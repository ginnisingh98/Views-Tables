--------------------------------------------------------
--  DDL for Package Body PO_HEADERS_PKG_S3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_HEADERS_PKG_S3" as
/* $Header: POXRFQHB.pls 120.1 2006/02/06 11:29:30 dedelgad noship $ */

/*===========================================================================

  PROCEDURE NAME:	Lock_Row()

===========================================================================*/

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Po_Header_Id                     NUMBER,
                     X_Agent_Id                         NUMBER,
                     X_Type_Lookup_Code                 VARCHAR2,
                     X_Segment1                         VARCHAR2,
                     X_Summary_Flag                     VARCHAR2,
                     X_Enabled_Flag                     VARCHAR2,
                     X_Segment2                         VARCHAR2,
                     X_Segment3                         VARCHAR2,
                     X_Segment4                         VARCHAR2,
                     X_Segment5                         VARCHAR2,
                     X_Vendor_Id                        NUMBER,
                     X_Vendor_Site_Id                   NUMBER,
                     X_Vendor_Contact_Id                NUMBER,
                     X_Ship_To_Location_Id              NUMBER,
                     X_Bill_To_Location_Id              NUMBER,
                     X_Terms_Id                         NUMBER,
                     X_Ship_Via_Lookup_Code             VARCHAR2,
                     X_Fob_Lookup_Code                  VARCHAR2,
                     X_Freight_Terms_Lookup_Code        VARCHAR2,
                     X_Status_Lookup_Code               VARCHAR2,
                     X_Currency_Code                    VARCHAR2,
                     X_Rate_Type                        VARCHAR2,
                     X_Rate_Date                        DATE,
                     X_Rate                             NUMBER,
                     X_From_Header_Id                   NUMBER,
                     X_From_Type_Lookup_Code            VARCHAR2,
                     X_Start_Date                       DATE,
                     X_End_Date                         DATE,
                     X_Revision_Num                     NUMBER,
