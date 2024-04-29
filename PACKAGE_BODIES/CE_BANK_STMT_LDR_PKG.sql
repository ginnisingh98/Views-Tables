--------------------------------------------------------
--  DDL for Package Body CE_BANK_STMT_LDR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_BANK_STMT_LDR_PKG" AS
/*$Header: cexsldrb.pls 120.3.12010000.2 2008/08/10 14:28:33 csutaria ship $ 	*/

PROCEDURE Map_Insert_Row(
 X_ROW_ID			IN OUT NOCOPY      VARCHAR2,
 X_MAP_ID                       IN OUT NOCOPY      NUMBER,
 X_FORMAT_NAME                              VARCHAR2,
 X_DESCRIPTION				    VARCHAR2,
 X_FORMAT_TYPE                              VARCHAR2,
 X_CONTROL_FILE_NAME                        VARCHAR2,
 X_ENABLED                                  VARCHAR2,
 X_PRECISION				    NUMBER,
 X_DATE_FORMAT				    VARCHAR2,
 X_TIMESTAMP_FORMAT			    VARCHAR2,
 X_CREATED_BY                               NUMBER,
 X_CREATION_DATE                            DATE,
 X_LAST_UPDATED_BY                          NUMBER,
 X_LAST_UPDATE_DATE                         DATE,
 X_LAST_UPDATE_LOGIN                        NUMBER,
 X_ATTRIBUTE_CATEGORY                       VARCHAR2,
 X_ATTRIBUTE1                               VARCHAR2,
 X_ATTRIBUTE2                               VARCHAR2,
 X_ATTRIBUTE3                               VARCHAR2,
 X_ATTRIBUTE4                               VARCHAR2,
 X_ATTRIBUTE5                               VARCHAR2,
 X_ATTRIBUTE6                               VARCHAR2,
 X_ATTRIBUTE7                               VARCHAR2,
 X_ATTRIBUTE8                               VARCHAR2,
 X_ATTRIBUTE9                               VARCHAR2,
 X_ATTRIBUTE10                              VARCHAR2,
 X_ATTRIBUTE11                              VARCHAR2,
 X_ATTRIBUTE12                              VARCHAR2,
 X_ATTRIBUTE13                              VARCHAR2,
 X_ATTRIBUTE14                              VARCHAR2,
 X_ATTRIBUTE15                              VARCHAR2) IS

 CURSOR C_map_id IS
   SELECT 	CE_BANK_STMT_INT_MAP_S.nextval
   FROM		sys.dual;

 CURSOR C_row_id IS
   SELECT 	rowid
   FROM 	ce_bank_stmt_int_map
   WHERE 	map_id = TO_NUMBER(X_MAP_ID);
BEGIN
  OPEN C_map_id;
  FETCH C_map_id
  INTO 	X_MAP_ID;
  CLOSE C_map_id;

  INSERT INTO ce_bank_stmt_int_map(
	MAP_ID,
   	FORMAT_NAME,
	DESCRIPTION,
   	FORMAT_TYPE,
   	CONTROL_FILE_NAME,
	ENABLED,
	PRECISION,
 	DATE_FORMAT,
 	TIMESTAMP_FORMAT,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN,
	ATTRIBUTE_CATEGORY,
	ATTRIBUTE1,
	ATTRIBUTE2,
	ATTRIBUTE3,
	ATTRIBUTE4,
	ATTRIBUTE5,
	ATTRIBUTE6,
	ATTRIBUTE7,
	ATTRIBUTE8,
	ATTRIBUTE9,
	ATTRIBUTE10,
	ATTRIBUTE11,
	ATTRIBUTE12,
	ATTRIBUTE13,
	ATTRIBUTE14,
	ATTRIBUTE15)
  VALUES(
  	X_MAP_ID,
   	X_FORMAT_NAME,
	X_DESCRIPTION,
   	X_FORMAT_TYPE,
   	X_CONTROL_FILE_NAME,
	X_ENABLED,
	X_PRECISION,
	X_DATE_FORMAT,
 	X_TIMESTAMP_FORMAT,
	X_CREATED_BY,
	X_CREATION_DATE,
	X_LAST_UPDATED_BY,
	X_LAST_UPDATE_DATE,
	X_LAST_UPDATE_LOGIN,
	X_ATTRIBUTE_CATEGORY,
	X_ATTRIBUTE1,
	X_ATTRIBUTE2,
	X_ATTRIBUTE3,
	X_ATTRIBUTE4,
	X_ATTRIBUTE5,
	X_ATTRIBUTE6,
	X_ATTRIBUTE7,
	X_ATTRIBUTE8,
	X_ATTRIBUTE9,
	X_ATTRIBUTE10,
	X_ATTRIBUTE11,
	X_ATTRIBUTE12,
	X_ATTRIBUTE13,
	X_ATTRIBUTE14,
	X_ATTRIBUTE15);

  OPEN C_row_id;
  FETCH C_row_id INTO X_row_id;
  if (C_row_id%NOTFOUND) then
    CLOSE C_row_id;
    Raise NO_DATA_FOUND;
  end if;
  CLOSE C_row_id;

END Map_Insert_Row;

