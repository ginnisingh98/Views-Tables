--------------------------------------------------------
--  DDL for Package Body IGIPMSLR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGIPMSLR" AS
-- $Header: igipmslb.pls 115.6 2003/12/01 15:00:09 sdixit ship $
-- ---------
-- SUBTYPES
-- --------
SUBTYPE SUBLGR   IS   IGI_MPP_SUBLEDGER%ROWTYPE;
-- ---------
-- CONSTANTS
-- ---------

AP_APPLICATION_ID   CONSTANT NUMBER(15)  := 200;
G_USER_ID           CONSTANT NUMBER(15)  := fnd_global.user_id;
G_DATE              CONSTANT DATE        := sysdate;
G_LOGIN_ID          CONSTANT NUMBER(15)  := fnd_global.login_id;
--bug 3199481: following variables added for fnd logging changes:sdixit :start
   l_debug_level number	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   l_state_level number	:=	FND_LOG.LEVEL_STATEMENT;
   l_proc_level number	:=	FND_LOG.LEVEL_PROCEDURE;
   l_event_level number	:=	FND_LOG.LEVEL_EVENT;
   l_excep_level number	:=	FND_LOG.LEVEL_EXCEPTION;
   l_error_level number	:=	FND_LOG.LEVEL_ERROR;
   l_unexp_level number	:=	FND_LOG.LEVEL_UNEXPECTED;

-- ----------
-- CURSORS
-- ----------

   CURSOR  c_dist ( cp_invoice_id in number
                  , cp_distribution_line_number in number
                  )
   IS
     SELECT dist.invoice_id, dist.set_of_books_id, dist.period_name, dist.amount
            , dist.distribution_line_number, dist.dist_code_combination_id
            , dist.description, dist.accounting_date, gsob.chart_of_accounts_id
            , dist.base_amount, dist.exchange_rate, dist.exchange_date,
              dist.exchange_rate_type, gsob.currency_code functional_currency_code
     FROM   ap_invoice_distributions dist
            , gl_sets_of_books gsob
     WHERE  dist.distribution_line_number = cp_distribution_line_number
     AND    dist.set_of_books_id          = gsob.set_of_books_id
     AND    dist.invoice_id               = cp_invoice_id
     ;


   CURSOR  c_ext_dist ( cp_invoice_id in number
                  , cp_distribution_line_number in number
                  )
   IS
     SELECT ext_dist.*
     FROM   igi_mpp_ap_invoice_dists_det  ext_dist
     WHERE  ext_dist.distribution_line_number = cp_distribution_line_number
     AND    ext_dist.invoice_id               = cp_invoice_id
     ORDER  BY ext_dist.mpp_dist_line_number
     ;

-- ----------------
-- COMMON PROCEDURES
-- -----------------

   PROCEDURE WriteToLog ( pp_mesg in varchar2 ) IS
   BEGIN
      -- FND_FILE.put_line( FND_FILE.log, pp_mesg );
      null;
   END;

