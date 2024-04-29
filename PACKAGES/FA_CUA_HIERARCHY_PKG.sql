--------------------------------------------------------
--  DDL for Package FA_CUA_HIERARCHY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_CUA_HIERARCHY_PKG" AUTHID CURRENT_USER AS
/* $Header: FACHRAHMS.pls 120.1.12010000.3 2009/08/20 14:18:27 bridgway ship $ */
/****
REM===========================================================================
REM $Header: FACHRAHMS.pls 120.1.12010000.3 2009/08/20 14:18:27 bridgway ship $
REM +========================================================================+
REM |     Copyright (c) 1993 Oracle Corporation  Redwood Shores, CA, USA     |
REM |                      All Rights Reserved                               |
REM +========================================================================+
REM |FILENAME                                                                |
REM |    FACHRAHS.pls                                                        |
REM |                                                                        |
REM |DESCRIPTION                                                             |
REM |    PL/SQL Body for package: FA_CUA_HIERARCHY_PKG                          |
REM |                                                                        |
REM |USAGE                                                                   |
REM |    sqlplus apps/apps @FACHRAHS.pls                                     |
REM |                                                                        |
REM |EXAMPLE                                                                 |
REM |    sqlplus apps/apps @FACHRAHS.pls                                     |
REM |                                                                        |
REM |HISTORY                                                                 |
REM |    21-Jan-99       S Murali Added Fn is_assets_attched_node            |
REM |    18-NOV-98       S Murali         Created                            |
REM |                                                                        |
REM |                                                                        |
REM +========================================================================+
REM

****/

g_asset_hierarchy_purpose_id    number;
g_book_type_code        varchar2(15);
g_name              varchar2(30);
g_parent_hierarchy_id       number;
g_err_code          varchar2(240);
g_err_stage         varchar2(240);
g_err_stack         varchar2(240);
global_level_number Number;

-- Declarations for Distribution Record type
   TYPE distribution_rec IS RECORD (
          distribution_line_percentage      NUMBER
        , code_combination_id               NUMBER
        , location_id                       NUMBER
        , assigned_to                       NUMBER
                                   );

   TYPE distribution_tabtype IS TABLE OF distribution_rec
   INDEX BY BINARY_INTEGER ;

   distribution_tab  distribution_tabtype;

Function set_global_level_number(p_level_number in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null)
return boolean;

Function get_global_level_number
return number;
pragma restrict_references (get_global_level_number,WNPS,WNDS);

Function validate_level_number(p_level_number in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null)
return boolean;

Procedure Insert_row (     x_rowid                      in out nocopy varchar2
                         , x_asset_hierarchy_purpose_id in  number
                         , x_asset_hierarchy_id     in out nocopy number
                         , x_name                   in varchar2 default null
                         , x_level_number           in NUMBER
                         , x_hierarchy_rule_set_id  in number
                         , X_CREATION_DATE          in date
                         , X_CREATED_BY             in number
                         , X_LAST_UPDATE_DATE       in date
                         , X_LAST_UPDATED_BY        in number
                         , X_LAST_UPDATE_LOGIN      in number
                         , x_description            in varchar2
                         , x_parent_hierarchy_id    in number
                         , x_lowest_level_flag      in number
                         , x_depreciation_start_date    in date
                         , x_asset_id               in number
                         , X_ATTRIBUTE_CATEGORY     in varchar2
                         , X_ATTRIBUTE1             in varchar2
                         , X_ATTRIBUTE2             in varchar2
                         , X_ATTRIBUTE3             in varchar2
                         , X_ATTRIBUTE4             in varchar2
                         , X_ATTRIBUTE5             in varchar2
                         , X_ATTRIBUTE6             in varchar2
                         , X_ATTRIBUTE7             in varchar2
                         , X_ATTRIBUTE8             in varchar2
                         , X_ATTRIBUTE9             in varchar2
                         , X_ATTRIBUTE10            in varchar2
                         , X_ATTRIBUTE11            in varchar2
                         , X_ATTRIBUTE12            in varchar2
                         , X_ATTRIBUTE13            in varchar2
                         , X_ATTRIBUTE14            in varchar2
                         , X_ATTRIBUTE15            in varchar2
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null);
--Function  to check an hierararchy node exists
Function check_node_exists ( x_name in varchar2
                            ,x_node_type in Varchar2
                            ,x_purpose_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null)
