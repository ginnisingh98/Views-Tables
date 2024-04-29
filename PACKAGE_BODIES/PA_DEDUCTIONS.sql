--------------------------------------------------------
--  DDL for Package Body PA_DEDUCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_DEDUCTIONS" AS
-- /* $Header: PADCTNSB.pls 120.6.12010000.10 2010/03/29 13:44:32 sesingh noship $

  TYPE g_dctn_hdr_amt IS RECORD (
             p_dctn_hdr_id  NUMBER,
             p_total_amount NUMBER);

  TYPE g_dctn_hdrtbl_amt IS TABLE OF g_dctn_hdr_amt INDEX BY BINARY_INTEGER;

  g_api_name      VARCHAR2(30);
  P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

  -- This procedure is for logging debug messages so as to debug the code
  -- in case of any unknown issues that occur during the entire cycle of
  -- a deduction request.

  Procedure log_message (p_log_msg IN VARCHAR2,p_proc_name VARCHAR2)  ;


  -- This procedure is to backout the interface table data in case of
  -- any issues during the payables import process.

  Procedure Delete_Failed_Rec(p_dctn_req_id NUMBER);


  -- This function verifies if the debit memo number has been provided by user
  -- and if not, it calls client extension to generate the debit memo number.
  -- If the client extension does not return any value, this function generates
  -- and returns a unique sequence number which does not exists in the system.

  Function Validate_DM( p_dctn_hdr       IN OUT NOCOPY g_dctn_hdrtbl
                       ,p_msg_count      OUT NOCOPY NUMBER
                       ,p_msg_data       OUT NOCOPY VARCHAR2
                       ,p_return_status  OUT NOCOPY VARCHAR2) Return Boolean;


  -- This procedure is to accept the error codes and token values so as to push
  -- any error to stack. This is being called from various procedures to store
  -- error messages in error stack.

  Procedure AddError_To_Stack( p_error_code VARCHAR2
                              ,p_hdr_or_txn VARCHAR2 := 'H' -- H->Header, D->Detail
                              ,p_token1_val VARCHAR2 :=''
                              ,p_token2_val VARCHAR2 :=''
                              ,p_token3_val VARCHAR2 :=''
                              ,p_token4_val VARCHAR2 :='');

  -- This procedure is to create entry into ap_invoices_interface table.
  Procedure Create_Invoice_Header (
        p_deduction_req_id       IN  NUMBER
       ,p_invoice_id             IN  NUMBER
       ,p_invoice_num            IN  VARCHAR2
       ,p_invoice_date           IN  DATE
       ,p_vendor_id              IN  NUMBER
       ,p_vendor_site_id         IN  NUMBER
       ,p_invoice_amount         IN  NUMBER
       ,p_invoice_currency_code  IN  VARCHAR2
       ,p_exchange_rate          IN  NUMBER
       ,p_exchange_rate_type     IN  VARCHAR2
       ,p_exchange_date          IN  DATE
       ,p_description            IN  VARCHAR2
       ,p_tax_flag               IN  VARCHAR2
       ,p_org_id                 IN  NUMBER );

  -- This procedure is to create entries into ap_invoice_lines_interface
  Procedure Create_Invoice_Line (
        p_invoice_id            IN  NUMBER
       ,p_amount                IN  NUMBER
       ,p_accounting_date       IN  DATE
       ,p_project_id            IN  NUMBER
       ,p_task_id               IN  NUMBER
       ,p_expenditure_item_date IN  DATE
       ,p_expenditure_type      IN  VARCHAR2
       ,p_expenditure_org       IN  NUMBER
       ,p_project_acct_context  IN  VARCHAR2
       ,p_description           IN  VARCHAR2
       ,p_qty_invoiced          IN  NUMBER
       ,p_org_id                IN  NUMBER );

  -- This procedure is to initiate the import process for the specific
  -- debit memo on successful creation of data in ap interface tables.
 /* Bug 8740525 sosharma commented and moved to specification
 Procedure Import_DebitMemo(p_dctn_req_id NUMBER
                            ,p_msg_count OUT NOCOPY NUMBER
                            ,p_msg_data  OUT NOCOPY VARCHAR2
                            ,p_return_status OUT NOCOPY VARCHAR2
                            );*/

  -- This procedure is to update the deduction request document status
  -- in the whole cycle of creation of a deduction request to the creation
  -- debit memo for that deduction request in payables.
  Procedure Update_Deduction_Status(p_dctn_hdr_id IN PA_DEDUCTIONS_ALL.deduction_req_id%TYPE,
                                    p_status      IN VARCHAR2);

  /*---------------------------------------------------------------------------------------------------------
    -- This procedure populates PA_DEDUCTIONS_ALL table after validating the data.
    -- Input parameters
    -- Parameters                Type           Required  Description
    --  p_dctn_hdr               TABLE          YES       It stores the deduction header information
    -- Out parameters
    -- Parameters                Type           Required  Description
    --  p_return_status          VARCHAR2       YES       The return status of the APIs.
    --                                                    Valid values are:
    --                                                    S (API completed successfully),
    --                                                    E (business rule violation error) and
    --                                                    U(Unexpected error, such as an Oracle error.
    --  p_msg_count              NUMBER         YES       Holds the number of messages in the global message
                                                          table. Calling programs should use this as the
                                                          basis to fetch all the stored messages.
    --  p_msg_data               VARCHAR2       YES       Holds the message code, if the API returned only
                                                          one error/warning message Otherwise the column is
                                                          left blank.
    --  p_calling_mode           VARCHAR2       YES       Holds whether the call is being made from public
                                                          API or from the create deductions page. This is to
                                                          enforce additional validations in case if this is
                                                          called from Public API.
  ----------------------------------------------------------------------------------------------------------*/
  Procedure Create_Deduction_Hdr(p_dctn_hdr      IN OUT NOCOPY g_dctn_hdrtbl,
                                 p_msg_count     OUT NOCOPY  NUMBER,
                                 p_msg_data      OUT NOCOPY  VARCHAR2,
                                 p_return_status OUT NOCOPY  VARCHAR2,
                                 p_calling_mode  IN          VARCHAR2) Is

  INVALID_DATA EXCEPTION;
  PRAGMA EXCEPTION_INIT(INVALID_DATA,-20001);

  l_dctn_hdr   g_dctn_hdrtbl;

  CURSOR C1(ded_id IN NUMBER) is
  select 'Y' from dual where not exists(select 1 from pa_deductions_all
  where deduction_req_id=ded_id);

  notexist VARCHAR2(1);

  Begin

     g_api_name := 'Create_Deduction_Hdr';

     IF P_DEBUG_MODE = 'Y' THEN
      log_message ('In Create deduction header procedure', g_api_name);
     END IF;

     p_return_status :='S';
     l_dctn_hdr.delete;
     FND_MSG_PUB.initialize;

     For i In 1..p_dctn_hdr.COUNT Loop
       l_dctn_hdr(i) := p_dctn_hdr(i);

       IF P_DEBUG_MODE = 'Y' THEN
         log_message ('Before calling validate header proc: '||l_dctn_hdr(i).deduction_req_id,
                      g_api_name);
       END IF;

OPEN C1(p_dctn_hdr(i).deduction_req_id);
FETCH C1 INTO notexist;
CLOSE C1;

