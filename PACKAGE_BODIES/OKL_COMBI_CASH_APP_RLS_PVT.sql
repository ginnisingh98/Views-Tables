--------------------------------------------------------
--  DDL for Package Body OKL_COMBI_CASH_APP_RLS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_COMBI_CASH_APP_RLS_PVT" AS
/* $Header: OKLRCAAB.pls 120.6 2008/01/08 12:14:18 asawanka noship $ */
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.RECEIVABLES.SETUP';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator

---------------------------------------------------------------------------
-- Function get_req_recs
---------------------------------------------------------------------------

FUNCTION get_req_recs(invoice VARCHAR) RETURN BOOLEAN IS
is_in        BOOLEAN DEFAULT TRUE;
i            NUMBER;
BEGIN
    i := 0;
    LOOP
        i := i + 1;
        IF l_scn_rcpt_tbl(i).invoice_number = invoice THEN
            is_in:= FALSE;
        END IF;
        EXIT WHEN i = l_scn_rcpt_tbl.LAST;
    END LOOP;
   RETURN(is_in);
END get_req_recs;

---------------------------------------------------------------------------
-- PROCEDURE handle_combi_pay
---------------------------------------------------------------------------

PROCEDURE handle_combi_pay
                (  p_api_version	     IN	 NUMBER
 	               ,p_init_msg_list    IN	 VARCHAR2 DEFAULT OKC_API.G_FALSE
	               ,x_return_status    OUT NOCOPY VARCHAR2
	               ,x_msg_count	     OUT NOCOPY NUMBER
	               ,x_msg_data	     OUT NOCOPY VARCHAR2
                   ,p_customer_number  IN  VARCHAR2
                   ,p_rcpt_amount      IN  NUMBER
                   ,p_org_id           IN  NUMBER
                   ,p_currency_code    IN VARCHAR2
                   ,x_appl_tbl         OUT NOCOPY okl_auto_cash_appl_rules_pvt.okl_appl_dtls_tbl_type
               ) IS

---------------------------
-- DECLARE Local Variables
---------------------------

  l_customer_number             VARCHAR2(30) DEFAULT p_customer_number;
  l_cons_inv_number             VARCHAR2(30) DEFAULT NULL;
  l_ar_inv_number             VARCHAR2(30) DEFAULT NULL;
  l_contract_number             VARCHAR2(30) DEFAULT NULL;
  l_due_date                    DATE DEFAULT NULL;
  l_rcpt_amount                 NUMBER DEFAULT p_rcpt_amount;

  l_org_id                       Number:=p_org_id;
  l_match_found                 NUMBER DEFAULT 0;
  l_currency_code               ar_cash_receipts.currency_code%TYPE DEFAULT p_currency_code;

  l_api_version			        NUMBER := 1.0;
  l_init_msg_list		        VARCHAR2(1) := FND_API.G_FALSE;
  l_return_status		        VARCHAR2(1);
  l_msg_count			        NUMBER;
  l_msg_data			        VARCHAR2(2000);

------------------------------
-- DECLARE Record/Table Types
------------------------------
l_appl_tbl    okl_auto_cash_appl_rules_pvt.okl_appl_dtls_tbl_type;
-------------------
-- DECLARE Cursors
-------------------

  -- get unique cons bill numbers
  CURSOR c_get_cons_invs(cp_cust_num IN VARCHAR2,cp_org_id IN NUMBER) IS
  SELECT distinct(consolidated_invoice_number), due_date
  FROM   okl_rcpt_consinv_balances_uv
  WHERE  customer_number = cp_cust_num
  AND org_id= cp_org_id
  ORDER BY due_date;

----------

  -- get unique contract number
  CURSOR c_get_contract(cp_cust_num IN VARCHAR2,cp_org_id IN NUMBER) IS
  SELECT distinct(contract_number)
  FROM   okl_rcpt_cust_cont_balances_uv
  WHERE  customer_number = cp_cust_num
    AND org_id= cp_org_id
  ORDER BY invoice_due_date;

  -- need to find due or start date for contracts and order by that.
---------------

  -- get unique ar invoice numbers
  CURSOR c_get_ar_invs(cp_cust_num IN VARCHAR2,cp_org_id IN NUMBER) IS
   SELECT distinct(invoice_number), invoice_due_date due_date
  FROM   okl_rcpt_arinv_balances_uv
  WHERE  customer_number = cp_cust_num
    AND org_id= cp_org_id
  ORDER BY invoice_due_date;