PROCEDURE Map_Update_Row(
 X_ROW_ID				    VARCHAR2,
 X_MAP_ID                                   NUMBER,
 X_FORMAT_NAME                              VARCHAR2,
 X_DESCRIPTION				    VARCHAR2,
 X_FORMAT_TYPE                              VARCHAR2,
 X_CONTROL_FILE_NAME                        VARCHAR2,
 X_ENABLED                                  VARCHAR2,
 X_PRECISION				    NUMBER,
 X_DATE_FORMAT				    VARCHAR2,
 X_TIMESTAMP_FORMAT			    VARCHAR2,
 X_CREATED_BY                               NUMBER,
 X_CREATION_DATE                            DATE,
 X_LAST_UPDATED_BY                          NUMBER,
 X_LAST_UPDATE_DATE                         DATE,
 X_LAST_UPDATE_LOGIN                        NUMBER,
 X_ATTRIBUTE_CATEGORY                       VARCHAR2,
 X_ATTRIBUTE1                               VARCHAR2,
 X_ATTRIBUTE2                               VARCHAR2,
 X_ATTRIBUTE3                               VARCHAR2,
 X_ATTRIBUTE4                               VARCHAR2,
 X_ATTRIBUTE5                               VARCHAR2,
 X_ATTRIBUTE6                               VARCHAR2,
 X_ATTRIBUTE7                               VARCHAR2,
 X_ATTRIBUTE8                               VARCHAR2,
 X_ATTRIBUTE9                               VARCHAR2,
 X_ATTRIBUTE10                              VARCHAR2,
 X_ATTRIBUTE11                              VARCHAR2,
 X_ATTRIBUTE12                              VARCHAR2,
 X_ATTRIBUTE13                              VARCHAR2,
 X_ATTRIBUTE14                              VARCHAR2,
 X_ATTRIBUTE15                              VARCHAR2) IS
BEGIN
  UPDATE ce_bank_stmt_int_map
  SET  	map_id			= X_map_id,
	format_name 		= X_format_name,
	description		= X_description,
	format_type		= X_format_type,
	control_file_name	= X_control_file_name,
	enabled			= X_enabled,
	precision		= X_precision,
	date_format		= X_date_format,
	timestamp_format	= X_timestamp_format,
	attribute_category	= X_attribute_category,
	attribute1		= X_attribute1,
	attribute2		= X_attribute2,
	attribute3		= X_attribute3,
	attribute4		= X_attribute4,
	attribute5		= X_attribute5,
	attribute6		= X_attribute6,
	attribute7		= X_attribute7,
	attribute8		= X_attribute8,
	attribute9		= X_attribute9,
	attribute10		= X_attribute10,
	attribute11		= X_attribute11,
	attribute12		= X_attribute12,
	attribute13		= X_attribute13,
	attribute14		= X_attribute14,
	attribute15		= X_attribute15,
        last_updated_by         = x_last_updated_by,
        last_update_date        = x_last_update_date,
        last_update_login       = x_last_update_login
  WHERE rowid = X_row_id;
  if (SQL%NOTFOUND) then
    Raise NO_DATA_FOUND;
  end if;
END Map_Update_Row;