IF notexist = 'Y' THEN
       If Validate_Deduction_Hdr(l_Dctn_Hdr,P_msg_count, p_msg_data,p_return_status) Then
         p_dctn_hdr(i) := l_Dctn_Hdr(i);

         IF P_DEBUG_MODE = 'Y' THEN
           log_message ('Before inserting into header', g_api_name);
         END IF;

         INSERT INTO PA_DEDUCTIONS_ALL(
                        deduction_req_id
                       ,project_id
                       ,vendor_id
                       ,vendor_site_id
                       ,change_doc_num
                       ,change_doc_type
                       ,ci_id
                       ,po_number
                       ,po_header_id
                       ,deduction_req_num
                       ,debit_memo_num
                       ,currency_code
                       ,conversion_ratetype
                       ,conversion_ratedate
                       ,conversion_rate
                       ,total_amount
                       ,total_pfc_amount
                       ,deduction_req_date
                       ,debit_memo_date
                       ,description
                       ,status
                       ,document_type
                       ,org_id
                       ,creation_date
                       ,created_by        )
                   SELECT
                       p_dctn_hdr(i).deduction_req_id
                      ,p_dctn_hdr(i).project_id
                      ,p_dctn_hdr(i).vendor_id
                      ,p_dctn_hdr(i).vendor_site_id
                      ,p_dctn_hdr(i).change_doc_num
                      ,p_dctn_hdr(i).change_doc_type
                      ,p_dctn_hdr(i).ci_id
                      ,p_dctn_hdr(i).po_number
                      ,p_dctn_hdr(i).po_header_id
                      ,p_dctn_hdr(i).deduction_req_num
                      ,p_dctn_hdr(i).debit_memo_num
                      ,p_dctn_hdr(i).currency_code
                      ,p_dctn_hdr(i).conversion_ratetype
                      ,p_dctn_hdr(i).conversion_ratedate
                      ,p_dctn_hdr(i).conversion_rate
                      ,0
                      ,0
                      ,p_dctn_hdr(i).deduction_req_date
                      ,p_dctn_hdr(i).debit_memo_date
                      ,p_dctn_hdr(i).description
                      ,p_dctn_hdr(i).status
                      ,DECODE(p_dctn_hdr(i).ci_id, NULL,'M','C')
                      ,p_dctn_hdr(i).org_id
                      ,SYSDATE
                      ,g_user_id FROM DUAL;
           p_return_status :='S';
       End If;
     END IF;
     End Loop;
  EXCEPTION
    WHEN OTHERS THEN
         p_msg_count:=1;
         p_msg_data:=SQLERRM;
         p_return_status := 'U';
  End;

  /*---------------------------------------------------------------------------------------------------------
    -- This procedure populates PA_DEDUCTION_TRANSACTIONS_ALL table after validating the data.
    -- Input parameters
    -- Parameters                Type           Required  Description
    --  p_dctn_dtl               TABLE          YES       It stores the deduction transactions information
    -- Out parameters
    -- Parameters                Type           Required  Description
    --  p_return_status          VARCHAR2       YES       The return status of the APIs.
    --                                                    Valid values are:
    --                                                    S (API completed successfully),
    --                                                    E (business rule violation error) and
    --                                                    U(Unexpected error, such as an Oracle error.
    --  p_msg_count              NUMBER         YES       Holds the number of messages in the global message
                                                          table. Calling programs should use this as the
                                                          basis to fetch all the stored messages.
    --  p_msg_data               VARCHAR2       YES       Holds the message code, if the API returned only
                                                          one error/warning message Otherwise the column is
                                                          left blank.
    --  p_calling_mode           VARCHAR2       YES       Holds whether the call is being made from public
                                                          API or from the create deductions page. This is to
                                                          enforce additional validations in case if this is
                                                          called from Public API.
  ----------------------------------------------------------------------------------------------------------*/
  Procedure Create_Deduction_Txn(p_dctn_dtl      IN OUT NOCOPY g_dctn_txntbl,
                                 p_msg_count     OUT NOCOPY	NUMBER,
                                 p_msg_data	     OUT NOCOPY VARCHAR2,
                                 p_return_status OUT NOCOPY VARCHAR2,
                                 p_calling_mode  IN         VARCHAR2) Is
    INVALID_DATA EXCEPTION ;
    PRAGMA EXCEPTION_INIT(INVALID_DATA,-20001);

    l_dctn_hdrtbl g_dctn_hdrtbl_amt;
    l_dctn_hdrcnt NUMBER :=0;
    l_dctn_hdrfnd VARCHAR2(1) :='N';
    l_dctn_hdrid  NUMBER;
    l_rec_no      NUMBER;
    l_dctn_tbl_hdrid  g_dctn_hdrid; --Bug# 8877035

  Begin

   g_api_name := 'Create_Deduction_Txn';

   IF P_DEBUG_MODE = 'Y' THEN
      log_message ('In Create deduction transaction ', g_api_name);
   END IF;

   p_return_status :='S';
   FND_MSG_PUB.initialize;

   IF P_DEBUG_MODE = 'Y' THEN
     log_message ('Before calling validate detail transaction', g_api_name);
   END IF;

   IF p_dctn_dtl.COUNT >0 THEN
    If Validate_Deduction_Txn(P_Dctn_Dtl,P_msg_count, p_msg_data,p_return_status) Then
     IF p_msg_data IS NULL THEN
        For i In p_dctn_dtl.FIRST..p_dctn_dtl.LAST Loop

         IF l_dctn_hdrcnt = 0 THEN
            l_dctn_hdrcnt := l_dctn_hdrcnt +1;
            l_dctn_hdrid  := p_dctn_dtl(i).deduction_req_id;
            l_dctn_hdrtbl(l_dctn_hdrcnt).p_dctn_hdr_id := p_dctn_dtl(i).deduction_req_id;
            l_dctn_tbl_hdrid(l_dctn_hdrcnt) := p_dctn_dtl(i).deduction_req_id; --Bug# 8877035
            l_dctn_hdrtbl(l_dctn_hdrcnt).p_total_amount :=0;
         ELSE
           IF nvl(l_dctn_hdrid,-99) <> p_dctn_dtl(i).deduction_req_id THEN
              l_dctn_hdrid  := p_dctn_dtl(i).deduction_req_id;
              l_dctn_hdrfnd := 'N';
              l_rec_no := 0;
               FOR J in 1..l_dctn_hdrtbl.COUNT LOOP
               IF l_dctn_hdrtbl(J).p_dctn_hdr_id = p_dctn_dtl(i).deduction_req_id THEN
                 l_dctn_hdrfnd := 'Y';
                 l_rec_no := J;
                 EXIT;
               END IF; END LOOP;
               IF l_dctn_hdrfnd = 'N' THEN
                  l_dctn_hdrcnt := l_dctn_hdrcnt +1;
                  l_dctn_hdrtbl(l_dctn_hdrcnt).p_dctn_hdr_id := p_dctn_dtl(i).deduction_req_id;
                  l_dctn_tbl_hdrid(l_dctn_hdrcnt) := p_dctn_dtl(i).deduction_req_id; --Bug# 8877035
                  l_dctn_hdrtbl(l_dctn_hdrcnt).p_total_amount :=0;
               END IF;
           END IF;
         END IF;

         IF P_DEBUG_MODE = 'Y' THEN
            log_message ('Before inserting into deduction transaction ', g_api_name);
         END IF;

         INSERT INTO PA_DEDUCTION_TRANSACTIONS_ALL (
                      deduction_req_id
                     ,deduction_req_tran_id
                     ,project_id
                     ,task_id
                     ,expenditure_type
                     ,expenditure_org_id
                     ,quantity
                     ,override_quantity
                     ,expenditure_item_id
                     ,projfunc_currency_code
                     ,orig_projfunc_amount
                     ,override_projfunc_amount
                     ,conversion_ratetype
                     ,conversion_ratedate
                     ,conversion_rate
                     ,amount
                     ,expenditure_item_date
                     ,gl_date
                     ,creation_date
                     ,created_by
                     ,description
                     )
                  SELECT
                      p_dctn_dtl(i).deduction_req_id
                     ,PA_DEDUCTION_TXNS_S.nextval
                     ,p_dctn_dtl(i).project_id
                     ,p_dctn_dtl(i).task_id
                     ,p_dctn_dtl(i).expenditure_type
                     ,p_dctn_dtl(i).expenditure_org_id
                     ,p_dctn_dtl(i).quantity
                     ,nvl(p_dctn_dtl(i).override_quantity,p_dctn_dtl(i).quantity)
                     ,p_dctn_dtl(i).expenditure_item_id
                     ,p_dctn_dtl(i).projfunc_currency_code
                     ,p_dctn_dtl(i).orig_projfunc_amount
                     ,nvl(p_dctn_dtl(i).override_projfunc_amount,p_dctn_dtl(i).orig_projfunc_amount)
                     ,p_dctn_dtl(i).conversion_ratetype
                     ,p_dctn_dtl(i).conversion_ratedate
                     ,p_dctn_dtl(i).conversion_rate
                     ,p_dctn_dtl(i).amount
                     ,p_dctn_dtl(i).expenditure_item_date
                     ,p_dctn_dtl(i).expenditure_item_date
                     ,SYSDATE
                     ,g_user_id
                     ,p_dctn_dtl(i).description FROM DUAL WHERE p_dctn_dtl(i).status IS NULL;

        End Loop;

       IF P_DEBUG_MODE = 'Y' THEN
         log_message ('Before updating the total amount on header ', g_api_name);
       END IF;

        /* Bug#8877035, used pl/sql table of column type instead of record type
           to aviod the restrictions in 10g, 9i databases */

        FORALL I in 1..l_dctn_tbl_hdrid.COUNT --l_dctn_hdrtbl.COUNT
        UPDATE PA_DEDUCTIONS_ALL SET total_amount = nvl((
                                 SELECT SUM(amount) FROM
                                 PA_DEDUCTION_TRANSACTIONS_ALL
                                 WHERE deduction_req_id = l_dctn_tbl_hdrid(i) --l_dctn_hdrtbl(i).p_dctn_hdr_id
                                  ),0) ,
                                     total_pfc_amount = nvl((
                                        SELECT
                                      SUM(nvl(override_projfunc_amount,orig_projfunc_amount)) FROM
                                     PA_DEDUCTION_TRANSACTIONS_ALL
                                     WHERE deduction_req_id = l_dctn_tbl_hdrid(i)
                                  ),0)
        WHERE deduction_req_id = l_dctn_tbl_hdrid(i);--l_dctn_hdrtbl(i).p_dctn_hdr_id;

        p_return_status :='S';
     END IF;
    End If;
   END IF;
  EXCEPTION
    WHEN OTHERS THEN
         IF P_DEBUG_MODE = 'Y' THEN
           log_message ('In Others Exception: '||SQLERRM, g_api_name);
         END IF;

         p_msg_count:=1;
         p_msg_data:=SQLERRM;
         p_return_status := 'U';
  End;

  /*---------------------------------------------------------------------------------------------------------
    -- This procedure is to update existing data in PA_DEDUCTIONS_ALL table after validating the data.
    -- Input parameters
    -- Parameters                Type           Required  Description
    --  p_dctn_hdr               TABLE          YES       It stores the deduction header information
    -- Out parameters
    -- Parameters                Type           Required  Description
    --  p_return_status          VARCHAR2       YES       The return status of the APIs.
    --                                                    Valid values are:
    --                                                    S (API completed successfully),
    --                                                    E (business rule violation error) and
    --                                                    U(Unexpected error, such as an Oracle error.
    --  p_msg_count              NUMBER         YES       Holds the number of messages in the global message
                                                          table. Calling programs should use this as the
                                                          basis to fetch all the stored messages.
    --  p_msg_data               VARCHAR2       YES       Holds the message code, if the API returned only
                                                          one error/warning message Otherwise the column is
                                                          left blank.
    --  p_calling_mode           VARCHAR2       YES       Holds whether the call is being made from public
                                                          API or from the create deductions page. This is to
                                                          enforce additional validations in case if this is
                                                          called from Public API.
  ----------------------------------------------------------------------------------------------------------*/
  Procedure Update_Deduction_Hdr( p_dctn_hdr      IN OUT NOCOPY g_dctn_hdrtbl
                                 ,p_msg_count     OUT NOCOPY  NUMBER
                                 ,p_msg_data      OUT NOCOPY  VARCHAR2
                                 ,p_return_status OUT NOCOPY  VARCHAR2
                                 ,p_calling_mode  IN          VARCHAR2) Is
    l_dctn_hdr   g_dctn_hdrtbl;
  Begin

    g_api_name := 'Update_Deduction_Hdr';
    p_return_status :='S';
    FND_MSG_PUB.initialize;

    IF P_DEBUG_MODE = 'Y' THEN
       log_message ('In Update deduction header procedure',g_api_name);
    END IF;

    IF p_dctn_hdr.COUNT >0 THEN
     FOR I IN p_dctn_hdr.FIRST..p_dctn_hdr.LAST LOOP
       l_dctn_hdr(i) := p_dctn_hdr(i);

       IF P_DEBUG_MODE = 'Y' THEN
         log_message ('Before calling validate header proc: '||l_dctn_hdr(i).deduction_req_id,
                      g_api_name);
       END IF;

       If Validate_Deduction_Hdr(l_Dctn_Hdr,P_msg_count, p_msg_data,p_return_status) Then
          UPDATE pa_deductions_all
          SET     debit_memo_num        =  p_dctn_hdr(I).debit_memo_num
                 ,debit_memo_date       =  p_dctn_hdr(I).debit_memo_date
                 ,conversion_ratetype   =  p_dctn_hdr(I).conversion_ratetype
                 ,conversion_ratedate   =  p_dctn_hdr(I).conversion_ratedate
                 ,conversion_rate       =  p_dctn_hdr(I).conversion_rate
                 ,total_amount          =  nvl(p_dctn_hdr(I).total_amount,nvl(total_amount,0))
                 ,description           =  p_dctn_hdr(I).description
                 ,status                =  'WORKING'
                 ,last_updated_by       =  g_user_id
                 ,last_updation_date    =  SYSDATE
          WHERE  deduction_req_id = p_dctn_hdr(I).deduction_req_id;
       End If;
     END LOOP;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
       IF P_DEBUG_MODE = 'Y' THEN
         log_message ('In Others Exception :'||SQLERRM, g_api_name);
       END IF;

        p_msg_count:=1;
        p_msg_data:=SQLERRM;
        p_return_status := 'U';
  End;

  /*---------------------------------------------------------------------------------------------------------
    -- This procedure is to update existing data in PA_DEDUCTION_TRANSACTIONS_ALL table after
    -- validating the data.
    -- Input parameters
    -- Parameters                Type           Required  Description
    --  p_dctn_dtl               TABLE          YES       It stores the deduction transactions information
    -- Out parameters
    -- Parameters                Type           Required  Description
    --  p_return_status          VARCHAR2       YES       The return status of the APIs.
    --                                                    Valid values are:
    --                                                    S (API completed successfully),
    --                                                    E (business rule violation error) and
    --                                                    U(Unexpected error, such as an Oracle error.
    --  p_msg_count              NUMBER         YES       Holds the number of messages in the global message
                                                          table. Calling programs should use this as the
                                                          basis to fetch all the stored messages.
    --  p_msg_data               VARCHAR2       YES       Holds the message code, if the API returned only
                                                          one error/warning message Otherwise the column is
                                                          left blank.
    --  p_calling_mode           VARCHAR2       YES       Holds whether the call is being made from public
                                                          API or from the create deductions page. This is to
                                                          enforce additional validations in case if this is
                                                          called from Public API.
  ----------------------------------------------------------------------------------------------------------*/
  Procedure Update_Deduction_Txn( p_dctn_dtl IN OUT NOCOPY g_dctn_txntbl
                                 ,p_msg_count OUT NOCOPY	NUMBER
                                 ,p_msg_data	 OUT NOCOPY	VARCHAR2
                                 ,p_return_status OUT NOCOPY VARCHAR2
                                 ,p_calling_mode IN VARCHAR2) Is
   l_dctn_hdrtbl g_dctn_hdrtbl_amt;
   l_dctn_hdrcnt NUMBER :=0;
   l_dctn_hdrfnd VARCHAR2(1) :='N';
   l_dctn_hdrid  NUMBER;
   l_dctn_tbl_hdrid  g_dctn_hdrid; -- Bug# 8877035
  Begin
    g_api_name := 'Update_Deduction_Txn';
    IF P_DEBUG_MODE = 'Y' THEN
       log_message ('In Update deduction transaction procedure',g_api_name);
    END IF;

    p_return_status :='S';
    FND_MSG_PUB.initialize;

    IF p_dctn_dtl.COUNT > 0 THEN
     IF P_DEBUG_MODE = 'Y' THEN
       log_message ('Before calling validate deduction transaction procedure',g_api_name);
     END IF;

     If Validate_Deduction_Txn(P_Dctn_Dtl,P_msg_count, p_msg_data,p_return_status) Then
       FOR I IN p_dctn_dtl.FIRST..p_dctn_dtl.LAST LOOP
        IF P_DEBUG_MODE = 'Y' THEN
         log_message ('Storing distinct deduction header values in a plsql table',g_api_name);
        END IF;

       IF l_dctn_hdrcnt = 0 THEN
          l_dctn_hdrcnt := l_dctn_hdrcnt +1;
          l_dctn_hdrid  := p_dctn_dtl(i).deduction_req_id;
          l_dctn_hdrtbl(l_dctn_hdrcnt).p_dctn_hdr_id := p_dctn_dtl(i).deduction_req_id;
          l_dctn_tbl_hdrid(l_dctn_hdrcnt) := p_dctn_dtl(i).deduction_req_id;-- Bug# 8877035
          l_dctn_hdrtbl(l_dctn_hdrcnt).p_total_amount :=0;
       ELSE
         IF nvl(l_dctn_hdrid,-99) <> p_dctn_dtl(i).deduction_req_id THEN
            l_dctn_hdrid  := p_dctn_dtl(i).deduction_req_id;
            l_dctn_hdrfnd := 'N';
             FOR J in 1..l_dctn_hdrtbl.COUNT LOOP
             IF l_dctn_hdrtbl(J).p_dctn_hdr_id = p_dctn_dtl(i).deduction_req_id THEN
               l_dctn_hdrfnd := 'Y';
               EXIT;
             END IF; END LOOP;
             IF l_dctn_hdrfnd = 'N' THEN
                l_dctn_hdrcnt := l_dctn_hdrcnt +1;
                l_dctn_tbl_hdrid(l_dctn_hdrcnt) := p_dctn_dtl(i).deduction_req_id; -- Bug# 8877035
                l_dctn_hdrtbl(l_dctn_hdrcnt).p_dctn_hdr_id := p_dctn_dtl(i).deduction_req_id;
                l_dctn_hdrtbl(l_dctn_hdrcnt).p_total_amount :=0;
             END IF;
         END IF;
       END IF;
       IF P_DEBUG_MODE = 'Y' THEN
         log_message ('Before updating the deduction transaction table',g_api_name);
       END IF;

       UPDATE pa_deduction_transactions_all
       SET      task_id                  =  p_dctn_dtl(i).task_id
               ,expenditure_type         =  p_dctn_dtl(i).expenditure_type
               ,expenditure_org_id       =  p_dctn_dtl(i).expenditure_org_id
               ,quantity                 =  p_dctn_dtl(i).quantity
               ,override_quantity        =  nvl(p_dctn_dtl(i).override_quantity,p_dctn_dtl(i).quantity)
               ,projfunc_currency_code   =  p_dctn_dtl(i).projfunc_currency_code
               ,orig_projfunc_amount     =  p_dctn_dtl(i).orig_projfunc_amount
               ,override_projfunc_amount =  nvl(p_dctn_dtl(i).override_projfunc_amount,
                                                p_dctn_dtl(i).orig_projfunc_amount)
               ,conversion_ratetype      =  p_dctn_dtl(i).conversion_ratetype
               ,conversion_ratedate      =  p_dctn_dtl(i).conversion_ratedate
               ,conversion_rate          =  p_dctn_dtl(i).conversion_rate
               ,expenditure_item_date    =  p_dctn_dtl(i).expenditure_item_date
               ,amount                   =  p_dctn_dtl(i).amount
               ,description              =  p_dctn_dtl(i).description
               ,last_updated_by          =  g_user_id
               ,last_updation_date       =  SYSDATE
       WHERE  deduction_req_tran_id = p_dctn_dtl(I).deduction_req_tran_id; END LOOP;
       IF P_DEBUG_MODE = 'Y' THEN
        log_message ('Updating total amount in the header table',g_api_name);
       END IF;

        /* Bug#8877035, used pl/sql table of column type instead of record type
           to aviod the restrictions in 10g, 9i databases */

        FORALL I in 1..l_dctn_tbl_hdrid.COUNT
        UPDATE PA_DEDUCTIONS_ALL SET total_amount = nvl((
                                 SELECT SUM(amount) FROM
                                 PA_DEDUCTION_TRANSACTIONS_ALL
                                 WHERE deduction_req_id = l_dctn_tbl_hdrid(i) --l_dctn_hdrtbl(i).p_dctn_hdr_id
                                  ),0),
                                         total_pfc_amount = nvl((
                                     SELECT SUM(nvl(override_projfunc_amount,orig_projfunc_amount)) FROM
                                     PA_DEDUCTION_TRANSACTIONS_ALL
                                     WHERE deduction_req_id = l_dctn_tbl_hdrid(i)
                                     ),0)
        WHERE deduction_req_id = l_dctn_tbl_hdrid(i);--l_dctn_hdrtbl(i).p_dctn_hdr_id;

     End If;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
         p_msg_count:=1;
         p_msg_data:=SQLERRM;
         p_return_status := 'U';
  End;

  /*---------------------------------------------------------------------------------------------------------
    -- This procedure is to delete existing data in PA_DEDUCTIONS_ALL table after validating the data.
    -- Input parameters
    -- Parameters                Type           Required  Description
    --  p_dctn_hdrid             TABLE          YES       It stores the array of deducion requests
    -- Out parameters
    -- Parameters                Type           Required  Description
    --  p_return_status          VARCHAR2       YES       The return status of the APIs.
    --                                                    Valid values are:
    --                                                    S (API completed successfully),
    --                                                    E (business rule violation error) and
    --                                                    U(Unexpected error, such as an Oracle error.
    --  p_msg_count              NUMBER         YES       Holds the number of messages in the global message
                                                          table. Calling programs should use this as the
                                                          basis to fetch all the stored messages.
    --  p_msg_data               VARCHAR2       YES       Holds the message code, if the API returned only
                                                          one error/warning message Otherwise the column is
                                                          left blank.
  ----------------------------------------------------------------------------------------------------------*/
  Procedure Delete_Deduction_Hdr( p_dctn_hdrid g_dctn_hdrid
                                 ,p_msg_count OUT NOCOPY NUMBER
                                 ,p_msg_data  OUT NOCOPY VARCHAR2
                                 ,p_return_status OUT NOCOPY VARCHAR2
                                ) Is
  Begin
    g_api_name := 'Delete_Deduction_Hdr';
    FND_MSG_PUB.initialize;
    p_return_status :='S';

    IF P_DEBUG_MODE = 'Y' THEN
       log_message ('In Delete deduction header procedure',g_api_name);
    END IF;

    IF P_DEBUG_MODE = 'Y' THEN
       log_message ('Before deleting the header information',g_api_name);
    END IF;

    FORALL I IN 1..p_dctn_hdrid.COUNT
    DELETE PA_DEDUCTIONS_ALL WHERE deduction_req_id = p_dctn_hdrid(I) AND status NOT IN('PROCESSED','SUBMITTED');

     IF P_DEBUG_MODE = 'Y' THEN
       log_message ('Before deleting the transaction information',g_api_name);
     END IF;

    FORALL I IN 1..p_dctn_hdrid.COUNT
    DELETE PA_DEDUCTION_TRANSACTIONS_ALL WHERE deduction_req_id = p_dctn_hdrid(I) AND NOT EXISTS(
           SELECT 1 FROM PA_DEDUCTIONS_ALL WHERE deduction_req_id = p_dctn_hdrid(I) );
    --Commit;
  EXCEPTION
    WHEN OTHERS THEN
       IF P_DEBUG_MODE = 'Y' THEN
         log_message ('In Others Exception: '||SQLERRM,g_api_name);
       END IF;
       p_msg_count:=1;
       p_msg_data:=SQLERRM;
       p_return_status := 'U';
  End;

  /*---------------------------------------------------------------------------------------------------------
    -- This procedure is to delete existing data in PA_DEDUCTION_TRANSACTIONS_ALL table
    -- after validating the data.
    -- Input parameters
    -- Parameters                Type           Required  Description
    --  p_dctn_txnid             TABLE          YES       It stores the array of deducion request transactions
    -- Out parameters
    -- Parameters                Type           Required  Description
    --  p_return_status          VARCHAR2       YES       The return status of the APIs.
    --                                                    Valid values are:
    --                                                    S (API completed successfully),
    --                                                    E (business rule violation error) and
    --                                                    U(Unexpected error, such as an Oracle error.
    --  p_msg_count              NUMBER         YES       Holds the number of messages in the global message
                                                          table. Calling programs should use this as the
                                                          basis to fetch all the stored messages.
    --  p_msg_data               VARCHAR2       YES       Holds the message code, if the API returned only
                                                          one error/warning message Otherwise the column is
                                                          left blank.
  ----------------------------------------------------------------------------------------------------------*/
  Procedure Delete_Deduction_Txn( p_dctn_txnid g_dctn_txnid
                                 ,p_msg_count OUT NOCOPY NUMBER
                                 ,p_msg_data  OUT NOCOPY VARCHAR2
                                 ,p_return_status OUT NOCOPY VARCHAR2
                                ) Is
  Begin
    g_api_name := 'Delete_Deduction_Txn';
    p_return_status :='S';
    FND_MSG_PUB.initialize;

    IF P_DEBUG_MODE = 'Y' THEN
       log_message ('In Delete deduction transaction procedure',g_api_name);
       log_message ('Deducting the respective transaction amount from header',g_api_name);
    END IF;

    FORALL I IN 1..p_dctn_txnid.COUNT
    UPDATE PA_DEDUCTIONS_ALL dctn_hdr SET total_amount = total_amount-nvl(
            (SELECT amount FROM PA_DEDUCTION_TRANSACTIONS_ALL dctn_txn
             WHERE deduction_req_tran_id = p_dctn_txnid(I)
             AND deduction_req_id = dctn_hdr.deduction_req_id
             AND EXISTS (
             SELECT 1 FROM PA_DEDUCTIONS_ALL WHERE deduction_req_id = dctn_txn.deduction_req_id
             AND status NOT IN('PROCESSED','SUBMITTED','APPROVED'))),0);
    IF P_DEBUG_MODE = 'Y' THEN
        log_message ('Deleting the data from transaction table',g_api_name);
    END IF;

    FORALL I IN 1..p_dctn_txnid.COUNT
    DELETE PA_DEDUCTION_TRANSACTIONS_ALL dctn_txn WHERE deduction_req_tran_id = p_dctn_txnid(I)
    AND EXISTS (
           SELECT 1 FROM PA_DEDUCTIONS_ALL WHERE deduction_req_id = dctn_txn.deduction_req_id
           AND status NOT IN('PROCESSED','SUBMITTED','APPROVED'));
    --Commit;
  EXCEPTION
    WHEN OTHERS THEN
         IF P_DEBUG_MODE = 'Y' THEN
           log_message ('In Others Exceptioin :'||SQLERRM,g_api_name);
         END IF;
         p_msg_count:=1;
         p_msg_data:=SQLERRM;
         p_return_status := 'U';
  End;

  /*---------------------------------------------------------------------------------------------------------
    -- This function is to validate Deduction header information and return the result to the called proc.
    -- Input parameters
    -- Parameters                Type           Required  Description
    --  p_dctn_hdr               TABLE          YES       It stores the deduction header information
    -- Out parameters
    -- Parameters                Type           Required  Description
    --  p_return_status          VARCHAR2       YES       The return status of the APIs.
    --                                                    Valid values are:
    --                                                    S (API completed successfully),
    --                                                    E (business rule violation error) and
    --                                                    U(Unexpected error, such as an Oracle error.
    --  p_msg_count              NUMBER         YES       Holds the number of messages in the global message
                                                          table. Calling programs should use this as the
                                                          basis to fetch all the stored messages.
    --  p_msg_data               VARCHAR2       YES       Holds the message code, if the API returned only
                                                          one error/warning message Otherwise the column is
                                                          left blank.
    --  p_calling_mode           VARCHAR2       YES       Holds whether the call is being made from public
                                                          API or from the create deductions page. This is to
                                                          enforce additional validations in case if this is
                                                          called from Public API.
  ----------------------------------------------------------------------------------------------------------*/
  Function  Validate_Deduction_Hdr( p_dctn_hdr IN OUT NOCOPY g_dctn_hdrtbl
                                   ,p_msg_count OUT NOCOPY NUMBER
                                   ,p_msg_data  OUT NOCOPY VARCHAR2
                                   ,p_return_status OUT NOCOPY VARCHAR2
                                   ,p_calling_mode IN VARCHAR2 :=''
                                  ) Return Boolean Is

    CURSOR C1(p_dctn_req_num PA_DEDUCTIONS_ALL.deduction_req_num%TYPE,
              p_dctn_req_id  PA_DEDUCTIONS_ALL.deduction_req_id%TYPE)  is
      SELECT 'N'
      FROM   PA_DEDUCTIONS_ALL
      WHERE  deduction_req_num = p_dctn_req_num
      AND    deduction_req_id <> p_dctn_req_id;

    CURSOR C2(p_debit_memo_num PA_DEDUCTIONS_ALL.debit_memo_num%TYPE,
              p_org_id         PA_DEDUCTIONS_ALL.org_id%TYPE,
              p_vendor_id      PA_DEDUCTIONS_ALL.vendor_id%TYPE,
              p_dctn_req_id    PA_DEDUCTIONS_ALL.deduction_req_id%TYPE)  is
      SELECT 'N'
      FROM   PA_DEDUCTIONS_ALL
      WHERE  debit_memo_num = p_debit_memo_num
      AND    org_id = p_org_id
      AND    vendor_id = p_vendor_id
      AND    deduction_req_id <> nvl(p_dctn_req_id,-99);

    CURSOR C3(p_debit_memo_num PA_DEDUCTIONS_ALL.debit_memo_num%TYPE,
              p_vendor_id      PA_DEDUCTIONS_ALL.vendor_id%TYPE,
              p_org_id PA_DEDUCTIONS_ALL.org_id%TYPE)  is
      SELECT 'N'
      FROM   DUAL WHERE EXISTS (
                     SELECT 1
                     FROM   AP_INVOICES_ALL
                     WHERE  invoice_num = p_debit_memo_num
                     AND    vendor_id = p_vendor_id
                     AND    org_id = p_org_id
                     UNION ALL
                     SELECT 1
                     FROM   AP_INVOICES_INTERFACE
                     WHERE  invoice_num = p_debit_memo_num
                     AND    vendor_id = p_vendor_id
                     AND    org_id = p_org_id
                     AND    nvl(status, 'REJECTED') <> 'REJECTED');

    CURSOR C4(p_po_header_id NUMBER) IS
       SELECT PO_INQ_SV.get_po_total (type_lookup_code,
                                      po_header_id,
                                      '') FROM PO_HEADERS_ALL WHERE po_header_id = p_po_header_id;

    is_dctn_req_unique   VARCHAR2(1) := 'Y';
    is_debit_memo_unique VARCHAR2(1) := 'Y';

    l_po_total_amt       NUMBER;

  Begin
    g_api_name := 'Validate_Deduction_Hdr';
    p_return_status := 'S';

    IF P_DEBUG_MODE = 'Y' THEN
       log_message ('In validate header procedure',g_api_name);
    END IF;

    IF p_dctn_hdr.count > 0 THEN
       FOR I in p_dctn_hdr.FIRST..p_dctn_hdr.LAST LOOP
         BEGIN
           IF P_DEBUG_MODE = 'Y' THEN
             log_message ('Debit Memo Number '||p_dctn_hdr(i).debit_memo_num||
                          ' Org '||p_dctn_hdr(i).org_id||
                          ' Debit Memo Request '||p_dctn_hdr(i).deduction_req_num||
                          ' Vendor Id '||p_dctn_hdr(i).vendor_id||
                          ' Deduction req id '||p_dctn_hdr(i).deduction_req_id, g_api_name);

             log_message ('Validating Uniqueness of deduction request number' ,g_api_name);
           END IF;

            OPEN C1(p_dctn_hdr(i).deduction_req_num, p_dctn_hdr(i).deduction_req_id);
            FETCH C1 INTO is_dctn_req_unique;
            CLOSE C1;
              IF is_dctn_req_unique = 'N' THEN
                 p_return_status := 'E';
                 p_msg_data := 'PA_DED_REQ_NUM_UNIQ';
                 is_dctn_req_unique :='Y';
                 p_dctn_hdr(i).status := 'PA_DREQ_UNIQ';
                 AddError_To_Stack( p_error_code => 'PA_DED_REQ_NUM_UNIQ'
                                   ,p_hdr_or_txn => 'H');

              END IF;

            IF P_DEBUG_MODE = 'Y' THEN
             log_message ('Validating Uniqueness of debit memo number' ,g_api_name);
            END IF;

            OPEN C2(p_dctn_hdr(i).debit_memo_num, p_dctn_hdr(i).org_id,
                    p_dctn_hdr(i).vendor_id, p_dctn_hdr(i).deduction_req_id);
            FETCH C2 INTO is_debit_memo_unique;
            CLOSE C2;
              IF is_debit_memo_unique = 'N' THEN
                 is_debit_memo_unique := 'Y';
                 IF p_dctn_hdr(i).status IS NULL THEN
                    p_return_status := 'E';
                    p_msg_data := 'PA_DEB_MEM_NUM_UNIQ';
                    p_dctn_hdr(i).status := 'PA_DMNUM_UNIQ';
                 END IF;
                 AddError_To_Stack( p_error_code => 'PA_DEB_MEM_NUM_UNIQ'
                                   ,p_hdr_or_txn => 'H');
              END IF;
            IF p_dctn_hdr(i).status <> 'PA_DEB_MEM_NUM_UNIQ' THEN
              OPEN C3(p_dctn_hdr(i).debit_memo_num,p_dctn_hdr(i).vendor_id, p_dctn_hdr(i).org_id);
              FETCH C3 INTO is_debit_memo_unique;
              CLOSE C3;
              IF is_debit_memo_unique = 'N' THEN
                 is_debit_memo_unique := 'Y';
                 IF p_dctn_hdr(i).status IS NULL THEN
                   p_return_status := 'E';
                   p_msg_data := 'PA_DEB_MEM_NUM_UNIQ';
                   p_dctn_hdr(i).status := 'PA_DMNUM_UNIQ';
                 END IF;
                 AddError_To_Stack( p_error_code => 'PA_DEB_MEM_NUM_UNIQ'
                                   ,p_hdr_or_txn => 'H');
              END IF;
            END IF;

            /*
            IF P_DEBUG_MODE = 'Y' THEN
               log_message ('Validating PO Amount against deduction request' ,g_api_name);
            END IF;

            IF p_dctn_hdr(i).po_header_id IS NOT NULL THEN
                OPEN C4(p_dctn_hdr(i).po_header_id);
                FETCH C4 INTO l_po_total_amt;
                CLOSE C4;

                IF nvl(p_dctn_hdr(i).total_amount,0) > nvl(l_po_total_amt,0) THEN
                   IF p_dctn_hdr(i).status IS NULL THEN
                      p_return_status := 'E';
                      p_msg_data := 'PA_DCTN_AMT_EXCEEDS_POAMT';
                      p_dctn_hdr(i).status := 'PA_DAMT_MORE';
                   END IF;
                   AddError_To_Stack( p_error_code => 'PA_DCTN_AMT_EXCEEDS_POAMT'
                                     ,p_hdr_or_txn => 'H');
                END IF;
            END IF;*/

         EXCEPTION
          WHEN OTHERS THEN
             IF P_DEBUG_MODE = 'Y' THEN
               log_message ('In Others Exception: '||SQLERRM ,g_api_name);
             END IF;
               p_return_status:= 'E';
               p_msg_data :=SQLCODE;
               p_msg_count:=1;
         END;
         IF p_dctn_hdr(i).status IS NULL THEN
            p_dctn_hdr(i).status := 'WORKING';
         END IF;
	   END LOOP;
    END IF;
    IF p_msg_data IS NOT NULL THEN
      IF P_DEBUG_MODE = 'Y' THEN
       log_message ('Validation failed :'||p_msg_data ,g_api_name);
      END IF;
       RETURN FALSE;
    END IF;
	RETURN TRUE;
  End;

  /*---------------------------------------------------------------------------------------------------------
    -- This procedure is to validate Deduction header information and return the result to the called proc.
    -- Input parameters
    -- Parameters                Type           Required  Description
    --  p_dctn_dtl               TABLE          YES       It stores deduction request transactions information
    -- Out parameters
    -- Parameters                Type           Required  Description
    --  p_return_status          VARCHAR2       YES       The return status of the APIs.
    --                                                    Valid values are:
    --                                                    S (API completed successfully),
    --                                                    E (business rule violation error) and
    --                                                    U(Unexpected error, such as an Oracle error.
    --  p_msg_count              NUMBER         YES       Holds the number of messages in the global message
                                                          table. Calling programs should use this as the
                                                          basis to fetch all the stored messages.
    --  p_msg_data               VARCHAR2       YES       Holds the message code, if the API returned only
                                                          one error/warning message Otherwise the column is
                                                          left blank.
    --  p_calling_mode           VARCHAR2       YES       Holds whether the call is being made from public
                                                          API or from the create deductions page. This is to
                                                          enforce additional validations in case if this is
                                                          called from Public API.
  ----------------------------------------------------------------------------------------------------------*/
  Function  Validate_Deduction_Txn( p_dctn_dtl IN OUT NOCOPY g_dctn_txntbl
                                   ,p_msg_count OUT NOCOPY NUMBER
                                   ,p_msg_data  OUT NOCOPY VARCHAR2
                                   ,p_return_status OUT NOCOPY VARCHAR2
                                   ,p_calling_mode IN VARCHAR2 :=''
                                  ) Return Boolean Is

    CURSOR C1(p_dctn_req_id NUMBER) IS
        SELECT project_id,
               vendor_id,
               po_number,
               deduction_req_date,
               org_id
        FROM   PA_DEDUCTIONS_ALL
        WHERE  deduction_req_id = p_dctn_req_id;

    CURSOR C2(c_exp_item_id  NUMBER, p_dctn_txn_id NUMBER) IS
      SELECT 'Y'
      FROM   PA_DEDUCTION_TRANSACTIONS_ALL
      WHERE  expenditure_item_id = c_exp_item_id
      AND    deduction_req_tran_id <> p_dctn_txn_id;

    CURSOR C3(p_po_header_id NUMBER) IS
       SELECT PO_INQ_SV.get_po_total (type_lookup_code,
                                      po_header_id,
                                      '') FROM PO_HEADERS_ALL WHERE po_header_id = p_po_header_id;

    l_dctn_req_id PA_DEDUCTIONS_ALL.deduction_req_id%TYPE;
    l_exp_item_exists VARCHAR2(1) := 'N';
    tbl_dctn_hdr C1%ROWTYPE;

     CURSOR C4(p_etype VARCHAR2) IS
         SELECT
                 system_linkage_function
                ,start_date_active
                ,end_date_active
          FROM  pa_expend_typ_sys_links
          WHERE system_linkage_function = 'VI'
          AND   expenditure_type        = p_etype ;

    l_exp_type_info C4%ROWTYPE;

    l_msg_application        Varchar2(80);
    l_msg_type               Varchar2(80);
    l_msg_token1             Varchar2(80);
    l_msg_token2             Varchar2(80);
    l_msg_token3             Varchar2(80);
    l_msg_count              NUMBER;
    l_msg_data               Varchar2(4000);

    l_recno                  NUMBER :=1;
    l_billable_flag          VARCHAR2(1);
  Begin

    g_api_name := 'Validate_Deduction_Txn';
    p_return_status := 'S';
    IF P_DEBUG_MODE = 'Y' THEN
       log_message ('In Validate Deduction Transaction procedure' ,g_api_name);
    END IF;

     IF p_dctn_dtl.COUNT > 0 THEN
        FOR I in p_dctn_dtl.FIRST..p_dctn_dtl.LAST LOOP
          IF P_DEBUG_MODE = 'Y' THEN
             log_message ('Deduction_Req_ID '||p_dctn_dtl(i).deduction_req_id||
                          ' Project_ID '||p_dctn_dtl(i).project_id||
                          ' Task_Id '||p_dctn_dtl(i).task_id||
                          ' Expenditure_Item_Date '||p_dctn_dtl(i).expenditure_item_date||
                          ' Expenditure Type '||p_dctn_dtl(i).expenditure_type, g_api_name);
          END IF;
          IF  nvl(l_dctn_req_id,-99) <> p_dctn_dtl(i).deduction_req_id THEN
            IF P_DEBUG_MODE = 'Y' THEN
             log_message ('Validating whether the deduction header exists or not', g_api_name);
            END IF;

              OPEN C1(p_dctn_dtl(i).deduction_req_id);
              FETCH C1 INTO tbl_dctn_hdr;
              IF C1%NOTFOUND THEN
                 CLOSE C1;
                 p_msg_data := 'PA_DCTN_HDR_NOT_EXISTS';
                 p_return_status := 'E';
                 p_dctn_dtl(I).status := 'HDR_NOT_SAVED';
                 AddError_To_Stack( p_error_code => p_msg_data
                                   ,p_hdr_or_txn => 'H'
                                   ,p_token2_val => p_dctn_dtl(i).deduction_req_id);
                 RETURN FALSE;
              END IF;
              CLOSE C1;
              l_dctn_req_id := p_dctn_dtl(i).deduction_req_id;
              p_dctn_dtl(I).project_id := tbl_dctn_hdr.project_id; /* Temporary Code*/
              l_recno :=1;
          END IF;


          IF p_dctn_dtl(I).expenditure_item_id IS NOT NULL THEN
           IF P_DEBUG_MODE = 'Y' THEN
            log_message ('Validating if EI is already used for any other deduciton request',
                          g_api_name);
           END IF;

             OPEN C2(p_dctn_dtl(I).expenditure_item_id, p_dctn_dtl(I).deduction_req_tran_id);
             FETCH C2 INTO l_exp_item_exists;
             CLOSE C2;

             IF l_exp_item_exists = 'Y' THEN
                 p_msg_data := 'PA_DCTN_EID_EXISTS';
                 p_return_status := 'E';
                 p_dctn_dtl(I).status := 'EID_EXISTS';
                 AddError_To_Stack( p_error_code => p_msg_data
                               ,p_hdr_or_txn => 'T'
                               ,p_token1_val => l_recno);
             END IF;

             IF P_DEBUG_MODE = 'Y' THEN
               log_message ('Validating expenditure type', g_api_name);
             END IF;

             OPEN C4(p_dctn_dtl(I).expenditure_type);
             FETCH C4 INTO l_exp_type_info;
             IF C4%NOTFOUND THEN
                IF  p_msg_data IS NULL THEN
                 p_msg_data := 'PA_DED_EXP_INV_TYPE';
                 p_return_status := 'E';
                 p_dctn_dtl(I).status := 'EXP_TYPE_INV';
                END IF;
                AddError_To_Stack( p_error_code => 'PA_DED_EXP_INV_TYPE'
                               ,p_hdr_or_txn => 'T'
                               ,p_token1_val => l_recno
			       ,p_token2_val => p_dctn_dtl(I).expenditure_item_id);
             ELSIF p_dctn_dtl(I).expenditure_item_date NOT BETWEEN l_exp_type_info.start_date_active
                   AND NVL(l_exp_type_info.end_date_active, p_dctn_dtl(I).expenditure_item_date) THEN
                IF  p_msg_data IS NULL THEN
                 p_msg_data := 'ETYPE_SLINK_INACTIVE';
                 p_return_status := 'E';
                 p_dctn_dtl(I).status := 'EXP_TYPE_INV';
                END IF;
                AddError_To_Stack( p_error_code => 'ETYPE_SLINK_INACTIVE'
                                  ,p_hdr_or_txn => 'T'
                                  ,p_token1_val => l_recno);
             END IF;
             CLOSE C4;
          END IF;

          IF P_DEBUG_MODE = 'Y' THEN
            log_message ('Validating project functional currency amount', g_api_name);
          END IF;

          IF nvl(p_dctn_dtl(I).override_projfunc_amount,
                 p_dctn_dtl(I).orig_projfunc_amount) IS NULL THEN
             IF  p_msg_data IS NULL THEN
                 p_msg_data := 'PA_DCTN_PFC_AMT_NULL';
                 p_return_status := 'E';
                 p_dctn_dtl(I).status := 'PFC_AMT_NULL';
             END IF;
             AddError_To_Stack( p_error_code => 'PA_DCTN_PFC_AMT_NULL'
                               ,p_hdr_or_txn => 'T'
                               ,p_token1_val => l_recno);
          END IF;

          IF P_DEBUG_MODE = 'Y' THEN
             log_message ('Validating transaction currency amount', g_api_name);
          END IF;

          IF p_dctn_dtl(I).amount IS NULL THEN
             IF  p_msg_data IS NULL THEN
                 p_msg_data := 'PA_DCTN_DMEMO_AMT_NULL';
                 p_return_status := 'E';
                 p_dctn_dtl(I).status := 'PFC_DAMT_NULL';
             END IF;
             AddError_To_Stack( p_error_code => 'PA_DCTN_DMEMO_AMT_NULL'
                               ,p_hdr_or_txn => 'T'
                               ,p_token1_val => l_recno);
          END IF;

          IF P_DEBUG_MODE = 'Y' THEN
            log_message ('Before calling PATC validate_transaction procedure', g_api_name);
          END IF;

          PA_TRANSACTIONS_PUB.VALIDATE_TRANSACTION(
              x_project_id          => tbl_dctn_hdr.project_id,
              x_task_id             => p_dctn_dtl(i).task_id,
              x_ei_date             => p_dctn_dtl(i).expenditure_item_date,
              x_expenditure_type    => p_dctn_dtl(i).expenditure_type,
              x_non_labor_resource  => null,
              x_person_id           => null,
              x_billable_flag       => l_billable_flag,
              x_quantity            => p_dctn_dtl(i).override_quantity,
              x_transfer_ei         => null,
              x_incurred_by_org_id  => p_dctn_dtl(i).expenditure_org_id,
              x_nl_resource_org_id  => null,
              x_transaction_source  => '',
              x_calling_module      => 'APXIIMPT',
              x_vendor_id           => tbl_dctn_hdr.vendor_id,
              x_entered_by_user_id  => g_user_id,
              x_denom_currency_code => null,
              x_acct_currency_code  => null,
              x_denom_raw_cost      =>  null,
              x_acct_raw_cost       => null,
              x_acct_rate_type      => null,
              x_acct_rate_date      => null,
              x_acct_exchange_rate  => null,
              x_msg_application     => l_msg_application,
              x_msg_type            => l_msg_type,
              x_msg_token1          => l_msg_token1,
              x_msg_token2          => l_msg_token2,
              x_msg_token3          => l_msg_token3,
              x_msg_count           => l_msg_count,
              x_msg_data            => l_msg_data,
              p_sys_link_function   => '');

          IF P_DEBUG_MODE = 'Y' THEN
            log_message ('After calling PATC validate_transaction procedure :'||l_msg_data, g_api_name);
          END IF;

          IF l_msg_data IS NOT NULL THEN
             IF p_msg_data IS NULL THEN
                 p_msg_data := l_msg_data;
                 p_return_status := 'E';
                 p_dctn_dtl(I).status := substr(l_msg_data,1,15);
             END IF;
                 AddError_To_Stack( p_error_code => l_msg_data
                               ,p_hdr_or_txn => 'T'
                               ,p_token1_val => l_recno);
          END IF;

          l_recno := l_recno + 1;
        END LOOP;
     END IF;
     RETURN TRUE;
  End;

  /*---------------------------------------------------------------------------------------------------------
    -- This procedure is to submit the deducion request for approval thereby for the creation of Debit memo.
    -- This is being called on pressing the submit button on Create deductions page.
    -- Input parameters
    -- Parameters                Type           Required  Description
    --  p_dctn_req_id            NUMBER         YES       Deduction request id for which debit memo needs
                                                          to be raised
    -- Out parameters
    -- Parameters                Type           Required  Description
    --  p_return_status          VARCHAR2       YES       The return status of the APIs.
    --                                                    Valid values are:
    --                                                    S (API completed successfully),
    --                                                    E (business rule violation error) and
    --                                                    U(Unexpected error, such as an Oracle error.
    --  p_msg_count              NUMBER         YES       Holds the number of messages in the global message
                                                          table. Calling programs should use this as the
                                                          basis to fetch all the stored messages.
    --  p_msg_data               VARCHAR2       YES       Holds the message code, if the API returned only
                                                          one error/warning message Otherwise the column is
                                                          left blank.
  ----------------------------------------------------------------------------------------------------------*/
  Procedure Submit_For_DebitMemo ( p_dctn_req_id IN PA_DEDUCTIONS_ALL.deduction_req_id%TYPE
                                  ,p_msg_count OUT NOCOPY NUMBER
                                  ,p_msg_data  OUT NOCOPY VARCHAR2
                                  ,p_return_status OUT NOCOPY VARCHAR2
                                 ) IS

    x_err_stack                VARCHAR2(2000);
    x_err_stage                VARCHAR2(2000);
    x_err_code                 NUMBER;

    CURSOR C1 IS
       SELECT * FROM PA_DEDUCTION_TRANSACTIONS_ALL
       WHERE  deduction_req_id = p_dctn_req_id;

    l_dctn_req_cnt   NUMBER;
    p_next_number    PA_DEDUCTIONS_ALL.debit_memo_num%TYPE;

    l_dctn_hdrtbl              g_dctn_hdrtbl;
    l_dctn_txntbl              g_dctn_txntbl;
    cnt                        NUMBER :=0;

  BEGIN
        g_api_name := 'Submit_For_DebitMemo_1';
        IF P_DEBUG_MODE = 'Y' THEN
          log_message ('Submit_For_DebitMemo started for deduction request:' ||p_dctn_req_id,
                      g_api_name);
        END IF;

        p_return_status := 'S';
        FND_MSG_PUB.initialize;

        IF P_DEBUG_MODE = 'Y' THEN
          log_message ('Verifying if the deduction header exists in database', g_api_name);
        END IF;

        OPEN cur_dctn_hdr_info(p_dctn_req_id);
        FETCH cur_dctn_hdr_info INTO cur_dctn_hdr;
        IF cur_dctn_hdr_info%NOTFOUND THEN
           p_return_status := 'E';
           p_msg_data := 'PA_DCTN_HDR_NOT_EXISTS';
           p_msg_count :=1;
           CLOSE cur_dctn_hdr_info;

           AddError_To_Stack( p_error_code => p_msg_data
                             ,p_hdr_or_txn => 'H'
                             ,p_token2_val => p_dctn_req_id);
           RETURN;
        END IF;
        CLOSE cur_dctn_hdr_info;

        IF P_DEBUG_MODE = 'Y' THEN
          log_message ('Verifying debit memo date is given or not', g_api_name);
        END IF;

        IF cur_dctn_hdr.debit_memo_date IS NULL THEN
           p_return_status := 'E';
           p_msg_data := 'PA_DCTN_DMEMO_DATE_NULL';
           p_msg_count :=1;

           AddError_To_Stack( p_error_code => p_msg_data
                             ,p_hdr_or_txn => 'H');
           RETURN;
        END IF;

        IF P_DEBUG_MODE = 'Y' THEN
          log_message ('Verifying if debit memo amount is negative', g_api_name);
        END IF;

        IF nvl(cur_dctn_hdr.total_amount,0) < 0 THEN
             IF p_msg_data IS NULL THEN
                 p_msg_data := 'PA_DEB_MEM_AMT_NEG';
                 p_return_status := 'E';
             END IF;
             AddError_To_Stack( p_error_code => 'PA_DEB_MEM_AMT_NEG'
                               ,p_hdr_or_txn => 'H');
             RETURN;
        END IF;

        IF P_DEBUG_MODE = 'Y' THEN
           log_message ('Initializing the pl/sql table for validating header', g_api_name);
        END IF;

        l_dctn_hdrtbl(1).deduction_req_id    :=  cur_dctn_hdr.deduction_req_id     ;
        l_dctn_hdrtbl(1).project_id          :=  cur_dctn_hdr.project_id           ;
        l_dctn_hdrtbl(1).vendor_id           :=  cur_dctn_hdr.vendor_id            ;
        l_dctn_hdrtbl(1).vendor_site_id      :=  cur_dctn_hdr.vendor_site_id       ;
        l_dctn_hdrtbl(1).change_doc_num      :=  cur_dctn_hdr.change_doc_num       ;
        l_dctn_hdrtbl(1).change_doc_type     :=  cur_dctn_hdr.change_doc_type      ;
        l_dctn_hdrtbl(1).ci_id               :=  cur_dctn_hdr.ci_id                ;
        l_dctn_hdrtbl(1).po_number           :=  cur_dctn_hdr.po_number            ;
        l_dctn_hdrtbl(1).po_header_id        :=  cur_dctn_hdr.po_header_id         ;
        l_dctn_hdrtbl(1).deduction_req_num   :=  cur_dctn_hdr.deduction_req_num    ;
        l_dctn_hdrtbl(1).debit_memo_num      :=  cur_dctn_hdr.debit_memo_num       ;
        l_dctn_hdrtbl(1).currency_code       :=  cur_dctn_hdr.currency_code        ;
        l_dctn_hdrtbl(1).conversion_ratetype :=  cur_dctn_hdr.conversion_ratetype  ;
        l_dctn_hdrtbl(1).conversion_ratedate :=  cur_dctn_hdr.conversion_ratedate  ;
        l_dctn_hdrtbl(1).conversion_rate     :=  cur_dctn_hdr.conversion_rate      ;
        l_dctn_hdrtbl(1).total_amount        :=  cur_dctn_hdr.total_amount         ;
        l_dctn_hdrtbl(1).deduction_req_date  :=  cur_dctn_hdr.deduction_req_date   ;
        l_dctn_hdrtbl(1).debit_memo_date     :=  cur_dctn_hdr.debit_memo_date      ;
        l_dctn_hdrtbl(1).description         :=  cur_dctn_hdr.description          ;
        l_dctn_hdrtbl(1).status              :=  cur_dctn_hdr.status               ;
        l_dctn_hdrtbl(1).org_id              :=  cur_dctn_hdr.org_id               ;

        p_msg_count:= '';
        p_msg_data := '';
        p_return_status :='';

        /* Bug# 9401673 Commented the below condition and added condition on deduction status. */
	/* Condition on deduction status is required to call the client extension only for the
	   first time when we submit the deduction for approval.

	   The client extension should not be called again when we resubmit the deduction for approval
	   in case if the deduction was rejected/failed during the last submission. This is to avoid
	   rederiving the debit memo number by the client extension.
	*/

	--IF cur_dctn_hdr.debit_memo_num IS NULL THEN
	IF cur_dctn_hdr.status = 'WORKING' THEN
          IF P_DEBUG_MODE = 'Y' THEN
            log_message ('Generating debit memo number', g_api_name);
          END IF;

          IF NOT Validate_DM(l_dctn_hdrtbl
                         ,p_msg_count
                         ,p_msg_data
                         ,p_return_status
                         ) THEN

            IF P_DEBUG_MODE = 'Y' THEN
              log_message ('Debit memo generation failed', g_api_name);
            END IF;
            RETURN;
          ELSE
           IF P_DEBUG_MODE = 'Y' THEN
             log_message ('Updating the debit memo number on Deduction request header', g_api_name);
           END IF;

            UPDATE PA_DEDUCTIONS_ALL pda
            SET    debit_memo_num = l_dctn_hdrtbl(1).debit_memo_num
            WHERE  deduction_req_id = p_dctn_req_id;

            COMMIT;
          END IF;
	END IF;
        --END IF;

        cnt :=1;

        If Validate_Deduction_Hdr(l_dctn_hdrtbl,P_msg_count, p_msg_data,p_return_status) Then
           IF P_DEBUG_MODE = 'Y' THEN
             log_message ('Initializing pl/sql table for detail tranasctions for validing them',
                           g_api_name);
           END IF;

          FOR cur_dctn_txn IN C1 LOOP
           l_dctn_txntbl(cnt).deduction_req_id          := cur_dctn_txn.deduction_req_id        ;
           l_dctn_txntbl(cnt).deduction_req_tran_id     := cur_dctn_txn.deduction_req_tran_id   ;
           l_dctn_txntbl(cnt).project_id                := cur_dctn_txn.project_id              ;
           l_dctn_txntbl(cnt).task_id                   := cur_dctn_txn.task_id                 ;
           l_dctn_txntbl(cnt).expenditure_type          := cur_dctn_txn.expenditure_type        ;
           l_dctn_txntbl(cnt).expenditure_item_date     := cur_dctn_txn.expenditure_item_date   ;
           l_dctn_txntbl(cnt).gl_date                   := cur_dctn_txn.gl_date                 ;
           l_dctn_txntbl(cnt).expenditure_org_id        := cur_dctn_txn.expenditure_org_id      ;
           l_dctn_txntbl(cnt).quantity                  := cur_dctn_txn.quantity                ;
           l_dctn_txntbl(cnt).override_quantity         := cur_dctn_txn.override_quantity       ;
           l_dctn_txntbl(cnt).expenditure_item_id       := cur_dctn_txn.expenditure_item_id     ;
           l_dctn_txntbl(cnt).projfunc_currency_code    := cur_dctn_txn.projfunc_currency_code  ;
           l_dctn_txntbl(cnt).orig_projfunc_amount      := cur_dctn_txn.orig_projfunc_amount    ;
           l_dctn_txntbl(cnt).override_projfunc_amount  := cur_dctn_txn.override_projfunc_amount;
           l_dctn_txntbl(cnt).conversion_ratetype       := cur_dctn_txn.conversion_ratetype     ;
           l_dctn_txntbl(cnt).conversion_ratedate       := cur_dctn_txn.conversion_ratedate     ;
           l_dctn_txntbl(cnt).conversion_rate           := cur_dctn_txn.conversion_rate         ;
           l_dctn_txntbl(cnt).amount                    := cur_dctn_txn.amount                  ;
           l_dctn_txntbl(cnt).description               := cur_dctn_txn.description             ;
           cnt := cnt+1;
          END LOOP;

          IF cnt = 1 THEN
             IF P_DEBUG_MODE = 'Y' THEN
               log_message ('There are no detail transactions and hence cannot be submitted',
                             g_api_name);
             END IF;

               p_return_status := 'E';
               p_msg_data := 'PA_DED_REQ_ITEM_LESS';
               p_msg_count :=1;
               AddError_To_Stack( p_error_code => p_msg_data
                                 ,p_hdr_or_txn => 'H');
               RETURN;
          ELSE
            If Validate_Deduction_Txn(l_dctn_txntbl,P_msg_count, p_msg_data,p_return_status) Then

              IF P_DEBUG_MODE = 'Y' THEN
               log_message ('Validation on detail transactions is successful', g_api_name);
              END IF;

           	   Update_Deduction_Status(p_dctn_req_id,
                                          'SUBMITTED');
		       COMMIT;

               IF P_DEBUG_MODE = 'Y' THEN
                 log_message ('Before calling workflow for deduction approval', g_api_name);
               END IF;

               PA_DCTN_APRV_NOTIFICATION.START_DCTN_APRV_WF (p_dctn_req_id
                                                            ,x_err_stack
                                                            ,x_err_stage
                                                            ,x_err_code );

               IF P_DEBUG_MODE = 'Y' THEN
                 IF x_err_code <>0 THEN
                   log_message ('Workflow is failed', g_api_name);
                 ELSE
                   log_message ('Workflow is successful', g_api_name);
                 END IF;
               END IF;

               COMMIT;
            End If;
	      END IF;
        Else
          IF P_DEBUG_MODE = 'Y' THEN
            log_message ('Header validation failed', g_api_name);
          END IF;

           UPDATE PA_DEDUCTIONS_ALL pda
           SET    status = DECODE(p_return_status,'E','REJECTED',status)
           WHERE  deduction_req_id = p_dctn_req_id;

           COMMIT;
	    End If;

  EXCEPTION
      WHEN OTHERS THEN
        IF P_DEBUG_MODE = 'Y' THEN
          log_message ('In Others exception : '||SQLERRM, g_api_name);
        END IF;

        Delete_Failed_Rec(p_dctn_req_id);
        p_msg_data:=SQLERRM;
        p_return_status := 'U';
        p_msg_count :=1;
        AddError_To_Stack( p_error_code => p_msg_data
                          ,p_hdr_or_txn => 'H');
  END;

  /*---------------------------------------------------------------------------------------------------------
    -- This procedure is to raise a debit memo in payables. This is being called from deduction request
    -- approval workflow on deduction request's approval.
    -- Input parameters
    -- Parameters                Type           Required  Description
    --  p_dctn_req_id            NUMBER         YES       Deduction request id for which debit memo needs
                                                          to be raised
    -- Out parameters
    -- Parameters                Type           Required  Description
    --  p_return_status          VARCHAR2       YES       The return status of the APIs.
    --                                                    Valid values are:
    --                                                    S (API completed successfully),
    --                                                    E (business rule violation error) and
    --                                                    U(Unexpected error, such as an Oracle error.
    --  p_msg_count              NUMBER         YES       Holds the number of messages in the global message
                                                          table. Calling programs should use this as the
                                                          basis to fetch all the stored messages.
    --  p_msg_data               VARCHAR2       YES       Holds the message code, if the API returned only
                                                          one error/warning message Otherwise the column is
                                                          left blank.
  ----------------------------------------------------------------------------------------------------------*/
  Procedure Submit_For_DebitMemo ( p_dctn_hdr_rec IN cur_dctn_hdr_info%ROWTYPE
                                  ,p_msg_count OUT NOCOPY NUMBER
                                  ,p_msg_data  OUT NOCOPY VARCHAR2
                                  ,p_return_status OUT NOCOPY VARCHAR2
                                 ) IS

    CURSOR C2(p_dctn_req_id PA_DEDUCTIONS_ALL.deduction_req_id%TYPE) IS
       SELECT *
       FROM PA_DEDUCTION_TRANSACTIONS_ALL WHERE deduction_req_id = p_dctn_req_id;

    l_int_invoice_id           NUMBER;
    l_int_invoice_line_id      NUMBER;

    l_description              VARCHAR2(240);
    l_exchange_rate            NUMBER;
    l_exchange_rate_type       VARCHAR2(30);
    l_exchange_date            DATE;

    l_dctn_hdrtbl              g_dctn_hdrtbl;
    l_dctn_txntbl              g_dctn_txntbl;
    cnt                        NUMBER :=0;

    l_is_deduction_valid       VARCHAR2(1):= 'Y';
    l_tax_flag                 VARCHAR2(1):= 'N';
    reqid                      NUMBER;
    cur_dctn_txn               C2%ROWTYPE;
  Begin
        g_api_name := 'Submit_For_DebitMemo_2';

        IF P_DEBUG_MODE = 'Y' THEN
          log_message ('Submit procedure for interfacing and importing the debit memo', g_api_name);
        END IF;

        p_return_status := 'S';
        FND_MSG_PUB.initialize;

        IF P_DEBUG_MODE = 'Y' THEN
          log_message ('Updating deduction request status to Approved :'||l_int_invoice_id, g_api_name);
        END IF;

        Update_Deduction_Status(p_dctn_hdr_rec.deduction_req_id,
                                'APPROVED');

        SELECT AP_INVOICES_INTERFACE_S.nextval
        INTO   l_int_invoice_id
     	FROM   SYS.DUAL;

        IF P_DEBUG_MODE = 'Y' THEN
          log_message ('Invoice_Id in interface table :'||l_int_invoice_id, g_api_name);
        END IF;

        IF p_dctn_hdr_rec.po_number IS NOT NULL THEN
           l_description := SUBSTR(p_dctn_hdr_rec.description,1,210)||p_dctn_hdr_rec.po_number;
        ELSE
           l_description := SUBSTR(p_dctn_hdr_rec.description,1,240);
        END IF;


        IF p_dctn_hdr_rec.document_type = 'M' THEN
           l_tax_flag := 'Y';
        ELSE
           l_tax_flag := 'N';
        END IF;

        IF P_DEBUG_MODE = 'Y' THEN
          log_message ('Tax Calculation Flag :'||l_tax_flag, g_api_name);
        END IF;

        l_dctn_hdrtbl(1).deduction_req_id    :=  p_dctn_hdr_rec.deduction_req_id     ;
        l_dctn_hdrtbl(1).project_id          :=  p_dctn_hdr_rec.project_id           ;
        l_dctn_hdrtbl(1).vendor_id           :=  p_dctn_hdr_rec.vendor_id            ;
        l_dctn_hdrtbl(1).vendor_site_id      :=  p_dctn_hdr_rec.vendor_site_id       ;
        l_dctn_hdrtbl(1).change_doc_num      :=  p_dctn_hdr_rec.change_doc_num       ;
        l_dctn_hdrtbl(1).change_doc_type     :=  p_dctn_hdr_rec.change_doc_type      ;
        l_dctn_hdrtbl(1).ci_id               :=  p_dctn_hdr_rec.ci_id                ;
        l_dctn_hdrtbl(1).po_number           :=  p_dctn_hdr_rec.po_number            ;
        l_dctn_hdrtbl(1).po_header_id        :=  p_dctn_hdr_rec.po_header_id         ;
        l_dctn_hdrtbl(1).deduction_req_num   :=  p_dctn_hdr_rec.deduction_req_num    ;
        l_dctn_hdrtbl(1).debit_memo_num      :=  p_dctn_hdr_rec.debit_memo_num       ;
        l_dctn_hdrtbl(1).currency_code       :=  p_dctn_hdr_rec.currency_code        ;
        l_dctn_hdrtbl(1).conversion_ratetype :=  p_dctn_hdr_rec.conversion_ratetype  ;
        l_dctn_hdrtbl(1).conversion_ratedate :=  p_dctn_hdr_rec.conversion_ratedate  ;
        l_dctn_hdrtbl(1).conversion_rate     :=  p_dctn_hdr_rec.conversion_rate      ;
        l_dctn_hdrtbl(1).total_amount        :=  p_dctn_hdr_rec.total_amount         ;
        l_dctn_hdrtbl(1).deduction_req_date  :=  p_dctn_hdr_rec.deduction_req_date   ;
        l_dctn_hdrtbl(1).debit_memo_date     :=  p_dctn_hdr_rec.debit_memo_date      ;
        l_dctn_hdrtbl(1).description         :=  p_dctn_hdr_rec.description          ;
        l_dctn_hdrtbl(1).status              :=  p_dctn_hdr_rec.status               ;
        l_dctn_hdrtbl(1).org_id              :=  p_dctn_hdr_rec.org_id               ;

        cnt :=1;

        FOR cur_dctn_txn IN C2(p_dctn_hdr_rec.deduction_req_id) LOOP
           l_dctn_txntbl(cnt).deduction_req_id          := cur_dctn_txn.deduction_req_id        ;
           l_dctn_txntbl(cnt).deduction_req_tran_id     := cur_dctn_txn.deduction_req_tran_id   ;
           l_dctn_txntbl(cnt).project_id                := cur_dctn_txn.project_id              ;
           l_dctn_txntbl(cnt).task_id                   := cur_dctn_txn.task_id                 ;
           l_dctn_txntbl(cnt).expenditure_type          := cur_dctn_txn.expenditure_type        ;
           l_dctn_txntbl(cnt).expenditure_item_date     := cur_dctn_txn.expenditure_item_date   ;
           l_dctn_txntbl(cnt).gl_date                   := cur_dctn_txn.gl_date                 ;
           l_dctn_txntbl(cnt).expenditure_org_id        := cur_dctn_txn.expenditure_org_id      ;
           l_dctn_txntbl(cnt).quantity                  := cur_dctn_txn.quantity                ;
           l_dctn_txntbl(cnt).override_quantity         := cur_dctn_txn.override_quantity       ;
           l_dctn_txntbl(cnt).expenditure_item_id       := cur_dctn_txn.expenditure_item_id     ;
           l_dctn_txntbl(cnt).projfunc_currency_code    := cur_dctn_txn.projfunc_currency_code  ;
           l_dctn_txntbl(cnt).orig_projfunc_amount      := cur_dctn_txn.orig_projfunc_amount    ;
           l_dctn_txntbl(cnt).override_projfunc_amount  := cur_dctn_txn.override_projfunc_amount;
           l_dctn_txntbl(cnt).conversion_ratetype       := cur_dctn_txn.conversion_ratetype     ;
           l_dctn_txntbl(cnt).conversion_ratedate       := cur_dctn_txn.conversion_ratedate     ;
           l_dctn_txntbl(cnt).conversion_rate           := cur_dctn_txn.conversion_rate         ;
           l_dctn_txntbl(cnt).amount                    := cur_dctn_txn.amount                  ;
           l_dctn_txntbl(cnt).description               := cur_dctn_txn.description             ;
           cnt := cnt+1;
        END LOOP;

        IF P_DEBUG_MODE = 'Y' THEN
           log_message ('Before creating the invoice header',g_api_name);
        END IF;

	    Create_Invoice_Header (
	       p_dctn_hdr_rec.deduction_req_id
	      ,l_int_invoice_id
	      ,p_dctn_hdr_rec.debit_memo_num
	      ,p_dctn_hdr_rec.debit_memo_date
	      ,p_dctn_hdr_rec.vendor_id
	      ,p_dctn_hdr_rec.vendor_site_id
	      ,p_dctn_hdr_rec.total_amount
	      ,p_dctn_hdr_rec.currency_code
	      ,l_exchange_rate
	      ,l_exchange_rate_type
	      ,l_exchange_date
	      ,l_description
	      ,l_tax_flag
	      ,p_dctn_hdr_rec.org_id );

        IF P_DEBUG_MODE = 'Y' THEN
           log_message ('Before creating the invoice lines',g_api_name);
        END IF;

	    FOR I IN 1..l_dctn_txntbl.COUNT LOOP
	        Create_Invoice_Line (
	            l_int_invoice_id
	            ,PA_CURRENCY.round_trans_currency_amt(l_dctn_txntbl(i).amount,
                                                      p_dctn_hdr_rec.currency_code)
	            ,nvl(l_dctn_txntbl(i).gl_date, l_dctn_txntbl(i).expenditure_item_date)
	            ,l_dctn_txntbl(i).project_id
	            ,l_dctn_txntbl(i).task_id
	            ,l_dctn_txntbl(i).expenditure_item_date
	            ,l_dctn_txntbl(i).expenditure_type
	            ,l_dctn_txntbl(i).expenditure_org_id
	            ,'Yes'
	            ,l_dctn_txntbl(i).description
	            ,l_dctn_txntbl(i).override_quantity
	            ,p_dctn_hdr_rec.org_id );
	    END LOOP;

        IF P_DEBUG_MODE = 'Y' THEN
           log_message ('Before calling Payables Open Import',g_api_name);
        END IF;
        /* Bug 8740525 sosharma commented and added code for concurrent request */
        /*Import_DebitMemo(p_dctn_hdr_rec.deduction_req_id
                        ,p_msg_count
                        ,p_msg_data
                        ,p_return_status
                        );*/

     reqid:=fnd_request.submit_request('PA','PA_DEBITMEMO_IMPORT','',null,FALSE,p_dctn_hdr_rec.deduction_req_id);

        IF P_DEBUG_MODE = 'Y' THEN
          IF p_return_status = 'S' THEN
            log_message ('Payables open interface concurrent request raised', reqid);
          END IF;
        END IF;

  EXCEPTION
    WHEN OTHERS THEN
       IF P_DEBUG_MODE = 'Y' THEN
         log_message ('Unexpected error in the procedure: '||g_api_name, g_api_name);
         log_message ('Error :'||SQLERRM, g_api_name);
       END IF;

         Update_Deduction_Status(p_dctn_hdr_rec.deduction_req_id,
                                 'FAILED');
      /*   p_msg_data:=SQLERRM;
         p_return_status := 'U';
         p_msg_count :=1;
         AddError_To_Stack( p_error_code => p_msg_data
                           ,p_hdr_or_txn => 'H');*/
  End;

  Procedure Create_Invoice_Header (
        p_deduction_req_id       IN  NUMBER
       ,p_invoice_id             IN  NUMBER
       ,p_invoice_num            IN  VARCHAR2
       ,p_invoice_date           IN  DATE
       ,p_vendor_id              IN  NUMBER
       ,p_vendor_site_id         IN  NUMBER
       ,p_invoice_amount         IN  NUMBER
       ,p_invoice_currency_code  IN  VARCHAR2
       ,p_exchange_rate          IN  NUMBER
       ,p_exchange_rate_type     IN  VARCHAR2
       ,p_exchange_date          IN  DATE
       ,p_description            IN  VARCHAR2
       ,p_tax_flag               IN  VARCHAR2
       ,p_org_id                 IN  NUMBER ) IS

    l_rowid   ROWID;
    l_groupid AP_INVOICES_INTERFACE.group_id%TYPE;
  Begin
          g_api_name := 'Create_Invoice_Header';

          IF P_DEBUG_MODE = 'Y' THEN
            log_message ('In Creating header information in interface table',g_api_name);
          END IF;

          l_groupid := 'DM'||TO_CHAR(SYSDATE,'YYYYMMDD')||p_invoice_num;

          IF P_DEBUG_MODE = 'Y' THEN
            log_message ('Before inserting invoice header : '||l_groupId, g_api_name);
          END IF;

          INSERT INTO AP_INVOICES_INTERFACE (
                            invoice_id
                           ,invoice_num
                           ,invoice_type_lookup_code
                           ,invoice_date
                           ,vendor_id
                           ,vendor_site_id
                           ,invoice_amount
                           ,invoice_currency_code
                           ,description
                           ,voucher_num
                           ,application_id
                           ,product_table
                           ,reference_key1
                           ,calc_tax_during_import_flag
                           ,group_id
                           ,source
                           ,creation_date
                           ,created_by
                           ,org_id )
                  VALUES   (
                            p_invoice_id
                           ,p_invoice_num
                           ,'DEBIT'
                           ,p_invoice_date
                           ,p_vendor_id
                           ,p_vendor_site_id
                           ,-p_invoice_amount
                           ,p_invoice_currency_code
                           ,p_description
                           ,p_invoice_num
                           ,275
                           ,'PA_DEDUCTIONS_ALL'
                           ,p_deduction_req_id
                           ,p_tax_flag
                           ,l_groupid
                           ,'Oracle Project Accounting'
                           ,SYSDATE
                           ,g_user_id
                           ,p_org_id );

        IF P_DEBUG_MODE = 'Y' THEN
          log_message ('After inserting into invoice interface table',g_api_name);
        END IF;
  End;

  Procedure Create_Invoice_Line (
          p_invoice_id            IN  NUMBER
         ,p_amount                IN  NUMBER
         ,p_accounting_date       IN  DATE
         ,p_project_id            IN  NUMBER
         ,p_task_id               IN  NUMBER
         ,p_expenditure_item_date IN  DATE
         ,p_expenditure_type      IN  VARCHAR2
         ,p_expenditure_org       IN  NUMBER
         ,p_project_acct_context  IN  VARCHAR2
         ,p_description           IN  VARCHAR2
         ,p_qty_invoiced          IN  NUMBER
         ,p_org_id                IN  NUMBER ) IS

  l_invoice_line_id   NUMBER;
  l_rowid             ROWID;
  Begin
       g_api_name := 'Create_Invoice_Line';
       log_message ('Before inserting lines into interface lines table', g_api_name);

       SELECT ap_invoice_lines_interface_s.nextval
       INTO   l_invoice_line_id
       FROM   sys.dual;

       IF P_DEBUG_MODE = 'Y' THEN
         log_message ('Invoice Line Id : '||l_invoice_line_id, g_api_name);
       END IF;

       INSERT INTO AP_INVOICE_LINES_INTERFACE (
                     invoice_id
                    ,invoice_line_id
                    ,line_type_lookup_code
                    ,amount
                    ,quantity_invoiced
                    ,org_id
                    ,project_id
                    ,task_id
                    ,expenditure_type
                    ,expenditure_organization_id
                    ,expenditure_item_date
                    ,project_accounting_context
                    ,accounting_date
                    ,description
                    ,pa_addition_flag
                    ,creation_date
                    ,created_by
                    )
    		 VALUES (
                    p_invoice_id
                   ,l_invoice_line_id
                   ,'ITEM'
                   ,-p_amount
                   ,p_qty_invoiced
                   ,p_org_id
                   ,p_project_id
                   ,p_task_id
                   ,p_expenditure_type
                   ,p_expenditure_org
                   ,p_expenditure_item_date
                   ,p_project_acct_context
                   ,p_accounting_date
                   ,p_description
                   ,'N'
                   ,SYSDATE
                   ,g_user_id) ;

       IF P_DEBUG_MODE = 'Y' THEN
          log_message ('After inserting into interface :'||SQL%ROWCOUNT|| ' records inserted',
                       g_api_name);
       END IF;
  End;

  Procedure Update_Deduction_Status(p_dctn_hdr_id IN PA_DEDUCTIONS_ALL.deduction_req_id%TYPE,
                                    p_status      IN VARCHAR2) IS
  -- PRAGMA AUTONOMOUS_TRANSACTION;
  Begin
        UPDATE PA_DEDUCTIONS_ALL SET status = p_status WHERE deduction_req_id = p_dctn_hdr_id;
      --  COMMIT;
  End;
