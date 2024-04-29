--------------------------------------------------------
--  DDL for Package Body BIS_INTERMEDIATE_LOV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_INTERMEDIATE_LOV_PVT" as
/* $Header: BISVIMTB.pls 120.1 2005/10/28 08:16:02 visuri noship $ */
-- *******************************************************
--         Procedure creates the SQL query
-- *******************************************************
procedure dim_level_values_query
(p_qrycnd        in varchar2    default NULL
,p_jsfuncname     in varchar2    default NULL
,p_startnum       in pls_integer default NULL
,p_rowcount       in pls_integer default NULL
,p_totalcount     in pls_integer default NULL
,p_search_str     in varchar2    default NULL
,Z                in pls_integer default NULL
,p_dim1_lbl       in varchar2    default NULL  -- 1797465
,x_string         out nocopy VARCHAR2
)

is

 l_qrycnd                 varchar2(32000);
 l_sql                    varchar2(32000);
 l_temp                   varchar2(32000);
 l_sqlcount               varchar2(32000);
 l_procname               varchar2(200);
 l_col_object             bis_lov_pub.colinfo_table;
 l_search_str             varchar2(200);
 l_view_name              varchar2(80);
 l_short_name             varchar2(30);
 l_dimension_short_name   varchar2(30);
 l_header                 varchar2(80);
 l_id                     pls_integer;
 l_point1                 pls_integer;
 l_point2                 pls_integer;
 l_point3                 pls_integer;
 l_point4                 pls_integer;
 l_point5                 pls_integer;
 l_point6                 pls_integer;
 l_point7                 pls_integer;
 l_target_level_id        pls_integer;
 l_user_id                pls_integer;
 l_dim_level_id           number;

 l_rel_dim_lev_id     pls_integer;
-- l_rel_dim_lev_val_id pls_integer;
 l_rel_dim_lev_val_id    VARCHAR2(32000);
 l_rel_dim_lev_g_var     varchar2(32000);

 l_tar_level_rec        BIS_Target_Level_PUB.Target_Level_Rec_Type;
 l_lovstring            VARCHAR2(32000);
 l_string               VARCHAR2(32000);

begin
  --commit;
--if icx_sec.validateSession then
   -- mdamle 01/15/2001 - Modified routine to use getLOVSQL for EDW

   -- (1) Call a function to plug the the ' on both sides of the search string
        l_search_str := bis_lov_pub.concat_string(p_search_str);

   -- (2)Set the procedure name
       l_procname := 'bis_intermediate_lov_pvt.dim_level_values_query';

   -- (3)Build two SQL queries, one for the statement and the other for
   --    the row count

   -- Now unpack the qrycnd string to get the userid,tar id, dim level id
   -- and other related dimension info

    l_point1 := instr(p_qrycnd,'*',1,1);
    l_point2 := instr(p_qrycnd,'*',1,2);
    l_point3 := instr(p_qrycnd,'*',1,3);
    l_point4 := instr(p_qrycnd,'*',1,4);
    l_point5 := instr(p_qrycnd,'*',1,5);
    l_point6 := instr(p_qrycnd,'*',1,6);
    l_point7 := instr(p_qrycnd,'*',1,7);

    l_user_id := substr(p_qrycnd,1,l_point1-1);
    --l_user_id := ICX_SEC.getID(ICX_SEC.PV_USER_ID, '', icx_sec.g_session_id);
    l_target_level_id := substr(p_qrycnd,l_point1+1,l_point2 - l_point1 - 1);

  IF (l_point3 <> 0) THEN
    l_dim_level_id    := substr(p_qrycnd,l_point2+1,l_point3 - l_point2 - 1);
  ELSE
    l_dim_level_id    := substr(p_qrycnd,l_point2+1);
  END IF;

  IF (l_point3 <> 0) AND (l_point4 <> 0) THEN
    l_rel_dim_lev_g_var  := substr(p_qrycnd,l_point3+1,l_point4-l_point3-1);
  END IF;
  IF (l_point4 <> 0) AND (l_point5 <> 0) THEN
    l_rel_dim_lev_id := substr(p_qrycnd,l_point4+1,l_point5-l_point4-1);
  END IF;
  IF (l_point5 <> 0)  THEN
    l_rel_dim_lev_val_id  := substr(p_qrycnd,l_point5+1);
  END if;

  l_temp := getLOVSQL(l_dim_level_id, l_search_str, 'LOV',  l_user_id);

  -- meastmon 04/24/2001 It works for OLTP dimensions but not for EDW dimensions
  -- which dont have id and value columns in the tables.
  -- l_point1 := instr(lower(l_temp),' from ',1);
  -- l_sql := 'select distinct id, value ' || substr(l_temp, l_point1);
  --l_sql := 'select distinct id, value from ('||l_temp||')';
  -- l_point1 := instr(lower(l_sql),' from ',1);
  -- l_sqlcount := 'select count(distinct id) ' || substr(l_sql, l_point1);
  l_sqlcount := 'select count(distinct id) from ('||l_temp||')';


    -- (4)Build the plsql table to transfer column information
    --
      l_col_object(1).header := c_orgid;
      l_col_object(1).value  := FND_API.G_TRUE;
      l_col_object(1).link   := FND_API.G_FALSE;
      l_col_object(1).display:= FND_API.G_FALSE;

      -- l_col_object(2).header := l_header;
