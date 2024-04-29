--------------------------------------------------------
--  DDL for Package Body QUOTATION_APPROVALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QUOTATION_APPROVALS_PKG" as
/* $Header: POXAPQPB.pls 120.0 2005/06/01 21:02:18 appldev noship $ */


  PROCEDURE Insert_Row(	X_Rowid                  IN OUT NOCOPY VARCHAR2,
			X_Quotation_Approval_ID	 IN OUT	NOCOPY  NUMBER,
                        X_Approval_Type			 VARCHAR2,
			X_Approval_Reason		 VARCHAR2,
			X_Comments			 VARCHAR2,
			X_Approver_ID			 NUMBER,
			X_Start_Date_Active		 DATE,
			X_End_Date_Active		 DATE,
			X_Line_Location_ID		 NUMBER,
                       	X_Last_Update_Date               DATE,
			X_Last_Updated_By                NUMBER,
			X_Last_Update_Login		 NUMBER,
                        X_Creation_Date                  DATE,
                       	X_Created_By                     NUMBER,
                        X_Attribute_Category		 VARCHAR2,
			X_Attribute1			 VARCHAR2,
			X_Attribute2			 VARCHAR2,
			X_Attribute3			 VARCHAR2,
			X_Attribute4			 VARCHAR2,
			X_Attribute5			 VARCHAR2,
			X_Attribute6			 VARCHAR2,
			X_Attribute7			 VARCHAR2,
			X_Attribute8			 VARCHAR2,
			X_Attribute9			 VARCHAR2,
			X_Attribute10			 VARCHAR2,
                        X_Attribute11			 VARCHAR2,
			X_Attribute12			 VARCHAR2,
			X_Attribute13			 VARCHAR2,
			X_Attribute14			 VARCHAR2,
                      	X_Attribute15			 VARCHAR2,
			X_Request_ID			 NUMBER,
			X_Program_Application_ID	 NUMBER,
			X_Program_ID			 NUMBER,
			X_Program_Update_Date		 DATE,
			X_Org_ID			 NUMBER    --<R12 MOAC> uncommented /* 2493519 */
                       )
     IS

     CURSOR C IS SELECT rowid FROM PO_QUOTATION_APPROVALS
                 WHERE quotation_approval_id = X_Quotation_Approval_ID;

     CURSOR C2 IS SELECT po_quotation_approvals_s.nextval FROM sys.dual;

     BEGIN
      if (X_Quotation_Approval_Id is NULL) then
        OPEN C2;
        FETCH C2 INTO X_Quotation_Approval_ID;
        CLOSE C2;
      end if;


       INSERT INTO PO_QUOTATION_APPROVALS(
		quotation_approval_id,
		approval_type,
		approval_reason,
		comments,
		approver_id,
		start_date_active,
		end_date_active,
		line_location_id,
        	last_update_date,
        	last_updated_by,
        	last_update_login,
        	creation_date,
        	created_by,
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
		request_id,
		program_application_id,
		program_id,
		program_update_date,
                org_id         --<R12 MOAC> uncommented       /* 2493519 */
             ) VALUES (
		X_Quotation_Approval_ID,
                X_Approval_Type,
		X_Approval_Reason,
		X_Comments,
		X_Approver_ID,
		X_Start_Date_Active,
		X_End_Date_Active,
		X_Line_Location_ID,
                X_Last_Update_Date,
		X_Last_Updated_By,
		X_Last_Update_Login,
                X_Creation_Date,
                X_Created_By,
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
		X_Request_ID,
		X_Program_Application_ID,
		X_Program_ID,
		X_Program_Update_Date,
	        X_Org_ID	--<R12 MOAC> uncommented    /* 2493519 */
               );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;


 PROCEDURE Lock_Row   (X_Rowid                    	 VARCHAR2,
			X_Quotation_Approval_ID		 NUMBER,
                     	X_Approval_Type			 VARCHAR2,
			X_Approval_Reason		 VARCHAR2,
			X_Comments			 VARCHAR2,
			X_Approver_ID			 NUMBER,
			X_Start_Date_Active		 DATE,
			X_End_Date_Active		 DATE,
			X_Line_Location_ID		 NUMBER,
                       	X_Last_Update_Date               DATE,
			X_Last_Updated_By                NUMBER,
			X_Last_Update_Login		 NUMBER,
                        X_Creation_Date                  DATE,
                       	X_Created_By                     NUMBER,
                        X_Attribute_Category		 VARCHAR2,
			X_Attribute1			 VARCHAR2,
			X_Attribute2			 VARCHAR2,
			X_Attribute3			 VARCHAR2,
			X_Attribute4			 VARCHAR2,
			X_Attribute5			 VARCHAR2,
			X_Attribute6			 VARCHAR2,
			X_Attribute7			 VARCHAR2,
			X_Attribute8			 VARCHAR2,
			X_Attribute9			 VARCHAR2,
			X_Attribute10			 VARCHAR2,
                        X_Attribute11			 VARCHAR2,
			X_Attribute12			 VARCHAR2,
			X_Attribute13			 VARCHAR2,
			X_Attribute14			 VARCHAR2,
                      	X_Attribute15			 VARCHAR2,
			X_Request_ID			 NUMBER,
			X_Program_Application_ID	 NUMBER,
			X_Program_ID			 NUMBER,
			X_Program_Update_Date		 DATE,
			X_Org_ID			 NUMBER --<R12 MOAC> uncommented   /* bug2493519*/
                      )

     IS
        CURSOR C IS
        SELECT *
        FROM   PO_QUOTATION_APPROVALS
        WHERE  rowid = X_Rowid
        FOR UPDATE of QUOTATION_APPROVAL_ID NOWAIT;
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

               (Recinfo.quotation_approval_id = X_Quotation_Approval_ID)
 	AND (   (Recinfo.approval_type = X_Approval_Type)
                OR (    (Recinfo.approval_type IS NULL)
                    AND (X_Approval_Type IS NULL)))
	AND (   (Recinfo.approval_reason = X_Approval_Reason)
                OR (    (Recinfo.approval_reason IS NULL)
                    AND (X_Approval_Reason IS NULL)))
	AND (   (Recinfo.comments = X_Comments)
                OR (    (Recinfo.comments IS NULL)
		    AND (X_Comments IS NULL)))
	AND (   (Recinfo.approver_id = X_Approver_ID)
                OR (    (Recinfo.approver_id IS NULL)
                    AND (X_Approver_ID IS NULL)))
	AND (   (Recinfo.start_date_active = X_Start_Date_Active)
                OR (    (Recinfo.start_date_active IS NULL)
                    AND (X_Start_Date_Active IS NULL)))
	AND (   (Recinfo.end_date_active = X_End_Date_Active)
                OR (    (Recinfo.end_date_active IS NULL)
                    AND (X_End_Date_Active IS NULL)))
	AND (   (Recinfo.line_location_id = X_Line_Location_ID)
                OR (    (Recinfo.line_location_id IS NULL)
                    AND (X_Line_Location_ID IS NULL)))
	AND (   (Recinfo.last_update_date = X_Last_Update_Date)
                OR (    (Recinfo.last_update_date IS NULL)
                    AND (X_Last_Update_Date IS NULL)))
	AND (   (Recinfo.last_updated_by = X_Last_Updated_By)
                OR (    (Recinfo.last_updated_by IS NULL)
                    AND (X_Last_Updated_By IS NULL)))
	AND (   (Recinfo.last_update_login = X_Last_Update_Login)
                OR (    (Recinfo.last_update_login IS NULL)
                    AND (X_Last_Update_Login IS NULL)))
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
        AND (Recinfo.org_id = X_Org_ID)    --<R12 MOAC>   added