/* Bug 8740525 sosharma commented and added code for concurrent request */
  Procedure Import_DebitMemo(errbuf OUT NOCOPY varchar2,
                             ret_code OUT NOCOPY varchar2,
                             p_dctn_req_id IN NUMBER
                        --  ,p_msg_count OUT NOCOPY NUMBER
                        --    ,p_msg_data  OUT NOCOPY VARCHAR2
                        --    ,p_return_status OUT NOCOPY VARCHAR2
                            ) IS
	   	p_batch_name              VARCHAR2(100);
	p_gl_date                 DATE;
	p_hold_code               VARCHAR2(100);
	p_hold_reason             VARCHAR2(1000);
	p_commit_cycles           NUMBER;
	p_source                  VARCHAR2(100);
	p_group_id                VARCHAR2(100);
	p_conc_request_id         NUMBER;
	p_debug_switch            VARCHAR2(1) :='N';
	p_org_id                  NUMBER;
	p_batch_error_flag        VARCHAR2(1);
	p_invoices_fetched        NUMBER;
	p_invoices_created        NUMBER;
        p_total_invoice_amount    NUMBER;
        p_print_batch             VARCHAR2(1);
	p_calling_sequence        VARCHAR2(100);

    CURSOR C1 IS
       SELECT * FROM AP_INVOICES_INTERFACE
       WHERE product_table = 'PA_DEDUCTIONS_ALL'
       AND reference_key1 = p_dctn_req_id;

    CURSOR C2 IS
       SELECT * FROM PA_DEDUCTIONS_ALL
       WHERE deduction_req_id = p_dctn_req_id;


       CURSOR C3 IS
         select pded.deduction_req_num,pded.debit_memo_num,pded.deduction_req_date,
	pded.debit_memo_date,pded.currency_code,pa.segment1,pa.name
	,v.vendor_name
	,vs.vendor_site_code
	,hr.name hr_name
	from pa_deductions_all pded,pa_projects_all pa
	,po_vendors v, po_vendor_sites_all vs,hr_organization_units hr
	where pa.project_id=pded.project_id and
	pded.vendor_id= v.vendor_id and pded.vendor_site_id=vs.vendor_site_id
	and pa.org_id=hr.organization_id
	and pded.deduction_req_id = p_dctn_req_id;

