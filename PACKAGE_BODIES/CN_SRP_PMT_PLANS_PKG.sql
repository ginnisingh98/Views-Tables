--------------------------------------------------------
--  DDL for Package Body CN_SRP_PMT_PLANS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SRP_PMT_PLANS_PKG" AS
/* $Header: cntsppb.pls 120.1 2005/06/16 15:06:08 appldev  $ */
--
-- Package Name
-- CN_SRP_PMT_PLANS_PKG
-- Purpose
--  Table Handler for CN_SRP_PMT_PLANS
--  FORM 	CNSRMT
--  BLOCK	SRP_PMT_PLAN
--
-- History
-- 26-May-99	Angela Chung	Created
-- 01-AUG-01    Kumar Sivankaran  Added Object_version Number
/*-------------------------------------------------------------------------*
 |
 |                             PRIVATE ROUTINES
 |
 *-------------------------------------------------------------------------*/

 /*-----------------------------------------------------------------------*
  |                             Custom Validation
  *-----------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
  -- Procedure Name
  --	Get_UID
  -- Purpose
  --    Get the Sequence Number to Create a new Srp Payment Plan.
 *-------------------------------------------------------------------------*/
 PROCEDURE Get_UID( X_srp_pmt_plan_id     IN OUT NOCOPY NUMBER) IS

 BEGIN

    SELECT cn_srp_pmt_plans_s.nextval
      INTO   X_srp_pmt_plan_id
      FROM   dual;

 END Get_UID;

/*-------------------------------------------------------------------------*
  -- Procedure Name
  --	Insert_row
  -- Purpose
  --    Main insert procedure
 *-------------------------------------------------------------------------*/
   PROCEDURE insert_row
   (x_srp_pmt_plan_id        	      IN OUT NOCOPY NUMBER
    ,x_pmt_plan_id                    IN NUMBER
    ,x_salesrep_id                    IN NUMBER
    ,x_org_id                         IN NUMBER
    ,x_role_id                        IN NUMBER
    ,x_credit_type_id                 IN NUMBER
    ,x_start_date		      DATE
    ,x_end_date	                      DATE
    ,x_minimum_amount                 IN NUMBER
    ,x_maximum_amount                 IN NUMBER
    ,x_max_recovery_amount            IN NUMBER
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
    ,x_Last_Update_Login              NUMBER
    ,x_srp_role_id                    NUMBER
    ,x_role_pmt_plan_id               NUMBER
    ,x_lock_flag                      VARCHAR2)
   IS
      l_dummy NUMBER;

   BEGIN

      Get_UID( x_srp_pmt_plan_id );

     INSERT INTO cn_srp_pmt_plans
       (srp_pmt_plan_id
	,pmt_plan_id
	,salesrep_id
	,org_id
	,role_id
	,credit_type_id
	,start_date
	,end_date
	,minimum_amount
	,maximum_amount
	,max_recovery_amount
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
        ,object_version_number
        ,srp_role_id
        ,role_pmt_plan_id
        ,lock_flag)
       VALUES
       (x_srp_pmt_plan_id
	,x_pmt_plan_id
	,x_salesrep_id
	,x_org_id
	,x_role_id
	,x_credit_type_id
	,x_start_date
	,x_end_date
	,x_minimum_amount
	,x_maximum_amount
	,x_max_recovery_amount
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
        ,x_srp_role_id
        ,x_role_pmt_plan_id
        ,NVL(x_lock_flag, 'N')
	);

     select 1 INTO l_dummy  from CN_SRP_PMT_PLANS
       where SRP_PMT_PLAN_ID = x_srp_pmt_plan_id;

   END Insert_row;

