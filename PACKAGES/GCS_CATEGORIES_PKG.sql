--------------------------------------------------------
--  DDL for Package GCS_CATEGORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_CATEGORIES_PKG" AUTHID CURRENT_USER AS
/* $Header: gcscategorys.pls 120.1 2005/10/30 05:17:06 appldev noship $ */
   TYPE r_category_info IS RECORD
    				(category_code	 		VARCHAR2(80),
    				 category_number		NUMBER(15),
    				 net_to_re_flag			VARCHAR2(1),
    				 target_entity_code		VARCHAR2(30),
				 support_multi_parents_flag	VARCHAR2(1));

   TYPE t_category_info IS TABLE OF r_category_info;

    g_oper_category_info	t_category_info;
    g_cons_category_info	t_category_info;


  --
  -- Procedure
  --   Insert_Row
  -- Purpose
  --   Inserts a row into the gcs_categories_b table.
  -- Arguments
  --   row_id
  --   category_code
  --   category_number
  --   net_to_re_flag
  --   target_entity_code
  --   category_type_code
  --   associated_object_id
  --   org_output_code
  --   support_multi_parents_flag
  --   enabled_flag
  --   specific_intercompany_id
  --   category_name
  --   description
  --   creation_date
  --   created_by
  --   last_update_date
  --   last_updated_by
  --   last_update_login
  --   object_version_number
  -- Example
  --   GCS_CATEGORIES_PKG.Insert_Row(...);
  -- Notes
  --
  PROCEDURE Insert_Row(	row_id	IN OUT NOCOPY			VARCHAR2,
				category_code			VARCHAR2,
                        	category_number               	NUMBER,
				net_to_re_flag			VARCHAR2,
				target_entity_code		VARCHAR2,
				category_type_code		VARCHAR2,
				associated_object_id		NUMBER,
				org_output_code			VARCHAR2,
				support_multi_parents_flag	VARCHAR2,
				enabled_flag			VARCHAR2,
				specific_intercompany_id	NUMBER,
				category_name			VARCHAR2,
				description			VARCHAR2,
				creation_date			DATE,
				created_by			NUMBER,
				last_update_date		DATE,
				last_updated_by			NUMBER,
				last_update_login		NUMBER,
                        	object_version_number         	NUMBER);

  --
  -- Procedure
  --   Update_Row
  -- Purpose
  --   Updates a row in the gcs_categories_b table.
  -- Arguments
  --   category_code
  --   category_number
  --   net_to_re_flag
  --   target_entity_code
  --   category_type_code
  --   associated_object_id
  --   org_output_code
  --   support_multi_parents_flag
  --   enabled_flag
  --   specific_intercompany_id
  --   category_name
  --   description
  --   last_update_date
  --   last_udpated_by
  --   last_update_login
  -- Example
  --   GCS_CATEGORIES_PKG.Update_Row(...);
  -- Notes
  --
  PROCEDURE Update_Row(	row_id	IN OUT NOCOPY			VARCHAR2,
				category_code			VARCHAR2,
                        	category_number               	NUMBER,
				net_to_re_flag			VARCHAR2,
				target_entity_code		VARCHAR2,
				category_type_code		VARCHAR2,
				associated_object_id		NUMBER,
				org_output_code			VARCHAR2,
				support_multi_parents_flag	VARCHAR2,
				enabled_flag			VARCHAR2,
				specific_intercompany_id	NUMBER,
				category_name			VARCHAR2,
				description			VARCHAR2,
				creation_date			DATE,
				created_by			NUMBER,
				last_update_date		DATE,
				last_updated_by			NUMBER,
				last_update_login		NUMBER,
                        	object_version_number         	NUMBER);

  --
  -- Procedure
  --   Load_Row
  -- Purpose
  --   Loads a row into the gcs_categories_b table.
  -- Arguments
  --   category_code
  --   owner
  --   last_update_date
  --   category_number
  --   net_to_re_flag
  --   target_entity_code
  --   category_type_code
  --   associated_object_id
  --   org_output_code
  --   support_multi_parents_flag
  --   enabled_flag
  --   specific_intercompany_id
  --   category_name
  --   description

  -- Example
  --   GCS_CATEGORIES_PKG.Load_Row(...);
  -- Notes
  --
  PROCEDURE Load_Row(	category_code			VARCHAR2,
			owner				VARCHAR2,
			last_update_date		VARCHAR2,
                        custom_mode			VARCHAR2,
			category_number			NUMBER,
			net_to_re_flag			VARCHAR2,
			target_entity_code		VARCHAR2,
			category_type_code		VARCHAR2,
			associated_object_id		NUMBER,
			org_output_code			VARCHAR2,
			support_multi_parents_flag	VARCHAR2,
			enabled_flag			VARCHAR2,
			specific_intercompany_id	NUMBER,
			category_name			VARCHAR2,
			description			VARCHAR2,
                	object_version_number         	NUMBER);

  --
  -- Procedure
  --   Translate_Row
  -- Purpose
  --   Updates translated infromation for a row in the
  --   gcs_categories_tl table.
  -- Arguments
  --   category_code
  --   owner
  --   last_update_date
  --   category_name
  --   description
  -- Example
  --   GCS_CATEGORIES_PKG.Translate_Row(...);
  -- Notes
  --
  PROCEDURE Translate_Row(		category_code			VARCHAR2,
					owner				VARCHAR2,
					last_update_date		VARCHAR2,
					custom_mode			VARCHAR2,
					category_name			VARCHAR2,
					description			VARCHAR2);



  -- Procedure
   --   ADD_LANGUAGE
  -- Arguments

   -- Example
   --   GCS_CATEGORIES_PKG.ADD_LANGUAGE();
   -- Notes
   --

 PROCEDURE ADD_LANGUAGE ;


END GCS_CATEGORIES_PKG;

 

/