-- -----------------
-- FUNCTIONS
-- -----------------
   FUNCTION  GetInvoiceCurrency ( fp_invoice_id in number)
   RETURN VARCHAR2
   IS
     CURSOR C_curr IS
        SELECT invoice_currency_code
        from   ap_invoices
        where  invoice_id = fp_invoice_id
        ;
   BEGIN
      FOR l_curr in C_curr LOOP
          return l_curr.invoice_currency_code;
      END LOOP;
      return '-1';
   END GetInvoiceCurrency;

   FUNCTION ExistsOffsetEntries ( p_invoice_id in number
                                    , p_distribution_line_number in number
                                    )
   RETURN BOOLEAN IS
       CURSOR c_exists IS
         SELECT count('x') ct
         FROM   igi_mpp_subledger
         WHERE  invoice_id = p_invoice_id
         AND    distribution_line_number = p_distribution_line_number
         AND    reference1 = '0'
         ;
   BEGIN
       FOR l_exists in c_exists LOOP
          IF l_exists.ct = 2 THEN
             return TRUE;
          END IF;
       END LOOP;
       return FALSE;
   END ExistsOffsetEntries;

   FUNCTION ExistsRecognizedEntries ( p_invoice_id in number
                                    , p_distribution_line_number in number
                                    )
   RETURN BOOLEAN IS
       CURSOR c_exists IS
         SELECT 'x'
         FROM   igi_mpp_subledger
         WHERE  invoice_id = p_invoice_id
         AND    distribution_line_number = p_distribution_line_number
         AND    (   nvl(expense_recognized_flag,'N') = 'Y'
                  OR nvl(gl_posted_flag,'N') = 'Y' )
         ;
   BEGIN
       FOR l_exists in c_exists LOOP
          return TRUE;
       END LOOP;
       return FALSE;
   END ExistsRecognizedEntries;


   FUNCTION ConvertToFuncCurr  ( fp_set_of_books_id in number
                               , fp_txn_date   in date
                               , fp_curr_conv_type in varchar2
                               , fp_txn_amount in number
                               , fp_txn_curr   in varchar2
                               , fp_func_curr  in varchar2 )
   RETURN   Number
   IS
   BEGIN
       IF fp_txn_curr = nvl(fp_func_curr, fp_txn_curr) then
          return fp_txn_amount;
       END IF;

       return GL_CURRENCY_API.Convert_amount ( fp_txn_curr, fp_func_curr,
                           fp_txn_date, fp_curr_conv_type, fp_txn_amount );

   END ConvertToFuncCurr;
