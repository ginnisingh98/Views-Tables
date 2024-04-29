--------------------------------------------------------
--  DDL for Package Body PA_INVOICE_DETAIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_INVOICE_DETAIL_PKG" as
/* $Header: PAICIDTB.pls 120.5 2007/04/11 08:17:56 nayyadev ship $ */

     L_EXPENDITURE_ITEM_ID   PA_PLSQL_DATATYPES.IdTabTyp;
     L_LINE_NUM              PA_PLSQL_DATATYPES.IdTabTyp;
     L_PROJECT_ID            PA_PLSQL_DATATYPES.IdTabTyp;
     L_INVOICED_FLAG         PA_PLSQL_DATATYPES.Char1TabTyp;
     L_DENOM_CURRENCY_CODE   PA_PLSQL_DATATYPES.Char30TabTyp;
     L_DENOM_BILL_AMOUNT     PA_PLSQL_DATATYPES.NumTabTyp;
     L_ACCT_CURRENCY_CODE    PA_PLSQL_DATATYPES.Char30TabTyp;
     L_BILL_AMOUNT           PA_PLSQL_DATATYPES.NumTabTyp;
     L_ACCT_RATE_TYPE        PA_PLSQL_DATATYPES.Char30TabTyp;
     L_ACCT_RATE_DATE        PA_PLSQL_DATATYPES.Char30TabTyp;
     L_ACCT_EXCHANGE_RATE    PA_PLSQL_DATATYPES.NumTabTyp;
     L_CC_PROJECT_ID         PA_PLSQL_DATATYPES.IdTabTyp;
     L_CC_TAX_TASK_ID        PA_PLSQL_DATATYPES.IdTabTyp;
     L_ORG_ID                PA_PLSQL_DATATYPES.IdTabTyp;
     L_REV_CODE_COMBINATION_ID PA_PLSQL_DATATYPES.IdTabTyp;
     L_DRAFT_INVOICE_NUM       PA_PLSQL_DATATYPES.IdTabTyp;
     L_DRAFT_INVOICE_LINE_NUM  PA_PLSQL_DATATYPES.IdTabTyp;
     L_OUTPUT_VAT_TAX_ID       PA_PLSQL_DATATYPES.IdTabTyp;
     L_OUTPUT_TAX_CODE         PA_PLSQL_DATATYPES.Char30TabTyp; --added by hsiu
     L_OUTPUT_TAX_EXEMPT_FLAG  PA_PLSQL_DATATYPES.Char1TabTyp;
     L_OUTPUT_EXEMPT_REASON_CODE PA_PLSQL_DATATYPES.Char30TabTyp;
     L_OUTPUT_TAX_EXEMPT_NUMBER      PA_PLSQL_DATATYPES.Char80TabTyp;
     L_LINE_NUM_REVERSED             PA_PLSQL_DATATYPES.IdTabTyp;
     L_DETAIL_ID_REVERSED            PA_PLSQL_DATATYPES.IdTabTyp;
     L_DETAIL_ID                     PA_PLSQL_DATATYPES.IdTabTyp;
     L_REVERSED_FLAG                 PA_PLSQL_DATATYPES.Char1TabTyp;
     L_MARKUP_CALC_BASE_CODE         PA_PLSQL_DATATYPES.Char30TabTyp;
     L_IND_COMPILED_SET_ID           PA_PLSQL_DATATYPES.IdTabTyp;
     L_RULE_PERCENTAGE               PA_PLSQL_DATATYPES.NumTabTyp;
     L_BILL_RATE                     PA_PLSQL_DATATYPES.NumTabTyp;
     L_BILL_MARKUP_PERCENTAGE        PA_PLSQL_DATATYPES.NumTabTyp;
     L_BASE_AMOUNT                   PA_PLSQL_DATATYPES.NumTabTyp;
     L_SCHEDULE_LINE_PERCENTAGE      PA_PLSQL_DATATYPES.NumTabTyp;
     L_ORIG_INV_NUM                  PA_PLSQL_DATATYPES.IdTabTyp;
     L_ORIG_INV_LINE_NUM             PA_PLSQL_DATATYPES.IdTabTyp;
     /* Added for cross proj*/
     L_TP_AMT_TYPE_CODE              PA_PLSQL_DATATYPES.Char30TabTyp;
     L_PROJECT_TP_RATE_TYPE          PA_PLSQL_DATATYPES.Char30TabTyp;
     L_PROJECT_TP_RATE_DATE          PA_PLSQL_DATATYPES.Char30TabTyp;
     L_PROJECT_TP_EXCHANGE_RATE      PA_PLSQL_DATATYPES.Char30TabTyp;
     L_PROJECT_TRANSFER_PRICE        PA_PLSQL_DATATYPES.Char30TabTyp;
     L_PROJFUNC_TP_RATE_TYPE         PA_PLSQL_DATATYPES.Char30TabTyp;
     L_PROJFUNC_TP_RATE_DATE         PA_PLSQL_DATATYPES.Char30TabTyp;
     L_PROJFUNC_TP_EXCHANGE_RATE     PA_PLSQL_DATATYPES.Char30TabTyp;
     L_PROJFUNC_TRANSFER_PRICE       PA_PLSQL_DATATYPES.Char30TabTyp;

     L_PROJECT_TP_CURRENCY_CODE      PA_PLSQL_DATATYPES.Char15TabTyp;
     L_PROJFUNC_TP_CURRENCY_CODE     PA_PLSQL_DATATYPES.Char15TabTyp;
     /* End for cross proj*/

