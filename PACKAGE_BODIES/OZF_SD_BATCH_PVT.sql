--------------------------------------------------------
--  DDL for Package Body OZF_SD_BATCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_SD_BATCH_PVT" AS
  /* $Header: ozfvsdbb.pls 120.48.12010000.44 2010/06/04 08:50:46 annsrini ship $ */

  -- Start of Comments
  -- Package name     : OZF_SD_BATCH_PVT
  -- Purpose          : This package contains procedures and functions for batch creation concurrent program
  --                    Also contains executable procedure for auto claim concurrent program
  -- Author  : MBHATT
  -- Created : 11/16/2007 2:39:16 PM
  -- History          :
  -- 16-FEB-2008     JMAHENDR     - Modified GET_BATCH_CURRENCY_AMOUNT to use
  --                                OZF_OFFERS.TRANSACTION_CURRENCY_CODE
  --                              - Insert of claim_amount_currency_code in CREATE_BATCH_LINES
  -- 22-FEB-2008     JMAHENDR     - Change filter condition on batch line create to pick accruals that are !=0
  --                              - Change to use PO_VENDOR_CONTACTS instead of AP_SUPPLIER_CONTACTS
  --                              - Use of tradeprofile (TP) thresholds only if TP currency is set
  -- 25-SEP-2008   -  ANNSRINI - removed product check in create_batch_lines and getting org_id from request lines instead of funds_utilised table
  -- 26-SEP-2008   -  ANNSRINI -  Modified p_start_date and p_end_date to varchar instead of DATE in create_batch_main
  --                                added l_start_date and l_end_date in create_batch_main and passing these in call to create_batch_sub
  --                           - Introduced the same code removed for product check except for org_id in create_batch_lines proc.
  -- 29-JAN-2009   -  ANNSRINI - Introduced NVL for oel.shipping_quantity_uom, oel.order_quantity_uom
  -- 10-FEB-2009   -  ANNSRINI - Populating l_supplier_contact_name in CREATE_BATCH_HEADER API
  -- 11-FEB-2009   -  JMAHENDR - Change to RA_CUSTOMER_TRX_LINES_ALL sql for RMA
  -- 23-FEB-2009   -  ANNSRINI - Added debug messages to get the timings of cursor execution in create_batch_lines, insertion, invoking claim API
  -- 25-FEB-2009   -  ANNSRINI - Change w.r.t RMA and negative accrual
  -- 06-MAR-2009   -  ANNSRINI - Changed the sequence of p_fund_id and p_product_id in create_batch_main proc
  -- 20-APR-2009   -  ANNSRINI - Changes w.r.t cost_basis, quantity in case of RMA, invoice and product info
  -- 06-MAY-2009   -  JMAHENDR - bug fix 8489965 - use absolute value of accrual
  -- 19-JUN-2009   -  ANNSRINI - 3 APIs added - PROCESS_SD_PENDING_CLM_BATCHES, PROCESS_SUPPLIER_SITES and INVOKE_CLAIM
  -- 30-JUN-2009   -  ANNSRINI - If claim process is unsuccessful, then update batch header status as PENDING_CLAIM
  -- 20-JUL-2009   -  ANNSRINI - Adjustment related changes
  -- 03-NOV-2009   -  ANNSRINI - fix for bug 8890852 (added resource_busy exception)
  -- 07-DEC-2009   -  ANNSRINI - changes w.r.t multicurrency
  --
  -- NOTE             :
  -- End of Comments

  G_PKG_NAME CONSTANT VARCHAR2(30)   := 'OZF_SD_BATCH_PVT';
  G_FILE_NAME CONSTANT VARCHAR2(12)  := 'ozfvsdbb.pls';
  OZF_DEBUG_HIGH_ON CONSTANT BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
  OZF_DEBUG_LOW_ON CONSTANT BOOLEAN  := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low);
  OZF_ERROR_ON CONSTANT BOOLEAN      := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error);
  g_currency VARCHAR2(30)            := null;
  g_ret_level NUMBER                 := 0;

  type c_batch_header is REF CURSOR;

-- Start of comments
--	API name 	: GET_BATCH_CURRENCY_AMOUNT
--	Type		: Private
--	Pre-reqs	: None.
--	Function	: Converts batch line currency into corresponding header currency
--                        Conversion is not made if FROM and TO currency are the same.
--	Parameters	:
--	IN		:	p_func_currency           	IN VARCHAR2	Required
--				p_batch_currency                IN VARCHAR2     Required
--				p_batch_id                      IN NUMBER 	Required
--                              p_acctd_amount                  IN NUMBER       Required
--                              p_conv_type                     IN VARCHAR2
--                              p_conv_rate                     IN NUMBER
--                              p_date                          IN DATE
--      OUT             :       Converted currency value.
-- End of comments
  FUNCTION GET_BATCH_CURRENCY_AMOUNT(p_func_currency  VARCHAR2,
                                     p_batch_currency VARCHAR2,
				     p_acctd_amount   NUMBER,
				     p_conv_type      VARCHAR2,
				     p_conv_rate      NUMBER,
				     p_date           DATE) RETURN number is
    x_return_status VARCHAR2(100) := NULL;
    x_rate          NUMBER;
    l_from_amount   NUMBER;
    x_to_amount     NUMBER;

  BEGIN

      OZF_UTILITY_PVT.Convert_Currency(p_from_currency => p_func_currency,
                                       p_to_currency   => p_batch_currency,
                                       p_conv_type     => p_conv_type,
				       p_conv_rate     => NULL,
				       p_conv_date     => p_date,
                                       p_from_amount   => p_acctd_amount,
				       x_return_status => x_return_status,
                                       x_to_amount     => x_to_amount,
				       x_rate          => x_rate);

    RETURN x_to_amount;

  EXCEPTION

    WHEN OTHERS then
      FND_FILE.PUT_LINE(FND_FILE.LOG,
                        'OZF_UTILITY_PVT.Convert_Currency(x_return_status,' ||
                        x_return_status);

      FND_FILE.PUT_LINE(FND_FILE.LOG,
                        'Start exception block of GET_BATCH_CURRENCY_AMOUNT(p_acctd_amount :-,' ||
                        p_acctd_amount || ' p_batch_currency VARCHAR2) ' ||
                        p_batch_currency || ' : x_to_amount :=' ||
                        x_to_amount || SQLERRM);
      RAISE FND_API.g_exc_error;

  END;

-- Start of comments
--	API name 	: CONV_DISC_TO_OFFER_CURR_AMOUNT
--	Type		: Private
--	Pre-reqs	: None.
--	Function	: Converts discount value from discount value currency to offer currency
--                        Conversion is not made if FROM and TO currency are the same.
--	Parameters	:
--	IN		:	p_offer_currency           	IN NUMBER	Required
--				p_discount_val_currency         IN VARCHAR2     Required
--				p_discount_val                  IN NUMBER 	Required
--                              p_batch_id                      IN NUMBER 	Required
--      OUT             :       Converted currency value.
-- End of comments

  FUNCTION CONV_DISC_TO_OFFER_CURR_AMOUNT(p_offer_currency VARCHAR2,
                                     p_discount_val_currency VARCHAR2,
                                     p_discount_val       number,
				     p_date date) RETURN number is
    x_return_status VARCHAR2(100) := NULL;
    l_conv_date     DATE;
    x_to_amount     NUMBER;

  BEGIN
/*
    SELECT OZF_SD_BATCH_HEADERS_ALL.Creation_Date
      INTO l_conv_date
      FROM OZF_SD_BATCH_HEADERS_ALL
     WHERE batch_id = p_batch_id;
  */

    IF p_discount_val_currency <> p_offer_currency then
      OZF_UTILITY_PVT.Convert_Currency(x_return_status,
                                       p_discount_val_currency,
                                       p_offer_currency,
                                       p_date,
                                       p_discount_val,
                                       x_to_amount);
    ELSE
      x_to_amount := p_discount_val;
    END IF;

    RETURN x_to_amount;

  EXCEPTION

    WHEN OTHERS then
      FND_FILE.PUT_LINE(FND_FILE.LOG,
                        'OZF_UTILITY_PVT.Convert_Currency(x_return_status,' ||
                        x_return_status);

      FND_FILE.PUT_LINE(FND_FILE.LOG,
                        'Start exception block of CONV_DISC_TO_OFFER_CURR_AMOUNT(p_discount_val number:-,' ||
                        p_discount_val || ' p_offer_currency VARCHAR2) ' ||
                        p_offer_currency || ' : x_to_amount :=' ||
                        x_to_amount || SQLERRM);
      RAISE FND_API.g_exc_error;

  END;

-- Start of comments
--	API name 	: CURR_ROUND_EXT_PREC
--	Type		: Private
--	Pre-reqs	: None.
--	Function	: Rounds the amount based on extended precision for currency
--	Parameters	:
--	IN		:	p_amount                       	IN NUMBER	Required
--				p_currency_code                 IN VARCHAR2     Required
--
--      OUT             :       Rounded amount based on extended precision for currency.
-- End of comments

FUNCTION CURR_ROUND_EXT_PREC(
    p_amount IN NUMBER,
    p_currency_code IN VARCHAR2
)
RETURN NUMBER IS

precision      NUMBER; /* number of digits to right of decimal*/
ext_precision  NUMBER; /* precision where more precision is needed*/
min_acct_unit  NUMBER; /* minimum value by which amt can vary */

BEGIN

    FND_CURRENCY.get_info(p_currency_code, precision, ext_precision, min_acct_unit);

        IF  min_acct_unit IS NOT NULL THEN
            RETURN( ROUND( p_amount /  min_acct_unit) *  min_acct_unit );
        ELSE
            RETURN( ROUND( p_amount, ext_precision ));
        END IF;

END CURR_ROUND_EXT_PREC;


-- Start of comments
--	API name        : GET_VENDOR_ITEM_ID
--	Type            : Private
--	Pre-reqs        : None.
--	Function        : Returns the mapped vendor product id for a given distributor
--                        product id based on trade profile for vendor site.
--	Parameters      :
--      IN              :       p_product_id                    IN NUMBER       Required
--                              p_supplier_site_id              IN NUMBER       Required
--      OUT             :       Vendor product code.
-- End of comments
  FUNCTION GET_VENDOR_ITEM_ID(p_product_id       number,
                              p_supplier_site_id number) RETURN varchar2 is

    l_vendor_product_id varchar2(240) := null;
    l_internal_code     varchar2(240) := null;

  BEGIN
    l_internal_code := p_product_id;

    SELECT code.external_code
      INTO l_vendor_product_id
      FROM OZF_SUPP_CODE_CONVERSIONS_ALL code, OZF_SUPP_TRD_PRFLS_ALL prf
     WHERE internal_code = l_internal_code and
           code.supp_trade_profile_id = prf.supp_trade_profile_id and
           prf.supplier_site_id = p_supplier_site_id and
           trunc(sysdate) between code.start_date_active and
           nvl(code.end_date_active, sysdate + 1);

    RETURN l_vendor_product_id;

  END get_vendor_item_id;



-- Start of comments
--	API name        : create_batch_main
--	Type            : Private
--	Pre-reqs        : None.
--	Function        : Executable target for concurrent program
--                        Executable Name "OZFSDBPREX"
--                        Loops over availabe operating units and invokes create_batch_sub
--	Parameters      :
--	IN              :       p_org_id                        IN NUMBER
--                              p_supplier_id                   IN NUMBER       REQUIRED
--                              p_supplier_site_id              IN NUMBER
--                              p_product_id                    IN NUMBER
--                              p_request_id                    IN NUMBER
--                              p_fund_id                       IN NUMBER
--                              p_start_date                    IN DATE
--                              p_end_date                      IN DATE
--                              p_period                        IN VARCHAR2
--                              p_attribute1                    IN VARCHAR2
--                              p_attribute2                    IN VARCHAR2
--                              p_attribute3                    IN VARCHAR2
--                              p_attribute4                    IN VARCHAR2
--                              p_attribute5                    IN VARCHAR2
--                              p_attribute6                    IN VARCHAR2
--                              p_attribute7                    IN VARCHAR2
--                              p_attribute8                    IN VARCHAR2
--                              p_attribute9                    IN VARCHAR2
--                              p_attribute10                   IN VARCHAR2
--                              p_attribute11                   IN VARCHAR2
--                              p_attribute12                   IN VARCHAR2
--                              p_attribute13                   IN VARCHAR2
--                              p_attribute14                   IN VARCHAR2
--                              p_attribute15                   IN VARCHAR2
-- End of comments
  PROCEDURE create_batch_main(errbuf             OUT nocopy VARCHAR2,
                              retcode            OUT nocopy NUMBER,
                              p_org_id           IN NUMBER,
                              p_supplier_id      IN NUMBER,
                              p_supplier_site_id IN NUMBER,
                              --p_category_id IN NUMBER,
                              p_fund_id     IN NUMBER,
                              p_request_id  IN NUMBER,
                              p_product_id  IN NUMBER,
                              p_start_date  IN VARCHAR2,
                              p_end_date    IN VARCHAR2,
                              p_period      IN VARCHAR2,
                              p_attribute1  IN VARCHAR2 := NULL,
                              p_attribute2  IN VARCHAR2 := NULL,
                              p_attribute3  IN VARCHAR2 := NULL,
                              p_attribute4  IN VARCHAR2 := NULL,
                              p_attribute5  IN VARCHAR2 := NULL,
                              p_attribute6  IN VARCHAR2 := NULL,
                              p_attribute7  IN VARCHAR2 := NULL,
                              p_attribute8  IN VARCHAR2 := NULL,
                              p_attribute9  IN VARCHAR2 := NULL,
                              p_attribute10 IN VARCHAR2 := NULL,
                              p_attribute11 IN VARCHAR2 := NULL,
                              p_attribute12 IN VARCHAR2 := NULL,
                              p_attribute13 IN VARCHAR2 := NULL,
                              p_attribute14 IN VARCHAR2 := NULL,
                              p_attribute15 IN VARCHAR2 := NULL
			      ) IS

    CURSOR operating_unit_csr IS
      SELECT ou.organization_id org_id
        FROM hr_operating_units ou
       WHERE mo_global.check_access(ou.organization_id) = 'Y';

    m        NUMBER := 0;
    l_org_id OZF_UTILITY_PVT.operating_units_tbl;

    l_start_date       date;
    l_end_date         date;

 /* resource_busy EXCEPTION;
    PRAGMA EXCEPTION_INIT (resource_busy, -54); */

  BEGIN

  g_ret_level := 0;


    IF OZF_DEBUG_LOW_ON THEN

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Start CREATE_BATCH_MAIN');
      FND_FILE.PUT_LINE(FND_FILE.LOG, '--- Start Parameter List ---');
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_org_id: '           || p_org_id);
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_supplier_id: '      || p_supplier_id);
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_supplier_site_id: ' || p_supplier_site_id);
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_product_id: '       || p_product_id);
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_request_id: '       || p_request_id);
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_fund_id: '          || p_fund_id);
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_start_date: '       || p_start_date);
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_end_date: '         || p_end_date);
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_period: '           || p_period);
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_attribute1: '       || p_attribute1);
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_attribute2: '       || p_attribute2);
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_attribute3: '       || p_attribute3);
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_attribute4: '       || p_attribute4);
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_attribute5: '       || p_attribute5);
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_attribute6: '       || p_attribute6);
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_attribute7: '       || p_attribute7);
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_attribute8: '       || p_attribute8);
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_attribute9: '       || p_attribute9);
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_attribute10: '      || p_attribute10);
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_attribute11: '      || p_attribute11);
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_attribute12: '      || p_attribute12);
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_attribute13: '      || p_attribute13);
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_attribute14: '      || p_attribute14);
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_attribute15: '      || p_attribute15);
      FND_FILE.PUT_LINE(FND_FILE.LOG, '--- End Parameter List ---');
    END IF;
    MO_GLOBAL.init('OZF');

    IF p_org_id IS NULL THEN
      MO_GLOBAL.set_policy_context('M', null);
      OPEN operating_unit_csr;
      LOOP
        FETCH operating_unit_csr
          INTO l_org_id(m);
        m := m + 1;
        EXIT WHEN operating_unit_csr%NOTFOUND;
      END LOOP;
      CLOSE operating_unit_csr;
    ELSE
      l_org_id(m) := p_org_id;
    END IF;

    IF (l_org_id.COUNT > 0) THEN
      FOR m IN l_org_id.FIRST .. l_org_id.LAST LOOP
        BEGIN
          IF OZF_DEBUG_LOW_ON THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, '--- Start Fetch of Organization ids ---');
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_org_id ' || to_char(l_org_id(m)));
            FND_FILE.PUT_LINE(FND_FILE.LOG, '--- End Fetch of Organization ids ---');
          END IF;

	  MO_GLOBAL.set_policy_context('S', l_org_id(m));

          IF OZF_DEBUG_HIGH_ON THEN
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Processing for Operating Unit: ' ||
	                                       MO_GLOBAL.get_ou_name(l_org_id(m)));
          END IF;


	  IF p_start_date IS NOT NULL THEN
		   l_start_date          := to_date(p_start_date,'YYYY/MM/DD HH24:MI:SS');
	  END IF ;

 	  IF p_end_date IS NOT NULL THEN
		   l_end_date            := to_date(p_end_date,  'YYYY/MM/DD HH24:MI:SS');
	  END IF ;

          create_batch_sub(l_org_id(m),
                           p_supplier_id,
                           p_supplier_site_id,
                           --p_category_id  ,
                           p_product_id,
                           p_request_id,
                           p_fund_id,
                           l_start_date,
                           l_end_date,
                           p_period,
                           FND_API.g_true,
                           p_attribute1,
                           p_attribute2,
                           p_attribute3,
                           p_attribute4,
                           p_attribute5,
                           p_attribute6,
                           p_attribute7,
                           p_attribute8,
                           p_attribute9,
                           p_attribute10,
                           p_attribute11,
                           p_attribute12,
                           p_attribute13,
                           p_attribute14,
                           p_attribute15);
        EXCEPTION

          WHEN OTHERS THEN
            IF OZF_DEBUG_HIGH_ON THEN
              FND_FILE.PUT_LINE(FND_FILE.LOG,
                                'Exception in CREATE_BATCH_MAIN : ' ||
                                SQLERRM);

            END IF;
            --Code added for bug#6971836
	    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Exception in CREATE_BATCH_MAIN : ' ||SQLERRM);

	    errbuf  := 'Error in CREATE_BATCH_MAIN ' || SQLERRM;
            retcode := 2;
        END;
      END LOOP;

    END IF;

    IF g_ret_level = 1 THEN
       errbuf  := 'Warning in CREATE_BATCH_MAIN ' || SQLERRM;
       retcode := 1;
    END IF;

  END create_batch_main;



