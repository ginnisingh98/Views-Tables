--------------------------------------------------------
--  DDL for Package Body IEC_WHERECLAUSE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_WHERECLAUSE_PVT" AS
/* $Header: IECVWHCB.pls 115.7.1158.3 2002/10/02 18:13:32 lcrew ship $ */


PROCEDURE GETWHERECLAUSE
    (P_OWNER_ID                 NUMBER
    ,P_OWNER_TYPE               VARCHAR2
    ,WHERECLAUSE      OUT       VARCHAR2) AS
e_operror EXCEPTION;
TYPE RULE_ID_TBL IS TABLE OF iec_g_rules.rule_id%TYPE;
TYPE CRITERIA_ID_TBL IS TABLE OF iec_g_field_criteria.criteria_id%TYPE;
TYPE COMBINATION_CODE_TBL IS TABLE OF iec_g_field_criteria.combination_code%TYPE;
TYPE FIELD_NAME_TBL IS TABLE OF iec_g_fields.field_name%TYPE;
TYPE FIELD_VALUE_TBL IS TABLE OF iec_g_fields.field_value%TYPE;
TYPE OPERATOR_CODE_TBL IS TABLE OF iec_g_fields.operator_code%TYPE;
TYPE SQL_OPERATOR_TBL IS TABLE OF iec_o_alg_op_defs_b.sql_operator%TYPE;
TYPE UNARY_FLAG_TBL IS TABLE OF iec_o_alg_op_defs_b.is_unary_flag%TYPE;
l_rule_id_tbl RULE_ID_TBL;
l_criteria_id_tbl CRITERIA_ID_TBL;
l_comb_code_tbl COMBINATION_CODE_TBL;
l_field_name_tbl FIELD_NAME_TBL;
l_field_value_tbl FIELD_VALUE_TBL;
l_operator_code_tbl OPERATOR_CODE_TBL;
l_sql_operator_tbl SQL_OPERATOR_TBL;
l_unary_flag_tbl UNARY_FLAG_TBL;
l_rule_flag    CHAR(1) := 'Y';
l_criteria_flag    CHAR(1) := 'Y';
l_field_flag    CHAR(1) := 'Y';
l_where_clause VARCHAR2(4000) := NULL;
BEGIN
  select rule_id bulk collect into l_rule_id_tbl from iec_g_rules
  where owner_id = p_owner_id and owner_type_code = p_owner_type;

  for j in 1 ..l_rule_id_tbl.COUNT
  loop
    if(l_rule_flag <> 'Y') then
      l_where_clause := l_where_clause || ' OR ( ';
    else
      l_where_clause := l_where_clause || ' ( ';
      l_rule_flag := 'N';
    end if;

    select criteria_id, combination_code bulk collect into l_criteria_id_tbl, l_comb_code_tbl
    from iec_g_field_criteria where rule_id = l_rule_id_tbl(j);
      l_criteria_flag := 'Y';
      for k in 1 .. l_criteria_id_tbl.COUNT
      loop
        if(l_criteria_flag <> 'Y') then
          l_where_clause := l_where_clause || ' AND ( ';
        else
          l_where_clause := l_where_clause || ' ( ';
          l_criteria_flag := 'N';
        end if;

        select A.field_name,UPPER(LTRIM(RTRIM(A.field_value,' '),' ')),
        UPPER(LTRIM(RTRIM(A.operator_code,' '),' ')),
        UPPER(LTRIM(RTRIM(B.sql_operator,' '),' ')),
        B.is_unary_flag bulk collect into l_field_name_tbl,l_field_value_tbl,
        l_operator_code_tbl,l_sql_operator_tbl,
        l_unary_flag_tbl from iec_g_fields A, iec_o_alg_op_defs_b B
        where A.criteria_id = l_criteria_id_tbl(k) and A.operator_code = B.operator_code;

        l_field_flag := 'Y';
        for i in 1 .. l_field_name_tbl.COUNT
        loop
          if(l_field_flag <> 'Y') then
            l_where_clause := l_where_clause || ' ';
            l_where_clause := l_where_clause || l_comb_code_tbl(k);
            l_where_clause := l_where_clause || ' ';
            l_where_clause := l_where_clause || ' ( ';
          else
            l_where_clause := l_where_clause || ' ( ';
            l_field_flag := 'N';
          end if;

          l_where_clause := l_where_clause || 'UPPER(';
          l_where_clause := l_where_clause || l_field_name_tbl(i);
          l_where_clause := l_where_clause || ') ';
          l_where_clause := l_where_clause || l_sql_operator_tbl(i);

          if(l_unary_flag_tbl(i) = 'N') then
           l_where_clause := l_where_clause || ' ''';
            if(l_sql_operator_tbl(i) = 'LIKE') then
              if(l_operator_code_tbl(i) = 'CONTAINS') then
                l_where_clause := l_where_clause || '%';
                l_where_clause := l_where_clause || l_field_value_tbl(i);
                l_where_clause := l_where_clause || '%';
              elsif(l_operator_code_tbl(i) = 'BGWITH') then
                l_where_clause := l_where_clause || l_field_value_tbl(i);
                l_where_clause := l_where_clause || '%';
              elsif(l_operator_code_tbl(i) = 'ENDWITH') then
                l_where_clause := l_where_clause || '%';
                l_where_clause := l_where_clause || l_field_value_tbl(i);
              else
                raise e_operror;
              end if;
            else
              l_where_clause := l_where_clause || l_field_value_tbl(i);
            end if;
            l_where_clause := l_where_clause || ''' ';
            l_where_clause := l_where_clause || ')';
          else
            l_where_clause := l_where_clause || ')';
          end if;
        end loop;

        l_where_clause := l_where_clause || ' ) ';
      end loop;
    l_where_clause := l_where_clause || ' ) ';
  end loop;
  whereclause := l_where_clause;
EXCEPTION
WHEN e_operror THEN
 whereclause := NULL;
WHEN others THEN
 whereclause := NULL;
END GETWHERECLAUSE;

PROCEDURE GETWHERECLAUSEFORSUBSET
    (P_OWNER_ID                 NUMBER
    ,P_OWNER_TYPE               VARCHAR2
    ,WHERECLAUSE      OUT       VARCHAR2)AS
e_operror EXCEPTION;
TYPE RULE_ID_TBL IS TABLE OF iec_g_rules.rule_id%TYPE;
TYPE SUBSET_ID_TBL IS TABLE OF iec_g_list_subsets.list_subset_id%TYPE;
l_subset_id_tbl SUBSET_ID_TBL;
l_rule_id_tbl RULE_ID_TBL;
l_default_subset_flag VARCHAR2(1) := NULL;
l_where_clause VARCHAR2(4000) := NULL;
l_where_clause_sub VARCHAR2(4000) := NULL;
BEGIN
  select default_subset_flag into l_default_subset_flag  from iec_g_list_subsets
  where list_subset_id = p_owner_id ;

  if(l_default_subset_flag is null or l_default_subset_flag <>'Y') then
    GETWHERECLAUSE(p_owner_id, p_owner_type, l_where_clause);
  else
    select rule_id bulk collect into l_rule_id_tbl from iec_g_rules
    where owner_id = p_owner_id and owner_type_code = p_owner_type;
    if(l_rule_id_tbl.COUNT >0 ) then
	GETWHERECLAUSE(p_owner_id, p_owner_type, l_where_clause);
    else
	select list_subset_id bulk collect into l_subset_id_tbl from iec_g_list_subsets where  list_header_id in
	(select list_header_id from iec_g_list_subsets   where list_subset_id = p_owner_id )
	and ( default_subset_flag <>'Y' or default_subset_flag is null);

	if(l_subset_id_tbl.COUNT = 0) then
        l_where_clause := NULL;
	elsif(l_subset_id_tbl.COUNT = 1) then
	  GETWHERECLAUSE(l_subset_id_tbl(1), p_owner_type, l_where_clause_sub);
	  l_where_clause := 'NOT('||l_where_clause_sub||')';
	else
	  for i in 1 ..l_subset_id_tbl.COUNT-1
        loop
	    GETWHERECLAUSE(l_subset_id_tbl(i), p_owner_type, l_where_clause_sub);
	    l_where_clause := l_where_clause ||'( '||l_where_clause_sub||')'||'OR';
	    l_where_clause_sub := NULL;
	  end loop;
	  GETWHERECLAUSE(l_subset_id_tbl(l_subset_id_tbl.COUNT), p_owner_type, l_where_clause_sub);
	    l_where_clause := l_where_clause ||'( '||l_where_clause_sub||')';
	  l_where_clause := 'NOT('||l_where_clause||')';
      end if;
    end if;
  end if;
whereclause := l_where_clause;
EXCEPTION
WHEN e_operror THEN
 whereclause := NULL;
WHEN others THEN
 whereclause := NULL;
END GETWHERECLAUSEFORSUBSET;

PROCEDURE getAMSView( listHeaderId number, viewName out varchar2) AS
l_viewname VARCHAR2(100) := NULL;
BEGIN
  select b.tag  into l_viewname from ams_list_headers_all a, iec_lookups b where
  a.list_header_id = listHeaderId and b.lookup_type='IEC_SOURCE_VIEW_MAP' and a.list_source_type = b.lookup_code;
  viewname := l_viewname;
EXCEPTION
WHEN others THEN
  viewname := NULL;
END getAMSView;
END IEC_WHERECLAUSE_PVT;


/
