--------------------------------------------------------
--  DDL for Package Body FA_CUA_HR_DISTRIBUTION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_CUA_HR_DISTRIBUTION_PKG" AS
/* $Header: FACHRDSMB.pls 120.1.12010000.3 2009/08/20 14:19:02 bridgway ship $ */

Procedure Insert_row (     x_rowid      in out nocopy varchar2
             , x_distribution_id    in out nocopy number
             , x_dist_set_id      in number
             , x_book_type_code in varchar2
             , x_distribution_line_percentage  in number
             , x_code_combination_id in number
             , x_location_id    in number
             , x_assigned_to    in number
             , X_CREATION_DATE  in date
             , X_CREATED_BY     in number
             , X_LAST_UPDATE_DATE   in date
             , X_LAST_UPDATED_BY    in number
             , X_LAST_UPDATE_LOGIN  in number
    , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null)
 is
 Cursor C1 is Select ROWID from FA_HIERARCHY_DISTRIBUTIONS
    where distribution_id = x_distribution_id;
 CURSOR C is Select FA_HIERARCHY_DISTRIBUTIONS_S.nextval from sys.dual;
 Begin
     if X_distribution_id is null then
        open C;
        fetch C into X_distribution_id ;
        close C;
     end if;
    insert into FA_HIERARCHY_DISTRIBUTIONS
                     (      distribution_id
                 ,  dist_set_id
                         ,  book_type_code
                         ,  distribution_line_percentage
                         ,  code_combination_id
                         ,  location_id
                         ,  assigned_to
                         ,  CREATION_DATE
                         ,  CREATED_BY
                         ,  LAST_UPDATE_DATE
                         ,  LAST_UPDATED_BY
                         ,  LAST_UPDATE_LOGIN
                      ) Values
                      (    x_distribution_id
                 , x_dist_set_id
                         , x_book_type_code
                         , x_distribution_line_percentage
                         , x_code_combination_id
                         , x_location_id
                         , x_assigned_to
                         , X_CREATION_DATE
                         , X_CREATED_BY
                         , X_LAST_UPDATE_DATE
                         , X_LAST_UPDATED_BY
                         , X_LAST_UPDATE_LOGIN
            );

    Open C1;
    fetch C1 into x_rowid;
        if (C1%NOTFOUND) then
          close C1;
          raise no_data_found;
        end if;
        close C1;
   end INSERT_ROW;



 procedure LOCK_ROW (     x_rowid       in  varchar2
             , x_distribution_id    in  number
         , x_dist_set_id        in number
             , x_book_type_code in varchar2
             , x_distribution_line_percentage  in number
             , x_code_combination_id in number
             , x_location_id    in number
             , x_assigned_to    in number
            , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null)
is
Cursor C1 is
   Select
          book_type_code
        , distribution_id
        , dist_set_id
        , distribution_line_percentage
        , code_combination_id
        , location_id
        , assigned_to
   from FA_HIERARCHY_DISTRIBUTIONS
   where rowid = x_rowid
   FOR UPDATE NOWAIT;
   tlinfo C1%ROWTYPE;
 begin
   open C1;
   fetch c1 into tlinfo;
  if (c1%notfound) then
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
    close c1;
    return;
  end if;
  close c1;
  if (
        (tlinfo.distribution_id = x_distribution_id)
      AND (tlinfo.dist_set_id = x_dist_set_id)
      AND (tlinfo.book_type_code = x_book_type_code)
      AND (tlinfo.distribution_line_percentage = x_distribution_line_percentage)
      AND ((tlinfo.code_combination_id = X_code_combination_id)
           OR ((tlinfo.code_combination_id is null)
               AND (X_code_combination_id is null)))
      AND ((tlinfo.location_id = X_location_id)
           OR ((tlinfo.location_id is null)
               AND (X_location_id is null)))
      AND ((tlinfo.assigned_to = X_assigned_to)
           OR ((tlinfo.assigned_to is null)
               AND (X_assigned_to is null)))
     ) then
      null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;

End lock_row;

procedure UPDATE_ROW (    x_rowid       in  varchar2
             , x_distribution_id    in  number
         , x_dist_set_id        in number
             , x_book_type_code in varchar2
             , x_distribution_line_percentage  in number
             , x_code_combination_id in number
             , x_location_id    in number
             , x_assigned_to    in number
             , X_LAST_UPDATE_DATE   in date
             , X_LAST_UPDATED_BY    in number
             , X_LAST_UPDATE_LOGIN  in number
            , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null)
is
Begin
update FA_HIERARCHY_DISTRIBUTIONS
  set
       book_type_code = x_book_type_code
     , distribution_line_percentage = x_distribution_line_percentage
     , code_combination_id = x_code_combination_id
     , location_id = x_location_id
     , assigned_to =  x_assigned_to
     , LAST_UPDATE_DATE = X_LAST_UPDATE_DATE
     , LAST_UPDATED_BY = X_LAST_UPDATED_BY
     , LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where rowid = x_rowid;
  if (sql%notfound) then
    raise no_data_found;
  end if;
End update_row;

procedure DELETE_ROW (
                         x_rowid      in varchar2
            , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null)
is
Begin
 delete from FA_HIERARCHY_DISTRIBUTIONS
 where rowid = x_rowid;
 if (sql%notfound) then
    raise no_data_found;
 end if;
End delete_row;

end FA_CUA_HR_DISTRIBUTION_PKG ;

/
