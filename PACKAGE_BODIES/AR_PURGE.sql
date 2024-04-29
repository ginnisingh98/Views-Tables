--------------------------------------------------------
--  DDL for Package Body AR_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_PURGE" AS
/* $Header: ARPURGEB.pls 120.32.12010000.3 2008/12/31 03:59:06 rviriyal ship $ */

    TYPE unpurgeable IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
    -- bug1199027
    TYPE control_detail_rec IS RECORD
    (
        period_name                   VARCHAR2(15),
        invoices_cnt                  NUMBER,
        credit_memos_cnt              NUMBER,
        debit_memos_cnt               NUMBER,
        chargebacks_cnt               NUMBER,
        deposits_cnt                  NUMBER,
        adjustments_cnt               NUMBER,
        cash_receipts_cnt             NUMBER,
        invoices_no_rec_cnt           NUMBER,
        credit_memos_no_rec_cnt       NUMBER,
        debit_memos_no_rec_cnt        NUMBER,
        chargebacks_no_rec_cnt        NUMBER,
        deposits_no_rec_cnt           NUMBER,
        guarantees_cnt                NUMBER,
        misc_receipts_cnt             NUMBER,
        invoices_total                NUMBER,
        credit_memos_total            NUMBER,
        debit_memos_total             NUMBER,
        chargebacks_total             NUMBER,
        deposits_total                NUMBER,
        adjustments_total             NUMBER,
        cash_receipts_total           NUMBER,
        discounts_total               NUMBER,
        exchange_gain_loss_total      NUMBER,
        invoices_no_rec_total         NUMBER,
        credit_memos_no_rec_total     NUMBER,
        debit_memos_no_rec_total      NUMBER,
        chargebacks_no_rec_total      NUMBER,
        deposits_no_rec_total         NUMBER,
        guarantees_total              NUMBER,
        misc_receipts_total           NUMBER
    ) ;
    TYPE control_detail_array IS TABLE OF control_detail_rec INDEX BY BINARY_INTEGER ;

    l_unpurgeable_txns         unpurgeable;
    l_unpurgeable_receipts     unpurgeable;
    l_control_detail_array     control_detail_array ; --bug1199027

    /* bug3975105 added */
    l_text varchar2(2000);
    l_short_flag varchar2(1);

    /* bug3975105 added p_flag */
    PROCEDURE print( p_indent IN NUMBER, p_text IN VARCHAR2, p_flag IN VARCHAR2 DEFAULT NULL ) IS
    BEGIN

       /* Only unpurged log */
       IF l_short_flag = 'Y' then

          /* if p_text has trx/rec info */
          IF p_flag = 'Y' then
             l_text := p_text ;

          /* if purge was done Successfully */
          ELSIF p_flag = 'S' then
             l_text := null;

          /* if p_text has process info */
          ELSIF p_flag = 'N' then
             null;

          /* if p_text has error info */
          ELSIF p_flag is null then

             IF l_text is not null then
                fnd_file.put_line( FND_FILE.LOG, l_text );
                l_text := null;
             END IF;

             fnd_file.put_line( FND_FILE.LOG, p_text );
          END IF;

       /* All log */
       ELSE

          fnd_file.put_line( FND_FILE.LOG, RPAD(' ', p_indent*2)||p_text );
       END IF;

    END;
    --
    -- add the given customer_trx_id to the list of unpurgeable transactions
    --
    PROCEDURE add_to_unpurgeable_txns( p_customer_trx_id IN NUMBER ) IS
    BEGIN
        l_unpurgeable_txns( p_customer_trx_id ) := 'Y';
    END;
    --
    -- returns TRUE if this transaction is in the unpurgeable transaction list
    --     FALSE if it is not
    --
    FUNCTION in_unpurgeable_txn_list( p_customer_trx_id IN NUMBER ) RETURN BOOLEAN IS
    BEGIN
        IF p_customer_trx_id is not null and l_unpurgeable_txns( p_customer_trx_id ) = 'Y'
        THEN
            RETURN TRUE;
        END IF;

        RETURN FALSE;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN FALSE;
        WHEN OTHERS THEN
            print( 0, 'Failed while checking the unpurgeable_trxn list') ;
            print( 0, 'sqlcode = ' || SQLCODE || SQLERRM ) ;
            RAISE;
    END;
    -- bug 1715258
    --
    -- add the given cash_receipt_id to the list of unpurgeable receipts
    --
    PROCEDURE add_to_unpurgeable_receipts( p_cash_receipt_id IN NUMBER ) IS
    BEGIN
        l_unpurgeable_receipts( p_cash_receipt_id ) := 'Y';
    END;
    -- bug 1715258
    --
    -- returns TRUE if this receipts is in the unpurgeable receipts list
    --     FALSE if it is not
    --
    FUNCTION in_unpurgeable_receipt_list( p_cash_receipt_id IN NUMBER ) RETURN BOOLEAN IS
    BEGIN
        IF l_unpurgeable_receipts( p_cash_receipt_id ) = 'Y'
        THEN
            RETURN TRUE;
        END IF;

        RETURN FALSE;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN FALSE;
        WHEN OTHERS THEN
            print( 0, 'Failed while checking the unpurgeable_receipt list') ;
            print( 0, 'sqlcode = ' || SQLCODE || SQLERRM ) ;
            RAISE;
    END;

    --
    -- get_period_name
    --
    FUNCTION get_period_name ( p_gl_date  IN DATE ) RETURN VARCHAR2  IS
        l_period_name VARCHAR2(15) ;
    BEGIN

         SELECT period_name
         INTO   l_period_name
         FROM   gl_period_statuses
         WHERE  application_id = 222
         AND    set_of_books_id = arp_standard.sysparm.set_of_books_id
         AND    p_gl_date >= start_date
         AND    p_gl_date <= end_date
         AND    adjustment_period_flag = 'N' ;
         -- there could be 2 records with enabled_flag = 'Y' and 'N'

         RETURN ( l_period_name ) ;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN ('-9999') ;
        WHEN OTHERS THEN
            print( 1, '  ...Failed while getting the period name ');
            print( 1, 'sqlcode = ' || SQLCODE || SQLERRM ) ;
            RAISE ;

    END ;
    --
    -- bug1199027
    FUNCTION ins_control_detail_table ( p_amount IN NUMBER,
                                        p_type IN VARCHAR2,
                                        p_open_rec IN VARCHAR2,
                                        p_period_name IN VARCHAR2,
                                        p_archive_id  IN NUMBER ) RETURN BOOLEAN IS
       l_last_index            NUMBER ;
       l_control_detail_index  NUMBER := 0 ;
       I NUMBER ;
    BEGIN

       l_last_index := l_control_detail_array.last ;

       IF l_last_index IS NOT NULL
       THEN
            FOR I in 1..l_last_index
            LOOP
                IF l_control_detail_array(I).period_name = p_period_name
                THEN
                    IF p_type = 'INV'
                    THEN
                        IF p_open_rec = 'Y'
                        THEN
                           l_control_detail_array(I).invoices_cnt :=
                                l_control_detail_array(I).invoices_cnt + 1 ;
                           l_control_detail_array(I).invoices_total :=
                                l_control_detail_array(I).invoices_total + p_amount ;
                        ELSE
                           l_control_detail_array(I).invoices_no_rec_cnt :=
                                l_control_detail_array(I).invoices_no_rec_cnt + 1 ;
                           l_control_detail_array(I).invoices_no_rec_total :=
                                l_control_detail_array(I).invoices_no_rec_total + p_amount ;
                        END IF ;
                    ELSIF p_type = 'CM'
                    THEN
                        IF p_open_rec = 'Y'
                        THEN
                           l_control_detail_array(I).credit_memos_cnt :=
                                l_control_detail_array(I).credit_memos_cnt + 1 ;
                           l_control_detail_array(I).credit_memos_total :=
                                l_control_detail_array(I).credit_memos_total + p_amount ;
                        ELSE
                           l_control_detail_array(I).credit_memos_no_rec_cnt :=
                                l_control_detail_array(I).credit_memos_no_rec_cnt + 1 ;
                           l_control_detail_array(I).credit_memos_no_rec_total :=
                                l_control_detail_array(I).credit_memos_no_rec_total + p_amount ;
                        END IF ;
                    ELSIF p_type = 'DM'
                    THEN
                        IF p_open_rec = 'Y'
                        THEN
                           l_control_detail_array(I).debit_memos_cnt :=
                                l_control_detail_array(I).debit_memos_cnt + 1 ;
                           l_control_detail_array(I).debit_memos_total :=
                                l_control_detail_array(I).debit_memos_total + p_amount ;
                        ELSE
                           l_control_detail_array(I).debit_memos_no_rec_cnt :=
                                l_control_detail_array(I).debit_memos_no_rec_cnt + 1 ;
                           l_control_detail_array(I).debit_memos_no_rec_total :=
                                l_control_detail_array(I).debit_memos_no_rec_total + p_amount ;
                        END IF ;
                    ELSIF p_type = 'CB'
                    THEN
                        IF p_open_rec = 'Y'
                        THEN
                           l_control_detail_array(I).chargebacks_cnt :=
                                l_control_detail_array(I).chargebacks_cnt + 1 ;
                           l_control_detail_array(I).chargebacks_total :=
                                l_control_detail_array(I).chargebacks_cnt + p_amount ;
                        ELSE
                           l_control_detail_array(I).chargebacks_no_rec_cnt :=
                                l_control_detail_array(I).chargebacks_no_rec_cnt + 1 ;
                           l_control_detail_array(I).chargebacks_no_rec_total :=
                                l_control_detail_array(I).chargebacks_no_rec_cnt + p_amount ;
                        END IF ;
                    ELSIF p_type = 'ADJ'
                    THEN
                        l_control_detail_array(I).adjustments_cnt :=
                             l_control_detail_array(I).adjustments_cnt + 1 ;
                        l_control_detail_array(I).adjustments_total :=
                             l_control_detail_array(I).adjustments_total + p_amount ;
                    ELSIF p_type = 'CASH'
                    THEN
                        l_control_detail_array(I).cash_receipts_cnt :=
                             l_control_detail_array(I).cash_receipts_cnt + 1 ;
                        -- Negating the Cash Receipts amount
                        l_control_detail_array(I).cash_receipts_total :=
                             l_control_detail_array(I).cash_receipts_total + (-1 * p_amount) ;
                    ELSIF p_type = 'MISC'
                    THEN
                        l_control_detail_array(I).misc_receipts_cnt :=
                             l_control_detail_array(I).misc_receipts_cnt + 1 ;
                        l_control_detail_array(I).misc_receipts_total :=
                             l_control_detail_array(I).misc_receipts_cnt + p_amount ;
                    ELSIF p_type = 'DISC'
                    THEN
                        l_control_detail_array(I).discounts_total :=
                             l_control_detail_array(I).discounts_total + (-1 * p_amount) ;
                    ELSIF p_type = 'EXCH'
                    THEN
                        l_control_detail_array(I).exchange_gain_loss_total :=
                             l_control_detail_array(I).exchange_gain_loss_total + p_amount ;
                    END IF ;
                    RETURN TRUE ;
                END IF ;
            END LOOP ;
       END IF ;
       --
       l_control_detail_index := NVL(l_last_index,0) + 1 ; -- Adding a new entry in the table
       --
       -- Initialising the values
       --
       l_control_detail_array(l_control_detail_index).invoices_cnt := 0 ;
       l_control_detail_array(l_control_detail_index).credit_memos_cnt := 0 ;
       l_control_detail_array(l_control_detail_index).debit_memos_cnt := 0 ;
       l_control_detail_array(l_control_detail_index).chargebacks_cnt := 0 ;
       l_control_detail_array(l_control_detail_index).adjustments_cnt := 0 ;
       l_control_detail_array(l_control_detail_index).cash_receipts_cnt := 0 ;
       l_control_detail_array(l_control_detail_index).invoices_no_rec_cnt := 0 ;
       l_control_detail_array(l_control_detail_index).credit_memos_no_rec_cnt := 0 ;
       l_control_detail_array(l_control_detail_index).debit_memos_no_rec_cnt := 0 ;
       l_control_detail_array(l_control_detail_index).chargebacks_no_rec_cnt := 0 ;
       l_control_detail_array(l_control_detail_index).misc_receipts_cnt := 0 ;
       l_control_detail_array(l_control_detail_index).invoices_total := 0 ;
       l_control_detail_array(l_control_detail_index).credit_memos_total := 0 ;
       l_control_detail_array(l_control_detail_index).debit_memos_total := 0 ;
       l_control_detail_array(l_control_detail_index).chargebacks_total := 0 ;
       l_control_detail_array(l_control_detail_index).adjustments_total := 0 ;
       l_control_detail_array(l_control_detail_index).cash_receipts_total := 0 ;
       l_control_detail_array(l_control_detail_index).discounts_total := 0 ;
       l_control_detail_array(l_control_detail_index).exchange_gain_loss_total := 0 ;
       l_control_detail_array(l_control_detail_index).invoices_no_rec_total := 0 ;
       l_control_detail_array(l_control_detail_index).credit_memos_no_rec_total := 0 ;
       l_control_detail_array(l_control_detail_index).debit_memos_no_rec_total := 0 ;
       l_control_detail_array(l_control_detail_index).chargebacks_no_rec_total := 0 ;
       l_control_detail_array(l_control_detail_index).misc_receipts_total := 0 ;
       --
       l_control_detail_array(l_control_detail_index).period_name := p_period_name ;
       --
       IF p_type = 'INV'
       THEN
           IF p_open_rec = 'Y'
           THEN
              l_control_detail_array(l_control_detail_index).invoices_cnt := 1 ;
              l_control_detail_array(l_control_detail_index).invoices_total := p_amount ;
           ELSE
              l_control_detail_array(l_control_detail_index).invoices_no_rec_cnt := 1 ;
              l_control_detail_array(l_control_detail_index).invoices_no_rec_total := p_amount ;
           END IF ;
       ELSIF p_type = 'CM'
       THEN
           IF p_open_rec = 'Y'
           THEN
              l_control_detail_array(l_control_detail_index).credit_memos_cnt := 1 ;
              l_control_detail_array(l_control_detail_index).credit_memos_total := p_amount ;
           ELSE
              l_control_detail_array(l_control_detail_index).credit_memos_no_rec_cnt := 1 ;
              l_control_detail_array(l_control_detail_index).credit_memos_no_rec_total := p_amount ;
           END IF ;
       ELSIF p_type = 'DM'
       THEN
           IF p_open_rec = 'Y'
           THEN
              l_control_detail_array(l_control_detail_index).debit_memos_cnt := 1 ;
              l_control_detail_array(l_control_detail_index).debit_memos_total := p_amount ;
           ELSE
              l_control_detail_array(l_control_detail_index).debit_memos_no_rec_cnt := 1 ;
              l_control_detail_array(l_control_detail_index).debit_memos_no_rec_total := p_amount ;
           END IF ;
       ELSIF p_type = 'CB'
       THEN
           IF p_open_rec = 'Y'
           THEN
              l_control_detail_array(l_control_detail_index).chargebacks_cnt := 1 ;
              l_control_detail_array(l_control_detail_index).chargebacks_total := p_amount ;
           ELSE
              l_control_detail_array(l_control_detail_index).chargebacks_no_rec_cnt := 1 ;
              l_control_detail_array(l_control_detail_index).chargebacks_no_rec_total := p_amount ;
           END IF ;
       ELSIF p_type = 'ADJ'
       THEN
           l_control_detail_array(l_control_detail_index).adjustments_cnt := 1 ;
           l_control_detail_array(l_control_detail_index).adjustments_total := p_amount ;
       ELSIF p_type = 'CASH'
       THEN
           l_control_detail_array(l_control_detail_index).cash_receipts_cnt := 1 ;
           -- Negating the Cash Receipts amount
           l_control_detail_array(l_control_detail_index).cash_receipts_total := -1 * p_amount ;
       ELSIF p_type = 'MISC'
       THEN
           l_control_detail_array(l_control_detail_index).misc_receipts_cnt := 1 ;
           l_control_detail_array(l_control_detail_index).misc_receipts_total := p_amount ;
       ELSIF p_type = 'DISC'
       THEN
           l_control_detail_array(l_control_detail_index).discounts_total := -1 * p_amount ;
       ELSIF p_type = 'EXCH'
       THEN
           l_control_detail_array(l_control_detail_index).exchange_gain_loss_total := p_amount ;
       END IF ;
       --
       RETURN(TRUE) ;

    EXCEPTION
        WHEN OTHERS THEN
           print( 1, '  ...Failed while ins into control_detail_table');
           print( 1, 'sqlcode = ' || SQLCODE || SQLERRM ) ;
           RAISE ;
    END ;
    --
    --
    -- bug1199027
    FUNCTION upd_arch_control_detail ( p_archive_id  IN NUMBER ) RETURN BOOLEAN IS
       I NUMBER ;
    BEGIN

       FOR I IN 1..l_control_detail_array.last
       LOOP
            UPDATE ar_archive_control_detail
            SET    invoices_cnt              = invoices_cnt +
                                                   l_control_detail_array(I).invoices_cnt ,
                   credit_memos_cnt          = credit_memos_cnt +
                                                   l_control_detail_array(I).credit_memos_cnt,
                   debit_memos_cnt           = debit_memos_cnt +
                                                   l_control_detail_array(I).debit_memos_cnt,
                   chargebacks_cnt           = chargebacks_cnt +
                                                   l_control_detail_array(I).chargebacks_cnt,
                   adjustments_cnt           = adjustments_cnt +
                                                   l_control_detail_array(I).adjustments_cnt,
                   cash_receipts_cnt         = cash_receipts_cnt +                                                                                          l_control_detail_array(I).cash_receipts_cnt,
                   invoices_no_rec_cnt       = invoices_no_rec_cnt +
                                                   l_control_detail_array(I).invoices_no_rec_cnt,
                   credit_memos_no_rec_cnt   = credit_memos_no_rec_cnt +
                                                   l_control_detail_array(I).credit_memos_no_rec_cnt,
                   debit_memos_no_rec_cnt    = debit_memos_no_rec_cnt +
                                                   l_control_detail_array(I).debit_memos_no_rec_cnt,
                   chargebacks_no_rec_cnt    = chargebacks_no_rec_cnt +
                                                   l_control_detail_array(I).chargebacks_no_rec_cnt,
                   misc_receipts_cnt         = misc_receipts_cnt +
                                                   l_control_detail_array(I).misc_receipts_cnt,
                   invoices_total            = invoices_total +
                                                   l_control_detail_array(I).invoices_total,
                   credit_memos_total        = credit_memos_total +
                                                   l_control_detail_array(I).credit_memos_total,
                   debit_memos_total         = debit_memos_total +
                                                   l_control_detail_array(I).debit_memos_total,
                   chargebacks_total         = chargebacks_total +
                                                   l_control_detail_array(I).chargebacks_total,
                   adjustments_total         = adjustments_total +
                                                   l_control_detail_array(I).adjustments_total,
                   -- Negating the Cash Receipts amount
                   cash_receipts_total       = cash_receipts_total +
                                                   l_control_detail_array(I).cash_receipts_total,
                   discounts_total           = discounts_total +
                                                   l_control_detail_array(I).discounts_total,
                   exchange_gain_loss_total  = exchange_gain_loss_total +
                                                   l_control_detail_array(I).exchange_gain_loss_total,
                   invoices_no_rec_total     = invoices_no_rec_total +
                                                   l_control_detail_array(I).invoices_no_rec_total,
                   credit_memos_no_rec_total =  credit_memos_no_rec_total +
                                                   l_control_detail_array(I).credit_memos_no_rec_total,
                   debit_memos_no_rec_total  = debit_memos_no_rec_total +
                                                   l_control_detail_array(I).debit_memos_no_rec_total,
                   chargebacks_no_rec_total  = chargebacks_no_rec_total  +
                                                   l_control_detail_array(I).chargebacks_no_rec_total,
                   misc_receipts_total       = misc_receipts_total +
                                                   l_control_detail_array(I).misc_receipts_total
            WHERE  archive_id  = p_archive_id
            AND    period_name = l_control_detail_array(I).period_name  ;

            IF SQL%ROWCOUNT = 0
            THEN
                BEGIN

                    INSERT INTO ar_archive_control_detail
                    ( archive_id,
                      period_name,
                      invoices_cnt,
                      credit_memos_cnt,
                      debit_memos_cnt,
                      chargebacks_cnt,
                      adjustments_cnt,
                      cash_receipts_cnt,
                      invoices_no_rec_cnt,
                      credit_memos_no_rec_cnt,
                      debit_memos_no_rec_cnt,
                      chargebacks_no_rec_cnt,
                      misc_receipts_cnt,
                      invoices_total,
                      credit_memos_total,
                      debit_memos_total,
                      chargebacks_total,
                      adjustments_total,
                      cash_receipts_total,
                      discounts_total,
                      exchange_gain_loss_total,
                      invoices_no_rec_total,
                      credit_memos_no_rec_total,
                      debit_memos_no_rec_total,
                      chargebacks_no_rec_total,
                      misc_receipts_total,
                      deposits_total,
                      deposits_cnt
                    )
                    VALUES
                    (
                      lpad(p_archive_id,14,'0'), /* modified for the bug 3266428 */
                      l_control_detail_array(I).period_name,
                      l_control_detail_array(I).invoices_cnt,
                      l_control_detail_array(I).credit_memos_cnt,
                      l_control_detail_array(I).debit_memos_cnt,
                      l_control_detail_array(I).chargebacks_cnt,
                      l_control_detail_array(I).adjustments_cnt,
                      l_control_detail_array(I).cash_receipts_cnt,
                      l_control_detail_array(I).invoices_no_rec_cnt,
                      l_control_detail_array(I).credit_memos_no_rec_cnt,
                      l_control_detail_array(I).debit_memos_no_rec_cnt,
                      l_control_detail_array(I).chargebacks_no_rec_cnt,
                      l_control_detail_array(I).misc_receipts_cnt,
                      l_control_detail_array(I).invoices_total,
                      l_control_detail_array(I).credit_memos_total,
                      l_control_detail_array(I).debit_memos_total,
                      l_control_detail_array(I).chargebacks_total,
                      l_control_detail_array(I).adjustments_total,
                      l_control_detail_array(I).cash_receipts_total,
                      l_control_detail_array(I).discounts_total,
                      l_control_detail_array(I).exchange_gain_loss_total,
                      l_control_detail_array(I).invoices_no_rec_total,
                      l_control_detail_array(I).credit_memos_no_rec_total,
                      l_control_detail_array(I).debit_memos_no_rec_total,
                      l_control_detail_array(I).chargebacks_no_rec_total,
                      l_control_detail_array(I).misc_receipts_total,
                      l_control_detail_array(I).deposits_total,
                      l_control_detail_array(I).deposits_cnt
                    ) ;
                EXCEPTION
                    WHEN OTHERS THEN
                        print( 1, '  ...Failed while inserting into AR_ARCHIVE_CONTROL_DETAIL');
                        print( 1, 'sqlcode = ' || SQLCODE || SQLERRM ) ;
                        RAISE ;
                END  ;
            END IF ;

       END LOOP ;
       RETURN(TRUE) ;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             print( 1, '  ...Failed while ins/upd into AR_ARCHIVE_CONTROL_DETAIL');
             RETURN(FALSE);
        WHEN OTHERS THEN
           print( 1, '  ...Failed while ins/upd into AR_ARCHIVE_CONTROL_DETAIL');
           print( 1, 'sqlcode = ' || SQLCODE || SQLERRM ) ;
           RAISE ;
    END ;
    ---
    FUNCTION trx_purgeable(p_entity_id IN NUMBER) RETURN BOOLEAN IS
      allow_purge BOOLEAN := TRUE;
    BEGIN
    --
    --  Place your logic here. Set the value of allow_purge to TRUE if
    --  you want this invoice to be purged, or FALSE if you don't want it
    --  purged
        RETURN allow_purge;
    END;
    ---
    --- FUNCTION get_ccid
    --- Function to get concatenated segments for a code combination id
    ---
    FUNCTION get_ccid  (p_code_combination_id  NUMBER) RETURN VARCHAR2 IS
        l_account_segs    VARCHAR2(240);

    BEGIN

	SELECT RTRIM(
		cc.segment1 || '.' ||
		cc.segment2 || '.' ||
		cc.segment3 || '.' ||
		cc.segment4 || '.' ||
		cc.segment5 || '.' ||
		cc.segment6 || '.' ||
		cc.segment7 || '.' ||
		cc.segment8 || '.' ||
		cc.segment9 || '.' ||
		cc.segment10 || '.' ||
		cc.segment11 || '.' ||
		cc.segment12 || '.' ||
		cc.segment13 || '.' ||
		cc.segment14 || '.' ||
		cc.segment15 || '.' ||
		cc.segment16 || '.' ||
		cc.segment17 || '.' ||
		cc.segment18 || '.' ||
		cc.segment19 || '.' ||
		cc.segment20 || '.' ||
		cc.segment21 || '.' ||
		cc.segment22 || '.' ||
		cc.segment23 || '.' ||
		cc.segment24 || '.' ||
		cc.segment25 || '.' ||
		cc.segment26 || '.' ||
		cc.segment27 || '.' ||
		cc.segment28 || '.' ||
		cc.segment29 || '.' ||
		cc.segment30, '.' )
 	INTO    l_account_segs
	FROM    gl_code_combinations cc
	WHERE   cc.code_combination_id = p_code_combination_id;

        RETURN(l_account_segs);

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL ;
        WHEN OTHERS THEN
            print( 1, 'Failed while selecting from gl_code_combinations') ;
            print( 1, 'sqlcode = ' || SQLCODE || SQLERRM ) ;
            RAISE ;
    END get_ccid;
    --
    --
    -- Insert into AR_ARCHIVE_HEADER
    --
    FUNCTION archive_header( p_customer_trx_id IN NUMBER ,
                             p_archive_id      IN NUMBER) RETURN BOOLEAN IS
    BEGIN
    DECLARE
        CURSOR header_cursor ( cp_customer_trx_id NUMBER ) IS
        SELECT ctt.type  type,			/* transaction_class */
               ctt.name  name,			/* transaction_type */
               ct.customer_trx_id  trx_id, 	/* transaction_id */
               decode(ctt.type, 'CM', ctt_prev.type)
                   related_trx_type,            /* related_transaction_class */
               decode(ctt.type, 'CM', ctt_prev.name)
                   related_trx_id,              /* related_transaction_type */
               decode(ctt.type, 'CM', ct.previous_customer_trx_id)
                   prev_trx_id ,                /* related_transaction_id */
               ct.trx_number trx_number,        /* transaction_number */
               ct.trx_date   trx_date,          /* transaction_date */
               batch.name    batch_name,
               bs.name       batch_source_name,
               sob.name      sob_name,
               ctlgd.amount  amount,
               ctlgd.acctd_amount acctd_amount,
               to_number('') exch_gain_loss,	      /* exchange_gain_loss */
               to_number('') earned_disc_taken,	      /* earned_discount_taken */
               to_number('') unearned_disc_taken,     /* unearned_discount_taken */
               to_number('') acctd_earned_disc_taken, /* acctd_earned_discount_taken */
               to_number('') acctd_unearned_disc_taken,	 /* acctd_unearned_discount_taken */
               '' adj_trx_type,				/* type */
               '' adj_type,				/* adjustment_type */
               ctt.post_to_gl post_to_gl,
               ctt.accounting_affect_flag open_receivable,
               '' cash_rcpt_status,		/* cash_receipt_status */
               '' cash_rcpt_hist_status,	/* cash_receipt_history_status */
               lu.meaning reason_code, 		/* reason_code_meaning */
               substrb(bill_party.party_name,1,50)  bill_to_cust_name,
               cust_bill.account_number bill_to_cust_no,
               su_bill.location bill_to_cust_loc,
               bill_loc.address1 bill_to_cust_addr1,
               bill_loc.address2 bill_to_cust_addr2,
               bill_loc.address3 bill_to_cust_addr3,
               bill_loc.address4 bill_to_cust_addr4,
               bill_loc.city bill_to_cust_city,
               bill_loc.state bill_to_cust_state,
               bill_loc.country bill_to_cust_country,
               bill_loc.postal_code bill_to_cust_zip,
               substrb(ship_party.party_name,1,50) ship_to_cust_name,
               cust_ship.account_number ship_to_cust_no,
               su_ship.location      ship_to_cust_loc,
               ship_loc.address1    ship_to_cust_addr1,
               ship_loc.address2    ship_to_cust_addr2,
               ship_loc.address3    ship_to_cust_addr3,
               ship_loc.address4    ship_to_cust_addr4,
               ship_loc.city        ship_to_cust_city,
               ship_loc.state       ship_to_cust_state,
               ship_loc.country     ship_to_cust_country,
               ship_loc.postal_code ship_to_cust_zip,
               remit_loc.address1   remit_to_cust_addr1,
               remit_loc.address2   remit_to_cust_addr2,
               remit_loc.address3   remit_to_cust_addr3,
               remit_loc.address4   remit_to_cust_addr4,
               remit_loc.city       remit_to_cust_city,
               remit_loc.state      remit_to_cust_state,
               remit_loc.country    remit_to_cust_country,
               remit_loc.postal_code remit_to_cust_zip,
               sales.name             salesrep_name,
               term.name              term_name,
               ct.term_due_date       term_due_date,
               ct.printing_last_printed last_printed,
               ct.printing_option printing_option,
               ct.purchase_order purchase_order,
               ct.comments            comments,
               ct.exchange_rate_type exch_rate_type,
               ct.exchange_date exch_date,
               ct.exchange_rate exch_rate,
               ct.invoice_currency_code curr_code,
               nvl(ctlgd.gl_date, ct.trx_date) gl_date,
               to_date(NULL) reversal_date,	/* reversal_date */
               '' reversal_category,		/* reversal_category */
               '' reversal_reason_code,		/* reversal_reason_code_meaning */
               '' reversal_comments, 		/* reversal_comments */
               ct.attribute_category attr_category,
               ct.attribute1 attr1,
               ct.attribute2 attr2,
               ct.attribute3 attr3,
               ct.attribute4 attr4,
               ct.attribute5 attr5,
               ct.attribute6 attr6,
               ct.attribute7 attr7,
               ct.attribute8 attr8,
               ct.attribute9 attr9,
               ct.attribute10 attr10,
               ct.attribute11 attr11,
               ct.attribute12 attr12,
               ct.attribute13 attr13,
               ct.attribute14 attr14,
               ct.attribute15 attr15,
               '' rcpt_method,             /* receipt_method_name */
               ct.waybill_number waybill_no,
               doc.name doc_name,
               ct.doc_sequence_value doc_seq_value,
               ct.start_date_commitment st_date_commitment,
               ct.end_date_commitment en_date_commitment,
               rule.name invoicing_rule,
               '' bank_acct_name,
               to_date(NULL) deposit_date,	/* deposit_date */
               to_number('') factor_disc_amount,/* factor_discount_amount */
               ct.interface_header_context     int_hdr_context,
               ct.interface_header_attribute1  int_hdr_attr1,
               ct.interface_header_attribute2  int_hdr_attr2,
               ct.interface_header_attribute3  int_hdr_attr3,
               ct.interface_header_attribute4  int_hdr_attr4,
               ct.interface_header_attribute5  int_hdr_attr5,
               ct.interface_header_attribute6  int_hdr_attr6,
               ct.interface_header_attribute7  int_hdr_attr7,
               ct.interface_header_attribute8  int_hdr_attr8,
               ct.interface_header_attribute9  int_hdr_attr9,
               ct.interface_header_attribute10 int_hdr_attr10,
               ct.interface_header_attribute11 int_hdr_attr11,
               ct.interface_header_attribute12 int_hdr_attr12,
               ct.interface_header_attribute13 int_hdr_attr13,
               ct.interface_header_attribute14 int_hdr_attr14,
               ct.interface_header_attribute15 int_hdr_attr15,
               '' bank_deposit_no,           /* bank_deposit_number */
               '' reference_type,            /* reference_type */
               to_number('') reference_id,   /* reference_id */
               '' cust_rcpt_reference,	     /* customer_receipt_reference */
               '' bank_acct_name2 /* bank_account_name */
        FROM   ar_lookups        lu,
               ra_rules          rule,
               ra_cust_trx_types ctt_prev,
               ra_cust_trx_types ctt,
               ra_batch_sources  bs,
               ra_batches        batch,
               fnd_document_sequences doc,
               gl_sets_of_books  sob,
               hz_cust_accounts  cust_bill,
               hz_parties        bill_party,
               hz_cust_site_uses su_bill,
               hz_cust_acct_sites addr_bill,
               hz_party_sites     bill_ps,
               hz_locations       bill_loc,
               hz_cust_accounts  cust_ship,
               hz_parties        ship_party,
               hz_cust_site_uses su_ship,
               hz_cust_acct_sites addr_ship,
               hz_party_sites     ship_ps,
               hz_locations       ship_loc,
               hz_cust_acct_sites addr_remit,
               hz_party_sites     remit_ps,
               hz_locations       remit_loc,
               iby_trxn_extensions_v iby,
               ra_salesreps      sales,
               ra_terms          term,
               ra_cust_trx_line_gl_dist ctlgd,
               ra_customer_trx   ct_prev,
               ra_customer_trx   ct
        WHERE  lu.lookup_code (+) = ct.reason_code
        AND    lu.lookup_type (+) = 'INVOICING_REASON'
        AND    iby.trxn_extension_id(+)     = ct.payment_trxn_extension_id
        AND    rule.rule_id (+)             = ct.invoicing_rule_id
        AND    ctt.cust_trx_type_id         = ct.cust_trx_type_id
        AND    bs.batch_source_id           = ct.batch_source_id
        AND    batch.batch_id (+)           = ct.batch_id
        AND    doc.doc_sequence_id (+)      = ct.doc_sequence_id
        AND    sob.set_of_books_id          = ct.set_of_books_id
        AND    cust_bill.cust_account_id (+) = ct.bill_to_customer_id
        AND    cust_bill.party_id           = bill_party.party_id(+)
        AND    su_bill.site_use_id (+)      = ct.bill_to_site_use_id
        AND    addr_bill.cust_acct_site_id (+) = su_bill.cust_acct_site_id
        AND    addr_bill.party_site_id      = bill_ps.party_site_id(+)
        AND    bill_loc.location_id(+)      = bill_ps.location_id
        AND    cust_ship.cust_account_id(+) = ct.ship_to_customer_id
        AND    cust_ship.party_id           = ship_party.party_id(+)
        AND    su_ship.site_use_id (+)      = ct.ship_to_site_use_id
        AND    addr_ship.cust_acct_site_id (+) = su_ship.cust_acct_site_id
        AND    addr_ship.party_site_id      = ship_ps.party_site_id(+)
        AND    ship_loc.location_id (+)        = ship_ps.location_id
        AND    addr_remit.cust_acct_site_id (+) = ct.remit_to_address_id
        AND    addr_remit.party_site_id     = remit_ps.party_site_id(+)
        AND    remit_loc.location_id(+)        = remit_ps.location_id
        AND    sales.salesrep_id(+)         = ct.primary_salesrep_id
        AND    term.term_id (+)             = ct.term_id
        AND    ctlgd.customer_trx_id        = ct.customer_trx_id
        AND    ctlgd.account_class          = 'REC'
        AND    ctlgd.latest_rec_flag        = 'Y'
        AND    ct.previous_customer_trx_id  = ct_prev.customer_trx_id(+)
        AND    ct_prev.cust_trx_type_id     = ctt_prev.cust_trx_type_id(+)
        AND    ct.customer_trx_id           = cp_customer_trx_id
        UNION
        --------------------------------------------------------------------
        -- ADJ: adjustments
        --------------------------------------------------------------------
        SELECT 'ADJ'  type,			  /* transaction_class */
               ''     name,                       /* transaction_type */
               adj.adjustment_id  trx_id,         /* transaction_id */
               ctt.type  related_trx_type,	  /* related_transaction_class */
               ctt.name  related_trx_id,	  /* related_transaction_type */
               ct.customer_trx_id prev_trx_id,    /* related_transaction_id */
               adj.adjustment_number trx_number,  /* transaction_number */
               adj.apply_date trx_date,		  /* transaction_date */
               ''  batch_name,  		  /* batch_name */
               ''  batch_source_name, 		  /* batch_source_name */
               sob.name  sob_name,
               adj.amount amount,
               adj.acctd_amount acctd_amount,
               to_number('') exch_gain_loss,	        /* exchange_gain_loss */
               to_number('') earned_disc_taken,		/* earned_discount_taken */
               to_number('') unearned_disc_taken,	/* unearned_discount_taken */
               to_number('') acctd_earned_disc_taken,   /* acctd_earned_discount_taken */
               to_number('') acctd_unearned_disc_taken,	/* acctd_unearned_discount_taken */
               adj.type  adj_trx_type,
               adj.adjustment_type adj_type,
               '' post_to_gl,		        /* post_to_gl */
               '' open_receivable,		/* accounting_affect_flag */
               '' cash_rcpt_status,	        /* cash_receipt_status */
               '' cash_rcpt_hist_status,	/* cash_receipt_history_status */
               lu.meaning reason_code,    	/* reason_code_meaning */
               substrb(cust_party.party_name,1,50)  bill_to_cust_name,	/* bill_to_customer_name */
               cust.account_number bill_to_cust_no,	/* bill_to_customer_number */
               '' bill_to_cust_loc,		/* bill_to_customer_location */
               '' bill_to_cust_addr1,		/* bill_to_customer_address1 */
               '' bill_to_cust_addr2,		/* bill_to_customer_address2 */
               '' bill_to_cust_addr3,		/* bill_to_customer_address3 */
               '' bill_to_cust_addr4,		/* bill_to_customer_address4 */
               '' bill_to_cust_city,		/* bill_to_customer_city */
               '' bill_to_cust_state,		/* bill_to_customer_state */
               '' bill_to_cust_country,		/* bill_to_customer_country */
               '' bill_to_cust_zip,		/* bill_to_customer_postal_code */
               '' ship_to_cust_name,		/* ship_to_customer_name */
               '' ship_to_cust_no,		/* ship_to_customer_number */
               '' ship_to_cust_loc,		/* ship_to_customer_location */
               '' ship_to_cust_addr1,           /* ship_to_customer_address1 */
               '' ship_to_cust_addr2,           /* ship_to_customer_address2 */
               '' ship_to_cust_addr3,		/* ship_to_customer_address3 */
               '' ship_to_cust_addr4,		/* ship_to_customer_address4 */
               '' ship_to_cust_city,		/* ship_to_customer_city */
               '' ship_to_cust_state,           /* ship_to_customer_state */
               '' ship_to_cust_country,         /* ship_to_customer_country */
               '' ship_to_cust_zip,		/* ship_to_customer_postal_code */
               '' remit_to_cust_addr1,		/* remit_to_customer_address1 */
               '' remit_to_cust_addr2,          /* remit_to_customer_address2 */
               '' remit_to_cust_addr3,          /* remit_to_customer_address3 */
               '' remit_to_cust_addr4,          /* remit_to_customer_address4 */
               '' remit_to_cust_city,           /* remit_to_customer_city */
               '' remit_to_cust_state,          /* remit_to_customer_state */
               '' remit_to_cust_country,        /* remit_to_customer_country */
               '' remit_to_cust_zip,	        /* remit_to_customer_postal_code */
               '' salesrep_name,		/* salesrep_name */
               '' term_name, 		        /* term_name */
               to_date(NULL) term_due_date,       /* term_due_date */
               to_date(NULL) last_printed,        /* printing_last_printed */
               '' printing_option,	        /* printing_option */
               '' purchase_order, 		/* purchase_order */
               '' comments,   		        /* comments */
               '' exch_rate_type,		/* exchange_rate_type */
               to_date(NULL) exch_date, 	/* exchange_rate_date */
               to_number('') exch_rate, 	/* exchange_rate */
               ct.invoice_currency_code curr_code,
               nvl(adj.gl_date, ct.trx_date)  gl_date,
               to_date(NULL) reversal_date,		/* reversal_date */
               '' reversal_catergory,			/* reversal_category */
               '' reversal_reason_code,			/* reversal_reason_code_meaning */
               '' reversal_comments, 			/* reversal_comments */
               adj.attribute_category attr_catergory,
               adj.attribute1 attr1,
               adj.attribute2 attr2,
               adj.attribute3 attr3,
               adj.attribute4 attr4,
               adj.attribute5 attr5,
               adj.attribute6 attr6,
               adj.attribute7 attr7,
               adj.attribute8 attr8,
               adj.attribute9 attr9,
               adj.attribute10 attr10,
               adj.attribute11 attr11,
               adj.attribute12 attr12,
               adj.attribute13 attr13,
               adj.attribute14 attr14,
               adj.attribute15 attr15,
               '' rcpt_method,		 /* receipt_method_name */
               '' waybill_no,			/* waybill_number */
               doc.name doc_name,
               adj.doc_sequence_value doc_seq_value,
               to_date(NULL) st_date_commitment,		/* start_date_commitment */
               to_date(NULL) en_date_commitment,		/* end_date_commitment */
               '' invoicing_rule,			/* invoicing_rule_name */
               '' bank_acct_name,			/* bank_account_name */
               to_date(NULL) deposit_date,		/* deposit_date */
               to_number('') factor_disc_amount,/* factor_discount_amount */
               '' int_hdr_context,		/* interface_header_context */
               '' int_hdr_attr1,		/* interface_header_attribute1 */
               '' int_hdr_attr2,		/* interface_header_attribute2 */
               '' int_hdr_attr3,		/* interface_header_attribute3 */
               '' int_hdr_attr4,		/* interface_header_attribute4 */
               '' int_hdr_attr5,		/* interface_header_attribute5 */
               '' int_hdr_attr6,		/* interface_header_attribute6 */
               '' int_hdr_attr7,		/* interface_header_attribute7 */
               '' int_hdr_attr8,		/* interface_header_attribute8 */
               '' int_hdr_attr9,		/* interface_header_attribute9 */
               '' int_hdr_attr10,		/* interface_header_attribute10 */
               '' int_hdr_attr11,		/* interface_header_attribute11 */
               '' int_hdr_attr12,		/* interface_header_attribute12 */
               '' int_hdr_attr13,		/* interface_header_attribute13 */
               '' int_hdr_attr14,		/* interface_header_attribute14 */
               '' int_hdr_attr15,		/* interface_header_attribute15 */
               '' bank_deposit_no,		/* bank_deposit_number */
               '' reference_type,		/* reference_type */
               to_number('') reference_id,	/* reference_id */
               '' cust_rcpt_reference,		/* customer_receipt_reference */
               '' bank_acct_name2               /* bank_account_name */
        FROM   ra_cust_trx_types ctt,
               fnd_document_sequences doc,
               gl_sets_of_books  sob,
               ar_lookups        lu,
               ar_adjustments    adj,
               hz_cust_accounts  cust,
               hz_parties        cust_party,
               ra_customer_trx   ct
        WHERE  lu.lookup_code (+)      = adj.reason_code
        AND    lu.lookup_type (+)      = 'ADJUST_REASON'
        AND    ctt.cust_trx_type_id    = ct.cust_trx_type_id
        AND    doc.doc_sequence_id (+) = adj.doc_sequence_id
        AND    sob.set_of_books_id     = adj.set_of_books_id
        AND    adj.customer_trx_id     = ct.customer_trx_id
               /* do not archive unaccrued adjustments */
        AND    adj.status <> 'U'
        AND    cust.cust_account_id (+)    = ct.bill_to_customer_id
        AND    cust.party_id = cust_party.party_id (+)
        AND    ct.customer_trx_id      = cp_customer_trx_id
        UNION
        --------------------------------------------------------------------
        -- REC: cash receipts
        --------------------------------------------------------------------
        SELECT cr.type type,			/* transaction_class */
               '' name,			        /* transaction_type */
               cr.cash_receipt_id trx_id, 	/* transaction_id */
               '' related_trx_type,		/* related_transaction_class */
               '' related_trx_id,		/* related_transaction_type */
               to_number('') prev_trx_id, 	/* related_transaction_id */
               cr.receipt_number trx_number,	/* transaction_number */
               cr.receipt_date trx_date,	/* transaction_date */
               batch.name batch_name,
               bs.name    batch_source_name,
               sob.name   sob_name,
               cr.amount  amount,
               -- bug1199027
               sum( ra.acctd_amount_applied_to ) acctd_amount,/* acctd_amount */
               sum( ra.acctd_amount_applied_from - ra.acctd_amount_applied_to )
                        exch_gain_loss, /* exchange_gain_loss */
               sum( ra.earned_discount_taken ) earned_disc_taken ,
               sum( ra.unearned_discount_taken ) unearned_disc_taken ,
               sum( ra.acctd_earned_discount_taken ) acctd_earned_disc_taken ,
               sum( ra.acctd_unearned_discount_taken ) acctd_unearned_disc_taken ,
               cr.type adj_trx_type,
               '' adj_type,			/* adjustment_type */
               ''  post_to_gl,                  /* post_to_gl */
               ''  open_receivable,             /* accounting_affect_flag */
               cr.status cash_rcpt_status,	/* cash_receipt_status */
               crh.status cash_rcpt_hist_status,/* cash_receipt_history_status */
               '' reason_code, 				        /* reason_code_meaning */
               substrb(cust_party.party_name,1,50)  bill_to_cust_name,		/* bill_to_customer_name */
               cust.account_number bill_to_cust_no,	        /* bill_to_customer_number */
               su.location bill_to_cust_loc,			/* bill_to_customer_location */
               substrb(loc.address1, 1, 80) bill_to_cust_addr1, /* bill_to_customer_address1 */
               substrb(loc.address2, 1, 80) bill_to_cust_addr2, /* bill_to_customer_address2 */
               substrb(loc.address3, 1, 80) bill_to_cust_addr3, /* bill_to_customer_address3 */
               substrb(loc.address4, 1, 80) bill_to_cust_addr4, /* bill_to_customer_address4 */
               loc.city  bill_to_cust_city,			/* bill_to_customer_city */
               loc.state bill_to_cust_state,			/* bill_to_customer_state */
               loc.country bill_to_cust_country,               /* bill_to_customer_country */
               loc.postal_code bill_to_cust_zip,		/* bill_to_postal_code*/
               '' ship_to_cust_name,		/* ship_to_customer_name */
               '' ship_to_cust_no, 		/* ship_to_customer_number */
               '' ship_to_cust_loc, 		/* ship_to_customer_location */
               '' ship_to_cust_addr1, 		/* ship_to_customer_address1 */
               '' ship_to_cust_addr2, 		/* ship_to_customer_address2 */
               '' ship_to_cust_addr3,		/* ship_to_customer_address3 */
               '' ship_to_cust_addr4, 		/* ship_to_customer_address4 */
               '' ship_to_cust_city, 		/* ship_to_customer_city */
               '' ship_to_cust_state, 		/* ship_to_customer_state */
               '' ship_to_cust_country, 	/* ship_to_customer_country */
               '' ship_to_cust_zip,		/* ship_to_customer_postal_code */
               '' remit_to_cust_addr1,  	/* remit_to_customer_address1 */
               '' remit_to_cust_addr2,		/* remit_to_customer_address2 */
               '' remit_to_cust_addr3,		/* remit_to_customer_address3 */
               '' remit_to_cust_addr4,		/* remit_to_customer_address4 */
               '' remit_to_cust_city, 		/* remit_to_customer_city */
               '' remit_to_cust_state, 		/* remit_to_customer_state */
               '' remit_to_cust_country, 	/* remit_to_customer_country */
               '' remit_to_cust_zip, 		/* remit_to_customer_postal_code */
               '' salesrep_name, 		/* salesrep_name */
               '' term_name, 			/* term_name */
               to_date(NULL) term_due_date,	/* term_due_date */
               to_date(NULL) last_printed,	/* printing_last_printed */
               '' printing_option,			/* printing_option */
               '' purchase_order,  		/* purchase_order */
               cr.comments comments,
               cr.exchange_rate_type exch_rate_type,
               cr.exchange_date exch_date,
               cr.exchange_rate exch_rate,
               cr.currency_code curr_code,
               nvl(crh.gl_date, cr.receipt_date) gl_date,
               cr.reversal_date reversal_date,
               substrb(lu1.meaning, 1, 20) reversal_category, 	/* reversal_category */
               lu2.meaning reversal_reason_code,       		/* reversal_reason_code_meaning */
               cr.reversal_comments reversal_comments,
               substrb(cr.attribute_category, 1, 30) attr_category,
               cr.attribute1 attr1,
               cr.attribute2 attr2,
               cr.attribute3 attr3,
               cr.attribute4 attr4,
               cr.attribute5 attr5,
               cr.attribute6 attr6,
               cr.attribute7 attr7,
               cr.attribute8 attr8,
               cr.attribute9 attr9,
               cr.attribute10 attr10,
               cr.attribute11 attr11,
               cr.attribute12 attr12,
               cr.attribute13 attr13,
               cr.attribute14 attr14,
               cr.attribute15 attr15,
               rm.name rcpt_method,		/* receipt_method_name */
               '' waybill_no,			/* waybill_number */
               doc.name doc_name,
               cr.doc_sequence_value doc_seq_value,
               to_date(NULL) st_date_commitment,		/* start_date_commitment */
               to_date(NULL) en_date_commitment,		/* end_date_commitment */
               '' invoicing_rule,       /* invoicing_rule_name */
               '' bank_acct_name,
               cr.deposit_date deposit_date,
               cr.factor_discount_amount factor_disc_amount,
               '' int_hdr_context,      /* interface_header_context */
               '' int_hdr_attr1,        /* interface_header_attribute1 */
               '' int_hdr_attr2,	/* interface_header_attribute2 */
               '' int_hdr_attr3,	/* interface_header_attribute3 */
               '' int_hdr_attr4,	/* interface_header_attribute4 */
               '' int_hdr_attr5,	/* interface_header_attribute5 */
               '' int_hdr_attr6,	/* interface_header_attribute6 */
               '' int_hdr_attr7,	/* interface_header_attribute7 */
               '' int_hdr_attr8,	/* interface_header_attribute8 */
               '' int_hdr_attr9,	/* interface_header_attribute9 */
               '' int_hdr_attr10,	/* interface_header_attribute10 */
               '' int_hdr_attr11,	/* interface_header_attribute11 */
               '' int_hdr_attr12,	/* interface_header_attribute12 */
               '' int_hdr_attr13,	/* interface_header_attribute13 */
               '' int_hdr_attr14,	/* interface_header_attribute14 */
               '' int_hdr_attr15, 	/* interface_header_attribute15 */
               batch_remit.bank_deposit_number bank_deposit_no,
               cr.reference_type reference_type,
               cr.reference_id reference_id,
               cr.customer_receipt_reference cust_rcpt_reference,
               cba.bank_account_name bank_acct_name2
        FROM   ar_lookups lu1,
               ar_lookups lu2,
               ar_receipt_methods rm,
               ar_batch_sources  bs,
               ar_batches        batch,
               ar_batches        batch_remit,
               ce_bank_accounts  cba,
               ce_bank_acct_uses ba2,
               ce_bank_branches_v bb,
               fnd_document_sequences doc,
               gl_sets_of_books  sob,
               hz_cust_acct_sites addr,
               hz_party_sites     party_site,
               hz_locations       loc,
               hz_cust_site_uses su,
               hz_cust_accounts  cust,
               hz_parties        cust_party,
               iby_trxn_extensions_v iby,
               ar_receivable_applications ra,
               ar_receivable_applications ra1, --bug1199027
               ar_cash_receipt_history crh,
               ar_cash_receipt_history crh_batch,
               ar_cash_receipt_history crh_remit,
               ar_cash_receipts  cr
        WHERE  lu1.lookup_code (+)  = cr.reversal_category
        AND    lu1.lookup_type (+)  = 'REVERSAL_CATEGORY_TYPE'
        AND    lu2.lookup_code (+)  = cr.reversal_reason_code
        AND    lu2.lookup_type (+)  = 'CKAJST_REASON'
        AND    iby.trxn_extension_id(+)     = cr.payment_trxn_extension_id
        AND    ba2.bank_account_id          = cba.bank_account_id (+)
        AND    ba2.bank_acct_use_id (+)     = cr.remit_bank_acct_use_id
        AND    bb.branch_party_id  (+)      = cba.bank_branch_id
        AND    rm.receipt_method_id (+)     = cr.receipt_method_id
        AND    cust.cust_account_id (+)     = cr.pay_from_customer
        AND    cust.party_id                = cust_party.party_id(+)
        AND    su.site_use_id (+)           = cr.customer_site_use_id
        AND    addr.cust_acct_site_id (+)   = su.cust_acct_site_id
        AND    addr.party_site_id           = party_site.party_site_id(+)
        AND    loc.location_id (+)          = party_site.location_id
        AND    doc.doc_sequence_id (+)      = cr.doc_sequence_id
        AND    sob.set_of_books_id          = cr.set_of_books_id
               /* get CR batch info */
        AND    bs.batch_source_id (+)       = batch.batch_source_id
        AND    batch.batch_id (+)           = crh_batch.batch_id
        AND    crh_batch.first_posted_record_flag = 'Y'
        AND    crh_batch.cash_receipt_id    = cr.cash_receipt_id
               /* get current crh record for gl_date */
        AND    crh.cash_receipt_id          = cr.cash_receipt_id
        AND    crh.current_record_flag      = 'Y'
               /* get remittance batch */
        AND    crh_remit.batch_id           = batch_remit.batch_id(+)
        AND    nvl(crh_remit.cash_receipt_history_id, -99) in
                   ( SELECT nvl( min(crh1.cash_receipt_history_id), -99 )
                     from   ar_cash_receipt_history crh1
                     where  crh1.cash_receipt_id  = cr.cash_receipt_id
                     and    crh1.status = 'REMITTED' )
        AND    crh_remit.status (+)         = 'REMITTED'
        AND    crh_remit.cash_receipt_id(+) = cr.cash_receipt_id
        AND    cr.cash_receipt_id           = ra.cash_receipt_id
        -- bug1199027
        and    ra.cash_receipt_id           = ra1.cash_receipt_id
        and    ra.status = ra1.status
        and    ra1.applied_customer_trx_id  = cp_customer_trx_id
        and    ra1.status = 'APP'
        -- bug2859402 Don't insert duplicate cash record.
        and    not exists (
                  select 'already purged'
                    from ar_archive_header aah
                   where aah.transaction_id = cr.cash_receipt_id
                     and aah.transaction_class = 'CASH' )
        GROUP BY cr.type,			/* transaction_class */
                 cr.cash_receipt_id, 		/* transaction_id */
                 cr.receipt_number,		/* transaction_number */
                 cr.receipt_date,		/* transaction_date */
                 batch.name,
                 bs.name,
                 sob.name,
                 cr.amount,
                 cr.type,
                 cr.status,			/* cash_receipt_status */
                 crh.status,			/* cash_receipt_history_status */
                 cust_party.party_name,		/* bill_to_customer_name */
                 cust.account_number,		/* bill_to_customer_number */
                 su.location,			/* bill_to_customer_location */
                 substrb(loc.address1, 1, 80), 	/* bill_to_customer_address1 */
                 substrb(loc.address2, 1, 80),	/* bill_to_customer_address2 */
                 substrb(loc.address3, 1, 80), 	/* bill_to_customer_address3 */
                 substrb(loc.address4, 1, 80), 	/* bill_to_customer_address4 */
                 loc.city,			/* bill_to_customer_city */
                 loc.state,			/* bill_to_customer_state */
                 loc.country,			/* bill_to_customer_country */
                 loc.postal_code,		/* bill_to_customer_postal_code */
                 cr.comments,
                 cr.exchange_rate_type,
                 cr.exchange_date,
                 cr.exchange_rate,
                 cr.currency_code,
                 nvl(crh.gl_date, cr.receipt_date),
                 cr.reversal_date,
                 substrb(lu1.meaning, 1, 20), 	/* reversal_category */
                 lu2.meaning,       		/* reversal_reason_code_meaning */
                 cr.reversal_comments,
                 substrb(cr.attribute_category, 1, 30),
                 cr.attribute1,
                 cr.attribute2,
                 cr.attribute3,
                 cr.attribute4,
                 cr.attribute5,
                 cr.attribute6,
                 cr.attribute7,
                 cr.attribute8,
                 cr.attribute9,
                 cr.attribute10,
                 cr.attribute11,
                 cr.attribute12,
                 cr.attribute13,
                 cr.attribute14,
                 cr.attribute15,
                 rm.name,			/* receipt_method_name */
                 doc.name,
                 cr.doc_sequence_value,
                 cr.deposit_date,
                 cr.factor_discount_amount,
                 batch_remit.bank_deposit_number,
                 cr.reference_type,
                 cr.reference_id,
                 cr.customer_receipt_reference,
                 cba.bank_account_name  ;
        l_total_discount  NUMBER ;
        l_period_name     VARCHAR2(15) ;
        l_status          BOOLEAN ;

        BEGIN

            FOR select_header IN header_cursor ( p_customer_trx_id )
            LOOP
            -- Collect Statistics

                 l_period_name := get_period_name ( select_header.gl_date ) ;

                 BEGIN

                     INSERT INTO ar_archive_header
                     ( archive_id,
                       transaction_class,
                       transaction_type,
                       transaction_id,
                       related_transaction_class,
                       related_transaction_type,
                       related_transaction_id,
                       transaction_number,
                       transaction_date,
                       batch_name,
                       batch_source_name,
                       set_of_books_name,
                       amount,
                       -- acctd_amount, -- bug1199027
                       exchange_gain_loss,
                       earned_discount_taken,
                       unearned_discount_taken,
                       -- acctd_earned_discount_taken, -- bug1199027
                       -- acctd_unearned_discount_taken, -- bug1199027
                       type,
                       adjustment_type,
                       post_to_gl,
                       accounting_affect_flag,
                       cash_receipt_status,
                       cash_receipt_history_status,
                       reason_code_meaning,
                       bill_to_customer_name,
                       bill_to_customer_number,
                       bill_to_customer_location,
                       bill_to_customer_address1,
                       bill_to_customer_address2,
                       bill_to_customer_address3,
                       bill_to_customer_address4,
                       bill_to_customer_city,
                       bill_to_customer_state,
                       bill_to_customer_country,
                       bill_to_customer_postal_code,
                       ship_to_customer_name,
                       ship_to_customer_number,
                       ship_to_customer_location,
                       ship_to_customer_address1,
                       ship_to_customer_address2,
                       ship_to_customer_address3,
                       ship_to_customer_address4,
                       ship_to_customer_city,
                       ship_to_customer_state,
                       ship_to_customer_country,
                       ship_to_customer_postal_code,
                       remit_to_address1,
                       remit_to_address2,
                       remit_to_address3,
                       remit_to_address4,
                       remit_to_city,
                       remit_to_state,
                       remit_to_country,
                       remit_to_postal_code,
                       salesrep_name,
                       term_name,
                       term_due_date,
                       printing_last_printed,
                       printing_option,
                       purchase_order,
                       comments,
                       exchange_rate_type,
                       exchange_rate_date,
                       exchange_rate,
                       currency_code,
                       gl_date,
                       reversal_date,
                       reversal_category,
                       reversal_reason_code_meaning,
                       reversal_comments,
                       attribute_category,
                       attribute1,
                       attribute2,
                       attribute3,
                       attribute4,
                       attribute5,
                       attribute6,
                       attribute7,
                       attribute8,
                       attribute9,
                       attribute10,
                       attribute11,
                       attribute12,
                       attribute13,
                       attribute14,
                       attribute15,
                       receipt_method_name,
                       waybill_number,
                       document_sequence_name,
                       document_sequence_value,
                       start_date_commitment,
                       end_date_commitment,
                       invoicing_rule_name,
                       customer_bank_account_name,
                       deposit_date,
                       factor_discount_amount,
                       interface_header_context,
                       interface_header_attribute1,
                       interface_header_attribute2,
                       interface_header_attribute3,
                       interface_header_attribute4,
                       interface_header_attribute5,
                       interface_header_attribute6,
                       interface_header_attribute7,
                       interface_header_attribute8,
                       interface_header_attribute9,
                       interface_header_attribute10,
                       interface_header_attribute11,
                       interface_header_attribute12,
                       interface_header_attribute13,
                       interface_header_attribute14,
                       interface_header_attribute15,
                       bank_deposit_number,
                       reference_type,
                       reference_id,
                       customer_receipt_reference,
                       bank_account_name
                     )
                     VALUES
                     ( lpad(p_archive_id,14,'0'), /* modified for bug 3266428 */
                       select_header.type,
                       select_header.name,
                       select_header.trx_id,
                       select_header.related_trx_type,
                       select_header.related_trx_id,
                       select_header.prev_trx_id ,
                       select_header.trx_number,
                       select_header.trx_date,
                       select_header.batch_name,
                       select_header.batch_source_name,
                       select_header.sob_name,
                       select_header.amount,
                       -- select_header.acctd_amount, --bug1199027
                       select_header.exch_gain_loss,
                       select_header.earned_disc_taken,
                       select_header.unearned_disc_taken,
                       -- select_header.acctd_earned_disc_taken, --bug1199027
                       -- select_header.acctd_unearned_disc_taken, --bug1199027
                       select_header.adj_trx_type,
                       select_header.adj_type,
                       select_header.post_to_gl,
                       select_header.open_receivable,
                       select_header.cash_rcpt_status,
                       select_header.cash_rcpt_hist_status,
                       select_header.reason_code,
                       select_header.bill_to_cust_name,
                       select_header.bill_to_cust_no,
                       select_header.bill_to_cust_loc,
                       select_header.bill_to_cust_addr1,
                       select_header.bill_to_cust_addr2,
                       select_header.bill_to_cust_addr3,
                       select_header.bill_to_cust_addr4,
                       select_header.bill_to_cust_city,
                       select_header.bill_to_cust_state,
                       select_header.bill_to_cust_country,
                       select_header.bill_to_cust_zip,
                       select_header.ship_to_cust_name,
                       select_header.ship_to_cust_no,
                       select_header.ship_to_cust_loc,
                       select_header.ship_to_cust_addr1,
                       select_header.ship_to_cust_addr2,
                       select_header.ship_to_cust_addr3,
                       select_header.ship_to_cust_addr4,
                       select_header.ship_to_cust_city,
                       select_header.ship_to_cust_state,
                       select_header.ship_to_cust_country,
                       select_header.ship_to_cust_zip,
                       select_header.remit_to_cust_addr1,
                       select_header.remit_to_cust_addr2,
                       select_header.remit_to_cust_addr3,
                       select_header.remit_to_cust_addr4,
                       select_header.remit_to_cust_city,
                       select_header.remit_to_cust_state,
                       select_header.remit_to_cust_country,
                       select_header.remit_to_cust_zip,
                       select_header.salesrep_name,
                       select_header.term_name,
                       select_header.term_due_date,
                       select_header.last_printed,
                       select_header.printing_option,
                       select_header.purchase_order,
                       select_header.comments,
                       select_header.exch_rate_type,
                       select_header.exch_date,
                       select_header.exch_rate,
                       select_header.curr_code,
                       select_header.gl_date,
                       select_header.reversal_date,
                       select_header.reversal_category,
                       select_header.reversal_reason_code,
                       select_header.reversal_comments,
                       select_header.attr_category,
                       select_header.attr1,
                       select_header.attr2,
                       select_header.attr3,
                       select_header.attr4,
                       select_header.attr5,
                       select_header.attr6,
                       select_header.attr7,
                       select_header.attr8,
                       select_header.attr9,
                       select_header.attr10,
                       select_header.attr11,
                       select_header.attr12,
                       select_header.attr13,
                       select_header.attr14,
                       select_header.attr15,
                       select_header.rcpt_method,
                       select_header.waybill_no,
                       select_header.doc_name,
                       select_header.doc_seq_value,
                       select_header.st_date_commitment,
                       select_header.en_date_commitment,
                       select_header.invoicing_rule,
                       select_header.bank_acct_name,
                       select_header.deposit_date,
                       select_header.factor_disc_amount,
                       select_header.int_hdr_context,
                       select_header.int_hdr_attr1,
                       select_header.int_hdr_attr2,
                       select_header.int_hdr_attr3,
                       select_header.int_hdr_attr4,
                       select_header.int_hdr_attr5,
                       select_header.int_hdr_attr6,
                       select_header.int_hdr_attr7,
                       select_header.int_hdr_attr8,
                       select_header.int_hdr_attr9,
                       select_header.int_hdr_attr10,
                       select_header.int_hdr_attr11,
                       select_header.int_hdr_attr12,
                       select_header.int_hdr_attr13,
                       select_header.int_hdr_attr14,
                       select_header.int_hdr_attr15,
                       select_header.bank_deposit_no,
                       select_header.reference_type,
                       select_header.reference_id,
                       select_header.cust_rcpt_reference,
                       select_header.bank_acct_name2
                     ) ;

                     -- bug1199027
                     l_status := ins_control_detail_table ( NVL(select_header.acctd_amount,0),
                                                           select_header.type,
                                                           NVL(select_header.open_receivable,'Y'),
                                                           l_period_name,
                                                           p_archive_id  ) ;

                     IF select_header.type = 'CASH'
                     THEN
                        l_total_discount := NVL(select_header.acctd_earned_disc_taken,0) +
                                                 NVL(select_header.acctd_unearned_disc_taken,0);
                        IF l_total_discount IS NOT NULL
                        THEN
                            -- bug1199027
                            l_status := ins_control_detail_table ( l_total_discount,
                                                                  'DISC',
                                                                  NVL(select_header.open_receivable,'Y'),
                                                                  l_period_name,
                                                                  p_archive_id  ) ;
                        END IF ;
                        --
                        IF select_header.exch_gain_loss IS NOT NULL
                        THEN
                            -- bug1199027
                            l_status := ins_control_detail_table ( select_header.exch_gain_loss,
                                                                  'EXCH',
                                                                  NVL(select_header.open_receivable,'Y'),
                                                                  l_period_name,
                                                                  p_archive_id  ) ;
                        END IF ;
                     END IF ;

                 EXCEPTION
                     WHEN OTHERS THEN
                         print( 1, 'Failed while inserting into AR_ARCHIVE_HEADER') ;
                         print( 1, 'sqlcode = ' || SQLCODE || SQLERRM ) ;
                         RAISE ;
                 END ;

            END LOOP ;

            RETURN ( TRUE );

        EXCEPTION
            WHEN OTHERS THEN
                print( 1, '  ...Failed while inserting into AR_ARCHIVE_HEADER');
                print( 1, 'sqlcode = ' || SQLCODE || SQLERRM ) ;
                RAISE ;
        END ;
    END ;

    --
    -- Insert into archive_detail
    --
    FUNCTION archive_detail( p_customer_trx_id IN NUMBER     ,
                             p_archive_level   IN VARCHAR2   ,
                             p_archive_id      IN NUMBER     ) RETURN BOOLEAN  IS
        CURSOR detail_cursor ( cp_customer_trx_id NUMBER ,
                               cp_archive_level   VARCHAR2 ,
                               cp_org_profile     VARCHAR2 ) IS
        SELECT
        ctt.type       trx_class,			/* transaction_class */
        ctt.name       trx_type,			/* transaction_type */
        ct.customer_trx_id trx_id, 		/* transaction_id */
        ctl.customer_trx_line_id line_id,	/* transaction_line_id */
        decode(ctt.type, 		/* related_transaction_class */
            'CM', ctt_prev.type) related_trx_class,
        decode(ctt.type,'CM', ctt_prev.name)
            related_trx_type,	/* related_transaction_type */
        decode(ctt.type,'CM', ct.previous_customer_trx_id)
            related_trx_id,	/* related_transaction_id */
        decode(ctt.type, 'CM', ctl.previous_customer_trx_line_id)
            related_trx_line_id,  /* related_transaction_line_id */
        ctl.line_number line_number,
        'LINE' dist_type, 			/* distribution_type */
        '' app_type,				/* application_type */
        lu_line.meaning line_code_meaning,		/* line_code_meaning */
        ctl.description description,
        /* item_name */
        rtrim( mtl.segment1 || '.' ||
            mtl.segment2 || '.' ||
            mtl.segment3 || '.' ||
            mtl.segment4 || '.' ||
            mtl.segment5 || '.' ||
            mtl.segment6 || '.' ||
            mtl.segment7 || '.' ||
            mtl.segment8 || '.' ||
            mtl.segment9 || '.' ||
            mtl.segment10|| '.' ||
            mtl.segment11|| '.' ||
            mtl.segment12|| '.' ||
            mtl.segment13|| '.' ||
            mtl.segment14|| '.' ||
            mtl.segment15|| '.' ||
            mtl.segment16|| '.' ||
            mtl.segment17|| '.' ||
            mtl.segment18|| '.' ||
            mtl.segment19|| '.' ||
            mtl.segment20, '.' ) item_name,
        nvl(ctl.quantity_invoiced, ctl.quantity_credited) qty, /* qty */
        ctl.unit_selling_price selling_price,
        ctl.line_type line_type,
        ctl.attribute_category attr_category,
        ctl.attribute1 attr1,
        ctl.attribute2 attr2,
        ctl.attribute3 attr3,
        ctl.attribute4 attr4,
        ctl.attribute5 attr5,
        ctl.attribute6 attr6,
        ctl.attribute7 attr7,
        ctl.attribute8 attr8,
        ctl.attribute9 attr9,
        ctl.attribute10 attr10,
        ctl.attribute11 attr11,
        ctl.attribute12 attr12,
        ctl.attribute13 attr13,
        ctl.attribute14 attr14,
        ctl.attribute15 attr15,
        ctl.extended_amount amount,		        /* amount */
        to_number('') acctd_amount,			/* acctd_amount */
        ctl.uom_code uom_code,
        '' ussgl_trx_code,				/* ussgl_transaction_code */
        ctl.tax_rate tax_rate,
        vt.tax_code tax_code,
        ctl.tax_precedence tax_precedence,
        to_number('') ccid1,  	/* account_ccid1 */
        to_number('') ccid2, 	/* account_ccid2 */
        to_number('') ccid3, 	/* account_ccid3 */
        to_number('') ccid4, 	/* account_ccid4 */
        to_date(NULL) gl_date,	/* gl_date */
        to_date(NULL) gl_posted_date, /* gl_posted_date */
        rule1.name rule_name,	    /* accounting_rule_name */
        ctl.accounting_rule_duration acctg_rule_duration,
        ctl.rule_start_date rule_start_date,
        ctl.last_period_to_credit last_period_to_credit,
        '' line_comment,  	/* line_comment */
        to_number('') line_adjusted,	/* line_adjusted */
        to_number('') freight_adjusted, /* freight_adjusted */
        to_number('') tax_adjusted,	/* tax_adjusted */
        to_number('') charges_adjusted, /* receivables_charges_adjusted */
        to_number('') line_applied,	/* line_applied */
        to_number('') freight_applied,	/* freight_applied */
        to_number('') tax_applied,	/* tax_applied */
        to_number('') charges_applied,	/* receivables_charges_applied */
        to_number('') earned_disc_taken,/* earned_discount_taken */
        to_number('') unearned_disc_taken,      /* unearned_discount_taken */
        to_number('') acctd_amount_applied_from,/* acctd_amount_applied_from */
        to_number('') acctd_amount_applied_to,	/* acctd_amount_applied_to */
        to_number('') acctd_earned_disc_taken,	/* acctd_earned_disc_taken */
        to_number('') acctd_unearned_disc_taken,	/* acctd_unearned_disc_taken */
        to_number('') factor_discount_amount,	/* factor_discount_amount */
        to_number('') acctd_factor_discount_amount,	/* acctd_factor_discount_amount */
        ctl.interface_line_context int_line_context,
        ctl.interface_line_attribute1 int_line_attr1,
        ctl.interface_line_attribute2 int_line_attr2,
        ctl.interface_line_attribute3 int_line_attr3,
        ctl.interface_line_attribute4 int_line_attr4,
        ctl.interface_line_attribute5 int_line_attr5,
        ctl.interface_line_attribute6 int_line_attr6,
        ctl.interface_line_attribute7 int_line_attr7,
        ctl.interface_line_attribute8 int_line_attr8,
        ctl.interface_line_attribute9 int_line_attr9,
        ctl.interface_line_attribute10 int_line_attr10,
        ctl.interface_line_attribute11 int_line_attr11,
        ctl.interface_line_attribute12 int_line_attr12,
        ctl.interface_line_attribute13 int_line_attr13,
        ctl.interface_line_attribute14 int_line_attr14,
        ctl.interface_line_attribute15 int_line_attr15,
        '' exch_rate_type,			/* exchange_rate_type */
        to_date(NULL) exch_date,			/* exchange_rate_date */
        to_number('') exch_rate, 		/* exchange_rate */
        to_date(NULL) due_date,			/* due_date */
        to_date(NULL) apply_date,			/* apply_date */
        ctl.movement_id movement_id,
        ctl.tax_vendor_return_code vendor_return_code,
        /* tax_authorities_tax_rate */
        rtrim( to_char(st.location1_rate) || ' ' ||
        to_char(st.location2_rate) || ' ' ||
        to_char(st.location3_rate) || ' ' ||
        to_char(st.location4_rate) || ' ' ||
        to_char(st.location5_rate) || ' ' ||
        to_char(st.location6_rate) || ' ' ||
        to_char(st.location7_rate) || ' ' ||
        to_char(st.location8_rate) || ' ' ||
        to_char(st.location9_rate) || ' ' ||
        to_char(st.location10_rate), ' ' ) tax_auth_tax_rate,
        ctl.tax_exempt_flag tax_exempt_flag,
        ctl.tax_exemption_id tax_exemption_id,
        te.exemption_type exemption_type,
        nvl(lu_te.meaning, lu_line2.meaning) tax_exemption_reason,/* tax_exemption_reason */
        nvl(te.customer_exemption_number, ctl.tax_exempt_number)
             tax_exemption_number, /* tax_exemption_number */
        /* item_exception_rate */
        rtrim( to_char(ier.location1_rate) || ' ' ||
        to_char(ier.location2_rate) || ' ' ||
        to_char(ier.location3_rate) || ' ' ||
        to_char(ier.location4_rate) || ' ' ||
        to_char(ier.location5_rate) || ' ' ||
        to_char(ier.location6_rate) || ' ' ||
        to_char(ier.location7_rate) || ' ' ||
        to_char(ier.location8_rate) || ' ' ||
        to_char(ier.location9_rate) || ' ' ||
        to_char(ier.location10_rate), ' ' ) item_exception_rate ,
        lu_ier.meaning meaning,			/* exception_reason */
        dl.original_collectibility_flag,      /* original_collectibility_flag */
        dl.line_collectible_flag,             /* line_collectible_flag */
        dl.manual_override_flag,              /* manual_override_flag */
        ''   contingency_code,  	/* contingency_code */
        to_date(null) expiration_date,  /* expiration_date */
        to_number('') expiration_days,  /* expiration_days */
        ctl.override_auto_accounting_flag	/* override_auto_accounting_flag */
        FROM
        ar_lookups lu_te,
        ra_tax_exemptions te,
        ar_lookups lu_ier,
        ra_item_exception_rates ier,
        ar_sales_tax      st,
        ar_vat_tax        vt,
        ar_lookups        lu_line,
        ar_lookups        lu_line2,
        ra_rules          rule1,
        ra_cust_trx_types ctt_prev,
        ra_cust_trx_types ctt,
        mtl_system_items  mtl,
        ra_customer_trx_lines    ctl,
        ra_customer_trx   ct_prev,
        ra_customer_trx   ct,
	ar_deferred_lines dl
        WHERE te.tax_exemption_id (+) = ctl.tax_exemption_id
        AND   te.reason_code = lu_te.lookup_code (+)
        AND   lu_te.lookup_type (+) = 'TAX_REASON'
        AND   ier.item_exception_rate_id (+) = ctl.item_exception_rate_id
        AND   ier.reason_code = lu_ier.lookup_code (+)
        AND   lu_ier.lookup_type (+) = 'TAX_EXCEPTION_REASON'
        AND   st.sales_tax_id (+)    = ctl.sales_tax_id
        AND   vt.vat_tax_id (+)      = ctl.vat_tax_id
        AND   lu_line.lookup_code (+)    = ctl.reason_code
        AND   lu_line.lookup_type (+)    = 'INVOICING_REASON'
        AND   lu_line2.lookup_code (+)    = ctl.tax_exempt_reason_code
        AND   lu_line2.lookup_type (+)    = 'TAX_REASON'
        AND   rule1.rule_id (+)        = ctl.accounting_rule_id
        AND   ctt.cust_trx_type_id    = ct.cust_trx_type_id
        AND   mtl.inventory_item_id (+) = ctl.inventory_item_id
        AND   mtl.organization_id (+) = to_number(cp_org_profile)
        AND   ctl.customer_trx_id = ct.customer_trx_id
        AND   ct.previous_customer_trx_id = ct_prev.customer_trx_id(+)
        AND   ct_prev.cust_trx_type_id = ctt_prev.cust_trx_type_id(+)
        AND   ct.customer_trx_id     = cp_customer_trx_id
        AND   cp_archive_level <> 'H'
        AND   ctl.customer_trx_line_id = dl.customer_trx_line_id(+)
        UNION ALL /* Bug 5105156 - fix 5044763 */
        ---------------------------------------------------------------------
        -- TRX distributions
        -- 'A' level only
        ---------------------------------------------------------------------
        SELECT
        ctt.type trx_class,			/* transaction_class */
        ctt.name trx_type,			/* transaction_type */
        ct.customer_trx_id trx_id, 		/* transaction_id */
        ctlgd.customer_trx_line_id line_id,	/* transaction_line_id */
        '' related_trx_class,			/* related_transaction_class */
        '' related_trx_type,			/* related_transaction_type */
        to_number('') related_trx_id, 		/* related_transaction_id */
        to_number('') related_trx_line_id,	/* related_transaction_line_id */
        to_number('') line_number,		/* line_number */
        ctlgd.account_class dist_type, 		/* distribution_type */
        '' app_type,				/* application_type */
        '' line_code_meaning, 			/* line_code_meaning */
        '' description,                         /* description */
        '' item_name,                           /* item_name */
        to_number('') qty, 			/* qty */
        to_number('') selling_price,		/* unit_selling_price */
        '' line_type,				/* line_type */
        ctlgd.attribute_category attr_category,
        ctlgd.attribute1 attr1,
        ctlgd.attribute2 attr2,
        ctlgd.attribute3 attr3,
        ctlgd.attribute4 attr4,
        ctlgd.attribute5 attr5,
        ctlgd.attribute6 attr6,
        ctlgd.attribute7 attr7,
        ctlgd.attribute8 attr8,
        ctlgd.attribute9 attr9,
        ctlgd.attribute10 attr10,
        ctlgd.attribute11 attr11,
        ctlgd.attribute12 attr12,
        ctlgd.attribute13 attr13,
        ctlgd.attribute14 attr14,
        ctlgd.attribute15 attr15,
        ctlgd.amount amount,
        ctlgd.acctd_amount acctd_amount,
        '' uom_code,		 /* uom code */
        ctlgd.ussgl_transaction_code ussgl_trx_code,
        to_number('') tax_rate,			/* tax_rate */
        '' tax_code, 				/* tax_code */
        to_number('') tax_precedence,		/* tax_precedence */
        ctlgd.code_combination_id ccid1,        /* account_ccid1 */
        to_number('') ccid2, 		/* account_ccid2 */
        to_number('') ccid3, 		/* account_ccid3 */
        to_number('') ccid4, 		/* account_ccid4 */
        nvl(ctlgd.gl_date, ct.trx_date) gl_date,/* gl_date */
        ctlgd.gl_posted_date gl_posted_date,	/* gl_posted_date */
        '' acctg_rule_name,			/* accounting_rule_name */
        to_number('') acctg_rule_duration,	/* accounting_rule_duration */
        to_date(NULL) rule_start_date,		/* rule_start_date */
        to_number('') last_period_to_credit,	/* last_period_to_credit */
        '' line_amount,  			/* line_comment */
        to_number('') line_adjusted,		/* line_adjusted */
        to_number('') freight_adjusted,	        /* freight_adjusted */
        to_number('') tax_adjusted,		/* tax_adjusted */
        to_number('') charges_adjusted,	        /* receivables_charges_adjusted */
        to_number('') line_applied,		/* line_applied */
        to_number('') freight_applied,		/* freight_applied */
        to_number('') tax_applied,		/* tax_applied */
        to_number('') charges_applied,		/* receivables_charges_applied */
        to_number('') earned_disc_taken,	/* earned_discount_taken */
        to_number('') unearned_disc_taken,	/* unearned_discount_taken */
        to_number('') acctd_amount_applied_from,/* acctd_amount_applied_from */
        to_number('') acctd_amount_applied_to,	/* acctd_amount_applied_to */
        to_number('') acctd_earned_disc_taken,	/* acctd_earned_disc_taken */
        to_number('') acctd_unearned_disc_taken,/* acctd_unearned_disc_taken */
        to_number('') factor_discount_amount,	/* factor_discount_amount */
        to_number('') acctd_factor_discount_amount,/* acctd_factor_discount_amount */
        '' int_line_context, /* interface_line_context */
        '' int_line_attr1,   /* interface_line_attribute1 */
        '' int_line_attr2,   /* interface_line_attribute2 */
        '' int_line_attr3,   /* interface_line_attribute3 */
        '' int_line_attr4,   /* interface_line_attribute4 */
        '' int_line_attr5,   /* interface_line_attribute5 */
        '' int_line_attr6,   /* interface_line_attribute6 */
        '' int_line_attr7,   /* interface_line_attribute7 */
        '' int_line_attr8,   /* interface_line_attribute8 */
        '' int_line_attr9,		/* interface_line_attribute9 */
        '' int_line_attr10,		/* interface_line_attribute10 */
        '' int_line_attr11,		/* interface_line_attribute11 */
        '' int_line_attr12,		/* interface_line_attribute12 */
        '' int_line_attr13,		/* interface_line_attribute13 */
        '' int_line_attr14,		/* interface_line_attribute14 */
        '' int_line_attr15,		/* interface_line_attribute15 */
        '' exchange_rate_type,		/* exchange_rate_type */
        to_date(NULL) exch_date,		/* exchange_rate_date */
        to_number('') exch_rate, 	/* exchange_rate */
        to_date(NULL) due_date,		/* due_date */
        to_date(NULL) apply_date,	        /* apply_date */
        to_number('') movement_id,	/* movement_id */
        '' tax_vendor_return_code,	/* tax_vendor_return_code */
        '' tax_auth_tax_rate,  	        /* tax_authorities_tax_rate */
        '' tax_exempt_flag,		/* tax_exemption_flag */
        to_number('') tax_exemption_id, /* tax_exemption_id */
        '' exemption_type,		/* exemption_type */
        '' tax_exemption_reason,	/* exemption_reason */
        '' tax_exemption_number,	/* customer_exemption_number */
        '' item_exception_rate,  	/* item_exception_rate */
        '' meaning,			/* exception_reason */
        '',                             /* original_collectibility_flag */
        '',                             /* line_collectible_flag */
        '',                             /* manual_override_flag */
        '',                             /* contingency_code */
        to_date(null),                  /* expiration_date */
        to_number(null),                /* expiration_days */
	''			/* override_auto_accounting_flag */
        FROM
        ra_cust_trx_types ctt,
        ra_cust_trx_line_gl_dist ctlgd,
        ra_customer_trx   ct
        WHERE  ctt.cust_trx_type_id  = ct.cust_trx_type_id
        AND    ctlgd.customer_trx_id = ct.customer_trx_id
        AND    ctlgd.account_set_flag <> 'Y'  /* no acount sets */
        AND    decode(ctlgd.account_class, 'REC',
                   ctlgd.latest_rec_flag, 'Y') = 'Y'
        AND    ct.customer_trx_id     = cp_customer_trx_id
        AND    cp_archive_level = 'A'
        UNION ALL /* Bug 5105156 - fix 5044763 */
        ---------------------------------------------------------------------
               -- TRX adjustments (ADJ)
               -- 'L', 'A' levels
        ---------------------------------------------------------------------
        SELECT
        'ADJ' trx_class,  	        /* transaction_class */
        ''    trx_type,    	        /* transaction_type */
        adj.adjustment_id trx_id, 	/* transaction_id */
        to_number('') line_id,		/* transaction_line_id */
        ctt.type related_trx_class,		/* related_transaction_class */
        ctt.name related_trx_type,		/* related_transaction_type */
        ct.customer_trx_id related_trx_id, 	/* related_transaction_id */
        to_number('') related_trx_line_id,		/* related_transaction_line_id */
        to_number('') line_number, 	/* line_number */
        'ADJ' dist_type, 		/* distribution_type */
        '' app_type,			/* application_type */
        '' line_code_meaning, 			/* line_code_meaning */
        '' description,			/* description */
        '' item_name,			/* item_name */
        to_number('') qty,		/* quantity */
        to_number('') selling_price,	/* unit_selling_price */
        '' line_type,			/* line_type */
        adj.attribute_category attr_category,
        adj.attribute1 attr1,
        adj.attribute2 attr2,
        adj.attribute3 attr3,
        adj.attribute4 attr4,
        adj.attribute5 attr5,
        adj.attribute6 attr6,
        adj.attribute7 attr7,
        adj.attribute8 attr8,
        adj.attribute9 attr9,
        adj.attribute10 attr10,
        adj.attribute11 attr11,
        adj.attribute12 attr12,
        adj.attribute13 attr13,
        adj.attribute14 attr14,
        adj.attribute15 attr15,
        adj.amount amount,
        adj.acctd_amount acctd_amount,
        '' uom_code,		/* uom_code */
        '' ussgl_trx_code,	/* ussgl_transaction_code */
        to_number('') tax_rate,/* tax_rate */
        '' tax_code,		/* tax_code */
        to_number('') tax_precedence,	/* tax_precedence */
        adj.code_combination_id ccid1, 	/* account_ccid1 */
        to_number('') ccid2,	/* account_ccid2 */
        to_number('') ccid3,	/* account_ccid3 */
        to_number('') ccid4,	/* account_ccid4 */
        adj.gl_date gl_date,
        adj.gl_posted_date gl_posted_date,
        '' acctg_rule_duration,	/* acct_rule_name */
        to_number('') rule_name, /* rule_duration */
        to_date(NULL) rule_start_date,	/* rule_start_date */
        to_number('') last_period_to_credit,	/* last_period_to_credit */
        '' line_comment,  		/* line_comment */
        adj.line_adjusted line_adjusted,	/* line_adjusted */
        adj.freight_adjusted freight_adjusted,	/* freight_adjusted */
        adj.tax_adjusted tax_adjusted,	/* tax_adjusted */
        adj.receivables_charges_adjusted charges_adjusted, /* receivables_charges_adjusted */
        to_number('') line_applied,		/* line_applied */
        to_number('') freight_applied,		/* freight_applied */
        to_number('') tax_applied,		/* tax_applied */
        to_number('') charges_applied,		/* receivables_charges_applied */
        to_number('') earned_disc_taken,	/* earned_discount_taken */
        to_number('') unearned_disc_taken,	/* unearned_discount_taken */
        to_number('') acctd_amount_applied_from,/* acctd_amount_applied_from */
        to_number('') acctd_amount_applied_to,	 /* acctd_amount_applied_to */
        to_number('') acctd_earned_disc_taken,		/* acctd_earned_disc_taken */
        to_number('') acctd_unearned_disc_taken,	/* acctd_unearned_disc_taken */
        to_number('') factor_discount_amount,		/* factor_discount_amount */
        to_number('') acctd_factor_discount_amount,	/* acctd_factor_discount_amount */
        '' int_line_context,  	/* interface_line_context */
        '' int_line_attr1,  	/* interface_line_attribute1 */
        '' int_line_attr2,  	/* interface_line_attribute2 */
        '' int_line_attr3,   	/* interface_line_attribute3 */
        '' int_line_attr4,  	/* interface_line_attribute4 */
        '' int_line_attr5,  	/* interface_line_attribute5 */
        '' int_line_attr6,   	/* interface_line_attribute6 */
        '' int_line_attr7,   	/* interface_line_attribute7 */
        '' int_line_attr8,   	/* interface_line_attribute8 */
        '' int_line_attr9,   	/* interface_line_attribute9 */
        '' int_line_attr10,   	/* interface_line_attribute10 */
        '' int_line_attr11,   	/* interface_line_attribute11 */
        '' int_line_attr12,   	/* interface_line_attribute12 */
        '' int_line_attr13,   	/* interface_line_attribute13 */
        '' int_line_attr14,   	/* interface_line_attribute14 */
        '' int_line_attr15,    /* interface_line_attribute15 */
        '' exch_rate_type, 	/* exchange_rate_type */
        to_date(NULL) exch_date,	/* exchange_rate_date */
        to_number('') exch_rate,/* exchange_rate */
        to_date(NULL) due_date,		/* due_date */
        to_date(NULL) apply_date,	/* apply_date */
        to_number('') movement_id,	/* movement_id */
        '' vendor_return_code,		/* tax_vendor_return_code */
        '' tax_auth_tax_rate,		/* tax_authority_tax_rates */
        '' tax_exempt_flag,		/* tax_exemption_flag */
        to_number('') tax_exemption_id,/* tax_exemption_id */
        '' exemption_type,		/* exemption_type */
        '' tax_exemption_reason,	/* exemption_reason */
        '' tax_exemption_number,	/* customer_exemption_number */
        '' item_exception_rate,	/* item_exception_rate */
        '' meaning,			/* item_exception_reason */
        '',                             /* original_collectibility_flag */
        '',                             /* line_collectible_flag */
        '',                             /* manual_override_flag */
        '',                             /* contingency_code */
        to_date(null),                  /* expiration_date */
        to_number(null),                /* expiration_days */
	''			/* override_auto_accounting_flag */
        FROM   ra_cust_trx_types ctt,
               ra_customer_trx   ct,
               ar_adjustments    adj
        WHERE  adj.customer_trx_id     = cp_customer_trx_id
        and    adj.customer_trx_id     = ct.customer_trx_id
        and    ctt.cust_trx_type_id    = ct.cust_trx_type_id
        and    cp_archive_level <> 'H'
	UNION ALL /* Bug 5105156 - fix 5044763 */
	---------------------------------------------------------------------
        -- TRX contingencies (CONTINGENCY)
        -- 'L', 'A' levels
	---------------------------------------------------------------------
	SELECT
	'CONTINGENCY',			/* transaction_class */
	'', 				/* transaction_type */
	ctl.customer_trx_id,		/* transaction_id */
	ctl.customer_trx_line_id,	/* transaction_line_id */
	'',				/* related_transaction_class */
	'',				/* related_transaction_type */
	to_number(''),			/* related_transaction_id */
	to_number(''),			/* related_transaction_line_id */
	to_number(''), 			/* line_number */
	'', 				/* distribution_type */
        '',				/* application_type */
	'', 				/* line_code_meaning */
	'',				/* description */
	'',				/* item_name */
	to_number(''),			/* quantity */
	to_number(''),			/* unit_selling_price */
	'',				/* line_type */
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	to_number(''),
	to_number(''),
	'',				/* uom_code */
	'',				/* ussgl_transaction_code */
	to_number(''),			/* tax_rate */
	'',				/* tax_code */
	to_number(''),			/* tax_precedence */
	to_number(''), 			/* account_ccid1 */
	to_number(''),			/* account_ccid2 */
	to_number(''),			/* account_ccid3 */
	to_number(''),			/* account_ccid4 */
	to_date(null),
	to_date(null),
        '',				/* acct_rule_name */
        to_number(''), 			/* rule_duration */
        to_date(null),			/* rule_start_date */
        to_number(''),			/* last_period_to_credit */
        '',  				/* line_comment */
	to_number(''),			/* line_adjusted */
	to_number(''),			/* freight_adjusted */
	to_number(''),			/* tax_adjusted */
	to_number(''),			/* receivables_charges_adjusted */
	to_number(''),			/* line_applied */
	to_number(''),			/* freight_applied */
	to_number(''),			/* tax_applied */
	to_number(''),			/* receivables_charges_applied */
	to_number(''),			/* earned_discount_taken */
	to_number(''),			/* unearned_discount_taken */
	to_number(''),			/* acctd_amount_applied_from */
	to_number(''),			/* acctd_amount_applied_to */
	to_number(''),			/* acctd_earned_disc_taken */
	to_number(''),			/* acctd_unearned_disc_taken */
	to_number(''),			/* factor_discount_amount */
	to_number(''),			/* acctd_factor_discount_amount */
	'',  				/* interface_line_context */
	'',  				/* interface_line_attribute1 */
	'',  				/* interface_line_attribute2 */
	'',   				/* interface_line_attribute3 */
	'',  				/* interface_line_attribute4 */
	'',  				/* interface_line_attribute5 */
	'',   				/* interface_line_attribute6 */
	'',   				/* interface_line_attribute7 */
	'',   				/* interface_line_attribute8 */
	'',   				/* interface_line_attribute9 */
	'',   				/* interface_line_attribute10 */
	'',   				/* interface_line_attribute11 */
	'',   				/* interface_line_attribute12 */
	'',   				/* interface_line_attribute13 */
	'',   				/* interface_line_attribute14 */
	'',    				/* interface_line_attribute15 */
	'', 				/* exchange_rate_type */
	to_date(null),			/* exchange_rate_date */
        to_number(''),  		/* exchange_rate */
	to_date(null),			/* due_date */
	to_date(null),			/* apply_date */
        to_number(''),			/* movement_id */
        '',				/* tax_vendor_return_code */
        '',				/* tax_authority_tax_rates */
        '',				/* tax_exemption_flag */
        to_number(''),			/* tax_exemption_id */
        '',				/* exemption_type */
        '',				/* exemption_reason */
        '',				/* customer_exemption_number */
        '',				/* item_exception_rate */
        '', 				/* item_exception_reason */
	'',				/* original_collectibility_flag */
	'',				/* line_collectible_flag */
	'',				/* manual_override_flag */
	lc.contingency_code,		/* contingency_code */
	lc.expiration_date, 		/* expiration_date */
	lc.expiration_days,		/* expiration_days */
	''			/* override_auto_accounting_flag */
	FROM
        ra_customer_trx_lines ctl,
        ar_line_conts lc
	WHERE   cp_customer_trx_id    = ctl.customer_trx_id
	and	ctl.customer_trx_line_id   = lc.customer_trx_line_id
        and     cp_archive_level <> 'H'
        UNION ALL /* Bug 5105156 - fix 5044763 */
        ---------------------------------------------------------------------
        -- REC information (CRH)
        -- all levels
        ---------------------------------------------------------------------
        SELECT
        cr.type trx_class,			/* transaction_class */
        '' trx_type,				/* transaction_type */
        cr.cash_receipt_id trx_id,		/* transaction_id */
        to_number('') line_id,			/* transaction_line_id */
        '' related_trx_class,			/* related_transaction_class */
        '' related_trx_type,			/* related_transaction_type */
        to_number('') related_trx_id,		/* related_transaction_id */
        to_number('') related_trx_line_id,	/* related_transaction_line_id */
        to_number('') line_number,  		/* line_number */
        'CRH' dist_type, 			/* distribution_type */
        '' app_type,				/* application_type */
        '' line_code_meaning,  		/* line_code_meaning */
        '' description,			/* description */
        '' item_name,				/* item_name */
        to_number('') qty,			/* quantity */
        to_number('') selling_price,			/* unit_selling_price */
        '' line_type,				/* line_type */
        crh.attribute_category attr_category,
        crh.attribute1 attr1,
        crh.attribute2 attr2,
        crh.attribute3 attr3,
        crh.attribute4 attr4,
        crh.attribute5 attr5,
        crh.attribute6 attr6,
        crh.attribute7 attr7,
        crh.attribute8 attr8,
        crh.attribute9 attr9,
        crh.attribute10 attr10,
        crh.attribute11 attr11,
        crh.attribute12 attr12,
        crh.attribute13 attr13,
        crh.attribute14 attr14,
        crh.attribute15 attr15,
        crh.amount amount,
        crh.acctd_amount acctd_amount,
        '' uom_code,  				/* uom code */
        cr.ussgl_transaction_code ussgl_trx_code,
        vt.tax_rate tax_rate,				/* tax_rate */
        vt.tax_code tax_code, 				/* tax_code */
        to_number('') tax_precedence,				/* tax_precedence */
        crh.account_code_combination_id ccid1,
        crh.bank_charge_account_ccid ccid2,
        to_number('') ccid3, 			/* account_ccid3 */
        to_number('') ccid4,  			/* account_ccid4 */
        crh.gl_date gl_date,
        crh.gl_posted_date gl_posted_date,
        '' rule_name, 				/* acct_rule_name */
        to_number('') acctg_rule_duration,  	/* rule_duration */
        to_date(NULL) rule_start_date,		/* rule_start_date */
        to_number('') last_period_to_credit, 	/* last_period_to_credit */
        '' line_comment, 			/* line_comment */
        to_number('') line_adjusted,		/* line_adjusted */
        to_number('') freight_adjusted,	/* freight_adjusted */
        to_number('') tax_adjusted,		/* tax_adjusted */
        to_number('') charges_adjusted,	/* receivables_charges_adjusted */
        to_number('') line_applied,		/* line_applied */
        to_number('') freight_applied,		/* freight_applied */
        to_number('') tax_applied,		/* tax_applied */
        to_number('') charges_adjusted,	/* receivables_charges_applied */
        to_number('') earned_disc_taken,	/* earned_discount_taken */
        to_number('') unearned_disc_taken,	/* unearned_discount_taken */
        to_number('') acctd_amount_applied_from,/* acctd_amount_applied_from */
        to_number('') acctd_amount_applied_to,	/* acctd_amount_applied_to */
        to_number('') acctd_earned_disc_taken,	/* acctd_earned_disc_taken */
        to_number('') acctd_unearned_disc_taken,/* acctd_unearned_disc_taken */
        crh.factor_discount_amount factor_discount_amount,
                /* factor_discount_amount */
        crh.acctd_factor_discount_amount acctd_factor_discount_amount,
                /* acctd_factor_discount_amount */
         '' int_line_context,    	/* interface_line_context */
         '' int_line_attr1,   		/* interface_line_attribute1 */
         '' int_line_attr2,    	/* interface_line_attribute2 */
         '' int_line_attr3,    	/* interface_line_attribute3 */
         '' int_line_attr4,   		/* interface_line_attribute4 */
         '' int_line_attr5,   		/* interface_line_attribute5 */
         '' int_line_attr6,   		/* interface_line_attribute6 */
         '' int_line_attr7,    	/* interface_line_attribute7 */
         '' int_line_attr8,   		/* interface_line_attribute8 */
         '' int_line_attr9,    	/* interface_line_attribute9 */
         '' int_line_attr10,   	/* interface_line_attribute10 */
         '' int_line_attr11,   	/* interface_line_attribute11 */
         '' int_line_attr12,   	/* interface_line_attribute12 */
         '' int_line_attr13,   	/* interface_line_attribute13 */
         '' int_line_attr14,   	/* interface_line_attribute14 */
         '' int_line_attr15,   		/* interface_line_attribute15 */
         crh.exchange_rate_type exch_rate_type,
         crh.exchange_date exch_date,
         crh.exchange_rate exch_rate,
         to_date(NULL) due_date,			/* due_date */
         to_date(NULL) apply_date,		/* apply_date */
         to_number('') movement_id,		/* movement_id */
         '' vendor_return_code,		/* tax_vendor_return_code */
         '' tax_auth_tax_rate,			/* tax_authority_tax_rates */
         '' tax_exempt_flag,			/* tax_exemption_flag */
         to_number('') tax_exemption_id,	/* tax_exemption_id */
         '' exemption_type,			/* exemption_type */
         '' tax_exemption_reason,		/* exemption_reason */
         '' tax_exemption_number,		/* customer_exemption_number */
         '' item_exception_rate,		/* item_exception_rate */
         '' meaning,                            /* item_exception_reason */
         '',                             /* original_collectibility_flag */
         '',                             /* line_collectible_flag */
         '',                             /* manual_override_flag */
         '',                             /* contingency_code */
         to_date(null),                  /* expiration_date */
         to_number(null),                /* expiration_days */
	 ''			 /* override_auto_accounting_flag */
         FROM
         ar_vat_tax vt,
         ar_cash_receipt_history crh,
         ar_cash_receipts  cr ,
         ar_receivable_applications ra
         WHERE  crh.cash_receipt_id     = cr.cash_receipt_id
         and	nvl(crh.current_record_flag, 'N') = 'Y'
         and    cr.vat_tax_id = vt.vat_tax_id (+)
         and 	cr.cash_receipt_id     = ra.cash_receipt_id
         and    ra.applied_customer_trx_id = cp_customer_trx_id
        -- bug3567865 Don't insert duplicate cash record.
        and    not exists (
                  select 'already purged'
                    from ar_archive_detail aad
                   where aad.transaction_id = cr.cash_receipt_id
                     and aad.transaction_class = 'CASH' )
         UNION ALL /* Bug 5105156 - fix 5044763 */
         ---------------------------------------------------------------------
         -- REC_APP of
         -- all invoices pertaining to the receipt of the invoice
         ---------------------------------------------------------------------
         SELECT
         cr.type trx_class, 			/* transaction_class */
         '' trx_type,				/* transaction_type */
         cr.cash_receipt_id trx_id,		/* transaction_id */
         to_number('') line_id,			/* transaction_line_id */
         ctt.type related_trx_class,			/* related_transaction_class */
         ctt.name related_trx_type,			/* related_transaction_type */
         ct.customer_trx_id related_trx_id,		/* related_transaction_id */
         to_number('') related_trx_line_id,			/* related_transaction_line_id */
         to_number('') line_number,  			/* line_number */
         'REC_APP' dist_type, 			/* distribution_type */
         ra.application_type app_type,		/* application_type */
         '' line_code_meaning, 				/* line_code_meaning */
         '' description,				/* description */
         '' item_name,				/* item_name */
         to_number('') qty,			/* quantity */
         to_number('') selling_price,			/* unit_selling_price */
         '' line_type,				/* line_type */
         ra.attribute_category attr_category,
         ra.attribute1 attr1,
         ra.attribute2 attr2,
         ra.attribute3 attr3,
         ra.attribute4 attr4,
         ra.attribute5 attr5,
         ra.attribute6 attr6,
         ra.attribute7 attr7,
         ra.attribute8 attr8,
         ra.attribute9 attr9,
         ra.attribute10 attr10,
         ra.attribute11 attr11,
         ra.attribute12 attr12,
         ra.attribute13 attr13,
         ra.attribute14 attr14,
         ra.attribute15 attr15,
         ra.amount_applied amount, /* amount */
         to_number('') acctd_amount,			/* acctd_amount */
         '' uom_code,  					/* uom code */
         cr.ussgl_transaction_code ussgl_trx_code,
         to_number('') tax_rate,		/* tax_rate */
         '' tax_code, 				/* tax_code */
         to_number('') tax_precedence,			/* tax_precedence */
         ra.code_combination_id ccid1,    /* account_ccid1 */
         to_number('') ccid2, 		   /* account_ccid2 */
         ra.earned_discount_ccid ccid3,   /* account_ccid3 */
         ra.unearned_discount_ccid ccid4, /* account_ccid4 */
         ra.gl_date gl_date,
         ra.gl_posted_date gl_posted_date,
         '' rule_name, 		    /* acct_rule_name */
         to_number('') acctg_rule_duration,/* rule_duration */
         to_date(NULL) rule_start_date,	    /* rule_start_date */
         to_number('') last_period_to_credit,  /* last_period_to_credit */
         ra.comments line_comment, 		/* line_comment */
         to_number('') line_adjusted,	        /* line_adjusted */
         to_number('') freight_adjusted,	/* freight_adjusted */
         to_number('') tax_adjusted,		/* tax_adjusted */
         to_number('') charges_adjusted,	/* receivables_charges_adjusted */
         ra.line_applied line_applied,		/* line_applied */
         ra.freight_applied freight_applied,	/* freight_applied */
         ra.tax_applied tax_applied,		/* tax_applied */
         ra.receivables_charges_applied charges_applied,/* receivables_charges_applied */
         ra.earned_discount_taken earned_disc_taken,	 /* earned_discount_taken */
         ra.unearned_discount_taken unearned_disc_taken,/* unearned_discount_taken */
         ra.acctd_amount_applied_from acctd_amount_applied_from,
                /* acctd_amount_applied_from */
         ra.acctd_amount_applied_to acctd_amount_applied_to,
                /* acctd_amount_applied_to */
         ra.acctd_earned_discount_taken acctd_earned_disc_taken,
                /* acctd_earned_disc_taken */
         ra.acctd_unearned_discount_taken acctd_unearned_disc_taken,
                /* acctd_unearned_disc_taken */
         to_number('') factor_discount_amount,	/* factor_discount_amount */
         to_number('') acctd_factor_discount_amount,/* acctd_factor_discount_amount */
         '' int_line_context,    		/* interface_line_context */
         '' int_line_attr1,   			/* interface_line_attribute1 */
         '' int_line_attr2,  			/* interface_line_attribute2 */
         '' int_line_attr3,   			/* interface_line_attribute3 */
         '' int_line_attr4,   			/* interface_line_attribute4 */
         '' int_line_attr5,   			/* interface_line_attribute5 */
         '' int_line_attr6,   			/* interface_line_attribute6 */
         '' int_line_attr7,   			/* interface_line_attribute7 */
         '' int_line_attr8,   			/* interface_line_attribute8 */
         '' int_line_attr9,   			/* interface_line_attribute9 */
         '' int_line_attr10,   		/* interface_line_attribute10 */
         '' int_line_attr11,   		/* interface_line_attribute11 */
         '' int_line_attr12,  			/* interface_line_attribute12 */
         '' int_line_attr13,  			/* interface_line_attribute13 */
         '' int_line_attr14,  			/* interface_line_attribute14 */
         '' int_line_attr15,    		/* interface_line_attribute15 */
         '' exch_rate_type,			/* exchange_rate_type */
         to_date(NULL) exch_date,  		/* exchange_date */
         to_number('') exch_rate,		/* exchange_rate */
         ps.due_date due_date,
         ra.apply_date apply_date,
         to_number('') movement_id,		/* movement_id */
         '' vendor_return_code,		/* tax_vendor_return_code */
         '' tax_auth_tax_rate,			/* tax_authority_tax_rates */
         '' tax_exempt_flag,			/* tax_exemption_flag */
         to_number('') tax_exemption_id,	/* tax_exemption_id */
         '' exemption_type,			/* exemption_type */
         '' tax_exemption_reason,              /* exemption_reason */
         '' tax_exemption_number,		/* customer_exemption_number */
         '' item_exception_rate,		/* item_exception_rate */
         '' meaning,		                /* item_exception_reason */
         '',                             /* original_collectibility_flag */
         '',                             /* line_collectible_flag */
         '',                             /* manual_override_flag */
         '',                             /* contingency_code */
         to_date(null),                  /* expiration_date */
         to_number(null),                /* expiration_days */
	 ''			 /* override_auto_accounting_flag */
         FROM
         ra_cust_trx_types ctt,
         ar_payment_schedules ps,
         ar_cash_receipts  cr,
         ar_receivable_applications ra,
         ra_customer_trx   ct
         WHERE   ctt.cust_trx_type_id    = ct.cust_trx_type_id
         and 	ps.payment_schedule_id (+) = ra.applied_payment_schedule_id
         and 	cr.cash_receipt_id     = ra.cash_receipt_id
         and 	ra.applied_customer_trx_id = ct.customer_trx_id
         and    exists ( SELECT 'x'
                         FROM   ar_receivable_applications ra1
                         WHERE  ra1.applied_customer_trx_id = cp_customer_trx_id
                         AND    ra1.cash_Receipt_id = ra.cash_receipt_id )
        -- bug3567865 Don't insert duplicate cash record.
        and    not exists (
                  select 'already purged'
                    from ar_archive_detail aad
                   where aad.transaction_id = cr.cash_receipt_id
                     and aad.transaction_class = 'CASH' )
         UNION ALL /* Bug 5105156 - fix 5044763 */
         ---------------------------------------------------------------------
         -- CM applications (CM_APP)
         -- all levels
         ---------------------------------------------------------------------
         SELECT
         ctt_cm.type trx_class,		/* transaction_class */
         ctt_cm.name trx_type,			/* transaction_type */
         ct_cm.customer_trx_id trx_id, 	/* transaction_id */
         to_number('') line_id,		/* transaction_line_id */
         ctt_inv.type related_trx_class,	/* related_transaction_class */
         ctt_inv.name related_trx_type,	/* related_transaction_type */
         ct_inv.customer_trx_id related_trx_id,/* related_transaction_id */
         to_number('') related_trx_line_id,	/* related_transaction_line_id */
         to_number('') line_number,		/* line_number */
         'CM_APP' dist_type, 			/* distribution_type */
         ra.application_type app_type,		/* application_type */
         '' line_code_meaning, 		/* line_code_meaning */
         '' description,
         '' item_name,			/* item_name */
         to_number('') qty,		/* quantity */
         to_number('') selling_price,	/* unit_selling_price */
         '' line_type,
         ra.attribute_category attr_category,
         ra.attribute1 attr1,
         ra.attribute2 attr2,
         ra.attribute3 attr3,
         ra.attribute4 attr4,
         ra.attribute5 attr5,
         ra.attribute6 attr6,
         ra.attribute7 attr7,
         ra.attribute8 attr8,
         ra.attribute9 attr9,
         ra.attribute10 attr10,
         ra.attribute11 attr11,
         ra.attribute12 attr12,
         ra.attribute13 attr13,
         ra.attribute14 attr14,
         ra.attribute15 attr15,
         ra.amount_applied,		/* amount */
         to_number('') acctd_amount,		/* acctd_amount */
         '' uom_code,
         '' ussgl_trx_code,
         to_number('') tax_rate,			/* tax_rate */
         '' tax_code,				/* tax_code */
         to_number('') tax_precedence,			/* tax_precedence */
         ra.code_combination_id ccid1,    /* account_ccid1 */
         to_number('') ccid2, 		   /* account_ccid2 */
         ra.unearned_discount_ccid ccid3, /* account_ccid3 */
         ra.earned_discount_ccid ccid4,
         ra.gl_date gl_date,
         ra.gl_posted_date gl_posted_date,
         '' rule_name, 		        /* acct_rule_name */
         to_number('') acctg_rule_duration,	/* rule_duration */
         to_date(NULL) rule_start_date,		/* rule_start_date */
         to_number('') last_period_to_credit, 	/* last_period_to_credit */
         ra.comments line_comment, 		/* line_comment */
         to_number('') line_adjusted,		/* line_adjusted */
         to_number('') freight_adjusted,	/* freight_adjusted */
         to_number('') tax_adjusted,		/* tax_adjusted */
         to_number('') charges_adjusted,	/* receivables_charges_adjusted */
         ra.line_applied line_applied,		/* line_applied */
         ra.freight_applied freight_applied,	/* freight_applied */
         ra.tax_applied tax_applied,		/* tax_applied */
         ra.receivables_charges_applied charges_applied,    /* receivables_charges_applied */
         ra.earned_discount_taken earned_disc_taken,	     /* earned_discount_taken */
         ra.unearned_discount_taken unearned_disc_taken,    /* unearned_discount_taken */
         ra.acctd_amount_applied_from acctd_amount_applied_from,
                /* acctd_amount_applied_from */
         ra.acctd_amount_applied_to acctd_amount_applied_to,
                /* acctd_amount_applied_to */
         ra.acctd_earned_discount_taken acctd_earned_disc_taken,
                /* acctd_earned_disc_taken */
         ra.acctd_unearned_discount_taken acctd_unearned_disc_taken,
                /* acctd_unearned_disc_taken */
         to_number('') factor_discount_amount,		/* factor_discount_amount */
         to_number('') acctd_factor_discount_amount,	/* acctd_factor_discount_amount */
         '' int_line_context,		/* interface_line_context */
         '' int_line_attr1,				/* interface_line_attribute1 */
         '' int_line_attr2,				/* interface_line_attribute2 */
         '' int_line_attr3,				/* interface_line_attribute3 */
         '' int_line_attr4,				/* interface_line_attribute4 */
         '' int_line_attr5,				/* interface_line_attribute5 */
         '' int_line_attr6,				/* interface_line_attribute6 */
         '' int_line_attr7,				/* interface_line_attribute7 */
         '' int_line_attr8,				/* interface_line_attribute8 */
         '' int_line_attr9,				/* interface_line_attribute9 */
         '' int_line_attr10,				/* interface_line_attribute10 */
         '' int_line_attr11,				/* interface_line_attribute11 */
         '' int_line_attr12,				/* interface_line_attribute12 */
         '' int_line_attr13,				/* interface_line_attribute13 */
         '' int_line_attr14,				/* interface_line_attribute14 */
         '' int_line_attr15,				/* interface_line_attribute15 */
         '' exch_rate_type, 				/* exchange_rate_type */
         to_date(NULL) exch_date,			/* exchange_rate_date */
         to_number('') exch_rate,		/* exchange_rate */
         to_date(NULL) due_date, 		/* due_date */
         ra.apply_date apply_date,
         to_number('') movement_id,		/* movement_id */
         '' vendor_return_code, 		/* tax_vendor_return_code */
         '' tax_auth_tax_rate,			/* tax_authority_tax_rates */
         '' tax_exempt_flag,			/* tax_exemption_flag */
         to_number('') tax_exemption_id,	/* tax_exemption_id */
         '' exemption_type, 			/* exemption_type */
         '' tax_exemption_reason,		/* reason_code */
         '' tax_exemption_number,		/* customer_exemption_number */
         '' item_exception_rate, 		/* item_exception_rate */
         '' meaning ,				/* item_exception_reason */
         '',                             /* original_collectibility_flag */
         '',                             /* line_collectible_flag */
         '',                             /* manual_override_flag */
         '',                             /* contingency_code */
         to_date(null),                  /* expiration_date */
         to_number(null),                /* expiration_days */
	 ''			 /* override_auto_accounting_flag */
         FROM
         ra_cust_trx_types ctt_cm,
         ra_customer_trx   ct_cm,
         ra_cust_trx_types ctt_inv,
         ar_receivable_applications ra,
         ra_customer_trx   ct_inv
         WHERE ctt_cm.cust_trx_type_id = ct_cm.cust_trx_type_id
         AND   ra.applied_customer_trx_id = ct_inv.customer_trx_id
         AND   ra.customer_trx_id = ct_cm.customer_trx_id
         -- bug3948805 removed
         -- AND   ct_cm.previous_customer_trx_id = ct_inv.customer_trx_id
         AND   ctt_inv.cust_trx_type_id = ct_inv.cust_trx_type_id
         AND   ctt_inv.type <> 'CM'
         -- bug3948805 added condition for ct_cm.customer_trx_id
         AND   ( ct_inv.customer_trx_id = cp_customer_trx_id
                 or   ct_cm.customer_trx_id = cp_customer_trx_id )

         UNION ALL /* Bug 5105156 - fix 5073245 starts */
         ---------------------------------------------------------------------
         -- REC_WRITE_OFFs
         -- all write-offs pertaining to receipts of the invoices
         ---------------------------------------------------------------------
         SELECT
         cr.type trx_class,                     /* transaction_class */
         '' trx_type,                           /* transaction_type */
         cr.cash_receipt_id trx_id,             /* transaction_id */
         to_number('') line_id,                 /* transaction_line_id */
         'Activity' related_trx_class,                    /* related_transaction_class */
         'Write_Off' related_trx_type,                     /* related_transaction_type */
         to_number('') related_trx_id,             /* related_transaction_id */
         to_number('') related_trx_line_id,                     /* related_transaction_line_id */
         to_number('') line_number,                     /* line_number */
         'REC_APP' dist_type,                   /* distribution_type */
         ra.application_type app_type,          /* application_type */
         '' line_code_meaning,                          /* line_code_meaning */
         '' description,                                /* description */
         '' item_name,                          /* item_name */
         to_number('') qty,                     /* quantity */
         to_number('') selling_price,                   /* unit_selling_price */
         '' line_type,                          /* line_type */
         ra.attribute_category attr_category,
         ra.attribute1 attr1,
         ra.attribute2 attr2,
         ra.attribute3 attr3,
         ra.attribute4 attr4,
         ra.attribute5 attr5,
         ra.attribute6 attr6,
         ra.attribute7 attr7,
         ra.attribute8 attr8,
         ra.attribute9 attr9,
         ra.attribute10 attr10,
         ra.attribute11 attr11,
         ra.attribute12 attr12,
         ra.attribute13 attr13,
         ra.attribute14 attr14,
         ra.attribute15 attr15,
         ra.amount_applied amount, /* amount */
         to_number('') acctd_amount,                    /* acctd_amount */
         '' uom_code,                                   /* uom code */
         cr.ussgl_transaction_code ussgl_trx_code,
         to_number('') tax_rate,                /* tax_rate */
         '' tax_code,                           /* tax_code */
         to_number('') tax_precedence,                  /* tax_precedence */
         ra.code_combination_id ccid1,    /* account_ccid1 */
         to_number('') ccid2,              /* account_ccid2 */
         ra.earned_discount_ccid ccid3,   /* account_ccid3 */
         ra.unearned_discount_ccid ccid4, /* account_ccid4 */
         ra.gl_date gl_date,
         ra.gl_posted_date gl_posted_date,
         '' rule_name,              /* acct_rule_name */
         to_number('') acctg_rule_duration,/* rule_duration */
         to_date(NULL) rule_start_date,     /* rule_start_date */
         to_number('') last_period_to_credit,  /* last_period_to_credit */
         ra.comments line_comment,              /* line_comment */
         to_number('') line_adjusted,           /* line_adjusted */
         to_number('') freight_adjusted,        /* freight_adjusted */
         to_number('') tax_adjusted,            /* tax_adjusted */
         to_number('') charges_adjusted,        /* receivables_charges_adjusted */
         ra.line_applied line_applied,          /* line_applied */
         ra.freight_applied freight_applied,    /* freight_applied */
         ra.tax_applied tax_applied,            /* tax_applied */
         ra.receivables_charges_applied charges_applied,/* receivables_charges_applied */
         ra.earned_discount_taken earned_disc_taken,     /* earned_discount_taken */
         ra.unearned_discount_taken unearned_disc_taken,/* unearned_discount_taken */
         ra.acctd_amount_applied_from acctd_amount_applied_from,
                /* acctd_amount_applied_from */
         ra.acctd_amount_applied_to acctd_amount_applied_to,
                /* acctd_amount_applied_to */
         ra.acctd_earned_discount_taken acctd_earned_disc_taken,
                /* acctd_earned_disc_taken */
         ra.acctd_unearned_discount_taken acctd_unearned_disc_taken,
                /* acctd_unearned_disc_taken */
         to_number('') factor_discount_amount,  /* factor_discount_amount */
         to_number('') acctd_factor_discount_amount,/* acctd_factor_discount_amount */
         '' int_line_context,                   /* interface_line_context */
         '' int_line_attr1,                     /* interface_line_attribute1 */
         '' int_line_attr2,                     /* interface_line_attribute2 */
         '' int_line_attr3,                     /* interface_line_attribute3 */
         '' int_line_attr4,                     /* interface_line_attribute4 */
         '' int_line_attr5,                     /* interface_line_attribute5 */
         '' int_line_attr6,                     /* interface_line_attribute6 */
         '' int_line_attr7,                     /* interface_line_attribute7 */
         '' int_line_attr8,                     /* interface_line_attribute8 */
         '' int_line_attr9,                     /* interface_line_attribute9 */
         '' int_line_attr10,            /* interface_line_attribute10 */
         '' int_line_attr11,            /* interface_line_attribute11 */
         '' int_line_attr12,                    /* interface_line_attribute12 */
         '' int_line_attr13,                    /* interface_line_attribute13 */
         '' int_line_attr14,                    /* interface_line_attribute14 */
         '' int_line_attr15,                    /* interface_line_attribute15 */
         '' exch_rate_type,                     /* exchange_rate_type */
         to_date(NULL) exch_date,               /* exchange_date */
         to_number('') exch_rate,               /* exchange_rate */
         to_date(NULL) due_date,
         ra.apply_date apply_date,
         to_number('') movement_id,             /* movement_id */
         '' vendor_return_code,         /* tax_vendor_return_code */
         '' tax_auth_tax_rate,                  /* tax_authority_tax_rates */
         '' tax_exempt_flag,                    /* tax_exemption_flag */
         to_number('') tax_exemption_id,        /* tax_exemption_id */
         '' exemption_type,                     /* exemption_type */
         '' tax_exemption_reason,              /* exemption_reason */
         '' tax_exemption_number,               /* customer_exemption_number */
         '' item_exception_rate,                /* item_exception_rate */
         '' meaning,                            /* item_exception_reason */
         '',                             /* original_collectibility_flag */
         '',                             /* line_collectible_flag */
         '',                             /* manual_override_flag */
         '',                             /* contingency_code */
         to_date(null),                  /* expiration_date */
         to_number(null),                /* expiration_days */
         ''                      /* override_auto_accounting_flag */
         FROM
         ar_cash_receipts  cr,
         ar_receivable_applications ra
         where  cr.cash_receipt_id     = ra.cash_receipt_id
         and    ra.applied_payment_schedule_id = -3
         and    ra.status = 'ACTIVITY'
         and    ra.display = 'Y'
         and    ra.reversal_gl_date is null
         and    exists ( SELECT 'x'
                         FROM   ar_receivable_applications ra1
                         WHERE  ra1.applied_customer_trx_id =
                                     cp_customer_trx_id
                         AND    ra1.cash_Receipt_id = ra.cash_receipt_id )
         and    not exists (
                  select 'already purged'
                    from ar_archive_detail aad
                   where aad.transaction_id = cr.cash_receipt_id
                     and aad.transaction_class = 'CASH' );

         /* Bug 5105156 - fix 5073245 ends */


         l_org_profile VARCHAR2(30) ;

         l_account_combination1 VARCHAR2(240) ;
         l_account_combination2 VARCHAR2(240) ;
         l_account_combination3 VARCHAR2(240) ;
         l_account_combination4 VARCHAR2(240) ;

     BEGIN


         oe_profile.get('SO_ORGANIZATION_ID', l_org_profile);

         FOR select_detail IN detail_cursor ( p_customer_trx_id,
                                              p_archive_level ,
                                              l_org_profile )
         LOOP

             l_account_combination1 := NULL ;
             l_account_combination2 := NULL ;
             l_account_combination3 := NULL ;
             l_account_combination4 := NULL ;
             --
             IF select_detail.ccid1 > 0 THEN
                l_account_combination1 := get_ccid(select_detail.ccid1) ;
             END IF ;
             --
             IF select_detail.ccid2 > 0 THEN
                l_account_combination2 := get_ccid(select_detail.ccid2) ;
             END IF ;
             --
             IF select_detail.ccid3 > 0 THEN
                l_account_combination3 := get_ccid(select_detail.ccid3) ;
             END IF ;
             --
             IF select_detail.ccid4 > 0 THEN
                l_account_combination4 := get_ccid(select_detail.ccid4) ;
             END IF ;
             --
             INSERT INTO ar_archive_detail
             ( archive_id,
               transaction_class,
               transaction_type,
               transaction_id,
               transaction_line_id,
               related_transaction_class,
               related_transaction_type,
               related_transaction_id,
               related_transaction_line_id,
               line_number,
               distribution_type,
               application_type,
               reason_code_meaning,
               line_description,
               item_name,
               quantity,
               unit_selling_price,
               line_type,
               attribute_category,
               attribute1,
               attribute2,
               attribute3,
               attribute4,
               attribute5,
               attribute6,
               attribute7,
               attribute8,
               attribute9,
               attribute10,
               attribute11,
               attribute12,
               attribute13,
               attribute14,
               attribute15,
               amount,
               -- acctd_amount, -- bug1199027
               uom_code,
               ussgl_transaction_code,
               tax_rate,
               tax_code,
               tax_precedence,
               account_combination1,
               account_combination2,
               account_combination3,
               account_combination4,
               gl_date,
               gl_posted_date,
               accounting_rule_name,
               rule_duration,
               rule_start_date,
               last_period_to_credit,
               comments,
               line_adjusted,
               freight_adjusted,
               tax_adjusted,
               receivables_charges_adjusted,
               line_applied,
               freight_applied,
               tax_applied,
               receivables_charges_applied,
               earned_discount_taken,
               unearned_discount_taken,
               -- acctd_amount_applied_from, -- bug1199027
               -- acctd_amount_applied_to, -- bug1199027
               -- acctd_earned_disc_taken, -- bug1199027
               -- acctd_unearned_disc_taken, -- bug1199027
               factor_discount_amount,
               -- acctd_factor_discount_amount, -- bug1199027
               interface_line_context,
               interface_line_attribute1,
               interface_line_attribute2,
               interface_line_attribute3,
               interface_line_attribute4,
               interface_line_attribute5,
               interface_line_attribute6,
               interface_line_attribute7,
               interface_line_attribute8,
               interface_line_attribute9,
               interface_line_attribute10,
               interface_line_attribute11,
               interface_line_attribute12,
               interface_line_attribute13,
               interface_line_attribute14,
               interface_line_attribute15,
               exchange_rate_type,
               exchange_rate_date,
               exchange_rate,
               due_date,
               apply_date,
               movement_id,
               tax_vendor_return_code,
               tax_authority_tax_rates,
               tax_exemption_flag,
               tax_exemption_id,
               tax_exemption_type,
               tax_exemption_reason,
               tax_exemption_number,
               item_exception_rate,
               Item_exception_reason ,
               original_collectibility_flag,
               line_collectible_flag,
               manual_override_flag,
               contingency_code,
               expiration_date,
               expiration_days,
	       override_auto_accounting_flag
             )
             VALUES
             ( lpad(p_archive_id,14,'0'), /* modified for bug 3266428 */
               select_detail.trx_class,
               select_detail.trx_type,
               select_detail.trx_id,
               select_detail.line_id,
               select_detail.related_trx_class,
               select_detail.related_trx_type,
               select_detail.related_trx_id,
               select_detail.related_trx_line_id,
               select_detail.line_number,
               select_detail.dist_type,
               select_detail.app_type,
               select_detail.line_code_meaning,
               select_detail.description,
               select_detail.item_name,
               select_detail.qty,
               select_detail.selling_price,
               select_detail.line_type,
               select_detail.attr_category,
               select_detail.attr1,
               select_detail.attr2,
               select_detail.attr3,
               select_detail.attr4,
               select_detail.attr5,
               select_detail.attr6,
               select_detail.attr7,
               select_detail.attr8,
               select_detail.attr9,
               select_detail.attr10,
               select_detail.attr11,
               select_detail.attr12,
               select_detail.attr13,
               select_detail.attr14,
               select_detail.attr15,
               select_detail.amount,
               -- select_detail.acctd_amount, -- bug1199027
               select_detail.uom_code,
               select_detail.ussgl_trx_code,
               select_detail.tax_rate,
               select_detail.tax_code,
               select_detail.tax_precedence,
               l_account_combination1,
               l_account_combination2,
               l_account_combination3,
               l_account_combination4,
               select_detail.gl_date,
               select_detail.gl_posted_date,
               select_detail.rule_name,
               select_detail.acctg_rule_duration,
               select_detail.rule_start_date,
               select_detail.last_period_to_credit,
               select_detail.line_comment,
               select_detail.line_adjusted,
               select_detail.freight_adjusted,
               select_detail.tax_adjusted,
               select_detail.charges_adjusted,
               select_detail.line_applied,
               select_detail.freight_applied,
               select_detail.tax_applied,
               select_detail.charges_applied,
               select_detail.earned_disc_taken,
               select_detail.unearned_disc_taken,
               -- select_detail.acctd_amount_applied_from, -- bug1199027
               -- select_detail.acctd_amount_applied_to, -- bug1199027
               -- select_detail.acctd_earned_disc_taken, -- bug1199027
               -- select_detail.acctd_unearned_disc_taken, -- bug1199027
               select_detail.factor_discount_amount,
               -- select_detail.acctd_factor_discount_amount, -- bug1199027
               select_detail.int_line_context,
               select_detail.int_line_attr1,
               select_detail.int_line_attr2,
               select_detail.int_line_attr3,
               select_detail.int_line_attr4,
               select_detail.int_line_attr5,
               select_detail.int_line_attr6,
               select_detail.int_line_attr7,
               select_detail.int_line_attr8,
               select_detail.int_line_attr9,
               select_detail.int_line_attr10,
               select_detail.int_line_attr11,
               select_detail.int_line_attr12,
               select_detail.int_line_attr13,
               select_detail.int_line_attr14,
               select_detail.int_line_attr15,
               select_detail.exch_rate_type,
               select_detail.exch_date,
               select_detail.exch_rate,
               select_detail.due_date,
               select_detail.apply_date,
               select_detail.movement_id,
               select_detail.vendor_return_code,
               select_detail.tax_auth_tax_rate,
               select_detail.tax_exempt_flag,
               select_detail.tax_exemption_id,
               select_detail.exemption_type,
               select_detail.tax_exemption_reason,
               select_detail.tax_exemption_number,
               select_detail.item_exception_rate,
               select_detail.meaning,
               select_detail.original_collectibility_flag,
               select_detail.line_collectible_flag,
               select_detail.manual_override_flag,
               select_detail.contingency_code,
               select_detail.expiration_date,
               select_detail.expiration_days,
	       select_detail.override_auto_accounting_flag
             ) ;

         END LOOP ;

         RETURN TRUE ;

    EXCEPTION
        WHEN OTHERS THEN
            print( 1, '  ...Failed while inserting into AR_ARCHIVE_DETAIL');
            print( 1, 'sqlcode = ' || SQLCODE || SQLERRM ) ;
            RAISE ;
    END;
    --
    -- archive - Processing Cycle
    --
    PROCEDURE archive( p_archive_id IN NUMBER,
                       p_customer_trx_id IN NUMBER,
                       p_archive_level IN VARCHAR2,
                       p_archive_status OUT NOCOPY BOOLEAN  ) IS
        l_error_location VARCHAR2(50) ;
        h boolean ;
    BEGIN

        -- bug3975105 add 'N'
        print( 1, '...archiving ', 'N');
        l_error_location := 'archive_header' ;

        IF archive_header( p_customer_trx_id ,
                           p_archive_id      ) = FALSE
        THEN
            print( 0, '  ...Failed while inserting into AR_ARCHIVE_HEADER ');
            p_archive_status := FALSE ;
        END IF ;

        l_error_location := 'archive_detail' ;
        IF  archive_detail( p_customer_trx_id  ,
                            p_archive_level    ,
                            p_archive_id       ) = FALSE
        THEN
            print( 0, '  ...Failed while inserting into AR_ARCHIVE_DETAIL ');
            p_archive_status := FALSE ;
        ELSE
            p_archive_status := TRUE ;
        END IF ;

    EXCEPTION
        WHEN OTHERS THEN
            print( 0, l_error_location ) ;
            print( 0, 'sqlcode = ' || SQLCODE || SQLERRM ) ;
            print( 0, '  ...Archive Failed ');
            p_archive_status := FALSE ;
            RAISE ;
    END;
    --
    --
    -- returns TRUE if the entity was successfully purged
    -- returns FALSE otherwise
    --
    FUNCTION recursive_purge( p_entity_id       IN     NUMBER,
                              p_entity_type     IN     VARCHAR2,
                              p_as_of_gl_date   IN     DATE,
                              p_customer_id     IN     NUMBER,
                              p_archive_level   IN     VARCHAR2,
                              p_recursive_level IN     NUMBER,
                              p_running_total   IN OUT NOCOPY NUMBER ) RETURN BOOLEAN
    IS
        l_dummy          NUMBER;
        l_archive_status BOOLEAN ;

    BEGIN
        -- bug3975105 added 'Y'
        print( p_recursive_level, 'Processing id:'||p_entity_id||' type:'||p_entity_type|| ' at ' || to_char(sysdate,'dd-mon-yyyy hh:mi:ss'), 'Y');

        IF p_entity_type = 'CT'
        THEN
            IF in_unpurgeable_txn_list( p_entity_id )
            THEN
                -- bug3975105 added 'S'
                print( p_recursive_level, '  ...already in unpurgeable transaction list', 'S');
                RETURN FALSE;
            END IF;
            --
            IF trx_purgeable ( p_entity_id ) = FALSE
            THEN
                print( p_recursive_level, '  ...is unpurgeable due to customisation' ) ;
                RETURN FALSE;
            END IF ;
            --
            DECLARE
                l_record_found  VARCHAR2(10) := 'Not Found' ;

                /* bug1999155: Divided select stmt which lock all transactions
                  records into the following stmts */
                cursor trx_cur is
                    SELECT  'Found'  record_found
                    from    ra_customer_trx trx
                    WHERE   trx.customer_trx_id = p_entity_id
                    FOR     UPDATE OF trx.customer_trx_id NOWAIT;

                cursor trx_line_cur is
                    SELECT  'Found'  record_found
                    from    ra_customer_trx_lines lines
                    WHERE   lines.customer_trx_id = p_entity_id
                    FOR     UPDATE OF lines.customer_trx_id NOWAIT;

                cursor dist_cur is
                    SELECT  'Found'  record_found
                    from    ra_cust_trx_line_gl_dist dist
                    WHERE   dist.customer_trx_id = p_entity_id
                    FOR     UPDATE OF dist.customer_trx_id NOWAIT;

                cursor sales_cur is
                    SELECT  'Found'  record_found
                    from    ra_cust_trx_line_salesreps sales
                    WHERE   sales.customer_trx_id = p_entity_id
                    FOR     UPDATE OF sales.customer_trx_id NOWAIT;

                cursor adj_cur is
                    SELECT  'Found'  record_found
                    from    ar_adjustments adj
                    WHERE   adj.customer_trx_id  = p_entity_id
                    FOR     UPDATE OF adj.customer_trx_id NOWAIT;

                cursor recv_app_cur is
                    SELECT  'Found'  record_found
                    from    ar_receivable_applications ra
                    WHERE   ra.applied_customer_trx_id = p_entity_id
                    FOR     UPDATE OF ra.customer_trx_id NOWAIT;

                cursor pay_sched_cur is
                    SELECT  'Found'  record_found
                    from    ar_payment_schedules ps
                    WHERE   ps.customer_trx_id = p_entity_id
                    FOR     UPDATE OF ps.customer_trx_id NOWAIT;

            BEGIN
                -- lock all the transaction records
                /* bug1999155: Divided the following select stmt into
                  some stmts. This cursor for loop is not used .
                FOR lock_rec IN (
                                  SELECT 'Found'  record_found
                                  FROM   ra_cust_trx_line_salesreps sales,
                                         ar_receivable_applications ra,
                                         ar_payment_schedules ps,
                                         ar_adjustments adj,
                                         ra_cust_trx_line_gl_dist dist,
                                         ra_customer_trx_lines lines,
                                         ra_customer_trx trx
                                  WHERE  trx.customer_trx_id = p_entity_id
                                  AND    trx.customer_trx_id = lines.customer_trx_id
                                  AND    trx.customer_trx_id = dist.customer_trx_id (+)
                                  AND    trx.customer_trx_id = sales.customer_trx_id (+)
                                  AND    trx.customer_trx_id = adj.customer_trx_id (+)
                                  AND    trx.customer_trx_id = ra.applied_customer_trx_id (+)
                                  AND    trx.customer_trx_id = ps.customer_trx_id (+)
                                  FOR    UPDATE OF trx.customer_trx_id ,
                                                   lines.customer_trx_id,
                                                   dist.customer_trx_id,
                                                   sales.customer_trx_id,
                                                   adj.customer_trx_id,
                                                   ra.customer_trx_id,
                                                   ps.customer_trx_id NOWAIT
                               )
                LOOP
                    l_record_found := lock_rec.record_found ;
                END LOOP ;
                bug1999155 end */

                /* bug1999155 : Open created cursors to lock */
                open    trx_cur;

                fetch  trx_cur
                into l_record_found;

                -- Need to verify if NO_DATA_FOUND will be raised if
                -- the cursor does not return any row.
                --
                IF l_record_found = 'Not Found'
                THEN
                   RETURN TRUE ; -- No Data Found
                END IF ;

                close   trx_cur;

                open    trx_line_cur;
                close   trx_line_cur;

                open    dist_cur;
                close   dist_cur;

                open    sales_cur;
                close   sales_cur;

                open    adj_cur;
                close   adj_cur;

                open    recv_app_cur;
                close   recv_app_cur;

                open    pay_sched_cur;
                close   pay_sched_cur;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    RETURN TRUE; -- assume already processed in this thread
                WHEN locked_by_another_session THEN
                    print( p_recursive_level, ' ...locked by another session' );
                    RETURN FALSE; -- assume already processed in this thread
                WHEN OTHERS THEN
                    print( p_recursive_level, ' ...Failed while trying to lock' );
                    print( 1, 'sqlcode = ' || SQLCODE || SQLERRM ) ;
                    RAISE;
            END;


            /* Bug2472294 : Merged following condition into next one.
            --
            -- ensure that the transaction is neither a commitment nor
            -- related to a commitment
            --
            DECLARE
                l_commitment_transactions NUMBER;
            BEGIN
                SELECT  COUNT(*)
                INTO    l_commitment_transactions
                FROM    ra_customer_trx     ct,
                        ra_cust_trx_types   ctt
                WHERE   ct.customer_trx_id = p_entity_id
                AND     ctt.cust_trx_type_id = ct.cust_trx_type_id
                AND
                (
                    ctt.type IN ( 'GUAR', 'DEP' )   OR
                    ct.initial_customer_trx_id IS NOT NULL
                );
                --
                IF l_commitment_transactions > 0
                THEN
                    print( p_recursive_level, '  ...is a commitment or related to a commitment');
                    RETURN FALSE;
                END IF;
            END;
            Bug 2472294 */


            -- bug2472294 start
            -- Handle non post to gl transaction
            DECLARE
                l_type ra_cust_trx_types.type%TYPE ;
                l_initial_customer_trx_id ra_customer_trx.initial_customer_trx_id%TYPE;
                l_post_to_gl ra_cust_trx_types.post_to_gl%TYPE;
                l_trx_date ra_customer_trx.trx_date%TYPE;

            BEGIN

                SELECT  ctt.type,
                        ct.initial_customer_trx_id,
                        ctt.post_to_gl,
                        ct.trx_date
                INTO    l_type,
                        l_initial_customer_trx_id,
                        l_post_to_gl,
                        l_trx_date
                FROM    ra_customer_trx ct,
                        ra_cust_trx_types ctt
                WHERE   ct.customer_trx_id = p_entity_id
                AND     ctt.cust_trx_type_id = ct.cust_trx_type_id ;

                --
                -- ensure that the transaction is neither a commitment nor
                -- related to a commitment
                --
                IF ( l_type = 'GUAR' ) or ( l_type = 'DEP') or
                ( l_initial_customer_trx_id IS NOT NULL )
                THEN
                   print( p_recursive_level, '  ...is a commitment or related to a commitment') ;
                   RETURN FALSE;
                END IF;

                IF l_post_to_gl = 'Y'
                THEN
                   --
                   -- select distributions that are unposted or whose gl_date
                   -- is after the purge date
                   --
                   DECLARE
                      l_unpurgeable_distributions   NUMBER;
                   BEGIN
                      SELECT  COUNT(*)
                      INTO    l_unpurgeable_distributions
                      FROM    ra_cust_trx_line_gl_dist
                      WHERE   customer_trx_id = p_entity_id
                      AND     account_set_flag = 'N'
                      AND
                      (
                          posting_control_id = -3    OR
                          gl_date > p_as_of_gl_date
                      );
                      IF l_unpurgeable_distributions <> 0 THEN
                         print( p_recursive_level, '  ...which has unpurgeable distributions' );
                         RETURN FALSE;
                      END IF;
                      ---
                      ---
                   END;
                   --
                   -- check for adjustments that violate rules
                   --    (NOTE: unapproved adjustments are excluded from search)
                   --           It is most unlikely that these unapproved adjs.
                   --           will be approved. So, these need not be
                   --           considered.
                   --
                   DECLARE
                      l_violate_adjustments   NUMBER;
                   BEGIN
                      SELECT  COUNT(*)
                      INTO    l_violate_adjustments
                      FROM    ar_adjustments
                      WHERE   customer_trx_id = p_entity_id
                      AND     status in ('A', 'M', 'W') -- bug1999155
                      AND
                      (
                          posting_control_id = -3    OR
                          gl_date            > p_as_of_gl_date
                      );
                      IF l_violate_adjustments > 0
                      THEN
                         print( p_recursive_level, '  ...unpurgeable adjustments' );
                         RETURN FALSE;
                      END IF;
                   END;

                /* l_post_to_gl = 'N'  */
                ELSE

                   IF l_trx_date > p_as_of_gl_date
                   THEN
                      print( p_recursive_level, '  ...transaction date is after the purge date');
                      RETURN FALSE;
                   END IF;

                   --
                   -- check for adjustments that violate rules
                   --    (NOTE: unapproved adjustments are excluded from search)
                   --           It is most unlikely that these unapproved adjs.
                   --           will be approved. So, these need not be
                   --           considered.
                   --
                   DECLARE
                      l_violate_adjustments   NUMBER;
                   BEGIN
                      SELECT  COUNT(*)
                      INTO    l_violate_adjustments
                      FROM    ar_adjustments
                      WHERE   customer_trx_id = p_entity_id
                      AND     status in ('A', 'M', 'W')
                      AND decode ( status, 'A', gl_date , p_as_of_gl_date + 1)
                             > p_as_of_gl_date ;

                      IF l_violate_adjustments > 0
                      THEN
                         print( p_recursive_level, '  ...unpurgeable adjustments' );
                         RETURN FALSE;
                      END IF;
                   END;
                END IF;

            EXCEPTION
                WHEN OTHERS THEN
                print( 1, 'Failed while checking the Transaction Type');
                print( 1, 'sqlcode = ' || SQLCODE || SQLERRM ) ;
                RAISE ;
            END ;
            -- bug2472294 end


            --
            --
            -- Check if this trx. belongs to the same customer
            --
            DECLARE
                l_same_customer   VARCHAR2(1);
            BEGIN

                IF p_customer_id IS NOT NULL THEN

                   BEGIN
                       SELECT  'Y'
                       INTO    l_same_customer
                       FROM    ra_customer_trx
                       WHERE   customer_trx_id = p_entity_id
                       AND     bill_to_customer_id = p_customer_id ;

                   EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                           print( p_recursive_level, '  ...Bill to Customer is different' );
                           RETURN FALSE ;
                       WHEN OTHERS THEN
                           RAISE ;
                   END ;
                END IF ;
                --
            END;
            --
            -- check that all of the invoice's payment schedules are closed
            --
            DECLARE
                l_invoice_open_amount   NUMBER;
            BEGIN
                SELECT  NVL(SUM(ABS(amount_due_remaining)),0)
                INTO    l_invoice_open_amount
                FROM    ar_payment_schedules
                WHERE   customer_trx_id = p_entity_id;
                --
                IF l_invoice_open_amount > 0 THEN
                    print( p_recursive_level, '  ...payment schedule is not closed' );
                    RETURN FALSE;
                END IF;
                --
            EXCEPTION
                WHEN OTHERS THEN
                    print( 1, 'Failed while checking the Payment Schedules');
                    print( 1, 'sqlcode = ' || SQLCODE || SQLERRM ) ;
                    RAISE ;
            END;
            --
            -- ensure that autorule is complete for this transaction
            --
            DECLARE
                l_autorule_incomplete_count    NUMBER;
            BEGIN
                SELECT  COUNT(*)
                INTO    l_autorule_incomplete_count
                FROM    ra_customer_trx_lines
                WHERE   customer_trx_id        = p_entity_id
                AND     line_type              = 'LINE'
                AND     autorule_complete_flag = 'N';
                IF l_autorule_incomplete_count > 0
                THEN
                    print( p_recursive_level, '  ...autorule is not complete' );
                    RETURN FALSE;
                END IF;
            END;

            /* bug2472294 : Moved to above because this was executed only when
               post_to_gl is 'Y'.
            --
            -- select distributions that are unposted or whose gl_date
            -- is after the purge date
            --
            DECLARE
                l_unpurgeable_distributions   NUMBER;
            BEGIN
                SELECT  COUNT(*)
                INTO    l_unpurgeable_distributions
                FROM    ra_cust_trx_line_gl_dist
                WHERE   customer_trx_id = p_entity_id
                AND     account_set_flag = 'N'
                AND
                (
                    posting_control_id = -3    OR
                    gl_date > p_as_of_gl_date
                );
                IF l_unpurgeable_distributions <> 0 THEN
                    print( p_recursive_level, '  ...which has unpurgeable distributions' );
                    RETURN FALSE;
                END IF;
                ---
                ---
            END;
            --
            -- check for adjustments that violate rules
            --    (NOTE: unapproved adjustments are excluded from search)
            --           It is most unlikely that these unapproved adjs.
            --           will be approved. So, these need not be
            --           considered.
            --

            DECLARE
                l_violate_adjustments   NUMBER;
            BEGIN
                SELECT  COUNT(*)
                INTO    l_violate_adjustments
                FROM    ar_adjustments
                WHERE   customer_trx_id = p_entity_id
                AND     status in ('A', 'M', 'W') -- bug1999155
                AND
                (
                    posting_control_id = -3    OR
                    gl_date            > p_as_of_gl_date
                );
                IF l_violate_adjustments > 0
                THEN
                    print( p_recursive_level, '  ...unpurgeable adjustments' );
                    RETURN FALSE;
                END IF;
            END;
            bug2472294 */

            --
            -- Check if any applications are unpurgeable
            --
            DECLARE
                l_unpurgeable_applications  NUMBER;
            BEGIN
                SELECT  COUNT(*)
                INTO    l_unpurgeable_applications
                FROM    ar_receivable_applications
                WHERE
                (
                    applied_customer_trx_id = p_entity_id     OR
                    customer_trx_id         = p_entity_id
                )
                AND
                (
                    posting_control_id = -3         OR
                    gl_date            > p_as_of_gl_date
                )
                AND postable = 'Y' ; -- bug3404430 added to check only postable
                IF l_unpurgeable_applications > 0 THEN
                    print( p_recursive_level, '  ...unpurgeable applications' );
                    RETURN FALSE;
                END IF;
            END;
            --

            DECLARE
                l_receivable_amount  NUMBER ;
                l_adjustment_amount  NUMBER ;
            BEGIN

                SELECT acctd_amount
                INTO   l_receivable_amount
                FROM   RA_CUST_TRX_LINE_GL_DIST
                WHERE  customer_trx_id = p_entity_id
                AND    account_class   = 'REC'
                AND    latest_rec_flag = 'Y'  ;

                p_running_total := p_running_total + l_receivable_amount ;

                SELECT NVL(SUM(acctd_amount),0)
                INTO   l_adjustment_amount
                FROM   ar_adjustments
                WHERE  customer_trx_id = p_entity_id
                AND    status in ('A', 'M', 'W') ;  -- bug1999155

                p_running_total := p_running_total + l_adjustment_amount;

            EXCEPTION
                  /* bug1999155 No need to handle NO_DATA_FOUND error
                  WHEN NO_DATA_FOUND THEN
                      RETURN FALSE;
		  */
                  WHEN OTHERS THEN
                      print( 1, 'Failed while checking GL_DIST/ADJ');
                      print( 1, 'sqlcode = ' || SQLCODE || SQLERRM ) ;
                      RAISE;
            END ;
            -- bug3873165 Added following check
            --
            -- check if line revenue is completed
            --

            DECLARE
                l_line_revenue     NUMBER;
            BEGIN
                SELECT  COUNT(*)
                INTO    l_line_revenue
                FROM    ar_deferred_lines dl
                WHERE   p_entity_id = dl.customer_trx_id
                AND     dl.line_collectible_flag = 'N'
                AND     dl.manual_override_flag = 'N'
                AND     dl.acctd_amount_due_original <> dl.acctd_amount_recognized;

                IF  l_line_revenue > 0
                THEN
                    print( p_recursive_level, '  ...line revenue is not completed ' );
                    RETURN FALSE;
                END IF;
            END;
            --
            DECLARE
                l_batch_id NUMBER(15) ;

                /* bug2021662 : added for getting deleted correspondence_id */
                TYPE Del_Cid_Tab IS TABLE OF ar_correspondences.correspondence_id%TYPE INDEX BY BINARY_INTEGER;
                del_cid Del_Cid_Tab;

                l_corr_row   BINARY_INTEGER := 0 ;

            BEGIN
                --
                -- Archive rows here before deleting so that
                -- you don't lose the data
                --
                archive( l_archive_id,
                         p_entity_id,
                         p_archive_level,
                         l_archive_status) ;

                IF l_archive_status = FALSE
                THEN
                    print( 0,'Archive Failed') ;
                    RETURN ( FALSE ) ;
                END IF ;
                --
                SELECT bat.batch_id
                INTO   l_batch_id
                FROM   ra_batches bat,
                       ra_customer_trx trx
                WHERE  trx.customer_trx_id = p_entity_id
                AND    trx.batch_id = bat.batch_id (+)
                FOR    UPDATE OF bat.batch_id NOWAIT ;
                --
                -- bug3975105 added 'N'
                print( p_recursive_level, '  ...deleting rows', 'N' );
                --
                /* bug3873165 added two tables for line rev */
                DELETE FROM ar_line_conts
                WHERE  customer_trx_line_id in ( select customer_trx_line_id
                                      from   ra_customer_trx
                                      where  customer_trx_id = p_entity_id );
                --
                DELETE FROM ar_deferred_lines
                WHERE  customer_trx_id = p_entity_id;
                --
                DELETE FROM ra_customer_trx_lines
                WHERE  customer_trx_id = p_entity_id;
                --
                DELETE FROM ra_cust_trx_line_gl_dist
                WHERE  customer_trx_id = p_entity_id;

                --
                -- bug 1404679 : to prevent ORA-1403 error when client uses AX,
                -- delete from RA_CUSTOMER_TRX
                -- after lines and dist table are done
                --
                -- DELETE FROM ra_customer_trx
                -- WHERE  customer_trx_id = p_entity_id;
                --

                -- Call table handler instead of doing direct delete to
                -- ra_customer_Trx

                 arp_ct_pkg.delete_p(p_entity_id);

                DELETE FROM ra_batches
                WHERE  batch_id = l_batch_id
                AND    NOT EXISTS ( SELECT 'x'
                                    FROM   ra_customer_trx t
                                    WHERE  t.batch_id = l_batch_id ) ;


                -- bug3283678 this must be done after above delete stmt.
                IF SQL%ROWCOUNT = 0
                THEN
                     UPDATE ra_batches batch
                     SET    batch.purged_children_flag = 'Y'
                     WHERE  batch.batch_id = l_batch_id ;
                END IF ;
                --


                --
                DELETE FROM ar_distributions
                WHERE  source_id in ( select adjustment_id
                                      from   ar_adjustments
                                      where  customer_trx_id = p_entity_id )
                AND    source_table = 'ADJ';


                --

                DELETE FROM ar_adjustments
                WHERE  customer_trx_id = p_entity_id;


                --
                DELETE FROM ra_cust_trx_line_salesreps
                WHERE  customer_trx_id = p_entity_id;
                --
                DELETE FROM ar_notes
                WHERE  customer_trx_id = p_entity_id;
                --
                DELETE FROM ar_action_notifications action
                WHERE  call_action_id IN
                (
                     SELECT call.call_action_id
                     FROM   ar_call_actions call,
                            ar_customer_call_topics topics
                     WHERE  topics.customer_trx_id = p_entity_id
                     AND    topics.customer_call_topic_id =
                                call.customer_call_topic_id
                ) ;
                --
                DELETE FROM ar_call_actions call
                WHERE  customer_call_topic_id IN
                (
                     SELECT topics.customer_call_topic_id
                     FROM   ar_customer_call_topics topics
                     WHERE  topics.customer_trx_id = p_entity_id
                ) ;
                --
                DELETE FROM ar_customer_call_topics
                WHERE  customer_trx_id = p_entity_id ;
                --
                UPDATE ar_correspondences corr
                SET    corr.purged_children_flag = 'Y'
                WHERE  corr.correspondence_id IN
                (
                      SELECT sched.correspondence_id
                      FROM   ar_payment_schedules ps,
                             ar_correspondence_pay_sched sched
                      WHERE  ps.customer_trx_id = p_entity_id
                      AND    ps.payment_schedule_id =
                                 sched.payment_schedule_id
                ) ;
                --
                /* bug2021662 :add RETURNING to get deleted correspondence_id
                */
                DELETE FROM  ar_correspondence_pay_sched sched
                WHERE  payment_schedule_id IN
                (
                      SELECT payment_schedule_id
                      FROM   ar_payment_schedules
                      WHERE  customer_trx_id = p_entity_id
                )
                RETURNING correspondence_id BULK COLLECT INTO del_cid ;
                --
                /* bug2021662 :this DELETE stmt does not work correctly
                DELETE FROM  ar_correspondences corr
                WHERE  corr.correspondence_id NOT IN
                (
                      SELECT sched.correspondence_id
                      FROM   ar_correspondence_pay_sched sched,
                             ar_payment_schedules ps
                      WHERE  ps.customer_trx_id = p_entity_id
                      AND    ps.payment_schedule_id =
                                 sched.payment_schedule_id
                ) ;
                */
                /* bug2021662 : instead of above stmt, created following stmt
		   for gotton correspondence_id
                */
		IF del_cid.count > 0 THEN
                   FORALL l_corr_row IN del_cid.FIRST..del_cid.LAST
                   DELETE FROM ar_correspondences corr
                   WHERE not exists
                   (
                      SELECT 'there are children records'
                        FROM ar_correspondence_pay_sched sched
                       WHERE corr.correspondence_id = sched.correspondence_id )
                   AND corr.correspondence_id = del_cid(l_corr_row) ;
		END IF;
                --
                DELETE FROM ar_payment_schedules
                WHERE  customer_trx_id = p_entity_id;

                --
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    print( p_recursive_level, ' ...No rows found while attempting to lock' );
                    RETURN FALSE;
                WHEN locked_by_another_session THEN
                    print( p_recursive_level, ' ...locked by another session' );
                    RETURN FALSE;
                WHEN deadlock_detected THEN
                    print( p_recursive_level, ' ...deadlock detected while deleting trxs.' );
                    RETURN FALSE;
                WHEN OTHERS THEN
                    print( 1, 'Failed while deleting from the trx tables');
                    print( 1, 'sqlcode = ' || SQLCODE || SQLERRM ) ;
                    RAISE ;
            END;
            --
            -- Recursively deal with applications
            --
            DECLARE
                CURSOR app_to_invoice( cp_applied_invoice_id NUMBER ) IS
                       SELECT  DECODE( application_type,
                                         'CASH',cash_receipt_id,
                                         'CM'  ,DECODE( applied_customer_trx_id,
                                                        cp_applied_invoice_id,
                                                        customer_trx_id ,
                                                        applied_customer_trx_id ) ),

                               applied_customer_trx_id,
                               application_type,
                               -- bug1199027
                               -- bug4060025 added code for CM app ex gain/loss
                               DECODE( application_type,
                                        'CASH', acctd_amount_applied_to,
                                        'CM', acctd_amount_applied_from - acctd_amount_applied_to ),
                               NVL(acctd_earned_discount_taken,0) +
                                   NVL(acctd_unearned_discount_taken,0)
                       FROM    ar_receivable_applications
                       WHERE
                       (
                           applied_customer_trx_id = cp_applied_invoice_id    OR
                           customer_trx_id         = cp_applied_invoice_id
                       )
                       FOR UPDATE OF receivable_application_id NOWAIT ;

                -- bug 1715258
                --
                -- Select all invoice related with unpurgeable receipt
                -- to add unpurgeable trx list.
                --
                CURSOR app_to_invoice_receipt( cp_cash_receipt_id NUMBER ) IS
                       SELECT applied_customer_trx_id
                       FROM   ar_receivable_applications
                       WHERE  cash_receipt_id = cp_cash_receipt_id
                       AND    status = 'APP';

                l_application_id           NUMBER; -- receipt_id or trx_id
                l_applied_customer_trx_id  NUMBER;
                l_application_type         ar_receivable_applications.application_type%TYPE;
                l_receipt_amount           NUMBER;
                l_discount_amount          NUMBER;
            BEGIN
                OPEN app_to_invoice( p_entity_id );
                --
                DELETE FROM ar_distributions
                WHERE  source_id in ( SELECT receivable_application_id
                                      FROM   ar_receivable_applications
                                      WHERE
                                      (   applied_customer_trx_id = p_entity_id OR
                                          customer_trx_id = p_entity_id
                                      )
                                    )
                AND    source_table = 'RA';



                --
                DELETE FROM ar_receivable_applications
                WHERE
                (
                    applied_customer_trx_id = p_entity_id    OR
                    customer_trx_id         = p_entity_id
                );

                --
                LOOP
                    FETCH app_to_invoice
                    INTO  l_application_id,
                          l_applied_customer_trx_id,
                          l_application_type,
                          l_receipt_amount,
                          l_discount_amount ;
                    EXIT WHEN app_to_invoice%NOTFOUND;
                    --
                    -- This check is made so that it doesn't attempt
                    -- to delete again and again within this loop
                    --
                    IF l_application_type = 'CASH'
                    THEN
                        ---
                        p_running_total := p_running_total - l_receipt_amount
                                                - l_discount_amount ;
                        ---
                        IF NOT recursive_purge( l_application_id,
                                                'CR',
                                                p_as_of_gl_date,
                                                p_customer_id,
                                                p_archive_level,
                                                p_recursive_level+1,
                                                p_running_total )
                        THEN
                            CLOSE app_to_invoice;

                            -- bug 1715258
                            add_to_unpurgeable_receipts( l_application_id );

                            -- bug 1715258
                            --
                            -- Add transaction related with unpurgeable receipt
                            -- to unpurgeable trx list
                            --
                            FOR r_app_to_invoice_receipt IN app_to_invoice_receipt(l_application_id )
                            LOOP
                              IF NOT in_unpurgeable_txn_list( r_app_to_invoice_receipt.applied_customer_trx_id )
                              THEN
                                -- bug3975105 added 'N'
                                print( p_recursive_level, '  Add id:' || r_app_to_invoice_receipt.applied_customer_trx_id || ' to unpurgeable transaction list', 'N');
                                add_to_unpurgeable_txns(r_app_to_invoice_receipt.applied_customer_trx_id );
                              END IF;

                            END LOOP;

                            RETURN FALSE;
                        END IF;
                    ELSE
                        -- Bug4060025 Need to calc exchange gain/loss for CM
                        ---
                        p_running_total := p_running_total + l_receipt_amount ;
                        ---
                        IF NOT recursive_purge( l_application_id,
                                                'CT',
                                                p_as_of_gl_date,
                                                p_customer_id,
                                                p_archive_level,
                                                p_recursive_level+1,
                                                p_running_total )
                        THEN
                            CLOSE app_to_invoice;
                            add_to_unpurgeable_txns( l_applied_customer_trx_id );
                            RETURN FALSE;
                        END IF;
                    END IF;
                END LOOP;
                CLOSE app_to_invoice;
            EXCEPTION
                WHEN locked_by_another_session THEN
                    print( p_recursive_level, ' ...locked by another session' );
                    RETURN FALSE; -- assume already processed in this thread
                WHEN deadlock_detected THEN
                    print( p_recursive_level, ' ...deadlock detected in app_to_inv' );
                    RETURN FALSE;
                WHEN OTHERS THEN
                    print(0,'Failed while dealing with Trx.') ;
                    print(0,'Error ' || SQLCODE || ' ' || SQLERRM ) ;
                    RAISE ;
            END;
            RETURN TRUE;
            -- finished 'CT' case
        ELSIF p_entity_type = 'CR'
        THEN
            --
            -- lock the receipt
            --

            -- bug 1715258
            IF in_unpurgeable_receipt_list( p_entity_id )
            THEN
                -- bug3975105 added 'S'
                print( p_recursive_level, '  ...already in unpurgeable receipt list', 'S');
                RETURN FALSE;
            END IF;

            DECLARE
                l_record_found  VARCHAR2(10) := 'Not Found' ;

                /* bug1999155: Divided select stmt which lock all transactions
                  records into the following stmts */
                cursor dist_crh_cur is
                    select  'Found'  record_found
                    FROM    ar_distributions        dist,
                            ar_cash_receipt_history crh
                    where   crh.cash_receipt_history_id = dist.source_id (+)
                    AND     crh.cash_receipt_id         = p_entity_id
                    FOR     UPDATE OF crh.cash_receipt_id,
                                      dist.source_id NOWAIT;

                cursor ps_cur is
                    select  'Found'  record_found
                    FROM    ar_payment_schedules ps
                    where   ps.cash_receipt_id  = p_entity_id
                    FOR     UPDATE OF ps.cash_receipt_id  NOWAIT;

                cursor ra_cur is
                    select  'Found'  record_found
                    FROM    ar_receivable_applications ra
                    where   ra.cash_receipt_id  = p_entity_id
                    FOR     UPDATE OF ra.cash_receipt_id  NOWAIT;

                cursor cr_cur is
                    select  'Found'  record_found
                    FROM    ar_cash_receipts  cr
                    where   cr.cash_receipt_id  = p_entity_id
                    FOR     UPDATE OF cr.cash_receipt_id  NOWAIT;

            BEGIN
                -- lock all the transaction records
                /* bug1999155: Divided the following select stmt into
                  some stmts. This cursor for loop is not used .
                FOR lock_rec IN (
                                  SELECT 'Found'  record_found
                                  FROM   ar_distributions dist,
                                         ar_payment_schedules ps,
                                         ar_receivable_applications ra,
                                         ar_cash_receipt_history crh,
                                         ar_cash_receipts cr
                                  WHERE  cr.cash_receipt_id = p_entity_id
                                  AND    cr.cash_receipt_id = crh.cash_receipt_id
                                  AND    cr.cash_receipt_id = ra.cash_receipt_id (+)
                                  AND    crh.cash_receipt_history_id = dist.source_id (+)
                                  AND    cr.cash_receipt_id = ps.cash_receipt_id (+)
                                  FOR    UPDATE OF cr.cash_receipt_id,
                                                   crh.cash_receipt_id,
                                                   ra.cash_receipt_id,
                                                   dist.source_id,
                                                   ps.cash_receipt_id NOWAIT
                               )
                LOOP
                    l_record_found := lock_rec.record_found ;
                END LOOP ;
                bug1999155 end */

                /* bug1999155 : Open created cursors to lock */
                open    dist_crh_cur;

                fetch   dist_crh_cur
                into l_record_found;

                --
                -- Need to verify if NO_DATA_FOUND will be raised if
                -- the cursor does not return any row.
                --
                IF l_record_found = 'Not Found'
                THEN
                   RETURN TRUE ; -- No Data Found
                END IF ;

                close   dist_crh_cur;

                open ps_cur;
                close ps_cur;

                open ra_cur;
                close ra_cur;

                open cr_cur;
                close cr_cur;

            EXCEPTION
                -- This receipt has already been deleted by an earlier process
                -- Ideal case when 2 invoices I1 and I2 have the same receipt R1
                -- applied against it.
                WHEN NO_DATA_FOUND THEN
                    RETURN TRUE; -- assume already processed in this thread
                WHEN locked_by_another_session THEN
                    print( p_recursive_level, ' ...locked by another session' );
                    RETURN FALSE; -- assume already processed in this thread
                WHEN OTHERS THEN
                    print( p_recursive_level, ' ...Failed while trying to lock CR' );
                    print( 1, 'sqlcode = ' || SQLCODE || SQLERRM ) ;
                    RAISE;
            END;
            --
            --  Check if it paid by the same customer
            --
            DECLARE
                l_same_customer  VARCHAR2(1);
            BEGIN
                IF p_customer_id IS NOT NULL THEN
                    BEGIN
                        SELECT  'Y'
                        INTO    l_same_customer
                        FROM    ar_cash_receipts
                        WHERE   cash_receipt_id = p_entity_id
                        AND     NVL( pay_from_customer, p_customer_id ) = p_customer_id ;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            print( p_recursive_level, ' ...Pymt made by different customer' );
                            RETURN FALSE ;
                        WHEN OTHERS THEN
                            print( p_recursive_level, ' ...Oracle Error at Cust Id. Check' );
                            RAISE;
                    END ;
                --
                END IF ;
            END;
            --
            -- check if open/closed
            --
            DECLARE
                l_ps_status    VARCHAR2(2);
            BEGIN
                SELECT  status
                INTO    l_ps_status
                FROM    ar_payment_schedules
                WHERE   cash_receipt_id = p_entity_id
                FOR     UPDATE OF payment_schedule_id NOWAIT ;

                IF l_ps_status = 'OP'  THEN
                    print( p_recursive_level,'  ...still open' );
                    RETURN FALSE;
                END IF;

            EXCEPTION
                WHEN locked_by_another_session THEN
                    print( p_recursive_level, ' ...pymt_sch locked by another session' );
                    RETURN ( FALSE ) ;

            END;
            -- search for unpurgeable history records
            DECLARE
                l_unpurgeable_histories   NUMBER;
            BEGIN
                SELECT  COUNT(*)
                INTO    l_unpurgeable_histories
                FROM    ar_cash_receipt_history
                WHERE   cash_receipt_id = p_entity_id
                AND
                (
                    posting_control_id = -3          OR
                    gl_date > p_as_of_gl_date
                );
                --
                IF l_unpurgeable_histories >0  THEN
                    print( p_recursive_level, '  ...unpurgeable CRH exist' );
                    RETURN FALSE;
                END IF;
                -- 5715943
                SELECT COUNT(*)
                INTO   l_unpurgeable_histories
                FROM   ar_cash_receipt_history
                WHERE  cash_receipt_id = p_entity_id
                AND    current_record_flag = 'Y'
                AND
                (
                     ( status =  'CLEARED' AND factor_flag = 'Y' ) OR
                     ( status IN ( 'APPROVED', 'REMITTED', 'CONFIRMED', 'REVERSED' ) )
                ) ;
                --
                -- 5715943
                IF l_unpurgeable_histories > 0 THEN
                    print( p_recursive_level, '  ...which has unpurgeable histories' );
                    RETURN FALSE;
                END IF;
            END;
            --
            -- check if there are any applications
            --

            DECLARE
                l_unpurgeable_applications     NUMBER;
            BEGIN
                SELECT  COUNT(*)
                INTO    l_unpurgeable_applications
                FROM    ar_receivable_applications
                WHERE   cash_receipt_id = p_entity_id
                AND
                (
                    posting_control_id = -3       OR
                    gl_date            > p_as_of_gl_date
                );

                IF  l_unpurgeable_applications > 0
                THEN
                    print( p_recursive_level, '  ...unpurgeable applications' );
                    RETURN FALSE;
                END IF;
            END;
            -- bug3655859 Added following check
            --
            -- check if there are related bank statement in CE
            --

            DECLARE
                l_statement_reconciliation     NUMBER;
            BEGIN
                SELECT  COUNT(*)
                INTO    l_statement_reconciliation
                FROM    ar_cash_receipt_history crh,
                        ce_statement_reconciliations sr
                WHERE   cash_receipt_id = p_entity_id
                AND     crh.cash_receipt_history_id = sr.reference_id
                AND     sr.reference_type = 'RECEIPT'
                AND     sr.current_record_flag = 'Y'
                AND     sr.status_flag = 'M' ;

                IF  l_statement_reconciliation > 0
                THEN
                    print( p_recursive_level, '  ...bank statement exists in CE ' );
                    RETURN FALSE;
                END IF;
            END;
            --
            -- delete records
            --
            DECLARE
		-- bug3384792 added
		TYPE BatchTyp IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
                l_batch_id  BatchTyp ;
                l_batch_id_null  BatchTyp ;
                l_trans_id NUMBER(15) ;

                --
                -- lock ar_batches row before deleting
                --
		-- bug33843792 removed outer join and changed to cursor
		CURSOR cur_batch_id(l_receipt_id NUMBER) IS
                SELECT bat.batch_id
                FROM   ar_batches bat,
                       (SELECT distinct batch_id
			FROM ar_cash_receipt_history
                	WHERE  cash_receipt_id = l_receipt_id) crh
               	WHERE   crh.batch_id = bat.batch_id
                FOR    UPDATE OF bat.batch_id NOWAIT ;
		--
		CURSOR cur_trans_id(l_receipt_id NUMBER) IS
                SELECT bat.transmission_request_id
                FROM   ar_batches bat,
                       ar_cash_receipt_history crh
                WHERE  crh.cash_receipt_id = l_receipt_id
                AND    crh.batch_id = bat.batch_id
		AND    crh.first_posted_record_flag = 'Y';

            BEGIN
                -- bug3384792 get batch info
		OPEN cur_batch_id(p_entity_id) ;
		FETCH cur_batch_id BULK COLLECT INTO l_batch_id ;
		CLOSE cur_batch_id ;
                --
		OPEN cur_trans_id(p_entity_id) ;
		FETCH cur_trans_id INTO l_trans_id ;
		CLOSE cur_trans_id ;
                --
                -- bug3975105 added 'N'
                print( p_recursive_level, '  ...deleting rows', 'N');
                --
                -- Call entity handler to delete from ar_cash_Receipts.
                -- DELETE FROM ar_cash_receipts
                -- WHERE  cash_receipt_id = p_entity_id;
                ARP_CASH_RECEIPTS_PKG.DELETE_P(p_entity_id);

                --
                DELETE FROM ar_distributions
                WHERE  source_id in
                (
                  SELECT cash_receipt_history_id
                  FROM   ar_cash_receipt_history
                  WHERE  cash_receipt_id = p_entity_id
                )
                AND    source_table = 'CRH';

                                --
                -- Bug 2021718: call the entity handler for
                -- ar_cash_receipt_history rather
                -- then doing the delete in this package.
                -- DELETE FROM ar_cash_receipt_history
                -- WHERE  cash_receipt_id = p_entity_id;

                arp_cr_history_pkg.delete_p_cr(p_entity_id);

                --
		-- bug3384792 there could be multiple records for one receipt.
		-- To handle the case, use BULK for delete stmt for ar_batches.
		-- And for performance, check whether or not there is batch.
		IF l_batch_id.COUNT>0
		THEN
		   FORALL i IN l_batch_id.FIRST..l_batch_id.LAST
                   DELETE FROM ar_batches
                   WHERE  batch_id = l_batch_id(i)
                   AND    NOT EXISTS ( SELECT 'x'
                                    FROM   ar_cash_receipt_history h
                                    WHERE  h.batch_id = l_batch_id(i) );

                   --
                   -- There could be multiple records within this batch
                   -- In this case, the above statement would not delete
                   -- this record.
                   --
		   FOR j IN l_batch_id.FIRST..l_batch_id.LAST
		   LOOP
		      IF SQL%BULK_ROWCOUNT(j) = 0
		      THEN
                         UPDATE ar_batches
                         SET purged_children_flag = 'Y'
                         WHERE batch_id = l_batch_id(j);
		      END IF;
		   END LOOP;


                   --
		   --
		   IF l_trans_id IS NOT NULL
		   THEN
		      DELETE from ar_transmissions trans
		      WHERE  transmission_request_id = l_trans_id
		      AND    NOT EXISTS
		      (
	 	         SELECT '*'
		         FROM ar_batches batch
		         WHERE batch.transmission_request_id = l_trans_id
		      );
		   END IF;
		END IF;

                --
                DELETE FROM ar_payment_schedules
                WHERE  cash_receipt_id = p_entity_id;

                --

                DELETE FROM ar_rate_adjustments
                WHERE  cash_receipt_id = p_entity_id;


                --
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    print( p_recursive_level, ' ...No rows found while attempting to lock' );
                    RETURN FALSE;
                WHEN locked_by_another_session THEN
                    print( p_recursive_level, ' ...locked by another session' );
                    RETURN FALSE;
                WHEN deadlock_detected THEN
                    print( p_recursive_level, ' ...deadlock detected while deleting from appls.' );
                    RETURN FALSE;
                WHEN OTHERS THEN
                    print( 1, 'Failed while deleting from CR tables');
                    print( 1, 'sqlcode = ' || SQLCODE || SQLERRM ) ;
                    RAISE ;
            END;
            --
            -- deal with applications
            --
            DECLARE
                CURSOR app_from_receipt( cp_cash_receipt_id NUMBER ) IS
                       SELECT  applied_customer_trx_id,
                               -- bug1199027
                               acctd_amount_applied_to,
                               NVL(acctd_earned_discount_taken,0) +
                                   NVL(acctd_unearned_discount_taken,0),
                               NVL(acctd_amount_applied_from,0) -
                                   NVL(acctd_amount_applied_to,0),
                               gl_date
                       FROM    ar_receivable_applications
                       WHERE   cash_receipt_id = cp_cash_receipt_id
                       AND     status          = 'APP'
                       FOR     UPDATE OF receivable_application_id NOWAIT ;

                l_applied_customer_trx_id  NUMBER;
                l_receipt_amount           NUMBER;
                l_discount_amount          NUMBER;
                l_gain_loss                NUMBER;
                l_gl_date                  DATE;
                l_period_name              VARCHAR2(15) ;
                l_status                   BOOLEAN;
                l_cnt_unapp_rows           NUMBER;


            BEGIN
                OPEN app_from_receipt( p_entity_id );
                ---
                ---
                LOOP
                    FETCH app_from_receipt
                    INTO  l_applied_customer_trx_id,
                          l_receipt_amount ,
                          l_discount_amount,
                          l_gain_loss,
                          l_gl_date ;
                    EXIT  WHEN app_from_receipt%NOTFOUND;
                    --
                    p_running_total := p_running_total - l_receipt_amount
                                           - l_discount_amount ;

                    -- To update ar_archive_control_detail with the
                    -- cash receipt amount. This rec. appln. record
                    -- will not exist when archive procedure is
                    -- called recursively.

                    l_period_name := get_period_name ( l_gl_date );