/*  CBGA and Project Jobs */

     L_TP_JOB_ID                     PA_PLSQL_DATATYPES.IdTabTyp;
     L_PROV_PROJ_BILL_JOB_ID         PA_PLSQL_DATATYPES.IdTabTyp;

/* 1898341 P_rec_counter modified as in out parameter */
g1_debug_mode varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

PROCEDURE download ( P_inv_rec_tab         IN OUT NOCOPY inv_rec_tab,
                     P_rec_counter         IN OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                     P_download_mode           IN  VARCHAR2 )
IS
/*  Added two variable for bug 1898341  */
loop_inc NUMBER :=0;
local_expenditure_item_id NUMBER :=0;
BEGIN
  IF g1_debug_mode  = 'Y' THEN
  	PA_IC_INV_UTILS.log_message('In Download...');
  END IF;
  FOR I in 1..P_rec_counter
  LOOP
  /* Commenting for bug 5934390
  IF P_inv_rec_tab(I).BILL_AMOUNT <>0
    THEN  */
     /* Added loop_inc for bug 1898341*/
     loop_inc :=loop_inc+1;
     L_DETAIL_ID(loop_inc)
                                    := P_inv_rec_tab(I).DRAFT_INVOICE_DETAIL_ID;
     L_EXPENDITURE_ITEM_ID(loop_inc)          := P_inv_rec_tab(I).EXPENDITURE_ITEM_ID;
     L_LINE_NUM(loop_inc)                     := P_inv_rec_tab(I).LINE_NUM;
     L_PROJECT_ID(loop_inc)                   := P_inv_rec_tab(I).PROJECT_ID;
     L_INVOICED_FLAG(loop_inc)                := P_inv_rec_tab(I).INVOICED_FLAG;
     L_DENOM_CURRENCY_CODE(loop_inc)          := P_inv_rec_tab(I).DENOM_CURRENCY_CODE;
     L_DENOM_BILL_AMOUNT(loop_inc)            := P_inv_rec_tab(I).DENOM_BILL_AMOUNT;
     L_ACCT_CURRENCY_CODE(loop_inc)           := P_inv_rec_tab(I).ACCT_CURRENCY_CODE;
     L_BILL_AMOUNT(loop_inc)                  := P_inv_rec_tab(I).BILL_AMOUNT;
     L_ACCT_RATE_TYPE(loop_inc)               := P_inv_rec_tab(I).ACCT_RATE_TYPE;
     L_ACCT_RATE_DATE(loop_inc)
              := to_char(P_inv_rec_tab(I).ACCT_RATE_DATE,'DD-MM-YYYY');
     L_ACCT_EXCHANGE_RATE(loop_inc)           := P_inv_rec_tab(I).ACCT_EXCHANGE_RATE;
     L_CC_PROJECT_ID(loop_inc)                := P_inv_rec_tab(I).CC_PROJECT_ID;
     L_CC_TAX_TASK_ID(loop_inc)               := P_inv_rec_tab(I).CC_TAX_TASK_ID;
     L_ORG_ID(loop_inc)                       := P_inv_rec_tab(I).ORG_ID;
     L_REV_CODE_COMBINATION_ID(loop_inc)
                                  := P_inv_rec_tab(I).REV_CODE_COMBINATION_ID;
     L_DRAFT_INVOICE_NUM(loop_inc)            := P_inv_rec_tab(I).DRAFT_INVOICE_NUM;
     L_DRAFT_INVOICE_LINE_NUM(loop_inc)
                                  := P_inv_rec_tab(I).DRAFT_INVOICE_LINE_NUM;
     L_OUTPUT_VAT_TAX_ID(loop_inc)       := P_inv_rec_tab(I).OUTPUT_VAT_TAX_ID;
     L_OUTPUT_TAX_CODE(loop_inc)         := P_inv_rec_tab(I).OUTPUT_TAX_CLASSIFICATION_CODE;
     L_OUTPUT_TAX_EXEMPT_FLAG(loop_inc)
                                  := P_inv_rec_tab(I).OUTPUT_TAX_EXEMPT_FLAG;
     L_OUTPUT_EXEMPT_REASON_CODE(loop_inc)
                            := P_inv_rec_tab(I).OUTPUT_TAX_EXEMPT_REASON_CODE;
     L_OUTPUT_TAX_EXEMPT_NUMBER(loop_inc)
                            := P_inv_rec_tab(I).OUTPUT_TAX_EXEMPT_NUMBER;
     L_LINE_NUM_REVERSED(loop_inc)          := P_inv_rec_tab(I).LINE_NUM_REVERSED;
     L_DETAIL_ID_REVERSED(loop_inc)         := P_inv_rec_tab(I).DETAIL_ID_REVERSED;
     L_REVERSED_FLAG(loop_inc)              := P_inv_rec_tab(I).REVERSED_FLAG;
     L_MARKUP_CALC_BASE_CODE(loop_inc)      := P_inv_rec_tab(I).MARKUP_CALC_BASE_CODE;
     L_IND_COMPILED_SET_ID(loop_inc)        := P_inv_rec_tab(I).IND_COMPILED_SET_ID;
     L_RULE_PERCENTAGE(loop_inc)            := P_inv_rec_tab(I).RULE_PERCENTAGE;
     L_BILL_RATE(loop_inc)                  := P_inv_rec_tab(I).BILL_RATE;
     L_BILL_MARKUP_PERCENTAGE(loop_inc)     := P_inv_rec_tab(I).BILL_MARKUP_PERCENTAGE;
     L_BASE_AMOUNT(loop_inc)                := P_inv_rec_tab(I).BASE_AMOUNT;
     L_SCHEDULE_LINE_PERCENTAGE(loop_inc)
                                   := P_inv_rec_tab(I).SCHEDULE_LINE_PERCENTAGE;
     L_ORIG_INV_NUM(loop_inc)             := P_inv_rec_tab(I).ORIG_DRAFT_INVOICE_NUM;
     L_ORIG_INV_LINE_NUM(loop_inc)        := P_inv_rec_tab(I).ORIG_DRAFT_INVOICE_LINE_NUM;

     /* Added for cross proj*/
     L_TP_AMT_TYPE_CODE(loop_inc)          := P_inv_rec_tab(I).TP_AMT_TYPE_CODE;
     L_PROJECT_TP_RATE_TYPE(loop_inc)      := P_inv_rec_tab(I).PROJECT_TP_RATE_TYPE;
     L_PROJECT_TP_RATE_DATE(loop_inc)      := P_inv_rec_tab(I).PROJECT_TP_RATE_DATE;
     L_PROJECT_TP_EXCHANGE_RATE(loop_inc)  := P_inv_rec_tab(I).PROJECT_TP_EXCHANGE_RATE;
     L_PROJECT_TRANSFER_PRICE(loop_inc)    := P_inv_rec_tab(I).PROJECT_TRANSFER_PRICE;

     L_PROJFUNC_TP_RATE_TYPE(loop_inc)      := P_inv_rec_tab(I).PROJFUNC_TP_RATE_TYPE;
     L_PROJFUNC_TP_RATE_DATE(loop_inc)      := P_inv_rec_tab(I).PROJFUNC_TP_RATE_DATE;
     L_PROJFUNC_TP_EXCHANGE_RATE(loop_inc)  := P_inv_rec_tab(I).PROJFUNC_TP_EXCHANGE_RATE;
     L_PROJFUNC_TRANSFER_PRICE(loop_inc)    := P_inv_rec_tab(I).PROJFUNC_TRANSFER_PRICE;

     L_PROJECT_TP_CURRENCY_CODE(loop_inc)   := P_inv_rec_tab(I).PROJECT_TP_CURRENCY_CODE;
     L_PROJFUNC_TP_CURRENCY_CODE(loop_inc)  := P_inv_rec_tab(I).PROJFUNC_TP_CURRENCY_CODE;
     /* End for cross proj*/

