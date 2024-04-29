--------------------------------------------------------
--  DDL for Package Body CN_PMT_PLANS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PMT_PLANS_PKG" as
-- $Header: cnpplntb.pls 120.2 2005/10/06 00:38:29 raramasa ship $


  g_temp_status_code VARCHAR2(30) := NULL;
  g_program_type     VARCHAR2(30) := NULL;

--*****************************************************************************
  -- Procedure Name : Get_UID
  -- Purpose        : Get the Sequence Number to Create a new Payment Plan.
--*****************************************************************************

 PROCEDURE Get_UID( X_pmt_plan_id     IN OUT NOCOPY NUMBER) IS

 BEGIN

    SELECT cn_pmt_plans_s.nextval
      INTO   X_pmt_plan_id
      FROM   sys.dual;

 END Get_UID;


--*****************************************************************************
  -- Procedure Name : Insert_Record
  -- Purpose        : Main insert procedure
--*****************************************************************************

  PROCEDURE Insert_Record(
                        x_Rowid              IN OUT NOCOPY VARCHAR2
                       ,x_org_id                    cn_pmt_plans.org_id%TYPE
                       ,x_pmt_plan_id        IN OUT NOCOPY NUMBER
                       ,x_name		            cn_pmt_plans.name%TYPE
		       ,x_minimum_amount	    cn_pmt_plans.minimum_amount%TYPE
		       ,x_maximum_amount	    cn_pmt_plans.maximum_amount%TYPE
		       ,x_min_rec_flag		    cn_pmt_plans.min_rec_flag%TYPE
                       ,x_max_rec_flag		    cn_pmt_plans.max_rec_flag%TYPE
		       ,x_max_recovery_amount	    cn_pmt_plans.max_recovery_amount%TYPE
		       ,x_credit_type_id	    cn_pmt_plans.credit_type_id%TYPE
                       ,x_pay_interval_type_id      cn_pmt_plans.pay_interval_type_id%TYPE
		       ,x_start_date		    cn_pmt_plans.start_date%TYPE
		       ,x_end_date		    cn_pmt_plans.end_date%TYPE
                       ,x_recoverable_interval_type_id cn_pmt_plans.recoverable_interval_type_id%TYPE
                       ,x_pay_against_commission    cn_pmt_plans.pay_against_commission%TYPE
                       ,x_attribute_category        cn_pmt_plans.attribute_category%TYPE
                       ,x_attribute1                cn_pmt_plans.attribute1%TYPE
                       ,x_attribute2                cn_pmt_plans.attribute2%TYPE
                       ,x_attribute3                cn_pmt_plans.attribute3%TYPE
                       ,x_attribute4                cn_pmt_plans.attribute4%TYPE
                       ,x_attribute5                cn_pmt_plans.attribute5%TYPE
                       ,x_attribute6                cn_pmt_plans.attribute6%TYPE
                       ,x_attribute7                cn_pmt_plans.attribute7%TYPE
                       ,x_attribute8                cn_pmt_plans.attribute8%TYPE
                       ,x_attribute9                cn_pmt_plans.attribute9%TYPE
                       ,x_attribute10               cn_pmt_plans.attribute10%TYPE
                       ,x_attribute11               cn_pmt_plans.attribute11%TYPE
                       ,x_attribute12               cn_pmt_plans.attribute12%TYPE
                       ,x_attribute13               cn_pmt_plans.attribute13%TYPE
                       ,x_attribute14               cn_pmt_plans.attribute14%TYPE
                       ,x_attribute15               cn_pmt_plans.attribute15%TYPE
                       ,x_Created_By                cn_pmt_plans.created_by%TYPE
                       ,x_Creation_Date             cn_pmt_plans.creation_date%TYPE
                       ,x_Last_Updated_By           cn_pmt_plans.last_updated_by%TYPE
                       ,x_Last_Update_Date          cn_pmt_plans.last_update_date%TYPE
                       ,x_Last_Update_Login         cn_pmt_plans.last_update_login%TYPE
                       ,x_Payment_Group_Code        cn_pmt_plans.payment_group_code%TYPE
                       ,x_object_version_number     IN OUT NOCOPY cn_pmt_plans.object_version_number%TYPE
                       )
    IS

  BEGIN

     IF x_pmt_plan_id is null
     THEN
        Get_UID( X_pmt_plan_id );
     END IF;

            x_object_version_number := 1;

          INSERT INTO cn_pmt_plans(
                    org_id
				   ,pmt_plan_id
				   ,name
				   ,minimum_amount
				   ,maximum_amount
				   ,min_rec_flag
				   ,max_rec_flag
				   ,max_recovery_amount
				   ,credit_type_id
				   ,pay_interval_type_id
				   ,start_date
				   ,end_date
                                   ,object_version_number
                                   ,recoverable_interval_type_id
                                   ,pay_against_commission
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
				   ,payment_group_code)
            VALUES (
            x_org_id
		    ,x_pmt_plan_id
		    ,x_name
		    ,x_minimum_amount
		    ,x_maximum_amount
		    ,x_min_rec_flag
		    ,x_max_rec_flag
		    ,x_max_recovery_amount
 		    ,x_credit_type_id
		    ,x_pay_interval_type_id
		    ,x_start_date
		    ,x_end_date
                    ,x_object_version_number
                    ,x_recoverable_interval_type_id
                    ,x_pay_against_commission
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
		    ,x_Payment_Group_Code
		    );

  END Insert_Record;


