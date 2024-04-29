--------------------------------------------------------
--  DDL for Package Body PA_MC_INVOICE_DETAIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_MC_INVOICE_DETAIL_PKG" as
/* $Header: PAMCIDTB.pls 120.3 2005/08/26 11:26:18 skannoji noship $*/

     L_PROJECT_ID              PA_PLSQL_DATATYPES.IdTabTyp;
     L_INVOICED_FLAG           PA_PLSQL_DATATYPES.Char1TabTyp;
     L_ACCT_CURRENCY_CODE      PA_PLSQL_DATATYPES.Char30TabTyp;
     L_BILL_AMOUNT             PA_PLSQL_DATATYPES.NumTabTyp;
     L_ACCT_RATE_TYPE          PA_PLSQL_DATATYPES.Char30TabTyp;
     L_ACCT_RATE_DATE          PA_PLSQL_DATATYPES.Char30TabTyp;
     L_ACCT_EXCHANGE_RATE      PA_PLSQL_DATATYPES.NumTabTyp;
     L_DRAFT_INV_DET_ID        PA_PLSQL_DATATYPES.IdTabTyp;
     L_PROG_APP_ID             PA_PLSQL_DATATYPES.IdTabTyp;
     L_PROG_ID                 PA_PLSQL_DATATYPES.IdTabTyp;
     L_PROG_UPDATE_DATE        PA_PLSQL_DATATYPES.Char30TabTyp;
     L_SETS_OF_BOOKS_ID        PA_PLSQL_DATATYPES.IdTabTyp;


g1_debug_mode varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

PROCEDURE get_orig_exchg_rate (l_line_id           IN NUMBER,
                               l_sob_id            IN NUMBER,
                               l_exchange_rate    OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                               l_exchange_date    OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                               l_exchange_rate_type OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                               l_bill_amount           OUT NOCOPY NUMBER ) --File.Sql.39 bug 4440895
IS
BEGIN
NULL;
EXCEPTION
  WHEN OTHERS
  THEN
       RAISE;
END get_orig_exchg_rate;

PROCEDURE download ( P_inv_rec_tab       IN  PA_INVOICE_DETAIL_PKG.inv_rec_tab,
                     P_record_cnt        IN  number,
                     P_Draft_inv_det_id OUT  NOCOPY  PA_PLSQL_DATATYPES.numtabtyp)
IS
BEGIN
  FOR I in 1..P_record_cnt
  LOOP
      P_Draft_inv_det_id(I) := P_inv_rec_tab(I).DRAFT_INVOICE_DETAIL_ID;
  END LOOP;
END download;

PROCEDURE compute_mrc (P_inv_rec_tab   IN  PA_INVOICE_DETAIL_PKG.inv_rec_tab,
                       P_trx_date      IN  PA_PLSQL_DATATYPES.DateTabTyp,
                       P_rec_counter   IN  NUMBER,
                       P_mrc_reqd_flag IN  PA_PLSQL_DATATYPES.Char1TabTyp,
                       P_tot_record   OUT  NOCOPY NUMBER ) --File.Sql.39 bug 4440895
IS
  orig_ref              VARCHAR2(30);
  adj_item              NUMBER;
  linkage               VARCHAR2(30);
  ei_date               DATE;
--Bug#1078399
--New parameter x_txn_source added in eiid_details() - to be used to check whether
--the EI is an imported-one or not.
  ei_txn_source         VARCHAR2(30);
  l_currency            VARCHAR2(20);
  l_err_stack           VARCHAR2(80);
  l_err_stage           VARCHAR2(80);
  l_exchange_date       DATE;
  l_exchange_rate       NUMBER;
  l_exchange_rate_type  VARCHAR2(16);
  l_sob_id              NUMBER;
  l_line_num            NUMBER;
  l_err_code            NUMBER;
  l_result_code         VARCHAR2(15);
  I                     NUMBER;
  J                     NUMBER;
  K                     NUMBER := 0;
  l_tot_record          NUMBER := 0;
  L_mrc_reqd_flag       varchar2(1);
  l_bill_amt            NUMBER;
  l_denom               NUMBER;
  l_num                 NUMBER;

