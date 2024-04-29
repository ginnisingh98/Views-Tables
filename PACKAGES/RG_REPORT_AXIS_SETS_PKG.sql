--------------------------------------------------------
--  DDL for Package RG_REPORT_AXIS_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RG_REPORT_AXIS_SETS_PKG" AUTHID CURRENT_USER AS
/* $Header: rgiraxss.pls 120.7 2004/07/16 18:30:06 ticheng ship $ */
--
-- Name
--   rg_report_axis_sets_pkg
-- Purpose
--   to include all server side procedures and packages for table
--   rg_report_axis_sets
-- Notes
--
-- History
--   11/01/93	A Chen	Created
--
--
-- Procedures

-- Name
--   update_structure_info
-- Purpose
--   update id_flex_code and structure_id for a axis set
-- Arguments
--   X_axis_set_id     axis set id
--   X_id_flex_code    id flex code
--   X_structure_id    structure_id or chart of accounts id
--
PROCEDURE update_structure_info(X_axis_set_id NUMBER,
                                X_id_flex_code VARCHAR2,
                                X_structure_id NUMBER);

-- Name
--   check_unique
-- Purpose
--   unique check for name
-- Arguments
--   X_rowid              rowid
--   X_name               row set name or column set name
--   X_axis_set_type      'R' or 'C'
--   X_application_id     application_id
--
-- Returns
--   TRUE   if unique
--   FALSE  if not unique
--
FUNCTION check_unique(X_rowid VARCHAR2,
                      X_name VARCHAR2,
                      X_axis_set_type VARCHAR2,
                      X_application_id NUMBER) RETURN BOOLEAN;

-- Name
--   check_references
-- Purpose
--   Referential integrity check on rg_report_axis_sets
-- Arguments
--   X_axis_set_id
--   X_axis_set_type      'R' or 'C'
--
PROCEDURE check_references(X_axis_set_id NUMBER,
                           X_axis_set_type VARCHAR2);

-- Name
--   get_nextval
-- Purpose
--   Retrieves next value for axis_set_id from
--   rg_report_axis_sets_s
-- Arguments
--   None.
--
FUNCTION get_nextval RETURN NUMBER;

-- *********************************************************************
-- The following procedures are necessary to handle the base view form.

PROCEDURE insert_row(X_rowid                  IN OUT NOCOPY VARCHAR2,
		     X_application_id    		    NUMBER,
 		     X_axis_set_id	      IN OUT NOCOPY NUMBER,
      		     X_name				    VARCHAR2,
 		     X_axis_set_type			    VARCHAR2,
                     X_security_flag                        VARCHAR2,
		     X_display_in_list_flag	            VARCHAR2,
 		     X_period_set_name			    VARCHAR2,
		     X_description		            VARCHAR2,
                     X_column_set_header                    VARCHAR2,
		     X_segment_name		            VARCHAR2,
		     X_id_flex_code		            VARCHAR2,
		     X_structure_id			    NUMBER,
                     X_creation_date                        DATE,
                     X_created_by                           NUMBER,
                     X_last_update_date                     DATE,
                     X_last_updated_by                      NUMBER,
                     X_last_update_login                    NUMBER,
                     X_context                              VARCHAR2,
                     X_attribute1                           VARCHAR2,
                     X_attribute2                           VARCHAR2,
                     X_attribute3                           VARCHAR2,
                     X_attribute4                           VARCHAR2,
                     X_attribute5                           VARCHAR2,
                     X_attribute6                           VARCHAR2,
                     X_attribute7                           VARCHAR2,
                     X_attribute8                           VARCHAR2,
                     X_attribute9                           VARCHAR2,
                     X_attribute10                          VARCHAR2,
                     X_attribute11                          VARCHAR2,
                     X_attribute12                          VARCHAR2,
                     X_attribute13                          VARCHAR2,
                     X_attribute14                          VARCHAR2,
                     X_attribute15                          VARCHAR2,
                     X_taxonomy_id                          NUMBER
                     );