-- Start of comments
--	API name        : create_batch_sub
--	Type            : Private
--	Pre-reqs        : None.
--	Function        : Invokes creation of Batch looping for Supplier Site and Currency.
--	Parameters      :
--	IN              :       p_org_id                        IN NUMBER       REQUIRED
--                              p_supplier_id                   IN NUMBER       REQUIRED
--                              p_supplier_site_id              IN NUMBER
--                              p_product_id                    IN NUMBER
--                              p_request_id                    IN NUMBER
--                              p_fund_id                       IN NUMBER
--                              p_start_date                    IN DATE
--                              p_end_date                      IN DATE
--                              p_period                        IN VARCHAR2
--                              p_commit                        IN VARCHAR2
--                              p_attribute1                    IN VARCHAR2
--                              p_attribute2                    IN VARCHAR2
--                              p_attribute3                    IN VARCHAR2
--                              p_attribute4                    IN VARCHAR2
--                              p_attribute5                    IN VARCHAR2
--                              p_attribute6                    IN VARCHAR2
--                              p_attribute7                    IN VARCHAR2
--                              p_attribute8                    IN VARCHAR2
--                              p_attribute9                    IN VARCHAR2
--                              p_attribute10                   IN VARCHAR2
--                              p_attribute11                   IN VARCHAR2
--                              p_attribute12                   IN VARCHAR2
--                              p_attribute13                   IN VARCHAR2
--                              p_attribute14                   IN VARCHAR2
--                              p_attribute15                   IN VARCHAR2
-- End of comments
  PROCEDURE create_batch_sub(p_org_id           IN NUMBER,
                             p_supplier_id      IN NUMBER,
                             p_supplier_site_id IN NUMBER,
                             --p_category_id    IN NUMBER,
                             p_product_id       IN NUMBER,
                             p_request_id       IN NUMBER,
                             p_fund_id          IN NUMBER,
                             p_start_date       IN DATE,
                             p_end_date         IN DATE,
                             p_period           IN VARCHAR2,
                             p_commit           IN VARCHAR2 := FND_API.g_false,
                             p_attribute1       IN VARCHAR2 := NULL,
                             p_attribute2       IN VARCHAR2 := NULL,
                             p_attribute3       IN VARCHAR2 := NULL,
                             p_attribute4       IN VARCHAR2 := NULL,
                             p_attribute5       IN VARCHAR2 := NULL,
                             p_attribute6       IN VARCHAR2 := NULL,
                             p_attribute7       IN VARCHAR2 := NULL,
                             p_attribute8       IN VARCHAR2 := NULL,
                             p_attribute9       IN VARCHAR2 := NULL,
                             p_attribute10      IN VARCHAR2 := NULL,
                             p_attribute11      IN VARCHAR2 := NULL,
                             p_attribute12      IN VARCHAR2 := NULL,
                             p_attribute13      IN VARCHAR2 := NULL,
                             p_attribute14      IN VARCHAR2 := NULL,
                             p_attribute15      IN VARCHAR2 := NULL) IS

    l_empty_batch      VARCHAR2(10);
    l_supplier_id      NUMBER;
    l_supplier_site_id NUMBER;
    l_org_id           NUMBER := NULL; --Code added for bug#6867618

    --l_category_id    NUMBER;
    l_product_id       NUMBER;

    -- after checking frequency
    l_freq             NUMBER;
    l_last_run_date    DATE := NULL;
    l_fund_id          NUMBER := NULL;
    l_start_date       DATE := NULL;
    l_end_date         DATE := NULL;
    l_period           VARCHAR2(100) := NULL;
    l_currency_code    VARCHAR2(15) := NULL;
    l_query            VARCHAR2(2000) := NULL;
    l_currency         VARCHAR2(15) := NULL;
    l_freq_unit        VARCHAR2(100) := NULL;
    type r_cursor is   REF CURSOR;
    c_currency         r_cursor;

    l_supplier_name   VARCHAR2(240);
    l_sup_site_name   VARCHAR2(15);

  --org id Code added for bug#6867618
    CURSOR get_sites(c_vendor_id NUMBER,c_org_id NUMBER) IS
      SELECT sites.vendor_site_id
        FROM ap_supplier_sites_all sites,
	     ozf_supp_trd_prfls_all trprf
       WHERE sites.vendor_id = c_vendor_id AND
             sites.org_id = c_org_id  AND
             nvl(sites.inactive_date, sysdate) >= trunc(sysdate) AND
	     trprf.cust_account_id is not null AND
	     sites.vendor_id=trprf.supplier_id AND
	     sites.vendor_site_id=trprf.supplier_site_id;

    CURSOR trade_profile_values(c_supplier_site_id NUMBER,c_org_id NUMBER) IS
      SELECT claim_currency_code
        FROM ozf_supp_trd_prfls_all
       WHERE supplier_site_id = c_supplier_site_id AND
             org_id = c_org_id;

    CURSOR get_freq_and_date(c_supplier_site_id NUMBER,c_org_id NUMBER) IS
      SELECT claim_frequency, claim_frequency_unit, last_paid_date
        FROM ozf_supp_trd_prfls_all
       WHERE supplier_site_id = c_supplier_site_id AND
             org_id = c_org_id;

  BEGIN
    IF OZF_DEBUG_LOW_ON THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Start create_batch_sub for org id : ' || p_org_id);
    END IF;

    --Code added for bug#6867618
    l_org_id           := p_org_id;

    l_supplier_id      := p_supplier_id;
    l_supplier_site_id := p_supplier_site_id;
    --l_category_id    := p_category_id;
    l_product_id       := p_product_id;

    --Code added for output log supplier name
    Select vendor_name
    into l_supplier_name
    From ap_suppliers
    Where vendor_id = l_supplier_id;

    IF l_supplier_site_id IS NOT NULL THEN
      --if site is an input parameter
      IF OZF_DEBUG_LOW_ON THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_supplier_site_id IS NOT NULL');
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Supplier Site =' || p_supplier_site_id);

      END IF;

      --Code added for output log supplier name
      Select vendor_site_code
	into l_sup_site_name
      From ap_supplier_sites_all
      Where vendor_site_id = l_supplier_site_id;

        --Code added for bug#6971836
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Supplier Name =' || l_supplier_name||'('||l_supplier_id||
	') Site Code '||l_sup_site_name||'('||l_supplier_site_id||')');

      OPEN trade_profile_values(p_supplier_site_id,l_org_id);
      FETCH trade_profile_values
       INTO l_currency_code;
      CLOSE trade_profile_values;

      g_currency := l_currency_code;

      IF OZF_DEBUG_LOW_ON THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Trade Profile Currency Code = ' ||
	                                to_char(NVL(l_currency_code, 'Not Set')));

      END IF;

        --Code added for bug#6971836
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Trade Profile Currency Code = ' ||
	                                  to_char(NVL(l_currency_code, 'Not Set.')));

      IF l_currency_code IS NULL then
        --Code added for bug#6867618
        l_query := 'SELECT distinct request_currency_code FROM OZF_SD_REQUEST_HEADERS_ALL_B ' ||
                   ' WHERE supplier_id='    || p_supplier_id ||
                   ' AND supplier_site_id=' || p_supplier_site_id;
      ELSE
        l_query := 'SELECT claim_currency_code  FROM OZF_SUPP_TRD_PRFLS_ALL ' ||
                   ' WHERE supplier_site_id =' || p_supplier_site_id;

      END IF;

      IF OZF_DEBUG_LOW_ON THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, '--- Start Query Text ---');
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_query = ' || to_char(l_query));
        FND_FILE.PUT_LINE(FND_FILE.LOG, '--- End Query Text ---');
      END IF;

      OPEN c_currency for l_query;
      LOOP
        FETCH c_currency INTO l_currency;

	EXIT WHEN c_currency%notfound;

        IF OZF_DEBUG_LOW_ON THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, '--- Processing for Currency ---');
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_currency = ' || to_char(l_currency));
        END IF;

        OPEN get_freq_and_date(l_supplier_site_id,l_org_id);
        FETCH get_freq_and_date
          INTO l_freq, l_freq_unit, l_last_run_date;
        CLOSE get_freq_and_date;

        IF OZF_DEBUG_LOW_ON THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, '--- Trade Profile Frequency ---');
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_freq = '           || l_freq);
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_freq_unit = '      || l_freq_unit);
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_last_paid_date = ' || l_last_run_date);
        END IF;

        IF l_freq_unit = 'DAYS' then
          l_last_run_date := l_last_run_date + l_freq;
        ELSIF l_freq_unit = 'MONTHS' then
          SELECT add_months(l_last_run_date, l_freq)
            INTO l_last_run_date
            FROM dual;
        ELSIF l_freq_unit = 'YEAR' then
          SELECT add_months(l_last_run_date, l_freq * 12)
            INTO l_last_run_date
            FROM dual;
        END IF;

        IF OZF_DEBUG_LOW_ON THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_last_run_date :' || to_char(l_last_run_date));
        END IF;

        IF sysdate >= nvl(l_last_run_date, trunc(sysdate)) THEN
          IF OZF_DEBUG_HIGH_ON THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Batch Frequency Threshold met');
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Invoking CREATE BATCH');
          END IF;

	   --Code added for Bug#6971836
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Batch Frequency Threshold met.');

          create_batch(l_empty_batch,
                       l_supplier_id,
                       l_supplier_site_id,
                       p_org_id,
                       --l_category_id,
                       l_product_id,
                       p_request_id,
                       p_fund_id,
                       p_start_date,
                       p_end_date,
                       p_period,
                       l_currency,
                       p_attribute1,
                       p_attribute2,
                       p_attribute3,
                       p_attribute4,
                       p_attribute5,
                       p_attribute6,
                       p_attribute7,
                       p_attribute8,
                       p_attribute9,
                       p_attribute10,
                       p_attribute11,
                       p_attribute12,
                       p_attribute13,
                       p_attribute14,
                       p_attribute15);

        ELSE
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Batch Frequency Threshold not met');

	--Code added for Bug#6971836
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Batch Frequency Threshold not met.');

        END IF;

      END LOOP;
      CLOSE c_currency;
      -- after currency loop
      --  IF l_empty_batch = 'N' THEN

      UPDATE ozf_supp_trd_prfls_all
         SET last_paid_date = sysdate
       WHERE supplier_site_id = l_supplier_site_id;

      IF fnd_api.To_Boolean(p_commit) THEN
        COMMIT;
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Transaction is commited');
        FND_FILE.PUT_LINE(FND_FILE.LOG, ' supplier_site_id= ' || l_supplier_site_id);
        FND_FILE.PUT_LINE(FND_FILE.LOG, ' l_currency= ' || l_currency);
      END IF;

    ELSE
      --if l_supplier_site is null
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_supplier_site_id IS NULL');

      --Code added for bug#6971836
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Supplier Name =' || l_supplier_name||'('||l_supplier_id||
	'), Supplier Site Not Provided. ');

      --if site is null then create a batch for each site

      FOR site_rec IN get_sites(l_supplier_id,l_org_id) LOOP
        IF OZF_DEBUG_HIGH_ON THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Looping for Supplier Site ID = ' ||
                            site_rec.vendor_site_id);
        END IF;

	 --Code modified to get supplier site id
        OPEN trade_profile_values(site_rec.vendor_site_id,l_org_id);
        FETCH trade_profile_values
         INTO l_currency_code;
        CLOSE trade_profile_values;

        --Code added for bug#6867618
        g_currency := l_currency_code;

	IF OZF_DEBUG_HIGH_ON THEN
	  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Currenty Code = ' ||l_currency_code);
        END IF;

	--Code added for Bug#6971836
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Currenty Code = ' ||l_currency_code);

        IF l_currency_code IS NULL then
	  --Code added for bug#6867618
          l_query := 'SELECT distinct request_currency_code FROM OZF_SD_REQUEST_HEADERS_ALL_B ' ||
                     ' WHERE supplier_site_id=' || site_rec.vendor_site_id;
        ELSE
          l_query := 'SELECT claim_currency_code  FROM OZF_SUPP_TRD_PRFLS_ALL ' ||
                     ' WHERE supplier_site_id =' || site_rec.vendor_site_id;

        END IF;

        OPEN c_currency for l_query;
        LOOP
          FETCH c_currency
           INTO l_currency;
           EXIT WHEN c_currency%notfound;

          IF OZF_DEBUG_LOW_ON THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, '--- Processing for Currency ---');
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_currency = ' || to_char(l_currency));
          END IF;

          OPEN get_freq_and_date(site_rec.vendor_site_id,l_org_id);
          FETCH get_freq_and_date
            INTO l_freq, l_freq_unit, l_last_run_date;
          CLOSE get_freq_and_date;

          IF OZF_DEBUG_LOW_ON THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, '--- Trade Profile Frequency ---');
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_freq = '           || l_freq);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_freq_unit = '      || l_freq_unit);
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_last_paid_date = ' || l_last_run_date);
          END IF;

          IF l_freq_unit = 'DAYS' then
            l_last_run_date := l_last_run_date + l_freq;
          ELSIF l_freq_unit = 'MONTHS' then
            SELECT add_months(l_last_run_date, l_freq)
              INTO l_last_run_date
              FROM dual;
          ELSIF l_freq_unit = 'YEAR' then
            SELECT add_months(l_last_run_date, l_freq * 12)
              INTO l_last_run_date
              FROM dual;
          END IF;

          FND_FILE.PUT_LINE(FND_FILE.LOG,'SuppSite Loop: l_last_run_date post calculation : ' || l_last_run_date);

          IF sysdate >= NVL(l_last_run_date, TRUNC(SYSDATE)) THEN

            FND_FILE.PUT_LINE(FND_FILE.LOG, 'SuppSite Loop: Batch Create Freq Requirement Met');

	    --Code added for Bug#6971836
	    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Batch Create Freq Requirement Met.');

            create_batch(l_empty_batch,
	                 l_supplier_id,
                         site_rec.vendor_site_id,
                         p_org_id,
                         --l_category_id,
                         l_product_id,
                         p_request_id,
                         l_fund_id,
                         l_start_date,
                         l_end_date,
                         l_period,
                         l_currency,
                         p_attribute1,
                         p_attribute2,
                         p_attribute3,
                         p_attribute4,
                         p_attribute5,
                         p_attribute6,
                         p_attribute7,
                         p_attribute8,
                         p_attribute9,
                         p_attribute10,
                         p_attribute11,
                         p_attribute12,
                         p_attribute13,
                         p_attribute14,
                         p_attribute15);

          ELSE
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'SuppSite Loop: Batch Create Freq Requirement not met ');

	    --Code added for Bug#6971836
	    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Batch Create Freq Requirement not met. ');

          END IF;

        END LOOP;

        UPDATE ozf_supp_trd_prfls_all
           SET last_paid_date = sysdate
         WHERE supplier_site_id = l_supplier_site_id;

         IF fnd_api.To_Boolean(p_commit) THEN
           COMMIT;
           FND_FILE.PUT_LINE(FND_FILE.LOG, 'Transaction is commited');
           FND_FILE.PUT_LINE(FND_FILE.LOG, ' supplier_site_id= ' || l_supplier_site_id);
           FND_FILE.PUT_LINE(FND_FILE.LOG, ' l_currency= ' || l_currency);
        END IF;

      END LOOP; -- supplier site loop
    END IF; -- end l_supplier site condition

  END create_batch_sub;