BEGIN

 l_currency := PA_MC_INVOICE_DETAIL_PKG.G_FUNC_CURR;
 l_sob_id   := PA_MC_INVOICE_DETAIL_PKG.G_SOB;
 P_tot_record := 0;

 IF g1_debug_mode  = 'Y' THEN
 	PA_IC_INV_UTILS.log_message('compute_mrc: ' || 'In Compute MRC ...');
 	PA_IC_INV_UTILS.log_message('compute_mrc: ' || 'Set of books...'||to_char(G_No_of_SOB));
 	PA_IC_INV_UTILS.log_message('compute_mrc: ' || 'Total Record...'||to_char(P_rec_counter));
 END IF;
 FOR I IN 1..P_rec_counter
 LOOP
  IF not( P_mrc_reqd_flag.exists(I))
  THEN
     L_mrc_reqd_flag := 'Y';
  ELSE
     L_mrc_reqd_flag := P_mrc_reqd_flag(I);
  END IF;

  if  (not P_trx_date.exists(I))
  then
       IF g1_debug_mode  = 'Y' THEN
       	PA_IC_INV_UTILS.log_message('compute_mrc: ' || 'Get EI Details....');
       END IF;
       pa_mc_currency_pkg.eiid_details(
                   x_eiid        => P_inv_rec_tab(I).EXPENDITURE_ITEM_ID,
                   x_orig_trx    => orig_ref,
                   x_adj_item    => adj_item,
                   x_linkage     => linkage,
                   x_ei_date     => ei_date,
--Bug#1078399
--New parameter x_txn_source added in eiid_details() - to be used to check whether
--the EI is an imported-one or not.
		   x_txn_source	 => ei_txn_source,
                   x_err_stack   => l_err_stack,
                   x_err_stage   => l_err_stage,
                   x_err_code    => l_err_code );
        IF g1_debug_mode  = 'Y' THEN
        	PA_IC_INV_UTILS.log_message('compute_mrc: ' || 'After Get EI Details....');
        END IF;
  else
        ei_date := P_trx_date(I);
  end if;

  IF g1_debug_mode  = 'Y' THEN
  	PA_IC_INV_UTILS.log_message('compute_mrc: ' || 'In Process of Compute MRC...');
  END IF;
  IF (L_mrc_reqd_flag = 'Y')
  THEN
   FOR J IN 1..G_No_of_SOB
   LOOP

     l_tot_record := l_tot_record + 1;
     K            := K + 1;

     If (P_inv_rec_tab(I).DETAIL_ID_REVERSED IS NOT NULL)
     Then
         IF g1_debug_mode  = 'Y' THEN
         	PA_IC_INV_UTILS.log_message('compute_mrc: ' || 'Detail Id Rev....'||
              to_char(P_inv_rec_tab(I).DETAIL_ID_REVERSED));
         END IF;
         get_orig_exchg_rate (P_inv_rec_tab(I).DETAIL_ID_REVERSED,
                           G_Reporting_SOB(J),l_exchange_rate,
                           l_exchange_date,l_exchange_rate_type,l_bill_amt );
         L_BILL_AMOUNT(K) := l_bill_amt;
     ELSE
         IF g1_debug_mode  = 'Y' THEN
         	PA_IC_INV_UTILS.log_message('compute_mrc: ' || 'Before Get Rate....');
         END IF;

         l_currency := P_inv_rec_tab(I).DENOM_CURRENCY_CODE;
         l_exchange_rate_type := P_inv_rec_tab(I).ACCT_RATE_TYPE;
         l_exchange_date := ei_date;
         l_exchange_rate := P_inv_rec_tab(I).ACCT_EXCHANGE_RATE;

         IF g1_debug_mode  = 'Y' THEN
         	PA_IC_INV_UTILS.log_message('compute_mrc: ' || 'Before Calling.....');
         	PA_IC_INV_UTILS.log_message('compute_mrc: ' || 'Primary Set of Books'||
                                                to_char(l_sob_id));
         	PA_IC_INV_UTILS.log_message('compute_mrc: ' || 'Transaction Date'||
                                                to_char(ei_date, 'YYYY/MM/DD'));
         	PA_IC_INV_UTILS.log_message('compute_mrc: ' || 'Transaction Currency'||
                                                l_currency);
         	PA_IC_INV_UTILS.log_message('compute_mrc: ' || 'Transaction Con Type'||
                                                l_exchange_rate_type);
         	PA_IC_INV_UTILS.log_message('compute_mrc: ' || 'Transaction Con date'||
                                                l_exchange_date);
         	PA_IC_INV_UTILS.log_message('compute_mrc: ' || 'Transaction Con rate'||
                                                l_exchange_rate);
         	PA_IC_INV_UTILS.log_message('compute_mrc: ' || 'Ous ...'||
                                    to_char(PA_MC_INVOICE_DETAIL_PKG.G_ORG_ID));
         	PA_IC_INV_UTILS.log_message('compute_mrc: ' || 'Reporting ...'||
                                    to_char(G_Reporting_SOB(J)));
         END IF;
         gl_mc_currency_pkg.get_rate ( p_primary_set_of_books_id  =>  l_sob_id,
                                       p_reporting_set_of_books_id =>
                                                       G_Reporting_SOB(J),
                                       p_trans_date            =>  ei_date,
                                       p_trans_currency_code   => l_currency,
                                       p_trans_conversion_type =>
                                                  l_exchange_rate_type,
                                       p_trans_conversion_date =>
                                                       l_exchange_date,
                                       p_trans_conversion_rate =>
                                                       l_exchange_rate,
                                       p_application_id    =>  275,
                                       p_org_id =>
                                            PA_MC_INVOICE_DETAIL_PKG.G_ORG_ID,
                                       p_fa_book_type_code =>  NULL,
                                       p_je_source_name    =>  NULL,
                                       p_je_category_name  =>  NULL,
                                       p_result_code       =>  l_result_code,
                                       p_denominator_rate  =>  l_denom,
                                       p_numerator_rate    =>  l_num );

          IF g1_debug_mode  = 'Y' THEN
          	PA_IC_INV_UTILS.log_message('compute_mrc: ' || 'After Get Rate Process');
          	PA_IC_INV_UTILS.log_message('compute_mrc: ' || 'Result Code'|| l_result_code);
          	PA_IC_INV_UTILS.log_message('compute_mrc: ' || 'Exchange Rate....'||
                                                to_char(l_exchange_rate, 'YYYY/MM/DD'));
          	PA_IC_INV_UTILS.log_message('compute_mrc: ' || 'Denominator....'|| to_char(l_denom));
          	PA_IC_INV_UTILS.log_message('compute_mrc: ' || 'Numrator....'|| to_char(l_num));
          	PA_IC_INV_UTILS.log_message('compute_mrc: ' || 'End Printing........');
          END IF;

          PA_IC_INV_UTILS.log_message('Bill Amt in MRC....'||
               to_char((P_inv_rec_tab(I).DENOM_BILL_AMOUNT * l_num)/l_denom));

          L_BILL_AMOUNT(K) := pa_mc_currency_pkg.CurrRound (
                          (P_inv_rec_tab(I).DENOM_BILL_AMOUNT * l_num)/l_denom,
                              G_Reporting_Curr(J));
          IF g1_debug_mode  = 'Y' THEN
          	PA_IC_INV_UTILS.log_message('compute_mrc: ' || 'After Compute...'||
                         to_char(L_BILL_AMOUNT(K)));
          END IF;
     end if;
     IF g1_debug_mode  = 'Y' THEN
     	PA_IC_INV_UTILS.log_message('compute_mrc: ' || 'Before Insert...');
     END IF;
     L_ACCT_EXCHANGE_RATE(K)   := l_exchange_rate;

    /* Release 12: ATG changes :  Change the date form to YYYY/MM/DD */

     L_ACCT_RATE_DATE(K)       := to_char(l_exchange_date,'YYYY/MM/DD');
     L_ACCT_RATE_TYPE(K)       := l_exchange_rate_type;
     L_SETS_OF_BOOKS_ID(K)     := G_Reporting_SOB(J);
     L_ACCT_CURRENCY_CODE(K)   := G_Reporting_Curr(J);
     L_DRAFT_INV_DET_ID(K)
                               := P_inv_rec_tab(I).DRAFT_INVOICE_DETAIL_ID;
     L_PROJECT_ID(K)           := P_inv_rec_tab(I).PROJECT_ID;
     L_INVOICED_FLAG(K)        := P_inv_rec_tab(I).INVOICED_FLAG;
     L_PROG_APP_ID(K)          := P_inv_rec_tab(I).PROGRAM_APPLICATION_ID;
     L_PROG_ID(K)              := P_inv_rec_tab(I).PROGRAM_ID;
     L_PROG_UPDATE_DATE(K)
                 := to_char(P_inv_rec_tab(I).PROGRAM_UPDATE_DATE,'YYYY/MM/DD');
     IF g1_debug_mode  = 'Y' THEN
     	PA_IC_INV_UTILS.log_message('compute_mrc: ' || 'Index '|| to_char(K));
     END IF;
   END LOOP;
  END IF;
 END LOOP;
