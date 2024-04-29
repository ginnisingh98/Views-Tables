--------------------------------------------------------
--  DDL for Package Body JA_AU_CCID_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_AU_CCID_PKG" as
/* $Header: jaaupccb.pls 115.0 2003/01/08 23:35:36 thwon ship $ */


-- ** Declare global variables
l_error_msg             po_interface_errors.error_message%TYPE ;
l_error_flag            number;
l_index                 NATURAL;


-- ** Declare exceptions
l_incorrect_table       EXCEPTION;
l_null_segment          EXCEPTION;
l_invalid_segment       EXCEPTION;
l_no_rows_updated       EXCEPTION;
l_null_exp_acct         EXCEPTION;
l_update_failure        EXCEPTION;
l_no_data_found         EXCEPTION;


PROCEDURE JA_AU_AUTOACCOUNTING
          (x_org_id     	IN
           mtl_material_transactions.organization_id%TYPE,
           x_subinv     	IN
           mtl_material_transactions.subinventory_code%TYPE,
           x_item_id    	IN
           mtl_material_transactions.inventory_item_id%TYPE,
	   l_transaction_id    	IN
     	   po_requisitions_interface.transaction_id%TYPE)

IS

l_chart_of_accts_id     org_organization_definitions.organization_id%TYPE;
l_set_of_books_id       org_organization_definitions.set_of_books_id%TYPE;
l_subinv_ccid           mtl_secondary_inventories.expense_account%TYPE;
l_item_ccid             mtl_system_items.expense_account%TYPE;
l_table_name            JA_AU_ACCT_DEFAULT_SEGS.table_name%TYPE;
l_constant              JA_AU_ACCT_DEFAULT_SEGS.constant%TYPE;
l_segment               JA_AU_ACCT_DEFAULT_SEGS.segment%TYPE;
l_segvalues             fnd_flex_ext.segmentarray;
l_seglength             natural := 0;
l_segnumber             natural := 0;
l_ccid                  gl_code_combinations.code_combination_id%TYPE;
l_num_segs		number;
l_test_ccid             boolean;


CURSOR l_autoaccount_defns IS
SELECT nvl(upper(s.table_name), '!~') TABLE_NAME,
       nvl(s.constant, '!~') CONSTANT,
       s.segment
  FROM JA_AU_ACCT_DEFAULT_SEGS s, ja_au_account_defaults d
 WHERE s.gl_default_id = d.gl_default_id
   AND d.set_of_books_id = l_set_of_books_id
ORDER BY d.type,s.segment_num ;

BEGIN

     l_error_flag := 0;
     l_num_segs := 0;
     /* Initialise l_segvalues and l_ccid */
     FOR l_index IN 1..30 LOOP
            l_segvalues(l_index) := NULL;
     END LOOP;
     l_ccid := 0;
     l_chart_of_accts_id := 0;
     l_set_of_books_id := 0;
     l_subinv_ccid := 0;
     l_item_ccid := 0;


     /* Obtain chart_of_accounts_id and set_of_books from
        org_organization_definitions*/
    JA_AU_get_coa_sob( x_org_id,
                       l_chart_of_accts_id,
                       l_set_of_books_id);

      IF l_error_flag = -1 THEN
          GOTO end_processing;
     END IF;
     /* Get the subinventory and item expense accounts */
     JA_AU_get_repln_exp_accts(x_org_id,
                               x_subinv,
                               x_item_id,
                               l_subinv_ccid,
                               l_item_ccid);

     IF l_error_flag = -1 THEN
          GOTO end_processing;
     END IF;

     /* Fetch the AutoAccounting definitions a row at a time and retrieve
        the segment value from GL_CODE_COMBINATIONS for the specified
        segment */
     OPEN l_autoaccount_defns;

     LOOP
          FETCH l_autoaccount_defns
           INTO l_table_name,
                l_constant,
                l_segment ;


          EXIT WHEN l_autoaccount_defns%NOTFOUND;

          l_num_segs := l_num_segs + 1;

          l_seglength := LENGTH(l_segment);
          l_segnumber := TO_NUMBER(SUBSTR(l_segment,8,l_seglength-7));

          l_segvalues(l_segnumber) := JA_AU_get_segment_value(l_table_name,
                                                             l_constant,
                                                             l_segment,
                                                             l_subinv_ccid,
                                                             l_item_ccid);

          IF l_error_flag = -1 THEN
               GOTO end_processing;
          END IF;

     END LOOP;

     CLOSE l_autoaccount_defns;

     l_test_ccid := fnd_flex_ext.get_combination_id('SQLGL',
                                                    'GL#',
                                                    l_chart_of_accts_id,
                                                    sysdate,
                                                    l_num_segs,
                                                    l_segvalues,
                                                    l_ccid);

     IF (l_test_ccid) THEN
	 NULL;
     ELSE
	 l_error_msg := 'AUTOGL ERROR - Could not obtain or create CODE_COMBINATION_ID.';
	 goto end_processing;
     END IF;

     JA_AU_update_mtltrxacct( l_transaction_id,
                              l_ccid );