-- ------------
-- PROCEDURES
-- ------------

   PROCEDURE InsertIntoSublgr    ( p_sublgr in  SUBLGR ) IS
     l_date  DATE;
     l_factor  NUMBER := 0;

     FUNCTION DateFactor ( fp_invoice_id in number, fp_dist_line_num in number
                            , fp_sob_id     in number
                            )
     RETURN   Number
     IS
      l_date  DATE := null;

      CURSOR c_acc_date is
       SELECT accounting_date
       FROM   ap_invoice_distributions
       WHERE  invoice_id    = fp_invoice_id
       AND    set_of_books_id = fp_sob_id
       AND    distribution_line_number =
                fp_dist_line_num
       ;
      CURSOR c_date IS
       SELECT start_date, end_date
       FROM   gl_period_statuses
       WHERE  application_id =    AP_APPLICATION_ID
       AND    set_of_books_id =   fp_sob_id
       AND    period_name     = ( select period_name
                                  from   ap_invoice_distributions
                                  where  invoice_id = fp_invoice_id AND
                                         distribution_line_number =
                                              fp_dist_line_num ) ;
     BEGIN
      FOR l_acc_date in c_acc_date LOOP
       FOR l_date in c_date LOOP
           return (
                   ( l_acc_date.accounting_date - l_date.start_date) /
                   ( l_date.end_date - l_date.start_date )
                  )
                 ;
       END LOOP;
     END LOOP;
       return null;
     EXCEPTION WHEN OTHERS THEN
      --bug 3199481 fnd logging changes:sdixit :start
      --standard way to handle when-others as per FND logging guidelines

           IF ( l_unexp_level >= l_debug_level ) THEN

               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_unexp_level,'igi.plsql.igipmslb.IGIPMSLR.DateFactor',TRUE);
           END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
        return null;
     END DateFactor;

     FUNCTION GetDay ( fp_period_name in varchar2, fp_sob_id in number,
                           fp_factor in number
                           )
     return   Date
     IS
        CURSOR c_last_date IS
           SELECT start_date, end_date
           FROM   gl_period_statuses
           WHERE  application_id =  AP_APPLICATION_ID
           AND    set_of_books_id = fp_sob_id
           AND    period_name     = fp_period_name;

     BEGIN

        FOR l_date in c_last_date LOOP
             return ( fp_factor * ( l_date.end_date - l_date.start_date) )
                    + l_date.start_date;
        END LOOP;

        return NULL;
     EXCEPTION
        when others then
      --bug 3199481 fnd logging changes:sdixit :start
      --standard way to handle when-others as per FND logging guidelines

           IF ( l_unexp_level >= l_debug_level ) THEN

               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_unexp_level,'igi.plsql.igipmslb.IGIPMSLR.GetDay',TRUE);
           END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
        null;
     END GetDay;

   BEGIN

     l_factor  := DateFactor( p_sublgr.invoice_id, p_sublgr.distribution_line_number
                             , p_sublgr.set_of_books_id
                             );

     l_date  := GetDay ( p_sublgr.period_name,  p_sublgr.set_of_books_id,
                             l_factor );

     l_date  := nvl( l_date, p_sublgr.gl_date );

     INSERT INTO IGI_MPP_SUBLEDGER
       (
           invoice_id
           ,distribution_line_number
           ,last_update_date
           ,last_updated_by
           ,creation_date
           ,created_by
           ,last_update_login
           ,subledger_entry_id
           ,currency_code
           ,actual_flag
           ,je_source_name
           ,je_category_name
           ,set_of_books_id
           ,gl_date
           ,expense_recognized_flag
           ,gl_posted_flag
           ,code_combination_id
           ,accounted_dr
           ,accounted_cr
           ,entered_dr
           ,entered_cr
           ,currency_conversion_date
           ,user_currency_conversion_type
           ,currency_conversion_rate
           ,period_name
           ,chart_of_accounts_id
           ,functional_currency_code
           ,date_created_in_gl
           ,je_batch_name
           ,je_batch_description
           ,je_header_name
           ,je_line_description
           ,reverse_journal_flag
           ,reversal_period_name
           ,ussgl_transaction_code
           ,reference1
           ,reference2
           ,reference3
       ) VALUES (
            p_sublgr.invoice_id
           ,p_sublgr.distribution_line_number
           ,p_sublgr.last_update_date
           ,p_sublgr.last_updated_by
           ,p_sublgr.creation_date
           ,p_sublgr.created_by
           ,p_sublgr.last_update_login
           ,p_sublgr.subledger_entry_id
           ,p_sublgr.currency_code
           ,p_sublgr.actual_flag
           ,p_sublgr.je_source_name
           ,p_sublgr.je_category_name
           ,p_sublgr.set_of_books_id
           ,l_date
           ,p_sublgr.expense_recognized_flag
           ,p_sublgr.gl_posted_flag
           ,p_sublgr.code_combination_id
           ,p_sublgr.accounted_dr
           ,p_sublgr.accounted_cr
           ,p_sublgr.entered_dr
           ,p_sublgr.entered_cr
           ,p_sublgr.currency_conversion_date
           ,p_sublgr.user_currency_conversion_type
           ,p_sublgr.currency_conversion_rate
           ,p_sublgr.period_name
           ,p_sublgr.chart_of_accounts_id
           ,p_sublgr.functional_currency_code
           ,p_sublgr.date_created_in_gl
           ,p_sublgr.je_batch_name
           ,p_sublgr.je_batch_description
           ,p_sublgr.je_header_name
           ,p_sublgr.je_line_description
           ,p_sublgr.reverse_journal_flag
           ,p_sublgr.reversal_period_name
           ,p_sublgr.ussgl_transaction_code
           ,p_sublgr.reference1
           ,p_sublgr.reference2
           ,p_sublgr.reference3
       );

   END;


   PROCEDURE CreateOffsetEntries ( p_sublgr IN  SUBLGR
                                 , p_ccid in number
                                 , p_dr_or_cr IN VARCHAR2
                                 , p_amount   IN NUMBER
                                 , p_base_amount in NUMBER
                                 ) IS
       l_sublgr SUBLGR := p_sublgr;

   BEGIN
       l_sublgr.reference1 := '0';
       l_sublgr.code_combination_id := p_ccid;

       SELECT DECODE(p_dr_or_cr,'DR',p_amount,null)
            , DECODE(p_dr_or_cr,'DR',null,p_amount)
       INTO  l_sublgr.entered_dr ,
             l_sublgr.entered_cr
       FROM  SYS.DUAL;

       IF l_sublgr.entered_dr is not null then
          l_sublgr.accounted_dr := ConvertToFuncCurr
                               ( l_sublgr.set_of_books_id
                               , l_sublgr.currency_conversion_date
                               , l_sublgr.user_currency_conversion_type
                               , l_sublgr.entered_dr
                               , l_sublgr.currency_code
                               , l_sublgr.functional_currency_code
                               );
       END IF;
       IF l_sublgr.entered_cr is not null then
          l_sublgr.accounted_cr := ConvertToFuncCurr
                               ( l_sublgr.set_of_books_id
                               , l_sublgr.currency_conversion_date
                               , l_sublgr.user_currency_conversion_type
                               , l_sublgr.entered_cr
                               , l_sublgr.currency_code
                               , l_sublgr.functional_currency_code
                               );
       END IF;

       SELECT igi_mpp_subledger_s.nextval
       INTO   l_sublgr.subledger_entry_id
       FROM   sys.dual;

       InsertIntoSublgr ( l_sublgr );

   END ;
   PROCEDURE CreateNormalEntries ( p_sublgr IN SUBLGR
                                 , p_ext_dist IN c_ext_dist%ROWTYPE
                                 , p_future_posting_ccid in number
                                 , p_dr_or_cr IN VARCHAR2
                                 ) IS
       l_sublgr SUBLGR := p_sublgr;
   BEGIN

       l_sublgr.reference1  := p_ext_dist.mpp_dist_line_number;
       l_sublgr.period_name := p_ext_dist.period_name;

       IF p_dr_or_cr = 'DR' THEN
          --bug 3199481: fnd logging changes:sdixit :start
          IF (l_state_level >=  l_debug_level ) THEN
             FND_LOG.STRING  (l_state_level , 'igi.pls.igipmslb.IGIPMSLR.CreateNormalEntries',
                          '>> >> >> >> Debit entry..(EXPENSE).');
          END IF;
          l_sublgr.code_combination_id := p_ext_dist.code_combination_id;
       ELSE
          --bug 3199481: fnd logging changes:sdixit :start
          IF (l_state_level >=  l_debug_level ) THEN
             FND_LOG.STRING  (l_state_level , 'igi.pls.igipmslb.IGIPMSLR.CreateNormalEntries',
                          '>> >> >> >> Credit entry..(FUTURE POSTING).');
          END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
          l_sublgr.code_combination_id := p_future_posting_ccid;
       END IF;

       SELECT DECODE(p_dr_or_cr,'DR',p_ext_dist.amount,null)
            , DECODE(p_dr_or_cr,'DR',null,p_ext_dist.amount)
       INTO  l_sublgr.entered_dr ,
             l_sublgr.entered_cr
       FROM  SYS.DUAL;

       IF l_sublgr.entered_dr is not null then
          l_sublgr.accounted_dr := ConvertToFuncCurr
                               ( l_sublgr.set_of_books_id
                               , l_sublgr.currency_conversion_date
                               , l_sublgr.user_currency_conversion_type
                               , l_sublgr.entered_dr
                               , l_sublgr.currency_code
                               , l_sublgr.functional_currency_code
                               );
       END IF;
       IF l_sublgr.entered_cr is not null then
          l_sublgr.accounted_cr := ConvertToFuncCurr
                               ( l_sublgr.set_of_books_id
                               , l_sublgr.currency_conversion_date
                               , l_sublgr.user_currency_conversion_type
                               , l_sublgr.entered_cr
                               , l_sublgr.currency_code
                               , l_sublgr.functional_currency_code
                               );
       END IF;
       SELECT igi_mpp_subledger_s.nextval
       INTO   l_sublgr.subledger_entry_id
       FROM   sys.dual;

       InsertIntoSublgr ( l_sublgr );

   END;

   PROCEDURE CreateEntries (  p_dist          in c_dist%ROWTYPE ) IS

        CURSOR c_future_post IS
           SELECT setup.*
           FROM   igi_mpp_setup setup
           ;

        l_future_post c_future_post%ROWTYPE;
        l_sublgr SUBLGR ;
        l_continue BOOLEAN := FALSE;
   BEGIN
      /*
      --  Get the future posting account details and the
      --  mpp distribution details
      */
      --bug 3199481: fnd logging changes:sdixit :start
       IF (l_state_level >=  l_debug_level ) THEN
          FND_LOG.STRING  (l_state_level , 'igi.pls.igipmslb.IGIPMSLR.CreateEntries',
                          '>> >> Inside Create new Subledger entry...');
          FND_LOG.STRING  (l_state_level , 'igi.pls.igipmslb.IGIPMSLR.CreateEntries',
                          '>> >> Validating Set up...');
       END IF;
      --bug 3199481 fnd logging changes: sdixit: end block
      OPEN c_future_post;
      LOOP
           FETCH c_future_post into l_future_post;
           EXIT WHEN c_future_post%NOTFOUND;

           l_continue := TRUE;
           IF l_future_post.future_posting_ccid is not null then
              NULL;
           ELSE
              CLOSE c_future_post;
              raise_application_error ( -20000, 'Future Posting Account is not set.');
           END IF;
           --bug 3199481: fnd logging changes:sdixit :start
           IF (l_state_level >=  l_debug_level ) THEN
               FND_LOG.STRING  (l_state_level , 'igi.pls.igipmslb.IGIPMSLR.CreateEntries',
                          '>> >> MPP Setup Validation successful...');
           END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
      END LOOP;
      CLOSE c_future_post;


      IF NOT l_continue THEN
         raise_application_error (-20000, 'MPP Setup is not done properly.');
      END IF;
      /*
      -- Set the Subldger Template record
      */
     --bug 3199481: fnd logging changes:sdixit :start
       IF (l_state_level >=  l_debug_level ) THEN
          FND_LOG.STRING  (l_state_level , 'igi.pls.igipmslb.IGIPMSLR.CreateEntries',
                          '>> >> Building Sub ledger Template...');
       END IF;
     --bug 3199481 fnd logging changes: sdixit: end block

      l_sublgr.invoice_id               := p_dist.invoice_id;
      l_sublgr.distribution_line_number := p_dist.distribution_line_number;
      l_sublgr.last_update_date         := g_date;
      l_sublgr.last_updated_by          := g_user_id;
      l_sublgr.creation_date            := g_date;
      l_sublgr.created_by               := g_user_id;
      l_sublgr.last_update_login        := g_login_id;
      l_sublgr.currency_code            := GetInvoiceCurrency ( p_dist.invoice_id) ;
      l_sublgr.actual_flag              := 'A';
      l_sublgr.je_source_name           := l_future_post.je_source_name;
      l_sublgr.je_category_name         := l_future_post.je_category_name;
      l_sublgr.set_of_books_id          := p_dist.set_of_books_id;
      l_sublgr.gl_date                  := p_dist.accounting_date;
      l_sublgr.expense_recognized_flag  := 'N';
      l_sublgr.gl_posted_flag           := 'N';
      l_sublgr.code_combination_id      := NULL;
      l_sublgr.accounted_dr             := NULL;
      l_sublgr.accounted_cr             := NULL;
      l_sublgr.entered_dr               := NULL;
      l_sublgr.entered_cr               := NULL;
      l_sublgr.currency_conversion_Date := p_dist.exchange_date;
      l_sublgr.currency_conversion_rate := p_dist.exchange_rate;
      l_sublgr.user_currency_conversion_type := p_dist.exchange_rate_type;
      l_sublgr.period_name              := p_dist.period_name;
      l_sublgr.chart_of_accounts_id     := p_dist.chart_of_accounts_id;
      l_sublgr.functional_currency_code := p_dist.functional_currency_code  ;
      l_sublgr.date_created_in_gl       := NULL;
      l_sublgr.je_batch_name            := NULL;
      l_sublgr.je_batch_description     := NULL;
      l_sublgr.je_header_name           := NULL;
      l_sublgr.je_line_description      := NULL;
      -- l_sublgr.reversal_journal_flag    := NULL;
      l_sublgr.reversal_period_name     := NULL;
      l_sublgr.ussgl_transaction_code   := NULL;
      l_sublgr.reference1               := p_dist.distribution_line_number;
      l_sublgr.reference2               := p_dist.description;
      l_sublgr.reference3               := NULL;




      /*
      --
      -- Create Offset Account entries at the invoice distribution
      -- line level
      */
   --bug 3199481: fnd logging changes:sdixit :start
      IF (l_state_level >=  l_debug_level ) THEN
         FND_LOG.STRING  (l_state_level , 'igi.pls.igipmslb.IGIPMSLR.CreateEntries',
                          '>> >> Creating Offset entries...');
      END IF;
   --bug 3199481 fnd logging changes: sdixit: end block


      IF NOT ExistsOffsetEntries ( p_dist.invoice_id
                                    , p_dist.distribution_line_number
                                    )  THEN
   --bug 3199481: fnd logging changes:sdixit :start
         IF (l_state_level >=  l_debug_level ) THEN
             FND_LOG.STRING  (l_state_level , 'igi.pls.igipmslb.IGIPMSLR.CreateEntries',
                          '>> >> >> Creating Offset entries (CR) OF EXPENSE ...');
         END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
         CreateOffsetEntries ( l_sublgr
                             , p_dist.dist_code_combination_id
                             , 'CR'
                             , p_dist.amount
                             , p_dist.base_amount
                             );
   --bug 3199481: fnd logging changes:sdixit :start
         IF (l_state_level >=  l_debug_level ) THEN
            FND_LOG.STRING  (l_state_level , 'igi.pls.igipmslb.IGIPMSLR.CreateEntries',
                          '>> >> >> Creating Offset entries (DR) OF FUTURE POSTING ...');
         END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
         CreateOffsetEntries ( l_sublgr
                             , l_future_post.future_posting_ccid
                             , 'DR'
                             , p_dist.amount
                             , p_dist.base_amount
                                );

          FOR l_mpp IN  c_ext_dist ( p_dist.invoice_id
                                   , p_dist.distribution_line_number )
          LOOP
           --bug 3199481: fnd logging changes:sdixit :start
             IF (l_state_level >=  l_debug_level ) THEN
                FND_LOG.STRING  (l_state_level , 'igi.pls.igipmslb.IGIPMSLR.CreateEntries',
                          '>> >> >> Creating Normal entries (DR) OF EXPENSE ...');
             END IF;
           --bug 3199481 fnd logging changes: sdixit: end block

             CreateNormalEntries ( l_sublgr
                                 , l_mpp
                                 , l_future_post.future_posting_ccid
                                 , 'DR' )
             ;
           --bug 3199481: fnd logging changes:sdixit :start
             IF (l_state_level >=  l_debug_level ) THEN
                FND_LOG.STRING  (l_state_level , 'igi.pls.igipmslb.IGIPMSLR.CreateEntries',
                          '>> >> >> Creating Normal entries (CR) OF FUTURE POSTING ...');
             END IF;
   --bug 3199481 fnd logging changes: sdixit: end block

             CreateNormalEntries ( l_sublgr
                                 , l_mpp
                                 , l_future_post.future_posting_ccid
                                 , 'CR' )
             ;

          END LOOP;
       END IF;

   END;

   PROCEDURE Create_MPPSLR_Details
     ( p_invoice_id in number
     , p_distribution_line_number in number
     )   IS
   l_currency_code      ap_invoices_all.invoice_currency_code%TYPE := NULL;

   BEGIN

     --bug 3199481: fnd logging changes:sdixit :start
       IF (l_state_level >=  l_debug_level ) THEN
          FND_LOG.STRING  (l_state_level ,'igi.pls.igipmslb.IGIPMSLR.Create_MPPSLR_Details',
                          'Begin Creation of MPP Subledger Entry...');
       END IF;

   l_currency_code := GetInvoiceCurrency ( p_invoice_id );
   IF (l_state_level >=  l_debug_level ) THEN
       FND_LOG.STRING  (l_state_level , 'igi.pls.igipmslb.IGIPMSLR.Create_MPPSLR_Details',
                          '>> Invoice Currency '||l_currency_code );
   END IF;
   --bug 3199481 fnd logging changes: sdixit: end block

   FOR l_dist in c_dist ( p_invoice_id, p_distribution_line_number ) LOOP
     --bug 3199481: fnd logging changes:sdixit :start
     IF (l_state_level >=  l_debug_level ) THEN
        FND_LOG.STRING  (l_state_level , 'igi.pls.igipmslb.IGIPMSLR.Create_MPPSLR_Details',
                          '>> Processing Invoice Distributions ...');
     END IF;
           IF (l_state_level >=  l_debug_level ) THEN
              FND_LOG.STRING  (l_state_level , 'igi.pls.igipmslb.IGIPMSLR.Create_MPPSLR_Details',
                          '>> Processing MPP distributions ...');
           END IF;
   --bug 3199481 fnd logging changes: sdixit: end block

           IF ExistsRecognizedEntries ( l_dist.invoice_id
                                    , l_dist.distribution_line_number
                                    ) THEN
           --bug 3199481: fnd logging changes:sdixit :start
              IF (l_state_level >=  l_debug_level ) THEN
                  FND_LOG.STRING  (l_state_level , 'igi.pls.igipmslb.IGIPMSLR.Create_MPPSLR_Details',
                          '>> >> Subledger entries have been recognized or posted...');
              END IF;
              IF (l_state_level >=  l_debug_level ) THEN
                  FND_LOG.STRING  (l_state_level , 'igi.pls.igipmslb.IGIPMSLR.Create_MPPSLR_Details',
                          '>> >> Stop further processing on this MPP distribution...');
              END IF;
          --bug 3199481 fnd logging changes: sdixit: end block

              NULL;
           ELSE
           --bug 3199481: fnd logging changes:sdixit :start
              IF (l_state_level >=  l_debug_level ) THEN
                  FND_LOG.STRING  (l_state_level , 'igi.pls.igipmslb.IGIPMSLR.Create_MPPSLR_Details',
                          '>> >> Delete from Subledger Entries...');
              END IF;
           --bug 3199481 fnd logging changes: sdixit: end block

              delete from igi_mpp_subledger
              where  invoice_id = l_dist.invoice_id
              and    distribution_line_number = l_dist.distribution_line_number
              ;
           --bug 3199481: fnd logging changes:sdixit :start
              --WriteToLog ('>> >> Create New Subledger Entries...');
              IF (l_state_level >=  l_debug_level ) THEN
                  FND_LOG.STRING  (l_state_level , 'igi.pls.igipmslb.IGIPMSLR.Create_MPPSLR_Details',
                          '>> >> Create New Subledger Entries...');
              END IF;
           --bug 3199481 fnd logging changes: sdixit: end block
              CreateEntries ( l_dist );

           END IF;

   END LOOP;

   END;

   PROCEDURE Update_MPPSLR_Details
     ( p_invoice_id in number
     , p_distribution_line_number in number
     )   IS
   BEGIN
      NULL;
   END;



   PROCEDURE Delete_MPPSLR_details
     ( p_invoice_id in number
     , p_distribution_line_number in number
     )
   IS
   BEGIN
      NULL;
   END;


END;

/