return Boolean;
--Function to check name is unique
Function check_name_unique(  x_event in varchar2
                            ,x_asset_hierarchy_id in number default null
                            ,x_name in varchar2
                            ,x_asset_id in number
                            ,x_purpose_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null)
return Boolean;

--Procedure to create the distribution set
Procedure create_distribution_set
                       ( x_dist_set_id                   out nocopy number
                        ,x_book_type_code             in     varchar2
                        ,x_distribution_tab           in     FA_CUA_HIERARCHY_PKG.distribution_tabtype
                        ,x_err_code                   in out nocopy varchar2
                        ,x_err_stage                  in out nocopy varchar2
                        ,x_err_stack                  in out nocopy varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null);

--Procedure to Validate Node Attribute Values
Procedure validate_node_attributes
                        (x_asset_hierarchy_purpose_id in number
                        ,x_asset_hierarchy_id         in number
                        ,x_level_number               in number
                        ,x_book_type_code             in varchar2
                        ,x_asset_category_id          in number default null
                        ,x_lease_id                   in NUMBER default null
                        ,x_asset_key_ccid             in number default null
                        ,x_serial_number              in varchar2 default null
                        ,x_life_end_date              in date default null
                        ,x_dist_set_id                in number default null
                        --,x_distribution_tab           in FA_CUA_HIERARCHY_PKG.distribution_tabtype
                        ,x_err_code                   in out nocopy varchar2
                        ,x_err_stage                  in out nocopy varchar2
                        ,x_err_stack                  in out nocopy varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null);