----------


BEGIN

    l_cons_inv_number := NULL;
    l_contract_number := NULL;

    OPEN c_get_ar_invs (l_customer_number,l_org_id); -- search by ar invoice(s)
    LOOP
        FETCH c_get_ar_invs INTO l_ar_inv_number,l_due_date;
        EXIT WHEN c_get_ar_invs%NOTFOUND;

        search_combi ( p_api_version	 => l_api_version
   	                  ,p_init_msg_list   => p_init_msg_list
		              ,x_return_status   => l_return_status
		              ,x_msg_count	     => l_msg_count
			           ,x_msg_data	     => l_msg_data
                      ,p_customer_number => l_customer_number
   	                  ,p_cons_inv_number => l_cons_inv_number
		               ,p_contract_number => l_contract_number
                      ,p_ar_inv_number => l_ar_inv_number
                      ,p_org_id        => l_org_id
                      ,p_rcpt_amount     => l_rcpt_amount
                      ,p_currency_code   => l_currency_code
                      ,x_match_found     => l_match_found
                      ,x_appl_tbl        => l_appl_tbl
                     );


        x_return_status := l_return_status;
        x_msg_data      := l_msg_data;
        x_msg_count     := l_msg_count;

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        IF l_match_found = 1 THEN
            EXIT;
        END IF;

    END LOOP;
    CLOSE c_get_ar_invs;

 IF l_match_found = 0 THEN

   l_contract_number := NULL;
   l_ar_inv_number :=NULL;

   OPEN c_get_cons_invs (l_customer_number,l_org_id);           -- search by consolidated inv related invoice(s)
  LOOP
    FETCH c_get_cons_invs INTO l_cons_inv_number, l_due_date;
    EXIT WHEN c_get_cons_invs%NOTFOUND;

    search_combi ( p_api_version	 => l_api_version
                  ,p_init_msg_list   => l_init_msg_list
    	           ,x_return_status   => l_return_status
		           ,x_msg_count	     => l_msg_count
		           ,x_msg_data	     => l_msg_data
                  ,p_customer_number => l_customer_number
   	              ,p_cons_inv_number => l_cons_inv_number
		          ,p_contract_number => l_contract_number
                  ,p_ar_inv_number => l_ar_inv_number
                  ,p_org_id        => l_org_id
                  ,p_rcpt_amount     => l_rcpt_amount
                  ,p_currency_code   => l_currency_code
                  ,x_match_found     => l_match_found
                  ,x_appl_tbl        => l_appl_tbl
                 );

    x_return_status := l_return_status;
    x_msg_data      := l_msg_data;
    x_msg_count     := l_msg_count;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF l_match_found = 1 THEN
        EXIT;
    END IF;

   END LOOP;
  CLOSE c_get_cons_invs;

 END IF;

  IF l_match_found = 0 THEN                           -- search by contract related invoice(s)

    l_cons_inv_number := NULL;
    l_ar_inv_number :=NULL;

    OPEN c_get_contract (l_customer_number,l_org_id);
    LOOP
        FETCH c_get_contract INTO l_contract_number;
        EXIT WHEN c_get_contract%NOTFOUND;

        search_combi ( p_api_version	 => l_api_version
   	                  ,p_init_msg_list   => p_init_msg_list
		              ,x_return_status   => l_return_status
		               ,x_msg_count	     => l_msg_count
			              ,x_msg_data	     => l_msg_data
                      ,p_customer_number => l_customer_number
   	                  ,p_cons_inv_number => l_cons_inv_number
		               ,p_contract_number => l_contract_number
                      ,p_ar_inv_number => l_ar_inv_number
                      ,p_org_id        => l_org_id
                      ,p_rcpt_amount     => l_rcpt_amount
                      ,p_currency_code   => l_currency_code
                      ,x_match_found     => l_match_found
                      ,x_appl_tbl        => l_appl_tbl
                     );


        x_return_status := l_return_status;
        x_msg_data      := l_msg_data;
        x_msg_count     := l_msg_count;

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        IF l_match_found = 1 THEN
            EXIT;
        END IF;

    END LOOP;
    CLOSE c_get_contract;

END IF;


