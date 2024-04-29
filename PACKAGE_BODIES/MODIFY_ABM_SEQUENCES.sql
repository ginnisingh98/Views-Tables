--------------------------------------------------------
--  DDL for Package Body MODIFY_ABM_SEQUENCES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MODIFY_ABM_SEQUENCES" AS
/*$Header: abmseqb.pls 115.5 2002/03/06 18:35:50 pkm ship    $*/

     xSqlCode VARCHAR2(1000);
     xSqlErr VARCHAR2(1000);
     xUserException EXCEPTION;

    /* The following procedure accepts the sequence name from the user
       retrieves the corresponding table_column_name and the table name
       It calls a function to modify the value of table_column_name
       by 5. And then uses this incremented value of the table column
       and calls a procedure that recreates the sequence with the starting
       value as the "incremented table column value"*/

    PROCEDURE get_tabcol_and_seq(sequence_name VARCHAR2) IS
         table_column_name VARCHAR2(1000) := NULL;
         table_name VARCHAR2(1000) := NULL;
         connect_statement VARCHAR2(1000) := NULL;
         sequence_start_value NUMBER;
    BEGIN

    /* Get the appropriate table_column_name and sequence_name from the
       given table name */

         IF sequence_name = 'ABM_BATCH_CALCS_SEQ' THEN
              table_column_name := 'M84_BATCH_PROG_ID_CTR';
              table_name := 'ABM_BATCH_CALCS';
         END IF;
         IF sequence_name = 'ABM_BOR_HIER_SEQ' THEN
              table_column_name := 'M33_BOR_LINE_ID_CTR';
              table_name := 'ABM_BOR_HIER';
         END IF;
         IF sequence_name = 'ABM_CALCS_LOG_SEQ' THEN
              table_column_name := 'M83_STEP_LOG_ID_CTR';
              table_name := 'ABM_CALCS_LOG';
         END IF;
         IF sequence_name = 'ABM_CALCULATIONS_SEQ' THEN
              table_column_name := 'M03_CALC_PROC_ELEM_STEP_ID_CTR';
              table_name := 'ABM_CALCULATIONS';
         END IF;
         IF sequence_name = 'ABM_CALC_PROCS_SEQ' THEN
              table_column_name := 'M01_CALC_PROC_ID_CTR';
              table_name := 'ABM_CALC_PROCS';
         END IF;
         IF sequence_name = 'ABM_CALC_PROC_STEPS_SEQ' THEN
              table_column_name := 'M02_CALC_STEP_ID_CTR';
              table_name := 'ABM_CALC_PROC_STEPS';
         END IF;
         IF sequence_name = 'ABM_CAL_EXT_COSTS_SEQ' THEN
              table_column_name := 'T05_SEQUENCE_NUMBER';
              table_name := 'ABM_CAL_EXT_COSTS';
         END IF;
         IF sequence_name = 'ABM_COMP_DS_VAL_SEQ' THEN
              table_column_name := 'T10_SEQUENCE_NUMBER';
              table_name := 'ABM_COMP_DS_VAL';
         END IF;
         IF sequence_name = 'ABM_COMP_RES_VAL_SEQ' THEN
              table_column_name := 'T09_SEQUENCE_NUMBER';
              table_name := 'ABM_COMP_RES_VAL';
         END IF;
         IF sequence_name = 'ABM_CO_UNIT_COST_DAT_SEQ' THEN
              table_column_name := 'M47A_SEQ_NBR';
              table_name := 'ABM_CO_UNIT_COST_DAT';
         END IF;
         IF sequence_name = 'ABM_CO_UNIT_COST_EXT_SEQ' THEN
              table_column_name := 'M47B_BOR_NBR';
              table_name := 'ABM_CO_UNIT_COST_EXT';
         END IF;
         IF sequence_name = 'ABM_DERIVE_ACT_COSTS_SEQ' THEN
              table_column_name := 'RUN_NUMBER';
              table_name := 'ABM_DERIVE_ACT_COSTS';
         END IF;
         IF sequence_name = 'ABM_DERIVE_DS_VALS_SEQ' THEN
              table_column_name := 'RUN_NUMBER';
              table_name := 'ABM_DERIVE_DS_VALS';
         END IF;
         IF sequence_name = 'ABM_DERIVE_RES_QTYS_SEQ' THEN
              table_column_name := 'RUN_NUMBER';
              table_name := 'ABM_DERIVE_RES_QTYS';
         END IF;
         IF sequence_name = 'ABM_IMP_RES_TRANS_SEQ' THEN
              table_column_name := 'N12_SEQUENCE_NUMBER';
              table_name := 'ABM_IMP_RES_TRANS';
         END IF;
         IF sequence_name = 'ABM_MAP_BASES_SEQ' THEN
              table_column_name := 'M67_MAPPING_BASIS_ID';
              table_name := 'ABM_MAP_BASES';
         END IF;
         IF sequence_name = 'ABM_NAV_PROCEDURES_SEQ' THEN
              table_column_name := 'NAV_PROC_ID';
              table_name := 'ABM_NAV_PROCEDURES';
         END IF;
         IF sequence_name = 'ABM_NAV_PROC_STEPS_SEQ1' THEN
              table_column_name := 'NAV_PROC_STEP_ID';
              table_name := 'ABM_NAV_PROC_STEPS';
         END IF;
         IF sequence_name = 'ABM_NAV_PROC_STEPS_SEQ2' THEN
              table_column_name := 'NAV_PROC_STEP_SEQ_NUM';
              table_name := 'ABM_NAV_PROC_STEPS';
         END IF;
         IF sequence_name = 'ABM_NAV_STEPS_SEQ' THEN
              table_column_name := 'STEP_ID';
              table_name := 'ABM_NAV_STEPS';
         END IF;
         IF sequence_name = 'ABM_PDS_ACT_RATE_SEQ' THEN
              table_column_name := 'T14_T42_ACT_RATE_CTR';
              table_name := 'ABM_PDS_ACT_RATE';
         END IF;
         IF sequence_name = 'ABM_PROCS_SEQ' THEN
              table_column_name := 'I04_PROC_ID_CTR';
              table_name := 'ABM_PROCS';
         END IF;
         IF sequence_name = 'ABM_PROC_HIER_SEQ' THEN
              table_column_name := 'T07_SEQUENCE_NUMBER';
              table_name := 'ABM_PROC_HIER';
         END IF;
         IF sequence_name = 'ABM_PROC_STEPS_SEQ' THEN
              table_column_name := 'I05_STEP_ID_CTR';
              table_name := 'ABM_PROC_STEPS';
         END IF;
         IF sequence_name = 'ABM_RES_RE_ACC_DAT_SEQ' THEN
              table_column_name := 'M16_SEQUENCE_NUMBER';
              table_name := 'ABM_RES_RE_ACC_DAT';
         END IF;
         IF sequence_name = 'ABM_RES_RE_STA_DAT_SEQ' THEN
              table_column_name := 'M17_SEQUENCE_NUMBER';
              table_name := 'ABM_RES_RE_STA_DAT';
         END IF;
         IF sequence_name = 'ABM_RE_ACC_DAT_SEQ' THEN
              table_column_name := 'M60_SEQUENCE_NUMBER';
              table_name := 'ABM_RE_ACC_DAT';
         END IF;
         IF sequence_name = 'ABM_RE_ACC_MAP_FORMS_SEQ' THEN
              table_column_name := 'M08_MAPPING_FORMULA_ID';
              table_name := 'ABM_RE_ACC_MAP_FORMS';
         END IF;
         IF sequence_name = 'ABM_SEC_OBJS_SEQ' THEN
              table_column_name := 'I91_OBJ_ID';
              table_name := 'ABM_SEC_OBJS';
         END IF;
         IF sequence_name = 'ABM_ACC_MAP_SUM_REP_SEQ' THEN
              table_column_name := 'ROW_CTR';
              table_name := 'ABM_ACC_MAP_SUM_REP';
         END IF;
         IF sequence_name = 'ABM_ATT_ID_SEQ' THEN
              table_column_name := 'ATTRIBUTE_TYPE_ID';
              table_name := 'ABM_ATTRIBUTE_TYPE';
         END IF;
         IF sequence_name = 'ABM_BOR_HIER_REP_SEQ' THEN
              table_column_name := 'T33_HIER_ID_CTR';
              table_name := 'ABM_BOR_HIER_REP';
         END IF;
         IF sequence_name = 'ABM_BOR_LINE_REP_SEQ' THEN
              table_column_name := 'T33_BOR_LINE_ID_CTR';
              table_name := 'ABM_BOR_LINE_REP';
         END IF;
         IF sequence_name = 'ABM_CO_MARG_COMP_REP_SEQ' THEN
              table_column_name := 'RUN_NUMBER';
              table_name := 'ABM_CO_MARG_COMP_REP';
         END IF;
         IF sequence_name = 'ABM_DRV_DS_DTL_REP_SEQ' THEN
              table_column_name := 'SURRROGATE_ID';
              table_name := 'ABM_DRV_DS_DTL_REP';
         END IF;
         IF sequence_name = 'ABM_FLAT_PROC_HIER_SEQ' THEN
              table_column_name := 'T06_SEQUENCE_NUMBER';
              table_name := 'ABM_FLAT_PROC_HIER';
         END IF;
         IF sequence_name = 'ABM_PROC_WIN_STEPS_SEQ' THEN
              table_column_name := 'I08_STEP_ID';
              table_name := 'ABM_PROC_WIN_STEPS';
         END IF;
         IF sequence_name = 'ABM_RES_STA_REP_SEQ' THEN
              table_column_name := 'RUN_NUMBER';
              table_name := 'ABM_RES_STA_REP';
         END IF;
         IF sequence_name = 'ABM_SYS_ERRORS_LOG_SEQ' THEN
              table_column_name := 'I21_SYS_ERR_REF_NUM';
              table_name := 'ABM_SYS_ERRORS_LOG';
         END IF;
         IF sequence_name = 'ABM_TEMPLATE_S' THEN
              table_column_name := 'TEMPLATE_ID';
              table_name := 'ABM_BUS_VIEW_TEMPLATES';
         END IF;

         IF (table_column_name IS NULL) OR (table_name IS NULL) THEN
              --dbms_output.put_line('An Error has occured');
              --dbms_output.put_line('Incorrect sequence name ' || sequence_name);
              RAISE xUserException;
         ELSE
             /* Get the starting value for the sequence from this function
                modify_table_column_by_value */
             sequence_start_value := modify_table_column_by_value(table_name, table_column_name,5);
             IF(xSqlCode <> 0)THEN
                RAISE xUserException;
             END IF;

             /* Recreate the sequence with the start value as the value
                obtained from the previous function*/
             create_sequence_with_new_value ( sequence_name, sequence_start_value);
             IF(xSqlCode <> 0)THEN
                RAISE xUserException;
             END IF;

         END IF;

         EXCEPTION
            WHEN xUserException THEN
                 ROLLBACK;
                 --dbms_output.put_line('An Error has occured please check the following code........');
                 --dbms_output.put_line(xSqlCode);
                 --dbms_output.put_line(xSqlErr);
                 RAISE;

            WHEN OTHERS THEN
                xSqlCode := SQLCODE;
                xSqlErr := SQLERRM(xSqlCode);
                ROLLBACK;
                --dbms_output.put_line('An Error has occured please check the following code..........');
                --dbms_output.put_line(xSqlCode);
                --dbms_output.put_line(xSqlErr);
                RAISE;

    END get_tabcol_and_seq;


    /*--------------------------------------------------------------------*/
    /* This function accepts the ABM table column name , selects it into a temporary variable and increments the value by 5 */

    FUNCTION modify_table_column_by_value ( table_name VARCHAR2, table_column_name VARCHAR2,increment_value NUMBER) RETURN NUMBER IS
    column_holder NUMBER;
    select_statement VARCHAR2(1000);
    BEGIN

        select_statement :=  'SELECT NVL(MAX(' || table_column_name || '),0)'
                              ||' FROM ABM.'|| table_name;


 	    EXECUTE IMMEDIATE select_statement INTO column_holder;

        column_holder := column_holder + increment_value;

        RETURN column_holder;

        EXCEPTION
          WHEN OTHERS THEN
              xSqlCode := SQLCODE;
              xSqlErr := SQLERRM(xSqlCode);


    END modify_table_column_by_value;


    /*--------------------------------------------------------------------*/
    /* This procedure drops the selected sequence and recreates it with
       the input starting value */

    PROCEDURE create_sequence_with_new_value ( sequence_name VARCHAR2, starting_value NUMBER) IS

    sequence_holder VARCHAR2(1000);
    create_statement VARCHAR2(1000);
    select_statement VARCHAR2(1000);
    drop_statement VARCHAR2(1000);
    seq_max_value VARCHAR2(1000) := 2147483647;

    BEGIN

        BEGIN

         	select_statement :=  'SELECT SEQUENCE_NAME '
              ||' FROM ALL_SEQUENCES'
              ||' WHERE SEQUENCE_NAME = '
              ||'''' || sequence_name || ''''
              ||'AND SEQUENCE_OWNER = ' || '''' || 'ABM' || '''';


         	EXECUTE IMMEDIATE select_statement INTO  sequence_holder;


         	EXECUTE IMMEDIATE 'DROP SEQUENCE ABM.' || sequence_name;

         	EXCEPTION
                	WHEN NO_DATA_FOUND THEN
                  		NULL;

         END;

         	create_statement :=  'CREATE SEQUENCE ABM.' || sequence_name
                  ||' INCREMENT BY 1'
                  ||' START WITH '|| starting_value
                  ||' MINVALUE 1 '
                  ||' MAXVALUE ' || seq_max_value
                  ||' NOCYCLE NOORDER CACHE 20';

         	EXECUTE IMMEDIATE create_statement;

            --dbms_output.put_line(sequence_name || ' From ' || starting_value);

         EXCEPTION
            WHEN OTHERS THEN
                xSqlCode := SQLCODE;
                xSqlErr := SQLERRM(xSqlCode);

   END create_sequence_with_new_value;


END modify_abm_sequences;

/
