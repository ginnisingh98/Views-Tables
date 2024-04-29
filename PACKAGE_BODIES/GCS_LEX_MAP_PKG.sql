--------------------------------------------------------
--  DDL for Package Body GCS_LEX_MAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_LEX_MAP_PKG" as
/* $Header: gcslxmpb.pls 115.1 2003/08/15 19:28:56 jhhuang noship $ */


    FUNCTION get_concat_conditions (Derivation_Id NUMBER) RETURN VARCHAR2 IS
     CURSOR condition_cur(derivId NUMBER) IS
      select column_name,
             meaning,
             comparison_value
      from gcs_lex_map_conditions,
            fnd_lookup_values,
            gcs_lex_map_columns
      where derivation_id = derivId
      and source_column_id = column_id
      and lookup_type = 'COMPARISON_OPERATOR'
      and lookup_code =comparison_operator_code
      and language = 'US'
      and view_application_id = 266;

    cond_text     VARCHAR2(1000);
    v_deriv_id   NUMBER(15);
    v_counter   NUMBER(15);

    BEGIN

        v_counter :=0;
        v_deriv_id := Derivation_Id;
        --dbms_output.put_line('v_deriv_id= '|| v_deriv_id);
        FOR cond_record IN condition_cur(v_deriv_id) LOOP
        --dbms_output.put_line('in the for loop');
        IF  (v_counter >0) THEN
            --dbms_output.put_line('v_counter = '|| v_counter);
            cond_text := cond_text || ' AND ';
        END IF;
        cond_text := cond_text ||
                    cond_record.column_name || ' ' ||
                    cond_record.meaning;
        IF(cond_record.comparison_value is not null) THEN
        cond_text:= cond_text || ' ''' ||
                    cond_record.comparison_value || '''';
        END IF;
        v_counter := v_counter + 1 ;

        --dbms_output.put_line(cond_text);
        END LOOP;
        RETURN(cond_text);

    EXCEPTION
        WHEN app_exceptions.application_exception THEN
        RAISE;
        WHEN OTHERS THEN
        fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
        fnd_message.set_token('PROCEDURE', 'gcs_lex_map_pkg.get_concatenated_con
ditions');

        RAISE;
END get_concat_conditions;

END GCS_LEX_MAP_PKG;



/
