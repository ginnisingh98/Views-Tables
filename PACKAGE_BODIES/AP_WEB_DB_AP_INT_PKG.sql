--------------------------------------------------------
--  DDL for Package Body AP_WEB_DB_AP_INT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_DB_AP_INT_PKG" AS
/* $Header: apwdbapb.pls 120.38.12010000.8 2009/12/14 14:13:31 dsadipir ship $ */

/* -------------------------------------------------------------------
-- Function to get from ap_system_parameters:
-- 1. func currency
-- 2. set of books id
-- 3. default template id
-- 4. default exchange rate type
-- 5. auto tax calc flag
-- 6. auto tax calc flag override
-- 7. amount includes tax override
-- ---------------------------------------------------------------- */
FUNCTION get_ap_system_params(
                           p_base_curr_code       OUT NOCOPY      apSetUp_baseCurrencyCode,
                           p_set_of_books_id      OUT NOCOPY      apSetUp_setOfBooksID,
                           p_expense_report_id    OUT NOCOPY      apSetUp_expenseReportID,
                           p_default_exch_rate_type    OUT NOCOPY      apSetUp_defaultExchRateType) RETURN BOOLEAN IS
begin

  begin
    select base_currency_code,
           set_of_books_id,
           expense_report_id,
           default_exchange_rate_type
    into   p_base_curr_code,
           p_set_of_books_id,
           p_expense_report_id,
           p_default_exch_rate_type
    from  ap_system_parameters;

    return TRUE;

  exception
    when others then
      p_base_curr_code := NULL;
      p_set_of_books_id := NULL;
      p_expense_report_id := NULL;
      p_default_exch_rate_type := NULL;
      return FALSE;
  end;

end get_ap_system_params;

--------------------------------------------------------------------------------
FUNCTION GetCurrNameForCurrCode(
	p_curr_code	IN	FND_CURRENCIES_VL.currency_code%TYPE,
	p_curr_name OUT NOCOPY FND_CURRENCIES_VL.name%TYPE
) RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN
        SELECT name
        INTO   p_curr_name
        FROM   fnd_currencies_vl
        WHERE  currency_code = p_curr_code;

	RETURN TRUE;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetCurrNameForCurrCode' );
		APP_EXCEPTION.RAISE_EXCEPTION;
		RETURN FALSE;
END GetCurrNameForCurrCode;

--------------------------------------------------------------------------------
FUNCTION GetBaseCurrInfo(
	p_base_curr_code OUT NOCOPY apSetUp_baseCurrencyCode
) RETURN BOOLEAN IS
--------------------------------------------------------------------------------
  l_set_of_books_id		apSetup_setOfBooksID;
  l_expense_report_id		apSetup_expenseReportID;
  l_default_exch_rate_type	apSetUp_defaultExchRateType;
BEGIN
  return AP_WEB_DB_AP_INT_PKG.get_ap_system_params(p_base_curr_code => p_base_curr_code,
                                            p_set_of_books_id => l_set_of_books_id,
                                            p_expense_report_id => l_expense_report_id,
                                            p_default_exch_rate_type => l_default_exch_rate_type);

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetBaseCurrInfo' );
		APP_EXCEPTION.RAISE_EXCEPTION;
		RETURN FALSE;

END GetBaseCurrInfo;

-------------------------------------------------------------------
FUNCTION GetSOB(
	p_set_of_books_id OUT NOCOPY glsob_setOfBooksID
) RETURN BOOLEAN IS
-------------------------------------------------------------------
  l_base_curr_code		apSetup_baseCurrencyCode;
  l_expense_report_id		apSetup_expenseReportID;
  l_default_exch_rate_type	apSetUp_defaultExchRateType;

BEGIN
  return AP_WEB_DB_AP_INT_PKG.get_ap_system_params(p_base_curr_code => l_base_curr_code,
                                            p_set_of_books_id => p_set_of_books_id,
                                            p_expense_report_id => l_expense_report_id,
                                            p_default_exch_rate_type => l_default_exch_rate_type);

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetSOB' );
		APP_EXCEPTION.RAISE_EXCEPTION;
		RETURN FALSE;

END GetSOB;


-------------------------------------------------------------------
FUNCTION GetCOAofSOB(
	p_chart_of_accounts OUT NOCOPY glsob_chartOfAccountsID
) RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN
  select  GS.chart_of_accounts_id
  into    p_chart_of_accounts
  from    ap_system_parameters S,
          gl_sets_of_books GS
  where   GS.set_of_books_id = S.set_of_books_id;

  return TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetCOAOfSOB' );
		APP_EXCEPTION.RAISE_EXCEPTION;
		RETURN FALSE;

END GetCOAofSOB;

-------------------------------------------------------------------
FUNCTION GetAPSysCurrencySetupInfo(p_sys_info_rec OUT NOCOPY APSysInfoRec
) RETURN BOOLEAN IS
-------------------------------------------------------------------
l_default_exch_rate_type      apSetUp_defaultExchRateType;

BEGIN
        AP_WEB_DB_AP_INT_PKG.GetDefaultExchange(l_default_exch_rate_type);

  	SELECT 	s.base_currency_code,
	 	l_default_exch_rate_type,
		c.name,
		nvl(s.multi_currency_flag, 'N')
  	INTO   	p_sys_info_rec.base_currency,
 	 	p_sys_info_rec.default_exchange_rate_type,
         	p_sys_info_rec.base_curr_name,
		p_sys_info_rec.sys_multi_curr_flag
    	FROM   	ap_system_parameters s,
		fnd_currencies_vl c
  	WHERE  	c.currency_code = s.base_currency_code;

	RETURN TRUE;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;
	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetAPSysCUrrencySetupInfo' );
		APP_EXCEPTION.RAISE_EXCEPTION;
		RETURN FALSE;

END GetAPSysCurrencySetupInfo;

------------------------------------------------------------------
PROCEDURE GetDefaultExchange(
			  p_default_exchange_rate_type	 OUT NOCOPY VARCHAR2
				   ) IS
------------------------------------------------------------------
BEGIN
  -- Bug 8463457 To default the Exchange rate type from OIE Setup,
  -- if NO_DATA_FOUND then from AP Setup
  SELECT s.exchange_rate_type
  INTO   p_default_exchange_rate_type
  FROM   ap_pol_exrate_options s
  WHERE  enabled = 'Y';

