--------------------------------------------------------
--  DDL for Package Body OKL_PAY_INVOICES_CONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PAY_INVOICES_CONS_PVT" AS
/* $Header: OKLRPICB.pls 120.41.12010000.2 2010/02/11 06:30:28 nikshah ship $ */
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.RECEIVABLES.INVOICE';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
  G_PROG_NAME_TOKEN      CONSTANT VARCHAR2(9)   := 'PROG_NAME';

  G_DB_ERROR             CONSTANT VARCHAR2(12)  := 'OKL_DB_ERROR';
  G_RET_STS_SUCCESS      CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_SUCCESS;
  G_RET_STS_UNEXP_ERROR  CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_UNEXP_ERROR;
  G_RET_STS_ERROR        CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_ERROR;
--start:|  01-MAY-2007  cklee -- Disbursement changes for R12B, bug fixed:           |
    G_ACC_SYS_OPTION VARCHAR2(4);
--end:|  01-MAY-2007  cklee -- Disbursement changes for R12B, bug fixed:           |

    TYPE cnsld_invs_type IS RECORD (

        cin_rec   OKL_CIN_PVT.cin_rec_type,
        tplv_tbl   OKL_TPL_PVT.tplv_tbl_type

      );

    TYPE cnsld_invs_tbl_type IS TABLE OF cnsld_invs_type
        INDEX BY BINARY_INTEGER;

--start: 31-Oct-2007 cklee -- bug: 6508575 fixed
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : get_Disbursement_term
-- Description     : Get Disbursement term
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 FUNCTION get_Disbursement_term(
 p_transaction_date       IN DATE -- reserved for future use
 ,p_vendor_id             IN NUMBER
 ,p_vendor_site_id        IN NUMBER
 ,p_stream_type_purpose   IN VARCHAR2
 ,x_rule_found            OUT NOCOPY BOOLEAN
 ,x_return_status         OUT NOCOPY VARCHAR2
 ) return disb_rules_type IS

    l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'get_Disbursement_term';
  lx_disb_rules disb_rules_type;

     cursor c_disb_rules( p_vendor_id             NUMBER,
                          p_vendor_site_id        NUMBER,
             			  p_stream_type_purpose   OKL_STRM_TYPE_B.STREAM_TYPE_PURPOSE%type,
						  p_transaction_date      DATE) -- reserved for future use
						  IS
     select dra.disb_rule_id,
            dra.rule_name,
            dra.fee_option,
		    dra.fee_basis,
		    dra.fee_amount,
		    dra.fee_percent,
		    nvl(dra.consolidate_by_due_date, 'N') consolidate_by_due_date,
		    dra.frequency,
		    dra.day_of_month,
		    dra.scheduled_month,
		    nvl(dra.consolidate_strm_type, 'N') consolidate_strm_type,
		    drs.stream_type_purpose,
		    drv.invoice_seq_start,
		    drv.invoice_seq_end,
		    drv.next_inv_seq,
		    drv.disb_rule_vendor_site_id
     from  okl_disb_rules_all_b dra,
           okl_disb_rule_vendor_sites drv,
           okl_disb_rule_sty_types drs
     where drv.disb_rule_id         = dra.disb_rule_id
        and drs.disb_rule_id        = dra.disb_rule_id
    	and drv.vendor_id           = p_vendor_id
        and drv.vendor_site_id      = p_vendor_site_id
        and drs.stream_type_purpose = p_stream_type_purpose
        and TRUNC(sysdate) between TRUNC(NVL(drv.start_date, dra.start_date)) and
		                           TRUNC(NVL(NVL(drv.end_date, dra.end_date),TRUNC(sysdate)));
/* reserved for future use
        and TRUNC(p_transaction_date) between TRUNC(NVL(drv.start_date, dra.start_date)) and
		                                      TRUNC(NVL(NVL(drv.end_date, dra.end_date),p_transaction_date));
*/
     r_disb_rules c_disb_rules%ROWTYPE;

BEGIN
    -- initial return variables
    x_return_status := G_RET_STS_SUCCESS;
    x_rule_found := FALSE;

    OPEN  c_disb_rules(p_vendor_id           => p_vendor_id,
	                   p_vendor_site_id      => p_vendor_site_id,
         			   p_stream_type_purpose => p_stream_type_purpose,
         			   p_transaction_date    => p_transaction_date);
    FETCH c_disb_rules into r_disb_rules;

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'get_Disbursement_term: p_vendor_id/p_vendor_site_id/p_stream_type_purpose/'
	 || p_vendor_id || '/' || p_vendor_site_id || '/' || p_stream_type_purpose || '/');

    IF c_disb_rules%FOUND THEN

      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'get_Disbursement_term: rule_name:' || r_disb_rules.rule_name);
      x_rule_found := TRUE;
      lx_disb_rules.dra_rec.disb_rule_id := r_disb_rules.disb_rule_id;
      lx_disb_rules.dra_rec.rule_name := r_disb_rules.rule_name;
      lx_disb_rules.dra_rec.fee_option := r_disb_rules.fee_option;
      lx_disb_rules.dra_rec.fee_basis := r_disb_rules.fee_basis;
      lx_disb_rules.dra_rec.fee_amount := r_disb_rules.fee_amount;
      lx_disb_rules.dra_rec.fee_percent := r_disb_rules.fee_percent;
      lx_disb_rules.dra_rec.consolidate_by_due_date := r_disb_rules.consolidate_by_due_date;
      lx_disb_rules.dra_rec.frequency := r_disb_rules.frequency;
      lx_disb_rules.dra_rec.day_of_month := r_disb_rules.day_of_month;
      lx_disb_rules.dra_rec.scheduled_month := r_disb_rules.scheduled_month;
      lx_disb_rules.dra_rec.consolidate_strm_type := r_disb_rules.consolidate_strm_type;

      lx_disb_rules.drs_rec.stream_type_purpose := r_disb_rules.stream_type_purpose;

      lx_disb_rules.drv_rec.invoice_seq_start := r_disb_rules.invoice_seq_start;
      lx_disb_rules.drv_rec.invoice_seq_end := r_disb_rules.invoice_seq_end;
      lx_disb_rules.drv_rec.next_inv_seq := r_disb_rules.next_inv_seq;
      lx_disb_rules.drv_rec.disb_rule_vendor_site_id := r_disb_rules.disb_rule_vendor_site_id;

    END IF;

    RETURN lx_disb_rules;

EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;
      RETURN lx_disb_rules;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;
      RETURN lx_disb_rules;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;
      RETURN lx_disb_rules;

 END;
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : handle_next_invoice_seq
-- Description     :
--                  In p_transaction_date    : OKL internal invoice transaction date
--                  In p_vendor_id           : vendor id
--                  In p_vendor_site_id      : vendor site id
--                  In p_stream_type_purpose : stream type purpose
--                  In p_adv_grouping_flag   : advance grouping flag
--                   OUT: vendor sequence number
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE handle_next_invoice_seq(
  p_api_version   	     IN  NUMBER
 ,p_init_msg_list	     IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
 ,x_return_status	     OUT NOCOPY   VARCHAR2
 ,x_msg_count		     OUT NOCOPY   NUMBER
 ,x_msg_data	         OUT NOCOPY   VARCHAR2
 ,p_transaction_date     IN DATE
 ,p_vendor_id            IN NUMBER
 ,p_vendor_site_id       IN NUMBER
 ,p_stream_type_purpose  IN VARCHAR2
 ,p_adv_grouping_flag    IN VARCHAR2 -- reserved for future use
 ,x_next_inv_seq         OUT NOCOPY NUMBER
 ) IS

	------------------------------------------------------------
	-- Declare variables required by APIs
	------------------------------------------------------------
   	l_api_version	CONSTANT NUMBER     := 1;
	l_api_name	CONSTANT VARCHAR2(30)   := 'handle_next_invoice_seq';
	l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
--
  l_inv_seq_start okl_disb_rule_vendor_sites.invoice_seq_start%type;
  l_inv_seq_end okl_disb_rule_vendor_sites.invoice_seq_end%type;
  l_next_inv_seq okl_disb_rule_vendor_sites.next_inv_seq%type;
  l_new_next_inv_seq okl_disb_rule_vendor_sites.next_inv_seq%type := NULL;

  l_disb_rules disb_rules_type;
  lx_rule_found BOOLEAN := FALSE;
  lx_return_status  VARCHAR2(30) := G_RET_STS_SUCCESS;

  l_update_flag boolean := TRUE; -- bug: 6662247
  l_curr_next_inv_seq okl_disb_rule_vendor_sites.next_inv_seq%type; -- bug: 6662247

BEGIN
	------------------------------------------------------------
	-- Start processing
	------------------------------------------------------------
	x_return_status := OKL_API.G_RET_STS_SUCCESS;

	l_return_status := OKL_API.START_ACTIVITY(
		p_api_name	    => l_api_name,
    	p_pkg_name	    => g_pkg_name,
		p_init_msg_list	=> p_init_msg_list,
		l_api_version	=> l_api_version,
		p_api_version	=> p_api_version,
		p_api_type	    => '_PVT',
		x_return_status	=> l_return_status);

	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

    x_next_inv_seq := NULL; -- initial to null

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'handle_next_invoice_seq: p_vendor_id/p_vendor_site_id/p_stream_type_purpose/'
	 || p_vendor_id || '/' || p_vendor_site_id || '/' || p_stream_type_purpose || '/');
    IF p_adv_grouping_flag = 'Y' THEN -- reserved for future use

      l_disb_rules :=  get_Disbursement_term(
          			   p_transaction_date    => p_transaction_date,
                       p_vendor_id           => p_vendor_id,
                       p_vendor_site_id      => p_vendor_site_id,
           			   p_stream_type_purpose => p_stream_type_purpose,
           			   x_return_status       => lx_return_status,
           			   x_rule_found          => lx_rule_found);

      IF lx_return_status = G_RET_STS_SUCCESS AND lx_rule_found = TRUE THEN
-----------------------------------------------------------------------------
--
--case   start   next   end   note
------------------------------------
-- 1     100            100
-- 2     100      -1    100   No next seq #
-- 3     100            200
-- 4     100     200    200   Next # is the last seq #
-- 5     100      -1    200   No next seq #
-- 6     100      150   200
--+7     100      150   120   User enter end seq # and system didn't check the next seq # (bug)
--+8     120            140   User delete previous seq # setup and setup a new seq range (refer to case 9) - bug
-- 9     100                  No end seq #
--10     100      101         No end seq #
--
-----------------------------------------------------------------------------
        -- if vendor invoice sequence has been set, system will find the next available sequence #.
--        IF l_disb_rules.drv_rec.invoice_seq_start IS NOT NULL AND l_disb_rules.drv_rec.invoice_seq_end IS NOT NULL THEN
        IF l_disb_rules.drv_rec.invoice_seq_start IS NOT NULL THEN --bug: 6662247

          l_inv_seq_start := l_disb_rules.drv_rec.invoice_seq_start;
          l_inv_seq_end := l_disb_rules.drv_rec.invoice_seq_end;
--start: bug: 6662247
--          l_next_inv_seq := nvl(l_disb_rules.drv_rec.next_inv_seq, l_inv_seq_start);
          l_next_inv_seq := l_disb_rules.drv_rec.next_inv_seq;

          IF l_disb_rules.drv_rec.invoice_seq_end IS NOT NULL THEN --(case 1-8)
            IF l_inv_seq_end > l_inv_seq_start THEN -- (case 3-8) note: 3=8
              IF l_next_inv_seq IS NULL THEN --(case 3,8) note: 3=8
                l_curr_next_inv_seq := l_inv_seq_start;
                l_new_next_inv_seq := l_inv_seq_start + 1;
              ELSE --(case 4,5,6,7)
                IF l_next_inv_seq = -1 THEN -- case 5
                  l_update_flag := FALSE;
                  l_curr_next_inv_seq := NULL;
                ELSIF l_next_inv_seq < l_inv_seq_end THEN -- case 6
                  l_curr_next_inv_seq := l_next_inv_seq;
                  l_new_next_inv_seq := l_next_inv_seq + 1;
                ELSIF l_next_inv_seq = l_inv_seq_end THEN -- case 4
                  l_curr_next_inv_seq := l_next_inv_seq;
                  l_new_next_inv_seq := -1;
                ELSIF l_next_inv_seq > l_inv_seq_end THEN -- case 7
                  l_curr_next_inv_seq := NULL;
                  l_new_next_inv_seq := -1;
                END IF;
              END IF;
            ELSIF l_inv_seq_end = l_inv_seq_start THEN -- (case 1,2)
              IF l_next_inv_seq IS NULL THEN -- case 1
                l_curr_next_inv_seq := l_inv_seq_start;
                l_new_next_inv_seq := -1; -- no next sequence # for the next visit
              ELSIF l_next_inv_seq = -1 THEN -- case 2
                l_update_flag := FALSE;
                l_curr_next_inv_seq := NULL;
              ELSE
                NULL;
              END IF;
            ELSE -- shall not happened
              l_curr_next_inv_seq := NULL;
              l_new_next_inv_seq := -1;
   		    END IF;
   		  ELSE -- no end sequence. So add 1 to the start seq # or next seq # (case 9,10)
            IF l_next_inv_seq IS NULL THEN -- case 9
              l_curr_next_inv_seq := l_inv_seq_start;
			  l_new_next_inv_seq := l_inv_seq_start + 1;
            ELSE -- case 10
              l_curr_next_inv_seq := l_next_inv_seq;
              l_new_next_inv_seq := l_next_inv_seq + 1;
			END IF;
   		  END IF;

--          -- Maintain the new next sequence #
--          IF ( l_next_inv_seq < l_inv_seq_end ) THEN
--            l_new_next_inv_seq := l_next_inv_seq + 1;
--          ELSE
--            l_new_next_inv_seq := l_inv_seq_end;
--          END IF;


          IF l_update_flag = TRUE THEN
            -- Update okl_disb_rule_vendor_sites
            UPDATE okl_disb_rule_vendor_sites
  	          SET next_inv_seq             = l_new_next_inv_seq
            WHERE disb_rule_vendor_site_id = l_disb_rules.drv_rec.disb_rule_vendor_site_id
            AND disb_rule_id               = l_disb_rules.dra_rec.disb_rule_id;
          END IF;

--end: bug: 6662247
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'handle_next_invoice_seq: l_next_inv_seq:' || l_next_inv_seq);
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'handle_next_invoice_seq: l_new_next_inv_seq:' || l_new_next_inv_seq);

        END IF; -- if vendor invoice sequence has been set
      END IF; -- if rule found
    END IF; --IF p_adv_grouping_flag = 'Y' THEN

    x_next_inv_seq := l_curr_next_inv_seq; --bug: 6662247
	------------------------------------------------------------
	-- End processing
	------------------------------------------------------------

	Okl_Api.END_ACTIVITY (
		x_msg_count	=> x_msg_count,
		x_msg_data	=> x_msg_data);


EXCEPTION
	------------------------------------------------------------
	-- Exception handling
	------------------------------------------------------------
	WHEN OKL_API.G_EXCEPTION_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'handle_next_invoice_seq*=> ERROR: '||SQLERRM);
		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OKL_API.G_RET_STS_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'handle_next_invoice_seq*=> ERROR: '||SQLERRM);
		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OKL_API.G_RET_STS_UNEXP_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN OTHERS THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'handle_next_invoice_seq*=> ERROR: '||SQLERRM);
		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OTHERS',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

END;

--end: 31-Oct-2007 cklee -- bug: 6508575 fixed
---------------------------------------------------------------------------
-- FUNCTION get_months_factor
---------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : get_months_factor
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
FUNCTION get_months_factor( p_frequency     IN VARCHAR2,
                              x_return_status OUT NOCOPY VARCHAR2) RETURN NUMBER IS

    l_months  NUMBER;

    l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'get_months_factor';


BEGIN

    IF p_frequency = 'M' THEN
      l_months := 1;
    ELSIF p_frequency = 'Q' THEN
      l_months := 3;
    ELSIF p_frequency = 'S' THEN
      l_months := 6;
    ELSIF p_frequency = 'A' THEN
      l_months := 12;
    END IF;

    IF l_months IS NOT NULL THEN
      x_return_status := G_RET_STS_SUCCESS;
      RETURN l_months;

    ELSE

      OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_INVALID_FREQUENCY_CODE',
                          p_token1       => 'FRQ_CODE',
                          p_token1_value => p_frequency);

      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;

    END IF;

EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

END get_months_factor;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : get_cnsld_invoiced_date
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
FUNCTION get_cnsld_invoiced_date(p_invoiced_date   DATE,
                                     p_frequency       VARCHAR,
				     p_day_of_month    NUMBER,
				     p_scheduled_month VARCHAR)

    RETURN DATE
    IS

        l_cnsld_invoiced_date DATE := p_invoiced_date;
	l_sys_date DATE := TRUNC(sysdate);
	l_scheduled_date DATE;

        lx_return_status             VARCHAR2(1);
        l_months_factor NUMBER;

BEGIN

        l_scheduled_date := TO_DATE(p_scheduled_month || '-' || to_char(l_sys_date, 'YYYY') || '-' || to_char(p_day_of_month), 'MM-YYYY-DD');

        l_months_factor := get_months_factor( p_frequency       =>   p_frequency,
                                              x_return_status   =>   lx_return_status);

        IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR OR lx_return_status = OKL_API.G_RET_STS_ERROR THEN
           l_months_factor := 1; -- Default monthly ??
        END IF;

/* -- OKL invoice dates can be earlier to current date (ssiruvol)

        WHILE ( l_scheduled_date < l_sys_date )
     	LOOP

            l_scheduled_date := ADD_MONTHS(l_scheduled_date, l_months_factor);

    	End LOOP;
*/

        WHILE ( l_scheduled_date <= p_invoiced_date )
    	LOOP

            l_scheduled_date := ADD_MONTHS(l_scheduled_date, l_months_factor);

    	End LOOP;

    	l_cnsld_invoiced_date := l_scheduled_date;

        RETURN l_cnsld_invoiced_date;

END get_cnsld_invoiced_date;
--start: 31-Oct-2007 cklee -- bug: 6508575 fixed
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : get_ap_invoice_date
-- Description     : Get the AP invoice date based on the following:
--                  In p_transaction_date    : OKL internal invoice transaction date
--                  In p_vendor_id           : vendor id
--                  In p_vendor_site_id      : vendor site id
--                  In p_stream_type_purpose : stream type purpose
--                  In p_adv_grouping_flag   : advance grouping flag
--                   OUT: Consolidation invoice date
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 FUNCTION get_ap_invoice_date(
 p_transaction_date            IN DATE
 ,p_vendor_id                  IN NUMBER
 ,p_vendor_site_id             IN NUMBER
 ,p_stream_type_purpose        IN VARCHAR2
 ,p_adv_grouping_flag          IN VARCHAR2 -- reserved for future use
 ) RETURN DATE IS

  l_invoice_date okl_cnsld_ap_invs_all.date_invoiced%type := p_transaction_date;
  l_disb_rules disb_rules_type;
  lx_rule_found BOOLEAN := FALSE;
  lx_return_status  VARCHAR2(30) := G_RET_STS_SUCCESS;

BEGIN
/*
 Business logic:
   If criteria meet, set new invoice date as a grouping cirteria. Otherwise, set
   invoice date as passed in transaction date.

1. Get rule
2. If rule found and p_adv_grouping_flag = 'Y' then
     get the consoldiate invoice date;
   else
     set inoice date as pass in transaction date;
   end if;
*/

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'get_ap_invoice_date: p_vendor_id/p_vendor_site_id/p_stream_type_purpose/consolidate_by_due_date'
	 || p_vendor_id || '/' || p_vendor_site_id || '/' || p_stream_type_purpose || '/'|| l_disb_rules.dra_rec.consolidate_by_due_date);
    IF p_adv_grouping_flag = 'Y' THEN -- reserved for future use

      l_disb_rules :=  get_Disbursement_term(
         			   p_transaction_date    => p_transaction_date,
	                   p_vendor_id           => p_vendor_id,
	                   p_vendor_site_id      => p_vendor_site_id,
         			   p_stream_type_purpose => p_stream_type_purpose,
         			   x_return_status       => lx_return_status,
         			   x_rule_found          => lx_rule_found);

      IF lx_return_status = G_RET_STS_SUCCESS AND lx_rule_found = TRUE THEN

        IF l_disb_rules.dra_rec.consolidate_by_due_date = 'Y' THEN

          FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'get_ap_invoice_date: p_invoiced_date/p_frequency/p_day_of_month/p_scheduled_month'
		   || p_transaction_date || '/' || l_disb_rules.dra_rec.frequency || '/' || l_disb_rules.dra_rec.day_of_month || '/'|| l_disb_rules.dra_rec.scheduled_month);
          -- getting the invoice date for the consolidated invoice based on the schedule setup on the rule (ssiruvol 5/10/2007)
          l_invoice_date := get_cnsld_invoiced_date (p_invoiced_date   => p_transaction_date,
                                                   p_frequency       => l_disb_rules.dra_rec.frequency,
          				                           p_day_of_month    => l_disb_rules.dra_rec.day_of_month,
     	        		                           p_scheduled_month => l_disb_rules.dra_rec.scheduled_month);
        END IF;
      END IF;
    END IF; --IF p_adv_grouping_flag = 'Y' THEN

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'get_ap_invoice_date: l_invoice_date' || l_invoice_date);

    return l_invoice_date;

EXCEPTION
    WHEN OTHERS THEN
    -- store SQL error message on message stack for caller
    Okl_Api.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                        p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                        p_token1        => 'OKL_SQLCODE',
                        p_token1_value  => SQLCODE,
                        p_token2        => 'OKL_SQLERRM',
                        p_token2_value  => SQLERRM);
    RETURN l_invoice_date;
 END;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : get_Disbursement_group
-- Description     : Get Disbursement group
--                  In p_transaction_date    : OKL internal invoice transaction date
--                  In p_vendor_id           : vendor id
--                  In p_vendor_site_id      : vendor site id
--                  In p_stream_type_purpose : stream type purpose
--                  In p_adv_grouping_flag   : advance grouping flag
--                   OUT: Disbursement term
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 FUNCTION get_Disbursement_group(
 p_transaction_date            IN DATE -- reserved for future use
 ,p_vendor_id                  IN NUMBER
 ,p_vendor_site_id             IN NUMBER
 ,p_stream_type_purpose        IN VARCHAR2
 ,p_adv_grouping_flag          IN VARCHAR2 -- reserved for future use
 ) RETURN VARCHAR2 IS

 l_disb_group varchar2(150) := p_stream_type_purpose; -- defualt to stream type purpose as a group criteria
  l_disb_rules disb_rules_type;
  lx_rule_found BOOLEAN := FALSE;
  lx_return_status  VARCHAR2(30) := G_RET_STS_SUCCESS;
BEGIN
 /*
 Business logic:
   If criteria meet, set Term name as a grouping cirteria. Otherwise, set
   stream type purpose as a grouping criteria.

 1. get Disbursement term
 2. If rule found and p_adv_grouping_flag = 'Y' then
      if consolidate_strm_type = 'Y' then
        If p_stream_type_purpose in rule's streanm type purposes then
          set l_disb_term := rule_name;
        end if;
      end if;
    else
      set l_disb_term := null;
    end if;
 */

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'get_Disbursement_group: p_vendor_id/p_vendor_site_id/p_stream_type_purpose/consolidate_strm_type '
	 || p_vendor_id || '/' || p_vendor_site_id || '/' || p_stream_type_purpose || '/'|| l_disb_rules.dra_rec.consolidate_strm_type );
    IF p_adv_grouping_flag = 'Y' THEN -- reserved for future use

      l_disb_rules :=  get_Disbursement_term(
         			   p_transaction_date    => p_transaction_date,
	                   p_vendor_id           => p_vendor_id,
	                   p_vendor_site_id      => p_vendor_site_id,
         			   p_stream_type_purpose => p_stream_type_purpose,
         			   x_return_status       => lx_return_status,
         			   x_rule_found          => lx_rule_found);

      IF lx_return_status = G_RET_STS_SUCCESS AND lx_rule_found = TRUE THEN

        IF l_disb_rules.dra_rec.consolidate_strm_type = 'Y' THEN
          -- if passed in stream type within the Disbursement term's stream type purpose pool
          IF l_disb_rules.drs_rec.stream_type_purpose = p_stream_type_purpose THEN
            l_disb_group := l_disb_rules.dra_rec.rule_name; -- set disb group as Term name
          END IF;
        END IF;
      END IF;
    END IF; --IF p_adv_grouping_flag = 'Y' THEN

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'get_Disbursement_group:l_disb_group' || l_disb_group);

    return l_disb_group;

EXCEPTION
    WHEN OTHERS THEN

    -- store SQL error message on message stack for caller
    Okl_Api.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                        p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                        p_token1        => 'OKL_SQLCODE',
                        p_token1_value  => SQLCODE,
                        p_token2        => 'OKL_SQLERRM',
                        p_token2_value  => SQLERRM);
    RETURN l_disb_group;
 END;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : get_contract_group
-- Description     : get_contract_group
--                  In p_transaction_date    : OKL internal invoice transaction date
--                  In p_vendor_id           : vendor id
--                  In p_vendor_site_id      : vendor site id
--                  In p_stream_type_purpose : stream type purpose
--                  In p_adv_grouping_flag   : advance grouping flag
--                   OUT: Disbursement term
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 FUNCTION get_contract_group(
 p_transaction_date            IN DATE -- reserved for future use
 ,p_vendor_id                  IN NUMBER
 ,p_vendor_site_id             IN NUMBER
 ,p_stream_type_purpose        IN VARCHAR2
 ,p_contract_number            IN VARCHAR2
 ,p_adv_grouping_flag          IN VARCHAR2 DEFAULT 'Y' -- reserved for future use
 ) RETURN VARCHAR2 IS

 l_contract_group okc_k_headers_all_b.contract_number%TYPE := p_contract_number; -- defualt to contract_number as a group criteria
  l_disb_rules disb_rules_type;
  lx_rule_found BOOLEAN := FALSE;
  lx_return_status  VARCHAR2(30) := G_RET_STS_SUCCESS;

BEGIN
 /*
 Business logic:
   If criteria meet, set contract number as a grouping cirteria. Otherwise, set
   contract number as null.

 1. get Disbursement term
 2. If rule found and p_adv_grouping_flag = 'Y' then
      if consolidate_strm_type = 'Y' or consolidate_by_date = 'Y' then
        set contract group = null;
      end if;
    else
      set lcontract group := contract number;
    end if;
 */
    IF p_adv_grouping_flag = 'Y' THEN -- reserved for future use

      l_disb_rules :=  get_Disbursement_term(
         			   p_transaction_date    => p_transaction_date,
	                   p_vendor_id           => p_vendor_id,
	                   p_vendor_site_id      => p_vendor_site_id,
         			   p_stream_type_purpose => p_stream_type_purpose,
         			   x_return_status       => lx_return_status,
         			   x_rule_found          => lx_rule_found);

      IF lx_return_status = G_RET_STS_SUCCESS AND lx_rule_found = TRUE THEN

        IF l_disb_rules.dra_rec.consolidate_strm_type = 'Y' OR l_disb_rules.dra_rec.consolidate_by_due_date = 'Y' THEN
            l_contract_group := 'x'; -- set disb group as NULL: group across contracts
        END IF;
      END IF;
    END IF; --IF p_adv_grouping_flag = 'Y' THEN

    return l_contract_group;

