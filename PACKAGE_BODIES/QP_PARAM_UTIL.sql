--------------------------------------------------------
--  DDL for Package Body QP_PARAM_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_PARAM_UTIL" AS
/* $Header: QPXUPRMB.pls 120.2 2005/10/03 02:26:23 prarasto noship $ */
PROCEDURE Get_Valueset_Select( p_valueset_id IN VARCHAR2,
                                x_select_stmt OUT NOCOPY VARCHAR2) IS
    v_select_clause varchar2(4000) := null;
    v_valueset_r     fnd_vset.valueset_r;
    v_valueset_dr    fnd_vset.valueset_dr;
    v_table_r        fnd_vset.table_r;
    v_cols           varchar2(3000);
    v_value_set_id   number := to_number(p_valueset_id);
BEGIN
       fnd_vset.get_valueset(v_value_set_id,v_valueset_r,v_valueset_dr);

    v_table_r := v_valueset_r.table_info;
    v_cols := nvl(v_table_r.ID_COLUMN_NAME, nvl(v_table_r.VALUE_COLUMN_NAME, 'null')) || ' attribute_id, ';
    v_cols := v_cols || nvl(v_table_r.VALUE_COLUMN_NAME, 'null') || ' attribute_name, ';
    v_cols := v_cols || 'nvl(' || nvl(v_table_r.MEANING_COLUMN_NAME, 'null') || ', ' || nvl(v_table_r.VALUE_COLUMN_NAME, 'null') || ') attribute_meaning ';

    if v_table_r.TABLE_NAME is not null then
       v_select_clause := 'select ' || v_cols || ' from ' || v_table_r.TABLE_NAME;
    else
       v_select_clause := 'select flex_value attribute_id, flex_value_meaning attribute_name, nvl(description, flex_value_meaning) attribute_meaning FROM fnd_flex_values_vl WHERE flex_value_set_id = '|| v_value_set_id;
    end if;

    if v_table_r.WHERE_CLAUSE is not null then
      v_select_clause := v_select_clause || ' ' || v_table_r.WHERE_CLAUSE;
    end if;

    x_select_stmt :=  'Select * from (' || v_select_clause || ') PVVO';
END Get_Valueset_Select;

PROCEDURE Insert_Parameter_Values( p_level IN VARCHAR2,
				   p_level_name IN VARCHAR2) IS
   CURSOR l_param_id_cur(p_level_type VARCHAR2) IS
   SELECT parameter_id,seeded_value
   FROM qp_parameters_b
   WHERE parameter_level = p_level_type;

   l_parameter_value_id NUMBER;

BEGIN
   FOR param_rec in l_param_id_cur(p_level) LOOP
        SELECT QP.QP_PARAMETER_VALUES_S.nextval into l_parameter_value_id FROM dual;
	INSERT INTO qp_parameter_values(parameter_value_id,
					parameter_id,
					level_name,
					seeded_default_value,
					created_by,
					creation_date,
					last_updated_by,
					last_update_date,
					last_update_login)
	VALUES
				       (l_parameter_value_id,
					param_rec.parameter_id,
					p_level_name,
					param_rec.seeded_value,
					FND_GLOBAL.user_id,
					sysdate,
					fnd_global.user_id,
					sysdate,
					FND_GLOBAL.login_id);
   END LOOP;
END Insert_Parameter_Values;

PROCEDURE Delete_Parameter_Values( p_level IN VARCHAR2,
				   p_level_name IN VARCHAR2) IS
BEGIN

   DELETE FROM QP_PARAMETER_VALUES
   WHERE level_name = p_level_name
   AND parameter_id IN ( SELECT parameter_id FROM QP_PARAMETERS_VL
   			 WHERE parameter_level = p_level );

END Delete_Parameter_Values;

PROCEDURE Populate_Parameter_Values( p_parameter_id IN NUMBER,
                                     p_seeded_value IN VARCHAR2,
                                     p_parameter_level IN VARCHAR2) IS
 CURSOR l_request_type_cur IS
 SELECT request_type_code   from qp_pte_request_types_b ;

 CURSOR l_pte_type_cur IS
 SELECT lookup_code from qp_lookups where lookup_type = 'QP_PTE_TYPE';

 L_PARAMETER_VALUE_ID NUMBER;
BEGIN

   IF p_parameter_level = 'REQ' THEN
   FOR param_value_rec in l_request_type_cur LOOP
        SELECT QP.QP_PARAMETER_VALUES_S.nextval into l_parameter_value_id FROM dual;

        INSERT INTO qp_parameter_values(parameter_value_id,
                                        parameter_id,
                                        level_name,
                                        seeded_default_value,
                                        created_by,
                                        creation_date,
                                        last_updated_by,
                                        last_update_date,
                                        last_update_login)
        VALUES
                                       (l_parameter_value_id,
                                        p_parameter_id,
                                        param_value_rec.request_type_code,
                                        p_seeded_value,
                                        FND_GLOBAL.user_id,
                                        sysdate,
                                        fnd_global.user_id,
                                        sysdate,
                                        FND_GLOBAL.login_id);
   END LOOP;
   END IF;


   IF p_parameter_level = 'PTE' THEN
   FOR param_value_rec in l_pte_type_cur LOOP
        SELECT QP.QP_PARAMETER_VALUES_S.nextval into l_parameter_value_id FROM dual;

        INSERT INTO qp_parameter_values(parameter_value_id,
                                        parameter_id,
                                        level_name,
                                        seeded_default_value,
                                        created_by,
                                        creation_date,
                                        last_updated_by,
                                        last_update_date,
                                        last_update_login)
        VALUES
                                       (l_parameter_value_id,
                                        p_parameter_id,
                                        param_value_rec.lookup_code,
                                        p_seeded_value,
                                        FND_GLOBAL.user_id,
                                        sysdate,
                                        fnd_global.user_id,
                                        sysdate,
                                        FND_GLOBAL.login_id);
   END LOOP;
   END IF;

END Populate_Parameter_Values;

 FUNCTION Get_Parameter_Value( p_level in varchar2,
                               p_level_name in varchar2 ,
                               p_parameter_code in varchar2)
  RETURN VARCHAR2 AS
  l_routine           VARCHAR2(100) := 'QP_Param_Util.Get_Parameter_Value';
  l_debug             VARCHAR2(3);
  parameter_value     qp_parameter_values.user_assigned_value%type;
 Begin
  l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
  SELECT nvl(V.USER_ASSIGNED_VALUE,V.SEEDED_DEFAULT_VALUE)
         INTO parameter_value
  from qp_parameters_b B, qp_parameters_tl T, qp_parameter_values V
  Where T.parameter_id = B.parameter_id
  and   T.Language = userenv('LANG')
  and   B.parameter_id = V.parameter_id
  and   B.PARAMETER_LEVEL = p_level
  and   B.Parameter_code = p_parameter_code
  and   V.Level_Name = p_level_name;
   RETURN parameter_value;
    EXCEPTION
            When OTHERS Then
             IF l_debug = FND_API.G_TRUE THEN
                QP_PREQ_GRP.Engine_debug('Exception in '||l_routine||' '||SQLERRM);
             END IF;
            RETURN NULL;

End Get_Parameter_Value;


FUNCTION Is_Seed_User RETURN VARCHAR2 AS
BEGIN

  if QP_UTIL.is_seed_user then
     return 'Y';
  else
     return 'N';
  end if;

END Is_Seed_User;


END QP_Param_Util;

/
