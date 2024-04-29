--------------------------------------------------------
--  DDL for Package PJM_PROJTASK_DELETION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJM_PROJTASK_DELETION" AUTHID CURRENT_USER AS
/* $Header: PJMPTDLS.pls 115.2 99/07/29 16:11:10 porting s $ */

--  Function name : Checkuse_ProjTask
--  Pre-reqs      : None.
--  Function      : Checks if project/task references are currently used
--                  in manufacturing applications.
--                  This function should be performed prior to project/task
--                  deletion from Oracle Projects
--  Parameters    :
--  IN            : p_project_id           IN       NUMBER      Optional
--                : p_task_id              IN       NUMBER      Optional
--  RETURNS       :
--               Returns -1 if both input Project/Task arguments are null.
--               Returns  1 if input Project/Task argument is still referred
--                             in MFG applications.
--
--                             This function does not check detailed status
--                             such as closed sales order line, or canceled PO
--                             line/shipments, etc.  Therefore those project/
--                             task references will prevent deletion in Oracle
--                             projects, so users should manually
--                             purge those references in mfg apps in order to
--                             delete it successfully in Oracle Projects.
--
--               Returns  0 if input Project/Task argument is not referred.
--
 FUNCTION CheckUse_ProjectTask (p_project_id IN  NUMBER,
                                p_task_id    IN  NUMBER)
	   RETURN NUMBER;

-- PRAGMA RESTRICT_REFERENCES (CheckUse_ProjectTask, WNDS);

--  Function name : Checkuse_ProjOrg
--  Pre-reqs      : None.
--  Function      : Checks if project references are currently present
--                  in the given organization
--  Parameters    :
--  IN            : p_project_id           IN       NUMBER      Required
--                : p_org_id               IN       NUMBER      Required
--  RETURNS       :
--               Returns -1 if either argument is null.
--               Returns  1 if input Project argument is still referred
--                             in input Org
--
--                             This function does not check detailed status
--                             such as closed sales order line, or canceled PO
--                             line/shipments, etc.
--
--               Returns  0 if input Project argument is not referred in
--                             the given org.
--
 FUNCTION CheckUse_ProjOrg (p_project_id IN  NUMBER,
                            p_org_id     IN  NUMBER)
 RETURN NUMBER;

-- PRAGMA RESTRICT_REFERENCES (CheckUse_ProjOrg, WNDS);

END PJM_PROJTASK_DELETION;

 

/