<<end_processing>>
     commit;

EXCEPTION
  WHEN OTHERS THEN
    null;
END JA_AU_AUTOACCOUNTING ;


-- *
-- ** Create JA_AU_GET_COA_SOB procedure
-- *

PROCEDURE JA_AU_GET_COA_SOB
          (x_org_id             IN
           org_organization_definitions.organization_id%TYPE,
           x_chart_of_accts_id  OUT
           org_organization_definitions.chart_of_accounts_id%TYPE,
           x_set_of_books_id    OUT
           org_organization_definitions.set_of_books_id%TYPE)
IS
BEGIN

     SELECT chart_of_accounts_id, set_of_books_id
     INTO x_chart_of_accts_id, x_set_of_books_id
     FROM org_organization_definitions
     WHERE organization_id = x_org_id
     AND nvl(disable_date, sysdate+1) > sysdate ;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
          l_error_msg := 'AUTOGL ERROR - Could not retrieve chart_of_accounts_id and/or set_of_books_id.';
          l_error_flag := -1;
     WHEN OTHERS THEN
          l_error_flag := -1;

END JA_AU_GET_COA_SOB;


-- *
-- ** Create JA_AU_GET_REPLN_EXP_ACCTS procedure
-- *

PROCEDURE JA_AU_GET_REPLN_EXP_ACCTS
          (x_org_id             IN
           org_organization_definitions.organization_id%TYPE,
           x_subinv             IN
           mtl_secondary_inventories.secondary_inventory_name%TYPE,
           x_item_id            IN
           mtl_system_items.inventory_item_id%TYPE,
           x_subinv_ccid        IN OUT
           mtl_secondary_inventories.expense_account%TYPE,
           x_item_ccid          IN OUT
           mtl_system_items.expense_account%TYPE)
IS
BEGIN

     l_error_msg := 'AUTOGL ERROR - Could not retrieve subinventory expense_account';

     SELECT nvl(expense_account, -1)
     INTO x_subinv_ccid
     FROM mtl_secondary_inventories
     WHERE organization_id = x_org_id
     AND secondary_inventory_name = x_subinv ;

     IF x_subinv_ccid = -1 THEN
          l_error_msg := 'AUTOGL ERROR - Subinventory expense_account was NULL';
          RAISE l_null_exp_acct;
     END IF;

     l_error_msg := 'AUTOGL ERROR - Could not retrieve item expense_account';

     SELECT nvl(expense_account, -1)
     INTO x_item_ccid
     FROM mtl_system_items
     WHERE organization_id = x_org_id
     AND inventory_item_id = x_item_id ;

     IF x_item_ccid = -1 THEN
          l_error_msg := 'AUTOGL ERROR - Item expense_account was NULL';
          RAISE l_null_exp_acct;
     END IF;

     l_error_msg := null;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
          l_error_flag := -1;
     WHEN l_null_exp_acct THEN
          l_error_flag := -1;
     WHEN OTHERS THEN
          l_error_flag := -1;

END JA_AU_GET_REPLN_EXP_ACCTS;


-- *
-- ** Create JA_AU_GET_SEGMENT_VALUE function
-- *

FUNCTION JA_AU_GET_SEGMENT_VALUE
         (
          x_table_name          IN
          JA_AU_ACCT_DEFAULT_SEGS.table_name%TYPE,
          x_constant            IN
          JA_AU_ACCT_DEFAULT_SEGS.constant%TYPE,
          x_segment             IN
          JA_AU_ACCT_DEFAULT_SEGS.segment%TYPE,
          x_subinv_ccid         IN
          mtl_secondary_inventories.expense_account%TYPE,
          x_item_ccid           IN
          mtl_system_items.expense_account%TYPE)
RETURN gl_code_combinations.segment1%TYPE IS

l_value         gl_code_combinations.segment1%TYPE;

BEGIN

     IF SUBSTR(x_constant,1,2) = '!~' THEN /* Not a constant */
          IF x_table_name = 'MTL_SECONDARY_INVENTORIES' THEN
               l_value := JA_AU_get_value(x_subinv_ccid,
                                         x_segment);
          ELSIF x_table_name = 'MTL_SYSTEM_ITEMS' THEN
               l_value := JA_AU_get_value(x_item_ccid,
                                         x_segment);
          ELSE
               l_value := '0';
               RAISE l_incorrect_table;
          END IF;
     ELSE
           l_value := RTRIM(SUBSTR(x_constant,1,25));
     END IF;

     return(l_value);

EXCEPTION
     WHEN l_incorrect_table THEN
          l_error_msg := 'AUTOGL ERROR - Incorrect AutoAccounting setup - Invalid Table.';
          l_error_flag := -1;
          return(l_value);
     WHEN OTHERS THEN
          l_error_flag := -1;
          return(l_value);

