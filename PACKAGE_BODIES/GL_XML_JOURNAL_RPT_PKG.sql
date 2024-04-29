--------------------------------------------------------
--  DDL for Package Body GL_XML_JOURNAL_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_XML_JOURNAL_RPT_PKG" AS
/* $Header: glumlrxb.pls 120.4 2006/06/28 17:31:34 spala noship $ */

 PROCEDURE START_PERIOD_DATE_NAME(X_START_DATE DATE,
                                  X_LEDGER_ID  NUMBER,
                                  X_PERIOD_START_DATE OUT NOCOPY DATE,
                                  X_START_PERIOD_NAME OUT NOCOPY VARCHAR2) IS

  start_period_date   DATE;
  l_period_name       VARCHAR2(100);
BEGIN

    SELECT start_date, period_name
    INTO start_period_date,l_period_name
    FROM   gl_period_statuses gps
    WHERE  gps.application_id = 101
    AND    gps.ledger_id = x_ledger_id
    AND    x_start_date between gps.START_DATE and gps.END_DATE
    AND    gps.adjustment_period_flag <> 'Y';


    X_PERIOD_START_DATE := START_PERIOD_DATE;
    X_START_PERIOD_NAME := l_period_name;

  -- Add exception block to avoid error when user enters
  -- start date which does not exists in gl_period_statuses.
  -- See bug #259063.

  EXCEPTION
  WHEN NO_DATA_FOUND THEN

    SELECT  p1.start_date, p1.period_name
    INTO    start_period_date, l_period_name
    FROM    gl_period_statuses p1
    WHERE   p1.application_id = 101
    AND     p1.ledger_id = x_ledger_id
    AND     p1.adjustment_period_flag <> 'Y'
    AND     p1.start_date =
   (SELECT  MIN(p2.start_date)
    FROM    gl_period_statuses p2
    WHERE   p2.application_id = 101
    AND     p2.ledger_id = x_ledger_id
    AND     p2.adjustment_period_flag <> 'Y');


    X_PERIOD_START_DATE := START_PERIOD_DATE;
    X_START_PERIOD_NAME := l_period_name;


   WHEN OTHERS THEN
      X_PERIOD_START_DATE := NULL;
      X_START_PERIOD_NAME := NULL;
 END START_PERIOD_DATE_NAME;

Function Net_Line_Balance (P_ACCT_SEG_WHERE  VARCHAR2,
                       P_STATUS    VARCHAR2,
                       P_START_DATE      DATE,
                       P_CURRENCY  VARCHAR2,
                       P_LED_ID    NUMBER,
                       P_BAL_SEG_NAME   VARCHAR2,
                       P_BAL_SEG_VAL    VARCHAR2,
                       P_ACCT_SEG_NAME  VARCHAR2,
                       P_ACCT_SEG_VAL   VARCHAR2,
                       P_SEC_SEG_NAME   VARCHAR2,
                       P_SEC_SEG_VAL    VARCHAR2) RETURN NUMBER IS

   l_Sql_Stmt         VARCHAR2(4000);
   l_sql_stmt1        VARCHAR2(100);
   Net_Line_Balance   NUMBER;
   l_start_prd_date   DATE;
   l_start_prd_name   VARCHAR2(100);
   l_status           VARCHAR2(10);
   l_stmt2            VARCHAR2(100);

BEGIN

          START_PERIOD_DATE_NAME(X_START_DATE => P_START_DATE,
                                  X_LEDGER_ID  => P_LED_ID,
                                  X_PERIOD_START_DATE => l_start_prd_date,
                                  X_START_PERIOD_NAME => l_start_prd_name);

   IF (P_CURRENCY = 'STAT') THEN
     l_sql_stmt1 := ' AND hed.currency_code = ''STAT'' ';
   ELSE
     l_sql_stmt1 := ' AND hed.currency_code <> ''STAT'' ';
   END IF;

    IF P_STATUS IS NULL THEN
      l_status := 'A';
    ELSE
      l_status := P_STATUS;
    END IF;
    IF (P_SEC_SEG_NAME IS NOT NULL) AND
         (P_SEC_SEG_VAL IS NOT NULL)THEN
      l_stmt2 := ' AND '||P_SEC_SEG_NAME||' = '''||P_SEC_SEG_VAL||'''';
    END IF;


    l_Sql_Stmt := ' SELECT
     (SUM(nvl(accounted_dr, 0)) - SUM(nvl(accounted_cr, 0)))
    FROM
     GL_JE_HEADERS HED,
     GL_JE_LINES LINE,
     GL_CODE_COMBINATIONS CC
   WHERE  '''||l_STATUS||''' =  ''P'''||
   P_ACCT_SEG_WHERE||
   ' AND  CC.code_combination_id = line.code_combination_id
   AND  HED.je_header_id = line.je_header_id
   AND  trunc(line.effective_date) >= :START_PRD_DATE
   AND  trunc(line.effective_date) <  :START_DATE
   AND  hed.period_name = :period_name '||
   ' AND  hed.actual_flag = ''A'''||
   l_sql_stmt1||
   ' AND  hed.ledger_id = :LED_ID
   AND  '||p_bal_seg_name|| '  =  :bal_Seg_Val
   AND   '|| p_acct_seg_name||'  = :acct_seg_val '||l_stmt2||
  ' AND LINE.STATUS = ''P''';


   EXECUTE IMMEDIATE l_sql_stmt INTO NET_LINE_BALANCE Using
        l_start_prd_date, P_START_DATE,
        l_start_prd_name,P_LED_ID, P_BAL_SEG_VAL,
        P_ACCT_Seg_Val;


   Return NVL(Net_Line_Balance,'');

  EXCEPTION

    WHEN NO_DATA_FOUND Then
        Return NULL;

 END Net_Line_Balance;