--*****************************************************************************
  -- Procedure Name : Lock_Record
  -- Purpose        : Lock db row after form record is changed
  -- Notes          : Only called from the form
--*****************************************************************************

  PROCEDURE Lock_Record( x_Rowid                VARCHAR2
                        ,x_pmt_plan_id         NUMBER) IS

     CURSOR C IS
        SELECT *
          FROM cn_pmt_plans
         WHERE pmt_plan_id = x_pmt_plan_id
           FOR UPDATE of pmt_plan_id NOWAIT;
     Recinfo C%ROWTYPE;

  BEGIN
     OPEN C;
     FETCH C INTO Recinfo;

     IF (C%NOTFOUND) then
        CLOSE C;
        fnd_message.Set_Name('FND', 'FORM_RECORD_DELETED');
        app_exception.raise_exception;
     END IF;

     CLOSE C;

     IF Recinfo.pmt_plan_id = x_pmt_plan_id
     THEN
        RETURN;
     ELSE
        fnd_message.Set_Name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
     END IF;
  END Lock_Record;


--*****************************************************************************
  -- Procedure Name : Update Record
  -- Purpose        : To Update the Payment Plans
--*****************************************************************************

  PROCEDURE Update_Record(
    x_org_id                cn_pmt_plans.org_id%TYPE
    ,x_pmt_plan_id          NUMBER
    ,x_name		    cn_pmt_plans.name%TYPE   	          := fnd_api.g_miss_char
    ,x_minimum_amount       cn_pmt_plans.minimum_amount%TYPE      := fnd_api.g_miss_num
    ,x_maximum_amount       cn_pmt_plans.maximum_amount%TYPE      := fnd_api.g_miss_num
    ,x_max_recovery_amount  cn_pmt_plans.max_recovery_amount%TYPE := fnd_api.g_miss_num
    ,x_min_rec_flag	    cn_pmt_plans.min_rec_flag%TYPE        := fnd_api.g_miss_char
    ,x_max_rec_flag	    cn_pmt_plans.max_rec_flag%TYPE        := fnd_api.g_miss_char
    ,x_credit_type_id       cn_pmt_plans.credit_type_id%TYPE      := cn_api.g_miss_id
    ,x_pay_interval_type_id cn_pmt_plans.pay_interval_type_id%TYPE := cn_api.g_miss_id
    ,x_start_date	    cn_pmt_plans.start_date%TYPE	  := fnd_api.g_miss_date
    ,x_end_date		    cn_pmt_plans.end_date%TYPE 		  := fnd_api.g_miss_date
    ,x_object_version_number IN OUT NOCOPY cn_pmt_plans.object_version_number%TYPE
    ,x_recoverable_interval_type_id cn_pmt_plans.recoverable_interval_type_id%TYPE := fnd_api.g_miss_char
    ,x_pay_against_commission    cn_pmt_plans.pay_against_commission%TYPE := fnd_api.g_miss_char
    ,x_attribute_category   cn_pmt_plans.attribute_category%TYPE  := fnd_api.g_miss_char
    ,x_attribute1           cn_pmt_plans.attribute1%TYPE          := fnd_api.g_miss_char
    ,x_attribute2           cn_pmt_plans.attribute2%TYPE          := fnd_api.g_miss_char
    ,x_attribute3           cn_pmt_plans.attribute3%TYPE          := fnd_api.g_miss_char
    ,x_attribute4           cn_pmt_plans.attribute4%TYPE          := fnd_api.g_miss_char
    ,x_attribute5           cn_pmt_plans.attribute5%TYPE          := fnd_api.g_miss_char
    ,x_attribute6           cn_pmt_plans.attribute6%TYPE          := fnd_api.g_miss_char
    ,x_attribute7           cn_pmt_plans.attribute7%TYPE          := fnd_api.g_miss_char
    ,x_attribute8           cn_pmt_plans.attribute8%TYPE          := fnd_api.g_miss_char
    ,x_attribute9           cn_pmt_plans.attribute9%TYPE          := fnd_api.g_miss_char
    ,x_attribute10          cn_pmt_plans.attribute10%TYPE         := fnd_api.g_miss_char
    ,x_attribute11          cn_pmt_plans.attribute11%TYPE         := fnd_api.g_miss_char
    ,x_attribute12          cn_pmt_plans.attribute12%TYPE         := fnd_api.g_miss_char
    ,x_attribute13          cn_pmt_plans.attribute13%TYPE         := fnd_api.g_miss_char
    ,x_attribute14          cn_pmt_plans.attribute14%TYPE         := fnd_api.g_miss_char
    ,x_attribute15          cn_pmt_plans.attribute15%TYPE         := fnd_api.g_miss_char
    ,x_Last_Updated_By      cn_pmt_plans.last_updated_by%TYPE
    ,x_Last_Update_Date     cn_pmt_plans.last_update_date%TYPE
    ,x_Last_Update_Login    cn_pmt_plans.last_update_login%TYPE
    ,x_Payment_Group_Code   cn_pmt_plans.payment_group_code%TYPE  := fnd_api.g_miss_char
    ) IS

    l_org_id        cn_pmt_plans.org_id%TYPE;
   l_name			cn_pmt_plans.name%TYPE;
   l_minimum_amount 		cn_pmt_plans.minimum_amount%TYPE;
   l_maximum_amount		cn_pmt_plans.maximum_amount%TYPE;
   l_min_rec_flag		cn_pmt_plans.min_rec_flag%TYPE;
   l_max_rec_flag		cn_pmt_plans.max_rec_flag%TYPE;
   l_max_recovery_amount	cn_pmt_plans.max_recovery_amount%TYPE;
   l_credit_type_id		cn_pmt_plans.credit_type_id%TYPE;
   l_pay_interval_type_id       cn_pmt_plans.pay_interval_type_id%TYPE;
   l_start_date			cn_pmt_plans.start_date%TYPE;
   l_end_date			cn_pmt_plans.end_date%TYPE;
   l_recoverable_interval_type_id  cn_pmt_plans.recoverable_interval_type_id%TYPE;
   l_pay_against_commission     cn_pmt_plans.pay_against_commission%TYPE;
   l_payment_group_code         cn_pmt_plans.payment_group_code%TYPE;

   l_attribute_category		cn_pmt_plans.attribute_category%TYPE;
   l_attribute1			cn_pmt_plans.attribute1%TYPE;
   l_attribute2			cn_pmt_plans.attribute2%TYPE;
   l_attribute3	    		cn_pmt_plans.attribute3%TYPE;
   l_attribute4	    		cn_pmt_plans.attribute4%TYPE;
   l_attribute5	    		cn_pmt_plans.attribute5%TYPE;
   l_attribute6	   		cn_pmt_plans.attribute6%TYPE;
   l_attribute7	   		cn_pmt_plans.attribute7%TYPE;
   l_attribute8			cn_pmt_plans.attribute8%TYPE;
   l_attribute9			cn_pmt_plans.attribute9%TYPE;
   l_attribute10		cn_pmt_plans.attribute10%TYPE;
   l_attribute11		cn_pmt_plans.attribute11%TYPE;
   l_attribute12		cn_pmt_plans.attribute12%TYPE;
   l_attribute13		cn_pmt_plans.attribute13%TYPE;
   l_attribute14		cn_pmt_plans.attribute14%TYPE;
   l_attribute15		cn_pmt_plans.attribute15%TYPE;

    CURSOR pmt_plan_cur IS
       SELECT *
	 FROM cn_pmt_plans
        WHERE pmt_plan_id = x_pmt_plan_id;

    l_pmt_plan_rec pmt_plan_cur%ROWTYPE;

 BEGIN
    OPEN pmt_plan_cur;
    FETCH pmt_plan_cur INTO l_pmt_plan_rec;
    CLOSE pmt_plan_cur;

    SELECT decode(x_name,
                  fnd_api.g_miss_char, l_pmt_plan_rec.name,
		  x_name),
	   decode(x_minimum_amount,
                  fnd_api.g_miss_num, l_pmt_plan_rec.minimum_amount,
		  x_minimum_amount),
	   decode(x_maximum_amount,
                  fnd_api.g_miss_num, l_pmt_plan_rec.maximum_amount,
		  x_maximum_amount),
	   decode(x_min_rec_flag,
                  fnd_api.g_miss_char, l_pmt_plan_rec.min_rec_flag,
		  x_min_rec_flag),
	   decode(x_max_rec_flag,
                  fnd_api.g_miss_char, l_pmt_plan_rec.max_rec_flag,
		  x_max_rec_flag),
	   decode(x_max_recovery_amount,
                  fnd_api.g_miss_num, l_pmt_plan_rec.max_recovery_amount,
		  x_max_recovery_amount),
	   decode(x_credit_type_id,
                  cn_api.g_miss_id, l_pmt_plan_rec.credit_type_id,
		  x_credit_type_id),
	   decode(x_pay_interval_type_id,
                  cn_api.g_miss_id, l_pmt_plan_rec.pay_interval_type_id,
		  x_pay_interval_type_id),
	   decode(x_start_date,
                  fnd_api.g_miss_date, l_pmt_plan_rec.start_date,
		  x_start_date),
	   decode(x_end_date,
                  fnd_api.g_miss_date, l_pmt_plan_rec.end_date,
		  x_end_date),
           decode(x_recoverable_interval_type_id,
                  fnd_api.g_miss_char, l_pmt_plan_rec.recoverable_interval_type_id,
		  x_recoverable_interval_type_id),
           decode(x_pay_against_commission,
                  fnd_api.g_miss_char, l_pmt_plan_rec.pay_against_commission,
		  x_pay_against_commission),
	   decode(x_attribute_category,
                  fnd_api.g_miss_char, l_pmt_plan_rec.attribute_category,
		  x_attribute_category),
	   decode(x_attribute1,
                  fnd_api.g_miss_char, l_pmt_plan_rec.attribute1,
		  x_attribute1),
	   decode(x_attribute2,
                  fnd_api.g_miss_char, l_pmt_plan_rec.attribute2,
		  x_attribute2),
	   decode(x_attribute3,
                  fnd_api.g_miss_char, l_pmt_plan_rec.attribute3,
		  x_attribute3),
	   decode(x_attribute4,
                  fnd_api.g_miss_char, l_pmt_plan_rec.attribute4,
		  x_attribute4),
	   decode(x_attribute5,
                  fnd_api.g_miss_char, l_pmt_plan_rec.attribute5,
		  x_attribute5),
	   decode(x_attribute6,
                  fnd_api.g_miss_char, l_pmt_plan_rec.attribute6,
		  x_attribute6),
	   decode(x_attribute7,
                  fnd_api.g_miss_char, l_pmt_plan_rec.attribute7,
		  x_attribute7),
	   decode(x_attribute8,
                  fnd_api.g_miss_char, l_pmt_plan_rec.attribute8,
		  x_attribute8),
	   decode(x_attribute9,
                  fnd_api.g_miss_char, l_pmt_plan_rec.attribute9,
		  x_attribute9),
	   decode(x_attribute10,
                  fnd_api.g_miss_char, l_pmt_plan_rec.attribute10,
		  x_attribute10),
	   decode(x_attribute11,
                  fnd_api.g_miss_char, l_pmt_plan_rec.attribute11,
		  x_attribute11),
	   decode(x_attribute12,
                  fnd_api.g_miss_char, l_pmt_plan_rec.attribute12,
		  x_attribute12),
	   decode(x_attribute13,
                  fnd_api.g_miss_char, l_pmt_plan_rec.attribute13,
		  x_attribute13),
	   decode(x_attribute14,
                  fnd_api.g_miss_char, l_pmt_plan_rec.attribute14,
		  x_attribute14),
	   decode(x_attribute15,
                  fnd_api.g_miss_char, l_pmt_plan_rec.attribute15,
		  x_attribute15),
	   decode(x_payment_group_code,
		  fnd_api.g_miss_char, l_pmt_plan_rec.payment_group_code,
		  x_payment_group_code)
    INTO l_name,
     l_minimum_amount,
	 l_maximum_amount,
	 l_min_rec_flag,
	 l_max_rec_flag,
	 l_max_recovery_amount,
     l_credit_type_id,
     l_pay_interval_type_id,
     l_start_date,
     l_end_date,
	 l_recoverable_interval_type_id,
     l_pay_against_commission,
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
	 l_payment_group_code
    FROM dual;

    UPDATE cn_pmt_plans
     SET
       	name              	=   l_name,
        minimum_amount		=	l_minimum_amount,
        maximum_amount		=	l_maximum_amount,
        min_rec_flag		= 	Nvl(l_min_rec_flag,'N'),
	    max_rec_flag		=	Nvl(l_max_rec_flag,'N'),
        max_recovery_amount =   l_max_recovery_amount,
        credit_type_id		=	l_credit_type_id,
        pay_interval_type_id = l_pay_interval_type_id,
        start_date		=	l_start_date,
    	end_date		=	l_end_date,
        object_version_number   =  x_object_version_number + 1,
	    recoverable_interval_type_id =  l_recoverable_interval_type_id,
        pay_against_commission =       l_pay_against_commission,
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
        last_update_date	=	x_Last_Update_Date,
       	last_updated_by      	=     	x_Last_Updated_By,
	last_update_login    	=     	x_Last_Update_Login,
	payment_group_code      =       l_payment_group_code

     WHERE pmt_plan_id  =     x_pmt_plan_id ;

     if (SQL%NOTFOUND) then
        Raise NO_DATA_FOUND;
     end if;

     x_object_version_number := x_object_version_number + 1;

  END Update_Record;


