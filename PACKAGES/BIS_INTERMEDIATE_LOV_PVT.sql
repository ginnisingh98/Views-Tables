--------------------------------------------------------
--  DDL for Package BIS_INTERMEDIATE_LOV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_INTERMEDIATE_LOV_PVT" AUTHID CURRENT_USER as
/* $Header: BISVIMTS.pls 120.1 2005/10/28 08:17:06 visuri noship $ */
c_orgid        CONSTANT varchar2(60) := 'Org Id';
c_organization CONSTANT varchar2(80) := 'Organization';
c_orglevel     CONSTANT varchar2(60) := 'Org Level Name';
c_percent      CONSTANT varchar2(1)  := '%';

procedure dim_level_values_query
( p_qrycnd        in varchar2    default NULL
 ,p_jsfuncname    in varchar2    default NULL
 ,p_startnum      in pls_integer default NULL
 ,p_rowcount      in pls_integer default NULL
 ,p_totalcount    in pls_integer default NULL
 ,p_search_str    in varchar2    default NULL
,Z                in pls_integer default NULL
,p_dim1_lbl       in varchar2    default NULL  -- 1797465
,x_string         out nocopy VARCHAR2
);

-- mdamle 01/15/2001 - add getLOVSQL
function getLOVSQL (p_dim_level_id       in number,
                    p_dimn_level_value       in varchar2,
                    p_sql_type               in varchar2 default null,
          p_user_id                in number)
    return varchar2;

end bis_intermediate_lov_pvt;

 

/