-- Bug 902976, zxzhang, 10/04/99
-- Change REVISED_DATE from VarChar(25) to Date.
--                   X_Revised_Date                     VARCHAR2,
                     X_Revised_Date                     DATE,
                     X_Note_To_Vendor                   VARCHAR2,
                     X_Printed_Date                     DATE,
                     X_Comments                         VARCHAR2,
                     X_Reply_Date                       DATE,
                     X_Reply_Method_Lookup_Code         VARCHAR2,
                     X_Rfq_Close_Date                   DATE,
                     X_Quote_Type_Lookup_Code           VARCHAR2,
                     X_Quotation_Class_Code             VARCHAR2,
                     X_Quote_Warning_Delay              NUMBER,
                     X_Quote_Vendor_Quote_Number        VARCHAR2,
                     X_Closed_Date                      DATE,
                     X_Approval_Required_Flag           VARCHAR2,
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
        FROM   PO_HEADERS
        WHERE  rowid = X_Rowid
        FOR UPDATE of Po_Header_Id NOWAIT;
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

               (Recinfo.po_header_id = X_Po_Header_Id)
           AND (Recinfo.agent_id = X_Agent_Id)
           AND (Recinfo.type_lookup_code = X_Type_Lookup_Code)
           AND (Recinfo.segment1 = X_Segment1)
           AND (nvl(Recinfo.summary_flag,'N') = nvl(X_Summary_Flag,'N'))
           AND (nvl(Recinfo.enabled_flag,'N') = nvl(X_Enabled_Flag,'N'))
           AND (   (Recinfo.segment2 = X_Segment2)
                OR ((Recinfo.segment2 IS NULL)
                    AND (X_Segment2 IS NULL)))
           AND (   (Recinfo.segment3 = X_Segment3)
                OR (    (Recinfo.segment3 IS NULL)
                    AND (X_Segment3 IS NULL)))
           AND (   (Recinfo.segment4 = X_Segment4)
                OR (    (Recinfo.segment4 IS NULL)
                    AND (X_Segment4 IS NULL)))
           AND (   (Recinfo.segment5 = X_Segment5)
                OR (    (Recinfo.segment5 IS NULL)
                    AND (X_Segment5 IS NULL)))
           AND (   (Recinfo.vendor_id = X_Vendor_Id)
                OR (    (Recinfo.vendor_id IS NULL)
                    AND (X_Vendor_Id IS NULL)))
           AND (   (Recinfo.vendor_site_id = X_Vendor_Site_Id)
                OR (    (Recinfo.vendor_site_id IS NULL)
                    AND (X_Vendor_Site_Id IS NULL)))
           AND (   (Recinfo.vendor_contact_id = X_Vendor_Contact_Id)
                OR (    (Recinfo.vendor_contact_id IS NULL)
                    AND (X_Vendor_Contact_Id IS NULL)))
           AND (   (Recinfo.ship_to_location_id = X_Ship_To_Location_Id)
                OR (    (Recinfo.ship_to_location_id IS NULL)
                    AND (X_Ship_To_Location_Id IS NULL)))
           AND (   (Recinfo.bill_to_location_id = X_Bill_To_Location_Id)
                OR (    (Recinfo.bill_to_location_id IS NULL)
                    AND (X_Bill_To_Location_Id IS NULL)))
           AND (   (Recinfo.terms_id = X_Terms_Id)
                OR (    (Recinfo.terms_id IS NULL)
                    AND (X_Terms_Id IS NULL)))
           AND (   (Recinfo.ship_via_lookup_code = X_Ship_Via_Lookup_Code)
                OR (    (Recinfo.ship_via_lookup_code IS NULL)
                    AND (X_Ship_Via_Lookup_Code IS NULL)))
           AND (   (Recinfo.fob_lookup_code = X_Fob_Lookup_Code)
                OR (    (Recinfo.fob_lookup_code IS NULL)
                    AND (X_Fob_Lookup_Code IS NULL)))
           AND (   (Recinfo.freight_terms_lookup_code = X_Freight_Terms_Lookup_Code)
                OR (    (Recinfo.freight_terms_lookup_code IS NULL)
                    AND (X_Freight_Terms_Lookup_Code IS NULL)))
           AND (   (Recinfo.status_lookup_code = X_Status_Lookup_Code)
                OR (    (Recinfo.status_lookup_code IS NULL)
                    AND (X_Status_Lookup_Code IS NULL)))
           AND (   (Recinfo.currency_code = X_Currency_Code)
                OR (    (Recinfo.currency_code IS NULL)
                    AND (X_Currency_Code IS NULL)))
           AND (   (Recinfo.rate_type = X_Rate_Type)
                OR (    (Recinfo.rate_type IS NULL)
                    AND (X_Rate_Type IS NULL)))
           AND (   (trunc(Recinfo.rate_date) = trunc(X_Rate_Date))
                OR (    (Recinfo.rate_date IS NULL)
                    AND (X_Rate_Date IS NULL)))
           AND (   (Recinfo.rate = X_Rate)
                OR (    (Recinfo.rate IS NULL)
                    AND (X_Rate IS NULL)))
           AND (   (Recinfo.from_header_id = X_From_Header_Id)
                OR (    (Recinfo.from_header_id IS NULL)
                    AND (X_From_Header_Id IS NULL)))
           AND (   (Recinfo.from_type_lookup_code = X_From_Type_Lookup_Code)
                OR (    (Recinfo.from_type_lookup_code IS NULL)
                    AND (X_From_Type_Lookup_Code IS NULL)))
           AND (   (trunc(Recinfo.start_date) = trunc(X_Start_Date))
                OR (    (Recinfo.start_date IS NULL)
                    AND (X_Start_Date IS NULL)))
           AND (   (trunc(Recinfo.end_date) = trunc(X_End_Date))
                OR (    (Recinfo.end_date IS NULL)
                    AND (X_End_Date IS NULL)))
           AND (   (Recinfo.revision_num = X_Revision_Num)
                OR (    (Recinfo.revision_num IS NULL)
                    AND (X_Revision_Num IS NULL)))
           AND (   (trunc(Recinfo.revised_date) = trunc(X_Revised_Date))
                OR (    (Recinfo.revised_date IS NULL)
                    AND (X_Revised_Date IS NULL)))
           AND (   (Recinfo.note_to_vendor = X_Note_To_Vendor)
                OR (    (Recinfo.note_to_vendor IS NULL)
                    AND (X_Note_To_Vendor IS NULL)))
           AND (   (trunc(Recinfo.printed_date) = trunc(X_Printed_Date))
                OR (    (Recinfo.printed_date IS NULL)
                    AND (X_Printed_Date IS NULL)))
           AND (   (Recinfo.comments = X_Comments)
                OR (    (Recinfo.comments IS NULL)
                    AND (X_Comments IS NULL)))
           AND (   (trunc(Recinfo.reply_date) = trunc(X_Reply_Date))
                OR (    (Recinfo.reply_date IS NULL)
                    AND (X_Reply_Date IS NULL)))
           AND (   (Recinfo.reply_method_lookup_code = X_Reply_Method_Lookup_Code)
                OR (    (Recinfo.reply_method_lookup_code IS NULL)
                    AND (X_Reply_Method_Lookup_Code IS NULL)))

         )  then

            if (
               (   (trunc(Recinfo.rfq_close_date) = trunc(X_Rfq_Close_Date))
                OR (    (Recinfo.rfq_close_date IS NULL)
                    AND (X_Rfq_Close_Date IS NULL)))
           AND (   (Recinfo.quote_type_lookup_code = X_Quote_Type_Lookup_Code)
                OR (    (Recinfo.quote_type_lookup_code IS NULL)
                    AND (X_Quote_Type_Lookup_Code IS NULL)))
           AND (   (Recinfo.quotation_class_code = X_Quotation_Class_Code)
                OR (    (Recinfo.quotation_class_code IS NULL)
                    AND (X_Quotation_Class_Code IS NULL)))
           AND (   (Recinfo.quote_warning_delay = X_Quote_Warning_Delay)
                OR (    (Recinfo.quote_warning_delay IS NULL)
                    AND (X_Quote_Warning_Delay IS NULL)))
           AND (   (nvl(Recinfo.quote_vendor_quote_number,'0') = nvl(X_Quote_Vendor_Quote_Number,'0'))
                OR (    (Recinfo.quote_vendor_quote_number IS NULL)
                    AND (X_Quote_Vendor_Quote_Number IS NULL)))
           AND (   (trunc(Recinfo.closed_date) = trunc(X_Closed_Date))
                OR (    (Recinfo.closed_date IS NULL)
                    AND (X_Closed_Date IS NULL)))
           AND (   (nvl(Recinfo.approval_required_flag,'N') = nvl(X_Approval_Required_Flag,'N'))
                OR (    (Recinfo.approval_required_flag IS NULL)
                    AND (X_Approval_Required_Flag IS NULL)))
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
            ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    end if;
  else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;

  end if;

  END Lock_Row;


/*===========================================================================

  PROCEDURE NAME:	Update_Row()

===========================================================================*/

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Po_Header_Id                   NUMBER,
                       X_Agent_Id                       NUMBER,
                       X_Type_Lookup_Code               VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Segment1                       VARCHAR2,
                       X_Summary_Flag                   VARCHAR2,
                       X_Enabled_Flag                   VARCHAR2,
                       X_Segment2                       VARCHAR2,
                       X_Segment3                       VARCHAR2,
                       X_Segment4                       VARCHAR2,
                       X_Segment5                       VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Vendor_Id                      NUMBER,
                       X_Vendor_Site_Id                 NUMBER,
                       X_Vendor_Contact_Id              NUMBER,
                       X_Ship_To_Location_Id            NUMBER,
                       X_Bill_To_Location_Id            NUMBER,
                       X_Terms_Id                       NUMBER,
                       X_Ship_Via_Lookup_Code           VARCHAR2,
                       X_Fob_Lookup_Code                VARCHAR2,
                       X_Freight_Terms_Lookup_Code      VARCHAR2,
                       X_Status_Lookup_Code             VARCHAR2,
                       X_Currency_Code                  VARCHAR2,
                       X_Rate_Type                      VARCHAR2,
                       X_Rate_Date                      DATE,
                       X_Rate                           NUMBER,
                       X_From_Header_Id                 NUMBER,
                       X_From_Type_Lookup_Code          VARCHAR2,
                       X_Start_Date                     DATE,
                       X_End_Date                       DATE,
                       X_Revision_Num                   NUMBER,
-- Bug 902976, zxzhang, 10/04/99
-- Change REVISED_DATE from VarChar(25) to Date.
--                     X_Revised_Date                   VARCHAR2,
                       X_Revised_Date                   DATE,
                       X_Note_To_Vendor                 VARCHAR2,
                       X_Printed_Date                   DATE,
                       X_Comments                       VARCHAR2,
                       X_Reply_Date                     DATE,
                       X_Reply_Method_Lookup_Code       VARCHAR2,
                       X_Rfq_Close_Date                 DATE,
                       X_Quote_Type_Lookup_Code         VARCHAR2,
                       X_Quotation_Class_Code           VARCHAR2,
                       X_Quote_Warning_Delay            NUMBER,
                       X_Quote_Vendor_Quote_Number      VARCHAR2,
                       X_Closed_Date                    DATE,
                       X_Approval_Required_Flag         VARCHAR2,
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

 BEGIN

   UPDATE PO_HEADERS
   SET
     po_header_id                      =     X_Po_Header_Id,
     agent_id                          =     X_Agent_Id,
     type_lookup_code                  =     X_Type_Lookup_Code,
     last_update_date                  =     X_Last_Update_Date,
     last_updated_by                   =     X_Last_Updated_By,
     segment1                          =     X_Segment1,
     summary_flag                      =     X_Summary_Flag,
     enabled_flag                      =     X_Enabled_Flag,
     segment2                          =     X_Segment2,
     segment3                          =     X_Segment3,
     segment4                          =     X_Segment4,
     segment5                          =     X_Segment5,
     last_update_login                 =     X_Last_Update_Login,
     vendor_id                         =     X_Vendor_Id,
     vendor_site_id                    =     X_Vendor_Site_Id,
     vendor_contact_id                 =     X_Vendor_Contact_Id,
     ship_to_location_id               =     X_Ship_To_Location_Id,
     bill_to_location_id               =     X_Bill_To_Location_Id,
     terms_id                          =     X_Terms_Id,
     ship_via_lookup_code              =     X_Ship_Via_Lookup_Code,
     fob_lookup_code                   =     X_Fob_Lookup_Code,
     freight_terms_lookup_code         =     X_Freight_Terms_Lookup_Code,
     status_lookup_code                =     X_Status_Lookup_Code,
     currency_code                     =     X_Currency_Code,
     rate_type                         =     X_Rate_Type,
     rate_date                         =     X_Rate_Date,
     rate                              =     X_Rate,
     from_header_id                    =     X_From_Header_Id,
     from_type_lookup_code             =     X_From_Type_Lookup_Code,
     start_date                        =     X_Start_Date,
     end_date                          =     X_End_Date,
     revision_num                      =     X_Revision_Num,
     revised_date                      =     X_Revised_Date,
     note_to_vendor                    =     X_Note_To_Vendor,
     printed_date                      =     X_Printed_Date,
     comments                          =     X_Comments,
     reply_date                        =     X_Reply_Date,
     reply_method_lookup_code          =     X_Reply_Method_Lookup_Code,
     rfq_close_date                    =     X_Rfq_Close_Date,
     quote_type_lookup_code            =     X_Quote_Type_Lookup_Code,
     quotation_class_code              =     X_Quotation_Class_Code,
     quote_warning_delay               =     X_Quote_Warning_Delay,
     quote_vendor_quote_number         =     X_Quote_Vendor_Quote_Number,
     closed_date                       =     X_Closed_Date,
     approval_required_flag            =     X_Approval_Required_Flag,
     attribute_category                =     X_Attribute_Category,
     attribute1                        =     X_Attribute1,
     attribute2                        =     X_Attribute2,
     attribute3                        =     X_Attribute3,
     attribute4                        =     X_Attribute4,
     attribute5                        =     X_Attribute5,
     attribute6                        =     X_Attribute6,
     attribute7                        =     X_Attribute7,
     attribute8                        =     X_Attribute8,
     attribute9                        =     X_Attribute9,
     attribute10                       =     X_Attribute10,
     attribute11                       =     X_Attribute11,
     attribute12                       =     X_Attribute12,
     attribute13                       =     X_Attribute13,
     attribute14                       =     X_Attribute14,
     attribute15                       =     X_Attribute15

    WHERE rowid = X_rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

END Update_Row;

END PO_HEADERS_PKG_S3;

/
