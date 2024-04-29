--------------------------------------------------------
--  DDL for Package Body CN_SCA_CRRULEATTR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SCA_CRRULEATTR_PKG" as
-- $Header: cntscrrb.pls 120.3 2005/10/12 11:58:36 mpawar noship $


  g_temp_status_code VARCHAR2(30) := NULL;
  g_program_type     VARCHAR2(30) := NULL;


 --------------------------------------------------------------------------
 -- Procedure Name : Get_UID
 -- Purpose        : Get the Sequence Number to Create a new Pay Group
 --------------------------------------------------------------------------

 PROCEDURE Get_UID( X_sca_rule_attribute_id     IN OUT NOCOPY NUMBER) IS

 BEGIN

    SELECT cn_sca_rule_attributes_s.nextval
      INTO   X_sca_rule_attribute_id
      FROM   sys.dual;

 END Get_UID;


  -------------------------------------------------------------------------
  -- Procedure Name : Insert_Record
  -- Purpose        : Main insert procedure
  -------------------------------------------------------------------------

 /* PROCEDURE Insert_Record(
                        x_Rowid                      IN OUT NOCOPY VARCHAR2
                       ,x_sca_rule_attribute_Id            IN OUT NOCOPY NUMBER
                       ,x_trx_source_name		         VARCHAR2
                       ,x_user_name		         VARCHAR2
		       ,x_destination_column		 VARCHAR2
                       ,x_value_set_id			 NUMBER
		       ,x_enable_flag			 VARCHAR2
		       ,x_datatype			 VARCHAR2
		       ,x_trx_src_column_name		 VARCHAR2
		       ,x_attribute_category             VARCHAR2
                       ,x_attribute1                     VARCHAR2
                       ,x_attribute2                     VARCHAR2
                       ,x_attribute3                     VARCHAR2
                       ,x_attribute4                     VARCHAR2
                       ,x_attribute5                     VARCHAR2
                       ,x_attribute6                     VARCHAR2
                       ,x_attribute7                     VARCHAR2
                       ,x_attribute8                     VARCHAR2
                       ,x_attribute9                     VARCHAR2
                       ,x_attribute10                    VARCHAR2
                       ,x_attribute11                    VARCHAR2
                       ,x_attribute12                    VARCHAR2
                       ,x_attribute13                    VARCHAR2
                       ,x_attribute14                    VARCHAR2
                       ,x_attribute15                    VARCHAR2
                       ,x_Created_By                     NUMBER
                       ,x_Creation_Date                  DATE
                       ,x_Last_Updated_By                NUMBER
                       ,x_Last_Update_Date               DATE
                       ,x_Last_Update_Login              NUMBER) IS



  BEGIN

     IF x_sca_rule_attribute_id is null
     THEN
        Get_UID( X_sca_rule_attribute_id );
     END IF;

          INSERT INTO cn_sca_rule_attributes(
		sca_rule_Attribute_id
               ,user_column_name
               ,src_column_name
               ,value_set_id
               ,enabled_Flag
               ,datatype
               ,trx_src_column_name
               ,transaction_source
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
               ,Created_By
               ,Creation_Date
               ,Last_Updated_By
               ,Last_Update_Date
               ,Last_Update_Login
               ,object_version_number)
            VALUES (
               	x_sca_rule_Attribute_id
               ,x_user_name
               ,x_destination_column
               ,x_value_set_id
               ,x_enable_flag
               ,x_datatype
               ,x_trx_src_column_name
               ,x_trx_source_name
	       ,x_attribute_category
               ,x_attribute1
               ,x_attribute2
               ,x_attribute3
               ,x_attribute4
               ,x_attribute5
               ,x_attribute6
               ,x_attribute7
               ,x_attribute8
               ,x_attribute9
               ,x_attribute10
               ,x_attribute11
               ,x_attribute12
               ,x_attribute13
               ,x_attribute14
               ,x_attribute15
               ,x_Created_By
               ,x_Creation_Date
               ,x_Last_Updated_By
               ,x_Last_Update_Date
               ,x_Last_Update_Login
               ,1
             );

  END Insert_Record;


  --------------------------------------------------------------------------
  -- Procedure Name : Update Record

  --------------------------------------------------------------------------

  PROCEDURE Update_Record(
                         x_Rowid                      IN OUT NOCOPY VARCHAR2
                        ,x_sca_rule_attribute_Id            IN OUT NOCOPY NUMBER
                        ,x_trx_source_name		         VARCHAR2
                        ,x_user_name		         VARCHAR2
 		        ,x_destination_column		 VARCHAR2
                        ,x_value_set_id			 NUMBER
 		        ,x_enable_flag			 VARCHAR2
 		        ,x_datatype			 VARCHAR2
 		        ,x_trx_src_column_name		 VARCHAR2
 		        ,x_attribute_category             VARCHAR2
                        ,x_attribute1                     VARCHAR2
                        ,x_attribute2                     VARCHAR2
                        ,x_attribute3                     VARCHAR2
                        ,x_attribute4                     VARCHAR2
                        ,x_attribute5                     VARCHAR2
                        ,x_attribute6                     VARCHAR2
                        ,x_attribute7                     VARCHAR2
                        ,x_attribute8                     VARCHAR2
                        ,x_attribute9                     VARCHAR2
                        ,x_attribute10                    VARCHAR2
                        ,x_attribute11                    VARCHAR2
                        ,x_attribute12                    VARCHAR2
                        ,x_attribute13                    VARCHAR2
                        ,x_attribute14                    VARCHAR2
                        ,x_attribute15                    VARCHAR2
                        ,x_Created_By                     NUMBER
                        ,x_Creation_Date                  DATE
                        ,x_Last_Updated_By                NUMBER
                        ,x_Last_Update_Date               DATE
                       ,x_Last_Update_Login              NUMBER) IS

   l_user_name			cn_sca_rule_attributes.user_column_name%TYPE;
   l_value_set_id		cn_sca_rule_attributes.value_set_id%TYPE;
   l_destination_column		cn_sca_rule_attributes.src_column_name%TYPE;
   l_enable_flag		cn_sca_rule_attributes.enabled_flag%TYPE;
   l_datatype			cn_sca_rule_attributes.datatype%TYPE;
   l_trx_source_column_name	cn_sca_rule_attributes.trx_src_column_name%TYPE;
   l_transaction_source  	cn_sca_rule_attributes.transaction_source%TYPE;
   l_attribute_category		cn_sca_rule_attributes.attribute_category%TYPE;
   l_attribute1			cn_sca_rule_attributes.attribute1%TYPE;
   l_attribute2			cn_sca_rule_attributes.attribute2%TYPE;
   l_attribute3	    		cn_sca_rule_attributes.attribute3%TYPE;
   l_attribute4	    		cn_sca_rule_attributes.attribute4%TYPE;
   l_attribute5	    		cn_sca_rule_attributes.attribute5%TYPE;
   l_attribute6	   		cn_sca_rule_attributes.attribute6%TYPE;
   l_attribute7	   		cn_sca_rule_attributes.attribute7%TYPE;
   l_attribute8			cn_sca_rule_attributes.attribute8%TYPE;
   l_attribute9			cn_sca_rule_attributes.attribute9%TYPE;
   l_attribute10		cn_sca_rule_attributes.attribute10%TYPE;
   l_attribute11		cn_sca_rule_attributes.attribute11%TYPE;
   l_attribute12		cn_sca_rule_attributes.attribute12%TYPE;
   l_attribute13		cn_sca_rule_attributes.attribute13%TYPE;
   l_attribute14		cn_sca_rule_attributes.attribute14%TYPE;
   l_attribute15		cn_sca_rule_attributes.attribute15%TYPE;

    CURSOR sca_rule_atribute_cur IS
       SELECT *
	 FROM cn_sca_rule_attributes
        WHERE sca_rule_attribute_id = x_sca_rule_attribute_id;

    l_sca_rule_attribute_rec sca_rule_atribute_cur%ROWTYPE;

 BEGIN

    OPEN sca_rule_atribute_cur;
    FETCH sca_rule_atribute_cur INTO l_sca_rule_attribute_rec;
    CLOSE sca_rule_atribute_cur;

    SELECT decode(x_user_name,
                  fnd_api.g_miss_char, l_sca_rule_attribute_rec.user_column_name,
		  x_user_name),
	   decode(x_destination_column,
                  fnd_api.g_miss_char, l_sca_rule_attribute_rec.src_column_name,
		  x_destination_column),
       	   decode(x_value_set_id,
                  cn_api.g_miss_num, l_sca_rule_attribute_rec.value_set_id,
		  x_value_set_id),
	   decode(x_enable_flag,
                  fnd_api.g_miss_char, l_sca_rule_attribute_rec.enabled_flag,
		  x_enable_flag),
	   decode(x_datatype,
                  fnd_api.g_miss_char, l_sca_rule_attribute_rec.datatype,
		  x_datatype),
	   decode(x_trx_src_column_name,
                  fnd_api.g_miss_char, l_sca_rule_attribute_rec.trx_src_column_name,
		  x_trx_src_column_name),
	   decode(x_trx_source_name,
                  fnd_api.g_miss_char, l_sca_rule_attribute_rec.transaction_source,
		  x_trx_source_name),

      	   decode(x_attribute_category,
                  fnd_api.g_miss_char, l_sca_rule_attribute_rec.attribute_category,
		  x_attribute_category),
	   decode(x_attribute1,
                  fnd_api.g_miss_char, l_sca_rule_attribute_rec.attribute1,
		  x_attribute1),
	   decode(x_attribute2,
                  fnd_api.g_miss_char, l_sca_rule_attribute_rec.attribute2,
		  x_attribute2),
	   decode(x_attribute3,
                  fnd_api.g_miss_char, l_sca_rule_attribute_rec.attribute3,
		  x_attribute3),
	   decode(x_attribute4,
                  fnd_api.g_miss_char, l_sca_rule_attribute_rec.attribute4,
		  x_attribute4),
	   decode(x_attribute5,
                  fnd_api.g_miss_char, l_sca_rule_attribute_rec.attribute5,
		  x_attribute5),
	   decode(x_attribute6,
                  fnd_api.g_miss_char, l_sca_rule_attribute_rec.attribute6,
		  x_attribute6),
	   decode(x_attribute7,
                  fnd_api.g_miss_char, l_sca_rule_attribute_rec.attribute7,
		  x_attribute7),
	   decode(x_attribute8,
                  fnd_api.g_miss_char, l_sca_rule_attribute_rec.attribute8,
		  x_attribute8),
	   decode(x_attribute9,
                  fnd_api.g_miss_char, l_sca_rule_attribute_rec.attribute9,
		  x_attribute9),
	   decode(x_attribute10,
                  fnd_api.g_miss_char, l_sca_rule_attribute_rec.attribute10,
		  x_attribute10),
	   decode(x_attribute11,
                  fnd_api.g_miss_char, l_sca_rule_attribute_rec.attribute11,
		  x_attribute11),
	   decode(x_attribute12,
                  fnd_api.g_miss_char, l_sca_rule_attribute_rec.attribute12,
		  x_attribute12),
	   decode(x_attribute13,
                  fnd_api.g_miss_char, l_sca_rule_attribute_rec.attribute13,
		  x_attribute13),
	   decode(x_attribute14,
                  fnd_api.g_miss_char, l_sca_rule_attribute_rec.attribute14,
		  x_attribute14),
	   decode(x_attribute15,
                  fnd_api.g_miss_char, l_sca_rule_attribute_rec.attribute15,
		  x_attribute15)

    INTO l_user_name,
	 l_destination_column	,
	 l_value_set_id,
         l_enable_flag,
	 l_datatype,
	 l_trx_source_column_name,
         l_transaction_source,
         l_attribute_category,
	 l_attribute1,
	 l_attribute2,
	 l_attribute3,
	 l_attribute4,
	 l_attribute5,
	 l_attribute6,
	 l_attribute7,
	 l_attribute8,
	 l_attribute9,
	 l_attribute10,
	 l_attribute11,
	 l_attribute12,
	 l_attribute13,
	 l_attribute14,
	 l_attribute15
    FROM dual;


    UPDATE cn_sca_rule_attributes
     SET
        user_column_name        =      	l_user_name,
	src_column_name	        = 	l_destination_column,
      value_set_id 		= 	l_value_set_id,
	enabled_flag		=	l_enable_flag,
	datatype		=	l_datatype,
        trx_src_column_name	=     	l_trx_source_column_name,
        transaction_source	=       l_transaction_source,
      attribute_category	=	l_attribute_category,
      attribute1		=       l_attribute1,
      attribute2		=       l_attribute2,
        attribute3		=	l_attribute3,
        attribute4		=	l_attribute4,
        attribute5		=	l_attribute5,
        attribute6		=	l_attribute6,
        attribute7		=	l_attribute7,
        attribute8		=	l_attribute8,
        attribute9		=	l_attribute9,
        attribute10		=	l_attribute10,
        attribute11		=	l_attribute11,
        attribute12		=	l_attribute12,
        attribute13		=	l_attribute13,
        attribute14		=	l_attribute14,
        attribute15		=	l_attribute15,
      last_update_date	  =	  x_Last_Update_Date,
      	last_updated_by      	=     	x_Last_Updated_By,
      last_update_login    	=     	x_Last_Update_Login,
   object_version_number  = object_version_number + 1
     WHERE sca_rule_attribute_id  =     x_sca_rule_attribute_id ;

     if (SQL%NOTFOUND) then
        Raise NO_DATA_FOUND;
     end if;

  END Update_Record;




  -----------------------------------------------------------------------------
  --  Procedure Name : BEGIN_RECORD
  --  Purpose        : This PUBLIC procedure is called at the start of the
  --		       commit cycle.
  -----------------------------------------------------------------------------
 PROCEDURE Begin_Record(
   X_OPERATION VARCHAR2,
   X_ROWID in out VARCHAR2,
   X_SCA_RULE_ATTRIBUTE_ID in NUMBER,
   X_TRANSACTION_SOURCE in VARCHAR2,
   X_SRC_COLUMN_NAME in VARCHAR2,
   X_DATATYPE in VARCHAR2,
   X_VALUE_SET_ID in NUMBER,
   X_TRX_SRC_COLUMN_NAME in VARCHAR2,
   X_ENABLED_FLAG in VARCHAR2,
   X_ATTRIBUTE_CATEGORY in VARCHAR2,
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
   X_OBJECT_VERSION_NUMBER in NUMBER,
   X_SECURITY_GROUP_ID in NUMBER,
   X_USER_COLUMN_NAME in VARCHAR2,
   X_CREATION_DATE in DATE,
   X_CREATED_BY in NUMBER,
   X_LAST_UPDATE_DATE in DATE,
   X_LAST_UPDATED_BY in NUMBER,
   X_LAST_UPDATE_LOGIN in NUMBER
 ) is



 BEGIN

   -- Saves passing it around

   g_temp_status_code 	:= 'COMPLETE'; -- Assume it is good to begin with
   IF X_Operation = 'INSERT' THEN

     Insert_Row(        X_ROWID
                       ,X_SCA_RULE_ATTRIBUTE_ID
                       ,X_TRANSACTION_SOURCE
		       ,X_SRC_COLUMN_NAME
		       ,X_DATATYPE
                       ,X_VALUE_SET_ID
		       ,X_TRX_SRC_COLUMN_NAME
		       ,X_ENABLED_FLAG
		       ,X_ATTRIBUTE_CATEGORY
		       ,X_ATTRIBUTE1
                       ,X_ATTRIBUTE2
                       ,X_ATTRIBUTE3
                       ,X_ATTRIBUTE4
                       ,X_ATTRIBUTE5
                       ,X_ATTRIBUTE6
                       ,X_ATTRIBUTE7
                       ,X_ATTRIBUTE8
                       ,X_ATTRIBUTE9
                       ,X_ATTRIBUTE10
                       ,X_ATTRIBUTE11
                       ,X_ATTRIBUTE12
                       ,X_ATTRIBUTE13
                       ,X_ATTRIBUTE14
                       ,X_ATTRIBUTE15
                       ,X_OBJECT_VERSION_NUMBER
                       ,X_SECURITY_GROUP_ID
                       	,X_USER_COLUMN_NAME
                       ,X_CREATION_DATE
                       ,X_CREATED_BY
                       ,X_LAST_UPDATE_DATE
                       ,X_LAST_UPDATED_BY
		       ,X_LAST_UPDATE_LOGIN);

   ELSIF X_Operation = 'UPDATE' THEN

     Update_Row(
                 X_SCA_RULE_ATTRIBUTE_ID
		 ,X_TRANSACTION_SOURCE
		 ,X_SRC_COLUMN_NAME
                 ,X_DATATYPE
		 ,X_VALUE_SET_ID
		 ,X_TRX_SRC_COLUMN_NAME
		 ,X_ENABLED_FLAG
		 ,X_ATTRIBUTE_CATEGORY
                 ,X_ATTRIBUTE1
                 ,X_ATTRIBUTE2
                 ,X_ATTRIBUTE3
                 ,X_ATTRIBUTE4
                 ,X_ATTRIBUTE5
                 ,X_ATTRIBUTE6
                 ,X_ATTRIBUTE7
                 ,X_ATTRIBUTE8
                 ,X_ATTRIBUTE9
                 ,X_ATTRIBUTE10
                 ,X_ATTRIBUTE11
                 ,X_ATTRIBUTE12
                 ,X_ATTRIBUTE13
                 ,X_ATTRIBUTE14
                 ,X_ATTRIBUTE15
                 ,X_OBJECT_VERSION_NUMBER
                 ,X_SECURITY_GROUP_ID
                 ,X_USER_COLUMN_NAME
                 ,X_LAST_UPDATE_DATE
      		 ,X_LAST_UPDATED_BY
		 ,X_LAST_UPDATE_LOGIN);
    END IF;

 END Begin_Record;
      */
 procedure INSERT_ROW (
   X_ROWID in out nocopy VARCHAR2,
   X_ORG_ID in NUMBER,  -- MOAC Change
   X_SCA_RULE_ATTRIBUTE_ID in NUMBER,
   X_TRANSACTION_SOURCE in VARCHAR2,
   X_SRC_COLUMN_NAME in VARCHAR2,
   X_DATATYPE in VARCHAR2,
   X_VALUE_SET_ID in NUMBER,
   X_TRX_SRC_COLUMN_NAME in VARCHAR2,
   X_ENABLED_FLAG in VARCHAR2,
   X_ATTRIBUTE_CATEGORY in VARCHAR2,
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
   X_OBJECT_VERSION_NUMBER in NUMBER,
   X_SECURITY_GROUP_ID in NUMBER,
   X_USER_COLUMN_NAME in VARCHAR2,
   X_CREATION_DATE in DATE,
   X_CREATED_BY in NUMBER,
   X_LAST_UPDATE_DATE in DATE,
   X_LAST_UPDATED_BY in NUMBER,
   X_LAST_UPDATE_LOGIN in NUMBER
 ) is
   cursor C is select ROWID from CN_SCA_RULE_ATTRIBUTES_ALL_B
     where SCA_RULE_ATTRIBUTE_ID = X_SCA_RULE_ATTRIBUTE_ID
       and org_id = x_org_id;   -- MOAC Change
 begin
   insert into CN_SCA_RULE_ATTRIBUTES_ALL_B (
     ORG_ID,    -- MOAC Change
     SCA_RULE_ATTRIBUTE_ID,
     TRANSACTION_SOURCE,
     SRC_COLUMN_NAME,
     DATATYPE,
     VALUE_SET_ID,
     TRX_SRC_COLUMN_NAME,
     ENABLED_FLAG,
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
     ATTRIBUTE15,
     OBJECT_VERSION_NUMBER,
     SECURITY_GROUP_ID,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN
   ) values (
     X_ORG_ID, -- MOAC Change
     X_SCA_RULE_ATTRIBUTE_ID,
     X_TRANSACTION_SOURCE,
     X_SRC_COLUMN_NAME,
     X_DATATYPE,
     X_VALUE_SET_ID,
     X_TRX_SRC_COLUMN_NAME,
     X_ENABLED_FLAG,
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
     X_ATTRIBUTE15,
     X_OBJECT_VERSION_NUMBER,
     X_SECURITY_GROUP_ID,
     X_CREATION_DATE,
     X_CREATED_BY,
     X_LAST_UPDATE_DATE,
     X_LAST_UPDATED_BY,
     X_LAST_UPDATE_LOGIN
   );

   insert into CN_SCA_RULE_ATTRIBUTES_ALL_TL (
     ORG_ID, -- MOAC Change
     SCA_RULE_ATTRIBUTE_ID,
     USER_COLUMN_NAME,
     CREATED_BY,
     CREATION_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_DATE,
     LAST_UPDATE_LOGIN,
     SECURITY_GROUP_ID,
     LANGUAGE,
     SOURCE_LANG
   ) select
     X_ORG_ID, -- MOAC Change
     X_SCA_RULE_ATTRIBUTE_ID,
     X_USER_COLUMN_NAME,
     X_CREATED_BY,
     X_CREATION_DATE,
     X_LAST_UPDATED_BY,
     X_LAST_UPDATE_DATE,
     X_LAST_UPDATE_LOGIN,
     X_SECURITY_GROUP_ID,
     L.LANGUAGE_CODE,
     userenv('LANG')
   from FND_LANGUAGES L
   where L.INSTALLED_FLAG in ('I', 'B')
   and not exists
     (select NULL
     from CN_SCA_RULE_ATTRIBUTES_ALL_TL T
     where T.SCA_RULE_ATTRIBUTE_ID = X_SCA_RULE_ATTRIBUTE_ID
     and T.LANGUAGE = L.LANGUAGE_CODE
     and T.ORG_ID = X_ORG_ID);

   open c;
   fetch c into X_ROWID;
   if (c%notfound) then
     close c;
     raise no_data_found;
   end if;
   close c;

 end INSERT_ROW;

 procedure LOCK_ROW (
   X_ORG_ID in NUMBER, -- MOAC Change
   X_SCA_RULE_ATTRIBUTE_ID in NUMBER,
   X_TRANSACTION_SOURCE in VARCHAR2,
   X_SRC_COLUMN_NAME in VARCHAR2,
   X_DATATYPE in VARCHAR2,
   X_VALUE_SET_ID in NUMBER,
   X_TRX_SRC_COLUMN_NAME in VARCHAR2,
   X_ENABLED_FLAG in VARCHAR2,
   X_ATTRIBUTE_CATEGORY in VARCHAR2,
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
   X_OBJECT_VERSION_NUMBER in NUMBER,
   X_SECURITY_GROUP_ID in NUMBER,
   X_USER_COLUMN_NAME in VARCHAR2
 ) is
   cursor c is select
       TRANSACTION_SOURCE,
       SRC_COLUMN_NAME,
       DATATYPE,
       VALUE_SET_ID,
       TRX_SRC_COLUMN_NAME,
       ENABLED_FLAG,
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
       ATTRIBUTE15,
       OBJECT_VERSION_NUMBER,
       SECURITY_GROUP_ID
     from CN_SCA_RULE_ATTRIBUTES_ALL_B
     where SCA_RULE_ATTRIBUTE_ID = X_SCA_RULE_ATTRIBUTE_ID
       and ORG_ID = X_ORG_ID   -- MOAC Change
     for update of SCA_RULE_ATTRIBUTE_ID nowait;
   recinfo c%rowtype;

   cursor c1 is select
       USER_COLUMN_NAME,
       decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
     from CN_SCA_RULE_ATTRIBUTES_ALL_TL
     where SCA_RULE_ATTRIBUTE_ID = X_SCA_RULE_ATTRIBUTE_ID
     and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
     and ORG_ID = X_ORG_ID
     for update of SCA_RULE_ATTRIBUTE_ID nowait;
 begin
   open c;
   fetch c into recinfo;
   if (c%notfound) then
     close c;
     fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
     app_exception.raise_exception;
   end if;
   close c;
   if (    (recinfo.TRANSACTION_SOURCE = X_TRANSACTION_SOURCE)
       AND (recinfo.SRC_COLUMN_NAME = X_SRC_COLUMN_NAME)
       AND (recinfo.DATATYPE = X_DATATYPE)
       AND ((recinfo.VALUE_SET_ID = X_VALUE_SET_ID)
            OR ((recinfo.VALUE_SET_ID is null) AND (X_VALUE_SET_ID is null)))
       AND ((recinfo.TRX_SRC_COLUMN_NAME = X_TRX_SRC_COLUMN_NAME)
            OR ((recinfo.TRX_SRC_COLUMN_NAME is null) AND (X_TRX_SRC_COLUMN_NAME is null)))
       AND ((recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
            OR ((recinfo.ENABLED_FLAG is null) AND (X_ENABLED_FLAG is null)))
       AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
            OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
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
       AND ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
            OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
       AND ((recinfo.SECURITY_GROUP_ID = X_SECURITY_GROUP_ID)
            OR ((recinfo.SECURITY_GROUP_ID is null) AND (X_SECURITY_GROUP_ID is null)))
   ) then
     null;
   else
     fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
     app_exception.raise_exception;
   end if;

   for tlinfo in c1 loop
     if (tlinfo.BASELANG = 'Y') then
       if (    (tlinfo.USER_COLUMN_NAME = X_USER_COLUMN_NAME)
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
   X_ORG_ID in NUMBER,  -- MOAC Change
   X_SCA_RULE_ATTRIBUTE_ID in NUMBER,
   X_TRANSACTION_SOURCE in VARCHAR2,
   X_SRC_COLUMN_NAME in VARCHAR2,
   X_DATATYPE in VARCHAR2,
   X_VALUE_SET_ID in NUMBER,
   X_TRX_SRC_COLUMN_NAME in VARCHAR2,
   X_ENABLED_FLAG in VARCHAR2,
   X_ATTRIBUTE_CATEGORY in VARCHAR2,
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
   X_OBJECT_VERSION_NUMBER in NUMBER,
   X_SECURITY_GROUP_ID in NUMBER,
   X_USER_COLUMN_NAME in VARCHAR2,
   X_LAST_UPDATE_DATE in DATE,
   X_LAST_UPDATED_BY in NUMBER,
   X_LAST_UPDATE_LOGIN in NUMBER
 ) is
 begin
   update CN_SCA_RULE_ATTRIBUTES_ALL_B set
     TRANSACTION_SOURCE = X_TRANSACTION_SOURCE,
     SRC_COLUMN_NAME = X_SRC_COLUMN_NAME,
     DATATYPE = X_DATATYPE,
     VALUE_SET_ID = X_VALUE_SET_ID,
     TRX_SRC_COLUMN_NAME = X_TRX_SRC_COLUMN_NAME,
     ENABLED_FLAG = X_ENABLED_FLAG,
     ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
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
     OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
     SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
     LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
     LAST_UPDATED_BY = X_LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
   where SCA_RULE_ATTRIBUTE_ID = X_SCA_RULE_ATTRIBUTE_ID
     and ORG_ID = X_ORG_ID; -- MOAC Change

   if (sql%notfound) then
     raise no_data_found;
   end if;

   update CN_SCA_RULE_ATTRIBUTES_ALL_TL set
     USER_COLUMN_NAME = X_USER_COLUMN_NAME,
     LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
     LAST_UPDATED_BY = X_LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
     SOURCE_LANG = userenv('LANG')
   where SCA_RULE_ATTRIBUTE_ID = X_SCA_RULE_ATTRIBUTE_ID
   and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
   and ORG_ID = X_ORG_ID; -- MOAC Change

   if (sql%notfound) then
     raise no_data_found;
   end if;
 end UPDATE_ROW;

 procedure DELETE_ROW (
   X_ORG_ID in NUMBER, -- MOAC Change
   X_SCA_RULE_ATTRIBUTE_ID in NUMBER
 ) is
 begin
   delete from CN_SCA_RULE_ATTRIBUTES_ALL_TL
   where SCA_RULE_ATTRIBUTE_ID = X_SCA_RULE_ATTRIBUTE_ID
     and ORG_ID = X_ORG_ID;  -- MOAC Change

   if (sql%notfound) then
     raise no_data_found;
   end if;

   delete from CN_SCA_RULE_ATTRIBUTES_ALL_B
   where SCA_RULE_ATTRIBUTE_ID = X_SCA_RULE_ATTRIBUTE_ID
     and ORG_ID = X_ORG_ID; -- MOAC Change

   if (sql%notfound) then
     raise no_data_found;
   end if;
 end DELETE_ROW;

 procedure ADD_LANGUAGE
 is
 begin
   delete from CN_SCA_RULE_ATTRIBUTES_ALL_TL T
   where not exists
     (select NULL
     from CN_SCA_RULE_ATTRIBUTES_ALL_B B
     where B.SCA_RULE_ATTRIBUTE_ID = T.SCA_RULE_ATTRIBUTE_ID
       and B.ORG_ID =  T.ORG_ID  -- MOAC Change
     );

   update CN_SCA_RULE_ATTRIBUTES_ALL_TL T set (
       USER_COLUMN_NAME
     ) = (select
       B.USER_COLUMN_NAME
     from CN_SCA_RULE_ATTRIBUTES_ALL_TL B
     where B.SCA_RULE_ATTRIBUTE_ID = T.SCA_RULE_ATTRIBUTE_ID
     and B.LANGUAGE = T.SOURCE_LANG
     and B.ORG_ID = T.ORG_ID   -- MOAC Change
     )
   where (
       T.SCA_RULE_ATTRIBUTE_ID,
       T.LANGUAGE
   ) in (select
       SUBT.SCA_RULE_ATTRIBUTE_ID,
       SUBT.LANGUAGE
     from CN_SCA_RULE_ATTRIBUTES_ALL_TL SUBB, CN_SCA_RULE_ATTRIBUTES_ALL_TL SUBT
     where SUBB.SCA_RULE_ATTRIBUTE_ID = SUBT.SCA_RULE_ATTRIBUTE_ID
     and SUBB.LANGUAGE = SUBT.SOURCE_LANG
     and SUBB.ORG_ID = SUBT.ORG_ID   -- MOAC Change
     and (SUBB.USER_COLUMN_NAME <> SUBT.USER_COLUMN_NAME
   ));

   insert into CN_SCA_RULE_ATTRIBUTES_ALL_TL (
     ORG_ID, -- MOAC Change
     SCA_RULE_ATTRIBUTE_ID,
     USER_COLUMN_NAME,
     CREATED_BY,
     CREATION_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_DATE,
     LAST_UPDATE_LOGIN,
     SECURITY_GROUP_ID,
     LANGUAGE,
     SOURCE_LANG
   ) select /*+ ORDERED */
     B.ORG_ID,  -- MOAC Change
     B.SCA_RULE_ATTRIBUTE_ID,
     B.USER_COLUMN_NAME,
     B.CREATED_BY,
     B.CREATION_DATE,
     B.LAST_UPDATED_BY,
     B.LAST_UPDATE_DATE,
     B.LAST_UPDATE_LOGIN,
     B.SECURITY_GROUP_ID,
     L.LANGUAGE_CODE,
     B.SOURCE_LANG
   from CN_SCA_RULE_ATTRIBUTES_ALL_TL B, FND_LANGUAGES L
   where L.INSTALLED_FLAG in ('I', 'B')
   and B.LANGUAGE = userenv('LANG')
   and not exists
     (select NULL
     from CN_SCA_RULE_ATTRIBUTES_ALL_TL T
     where T.SCA_RULE_ATTRIBUTE_ID = B.SCA_RULE_ATTRIBUTE_ID
     and T.LANGUAGE = L.LANGUAGE_CODE
     and B.ORG_ID = T.ORG_ID   -- MOAC Change
     );
 end ADD_LANGUAGE;

 -- --------------------------------------------------------------------+
 -- Procedure : LOAD_ROW
 -- Description : Called by FNDLOAD to upload seed datas, this procedure
 --    only handle seed datas. ORG_ID = -3113
 -- --------------------------------------------------------------------+
 PROCEDURE LOAD_ROW
   (  X_SCA_RULE_ATTRIBUTE_ID IN NUMBER,
      X_TRANSACTION_SOURCE in VARCHAR2,
      X_SRC_COLUMN_NAME in VARCHAR2,
      X_DATATYPE in VARCHAR2,
      X_VALUE_SET_ID in NUMBER,
      X_TRX_SRC_COLUMN_NAME in VARCHAR2,
      X_ENABLED_FLAG in VARCHAR2,
      X_USER_COLUMN_NAME IN VARCHAR2,
      x_org_id IN NUMBER,
      x_owner IN VARCHAR2) IS
        user_id NUMBER;

 BEGIN
    -- Validate input data
    IF (X_SCA_RULE_ATTRIBUTE_ID IS NULL) OR (X_USER_COLUMN_NAME IS NULL) THEN
       GOTO end_load_row;
    END IF;

    IF (x_owner IS NOT NULL) AND (x_owner = 'SEED') THEN
       user_id := 1;
     ELSE
       user_id := 0;
    END IF;
    -- Load The record to _B table
    UPDATE  cn_sca_rule_attributes_all_b SET
      last_update_date = sysdate,
      last_updated_by = user_id,
      last_update_login = 0
      WHERE sca_rule_attribute_id = X_SCA_RULE_ATTRIBUTE_id
      AND org_id = x_org_id;

    IF (SQL%NOTFOUND) THEN
       -- Insert new record to _B table
       INSERT INTO cn_sca_rule_attributes_all_b
 	( SCA_RULE_ATTRIBUTE_ID,
 	  TRANSACTION_SOURCE,
 	  SRC_COLUMN_NAME,
 	  DATATYPE,
 	  VALUE_SET_ID,
 	  TRX_SRC_COLUMN_NAME,
 	  ENABLED_FLAG,
 	 creation_date,
 	 created_by,
 	 last_update_date,
 	 last_updated_by,
	 last_update_login,
	 org_id
 	 ) VALUES
 	( X_SCA_RULE_ATTRIBUTE_ID,
 	  X_TRANSACTION_SOURCE,
 	  X_SRC_COLUMN_NAME,
 	  X_DATATYPE,
 	  X_VALUE_SET_ID,
 	  X_TRX_SRC_COLUMN_NAME,
 	  X_ENABLED_FLAG,
 	 sysdate,
 	 user_id,
 	 sysdate,
 	 user_id,
	 0,
	 x_org_id
 	 );
    END IF;
    -- Load The record to _TL table
    UPDATE cn_sca_rule_attributes_all_tl SET
      USER_COLUMN_NAME = X_USER_COLUMN_NAME,
      last_update_date = sysdate,
      last_updated_by = user_id,
      last_update_login = 0,
      source_lang = userenv('LANG')
      WHERE sca_rule_attribute_id = x_sca_rule_attribute_id
      AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

    IF (SQL%NOTFOUND) THEN
       -- Insert new record to _TL table
       INSERT INTO cn_sca_rule_attributes_all_tl
 	(sca_rule_attribute_id,
 	 USER_COLUMN_NAME,
 	 creation_date,
 	 created_by,
 	 last_update_date,
 	 last_updated_by,
 	 last_update_login,
 	 language,
 	 source_lang)
 	SELECT
 	x_sca_rule_attribute_id,
 	X_USER_COLUMN_NAME,
 	sysdate,
 	user_id,
 	sysdate,
 	user_id,
 	0,
 	l.language_code,
 	userenv('LANG')
 	FROM fnd_languages l
 	WHERE l.installed_flag IN ('I', 'B')
 	AND NOT EXISTS
 	(SELECT NULL
 	 FROM cn_sca_rule_attributes_all_tl t
 	 WHERE t.sca_rule_attribute_id = x_sca_rule_attribute_id
 	 AND t.language = l.language_code);
    END IF;
    << end_load_row >>
      NULL;
 END LOAD_ROW ;

 -- --------------------------------------------------------------------+
 -- Procedure : TRANSLATE_ROW
 -- Description : Called by FNDLOAD to translate seed datas, this procedure
 --    only handle seed datas. ORG_ID = -3113
 -- --------------------------------------------------------------------+
 PROCEDURE TRANSLATE_ROW
   ( X_SCA_RULE_ATTRIBUTE_ID IN NUMBER,
     X_USER_COLUMN_NAME IN VARCHAR2,
     x_owner IN VARCHAR2) IS
        user_id NUMBER;
 BEGIN
     -- Validate input data
    IF (X_SCA_RULE_ATTRIBUTE_ID IS NULL) OR (X_USER_COLUMN_NAME IS NULL) THEN
       GOTO end_translate_row;
    END IF;

    IF (x_owner IS NOT NULL) AND (x_owner = 'SEED') THEN
       user_id := 1;
     ELSE
       user_id := 0;
    END IF;
    -- Update the translation
    UPDATE cn_sca_rule_attributes_all_tl SET
      USER_COLUMN_NAME = X_USER_COLUMN_NAME,
      last_update_date = sysdate,
      last_updated_by = user_id,
      last_update_login = 0,
      source_lang = userenv('LANG')
      WHERE sca_rule_attribute_id = x_sca_rule_attribute_id
      AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

    << end_translate_row >>
      NULL;
END TRANSLATE_ROW ;


END CN_SCA_CRRULEATTR_PKG;

/
