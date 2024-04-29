--------------------------------------------------------
--  DDL for Package Body PAAP_PWP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAAP_PWP_PKG" AS
-- /* $Header: PAAPPWPB.pls 120.3.12010000.33 2010/03/29 10:14:04 abjacob noship $

  ProjFunc_Curr_Amount Number;
  Proj_Curr_Amount     Number;
  P_Trans_Amount       Number;

  P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

  ---------------------------------------------------------------------------------------------------------
    -- This Function returns Project Functional Currency Code
  ----------------------------------------------------------------------------------------------------------
  Function Get_ProjFunc_Curr Return VARCHAR2;

  ---------------------------------------------------------------------------------------------------------
    -- This Function returns Exchange Rate Date for Project Functional Currency
  ----------------------------------------------------------------------------------------------------------
  Function Get_ProjFunc_RateDate Return DATE;

  ---------------------------------------------------------------------------------------------------------
    -- This Function returns Exchange Rate Type for Project Functional Currency
  ----------------------------------------------------------------------------------------------------------
  Function Get_ProjFunc_RateType Return VARCHAR2;

  ---------------------------------------------------------------------------------------------------------
    -- This Function returns Project Currency Code
  ----------------------------------------------------------------------------------------------------------
  Function Get_ProjFunc_Rate Return NUMBER;

  ---------------------------------------------------------------------------------------------------------
    -- This Function returns Amount in Project Functional Currency
  ----------------------------------------------------------------------------------------------------------
  Function Get_ProjFunc_Amt Return NUMBER;

  ---------------------------------------------------------------------------------------------------------
    -- This Function returns Project Currency Code
  ----------------------------------------------------------------------------------------------------------
  Function Get_Proj_Curr Return VARCHAR2;

  ---------------------------------------------------------------------------------------------------------
    -- This Function returns Exchange Rate Date for Project Currency
  ----------------------------------------------------------------------------------------------------------
  Function Get_Proj_RateDate Return DATE;

  ---------------------------------------------------------------------------------------------------------
    -- This Function returns Exchange Rate Type for Project Code
  ----------------------------------------------------------------------------------------------------------
  Function Get_Proj_RateType Return VARCHAR2;

  ---------------------------------------------------------------------------------------------------------
    -- This Function returns Exchange Rate for Project Currency
  ----------------------------------------------------------------------------------------------------------
  Function Get_Proj_Rate Return NUMBER;

  ---------------------------------------------------------------------------------------------------------
    -- This Function returns Amount in Project Currency
  ----------------------------------------------------------------------------------------------------------
  Function Get_Proj_Amt Return NUMBER;

  ---------------------------------------------------------------------------------------------------------
    -- This procedure prints the text which is being passed as the input
    -- Input parameters
    -- Parameters                Type            Required      Description
    --  p_log_msg                VARCHAR2        YES           It stores text which you want
    --                                                         to print on screen
    -- Out parameters
  ----------------------------------------------------------------------------------------------------------
  PROCEDURE log_message (p_log_msg IN VARCHAR2,p_proc_name VARCHAR2)
  IS
  BEGIN
      pa_debug.write('log_message: ' || p_proc_name, 'log: ' || p_log_msg, 3);
  END log_message;

  Function Get_ProjFunc_curr Return Varchar2 Is
  BEGIN
   Return ProjFunc_Currency;
  END;

  Function Get_ProjFunc_rateDate Return Date  Is
  BEGIN
   Return ProjFunc_Cst_Rate_Date;
  END;

  Function Get_ProjFunc_ratetype Return Varchar2 Is
  BEGIN
   Return ProjFunc_Cst_Rate_Type;
  END;

  Function Get_ProjFunc_rate Return Number Is
  BEGIN
   Return ProjFunc_CST_RATE;
  END;

  Function Get_ProjFunc_amt Return Number Is
  BEGIN
   Return ProjFunc_Curr_Amount;
  END;

  Function Get_Proj_curr Return Varchar2 Is
  BEGIN
   Return Proj_Currency;
  END;

  Function Get_Proj_rateDate Return Date Is
  BEGIN
   Return Proj_Cst_Rate_Date;
  END;

  Function Get_Proj_ratetype Return Varchar2 Is
  BEGIN
   Return Proj_Cst_Rate_Type;
  END;

  Function Get_Proj_rate Return Number Is
  BEGIN
   Return Proj_CST_RATE;
  END;

  Function Get_Proj_amt Return Number Is
  BEGIN
   Return Proj_Curr_Amount;
  END;

  ---------------------------------------------------------------------------------------------------------
    -- This Procedure derives the all the conversion attributes from any currency passed as a parameter to
    -- Project Functional/Project/Acct Currencies. This procedure caches all the Currency /Exchange Rate/
    -- Exchange Rate Date/Exchange Rate Type values in global variables.
    -- Input parameters
    -- Parameters                Type           Required     Description
    --  p_project_id             NUMBER         YES          It stores the project_id
    --  p_task_id                NUMBER         YES          It stores the task_Id
    --  p_ei_date                DATE           YES          It stores the expenditure item date
    --  p_from_currency          VARCHAR2       NO           From Currency
    -- Out parameters
  ----------------------------------------------------------------------------------------------------------
  Procedure Derive_ProjCurr_Attribute(P_Project_Id   IN Number,
                                      P_Task_Id      IN Number,
                                      P_Exp_Item_Date IN Date,
                                      P_FromCurrency IN Varchar2) Is
   l_denom_raw_cost    Number;
   l_denom_curr_code   Varchar2(30);
   l_acct_curr_code    Varchar2(30);

   l_acct_rate_Date    Date;
   l_acct_rate_type    Varchar2(30);
   l_acct_exch_rate    Number;
   l_acct_raw_cost     Number;

   l_project_rate_type Varchar2(30);
   l_project_rate_Date Date;
   l_project_exch_rate Number;
   l_project_raw_cost  Number;

   l_ProjFunc_cost_rate_type Varchar2(30);
   l_ProjFunc_cost_rate_Date Date;
   l_ProjFunc_cost_exch_rate Number;
   l_ProjFunc_raw_cost       Number;

   l_status            Varchar2(2000);
   l_stage             Number;

  BEGIN
    IF P_DEBUG_MODE = 'Y' THEN
     log_message('[PA_CURR_CODE : '||PA_CURR_CODE||' ]'||'[P_project_id : '||p_project_id||' ]'
                 ||' [P_Task_Id : '||P_Task_Id||'] '||'[P_Exp_Item_Date : '||P_Exp_Item_Date||']',
                 'Derive_ProjCurr_Attribute');
    END IF;

     If PA_CURR_CODE IS NULL Then
         PA_CURR_CODE := PA_Currency.get_Currency_code;

       IF P_DEBUG_MODE = 'Y' THEN
         log_message('From PA_Currency.get_Currency_code [PA_CURR_CODE : '||PA_CURR_CODE||' ]' ,
                 'Derive_ProjCurr_Attribute');
       END IF;
     END If;

     IF P_DEBUG_MODE = 'Y' THEN
      log_message('Before Calling pa_multi_Currency_txn.Get_Proj_curr_code_sql '||
                 '[G_project_id : '||G_Project_Id||' ]',
                 'Derive_ProjCurr_Attribute');
     END IF;

     If NVL(G_Project_Id, -99) <> P_Project_ID Then
            Proj_Currency := pa_multi_Currency_txn.Get_Proj_curr_code_sql(p_project_id);
            G_Project_Id := P_Project_Id;
     END If;

     IF P_DEBUG_MODE = 'Y' THEN
        log_message('After Calling pa_multi_Currency_txn.Get_Proj_curr_code_sql '||
                 '[G_project_id : '||G_Project_Id||']'||
                 '[Proj_Currency : '||Proj_Currency||']' ,
                 'Derive_ProjCurr_Attribute');
     END IF;

     IF P_DEBUG_MODE = 'Y' THEN
       log_message('Before Calling pa_multi_Currency_txn.get_def_ProjFunc_Cst_Rate_Type '||
                 '[G_Task_Id : '||G_Task_Id||']',
                 'Derive_ProjCurr_Attribute');
     END IF;

     If NVL(G_Task_Id,-99) <> P_Task_Id Then
            pa_multi_Currency_txn.get_def_ProjFunc_Cst_Rate_Type(
            P_task_id ,
            ProjFunc_Currency,
            ProjFunc_Cst_Rate_Type);
     END If;

     IF P_DEBUG_MODE = 'Y' THEN
       log_message('After Calling pa_multi_Currency_txn.get_def_ProjFunc_Cst_Rate_Type '||
                 '[ProjFunc_Currency : '||ProjFunc_Currency||']'||' [ProjFunc_Cst_Rate_Type : '||
                  ProjFunc_Cst_Rate_Type||'] ',
                 'Derive_ProjCurr_Attribute');
     END IF;

     If NVL(G_Expenditure_Item_Date,SYSDate) <> P_Exp_Item_Date
        OR NVL(G_Task_Id,-99) <> P_Task_Id
        OR NVL(G_From_Curr,'XXXX') <> P_FromCurrency Then /* Added G_From_Curr for Bug# 7830751 */

     IF P_DEBUG_MODE = 'Y' THEN
        log_message('Before Calling pa_multi_Currency_txn.get_Currency_amounts',
                 'Derive_ProjCurr_Attribute');
     END IF;

     /* Bug# Added this for the bug 8849692 */
     /* Bug#8897745 */
     IF ACCT_CST_RATE IS NOT NULL  THEN
        l_acct_rate_Date:= ACCT_Cst_Rate_Date;
        l_acct_rate_type:= ACCT_Cst_Rate_Type;
        l_acct_exch_rate:= ACCT_CST_RATE;
     END IF;
            pa_multi_Currency_txn.get_Currency_amounts (
	          P_project_id            =>p_Project_Id,
                  P_task_id           =>P_task_id,
                  P_EI_Date           =>P_Exp_Item_Date,
	              P_calling_module    =>'GET_CURR_AMOUNTS',
                  P_denom_curr_code   =>p_fromCurrency,
                  P_acct_curr_code    =>PA_CURR_CODE,
                  P_accounted_flag    =>'Y',
                  P_acct_rate_Date    =>l_acct_rate_Date,
                  P_acct_rate_type    =>l_acct_rate_type,
                  P_acct_exch_rate    =>l_acct_exch_rate,
                  P_project_curr_code =>Proj_Currency,
                  P_project_rate_type =>l_project_rate_type,
                  P_project_rate_Date =>l_project_rate_Date,
                  P_project_exch_rate =>l_project_exch_rate,
                  P_ProjFunc_curr_code =>ProjFunc_Currency,
                  P_ProjFunc_cost_rate_type =>l_ProjFunc_cost_rate_type,
                  P_ProjFunc_cost_rate_Date =>l_ProjFunc_cost_rate_Date,
                  P_ProjFunc_cost_exch_rate =>l_ProjFunc_cost_exch_rate,
                  P_denom_raw_cost    => l_denom_raw_cost,
                  P_acct_raw_cost     => l_acct_raw_cost,
                  P_project_raw_cost  => l_project_raw_cost,
                  P_ProjFunc_raw_cost => l_ProjFunc_raw_cost,
                  P_system_linkage    => 'VI',
                  P_status            =>l_status,
                  P_stage             =>l_stage);

           IF l_status IS NULL THEN /* Bug#8897745 */
            ProjFunc_Cst_Rate_Date   :=l_ProjFunc_cost_rate_Date;
            ProjFunc_Cst_Rate_Type   :=l_ProjFunc_cost_rate_type;
            ProjFunc_CST_RATE        :=nvl(l_ProjFunc_cost_exch_rate,1);

            Proj_Cst_Rate_Date       :=l_project_rate_Date;
            Proj_Cst_Rate_Type       :=l_project_rate_type;
            Proj_CST_RATE            :=nvl(l_project_exch_rate,1);

             /* Bug# Added this for bug# 8849692 */
              IF nvl(ACCT_Cst_Rate_Type,'XXX') <> 'User' THEN
                ACCT_Cst_Rate_Date       :=l_acct_rate_Date;
                ACCT_Cst_Rate_Type       :=l_acct_rate_type;
                ACCT_CST_RATE            :=nvl(l_acct_exch_rate,1);
              END IF;
            END IF;

            G_Expenditure_Item_Date := P_Exp_Item_Date;
            G_Task_Id := P_Task_Id;
            G_From_Curr := P_FromCurrency; /* For Bug# 7830751 */

      IF P_DEBUG_MODE = 'Y' THEN
       log_message('After Calling pa_multi_Currency_txn.get_Currency_amounts '||
                 '[G_Expenditure_Item_Date : '||G_Expenditure_Item_Date||']'||' [ProjFunc_Cst_Rate_Date : '||
                  ProjFunc_Cst_Rate_Date||'] '||' [ProjFunc_Cst_Rate_Type : '||
                  ProjFunc_Cst_Rate_Type||'] '||' [ProjFunc_CST_RATE : '||
                  ProjFunc_CST_RATE||'] '||' [Proj_Cst_Rate_Date : '||
                  Proj_Cst_Rate_Date||'] '||' [Proj_Cst_Rate_Type : '||
                  Proj_Cst_Rate_Type||'] '||' [Proj_CST_RATE : '||
                  Proj_CST_RATE||'] '||' [ACCT_Cst_Rate_Date : '||
                  ACCT_Cst_Rate_Date||'] '||' [ACCT_Cst_Rate_Type : '||
                  ACCT_Cst_Rate_Type||'] '||' [ACCT_CST_RATE : '||
                  ACCT_CST_RATE||'] '||' l_status :'||
                  l_status,
                 'Derive_ProjCurr_Attribute');
      END IF;

     END If;
  EXCEPTION
     WHEN OTHERS THEN
         IF P_DEBUG_MODE = 'Y' THEN
           log_message('In When Others Exception : '||SQLERRM,'Derive_ProjCurr_Attribute');
         END IF;
         RAISE;
  END Derive_ProjCurr_Attribute;

  ---------------------------------------------------------------------------------------------------------
    -- This function derives the all the conversion attributes from any currency passed as a parameter to
    -- Project Functional/Project/Acct Currencies. This function returns any of the Currency /Exchange Rate/
    -- Exchange Rate Date/Exchange Rate Type/Amount values based on the parameter p_ret_atr value.
    -- Input parameters
    -- Parameters                Type          Required  Description
    --  p_project_id             NUMBER        YES        It stores the project_id
    --  p_task_id                NUMBER        YES        It stores the task_Id
    --  p_ei_date                DATE          YES        It stores the expenditure item date
    --  p_from_currency          VARCHAR2      NO         If not passed, this will be same as the Functional
    --                                                    Currency
    --  p_ret_atr                VARCHAR2      NO         Default value is 'ProjFunc_Rate'
    --                                                         Valid Values are:
    --                                                                    ProjFunc_Rate
    --                                                                    ProjFunc_Rate_Type
    --                                                                    ProjFunc_Rate_Date
    --                                                                    ProjFunc_Amt
    --                                                                    Proj_Rate
    --                                                                    Proj_Rate_Type
    --                                                                    Proj_Rate_Date
    --                                                                    Proj_Amt
    --                                                                    Proj_Curr
    --                                                                    ProjFunc_Curr
    --  p_amt                    NUMBER        NO         Amount to be converted
    -- Out parameters
  ----------------------------------------------------------------------------------------------------------
  Function Get_Proj_Curr_Amt (
                               P_Project_Id      IN Number,
                               P_Task_Id         IN Number,
                               P_EI_Date         IN Date := SYSDATE,
                               P_FromCurrency    IN Varchar2 :='',
                               P_RET_ATR         IN Varchar2 :='ProjFunc_Rate',
                               P_Amt             IN Number :=0
                             ) Return Varchar2 Is
  BEGIN

      IF P_DEBUG_MODE = 'Y' THEN
        log_message('Before Calling Derive_ProjCurr_Attribute '||
                 '[P_Project_Id : '||P_Project_Id||'] '||'[P_Task_Id : '||P_Task_Id||'] '
                  ||'[P_EI_Date : '||P_EI_Date||'] '||'[P_FromCurrency : '||P_FromCurrency||'] '
                  ||'[P_RET_ATR : '||P_RET_ATR||'] '||'[P_Amt : '||P_Amt||'] ',
                 'Get_Proj_Curr_Amt');
      END IF;

             Derive_ProjCurr_Attribute(P_Project_Id ,
                                       P_Task_Id    ,
                                       P_EI_Date,
                                       P_FromCurrency);
             P_Trans_Amount := P_Amt;
             ProjFunc_Curr_Amount := P_Trans_Amount * ProjFunc_Cst_Rate;
             Proj_Curr_Amount := P_Trans_Amount * Proj_Cst_Rate;

             If P_RET_ATR = 'ProjFunc_Rate' Then
                Return Get_ProjFunc_Rate;
             END If;

             If P_RET_ATR = 'ProjFunc_Rate_Type' Then
                Return get_ProjFunc_ratetype;
             END If;

             If P_RET_ATR = 'ProjFunc_Rate_Date' Then
                Return get_ProjFunc_rateDate;
             END If;

             If P_RET_ATR = 'ProjFunc_Amt' Then
                Return get_ProjFunc_amt;
             END If;

             If P_RET_ATR = 'Proj_Rate' Then
                Return Get_Proj_Rate;
             END If;

             If P_RET_ATR = 'Proj_Rate_Type' Then
                Return get_Proj_ratetype;
             END If;

             If P_RET_ATR = 'Proj_Rate_Date' Then
                Return get_Proj_rateDate;
             END If;

             If P_RET_ATR = 'Proj_Amt' Then
                Return get_Proj_amt;
             END If;

             If P_RET_ATR = 'Proj_Curr' Then
                Return Get_Proj_curr;
             END If;

             If P_RET_ATR = 'ProjFunc_Curr' Then
                Return Get_ProjFunc_curr;
             END If;
  EXCEPTION
    WHEN OTHERS THEN
      IF P_DEBUG_MODE = 'Y' THEN
        log_message('In When Others Exception :'||SQLERRM,
                 'Get_Proj_Curr_Amt');
      END IF;
	  return 0;
  END Get_Proj_Curr_Amt;


  Procedure init_global Is
  BEGIN

    NULL;

  END;

  ---------------------------------------------------------------------------------------------------------
    -- This procedure releases PWP Hold, DLV Hold for the supplier invoices passed as a pl/sql table
    -- Input parameters
    -- Parameters                Type           Required  Description
    --  P_Inv_Tbl                PL/SQL Tbl     YES       It stores a list of invoice_id's for which the
    --                                                    PWP/DLV Hold needs to be released.
    -- Out parameters
    -- Parameters                Type           Required  Description
    --  X_return_status          VARCHAR2       YES       The return status of the APIs.
    --                                                     Valid values are:
    --                                                       S (API completed successfully),
    --                                                       E (business rule violation error) and
    --                                                       U(Unexpected error, such as an Oracle error.
    --  X_msg_count              NUMBER         YES       Holds the number of messages in the global message
    --                                                    table. Calling programs should use this as the
    --                                                    basis to fetch all the stored messages.
    --  x_msg_data               VARCHAR2       YES       Holds the message code, if the API returned only
    --                                                    one error/warning message Otherwise the column is
    --                                                    left blank.
  ----------------------------------------------------------------------------------------------------------
  Procedure paap_release_hold (P_Inv_Tbl          IN InvoiceId
                              ,p_rel_option   IN VARCHAR2 := 'REL_ALL_HOLD'
                              ,X_return_status   OUT NOCOPY VARCHAR2
                              ,X_msg_count       OUT NOCOPY NUMBER
                              ,X_msg_data        OUT NOCOPY VARCHAR2) IS

     l_line_location_id    Number(15);
     l_rcv_transaction_id  Number;
     l_hold_lookup_code    Varchar2(25);
     l_should_have_hold    Varchar2(1):='N';
     l_hold_reason         Varchar2(240):='Project Manager Release';
     l_calling_sequence    Varchar2(240);

     -- Cursor c1 is to fetch hold lookup code
     -- for the invoice being passed if any of the PWP or DLV hold exists.
     Cursor c1(p_invoice_id Number) Is
       select hold_lookup_code from ap_holds_all
       where invoice_id= p_invoice_id
       and hold_lookup_code in ('Pay When Paid','PO Deliverable','Project Hold') --bug 9525493
       and release_reason IS NULL
 and hold_lookup_code not in (select decode(FND_PROFILE.value('PA_PAY_WHEN_PAID'),'N','Pay When Paid','Y','#######','Pay When Paid') from dual);

	        Cursor c12(p_invoice_id Number, p_hold_type VARCHAR2) Is
       select hold_lookup_code from ap_holds_all
       where invoice_id= p_invoice_id
       and hold_lookup_code in ('Pay When Paid','PO Deliverable','Project Hold') --bug 9525493
       and release_reason IS NULL
	   and hold_lookup_code = decode(p_hold_type,
									 'REL_PWP_HOLD','Pay When Paid',
									 'REL_DEL_HOLD','PO Deliverable',
									 'REL_PROJ_HOLD','Project Hold', --bug 9525493
									 null)
									 ;

	 l_err_msg            Varchar2(4000);

    -- To get the hold reason if any for an Invoice.
    Cursor C3(P_Invoice_Id Number) Is
    Select hold_lookup_code, hold_reason, 'PWP/DLV' HoldType From ap_holds_all
       Where invoice_id= P_Invoice_Id
       And hold_lookup_code In ('Pay When Paid','PO Deliverable')
       and RELEASE_REASON is null
	UNION ALL
    Select hold_lookup_code, hold_reason, 'OTH' HoldType From ap_holds_all
       Where invoice_id= P_Invoice_Id
       And hold_lookup_code Not In ('Pay When Paid','PO Deliverable')
       and RELEASE_REASON is null;

	l_inv_pwp_hold                            Varchar2(1):='N';
	l_inv_dlv_hold                            Varchar2(1):='N';
	l_inv_hold                                Varchar2(1):='N';
    l_hold_reason1                             Varchar2(4000);
    l_hold_applied_yn                         varchar2(1):= 'N';
  BEGIN
   x_return_status := 'S';
   X_msg_count :=0;

   IF P_DEBUG_MODE = 'Y' THEN
        log_message('Begin: paap_release_hold ', 'paap_release_hold');
   END IF;

   IF p_inv_tbl.count > 0 THEN

     FOR Inv_RelHOld_rec in 1..p_inv_tbl.count LOOP
	   --anuragag
	   if(p_rel_option = 'REL_ALL_HOLD') then
       FOR HoldRec in  c1(p_inv_tbl(Inv_RelHOld_rec)) LOOP
	    BEGIN
         IF P_DEBUG_MODE = 'Y' THEN
            log_message('Before calling AP_HOLDS_PKG.release_single_hold API '
                        ||'[Invoice_Id : '||p_inv_tbl(Inv_RelHOld_rec)||'] '
                        ||'[hold_lookup_code: '||HoldRec.hold_lookup_code||'] '
                        ||'[l_hold_reason: '||l_hold_reason||'] ', 'paap_release_hold');
         END IF;

         AP_HOLDS_PKG.release_single_hold
               (X_invoice_id => p_inv_tbl(Inv_RelHOld_rec),
                X_hold_lookup_code=> HoldRec.hold_lookup_code,
                X_release_lookup_code =>l_hold_reason); /*Removed the parameter Held_By for bug 8916025 */

		EXCEPTION
		  WHEN OTHERS THEN
            l_err_msg:= SQLERRM;

            IF P_DEBUG_MODE = 'Y' THEN
             log_message('In When Others Exception FORLOOP '||SQLERRM, 'paap_release_hold');
            END IF;

		    Update PA_PWP_AP_INV_HDR Set RELHOLD_REJ_REASON = SubStr(l_err_msg,1,2000)
		    Where  invoice_id = p_inv_tbl(Inv_RelHOld_rec);

            x_msg_count := 1;
            x_return_status :='E';
            x_msg_data := SQLERRM;
		END;
      END LOOP;
	  else
	  FOR HoldRec in  c12(p_inv_tbl(Inv_RelHOld_rec),p_rel_option) LOOP
	    BEGIN
         IF P_DEBUG_MODE = 'Y' THEN
            log_message('Before calling AP_HOLDS_PKG.release_single_hold API '
                        ||'[Invoice_Id : '||p_inv_tbl(Inv_RelHOld_rec)||'] '
                        ||'[hold_lookup_code: '||HoldRec.hold_lookup_code||'] '
                        ||'[l_hold_reason: '||l_hold_reason||'] ', 'paap_release_hold');
         END IF;

         AP_HOLDS_PKG.release_single_hold
               (X_invoice_id => p_inv_tbl(Inv_RelHOld_rec),
                X_hold_lookup_code=> HoldRec.hold_lookup_code,
                X_release_lookup_code =>l_hold_reason); /*Removed the parameter Held_By for bug 8916025 */

		EXCEPTION
		  WHEN OTHERS THEN
            l_err_msg:= SQLERRM;

            IF P_DEBUG_MODE = 'Y' THEN
             log_message('In When Others Exception FORLOOP '||SQLERRM, 'paap_release_hold');
            END IF;

		    Update PA_PWP_AP_INV_HDR Set RELHOLD_REJ_REASON = SubStr(l_err_msg,1,2000)
		    Where  invoice_id = p_inv_tbl(Inv_RelHOld_rec);

            x_msg_count := 1;
            x_return_status :='E';
            x_msg_data := SQLERRM;
		END;
      END LOOP;
	  end if;

      l_inv_pwp_hold   :='N';
	  l_inv_dlv_hold   :='N';
	  l_inv_hold       :='N';
      l_hold_reason1    :='';
      l_hold_applied_yn := 'N';

      FOR INVREC_HOLD IN C3(p_inv_tbl(Inv_RelHOld_rec))
		  LOOP
		     IF l_hold_reason1 IS NULL THEN
                l_hold_reason1 := INVREC_HOLD.hold_reason||'.';
             ELSE
                l_hold_reason1 := l_hold_reason1||'<br>'||INVREC_HOLD.hold_reason||'.';
             END IF;
             l_inv_hold := 'Y';
			 If INVREC_HOLD.hold_lookup_code = 'Pay When Paid' Then
			    l_inv_pwp_hold := 'Y';
			 ElsIf INVREC_HOLD.hold_lookup_code = 'PO Deliverable' Then
			    l_inv_dlv_hold := 'Y';
             ElsIf INVREC_HOLD.hold_lookup_code = 'Project Hold' Then --bug 9525493
                l_hold_applied_yn := 'Y';
			 End If;
      END LOOP;
      IF P_DEBUG_MODE = 'Y' THEN
          log_message('Setting hold reason to null for Invoice_Id:'
                      ||'[Invoice_Id : '||p_inv_tbl(Inv_RelHOld_rec)||' ]', 'paap_release_hold');
      END IF;

       Update PA_PWP_AP_INV_HDR Set HOLD_REASON = l_hold_reason1,
                                    PWP_HOLD_FLAG = l_inv_pwp_hold,
                                    DLV_HOLD_FLAG = l_inv_dlv_hold,
                                    HOLD_FLAG = l_inv_hold,
                                    HOLD_APPLIED_YN = l_hold_applied_yn
	   Where  Invoice_Id = p_inv_tbl(Inv_RelHOld_rec)
	   And    RELHOLD_REJ_REASON Is Null;

     END LOOP;

    END IF;
    COMMIT;

    IF P_DEBUG_MODE = 'Y' THEN
        log_message('[x_return_status : '||x_return_status||' ]', 'paap_release_hold');
    END IF;

    IF x_return_status = 'S' THEN
       X_msg_data := 'PA_INV_HOLD_RELEASE';
    END IF;

 EXCEPTION
    WHEN OTHERS THEN
      IF P_DEBUG_MODE = 'Y' THEN
        log_message('In When Others Exception :'||SQLERRM, 'paap_release_hold');
      END IF;

       x_msg_count:=1;
       x_return_status := 'U';
       X_msg_data:=SQLERRM;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END paap_release_hold;

  /*---------------------------------------------------------------------------------------------------------
    -- This procedure populates pa_pwp_ap_inv_hdr, pa_pwp_ap_inv_dtl tables by processing all the supplier
    -- invoices pertaining to the project_id being passed. Returns Success/Failure to the calling module.
    -- Input parameters
    -- Parameters                Type           Required  Description
    --  p_project_id             NUMBER         YES       It stores the project_id
    -- Out parameters
    -- Parameters                Type           Required  Description
    --  X_return_status          VARCHAR2       YES       The return status of the APIs.
                                                          Valid values are:
                                                          S (API completed successfully),
                                                          E (business rule violation error) and
                                                          U(Unexpected error, such as an Oracle error.
    --  X_msg_count              NUMBER         YES       Holds the number of messages in the global message
                                                          table. Calling programs should use this as the
                                                          basis to fetch all the stored messages.
    --  x_msg_data               VARCHAR2       YES       Holds the message code, if the API returned only
                                                          one error/warning message Otherwise the column is
                                                          left blank.
  ----------------------------------------------------------------------------------------------------------*/
  Procedure Process_SuppInv_Dtls1 (P_Project_Id    IN         Number
                                  ,X_return_status OUT NOCOPY VARCHAR2
                                  ,X_msg_count     OUT NOCOPY NUMBER
                                  ,X_msg_data      OUT NOCOPY VARCHAR2) IS

     -- Cursor C1 is to Fetch Supplier wise Invoice details at Invoice Header Level for a project.
     -- We pickup the payment details from ap_payment_schedules_all and vendor information from
     -- po_vendors.

     /****
      Modified below cursor for Bug# 7833675:
      Removed the discount calculation from here.
      ****/
     Cursor c1 Is
     select apinv.invoice_id                               Invoice_Id,
            apinv.invoice_num                              invoice_num,
            vend.vendor_id                                 vendor_Id,
            vend.vendor_name                               Supplier_name,
			vend.segment1                                  Supplier_Num,
            apinv.Invoice_Date                             Invoice_Date,
            P_project_id                                   Project_Id,
            apinv.invoice_Currency_code                    invoice_Currency,
            apinv.payment_Currency_code                    Payment_Currency,
            appay.payment_cross_rate                       Exchange_Rate, /* Bug# 8785535*/
            (select vendor_site_code from
                    po_vendor_sites_all
             where  vendor_id = apinv.vendor_id
             and vendor_site_id = apinv.vendor_site_id)    Supplier_Site,
             Invoice_Amount,
            decode(apinv.payment_Currency_code, apinv.invoice_Currency_code,
                   sum(amount_remaining),
	               sum(amount_remaining)/nvl(appay.payment_cross_rate,1)) UnPaid_Inv_Amt, /* Bug# 8785535*/
            (decode(apinv.payment_Currency_code,
 	                apinv.invoice_Currency_code,
                    sum(gross_amount),
	                sum(gross_amount)/nvl(appay.payment_cross_rate,1)) - /* Bug# 8785535*/
             decode(apinv.payment_Currency_code,
                    apinv.invoice_Currency_code,
                    sum(amount_remaining),
                    sum(amount_remaining)/nvl(appay.payment_cross_rate,1))) Paid_Inv_Amt, /* Bug# 8785535*/
                    apinv.invoice_Type_Lookup_code  invoice_type, /*Added for bug 8293625 */
                    apinv.cancelled_date  Cancelled_Date /*Added for bug 8293625 */
     from   ap_invoices_all apinv,
            ap_payment_schedules_all appay,
            po_vendors vend
     where  exIsts (select 1 from
                           ap_invoice_dIstributions_all apd
                    where  apd.project_id = P_project_Id
                    and    apd.posted_flag ='Y'
                    and    apinv.invoice_id = apd.invoice_id)
     and    appay.invoice_id(+)=apinv.invoice_id
     and    vend.vendor_id = apinv.vendor_id
     --and    apinv.invoice_amount !=0 -- Bug# 7713608
     and    apinv.invoice_type_lookup_code <> 'EXPENSE REPORT'
     and    apinv.invoice_id = NVL(G_Invoice_Id,apinv.invoice_id)
     group by apinv.invoice_id, apinv.invoice_num,
              vend.vendor_name,apinv.invoice_Date, apinv.invoice_Currency_code,
              apinv.vendor_id,apinv.vendor_site_id, apinv.Invoice_Amount, vend.vendor_id,
              apinv.payment_Currency_code,appay.payment_cross_rate,vend.segment1,
              apinv.invoice_Type_Lookup_code, --Bug# 8717502
              apinv.cancelled_date --Bug# 8717502
     order by apinv.invoice_id;

    -- This cursor is to reduce the retainage amount from invoice amount.
    Cursor C1_Rtng(p_Invoice_Id Number) Is
    select nvl(sum(apd.amount),0) InvRtngAmount from
           ap_invoices_all aia,
           ap_invoice_dIstributions_all apd
    where  aia.invoice_id = p_invoice_id
      and  nvl(aia.Cancelled_Date,Sysdate+1) = (Sysdate+1)
      and  apd.invoice_id = aia.invoice_id
      and  aia.invoice_type_lookup_code <> 'RETAINAGE RELEASE'
      and  apd.posted_flag = 'Y'
      and  apd.line_type_lookup_code = 'RETAINAGE'
     group by apd.invoice_id;

    -- This cursor is for calculating the invoice paid amount in current period
    Cursor C_Cur_Per_Inv_Paid(p_invoice_id Number) IS
	select  nvl((decode(apinv.payment_Currency_code,
 	                apinv.invoice_Currency_code,
                    sum(gross_amount),
	                sum(gross_amount)/nvl(appay.payment_cross_rate,1)) -
             decode(apinv.payment_Currency_code,
                    apinv.invoice_Currency_code,
                    sum(amount_remaining),
                    sum(amount_remaining)/nvl(appay.payment_cross_rate,1))),0) Paid_Inv_Amt
    from    ap_invoices_all apinv,
            ap_payment_schedules_all appay
    where   apinv.invoice_id = p_invoice_id and exIsts (select 1 from
                           ap_invoice_dIstributions_all apd
                    where  apd.project_id = P_project_Id
                    and    apd.posted_flag ='Y'
                    and    apinv.invoice_id = apd.invoice_id)
     and    appay.invoice_id(+)=apinv.invoice_id
     and    apinv.invoice_type_lookup_code <> 'EXPENSE REPORT'
     and    exists (
               (SELECT 1
                FROM   ap_invoice_payments_all invpay ,
                       pa_projects_all proj,
                       pa_implementations_all imp,
				       GL_PERIOD_STATUSES glp
                WHERE  proj.project_id = p_project_id
                and    invpay.invoice_id = appay.invoice_id
				and    invpay.payment_num = appay.payment_num
				and    glp.application_id = 101
                AND    glp.adjustment_period_flag = 'N'
                AND    glp.set_of_books_id = imp.set_of_books_id --Bug# 7713608
                AND    glp.closing_status = 'O'
                and    imp.org_id = proj.org_id
                GROUP BY glp.application_id,glp.adjustment_period_flag,glp.closing_status
                HAVING max(invpay.accounting_date)
				BETWEEN MAX(glp.start_date) AND MAX(glp.end_date)
              )) group by apinv.payment_Currency_code,
 	                apinv.invoice_Currency_code, appay.payment_cross_rate;

    -- Cursor C2 is to fetch the invoice details at distribution level.
    -- This returns total invoice amount for specific project related distributions for an invoice.
    Cursor C2(p_Invoice_Id Number, p_Project_Id Number) Is
    select apd.invoice_id,
           apd.project_id,
           apd.task_id,
           apd.Expenditure_Item_Date,
           pod.po_header_id,
           sum(apd.amount) ProjInvAmount,
           sum(nvl(rc_tax.amount,0)) rc_tax,
           sum(ap_pay_hd.amount) Disc_Taken_On_Invoice /* Bug# 7833675 */
    from
    ap_invoice_dIstributions_all apd,
    ap_invoice_dIstributions_all rc_tax,
    po_dIstributions_all pod,
    ap_payment_hist_dists ap_pay_hd
    where apd.project_Id = p_project_Id
      and rc_tax.line_type_lookup_code(+) = 'REC_TAX'
      and rc_tax.tax_recoverable_flag(+) = 'Y'
      and rc_tax.charge_applicable_to_dist_id(+)=apd.invoice_distribution_id
      and rc_tax.posted_flag(+) = 'Y'
      and apd.invoice_id = p_invoice_id
      and rc_tax.invoice_id(+) = p_invoice_id
      and apd.posted_flag = 'Y'
      and pod.po_dIstribution_id(+) = apd.po_distribution_id
	  and nvl(rc_tax.reversal_flag(+),'N') = 'N' /* Additional scenario mentioned by UMA */
      and ap_pay_hd.invoice_distribution_id(+) = apd.invoice_distribution_id /* Bug# 7833675 */
      and ap_pay_hd.pay_dist_lookup_code(+) = 'DISCOUNT' /* Bug# 7833675 */
      -- and apd.line_type_lookup_code <> 'RETAINAGE' /* Bug# 8310848 */
    group by apd.invoice_id, apd.project_id, apd.task_id, apd.Expenditure_Item_Date,
	         pod.po_header_id
    order by apd.project_id, apd.task_id, apd.Expenditure_Item_Date, apd.invoice_id,pod.po_header_id;

    -- Cursor C_RTNG_AMT is to fetch the retainage amount at distribution level.
    -- This returns retainage amount for specific project related distributions for an invoice.
    -- Group by is added just to capture %NOTFOUND in case if there are no records
    -- with retainage lookup code in the invoice distributions table.
    Cursor C_RTNG_AMT(
              p_Invoice_Id Number,
              p_Project_Id Number,
              p_task_id Number,
              p_Expenditure_Item_Date Date,
              p_po_header_id Number) Is
    select sum(apd.amount) ProjRtngAmount,
           -- sum(retained_amount_remaining) Outstanding_Retained
           sum(apd1.amount) RtngReleaseAmount
    from
    ap_invoices_all aia,
    ap_invoice_dIstributions_all apd,
    ap_invoice_dIstributions_all apd1, /* Bug# 8310848 */
    po_dIstributions_all pod
    where aia.invoice_id = p_invoice_id
      and nvl(aia.Cancelled_Date,Sysdate+1) = (Sysdate+1)
      and aia.invoice_type_lookup_code <> 'RETAINAGE RELEASE'
      and apd.invoice_id = aia.invoice_id
      and apd.project_Id = p_project_id
      and apd.posted_flag = 'Y'
      and pod.po_dIstribution_id(+) = apd.po_distribution_id
      and pod.po_header_id(+)=p_po_header_id
      and apd.line_type_lookup_code = 'RETAINAGE'
      and apd.task_id = p_task_id
      and apd.expenditure_item_date = p_expenditure_item_date
      and apd1.retained_invoice_dist_id(+) = apd.invoice_distribution_id /* Bug# 8310848 */
	  and apd1.project_id(+) = apd.project_id /* Bug# 8310848 */
	  and apd1.task_id(+) = apd.task_id /* Bug# 8310848 */
	  and apd1.expenditure_item_date(+) = apd.expenditure_item_date /* Bug# 8310848 */
	  and apd1.po_distribution_id(+) = apd.po_distribution_id /* Bug# 8310848 */
      and nvl(apd1.reversal_flag(+),'N') = 'N' /* Bug# 8310848 */
      and nvl(apd1.posted_flag(+), 'N') = 'Y' /* Bug# 8310848 */
     group by apd.invoice_id, apd.project_Id, apd.task_id, apd.po_dIstribution_id, apd.expenditure_item_date;

    /* Included the hold reasons other than the PWP and DLV */
    -- To get the hold reason if any for an Invoice.
    Cursor C3(P_Invoice_Id Number) Is
    Select hold_lookup_code, hold_reason, 'PWP/DLV' HoldType From ap_holds_all
       Where invoice_id= P_Invoice_Id
       And hold_lookup_code In ('Pay When Paid','PO Deliverable')
       and RELEASE_REASON is null
	UNION ALL
    Select hold_lookup_code, hold_reason, 'OTH' HoldType From ap_holds_all
       Where invoice_id= P_Invoice_Id
       And hold_lookup_code Not In ('Pay When Paid','PO Deliverable')
       and RELEASE_REASON is null;

    -- Cursor C4 is to identify the Manually/Automatically linked draft invoices to a supplier invoice.
    Cursor C4(P_Invoice_Id Number, P_Project_Id Number) Is
	Select distinct draft_invoice_num,link_type From (
    Select   draft_invoice_num, 'M' link_type From PA_PWP_LINKED_INVOICES PWP
      Where  PWP.AP_INVOICE_ID = p_invoice_id
      And    PWP.PROJECT_ID = p_project_id
    UNION ALL
    Select   pdii.draft_invoice_num, 'A' From PA_DRAFT_INVOICE_ITEMS PDII ,
                                                  PA_CUST_REV_DIST_LINES CRDL ,
                                                  PA_EXPENDITURE_ITEMS EI
        Where    PDII.project_id          = crdl.project_id
             And pdii.draft_invoice_num   = crdl.draft_invoice_num
             And pdii.line_num            = crdl.draft_invoice_item_line_num
             And crdl.expenditure_item_id = ei.expenditure_item_id
             And ei.system_linkage_function  = 'VI'
             And ei.document_header_id =p_invoice_id
             And ei.transaction_source like 'AP%'
             And ei.project_id =p_project_id);

    -- Cursor C5 is to get all the PO number's matched to an Invoice.
	Cursor C5(p_Invoice_Id Number) IS
	Select Segment1 PO_NUMBER From po_headers_all
	Where  po_header_id in (Select distinct po_header_id
	                        from pa_pwp_ap_inv_dtl where invoice_id = p_Invoice_id);

    --Cursor C6  is to get all the linked invoices for a given Draft_Inv_Num
    Cursor C6(P_Draft_Inv_Num Number) IS
	Select distinct Invoice_Id From (
    Select   AP_Invoice_Id Invoice_Id From PA_PWP_LINKED_INVOICES PWP
      Where  PWP.draft_invoice_num = P_Draft_Inv_Num
      And    PWP.PROJECT_ID = p_project_id
      And    ap_Invoice_Id is not null
    UNION ALL
    Select   ei.document_header_id From PA_DRAFT_INVOICE_ITEMS PDII ,
                             PA_CUST_REV_DIST_LINES CRDL ,
                             PA_EXPENDITURE_ITEMS EI
        Where    PDII.project_id          = crdl.project_id
             And pdii.draft_invoice_num   = P_Draft_Inv_Num
             AND pdii.draft_invoice_num   = crdl.draft_invoice_num
             And pdii.line_num            = crdl.draft_invoice_item_line_num
             And crdl.expenditure_item_id = ei.expenditure_item_id
             And ei.system_linkage_function  = 'VI'
             And ei.transaction_source like 'AP%'
             And ei.project_id =p_project_id);
    /*
    -- Cursor C_RecTax is to fetch the invoice details at distribution level.
    -- This returns total invoice amount for specific project related distributions for an invoice.
    Cursor C_RecTax(p_Invoice_Id Number,
                    p_Project_Id Number,
                    p_task_id  Number,
                    p_expenditure_item_date Date, p_po_header_id Number ) Is
    select
           sum(rc_tax.amount) ProjInv_RCTax_Amount
    from
    ap_invoice_dIstributions_all apd,
    po_dIstributions_all pod,
    ap_invoice_dIstributions_all rc_tax
    where apd.project_Id = p_project_Id
      and apd.invoice_id = p_invoice_id
      and apd.task_id = p_task_id
      and apd.expenditure_item_date = p_expenditure_item_date
      and apd.posted_flag = 'Y'
      and pod.po_dIstribution_id(+) = apd.po_distribution_id
      and pod.po_header_id(+) = p_po_header_id
      and rc_tax.line_type_lookup_code = 'REC_TAX'
      and rc_tax.tax_recoverable_flag = 'Y'
      and rc_tax.charge_applicable_to_dist_id=apd.invoice_distribution_id
      and rc_tax.posted_flag = 'Y'
      and apd.line_type_lookup_code <> 'RETAINAGE'
    group by apd.invoice_id, apd.project_id, apd.task_id, apd.Expenditure_Item_Date,
	         pod.po_header_id;
    */

      /*Bug#:7834036 sosharma added for additional columns to be displayed in Supplier workbench changes*/
     -- cursor to get header details gl_date, description,invoice type and exchange information
      Cursor c_hdr_info(p_invoice_id Number) IS
   select app.Description,
   app.GL_date,
   (select meaning from FND_LOOKUP_VALUES where lookup_type = 'INVOICE TYPE'
   and view_application_id =200 and language = USERENV('LANG') and lookup_code=app.invoice_type_lookup_code) invoice_type,
   (select min(psd.due_date) from ap_payment_schedules_all psd where psd.invoice_id=app.invoice_id) earliest_due_date,
   app.exchange_rate_type,
   (select user_conversion_type from GL_DAILY_CONVERSION_TYPES where conversion_type=app.exchange_rate_type) exchange_rate_type1,-- Bug 8904838
   app.exchange_date,
   app.exchange_rate
   from ap_invoices_all app where app.invoice_id=p_invoice_id
   and
   exists (select 1 from
                           ap_invoice_dIstributions_all apd
                    where  apd.project_id = P_project_Id
                    and    apd.posted_flag ='Y'
                    and     apd.invoice_id=p_invoice_id);


-- Cursor to get prepaid amount
Cursor c_prepay_amt(p_invoice_id Number) is
select sum(dist.amount) prepaid_amount from ap_prepay_app_dists dist, ap_invoice_dIstributions_all  apd
where dist.invoice_distribution_id = apd.invoice_distribution_id
and apd.project_id=P_Project_Id
and apd.invoice_id=p_invoice_id
group by apd.invoice_id;

inv_prepay_amt                              Number;
inv_description                         VARCHAR2(4000);
inv_ex_rate                             Number;
inv_ex_date                             Date;
inv_ex_rtype                            VARCHAR2(200);
inv_ex_rtype1                            VARCHAR2(200); -- Bug 8904838
inv_gl_date                             Date;
inv_type                                 VARCHAR2(200);
inv_due_date                            Date;
/* sosharma end changes*/

    l_PA_PWP_AP_HDR_ID   Number;

    ProjFunc_INVOICE_AMT                      Number;
    ProjFunc_AMT_PAID                         Number;
    ProjFunc_AMT_UNPAID                       Number;
    ProjFunc_DISCOUNT_AMT                     Number;
    ProjFunc_Retainage                        Number;

    Proj_INVOICE_AMT                          Number;
    Proj_AMT_PAID                             Number;
    Proj_AMT_UNPAID                           Number;
    Proj_DISCOUNT_AMT                         Number;
    Proj_Retainage                            Number;

    ACCT_INVOICE_AMT                          Number;
    ACCT_AMT_PAID                             Number;
    ACCT_AMT_UNPAID                           Number;
    ACCT_DISCOUNT_AMT                         Number;
    Acct_Retainage                            Number;

    INVOICE_AMOUNT                            Number;
    AMOUNT_PAID                               Number;
    AMOUNT_UNPAID                             Number;
    DISCOUNT_AMOUNT                           Number;
    Retainage                                 Number;
    Outstanding_Retainage                     NUMBER :=0; --8310848
    Rtng_Release                              NUMBER :=0; --8310848
    Proj_Rc_Tax                               Number;
    Acct_Rc_Tax                               Number;
    Rc_Tax                                    Number;
    ProjFunc_Rc_Tax                           Number;

	l_inv_paid                                Varchar2(1):='N';

    l_inv_rtng_amt                            NUMBER; -- Bug#8310848

	l_hold_reason                             Varchar2(4000):='';
	l_inv_pwp_hold                            Varchar2(1):='N';
	l_inv_dlv_hold                            Varchar2(1):='N';
	l_inv_hold                                Varchar2(1):='N'; /* ForPayment control enhancement */

	l_po_number                               Varchar2(2000):='';
	l_draft_inv_number                        Varchar2(2000):='';
    l_draft_inv_link_type                     Varchar2(2000):='';

	l_status                                  Varchar2(1);
	l_stage                                   Number :=0 ;

    l_projfunc_cur_per_inv_paid               Number :=0;
	l_proj_cur_per_inv_paid                   Number :=0;

    ProjFunc_Cur_Per_AMT_PAID                 Number;
    Proj_Cur_Per_AMT_PAID                     Number;

    L_Cur_Per_Inv_Paid                        Number;

    l_inv_amount                              Number:=0;
    l_hold_applied_yn                         VARCHAR2(1);

    l_invrec_amount                           Number:=0;
  BEGIN

    l_stage :=0;
	l_status :='S';

    IF P_DEBUG_MODE = 'Y' THEN
      log_message('Begin: Process_SuppInv_Dtls1'||
               '[P_Project_Id : '||P_Project_Id||' ]',
               'Process_SuppInv_Dtls1');
    END IF;

    IF P_DEBUG_MODE = 'Y' THEN
      log_message('Before deleting data from PA_PWP_AP_INV_HDR and PA_PWP_AP_INV_DTL for'||
               '[P_Project_Id : '||P_Project_Id||' ]',
               'Process_SuppInv_Dtls1');
    END IF;

    IF G_Draft_Inv_Num IS NULL THEN
       Delete from PA_PWP_AP_INV_HDR where project_id = P_Project_Id;
	   Delete from PA_PWP_AP_INV_DTL where project_id = P_Project_Id;
    END IF;
    IF G_Draft_Inv_Num IS NOT NULL THEN
        OPEN C6(G_Draft_Inv_Num);
    END IF;

    LOOP
      G_Invoice_Id :='';
      IF G_Draft_Inv_Num IS NOT NULL AND C6%ISOPEN THEN
         FETCH C6 INTO G_Invoice_Id;
         IF C6%NOTFOUND THEN
            CLOSE C6;
            EXIT;
         ELSE
           Delete from PA_PWP_AP_INV_HDR where project_id = P_Project_Id And Invoice_Id = G_Invoice_Id;
	       Delete from PA_PWP_AP_INV_DTL where project_id = P_Project_Id And Invoice_Id = G_Invoice_Id;
         END IF;
      END IF;

      l_stage :=10;
      FOR INVREC IN C1 LOOP

        IF P_DEBUG_MODE = 'Y' THEN
          log_message('In For Loop for INVREC'||
                      '[INVREC.INVOICE_ID : '||INVREC.INVOICE_ID||'] '||
                      '[l_stage : '||l_stage||']',
                      'Process_SuppInv_Dtls1');
        END IF;

	      l_hold_reason :='';
		  l_inv_paid:='N';
          l_inv_hold:='N';
		  l_inv_pwp_hold:='N';
		  l_inv_dlv_hold:='N';
          l_hold_applied_yn := 'N';
          l_draft_inv_number:='';
		  l_po_number := '';
          l_inv_rtng_amt :=0; /* Bug# 8310848 */

          OPEN C1_Rtng(INVREC.invoice_id); /* Bug# 8310848 */
          FETCH C1_Rtng INTO l_inv_rtng_amt;
          CLOSE C1_Rtng;

          IF INVREC.Invoice_Amount = 0 THEN
             l_inv_amount :=1;
          ELSE
             l_inv_amount :=INVREC.Invoice_Amount+nvl(l_inv_rtng_amt,0); /* Bug# 8310848 */
          END IF;

          l_stage :=20;

          IF P_DEBUG_MODE = 'Y' THEN
             log_message('Before Opening C3 for INVREC_HOLD'||
                         '[INVREC.INVOICE_ID : '||INVREC.INVOICE_ID||'] '||
                         '[l_stage : '||l_stage||'] ',
                        'Process_SuppInv_Dtls1');
          END IF;

          FOR INVREC_HOLD IN C3(INVREC.INVOICE_ID)
		  LOOP
		     IF l_hold_reason IS NULL THEN
                l_hold_reason := INVREC_HOLD.hold_reason||'.';
             ELSE
                l_hold_reason := l_hold_reason||'<br>'||INVREC_HOLD.hold_reason||'.';
             END IF;

             l_inv_hold := 'Y';
			 If INVREC_HOLD.hold_lookup_code = 'Pay When Paid' Then
			    l_inv_pwp_hold := 'Y';
			 ElsIf INVREC_HOLD.hold_lookup_code = 'PO Deliverable' Then
			    l_inv_dlv_hold := 'Y';
             ElsIf INVREC_HOLD.hold_lookup_code = 'Project Hold' Then --bug 9525493
                l_hold_applied_yn := 'Y';
			 End If;
		  END LOOP;

          IF P_DEBUG_MODE = 'Y' THEN
             log_message('INVREC_HOLD '||
                         '[l_hold_reason : '||l_hold_reason||'] '||
                         '[l_inv_pwp_hold : '||l_inv_pwp_hold||'] '||
                         '[l_inv_dlv_hold : '||l_inv_dlv_hold||'] '||
                         '[l_inv_hold : '||l_inv_hold||'] ',
                        'Process_SuppInv_Dtls1');
          END IF;

          IF P_DEBUG_MODE = 'Y' THEN
             log_message('Before Opening C4 for DRAFTINV_REC ',
                        'Process_SuppInv_Dtls1');
          END IF;

          FOR DRAFTINV_REC IN C4(INVREC.INVOICE_ID,INVREC.PROJECT_ID) LOOP
            IF l_draft_inv_number IS NULL THEN
		       l_draft_inv_number:=DRAFTINV_REC.draft_invoice_num;
               l_draft_inv_link_type :=DRAFTINV_REC.link_type;
            ELSE
		       l_draft_inv_number:=l_draft_inv_number||','||DRAFTINV_REC.draft_invoice_num;
               l_draft_inv_link_type := l_draft_inv_link_type||','||DRAFTINV_REC.link_type;
            END IF;
		  END LOOP;

          IF P_DEBUG_MODE = 'Y' THEN
             log_message('After Opening C4 for DRAFTINV_REC '||
                         '[l_draft_inv_number : '||l_draft_inv_number||'] '||
                         '[l_draft_inv_link_type : '||l_draft_inv_link_type||'] ',
                        'Process_SuppInv_Dtls1');
          END IF;

          l_stage :=30;
          IF P_DEBUG_MODE = 'Y' THEN
             log_message('Before calculating invoice paid amount in current period ',
                        'Process_SuppInv_Dtls1');
          END IF;
          L_Cur_Per_Inv_Paid :=0; /* Initialization is done for Bug# 8203817 */

		  IF nvl(INVREC.Paid_Inv_Amt,0) > 0 THEN
		     OPEN C_Cur_Per_Inv_Paid(INVREC.INVOICE_ID);
		     FETCH C_Cur_Per_Inv_Paid Into L_Cur_Per_Inv_Paid;
		     CLOSE C_Cur_Per_Inv_Paid;
		  END IF;

          IF P_DEBUG_MODE = 'Y' THEN
             log_message('After calculating invoice paid amount in current period '||
                         '[L_Cur_Per_Inv_Paid : '||L_Cur_Per_Inv_Paid||'] ',
                        'Process_SuppInv_Dtls1');
          END IF;

          IF P_DEBUG_MODE = 'Y' THEN
             log_message('Deriving paid flag for invoice '||
                         '[l_stage : '||l_stage||'] ',
                        'Process_SuppInv_Dtls1');
          END IF;

          /*****
             1. If there is unpaid amount and paid amount,
                   then it is Partial Case.
             2. If there is unpaid amount and no paid amount,
                   then it is Not Paid Case.
             3. If there is no unpaid amount and paid amount,
                   then it is Fully Paid case.
             4. If there is no unpaid amount and no paid amount,
                   then it is also Not Paid case.
           *****/

           /* Added for bug 8293625 */
           if(INVREC.Invoice_Type = 'CREDIT' OR INVREC.Invoice_Type = 'DEBIT' OR nvl(INVREC.Cancelled_Date,Sysdate+1) <> Sysdate+1) Then
             l_inv_paid := 'G';

           Else

		  If nvl(INVREC.Unpaid_Inv_Amt,0) <> 0 Then
		    If nvl(INVREC.Paid_Inv_Amt,0) <> 0 Then
		       l_inv_paid := 'P';
			Else
			   l_inv_paid := 'N';
			End If;
		  ElsIf nvl(INVREC.Paid_Inv_Amt,0) <> 0 Then /* For Bug# 7831141 */
		    l_inv_paid := 'Y';
          Else
            l_inv_paid := 'N';
		  End If;

          IF P_DEBUG_MODE = 'Y' THEN
             log_message('After deriving paid flag for invoice '||
                         '[l_inv_paid : '||l_inv_paid||'] ',
                        'Process_SuppInv_Dtls1');
          END IF;

          End if;

          l_stage :=40;

           /* Bug#:7834036 sosharma added for additional columns
              to be displayed in Supplier workbench changes
           */

            FOR inv_dtls_rec IN c_hdr_info(INVREC.INVOICE_ID) LOOP

                inv_description:=inv_dtls_rec.description;
		inv_ex_rate:=inv_dtls_rec.exchange_rate;
		inv_ex_date:=inv_dtls_rec.exchange_date;
		inv_ex_rtype:=inv_dtls_rec.exchange_rate_type;
		inv_ex_rtype1:=inv_dtls_rec.exchange_rate_type1;-- Bug 8904838
		inv_gl_date:=inv_dtls_rec.gl_date;
		inv_type :=inv_dtls_rec.invoice_type;
		inv_due_date :=inv_dtls_rec.earliest_due_date;

	END LOOP;

        /* Bug# Added this for bug# 8849692 */
        /* Bug#8897745 */
        IF inv_ex_rate IS NOT NULL  THEN
            ACCT_Cst_Rate_Date       :=inv_ex_date;
            ACCT_Cst_Rate_Type       :=inv_ex_rtype;
            ACCT_CST_RATE            :=inv_ex_rate;
        ELSE
            ACCT_Cst_Rate_Date       :='';
            ACCT_Cst_Rate_Type       :='';
            ACCT_CST_RATE            :='';
        END IF;

         FOR inv_prepay_rec IN c_prepay_amt(INVREC.INVOICE_ID) LOOP

                inv_prepay_amt:=inv_prepay_rec.prepaid_amount;
          END LOOP;
	  /* sosharma end changes*/

         -- L_PA_PWP_AP_HDR_ID:= PA_PWP_AP_INV_HDR_S.nextval; Changed for backward compatibility : Bug 7666516
         SELECT PA_PWP_AP_INV_HDR_S.nextval
           INTO L_PA_PWP_AP_HDR_ID
           FROM dual;

          IF P_DEBUG_MODE = 'Y' THEN
             log_message('Before inserting record in  PA_PWP_AP_INV_HDR'||
                         '[INVREC.INVOICE_ID : '||INVREC.INVOICE_ID||'] '||
                         '[l_stage : '||l_stage||'] '||
                         '[L_PA_PWP_AP_HDR_ID : '||L_PA_PWP_AP_HDR_ID||'] ',
                        'Process_SuppInv_Dtls1');
          END IF;

             Insert Into PA_PWP_AP_INV_HDR(PA_PWP_AP_HDR_ID
                                       ,PROJECT_ID
                                       ,INVOICE_ID
                                       ,INVOICE_NUM
                                       ,vendOR_ID
									   ,SUPPLIER_NUM
                                       ,SUPPLIER_NAME
                                       ,SUPPLIER_SITE_CODE
                                       ,INVOICE_Date
                                       ,INVOICE_AMOUNT
                                       ,INVOICE_Currency
									   ,HOLD_REASON
									   ,PWP_HOLD_FLAG
									   ,DLV_HOLD_FLAG
                                       ,HOLD_FLAG
									   ,PAYMENT_STATUS
                                       ,LINKED_DRAFT_INVOICE_NUM
                                       ,LINKED_DRFAT_INV_TYPE
                                       ,hold_applied_yn
				       ,description
				       ,exchange_rate
				       ,exchange_date
				       ,exchange_rate_type
				       ,gl_date
				       ,invoice_type
				       ,earliest_pay_due_date
				       ,prepaid_amount
									   ) Values(
                                        l_PA_PWP_AP_HDR_ID
                                       ,INVREC.PROJECT_ID
                                       ,INVREC.INVOICE_ID
                                       ,INVREC.INVOICE_NUM
									   ,INVREC.vendOR_ID
									   ,INVREC.Supplier_Num
                                       ,INVREC.SUPPLIER_NAME
                                       ,INVREC.SUPPLIER_SITE
                                       ,INVREC.INVOICE_Date
                                       ,INVREC.INVOICE_AMOUNT
                                       ,INVREC.INVOICE_Currency
                                       ,l_hold_reason
		                               ,l_inv_pwp_hold
		                               ,l_inv_dlv_hold
                                       ,l_inv_hold
									   ,l_inv_paid
									   ,l_draft_inv_number
                                       ,l_draft_inv_link_type
                                       ,l_hold_applied_yn
					, inv_description
					,inv_ex_rate
					,inv_ex_date
					,inv_ex_rtype1
					,inv_gl_date
					,inv_type
					,inv_due_date
					,inv_prepay_amt
					);

          l_stage :=50;

          IF P_DEBUG_MODE = 'Y' THEN
             log_message('Before opening the loop for inserting record in PA_PWP_AP_INV_DTL '||
                         '[INVREC.INVOICE_ID : '||INVREC.INVOICE_ID||'] '||
                         '[l_stage : '||l_stage||'] ',
                        'Process_SuppInv_Dtls1');
          END IF;

          FOR INVDTL IN C2(INVREC.INVOICE_ID, INVREC.PROJECT_ID) LOOP

             l_stage :=60;

             IF P_DEBUG_MODE = 'Y' THEN
                log_message('Before calling Derive_ProjCurr_Attribute '||'[l_stage : '||l_stage||'] ',
                        'Process_SuppInv_Dtls1');
             END IF;

             Derive_ProjCurr_Attribute(p_Project_id,
                                       INVDTL.tasK_id,
                                       INVDTL.expenditure_item_date,
                                       INVREC.Invoice_Currency);

             IF P_DEBUG_MODE = 'Y' THEN
                log_message('Before Calculating the retainage amount '||'[l_stage : '||l_stage||'] ',
                        'Process_SuppInv_Dtls1');
             END IF;

             OPEN C_RTNG_AMT(
              INVREC.Invoice_Id,
              p_Project_Id,
              INVDTL.task_id,
              INVDTL.Expenditure_Item_Date,
              INVDTL.po_header_id);

             FETCH C_RTNG_AMT INTO Retainage, Rtng_Release; -- Added for 8310848
             IF C_RTNG_AMT%NOTFOUND THEN
                Retainage := 0;
                Rtng_Release :=0; -- Added for 8310848
             END IF;
             CLOSE C_RTNG_AMT;

             Outstanding_Retainage := abs(nvl(Retainage,0)) - nvl(Rtng_Release,0); /* Bug# 8310848 */

             /* Rtng_Release := abs(Retainage) - Outstanding_Retainage;*/ -- Added for 8310848

             /*
             OPEN C_RecTax(
              INVREC.Invoice_Id,
              p_Project_Id,
              INVDTL.task_id,
              INVDTL.Expenditure_Item_Date,
              INVDTL.po_header_id);

             FETCH C_RecTax INTO Rc_Tax;
             IF C_RecTax%NOTFOUND THEN
                Rc_Tax := 0;
             END IF;
             CLOSE C_RecTax;*/
             Rc_Tax := INVDTL.rc_tax;
             l_invrec_amount := (INVDTL.ProjInvAmount+INVDTL.rc_tax);

             IF P_DEBUG_MODE = 'Y' THEN
                log_message('Before deriving all the amount columns',
                            'Process_SuppInv_Dtls1');
             END IF;

            /* Bug# 8310848:
            */
  		     ProjFunc_INVOICE_AMT  :=l_invrec_amount* ProjFunc_CST_RATE;

             ProjFunc_AMT_PAID     :=(l_invrec_amount*INVREC.Paid_Inv_Amt/l_inv_amount)
                                            * ProjFunc_CST_RATE;
             ProjFunc_AMT_UNPAID   :=(l_invrec_amount*INVREC.UnPaid_Inv_Amt/l_inv_amount)
                                            * ProjFunc_CST_RATE;
             IF nvl(L_Cur_Per_Inv_Paid,0) >0 THEN
 			    ProjFunc_Cur_Per_AMT_PAID := (l_invrec_amount*L_Cur_Per_Inv_Paid/l_inv_amount)
                                            * ProjFunc_CST_RATE;
			 ELSE
			    ProjFunc_Cur_Per_AMT_PAID := 0;
			 END IF;

             /* Modified the discount calculation for Bug# 7833675 as below.
             ProjFunc_DISCOUNT_AMT :=(INVDTL.ProjInvAmount*INVREC.DIsc_Taken_On_Inv/l_inv_amount)
                                            * ProjFunc_CST_RATE;
             */

             ProjFunc_DISCOUNT_AMT :=INVDTL.DIsc_Taken_On_Invoice* ProjFunc_CST_RATE;

             ProjFunc_Retainage := Outstanding_Retainage *ProjFunc_CST_RATE;
             ProjFunc_Rc_Tax := Rc_Tax * ProjFunc_CST_RATE;

             Proj_INVOICE_AMT      :=l_invrec_amount*Proj_CST_RATE;
             Proj_AMT_PAID         :=(l_invrec_amount*INVREC.Paid_Inv_Amt/l_inv_amount)
                                            *Proj_CST_RATE;
             Proj_AMT_UNPAID       :=(l_invrec_amount*INVREC.UnPaid_Inv_Amt/l_inv_amount)
                                            *Proj_CST_RATE;

             IF nvl(L_Cur_Per_Inv_Paid,0) >0 THEN
 			    Proj_Cur_Per_AMT_PAID := (l_invrec_amount*L_Cur_Per_Inv_Paid/l_inv_amount)
                                          * Proj_CST_RATE;
			 ELSE
			    Proj_Cur_Per_AMT_PAID := 0;
			 END IF;

             /* Modified the discount calculation for Bug# 7833675 as below.
			 Proj_DISCOUNT_AMT     :=(INVDTL.ProjInvAmount*INVREC.DIsc_Taken_On_Inv/l_inv_amount)
                                            *Proj_CST_RATE;
             */
			 Proj_DISCOUNT_AMT     :=INVDTL.DIsc_Taken_On_Invoice*Proj_CST_RATE;

             Proj_Retainage := Outstanding_Retainage * Proj_CST_RATE;

             Proj_Rc_Tax := Rc_Tax * Proj_CST_RATE;
             ACCT_INVOICE_AMT      :=l_invrec_amount*ACCT_CST_RATE;
             ACCT_AMT_PAID         :=(l_invrec_amount*INVREC.Paid_Inv_Amt/l_inv_amount)
			                               *ACCT_CST_RATE;
             ACCT_AMT_UNPAID       :=(l_invrec_amount*INVREC.UnPaid_Inv_Amt/l_inv_amount)
			                               *ACCT_CST_RATE;

            /* Modified the discount calculation for Bug# 7833675 as below.
             ACCT_DISCOUNT_AMT     :=(INVDTL.ProjInvAmount*INVREC.DIsc_Taken_On_Inv/l_inv_amount)
                                           *ACCT_CST_RATE;
            */

             ACCT_DISCOUNT_AMT     :=(INVDTL.Disc_Taken_On_Invoice)*ACCT_CST_RATE;

             Acct_Retainage := Outstanding_Retainage *ACCT_CST_RATE;

             Acct_Rc_Tax := Rc_Tax * Acct_CST_RATE;
             INVOICE_AMOUNT        :=l_invrec_amount;
             AMOUNT_PAID           :=(l_invrec_amount*INVREC.Paid_Inv_Amt/l_inv_amount);
             AMOUNT_UNPAID         :=(l_invrec_amount*INVREC.UnPaid_Inv_Amt/l_inv_amount);

             /* Modified the discount calculation for Bug# 7833675 as below.
             DISCOUNT_AMOUNT       :=(INVDTL.DIsc_Taken_On_Invoice/l_inv_amount);
             */
             DISCOUNT_AMOUNT       :=INVDTL.DIsc_Taken_On_Invoice;

             IF P_DEBUG_MODE = 'Y' THEN
                log_message('After deriving all amount columns '||
                         '[ProjFunc_INVOICE_AMT : '||ProjFunc_INVOICE_AMT||'] '||
                         '[ProjFunc_AMT_PAID : '||ProjFunc_AMT_PAID||'] '||
                         '[ProjFunc_AMT_UNPAID : '||ProjFunc_AMT_UNPAID||'] '||
                         '[ProjFunc_Cur_Per_AMT_PAID : '||ProjFunc_Cur_Per_AMT_PAID||'] '||
                         '[ProjFunc_DISCOUNT_AMT : '||ProjFunc_DISCOUNT_AMT||'] '||
                         '[Proj_INVOICE_AMT : '||Proj_INVOICE_AMT||'] '||
                         '[Proj_AMT_PAID : '||Proj_AMT_PAID||'] '||
                         '[Proj_AMT_UNPAID : '||Proj_AMT_UNPAID||'] '||
                         '[Proj_Cur_Per_AMT_PAID : '||Proj_Cur_Per_AMT_PAID||'] '||
                         '[Proj_DISCOUNT_AMT : '||Proj_DISCOUNT_AMT||'] '||
                         '[ACCT_INVOICE_AMT : '||ACCT_INVOICE_AMT||'] '||
                         '[ACCT_AMT_PAID : '||ACCT_AMT_PAID||'] '||
                         '[ACCT_AMT_UNPAID : '||ACCT_AMT_UNPAID||'] '||
                         '[ACCT_DISCOUNT_AMT : '||ACCT_DISCOUNT_AMT||'] '||
                         '[INVOICE_AMOUNT : '||INVOICE_AMOUNT||'] '||
                         '[AMOUNT_PAID : '||AMOUNT_PAID||'] '||
                         '[AMOUNT_UNPAID : '||AMOUNT_UNPAID||'] '||
                         '[DISCOUNT_AMOUNT : '||DISCOUNT_AMOUNT||'] ',
                        'Process_SuppInv_Dtls1');
             END IF;

             l_stage :=70;

             IF P_DEBUG_MODE = 'Y' THEN
                 log_message('Before inserting record in  PA_PWP_AP_INV_DTL '||
                         '[INVREC.INVOICE_ID : '||INVREC.INVOICE_ID||'] '||
                         '[l_stage : '||l_stage||'] ',
                        'Process_SuppInv_Dtls1');
             END IF;

              Insert into PA_PWP_AP_INV_DTL(PA_PWP_AP_HDR_ID
                                           ,INVOICE_ID
                                           ,PROJECT_ID
                                           ,TASK_ID
                                           ,Expenditure_Item_Date
                                           ,PO_HEADER_ID
                                           ,INVOICE_Currency
                                           ,PROJINV_TOT_AMOUNT
                                           ,AMOUNT_PAID
                                           ,AMOUNT_UNPAID
                                           ,RETAINED_AMOUNT
                                           ,DISCOUNT_AMOUNT
                                           ,ProjFunc_Currency_CODE
                                           ,ProjFunc_INVOICE_AMOUNT
                                           ,ProjFunc_INV_PAID_AMOUNT
                                           ,ProjFunc_INV_UNPAID_AMOUNT
                                           ,ProjFunc_RETAINED_AMOUNT
                                           ,ProjFunc_DISCOUNT_AMOUNT
                                           ,Proj_Currency_CODE
                                           ,Proj_INVOICE_AMOUNT
                                           ,Proj_INV_PAID_AMOUNT
                                           ,Proj_INV_UNPAID_AMOUNT
                                           ,Proj_RETAINED_AMOUNT
                                           ,Proj_DISCOUNT_AMOUNT
                                           ,ACCT_Currency_CODE
                                           ,ACCT_INVOICE_AMOUNT
                                           ,ACCT_INV_PAID_AMOUNT
                                           ,ACCT_INV_UNPAID_AMOUNT
                                           ,ACCT_RETAINED_AMOUNT
                                           ,ACCT_DISCOUNT_AMOUNT
										   ,PROJFUNC_CUR_PER_INV_PAID
										   ,PROJ_CUR_PER_INV_PAID
                                           ,PROJFUNC_RTAX_AMOUNT
                                           ,PROJ_RTAX_AMOUNT
                                           ,ACCT_RTAX_AMOUNT
                                           ,RTAX_AMOUNT)
                                   VALUES (
                                            l_PA_PWP_AP_HDR_ID
                                           ,INVREC.INVOICE_ID
                                           ,INVREC.PROJECT_ID
                                           ,INVDTL.TASK_ID
                                           ,INVDTL.Expenditure_Item_Date
                                           ,INVDTL.PO_HEADER_ID
                                           ,INVREC.INVOICE_Currency
                                           ,INVOICE_AMOUNT
                                           ,AMOUNT_PAID
                                           ,AMOUNT_UNPAID
                                           ,Outstanding_Retainage -- 8310848
                                           ,DISCOUNT_AMOUNT
                                           ,ProjFunc_Currency
                                           ,ProjFunc_INVOICE_AMT
                                           ,ProjFunc_AMT_PAID
                                           ,ProjFunc_AMT_UNPAID
                                           ,ProjFunc_retainage
                                           ,ProjFunc_DISCOUNT_AMT
                                           ,Proj_Currency
                                           ,Proj_INVOICE_AMT
                                           ,Proj_AMT_PAID
                                           ,Proj_AMT_UNPAID
                                           ,Proj_Retainage
                                           ,Proj_DISCOUNT_AMT
                                           ,PA_CURR_CODE
                                           ,ACCT_INVOICE_AMT
                                           ,ACCT_AMT_PAID
                                           ,ACCT_AMT_UNPAID
                                           ,Acct_retainage
                                           ,ACCT_DISCOUNT_AMT
                                           ,ProjFunc_Cur_Per_AMT_PAID
										   ,Proj_Cur_Per_AMT_PAID
                                           ,ProjFunc_Rc_Tax
                                           ,Proj_Rc_Tax
                                           ,Acct_Rc_Tax
                                           ,Rc_Tax);

           END LOOP;
           l_stage :=80;

           IF P_DEBUG_MODE = 'Y' THEN
                 log_message('Before deriving PO Number '||
                         '[INVREC.INVOICE_ID : '||INVREC.INVOICE_ID||'] '||
                         '[l_stage : '||l_stage||'] ',
                        'Process_SuppInv_Dtls1');
           END IF;

           FOR PO_NUM IN C5(INVREC.INVOICE_ID) LOOP
		       If l_po_number Is NULL Then
			      l_po_number := l_po_number||nvl(PO_NUM.po_number,'');
			   Else
                  l_po_number := l_po_number||','||nvl(PO_NUM.po_number,'');
			   End If;
		   END LOOP;

           IF P_DEBUG_MODE = 'Y' THEN
                 log_message('After deriving PO Number '||
                         '[l_po_number : '||l_po_number||'] '||
                         '[l_stage : '||l_stage||'] ',
                        'Process_SuppInv_Dtls1');
           END IF;

		   Update PA_PWP_AP_INV_HDR
		   Set    po_number = l_po_number
		   Where  pa_pwp_ap_hdr_id = l_pa_pwp_ap_hdr_id;

      END LOOP;

      IF G_Draft_Inv_Num IS NULL THEN
         EXIT;
      END IF;

    END LOOP;

    COMMIT;
    IF P_DEBUG_MODE = 'Y' THEN
        log_message('End of the procedure '||
                       '[l_status : '||l_status||'] ',
                      'Process_SuppInv_Dtls1');
    END IF;

	  X_return_status := l_status;
  EXCEPTION
      WHEN OTHERS THEN
          IF C1%ISOPEN THEN
             CLOSE C1;
          END IF;

          IF C2%ISOPEN THEN
             CLOSE C2;
          END IF;

          IF C3%ISOPEN THEN
             CLOSE C3;
          END IF;

          IF C4%ISOPEN THEN
             CLOSE C4;
          END IF;

          IF C5%ISOPEN THEN
             CLOSE C5;
          END IF;

          IF C6%ISOPEN THEN
             CLOSE C6;
          END IF;

          IF C_Cur_Per_Inv_Paid%ISOPEN THEN
             CLOSE C_Cur_Per_Inv_Paid;
          END IF;

          IF C_RTNG_AMT%ISOPEN THEN
             CLOSE C_RTNG_AMT;
          END IF;

          IF P_DEBUG_MODE = 'Y' THEN
             log_message('In When Others Exception : '||SQLERRM,
                        'Process_SuppInv_Dtls1');
          END IF;
	      X_return_status := 'U';
          X_msg_data := SQLERRM;
  END Process_SuppInv_Dtls1;

  ---------------------------------------------------------------------------------------------------------
    -- This procedure in turn calls Process_SuppInv_Dtls1, to populate pa_pwp_ap_inv_hdr, pa_pwp_ap_inv_dtl
    -- tables by processing all the supplier invoices pertaining to the project_id being passed.
    -- This is being called from the Summary Page of Subcontractor tab.
    -- Input parameters
    -- Parameters                Type           Required  Description
    --  p_project_id             NUMBER         YES       It stores the project_id
    -- Out parameters
  ----------------------------------------------------------------------------------------------------------
  Procedure Process_SuppInv_Dtls  (P_Project_Id  IN  Number, P_Draft_Inv_Num IN Number :='') IS
    X_return_status   VARCHAR2(2000);
    X_msg_count       NUMBER;
    X_msg_data        VARCHAR2(4000);
  BEGIN

          IF P_Draft_Inv_Num IS NOT NULL THEN
            IF NVL(G_Draft_Inv_Num,-99) <> NVL(P_Draft_Inv_Num,-99) THEN
             G_Draft_Inv_Num:= P_Draft_Inv_Num;
            END IF;
          ELSE
            G_Draft_Inv_Num:='';
          END IF;

          IF P_DEBUG_MODE = 'Y' THEN
             log_message('Before calling Process_SuppInv_Dtls1 ',
                        'Process_SuppInv_Dtls');
          END IF;

          Process_SuppInv_Dtls1  (P_Project_Id
                                 ,X_return_status
                                 ,X_msg_count
                                 ,X_msg_data);
          IF P_DEBUG_MODE = 'Y' THEN
             log_message('After calling Process_SuppInv_Dtls1 ',
                        'Process_SuppInv_Dtls');
          END IF;

  END Process_SuppInv_Dtls;
  /*--------------------------------------------------------------------------------------------------------
    -- This procedure applies Project Hold for the supplier invoices passed as a pl/sql table
    -- Input parameters
    -- Parameters                Type           Required  Description
    --  P_Inv_Tbl                PL/SQL Tbl     YES       It stores a list of invoice_id's for which
    --                                                    the PWP/DLV Hold needs to be released.
    -- Out parameters
    -- Parameters                Type           Required  Description
    --  X_return_status          VARCHAR2       YES       The return status of the APIs.
                                                          Valid values are:
                                                          S (API completed successfully),
                                                          E (business rule violation error) and
                                                          U(Unexpected error, such as an Oracle error.
    --  X_msg_count              NUMBER         YES       Holds the number of messages in the global message
                                                          table. Calling programs should use this as the
                                                          basis to fetch all the stored messages.
    --  x_msg_data               VARCHAR2       YES       Holds the message code, if the API returned only
                                                          one error/warning message Otherwise the column is
                                                          left blank.
  ----------------------------------------------------------------------------------------------------------*/
  Procedure Paap_Apply_Hold (P_Inv_Tbl         IN  InvoiceId
                             ,X_return_status   OUT NOCOPY VARCHAR2
                             ,X_msg_count       OUT NOCOPY NUMBER
                             ,X_msg_data        OUT NOCOPY VARCHAR2) IS
    -- To get the hold reason if any for an Invoice.
    Cursor C3(P_Invoice_Id Number) Is
    Select hold_lookup_code, hold_reason, 'PWP/DLV' HoldType From ap_holds_all
       Where invoice_id= P_Invoice_Id
       And hold_lookup_code In ('Pay When Paid','PO Deliverable')
       and RELEASE_REASON is null
	UNION ALL
    Select hold_lookup_code, hold_reason, 'OTH' HoldType From ap_holds_all
       Where invoice_id= P_Invoice_Id
       And hold_lookup_code Not In ('Pay When Paid','PO Deliverable')
       and RELEASE_REASON is null;

	l_inv_pwp_hold                            Varchar2(1):='N';
	l_inv_dlv_hold                            Varchar2(1):='N';
	l_inv_hold                                Varchar2(1):='N';
    l_hold_reason1                             Varchar2(4000);
    l_hold_applied_yn                         varchar2(1):= 'N';
  Begin
      X_return_status :='S';
      FOR I in 1..P_Inv_Tbl.COUNT LOOP
         AP_HOLDS_PKG.insert_single_hold  (X_invoice_id=>P_Inv_Tbl(i)
                                          ,X_hold_lookup_code=>'Project Hold' -- bug 9525493
                                          ,X_hold_reason=>'Project Managers Hold'
                                          ,X_held_by=>FND_GLOBAL.User_Id);

        l_inv_pwp_hold   :='N';
	    l_inv_dlv_hold   :='N';
	    l_inv_hold       :='N';
        l_hold_reason1    :='';
        l_hold_applied_yn := 'N';

        FOR INVREC_HOLD IN C3(p_inv_tbl(i))
		  LOOP
		     IF l_hold_reason1 IS NULL THEN
                l_hold_reason1 := INVREC_HOLD.hold_reason||'.';
             ELSE
                l_hold_reason1 := l_hold_reason1||'<br>'||INVREC_HOLD.hold_reason||'.';
             END IF;
             l_inv_hold := 'Y';
			 If INVREC_HOLD.hold_lookup_code = 'Pay When Paid' Then
			    l_inv_pwp_hold := 'Y';
			 ElsIf INVREC_HOLD.hold_lookup_code = 'PO Deliverable' Then
			    l_inv_dlv_hold := 'Y';
             ElsIf INVREC_HOLD.hold_lookup_code = 'Project Hold' Then  --bug 9525493
                l_hold_applied_yn := 'Y';
			 End If;
        END LOOP;

        Update PA_PWP_AP_INV_HDR Set HOLD_REASON = l_hold_reason1,
                                     PWP_HOLD_FLAG = l_inv_pwp_hold,
                                     DLV_HOLD_FLAG = l_inv_dlv_hold,
                                     HOLD_FLAG = l_inv_hold,
                                     HOLD_APPLIED_YN = l_hold_applied_yn
	    Where  Invoice_Id = p_inv_tbl(i)
        And    RELHOLD_REJ_REASON Is Null;

      END LOOP;
   End;

END PAAP_PWP_PKG;

/
