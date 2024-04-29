--------------------------------------------------------
--  DDL for Package PO_REQUISITION_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_REQUISITION_HEADERS_PKG" AUTHID CURRENT_USER as
/* $Header: POXRIH1S.pls 120.0 2005/06/01 20:30:07 appldev noship $ */


  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Requisition_Header_Id   IN OUT	NOCOPY NUMBER,
                       X_Preparer_Id                    NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Segment1                IN OUT NOCOPY VARCHAR2,
                       X_Summary_Flag                   VARCHAR2,
                       X_Enabled_Flag                   VARCHAR2,
                       X_Segment2                       VARCHAR2,
                       X_Segment3                       VARCHAR2,
                       X_Segment4                       VARCHAR2,
                       X_Segment5                       VARCHAR2,
                       X_Start_Date_Active              DATE,
                       X_End_Date_Active                DATE,
                       X_Last_Update_Login              NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
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
                       X_Closed_Code                    VARCHAR2,
		       X_Manual				BOOLEAN,
                       p_org_id                  IN     NUMBER   DEFAULT NULL     -- <R12 MOAC>
                      );

  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

/* Ben bug#465696 created this procedure to resolve the performance problem.
       See POXRIHDB.pls for detailed explanation.
*/

PROCEDURE get_real_segment1(x_requisition_header_id NUMBER,
                            x_type_lookup_code      VARCHAR2,
                            x_currency_code         VARCHAR2,
                            x_segment1       IN OUT NOCOPY VARCHAR2);

  PROCEDURE Check_Unique(X_rowid	VARCHAR2,
			 X_segment1	VARCHAR2);


  FUNCTION get_req_total(P_header_id NUMBER)
	   return number;
--  pragma restrict_references (get_req_total,WNDS);

/* Start Bug#3406460 overloaded the function to calculate header total*/
/* by rounding the line totals to the precision */

  FUNCTION get_req_total(P_header_id NUMBER,
                         P_currency_code VARCHAR2)
           return number;

/*End Bug #3406460*/
END PO_REQUISITION_HEADERS_PKG;

 

/