IF l_match_found = 0 THEN                           -- all out search because still no match.

    l_cons_inv_number := NULL;
    l_contract_number := NULL;
    l_ar_inv_number := NULL;

    search_combi ( p_api_version	 => l_api_version
   	              ,p_init_msg_list   => p_init_msg_list
	              ,x_return_status   => l_return_status
	              ,x_msg_count	     => l_msg_count
		          ,x_msg_data	     => l_msg_data
                  ,p_customer_number => l_customer_number
   	              ,p_cons_inv_number => l_cons_inv_number
		          ,p_contract_number => l_contract_number
                  ,p_ar_inv_number => l_ar_inv_number
                  ,p_org_id        => l_org_id
                  ,p_rcpt_amount     => l_rcpt_amount
                  ,p_currency_code   => l_currency_code
                  ,x_match_found     => l_match_found
                  ,x_appl_tbl        => l_appl_tbl
                 );

    x_return_status := l_return_status;
    x_msg_data      := l_msg_data;
    x_msg_count     := l_msg_count;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

END IF;

x_appl_tbl:= l_appl_tbl;

EXCEPTION

    WHEN OTHERS THEN
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;

END handle_combi_pay;


PROCEDURE search_combi
                ( p_api_version	     IN	 NUMBER
   	             ,p_init_msg_list    IN	 VARCHAR2 DEFAULT OKC_API.G_FALSE
	             ,x_return_status    OUT NOCOPY VARCHAR2
	             ,x_msg_count	     OUT NOCOPY NUMBER
	             ,x_msg_data	     OUT NOCOPY VARCHAR2
                 ,p_customer_number  IN	 VARCHAR2
                 ,p_cons_inv_number  IN	 VARCHAR2
	             ,p_contract_number  IN  VARCHAR2
                 ,p_ar_inv_number    IN	 VARCHAR2
                 ,p_org_id           IN NUMBER
                 ,p_rcpt_amount      IN  NUMBER
                 ,p_currency_code   IN VARCHAR2
                 ,x_match_found      OUT NOCOPY NUMBER
                 ,x_appl_tbl         OUT NOCOPY okl_auto_cash_appl_rules_pvt.okl_appl_dtls_tbl_type
                 ) IS

---------------------------
-- DECLARE Local Variables
---------------------------


  l_org_id                      NUMBER := p_org_id;

  l_customer_number             VARCHAR2(30) DEFAULT p_customer_number;
  l_cons_inv_number             VARCHAR2(30) DEFAULT p_cons_inv_number;
  l_contract_number             VARCHAR2(30) DEFAULT p_contract_number;
  l_ar_inv_number               VARCHAR2(30) DEFAULT p_ar_inv_number;

  l_sty_id                      OKL_SRCH_STRM_TYPS.STY_ID%TYPE DEFAULT NULL;
  l_amount_due_remaining        NUMBER DEFAULT NULL;
   l_currency_code               ar_cash_receipts.currency_code%TYPE DEFAULT p_currency_code;

  l_running_total               NUMBER DEFAULT NULL;
  l_rcpt_amount                 NUMBER DEFAULT p_rcpt_amount;
  l_receivables_invoice_number  NUMBER DEFAULT NULL;

  l_inv_tot                     NUMBER DEFAULT NULL;

  l_count                       NUMBER DEFAULT NULL;
  l_init_count                  NUMBER DEFAULT NULL;
  l_next_rule                   NUMBER DEFAULT 0;
  l_match_found                 NUMBER DEFAULT 0;

  i                             NUMBER DEFAULT NULL;            -- for scn table count
  j                             NUMBER DEFAULT NULL;            -- for ttl table count
  k                             NUMBER DEFAULT NULL;            -- for tmc table count

  l_cah_id                      OKL_SRCH_STRM_TYPS.CAH_ID%TYPE DEFAULT NULL;
  l_seq_num                     OKL_CSH_ALLCT_SRCHS.SEQUENCE_NUMBER%TYPE DEFAULT NULL;
  l_csh_type                    OKL_CSH_ALLCT_SRCHS.CASH_SEARCH_TYPE%TYPE DEFAULT NULL;

  l_rule_sty_id                 OKL_SRCH_STRM_TYPS.STY_ID%TYPE DEFAULT NULL;
  l_add_yn                      OKL_SRCH_STRM_TYPS.ADD_YN%TYPE DEFAULT NULL;

  l_api_version			        NUMBER := 1.0;
  l_init_msg_list		        VARCHAR2(1) := FND_API.G_FALSE;
  l_return_status		        VARCHAR2(1);
  l_msg_count			        NUMBER;
  l_msg_data			        VARCHAR2(2000);

