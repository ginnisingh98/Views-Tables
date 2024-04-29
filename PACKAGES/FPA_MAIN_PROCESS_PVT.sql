--------------------------------------------------------
--  DDL for Package FPA_MAIN_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FPA_MAIN_PROCESS_PVT" AUTHID CURRENT_USER AS
   /* $Header: FPAXWFMS.pls 120.1 2005/08/18 11:48:31 appldev noship $ */



-------------------------------------------------------------
--Start of Comments
--Name        : INITIATE_WORKFLOW
--
--Pre-reqs    : IN parameters need to be passed in with valid values
--
--Modifies    : None
--
--Locks       : None
--
--Function    : This procedure sets up all necessary workflow
--              attributes needed before starting the workflow
--              process.
--
--Parameter(s):
--
--IN          : p_pc_name               IN         VARCHAR2,
--              p_pc_id                 IN         NUMBER,
--              p_pc_description        IN         VARCHAR2,
--              p_pc_date_initiated     IN         DATE,
--              p_due_date              IN         DATE,
--              x_return_status         OUT NOCOPY VARCHAR2,
--              x_msg_count             OUT NOCOPY NUMBER,
--              x_msg_data              OUT NOCOPY VARCHAR2
--
--IN OUT:     : None
--
--OUT         : None
--
--Returns     : None
--
--Notes       : None
--
--Testing     : None
--
--End of Comments
-------------------------------------------------------------
PROCEDURE INITIATE_WORKFLOW(p_pc_name           IN         VARCHAR2,
 			    p_pc_id             IN         NUMBER,
			    p_last_pc_id        IN         NUMBER,
			    p_pc_description    IN         VARCHAR2,
			    p_pc_date_initiated IN         DATE,
			    p_due_date          IN         DATE,
			    x_return_status     OUT NOCOPY VARCHAR2,
			    x_msg_count         OUT NOCOPY NUMBER,
			    x_msg_data          OUT NOCOPY VARCHAR2
			   );

-- Cancels the main workflow process and starts an alternate process
PROCEDURE CANCEL_WORKFLOW(p_pc_name           IN         VARCHAR2,
			  p_pc_id             IN         NUMBER,
			  p_pc_description    IN         VARCHAR2,
			  p_pc_date_initiated IN         DATE,
			  p_due_date          IN         DATE,
			  x_return_status     OUT NOCOPY VARCHAR2,
			  x_msg_count         OUT NOCOPY NUMBER,
			  x_msg_data          OUT NOCOPY VARCHAR2
			 );

-- Launch the main workflow process
PROCEDURE LAUNCH_PROCESS(p_itemtype  IN         VARCHAR2,
			 p_itemkey   IN         VARCHAR2,
			 p_actid     IN         NUMBER,
			 p_funcmode  IN         VARCHAR2,
			 x_resultout OUT NOCOPY VARCHAR2);

-- Aborts existing workflow processes and raises Event when Planning cycle is CLOSED
PROCEDURE RAISE_CLOSEPC_EVENT(p_pc_id             IN         NUMBER,
			      x_return_status     OUT NOCOPY VARCHAR2,
			      x_msg_count         OUT NOCOPY NUMBER,
			      x_msg_data          OUT NOCOPY VARCHAR2
			     );

/* Workflow get methods */
/* Get distribution list */
-- gets all project analyst email addresses from the distribution list
PROCEDURE GET_DLIST(p_itemtype  IN         VARCHAR2,
		    p_itemkey   IN         VARCHAR2,
		    p_actid     IN         NUMBER,
		    p_funcmode  IN         VARCHAR2,
		    x_resultout OUT NOCOPY VARCHAR2);

/* Get access list */
-- gets all approvers or related persons email addresses from the access list
PROCEDURE GET_ALIST(p_itemtype  IN         VARCHAR2,
		    p_itemkey   IN         VARCHAR2,
		    p_actid     IN         NUMBER,
		    p_funcmode  IN         VARCHAR2,
		    x_resultout OUT NOCOPY VARCHAR2);

/* Get list of portfolio approvers*/
PROCEDURE GET_APPROVER(p_itemtype  IN         VARCHAR2,
		       p_itemkey   IN         VARCHAR2,
		       p_actid     IN         NUMBER,
		       p_funcmode  IN         VARCHAR2,
		       x_resultout OUT NOCOPY VARCHAR2);

/* Get list of portfolio analysts*/
PROCEDURE GET_ANALYST (p_itemtype  IN         VARCHAR2,
		       p_itemkey   IN         VARCHAR2,
		       p_actid     IN         NUMBER,
		       p_funcmode  IN         VARCHAR2,
		       x_resultout OUT NOCOPY VARCHAR2);

/* Get list of planning cycle managers*/
PROCEDURE GET_PC_MANAGERS (p_itemtype  IN         VARCHAR2,
		       p_itemkey   IN         VARCHAR2,
		       p_actid     IN         NUMBER,
		       p_funcmode  IN         VARCHAR2,
		       x_resultout OUT NOCOPY VARCHAR2);

/* Wrapper calls */
/* Project load */
-- calls Project Load api
PROCEDURE CALL_PROJ_LOAD(p_itemtype  IN         VARCHAR2,
			 p_itemkey   IN         VARCHAR2,
			 p_actid     IN         NUMBER,
			 p_funcmode  IN         VARCHAR2,
			 x_resultout OUT NOCOPY VARCHAR2);