/*   CBGA and project Jobs */

     L_TP_JOB_ID(loop_inc)                := P_inv_rec_tab(I).TP_JOB_ID;
     L_PROV_PROJ_BILL_JOB_ID(loop_inc)    := P_inv_rec_tab(I).PROV_PROJ_BILL_JOB_ID;

/* Added for bug 1898341*/
 /* ELSE commented for 	5934390 */
/* Added If condition for  5934390 */
IF P_inv_rec_tab(I).BILL_AMOUNT = 0
    THEN
/* End of code change for 5934390 */

    IF g1_debug_mode  = 'Y' THEN
    	PA_IC_INV_UTILS.log_message('download: ' || 'Within Else of down function..'||to_char(I));
    END IF;
    local_expenditure_item_id :=  P_inv_rec_tab(I).EXPENDITURE_ITEM_ID;
    IF g1_debug_mode  = 'Y' THEN
    	PA_IC_INV_UTILS.log_message('download: ' || 'Exp item id ..'||local_expenditure_item_id);
    END IF;

     UPDATE PA_EXPENDITURE_ITEMS
	SET CC_IC_PROCESSED_CODE ='X'
     WHERE EXPENDITURE_ITEM_ID = local_expenditure_item_id;
  END IF;
   /* End of commnet for bug 1898341*/

     IF g1_debug_mode  = 'Y' THEN
     	PA_IC_INV_UTILS.log_message('download: ' || 'Complete Init...'||to_char(I));
     END IF;
 END LOOP;
 /*Added for bug 1898341 */
  P_rec_counter := loop_inc;