------------------------------
-- DECLARE Record/Table Types
------------------------------
l_appl_tbl    okl_auto_cash_appl_rules_pvt.okl_appl_dtls_tbl_type;
l_scn_rcpt_tbl  okl_auto_cash_appl_rules_pvt.okl_rcpt_dtls_tbl_type;
l_tmc_rcpt_tbl  okl_auto_cash_appl_rules_pvt.okl_rcpt_dtls_tbl_type;
l_rcpt_tbl    okl_auto_cash_appl_rules_pvt.okl_rcpt_dtls_tbl_type;
-------------------
-- DECLARE Cursors
-------------------

  -- get all open invoices for customer and consolidated invoices
  CURSOR c_open_invs_consinv( cp_customer_num	IN VARCHAR2
                     ,cp_cons_bill_num	IN VARCHAR2
                     ,cp_stream_type_id	IN NUMBER
                     ,cp_org_id IN NUMBER) IS
 SELECT AR_INVOICE_ID,
            AR_INVOICE_NUMBER,
            AR_INVOICE_LINE_ID INVOICE_LINE_ID,
            LINE_NUMBER,
            AMOUNT_DUE_REMAINING,
            CURRENCY_CODE
 FROM okl_rcpt_consinv_balances_uv lpt
   WHERE    lpt.consolidated_invoice_number    = cp_cons_bill_num
   AND    lpt.customer_number = NVL (cp_customer_num, lpt.customer_number)
   AND lpt.stream_type_id = NVL (cp_stream_type_id, lpt.stream_type_id)
   AND    lpt.amount_due_remaining > 0
   AND lpt.org_id=cp_org_id
   AND lpt.status='OP';


  c_open_inv_rec c_open_invs_consinv%ROWTYPE;
  c_open_invs_rec c_open_invs_consinv%ROWTYPE;

----------
-- get all open invoices for customer ar invoices
CURSOR c_open_invs_arinv( cp_customer_num IN VARCHAR2
                        ,cp_ar_bill_num IN VARCHAR2
                        ,cp_stream_type_id IN NUMBER
                        ,cp_org_id IN NUMBER) IS
Select AR_INVOICE_ID  Ar_Invoice_Id,
            Invoice_Number  AR_INVOICE_NUMBER,
            INVOICE_LINE_ID invoice_line_id,
            Line_Identifier Line_Number,
            amount_due_remaining amount_due_remaining,
            invoice_currency_code CURRENCY_CODE
    From   OKL_RCPT_ARINV_BALANCES_UV
    Where  Invoice_Number = cp_ar_bill_num
    And Org_id = cp_org_id
    AND	amount_due_remaining > 0
    AND	status = 'OP'
    And sty_Id = Nvl(cp_stream_type_id,sty_id);


----------
-- get all open invoices for customer/contracts
CURSOR c_open_invs_contract( cp_customer_num IN VARCHAR2
                        ,cp_contract_num IN VARCHAR2
                        ,cp_stream_type_id IN NUMBER
                        ,cp_org_id IN NUMBER) IS
 SELECT  AR_INVOICE_ID,
            AR_INVOICE_NUMBER,
            INVOICE_LINE_ID,
            LINE_NUMBER,
            AMOUNT_DUE_REMAINING,
            CURRENCY_CODE
    FROM    OKL_RCPT_CUST_CONT_BALANCES_UV
    WHERE   CONTRACT_NUMBER = NVL (cp_contract_num, CONTRACT_NUMBER)
    AND     STY_ID = NVL(cp_stream_type_id, STY_ID)
    AND     CUSTOMER_ACCOUNT_NUMBER = cp_customer_num
	AND     ORG_ID = cp_org_id
    AND     STATUS = 'OP'
    AND 	AMOUNT_DUE_REMAINING > 0;


------------

  -- get search combination rule headers
  CURSOR c_get_rules IS
  SELECT id, sequence_number, cash_search_type
  FROM   okl_csh_allct_srchs
  ORDER BY sequence_number;

----------

  -- get search combination rule lines
  CURSOR c_get_rule_lines(cp_cah_id IN NUMBER) IS
  SELECT sty_id, add_yn
  FROM   okl_srch_strm_typs
  WHERE  cah_id = cp_cah_id;

----------

BEGIN

