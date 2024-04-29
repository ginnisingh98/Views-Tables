--------------------------------------------------------
--  DDL for Package Body FV_COPY_YE_RECORDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_COPY_YE_RECORDS_PKG" AS
/* $Header: FVYECPGB.pls 120.6.12010000.2 2009/12/23 10:19:08 amaddula ship $ |*/
	g_module_name VARCHAR2(100) := 'fv.plsql.fv_copy_ye_records_pkg.';

PROCEDURE copy_record
(v_ledger_id           IN gl_ledgers.ledger_id%TYPE,
 v_old_group_id        IN fv_ye_groups.group_id%TYPE,
 v_time_frame_new      IN fv_treasury_symbols.time_frame%TYPE,--modified for Bug.1575992
 v_fund_group_code_new IN VARCHAR2,
 v_treasury_symbol_new IN fv_treasury_symbols.treasury_symbol%TYPE,
 v_closing_method IN fv_ye_groups.closing_method%TYPE)--modified for Bug.1575992
AS

 CURSOR c_sequences
     IS
 SELECT *
   FROM fv_ye_group_sequences
  WHERE group_id = v_old_group_id
  ORDER BY SEQUENCE;

CURSOR c_accounts(cv_sequence_id NUMBER)
     IS
 SELECT *
   FROM fv_ye_sequence_accounts
  WHERE sequence_id = cv_sequence_id
  ORDER BY order_by_ctr;
 l_module_name         VARCHAR2(200) :=  g_module_name || 'copy_record';
 l_errbuff             VARCHAR2(300);
 v_login NUMBER;
 v_set_of_books_id NUMBER;
 v_new_group_id fv_ye_groups.group_id%TYPE;
 v_sequence_id fv_ye_group_sequences.sequence_id%TYPE;
--pkpatel:Declared a new variable to fix Bug. 1575992
	v_treasury_symbol_id  fv_treasury_symbols.treasury_symbol_id%TYPE;

BEGIN

 v_login := fnd_global.user_id;

 SELECT fv_ye_groups_id_s.NEXTVAL
   INTO v_new_group_id
   FROM dual;
--pkpatel:Added code to fix Bug.1575992

--Bug 2374153: Add If to check if new_treasury_symbol is null
IF v_treasury_symbol_new  IS NOT NULL THEN

    SELECT  treasury_symbol_id
	INTO    v_treasury_symbol_id
	FROM    fv_treasury_symbols
	WHERE   treasury_symbol = v_treasury_symbol_new
	AND	set_of_books_id = v_ledger_id;
END IF;

 IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                         'INSERTING TO FV_YE_GROUPS');
 END IF;
 -- create fv_ye_groups record for new record.
 INSERT INTO fv_ye_groups
 (group_id,
  set_of_books_id,
  fund_time_frame,
  fund_group_code,
  last_update_date,
  last_updated_by,
  last_update_login,
  creation_date,
  created_by,
  treasury_symbol_id,
  closing_method)
 VALUES
 (v_new_group_id,
  v_ledger_id,
  v_time_frame_new,
  v_fund_group_code_new,
  TRUNC(SYSDATE),
  v_login,
  v_login,
  TRUNC(SYSDATE),
  v_login,
  v_treasury_symbol_id,
  v_closing_method);

 -- create sequences for group_id processing.
 FOR c_sequences_rec IN c_sequences LOOP

   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                     'SEQUENCE = '||C_SEQUENCES_REC.SEQUENCE);
   END IF;
   SELECT fv_ye_group_sequences_s.NEXTVAL
     INTO v_sequence_id
     FROM dual;

   INSERT INTO fv_ye_group_sequences
   (sequence_id,
    group_id,
    SEQUENCE,
    set_of_books_id,
    last_update_date,
    last_updated_by,
    last_update_login,
    creation_date,
    created_by)
   VALUES
   (v_sequence_id,
    v_new_group_id,
    c_sequences_rec.SEQUENCE,
    v_ledger_id,
    TRUNC(SYSDATE),
    v_login,
    v_login,
    TRUNC(SYSDATE),
    v_login);

   -- create account records for the sequence processing.
   FOR c_accounts_rec IN c_accounts(c_sequences_rec.sequence_id) LOOP

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                'ACCT_ID ='||C_ACCOUNTS_REC.SEQUENCE_ACCT_ID);
    END IF;
    INSERT INTO fv_ye_sequence_accounts
    (sequence_id,
     sequence_acct_id,
     account_flag,
     from_account,
     to_account,
     order_by_ctr,
     set_of_books_id,
     last_update_date,
     last_updated_by,
     last_update_login,
     creation_date,
     created_by,
     requisition)
    VALUES
    (v_sequence_id,
     fv_ye_sequence_acct_s.NEXTVAL,
     c_accounts_rec.account_flag,
     c_accounts_rec.from_account,
     c_accounts_rec.to_account,
     c_accounts_rec.order_by_ctr,
     v_ledger_id,
     TRUNC(SYSDATE),
     v_login,
     v_login,
     TRUNC(SYSDATE),
     v_login,
     c_accounts_rec.requisition);

   END LOOP;
END LOOP;
COMMIT;
EXCEPTION
WHEN OTHERS THEN
  l_errbuff := SQLERRM;
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,l_errbuff);
END copy_record;
END fv_copy_ye_records_pkg;


/
