--------------------------------------------------------
--  DDL for Package PJM_TASK_AUTO_ASSIGN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJM_TASK_AUTO_ASSIGN" AUTHID CURRENT_USER AS
/* $Header: PJMTKASS.pls 120.0.12010000.1 2008/07/30 04:24:40 appldev ship $ */

--
--  Name          : Inv_Task_WNPS
--
--  Function      : This function returns a task based on predefined
--                  rules and is specially designed for using in
--                  views.
--
--  Parameters    :
--  IN            : X_org_id                         NUMBER
--                : X_project_id                     NUMBER
--                : X_item_id                        NUMBER
--                : X_po_header_id                   NUMBER
--                : X_category_id                    NUMBER
--                : X_subinv_code                    VARCHAR2
--
FUNCTION Inv_Task_WNPS ( X_org_id        IN NUMBER
                       , X_project_id    IN NUMBER
                       , X_item_id       IN NUMBER
                       , X_po_header_id  IN NUMBER
                       , X_category_id   IN NUMBER
                       , X_subinv_code   IN VARCHAR2 )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (Inv_Task_WNPS, WNDS, WNPS);

--
--  Name          : Wip_Task_WNPS
--
--  Function      : This function returns a task based on predefined
--                  rules and is specially designed for using in
--                  views.
--
--  Parameters    :
--  IN            : X_org_id                         NUMBER
--                : X_project_id                     NUMBER
--                : X_operation_id                   NUMBER
--                : X_wip_entity_id                  NUMBER
--                : X_assy_item_id                   NUMBER
--                : X_dept_id                        NUMBER
--
FUNCTION Wip_Task_WNPS ( X_org_id         IN NUMBER
                       , X_project_id     IN NUMBER
                       , X_operation_id   IN NUMBER
                       , X_wip_entity_id  IN NUMBER
                       , X_assy_item_id   IN NUMBER
                       , X_dept_id        IN NUMBER )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (Wip_Task_WNPS, WNDS, WNPS);

--  Name 	  : WipMat_Task_WNPS
--
--  Function	  : This function returns a task based on predefined
--		    rules and is specially designed for using in
--		    views.
--
--  Parameters    :
--  IN	 	  : X_org_id		NUMBER
--		  : X_project_id	NUMBER
--		  : X_item_id		NUMBER
--		  : X_category_id	NUMBER
--                : X_subinv_code       VARCHAR2
--                : X_wip_entity_id     NUMBER
--                : X_assy_item_id      NUMBER
--                : X_operation_id      NUMBER
--                : X_dept_id           NUMBER
--

FUNCTION WipMat_Task_WNPS ( X_org_id            IN NUMBER
                          , X_project_id        IN NUMBER
                          , X_item_id           IN NUMBER
                          , X_category_id       IN NUMBER
                          , X_subinv_code       IN VARCHAR2
                          , X_wip_matl_txn_type IN VARCHAR2
                          , X_wip_entity_id     IN NUMBER
                          , X_assy_item_id      IN NUMBER
                          , X_operation_id      IN NUMBER
                          , X_dept_id           IN NUMBER )
RETURN NUMBER;
-- PRAGMA RESTRICT_REFERENCES (WipMat_Task_WNPS, WNDS, WNPS);

--  Name 	  : SCP_Task_WNPS
--
--  Function	  : This function returns a task based on predefined
--		    rules and is specially designed for using in
--		    views.
--
--  Parameters    :
--  IN	 	  : X_org_id		NUMBER
--		  : X_project_id	NUMBER
--		  : X_item_id		NUMBER
--		  : X_category_id	NUMBER
--		  : X_to_org_id		NUMBER
--

FUNCTION SCP_Task_WNPS ( X_org_id	IN NUMBER
		       , X_project_id	IN NUMBER
		       , X_item_id	IN NUMBER
		       , X_category_id  IN NUMBER
		       , X_to_org_id    IN NUMBER )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (SCP_Task_WNPS, WNDS, WNPS);

--
--  Name          : Assign_Task_Inv
--
--  Function      : This procedure assigns a task based on predefined
--                  rules if a material transaction has project
--                  references but no task references.  If assignment
--                  rule cannot be found, the transaction will be
--                  flagged as error and Cost Collection will not be
--                  performed
--
--  Parameters    :
--  IN            : X_transaction_id                 NUMBER
--                : X_transfer_flag                  VARCHAR2
--
--  IN OUT        : X_error_num                      NUMBER
--                : X_error_msg                      VARCHAR2
--
PROCEDURE assign_task_inv
  ( X_transaction_id   IN            NUMBER
  , X_error_num        IN OUT NOCOPY NUMBER
  , X_error_msg        IN OUT NOCOPY VARCHAR2);

--
--  Name          : Assign_Task_WIPL
--
--  Function      : This procedure assigns a task based on predefined
--                  rules if a WIP resource/overhead transaction has
--                  project references but no task references.  If
--                  assignment rule cannot be found, the transaction
--                  will beflagged as error and Cost Collection will
--                  not be performed
--
--  Parameters    :
--  IN            : X_transaction_id                 NUMBER
--
--  IN OUT        : X_error_num                      NUMBER
--                : X_error_msg                      VARCHAR2
--
PROCEDURE assign_task_wipl
  ( X_transaction_id   IN            NUMBER
  , X_error_num        IN OUT NOCOPY NUMBER
  , X_error_msg        IN OUT NOCOPY VARCHAR2);

END pjm_task_auto_assign;

/