OPEN c_get_rules;                                   -- get rule headers in seq order
LOOP
    l_next_rule := 0;
    l_running_total := 0;                           -- reset running total for new rule
    l_init_count := 0;

    i := 0;

    FETCH c_get_rules INTO l_cah_id, l_seq_num, l_csh_type;
    EXIT WHEN c_get_rules%NOTFOUND;

    OPEN c_get_rule_lines(l_cah_id);                -- get associated rule lines
    LOOP
        FETCH c_get_rule_lines INTO l_rule_sty_id, l_add_yn;
        EXIT WHEN c_get_rule_lines%NOTFOUND;

       IF  l_cons_inv_number is not null THEN
         OPEN c_open_invs_consinv (l_customer_number, l_cons_inv_number, l_rule_sty_id,l_org_id);
          l_count := 0;

              LOOP
              FETCH c_open_invs_consinv INTO c_open_inv_rec;
            l_amount_due_remaining:= c_open_inv_rec.amount_due_remaining;
          IF c_open_invs_consinv%NOTFOUND AND
          l_count <> 0 THEN
          EXIT; -- exit out first loop and pick up next rule_sty_id from rule.
          END IF;

       IF c_open_invs_consinv%NOTFOUND AND
                  l_count = 0 THEN
                  l_next_rule := 1; -- rule has failed, next !
                  EXIT; -- exit loop
       ELSE
       l_count := l_count + 1;

      IF l_add_yn = 'Y' THEN
       l_running_total := l_running_total + l_amount_due_remaining;
    ELSE
    l_running_total := l_running_total - l_amount_due_remaining;
    END IF;

    IF l_init_count = 0 THEN -- initialise the table ...
    l_scn_rcpt_tbl := l_initialize;
    END IF;

   l_init_count := l_init_count + 1;

   i := i + 1;
    -- l_scn_rcpt_tbl(i).invoice_number := l_receivables_invoice_number;
    -- l_scn_rcpt_tbl(i).amount_applied := l_amount_due_remaining;
               l_scn_rcpt_tbl(i).INVOICE_NUMBER        := c_open_inv_rec.ar_invoice_number;
               l_scn_rcpt_tbl(i).INVOICE_CURRENCY_CODE := c_open_inv_rec.currency_code;
               l_scn_rcpt_tbl(i).INVOICE_ID := c_open_inv_rec.ar_invoice_id;
               l_scn_rcpt_tbl(i).INVOICE_LINE_ID := c_open_inv_rec.invoice_line_id;
               l_scn_rcpt_tbl(i).INVOICE_LINE_NUMBER := c_open_inv_rec.line_number;
               l_scn_rcpt_tbl(i).AMOUNT_APPLIED        := c_open_inv_rec.amount_due_remaining;


END IF;
END LOOP;
CLOSE c_open_invs_consinv;
END IF;


--- for ar invoices
IF  l_ar_inv_number is not null THEN
OPEN c_open_invs_arinv (l_customer_number, l_ar_inv_number, l_rule_sty_id,l_org_id);
l_count := 0;

  LOOP
     FETCH c_open_invs_arinv INTO c_open_inv_rec;
     l_amount_due_remaining:= c_open_inv_rec.amount_due_remaining;
    IF c_open_invs_arinv%NOTFOUND AND
        l_count <> 0 THEN
         EXIT; -- exit out first loop and pick up next rule_sty_id from rule.
    END IF;

    IF c_open_invs_arinv%NOTFOUND AND
       l_count = 0 THEN
       l_next_rule := 1; -- rule has failed, next !
        EXIT; -- exit loop
     ELSE
    l_count := l_count + 1;

   IF l_add_yn = 'Y' THEN
     l_running_total := l_running_total + l_amount_due_remaining;
   ELSE
     l_running_total := l_running_total - l_amount_due_remaining;
   END IF;

IF l_init_count = 0 THEN -- initialise the table ...
l_scn_rcpt_tbl := l_initialize;
END IF;

l_init_count := l_init_count + 1;

i := i + 1;
      l_scn_rcpt_tbl(i).INVOICE_NUMBER        := c_open_inv_rec.ar_invoice_number;
               l_scn_rcpt_tbl(i).INVOICE_CURRENCY_CODE := c_open_inv_rec.currency_code;
               l_scn_rcpt_tbl(i).INVOICE_ID := c_open_inv_rec.ar_invoice_id;
               l_scn_rcpt_tbl(i).INVOICE_LINE_ID := c_open_inv_rec.invoice_line_id;
               l_scn_rcpt_tbl(i).INVOICE_LINE_NUMBER := c_open_inv_rec.line_number;
               l_scn_rcpt_tbl(i).AMOUNT_APPLIED        := c_open_inv_rec.amount_due_remaining;


          END IF;
    END LOOP;
     CLOSE c_open_invs_arinv;
 END IF;