-- Start of comments
--	API name        : CREATE_BATCH
--	Type            : Private
--	Pre-reqs        : None.
--	Function        : Creates Batch Header and Batch Lines.
--                        Checks for existance of batch line and batch threshold.
--                        Rollsback header is the above is not met.
--                        Invokes claim api and updates header if Trade Profile for Auto Calim is set
--	Parameters      :
--	IN              :       p_empty_batch      OUT VARCHAR2
--                              p_supplier_id      IN NUMBER                REQUIRED
--                              p_supplier_site_id IN NUMBER                REQUIRED
--                              p_org_id           IN NUMBER                REQUIRED
--                              --p_category_id    IN NUMBER
--                              p_product_id       IN NUMBER
--                              p_request_id       IN NUMBER
--                              p_fund_id          IN NUMBER
--                              p_start_date       IN DATE
--                              p_end_date         IN DATE
--                              p_period           IN VARCHAR2
--                              p_currency_code    IN VARCHAR2              REQUIRED
--                              p_attribute1       IN VARCHAR2
--                              p_attribute2       IN VARCHAR2
--                              p_attribute3       IN VARCHAR2
--                              p_attribute4       IN VARCHAR2
--                              p_attribute5       IN VARCHAR2
--                              p_attribute6       IN VARCHAR2
--                              p_attribute7       IN VARCHAR2
--                              p_attribute8       IN VARCHAR2
--                              p_attribute9       IN VARCHAR2
--                              p_attribute10      IN VARCHAR2
--                              p_attribute11      IN VARCHAR2
--                              p_attribute12      IN VARCHAR2
--                              p_attribute13      IN VARCHAR2
--                              p_attribute14      IN VARCHAR2
--                              p_attribute15      IN VARCHAR2
-- End of comments
  PROCEDURE CREATE_BATCH(p_empty_batch      OUT NOCOPY VARCHAR2,
                         p_supplier_id      IN NUMBER,
                         p_supplier_site_id IN NUMBER,
                         p_org_id           IN NUMBER,
                         --p_category_id    IN NUMBER,
                         p_product_id       IN NUMBER,
                         p_request_id       IN NUMBER,
                         p_fund_id          IN NUMBER,
                         p_start_date       IN DATE,
                         p_end_date         IN DATE,
                         p_period           IN VARCHAR2,
                         p_currency_code    IN VARCHAR2,
                         p_attribute1       IN VARCHAR2 := NULL,
                         p_attribute2       IN VARCHAR2 := NULL,
                         p_attribute3       IN VARCHAR2 := NULL,
                         p_attribute4       IN VARCHAR2 := NULL,
                         p_attribute5       IN VARCHAR2 := NULL,
                         p_attribute6       IN VARCHAR2 := NULL,
                         p_attribute7       IN VARCHAR2 := NULL,
                         p_attribute8       IN VARCHAR2 := NULL,
                         p_attribute9       IN VARCHAR2 := NULL,
                         p_attribute10      IN VARCHAR2 := NULL,
                         p_attribute11      IN VARCHAR2 := NULL,
                         p_attribute12      IN VARCHAR2 := NULL,
                         p_attribute13      IN VARCHAR2 := NULL,
                         p_attribute14      IN VARCHAR2 := NULL,
                         p_attribute15      IN VARCHAR2 := NULL) is

    CURSOR trade_profile_values(c_supplier_site_id NUMBER) IS
      SELECT min_claim_amt, min_claim_amt_line_lvl, auto_debit
        FROM ozf_supp_trd_prfls_all
       WHERE supplier_site_id = c_supplier_site_id;

    l_batch_id         NUMBER;
    l_empty_batch      VARCHAR2(15) := 'Y';
    l_auto_claim       VARCHAR(1) := 'N';

    l_batch_threshold  NUMBER := NULL;
    l_line_threshold   NUMBER := NULL;
    l_currency_code    VARCHAR2(30);

    l_claim_id         NUMBER := NULL;
    l_claim_ret_status VARCHAR2(15) := NULL;
    l_claim_msg_count  NUMBER := NULL;
    l_claim_msg_data   VARCHAR2(500) := NULL;
    l_claim_type       VARCHAR2(20) := 'SUPPLIER';
    l_batch_sum        NUMBER := NULL;
    l_return_status         VARCHAR2(15) := NULL;

    resource_busy EXCEPTION;
    PRAGMA EXCEPTION_INIT (resource_busy, -54);

  BEGIN

    OPEN trade_profile_values(p_supplier_site_id);
    FETCH trade_profile_values
     INTO l_batch_threshold, l_line_threshold, l_auto_claim;
    CLOSE trade_profile_values;

    SAVEPOINT BATCHHEADER;

    IF OZF_DEBUG_LOW_ON THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, '---Start CREATE_BATCH ---');
    END IF;

    CREATE_BATCH_HEADER(p_supplier_id,
                        p_supplier_site_id,
                        p_org_id,
                        l_batch_threshold,
                        l_line_threshold,
                        p_currency_code,
			'N',
			'NEW',
			NULL, --claim_number will be generated in CREATE_BATCH_HEADER
			NULL, --claim_minor_version will be initialized in CREATE_BATCH_HEADER
			NULL, --parent_batch_id will be NULL for a new batch
                        l_batch_id);

    IF OZF_DEBUG_LOW_ON THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,
                        'Invoked CREATE_BATCH_HEADER Successfully. Batch_ID=' ||
                        to_char(l_batch_id));
    END IF;

     --Code added for Bug#6971836
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Batch ' ||to_char(l_batch_id)||' created.');

    CREATE_BATCH_LINES(l_batch_id,
                       p_supplier_id,
                       p_supplier_site_id,
                       p_org_id,
                       l_line_threshold,
                       p_currency_code,
                       --p_category_id,
                       p_product_id,
                       p_request_id,
                       p_fund_id,
                       p_start_date,
                       p_end_date,
                       p_period,
                       l_empty_batch,
                       p_attribute1,
                       p_attribute2,
                       p_attribute3,
                       p_attribute4,
                       p_attribute5,
                       p_attribute6,
                       p_attribute7,
                       p_attribute8,
                       p_attribute9,
                       p_attribute10,
                       p_attribute11,
                       p_attribute12,
                       p_attribute13,
                       p_attribute14,
                       p_attribute15);

    IF OZF_DEBUG_HIGH_ON THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,
                        'Invoked CREATE_BATCH_LINES Successfully. l_empty_batch=' ||
                        to_char(l_empty_batch));
    END IF;


    IF NVL(l_empty_batch, 'Y') = 'N' THEN

	--Code added for Bug#6971836
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Batch Lines created.');

      SELECT sum(batch_curr_claim_amount)
        INTO l_batch_sum
        FROM ozf_sd_batch_lines_all
       WHERE batch_id = l_batch_id;

      -- Check for Batch Amount Threshold

      IF OZF_DEBUG_LOW_ON THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, '--- Check for Batch Amount Threshold ---');
        FND_FILE.PUT_LINE(FND_FILE.LOG,
                          'l_batch_threshold=' ||
                          to_char(l_batch_threshold) || ' :: l_batch_sum=' ||
                          to_char(l_batch_sum));

      END IF;

      IF NVL(l_batch_threshold, l_batch_sum - 1) > l_batch_sum
         AND g_currency IS NOT NULL THEN

        IF OZF_DEBUG_HIGH_ON THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, '---Batch Amount Threshold Violated ---');
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Batch beign Rolledback. Batch_ID = ' ||
                            to_char(l_batch_id));
        END IF;

	 --Code added for Bug#6971836
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Batch Amount Threshold Violated, Batch rolled back.');

        ROLLBACK TO SAVEPOINT BATCHHEADER;
        RETURN;
      END IF;

      UPDATE_AMOUNTS(l_batch_id, l_batch_threshold);

      OZF_SD_UTIL_PVT.SD_RAISE_EVENT(l_batch_id, 'CREATE', l_return_status); -- Raising lifecycle event for create
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.g_exc_error;
      END IF;

    ELSE

      IF OZF_DEBUG_HIGH_ON THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Batch has no lines, Batch id being rolled back. Batch_ID = ' ||
                          to_char(l_batch_id));
      END IF;

      --Code added for Bug#6971836
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Batch has no lines or Line threshold not met '||
      to_char(l_batch_id)||', Batch id being rolled back.' );

      ROLLBACK TO SAVEPOINT BATCHHEADER;
      RETURN;

    END IF;

    -- end transaction

    IF l_auto_claim = 'Y' then

      IF OZF_DEBUG_HIGH_ON THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'AutoClaim Flag : True.');
      END IF;

      UPDATE ozf_sd_batch_headers_all
         SET status_code = 'APPROVED'
       WHERE batch_id = l_batch_id;
      COMMIT;

      IF l_batch_sum > 0 THEN
         IF OZF_DEBUG_HIGH_ON THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Batch Sum > 0 : Invoking Claim API');
         END IF;

       IF OZF_DEBUG_LOW_ON THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Claim API Invoke Start time in create_batch ' || to_char(sysdate,'dd-mm-yyyy hh:mi:ss') );
       END IF;

          OZF_CLAIM_ACCRUAL_PVT.Initiate_SD_Payment(1,
                                                FND_API.g_false,
                                                FND_API.g_true,
                                                FND_API.g_valid_level_full,
                                                l_claim_ret_status,
                                                l_claim_msg_count,
                                                l_claim_msg_data,
                                                l_batch_id,
                                                l_claim_type,
                                                l_claim_id);

     IF OZF_DEBUG_LOW_ON THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Claim API Invoke End time in create_batch ' || to_char(sysdate,'dd-mm-yyyy hh:mi:ss') );
     END IF;

            IF OZF_DEBUG_HIGH_ON THEN
              FND_FILE.PUT_LINE(FND_FILE.LOG, 'Invoked Claim ....' );
              FND_FILE.PUT_LINE(FND_FILE.LOG, '  Batch ID ' || to_char(l_batch_id));
              FND_FILE.PUT_LINE(FND_FILE.LOG, '  Claim ID ' || to_char(l_claim_id) );
	    END IF;

	    IF OZF_ERROR_ON THEN
              FND_FILE.PUT_LINE(FND_FILE.LOG, '  l_claim_ret_status ' || l_claim_ret_status );
              FND_FILE.PUT_LINE(FND_FILE.LOG, '  l_claim_msg_count ' || l_claim_msg_count );
	      FND_FILE.PUT_LINE(FND_FILE.LOG, '  l_claim_msg_data ' ||  l_claim_msg_data );
		 FOR I IN 1..l_claim_msg_count LOOP
			FND_FILE.PUT_LINE(FND_FILE.LOG, '  Msg from Claim API in Batch Create ' ||  SUBSTR(FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F'), 1, 254) );
		END LOOP;
           END IF;

	    IF l_claim_ret_status =  FND_API.G_RET_STS_SUCCESS THEN

	    --Code added for Bug#6971836
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Claim created for batch.');

            UPDATE ozf_sd_batch_headers_all
               SET status_code           = 'CLOSED',
                   claim_id              = l_claim_id,
                   last_update_date      = sysdate,
                   last_updated_by       = FND_GLOBAL.USER_ID,
                   object_version_number = object_version_number + 1
             WHERE batch_id = l_batch_id;
          ELSE
             UPDATE ozf_sd_batch_headers_all
               SET status_code           = 'PENDING_CLAIM',
                   last_update_date      = sysdate,
                   last_updated_by       = FND_GLOBAL.USER_ID,
                   object_version_number = object_version_number + 1
             WHERE batch_id = l_batch_id;

            IF OZF_DEBUG_HIGH_ON THEN
              FND_FILE.PUT_LINE(FND_FILE.LOG,
                    'Claim process returned errors, could not update batch with ID :' || l_batch_id);
            END IF;
	    --Code added for Bug#6971836
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Claim process failed.');
          END IF;

      END IF; --BATCH_SUM > 0


    OZF_SD_UTIL_PVT.SD_RAISE_EVENT(l_batch_id, 'CLAIM', l_return_status); -- Raising lifecycle event for claim
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.g_exc_error;
      END IF;

    END IF; --AUTO_CLAIM TRUE
    p_empty_batch := l_empty_batch;

    EXCEPTION
     WHEN resource_busy THEN

     g_ret_level := 1 ;


     IF OZF_DEBUG_HIGH_ON THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Warning !!!! CREATE_BATCH : Accruals for supplier site : ' || p_supplier_site_id || ' are currently being processed by another request.');
	FND_FILE.PUT_LINE(FND_FILE.LOG, 'Batch_ID : ' || to_char(l_batch_id) || ' is rolled back.' );
     END IF;

     FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Warning !!!! CREATE_BATCH : Accruals for supplier site : ' || p_supplier_site_id || ' are currently being processed by another request.');
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Batch_ID : ' || to_char(l_batch_id) || ' is rolled back.' );

     ROLLBACK TO SAVEPOINT BATCHHEADER;

     -- RAISE;

  END Create_Batch;


-- Start of comments
--	API name        : CREATE_BATCH_HEADER
--	Type            : Private
--	Pre-reqs        : None.
--	Function        : Creates Batch Header record.
--	Parameters      :
--      IN              :       p_supplier_id          NUMBER                  REQUIRED
--                              p_supplier_site_id     NUMBER                  REQUIRED
--                              p_org_id               NUMBER                  REQUIRED
--                              p_batch_threshold      NUMBER                  REQUIRED
--                              p_line_threshold       NUMBER                  REQUIRED
--                              p_batch_currency       VARCHAR2                REQUIRED
--                              p_batch_new            VARCHAR2                REQUIRED
--                              p_batch_status         VARCHAR2                REQUIRED
--                              p_claim_number         VARCHAR2
--                              p_claim_minor_version  IN NUMBER
--                              p_parent_batch_id      NUMBER
--      OUT             :       p_batch_id             NUMBER
-- End of comments
  PROCEDURE CREATE_BATCH_HEADER(p_supplier_id          IN NUMBER,
                                p_supplier_site_id     IN NUMBER,
                                p_org_id               IN NUMBER,
                                p_batch_threshold      IN NUMBER,
                                p_line_threshold       IN NUMBER,
                                p_batch_currency       IN VARCHAR2,
				p_batch_new            IN VARCHAR2,
				p_batch_status         IN VARCHAR2,
				p_claim_number         IN VARCHAR2,
				p_claim_minor_version  IN NUMBER,
				p_parent_batch_id      IN NUMBER,
                                p_batch_id             OUT NOCOPY NUMBER ) is

    l_supplier_id            NUMBER := NULL;
    l_supplier_site_id       NUMBER := NULL;
    l_batch_id               NUMBER := NULL;
    l_org_id                 NUMBER := NULL;
    l_supplier_contact_email VARCHAR2(100) := NULL;
    l_supplier_contact_id    NUMBER := NULL;
    l_supplier_contact_phone VARCHAR2(60) := NULL;
    l_supplier_contact_fax   VARCHAR2(60) := NULL;
    l_batch_threshold        NUMBER := NULL;
    l_line_threshold         NUMBER := NULL;
    l_batch_currency         VARCHAR2(15) := NULL;
    l_supplier_contact_name  VARCHAR2(240) := NULL;
    l_batch_new VARCHAR2(1) := NULL;

    --claim number variables

    l_return_status       VARCHAR2(15) := NULL;
    l_msg_count           NUMBER := NULL;
    l_msg_data            VARCHAR2(100) := NULL;
    l_return_status2      VARCHAR2(15) := NULL;
    l_msg_count2          NUMBER := NULL;
    l_msg_data2           VARCHAR2(100) := NULL;
    l_custom_setup_id     NUMBER := NULL;
    l_claim_rec           OZF_Claim_PVT.claim_rec_type := NULL;
    l_clam_def_rec_type   ozf_claim_def_rule_pvt.clam_def_rec_type := NULL;
    l_claim_number        VARCHAR2(30) := NULL;
    l_claim_minor_version NUMBER := NULL;
    l_split_claim_id      NUMBER := NULL;

    CURSOR get_contact_details(c_supplier_site_id NUMBER) IS
      SELECT cont.vendor_contact_id,
	     decode(cont.last_name,null,null,'','',cont.last_name || ', ') || nvl(cont.middle_name, '')|| ' '|| cont.first_name fullname,
             cont.email_address,
             decode(cont.phone ,NULL, NULL, cont.area_code || '-' || cont.phone) phone,
             decode(cont.fax,NULL, NULL, cont.fax_area_code || '-' || cont.fax) fax
        FROM PO_VENDOR_CONTACTS cont
       WHERE cont.vendor_site_id = c_supplier_site_id
             AND NVL(inactive_date, sysdate+1) > sysdate;

  BEGIN

    l_supplier_id      := p_supplier_id;
    l_supplier_site_id := p_supplier_site_id;
    l_batch_new := p_batch_new;

    SELECT ozf_sd_batch_headers_all_s.nextval INTO l_batch_id FROM dual;

    l_org_id          := p_org_id;
    p_batch_id        := l_batch_id;
    l_batch_threshold := p_batch_threshold;
    l_line_threshold  := p_line_threshold;
    l_batch_currency  := p_batch_currency;

    IF OZF_DEBUG_LOW_ON THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Start CREATE_BATCH_HEADER');
    END IF;

    -- select contact and contact email from suppliers tables
    OPEN get_contact_details(l_supplier_site_id);
    FETCH get_contact_details
      INTO l_supplier_contact_id, l_supplier_contact_name, l_supplier_contact_email, l_supplier_contact_phone, l_supplier_contact_fax;
     CLOSE get_contact_details;

    IF OZF_DEBUG_LOW_ON THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_supplier_contact_id' || to_char(l_supplier_contact_id));
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_supplier_contact_name' || l_supplier_contact_name);
    END IF;

    IF l_batch_new = 'N' THEN
	    l_claim_minor_version := 1;

	    --to get claim number
	    l_claim_rec.claim_class         := 'CLAIM';
	    l_claim_rec.source_object_class := 'SD_SUPPLIER';
	    OZF_CLAIM_DEF_RULE_PVT.get_clam_def_rule(p_claim_rec         => l_claim_rec,
						     x_clam_def_rec_type => l_clam_def_rec_type,
						     x_return_status     => l_return_status,
						     x_msg_count         => l_msg_count,
						     x_msg_data          => l_msg_data);
	    l_custom_setup_id := l_clam_def_rec_type.custom_setup_id;

	    IF OZF_DEBUG_LOW_ON THEN
	      FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_custom_setup_id' || to_char(l_custom_setup_id));
	    END IF;

	    OZF_CLAIM_PVT.Get_Claim_Number(l_split_claim_id,
					   l_custom_setup_id,
					   l_claim_number,
					   l_msg_data2,
					   l_msg_count2,
					   l_return_status2);
    ELSIF l_batch_new = 'F' THEN

	    l_claim_number := p_claim_number ;
	    l_claim_minor_version := p_claim_minor_version;
    END IF;

    IF OZF_DEBUG_HIGH_ON THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Claim Number = ' || to_char(l_claim_number));
    END IF;

    INSERT INTO ozf_sd_batch_headers_all
      (batch_id,
       object_version_number,
       batch_number,
       claim_number,
       claim_minor_version,
       vendor_id,
       vendor_site_id,
       vendor_contact_id,
       vendor_contact_name,
       vendor_email,
       vendor_phone,
       vendor_fax,
       batch_line_amount_threshold,
       batch_amount_threshold,
       currency_code,
       credit_code,
       status_code,
       creation_date,
       last_update_date,
       last_updated_by,
       request_id,
       created_by,
       created_from,
       last_update_login,
       program_application_id,
       program_update_date,
       program_id,
       transfer_type,
       org_id,
       parent_batch_id)
    VALUES
      (l_batch_id,
       1,
       l_batch_id,
       l_claim_number,
       l_claim_minor_version,
       l_supplier_id, --supplier_party_id
       l_supplier_site_id, --supplier site
       l_supplier_contact_id,
       l_supplier_contact_name,
       l_supplier_contact_email,
       l_supplier_contact_phone,
       l_supplier_contact_fax,
       l_batch_threshold, -- From TP
       l_line_threshold, -- From TP
       l_batch_currency, -- From TP
       'D', -- Value can be Debit or Credit. defaulted to Credit
       p_batch_status, --NEW for new batch and APPROVED for child batch
       sysdate,
       sysdate,
       FND_GLOBAL.USER_ID, --las_updated_by
       FND_GLOBAL.CONC_REQUEST_ID, --? conc program id
       FND_GLOBAL.USER_ID, --created by
       null, --created from --??
       FND_GLOBAL.CONC_LOGIN_ID, -- last_update_login
       FND_GLOBAL.PROG_APPL_ID, -- program app id
       sysdate,
       FND_GLOBAL.CONC_PROGRAM_ID, --program id
       null, --l_transfer_type to be updated when batch is exported
       l_org_id, --default batch Org ID
       p_parent_batch_id
       );
   END Create_Batch_Header;

  PROCEDURE CREATE_BATCH_LINES(p_batch_id          IN NUMBER,
                               p_supplier_id       IN NUMBER,
                               p_supplier_site_id  IN NUMBER,
                               p_org_id            IN NUMBER,
                               p_thresh_line_limit IN NUMBER,
                               p_batch_currency    IN VARCHAR2,
                               --p_category_id     IN NUMBER,
                               p_product_id        IN NUMBER,
                               p_request_id        IN NUMBER,
                               p_fund_id           IN NUMBER,
                               p_start_date        IN DATE,
                               p_end_date          IN DATE,
                               p_period            IN VARCHAR2,
                               p_empty_batch       OUT NOCOPY VARCHAR2,
                               p_attribute1        IN VARCHAR2 := NULL,
                               p_attribute2        IN VARCHAR2 := NULL,
                               p_attribute3        IN VARCHAR2 := NULL,
                               p_attribute4        IN VARCHAR2 := NULL,
                               p_attribute5        IN VARCHAR2 := NULL,
                               p_attribute6        IN VARCHAR2 := NULL,
                               p_attribute7        IN VARCHAR2 := NULL,
                               p_attribute8        IN VARCHAR2 := NULL,
                               p_attribute9        IN VARCHAR2 := NULL,
                               p_attribute10       IN VARCHAR2 := NULL,
                               p_attribute11       IN VARCHAR2 := NULL,
                               p_attribute12       IN VARCHAR2 := NULL,
                               p_attribute13       IN VARCHAR2 := NULL,
                               p_attribute14       IN VARCHAR2 := NULL,
                               p_attribute15       IN VARCHAR2 := NULL) is

    l_batch_id                   NUMBER := NULL;
    l_supplier_id                NUMBER := NULL;
    l_supplier_site_id           NUMBER := NULL;
    l_org_id                     NUMBER := NULL;
    l_inv_org_id                 NUMBER := NULL;
    l_count                      NUMBER := 0;

    --for cursor execution
    l_lines_csr                  NUMBER := NULL;
    l_lines_sql                  VARCHAR2(10000) := NULL;
    l_ignore                     NUMBER;

    -- for define columns
    l_batch_line_id              NUMBER := NULL;
    l_batch_line_number          NUMBER := NULL;
    l_utilization_id             NUMBER := NULL;
    l_agreement_number           VARCHAR2(100) := NULL;
    l_ship_to_org_id             NUMBER := NULL;
    l_ship_to_contact_id         NUMBER := NULL;
    l_ship_to_customer_site_id   NUMBER := NULL;
    l_sold_to_customer_id        NUMBER := NULL;
    l_SOLD_TO_CONTACT_ID         NUMBER := NULL;
    l_SOLD_TO_SITE_USE_ID        NUMBER := NULL;
    l_end_customer_id            NUMBER := NULL;
    l_end_customer_contact_id    NUMBER := NULL;
    l_end_customer_site_id       NUMBER := NULL;
    l_order_header_id            NUMBER := NULL;
    l_order_line_number          NUMBER := NULL;
    l_invoice_number             NUMBER := NULL;
    l_invoice_line_number        NUMBER := NULL;
    l_resale_price_currency_code VARCHAR2(15) := NULL;
    l_resales_price              NUMBER := NULL;
    l_list_price_currency_code   VARCHAR2(15) := NULL;
    l_list_price                 NUMBER := NULL;
    l_agreement_currency_code    VARCHAR2(15) := NULL;
    l_agreement_price            NUMBER := NULL;

    l_claim_amount               NUMBER := NULL;
    l_batch_curr_claim_amount    NUMBER := NULL;

    l_orig_claim_amount               NUMBER := NULL;
    l_batch_curr_orig_claim_amount    NUMBER := NULL;

    l_item_id                    NUMBER := NULL;
    l_vendor_item_id             NUMBER := NULL;
    l_shipped_quantity_uom       VARCHAR2(100) := NULL;
    l_quantity_shipped           NUMBER := NULL;
    l_order_date                 DATE := NULL;
    l_claim_amount_currency_code VARCHAR2(15) := NULL;
    l_acct_amount_remaining      NUMBER := NULL;
    l_univ_curr_amount_remaining NUMBER := NULL;
    l_fund_req_amount_remaining  NUMBER := NULL;
    l_amount_remaining           NUMBER := NULL;
    l_ozf_gl_entries             VARCHAR2(15) := NULL;
    l_approved_discount_type     VARCHAR2(30) := NULL;
    l_approved_discount_value    NUMBER := NULL;
    l_approved_discount_currency VARCHAR2(15) := NULL;
    l_adjustment_type_id         NUMBER := NULL;

    --from trade profile
    l_thresh_line_limit          NUMBER := NULL;
    l_batch_currency             VARCHAR2(15) := NULL;

    --parameters
    l_fund_id                    NUMBER := NULL;
    l_start_date                 DATE;
    l_end_date                   DATE := NULL;
    l_period                     VARCHAR2(50) := NULL;
    l_period_start               DATE := NULL;
    l_period_end                 DATE := NULL;
    l_func_call_string           VARCHAR2(2000) := NULL;
    l_cost_price_string          VARCHAR2(2000) := NULL;
    l_rounded_cost_price         VARCHAR2(2000) := NULL;
    l_agmt_price_string          VARCHAR2(2000) := NULL;
    l_shipped_qty_string         VARCHAR2(2000) := NULL;

    -- to get functional currency
    l_func_currency              VARCHAR2(15)   := NULL;
    l_date                       DATE;

    resource_busy EXCEPTION;
    PRAGMA EXCEPTION_INIT (resource_busy, -54);

    --cursor for period param
    CURSOR get_period_limits(c_period VARCHAR2) IS
      SELECT start_date, end_date
        FROM gl_periods
       WHERE period_name = c_period and
             period_set_name =
             fnd_profile.value('AMS_CAMPAIGN_DEFAULT_CALENDER');

  BEGIN
    l_batch_id          := p_batch_id;
    l_org_id            := p_org_id;
    l_thresh_line_limit := p_thresh_line_limit;
    l_batch_currency    := p_batch_currency;

    l_fund_id           := p_fund_id;
    l_start_date        := p_start_date;
    l_end_date          := p_end_date;
    l_period            := p_period;
    l_ozf_gl_entries    := fnd_profile.value('OZF_ORDER_GLPOST_PHASE');
    l_date              := sysdate;

    IF l_ozf_gl_entries is null then
      l_ozf_gl_entries := 'SHIPPED';
    END IF;

    SELECT gs.currency_code
      INTO l_func_currency
      FROM gl_sets_of_books gs,
	   ozf_sys_parameters_all org,
	   ozf_sd_batch_headers_all bh
     WHERE org.set_of_books_id = gs.set_of_books_id
       AND org.org_id = bh.org_id
       AND bh.batch_id = p_batch_id;

    FND_DSQL.init;

    FND_DSQL.add_text('SELECT ');
    FND_DSQL.add_text('OZF_SD_BATCH_LINES_ALL_S.NEXTVAL  ,   ');
    FND_DSQL.add_text('FU.UTILIZATION_ID,  ');
    FND_DSQL.add_text('RH.AUTHORIZATION_NUMBER, ');
    FND_DSQL.add_text('OEL.SHIP_TO_ORG_ID, ');
    FND_DSQL.add_text('OEL.SHIP_TO_CONTACT_ID, ');
    FND_DSQL.add_text('HZCA.PARTY_ID, ');
    FND_DSQL.add_text('OEH.SOLD_TO_CONTACT_ID, ');
    FND_DSQL.add_text('OEH.SOLD_TO_SITE_USE_ID, ');

    FND_DSQL.add_text('OEL.END_CUSTOMER_ID, ');
    FND_DSQL.add_text('OEL.END_CUSTOMER_CONTACT_ID, ');


    FND_DSQL.add_text('OEL.HEADER_ID, ');
    FND_DSQL.add_text('OEL.LINE_ID, ');


    FND_DSQL.add_text('(SELECT CTLA.CUSTOMER_TRX_ID FROM RA_CUSTOMER_TRX_LINES_ALL CTLA
                         WHERE CTLA.INTERFACE_LINE_ATTRIBUTE6 = TO_CHAR(OEL.LINE_ID)
                           AND CTLA.LINE_TYPE = ''LINE''
			   AND CTLA.INTERFACE_LINE_CONTEXT = ''ORDER ENTRY''
                           AND ROWNUM = 1) TRX_NUMBER,');

    FND_DSQL.add_text('(SELECT CTLA.CUSTOMER_TRX_LINE_ID FROM RA_CUSTOMER_TRX_LINES_ALL CTLA
                         WHERE CTLA.INTERFACE_LINE_ATTRIBUTE6 = TO_CHAR(OEL.LINE_ID)
			   AND CTLA.LINE_TYPE = ''LINE''
			   AND CTLA.INTERFACE_LINE_CONTEXT = ''ORDER ENTRY''
                           AND ROWNUM = 1) LINE_NUMBER, ');

    --Compute Resale Price
    FND_DSQL.add_text('OEH.TRANSACTIONAL_CURR_CODE, ');
    FND_DSQL.add_text('OEL.UNIT_SELLING_PRICE, ');

    --Compute cost price
    FND_DSQL.add_text('DECODE(RL.APPROVED_DISCOUNT_TYPE,  ''AMT'', null, FU.PLAN_CURRENCY_CODE), ');

    -- Call CONV_DISC_TO_OFFER_CURR_AMOUNT where
    --  To Currency            OFRS CURRENCY_CODE
    --  From Currency          RL. APPROVED_DISCOUNT_CURRENCY
    --  From Amount            RL.APPROVED_DISCOUNT_VALUE
    --	Batch ID	       p_batch_id

    l_func_call_string := 'OZF_SD_BATCH_PVT.CONV_DISC_TO_OFFER_CURR_AMOUNT(FU.PLAN_CURRENCY_CODE ,RL.APPROVED_DISCOUNT_CURRENCY, RL.APPROVED_DISCOUNT_VALUE, QPLL.CREATION_DATE )' ;
	l_shipped_qty_string := 'DECODE(OEL.LINE_CATEGORY_CODE, ''RETURN'' , -1 * abs(NVL(oel.shipped_quantity, NVL(oel.invoiced_quantity, NVL(oel.ordered_quantity, 1)))) ,
	                                        NVL(oel.shipped_quantity, NVL(oel.invoiced_quantity, NVL(oel.ordered_quantity, 1))) ) ' ;

    IF l_ozf_gl_entries = 'SHIPPED' then
       l_cost_price_string:= ('decode (RL.APPROVED_DISCOUNT_TYPE,
          ''%'', ( FU.PLAN_CURR_AMOUNT_REMAINING/' || l_shipped_qty_string || '  * (100/qpll.OPERAND) ),
          ''AMT'', null,
          ''NEWPRICE'', '||  l_func_call_string ||' + FU.PLAN_CURR_AMOUNT_REMAINING/ ' || l_shipped_qty_string || '	  )  ');
    END IF;

    IF l_ozf_gl_entries = 'INVOICED' then
       l_cost_price_string:= ('decode (RL.APPROVED_DISCOUNT_TYPE,
          ''%'', ( FU.PLAN_CURR_AMOUNT_REMAINING/NVL(oel.invoiced_quantity, NVL('|| l_shipped_qty_string ||',1))  * (100/qpll.OPERAND) ),
          ''AMT'', null,
          ''NEWPRICE'', '||  l_func_call_string ||' + FU.PLAN_CURR_AMOUNT_REMAINING/NVL(oel.invoiced_quantity, NVL('|| l_shipped_qty_string || ' , 1))	  )  ');
    END IF;

    l_rounded_cost_price:= 'OZF_SD_BATCH_PVT.CURR_ROUND_EXT_PREC('||l_cost_price_string||',FU.PLAN_CURRENCY_CODE)';

    FND_DSQL.add_text(l_rounded_cost_price || 'COST_PRICE' );

    FND_DSQL.add_text(', DECODE(RL.APPROVED_DISCOUNT_TYPE,  ''AMT'', null, FU.PLAN_CURRENCY_CODE), ');

       l_agmt_price_string:= ('decode (rl.APPROVED_DISCOUNT_TYPE,
        ''%'', ('|| l_cost_price_string ||' * (1 - qpll.OPERAND/100)),
        ''AMT'', null,
        ''NEWPRICE'', '|| l_func_call_string || ', ' ||
        l_func_call_string || ') ');

    l_agmt_price_string:= 'OZF_SD_BATCH_PVT.CURR_ROUND_EXT_PREC('||l_agmt_price_string||', FU.PLAN_CURRENCY_CODE)';

    FND_DSQL.add_text(l_agmt_price_string || 'APPROVED_DISCOUNT_VALUE' );

    FND_DSQL.add_text(', FU.PLAN_CURR_AMOUNT_REMAINING, '); -- for claim_amount

    FND_DSQL.add_text(' CASE WHEN (FU.PLAN_CURRENCY_CODE = ');
    FND_DSQL.add_bind(''||p_batch_currency||'' );
    FND_DSQL.add_text(' ) THEN FU.PLAN_CURR_AMOUNT_REMAINING  WHEN (');
    FND_DSQL.add_bind(''||l_func_currency||'' );
    FND_DSQL.add_text('=');
    FND_DSQL.add_bind(''||p_batch_currency||'' );
    FND_DSQL.add_text(' ) THEN FU.ACCTD_AMOUNT_REMAINING  ELSE  OZF_SD_BATCH_PVT.GET_BATCH_CURRENCY_AMOUNT(');
    FND_DSQL.add_bind(''||l_func_currency||'' );
    FND_DSQL.add_text(',');
    FND_DSQL.add_bind(''||p_batch_currency||'' );
    FND_DSQL.add_text(', FU.ACCTD_AMOUNT_REMAINING, FU.EXCHANGE_RATE_TYPE, NULL,');
    FND_DSQL.add_bind(''||l_date||'' );
    FND_DSQL.add_text(') END BATCH_CURR_CLAIM_AMOUNT '); --for batch_curr_claim_amount

    FND_DSQL.add_text(', FU.PRODUCT_ID, ');

    FND_DSQL.add_text('NVL(OEL.SHIPPING_QUANTITY_UOM, OEL.ORDER_QUANTITY_UOM), ');

    IF l_ozf_gl_entries = 'SHIPPED' THEN
	--If accrual is negative for shipped profile, set the quantity as negative. This is required for RMA orders
         FND_DSQL.add_text(l_shipped_qty_string || ' , ');
    END IF;

    IF l_ozf_gl_entries = 'INVOICED' THEN
      FND_DSQL.add_text('NVL(oel.invoiced_quantity, NVL('|| l_shipped_qty_string || ' ,1)), ');
    END IF;

    FND_DSQL.add_text('OEH.ordered_date, ');

    FND_DSQL.add_text('FU.PLAN_CURRENCY_CODE, ');
    FND_DSQL.add_text('FU.ACCTD_AMOUNT_REMAINING, ');
    FND_DSQL.add_text('FU.UNIV_CURR_AMOUNT_REMAINING, ');
    FND_DSQL.add_text('FU.FUND_REQUEST_AMOUNT_REMAINING, ');
    FND_DSQL.add_text('FU.AMOUNT_REMAINING, ');
    FND_DSQL.add_text('RL.ORG_ID, ');
    FND_DSQL.add_text('RL.APPROVED_DISCOUNT_TYPE, ');

    --if % or Amount use qpll.operand, for NewPrice use rounded agreeement price.
    FND_DSQL.add_text('DECODE(RL.APPROVED_DISCOUNT_TYPE,
          ''NEWPRICE'', ' || l_agmt_price_string || ', ' || 'qpll.operand ) APPROVED_DISCOUNT_VALUE, ');

    FND_DSQL.add_text('FU.PLAN_CURRENCY_CODE, ');
    FND_DSQL.add_text('ospa.SSD_DEC_ADJ_TYPE_ID ');

    --BEGIN FROM CLAUSE
    FND_DSQL.add_text('FROM OZF_FUNDS_UTILIZED_ALL_B FU,  ');
    FND_DSQL.add_text('OE_ORDER_HEADERS_ALL OEH,  ');
    FND_DSQL.add_text('OE_ORDER_LINES_ALL OEL,  ');
    FND_DSQL.add_text('OZF_SD_REQUEST_HEADERS_ALL_B RH,   ');
    FND_DSQL.add_text('OZF_SD_REQUEST_LINES_ALL RL ,   ');

    FND_DSQL.add_text('HZ_CUST_SITE_USES_ALL HZCSU,   ');
    FND_DSQL.add_text('HZ_CUST_ACCT_SITES_ALL HZCAS,   ');
    FND_DSQL.add_text('HZ_CUST_ACCOUNTS HZCA,   ');
    FND_DSQL.add_text('QP_LIST_HEADERS_B qplh, ');
    FND_DSQL.add_text('QP_LIST_LINES qpll, ');
    FND_DSQL.add_text('OZF_SYS_PARAMETERS_ALL ospa ');

    --BEGIN WHERE CLAUSE
    FND_DSQL.add_text('WHERE qplh.LIST_HEADER_ID = FU.PLAN_ID AND  ');
    FND_DSQL.add_text('qplh.LIST_HEADER_ID = qpll.LIST_HEADER_ID AND ');
    FND_DSQL.add_text('qplh.LIST_HEADER_ID = RH.OFFER_ID AND ');
    FND_DSQL.add_text('qpll.LIST_LINE_NO = RL.REQUEST_LINE_ID AND ');

    FND_DSQL.add_text('FU.AMOUNT_REMAINING <> 0 AND ');
    FND_DSQL.add_text('FU.PLAN_TYPE = ''OFFR'' AND  ');
    FND_DSQL.add_text('OEL.HEADER_ID = OEH.HEADER_ID AND  ');
    FND_DSQL.add_text('RH.REQUEST_HEADER_ID = RL.REQUEST_HEADER_ID AND  ');

    FND_DSQL.add_text('RH.SUPPLIER_SITE_ID = ' );
    FND_DSQL.add_bind(p_supplier_site_id);
    FND_DSQL.add_text(' AND RH.ORG_ID = ' );
    FND_DSQL.add_bind(l_org_id);

    FND_DSQL.add_text(' AND ospa.ORG_ID = ' );
    FND_DSQL.add_bind(l_org_id);

    FND_DSQL.add_text(' AND OEH.invoice_to_org_id = HZCSU.SITE_USE_ID AND ');
    FND_DSQL.add_text('HZCSU.CUST_ACCT_SITE_ID = HZCAS.CUST_ACCT_SITE_ID AND ');
    FND_DSQL.add_text('HZCAS.CUST_ACCOUNT_ID = HZCA.CUST_ACCOUNT_ID AND ');

    FND_DSQL.add_text('((FU.PRODUCT_ID = RL.INVENTORY_ITEM_ID )  OR  ');

 /*   FND_DSQL.add_text('FU.PRODUCT_ID IN
  (SELECT MIC.INVENTORY_ITEM_ID
   FROM MTL_ITEM_CATEGORIES MIC,
        ENI_PROD_DEN_HRCHY_PARENTS_V P,
        ENI_PROD_DENORM_HRCHY_V H,
        MTL_SYSTEM_ITEMS_B_KFV B
   WHERE P.CATEGORY_ID = MIC.CATEGORY_ID AND
         MIC.ORGANIZATION_ID = B.ORGANIZATION_ID AND
         P.CATEGORY_SET_ID = MIC.CATEGORY_SET_ID AND
         MIC.CATEGORY_SET_ID = H.CATEGORY_SET_ID AND
         MIC.CATEGORY_ID = H.CHILD_ID AND
	 (P.DISABLE_DATE is null OR P.DISABLE_DATE > SYSDATE)
         AND
         H.PARENT_ID = RL.prod_catg_id )) AND  '); */

    FND_DSQL.add_text('EXISTS
                      (SELECT ''X''
                       FROM OE_PRICE_ADJUSTMENTS
                       WHERE PRICE_ADJUSTMENT_ID = FU.PRICE_ADJUSTMENT_ID
                       AND LIST_LINE_ID = QPLL.LIST_LINE_ID )) AND  ');

    FND_DSQL.add_text('FU.ORDER_LINE_ID = OEL.LINE_ID AND  ');
    FND_DSQL.add_text('FU.GL_POSTED_FLAG = ''Y'' AND  ');

    IF l_ozf_gl_entries = 'SHIPPED' THEN
      FND_DSQL.add_text('oel.cancelled_flag = ''N'' AND  oel.booked_flag = ''Y'' AND ');
    END IF;

    IF l_ozf_gl_entries = 'INVOICED' THEN
      FND_DSQL.add_text('oel.cancelled_flag = ''N'' AND  oel.booked_flag = ''Y'' AND  oel.flow_status_code in (''CLOSED'',''INVOICED'') AND ');
    END IF;

    FND_DSQL.add_text(' RH.OFFER_TYPE= ''ACCRUAL''   ');
    --  FND_DSQL.add_text(' RL.ORG_ID =' || l_org_id); -- AND  ');  --this was commented already

    IF g_currency IS NULL THEN
      -- currency not set on trade profile
          FND_DSQL.add_text(' AND RH.REQUEST_CURRENCY_CODE = ' );
	  FND_DSQL.add_bind('' || l_batch_currency || '');
    END IF;

    --request ID filter
    IF p_request_id is not null then
        FND_DSQL.add_text(' AND RH.REQUEST_HEADER_ID = '  );
        FND_DSQL.add_bind(p_request_id);
    END IF;

    --product filter
    IF p_product_id is not null then
         FND_DSQL.add_text(' AND FU.PRODUCT_ID = '  );
	 FND_DSQL.add_bind(p_product_id);
    END IF;

    -- offer filter
    IF p_fund_id is not null then
         FND_DSQL.add_text(' AND FU.fund_id = '  );
	 FND_DSQL.add_bind(p_fund_id);
    END IF;

    --start date filter
    IF p_start_date is not null then
         FND_DSQL.add_text(' AND FU.creation_date >=' );
	 FND_DSQL.add_bind('' || p_start_date || '');
    END IF;

    --end date filter
    IF p_end_date is not null then
         FND_DSQL.add_text(' AND FU.creation_date <=' );
	 FND_DSQL.add_bind('' || p_end_date || '');
    END IF;

    --period filter
    IF p_period is not null then
      open get_period_limits(p_period);
      FETCH get_period_limits
        INTO l_period_start, l_period_end;
      CLOSE get_period_limits;

	 IF l_period_start is not null then
             FND_DSQL.add_text(' AND FU.creation_date >= ');
	     FND_DSQL.add_bind(''||to_date(to_char(l_period_start,'DD-MM-YYYY'),'DD-MM-YYYY')||'');
	 END IF;

	 IF l_period_end is not null then
	     FND_DSQL.add_text(' AND FU.creation_date <= ');
	     FND_DSQL.add_bind(''||to_date(to_char(l_period_end,'DD-MM-YYYY'),'DD-MM-YYYY')||'');
	 END IF;

    END IF;

    -- attribute1 filter
    IF p_attribute1 is not null then
         FND_DSQL.add_text(' AND FU.ATTRIBUTE1 =' );
	 FND_DSQL.add_bind('' || p_attribute1 || '');
    END IF;

    -- attribute2 filter
    IF p_attribute2 is not null then
         FND_DSQL.add_text(' AND FU.ATTRIBUTE2 =' );
	 FND_DSQL.add_bind('' || p_attribute2 || '');
    END IF;

    -- attribute3 filter
    IF p_attribute3 is not null then
         FND_DSQL.add_text(' AND FU.ATTRIBUTE3 =' );
	 FND_DSQL.add_bind('' || p_attribute3 || '');
    END IF;

    -- attribute4 filter
    IF p_attribute4 is not null then
         FND_DSQL.add_text(' AND FU.ATTRIBUTE4 =' );
	 FND_DSQL.add_bind('' || p_attribute4 || '');
    END IF;

    -- attribute5 filter
    IF p_attribute5 is not null then
         FND_DSQL.add_text(' AND FU.ATTRIBUTE5 =' );
	 FND_DSQL.add_bind('' || p_attribute5 || '');
    END IF;

    -- attribute6 filter
    IF p_attribute6 is not null then
        FND_DSQL.add_text(' AND FU.ATTRIBUTE6 =' );
	FND_DSQL.add_bind('' || p_attribute6 || '');
    END IF;

    -- attribute7 filter
    IF p_attribute7 is not null then
         FND_DSQL.add_text(' AND FU.ATTRIBUTE7 =' );
         FND_DSQL.add_bind('' || p_attribute7 || '');
    END IF;

    -- attribute8 filter
    IF p_attribute8 is not null then
         FND_DSQL.add_text(' AND FU.ATTRIBUTE8 =' );
	 FND_DSQL.add_bind('' || p_attribute8 || '');
    END IF;

    -- attribute9 filter
    IF p_attribute9 is not null then
         FND_DSQL.add_text(' AND FU.ATTRIBUTE9 =' );
	 FND_DSQL.add_bind('' || p_attribute9 || '');
    END IF;

    -- attribute10 filter
    IF p_attribute10 is not null then
         FND_DSQL.add_text(' AND FU.ATTRIBUTE10 =' );
	 FND_DSQL.add_bind('' || p_attribute10 || '');
    END IF;

    -- attribute11 filter
    IF p_attribute11 is not null then
         FND_DSQL.add_text(' AND FU.ATTRIBUTE11 =' );
	 FND_DSQL.add_bind('' || p_attribute11 || '');
    END IF;

    -- attribute12 filter
    IF p_attribute12 is not null then
         FND_DSQL.add_text(' AND FU.ATTRIBUTE12 =' );
	 FND_DSQL.add_bind('' || p_attribute12 || '');
    END IF;

    -- attribute13 filter
    IF p_attribute13 is not null then
         FND_DSQL.add_text(' AND FU.ATTRIBUTE13 =' );
	 FND_DSQL.add_bind('' || p_attribute13 || '');
    END IF;

    -- attribute14 filter
    IF p_attribute14 is not null then
         FND_DSQL.add_text(' AND FU.ATTRIBUTE14 =' );
	 FND_DSQL.add_bind('' || p_attribute14 || '');
    END IF;

    -- attribute15 filter
    IF p_attribute15 is not null then
         FND_DSQL.add_text(' AND FU.ATTRIBUTE15 =' );
	 FND_DSQL.add_bind('' || p_attribute15 || '');
    END IF;


         FND_DSQL.add_text(' FOR UPDATE OF FU.PLAN_CURR_AMOUNT_REMAINING NOWAIT' );


    --creating cursor
    l_lines_csr := DBMS_SQL.open_cursor;
    l_lines_sql := FND_DSQL.get_text(FALSE); -- Get SQL query built above

    IF OZF_DEBUG_LOW_ON THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, '---Start Query Text ---');
      FND_FILE.PUT_LINE(FND_FILE.LOG,' l_lines_sql = ' || l_lines_sql);
      FND_FILE.PUT_LINE(FND_FILE.LOG, '---End Query Text ---');
    END IF;

    IF OZF_DEBUG_LOW_ON THEN
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '--- Values for Binds ---' );
	  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' p_batch_currency = '  ||  p_batch_currency || ' p_batch_id = ' || p_batch_id || ' p_supplier_site_id = '  ||  p_supplier_site_id || ' l_org_id = ' || l_org_id );
	  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' l_batch_currency = '  ||  l_batch_currency || ' p_request_id = ' || p_request_id || ' p_product_id = '  ||  p_product_id || ' p_fund_id = ' || p_fund_id );
	  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' p_start_date = '  ||  p_start_date || ' p_end_date = ' || p_end_date || ' l_period_start = '  ||  l_period_start || ' l_period_end = ' || l_period_end );
	  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' p_attribute1 = '  ||  p_attribute1 || ' p_attribute2 = ' || p_attribute2 || ' p_attribute3 = ' || p_attribute3  || ' p_attribute4 = ' || p_attribute4 || ' p_attribute5 = ' || p_attribute5 );
	  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' p_attribute6 = '  || p_attribute6  || ' p_attribute7 = ' || p_attribute7 || ' p_attribute8 = ' || p_attribute8 || ' p_attribute9 = ' || p_attribute9 || ' p_attribute10 = ' || p_attribute10 );
	  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' p_attribute11 = ' || p_attribute11 || ' p_attribute12 = ' || p_attribute12 || ' p_attribute13 = ' || p_attribute13 || ' p_attribute14 = ' || p_attribute14 || ' p_attribute15 = ' || p_attribute15 );
    END IF;

    IF OZF_DEBUG_LOW_ON THEN
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' --Start Query Text--');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' l_lines_sql = ' || l_lines_sql);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' --End Query Text --');
    END IF;

    FND_DSQL.set_cursor(l_lines_csr);
    DBMS_SQL.parse(l_lines_csr, l_lines_sql, DBMS_SQL.native);
    FND_DSQL.do_binds;

    --define columns

    DBMS_SQL.define_column(l_lines_csr, 1, l_batch_line_id);
    DBMS_SQL.define_column(l_lines_csr, 2, l_utilization_id);
    DBMS_SQL.define_column(l_lines_csr, 3, l_agreement_number, 100);
    DBMS_SQL.define_column(l_lines_csr, 4, l_ship_to_org_id);
    DBMS_SQL.define_column(l_lines_csr, 5, l_ship_to_contact_id);

    DBMS_SQL.define_column(l_lines_csr, 6, l_sold_to_customer_id);
    DBMS_SQL.define_column(l_lines_csr, 7, l_SOLD_TO_CONTACT_ID);
    DBMS_SQL.define_column(l_lines_csr, 8, l_SOLD_TO_SITE_USE_ID);
    DBMS_SQL.define_column(l_lines_csr, 9, l_end_customer_id);
    DBMS_SQL.define_column(l_lines_csr, 10, l_end_customer_contact_id);

    DBMS_SQL.define_column(l_lines_csr, 11, l_order_header_id);
    DBMS_SQL.define_column(l_lines_csr, 12, l_order_line_number);

    DBMS_SQL.define_column(l_lines_csr, 13, l_invoice_number);
    DBMS_SQL.define_column(l_lines_csr, 14, l_invoice_line_number);

    DBMS_SQL.define_column(l_lines_csr, 15, l_resale_price_currency_code, 15);
    DBMS_SQL.define_column(l_lines_csr, 16, l_resales_price);
    DBMS_SQL.define_column(l_lines_csr, 17, l_list_price_currency_code, 15);
    DBMS_SQL.define_column(l_lines_csr, 18, l_list_price);
    DBMS_SQL.define_column(l_lines_csr, 19, l_agreement_currency_code, 15);
    DBMS_SQL.define_column(l_lines_csr, 20, l_agreement_price);
    DBMS_SQL.define_column(l_lines_csr, 21, l_claim_amount);
    DBMS_SQL.define_column(l_lines_csr, 22, l_batch_curr_claim_amount);
    DBMS_SQL.define_column(l_lines_csr, 23, l_item_id);

    DBMS_SQL.define_column(l_lines_csr, 24, l_shipped_quantity_uom, 100);
    DBMS_SQL.define_column(l_lines_csr, 25, l_quantity_shipped);
    DBMS_SQL.define_column(l_lines_csr, 26, l_order_date);
    DBMS_SQL.define_column(l_lines_csr, 27, l_claim_amount_currency_code, 15);
    DBMS_SQL.define_column(l_lines_csr, 28, l_acct_amount_remaining);
    DBMS_SQL.define_column(l_lines_csr, 29, l_univ_curr_amount_remaining);
    DBMS_SQL.define_column(l_lines_csr, 30, l_fund_req_amount_remaining);
    DBMS_SQL.define_column(l_lines_csr, 31, l_amount_remaining);
    DBMS_SQL.define_column(l_lines_csr, 32, l_inv_org_id);

    DBMS_SQL.define_column(l_lines_csr, 33, l_approved_discount_type,30);
    DBMS_SQL.define_column(l_lines_csr, 34, l_approved_discount_value);
    DBMS_SQL.define_column(l_lines_csr, 35, l_approved_discount_currency,15);
    DBMS_SQL.define_column(l_lines_csr, 36, l_adjustment_type_id);

    --execute cursor

    IF OZF_DEBUG_LOW_ON THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Cursor Execute Start time' || to_char(sysdate,'dd-mm-yyyy hh:mi:ss') );
    END IF;

    l_ignore            := DBMS_SQL.execute(l_lines_csr);

    IF OZF_DEBUG_LOW_ON THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Cursor Execute End time' || to_char(sysdate,'dd-mm-yyyy hh:mi:ss') );
    END IF;

    p_empty_batch       := 'Y'; -- to check if any lines were created
    l_batch_line_number := 1;

    LOOP

      IF OZF_DEBUG_LOW_ON THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'DBMS_SQL.FETCH_ROWS loop - Before Fetch');
      END IF;

      EXIT WHEN DBMS_SQL.FETCH_ROWS(l_lines_csr) = 0;

      IF OZF_DEBUG_HIGH_ON THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'DBMS_SQL.FETCH_ROWS loop - After Fetch');
      END IF;

      DBMS_SQL.column_value(l_lines_csr, 1, l_batch_line_id);
      DBMS_SQL.column_value(l_lines_csr, 2, l_utilization_id);
      DBMS_SQL.column_value(l_lines_csr, 3, l_agreement_number);
      DBMS_SQL.column_value(l_lines_csr, 4, l_ship_to_org_id);
      DBMS_SQL.column_value(l_lines_csr, 5, l_ship_to_contact_id);

      DBMS_SQL.column_value(l_lines_csr, 6, l_sold_to_customer_id);
      DBMS_SQL.column_value(l_lines_csr, 7, l_SOLD_TO_CONTACT_ID);
      DBMS_SQL.column_value(l_lines_csr, 8, l_SOLD_TO_SITE_USE_ID);
      DBMS_SQL.column_value(l_lines_csr, 9, l_end_customer_id);
      DBMS_SQL.column_value(l_lines_csr, 10, l_end_customer_contact_id);

      DBMS_SQL.column_value(l_lines_csr, 11, l_order_header_id);
      DBMS_SQL.column_value(l_lines_csr, 12, l_order_line_number);

      DBMS_SQL.column_value(l_lines_csr, 13, l_invoice_number);
      DBMS_SQL.column_value(l_lines_csr, 14, l_invoice_line_number);
      DBMS_SQL.column_value(l_lines_csr, 15, l_resale_price_currency_code);
      DBMS_SQL.column_value(l_lines_csr, 16, l_resales_price);
      DBMS_SQL.column_value(l_lines_csr, 17, l_list_price_currency_code);
      DBMS_SQL.column_value(l_lines_csr, 18, l_list_price);
      DBMS_SQL.column_value(l_lines_csr, 19, l_agreement_currency_code);
      DBMS_SQL.column_value(l_lines_csr, 20, l_agreement_price);
      DBMS_SQL.column_value(l_lines_csr, 21, l_claim_amount);
      DBMS_SQL.column_value(l_lines_csr, 22, l_batch_curr_claim_amount);
      DBMS_SQL.column_value(l_lines_csr, 23, l_item_id);

      DBMS_SQL.column_value(l_lines_csr, 24, l_shipped_quantity_uom);
      DBMS_SQL.column_value(l_lines_csr, 25, l_quantity_shipped);
      DBMS_SQL.column_value(l_lines_csr, 26, l_order_date);
      DBMS_SQL.column_value(l_lines_csr, 27, l_claim_amount_currency_code);
      DBMS_SQL.column_value(l_lines_csr, 28, l_acct_amount_remaining);
      DBMS_SQL.column_value(l_lines_csr, 29, l_univ_curr_amount_remaining);
      DBMS_SQL.column_value(l_lines_csr, 30, l_fund_req_amount_remaining);
      DBMS_SQL.column_value(l_lines_csr, 31, l_amount_remaining);
      DBMS_SQL.column_value(l_lines_csr, 32, l_inv_org_id);
      DBMS_SQL.column_value(l_lines_csr, 33, l_approved_discount_type);
      DBMS_SQL.column_value(l_lines_csr, 34, l_approved_discount_value);
      DBMS_SQL.column_value(l_lines_csr, 35, l_approved_discount_currency);
      DBMS_SQL.column_value(l_lines_csr, 36, l_adjustment_type_id);

      IF OZF_DEBUG_HIGH_ON THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, '--- Check for Line Amount Threshold ---');
	FND_FILE.PUT_LINE(FND_FILE.LOG,
                          'l_thresh_line_limit = ' ||
                          to_char(l_thresh_line_limit) ||
                          'claim amount: = ' ||
                          to_char(l_batch_curr_claim_amount));
      END IF;
      IF ( nvl(l_thresh_line_limit, l_batch_curr_claim_amount - 1) <
         l_batch_curr_claim_amount AND
	 g_currency IS NOT NULL ) OR
	 g_currency IS NULL OR
	 l_batch_curr_claim_amount < 0 THEN

	p_empty_batch := 'N';
        IF OZF_DEBUG_LOW_ON THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG,
                            '--- Values fetched for Batch Line ---');
          FND_FILE.PUT_LINE(FND_FILE.LOG,
                            'values being fetched from SQL' ||
                            to_char(l_batch_line_id) || '*' || -- line sequence.nextval
                            to_char(1) || '*' || to_char(l_batch_id) || '*' ||
                            to_char(l_batch_line_number) || '*' ||
                            to_char(l_utilization_id) || '*' ||
                            to_char(l_agreement_number) || '*' ||
                            to_char(l_ship_to_org_id) || '*' ||
                            to_char(l_ship_to_contact_id) || '*' ||
                            to_char(l_sold_to_customer_id) || '*' ||
                            to_char(l_SOLD_TO_CONTACT_ID) || '*' ||
                            to_char(l_SOLD_TO_SITE_USE_ID) || '*' ||
                            to_char(l_end_customer_id) || '*' ||
                            to_char(l_end_customer_contact_id) || '*' ||

			    to_char(l_order_header_id) || '*' ||
                            to_char(l_order_line_number) || '*' ||

			    to_char(l_invoice_number) || '*' ||
                            to_char(l_invoice_line_number) || '*' ||
                            to_char(l_resale_price_currency_code) || '*' ||
                            to_char(l_resales_price) || '*' ||
                            to_char(l_list_price_currency_code) || '*' ||
                            to_char(l_list_price) || '*' ||
                            to_char(l_agreement_currency_code) || '*' ||
                            to_char(l_agreement_price) || '*' ||
                            to_char('NEW') || '*' || -- status is 'new'

                            to_char(l_claim_amount) || '*' ||
                            to_char(l_batch_curr_claim_amount) || '*' ||
			    to_char(l_item_id) || '*' ||
                            to_char(l_batch_curr_claim_amount) || '*' ||
                            to_char(l_shipped_quantity_uom) || '*' ||
                            to_char(l_quantity_shipped) || '*' ||
                            to_char(l_claim_amount_currency_code) || '*' ||
                            to_char(l_acct_amount_remaining) || '*' ||
                            to_char(l_univ_curr_amount_remaining) || '*' ||
			    to_char(l_fund_req_amount_remaining) || '*' ||
                            to_char(l_amount_remaining) || '*' ||
                            to_char('Y') || '*' || to_char(l_order_date) || '*' ||
                            to_char(sysdate) || '*' || to_char(sysdate) || '*' ||
                            to_char(FND_GLOBAL.USER_ID) || '*' ||
                            to_char(FND_GLOBAL.CONC_REQUEST_ID) || '*' ||
                            to_char(FND_GLOBAL.USER_ID) || '*' ||
                            to_char(FND_GLOBAL.CONC_LOGIN_ID) || '*' ||
                            to_char(FND_GLOBAL.PROG_APPL_ID) || '*' ||
                            to_char(null) || '*' ||
                            to_char(FND_GLOBAL.CONC_PROGRAM_ID) || '*' ||
                            to_char(l_org_id) || '*' ||
                            to_char(l_inv_org_id) || '*' ||
			    to_char(l_approved_discount_type) || '*' ||
			    to_char(l_approved_discount_value) || '*' ||
			    to_char(l_approved_discount_currency) || '*' ||
			    to_char(l_adjustment_type_id));
        END IF;

        IF OZF_DEBUG_LOW_ON THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Inserting INTO ozf_sd_batch_lines_all');
        END IF;

	  IF OZF_DEBUG_LOW_ON THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Insert into batch lines: start time:' || to_char(sysdate,'dd-mm-yyyy hh:mi:ss') );
        END IF;

        INSERT INTO OZF_SD_BATCH_LINES_ALL
          (batch_line_id,
           object_version_number,
           batch_id,
           batch_line_number,
           utilization_id,
           agreement_number,
           ship_to_org_id,
           ship_to_contact_id,

           sold_to_customer_id,
           sold_to_contact_id,
           sold_to_site_use_id,
           end_customer_id,
           end_customer_contact_id,

	   order_header_id,
           order_line_id,

	   invoice_number,
           invoice_line_number,
           resale_price_currency_code,
           resales_price,
           list_price_currency_code,
           list_price,
           agreement_currency_code,
           agreement_price,
           status_code,

           claim_amount,
           claim_amount_currency_code,
           batch_curr_claim_amount,

	   original_claim_amount,
           batch_curr_orig_claim_amount,

           item_id,
           vendor_item_id,
           shipped_quantity_uom,
           last_sub_claim_amount,
           acctd_amount_remaining,
           univ_curr_amount_remaining,
	   fund_request_amount_remaining,
           amount_remaining,
           quantity_shipped,
           purge_flag,
           order_date,
           creation_date,
           last_update_date,
           last_updated_by,
           request_id,
           created_by,

           last_update_login,
           program_application_id,
           program_update_date,
           program_id,
           org_id,
	   transmit_flag,

	   discount_type,
           discount_value,
	   discount_currency_code,
	   adjustment_type_id
	   )
        VALUES
          (l_batch_line_id,
           1,
           l_batch_id,
           l_batch_line_number,
           l_utilization_id,
           l_agreement_number,
           l_ship_to_org_id,
           l_ship_to_contact_id,

           l_sold_to_customer_id,
           l_SOLD_TO_CONTACT_ID,
           l_SOLD_TO_SITE_USE_ID,
           l_end_customer_id,
           l_end_customer_contact_id,

	   l_order_header_id,
           l_order_line_number,

	   l_invoice_number,
           l_invoice_line_number,

           l_resale_price_currency_code, -- from orders
           l_resales_price,
           l_list_price_currency_code, --purchase price from sdr
           l_list_price,
           l_agreement_currency_code, --agreement price from sdr
           l_agreement_price,
           'NEW',

           l_claim_amount, --claim amount from funds accrual
           l_claim_amount_currency_code,
           l_batch_curr_claim_amount,

           l_claim_amount, -- for original_claim_amount
	   l_batch_curr_claim_amount, -- for batch_curr_orig_claim_amount

           l_item_id,
           get_vendor_item_id(l_item_id, p_supplier_site_id),

           l_shipped_quantity_uom,
           null,
           l_acct_amount_remaining,
           l_univ_curr_amount_remaining,
	   l_fund_req_amount_remaining,
           l_amount_remaining,
           l_quantity_shipped,

           'N', -- l_active_flag
           l_order_date, -- from OE order lines/header
           sysdate, --l_creation_date,
           sysdate, --l_last_update_date,
           FND_GLOBAL.USER_ID, --l_last_updated_by,
           FND_GLOBAL.CONC_REQUEST_ID, --l_request_id,
           FND_GLOBAL.USER_ID, --l_created_by,
           --l_created_from,
           FND_GLOBAL.CONC_LOGIN_ID, --l_last_update_login,
           FND_GLOBAL.PROG_APPL_ID, --l_program_application_id,
           null, --l_program_update_date,
           FND_GLOBAL.CONC_PROGRAM_ID, --l_program_id,
           l_inv_org_id,
	   'Y',

           l_approved_discount_type,
	   l_approved_discount_value,
	   l_approved_discount_currency,

	   l_adjustment_type_id
	   );

	IF OZF_DEBUG_LOW_ON THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Insert into batch lines: end time:' || to_char(sysdate,'dd-mm-yyyy hh:mi:ss') );
        END IF;

        IF OZF_DEBUG_LOW_ON THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Inserted INTO ozf_sd_batch_lines_all');
        END IF;

        l_batch_line_number := l_batch_line_number + 1;
      END IF;

    END LOOP;
  EXCEPTION

    WHEN resource_busy THEN

      IF OZF_DEBUG_HIGH_ON THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Exception in CREATE_BATCH_LINES : ' || SQLERRM);
      END IF;

      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Exception in CREATE_BATCH_LINES : ' || SQLERRM);

      RAISE ;


    WHEN OTHERS THEN

      IF OZF_DEBUG_HIGH_ON THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Exception in CREATE_BATCH_LINES : ' || SQLERRM);
      END IF;

      RAISE FND_API.g_exc_error;

  END Create_Batch_Lines;



