--------------------------------------------------------
--  DDL for Package Body HR_PASSED_SQL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PASSED_SQL" AS
/* $Header: hrpsdsql.pkb 120.1.12010000.1 2008/07/28 03:42:10 appldev ship $ */
--
--------------------------------------------------------------------------------
--  FUNCTION:         GET_PASSED_SQL_ID                                       --
--                                                                            --
--  DESCRIPTION:      Inserts Query into Parameters tables, and a             --
--                    session date.                                           --
--                                                                            --
--  PARAMETERS:       WHERE clause - query to be executed by HR SQL Control   --
--                    Session Date - date to be used by HR SQL Control        --
--			                                                      --
--			   	 	   	 	                      --
--		 							      --
--  RETURN: 	         parameter list id.                                   --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date       Username  Description                                          --
--  10-JUL-02  smcmilla  CREATED                                              --
--------------------------------------------------------------------------------
--
--$ addd additional argument p_form_name to add additional paramater to the list
FUNCTION GET_PASSED_SQL_ID(p_where_clause   in VARCHAR2
                          ,p_session_date   in VARCHAR2
                          ,p_form_name      in VARCHAR2) RETURN varchar2 as
--
  l_list_id        number;
  l_list_name      varchar2(50);
  l_list_code      varchar2(60);
  l_list_key       varchar2(60);
  l_prompt_above   varchar2(240);
  --
  l_param_defn_app_id  number;
  l_param_defn_code    varchar2(60);

  l_param_defn_id  number;
  l_param_name     varchar2(50);
  l_param_source   varchar2(50);
  l_param_category number;
  l_val_type       number;
  l_max_size       number;
  l_display_type   number;
  l_display_style  number;
  l_display_size   number;
  l_data_type      number;
  l_required       varchar2(1);
  l_persistent     varchar2(1);
  l_visible        varchar2(1);
  l_modifyable     varchar2(1);
  l_desc_value     varchar2(240);
  l_prompt_left    varchar2(240);
  l_sequence_num   number;

  l_plsql          varchar2(4000);

  l_where1         varchar2(2000);
  l_where2         varchar2(2000);