--Bug 1797465
  --  l_col_object(2).header := c_organization;
      l_col_object(2).header := p_dim1_lbl;
--Bug 1797465
      l_col_object(2).value  := FND_API.G_FALSE;
      l_col_object(2).link   := FND_API.G_TRUE;
      l_col_object(2).display:= FND_API.G_TRUE;

  --
  -- (5)Now call LOV utility procedure to run the query and paint the window
  --


     IF l_rel_dim_lev_g_var IS NOT NULL
     THEN
      bis_lov_pub.main (p_procname     => l_procname,
                       p_qrycnd       => p_qrycnd,
                       p_jsfuncname   => p_jsfuncname,
                       p_startnum     => p_startnum,
                       p_rowcount     => bis_lov_pub.c_rowcount,
                       p_totalcount   => p_totalcount,
                       p_search_str   => p_search_str,
                       p_dim_level_id => l_dim_level_id,
                       p_sqlcount     => l_sqlcount,
                       p_coldata      => l_col_object,
                       p_rel_dim_lev_id     => l_rel_dim_lev_id,
                       p_rel_dim_lev_val_id => l_rel_dim_lev_val_id,
                       p_rel_dim_lev_g_var  => l_rel_dim_lev_g_var,
                       Z                    => Z,
                       p_user_id      => l_user_id,
                       x_string             => l_lovstring);


     ELSE

     bis_lov_pub.main (p_procname     => l_procname,
                       p_qrycnd       => p_qrycnd,
                       p_jsfuncname   => p_jsfuncname,
                       p_startnum     => p_startnum,
                       p_rowcount     => bis_lov_pub.c_rowcount,
                       p_totalcount   => p_totalcount,
                       p_search_str   => p_search_str,
                       p_dim_level_id => l_dim_level_id,
                       p_sqlcount     => l_sqlcount,
                       p_coldata      => l_col_object,
                       Z              => Z,
                       p_user_id      => l_user_id,
                       x_string       => l_lovstring);

     END IF;

     x_string := l_lovstring;
--end if; --icx_sec.validateSession


end dim_level_values_query;


-- mdamle 01/15/2001 - added for EDW purposes
-- juwang 02/18/2002 bug#2226770
function getLOVSQL (p_dim_level_id       in number,
                    p_dimn_level_value       in varchar2,
                    p_sql_type               in varchar2 default null,
                    p_user_id                in number) return varchar2