EXCEPTION
  WHEN NO_DATA_FOUND THEN

      BEGIN
        SELECT 	s.default_exchange_rate_type
        INTO   	p_default_exchange_rate_type
        FROM   	ap_system_parameters s,
	        fnd_currencies_vl c
  	WHERE  	c.currency_code = s.base_currency_code;

      EXCEPTION
	WHEN NO_DATA_FOUND THEN
          null;
        WHEN OTHERS THEN
	  AP_WEB_DB_UTIL_PKG.RaiseException( 'GetDefaultExchange' );
	  APP_EXCEPTION.RAISE_EXCEPTION;
      END;

  WHEN OTHERS THEN
	AP_WEB_DB_UTIL_PKG.RaiseException( 'GetDefaultExchange' );
	APP_EXCEPTION.RAISE_EXCEPTION;

END GetDefaultExchange;





----------------------------------------------------------
FUNCTION GetVendorInfoOfEmp(
	p_employee_id		IN	vendors_employeeID,
	p_vendor_id	 OUT NOCOPY vendors_vendorID,
	p_vend_pay_curr_code  OUT NOCOPY  	vendors_paymentCurrCode,
	p_vend_pay_curr_name OUT NOCOPY  	FND_CURRENCIES_VL.name%TYPE
) RETURN BOOLEAN IS
----------------------------------------------------------
l_expense_check_address_flag      VARCHAR2(1);
l_get_from_vendor                 VARCHAR2(1) := 'N';
l_vendor_id                       VARCHAR2(15);
BEGIN
    -- 3176205: Inactive Employees and contingent workers
    -- The following query includes all workers except for
    -- terminated contingent workers and terminated employees
    -- who are now active contingent workers.
    BEGIN
      -- Bug 6978871(sodash) get the vendor_id
      SELECT expense_check_address_flag, vendor_id
      INTO l_expense_check_address_flag, l_vendor_id
      FROM (
        SELECT emp.expense_check_address_flag, null vendor_id
        FROM  per_employees_x emp
        WHERE  emp.employee_id = p_employee_id
        AND NOT AP_WEB_DB_HR_INT_PKG.ispersoncwk(emp.employee_id)='Y'
          UNION ALL
        SELECT emp.expense_check_address_flag, vendor_id
        FROM  per_cont_workers_current_x emp
        WHERE  emp.person_id = p_employee_id
      );

      IF l_expense_check_address_flag IS NULL THEN -- Bug 6978871(sodash) if not set at emp then get from financial option
         SELECT expense_check_address_flag
	 INTO l_expense_check_address_flag
	 FROM financials_system_parameters;
      END IF;

      IF l_expense_check_address_flag IS NOT NULL THEN
         BEGIN
           SELECT vdr.vendor_id, site.payment_currency_code, c.name
           INTO   p_vendor_id, p_vend_pay_curr_code, p_vend_pay_curr_name
           FROM   ap_suppliers vdr, ap_supplier_sites site, fnd_currencies_vl c
	   WHERE  site.vendor_id = vdr.vendor_id
           AND    (vdr.employee_id = p_employee_id OR (l_vendor_id is not null and l_vendor_id = vdr.vendor_id))  -- Bug 6978871(sodash)
           AND    c.currency_code(+) = site.payment_currency_code
           AND    upper(site.vendor_site_code) =
                              (SELECT upper(meaning)
                               FROM   hr_lookups
                               WHERE  lookup_code = l_expense_check_address_flag
                               AND    lookup_type = 'HOME_OFFICE');
           IF p_vend_pay_curr_code IS NULL THEN
              l_get_from_vendor := 'Y';
           END IF;
           EXCEPTION
              WHEN no_data_found THEN
                   l_get_from_vendor := 'Y';
        END;
      ELSE
         l_get_from_vendor := 'Y';
      END IF;

    EXCEPTION
      WHEN no_data_found THEN
           l_get_from_vendor := 'Y';
    END;

    IF l_get_from_vendor = 'Y' THEN
       SELECT vendor_id,
              payment_currency_code,
              c.name
       INTO   p_vendor_id,
              p_vend_pay_curr_code,
	      p_vend_pay_curr_name
       FROM   ap_suppliers v,
              fnd_currencies_vl c
       WHERE  (v.employee_id = p_employee_id OR (l_vendor_id is not null and l_vendor_id = v.vendor_id))  -- Bug 6978871(sodash)
       AND    c.currency_code(+) = v.payment_currency_code;
    END IF;


	RETURN TRUE;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetVendorInfoOfEmp' );
		APP_EXCEPTION.RAISE_EXCEPTION;
		RETURN FALSE;

END GetVendorInfoOfEmp;


----------------------------------------------------------
FUNCTION GetVendorAWTSetupForExpRpt(
	p_report_header_id   IN  expHdr_headerID,
	p_ven_allow_awt_flag OUT NOCOPY vendors_allowAWTFlag,
	p_ven_awt_group_id   OUT NOCOPY vendors_awtGroupID
) RETURN BOOLEAN IS
----------------------------------------------------------
BEGIN
  SELECT  nvl(PV.allow_awt_flag, 'N'),
          PV.awt_group_id
  INTO    p_ven_allow_awt_flag,
	  p_ven_awt_group_id
  FROM    ap_suppliers PV,
          ap_expense_report_headers RH
  WHERE   RH.report_header_id = p_report_header_id
  AND     PV.employee_id = RH.employee_id;

	RETURN TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetVendorAWTSetupForExpRpt' );
		APP_EXCEPTION.RAISE_EXCEPTION;
		RETURN FALSE;

END GetVendorAWTSetupForExpRpt;


-------------------------------------------------------------------
FUNCTION GetVendorID(
	p_employee_id 	IN 	vendors_employeeID,
	p_vendor_id  OUT NOCOPY vendors_vendorID
) RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN
  SELECT vendor_id
  INTO   p_vendor_id
  FROM   ap_suppliers
  WHERE  employee_id = p_employee_id;

  return TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetVendorID' );
		APP_EXCEPTION.RAISE_EXCEPTION;
		RETURN FALSE;
END GetVendorID;

-------------------------------------------------------------------
FUNCTION GetVendorSitesCodeCombID(
	p_vendor_site_id 	IN 	vendorSites_vendorSiteID,
	p_code_comb_id	  OUT NOCOPY     vendorSites_acctsPayCodeCombID
) RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN
  SELECT accts_pay_code_combination_id
  INTO   p_code_comb_id
  FROM   ap_supplier_sites
  WHERE  vendor_site_id = p_vendor_site_id;

  return TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
	   RETURN FALSE;
	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetVendorSitesCodeCombID' );
		APP_EXCEPTION.RAISE_EXCEPTION;
		RETURN FALSE;