/* bug2493519*/
--          AND (   (Recinfo.org_id = X_Org_ID)
--                OR (    (Recinfo.org_id IS NULL)
--                    AND (X_Org_ID IS NULL)))

            ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                    	 VARCHAR2,
			X_Quotation_Approval_ID		 NUMBER,
                     	X_Approval_Type			 VARCHAR2,
			X_Approval_Reason		 VARCHAR2,
			X_Comments			 VARCHAR2,
			X_Approver_ID			 NUMBER,
			X_Start_Date_Active		 DATE,
			X_End_Date_Active		 DATE,
			X_Line_Location_ID		 NUMBER,
                       	X_Last_Update_Date               DATE,
			X_Last_Updated_By                NUMBER,
			X_Last_Update_Login		 NUMBER,
                        X_Attribute_Category		 VARCHAR2,
			X_Attribute1			 VARCHAR2,
			X_Attribute2			 VARCHAR2,
			X_Attribute3			 VARCHAR2,
			X_Attribute4			 VARCHAR2,
			X_Attribute5			 VARCHAR2,
			X_Attribute6			 VARCHAR2,
			X_Attribute7			 VARCHAR2,
			X_Attribute8			 VARCHAR2,
			X_Attribute9			 VARCHAR2,
			X_Attribute10			 VARCHAR2,
                        X_Attribute11			 VARCHAR2,
			X_Attribute12			 VARCHAR2,
			X_Attribute13			 VARCHAR2,
			X_Attribute14			 VARCHAR2,
                      	X_Attribute15			 VARCHAR2,
			X_Request_ID			 NUMBER,
			X_Program_Application_ID	 NUMBER,
			X_Program_ID			 NUMBER,
			X_Program_Update_Date		 DATE
		--	X_Org_ID			 NUMBER /* bug2493519*/
			)

   IS

 BEGIN

   UPDATE PO_QUOTATION_APPROVALS

   SET
               	quotation_approval_id	=	X_Quotation_Approval_ID,
		approval_type		=	X_Approval_Type,
		approval_reason		=	X_Approval_Reason,
		comments		=	X_Comments,
		approver_id		=	X_Approver_ID,
		start_date_active	=	X_Start_Date_Active,
		end_date_active		=	X_End_Date_Active,
		line_location_id	=	X_Line_Location_ID,
		last_update_date	=	X_Last_Update_Date,
		last_updated_by		=	X_Last_Updated_By,
		last_update_login	=	X_Last_Update_Login,
                attribute_category	=       X_Attribute_Category,
		attribute1		=	X_Attribute1,
		attribute2		=	X_Attribute2,
		attribute3		=	X_Attribute3,
		attribute4		=	X_Attribute4,
		attribute5		=	X_Attribute5,
		attribute6		=	X_Attribute6,
		attribute7		=	X_Attribute7,
		attribute8		=	X_Attribute8,
		attribute9		=	X_Attribute9,
		attribute10		=	X_Attribute10,
                attribute11		=	X_Attribute11,
		attribute12		=	X_Attribute12,
		attribute13		=	X_Attribute13,
		attribute14		=	X_Attribute14,
                attribute15		=	X_Attribute15,
		request_id		=	X_Request_ID,
		program_application_id	=	X_Program_Application_ID,
		program_id		=	X_Program_ID,
		program_update_date	=	X_Program_Update_Date
--		org_id			=	X_Org_ID /* bug2493519*/
   WHERE rowid = X_rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM PO_QUOTATION_APPROVALS
    WHERE  rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;

END QUOTATION_APPROVALS_PKG;

/
