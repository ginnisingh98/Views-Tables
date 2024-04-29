--------------------------------------------------------
--  DDL for Package Body AS_ACCESSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_ACCESSES_PKG" as
/* $Header: asxacacb.pls 120.1 2005/12/18 23:26:16 subabu noship $ */

--
-- HISTORY
--  30-JUN-94	J Sondergaard	Created Territory_Access_Exists
--				Created Access_For_Person_Exists
--  09-SEP-94	J Sondergaard	Modified Access_For_Person_Exists
--				to Access Exists. Function now
--				takes more arguments
--  12-OCT-94   J Sondergaard   Access_Exists renamed to
--				Emp_Access_Exists
--				Created Ptr_Access_Exists
--  13-OCT-94   J Sondergaard   Added Lead_Id so Emp_Access_Exists
--				and Ptr_Access_Exists can be used in
--				Leads form also.
--
--  16-JUN-95   J Kornberg	Removed Function Territory_Access_Exists
--
--  21-JUN-95   J Kornberg	Added partner_customer_id and partner_address_id
--				to the access table handlers
--  23-AUG-95   K Lee		Changed due to ACCESS_TYPE becoming obsolete
--				in AS_ACCESSES
--  12-JUL-96   J Kornberg      Added salesforce_role and salesforce_relationship
--				column to table handlers
--

PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Access_Id                           IN OUT NOCOPY NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Creation_Date                       DATE,
                     X_Created_By                          NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Access_Type                         VARCHAR2,
                     X_Freeze_Flag                         VARCHAR2,
                     X_Reassign_Flag                       VARCHAR2,
                     X_Team_Leader_Flag                    VARCHAR2,
                     X_Person_Id                           NUMBER,
                     X_Customer_Id                         NUMBER,
                     X_Address_Id                          NUMBER,
		     X_Salesforce_Id			   NUMBER,
                     X_Partner_Customer_Id                 NUMBER,
                     X_Partner_Address_Id                  NUMBER,
                     X_Created_Person_Id                   NUMBER,
                     X_Lead_Id                             NUMBER,
                     X_Freeze_Date                         DATE,
                     X_Reassign_Reason                     VARCHAR2,
		     x_reassign_request_date		    DATE,
		     x_reassign_requested_person_id         NUMBER,
                     X_Attribute_Category                  VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Attribute11                         VARCHAR2,
                     X_Attribute12                         VARCHAR2,
                     X_Attribute13                         VARCHAR2,
                     X_Attribute14                         VARCHAR2,
                     X_Attribute15                         VARCHAR2,
		     X_Salesforce_Role_Code		   VARCHAR2,
		     X_Salesforce_Relationship_Code	   VARCHAR2,
		     X_Internal_update_access              NUMBER  ,
		     X_Sales_lead_id                       NUMBER  ,
		     X_Sales_group_id                      NUMBER  ,
			X_Partner_Cont_Party_Id               NUMBER,
			X_owner_flag	          VARCHAR2,
			X_created_by_tap_flag	  VARCHAR2,
			X_prm_keep_flag          VARCHAR2,
                        X_open_flag              VARCHAR2,
                        X_lead_rank_score        NUMBER,
                        X_object_creation_date   DATE,
                        X_contributor_flag       VARCHAR2 -- Added for ASNB

 ) IS
   CURSOR C IS SELECT rowid FROM as_accesses_all
             WHERE access_id = X_Access_Id;
    CURSOR C2 IS SELECT as_accesses_s.nextval FROM sys.dual;