-- Total Number of records in Array
 P_tot_record := l_tot_record;
 IF g1_debug_mode  = 'Y' THEN
 	PA_IC_INV_UTILS.log_message('compute_mrc: ' || 'Total Record '|| to_char(l_tot_record));
 END IF;

EXCEPTION
 WHEN OTHERS
 THEN
      RAISE;

END compute_mrc;

/* This procedure is called from Intercompany invoice process. This will
   create MRC records for Invoice details */

PROCEDURE Insert_rows
           ( P_inv_rec_tab          IN   PA_INVOICE_DETAIL_PKG.inv_rec_tab)
IS
 l_tot_count   NUMBER;
 l_mrc_reqd_flag  PA_PLSQL_DATATYPES.Char1TabTyp;
 c   number;
 l_trx_date   PA_PLSQL_DATATYPES.DateTabTyp;
BEGIN
 c := 0;
 IF g1_debug_mode  = 'Y' THEN
 	PA_IC_INV_UTILS.log_message('Insert_rows: ' || 'In MRC Insert...');
 END IF;

 /* Compute the MRC amount and populate the global array */
 If ( PA_INVOICE_DETAIL_PKG.G_Ins_count > 0 )
 Then
 compute_mrc(P_inv_rec_tab,l_trx_date,PA_INVOICE_DETAIL_PKG.G_Ins_count,
             l_mrc_reqd_flag,l_tot_count);
 c := 10;
 IF g1_debug_mode  = 'Y' THEN
 	PA_IC_INV_UTILS.log_message('Insert_rows: ' || 'In MRC Insert..'||to_char(l_tot_count));
 END IF;

 /* If MRC records are created, insert in PA_MC_DRAFT_INV_DETAILS */
 if (l_tot_count > 0)
 Then
  IF g1_debug_mode  = 'Y' THEN
  	PA_IC_INV_UTILS.log_message('Insert_rows: ' || 'Before Insert...');
  END IF;
  FOR I IN 1..l_tot_count
  LOOP
  c := 50;
  IF g1_debug_mode  = 'Y' THEN
  	PA_IC_INV_UTILS.log_message('Insert_rows: ' || 'Details Id'||to_char(L_DRAFT_INV_DET_ID(I)));
  END IF;
  c := 11;
  IF g1_debug_mode  = 'Y' THEN
  	PA_IC_INV_UTILS.log_message('Insert_rows: ' || 'Project Id'||to_char(L_PROJECT_ID(I)));
  END IF;
  c := 12;
  IF g1_debug_mode  = 'Y' THEN
  	PA_IC_INV_UTILS.log_message('Insert_rows: ' || 'Invoiced  Flag'||L_INVOICED_FLAG(I));
  END IF;
  c := 13;
  IF g1_debug_mode  = 'Y' THEN
  	PA_IC_INV_UTILS.log_message('Insert_rows: ' || 'Set of Books Id'||to_char(L_SETS_OF_BOOKS_ID(I)));
  END IF;
  c := 14;
  IF g1_debug_mode  = 'Y' THEN
  	PA_IC_INV_UTILS.log_message('Insert_rows: ' || 'Account Currency'||L_ACCT_CURRENCY_CODE(I));
  END IF;
  c := 15;
  IF g1_debug_mode  = 'Y' THEN
  	PA_IC_INV_UTILS.log_message('Insert_rows: ' || 'Bill Amount'||to_char(L_BILL_AMOUNT(I)));
  END IF;
  c := 16;
  IF g1_debug_mode  = 'Y' THEN
  	PA_IC_INV_UTILS.log_message('Insert_rows: ' || 'Request Id'||to_char(PA_IC_INV_UTILS.G_REQUEST_ID));
  END IF;
  c := 17;
  IF g1_debug_mode  = 'Y' THEN
  	PA_IC_INV_UTILS.log_message('Insert_rows: ' || 'Acct Rate Type'||L_ACCT_RATE_TYPE(I));
  END IF;
  c := 18;
  IF g1_debug_mode  = 'Y' THEN
  	PA_IC_INV_UTILS.log_message('Insert_rows: ' || 'Acct Rate Date'||L_ACCT_RATE_DATE(I));
  	PA_IC_INV_UTILS.log_message('Insert_rows: ' || 'Acct Exchg Rate '||L_ACCT_EXCHANGE_RATE(I));
  END IF;
  c := 19;
  END LOOP;

  c := 20;

  /* Array Insert of MRC records */
  FOR  I IN 1..l_tot_count
  LOOP
  /* Added the following if condition to stop inserting into pa_mc_draft_inv_details_all
     table when bill_amount is zero, as we don't insert into pa_draft_invoice_details_all when bill_amount is zero- Bug 2739218  */
     IF L_BILL_AMOUNT(I) <> 0
     THEN
  NULL;
  END IF;
  END LOOP;