/*-------------------------------------------------------------------------*
  -- Procedure Name
  --	Lock_row
  -- Purpose
  --    Lock db row after form record is changed
  -- Notes
  --    Only called from the form
 *-------------------------------------------------------------------------*/
   PROCEDURE lock_row
   ( x_srp_pmt_plan_id          NUMBER
     ,x_pmt_plan_id             NUMBER
     ,x_salesrep_id             NUMBER
     ,x_org_id                  NUMBER
     ,x_role_id                 NUMBER
     ,x_credit_type_id          NUMBER
     ,x_start_date		DATE
     ,x_end_date		DATE
     ,x_minimum_amount           NUMBER
     ,x_maximum_amount           NUMBER
     ,x_max_recovery_amount      NUMBER
     ,x_attribute_category       VARCHAR2	:= NULL
     ,x_attribute1               VARCHAR2	:= NULL
     ,x_attribute2               VARCHAR2	:= NULL
     ,x_attribute3               VARCHAR2	:= NULL
     ,x_attribute4               VARCHAR2	:= NULL
     ,x_attribute5               VARCHAR2	:= NULL
     ,x_attribute6               VARCHAR2	:= NULL
     ,x_attribute7               VARCHAR2	:= NULL
     ,x_attribute8               VARCHAR2       := NULL
     ,x_attribute9               VARCHAR2	:= NULL
     ,x_attribute10              VARCHAR2	:= NULL
     ,x_attribute11              VARCHAR2	:= NULL
     ,x_attribute12              VARCHAR2	:= NULL
   ,x_attribute13              VARCHAR2	:= NULL
   ,x_attribute14              VARCHAR2	:= NULL
   ,x_attribute15              VARCHAR2	:= NULL
   ) IS

     CURSOR C IS
        SELECT *
          FROM cn_srp_pmt_plans
         WHERE srp_pmt_plan_id = x_srp_pmt_plan_id
           FOR UPDATE of srp_pmt_plan_id NOWAIT;
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

     IF (     ((tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
               OR ((tlinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
          AND ((tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
               OR ((tlinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
          AND ((tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
               OR ((tlinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
          AND ((tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
               OR ((tlinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
          AND ((tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
               OR ((tlinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
          AND ((tlinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
               OR ((tlinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
          AND ((tlinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
               OR ((tlinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
          AND ((tlinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
               OR ((tlinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
          AND ((tlinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
               OR ((tlinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
          AND ((tlinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
               OR ((tlinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
          AND ((tlinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
               OR ((tlinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
          AND ((tlinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
               OR ((tlinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
          AND ((tlinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
               OR ((tlinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
          AND ((tlinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
               OR ((tlinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
          AND ((tlinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
               OR ((tlinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
          AND ((tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
               OR ((tlinfo.ATTRIBUTE_CATEGORY is null) AND
		   (X_ATTRIBUTE_CATEGORY is null)))
          AND (tlinfo.START_DATE = X_START_DATE)
          AND ((tlinfo.END_DATE = X_END_DATE)
               OR ((tlinfo.END_DATE is null) AND (X_END_DATE is null)))
          AND ((tlinfo.MINIMUM_AMOUNT = X_MINIMUM_AMOUNT)
               OR ((tlinfo.MINIMUM_AMOUNT is null) AND
		   (X_MINIMUM_AMOUNT is null)))
          AND ((tlinfo.MAXIMUM_AMOUNT = X_MAXIMUM_AMOUNT)
               OR ((tlinfo.MAXIMUM_AMOUNT is null) AND
		   (X_MAXIMUM_AMOUNT is null)))
          AND ((tlinfo.MAX_RECOVERY_AMOUNT = X_MAX_RECOVERY_AMOUNT )
               OR ((tlinfo.MAX_RECOVERY_AMOUNT is null) AND
		   (X_MAX_RECOVERY_AMOUNT is null)))
          AND (tlinfo.PMT_PLAN_ID = X_PMT_PLAN_ID)
          AND (tlinfo.SALESREP_ID = X_SALESREP_ID)
          AND (tlinfo.ORG_ID = X_ORG_ID)
	  AND (tlinfo.ROLE_ID = X_ROLE_ID)
          AND (tlinfo.CREDIT_TYPE_ID = X_CREDIT_TYPE_ID)
      )
     THEN
        RETURN;
     ELSE
        fnd_message.Set_Name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
     END IF;

  END Lock_row;

/*-------------------------------------------------------------------------*
  -- Procedure Name
  --   Update Record
  -- Purpose
  --   To Update the Srp Payment Plan Assign
  --
 *-------------------------------------------------------------------------*/
PROCEDURE update_row
   (x_srp_pmt_plan_id        	NUMBER
    ,x_pmt_plan_id              NUMBER
    ,x_salesrep_id              NUMBER
    ,x_org_id                   NUMBER
    ,x_role_id                  NUMBER
    ,x_credit_type_id           NUMBER
    ,x_start_date		DATE
    ,x_end_date		        DATE
    ,x_minimum_amount           NUMBER
    ,x_maximum_amount           NUMBER
    ,x_max_recovery_amount      NUMBER
    ,x_attribute_category       VARCHAR2
    ,x_attribute1               VARCHAR2
    ,x_attribute2               VARCHAR2
    ,x_attribute3               VARCHAR2
    ,x_attribute4               VARCHAR2
    ,x_attribute5               VARCHAR2
    ,x_attribute6               VARCHAR2
    ,x_attribute7               VARCHAR2
    ,x_attribute8               VARCHAR2
    ,x_attribute9               VARCHAR2
    ,x_attribute10              VARCHAR2
    ,x_attribute11              VARCHAR2
    ,x_attribute12              VARCHAR2
    ,x_attribute13              VARCHAR2
    ,x_attribute14              VARCHAR2
    ,x_attribute15              VARCHAR2
    ,x_Last_Updated_By          NUMBER
    ,x_Last_Update_Date         DATE
    ,x_Last_Update_Login        NUMBER
    ,x_object_version_number    NUMBER
    ,x_lock_flag 		VARCHAR2  ) IS

   l_pmt_plan_id		cn_srp_pmt_plans.pmt_plan_id%TYPE;
   l_salesrep_id		cn_srp_pmt_plans.salesrep_id%TYPE;
   l_org_id  		        cn_srp_pmt_plans.org_id%TYPE;
   l_role_id 		        cn_srp_pmt_plans.role_id%TYPE;
   l_credit_type_id	        cn_srp_pmt_plans.credit_type_id%TYPE;
   l_start_date			cn_srp_pmt_plans.start_date%TYPE;
   l_end_date			cn_srp_pmt_plans.end_date%TYPE;
   l_minimum_amount           	cn_srp_pmt_plans.minimum_amount%TYPE;
   l_maximum_amount          	cn_srp_pmt_plans.maximum_amount%TYPE;
   l_max_recovery_amount      	cn_srp_pmt_plans.max_recovery_amount%TYPE;
   l_attribute_category		cn_srp_pmt_plans.attribute_category%TYPE;
   l_attribute1			cn_srp_pmt_plans.attribute1%TYPE;
   l_attribute2			cn_srp_pmt_plans.attribute2%TYPE;
   l_attribute3	    		cn_srp_pmt_plans.attribute3%TYPE;
   l_attribute4	    		cn_srp_pmt_plans.attribute4%TYPE;
   l_attribute5	    		cn_srp_pmt_plans.attribute5%TYPE;
   l_attribute6	   		cn_srp_pmt_plans.attribute6%TYPE;
   l_attribute7	   		cn_srp_pmt_plans.attribute7%TYPE;
   l_attribute8			cn_srp_pmt_plans.attribute8%TYPE;
   l_attribute9			cn_srp_pmt_plans.attribute9%TYPE;
   l_attribute10		cn_srp_pmt_plans.attribute10%TYPE;
   l_attribute11		cn_srp_pmt_plans.attribute11%TYPE;
   l_attribute12		cn_srp_pmt_plans.attribute12%TYPE;
   l_attribute13		cn_srp_pmt_plans.attribute13%TYPE;
   l_attribute14		cn_srp_pmt_plans.attribute14%TYPE;
   l_attribute15		cn_srp_pmt_plans.attribute15%TYPE;
   l_lock_flag			cn_srp_pmt_plans.lock_flag%TYPE;

   CURSOR C IS
	  SELECT *
	    FROM cn_srp_pmt_plans
	    WHERE srp_pmt_plan_id = x_srp_pmt_plan_id
	    FOR UPDATE of srp_pmt_plan_id NOWAIT;
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

   -- Update only allowed for start date/end date change
   --    IF oldrow.salesrep_id <> x_salesrep_id OR
   --     oldrow.pmt_plan_id <> x_pmt_plan_id OR
   --     oldrow.credit_type_id <> x_credit_type_id THEN
   --      FND_MESSAGE.Set_Name('CN', 'CN_SRP_PMT_PLAN_UPD_NA');
   --      app_exception.raise_exception;
   --   END IF;

   SELECT
      decode(x_pmt_plan_id,
	     fnd_api.g_miss_num, oldrow.pmt_plan_id,
	     x_pmt_plan_id),
      decode(x_salesrep_id,
	     fnd_api.g_miss_num, oldrow.salesrep_id,
	     x_salesrep_id),
      decode(x_org_id,
	     fnd_api.g_miss_num, oldrow.org_id,
	     x_org_id),
      decode(x_role_id,
	     fnd_api.g_miss_num, oldrow.role_id,
	     x_role_id),
      decode(x_credit_type_id,
	     fnd_api.g_miss_num, oldrow.credit_type_id ,
	     x_credit_type_id),
      decode(x_start_date,
	     fnd_api.g_miss_date, oldrow.start_date,
	     x_start_date),
      decode(x_end_date,
	     fnd_api.g_miss_date, oldrow.end_date,
	     x_end_date),
      decode(x_minimum_amount,
	     fnd_api.g_miss_num, oldrow.minimum_amount,
	     x_minimum_amount),
      decode(x_maximum_amount,
	     fnd_api.g_miss_num, oldrow.maximum_amount,
	     x_maximum_amount),
      decode(x_max_recovery_amount,
	     fnd_api.g_miss_num, oldrow.max_recovery_amount,
	     x_max_recovery_amount),
      decode(x_attribute_category,
	     fnd_api.g_miss_char, oldrow.attribute_category,
	     x_attribute_category),
      decode(x_attribute1,
	     fnd_api.g_miss_char, oldrow.attribute1,
	     x_attribute1),
      decode(x_attribute2,
	     fnd_api.g_miss_char, oldrow.attribute2,
	     x_attribute2),
      decode(x_attribute3,
	     fnd_api.g_miss_char, oldrow.attribute3,
	     x_attribute3),
      decode(x_attribute4,
	     fnd_api.g_miss_char, oldrow.attribute4,
	     x_attribute4),
      decode(x_attribute5,
	     fnd_api.g_miss_char, oldrow.attribute5,
	     x_attribute5),
      decode(x_attribute6,
	     fnd_api.g_miss_char, oldrow.attribute6,
	     x_attribute6),
      decode(x_attribute7,
	     fnd_api.g_miss_char, oldrow.attribute7,
	     x_attribute7),
      decode(x_attribute8,
	     fnd_api.g_miss_char, oldrow.attribute8,
	     x_attribute8),
      decode(x_attribute9,
	     fnd_api.g_miss_char, oldrow.attribute9,
	     x_attribute9),
      decode(x_attribute10,
	     fnd_api.g_miss_char, oldrow.attribute10,
	     x_attribute10),
      decode(x_attribute11,
	     fnd_api.g_miss_char, oldrow.attribute11,
	     x_attribute11),
      decode(x_attribute12,
	     fnd_api.g_miss_char, oldrow.attribute12,
	     x_attribute12),
      decode(x_attribute13,
	     fnd_api.g_miss_char, oldrow.attribute13,
	     x_attribute13),
      decode(x_attribute14,
	     fnd_api.g_miss_char, oldrow.attribute14,
	     x_attribute14),
      decode(x_attribute15,
	     fnd_api.g_miss_char, oldrow.attribute15,
	     x_attribute15),
      decode(x_lock_flag,
	     fnd_api.g_miss_char, oldrow.lock_flag,
	     x_lock_flag)
     INTO
      l_pmt_plan_id,
      l_salesrep_id,
      l_org_id,
      l_role_id,
      l_credit_type_id,
      l_start_date,
      l_end_date,
      l_minimum_amount,
      l_maximum_amount,
      l_max_recovery_amount,
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
      l_attribute15,
      l_lock_flag
      FROM dual;

    UPDATE cn_srp_pmt_plans
      SET
      pmt_plan_id               =       l_pmt_plan_id,
      salesrep_id               =       l_salesrep_id,
      org_id                    =       l_org_id,
      role_id                   =       l_role_id,
      credit_type_id            =       l_credit_type_id,
      start_date		=	l_start_date,
      end_date		        =	l_end_date,
      minimum_amount	        =       l_minimum_amount,
      maximum_amount	        =       l_maximum_amount,
      max_recovery_amount	=       l_max_recovery_amount,
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
      last_update_date	        =	x_Last_Update_Date,
      last_updated_by      	=     	x_Last_Updated_By,
      last_update_login    	=     	x_Last_Update_Login,
      object_version_number     =       nvl(X_OBJECT_VERSION_NUMBER,0) + 1,
      lock_flag 		=       l_lock_flag

      WHERE srp_pmt_plan_id  =   x_srp_pmt_plan_id ;

     IF (SQL%NOTFOUND) THEN
        RAISE NO_DATA_FOUND;
     END IF;

  END Update_row;

/*-------------------------------------------------------------------------*
  -- Procedure Name
  --	Delete_row
  -- Purpose
  --    Delete the Srp Payment Plan Assign
 *-------------------------------------------------------------------------*/
  PROCEDURE Delete_row( x_srp_pmt_plan_id     NUMBER ) IS
  BEGIN

     DELETE FROM cn_srp_pmt_plans
       WHERE  srp_pmt_plan_id = x_srp_pmt_plan_id;
     IF (SQL%NOTFOUND) THEN
	RAISE NO_DATA_FOUND;
     END IF;

  END Delete_row;

END CN_SRP_PMT_PLANS_PKG;

/