EXCEPTION
    WHEN OTHERS THEN

    -- store SQL error message on message stack for caller
    Okl_Api.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                        p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                        p_token1        => 'OKL_SQLCODE',
                        p_token1_value  => SQLCODE,
                        p_token2        => 'OKL_SQLERRM',
                        p_token2_value  => SQLERRM);
    RETURN l_contract_group;
 END;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : get_Disbursement_rule
-- Description     : Get Disbursement rule
--                  In p_transaction_date    : OKL internal invoice transaction date
--                  In p_vendor_id           : vendor id
--                  In p_vendor_site_id      : vendor site id
--                  In p_stream_type_purpose : stream type purpose
--                  In p_adv_grouping_flag   : advance grouping flag
--                   OUT: Disbursement term
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 FUNCTION get_Disbursement_rule(
 p_transaction_date            IN DATE -- reserved for future use
 ,p_okl_invoice_line_id        IN NUMBER
 ,p_vendor_id                  IN NUMBER
 ,p_vendor_site_id             IN NUMBER
 ,p_stream_type_purpose        IN VARCHAR2
 ,p_adv_grouping_flag          IN VARCHAR2 -- reserved for future use
 ) RETURN VARCHAR2 IS

 l_disb_rule varchar2(150) := to_char(p_okl_invoice_line_id); -- defualt to okl_txl_ap_inv_lns_all_b.id as a group criteria
  l_disb_rules disb_rules_type;
  lx_rule_found BOOLEAN := FALSE;
  lx_return_status  VARCHAR2(30) := G_RET_STS_SUCCESS;
BEGIN
 /*
 Business logic:
   If criteria meet, set Term name as a grouping cirteria. Otherwise, set
   okl_txl_ap_inv_lns_all_b.id as a grouping criteria.

 */

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'get_Disbursement_rule: p_vendor_id/p_vendor_site_id/p_stream_type_purpose/'
	 || p_vendor_id || '/' || p_vendor_site_id || '/' || p_stream_type_purpose || '/');
    IF p_adv_grouping_flag = 'Y' THEN -- reserved for future use

      l_disb_rules :=  get_Disbursement_term(
         			   p_transaction_date    => p_transaction_date,
	                   p_vendor_id           => p_vendor_id,
	                   p_vendor_site_id      => p_vendor_site_id,
         			   p_stream_type_purpose => p_stream_type_purpose,
         			   x_return_status       => lx_return_status,
         			   x_rule_found          => lx_rule_found);

      IF lx_return_status = G_RET_STS_SUCCESS AND lx_rule_found = TRUE THEN
        l_disb_rule := l_disb_rules.dra_rec.rule_name; -- set disb group as Term name
      END IF;
    END IF; --IF p_adv_grouping_flag = 'Y' THEN

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'get_Disbursement_rule: l_disb_rule' || l_disb_rule);
    return l_disb_rule;

EXCEPTION
    WHEN OTHERS THEN

    -- store SQL error message on message stack for caller
    Okl_Api.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                        p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                        p_token1        => 'OKL_SQLCODE',
                        p_token1_value  => SQLCODE,
                        p_token2        => 'OKL_SQLERRM',
                        p_token2_value  => SQLERRM);
    RETURN l_disb_rule;
 END;

--end: 31-Oct-2007 cklee -- bug: 6508575 fixed

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : apply_consolidation_rules
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
-- OBSOLETE THE FOLOWING PROCEDURE 9/25/07
PROCEDURE apply_consolidation_rules_ssir(
         p_api_version	   IN  NUMBER,
	 p_init_msg_list   IN  VARCHAR2	DEFAULT OKC_API.G_FALSE,
	 x_return_status   OUT NOCOPY      VARCHAR2,
	 x_msg_count	   OUT NOCOPY      NUMBER,
	 x_msg_data	   OUT NOCOPY      VARCHAR2,
	 x_cnsld_invs      OUT NOCOPY     cnsld_invs_tbl_type,
         p_contract_id     IN  NUMBER      DEFAULT NULL,
 	 p_vendor_id       IN  NUMBER      DEFAULT NULL,
	 p_vendor_site_id  IN  NUMBER       DEFAULT NULL,
         p_vpa_id          IN  NUMBER       DEFAULT NULL,
--start:|  24-APR-2007  cklee Disbursement changes for R12B                          |
    p_stream_type_purpose IN VARCHAR2    DEFAULT NULL,
--end:|  24-APR-2007  cklee Disbursement changes for R12B                          |
         p_from_date       IN  DATE,
         p_to_date         IN  DATE)
IS
	------------------------------------------------------------
	-- Declare variables required by APIs
	------------------------------------------------------------
   	l_api_version	CONSTANT NUMBER     := 1;
	l_api_name	CONSTANT VARCHAR2(30)   := 'APPLY_CONSOLIDATION_RULES';
	l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	------------------------------------------------------------
	-- Declare Process variables
	------------------------------------------------------------
    l_msg_index_out     NUMBER;

    l_cin_tbl OKL_CIN_PVT.cin_tbl_type;
    lx_cin_tbl OKL_CIN_PVT.cin_tbl_type;

    l_cin_rec OKL_CIN_PVT.cin_rec_type;
    lx_cin_rec OKL_CIN_PVT.cin_rec_type;

    l_tplv_rec   OKL_TPL_PVT.tplv_rec_type;
    lx_tplv_rec  OKL_TPL_PVT.tplv_rec_type;

    l_tplv_tbl   OKL_TPL_PVT.tplv_tbl_type;
    lx_tplv_tbl  OKL_TPL_PVT.tplv_tbl_type;

    l_cnsld_invs cnsld_invs_tbl_type;

    l_gen_seq           okl_trx_ap_invoices_v.invoice_number%TYPE;

    CURSOR c_invoice IS
	    SELECT
             tap.id  tap_id
            ,NVL(tap.set_of_books_id, OKL_ACCOUNTING_UTIL.get_set_of_books_id) sob_id
            ,tap.org_id
            ,tap.invoice_category_code
            ,tap.invoice_number
            --,tap.vendor_invoice_number
            ,nvl(tap.vendor_invoice_number, tap.invoice_number) vendor_invoice_number
            ,tap.object_version_number
            ,tap.code_combination_id tap_ccid
            ,tap.date_invoiced date_invoiced
            ,tap.pay_group_lookup_code
            ,tap.ipvs_id
            ,tap.ippt_id
            ,tap.IPT_FREQUENCY
            ,tap.IPT_ID
            ,tap.payment_method_code
            ,tap.currency_code
            ,tap.currency_conversion_type
            ,tap.currency_conversion_rate
            ,tap.currency_conversion_date
            ,tap.workflow_yn
            ,tap.date_gl gl_date
            ,tap.nettable_yn
--start:|  02-May-2007  cklee Disbursement changes for R12B                          |
--            ,tap.khr_id
            ,tpl.khr_id
--end:|  02-May-2007  cklee Disbursement changes for R12B                          |
            ,tap.wait_vendor_invoice_yn
            ,tap.try_id
            ,tpl.id tpl_id
            ,tpl.code_combination_id tpl_ccid
            ,tpl.sty_id
            ,acc_db.code_combination_id db_ccid
            ,acc_cr.code_combination_id cr_ccid
            ,tpl.amount invoice_amount
            ,acc_db.amount line_amount
            ,povs.vendor_id
	    ,tap.trx_status_code
	    ,tpl.line_number
	    ,tap.INVOICE_TYPE
	    ,tap.SET_OF_BOOKS_ID
	    ,tap.DATE_GL
	    ,tap.LEGAL_ENTITY_ID
	    ,tap.VPA_ID
	    ,tpl.INV_DISTR_LINE_CODE
	    ,tpl.DISBURSEMENT_BASIS_CODE
	    ,tpl.TPL_ID_REVERSES
	    ,tpl.CODE_COMBINATION_ID
	    ,tpl.LSM_ID
	    ,tpl.KLE_ID
	    ,tpl.ITC_ID
	    ,tpl.DATE_ACCOUNTING
	    ,tpl.PAYABLES_INVOICE_ID
	    ,tpl.REQUEST_ID
	    ,tpl.FUNDING_REFERENCE_NUMBER
	    ,tpl.FUNDING_REFERENCE_TYPE_CODE
	    ,tpl.SEL_ID
	    ,tpl.TAXABLE_YN
--start:|  02-May-2007  cklee Disbursement changes for R12B                          |
	    ,tpl.REF_LINE_NUMBER
	    ,tpl.CNSLD_LINE_NUMBER
--end:|  02-May-2007  cklee Disbursement changes for R12B                          |
        FROM
            okl_trns_acc_dstrs  acc_db
            ,okl_trns_acc_dstrs  acc_cr
            ,po_vendor_sites_all povs
            ,okl_txl_ap_inv_lns_b tpl
            ,okl_trx_ap_invoices_b tap
        WHERE
            NVL(tap.trx_status_code, 'ENTERED') in ( 'ENTERED', 'APPROVED' ) AND
            trunc(tap.date_invoiced) BETWEEN
            NVL(p_from_date, SYSDATE-10000) AND NVL(p_to_date, SYSDATE+10000)
            AND nvl(acc_db.cr_dr_flag(+), 'D') = 'D' --ssiruvol 05May2007
            AND nvl(acc_cr.cr_dr_flag(+), 'C') = 'C' --ssiruvol 05May2007
            AND acc_db.source_table (+)= 'OKL_TXL_AP_INV_LNS_B'
            AND acc_cr.source_table (+)= 'OKL_TXL_AP_INV_LNS_B'
            AND tpl.id = acc_db.source_id (+)
            AND tpl.id = acc_cr.source_id (+)
            AND povs.vendor_site_id = tap.ipvs_id
            AND tap.id = tpl.tap_id
            AND tap.FUNDING_TYPE_CODE IS NULL
	    AND nvl(tap.khr_id,-1) = nvl(p_contract_id, nvl(tap.khr_id,-1))
	    AND nvl(tap.vendor_id,-1) = nvl(p_vendor_id, nvl(tap.vendor_id,-1) )
	    AND nvl(tap.ipvs_id,-1) = nvl(p_vendor_site_id, nvl(tap.ipvs_id,-1))
--start:|  24-APR-2007  cklee Disbursement changes for R12B                          |
--	    AND nvl(tpl.sty_id,-1) = nvl(p_sty_id, nvl(tpl.sty_id,-1))
	    AND nvl(tpl.sty_id,-1) = NVL((select id from OKL_STRM_TYPE_B where STREAM_TYPE_PURPOSE = nvl(p_stream_type_purpose, 'XXX')),nvl(tpl.sty_id,-1))
--end:|  24-APR-2007  cklee Disbursement changes for R12B                          |
	    AND nvl(tap.vpa_id,-1) = nvl(p_vpa_id, nvl(tap.vpa_id,-1))
	  UNION	ALL
		SELECT
             tap.id  tap_id
            ,NVL(tap.set_of_books_id, OKL_ACCOUNTING_UTIL.get_set_of_books_id) sob_id
            ,tap.org_id
            ,tap.invoice_category_code
            ,tap.invoice_number
            --,tap.vendor_invoice_number
            ,nvl(tap.vendor_invoice_number, tap.invoice_number) vendor_invoice_number
            ,tap.object_version_number
            ,tap.code_combination_id tap_ccid
            ,tap.date_invoiced date_invoiced
            ,tap.pay_group_lookup_code
            ,tap.ipvs_id
            ,tap.ippt_id
	    ,tap.IPT_FREQUENCY
            ,tap.IPT_ID
            ,tap.payment_method_code
            ,tap.currency_code
            ,tap.currency_conversion_type
            ,tap.currency_conversion_rate
            ,tap.currency_conversion_date
            ,tap.workflow_yn
            ,tap.date_gl gl_date
            ,tap.nettable_yn
--start:|  02-May-2007  cklee Disbursement changes for R12B                          |
--            ,tap.khr_id
            ,tpl.khr_id
--end:|  02-May-2007  cklee Disbursement changes for R12B                          |
            ,tap.wait_vendor_invoice_yn
            ,tap.try_id
            ,tpl.id tpl_id
            ,tpl.code_combination_id tpl_ccid
            ,tpl.sty_id
            ,acc_db.code_combination_id db_ccid
            ,acc_cr.code_combination_id cr_ccid
            ,tpl.amount invoice_amount
            ,acc_db.amount line_amount
            ,povs.vendor_id
	    ,tap.trx_status_code
	    ,tpl.line_number
	    ,tap.INVOICE_TYPE
	    ,tap.SET_OF_BOOKS_ID
	    ,tap.DATE_GL
	    ,tap.LEGAL_ENTITY_ID
	    ,tap.VPA_ID
	    ,tpl.INV_DISTR_LINE_CODE
	    ,tpl.DISBURSEMENT_BASIS_CODE
	    ,tpl.TPL_ID_REVERSES
	    ,tpl.CODE_COMBINATION_ID
	    ,tpl.LSM_ID
	    ,tpl.KLE_ID
	    ,tpl.ITC_ID
	    ,tpl.DATE_ACCOUNTING
	    ,tpl.PAYABLES_INVOICE_ID
	    ,tpl.REQUEST_ID
	    ,tpl.FUNDING_REFERENCE_NUMBER
	    ,tpl.FUNDING_REFERENCE_TYPE_CODE
	    ,tpl.SEL_ID
	    ,tpl.TAXABLE_YN
--start:|  02-May-2007  cklee Disbursement changes for R12B                          |
	    ,tpl.REF_LINE_NUMBER
	    ,tpl.CNSLD_LINE_NUMBER
--end:|  02-May-2007  cklee Disbursement changes for R12B                          |
        FROM
            okl_trns_acc_dstrs  acc_db
            ,okl_trns_acc_dstrs  acc_cr
            ,po_vendor_sites_all povs
            ,okl_txl_ap_inv_lns_b tpl
            ,okl_trx_ap_invoices_b tap
        WHERE
            NVL(tap.trx_status_code, 'APPROVED') in ( 'APPROVED') AND
            trunc(tap.date_invoiced) BETWEEN
            NVL(p_from_date, SYSDATE-10000) AND NVL(p_to_date, SYSDATE+10000)
            AND nvl(acc_db.cr_dr_flag(+), 'D')  = 'D' --ssiruvol 05May2007
            AND nvl(acc_cr.cr_dr_flag(+), 'C')  = 'C' --ssiruvol 05May2007
            AND acc_db.source_table (+)= 'OKL_TXL_AP_INV_LNS_B'
            AND acc_cr.source_table (+)= 'OKL_TXL_AP_INV_LNS_B'
            AND tpl.id = acc_db.source_id (+)
            AND tpl.id = acc_cr.source_id (+)
            AND povs.vendor_site_id = tap.ipvs_id
            AND tap.id = tpl.tap_id
            AND tap.FUNDING_TYPE_CODE IS NOT NULL
	    AND nvl(tap.khr_id,-1) = nvl(p_contract_id, nvl(tap.khr_id,-1))
	    AND nvl(tap.vendor_id,-1) = nvl(p_vendor_id, nvl(tap.vendor_id,-1) )
	    AND nvl(tap.ipvs_id,-1) = nvl(p_vendor_site_id, nvl(tap.ipvs_id,-1))
--start:|  24-APR-2007  cklee Disbursement changes for R12B                          |
--	    AND nvl(tpl.sty_id,-1) = nvl(p_sty_id, nvl(tpl.sty_id,-1))
	    AND nvl(tpl.sty_id,-1) = NVL((select id from OKL_STRM_TYPE_B where STREAM_TYPE_PURPOSE = nvl(p_stream_type_purpose, 'XXX')), nvl(tpl.sty_id,-1))
--end:|  24-APR-2007  cklee Disbursement changes for R12B                          |
	    AND nvl(tap.vpa_id,-1) = nvl(p_vpa_id, nvl(tap.vpa_id,-1))
      ORDER BY vendor_id,
	       ipvs_id,
	       pay_group_lookup_code,
	       payment_method_code,
	       ippt_id,
	       set_of_books_id,
	       code_combination_id,
	       currency_code,
	       currency_conversion_type,
	       currency_conversion_rate,
	       currency_conversion_date,
	       legal_entity_id,
	       vpa_id,
	       invoice_type,
	       ipt_id,
	       ipt_frequency,
	       sty_id,
	       date_invoiced;

      r_invoice c_invoice%ROWTYPE;

     cursor c_get_sty_id(p_sty_id NUMBER) IS
       select id
	   from OKL_STRM_TYPE_B
	   where STREAM_TYPE_PURPOSE = p_stream_type_purpose;

     cursor c_disb_rules( vId     NUMBER,
                          vSiteid NUMBER,
			  styId   NUMBER) IS
     select dra.rule_name,
            dra.fee_option,
	    dra.fee_basis,
	    dra.fee_amount,
	    dra.fee_percent,
	    nvl(dra.consolidate_by_due_date, 'N') consolidate_by_due_date,
	    dra.frequency,
	    dra.day_of_month,
	    dra.scheduled_month,
	    nvl(dra.consolidate_strm_type, 'N') consolidate_strm_type,
	    drs.stream_type_purpose,
	    drv.invoice_seq_start,
	    drv.invoice_seq_end,
	    drv.next_inv_seq,
	    drv.disb_rule_vendor_site_id,
	    drv.disb_rule_id
     from  okl_disb_rules_all_b dra,
           okl_disb_rule_vendor_sites drv,
	   okl_disb_rule_sty_types drs
     where drv.DISB_RULE_ID = dra.disb_rule_id
        and drs.disb_rule_id = dra.disb_rule_id
	and drv.vendor_id = vId
        and drv.vendor_site_id = vSiteid
        and drs.stream_type_purpose = nvl((select stream_type_purpose from OKL_STRM_TYPE_B where id = nvl(styId, -1)),nvl(drs.stream_type_purpose,'XXX'))
        and TRUNC(sysdate) between TRUNC(NVL(drv.start_date, dra.start_date)) and TRUNC(NVL(NVL(drv.end_date, dra.end_date),TRUNC(sysdate)));

     r_disb_rules c_disb_rules%ROWTYPE;

     l_okl_application_id NUMBER(3) := 540;
     l_document_category VARCHAR2(100):= 'OKL Lease Pay Invoices';
     lX_dbseqnm          VARCHAR2(2000):= '';
     lX_dbseqid          NUMBER(38):= NULL;


     l_inv_seq_start NUMBER := 0;
     l_inv_seq_end NUMBER := 0;
     l_next_inv_seq NUMBER := 0;
     l_new_next_inv_seq NUMBER := 0;

     l_curr_vendor_id NUMBER := NULL;
     l_curr_vendor_site_id NUMBER := NULL;
     l_curr_invoiced_date DATE := NULL;
     l_curr_sty_id NUMBER := NULL;
     l_curr_inv_date DATE := NULL;

	       l_curr_ipvs_id NUMBER := NULL;
	       l_curr_pay_group_lookup_code VARCHAR2(30) := NULL;
	       l_curr_payment_method_code VARCHAR2(30) := NULL;
	       l_curr_ippt_id NUMBER := NULL;
	       l_curr_set_of_books_id NUMBER := NULL;
	       l_curr_code_combination_id NUMBER := NULL;
	       l_curr_currency_code VARCHAR2(15) := NULL;
	       l_curr_currency_conv_type VARCHAR2(30) := NULL;
	       l_curr_currency_conv_rate NUMBER := NULL;
	       l_curr_currency_conv_date DATE := NULL;
	       l_curr_legal_entity_id NUMBER := NULL;
	       l_curr_vpa_id NUMBER := NULL;
	       l_curr_invoice_type VARCHAR2(240) := NULL;
	       l_curr_ipt_id NUMBER := NULL;
	       l_curr_ipt_frequency VARCHAR2(3) := NULL;

     l_last_vendor_id NUMBER := NULL;
     l_last_vendor_site_id NUMBER := NULL;
     l_last_invoiced_date DATE := NULL;
     l_last_sty_id NUMBER := NULL;
     l_last_inv_date DATE := NULL;


	       l_last_ipvs_id NUMBER := NULL;
	       l_last_pay_group_lookup_code VARCHAR2(30) := NULL;
	       l_last_payment_method_code VARCHAR2(30) := NULL;
	       l_last_ippt_id NUMBER := NULL;
	       l_last_set_of_books_id NUMBER := NULL;
	       l_last_code_combination_id NUMBER := NULL;
	       l_last_currency_code VARCHAR2(15) := NULL;
	       l_last_currency_conv_type VARCHAR2(30) := NULL;
	       l_last_currency_conv_rate NUMBER := NULL;
	       l_last_currency_conv_date DATE := SYSDATE-10000;
	       l_last_legal_entity_id NUMBER := NULL;
	       l_last_vpa_id NUMBER := NULL;
	       l_last_invoice_type VARCHAR2(240) := NULL;
	       l_last_ipt_id NUMBER := NULL;
	       l_last_ipt_frequency VARCHAR2(3) := NULL;


     l_found_rule_YN VARCHAR2(1) := 'N';
     l_new_invoiced_date DATE;

     i BINARY_INTEGER := 0;
     j BINARY_INTEGER := 0;
     l BINARY_INTEGER := 0;

     l_consolidate_yn VARCHAR2(1) := 'N';

BEGIN
	------------------------------------------------------------
	-- Start processing
	------------------------------------------------------------

FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'In PVT 1');

	x_return_status := OKL_API.G_RET_STS_SUCCESS;

	l_return_status := OKL_API.START_ACTIVITY(
		p_api_name	=> l_api_name,
    	        p_pkg_name	=> g_pkg_name,
		p_init_msg_list	=> p_init_msg_list,
		l_api_version	=> l_api_version,
		p_api_version	=> p_api_version,
		p_api_type	=> '_PVT',
		x_return_status	=> l_return_status);

	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

    i := 0;

FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'In PVT 2');

    FOR r_invoice IN c_invoice LOOP -- loop through all invoices ordered by the header values (ssiruvol 5/10/2007)

FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'In PVT 3');

        l_consolidate_yn := 'N'; -- Flag to know whether current invoice is being consolidated or not (ssiruvol 5/10/2007)

        l_curr_vendor_id      := r_invoice.vendor_id;
 	l_curr_vendor_site_id := r_invoice.ipvs_id;
        l_curr_invoiced_date  := r_invoice.date_invoiced;
        l_curr_sty_id         := r_invoice.sty_id;


	       l_curr_ipvs_id := r_invoice.ipvs_id;
	       l_curr_pay_group_lookup_code := r_invoice.pay_group_lookup_code;
	       l_curr_payment_method_code := r_invoice.payment_method_code;
	       l_curr_ippt_id := r_invoice.ippt_id;
	       l_curr_set_of_books_id := r_invoice.set_of_books_id;
	       l_curr_code_combination_id := r_invoice.code_combination_id;
	       l_curr_currency_code := r_invoice.currency_code;
	       l_curr_currency_conv_type := r_invoice.currency_conversion_type;
	       l_curr_currency_conv_rate := r_invoice.currency_conversion_rate;
	       l_curr_currency_conv_date := r_invoice.currency_conversion_date;
	       l_curr_legal_entity_id := r_invoice.legal_entity_id;
	       l_curr_vpa_id := r_invoice.vpa_id;
	       l_curr_invoice_type := r_invoice.invoice_type;
	       l_curr_ipt_id := r_invoice.ipt_id;
	       l_curr_ipt_frequency := r_invoice.ipt_frequency;


        r_disb_rules := NULL;
        l_found_rule_YN := 'N';


        l_inv_seq_start := 0;
        l_inv_seq_end := 0;
        l_next_inv_seq := 0;
        l_new_next_inv_seq := 0;

FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'In PVT 3.1 vendor id ' || to_char(l_curr_vendor_id));
FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'In PVT 3.1 vendor site id ' || to_char(l_curr_vendor_site_id));
FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'In PVT 3.1 sty id ' || to_char(l_curr_sty_id));

        -- Checking if a rule exists on the an invoice (ssiruvol 5/10/2007)
        OPEN  c_disb_rules(vId     => l_curr_vendor_id,
	                   vSiteid => l_curr_vendor_site_id,
			   styId   => l_curr_sty_id);

        FETCH c_disb_rules into r_disb_rules;

 	If c_disb_rules%FOUND THEN

FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'In PVT 4 found rule ' );
	    l_found_rule_YN := 'Y';

            -- getting the correct seqence number (ssiruvol 5/10/2007)
            l_inv_seq_start := nvl(r_disb_rules.invoice_seq_start,0);
            l_inv_seq_end := nvl(r_disb_rules.invoice_seq_end,0);
            l_next_inv_seq := nvl(r_disb_rules.next_inv_seq, l_inv_seq_start);
	    If ( l_next_inv_seq < l_inv_seq_end ) THen
	        l_new_next_inv_seq := l_next_inv_seq + 1;
            else
	        l_neW_next_inv_seq := l_inv_seq_end;
		l_next_inv_seq := NULL;
	    End If;

FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'In PVT 4.1 l_inv_seq_start ' || to_char(l_inv_seq_start) );
FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'In PVT 4.1 l_inv_seq_end ' || to_char(l_inv_seq_end) );
FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'In PVT 4.1 l_next_inv_seq ' || to_char(l_next_inv_seq) );
FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'In PVT 4.1 l_new_next_inv_seq ' || to_char(l_new_next_inv_seq) );

            IF r_disb_rules.consolidate_by_due_date = 'Y' THEN

                -- getting the invoice date for the consolidated invoice based on the schedule setup on the rule (ssiruvol 5/10/2007)
                l_curr_inv_date := get_cnsld_invoiced_date (p_invoiced_date   => l_curr_invoiced_date,
                                                            p_frequency       => r_disb_rules.frequency,
				                            p_day_of_month    => r_disb_rules.day_of_month,
				                            p_scheduled_month => r_disb_rules.scheduled_month);
            ELSE
                l_curr_inv_date := l_curr_invoiced_date;
            END IF;
        Else
	    -- if there is no rule then the cnsld invoice date is same as the original invoice date (ssiruvol 5/10/2007)
	    l_curr_inv_date := l_curr_invoiced_date;
  	END If;
        CLOSE c_disb_rules;

FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'In PVT 5 cnsld inv date ' || to_char(l_curr_inv_date)  );

