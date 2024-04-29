--------------------------------------------------------
--  DDL for Package Body ZX_FC_CODES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_FC_CODES_PKG" as
/* $Header: zxcfccodesb.pls 120.8.12010000.2 2008/11/28 12:52:33 nisinha ship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_CLASSIFICATION_ID in NUMBER,
  X_Classification_Code in VARCHAR2,
  X_CLASSIFICATION_TYPE_CODE in VARCHAR2,
  X_PARENT_CLASSIFICATION_ID in NUMBER,
  X_PARENT_CLASSIFICATION_CODE in VARCHAR2,
  X_COUNTRY_CODE in VARCHAR2,
  X_Compiled_Flag in VARCHAR2,
  X_EFFECTIVE_FROM in DATE,
  X_EFFECTIVE_TO in DATE,
  X_REQUEST_ID in NUMBER,
  X_Record_Type_Code in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_CLASSIFICATION_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_Program_Login_Id in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
p_type_id	  ZX_FC_TYPES_VL.CLASSIFICATION_TYPE_ID%TYPE;
p_type_code	  ZX_FC_TYPES_VL.CLASSIFICATION_TYPE_CODE%TYPE;
p_type_name	  ZX_FC_TYPES_VL.CLASSIFICATION_TYPE_NAME%TYPE;
p_type_categ      ZX_FC_TYPES_VL.Classification_Type_Categ_Code%TYPE;
p_delimiter	  ZX_FC_TYPES_VL.DELIMITER%TYPE;
p_concat_code     Zx_Fc_Codes_Denorm_B.CONCAT_CLASSIF_CODE%TYPE;
p_concat_name     Zx_Fc_Codes_Denorm_B.CONCAT_CLASSIF_NAME%TYPE;
p_code_level	  Zx_Fc_Codes_Denorm_B.CLASSIFICATION_CODE_LEVEL%TYPE;
p_parent_name     Zx_Fc_Codes_Denorm_B.CLASSIFICATION_NAME%TYPE;
TYPE p_seg_t	  	IS TABLE OF VARCHAR2(30) index BY BINARY_INTEGER;
TYPE p_seg_tn	  	IS TABLE OF Zx_Fc_Codes_Denorm_B.CLASSIFICATION_NAME%TYPE index BY BINARY_INTEGER;
p_seg 			p_seg_t;
p_seg_name 		p_seg_tn;
p_tmp_seg 		p_seg_t;
p_tmp_seg_name 		p_seg_tn;
cursor C is select ROWID from ZX_FC_CODES_B
    where CLASSIFICATION_ID = X_CLASSIFICATION_ID ;
cursor C_GET_TYPES_INFO is
	SELECT
	TYPE.CLASSIFICATION_TYPE_ID,
	TYPE.CLASSIFICATION_TYPE_CODE,
	TYPE.CLASSIFICATION_TYPE_NAME,
	TYPE.Classification_Type_Categ_Code,
	TYPE.DELIMITER
	FROM ZX_FC_TYPES_VL TYPE
	WHERE TYPE.CLASSIFICATION_TYPE_CODE = X_CLASSIFICATION_TYPE_CODE;
cursor C_GET_PARENT_DETAIL  is
	SELECT
            CONCAT_CLASSIF_CODE,CONCAT_CLASSIF_NAME,CLASSIFICATION_CODE_LEVEL,CLASSIFICATION_NAME,
	    SEGMENT1,SEGMENT2,SEGMENT3,SEGMENT4,SEGMENT5,
	    SEGMENT6,SEGMENT7,SEGMENT8,SEGMENT9,SEGMENT10,
	    SEGMENT1_NAME,SEGMENT2_NAME,SEGMENT3_NAME,SEGMENT4_NAME,SEGMENT5_NAME,
	    SEGMENT6_NAME,SEGMENT7_NAME,SEGMENT8_NAME,SEGMENT9_NAME,SEGMENT10_NAME
	FROM
            ZX_FC_CODES_DENORM_B
        WHERE
            CLASSIFICATION_ID = X_PARENT_CLASSIFICATION_ID AND
            LANGUAGE = userenv('LANG');
begin
  insert into ZX_FC_CODES_B (
    CLASSIFICATION_ID,
    Classification_Code,
    CLASSIFICATION_TYPE_CODE,
    PARENT_CLASSIFICATION_ID,
    PARENT_CLASSIFICATION_CODE,
    COUNTRY_CODE,
    Compiled_Flag,
    EFFECTIVE_FROM,
    EFFECTIVE_TO,
    REQUEST_ID,
    Record_Type_Code,
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
    ATTRIBUTE15,
    ATTRIBUTE_CATEGORY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    PROGRAM_APPLICATION_ID,
    PROGRAM_ID ,
    Program_Login_Id,
    OBJECT_VERSION_NUMBER
  ) values (
    X_CLASSIFICATION_ID,
    X_Classification_Code,
    X_CLASSIFICATION_TYPE_CODE,
    X_PARENT_CLASSIFICATION_ID,
    X_PARENT_CLASSIFICATION_CODE,
    X_COUNTRY_CODE,
    X_Compiled_Flag,
    X_EFFECTIVE_FROM,
    X_EFFECTIVE_TO,
    X_REQUEST_ID,
    X_Record_Type_Code,
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
    X_ATTRIBUTE15,
    X_ATTRIBUTE_CATEGORY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_ID,
    X_Program_Login_Id,
    X_OBJECT_VERSION_NUMBER
  );
  insert into ZX_FC_CODES_TL (
    CLASSIFICATION_ID,
    CLASSIFICATION_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CLASSIFICATION_ID,
    X_CLASSIFICATION_NAME,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from ZX_FC_CODES_TL T
    where T.CLASSIFICATION_ID = X_CLASSIFICATION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
OPEN C_GET_TYPES_INFO;
fetch C_GET_TYPES_INFO into p_type_id,p_type_code,p_type_name,p_type_categ,p_delimiter;

FOR j IN 1..10
LOOP
	p_seg(j)   	:= '';
        p_seg_name(j)	:= '';
END LOOP;

IF X_PARENT_CLASSIFICATION_ID is NULL THEN
  p_code_level 	:= 1;
  p_concat_code := X_Classification_Code;
  p_concat_name := X_CLASSIFICATION_NAME;
  p_seg(1)	:= X_Classification_Code;
  p_seg_name(1) := X_CLASSIFICATION_NAME;
else
  FOR parentRec in C_GET_PARENT_DETAIL
  LOOP
  	p_concat_code 	:= parentRec.CONCAT_CLASSIF_CODE || p_delimiter || X_Classification_Code;
  	p_concat_name 	:= parentRec.CONCAT_CLASSIF_NAME || p_delimiter || X_CLASSIFICATION_NAME;
  	p_code_level 	:= parentRec.CLASSIFICATION_CODE_LEVEL + 1;
	p_parent_name   := parentRec.CLASSIFICATION_NAME;
	p_tmp_seg(1) 	:= parentRec.SEGMENT1;
	p_tmp_seg(2) 	:= parentRec.SEGMENT2;
	p_tmp_seg(3) 	:= parentRec.SEGMENT3;
	p_tmp_seg(4) 	:= parentRec.SEGMENT4;
	p_tmp_seg(5) 	:= parentRec.SEGMENT5;
	p_tmp_seg(6) 	:= parentRec.SEGMENT6;
	p_tmp_seg(7) 	:= parentRec.SEGMENT7;
	p_tmp_seg(8) 	:= parentRec.SEGMENT8;
	p_tmp_seg(9) 	:= parentRec.SEGMENT9;
	p_tmp_seg(10) 	:= parentRec.SEGMENT10;
	p_tmp_seg_name(1)  := parentRec.SEGMENT1_NAME;
	p_tmp_seg_name(2)  := parentRec.SEGMENT2_NAME;
	p_tmp_seg_name(3)  := parentRec.SEGMENT3_NAME;
	p_tmp_seg_name(4)  := parentRec.SEGMENT4_NAME;
	p_tmp_seg_name(5)  := parentRec.SEGMENT5_NAME;
	p_tmp_seg_name(6)  := parentRec.SEGMENT6_NAME;
	p_tmp_seg_name(7)  := parentRec.SEGMENT7_NAME;
	p_tmp_seg_name(8)  := parentRec.SEGMENT8_NAME;
	p_tmp_seg_name(9)  := parentRec.SEGMENT9_NAME;
	p_tmp_seg_name(10) := parentRec.SEGMENT10_NAME;
  END LOOP;
  FOR i IN 1..10
  LOOP
	IF p_tmp_seg(i) IS NULL THEN
	  p_seg(i) 	:= X_Classification_Code;
	  p_seg_name(i) := X_CLASSIFICATION_NAME;
	  EXIT;
        ELSE
	  p_seg(i) 	:= p_tmp_seg(i);
	  p_seg_name(i) := p_tmp_seg_name(i);
	END IF;
  END LOOP;
END IF;
CLOSE C_GET_TYPES_INFO;

INSERT INTO Zx_Fc_Codes_Denorm_B(
    CLASSIFICATION_TYPE_ID,
    CLASSIFICATION_TYPE_CODE,
    CLASSIFICATION_TYPE_NAME,
    Classification_Type_Categ_Code,
    CLASSIFICATION_ID,
    Classification_Code,
    CLASSIFICATION_NAME,
    LANGUAGE,
    EFFECTIVE_FROM,
    EFFECTIVE_TO,
    Enabled_Flag,
    ANCESTOR_ID,
    ANCESTOR_CODE,
    ANCESTOR_NAME,
    CONCAT_CLASSIF_CODE,
    CONCAT_CLASSIF_NAME,
    CLASSIFICATION_CODE_LEVEL,
    COUNTRY_CODE,
    SEGMENT1,
    SEGMENT2,
    SEGMENT3,
    SEGMENT4,
    SEGMENT5,
    SEGMENT6,
    SEGMENT7,
    SEGMENT8,
    SEGMENT9,
    SEGMENT10,
    SEGMENT1_NAME,
    SEGMENT2_NAME,
    SEGMENT3_NAME,
    SEGMENT4_NAME,
    SEGMENT5_NAME,
    SEGMENT6_NAME,
    SEGMENT7_NAME,
    SEGMENT8_NAME,
    SEGMENT9_NAME,
    SEGMENT10_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    REQUEST_ID,
    PROGRAM_ID,
    PROGRAM_APPLICATION_ID,
    Program_Login_Id,
    Record_Type_Code)
SELECT
    p_type_id,
    p_type_code,
    p_type_name,
    p_type_categ,
    X_CLASSIFICATION_ID,
    X_Classification_Code,
    X_CLASSIFICATION_NAME,
    L.LANGUAGE_CODE,
    X_EFFECTIVE_FROM,
    X_EFFECTIVE_TO,
    'Y',
    X_PARENT_CLASSIFICATION_ID,
    X_PARENT_CLASSIFICATION_CODE,
    p_parent_name,
    p_concat_code,
    p_concat_name,
    p_code_level,
    X_COUNTRY_CODE,
    p_seg(1),
    p_seg(2),
    p_seg(3),
    p_seg(4),
    p_seg(5),
    p_seg(6),
    p_seg(7),
    p_seg(8),
    p_seg(9),
    p_seg(10),
    p_seg_name(1),
    p_seg_name(2),
    p_seg_name(3),
    p_seg_name(4),
    p_seg_name(5),
    p_seg_name(6),
    p_seg_name(7),
    p_seg_name(8),
    p_seg_name(9),
    p_seg_name(10),
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_LAST_UPDATE_DATE,
    X_REQUEST_ID,
    X_PROGRAM_ID,
    X_PROGRAM_APPLICATION_ID,
    X_Program_Login_Id,
    X_Record_Type_Code
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from Zx_Fc_Codes_Denorm_B Denorm
    where Denorm.CLASSIFICATION_ID = X_CLASSIFICATION_ID
    and Denorm.LANGUAGE = L.LANGUAGE_CODE);

end INSERT_ROW;

procedure LOCK_ROW (
  X_CLASSIFICATION_ID in NUMBER,
  X_Classification_Code in VARCHAR2,
  X_CLASSIFICATION_TYPE_CODE in VARCHAR2,
  X_PARENT_CLASSIFICATION_ID in NUMBER,
  X_PARENT_CLASSIFICATION_CODE in VARCHAR2,
  X_COUNTRY_CODE in VARCHAR2,
  X_Compiled_Flag in VARCHAR2,
  X_EFFECTIVE_FROM in DATE,
  X_EFFECTIVE_TO in DATE,
  X_REQUEST_ID in NUMBER,
  X_Record_Type_Code in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_CLASSIFICATION_NAME in VARCHAR2,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_Program_Login_Id in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select
      Classification_Code,
      CLASSIFICATION_TYPE_CODE,
      PARENT_CLASSIFICATION_ID,
      PARENT_CLASSIFICATION_CODE,
      COUNTRY_CODE,
      Compiled_Flag,
      EFFECTIVE_FROM,
      EFFECTIVE_TO,
      REQUEST_ID,
      Record_Type_Code,
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
      ATTRIBUTE15,
      ATTRIBUTE_CATEGORY,
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID,
      Program_Login_Id  ,
      OBJECT_VERSION_NUMBER
    from ZX_FC_CODES_B
    where CLASSIFICATION_ID = X_CLASSIFICATION_ID
    for update of CLASSIFICATION_ID nowait;
  recinfo c%rowtype;
  cursor c1 is select
      CLASSIFICATION_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from ZX_FC_CODES_TL
    where CLASSIFICATION_ID = X_CLASSIFICATION_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of CLASSIFICATION_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.Classification_Code = X_Classification_Code)
      AND (recinfo.CLASSIFICATION_TYPE_CODE = X_CLASSIFICATION_TYPE_CODE)
      AND ((recinfo.PARENT_CLASSIFICATION_ID = X_PARENT_CLASSIFICATION_ID)
           OR ((recinfo.PARENT_CLASSIFICATION_ID is null) AND (X_PARENT_CLASSIFICATION_ID is null)))
      AND ((recinfo.PARENT_CLASSIFICATION_CODE = X_PARENT_CLASSIFICATION_CODE)
           OR ((recinfo.PARENT_CLASSIFICATION_CODE is null) AND (X_PARENT_CLASSIFICATION_CODE is null)))
      AND ((recinfo.COUNTRY_CODE = X_COUNTRY_CODE)
           OR ((recinfo.COUNTRY_CODE is null) AND (X_COUNTRY_CODE is null)))
      AND ((recinfo.Compiled_Flag = X_Compiled_Flag)
           OR ((recinfo.Compiled_Flag is null) AND (X_Compiled_Flag is null)))
      AND ((recinfo.EFFECTIVE_FROM = X_EFFECTIVE_FROM)
           OR ((recinfo.EFFECTIVE_FROM is null) AND (X_EFFECTIVE_FROM is null)))
      AND ((recinfo.EFFECTIVE_TO = X_EFFECTIVE_TO)
           OR ((recinfo.EFFECTIVE_TO is null) AND (X_EFFECTIVE_TO is null)))
      AND ((recinfo.REQUEST_ID = X_REQUEST_ID)
           OR ((recinfo.REQUEST_ID is null) AND (X_REQUEST_ID is null)))
      AND ((recinfo.Record_Type_Code = X_Record_Type_Code)
           OR ((recinfo.Record_Type_Code is null) AND (X_Record_Type_Code is null)))
      AND ((recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID)
           OR ((recinfo.PROGRAM_APPLICATION_ID is null) AND (X_PROGRAM_APPLICATION_ID is null)))
      AND ((recinfo.PROGRAM_ID = X_PROGRAM_ID)
           OR ((recinfo.PROGRAM_ID is null) AND (X_PROGRAM_ID is null)))
      AND ((recinfo.Program_Login_Id = X_Program_Login_Id)
           OR ((recinfo.Program_Login_Id is null) AND (X_Program_Login_Id is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.CLASSIFICATION_NAME = X_CLASSIFICATION_NAME)
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_CLASSIFICATION_ID in NUMBER,
  X_Classification_Code in VARCHAR2,
  X_CLASSIFICATION_TYPE_CODE in VARCHAR2,
  X_PARENT_CLASSIFICATION_ID in NUMBER,
  X_PARENT_CLASSIFICATION_CODE in VARCHAR2,
  X_COUNTRY_CODE in VARCHAR2,
  X_Compiled_Flag in VARCHAR2,
  X_EFFECTIVE_FROM in DATE,
  X_EFFECTIVE_TO in DATE,
  X_REQUEST_ID in NUMBER,
  X_Record_Type_Code in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_CLASSIFICATION_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_Program_Login_Id in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
p_delimiter	  ZX_FC_TYPES_VL.DELIMITER%TYPE;
p_concat_name     Zx_Fc_Codes_Denorm_B.CONCAT_CLASSIF_NAME%TYPE;
begin
  update ZX_FC_CODES_B set
    Classification_Code = X_Classification_Code,
    CLASSIFICATION_TYPE_CODE = X_CLASSIFICATION_TYPE_CODE,
    PARENT_CLASSIFICATION_ID = X_PARENT_CLASSIFICATION_ID,
    PARENT_CLASSIFICATION_CODE = X_PARENT_CLASSIFICATION_CODE,
    COUNTRY_CODE = X_COUNTRY_CODE,
    Compiled_Flag = X_Compiled_Flag,
    EFFECTIVE_FROM = X_EFFECTIVE_FROM,
    EFFECTIVE_TO = X_EFFECTIVE_TO,
    REQUEST_ID = X_REQUEST_ID,
    Record_Type_Code = X_Record_Type_Code,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    PROGRAM_APPLICATION_ID=X_PROGRAM_APPLICATION_ID ,
    PROGRAM_ID=X_PROGRAM_ID ,
    Program_Login_Id=X_Program_Login_Id,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER
  where CLASSIFICATION_ID = X_CLASSIFICATION_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  update ZX_FC_CODES_TL set
    CLASSIFICATION_NAME = X_CLASSIFICATION_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where CLASSIFICATION_ID = X_CLASSIFICATION_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
  if (sql%notfound) then
    raise no_data_found;
  end if;
  p_delimiter	  := '';
  p_concat_name   := '';
  IF X_PARENT_CLASSIFICATION_ID IS NOT NULL THEN
      select DELIMITER into p_delimiter FROM ZX_FC_TYPES_B WHERE
   	   CLASSIFICATION_TYPE_CODE = X_CLASSIFICATION_TYPE_CODE;
      select CONCAT_CLASSIF_NAME into p_concat_name from
    	  Zx_Fc_Codes_Denorm_B CodeDenorm where CLASSIFICATION_ID = X_PARENT_CLASSIFICATION_ID
	  and userenv('LANG') in (LANGUAGE);
  END IF;
 -- start bug#7600239
  update Zx_Fc_Codes_Denorm_B set
    COUNTRY_CODE	= X_COUNTRY_CODE,
    EFFECTIVE_TO	= X_EFFECTIVE_TO,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    PROGRAM_APPLICATION_ID=X_PROGRAM_APPLICATION_ID ,
    PROGRAM_ID=X_PROGRAM_ID ,
    Program_Login_Id=X_Program_Login_Id
    where CLASSIFICATION_ID = X_CLASSIFICATION_ID;

  update Zx_Fc_Codes_Denorm_B set
    CLASSIFICATION_NAME = X_CLASSIFICATION_NAME,
    CONCAT_CLASSIF_NAME = p_concat_name || p_delimiter || X_CLASSIFICATION_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    PROGRAM_APPLICATION_ID=X_PROGRAM_APPLICATION_ID ,
    PROGRAM_ID=X_PROGRAM_ID ,
    Program_Login_Id=X_Program_Login_Id
    where CLASSIFICATION_ID = X_CLASSIFICATION_ID
    and userenv('LANG') in (LANGUAGE);
-- end bug#7600239
end UPDATE_ROW;

procedure DELETE_ROW (
  X_CLASSIFICATION_ID in NUMBER
) is
begin
  delete from ZX_FC_CODES_TL
  where CLASSIFICATION_ID = X_CLASSIFICATION_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  delete from ZX_FC_CODES_B
  where CLASSIFICATION_ID = X_CLASSIFICATION_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from ZX_FC_CODES_TL T
  where not exists
    (select NULL
    from ZX_FC_CODES_B B
    where B.CLASSIFICATION_ID = T.CLASSIFICATION_ID
    );
  update ZX_FC_CODES_TL T set (
      CLASSIFICATION_NAME
    ) = (select
      B.CLASSIFICATION_NAME
    from ZX_FC_CODES_TL B
    where B.CLASSIFICATION_ID = T.CLASSIFICATION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CLASSIFICATION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CLASSIFICATION_ID,
      SUBT.LANGUAGE
    from ZX_FC_CODES_TL SUBB, ZX_FC_CODES_TL SUBT
    where SUBB.CLASSIFICATION_ID = SUBT.CLASSIFICATION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.CLASSIFICATION_NAME <> SUBT.CLASSIFICATION_NAME
  ));
  insert into ZX_FC_CODES_TL (
    CLASSIFICATION_ID,
    CLASSIFICATION_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.CLASSIFICATION_ID,
    B.CLASSIFICATION_NAME,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from ZX_FC_CODES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from ZX_FC_CODES_TL T
    where T.CLASSIFICATION_ID = B.CLASSIFICATION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

/* Logic to delete/update/insert into zx_fc_codes_denorm_b table */

  delete from ZX_FC_CODES_DENORM_B T
  where not exists
    (select NULL
    from ZX_FC_CODES_B B
    where B.CLASSIFICATION_ID = T.CLASSIFICATION_ID
    );

  /* commented out the following code, as we don't have
     SOURCE_LANG column in the ZX_FC_CODES_DENORM_B table */
  /*
  update ZX_FC_CODES_DENORM_B T set (
      CLASSIFICATION_NAME
    ) = (select
      B.CLASSIFICATION_NAME
    from ZX_FC_CODES_DENORM_B B
    where B.CLASSIFICATION_ID = T.CLASSIFICATION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CLASSIFICATION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CLASSIFICATION_ID,
      SUBT.LANGUAGE
    from ZX_FC_CODES_DENORM_B SUBB, ZX_FC_CODES_DENORM_B SUBT
    where SUBB.CLASSIFICATION_ID = SUBT.CLASSIFICATION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.CLASSIFICATION_NAME <> SUBT.CLASSIFICATION_NAME
  ));
 */

  insert into ZX_FC_CODES_DENORM_B (
    CLASSIFICATION_ID,
    CLASSIFICATION_CODE,
    CLASSIFICATION_NAME,
    CLASSIFICATION_TYPE_ID,
    CLASSIFICATION_TYPE_CODE,
    CLASSIFICATION_TYPE_NAME,
    CLASSIFICATION_TYPE_CATEG_CODE,
    EFFECTIVE_FROM,
    EFFECTIVE_TO,
    ENABLED_FLAG,
    ANCESTOR_ID,
    ANCESTOR_CODE,
    ANCESTOR_NAME,
    CONCAT_CLASSIF_CODE,
    CONCAT_CLASSIF_NAME,
    CLASSIFICATION_CODE_LEVEL,
    COUNTRY_CODE,
    SEGMENT1,
    SEGMENT2,
    SEGMENT3,
    SEGMENT4,
    SEGMENT5,
    SEGMENT6,
    SEGMENT7,
    SEGMENT8,
    SEGMENT9,
    SEGMENT10,
    SEGMENT1_NAME,
    SEGMENT2_NAME,
    SEGMENT3_NAME,
    SEGMENT4_NAME,
    SEGMENT5_NAME,
    SEGMENT6_NAME,
    SEGMENT7_NAME,
    SEGMENT8_NAME,
    SEGMENT9_NAME,
    SEGMENT10_NAME,
    REQUEST_ID,
    PROGRAM_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_LOGIN_ID,
    RECORD_TYPE_CODE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE
  ) select
    B.CLASSIFICATION_ID,
    B.CLASSIFICATION_CODE,
    B.CLASSIFICATION_NAME,
    B.CLASSIFICATION_TYPE_ID,
    B.CLASSIFICATION_TYPE_CODE,
    B.CLASSIFICATION_TYPE_NAME,
    B.CLASSIFICATION_TYPE_CATEG_CODE,
    B.EFFECTIVE_FROM,
    B.EFFECTIVE_TO,
    B.ENABLED_FLAG,
    B.ANCESTOR_ID,
    B.ANCESTOR_CODE,
    B.ANCESTOR_NAME,
    B.CONCAT_CLASSIF_CODE,
    B.CONCAT_CLASSIF_NAME,
    B.CLASSIFICATION_CODE_LEVEL,
    B.COUNTRY_CODE,
    B.SEGMENT1,
    B.SEGMENT2,
    B.SEGMENT3,
    B.SEGMENT4,
    B.SEGMENT5,
    B.SEGMENT6,
    B.SEGMENT7,
    B.SEGMENT8,
    B.SEGMENT9,
    B.SEGMENT10,
    B.SEGMENT1_NAME,
    B.SEGMENT2_NAME,
    B.SEGMENT3_NAME,
    B.SEGMENT4_NAME,
    B.SEGMENT5_NAME,
    B.SEGMENT6_NAME,
    B.SEGMENT7_NAME,
    B.SEGMENT8_NAME,
    B.SEGMENT9_NAME,
    B.SEGMENT10_NAME,
    B.REQUEST_ID,
    B.PROGRAM_ID,
    B.PROGRAM_APPLICATION_ID,
    B.PROGRAM_LOGIN_ID,
    B.RECORD_TYPE_CODE,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE
  from ZX_FC_CODES_DENORM_B B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from ZX_FC_CODES_DENORM_B T
    where T.CLASSIFICATION_ID = B.CLASSIFICATION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

end ADD_LANGUAGE;

end ZX_FC_CODES_PKG;

/
