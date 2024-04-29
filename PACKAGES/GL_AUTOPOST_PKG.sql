--------------------------------------------------------
--  DDL for Package GL_AUTOPOST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_AUTOPOST_PKG" AUTHID CURRENT_USER AS
/* $Header: glijeaps.pls 120.3 2005/05/05 01:09:02 kvora noship $ */
--
-- Package
--   GL_AUTOPOST_PKG
-- Purpose
--   This package is used to post GL batches based on some specific criteria.
--   This package was originally created for the Cross-Instance Consolidation
--   Project.
--   (this project has an AutoPost functionality)
-- History
--   11-11-01  	O Monnier       Created
--

  --
  -- Procedure
  --   Post_Batches
  -- Purpose
  --   Post batches based on specified criteria.
  -- Details
  --   This API can be used to post batches based on many different criteria:
  --   batch id, source, category, actual_flag, period_name, batch name ...
  -- History
  --   11-11-01   O Monnier		Created
  -- Arguments
  --   X_Request_Id		The posting request id
  --   X_Count_Bat	        The number of batches selected for posting
  PROCEDURE Post_Batches(X_Request_Id           OUT NOCOPY NUMBER,
                         X_Count_Sel_Bat        OUT NOCOPY NUMBER,
                         X_Access_Set_Id        IN NUMBER,
                         X_Ledger_Id            IN NUMBER,
                         X_Je_Batch_Id          IN NUMBER DEFAULT NULL,
                         X_Je_Source_Name       IN VARCHAR2 DEFAULT NULL,
                         X_Je_Category_Name     IN VARCHAR2 DEFAULT NULL,
                         X_Actual_Flag          IN VARCHAR2 DEFAULT NULL,
                         X_Period_Name          IN VARCHAR2 DEFAULT NULL,
                         X_From_Day_Before      IN NUMBER DEFAULT NULL,
                         X_To_Day_After         IN NUMBER DEFAULT NULL,
                         X_Name                 IN VARCHAR2 DEFAULT NULL,
                         X_Description          IN VARCHAR2 DEFAULT NULL,
                         X_Debug_Mode           IN BOOLEAN DEFAULT FALSE);

END gl_autopost_pkg;


 

/