PROCEDURE Map_Lock_Row(
 X_ROW_ID				    VARCHAR2,
 X_MAP_ID                                   NUMBER,
 X_FORMAT_NAME                              VARCHAR2,
 X_DESCRIPTION				    VARCHAR2,
 X_FORMAT_TYPE                              VARCHAR2,
 X_CONTROL_FILE_NAME                        VARCHAR2,
 X_ENABLED                                  VARCHAR2,
 X_PRECISION				    NUMBER,
 X_DATE_FORMAT				    VARCHAR2,
 X_TIMESTAMP_FORMAT			    VARCHAR2,
 X_CREATED_BY                               NUMBER,
 X_CREATION_DATE                            DATE,
 X_LAST_UPDATED_BY                          NUMBER,
 X_LAST_UPDATE_DATE                         DATE,
 X_LAST_UPDATE_LOGIN                        NUMBER,
 X_ATTRIBUTE_CATEGORY                       VARCHAR2,
 X_ATTRIBUTE1                               VARCHAR2,
 X_ATTRIBUTE2                               VARCHAR2,
 X_ATTRIBUTE3                               VARCHAR2,
 X_ATTRIBUTE4                               VARCHAR2,
 X_ATTRIBUTE5                               VARCHAR2,
 X_ATTRIBUTE6                               VARCHAR2,
 X_ATTRIBUTE7                               VARCHAR2,
 X_ATTRIBUTE8                               VARCHAR2,
 X_ATTRIBUTE9                               VARCHAR2,
 X_ATTRIBUTE10                              VARCHAR2,
 X_ATTRIBUTE11                              VARCHAR2,
 X_ATTRIBUTE12                              VARCHAR2,
 X_ATTRIBUTE13                              VARCHAR2,
 X_ATTRIBUTE14                              VARCHAR2,
 X_ATTRIBUTE15                              VARCHAR2) IS

  CURSOR C IS
    SELECT *
    FROM ce_bank_stmt_int_map
    WHERE rowid = X_row_id
    FOR UPDATE of map_id NOWAIT;

  Recinfo C%ROWTYPE;

  BEGIN
	OPEN C;
	FETCH C INTO recinfo;
	if (C%NOTFOUND) then
		CLOSE C;
		FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
		APP_EXCEPTION.Raise_Exception;
	end if;
	CLOSE C;
	if (
			(Recinfo.map_id = X_map_id)
		   AND  (Recinfo.format_name = X_format_name)
		   AND  (    (Recinfo.description = X_description)
			 OR  (  (Recinfo.description IS NULL)
                             AND (X_description IS NULL)))
		   AND  (    (Recinfo.format_type = X_format_type)
			 OR  (  (Recinfo.format_type IS NULL)
                             AND (X_format_type IS NULL)))
		   AND  (    (Recinfo.control_file_name = X_control_file_name)
			 OR  (  (Recinfo.control_file_name IS NULL)
			     AND (X_control_file_name IS NULL)))
		   AND  (Recinfo.enabled = X_enabled)
		   AND  (    (Recinfo.precision = X_precision)
			 OR  (  (Recinfo.precision IS NULL)
                             AND (X_precision IS NULL)))
		   AND  (Recinfo.date_format = X_date_format)
		   AND  (    (Recinfo.timestamp_format = X_timestamp_format)
			 OR  (  (Recinfo.timestamp_format IS NULL)
                             AND (X_timestamp_format IS NULL)))
	   	   AND  (    (Recinfo.attribute_category = X_attribute_category)
			 OR  (  (Recinfo.attribute_category IS NULL)
			     AND (X_attribute_category IS NULL)))
		   AND  (    (Recinfo.attribute1 = X_attribute1)
			 OR  (  (Recinfo.attribute1 IS NULL)
			     AND (X_attribute1 IS NULL)))
		   AND  (    (Recinfo.attribute2 = X_attribute2)
			 OR  (  (Recinfo.attribute2 IS NULL)
			     AND (X_attribute2 IS NULL)))
		   AND  (    (Recinfo.attribute3 = X_attribute3)
			 OR  (  (Recinfo.attribute3 IS NULL)
			     AND (X_attribute3 IS NULL)))
		   AND  (    (Recinfo.attribute4 = X_attribute4)
			 OR  (  (Recinfo.attribute4 IS NULL)
			     AND (X_attribute4 IS NULL)))
		   AND  (    (Recinfo.attribute5 = X_attribute5)
			 OR  (  (Recinfo.attribute5 IS NULL)
			     AND (X_attribute5 IS NULL)))
		   AND  (    (Recinfo.attribute6 = X_attribute6)
			 OR  (  (Recinfo.attribute6 IS NULL)
			     AND (X_attribute6 IS NULL)))
		   AND  (    (Recinfo.attribute7 = X_attribute7)
			 OR  (  (Recinfo.attribute7 IS NULL)
			     AND (X_attribute7 IS NULL)))
		   AND  (    (Recinfo.attribute8 = X_attribute8)
			 OR  (  (Recinfo.attribute8 IS NULL)
			     AND (X_attribute8 IS NULL)))
		   AND  (    (Recinfo.attribute9 = X_attribute9)
			 OR  (  (Recinfo.attribute9 IS NULL)
			     AND (X_attribute9 IS NULL)))
		   AND  (    (Recinfo.attribute10 = X_attribute10)
			 OR  (  (Recinfo.attribute10 IS NULL)
			     AND (X_attribute10 IS NULL)))
		   AND  (    (Recinfo.attribute11 = X_attribute11)
			 OR  (  (Recinfo.attribute11 IS NULL)
			     AND (X_attribute11 IS NULL)))
		   AND  (    (Recinfo.attribute12 = X_attribute12)
			 OR  (  (Recinfo.attribute12 IS NULL)
			     AND (X_attribute12 IS NULL)))
		   AND  (    (Recinfo.attribute13 = X_attribute13)
			 OR  (  (Recinfo.attribute13 IS NULL)
			     AND (X_attribute13 IS NULL)))
		   AND  (    (Recinfo.attribute14 = X_attribute14)
			 OR  (  (Recinfo.attribute14 IS NULL)
			     AND (X_attribute14 IS NULL)))
		   AND  (    (Recinfo.attribute15 = X_attribute15)
			 OR  (  (Recinfo.attribute15 IS NULL)
			     AND (X_attribute15 IS NULL)))
	) then
	return;
	else
		FND_MESSAGE.Set_name('FND', 'FORM_RECORD_CHANGED');
		APP_EXCEPTION.Raise_Exception;
	end if;
END Map_Lock_Row;

PROCEDURE Headers_Insert_Row(
 X_ROW_ID		IN OUT NOCOPY		    VARCHAR2,
 X_MAP_HEADER_ID	IN OUT NOCOPY		    NUMBER,
 X_MAP_ID				    NUMBER,
 X_COLUMN_NAME				    VARCHAR2,
 X_REC_ID				    VARCHAR2,
 X_POSITION				    NUMBER,
 X_FORMAT				    VARCHAR2,
 X_INCLUDE_FORMAT_IND			    VARCHAR2,
 X_CONCATENATE_FORMAT_FLAG		    VARCHAR2,
 X_CREATED_BY                               NUMBER,
 X_CREATION_DATE                            DATE,
 X_LAST_UPDATED_BY                          NUMBER,
 X_LAST_UPDATE_DATE                         DATE,
 X_LAST_UPDATE_LOGIN                        NUMBER,
 X_ATTRIBUTE_CATEGORY                       VARCHAR2,
 X_ATTRIBUTE1                               VARCHAR2,
 X_ATTRIBUTE2                               VARCHAR2,
 X_ATTRIBUTE3                               VARCHAR2,
 X_ATTRIBUTE4                               VARCHAR2,
 X_ATTRIBUTE5                               VARCHAR2,
 X_ATTRIBUTE6                               VARCHAR2,
 X_ATTRIBUTE7                               VARCHAR2,
 X_ATTRIBUTE8                               VARCHAR2,
 X_ATTRIBUTE9                               VARCHAR2,
 X_ATTRIBUTE10                              VARCHAR2,
 X_ATTRIBUTE11                              VARCHAR2,
 X_ATTRIBUTE12                              VARCHAR2,
 X_ATTRIBUTE13                              VARCHAR2,
 X_ATTRIBUTE14                              VARCHAR2,
 X_ATTRIBUTE15                              VARCHAR2) IS

 CURSOR C_map_id IS
   SELECT 	CE_BANK_STMT_MAP_HDR_S.nextval
   FROM		sys.dual;

 CURSOR C_row_id IS
   SELECT 	rowid
   FROM 	ce_bank_stmt_map_hdr
   WHERE 	map_header_id = TO_NUMBER(X_MAP_HEADER_ID);
