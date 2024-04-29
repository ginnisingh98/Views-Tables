--------------------------------------------------------
--  DDL for Package Body IGIRCBID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGIRCBID" AS
-- $Header: igircidb.pls 120.4.12000000.2 2007/11/08 17:42:59 sguduru ship $

--following variables added for bug 3199481: fnd logging changes: sdixit
   l_debug_level number;
   l_state_level number;
   l_proc_level number;
   l_event_level number;
   l_excep_level number;
   l_error_level number;
   l_unexp_level number;

    PROCEDURE WritetoLog (pp_line in varchar2) IS
       l_debug_mode BOOLEAN := FALSE;
    BEGIN
       IF pp_line IS NULL THEN
          return;
       END IF;
       IF l_debug_mode THEN
         fnd_file.put_line( FND_FILE.log, 'IGIRCBID '||pp_line );
       ELSE
         null;
       END IF;
    END;

    PROCEDURE PostNonDistApplications( p_Prepare IN ParametersType  ) IS

        CURSOR CRa IS
        SELECT  DISTINCT
                ra.receivable_application_id
        FROM    ar_receivable_applications    ra,
                ar_cash_receipts              cr
        WHERE   ra.gl_date >=  p_Prepare.GlDateFrom
        AND     ra.gl_date <=  p_Prepare.GlDateTo
        AND     nvl(ra.postable,'Y')           = 'Y'
        AND     nvl(ra.confirmed_flag,'Y')     = 'Y'
        AND     ra.status                      <> 'APP'  -- Bug 3519052
        AND     ra.application_type||''        = 'CASH'
        AND     cr.cash_receipt_id             = ra.cash_receipt_id
        AND     ra.set_of_books_id             = p_Prepare.SetOfBooksId
        ;
--
    l_Count         NUMBER  :=0;

         FUNCTION IsRecordCopiedBefore ( fp_app_id in number) return boolean
        IS
             CURSOR c_app is
                  select 'x'
                  from   igi_ar_rec_applications_all igi
                  where  igi.receivable_application_id = fp_app_id
                  ;
        BEGIN
            FOR l_app IN c_app LOOP
                return TRUE;
            END LOOP;
            return FALSE;
        EXCEPTION WHEN OTHERS THEN
            return FALSE;
        END IsRecordCopiedBefore;


    BEGIN

        IF (l_proc_level >=  l_debug_level ) THEN
           FND_LOG.STRING  (l_proc_level , 'igi.plsql.igircidb.PostNonDistApplications',
                          ' Begin PostNonDistApplications ');
        END IF;

        FOR LRA in CRa LOOP
        IF (NOT IsRecordCopiedBefore( LRA.receivable_application_id ))
        THEN
--
               INSERT INTO igi_ar_rec_applications_all
                          ( receivable_application_id
                          , arc_posting_control_id
                          , last_update_date
                          , last_updated_by
                          , last_update_login
                          , creation_Date
                          , created_by
                          )
               VALUES ( LRA.receivable_application_id
                      , -3
                      , sysdate
                      , fnd_global.user_id
                      , fnd_global.login_id
                      , sysdate
                      , fnd_global.user_id
                      );

--
                l_Count := l_Count + 1;
--
        END IF;
--
        END LOOP;
        IF (l_proc_level >=  l_debug_level ) THEN
           FND_LOG.STRING  (l_proc_level , 'igi.plsql.igircidb.PostNonDistApplications',
                          ' Count : ' || l_count);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            WritetoLog( 'Exception:PostNonDistApplications:' );
            RAISE;
    END;