/* End of Changes done for bug 2739218 */

  IF g1_debug_mode  = 'Y' THEN
  	PA_IC_INV_UTILS.log_message('Insert_rows: ' || 'End Insert...');
  END IF;
  End if;
 End if;
EXCEPTION
 WHEN OTHERS
 THEN
  IF g1_debug_mode  = 'Y' THEN
  	PA_IC_INV_UTILS.log_message('Insert_rows: ' || 'In MRC Insert Error..'|| to_char(c));
  END IF;
  Raise;

END Insert_rows;

/* This procedure is called from MRC upgrade. In this case, transaction
   date is suuplied as parameter */
PROCEDURE Insert_rows
           ( P_inv_rec_tab          IN   PA_INVOICE_DETAIL_PKG.inv_rec_tab,
             P_trx_date             IN   PA_PLSQL_DATATYPES.DateTabTyp)
IS
 l_tot_count   NUMBER;
 l_mrc_reqd_flag  PA_PLSQL_DATATYPES.Char1TabTyp;
 c   number;
BEGIN
 c := 0;
 IF g1_debug_mode  = 'Y' THEN
 	PA_IC_INV_UTILS.log_message('Insert_rows: ' || 'In MRC Insert...');
 END IF;
 /* Compute the MRC amount and populate the global array */
 If ( PA_INVOICE_DETAIL_PKG.G_Ins_count > 0 )
 Then
 compute_mrc(P_inv_rec_tab,P_trx_date,PA_INVOICE_DETAIL_PKG.G_Ins_count,
             l_mrc_reqd_flag,l_tot_count);
 c := 10;
 IF g1_debug_mode  = 'Y' THEN
 	PA_IC_INV_UTILS.log_message('Insert_rows: ' || 'In MRC Insert..'||to_char(l_tot_count));
 END IF;
 /* If MRC records are created, insert in PA_MC_DRAFT_INV_DETAILS */
 if (l_tot_count > 0)
 Then
  IF g1_debug_mode  = 'Y' THEN
  	PA_IC_INV_UTILS.log_message('Insert_rows: ' || 'Before Insert...');
  END IF;
  FOR I IN 1..l_tot_count
  LOOP
  c := 50;

  IF g1_debug_mode  = 'Y' THEN
  	PA_IC_INV_UTILS.log_message('Insert_rows: ' || 'Details Id'||to_char(L_DRAFT_INV_DET_ID(I)));
  END IF;
  c := 11;
  IF g1_debug_mode  = 'Y' THEN
  	PA_IC_INV_UTILS.log_message('Insert_rows: ' || 'Project Id'||to_char(L_PROJECT_ID(I)));
  END IF;
  c := 12;
  IF g1_debug_mode  = 'Y' THEN
  	PA_IC_INV_UTILS.log_message('Insert_rows: ' || 'Invoiced  Flag'||L_INVOICED_FLAG(I));
  END IF;
  c := 13;
  IF g1_debug_mode  = 'Y' THEN
  	PA_IC_INV_UTILS.log_message('Insert_rows: ' || 'Set of Books Id'||to_char(L_SETS_OF_BOOKS_ID(I)));
  END IF;
  c := 14;
  IF g1_debug_mode  = 'Y' THEN
  	PA_IC_INV_UTILS.log_message('Insert_rows: ' || 'Account Currency'||L_ACCT_CURRENCY_CODE(I));
  END IF;
  c := 15;
  IF g1_debug_mode  = 'Y' THEN
  	PA_IC_INV_UTILS.log_message('Insert_rows: ' || 'Bill Amount'||to_char(L_BILL_AMOUNT(I)));
  END IF;
  c := 16;
  IF g1_debug_mode  = 'Y' THEN
  	PA_IC_INV_UTILS.log_message('Insert_rows: ' || 'Request Id'||to_char(PA_IC_INV_UTILS.G_REQUEST_ID));
  END IF;
  c := 17;
  IF g1_debug_mode  = 'Y' THEN
  	PA_IC_INV_UTILS.log_message('Insert_rows: ' || 'Acct Rate Type'||L_ACCT_RATE_TYPE(I));
  END IF;
  c := 18;
  IF g1_debug_mode  = 'Y' THEN
  	PA_IC_INV_UTILS.log_message('Insert_rows: ' || 'Acct Rate Date'||L_ACCT_RATE_DATE(I));
  	PA_IC_INV_UTILS.log_message('Insert_rows: ' || 'Acct Exchg Rate '||L_ACCT_EXCHANGE_RATE(I));
  END IF;
  c := 19;
  END LOOP;

  c := 20;
  /* Array Insert of MRC records */
  IF g1_debug_mode  = 'Y' THEN
  	PA_IC_INV_UTILS.log_message('Insert_rows: ' || 'End Insert...');
  END IF;
  End if;
 End if;
