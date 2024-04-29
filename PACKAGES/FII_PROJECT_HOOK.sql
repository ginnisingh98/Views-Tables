--------------------------------------------------------
--  DDL for Package FII_PROJECT_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_PROJECT_HOOK" AUTHID CURRENT_USER as
/* $Header: FIIPA17S.pls 120.0 2002/08/24 05:00:43 appldev noship $ */

  --
  -- Package FII_PROJECT_HOOK implements collection hooks for
  -- EDW Project Dimension. Collection hooks like FII_PROJECT_HOOK are
  -- used by EDW collection engine to pass control to
  -- product specific code at different stages of collection process.
  --
  -- When FII_PROJECT_HOOK function finishs execution, control is
  -- returned back to the collection engine.
  --
  -- This concept is similar to message (event) handling mechanisms.
  --


  -- ---------------------------------
  -- function PRE_DIMENSION_CALL
  -- ---------------------------------

  -- Function PRE_DIMENSION_CALL is Project dimension pre-collection hook.
  -- The function detects change in Task Owning organization made in Oracle Projects
  -- and if such change occurs, inserts three records into FII_SYSTEM_EVENT_LOG
  -- table (one record per PA fact - cost, revenue, budget) to notify
  -- PA fact collection processes that task has changed its task owning
  -- organization and that task owing organization foreign key in PA fact tables need to be
  -- updated accordingly to reflect this.
  -- PROJECT_ORG_FK column in PA facts is denormalized from Project Task level,
  -- Corresponding column in the EDW_PROJ_TASK_LTC table is DENORM_TASK_ORG_FK.

  function pre_dimension_coll return boolean;

end FII_PROJECT_HOOK;

 

/
