from fastapi import FastAPI, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import sympy as sp

app = FastAPI()

# Enable CORS so Flutter frontend can access it locally
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class MathRequest(BaseModel):
    expression: str

@app.post("/solve")
def solve_expression(req: MathRequest):
    try:
        expr = sp.sympify(req.expression)
        simplified = sp.simplify(expr)
        result = str(simplified)
        return {"input": req.expression, "result": result}
    except Exception as e:
        return {"error": str(e)}

@app.post("/derivative")
def compute_derivative(req: MathRequest):
    try:
        expr = sp.sympify(req.expression)
        derivative = sp.diff(expr)
        return {"input": req.expression, "derivative": str(derivative)}
    except Exception as e:
        return {"error": str(e)}

@app.post("/integrate")
def compute_integral(req: MathRequest):
    try:
        expr = sp.sympify(req.expression)
        integral = sp.integrate(expr)
        return {"input": req.expression, "integral": str(integral)}
    except Exception as e:
        return {"error": str(e)}

@app.post("/latex")
def convert_to_latex(req: MathRequest):
    try:
        expr = sp.sympify(req.expression)
        latex = sp.latex(expr)
        return {"input": req.expression, "latex": latex}
    except Exception as e:
        return {"error": str(e)}
    
@app.get("/")
def read_root():
    return {"message": "FastAPI is running"}