-- Start of comments
--	API name        : UPDATE_AMOUNTS
--	Type            : Private
--	Pre-reqs        : None.
--	Function        : Updates ozf_funds_utilized_all table setting amount remaining to zero
--	Parameters      :
--	IN              :       p_batch_id                      IN NUMBER       REQUIRED
--                              p_batch_threshold               IN NUMBER
-- End of comments
  PROCEDURE UPDATE_AMOUNTS(p_batch_id        IN NUMBER,
                           p_batch_threshold IN NUMBER) is

    l_batch_id        NUMBER;
    l_batch_sum       NUMBER;
    l_batch_threshold NUMBER;
  BEGIN
    l_batch_threshold := p_batch_threshold;
    l_batch_id        := p_batch_id;

    IF OZF_DEBUG_LOW_ON THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,
                        '--- Start of UPDATE_AMOUNTS ---');
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_batch_id = ' || p_batch_id);
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_batch_threshold = ' || p_batch_threshold);
    END IF;

    UPDATE ozf_funds_utilized_all_b
       SET amount_remaining           = 0,
           acctd_amount_remaining     = 0,
           plan_curr_amount_remaining = 0,
           univ_curr_amount_remaining = 0,
	   fund_request_amount_remaining = 0,
           last_update_date           = sysdate,
           last_updated_by            = FND_GLOBAL.USER_ID,
           object_version_number      = object_version_number + 1
     WHERE utilization_id in
           (SELECT utilization_id
              FROM ozf_sd_batch_lines_all
             WHERE batch_id = l_batch_id);
  EXCEPTION
    WHEN OTHERS THEN
      IF OZF_DEBUG_HIGH_ON THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Exception in UPDATE_AMOUNTS:' || SQLERRM);
      END IF;

      RAISE FND_API.g_exc_error;

  END UPDATE_AMOUNTS;