PROCEDURE lock_row(X_rowid                                VARCHAR2,
		   X_application_id    		          NUMBER,
 		   X_axis_set_id			  NUMBER,
      		   X_name			          VARCHAR2,
 	           X_axis_set_type			  VARCHAR2,
                   X_security_flag                        VARCHAR2,
		   X_display_in_list_flag	          VARCHAR2,
 		   X_period_set_name			  VARCHAR2,
		   X_description		          VARCHAR2,
                   X_column_set_header                    VARCHAR2,
		   X_segment_name		          VARCHAR2,
		   X_id_flex_code		          VARCHAR2,
		   X_structure_id			  NUMBER,
                   X_context                              VARCHAR2,
                   X_attribute1                           VARCHAR2,
                   X_attribute2                           VARCHAR2,
                   X_attribute3                           VARCHAR2,
                   X_attribute4                           VARCHAR2,
                   X_attribute5                           VARCHAR2,
                   X_attribute6                           VARCHAR2,
                   X_attribute7                           VARCHAR2,
                   X_attribute8                           VARCHAR2,
                   X_attribute9                           VARCHAR2,
                   X_attribute10                          VARCHAR2,
                   X_attribute11                          VARCHAR2,
                   X_attribute12                          VARCHAR2,
                   X_attribute13                          VARCHAR2,
                   X_attribute14                          VARCHAR2,
                   X_attribute15                          VARCHAR2,
                   X_taxonomy_id                          NUMBER
                   );

PROCEDURE update_row(X_rowid                  IN OUT NOCOPY VARCHAR2,
		     X_application_id    		    NUMBER,
 		     X_axis_set_id			    NUMBER,
      		     X_name				    VARCHAR2,
 		     X_axis_set_type			    VARCHAR2,
                     X_security_flag                        VARCHAR2,
		     X_display_in_list_flag	            VARCHAR2,
 		     X_period_set_name			    VARCHAR2,
		     X_description		            VARCHAR2,
                     X_column_set_header                    VARCHAR2,
		     X_segment_name		            VARCHAR2,
		     X_id_flex_code		            VARCHAR2,
		     X_structure_id			    NUMBER,
                     X_last_update_date                     DATE,
                     X_last_updated_by                      NUMBER,
                     X_last_update_login                    NUMBER,
                     X_context                              VARCHAR2,
                     X_attribute1                           VARCHAR2,
                     X_attribute2                           VARCHAR2,
                     X_attribute3                           VARCHAR2,
                     X_attribute4                           VARCHAR2,
                     X_attribute5                           VARCHAR2,
                     X_attribute6                           VARCHAR2,
                     X_attribute7                           VARCHAR2,
                     X_attribute8                           VARCHAR2,
                     X_attribute9                           VARCHAR2,
                     X_attribute10                          VARCHAR2,
                     X_attribute11                          VARCHAR2,
                     X_attribute12                          VARCHAR2,
                     X_attribute13                          VARCHAR2,
                     X_attribute14                          VARCHAR2,
                     X_attribute15                          VARCHAR2,
                     X_taxonomy_id                          NUMBER
                     );

PROCEDURE delete_row(X_rowid VARCHAR2,
                     X_axis_set_id NUMBER);

PROCEDURE Load_Row (
           X_Application_Id  			NUMBER,
           X_Seeded_Name                        VARCHAR2,
      	   X_Name			        VARCHAR2,
 	   X_Axis_Set_Type                      VARCHAR2,
	   X_Display_In_List_Flag               VARCHAR2,
	   X_Description                        VARCHAR2,
           X_Column_Set_Header                  VARCHAR2,
	   X_Segment_Name                       VARCHAR2,
	   X_Id_Flex_Code                       VARCHAR2,
           X_Structure_Id                       NUMBER,
	   X_Context                            VARCHAR2,
           X_Attribute1                         VARCHAR2,
           X_Attribute2                         VARCHAR2,
           X_Attribute3                         VARCHAR2,
           X_Attribute4                         VARCHAR2,
           X_Attribute5                         VARCHAR2,
           X_Attribute6                         VARCHAR2,
           X_Attribute7                         VARCHAR2,
           X_Attribute8                         VARCHAR2,
           X_Attribute9                         VARCHAR2,
           X_Attribute10                        VARCHAR2,
           X_Attribute11                        VARCHAR2,
           X_Attribute12                        VARCHAR2,
           X_Attribute13                        VARCHAR2,
           X_Attribute14                        VARCHAR2,
           X_Attribute15                        VARCHAR2,
	   X_Owner                              VARCHAR2,
	   X_Force_Edits                        VARCHAR2
           );

PROCEDURE Translate_Row (
	    X_Name           VARCHAR2,
	    X_Description    VARCHAR2,
	    X_Seeded_Name    VARCHAR2,
	    X_Owner          VARCHAR2,
	    X_Force_Edits    VARCHAR2
            );

END RG_REPORT_AXIS_SETS_PKG;

 

/