--Procedure To validate Node parameters
Procedure validate_node( x_calling_module in varchar2 default 'A'
                        ,x_asset_hierarchy_purpose_id in out nocopy number
                        ,x_book_type_code in varchar2
                        ,x_name           in varchar2 default null
                        ,x_level_number  in NUMBER default 0
                        ,x_parent_hierarchy_id in number
                        ,x_hierarchy_rule_set_id in number default null
                        ,x_err_code in out nocopy varchar2
                        ,x_err_stage in out nocopy varchar2
                        ,x_err_stack in out nocopy varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null);

 procedure create_node(
 -- Arguments required for Public APIs
  x_err_code                    in out nocopy varchar2
, x_err_stage                   in out nocopy Varchar2
, x_err_stack                   in out nocopy varchar2
  -- Arguments for Node Creation
, x_asset_hierarchy_purpose_id  in     NUMBER
, x_asset_hierarchy_id          in out nocopy NUMBER
, x_name                        in     VARCHAR2 default null
, x_level_number                in     NUMBER
, x_hierarchy_rule_set_id       in NUMBER  default null
, X_CREATION_DATE               in DATE    default trunc(sysdate)
, X_CREATED_BY                  in NUMBER  := FND_GLOBAL.USER_ID
, X_LAST_UPDATE_DATE            in DATE    default trunc(sysdate)
, X_LAST_UPDATED_BY             in NUMBER  := FND_GLOBAL.USER_ID
, X_LAST_UPDATE_LOGIN           in NUMBER  := FND_GLOBAL.USER_ID
, x_description                 in VARCHAR2 default null
, x_parent_hierarchy_id         in NUMBER  default null
, x_lowest_level_flag           in NUMBER  default null
, x_depreciation_start_date     in date default null
, x_asset_id                    in number   default null
, X_ATTRIBUTE_CATEGORY          in VARCHAR2 default null
, X_ATTRIBUTE1                  in VARCHAR2 default null
, X_ATTRIBUTE2                  in VARCHAR2 default null
, X_ATTRIBUTE3                  in VARCHAR2 default null
, X_ATTRIBUTE4                  in VARCHAR2 default null
, X_ATTRIBUTE5                  in VARCHAR2 default null
, X_ATTRIBUTE6                  in VARCHAR2 default null
, X_ATTRIBUTE7                  in VARCHAR2 default null
, X_ATTRIBUTE8                  in VARCHAR2 default null
, X_ATTRIBUTE9                  in VARCHAR2 default null
, X_ATTRIBUTE10                 in VARCHAR2 default null
, X_ATTRIBUTE11                 in VARCHAR2 default null
, X_ATTRIBUTE12                 in VARCHAR2 default null
, X_ATTRIBUTE13                 in VARCHAR2 default null
, X_ATTRIBUTE14                 in VARCHAR2 default null
, X_ATTRIBUTE15                 in VARCHAR2 default null
,p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null  );
--Procedure to create node along with the attributes
procedure create_node_with_attributes(
 -- Arguments required for Public APIs
  x_err_code                    in out nocopy varchar2
, x_err_stage                   in out nocopy Varchar2
, x_err_stack                   in out nocopy varchar2
  -- Arguments for Node Creation
, x_asset_hierarchy_purpose_id  in     NUMBER
, x_asset_hierarchy_id          in out nocopy NUMBER
, x_name                        in     VARCHAR2 default null
, x_level_number                in NUMBER
, x_hierarchy_rule_set_id       in NUMBER  default null
, X_CREATION_DATE               in DATE    default trunc(sysdate)
, X_CREATED_BY                  in NUMBER  := FND_GLOBAL.USER_ID
, X_LAST_UPDATE_DATE            in DATE    default trunc(sysdate)
, X_LAST_UPDATED_BY             in NUMBER  := FND_GLOBAL.USER_ID
, X_LAST_UPDATE_LOGIN           in NUMBER  := FND_GLOBAL.USER_ID
, x_description                 in VARCHAR2 default null
, x_parent_hierarchy_id         in NUMBER  default null
, x_lowest_level_flag           in NUMBER  default null
, x_depreciation_start_date     in date default null
, x_asset_id                    in number   default null
, X_ATTRIBUTE_CATEGORY          in VARCHAR2 default null
, X_ATTRIBUTE1                  in VARCHAR2 default null
, X_ATTRIBUTE2                  in VARCHAR2 default null
, X_ATTRIBUTE3                  in VARCHAR2 default null
, X_ATTRIBUTE4                  in VARCHAR2 default null
, X_ATTRIBUTE5                  in VARCHAR2 default null
, X_ATTRIBUTE6                  in VARCHAR2 default null
, X_ATTRIBUTE7                  in VARCHAR2 default null
, X_ATTRIBUTE8                  in VARCHAR2 default null
, X_ATTRIBUTE9                  in VARCHAR2 default null
, X_ATTRIBUTE10                 in VARCHAR2 default null
, X_ATTRIBUTE11                 in VARCHAR2 default null
, X_ATTRIBUTE12                 in VARCHAR2 default null
, X_ATTRIBUTE13                 in VARCHAR2 default null
, X_ATTRIBUTE14                 in VARCHAR2 default null
, X_ATTRIBUTE15                 in VARCHAR2 default null
--Parameters for Node Attributes
,x_attribute_book_type_code     in varchar2 default null
,x_asset_category_id            in number default null
,x_lease_id                     in NUMBER default null
,x_asset_key_ccid               in number default null
,x_serial_number                in varchar2 default null
,x_life_end_date                in date default null
,x_distribution_tab             in FA_CUA_HIERARCHY_PKG.distribution_tabtype default FA_CUA_HIERARCHY_PKG.distribution_tab
,p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null );


