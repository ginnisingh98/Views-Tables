--------------------------------------------------------
--  DDL for Package Body CN_CALC_EXT_TABLE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_CALC_EXT_TABLE_PKG" AS
/* $Header: cntexttb.pls 115.6 2002/11/21 21:09:24 hlchen ship $ */
--
-- Package Name
-- CN_CALC_EXT_TABLE_PKG
-- Purpose
--  Table Handler for CN_CALC_EXT_TABLE
--
-- History
-- 02-feb-01	Kumar Sivasankaran
-- ==========================================================================
-- |
-- |                             PRIVATE VARIABLES
-- |
-- ==========================================================================
  g_program_type     VARCHAR2(30) := NULL;
-- ==========================================================================
-- |
-- |                             PRIVATE ROUTINES
-- |
-- ==========================================================================

-- ==========================================================================
--  |                             Custom Validation
-- ==========================================================================

-- ==========================================================================
  -- Procedure Name
  --	Get_UID
  -- Purpose
  --    Get the Sequence Number to Create a new quota pay element
-- ==========================================================================
 PROCEDURE Get_UID( x_calc_ext_table_id     IN OUT NOCOPY NUMBER) IS

 BEGIN

    SELECT cn_calc_ext_tables_s.nextval
      INTO   X_calc_ext_table_id
      FROM   dual;

 END Get_UID;

-- ==========================================================================
  -- Procedure Name
  --	Insert_row
  -- Purpose
  --    Main insert procedure
-- ==========================================================================
PROCEDURE insert_row
   (x_calc_ext_table_id         IN OUT NOCOPY NUMBER
    ,p_name                     VARCHAR2        := NULL
    ,p_description              VARCHAR2        := NULL
    ,p_internal_table_id        NUMBER      := NULL
    ,p_external_table_id        NUMBER      := NULL
    ,P_USED_FLAG	        VARCHAR2        := NULL
    ,P_SCHEMA 		        VARCHAR2        := NULL
    ,P_EXTERNAL_TABLE_NAME      VARCHAR2        := NULL
    ,P_ALIAS		        VARCHAR2        := NULL
    ,p_attribute_category       VARCHAR2	:= NULL
    ,p_attribute1               VARCHAR2	:= NULL
    ,p_attribute2               VARCHAR2	:= NULL
    ,p_attribute3               VARCHAR2	:= NULL
    ,p_attribute4               VARCHAR2	:= NULL
    ,p_attribute5               VARCHAR2	:= NULL
    ,p_attribute6               VARCHAR2	:= NULL
    ,p_attribute7               VARCHAR2	:= NULL
    ,p_attribute8               VARCHAR2	:= NULL
    ,p_attribute9               VARCHAR2	:= NULL
    ,p_attribute10              VARCHAR2	:= NULL
    ,p_attribute11              VARCHAR2	:= NULL
    ,p_attribute12              VARCHAR2	:= NULL
    ,p_attribute13              VARCHAR2	:= NULL
    ,p_attribute14              VARCHAR2	:= NULL
    ,p_attribute15              VARCHAR2	:= NULL
    ,p_Created_By               NUMBER
    ,p_Creation_Date            DATE
    ,p_Last_Updated_By          NUMBER
    ,p_Last_Update_Date         DATE
    ,p_Last_Update_Login        NUMBER )
   IS
      l_dummy NUMBER;

   BEGIN

      Get_UID( x_calc_ext_table_id );

     INSERT INTO cn_calc_ext_tables
      ( calc_ext_table_id
        ,name
        ,DESCRIPTION
        ,INTERNAL_TABLE_ID
        ,EXTERNAL_TABLE_ID
        ,USED_FLAG
        ,SCHEMA
        ,EXTERNAL_TABLE_NAME
        ,ALIAS
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
	,Last_Update_Login)
       VALUES
       ( x_calc_ext_table_id
        ,p_name
        ,p_DESCRIPTION
        ,p_INTERNAL_TABLE_ID
        ,p_EXTERNAL_TABLE_ID
        ,p_USED_FLAG
        ,p_SCHEMA
        ,p_EXTERNAL_TABLE_NAME
        ,nvl(p_ALIAS, 'CN'||x_calc_ext_table_id)
	,p_attribute_category
	,p_attribute1
	,p_attribute2
	,p_attribute3
	,p_attribute4
	,p_attribute5
	,p_attribute6
	,p_attribute7
	,p_attribute8
	,p_attribute9
	,p_attribute10
	,p_attribute11
	,p_attribute12
	,p_attribute13
	,p_attribute14
	,p_attribute15
	,p_Created_By
	,p_Creation_Date
	,p_Last_Updated_By
	,p_Last_Update_Date
	,p_Last_Update_Login
	);

     select 1 INTO l_dummy  from CN_CALC_EXT_TABLES
       where calc_ext_table_id  = x_calc_ext_table_id;

   END Insert_row;