/*
        If ( l_curr_vendor_id <> nvl(l_last_vendor_id, -99)
	   AND l_curr_vendor_site_id <> nvl(l_last_vendor_site_id, -99)
	   AND l_curr_ipvs_id <> nvl(l_last_ipvs_id, -99)
	   AND l_curr_pay_group_lookup_code <> nvl(l_last_pay_group_lookup_code, 'XXX')
	   AND l_curr_payment_method_code <> nvl(l_last_payment_method_code, 'XXX')
	   AND l_curr_ippt_id <> nvl(l_last_ippt_id, -99)
	   AND l_curr_set_of_books_id <> nvl(l_last_set_of_books_id, -99)
	   AND l_curr_code_combination_id <> nvl(l_last_code_combination_id, -99)
	   AND l_curr_currency_code <> nvl(l_last_currency_code, 'XXX')
	   AND l_curr_currency_conv_type <> nvl(l_last_currency_conv_type, 'XXX')
	   AND l_curr_currency_conv_rate <> nvl(l_last_currency_conv_rate, -99)
	   AND l_curr_currency_conv_date <> nvl(l_last_currency_conv_date, sysdate-10000)
	   AND l_curr_legal_entity_id <> nvl(l_last_legal_entity_id, -99)
	   AND l_curr_vpa_id <> nvl(l_last_vpa_id, -99)
	   AND l_curr_ipt_id <> nvl(l_last_ipt_id, -99)
	   AND l_curr_ipt_frequency <>  nvl(l_last_ipt_frequency, 'XXX') )
	   -- If any one of the above header values is different than we cannot consolidate (ssiruvol 5/10/2007)
           OR ( l_curr_inv_date <> nvl(l_last_inv_date,sysdate-10000)) Then
	   -- If the dates are different, then there is no scope of consolidation. However, if the dates are same
	   -- then further validation against rules is necessary before consolidating (ssiruvol 5/10/2007)

		 i := i + 1; -- i is a new consolidation invoice (ssiruvol 5/10/2007)
		 l_cnsld_invs(i).cin_rec.amount := r_invoice.invoice_amount;

        ELSE

	        If l_found_rule_YN = 'N' THEN
		    i := i + 1; -- Do not consolidate if there are no rules against the invoices, even if everything else matches
		                -- for consolidation (ssiruvol 5/10/2007)
		    l_cnsld_invs(i).cin_rec.amount := r_invoice.invoice_amount;
     		Else

		    -- date rule (ssiruvol 5/10/2007)
    		    If ( l_curr_invoiced_date = l_last_invoiced_date ) OR ( r_disb_rules.consolidate_by_due_date = 'Y') Then

		        -- stream type purpose rule (ssiruvol 5/10/2007)
    		        If ( l_curr_sty_id = l_last_sty_id ) OR ( r_disb_rules.consolidate_strm_type = 'Y') Then
                                    l_consolidate_yn := 'Y';
    		    	Else
		                i := i + 1;
		                l_cnsld_invs(i).cin_rec.amount := r_invoice.invoice_amount;
    	    		END If;

    		    Else
	    	        i := i + 1;
		        l_cnsld_invs(i).cin_rec.amount := r_invoice.invoice_amount;
    		    END If;

		    -- More rules will go here. (For future - ssiruvol 5/10/2007)

    		End If;

         END If;

*/
FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' last ccd ' || to_char(nvl(l_last_code_combination_id, -99))  );
FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' curr ccd ' || to_char(l_curr_code_combination_id)  );

        If ( nvl(l_curr_vendor_id, -99) = nvl(l_last_vendor_id, -99)
	   AND nvl(l_curr_vendor_site_id, -99) = nvl(l_last_vendor_site_id, -99)
	   AND nvl(l_curr_ipvs_id, -99) = nvl(l_last_ipvs_id, -99)
	   AND nvl(l_curr_pay_group_lookup_code, 'XXX') = nvl(l_last_pay_group_lookup_code, 'XXX')
	   AND nvl(l_curr_payment_method_code, 'XXX') = nvl(l_last_payment_method_code, 'XXX')
	   AND nvl(l_curr_ippt_id, -99) = nvl(l_last_ippt_id, -99)
	   AND nvl(l_curr_set_of_books_id, -99) = nvl(l_last_set_of_books_id, -99)
	   AND nvl(l_curr_code_combination_id, -99) = nvl(l_last_code_combination_id, -99)
	   AND nvl(l_curr_currency_code, 'XXX') = nvl(l_last_currency_code, 'XXX')
	   AND nvl(l_curr_currency_conv_type, 'XXX') = nvl(l_last_currency_conv_type, 'XXX')
	   AND nvl(l_curr_currency_conv_rate, -99) = nvl(l_last_currency_conv_rate, -99)
	   AND nvl(l_curr_currency_conv_date, sysdate-10000) = nvl(l_last_currency_conv_date, sysdate-10000)
	   AND nvl(l_curr_legal_entity_id, -99) = nvl(l_last_legal_entity_id, -99)
	   AND nvl(l_curr_vpa_id, -99) = nvl(l_last_vpa_id, -99)
	   AND nvl(l_curr_ipt_id, -99) = nvl(l_last_ipt_id, -99)
	   AND nvl(l_curr_ipt_frequency, 'XXX') =  nvl(l_last_ipt_frequency, 'XXX')
	   -- If any one of the above header values is different than we cannot consolidate (ssiruvol 5/10/2007)

	   AND l_found_rule_YN = 'Y') Then

FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'In PVT 6 tyrig to cnsld inv date ' || to_char(l_curr_inv_date)  );

               -- date rule (ssiruvol 5/10/2007)
    	      If ( l_curr_invoiced_date = l_last_invoiced_date OR r_disb_rules.consolidate_by_due_date = 'Y' ) Then

	          -- stream type purpose rule (ssiruvol 5/10/2007)
    	          If ( l_curr_sty_id = l_last_sty_id ) OR ( r_disb_rules.consolidate_strm_type = 'Y') Then
                      l_consolidate_yn := 'Y';
    	          END If;

    	      End If;

	      If  l_consolidate_yn = 'N' AND  -- consolidate_by_due_date and consolidate_strm_type are mutually exclusive. This
	                                      -- particular check is not met by the above condition.
					      -- THE INVOICE CURSOR HAS STREAM TYPE PURPOSES sorted
	          r_disb_rules.consolidate_strm_type = 'Y' AND
		  r_disb_rules.consolidate_by_due_date = 'N' Then

	          l_consolidate_yn := 'Y';

	      End If;

         END If;

         If l_consolidate_yn = 'Y' and  l_curr_inv_date = nvl(l_last_inv_date,sysdate-10000) Then

FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'In PVT 7 tyrig to cnsld inv date ' || to_char(l_curr_inv_date)  );

	     l_cnsld_invs(i).cin_rec.amount := l_cnsld_invs(i).cin_rec.amount + r_invoice.invoice_amount;
             l_cnsld_invs(i).cin_rec.vendor_invoice_number := NULL;

         ElsIf l_consolidate_yn = 'Y' and  l_curr_inv_date <> nvl(l_last_inv_date,sysdate-10000) Then

FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'In PVT 8 ' );

             l :=  nvl(l_cnsld_invs.FIRST, l_cnsld_invs.COUNT + 1);
             i :=  l_cnsld_invs.COUNT + 1; -- making sure to create a new consld transaction incase the while loop is missed

             WHILE (  l <= l_cnsld_invs.COUNT ) -- finding the correct invoice to consolidate the current transaction into,
	                                        -- based on the invoice date and stream type
     	     LOOP
	         If (l_cnsld_invs(l).cin_rec.date_invoiced = l_curr_inv_date) AND
		    ( r_disb_rules.consolidate_strm_type = 'Y' OR l_curr_sty_id = l_cnsld_invs(l).tplv_tbl(1).STY_ID ) Then
		     i := l;
                     l := l_cnsld_invs.COUNT + 1;
		 else
		     l := l + 1;
		     i := l;
		 end if;
    	     End LOOP;

	     If (i > l_cnsld_invs.COUNT ) Then -- did not find a match, hence a new consold transaction
	         l_consolidate_yn := 'N';
	     Else
	         l_cnsld_invs(i).cin_rec.amount := l_cnsld_invs(i).cin_rec.amount + r_invoice.invoice_amount;
                 l_cnsld_invs(i).cin_rec.vendor_invoice_number := NULL;
	     End If;

	 End If;

         If l_consolidate_yn = 'N' Then -- processing a brand new transaction

FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'In PVT 9 ' );

	    i := l_cnsld_invs.COUNT + 1;
	    l_cnsld_invs(i).cin_rec.amount := r_invoice.invoice_amount;

	    l_cnsld_invs(i).cin_rec.date_invoiced := l_curr_inv_date;

	    -- This is valid ONLY when NOT consolidating the invoices. When consolidating, the vendor_invoice_number
	    -- on the consolidated invoice has no relation to the orginal set of consolidated invoices. (ssiruvol 5/10/2007)
            l_cnsld_invs(i).cin_rec.vendor_invoice_number := r_invoice.vendor_invoice_number;

	    l_cnsld_invs(i).cin_rec.org_id := r_invoice.org_id;
	    l_cnsld_invs(i).cin_rec.trx_status_code := 'ENTERED';--r_invoice.trx_status_code;
	    l_cnsld_invs(i).cin_rec.currency_code := r_invoice.currency_code;
	    l_cnsld_invs(i).cin_rec.try_id := r_invoice.try_id;
	    l_cnsld_invs(i).cin_rec.ipvs_id := r_invoice.ipvs_id;
	    l_cnsld_invs(i).cin_rec.CURRENCY_CONVERSION_TYPE := r_invoice.CURRENCY_CONVERSION_TYPE;
	    l_cnsld_invs(i).cin_rec.CURRENCY_CONVERSION_RATE := r_invoice.CURRENCY_CONVERSION_RATE;
	    l_cnsld_invs(i).cin_rec.CURRENCY_CONVERSION_DATE := r_invoice.CURRENCY_CONVERSION_DATE;
	    l_cnsld_invs(i).cin_rec.PAYMENT_METHOD_CODE := r_invoice.PAYMENT_METHOD_CODE;
	    l_cnsld_invs(i).cin_rec.PAY_GROUP_LOOKUP_CODE  := r_invoice.PAY_GROUP_LOOKUP_CODE ;
	    l_cnsld_invs(i).cin_rec.INVOICE_TYPE  := r_invoice.INVOICE_TYPE;
	    l_cnsld_invs(i).cin_rec.SET_OF_BOOKS_ID   := r_invoice.SET_OF_BOOKS_ID;
	    l_cnsld_invs(i).cin_rec.IPPT_ID    := r_invoice.IPPT_ID;
	    l_cnsld_invs(i).cin_rec.DATE_GL     := r_invoice.DATE_GL;
	    l_cnsld_invs(i).cin_rec.VENDOR_ID      := r_invoice.VENDOR_ID;
	    l_cnsld_invs(i).cin_rec.LEGAL_ENTITY_ID       := r_invoice.LEGAL_ENTITY_ID ;
	    l_cnsld_invs(i).cin_rec.VPA_ID        := r_invoice.VPA_ID ;
	    l_cnsld_invs(i).cin_rec.OBJECT_VERSION_NUMBER        := i ;
--	    l_cnsld_invs(i).cin_rec.CREATED_BY        := i ; -- cklee 04/26/07
	    l_cnsld_invs(i).cin_rec.CREATED_BY        := fnd_global.user_id ;
	    l_cnsld_invs(i).cin_rec.CREATION_DATE        := sysdate ;
--	    l_cnsld_invs(i).cin_rec.LAST_UPDATED_BY        := i ; -- cklee 04/26/07
	    l_cnsld_invs(i).cin_rec.LAST_UPDATED_BY        := fnd_global.user_id ;
	    l_cnsld_invs(i).cin_rec.LAST_UPDATE_DATE        := sysdate ;

--start:|  03-MAY-2007  cklee -- Disbursement changes for R12B, bug fixed:           |
            l_cnsld_invs(i).cin_rec.accts_pay_cc_id := NVL(r_invoice.tap_ccid,r_invoice.cr_ccid);
--end:|  03-MAY-2007  cklee -- Disbursement changes for R12B, bug fixed:           |


            If l_found_rule_YN = 'Y' THEN

		l_cnsld_invs(i).cin_rec.self_bill_inv_num := l_next_inv_seq;
		update okl_disb_rule_vendor_sites
		set next_inv_seq = l_new_next_inv_seq
		where disb_rule_vendor_site_id =  r_disb_rules.disb_rule_vendor_site_id
		   and disb_rule_id = r_disb_rules.disb_rule_id;

FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'In PVT 4.1.1  updating self_bill_inv_num ' || to_char(l_next_inv_seq) );
FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'In PVT 4.1.2  updating next_inv_seq ' || to_char( l_new_next_inv_seq) );

	    END IF;

	  End If;

            j := l_cnsld_invs(i).tplv_tbl.COUNT + 1;
	    l_cnsld_invs(i).tplv_tbl(j).id := r_invoice.tpl_id;
	    l_cnsld_invs(i).tplv_tbl(j).tap_id := r_invoice.tap_id;
	    l_cnsld_invs(i).tplv_tbl(j).amount := r_invoice.invoice_amount;
	    l_cnsld_invs(i).tplv_tbl(j).line_number := r_invoice.line_number;
	    l_cnsld_invs(i).tplv_tbl(j).INV_DISTR_LINE_CODE := r_invoice.INV_DISTR_LINE_CODE;
	    l_cnsld_invs(i).tplv_tbl(j).DISBURSEMENT_BASIS_CODE := r_invoice.DISBURSEMENT_BASIS_CODE;
	    l_cnsld_invs(i).tplv_tbl(j).TPL_ID_REVERSES   := r_invoice.TPL_ID_REVERSES;
	    l_cnsld_invs(i).tplv_tbl(j).CODE_COMBINATION_ID   := r_invoice.CODE_COMBINATION_ID;
	    l_cnsld_invs(i).tplv_tbl(j).LSM_ID   := r_invoice.LSM_ID;
	    l_cnsld_invs(i).tplv_tbl(j).KLE_ID    := r_invoice.KLE_ID ;
	    l_cnsld_invs(i).tplv_tbl(j).ITC_ID     := r_invoice.ITC_ID ;
	    l_cnsld_invs(i).tplv_tbl(j).STY_ID     := r_invoice.STY_ID;
	    l_cnsld_invs(i).tplv_tbl(j).DATE_ACCOUNTING     := r_invoice.DATE_ACCOUNTING;
	    l_cnsld_invs(i).tplv_tbl(j).PAYABLES_INVOICE_ID       := r_invoice.PAYABLES_INVOICE_ID;
	    l_cnsld_invs(i).tplv_tbl(j).REQUEST_ID         := r_invoice.REQUEST_ID;
	    l_cnsld_invs(i).tplv_tbl(j).FUNDING_REFERENCE_NUMBER         := r_invoice.FUNDING_REFERENCE_NUMBER;
	    l_cnsld_invs(i).tplv_tbl(j).FUNDING_REFERENCE_TYPE_CODE         := r_invoice.FUNDING_REFERENCE_TYPE_CODE;
	    l_cnsld_invs(i).tplv_tbl(j).SEL_ID         := r_invoice.SEL_ID;
	    l_cnsld_invs(i).tplv_tbl(j).TAXABLE_YN         := r_invoice.TAXABLE_YN;
	    l_cnsld_invs(i).tplv_tbl(j).ORG_ID         := r_invoice.ORG_ID;
--	    l_cnsld_invs(i).tplv_tbl(j).CREATED_BY         := i; -- cklee 4/26/07
	    l_cnsld_invs(i).tplv_tbl(j).CREATED_BY         := fnd_global.user_id;
	    l_cnsld_invs(i).tplv_tbl(j).CREATION_DATE         := sysdate;
--	    l_cnsld_invs(i).tplv_tbl(j).LAST_UPDATED_BY         := i; -- cklee 4/26/07
	    l_cnsld_invs(i).tplv_tbl(j).LAST_UPDATED_BY         := fnd_global.user_id;
	    l_cnsld_invs(i).tplv_tbl(j).LAST_UPDATE_DATE         := sysdate;
--start:|  02-May-2007  cilee Disbursement changes for R12B                          |
	    l_cnsld_invs(i).tplv_tbl(j).KHR_ID         := r_invoice.KHR_ID;
	    l_cnsld_invs(i).tplv_tbl(j).REF_LINE_NUMBER         := r_invoice.REF_LINE_NUMBER;
	    l_cnsld_invs(i).tplv_tbl(j).CNSLD_LINE_NUMBER         := r_invoice.CNSLD_LINE_NUMBER;
--end:|  02-May-2007  cklie Disbursement changes for R12B                          |



	    l_last_vendor_id      := l_curr_vendor_id;
	    l_last_vendor_site_id := l_curr_vendor_site_id;
            l_last_invoiced_date  := l_curr_invoiced_date;
            l_last_sty_id         := l_curr_sty_id;
            l_last_inv_date       := l_curr_inv_date;

	    l_last_ipvs_id := l_curr_ipvs_id;
	    l_last_pay_group_lookup_code := l_curr_pay_group_lookup_code;
	    l_last_payment_method_code := l_curr_payment_method_code;
	    l_last_ippt_id := l_curr_ippt_id;
	    l_last_set_of_books_id := l_curr_set_of_books_id;
	    l_last_code_combination_id := l_curr_code_combination_id;
	    l_last_currency_code := l_curr_currency_code;
	    l_last_currency_conv_type := l_curr_currency_conv_type;
	    l_last_currency_conv_rate := l_curr_currency_conv_rate;
	    l_last_currency_conv_date := l_curr_currency_conv_date;
	    l_last_legal_entity_id := l_curr_legal_entity_id;
            l_last_vpa_id := l_curr_vpa_id;
	    l_last_ipt_id := l_curr_ipt_id;
	    l_last_ipt_frequency := l_curr_ipt_frequency;

    END LOOP;

FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'In PVT 100');

    If ( l_cnsld_invs.COUNT > 0 ) then

    i := 0;
    FOR i in l_cnsld_invs.FIRST..l_cnsld_invs.LAST
    LOOP

FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'In PVT 102');
            l_gen_seq := NULL;

            l_gen_seq := fnd_seqnum.get_next_sequence
                (appid      =>  l_okl_application_id,
                cat_code    =>  l_document_category,
                sobid       =>  l_cnsld_invs(i).cin_rec.set_of_books_id,
                met_code    =>  'A',
                trx_date    =>  SYSDATE,
                dbseqnm     =>  lx_dbseqnm,
                dbseqid     =>  lx_dbseqid);

            l_cnsld_invs(i).cin_rec.invoice_number := l_gen_seq;
--start:|  01-MAY-2007  cklee -- Disbursement changes for R12B, bug fixed:           |
            l_cnsld_invs(i).cin_rec.vendor_invoice_number := NVL(l_cnsld_invs(i).cin_rec.vendor_invoice_number,l_gen_seq);
--end:|  01-MAY-2007  cklee -- Disbursement changes for R12B, bug fixed:           |

    END LOOP;

    end If;

FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'In PVT 103');
        x_cnsld_invs := l_cnsld_invs;

	------------------------------------------------------------
	-- End processing
	------------------------------------------------------------

	Okl_Api.END_ACTIVITY (
		x_msg_count	=> x_msg_count,
		x_msg_data	=> x_msg_data);


EXCEPTION
	------------------------------------------------------------
	-- Exception handling
	------------------------------------------------------------
	WHEN OKL_API.G_EXCEPTION_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '*=> ERROR: '||SQLERRM);
		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OKL_API.G_RET_STS_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '*=> ERROR: '||SQLERRM);
		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OKL_API.G_RET_STS_UNEXP_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN OTHERS THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '*=> ERROR: '||SQLERRM);
		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OTHERS',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');
END apply_consolidation_rules_ssir;

------------------------------------------------
------------------------------------------------
--start: 31-Oct-2007 cklee -- bug: 6508575 fixed
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : apply_consolidation_rules
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
PROCEDURE apply_consolidation_rules(
     p_api_version	       IN  NUMBER,
	 p_init_msg_list       IN  VARCHAR2	DEFAULT OKC_API.G_FALSE,
	 x_return_status       OUT NOCOPY VARCHAR2,
	 x_msg_count	       OUT NOCOPY NUMBER,
	 x_msg_data	           OUT NOCOPY VARCHAR2,
--	 x_cnsld_invs          OUT NOCOPY cnsld_invs_tbl_type,
     p_contract_id         IN  NUMBER  DEFAULT NULL,
 	 p_vendor_id           IN  NUMBER  DEFAULT NULL,
	 p_vendor_site_id      IN  NUMBER  DEFAULT NULL,
     p_vpa_id              IN  NUMBER  DEFAULT NULL,
     p_stream_type_purpose IN  VARCHAR2 DEFAULT NULL,
     p_from_date           IN  DATE,
     p_to_date             IN  DATE)
IS
	------------------------------------------------------------
	-- Declare variables required by APIs
	------------------------------------------------------------
   	l_api_version	CONSTANT NUMBER     := 1;
	l_api_name	CONSTANT VARCHAR2(30)   := 'APPLY_CONSOLIDATION_RULES';
	l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	------------------------------------------------------------
	-- Declare Process variables
	------------------------------------------------------------
    l_msg_index_out     NUMBER;

--    l_cin_tbl OKL_CIN_PVT.cin_tbl_type;
--    lx_cin_tbl OKL_CIN_PVT.cin_tbl_type;

    l_cin_rec OKL_CIN_PVT.cin_rec_type;
    lx_cin_rec OKL_CIN_PVT.cin_rec_type;

    l_tplv_rec   OKL_TPL_PVT.tplv_rec_type;
    lx_tplv_rec  OKL_TPL_PVT.tplv_rec_type;

    l_tplv_tbl   OKL_TPL_PVT.tplv_tbl_type;
    lx_tplv_tbl  OKL_TPL_PVT.tplv_tbl_type;

--    l_cnsld_invs cnsld_invs_tbl_type;

    l_gen_seq           okl_trx_ap_invoices_v.invoice_number%TYPE;
    l_conc_status       VARCHAR2(1);

-- Main cursor to get the consolidate invoice header
    CURSOR c_cin_invoice IS
	    SELECT
            TRUNC(okl_pay_invoices_cons_pvt.get_ap_invoice_date(
            tap.date_invoiced,povs.vendor_id,tap.ipvs_id,sty.stream_type_purpose,'Y')) cin_date_invoiced -- |  12-Dec-2007  cklee -- Fixed bug: 6682348 added trunc
            ,tap.pay_group_lookup_code
            ,tap.ipvs_id
            ,tap.ippt_id
            ,tap.payment_method_code
            ,tap.currency_code
            ,tap.currency_conversion_type
            ,tap.currency_conversion_rate
	        ,TRUNC(tap.currency_conversion_date) currency_conversion_date -- cklee 09/13/07
--futrue release           ,okl_pay_invoices_cons_pvt.get_contract_group(
--            tap.date_invoiced,povs.vendor_id,tap.ipvs_id,sty.stream_type_purpose,chr.contract_number, nvl(tpl.adv_grouping_flag,'Y')) contract_group
            ,okl_pay_invoices_cons_pvt.get_Disbursement_rule(
            tap.date_invoiced,tpl.id,povs.vendor_id,tap.ipvs_id,sty.stream_type_purpose,'Y') disbursement_rule
            ,okl_pay_invoices_cons_pvt.get_Disbursement_group(
            tap.date_invoiced,povs.vendor_id,tap.ipvs_id,sty.stream_type_purpose,'Y') disbursement_group
            ,SUM(tpl.amount) cin_invoice_amount
            ,povs.vendor_id
    	    ,tap.INVOICE_TYPE
            ,NVL(tap.set_of_books_id, OKL_ACCOUNTING_UTIL.get_set_of_books_id) sob_id
            ,tap.LEGAL_ENTITY_ID
    	    ,tap.VPA_ID
            ,acc_cr.code_combination_id
            ,COUNT(1) line_count
        FROM
            okl_trns_acc_dstrs  acc_cr
            ,okl_txl_ap_inv_lns_b tpl
            ,okl_trx_ap_invoices_b tap
            ,po_vendor_sites_all povs
--            ,okc_k_headers_all_b chr -- cklee 09/13/07
			,OKL_STRM_TYPE_B sty -- cklee 09/13/07
        WHERE
            NVL(tap.trx_status_code, 'ENTERED') in ( 'ENTERED', 'APPROVED' ) AND
            trunc(tap.date_invoiced) BETWEEN
            NVL(p_from_date, trunc(tap.date_invoiced)) AND NVL(p_to_date, trunc(tap.date_invoiced))
            AND nvl(acc_cr.cr_dr_flag(+), 'C') = 'C'
            AND acc_cr.source_table (+)= 'OKL_TXL_AP_INV_LNS_B'
            AND tpl.id = acc_cr.source_id (+)
            AND tap.id = tpl.tap_id
            AND povs.vendor_site_id = tap.ipvs_id
            AND tap.FUNDING_TYPE_CODE IS NULL
	    AND nvl(tpl.khr_id,-1) = nvl(p_contract_id, nvl(tpl.khr_id,-1)) -- cklee 09/13/07
	    AND nvl(povs.vendor_id,-1) = nvl(p_vendor_id, nvl(povs.vendor_id,-1) )
	    AND nvl(tap.ipvs_id,-1) = nvl(p_vendor_site_id, nvl(tap.ipvs_id,-1))
--        AND tpl.khr_id = chr.id
        AND tpl.sty_id = sty.id
        AND nvl(sty.stream_type_purpose, 'xxx') = nvl(p_stream_type_purpose,nvl(sty.stream_type_purpose, 'xxx'))
	    AND nvl(tap.vpa_id,-1) = nvl(p_vpa_id, nvl(tap.vpa_id,-1))
      GROUP BY
	       povs.vendor_id,
	       tap.ipvs_id,
	       tap.pay_group_lookup_code,
	       tap.payment_method_code,
	       tap.ippt_id,
	       NVL(tap.set_of_books_id, OKL_ACCOUNTING_UTIL.get_set_of_books_id),
	       acc_cr.code_combination_id,
	       tap.currency_code,
	       tap.currency_conversion_type,
	       tap.currency_conversion_rate,
	       TRUNC(tap.currency_conversion_date), -- cklee 09/13/07
	       tap.legal_entity_id,
	       tap.vpa_id,
	       tap.invoice_type,
           okl_pay_invoices_cons_pvt.get_Disbursement_rule(
             tap.date_invoiced,tpl.id,povs.vendor_id,tap.ipvs_id,sty.stream_type_purpose,'Y'),
           okl_pay_invoices_cons_pvt.get_Disbursement_group(
             tap.date_invoiced,povs.vendor_id,tap.ipvs_id,sty.stream_type_purpose,'Y'),
           TRUNC(okl_pay_invoices_cons_pvt.get_ap_invoice_date(
             tap.date_invoiced,povs.vendor_id,tap.ipvs_id,sty.stream_type_purpose,'Y')) -- |  12-Dec-2007  cklee -- Fixed bug: 6682348 added trunc
 	  UNION	ALL
		SELECT
            TRUNC(okl_pay_invoices_cons_pvt.get_ap_invoice_date(
            tap.date_invoiced,povs.vendor_id,tap.ipvs_id,sty.stream_type_purpose,'Y')) cin_date_invoiced -- |  12-Dec-2007  cklee -- Fixed bug: 6682348 added trunc
            ,tap.pay_group_lookup_code
            ,tap.ipvs_id
            ,tap.ippt_id
            ,tap.payment_method_code
            ,tap.currency_code
            ,tap.currency_conversion_type
            ,tap.currency_conversion_rate
	        ,TRUNC(tap.currency_conversion_date) currency_conversion_date -- cklee 09/13/07
--futrue release            ,okl_pay_invoices_cons_pvt.get_contract_group(
--            tap.date_invoiced,povs.vendor_id,tap.ipvs_id,sty.stream_type_purpose,chr.contract_number, nvl(tpl.adv_grouping_flag,'Y')) contract_group
            ,okl_pay_invoices_cons_pvt.get_Disbursement_rule(
            tap.date_invoiced,tpl.id,povs.vendor_id,tap.ipvs_id,sty.stream_type_purpose,'Y') disbursement_rule
            ,okl_pay_invoices_cons_pvt.get_Disbursement_group(
            tap.date_invoiced,povs.vendor_id,tap.ipvs_id,sty.stream_type_purpose,'Y') disbursement_group
            ,SUM(tpl.amount) cin_invoice_amount
            ,povs.vendor_id
    	    ,tap.INVOICE_TYPE
            ,NVL(tap.set_of_books_id, OKL_ACCOUNTING_UTIL.get_set_of_books_id) sob_id
    	    ,tap.LEGAL_ENTITY_ID
    	    ,tap.VPA_ID
            ,acc_cr.code_combination_id
            ,COUNT(1) line_count
        FROM
            okl_trns_acc_dstrs  acc_cr
            ,okl_txl_ap_inv_lns_b tpl
            ,okl_trx_ap_invoices_b tap
            ,po_vendor_sites_all povs