END JA_AU_GET_SEGMENT_VALUE;


-- *
-- ** Create JA_AU_GET_VALUE function
-- *

FUNCTION JA_AU_GET_VALUE
         (x_ccid                IN
          gl_code_combinations.code_combination_id%TYPE,
          x_segment     IN
          gl_code_combinations.segment1%TYPE)
RETURN gl_code_combinations.segment1%TYPE IS

l_value         gl_code_combinations.segment1%TYPE;

BEGIN

     IF SUBSTR(x_segment,1,9) = 'SEGMENT30' THEN
          SELECT nvl(segment30,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,9) = 'SEGMENT29' THEN
          SELECT nvl(segment29,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,9) = 'SEGMENT28' THEN
          SELECT nvl(segment28,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,9) = 'SEGMENT27' THEN
          SELECT nvl(segment27,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,9) = 'SEGMENT26' THEN
          SELECT nvl(segment26,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,9) = 'SEGMENT25' THEN
          SELECT nvl(segment25,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,9) = 'SEGMENT24' THEN
          SELECT nvl(segment24,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,9) = 'SEGMENT23' THEN
          SELECT nvl(segment23,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,9) = 'SEGMENT22' THEN
          SELECT nvl(segment22,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,9) = 'SEGMENT21' THEN
          SELECT nvl(segment21,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,9) = 'SEGMENT20' THEN
          SELECT nvl(segment20,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,9) = 'SEGMENT19' THEN
          SELECT nvl(segment19,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,9) = 'SEGMENT18' THEN
          SELECT nvl(segment18,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,9) = 'SEGMENT17' THEN
          SELECT nvl(segment17,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,9) = 'SEGMENT16' THEN
          SELECT nvl(segment16,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,9) = 'SEGMENT15' THEN
          SELECT nvl(segment15,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,9) = 'SEGMENT14' THEN
          SELECT nvl(segment14,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,9) = 'SEGMENT13' THEN
          SELECT nvl(segment13,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,9) = 'SEGMENT12' THEN
          SELECT nvl(segment12,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,9) = 'SEGMENT11' THEN
          SELECT nvl(segment11,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,9) = 'SEGMENT10' THEN
          SELECT nvl(segment10,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,8) = 'SEGMENT9' THEN
          SELECT nvl(segment9,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,8) = 'SEGMENT8' THEN
          SELECT nvl(segment8,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,8) = 'SEGMENT7' THEN
          SELECT nvl(segment7,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,8) = 'SEGMENT6' THEN
          SELECT nvl(segment6,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,8) = 'SEGMENT5' THEN
          SELECT nvl(segment5,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,8) = 'SEGMENT4' THEN
          SELECT nvl(segment4,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,8) = 'SEGMENT3' THEN
          SELECT nvl(segment3,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,8) = 'SEGMENT2' THEN
          SELECT nvl(segment2,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSIF SUBSTR(x_segment,1,8) = 'SEGMENT1' THEN
          SELECT nvl(segment1,'!@')
            INTO l_value
            FROM gl_code_combinations
           WHERE code_combination_id = x_ccid ;
     ELSE
          RAISE l_invalid_segment;
     END IF;

     IF l_value = '!@' THEN
          RAISE l_null_segment;
     END IF;

     return(l_value);

EXCEPTION
     WHEN l_invalid_segment THEN
          l_error_msg := 'AUTOGL ERROR - Incorrect AutoAccounting setup - Invalid Segment';
     WHEN l_null_segment THEN
          l_error_msg := 'AUTOGL ERROR - Segment value in GL_CODE_COMBINATIONS is null';
     WHEN NO_DATA_FOUND THEN
          l_error_msg := 'AUTOGL ERROR - Could not retrieve segment value from GL_CODE_COMBINATIONS.';
     WHEN OTHERS THEN
          null;

END JA_AU_GET_VALUE;


PROCEDURE JA_AU_UPDATE_MTLTRXACCT
          (x_transaction_id     IN
           mtl_transaction_accounts.transaction_id%TYPE,
           x_ccid       IN
           gl_code_combinations.code_combination_id%TYPE)
IS
BEGIN

     UPDATE mtl_transaction_accounts
        SET reference_account = x_ccid
      WHERE transaction_id = x_transaction_id
        AND accounting_line_type = 2;

     IF SQL%NOTFOUND THEN
          RAISE l_no_rows_updated;
     END IF;

     COMMIT WORK;

EXCEPTION
     WHEN l_no_rows_updated THEN
          l_error_msg := 'AUTOGL ERROR - Update of charge_account_id in po_requisitions_interface
failed.';
     WHEN OTHERS THEN
          null;
END JA_AU_UPDATE_MTLTRXACCT;


END JA_AU_CCID_PKG;

/
