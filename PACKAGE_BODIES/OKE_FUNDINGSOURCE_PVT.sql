--------------------------------------------------------
--  DDL for Package Body OKE_FUNDINGSOURCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_FUNDINGSOURCE_PVT" as
/* $Header: OKEVFDSB.pls 115.11 2003/10/07 00:48:42 alaw ship $ */


  PROCEDURE Insert_Row(X_Rowid            IN OUT NOCOPY VARCHAR2,
     		       X_Funding_Source_Id		NUMBER,
                       X_Pool_Party_Id			NUMBER,
                       X_K_Party_Id                     NUMBER,
                       X_Object_Type			VARCHAR2,
                       X_Object_Id			NUMBER,
                       X_Agreement_Number		VARCHAR2,
                       X_Currency_Code			VARCHAR2,
                       X_Amount				NUMBER,
                       X_Initial_Amount			NUMBER,
                       X_Previous_Amount		NUMBER,
                       X_Funding_Status			VARCHAR2,
                       X_Hard_Limit			NUMBER,
                       X_Revenue_Hard_Limit		NUMBER,
                       X_Agreement_Org_Id		NUMBER,
                       X_K_Conversion_Type		VARCHAR2,
                       X_K_Conversion_Date		DATE,
                       X_K_Conversion_Rate		NUMBER,
                       X_Start_Date_Active		DATE,
                       X_End_Date_Active		DATE,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
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
                       X_Attribute15                    VARCHAR2,
 		       X_PA_Attribute_Category		VARCHAR2,
                       X_PA_Attribute1                  VARCHAR2,
                       X_PA_Attribute2                  VARCHAR2,
                       X_PA_Attribute3                  VARCHAR2,
                       X_PA_Attribute4                  VARCHAR2,
                       X_PA_Attribute5                  VARCHAR2,
                       X_PA_Attribute6                  VARCHAR2,
                       X_PA_Attribute7                  VARCHAR2,
                       X_PA_Attribute8                  VARCHAR2,
                       X_PA_Attribute9                  VARCHAR2,
                       X_PA_Attribute10                 VARCHAR2
  ) is

    cursor C is
    select rowid
    from   OKE_K_FUNDING_SOURCES
    where  funding_source_id = X_Funding_Source_Id;

  begin
       --oke_debug.debug('entering funding source insert_row');
       insert into OKE_K_FUNDING_SOURCES(
              funding_source_id,
   	      pool_party_id,
 	      k_party_id,
 	      object_type,
	      object_id,
	      agreement_number,
	      amount,
 	      initial_amount,
	      previous_amount,
	      funding_status,
	      hard_limit,
	      revenue_hard_limit,
	      agreement_org_id,
	      currency_code,
	      k_conversion_type,
	      k_conversion_date,
	      k_conversion_rate,
 	      start_date_active,
 	      end_date_active,
 	      creation_date,
 	      created_by,
	      last_updated_by,
	      last_update_date,
	      last_update_login,
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
	      attribute15,
	      pa_attribute_category,
	      pa_attribute1,
 	      pa_attribute2,
 	      pa_attribute3,
	      pa_attribute4,
	      pa_attribute5,
 	      pa_attribute6,
 	      pa_attribute7,
 	      pa_attribute8,
 	      pa_attribute9,
 	      pa_attribute10
             ) VALUES (
              X_Funding_Source_Id,
              X_Pool_Party_Id,
              X_K_Party_Id,
              X_Object_Type,
              X_Object_Id,
              X_Agreement_Number,
              X_Amount,
              X_Initial_Amount,
              X_Previous_Amount,
              X_Funding_Status,
              X_Hard_Limit,
              X_Revenue_Hard_Limit,
              X_Agreement_Org_ID,
              X_Currency_Code,
              X_K_Conversion_Type,
              X_K_Conversion_Date,
              X_K_Conversion_Rate,
              X_Start_Date_Active,
              X_End_Date_Active,
              X_Creation_Date,
              X_Created_By,
              X_Last_Updated_By,
              X_Last_Update_Date,
              X_Last_Update_Login,
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
              X_Attribute15,
              X_PA_Attribute_Category,
              X_PA_Attribute1,
              X_PA_Attribute2,
              X_PA_Attribute3,
              X_PA_Attribute4,
              X_PA_Attribute5,
              X_PA_Attribute6,
              X_PA_Attribute7,
              X_PA_Attribute8,
              X_PA_Attribute9,
              X_PA_Attribute10
             );

  	open c;
 	fetch c into X_Rowid;
    	if (c%notfound) then
   	   close c;
    	   raise no_data_found;
        end if;
        close c;
        --oke_debug.debug('finishing insert_row');
        if (x_pool_party_id is not null) then
        --oke_debug.debug('inside the update oke_pool_parties');

     	   update oke_pool_parties
       	   set    available_amount = (available_amount - X_amount)
       	   where  pool_party_id    = X_Pool_Party_Id;

       	   if (sql%notfound) then
       	   --oke_debug.debug('encounter no date found for update pool party');
       	      raise no_data_found;
           end if;

        end if;

  end Insert_Row;

  PROCEDURE Lock_Row(X_Funding_Source_Id		NUMBER,
                     X_Pool_Party_Id			NUMBER,
                     X_K_Party_Id                       NUMBER,
                     X_Object_Type			VARCHAR2,
                     X_Object_Id			NUMBER,
                     X_Agreement_Number			VARCHAR2,
                     X_Currency_Code			VARCHAR2,
                     X_Amount				NUMBER,
                     X_Initial_Amount			NUMBER,
                     X_Previous_Amount			NUMBER,
                     X_Funding_Status			VARCHAR2,
                     X_Hard_Limit			NUMBER,
                     X_Revenue_Hard_Limit		NUMBER,
                     X_Agreement_Org_Id			NUMBER,
                     X_K_Conversion_Type		VARCHAR2,
                     X_K_Conversion_Date		DATE,
                     X_K_Conversion_Rate		NUMBER,
                     X_Start_Date_Active		DATE,
                     X_End_Date_Active			DATE,
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
                     X_Attribute15                      VARCHAR2,
                     X_PA_Attribute_Category		VARCHAR2,
                     X_PA_Attribute1                    VARCHAR2,
                     X_PA_Attribute2                    VARCHAR2,
                     X_PA_Attribute3                    VARCHAR2,
                     X_PA_Attribute4                    VARCHAR2,
                     X_PA_Attribute5                    VARCHAR2,
                     X_PA_Attribute6                    VARCHAR2,
                     X_PA_Attribute7                    VARCHAR2,
                     X_PA_Attribute8                    VARCHAR2,
                     X_PA_Attribute9                    VARCHAR2,
                     X_PA_Attribute10                   VARCHAR2
  ) is

    cursor c is
    select funding_source_id,
    	   pool_party_id,
    	   k_party_id,
    	   object_type,
  	   object_id,
  	   agreement_number,
  	   currency_code,
  	   amount,
  	   initial_amount,
  	   previous_amount,
  	   funding_status,
  	   hard_limit,
  	   revenue_hard_limit,
  	   agreement_org_id,
  	   k_conversion_type,
  	   k_conversion_rate,
  	   k_conversion_date,
  	   start_date_active,
  	   end_date_active,
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
           attribute15,
           pa_attribute_category,
           pa_attribute1,
           pa_attribute2,
           pa_attribute3,
           pa_attribute4,
           pa_attribute5,
           pa_attribute6,
           pa_attribute7,
           pa_attribute8,
           pa_attribute9,
           pa_attribute10
    from   OKE_K_FUNDING_SOURCES
    where  funding_source_id = X_Funding_Source_Id
    for update of funding_source_id nowait;

    recinfo     c%rowtype;