--
    PROCEDURE PostDistributedApplications( p_Prepare IN ParametersType  ) IS
        CURSOR CRa IS
        SELECT  DISTINCT
        DECODE(
            l.lookup_code,
            '1', 'N',
            '2', 'Y'
            )                  CmPsIdFlag,
                ra.receivable_application_id
        FROM    ar_receivable_applications    ra,
                ra_cust_trx_types             ctt,
                ra_customer_trx               ct,
                ar_cash_receipts              cr,
                ar_cash_receipt_history       crh,
                ra_customer_trx               ctcm,
                ar_lookups            l
        WHERE   ra.gl_date                         BETWEEN p_Prepare.GlDateFrom
                                                   AND     p_Prepare.GlDateTo
        AND nvl(ra.postable,'Y')           = 'Y'
        AND nvl(ra.confirmed_flag,'Y')     = 'Y'
        AND     ra.status||''              = 'APP'  -- Bug 3519052
        AND     ra.cash_receipt_id         = cr.cash_receipt_id(+)
        AND ra.cash_receipt_history_id     = crh.cash_receipt_history_id(+)
        AND     ra.customer_trx_id         = ctcm.customer_trx_id(+)
        AND ctcm.previous_customer_trx_id      IS NULL
        AND     ra.applied_customer_trx_id     = ct.customer_trx_id
        AND     ct.cust_trx_type_id            = ctt.cust_trx_type_id
        AND     ra.set_of_books_id             = p_Prepare.SetOfBooksId
        AND l.lookup_type              = 'AR_CARTESIAN_JOIN'
        AND     (
                ( l.lookup_code ='1' )
                OR
                ( l.lookup_code = '2'
                      AND
                      ra.application_type = 'CM' )
            )
    ;
--
    l_Count         NUMBER  :=0;


        FUNCTION IsRecordCopiedBefore ( fp_app_id in number) return boolean
        IS
             CURSOR c_app is
                  select 'x'
                  from   igi_ar_rec_applications_all igi
                  where  igi.receivable_application_id = fp_app_id
                  ;
        BEGIN
            FOR l_app IN c_app LOOP
                return TRUE;
            END LOOP;
            return FALSE;
        EXCEPTION WHEN OTHERS THEN
            return FALSE;
        END IsRecordCopiedBefore;


    BEGIN
        IF (l_proc_level >=  l_debug_level ) THEN
            FND_LOG.STRING  (l_proc_level , 'igi.plsql.igircidb.PostDistributedApplications',
                          ' Begin PostDistributedApplications ');
        END IF;
        FOR LRA in CRa LOOP
        IF (LRA.CmPsIdFlag <> 'Y') AND (NOT IsRecordCopiedBefore( LRA.receivable_application_id ))
        THEN

               INSERT INTO igi_ar_rec_applications_all
                          ( receivable_application_id
                          , arc_posting_control_id
                          , last_update_date
                          , last_updated_by
                          , last_update_login
                          , creation_Date
                          , created_by
                          )
               VALUES ( LRA.receivable_application_id
                      , -3
                      , sysdate
                      , fnd_global.user_id
                      , fnd_global.login_id
                      , sysdate
                      , fnd_global.user_id
                      );

--
                l_Count := l_Count + 1;
--
        END IF;
--
        END LOOP;
        IF (l_proc_level >=  l_debug_level ) THEN
            FND_LOG.STRING  (l_proc_level , 'igi.plsql.igircidb.PostDistributedApplications',
                          ' Count : ' || l_count);
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            WritetoLog( 'Exception:PostDistributedApplications:' );
            RAISE;
    END;
    PROCEDURE PostCashReceiptHistory( p_Prepare IN ParametersType ) IS
        CURSOR CCrh IS
        SELECT  distinct crh.cash_receipt_history_id
        FROM    ar_cash_receipt_history          crh,
                ar_cash_receipts                 cr,
                ar_distributions                 d
        WHERE  crh.gl_date                      BETWEEN p_Prepare.GlDateFrom
                                                 AND     p_Prepare.GlDateTo
        AND     crh.postable_flag                = 'Y'
        AND     cr.cash_receipt_id               = crh.cash_receipt_id
        AND crh.cash_receipt_history_id      = d.source_id
        AND d.source_table = 'CRH' ;