is

   cursor c_dim_level_info (cp_dim_level_id number) is
   select dimension_short_name
         ,dimension_level_short_name
   ,level_values_view_name
   ,source
   from  bisfv_dimension_levels
   where dimension_level_id = cp_dim_level_id;

   vViewname       VARCHAR2(80) := null;
   l_source                VARCHAR2(20) := null;

   v_sql_stmnt             VARCHAR2(32000);
   l_dim_shname            VARCHAR2(80);
   l_dimlevel_shname       VARCHAR2(80);

   v_table_name VARCHAR2(2000);
   v_id_name VARCHAR2(2000);
   v_value_name VARCHAR2(2000);
   v_return_status VARCHAR2(2000);
   v_msg_count NUMBER;
   v_msg_data VARCHAR2(2000);

   l_Responsibility_Tbl     BIS_RESPONSIBILITY_PVT.Responsibility_Tbl_Type;
   l_link                   VARCHAR2(32000);
   l_return_status          VARCHAR2(400);
   l_error_tbl              BIS_UTILITIES_PUB.Error_Tbl_Type;

   l_where_clause       VARCHAR2(32000);
   l_first_quote_pos PLS_INTEGER;
   l_last_quote_pos PLS_INTEGER;
BEGIN

-- get source
  open c_dim_level_info (p_dim_level_id);
  fetch c_dim_level_info into l_dim_shname, l_dimlevel_shname, vViewName, l_source;
  close c_dim_level_info;

  BIS_PMF_GET_DIMLEVELS_PUB.GET_DIMLEVEL_SELECT_STRING(
    p_DimLevelShortName => l_dimlevel_shname
    ,p_bis_source => l_source
    ,x_Select_String => v_sql_stmnt
    ,x_table_name=>     v_table_name
    ,x_id_name=>        v_id_name
    ,x_value_name=>     v_value_name
    ,x_return_status=>  v_return_status
    ,x_msg_count=>      v_msg_count
    ,x_msg_data=>       v_msg_data
  );


  v_sql_stmnt := v_sql_stmnt || ' where '||v_value_name||' like ';

  if upper(p_sql_type) = 'LOV' then
    if  p_dimn_level_value = '''%''' then
      v_sql_stmnt := v_sql_stmnt|| p_dimn_level_value;
    else
--rmohanty Fixed the LOV SQL command not properly ending error bug#1651909
--v_sql_stmnt := v_sql_stmnt||''''||p_dimn_level_value||'%''';
      v_sql_stmnt := v_sql_stmnt||p_dimn_level_value;
    end if;
  else
    v_sql_stmnt := v_sql_stmnt||''''||p_dimn_level_value||'''';
  end if;

/* 2359096
--juwang #bug#2226770
  IF ((l_source = 'OLTP') AND (l_dim_shname = 'ORGANIZATION')) THEN
    BIS_UTILITIES_PUB.Retrieve_Org_Where_Clause(
        p_user_id => p_user_id
      , p_dimension_level_short_name => l_dimlevel_shname
      , x_where_clause  => l_where_clause
      );

    IF ( (l_where_clause IS NOT NULL) AND
         (l_where_clause <> '""')) THEN
      l_where_clause := TRIM(l_where_clause);
      l_first_quote_pos := instr(l_where_clause, '"');
      l_where_clause := SUBSTR(l_where_clause, (l_first_quote_pos+1));

      l_where_clause := SUBSTR(l_where_clause,1,(LENGTH(l_where_clause)-1));
      v_sql_stmnt := v_sql_stmnt || ' and ' || l_where_clause;
    END IF;

  END IF;
2359096 */
-- 2359096
    BIS_UTILITIES_PUB.get_org_where_clause(
             p_usr_id               => p_user_id
           , p_dim_level_short_name => l_dimlevel_shname
           , x_where_clause         => l_where_clause
           , x_return_status        => v_return_status
           , x_err_count            => v_msg_count
           , x_errorMessage         => v_msg_data
           );

      IF (l_where_clause IS NOT NULL)  THEN
            v_sql_stmnt := v_sql_stmnt || ' and ' || l_where_clause;
      END IF;
-- 2359096

  v_sql_stmnt := v_sql_stmnt ||' order by '||v_value_name;

  return(v_sql_stmnt);

 Exception
   when others then BISVIEWER.displayError(380,SQLCODE,SQLERRM);
END getLOVSQL;

-- ****************************************************
end bis_intermediate_lov_pvt;

/
