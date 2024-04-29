--------------------------------------------------------
--  DDL for Package Body CN_SRP_PAY_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SRP_PAY_GROUPS_PKG" as
-- $Header: cnpgratb.pls 120.1 2005/08/25 02:16:19 sjustina noship $


--PRIVATE VARIABLES
g_temp_status_code VARCHAR2(30) := NULL;


-- Procedure : get_UID
--
-- Purpose   : Get the Sequence Number to Create a new Pay Group.

PROCEDURE Get_UID( X_srp_pay_group_id     IN OUT NOCOPY NUMBER) IS
BEGIN

   SELECT cn_srp_pay_groups_s.nextval
     INTO X_srp_pay_group_id
     FROM dual;

END Get_UID;


  -- Procedure : Insert_Record
  --
  -- Purpose   : Procedure to create an salesrep assignment to a pay group

  PROCEDURE Insert_Record(
			x_srp_pay_group_Id        IN OUT NOCOPY NUMBER
                       ,x_salesrep_id		         NUMBER
		       ,x_pay_group_id			 NUMBER
		       ,x_start_date			 DATE
		       ,x_end_date			 DATE
		       ,x_lock_flag			 VARCHAR2
		       ,x_role_pay_group_id	         NUMBER
		       ,x_org_id	                 NUMBER
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
                       ,x_object_version_number IN OUT NOCOPY number) IS

  BEGIN

     IF x_srp_pay_group_id is null
     THEN
        Get_UID( X_srp_pay_group_id );
     END IF;

          INSERT INTO cn_srp_pay_groups_all(
		srp_pay_group_id
               ,salesrep_id
               ,pay_group_id
               ,start_date
               ,end_date
               ,lock_flag
               ,role_pay_group_id
               ,org_id
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
               	x_srp_pay_group_id
               ,x_salesrep_id
               ,x_pay_group_id
               ,x_start_date
               ,x_end_date
               ,x_lock_flag
               ,Decode(x_role_pay_group_id,cn_api.g_miss_num,NULL,x_role_pay_group_id)
	       ,x_org_id
	       ,Decode(x_attribute_category,cn_api.g_miss_char,NULL,x_attribute_category)
               ,Decode(x_attribute1,cn_api.g_miss_char,NULL,x_attribute1)
               ,Decode(x_attribute2,cn_api.g_miss_char,NULL,x_attribute2)
               ,Decode(x_attribute3,cn_api.g_miss_char,NULL,x_attribute3)
               ,Decode(x_attribute4,cn_api.g_miss_char,NULL,x_attribute4)
               ,Decode(x_attribute5,cn_api.g_miss_char,NULL,x_attribute5)
               ,Decode(x_attribute6,cn_api.g_miss_char,NULL,x_attribute6)
               ,Decode(x_attribute7,cn_api.g_miss_char,NULL,x_attribute7)
               ,Decode(x_attribute8,cn_api.g_miss_char,NULL,x_attribute8)
               ,Decode(x_attribute9,cn_api.g_miss_char,NULL,x_attribute9)
               ,Decode(x_attribute10,cn_api.g_miss_char,NULL,x_attribute10)
               ,Decode(x_attribute11,cn_api.g_miss_char,NULL,x_attribute11)
               ,Decode(x_attribute12,cn_api.g_miss_char,NULL,x_attribute12)
               ,Decode(x_attribute13,cn_api.g_miss_char,NULL,x_attribute13)
               ,Decode(x_attribute14,cn_api.g_miss_char,NULL,x_attribute14)
               ,Decode(x_attribute15,cn_api.g_miss_char,NULL,x_attribute15)
               ,x_Created_By
               ,x_Creation_Date
               ,x_Last_Updated_By
               ,x_Last_Update_Date
               ,x_Last_Update_Login
               ,1
             );
             x_object_version_number := 1;

  END Insert_Record;


-- Procedure : Update_Record
--
-- Description : Procedure to update the end_date for the pay group assignment

  PROCEDURE Update_Record(
     x_srp_pay_group_id         NUMBER
    ,x_salesrep_id		NUMBER
    ,x_pay_group_id	        NUMBER
    ,x_start_date		DATE
    ,x_end_date		        DATE
    ,x_lock_flag                VARCHAR2
    ,x_role_pay_group_id        NUMBER
    ,x_org_id                   NUMBER
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
    ,x_object_version_number  IN OUT NOCOPY number) IS

 BEGIN
    UPDATE cn_srp_pay_groups_all
     SET
       	salesrep_id           	=     	x_salesrep_id,
	pay_group_id		= 	x_pay_group_id,
	start_date		=	x_start_date,
	end_date		=	x_end_date,
	lock_flag		=	x_lock_flag,
        role_pay_group_id	=	x_role_pay_group_id,
        org_id                  =       x_org_id,
	attribute_category	=	x_attribute_category,
        attribute1		=       x_attribute1,
        attribute2		=       x_attribute2,
        attribute3		=	x_attribute3,
        attribute4		=	x_attribute4,
        attribute5		=	x_attribute5,
        attribute6		=	x_attribute6,
        attribute7		=	x_attribute7,
        attribute8		=	x_attribute8,
        attribute9		=	x_attribute9,
        attribute10		=	x_attribute10,
        attribute11		=	x_attribute11,
        attribute12		=	x_attribute12,
        attribute13		=	x_attribute13,
        attribute14		=	x_attribute14,
        attribute15		=	x_attribute15,
        last_update_date	=	x_Last_Update_Date,
       	last_updated_by      	=     	x_Last_Updated_By,
	last_update_login    	=     	x_Last_Update_Login,
        object_version_number   =       object_version_number + 1
     WHERE srp_pay_group_id  =     x_srp_pay_group_id ;

     if (SQL%NOTFOUND) then
        Raise NO_DATA_FOUND;
     end if;

     select object_version_number into x_object_version_number
     from cn_srp_pay_groups_all where srp_pay_group_id  = x_srp_pay_group_id;

  END Update_Record;