--
    l_Count         NUMBER  :=0;

        FUNCTION IsRecordCopiedBefore ( fp_crh_id in number) return boolean
        IS
             CURSOR c_crh is
                  select 'x'
                  from   igi_ar_cash_receipt_hist_all igi
                  where  igi.cash_receipt_history_id = fp_crh_id
                  ;
        BEGIN
            FOR l_crh IN c_crh LOOP
                return TRUE;
            END LOOP;
            return FALSE;
        EXCEPTION WHEN OTHERS THEN
            return FALSE;
        END IsRecordCopiedBefore;

    BEGIN
        IF (l_proc_level >=  l_debug_level ) THEN
        FND_LOG.STRING  (l_proc_level , 'igi.plsql.igircidb.PostCashReceiptHistory',
                          ' Begin PostCashReceiptHistory ');
        END IF;
        FOR lcrh in CCRH LOOP

           IF IsRecordCopiedBefore ( lcrh.cash_receipt_history_id) THEN
              NULL;
            ELSE

              BEGIN
                 INSERT into igi_ar_cash_receipt_hist_all (
                             cash_receipt_history_id
                             , last_update_date
                             , last_updated_by
                             , last_update_login
                             , creation_date
                             , created_by
                             , arc_rev_post_control_id
                             , arc_posting_control_id

                             ) values
                             ( lcrh.cash_receipt_history_id
                             , sysdate
                             , fnd_global.user_id
                             , fnd_global.conc_login_id  -- bug 4119243
                             , sysdate
                             , fnd_global.user_id -- bug 4119243
                             , null
                             , -3
                             );
               EXCEPTION WHEN OTHERS THEN
                             null;
               END;

               l_Count := l_Count + 1;
            END IF;

        END LOOP;
        IF (l_proc_level >=  l_debug_level ) THEN
           FND_LOG.STRING  (l_proc_level , 'igi.plsql.igircidb.PostCashReceiptHistory',
                          ' Count : ' || l_count);
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            WritetoLog( 'PostCashReceiptHistory:' );
            RAISE;
    END;
--
    PROCEDURE PostRevCashReceiptHist( p_Prepare IN ParametersType ) IS
        CURSOR CCrh IS
        SELECT  distinct crh.cash_receipt_history_id
        FROM    ar_cash_receipt_history          crh,
                ar_cash_receipts                 cr,
                ar_distributions                 d
        WHERE  crh.reversal_gl_date              BETWEEN p_Prepare.GlDateFrom
                                                 AND     p_Prepare.GlDateTo
        AND     crh.postable_flag                = 'Y'
        AND     cr.cash_receipt_id               = crh.cash_receipt_id
        AND crh.cash_receipt_history_id      = d.source_id
        AND d.source_table = 'CRH' ;
--
    l_Count         NUMBER  :=0;

        FUNCTION IsRecordCopiedBefore ( fp_crh_id in number) return boolean
        IS
             CURSOR c_crh is
                  select 'x'
                  from   igi_ar_cash_receipt_hist_all igi
                  where  igi.cash_receipt_history_id = fp_crh_id
                  ;
        BEGIN
            FOR l_crh IN c_crh LOOP
                return TRUE;
            END LOOP;
            return FALSE;
        EXCEPTION WHEN OTHERS THEN
            return FALSE;
        END IsRecordCopiedBefore;

    BEGIN
        IF (l_proc_level >=  l_debug_level ) THEN
           FND_LOG.STRING  (l_proc_level , 'igi.plsql.igircidb.PostRevCashReceiptHist',
                          ' Begin PostRevCashReceiptHist ');
        END IF;
        FOR lcrh in CCRH LOOP

           IF IsRecordCopiedBefore ( lcrh.cash_receipt_history_id) THEN

              UPDATE igi_Ar_cash_receipt_hist_all
              SET    arc_rev_post_control_id = -3
              ,      arc_rev_gl_posted_date  = null
              WHERE  cash_receipt_history_id = lcrh.cash_receipt_history_id
              ;

            ELSE

              BEGIN
                 INSERT into igi_ar_cash_receipt_hist_all (
                             cash_receipt_history_id
                             , last_update_date
                             , last_updated_by
                             , last_update_login
                             , creation_date
                             , created_by
                             , arc_posting_control_id
                             , arc_rev_post_control_id
                             ) values
                             ( lcrh.cash_receipt_history_id
                             , sysdate
                             , fnd_global.user_id
                             , fnd_global.conc_login_id  -- bug 4119243
                             , sysdate
                             , fnd_global.user_id
                             , -3	-- Bug 3519052
                             , null
                             );
               EXCEPTION WHEN OTHERS THEN
                             null;
               END;

               l_Count := l_Count + 1;
            END IF;

        END LOOP;
        IF (l_proc_level >=  l_debug_level ) THEN
            FND_LOG.STRING  (l_proc_level , 'igi.plsql.igircidb.PostRevCashReceiptHist',
                          ' Count : ' || l_count);
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            WritetoLog( 'PostRevCashReceiptHist:' );
            RAISE;
    END;