BEGIN
   if (X_Access_Id is NULL or x_access_id = fnd_api.g_miss_num) then
     OPEN C2;
     FETCH C2 INTO X_Access_Id;
     CLOSE C2;
   end if;
  INSERT INTO as_accesses_all(
          access_id,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login,
          access_type,
          freeze_flag,
          reassign_flag,
          team_leader_flag,
          person_id,
          customer_id,
          address_id,
	  salesforce_id,
          partner_customer_id,
	  partner_address_id,
          created_person_id,
          lead_id,
          freeze_date,
          reassign_reason,
	  reassign_request_date,
	  reassign_requested_person_id,
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
 	  salesforce_role_code,
	  salesforce_relationship_code,
	  internal_update_access,
       sales_lead_id,
	  sales_group_id,
	  partner_cont_party_id,
	  owner_flag,
	  created_by_tap_flag,
	  prm_keep_flag,
          open_flag,
          lead_rank_score,
          object_creation_date,
	  contributor_flag -- Added for ASNB
         ) VALUES (
          X_Access_Id,
          X_Last_Update_Date,
          X_Last_Updated_By,
          X_Creation_Date,
          X_Created_By,
          X_Last_Update_Login,
	decode(X_Access_Type,FND_API.G_MISS_CHAR,NULL,X_Access_Type),
        decode(X_Freeze_Flag,FND_API.G_MISS_CHAR,'Y',X_Freeze_Flag),
        decode(X_Reassign_Flag,FND_API.G_MISS_CHAR,'N',X_Reassign_Flag),
	decode(X_Team_Leader_Flag,FND_API.G_MISS_CHAR,'N',X_Team_Leader_Flag),
	decode(X_Person_Id, FND_API.G_MISS_NUM, NULL, X_person_id),
	decode(X_Customer_Id,FND_API.G_MISS_NUM, NULL, X_customer_id),
	decode(X_Address_Id,FND_API.G_MISS_NUM, NULL, X_address_id ),
	decode(X_Salesforce_Id,FND_API.G_MISS_NUM, NULL, X_salesforce_id),
	decode(X_Partner_Customer_Id,FND_API.G_MISS_NUM, NULL, X_partner_customer_id),
	decode(X_Partner_Address_Id,FND_API.G_MISS_NUM, NULL, X_partner_address_id),
	decode(X_Created_Person_Id,FND_API.G_MISS_NUM, NULL, X_created_person_id ),
	decode(X_Lead_Id,FND_API.G_MISS_NUM, NULL, X_lead_id),
	decode(X_Freeze_Date,FND_API.G_MISS_DATE, NULL,X_Freeze_Date),
	decode(X_Reassign_Reason,FND_API.G_MISS_CHAR,NULL,X_Reassign_Reason),
	decode(X_reassign_request_date,FND_API.G_MISS_DATE,
			NULL,X_reassign_request_date),
	decode(X_reassign_requested_person_id ,FND_API.G_MISS_NUM,
					NULL,X_reassign_requested_person_id ),
	decode(X_Attribute_Category,FND_API.G_MISS_CHAR,NULL,X_Attribute_Category),
	decode(X_Attribute1,FND_API.G_MISS_CHAR,NULL,X_Attribute1),
        decode(X_Attribute2,FND_API.G_MISS_CHAR,NULL,X_Attribute2),
        decode(X_Attribute3,FND_API.G_MISS_CHAR,NULL,X_Attribute3),
        decode(X_Attribute4,FND_API.G_MISS_CHAR,NULL,X_Attribute4),
        decode(X_Attribute5,FND_API.G_MISS_CHAR,NULL,X_Attribute5),
        decode(X_Attribute6,FND_API.G_MISS_CHAR,NULL,X_Attribute6),
        decode(X_Attribute7,FND_API.G_MISS_CHAR,NULL,X_Attribute7),
        decode(X_Attribute8,FND_API.G_MISS_CHAR,NULL,X_Attribute8),
        decode(X_Attribute9,FND_API.G_MISS_CHAR,NULL,X_Attribute9),
        decode(X_Attribute10,FND_API.G_MISS_CHAR,NULL,X_Attribute10),
        decode(X_Attribute11,FND_API.G_MISS_CHAR,NULL,X_Attribute11),
        decode(X_Attribute12,FND_API.G_MISS_CHAR,NULL,X_Attribute12),
        decode(X_Attribute13,FND_API.G_MISS_CHAR,NULL,X_Attribute13),
        decode(X_Attribute14,FND_API.G_MISS_CHAR,NULL,X_Attribute14),
        decode(X_Attribute15,FND_API.G_MISS_CHAR,NULL,X_Attribute15),
        decode(X_Salesforce_Role_Code,FND_API.G_MISS_CHAR,NULL,X_Salesforce_Role_Code),
        decode(X_Salesforce_Relationship_Code,FND_API.G_MISS_CHAR,NULL,X_Salesforce_Relationship_Code),
        decode(X_Internal_update_access,FND_API.G_MISS_NUM,NULL,X_Internal_update_access),
        decode(X_Sales_lead_id,FND_API.G_MISS_NUM,NULL,X_Sales_lead_id),
        decode(X_Sales_group_id,FND_API.G_MISS_NUM,NULL,X_Sales_group_id),
        decode(X_Partner_Cont_Party_id,FND_API.G_MISS_NUM,NULL,X_Partner_Cont_Party_Id),
         decode(X_owner_flag,FND_API.G_MISS_CHAR,'N',X_owner_flag),
	 decode(X_created_by_tap_flag,FND_API.G_MISS_CHAR,NULL,X_created_by_tap_flag),
	 decode(X_prm_keep_flag,FND_API.G_MISS_CHAR,NULL,X_prm_keep_flag),
         decode(X_open_flag, FND_API.G_MISS_CHAR, 'N', X_open_flag),
         decode(X_lead_rank_score, FND_API.G_MISS_NUM, NULL, X_lead_rank_score),
         decode(X_object_creation_date, FND_API.G_MISS_DATE, TO_DATE(NULL), X_object_creation_date),
         decode(X_contributor_flag, FND_API.G_MISS_CHAR, 'N', X_contributor_flag) -- Added for ASNB
  );

  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