--*****************************************************************************
  -- Procedure Name : Delete_Record
  -- Purpose        : Delete the Payment Plan if it has not been assigned
  --                  to a salesrep
--*****************************************************************************

  PROCEDURE Delete_Record( x_pmt_plan_id     NUMBER ) IS
  BEGIN

        DELETE FROM cn_pmt_plans
        WHERE  pmt_plan_id = x_pmt_plan_id;


  END Delete_Record;


--*****************************************************************************
 -- Procedure Name : Begin_Record
 -- Purpose	   : Public procedure which calls the appropriate pvt.
 --		     depending on the value of X_Operation
 -- History        : Modified by Sundar Venkat
 --		     Added New Column
 --		     PAYMENT_GROUP_CODE
--*****************************************************************************

  PROCEDURE Begin_Record(
		        x_Operation		    VARCHAR2
		       ,x_Rowid              IN OUT NOCOPY VARCHAR2
        		       ,x_org_id                    cn_pmt_plans.org_id%TYPE
               	       ,x_pmt_plan_id        IN OUT NOCOPY NUMBER
                       ,x_name              	   cn_pmt_plans.name%TYPE
                       ,x_minimum_amount           cn_pmt_plans.minimum_amount%TYPE
                       ,x_maximum_amount	   cn_pmt_plans.maximum_amount%TYPE
                       ,x_min_rec_flag	           cn_pmt_plans.min_rec_flag%TYPE
                       ,x_max_rec_flag		   cn_pmt_plans.max_rec_flag%TYPE
		       ,x_max_recovery_amount	   cn_pmt_plans.max_recovery_amount%TYPE
		       ,x_credit_type_id	   cn_pmt_plans.credit_type_id%TYPE
		       ,x_pay_interval_type_id     cn_pmt_plans.pay_interval_type_id%TYPE
                       ,x_start_date		   cn_pmt_plans.start_date%TYPE
                       ,x_end_date		   cn_pmt_plans.end_date%TYPE
                       ,x_object_version_number    IN OUT NOCOPY
                       cn_pmt_plans.object_version_number%TYPE
	               ,x_recoverable_interval_type_id cn_pmt_plans.recoverable_interval_type_id%TYPE
                       ,x_pay_against_commission   cn_pmt_plans.pay_against_commission%TYPE
                       ,x_attribute_category       cn_pmt_plans.attribute_category%TYPE
                       ,x_attribute1               cn_pmt_plans.attribute1%TYPE
                       ,x_attribute2               cn_pmt_plans.attribute2%TYPE
                       ,x_attribute3               cn_pmt_plans.attribute3%TYPE
                       ,x_attribute4               cn_pmt_plans.attribute4%TYPE
                       ,x_attribute5               cn_pmt_plans.attribute5%TYPE
                       ,x_attribute6               cn_pmt_plans.attribute6%TYPE
                       ,x_attribute7               cn_pmt_plans.attribute7%TYPE
                       ,x_attribute8               cn_pmt_plans.attribute8%TYPE
                       ,x_attribute9               cn_pmt_plans.attribute9%TYPE
                       ,x_attribute10              cn_pmt_plans.attribute10%TYPE
                       ,x_attribute11              cn_pmt_plans.attribute11%TYPE
                       ,x_attribute12              cn_pmt_plans.attribute12%TYPE
                       ,x_attribute13              cn_pmt_plans.attribute13%TYPE
                       ,x_attribute14              cn_pmt_plans.attribute14%TYPE
                       ,x_attribute15              cn_pmt_plans.attribute15%TYPE
                       ,x_Created_By               cn_pmt_plans.created_by%TYPE
                       ,x_Creation_Date            cn_pmt_plans.creation_date%TYPE
                       ,x_Last_Updated_By          cn_pmt_plans.last_updated_by%TYPE
                       ,x_Last_Update_Date         cn_pmt_plans.last_update_date%TYPE
                       ,x_Last_Update_Login        cn_pmt_plans.last_update_login%TYPE
		       ,x_Program_Type		   VARCHAR2
		       ,x_Payment_Group_Code       cn_pmt_plans.payment_group_code%TYPE
		       ) IS

