--------------------------------------------------------
--  DDL for Package Body IGW_PROP_COMMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_PROP_COMMENTS_PKG" as
--$Header: igwprnpb.pls 115.4 2002/03/28 19:13:43 pkm ship    $

  PROCEDURE Insert_Row(X_Rowid IN OUT      VARCHAR2,
                       X_Proposal_Id       NUMBER,
                       X_Comment_Id        NUMBER,
                       X_Comments          VARCHAR2,
                       X_Last_Update_Date  DATE,
                       X_Last_Updated_By   NUMBER,
                       X_Creation_Date     DATE,
                       X_Created_By        NUMBER,
                       X_Last_Update_Login NUMBER) IS

CURSOR C IS SELECT rowid FROM IGW_PROP_COMMENTS
            WHERE comment_id = X_comment_ID;

BEGIN
  INSERT INTO IGW_PROP_COMMENTS( PROPOSAL_ID,
                                 COMMENT_ID,
                                 COMMENTS,
                                 LAST_UPDATE_DATE,
                                 LAST_UPDATED_BY,
                                 CREATION_DATE,
                                 CREATED_BY,
                                 LAST_UPDATE_LOGIN) VALUES
                                 ( X_Proposal_Id,
                                  X_Comment_Id        ,
                                  X_Comments          ,
                                  X_Last_Update_Date  ,
                                  X_Last_Updated_By   ,
                                  X_Creation_Date     ,
                                  X_Created_By        ,
                                  X_Last_Update_Login );
       Open c;
        Fetch c into X_rowid;
        if (c%NOTFOUND) then
           close c;
           RAISE NO_DATA_FOUND;
        end if;
        CLOSE c;
END Insert_row;

  PROCEDURE   Lock_Row(X_Rowid             VARCHAR2,
                       X_Proposal_Id       NUMBER,
                       X_Comment_Id        NUMBER,
                       X_Comments          VARCHAR2,
                       X_Last_Update_Date  DATE,
                       X_Last_Updated_By   NUMBER,
                       X_Creation_Date     DATE,
                       X_Created_By        NUMBER,
                       X_Last_Update_Login NUMBER) IS
   cursor c is select * from IGW_prop_comments
                 where rowid = X_rowid
                 for update of comment_id nowait;
   Recinfo c%rowtype;
  Begin
     open c;
     fetch c into Recinfo;
     if (c%NOTFOUND)  then
        CLOSE c;
     FND_MESSAGE.Set_Name('FND','FORM_RECORD_DELETED');
     APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE c;
    if ( (recinfo.comment_id = X_comment_id)
       AND  (Recinfo.proposal_id = X_proposal_id)
       AND  ((Recinfo.comments = X_comments) or
             ((Recinfo.comments is null) AND
              (X_comments is  null)))
       AND  (Recinfo.last_update_Date = X_last_update_Date)
       AND  (Recinfo.last_updated_by = X_last_updated_by)
       AND  (Recinfo.creation_date = X_creation_date)
       AND  (Recinfo.created_by = X_created_by)
       AND  (Recinfo.last_update_login = X_last_update_login)) then
     return;
    else
       FND_MESSAGE.set_name('FND','FORM_RECORD_CHANGED');
       APP_EXCEPTION.Raise_Exception;
   end if;
 END Lock_row;

  PROCEDURE Update_Row(X_Rowid               VARCHAR2,
                       X_Proposal_Id       NUMBER,
                       X_Comment_Id        NUMBER,
                       X_Comments          VARCHAR2,
                       X_Last_Update_Date  DATE,
                       X_Last_Updated_By   NUMBER,
                       X_Creation_Date     DATE,
                       X_Created_By        NUMBER,
                       X_Last_Update_Login NUMBER) IS
  begin
   update igw_prop_comments
   set  proposal_id = X_proposal_id,
        comment_id = X_comment_id,
        comments  = X_comments,
        last_update_date = X_last_update_date,
        last_updated_by = X_last_updated_by,
        creation_date = X_creation_date,
        created_by = X_created_by,
        last_update_login = X_last_update_login
   where rowid = X_Rowid;
   if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
   end if;
 End update_row;

  PROCEDURE Delete_Row(X_Rowid             VARCHAR2) is
  begin
  delete igw_prop_comments
  where rowid = X_Rowid;
  END Delete_row;

END IGW_PROP_COMMENTS_PKG;

/