END GetVendorSitesCodeCombID;

-------------------------------------------------------------------
FUNCTION GetVendorCodeCombID(
	p_vendor_id 	IN 	vendors_vendorID,
	p_accts_pay OUT NOCOPY     vendors_acctsPayCodeCombID
) RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN
  SELECT accts_pay_code_combination_id
  INTO   p_accts_pay
  FROM   ap_suppliers
  WHERE  vendor_id = p_vendor_id;

  return TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
	   RETURN FALSE;
	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetVendorCodeCombID' );
		APP_EXCEPTION.RAISE_EXCEPTION;
		RETURN FALSE;
END GetVendorCodeCombID;

-------------------------------------------------------------------
FUNCTION GetPayGroupLookupCode(
	p_vendor_id 		IN	vendorSites_vendorID,
	p_vendor_site_id 	IN 	vendorSites_vendorSiteID,
	p_pay_group_code  OUT NOCOPY     vendorSites_payGroupLookupCode
) RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN
  SELECT pay_group_lookup_code
  INTO   p_pay_group_code
  FROM   ap_supplier_sites
  WHERE  vendor_id = p_vendor_id
  AND 	 vendor_site_id = p_vendor_site_id;

  return TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetPayGroupLookupCode' );
		APP_EXCEPTION.RAISE_EXCEPTION;
		RETURN FALSE;
END GetPayGroupLookupCode;

--------------------------------------------------------------------------------
FUNCTION GetNextInvoiceId(
	p_invoice_id OUT NOCOPY NUMBER
) RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN
	SELECT	ap_invoices_interface_s.nextval
	INTO	p_invoice_id
	FROM	sys.dual;

	return TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetNextInvoiceId');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetNextInvoiceId;

--------------------------------------------------------------------------------
FUNCTION GetNextInvoiceLineId(p_invoice_line_id OUT NOCOPY NUMBER) RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN
	SELECT	ap_invoice_lines_interface_s.nextval
	INTO	p_invoice_line_id
	FROM	sys.dual;

	return TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetNextInvoiceLineId');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetNextInvoiceLineId;


-------------------------------------------------------------------
FUNCTION ApproverHasAuthority(
	p_approver_id 	  IN signingLimits_employeeID,
	p_doc_cost_center IN signingLimits_costCenter,
	p_approval_amount IN NUMBER,
	p_reimb_precision IN FND_CURRENCIES_VL.PRECISION%TYPE,
	p_item_type       IN signingLimits_docType,
        p_payment_curr_code  IN VARCHAR2,
        p_week_end_date IN DATE,
       	p_has_authority	  OUT NOCOPY BOOLEAN
) RETURN BOOLEAN IS
-------------------------------------------------------------------
l_signingLimitRate  NUMBER;

TYPE SigningLimitRecTyp IS RECORD (
   l_signingLimit  NUMBER,
   l_signingCurrencyCode  ap_system_parameters_all.base_currency_code%TYPE,
   l_exchangeRateType  VARCHAR2(30));

TYPE SigningLimitCurTyp IS REF CURSOR RETURN SigningLimitRecTyp;

SigningLimit         SigningLimitRecTyp;
SigningCurrencyCodes SigningLimitCurTyp; -- Cursor Variable

l_doc_cost_center           signingLimits_costCenter;
l_alphanumeric_allowed_flag fnd_flex_value_sets.alphanumeric_allowed_flag%type;
l_uppercase_only_flag       fnd_flex_value_sets.uppercase_only_flag%type;
l_numeric_mode_enabled_flag fnd_flex_value_sets.numeric_mode_enabled_flag%type;
l_max_size                  fnd_flex_value_sets.maximum_size%type;

BEGIN

   AP_WEB_ACCTG_PKG.GetCostCenterApprovalRule(
        p_alphanumeric_allowed_flag => l_alphanumeric_allowed_flag,
        p_uppercase_only_flag => l_uppercase_only_flag,
        p_numeric_mode_enabled_flag => l_numeric_mode_enabled_flag,
        p_maximum_size => l_max_size);

   -- Bug : 2234644 as per AOL team when the valueset is upper case only.
   -- For that type of value set, upper case values are allowed to be
   -- defined and if user enters a lower case then we make some assumptions.
   -- hence converting to upper case when Uppercase Only (A-Z) is checked.
   -- making same assumption as AOL team
   IF (l_uppercase_only_flag = 'Y') THEN
      l_doc_cost_center := upper(p_doc_cost_center);
   ELSE
      l_doc_cost_center := p_doc_cost_center;
   END IF;

   --Bug 3484668:Support for Right Justify Zero Fill is enabled.

   IF (l_numeric_mode_enabled_flag = 'Y') THEN
     --
     -- Right Justify Zero Fill is enabled.
     --
     l_doc_cost_center := Nvl(Rtrim(Ltrim(l_doc_cost_center)),'0');
     -- Bug: 5586280
     IF (NOT AP_WEB_UTILITIES_PKG.ContainsChars(l_doc_cost_center)) THEN
	     l_doc_cost_center := Lpad(l_doc_cost_center, l_max_size, '0');
     END IF;
   END IF;

   -- N=>Numbers Only (is checked for the valueset)
   -- Y=>Numbers Only (is unchecked for the valueset)
   IF (l_alphanumeric_allowed_flag = 'N') THEN
      OPEN SigningCurrencyCodes FOR
         select s.signing_limit, p.base_currency_code,  p.default_exchange_rate_type
         from ap_system_parameters p,
              ap_web_signing_limits s
         where employee_id = p_approver_id
         and to_number(cost_center) = to_number(l_doc_cost_center)
         and document_type = p_item_type;
   ELSE
      OPEN SigningCurrencyCodes FOR
         select s.signing_limit, p.base_currency_code,  p.default_exchange_rate_type
         from ap_system_parameters p,
              ap_web_signing_limits s
         where employee_id = p_approver_id
         and cost_center = l_doc_cost_center
         and document_type = p_item_type;
   END IF;

   p_has_authority := FALSE;

   /* loop throught all of the rows where employee_id, cost_center, and
      document_type match with the expense report but the approver might
      under different orgs */
   LOOP
   FETCH SigningCurrencyCodes
         into SigningLimit;
   EXIT WHEN SigningCurrencyCodes%NOTFOUND;

   -- get exchange rate between the signing limit currency code and
   -- reimbursement currency code
   l_signingLimitRate := AP_UTILITIES_PKG.get_exchange_rate(
        SigningLimit.l_SigningCurrencyCode,
        p_payment_curr_code,
        SigningLimit.l_exchangeRateType,
        p_week_end_date,
       'ApproverHasAuthority');

   IF round(SigningLimit.l_signingLimit * l_signingLimitRate, p_reimb_precision) >= round(p_approval_amount, p_reimb_precision) THEN
     p_has_authority := TRUE;
     EXIT;
   END IF;

   END LOOP;

   CLOSE SigningCurrencyCodes;

   RETURN TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'ApproverHasAuthority');
		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;