CURSOR C4 is
   select lookup.description reason,
     pta.task_number task_num,
     al.expenditure_type exp_type,
     hr.name exp_org,
     al.amount
	from AP_INVOICE_LINES_INTERFACE al
	, ap_interface_rejections ar,
	AP_INVOICES_INTERFACE ad,
	pa_tasks pta,hr_organization_units hr,
	fnd_lookup_values lookup
	where ar.parent_id=al.invoice_line_id
	and ar.parent_table='AP_INVOICE_LINES_INTERFACE'
	and al.invoice_id=ad.invoice_id
	and ad.product_table = 'PA_DEDUCTIONS_ALL'
	and al.task_id=pta.task_id
	and hr.organization_id=al.expenditure_organization_id
	and ar.reject_lookup_code = lookup.lookup_code
	and lookup.lookup_type='REJECT CODE'
	 and view_application_id=200
	 and lookup.language=USERENV('LANG')
	and   ad.reference_key1 = p_dctn_req_id;


  CURSOR C5 IS
      select lookup.description reason
   	from  ap_interface_rejections ar,
	AP_INVOICES_INTERFACE ad,
		fnd_lookup_values lookup
	where ar.parent_id=ad.invoice_id
	and ar.parent_table='AP_INVOICES_INTERFACE'
	and ad.product_table = 'PA_DEDUCTIONS_ALL'
	and ar.reject_lookup_code = lookup.lookup_code
	and lookup.lookup_type='REJECT CODE'
	 and view_application_id=200
	 and lookup.language=USERENV('LANG')
	and   ad.reference_key1 = p_dctn_req_id;


    l_ap_inv_int_rec         C1%ROWTYPE;
    l_dctn_req_hdr           C2%ROWTYPE;
    l_report_rec             C3%ROWTYPE;
   reject_dtls_rec           C4%ROWTYPE;
    reject_hdr_rec           C5%ROWTYPE;

     -- report related fields
  l_row_num_len      NUMBER := 11;
  l_contract_num_len NUMBER := 15;
  l_asset_num_len    NUMBER := 20;
  l_lessee_len       NUMBER := 25;
  l_sty_subclass_len NUMBER := 25;
  l_reject_code_len  NUMBER := 45;
  l_max_len          NUMBER := 150;
  l_prompt_len       NUMBER := 35;


  l_str_row_num      VARCHAR2(5);
  l_str_contract_num VARCHAR2(30);
  l_str_lessee       VARCHAR2(50);
  l_content          VARCHAR2(1000);
  l_header_len       NUMBER;
  counter  NUMBER;
  hdrcount NUMBER := 0;
  G_APP_NAME VARCHAR2(3) :='PA';

