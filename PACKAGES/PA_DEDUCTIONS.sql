--------------------------------------------------------
--  DDL for Package PA_DEDUCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_DEDUCTIONS" AUTHID CURRENT_USER AS
-- /* $Header: PADCTNSS.pls 120.2.12010000.5 2010/03/29 13:29:54 sesingh noship $ */

  CURSOR cur_dctn_hdr_info (c_dctn_req_id NUMBER) IS
     SELECT *
     FROM PA_DEDUCTIONS_ALL WHERE deduction_req_id = c_dctn_req_id AND status IN('WORKING','REJECTED','FAILED');

  cur_dctn_hdr               cur_dctn_hdr_info%ROWTYPE;

  TYPE g_dctn_hdrid IS TABLE OF PA_DEDUCTIONS_ALL.DEDUCTION_REQ_ID%TYPE INDEX BY BINARY_INTEGER;

  TYPE g_dctn_txnid IS TABLE OF PA_DEDUCTION_TRANSACTIONS_ALL.DEDUCTION_REQ_TRAN_ID%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE g_dctn_hdr_rec IS RECORD (
          deduction_req_id       NUMBER(15),
          project_id             NUMBER(15),
          vendor_id              NUMBER(15),
          vendor_site_id         NUMBER,
          change_doc_num         VARCHAR2(30),
          change_doc_type        VARCHAR2(15),
          ci_id                  NUMBER,
          po_number              VARCHAR2(20),
          po_header_id           NUMBER,
          deduction_req_num      VARCHAR2(30),
          debit_memo_num         VARCHAR2(30),
          currency_code          VARCHAR2(30),
          conversion_ratetype    VARCHAR2(30),
          conversion_ratedate    DATE,
          conversion_rate        NUMBER,
          total_amount           NUMBER,
          deduction_req_date     DATE,
          debit_memo_date        DATE,
          description            VARCHAR2(4000),
          status                 VARCHAR2(15),
          org_id                 NUMBER
         );

  TYPE g_dctn_txn_rec IS RECORD (
          deduction_req_id           NUMBER(15),
          deduction_req_tran_id      NUMBER(15),
          project_id                 NUMBER(15),
          task_id                    NUMBER(15),
          expenditure_type           VARCHAR2(30),
          expenditure_item_date      DATE,
          gl_date                    DATE,
          expenditure_org_id         NUMBER(15),
          quantity                   NUMBER,
          override_quantity          NUMBER,
          expenditure_item_id        NUMBER(15),
          projfunc_currency_code     VARCHAR2(30),
          orig_projfunc_amount       NUMBER,
          override_projfunc_amount   NUMBER,
          conversion_ratetype        VARCHAR2(30),
          conversion_ratedate        DATE,
          conversion_rate            NUMBER,
          amount                     NUMBER,
          description                VARCHAR2(4000),
          status                     VARCHAR2(15)
         );

  TYPE g_dctn_hdrtbl IS TABLE OF g_dctn_hdr_rec INDEX BY BINARY_INTEGER;
  TYPE g_dctn_txntbl IS TABLE OF g_dctn_txn_rec INDEX BY BINARY_INTEGER;

  g_validate_txn VARCHAR2(1) := 'N';
  g_user_id NUMBER(15) := FND_GLOBAL.USER_ID;

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

  Procedure Create_Deduction_Hdr( p_dctn_hdr IN OUT NOCOPY g_dctn_hdrtbl
                                 ,p_msg_count OUT NOCOPY NUMBER
                                 ,p_msg_data OUT NOCOPY VARCHAR2
                                 ,p_return_status OUT NOCOPY VARCHAR2
                                 ,p_calling_mode IN VARCHAR2
                                );

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
  Procedure Create_Deduction_Txn( p_dctn_dtl IN OUT NOCOPY g_dctn_txntbl
                                 ,p_msg_count OUT NOCOPY NUMBER
                                 ,p_msg_data OUT NOCOPY VARCHAR2
                                 ,p_return_status OUT NOCOPY VARCHAR2
                                 ,p_calling_mode IN VARCHAR2
                                );


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
  Procedure Update_Deduction_Hdr( p_dctn_hdr IN OUT NOCOPY g_dctn_hdrtbl
                                 ,p_msg_count OUT NOCOPY NUMBER
                                 ,p_msg_data OUT NOCOPY VARCHAR2
                                 ,p_return_status OUT NOCOPY VARCHAR2
                                 ,p_calling_mode IN VARCHAR2
                                );

  /*---------------------------------------------------------------------------------------------------------
    -- This procedure is to update existing data in PA_DEDUCTION_TRANSACTIONS_ALL table after validating the data.
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
                                 ,p_msg_count OUT NOCOPY NUMBER
                                 ,p_msg_data OUT NOCOPY VARCHAR2
                                 ,p_return_status OUT NOCOPY VARCHAR2
                                 ,p_calling_mode IN VARCHAR2
                                );

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
                                 ,p_msg_data OUT NOCOPY VARCHAR2
                                 ,p_return_status OUT NOCOPY VARCHAR2
                                );

  /*---------------------------------------------------------------------------------------------------------
    -- This procedure is to delete existing data in PA_DEDUCTION_TRANSACTIONS_ALL table after validating the data.
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

  Procedure Delete_Deduction_Txn(p_dctn_txnid g_dctn_txnid
                                 ,p_msg_count OUT NOCOPY NUMBER
                                 ,p_msg_data OUT NOCOPY VARCHAR2
                                 ,p_return_status OUT NOCOPY VARCHAR2
                                );

  /*---------------------------------------------------------------------------------------------------------
    -- This procedure is to validate Deduction header information and return the result to the called proc.
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
                                   ,p_msg_data OUT NOCOPY VARCHAR2
                                   ,p_return_status OUT NOCOPY VARCHAR2
                                   ,p_calling_mode IN VARCHAR2:=''
                                  )
  Return Boolean;

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
                                   ,p_msg_data OUT NOCOPY VARCHAR2
                                   ,p_return_status OUT NOCOPY VARCHAR2
                                   ,p_calling_mode IN VARCHAR2:=''
                                  )
  Return Boolean;

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
                                  ,p_msg_data OUT NOCOPY VARCHAR2
                                  ,p_return_status OUT NOCOPY   VARCHAR2
                                 );

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
                                 );

  /*---------------------------------------------------------------------------------------------------------
    -- This function is to return the list of invoices which are assoiciated to a debit memo that is created
    -- out of a deduction request.
    -- Input parameters
    -- Parameters                Type           Required  Description
    --  p_vendor_Id              NUMBER         YES       vendor id
    --  p_vendor_site_id         NUMBER         YES       vendor site id
    --  ded_req_num              VARCHAR2       YES       deduction request id
  ----------------------------------------------------------------------------------------------------------*/
  function invoice_dm_map(p_vendor_id      NUMBER,
                          p_vendor_site_id NUMBER,
                          ded_req_num IN VARCHAR2) return VARCHAR2;



  /*---------------------------------------------------------------------------------------------------------
    --  This procedure is to raise a debit memo in payables. This is being called from concurrenmt program
    -- Input parameters
    --  Parameters                Type           Required  Description
    --  p_dctn_req_id              NUMBER         YES       deduction request id
     ----------------------------------------------------------------------------------------------------------*/
Procedure Import_DebitMemo ( errbuf OUT NOCOPY varchar2,
                            ret_code OUT NOCOPY varchar2,
                            p_dctn_req_id IN NUMBER
                                 );

/*Bug#9498500:Moved the procedure validate_unprocessed_ded() to PAAPVALS/B.pls
---------------------------------------------------------------------------------------------------------
    --  This procedure is to validate a retention invoice in payables. This is being called from Payables
    -- Input parameters
    --  Parameters                Type           Required  Description
    --  invoice_id              NUMBER         YES          invoice_id being validated
    -- cmt_exist_flag           VARCHAR                     returns whether unprocessed dedns exist
	----------------------------------------------------------------------------------------------------------
	Procedure validate_unprocessed_ded ( invoice_id IN ap_invoices_all.invoice_id%type,
			        	cmt_exist_flag OUT NOCOPY VARCHAR2);
*/

END PA_DEDUCTIONS;

/