END ApproverHasAuthority;



/*Bug 2743726: New procedure for checking cost center value set
               alphanumeric_flag is checked or not.
*/

-------------------------------------------------------------------
PROCEDURE IsCostCenterUpperCase(
	p_doc_cost_center IN VARCHAR2,
       	Is_Cost_Center_UpperCase_flag	  OUT NOCOPY VARCHAR2
) IS
-------------------------------------------------------------------

l_alphanumeric_allowed_flag fnd_flex_value_sets.alphanumeric_allowed_flag%type;
l_uppercase_only_flag       fnd_flex_value_sets.uppercase_only_flag%type;
l_numeric_mode_enabled_flag fnd_flex_value_sets.numeric_mode_enabled_flag%type;
l_max_size                  fnd_flex_value_sets.maximum_size%type;
l_doc_cost_center           VARCHAR2(2000);

BEGIN

   AP_WEB_ACCTG_PKG.GetCostCenterApprovalRule(
        p_alphanumeric_allowed_flag => l_alphanumeric_allowed_flag,
        p_uppercase_only_flag => l_uppercase_only_flag,
        p_numeric_mode_enabled_flag => l_numeric_mode_enabled_flag,
        p_maximum_size => l_max_size);

   Is_Cost_Center_UpperCase_flag := nvl(l_uppercase_only_flag, 'N');

   EXCEPTION
        WHEN NO_DATA_FOUND THEN
                Is_Cost_Center_UpperCase_flag := 'N';
        WHEN OTHERS THEN
                Is_Cost_Center_UpperCase_flag := 'N';

END IsCostCenterUpperCase;

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
FUNCTION CostCenterValid(
	p_cost_center		IN  expFeedDists_costCenter,
	p_valid		 OUT NOCOPY BOOLEAN,
        p_employee_id           IN  NUMBER
) RETURN BOOLEAN IS
--------------------------------------------------------------------------------
l_valid VARCHAR2(1) := 'N';

l_employee_id             number;
l_chart_of_accounts_id    AP_WEB_DB_AP_INT_PKG.glsob_chartOfAccountsID;
l_default_emp_ccid        AP_WEB_DB_HR_INT_PKG.empCurrent_defaultCodeCombID;

/*Bug 2690715 : variable declarations */


l_parent_flex_value_set_id  fnd_flex_value_sets.parent_flex_value_set_id%type;

l_emp_set_of_books_id       AP_WEB_DB_AP_INT_PKG.glsob_setOfBooksID;
l_ou_chart_of_accounts_id   AP_WEB_DB_AP_INT_PKG.glsob_chartOfAccountsID;
l_emp_chart_of_accounts_id  AP_WEB_DB_AP_INT_PKG.glsob_chartOfAccountsID;

/*Bug 2699258:Added proper join conditions between S,GS,HR
              so that Merge Join Cartesians.
*/

-- 3176205: Inactive Employees and contingent workers
-- The following query includes all workers.
/* Bug 3916349/4042775 - comment
cursor c1(p_employee_id IN number) is
   SELECT GS.chart_of_accounts_id,
          HR.default_code_combination_id
   FROM   ap_system_parameters S,
          gl_sets_of_books GS,
          per_workforce_x HR
   WHERE  HR.person_id = p_employee_id
   AND    GS.set_of_books_id = S.set_of_books_id
   AND    S.set_of_books_id = nvl(HR.set_of_books_id,S.set_of_books_id)
   AND    rownum = 1;
*/

BEGIN

   l_employee_id := nvl(p_employee_id, AP_WEB_DB_HR_INT_PKG.getemployeeid);

   /* Bug 3916349/4042775 - comment
   for i in c1(l_employee_id) loop
      l_chart_of_accounts_id := i.chart_of_accounts_id;
      l_default_emp_ccid := i.default_code_combination_id;
   end loop;
   */

   SELECT set_of_books_id, default_code_combination_id
   INTO l_emp_set_of_books_id, l_default_emp_ccid
   FROM (
     SELECT emp.set_of_books_id, emp.default_code_combination_id
     FROM  per_employees_x emp
     WHERE  emp.employee_id = l_employee_id
     AND NOT AP_WEB_DB_HR_INT_PKG.ispersoncwk(emp.employee_id)='Y'
       UNION ALL
     SELECT emp.set_of_books_id, emp.default_code_combination_id
     FROM  per_cont_workers_current_x emp
     WHERE  emp.person_id = l_employee_id
   );

   -- Get the chart_of_account_id from system parameters
   IF (NOT AP_WEB_DB_AP_INT_PKG.GetCOAofSOB(l_ou_chart_of_accounts_id)) THEN
      l_ou_chart_of_accounts_id := null;
   END IF;

   IF (l_emp_set_of_books_id is not null) THEN
      SELECT GS.chart_of_accounts_id
      INTO   l_emp_chart_of_accounts_id
      FROM   gl_sets_of_books GS
      WHERE  GS.set_of_books_id = l_emp_set_of_books_id;

      IF (l_emp_chart_of_accounts_id <> l_ou_chart_of_accounts_id) THEN
        p_valid := FALSE;
        return FALSE;
      END IF;
   END IF;

   l_chart_of_accounts_id := l_ou_chart_of_accounts_id;

   AP_WEB_ACCTG_PKG.ValidateCostCenter(
        p_cost_center => p_cost_center,
        p_employee_id => l_employee_id,
        p_emp_set_of_books_id =>l_emp_set_of_books_id,
        p_default_emp_ccid => l_default_emp_ccid,
        p_chart_of_accounts_id => l_chart_of_accounts_id,
        p_cost_center_valid => p_valid);

    return p_valid;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		p_valid := FALSE;
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'CostCenterValid' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;