-- ==========================================================================
  -- Procedure Name
  --	Lock_row
  -- Purpose
  --    Lock db row after form record is changed
  -- Notes
-- ==========================================================================
PROCEDURE lock_row
   (p_calc_ext_table_id         NUMBER
    ,p_name                     VARCHAR2        := NULL
    ,p_description              VARCHAR2        := NULL
    ,p_internal_table_id        NUMBER      := NULL
    ,p_external_table_id        NUMBER      := NULL
    ,P_USED_FLAG	        VARCHAR2        := NULL
    ,P_SCHEMA 		        VARCHAR2        := NULL
    ,P_EXTERNAL_TABLE_NAME      VARCHAR2        := NULL
    ,P_ALIAS		        VARCHAR2        := NULL
    ,p_attribute_category       VARCHAR2	:= NULL
    ,p_attribute1               VARCHAR2	:= NULL
    ,p_attribute2               VARCHAR2	:= NULL
    ,p_attribute3               VARCHAR2	:= NULL
    ,p_attribute4               VARCHAR2	:= NULL
    ,p_attribute5               VARCHAR2	:= NULL
    ,p_attribute6               VARCHAR2	:= NULL
    ,p_attribute7               VARCHAR2	:= NULL
    ,p_attribute8               VARCHAR2        := NULL
    ,p_attribute9               VARCHAR2	:= NULL
    ,p_attribute10              VARCHAR2	:= NULL
    ,p_attribute11              VARCHAR2	:= NULL
    ,p_attribute12              VARCHAR2	:= NULL
    ,p_attribute13              VARCHAR2	:= NULL
    ,p_attribute14              VARCHAR2	:= NULL
    ,p_attribute15              VARCHAR2	:= NULL
   ) IS

     CURSOR C IS
        SELECT *
          FROM cn_calc_ext_tables
         WHERE calc_ext_table_id = p_calc_ext_table_id
           FOR UPDATE of calc_ext_table_id NOWAIT;

       tlinfo C%ROWTYPE;

  BEGIN
     OPEN C;
     FETCH C INTO tlinfo;

     IF (C%NOTFOUND) then
        CLOSE C;
        fnd_message.Set_Name('FND', 'FORM_RECORD_DELETED');
        app_exception.raise_exception;
     END IF;
     CLOSE C;
     NULL;

  END Lock_row;

-- ==========================================================================
  -- Procedure Name
  --   Update Record
  -- Purpose
  --
