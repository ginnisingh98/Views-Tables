--------------------------------------------------------
--  DDL for Package BIS_LOV_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_LOV_PUB" AUTHID CURRENT_USER as
/* $Header: BISPLOVS.pls 120.2 2005/12/28 06:02:33 ashankar noship $ */
c_asterisk CONSTANT varchar2(1) := '*';
c_plus     CONSTANT varchar2(1) := '+';
c_amp      CONSTANT varchar2(1) := '&';
c_percent  CONSTANT varchar2(1) := '%';
c_rowcount CONSTANT pls_integer := 20;

-- Set the colors for the appropriate areas
c_pgbgcolor    CONSTANT varchar2(30) := '#eaeff5'; --#88BBEE
c_fmbgcolor    CONSTANT varchar2(30) := '#88BBEE';
c_rowcolor     CONSTANT varchar2(30) := '#F2F2F5';
c_tblsurnd     CONSTANT varchar2(30) := '#a6a9b5';
c_rowHeader    CONSTANT VARCHAR2(30) := '#999999';

-- Set the translated strings from the database
c_of           CONSTANT varchar2(100) := BIS_UTILITIES_PVT.getPrompt('BIS_OF');
c_to           CONSTANT varchar2(100) := BIS_UTILITIES_PVT.getPrompt('BIS_TO');
c_listofvalues CONSTANT varchar2(100) := BIS_UTILITIES_PVT.getPrompt('BIS_LISTOFVALUES');
c_previous     CONSTANT varchar2(100) := BIS_UTILITIES_PVT.getPrompt('BIS_PREVIOUS');
c_next         CONSTANT varchar2(100) := BIS_UTILITIES_PVT.getPrompt('BIS_NEXT');
c_find         CONSTANT varchar2(100) := BIS_UTILITIES_PVT.getPrompt('BIS_FIND');
c_values       CONSTANT varchar2(100) := BIS_UTILITIES_PVT.getPrompt('BIS_VALUES');
c_cancel       CONSTANT varchar2(100) := BIS_UTILITIES_PVT.getPrompt('BIS_CANCEL');
c_possible     CONSTANT varchar2(100) := BIS_UTILITIES_PVT.getPrompt('BIS_POSSIBLE');

type column_info is RECORD (header       varchar2(200),
                            value        varchar2(1),
                            link         varchar2(1),
                            display      varchar2(1)
                            );

type colinfo_table is table of column_info index by binary_integer;
type colstore_table is table of varchar2(32000) index by binary_integer;

/*
procedure main  (p_procname      in  varchar2      default NULL
                    ,p_qrycnd        in  varchar2      default NULl
                    ,p_jsfuncname    in  varchar2      default NULL
                    ,p_startnum      in  pls_integer   default NULL
                    ,p_rowcount      in  pls_integer   default NULL
                    ,p_totalcount    in  pls_integer   default NULL
                    ,p_search_str    in  varchar2      default NULL
                    ,p_sql           in  varchar2      default NULL
                    ,p_sqlcount      in  varchar2      default NULL
                    ,p_coldata       in  colinfo_table);
*/

procedure main
( p_procname               in  varchar2 default NULL
, p_qrycnd                 in  varchar2 default NULL
, p_jsfuncname             in  varchar2 default NULl
, p_startnum               in  pls_integer   default NULL
, p_rowcount               in  pls_integer   default NULL
, p_totalcount             in  pls_integer   default NULL
, p_search_str             in  varchar2 default NULL
, p_dim_level_id           in number default NULL
, p_sqlcount               in  varchar2 default NULL
, p_coldata                in  colinfo_table
, p_rel_dim_lev_id         in varchar2 default NULL
, p_rel_dim_lev_val_id     in varchar2 default NULL
, p_rel_dim_lev_g_var      in varchar2 default NULL
, Z                        in pls_integer default NULL
, p_user_id        in pls_integer default NULL
, x_string                 out nocopy VARCHAR2
);

procedure lov_search( p_totalpossible     in  pls_integer   default NULL
                    , p_totalavailable    in  pls_integer   default NULL
                    , p_titlename         in  varchar2      default NULL
                    , p_startnum         in  pls_integer   default NULL
                    , p_rowcount          in  pls_integer   default NULL
                    , p_search_str        in  varchar2      default NULL
                    , x_string            out nocopy VARCHAR2);

/*
procedure lov_data( p_startnum          in  pls_integer   default NULL
                  , p_rowcount          in  pls_integer   default NULL
                  , p_totalavailable    in  pls_integer   default NULL
                  , p_sql               in  varchar2 default NULL
                  , p_head              in  colstore_table
                  , p_value             in  colstore_table
                  , p_link              in  colstore_table
                  , p_disp              in  colstore_table);
*/


procedure lov_data
( p_startnum          in  pls_integer   default NULL
, p_rowcount          in  pls_integer   default NULL
, p_totalavailable    in  pls_integer   default NULL
, p_dim_level_id      in number default NULL
, p_search_str        in varchar2 default NULL
, p_head              in  colstore_table
, p_value             in  colstore_table
, p_link              in  colstore_table
, p_disp              in  colstore_table
, p_rel_dim_lev_id         in varchar2 default NULL
, p_rel_dim_lev_val_id     in varchar2 default NULL
, p_rel_dim_lev_g_var      in varchar2 default NULL
, Z                        in pls_integer default NULL
, p_user_id           in pls_integer default NULL
, x_string            out nocopy VARCHAR2
);

procedure lov_buttons( p_startnum          in  pls_integer   default NULL
                     , p_rowcount          in  pls_integer   default NULL
                     , p_totalavailable    in  pls_integer   default NULL
                     , x_string             out nocopy VARCHAR);


function concat_string (p_search_str  in varchar2 default NULL) return varchar2;

procedure lovjscript(x_string out nocopy varchar2);

PROCEDURE setGlobalVar
( p_dim_lev_id     in VARCHAR2
, p_dim_lev_val_id in VARCHAR2
, p_dim_lev_g_var  in VARCHAR2
, x_return_status  out NOCOPY VARCHAR2
);

-- mdamle 01/15/2001
procedure editlovjscript(x_string out nocopy varchar2);

end bis_lov_pub;

 

/