Function Net_Begin_Balance (P_ACCT_SEG_WHERE  VARCHAR2,
                       P_STATUS    VARCHAR2,
                       P_START_DATE  DATE,
                       P_CURRENCY  VARCHAR2,
                       P_LED_ID    NUMBER,
                       P_BAL_SEG_NAME   VARCHAR2,
                       P_BAL_SEG_VAL    VARCHAR2,
                       P_ACCT_SEG_NAME  VARCHAR2,
                       P_ACCT_SEG_VAL   VARCHAR2,
                       P_SEC_SEG_NAME   VARCHAR2,
                       P_SEC_SEG_VAL    VARCHAR2) RETURN NUMBER IS

   l_stmt              VARCHAR2(4000);
   NET_BEG_BALANCE     NUMBER;
   l_prd_start_date    DATE;
   l_prd_start_name    VARCHAR2(100);
   l_stmt1             VARCHAR2(100);
   l_status            VARCHAR2(10);

 BEGIN

            START_PERIOD_DATE_NAME(X_START_DATE => P_START_DATE,
                                  X_LEDGER_ID  => P_LED_ID,
                                  X_PERIOD_START_DATE => l_prd_start_date,
                                  X_START_PERIOD_NAME => l_prd_start_name);


    IF (P_SEC_SEG_NAME IS NOT NULL) AND
         (P_SEC_SEG_VAL IS NOT NULL) THEN
      l_stmt1 := ' AND '||P_SEC_SEG_NAME||' = '''||P_SEC_SEG_VAL||'''';
    END IF;

    IF P_STATUS IS NULL THEN
      l_status := 'A';
    ELSE
      l_status := P_STATUS;
    END IF;

    l_stmt := 'SELECT
      (SUM(decode(cc.summary_flag, ''N'', nvl(gb.begin_balance_dr, 0), 0)) -
        SUM(decode(cc.summary_flag, ''N'', nvl(gb.begin_balance_cr, 0),0)))
      FROM   GL_CODE_COMBINATIONS CC,
             GL_BALANCES GB
      WHERE  '''||l_status ||''' = ''P''
      AND    CC.code_combination_id = GB.code_combination_id '
      ||P_ACCT_SEG_WHERE ||
      ' AND    GB.currency_code = '''||P_CURRENCY||'''
       AND    GB.ledger_id = :LGR_ID '
      ||l_stmt1||
      ' AND    GB.actual_flag = ''A''
      AND    GB.period_name = '''||l_prd_start_name||'''
      AND    '||P_BAL_SEG_NAME ||' = '''||P_Bal_Seg_Val||'''
      AND    '||P_ACCT_SEG_NAME || ' = '''||P_ACCT_SEG_VAL||'''';


    EXECUTE IMMEDIATE l_stmt INTO NET_BEG_BALANCE USING P_LED_ID;


  Return Net_Beg_Balance;

  EXCEPTION

    WHEN NO_DATA_FOUND Then

        Return NULL;

 End Net_Begin_Balance;



FUNCTION Get_Contra_Account(P_Account_Select VARCHAR2,
                            p_Header_id   NUMBER,
                            P_Sub_Doc_Seq_Id NUMBER,
                            P_Sub_Doc_SEq_Val VARCHAR2,
                            p_Accounted_Dr NUMBER,
                            P_Accounted_Cr NUMBER) RETURN VARCHAR2 IS

    contra_account_name        varchar2(240);
    CONTRA_ACCT_SEGMENT        varchar2(2000);
    TYPE C_SQL_Cur_Type IS REF CURSOR;
    c_sql_cur	C_SQL_Cur_Type;
    l_type VARCHAR2(25);
   v_sql_stmt VARCHAR2(2000);
 TYPE CONTRA_ACCOUNT_NAME_TBL IS TABLE OF VARCHAR2(25) INDEX BY BINARY_INTEGER;
 t_contra_account_name_tbl  CONTRA_ACCOUNT_NAME_TBL;

BEGIN
    CONTRA_ACCT_SEGMENT := 'G'||P_Account_select;
IF nvl(p_accounted_dr,0) <> 0 and nvl(p_accounted_cr,0) <> 0 THEN

    var.prev_type := 'BOTH';
    var.header_id_prev := p_header_id;
    var.sub_doc_sequence_id_prev := p_sub_doc_seq_id;
    var.sub_doc_sequence_value_prev := p_sub_doc_seq_val;

    RETURN(null);

   ELSIF (P_ACCOUNTED_DR IS NOT NULL and P_ACCOUNTED_DR <> 0) then

   v_sql_stmt := 'select distinct '||
     contra_acct_segment ||
     ' from gl_je_lines gjl, gl_code_combinations gcc  ' ||
     'where gjl.je_header_id = :header_id and '||
     'gjl.accounted_cr IS NOT NULL and gjl.accounted_cr <> 0 and ' ||
     'gjl.code_combination_id = gcc.code_combination_id and '||
     '((gjl.subledger_doc_sequence_id = :sub_doc_sequence_id and '||
     'gjl.subledger_doc_sequence_value = :sub_doc_sequence_value) or '||
     '(:sub_doc_sequence_id is null and gjl.subledger_doc_sequence_id is null and '||
     'gjl.subledger_doc_sequence_value is null))';
     l_type :='DR';

ELSIF p_accounted_cr IS NOT NULL and p_accounted_cr <> 0 THEN
   v_sql_stmt := 'select distinct ' ||
     contra_acct_segment ||
     ' from gl_je_lines gjl, gl_code_combinations gcc  '||
     'where gjl.je_header_id = :header_id and '||
     'gjl.accounted_dr IS NOT NULL and gjl.accounted_dr <> 0 and ' ||
     'gjl.code_combination_id = gcc.code_combination_id and '||
     '((gjl.subledger_doc_sequence_id = :sub_doc_sequence_id and '||
     'gjl.subledger_doc_sequence_value = :sub_doc_sequence_value) or '||
     '(:sub_doc_sequence_id is null and gjl.subledger_doc_sequence_id is null and '||
     'gjl.subledger_doc_sequence_value is null))';
     l_type :='CR';
    END IF;




  IF l_type = var.prev_type
    AND p_header_id = var.header_id_prev
    AND NVL(p_sub_doc_seq_id, -1) = NVL(var.sub_doc_sequence_id_prev, -1)
    AND NVL(p_sub_doc_seq_val, -1)
           = NVL(var.sub_doc_sequence_value_prev, -1) THEN
    return (var.contra_account_name_prev);
  END IF;

 var.prev_type := l_type;
  var.header_id_prev := p_header_id;
 var.sub_doc_sequence_id_prev := p_sub_doc_seq_id;
 var.sub_doc_sequence_value_prev := p_sub_doc_seq_val;

  open c_sql_cur for v_sql_stmt using p_header_id,
                                      p_sub_doc_seq_id ,
                                      p_sub_doc_seq_val ,
                                      p_sub_doc_seq_id ;
  fetch c_sql_cur bulk collect into t_contra_account_name_tbl;
  IF c_sql_cur%rowcount = 0 then

     RAISE NO_DATA_FOUND;

  END IF;

  IF c_sql_cur%rowcount >= 2 then
     RAISE TOO_MANY_ROWS;
  ELSE
     contra_account_name := t_contra_account_name_tbl(1);
  END IF;

  CLOSE c_sql_cur;

  RETURN(contra_account_name);

EXCEPTION
   WHEN TOO_MANY_ROWS THEN

      close c_sql_cur;
      var.contra_account_name_prev := 'MULTIPLE';
      RETURN ('MULTIPLE');

   WHEN NO_DATA_FOUND THEN

      close c_sql_cur;
      var.contra_account_name_prev := 'NO CONTRA ACCOUNT';
      RETURN ('NO CONTRA ACCOUNT');

   WHEN OTHERS THEN

      close c_sql_cur;
      return(sqlcode||sqlerrm);










End  Get_Contra_Account;

END GL_XML_JOURNAL_RPT_PKG;

/