Begin
  g_api_name := 'Import_DebitMemo';

     log_message ('In Import process', g_api_name);

     SELECT FND_GLOBAL.CONC_REQUEST_ID
     INTO   p_conc_request_id
     FROM   DUAL;

     IF P_DEBUG_MODE = 'Y' THEN
        log_message ('Conc request id'||p_conc_request_id, g_api_name);
     END IF;

     OPEN C2;
     FETCH C2 INTO l_dctn_req_hdr;
     CLOSE C2;

     OPEN C1;
     FETCH C1 INTO l_ap_inv_int_rec;
     IF C1%NOTFOUND THEN

        IF P_DEBUG_MODE = 'Y' THEN
          log_message ('Interface records not found, Interface failed', g_api_name);
        END IF;


        Update_Deduction_Status(p_dctn_req_id,
                                'REJECTED');
        CLOSE C1;
       /* AddError_To_Stack( p_error_code => 'PA_DCTN_INT_FAILED'
                          ,p_hdr_or_txn => 'H'
                          ,p_token2_val => l_dctn_req_hdr.deduction_req_num);*/
        RETURN;
     END IF;
     CLOSE C1;

     IF P_DEBUG_MODE = 'Y' THEN
       log_message ('Before calling import API', g_api_name);
     END IF;

     IF AP_IMPORT_INVOICES_PKG.IMPORT_INVOICES(
		p_batch_name,
		p_gl_date,
		p_hold_code,
		p_hold_reason,
		p_commit_cycles,
		'Oracle Project Accounting',
		l_ap_inv_int_rec.group_id,
		p_conc_request_id,
		p_debug_switch,
		l_ap_inv_int_rec.org_id,
		p_batch_error_flag,
		p_invoices_fetched,
		p_invoices_created,
		p_total_invoice_amount,
		p_print_batch,
		'BackEnd')= TRUE THEN

        OPEN C1;
        FETCH C1 INTO l_ap_inv_int_rec;
        CLOSE C1;
        IF l_ap_inv_int_rec.status = 'REJECTED' THEN
          IF P_DEBUG_MODE = 'Y' THEN
           log_message ('Interface process rejected', g_api_name);
          END IF;


           Update_Deduction_Status(p_dctn_req_id,
                                   'FAILED');


       -- fetch header for the report
        OPEN C3;
        FETCH C3 INTO l_report_rec;
        CLOSE C3;
       -- display details in the log
	    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
	    FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET_STRING(G_APP_NAME,'DEDUCTION_NUMBER')||':' || l_report_rec.deduction_req_num);
	    FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET_STRING(G_APP_NAME,'DEBIT_MEMO_NUMBER')||':' ||l_report_rec.debit_memo_num);
	    FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET_STRING(G_APP_NAME,'DEDUCTION_DATE')||':'|| l_report_rec.deduction_req_date);

	      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Payables Interface Status : ' || 'Failed');

	    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');

            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,LPAD(SYSDATE,130));
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_report_rec.hr_name,120));
       -- display the rejected header in the output file
	     l_content := FND_MESSAGE.GET_STRING(G_APP_NAME,'DED_IMP_FAIL_REP');
		l_header_len := LENGTH(l_content);
		l_content :=    RPAD(LPAD(l_content,l_max_len/2),l_max_len/2);    -- center align header
	    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_content);
	       FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
		  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');

	l_content:=RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,'DEDUCTION_NUMBER')||':'|| l_report_rec.deduction_req_num,60)||FND_MESSAGE.GET_STRING(G_APP_NAME,'DEBIT_MEMO_NUMBER')||':' ||l_report_rec.debit_memo_num;
	     FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_content);

	    l_content:=RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,'DEDUCTION_DATE')||':' || l_report_rec.deduction_req_date,60)||FND_MESSAGE.GET_STRING(G_APP_NAME,'DEBIT_MEMO_DATE')||':' || l_report_rec.debit_memo_date;
	     FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_content);

	    l_content:=RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,'PROJECT_NAME')||':' || l_report_rec.name,60)||FND_MESSAGE.GET_STRING(G_APP_NAME,'DEBIT_MEMO_CURRENCY')||':' || l_report_rec.currency_code;
	     FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_content);

	  l_content:=RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,'PROJECT_NUMBER')||':' || l_report_rec.segment1,60)||FND_MESSAGE.GET_STRING(G_APP_NAME,'SUPPLIER_NAME')||':' || l_report_rec.vendor_name;
	     FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_content);

	     l_content:=RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,'PAYABLES_INTERFACE_STATUS')||':'|| 'Failed',60)||FND_MESSAGE.GET_STRING(G_APP_NAME,'SUPPLIER_SITE')||':' || l_report_rec.vendor_site_code;
	     FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_content);


	    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');

