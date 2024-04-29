--------------------------------------------------------
--  DDL for Package Body PO_REQUISITION_HEADERS_PKG2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_REQUISITION_HEADERS_PKG2" as
/* $Header: POXRIH3B.pls 120.4 2005/10/03 04:12:33 nipagarw noship $ */

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Requisition_Header_Id          NUMBER,
                       X_Preparer_Id                    NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Segment1                       VARCHAR2,
                       X_Summary_Flag                   VARCHAR2,
                       X_Enabled_Flag                   VARCHAR2,
                       X_Segment2                       VARCHAR2,
                       X_Segment3                       VARCHAR2,
                       X_Segment4                       VARCHAR2,
                       X_Segment5                       VARCHAR2,
                       X_Start_Date_Active              DATE,
                       X_End_Date_Active                DATE,
                       X_Last_Update_Login              NUMBER,
                       X_Description                    VARCHAR2,
                       X_Authorization_Status           VARCHAR2,
                       X_Note_To_Authorizer             VARCHAR2,
                       X_Type_Lookup_Code               VARCHAR2,
                       X_Transferred_To_Oe_Flag         VARCHAR2,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_On_Line_Flag                   VARCHAR2,
                       X_Preliminary_Research_Flag      VARCHAR2,
                       X_Research_Complete_Flag         VARCHAR2,
                       X_Preparer_Finished_Flag         VARCHAR2,
                       X_Preparer_Finished_Date         DATE,
                       X_Agent_Return_Flag              VARCHAR2,
                       X_Agent_Return_Note              VARCHAR2,
                       X_Cancel_Flag                    VARCHAR2,
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
                       X_Ussgl_Transaction_Code         VARCHAR2,
                       X_Government_Context             VARCHAR2,
                       X_Interface_Source_Code          VARCHAR2,
                       X_Interface_Source_Line_Id       NUMBER,
                       X_Closed_Code                    VARCHAR2

 ) IS
 BEGIN

   UPDATE PO_REQUISITION_HEADERS
   SET
     requisition_header_id             =     X_Requisition_Header_Id,
     preparer_id                       =     X_Preparer_Id,
     last_update_date                  =     X_Last_Update_Date,
     last_updated_by                   =     X_Last_Updated_By,
     segment1                          =     X_Segment1,
     summary_flag                      =     X_Summary_Flag,
     enabled_flag                      =     X_Enabled_Flag,
     segment2                          =     X_Segment2,
     segment3                          =     X_Segment3,
     segment4                          =     X_Segment4,
     segment5                          =     X_Segment5,
     start_date_active                 =     X_Start_Date_Active,
     end_date_active                   =     X_End_Date_Active,
     last_update_login                 =     X_Last_Update_Login,
     description                       =     X_Description,
     authorization_status              =     X_Authorization_Status,
     note_to_authorizer                =     X_Note_To_Authorizer,
     type_lookup_code                  =     X_Type_Lookup_Code,
     transferred_to_oe_flag            =     X_Transferred_To_Oe_Flag,
     attribute_category                =     X_Attribute_Category,
     attribute1                        =     X_Attribute1,
     attribute2                        =     X_Attribute2,
     attribute3                        =     X_Attribute3,
     attribute4                        =     X_Attribute4,
     attribute5                        =     X_Attribute5,
     on_line_flag                      =     X_On_Line_Flag,
     preliminary_research_flag         =     X_Preliminary_Research_Flag,
     research_complete_flag            =     X_Research_Complete_Flag,
     preparer_finished_flag            =     X_Preparer_Finished_Flag,
     preparer_finished_date            =     X_Preparer_Finished_Date,
     agent_return_flag                 =     X_Agent_Return_Flag,
     agent_return_note                 =     X_Agent_Return_Note,
     cancel_flag                       =     X_Cancel_Flag,
     attribute6                        =     X_Attribute6,
     attribute7                        =     X_Attribute7,
     attribute8                        =     X_Attribute8,
     attribute9                        =     X_Attribute9,
     attribute10                       =     X_Attribute10,
     attribute11                       =     X_Attribute11,
     attribute12                       =     X_Attribute12,
     attribute13                       =     X_Attribute13,
     attribute14                       =     X_Attribute14,
     attribute15                       =     X_Attribute15,
     government_context                =     X_Government_Context,
     interface_source_code             =     X_Interface_Source_Code,
     interface_source_line_id          =     X_Interface_Source_Line_Id,
     closed_code                       =     X_Closed_Code,
     tax_attribute_update_code         =     NVL(tax_attribute_update_code,'UPDATE')  --<eTax Integration R12>
   WHERE rowid = X_rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

  END Update_Row;

END PO_REQUISITION_HEADERS_PKG2;

/