---- for contracts
IF  l_contract_number is not null THEN
OPEN c_open_invs_contract (l_customer_number, l_contract_number, l_rule_sty_id,l_org_id);
l_count := 0;

LOOP
   FETCH c_open_invs_contract INTO c_open_inv_rec;
   l_amount_due_remaining:= c_open_inv_rec.amount_due_remaining;
    IF c_open_invs_contract%NOTFOUND AND
      l_count <> 0 THEN
    EXIT; -- exit out first loop and pick up next rule_sty_id from rule.
   END IF;

    IF c_open_invs_contract%NOTFOUND AND
    l_count = 0 THEN
      l_next_rule := 1; -- rule has failed, next !
       EXIT; -- exit loop
    ELSE
      l_count := l_count + 1;

    IF l_add_yn = 'Y' THEN
      l_running_total := l_running_total + l_amount_due_remaining;
    ELSE
      l_running_total := l_running_total - l_amount_due_remaining;
    END IF;

      IF l_init_count = 0 THEN -- initialise the table ...
      l_scn_rcpt_tbl := l_initialize;
      END IF;

      l_init_count := l_init_count + 1;

      i := i + 1;
      l_scn_rcpt_tbl(i).INVOICE_NUMBER        := c_open_inv_rec.ar_invoice_number;
               l_scn_rcpt_tbl(i).INVOICE_CURRENCY_CODE := c_open_inv_rec.currency_code;
               l_scn_rcpt_tbl(i).INVOICE_ID := c_open_inv_rec.ar_invoice_id;
               l_scn_rcpt_tbl(i).INVOICE_LINE_ID := c_open_inv_rec.invoice_line_id;
               l_scn_rcpt_tbl(i).INVOICE_LINE_NUMBER := c_open_inv_rec.line_number;
               l_scn_rcpt_tbl(i).AMOUNT_APPLIED        := c_open_inv_rec.amount_due_remaining;

END IF;
END LOOP;
CLOSE c_open_invs_contract;
END IF;


------- for no match condition

IF  l_cons_inv_number is null  and l_ar_inv_number is null and l_contract_number is null THEN
   OPEN c_open_invs_contract (l_customer_number, NULL, l_rule_sty_id,l_org_id);
   l_count := 0;

  LOOP
    FETCH c_open_invs_contract INTO c_open_inv_rec;
   l_amount_due_remaining:= c_open_inv_rec.amount_due_remaining;
   IF c_open_invs_contract%NOTFOUND AND
   l_count <> 0 THEN
   EXIT; -- exit out first loop and pick up next rule_sty_id from rule.
   END IF;

   IF c_open_invs_contract%NOTFOUND AND
   l_count = 0 THEN
   l_next_rule := 1; -- rule has failed, next !
   EXIT; -- exit loop
   ELSE
   l_count := l_count + 1;

      IF l_add_yn = 'Y' THEN
      l_running_total := l_running_total + l_amount_due_remaining;
      ELSE
      l_running_total := l_running_total - l_amount_due_remaining;
      END IF;

      IF l_init_count = 0 THEN -- initialise the table ...
      l_scn_rcpt_tbl := l_initialize;
      END IF;

      l_init_count := l_init_count + 1;

      i := i + 1;
      l_scn_rcpt_tbl(i).INVOICE_NUMBER        := c_open_inv_rec.ar_invoice_number;
               l_scn_rcpt_tbl(i).INVOICE_CURRENCY_CODE := c_open_inv_rec.currency_code;
               l_scn_rcpt_tbl(i).INVOICE_ID := c_open_inv_rec.ar_invoice_id;
               l_scn_rcpt_tbl(i).INVOICE_LINE_ID := c_open_inv_rec.invoice_line_id;
               l_scn_rcpt_tbl(i).INVOICE_LINE_NUMBER := c_open_inv_rec.line_number;
               l_scn_rcpt_tbl(i).AMOUNT_APPLIED        := c_open_inv_rec.amount_due_remaining;


    END IF;
  END LOOP;
