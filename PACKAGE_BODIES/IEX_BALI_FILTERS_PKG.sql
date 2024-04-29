--------------------------------------------------------
--  DDL for Package Body IEX_BALI_FILTERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_BALI_FILTERS_PKG" AS
/* $Header: iextbflb.pls 120.2 2004/05/14 15:17:46 jsanju noship $ */

PG_DEBUG NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

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
    x_last_update_login       in number)  IS
	CURSOR C IS SELECT ROWID FROM IEX_BALI_FILTERS
		WHERE BALI_FILTER_ID = x_BALI_FILTER_ID;

BEGIN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage ('** Start of Procedure =>'||
               'IEX_BALI_FILTERS_PKG.INSERT_ROW ** ');
    END IF;
	INSERT INTO IEX_BALI_FILTERS
	(bali_filter_id,
     bali_filter_name,
     bali_datasource,
     bali_user_id,
     bali_col_alias,
     bali_col_data_type,
     bali_col_label_text,
     bali_col_condition_code,
     bali_col_condition_value,
     bali_col_value,
     right_parenthesis_code,
     left_parenthesis_code,
     boolean_operator_code
    ,object_version_number
	,request_id
    ,program_application_id
	,program_id
	,program_update_date
	,attribute_category
	,attribute1
	,attribute2
	,attribute3
	,attribute4
	,attribute5
	,attribute6
	,attribute7
	,attribute8
	,attribute9
	,attribute10
	,attribute11
	,attribute12
	,attribute13
	,attribute14
	,attribute15
	,created_by
	,creation_date
	,last_updated_by
	,last_update_date
	,last_update_login
    )
    VALUES (
     x_bali_filter_id
    ,x_bali_filter_name
    ,x_bali_datasource
    ,x_bali_user_id
    ,x_bali_col_alias
    ,x_bali_col_data_type
    ,x_bali_col_label_text
    ,x_bali_col_condition_code
    ,x_bali_col_condition_value
    ,x_bali_col_value
    ,decode( x_right_parenthesis_code, FND_API.G_MISS_CHAR, NULL, x_right_parenthesis_code)
    ,decode( x_left_parenthesis_code, FND_API.G_MISS_CHAR, NULL, x_left_parenthesis_code)
    ,decode( x_boolean_operator_code, FND_API.G_MISS_CHAR, NULL, x_boolean_operator_code)
 	,x_object_version_number
    ,decode( x_REQUEST_ID, FND_API.G_MISS_NUM, NULL, x_REQUEST_ID),
     decode( x_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, NULL, x_PROGRAM_APPLICATION_ID),
     decode( x_PROGRAM_ID, FND_API.G_MISS_NUM, NULL, x_PROGRAM_ID),
     decode( x_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), x_PROGRAM_UPDATE_DATE),
     decode( x_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE_CATEGORY),
     decode( x_ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE1),
     decode( x_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE2),
     decode( x_ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE3),
     decode( x_ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE4),
     decode( x_ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE5),
     decode( x_ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE6),
     decode( x_ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE7),
     decode( x_ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE8),
     decode( x_ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE9),
     decode( x_ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE10),
     decode( x_ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE11),
     decode( x_ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE12),
     decode( x_ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE13),
     decode( x_ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE14),
     decode( x_ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE15)
    ,x_CREATED_BY
    ,x_CREATION_DATE
    ,x_LAST_UPDATED_BY
    ,x_LAST_UPDATE_DATE
    ,decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, x_LAST_UPDATE_LOGIN)
    );

	OPEN C;
	FETCH C INTO x_rowid;
	IF (C%NOTFOUND) THEN
		CLOSE C;
		RAISE NO_DATA_FOUND;
	END IF;
	CLOSE C;
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage ('** End of Procedure =>'||
             'IEX_BALI_FILTERS_PKG.INSERT_ROW *** ');
   END IF;
END Insert_Row;

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
    x_last_update_login       in number)
  IS