END CostCenterValid;


--------------------------------------------------------------------------------
FUNCTION GetExpenseClearingCCID(
	p_ccid OUT NOCOPY NUMBER,
	p_card_program_id IN NUMBER,
	p_employee_id     IN NUMBER,
	p_as_of_date      IN DATE
) RETURN BOOLEAN IS
-------------------------------------------------------------------------------
 l_data_feed_level_code   ap_card_programs.data_feed_level_code%type;
 l_default_emp_ccid       ap_expense_report_headers_all.employee_ccid%type;
 l_expense_clearing_ccid  ap_expense_report_headers_all.employee_ccid%type;
 l_chart_of_accounts_id   NUMBER;
 l_num_segments           NUMBER;
 l_company_seg_num        NUMBER;
 l_flex_segment_delimiter  varchar2(1);
 l_concatenated_segments   varchar2(2000);
 l_debug_info              varchar2(2000);

 l_cp_clearing_account_segments    FND_FLEX_EXT.SEGMENTARRAY;
 l_default_emp_segments             FND_FLEX_EXT.SEGMENTARRAY;

BEGIN

  SELECT expense_clearing_ccid, nvl(data_feed_level_code,'N')
  INTO   l_expense_clearing_ccid, l_data_feed_level_code
  FROM   ap_card_programs
  WHERE  card_program_id = p_card_program_id;

  if (l_expense_clearing_ccid IS NULL) then
	SELECT	EXPENSE_CLEARING_CCID
	INTO	l_expense_clearing_ccid
	FROM	FINANCIALS_SYSTEM_PARAMETERS;
  end if;

  -- if data_feed_level_code is Y then overlay company segment from employee a/c
  if l_data_feed_level_code = 'Y' then
	-----------------------------------------------------
	l_debug_info := 'Get the HR defaulted Employee CCID';
	-----------------------------------------------------
	begin
		SELECT pera.default_code_comb_id
		INTO   l_default_emp_ccid
		FROM   per_assignments_f pera,
		       per_assignment_status_types peras
		WHERE  pera.person_id = p_employee_id
		AND pera.assignment_status_type_id = peras.assignment_status_type_id
		AND trunc(p_as_of_date) between pera.effective_start_date and pera.effective_end_date
		AND pera.assignment_type in ('C', 'E')
		AND pera.primary_flag='Y'
		AND peras.per_system_status in ('ACTIVE_ASSIGN', 'ACTIVE_CWK');
	exception
	  when no_data_found then
		FND_MESSAGE.Set_Name('SQLAP', 'AP_WEB_EXP_MISSING_EMP_CCID');
		RAISE AP_WEB_OA_MAINFLOW_PKG.G_EXC_ERROR;
	end;

	-----------------------------------------------------
	l_debug_info := 'Get the Employee Chart of Accounts ID';
	-----------------------------------------------------
	IF (NOT AP_WEB_DB_EXPRPT_PKG.GetChartOfAccountsID(
	   p_employee_id          => p_employee_id,
	   p_chart_of_accounts_id => l_chart_of_accounts_id)) THEN
		NULL;
	END IF;

	IF (l_chart_of_accounts_id is null) THEN
		FND_MESSAGE.Set_Name('SQLAP', 'OIE_MISS_CHART_OF_ACC_ID');
		RAISE AP_WEB_OA_MAINFLOW_PKG.G_EXC_ERROR;
	END IF;

	-----------------------------------------------------------------
	l_debug_info := 'Get employee default ccid account segments';
	-----------------------------------------------------------------
	IF (l_default_emp_ccid IS NOT NULL) THEN
		IF (NOT FND_FLEX_EXT.GET_SEGMENTS(
					'SQLGL',
					'GL#',
					l_chart_of_accounts_id,
					l_default_emp_ccid,
					l_num_segments,
					l_default_emp_segments)) THEN
			RAISE AP_WEB_OA_MAINFLOW_PKG.G_EXC_ERROR;
		END IF; /* GET_SEGMENTS */
	END IF;


	-----------------------------------------------------------------
	l_debug_info := 'Get card program clearing account segments';
	-----------------------------------------------------------------
	IF (l_expense_clearing_ccid IS NOT NULL) THEN
		IF (NOT FND_FLEX_EXT.GET_SEGMENTS(
					'SQLGL',
					'GL#',
					l_chart_of_accounts_id,
					l_expense_clearing_ccid,
					l_num_segments,
					l_cp_clearing_account_segments)) THEN
			RAISE AP_WEB_OA_MAINFLOW_PKG.G_EXC_ERROR;
		END IF; /* GET_SEGMENTS */
	END IF;

	----------------------------------------
	l_debug_info := 'Get Company Segment';
	----------------------------------------
	IF (NOT FND_FLEX_APIS.GET_QUALIFIER_SEGNUM(
				101,
				'GL#',
				l_chart_of_accounts_id,
				'GL_BALANCING',
				l_company_seg_num)) THEN
		null;
	END IF;


        -- Overlay cardprogram clearing a/c company segment with
        -- employee default a/c company segment
        if l_company_seg_num is not null then
	   l_cp_clearing_account_segments(l_company_seg_num) := l_default_emp_segments(l_company_seg_num);
	end if;

	----------------------------------------
	l_debug_info := 'Get Segment Delimiter like .';
	----------------------------------------
	l_flex_segment_delimiter := FND_FLEX_EXT.GET_DELIMITER(
					'SQLGL',
					'GL#',
					l_chart_of_accounts_id);

	IF (l_flex_segment_delimiter IS NULL) THEN
		RAISE AP_WEB_OA_MAINFLOW_PKG.G_EXC_ERROR;
	END IF;


      --------------------------------------------------------------
      l_debug_info := 'Get Concatenate segments to retrieve new clearing ccid';
      --------------------------------------------------------------
      l_concatenated_segments :=  FND_FLEX_EXT.concatenate_segments(l_num_segments,
                        l_cp_clearing_account_segments,
                        l_flex_segment_delimiter);

      ------------------------------------------------------------------------
      l_debug_info := 'calling FND_FLEX_KEYVAL.validate_segs';
      ------------------------------------------------------------------------
      -- Bug: 7699146, Replaced CREATE_COMB_NO_AT with CREATE_COMBINATION
      IF (FND_FLEX_KEYVAL.validate_segs('CREATE_COMBINATION',
                                        'SQLGL',
                                        'GL#',
                                        l_chart_of_accounts_id,
                                        l_concatenated_segments)) THEN

        p_ccid := FND_FLEX_KEYVAL.combination_id;

      ELSE
        l_debug_info := substr(FND_FLEX_KEYVAL.error_message, 1800);
        FND_MESSAGE.set_encoded(FND_FLEX_KEYVAL.encoded_error_message);
        fnd_msg_pub.add();
        RAISE AP_WEB_OA_MAINFLOW_PKG.G_EXC_ERROR;

      END IF; /* FND_FLEX_KEYVAL.validate_segs */


  else -- if l_data_feed_level_code = 'Y' then

	p_ccid := l_expense_clearing_ccid;

  end if;

	RETURN TRUE;
