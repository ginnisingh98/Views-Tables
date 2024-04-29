--------------------------------------------------------
--  DDL for Package IEX_BALI_FILTERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_BALI_FILTERS_PKG" AUTHID CURRENT_USER as
/* $Header: iextbfls.pls 120.2 2004/05/14 15:17:40 jsanju noship $ */

PROCEDURE Insert_Row
    (x_rowid          	        in out nocopy varchar2
	,x_bali_filter_id	        in number
    ,x_bali_filter_name         in varchar2
    ,x_bali_datasource          in varchar2
    ,x_bali_user_id             in number
    ,x_bali_col_alias           in varchar2
    ,x_bali_col_data_type       in varchar2
    ,x_bali_col_label_text      in varchar2
    ,x_bali_col_condition_code  in varchar2
    ,x_bali_col_condition_value in varchar2
    ,x_bali_col_value           in varchar2
    ,x_right_parenthesis_code   in varchar2
    ,x_left_parenthesis_code    in varchar2
    ,x_boolean_operator_code    in varchar2
	,x_object_version_number  in number
    ,x_request_id             in  number,
    x_program_application_id  in  number,
    x_program_id              in  number,
    x_program_update_date     in  date,
    x_attribute_category      in varchar2,
    x_attribute1              in varchar2,
    x_attribute2              in varchar2,
    x_attribute3              in varchar2,
    x_attribute4              in varchar2,
    x_attribute5              in varchar2,
    x_attribute6              in varchar2,
    x_attribute7              in varchar2,
    x_attribute8              in varchar2,
    x_attribute9              in varchar2,
    x_attribute10             in varchar2,
    x_attribute11             in varchar2,
    x_attribute12             in varchar2,
    x_attribute13             in varchar2,
    x_attribute14             in varchar2,
    x_attribute15             in varchar2,
    x_creation_date           in date,
    x_created_by              in number,
    x_last_update_date        in date,
    x_last_updated_by         in number,
    x_last_update_login       in number);


/* Update_Row procedure */
PROCEDURE Update_Row(
	 x_bali_filter_id	        in number
    ,x_bali_filter_name         in varchar2
    ,x_bali_datasource          in varchar2
    ,x_bali_user_id             in number
    ,x_bali_col_alias           in varchar2
    ,x_bali_col_data_type       in varchar2
    ,x_bali_col_label_text      in varchar2
    ,x_bali_col_condition_code  in varchar2
    ,x_bali_col_condition_value in varchar2
    ,x_bali_col_value           in varchar2
    ,x_right_parenthesis_code   in varchar2
    ,x_left_parenthesis_code    in varchar2
    ,x_boolean_operator_code    in varchar2
	,x_object_version_number  in number
    ,x_request_id             in  number,
    x_program_application_id  in  number,
    x_program_id              in  number,
    x_program_update_date     in  date,
    x_attribute_category      in varchar2,
    x_attribute1              in varchar2,
    x_attribute2              in varchar2,
    x_attribute3              in varchar2,
    x_attribute4              in varchar2,
    x_attribute5              in varchar2,
    x_attribute6              in varchar2,
    x_attribute7              in varchar2,
    x_attribute8              in varchar2,
    x_attribute9              in varchar2,
    x_attribute10             in varchar2,
    x_attribute11             in varchar2,
    x_attribute12             in varchar2,
    x_attribute13             in varchar2,
    x_attribute14             in varchar2,
    x_attribute15             in varchar2,
    x_last_update_date        in date,
    x_last_updated_by         in number,
    x_last_update_login       in number);

/* Delete_Row procedure */
 PROCEDURE Delete_Row(X_BALI_FILTER_ID IN NUMBER);

procedure LOCK_ROW (
  X_BALI_FILTER_ID    in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER);


END IEX_BALI_FILTERS_PKG ;

 

/