BEGIN
  OPEN C_map_id;
  FETCH C_map_id
  INTO 	X_MAP_HEADER_ID;
  CLOSE C_map_id;

  INSERT INTO ce_bank_stmt_map_hdr(
   	MAP_HEADER_ID,
	MAP_ID,
   	COLUMN_NAME,
   	REC_ID_NO,
   	POSITION,
	FORMAT,
       	INCLUDE_FORMAT_IND,
        CONCATENATE_FORMAT_FLAG,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN,
	ATTRIBUTE_CATEGORY,
	ATTRIBUTE1,
	ATTRIBUTE2,
	ATTRIBUTE3,
	ATTRIBUTE4,
	ATTRIBUTE5,
	ATTRIBUTE6,
	ATTRIBUTE7,
	ATTRIBUTE8,
	ATTRIBUTE9,
	ATTRIBUTE10,
	ATTRIBUTE11,
	ATTRIBUTE12,
	ATTRIBUTE13,
	ATTRIBUTE14,
	ATTRIBUTE15)
  VALUES(
 	X_MAP_HEADER_ID,
  	X_MAP_ID,
   	X_COLUMN_NAME,
   	X_REC_ID,
   	X_POSITION,
	X_FORMAT,
       	X_INCLUDE_FORMAT_IND,
	X_CONCATENATE_FORMAT_FLAG,
	X_CREATED_BY,
	X_CREATION_DATE,
	X_LAST_UPDATED_BY,
	X_LAST_UPDATE_DATE,
	X_LAST_UPDATE_LOGIN,
	X_ATTRIBUTE_CATEGORY,
	X_ATTRIBUTE1,
	X_ATTRIBUTE2,
	X_ATTRIBUTE3,
	X_ATTRIBUTE4,
	X_ATTRIBUTE5,
	X_ATTRIBUTE6,
	X_ATTRIBUTE7,
	X_ATTRIBUTE8,
	X_ATTRIBUTE9,
	X_ATTRIBUTE10,
	X_ATTRIBUTE11,
	X_ATTRIBUTE12,
	X_ATTRIBUTE13,
	X_ATTRIBUTE14,
	X_ATTRIBUTE15);

  OPEN C_row_id;
  FETCH C_row_id INTO X_row_id;
  if (C_row_id%NOTFOUND) then
    CLOSE C_row_id;
    Raise NO_DATA_FOUND;
  end if;
  CLOSE C_row_id;
END Headers_Insert_Row;

PROCEDURE Headers_Update_Row(
 X_ROW_ID				    VARCHAR2,
 X_MAP_HEADER_ID			    NUMBER,
 X_MAP_ID				    NUMBER,
 X_COLUMN_NAME				    VARCHAR2,
 X_REC_ID				    VARCHAR2,
 X_POSITION				    NUMBER,
 X_FORMAT				    VARCHAR2,
 X_INCLUDE_FORMAT_IND			    VARCHAR2,
 X_CONCATENATE_FORMAT_FLAG		    VARCHAR2,
 X_CREATED_BY                               NUMBER,
 X_CREATION_DATE                            DATE,
 X_LAST_UPDATED_BY                          NUMBER,
 X_LAST_UPDATE_DATE                         DATE,
 X_LAST_UPDATE_LOGIN                        NUMBER,
 X_ATTRIBUTE_CATEGORY                       VARCHAR2,
 X_ATTRIBUTE1                               VARCHAR2,
 X_ATTRIBUTE2                               VARCHAR2,
 X_ATTRIBUTE3                               VARCHAR2,
 X_ATTRIBUTE4                               VARCHAR2,
 X_ATTRIBUTE5                               VARCHAR2,
 X_ATTRIBUTE6                               VARCHAR2,
 X_ATTRIBUTE7                               VARCHAR2,
 X_ATTRIBUTE8                               VARCHAR2,
 X_ATTRIBUTE9                               VARCHAR2,
 X_ATTRIBUTE10                              VARCHAR2,
 X_ATTRIBUTE11                              VARCHAR2,
 X_ATTRIBUTE12                              VARCHAR2,
 X_ATTRIBUTE13                              VARCHAR2,
 X_ATTRIBUTE14                              VARCHAR2,
 X_ATTRIBUTE15                              VARCHAR2) IS