-- Procedure    : PUBLIC PROGRAM
-- Description  : Main procedure which calls insert/update depending on the
--                value in x_operation
 PROCEDURE Begin_Record(
		        X_Operation		         VARCHAR2
               	       ,X_srp_pay_group_id     	  IN OUT NOCOPY NUMBER
                       ,X_salesrep_id                    NUMBER
		       ,x_pay_group_id			 NUMBER
                       ,X_start_date		         VARCHAR2
                       ,X_end_date	                 VARCHAR2
                       ,X_lock_flag	                 VARCHAR2
		       ,X_role_pay_group_id	         NUMBER
		       ,x_org_id                         NUMBER
                       ,X_attribute_category             VARCHAR2
                       ,X_attribute1                     VARCHAR2
                       ,X_attribute2                     VARCHAR2
                       ,X_attribute3                     VARCHAR2
                       ,X_attribute4                     VARCHAR2
                       ,X_attribute5                     VARCHAR2
                       ,X_attribute6                     VARCHAR2
                       ,X_attribute7                     VARCHAR2
                       ,X_attribute8                     VARCHAR2
                       ,X_attribute9                     VARCHAR2
                       ,X_attribute10                    VARCHAR2
                       ,X_attribute11                    VARCHAR2
                       ,X_attribute12                    VARCHAR2
                       ,X_attribute13                    VARCHAR2
                       ,X_attribute14                    VARCHAR2
                       ,X_attribute15                    VARCHAR2
                       ,X_Created_By                     NUMBER
                       ,X_Creation_Date                  DATE
                       ,X_Last_Updated_By                NUMBER
                       ,X_Last_Update_Date               DATE
                       ,X_Last_Update_Login              NUMBER
                       ,x_object_version_number IN OUT NOCOPY NUMBER) IS

 BEGIN

   --Initialize global variables
   g_temp_status_code 	:= 'COMPLETE'; -- Assume it is good to begin with

   IF X_Operation = 'INSERT' THEN

     Insert_Record(     X_srp_pay_group_id
                       ,X_salesrep_id
		       ,X_pay_group_id
                       ,X_start_date
		       ,X_end_date
		       ,X_lock_flag
		       ,x_role_pay_group_id
		       ,X_org_id
                       ,X_attribute_category
                       ,X_attribute1
                       ,X_attribute2
                       ,X_attribute3
                       ,X_attribute4
                       ,X_attribute5
                       ,X_attribute6
                       ,X_attribute7
                       ,X_attribute8
                       ,X_attribute9
                       ,X_attribute10
                       ,X_attribute11
                       ,X_attribute12
                       ,X_attribute13
                       ,X_attribute14
                       ,X_attribute15
                       ,X_Created_By
                       ,X_Creation_Date
                       ,X_Last_Updated_By
                       ,X_Last_Update_Date
		       ,X_Last_Update_Login
               ,x_object_version_number);

   ELSIF X_Operation = 'UPDATE' THEN

     Update_Record(	X_srp_pay_group_id
                       ,X_salesrep_id
		       ,X_pay_group_id
                       ,X_start_date
		       ,X_end_date
		       ,X_lock_flag
		       ,x_role_pay_group_id
		       ,x_org_id
                       ,X_attribute_category
                       ,X_attribute1
                       ,X_attribute2
                       ,X_attribute3
                       ,X_attribute4
                       ,X_attribute5
                       ,X_attribute6
                       ,X_attribute7
                       ,X_attribute8
                       ,X_attribute9
                       ,X_attribute10
                       ,X_attribute11
                       ,X_attribute12
                       ,X_attribute13
                       ,X_attribute14
                       ,X_attribute15
                       ,X_Last_Updated_By
                       ,X_Last_Update_Date
		       ,X_Last_Update_Login
               ,x_object_version_number);

    END IF;

 END Begin_Record;

END CN_SRP_PAY_GROUPS_PKG;

/