EXCEPTION
	WHEN AP_WEB_OA_MAINFLOW_PKG.G_EXC_ERROR THEN
		AP_WEB_DB_UTIL_PKG.RaiseException(nvl(FND_MESSAGE.Get,l_debug_info));
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;
	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetExpenseClearingCCID' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;

END GetExpenseClearingCCID;

FUNCTION GetRoundingErrorCCID(
        p_ccid OUT NOCOPY NUMBER
) RETURN BOOLEAN IS
-------------------------------------------------------------------------------
BEGIN
        SELECT  ROUNDING_ERROR_CCID
        INTO    p_ccid
        FROM    ap_system_parameters;

        RETURN TRUE;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
                RETURN FALSE;

        WHEN OTHERS THEN
                AP_WEB_DB_UTIL_PKG.RaiseException( 'GetRoundingErrorCCID' );
                APP_EXCEPTION.RAISE_EXCEPTION;
                return FALSE;

END GetRoundingErrorCCID;

/* move to interface with AP system */
-----------------------------------------------------
FUNCTION GetAvailablePrepayments(
	p_employee_id 		IN 	vendors_employeeID,
	p_default_currency_code IN 	invoices_invCurrCode,
	p_available_prepays OUT NOCOPY NUMBER
) RETURN BOOLEAN IS
-----------------------------------------------------
BEGIN
  SELECT nvl(sum(decode(payment_status_flag, 'Y',
                        decode(sign(earliest_settlement_date - sysdate),1,0,1),
                        0)),
                        0)
  INTO  p_available_prepays
  FROM  ap_invoices I,
    	ap_suppliers  PV
  WHERE (select sum(aid.prepay_amount_remaining)
         from ap_invoice_distributions aid
         where aid.invoice_id = I.invoice_id
              AND   aid.line_type_lookup_code IN ('ITEM','TAX')
              AND   NVL(aid.reversal_flag,'N') <> 'Y'
        ) > 0
  AND   I.vendor_id = PV.vendor_id
  AND   PV.employee_id = p_employee_id
  AND   I.invoice_type_lookup_code = 'PREPAYMENT'
  AND   earliest_settlement_date IS NOT NULL
  AND   I.invoice_amount > 0
  AND   I.invoice_currency_code = p_default_currency_code;

  return TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetAvailablePrepayments' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;

END GetAvailablePrepayments;


--------------------------------------------------------------------------------
FUNCTION InsertInvoiceInterface(
	p_invoice_id		IN invIntf_invID,
	p_party_id		IN invIntf_partyID,
	p_vendor_id		IN invIntf_vendorID,
	p_vendor_site_id 	IN invIntf_vendorSiteID,
	p_sum			IN invIntf_invAmt,
	p_invoice_curr_code 	IN invIntf_invCurrCode,
	p_source		IN invIntf_source,
	p_pay_group_lookup_code	IN vendorSites_payGroupLookupCode,
        p_org_id                IN NUMBER,
        p_doc_category_code     IN invIntf_docCategoryCode,
        p_invoice_type_lookup_code IN invIntf_invTypeCode,
        p_accts_pay_ccid        IN invIntf_acctsPayCCID,
	p_party_site_id		IN invIntf_partySiteID default null,
	p_terms_id		IN AP_TERMS.TERM_ID%TYPE default null
) RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN
-- Bug 	6838894
-- Bug: 7234744 populate terms-id in the interface table.
	INSERT INTO AP_INVOICES_INTERFACE
		(INVOICE_ID,
		INVOICE_NUM,
		PARTY_ID,
		PARTY_SITE_ID,
		VENDOR_ID,
		VENDOR_SITE_ID,
		INVOICE_AMOUNT,
		INVOICE_CURRENCY_CODE,
		SOURCE,
		PAY_GROUP_LOOKUP_CODE,
                ORG_ID,
                DOC_CATEGORY_CODE,
                INVOICE_TYPE_LOOKUP_CODE,
                ACCTS_PAY_CODE_COMBINATION_ID,
		TERMS_ID)
	VALUES
		(p_invoice_id,
		substrb(to_char(p_invoice_id)||'-'||to_char(sysdate), 1, 50),
		p_party_id,
		p_party_site_id,
		p_vendor_id,
		p_vendor_site_id,
		p_sum,
		p_invoice_curr_code,
		p_source,
		p_pay_group_lookup_code,
                p_org_id,
		p_doc_category_code,
		p_invoice_type_lookup_code,
		p_accts_pay_ccid,
		p_terms_id);

	RETURN TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'UpdateInvoiceInterface' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;

END InsertInvoiceInterface;

--------------------------------------------------------------------------------
FUNCTION InsertInvoiceLinesInterface(
	p_invoice_id		IN invLines_invID,
	p_invoice_line_id	IN invLines_invLineID,
	p_count			IN invLines_lineNum,
	p_linetype		IN invLines_lineTypeLookupCode,
	p_amount		IN invLines_amount,
	p_trxn_date		IN invLines_accountingDate,
	p_ccid			IN invLines_distCodeCombID,
	p_card_trxn_id		IN invLines_crdCardTrxID,
        p_description           IN invLines_description,
        p_org_id                IN NUMBER
) RETURN BOOLEAN IS
--------------------------------------------------------------------------------
BEGIN

	INSERT INTO AP_INVOICE_LINES_INTERFACE(
		INVOICE_ID,
		INVOICE_LINE_ID,
		LINE_NUMBER,
		LINE_TYPE_LOOKUP_CODE,
		AMOUNT,
		ACCOUNTING_DATE,
		DIST_CODE_COMBINATION_ID,
		CREDIT_CARD_TRX_ID,
                DESCRIPTION,
                ORG_ID)
	VALUES
		(p_invoice_id,
		p_invoice_line_id,
		p_count,
		p_linetype,
		p_amount,
		p_trxn_date,
		p_ccid,
		p_card_trxn_id,
                p_description,
                p_org_id);

	RETURN TRUE;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'InsertInvoiceLinesInerface' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;

