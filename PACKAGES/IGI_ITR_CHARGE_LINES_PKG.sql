--------------------------------------------------------
--  DDL for Package IGI_ITR_CHARGE_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_ITR_CHARGE_LINES_PKG" AUTHID CURRENT_USER as
-- $Header: igiitrts.pls 120.3.12000000.1 2007/09/12 10:32:54 mbremkum ship $
--

  PROCEDURE  Insert_Row(X_Rowid                            IN OUT NOCOPY VARCHAR2,
                        X_It_Service_Line_Id               IN OUT NOCOPY NUMBER,
                        X_It_Header_Id                     NUMBER,
                        X_It_Line_Num                      NUMBER,
                        X_Set_Of_Books_Id                  NUMBER,
                        X_Receiving_Ccid                   NUMBER,
                        X_Creation_Ccid                    NUMBER,
                        X_Charge_Center_Id                 NUMBER,
                        X_Charge_Service_Id                NUMBER,
                        X_Service_Id                       NUMBER,
                        X_Crea_Cost_Center                 VARCHAR2,
                        X_Crea_Conf_Segment_Value          VARCHAR2,
                        X_Recv_Cost_Center                 VARCHAR2,
                        X_Recv_Conf_Segment_Value          VARCHAR2,
                        X_Effective_Date                   DATE,
                        X_Entered_Dr                       NUMBER,
                        X_Entered_Cr                       NUMBER,
                        X_Description                      VARCHAR2,
                        X_Status_Flag                      VARCHAR2,
                        X_Posting_Flag                     VARCHAR2,
                        X_Submit_Date                      DATE,
                        X_Suggested_Amount                 NUMBER,
                        X_Rejection_Note                   VARCHAR2,
                        X_Failed_Funds_Lookup_code         VARCHAR2,
                        X_Encumbrance_Flag                 VARCHAR2,
                        X_Encumbered_Amount                NUMBER,
                        X_Unencumbered_Amount              NUMBER,
                        X_Gl_Encumbered_Date               DATE,
                        X_Gl_Encumbered_Period_Name        VARCHAR2,
                        X_Gl_Cancelled_Date                DATE,
                        X_Prevent_Encumbrance_Flag         VARCHAR2,
                        X_Je_Header_Id                     NUMBER,
                        X_Receiver_Id                      NUMBER,
                        X_Charge_Range_Id                  NUMBER,
                        X_Creation_Date                    DATE,
                        X_Created_By                       NUMBER,
                        X_Last_Update_Login                NUMBER,
                        X_Last_Update_Date                 DATE,
                        X_Last_Updated_By                  NUMBER
  );



  PROCEDURE    Lock_Row(X_Rowid                            VARCHAR2,
                        X_It_Service_Line_Id               NUMBER,
                        X_It_Header_Id                     NUMBER,
                        X_It_Line_Num                      NUMBER,
                        X_Set_Of_Books_Id                  NUMBER,
                        X_Receiving_Ccid                   NUMBER,
                        X_Creation_Ccid                    NUMBER,
                        X_Charge_Center_Id                 NUMBER,
                        X_Charge_Service_Id                NUMBER,
                        X_Service_Id                       NUMBER,
                        X_Crea_Cost_Center                 VARCHAR2,
                        X_Crea_Conf_Segment_Value          VARCHAR2,
                        X_Recv_Cost_Center                 VARCHAR2,
                        X_Recv_Conf_Segment_Value          VARCHAR2,
                        X_Effective_Date                   DATE,
                        X_Entered_Dr                       NUMBER,
                        X_Entered_Cr                       NUMBER,
                        X_Description                      VARCHAR2,
                        X_Status_Flag                      VARCHAR2,
                        X_Posting_Flag                     VARCHAR2,
                        X_Submit_Date                      DATE,
                        X_Suggested_Amount                 NUMBER,
                        X_Rejection_Note                   VARCHAR2,
                        X_Failed_Funds_Lookup_code         VARCHAR2,
                        X_Encumbrance_Flag                 VARCHAR2,
                        X_Encumbered_Amount                NUMBER,
                        X_Unencumbered_Amount              NUMBER,
                        X_Gl_Encumbered_Date               DATE,
                        X_Gl_Encumbered_Period_Name        VARCHAR2,
                        X_Gl_Cancelled_Date                DATE,
                        X_Prevent_Encumbrance_Flag         VARCHAR2,
                        X_Je_Header_Id                     NUMBER,
                        X_Receiver_Id                      NUMBER,
                        X_Charge_Range_Id                  NUMBER
  );



  PROCEDURE  Update_Row(X_Rowid                            VARCHAR2,
                        X_It_Service_Line_Id               NUMBER,
                        X_It_Header_Id                     NUMBER,
                        X_It_Line_Num                      NUMBER,
                        X_Set_Of_Books_Id                  NUMBER,
                        X_Receiving_Ccid                   NUMBER,
                        X_Creation_Ccid                    NUMBER,
                        X_Charge_Center_Id                 NUMBER,
                        X_Charge_Service_Id                NUMBER,
                        X_Service_Id                       NUMBER,
                        X_Crea_Cost_Center                 VARCHAR2,
                        X_Crea_Conf_Segment_Value          VARCHAR2,
                        X_Recv_Cost_Center                 VARCHAR2,
                        X_Recv_Conf_Segment_Value          VARCHAR2,
                        X_Effective_Date                   DATE,
                        X_Entered_Dr                       NUMBER,
                        X_Entered_Cr                       NUMBER,
                        X_Description                      VARCHAR2,
                        X_Status_Flag                      VARCHAR2,
                        X_Posting_Flag                     VARCHAR2,
                        X_Submit_Date                      DATE,
                        X_Suggested_Amount                 NUMBER,
                        X_Rejection_Note                   VARCHAR2,
                        X_Failed_Funds_Lookup_code         VARCHAR2,
                        X_Encumbrance_Flag                 VARCHAR2,
                        X_Encumbered_Amount                NUMBER,
                        X_Unencumbered_Amount              NUMBER,
                        X_Gl_Encumbered_Date               DATE,
                        X_Gl_Encumbered_Period_Name        VARCHAR2,
                        X_Gl_Cancelled_Date                DATE,
                        X_Prevent_Encumbrance_Flag         VARCHAR2,
                        X_Je_Header_Id                     NUMBER,
                        X_Receiver_Id                      NUMBER,
                        X_Charge_Range_Id                  NUMBER,
                        X_Last_Update_Login                NUMBER,
                        X_Last_Update_Date                 DATE,
                        X_Last_Updated_By                  NUMBER
  );



   PROCEDURE Delete_Row(X_Rowid VARCHAR2);

   -- to check the service line number is unique for the cross charge
   PROCEDURE check_unique(X_Rowid         VARCHAR2,
                          X_It_Line_Num   NUMBER,
                          X_It_Header_Id  NUMBER);

   -- OPSF(I) ITR  Bug 1764441  22-May-2001  S Brewer Start(1)
   -- to delete lines when the header has been deleted
   PROCEDURE delete_lines(X_It_Header_Id NUMBER);
   -- OPSF(I) ITR  Bug 1764441  22-May-2001  S Brewer End(1)

END IGI_ITR_CHARGE_LINES_PKG;

 

/
