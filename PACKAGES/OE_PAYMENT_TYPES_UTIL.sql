--------------------------------------------------------
--  DDL for Package OE_PAYMENT_TYPES_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_PAYMENT_TYPES_UTIL" AUTHID CURRENT_USER as
/* $Header: OEXUPMTS.pls 115.2 2003/10/20 07:16:27 appldev ship $ */

  PROCEDURE Insert_Row(X_Rowid         		IN OUT NOCOPY  	VARCHAR2,
                       p_name                	VARCHAR2,
                       p_description            VARCHAR2,
                       p_payment_type_id        NUMBER := 0,
                       p_payment_type_code      VARCHAR2,
                       p_receipt_method_id      NUMBER,
                       p_start_date_active      DATE,
                       p_end_date_active        DATE,
                       p_enabled_flag           VARCHAR2,
                       p_defer_payment          VARCHAR2,
                       p_credit_check_flag      VARCHAR2,
                       p_org_id                	NUMBER  ,
                       p_Last_Update_Date       DATE,
                       p_Last_Updated_By        NUMBER  ,
                       p_Creation_Date          DATE ,
                       p_Created_By             NUMBER ,
                       p_Last_Update_Login      NUMBER,
                       p_program_application_id NUMBER,
                       p_program_id         	NUMBER,
                       p_request_id         	NUMBER,
                       p_program_update_date    DATE ,
                       p_Context 	        VARCHAR2,
                       p_Attribute1             VARCHAR2,
                       p_Attribute2             VARCHAR2,
                       p_Attribute3             VARCHAR2,
                       p_Attribute4             VARCHAR2,
                       p_Attribute5             VARCHAR2,
                       p_Attribute6             VARCHAR2,
                       p_Attribute7             VARCHAR2,
                       p_Attribute8             VARCHAR2,
                       p_Attribute9             VARCHAR2,
                       p_Attribute10            VARCHAR2,
                       p_Attribute11            VARCHAR2,
                       p_Attribute12            VARCHAR2,
                       p_Attribute13            VARCHAR2,
                       p_Attribute14            VARCHAR2,
                       p_Attribute15            VARCHAR2
                      );

PROCEDURE Lock_Row(    p_name                	VARCHAR2,
                       p_description            VARCHAR2,
                       p_payment_type_id        NUMBER,
                       p_payment_type_code      VARCHAR2,
                       p_receipt_method         VARCHAR2,
                       p_start_date_active      DATE,
                       p_end_date_active        DATE,
                       p_enabled_flag           VARCHAR2,
                       p_defer_payment          VARCHAR2,
                       p_credit_check_flag      VARCHAR2,
                       p_org_id                	NUMBER  ,
                       p_Context 	        VARCHAR2,
                       p_Attribute1             VARCHAR2,
                       p_Attribute2             VARCHAR2,
                       p_Attribute3             VARCHAR2,
                       p_Attribute4             VARCHAR2,
                       p_Attribute5             VARCHAR2,
                       p_Attribute6             VARCHAR2,
                       p_Attribute7             VARCHAR2,
                       p_Attribute8             VARCHAR2,
                       p_Attribute9             VARCHAR2,
                       p_Attribute10            VARCHAR2,
                       p_Attribute11            VARCHAR2,
                       p_Attribute12            VARCHAR2,
                       p_Attribute13            VARCHAR2,
                       p_Attribute14            VARCHAR2,
                       p_Attribute15            VARCHAR2
                      );

  PROCEDURE Update_Row(X_Rowid         		VARCHAR2,
                       p_name                	VARCHAR2,
                       p_description            VARCHAR2,
                       p_payment_type_id        NUMBER  ,
                       p_payment_type_code      VARCHAR2,
                       p_receipt_method_id      NUMBER  ,
                       p_start_date_active      DATE,
                       p_end_date_active        DATE,
                       p_enabled_flag           VARCHAR2,
                       p_defer_payment          VARCHAR2,
                       p_credit_check_flag      VARCHAR2,
                       p_org_id                	NUMBER  ,
                       p_Last_Update_Date       DATE,
                       p_Last_Updated_By        NUMBER  ,
                       p_Creation_Date          DATE ,
                       p_Created_By             NUMBER ,
                       p_Last_Update_Login      NUMBER,
                       p_program_application_id NUMBER,
                       p_program_id         	NUMBER,
                       p_request_id         	NUMBER,
                       p_program_update_date    DATE ,
                       p_Context 	        VARCHAR2,
                       p_Attribute1             VARCHAR2,
                       p_Attribute2             VARCHAR2,
                       p_Attribute3             VARCHAR2,
                       p_Attribute4             VARCHAR2,
                       p_Attribute5             VARCHAR2,
                       p_Attribute6             VARCHAR2,
                       p_Attribute7             VARCHAR2,
                       p_Attribute8             VARCHAR2,
                       p_Attribute9             VARCHAR2,
                       p_Attribute10            VARCHAR2,
                       p_Attribute11            VARCHAR2,
                       p_Attribute12            VARCHAR2,
                       p_Attribute13            VARCHAR2,
                       p_Attribute14            VARCHAR2,
                       p_Attribute15            VARCHAR2
                      );

  PROCEDURE Delete_Row(p_payment_type_id IN NUMBER,
                       p_payment_type_code IN VARCHAR2,
                       p_org_id in NUMBER);

  PROCEDURE Translate_Row(p_payment_type_id in VARCHAR2,
                          p_payment_type_code in VARCHAR2,
                          p_name in VARCHAR2,
                          p_description in VARCHAR2,
                          p_owner in varchar2,
                          p_org_id in varchar2);

  PROCEDURE LOAD_ROW( x_payment_type_id  in NUMBER,
                      x_payment_type_code in VARCHAR2,
                      x_request_id        in NUMBER,
                      x_start_date_active in VARCHAR2,
                      x_end_date_active   in VARCHAR2,
                      x_enabled_flag      in VARCHAR2,
                      x_defer_processing_flag in VARCHAR2,
                      x_credit_check_flag in VARCHAR2,
                      x_receipt_method_id in NUMBER,
                      x_context           in VARCHAR2,
                      x_attribute1        in VARCHAR2,
                      x_attribute2        in VARCHAR2,
                      x_attribute3        in VARCHAR2,
                      x_attribute4        in VARCHAR2,
                      x_attribute5        in VARCHAR2,
                      x_attribute6        in VARCHAR2,
                      x_attribute7        in VARCHAR2,
                      x_attribute8        in VARCHAR2,
                      x_attribute9        in VARCHAR2,
                      x_attribute10        in VARCHAR2,
                      x_attribute11        in VARCHAR2,
                      x_attribute12        in VARCHAR2,
                      x_attribute13        in VARCHAR2,
                      x_attribute14        in VARCHAR2,
                      x_attribute15        in VARCHAR2,
                      x_name               in VARCHAR2,
                      x_description        in VARCHAR2,
                      x_last_update_date   in VARCHAR2,
                      x_last_updated_by    in NUMBER,
                      x_last_update_login  in NUMBER,
                      x_owner              in VARCHAR2,
                      x_org_id             in NUMBER);

Procedure Copy_Payment_Types(p_from_org_id in number,
                             p_to_org_id in number);

procedure ADD_LANGUAGE;

END OE_PAYMENT_TYPES_UTIL;

 

/