EXCEPTION
 WHEN OTHERS
 THEN
  IF g1_debug_mode  = 'Y' THEN
  	PA_IC_INV_UTILS.log_message('Insert_rows: ' || 'In MRC Insert Error..'|| to_char(c));
  END IF;
  Raise;

END Insert_rows;

PROCEDURE Update_rows
           ( P_inv_rec_tab            IN PA_INVOICE_DETAIL_PKG.inv_rec_tab,
             P_mrc_reqd_flag          IN PA_PLSQL_DATATYPES.Char1TabTyp)
IS
 l_tot_count  NUMBER;
 l_trx_date   PA_PLSQL_DATATYPES.DateTabTyp;
BEGIN

 IF g1_debug_mode  = 'Y' THEN
 	PA_IC_INV_UTILS.log_message('Update_rows: ' || 'In MRC Update...');
 END IF;
 If ( PA_INVOICE_DETAIL_PKG.G_Upd_count > 0)
 Then
   compute_mrc(P_inv_rec_tab,l_trx_date,PA_INVOICE_DETAIL_PKG.G_Upd_count,
               P_mrc_reqd_flag,l_tot_count);


 End if;

EXCEPTION
 WHEN OTHERS
 THEN
    Raise;

END Update_rows;

PROCEDURE Delete_rows
           ( P_inv_rec_tab             IN   PA_INVOICE_DETAIL_PKG.inv_rec_tab)
IS
 l_draft_line_id     PA_PLSQL_DATATYPES.numtabtyp;
BEGIN

 IF g1_debug_mode  = 'Y' THEN
 	PA_IC_INV_UTILS.log_message('Delete_rows: ' || 'In MRC Delete...');
 END IF;
 If ( PA_INVOICE_DETAIL_PKG.G_Del_count > 0)
 Then
  download(P_inv_rec_tab,PA_INVOICE_DETAIL_PKG.G_Del_count,l_draft_line_id);


 End if;

EXCEPTION
 WHEN OTHERS
 THEN
    Raise;

END Delete_rows;

END PA_MC_INVOICE_DETAIL_PKG;

/
