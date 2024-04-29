--------------------------------------------------------
--  DDL for Package JG_GLOBE_FLEX_VAL_SHARED
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_GLOBE_FLEX_VAL_SHARED" AUTHID CURRENT_USER AS
/* $Header: jggdfvss.pls 115.3 2002/05/17 11:33:52 pkm ship   $ */

--
-- Record type is introduced to handle global_attributes
--

TYPE GdfRec IS RECORD
     (global_attribute_category   VARCHAR2(30)    DEFAULT NULL,
      global_attribute1           VARCHAR2(150)   DEFAULT NULL,
      global_attribute2           VARCHAR2(150)   DEFAULT NULL,
      global_attribute3           VARCHAR2(150)   DEFAULT NULL,
      global_attribute4           VARCHAR2(150)   DEFAULT NULL,
      global_attribute5           VARCHAR2(150)   DEFAULT NULL,
      global_attribute6           VARCHAR2(150)   DEFAULT NULL,
      global_attribute7           VARCHAR2(150)   DEFAULT NULL,
      global_attribute8           VARCHAR2(150)   DEFAULT NULL,
      global_attribute9           VARCHAR2(150)   DEFAULT NULL,
      global_attribute10          VARCHAR2(150)   DEFAULT NULL,
      global_attribute11          VARCHAR2(150)   DEFAULT NULL,
      global_attribute12          VARCHAR2(150)   DEFAULT NULL,
      global_attribute13          VARCHAR2(150)   DEFAULT NULL,
      global_attribute14          VARCHAR2(150)   DEFAULT NULL,
      global_attribute15          VARCHAR2(150)   DEFAULT NULL,
      global_attribute16          VARCHAR2(150)   DEFAULT NULL,
      global_attribute17          VARCHAR2(150)   DEFAULT NULL,
      global_attribute18          VARCHAR2(150)   DEFAULT NULL,
      global_attribute19          VARCHAR2(150)   DEFAULT NULL,
      global_attribute20          VARCHAR2(150)   DEFAULT NULL
      );


TYPE GenRec IS RECORD
     (core_prod_arg1              VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg2              VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg3              VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg4              VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg5              VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg6              VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg7              VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg8              VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg9              VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg10             VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg11             VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg12             VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg13             VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg14             VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg15             VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg16             VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg17             VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg18             VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg19             VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg20             VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg21             VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg22             VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg23             VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg24             VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg25             VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg26             VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg27             VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg28             VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg29             VARCHAR2(150)   DEFAULT NULL,
      core_prod_arg30             VARCHAR2(150)   DEFAULT NULL
     );

PROCEDURE insert_rejections(
	p_parent_table			IN	VARCHAR2,
	p_parent_id			IN	NUMBER,
	p_reject_code			IN	VARCHAR2,
	p_last_updated_by		IN	NUMBER,
	p_last_update_login		IN	NUMBER,
	p_calling_sequence   		IN    	VARCHAR2);

PROCEDURE update_ra_customers_interface(
        p_code                          IN VARCHAR2,
        p_row_id                        IN VARCHAR2,
        p_current_status                IN VARCHAR2);

PROCEDURE update_interface_status(
        p_rowid                         IN VARCHAR2,
        p_table_name                    IN VARCHAR2,
        p_code                          IN VARCHAR2,
        p_current_status                IN VARCHAR2);

FUNCTION check_format(
        p_value                         IN VARCHAR2,
        p_format_type                   IN VARCHAR2,
        p_maximum_size                  IN NUMBER,
        p_precision                     IN NUMBER,
        p_alphanumeric                  IN VARCHAR2,
        p_uppercase_only                IN VARCHAR2,
        p_right_justify                 IN VARCHAR2,
        p_min_value                     IN VARCHAR2,
        p_max_value                     IN VARCHAR2) RETURN BOOLEAN;

END jg_globe_flex_val_shared;

 

/