/* Create Initial Scenario */
-- calls Create Initial Scenario api
PROCEDURE CALL_CREATE_INITIAL_SCENARIO(p_itemtype  IN         VARCHAR2,
				       p_itemkey   IN         VARCHAR2,
				       p_actid     IN         NUMBER,
				       p_funcmode  IN         VARCHAR2,
				       x_resultout OUT NOCOPY VARCHAR2);

/* Set Status */
-- sets the status of Planning Cycle or Scenario
PROCEDURE CALL_SET_STATUS(p_itemtype  IN         VARCHAR2,
			  p_itemkey   IN         VARCHAR2,
			  p_actid     IN         NUMBER,
			  p_funcmode  IN         VARCHAR2,
			  x_resultout OUT NOCOPY VARCHAR2);

/* Call Project Sets */
-- calls the Project Sets API
PROCEDURE CALL_PROJECT_SETS(p_itemtype  IN         VARCHAR2,
			    p_itemkey   IN         VARCHAR2,
			    p_actid     IN         NUMBER,
			    p_funcmode  IN         VARCHAR2,
			    x_resultout OUT NOCOPY VARCHAR2);

/* Is Plan Approved */
-- Checks if the Plan is approved
PROCEDURE IS_PLAN_APPROVED(p_itemtype  IN         VARCHAR2,
			   p_itemkey   IN         VARCHAR2,
			   p_actid     IN         NUMBER,
			   p_funcmode  IN         VARCHAR2,
			   x_resultout OUT NOCOPY VARCHAR2);

-- Sets the Planning Cycle Status to ANALYSIS
PROCEDURE SET_STATUS_ANALYSIS(p_itemtype  IN         VARCHAR2,
			      p_itemkey   IN         VARCHAR2,
			      p_actid     IN         NUMBER,
			      p_funcmode  IN         VARCHAR2,
			      x_resultout OUT NOCOPY VARCHAR2);

-- Sets the Planning Cycle Status to APPROVED
PROCEDURE SET_STATUS_APPROVED(p_itemtype  IN         VARCHAR2,
			      p_itemkey   IN         VARCHAR2,
			      p_actid     IN         NUMBER,
			      p_funcmode  IN         VARCHAR2,
			      x_resultout OUT NOCOPY VARCHAR2);

-- Sets the Planning Cycle Status to CLOSED
PROCEDURE SET_STATUS_CLOSED(p_itemtype  IN         VARCHAR2,
			    p_itemkey   IN         VARCHAR2,
			    p_actid     IN         NUMBER,
			    p_funcmode  IN         VARCHAR2,
			    x_resultout OUT NOCOPY VARCHAR2);

-- Sets the Planning Cycle Status to COLLECTING
PROCEDURE SET_STATUS_COLLECTING(p_itemtype  IN         VARCHAR2,
				p_itemkey   IN         VARCHAR2,
				p_actid     IN         NUMBER,
				p_funcmode  IN         VARCHAR2,
				x_resultout OUT NOCOPY VARCHAR2);

-- Sets the Planning Cycle Status to SUBMITTED
PROCEDURE SET_STATUS_SUBMITTED(p_itemtype  IN         VARCHAR2,
			       p_itemkey   IN         VARCHAR2,
			       p_actid     IN         NUMBER,
			       p_funcmode  IN         VARCHAR2,
			       x_resultout OUT NOCOPY VARCHAR2);

/* Workflow business events */
/* User force action */
-- pings the User Action business event
PROCEDURE FORCE_USER_ACTION(p_itemkey       IN         VARCHAR2,
			    p_event_name    IN         VARCHAR2,
			    x_return_status OUT NOCOPY VARCHAR2,
			    x_msg_count     OUT NOCOPY NUMBER,
			    x_msg_data      OUT NOCOPY VARCHAR2);

/* Workflow business events */
/* Submit plan */
-- pings the Submit Plan business event
PROCEDURE SUBMIT_PLAN(p_itemkey       IN         VARCHAR2,
		      p_event_name    IN         VARCHAR2,
		      x_return_status OUT NOCOPY VARCHAR2,
		      x_msg_count     OUT NOCOPY NUMBER,
		      x_msg_data      OUT NOCOPY VARCHAR2);

/* Workflow business events */
/* Approve or Reject a plan */
-- pings the Approve Reject Plan business event
PROCEDURE APPROVE_REJECT_PLAN(p_itemkey       IN         VARCHAR2,
			      p_event_name    IN         VARCHAR2,
			      x_return_status OUT NOCOPY VARCHAR2,
			      x_msg_count     OUT NOCOPY NUMBER,
			      x_msg_data      OUT NOCOPY VARCHAR2);

--Procedure to copy Projects from last planning cycle of current portfolio

PROCEDURE COPY_PROJ_FROM_PREV_PC(p_itemtype  IN         VARCHAR2,
			         p_itemkey   IN         VARCHAR2,
	  		         p_actid     IN         NUMBER,
			         p_funcmode  IN         VARCHAR2,
			         x_resultout OUT NOCOPY VARCHAR2);

--Procedure to attach AW for workflow

PROCEDURE WF_ATTACH_AW          (p_itemtype  IN         VARCHAR2,
			         p_itemkey   IN         VARCHAR2,
	  		         p_actid     IN         NUMBER,
			         p_funcmode  IN         VARCHAR2,
			         x_resultout OUT NOCOPY VARCHAR2);

--Procedure to detach AW for workflow

PROCEDURE WF_DETACH_AW          (p_itemtype  IN         VARCHAR2,
			         p_itemkey   IN         VARCHAR2,
	  		         p_actid     IN         NUMBER,
			         p_funcmode  IN         VARCHAR2,
			         x_resultout OUT NOCOPY VARCHAR2);

END FPA_MAIN_PROCESS_PVT;
 

/