-- check if failure at header level or line level
       FOR reject_hdr_rec IN C5
       LOOP
       hdrcount:=hdrcount+1;
       END LOOP;

      IF hdrcount > 0 THEN -- header level failure

      l_content:=RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,'REASON_FOR_FAILURE'),20);
       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_content);
      FOR reject_hdr_rec IN C5
       LOOP
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,reject_hdr_rec.reason);
       END LOOP;

      ELSE --lines level failure
        -- Failed records report header

	     l_content :=  FND_MESSAGE.GET_STRING(G_APP_NAME,'DED_PAY_IMP_FAIL_REP');
		l_header_len := LENGTH(l_content);
		l_content :=    RPAD(LPAD(l_content,l_max_len/2),l_max_len/2);    -- center align header
	    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_content);

		l_content := RPAD('=',l_header_len,'=');                           -- underline header
		l_content := RPAD(LPAD(l_content,l_max_len/2),l_max_len/2,'=');    -- center align
	    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_content);

	    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
	    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');


        -- Table header
		l_content :=    RPAD('-',l_row_num_len-1,'-') || ' '
	             || RPAD('-',l_contract_num_len-1,'-') || ' '
	             || RPAD('-',l_asset_num_len-1,'-') || ' '
				 || RPAD('-',l_lessee_len-1,'-') || ' '
				 || RPAD('-',l_sty_subclass_len-1,'-') || ' '
				 || RPAD('-',l_reject_code_len-1,'-');

       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_content);

       l_content :=    RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,'SERIAL_NO'),l_row_num_len-1) || ' '
	                || RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,'TASK_NUMBER'),l_contract_num_len-1) || ' '
	                || RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,'EXPENDITURE_TYPE'),l_asset_num_len-1) || ' '
                    || RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,'EXPENDITURE_ORG'),l_lessee_len-1) || ' '
                    || RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,'DEB_MEM_AMT'),l_sty_subclass_len-1) || ' '
                    || RPAD(FND_MESSAGE.GET_STRING(G_APP_NAME,'REASON_FOR_FAILURE'),l_reject_code_len-1);



       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_content);

           l_content :=    RPAD('-',l_row_num_len-1,'-') || ' '
	             || RPAD('-',l_contract_num_len-1,'-') || ' '
	             || RPAD('-',l_asset_num_len-1,'-') || ' '
				 || RPAD('-',l_lessee_len-1,'-') || ' '
				 || RPAD('-',l_sty_subclass_len-1,'-') || ' '
				 || RPAD('-',l_reject_code_len-1,'-');

       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_content);

       -- initialize counter for serial number
        counter:=0;

        -- get details of the rejected records
        FOR reject_dtls_rec IN C4

		   LOOP
                    counter:=counter+1;
		l_content :=    RPAD(counter,l_row_num_len-1) || ' '
	                || RPAD(reject_dtls_rec.task_num,l_contract_num_len-1) || ' '
	                || RPAD(reject_dtls_rec.exp_type,l_asset_num_len-1) || ' '
                    || RPAD(reject_dtls_rec.exp_org,l_lessee_len-1) || ' '
                    || RPAD(reject_dtls_rec.amount,l_sty_subclass_len-1) || ' '
                    || RPAD(reject_dtls_rec.reason,l_reject_code_len-1);

               FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_content);

		   END LOOP;
       END IF;

       -- delete the failed records from interface and Ap
           Delete_Failed_Rec(p_dctn_req_id);

        ELSE
         IF P_DEBUG_MODE = 'Y' THEN
           log_message ('Interface process successful', g_api_name);
         END IF;
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Import Process successful');
           Update_Deduction_Status(p_dctn_req_id,
                                   'PROCESSED');

        END IF;
     Else

        IF P_DEBUG_MODE = 'Y' THEN
          log_message ('Import process failed', g_api_name);
        END IF;

        Update_Deduction_Status(p_dctn_req_id,
                                'FAILED');

        Delete_Failed_Rec(p_dctn_req_id);


        RETURN;
     End If;

   ret_code := 0;

   EXCEPTION
     WHEN OTHERS THEN
       IF P_DEBUG_MODE = 'Y' THEN
        log_message ('In Others Exceptions :'||SQLERRM, g_api_name);
       END IF;
      errbuf := SQLERRM;
       ret_code := 2;
        Delete_Failed_Rec(p_dctn_req_id);

        Update_Deduction_Status(p_dctn_req_id,
                                'FAILED');


   End Import_DebitMemo;

  PROCEDURE log_message (p_log_msg IN VARCHAR2,p_proc_name VARCHAR2) IS
  BEGIN
      pa_debug.write('log_message: ' || p_proc_name, 'log: ' || p_log_msg, 3);
  END log_message;

  PROCEDURE Delete_Failed_Rec(p_dctn_req_id NUMBER) IS
  BEGIN
  NULL;

        DELETE AP_INVOICE_LINES_INTERFACE WHERE invoice_id IN(
              SELECT invoice_id FROM AP_INVOICES_INTERFACE WHERE
              product_table = 'PA_DEDUCTIONS_ALL' and reference_key1 = to_char(p_dctn_req_id));

        DELETE AP_INVOICES_INTERFACE WHERE
              product_table = 'PA_DEDUCTIONS_ALL' and reference_key1 = to_char(p_dctn_req_id);

        DELETE AP_INVOICE_DISTRIBUTIONS_ALL WHERE invoice_id IN(
              SELECT invoice_id FROM AP_INVOICES_ALL WHERE
              product_table = 'PA_DEDUCTIONS_ALL' and reference_key1 = to_char(p_dctn_req_id));

        DELETE AP_INVOICE_LINES_ALL WHERE invoice_id IN(
              SELECT invoice_id FROM AP_INVOICES_ALL WHERE
              product_table = 'PA_DEDUCTIONS_ALL' and reference_key1 = to_char(p_dctn_req_id));

        DELETE AP_INVOICES_ALL WHERE
              product_table = 'PA_DEDUCTIONS_ALL' and reference_key1 = to_char(p_dctn_req_id);

  END Delete_Failed_Rec;

  Function Validate_DM( p_dctn_hdr       IN OUT NOCOPY g_dctn_hdrtbl
                       ,p_msg_count      OUT NOCOPY NUMBER
                       ,p_msg_data       OUT NOCOPY VARCHAR2
                       ,p_return_status  OUT NOCOPY VARCHAR2
                       ) Return Boolean Is

    CURSOR C1(p_debit_memo_num PA_DEDUCTIONS_ALL.debit_memo_num%TYPE,
              p_org_id         PA_DEDUCTIONS_ALL.org_id%TYPE,
              p_vendor_id      PA_DEDUCTIONS_ALL.vendor_id%TYPE,
              p_dctn_req_id    PA_DEDUCTIONS_ALL.deduction_req_id%TYPE) IS
      SELECT 'N'
      FROM   PA_DEDUCTIONS_ALL
      WHERE  debit_memo_num = p_debit_memo_num
      AND    org_id = p_org_id
      AND    vendor_id = p_vendor_id
      AND    deduction_req_id <> nvl(p_dctn_req_id,-99);

    CURSOR C2(p_debit_memo_num PA_DEDUCTIONS_ALL.debit_memo_num%TYPE,
              p_org_id         PA_DEDUCTIONS_ALL.org_id%TYPE,
              p_vendor_id      PA_DEDUCTIONS_ALL.vendor_id%TYPE) IS
      SELECT 'N'
      FROM   DUAL WHERE EXISTS (
                     SELECT 1
                     FROM   AP_INVOICES_ALL
                     WHERE  invoice_num = p_debit_memo_num
                     AND    vendor_id = p_vendor_id
                     AND    org_id = p_org_id
                     UNION ALL
                     SELECT 1
                     FROM   AP_INVOICES_INTERFACE
                     WHERE  invoice_num = p_debit_memo_num
                     AND    vendor_id = p_vendor_id
                     AND    org_id = p_org_id
                     AND    nvl(status, 'REJECTED') <> 'REJECTED');

    is_debit_memo_unique VARCHAR2(1) := 'Y';
    l_next_number        PA_DEDUCTIONS_ALL.debit_memo_num%TYPE;

    l_msg_count NUMBER;
    l_msg_data  VARCHAR2(4000);
    l_return_status VARCHAR2(1);
  Begin
    g_api_name := 'Validate_DM';
    p_return_status := 'S';

    IF P_DEBUG_MODE = 'Y' THEN
       log_message ('In validate debit memo procedure', g_api_name);
    END IF;

    FND_MSG_PUB.initialize;

    IF P_DEBUG_MODE = 'Y' THEN
       log_message ('DMNO '||p_dctn_hdr(1).debit_memo_num||' Org '||p_dctn_hdr(1).org_id||
                    ' Vendor Id '||p_dctn_hdr(1).vendor_id|| ' Deduction req id '||
                    p_dctn_hdr(1).deduction_req_id,'Validate Header');

    END IF;
    l_next_number := p_dctn_hdr(1).debit_memo_num ; /* 9401673 */

