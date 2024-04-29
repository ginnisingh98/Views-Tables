--------------------------------------------------------
--  DDL for Package FF_GLOBALS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FF_GLOBALS_F_PKG" AUTHID CURRENT_USER as
/* $Header: ffglb01t.pkh 120.1 2006/06/22 16:23:48 mseshadr ship $ */
--
 /*===========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+
  Name
    ff_globals_f_pkg
  Purpose
    Supports the GLB block in the form FFWSDGLB (Define Globals).
  Notes

  History
    11-Mar-94  J.S.Hobbs   40.0         Date created.
    31-Jan-95  J.S.Hobbs   40.2         Removed aol WHO columns.
    12-Apr-05  Shisriva    --          Version 115.3,115.4 for MLS of FF_GLOBALS_F.
    05-May-05  Shisriva    115.5       Fixes for bug 4350976. Removed the Base
                                       Parameters from insert_row procedure.
    05-May-05  Shisriva    115.6       Fixes for bug 4350976. Changed defualting
                                       of parameters in update_row and lock_row.
    22-Jun-06  mseshadr    115.7       Added procedure LOAD_ROW and global
                                       variables for lct support.
 ============================================================================*/
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Insert_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert of a global via the  --
 --   Define Global form.                                                   --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- |                     Package Header Variable                              |
-- ----------------------------------------------------------------------------
--
g_dml_status boolean := FALSE;  -- Global package variable


--used by load_row procedure
Type glb_record is record(global_id            ff_globals_f.global_id%TYPE,
                          global_name          ff_globals_f.GLOBAL_NAME%TYPE,
                          legislation_code     ff_globals_f.LEGISLATION_CODE%TYPE,
                          created_by           ff_globals_f.created_by%TYPE,
                          creation_date        ff_globals_f.creation_date%type,
                          global_upload_flag   boolean);
g_glb_record glb_record;
g_leg_view_exists  boolean;--used in hrglobal for caching LEG_VIEW's presence
--

 PROCEDURE Insert_Row(X_Rowid                 IN OUT NOCOPY VARCHAR2,
                      X_Global_Id             IN OUT NOCOPY NUMBER,
                      X_Effective_Start_Date                DATE,
                      X_Effective_End_Date                  DATE,
                      X_Business_Group_Id                   NUMBER,
                      X_Legislation_Code                    VARCHAR2,
                      X_Data_Type                           VARCHAR2,
                      X_Global_Name           IN OUT NOCOPY VARCHAR2,
                      X_Global_Description                  VARCHAR2,
                      X_Global_Value                        VARCHAR2);
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Lock_Row                                                              --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert , update and delete  --
 --   of a formula by applying a lock on a global in the Define Global form.--
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                    X_Global_Id                             NUMBER,
                    X_Effective_Start_Date                  DATE,
                    X_Effective_End_Date                    DATE,
                    X_Business_Group_Id                     NUMBER,
                    X_Legislation_Code                      VARCHAR2,
                    X_Data_Type                             VARCHAR2,
                    X_Global_Name                           VARCHAR2,
                    X_Global_Description                    VARCHAR2,
                    X_Global_Value                          VARCHAR2,
		    X_Base_Global_Name                      VARCHAR2 default NULL,
		    X_Base_Global_Description               VARCHAR2 default NULL);
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Lock_Row                                                              --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the update of a global via the  --
 --   Define Global form.                                                   --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                      X_Global_Id                           NUMBER,
                      X_Effective_Start_Date                DATE,
                      X_Effective_End_Date                  DATE,
                      X_Business_Group_Id                   NUMBER,
                      X_Legislation_Code                    VARCHAR2,
                      X_Data_Type                           VARCHAR2,
                      X_Global_Name                         VARCHAR2,
                      X_Global_Description                  VARCHAR2,
                      X_Global_Value                        VARCHAR2,
	X_Base_Global_Name           VARCHAR2 default  hr_api.g_varchar2,
	X_Base_Global_Description    VARCHAR2 default  hr_api.g_varchar2);
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Delete_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the delete of a global via the  --
 --   Define Global form.                                                   --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Delete_Row(X_Rowid              VARCHAR2,
                     -- X_Global_Id          NUMBER,   -- Extra Columns
                      X_Global_Name        VARCHAR2,
                      X_Business_Group_Id  NUMBER,
                      X_Legislation_Code   VARCHAR2);
--For MLS-----------------------------------------------------------------------
PROCEDURE set_translation_globals(p_business_group_id NUMBER,
                                  p_legislation_code  VARCHAR2);
procedure ADD_LANGUAGE;
procedure TRANSLATE_ROW (  X_B_GLOBAL_NAME		VARCHAR2,
			   X_B_LEGISLATION_CODE		VARCHAR2,
			   X_GLOBAL_NAME		VARCHAR2,
			   X_GLOBAL_DESCRIPTION		VARCHAR2,
			   X_OWNER			VARCHAR2);

procedure validate_translation(global_id		IN NUMBER,
			       language			IN VARCHAR2,
			       global_name		IN VARCHAR2,
			       global_description	IN VARCHAR2);

function return_dml_status return boolean;
--------------------------------------------------------------------------------
--


--To be called from ffglbs1.lct
Procedure Load_Row ( P_BASE_GLOBAL_NAME          VARCHAR2
                    ,P_EFFECTIVE_START_DATE      DATE
                    ,P_EFFECTIVE_END_DATE        DATE
                    ,P_GLOBAL_VALUE              VARCHAR2
                    ,P_DATA_TYPE                 VARCHAR2
                    ,P_LEGISLATION_CODE          VARCHAR2
                    ,P_BASE_GLOBAL_DESCRIPTION   VARCHAR2
                    ,P_GLOBAL_NAME_TL            VARCHAR2
                    ,P_GLOBAL_DESCRIPTION_TL     VARCHAR2
                    ,P_MAX_UPDATE_DATE           DATE);



END FF_GLOBALS_F_PKG;

/
