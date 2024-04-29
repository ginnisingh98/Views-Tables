--------------------------------------------------------
--  DDL for Package CN_CREDIT_CONV_FCTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_CREDIT_CONV_FCTS_PKG" AUTHID CURRENT_USER as
/* $Header: cncrtcvs.pls 115.2 2001/10/29 17:06:17 pkm ship    $ */
  PROCEDURE Insert_Row
      ( x_credit_conv_fct_id  NUMBER			,
    	x_from_credit_type_id NUMBER			,
   	x_to_credit_type_id   NUMBER			,
        x_conversion_factor   NUMBER			,
    	x_start_date          DATE			,
    	x_end_date            DATE			,
    	x_attribute_category  VARCHAR2 := NULL		,
    	x_attribute1          VARCHAR2 := NULL		,
    	x_attribute2          VARCHAR2 := NULL		,
    	x_attribute3          VARCHAR2 := NULL		,
    	x_attribute4          VARCHAR2 := NULL		,
    	x_attribute5          VARCHAR2 := NULL		,
    	x_attribute6          VARCHAR2 := NULL		,
    	x_attribute7          VARCHAR2 := NULL		,
    	x_attribute8          VARCHAR2 := NULL		,
    	x_attribute9          VARCHAR2 := NULL		,
    	x_attribute10         VARCHAR2 := NULL		,
    	x_attribute11         VARCHAR2 := NULL		,
    	x_attribute12         VARCHAR2 := NULL		,
    	x_attribute13         VARCHAR2 := NULL		,
    	x_attribute14         VARCHAR2 := NULL		,
        x_attribute15         VARCHAR2 := NULL		,
        x_created_by	      NUMBER			,
        x_creation_date	      DATE			,
        x_last_update_login   NUMBER			,
        x_last_update_date    DATE			,
        x_last_updated_by     NUMBER
      );

  PROCEDURE Update_Row
    ( x_credit_conv_fct_id  NUMBER			,
      x_object_version      number,
    	x_from_credit_type_id NUMBER			,
   	x_to_credit_type_id   NUMBER			,
        x_conversion_factor   NUMBER			,
    	x_start_date          DATE			,
    	x_end_date            DATE			,
    	x_attribute_category  VARCHAR2 := NULL		,
    	x_attribute1          VARCHAR2 := NULL		,
    	x_attribute2          VARCHAR2 := NULL		,
    	x_attribute3          VARCHAR2 := NULL		,
    	x_attribute4          VARCHAR2 := NULL		,
    	x_attribute5          VARCHAR2 := NULL		,
    	x_attribute6          VARCHAR2 := NULL		,
    	x_attribute7          VARCHAR2 := NULL		,
    	x_attribute8          VARCHAR2 := NULL		,
    	x_attribute9          VARCHAR2 := NULL		,
    	x_attribute10         VARCHAR2 := NULL		,
    	x_attribute11         VARCHAR2 := NULL		,
    	x_attribute12         VARCHAR2 := NULL		,
    	x_attribute13         VARCHAR2 := NULL		,
    	x_attribute14         VARCHAR2 := NULL		,
        x_attribute15         VARCHAR2 := NULL		,
        x_created_by	      NUMBER			,
        x_creation_date	      DATE			,
        x_last_update_login   NUMBER			,
        x_last_update_date    DATE			,
        x_last_updated_by     NUMBER
      );

  PROCEDURE Lock_Row
      ( x_credit_conv_fct_id  NUMBER			,
    	x_from_credit_type_id NUMBER			,
   	x_to_credit_type_id   NUMBER			,
        x_conversion_factor   NUMBER			,
    	x_start_date          DATE			,
    	x_end_date            DATE			,
    	x_attribute_category  VARCHAR2 := NULL		,
    	x_attribute1          VARCHAR2 := NULL		,
    	x_attribute2          VARCHAR2 := NULL		,
    	x_attribute3          VARCHAR2 := NULL		,
    	x_attribute4          VARCHAR2 := NULL		,
    	x_attribute5          VARCHAR2 := NULL		,
    	x_attribute6          VARCHAR2 := NULL		,
    	x_attribute7          VARCHAR2 := NULL		,
    	x_attribute8          VARCHAR2 := NULL		,
    	x_attribute9          VARCHAR2 := NULL		,
    	x_attribute10         VARCHAR2 := NULL		,
    	x_attribute11         VARCHAR2 := NULL		,
    	x_attribute12         VARCHAR2 := NULL		,
    	x_attribute13         VARCHAR2 := NULL		,
    	x_attribute14         VARCHAR2 := NULL		,
        x_attribute15         VARCHAR2 := NULL		,
        x_created_by	      NUMBER			,
        x_creation_date	      DATE			,
        x_last_update_login   NUMBER			,
        x_last_update_date    DATE			,
        x_last_updated_by     NUMBER
      );

  PROCEDURE Delete_Row(x_credit_conv_fct_id  NUMBER);
end CN_CREDIT_CONV_FCTS_PKG;

 

/