--

    PROCEDURE PostMiscCashDistributions( p_Prepare IN ParametersType ) IS
        CURSOR CMcd IS
        SELECT  distinct mcd.misc_cash_distribution_id
        FROM    ar_misc_cash_distributions    mcd,
                ar_cash_receipts              cr
        WHERE   mcd.gl_date                            BETWEEN p_Prepare.GlDateFrom
                                                       AND     p_Prepare.GlDateTo
        AND     mcd.set_of_books_id                  = p_Prepare.setofbooksid
        AND     cr.cash_receipt_id                   = mcd.cash_receipt_id ;
--

    l_Count         NUMBER  :=0;

        FUNCTION IsRecordCopiedBefore ( fp_mcd_id in number) return boolean
        IS
             CURSOR c_mcd is
                  select 'x'
                  from   igi_ar_misc_cash_dists_all igi
                  where  igi.misc_cash_distribution_id = fp_mcd_id
                  ;
        BEGIN
            FOR l_mcd IN c_mcd LOOP
                return TRUE;
            END LOOP;
            return FALSE;
        EXCEPTION WHEN OTHERS THEN
            return FALSE;
        END IsRecordCopiedBefore;
    BEGIN
        IF (l_proc_level >=  l_debug_level ) THEN
            FND_LOG.STRING  (l_proc_level , 'igi.plsql.igircidb.PostMiscCashDistributions',
                          ' Begin PostMiscCashDistributions ');
        END IF;

        FOR RMcd IN CMcd
        LOOP
            -- first create the debit in gl_interface to the account_code_combination_id
            IF NOT IsRecordCopiedBefore (Rmcd.misc_cash_distribution_id) THEN
                    INSERT INTO  igi_ar_misc_cash_dists_all (
                               misc_cash_distribution_id
                               , arc_posting_control_id
                               , last_update_date
                               , last_updated_by
                               , last_update_login
                               , creation_date
                               , created_by
                              ) VALUES (
                                  Rmcd.misc_cash_distribution_id
                                  , -3
                                  , sysdate
                                  , fnd_global.user_id
                                  , fnd_global.login_id
                                  , sysdate
                                  , fnd_global.user_id
                              );
                     l_Count := l_Count + 1;
             END IF;

        END LOOP;
        IF (l_proc_level >=  l_debug_level ) THEN
            FND_LOG.STRING  (l_proc_level , 'igi.plsql.igircidb.PostMiscCashDistributions',
                           ' Count : ' || l_count);
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            WritetoLog( 'PostMiscCashDistributions:' );
            RAISE;
    END;

FUNCTION ar_nls_text
        ( p_message_name    VARCHAR2
        ) RETURN VARCHAR2 IS
l_message_text VARCHAR2(240);
BEGIN
    SELECT message_text
      INTO l_message_text
      FROM fnd_new_messages
     WHERE application_id = 222
       AND message_name = p_message_name;
     return(l_message_text);
EXCEPTION
   WHEN OTHERS THEN
return(p_message_name);
end;

