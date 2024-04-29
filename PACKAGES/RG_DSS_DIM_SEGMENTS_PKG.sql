--------------------------------------------------------
--  DDL for Package RG_DSS_DIM_SEGMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RG_DSS_DIM_SEGMENTS_PKG" AUTHID CURRENT_USER AS
/* $Header: rgiddsms.pls 120.2 2002/11/14 02:58:18 djogg ship $ */
--
-- Name
--   RG_DSS_DIM_SEGMENTS_PKG
-- Purpose
--   to include all server side procedures and packages for table
--   rg_dss_DIM_SEGMENTS
-- Notes
--
-- History
--   06/16/95	A Chen	Created
--
--
-- Procedures

-- Name
--   check_unique_sequence
-- Purpose
--   unique check for sequence
-- Arguments
--   X_rowid              rowid
--   X_dimension_id       dimension id
--   X_sequence           segment sequence
--
PROCEDURE check_unique_sequence(X_rowid VARCHAR2,
                               X_dimension_id NUMBER,
                               X_sequence NUMBER);


-- Name
--   check_unique_segment
-- Purpose
--   unique check for sequence
-- Arguments
--   X_rowid                         rowid
--   X_dimension_id                  dimension id
--   X_application_column_name       segment name
--
--
PROCEDURE check_unique_segment(X_rowid VARCHAR2,
                              X_dimension_id NUMBER,
                              X_application_column_name VARCHAR2);


-- Name
--   number_of_dim_segments
-- Purpose
--   find the number of segments used in a dimension
-- Arguments
--   X_dimension_id                  dimension id
--
-- Returns
--   The number of segments used in a dimension
--
FUNCTION number_of_dim_segments(X_dimension_id NUMBER)
RETURN NUMBER;


-- *********************************************************************
-- The following procedures are necessary to handle the base view form.

PROCEDURE insert_row(X_master_dimension_id           IN OUT NOCOPY NUMBER,
                     X_rowid                         IN OUT NOCOPY VARCHAR2,
		     X_dimension_id    		     IN OUT NOCOPY NUMBER,
 		     X_sequence		  	            NUMBER,
      		     X_application_column_name		    VARCHAR2,
		     X_id_flex_code		            VARCHAR2,
		     X_id_flex_num			    NUMBER,
                     X_max_desc_size                        NUMBER,
                     X_creation_date                        DATE,
                     X_created_by                           NUMBER,
                     X_last_update_date                     DATE,
                     X_last_updated_by                      NUMBER,
                     X_last_update_login                    NUMBER,
		     X_range_set_id			    NUMBER,
		     X_account_type			    VARCHAR2,
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
                     X_attribute15                          VARCHAR2
                     );

PROCEDURE update_row(X_rowid                         IN OUT NOCOPY VARCHAR2,
		     X_dimension_id    		  	    NUMBER,
 		     X_sequence		  	            NUMBER,
      		     X_application_column_name		    VARCHAR2,
		     X_id_flex_code		            VARCHAR2,
		     X_id_flex_num			    NUMBER,
                     X_max_desc_size                        NUMBER,
                     X_last_update_date                     DATE,
                     X_last_updated_by                      NUMBER,
                     X_last_update_login                    NUMBER,
		     X_range_set_id			    NUMBER,
		     X_account_type			    VARCHAR2,
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
                     X_attribute15                          VARCHAR2
                     );

PROCEDURE lock_row(X_rowid                         IN OUT NOCOPY VARCHAR2,
		   X_dimension_id    		  	  NUMBER,
 		   X_sequence		  	          NUMBER,
      		   X_application_column_name              VARCHAR2,
		   X_id_flex_code		          VARCHAR2,
		   X_id_flex_num                          NUMBER,
                   X_max_desc_size                        NUMBER,
		   X_range_set_id                         NUMBER,
		   X_account_type			  VARCHAR2,
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
                   X_attribute15                          VARCHAR2
                   );


PROCEDURE delete_row(
            X_rowid VARCHAR2,
            X_Dimension_Id NUMBER);


END RG_DSS_DIM_SEGMENTS_PKG;

 

/