--            ,okc_k_headers_all_b chr -- cklee 09/13/07
            ,OKL_STRM_TYPE_B sty -- cklee 09/13/07
        WHERE
            NVL(tap.trx_status_code, 'APPROVED') in ( 'APPROVED') AND
            trunc(tap.date_invoiced) BETWEEN
            NVL(p_from_date, trunc(tap.date_invoiced)) AND NVL(p_to_date, trunc(tap.date_invoiced))
            AND nvl(acc_cr.cr_dr_flag(+), 'C') = 'C'
            AND acc_cr.source_table (+)= 'OKL_TXL_AP_INV_LNS_B'
            AND tpl.id = acc_cr.source_id (+)
            AND tap.id = tpl.tap_id
            AND povs.vendor_site_id = tap.ipvs_id
            AND tap.FUNDING_TYPE_CODE IS NOT NULL
	    AND nvl(tpl.khr_id,-1) = nvl(p_contract_id, nvl(tpl.khr_id,-1)) -- cklee 09/13/07
	    AND nvl(tap.vendor_id,-1) = nvl(p_vendor_id, nvl(tap.vendor_id,-1) )
	    AND nvl(tap.ipvs_id,-1) = nvl(p_vendor_site_id, nvl(tap.ipvs_id,-1))
--        AND tpl.khr_id = chr.id
        AND tpl.sty_id = sty.id
        AND nvl(sty.stream_type_purpose, 'xxx') = nvl(p_stream_type_purpose,nvl(sty.stream_type_purpose, 'xxx'))
	    AND nvl(tap.vpa_id,-1) = nvl(p_vpa_id, nvl(tap.vpa_id,-1))
      GROUP BY
	       povs.vendor_id,
	       tap.ipvs_id,
	       tap.pay_group_lookup_code,
	       tap.payment_method_code,
	       tap.ippt_id,
	       NVL(tap.set_of_books_id, OKL_ACCOUNTING_UTIL.get_set_of_books_id),
	       acc_cr.code_combination_id,
	       tap.currency_code,
	       tap.currency_conversion_type,
	       tap.currency_conversion_rate,
	       TRUNC(tap.currency_conversion_date), -- cklee 09/13/07
	       tap.legal_entity_id,
	       tap.vpa_id,
	       tap.invoice_type,
           okl_pay_invoices_cons_pvt.get_Disbursement_rule(
             tap.date_invoiced,tpl.id,povs.vendor_id,tap.ipvs_id,sty.stream_type_purpose,'Y'),
           okl_pay_invoices_cons_pvt.get_Disbursement_group(
             tap.date_invoiced,povs.vendor_id,tap.ipvs_id,sty.stream_type_purpose,'Y'),
           TRUNC(okl_pay_invoices_cons_pvt.get_ap_invoice_date(
             tap.date_invoiced,povs.vendor_id,tap.ipvs_id,sty.stream_type_purpose,'Y')); -- |  12-Dec-2007  cklee -- Fixed bug: 6682348 added trunc

      r_cin_invoice c_cin_invoice%ROWTYPE;

--
-- details cursor to get all invoice lines
    CURSOR c_invoice (
           p_vendor_id                 po_vendor_sites_all.vendor_id%type,
	       p_ipvs_id                   okl_trx_ap_invs_all_b.ipvs_id%type,
	       p_pay_group_lookup_code     okl_trx_ap_invs_all_b.pay_group_lookup_code%type,
	       p_payment_method_code       okl_trx_ap_invs_all_b.payment_method_code%type,
	       p_ippt_id                   okl_trx_ap_invs_all_b.ippt_id%type,
	       p_set_of_books_id           okl_trx_ap_invs_all_b.set_of_books_id%type,
	       p_code_combination_id       okl_trns_acc_dstrs.code_combination_id%type,
	       p_currency_code             okl_trx_ap_invs_all_b.currency_code%type,
	       p_currency_conversion_type  okl_trx_ap_invs_all_b.currency_conversion_type%type,
	       p_currency_conversion_rate  okl_trx_ap_invs_all_b.currency_conversion_rate%type,
	       p_currency_conversion_date  date,
	       p_legal_entity_id           okl_trx_ap_invs_all_b.legal_entity_id%type,
	       p_vpa_id                    okl_trx_ap_invs_all_b.vpa_id%type,
	       p_invoice_type              okl_trx_ap_invs_all_b.invoice_type%type,
--           p_contract_group            okc_k_headers_all_b.contract_number%type,
		   p_disbursement_rule         varchar2,
		   p_disbursement_group        varchar2,
		   p_cin_date_invoiced         date
	)IS
		SELECT
             tap.id  tap_id
            ,NVL(tap.set_of_books_id, OKL_ACCOUNTING_UTIL.get_set_of_books_id) sob_id
            ,tap.org_id
            ,tap.invoice_number
            ,nvl(tap.vendor_invoice_number, tap.invoice_number) vendor_invoice_number
            ,tap.code_combination_id tap_ccid
            ,tap.date_invoiced date_invoiced
            ,tap.pay_group_lookup_code
            ,tap.ipvs_id
            ,tap.ippt_id
            ,tap.payment_method_code
            ,tap.currency_code
            ,tap.currency_conversion_type
            ,tap.currency_conversion_rate
	        ,TRUNC(tap.currency_conversion_date) currency_conversion_date -- cklee 09/13/07
            ,tpl.khr_id
            ,tap.try_id
            ,tpl.id tpl_id
            ,tpl.sty_id
            ,acc_db.code_combination_id db_ccid
            ,acc_cr.code_combination_id cr_ccid
            ,povs.vendor_id
	    ,tap.INVOICE_TYPE
	    ,tap.DATE_GL
	    ,tap.LEGAL_ENTITY_ID
	    ,tap.VPA_ID
--        ,nvl(tpl.adv_grouping_flag, 'Y') adv_grouping_flag -- cklee 09/14/07
        ,sty.stream_type_purpose -- cklee 09/14/07
        FROM
            okl_trns_acc_dstrs  acc_db
            ,okl_trns_acc_dstrs  acc_cr
            ,po_vendor_sites_all povs
            ,okl_txl_ap_inv_lns_b tpl
            ,okl_trx_ap_invoices_b tap
--            ,okc_k_headers_all_b chr -- cklee 09/13/07
			,OKL_STRM_TYPE_B sty -- cklee 09/13/07
        WHERE
            NVL(tap.trx_status_code, 'ENTERED') in ( 'ENTERED', 'APPROVED' )
            AND trunc(tap.date_invoiced) BETWEEN
              NVL(p_from_date, trunc(tap.date_invoiced)) AND NVL(p_to_date, trunc(tap.date_invoiced))
            AND nvl(acc_db.cr_dr_flag(+), 'D') = 'D' --ssiruvol 05May2007
            AND nvl(acc_cr.cr_dr_flag(+), 'C') = 'C' --ssiruvol 05May2007
            AND acc_db.source_table (+)= 'OKL_TXL_AP_INV_LNS_B'
            AND acc_cr.source_table (+)= 'OKL_TXL_AP_INV_LNS_B'
            AND tpl.id = acc_db.source_id (+)
            AND tpl.id = acc_cr.source_id (+)
            AND povs.vendor_site_id = tap.ipvs_id
            AND tap.id = tpl.tap_id
            AND tap.FUNDING_TYPE_CODE IS NULL
--        AND tpl.khr_id = chr.id
        AND tpl.sty_id = sty.id
      and tpl.khr_id                    = nvl(p_contract_id, tpl.khr_id) -- cklee 09/13/07
      and sty.stream_type_purpose       = nvl(p_stream_type_purpose, sty.stream_type_purpose)
      and povs.vendor_id                = p_vendor_id
      and tap.ipvs_id                   = p_ipvs_id
      and NVL(tap.pay_group_lookup_code,'x')     = NVL(p_pay_group_lookup_code,'x')
      and tap.payment_method_code       = p_payment_method_code
      and NVL(tap.ippt_id,-123)                   = NVL(p_ippt_id,-123)
      and NVL(tap.set_of_books_id, OKL_ACCOUNTING_UTIL.get_set_of_books_id) = p_set_of_books_id
      and nvl(acc_cr.code_combination_id, -1)  = nvl(p_code_combination_id, nvl(acc_cr.code_combination_id, -1))
      and tap.currency_code             = p_currency_code
      and nvl(tap.currency_conversion_type, 'x')  = nvl(p_currency_conversion_type,nvl(tap.currency_conversion_type, 'x'))
      and nvl(tap.currency_conversion_rate, -1)  = nvl(p_currency_conversion_rate,nvl(tap.currency_conversion_rate, -1))
      and nvl(TRUNC(tap.currency_conversion_date), trunc(sysdate))  = nvl(TRUNC(p_currency_conversion_date),nvl(TRUNC(tap.currency_conversion_date), trunc(sysdate)))  -- |  12-Dec-2007  cklee -- Fixed bug: 6682348 added trunc
      and tap.legal_entity_id           = p_legal_entity_id
      and nvl(tap.vpa_id,-1)            = nvl(p_vpa_id, nvl(tap.vpa_id,-1))
      and nvl(tap.invoice_type, 'x')    = nvl(p_invoice_type,nvl(tap.invoice_type, 'x'))
      and okl_pay_invoices_cons_pvt.get_Disbursement_rule(
            tap.date_invoiced,tpl.id, povs.vendor_id,tap.ipvs_id,sty.stream_type_purpose,'Y')
                                          = p_disbursement_rule
      and okl_pay_invoices_cons_pvt.get_Disbursement_group(
            tap.date_invoiced,povs.vendor_id,tap.ipvs_id,sty.stream_type_purpose,'Y')
                                          = p_disbursement_group
--      and nvl(okl_pay_invoices_cons_pvt.get_contract_group(
--            tap.date_invoiced,povs.vendor_id,tap.ipvs_id,sty.stream_type_purpose,chr.contract_number, nvl(tpl.adv_grouping_flag,'Y')), 'x')
--                                          = nvl(p_contract_group, 'x')
      and TRUNC(okl_pay_invoices_cons_pvt.get_ap_invoice_date(
            tap.date_invoiced,povs.vendor_id,tap.ipvs_id,sty.stream_type_purpose,'Y'))  -- |  12-Dec-2007  cklee -- Fixed bug: 6682348 added trunc
                                          = p_cin_date_invoiced
	  UNION	ALL
		SELECT
             tap.id  tap_id
            ,NVL(tap.set_of_books_id, OKL_ACCOUNTING_UTIL.get_set_of_books_id) sob_id
            ,tap.org_id
            ,tap.invoice_number
            ,nvl(tap.vendor_invoice_number, tap.invoice_number) vendor_invoice_number
            ,tap.code_combination_id tap_ccid
            ,tap.date_invoiced date_invoiced
            ,tap.pay_group_lookup_code
            ,tap.ipvs_id
            ,tap.ippt_id
            ,tap.payment_method_code
            ,tap.currency_code
            ,tap.currency_conversion_type
            ,tap.currency_conversion_rate
	        ,TRUNC(tap.currency_conversion_date) currency_conversion_date -- cklee 09/13/07
            ,tpl.khr_id
            ,tap.try_id
            ,tpl.id tpl_id
            ,tpl.sty_id
            ,acc_db.code_combination_id db_ccid
            ,acc_cr.code_combination_id cr_ccid
            ,povs.vendor_id
	    ,tap.INVOICE_TYPE
	    ,tap.DATE_GL
	    ,tap.LEGAL_ENTITY_ID
	    ,tap.VPA_ID
--        ,nvl(tpl.adv_grouping_flag, 'Y') adv_grouping_flag -- cklee 09/14/07
        ,sty.stream_type_purpose -- cklee 09/14/07
        FROM
            okl_trns_acc_dstrs  acc_db
            ,okl_trns_acc_dstrs  acc_cr
            ,po_vendor_sites_all povs
            ,okl_txl_ap_inv_lns_b tpl
            ,okl_trx_ap_invoices_b tap
--            ,okc_k_headers_all_b chr -- cklee 09/13/07
            ,OKL_STRM_TYPE_B sty -- cklee 09/13/07
        WHERE
            NVL(tap.trx_status_code, 'ENTERED') in ( 'ENTERED', 'APPROVED' )
            AND trunc(tap.date_invoiced) BETWEEN
              NVL(p_from_date, trunc(tap.date_invoiced)) AND NVL(p_to_date, trunc(tap.date_invoiced))
            AND nvl(acc_db.cr_dr_flag(+), 'D') = 'D' --ssiruvol 05May2007
            AND nvl(acc_cr.cr_dr_flag(+), 'C') = 'C' --ssiruvol 05May2007
            AND acc_db.source_table (+)= 'OKL_TXL_AP_INV_LNS_B'
            AND acc_cr.source_table (+)= 'OKL_TXL_AP_INV_LNS_B'
            AND tpl.id = acc_db.source_id (+)
            AND tpl.id = acc_cr.source_id (+)
            AND povs.vendor_site_id = tap.ipvs_id
            AND tap.id = tpl.tap_id
            AND tap.FUNDING_TYPE_CODE IS NOT NULL
--        AND tpl.khr_id = chr.id
        AND tpl.sty_id = sty.id
      and tpl.khr_id                    = nvl(p_contract_id, tpl.khr_id) -- cklee 09/13/07
      and sty.stream_type_purpose       = nvl(p_stream_type_purpose, sty.stream_type_purpose)
      and povs.vendor_id                = p_vendor_id
      and tap.ipvs_id                   = p_ipvs_id
      and NVL(tap.pay_group_lookup_code,'x')     = NVL(p_pay_group_lookup_code,'x')
      and tap.payment_method_code       = p_payment_method_code
      and NVL(tap.ippt_id,-123)                   = NVL(p_ippt_id,-123)
      and NVL(tap.set_of_books_id, OKL_ACCOUNTING_UTIL.get_set_of_books_id) = p_set_of_books_id
      and nvl(acc_cr.code_combination_id, -1)  = nvl(p_code_combination_id, nvl(acc_cr.code_combination_id, -1))
      and tap.currency_code             = p_currency_code
      and nvl(tap.currency_conversion_type, 'x')  = nvl(p_currency_conversion_type,nvl(tap.currency_conversion_type, 'x'))
      and nvl(tap.currency_conversion_rate, -1)  = nvl(p_currency_conversion_rate,nvl(tap.currency_conversion_rate, -1))
      and nvl(TRUNC(tap.currency_conversion_date), trunc(sysdate))  = nvl(TRUNC(p_currency_conversion_date),nvl(TRUNC(tap.currency_conversion_date), trunc(sysdate))) --  -- |  12-Dec-2007  cklee -- Fixed bug: 6682348 added trunc
      and tap.legal_entity_id           = p_legal_entity_id
      and nvl(tap.vpa_id,-1)            = nvl(p_vpa_id, nvl(tap.vpa_id,-1))
      and nvl(tap.invoice_type, 'x')    = nvl(p_invoice_type,nvl(tap.invoice_type, 'x'))
      and okl_pay_invoices_cons_pvt.get_Disbursement_rule(
            tap.date_invoiced,tpl.id,povs.vendor_id,tap.ipvs_id,sty.stream_type_purpose,'Y')
                                          = p_disbursement_rule
      and okl_pay_invoices_cons_pvt.get_Disbursement_group(
            tap.date_invoiced,povs.vendor_id,tap.ipvs_id,sty.stream_type_purpose,'Y')
                                          = p_disbursement_group
--      and nvl(okl_pay_invoices_cons_pvt.get_contract_group(
--            tap.date_invoiced,povs.vendor_id,tap.ipvs_id,sty.stream_type_purpose,chr.contract_number, nvl(tpl.adv_grouping_flag,'Y')), 'x')
--                                          = nvl(p_contract_group, 'x')
      and TRUNC(okl_pay_invoices_cons_pvt.get_ap_invoice_date(
            tap.date_invoiced,povs.vendor_id,tap.ipvs_id,sty.stream_type_purpose,'Y'))
                                          = p_cin_date_invoiced; -- |  12-Dec-2007  cklee -- Fixed bug: 6682348 added trunc

      r_invoice c_invoice%ROWTYPE;


     l_okl_application_id NUMBER(3) := 540;
     l_document_category VARCHAR2(100):= 'OKL Lease Pay Invoices';
     lX_dbseqnm          VARCHAR2(2000):= '';
     lX_dbseqid          NUMBER(38):= NULL;

     cin_cnt number := 0;
     cin_ln_cnt number := 0;

BEGIN
	------------------------------------------------------------
	-- Start processing
	------------------------------------------------------------

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'apply_consolidation_rules 1');

	x_return_status := OKL_API.G_RET_STS_SUCCESS;

	l_return_status := OKL_API.START_ACTIVITY(
		p_api_name	=> l_api_name,
        p_pkg_name	=> g_pkg_name,
		p_init_msg_list	=> p_init_msg_list,
		l_api_version	=> l_api_version,
		p_api_version	=> p_api_version,
		p_api_type	=> '_PVT',
		x_return_status	=> l_return_status);

	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

    BEGIN  -- block to handel trx status update
      cin_ln_cnt := 0; -- initial to 0
      -- go through each cin header
      FOR r_cin_invoice IN c_cin_invoice LOOP

        cin_cnt := 0; -- initial to 0

        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'apply_consolidation_rules 1.1');


--        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'apply_consolidation_rules 2 cin_cnt:' || cin_cnt);
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'apply_consolidation_rules 2');
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'apply_consolidation_rules 2          p_contract_id                => '|| p_contract_id);
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'apply_consolidation_rules 2          p_from_date                  => '|| p_from_date);
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'apply_consolidation_rules 2          p_to_date                    => '|| p_to_date);
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'apply_consolidation_rules 2          p_stream_type_purpose        => '|| p_stream_type_purpose);

        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'apply_consolidation_rules 2          p_vendor_id                  => '|| r_cin_invoice.vendor_id);
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'apply_consolidation_rules 2          ,p_ipvs_id                   =>'||  r_cin_invoice.ipvs_id);
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'apply_consolidation_rules 2          ,p_pay_group_lookup_code     =>'||  r_cin_invoice.pay_group_lookup_code);
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'apply_consolidation_rules 2          ,p_payment_method_code       =>'||  r_cin_invoice.payment_method_code);
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'apply_consolidation_rules 2          ,p_ippt_id                   =>'||  r_cin_invoice.ippt_id);
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'apply_consolidation_rules 2          ,p_set_of_books_id           =>'||  r_cin_invoice.sob_id);
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'apply_consolidation_rules 2          ,p_code_combination_id       =>'||  r_cin_invoice.code_combination_id);
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'apply_consolidation_rules 2          ,p_currency_code             =>'||  r_cin_invoice.currency_code);
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'apply_consolidation_rules 2          ,p_currency_conversion_type  =>'||  r_cin_invoice.currency_conversion_type);
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'apply_consolidation_rules 2          ,p_currency_conversion_rate  =>'||  r_cin_invoice.currency_conversion_rate);
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'apply_consolidation_rules 2          ,p_currency_conversion_date  =>'||  r_cin_invoice.currency_conversion_date);
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'apply_consolidation_rules 2          ,p_legal_entity_id           =>'||  r_cin_invoice.legal_entity_id);
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'apply_consolidation_rules 2          ,p_vpa_id                    =>'||  r_cin_invoice.vpa_id);
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'apply_consolidation_rules 2          ,p_invoice_type              =>'||  r_cin_invoice.invoice_type);
--         ,p_contract_group            => r_cin_invoice.contract_group
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'apply_consolidation_rules 2          ,p_disbursement_rule         =>'||  r_cin_invoice.disbursement_rule);
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'apply_consolidation_rules 2          ,p_disbursement_group        =>'||  r_cin_invoice.disbursement_group);
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'apply_consolidation_rules 2          ,p_cin_date_invoiced         =>'||  r_cin_invoice.cin_date_invoiced);

        -- go through all cin lines
        FOR r_invoice IN c_invoice(
          p_vendor_id                 => r_cin_invoice.vendor_id
          ,p_ipvs_id                   => r_cin_invoice.ipvs_id
          ,p_pay_group_lookup_code     => r_cin_invoice.pay_group_lookup_code
          ,p_payment_method_code       => r_cin_invoice.payment_method_code
          ,p_ippt_id                   => r_cin_invoice.ippt_id
          ,p_set_of_books_id           => r_cin_invoice.sob_id
          ,p_code_combination_id       => r_cin_invoice.code_combination_id
          ,p_currency_code             => r_cin_invoice.currency_code
          ,p_currency_conversion_type  => r_cin_invoice.currency_conversion_type
          ,p_currency_conversion_rate  => r_cin_invoice.currency_conversion_rate
          ,p_currency_conversion_date  => r_cin_invoice.currency_conversion_date
          ,p_legal_entity_id           => r_cin_invoice.legal_entity_id
          ,p_vpa_id                    => r_cin_invoice.vpa_id
          ,p_invoice_type              => r_cin_invoice.invoice_type
--          ,p_contract_group            => r_cin_invoice.contract_group
          ,p_disbursement_rule         => r_cin_invoice.disbursement_rule
          ,p_disbursement_group        => r_cin_invoice.disbursement_group
          ,p_cin_date_invoiced         => r_cin_invoice.cin_date_invoiced
    	  ) LOOP

          FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'apply_consolidation_rules 2: in loop:cin_cnt<' || cin_cnt || '>');
          -- 1. create cin header
          IF cin_cnt = 0 THEN
            -- get all attributes and assign to cin record
            l_cin_rec.amount := r_cin_invoice.cin_invoice_amount;

            l_cin_rec.date_invoiced := r_cin_invoice.cin_date_invoiced;

--start:|  30-Nov-2007  cklee -- bug: 6628542 fixed                                  |
            -- 1 header and 1 line case
--            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'apply_consolidation_rules 3r_cin_invoice.line_count: '
--			 || r_cin_invoice.line_count );
--            IF r_cin_invoice.line_count = 1 THEN
--              l_cin_rec.vendor_invoice_number := r_invoice.vendor_invoice_number;
--              l_cin_rec.invoice_number := r_invoice.invoice_number;
--            ELSE -- 1 header and multiple lines case
            l_gen_seq := NULL;
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'apply_consolidation_rules 4 fnd_seqnum.get_next_sequence: r_invoice.sob_id' || r_invoice.sob_id );

            FOR v_cnt In 1..2 LOOP
              l_gen_seq := fnd_seqnum.get_next_sequence
                  (appid      =>  l_okl_application_id,
                  cat_code    =>  l_document_category,
                  sobid       =>  r_invoice.sob_id,
                  met_code    =>  'A',
                  trx_date    =>  SYSDATE,
                  dbseqnm     =>  lx_dbseqnm,
                  dbseqid     =>  lx_dbseqid);

              IF v_cnt = 1 THEN
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'apply_consolidation_rules 5 fnd_seqnum.get_next_sequence: l_gen_seq(l_cin_rec.vendor_invoice_number- AP invoice number)' || l_gen_seq );
                l_cin_rec.vendor_invoice_number := l_gen_seq;
              ELSE
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'apply_consolidation_rules 5 fnd_seqnum.get_next_sequence: l_gen_seq(l_cin_rec.invoice_number- AP voucher number)' || l_gen_seq );
                l_cin_rec.invoice_number := l_gen_seq;
              END IF;
            END LOOP;

--            END IF;
--end:|  30-Nov-2007  cklee -- bug: 6628542 fixed                                  |

            -- 1. get vendor sequence number if any
            -- 2. reset the vendor sequence number at vendor site, rule
            -- 3. set vendor sequence number at cin header
            handle_next_invoice_seq(
              p_api_version         => p_api_version,
              p_init_msg_list       => p_init_msg_list,
              x_return_status       => x_return_status,
              x_msg_count           => x_msg_count,
              x_msg_data            => x_msg_data,
              p_transaction_date    => r_invoice.date_invoiced,
              p_vendor_id           => r_invoice.vendor_id,
              p_vendor_site_id      => r_invoice.ipvs_id,
              p_stream_type_purpose => r_invoice.stream_type_purpose,
              p_adv_grouping_flag   => 'Y',
              x_next_inv_seq        => l_cin_rec.self_bill_inv_num);


            IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
              FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ERROR: get and set vendor invoice sequence.');
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
              FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ERROR: get and set vendor invoice sequence.');
              RAISE OKL_API.G_EXCEPTION_ERROR;
            ELSIF (x_return_status ='S') THEN
              FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' handle_next_invoice_seq: ' || l_cin_rec.self_bill_inv_num);
            END IF;

            l_cin_rec.org_id                   := r_invoice.org_id;
            l_cin_rec.trx_status_code          := 'ENTERED';--r_invoice.trx_status_code;
            l_cin_rec.currency_code            := r_invoice.currency_code;
            l_cin_rec.try_id                   := r_invoice.try_id;
            l_cin_rec.ipvs_id                  := r_invoice.ipvs_id;
            l_cin_rec.CURRENCY_CONVERSION_TYPE := r_invoice.CURRENCY_CONVERSION_TYPE;
            l_cin_rec.CURRENCY_CONVERSION_RATE := r_invoice.CURRENCY_CONVERSION_RATE;
            l_cin_rec.CURRENCY_CONVERSION_DATE := r_invoice.CURRENCY_CONVERSION_DATE;
            l_cin_rec.PAYMENT_METHOD_CODE      := r_invoice.PAYMENT_METHOD_CODE;
	        l_cin_rec.PAY_GROUP_LOOKUP_CODE    := r_invoice.PAY_GROUP_LOOKUP_CODE ;
	        l_cin_rec.INVOICE_TYPE             := r_invoice.INVOICE_TYPE;
	        l_cin_rec.SET_OF_BOOKS_ID          := r_invoice.sob_id;
	        l_cin_rec.IPPT_ID                  := r_invoice.IPPT_ID;
	        l_cin_rec.DATE_GL                  := r_invoice.DATE_GL;
	        l_cin_rec.VENDOR_ID                := r_invoice.VENDOR_ID;
	        l_cin_rec.LEGAL_ENTITY_ID          := r_invoice.LEGAL_ENTITY_ID ;
	        l_cin_rec.VPA_ID                   := r_invoice.VPA_ID ;
            l_cin_rec.OBJECT_VERSION_NUMBER    := 1 ;
            l_cin_rec.CREATED_BY               := fnd_global.user_id ;
	        l_cin_rec.CREATION_DATE            := sysdate ;
	        l_cin_rec.LAST_UPDATED_BY          := fnd_global.user_id ;
            l_cin_rec.LAST_UPDATE_DATE         := sysdate ;
            l_cin_rec.accts_pay_cc_id          := NVL(r_invoice.tap_ccid,r_invoice.cr_ccid);
            l_cin_rec.REQUEST_ID               := Fnd_Global.CONC_REQUEST_ID ; -- 11-Dec-2007  cklee -- Fixed bug: 6682348 -- stamped request_id when insert

            OKL_CIN_PVT.insert_row(
              p_api_version   =>   p_api_version,
              p_init_msg_list =>   p_init_msg_list,
              x_return_status =>   x_return_status,
              x_msg_count     =>   x_msg_count,
              x_msg_data      =>   x_msg_data,
              p_cin_rec      =>    l_cin_rec,
              x_cin_rec      =>    lx_cin_rec);

            IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
              FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' (apply_consolidation_rules)ERROR: Creating Consolidated invoices.');
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
              FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' (apply_consolidation_rules)ERROR: Creating Consolidated invoices.');
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status ='S') THEN
              FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' (apply_consolidation_rules)Created Consolidated invoices: '||lx_cin_rec.cnsld_ap_inv_id);
            END IF;

            cin_cnt := cin_cnt + 1; -- create header only once
          END IF; -- IF cin_cnt = 0 THEN

          cin_ln_cnt := cin_ln_cnt + 1; -- increase the count
          -- 2. update okl_txl_ap_inv_lns_all_b with FK: cnsld_ap_inv_id and cnsld_line_number
	      UPDATE okl_txl_ap_inv_lns_all_b txl
	        SET txl.cnsld_ap_inv_id   = lx_cin_rec.cnsld_ap_inv_id,
	            txl.cnsld_line_number = cin_ln_cnt,
	            txl.LAST_UPDATED_BY   = fnd_global.user_id,
	            txl.LAST_UPDATE_DATE  = sysdate,
                txl.REQUEST_ID        = Fnd_Global.CONC_REQUEST_ID -- 11-Dec-2007  cklee -- Fixed bug: 6682348 -- stamped request_id when insert/UPDATE
            WHERE txl.id              = r_invoice.tpl_id;
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' update okl_txl_ap_inv_lns_all_b with FK: cnsld_ap_inv_id and cnsld_line_number. cin_ln_cnt:<'
		   || cin_ln_cnt || '>r_invoice.tpl_id:' ||r_invoice.tpl_id || 'lx_cin_rec.cnsld_ap_inv_id:'|| lx_cin_rec.cnsld_ap_inv_id);

          l_tplv_tbl(cin_ln_cnt).tap_id := r_invoice.tap_id;
        END LOOP; -- end of c_invoice loop
      END LOOP;

      -- Since the status stored at header, we only need to update once if
      -- one of the children record has been processed.
      --------------------------------------------------------------------
      -- note: we shall add another trx_status_code at line level okl_txl_ap_inv_lns_all_b
      --       in case if lines merged with diferent invoice header
      --------------------------------------------------------------------
      IF l_tplv_tbl.COUNT > 0 THEN
        FOR k in l_tplv_tbl.FIRST..l_tplv_tbl.LAST
        LOOP
          UPDATE OKL_TRX_AP_INVS_ALL_B trx
            SET trx.TRX_STATUS_CODE   = 'PROCESSED',
                trx.REQUEST_ID        = Fnd_Global.CONC_REQUEST_ID -- 11-Dec-2007  cklee -- Fixed bug: 6682348 -- stamped request_id when insert/UPDATE
            WHERE trx.ID              = l_tplv_tbl(k).tap_id
            AND trx.TRX_STATUS_CODE IN ('ENTERED', 'APPROVED');
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' UPDATE OKL_TRX_AP_INVS_ALL_B with Processed status.l_tplv_tbl('
		   ||k||').tap_id'|| l_tplv_tbl(k).tap_id);

        END LOOP;
      END IF;

    EXCEPTION
      WHEN OTHERS THEN

        IF l_tplv_tbl.COUNT > 0 THEN
          FOR j in l_tplv_tbl.FIRST..l_tplv_tbl.LAST
          LOOP

              UPDATE OKL_TRX_AP_INVS_ALL_B trx
              SET trx.TRX_STATUS_CODE = 'ERROR',
                  trx.REQUEST_ID      = Fnd_Global.CONC_REQUEST_ID -- 11-Dec-2007  cklee -- Fixed bug: 6682348 -- stamped request_id when insert/UPDATE
              WHERE trx.ID = l_tplv_tbl(j).tap_id
              AND trx.TRX_STATUS_CODE IN ('ENTERED', 'APPROVED');
              FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' UPDATE OKL_TRX_AP_INVS_ALL_B with Error status.l_tplv_tbl(' ||j||').tap_id'|| l_tplv_tbl(j).tap_id);

          END LOOP;
        END IF;
    END;

	------------------------------------------------------------
	-- End processing
	------------------------------------------------------------

	Okl_Api.END_ACTIVITY (
		x_msg_count	=> x_msg_count,
		x_msg_data	=> x_msg_data);