BEGIN
	UPDATE IEX_BALI_FILTERS SET
	    BALI_FILTER_ID           = decode( x_BALI_FILTER_ID, FND_API.G_MISS_NUM, NULL,
                                         NULL, BALI_FILTER_ID, x_BALI_FILTER_ID)
        ,bali_filter_name =decode( x_bali_filter_name, fnd_api.g_miss_char,null,
                                    null,bali_filter_name, x_bali_filter_name)
        ,bali_datasource=decode( x_bali_datasource, fnd_api.g_miss_char,null,
                                    null,bali_datasource, x_bali_datasource)
        ,bali_user_id  = decode( x_bali_user_id, FND_API.G_MISS_NUM, NULL,
                                         NULL, bali_user_id, x_bali_user_id)
        ,bali_col_alias=decode( x_bali_col_alias, fnd_api.g_miss_char,null,
                                    null,bali_col_alias, x_bali_col_alias)
        ,bali_col_data_type=decode( x_bali_col_data_type, fnd_api.g_miss_char,null,
                                    null,bali_col_data_type, x_bali_col_data_type)
        ,bali_col_label_text=decode( x_bali_col_label_text, fnd_api.g_miss_char,null,
                                    null,bali_col_label_text, x_bali_col_label_text)
        ,bali_col_condition_code=decode( x_bali_col_condition_code, fnd_api.g_miss_char,null,
                                    null,bali_col_condition_code, x_bali_col_condition_code)
        ,bali_col_condition_value=decode( x_bali_col_condition_value, fnd_api.g_miss_char,null,
                                    null,bali_col_condition_value, x_bali_col_condition_value)
        ,bali_col_value=decode( x_bali_col_value, fnd_api.g_miss_char,null,
                                    null,bali_col_value, x_bali_col_value)
        ,right_parenthesis_code = decode( x_right_parenthesis_code, fnd_api.g_miss_char,null,
                                    null,right_parenthesis_code, x_right_parenthesis_code)
        ,left_parenthesis_code  = decode( x_left_parenthesis_code, fnd_api.g_miss_char,null,
                                    null,left_parenthesis_code, x_left_parenthesis_code)
        ,boolean_operator_code    = decode( x_boolean_operator_code, fnd_api.g_miss_char,null,
                                    null,boolean_operator_code, x_boolean_operator_code)

		,object_version_number = decode( x_object_version_number, fnd_api.g_miss_num,null,
                                       null,object_version_number, x_object_version_number)

        ,request_id = decode( x_request_id, fnd_api.g_miss_num,null,
                               null,request_id, x_request_id),
        program_application_id = decode( x_program_application_id, fnd_api.g_miss_num,null,
                           null,program_application_id,   x_program_application_id),
        program_id = decode( x_program_id, fnd_api.g_miss_num,null,
                                 null,program_id, x_program_id),
        program_update_date = decode( x_program_update_date, fnd_api.g_miss_date,null,
                              null,program_update_date, x_program_update_date),
              attribute_category = decode( x_attribute_category, fnd_api.g_miss_char,null,
                                           null,attribute_category, x_attribute_category),
              attribute1 = decode( x_attribute1, fnd_api.g_miss_char,null,
                                    null,attribute1, x_attribute1),
              attribute2 = decode( x_attribute2, fnd_api.g_miss_char,null,
                                      null,attribute2, x_attribute2),
              attribute3 = decode( x_attribute3, fnd_api.g_miss_char, null,
                                     null,attribute3, x_attribute3),
              attribute4 = decode( x_attribute4, fnd_api.g_miss_char,null,
                                      null,attribute4, x_attribute4),
              attribute5 = decode( x_attribute5, fnd_api.g_miss_char,null,
                                      null,attribute5, x_attribute5),

              attribute6 = decode( x_attribute6, fnd_api.g_miss_char,null,
                                    null,attribute6, x_attribute6),
              attribute7 = decode( x_attribute7, fnd_api.g_miss_char,null,
                                      null,attribute7, x_attribute7),
              attribute8 = decode( x_attribute8, fnd_api.g_miss_char, null,
                                     null,attribute8, x_attribute8),
              attribute9= decode( x_attribute9, fnd_api.g_miss_char,null,
                                      null,attribute9, x_attribute9),
              attribute10 = decode( x_attribute10, fnd_api.g_miss_char,null,
                                      null,attribute10, x_attribute10),

              attribute11 = decode( x_attribute11, fnd_api.g_miss_char,null,
                                      null,attribute11, x_attribute11),

               attribute12 = decode( x_attribute10, fnd_api.g_miss_char,null,
                                      null,attribute12, x_attribute12),

               attribute13 = decode( x_attribute10, fnd_api.g_miss_char,null,
                                      null,attribute13, x_attribute13),
              attribute14 = decode( x_attribute10, fnd_api.g_miss_char,null,
                                      null,attribute14, x_attribute14),
              attribute15 = decode( x_attribute15, fnd_api.g_miss_char,null,
                                      null,attribute15, x_attribute15),

              last_updated_by = decode( x_last_updated_by, fnd_api.g_miss_num,null,
                                       null,last_updated_by, x_last_updated_by),
              last_update_date = decode( x_last_update_date, fnd_api.g_miss_date,null,
                                      null,last_update_date, x_last_update_date),
              last_update_login = decode( x_last_update_login, fnd_api.g_miss_num,null,
                                     null,last_update_login, x_last_update_login)

	 WHERE bali_filter_id = x_bali_filter_ID;

	if (sql%notfound) then
		raise no_data_found;
	end if;
END Update_Row;

/* Delete_Row procedure */
 PROCEDURE Delete_Row(x_bali_filter_id IN NUMBER)
  IS
BEGIN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     IEX_DEBUG_PUB.LogMessage ('*** Start of Procedure =>IEX_BALI_FILTERS_PKG.DELETE_ROW *** ');
     END IF;
      delete from IEX_BALI_FILTERS
      where  bali_filter_id = x_bali_filter_id;

      if (sql%notfound) then
         raise no_data_found;
      end if;

END Delete_Row;

procedure LOCK_ROW (
  x_bali_filter_id in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select OBJECT_VERSION_NUMBER
    from IEX_BALI_FILTERS
    where bali_filter_id  = X_bali_filter_id
    and OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER
    for update of bali_filter_id  nowait;
  recinfo c%rowtype;


begin
 IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
 IEX_DEBUG_PUB.LogMessage ('*** Start of Procedure =>IEX_BALI_FILTERS_PKG.LOCK_ROW ** ');
 END IF;
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;

  close c;

  if recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
IEX_DEBUG_PUB.LogMessage ('********* End of Procedure =>IEX_BALI_FILTERS_PKG.LOCK_ROW ******** ');
END IF;
end LOCK_ROW;

END IEX_BALI_FILTERS_PKG;


/
