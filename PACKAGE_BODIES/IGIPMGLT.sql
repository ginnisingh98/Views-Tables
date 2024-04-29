--------------------------------------------------------
--  DDL for Package Body IGIPMGLT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGIPMGLT" AS
-- $Header: igipmgtb.pls 115.10 2003/12/01 14:57:42 sdixit ship $

   g_date CONSTANT DATE := SYSDATE;
   g_user_id CONSTANT NUMBER := fnd_global.user_id;
   --bug 3199481: following variables added for fnd logging changes: sdixit
   l_debug_level number	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   l_state_level number	:=	FND_LOG.LEVEL_STATEMENT;
   l_proc_level number	:=	FND_LOG.LEVEL_PROCEDURE;
   l_event_level number	:=	FND_LOG.LEVEL_EVENT;
   l_excep_level number	:=	FND_LOG.LEVEL_EXCEPTION;
   l_error_level number	:=	FND_LOG.LEVEL_ERROR;
   l_unexp_level number	:=	FND_LOG.LEVEL_UNEXPECTED;

   PROCEDURE WriteToLog ( pp_mesg in varchar2 ) IS
   BEGIN
            FND_FILE.put_line ( FND_FILE.log, pp_mesg ) ;
   END;

   PROCEDURE InitGLTransfer ( p_glint_control IN OUT NOCOPY GLINT_CONTROL ) IS
   BEGIN
          SELECT  GL_JOURNAL_IMPORT_S.nextval
               , sp.set_of_books_id
               ,  GL_INTERFACE_CONTROL_S.nextval
               , 'S'
          INTO     p_glint_control.interface_run_id
                ,  p_glint_control.set_of_books_id
                ,  p_glint_control.group_id
                ,  p_glint_control.status
          FROM    ap_system_parameters sp
          ;
          select  je_source_name
          into    p_glint_control.je_source_name
          from    igi_mpp_setup
          ;

   END;
   PROCEDURE  InsertControlRec ( p_glint_control in GLINT_CONTROL )
   IS
   BEGIN

        INSERT INTO gl_interface_control
        ( je_source_name
        , status
        , interface_run_id
        , group_id
        , set_of_books_id)
        VALUES
        ( p_glint_control.je_source_name
        , p_glint_control.status
        , p_glint_control.interface_run_id
        , p_glint_control.group_id
        , p_glint_control.set_of_books_id
        );


   END;

   PROCEDURE InsertInterfaceRec ( l_glint IN  GLINT ) IS
   BEGIN
   --bug 3199481 fnd logging changes: sdixit: start block
       IF (l_state_level >=  l_debug_level ) THEN
          FND_LOG.STRING  (l_state_level , 'igi.pls.igipmgtb.IGIPMGLT.InsertInterfaceRec',
                          '>> >> ****  Accounting date '||l_glint.accounting_date);
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
       INSERT INTO GL_INTERFACE
        (
        status                           -- not null
        ,set_of_books_id                 -- not null
        ,accounting_date                 -- not null
        ,currency_code                   -- not null
        ,date_created                    -- not null
        ,created_by                      -- not null
        ,actual_flag                     -- not null
        ,user_je_category_name           -- not null
        ,user_je_source_name             -- not null
        ,currency_conversion_date
        ,encumbrance_type_id
        ,budget_version_id
        ,user_currency_conversion_type
        ,currency_conversion_rate
        ,entered_dr
        ,entered_cr
        ,accounted_dr
        ,accounted_cr
        ,transaction_date
        ,reference1
        ,reference2
        ,reference3
        ,reference4
        ,period_name
        ,chart_of_accounts_id
        ,functional_currency_code
        ,code_combination_id
        ,group_id
        ) VALUES
        (
         'NEW'                           -- not null
        ,l_glint.set_of_books_id                 -- not null
        ,l_glint.accounting_date                 --  not null
        ,l_glint.currency_code                   -- not null
        ,l_glint.date_created                    -- not null
        ,l_glint.created_by                      -- not null
        ,l_glint.actual_flag                     -- not null
        ,l_glint.user_je_category_name           -- not null
        ,l_glint.user_je_source_name             -- not null
        ,l_glint.currency_conversion_date
        ,l_glint.encumbrance_type_id
        ,l_glint.budget_version_id
        ,l_glint.user_currency_conversion_type
        ,l_glint.currency_conversion_rate
        ,l_glint.entered_dr
        ,l_glint.entered_cr
        ,l_glint.accounted_dr
        ,l_glint.accounted_cr
        ,l_glint.transaction_date
        ,l_glint.reference1
        ,l_glint.reference2
        ,l_glint.reference3
        ,l_glint.reference4
        ,l_glint.period_name
        ,l_glint.chart_of_accounts_id
        ,l_glint.functional_currency_code
        ,l_glint.code_combination_id
        ,l_glint.group_id
        )
        ;
   END;


   FUNCTION TxfrToGL ( p_period_name in varchar2
                     , p_sob_id      in number
                     , p_glint_control in  GLINT_CONTROL
                     )
   RETURN NUMBER
   IS

     CURSOR c_subledger   IS
     SELECT slgr.*
     FROM   igi_mpp_subledger slgr
     WHERE  slgr.period_name  =     p_period_name
     AND    slgr.set_of_books_id =  p_sob_id
     AND    slgr.expense_recognized_flag = 'Y'
     AND    slgr.gl_posted_flag          = 'N'
     ;

         l_glint_control   GLINT_CONTROL := p_glint_control;
         l_glint           GLINT        ;

         PROCEDURE TransferInfo ( p_slgr c_subledger%ROWTYPE
                                , p_glint in  GLINT ) IS
                   l_glint GLINT := p_glint;
                   l_user_je_category_name
                          gl_je_categories.user_je_category_name%TYPE;
                   l_user_je_source_name
                          gl_je_sources.user_je_source_name%TYPE;

         BEGIN
               SELECT user_je_source_name
               INTO   l_user_je_source_name
               FROM   gl_je_sources
               WHERE  je_source_name = p_slgr.je_source_name
               ;
               SELECT user_je_category_name
               INTO   l_user_je_category_name
               FROM   gl_je_categories
               WHERE  je_category_name = p_slgr.je_category_name
               ;

               SELECT p_slgr.invoice_id
                ,     p_slgr.distribution_line_number
               ,     p_slgr.subledger_entry_id
               ,     p_slgr.currency_code
               ,     p_slgr.actual_flag
               ,     l_user_je_source_name
               ,     l_user_je_category_name
               ,     p_slgr.set_of_books_id
               ,     p_slgr.gl_date
               ,     p_slgr.code_combination_id
               ,     p_slgr.accounted_dr
               ,     p_slgr.accounted_cr
               ,     p_slgr.entered_dr
               ,     p_slgr.entered_cr
               ,     p_slgr.currency_conversion_date
               ,     p_slgr.user_currency_conversion_type
               ,     p_slgr.currency_conversion_rate
               ,     p_slgr.period_name
               ,     p_slgr.chart_of_accounts_id
               ,     p_slgr.functional_currency_code
               ,     p_slgr.reference1
               ,     p_slgr.reference2
               ,     p_slgr.reference3
               ,     g_date
               ,     g_user_id
               INTO
                     l_glint.reference4
               ,     l_glint.reference5
               ,     l_glint.reference6
               ,     l_glint.currency_code
               ,     l_glint.actual_flag
               ,     l_glint.user_je_source_name
               ,     l_glint.user_je_category_name
               ,     l_glint.set_of_books_id
               ,     l_glint.accounting_date
               ,     l_glint.code_combination_id
               ,     l_glint.accounted_dr
               ,     l_glint.accounted_cr
               ,     l_glint.entered_dr
               ,     l_glint.entered_cr
               ,     l_glint.currency_conversion_date
               ,     l_glint.user_currency_conversion_type
               ,     l_glint.currency_conversion_rate
               ,     l_glint.period_name
               ,     l_glint.chart_of_accounts_id
               ,     l_glint.functional_currency_code
               ,     l_glint.reference1
               ,     l_glint.reference2
               ,     l_glint.reference3
               ,     l_glint.date_created
               ,     l_glint.created_by
               FROM  SYS.DUAL
               ;

               InsertInterfaceRec ( l_glint ) ;
   --bug 3199481 fnd logging changes: sdixit: start block
           IF (l_state_level >=  l_debug_level ) THEN
               FND_LOG.STRING  (l_state_level ,'igi.pls.igipmgtb.IGIPMGLT.TransferInfo',
                                '>> >> >> Populated Interface control table... ');
           END IF;
   --bug 3199481 fnd logging changes: sdixit: end block

         END TransferInfo;

   BEGIN

        l_glint.group_id   := l_glint_control.group_id;
        l_glint.status     := 'NEW';
        l_glint.set_of_books_id := l_glint_control.set_of_books_id;



        FOR l_slgr IN C_subledger LOOP
                TransferInfo ( l_slgr,  l_glint );
   --bug 3199481 fnd logging changes: sdixit: start block
         IF (l_state_level >=  l_debug_level ) THEN
           FND_LOG.STRING  (l_state_level , 'igi.pls.igipmgtb.IGIPMGLT.InsertInterfaceRec',
                          '>> >> >> Built the  interface info... ' );
         END IF;
   --bug 3199481 fnd logging changes: sdixit: end block

                UPDATE igi_mpp_subledger
                SET    gl_posted_flag = 'Y'
                ,      date_created_in_gl = g_date
                WHERE  subledger_entry_id = l_slgr.subledger_entry_id
                AND    nvl(gl_posted_flag,'N') = 'N'
                AND    expense_recognized_flag = 'Y'
                ;

                UPDATE igi_mpp_ap_invoice_dists_det
                SET    gl_posted_flag = 'Y'
                ,      gl_posted_date = g_date
                WHERE  invoice_id               = l_slgr.invoice_id
                AND    distribution_line_number =
                                    l_slgr.distribution_line_number
                AND    period_name              = l_slgr.period_name
                AND    NVL(gl_posted_flag,'N')  = 'N'
                AND    expense_recognized_flag  = 'Y'
                and    EXISTS
                    (   SELECT 'x'
                        FROM   igi_mpp_subledger
                        WHERE  gl_posted_flag = 'Y'
                        AND    expense_recognized_flag = 'Y'
                        AND    invoice_id = l_slgr.invoice_id
                        AND    distribution_line_number =
                               l_slgr.distribution_line_number
                        AND    period_name              = l_slgr.period_name
                    )
                ;

   --bug 3199481 fnd logging changes: sdixit: start block
       IF (l_state_level >=  l_debug_level ) THEN
          FND_LOG.STRING  (l_state_level , 'igi.pls.igipmgtb.IGIPMGLT.InsertInterfaceRec',
                          '>> >> >> Marked as posted... ' );
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block

        END LOOP;

        return( l_glint_control.interface_run_id );

   END;

   PROCEDURE   SubLedgerTxfrtoGL (  errbuf  out NOCOPY varchar2
                                 ,  retcode out NOCOPY number
                                 ,  p_set_of_books_id      in number
                                 ,  p_start_period_eff_num in number
                                 ,  p_end_period_eff_num   in number
                                 ,  p_run_gl_import        in varchar2
                                 )
  IS

    l_continue BOOLEAN := TRUE;
    l_request_id  NUMBER(15) := NULL;
    l_interface_run_id number(15) := NULL;
    l_glint_control GLINT_CONTROL;

    CURSOR c_start_date  IS
     SELECT start_date
     from   gl_period_statuses
     where  set_of_books_id = p_set_of_books_id
     and    application_id  = 200
     and    adjustment_period_flag = 'N'
     and    effective_period_num   = p_start_period_eff_num
     ;
    CURSOR c_end_date  IS
     SELECT end_date
     from   gl_period_statuses
     where  set_of_books_id = p_set_of_books_id
     and    application_id  = 200
     and    adjustment_period_flag = 'N'
     and    effective_period_num   = p_end_period_eff_num
     ;

    CURSOR c_periods IS
     SELECT period_name, set_of_books_id
     from   gl_period_statuses
     where  set_of_books_id     = p_set_of_books_id
     and    application_id      = 200
     and    adjustment_period_flag = 'N'
     and    effective_period_num between p_start_period_eff_num and
                                         p_end_period_eff_num
     order by effective_period_num
     ;

     CURSOR c_currency  ( cp_period_name in varchar2
                        , cp_sob_id      in number ) IS
            SELECT DISTINCT currency_code
            FROM   igi_mpp_subledger
            WHERE  period_name     = cp_period_name
            and    set_of_books_id = cp_sob_id
            ;

     CURSOR c_verify   ( cp_period_name in varchar2
                       , cp_sob_id      in number
                       , cp_currency_code in varchar2
                       ) IS
     SELECT  currency_code
     ,       SUM( nvl( accounted_dr, 0) )  sum_accounted_dr
     ,       SUM( nvl( accounted_cr, 0) )  sum_accounted_cr
     ,       SUM( nvl( entered_dr,   0) )  sum_entered_dr
     ,       SUM( nvl( entered_cr,   0) )  sum_entered_cr
     FROM    igi_mpp_subledger
     WHERE  period_name  =     cp_period_name
     AND    expense_recognized_flag = 'Y'
     AND    gl_posted_flag          = 'N'
     AND    seT_of_books_id         = cp_sob_id
     AND    currency_code           = cp_currency_code
     GROUP BY currency_code
     ;
     FUNCTION  CheckTotals ( cp_period_name in varchar2
                           , cp_sob_id      in number
                           , cp_currency_code in varchar2
                           )
     RETURN    BOOLEAN
     IS
     BEGIN
         FOR l_verify in c_verify ( cp_period_name, cp_sob_id, cp_currency_code )
         LOOP
             IF l_verify.sum_accounted_dr =   l_verify.sum_accounted_cr THEN
                return TRUE;
             ELSIF l_verify.sum_entered_dr =  l_verify.sum_entered_cr THEN
                return TRUE;
             else
                return FALSE;
             end if;
         END LOOP;
         return FALSE;
     END CheckTotals;


  BEGIN

   --bug 3199481 fnd logging changes: sdixit: start block
       IF (l_state_level >=  l_debug_level ) THEN
          FND_LOG.STRING  (l_state_level , 'igi.pls.igipmgtb.IGIPMGLT.SubLedgerTrfxtoGl',
                          'BEGIN Transfer to GL.');
       END IF;
        InitGLTransfer ( l_glint_control  ) ;
       IF (l_state_level >=  l_debug_level ) THEN
          FND_LOG.STRING  (l_state_level , 'igi.pls.igipmgtb.IGIPMGLT.SubLedgerTrfxtoGl',
                          '>> >> Initalized interface control info... ' );
       END IF;
        InsertControlRec ( l_glint_control   )   ;
       IF (l_state_level >=  l_debug_level ) THEN
          FND_LOG.STRING  (l_state_level , 'igi.pls.igipmgtb.IGIPMGLT.SubLedgertrfxtoGl',
                          '>> >> Populated Interface control table... ' );
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block

     FOR l_period in c_periods LOOP

   --bug 3199481 fnd logging changes: sdixit: start block
       IF (l_state_level >=  l_debug_level ) THEN
          FND_LOG.STRING  (l_state_level , 'igi.pls.igipmgtb.IGIPMGLT.SubLedgerTrfxtoGl',
                         '>> Period '|| l_period.period_name );
          FND_LOG.STRING  (l_state_level , 'igi.pls.igipmgtb.IGIPMGLT.SubLedgerTrfxtoGl',
                         '>> SOB ID '|| l_period.set_of_books_id );
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block


         l_continue := TRUE;

         FOR l_currency in c_currency ( l_period.period_name
                                      , l_period.set_of_books_id
                                      )
         LOOP
   --bug 3199481 fnd logging changes: sdixit: start block
       IF (l_state_level >=  l_debug_level ) THEN
          FND_LOG.STRING  (l_state_level , 'igi.pls.igipmgtb.IGIPMGLT.SubLedgerTrfxtoGl',
                          '>> >> Currency '|| l_currency.currency_code );
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block

             IF CheckTotals ( l_period.period_name, l_period.set_of_books_id
                            , l_currency.currency_code )
             THEN

                  NULL;
             ELSE
   --bug 3199481 fnd logging changes: sdixit: start block
               IF (l_state_level >=  l_debug_level ) THEN
               FND_LOG.STRING  (l_state_level , 'igi.pls.igipmgtb.IGIPMGLT.InsertInterfaceRec',
                          '>> >> Totals unbalanced for Currency '|| l_currency.currency_code );
               END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
                  l_continue := FALSE;
             END IF;

         END LOOP;

        IF l_continue THEN
            l_interface_run_id :=
                TxfrtoGl   ( l_period.period_name, l_period.set_of_books_id
                           , l_glint_control );
        ELSE
            rollback;
            errbuf := 'Unbalanced entries found.';
            retcode := 2;
        END IF;

     END LOOP;

     if p_run_gl_import = 'Y' and l_interface_run_id <> 0 then

        for l_start_date in c_start_date loop
          for l_end_date in c_end_date  loop
              l_request_id :=
                 FND_REQUEST.SUBMIT_REQUEST
                 ( 'SQLGL'
                 , 'GLLEZL'
                 , null
                 , null
                 , FALSE
                 , l_interface_run_id
                 , p_set_of_books_id
                 , 'N' -- post_errors_to_suspense
                 , to_char(l_start_date.start_date,'YYYY/MM/DD')
                 , to_char(l_end_date.end_date,'YYYY/MM/DD')
                 , 'N'
                 , 'N' -- descriptive_flexfield_flag
                 );

          end loop;
        end loop;

     end if;
     commit;
   --bug 3199481 fnd logging changes: sdixit: start block
     WriteToLog ( 'END (Normal) Transfer to GL.');
     IF (l_state_level >=  l_debug_level ) THEN
     	FND_LOG.STRING  (l_state_level , 'igi.pls.igipmgtb.IGIPMGLT.InsertInterfaceRec',
                          'END (Normal) Transfer to GL.');
     END IF;
   --bug 3199481 fnd logging changes: sdixit: end block

     errbuf  := 'Normal Completion';
     retcode := 0;

  EXCEPTION WHEN OTHERS THEN
   --bug 3199481 fnd logging changes: sdixit: start block
           FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
           retcode := 2;
           errbuf :=  Fnd_message.get;

           IF ( l_unexp_level >= l_debug_level ) THEN

               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_unexp_level,'igi.pls.igipmgtb.IGIPMGLT.InsertInterfaceRec',TRUE);
           END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
  END;
END IGIPMGLT ;

/