BEGIN
  UPDATE ce_bank_stmt_map_hdr
  SET  	map_header_id		= X_map_header_id,
	map_id			= X_map_id,
	column_name 		= X_column_name,
	rec_id_no		= X_rec_id,
	position		= X_position,
	format			= X_format,
       	include_format_ind	= X_include_format_ind,
        concatenate_format_flag	= X_concatenate_format_flag,
	attribute_category	= X_attribute_category,
	attribute1		= X_attribute1,
	attribute2		= X_attribute2,
	attribute3		= X_attribute3,
	attribute4		= X_attribute4,
	attribute5		= X_attribute5,
	attribute6		= X_attribute6,
	attribute7		= X_attribute7,
	attribute8		= X_attribute8,
	attribute9		= X_attribute9,
	attribute10		= X_attribute10,
	attribute11		= X_attribute11,
	attribute12		= X_attribute12,
	attribute13		= X_attribute13,
	attribute14		= X_attribute14,
	attribute15		= X_attribute15,
        last_updated_by         = x_last_updated_by,
        last_update_date        = x_last_update_date,
        last_update_login       = x_last_update_login
  WHERE rowid = X_row_id;
  if (SQL%NOTFOUND) then
    Raise NO_DATA_FOUND;
  end if;
END Headers_Update_Row;

PROCEDURE Headers_Lock_Row(
 X_ROW_ID				    VARCHAR2,
 X_MAP_HEADER_ID			    NUMBER,
 X_MAP_ID				    NUMBER,
 X_COLUMN_NAME				    VARCHAR2,
 X_REC_ID				    VARCHAR2,
 X_POSITION				    NUMBER,
 X_FORMAT				    VARCHAR2,
 X_INCLUDE_FORMAT_IND			    VARCHAR2,
 X_CONCATENATE_FORMAT_FLAG		    VARCHAR2,
 X_CREATED_BY                               NUMBER,
 X_CREATION_DATE                            DATE,
 X_LAST_UPDATED_BY                          NUMBER,
 X_LAST_UPDATE_DATE                         DATE,
 X_LAST_UPDATE_LOGIN                        NUMBER,
 X_ATTRIBUTE_CATEGORY                       VARCHAR2,
 X_ATTRIBUTE1                               VARCHAR2,
 X_ATTRIBUTE2                               VARCHAR2,
 X_ATTRIBUTE3                               VARCHAR2,
 X_ATTRIBUTE4                               VARCHAR2,
 X_ATTRIBUTE5                               VARCHAR2,
 X_ATTRIBUTE6                               VARCHAR2,
 X_ATTRIBUTE7                               VARCHAR2,
 X_ATTRIBUTE8                               VARCHAR2,
 X_ATTRIBUTE9                               VARCHAR2,
 X_ATTRIBUTE10                              VARCHAR2,
 X_ATTRIBUTE11                              VARCHAR2,
 X_ATTRIBUTE12                              VARCHAR2,
 X_ATTRIBUTE13                              VARCHAR2,
 X_ATTRIBUTE14                              VARCHAR2,
 X_ATTRIBUTE15                              VARCHAR2) IS

  CURSOR C IS
    SELECT *
    FROM ce_bank_stmt_map_hdr
    WHERE rowid = X_row_id
    FOR UPDATE of map_header_id NOWAIT;

  Recinfo C%ROWTYPE;

  BEGIN
	OPEN C;
	FETCH C INTO recinfo;
	if (C%NOTFOUND) then
		CLOSE C;
		FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
		APP_EXCEPTION.Raise_Exception;
	end if;
	CLOSE C;
	if (
			(Recinfo.map_id = X_map_id)
		   AND  (Recinfo.map_header_id = X_map_header_id)
		   AND  (Recinfo.column_name = X_column_name)
		   AND  NVL(Recinfo.include_format_ind,'N') = NVL(X_include_format_ind,'N')/* Bug 3033122 added the NVL to this condition */
		   AND  (Recinfo.concatenate_format_flag = X_concatenate_format_flag)
		   AND  (    (Recinfo.format = X_format)
			 OR  (  (Recinfo.format IS NULL)
                             AND (X_format IS NULL)))
		   AND  (    (Recinfo.rec_id_no = X_rec_id)
			 OR  (  (Recinfo.rec_id_no IS NULL)
                             AND (X_rec_id IS NULL)))
		   AND  (    (Recinfo.position = X_position)
			 OR  (  (Recinfo.position IS NULL)
			     AND (X_position IS NULL)))
	   	   AND  (    (Recinfo.attribute_category = X_attribute_category)
			 OR  (  (Recinfo.attribute_category IS NULL)
			     AND (X_attribute_category IS NULL)))
		   AND  (    (Recinfo.attribute1 = X_attribute1)
			 OR  (  (Recinfo.attribute1 IS NULL)
			     AND (X_attribute1 IS NULL)))
		   AND  (    (Recinfo.attribute2 = X_attribute2)
			 OR  (  (Recinfo.attribute2 IS NULL)
			     AND (X_attribute2 IS NULL)))
		   AND  (    (Recinfo.attribute3 = X_attribute3)
			 OR  (  (Recinfo.attribute3 IS NULL)
			     AND (X_attribute3 IS NULL)))
		   AND  (    (Recinfo.attribute4 = X_attribute4)
			 OR  (  (Recinfo.attribute4 IS NULL)
			     AND (X_attribute4 IS NULL)))
		   AND  (    (Recinfo.attribute5 = X_attribute5)
			 OR  (  (Recinfo.attribute5 IS NULL)
			     AND (X_attribute5 IS NULL)))
		   AND  (    (Recinfo.attribute6 = X_attribute6)
			 OR  (  (Recinfo.attribute6 IS NULL)
			     AND (X_attribute6 IS NULL)))
		   AND  (    (Recinfo.attribute7 = X_attribute7)
			 OR  (  (Recinfo.attribute7 IS NULL)
			     AND (X_attribute7 IS NULL)))
		   AND  (    (Recinfo.attribute8 = X_attribute8)
			 OR  (  (Recinfo.attribute8 IS NULL)
			     AND (X_attribute8 IS NULL)))
		   AND  (    (Recinfo.attribute9 = X_attribute9)
			 OR  (  (Recinfo.attribute9 IS NULL)
			     AND (X_attribute9 IS NULL)))
		   AND  (    (Recinfo.attribute10 = X_attribute10)
			 OR  (  (Recinfo.attribute10 IS NULL)
			     AND (X_attribute10 IS NULL)))
		   AND  (    (Recinfo.attribute11 = X_attribute11)
			 OR  (  (Recinfo.attribute11 IS NULL)
			     AND (X_attribute11 IS NULL)))
		   AND  (    (Recinfo.attribute12 = X_attribute12)
			 OR  (  (Recinfo.attribute12 IS NULL)
			     AND (X_attribute12 IS NULL)))
		   AND  (    (Recinfo.attribute13 = X_attribute13)
			 OR  (  (Recinfo.attribute13 IS NULL)
			     AND (X_attribute13 IS NULL)))
		   AND  (    (Recinfo.attribute14 = X_attribute14)
			 OR  (  (Recinfo.attribute14 IS NULL)
			     AND (X_attribute14 IS NULL)))
		   AND  (    (Recinfo.attribute15 = X_attribute15)
			 OR  (  (Recinfo.attribute15 IS NULL)
			     AND (X_attribute15 IS NULL)))
	) then
	return;
	else
		FND_MESSAGE.Set_name('FND', 'FORM_RECORD_CHANGED');
		APP_EXCEPTION.Raise_Exception;
	end if;