CLOSE c_open_invs_contract;
END IF;


        IF l_next_rule = 1 THEN
            EXIT;                                   -- exit loop and pick up next rule
        END IF;

    END LOOP;
    CLOSE c_get_rule_lines;


    IF l_next_rule = 0 THEN                         -- we have a match, prepare table

        j := 1;
        --  get invoice amount due remaining
       IF l_ar_inv_number is not null THEN
        FOR c_open_invs_rec IN c_open_invs_consinv (l_customer_number, l_cons_inv_number, l_rule_sty_id,l_org_id)
	    LOOP
            l_inv_tot := l_inv_tot + c_open_invs_rec.amount_due_remaining;

          l_rcpt_tbl(j).AMOUNT_APPLIED        := c_open_invs_rec.amount_due_remaining;
          l_rcpt_tbl(j).INVOICE_NUMBER        := c_open_invs_rec.ar_invoice_number;
          l_rcpt_tbl(j).INVOICE_CURRENCY_CODE := c_open_invs_rec.currency_code;
          l_rcpt_tbl(j).INVOICE_ID := c_open_invs_rec.ar_invoice_id;
          l_rcpt_tbl(j).INVOICE_LINE_NUMBER := c_open_invs_rec.line_number;
          l_rcpt_tbl(j).INVOICE_LINE_ID := c_open_invs_rec.invoice_line_id;


            j := j + 1;

	    END LOOP;

      ELSIF l_ar_inv_number is not null THEN
         FOR c_open_invs_rec IN c_open_invs_arinv (l_customer_number, l_ar_inv_number, l_rule_sty_id,l_org_id)
	    LOOP
            l_inv_tot := l_inv_tot + c_open_invs_rec.amount_due_remaining;

          l_rcpt_tbl(j).AMOUNT_APPLIED        := c_open_invs_rec.amount_due_remaining;
          l_rcpt_tbl(j).INVOICE_NUMBER        := c_open_invs_rec.ar_invoice_number;
          l_rcpt_tbl(j).INVOICE_CURRENCY_CODE := c_open_invs_rec.currency_code;
          l_rcpt_tbl(j).INVOICE_ID := c_open_invs_rec.ar_invoice_id;
          l_rcpt_tbl(j).INVOICE_LINE_NUMBER := c_open_invs_rec.line_number;
          l_rcpt_tbl(j).INVOICE_LINE_ID := c_open_invs_rec.invoice_line_id;


            j := j + 1;

	    END LOOP;

      ELSIF l_contract_number is not null THEN

         FOR c_open_invs_rec IN c_open_invs_contract (l_customer_number, l_contract_number, l_rule_sty_id,l_org_id)
	    LOOP
            l_inv_tot := l_inv_tot + c_open_invs_rec.amount_due_remaining;

          l_rcpt_tbl(j).AMOUNT_APPLIED        := c_open_invs_rec.amount_due_remaining;
          l_rcpt_tbl(j).INVOICE_NUMBER        := c_open_invs_rec.ar_invoice_number;
          l_rcpt_tbl(j).INVOICE_CURRENCY_CODE := c_open_invs_rec.currency_code;
          l_rcpt_tbl(j).INVOICE_ID := c_open_invs_rec.ar_invoice_id;
          l_rcpt_tbl(j).INVOICE_LINE_NUMBER := c_open_invs_rec.line_number;
          l_rcpt_tbl(j).INVOICE_LINE_ID := c_open_invs_rec.invoice_line_id;


            j := j + 1;

	    END LOOP;
      ELSE
      FOR c_open_invs_rec IN c_open_invs_contract (l_customer_number, null, l_rule_sty_id,l_org_id)
	    LOOP
            l_inv_tot := l_inv_tot + c_open_invs_rec.amount_due_remaining;

          l_rcpt_tbl(j).AMOUNT_APPLIED        := c_open_invs_rec.amount_due_remaining;
          l_rcpt_tbl(j).INVOICE_NUMBER        := c_open_invs_rec.ar_invoice_number;
          l_rcpt_tbl(j).INVOICE_CURRENCY_CODE := c_open_invs_rec.currency_code;
          l_rcpt_tbl(j).INVOICE_ID := c_open_invs_rec.ar_invoice_id;
          l_rcpt_tbl(j).INVOICE_LINE_NUMBER := c_open_invs_rec.line_number;
          l_rcpt_tbl(j).INVOICE_LINE_ID := c_open_invs_rec.invoice_line_id;


            j := j + 1;
         END LOOP;
      END IF;


        IF l_rcpt_amount = l_running_total AND
           l_csh_type = 'SCN' or l_csh_type = 'scn' THEN

        /*    -- we need to return the table in multiples of 8

            IF (l_scn_rcpt_tbl.COUNT > 1 AND
                l_scn_rcpt_tbl.COUNT < 8) OR
                mod((l_scn_rcpt_tbl.COUNT), 8) <> 0 THEN
                -- j := l_rcpt_tbl.NEXT(j);
                LOOP

                    i:= i + 1;
                    l_scn_rcpt_tbl(i).INVOICE_CURRENCY_CODE :='USD';   -- used ONLY to buffer the records out !!
                    EXIT WHEN mod((l_scn_rcpt_tbl.COUNT), 8) = 0;       -- multiple of 8
                END LOOP;

            END IF;*/
            okl_auto_cash_appl_rules_pvt.GET_APPLICATIONS( p_rcpt_tbl => l_scn_rcpt_tbl
                        ,x_appl_tbl => l_appl_tbl);

            l_match_found := 1;
            x_appl_tbl := l_appl_tbl;

            EXIT;           -- rules loop - we're done !

        ELSIF l_rcpt_amount = l_inv_tot - l_running_total AND
              l_csh_type = 'TMC' or l_csh_type = 'tmc' THEN


            j := 0;
            k := 0;

            LOOP
                j:= j + 1;
                IF l_rcpt_tbl(j).invoice_number IS NOT NULL THEN

                    IF get_req_recs(l_rcpt_tbl(j).invoice_number) THEN    -- if i (scn) is not in j (ttl) ...
                        k := k + 1;
                       -- l_tmc_rcpt_tbl(k).invoice_number := l_rcpt_tbl(j).invoice_number;
                       -- l_tmc_rcpt_tbl(k).amount_applied := l_rcpt_tbl(j).amount_applied;
                        l_tmc_rcpt_tbl(k).INVOICE_NUMBER        := l_rcpt_tbl(j).invoice_number;
                       l_tmc_rcpt_tbl(k).INVOICE_CURRENCY_CODE := l_rcpt_tbl(j).INVOICE_CURRENCY_CODE;
                       l_tmc_rcpt_tbl(k).INVOICE_ID := l_rcpt_tbl(j).INVOICE_ID ;
                       l_tmc_rcpt_tbl(k).INVOICE_LINE_ID := l_rcpt_tbl(j).INVOICE_LINE_ID;
                       l_tmc_rcpt_tbl(k).INVOICE_LINE_NUMBER := l_rcpt_tbl(j).INVOICE_LINE_NUMBER ;
                       l_tmc_rcpt_tbl(k).AMOUNT_APPLIED        := l_rcpt_tbl(j).AMOUNT_APPLIED;

                    END IF;

                END IF;

                EXIT WHEN j = l_rcpt_tbl.LAST;

            END LOOP;

            -- we need to return the table in multiples of 8
