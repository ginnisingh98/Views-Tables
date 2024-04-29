--------------------------------------------------------
--  DDL for Package Body ARP_CRM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CRM_PKG" as
/* $Header: AROCRMB.pls 115.1 99/07/17 00:01:50 porting ship $ */
  PROCEDURE check_unique ( x_cust_receipt_method_id in number,
			   x_receipt_method_id	    in number,
			   x_start_date		    in date,
			   x_end_date		    in date,
			   x_meth_type		    in varchar2,
			   x_id		    	    in number
		          ) is
  overlap_count number;
  begin
  --
  if (x_meth_type = 'CUST' ) then
	--
	SELECT  count(1)
        into    overlap_count
	FROM 	ra_cust_receipt_methods cpm
 	WHERE 	cpm.receipt_method_id 	= x_receipt_method_id
   	AND 	cpm.customer_id 	= x_id
   	AND 	cpm.site_use_id 	is null
   	AND 	((x_cust_receipt_method_id is null) or (cpm.cust_receipt_method_id <>  X_cust_receipt_method_id))
  	AND 	( trunc(x_start_date) BETWEEN cpm.start_date
            		              AND NVL(cpm.end_date, trunc(x_start_date))
		  or
		  cpm.start_date between x_start_date and nvl(x_end_date,cpm.start_date)
		);
  	--
  	if (overlap_count >= 1) then
		fnd_message.set_name('AR','AR_CUST_PAYMETH_OVERLAP');
		app_exception.raise_exception;
	 end if;
  elsif (x_meth_type = 'SITE') then
	--
	SELECT  count(1)
        into    overlap_count
	FROM 	ra_cust_receipt_methods cpm
 	WHERE 	cpm.receipt_method_id 	= x_receipt_method_id
   	AND 	cpm.site_use_id 	= x_id
   	AND 	((x_cust_receipt_method_id is null) or (cpm.cust_receipt_method_id <>  X_cust_receipt_method_id))
  	AND 	( trunc(x_start_date) BETWEEN cpm.start_date
            		              AND NVL(cpm.end_date, trunc(x_start_date))
		or
		cpm.start_date between x_start_date and nvl(x_end_date,cpm.start_date)
		);
	--
	if (overlap_count >= 1) then
		fnd_message.set_name('AR','AR_CUST_PAYMETH_OVERLAP');
		app_exception.raise_exception;
	end if;
  else
	app_exception.invalid_argument('arp_cust_receipt_methods_pkg.check_unique','meth_type',x_meth_type);
  end if;
  --
  end check_unique;

  PROCEDURE check_primary(x_cust_receipt_method_id in number,
			   x_start_date		    in date,
			   x_end_date		    in date,
			   x_meth_type		    in varchar2,
			   x_id			    in number
			  ) is
  primary_count number;
  begin
  if (x_meth_type = 'CUST' ) then
	SELECT 	count(1)
	INTO    primary_count
	FROM 	ra_cust_receipt_methods cpm
 	WHERE 	cpm.primary_flag	= 'Y'
   	AND 	cpm.customer_id 	= x_id
        AND     cpm.site_use_id         is null
   	AND 	((x_cust_receipt_method_id is null) or (cpm.cust_receipt_method_id <>  x_cust_receipt_method_id))
	AND 	( trunc(x_start_date) BETWEEN cpm.start_date
             		 	      AND     NVL(cpm.end_date,TRUNC(x_start_date))
		  OR
		  cpm.start_date between x_start_date and nvl(x_end_date,cpm.start_date)
		);


  	if (primary_count >= 1 ) then
		fnd_message.set_name('AR','AR_CUST_PAYMETH_PRIM_OVERLAP');
		app_exception.raise_exception;
	end if;

  elsif( x_meth_type = 'SITE' ) then
	SELECT 	count(1)
	INTO    primary_count
	FROM 	ra_cust_receipt_methods cpm
 	WHERE 	cpm.primary_flag	= 'Y'
   	AND 	cpm.site_use_id 	= x_id
   	AND 	((x_cust_receipt_method_id is null) or (cpm.cust_receipt_method_id <>  x_cust_receipt_method_id))
	AND 	(trunc(x_start_date) BETWEEN cpm.start_date
             		 	    AND     NVL(cpm.end_date,TRUNC(x_start_date))
		OR
		cpm.start_date between x_start_date and nvl(x_end_date,cpm.start_date)
		);
  	if (primary_count >= 1 ) then
		fnd_message.set_name('AR','AR_CUST_PAYMETH_PRIM_OVERLAP');
		app_exception.raise_exception;
	end if;

  else
		app_exception.invalid_argument('arp_cust_receipt_methods_pkg.check_primary','meth_type',x_meth_type);
  end if;
  --
  end check_primary;

  PROCEDURE Insert_Row(X_Rowid                   IN OUT VARCHAR2,
                       X_Cust_Receipt_Method_Id  IN OUT NUMBER,
                       X_Created_By                     NUMBER,
                       X_Creation_Date                  DATE,
                       X_Customer_Id                    NUMBER,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Primary_Flag                   VARCHAR2,
                       X_Receipt_Method_Id              NUMBER,
                       X_Start_Date                     DATE,
                       X_End_Date                       DATE,
                       X_Last_Update_Login              NUMBER,
                       X_Site_Use_Id                    NUMBER,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2
  ) IS
    CURSOR C IS SELECT rowid FROM ra_cust_receipt_methods
                 WHERE cust_receipt_method_id = X_Cust_Receipt_Method_Id;

   meth_type varchar2(4);
   id        number(15);
   BEGIN
	if ( x_site_use_id is null ) then
		meth_type := 'CUST';
	        id	  := x_customer_id;
	else
		meth_type := 'SITE';
		id	  := x_site_use_id;
	end if;
	--
	check_unique(x_cust_receipt_method_id,x_receipt_method_id,x_start_date,x_end_date,meth_type,id);
	--
	if (x_primary_flag = 'Y') then
		check_primary(x_cust_receipt_method_id,x_start_date,x_end_date,meth_type,id);
	end if;

       select ra_cust_receipt_methods_s.nextval
       into   x_cust_receipt_method_id
       from   dual;

       INSERT INTO ra_cust_receipt_methods(
              cust_receipt_method_id,
              created_by,
              creation_date,
              customer_id,
              last_updated_by,
              last_update_date,
              primary_flag,
              receipt_method_id,
              start_date,
	      end_date,
              last_update_login,
              site_use_id,
              attribute_category,
              attribute1,
              attribute2,
              attribute3,
              attribute4,
              attribute5,
              attribute6,
              attribute7,
              attribute8,
              attribute9,
              attribute10,
              attribute11,
              attribute12,
              attribute13,
              attribute14,
              attribute15
             ) VALUES (

              X_Cust_Receipt_Method_Id,
              X_Created_By,
              X_Creation_Date,
              X_Customer_Id,
              X_Last_Updated_By,
              X_Last_Update_Date,
              X_Primary_Flag,
              X_Receipt_Method_Id,
              X_Start_Date,
              X_End_Date,
              X_Last_Update_Login,
              X_Site_Use_Id,
              X_Attribute_Category,
              X_Attribute1,
              X_Attribute2,
              X_Attribute3,
              X_Attribute4,
              X_Attribute5,
              X_Attribute6,
              X_Attribute7,
              X_Attribute8,
              X_Attribute9,
              X_Attribute10,
              X_Attribute11,
              X_Attribute12,
              X_Attribute13,
              X_Attribute14,
              X_Attribute15

             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Cust_Receipt_Method_Id           NUMBER,
                     X_Customer_Id                      NUMBER,
                     X_Primary_Flag                     VARCHAR2,
                     X_Receipt_Method_Id                NUMBER,
                     X_Start_Date                       DATE,
                     X_End_Date                         DATE,
                     X_Attribute_Category               VARCHAR2,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_Attribute6                       VARCHAR2,
                     X_Attribute7                       VARCHAR2,
                     X_Attribute8                       VARCHAR2,
                     X_Attribute9                       VARCHAR2,
                     X_Attribute10                      VARCHAR2,
                     X_Attribute11                      VARCHAR2,
                     X_Attribute12                      VARCHAR2,
                     X_Attribute13                      VARCHAR2,
                     X_Attribute14                      VARCHAR2,
                     X_Attribute15                      VARCHAR2
  ) IS
    CURSOR C IS
        SELECT *
        FROM   ra_cust_receipt_methods
        WHERE  rowid = X_Rowid
        FOR UPDATE of Cust_Receipt_Method_Id NOWAIT;
    Recinfo C%ROWTYPE;


  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if (

               (Recinfo.cust_receipt_method_id =  X_Cust_Receipt_Method_Id)
           AND (Recinfo.customer_id =  X_Customer_Id)
           AND (Recinfo.primary_flag =  X_Primary_Flag)
           AND (Recinfo.receipt_method_id =  X_Receipt_Method_Id)
           AND (Recinfo.start_date =  X_Start_Date)
           AND (   (Recinfo.end_date =  X_End_Date)
                OR (    (Recinfo.end_date IS NULL)
                    AND (X_End_Date IS NULL)))
           AND (   (Recinfo.attribute_category =  X_Attribute_Category)
                OR (    (Recinfo.attribute_category IS NULL)
                    AND (X_Attribute_Category IS NULL)))
           AND (   (Recinfo.attribute1 =  X_Attribute1)
                OR (    (Recinfo.attribute1 IS NULL)
                    AND (X_Attribute1 IS NULL)))
           AND (   (Recinfo.attribute2 =  X_Attribute2)
                OR (    (Recinfo.attribute2 IS NULL)
                    AND (X_Attribute2 IS NULL)))
           AND (   (Recinfo.attribute3 =  X_Attribute3)
                OR (    (Recinfo.attribute3 IS NULL)
                    AND (X_Attribute3 IS NULL)))
           AND (   (Recinfo.attribute4 =  X_Attribute4)
                OR (    (Recinfo.attribute4 IS NULL)
                    AND (X_Attribute4 IS NULL)))
           AND (   (Recinfo.attribute5 =  X_Attribute5)
                OR (    (Recinfo.attribute5 IS NULL)
                    AND (X_Attribute5 IS NULL)))
           AND (   (Recinfo.attribute6 =  X_Attribute6)
                OR (    (Recinfo.attribute6 IS NULL)
                    AND (X_Attribute6 IS NULL)))
           AND (   (Recinfo.attribute7 =  X_Attribute7)
                OR (    (Recinfo.attribute7 IS NULL)
                    AND (X_Attribute7 IS NULL)))
           AND (   (Recinfo.attribute8 =  X_Attribute8)
                OR (    (Recinfo.attribute8 IS NULL)
                    AND (X_Attribute8 IS NULL)))
           AND (   (Recinfo.attribute9 =  X_Attribute9)
                OR (    (Recinfo.attribute9 IS NULL)
                    AND (X_Attribute9 IS NULL)))
           AND (   (Recinfo.attribute10 =  X_Attribute10)
                OR (    (Recinfo.attribute10 IS NULL)
                    AND (X_Attribute10 IS NULL)))
           AND (   (Recinfo.attribute11 =  X_Attribute11)
                OR (    (Recinfo.attribute11 IS NULL)
                    AND (X_Attribute11 IS NULL)))
           AND (   (Recinfo.attribute12 =  X_Attribute12)
                OR (    (Recinfo.attribute12 IS NULL)
                    AND (X_Attribute12 IS NULL)))
           AND (   (Recinfo.attribute13 =  X_Attribute13)
                OR (    (Recinfo.attribute13 IS NULL)
                    AND (X_Attribute13 IS NULL)))
           AND (   (Recinfo.attribute14 =  X_Attribute14)
                OR (    (Recinfo.attribute14 IS NULL)
                    AND (X_Attribute14 IS NULL)))
           AND (   (Recinfo.attribute15 =  X_Attribute15)
                OR (    (Recinfo.attribute15 IS NULL)
                    AND (X_Attribute15 IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,

                       X_Cust_Receipt_Method_Id         NUMBER,
                       X_Customer_Id                    NUMBER,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Primary_Flag                   VARCHAR2,
                       X_Receipt_Method_Id              NUMBER,
                       X_Start_Date                     DATE,
                       X_End_Date                       DATE,
                       X_Last_Update_Login              NUMBER,
                       X_Site_Use_Id                    NUMBER,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2

  ) IS
  meth_type varchar2(4);
  id        number(15);
  BEGIN
	if ( x_site_use_id is null ) then
		meth_type := 'CUST';
	        id	  := x_customer_id;
	else
		meth_type := 'SITE';
		id	  := x_site_use_id;
	end if;
	--
	check_unique(x_cust_receipt_method_id,x_receipt_method_id,x_start_date,x_end_date,meth_type,id);
	--
	if (x_primary_flag = 'Y') then
		check_primary(x_cust_receipt_method_id,x_start_date,x_end_date,meth_type,id);
	end if;

    UPDATE ra_cust_receipt_methods
    SET
       cust_receipt_method_id          =     X_Cust_Receipt_Method_Id,
       customer_id                     =     X_Customer_Id,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_date                =     X_Last_Update_Date,
       primary_flag                    =     X_Primary_Flag,
       receipt_method_id               =     X_Receipt_Method_Id,
       start_date                      =     X_Start_Date,
       end_date                        =     X_End_Date,
       last_update_login               =     X_Last_Update_Login,
       site_use_id                     =     X_Site_Use_Id,
       attribute_category              =     X_Attribute_Category,
       attribute1                      =     X_Attribute1,
       attribute2                      =     X_Attribute2,
       attribute3                      =     X_Attribute3,
       attribute4                      =     X_Attribute4,
       attribute5                      =     X_Attribute5,
       attribute6                      =     X_Attribute6,
       attribute7                      =     X_Attribute7,
       attribute8                      =     X_Attribute8,
       attribute9                      =     X_Attribute9,
       attribute10                     =     X_Attribute10,
       attribute11                     =     X_Attribute11,
       attribute12                     =     X_Attribute12,
       attribute13                     =     X_Attribute13,
       attribute14                     =     X_Attribute14,
       attribute15                     =     X_Attribute15
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

END arp_crm_pkg;

/