-- Start of comments
--	API name        : INVOKE_BATCH_AUTO_CLAIM
--	Type            : Private
--	Pre-reqs        : None.
--      Function        : Executable target for concurrent program
--                        Executable Name "OZFSDBACEX"
--	Parameters      :
--      IN              :       p_batch_id                      IN NUMBER
--                              p_vendor_id                     IN NUMBER
--                              p_vendor_site_id                IN NUMBER
-- End of comments
  PROCEDURE INVOKE_BATCH_AUTO_CLAIM(errbuf           OUT nocopy VARCHAR2,
                                    retcode          OUT nocopy NUMBER,
                                    p_batch_id       NUMBER,
                                    p_vendor_id      NUMBER,
                                    p_vendor_site_id NUMBER) is

    CURSOR get_freq_and_date(c_supplier_site_id NUMBER) IS
      SELECT days_before_claiming_debit
        FROM ozf_supp_trd_prfls_all
       WHERE supplier_site_id = c_supplier_site_id;

    l_claim_id              NUMBER := NULL; -- Incase auto claim is run
    l_claim_ret_status      VARCHAR2(15) := NULL;
    l_claim_msg_count       NUMBER := NULL;
    l_claim_msg_data        VARCHAR2(500) := NULL;
    l_claim_type            VARCHAR2(20) := 'SUPPLIER'; --always defaulted to external claim
    l_batch_id              NUMBER;
    l_duration              NUMBER;
    l_freq                  NUMBER;
    l_freq_unit             VARCHAR2(40);
    l_sql                   VARCHAR2(2000) := NULL;
    l_supplier_site_id      NUMBER := null;
    v_batch_header          c_batch_header;
    l_last_run_date         DATE;
    l_batch_submission_date DATE;
    l_return_status         VARCHAR2(15) := NULL;
  BEGIN

    IF OZF_DEBUG_LOW_ON THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, '--- Start INVOKE_BATCH_AUTO_CLAIM ---');
    END IF;

    l_sql := 'SELECT HDR.BATCH_ID, HDR.vendor_site_id, HDR.BATCH_SUBMISSION_DATE '
              || ' FROM ozf_sd_batch_headers_all HDR, ozf_sd_batch_lines_all BLN '
              || ' WHERE HDR.batch_id = BLN.batch_id'
              || ' AND HDR.status_code = ''SUBMITTED'' ';


    IF p_vendor_site_id IS NOT NULL THEN
      l_sql := l_sql || '  AND HDR.vendor_site_id =' || p_vendor_site_id;

    END IF;

    IF p_batch_id IS NOT NULL THEN
      l_sql := l_sql || ' AND  HDR.batch_id =' || p_batch_id;

    END IF;

    IF p_vendor_id IS NOT NULL THEN
      l_sql := l_sql || '  AND HDR.vendor_id =' || p_vendor_id;

    END IF;

      l_sql := l_sql || '  GROUP BY HDR.BATCH_ID, HDR.vendor_site_id, HDR.BATCH_SUBMISSION_DATE HAVING sum(BLN.batch_curr_claim_amount) > 0 ' ;

    OPEN v_batch_header for l_sql;
    LOOP
      FETCH v_batch_header
       INTO l_batch_id, l_supplier_site_id, l_batch_submission_date;
       EXIT WHEN v_batch_header%notfound;

      BEGIN
        OPEN get_freq_and_date(l_supplier_site_id);
        FETCH get_freq_and_date
         INTO l_freq;
        CLOSE get_freq_and_date;

        IF OZF_DEBUG_LOW_ON THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Batch ID ' || to_char(l_batch_id));
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Batch Submission Date ' || to_char(l_batch_submission_date));
	  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Trade Profile Frequency = ' || to_char(l_freq));
        END IF;

        l_batch_submission_date := l_batch_submission_date + l_freq;

        IF NVL(l_batch_submission_date, sysdate + 1) < sysdate THEN

	  IF OZF_DEBUG_HIGH_ON THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Invoking Claim for Batch ID ' || to_char(l_batch_id));
          END IF;

	  --Code added for Bug#6971836
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Initiates claim for batch '||to_char(l_batch_id));

       IF OZF_DEBUG_LOW_ON THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Claim API Invoke Start time in invoke_batch auto claim' || to_char(sysdate,'dd-mm-yyyy hh:mi:ss') );
       END IF;

	  OZF_CLAIM_ACCRUAL_PVT.Initiate_SD_Payment(1,
                                                    FND_API.g_false,
                                                    FND_API.g_true,
                                                    FND_API.g_valid_level_full,
                                                    l_claim_ret_status,
                                                    l_claim_msg_count,
                                                    l_claim_msg_data,
                                                    l_batch_id,
                                                    l_claim_type,
                                                    l_claim_id);

       IF OZF_DEBUG_LOW_ON THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Claim API Invoke End time in invoke batch auto claim' || to_char(sysdate,'dd-mm-yyyy hh:mi:ss') );
       END IF;

	    IF OZF_DEBUG_HIGH_ON THEN
              FND_FILE.PUT_LINE(FND_FILE.LOG, 'Invoked Claim ....' );
              FND_FILE.PUT_LINE(FND_FILE.LOG, '  Batch ID ' || to_char(l_batch_id));
              FND_FILE.PUT_LINE(FND_FILE.LOG, '  Claim ID ' || to_char(l_claim_id) );
	    END IF;

            IF OZF_ERROR_ON THEN
	      FND_FILE.PUT_LINE(FND_FILE.LOG, '  l_claim_ret_status ' || l_claim_ret_status );
              FND_FILE.PUT_LINE(FND_FILE.LOG, '  l_claim_msg_count ' || l_claim_msg_count );
	      FND_FILE.PUT_LINE(FND_FILE.LOG, '  l_claim_msg_data ' ||  l_claim_msg_data );
        	      FOR I IN 1..l_claim_msg_count LOOP
	        		FND_FILE.PUT_LINE(FND_FILE.LOG, '  Msg from Claim API while invoking batch for Auto Claim ' ||  SUBSTR(FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F'), 1, 254) );
                      END LOOP;
	    END IF;

	    IF l_claim_ret_status =  FND_API.G_RET_STS_SUCCESS THEN

	    --Code added for Bug#6971836
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Claim created for batch.');

            UPDATE OZF_SD_BATCH_HEADERS_ALL
               SET status_code           = 'CLOSED',
                   claim_id              = l_claim_id,
                   last_update_date      = sysdate,
                   last_updated_by       = FND_GLOBAL.USER_ID,
                   object_version_number = object_version_number + 1
             WHERE batch_id = l_batch_id;

           OZF_SD_UTIL_PVT.SD_RAISE_EVENT(l_batch_id, 'CLAIM', l_return_status); -- Raising lifecycle event for claim
           IF l_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.g_exc_error;
           END IF;



            COMMIT;

          END IF;
	ELSE
	    --Code added for Bug#6971836
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Claim process failed.');
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
          IF OZF_DEBUG_HIGH_ON THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG,
                              'Exception occured in INVOKE_BATCH_AUTO_CLAIM :=' ||
                              SQLERRM);
            errbuf  := 'Exception occured in INVOKE_BATCH_AUTO_CLAIM ' ||
                       SQLERRM;
            retcode := 2;
          END IF;
      END;
    END LOOP;

    CLOSE v_batch_header;

  END INVOKE_BATCH_AUTO_CLAIM;

-- Start of comments
--	API name        : PROCESS_SD_PENDING_CLM_BATCHES
--	Type            : Private
--	Pre-reqs        : None.
--      Function        : Executable target for concurrent program
--                      : Executable Name "OZFSDPABEX"
--                      : Loops over availabe operating units and invokes GET_SUPPLIER_SITES
--	Parameters      :
--      IN              :       p_org_id                        IN NUMBER
--                              p_vendor_id                     IN NUMBER
--                              p_vendor_site_id                IN NUMBER
--                              p_batch_id                      IN NUMBER
-- End of comments
  PROCEDURE PROCESS_SD_PENDING_CLM_BATCHES(errbuf OUT nocopy VARCHAR2,
					   retcode          OUT nocopy NUMBER,
                                           p_org_id         NUMBER,
					   p_vendor_id      NUMBER,
                                           p_vendor_site_id NUMBER,
					   p_batch_id       NUMBER) IS

    CURSOR operating_unit_csr IS
      SELECT ou.organization_id org_id
        FROM hr_operating_units ou
       WHERE mo_global.check_access(ou.organization_id) = 'Y';

    m                       NUMBER := 0;
    l_org_id                OZF_UTILITY_PVT.operating_units_tbl;
    l_return_status         VARCHAR2(15) := NULL;
  BEGIN

    IF OZF_DEBUG_LOW_ON THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, '--- Start PROCESS_SD_PENDING_CLM_BATCHES ---');
      FND_FILE.PUT_LINE(FND_FILE.LOG, '--- Start Parameter List ---');
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_org_id: '           || p_org_id);
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_vendor_id: '        || p_vendor_id);
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_vendor_site_id: '   || p_vendor_site_id);
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_batch_id: '         || p_batch_id);
      FND_FILE.PUT_LINE(FND_FILE.LOG, '--- End Parameter List ---');
    END IF;

      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'p_org_id: '           || p_org_id);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'p_vendor_id: '        || p_vendor_id);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'p_vendor_site_id: '   || p_vendor_site_id);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'p_batch_id: '         || p_batch_id);

    MO_GLOBAL.init('OZF');

    IF p_org_id IS NULL THEN
      MO_GLOBAL.set_policy_context('M', null);
      OPEN operating_unit_csr;
      LOOP
        FETCH operating_unit_csr
          INTO l_org_id(m);
        m := m + 1;
        EXIT WHEN operating_unit_csr%NOTFOUND;
      END LOOP;
      CLOSE operating_unit_csr;
    ELSE
      l_org_id(m) := p_org_id;
    END IF;

    BEGIN
    IF p_org_id is NOT NULL OR p_vendor_id is NOT NULL OR p_vendor_site_id is NOT NULL OR p_batch_id is NOT NULL THEN --atleast if one parameter is given

      PROCESS_SUPPLIER_SITES(p_org_id, p_vendor_id , p_vendor_site_id, p_batch_id);

    ELSIF (l_org_id.COUNT > 0) AND p_org_id is NULL AND p_vendor_id IS NULL AND p_vendor_site_id IS NULL AND p_batch_id IS NULL THEN --if all 4 parameters are not passed
      FOR m IN l_org_id.FIRST .. l_org_id.LAST LOOP

          IF OZF_DEBUG_LOW_ON THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, '--- Start Fetch of Organization ids ---');
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_org_id ' || to_char(l_org_id(m)));
            FND_FILE.PUT_LINE(FND_FILE.LOG, '--- End Fetch of Organization ids ---');
          END IF;

            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'l_org_id ' || to_char(l_org_id(m)));

	  MO_GLOBAL.set_policy_context('S', l_org_id(m));

          IF OZF_DEBUG_HIGH_ON THEN
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Processing for Operating Unit: ' ||
	                                        MO_GLOBAL.get_ou_name(l_org_id(m)));
          END IF;

          PROCESS_SUPPLIER_SITES(l_org_id(m) , p_vendor_id , p_vendor_site_id, p_batch_id);
      END LOOP;
    END IF;

    EXCEPTION
          WHEN OTHERS THEN
            IF OZF_DEBUG_HIGH_ON THEN
              FND_FILE.PUT_LINE(FND_FILE.LOG, 'Exception in PROCESS_SD_PENDING_CLM_BATCHES : ' || SQLERRM);
	    END IF;

	    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Exception in PROCESS_SD_PENDING_CLM_BATCHES : ' ||SQLERRM);

	    errbuf  := 'Error in PROCESS_SD_PENDING_CLM_BATCHES ' || SQLERRM;
            retcode := 2;
    END;

  END PROCESS_SD_PENDING_CLM_BATCHES;