END InsertInvoiceLinesInterface;


-------------------------------------------------------------------
FUNCTION IsTaxCodeWebEnabled(
	P_ExpTypeDefaultTaxCode IN  taxCodes_name,
	p_tax_web_enabled OUT NOCOPY taxCodes_webEnabledFlag
) RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN

  -- Clear out the default tax if it is not web enabled.  This is a setup
  -- error.
  -- If web_enabled_flag is null should assume P_Default_No_Flag.
    SELECT NVL(WEB_ENABLED_FLAG, 'N')
    INTO   p_tax_web_enabled
    FROM   AP_TAX_CODES
    WHERE  NAME = P_ExpTypeDefaultTaxCode
    AND    nvl(enabled_flag, 'Y') = 'Y'
    AND    nvl(web_enabled_flag,'N') = 'Y';

	RETURN TRUE;

EXCEPTION

	WHEN TOO_MANY_ROWS THEN
		p_tax_web_enabled := 'Y';
                RETURN TRUE;

	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'IsTaxCodeWebEnabled' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;

END IsTaxCodeWebEnabled;


-----------------------------------------------------
PROCEDURE GenTaxFunctions
-----------------------------------------------------
IS

BEGIN

 --This is a wrapper procedure for 11.0.3 backport
 AP_WEB_WRAPPER_PKG.GenTaxFunctions;


EXCEPTION

    WHEN OTHERS THEN
	AP_WEB_DB_UTIL_PKG.RaiseException( 'AP_WEB_DB_AP_INT_PKG.GenTaxFunctions' );
    	APP_EXCEPTION.RAISE_EXCEPTION;

END GenTaxFunctions;


FUNCTION GetInvoiceAmt(
        p_invoiceId  IN invAll_id,
        p_invoiceAmt OUT NOCOPY invLines_amount,
        p_exchangeRate OUT NOCOPY invAll_exchangeRate,
        p_minAcctUnit OUT NOCOPY FND_CURRENCIES_VL.minimum_accountable_unit%TYPE,
        p_precision OUT NOCOPY FND_CURRENCIES_VL.PRECISION%TYPE
) RETURN BOOLEAN IS
BEGIN

    SELECT inv.invoice_amount, inv.exchange_rate,
           F.minimum_accountable_unit, F.precision
    INTO   p_invoiceAmt, p_exchangeRate, p_minAcctUnit, p_precision
    FROM   AP_INVOICES inv, ap_system_parameters sp, fnd_currencies F
    WHERE  inv.invoice_id = p_invoiceId
       AND inv.set_of_books_id = sp.set_of_books_id
       AND F.currency_code = sp.base_currency_code;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
	RETURN FALSE;

    WHEN OTHERS THEN
	AP_WEB_DB_UTIL_PKG.RaiseException( 'GetInvoiceAmt' );
    	APP_EXCEPTION.RAISE_EXCEPTION;
    	return FALSE;

END GetInvoiceAmt;

FUNCTION SetInvoiceAmount(p_invoiceId   IN invAll_id,
                          p_invoiceAmt 	IN invAll_invoiceAmount,
			  p_baseAmt     IN invAll_baseAmount) RETURN BOOLEAN IS
BEGIN
	UPDATE  AP_INVOICES
	SET     invoice_amount = p_invoiceAmt,
                pay_curr_invoice_amount = ap_web_utilities_pkg.oie_round_currency(
                                             p_invoiceAmt * payment_cross_rate,
                                                        payment_currency_code),
                base_amount = p_baseAmt
        WHERE   invoice_id = p_invoiceId;

    RETURN TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
	AP_WEB_DB_UTIL_PKG.RaiseException( 'SetInvoiceAmount' );
    	APP_EXCEPTION.RAISE_EXCEPTION;
    	return FALSE;

END SetInvoiceAmount;

-------------------------------------------------------------------
FUNCTION GetVatCode(
	P_TaxCodeID 	IN  taxCodes_taxID,
	P_VatCode OUT NOCOPY taxCodes_name
) RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN


  -- Return Vat Code according to Tax Code ID
    SELECT NAME
    INTO   P_VatCode
    FROM   AP_TAX_CODES
    WHERE  TAX_ID = P_TaxCodeID;

	RETURN TRUE;

EXCEPTION

	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetVatCode' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return FALSE;

END GetVatCode;

-------------------------------------------------------------------
FUNCTION GetTaxCodeID(
        P_VatCode       IN  taxCodes_name,
        P_TaxCodeID     OUT NOCOPY taxCodes_taxID
) RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN


  -- Return Tax Code Id using Vat Code
    SELECT TAX_ID
    INTO   P_TAXCodeID
    FROM   AP_TAX_CODES
    WHERE  NAME = P_VatCode;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        RETURN FALSE;

    WHEN OTHERS THEN
        AP_WEB_DB_UTIL_PKG.RaiseException( 'GetTaxCodeID' );
    	APP_EXCEPTION.RAISE_EXCEPTION;
        return FALSE;

END GetTaxCodeID;

-------------------------------------------------------------------
FUNCTION GetTaxCodeID(
        P_VatCode       IN  taxCodes_name,
        P_ExpLine_Date  IN  DATE,
        P_TaxCodeID     OUT NOCOPY taxCodes_taxID
) RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN


  -- Return Tax Code Id using Vat Code
    SELECT TAX_ID
    INTO   P_TAXCodeID
    FROM   AP_TAX_CODES
    WHERE  NAME = P_VatCode
    AND    nvl(enabled_flag, 'Y') = 'Y'
    AND    nvl(P_ExpLine_Date,sysdate) BETWEEN
	   nvl(start_date,nvl(P_ExpLine_Date,sysdate)) AND
           nvl(inactive_date,nvl(P_ExpLine_Date,sysdate));

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        RETURN FALSE;

    WHEN OTHERS THEN
        AP_WEB_DB_UTIL_PKG.RaiseException( 'GetTaxCodeID' );
    	APP_EXCEPTION.RAISE_EXCEPTION;
        return FALSE;