EXCEPTION
	------------------------------------------------------------
	-- Exception handling
	------------------------------------------------------------
	WHEN OKL_API.G_EXCEPTION_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '*=> ERROR: '||SQLERRM);
		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OKL_API.G_RET_STS_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '*=> ERROR: '||SQLERRM);
		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OKL_API.G_RET_STS_UNEXP_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN OTHERS THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '*=> ERROR: '||SQLERRM);
		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OTHERS',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');
END apply_consolidation_rules;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : handle_processing_fee
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
PROCEDURE handle_processing_fee(p_api_version	IN  NUMBER
                                 ,p_init_msg_list	IN  VARCHAR2	DEFAULT OKC_API.G_FALSE
	                             ,x_return_status	OUT NOCOPY      VARCHAR2
	                             ,x_msg_count		OUT NOCOPY      NUMBER
	                             ,x_msg_data		    OUT NOCOPY      VARCHAR2)
   IS
     ------------------------------------------------------------
	-- Declare Process variables
	------------------------------------------------------------
   	l_api_version	CONSTANT NUMBER     := 1;
	l_api_name	CONSTANT VARCHAR2(30)   := 'handle_processing_fee';
	l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	l_msg_index_out     NUMBER;
    i                   NUMBER;

 /*
      -- find existing 'no further processing" flag
      CURSOR c_no_adv_grp(p_cnsld_ap_invs_id okl_cnsld_ap_invs_all.cnsld_ap_inv_id%type) IS
      SELECT 1
      FROM OKL_TRX_AP_INVS_ALL_B TAP
      where NVL(TAP.ADV_GROUPING_FLAG, 'Y') = 'N'
      and tap.id in
	     (select txl.tap_id
          from okl_txl_ap_invs_all_b txl,
               okl_cnsld_ap_invs_all cin
          where txl.cnsld_ap_inv_id = tap.cnsld_ap_inv_id
          and txl.tap_id = tap.id);
*/

      CURSOR c_cnsld_hdr IS
      SELECT *
      FROM OKL_CNSLD_AP_INVS_ALL
      WHERE trx_status_code = 'ENTERED';

      l_row_found BOOLEAN;
--      r_no_adv_grp c_no_adv_grp%ROWTYPE;
BEGIN

     x_return_status := OKL_API.G_RET_STS_SUCCESS;

     l_return_status := OKL_API.START_ACTIVITY(
	                               	p_api_name	    => l_api_name,
    	                            p_pkg_name	    => g_pkg_name,
		                            p_init_msg_list	=> p_init_msg_list,
		                            l_api_version	=> l_api_version,
		                            p_api_version	=> p_api_version,
	                                p_api_type	    => '_PVT',
		                            x_return_status	=> l_return_status);

      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	  	RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	  ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	  END IF;
/*

Question 1:
Processing fee:
For each OKL internal invoice line, system guarantee to get only one unique Disbursement rule that based on vendor site,
stream type purpose, and date range vs transaction's vendor site, stream type purpose, and transaction date.
 This implies that once a consoldiate invoice has been generated, one invoice may refer to multiple Disbursement
  rules due to the changes of the final invoice date as well as combine stream type purposes.
   So how does the system to determine which rule need to be picked for processing fee process?

Question 2:
There is no relationship between lines within the same invoice. Hence this is no way to find out the link between
individual invoice line and individual processing fee within the invoice.

Question 3:
Processing fee:
if system subtract the fee amount from invoice amount, we may lose the track of the original transaaction amount

 Business logic:
   if Account Derivation option = AMB then
     if Fee Option = Per Invoice then
       --The fee is charged as one separate line on the AP invoice with a negative amount. fee option: fixed amount
           "1. Create a new OKL internal invoice header and line with invoice type = 'Mixed' with negative amount.
               (Assume the processing fee amount < invoice amount.)
            2. Update # 1 line FK with #1 consoldiate invoice
            3. Assume processing fee is only applicable for ""Standard"" invoice.
            4. Mark the OKL internal invoice header status to 'Processed"" once complete the transaction of consoldation."

     elsif Fee Option = Per Invoice line then
       --The fee is charged as multiple separate lines, one corresponding to each invoice line on the AP invoice with a negative amounts.
	   -- The amount of fee corresponding to an invoice line = Invoice line amount * %
           "1. Create a new OKL internal invoice line with negative amount and associated with the corresponding OKL internal invoice header.
               (Assume the processing fee amount < invoice amount.)
            2. Update # 1 line FK with #1 consoldiate invoice.
            3. Assume processing fee is only applicable for ""Standard"" invoice.

     end if;

   elsif Account Derivation option = ATS then
     if Fee Option = Per Invoice then
       --The fee amount is approportioned across invoice line amounts and subtracted from line amounts.
         "1. Find out the propotion amount for each line and update each line.
             formula:
               new line amount := old line amount - (fixed fee * (line amount / header amount))
          2. Update the OKL internal invoice header amount accordingly
             formula:
               new OKL internal header amount := old header amount - (fixed fee * (line amount / header amount))
          3. Update the consolidation invoice header amount acordingly.
             formula:
               3. new header amount := sum of all line amount (rounding issue may happen)
               (Assume the processing fee amount < invoice amount.)
          4. Assume processing fee is only applicable for ""Standard"" invoice.


     elsif Fee Option = Per Invoice line then
       --The fee amount per line is calculated as % of line amount and subtracted from each line
         "1. Find out the propotion amount for each line and update each line.
             formula:
               new line amount := old line amount - (old line amount * fee %)
          2. Update the OKL internal invoice header amount accordingly
             formula:
               new OKL internal header amount := old header amount - (old line amount * fee %)
          3. Update the consolidation invoice header amount acordingly.
             formula:
               3. new header amount := sum of all line amount (rounding issue may happen)
               (Assume the processing fee amount < invoice amount.)
          4. Assume processing fee is only applicable for ""Standard"" invoice.

     end if;
   end if;

*/

    FOR r_cnsld_hdr IN c_cnsld_hdr LOOP

/*        OPEN c_no_adv_grp(r_cnsld_hdr.cnsld_ap_inv_id);  */
/*        FETCH c_no_adv_grp INTO r_no_adv_grp;  */
/*        l_row_found := c_no_adv_grp%FOUND;  */
/*        CLOSE c_no_adv_grp;  */
/*    */
/*        IF NOT l_row_found THEN  */
/*    */
/*          -- 1. Get Disbursement rule for each consoldiation invoice (need to resolve multiple rules issue)  */
/*          l_disb_rules :=  get_Disbursement_term(  */
/*              			   p_transaction_date    => r_cnsld_hdr.date_invoiced, --p_transaction_date,  */
/*                             p_vendor_id           => r_cnsld_hdr.vendor_id,  */
/*                             p_vendor_site_id      => r_cnsld_hdr.ipvs_id,  */
/*             	    		   p_stream_type_purpose => p_stream_type_purpose, --?  */
/*               			   x_return_status       => lx_return_status,  */
/*               			   x_rule_found          => lx_rule_found);  */
/*    */
/*          IF lx_return_status = G_RET_STS_SUCCESS AND lx_rule_found = TRUE THEN  */
/*    */
/*          END IF; -- if rule found  */
/*        END IF; --IF p_adv_grouping_flag = 'Y' THEN  */

        -- get_disb_rule_options
--      IF G_ACC_SYS_OPTION = 'ATS' THEN -- Account Template Set
          -- handle_ATS_per_invoice
--      ELSE
          -- handle_AMB_per_invoice
--      END IF;
null;
    END LOOP; --> Header

    COMMIT;

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '============================================================');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '  ******* End Processing Records ******* ');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '============================================================');

	------------------------------------------------------------
	-- End processing
	------------------------------------------------------------

	Okl_Api.END_ACTIVITY (
		x_msg_count	=> x_msg_count,
		x_msg_data	=> x_msg_data);

EXCEPTION
      	------------------------------------------------------------
	-- Exception handling
	------------------------------------------------------------
	WHEN OKL_API.G_EXCEPTION_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '*=> ERROR: '||SQLERRM);
		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OKL_API.G_RET_STS_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '*=> ERROR: '||SQLERRM);
		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OKL_API.G_RET_STS_UNEXP_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN OTHERS THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '*=> ERROR: '||SQLERRM);
		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OTHERS',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');
END handle_processing_fee;

--end: 31-Oct-2007 cklee -- bug: 6508575 fixed

-- End of wraper code generated automatically by Debug code generator

  -- Start of Comments
  --    API name   : Transfer_to_External
  --    Pre-reqs   : None
  --    Function   :
  --    Parameters     :
  --    IN         :p_api_version     IN NUMBER   Required
  --                p_init_msg_list   IN VARCHAR2 Required
  --                p_from_date       IN DATE     Required
  --                p_to_date         IN DATE     Required
  --    Version    : 1.0
  --    History    : RKUTTIYA          01/26/07   Created
  -- End of Comments
PROCEDURE transfer_to_external(p_api_version	IN  NUMBER
                                 ,p_init_msg_list	IN  VARCHAR2	DEFAULT OKC_API.G_FALSE
	                             ,x_return_status	OUT NOCOPY      VARCHAR2
	                             ,x_msg_count		OUT NOCOPY      NUMBER
	                             ,x_msg_data		    OUT NOCOPY      VARCHAR2)
--start: 24-APR-2007  cklee -- Disbursement changes for R12B, bug fixed:           |
--                                 ,p_from_date        IN  DATE
--                                 ,p_to_date          IN  DATE)
--end: 24-APR-2007  cklee -- Disbursement changes for R12B, bug fixed:           |
   IS
     ------------------------------------------------------------
	-- Declare Process variables
	------------------------------------------------------------
   	l_api_version	CONSTANT NUMBER     := 1;
	l_api_name	CONSTANT VARCHAR2(30)   := 'CONSOLIDATION';
	l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	l_msg_index_out     NUMBER;
    i                   NUMBER;

    --Cursor for selecting the Consolidated invoice header attributes
--      CURSOR c_cnsld_hdr(p_date_from IN DATE,
--                         p_to_date   IN DATE) IS
      CURSOR c_cnsld_hdr IS
      SELECT *
      FROM OKL_CNSLD_AP_INVS_ALL
      WHERE trx_status_code = 'ENTERED';
--start: 24-APR-2007  cklee -- Disbursement changes for R12B, bug fixed:           |
--      AND  date_invoiced BETWEEN
--            p_from_date AND p_to_date;
--end: 24-APR-2007  cklee -- Disbursement changes for R12B, bug fixed:           |

     --Cursor for selecting the Consolidated Invoice lines
     CURSOR c_cnsld_lns(p_cnsld_inv_id IN NUMBER) IS
     SELECT TPL.ID,
            TPL.cnsld_line_number,
            TPL.inv_distr_line_code,
            TPL.org_id,
            TPL.ATTRIBUTE_CATEGORY,
            TPL.ATTRIBUTE1,
            TPL.ATTRIBUTE2,
            TPL.ATTRIBUTE3,
            TPL.ATTRIBUTE4,
            TPL.ATTRIBUTE5,
            TPL.ATTRIBUTE6,
            TPL.ATTRIBUTE7,
            TPL.ATTRIBUTE8,
            TPL.ATTRIBUTE9,
            TPL.ATTRIBUTE10,
            TPL.ATTRIBUTE11,
            TPL.ATTRIBUTE12,
            TPL.ATTRIBUTE13,
            TPL.ATTRIBUTE14,
            TPL.ATTRIBUTE15,
            DSTRS.AMOUNT,
            DSTRS.CODE_COMBINATION_ID,
            DSTRS.CR_DR_FLAG
    FROM OKL_TXL_AP_INV_LNS_B TPL,
         OKL_TRNS_ACC_DSTRS DSTRS
    WHERE TPL.CNSLD_AP_INV_ID = p_cnsld_inv_id
    AND   TPL.ID = DSTRS.SOURCE_ID
    AND   DSTRS.SOURCE_TABLE = 'OKL_TXL_AP_INV_LNS_B';


    -----------------------------------------------------------------
	-- Fetch Ap Interface Sequence Number
	-----------------------------------------------------------------
    CURSOR seq_csr IS
    SELECT ap_invoices_interface_s.nextval
    FROM dual;

    ------------------------------------------------------------
	-- Declare records: Payable Invoice Headers and Lines
	------------------------------------------------------------
    l_xpiv_rec           Okl_xpi_Pvt.xpiv_rec_type;

    -- Nulling record
    l_init_xpiv_rec      Okl_xpi_Pvt.xpiv_rec_type;

    lx_xpiv_rec          Okl_xpi_Pvt.xpiv_rec_type;
    l_xlpv_rec           okl_xlp_pvt.xlpv_rec_type;

    -- Nulling record
    l_init_xlpv_rec      okl_xlp_pvt.xlpv_rec_type;

    lx_xlpv_rec          okl_xlp_pvt.xlpv_rec_type;

/*      l_taiv_rec           okl_tai_pvt.taiv_rec_type;  */
/*      lx_taiv_rec          okl_tai_pvt.taiv_rec_type;  */
/*      -- Nulling record  */
/*      l_init_taiv_rec      okl_tai_pvt.taiv_rec_type;  */
/*    */
/*      l_tilv_rec           okl_til_pvt.tilv_rec_type;  */
/*      lx_tilv_rec          okl_til_pvt.tilv_rec_type;  */
/*      -- Nulling record  */
/*      l_init_tilv_rec      okl_til_pvt.tilv_rec_type;  */
--

    l_gen_seq           okl_trx_ap_invoices_v.invoice_number%TYPE;
    l_okl_application_id NUMBER(3) := 540;
    l_document_category VARCHAR2(100):= 'OKL Lease Pay Invoices';
    lX_dbseqnm          VARCHAR2(2000):= '';
    lX_dbseqid          NUMBER(38):= NULL;


    l_conc_status       VARCHAR2(1) := 'S';

    l_commit_cnt        NUMBER;
    l_MAX_commit_cnt    NUMBER := 500;


BEGIN

     x_return_status := OKL_API.G_RET_STS_SUCCESS;

     l_return_status := OKL_API.START_ACTIVITY(
	                               	p_api_name	    => l_api_name,
    	                            p_pkg_name	    => g_pkg_name,
		                            p_init_msg_list	=> p_init_msg_list,
		                            l_api_version	=> l_api_version,
		                            p_api_version	=> p_api_version,
	                                p_api_type	    => '_PVT',
		                            x_return_status	=> l_return_status);

      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	  	RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	  ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	  END IF;


--start: 24-APR-2007  cklee -- Disbursement changes for R12B, bug fixed:           |
--	  FOR r_cnsld_hdr IN c_cnsld_hdr(p_from_date, p_to_date) LOOP
	  FOR r_cnsld_hdr IN c_cnsld_hdr LOOP
--end: 24-APR-2007  cklee -- Disbursement changes for R12B, bug fixed:           |
	     l_xpiv_rec := l_init_xpiv_rec;
	     l_xpiv_rec.vendor_invoice_number := r_cnsld_hdr.vendor_invoice_number;
	     l_xpiv_rec.invoice_num        := r_cnsld_hdr.invoice_number;


       FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '============================================================');
       FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Processing Vendor Invoice Number: '||r_cnsld_hdr.vendor_invoice_number);
       FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '============================================================');

       FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
       FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '++++ Set of Books: '||r_cnsld_hdr.set_of_books_id||' Org Id: '||r_cnsld_hdr.org_id||' Invoice Number: '||r_cnsld_hdr.invoice_number );
       FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '++++ Vendor Site (ipvs_id): '||r_cnsld_hdr.ipvs_id||' Terms Id(ippt_id): '||r_cnsld_hdr.ippt_id||' Payment Method Code: '||r_cnsld_hdr.payment_method_code );
       FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '++++ Currency: '||r_cnsld_hdr.currency_code||' GL Date: '||r_cnsld_hdr.date_gl );
       FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '++++ try_id: '||r_cnsld_hdr.try_id);
       FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '++++ ccid: '||r_cnsld_hdr.accts_pay_cc_id);
       FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '++++ invoice_amount: '||r_cnsld_hdr.amount||' Vendor Id: '||r_cnsld_hdr.vendor_id);
       FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');



	    OPEN  seq_csr;
		FETCH seq_csr INTO l_xpiv_rec.invoice_id;
		CLOSE seq_csr;

        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' Invoice id: '||l_xpiv_rec.invoice_id);

	    l_xpiv_rec.invoice_type             := r_cnsld_hdr.invoice_type;
	    l_xpiv_rec.invoice_date             := r_cnsld_hdr.date_invoiced;
	    l_xpiv_rec.vendor_id                := r_cnsld_hdr.vendor_id;
	    l_xpiv_rec.vendor_site_id           := r_cnsld_hdr.ipvs_id;
	    l_xpiv_rec.invoice_amount           := r_cnsld_hdr.amount;
	    l_xpiv_rec.invoice_currency_code    := r_cnsld_hdr.currency_code;
	    l_xpiv_rec.terms_id                 := r_cnsld_hdr.ippt_id;
	    l_xpiv_rec.workflow_flag            := NULL;
	    l_xpiv_rec.pay_group_lookup_code    := r_cnsld_hdr.pay_group_lookup_code;
	    l_xpiv_rec.doc_category_code        := NULL;
	    l_xpiv_rec.payment_method           := r_cnsld_hdr.payment_method_code;
	    l_xpiv_rec.gl_date                  := r_cnsld_hdr.date_gl;
	    l_xpiv_rec.accts_pay_cc_id          := r_cnsld_hdr.accts_pay_cc_id;
--start:|  03-MAY-2007  cklee -- Disbursement changes for R12B, bug fixed:           |
--	    l_xpiv_rec.nettable_yn              := NULL;
	    l_xpiv_rec.nettable_yn              := 'N';
--end:|  03-MAY-2007  cklee -- Disbursement changes for R12B, bug fixed:           |
	    l_xpiv_rec.pay_alone_flag           := NULL;
	    l_xpiv_rec.wait_vendor_invoice_yn   := NULL;
	    l_xpiv_rec.payables_invoice_id      := NULL;
	    l_xpiv_rec.org_id                   := r_cnsld_hdr.org_id;
	    l_xpiv_rec.attribute_category       := r_cnsld_hdr.attribute_category;
	    l_xpiv_rec.attribute1               := r_cnsld_hdr.attribute1;
	    l_xpiv_rec.attribute2               := r_cnsld_hdr.attribute2;
	    l_xpiv_rec.attribute3               := r_cnsld_hdr.attribute3;
	    l_xpiv_rec.attribute4               := r_cnsld_hdr.attribute4;
	    l_xpiv_rec.attribute5               := r_cnsld_hdr.attribute5;
	    l_xpiv_rec.attribute6               := r_cnsld_hdr.attribute6;
	    l_xpiv_rec.attribute7               := r_cnsld_hdr.attribute7;
	    l_xpiv_rec.attribute8               := r_cnsld_hdr.attribute8;
	    l_xpiv_rec.attribute9               := r_cnsld_hdr.attribute9;
	    l_xpiv_rec.attribute10              := r_cnsld_hdr.attribute10;
        l_xpiv_rec.attribute11              := r_cnsld_hdr.attribute11;
        l_xpiv_rec.attribute12              := r_cnsld_hdr.attribute12;
        l_xpiv_rec.attribute13              := r_cnsld_hdr.attribute13;
        l_xpiv_rec.attribute14              := r_cnsld_hdr.attribute14;
        l_xpiv_rec.attribute15              := r_cnsld_hdr.attribute15;
        l_xpiv_rec.trx_status_code          := 'ENTERED';
        l_xpiv_rec.currency_conversion_rate := r_cnsld_hdr.currency_conversion_rate;
        l_xpiv_rec.currency_conversion_type := r_cnsld_hdr.currency_conversion_type;
        l_xpiv_rec.currency_conversion_date := r_cnsld_hdr.currency_conversion_date;
        l_xpiv_rec.legal_entity_id          := r_cnsld_hdr.legal_entity_id;
        l_xpiv_rec.cnsld_ap_inv_id          := r_cnsld_hdr.cnsld_ap_inv_id;
        l_xpiv_rec.REQUEST_ID               := Fnd_Global.CONC_REQUEST_ID ; -- 11-Dec-2007  cklee -- Fixed bug: 6682348 -- stamped request_id when insert


        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' Creating External AP Invoice Header..');

  -- Start of wraper code generated automatically by Debug code generator for OKL_EXT_PAY_INVS_PUB.insert_ext_pay_invs
        IF(L_DEBUG_ENABLED='Y') THEN
          L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
          IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
        END IF;
        IF(IS_DEBUG_PROCEDURE_ON) THEN
          BEGIN
            OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRPICB.pls call OKL_EXT_PAY_INVS_PUB.insert_ext_pay_invs ');
          END;
        END IF;


        OKL_EXT_PAY_INVS_PUB.insert_ext_pay_invs(
        p_api_version            =>   p_api_version
        ,p_init_msg_list         =>   p_init_msg_list
        ,x_return_status         =>   x_return_status
        ,x_msg_count             =>   x_msg_count
        ,x_msg_data              =>   x_msg_data
        ,p_xpiv_rec              =>   l_xpiv_rec
        ,x_xpiv_rec              =>   lx_xpiv_rec);

        IF(IS_DEBUG_PROCEDURE_ON) THEN
          BEGIN
            OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRPICB.pls call OKL_EXT_PAY_INVS_PUB.insert_ext_pay_invs '|| x_return_status);
          END;
        END IF;
        -- End of wraper code generated automatically by Debug code generator for OKL_EXT_PAY_INVS_PUB.insert_ext_pay_invs
		IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            l_conc_status  := 'E';
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ERROR: Creating External AP Invoice Header.');
		ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            l_conc_status  := 'E';
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ERROR: Creating External AP Invoice Header.');
		ELSIF (x_return_status ='S') THEN
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' Created External AP Invoice Header with Id: '||lx_xpiv_rec.id);
		END IF;

	   FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' Creating External AP Invoice Lines..');
     --Processing the Consolidated lines for transfer to external lines table
		FOR r_cnsld_lns IN c_cnsld_lns(r_cnsld_hdr.cnsld_ap_inv_id) LOOP
		  l_commit_cnt := l_commit_cnt + 1;
		  IF nvl(r_cnsld_lns.CR_DR_FLAG, 'D') = 'D' THEN
		    l_xlpv_rec.xpi_id_details       := lx_xpiv_rec.id;
		    l_xlpv_rec.pid_id               := NULL;
		    l_xlpv_rec.ibi_id               := NULL;
		    l_xlpv_rec.tpl_id               := r_cnsld_lns.id;
		    l_xlpv_rec.tap_id               := NULL;
		    l_xlpv_rec.invoice_line_id      := NULL;
		    l_xlpv_rec.line_number          := r_cnsld_lns.cnsld_line_number;

		    --validate line type and set it to ITEM if invoice distr line type is any of the below
		    IF r_cnsld_lns.inv_distr_line_code in ('ITEM','INVESTOR','MANUAL','AUTO_DISBURSEMENT',NULL) THEN
		      l_xlpv_rec.line_type := 'ITEM';
            ELSE
              l_xlpv_rec.line_type := r_cnsld_lns.inv_distr_line_code;
            END IF;

            l_xlpv_rec.amount                   := r_cnsld_lns.amount;
            l_xlpv_rec.accounting_date          := r_cnsld_hdr.date_gl;

            l_xlpv_rec.dist_code_combination_id := r_cnsld_lns.code_combination_id;
