--------------------------------------------------------
--  DDL for Package Body CZ_LC_MGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_LC_MGR" AS
/*  $Header: czlcmgrb.pls 115.21 2004/05/17 19:46:48 skudravs ship $	*/

PROCEDURE get_BATCH_size IS
BEGIN
SELECT TO_NUMBER(VALUE) INTO BATCH_size FROM CZ_DB_SETTINGS
WHERE UPPER(SETTING_ID)='BATCHSIZE';
EXCEPTION
WHEN NO_DATA_FOUND THEN
     BATCH_size:=5000;
WHEN OTHERS THEN
     BATCH_size:=5000;
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE assess_data IS
BEGIN
NULL;
END;


/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE redo_statistics IS
BEGIN
cz_base_mgr.REDO_STATISTICS('LC');
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE triggers_enabled
(Switch IN VARCHAR2) IS
BEGIN
cz_base_mgr.TRIGGERS_ENABLED('LC',Switch);
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE constraints_enabled
(Switch IN VARCHAR2) IS
BEGIN
cz_base_mgr.CONSTRAINTS_ENABLED('LC',Switch);
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE redo_sequences
(RedoStart_Flag IN VARCHAR2,
 incr           IN INTEGER DEFAULT NULL) IS
BEGIN
cz_base_mgr.REDO_SEQUENCES('LC',RedoStart_Flag,incr);
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE Propogate_DeletedFlag IS
BEGIN
  CZ_BASE_MGR.exec('CZ_LCE_HEADERS','where deleted_flag='''||'0'||''' AND '||
                 'component_id in(select ps_node_id from CZ_PS_NODES where deleted_flag='''||'1'||''')',
                 'lce_header_id',FALSE);

  CZ_BASE_MGR.exec('CZ_LCE_LOAD_SPECS','where deleted_flag='''||'0'||''' AND '||
                 'lce_header_id in(select lce_header_id from CZ_LCE_HEADERS where deleted_flag='''||'1'||''')',
                 'lce_header_id','attachment_expl_id','required_expl_id',FALSE);

  CZ_BASE_MGR.exec('CZ_LCE_TEXTS','where '||
                 'lce_header_id in(select lce_header_id from CZ_LCE_HEADERS where deleted_flag='''||'1'||''')',
                 'lce_header_id','seq_nbr',TRUE);
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE purge IS
BEGIN
Propogate_DeletedFlag;
cz_base_mgr.PURGE('LC');
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE RESET_CLEAR IS
BEGIN
NULL;
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE modified
(AS_OF IN OUT NOCOPY DATE) IS
BEGIN
cz_base_mgr.MODIFIED('LC',AS_OF);
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

FUNCTION makeOperator(inCode IN NUMBER) RETURN VARCHAR2 IS
v_operator_return VARCHAR2(20);
BEGIN

IF inCode = OPERATOR_LT THEN
      v_operator_return := '<';
ELSIF inCode = OPERATOR_GT THEN
      v_operator_return := '>';
ELSIF inCode = OPERATOR_EQUALS THEN
      v_operator_return := '=';
ELSIF inCode = OPERATOR_NOTEQUALS THEN
  v_operator_return := '!=';
ELSIF inCode = OPERATOR_NOT THEN
  v_operator_return := '!=';
ELSIF inCode = OPERATOR_LE THEN
  v_operator_return := '<=';
ELSIF inCode = OPERATOR_GE THEN
      v_operator_return := '>=';
ELSIF inCode = OPERATOR_ADD THEN
  v_operator_return := '+';
ELSIF inCode = OPERATOR_SUB THEN
      v_operator_return := '-';
ELSIF inCode = OPERATOR_MULT THEN
  v_operator_return := '*';
ELSIF inCode = OPERATOR_DIV THEN
      v_operator_return := '/';
ELSIF inCode = OPERATOR_MIN THEN
  v_operator_return := 'min';
ELSIF inCode = OPERATOR_MAX THEN
  v_operator_return := 'max';
ELSE
      v_operator_return := null;
END IF;
RETURN v_operator_return;
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/


PROCEDURE generate_lce_varchar(lce_header_id IN  NUMBER)
AS

p_lce_header_id   NUMBER;
Batch_Counter     INTEGER:=0;

CURSOR   header_cursor  IS
        SELECT lce_header_id,
               desc_text,
                               component_id,
                               gen_version
        FROM   cz_lce_headers
        WHERE  Lce_header_id = p_lce_header_id;

CURSOR  lines_cursor(p_lce_header_id NUMBER) IS
                SELECT  lce_line_id,
                        int_operand1,
                    int_operand2,
                    fp_operand,
                    operator, name,
                    prior_line_id,
                    line_type,
                    intl_text_id,
                    int_operand3
                FROM    cz_lce_lines
                WHERE   lce_header_id = p_lce_header_id
                    ORDER BY    lce_line_id ;

CURSOR operands_cursor(p_lce_header_id NUMBER ) IS
                SELECT  lce_line_id,
                    operand_seq,
                    operand_type,
                    name
                FROM    cz_lce_operands
                WHERE   lce_header_id = p_lce_header_id
                ORDER BY    lce_line_id, operand_seq;

  v_header_cursor   header_cursor%ROWTYPE;
  v_lines_cursor    lines_cursor%ROWTYPE;
  v_operands_cursor operands_cursor%ROWTYPE;
  v_op_type   cz_lce_operands.operand_type%TYPE;
  v_name      VARCHAR2(255);
  v_generic_type    CHAR(1);
  v_line_type     CHAR(1);
  v_op1       VARCHAR2(255);
  v_op2       VARCHAR2(255);
  v_op3       VARCHAR2(255);
  v_operator    NUMBER;
  v_right_op    VARCHAR2(255);
  v_result_op     VARCHAR2(255);
  v_operator_return   VARCHAR2(3);
  v_op      VARCHAR2(255);
  v_buffer    VARCHAR2(2000):=' ';
  text      VARCHAR2(2000);
  v_xx_count    NUMBER:= 0;
  v_buffer_length   NUMBER:=0;
  counter     NUMBER := 1;
  init_counter    NUMBER := 1;
  line_id_found   BOOLEAN:= FALSE;
  v_seq_no    INTEGER:=0;
      var_sgn                 VARCHAR2(3);
  v_prop          VARCHAR2(255);
      v_withcell_value        VARCHAR2(255);

  TYPE  t_operandsRecord IS RECORD (
  lce_line_id   cz_lce_operands.lce_line_id%TYPE,
  operand_seq   cz_lce_operands.operand_seq%TYPE,
  operand_type  cz_lce_operands.operand_type%TYPE,
  name      cz_lce_operands.name%TYPE
  );

  TYPE operandsTable IS TABLE OF t_operandsRecord INDEX BY BINARY_INTEGER;
  TYPE text_field_Table IS TABLE OF cz_lce_texts.lce_text%TYPE INDEX BY BINARY_INTEGER;
  v_operandsTable   operandsTable;
  v_text_field_Table  text_field_Table;
  text_field_counter  NUMBER:=0;

  BEGIN
        get_BATCH_size;
    p_lce_header_id := lce_header_id;

    OPEN header_cursor;
    LOOP
      FETCH header_cursor
      INTO v_header_cursor ;
      EXIT WHEN header_cursor%NOTFOUND ;
    END LOOP;
    CLOSE header_cursor;


    OPEN operands_cursor(v_header_cursor.lce_header_id);
    LOOP
      FETCH operands_cursor INTO v_operands_cursor;
      EXIT WHEN operands_cursor%NOTFOUND;
      v_operandsTable(counter).lce_line_id  := v_operands_cursor.lce_line_id;
      v_operandsTable(counter).operand_seq  := v_operands_cursor.operand_seq;
      v_operandsTable(counter).operand_type := v_operands_cursor.operand_type;
      v_operandsTable(counter).name     := v_operands_cursor.name;
      counter := counter +1;
    END LOOP;
    CLOSE operands_cursor;

    text_field_counter := text_field_counter + 1;
    v_text_field_Table(text_field_counter) :='REM Generated LCE file';
    text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter) := ENDOFLINE1;
    text_field_counter := text_field_counter + 1;
    v_text_field_Table(text_field_counter) :='REM DO NOT EDIT THIS FILE';
    text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter) := ENDOFLINE1;
    text_field_counter := text_field_counter + 1;
    v_text_field_Table(text_field_counter) :='CONTROL NOSPEC';
    text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter) := ENDOFLINE1;
    text_field_counter := text_field_counter + 1;
    v_text_field_Table(text_field_counter) :='VERSION 3 3';
    text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter) := ENDOFLINE1;
          text_field_counter := text_field_counter + 1;
       v_text_field_Table(text_field_counter):='SETDEFAULTDELTA F';
    text_field_counter := text_field_counter + 1;
    v_text_field_Table(text_field_counter) := ENDOFLINE1;

           text_field_counter := text_field_counter + 1;
       v_text_field_Table(text_field_counter):='REM -- Component: '||to_char(v_header_cursor.component_id)||ENDOFLINE1;
    text_field_counter := text_field_counter + 1;
    v_text_field_Table(text_field_counter) := ENDOFLINE1;
           text_field_counter := text_field_counter + 1;
       v_text_field_Table(text_field_counter):='REM -- Description: '||v_header_cursor.desc_text||ENDOFLINE1;
    text_field_counter := text_field_counter + 1;
    v_text_field_Table(text_field_counter) := ENDOFLINE1;

    OPEN lines_cursor(v_header_cursor.lce_header_id);
    LOOP
      FETCH lines_cursor  INTO v_lines_cursor;
      EXIT WHEN lines_cursor%NOTFOUND;

      IF (v_lines_cursor.line_type = LOGIC_VERB_OBJECT) THEN
        text_field_counter := text_field_counter + 1;
            v_text_field_Table(text_field_counter) :='OBJECT '||v_lines_cursor.name ;
                       IF (v_lines_cursor.int_operand3=1) THEN
                         v_text_field_Table(text_field_counter):=v_text_field_Table(text_field_counter)||' R';
                       END IF;
           LOOP
          EXIT WHEN (init_counter >=counter);
          EXIT WHEN(( v_operandsTable(init_counter).lce_line_id > v_lines_cursor.lce_line_id )OR (init_counter =counter));
          text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter) :=' '||v_operandsTable(init_counter).name;
          init_counter := init_counter + 1;
        END LOOP;
        text_field_counter := text_field_counter + 1;
        v_text_field_Table(text_field_counter) := ENDOFLINE1;

      ELSIF ( v_lines_cursor.line_type = LOGIC_VERB_TOTAL) THEN
        text_field_counter := text_field_counter + 1;
        v_text_field_Table(text_field_counter) :='TOTAL '||v_lines_cursor.name;

        IF (v_lines_cursor.int_operand2 = 1) THEN
          text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter) :=' R';
        END IF;

        IF (v_lines_cursor.int_operand3 <> -1) THEN
          text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter) :=' '||v_lines_cursor.fp_operand;
        END IF;
        IF (v_lines_cursor.int_operand1 = 1) THEN
          text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter) :=' D+';
        END IF;

        text_field_counter := text_field_counter + 1;
        v_text_field_Table(text_field_counter):= ENDOFLINE1;

       ELSIF (v_lines_cursor.line_type = LOGIC_VERB_SG0) THEN
        text_field_counter := text_field_counter + 1;
        v_text_field_Table(text_field_counter) :='SGO '||v_lines_cursor.name ;
        LOOP
          EXIT WHEN (init_counter >=counter);
          EXIT WHEN((v_operandsTable(init_counter).lce_line_id > v_lines_cursor.lce_line_id ) OR (init_counter =counter));
          text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter):=' '||v_operandsTable(init_counter).name;
          init_counter := init_counter + 1;
        END LOOP;
        IF ( v_lines_cursor.intl_text_id IS NOT NULL ) THEN
          text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter):= ' ... '||v_lines_cursor.intl_text_id;
        END IF;
        text_field_counter := text_field_counter + 1;
        v_text_field_Table(text_field_counter)  := ENDOFLINE1;

       ELSIF (v_lines_cursor.line_type = LOGIC_VERB_SG1) THEN
        text_field_counter := text_field_counter + 1;
        v_text_field_Table(text_field_counter) :='SG1 '||v_lines_cursor.name;

        LOOP
          EXIT WHEN (init_counter >=counter);
          EXIT WHEN( (v_operandsTable(init_counter).lce_line_id > v_lines_cursor.lce_line_id ) OR (init_counter =counter));
          text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter) :=' '||v_operandsTable(init_counter).name;
          init_counter := init_counter + 1;
        END LOOP;
        IF ( v_lines_cursor.intl_text_id IS NOT NULL ) THEN
          text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter):=' ... '||v_lines_cursor.intl_text_id;
        END IF;
        text_field_counter := text_field_counter + 1;
        v_text_field_Table(text_field_counter)  := ENDOFLINE1;

       ELSIF (v_lines_cursor.line_type = LOGIC_VERB_SG) THEN
        text_field_counter := text_field_counter + 1;
        v_text_field_Table(text_field_counter) :='SG '||v_lines_cursor.name;

        LOOP
          EXIT WHEN (init_counter >=counter);
          EXIT WHEN( (v_operandsTable(init_counter).lce_line_id > v_lines_cursor.lce_line_id ) OR (init_counter =counter));
          text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter) :=' '||v_operandsTable(init_counter).name;
          init_counter := init_counter + 1;
        END LOOP;
        IF ( v_lines_cursor.intl_text_id IS NOT NULL ) THEN
          text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter):=' ... '||v_lines_cursor.intl_text_id;
        END IF;

        text_field_counter := text_field_counter + 1;
        v_text_field_Table(text_field_counter)  := ENDOFLINE1;

         ELSIF (v_lines_cursor.line_type = LOGIC_VERB_MINMAX) THEN
         text_field_counter := text_field_counter + 1;
         v_text_field_Table(text_field_counter) :='MINMAX '||v_lines_cursor.int_operand1||' '||v_lines_cursor.int_operand2;
        LOOP
          EXIT WHEN (init_counter >=counter);
          EXIT WHEN( (v_operandsTable(init_counter).lce_line_id > v_lines_cursor.lce_line_id ) OR (init_counter =counter));
          text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter) :=' '||v_operandsTable(init_counter).name;
          init_counter := init_counter + 1;
        END LOOP;
        IF ( v_lines_cursor.intl_text_id IS NOT NULL ) THEN
          text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter):=' ... '||v_lines_cursor.intl_text_id;
        END IF;
        text_field_counter := text_field_counter + 1;
        v_text_field_Table(text_field_counter)  := ENDOFLINE1;

        ELSIF (v_lines_cursor.line_type = LOGIC_VERB_COMBO) THEN
        text_field_counter := text_field_counter + 1;
        v_text_field_Table(text_field_counter) :='COMBO '||v_lines_cursor.name||' '||v_lines_cursor.int_operand1||' '||v_lines_cursor.int_operand2||' '||v_lines_cursor.int_operand3;
        LOOP
          EXIT WHEN (init_counter >=counter);
          EXIT WHEN( (v_operandsTable(init_counter).lce_line_id > v_lines_cursor.lce_line_id ) OR (init_counter =counter));
          text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter) :=' '||v_operandsTable(init_counter).name;
          init_counter := init_counter + 1;
        END LOOP;
        IF ( v_lines_cursor.intl_text_id IS NOT NULL ) THEN
          text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter):=' ... '||v_lines_cursor.intl_text_id;
        END IF;

        text_field_counter := text_field_counter + 1;
        v_text_field_Table(text_field_counter)  := ENDOFLINE1;

      ELSIF (v_lines_cursor.line_type = LOGIC_VERB_CI) THEN
        text_field_counter := text_field_counter + 1;
        v_text_field_Table(text_field_counter) :='CI '||v_lines_cursor.int_operand1||' '||v_lines_cursor.name||' '||v_lines_cursor.int_operand2;
        text_field_counter := text_field_counter + 1;
        v_text_field_Table(text_field_counter)  := ENDOFLINE1;

      ELSIF (v_lines_cursor.line_type = LOGIC_VERB_CC) THEN
        text_field_counter := text_field_counter + 1;
        v_text_field_Table(text_field_counter) :='CC '||v_lines_cursor.int_operand1||' '||v_lines_cursor.int_operand2||' '||v_lines_cursor.int_operand3||' '||v_lines_cursor.name;
        text_field_counter := text_field_counter + 1;
        v_text_field_Table(text_field_counter)  := ENDOFLINE1;

      ELSIF (v_lines_cursor.line_type = LOGIC_VERB_CR) THEN
        text_field_counter := text_field_counter + 1;
        v_text_field_Table(text_field_counter) :='CR '||v_lines_cursor.int_operand1;
        LOOP
          EXIT WHEN (init_counter >=counter);
          EXIT WHEN( (v_operandsTable(init_counter).lce_line_id > v_lines_cursor.lce_line_id ) OR (init_counter =counter));
          text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter) :=' '||v_operandsTable(init_counter).name;
          init_counter := init_counter + 1;
        END LOOP;

        IF ( v_lines_cursor.intl_text_id IS NOT NULL ) THEN
          text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter):=' ... '||v_lines_cursor.intl_text_id;
        END IF;
        text_field_counter := text_field_counter + 1;
        v_text_field_Table(text_field_counter)  := ENDOFLINE1;

      ELSIF (v_lines_cursor.line_type = LOGIC_VERB_COMBO_END) THEN
        text_field_counter := text_field_counter + 1;
        v_text_field_Table(text_field_counter) :='COMBO_END';
        text_field_counter := text_field_counter + 1;
        v_text_field_Table(text_field_counter)  := ENDOFLINE1;


      ELSIF (v_lines_cursor.line_type = LOGIC_VERB_GS) THEN
        IF v_lines_cursor.name IS NULL THEN
          v_name := '';
        ELSE
          v_name := ' '||v_lines_cursor.name;
        END IF;
        IF v_lines_cursor.int_operand1 = OPR_REQUIRES THEN
          v_generic_type := 'R';
        ELSIF v_lines_cursor.int_operand1 = OPR_IMPLIES THEN
          v_generic_type := 'I';
        ELSIF v_lines_cursor.int_operand1 = OPR_EXCLUDES THEN
          v_generic_type := 'E';
        ELSIF v_lines_cursor.int_operand1 = OPR_NEGATES THEN
          v_generic_type := 'N';
        END IF;
        text_field_counter := text_field_counter + 1;
        v_text_field_Table(text_field_counter) := 'GS '||v_generic_type||v_name;
        IF ( v_lines_cursor.intl_text_id IS NOT NULL ) THEN
          text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter):=' ... '||v_lines_cursor.intl_text_id;
        END IF;
        text_field_counter := text_field_counter + 1;
        v_text_field_Table(text_field_counter)  := ENDOFLINE1;

      ELSIF (v_lines_cursor.line_type = LOGIC_VERB_GL) THEN
        IF v_lines_cursor.int_operand1 = OPERATOR_ANYOF THEN
          v_line_type := 'N';
        ELSIF v_lines_cursor.int_operand1 = OPERATOR_ALLOF THEN
          v_line_type := 'L';
        ELSE
          v_line_type := NULL;
        END IF;
        text_field_counter := text_field_counter + 1;
        v_text_field_Table(text_field_counter) := 'GL '||v_line_type;
        LOOP
          EXIT WHEN (init_counter >=counter);
          EXIT WHEN( (v_operandsTable(init_counter).lce_line_id > v_lines_cursor.lce_line_id ) OR (init_counter =counter));
          text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter) :=' '||v_operandsTable(init_counter).name;
          init_counter := init_counter + 1;
        END LOOP;

        text_field_counter := text_field_counter + 1;
        v_text_field_Table(text_field_counter)  := ENDOFLINE1;

       ELSIF (v_lines_cursor.line_type = LOGIC_VERB_GR) THEN
        IF v_lines_cursor.int_operand1 = OPERATOR_ANYOF THEN
          v_line_type := 'N';
        ELSIF v_lines_cursor.int_operand1 = OPERATOR_ALLOF THEN
          v_line_type := 'L';
        ELSE
          v_line_type := NULL;
        END IF;
        text_field_counter := text_field_counter + 1;
        v_text_field_Table(text_field_counter) := 'GR '||v_line_type;

        LOOP
          EXIT WHEN (init_counter >=counter);
          EXIT WHEN( (v_operandsTable(init_counter).lce_line_id > v_lines_cursor.lce_line_id ) OR (init_counter >=counter));
          text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter) :=' '||v_operandsTable(init_counter).name;
          init_counter := init_counter + 1;
        END LOOP;

        text_field_counter := text_field_counter + 1;
        v_text_field_Table(text_field_counter)  := ENDOFLINE1;

       ELSIF (v_lines_cursor.line_type = LOGIC_VERB_CONTRIBUTE) THEN

        LOOP
          EXIT WHEN((init_counter >= counter));
          EXIT WHEN( (v_operandsTable(init_counter).lce_line_id > v_lines_cursor.lce_line_id ) OR (init_counter >=counter));
          v_op1 := v_operandsTable(init_counter).name;
          v_op2 := v_operandsTable(init_counter+1).name;
          v_op3 := v_operandsTable(init_counter+2).name;
          init_counter := init_counter+3;
        END LOOP;

                        v_operator_return:=makeOperator(v_lines_cursor.operator);

                IF v_lines_cursor.name IS NULL THEN
          text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter) := 'CONTRIBUTE '||v_op1||' '||v_operator_return||' '||v_op2||' '||v_op3;
        ELSE
          text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter) := 'CONTRIBUTE '||v_op1||' '||v_operator_return||' '||v_op2||' '||v_op3||' '||v_lines_cursor.name;
        END IF;
        IF ( v_lines_cursor.intl_text_id IS NOT NULL ) THEN
          text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter):=' ... '||v_lines_cursor.intl_text_id;
        END IF;

        text_field_counter := text_field_counter + 1;
        v_text_field_Table(text_field_counter)  := ENDOFLINE1;

      ELSIF (v_lines_cursor.line_type = LOGIC_VERB_WITH) THEN

        LOOP
          EXIT WHEN (init_counter >=counter);
          EXIT WHEN( (v_operandsTable(init_counter).lce_line_id > v_lines_cursor.lce_line_id ) OR (init_counter =counter));
          text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter) :='WITH '||v_lines_cursor.name||' = '||v_operandsTable(init_counter).name;
          text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter)  := ENDOFLINE1;
          init_counter := init_counter + 1;
        END LOOP;

      ELSIF (v_lines_cursor.line_type = LOGIC_VERB_WITHCELL) THEN

        LOOP
          EXIT WHEN (init_counter >=counter);
          EXIT WHEN( (v_operandsTable(init_counter).lce_line_id > v_lines_cursor.lce_line_id ) OR (init_counter =counter));
          v_prop := v_operandsTable(init_counter).name;
          v_withcell_value := v_operandsTable(init_counter + 1).name;
          init_counter := init_counter + 2;
        END LOOP;

          text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter) := 'WITHCELL '||v_lines_cursor.name||' '||v_prop||' = '||v_withcell_value ;
          text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter)  := ENDOFLINE1;


      ELSIF (v_lines_cursor.line_type = LOGIC_VERB_COMPARE) THEN

        LOOP
          EXIT WHEN (init_counter >=counter);
          EXIT WHEN( (v_operandsTable(init_counter).lce_line_id > v_lines_cursor.lce_line_id ) OR (init_counter =counter));
          v_right_op := v_operandsTable(init_counter).name;
          v_result_op := v_operandsTable(init_counter+1).name;
          init_counter := init_counter + 2;
        END LOOP;

        v_operator_return:=makeOperator(v_lines_cursor.operator);

        text_field_counter := text_field_counter + 1;
        v_text_field_Table(text_field_counter) := 'COMPARE '||' '||v_lines_cursor.name||' '||v_operator_return||' '||v_right_op||' '||v_result_op;
        IF ( v_lines_cursor.intl_text_id IS NOT NULL ) THEN
          text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter):=' ... '||v_lines_cursor.intl_text_id;
        END IF;

        text_field_counter := text_field_counter + 1;
        v_text_field_Table(text_field_counter) := ENDOFLINE1;

      ELSIF (v_lines_cursor.line_type = LOGIC_VERB_INC) THEN
        text_field_counter := text_field_counter + 1;
        v_text_field_Table(text_field_counter) :='INC';
        LOOP
          EXIT WHEN (init_counter >=counter);
          EXIT WHEN( (v_operandsTable(init_counter).lce_line_id > v_lines_cursor.lce_line_id ) OR (init_counter =counter));
          text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter) :=' '||v_operandsTable(init_counter).name;
          init_counter := init_counter + 1;
        END LOOP;
                    v_text_field_Table(text_field_counter) := v_text_field_Table(text_field_counter)||' '||v_lines_cursor.name;
        IF ( v_lines_cursor.intl_text_id IS NOT NULL ) THEN
          text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter):=' ... '||v_lines_cursor.intl_text_id;
        END IF;

        text_field_counter := text_field_counter + 1;
        v_text_field_Table(text_field_counter)  := ENDOFLINE1;
      ELSIF (v_lines_cursor.line_type = LOGIC_VERB_TEXT) THEN
        LOOP
          EXIT WHEN (init_counter >=counter);
          EXIT WHEN( (v_operandsTable(init_counter).lce_line_id > v_lines_cursor.lce_line_id ) OR (init_counter =counter));
          v_op := v_operandsTable(init_counter).name;
          init_counter := init_counter + 1;
        END LOOP;

        IF v_op IS NULL THEN
          text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter) :='TEXT '||v_lines_cursor.name||' ""';
        ELSE
          text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter) :='TEXT '||v_lines_cursor.name||' "'||v_op||'"';
        END IF;
        text_field_counter := text_field_counter + 1;
        v_text_field_Table(text_field_counter)  := ENDOFLINE1;

      ELSIF ( v_lines_cursor.line_type = LOGIC_VERB_SGN ) THEN
                        IF (v_lines_cursor.int_operand3=1) THEN
                           var_sgn:='R ';
                        ELSE
                          var_sgn:='';
                        END IF;
        text_field_counter := text_field_counter + 1;
        v_text_field_Table(text_field_counter) :='SGN '||v_lines_cursor.name||' '||var_sgn||v_lines_cursor.int_operand1||' '||v_lines_cursor.int_operand2;
        LOOP
          EXIT WHEN (init_counter >=counter);
          EXIT WHEN( (v_operandsTable(init_counter).lce_line_id > v_lines_cursor.lce_line_id ) OR (init_counter =counter));
          text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter) :=' '||v_operandsTable(init_counter).name;
          init_counter := init_counter + 1;
        END LOOP;
        IF ( v_lines_cursor.intl_text_id IS NOT NULL ) THEN
          text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter):=' ... '||v_lines_cursor.intl_text_id;
        END IF;
        text_field_counter := text_field_counter + 1;
        v_text_field_Table(text_field_counter)  := ENDOFLINE1;

      ELSIF (v_lines_cursor.line_type = LOGIC_VERB_SET) THEN

        LOOP
          EXIT WHEN (init_counter >=counter);
          EXIT WHEN( (v_operandsTable(init_counter).lce_line_id > v_lines_cursor.lce_line_id ) OR (init_counter =counter));
          v_op1 := v_operandsTable(init_counter).name;
          init_counter := init_counter + 1;
        END LOOP;
        text_field_counter := text_field_counter + 1;
        v_text_field_Table(text_field_counter) :='SET '||v_lines_cursor.name||' '||v_op1;
        text_field_counter := text_field_counter + 1;
        v_text_field_Table(text_field_counter)  := ENDOFLINE1;

      ELSIF (v_lines_cursor.line_type = LOGIC_VERB_BOM) THEN

        text_field_counter := text_field_counter + 1;
        v_text_field_Table(text_field_counter) :='BOM '||v_lines_cursor.name||' ';

        IF  (v_lines_cursor.int_operand3 = 1 ) THEN
          text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter) :='R ';
        END IF;

        IF  (v_lines_cursor.operator = 10) THEN
          text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter) :='M NRC';
        ELSIF  (v_lines_cursor.operator = 11) THEN
          text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter) :='M RC';
        ELSIF  (v_lines_cursor.operator = 20) THEN
          text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter) :='O NRC';
        ELSIF  (v_lines_cursor.operator = 21) THEN
          text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter) :='O RC';
        ELSIF  (v_lines_cursor.operator = 30) THEN
          text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter) :='S NRC';
        ELSIF  (v_lines_cursor.operator = 31) THEN
          text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter) :='S RC';
        END IF;

        text_field_counter := text_field_counter + 1;
        v_text_field_Table(text_field_counter) := ' '||v_lines_cursor.int_operand1||' '||v_lines_cursor.int_operand2||' ';


        LOOP
          EXIT WHEN (init_counter >=counter);
          EXIT WHEN(( v_operandsTable(init_counter).lce_line_id > v_lines_cursor.lce_line_id )OR (init_counter =counter));
          text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter) := v_operandsTable(init_counter).name||' ';
          init_counter := init_counter + 1;
        END LOOP;

        text_field_counter := text_field_counter + 1;
        v_text_field_Table(text_field_counter)  := v_lines_cursor.fp_operand||' ';

        IF ( v_lines_cursor.intl_text_id IS NOT NULL ) THEN
          text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter):='... '||v_lines_cursor.intl_text_id;
        END IF;

        text_field_counter := text_field_counter + 1;
        v_text_field_Table(text_field_counter)  := ENDOFLINE1;

      ELSIF (v_lines_cursor.line_type = LOGIC_VERB_NOTTRUE) THEN

        LOOP
          EXIT WHEN (init_counter >=counter);
          EXIT WHEN( (v_operandsTable(init_counter).lce_line_id > v_lines_cursor.lce_line_id ) OR (init_counter =counter));
          v_op := v_operandsTable(init_counter).name;
          init_counter := init_counter + 1;
        END LOOP;

        text_field_counter := text_field_counter + 1;
        v_text_field_Table(text_field_counter) :='NOTTRUE '||v_lines_cursor.name||' '||v_op;
        IF ( v_lines_cursor.intl_text_id IS NOT NULL ) THEN
          text_field_counter := text_field_counter + 1;
          v_text_field_Table(text_field_counter):=' ... '||v_lines_cursor.intl_text_id;
        END IF;

        text_field_counter := text_field_counter + 1;
        v_text_field_Table(text_field_counter)  := ENDOFLINE1;

      END IF;

    END LOOP;

    text_field_counter := text_field_counter + 1;
            v_text_field_Table(text_field_counter):='REM -- End Component: '||to_char(v_header_cursor.component_id);
    text_field_counter := text_field_counter + 1;
        v_text_field_Table(text_field_counter):= ENDOFLINE1;

    DELETE FROM cz_lce_texts where lce_header_id = p_lce_header_id;
    BEGIN
      SELECT NVL(MAX(seq_nbr),0)
      INTO v_seq_no
      FROM cz_lce_texts
      WHERE lce_header_id = p_lce_header_id ;

    EXCEPTION
      WHEN OTHERS THEN
        v_seq_no:=0;
    END;

    v_buffer :='';
    FOR i  IN 1..text_field_counter LOOP
      v_buffer_length := NVL(LENGTH(v_buffer),0);
      IF ((v_buffer_length + NVL(LENGTH(v_text_field_Table(i)),0)) > 2000) THEN
        v_seq_no := v_seq_no +1;
        INSERT INTO  cz_lce_texts(LCE_HEADER_ID,SEQ_NBR,LCE_TEXT)
        values(p_lce_header_id, v_seq_no, v_buffer);
        v_buffer := v_text_field_Table(i);

                        IF BATCH_Counter>=BATCH_size THEN
                           Batch_Counter:=0;
                           COMMIT;
                        ELSE
                           Batch_Counter:=Batch_Counter+1;
                        END IF;

      ELSE
        v_buffer := v_buffer||v_text_field_Table(i);
      END IF;
    END LOOP;

    v_seq_no := v_seq_no +1;
    INSERT INTO  cz_lce_texts(LCE_HEADER_ID,SEQ_NBR,LCE_TEXT)
    values(p_lce_header_id, v_seq_no, v_buffer);
    COMMIT;
    CLOSE lines_cursor ;
  EXCEPTION
    WHEN OTHERS THEN
      cz_base_mgr.LOG_REPORT('CZ_LC_MGR.cz_generate_lce_varchar','ERROR : '||SQLERRM);

END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

END;

/