END Headers_Lock_Row;

PROCEDURE Lines_Insert_Row(
 X_ROW_ID		IN OUT NOCOPY		    VARCHAR2,
 X_MAP_LINE_ID		IN OUT NOCOPY		    NUMBER,
 X_MAP_ID				    NUMBER,
 X_COLUMN_NAME				    VARCHAR2,
 X_REC_ID				    VARCHAR2,
 X_POSITION				    NUMBER,
 X_FORMAT				    VARCHAR2,
 X_INCLUDE_FORMAT_IND			    VARCHAR2,
 X_CONCATENATE_FORMAT_FLAG		    VARCHAR2,
 X_CREATED_BY                               NUMBER,
 X_CREATION_DATE                            DATE,
 X_LAST_UPDATED_BY                          NUMBER,
 X_LAST_UPDATE_DATE                         DATE,
 X_LAST_UPDATE_LOGIN                        NUMBER,
 X_ATTRIBUTE_CATEGORY                       VARCHAR2,
 X_ATTRIBUTE1                               VARCHAR2,
 X_ATTRIBUTE2                               VARCHAR2,
 X_ATTRIBUTE3                               VARCHAR2,
 X_ATTRIBUTE4                               VARCHAR2,
 X_ATTRIBUTE5                               VARCHAR2,
 X_ATTRIBUTE6                               VARCHAR2,
 X_ATTRIBUTE7                               VARCHAR2,
 X_ATTRIBUTE8                               VARCHAR2,
 X_ATTRIBUTE9                               VARCHAR2,
 X_ATTRIBUTE10                              VARCHAR2,
 X_ATTRIBUTE11                              VARCHAR2,
 X_ATTRIBUTE12                              VARCHAR2,
 X_ATTRIBUTE13                              VARCHAR2,
 X_ATTRIBUTE14                              VARCHAR2,
 X_ATTRIBUTE15                              VARCHAR2) IS

 CURSOR C_map_id IS
   SELECT 	CE_BANK_STMT_MAP_LINE_S.nextval
   FROM		sys.dual;

 CURSOR C_row_id IS
   SELECT 	rowid
   FROM 	ce_bank_stmt_map_line
   WHERE 	map_line_id = TO_NUMBER(X_MAP_LINE_ID);