/* bug1199027
                    l_status := ins_control_detail_table ( NVL(l_receipt_amount,0),
                                                          'CASH',
                                                          'Y',
                                                          l_period_name,
                                                          l_archive_id  ) ;

                    IF (l_discount_amount <> 0)
                    THEN
                        l_status := ins_control_detail_table ( l_discount_amount,
                                                              'DISC',
                                                              'Y',
                                                              l_period_name,
                                                              l_archive_id  ) ;
                    END IF ;

                    IF (l_gain_loss <> 0)
                    THEN
                        l_status := ins_control_detail_table ( l_gain_loss,
                                                              'EXCH',
                                                              'Y',
                                                              l_period_name,
                                                              l_archive_id  ) ;
                    END IF ;
*/

                    --
                    DELETE FROM ar_receivable_applications
                    WHERE  cash_receipt_id = p_entity_id;


                    --
                    IF NOT recursive_purge( l_applied_customer_trx_id,
                                            'CT',
                                            p_as_of_gl_date,
                                            p_customer_id,
                                            p_archive_level,
                                            p_recursive_level+1,
                                            p_running_total )
                    THEN
                        CLOSE app_from_receipt;
                        add_to_unpurgeable_txns( l_applied_customer_trx_id );
                        RETURN FALSE;
                    END IF;
                END LOOP;
                CLOSE app_from_receipt;
                --
                DELETE FROM ar_distributions
                WHERE  source_id in ( SELECT receivable_application_id
                                      FROM   ar_receivable_applications
                                      WHERE  cash_receipt_id = p_entity_id
                                      AND    status  <> 'APP' )

                AND    source_table = 'RA' ;



               --

                --
                --  Need to lock the rows for status <> 'APP'.
                --  This delete is necessary to delete all the UNAPP rows
                --  in case of a single receipt applied against a single
                --  invoice.
                --
                BEGIN
                    FOR I in ( SELECT receivable_application_id
                               FROM   ar_receivable_applications
                               WHERE  cash_receipt_id = p_entity_id
                               AND    status <> 'APP'
                               FOR  UPDATE OF receivable_application_id NOWAIT )
                    LOOP
                        DELETE FROM ar_receivable_applications
                        WHERE  receivable_application_id =
                                   I.receivable_application_id;

                /*---------------------------------+
                 | Calling central MRC library     |
                 | for MRC Integration             |
                 +---------------------------------*/

              /*  ar_mrc_engine.maintain_mrc_data(
                        p_event_mode        => 'DELETE',
                        p_table_name        => 'AR_RECEIVABLE_APPLICATIONS',
                        p_mode              => 'SINGLE',
                        p_key_value         => I.receivable_application_id);*/

                        --
                    END LOOP ;
                EXCEPTION
                    WHEN locked_by_another_session THEN
                         print( p_recursive_level, ' ...appl.locked by another session' );
                         RETURN FALSE;
                    WHEN deadlock_detected THEN
                         print( p_recursive_level, ' ...deadlock detected while deleting UNAPP rows
' );
                         RETURN FALSE;
                END ;
                --
            EXCEPTION
                WHEN locked_by_another_session THEN
                    print( p_recursive_level, ' ...locked by another session' );
                    RETURN FALSE;
                WHEN deadlock_detected THEN
                    print( p_recursive_level, ' ...deadlock detected in app_from_receipt' );
                    RETURN FALSE;
                WHEN OTHERS THEN
                    print( p_recursive_level, ' ...Failed while trying to lock rec. app.');
                    print( 1, 'sqlcode = ' || SQLCODE || SQLERRM ) ;
                    RAISE ;
            END;
            RETURN TRUE;
        END IF;
        RETURN TRUE; -- Not reqd.

    EXCEPTION
        WHEN OTHERS THEN
            print( 1, 'Failed in Recursive purge') ;
            print( 1, 'sqlcode = ' || SQLCODE || SQLERRM ) ;
            RAISE ;
    END;
    --
    PROCEDURE drive_by_invoice( errbuf           OUT NOCOPY VARCHAR2,
                                retcode          OUT NOCOPY NUMBER,
                                p_start_gl_date  IN  DATE, --bug1199027
                                p_end_gl_date    IN  DATE, --bug1199027
                                p_as_of_gl_date  IN  DATE, --bug1199027
                                p_archive_level  IN  VARCHAR2,
                                p_archive_id     IN  NUMBER,
                                p_total_worker   IN  NUMBER,
                                p_worker_number  IN  NUMBER,
                                p_customer_id    IN  NUMBER,
                                p_short_flag     IN  VARCHAR2) IS
        --
        --  Earlier, it was driven from RA_CUST_TRX_LINE_GL_DIST
        --  To improve the performance, the code is changed
        --  so that it drives from AR_PAYMENT_SCHEDULES.
        --  This will not handle the cases where the
        --  open_receivable flag for the transaction_type is set
        --  to 'N'. This is the intended behaviour to improve
        --  the performance.
        --
        -- bug1199027 Use cp_start/end_gl_date instead of l_as_of_gl_date
        CURSOR c_inv( cp_start_gl_date DATE, cp_end_gl_date DATE,
                      cp_customer_id   NUMBER ,
                      cp_max_trx_id    NUMBER) IS
        SELECT ct.customer_trx_id          customer_trx_id
        FROM   ra_cust_trx_types           ctt,
               ra_customer_trx             ct,
               ar_payment_schedules        ps
        WHERE  ct.initial_customer_trx_id  IS NULL
        AND    ps.customer_trx_id          = ct.customer_trx_id
        -- bug1199027
        AND    ps.gl_date_closed           BETWEEN cp_start_gl_date
                                           AND     cp_end_gl_date
        -- bug2967315 added DM
        AND    ps.class                    IN ('INV','CM', 'DM')
        AND    NVL(cp_customer_id, 0 )     = DECODE(cp_customer_id, NULL,0,
                                                 ct.bill_to_customer_id )
        AND    ps.terms_sequence_number     = 1
        AND    ctt.cust_trx_type_id        = ct.cust_trx_type_id
        AND    ctt.type                    NOT IN ('DEP', 'GUAR' )
        -- bug2472294
        -- AND    ctt.post_to_gl              = 'Y'  -- just handle gl_date < cut-off date
        AND    ct.complete_flag = 'Y'
        AND    ct.customer_trx_id > cp_max_trx_id  -- bug1715258
        ORDER BY ct.customer_trx_id  ;  -- bug1715258

        -- bug1715258
        r_inv  c_inv%ROWTYPE ;
        l_max_trx_id     NUMBER := 0 ;
        l_max_record     NUMBER := 500 ;

        TYPE inv_table IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
        l_inv_table      inv_table;
        -- bug3990664 added
        l_inv_table_null inv_table;
        l_inv_rows       BINARY_INTEGER := 0;
        l_inv_cnt        BINARY_INTEGER := 0;
        l_trx_id         NUMBER ;
        -- bug1715258


        l_running_total  NUMBER ;
        l_existence      NUMBER(2) ;
        -- l_archive_status BOOLEAN ; --bug1199027
        l_arch_status    BOOLEAN ; -- bug1199027
        --l_as_of_gl_date  DATE ; -- bug1199027
        l_cnt_of_chains  NUMBER := 0 ;
        l_org_id         NUMBER ; /* Bug 5290308 */

    BEGIN

	/*Bug 5349016 Commenting the below code as it is handled in ARARCALL.sql
        -- Bug 5290308 : Set the org_context
        fnd_profile.get('ORG_ID', l_org_id);
        mo_global.init ('AR');
        mo_global.set_policy_context('S',l_org_id);
        arp_global.init_global(l_org_id);
        arp_standard.init_standard(l_org_id);
	*/

        /* bug3975105 added */
	IF p_short_flag = 'Y' THEN
           l_short_flag := p_short_flag;
	   print(0,'(Show only unpurged items)');
	END IF;
        --
        --l_as_of_gl_date := TRUNC(to_date(p_as_of_gl_date,'DD-MON-YYYY'));
        -- bug1199027
        --l_as_of_gl_date := FND_DATE.canonical_to_date(p_as_of_gl_date) ;
        --
        l_archive_id := p_archive_id ;
        --
        print( 0,'Starting Archive and Purge Process');
        print( 0,'----------------------------------');
        --

        -- bug 1715258
        -- Change logic to prevent "Snapshot too old" error
        --
        LOOP

           l_inv_cnt := 0 ;

           /* 3990664: added initialization */
           l_inv_table := l_inv_table_null ;

           -- bug1199027 Use cp_start/end_gl_date instead of l_as_of_gl_date
           OPEN c_inv(p_start_gl_date,p_end_gl_date,
				p_customer_id , l_max_trx_id) ;

           -- bug3990664: changed to BULK FETCH
              FETCH c_inv BULK COLLECT INTO l_inv_table LIMIT l_max_record;

           CLOSE c_inv ;

           -- bug1715258
           -- set max trx id to l_max_trx_id in order not to process
           -- same trx id.
           -- bug3990664 : added
           l_inv_cnt := l_inv_table.COUNT ;

           -- bug3990664 : modified
           /* Bug fix 5290308 : Try to access the table only if it contains records */
           IF l_inv_cnt  > 0 THEN
               l_max_trx_id := l_inv_table(l_inv_table.last) ;
           END IF;

           IF l_inv_cnt > 0 THEN
              FOR l_inv_rows IN l_inv_table.first..l_inv_table.last LOOP

              BEGIN
                --
                SAVEPOINT prior_to_inv;
                --
                l_running_total := 0 ;
                l_cnt_of_chains := l_cnt_of_chains + 1 ;
                l_trx_id        := l_inv_table(l_inv_rows); -- bug1715258
                l_inv_table.delete(l_inv_rows); -- bug1715258
                --
                -- Just to make sure that this trx is not deleted
                -- by another instance when called recursively
                --
                SELECT 1
                INTO   l_existence
                FROM   RA_CUSTOMER_TRX
                WHERE  customer_trx_id = l_trx_id
                FOR    UPDATE OF customer_trx_id  NOWAIT ;

                -- lock all the corresponding records

                IF l_existence = 0 THEN
                   print(0, l_trx_id || ' ...already purged by another instance') ;
                   GOTO continue ;
                END IF ;
    --
                IF recursive_purge( l_trx_id,
                                    'CT',
                                    p_as_of_gl_date,
                                    p_customer_id,
                                    p_archive_level,
                                    0,
                                    l_running_total )
                THEN
                    IF l_running_total = 0
                    THEN
                       -- bug1199027
                       l_arch_status := upd_arch_control_detail( p_archive_id ) ;
                       l_control_detail_array.delete ;
                       --
                       -- bug3975105 added 'S'
                       print( 0,'Successful purge' , 'S');
                       COMMIT;
                       --
                    ELSE
                       print( 1,'...Running total is not Zero ');
                       -- bug3975105 added 'N'
                       print( 0, 'Rollback work', 'N');
                       add_to_unpurgeable_txns( l_trx_id );
                       -- bug1199027
                       l_control_detail_array.delete ;
                       --
                       ROLLBACK TO prior_to_inv;
                    END IF ;
                ELSE
                    -- bug3975105 added 'N'
                    print( 0, 'Rollback Work', 'N');
                    add_to_unpurgeable_txns( l_trx_id );
                    -- bug1199027
                    l_control_detail_array.delete ;
                    --
                    ROLLBACK TO prior_to_inv;
                END IF;
                << continue >>
                -- bug3975105 added 'N'
                print( 0, '------------------------------------------------------------', 'N' );
                IF ( l_cnt_of_chains MOD 500 ) = 0 THEN
                     -- bug3975105 added 'N'
                     print(0, 'No. of Chains processed so far : ' || l_cnt_of_chains , 'N') ;
                     print( 0, '------------------------------------------------------------', 'N' );
                END IF ;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                   print( 0,'Id : ' || l_trx_id ) ;
                   print( 0, '...deleted by another instance' );
                   print( 0, '------------------------------------------------------------' );
                   ROLLBACK TO prior_to_inv; -- bug1999155
                   -- bug1199027
                   IF ( l_cnt_of_chains MOD 500 ) = 0 THEN
                        print(0, 'No. of Chains processed so far : ' || l_cnt_of_chains ) ;
                        print( 0, '------------------------------------------------------------' );
		   END IF;
                WHEN locked_by_another_session THEN
                   print( 0,'...locked by another session ') ;
                   print( 0, '------------------------------------------------------------' );
                   ROLLBACK TO prior_to_inv;
                   -- bug1199027
                   IF ( l_cnt_of_chains MOD 500 ) = 0 THEN
                        print(0, 'No. of Chains processed so far : ' || l_cnt_of_chains ) ;
                        print( 0, '------------------------------------------------------------' );
                   END IF ;
                WHEN savepoint_not_established THEN
                   print( 0,'...Savepoint not established') ;
                   print( 0, '------------------------------------------------------------' );
                   ROLLBACK ; -- bug1999155
                   RAISE ;
                WHEN OTHERS THEN
                   print( 1, 'Failed in the for loop') ;
                   print( 1, 'sqlcode = ' || SQLCODE || SQLERRM ) ;
                   ROLLBACK TO prior_to_inv; -- bug1999155
                   RAISE ;
              END ;
              END LOOP ;

           END IF;

           -- bug1715258
           --
           -- Exit when already get last record
           --
           EXIT WHEN l_inv_cnt < l_max_record ;

        END LOOP;
        print( 0,'------------------------------------------------------------ ' );
        print( 0,'Total No. of Chains Processed : ' || l_cnt_of_chains );
        print( 0,'End Time : ' || to_char(sysdate,'dd-mon-yyyy hh:mi:ss') );
        print( 0,'------------------------------ End ------------------------- ' );

    EXCEPTION
        WHEN OTHERS THEN
            print( 1, 'sqlcode = ' || SQLCODE || SQLERRM ) ;
            print( 1, 'Failed in drive_by_invoice') ;
            ROLLBACK ;
            print( 0,'------------------------------------------------------------ ' );
            print( 0,'Total No. of Chains Processed : ' || l_cnt_of_chains );
            print( 0,'End Time : ' || to_char(sysdate,'dd-mon-yyyy hh:mi:ss') );
            print( 0,'------------------------------ End ------------------------- ' );
            fnd_file.put_line (FND_FILE.LOG, 'Error ' || SQLCODE || ' ' || SQLERRM ) ;
            RAISE ;
    END;

END;

/
