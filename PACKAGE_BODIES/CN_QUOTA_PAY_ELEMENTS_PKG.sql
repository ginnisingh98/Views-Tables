--------------------------------------------------------
--  DDL for Package Body CN_QUOTA_PAY_ELEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_QUOTA_PAY_ELEMENTS_PKG" AS
/* $Header: cntqpeb.pls 115.2 2002/02/05 00:26:05 pkm ship      $ */
--
-- Package Name
-- CN_QUOTA_PAY_ELEMENTS_PKG
-- Purpose
--  Table Handler for CN_QUOTA_PAY_ELEMENTS
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
 PROCEDURE Get_UID( X_quota_pay_element_id     IN OUT NUMBER) IS

 BEGIN

    SELECT cn_quota_pay_elements_s.nextval
      INTO   X_quota_pay_element_id
      FROM   dual;

 END Get_UID;

-- ==========================================================================
  -- Procedure Name
  --	Insert_row
  -- Purpose
  --    Main insert procedure
-- ==========================================================================
PROCEDURE insert_row
   (x_quota_pay_element_id  IN OUT NUMBER
    ,p_quota_id                 IN NUMBER
    ,p_pay_element_type_id      IN NUMBER
    ,p_status                   VARCHAR2        := NULL
    ,p_start_date	        DATE
    ,p_end_date	                DATE
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

      Get_UID( x_quota_pay_element_id );

     INSERT INTO cn_quota_pay_elements
       (quota_pay_element_id
	,quota_id
	,pay_element_type_id
	,status
	,start_date
	,end_date
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
       (x_quota_pay_element_id
	,p_quota_id
	,p_pay_element_type_id
	,p_status
	,p_start_date
	,p_end_date
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

     select 1 INTO l_dummy  from CN_QUOTA_PAY_ELEMENTS
       where QUOTA_PAY_ELEMENT_ID = x_quota_pay_element_id;

   END Insert_row;

-- ==========================================================================
  -- Procedure Name
  --	Lock_row
  -- Purpose
  --    Lock db row after form record is changed
  -- Notes
-- ==========================================================================
PROCEDURE lock_row
   ( p_quota_pay_element_id     IN NUMBER
    ,p_quota_id                 IN NUMBER
    ,p_pay_element_type_id      IN NUMBER
    ,p_status                   VARCHAR2        := NULL
    ,p_start_date	        DATE
    ,p_end_date	                DATE
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
          FROM cn_quota_pay_elements
         WHERE quota_pay_element_id = p_quota_pay_element_id
           FOR UPDATE of quota_pay_element_id NOWAIT;

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

     IF (     ((tlinfo.ATTRIBUTE1 = P_ATTRIBUTE1)
               OR ((tlinfo.ATTRIBUTE1 is null) AND (P_ATTRIBUTE1 is null)))
          AND ((tlinfo.ATTRIBUTE2 = P_ATTRIBUTE2)
               OR ((tlinfo.ATTRIBUTE2 is null) AND (P_ATTRIBUTE2 is null)))
          AND ((tlinfo.ATTRIBUTE3 = P_ATTRIBUTE3)
               OR ((tlinfo.ATTRIBUTE3 is null) AND (P_ATTRIBUTE3 is null)))
          AND ((tlinfo.ATTRIBUTE4 = P_ATTRIBUTE4)
               OR ((tlinfo.ATTRIBUTE4 is null) AND (P_ATTRIBUTE4 is null)))
          AND ((tlinfo.ATTRIBUTE5 = P_ATTRIBUTE5)
               OR ((tlinfo.ATTRIBUTE5 is null) AND (P_ATTRIBUTE5 is null)))
          AND ((tlinfo.ATTRIBUTE6 = P_ATTRIBUTE6)
               OR ((tlinfo.ATTRIBUTE6 is null) AND (P_ATTRIBUTE6 is null)))
          AND ((tlinfo.ATTRIBUTE7 = P_ATTRIBUTE7)
               OR ((tlinfo.ATTRIBUTE7 is null) AND (P_ATTRIBUTE7 is null)))
          AND ((tlinfo.ATTRIBUTE8 = P_ATTRIBUTE8)
               OR ((tlinfo.ATTRIBUTE8 is null) AND (P_ATTRIBUTE8 is null)))
          AND ((tlinfo.ATTRIBUTE9 = P_ATTRIBUTE9)
               OR ((tlinfo.ATTRIBUTE9 is null) AND (P_ATTRIBUTE9 is null)))
          AND ((tlinfo.ATTRIBUTE10 = P_ATTRIBUTE10)
               OR ((tlinfo.ATTRIBUTE10 is null) AND (P_ATTRIBUTE10 is null)))
          AND ((tlinfo.ATTRIBUTE11 = P_ATTRIBUTE11)
               OR ((tlinfo.ATTRIBUTE11 is null) AND (P_ATTRIBUTE11 is null)))
          AND ((tlinfo.ATTRIBUTE12 = P_ATTRIBUTE12)
               OR ((tlinfo.ATTRIBUTE12 is null) AND (P_ATTRIBUTE12 is null)))
          AND ((tlinfo.ATTRIBUTE13 = P_ATTRIBUTE13)
               OR ((tlinfo.ATTRIBUTE13 is null) AND (P_ATTRIBUTE13 is null)))
          AND ((tlinfo.ATTRIBUTE14 = P_ATTRIBUTE14)
               OR ((tlinfo.ATTRIBUTE14 is null) AND (P_ATTRIBUTE14 is null)))
          AND ((tlinfo.ATTRIBUTE15 = P_ATTRIBUTE15)
               OR ((tlinfo.ATTRIBUTE15 is null) AND (P_ATTRIBUTE15 is null)))
          AND ((tlinfo.ATTRIBUTE_CATEGORY = P_ATTRIBUTE_CATEGORY)
               OR ((tlinfo.ATTRIBUTE_CATEGORY is null) AND
		   (P_ATTRIBUTE_CATEGORY is null)))
          AND ((tlinfo.STATUS = P_STATUS)
               OR ((tlinfo.STATUS is null) AND (P_STATUS is null)))
          AND (tlinfo.START_DATE = P_START_DATE)
          AND ((tlinfo.END_DATE = P_END_DATE)
               OR ((tlinfo.END_DATE is null) AND (P_END_DATE is null)))
          AND (tlinfo.QUOTA_ID = P_QUOTA_ID)
          AND (tlinfo.PAY_ELEMENT_TYPE_ID = P_PAY_ELEMENT_TYPE_ID)
      )
     THEN
        RETURN;
     ELSE
        fnd_message.Set_Name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
     END IF;

  END Lock_row;

-- ==========================================================================
  -- Procedure Name
  --   Update Record
  -- Purpose
  --   To Update the quota Pay element
  --
-- ==========================================================================
PROCEDURE update_row
   (p_quota_pay_element_id      NUMBER
    ,p_quota_id                 NUMBER
    ,p_pay_element_type_id      NUMBER
    ,p_status                   VARCHAR2
    ,p_start_date		DATE
    ,p_end_date		        DATE
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

   l_quota_pay_element_id	cn_quota_pay_elements.quota_pay_element_id%TYPE;
   l_quota_id			cn_quota_pay_elements.quota_id%TYPE;
   l_pay_element_type_id 	cn_quota_pay_elements.pay_element_type_id%TYPE;
   l_start_date			cn_quota_pay_elements.start_date%TYPE;
   l_end_date			cn_quota_pay_elements.end_date%TYPE;
   l_status           		cn_quota_pay_elements.status%TYPE;
   l_attribute_category		cn_quota_pay_elements.attribute_category%TYPE;
   l_attribute1			cn_quota_pay_elements.attribute1%TYPE;
   l_attribute2			cn_quota_pay_elements.attribute2%TYPE;
   l_attribute3	    		cn_quota_pay_elements.attribute3%TYPE;
   l_attribute4	    		cn_quota_pay_elements.attribute4%TYPE;
   l_attribute5	    		cn_quota_pay_elements.attribute5%TYPE;
   l_attribute6	   		cn_quota_pay_elements.attribute6%TYPE;
   l_attribute7	   		cn_quota_pay_elements.attribute7%TYPE;
   l_attribute8			cn_quota_pay_elements.attribute8%TYPE;
   l_attribute9			cn_quota_pay_elements.attribute9%TYPE;
   l_attribute10		cn_quota_pay_elements.attribute10%TYPE;
   l_attribute11		cn_quota_pay_elements.attribute11%TYPE;
   l_attribute12		cn_quota_pay_elements.attribute12%TYPE;
   l_attribute13		cn_quota_pay_elements.attribute13%TYPE;
   l_attribute14		cn_quota_pay_elements.attribute14%TYPE;
   l_attribute15		cn_quota_pay_elements.attribute15%TYPE;

   CURSOR C IS
	  SELECT *
	    FROM cn_quota_pay_elements
	    WHERE quota_pay_element_id = p_quota_pay_element_id
	    FOR UPDATE of quota_pay_element_id NOWAIT;
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

   SELECT
      decode(p_quota_id,
	     fnd_api.g_miss_num, oldrow.quota_id,
	     p_quota_id),
      decode(p_pay_element_type_id,
	     fnd_api.g_miss_num, oldrow.pay_element_type_id,
	     p_pay_element_type_id),
      decode(p_status,
	     fnd_api.g_miss_char, oldrow.status,
	     p_status),
      decode(p_start_date,
	     fnd_api.g_miss_date, oldrow.start_date,
	     p_start_date),
      decode(p_end_date,
	     fnd_api.g_miss_date, oldrow.end_date,
	     p_end_date),
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
      l_quota_id,
      l_pay_element_type_id,
      l_status,
      l_start_date,
      l_end_date,
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

    UPDATE cn_quota_pay_elements
      SET
      quota_id                  =       l_quota_id,
      pay_element_type_id       =       l_pay_element_type_id,
      status                    =       l_status,
      start_date		=	l_start_date,
      end_date		        =	l_end_date,
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
      WHERE quota_pay_element_id=       p_quota_pay_element_id;

     IF (SQL%NOTFOUND) THEN
        RAISE NO_DATA_FOUND;
     END IF;

  END Update_row;

-- ==========================================================================
  -- Procedure Name
  --	Delete_row
  -- Purpose
  --    Delete the Quota pay element
-- ==========================================================================

  PROCEDURE Delete_row( p_quota_pay_element_id     NUMBER ) IS
  BEGIN

     DELETE FROM cn_quota_pay_elements
       WHERE  quota_pay_element_id = p_quota_pay_element_id ;
     IF (SQL%NOTFOUND) THEN
	RAISE NO_DATA_FOUND;
     END IF;

  END Delete_row;

END CN_QUOTA_PAY_ELEMENTS_PKG;

/
