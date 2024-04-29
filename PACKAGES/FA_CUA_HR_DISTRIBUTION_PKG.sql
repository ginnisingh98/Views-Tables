--------------------------------------------------------
--  DDL for Package FA_CUA_HR_DISTRIBUTION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_CUA_HR_DISTRIBUTION_PKG" AUTHID CURRENT_USER AS
/* $Header: FACHRDSMS.pls 120.1.12010000.3 2009/08/20 14:16:33 bridgway ship $ */
Procedure Insert_row (
               x_rowid      in out nocopy varchar2
             , x_distribution_id    in out nocopy number
             , x_dist_set_id      in number
             , x_book_type_code   in varchar2
             , x_distribution_line_percentage  in number
             , x_code_combination_id in number
             , x_location_id    in number
             , x_assigned_to    in number
             , X_CREATION_DATE  in date
             , X_CREATED_BY     in number
             , X_LAST_UPDATE_DATE   in date
             , X_LAST_UPDATED_BY    in number
             , X_LAST_UPDATE_LOGIN  in number
    , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null);

 procedure LOCK_ROW (
               x_rowid       in  varchar2
             , x_distribution_id    in  number
             , x_dist_set_id        in number
             , x_book_type_code   in varchar2
             , x_distribution_line_percentage  in number
             , x_code_combination_id in number
             , x_location_id    in number
             , x_assigned_to    in number
            , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null);
procedure UPDATE_ROW (    x_rowid       in  varchar2
                 , x_distribution_id    in  number
             , x_dist_set_id        in number
             , x_book_type_code   in varchar2
             , x_distribution_line_percentage  in number
             , x_code_combination_id in number
             , x_location_id    in number
             , x_assigned_to    in number
             , X_LAST_UPDATE_DATE   in date
             , X_LAST_UPDATED_BY    in number
             , X_LAST_UPDATE_LOGIN  in number
            , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null);

procedure DELETE_ROW (
                         x_rowid      in varchar2
            , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null);

end FA_CUA_HR_DISTRIBUTION_PKG ;

/