END Insert_Row;

PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Access_Id                             NUMBER,
                   X_Access_Type                           VARCHAR2,
                   X_Freeze_Flag                           VARCHAR2,
                   X_Reassign_Flag                         VARCHAR2,
                   X_Team_Leader_Flag                      VARCHAR2,
                   X_Person_Id                             NUMBER,
                   X_Customer_Id                           NUMBER,
                   X_Address_Id                            NUMBER,
	  	   X_Salesforce_id			   NUMBER,
                   X_Partner_Customer_Id                   NUMBER,
                   X_Partner_Address_Id                    NUMBER,
                   X_Created_Person_Id                     NUMBER,
                   X_Lead_Id                               NUMBER,
                   X_Freeze_Date                           DATE,
                   X_Reassign_Reason                       VARCHAR2,
		   x_reassign_request_date		    DATE,
		   x_reassign_requested_person_id          NUMBER,
                   X_Attribute_Category                    VARCHAR2,
                   X_Attribute1                            VARCHAR2,
                   X_Attribute2                            VARCHAR2,
                   X_Attribute3                            VARCHAR2,
                   X_Attribute4                            VARCHAR2,
                   X_Attribute5                            VARCHAR2,
                   X_Attribute6                            VARCHAR2,
                   X_Attribute7                            VARCHAR2,
                   X_Attribute8                            VARCHAR2,
                   X_Attribute9                            VARCHAR2,
                   X_Attribute10                           VARCHAR2,
                   X_Attribute11                           VARCHAR2,
                   X_Attribute12                           VARCHAR2,
                   X_Attribute13                           VARCHAR2,
                   X_Attribute14                           VARCHAR2,
                   X_Attribute15                           VARCHAR2,
		   X_Salesforce_Role_Code		   VARCHAR2,
		   X_Salesforce_Relationship_Code	   VARCHAR2,
		   X_Sales_lead_id                    NUMBER  ,
		   X_Sales_group_id                   NUMBER  ,
		   X_Partner_Cont_Party_id            NUMBER,
		   X_owner_flag	          VARCHAR2,
		   X_created_by_tap_flag	  VARCHAR2,
		   X_prm_keep_flag          VARCHAR2,
		   X_contributor_flag          VARCHAR2   -- Added for ASNB
) IS
  CURSOR C IS
      SELECT *
      FROM   as_accesses_all
      WHERE  rowid = X_Rowid
      FOR UPDATE of Access_Id  NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
  CLOSE C;
  if (
          (   (Recinfo.access_id = X_Access_Id)
           OR (    (Recinfo.access_id IS NULL)
               AND (X_Access_Id IS NULL)))
      AND (   (Recinfo.access_type = X_Access_Type)
           OR (    (Recinfo.access_type IS NULL)
               AND (X_Access_Type IS NULL)))
      AND (   (Recinfo.freeze_flag = X_Freeze_Flag)
           OR (    (Recinfo.freeze_flag IS NULL)
               AND (X_Freeze_Flag IS NULL)))
      AND (   (Recinfo.reassign_flag = X_Reassign_Flag)
           OR (    (Recinfo.reassign_flag IS NULL)
               AND (X_Reassign_Flag IS NULL)))
      AND (   (Recinfo.team_leader_flag = X_Team_Leader_Flag)
           OR (    (Recinfo.team_leader_flag IS NULL)
               AND (X_Team_Leader_Flag IS NULL)))
      AND (   (Recinfo.person_id = X_Person_Id)
           OR (    (Recinfo.person_id IS NULL)
               AND (X_Person_Id IS NULL)))
      AND (   (Recinfo.customer_id = X_Customer_Id)
           OR (    (Recinfo.customer_id IS NULL)
               AND (X_Customer_Id IS NULL)))
      AND (   (Recinfo.address_id = X_Address_Id)
           OR (    (Recinfo.address_id IS NULL)
               AND (X_Address_Id IS NULL)))
      AND (   (Recinfo.salesforce_id = X_Salesforce_Id)
           OR (    (Recinfo.Salesforce_id IS NULL)
               AND (X_Salesforce_Id IS NULL)))
      AND (   (Recinfo.partner_customer_id = X_Partner_Customer_Id)
           OR (    (Recinfo.partner_customer_id IS NULL)
               AND (X_Partner_Customer_Id IS NULL)))
      AND (   (Recinfo.partner_address_id = X_Partner_Address_Id)
           OR (    (Recinfo.partner_address_id IS NULL)
               AND (X_Partner_Address_Id IS NULL)))
      AND (   (Recinfo.created_person_id = X_Created_Person_Id)
           OR (    (Recinfo.created_person_id IS NULL)
               AND (X_Created_Person_Id IS NULL)))
      AND (   (Recinfo.lead_id = X_Lead_Id)
           OR (    (Recinfo.lead_id IS NULL)
               AND (X_Lead_Id IS NULL)))
      AND (   (Recinfo.freeze_date = X_Freeze_Date)
           OR (    (Recinfo.freeze_date IS NULL)
               AND (X_Freeze_Date IS NULL)))
      AND (   (Recinfo.reassign_reason = X_Reassign_Reason)
           OR (    (Recinfo.reassign_reason IS NULL)
               AND (X_Reassign_Reason IS NULL)))
	AND (   (Recinfo.reassign_request_date = x_reassign_request_date)
           OR (    (Recinfo.reassign_request_date IS NULL)
               AND (x_reassign_request_date IS NULL)))
      AND (   (Recinfo.reassign_requested_person_id = X_reassign_requested_person_id)
           OR (    (Recinfo.reassign_requested_person_id IS NULL)
               AND (X_reassign_requested_person_id IS NULL)))
      AND (   (Recinfo.attribute_category = X_Attribute_Category)
           OR (    (Recinfo.attribute_category IS NULL)
               AND (X_Attribute_Category IS NULL)))
      AND (   (Recinfo.attribute1 = X_Attribute1)
           OR (    (Recinfo.attribute1 IS NULL)
               AND (X_Attribute1 IS NULL)))
      AND (   (Recinfo.attribute2 = X_Attribute2)
           OR (    (Recinfo.attribute2 IS NULL)
               AND (X_Attribute2 IS NULL)))
      AND (   (Recinfo.attribute3 = X_Attribute3)
           OR (    (Recinfo.attribute3 IS NULL)
               AND (X_Attribute3 IS NULL)))
      AND (   (Recinfo.attribute4 = X_Attribute4)
           OR (    (Recinfo.attribute4 IS NULL)
               AND (X_Attribute4 IS NULL)))
      AND (   (Recinfo.attribute5 = X_Attribute5)
           OR (    (Recinfo.attribute5 IS NULL)
               AND (X_Attribute5 IS NULL)))
      AND (   (Recinfo.attribute6 = X_Attribute6)
           OR (    (Recinfo.attribute6 IS NULL)
               AND (X_Attribute6 IS NULL)))
      AND (   (Recinfo.attribute7 = X_Attribute7)
           OR (    (Recinfo.attribute7 IS NULL)
               AND (X_Attribute7 IS NULL)))
      AND (   (Recinfo.attribute8 = X_Attribute8)
           OR (    (Recinfo.attribute8 IS NULL)
               AND (X_Attribute8 IS NULL)))
      AND (   (Recinfo.attribute9 = X_Attribute9)
           OR (    (Recinfo.attribute9 IS NULL)
               AND (X_Attribute9 IS NULL)))
      AND (   (Recinfo.attribute10 = X_Attribute10)
           OR (    (Recinfo.attribute10 IS NULL)
               AND (X_Attribute10 IS NULL)))
      AND (   (Recinfo.attribute11 = X_Attribute11)
           OR (    (Recinfo.attribute11 IS NULL)
               AND (X_Attribute11 IS NULL)))
      AND (   (Recinfo.attribute12 = X_Attribute12)
           OR (    (Recinfo.attribute12 IS NULL)
               AND (X_Attribute12 IS NULL)))
      AND (   (Recinfo.attribute13 = X_Attribute13)
           OR (    (Recinfo.attribute13 IS NULL)
               AND (X_Attribute13 IS NULL)))
      AND (   (Recinfo.attribute14 = X_Attribute14)
           OR (    (Recinfo.attribute14 IS NULL)
               AND (X_Attribute14 IS NULL)))
      AND (   (Recinfo.attribute15 = X_Attribute15)
           OR (    (Recinfo.attribute15 IS NULL)
               AND (X_Attribute15 IS NULL)))
      AND (   (Recinfo.salesforce_role_code = X_Salesforce_Role_Code)
           OR (    (Recinfo.salesforce_role_code IS NULL)
               AND (X_Salesforce_Role_Code IS NULL)))
      AND (   (Recinfo.salesforce_relationship_code = X_Salesforce_Relationship_Code)
           OR (    (Recinfo.salesforce_relationship_code IS NULL)
               AND (X_Salesforce_Relationship_Code IS NULL)))
      AND (   (Recinfo.sales_lead_id = X_Sales_lead_id)
           OR (    (Recinfo.Sales_lead_id IS NULL)
               AND (X_Sales_lead_id IS NULL)))
      AND (   (Recinfo.sales_group_id = X_Sales_group_id)
           OR (    (Recinfo.Sales_group_id IS NULL)
               AND (X_Sales_group_id IS NULL)))
      AND (   (Recinfo.partner_cont_party_id = X_Partner_Cont_Party_Id)
           OR (    (Recinfo.partner_cont_party_id IS NULL)
               AND (X_Partner_Cont_Party_Id IS NULL)))
	AND (   (Recinfo.owner_flag = X_owner_flag)
           OR (    (Recinfo.owner_flag IS NULL)
               AND (X_owner_flag IS NULL)))
	AND (   (Recinfo.created_by_tap_flag =X_created_by_tap_flag )
           OR (    (Recinfo.created_by_tap_flag IS NULL)
               AND (X_created_by_tap_flag IS NULL)))
	AND (   (Recinfo.prm_keep_flag = X_prm_keep_flag)
           OR (    (Recinfo.prm_keep_flag IS NULL)
               AND (X_prm_keep_flag IS NULL)))
-- Added for ASNB
	AND (   (Recinfo.contributor_flag = X_contributor_flag)
           OR (    (Recinfo.contributor_flag IS NULL)
               AND (X_contributor_flag IS NULL)))
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Access_Id                           NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Access_Type                         VARCHAR2,
                     X_Freeze_Flag                         VARCHAR2,
                     X_Reassign_Flag                       VARCHAR2,
                     X_Team_Leader_Flag                    VARCHAR2,
                     X_Person_Id                           NUMBER,
                     X_Customer_Id                         NUMBER,
                     X_Address_Id                          NUMBER,
		     X_Salesforce_Id			   NUMBER,
                     X_Partner_Customer_Id                 NUMBER,
                     X_Partner_Address_Id                  NUMBER,
                     X_Created_Person_Id                   NUMBER,
                     X_Lead_Id                             NUMBER,
                     X_Freeze_Date                         DATE,
                     X_Reassign_Reason                     VARCHAR2,
		     x_reassign_request_date		   DATE,
		     x_reassign_requested_person_id         NUMBER,
                     X_Attribute_Category                  VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Attribute11                         VARCHAR2,
                     X_Attribute12                         VARCHAR2,
                     X_Attribute13                         VARCHAR2,
                     X_Attribute14                         VARCHAR2,
                     X_Attribute15                         VARCHAR2,
                     X_Salesforce_Role_Code                VARCHAR2,
                     X_Salesforce_Relationship_Code        VARCHAR2,
				 X_Internal_update_access              NUMBER  ,
				 X_Sales_lead_id                       NUMBER  ,
				 X_Sales_group_id                      NUMBER  ,
				 X_Partner_Cont_Party_Id               NUMBER ,
			X_owner_flag	          VARCHAR2,
			X_created_by_tap_flag	  VARCHAR2,
			X_prm_keep_flag          VARCHAR2,
			X_contributor_flag          VARCHAR2 -- Added for ASNB
) IS
BEGIN
  UPDATE as_accesses_all
  SET object_version_number =  nvl(object_version_number,0) + 1,
    access_id                                 =    X_Access_Id,
    last_update_date                          =    X_Last_Update_Date,
    last_updated_by                           =    X_Last_Updated_By,
    last_update_login                         =    X_Last_Update_Login,
    access_type                               =    decode(X_Access_Type,FND_API.G_MISS_CHAR,access_type,X_Access_Type),
    freeze_flag                               =    decode(X_Freeze_Flag,FND_API.G_MISS_CHAR,freeze_flag,X_Freeze_Flag),
    reassign_flag                             =    decode(X_Reassign_Flag,FND_API.G_MISS_CHAR,reassign_flag,X_Reassign_Flag),
    team_leader_flag                          =    decode(X_Team_Leader_Flag,FND_API.G_MISS_CHAR,team_leader_flag,X_Team_Leader_Flag),
    person_id                                 =    decode(X_Person_Id,FND_API.G_MISS_NUM, person_id,X_Person_Id ),
    customer_id                               =   decode(X_Customer_Id,FND_API.G_MISS_NUM,customer_id,X_Customer_Id),
    address_id                                =    decode(X_Address_Id,FND_API.G_MISS_NUM,address_id,X_Address_Id ),
    salesforce_id                         = decode(X_Salesforce_Id,FND_API.G_MISS_NUM,salesforce_id,X_Salesforce_Id),
    partner_customer_id  =decode(X_Partner_Customer_Id,FND_API.G_MISS_NUM,partner_customer_id,X_Partner_Customer_Id),
    partner_address_id  = decode(X_Partner_Address_Id,FND_API.G_MISS_NUM,partner_address_id,X_Partner_Address_Id),
    created_person_id   =    decode(X_Created_Person_Id,FND_API.G_MISS_NUM,created_person_id,X_Created_Person_Id ),
    lead_id                                   = decode(X_Lead_Id,FND_API.G_MISS_NUM,lead_id,X_Lead_Id ),
    freeze_date                               =    decode(X_Freeze_Date,FND_API.G_MISS_DATE, freeze_date,X_Freeze_Date),
    reassign_reason                           =  decode(X_Reassign_Reason,FND_API.G_MISS_CHAR,reassign_reason,X_Reassign_Reason),
     reassign_request_date = decode(X_reassign_request_date,FND_API.G_MISS_DATE,
				reassign_request_date,X_reassign_request_date),
    reassign_requested_person_id = decode(X_reassign_requested_person_id ,FND_API.G_MISS_NUM,
					reassign_requested_person_id ,X_reassign_requested_person_id ),
    attribute_category = decode(X_Attribute_Category,FND_API.G_MISS_CHAR,attribute_category,X_Attribute_Category),
	      attribute1 = decode(X_Attribute1,FND_API.G_MISS_CHAR,attribute1,X_Attribute1),
              attribute2 = decode(X_Attribute2,FND_API.G_MISS_CHAR,attribute2,X_Attribute2),
              attribute3 = decode(X_Attribute3,FND_API.G_MISS_CHAR,attribute3,X_Attribute3),
              attribute4 = decode(X_Attribute4,FND_API.G_MISS_CHAR,attribute4,X_Attribute4),
              attribute5 = decode(X_Attribute5,FND_API.G_MISS_CHAR,attribute5,X_Attribute5),
              attribute6 = decode(X_Attribute6,FND_API.G_MISS_CHAR,attribute6,X_Attribute6),
              attribute7 = decode(X_Attribute7,FND_API.G_MISS_CHAR,attribute7,X_Attribute7),
              attribute8 = decode(X_Attribute8,FND_API.G_MISS_CHAR,attribute8,X_Attribute8),
              attribute9 = decode(X_Attribute9,FND_API.G_MISS_CHAR,attribute9,X_Attribute9),
              attribute10 = decode(X_Attribute10,FND_API.G_MISS_CHAR,attribute10,X_Attribute10),
              attribute11 = decode(X_Attribute11,FND_API.G_MISS_CHAR,attribute11,X_Attribute11),
              attribute12 = decode(X_Attribute12,FND_API.G_MISS_CHAR,attribute12,X_Attribute12),
              attribute13 = decode(X_Attribute13,FND_API.G_MISS_CHAR,attribute13,X_Attribute13),
              attribute14 = decode(X_Attribute14,FND_API.G_MISS_CHAR,attribute14,X_Attribute14),
              attribute15 = decode(X_Attribute15,FND_API.G_MISS_CHAR,attribute15,X_Attribute15),
              salesforce_role_code	= decode(X_Salesforce_Role_Code,FND_API.G_MISS_CHAR,salesforce_role_code,X_Salesforce_Role_Code),
              salesforce_relationship_code = decode(X_Salesforce_Relationship_Code,FND_API.G_MISS_CHAR,salesforce_relationship_code,X_Salesforce_Relationship_Code),
              internal_update_access = decode(X_Internal_update_access,FND_API.G_MISS_NUM,internal_update_access,X_Internal_update_access),
              sales_lead_id = decode(X_Sales_lead_id,FND_API.G_MISS_NUM,sales_lead_id,X_Sales_lead_id),
              sales_group_id = decode(X_Sales_group_id,FND_API.G_MISS_NUM,sales_group_id,X_Sales_group_id),
              partner_cont_party_id =decode(X_Partner_Cont_Party_id,FND_API.G_MISS_NUM,partner_cont_party_id,X_Partner_Cont_Party_Id),
	      owner_flag = decode(X_owner_flag,FND_API.G_MISS_CHAR,owner_flag,X_owner_flag),
	      created_by_tap_flag =   decode(X_created_by_tap_flag,FND_API.G_MISS_CHAR,created_by_tap_flag,X_created_by_tap_flag),
              prm_keep_flag = decode(X_prm_keep_flag,FND_API.G_MISS_CHAR,prm_keep_flag,X_prm_keep_flag),
              contributor_flag = decode(X_contributor_flag,FND_API.G_MISS_CHAR,contributor_flag,X_contributor_flag) -- Added for ASNB
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
END Update_Row;

PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN
  DELETE FROM as_accesses_all
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
END Delete_Row;

--
-- NAME
--   Emp_Access_Exists
--
-- ARGUMENTS
--   Access_Id
--   Customer_Id
--   Address_Id
--   Person_Id
--   Salesforce_Id
--   Lead_Id
--   Access_Type
-- HISTORY
--   30-JUN-94	J Sondergaard	Created
--   09-SEP-94  J Sondergaard   Now called Access_Exists
--				More arguments added after
--				as_salesforce got involved
--   12-OCT-94  J Sondergaard   Renamed to Emp_Access_Exists
--				Partner columns removed, and
--				access_type added
--   13-OCT-94  J Sondergaard   Added Lead_Id
--   23-AUG-95  K Lee           removed ACCESS_TYPE clause
--
FUNCTION Emp_Access_Exists(X_Access_Id	     NUMBER,
			   X_Customer_Id         NUMBER,
		           X_Address_Id          NUMBER,
		           X_Person_Id           NUMBER,
		           X_Salesforce_Id       NUMBER,
			   X_Lead_Id             NUMBER,
		           X_Access_Type         VARCHAR2) RETURN BOOLEAN IS
  X_Acc_Id  NUMBER;
BEGIN
  select access_id
    into X_Acc_Id
    from as_accesses_all
   where customer_id = X_Customer_Id
   --  and address_id = X_Address_Id
     and salesforce_id = X_Salesforce_Id
     and person_id = X_Person_Id
     and ( (lead_id = X_Lead_Id) or
	   (lead_id is null and X_Lead_Id is null)
         )
     and ( (access_id <> X_Access_Id) or
	   (X_Access_Id is NULL) );
  return TRUE;
