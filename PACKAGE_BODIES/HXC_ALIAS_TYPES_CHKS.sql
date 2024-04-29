--------------------------------------------------------
--  DDL for Package Body HXC_ALIAS_TYPES_CHKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_ALIAS_TYPES_CHKS" as
/* $Header: hxcaltchk.pkb 115.6 2004/01/13 14:44:43 jdupont noship $ */
PROCEDURE Check_Sql(X_P_ID IN NUMBER,
           P_SQL_WC OUT NOCOPY VARCHAR2,
   	   P_SQL_NC OUT NOCOPY VARCHAR2,
           P_RET OUT NOCOPY VARCHAR2
           ) is
l_select_nid varchar2(32000);
l_select_wid varchar2(32000);

Begin
p_id := X_P_ID;
p_name := G_MISS_CHAR;

fnd_flex_val_api.get_table_vset_select
(
 P_VALUE_SET_ID => p_id
 ,p_inc_id_col => 'N'
 , p_inc_meaning_col => 'N'
 ,X_SELECT => l_select_nid
 ,X_MAPPING_CODE => p_X_mapping_code
 ,X_SUCCESS => p_X_success);
fnd_flex_val_api.get_table_vset_select
(
 P_VALUE_SET_ID => p_id
 , p_inc_meaning_col => 'N'
 ,X_SELECT => l_select_wid
 ,X_MAPPING_CODE => p_X_mapping_code
 ,X_SUCCESS => p_X_success);

if (l_select_nid = l_select_wid ) then
raise invalid_sql;
end if;

fnd_flex_val_api.GET_TABLE_VSET_SELECT
(
 P_VALUE_SET_ID    => p_id
,P_VALUE_SET_NAME  => p_name
,p_inc_addtl_quickpick_cols => 'Y'
 ,X_SELECT    => p_X_SELECT_WC
 ,X_MAPPING_CODE   => p_X_MAPPING_CODE
 ,X_SUCCESS         => p_X_SUCCESS
);
if (p_X_SUCCESS <> 0)
then RAISE invalid_sql;
end if;

fnd_flex_val_api.GET_TABLE_VSET_SELECT
(
 P_VALUE_SET_ID    => p_id
,P_VALUE_SET_NAME  => p_name
,X_SELECT    => p_X_SELECT_NC
 ,X_MAPPING_CODE   => p_X_MAPPING_CODE
 ,X_SUCCESS        => p_X_SUCCESS
);
if (p_X_SUCCESS <> 0)
then RAISE invalid_sql;
end if;
c := dbms_sql.open_cursor;
  -- test your SQL
  dbms_sql.parse( c , p_X_SELECT_WC,dbms_sql.native);--dbms_sql.native) ;
--   get the column into rec_tab pl/sql table
  dbms_sql.describe_columns( c , col_cnt , rec_tab ) ;
  dbms_sql.close_cursor (c);
P_SQL_WC:=p_X_SELECT_WC;
P_SQL_NC:=p_X_SELECT_NC;
P_RET:='S';
return;
exception
 when invalid_sql then
P_RET := 'E';
return;
when others then
P_RET := 'S';
P_SQL_WC :='E';
return;

End Check_Sql;

Procedure get_id_string (X_P_ID IN NUMBER,
                         P_SQL_WC OUT NOCOPY varchar2,
                         P_SQL_NC OUT NOCOPY varchar2,
                         P_RET OUT NOCOPY varchar2) is
l_select_nid varchar2(32000);
l_select_wid varchar2(32000);
Begin
p_id := X_P_ID;
p_name := G_MISS_CHAR;

fnd_flex_val_api.get_table_vset_select
(
 P_VALUE_SET_ID => p_id
 ,p_inc_id_col => 'N'
 , p_inc_meaning_col => 'N'
 ,X_SELECT => l_select_nid
 ,X_MAPPING_CODE => p_X_mapping_code
,X_SUCCESS => p_X_success);
-- Bug 2815168
if (p_X_SUCCESS <> 0)
then RAISE invalid_sql;
end if;
-- End bug 2815168
fnd_flex_val_api.get_table_vset_select
(
 P_VALUE_SET_ID => p_id
 , p_inc_meaning_col => 'N'
 ,X_SELECT => l_select_wid
 ,X_MAPPING_CODE => p_X_mapping_code
 ,X_SUCCESS => p_X_success);

-- Bug 2815168
if (p_X_SUCCESS <> 0)
then RAISE invalid_sql;
end if;
-- End Bug 2815168

P_SQL_WC := l_select_wid;
P_SQL_NC := l_select_nid;
return;
exception
 when invalid_sql then
P_RET := 'E';
return;
when others then
P_RET := 'S';
P_SQL_WC :='E';
return;
end get_id_string;

END HXC_ALIAS_TYPES_CHKS;

/