BEGIN
  --
  -- Determine param_list_id
  -- EXECUTE IMMEDIATE
  --   'SELECT BNE_PARAMETER_UTILS.GET_NEXT_PARAM_LIST_SEQ ' ||
  --   'FROM   dual'
 --  INTO l_list_id;
  --
  l_persistent := 'Y';
  l_prompt_above := 'HR WHERE clause';
  --
  l_list_code := 'HRPS_' || fnd_global.user_id || '_' || to_char(sysdate,'DDMMYY_HHMISS');
  l_list_name := 'HR Passed SQL for ' ||
                 fnd_global.user_id || ' ' || sysdate;
  --
  -- Create the initial Parameter List
  --
  l_plsql := 'BEGIN ' ||
             '  :1 := BNE_PARAMETER_UTILS.CREATE_PARAM_LIST_ALL' ||
             '          (p_application_id    => 800 ' ||
             '          ,p_param_list_code   => ''' || l_list_code || ''' ' ||
             '          ,p_persistent        => ''' || l_persistent || ''' ' ||
             '          ,p_comments          => null ' ||
             '          ,p_attribute_app_id  => null ' ||
             '          ,p_attribute_code    => null ' ||
             '          ,p_list_resolver     => null ' ||
             '          ,p_prompt_left       => null ' ||
             '          ,p_prompt_above      => ''' || l_prompt_above || ''' ' ||
             '          ,p_user_name         => ''' || l_list_name || ''' ' ||
             '          ,p_user_tip          => null ' ||
             '          ); ' ||
             'END; ';
  --
  EXECUTE IMMEDIATE l_plsql
    USING out l_list_key;
  --
  -- COMMIT;
  --
  --
  --Find the Parameter Definition Id for hr:sessionDate
  --
  --EXECUTE IMMEDIATE
  --  'SELECT param_defn_id ' ||
  --  '  FROM bne_param_defn ' ||
  --  ' WHERE param_name = ''hr:sessionDate'''
  --INTO l_param_defn_id;
  --
  l_param_name := 'hr:sessionDate';
  l_param_Source := l_list_name;
  l_param_category := 5;
  l_val_type := 1;
  l_max_size := 240;
  l_display_type := 4;
  l_display_Style := 1;
  l_data_type := 1;
  l_required := 'Y';
  l_visible  := 'Y';
  l_modifyable := 'N';
  l_display_size := 100;
  l_desc_value := 'Session Date';
  l_prompt_left := 'Session Date';
  --
  --
  -- l_plsql := 'BEGIN ' ||
  --            '  :1 := BNE_PARAMETER_UTILS.CREATE_PARAM_ALL ' ||
  --           '          (P_PARAM_ID        => ' || to_char(l_param_defn_id) ||
  --           '          ,P_PARAM_NAME      => ''' || l_param_name || ''' ' ||
  --           '          ,P_PARAM_SOURCE    => ''' || l_list_name || ''' ' ||
  --           '          ,P_CATEGORY        => ' || to_char(l_param_category) ||
  --           '          ,P_DESCRIPTION     => null ' ||
  --           '          ,P_DATA_TYPE       => ' || to_char(l_data_type) ||
  --           '          ,P_ATTRIBUTE_ID    => null ' ||
  --           '          ,P_PARAM_RESOLVER  => null ' ||
  --           '          ,P_REQUIRED        => ''' || l_required || ''' ' ||
  --           '          ,P_VISIBLE         => ''' || l_visible || ''' ' ||
  --           '          ,P_MODIFYABLE      => ''' || l_modifyable || ''' ' ||
  --           '          ,P_DEFAULT_STRING  => ''' || p_session_date || ''' ' ||
  --          '          ,P_DEFAULT_DATE    => null ' ||
  --           '          ,P_DEFAULT_NUM     => null ' ||
  --           '          ,P_DEFAULT_BOOLEAN => null ' ||
  --           '          ,P_DEFAULT_FORMULA => null ' ||
  --           '          ,P_VAL_TYPE        => ' || to_char(l_val_type) ||
  --           '          ,P_VAL_VALUE       => null ' ||
  --           '          ,P_MAXIMUM_SIZE    => ' || to_char(l_max_size) ||
  --           '          ,P_DISPLAY_TYPE    => ' || to_char(l_display_type) ||
  --           '          ,P_DISPLAY_STYLE   => ' || to_char(l_display_style) ||
  --           '          ,P_DISPLAY_SIZE    => ' || to_char(l_display_size) ||
  --           '          ,P_HELP_URL        => null ' ||
  --           '          ,P_FORMAT_MASK     => null ' ||
  --           '          ,P_DEFAULT_DESC    => ''' || l_desc_value || ''' ' ||
  --           '          ,P_PROMPT_LEFT     => ''' || l_prompt_left || ''' ' ||
  --           '          ,P_PROMPT_ABOVE    => null ' ||
  --           '          ,P_USER_TIP        => null ' ||
  --           '          ,P_ACCESS_KEY      => null ' ||
  --           '          ); ' ||
  --           ' END;';
  --
  --EXECUTE IMMEDIATE l_plsql
  --  USING out l_param_defn_id;
  --
  --l_plsql := 'BEGIN ' ||
  --           '	:1 := BNE_PARAMETER_UTILS.CREATE_LIST_ITEMS_ALL ' ||
  --           '          (p_param_list_id => ' || to_char(l_list_id) ||
  --           '          ,p_param_defn_id => ' || to_char(l_param_defn_id) ||
  --           '          ,p_param_name    => ''' || l_param_name || ''' ' ||
  --           '          ,p_attribute_id  => null ' ||
  --           '          ,p_string_val    => null ' ||
  --           '          ,p_date_val      => to_date(''' || p_session_date ||
  --                                                  ''',''YYYY-MM-DD'') ' ||
  --           '          ,p_number_val    => null ' ||
  --           '          ,p_boolean_val   => null ' ||
  --           '          ,p_formula       => null ' ||
  --           '          ,p_desc_val      => ''' || l_desc_value || ''' ' ||
  --           '          ); ' ||
  --           ' END;';
  --
  --EXECUTE IMMEDIATE l_plsql
  --  USING out l_sequence_num;
  --
  -- COMMIT;
  --
  --
  -- Create the Parameter Definition for hr:where
  --
  EXECUTE IMMEDIATE
    'SELECT application_id, param_defn_code' ||
    '  FROM bne_param_defns_b ' ||
    ' WHERE param_name = ''hr:where'''
  INTO l_param_defn_app_id, l_param_defn_code;
  --
  l_param_name := 'hr:where';
  l_param_Source := l_list_name;
  l_param_category := 5;
  l_val_type := 1;
  l_max_size := 240;
  l_display_type := 4;
  l_display_Style := 1;
  l_data_type := 1;
  l_required := 'Y';
  l_visible  := 'Y';
  l_modifyable := 'N';
  l_display_size := 100;
  l_desc_value := 'HR WHERE clause';
  l_prompt_left := 'SQL WHERE clause';
  --
  --
  -- l_plsql := 'BEGIN ' ||
  --           '  :1 := BNE_PARAMETER_UTILS.CREATE_PARAM_ALL ' ||
  --           '          (p_param_id        => ' || to_char(l_param_defn_id) ||
  --           '          ,p_param_name      => ''' || l_param_name || ''' ' ||
  --           '          ,p_param_source    => ''' || l_list_name || ''' ' ||
  --           '          ,p_category        => ' || to_char(l_param_category) ||
  --           '          ,p_description     => null ' ||
  --           '          ,p_data_type       => ' || to_char(l_data_type) ||
  --           '          ,p_attribute_id    => null ' ||
  --           '          ,p_param_resolver  => null ' ||
  --           '          ,p_required        => ''' || l_required || ''' ' ||
  --           '          ,p_visible         => ''' || l_visible || ''' ' ||
  --           '          ,p_modifyable      => ''' || l_modifyable || ''' ' ||
  --           '          ,p_default_string  => :2 ' ||
  --           '          ,p_default_date    => null ' ||
  --           '          ,p_default_num     => null ' ||
  --           '          ,p_default_boolean => null ' ||
  --           '          ,p_default_formula => null ' ||
  --           '          ,p_val_type        => ''' || l_val_type || ''' ' ||
  --           '          ,p_val_value       => null ' ||
  --           '          ,p_maximum_size    => ' || to_char(l_max_size) ||
  --           '          ,p_display_type    => ' || to_char(l_display_type) ||
  --           '          ,p_display_style   => ' || to_char(l_display_style) ||
  --           '          ,p_display_size    => ' || to_char(l_display_size) ||
  --           '          ,p_help_url        => null ' ||
  --           '          ,p_format_mask     => null ' ||
  --           '          ,p_default_desc    => ''' || l_desc_value || ''' ' ||
  --          '          ,p_prompt_left     => ''' || l_prompt_left || ''' ' ||
  --           '          ,p_prompt_above    => null ' ||
  --           '          ,p_user_tip        => null ' ||
  --           '          ,p_access_key      => null ' ||
  --           '          ); ' ||
  --           ' END;';
  --
  --EXECUTE IMMEDIATE l_plsql
  --  USING out l_param_defn_id;
  --
  l_plsql := 'BEGIN ' ||
             '	:1 := BNE_PARAMETER_UTILS.CREATE_LIST_ITEMS_ALL ' ||
             '          (p_application_id  => 800 ' ||
             '          ,p_param_list_code => ''' || l_list_code || ''' ' ||
             '          ,p_param_defn_app_id => ' || l_param_defn_app_id ||
             '          ,p_param_defn_code   => ''' || l_param_defn_code || ''' ' ||
             '          ,p_param_name        => ''' || l_param_name  || ''' ' ||
             '          ,p_attribute_app_id  => null ' ||
             '          ,p_attribute_code    => null ' ||
             '          ,p_string_val        => :2 ' ||
             '          ,p_date_val          => null ' ||
             '          ,p_number_val        => null ' ||
             '          ,p_boolean_val       => null ' ||
             '          ,p_formula           => null ' ||
             '          ,p_desc_val         => ''' || l_desc_value || ''' ' ||
             '          ); ' ||
             ' END;';
  --
  -- Determine if we use pass entire WHERE clause, or need to split it
  --
  IF length(p_where_clause) > 2000 THEN
     --
     l_where1 := substr(p_where_clause,1,2000);
     l_where2 := substr(p_where_clause,2001);
  ELSE
     l_where1 := p_where_clause;
     l_where2 := null;
  END IF;
  --
  EXECUTE IMMEDIATE l_plsql
    USING out l_sequence_num
        , in l_where1;
  --
  -- Create the Parameter Definition for hr:extra
  --
  EXECUTE IMMEDIATE
    'SELECT application_id, param_defn_code' ||
    '  FROM bne_param_defns_b ' ||
    ' WHERE param_name = ''hr:extra'''
  INTO l_param_defn_app_id, l_param_defn_code;
  --
  l_param_name := 'hr:extra';
  l_param_Source := l_list_name;
  l_param_category := 5;
  l_val_type := 1;
  l_max_size := 240;
  l_display_type := 4;
  l_display_Style := 1;
  l_data_type := 1;
  l_required := 'Y';
  l_visible  := 'Y';
  l_modifyable := 'N';
  l_display_size := 100;
  l_desc_value := 'HR EXTRA clause';
  l_prompt_left := 'SQL EXTRA clause';
  --
  l_plsql := 'BEGIN ' ||
             '  :1 := BNE_PARAMETER_UTILS.CREATE_LIST_ITEMS_ALL ' ||
             '          (p_application_id  => 800 ' ||
             '          ,p_param_list_code => ''' || l_list_code || ''' ' ||
             '          ,p_param_defn_app_id => ' || l_param_defn_app_id ||
             '          ,p_param_defn_code   => ''' || l_param_defn_code || ''' ' ||
             '          ,p_param_name        => ''' || l_param_name  || ''' ' ||             '          ,p_attribute_app_id  => null ' ||
             '          ,p_attribute_code    => null ' ||
             '          ,p_string_val        => :2 ' ||
             '          ,p_date_val          => null ' ||
             '          ,p_number_val        => null ' ||
             '          ,p_boolean_val       => null ' ||
             '          ,p_formula           => null ' ||
             '          ,p_desc_val         => ''' || l_desc_value || ''' ' ||
             '          ); ' ||
             ' END;';
  --
  EXECUTE IMMEDIATE l_plsql
    USING out l_sequence_num
        , in l_where2;
  --
  --  COMMIT;
  --
  --$ Add third parameter to the parameter list to pass form name
  --
  l_param_name := 'hr:form';
  l_desc_value := 'hr form parameter';
  l_plsql := 'BEGIN ' ||
             '  :1 := BNE_PARAMETER_UTILS.CREATE_LIST_ITEMS_ALL ' ||
             '          (p_application_id  => 800 ' ||
             '          ,p_param_list_code => ''' || l_list_code || ''' ' ||
             '          ,p_param_defn_app_id => null ' ||
             '          ,p_param_defn_code   => null ' ||
             '          ,p_param_name        =>  ''' || l_param_name  || ''' ' ||
             '          ,p_attribute_app_id  => null ' ||
             '          ,p_attribute_code    => null ' ||
             '          ,p_string_val        => :2 ' ||
             '          ,p_date_val          => null ' ||
             '          ,p_number_val        => null ' ||
             '          ,p_boolean_val       => null ' ||
             '          ,p_formula           => null ' ||
             '          ,p_desc_val         =>   ''' || l_desc_value  || ''' ' ||
             '          ); ' ||
             ' END;';
  --
  EXECUTE IMMEDIATE l_plsql
    USING out l_sequence_num
        , in p_form_name;
  --


  RETURN l_list_key;
  --
END get_passed_sql_id;
--
END HR_PASSED_SQL;

/
