--------------------------------------------------------
--  DDL for Package Body IGI_EXP_DIAL_HAND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_EXP_DIAL_HAND_PKG" AS
-- $Header: igiexpdb.pls 115.8 2003/08/09 11:37:41 rgopalan ship $

 PROCEDURE Insert_Row_DU( X_Rowid             IN OUT NOCOPY varchar2,
                          X_Dial_Unit_id            number,
                          X_Dial_Unit_Num           varchar2,
                          X_Trx_Type_Id             number,
                          X_Description             varchar2,
                          X_Third_Party_id          number,
                          X_Site_id                 number,
                          X_Status                  varchar2,
                          X_Amount                  number,
                          X_Trans_Unit_Id           number,
                          X_Doc_Type_Id             number,
			  X_curr_code		    varchar2,
                          X_Creation_Date           date,
                          X_Created_by              number,
                          X_Last_Update_login       number
                         ) IS

 BEGIN
   NULL;
 END Insert_Row_DU;


  PROCEDURE Lock_Row_DU(X_Rowid           varchar2,
                        X_Dial_Unit_id    number,
                        X_Description     varchar2,
                        X_Amount          number)
 IS
 BEGIN
   NULL;
 END Lock_Row_DU;

  PROCEDURE Update_Row_DU (X_Rowid             Varchar2,
                           X_Dial_Unit_id      Number,
                           X_Description       varchar2,
                           X_Amount            number,
                           X_Last_Update_login number,
                           X_Last_Updated_by   number,
                           X_Last_Update_Date  date
                         ) IS
 BEGIN
   NULL;
 END Update_Row_DU;

  PROCEDURE Delete_Row_DU(X_Rowid       varchar2) IS
 BEGIN
   NULL;
 END Delete_Row_DU;

  PROCEDURE Lock_Row_Doc(X_Rowid          varchar2,
                         X_Document_id    number,
                         X_Dial_Unit_link      varchar2
                         ) IS
  BEGIN
   NULL;
  END Lock_Row_Doc;

 PROCEDURE Update_Row_Doc(X_Rowid             varchar2,
                           X_Document_id      number,
                           X_Dial_Unit_link   varchar2
                        )
                     IS
 BEGIN
   NULL;
 END Update_Row_Doc;


END IGI_EXP_DIAL_HAND_PKG;

/