EXCEPTION
  when NO_DATA_FOUND then return FALSE;
  when TOO_MANY_ROWS then return TRUE;
END;

-- NAME
--   Emp_Access_Exists
--   (Same as the other function just with an extra out parameter (X_Team_Leader_Flag).
--   This returns the team leader flag if access row is found else 'N'.
-- HISTORY
--   12-SEP-96  M Chatterjee   Created
--
FUNCTION Emp_Access_Exists(X_Access_Id            NUMBER,
                           X_Customer_Id          NUMBER,
                           X_Address_Id           NUMBER,
                           X_Person_Id            NUMBER,
                           X_Salesforce_Id        NUMBER,
                           X_Lead_Id              NUMBER,
                           X_Access_Type          VARCHAR2,
                           X_Team_Leader_FLag OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS
  cursor Get_Access_Row (x_customer_id number, x_address_id number, x_salesforce_id number,
                         x_person_id number, x_lead_id number) IS
  select Team_Leader_Flag
    from as_accesses_all
   where customer_id   = X_Customer_Id
--     and address_id    = X_Address_Id
     and salesforce_id = X_Salesforce_Id
     and person_id     = X_Person_Id
     and ( (lead_id    = X_Lead_Id) or
           (lead_id is null and X_Lead_Id is null)
         );
  T_Team_Leader_Flag  Varchar2(1);
BEGIN
  X_Team_Leader_Flag := 'N';
  Open Get_Access_Row (x_customer_id, x_address_id, x_salesforce_id, x_person_id, x_lead_id);
  Fetch Get_Access_Row Into T_Team_Leader_Flag;
  If (Get_Access_Row%NOTFOUND)
  Then
    Close Get_Access_Row;
    return FALSE;
  End If;
  Close Get_Access_Row;
  X_Team_Leader_Flag := Nvl(T_Team_Leader_Flag,'N');
  return TRUE;
EXCEPTION
  when NO_DATA_FOUND then return FALSE;
  when TOO_MANY_ROWS then return TRUE;
END Emp_Access_Exists;


--
-- NAME
--   Ptr_Access_Exists
--
-- ARGUMENTS
--   Access_Id
--   Customer_Id
--   Address_Id
--   Partner_Customer_Id
--   Partner_Address_Id
--   Salesforce_Id
--   Lead_Id
--   Access_Type
-- HISTORY
--   12-OCT-94	J Sondergaard	Created
--   13-OCT-94  J Sondergaard   Added Lead_Id
--   23-AUG-95  K Lee           removed ACCESS_TYPE clause
--
FUNCTION Ptr_Access_Exists(X_Access_Id	         NUMBER,
		           X_Customer_Id         NUMBER,
		           X_Address_Id          NUMBER,
		           X_Partner_Customer_Id NUMBER,
			   X_Partner_Address_Id  NUMBER,
		           X_Salesforce_Id       NUMBER,
			   X_Lead_Id		 NUMBER,
		           X_Access_Type         VARCHAR2) RETURN BOOLEAN IS
  X_Acc_Id  NUMBER;
BEGIN
  select access_id
    into X_Acc_Id
    from as_accesses_all
   where customer_id = X_Customer_Id
--     and address_id = X_Address_Id
     and salesforce_id = X_Salesforce_Id
     and partner_customer_id = X_Partner_Customer_Id
--     and partner_address_id = X_Partner_Address_Id
     and ( (lead_id = X_Lead_Id) or
	   (lead_id is null and X_Lead_Id is null)
         )
     and ( (access_id <> X_Access_Id) or
	   (X_Access_Id is NULL) );
  return TRUE;
EXCEPTION
  when NO_DATA_FOUND then return FALSE;
  when TOO_MANY_ROWS then return TRUE;
END;


END AS_ACCESSES_PKG;

/