EXCEPTION
 WHEN others
 then
      raise;

END download;

PROCEDURE Insert_rows
           ( P_inv_rec_tab                 IN OUT NOCOPY  inv_rec_tab)
IS
temp_G_Ins_count NUMBER :=0;   /* Added for bug 2739218 */

BEGIN

 IF g1_debug_mode  = 'Y' THEN
 	PA_IC_INV_UTILS.log_message('Insert_rows: ' || 'In Insert...');
        PA_IC_INV_UTILS.log_message('Insert_rows: G_Ins_count '|| to_char(G_Ins_count));
 END IF;

temp_G_Ins_count := G_Ins_count;   /* Added for bug2739218 */

 If ( G_Ins_count > 0 )
 Then

IF g1_debug_mode  = 'Y' THEN
PA_IC_INV_UTILS.log_message('Insert_rows: Before calling download G_Ins_count' || to_char(G_Ins_count));
END IF;

 download(P_inv_rec_tab,G_Ins_count,'I');

IF g1_debug_mode  = 'Y' THEN
PA_IC_INV_UTILS.log_message('Insert_rows: After calling download G_Ins_count '|| to_char(G_Ins_count));
END IF;

 IF g1_debug_mode  = 'Y' THEN
 	PA_IC_INV_UTILS.log_message('Insert_rows: ' || 'In Insert...'|| to_char(G_Ins_count));
 END IF;

 FORALL I IN 1..G_Ins_count
  INSERT INTO PA_DRAFT_INVOICE_DETAILS
   ( DRAFT_INVOICE_DETAIL_ID,
     EXPENDITURE_ITEM_ID,
     LINE_NUM,
     PROJECT_ID,
     INVOICED_FLAG,
     DENOM_CURRENCY_CODE,
     DENOM_BILL_AMOUNT,
     ACCT_CURRENCY_CODE,
     BILL_AMOUNT,
     REQUEST_ID,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_LOGIN,
     ACCT_RATE_TYPE,
     ACCT_RATE_DATE,
     ACCT_EXCHANGE_RATE,
     CC_PROJECT_ID,
     CC_TAX_TASK_ID,
     ORG_ID,
     REV_CODE_COMBINATION_ID,
     DRAFT_INVOICE_NUM,
     DRAFT_INVOICE_LINE_NUM,
     OUTPUT_VAT_TAX_ID,
     OUTPUT_TAX_CLASSIFICATION_CODE,
     OUTPUT_TAX_EXEMPT_FLAG,
     OUTPUT_TAX_EXEMPT_REASON_CODE,
     OUTPUT_TAX_EXEMPT_NUMBER,
     LINE_NUM_REVERSED,
     DETAIL_ID_REVERSED,
     REVERSED_FLAG,
     MARKUP_CALC_BASE_CODE,
     IND_COMPILED_SET_ID,
     RULE_PERCENTAGE,
     BILL_RATE,
     BILL_MARKUP_PERCENTAGE,
     BASE_AMOUNT,
     SCHEDULE_LINE_PERCENTAGE,
     ORIG_DRAFT_INVOICE_NUM,
     ORIG_DRAFT_INVOICE_LINE_NUM,
     PROGRAM_APPLICATION_ID,
     PROGRAM_ID,
     PROGRAM_UPDATE_DATE,
     TP_JOB_ID,
     PROV_PROJ_BILL_JOB_ID,
     /* Added for cross proj*/
      TP_AMT_TYPE_CODE,
      PROJECT_TP_RATE_TYPE,
      PROJECT_TP_RATE_DATE,
      PROJECT_TP_EXCHANGE_RATE,
      PROJECT_TRANSFER_PRICE,
      PROJFUNC_TP_RATE_TYPE,
      PROJFUNC_TP_RATE_DATE,
      PROJFUNC_TP_EXCHANGE_RATE,
      PROJFUNC_TRANSFER_PRICE,

      PROJECT_TP_CURRENCY_CODE,
      PROJFUNC_TP_CURRENCY_CODE
      /* End for cross proj*/
   )
  VALUES
  (  L_DETAIL_ID(I),
     L_EXPENDITURE_ITEM_ID(I),
     L_LINE_NUM(I),
     L_PROJECT_ID(I),
     L_INVOICED_FLAG(I),
     L_DENOM_CURRENCY_CODE(I),
     L_DENOM_BILL_AMOUNT(I),
     L_ACCT_CURRENCY_CODE(I),
     L_BILL_AMOUNT(I),
     PA_IC_INV_UTILS.G_REQUEST_ID,
     SYSDATE,
     PA_IC_INV_UTILS.G_LAST_UPDATED_BY,
     SYSDATE,
     PA_IC_INV_UTILS.G_CREATED_BY,
     PA_IC_INV_UTILS.G_LAST_UPDATE_LOGIN,
     L_ACCT_RATE_TYPE(I),
     to_date(L_ACCT_RATE_DATE(I),'DD-MM-YYYY'),
     L_ACCT_EXCHANGE_RATE(I),
     L_CC_PROJECT_ID(I),
     L_CC_TAX_TASK_ID(I),
     L_ORG_ID(I),
     L_REV_CODE_COMBINATION_ID(I),
     L_DRAFT_INVOICE_NUM(I),
     L_DRAFT_INVOICE_LINE_NUM(I),
     L_OUTPUT_VAT_TAX_ID(I),
     L_OUTPUT_TAX_CODE(I),
     L_OUTPUT_TAX_EXEMPT_FLAG(I),
     L_OUTPUT_EXEMPT_REASON_CODE(I),
     L_OUTPUT_TAX_EXEMPT_NUMBER(I),
     L_LINE_NUM_REVERSED(I),
     L_DETAIL_ID_REVERSED(I),
     L_REVERSED_FLAG(I),
     L_MARKUP_CALC_BASE_CODE(I),
     L_IND_COMPILED_SET_ID(I),
     L_RULE_PERCENTAGE(I),
     L_BILL_RATE(I),
     L_BILL_MARKUP_PERCENTAGE(I),
     L_BASE_AMOUNT(I),
     L_SCHEDULE_LINE_PERCENTAGE(I),
     L_ORIG_INV_NUM(I),
     L_ORIG_INV_LINE_NUM(I),
     PA_IC_INV_UTILS.G_PROGRAM_APPLICATION_ID,
     PA_IC_INV_UTILS.G_PROGRAM_ID,
     SYSDATE,
     L_TP_JOB_ID(I),
     L_PROV_PROJ_BILL_JOB_ID(I),
 /* Added for cross proj*/
    L_TP_AMT_TYPE_CODE(i),
    L_PROJECT_TP_RATE_TYPE(i),
    L_PROJECT_TP_RATE_DATE(i),
    L_PROJECT_TP_EXCHANGE_RATE(i),
    L_PROJECT_TRANSFER_PRICE(i),
    L_PROJFUNC_TP_RATE_TYPE(i),
    L_PROJFUNC_TP_RATE_DATE(i),
    L_PROJFUNC_TP_EXCHANGE_RATE(i),
    L_PROJFUNC_TRANSFER_PRICE(i),

    L_PROJECT_TP_CURRENCY_CODE(i),
    L_PROJFUNC_TP_CURRENCY_CODE(i)
/* End for cross proj*/
);