begin

    open c;
    fetch c into recinfo;
    if (c%notfound) then
       close c;
       fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
       app_exception.raise_exception;
    end if;
    close c;

    if (   ((recinfo.hard_limit = X_Hard_Limit)
           OR ((recinfo.hard_limit is null) AND (X_Hard_Limit is null)))
       AND ((recinfo.revenue_hard_limit = X_Revenue_Hard_Limit)
           OR ((recinfo.revenue_hard_limit is null) AND (X_Revenue_Hard_Limit is null)))
       AND ((recinfo.agreement_org_id = X_Agreement_Org_ID)
           OR ((recinfo.agreement_org_id is null) AND (X_Agreement_Org_ID is null)))
       AND ((rtrim(recinfo.k_conversion_type) = rtrim(X_K_Conversion_Type))
           OR ((recinfo.k_conversion_type is null) AND (X_K_Conversion_Type is null)))
       AND ((rtrim(recinfo.k_conversion_date) = rtrim(X_K_Conversion_Date))
           OR ((recinfo.k_conversion_date is null) AND (X_K_Conversion_Date is null)))
       AND ((recinfo.k_conversion_rate = X_K_Conversion_Rate)
           OR ((recinfo.k_conversion_rate is null) AND (X_K_Conversion_Rate is null)))
       AND ((rtrim(recinfo.end_date_active) = rtrim(X_End_Date_Active))
           OR ((recinfo.end_date_active is null) AND (X_End_Date_Active is null)))
       AND ((rtrim(recinfo.start_date_active) = rtrim(X_Start_Date_Active))
           OR ((recinfo.start_date_active is null) AND (X_Start_Date_Active is null)))
       AND ((rtrim(recinfo.funding_status) = rtrim(X_Funding_Status))
           OR ((recinfo.funding_status is null) AND (X_Funding_Status is null)))
       AND ((recinfo.pool_party_id = X_Pool_Party_Id)
           OR ((recinfo.pool_party_id is null) AND (X_Pool_Party_Id is null)))
       AND (recinfo.initial_amount = X_Initial_Amount)
       AND (recinfo.previous_amount = X_Previous_Amount)
       AND (rtrim(recinfo.object_type) = rtrim(X_Object_Type))
       AND (rtrim(recinfo.currency_code) = rtrim(X_Currency_Code))
       AND (recinfo.funding_source_id = X_Funding_Source_Id)
       AND (recinfo.object_id = X_Object_Id)
       AND (recinfo.amount = X_Amount)
       AND (recinfo.k_party_id = X_K_Party_Id)
       AND (recinfo.funding_source_id = X_Funding_Source_Id)
       AND ((rtrim(recinfo.attribute_category) = rtrim(X_Attribute_Category))
           OR ((recinfo.attribute_category is null) AND (X_Attribute_Category is null)))
       AND ((rtrim(recinfo.attribute1) = rtrim(X_Attribute1))
           OR ((recinfo.attribute1 is null) AND (X_Attribute1 is null)))
       AND ((rtrim(recinfo.attribute2) = rtrim(X_Attribute2))
           OR ((recinfo.attribute2 is null) AND (X_Attribute2 is null)))
       AND ((rtrim(recinfo.attribute3) = rtrim(X_Attribute3))
           OR ((recinfo.attribute3 is null) AND (X_Attribute3 is null)))
       AND ((rtrim(recinfo.attribute4) = rtrim(X_Attribute4))
           OR ((recinfo.attribute4 is null) AND (X_Attribute4 is null)))
       AND ((rtrim(recinfo.attribute5) = rtrim(X_Attribute5))
           OR ((recinfo.attribute5 is null) AND (X_Attribute5 is null)))
       AND ((rtrim(recinfo.attribute6) = rtrim(X_Attribute6))
           OR ((recinfo.attribute6 is null) AND (X_Attribute6 is null)))
       AND ((rtrim(recinfo.attribute7) = rtrim(X_Attribute7))
           OR ((recinfo.attribute7 is null) AND (X_Attribute7 is null)))
       AND ((rtrim(recinfo.attribute8) = rtrim(X_Attribute8))
           OR ((recinfo.attribute8 is null) AND (X_Attribute8 is null)))
       AND ((rtrim(recinfo.attribute9) = rtrim(X_Attribute9))
           OR ((recinfo.attribute9 is null) AND (X_Attribute9 is null)))
       AND ((rtrim(recinfo.attribute10) = rtrim(X_Attribute10))
           OR ((recinfo.attribute10 is null) AND (X_Attribute10 is null)))
       AND ((rtrim(recinfo.attribute11) = rtrim(X_Attribute11))
           OR ((recinfo.attribute11 is null) AND (X_Attribute11 is null)))
       AND ((rtrim(recinfo.attribute12) = rtrim(X_Attribute12))
           OR ((recinfo.attribute12 is null) AND (X_Attribute12 is null)))
       AND ((rtrim(recinfo.attribute13) = rtrim(X_Attribute13))
           OR ((recinfo.attribute13 is null) AND (X_Attribute13 is null)))
       AND ((rtrim(recinfo.attribute14) = rtrim(X_Attribute14))
           OR ((recinfo.attribute14 is null) AND (X_Attribute14 is null)))
       AND ((rtrim(recinfo.attribute15) = rtrim(X_Attribute15))
           OR ((recinfo.attribute15 is null) AND (X_Attribute15 is null)))
       AND ((rtrim(recinfo.pa_attribute_category) = rtrim(X_PA_Attribute_Category))
           OR ((recinfo.pa_attribute_category is null) AND (X_PA_Attribute_Category is null)))
       AND ((rtrim(recinfo.pa_attribute1) = rtrim(X_PA_Attribute1))
           OR ((recinfo.pa_attribute1 is null) AND (X_PA_Attribute1 is null)))
       AND ((rtrim(recinfo.pa_attribute2) = rtrim(X_PA_Attribute2))
           OR ((recinfo.pa_attribute2 is null) AND (X_PA_Attribute2 is null)))
       AND ((rtrim(recinfo.pa_attribute3) = rtrim(X_PA_Attribute3))
           OR ((recinfo.pa_attribute3 is null) AND (X_PA_Attribute3 is null)))
       AND ((rtrim(recinfo.pa_attribute4) = rtrim(X_PA_Attribute4))
           OR ((recinfo.pa_attribute4 is null) AND (X_PA_Attribute4 is null)))
       AND ((rtrim(recinfo.pa_attribute5) = rtrim(X_PA_Attribute5))
           OR ((recinfo.pa_attribute5 is null) AND (X_PA_Attribute5 is null)))
       AND ((rtrim(recinfo.pa_attribute6) = rtrim(X_PA_Attribute6))
           OR ((recinfo.pa_attribute6 is null) AND (X_PA_Attribute6 is null)))
       AND ((rtrim(recinfo.pa_attribute7) = rtrim(X_PA_Attribute7))
           OR ((recinfo.pa_attribute7 is null) AND (X_PA_Attribute7 is null)))
       AND ((rtrim(recinfo.pa_attribute8) = rtrim(X_PA_Attribute8))
           OR ((recinfo.pa_attribute8 is null) AND (X_PA_Attribute8 is null)))
       AND ((rtrim(recinfo.pa_attribute9) = rtrim(X_PA_Attribute9))
           OR ((recinfo.pa_attribute9 is null) AND (X_PA_Attribute9 is null)))
       AND ((rtrim(recinfo.pa_attribute10) = rtrim(X_PA_Attribute10))
           OR ((recinfo.pa_attribute10 is null) AND (X_PA_Attribute10 is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  end Lock_Row;

  PROCEDURE Update_Row(X_Funding_Source_Id		NUMBER,
  		       X_Pool_Party_Id			NUMBER,
                       X_K_Party_Id                     NUMBER,
                       X_Amount				NUMBER,
                       X_Previous_Amount		NUMBER,
                       X_Funding_Status			VARCHAR2,
                       X_Agreement_Number		VARCHAR2,
                       X_Hard_Limit			NUMBER,
                       X_Revenue_Hard_Limit		NUMBER,
                       X_Agreement_Org_ID		NUMBER,
                       X_K_Conversion_Type		VARCHAR2,
                       X_K_Conversion_Date		DATE,
                       X_K_Conversion_Rate		NUMBER,
                       X_Start_Date_Active		DATE,
                       X_End_Date_Active		DATE,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
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
                       X_Attribute15                    VARCHAR2,
		       X_PA_Attribute_Category		VARCHAR2,
                       X_PA_Attribute1                  VARCHAR2,
                       X_PA_Attribute2                  VARCHAR2,
                       X_PA_Attribute3                  VARCHAR2,
                       X_PA_Attribute4                  VARCHAR2,
                       X_PA_Attribute5                  VARCHAR2,
                       X_PA_Attribute6                  VARCHAR2,
                       X_PA_Attribute7                  VARCHAR2,
                       X_PA_Attribute8                  VARCHAR2,
                       X_PA_Attribute9                  VARCHAR2,
                       X_PA_Attribute10                 VARCHAR2
  ) is

      cursor c_source is
          select nvl(sum(amount), 0)
          from   oke_k_funding_sources
          where  pool_party_id = x_pool_party_id;

      l_amount	number;

  begin

       update OKE_K_FUNDING_SOURCES
       set
  	  pool_party_id		       =      X_Pool_Party_Id,
          k_party_id		       =      X_K_Party_Id,
          amount		       =      X_Amount,
          previous_amount              =      X_Previous_Amount,
          funding_status	       =      X_Funding_Status,
          agreement_number	       =      X_Agreement_Number,
          hard_limit	               =      X_Hard_Limit,
          revenue_hard_limit	       =      X_Revenue_Hard_Limit,
          agreement_org_id	       =      X_Agreement_Org_ID,
          k_conversion_type            =      X_K_Conversion_Type,
          k_conversion_date            =      X_K_Conversion_Date,
          k_conversion_rate            =      X_K_Conversion_Rate,
          start_date_active            =      X_Start_Date_Active,
          end_date_active              =      X_End_Date_Active,
          last_update_date             =      X_Last_Update_Date,
          last_updated_by              =      X_Last_Updated_By,
          last_update_login            =      X_Last_Update_Login,
          attribute_Category           =      X_Attribute_Category,
          attribute1                   =      X_Attribute1,
          attribute2                   =      X_Attribute2,
          attribute3                   =      X_Attribute3,
          attribute4                   =      X_Attribute4,
          attribute5                   =      X_Attribute5,
          attribute6                   =      X_Attribute6,
          attribute7                   =      X_Attribute7,
          attribute8                   =      X_Attribute8,
          attribute9                   =      X_Attribute9,
          attribute10                  =      X_Attribute10,
          attribute11                  =      X_Attribute11,
          attribute12                  =      X_Attribute12,
          attribute13                  =      X_Attribute13,
          attribute14                  =      X_Attribute14,
          attribute15                  =      X_Attribute15,
          pa_attribute_category	       =      X_PA_Attribute_Category,
          pa_attribute1		       =      X_PA_Attribute1,
          pa_attribute2		       =      X_PA_Attribute2,
          pa_attribute3		       =      X_PA_Attribute3,
          pa_attribute4		       =      X_PA_Attribute4,
          pa_attribute5		       =      X_PA_Attribute5,
          pa_attribute6		       =      X_PA_Attribute6,
          pa_attribute7		       =      X_PA_Attribute7,
          pa_attribute8		       =      X_PA_Attribute8,
          pa_attribute9		       =      X_PA_Attribute9,
          pa_attribute10	       =      X_PA_Attribute10
       where funding_source_id = X_Funding_Source_Id;

    if (sql%notfound) then
        raise no_data_found;
    end if;

    if (x_pool_party_id is not null) then

       open c_source;
       fetch c_source into l_amount;

       if (c_source%notfound) then
   	   close c_source;
    	   raise no_data_found;
       end if;

       close c_source;

       update oke_pool_parties
       set    available_amount = (amount - l_amount)
       where  pool_party_id    = X_Pool_Party_Id;

       if (sql%notfound) then
       	  raise no_data_found;
       end if;

     end if;

  end Update_Row;

  PROCEDURE Delete_Row(X_Rowid 		 VARCHAR2,
  		       X_Pool_Party_Id	 NUMBER   ) IS
     cursor c_pool is
        select *
        from   oke_pool_parties
        where  pool_party_id = x_pool_party_id
        for update of pool_party_id nowait;

     cursor c_source is
        select nvl(amount, 0)
        from   oke_k_funding_sources
        where  rowid = x_rowid;

     l_source_amount	number;
     l_pool_party_row	c_pool%ROWTYPE;

  BEGIN

   OPEN c_source;
   FETCH c_source into l_source_amount;
   CLOSE c_source;

   DELETE FROM OKE_K_FUNDING_SOURCES
   WHERE rowid = X_Rowid;

   if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
   end if;

   if (x_pool_party_id is not null) then

       OPEN c_pool;
       FETCH c_pool into l_pool_party_row;

       if (c_pool%notfound) then
          close c_pool;
          raise no_data_found;
       end if;

       close c_pool;

       UPDATE OKE_POOL_PARTIES
       SET    available_amount = l_pool_party_row.available_amount + l_source_amount
       WHERE  pool_party_id = l_pool_party_row.pool_party_id;

   end if;

  EXCEPTION
     WHEN OTHERS THEN
          raise;

  END Delete_Row;

END OKE_FundingSource_PVT;

/