BEGIN

   -- Saves passing it around
   g_program_type 	:= x_program_type;
   g_temp_status_code 	:= 'COMPLETE'; -- Assume it is good to begin with


   IF X_Operation = 'INSERT' THEN

     Insert_Record(     X_Rowid
                       ,X_org_id
                       ,X_pmt_plan_id
                       ,X_name
		       ,X_minimum_amount
		       ,X_maximum_amount
		       ,X_min_rec_flag
   		       ,X_max_rec_flag
                       ,X_max_recovery_amount
		       ,X_credit_type_id
		       ,X_pay_interval_type_id
                       ,X_start_date
		       ,X_end_date
	               ,x_recoverable_interval_type_id
                       ,x_pay_against_commission
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
		       ,x_Payment_Group_Code
		       ,x_object_version_number
		       );


    ELSIF X_Operation = 'UPDATE' THEN


      Update_Record(	x_org_id
                        ,x_pmt_plan_id
                       ,X_name
		       ,X_minimum_amount
		       ,X_maximum_amount
		       ,X_max_recovery_amount
		       ,X_min_rec_flag
   		       ,X_max_rec_flag
		       ,X_credit_type_id
		       ,X_pay_interval_type_id
                       ,X_start_date
		       ,X_end_date
                       ,X_object_version_number
                       ,x_recoverable_interval_type_id
                       ,x_pay_against_commission
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
		       ,x_Payment_Group_Code
		       );

    ELSIF X_Operation = 'DELETE' THEN

       Delete_Record(	X_pmt_plan_id );

    ELSIF X_Operation = 'LOCK' THEN

       Lock_Record( 	X_Rowid
              	       ,X_pmt_plan_id);

    END IF;


 END Begin_Record;

END CN_PMT_PLANS_PKG;

/