procedure LOCK_ROW (
  x_asset_hierarchy_purpose_id  in NUMBER
, x_asset_hierarchy_id          in NUMBER
--, x_book_type_code        in varchar2
, x_name                        in VARCHAR2
, x_level_number                in Number
, x_hierarchy_rule_set_id       in NUMBER
, x_description                 in VARCHAR2
, x_parent_hierarchy_id         in NUMBER
, x_lowest_level_flag           in NUMBER
, x_depreciation_start_date     in date
, x_asset_id            in number
, X_ATTRIBUTE_CATEGORY          in VARCHAR2
, X_ATTRIBUTE1                  in VARCHAR2
, X_ATTRIBUTE2                  in VARCHAR2
, X_ATTRIBUTE3                  in VARCHAR2
, X_ATTRIBUTE4                  in VARCHAR2
, X_ATTRIBUTE5                  in VARCHAR2
, X_ATTRIBUTE6                  in VARCHAR2
, X_ATTRIBUTE7                  in VARCHAR2
, X_ATTRIBUTE8                  in VARCHAR2
, X_ATTRIBUTE9                  in VARCHAR2
, X_ATTRIBUTE10                 in VARCHAR2
, X_ATTRIBUTE11                 in VARCHAR2
, X_ATTRIBUTE12                 in VARCHAR2
, X_ATTRIBUTE13                 in VARCHAR2
, X_ATTRIBUTE14                 in VARCHAR2
, X_ATTRIBUTE15                 in VARCHAR2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null);



procedure UPDATE_ROW (
  x_asset_hierarchy_purpose_id  in NUMBER
, x_asset_hierarchy_id          in NUMBER
--, x_book_type_code        in varchar2
, x_name                        in VARCHAR2
, x_level_number                in NUMBER
, x_hierarchy_rule_set_id       in NUMBER
, X_LAST_UPDATE_DATE            in DATE
, X_LAST_UPDATED_BY             in NUMBER
, X_LAST_UPDATE_LOGIN           in NUMBER
, x_description                 in VARCHAR2
, x_parent_hierarchy_id         in NUMBER
, x_lowest_level_flag           in NUMBER
, X_DEPRECIATION_START_DATE     in DATE
, x_asset_id            in number
, X_ATTRIBUTE_CATEGORY          in VARCHAR2
, X_ATTRIBUTE1                  in VARCHAR2
, X_ATTRIBUTE2                  in VARCHAR2
, X_ATTRIBUTE3                  in VARCHAR2
, X_ATTRIBUTE4                  in VARCHAR2
, X_ATTRIBUTE5                  in VARCHAR2
, X_ATTRIBUTE6                  in VARCHAR2
, X_ATTRIBUTE7                  in VARCHAR2
, X_ATTRIBUTE8                  in VARCHAR2
, X_ATTRIBUTE9                  in VARCHAR2
, X_ATTRIBUTE10                 in VARCHAR2
, X_ATTRIBUTE11                 in VARCHAR2
, X_ATTRIBUTE12                 in VARCHAR2
, X_ATTRIBUTE13                 in VARCHAR2
, X_ATTRIBUTE14                 in VARCHAR2
, X_ATTRIBUTE15                 in VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null);


procedure DELETE_ROW (
  x_asset_hierarchy_purpose_id in number
, X_asset_hierarchy_id in NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null);

Function check_lowest_level_node(x_asset_hierarchy_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null)
return Boolean;

Function check_asset_node(x_asset_hierarchy_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null)
return Boolean;

Function Check_asset_tied_node(x_asset_hierarchy_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null)
return BOOLEAN;

Function is_attribute_mandatory(x_hierarchy_purpose_id in number
                               ,x_level_number       in number
                               ,x_attribute_name     in varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null)
return Boolean;

Function is_child_exists(x_asset_hierarchy_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null)
return BOOLEAN;

Function is_assets_attached_node(x_node_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null) return boolean;

Function is_valid_line_percent(x_line_percent in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type    default null) return boolean;

Procedure wrapper_validate_node(p_log_level_rec        IN
FA_API_TYPES.log_level_rec_type   default null);

end FA_CUA_HIERARCHY_PKG ;

/
