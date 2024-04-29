--------------------------------------------------------
--  DDL for Package GL_GLCOAM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_GLCOAM_PKG" AUTHID CURRENT_USER as
/* $Header: glmrcoas.pls 120.3 2005/07/27 17:38:23 ticheng ship $ */

  --
  -- Procedure
  --   run_prog
  -- Purpose
  --   This procedure executes the actual work to create the mirror strcutre
  --   under 'GLLE'.
  -- History
  --   01/31/03     C Ma            Created.
  -- Arguments
  --   id_flex_num    NUMBER
  --   mode      VARCHAR2
  -- Example
  --   gl_glcoam_pkg.run_prog(101,'Y');
  -- Notes
  --
  PROCEDURE run_prog(X_id_flex_num NUMBER,
                     X_mode   VARCHAR2);

  --
  -- Function
  --   gl_coam_rule
  -- Purpose
  --   This function is the pl/sql rule function used by the business event
  --   subscription on oracle.apps.fnd.flex.kff.structure.compiled.
  -- History
  --   07/12/05     T Cheng         Created.
  -- Arguments
  --   p_subscription_guid   The globally unique identifier of the subscription
  --   p_event               The event message
  -- Notes
  --
  FUNCTION gl_coam_rule(p_subscription_guid IN RAW,
                        p_event             IN OUT NOCOPY WF_EVENT_T)
    RETURN VARCHAR2;

END GL_GLCOAM_PKG;

 

/