END GetTaxCodeID;

FUNCTION getTemplateCostCenter(
        p_parameter_id          IN  NUMBER
) RETURN VARCHAR2 IS
--------------------------------------------------------------------------------
l_cost_center             varchar2(200);

BEGIN

   AP_WEB_ACCTG_PKG.GetExpenseTypeCostCenter(
        p_exp_type_parameter_id => p_parameter_id,
        p_cost_center => l_cost_center);

   return l_cost_center;

EXCEPTION
  when others then
       return l_cost_center;
END getTemplateCostCenter;

FUNCTION isCostCenterExistOnTemplate(
	p_expense_report_id		IN  NUMBER
) RETURN VARCHAR2 IS
--------------------------------------------------------------------------------
l_cost_center                   varchar2(200);
l_cc_exist                      varchar2(1) := 'N';
l_expense_types_cursor 	        AP_WEB_DB_EXPTEMPLATE_PKG.ExpenseTypesCursor;
l_parameter_id	 	        AP_WEB_DB_EXPTEMPLATE_PKG.expTempl_paramID;
l_web_FriendlyPrompt		AP_WEB_DB_EXPTEMPLATE_PKG.expTempl_webFriendlyPrompt;
l_require_receipt_amount	AP_WEB_DB_EXPTEMPLATE_PKG.expTempl_requireReceiptAmt;
l_card_exp_type_lookup_code	AP_WEB_DB_EXPTEMPLATE_PKG.expTempl_cardExpTypeLookupCode;
l_amount_includes_tax_flag      AP_WEB_DB_EXPTEMPLATE_PKG.expTempl_amtInclTaxFlag;
l_justif_req			AP_WEB_DB_EXPTEMPLATE_PKG.expTempl_justificationReqdFlag;

BEGIN

   IF (AP_WEB_DB_EXPTEMPLATE_PKG.GetExpTypesCursor(p_expense_report_id, l_expense_types_cursor)) THEN
      LOOP
        FETCH l_expense_types_cursor
        INTO  l_parameter_id, l_web_FriendlyPrompt,
      	      l_require_receipt_amount,
	      l_card_exp_type_lookup_code,
              l_amount_includes_tax_flag,
	      l_justif_req;
	EXIT WHEN l_expense_types_cursor%NOTFOUND;
	begin
          AP_WEB_ACCTG_PKG.GetExpenseTypeCostCenter(
               p_exp_type_parameter_id => l_parameter_id,
               p_cost_center => l_cost_center);

          IF (l_cost_center IS NOT NULL) THEN
              l_cc_exist := 'Y';
              EXIT;
          END IF;
        exception
          when others then
            null;
        end;
      END LOOP;  --end for arrExpType
   END IF;
   CLOSE l_expense_types_cursor;

   return l_cc_exist;

EXCEPTION
  when others then
    AP_WEB_DB_UTIL_PKG.RaiseException('isCostCenterExistOnTemplate');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return l_cc_exist;
END isCostCenterExistOnTemplate;

-------------------------------------------------------------------
FUNCTION GetExpenseClearingCCID(
	p_trx_id NUMBER
) RETURN NUMBER IS
-------------------------------------------------------------------
  l_employee_id      number;
  l_card_program_id  number;
  l_transaction_date ap_credit_card_trxns.transaction_date%type;
  l_ccid  	     ap_expense_report_headers_all.employee_ccid%type;
BEGIN

        SELECT employee_id, txn.card_program_id, transaction_date
        INTO   l_employee_id, l_card_program_id, l_transaction_date
        FROM   ap_cards card,
               ap_credit_card_trxns txn
        WHERE  card.card_program_id = txn.card_program_id
        AND    card.card_id = txn.card_id
        AND    txn.trx_id = p_trx_id;

	IF NOT AP_WEB_DB_AP_INT_PKG.GetExpenseClearingCCID(p_ccid => l_ccid,
		p_card_program_id => l_card_program_id,
		p_employee_id     => l_employee_id,
		p_as_of_date      => l_transaction_date) THEN
		l_ccid := null;
	END IF;


	RETURN l_ccid;
EXCEPTION
	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetExpenseClearingCCID' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
    		return 0;

END GetExpenseClearingCCID;

-------------------------------------------------------------------

----------------------------------------------------------------------------------------
-- Bug# 9182883: Procedure to find whether the default exchange rates is enabled or not
-- also used to get the allowance rate
----------------------------------------------------------------------------------------
PROCEDURE GetDefaultExchangeRates(
        p_default_exchange_rates OUT NOCOPY VARCHAR2,
        p_exchange_rate_allowance OUT NOCOPY NUMBER
) IS
-------------------------------------------------------
l_default_exchange_rates        VARCHAR2(1);
l_default_exchange_rate_flag    VARCHAR2(1);
l_exchange_rate_allowance       NUMBER;
l_employee_id   NUMBER;
BEGIN
        p_default_exchange_rates := 'N';
        p_exchange_rate_allowance := 0;

        SELECT default_exchange_rates, exchange_rate_allowance
        INTO l_default_exchange_rates, l_exchange_rate_allowance
        FROM ap_pol_exrate_options WHERE  enabled = 'Y';

        IF l_default_exchange_rates = 'U' THEN
                l_employee_id := AP_WEB_DB_HR_INT_PKG.getEmployeeID;

                SELECT default_exchange_rate_flag INTO l_default_exchange_rate_flag
                FROM ap_web_preferences WHERE employee_id = l_employee_id;

                IF l_default_exchange_rate_flag = 'Y' THEN
                        p_default_exchange_rates := 'Y';
                        p_exchange_rate_allowance := l_exchange_rate_allowance;
                END IF;

        ELSIF l_default_exchange_rates <> 'N' THEN
                p_default_exchange_rates := 'Y';
    IF l_default_exchange_rates = 'Y' THEN
                  p_exchange_rate_allowance := l_exchange_rate_allowance;
    END IF;

        END IF;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
                null;
        WHEN OTHERS THEN
                AP_WEB_DB_UTIL_PKG.RaiseException( 'GetDefaultExchangeRates' );
                APP_EXCEPTION.RAISE_EXCEPTION;

END GetDefaultExchangeRates;

-------------------------------------------------------------------------------------


END AP_WEB_DB_AP_INT_PKG;

/
