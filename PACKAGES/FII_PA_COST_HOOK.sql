--------------------------------------------------------
--  DDL for Package FII_PA_COST_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_PA_COST_HOOK" AUTHID CURRENT_USER as
/* $Header: FIIPA15S.pls 120.0 2002/08/24 05:00:30 appldev noship $ */

  --
  -- Package FII_PA_COST_HOOK implements collection hooks for
  -- EDW Project Cost fact. Collection hooks like FII_PA_COST_HOOK are
  -- used by EDW collection engine to pass control to
  -- product specific code at different stages of collection process.
  --
  -- When FII_PA_COST_HOOK finishes execution, control is
  -- returned back to the collection engine.
  --
  -- This concept is similar to message (event) handling mechanisms.
  --


  -- --------------------------
  -- function PRE_FACT_COLL
  -- --------------------------

  -- Function PRE_FACT_COLL is Project Cost fact pre-collection hook.
  -- The function implements "denormalized" Task Owning organization
  -- foreign key in facts (PROJECT_ORG_FK_KEY).
  --
  -- The function does the following:
  --
  -- 1. For all new rows in the FII_PA_COST_FSTG staging table it
  --    populates PROJECT_ORG_FK with the up-to-date Task Owning
  --    organization foreign key. Task owning organization FK is stored in
  --    EDW_PROJ_TASK_LCT.DENORM_TASK_ORG_FK column in EDW.
  --
  -- 2. Update PROJECT_ORG_FK_KEY for all records in the FII_PA_COST_F
  --    fact table which belong to tasks (PROJECT_FK_KEY) for which
  --    Task Owning organization has changed. The function uses
  --    FII_SYSTEM_EVENT_LOG table to detect changes in Task Owning
  --    organizations.

  function pre_fact_coll return boolean;

end;

 

/