-- Start of comments
--	API name        : PROCESS_SUPPLIER_SITES
--	Type            : Private
--	Pre-reqs        : None.
--	Function        : Looping over Supplier Site .
--	Parameters      :
--	IN              : p_org_id IN NUMBER
--                      : p_vendor_id IN NUMBER
--                      : p_vendor_site_id IN NUMBER
--                      : p_batch_id IN NUMBER
-- End of comments

    PROCEDURE PROCESS_SUPPLIER_SITES(p_org_id         IN NUMBER,
			             p_vendor_id      IN NUMBER,
			             p_vendor_site_id IN NUMBER,
			             p_batch_id       IN NUMBER) IS

    l_org_id           NUMBER := NULL;
    l_supplier_id      NUMBER;
    l_supplier_site_id NUMBER;
    l_batch_id         NUMBER;


     CURSOR get_supplier_sites(c_org_id NUMBER,c_vendor_id NUMBER,c_vendor_site_id NUMBER) IS
      SELECT sites.vendor_id, sites.vendor_site_id
        FROM ap_supplier_sites_all sites,
	     ozf_supp_trd_prfls_all trprf
       WHERE sites.org_id = NVL(c_org_id,sites.org_id)  AND
             sites.vendor_id = NVL(c_vendor_id,sites.vendor_id) AND
             sites.vendor_site_id = NVL(c_vendor_site_id,sites.vendor_site_id) AND
             nvl(sites.inactive_date, sysdate) >= trunc(sysdate) AND
	     trprf.cust_account_id is not null AND
	     sites.vendor_id=trprf.supplier_id AND
	     sites.vendor_site_id=trprf.supplier_site_id;

    BEGIN

    l_org_id           := p_org_id;
    l_supplier_id      := p_vendor_id;
    l_supplier_site_id := p_vendor_site_id;
    l_batch_id         := p_batch_id;

	 IF l_batch_id IS NULL THEN
	    FOR site_rec IN get_supplier_sites(l_org_id,l_supplier_id,l_supplier_site_id) LOOP
		IF OZF_DEBUG_HIGH_ON THEN
		  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Looping for Supplier ID = '|| site_rec.vendor_id || ' and Supplier Site ID = ' || site_rec.vendor_site_id);
		END IF;

		  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Looping for Supplier ID = '|| site_rec.vendor_id || ' and Supplier Site ID = ' || site_rec.vendor_site_id);

                  INVOKE_CLAIM(p_org_id, p_vendor_id , site_rec.vendor_site_id, p_batch_id);
	    END LOOP; -- for site_rec

         ELSE
              INVOKE_CLAIM(p_org_id, p_vendor_id , p_vendor_site_id, p_batch_id);

	 END IF;

    EXCEPTION
      WHEN OTHERS THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Exception in PROCESS_SUPPLIER_SITES' || sqlerrm);
       FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Exception in PROCESS_SUPPLIER_SITES' || sqlerrm);
    END; -- PROCESS_SUPPLIER_SITES;


