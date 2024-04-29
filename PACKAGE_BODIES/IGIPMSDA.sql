--------------------------------------------------------
--  DDL for Package Body IGIPMSDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGIPMSDA" AS
-- $Header: igipmsdb.pls 115.13 2003/12/01 14:59:08 sdixit ship $

     g_user_id   NUMBER := fnd_global.user_id;
     g_date      DATE   := sysdate;
     g_login_id  NUMBER := fnd_global.login_id;
   --bug 3199481: following variables added for fnd logging changes:sdixit :start
   l_debug_level number	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   l_state_level number	:=	FND_LOG.LEVEL_STATEMENT;
   l_proc_level number	:=	FND_LOG.LEVEL_PROCEDURE;
   l_event_level number	:=	FND_LOG.LEVEL_EVENT;
   l_excep_level number	:=	FND_LOG.LEVEL_EXCEPTION;
   l_error_level number	:=	FND_LOG.LEVEL_ERROR;
   l_unexp_level number	:=	FND_LOG.LEVEL_UNEXPECTED;

     PROCEDURE WriteToLog ( pp_mesg in varchar2) IS
     BEGIN
        FND_FILE.put_line( FND_FILE.log, pp_mesg );
     END WriteToLog;

     PROCEDURE Synchronize_Invoice ( p_invoice_id in number
                                   , p_accounting_rule_id in number
                                   ) IS
       l_default_acc_rule_id NUMBER(15);
       l_parent_distribution_id number(15);
       l_default_flag        VARCHAR2(1) := 'N';
       l_duration            number;
       l_continue            BOOLEAN;
    /*
    -- Check if the invoice has been approved or cancelled
    -- This excludes prepayments automatically.
    */
      CURSOR c_proper_inv (cp_invoice_id in number) IS
         SELECT  inv.invoice_id, inv.approval_status_lookup_code
         from    ap_invoices_v inv
         WHERE   inv.invoice_id = cp_invoice_id
         and     inv.approval_status_lookup_code
                 in  ('APPROVED', 'CANCELLED')
         ;

      CURSOR c_proper_dist ( cp_invoice_id in number) IS
          SELECT inv_dist.invoice_id, inv_dist.distribution_line_number
                 , inv_dist.invoice_distribution_id, inv_dist.dist_code_combination_id
                 , inv_dist.accounting_date gl_date
          FROM   ap_invoice_distributions inv_dist
          WHERE  inv_dist.invoice_id   = cp_invoice_id
          AND    ( inv_dist.line_type_lookup_code = 'ITEM' OR
                   ( inv_dist.line_type_lookup_code = 'TAX' AND
                     inv_dist.tax_recoverable_flag  = 'N'   AND
                        ( not ( inv_dist.tax_recovery_override_flag is not null ) OR
                          inv_dist.tax_recovery_override_flag = 'N'
                        )
                   )
                 )
          AND    match_status_flag     = 'A'
          ;

      FUNCTION DefaultRuleId ( cp_code_combination_id in number
                             )
      RETURN NUMBER
      IS
         CURSOR c_rule IS
           SELECT  default_accounting_rule_id, 1 priority
           FROM    igi_mpp_expense_rules
           WHERE   enabled_flag = 'Y'
           and     expense_ccid = cp_code_combination_id
           UNION
           SELECT  p_accounting_rule_id, 2 priority
           FROM    SYS.DUAL
           WHERE   p_accounting_rule_id is not null
           UNION
           SELECT  default_accounting_rule_id, 3 priority
           FROM    igi_mpp_setup
           ORDER   BY 2
           ;
      BEGIN
         FOR l_rule in C_rule LOOP
             return l_rule.default_accounting_rule_id;
         END LOOP;
         return -1;
      END DefaultRuleID
      ;
      FUNCTION InvoiceDistExists ( cp_invoice_id in number
                                 , cp_distribution_line_number in number
                                 ) RETURN BOOLEAN IS
         CURSOR c_exists IS
            SELECT 'x'
            FROM  igi_mpp_ap_invoice_dists
            WHERE invoice_id = cp_invoice_id
            AND   distribution_line_number = cp_distribution_line_number
            ;

      BEGIN
         FOR l_exists IN C_exists LOOP
            return TRUE;
         END LOOP;
         return FALSE;
      END InvoiceDistExists
      ;
      FUNCTION InvoiceExists ( cp_invoice_id in number )
      RETURN BOOLEAN IS
         CURSOR c_exists IS
            SELECT 'x'
            FROM  igi_mpp_ap_invoices
            WHERE invoice_id = cp_invoice_id
            ;
      BEGIN
         FOR l_exists IN C_exists LOOP
            return TRUE;
         END LOOP;
         return FALSE;
      END InvoiceExists;

      FUNCTION IsReversal ( fp_invoice_id   in  number
                          , fp_distribution_line_number in number
                          )
      RETURN BOOLEAN IS
      CURSOR C_reversal IS
         select parent_reversal_id
         from ap_invoice_distributions
         where invoice_id               = fp_invoice_id
         and   distribution_line_number = fp_distribution_line_number
         and   reversal_flag            = 'Y'
         and   parent_reversal_id       is not null
      ;

      BEGIN

         for l_reversal in c_reversal loop
             return TRUE;
         end loop;
         return FALSE;

      END IsReversal;

      FUNCTION   ParentDistributionID ( fp_invoice_distribution_id in number )
      RETURN NUMBER IS
         CURSOR c_rev IS
           SELECT parent_reversal_id
           FROM   ap_invoice_distributions
           WHERE  invoice_distribution_id = fp_invoice_distribution_id;
      BEGIN
         FOR l_rev in c_rev LOOP
            return l_rev.parent_reversal_id;
         END LOOP;
         return -1;
      EXCEPTION WHEN OTHERS THEN
      --bug 3199481 fnd logging changes:sdixit :start
      --standard way to handle when-others as per FND logging guidelines

           IF ( l_unexp_level >= l_debug_level ) THEN

               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_unexp_level,'igi.plsql.l.igipmsdb.ParentDistributionID',TRUE);
           END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
         return -1;

      END ParentDistributionID;
      PROCEDURE  GetMPPDefaults ( fp_invoice_distribution_id in number
                                , ofp_accounting_rule_id     in out NOCOPY number
                                , ofp_ignore_mpp_flag        in out NOCOPY varchar2
                                )
      IS
          CURSOR c_defaults IS
             SELECT  mpp_dist.accounting_rule_id, mpp_dist.ignore_mpp_flag
             FROM    igi_mpp_ap_invoice_dists mpp_dist
             ,       ap_invoice_distributions dist
             WHERE   dist.invoice_id         = mpp_dist.invoice_id
             and     dist.distribution_line_number
                                 = mpp_dist.distribution_line_number
             and     dist.reversal_flag = 'Y'
             and     dist.invoice_distribution_id
                                 = fp_invoice_distribution_id
             ;
      BEGIN
         FOR l_defaults in c_defaults LOOP
              ofp_accounting_rule_id := l_defaults.accounting_rule_id ;
              ofp_ignore_mpp_flag    := l_defaults.ignore_mpp_flag;
         END LOOP;

      END GetMPPDefaults;


   BEGIN
       --bug 3199481: fnd logging changes:sdixit :start
       IF (l_state_level >=  l_debug_level ) THEN
          FND_LOG.STRING  (l_state_level , 'igi.plsql.igipmsdb.IGIPMSDA.SynchronizeInvoice',
                          'BEGIN  MPP Expense collection');
       END IF;
       IF (l_state_level >=  l_debug_level ) THEN
          FND_LOG.STRING  (l_state_level , 'igi.plsql.igipmsdb.IGIPMGLT.InsertInterfaceRec',
                          '>> Invoice Id '||p_invoice_id||' >>');
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block

       FOR l_inv in c_proper_inv ( p_invoice_id ) LOOP

          l_continue := TRUE;
          --bug 3199481: fnd logging changes:sdixit :start
          IF (l_state_level >=  l_debug_level ) THEN
             FND_LOG.STRING  (l_state_level ,  'igi.plsql.igipmsdb.IGIPMSDA.SynchronizeInvoice',
                           '>> Invoice has been '||l_inv.approval_status_lookup_code );
          END IF;
   --bug 3199481 fnd logging changes: sdixit: end block

          IF NOT invoiceExists ( l_inv.invoice_id ) THEN
             IF l_inv.approval_status_lookup_code = 'CANCELLED' THEN
                l_continue := FALSE;
             ELSE
           -- Drop record into MPP extended invoice table
           --bug 3199481: fnd logging changes:sdixit :start
           IF (l_state_level >=  l_debug_level ) THEN
              FND_LOG.STRING  (l_state_level ,  'igi.plsql.igipmsdb.IGIPMSDA.SynchronizeInvoice',
                          '>> Invoice Does not exist in MPP extended table. Inserting...');
           END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
                INSERT INTO igi_mpp_ap_invoices
                 (  invoice_id
                 ,  accounting_rule_id
                 ,  ignore_mpp_flag
                 ,  created_by
                 ,  creation_date
                 ,  last_updated_by
                 ,  last_update_date
                 ,  last_update_login
                 )  VALUES (
                   l_inv.invoice_id
                 ,  p_accounting_rule_id
                 ,  'N'
                 ,  g_user_id
                 ,  g_date
                 ,  g_user_id
                 ,  g_date
                 ,  g_login_id
                 );
              END IF;
           END IF;

           IF l_continue THEN

           --bug 3199481: fnd logging changes:sdixit :start
           IF (l_state_level >=  l_debug_level ) THEN
              FND_LOG.STRING  (l_state_level ,  'igi.plsql.igipmsdb.IGIPMSDA.SynchronizeInvoice',
                         '>> Continuing... ');
           END IF;
              IF InvoiceExists ( l_inv.invoice_id ) THEN

           IF (l_state_level >=  l_debug_level ) THEN
              FND_LOG.STRING  (l_state_level ,  'igi.plsql.igipmsdb.IGIPMSDA.SynchronizeInvoice',
                           '>> Invoice Does exists. Check the extended distribution records...');
           END IF;

              FOR  l_dist in C_proper_dist ( l_inv.invoice_id ) LOOP

           IF (l_state_level >=  l_debug_level ) THEN
              FND_LOG.STRING  (l_state_level , 'igi.plsql.igipmsdb.IGIPMSDA.SynchronizeInvoice',
                          '>>  Distribution Exists. Insert Extended Dist if not there...');
           END IF;
   --bug 3199481 fnd logging changes: sdixit: end block

                   IF Not InvoiceDistExists ( l_dist.invoice_id,
                                         l_dist.distribution_line_number )
                   THEN
     --bug 3199481: fnd logging changes:sdixit :start
       IF (l_state_level >=  l_debug_level ) THEN
          FND_LOG.STRING  (l_state_level ,  'igi.plsql.igipmsdb.IGIPMSDA.SynchronizeInvoice',
                          '>> Insert Extended Dist.');
       END IF;
     --bug 3199481 fnd logging changes: sdixit: end block


                          l_default_acc_rule_id := DefaultRuleID
                               ( l_dist.dist_code_combination_id );
                          l_default_flag        := 'N';

                          IF   IsReversal  ( l_dist.invoice_id,
                                         l_dist.distribution_line_number )
                          THEN
                              l_parent_distribution_id :=
                                   ParentDistributionID
                                    ( l_dist.invoice_distribution_id );
                              if l_parent_distribution_id = -1 then
                                  l_parent_distribution_id :=
                                       l_dist.invoice_distribution_id;
                              end if;

                              GetMPPDefaults
                                ( l_parent_distribution_id
                                , l_default_acc_rule_id
                                , l_default_flag );
                          END IF;

                          select occurrences
                          into   l_duration
                          from   ra_rules
                          where  rule_id = l_default_acc_rule_id;


                          INSERT into igi_mpp_ap_invoice_dists
                           (
                             distribution_line_number
                            ,invoice_id
                            ,accounting_rule_id
                            ,ignore_mpp_flag
                            ,start_date
                            ,duration
                            ,created_by
                            ,creation_date
                            ,last_updated_by
                            ,last_update_date
                            ,last_update_login
                           ) VALUES (  l_dist.distribution_line_number
                                    ,  l_dist.invoice_id
                                    ,  l_default_acc_rule_id
                                    ,  l_default_flag
                                    ,  l_dist.gl_date
                                    ,  l_duration
                                    ,  g_user_id
                                    ,  g_date
                                    ,  g_user_id
                                    ,  g_date
                                    ,  g_login_id
                            );



                   END IF;

              END LOOP;
             END IF;
           END IF; -- If can continue
       END LOOP;
       --bug 3199481: fnd logging changes:sdixit :start
       IF (l_state_level >=  l_debug_level ) THEN
          FND_LOG.STRING  (l_state_level ,  'igi.plsql.igipmsdb.IGIPMSDA.SynchronizeInvoice',
                       'END MPP Expense Collection.');
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block

   EXCEPTION
      WHEN others THEN
      --standard way to handle when-others as per FND logging guidelines

           IF ( l_unexp_level >= l_debug_level ) THEN

               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_unexp_level,'igi.plsql.igipmsdb.IGIPMSDA.SynchronizeInvoice',TRUE);
           END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
          raise_application_error ( -20000, SQLERRM);
   END;

   PROCEDURE Synchronize_transfer ( errbuf  out NOCOPY varchar2
                         , retcode out NOCOPY  number
                         , p_transfer_id in number ) IS
         CURSOR c_inv IS
           SELECT apinv.invoice_id, imit.accounting_rule_id, imit.rowid
                  imit_rowid
           from   ap_invoices_v apinv
           ,      igi_mpp_invoice_transfer imit
           WHERE  apinv.approval_status_lookup_code = 'APPROVED'
           AND    imit.invoice_id = apinv.invoice_id
           AND    imit.transfer_id = p_transfer_id
           ;

        FUNCTION IsTransferOK ( fp_invoice_id in number )
        RETURN BOOLEAN IS
            CURSOR c_trx IS
                SELECT  'x'
                FROM    igi_mpp_ap_invoices
                WHERE   invoice_id = fp_invoice_id
                ;
        BEGIN
             FOR l_trx in c_trx LOOP
                 return TRUE;
             END LOOP;
             return FALSE;
        END IsTransferOK;

   BEGIN
           --bug 3199481: fnd logging changes:sdixit :start
       IF (l_state_level >=  l_debug_level ) THEN
          FND_LOG.STRING  (l_state_level , 'igi.plsql.igipmsdb.IGIPMSDA.SynchronizeTransfer',
                         ' Transfer ID : '||p_transfer_id        );
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
         FOR l_inv in C_inv LOOP
           --bug 3199481: fnd logging changes:sdixit :start
       IF (l_state_level >=  l_debug_level ) THEN
          FND_LOG.STRING  (l_state_level , 'igi.plsql.igipmsdb.IGIPMSDA.SynchronizeTransfer',
                          ' Transfer : '||l_inv.invoice_id );
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
             Synchronize_invoice ( l_inv.invoice_id, l_inv.accounting_rule_id );
             IF IsTransferOK ( l_inv.invoice_id) THEN
                   delete from  igi_mpp_invoice_transfer
                   where  rowid = l_inv.imit_rowid
                   ;
             END IF;
         END LOOP;
         commit;
         errbuf := 'Normal Completion';
         retcode := 0;
   EXCEPTION WHEN OTHERS THEN
             rollback;
   --bug 3199481 fnd logging changes: sdixit: start block
      FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
      retcode := 2;
      errbuf :=  Fnd_message.get;

           IF ( l_unexp_level >= l_debug_level ) THEN

               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_unexp_level,'igi.plsql.igipmsdb.IGIPMSDA.SynchronizeTransfer',TRUE);
           END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
             return;
   END ;

   PROCEDURE Synchronize ( errbuf  out NOCOPY varchar2
                         , retcode out NOCOPY  number
                         , p_mode          in varchar2
                         , p_invoice_num   in varchar2
                         , p_vendor_name   in varchar2
                         , p_batch_name    in varchar2
                         ) IS
       CURSOR c_inv IS
         SELECT invoice_id
         from   ap_invoices_v apinv
         where  vendor_name = nvl(p_vendor_name, vendor_name)
         and    ( ( p_batch_name is null     )
                  OR
                  ( ( p_batch_name is not null )   AND
                     batch_name = p_batch_name
                  )
                )
         and    invoice_num = nvl(p_invoice_num, invoice_num)
         and    approval_status_lookup_code in ( 'APPROVED', 'CANCELLED')
         and    set_of_books_id = ( select set_of_books_id from ap_system_parameters )
         ;

         FUNCTION  ModeCheck ( fp_mode in varchar2
                             , fp_invoice_id in number
                             )
         RETURN BOOLEAN IS
            CURSOR c_igi_inv IS
               SELECT 'x'
               FROM   igi_mpp_ap_invoices
               WHERE  invoice_id     = fp_invoice_id
               ;
           b_rec_found BOOLEAN ;
         BEGIN

            b_rec_found := FALSE;

            FOR l_igi IN c_igi_inv LOOP
                b_rec_found := TRUE;
            END LOOP;

            IF p_mode = 'EXISTING' THEN
               IF b_rec_found THEN
                  return TRUE;
               ELSE
                  return FALSE;
               END IF;
            ELSIF p_mode = 'NEW'   THEN
               IF b_rec_found THEN
                  return FALSE;
               ELSE
                  return TRUE;
               END IF;
            ELSIF  p_mode = 'ALL'  THEN
               return TRUE;
            ELSE
               return FALSE;
            END IF;
         EXCEPTION WHEN OTHERS THEN
      --bug 3199481 fnd logging changes:sdixit :start

           IF ( l_unexp_level >= l_debug_level ) THEN

               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_unexp_level,'igi.plsql.l.igipmsdb.IGIPMSDA.ModeCheck',TRUE);
           END IF;
             return FALSE;
         END ModeCheck;
   BEGIN

         --bug 3199481: fnd logging changes:sdixit :start
       IF (l_state_level >=  l_debug_level ) THEN
          FND_LOG.STRING  (l_state_level ,'igi.plsql.igipmsdb.IGIPMSDA.Synchronize',
                          'Expense Collection mode : '||p_mode        );
          FND_LOG.STRING  (l_state_level , 'igi.plsql.igipmsdb.IGIPMSDA.Synchronize',
                          'Invoice number          : '||p_invoice_num );
          FND_LOG.STRING  (l_state_level , 'igi.plsql.igipmsdb.IGIPMSDA.Synchronize',
                           ' Vendor name             : '||p_vendor_name );
          FND_LOG.STRING  (l_state_level , 'igi.plsql.igipmsdb.IGIPMSDA.Synchronize',
                         ' Batch name              : '||p_batch_name  );
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block

         FOR l_inv in C_inv LOOP

             IF ModeCheck ( p_mode, l_inv.invoice_id ) THEN
           --bug 3199481: fnd logging changes:sdixit :start
       IF (l_state_level >=  l_debug_level ) THEN
          FND_LOG.STRING  (l_state_level , 'igi.plsql.igipmsdb.IGIPMSDA.Synchronize',
                          ' Process : '||l_inv.invoice_id );
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
                Synchronize_Invoice ( l_inv.invoice_id );
             END IF;

         END LOOP;
         COMMIT;
         errbuf := 'Normal Completion';
         retcode := 0;


   EXCEPTION WHEN OTHERS THEN
             rollback;
   --bug 3199481 fnd logging changes: sdixit: start block
             --errbuf := SQLERRM;
             --retcode := 2;
      --standard way to handle when-others as per FND logging guidelines
             FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_USER_ERROR'); -- Seeded Message
             retcode := 2;
             errbuf :=  Fnd_message.get;

             IF ( l_unexp_level >= l_debug_level ) THEN

                 FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
                 FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
                 FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
                 FND_LOG.MESSAGE ( l_unexp_level,'igi.plsql.igipmsdb.IGIPMSDA.Synchronize',TRUE);
             END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
             return;
   END   Synchronize;

END IGIPMSDA ;

/
