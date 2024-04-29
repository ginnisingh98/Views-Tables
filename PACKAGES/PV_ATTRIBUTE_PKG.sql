--------------------------------------------------------
--  DDL for Package PV_ATTRIBUTE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_ATTRIBUTE_PKG" AUTHID CURRENT_USER AS
/* $Header: pvxtatss.pls 120.1 2005/06/30 13:07:51 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_ATTRIBUTE_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          px_attribute_id	   IN OUT NOCOPY NUMBER,
          p_last_update_date		  DATE,
          p_last_updated_by		  NUMBER,
          p_creation_date		  DATE,
          p_created_by			  NUMBER,
          p_last_update_login		  NUMBER,
          px_object_version_number IN OUT NOCOPY NUMBER,
          --p_security_group_id		  NUMBER,
          p_enabled_flag		  VARCHAR2,
          p_attribute_type		  VARCHAR2,
          p_attribute_category		  VARCHAR2,
          p_seeded_flag			  VARCHAR2,
          p_lov_function_name		  VARCHAR2,
          p_return_type			  VARCHAR2,
          p_max_value_flag		  VARCHAR2,
  	  p_name			  VARCHAR2,
	  p_description			  VARCHAR2,
	  p_short_name			  VARCHAR2,

	  --new columns added

	  p_display_style		  VARCHAR2   := FND_API.G_MISS_CHAR,
          p_character_width		  NUMBER     := FND_API.G_MISS_NUM,
          p_decimal_points		  NUMBER     := FND_API.G_MISS_NUM,
          p_no_of_lines			  NUMBER     := FND_API.G_MISS_NUM,
          p_expose_to_partner_flag	  VARCHAR2   := FND_API.G_MISS_CHAR,
          p_value_extn_return_type	  VARCHAR2   := FND_API.G_MISS_CHAR,
          p_enable_matching_flag	  VARCHAR2   := FND_API.G_MISS_CHAR,
          p_performance_flag    	  VARCHAR2   := FND_API.G_MISS_CHAR,
          p_additive_flag    		  VARCHAR2   := FND_API.G_MISS_CHAR,
	  p_sequence_number		  NUMBER     := FND_API.G_MISS_NUM
	  );

PROCEDURE Update_Row(
          p_attribute_id	          NUMBER,
          p_last_update_date		  DATE,
          p_last_updated_by		  NUMBER,
	  --p_creation_date		  DATE,
          --p_created_by		  NUMBER,
          p_last_update_login		  NUMBER,
          p_object_version_number	  NUMBER,
          --p_security_group_id           NUMBER,
          p_enabled_flag                  VARCHAR2,
          p_attribute_type		  VARCHAR2,
          p_attribute_category		  VARCHAR2,
          p_seeded_flag			  VARCHAR2,
          p_lov_function_name		  VARCHAR2,
          p_return_type			  VARCHAR2,
          p_max_value_flag		  VARCHAR2,
	  p_name			  VARCHAR2,
	  p_description			  VARCHAR2,
	  p_short_name			  VARCHAR2,

	   --new columns added

	  p_display_style			  VARCHAR2   := FND_API.G_MISS_CHAR,
          p_character_width		  NUMBER     := FND_API.G_MISS_NUM,
          p_decimal_points		  NUMBER     := FND_API.G_MISS_NUM,
          p_no_of_lines			  NUMBER     := FND_API.G_MISS_NUM,
          p_expose_to_partner_flag	  VARCHAR2   := FND_API.G_MISS_CHAR,
          p_value_extn_return_type	  VARCHAR2   := FND_API.G_MISS_CHAR,
          p_enable_matching_flag	  VARCHAR2   := FND_API.G_MISS_CHAR,
          p_performance_flag    	  VARCHAR2   := FND_API.G_MISS_CHAR,
          p_additive_flag    		  VARCHAR2   := FND_API.G_MISS_CHAR,
	  p_sequence_number		  NUMBER     := FND_API.G_MISS_NUM
	  );

PROCEDURE Update_Row_Seed(
          p_attribute_id	          NUMBER,
          p_last_update_date		  DATE,
          p_last_updated_by		  NUMBER,
	  --p_creation_date		  DATE,
          --p_created_by		  NUMBER,
          p_last_update_login		  NUMBER,
          p_object_version_number	  NUMBER,
          --p_security_group_id           NUMBER,
          p_enabled_flag                  VARCHAR2,
          p_attribute_type		  VARCHAR2,
          p_attribute_category		  VARCHAR2,
          p_seeded_flag			  VARCHAR2,
          p_lov_function_name		  VARCHAR2,
          p_return_type			  VARCHAR2,
          p_max_value_flag		  VARCHAR2,
	  p_name			  VARCHAR2,
	  p_description			  VARCHAR2,
	  p_short_name			  VARCHAR2,

	   --new columns added

	  p_display_style		  VARCHAR2   := FND_API.G_MISS_CHAR,
          p_character_width		  NUMBER     := FND_API.G_MISS_NUM,
          p_decimal_points		  NUMBER     := FND_API.G_MISS_NUM,
          p_no_of_lines			  NUMBER     := FND_API.G_MISS_NUM,
          p_expose_to_partner_flag	  VARCHAR2   := FND_API.G_MISS_CHAR,
          p_value_extn_return_type	  VARCHAR2   := FND_API.G_MISS_CHAR,
          p_enable_matching_flag	  VARCHAR2   := FND_API.G_MISS_CHAR,
          p_performance_flag    	  VARCHAR2   := FND_API.G_MISS_CHAR,
          p_additive_flag    		  VARCHAR2   := FND_API.G_MISS_CHAR,
	  p_sequence_number		  NUMBER     := FND_API.G_MISS_NUM
	  );

PROCEDURE Delete_Row(
          p_ATTRIBUTE_ID                  NUMBER
	  );

PROCEDURE Lock_Row(
          p_attribute_id		  NUMBER,
          p_last_update_date		  DATE,
          p_last_updated_by		  NUMBER,
          p_creation_date		  DATE,
          p_created_by			  NUMBER,
          p_last_update_login		  NUMBER,
          p_object_version_number	  NUMBER,
          --p_security_group_id		  NUMBER,
          p_enabled_flag		  VARCHAR2,
          p_attribute_type		  VARCHAR2,
          p_attribute_category		  VARCHAR2,
          p_seeded_flag			  VARCHAR2,
          p_lov_function_name		  VARCHAR2,
          p_return_type			  VARCHAR2,
          p_max_value_flag		  VARCHAR2,

	   --new columns added

	  p_display_style		  VARCHAR2   := FND_API.G_MISS_CHAR,
          p_character_width		  NUMBER     := FND_API.G_MISS_NUM,
          p_decimal_points		  NUMBER     := FND_API.G_MISS_NUM,
          p_no_of_lines			  NUMBER     := FND_API.G_MISS_NUM,
          p_expose_to_partner_flag	  VARCHAR2   := FND_API.G_MISS_CHAR,
          p_value_extn_return_type	  VARCHAR2   := FND_API.G_MISS_CHAR,
          p_enable_matching_flag	  VARCHAR2   := FND_API.G_MISS_CHAR,
          p_performance_flag    	  VARCHAR2   := FND_API.G_MISS_CHAR,
          p_additive_flag    		  VARCHAR2   := FND_API.G_MISS_CHAR,
	  p_sequence_number		  NUMBER     := FND_API.G_MISS_NUM
	  );


procedure ADD_LANGUAGE;


procedure TRANSLATE_ROW(
 p_attribute_id           in NUMBER,
 p_name                   in VARCHAR2,
 p_description            in VARCHAR2,
 p_owner                  in VARCHAR2
);

procedure LOAD_ROW(
          p_attribute_id		IN NUMBER,
          --p_creation_date		IN DATE,
          --p_created_by		IN NUMBER,
          --p_security_group_id		IN NUMBER,
          p_enabled_flag		IN VARCHAR2,
          p_attribute_type		IN VARCHAR2,
          p_attribute_category		IN VARCHAR2,
          p_seeded_flag			IN VARCHAR2,
          p_lov_function_name		IN VARCHAR2,
          p_return_type			IN VARCHAR2,
          p_max_value_flag		IN VARCHAR2,
	  p_name			IN VARCHAR2,
	  p_description			IN VARCHAR2,
	  p_short_name			IN VARCHAR2,
          p_owner			IN VARCHAR2,

	   --new columns added

	  p_display_style		IN VARCHAR2   := FND_API.G_MISS_CHAR,
          p_character_width		IN NUMBER     := FND_API.G_MISS_NUM,
          p_decimal_points		IN NUMBER     := FND_API.G_MISS_NUM,
          p_no_of_lines			IN NUMBER     := FND_API.G_MISS_NUM,
          p_expose_to_partner_flag	IN VARCHAR2   := FND_API.G_MISS_CHAR,
          p_value_extn_return_type	IN VARCHAR2   := FND_API.G_MISS_CHAR,
          p_enable_matching_flag	  VARCHAR2   := FND_API.G_MISS_CHAR,
          p_performance_flag    	  VARCHAR2   := FND_API.G_MISS_CHAR,
          p_additive_flag    		  VARCHAR2   := FND_API.G_MISS_CHAR,
	  p_sequence_number		  NUMBER     := FND_API.G_MISS_NUM
);

procedure LOAD_SEED_ROW(
          p_upload_mode                 IN VARCHAR2,
          p_attribute_id		IN NUMBER,
          p_enabled_flag		IN VARCHAR2,
          p_attribute_type		IN VARCHAR2,
          p_attribute_category		IN VARCHAR2,
          p_seeded_flag			IN VARCHAR2,
          p_lov_function_name		IN VARCHAR2,
          p_return_type			IN VARCHAR2,
          p_max_value_flag		IN VARCHAR2,
	  p_name			IN VARCHAR2,
	  p_description			IN VARCHAR2,
	  p_short_name			IN VARCHAR2,
          p_owner			IN VARCHAR2,
	  p_display_style		IN VARCHAR2    := FND_API.G_MISS_CHAR,
          p_character_width		IN NUMBER      := FND_API.G_MISS_NUM,
          p_decimal_points		IN NUMBER      := FND_API.G_MISS_NUM,
          p_no_of_lines			IN NUMBER      := FND_API.G_MISS_NUM,
          p_expose_to_partner_flag	IN VARCHAR2    := FND_API.G_MISS_CHAR,
          p_value_extn_return_type	IN VARCHAR2    := FND_API.G_MISS_CHAR,
          p_enable_matching_flag	IN VARCHAR2    := FND_API.G_MISS_CHAR,
          p_performance_flag    	IN VARCHAR2    := FND_API.G_MISS_CHAR,
          p_additive_flag    		IN VARCHAR2    := FND_API.G_MISS_CHAR,
	  p_sequence_number		IN NUMBER      := FND_API.G_MISS_NUM
);

END PV_ATTRIBUTE_PKG;

 

/
