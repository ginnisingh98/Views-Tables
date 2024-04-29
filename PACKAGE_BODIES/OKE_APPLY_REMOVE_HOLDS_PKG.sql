--------------------------------------------------------
--  DDL for Package Body OKE_APPLY_REMOVE_HOLDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_APPLY_REMOVE_HOLDS_PKG" as
/* $Header: OKEHDPLB.pls 115.8 2002/11/19 23:03:39 jxtang ship $ */



  PROCEDURE Lock_Row(X_hold_id				NUMBER,
  	  	     X_k_header_id			NUMBER,
                     X_k_line_id			NUMBER,
                     X_remove_date			DATE,
		     X_remove_reason_code		VARCHAR2,
		     X_remove_comment			VARCHAR2,
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
  		) is

    cursor c is
    select hold_id,
    	   k_header_id,
           k_line_id,
           remove_date,
	   remove_reason_code,
	   remove_comment,
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
    from   OKE_K_HOLDS
    where  hold_id = X_hold_id
    for update of hold_id nowait;

    recinfo c%rowtype;

begin

    open c;
    fetch c into recinfo;
    if (c%notfound) then
       close c;
       fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
       app_exception.raise_exception;
    end if;
    close c;

    if (
        ((rtrim(recinfo.remove_date) = rtrim(X_remove_date))
           OR ((recinfo.remove_date is null) AND (X_remove_date is null)))
       AND ((rtrim(recinfo.remove_reason_code) = rtrim(X_remove_reason_code))
           OR ((recinfo.remove_reason_code is null) AND (X_remove_reason_code is null)))
       AND ((rtrim(recinfo.remove_comment) = rtrim(X_remove_comment))
           OR ((recinfo.remove_comment is null) AND (X_remove_comment is null)))
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
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

end Lock_Row;


PROCEDURE Update_Row(X_hold_id		                NUMBER,
  	  	     X_k_header_id	        	NUMBER,
                     X_k_line_id		        NUMBER,
                     X_remove_date		        DATE,
                     X_remove_reason_code		VARCHAR2,
                     X_remove_comment			VARCHAR2,
                     X_hold_status_code                 VARCHAR2,
                     X_wf_item_type                     VARCHAR2,
                     X_wf_process                       VARCHAR2,
                     X_Last_Update_Date                 DATE,
                     X_Last_Updated_By                  NUMBER,
                     X_Creation_Date                    DATE,
                     X_Created_By                       NUMBER,
                     X_Last_Update_Login                NUMBER,
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

  ) is

  x_prev_hold_status_code OKE_K_HOLDS.hold_status_code%TYPE;
  x_k_Deliverable_ID      OKE_K_HOLDS.Deliverable_ID%TYPE;
  x_hold_type_code        OKE_K_HOLDS.hold_type_code%TYPE;
  x_hold_reason_code      OKE_K_HOLDS.hold_reason_code%TYPE;

  cursor C_prev is
    select hold_status_code
          ,Deliverable_ID
          ,hold_type_code
          ,hold_reason_code
    from   OKE_K_HOLDS
    where hold_id = X_hold_id;

begin

  open c_prev;
  fetch c_prev into X_prev_hold_status_code
                   ,x_k_Deliverable_ID
                   ,x_hold_type_code
                   ,x_hold_reason_code;
  close c_prev;

    update OKE_K_HOLDS
    set
       remove_date		       =     X_remove_date,
       remove_reason_code	       =     X_remove_reason_code,
       remove_comment		       =     X_remove_comment,
       hold_status_code                =     X_hold_status_code,
       wf_item_type                    =     X_wf_item_type,
       wf_process                      =     X_wf_process,
       Last_Update_Date                =     X_Last_Update_Date,
       Last_Updated_By                 =     X_Last_Updated_By,
       Creation_Date                   =     X_Creation_Date,
       Created_By                      =     X_Created_By,
       Last_Update_Login               =     X_Last_Update_Login,
       attribute_Category              =     X_Attribute_Category,
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
    where hold_id = X_hold_id;
--	and k_header_id = X_k_header_id;
--	and k_line_id = X_k_line_id;

  if NVL(X_Hold_Status_Code, '@' ) <> NVL(X_prev_hold_status_code, '@' ) then
    OKE_HOLD_UTILS.Status_Change
    ( X_Hold_ID
    , X_K_Header_ID
    , X_K_Line_ID
    , X_k_Deliverable_ID
    , X_Hold_Type_Code
    , X_Hold_Reason_Code
    , X_Remove_Reason_Code
    , X_prev_hold_status_code
    , X_Hold_Status_Code
    , X_Last_Updated_By
    , X_Last_Update_Date
    , X_Last_Update_Login
    );
  end if;


    if (sql%notfound) then
        raise no_data_found;
    end if;

end Update_Row;


PROCEDURE Insert_Row(X_Rowid			 IN OUT NOCOPY VARCHAR2,
	 	     X_hold_id		        	NUMBER,
  	  	     X_k_header_id			NUMBER,
                     X_k_line_id			NUMBER,
                     X_k_deliverable_id			NUMBER,
                     X_apply_date			DATE,
                     X_schedule_remove_date		DATE,
		     X_hold_type_code			VARCHAR2,
		     X_hold_reason_code			VARCHAR2,
		     X_hold_status_code			VARCHAR2,
		     X_hold_comment			VARCHAR2,
		     X_wf_item_type			VARCHAR2,
		     X_wf_process			VARCHAR2,
                     X_Last_Update_Date               	DATE,
                     X_Last_Updated_By                	NUMBER,
                     X_Creation_Date                  	DATE,
                     X_Created_By                     	NUMBER,
                     X_Last_Update_Login              	NUMBER
  ) is

    cursor C is
    select rowid
    from   OKE_K_HOLDS
    where  hold_id = X_hold_id;

begin

       insert into OKE_K_HOLDS(
	      hold_id,
  	      k_header_id,
              k_line_id,
              deliverable_id,
              apply_date,
              schedule_remove_date,
	      hold_type_code,
	      hold_reason_code,
	      hold_status_code,
	      hold_comment,
	      wf_item_type,
	      wf_process,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login
             ) VALUES (
	 	     X_hold_id,
  	  	     X_k_header_id,
                     X_k_line_id,
                     X_k_deliverable_id,
                     X_apply_date,
                     X_schedule_remove_date,
		     X_hold_type_code,
		     X_hold_reason_code,
		     X_hold_status_code,
		     X_hold_comment,
		     X_wf_item_type,
		     X_wf_process,
                     X_Last_Update_Date,
                     X_Last_Updated_By,
                     X_Creation_Date,
                     X_Created_By,
                     X_Last_Update_Login
             );

    OKE_HOLD_UTILS.Status_Change
    ( X_Hold_ID
    , X_K_Header_ID
    , X_K_Line_ID
    , X_k_Deliverable_ID
    , X_Hold_Type_Code
    , X_Hold_Reason_Code
    , null
    , null
    , X_Hold_Status_Code
    , X_Last_Updated_By
    , X_Last_Update_Date
    , X_Last_Update_Login
    );

  	open c;
 	fetch c into X_Rowid;
    	if (c%notfound) then
   	   close c;
    	   raise no_data_found;
        end if;
        close c;

end Insert_Row;


end OKE_APPLY_REMOVE_HOLDS_PKG;

/
