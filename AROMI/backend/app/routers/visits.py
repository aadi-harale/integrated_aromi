from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import date
from app.database import get_db
from app.auth import get_current_worker
from app.models.models import Worker, HomeVisit, Child

router = APIRouter()


@router.get("/")
def list_visits(db: Session = Depends(get_db), worker: Worker = Depends(get_current_worker)):
    visits = db.query(HomeVisit).filter(HomeVisit.worker_id == worker.id).order_by(HomeVisit.scheduled_date.asc()).all()
    result = []
    for v in visits:
        child = db.query(Child).filter(Child.id == v.child_id).first()
        result.append({
            "id": v.id,
            "child_id": v.child_id,
            "child_name": child.name if child else "Unknown",
            "scheduled_date": str(v.scheduled_date) if v.scheduled_date else None,
            "visited_date": str(v.visited_date) if v.visited_date else None,
            "completed": v.completed,
            "priority": v.priority.value if hasattr(v.priority, 'value') else str(v.priority),
            "visit_reason": v.visit_reason,
            "findings": v.findings,
            "actions_taken": v.actions_taken,
        })
    return result


@router.get("/due")
def due_visits(db: Session = Depends(get_db), worker: Worker = Depends(get_current_worker)):
    today = date.today()
    visits = db.query(HomeVisit).filter(
        HomeVisit.worker_id == worker.id,
        HomeVisit.completed == False,
    ).all()
    result = []
    for v in visits:
        child = db.query(Child).filter(Child.id == v.child_id).first()
        result.append({
            "id": v.id,
            "child_id": v.child_id,
            "child_name": child.name if child else "Unknown",
            "scheduled_date": str(v.scheduled_date) if v.scheduled_date else None,
            "completed": v.completed,
            "priority": v.priority.value if hasattr(v.priority, 'value') else str(v.priority),
            "visit_reason": v.visit_reason,
        })
    return result