-- ==========================================================================
PROCEDURE update_row
    (p_calc_ext_table_id        NUMBER
    ,p_name                     VARCHAR2
    ,p_description              VARCHAR2
    ,p_internal_table_id        NUMBER
    ,p_external_table_id        NUMBER
    ,P_USED_FLAG	        VARCHAR2
    ,P_SCHEMA 		        VARCHAR2
    ,P_EXTERNAL_TABLE_NAME      VARCHAR2
    ,P_ALIAS		        VARCHAR2
    ,p_attribute_category       VARCHAR2
    ,p_attribute1               VARCHAR2
    ,p_attribute2               VARCHAR2
    ,p_attribute3               VARCHAR2
    ,p_attribute4               VARCHAR2
    ,p_attribute5               VARCHAR2
    ,p_attribute6               VARCHAR2
    ,p_attribute7               VARCHAR2
    ,p_attribute8               VARCHAR2
    ,p_attribute9               VARCHAR2
    ,p_attribute10              VARCHAR2
    ,p_attribute11              VARCHAR2
    ,p_attribute12              VARCHAR2
    ,p_attribute13              VARCHAR2
    ,p_attribute14              VARCHAR2
    ,p_attribute15              VARCHAR2
    ,p_Last_Updated_By          NUMBER
    ,p_Last_Update_Date         DATE
    ,p_Last_Update_Login        NUMBER ) IS


   l_calc_ext_table_id         cn_calc_ext_tables.calc_ext_table_id%TYPE;
   l_name                      cn_calc_ext_tables.name%TYPE;
   l_description               cn_calc_ext_tables.description%TYPE;
   l_internal_table_id         cn_calc_ext_tables.internal_table_id%TYPE;
   l_external_table_id         cn_calc_ext_tables.external_table_id%TYPE;
   l_USED_FLAG	                cn_calc_ext_tables.used_flag%TYPE;
   l_SCHEMA 		        cn_calc_ext_tables.schema%TYPE;
   l_EXTERNAL_TABLE_NAME       cn_calc_ext_tables.external_table_name%TYPE;
   l_ALIAS		        cn_calc_ext_tables.alias%TYPE;
   l_attribute_category		cn_calc_ext_tables.attribute_category%TYPE;
   l_attribute1			cn_calc_ext_tables.attribute1%TYPE;
   l_attribute2			cn_calc_ext_tables.attribute2%TYPE;
   l_attribute3	    		cn_calc_ext_tables.attribute3%TYPE;
   l_attribute4	    		cn_calc_ext_tables.attribute4%TYPE;
   l_attribute5	    		cn_calc_ext_tables.attribute5%TYPE;
   l_attribute6	   		cn_calc_ext_tables.attribute6%TYPE;
   l_attribute7	   		cn_calc_ext_tables.attribute7%TYPE;
   l_attribute8			cn_calc_ext_tables.attribute8%TYPE;
   l_attribute9			cn_calc_ext_tables.attribute9%TYPE;
   l_attribute10		cn_calc_ext_tables.attribute10%TYPE;
   l_attribute11		cn_calc_ext_tables.attribute11%TYPE;
   l_attribute12		cn_calc_ext_tables.attribute12%TYPE;
   l_attribute13		cn_calc_ext_tables.attribute13%TYPE;
   l_attribute14		cn_calc_ext_tables.attribute14%TYPE;
   l_attribute15		cn_calc_ext_tables.attribute15%TYPE;

   CURSOR C IS
	  SELECT *
	    FROM cn_calc_ext_tables
	    WHERE calc_ext_table_id = p_calc_ext_table_id
	    FOR UPDATE of calc_ext_table_id NOWAIT;
       oldrow C%ROWTYPE;