-- Start of comments
--	API name        : INVOKE_CLAIM
--	Type            : Private
--	Pre-reqs        : None.
--	Function        : Invokes claim creation of Batches that are Pending Claim.
--	Parameters      :
--	IN              : p_org_id IN NUMBER
--                      : p_vendor_id IN NUMBER
--                      : p_vendor_site_id IN NUMBER
--                      : p_batch_id IN NUMBER
-- End of comments

    PROCEDURE INVOKE_CLAIM(p_org_id         IN NUMBER,
			   p_vendor_id      IN NUMBER,
			   p_vendor_site_id IN NUMBER,
			   p_batch_id       IN NUMBER) IS

    l_org_id           NUMBER := NULL;
    l_supplier_id      NUMBER;
    l_supplier_site_id NUMBER;
    l_batch_id         NUMBER;

    l_claim_id         NUMBER := NULL;
    l_ret_status       VARCHAR2(15) := NULL;
    l_msg_count        NUMBER := NULL;
    l_msg_data         VARCHAR2(5000) := NULL;
    l_claim_type       VARCHAR2(20) := 'SUPPLIER';
    l_func_currency    VARCHAR2(15);

      CURSOR get_sd_batches_pending_claim(c_org_id NUMBER,c_vendor_id NUMBER,c_vendor_site_id NUMBER,c_batch_id NUMBER) IS
      SELECT HDR.BATCH_ID batch_id, HDR.CURRENCY_CODE currency_code
        FROM ozf_sd_batch_headers_all HDR , ozf_sd_batch_lines_all BLN
       WHERE HDR.batch_id = BLN.batch_id
         AND HDR.status_code = 'PENDING_CLAIM'
	 AND HDR.org_id = NVL(c_org_id,HDR.org_id)
	 AND HDR.vendor_id = NVL(c_vendor_id,HDR.vendor_id)
	 AND HDR.vendor_site_id = NVL(c_vendor_site_id,HDR.vendor_site_id)
	 AND HDR.batch_id = NVL(c_batch_id,HDR.batch_id)
	 GROUP BY HDR.BATCH_ID, HDR.CURRENCY_CODE
	 HAVING sum(BLN.batch_curr_claim_amount) > 0;

    BEGIN

    l_org_id           := p_org_id;
    l_supplier_id      := p_vendor_id;
    l_supplier_site_id := p_vendor_site_id;
    l_batch_id         := p_batch_id;

    FOR batch_rec IN get_sd_batches_pending_claim(l_org_id,l_supplier_id,l_supplier_site_id,l_batch_id) LOOP

       SELECT gs.currency_code
         INTO l_func_currency
	 FROM gl_sets_of_books gs,
	      ozf_sys_parameters_all org,
	      ozf_sd_batch_headers_all bh
	WHERE org.set_of_books_id = gs.set_of_books_id
	  AND org.org_id = bh.org_id
	  AND bh.batch_id = batch_rec.BATCH_ID;

	   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Initiating claim for batch '|| batch_rec.BATCH_ID);
	   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Initiating claim for batch '|| batch_rec.BATCH_ID);

	   SAVEPOINT BEFORE_INVOKE_CLAIM;

     	UPDATE ozf_sd_batch_lines_all BLN
	   SET batch_curr_claim_amount =  (
					    CASE

					       WHEN ((BLN.claim_amount_currency_code = l_func_currency) AND (l_func_currency <> batch_rec.currency_code)) THEN  OZF_SD_UTIL_PVT.GET_CONVERTED_CURRENCY(BLN.claim_amount_currency_code,
																								       batch_rec.currency_code,
																								       l_func_currency,
																								       (SELECT fu.exchange_rate_type
																									  FROM ozf_funds_utilized_all_b fu
																							                 WHERE fu.utilization_id = BLN.utilization_id
																									   AND BLN.batch_id      = batch_rec.batch_id),
																								       NULL,
																								       sysdate,
																								       BLN.CLAIM_AMOUNT)

					       WHEN ((BLN.claim_amount_currency_code <> l_func_currency) AND (l_func_currency <> batch_rec.currency_code)) THEN OZF_SD_UTIL_PVT.GET_CONVERTED_CURRENCY(BLN.claim_amount_currency_code,
																								       batch_rec.currency_code,
																								       l_func_currency,
																								       (SELECT fu.exchange_rate_type
																									  FROM ozf_funds_utilized_all_b fu
																							                 WHERE fu.utilization_id = BLN.utilization_id
																									   AND BLN.batch_id      = batch_rec.batch_id),
																								       NULL,
																								       (SELECT fu.exchange_rate_date
																					                                  FROM ozf_funds_utilized_all_b fu
																							                 WHERE fu.utilization_id = BLN.utilization_id
																									   AND BLN.batch_id      = batch_rec.batch_id),
																								       BLN.CLAIM_AMOUNT)
					    END
					  ),
	       object_version_number   = object_version_number + 1,
	       last_update_date        = sysdate,
               last_updated_by         = fnd_global.user_id
	 WHERE batch_id                = batch_rec.batch_id
	   AND batch_line_number       IN (SELECT BLN.BATCH_LINE_NUMBER
	                                     FROM ozf_sd_batch_lines_all BLN,
					          ozf_funds_utilized_all_b FU
                                            WHERE BLN.batch_id = batch_rec.BATCH_ID
                                              AND BLN.utilization_id = FU.utilization_id
					      AND ((batch_rec.currency_code <> BLN.claim_amount_currency_code) AND (batch_rec.currency_code <> l_func_currency))
					   );


	  OZF_CLAIM_ACCRUAL_PVT.Initiate_SD_Payment(1,
                                                    FND_API.g_false,
                                                    FND_API.g_true,
                                                    FND_API.g_valid_level_full,
                                                    l_ret_status,
                                                    l_msg_count,
                                                    l_msg_data,
                                                    batch_rec.BATCH_ID,
                                                    l_claim_type,
                                                    l_claim_id);

              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'After Claim Initiation for batch '|| batch_rec.BATCH_ID);

              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '  l_ret_status ' || l_ret_status );
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '  l_msg_count ' || l_msg_count );
	      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '  l_msg_data ' ||  l_msg_data );
        	  FOR I IN 1..l_msg_count LOOP
	            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '  Msg from Claim API while invoking claim for batch ' ||  SUBSTR(FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F'), 1, 254) );
                  END LOOP;

	    IF OZF_DEBUG_HIGH_ON THEN
              FND_FILE.PUT_LINE(FND_FILE.LOG, 'Invoked Claim ....' );
              FND_FILE.PUT_LINE(FND_FILE.LOG, '  Batch ID ' || batch_rec.BATCH_ID);
              FND_FILE.PUT_LINE(FND_FILE.LOG, '  Claim ID ' || to_char(l_claim_id) );
	    END IF;

            IF OZF_ERROR_ON THEN
	      FND_FILE.PUT_LINE(FND_FILE.LOG, '  l_ret_status ' || l_ret_status );
              FND_FILE.PUT_LINE(FND_FILE.LOG, '  l_msg_count ' || l_msg_count );
	      FND_FILE.PUT_LINE(FND_FILE.LOG, '  l_msg_data ' ||  l_msg_data );
        	  FOR I IN 1..l_msg_count LOOP
	            FND_FILE.PUT_LINE(FND_FILE.LOG, '  Msg from Claim API while invoking claim for batch ' ||  SUBSTR(FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F'), 1, 254) );
                  END LOOP;
	    END IF;

	    IF l_ret_status =  FND_API.G_RET_STS_SUCCESS THEN  -- If claim is successful

	       FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Claim created for batch.' || batch_rec.BATCH_ID || 'is :' || to_char(l_claim_id));
	       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Claim created for batch.' || batch_rec.BATCH_ID || 'is :' || to_char(l_claim_id));

	       OZF_SD_UTIL_PVT.CREATE_ADJUSTMENT(batch_rec.BATCH_ID, 'F', l_ret_status, l_msg_count, l_msg_data);

	          IF l_ret_status =  FND_API.G_RET_STS_SUCCESS THEN  -- If adjustment is successful

		    UPDATE OZF_SD_BATCH_HEADERS_ALL
		       SET status_code           = 'CLOSED',
			   claim_id              = l_claim_id,
			   last_update_date      = sysdate,
			   last_updated_by       = FND_GLOBAL.USER_ID,
			   object_version_number = object_version_number + 1
		     WHERE batch_id = batch_rec.BATCH_ID
		       AND status_code = 'PENDING_CLAIM';

		       OZF_SD_UTIL_PVT.SD_RAISE_EVENT(batch_rec.BATCH_ID, 'CLAIM', l_ret_status); -- Raising lifecycle event for claim

                   ELSE  -- If adjustment is not successful

		      ROLLBACK TO BEFORE_INVOKE_CLAIM;
		      UPDATE ozf_sd_batch_headers_all
		         SET status_code           = 'PENDING_CLAIM',
			     last_update_date      = sysdate,
			     last_updated_by       = fnd_global.user_id,
			     object_version_number = object_version_number + 1
		       WHERE batch_id = batch_rec.BATCH_ID;
		  END IF;

	    ELSE  -- If claim is not successful

		  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Claim process failed.');
		  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Claim process failed.');

		  ROLLBACK TO BEFORE_INVOKE_CLAIM;
		      UPDATE ozf_sd_batch_headers_all
		         SET status_code           = 'PENDING_CLAIM',
			     last_update_date      = sysdate,
			     last_updated_by       = fnd_global.user_id,
			     object_version_number = object_version_number + 1
		       WHERE batch_id = batch_rec.BATCH_ID;
	    END IF;

	    COMMIT;

    END LOOP;  -- for batch_rec

    EXCEPTION
      WHEN OTHERS THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Exception in INVOKE_CLAIM' || sqlerrm);
       FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Exception in INVOKE_CLAIM' || sqlerrm);
    END; -- INVOKE_CLAIM;

END OZF_SD_BATCH_PVT;

/