BEGIN
  OPEN C_map_id;
  FETCH C_map_id
  INTO 	X_MAP_LINE_ID;
  CLOSE C_map_id;

  INSERT INTO ce_bank_stmt_map_line(
   	MAP_LINE_ID,
	MAP_ID,
   	COLUMN_NAME,
   	REC_ID_NO,
   	POSITION,
	FORMAT,
       	INCLUDE_FORMAT_IND,
	CONCATENATE_FORMAT_FLAG,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN,
	ATTRIBUTE_CATEGORY,
	ATTRIBUTE1,
	ATTRIBUTE2,
	ATTRIBUTE3,
	ATTRIBUTE4,
	ATTRIBUTE5,
	ATTRIBUTE6,
	ATTRIBUTE7,
	ATTRIBUTE8,
	ATTRIBUTE9,
	ATTRIBUTE10,
	ATTRIBUTE11,
	ATTRIBUTE12,
	ATTRIBUTE13,
	ATTRIBUTE14,
	ATTRIBUTE15)
  VALUES(
 	X_MAP_LINE_ID,
  	X_MAP_ID,
   	X_COLUMN_NAME,
   	X_REC_ID,
   	X_POSITION,
	X_FORMAT,
       	X_INCLUDE_FORMAT_IND,
	X_CONCATENATE_FORMAT_FLAG,
	X_CREATED_BY,
	X_CREATION_DATE,
	X_LAST_UPDATED_BY,
	X_LAST_UPDATE_DATE,
	X_LAST_UPDATE_LOGIN,
	X_ATTRIBUTE_CATEGORY,
	X_ATTRIBUTE1,
	X_ATTRIBUTE2,
	X_ATTRIBUTE3,
	X_ATTRIBUTE4,
	X_ATTRIBUTE5,
	X_ATTRIBUTE6,
	X_ATTRIBUTE7,
	X_ATTRIBUTE8,
	X_ATTRIBUTE9,
	X_ATTRIBUTE10,
	X_ATTRIBUTE11,
	X_ATTRIBUTE12,
	X_ATTRIBUTE13,
	X_ATTRIBUTE14,
	X_ATTRIBUTE15);

  OPEN C_row_id;
  FETCH C_row_id INTO X_row_id;
  if (C_row_id%NOTFOUND) then
    CLOSE C_row_id;
    Raise NO_DATA_FOUND;
  end if;
  CLOSE C_row_id;
END Lines_Insert_Row;

PROCEDURE Lines_Update_Row(
 X_ROW_ID				    VARCHAR2,
 X_MAP_LINE_ID				    NUMBER,
 X_MAP_ID				    NUMBER,
 X_COLUMN_NAME				    VARCHAR2,
 X_REC_ID				    VARCHAR2,
 X_POSITION				    NUMBER,
 X_FORMAT				    VARCHAR2,
 X_INCLUDE_FORMAT_IND			    VARCHAR2,
 X_CONCATENATE_FORMAT_FLAG		    VARCHAR2,
 X_CREATED_BY                               NUMBER,
 X_CREATION_DATE                            DATE,
 X_LAST_UPDATED_BY                          NUMBER,
 X_LAST_UPDATE_DATE                         DATE,
 X_LAST_UPDATE_LOGIN                        NUMBER,
 X_ATTRIBUTE_CATEGORY                       VARCHAR2,
 X_ATTRIBUTE1                               VARCHAR2,
 X_ATTRIBUTE2                               VARCHAR2,
 X_ATTRIBUTE3                               VARCHAR2,
 X_ATTRIBUTE4                               VARCHAR2,
 X_ATTRIBUTE5                               VARCHAR2,
 X_ATTRIBUTE6                               VARCHAR2,
 X_ATTRIBUTE7                               VARCHAR2,
 X_ATTRIBUTE8                               VARCHAR2,
 X_ATTRIBUTE9                               VARCHAR2,
 X_ATTRIBUTE10                              VARCHAR2,
 X_ATTRIBUTE11                              VARCHAR2,
 X_ATTRIBUTE12                              VARCHAR2,
 X_ATTRIBUTE13                              VARCHAR2,
 X_ATTRIBUTE14                              VARCHAR2,
 X_ATTRIBUTE15                              VARCHAR2) IS
BEGIN
  UPDATE ce_bank_stmt_map_line
  SET  	map_line_id		= X_map_line_id,
	map_id			= X_map_id,
	column_name 		= X_column_name,
	rec_id_no		= X_rec_id,
	position		= X_position,
        format			= X_format,
	include_format_ind	= X_include_format_ind,
	concatenate_format_flag	= X_concatenate_format_flag,
	attribute_category	= X_attribute_category,
	attribute1		= X_attribute1,
	attribute2		= X_attribute2,
	attribute3		= X_attribute3,
	attribute4		= X_attribute4,
	attribute5		= X_attribute5,
	attribute6		= X_attribute6,
	attribute7		= X_attribute7,
	attribute8		= X_attribute8,
	attribute9		= X_attribute9,
	attribute10		= X_attribute10,
	attribute11		= X_attribute11,
	attribute12		= X_attribute12,
	attribute13		= X_attribute13,
	attribute14		= X_attribute14,
	attribute15		= X_attribute15,
	last_updated_by         = x_last_updated_by,
        last_update_date        = x_last_update_date,
        last_update_login       = x_last_update_login
  WHERE rowid = X_row_id;
  if (SQL%NOTFOUND) then
    Raise NO_DATA_FOUND;
  end if;
END Lines_Update_Row;