BEGIN
   OPEN C;
   FETCH C INTO oldrow;

   IF (C%NOTFOUND) then
      CLOSE C;
      fnd_message.Set_Name('FND', 'FORM_RECORD_DELETED');
      app_exception.raise_exception;
   END IF;
   CLOSE C;


   SELECT decode(p_calc_ext_table_id,
	     fnd_api.g_miss_num, oldrow.calc_ext_table_id,
	     p_calc_ext_table_id),
      decode(p_name,
	     fnd_api.g_miss_char, oldrow.name,
	     p_name),
      decode(p_description,
	     fnd_api.g_miss_char, oldrow.description,
	     p_description),
      decode(p_internal_table_id,
	     fnd_api.g_miss_num, oldrow.internal_table_id,
	     p_internal_table_id),
      decode(p_external_table_id,
	     fnd_api.g_miss_num, oldrow.external_table_id,
	     p_external_table_id),
      decode(p_used_flag,
	     fnd_api.g_miss_char, oldrow.used_flag,
	     p_used_flag),
      decode(p_schema,
	     fnd_api.g_miss_char, oldrow.schema,
	     p_schema),
     decode(p_external_table_name,
	     fnd_api.g_miss_char, oldrow.external_table_name,
	     p_external_table_name),
     decode(p_alias,
	     fnd_api.g_miss_char, oldrow.alias,
	     p_alias),
      decode(p_attribute_category,
	     fnd_api.g_miss_char, oldrow.attribute_category,
	     p_attribute_category),
      decode(p_attribute1,
	     fnd_api.g_miss_char, oldrow.attribute1,
	     p_attribute1),
      decode(p_attribute2,
	     fnd_api.g_miss_char, oldrow.attribute2,
	     p_attribute2),
      decode(p_attribute3,
	     fnd_api.g_miss_char, oldrow.attribute3,
	     p_attribute3),
      decode(p_attribute4,
	     fnd_api.g_miss_char, oldrow.attribute4,
	     p_attribute4),
      decode(p_attribute5,
	     fnd_api.g_miss_char, oldrow.attribute5,
	     p_attribute5),
      decode(p_attribute6,
	     fnd_api.g_miss_char, oldrow.attribute6,
	     p_attribute6),
      decode(p_attribute7,
	     fnd_api.g_miss_char, oldrow.attribute7,
	     p_attribute7),
      decode(p_attribute8,
	     fnd_api.g_miss_char, oldrow.attribute8,
	     p_attribute8),
      decode(p_attribute9,
	     fnd_api.g_miss_char, oldrow.attribute9,
	     p_attribute9),
      decode(p_attribute10,
	     fnd_api.g_miss_char, oldrow.attribute10,
	     p_attribute10),
      decode(p_attribute11,
	     fnd_api.g_miss_char, oldrow.attribute11,
	     p_attribute11),
      decode(p_attribute12,
	     fnd_api.g_miss_char, oldrow.attribute12,
	     p_attribute12),
      decode(p_attribute13,
	     fnd_api.g_miss_char, oldrow.attribute13,
	     p_attribute13),
      decode(p_attribute14,
	     fnd_api.g_miss_char, oldrow.attribute14,
	     p_attribute14),
      decode(p_attribute15,
	     fnd_api.g_miss_char, oldrow.attribute15,
	     p_attribute15)
     INTO
      l_calc_ext_table_id,
      l_name             ,
      l_description      ,
      l_internal_table_id,
      l_external_table_id,
      l_USED_FLAG	 ,
      l_SCHEMA 		 ,
      l_EXTERNAL_TABLE_NAME,
      l_ALIAS,
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

    UPDATE cn_calc_ext_tables
      SET
      calc_ext_table_id         =       l_calc_ext_table_id,
      name                      =       l_name,
      description               =       l_description,
      internal_table_id         =       l_internal_table_id,
      external_table_id         =       l_external_table_id,
      used_flag                 =       l_USED_FLAG,
      schema                    =       l_SCHEMA,
      external_table_name       =       l_EXTERNAL_TABLE_NAME,
      alias                     =       nvl(l_ALIAS,'CN'||l_calc_ext_table_id),
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
      last_update_date	        =	p_Last_Update_Date,
      last_updated_by      	=     	p_Last_Updated_By,
      last_update_login    	=     	p_Last_Update_Login
      WHERE calc_ext_table_id   =       p_calc_ext_table_id;

     IF (SQL%NOTFOUND) THEN
        RAISE NO_DATA_FOUND;
     END IF;

  END Update_row;

-- ==========================================================================
  -- Procedure Name
  --	Delete_row
  -- Purpose
-- ==========================================================================

  PROCEDURE Delete_row( p_calc_ext_table_id     NUMBER ) IS
  BEGIN

     DELETE FROM cn_calc_ext_tables
       WHERE  calc_ext_table_id  = p_calc_ext_table_id;
     IF (SQL%NOTFOUND) THEN
	RAISE NO_DATA_FOUND;
     END IF;

  END Delete_row;

END CN_CALC_EXT_TABLE_PKG;

/
