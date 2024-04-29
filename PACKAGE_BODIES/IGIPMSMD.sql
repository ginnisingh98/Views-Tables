--------------------------------------------------------
--  DDL for Package Body IGIPMSMD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGIPMSMD" AS
-- $Header: igipmmdb.pls 115.7 2003/12/01 14:58:03 sdixit ship $
-- ---------
-- CONSTANTS
-- ---------

AP_APPLICATION_ID   CONSTANT NUMBER(15)  := 200;
G_USER_ID           CONSTANT NUMBER(15)  := fnd_global.user_id;
G_DATE              CONSTANT DATE        := sysdate;
G_LOGIN_ID          CONSTANT NUMBER(15)  := fnd_global.login_id;
--bug 3199481: following variables added for fnd logging changes: sdixit
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
            , dist.description
     FROM   ap_invoice_distributions dist
     WHERE  dist.distribution_line_number = cp_distribution_line_number
     AND    dist.invoice_id               = cp_invoice_id
     ;

   CURSOR  c_ext_dist ( cp_invoice_id in number
                  , cp_distribution_line_number in number
                  )
   IS
     SELECT ext_dist.*
     FROM   igi_mpp_ap_invoice_dists  ext_dist
     WHERE  ext_dist.distribution_line_number = cp_distribution_line_number
     AND    ext_dist.invoice_id               = cp_invoice_id
     ;


    CURSOR c_rules ( cp_accounting_rule_id in number) IS
        SELECT  rr.rule_id, rr.type
        FROM    ra_rules rr
        where   rr.rule_id = cp_accounting_rule_id
        ;

    CURSOR c_rule_schedules (cp_accounting_rule_id in number) IS
        SELECT ras.period_number, ras.percent, ras.rule_id
        FROM   ra_rule_schedules ras
        WHERE  ras.rule_id = cp_accounting_rule_id
        ORDER BY period_number
        ;
-- ----------------
-- COMMON PROCEDURES
-- -----------------

   PROCEDURE WriteToLog ( pp_mesg in varchar2 ) IS
   BEGIN
      -- FND_FILE.put_line( FND_FILE.log, pp_mesg );
      -- dbms_output.put_line( pp_mesg);
      null;
   END;