--start:|  01-MAY-2007  cklee -- Disbursement changes for R12B, bug fixed:           |
/*
            IF G_ACC_SYS_OPTION = 'ATS' THEN -- Account Template Set
              l_xlpv_rec.dist_code_combination_id := r_cnsld_lns.code_combination_id;
  			ELSE -- Account Method Builder(AMB),
              l_xlpv_rec.dist_code_combination_id := -1;
            END IF;
*/
--            l_xlpv_rec.dist_code_combination_id := r_cnsld_lns.code_combination_id;
--end:|  01-MAY-2007  cklee -- Disbursement changes for R12B, bug fixed:           |
            l_xlpv_rec.tax_code                 := NULL;
            l_xlpv_rec.org_id                   := r_cnsld_lns.org_id;
            l_xlpv_rec.attribute_category       := r_cnsld_lns.attribute_category;
            l_xlpv_rec.attribute1               := r_cnsld_lns.attribute1;
            l_xlpv_rec.attribute2               := r_cnsld_lns.attribute2;
            l_xlpv_rec.attribute3               := r_cnsld_lns.attribute3;
            l_xlpv_rec.attribute4               := r_cnsld_lns.attribute4;
            l_xlpv_rec.attribute5               := r_cnsld_lns.attribute5;
            l_xlpv_rec.attribute6               := r_cnsld_lns.attribute6;
            l_xlpv_rec.attribute7               := r_cnsld_lns.attribute7;
            l_xlpv_rec.attribute8               := r_cnsld_lns.attribute8;
            l_xlpv_rec.attribute9               := r_cnsld_lns.attribute9;
            l_xlpv_rec.attribute10              := r_cnsld_lns.attribute10;
            l_xlpv_rec.attribute11              := r_cnsld_lns.attribute11;
            l_xlpv_rec.attribute12              := r_cnsld_lns.attribute12;
            l_xlpv_rec.attribute13              := r_cnsld_lns.attribute13;
            l_xlpv_rec.attribute14              := r_cnsld_lns.attribute14;
            l_xlpv_rec.attribute15              := r_cnsld_lns.attribute15;
            l_xlpv_rec.REQUEST_ID               := Fnd_Global.CONC_REQUEST_ID ; -- 11-Dec-2007  cklee -- Fixed bug: 6682348 -- stamped request_id when insert


-- Start of wraper code generated automatically by Debug code generator for okl_xtl_pay_invs_pub.insert_xtl_pay_invs
           IF(IS_DEBUG_PROCEDURE_ON) THEN
             BEGIN
               OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRPICB.pls call okl_xtl_pay_invs_pub.insert_xtl_pay_invs ');
             END;
           END IF;

           OKL_XTL_PAY_INVS_PUB.insert_xtl_pay_invs(
             p_api_version           =>   p_api_version
            ,p_init_msg_list        =>   p_init_msg_list
            ,x_return_status        =>   x_return_status
            ,x_msg_count            =>   x_msg_count
            ,x_msg_data             =>   x_msg_data
            ,p_xlpv_rec             =>   l_xlpv_rec
            ,x_xlpv_rec             =>   lx_xlpv_rec);

           IF(IS_DEBUG_PROCEDURE_ON) THEN
             BEGIN
               OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRPICB.pls call okl_xtl_pay_invs_pub.insert_xtl_pay_invs '||x_return_status);
             END;
           END IF;
-- End of wraper code generated automatically by Debug code generator for okl_xtl_pay_invs_pub.insert_xtl_pay_invs

		   IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
              l_conc_status  := 'E';
              FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ERROR: Creating External AP Invoice Line.');
		   ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
              l_conc_status  := 'E';
              FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ERROR: Creating External AP Invoice Line.');
	  	   ELSIF (x_return_status ='S') THEN
              FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' Created External AP Invoice Line with Id: '||lx_xlpv_rec.id);
		   END IF;

		   IF l_commit_cnt > l_MAX_commit_cnt THEN
             COMMIT;
             l_commit_cnt := 0;
           END IF;
        END IF; --> Debit check
      END LOOP; -- > Lines

      IF ( NVL(l_conc_status, 'E') = okl_api.g_ret_sts_success  ) THEN
	   -----------------------------------------------------------------
	   -- Update internal AP table for Success
	   -----------------------------------------------------------------
         FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Successfully Prepared Invoice Number : ' || r_cnsld_hdr.invoice_number);

         UPDATE OKL_CNSLD_AP_INVS
         SET TRX_STATUS_CODE = 'PROCESSED'
         WHERE CNSLD_AP_INV_ID = r_cnsld_hdr.cnsld_ap_inv_id;
      ELSE
	    -----------------------------------------------------------------
		-- Update internal AP table for Error
		-----------------------------------------------------------------
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'*=>ERROR: Processing Invoice Number : ' || r_cnsld_hdr.invoice_number);
          IF x_msg_count >= 1 THEN
             FOR i in 1..x_msg_count LOOP
              fnd_msg_pub.get (p_msg_index => i,
                               p_encoded => 'F',
                               p_data => x_msg_data,
                               p_msg_index_out => l_msg_index_out);

    		   FND_FILE.PUT_LINE (FND_FILE.OUTPUT,to_char(i) || ': ' || x_msg_data);

             END LOOP;
           END IF;
--start: cklee 4/26/07
         UPDATE OKL_CNSLD_AP_INVS
         SET TRX_STATUS_CODE = 'ERROR'
         WHERE CNSLD_AP_INV_ID = r_cnsld_hdr.cnsld_ap_inv_id;

         UPDATE OKL_EXT_PAY_INVS_ALL_B
         SET TRX_STATUS_CODE = 'ERROR'
         WHERE CNSLD_AP_INV_ID = r_cnsld_hdr.cnsld_ap_inv_id;
--end: cklee 4/26/07

      END IF; --> Status Check
    END LOOP; --> Header

    COMMIT;

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '============================================================');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '  ******* End Processing Records ******* ');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '============================================================');

	------------------------------------------------------------
	-- End processing
	------------------------------------------------------------

	Okl_Api.END_ACTIVITY (
		x_msg_count	=> x_msg_count,
		x_msg_data	=> x_msg_data);

EXCEPTION
      	------------------------------------------------------------
	-- Exception handling
	------------------------------------------------------------
	WHEN OKL_API.G_EXCEPTION_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '*=> ERROR: '||SQLERRM);
		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OKL_API.G_RET_STS_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '*=> ERROR: '||SQLERRM);
		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OKL_API.G_RET_STS_UNEXP_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN OTHERS THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '*=> ERROR: '||SQLERRM);
		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OTHERS',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');
END transfer_to_external;


PROCEDURE consolidation_11i(p_api_version	IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2	DEFAULT OKC_API.G_FALSE
	,x_return_status	OUT NOCOPY      VARCHAR2
	,x_msg_count		OUT NOCOPY      NUMBER
	,x_msg_data		    OUT NOCOPY      VARCHAR2
    ,p_from_date        IN  DATE
    ,p_to_date          IN  DATE)
IS
	------------------------------------------------------------
	-- Declare variables required by APIs
	------------------------------------------------------------
   	l_api_version	CONSTANT NUMBER     := 1;
	l_api_name	CONSTANT VARCHAR2(30)   := 'CONSOLIDATION';
	l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	------------------------------------------------------------
	-- Declare Process variables
	------------------------------------------------------------
    l_msg_index_out     NUMBER;
    i                   NUMBER;
	-----------------------------------------------------------------
	-- Extract all Invoices due for submission
	-----------------------------------------------------------------

    CURSOR c_invoice IS
        SELECT
             tap.id  tap_id
            ,NVL(tap.set_of_books_id, OKL_ACCOUNTING_UTIL.get_set_of_books_id) sob_id
            ,tap.org_id
            ,tap.invoice_category_code
            ,tap.invoice_number
            --,tap.vendor_invoice_number
            ,nvl(tap.vendor_invoice_number, tap.invoice_number) vendor_invoice_number
            ,tap.object_version_number
            ,tap.code_combination_id tap_ccid
            ,tap.date_invoiced date_invoiced
            ,tap.pay_group_lookup_code
            ,tap.ipvs_id
            ,tap.ippt_id
            ,tap.payment_method_code
            ,tap.currency_code
            ,tap.currency_conversion_type
            ,tap.currency_conversion_rate
            ,tap.currency_conversion_date
            ,tap.workflow_yn
            ,tap.date_gl gl_date
            ,tap.nettable_yn
            ,tap.khr_id
            ,tap.wait_vendor_invoice_yn
            ,tap.try_id
            ,tpl.id tpl_id
            ,tpl.code_combination_id tpl_ccid
            ,tpl.sty_id
            ,acc_db.code_combination_id db_ccid
            ,acc_cr.code_combination_id cr_ccid
            ,tpl.amount invoice_amount
            ,acc_db.amount line_amount
            ,povs.vendor_id
        FROM
            okl_trns_acc_dstrs  acc_db
            ,okl_trns_acc_dstrs  acc_cr
            ,po_vendor_sites_all povs
            ,okl_txl_ap_inv_lns_b tpl
            ,okl_trx_ap_invoices_b tap
        WHERE
            NVL(tap.trx_status_code, 'ENTERED') in ( 'ENTERED', 'APPROVED' ) AND
            trunc(tap.date_invoiced) BETWEEN
            NVL(p_from_date,SYSDATE-10000) AND NVL(p_to_date, SYSDATE+10000)
            AND  acc_db.cr_dr_flag (+) = 'D'
            AND acc_cr.cr_dr_flag (+) = 'C'
            AND acc_db.source_table (+)= 'OKL_TXL_AP_INV_LNS_B'
            AND acc_cr.source_table (+)= 'OKL_TXL_AP_INV_LNS_B'
            AND tpl.id = acc_db.source_id (+)
            AND tpl.id = acc_cr.source_id (+)
            AND povs.vendor_site_id = tap.ipvs_id
            AND tap.id = tpl.tap_id
            AND tap.org_id = NVL(TO_NUMBER(DECODE( SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)
			AND tap.FUNDING_TYPE_CODE IS NULL
      ORDER BY tap.id;


    CURSOR c_funding_csr IS
    SELECT * FROM (
    SELECT
--            NULL tpl_id -- cklee comment out
            tap.id tap_id
            ,NVL(tap.set_of_books_id,
            OKL_ACCOUNTING_UTIL.get_set_of_books_id) sob_id
            ,tap.org_id
            ,tap.invoice_category_code
            ,tap.invoice_number
            --,tap.vendor_invoice_number
            ,nvl(tap.vendor_invoice_number, tap.invoice_number) vendor_invoice_number
            ,tap.object_version_number
            ,tap.code_combination_id tap_ccid
            ,tap.date_invoiced date_invoiced
            ,tap.pay_group_lookup_code
            ,tap.ipvs_id
            ,tap.ippt_id
            ,tap.payment_method_code
            ,tap.currency_code
            ,tap.currency_conversion_type
            ,tap.currency_conversion_rate
            ,tap.currency_conversion_date
            ,tap.workflow_yn
            ,nvl(tap.date_gl,tap.date_invoiced)  gl_date
            ,tap.nettable_yn
            ,tap.khr_id
            ,tap.wait_vendor_invoice_yn
            ,tap.try_id
            ,acc_db.code_combination_id db_ccid
            ,acc_cr.code_combination_id cr_ccid
            ,tap.amount invoice_amount
            ,acc_db.amount line_amount
            ,povs.vendor_id
--            ,tap.FUNDING_TYPE_CODE -cklee
        FROM
            okl_trns_acc_dstrs  acc_db
            ,okl_trns_acc_dstrs  acc_cr
            ,po_vendor_sites_all povs
            ,okl_trx_ap_invoices_b tap
        WHERE
              NVL(tap.trx_status_code, 'ENTERED') in ( 'APPROVED' ) AND
              trunc(tap.date_invoiced) BETWEEN
              NVL(p_from_date,SYSDATE-10000) AND NVL(p_to_date,SYSDATE+10000)
             AND   acc_db.cr_dr_flag (+) = 'D'
            AND acc_cr.cr_dr_flag (+) = 'C'
            AND acc_db.source_table (+)= 'OKL_TRX_AP_INVOICES_B'
            AND acc_cr.source_table (+)= 'OKL_TRX_AP_INVOICES_B'
            AND tap.id = acc_db.source_id (+)
            AND tap.id = acc_cr.source_id (+)
            AND povs.vendor_site_id = tap.ipvs_id
            AND tap.org_id = NVL(TO_NUMBER(DECODE( SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)
            AND tap.FUNDING_TYPE_CODE IS NOT NULL
            --AND  tap.FUNDING_TYPE_CODE <> 'ASSET_SUBSIDY'
            AND  tap.FUNDING_TYPE_CODE not in ('ASSET_SUBSIDY', 'MANUAL_DISB')
        UNION
            SELECT
--            tpl.id tpl_id -- cklee comment out
            tap.id tap_id
            ,NVL(tap.set_of_books_id,OKL_ACCOUNTING_UTIL.get_set_of_books_id) sob_id
            ,tap.org_id
            ,tap.invoice_category_code
            ,tap.invoice_number
            --,tap.vendor_invoice_number
            ,nvl(tap.vendor_invoice_number, tap.invoice_number) vendor_invoice_number
            ,tap.object_version_number
            ,tap.code_combination_id tap_ccid
            ,tap.date_invoiced date_invoiced
            ,tap.pay_group_lookup_code
            ,tap.ipvs_id
            ,tap.ippt_id
            ,tap.payment_method_code
            ,tap.currency_code
            ,tap.currency_conversion_type
            ,tap.currency_conversion_rate
            ,tap.currency_conversion_date
            ,tap.workflow_yn
            ,nvl(tap.date_gl,tap.date_invoiced)  gl_date
            ,tap.nettable_yn
            ,tap.khr_id
            ,tap.wait_vendor_invoice_yn
            ,tap.try_id
            ,acc_db.code_combination_id db_ccid
            ,acc_cr.code_combination_id cr_ccid
            ,tap.amount invoice_amount
            ,acc_db.amount line_amount
            ,povs.vendor_id
--            ,tap.FUNDING_TYPE_CODE -- cklee
        FROM
            okl_trns_acc_dstrs  acc_db
            ,okl_trns_acc_dstrs  acc_cr
            ,po_vendor_sites_all povs
            ,okl_trx_ap_invoices_b tap
            ,okl_txl_ap_inv_lns_b tpl
        WHERE
             NVL(tap.trx_status_code, 'ENTERED') in ( 'APPROVED' )
             AND trunc(tap.date_invoiced) BETWEEN
              NVL(p_from_date,SYSDATE-10000) AND NVL(p_to_date, SYSDATE+10000)
              AND  acc_db.cr_dr_flag (+) = 'D'
            AND acc_cr.cr_dr_flag (+) = 'C'
            AND acc_db.source_table (+)= 'OKL_TXL_AP_INV_LNS_B'
            AND acc_cr.source_table (+)= 'OKL_TXL_AP_INV_LNS_B'
            AND tpl.id = acc_db.source_id (+)
            AND tpl.id = acc_cr.source_id (+)
            AND povs.vendor_site_id = tap.ipvs_id
            AND tap.id = tpl.tap_id
            AND tap.org_id = NVL(TO_NUMBER(DECODE( SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)
            --AND  tap.FUNDING_TYPE_CODE = 'ASSET_SUBSIDY' ;
            AND  tap.FUNDING_TYPE_CODE in ('ASSET_SUBSIDY', 'MANUAL_DISB')
            ) ORDER BY tap_id;



	-----------------------------------------------------------------
	-- Fetch Ap Interface Sequence Number
	-----------------------------------------------------------------
	CURSOR seq_csr IS
        SELECT ap_invoices_interface_s.nextval
        FROM dual;

	p_bpd_acc_rec					Okl_Acc_Call_Pub.bpd_acc_rec_type;

	------------------------------------------------------------
	-- Declare records: Payable Invoice Headers and Lines
	------------------------------------------------------------
    l_xpiv_rec           Okl_xpi_Pvt.xpiv_rec_type;

    -- Nulling record
    l_init_xpiv_rec      Okl_xpi_Pvt.xpiv_rec_type;

    lx_xpiv_rec          Okl_xpi_Pvt.xpiv_rec_type;
    l_xlpv_rec           okl_xlp_pvt.xlpv_rec_type;

    -- Nulling record
    l_init_xlpv_rec      okl_xlp_pvt.xlpv_rec_type;

    lx_xlpv_rec          okl_xlp_pvt.xlpv_rec_type;

    l_taiv_rec           okl_tai_pvt.taiv_rec_type;
    lx_taiv_rec          okl_tai_pvt.taiv_rec_type;
    -- Nulling record
    l_init_taiv_rec      okl_tai_pvt.taiv_rec_type;

    l_tilv_rec           okl_til_pvt.tilv_rec_type;
    lx_tilv_rec          okl_til_pvt.tilv_rec_type;
    -- Nulling record
    l_init_tilv_rec      okl_til_pvt.tilv_rec_type;

     -- Multi Currency Compliance
    l_currency_code            okl_ext_sell_invs_b.currency_code%type;
    l_currency_conversion_type okl_ext_sell_invs_b.currency_conversion_type%type;
    l_currency_conversion_rate okl_ext_sell_invs_b.currency_conversion_rate%type;
    l_currency_conversion_date okl_ext_sell_invs_b.currency_conversion_date%type;

    l_previous_tap_id    okl_trx_ap_invoices_b.id%TYPE := NULL;
    l_previous_xpi_id    okl_ext_sell_invs_b.id%TYPE := NULL;

    CURSOR l_curr_conv_csr( cp_khr_id  NUMBER ) IS
        SELECT  currency_code
               ,currency_conversion_type
               ,currency_conversion_rate
               ,currency_conversion_date
        FROM    okl_k_headers_full_v
        WHERE   id = cp_khr_id;

    -----------------------------------------------------------
    -- Variables for Bug 2949640, Sunil Mathew, 12-May-2003
    -----------------------------------------------------------
    l_gen_seq           okl_trx_ap_invoices_v.invoice_number%TYPE;
    l_okl_application_id NUMBER(3) := 540;
    l_document_category VARCHAR2(100):= 'OKL Lease Pay Invoices';
    lX_dbseqnm          VARCHAR2(2000):= '';
    lX_dbseqid          NUMBER(38):= NULL;


    l_conc_status       VARCHAR2(1);

    l_commit_cnt        NUMBER;
    l_MAX_commit_cnt    NUMBER := 500;

BEGIN
	------------------------------------------------------------
	-- Start processing
	------------------------------------------------------------

	x_return_status := OKL_API.G_RET_STS_SUCCESS;

	l_return_status := OKL_API.START_ACTIVITY(
		p_api_name	    => l_api_name,
    	p_pkg_name	    => g_pkg_name,
		p_init_msg_list	=> p_init_msg_list,
		l_api_version	=> l_api_version,
		p_api_version	=> p_api_version,
		p_api_type	    => '_PVT',
		x_return_status	=> l_return_status);

	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	-----------------------------------------------------------------
	-- Open Invoice cursor in block
	-----------------------------------------------------------------

    l_commit_cnt := 0;

FOR r_invoice IN c_invoice LOOP
  IF (NVL(l_previous_tap_id, -99) <> r_invoice.tap_id) THEN
       l_commit_cnt := l_commit_cnt + 1;

       l_conc_status := 'S';

       -- Null records
       l_xpiv_rec := l_init_xpiv_rec;
       l_xlpv_rec := l_init_xlpv_rec;
       l_taiv_rec := l_init_taiv_rec;
       l_tilv_rec := l_init_tilv_rec;

       ------------------------------------------------------------
       -- Generate sequence while consolidating, Bug 2949640
       -- Sunil Mathew, 12-May-2003
       ------------------------------------------------------------
       l_gen_seq := NULL;
       IF r_invoice.invoice_number IS NULL THEN
         BEGIN
          l_gen_seq := fnd_seqnum.get_next_sequence
                (appid      =>  l_okl_application_id,
                cat_code    =>  l_document_category,
                sobid       =>  r_invoice.sob_id,
                met_code    =>  'A',
                trx_date    =>  SYSDATE,
                dbseqnm     =>  lx_dbseqnm,
                dbseqid     =>  lx_dbseqid);
         EXCEPTION
            WHEN OTHERS THEN
                 l_gen_seq := -1;
         END;

       END IF;

       r_invoice.vendor_invoice_number := NVL(r_invoice.vendor_invoice_number,l_gen_seq);
       r_invoice.invoice_number        := NVL(r_invoice.invoice_number,l_gen_seq);

       FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '============================================================');
       FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Processing Vendor Invoice Number: '||r_invoice.vendor_invoice_number);
       FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '============================================================');

       FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
       FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '++++ Set of Books: '||r_invoice.sob_id||' Org Id: '||r_invoice.org_id||' Invoice Number: '||r_invoice.invoice_number );
       FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '++++ Vendor Site (ipvs_id): '||r_invoice.ipvs_id||' Terms Id(ippt_id): '||r_invoice.ippt_id||' Payment Method Code: '||r_invoice.payment_method_code );
       FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '++++ Currency: '||r_invoice.currency_code||' GL Date: '||r_invoice.gl_date||' Nettable: '||r_invoice.nettable_yn );
       FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '++++ khr_id: '||r_invoice.khr_id||' try_id: '||r_invoice.try_id);
       FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '++++ db_ccid: '||r_invoice.db_ccid||' cr_ccid: '||r_invoice.cr_ccid);
       FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '++++ invoice_amount: '||r_invoice.invoice_amount||' Vendor Id: '||r_invoice.vendor_id);
       FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
  END IF;

--    SAVEPOINT C_INVOICE_POINT;

  IF NVL(r_invoice.nettable_yn, 'N') = 'N' OR r_invoice.invoice_amount > 0 THEN
    IF (NVL(l_previous_tap_id, -99) <> r_invoice.tap_id) THEN
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Creating Payables Invoice');

	   -----------------------------------------------------------------
	   -- Populate and insert external AP invoice header
	   -----------------------------------------------------------------
		l_xpiv_rec.invoice_id := NULL;

		OPEN  seq_csr;
		FETCH seq_csr INTO l_xpiv_rec.invoice_id;
		CLOSE seq_csr;

        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' Invoice id: '||l_xpiv_rec.invoice_id);

        l_xpiv_rec.doc_category_code    := r_invoice.invoice_category_code;
        l_xpiv_rec.invoice_num          := r_invoice.invoice_number;
        l_xpiv_rec.vendor_invoice_number:= r_invoice.vendor_invoice_number;
        l_xpiv_rec.gl_date              := r_invoice.gl_date;
        l_xpiv_rec.invoice_amount       := r_invoice.invoice_amount;
        l_xpiv_rec.pay_group_lookup_code:= r_invoice.pay_group_lookup_code;
        l_xpiv_rec.nettable_yn			:= r_invoice.nettable_yn;

        l_xpiv_rec.accts_pay_cc_id := NVL(r_invoice.tap_ccid,r_invoice.cr_ccid);
        l_xpiv_rec.invoice_currency_code:= r_invoice.currency_code;
        l_xpiv_rec.invoice_date         := r_invoice.date_invoiced;
        l_xpiv_rec.object_version_number:= r_invoice.object_version_number;
        l_xpiv_rec.org_id               := r_invoice.org_id;
        l_xpiv_rec.payment_method       := r_invoice.payment_method_code;
        l_xpiv_rec.terms_id             := r_invoice.ippt_id;
        l_xpiv_rec.trx_status_code      := 'ENTERED';
        l_xpiv_rec.vendor_site_id       := r_invoice.ipvs_id;
        l_xpiv_rec.wait_vendor_invoice_yn := r_invoice.wait_vendor_invoice_yn;
        l_xpiv_rec.workflow_flag        := r_invoice.workflow_yn;

        l_xpiv_rec.CURRENCY_CONVERSION_TYPE := r_invoice.CURRENCY_CONVERSION_TYPE;
        l_xpiv_rec.CURRENCY_CONVERSION_RATE := r_invoice.CURRENCY_CONVERSION_RATE;
        l_xpiv_rec.CURRENCY_CONVERSION_DATE := r_invoice.CURRENCY_CONVERSION_DATE;


        -- Multi Currency Parameters
        IF ( (l_xpiv_rec.CURRENCY_CONVERSION_TYPE IS NULL) OR
             (l_xpiv_rec.CURRENCY_CONVERSION_RATE IS NULL) OR
             (l_xpiv_rec.CURRENCY_CONVERSION_DATE IS NULL) OR
             (l_xpiv_rec.INVOICE_CURRENCY_CODE IS NULL) ) THEN

            l_currency_code            := NULL;
            l_currency_conversion_type := NULL;
            l_currency_conversion_rate := NULL;
            l_currency_conversion_date := NULL;

            OPEN  l_curr_conv_csr ( r_invoice.khr_id );
            FETCH l_curr_conv_csr INTO  l_currency_code,
                                        l_currency_conversion_type,
                                        l_currency_conversion_rate,
                                        l_currency_conversion_date;
            CLOSE l_curr_conv_csr;

            l_xpiv_rec.INVOICE_CURRENCY_CODE    := l_currency_code;
	        l_xpiv_rec.CURRENCY_CONVERSION_TYPE := l_currency_conversion_type;
	        l_xpiv_rec.CURRENCY_CONVERSION_RATE := l_currency_conversion_rate;
	        l_xpiv_rec.CURRENCY_CONVERSION_DATE := l_currency_conversion_date;

            -- If Currency Code is null then default functional currency
            IF ( l_xpiv_rec.INVOICE_CURRENCY_CODE IS NULL ) THEN
                l_xpiv_rec.INVOICE_CURRENCY_CODE
                     := okl_accounting_util.get_func_curr_code;
            END IF;

            -- If the type were not captured in authoring
            IF 	l_xpiv_rec.currency_conversion_type IS NULL THEN
                l_xpiv_rec.currency_conversion_type := 'User';
		        l_xpiv_rec.currency_conversion_rate := 1;
                l_xpiv_rec.currency_conversion_date := SYSDATE;
            END IF;

            -- For date
            IF l_xpiv_rec.currency_conversion_date IS NULL THEN
	           l_xpiv_rec.currency_conversion_date := SYSDATE;
            END IF;

            -- For rate -- Work out the rate in a Spot or Corporate
            IF (l_xpiv_rec.currency_conversion_type = 'User') THEN
                IF l_xpiv_rec.currency_conversion_rate IS NULL THEN
                    l_xpiv_rec.currency_conversion_rate := 1;
                END IF;
            END IF;
        END IF;

        IF (l_xpiv_rec.currency_conversion_type = 'Spot'
                OR l_xpiv_rec.currency_conversion_type = 'Corporate') THEN

                l_xpiv_rec.currency_conversion_rate := NULL;
                /*
                    := okl_accounting_util.get_curr_con_rate
                   (p_from_curr_code => l_xpiv_rec.INVOICE_CURRENCY_CODE,
	                p_to_curr_code => okl_accounting_util.get_func_curr_code,
	                p_con_date => l_xpiv_rec.currency_conversion_date,
	                p_con_type => l_xpiv_rec.currency_conversion_type);
                 */
        END IF;

        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' Creating External AP Invoice Header..');

