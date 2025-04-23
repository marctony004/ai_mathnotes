from fastapi import FastAPI
from sympy import *
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import uvicorn

app = FastAPI(
    title="MathNotes CAS API",
    description="Provides symbolic math analysis for equations",
    version="1.0",
    docs_url="/docs",
    redoc_url=None
)

# Enable CORS (for iPad/mobile local access)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Declare global symbols
x, y, z = symbols("x y z")


class EquationRequest(BaseModel):
    equation: str


@app.post("/analyze")
async def analyze_equation(req: EquationRequest):
    try:
        expr_str = req.equation.replace("^", "**")  # Safety fix for x^2 style input

        if '=' in expr_str:
            # Handle equation solving
            lhs, rhs = expr_str.split('=')
            equation = Eq(sympify(lhs), sympify(rhs))
            solution = solve(equation, x)

            return {
                "latex": f"x = {latex(solution)}",
                "solution": [str(s) for s in solution],
                "derivative": "0",  # derivative of a constant/solution
                "integral": f"{latex(integrate(solution[0], x))}x" if solution else "N/A",
                "3d_points": []
            }

        # Handle basic expressions (not equations)
        expr = sympify(expr_str)
        return {
            "latex": latex(expr),
            "derivative": latex(diff(expr, x)),
            "integral": latex(integrate(expr, x)),
            "3d_points": generate_3d_points(expr)
        }

    except Exception as e:
        return {"error": str(e)}


def generate_3d_points(expr):
    points = []
    for xi in range(-10, 11):
        for yi in range(-10, 11):
            try:
                zi = expr.subs({x: xi, y: yi})
                points.append({"x": xi, "y": yi, "z": float(zi)})
            except:
                continue
    return points


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
