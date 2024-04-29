--------------------------------------------------------
--  DDL for Package IGI_EXP_DIAL_HAND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_EXP_DIAL_HAND_PKG" AUTHID CURRENT_USER AS
-- $Header: igiexpds.pls 115.8 2003/08/09 14:49:06 rgopalan ship $
 PROCEDURE Insert_Row_DU(
                          X_Rowid             IN OUT NOCOPY varchar2,
                          X_Dial_Unit_id      number,
                          X_Dial_Unit_Num     varchar2,
                          X_Trx_Type_Id       number,
                          X_Description       varchar2,
                          X_Third_Party_id    number,
                          X_Site_id           number,
                          X_Status            varchar2,
                          X_Amount            number,
                          X_Trans_Unit_Id     number,
                          X_Doc_Type_Id       number,
			  X_curr_code         varchar2,
                          X_Creation_Date     date,
                          X_Created_by        number,
                          X_Last_Update_login number);

  PROCEDURE Update_Row_DU(X_Rowid             varchar2,
                          X_Dial_Unit_id      number,
                          X_Description       varchar2,
                          X_Amount            number,
                          X_Last_Update_login number,
                          X_Last_Updated_by   number,
                          X_Last_Update_Date  date);

  PROCEDURE Lock_Row_DU(X_Rowid           varchar2,
                        X_Dial_Unit_id    number,
                        X_Description     varchar2,
                        X_Amount          number);

  PROCEDURE Delete_Row_DU(X_Rowid       varchar2);

  PROCEDURE Lock_Row_Doc(X_Rowid          varchar2,
                         X_Document_id    number,
                         X_Dial_Unit_link      varchar2);

  PROCEDURE Update_Row_Doc(X_Rowid          varchar2,
                           X_Document_id    number,
                           X_Dial_Unit_link      varchar2);

END;

 

/