-- Start of wraper code generated automatically by Debug code generator for OKL_EXT_PAY_INVS_PUB.insert_ext_pay_invs
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRPICB.pls call OKL_EXT_PAY_INVS_PUB.insert_ext_pay_invs ');
    END;
  END IF;


        OKL_EXT_PAY_INVS_PUB.insert_ext_pay_invs(
        p_api_version            =>   p_api_version
        ,p_init_msg_list         =>   p_init_msg_list
        ,x_return_status         =>   x_return_status
        ,x_msg_count             =>   x_msg_count
        ,x_msg_data              =>   x_msg_data
        ,p_xpiv_rec              =>   l_xpiv_rec
        ,x_xpiv_rec              =>   lx_xpiv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRPICB.pls call OKL_EXT_PAY_INVS_PUB.insert_ext_pay_invs ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_EXT_PAY_INVS_PUB.insert_ext_pay_invs
		IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            l_conc_status  := 'E';
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ERROR: Creating External AP Invoice Header.');
		ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            l_conc_status  := 'E';
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ERROR: Creating External AP Invoice Header.');
		ELSIF (x_return_status ='S') THEN
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' Created External AP Invoice Header with Id: '||lx_xpiv_rec.id);
		END IF;

    l_previous_tap_id := r_invoice.tap_id;
    l_previous_xpi_id := lx_xpiv_rec.id;
  END IF;
	-----------------------------------------------------------------
	-- Populate and Insert external AP invoice Lines
	-----------------------------------------------------------------
        --l_xlpv_rec.xpi_id_details       := lx_xpiv_rec.id;
        l_xlpv_rec.xpi_id_details       := l_previous_xpi_id;
        l_xlpv_rec.amount               := r_invoice.line_amount;
        l_xlpv_rec.org_id               := r_invoice.org_id;
        l_xlpv_rec.object_version_number:= r_invoice.object_version_number;
        l_xlpv_rec.dist_code_combination_id := NVL(r_invoice.tpl_ccid,r_invoice.db_ccid);
        l_xlpv_rec.tpl_id 		:= r_invoice.tpl_id;


        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' Creating External AP Invoice Lines..');
-- Start of wraper code generated automatically by Debug code generator for okl_xtl_pay_invs_pub.insert_xtl_pay_invs
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRPICB.pls call okl_xtl_pay_invs_pub.insert_xtl_pay_invs ');
    END;
  END IF;
        okl_xtl_pay_invs_pub.insert_xtl_pay_invs(
            p_api_version           =>   p_api_version
            ,p_init_msg_list        =>   p_init_msg_list
            ,x_return_status        =>   x_return_status
            ,x_msg_count            =>   x_msg_count
            ,x_msg_data             =>   x_msg_data
            ,p_xlpv_rec             =>   l_xlpv_rec
            ,x_xlpv_rec             =>   lx_xlpv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRPICB.pls call okl_xtl_pay_invs_pub.insert_xtl_pay_invs ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_xtl_pay_invs_pub.insert_xtl_pay_invs

		IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            l_conc_status  := 'E';
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ERROR: Creating External AP Invoice Line.');
		ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            l_conc_status  := 'E';
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ERROR: Creating External AP Invoice Line.');
		ELSIF (x_return_status ='S') THEN
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' Created External AP Invoice Line with Id: '||lx_xlpv_rec.id);
		END IF;

    ELSE
	    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Creating Receviables Invoice');

		-----------------------------------------------------------------
		-- Populate external AR invoice header and line record
		-----------------------------------------------------------------
 		l_taiv_rec.amount           := -r_invoice.invoice_amount;
    	l_taiv_rec.amount_applied   := 0;
    	l_taiv_rec.currency_code    := r_invoice.currency_code;
    	l_taiv_rec.date_entered     := SYSDATE;
    	l_taiv_rec.date_invoiced    := SYSDATE;
    	l_taiv_rec.khr_id           := r_invoice.khr_id;
    	l_taiv_rec.object_version_number := l_api_version;
    	l_taiv_rec.org_id           := r_invoice.org_id;
    	l_taiv_rec.set_of_books_id  := r_invoice.sob_id;
    	l_taiv_rec.trx_status_code  := 'ENTERED';
    	l_taiv_rec.try_id           := r_invoice.try_id ;


        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' Creating Internal AR Invoice Header..');

-- Start of wraper code generated automatically by Debug code generator for okl_trx_ar_invoices_pub.insert_trx_ar_invoices
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRPICB.pls call okl_trx_ar_invoices_pub.insert_trx_ar_invoices  ');
    END;
  END IF;
    	okl_trx_ar_invoices_pub.insert_trx_ar_invoices (
            p_api_version           =>   p_api_version
            ,p_init_msg_list        =>   p_init_msg_list
            ,x_return_status        =>   x_return_status
            ,x_msg_count            =>   x_msg_count
            ,x_msg_data             =>   x_msg_data
            ,p_taiv_rec             =>   l_taiv_rec
            ,x_taiv_rec             =>   lx_taiv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRPICB.pls call okl_trx_ar_invoices_pub.insert_trx_ar_invoices  ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_trx_ar_invoices_pub.insert_trx_ar_invoices

		IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            l_conc_status  := 'E';
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ERROR: Creating Internal AR Invoice Header.');
		ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            l_conc_status  := 'E';
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ERROR: Creating Internal AR Invoice Header.');
		ELSIF (x_return_status ='S') THEN
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' Created Internal AR Invoice Header with Id: '||lx_taiv_rec.id);
		END IF;

	    -----------------------------------------------------------------
		-- Insert external AR invoice line
		-----------------------------------------------------------------
    	l_tilv_rec.tai_id           := lx_taiv_rec.id;
    	l_tilv_rec.amount           := -r_invoice.invoice_amount;
    	l_tilv_rec.amount_applied   := 0;
    	l_tilv_rec.line_number      := 1;
    	l_tilv_rec.object_version_number := l_api_version;
    	l_tilv_rec.org_id           := r_invoice.org_id;
    	l_tilv_rec.inv_receiv_line_code           := 'LINE';
    	l_taiv_rec.attribute1       := 'AUTO_DISBURSEMENT';
    	l_tilv_rec.attribute1       := 'AUTO_DISBURSEMENT';

        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' Creating Internal AR Invoice Line..');
-- Start of wraper code generated automatically by Debug code generator for okl_txl_ar_inv_lns_pub.insert_txl_ar_inv_lns
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRPICB.pls call okl_txl_ar_inv_lns_pub.insert_txl_ar_inv_lns  ');
    END;
  END IF;
    	okl_txl_ar_inv_lns_pub.insert_txl_ar_inv_lns (
            p_api_version           =>   p_api_version
            ,p_init_msg_list        =>   p_init_msg_list
            ,x_return_status        =>   x_return_status
            ,x_msg_count            =>   x_msg_count
            ,x_msg_data             =>   x_msg_data
            ,p_tilv_rec             =>   l_tilv_rec
            ,x_tilv_rec             =>   lx_tilv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRPICB.pls call okl_txl_ar_inv_lns_pub.insert_txl_ar_inv_lns  ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_txl_ar_inv_lns_pub.insert_txl_ar_inv_lns

		IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            l_conc_status  := 'E';
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ERROR: Creating Internal AR Invoice Line.');
		ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            l_conc_status  := 'E';
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ERROR: Creating Internal AR Invoice Line.');
		ELSIF (x_return_status ='S') THEN
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' Created Internal AR Invoice Line with Id: '||lx_tilv_rec.id);
		END IF;

		p_bpd_acc_rec.id 		   := lx_tilv_rec.id;
		p_bpd_acc_rec.source_table := 'OKL_TXL_AR_INV_LNS_B';
		----------------------------------------------------
		-- Create Accounting Distributions
		----------------------------------------------------
-- Start of wraper code generated automatically by Debug code generator for Okl_Acc_Call_Pub.CREATE_ACC_TRANS
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRPICB.pls call Okl_Acc_Call_Pub.CREATE_ACC_TRANS ');
    END;
  END IF;
		Okl_Acc_Call_Pub.CREATE_ACC_TRANS(
     			p_api_version
    		   ,p_init_msg_list
    		   ,x_return_status
    		   ,x_msg_count
    		   ,x_msg_data
  			   ,p_bpd_acc_rec
		);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRPICB.pls call Okl_Acc_Call_Pub.CREATE_ACC_TRANS ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Acc_Call_Pub.CREATE_ACC_TRANS
		IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            l_conc_status  := 'E';
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ERROR: Creating Accounting Distributions.');
		ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            l_conc_status  := 'E';
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ERROR: Creating Accounting Distributions.');
		ELSIF (x_return_status ='S') THEN
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ... Accounting Distributions Created.');
		END IF;

    END IF;

    IF ( NVL(l_conc_status, 'E') = okl_api.g_ret_sts_success )
        THEN
	   -----------------------------------------------------------------
	   -- Update internal AP table for Success
	   -----------------------------------------------------------------
       FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Successfully Prepared Invoice Number : ' || r_invoice.invoice_number);

       UPDATE okl_trx_ap_invoices_b
       SET trx_status_code = 'PROCESSED'
       WHERE id = r_invoice.tap_id;

    ELSE
	    -----------------------------------------------------------------
		-- Update internal AP table for Error
		-----------------------------------------------------------------
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'*=>ERROR: Processing Invoice Number : ' || r_invoice.invoice_number);

        IF x_msg_count >= 1 THEN

            FOR i in 1..x_msg_count LOOP
            fnd_msg_pub.get (p_msg_index => i,
                       p_encoded => 'F',
                       p_data => x_msg_data,
                       p_msg_index_out => l_msg_index_out);

    		  FND_FILE.PUT_LINE (FND_FILE.OUTPUT,to_char(i) || ': ' || x_msg_data);

            END LOOP;
        END IF;

    	UPDATE okl_trx_ap_invoices_b
    	SET trx_status_code = 'ERROR'
        WHERE id = r_invoice.tap_id;

    	UPDATE OKL_EXT_PAY_INVS_b
    	SET trx_status_code = 'ERROR'
        WHERE id = lx_xpiv_rec.id;

    	UPDATE okl_trx_ar_invoices_b
    	SET trx_status_code = 'ERROR'
        WHERE id = lx_taiv_rec.id;

    END IF;


    IF l_commit_cnt > l_MAX_commit_cnt THEN
        COMMIT;
        l_commit_cnt := 0;
    END IF;

END LOOP;

COMMIT;

l_commit_cnt := 0;
l_previous_tap_id := null;
l_previous_xpi_id := null;

-- FUNDING CURSOR

FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '============================================================');
FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '  ******* Begin Funding Records ******* ');
FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '============================================================');

FOR fund_rec IN c_funding_csr LOOP
  IF (NVL(l_previous_tap_id, -99) <> fund_rec.tap_id) THEN

       l_conc_status := 'S';

       l_commit_cnt := l_commit_cnt + 1;

       -- Consider activating
       -- Null records
       --l_xpiv_rec := l_init_xpiv_rec;
       --l_xlpv_rec := l_init_xlpv_rec;

       -- Null records
       l_xpiv_rec := l_init_xpiv_rec;
       l_xlpv_rec := l_init_xlpv_rec;
       l_taiv_rec := l_init_taiv_rec;
       l_tilv_rec := l_init_tilv_rec;

       ------------------------------------------------------------
       -- Generate sequence while consolidating, Bug 2949640
       -- Sunil Mathew, 12-May-2003
       ------------------------------------------------------------
       l_gen_seq := NULL;
       IF fund_rec.invoice_number IS NULL THEN
         BEGIN
          l_gen_seq := fnd_seqnum.get_next_sequence
                (appid      =>  l_okl_application_id,
                cat_code    =>  l_document_category,
                sobid       =>  fund_rec.sob_id,
                met_code    =>  'A',
                trx_date    =>  SYSDATE,
                dbseqnm     =>  lx_dbseqnm,
                dbseqid     =>  lx_dbseqid);
         EXCEPTION
            WHEN OTHERS THEN
                 l_gen_seq := -1;
         END;
       END IF;

       fund_rec.vendor_invoice_number := NVL(fund_rec.vendor_invoice_number,l_gen_seq);
       fund_rec.invoice_number        := NVL(fund_rec.invoice_number,l_gen_seq);

       FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '============================================================');
       FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Processing Vendor Invoice Number: '||fund_rec.vendor_invoice_number);
       FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '============================================================');

       FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
       FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '++++ Set of Books: '||fund_rec.sob_id||' Org Id: '||fund_rec.org_id||' Invoice Number: '||fund_rec.invoice_number );
       FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '++++ Vendor Site (ipvs_id): '||fund_rec.ipvs_id||' Terms Id(ippt_id): '||fund_rec.ippt_id||' Payment Method Code: '||fund_rec.payment_method_code );
       FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '++++ Currency: '||fund_rec.currency_code||' GL Date: '||fund_rec.gl_date||' Nettable: '||fund_rec.nettable_yn );
       FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '++++ khr_id: '||fund_rec.khr_id||' try_id: '||fund_rec.try_id);
       FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '++++ db_ccid: '||fund_rec.db_ccid||' cr_ccid: '||fund_rec.cr_ccid);
       FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '++++ invoice_amount: '||fund_rec.invoice_amount||' Vendor Id: '||fund_rec.vendor_id);
       FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
  END IF;

--    SAVEPOINT C_INVOICE_POINT;

    IF NVL(fund_rec.nettable_yn, 'N') = 'N' OR fund_rec.invoice_amount > 0 THEN
      IF (NVL(l_previous_tap_id, -99) <> fund_rec.tap_id) THEN
       FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Creating Payables Invoice');

	   -----------------------------------------------------------------
	   -- Populate and insert external AP invoice header
	   -----------------------------------------------------------------
		l_xpiv_rec.invoice_id := NULL;

		OPEN  seq_csr;
		FETCH seq_csr INTO l_xpiv_rec.invoice_id;
		CLOSE seq_csr;

        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' Invoice id: '||l_xpiv_rec.invoice_id);

        l_xpiv_rec.doc_category_code    := fund_rec.invoice_category_code;
        l_xpiv_rec.invoice_num          := fund_rec.invoice_number;
        l_xpiv_rec.vendor_invoice_number:= fund_rec.vendor_invoice_number;
        l_xpiv_rec.gl_date              := fund_rec.gl_date ;
        l_xpiv_rec.invoice_amount       := fund_rec.invoice_amount;
        l_xpiv_rec.pay_group_lookup_code:= fund_rec.pay_group_lookup_code;
        l_xpiv_rec.nettable_yn			:= fund_rec.nettable_yn;

        l_xpiv_rec.accts_pay_cc_id 		:= NVL(fund_rec.tap_ccid,fund_rec.cr_ccid);
        l_xpiv_rec.invoice_currency_code:= fund_rec.currency_code;
        l_xpiv_rec.invoice_date         := fund_rec.date_invoiced;
        l_xpiv_rec.object_version_number:= fund_rec.object_version_number;
        l_xpiv_rec.org_id               := fund_rec.org_id;
        l_xpiv_rec.payment_method       := fund_rec.payment_method_code;
        l_xpiv_rec.terms_id             := fund_rec.ippt_id;
        l_xpiv_rec.trx_status_code      := 'ENTERED';
        l_xpiv_rec.vendor_site_id       := fund_rec.ipvs_id;
        l_xpiv_rec.wait_vendor_invoice_yn := fund_rec.wait_vendor_invoice_yn;
        l_xpiv_rec.workflow_flag        := fund_rec.workflow_yn;


        l_xpiv_rec.CURRENCY_CONVERSION_TYPE := fund_rec.CURRENCY_CONVERSION_TYPE;
        l_xpiv_rec.CURRENCY_CONVERSION_RATE := fund_rec.CURRENCY_CONVERSION_RATE;
        l_xpiv_rec.CURRENCY_CONVERSION_DATE := fund_rec.CURRENCY_CONVERSION_DATE;


        -- Multi Currency Parameters
        IF ( (l_xpiv_rec.CURRENCY_CONVERSION_TYPE IS NULL) OR
             (l_xpiv_rec.CURRENCY_CONVERSION_RATE IS NULL) OR
             (l_xpiv_rec.CURRENCY_CONVERSION_DATE IS NULL) OR
             (l_xpiv_rec.INVOICE_CURRENCY_CODE IS NULL) ) THEN

            l_currency_code            := NULL;
            l_currency_conversion_type := NULL;
            l_currency_conversion_rate := NULL;
            l_currency_conversion_date := NULL;

            OPEN  l_curr_conv_csr ( fund_rec.khr_id );
            FETCH l_curr_conv_csr INTO  l_currency_code,
                                        l_currency_conversion_type,
                                        l_currency_conversion_rate,
                                        l_currency_conversion_date;
            CLOSE l_curr_conv_csr;

            l_xpiv_rec.INVOICE_CURRENCY_CODE    := l_currency_code;
	        l_xpiv_rec.CURRENCY_CONVERSION_TYPE := l_currency_conversion_type;
	        l_xpiv_rec.CURRENCY_CONVERSION_RATE := l_currency_conversion_rate;
	        l_xpiv_rec.CURRENCY_CONVERSION_DATE := l_currency_conversion_date;

            -- If Currency Code is null then default functional currency
            IF ( l_xpiv_rec.INVOICE_CURRENCY_CODE IS NULL ) THEN
                l_xpiv_rec.INVOICE_CURRENCY_CODE
                     := okl_accounting_util.get_func_curr_code;
            END IF;

            -- If the type were not captured in authoring
            IF 	l_xpiv_rec.currency_conversion_type IS NULL THEN
                l_xpiv_rec.currency_conversion_type := 'User';
		        l_xpiv_rec.currency_conversion_rate := 1;
                l_xpiv_rec.currency_conversion_date := SYSDATE;
            END IF;

            -- For date
            IF l_xpiv_rec.currency_conversion_date IS NULL THEN
	           l_xpiv_rec.currency_conversion_date := SYSDATE;
            END IF;

            -- For rate -- Work out the rate in a Spot or Corporate
            IF (l_xpiv_rec.currency_conversion_type = 'User') THEN
                IF l_xpiv_rec.currency_conversion_rate IS NULL THEN
                    l_xpiv_rec.currency_conversion_rate := 1;
                END IF;
            END IF;
        END IF;

            IF (l_xpiv_rec.currency_conversion_type = 'Spot'
                OR l_xpiv_rec.currency_conversion_type = 'Corporate') THEN

                l_xpiv_rec.currency_conversion_rate  := NULL;
                /*l_xpiv_rec.currency_conversion_rate
                    := okl_accounting_util.get_curr_con_rate
                   (p_from_curr_code => l_xpiv_rec.INVOICE_CURRENCY_CODE,
	                p_to_curr_code => okl_accounting_util.get_func_curr_code,
	                p_con_date => l_xpiv_rec.currency_conversion_date,
	                p_con_type => l_xpiv_rec.currency_conversion_type);
                 */
            END IF;


        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' Creating External AP Invoice Header..');

-- Start of wraper code generated automatically by Debug code generator for OKL_EXT_PAY_INVS_PUB.insert_ext_pay_invs
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRPICB.pls call OKL_EXT_PAY_INVS_PUB.insert_ext_pay_invs ');
    END;
  END IF;


        OKL_EXT_PAY_INVS_PUB.insert_ext_pay_invs(
        p_api_version            =>   p_api_version
        ,p_init_msg_list         =>   p_init_msg_list
        ,x_return_status         =>   x_return_status
        ,x_msg_count             =>   x_msg_count
        ,x_msg_data              =>   x_msg_data
        ,p_xpiv_rec              =>   l_xpiv_rec
        ,x_xpiv_rec              =>   lx_xpiv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRPICB.pls call OKL_EXT_PAY_INVS_PUB.insert_ext_pay_invs ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_EXT_PAY_INVS_PUB.insert_ext_pay_invs

		IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            l_conc_status  := 'E';
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ERROR: Creating External AP Invoice Header.');
		ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            l_conc_status  := 'E';
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ERROR: Creating External AP Invoice Header.');
		ELSIF (x_return_status ='S') THEN
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' Created External AP Invoice Header with Id: '||lx_xpiv_rec.id);
		END IF;

    l_previous_tap_id := fund_rec.tap_id;
    l_previous_xpi_id := lx_xpiv_rec.id;
  END IF;

	-----------------------------------------------------------------
	-- Populate and Insert external AP invoice Lines
	-----------------------------------------------------------------
        --l_xlpv_rec.xpi_id_details       := lx_xpiv_rec.id;
        l_xlpv_rec.xpi_id_details       := l_previous_xpi_id;
        l_xlpv_rec.amount               := fund_rec.line_amount;
        l_xlpv_rec.org_id               := fund_rec.org_id;
        l_xlpv_rec.object_version_number:= fund_rec.object_version_number;
        l_xlpv_rec.dist_code_combination_id := NVL(fund_rec.tap_ccid,fund_rec.db_ccid);

		-- Usually Line id but for funding, an exception!
--        IF (fund_rec.FUNDING_TYPE_CODE = 'ASSET_SUBSIDY') THEN
--            l_xlpv_rec.tpl_id 				:= fund_rec.tpl_id;
--        ELSE
            l_xlpv_rec.tap_id 				:= fund_rec.tap_id;
--        END IF;

        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' Creating External AP Invoice Lines..');
        okl_xtl_pay_invs_pub.insert_xtl_pay_invs(
            p_api_version           =>   p_api_version
            ,p_init_msg_list        =>   p_init_msg_list
            ,x_return_status        =>   x_return_status
            ,x_msg_count            =>   x_msg_count
            ,x_msg_data             =>   x_msg_data
            ,p_xlpv_rec             =>   l_xlpv_rec
            ,x_xlpv_rec             =>   lx_xlpv_rec);


		IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            l_conc_status  := 'E';
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ERROR: Creating External AP Invoice Line.');
		ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            l_conc_status  := 'E';
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ERROR: Creating External AP Invoice Line.');
		ELSIF (x_return_status ='S') THEN
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' Created External AP Invoice Line with Id: '||lx_xlpv_rec.id);
		END IF;

    ELSE
	    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Creating Receviables Invoice');

		-----------------------------------------------------------------
		-- Populate external AR invoice header and line record
		-----------------------------------------------------------------
 		l_taiv_rec.amount           := -fund_rec.invoice_amount;
    	l_taiv_rec.amount_applied   := 0;
    	l_taiv_rec.currency_code    := fund_rec.currency_code;
    	l_taiv_rec.date_entered     := SYSDATE;
    	l_taiv_rec.date_invoiced    := SYSDATE;
    	l_taiv_rec.khr_id           := fund_rec.khr_id;
    	l_taiv_rec.object_version_number := l_api_version;
    	l_taiv_rec.org_id           := fund_rec.org_id;
    	l_taiv_rec.set_of_books_id  := fund_rec.sob_id;
    	l_taiv_rec.trx_status_code  := 'ENTERED';
    	l_taiv_rec.try_id           := fund_rec.try_id ;


        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' Creating Internal AR Invoice Header..');

-- Start of wraper code generated automatically by Debug code generator for okl_trx_ar_invoices_pub.insert_trx_ar_invoices
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRPICB.pls call okl_trx_ar_invoices_pub.insert_trx_ar_invoices  ');
    END;
  END IF;
    	okl_trx_ar_invoices_pub.insert_trx_ar_invoices (
            p_api_version           =>   p_api_version
            ,p_init_msg_list        =>   p_init_msg_list
            ,x_return_status        =>   x_return_status
            ,x_msg_count            =>   x_msg_count
            ,x_msg_data             =>   x_msg_data
            ,p_taiv_rec             =>   l_taiv_rec
            ,x_taiv_rec             =>   lx_taiv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRPICB.pls call okl_trx_ar_invoices_pub.insert_trx_ar_invoices  ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_trx_ar_invoices_pub.insert_trx_ar_invoices

		IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            l_conc_status  := 'E';
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ERROR: Creating Internal AR Invoice Header.');
		ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            l_conc_status  := 'E';
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ERROR: Creating Internal AR Invoice Header.');
		ELSIF (x_return_status ='S') THEN
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' Created Internal AR Invoice Header with Id: '||lx_taiv_rec.id);
		END IF;

	    -----------------------------------------------------------------
		-- Insert external AR invoice line
		-----------------------------------------------------------------
    	l_tilv_rec.tai_id           := lx_taiv_rec.id;
    	l_tilv_rec.amount           := -fund_rec.invoice_amount;
    	l_tilv_rec.amount_applied   := 0;
    	l_tilv_rec.line_number      := 1;
    	l_tilv_rec.object_version_number := l_api_version;
    	l_tilv_rec.org_id           := fund_rec.org_id;
    	l_tilv_rec.inv_receiv_line_code           := 'LINE';
    	l_taiv_rec.attribute1       := 'AUTO_DISBURSEMENT';
    	l_tilv_rec.attribute1       := 'AUTO_DISBURSEMENT';

        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' Creating Internal AR Invoice Line..');
-- Start of wraper code generated automatically by Debug code generator for okl_txl_ar_inv_lns_pub.insert_txl_ar_inv_lns
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRPICB.pls call okl_txl_ar_inv_lns_pub.insert_txl_ar_inv_lns  ');
    END;
  END IF;
    	okl_txl_ar_inv_lns_pub.insert_txl_ar_inv_lns (
            p_api_version           =>   p_api_version
            ,p_init_msg_list        =>   p_init_msg_list
            ,x_return_status        =>   x_return_status
            ,x_msg_count            =>   x_msg_count
            ,x_msg_data             =>   x_msg_data
            ,p_tilv_rec             =>   l_tilv_rec
            ,x_tilv_rec             =>   lx_tilv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRPICB.pls call okl_txl_ar_inv_lns_pub.insert_txl_ar_inv_lns  ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_txl_ar_inv_lns_pub.insert_txl_ar_inv_lns

		IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            l_conc_status  := 'E';
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ERROR: Creating Internal AR Invoice Line.');
		ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            l_conc_status  := 'E';
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ERROR: Creating Internal AR Invoice Line.');
		ELSIF (x_return_status ='S') THEN
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' Created Internal AR Invoice Line with Id: '||lx_tilv_rec.id);
		END IF;

		p_bpd_acc_rec.id 		   := lx_tilv_rec.id;
		p_bpd_acc_rec.source_table := 'OKL_TXL_AR_INV_LNS_B';
		----------------------------------------------------
		-- Create Accounting Distributions
		----------------------------------------------------
-- Start of wraper code generated automatically by Debug code generator for Okl_Acc_Call_Pub.CREATE_ACC_TRANS
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRPICB.pls call Okl_Acc_Call_Pub.CREATE_ACC_TRANS ');
    END;
  END IF;
		Okl_Acc_Call_Pub.CREATE_ACC_TRANS(
     			p_api_version
    		   ,p_init_msg_list
    		   ,x_return_status
    		   ,x_msg_count
    		   ,x_msg_data
  			   ,p_bpd_acc_rec
		);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRPICB.pls call Okl_Acc_Call_Pub.CREATE_ACC_TRANS ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Acc_Call_Pub.CREATE_ACC_TRANS

		IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            l_conc_status  := 'E';
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ERROR: Creating Accounting Distributions.');
		ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            l_conc_status  := 'E';
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ERROR: Creating Accounting Distributions.');
		ELSIF (x_return_status ='S') THEN
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ... Accounting Distributions Created.');
		END IF;
    END IF;


    IF ( NVL(l_conc_status, 'E') = okl_api.g_ret_sts_success  )
     THEN
	   -----------------------------------------------------------------
	   -- Update internal AP table for Success
	   -----------------------------------------------------------------
       FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Successfully Prepared Invoice Number : ' || fund_rec.invoice_number);

       UPDATE okl_trx_ap_invoices_b
       SET trx_status_code = 'PROCESSED'
       WHERE id = fund_rec.tap_id;
    ELSE
	    -----------------------------------------------------------------
		-- Update internal AP table for Error
		-----------------------------------------------------------------
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'*=>ERROR: Processing Invoice Number : ' || fund_rec.invoice_number);

        IF x_msg_count >= 1 THEN

            FOR i in 1..x_msg_count LOOP
            fnd_msg_pub.get (p_msg_index => i,
                       p_encoded => 'F',
                       p_data => x_msg_data,
                       p_msg_index_out => l_msg_index_out);

    		  FND_FILE.PUT_LINE (FND_FILE.OUTPUT,to_char(i) || ': ' || x_msg_data);

            END LOOP;
        END IF;

    	UPDATE okl_trx_ap_invoices_b
    	SET trx_status_code = 'ERROR'
        WHERE id = fund_rec.tap_id;

    	UPDATE OKL_EXT_PAY_INVS_b
    	SET trx_status_code = 'ERROR'
        WHERE id = lx_xpiv_rec.id;

    	UPDATE okl_trx_ar_invoices_b
    	SET trx_status_code = 'ERROR'
        WHERE id = lx_taiv_rec.id;

    END IF;

    IF l_commit_cnt > l_MAX_commit_cnt THEN
        COMMIT;
        l_commit_cnt := 0;
    END IF;