-- -----------------
-- FUNCTIONS
-- -----------------
   FUNCTION GetEffPeriodNum  ( fp_period_name in varchar2
                             , fp_sob_id      in number
                             )
   RETURN NUMBER
   IS
     CURSOR c_effnum IS
      SELECT effective_period_num
      FROM   gl_period_statuses
      WHERE  application_id = AP_APPLICATION_ID
      AND    set_of_books_id = fp_sob_id
      AND    period_name    = fp_period_name
      ;
   BEGIN
       FOR l_eff in C_effnum LOOP
           return l_eff.effective_period_num;
       END LOOP;
   END GetEffPeriodNum;

   FUNCTION GetRelPeriodName ( fp_period_name in varchar2
                             , fp_sob_id      in number
                             , fp_relative    in number
                             )
   RETURN   VARCHAR2
   IS
     CURSOR   c_ap_periods  ( cp_eff_period_num in number) IS
        SELECT  gps.effective_period_num, gps.period_name
        FROM    gl_period_statuses gps
        WHERE   gps.application_id = AP_APPLICATION_ID
        AND     gps.set_of_books_id = fp_sob_id
        AND     gps.adjustment_period_flag <> 'Y'
        AND     gps.effective_period_num   >= cp_eff_period_num
        ORDER BY gps.effective_period_num
        ;
     l_eff_period_num NUMBER := 0;
     l_count NUMBER := 0;
   BEGIN
   --bug 3199481 fnd logging changes: sdixit: start block
       IF (l_state_level >=  l_debug_level ) THEN
          FND_LOG.STRING  (l_state_level , 'igi.pls.igipmmdb.IGIPMSMD.GetRelPeriodName',
                          '>> >> Current Period '||fp_period_name );
       END IF;
      l_eff_period_num := GetEffPeriodNum( fp_period_name, fp_sob_id );
       IF (l_state_level >=  l_debug_level ) THEN
          FND_LOG.STRING  (l_state_level , 'igi.pls.igipmmdb.IGIPMSMD.GetRelPeriodName',
                          '>> >> Current Eff Period Num '||l_eff_period_num );
       END IF;

      l_count := 0;
      FOR l_per IN c_ap_periods ( l_eff_period_num ) LOOP
           IF l_count = fp_relative THEN
       IF (l_state_level >=  l_debug_level ) THEN
          FND_LOG.STRING  (l_state_level , 'igi.pls.igipmmdb.IGIPMSMD.GetRelPeriodName',
                          '>> >> New Period Name '||l_per.period_name );
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
              return  l_per.period_name;
           ELSE
              l_count := l_count + 1;
           END IF;
      END LOOP;
      return fp_period_name;
   END GetRelPeriodName;


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


   PROCEDURE Create_MPP_Details
     ( p_invoice_id in number
     , p_distribution_line_number in number
     , p_accounting_rule_id       in number
     , p_start_date               in date
     , p_duration                 in number
     )   IS

   l_currency_code      ap_invoices_all.invoice_currency_code%TYPE := NULL;
   l_amount             ap_invoice_distributions_all.amount%TYPE := NULL;
   l_running_amount     ap_invoice_distributions_all.amount%TYPE := NULL;
   l_total_amount       ap_invoice_distributions_all.amount%TYPE := NULL;
   l_mpp_dist_line_num  igi_mpp_ap_invoice_dists_det.mpp_dist_line_number%TYPE;
   l_period_name        igi_mpp_ap_invoice_dists_det.period_name%TYPE;

   FUNCTION isVariableDuration ( fp_accounting_rule_id in  number)
   RETURN BOOLEAN  IS
      CURSOR c_exist is
        SELECT 'x'
        FROM   ra_rules
        WHERE  type = 'ACC_DUR'
        AND    rule_id = fp_accounting_rule_id
        ;
   BEGIN
      FOR l_exist in C_exist LOOP
         return TRUE;
      END LOOP;
      return FALSE;
   EXCEPTION WHEN OTHERS THEN
   --bug 3199481 fnd logging changes: sdixit: start block
      --standard way to handle when-others as per FND logging guidelines
           IF ( l_unexp_level >= l_debug_level ) THEN

               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_unexp_level,'igi.plsql.isipmsdb.igipmsmd.isVariableduration',TRUE);
           END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
     return FALSE;
   END ;

   PROCEDURE InsertRecord     ( p_mpp_dist_line_num in number
                              , p_dist              in c_dist%ROWTYPE
                              , p_period_name       in varchar2
                              , p_rule_id           in number
                              , p_amount            in number
                              )

   IS

   BEGIN
   --bug 3199481 fnd logging changes: sdixit: start block
       IF (l_state_level >=  l_debug_level ) THEN
          FND_LOG.STRING  (l_state_level , 'igi.pls.igipmmdb.IGIPMSMD.InsertRecord',
                          '>> >> ** Mpp dist line number '|| p_mpp_dist_line_num );
       END IF;
       IF (l_state_level >=  l_debug_level ) THEN
          FND_LOG.STRING  (l_state_level , 'igi.pls.igipmmdb.IGIPMSMD.InsertRecord',
                           '>> >> ** Mpp dist amount      '|| p_amount );
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block

         INSERT INTO  igi_mpp_ap_invoice_dists_det
               ( mpp_dist_line_number
               , distribution_line_number
               , invoice_id
               , last_updated_by
               , code_combination_id
               , last_update_date
               , period_name
               , created_by
               , creation_date
               , accounting_rule_id
               , description
               , amount
               , last_update_login  ) values (
                 p_mpp_dist_line_num
               , p_dist.distribution_line_number
               , p_dist.invoice_id
               , g_user_id
               , p_dist.dist_code_combination_id
               , g_date
               , p_period_name
               , g_user_id
               , g_date
               , p_rule_id
               , p_dist.description
               , p_amount
               , g_login_id  ) ;

   END;

   FUNCTION GetPeriod  ( fp_date    in date
                            , fp_sob_id  in number
                            )
   RETURN   varchar2 IS
           CURSOR c_period IS
           SELECT  period_name
           FROM    gl_period_statuses
           where   application_id = AP_APPLICATION_ID
           and     set_of_books_id = fp_sob_id
           and     adjustment_period_flag = 'N'
           and     fp_date between start_date and end_date
           ;
   BEGIN
          FOR  l_period in c_period LOOP
              return l_period.period_name;
          END LOOP;

          return null;
        EXCEPTION WHEN OTHERS THEN
   --bug 3199481 fnd logging changes: sdixit: start block
      --standard way to handle when-others as per FND logging guidelines

           IF ( l_unexp_level >= l_debug_level ) THEN

               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_unexp_level,'igi.plsql.igipmmdb.igipmsmd.GetPeriod',TRUE);
           END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
          return null;
   END GetPeriod;

   PROCEDURE CreateFixedDists ( p_dist in c_dist%ROWTYPE
                              , p_accounting_rule_id in number
                              , p_running_amount in out NOCOPY number
                              , p_currency_code in varchar2
                              , p_mpp_dist_line_num in out NOCOPY number
                              , p_start_date in date
                              ) IS
        l_period_name varchar2(80);
        l_amount  number;
        l_first_period_name varchar2(80);



   BEGIN

        l_first_period_name := nvl(GetPeriod(p_start_date,
                                         p_dist.set_of_books_id
                                        ), p_dist.period_name) ;

        FOR l_rs IN c_rule_schedules ( p_accounting_rule_id) LOOP
   --bug 3199481 fnd logging changes: sdixit: start block
            IF (l_state_level >=  l_debug_level ) THEN
               FND_LOG.STRING  (l_state_level , 'igi.pls.igipmmdb.IGIPMSMD.CreateFixedDists',
                          '>> Processing Accounting Rules ...');
            END IF;
   --bug 3199481 fnd logging changes: sdixit: end block

             p_mpp_dist_line_num := p_mpp_dist_line_num + 1;
   --bug 3199481 fnd logging changes: sdixit: start block
           IF (l_state_level >=  l_debug_level ) THEN
              FND_LOG.STRING  (l_state_level , 'igi.pls.igipmmdb.IGIPMSMD.CreateFixedDists',
                          '>> MPP Distribution Line number '||p_mpp_dist_line_num );
            END IF;
   --bug 3199481 fnd logging changes: sdixit: end block

             l_amount         := (l_rs.percent/100) * p_dist.amount;
   --bug 3199481 fnd logging changes: sdixit: start block
           IF (l_state_level >=  l_debug_level ) THEN
               FND_LOG.STRING  (l_state_level , 'igi.pls.igipmmdb.IGIPMSMD.CreateFixedDists',
                          '>> MPP Distribution Amount (Before Rounding) '||l_amount );
           END IF;
   --bug 3199481 fnd logging changes: sdixit: end block

             l_amount         := arp_util.CurrRound( l_amount, p_currency_code );
             p_running_amount := p_running_amount - l_amount;
   --bug 3199481 fnd logging changes: sdixit: start block
       IF (l_state_level >=  l_debug_level ) THEN
          FND_LOG.STRING  (l_state_level , 'igi.pls.igipmmdb.IGIPMSMD.CreateFixedDists',
                          '>> MPP Distribution Amount (After Rounding) '||l_amount );
       END IF;
       IF (l_state_level >=  l_debug_level ) THEN
          FND_LOG.STRING  (l_state_level , 'igi.pls.igipmmdb.IGIPMSMD.CreateFixedDists',
                          '>> Balance  '||p_running_amount );
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block



             l_Period_name  := GetRelPeriodName
                                    ( l_first_period_name
                                    , p_dist.set_of_books_id
                                    , p_mpp_dist_line_num -1
                                    ) ;
   --bug 3199481 fnd logging changes: sdixit: start block
           IF (l_state_level >=  l_debug_level ) THEN
              FND_LOG.STRING  (l_state_level , 'igi.pls.igipmmdb.IGIPMSMD.CreateFixedDists',
                          '>> MPP Distribution Period  '||l_period_name );
           END IF;
           IF (l_state_level >=  l_debug_level ) THEN
              FND_LOG.STRING  (l_state_level , 'igi.pls.igipmmdb.IGIPMSMD.CreateFixedDists',
                          '>> Inserting the record into MPP details...' );
           END IF;
   --bug 3199481 fnd logging changes: sdixit: end block

              InsertRecord     ( p_mpp_dist_line_num
                         , p_dist
                         , l_period_name
                         , p_accounting_rule_id
                         , l_amount
                         ) ;
     END LOOP;

   END CreateFixedDists;

   PROCEDURE CreateVariableDists ( p_dist in c_dist%ROWTYPE
                                 , p_accounting_rule_id in number
                                 , p_running_amount in out NOCOPY number
                                 , p_currency_code in varchar2
                                 , p_start_date    in date
                                 , p_duration      in number
                                 , p_mpp_dist_line_num in out NOCOPY number
                                 ) IS
        l_period_name varchar2(80);
        l_first_period_name varchar2(80);
        l_amount  number;
        l_amount_remaining NUMBER;


        FUNCTION GetPercent ( fp_rule_id in number
                            , fp_duration_is_1 in boolean
                            )
        RETURN NUMBER IS
          CURSOR c_percent is
             SELECT  nvl(percent,0)/100  percent_value
             FROM    ra_rule_schedules
             WHERE   rule_id = fp_rule_id
             AND     period_number = 1
             ;
        BEGIN
          IF fp_duration_is_1 THEN
             return 100;
          END IF;

          FOR l_percent in C_percent LOOP
              return l_percent.percent_value;
          END LOOP;
          return 0;
        EXCEPTION WHEN OTHERS THEN
   --bug 3199481 fnd logging changes: sdixit: start block
      --standard way to handle when-others as per FND logging guidelines

           IF ( l_unexp_level >= l_debug_level ) THEN

               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_unexp_level,'igi.plsql.igipmmdb.igipmsmd.GetPercent',TRUE);
           END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
          return 0;
        END GetPercent;

   BEGIN
        --
        -- Create the FIRST line
        --
        p_mpp_dist_line_num := 1;
        l_amount            := p_dist.amount * GetPercent( p_accounting_rule_id ,
                                     p_duration = 1 );
   --bug 3199481 fnd logging changes: sdixit: start block
        IF (l_state_level >=  l_debug_level ) THEN
           FND_LOG.STRING  (l_state_level , 'igi.pls.igipmmdb.IGIPMSMD.CreateVariableDists',
                          '>> >> First instalment '|| l_amount );
        END IF;

        l_amount            := arp_util.CurrRound( l_amount, p_currency_code );
        p_running_amount    := p_running_amount - l_amount;
        l_first_period_name := GetPeriod ( p_start_date, p_dist.set_of_books_id );

	IF (l_state_level >=  l_debug_level ) THEN
           FND_LOG.STRING  (l_state_level , 'igi.pls.igipmmdb.IGIPMSMD.CreateVariableDists',
                          '>> >> Period Name '|| l_period_name );
        END IF;
   --bug 3199481 fnd logging changes: sdixit: end block

        InsertRecord     ( p_mpp_dist_line_num
                         , p_dist
                         , l_first_period_name
                         , p_accounting_rule_id
                         , l_amount
                         ) ;

        if p_duration = 1 then
           return;
        end if;

        l_amount_remaining := p_dist.amount - l_amount;
        l_amount           := l_amount_remaining / (p_duration - 1);
   --bug 3199481 fnd logging changes: sdixit: start block
        IF (l_state_level >=  l_debug_level ) THEN
          FND_LOG.STRING  (l_state_level , 'igi.pls.igipmmdb.IGIPMSMD.CreateVariableDists',
                          '>> MPP Distribution Amount (Before Rounding) '||l_amount );
        END IF;
        l_amount           := arp_util.CurrRound( l_amount, p_currency_code );
        IF (l_state_level >=  l_debug_level ) THEN
           FND_LOG.STRING  (l_state_level , 'igi.pls.igipmmdb.IGIPMSMD.CreateVariableDists',
                          '>> MPP Distribution Amount (After Rounding) '||l_amount );
        END IF;
   --bug 3199481 fnd logging changes: sdixit: end block

        FOR t_mpp_dist_line_num  IN 2 .. p_duration LOOP
             p_mpp_dist_line_num := t_mpp_dist_line_num;

   --bug 3199481 fnd logging changes: sdixit: start block
           IF (l_state_level >=  l_debug_level ) THEN
              FND_LOG.STRING  (l_state_level , 'igi.pls.igipmmdb.IGIPMSMD.CreateVariableDists',
                          '>> MPP Distribution Line number '||p_mpp_dist_line_num );
           END IF;

             p_running_amount := p_running_amount - l_amount;
             IF (l_state_level >=  l_debug_level ) THEN
              FND_LOG.STRING  (l_state_level , 'igi.pls.igipmmdb.IGIPMSMD.CreateVariableDists',
                          '>> Balance  '||p_running_amount );
             END IF;
   --bug 3199481 fnd logging changes: sdixit: end block

             l_Period_name  := GetRelPeriodName
                                    ( l_first_period_name
                                    , p_dist.set_of_books_id
                                    , p_mpp_dist_line_num -1
                                    ) ;
   --bug 3199481 fnd logging changes: sdixit: start block
       IF (l_state_level >=  l_debug_level ) THEN
          FND_LOG.STRING  (l_state_level , 'igi.pls.igipmmdb.IGIPMSMD.CreateVariableDists',
                          '>> MPP Distribution Period  '||l_period_name );
       END IF;
       IF (l_state_level >=  l_debug_level ) THEN
          FND_LOG.STRING  (l_state_level , 'igi.pls.igipmmdb.IGIPMSMD.CreateVariableDists',
                          '>> Inserting the record into MPP details...' );
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
             InsertRecord     ( p_mpp_dist_line_num
                         , p_dist
                         , l_period_name
                         , p_accounting_rule_id
                         , l_amount
                         ) ;
     END LOOP;

   END CreateVariableDists;

   BEGIN  /** create mpp distributions **/


   --bug 3199481: fnd logging changes: sdixit : start
   IF (l_state_level >=  l_debug_level ) THEN
       FND_LOG.STRING  (l_state_level , 'igi.pls.igipmmdb.IGIPMSMD',
                          'Begin Creation of MPP Dist Details...');
   END IF;

   l_currency_code := GetInvoiceCurrency ( p_invoice_id );
   IF (l_state_level >=  l_debug_level ) THEN
       FND_LOG.STRING  (l_state_level , 'igi.pls.igipmmdb.IGIPMSMD',
                          '>> Invoice Currency '||l_currency_code );
   END IF;
   --bug 3199481 fnd logging changes: sdixit: end block

   FOR l_dist in c_dist ( p_invoice_id, p_distribution_line_number ) LOOP

     l_mpp_dist_line_num  := 0;
     l_total_amount       := l_dist.amount;
     l_running_amount     := l_dist.amount;
   --bug 3199481 fnd logging changes: sdixit: start block
       IF (l_state_level >=  l_debug_level ) THEN
          FND_LOG.STRING  (l_state_level , 'igi.pls.igipmmdb.IGIPMSMD',
                          '>> Processing Invoice Distributions ...');
       END IF;
       IF (l_state_level >=  l_debug_level ) THEN
          FND_LOG.STRING  (l_state_level , 'igi.pls.igipmmdb.IGIPMSMD',
                          '>> Distribution Amount '||l_total_amount );
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block

     IF IsVariableDuration ( p_accounting_rule_id ) THEN
        CreateVariableDists      ( l_dist
                                 , p_accounting_rule_id
                                 , l_running_amount
                                 , l_currency_code
                                 , p_start_date
                                 , p_duration
                                 , l_mpp_dist_line_num
                                 );
     ELSE
         CreateFixedDists ( l_dist
                         , p_accounting_rule_id
                         , l_running_amount
                         , l_currency_code
                         , l_mpp_dist_line_num
                         , p_start_date
                         );
     END IF;

   --bug 3199481 fnd logging changes: sdixit: start block
       IF (l_state_level >=  l_debug_level ) THEN
          FND_LOG.STRING  (l_state_level , 'igi.pls.igipmmdb.IGIPMSMD',
                          '>> Rounding Checks... ');
          FND_LOG.STRING  (l_state_level , 'igi.pls.igipmmdb.IGIPMSMD',
                    '>> >> Running Amount '|| l_running_amount );
          FND_LOG.STRING  (l_state_level , 'igi.pls.igipmmdb.IGIPMSMD',
                          '>> >> Dist Line Num  '|| l_mpp_dist_line_num );
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
     IF l_running_amount <> 0 AND l_mpp_dist_line_num <> 0 THEN

        UPDATE igi_mpp_ap_invoice_dists_det
        SET    amount = amount + l_running_amount
        WHERE  invoice_id  = l_dist.invoice_id
        AND    distribution_line_number = l_dist.distribution_line_number
        AND    mpp_dist_line_number     = l_mpp_dist_line_num
        ;
   --bug 3199481 fnd logging changes: sdixit: start block
       IF (l_state_level >=  l_debug_level ) THEN
          FND_LOG.STRING  (l_state_level , 'igi.pls.igipmmdb.IGIPMSMD',
                          '>> Rounding Performed on the last mpp distribution '||               l_mpp_dist_line_num );
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block

     ELSE
   --bug 3199481 fnd logging changes: sdixit: start block
           IF (l_state_level >=  l_debug_level ) THEN
                FND_LOG.STRING  (l_state_level , 'igi.pls.igipmmdb.IGIPMSMD',
                          '>> Rounding Check okay!... ');
           END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
     END IF;

   END LOOP;

   END;

   PROCEDURE Update_MPP_Details
     ( p_invoice_id in number
     , p_distribution_line_number in number
     , p_accounting_rule_id       in number
     )   IS
   BEGIN
      NULL;
   END;



   PROCEDURE Delete_MPP_details
     ( p_invoice_id in number
     , p_distribution_line_number in number
     , p_accounting_rule_id       in number
     , p_ignore_mpp_flag          in number
     )
   IS
   BEGIN
      NULL;
   END;


END;

/