/*
            IF (l_tmc_rcpt_tbl.COUNT > 1 AND
                l_tmc_rcpt_tbl.COUNT < 8) OR
                mod((l_tmc_rcpt_tbl.COUNT), 8) <> 0 THEN
                -- j := l_rcpt_tbl.NEXT(j);
                LOOP
                    k := k + 1;
                    l_tmc_rcpt_tbl(k).INVOICE_CURRENCY_CODE := 'USD';   -- used ONLY to buffer the records out !!
                    EXIT WHEN mod((l_tmc_rcpt_tbl.COUNT), 8) = 0;       -- multiple of 8
                END LOOP;

            END IF;*/
          okl_auto_cash_appl_rules_pvt.GET_APPLICATIONS( p_rcpt_tbl => l_tmc_rcpt_tbl
             ,x_appl_tbl => l_appl_tbl);

            l_match_found := 1;
            x_appl_tbl := l_appl_tbl;

          --  x_appl_tbl := l_tmc_rcpt_tbl;
            EXIT;               -- rules loop - we're done !

        END IF;

    END IF;

END LOOP;
CLOSE c_get_rules;

x_match_found := l_match_found;

EXCEPTION

    WHEN OTHERS THEN
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;

END search_combi;

END OKL_COMBI_CASH_APP_RLS_PVT;

/
