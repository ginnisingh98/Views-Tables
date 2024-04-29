--------------------------------------------------------
--  DDL for Package PJM_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJM_UTILS" AUTHID CURRENT_USER AS
/* $Header: PJMPUTLS.pls 120.1 2006/03/08 14:04:19 yliou noship $ */
FUNCTION Get_Demand_Quantity (
          X_line_id IN NUMBER
) RETURN NUMBER;
--
--  Name          : Last_Accum_Period
--  Pre-reqs      : None.
--  Function      : This function returns the last accumulated period
--                  for a given project or project / task combo.
--
--
--  Parameters    :
--  IN            : X_project_id              IN       NUMBER
--                : X_task_id                 IN       NUMBER
--
--  Returns       : Last accum period
--
FUNCTION Last_Accum_Period (
          X_project_id       IN NUMBER,
          X_task_id          IN NUMBER DEFAULT NULL
) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (Last_Accum_Period, WNDS, WNPS);


--
--  Name          : default_wip_acct_class
--  Pre-reqs      : None.
--  Function      : This function returns the default WIP accounting
--                  class for the given organization , project and
--                  task.  The default is derived first from the
--                  task level, and if not found, the project level.
--
--
--  Parameters    :
--  IN            : X_inventory_org_id        IN       NUMBER
--                : X_project_id              IN       NUMBER
--                : X_task_id                 IN       NUMBER
--                : X_class_type              IN       NUMBER
--
--  Returns       : WIP accounting class code
--
FUNCTION default_wip_acct_class
( X_inventory_org_id    in number
, X_project_id          in number
, X_task_id             in number
, X_class_type          in number
) RETURN VARCHAR2;

END;

 

/
