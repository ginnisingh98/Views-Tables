--------------------------------------------------------
--  DDL for Package GL_WEB_PLSQL_CARTRIDGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_WEB_PLSQL_CARTRIDGE" AUTHID CURRENT_USER as
/* $Header: glwplcrs.pls 120.7 2005/05/05 02:08:21 kvora ship $ */

  -- Procedure
  --   GCS_CHVHTML
  -- Purpose
  --   Generate dynamic html to call the Consolidation
  --   Hierarchy Viewer applet.
  -- Arguments
  --   Consolidation Set Id,
  --   Display_Option,
  --   Mode
  -- Example
  --   GL_WEB_PLSQL_CARTRIDGE.gcs_chvhtml(1020, 'SOB', 'R');
  -- Notes
  --
  PROCEDURE GCS_CHVHTML(X_Consolidation_Set_Id  IN NUMBER,
                        X_Display_Option IN VARCHAR2,
                        X_Appl_Id IN NUMBER,
                        X_User_Id IN NUMBER,
                        X_Resp_Id IN NUMBER,
                        X_Mode IN VARCHAR2 DEFAULT 'R'
                      );

END GL_WEB_PLSQL_CARTRIDGE ;

 

/