--    Calling the client extension even in the case of the debit memo number is entered by the user.
--    So, whatever the client extension returns is the final debit memo number. By default, Client extension
--    returts the same value, which is passed to it.

--    IF p_dctn_hdr(1).debit_memo_num IS NULL THEN

       IF P_DEBUG_MODE = 'Y' THEN
          log_message ('Before calling client extension', g_api_name);
       END IF;

       PA_DM_NUMBER_CLIENT_EXTN.get_next_number (
              p_project_id           => p_dctn_hdr(1).project_id
             ,p_vendor_id            => p_dctn_hdr(1).vendor_id
             ,p_vendor_site_id       => p_dctn_hdr(1).vendor_site_id
             ,p_org_id               => p_dctn_hdr(1).org_id
             ,p_po_header_id         => p_dctn_hdr(1).po_header_id
             ,p_ci_id                => p_dctn_hdr(1).ci_id
             ,p_dctn_req_date        => p_dctn_hdr(1).deduction_req_date
             ,p_debit_memo_date      => p_dctn_hdr(1).debit_memo_date
             ,p_next_number          => l_next_number
             ,x_return_status        => l_return_status
             ,x_msg_count            => l_msg_count
             ,x_msg_data             => l_msg_data);

        IF P_DEBUG_MODE = 'Y' THEN
           log_message ('After the client extension', g_api_name);

           log_message ('l_next_number '||l_next_number||
                        ' l_return_status '||l_return_status, g_api_name);
        END IF;

        IF l_next_number IS NULL AND l_return_status = 'S' THEN

          IF P_DEBUG_MODE = 'Y' THEN
            log_message ('Generating debit memo number using sequence', g_api_name);
          END IF;

          LOOP
             SELECT PA_DEDUCTIONS_DM_S.nextval
             INTO l_next_number FROM sys.DUAL;

             OPEN C1(l_next_number,
                     p_dctn_hdr(1).org_id,
                     p_dctn_hdr(1).vendor_id,
                     p_dctn_hdr(1).deduction_req_id);
             FETCH C1 INTO is_debit_memo_unique;
             CLOSE C1;

             IF is_debit_memo_unique = 'Y' THEN
                OPEN C2(l_next_number,
                        p_dctn_hdr(1).org_id,
                        p_dctn_hdr(1).vendor_id ) ;
                FETCH C2 INTO is_debit_memo_unique;
                CLOSE C2;
             END IF;

             IF is_debit_memo_unique = 'Y' THEN
                EXIT;
             END IF;
          END LOOP;
          p_dctn_hdr(1).debit_memo_num := l_next_number;
        ELSIF l_next_number IS NOT NULL THEN

          IF P_DEBUG_MODE = 'Y' THEN
            log_message ('validating the sequence generated by client extension', g_api_name);
          END IF;

          IF l_return_status = 'S' THEN

             IF P_DEBUG_MODE = 'Y' THEN
               log_message ('Client extension succesfully returned a debit memo number', g_api_name);

               log_message('return status '||l_return_status, g_api_name);
             END IF;

             OPEN C1(l_next_number,
                     p_dctn_hdr(1).org_id,
                     p_dctn_hdr(1).vendor_id,
                     p_dctn_hdr(1).deduction_req_id);
             FETCH C1 INTO is_debit_memo_unique;
             CLOSE C1;
             IF is_debit_memo_unique = 'N' THEN
                 is_debit_memo_unique := 'Y';
                   IF p_msg_data IS NULL THEN
                      p_return_status := 'E';
                      p_msg_data := 'PA_DCTN_CLX_DM_NUM_EXISTS';
                   END IF;
                  AddError_To_Stack( p_error_code => 'PA_DCTN_CLX_DM_NUM_EXISTS'
                                    ,p_hdr_or_txn => 'H'
                                    ,p_token2_val => l_next_number);
             END IF;

             IF p_msg_data <> 'PA_DCTN_CLX_DM_NUM_EXISTS' THEN
                OPEN C2(l_next_number,
                        p_dctn_hdr(1).org_id,
                        p_dctn_hdr(1).vendor_id ) ;
                FETCH C2 INTO is_debit_memo_unique;
                CLOSE C2;
               IF is_debit_memo_unique = 'N' THEN
                  is_debit_memo_unique := 'Y';
                   IF p_msg_data IS NULL THEN
                      p_return_status := 'E';
                      p_msg_data := 'PA_DCTN_CLX_DM_NUM_EXISTS';
                   END IF;

                   AddError_To_Stack( p_error_code => 'PA_DCTN_CLX_DM_NUM_EXISTS'
                                     ,p_hdr_or_txn => 'H'
                                     ,p_token2_val => l_next_number);
               END IF;
             END IF;
             p_dctn_hdr(1).debit_memo_num := l_next_number;

          ELSIF l_return_status = 'E' THEN
            IF P_DEBUG_MODE = 'Y' THEN
             log_message ('Client extension failed while returning the sequence number', g_api_name);
            END IF;

             p_msg_count      := l_msg_count;
             p_msg_data       := l_msg_data;
             p_return_status  := l_return_status;
          END IF;
        END IF;
  --  END IF;

    IF p_return_status = 'S' THEN
       RETURN TRUE;
    ELSE
       RETURN FALSE;
    END IF;
  End Validate_DM;

  /*---------------------------------------------------------------------------------------------------------
    -- This function is to return the list of invoices which are assoiciated to a debit memo that is created
    -- out of a deduction request.
    -- Input parameters
    -- Parameters                Type           Required  Description
    --  p_vendor_Id              NUMBER         YES       vendor id
    --  p_vendor_site_id         NUMBER         YES       vendor site id
    --  ded_req_num              VARCHAR2       YES       deduction request id
  ----------------------------------------------------------------------------------------------------------*/
  Function Invoice_Dm_Map(p_vendor_id NUMBER,
                          p_vendor_site_id NUMBER,
                          ded_req_num IN VARCHAR2) RETURN VARCHAR2 IS
   CURSOR C1 IS
   SELECT invoice_num
   FROM   ap_invoices_all apinv
   WHERE  apinv.vendor_id = p_vendor_id
   AND    apinv.vendor_site_id = p_vendor_site_id
   AND   EXISTS
           (SELECT 1 FROM ap_invoice_distributions_all
            WHERE  invoice_id = apinv.invoice_id
            AND    parent_invoice_id =  ( SELECT invoice_id from ap_invoices_all
                                          WHERE  source = 'Oracle Project Accounting'
                                          AND    invoice_type_lookup_code = 'DEBIT'
                                          AND    product_table='PA_DEDUCTIONS_ALL'
                                          AND    reference_key1 = ded_req_num));

   rval VARCHAR2(300) := NULL;
  BEGIN
   g_api_name := 'Invoice_DM_Map';
   FOR arec in C1 LOOP
       if(rval is NULL)  then
          rval := arec.invoice_num;
       else
          rval := rval || ',' || arec.invoice_num;
       end if;
   END LOOP;
   return rval;
  EXCEPTION
  WHEN OTHERS THEN
    return '';
  END;

  Procedure AddError_To_Stack( p_error_code VARCHAR2
                              ,p_hdr_or_txn VARCHAR2 := 'H'
                              ,p_token1_val VARCHAR2 :=''
                              ,p_token2_val VARCHAR2 :=''
                              ,p_token3_val VARCHAR2 :=''
                              ,p_token4_val VARCHAR2 :='') IS
  BEGIN
	FND_MESSAGE.SET_NAME  ('PA',p_error_code);

    IF  p_hdr_or_txn = 'T' THEN
    	FND_MESSAGE.SET_TOKEN ('LINE_NO', 'Line no: '||p_token1_val||' ');

        IF p_error_code = 'PA_EIDATE_NOT_MORETHAN_DRDATE' THEN
           FND_MESSAGE.SET_TOKEN ('EIDATE', p_token2_val);
	       FND_MESSAGE.SET_TOKEN ('DRDATE', p_token3_val);
        END IF;

       IF p_error_code = 'PA_RTDATE_NOT_MORETHAN_DRDATE' THEN
          FND_MESSAGE.SET_TOKEN ('RTDATE', p_token2_val);
	      FND_MESSAGE.SET_TOKEN ('DRDATE', p_token3_val);
       END IF;
        IF p_error_code = 'PA_DED_EXP_INV_TYPE' THEN
          FND_MESSAGE.SET_TOKEN ('EID', p_token2_val);
       END IF;
       END IF;

    IF p_hdr_or_txn = 'H' THEN
        IF p_error_code = 'PA_DCTN_HDR_NOT_EXISTS' THEN
           FND_MESSAGE.SET_TOKEN ('REQ_NUM', p_token2_val);
        END IF;

        IF p_error_code = 'PA_DCTN_IMPORT_FAILED' THEN
           FND_MESSAGE.SET_TOKEN ('DEB_MEMO_NUM', p_token2_val);
           FND_MESSAGE.SET_TOKEN ('REQ_NUM', p_token3_val);
        END IF;

        IF p_error_code = 'PA_DCTN_INT_FAILED' THEN
           FND_MESSAGE.SET_TOKEN ('REQ_NUM', p_token2_val);
        END IF;

        IF p_error_code = 'PA_DCTN_CLX_DM_NUM_EXISTS' THEN
           FND_MESSAGE.SET_TOKEN ('DEB_MEMO_NUM', p_token2_val);
        END IF;
    END IF;

	FND_MSG_PUB.Add;
  END;

  /*Bug#9498500:Moved the procedure validate_unprocessed_ded() to PAAPVALS/B.pls
 ---------------------------------------------------------------------------------------------------------
    -- Bug 9307667
	--  This procedure is to validate a retention invoice in payables. This is being called from Payables
    -- Input parameters
    --  Parameters                Type           Required  Description
    --  invoice_id              NUMBER         YES          invoice_id being validated
	-- cmt_exist_flag           VARCHAR                     returns whether unprocessed dedns exist
     ---------------------------------------------------------------------------------------------------------
	 Procedure validate_unprocessed_ded ( invoice_id IN ap_invoices_all.invoice_id%type,
	                                       cmt_exist_flag OUT NOCOPY VARCHAR2)

*/


END PA_DEDUCTIONS;

/