END LOOP; -- End Funding Cursor

FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '============================================================');
FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '  ******* End Funding Records ******* ');
FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '============================================================');

	------------------------------------------------------------
	-- End processing
	------------------------------------------------------------

	Okl_Api.END_ACTIVITY (
		x_msg_count	=> x_msg_count,
		x_msg_data	=> x_msg_data);


EXCEPTION
	------------------------------------------------------------
	-- Exception handling
	------------------------------------------------------------
	WHEN OKL_API.G_EXCEPTION_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '*=> ERROR: '||SQLERRM);
		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OKL_API.G_RET_STS_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '*=> ERROR: '||SQLERRM);
		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OKL_API.G_RET_STS_UNEXP_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN OTHERS THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '*=> ERROR: '||SQLERRM);
		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OTHERS',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');
END consolidation_11i;


PROCEDURE consolidation_ssiruvol(
         p_api_version	IN  NUMBER,
	 p_init_msg_list	IN  VARCHAR2	DEFAULT OKC_API.G_FALSE,
	 x_return_status	OUT NOCOPY      VARCHAR2,
	 x_msg_count		OUT NOCOPY      NUMBER,
	 x_msg_data		    OUT NOCOPY      VARCHAR2,
         p_contract_number     IN VARCHAR2    DEFAULT NULL,
 	 p_vendor              IN VARCHAr2      DEFAULT NULL,
	 p_vendor_site         IN VARCHAr2      DEFAULT NULL,
         p_vpa_number              IN VARCHAR2      DEFAULT NULL,
         p_stream_type_purpose IN VARCHAR2    DEFAULT NULL,
         p_from_date        IN  DATE DEFAULT NULL,
         p_to_date          IN  DATE DEFAULT NULL)
IS
	------------------------------------------------------------
	-- Declare variables required by APIs
	------------------------------------------------------------
   	l_api_version	CONSTANT NUMBER     := 1;
	l_api_name	CONSTANT VARCHAR2(30)   := 'CONSOLIDATION';
	l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	------------------------------------------------------------
	-- Declare Process variables
	------------------------------------------------------------
    l_msg_index_out     NUMBER;
    i                   NUMBER;

	-----------------------------------------------------------------
	-- Fetch Ap Interface Sequence Number
	-----------------------------------------------------------------
	CURSOR seq_csr IS
        SELECT ap_invoices_interface_s.nextval
        FROM dual;

	p_bpd_acc_rec					Okl_Acc_Call_Pub.bpd_acc_rec_type;

	------------------------------------------------------------
	-- Declare records: Payable Invoice Headers and Lines
	------------------------------------------------------------
    l_xpiv_rec           Okl_xpi_Pvt.xpiv_rec_type;

    -- Nulling record
    l_init_xpiv_rec      Okl_xpi_Pvt.xpiv_rec_type;

    lx_xpiv_rec          Okl_xpi_Pvt.xpiv_rec_type;
    l_xlpv_rec           okl_xlp_pvt.xlpv_rec_type;

    -- Nulling record
    l_init_xlpv_rec      okl_xlp_pvt.xlpv_rec_type;

    lx_xlpv_rec          okl_xlp_pvt.xlpv_rec_type;

    l_taiv_rec           okl_tai_pvt.taiv_rec_type;
    lx_taiv_rec          okl_tai_pvt.taiv_rec_type;
    -- Nulling record
    l_init_taiv_rec      okl_tai_pvt.taiv_rec_type;

    l_tilv_rec           okl_til_pvt.tilv_rec_type;
    lx_tilv_rec          okl_til_pvt.tilv_rec_type;
    -- Nulling record
    l_init_tilv_rec      okl_til_pvt.tilv_rec_type;

     -- Multi Currency Compliance
    l_currency_code            okl_ext_sell_invs_b.currency_code%type;
    l_currency_conversion_type okl_ext_sell_invs_b.currency_conversion_type%type;
    l_currency_conversion_rate okl_ext_sell_invs_b.currency_conversion_rate%type;
    l_currency_conversion_date okl_ext_sell_invs_b.currency_conversion_date%type;

    l_previous_tap_id    okl_trx_ap_invoices_b.id%TYPE := NULL;
    l_previous_xpi_id    okl_ext_sell_invs_b.id%TYPE := NULL;

    CURSOR l_curr_conv_csr( cp_khr_id  NUMBER ) IS
        SELECT  currency_code
               ,currency_conversion_type
               ,currency_conversion_rate
               ,currency_conversion_date
        FROM    okl_k_headers_full_v
        WHERE   id = cp_khr_id;

    CURSOR l_contract_id_csr (cNum VARCHAR2) Is
    select id
    from okc_K_headers_b
    where contract_number = cNum;

    l_contract_id_rec l_contract_id_csr%ROWTYPE;

    CURSOR l_vendor_csr (vendorN VARCHAR2) IS
    select vendor_id
    from po_vendors
    where vendor_name = nvl(vendorN, 'XX');

    l_vendor_rec l_vendor_csr%ROWTYPE;

    CURSOR l_vendor_site_csr (vId NUMBER, VSite VARCHAR) IS
    select vendor_site_id
    from po_vendor_sites_all
    where vendor_id = nvl(vId, -1)
      and vendor_site_code = nvl(VSite, 'XX');

    l_vendor_site_rec l_vendor_site_csr%ROWTYPE;

    -----------------------------------------------------------
    -- Variables for Bug 2949640, Sunil Mathew, 12-May-2003
    -----------------------------------------------------------
    l_gen_seq           okl_trx_ap_invoices_v.invoice_number%TYPE;
    l_okl_application_id NUMBER(3) := 540;
    l_document_category VARCHAR2(100):= 'OKL Lease Pay Invoices';
    lX_dbseqnm          VARCHAR2(2000):= '';
    lX_dbseqid          NUMBER(38):= NULL;


    l_conc_status       VARCHAR2(1);

    l_commit_cnt        NUMBER;
    l_MAX_commit_cnt    NUMBER := 500;

    l_cin_tbl OKL_CIN_PVT.cin_tbl_type;
    lx_cin_tbl OKL_CIN_PVT.cin_tbl_type;

    l_cin_rec OKL_CIN_PVT.cin_rec_type;
    lx_cin_rec OKL_CIN_PVT.cin_rec_type;

    l_tplv_rec   OKL_TPL_PVT.tplv_rec_type;
    lx_tplv_rec  OKL_TPL_PVT.tplv_rec_type;

    l_tplv_tbl   OKL_TPL_PVT.tplv_tbl_type;
    lx_tplv_tbl  OKL_TPL_PVT.tplv_tbl_type;



    l_cnsld_invs cnsld_invs_tbl_type;

    l_contract_id NUMBER;
    l_vendor_id NUMBER;
    l_vendor_site_id NUMBER;
    l_vpa_id NUMBER;

    l_cnsld_line_number BINARY_INTEGER := 0;

--start: |           01-May-07 cklee  R12 DIsb enhancement project
        CURSOR acc_sys_option is
        select account_derivation
		from okl_sys_acct_opts;
--end: |           01-May-07 cklee  R12 DIsb enhancement project

BEGIN
	------------------------------------------------------------
	-- Start processing
	------------------------------------------------------------

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'OKL Prepare Payables Invoices IN pvt consol');

	x_return_status := OKL_API.G_RET_STS_SUCCESS;

	l_return_status := OKL_API.START_ACTIVITY(
		p_api_name	    => l_api_name,
    	p_pkg_name	    => g_pkg_name,
		p_init_msg_list	=> p_init_msg_list,
		l_api_version	=> l_api_version,
		p_api_version	=> p_api_version,
		p_api_type	    => '_PVT',
		x_return_status	=> l_return_status);

	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

--start: |           01-May-07 cklee  R12 DIsb enhancement project
    OPEN acc_sys_option;
    FETCH acc_sys_option INTO G_ACC_SYS_OPTION;
    CLOSE acc_sys_option;
--end: |           01-May-07 cklee  R12 DIsb enhancement project
	-----------------------------------------------------------------
	-- Open Invoice cursor in block
	-----------------------------------------------------------------

    l_commit_cnt := 0;

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'IN pvt consol getting contarct id for contarct ' || p_contract_number);

    OPEN  l_contract_id_csr(p_contract_number);
    FETCH l_contract_id_csr into l_contract_id_rec;
    If l_contract_id_csr%FOUND THEN
      l_contract_id := l_contract_id_rec.id;
    ELse
      l_contract_id := NULL;
    END IF;
    CLOSE l_contract_id_csr;

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'IN pvt consol got contarct id ' || to_char(nvl(l_contract_id, -1)));

    l_contract_id_rec := NULL;
    OPEN  l_contract_id_csr(p_vpa_number);
    FETCH l_contract_id_csr into l_contract_id_rec;
    If l_contract_id_csr%FOUND THEN
      l_vpa_id := l_contract_id_rec.id;
    ELse
      l_vpa_id := NULL;
    END IF;
    CLOSE l_contract_id_csr;

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'IN pvt consol got vpa_id id ' || to_char(nvl(l_vpa_id, -1)));

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'IN pvt consol getting vendor program  ' || nvl(p_vpa_number, 'XXX'));
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'IN pvt consol getting vendor name  ' || nvl(p_vendor, 'XXX'));
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'IN pvt consol getting vendor site  ' || nvl(p_vendor_site, 'XXX'));

/*
    OPEN  l_vendor_csr(p_vendor);
    FETCH l_vendor_csr into l_vendor_rec;
    If l_vendor_csr%FOUND THEN
      l_vendor_id := l_vendor_rec.vendor_id;
    ELse
      l_vendor_id := NULL;
    END IF;
    CLOSE l_vendor_csr;
    */

    l_vendor_id := to_number(p_vendor);


    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'IN pvt consol got vendor name id ' || to_char(nvl(l_vendor_id, -1)));
/*

    OPEN  l_vendor_site_csr(l_vendor_id, p_vendor_site );
    FETCH l_vendor_site_csr into l_vendor_site_rec;
    If l_vendor_site_csr%FOUND THEN
      l_vendor_site_id := l_vendor_site_rec.vendor_site_id;
    ELse
      l_vendor_site_id := NULL;
    END IF;
    CLOSE l_vendor_site_csr;

*/

    l_vendor_site_id := to_number(p_vendor_site);

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'IN pvt consol got vendor site id ' || to_char(nvl(l_vendor_site_id, -1)));

    apply_consolidation_rules_ssir(
            p_api_version   =>   p_api_version,
            p_init_msg_list =>   p_init_msg_list,
            x_return_status =>   x_return_status,
            x_msg_count     =>   x_msg_count,
            x_msg_data      =>   x_msg_data,
            x_cnsld_invs    =>   l_cnsld_invs,
            p_contract_id   =>   l_contract_id,
 	    p_vendor_id       => l_vendor_id,
	    p_vendor_site_id  => l_vendor_site_id,
            p_vpa_id          => l_vpa_id,
            p_stream_type_purpose => p_stream_type_purpose,
            p_from_date       => p_from_date,
            p_to_date         => p_to_date);



    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            l_conc_status  := 'E';
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ERROR: Cannot Consolidate.');
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            l_conc_status  := 'E';
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ERROR: Cannot Consolidate.');
    ELSIF (x_return_status ='S') THEN
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' Created Consolidated invoices: ');
    END IF;

    if l_cnsld_invs.count > 0 Then

      FOR i in l_cnsld_invs.FIRST..l_cnsld_invs.LAST
      LOOP

        l_cin_rec := l_cnsld_invs(i).cin_rec;

        OKL_CIN_PVT.insert_row(
            p_api_version   =>   p_api_version,
            p_init_msg_list =>   p_init_msg_list,
            x_return_status =>   x_return_status,
            x_msg_count     =>   x_msg_count,
            x_msg_data      =>   x_msg_data,
            p_cin_rec      =>    l_cin_rec,
            x_cin_rec      =>    lx_cin_rec);


        IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            l_conc_status  := 'E';
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ERROR: Creating Consolidated invoices.');
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            l_conc_status  := 'E';
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ERROR: Creating Consolidated invoices.');
        ELSIF (x_return_status ='S') THEN
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' Created Consolidated invoices: '||to_char(l_cin_rec.cnsld_ap_inv_id));
        END IF;

        l_tplv_tbl := l_cnsld_invs(i).tplv_tbl;
        l_cnsld_line_number := 0;
        FOR j in l_tplv_tbl.FIRST..l_tplv_tbl.LAST
        LOOP
          l_tplv_tbl(j).cnsld_ap_inv_id := lx_cin_rec.cnsld_ap_inv_id;
          l_cnsld_line_number := l_cnsld_line_number + 1;
          l_tplv_tbl(j).cnsld_line_number := l_cnsld_line_number;
        END LOOP;


        OKL_TPL_PVT.update_row(
            p_api_version   =>   p_api_version,
            p_init_msg_list =>   p_init_msg_list,
            x_return_status =>   x_return_status,
            x_msg_count     =>   x_msg_count,
            x_msg_data      =>   x_msg_data,
            p_tplv_tbl      =>   l_tplv_tbl,
            x_tplv_tbl      =>   lx_tplv_tbl);


        IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            l_conc_status  := 'E';
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ERROR: Creating Consolidated invoices lines.');
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            l_conc_status  := 'E';
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ERROR: Creating Consolidated invoices lines.');
        ELSIF (x_return_status ='S') THEN
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' Created Consolidated invoices lines: '||to_char(lx_tplv_rec.id));
        END IF;

        If (x_return_status ='S') THEN

          For j in l_tplv_tbl.FIRST..l_tplv_tbl.LAST
          LOOP

           UPDATE OKL_TRX_AP_INVS_ALL_B
           SET TRX_STATUS_CODE = 'PROCESSED'
           WHERE ID = l_tplv_tbl(j).tap_id;

          END LOOP;

-- strat: cklee 4/26/07
        Else

          For j in l_tplv_tbl.FIRST..l_tplv_tbl.LAST
          LOOP

           UPDATE OKL_TRX_AP_INVS_ALL_B
           SET TRX_STATUS_CODE = 'ERROR'
           WHERE ID = l_tplv_tbl(j).tap_id;

          END LOOP;
-- end: cklee 4/26/07

        End If;

      END LOOP;

    End If; -- if l_cnsld_invs.count > 0 Then


    transfer_to_external(
            p_api_version   =>   p_api_version,
            p_init_msg_list =>   p_init_msg_list,
            x_return_status =>   x_return_status,
            x_msg_count     =>   x_msg_count,
            x_msg_data      =>   x_msg_data);
--            p_from_date       => p_from_date,
--            p_to_date         => p_to_date);

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            l_conc_status  := 'E';
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ERROR: transferring invoices lines.');
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            l_conc_status  := 'E';
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ERROR: transferring invoices lines.');
    ELSIF (x_return_status ='S') THEN
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' transferring invoices lines: ');
    END IF;

	------------------------------------------------------------
	-- End processing
	------------------------------------------------------------

	Okl_Api.END_ACTIVITY (
		x_msg_count	=> x_msg_count,
		x_msg_data	=> x_msg_data);


EXCEPTION
	------------------------------------------------------------
	-- Exception handling
	------------------------------------------------------------
	WHEN OKL_API.G_EXCEPTION_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '*=> ERROR: '||SQLERRM);
		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OKL_API.G_RET_STS_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '*=> ERROR: '||SQLERRM);
		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OKL_API.G_RET_STS_UNEXP_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN OTHERS THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '*=> ERROR: '||SQLERRM);
		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OTHERS',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');
END consolidation_ssiruvol;

--start: 31-Oct-2007 cklee -- bug: 6508575 fixed
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : get consolidation parameters
-- Description     : get consolidation parameters
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
PROCEDURE get_con_parameters(
     p_api_version         IN  NUMBER,
	 p_init_msg_list       IN  VARCHAR2	DEFAULT OKC_API.G_FALSE,
	 x_return_status       OUT NOCOPY  VARCHAR2,
	 x_msg_count	       OUT NOCOPY  NUMBER,
	 x_msg_data	    	   OUT NOCOPY  VARCHAR2,
     p_contract_number     IN VARCHAR2 DEFAULT NULL,
 	 p_vendor              IN VARCHAr2 DEFAULT NULL,
	 p_vendor_site         IN VARCHAr2 DEFAULT NULL,
     p_vpa_number          IN VARCHAR2 DEFAULT NULL,
     x_contract_id         OUT NOCOPY  NUMBER,
 	 x_vendor_id           OUT NOCOPY  NUMBER,
	 x_vendor_site_id      OUT NOCOPY  NUMBER,
     x_vpa_id              OUT NOCOPY  NUMBER
)
IS
	------------------------------------------------------------
	-- Declare variables required by APIs
	------------------------------------------------------------
   	l_api_version	CONSTANT NUMBER     := 1;
	l_api_name	CONSTANT VARCHAR2(30)   := 'get_con_parameters';
	l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	------------------------------------------------------------
	-- Declare Process variables
	------------------------------------------------------------
--    l_msg_index_out     NUMBER;
--    i                   NUMBER;

    CURSOR l_contract_id_csr (cNum VARCHAR2) Is
    select id
    from okc_k_headers_all_b
    where contract_number = cNum;

--    l_contract_id_rec l_contract_id_csr%ROWTYPE;

    CURSOR l_vendor_csr (vendorN VARCHAR2) IS
    select pv.vendor_id
    from po_vendors pv
    where pv.vendor_name = vendorN;

--    l_vendor_rec l_vendor_csr%ROWTYPE;

    CURSOR l_vendor_site_csr (VSite VARCHAR) IS
    select vendor_site_id
    from po_vendor_sites_all povs
    where povs.vendor_site_code = VSite;

--    l_vendor_site_rec l_vendor_site_csr%ROWTYPE;

    l_conc_status       VARCHAR2(1);

--    l_contract_id NUMBER;
--    l_vendor_id NUMBER;
--    l_vendor_site_id NUMBER;
--    l_vpa_id NUMBER;

--    l_cnsld_line_number BINARY_INTEGER := 0;


BEGIN
	------------------------------------------------------------
	-- Start processing
	------------------------------------------------------------

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'get_con_parameters: 1');

	x_return_status := OKL_API.G_RET_STS_SUCCESS;

	l_return_status := OKL_API.START_ACTIVITY(
		p_api_name	    => l_api_name,
    	p_pkg_name	    => g_pkg_name,
		p_init_msg_list	=> p_init_msg_list,
		l_api_version	=> l_api_version,
		p_api_version	=> p_api_version,
		p_api_type	    => '_PVT',
		x_return_status	=> l_return_status);

	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;
	-----------------------------------------------------------------
	-- Open Invoice cursor in block
	-----------------------------------------------------------------

--    l_commit_cnt := 0;
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'get_con_parameters: 2 contarct number:' || p_contract_number);

    OPEN  l_contract_id_csr(p_contract_number);
    FETCH l_contract_id_csr into x_contract_id;
    CLOSE l_contract_id_csr;

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'get_con_parameters: 3 got contarct id ' || to_char(nvl(x_contract_id, -1)));

--    l_contract_id_rec := NULL;
    OPEN  l_contract_id_csr(p_vpa_number);
    FETCH l_contract_id_csr into x_vpa_id;
    CLOSE l_contract_id_csr;

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'get_con_parameters: 4 got vpa_id id ' || to_char(nvl(x_vpa_id, -1)));

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'get_con_parameters: 5 getting vendor program  ' || nvl(p_vpa_number, 'XXX'));
--start:|  26-Nov-2007  cklee -- bug: 6620557 fixed                                  |
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'get_con_parameters: 6 getting vendor ID  ' || nvl(p_vendor, 'XXX'));
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'get_con_parameters: 7 getting vendor site ID  ' || nvl(p_vendor_site, 'XXX'));
    x_vendor_id := p_vendor;
    x_vendor_site_id := p_vendor_site;
/*
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'get_con_parameters: 6 getting vendor name  ' || nvl(p_vendor, 'XXX'));
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'get_con_parameters: 7 getting vendor site  ' || nvl(p_vendor_site, 'XXX'));

    OPEN  l_vendor_csr(p_vendor);
    FETCH l_vendor_csr into x_vendor_id;
    CLOSE l_vendor_csr;

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'get_con_parameters: 8 got vendor name id ' || to_char(nvl(x_vendor_id, -1)));

    OPEN  l_vendor_site_csr(p_vendor_site);
    FETCH l_vendor_site_csr into x_vendor_site_id;
    CLOSE l_vendor_site_csr;

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'get_con_parameters: 9 got vendor site id ' || to_char(nvl(x_vendor_site_id, -1)));*/
--end:|  26-Nov-2007  cklee -- bug: 6620557 fixed                                  |

	------------------------------------------------------------
	-- End processing
	------------------------------------------------------------

	Okl_Api.END_ACTIVITY (
		x_msg_count	=> x_msg_count,
		x_msg_data	=> x_msg_data);


EXCEPTION
	------------------------------------------------------------
	-- Exception handling
	------------------------------------------------------------
	WHEN OKL_API.G_EXCEPTION_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '*=> ERROR: '||SQLERRM);
		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OKL_API.G_RET_STS_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '*=> ERROR: '||SQLERRM);
		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OKL_API.G_RET_STS_UNEXP_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN OTHERS THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '*=> ERROR: '||SQLERRM);
		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OTHERS',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');
END get_con_parameters;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : consolidation
-- Description     : consolidation
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
PROCEDURE consolidation(
     p_api_version         IN  NUMBER,
	 p_init_msg_list       IN  VARCHAR2	DEFAULT OKC_API.G_FALSE,
	 x_return_status       OUT NOCOPY  VARCHAR2,
	 x_msg_count	       OUT NOCOPY  NUMBER,
	 x_msg_data	    	   OUT NOCOPY  VARCHAR2,
     p_contract_number     IN VARCHAR2 DEFAULT NULL,
 	 p_vendor              IN VARCHAr2 DEFAULT NULL,
	 p_vendor_site         IN VARCHAr2 DEFAULT NULL,
     p_vpa_number          IN VARCHAR2 DEFAULT NULL,
     p_stream_type_purpose IN VARCHAR2 DEFAULT NULL,
     p_from_date           IN  DATE    DEFAULT NULL,
     p_to_date             IN  DATE    DEFAULT NULL)
IS
	------------------------------------------------------------
	-- Declare variables required by APIs
	------------------------------------------------------------
   	l_api_version	CONSTANT NUMBER     := 1;
	l_api_name	CONSTANT VARCHAR2(30)   := 'CONSOLIDATION';
	l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	------------------------------------------------------------
	-- Declare Process variables
	------------------------------------------------------------
--    l_msg_index_out     NUMBER;
--    i                   NUMBER;

    l_contract_id NUMBER;
    l_vendor_id NUMBER;
    l_vendor_site_id NUMBER;
    l_vpa_id NUMBER;

    l_conc_status       VARCHAR2(1);

BEGIN
	------------------------------------------------------------
	-- Start processing
	------------------------------------------------------------

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'consolidation 1');

	x_return_status := OKL_API.G_RET_STS_SUCCESS;

	l_return_status := OKL_API.START_ACTIVITY(
		p_api_name	    => l_api_name,
    	p_pkg_name	    => g_pkg_name,
		p_init_msg_list	=> p_init_msg_list,
		l_api_version	=> l_api_version,
		p_api_version	=> p_api_version,
		p_api_type	    => '_PVT',
		x_return_status	=> l_return_status);

	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;
--
    get_con_parameters(
            p_api_version         => p_api_version,
            p_init_msg_list       => p_init_msg_list,
            x_return_status       => x_return_status,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data,
            p_contract_number     => p_contract_number,
     	    p_vendor              => p_vendor,
	        p_vendor_site         => p_vendor_site,
            p_vpa_number          => p_vpa_number,
            x_contract_id         => l_contract_id,
     	    x_vendor_id           => l_vendor_id,
	        x_vendor_site_id      => l_vendor_site_id,
            x_vpa_id              => l_vpa_id);

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            l_conc_status  := 'E';
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ERROR: get_con_parameters failed.');
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            l_conc_status  := 'E';
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ERROR: get_con_parameters failed.');
    ELSIF (x_return_status ='S') THEN
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' get_con_parameters done: ');
    END IF;

    apply_consolidation_rules(
            p_api_version         => p_api_version,
            p_init_msg_list       => p_init_msg_list,
            x_return_status       => x_return_status,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data,
            p_contract_id         => l_contract_id,
     	    p_vendor_id           => l_vendor_id,
	        p_vendor_site_id      => l_vendor_site_id,
            p_vpa_id              => l_vpa_id,
            p_stream_type_purpose => p_stream_type_purpose,
            p_from_date           => p_from_date,
            p_to_date             => p_to_date);

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            l_conc_status  := 'E';
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ERROR: apply_consolidation_rules failed.');
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            l_conc_status  := 'E';
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ERROR: apply_consolidation_rules failed.');
    ELSIF (x_return_status ='S') THEN
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' Created Consolidated invoices: ');
    END IF;
/* future release
    handle_processing_fee(
            p_api_version   =>   p_api_version,
            p_init_msg_list =>   p_init_msg_list,
            x_return_status =>   x_return_status,
            x_msg_count     =>   x_msg_count,
            x_msg_data      =>   x_msg_data);

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            l_conc_status  := 'E';
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ERROR: Handle porcessing feet.');
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            l_conc_status  := 'E';
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ERROR: Handle porcessing feet.');
    ELSIF (x_return_status ='S') THEN
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' Handle porcessing feet.');
    END IF;
*/
    transfer_to_external(
            p_api_version   =>   p_api_version,
            p_init_msg_list =>   p_init_msg_list,
            x_return_status =>   x_return_status,
            x_msg_count     =>   x_msg_count,
            x_msg_data      =>   x_msg_data);

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            l_conc_status  := 'E';
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ERROR: transferring invoices lines.');
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            l_conc_status  := 'E';
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ERROR: transferring invoices lines.');
    ELSIF (x_return_status ='S') THEN
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' transferring invoices lines: ');
    END IF;

	------------------------------------------------------------
	-- End processing
	------------------------------------------------------------

	Okl_Api.END_ACTIVITY (
		x_msg_count	=> x_msg_count,
		x_msg_data	=> x_msg_data);


EXCEPTION
	------------------------------------------------------------
	-- Exception handling
	------------------------------------------------------------
	WHEN OKL_API.G_EXCEPTION_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '*=> ERROR: '||SQLERRM);
		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OKL_API.G_RET_STS_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '*=> ERROR: '||SQLERRM);
		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OKL_API.G_RET_STS_UNEXP_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN OTHERS THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '*=> ERROR: '||SQLERRM);
		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OTHERS',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');
END consolidation;
--end: 31-Oct-2007 cklee -- bug: 6508575 fixed



END okl_pay_invoices_cons_pvt;

/