G_Ins_count:= temp_G_Ins_count; /* Added for bug 2739218 */

-- Call MRC Hook

 End if;
EXCEPTION
 WHEN OTHERS
 THEN
  IF g1_debug_mode  = 'Y' THEN
  	PA_IC_INV_UTILS.log_message('Insert_rows: ' || 'Error In Insert...');
  END IF;
  Raise;

END Insert_rows;

PROCEDURE Update_rows
           ( P_inv_rec_tab        IN OUT NOCOPY  inv_rec_tab,
             P_mrc_reqd_flag      IN   PA_PLSQL_DATATYPES.Char1TabTyp)
IS
BEGIN

 IF g1_debug_mode  = 'Y' THEN
 	PA_IC_INV_UTILS.log_message('Update_rows: ' || 'In Update...');
 END IF;
 If ( G_Upd_count > 0)
 Then
   download(P_inv_rec_tab,G_Upd_count,'U');

   FORALL I IN 1..G_Upd_count
    Update PA_DRAFT_INVOICE_DETAILS
    Set
     DENOM_CURRENCY_CODE = L_DENOM_CURRENCY_CODE(I),
     DENOM_BILL_AMOUNT   = L_DENOM_BILL_AMOUNT(I),
     ACCT_CURRENCY_CODE  = L_ACCT_CURRENCY_CODE(I),
     BILL_AMOUNT         = L_BILL_AMOUNT(I),
     REQUEST_ID          = PA_IC_INV_UTILS.G_REQUEST_ID,
     LAST_UPDATE_DATE    = SYSDATE,
     LAST_UPDATED_BY     = PA_IC_INV_UTILS.G_LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN   = PA_IC_INV_UTILS.G_LAST_UPDATE_LOGIN,
     ACCT_RATE_TYPE      = L_ACCT_RATE_TYPE(I),
     ACCT_RATE_DATE      = to_date(L_ACCT_RATE_DATE(I),'DD-MM-YYYY'),
     ACCT_EXCHANGE_RATE  = L_ACCT_EXCHANGE_RATE(I),
     REV_CODE_COMBINATION_ID = L_REV_CODE_COMBINATION_ID(I),
     OUTPUT_VAT_TAX_ID   = L_OUTPUT_VAT_TAX_ID(I),
     OUTPUT_TAX_CLASSIFICATION_CODE = L_OUTPUT_TAX_CODE(I),
     OUTPUT_TAX_EXEMPT_FLAG = L_OUTPUT_TAX_EXEMPT_FLAG(I),
     OUTPUT_TAX_EXEMPT_REASON_CODE
                         = L_OUTPUT_EXEMPT_REASON_CODE(I),
     OUTPUT_TAX_EXEMPT_NUMBER
                         = L_OUTPUT_TAX_EXEMPT_NUMBER(I),
     LINE_NUM_REVERSED   = L_LINE_NUM_REVERSED(I),
     DETAIL_ID_REVERSED  = L_DETAIL_ID_REVERSED(I),
     REVERSED_FLAG       = L_REVERSED_FLAG(I),
     MARKUP_CALC_BASE_CODE = L_MARKUP_CALC_BASE_CODE(I),
     IND_COMPILED_SET_ID   = L_IND_COMPILED_SET_ID(I),
     RULE_PERCENTAGE       = L_RULE_PERCENTAGE(I),
     BILL_RATE             = L_BILL_RATE(I),
     BILL_MARKUP_PERCENTAGE= L_BILL_MARKUP_PERCENTAGE(I),
     BASE_AMOUNT           = L_BASE_AMOUNT(I),
     SCHEDULE_LINE_PERCENTAGE = L_SCHEDULE_LINE_PERCENTAGE(I),
     PROGRAM_APPLICATION_ID   = PA_IC_INV_UTILS.G_PROGRAM_APPLICATION_ID,
     PROGRAM_ID               = PA_IC_INV_UTILS.G_PROGRAM_ID,
     PROGRAM_UPDATE_DATE      = SYSDATE,
     TP_JOB_ID                = L_TP_JOB_ID(I),
     PROV_PROJ_BILL_JOB_ID    = L_PROV_PROJ_BILL_JOB_ID(I),
     /*Cross proj*/
     TP_AMT_TYPE_CODE         = L_TP_AMT_TYPE_CODE(I),
     PROJECT_TP_RATE_TYPE   =  L_PROJECT_TP_RATE_TYPE(I),
     PROJECT_TP_RATE_DATE    =  L_PROJECT_TP_RATE_DATE(I),
     PROJECT_TP_EXCHANGE_RATE=  L_PROJECT_TP_EXCHANGE_RATE(I),
     PROJECT_TRANSFER_PRICE  =  L_PROJECT_TRANSFER_PRICE(I),
     PROJFUNC_TP_RATE_TYPE   =  L_PROJFUNC_TP_RATE_TYPE(I),
     PROJFUNC_TP_RATE_DATE   =  L_PROJFUNC_TP_RATE_DATE(I),
     PROJFUNC_TP_EXCHANGE_RATE= L_PROJFUNC_TP_EXCHANGE_RATE(I),
     PROJFUNC_TRANSFER_PRICE  = L_PROJFUNC_TRANSFER_PRICE(I),

     PROJECT_TP_CURRENCY_CODE = L_PROJECT_TP_CURRENCY_CODE(I),
     PROJFUNC_TP_CURRENCY_CODE= L_PROJFUNC_TP_CURRENCY_CODE(I)
     /*Cross proj*/
    Where EXPENDITURE_ITEM_ID = L_EXPENDITURE_ITEM_ID(I)
      AND LINE_NUM = L_LINE_NUM(I);


    /* Code added for Bug No 5284823 */
   FORALL I IN 1..G_Upd_count
     Update
       PA_DRAFT_INVOICE_DETAILS
     Set
       REQUEST_ID          = PA_IC_INV_UTILS.G_REQUEST_ID
     where
       EXPENDITURE_ITEM_ID = L_EXPENDITURE_ITEM_ID(I) and
       DETAIL_ID_REVERSED is NOT NULL                 and
       INVOICED_FLAG = 'N';
   /*Code added for Bug No 5284823 ends here */