--
-- --------------------------------------------------------------------------
--
--

    PROCEDURE Prepare( p_prepare       IN ParametersType ) IS
       BEGIN

        PostCashReceiptHistory( p_prepare );
        PostRevCashReceiptHist ( p_Prepare );
        PostMiscCashDistributions( p_prepare );
        PostNonDistApplications( p_prepare );
        PostDistributedApplications( p_prepare );

    EXCEPTION
        WHEN OTHERS THEN
            WritetoLog( 'Exception: IGIRCBID.Prepare ( p_Prepare ):'||sqlerrm );
            RAISE_APPLICATION_ERROR( -20000, sqlerrm||'Exception: IGIRCBID.Prepare ( p_Prepare ):' );
    END;

    PROCEDURE CopyData ( p_GlDateFrom          IN  DATE
                       , p_GlDateTo            IN  DATE
                       , p_GlPostedDate        IN  DATE
                       , p_CreatedBy           IN  NUMBER
                       , p_SummaryFlag         IN  VARCHAR2 ) IS

         l_SetOfBooksId        NUMBER;
         l_CashSetOfBooksId    NUMBER;
         l_ra_id           NUMBER;
         l_crh_id          NUMBER;
         l_mcd_id          NUMBER;
         l_balanceflag     VARCHAR2(1);


    BEGIN
        WritetoLog ( 'IGIRCBID : Begin LOG...');
          Prepare
                ( p_GlDateFrom
        , p_GlDateTo
        , p_GlPostedDate
       ) ;
       WritetoLog ( 'IGIRCBID : End  LOG...');

    END;


    PROCEDURE Prepare
                (
         p_GlDateFrom          IN  DATE
        , p_GlDateTo            IN  DATE
        , p_GlPostedDate        IN  DATE
        ) IS
    l_prepare  ParametersType;
    l_BalanceFlag   Varchar2(1);
    BEGIN
        l_prepare.GlDateFrom       := p_GlDateFrom;
        l_prepare.GlDateTo         := p_GlDateTo + (86399/86400);
        l_prepare.GlPostedDate     := p_GlPostedDate;

    SELECT -- sob.currency_code,
         sp.set_of_books_id
         , igisp.arc_cash_sob_id
         , igisp.arc_unalloc_rev_ccid
      INTO -- l_prepare.FuncCurr ,
         l_prepare.SetOfBooksId
         , l_prepare.CashSetOfBooksId
         , l_prepare.UnallocatedRevCcid
      FROM ar_system_parameters sp
         , igi_ar_system_options igisp
         , gl_sets_of_books sob
     WHERE sob.set_of_books_id = sp.set_of_books_id;

    BEGIN

        Prepare ( l_prepare );

    EXCEPTION
        WHEN OTHERS THEN
            WritetoLog( 'Exception:IGIRCBID.Prepare( ... ):'||sqlerrm );
            RAISE;
    END;

   END Prepare;

    PROCEDURE Prepare(
         p_GlDateFrom          IN  DATE
        , p_GlDateTo            IN  DATE
        , p_GlPostedDate        IN  DATE
        , p_SetOfBooksId        IN NUMBER
        , p_CashSetOfBooksId    IN NUMBER
        ) IS

    l_prepare  ParametersType;

    BEGIN

        l_prepare.GlDateFrom       := p_GlDateFrom;
        l_prepare.GlDateTo         := p_GlDateTo + (86399/86400);
        l_prepare.GlPostedDate     := p_GlPostedDate;
        l_prepare.SetOfBooksId     := p_SetOfBooksId;
        l_prepare.CashSetOfBooksId := p_CashSetOfBooksId;

        Prepare ( l_prepare );

    EXCEPTION
        WHEN OTHERS THEN
            WritetoLog( 'Exception:IGIRCBID.Prepare( ... ):'||sqlerrm );
            RAISE;
    END;
--
--

BEGIN

   l_debug_level 	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   l_state_level 	:=	FND_LOG.LEVEL_STATEMENT;
   l_proc_level  	:=	FND_LOG.LEVEL_PROCEDURE;
   l_event_level 	:=	FND_LOG.LEVEL_EVENT;
   l_excep_level 	:=	FND_LOG.LEVEL_EXCEPTION;
   l_error_level 	:=	FND_LOG.LEVEL_ERROR;
   l_unexp_level 	:=	FND_LOG.LEVEL_UNEXPECTED;

END IGIRCBID;

/