PROCEDURE Lines_Lock_Row(
 X_ROW_ID				    VARCHAR2,
 X_MAP_LINE_ID				    NUMBER,
 X_MAP_ID				    NUMBER,
 X_COLUMN_NAME				    VARCHAR2,
 X_REC_ID				    VARCHAR2,
 X_POSITION				    NUMBER,
 X_FORMAT				    VARCHAR2,
 X_INCLUDE_FORMAT_IND			    VARCHAR2,
 X_CONCATENATE_FORMAT_FLAG		    VARCHAR2,
 X_CREATED_BY                               NUMBER,
 X_CREATION_DATE                            DATE,
 X_LAST_UPDATED_BY                          NUMBER,
 X_LAST_UPDATE_DATE                         DATE,
 X_LAST_UPDATE_LOGIN                        NUMBER,
 X_ATTRIBUTE_CATEGORY                       VARCHAR2,
 X_ATTRIBUTE1                               VARCHAR2,
 X_ATTRIBUTE2                               VARCHAR2,
 X_ATTRIBUTE3                               VARCHAR2,
 X_ATTRIBUTE4                               VARCHAR2,
 X_ATTRIBUTE5                               VARCHAR2,
 X_ATTRIBUTE6                               VARCHAR2,
 X_ATTRIBUTE7                               VARCHAR2,
 X_ATTRIBUTE8                               VARCHAR2,
 X_ATTRIBUTE9                               VARCHAR2,
 X_ATTRIBUTE10                              VARCHAR2,
 X_ATTRIBUTE11                              VARCHAR2,
 X_ATTRIBUTE12                              VARCHAR2,
 X_ATTRIBUTE13                              VARCHAR2,
 X_ATTRIBUTE14                              VARCHAR2,
 X_ATTRIBUTE15                              VARCHAR2) IS

  CURSOR C IS
    SELECT *
    FROM ce_bank_stmt_map_line
    WHERE rowid = X_row_id
    FOR UPDATE of map_line_id NOWAIT;

  Recinfo C%ROWTYPE;

  BEGIN
	OPEN C;
	FETCH C INTO recinfo;
	if (C%NOTFOUND) then
		CLOSE C;
		FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
		APP_EXCEPTION.Raise_Exception;
	end if;
	CLOSE C;
	if (
			(Recinfo.map_id = X_map_id)
		   AND  (Recinfo.map_line_id = X_map_line_id)
		   AND  (Recinfo.column_name = X_column_name)
		   AND  (Recinfo.include_format_ind = X_include_format_ind)
		   AND  (Recinfo.concatenate_format_flag = X_concatenate_format_flag)
		   AND  (    (Recinfo.format = X_format)
			 OR  (  (Recinfo.format IS NULL)
                             AND (X_format IS NULL)))
		   AND  (    (Recinfo.rec_id_no = X_rec_id)
			 OR  (  (Recinfo.rec_id_no IS NULL)
                             AND (X_rec_id IS NULL)))
		   AND  (    (Recinfo.position = X_position)
			 OR  (  (Recinfo.position IS NULL)
			     AND (X_position IS NULL)))
	   	   AND  (    (Recinfo.attribute_category = X_attribute_category)
			 OR  (  (Recinfo.attribute_category IS NULL)
			     AND (X_attribute_category IS NULL)))
		   AND  (    (Recinfo.attribute1 = X_attribute1)
			 OR  (  (Recinfo.attribute1 IS NULL)
			     AND (X_attribute1 IS NULL)))
		   AND  (    (Recinfo.attribute2 = X_attribute2)
			 OR  (  (Recinfo.attribute2 IS NULL)
			     AND (X_attribute2 IS NULL)))
		   AND  (    (Recinfo.attribute3 = X_attribute3)
			 OR  (  (Recinfo.attribute3 IS NULL)
			     AND (X_attribute3 IS NULL)))
		   AND  (    (Recinfo.attribute4 = X_attribute4)
			 OR  (  (Recinfo.attribute4 IS NULL)
			     AND (X_attribute4 IS NULL)))
		   AND  (    (Recinfo.attribute5 = X_attribute5)
			 OR  (  (Recinfo.attribute5 IS NULL)
			     AND (X_attribute5 IS NULL)))
		   AND  (    (Recinfo.attribute6 = X_attribute6)
			 OR  (  (Recinfo.attribute6 IS NULL)
			     AND (X_attribute6 IS NULL)))
		   AND  (    (Recinfo.attribute7 = X_attribute7)
			 OR  (  (Recinfo.attribute7 IS NULL)
			     AND (X_attribute7 IS NULL)))
		   AND  (    (Recinfo.attribute8 = X_attribute8)
			 OR  (  (Recinfo.attribute8 IS NULL)
			     AND (X_attribute8 IS NULL)))
		   AND  (    (Recinfo.attribute9 = X_attribute9)
			 OR  (  (Recinfo.attribute9 IS NULL)
			     AND (X_attribute9 IS NULL)))
		   AND  (    (Recinfo.attribute10 = X_attribute10)
			 OR  (  (Recinfo.attribute10 IS NULL)
			     AND (X_attribute10 IS NULL)))
		   AND  (    (Recinfo.attribute11 = X_attribute11)
			 OR  (  (Recinfo.attribute11 IS NULL)
			     AND (X_attribute11 IS NULL)))
		   AND  (    (Recinfo.attribute12 = X_attribute12)
			 OR  (  (Recinfo.attribute12 IS NULL)
			     AND (X_attribute12 IS NULL)))
		   AND  (    (Recinfo.attribute13 = X_attribute13)
			 OR  (  (Recinfo.attribute13 IS NULL)
			     AND (X_attribute13 IS NULL)))
		   AND  (    (Recinfo.attribute14 = X_attribute14)
			 OR  (  (Recinfo.attribute14 IS NULL)
			     AND (X_attribute14 IS NULL)))
		   AND  (    (Recinfo.attribute15 = X_attribute15)
			 OR  (  (Recinfo.attribute15 IS NULL)
			     AND (X_attribute15 IS NULL)))
	) then
	return;
	else
		FND_MESSAGE.Set_name('FND', 'FORM_RECORD_CHANGED');
		APP_EXCEPTION.Raise_Exception;
	end if;

END Lines_Lock_Row;

END CE_BANK_STMT_LDR_PKG;

/