-- Call MRC Hook

 End if;

EXCEPTION
 WHEN OTHERS
 THEN
    Raise;

END Update_rows;

PROCEDURE Delete_rows
           ( P_inv_rec_tab                  IN OUT NOCOPY  inv_rec_tab)
IS
BEGIN

 IF g1_debug_mode  = 'Y' THEN
 	PA_IC_INV_UTILS.log_message('Delete_rows: ' || 'In Delete...');
 END IF;
 If ( G_Del_count > 0)
 Then
  download(P_inv_rec_tab,G_Del_count,'U');

  FORALL I IN 1..G_Del_count
   Delete
   From  PA_DRAFT_INVOICE_DETAILS
   Where EXPENDITURE_ITEM_ID = L_EXPENDITURE_ITEM_ID(I)
   AND   LINE_NUM            = L_LINE_NUM(I);

  FORALL I IN 1..G_Del_count
   UPDATE PA_EXPENDITURE_ITEMS
   SET    DENOM_TP_CURRENCY_CODE      = NULL,
          DENOM_TRANSFER_PRICE        = NULL,
          ACCT_TP_RATE_TYPE           = NULL,
          ACCT_TP_RATE_DATE           = NULL,
          ACCT_TP_EXCHANGE_RATE       = NULL,
          ACCT_TRANSFER_PRICE         = NULL,
          PROJACCT_TRANSFER_PRICE     = NULL,
          CC_MARKUP_BASE_CODE         = NULL,
          TP_BASE_AMOUNT              = NULL,
          TP_IND_COMPILED_SET_ID      = NULL,
          TP_BILL_RATE                = NULL,
          TP_BILL_MARKUP_PERCENTAGE   = NULL,
          TP_SCHEDULE_LINE_PERCENTAGE = NULL,
          TP_RULE_PERCENTAGE          = NULL,
          TP_JOB_ID                   = NULL,
         /*Cross proj*/
          PROJECT_TRANSFER_PRICE  =  NULL,
          PROJFUNC_TRANSFER_PRICE  = NULL,
        /*Cross proj*/
          PROV_PROJ_BILL_JOB_ID       = NULL
   WHERE  EXPENDITURE_ITEM_ID = L_EXPENDITURE_ITEM_ID(I);

-- Call MRC Hook

 End if;

EXCEPTION
 WHEN OTHERS
 THEN
    Raise;

END Delete_rows;

END PA_INVOICE_DETAIL_PKG;

/
