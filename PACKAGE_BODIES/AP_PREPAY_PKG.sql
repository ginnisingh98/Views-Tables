--------------------------------------------------------
--  DDL for Package Body AP_PREPAY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_PREPAY_PKG" AS
/*$Header: aprepayb.pls 120.42.12010000.15 2010/05/31 16:18:21 pgayen ship $*/


G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AP_PREPAY_PKG';
G_MSG_UERROR        CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
G_MSG_ERROR         CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_ERROR;
G_MSG_SUCCESS       CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_SUCCESS;
G_MSG_HIGH          CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
G_MSG_MEDIUM        CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
G_MSG_LOW           CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;
G_LINES_PER_FETCH   CONSTANT NUMBER       := 1000;

G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_UNEXPECTED      CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
G_LEVEL_ERROR           CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
G_LEVEL_EXCEPTION       CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_EVENT           CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
G_LEVEL_PROCEDURE       CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_STATEMENT       CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
G_MODULE_NAME           CONSTANT VARCHAR2(100) := 'AP.PLSQL.AP_PREPAY_PKG.';

FUNCTION Check_Supplier_Consistency (
          p_prepay_num   IN VARCHAR2,
          p_vendor_id    IN NUMBER) RETURN VARCHAR2
IS

l_reject_code          VARCHAR2(30) := NULL;

CURSOR C_Supplier_Consistent(
          cv_prepay_num  VARCHAR2,
          cv_vendor_id   NUMBER)
IS
SELECT DECODE(COUNT(*),
              0, 'INCONSISTENT PREPAY SUPPL', NULL)
  FROM ap_invoices ai
 WHERE ai.invoice_num = cv_prepay_num
   AND ai.vendor_id   = cv_vendor_id;

BEGIN

  OPEN  C_Supplier_Consistent
         (p_prepay_num,
          p_vendor_id);

  FETCH C_Supplier_Consistent
   INTO l_reject_code;

  CLOSE C_Supplier_Consistent;

  RETURN (l_reject_code);

EXCEPTION
  WHEN OTHERS THEN
     IF C_Supplier_Consistent%ISOPEN THEN
              CLOSE C_Supplier_Consistent;
     END IF;
     APP_EXCEPTION.RAISE_EXCEPTION;

END Check_Supplier_Consistency;


FUNCTION Check_Currency_Consistency (
          p_prepay_num                    IN VARCHAR2,
          p_vendor_id                     IN NUMBER,
          p_base_currency_code            IN VARCHAR2,
          p_invoice_currency_code         IN VARCHAR2,
          p_payment_currency_code         IN VARCHAR2) RETURN VARCHAR2
IS

l_reject_code                        VARCHAR2(30) := NULL;

CURSOR C_Currency_Consistent
         (cv_prepay_num              VARCHAR2,
          cv_vendor_id               NUMBER,
          cv_base_currency_code      VARCHAR2,
          cv_invoice_currency_code   VARCHAR2,
          cv_payment_currency_code   VARCHAR2) IS
SELECT DECODE(COUNT(*),
              0, 'INCONSISTENT PREPAY CURR', NULL)
  FROM ap_invoices ai
 WHERE invoice_num              = cv_prepay_num
   AND vendor_id                = cv_vendor_id
   AND cv_base_currency_code    =
           (SELECT base_currency_code
             FROM  ap_system_parameters)
   AND ai.invoice_currency_code = cv_invoice_currency_code
   AND ai.payment_currency_code = NVL(cv_payment_currency_code,
                                      cv_invoice_currency_code);
BEGIN

  OPEN  C_Currency_Consistent
         (p_prepay_num,
          p_vendor_id,
          p_base_currency_code,
          p_invoice_currency_code,
          p_payment_currency_code);

  FETCH C_Currency_Consistent
   INTO  l_reject_code;

  CLOSE C_Currency_Consistent;

  RETURN (l_reject_code);

EXCEPTION
  WHEN OTHERS THEN
    IF C_Currency_Consistent%ISOPEN THEN
      CLOSE C_Currency_Consistent;
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Check_Currency_Consistency;


FUNCTION Check_Prepayment_Invoice (
           p_prepay_num           IN VARCHAR2,
           p_vendor_id            IN VARCHAR2,
           p_prepay_invoice_id    OUT NOCOPY NUMBER) RETURN VARCHAR2
IS

l_reject_code                   VARCHAR2(30) := NULL;
l_api_name			VARCHAR2(50);
l_count				NUMBER;
l_debug_info 			VARCHAR2(4000);

BEGIN
  l_api_name := 'Check_Prepayment_Invoice';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_PREPAY_PKG.Check_Prepayment_Invoice(+)');
  END IF;


  l_debug_info := 'Check if the prepayment invoice is a valid invoice ';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  SELECT count(*)
  INTO l_count
  FROM ap_invoices ai
  WHERE ai.invoice_num              = p_prepay_num
   AND ai.invoice_type_lookup_code = 'PREPAYMENT'
   AND ai.payment_status_flag      = 'Y'
   AND ai.vendor_id                = p_vendor_id
   AND NVL(ai.earliest_settlement_date,sysdate+1) <= SYSDATE;

  IF l_count  = 0 THEN
   l_reject_code := 'INVALID PREPAY INFO';
  END IF;

  l_debug_info := 'Get prepay_invoice_id ';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  IF l_reject_code IS NULL THEN
    SELECT invoice_id
      INTO p_prepay_invoice_id
      FROM ap_invoices
     WHERE invoice_num = p_prepay_num
     AND vendor_id = p_vendor_id;
  END IF;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_PREPAY_PKG.Check_Prepayment_Invoice(-)');
  END IF;

  RETURN (l_reject_code);

EXCEPTION
  WHEN OTHERS THEN
    app_exception.raise_exception;
END Check_Prepayment_Invoice;


FUNCTION Check_Prepayment_Line (
          p_prepay_num       IN VARCHAR2,
          p_prepay_line_num  IN NUMBER,
          p_vendor_id        IN NUMBER) RETURN VARCHAR2
IS

l_reject_code                        VARCHAR2(30) := NULL;

CURSOR C_Check_Prepay_Line_Apply_Info
         (cv_prepay_num      VARCHAR2,
          cv_prepay_line_num NUMBER,
          cv_vendor_id       NUMBER)
IS
SELECT DECODE(COUNT(*),
              0, 'INVALID PREPAY LINE NUM', NULL)
  FROM ap_invoices ai,
       ap_invoice_lines ail
 WHERE ai.invoice_num               = cv_prepay_num
   AND ail.line_number              = cv_prepay_line_num
   AND ail.invoice_id               = ai.invoice_id
   AND ai.invoice_type_lookup_code  = 'PREPAYMENT'
   AND ai.payment_status_flag       = 'Y'
   AND ai.vendor_id                 = cv_vendor_id
   AND NVL(ai.earliest_settlement_date,sysdate+1) <= SYSDATE
   AND ail.line_type_lookup_code    = 'ITEM'
   AND NVL(ail.discarded_flag,'N')  <> 'Y';

BEGIN

  OPEN  C_Check_Prepay_Line_Apply_Info
         (p_prepay_num,
          p_prepay_line_num,
          p_vendor_id);

  FETCH C_Check_Prepay_Line_Apply_Info
   INTO  l_reject_code;

  CLOSE C_Check_Prepay_Line_Apply_Info;

  RETURN (l_reject_code);

EXCEPTION
  WHEN OTHERS THEN
    IF C_Check_Prepay_Line_Apply_Info %ISOPEN THEN
      CLOSE C_Check_Prepay_Line_Apply_Info;
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Check_Prepayment_Line;


FUNCTION Check_Nothing_To_Apply_Line (
          p_prepay_invoice_id   IN NUMBER,
          p_prepay_line_num     IN NUMBER) RETURN VARCHAR2
IS
l_prepay_amount_remaining   NUMBER;
l_reject_code               VARCHAR2(30) := NULL;

CURSOR C_Check_No_Apply_Line_Amount
         (cv_prepay_invoice_id NUMBER,
          cv_prepay_line_num   NUMBER)
IS
SELECT SUM(NVL(aid.prepay_amount_remaining, aid.total_dist_amount))
  FROM ap_invoice_lines_all ail,
       ap_invoice_distributions_all aid
 WHERE ail.invoice_id                            = cv_prepay_invoice_id
   AND ail.line_number                           = cv_prepay_line_num
   AND NVL(ail.line_selected_for_appl_flag,'N') <> 'Y'
   AND aid.invoice_id                            = ail.invoice_id
   AND aid.invoice_line_number                   = ail.line_number
   AND aid.line_type_lookup_code IN ('ITEM', 'ACCRUAL', 'REC_TAX', 'NONREC_TAX')
   -- Included tax distributions for inclusive tax if any
   AND NVL(aid.reversal_flag,'N')               <> 'Y';

BEGIN

  OPEN  C_Check_No_Apply_Line_Amount
          (p_prepay_invoice_id,
           p_prepay_line_num);


  FETCH C_Check_No_Apply_Line_Amount
   INTO  l_prepay_amount_remaining;

  CLOSE C_Check_No_Apply_Line_Amount;

  IF NVL(l_prepay_amount_remaining,0) <= 0 THEN
    l_reject_code :=  'NOTHING TO APPLY';
  END IF;

  RETURN (l_reject_code);

EXCEPTION
  WHEN OTHERS THEN
    IF C_Check_No_Apply_Line_Amount %ISOPEN THEN
      CLOSE C_Check_No_Apply_Line_Amount;
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Check_Nothing_To_Apply_Line;


FUNCTION Check_Nothing_To_Apply_Invoice (
          p_prepay_invoice_id   IN NUMBER) RETURN VARCHAR2
IS
l_prepay_amount_remaining      NUMBER;
l_reject_code                  VARCHAR2(30) := NULL;

CURSOR C_Check_No_Apply_Inv_Amount
         (cv_prepay_invoice_id NUMBER)
IS
SELECT SUM(NVL(aid.prepay_amount_remaining, aid.total_dist_amount))
  FROM ap_invoice_lines_all ail,
       ap_invoice_distributions_all aid
 WHERE ail.invoice_id                            = cv_prepay_invoice_id
   AND ail.line_type_lookup_code <> 'TAX'
   AND NVL(ail.line_selected_for_appl_flag,'N') <> 'Y'
   AND aid.invoice_id                            = ail.invoice_id
   AND aid.invoice_line_number                   = ail.line_number
   AND aid.line_type_lookup_code IN ('ITEM', 'ACCRUAL', 'REC_TAX', 'NONREC_TAX')
   AND NVL(aid.reversal_flag,'N')               <> 'Y';
    -- Included tax distributions for inclusive tax if any and excluded
    -- any tax line (exclusive case)

BEGIN

  OPEN  C_Check_No_Apply_Inv_Amount
         (p_prepay_invoice_id);

  FETCH C_Check_No_Apply_Inv_Amount
            INTO  l_prepay_amount_remaining;

  CLOSE C_Check_No_Apply_Inv_Amount;

  IF NVL(l_prepay_amount_remaining,0) <= 0 THEN
    l_reject_code :=  'NOTHING TO APPLY';
  END IF;

  RETURN (l_reject_code);

EXCEPTION
  WHEN OTHERS THEN
    IF C_Check_No_Apply_Inv_Amount %ISOPEN THEN
      CLOSE C_Check_No_Apply_Inv_Amount;
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Check_Nothing_To_Apply_Invoice;


FUNCTION Check_Nothing_To_Apply_Vendor (
           p_vendor_id    IN NUMBER) RETURN VARCHAR2
IS
l_prepay_amount_remaining NUMBER;
l_reject_code             VARCHAR2(30) := NULL;

CURSOR C_Check_No_Apply_Vendor_Amount
         (cv_vendor_id NUMBER)
IS
SELECT SUM(NVL(aid.prepay_amount_remaining, aid.total_dist_amount))
  FROM ap_invoices ai,
       ap_invoice_lines ail,
       ap_invoice_distributions aid
 WHERE ai.vendor_id                                = cv_vendor_id
   AND ai.invoice_type_lookup_code                 = 'PREPAYMENT'
   AND ai.payment_status_flag                      = 'Y'
   AND NVL(ai.earliest_settlement_date,sysdate+1) <= SYSDATE
   AND ail.invoice_id                              = ai.invoice_id
   AND ail.line_type_lookup_code                   = 'ITEM'
   -- this will make sure exclusive TAX lines are not included
   AND NVL(ail.discarded_flag,'N')                <> 'Y'
   AND NVL(ail.line_selected_for_appl_flag,'N')   <> 'Y'
   AND aid.invoice_id                              = ail.invoice_id
   AND aid.invoice_line_number                     = ail.line_number
   AND aid.line_type_lookup_code IN ('ITEM', 'ACCRUAL', 'REC_TAX', 'NONREC_TAX')
   AND NVL(aid.reversal_flag,'N')                 <> 'Y';
   -- Included inclusive tax amount

BEGIN

  OPEN  C_Check_No_Apply_Vendor_Amount
         (p_vendor_id);

  FETCH C_Check_No_Apply_Vendor_Amount
   INTO  l_prepay_amount_remaining;

  CLOSE C_Check_No_Apply_Vendor_Amount;

  IF NVL(l_prepay_amount_remaining,0) <= 0 THEN
    l_reject_code :=  'NOTHING TO APPLY';
  END IF;

  RETURN (l_reject_code);

EXCEPTION
  WHEN OTHERS THEN
    IF C_Check_No_Apply_Vendor_Amount %ISOPEN THEN
      CLOSE C_Check_No_Apply_Vendor_Amount;
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Check_Nothing_To_Apply_Vendor;


FUNCTION Check_Period_Status (
          p_prepay_gl_date       IN OUT NOCOPY DATE,
          p_prepay_period_name   IN OUT NOCOPY VARCHAR2) RETURN VARCHAR2
IS

l_reject_code                        VARCHAR2(30) := NULL;

CURSOR C_Get_Period_Name
         (cv_gl_date DATE) IS
SELECT G.period_name
  FROM gl_period_statuses G,
       ap_system_parameters P
 WHERE G.application_id                   = 200
   AND G.set_of_books_id                  = P.set_of_books_id
   AND TRUNC(cv_gl_date) BETWEEN G.start_date AND
                                 G.end_date
   AND G.closing_status                   IN ('O', 'F')
   AND NVL(G.adjustment_period_flag, 'N') = 'N';

BEGIN

  IF p_prepay_gl_date IS NULL THEN
    P_prepay_gl_date := SYSDATE;
  END IF;

  OPEN C_Get_Period_Name
          (p_prepay_gl_date);

  FETCH C_Get_Period_Name
   INTO  p_prepay_period_name;

  IF C_Get_Period_Name%NOTFOUND THEN
    l_reject_code := 'PP GL DATE IN CLOSED PD';
  END IF;

  CLOSE c_get_period_name;

  RETURN (l_reject_code);

EXCEPTION
  WHEN OTHERS THEN
    IF C_Get_Period_Name %ISOPEN THEN
      CLOSE C_Get_Period_Name;
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Check_Period_Status;


FUNCTION Validate_Prepay_Info (
          p_prepay_case_name        IN         VARCHAR2,
          p_prepay_num              IN         OUT NOCOPY VARCHAR2,
          p_prepay_line_num         IN         OUT NOCOPY NUMBER,
          p_prepay_apply_amount     IN         OUT NOCOPY NUMBER, -- Bug 7004765
          p_invoice_amount          IN         NUMBER,
          p_prepay_gl_date          IN         OUT NOCOPY DATE,
          p_prepay_period_name      IN         OUT NOCOPY VARCHAR2,
          p_vendor_id               IN         NUMBER,
          p_import_invoice_id       IN         NUMBER,
          p_source                  IN         VARCHAR2,
          p_apply_advances_flag     IN         VARCHAR2,
          p_invoice_date            IN         DATE,
          p_base_currency_code      IN         VARCHAR2,
          p_invoice_currency_code   IN         VARCHAR2,
          p_payment_currency_code   IN         VARCHAR2,
          p_calling_sequence        IN         VARCHAR2,
          p_prepay_invoice_id       OUT NOCOPY NUMBER,
	  p_invoice_type_lookup_code IN        VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 -- Bug 7004765
IS

  l_reject_code    VARCHAR2(30) := NULL;
  l_debug_info     VARCHAR2(4000);      --Changed length from 100 to 4000(8534097)
  l_api_name	   VARCHAR2(50);

BEGIN
  l_api_name := 'Validate_Prepay_Info';

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_PREPAY_PKG.Validate_Prepay_Info(+)');
  END IF;

  IF p_prepay_case_name = 'DO_NOTHING_CASE' THEN

    l_debug_info  := 'Import - No Prepay related information is given and '||
                     'apply advances flag is set to N';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    l_reject_code := NULL;
    RETURN (l_reject_code);

  ELSIF p_prepay_case_name = 'INVALID_CASE' THEN

    l_debug_info  := 'Import - Insufficient Prepayment information provided';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    l_reject_code := 'INSUFFICIENT PREPAY INFO';
    RETURN (l_reject_code);

  END IF;

  IF p_prepay_case_name IN (
          'LINE_PREPAY_APPL_WITH_AMOUNT',
          'INV_PREPAY_APPL_WITH_AMOUNT',
          'VND_PREPAY_APPL_WITH_AMOUNT') THEN

    IF p_prepay_apply_amount <= 0 THEN

      l_debug_info  := 'Import - Apply amount should be positive and non zero';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;

      l_reject_code := 'CANNOT APPLY ZERO OR NEG';

      RETURN (l_reject_code);

    END IF;
  END IF;

  IF p_prepay_case_name IN (
          'LINE_PREPAY_APPL_WITH_AMOUNT',
          'INV_PREPAY_APPL_WITH_AMOUNT',
          'LINE_PREPAY_APPL_WITHOUT_AMOUNT',
          'INV_PREPAY_APPL_WITHOUT_AMOUNT') THEN

    l_debug_info  := 'Import - Check Supplier Consistency';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    l_reject_code := Check_Supplier_Consistency
         (p_prepay_num,
          p_vendor_id);

    IF l_reject_code IS NOT NULL THEN
      RETURN (l_reject_code);
    END IF;

    l_debug_info  := 'Import - Check Currency Consistency';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    l_reject_code := Check_Currency_Consistency
         (p_prepay_num,
          p_vendor_id,
          p_base_currency_code,
          p_invoice_currency_code,
          p_payment_currency_code);

    IF l_reject_code IS NOT NULL THEN
      RETURN (l_reject_code);
    END IF;

    l_debug_info  := 'Import - Check Prepayment Validity';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    l_reject_code := Check_Prepayment_Invoice
         (p_prepay_num,
          p_vendor_id,
          p_prepay_invoice_id);

    IF l_reject_code IS NOT NULL THEN
      RETURN (l_reject_code);
    END IF;

    IF p_prepay_case_name IN (
          --'INV_PREPAY_APPL_WITH_AMOUNT',  Bug5506845
          'LINE_PREPAY_APPL_WITH_AMOUNT',
          --'INV_PREPAY_APPL_WITHOUT_AMOUNT', Bug5506845
          'LINE_PREPAY_APPL_WITHOUT_AMOUNT') THEN
      l_debug_info := 'Import - Check Prepayment Line Validity';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;

      l_reject_code := Check_Prepayment_Line
         (p_prepay_num,
          p_prepay_line_num,
          p_vendor_id);


      IF l_reject_code IS NOT NULL THEN
        RETURN (l_reject_code);
      END IF;
    END IF;

    IF p_prepay_case_name IN (
          'LINE_PREPAY_APPL_WITHOUT_AMOUNT',
          'LINE_PREPAY_APPL_WITH_AMOUNT') THEN
      l_debug_info := 'Import - Check Nothing to Apply in this Prepay Line';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;

      l_reject_code := Check_Nothing_To_Apply_Line
         (p_prepay_invoice_id,
          p_prepay_line_num);

      IF l_reject_code IS NOT NULL THEN
	 IF p_invoice_type_lookup_code = 'EXPENSE REPORT'   -- Bug 7004765
	    or p_source in ('SelfService', 'XpenseXpress')  THEN
		l_debug_info := 'Import - Nothing to Apply in this Prepay Line. But not REJECTING an ER invoice';
      		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        	  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      		END IF;
		p_prepay_apply_amount := null;
		p_prepay_line_num := null;
		p_prepay_num := null;
	 ELSE
            RETURN (l_reject_code);
	 END IF;
      END IF;
    END IF;

    IF p_prepay_case_name IN (
          'INV_PREPAY_APPL_WITHOUT_AMOUNT',
          'INV_PREPAY_APPL_WITH_AMOUNT') THEN
      l_debug_info := 'Import - Check Nothing to Apply in this Prepay Invoice';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;

      l_reject_code := Check_Nothing_To_Apply_Invoice
         (p_prepay_invoice_id);

      IF l_reject_code IS NOT NULL THEN
	 IF p_invoice_type_lookup_code = 'EXPENSE REPORT'  -- Bug 7004765
	    or p_source in ('SelfService', 'XpenseXpress')  THEN
		l_debug_info := 'Import - Nothing to Apply in this Prepay Line. But not REJECTING an ER invoice';
      		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        	  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      		END IF;
		p_prepay_apply_amount := null;
		p_prepay_num := null;
	 ELSE
            RETURN (l_reject_code);
	 END IF;
      END IF;
    END IF;
  END IF;

  IF p_prepay_case_name IN (
          'VND_PREPAY_APPL_WITHOUT_AMOUNT',
          'VND_PREPAY_APPL_WITH_AMOUNT') THEN
    l_debug_info := 'Import - Check Nothing to Apply for this vendor';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    l_reject_code := Check_Nothing_To_Apply_Vendor (p_vendor_id);

    IF l_reject_code IS NOT NULL THEN
	 IF p_invoice_type_lookup_code = 'EXPENSE REPORT' -- Bug 7004765
	    or p_source in ('SelfService', 'XpenseXpress')  THEN
		l_debug_info := 'Import - Nothing to Apply in this Prepay Line. But not REJECTING an ER invoice';
      		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        	  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      		END IF;
		p_prepay_apply_amount := null;
	 ELSE
            RETURN (l_reject_code);
	 END IF;
    END IF;
  END IF;

  l_debug_info := 'Import - Check Period Status';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  l_reject_code := Check_Period_Status
         (p_prepay_gl_date,
          p_prepay_period_name);

  IF l_reject_code IS NOT NULL THEN
    RETURN (l_reject_code);
  END IF;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_PREPAY_PKG.Validate_Prepay_Info(-)');
  END IF;

  RETURN (l_reject_code);

EXCEPTION
  WHEN OTHERS THEN
    APP_EXCEPTION.RAISE_EXCEPTION;
END Validate_Prepay_Info;


FUNCTION Get_Prepay_Case_Name (
          p_prepay_num               IN VARCHAR2,
          p_prepay_line_num          IN NUMBER,
          p_prepay_apply_amount      IN NUMBER,
          p_source                   IN VARCHAR2,
          p_apply_advances_flag      IN VARCHAR2,
          p_calling_sequence         IN VARCHAR2) RETURN VARCHAR2
IS

  l_prepay_case_name     VARCHAR2(100);
  l_api_name		 VARCHAR2(50);
  l_debug_info		 VARCHAR2(4000);

BEGIN
  l_api_name := 'Get_Prepay_Case_Name';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_PREPAY_PKG.Get_Prepay_Case_Name(+)');
  END IF;

  l_debug_info := 'Derive case name';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  IF (p_prepay_num             IS NOT NULL AND
      p_prepay_line_num        IS NOT NULL AND
      p_prepay_apply_amount    IS NOT NULL) THEN

    l_prepay_case_name := 'LINE_PREPAY_APPL_WITH_AMOUNT';

  ELSIF (p_prepay_num          IS NOT NULL AND
         p_prepay_line_num     IS NOT NULL AND
         p_prepay_apply_amount IS NULL) THEN

    l_prepay_case_name := 'LINE_PREPAY_APPL_WITHOUT_AMOUNT';

  ELSIF (p_prepay_num          IS NOT NULL AND
         p_prepay_line_num     IS NULL AND
         p_prepay_apply_amount IS NOT NULL) THEN

    l_prepay_case_name := 'INV_PREPAY_APPL_WITH_AMOUNT';

  ELSIF (p_prepay_num          IS NOT NULL AND
         p_prepay_line_num     IS NULL AND
         p_prepay_apply_amount IS NULL) THEN

    l_prepay_case_name := 'INV_PREPAY_APPL_WITHOUT_AMOUNT';

  ELSIF (p_prepay_num          IS NULL AND
         p_prepay_line_num     IS NULL AND
         p_prepay_apply_amount IS NOT NULL) THEN

    l_prepay_case_name := 'VND_PREPAY_APPL_WITH_AMOUNT';

  ELSIF (p_prepay_num          IS NULL AND
         p_prepay_line_num     IS NULL AND
         p_prepay_apply_amount IS NULL AND
         p_source              IN ('SelfService', 'XpenseXpress') AND
         NVl(p_apply_advances_flag,'N') = 'Y') THEN

    l_prepay_case_name := 'VND_PREPAY_APPL_WITHOUT_AMOUNT_EXP';

  ELSIF (p_prepay_num          IS NULL AND
         p_prepay_line_num     IS NULL AND
         p_prepay_apply_amount IS NULL AND
         p_source          NOT IN ('SelfService', 'XpenseXpress') AND
         NVl(p_apply_advances_flag,'N') = 'Y') THEN

    l_prepay_case_name := 'VND_PREPAY_APPL_WITHOUT_AMOUNT';

  ELSIF (p_prepay_num          IS NULL AND
         p_prepay_line_num     IS NULL AND
         p_prepay_apply_amount IS NULL AND
         NVl(p_apply_advances_flag,'N') = 'N') THEN

    l_prepay_case_name := 'DO_NOTHING_CASE';

  ELSE
    l_prepay_case_name := 'INVALID_CASE';

  END IF;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_PREPAY_PKG.Get_Prepay_Case_Name(-)');
  END IF;

  RETURN (l_prepay_case_name);

EXCEPTION
  WHEN OTHERS THEN
    APP_EXCEPTION.RAISE_EXCEPTION;
END Get_Prepay_Case_Name;


FUNCTION get_prepay_apply_amount(
          p_prepay_case_name        VARCHAR2,
          p_prepay_invoice_id       NUMBER,
          P_prepay_line_num         NUMBER,
          p_prepay_apply_amount     NUMBER,
          p_invoice_id              NUMBER,
          p_vendor_id               NUMBER,
          p_prepay_included         VARCHAR2) RETURN NUMBER
IS
  l_prepay_apply_amount       NUMBER := p_prepay_apply_amount;
  l_invoice_amount_remaining  NUMBER;
  l_prepay_amount_remaining   NUMBER;

BEGIN
  -- Get the Invoice Amount Remaining for the standard invoice.
  -- This is the unpaid amount.  Since we are importing the invoice
  -- there is no posibility of partial payment of the invoice, so
  -- there is no need to verify the payment_status flag.

 /* Start of fix for bug8692604 */
 /*    SELECT SUM(NVL(aid.amount,0))
       INTO l_invoice_amount_remaining
       FROM ap_invoice_distributions_all aid, ap_invoice_lines_all ail
      WHERE ail.invoice_id   = p_invoice_id
        AND ail.invoice_id = aid.invoice_id
        AND ail.line_number = aid.invoice_line_number
	--Contract Payments: Although Recoupment is modelled as 'PREPAY' dists
	--amount_recouped will effect the invoice_amount_remaining
	--regardless of invoice_includes_prepay_flag.
        AND ((ail.line_type_lookup_code = 'PREPAY' and
	       ((aid.line_type_lookup_code <> 'PREPAY'
                 and aid.prepay_distribution_id IS NULL
                )
               or  NVL(ail.invoice_includes_prepay_flag,'N') = 'Y'
               )
             ) OR
             (ail.line_type_lookup_code <> 'PREPAY')
       	    );  */

  select sum(nvl(amount,0))
 into l_invoice_amount_remaining
 from ap_invoice_lines_all
where invoice_id = p_invoice_id
and line_type_lookup_code <> 'PREPAY';
/* End of fix for bug8692604 */

  -- Get the correct Prepay Amount Remaining and hence the correct
  -- Apply Amount and Additional Amount if Applicable.

  IF p_prepay_case_name IN ('LINE_PREPAY_APPL_WITH_AMOUNT',
                            'LINE_PREPAY_APPL_WITHOUT_AMOUNT') THEN

    -- Get the Prepay Amount Remaining
    SELECT  SUM(NVL(aid.prepay_amount_remaining, aid.total_dist_amount))
      INTO  l_prepay_amount_remaining
      FROM  ap_invoice_lines_all ail,
            ap_invoice_distributions_all aid
     WHERE  ail.invoice_id                            = p_prepay_invoice_id
       AND  ail.line_number                           = p_prepay_line_num
       AND  ail.line_type_lookup_code                 = 'ITEM'
       AND  NVL(ail.discarded_flag,'N')              <> 'Y'
       AND  NVL(ail.line_selected_for_appl_flag,'N') <> 'Y'
       AND  aid.invoice_id                            = ail.invoice_id
       AND  aid.invoice_line_number                   = ail.line_number
       AND  aid.line_type_lookup_code
            IN ('ITEM','ACCRUAL','REC_TAX','NONREC_TAX')
       AND  nvl(aid.reversal_flag,'N')               <> 'Y';
      -- eTax Uptake.  Included inclusive tax distributions

    IF p_prepay_apply_amount is NOT NULL THEN

      IF (p_prepay_apply_amount > l_prepay_amount_remaining) THEN
        l_prepay_apply_amount := l_prepay_amount_remaining;
      END IF;

      IF (l_invoice_amount_remaining < l_prepay_apply_amount) THEN
        l_prepay_apply_amount := l_invoice_amount_remaining;
      END IF;
    ELSE
      IF (l_invoice_amount_remaining <= l_prepay_amount_remaining) THEN
        l_prepay_apply_amount := l_invoice_amount_remaining;
      ELSE
        l_prepay_apply_amount := l_prepay_amount_remaining;
      END IF;
    END IF;
  END IF;

  IF p_prepay_case_name IN ('INV_PREPAY_APPL_WITH_AMOUNT',
                            'INV_PREPAY_APPL_WITHOUT_AMOUNT') THEN

    -- Get the Prepay Amount Remaining
    SELECT  SUM(NVL(aid.prepay_amount_remaining, aid.total_dist_amount))
      INTO  l_prepay_amount_remaining
      FROM  ap_invoice_lines_all ail,
            ap_invoice_distributions_all aid
     WHERE  ail.invoice_id                  = p_prepay_invoice_id
       AND  ail.line_type_lookup_code       = 'ITEM'
       AND  NVL(ail.discarded_flag,'N')     <> 'Y'
       AND  NVL(ail.line_selected_for_appl_flag, 'N') <> 'Y'
       AND  aid.invoice_id                  = ail.invoice_id
       AND  aid.invoice_line_number         = ail.line_number
       AND  aid.line_type_lookup_code
            IN ( 'ITEM','ACCRUAL','REC_TAX','NONREC_TAX')
       AND  NVL(aid.reversal_flag,'N')      <> 'Y';
      -- eTax Uptake.  Included inclusive tax distributions.  No TAX
      -- lines included (exclusive case)

    IF p_prepay_apply_amount is NOT NULL THEN
      IF (p_prepay_apply_amount > l_prepay_amount_remaining) THEN
        l_prepay_apply_amount := l_prepay_amount_remaining;
      END IF;

      IF (l_invoice_amount_remaining < l_prepay_apply_amount) THEN
        l_prepay_apply_amount := l_invoice_amount_remaining;
      END IF;
    ELSE
      IF (l_invoice_amount_remaining <= l_prepay_amount_remaining) THEN
        l_prepay_apply_amount := l_invoice_amount_remaining;
      ELSE
        l_prepay_apply_amount := l_prepay_amount_remaining;
      END IF;
    END IF;
  END IF;

  IF p_prepay_case_name IN ('VND_PREPAY_APPL_WITH_AMOUNT',
                            'VND_PREPAY_APPL_WITHOUT_AMOUNT',
                            'VND_PREPAY_APPL_WITHOUT_AMOUNT_EXP') THEN
    -- Get the Prepay Amount Remaining
    SELECT SUM(NVL(aid.prepay_amount_remaining, aid.total_dist_amount))
      INTO l_prepay_amount_remaining
      FROM ap_invoices ai,
           ap_invoice_lines ail,
           ap_invoice_distributions aid
     WHERE ai.vendor_id                                = p_vendor_id
       AND ai.invoice_type_lookup_code                 = 'PREPAYMENT'
       AND nvl(ai.earliest_settlement_date,sysdate+1) <= SYSDATE
       AND ai.payment_status_flag                      = 'Y'
       AND ail.invoice_id                              = ai.invoice_id
       AND ail.line_type_lookup_code                   = 'ITEM'
       AND NVL(ail.discarded_flag,'N')                 <> 'Y'
       AND NVL(ail.line_selected_for_appl_flag, 'N')   <> 'Y'
       AND aid.invoice_id                              = ail.invoice_id
       AND aid.invoice_line_number                     = ail.line_number
       AND aid.line_type_lookup_code
           IN ( 'ITEM','ACCRUAL','REC_TAX','NONREC_TAX')
       AND NVL(aid.reversal_flag,'N')                 <> 'Y';
       -- eTax Uptake.  Included inclusive tax distributions

    IF p_prepay_apply_amount is NOT NULL THEN
      IF (p_prepay_apply_amount > l_prepay_amount_remaining) THEN
        l_prepay_apply_amount := l_prepay_amount_remaining;
      END IF;

      IF (l_invoice_amount_remaining < l_prepay_apply_amount) THEN
        l_prepay_apply_amount := l_invoice_amount_remaining;
      END IF;
    ELSE
      IF (l_invoice_amount_remaining <= l_prepay_amount_remaining) THEN
        l_prepay_apply_amount := l_invoice_amount_remaining;
      ELSE
        l_prepay_apply_amount := l_prepay_amount_remaining;
      END IF;
    END IF;
  END IF;

  RETURN (l_prepay_apply_amount);

EXCEPTION
  WHEN OTHERS THEN
    APP_EXCEPTION.RAISE_EXCEPTION;
END get_prepay_apply_amount;


PROCEDURE Select_Lines_For_Application (
          p_prepay_case_name   IN VARCHAR2,
          p_prepay_invoice_id  IN NUMBER,
          p_prepay_line_num    IN NUMBER,
          p_apply_amount       IN NUMBER,
          p_vendor_id          IN NUMBER,
          p_calling_sequence   IN VARCHAR2,
          p_request_id         IN NUMBER,
          p_invoice_id         IN NUMBER, -- Bug 6394865
          p_prepay_appl_info   OUT NOCOPY ap_prepay_pkg.prepay_appl_tab)
IS

  l_application_result       BOOLEAN;
  l_apply_amount_remaining   NUMBER;
  l_cur_invoice_id           NUMBER;
  l_prepay_invoice_num       VARCHAR2(50);
  l_prepay_line_num          NUMBER;
  l_cursor_amount_remaining  NUMBER;
  l_loop_counter             BINARY_INTEGER := 1;
  l_request_id               NUMBER := p_request_id;
  l_is_line_locked           VARCHAR2(100);
  l_lock_result              BOOLEAN;
  l_invoice_currency_code    ap_invoices_all.INVOICE_CURRENCY_CODE%TYPE; -- Bug 6394865
  l_payment_currency_code    ap_invoices_all.PAYMENT_CURRENCY_CODE%TYPE; -- Bug 6394865

CURSOR C_INV_LEVEL_APPLY (cv_prepay_invoice_id IN NUMBER)
IS
SELECT ai.invoice_id,
       ail.line_number,
       AP_Prepay_Utils_PKG.Get_Line_Prepay_AMT_Remaining
                           (ail.invoice_id,
                            ail.line_number)
  FROM ap_invoices_all ai,
       ap_invoice_lines_all ail
 WHERE ai.invoice_id                             = cv_prepay_invoice_id
   AND ail.invoice_id                            = ai.invoice_id
   AND AP_Prepay_Utils_PKG.Get_Line_Prepay_AMT_Remaining
                           (ail.invoice_id,
                            ail.line_number)     > 0
   AND ail.line_type_lookup_code                 = 'ITEM'
   AND NVL(ail.discarded_flag,'N')              <> 'Y'
   AND NVL(ail.line_selected_for_appl_flag,'N') <> 'Y'
 ORDER BY ail.line_number;
  -- The application is based only in ITEM lines.  No TAX
  -- lines should be included

CURSOR C_VND_LEVEL_APPLY (cv_vendor_id IN NUMBER,
                          cv_invoice_currency_code IN ap_invoices_all.INVOICE_CURRENCY_CODE%TYPE,
                          cv_payment_currency_code IN ap_invoices_all.INVOICE_CURRENCY_CODE%TYPE)
                          -- Bug 6394865
IS
SELECT ai.invoice_id,
       ail.line_number,
       AP_Prepay_Utils_PKG.Get_Line_Prepay_AMT_Remaining
                           (ail.invoice_id,
                            ail.line_number)
  FROM ap_invoices ai,
       ap_invoice_lines ail
 WHERE ai.vendor_id                                = cv_vendor_id
   AND ai.invoice_type_lookup_code                 = 'PREPAYMENT'
   AND ai.payment_status_flag                      = 'Y'
   AND NVL(ai.earliest_settlement_date,SYSDATE+1) <= SYSDATE
   AND ail.invoice_id = ai.invoice_id
   AND AP_Prepay_Utils_PKG.Get_Line_Prepay_AMT_Remaining
                           (ail.invoice_id,
                            ail.line_number)       > 0
   AND ail.line_type_lookup_code                   = 'ITEM'
   AND NVL(ail.discarded_flag,'N')                <> 'Y'
   AND NVL(ail.line_selected_for_appl_flag,'N')   <> 'Y'
   AND ai.invoice_currency_code = cv_invoice_currency_code -- Bug 6394865
   AND ai.payment_currency_code = cv_payment_currency_code -- Bug 6394865
 ORDER BY ai.gl_date,
          ai.invoice_id,
          ail.line_number;

BEGIN
  -- Clear unwanted buffers
  p_prepay_appl_info.DELETE;

  l_apply_amount_remaining := p_apply_amount;

  IF p_prepay_case_name IN ('LINE_PREPAY_APPL_WITH_AMOUNT',
                            'LINE_PREPAY_APPL_WITHOUT_AMOUNT') THEN

    -- Lock the line if not locked and populate the application info
    -- into a PL/SQL table.

    l_is_line_locked := AP_PREPAY_UTILS_PKG.Is_Line_Locked (
           p_prepay_invoice_id,
           p_prepay_line_num,
           l_request_id);

    IF l_is_line_locked = 'UNLOCKED' THEN

       l_lock_result := AP_PREPAY_UTILS_PKG.Lock_Line(
                           p_prepay_invoice_id,
                           p_prepay_line_num,
                           l_request_id);

       -- Populate the PL/SQL table

       p_prepay_appl_info(l_loop_counter).prepay_invoice_id   := p_prepay_invoice_id;
       p_prepay_appl_info(l_loop_counter).prepay_line_num     := p_prepay_line_num;
       p_prepay_appl_info(l_loop_counter).prepay_apply_amount := p_apply_amount;

    END IF;
  END IF;

  IF p_prepay_case_name IN ('INV_PREPAY_APPL_WITH_AMOUNT',
                            'INV_PREPAY_APPL_WITHOUT_AMOUNT') THEN
    OPEN C_INV_LEVEL_APPLY (p_prepay_invoice_id);
    LOOP
      FETCH C_INV_LEVEL_APPLY
       INTO  l_cur_invoice_id,
             l_prepay_line_num,
             l_cursor_amount_remaining;

      EXIT WHEN C_INV_LEVEL_APPLY%NOTFOUND;

      IF l_apply_amount_remaining <= l_cursor_amount_remaining THEN

        l_lock_result := AP_PREPAY_UTILS_PKG.Lock_Line(
             p_prepay_invoice_id,
             p_prepay_line_num,
             l_request_id);

        -- Populate the PL/SQL table

        p_prepay_appl_info(l_loop_counter).prepay_invoice_id   := l_cur_invoice_id;
        p_prepay_appl_info(l_loop_counter).prepay_line_num     := l_prepay_line_num;
        p_prepay_appl_info(l_loop_counter).prepay_apply_amount := l_apply_amount_remaining;

        EXIT;
      ELSE
        l_lock_result := AP_PREPAY_UTILS_PKG.Lock_Line(
             p_prepay_invoice_id,
             p_prepay_line_num,
             l_request_id);

        -- Populate the PL/SQL table

        p_prepay_appl_info(l_loop_counter).prepay_invoice_id   := l_cur_invoice_id;
        p_prepay_appl_info(l_loop_counter).prepay_line_num     := l_prepay_line_num;
        p_prepay_appl_info(l_loop_counter).prepay_apply_amount := l_cursor_amount_remaining;

        l_loop_counter := l_loop_counter + 1;

        l_apply_amount_remaining :=
                l_apply_amount_remaining -
                l_cursor_amount_remaining;

      END IF;
    END LOOP;

    CLOSE C_INV_LEVEL_APPLY;

  END IF;

  IF p_prepay_case_name IN ('VND_PREPAY_APPL_WITH_AMOUNT',
                            'VND_PREPAY_APPL_WITHOUT_AMOUNT') THEN

    select invoice_currency_code, payment_currency_code
      into l_invoice_currency_code, l_payment_currency_code
    from ap_invoices where invoice_id = p_invoice_id; -- Bug 6394865

    OPEN C_VND_LEVEL_APPLY (p_vendor_id, l_invoice_currency_code,
                                         l_payment_currency_code); -- Bug 6394865
    LOOP
      FETCH C_VND_LEVEL_APPLY
       INTO l_cur_invoice_id,
            l_prepay_line_num,
            l_cursor_amount_remaining;

      EXIT WHEN C_VND_LEVEL_APPLY%NOTFOUND;

      IF l_apply_amount_remaining <= l_cursor_amount_remaining THEN

        l_lock_result := AP_PREPAY_UTILS_PKG.Lock_Line(
             p_prepay_invoice_id,
             p_prepay_line_num,
             l_request_id);

        -- Populate the PL/SQL table

        p_prepay_appl_info(l_loop_counter).prepay_invoice_id   := l_cur_invoice_id;
        p_prepay_appl_info(l_loop_counter).prepay_line_num     := l_prepay_line_num;
        p_prepay_appl_info(l_loop_counter).prepay_apply_amount := l_apply_amount_remaining;

        EXIT;
      ELSE
        l_lock_result := AP_PREPAY_UTILS_PKG.Lock_Line(
             p_prepay_invoice_id,
             p_prepay_line_num,
             l_request_id);

        -- Populate the PL/SQL table

        p_prepay_appl_info(l_loop_counter).prepay_invoice_id := l_cur_invoice_id;
        p_prepay_appl_info(l_loop_counter).prepay_line_num := l_prepay_line_num;
        p_prepay_appl_info(l_loop_counter).prepay_apply_amount := l_cursor_amount_remaining;

        l_loop_counter := l_loop_counter + 1;

        l_apply_amount_remaining :=
                l_apply_amount_remaining -
                l_cursor_amount_remaining;
      END IF;
    END LOOP;

    CLOSE C_VND_LEVEL_APPLY;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF C_INV_LEVEL_APPLY%ISOPEN THEN
      CLOSE C_INV_LEVEL_APPLY;
    END IF;

    IF C_VND_LEVEL_APPLY%ISOPEN THEN
      CLOSE C_VND_LEVEL_APPLY;
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Select_Lines_For_Application;



FUNCTION Check_Prepay_Info_Import (
          p_prepay_num             IN OUT NOCOPY VARCHAR2,
          p_prepay_line_num        IN OUT NOCOPY NUMBER,
          p_prepay_apply_amount    IN OUT NOCOPY NUMBER,  -- Bug 7004765
          p_invoice_amount         IN         NUMBER,
          p_prepay_gl_date         IN OUT NOCOPY DATE,
          p_prepay_period_name     IN OUT NOCOPY VARCHAR2,
          p_vendor_id              IN         NUMBER,
          p_prepay_included        IN         VARCHAR2,
          p_import_invoice_id      IN         NUMBER,
          p_source                 IN         VARCHAR2,
          p_apply_advances_flag    IN         VARCHAR2,
          p_invoice_date           IN         DATE,
          p_base_currency_code     IN         VARCHAR2,
          p_invoice_currency_code  IN         VARCHAR2,
          p_payment_currency_code  IN         VARCHAR2,
          p_calling_sequence       IN         VARCHAR2,
          p_request_id             IN         NUMBER,
          p_prepay_case_name   	   OUT NOCOPY VARCHAR2,
          p_prepay_invoice_id      OUT NOCOPY NUMBER,
	  p_invoice_type_lookup_code IN VARCHAR2 DEFAULT NULL)   -- Bug 7004765
RETURN VARCHAR2 IS

  l_reject_code         VARCHAR2(30);
  l_apply_amount        NUMBER;
  l_api_name 	        VARCHAR2(50);
  l_debug_info 		VARCHAR2(4000);

BEGIN

  l_api_name := 'Check_Prepay_Info_Import';

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_PREPAY_PKG.Check_Prepay_Info_Import(+)');
  END IF;

  p_prepay_invoice_id := p_import_invoice_id;

  -- ============================================================================
  -- Step 1: Identify the case name based on the prepayment information provided.
  -- ============================================================================
  l_debug_info := 'Call Get_Prepay_Case_Name';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  p_prepay_case_name := Get_Prepay_Case_Name (
          p_prepay_num,
          p_prepay_line_num,
          p_prepay_apply_amount,
          p_source,
          p_apply_advances_flag,
          p_calling_sequence);

  -- ============================================================================
  -- Step 2: Validate the prepayment information provided based on the Case Name.
  -- ============================================================================

  l_debug_info := 'Call Validate_Prepay_Info';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  l_reject_code := Validate_Prepay_Info (
          p_prepay_case_name,
          p_prepay_num,
          p_prepay_line_num,
          p_prepay_apply_amount,
          p_invoice_amount,
          p_prepay_gl_date,
          p_prepay_period_name,
          p_vendor_id,
          p_import_invoice_id,
          p_source,
          p_apply_advances_flag,
          p_invoice_date,
          p_base_currency_code,
          p_invoice_currency_code,
          p_payment_currency_code,
          p_calling_sequence,
          p_prepay_invoice_id,
	  p_invoice_type_lookup_code);  -- Bug 7004765

  IF l_reject_code IS NOT NULL THEN
    RETURN (l_reject_code);
  END IF;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_PREPAY_PKG.Check_Prepay_Info_Import(-)');
  END IF;

  RETURN (l_reject_code);

EXCEPTION
WHEN OTHERS THEN
  APP_EXCEPTION.RAISE_EXCEPTION;
END Check_Prepay_Info_Import;


PROCEDURE Get_Prepay_Info_Import (
	  p_prepay_case_name	IN	      VARCHAR2,
	  p_prepay_invoice_id   IN	      NUMBER,
          p_prepay_num          IN            VARCHAR2,
          p_prepay_line_num     IN            NUMBER,
          p_prepay_apply_amount IN            NUMBER,
	  p_prepay_included	IN	      VARCHAR2,
          p_import_invoice_id   IN	      NUMBER,
	  p_vendor_id		IN	      NUMBER,
	  p_request_id		IN	      NUMBER,
	  p_prepay_appl_info    OUT NOCOPY    ap_prepay_pkg.prepay_appl_tab,
	  p_calling_sequence	IN	      VARCHAR2) IS

  l_apply_amount   NUMBER;
BEGIN

  l_apply_amount := get_prepay_apply_amount(
          p_prepay_case_name,
          p_prepay_invoice_id,
          p_prepay_line_num,
          p_prepay_apply_amount,
          p_import_invoice_id,
          p_vendor_id,
          p_prepay_included);

  --============================================================================
  -- Step 4: Select/lock the lines for prepayment application
  --============================================================================

  Select_Lines_For_Application (
          p_prepay_case_name,
          p_prepay_invoice_id,
          p_prepay_line_num,
          l_apply_amount,
          p_vendor_id,
          p_calling_sequence,
          p_request_id,
          p_import_invoice_id, -- Bug 6394865
          p_prepay_appl_info);

EXCEPTION
WHEN OTHERS THEN
 APP_EXCEPTION.RAISE_EXCEPTION;
END Get_Prepay_Info_Import;


PROCEDURE Apply_Prepay_Import (
          p_prepay_invoice_id     IN NUMBER,
	  p_prepay_num		  IN VARCHAR2,
	  p_prepay_line_num	  IN NUMBER,
	  p_prepay_apply_amount   IN NUMBER,
	  p_prepay_case_name      IN VARCHAR2,
	  p_import_invoice_id	  IN NUMBER,
	  p_request_id		  IN NUMBER,
          p_invoice_id            IN NUMBER,
          p_vendor_id             IN NUMBER,
          p_prepay_gl_date        IN DATE,
          p_prepay_period_name    IN VARCHAR2,
          p_prepay_included       IN VARCHAR2,
          p_user_id               IN NUMBER,
          p_last_update_login     IN NUMBER,
          p_calling_sequence      IN VARCHAR2,
          p_prepay_appl_log       OUT NOCOPY ap_prepay_pkg.Prepay_Appl_Log_Tab)
IS
  l_prepay_apply_amount  NUMBER;
  l_loop_counter         BINARY_INTEGER;
  l_dummy                BOOLEAN;
  l_error_message        VARCHAR2(2000);
  l_prepay_appl_info	 ap_prepay_pkg.prepay_appl_tab;
  l_prepay_dist_info     AP_PREPAY_PKG.PREPAY_DIST_TAB_TYPE;
  l_curr_calling_sequence VARCHAR2(2000);
BEGIN


  l_curr_calling_sequence := 'Apply_Prepay_Import <-'||p_calling_sequence;

  AP_PREPAY_PKG.Get_Prepay_Info_Import(
  		P_Prepay_Case_Name     => p_prepay_case_name,
		P_Prepay_Invoice_Id    => p_prepay_invoice_id,
		P_Prepay_Num           => p_prepay_num,
		P_Prepay_Line_Num      => p_prepay_line_num,
		P_Prepay_Apply_Amount  => p_prepay_apply_amount,
		P_Prepay_Included      => p_prepay_included,
		P_Import_Invoice_Id    => p_invoice_id, -- p_import_invoice_id, Modified for bug 7110038
		P_Vendor_Id            => p_vendor_id,
		P_Request_Id           => p_request_id,
		P_Prepay_Appl_Info     => l_prepay_appl_info,
		P_Calling_Sequence     => l_curr_calling_sequence);

  IF l_prepay_appl_info.count <=0 THEN
    RETURN;
  END IF;

  FOR l_loop_counter IN NVL(l_prepay_appl_info.FIRST,0) .. NVL(l_prepay_appl_info.LAST,0) LOOP

    -- Call the Apply_Prepay_line API to apply the prepayment
    IF (AP_PREPAY_PKG.Apply_Prepay_Line (
          l_prepay_appl_info(l_loop_counter).prepay_invoice_id,
          l_prepay_appl_info(l_loop_counter).prepay_line_num,
          l_prepay_dist_info,
          'Y',
          p_invoice_id,
          NULL, --p_invoice_line_number
          l_prepay_appl_info(l_loop_counter).prepay_apply_amount,
          p_prepay_gl_date,
          p_prepay_period_name,
          p_prepay_included,
          p_user_id,
          p_last_update_login,
          p_calling_sequence,
	  'PREPAYMENT APPLICATION',
          l_error_message) = FALSE ) THEN

      p_prepay_appl_log(l_loop_counter).success := 'N';

      p_prepay_appl_log(l_loop_counter).error_message := l_error_message;

    ELSE

      p_prepay_appl_log(l_loop_counter).success := 'Y';

    END IF;

    p_prepay_appl_log(l_loop_counter).prepay_invoice_id :=
        l_prepay_appl_info(l_loop_counter).prepay_invoice_id;

    p_prepay_appl_log(l_loop_counter).prepay_line_num :=
        l_prepay_appl_info(l_loop_counter).prepay_line_num;

    p_prepay_appl_log(l_loop_counter).prepay_apply_amount :=
        l_prepay_appl_info(l_loop_counter).prepay_apply_amount;

  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    APP_EXCEPTION.RAISE_EXCEPTION;
END Apply_Prepay_Import;



FUNCTION Apply_Prepay_Line (
          P_PREPAY_INVOICE_ID IN         NUMBER,
          P_PREPAY_LINE_NUM   IN         NUMBER,
          P_PREPAY_DIST_INFO  IN OUT NOCOPY AP_PREPAY_PKG.PREPAY_DIST_TAB_TYPE,
          P_PRORATE_FLAG      IN         VARCHAR2,
          P_INVOICE_ID        IN         NUMBER,
	  /*Contract Payments*/
	  P_INVOICE_LINE_NUMBER IN	 NUMBER DEFAULT NULL,
          P_APPLY_AMOUNT      IN         NUMBER,
          P_GL_DATE           IN         DATE,
          P_PERIOD_NAME       IN         VARCHAR2,
          P_PREPAY_INCLUDED   IN         VARCHAR2,
          P_USER_ID           IN         NUMBER,
          P_LAST_UPDATE_LOGIN IN         NUMBER,
          P_CALLING_SEQUENCE  IN         VARCHAR2,
	  /*Contract Payments*/
	  P_CALLING_MODE      IN         VARCHAR2 DEFAULT 'PREPAYMENT APPLICATION',
          P_ERROR_MESSAGE     OUT NOCOPY VARCHAR2) RETURN BOOLEAN
IS

l_base_currency_code            ap_system_parameters_all.base_currency_code%TYPE;

-- Standard Invoice Related Variables
l_std_inv_batch_id              ap_invoices_all.batch_id%TYPE;
l_std_inv_curr_code             ap_invoices_all.invoice_currency_code%TYPE;
l_std_inv_xrate                 ap_invoices_all.exchange_rate%TYPE;
l_std_inv_xdate                 ap_invoices_all.exchange_date%TYPE;
l_std_inv_xrate_type            ap_invoices_all.exchange_rate_type%TYPE;
l_std_inv_pay_curr_code         ap_invoices_all.payment_currency_code%TYPE;
l_std_inv_pay_cross_rate_date   ap_invoices_all.payment_cross_rate_date%TYPE;
l_std_inv_pay_cross_rate_type   ap_invoices_all.payment_cross_rate_type%TYPE;

-- Prepayment Invoice Related Variables
l_ppay_inv_curr_code            ap_invoices_all.invoice_currency_code%TYPE;
l_ppay_inv_xrate                ap_invoices_all.exchange_rate%TYPE;
l_ppay_inv_xdate                ap_invoices_all.exchange_date%TYPE;
l_ppay_inv_xrate_type           ap_invoices_all.exchange_rate_type%TYPE;
l_ppay_inv_pay_curr_code        ap_invoices_all.payment_currency_code%TYPE;
l_ppay_inv_pay_cross_rate_date  ap_invoices_all.payment_cross_rate_date%TYPE;
l_ppay_inv_pay_cross_rate_type  ap_invoices_all.payment_cross_rate_type%TYPE;

-- Prepayment Line Related Variables
l_ppay_ln_amount                  ap_invoice_lines_all.amount%TYPE;
l_ppay_ln_base_amount             ap_invoice_lines_all.base_amount%TYPE;
l_ppay_ln_amount_remaining        NUMBER;
l_ppay_ln_quantity_invoiced       ap_invoice_lines_all.quantity_invoiced%TYPE;
l_ppay_ln_pa_quantity             ap_invoice_lines_all.pa_quantity%TYPE;
l_ppay_ln_stat_amount             ap_invoice_lines_all.stat_amount%TYPE;
l_ppay_ln_po_line_location_id     ap_invoice_lines_all.po_line_location_id%TYPE;
l_ppay_ln_po_distribution_id      ap_invoice_lines_all.po_distribution_id%TYPE;
l_ppay_ln_rcv_transaction_id      ap_invoice_lines_all.rcv_transaction_id%TYPE;
l_ppay_ln_uom                     ap_invoice_lines_all.unit_meas_lookup_code%TYPE;
l_ppay_ln_match_basis             po_line_types.matching_basis%TYPE;

-- Prepayment Payment Related Variables
l_ppay_pay_curr_code              ap_checks_all.currency_code%TYPE;
l_ppay_pay_xrate                  ap_checks_all.exchange_rate%TYPE;
l_ppay_pay_xdate                  ap_invoices_all.exchange_date%TYPE;
l_ppay_pay_xrate_type             ap_checks_all.exchange_rate_type%TYPE;

-- Other Prepayment Application Related Variables
l_apply_amount                    NUMBER := p_apply_amount;
l_ppay_apply_amt_in_pay_curr    NUMBER;
l_dummy                           BOOLEAN;
l_final_application               VARCHAR2(1) := 'N';
l_result                          BOOLEAN;
l_calling_program                 VARCHAR2(1000);

-- PREPAY LINE related variables
l_prepay_ln_base_amount           ap_invoice_lines_all.base_amount%TYPE;
l_prepay_ln_quantity_invoiced     ap_invoice_lines_all.quantity_invoiced%TYPE;
l_prepay_ln_pa_quantity           ap_invoice_lines_all.pa_quantity%TYPE;
l_prepay_ln_stat_amount           ap_invoice_lines_all.stat_amount%TYPE;
l_prepay_ln_number                ap_invoice_lines_all.line_number%TYPE;
l_prepay_ln_s_quant_invoiced      ap_invoice_lines_all.quantity_invoiced%TYPE;
l_prepay_ln_s_pa_quantity         ap_invoice_lines_all.pa_quantity%TYPE;
l_prepay_ln_s_stat_amount         ap_invoice_lines_all.stat_amount%TYPE;

-- PREPAY distributions related variables
l_prepay_dist_info                AP_PREPAY_PKG.PREPAY_DIST_TAB_TYPE;
l_max_dist_number
                ap_invoice_distributions_all.distribution_line_number%TYPE;
l_loop_counter                    BINARY_INTEGER := 1;
l_loop_variable                   BINARY_INTEGER;
l_dist_line_counter               NUMBER := 1;
l_prepay_dist_s_quant_invoiced
                ap_invoice_distributions_all.quantity_invoiced%TYPE;
l_prepay_dist_s_pa_quantity       ap_invoice_distributions_all.pa_quantity%TYPE;
l_prepay_dist_s_stat_amount       ap_invoice_distributions_all.stat_amount%TYPE;

l_debug_info                      VARCHAR2(4000);
l_current_calling_sequence        VARCHAR2(2000);

l_inclusive_tax_amount            ap_invoice_lines_all.included_tax_amount%TYPE;
l_apply_amount_no_tax_incl        NUMBER;
l_ppay_ln_amt_remaining_no_tax    NUMBER;
l_prepay_tax_diff_amt             NUMBER;

l_invoice_line_number		  ap_invoice_lines_all.line_number%TYPE;

l_api_name			  VARCHAR2(50);

tax_exception                     EXCEPTION;
l_prepay_excl_tax_amt             NUMBER; --5224883

total_item_apply_amount           NUMBER; -- 7834255

CURSOR C_SYS_PARAMS IS
SELECT base_currency_code
FROM   ap_system_parameters;

CURSOR C_STD_INVOICE_INFO (CV_Std_Invoice_ID IN NUMBER) IS
SELECT batch_id,
       invoice_currency_code,
       exchange_rate,
       exchange_date,
       exchange_rate_type,
       payment_currency_code,
       payment_cross_rate_date,
       payment_cross_rate_type
  FROM AP_Invoices
 WHERE invoice_id = CV_Std_Invoice_ID;

CURSOR C_PPAY_INVOICE_INFO (CV_PPay_Invoice_ID IN NUMBER) IS
SELECT invoice_currency_code,
       exchange_rate,
       exchange_date,
       exchange_rate_type,
       payment_currency_code,
       payment_cross_rate_date,
       payment_cross_rate_type
  FROM AP_Invoices
 WHERE invoice_id = CV_PPay_Invoice_ID;

CURSOR C_PPAY_LINE_INFO (CV_PPAY_Invoice_ID IN NUMBER,
                         CV_PPAY_LINE_NUM   IN NUMBER) IS
SELECT ail.amount,
       NVL(ail.base_amount,0),
       /*
       Decode(p_calling_mode,'PREPAYMENT APPLICATION',
  	      AP_Prepay_Utils_PKG.get_line_prepay_amt_remaining(
              		ail.invoice_id,
              		ail.line_number),
	      'RECOUPMENT',
	      AP_Prepay_Utils_Pkg.get_ln_prep_amt_remain_recoup(
			ail.invoice_id,
			ail.line_number)
	     ),
       */
       AP_Prepay_Utils_PKG.get_line_prepay_amt_remaining(
                        ail.invoice_id,
                        ail.line_number),
       ail.quantity_invoiced,
       ail.pa_quantity,
       ail.stat_amount,
       ail.po_line_location_id,
       ail.po_distribution_id,
       ail.rcv_transaction_id,
       ail.unit_meas_lookup_code,
       plt.matching_basis
  FROM AP_invoice_lines ail,
       po_lines pl,        /* Amount Based Matching. PO related tables and conditions */
       po_line_locations pll,
       po_line_types_b plt       --bug 5056269
   --    po_line_types_tl T      --bug 5119694
 WHERE invoice_id  = CV_PPAY_Invoice_ID
   AND line_number = CV_PPAY_LINE_NUM
   AND ail.po_line_location_id  = pll.line_location_id(+)
   AND pll.po_line_id           = pl.po_line_id(+)
   AND pl.line_type_id          = plt.line_type_id(+);
 --  AND plt.LINE_TYPE_ID = T.LINE_TYPE_ID
--   AND T.LANGUAGE = userenv('LANG');

CURSOR C_PPAY_PAY_INFO (CV_PPAY_Invoice_ID IN NUMBER) IS
SELECT AC.currency_code,
       AC.exchange_rate_type,
       AC.exchange_date,
       AC.exchange_rate
  FROM AP_checks_all AC,
       AP_invoice_payments_all AIP
 WHERE AC.check_id    = AIP.check_id
   AND AIP.invoice_id = CV_PPAY_Invoice_ID
   AND AIP.reversal_inv_pmt_id IS NULL -- bug8971713
   AND NOT EXISTS (SELECT 'Invoice payment has been reversed'
                     FROM AP_invoice_payments_all AIP2
                    WHERE AIP2.reversal_inv_pmt_id = AIP.invoice_payment_id
                      AND AIP2.check_id            = AC.check_id);

CURSOR C_PPAY_DIST_INFO (CV_PPAY_Invoice_ID IN NUMBER,
                         CV_PPAY_LINE_NUM   IN NUMBER) IS
SELECT invoice_distribution_id,
       total_dist_amount,
       total_dist_base_amount,
       nvl(prepay_amount_remaining,total_dist_amount),
       po_distribution_id,
       rcv_transaction_id,
       quantity_invoiced,
       stat_amount,
       pa_quantity,
       p_gl_date,
       p_period_name,
       global_attribute_category,
       'PREPAY' line_type_lookup_code
  FROM ap_invoice_distributions
 WHERE invoice_id                     = CV_PPAY_Invoice_ID
   AND invoice_line_number            = CV_PPAY_LINE_NUM
   AND line_type_lookup_code          IN ('ITEM', 'ACCRUAL')
   AND NVL(prepay_amount_remaining,total_dist_amount) > 0
   --AND NVL(prepay_amount_remaining,0) > 0
   AND NVL(reversal_flag,'N')        <> 'Y'
  ORDER BY nvl(prepay_amount_remaining,total_dist_amount); -- 7834255


CURSOR C_PPAY_DIST_INFO_RECOUP(CV_PPAY_Invoice_ID IN NUMBER,
                               CV_PPAY_LINE_NUM   IN NUMBER) IS
/*Get the distributions including inclusive tax distributions
of the Prepayment Invoice - Item line */
SELECT invoice_distribution_id,
       total_dist_amount,
       total_dist_base_amount,
       nvl(prepay_amount_remaining,total_dist_amount),
       po_distribution_id,
       rcv_transaction_id,
       quantity_invoiced,
       stat_amount,
       pa_quantity,
       p_gl_date,
       p_period_name,
       global_attribute_category,
       decode(line_type_lookup_code,'ITEM','PREPAY',
              'ACCRUAL','PREPAY',line_type_lookup_code) line_type_lookup_code,
       decode(line_type_lookup_code,'NONREC_TAX',charge_applicable_to_dist_id,
              'REC_TAX',charge_applicable_to_dist_id,NULL) parent_chrg_appl_to_dist_id,
       decode(line_type_lookup_code,'TERV',related_id, 'TIPV', related_id,
              'TRV',related_id, NULL) parent_related_id
FROM ap_invoice_distributions
WHERE invoice_id          = CV_PPAY_Invoice_ID
AND invoice_line_number   = CV_PPAY_LINE_NUM
AND line_type_lookup_code IN ('ITEM','ACCRUAL')
AND NVL(prepay_amount_remaining,total_dist_amount) > 0
AND NVL(reversal_flag,'N') <> 'Y'
ORDER BY nvl(prepay_amount_remaining,total_dist_amount); -- 7834255

BEGIN

  l_current_calling_sequence := 'Apply_Prepay_Line<-'
                                 ||p_calling_sequence;

  l_calling_program := p_calling_sequence;

  l_api_name := 'Apply_Prepay_Line';

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_PREPAY_PKG.Apply_Prepay_Line(+)');
  END IF;

  -- ==========================================================
  -- Step 0: Get Base Currency Code
  -- ==========================================================

  l_debug_info := 'Get Base Currency Code';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  OPEN C_SYS_PARAMS;

  FETCH C_SYS_PARAMS INTO
        l_base_currency_code;

  CLOSE C_SYS_PARAMS;

  -- ==========================================================
  -- Step 1: Get Required Information from the STANDARD INVOICE
  -- ==========================================================

  l_debug_info := 'Get Required Information from the STANDARD INVOICE';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  OPEN C_STD_INVOICE_INFO (P_INVOICE_ID);

  FETCH C_STD_INVOICE_INFO INTO
        l_std_inv_batch_id,
        l_std_inv_curr_code,
        l_std_inv_xrate,
        l_std_inv_xdate,
        l_std_inv_xrate_type,
        l_std_inv_pay_curr_code,
        l_std_inv_pay_cross_rate_date,
        l_std_inv_pay_cross_rate_type;

  CLOSE C_STD_INVOICE_INFO;

  -- =============================================================
  -- Step 2: Get Required Information from the PREPAYMENT INVOICE
  -- =============================================================

  l_debug_info := 'Get Required Information from the PREPAYMENT INVOICE';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  OPEN C_PPAY_INVOICE_INFO (P_PREPAY_INVOICE_ID);

  FETCH C_PPAY_INVOICE_INFO INTO
        l_ppay_inv_curr_code,
        l_ppay_inv_xrate,
        l_ppay_inv_xdate,
        l_ppay_inv_xrate_type,
        l_ppay_inv_pay_curr_code,
        l_ppay_inv_pay_cross_rate_date,
        l_ppay_inv_pay_cross_rate_type;

  CLOSE C_PPAY_INVOICE_INFO;

  -- ==========================================================
  -- Step 3: Get the Required Line Information for the Selected
  --         Prepayment Invoice Line
  -- ==========================================================

  l_debug_info := 'Get the Required Line Information for the Selected '||
                  'Prepayment Invoice Line';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  OPEN C_PPAY_LINE_INFO (P_PREPAY_INVOICE_ID,
                         P_PREPAY_LINE_NUM);

  FETCH C_PPAY_LINE_INFO INTO
        l_ppay_ln_amount,
        l_ppay_ln_base_amount,
        l_ppay_ln_amount_remaining,
        l_ppay_ln_quantity_invoiced,
        l_ppay_ln_pa_quantity,
        l_ppay_ln_stat_amount,
        l_ppay_ln_po_line_location_id,
        l_ppay_ln_po_distribution_id,
        l_ppay_ln_rcv_transaction_id,
        l_ppay_ln_uom,
        l_ppay_ln_match_basis;

  CLOSE C_PPAY_LINE_INFO;


  --Upgrade the PO Shipment and Po Distributions if the Po Shipment
  --or the Prepayment invoice is pre-upgrade data from a release prior to R12.
  IF (l_ppay_ln_po_line_location_id IS NOT NULL) THEN
     l_debug_info := 'Call Upgrade Po Shipment';
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;

     AP_MATCHING_UTILS_PKG.AP_Upgrade_Po_Shipment(
     		l_ppay_ln_po_line_location_id,
		l_current_calling_sequence);

  END IF;

  -- ==========================================================
  -- Step 4: Get the Prepayment Payment Related Information
  -- ==========================================================

  l_debug_info := 'Get the Prepayment Payment Related Information';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  OPEN C_PPAY_PAY_INFO (P_PREPAY_INVOICE_ID);

  FETCH C_PPAY_PAY_INFO INTO
        l_ppay_pay_curr_code,
        l_ppay_pay_xrate_type,
        l_ppay_pay_xdate,
        l_ppay_pay_xrate;

  CLOSE C_PPAY_PAY_INFO;

  -- ==========================================================
  -- Step 5: Round the Apply Amount
  -- ==========================================================
  l_debug_info := 'Round the Apply Amount';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;
  l_apply_amount := AP_Utilities_PKG.AP_Round_Currency (
                    l_apply_amount,
                    l_std_inv_curr_code);


  -- ==========================================================
  -- Step 6: Get Line Level Apply Base Amount
  --         This base amount will be the base amount of the
  --         PREPAY line that will be created as a result of
  --         this application. This base amount will be
  --         calculated using the Standard Invoice XRATE.
  -- ==========================================================
  l_debug_info := 'Get Line Level Apply Base Amount';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  IF (l_std_inv_curr_code <>   l_base_currency_code) THEN

    IF l_std_inv_xrate_type = 'User' THEN
      l_prepay_ln_base_amount := AP_Utilities_PKG.AP_Round_Currency(
                l_apply_amount* l_std_inv_xrate,
                l_base_currency_code);
    ELSE
      l_prepay_ln_base_amount := GL_Currency_API.Convert_Amount(
                l_std_inv_curr_code,
                l_base_currency_code,
                l_std_inv_xdate,
                l_std_inv_xrate_type,
                l_apply_amount);
    END IF;
  END IF;

  -- ==========================================================
  -- Step 7: Get Line Level Quantity Invoiced, Stat Amount and
  --         PA Quantity
  -- ==========================================================

  l_debug_info := 'Get Line Level Quantity Invoiced, Stat Amount and '||
                  'PA Quantity';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  IF (l_apply_amount = l_ppay_ln_amount_remaining) THEN

    SELECT NVL( ABS(SUM(quantity_invoiced)), 0 ),
           NVL( ABS(SUM(stat_amount)), 0 ),
           NVL( ABS(SUM(pa_quantity)), 0 )
    INTO   l_prepay_ln_s_quant_invoiced,
           l_prepay_ln_s_stat_amount,
           l_prepay_ln_s_pa_quantity
    FROM   ap_invoice_lines
    WHERE  prepay_invoice_id  = p_prepay_invoice_id
    AND    prepay_line_number = p_prepay_line_num;

    IF (l_ppay_ln_po_line_location_id IS NOT NULL OR
       l_ppay_ln_po_distribution_id IS NOT NULL OR
       l_ppay_ln_rcv_transaction_id IS NOT NULL)  THEN

      l_prepay_ln_quantity_invoiced :=
        ( -1 ) *
        (l_ppay_ln_quantity_invoiced -
         l_prepay_ln_s_quant_invoiced);
    END IF;

    IF l_ppay_ln_stat_amount IS NOT NULL THEN

      l_prepay_ln_stat_amount :=
        ( -1 ) *
        (l_ppay_ln_stat_amount -
         l_prepay_ln_s_stat_amount);
    END IF;

    IF l_ppay_ln_pa_quantity IS NOT NULL THEN

      l_prepay_ln_pa_quantity :=
        ( -1 ) *
        (l_ppay_ln_pa_quantity -
         l_prepay_ln_s_pa_quantity);
    END IF;

  ELSE

    IF (l_ppay_ln_po_line_location_id IS NOT NULL OR
       l_ppay_ln_po_distribution_id IS NOT NULL OR
       l_ppay_ln_rcv_transaction_id IS NOT NULL)  THEN

      l_prepay_ln_quantity_invoiced :=
        (-1) *
        ((l_apply_amount/l_ppay_ln_amount) *
        l_ppay_ln_quantity_invoiced);

    END IF;

    IF l_ppay_ln_stat_amount IS NOT NULL THEN

      l_prepay_ln_stat_amount :=
        (-1) *
        ((l_apply_amount/l_ppay_ln_amount) *
        l_ppay_ln_stat_amount);

    END IF;

    IF l_ppay_ln_pa_quantity IS NOT NULL THEN

      l_prepay_ln_pa_quantity :=
        (-1) *
        ((l_apply_amount/l_ppay_ln_amount) *
        l_ppay_ln_pa_quantity);

    END IF;

  END IF;

  -- ==========================================================
  -- Step 8: Get Next Line Number for the PREPAY Line from the
  --         STANDARD Invoice if performing 'Prepayment Application'
  --	     not for 'Recoupment'.
  -- ==========================================================

  l_debug_info := 'Get Next Line Number for the PREPAY Line from the '||
                  'STANDARD Invoice';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  --Contract Payments: Added the IF condition
  IF (P_calling_mode = 'PREPAYMENT APPLICATION') THEN

     SELECT NVL(MAX (line_number),0) + 1
      INTO l_prepay_ln_number
      FROM ap_invoice_lines
      WHERE invoice_id = p_invoice_id;


     -- ===========================================================
     -- Step 9: Insert PREPAY Line - We will call the INSERT_PREPAY
     --          _LINE procedure to create the PREPAY line if the
     --		calling mode is 'PREPAYMENT APPLICATION', not for
     --		RECOUPMENT.
     -- ===========================================================
     l_debug_info := 'Call Ap_Prepay_Pkg.Insert_Prepay_Line';
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;

     l_dummy := AP_PREPAY_PKG.INSERT_PREPAY_LINE(
     		          p_prepay_invoice_id,
               		  p_prepay_line_num,
               		  p_invoice_id,
               		  l_prepay_ln_number,
               		  l_apply_amount,
               		  l_prepay_ln_base_amount,
               		  p_gl_date,
               		  p_period_name,
               		  p_prepay_included,
               		  l_prepay_ln_quantity_invoiced,
               		  l_prepay_ln_stat_amount,
               		  l_prepay_ln_pa_quantity,
               		  p_user_id,
               		  p_last_update_login,
               		  p_calling_sequence,
               		  p_error_message);

     IF l_dummy = FALSE THEN

         l_result:= AP_PREPAY_UTILS_PKG.Unlock_Line(
        	         p_prepay_invoice_id,
               		 p_prepay_line_num);

         RETURN (FALSE);

     END IF;

     -- ===========================================================
     -- Step 10: Calculate Tax
     --          Call eTax service.
     -- ===========================================================
        l_debug_info := 'Call to calculate tax';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;

        IF NOT (ap_etax_pkg.calling_etax(
   		         p_invoice_id             => p_invoice_id,
	        	 p_line_number            => NULL,
	                 p_calling_mode           => 'APPLY PREPAY',
	                 p_override_status        => NULL,
	                 p_line_number_to_delete  => NULL,
	                 p_Interface_Invoice_Id   => NULL,
	                 p_all_error_messages     => 'N',
	                 p_error_code             => p_error_message,
	                 p_calling_sequence       => l_current_calling_sequence)) THEN

	         RAISE tax_exception;

	END IF;

     -- ===========================================================
     -- Step 11: Get inclusive tax amount calculated by eTax
     --
     -- ===========================================================
     l_debug_info := 'Get inclusive tax amount from the PREPAY line '||
                     'after tax calculation';
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;

     BEGIN
        SELECT NVL(included_tax_amount, 0)
        INTO l_inclusive_tax_amount
        FROM ap_invoice_lines_all
        WHERE invoice_id = p_invoice_id
        AND line_number = l_prepay_ln_number;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         -- If there is a no_data_found in this case the PREPAY
         -- line was not created.  End the process and unlock the
         -- PREPAYMENT line
         l_result:= AP_PREPAY_UTILS_PKG.Unlock_Line(
        	         p_prepay_invoice_id,
               		 p_prepay_line_num);

         RETURN (FALSE);
     END;

     -- ===========================================================
     -- Step 12: Reduce inclusive tax if any from the line total to
     --          create the ITEM distributions.
     --          The distribution of tax (determine_recovery) will
     --          create the recoverable and non-rec distributions
     --          and tax variances
     -- ===========================================================
     l_debug_info := 'Reduce inclusive tax amount if any from PREPAY '||
                     'line amount';
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;

     IF (l_inclusive_tax_amount <> 0) THEN
	--Bugfix: 5577707 added the ABS for l_inclusive_tax_amount.
        l_apply_amount_no_tax_incl := l_apply_amount - abs(l_inclusive_tax_amount);

        l_ppay_ln_amt_remaining_no_tax :=
        AP_Prepay_Utils_PKG.get_ln_pp_amt_remaining_no_tax(
              p_prepay_invoice_id,
              p_prepay_line_num);

     END IF;

  END IF; /* P_calling_mode = 'PREPAYMENT APPLICATION' */

  -- ==========================================================
  -- Step 13: Get Distribution information
  --         Here when we are coming in the context of the
  --         invoice import or prepayment application from
  --         the prepayment invoice and line level application,
  --         we will always have the
  --         prorate_flag parameter set to Y. Hence we need to
  --         derive all the distribution related information.
  --         We will populate the information into a PL/SQL table
  --         and during insertion we will loop through the table
  --         to get the values.
  --         In case of apply prepayments from the distribute
  --         prepayments window, we will know the basic distribution
  --         information including the apply amount.
  --         We will only calculate the quantities, stat_amount
  --         and new distribution line numbers in this case.
  -- ==========================================================

  -- ==========================================================
  -- Step 13.1: Get maximum distribution line number from
  --           the standard invoice.
  -- ==========================================================

  l_debug_info := 'Get maximum distribution line number from '||
                  'the standard invoice';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  --From the Prepay line
  IF (P_calling_mode = 'PREPAYMENT APPLICATION') THEN

     SELECT NVL(MAX(distribution_line_number),0)
     INTO l_max_dist_number
     FROM ap_invoice_distributions
     WHERE invoice_id = p_invoice_id
     AND invoice_line_number = l_prepay_ln_number;

  --For Recoupment, 'PREPAY' distributions are tied to the ITEM line itself.
  ELSIF (P_calling_mode = 'RECOUPMENT') THEN

     SELECT NVL(MAX(distribution_line_number),0)
     INTO l_max_dist_number
     FROM ap_invoice_distributions
     WHERE invoice_id = p_invoice_id
     AND invoice_line_number = p_invoice_line_number ;

  END IF;

  -- ===========================================================
  -- Step 13.2: Populate the PL/SQL table with the basic
  --           distribution information if the prorate flag
  --           is 'Y'
  -- ==========================================================

  l_debug_info := 'Populate the PL/SQL table with the basic '||
                  'distribution information p_calling_mode'||p_calling_mode;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  -- IF p_prepay_dist_info is not empty then assign it to
  -- l_prepay_dist_info, otherwise populate l_prepay_dist_info
  -- from the cursor c_ppay_dist_info.
 IF (NVL(P_calling_mode,'PREPAYMENT APPLICATION') = 'PREPAYMENT APPLICATION') THEN

     IF (p_prorate_flag = 'Y') THEN  -- p_prepay_dist_info is Empty
	l_debug_info := 'Open Cursor C_PPay_Dist_Info';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;
        OPEN C_PPAY_DIST_INFO(
       		   p_prepay_invoice_id,
          	   p_prepay_line_num);

        total_item_apply_amount := 0; -- 7834255

        LOOP
           FETCH C_PPAY_DIST_INFO INTO
           l_prepay_dist_info(l_loop_counter).PREPAY_DISTRIBUTION_ID,
           l_prepay_dist_info(l_loop_counter).PPAY_AMOUNT,
           l_prepay_dist_info(l_loop_counter).PPAY_BASE_AMOUNT,
           l_prepay_dist_info(l_loop_counter).PPAY_AMOUNT_REMAINING,
           l_prepay_dist_info(l_loop_counter).PPAY_PO_DISTRIBUTION_ID,
           l_prepay_dist_info(l_loop_counter).PPAY_RCV_TRANSACTION_ID,
           l_prepay_dist_info(l_loop_counter).PPAY_QUANTITY_INVOICED,
           l_prepay_dist_info(l_loop_counter).PPAY_STAT_AMOUNT,
           l_prepay_dist_info(l_loop_counter).PPAY_PA_QUANTITY,
           l_prepay_dist_info(l_loop_counter).PREPAY_ACCOUNTING_DATE,
           l_prepay_dist_info(l_loop_counter).PREPAY_PERIOD_NAME,
           l_prepay_dist_info(l_loop_counter).PREPAY_GLOBAL_ATTR_CATEGORY,
           l_prepay_dist_info(l_loop_counter).LINE_TYPE_LOOKUP_CODE;
           EXIT WHEN C_PPAY_DIST_INFO%NOTFOUND OR C_PPAY_DIST_INFO%NOTFOUND IS NULL;
           -- Populate the APPLY Amount
           IF (l_apply_amount = l_ppay_ln_amount_remaining) THEN

              l_prepay_dist_info(l_loop_counter).PREPAY_APPLY_AMOUNT :=
                   l_prepay_dist_info(l_loop_counter).PPAY_AMOUNT_REMAINING;


           ELSE

              -- for the case of inclusive tax the proration should be
              -- done with the apply_amount without tax and the prepay_line
              -- amount remaining wihtout tax as well.
              IF (l_inclusive_tax_amount <> 0) THEN
                 -- Tax amount is included in PREPAY line amount
                 l_prepay_dist_info(l_loop_counter).PREPAY_APPLY_AMOUNT :=
                   AP_Utilities_PKG.AP_Round_Currency (
                       (l_prepay_dist_info(l_loop_counter).PPAY_AMOUNT_REMAINING/
                                l_ppay_ln_amt_remaining_no_tax) *  l_apply_amount_no_tax_incl
                        , l_std_inv_curr_code); -- 7834255
              ELSE

                 -- Tax amount is not included in PREPAY line amount
                 -- this is an exclusive case or inclusive with tax amount as 0
                 l_prepay_dist_info(l_loop_counter).PREPAY_APPLY_AMOUNT :=
                   AP_Utilities_PKG.AP_Round_Currency (
                    (l_prepay_dist_info(l_loop_counter).PPAY_AMOUNT_REMAINING/
                            l_ppay_ln_amount_remaining) *
                            l_apply_amount
                     , l_std_inv_curr_code); -- 7834255
              END IF;
           END IF;

           -- 7834255
           total_item_apply_amount := total_item_apply_amount + l_prepay_dist_info(l_loop_counter).PREPAY_APPLY_AMOUNT;

           l_loop_counter := l_loop_counter + 1;

        END LOOP;

        -- 7834255
        IF l_loop_counter > 1 THEN
           IF l_inclusive_tax_amount <> 0 THEN
              IF total_item_apply_amount <> l_apply_amount_no_tax_incl
                 AND abs(total_item_apply_amount - l_apply_amount_no_tax_incl) <= 1
              THEN
                 l_prepay_dist_info(l_loop_counter-1).PREPAY_APPLY_AMOUNT := l_prepay_dist_info(l_loop_counter-1).PREPAY_APPLY_AMOUNT
                                                                             - (total_item_apply_amount - l_apply_amount_no_tax_incl);
              END IF;
           ELSE
              IF total_item_apply_amount <> l_apply_amount
                 AND abs(total_item_apply_amount - l_apply_amount) <= 1
              THEN
                 l_prepay_dist_info(l_loop_counter-1).PREPAY_APPLY_AMOUNT := l_prepay_dist_info(l_loop_counter-1).PREPAY_APPLY_AMOUNT
                                                                             - (total_item_apply_amount - l_apply_amount);
              END IF;
           END IF;
        END IF;

     ELSE /* p_prepay_dist_info is not empty */
        -- the form will make sure the prepay_apply_amount
        -- does not have tax included in the case of inclusive
        -- tax calculation.
        l_prepay_dist_info := p_prepay_dist_info;
     END IF;


  ELSIF (P_calling_mode = 'RECOUPMENT') THEN

     l_debug_info := 'Open Cursor C_PPay_Dist_Info_Recoup l_ppay_invoice_id, l_ppay_line_number'||p_prepay_invoice_id||','||p_prepay_line_num;
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;

     OPEN C_PPAY_DIST_INFO_RECOUP(
       		   p_prepay_invoice_id,
          	   p_prepay_line_num);

     total_item_apply_amount := 0; -- 7834255

     LOOP
        l_debug_info := 'Fetch C_PPay_Dist_Info_Recoup into local variables';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;

        FETCH C_PPAY_DIST_INFO_RECOUP INTO
           l_prepay_dist_info(l_loop_counter).PREPAY_DISTRIBUTION_ID,
           l_prepay_dist_info(l_loop_counter).PPAY_AMOUNT,
           l_prepay_dist_info(l_loop_counter).PPAY_BASE_AMOUNT,
           l_prepay_dist_info(l_loop_counter).PPAY_AMOUNT_REMAINING,
           l_prepay_dist_info(l_loop_counter).PPAY_PO_DISTRIBUTION_ID,
           l_prepay_dist_info(l_loop_counter).PPAY_RCV_TRANSACTION_ID,
           l_prepay_dist_info(l_loop_counter).PPAY_QUANTITY_INVOICED,
           l_prepay_dist_info(l_loop_counter).PPAY_STAT_AMOUNT,
           l_prepay_dist_info(l_loop_counter).PPAY_PA_QUANTITY,
           l_prepay_dist_info(l_loop_counter).PREPAY_ACCOUNTING_DATE,
           l_prepay_dist_info(l_loop_counter).PREPAY_PERIOD_NAME,
           l_prepay_dist_info(l_loop_counter).PREPAY_GLOBAL_ATTR_CATEGORY,
	   l_prepay_dist_info(l_loop_counter).LINE_TYPE_LOOKUP_CODE,
	   l_prepay_dist_info(l_loop_counter).PARENT_CHRG_APPL_TO_DIST_ID,
	   l_prepay_dist_info(l_loop_counter).PARENT_RELATED_ID;

        EXIT WHEN C_PPAY_DIST_INFO_RECOUP%NOTFOUND OR C_PPAY_DIST_INFO_RECOUP%NOTFOUND IS NULL;

        -- Populate the APPLY Amount

        IF (l_apply_amount = l_ppay_ln_amount_remaining) THEN
            l_debug_info := 'Test1';
            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
            END IF;

            l_prepay_dist_info(l_loop_counter).PREPAY_APPLY_AMOUNT :=
                   l_prepay_dist_info(l_loop_counter).PPAY_AMOUNT_REMAINING;


        ELSE

            l_debug_info := 'Test2';
            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
            END IF;

	    --Contract Payments:
	    --Proration for both exclusive and inclusive tax cases, since
	    --for recoupment regardless of how the tax was calculated on the
	    --parent Item line on the Prepayment invoice, when recouping
	    --the Prepay dists as well as tax tied to those distributions will
	    --be part of the same ITEM line on the Standard invoice which is recouping.

            l_prepay_dist_info(l_loop_counter).PREPAY_APPLY_AMOUNT :=
                  AP_Utilities_PKG.AP_Round_Currency (
                    (l_prepay_dist_info(l_loop_counter).PPAY_AMOUNT_REMAINING/
                            l_ppay_ln_amount_remaining) *
                            l_apply_amount
                     , l_std_inv_curr_code); -- 7834255

        END IF;

        -- 7834255
        total_item_apply_amount := total_item_apply_amount + l_prepay_dist_info(l_loop_counter).PREPAY_APPLY_AMOUNT;

        l_loop_counter := l_loop_counter + 1;

     END LOOP;

        -- 7834255
     IF l_loop_counter > 1 THEN
        IF total_item_apply_amount <> l_apply_amount
	   AND abs(total_item_apply_amount - l_apply_amount) <= 1
        THEN
            l_prepay_dist_info(l_loop_counter-1).PREPAY_APPLY_AMOUNT := l_prepay_dist_info(l_loop_counter-1).PREPAY_APPLY_AMOUNT
                                                                        - (total_item_apply_amount - l_apply_amount);
        END IF;
     END IF;

  END IF; /* P_calling_mode .... */

  -- ===========================================================
  -- Step 13.3: Populate the PL/SQL table with the distribution
  --           line number, base amounts, quantity invoiced,
  --           pa quantity and stat amount. (PREPAY Distributions)
  -- ===========================================================

  l_debug_info := 'Populate the PL/SQL table with the PREPAY Distributions '||
                  'information';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;


  FOR l_loop_variable IN nvl(l_prepay_dist_info.FIRST,0)..nvl(l_prepay_dist_info.LAST,0) LOOP

      -- Get the Next Distribution Line Number

      l_debug_info := 'Populate other generic info for the prepay dists';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;

      l_prepay_dist_info(l_loop_variable).PREPAY_DIST_LINE_NUMBER :=
          l_max_dist_number + l_dist_line_counter;
      l_dist_line_counter := l_dist_line_counter+1;

      -- Get the Base Amount at the Standard Invoice Exchange Rate

      IF (l_std_inv_curr_code <> l_base_currency_code) THEN
        IF l_std_inv_xrate_type = 'User' THEN
          l_prepay_dist_info(l_loop_variable).PREPAY_BASE_AMOUNT :=
                  AP_Utilities_PKG.AP_Round_Currency(
                    l_prepay_dist_info(l_loop_variable).PREPAY_APPLY_AMOUNT *
                    l_std_inv_xrate,
                    l_base_currency_code);
        ELSE
          l_prepay_dist_info(l_loop_variable).PREPAY_BASE_AMOUNT :=
                  GL_Currency_API.Convert_Amount(
                    l_std_inv_curr_code,
                    l_base_currency_code,
                    l_std_inv_xdate,
                    l_std_inv_xrate_type,
                    l_prepay_dist_info(l_loop_variable).PREPAY_APPLY_AMOUNT);
        END IF;

        -- Get the Base Amount at the Prepayment Invoice Exchange Rate
        IF l_ppay_inv_xrate_type = 'User' THEN
          l_prepay_dist_info(l_loop_variable).PREPAY_BASE_AMT_PPAY_XRATE :=
                  AP_Utilities_PKG.AP_Round_Currency(
                     l_prepay_dist_info(l_loop_variable).PREPAY_APPLY_AMOUNT *
                     l_ppay_inv_xrate,
                     l_base_currency_code);
        ELSE
          l_prepay_dist_info(l_loop_variable).PREPAY_BASE_AMT_PPAY_XRATE :=
                  GL_Currency_API.Convert_Amount(
                     l_ppay_inv_curr_code,
                     l_base_currency_code,
                     l_ppay_inv_xdate,
                     l_ppay_inv_xrate_type,
                     l_prepay_dist_info(l_loop_variable).PREPAY_APPLY_AMOUNT);
        END IF;

        -- Get the Base Amount at the Prepayment Payment Exchange Rate
        IF l_ppay_pay_xrate_type = 'User' THEN
          l_prepay_dist_info(l_loop_variable).PREPAY_BASE_AMT_PPAY_PAY_XRATE :=
                   AP_Utilities_PKG.AP_Round_Currency(
                       l_prepay_dist_info(l_loop_variable).PREPAY_APPLY_AMOUNT *
                       l_ppay_pay_xrate,
                       l_base_currency_code);
        ELSE
          l_prepay_dist_info(l_loop_variable).PREPAY_BASE_AMT_PPAY_PAY_XRATE :=
                   GL_Currency_API.Convert_Amount(
                       l_ppay_pay_curr_code,
                       l_base_currency_code,
                       l_ppay_pay_xdate,
                       l_ppay_pay_xrate_type,
                       l_prepay_dist_info(l_loop_variable).PREPAY_APPLY_AMOUNT);
        END IF;
      END IF;

      -- Get Quantity Invoiced, PA_Quantity and the STAT Amount at the
      -- Distribution Level

      IF (l_apply_amount = l_ppay_ln_amount_remaining) THEN

          l_debug_info := 'Get Quantity_Invoiced, PA_Quantity, Stat_Amount';
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
          END IF;

          SELECT NVL( ABS(SUM(quantity_invoiced)), 0 ),
               NVL( ABS(SUM(stat_amount)), 0 ),
               NVL( ABS(SUM(pa_quantity)), 0 )
          INTO l_prepay_dist_s_quant_invoiced,
               l_prepay_dist_s_stat_amount,
               l_prepay_dist_s_pa_quantity
          FROM ap_invoice_distributions
         WHERE prepay_distribution_id =
               l_prepay_dist_info(l_loop_variable).PREPAY_DISTRIBUTION_ID;

        IF (l_prepay_dist_info(l_loop_variable).PPAY_PO_DISTRIBUTION_ID IS NOT NULL
            OR
            l_prepay_dist_info(l_loop_variable).PPAY_RCV_TRANSACTION_ID IS NOT NULL)
        THEN

          l_prepay_dist_info(l_loop_variable).PREPAY_QUANTITY_INVOICED :=
            ( -1 ) *
            (l_prepay_dist_info(l_loop_variable).PPAY_QUANTITY_INVOICED -
             l_prepay_dist_s_quant_invoiced);
        END IF;

        IF l_prepay_dist_info(l_loop_variable).PPAY_STAT_AMOUNT IS NOT NULL THEN

          l_prepay_dist_info(l_loop_variable).PREPAY_STAT_AMOUNT :=
            ( -1 ) *
            (l_prepay_dist_info(l_loop_variable).PPAY_STAT_AMOUNT -
             l_prepay_dist_s_stat_amount);
        END IF;

        IF l_prepay_dist_info(l_loop_variable).PPAY_PA_QUANTITY IS NOT NULL THEN

          l_prepay_dist_info(l_loop_variable).PREPAY_PA_QUANTITY :=
            ( -1 ) *
            (l_prepay_dist_info(l_loop_variable).PPAY_PA_QUANTITY -
             l_prepay_dist_s_pa_quantity);
        END IF;

      ELSE

        IF (l_prepay_dist_info(l_loop_variable).PPAY_PO_DISTRIBUTION_ID IS NOT NULL
            OR
            l_prepay_dist_info(l_loop_variable).PPAY_RCV_TRANSACTION_ID IS NOT NULL)
        THEN
            l_prepay_dist_info(l_loop_variable).PREPAY_QUANTITY_INVOICED :=
            (-1) *
            ((l_prepay_dist_info(l_loop_variable).PREPAY_APPLY_AMOUNT/
              l_prepay_dist_info(l_loop_variable).PPAY_AMOUNT) *
              l_prepay_dist_info(l_loop_variable).PPAY_QUANTITY_INVOICED);

        END IF;

        IF l_prepay_dist_info(l_loop_variable).PPAY_STAT_AMOUNT IS NOT NULL THEN

          l_prepay_dist_info(l_loop_variable).PREPAY_STAT_AMOUNT :=
            (-1) *
            ((l_prepay_dist_info(l_loop_variable).PREPAY_APPLY_AMOUNT/
              l_prepay_dist_info(l_loop_variable).PPAY_AMOUNT) *
              l_prepay_dist_info(l_loop_variable).PPAY_STAT_AMOUNT);

        END IF;

        IF l_prepay_dist_info(l_loop_variable).PPAY_PA_QUANTITY IS NOT NULL THEN

          l_prepay_dist_info(l_loop_variable).PREPAY_PA_QUANTITY :=
            (-1) *
            ((l_prepay_dist_info(l_loop_variable).PREPAY_APPLY_AMOUNT/
              l_prepay_dist_info(l_loop_variable).PPAY_AMOUNT) *
              l_prepay_dist_info(l_loop_variable).PPAY_PA_QUANTITY);

        END IF;

      END IF;

    END LOOP;

  -- ===========================================================
  -- Step 14: Insert PREPAY Distributions - We will call the
  --          INSERT_PREPAY_DISTS to insert the PREPAY
  --          distributions.
  -- ===========================================================
  --Contract Payments
  IF (p_calling_mode = 'RECOUPMENT') THEN
     l_invoice_line_number := p_invoice_line_number;
  ELSE
     l_invoice_line_number := l_prepay_ln_number;
  END IF;

  l_debug_info := 'Call Ap_Prepay_Pkg.Insert_Prepay_Dists';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  l_dummy := AP_PREPAY_PKG.INSERT_PREPAY_DISTS(
               p_prepay_invoice_id,
               p_prepay_line_num,
               p_invoice_id,
               l_std_inv_batch_id,
	       l_invoice_line_number,
               l_prepay_dist_info,
               p_user_id,
               p_last_update_login,
               p_calling_sequence,
               p_error_message);

  IF l_dummy = FALSE THEN

     l_result:= AP_PREPAY_UTILS_PKG.Unlock_Line(
                 p_prepay_invoice_id,
                 p_prepay_line_num);

    RETURN (FALSE);

  END IF;


  -- =======================================================================
  -- Step 15: Determine_recovery IF calling_mode is 'PREPAYMENT APPLICATION'
  --          Call eTax service.
  -- =======================================================================
  IF (P_calling_mode = 'PREPAYMENT APPLICATION') THEN

     l_debug_info := 'Distribute tax';
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;

     IF NOT (ap_etax_pkg.calling_etax(
    	        p_invoice_id             => p_invoice_id,
       	        p_line_number            => NULL,
                p_calling_mode           => 'DISTRIBUTE',
                p_override_status        => NULL,
                p_line_number_to_delete  => NULL,
                p_Interface_Invoice_Id   => NULL,
                p_all_error_messages     => 'N',
                p_error_code             => p_error_message,
                p_calling_sequence       => l_current_calling_sequence)) THEN

        RAISE tax_exception;

     END IF;

     -- ===========================================================
     -- Step 16: Update line amount total if there is a diff of tax
     --          rate or tax recovery rate and the calculation point
     --          is the Standard Invoice. This is valid only in the
     --          inclusive case.
     -- ===========================================================
     l_debug_info := 'Update parent PREPAY line amount if required';
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;

     IF (l_inclusive_tax_amount <> 0) THEN
        -- We need to update the PREPAY line amount only in the case the
        -- tax is inclusive.  For the exclusive case the parent line is
        -- the TAX line and it will be created with the correct amount
        -- while calling calculate tax

        l_debug_info := 'Get prepay tax difference amount from non-rec '||
                        'tax distributions';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;

        BEGIN

           SELECT SUM(NVL(aid.prepay_tax_diff_amount, 0))
           INTO l_prepay_tax_diff_amt
           FROM ap_invoice_distributions_all aid
           WHERE aid.invoice_id = p_invoice_id
           AND aid.invoice_line_number = l_prepay_ln_number
           AND aid.line_type_lookup_code = 'NONREC_TAX'
           AND NVL(aid.reversal_flag,'N') <> 'Y';

        EXCEPTION
         WHEN NO_DATA_FOUND THEN
            l_prepay_tax_diff_amt := 0;

        END;


        IF (l_prepay_tax_diff_amt <> 0) THEN

           l_apply_amount := (-1 * l_apply_amount) - l_prepay_tax_diff_amt;

           l_debug_info := 'Recalculate base amount including the tax '||
                           'difference amount';

           IF (l_std_inv_curr_code <>   l_base_currency_code) THEN
              IF l_std_inv_xrate_type = 'User' THEN
                 l_prepay_ln_base_amount := AP_Utilities_PKG.AP_Round_Currency(
                     				l_apply_amount* l_std_inv_xrate,
                				l_base_currency_code);
              ELSE
          	 l_prepay_ln_base_amount := GL_Currency_API.Convert_Amount(
               				        l_std_inv_curr_code,
                				l_base_currency_code,
                				l_std_inv_xdate,
                				l_std_inv_xrate_type,
                				l_apply_amount);
              END IF;
           END IF;

           l_debug_info := 'Update PREPAY line amount and base amount '||
                           'including the prepay tax difference';
           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
           END IF;

           BEGIN
              UPDATE ap_invoice_lines_all ail
              SET amount = l_apply_amount,
                  base_amount = l_prepay_ln_base_amount
              WHERE ail.invoice_id = p_invoice_id
              AND ail.line_number = l_prepay_ln_number;
           END;
       END IF;

     END IF;

  ELSIF (p_calling_mode = 'RECOUPMENT') THEN

    --SMYADAM: Need to call the ETAX api once the decision
    --is made regarding which api needs to be called,
    --to sync up the recouped tax distributions
    --with the etax repository.Also need to add
    --a similar call in discard inv line api too.
    NULL;

  END IF; /* P_calling_mode = 'PREPAYMENT APPLICATION' */

  -- ===========================================================
  -- Step 17: Update Prepayment
  -- ===========================================================

  l_debug_info := 'Update Prepayment distributions';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  l_dummy := AP_PREPAY_PKG.Update_Prepayment(
                 l_prepay_dist_info,
                 p_prepay_invoice_id,
                 p_prepay_line_num,
                 p_invoice_id,
		 l_invoice_line_number,
                 'APPLICATION',
		 p_calling_mode,
                 p_calling_sequence,
                 p_error_message);

  IF l_dummy = FALSE THEN
    l_debug_info := 'Unlock Line';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    l_result:= AP_PREPAY_UTILS_PKG.Unlock_Line(
                  p_prepay_invoice_id,
                  p_prepay_line_num);

    RETURN (FALSE);

  END IF;

  -- ===========================================================
  -- Step 18: Update PO/RCV information
  -- ===========================================================

  l_debug_info := 'Update_PO_Receipt_Info';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;


  l_dummy := AP_PREPAY_PKG.Update_PO_Receipt_Info(
                 l_prepay_dist_info,
                 p_prepay_invoice_id,
                 p_prepay_line_num,
                 p_invoice_id,
		 l_invoice_line_number,
                 l_ppay_ln_po_line_location_id,
                 l_ppay_ln_uom,
                 'APPLICATION',
                 l_ppay_ln_match_basis,
                 p_calling_sequence,
                 p_error_message);

  IF l_dummy = FALSE THEN

    l_result := AP_PREPAY_UTILS_PKG.Unlock_Line(
                  p_prepay_invoice_id,
                  p_prepay_line_num);

    RETURN (FALSE);

  END IF;

  -- ==========================================================
  -- Step 19: Get Apply Amount in Payment Currency
  --         This information is used only when we update the
  --         Payment Schedules.
  --         Here we will get this amount and pass it to the
  --         Sub Procedure that updates the Payment Schedules.
  -- ==========================================================
--Bug5224883
  -- Get the exculusive tax amount for the prepay appln line.
  SELECT sum(aid.amount) into l_prepay_excl_tax_amt
  FROM   ap_invoice_lines_all ail,ap_invoice_distributions_all aid
  WHERE  ail.line_type_lookup_code='TAX'
  AND    ail.invoice_id=p_invoice_id
  and    aid.invoice_id=ail.invoice_id
  AND    aid.invoice_line_number=ail.line_number
  AND   ail.prepay_line_number is not null
  AND exists( select 1 from ap_invoice_distributions_all aid1
              where aid1.invoice_id=p_invoice_id
              and aid1.invoice_line_number=l_prepay_ln_number
              and aid1.invoice_distribution_id=aid.charge_applicable_to_dist_id);
  -- Bug 5307022. Added the NVL for amount calculation in case of non exclusive tax
  l_apply_amount:= l_apply_amount - nvl(l_prepay_excl_tax_amt,0); --Bug5224883

  l_debug_info := 'Get Apply Amount in Payment Currency';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  IF (l_ppay_inv_curr_code <> l_ppay_inv_pay_curr_code) THEN

    l_ppay_apply_amt_in_pay_curr :=
         GL_Currency_API.Convert_Amount (
                    l_ppay_inv_curr_code,
                    l_ppay_inv_pay_curr_code,
                    l_ppay_inv_pay_cross_rate_date,
                    l_ppay_inv_pay_cross_rate_type,
                    l_apply_amount);

  ELSE
    l_ppay_apply_amt_in_pay_curr := l_apply_amount;
  END IF;


  -- ===========================================================
  -- Step 20: Update Payment Schedules
  -- ===========================================================

  IF NVL(p_prepay_included, 'N') = 'N' THEN
    --Contract Payments: No modification needed for this api.
    l_debug_info := 'Update Payment Schedules';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    l_dummy := AP_PREPAY_PKG.Update_Payment_Schedule(
                p_invoice_id,
                p_prepay_invoice_id,
                p_prepay_line_num,
                l_ppay_apply_amt_in_pay_curr,
                'APPLICATION',
                l_ppay_inv_pay_curr_code,
                p_user_id,
                p_last_update_login,
                p_calling_sequence,
		p_calling_mode,
                p_error_message);

    IF l_dummy = FALSE THEN
      l_result := AP_PREPAY_UTILS_PKG.Unlock_Line(
                    p_prepay_invoice_id,
                    p_prepay_line_num);

      RETURN (FALSE);
    END IF;
  END IF;

  -- Bug 5056104 - below step obsolete in R12

  -- ===========================================================
  -- Step 21: Calculate/Update Rounding Amounts
  -- ===========================================================

  -- l_debug_info := 'Calculate/Update Rounding Amounts';
  -- IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
  --   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  --END IF;
  -- ===========================================================
  -- Step 21.1: Identify if this application is the final
  -- application for this prepayment invoice line. If so then
  -- it is considered final application for all the distributions.
  -- pertaining to this prepayment invoice line.
  -- ===========================================================

--COMMENT!!!!!!This comment is for who is going to  modify latter on the
-- final application rounding.  The l_apply_amount at this moment includes
-- any tax difference etax has returned in the case the calculation
-- point for the tax is the standard invoice.
 -- IF (l_apply_amount = l_ppay_ln_amount_remaining) THEN
 --   l_final_application := 'Y';
 --  END IF;

  --IF l_base_currency_code <> l_std_inv_curr_code THEN
    --l_debug_info := 'Update Rounding Amounts';
    --IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     --  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    --END IF;

 --   l_dummy := AP_PREPAY_PKG.Update_Rounding_Amounts(
  --               p_prepay_invoice_id,
  --               p_prepay_line_num,
  --               p_invoice_id,
  --               l_invoice_line_number,
  --               l_final_application,
  --               l_current_calling_sequence,
  --               p_error_message);

  --  IF l_dummy = FALSE THEN
  --  l_result := AP_PREPAY_UTILS_PKG.Unlock_Line(
  --              p_prepay_invoice_id,
  --            p_prepay_line_num);
  --     RETURN (FALSE);
  --   END IF;
  -- END IF;

  -- ===========================================================
  -- Step 22: Unlock the Locked Line
  -- ===========================================================

  l_debug_info := 'Unlock the Locked Line';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  l_result := AP_PREPAY_UTILS_PKG.Unlock_Line(
                p_prepay_invoice_id,
                p_prepay_line_num);

  -- ===========================================================
  -- Step 23: If we are here we have done everything we need to
  --          Hence we can return TRUE to the calling module.
  -- ===========================================================

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_PREPAY_PKG.Apply_Prepay_Line(-)');
  END IF;

  RETURN (TRUE);

EXCEPTION
  WHEN tax_exception THEN
     l_result:= AP_PREPAY_UTILS_PKG.Unlock_Line(
                 p_prepay_invoice_id,
                 p_prepay_line_num);

     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR', p_error_message, TRUE);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
     APP_EXCEPTION.RAISE_EXCEPTION;

  WHEN OTHERS THEN
  IF (SQLCODE <> -20001) THEN
    FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
    FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
    FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                    l_current_calling_sequence);
    FND_MESSAGE.SET_TOKEN('PARAMETERS',
               'P_PREPAY_INVOICE_ID = '||P_PREPAY_INVOICE_ID
           ||', P_PREPAY_LINE_NUM   = '||P_PREPAY_LINE_NUM
           ||', P_PRORATE_FLAG      = '||P_PRORATE_FLAG
           ||', P_INVOICE_ID        = '||P_INVOICE_ID
           ||', P_APPLY_AMOUNT      = '||P_APPLY_AMOUNT
           ||', P_GL_DATE           = '||P_GL_DATE
           ||', P_PERIOD_NAME       = '||P_PERIOD_NAME
           ||', P_PREPAY_INCLUDED   = '||P_PREPAY_INCLUDED
           ||', P_USER_ID           = '||P_USER_ID
           ||', P_LAST_UPDATE_LOGIN = '||P_LAST_UPDATE_LOGIN);

    FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);

    IF INSTR(l_calling_program,'Apply Prepayment Form') > 0 THEN
      APP_EXCEPTION.RAISE_EXCEPTION;
    ELSE
      p_error_message := FND_MESSAGE.GET;
    END IF;

  END IF;

  l_result := AP_PREPAY_UTILS_PKG.Unlock_Line(
                p_prepay_invoice_id,
                p_prepay_line_num);
  RETURN (FALSE);
END Apply_Prepay_Line;


FUNCTION Insert_Prepay_Line(
          p_prepay_invoice_id    IN NUMBER,
          p_prepay_line_num      IN NUMBER,
          p_invoice_id           IN NUMBER,
          p_prepay_line_number   IN NUMBER,
          p_amount_to_apply      IN NUMBER,
          p_base_amount_to_apply IN NUMBER,
          p_gl_date              IN DATE,
          p_period_name          IN VARCHAR2,
          p_prepay_included      IN VARCHAR2,
          p_quantity_invoiced    IN NUMBER,
          p_stat_amount          IN NUMBER,
          p_pa_quantity          IN NUMBER,
          p_user_id              IN NUMBER,
          p_last_update_login    IN NUMBER,
          p_calling_sequence     IN VARCHAR2,
          p_error_message        OUT NOCOPY VARCHAR2)
RETURN BOOLEAN IS

  l_debug_info                VARCHAR2(4000);	--Changed length from 100 to 4000 (8534097)
  l_current_calling_sequence  VARCHAR2(2000);
  l_calling_program           VARCHAR2(1000);
  l_result                    BOOLEAN;
  l_api_name		      VARCHAR2(50);

BEGIN

  l_api_name := 'Insert_Prepay_Line';
  l_calling_program := p_calling_sequence;
  l_current_calling_sequence := 'Insert_Prepay_Line<-'
                                ||p_calling_sequence;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_PREPAY_PKG.Insert_Prepay_Line(+)');
  END IF;

  l_debug_info := 'Insert PREPAY Line';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  INSERT INTO AP_Invoice_Lines(
      INVOICE_ID,
      LINE_NUMBER,
      LINE_TYPE_LOOKUP_CODE,
      REQUESTER_ID,
      DESCRIPTION,
      LINE_SOURCE,
      LINE_GROUP_NUMBER ,
      INVENTORY_ITEM_ID ,
      ITEM_DESCRIPTION  ,
      SERIAL_NUMBER     ,
      MANUFACTURER      ,
      MODEL_NUMBER      ,
      WARRANTY_NUMBER   ,
      GENERATE_DISTS    ,
      MATCH_TYPE        ,
      DISTRIBUTION_SET_ID,
      ACCOUNT_SEGMENT    ,
      BALANCING_SEGMENT,
      COST_CENTER_SEGMENT,
      OVERLAY_DIST_CODE_CONCAT,
      DEFAULT_DIST_CCID,
      PRORATE_ACROSS_ALL_ITEMS,
      ACCOUNTING_DATE,
      PERIOD_NAME,
      DEFERRED_ACCTG_FLAG,
      DEF_ACCTG_START_DATE,
      DEF_ACCTG_END_DATE,
      DEF_ACCTG_NUMBER_OF_PERIODS,
      DEF_ACCTG_PERIOD_TYPE,
      SET_OF_BOOKS_ID,
      AMOUNT,
      BASE_AMOUNT,
      ROUNDING_AMT,
      QUANTITY_INVOICED,
      UNIT_MEAS_LOOKUP_CODE,
      UNIT_PRICE,
      WFAPPROVAL_STATUS,
   -- USSGL_TRANSACTION_CODE, - Bug 4277744
      DISCARDED_FLAG,
      ORIGINAL_AMOUNT,
      ORIGINAL_BASE_AMOUNT,
      ORIGINAL_ROUNDING_AMT,
      CANCELLED_FLAG,
      INCOME_TAX_REGION,
      TYPE_1099,
      STAT_AMOUNT,
      PREPAY_INVOICE_ID,
      PREPAY_LINE_NUMBER,
      INVOICE_INCLUDES_PREPAY_FLAG,
      CORRECTED_INV_ID,
      CORRECTED_LINE_NUMBER,
      PO_HEADER_ID,
      PO_LINE_ID,
      PO_RELEASE_ID,
      PO_LINE_LOCATION_ID,
      PO_DISTRIBUTION_ID,
      RCV_TRANSACTION_ID,
      FINAL_MATCH_FLAG,
      ASSETS_TRACKING_FLAG,
      ASSET_BOOK_TYPE_CODE,
      ASSET_CATEGORY_ID,
      PROJECT_ID,
      TASK_ID,
      EXPENDITURE_TYPE,
      EXPENDITURE_ITEM_DATE,
      EXPENDITURE_ORGANIZATION_ID,
      PA_QUANTITY,
      PA_CC_AR_INVOICE_ID,
      PA_CC_AR_INVOICE_LINE_NUM,
      PA_CC_PROCESSED_CODE,
      AWARD_ID,
      AWT_GROUP_ID,
      REFERENCE_1,
      REFERENCE_2,
      RECEIPT_VERIFIED_FLAG,
      RECEIPT_REQUIRED_FLAG,
      RECEIPT_MISSING_FLAG,
      JUSTIFICATION     ,
      EXPENSE_GROUP     ,
      START_EXPENSE_DATE,
      END_EXPENSE_DATE  ,
      RECEIPT_CURRENCY_CODE,
      RECEIPT_CONVERSION_RATE,
      RECEIPT_CURRENCY_AMOUNT,
      DAILY_AMOUNT           ,
      WEB_PARAMETER_ID,
      ADJUSTMENT_REASON,
      MERCHANT_DOCUMENT_NUMBER,
      MERCHANT_NAME           ,
      MERCHANT_REFERENCE     ,
      MERCHANT_TAX_REG_NUMBER,
      MERCHANT_TAXPAYER_ID   ,
      COUNTRY_OF_SUPPLY      ,
      CREDIT_CARD_TRX_ID     ,
      COMPANY_PREPAID_INVOICE_ID,
      CC_REVERSAL_FLAG          ,
      CREATION_DATE             ,
      CREATED_BY,
      LAST_UPDATED_BY           ,
      LAST_UPDATE_DATE          ,
      LAST_UPDATE_LOGIN         ,
      PROGRAM_APPLICATION_ID    ,
      PROGRAM_ID,
      PROGRAM_UPDATE_DATE       ,
      REQUEST_ID,
      LINE_SELECTED_FOR_APPL_FLAG,
      PREPAY_APPL_REQUEST_ID       ,
      ATTRIBUTE_CATEGORY        ,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      GLOBAL_ATTRIBUTE_CATEGORY,
      GLOBAL_ATTRIBUTE1,
      GLOBAL_ATTRIBUTE2,
      GLOBAL_ATTRIBUTE3,
      GLOBAL_ATTRIBUTE4,
      GLOBAL_ATTRIBUTE5,
      GLOBAL_ATTRIBUTE6,
      GLOBAL_ATTRIBUTE7,
      GLOBAL_ATTRIBUTE8,
      GLOBAL_ATTRIBUTE9,
      GLOBAL_ATTRIBUTE10,
      GLOBAL_ATTRIBUTE11,
      GLOBAL_ATTRIBUTE12,
      GLOBAL_ATTRIBUTE13,
      GLOBAL_ATTRIBUTE14,
      GLOBAL_ATTRIBUTE15,
      GLOBAL_ATTRIBUTE16,
      GLOBAL_ATTRIBUTE17,
      GLOBAL_ATTRIBUTE18,
      GLOBAL_ATTRIBUTE19,
      GLOBAL_ATTRIBUTE20,
      --ETAX: Invwkb
      SHIP_TO_LOCATION_ID,
      PRIMARY_INTENDED_USE,
      PRODUCT_FISC_CLASSIFICATION,
      TRX_BUSINESS_CATEGORY,
      PRODUCT_TYPE,
      PRODUCT_CATEGORY,
      USER_DEFINED_FISC_CLASS,
      PURCHASING_CATEGORY_ID,
      ORG_ID,
      PAY_AWT_GROUP_ID) --Bug 9058369
SELECT
      p_invoice_id,
      p_prepay_line_number,
      'PREPAY',
      NULL,
      description,
      'PREPAY APPL',
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      'D',
      match_type,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      'N',
      trunc(p_gl_date),--8532204
      p_period_name,
      'N',
      NULL,
      NULL,
      NULL,
      NULL,
      set_of_books_id,
      (-1 * p_amount_to_apply),
      (-1 * p_base_amount_to_apply),
      rounding_amt,
      p_quantity_invoiced,
      unit_meas_lookup_code,
      unit_price,
      'NOT REQUIRED',
   -- ussgl_transaction_code, - Bug 4277744
      'N',
      0,
      0,
      0,
      'N',
      income_tax_region,
      type_1099,
      p_stat_amount,
      invoice_id,
      line_number,
      p_prepay_included,
      NULL,
      NULL,
      po_header_id,
      po_line_id,
      po_release_id,
      po_line_location_id,
      po_distribution_id,
      rcv_transaction_id,
      final_match_flag,
      'N',
      asset_book_type_code,
      asset_category_id,
      project_id,
      task_id,
      expenditure_type,
      expenditure_item_date,
      expenditure_organization_id,
      p_pa_quantity,
      NULL,
      NULL,
      NULL,
      award_id,
      awt_group_id,
      reference_1,
      reference_2,
      receipt_verified_flag,
      receipt_required_flag,
      receipt_missing_flag,
      justification,
      expense_group,
      start_expense_date,
      end_expense_date,
      receipt_currency_code,
      receipt_conversion_rate,
      receipt_currency_amount,
      daily_amount,
      web_parameter_id,
      adjustment_reason,
      merchant_document_number,
      merchant_name,
      merchant_reference,
      merchant_tax_reg_number,
      merchant_taxpayer_id,
      country_of_supply,
      credit_card_trx_id,
      company_prepaid_invoice_id,
      cc_reversal_flag,
      SYSDATE,
      p_user_id,
      p_user_id,
      SYSDATE,
      p_last_update_login,
      program_application_id,
      program_id,
      program_update_date,
      request_id,
     'N',
      NULL,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      global_attribute_category,
      global_attribute1,
      global_attribute2,
      global_attribute3,
      global_attribute4,
      global_attribute5,
      global_attribute6,
      global_attribute7,
      global_attribute8,
      global_attribute9,
      global_attribute10,
      global_attribute11,
      global_attribute12,
      global_attribute13,
      global_attribute14,
      global_attribute15,
      global_attribute16,
      global_attribute17,
      global_attribute18,
      global_attribute19,
      global_attribute20,
      --ETAX: Invwkb
      ship_to_location_id,
      primary_intended_use,
      product_fisc_classification,
      trx_business_category,
      product_type,
      product_category,
      user_defined_fisc_class,
      purchasing_category_id,
      org_id,
      pay_awt_group_id --Bug 9058369
 FROM ap_invoice_lines
WHERE invoice_id  = p_prepay_invoice_id
  AND line_number = p_prepay_line_num;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_PREPAY_PKG.Insert_Prepay_Line(-)');
  END IF;

  RETURN (TRUE);
EXCEPTION
  WHEN OTHERS THEN
  IF (SQLCODE <> -20001) THEN
    FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
    FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
    FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                    p_calling_sequence);
    FND_MESSAGE.SET_TOKEN('PARAMETERS',
               'P_PREPAY_INVOICE_ID    = '||P_PREPAY_INVOICE_ID
           ||', P_PREPAY_LINE_NUM      = '||P_PREPAY_LINE_NUM
           ||', P_PREPAY_LINE_NUMBER   = '||P_PREPAY_LINE_NUMBER
           ||', P_INVOICE_ID           = '||P_INVOICE_ID
           ||', P_AMOUNT_TO_APPLY      = '||P_AMOUNT_TO_APPLY
           ||', P_BASE_AMOUNT_TO_APPLY = '||P_BASE_AMOUNT_TO_APPLY
           ||', P_GL_DATE              = '||P_GL_DATE
           ||', P_PERIOD_NAME          = '||P_PERIOD_NAME
           ||', P_PREPAY_INCLUDED      = '||P_PREPAY_INCLUDED
           ||', P_QUANTITY_INVOICED    = '||P_QUANTITY_INVOICED
           ||', P_STAT_AMOUNT          = '||P_STAT_AMOUNT
           ||', P_PA_QUANTITY          = '||P_PA_QUANTITY
           ||', P_USER_ID              = '||P_USER_ID
           ||', P_LAST_UPDATE_LOGIN    = '||P_LAST_UPDATE_LOGIN);

    FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);

    IF INSTR(l_calling_program,'Apply Prepayment Form') > 0 THEN
      APP_EXCEPTION.RAISE_EXCEPTION;
    ELSE
      p_error_message := FND_MESSAGE.GET;
    END IF;

  END IF;

  l_result := AP_PREPAY_UTILS_PKG.Unlock_Line(
                p_prepay_invoice_id,
                p_prepay_line_num);
  RETURN (FALSE);
END Insert_Prepay_Line;


FUNCTION Insert_Prepay_Dists(
          P_prepay_invoice_id  IN NUMBER,
          P_prepay_line_num    IN NUMBER,
          P_invoice_id         IN NUMBER,
          P_batch_id           IN NUMBER,
          P_line_number        IN NUMBER,
          P_prepay_dist_info   IN OUT NOCOPY AP_PREPAY_PKG.Prepay_Dist_Tab_Type,
          P_user_id            IN NUMBER,
          P_last_update_login  IN NUMBER,
          P_calling_sequence   IN VARCHAR2,
          P_error_message      OUT NOCOPY VARCHAR2)
RETURN BOOLEAN IS

  l_loop_counter            BINARY_INTEGER;
  l_invoice_distribution_id NUMBER;
  l_global_attr_category    ap_invoice_distributions_all.global_attribute_category%TYPE;
  l_result                  BOOLEAN;
  l_debug_info              VARCHAR2(4000);	--Changed length from 100 to 4000 (8534097)
  l_calling_sequence        VARCHAR2(2000);
  l_calling_program         VARCHAR2(1000);
  l_bug varchar2(2000);
  l_api_name 		    VARCHAR2(50);
  l_invoice_includes_prepay_flag  VARCHAR2(1);  --Bug5224996

BEGIN

  l_api_name := 'Insert_Prepay_Dists';
  l_calling_program := p_calling_sequence;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_PREPAY_PKG.Insert_Prepay_Dists(+)');
  END IF;

  l_debug_info := 'Insert PREPAY Distributions';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  --Bug5224996 Added following select stmt
  SELECT invoice_includes_prepay_flag
  INTO   l_invoice_includes_prepay_flag
  FROM   ap_invoice_lines
  WHERE  invoice_id=p_invoice_id
  AND    line_number=p_line_number;

  FOR l_loop_counter IN nvl(p_prepay_dist_info.first,0) .. nvl(p_prepay_dist_info.last,0) LOOP

    SELECT ap_invoice_distributions_s.NEXTVAL
      INTO p_prepay_dist_info(l_loop_counter).invoice_distribution_id
      FROM sys.dual;   -- Check if it's better to use sequence.CURRVAL instead of dual.


      l_debug_info := 'Derive the charge_applicable_to_dist_id and related_id for Tax Dists and Tax variances';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;

      --Note: Need to derive it only after the 'PREPAY' distributions have been created as
      --part of the loop, hence ordered the cursor C_PPAY_DIST_INFO_RECOUP by line_type_lookup_code
      --so that the PREPAY dists are created before TAX dists and TAX variances.

      IF (p_prepay_dist_info(l_loop_counter).parent_chrg_appl_to_dist_id IS NOT NULL) THEN

	    IF (p_prepay_dist_info(l_loop_counter).line_type_lookup_code IN ('REC_TAX','NONREC_TAX')) THEN

	       l_debug_info := 'Derive Charge_Applicable_to_Dist_Id for the Tax distributions';
	       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
	       END IF;

	       SELECT invoice_distribution_id
	       INTO p_prepay_dist_info(l_loop_counter).charge_applicable_to_dist_id
	       FROM ap_invoice_distributions
	       WHERE invoice_id = p_invoice_id
	       AND invoice_line_number = p_line_number
               AND line_type_lookup_code = 'PREPAY'
	       and prepay_distribution_id = p_prepay_dist_info(l_loop_counter).parent_chrg_appl_to_dist_id;

            ELSIF (p_prepay_dist_info(l_loop_counter).line_type_lookup_code IN ('TERV','TIPV','TRV')) THEN

	       l_debug_info := 'Derive Related_Id for the Tax Variance distributions';
	       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
	       END IF;


	       SELECT invoice_distribution_id
	       INTO p_prepay_dist_info(l_loop_counter).related_id
	       FROM ap_invoice_distributions
	       WHERE invoice_id = p_invoice_id
	       AND invoice_line_number = p_line_number
	       AND line_type_lookup_code in ('NONREC_TAX','REC_TAX')
	       AND prepay_distribution_id = p_prepay_dist_info(l_loop_counter).parent_related_id;

	    END IF;

	END IF;

    l_debug_info := 'Insert into ap_invoice_distributions';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    l_debug_info := 'Prepay Distribution Id is '||p_prepay_dist_info(l_loop_counter).prepay_distribution_id;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;



    INSERT INTO AP_INVOICE_DISTRIBUTIONS
      (ACCOUNTING_DATE,
       ACCRUAL_POSTED_FLAG,
       ASSETS_ADDITION_FLAG,
       ASSETS_TRACKING_FLAG,
       CASH_POSTED_FLAG,
       DISTRIBUTION_LINE_NUMBER,
       DIST_CODE_COMBINATION_ID,
       INVOICE_ID,
       LAST_UPDATED_BY,
       LAST_UPDATE_DATE,
       LINE_TYPE_LOOKUP_CODE,
       PERIOD_NAME,
       SET_OF_BOOKS_ID,
       ACCTS_PAY_CODE_COMBINATION_ID,
       AMOUNT,
       BASE_AMOUNT,
       BATCH_ID,
       CREATED_BY,
       CREATION_DATE,
       DESCRIPTION,
       FINAL_MATCH_FLAG,
       INCOME_TAX_REGION ,
       LAST_UPDATE_LOGIN,
       MATCH_STATUS_FLAG,
       POSTED_FLAG,
       PO_DISTRIBUTION_ID,
       PROGRAM_APPLICATION_ID,
       PROGRAM_ID,
       PROGRAM_UPDATE_DATE,
       QUANTITY_INVOICED,
       REQUEST_ID,
       REVERSAL_FLAG,
       TYPE_1099,
       UNIT_PRICE,
       ENCUMBERED_FLAG ,
       STAT_AMOUNT,
       AMOUNT_TO_POST,
       ATTRIBUTE1,
       ATTRIBUTE10,
       ATTRIBUTE11,
       ATTRIBUTE12,
       ATTRIBUTE13,
       ATTRIBUTE14,
       ATTRIBUTE15,
       ATTRIBUTE2,
       ATTRIBUTE3,
       ATTRIBUTE4,
       ATTRIBUTE5,
       ATTRIBUTE6,
       ATTRIBUTE7,
       ATTRIBUTE8,
       ATTRIBUTE9,
       ATTRIBUTE_CATEGORY,
       BASE_AMOUNT_TO_POST,
       EXPENDITURE_ITEM_DATE,
       EXPENDITURE_ORGANIZATION_ID,
       EXPENDITURE_TYPE,
       PARENT_INVOICE_ID ,
       PA_ADDITION_FLAG,
       PA_QUANTITY,
       POSTED_AMOUNT,
       POSTED_BASE_AMOUNT,
       PREPAY_AMOUNT_REMAINING,
       PROJECT_ID,
       TASK_ID ,
    -- USSGL_TRANSACTION_CODE, - Bug 4277744
    -- USSGL_TRX_CODE_CONTEXT, - Bug 4277744
       QUANTITY_VARIANCE ,
       BASE_QUANTITY_VARIANCE,
       PACKET_ID,
       AWT_FLAG,
       AWT_GROUP_ID,
       AWT_TAX_RATE_ID,
       AWT_GROSS_AMOUNT,
       AWT_INVOICE_ID,
       AWT_ORIGIN_GROUP_ID,
       REFERENCE_1,
       REFERENCE_2,
       AWT_INVOICE_PAYMENT_ID,
       GLOBAL_ATTRIBUTE_CATEGORY,
       GLOBAL_ATTRIBUTE1 ,
       GLOBAL_ATTRIBUTE2 ,
       GLOBAL_ATTRIBUTE3 ,
       GLOBAL_ATTRIBUTE4 ,
       GLOBAL_ATTRIBUTE5 ,
       GLOBAL_ATTRIBUTE6 ,
       GLOBAL_ATTRIBUTE7 ,
       GLOBAL_ATTRIBUTE8 ,
       GLOBAL_ATTRIBUTE9 ,
       GLOBAL_ATTRIBUTE10,
       GLOBAL_ATTRIBUTE11,
       GLOBAL_ATTRIBUTE12,
       GLOBAL_ATTRIBUTE13,
       GLOBAL_ATTRIBUTE14,
       GLOBAL_ATTRIBUTE15,
       GLOBAL_ATTRIBUTE16,
       GLOBAL_ATTRIBUTE17,
       GLOBAL_ATTRIBUTE18,
       GLOBAL_ATTRIBUTE19,
       GLOBAL_ATTRIBUTE20,
       RECEIPT_VERIFIED_FLAG,
       RECEIPT_REQUIRED_FLAG,
       RECEIPT_MISSING_FLAG ,
       JUSTIFICATION,
       EXPENSE_GROUP,
       START_EXPENSE_DATE,
       END_EXPENSE_DATE,
       RECEIPT_CURRENCY_CODE,
       RECEIPT_CONVERSION_RATE,
       RECEIPT_CURRENCY_AMOUNT,
       DAILY_AMOUNT,
       WEB_PARAMETER_ID,
       ADJUSTMENT_REASON ,
       AWARD_ID,
       CREDIT_CARD_TRX_ID,
       DIST_MATCH_TYPE,
       RCV_TRANSACTION_ID,
       INVOICE_DISTRIBUTION_ID ,
       PARENT_REVERSAL_ID,
       TAX_RECOVERABLE_FLAG,
       TAX_CODE_ID,
       MERCHANT_DOCUMENT_NUMBER,
       MERCHANT_NAME ,
       MERCHANT_REFERENCE,
       MERCHANT_TAX_REG_NUMBER,
       MERCHANT_TAXPAYER_ID,
       COUNTRY_OF_SUPPLY,
       MATCHED_UOM_LOOKUP_CODE,
       GMS_BURDENABLE_RAW_COST,
       ACCOUNTING_EVENT_ID,
       PREPAY_DISTRIBUTION_ID,
       UPGRADE_POSTED_AMT,
       UPGRADE_BASE_POSTED_AMT,
       INVENTORY_TRANSFER_STATUS,
       COMPANY_PREPAID_INVOICE_ID,
       CC_REVERSAL_FLAG,
       AWT_WITHHELD_AMT,
       PRICE_CORRECT_INV_ID,
       PRICE_CORRECT_QTY,
       PA_CMT_XFACE_FLAG,
       CANCELLATION_FLAG,
       INVOICE_LINE_NUMBER,
       ROUNDING_AMT,
       CHARGE_APPLICABLE_TO_DIST_ID ,
       CORRECTED_INVOICE_DIST_ID,
       CORRECTED_QUANTITY,
       RELATED_ID,
       JE_BATCH_ID,
       CASH_JE_BATCH_ID ,
       INVOICE_PRICE_VARIANCE,
       BASE_INVOICE_PRICE_VARIANCE,
       PRICE_ADJUSTMENT_FLAG,
       PRICE_VAR_CODE_COMBINATION_ID,
       RATE_VAR_CODE_COMBINATION_ID,
       EXCHANGE_RATE_VARIANCE,
       AMOUNT_ENCUMBERED ,
       BASE_AMOUNT_ENCUMBERED,
       QUANTITY_UNENCUMBERED,
       EARLIEST_SETTLEMENT_DATE,
       OTHER_INVOICE_ID,
       LINE_GROUP_NUMBER ,
       REQ_DISTRIBUTION_ID,
       PROJECT_ACCOUNTING_CONTEXT,
       PA_CC_AR_INVOICE_ID,
       PA_CC_AR_INVOICE_LINE_NUM,
       PA_CC_PROCESSED_CODE ,
       ASSET_BOOK_TYPE_CODE ,
       ASSET_CATEGORY_ID ,
       DISTRIBUTION_CLASS,
       FINAL_PAYMENT_ROUNDING,
       AMOUNT_AT_PREPAY_XRATE,
       AMOUNT_AT_PREPAY_PAY_XRATE,
       --ETAX: Invwkb
       INTENDED_USE,
       --Freight and Special Charges
       rcv_charge_addition_flag,
       invoice_includes_prepay_flag,  --Bug5224996
       org_id,
       pay_awt_group_id) --Bug 9058369
    SELECT
       trunc(p_prepay_dist_info(l_loop_counter).PREPAY_ACCOUNTING_DATE), --8532204
       'N',
       'U',
       ASSETS_TRACKING_FLAG,
       'N',
       p_prepay_dist_info(l_loop_counter).PREPAY_DIST_LINE_NUMBER,
       DIST_CODE_COMBINATION_ID,
       p_invoice_id,
       p_user_id,
       SYSDATE,
       p_prepay_dist_info(l_loop_counter).LINE_TYPE_LOOKUP_CODE,
       p_prepay_dist_info(l_loop_counter).PREPAY_PERIOD_NAME,
       SET_OF_BOOKS_ID,
       NULL,
       (- 1 * p_prepay_dist_info(l_loop_counter).PREPAY_APPLY_AMOUNT),
       (-1 * p_prepay_dist_info(l_loop_counter).PREPAY_BASE_AMOUNT),
       p_batch_id,
       p_user_id,
       SYSDATE,
       DESCRIPTION,
       NULL,
       INCOME_TAX_REGION ,
       p_last_update_login,
       Null,
       'N',
       PO_DISTRIBUTION_ID,
       program_application_id,
       program_id,
       SYSDATE,
       p_prepay_dist_info(l_loop_counter).PREPAY_QUANTITY_INVOICED,
       request_id,
       'N',
       TYPE_1099,
       UNIT_PRICE,
       'N' ,
       p_prepay_dist_info(l_loop_counter).PREPAY_STAT_AMOUNT,
       NULL,
       ATTRIBUTE1,
       ATTRIBUTE10,
       ATTRIBUTE11,
       ATTRIBUTE12,
       ATTRIBUTE13,
       ATTRIBUTE14,
       ATTRIBUTE15,
       ATTRIBUTE2,
       ATTRIBUTE3,
       ATTRIBUTE4,
       ATTRIBUTE5,
       ATTRIBUTE6,
       ATTRIBUTE7,
       ATTRIBUTE8,
       ATTRIBUTE9,
       ATTRIBUTE_CATEGORY,
       NULL,
       EXPENDITURE_ITEM_DATE,
       EXPENDITURE_ORGANIZATION_ID,
       EXPENDITURE_TYPE,
       NULL,
       --bugfix:4924696
       DECODE(pa_addition_flag,'E','E','N'),
       p_prepay_dist_info(l_loop_counter).PREPAY_PA_QUANTITY,
       NULL,
       NULL,
       NULL,
       PROJECT_ID,
       TASK_ID ,
    -- USSGL_TRANSACTION_CODE, - Bug 4277744
    -- USSGL_TRX_CODE_CONTEXT, - Bug 4277744
       NULL,
       NULL,
       NULL,
       NULL,
       AWT_GROUP_ID,
       AWT_TAX_RATE_ID,
       AWT_GROSS_AMOUNT,
       AWT_INVOICE_ID,
       AWT_ORIGIN_GROUP_ID,
       REFERENCE_1,
       REFERENCE_2,
       AWT_INVOICE_PAYMENT_ID,
       GLOBAL_ATTRIBUTE_CATEGORY,
       GLOBAL_ATTRIBUTE1 ,
       GLOBAL_ATTRIBUTE2 ,
       GLOBAL_ATTRIBUTE3 ,
       GLOBAL_ATTRIBUTE4 ,
       GLOBAL_ATTRIBUTE5 ,
       GLOBAL_ATTRIBUTE6 ,
       GLOBAL_ATTRIBUTE7 ,
       GLOBAL_ATTRIBUTE8 ,
       GLOBAL_ATTRIBUTE9 ,
       GLOBAL_ATTRIBUTE10,
       GLOBAL_ATTRIBUTE11,
       GLOBAL_ATTRIBUTE12,
       GLOBAL_ATTRIBUTE13,
       GLOBAL_ATTRIBUTE14,
       GLOBAL_ATTRIBUTE15,
       GLOBAL_ATTRIBUTE16,
       GLOBAL_ATTRIBUTE17,
       GLOBAL_ATTRIBUTE18,
       GLOBAL_ATTRIBUTE19,
       GLOBAL_ATTRIBUTE20,
       RECEIPT_VERIFIED_FLAG,
       RECEIPT_REQUIRED_FLAG,
       RECEIPT_MISSING_FLAG ,
       JUSTIFICATION,
       EXPENSE_GROUP,
       START_EXPENSE_DATE,
       END_EXPENSE_DATE,
       RECEIPT_CURRENCY_CODE,
       RECEIPT_CONVERSION_RATE,
       RECEIPT_CURRENCY_AMOUNT,
       DAILY_AMOUNT,
       WEB_PARAMETER_ID,
       ADJUSTMENT_REASON ,
       AWARD_ID,
       CREDIT_CARD_TRX_ID,
       DIST_MATCH_TYPE,
       RCV_TRANSACTION_ID,
       p_prepay_dist_info(l_loop_counter).INVOICE_DISTRIBUTION_ID,
       NULL,
       TAX_RECOVERABLE_FLAG,
       TAX_CODE_ID,
       MERCHANT_DOCUMENT_NUMBER,
       MERCHANT_NAME ,
       MERCHANT_REFERENCE,
       MERCHANT_TAX_REG_NUMBER,
       MERCHANT_TAXPAYER_ID,
       COUNTRY_OF_SUPPLY,
       MATCHED_UOM_LOOKUP_CODE,
       NULL,
       NULL,
       p_prepay_dist_info(l_loop_counter).PREPAY_DISTRIBUTION_ID,
       NULL,
       NULL,
       'N',
       COMPANY_PREPAID_INVOICE_ID,
       CC_REVERSAL_FLAG,
       NULL,
       PRICE_CORRECT_INV_ID,
       PRICE_CORRECT_QTY,
       PA_CMT_XFACE_FLAG,
       'N',
       p_line_number,
       ROUNDING_AMT,
       p_prepay_dist_info(l_loop_counter).charge_applicable_to_dist_id,
       NULL,
       NULL,
       p_prepay_dist_info(l_loop_counter).related_id,
       NULL,
       NULL,
       INVOICE_PRICE_VARIANCE,
       BASE_INVOICE_PRICE_VARIANCE,
       PRICE_ADJUSTMENT_FLAG,
       PRICE_VAR_CODE_COMBINATION_ID,
       RATE_VAR_CODE_COMBINATION_ID,
       EXCHANGE_RATE_VARIANCE,
       AMOUNT_ENCUMBERED ,
       BASE_AMOUNT_ENCUMBERED,
       QUANTITY_UNENCUMBERED,
       EARLIEST_SETTLEMENT_DATE,
       NULL,
       LINE_GROUP_NUMBER ,
       REQ_DISTRIBUTION_ID,
       PROJECT_ACCOUNTING_CONTEXT,
       NULL,
       NULL,
       NULL,
       ASSET_BOOK_TYPE_CODE ,
       ASSET_CATEGORY_ID ,
       'PERMANENT',
       NULL,
       (-1 * p_prepay_dist_info(l_loop_counter).PREPAY_BASE_AMT_PPAY_XRATE),
       (-1 * p_prepay_dist_info(l_loop_counter).PREPAY_BASE_AMT_PPAY_PAY_XRATE),
       --ETAX: Invwkb
       INTENDED_USE,
       'N',
       l_invoice_includes_prepay_flag,  --Bug5224996
       ORG_ID,
       PAY_AWT_GROUP_ID --Bug 9058369
    FROM ap_invoice_distributions
   WHERE invoice_distribution_id = p_prepay_dist_info(l_loop_counter).PREPAY_DISTRIBUTION_ID;

  -- ===============================================================
  -- Call GMS
  -- ===============================================================

  l_debug_info := 'Call Create Prepay ADL';
  GMS_AP_API.Create_Prepay_Adl (
          p_prepay_dist_info(l_loop_counter).PREPAY_DISTRIBUTION_ID,
          p_invoice_id,
          p_prepay_dist_info(l_loop_counter).PREPAY_DIST_LINE_NUMBER,
          p_prepay_dist_info(l_loop_counter).INVOICE_DISTRIBUTION_ID);


  --------------------------------------------------------------------
  -- Execute the Argentine/Colombian prepayment defaulting procedure
  --------------------------------------------------------------------

  IF (AP_EXTENDED_WITHHOLDING_PKG.Ap_Extended_Withholding_Active) THEN
    AP_EXTENDED_WITHHOLDING_PKG.Ap_Ext_Withholding_Prepay (
          p_prepay_dist_id    => p_prepay_dist_info(l_loop_counter).prepay_distribution_id,
          p_invoice_id        => p_invoice_id,
          p_inv_dist_id       => p_prepay_dist_info(l_loop_counter).invoice_distribution_id,
          p_user_id           => p_user_id,
          p_last_update_login => p_last_update_login,
          p_calling_sequence  => p_calling_sequence );
  END IF;

  -- ===============================================================
  -- Call Global
  -- ===============================================================

  l_debug_info := 'Update global context code';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  l_global_attr_category :=  p_prepay_dist_info(l_loop_counter).PREPAY_global_attr_category;

--  Bug 4014019. Commented out this call as it is invalid in 116 instance.
--  Logged a bug against JG to resolve the issue. This comment will have to
--  be taken out once JG code is fixed.
--  IF ( jg_globe_flex_val.reassign_context_code(
--         l_global_attr_category) <> TRUE) THEN
--               -- > IN   global context code in interface table
--               -- > OUT NOCOPY  global context code in base table
--    l_calling_sequence := 'reassign_context_code<-'||p_calling_sequence;
--  END IF;
  END LOOP;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_PREPAY_PKG.Insert_Prepay_Dists(-)');
  END IF;

  RETURN (TRUE);
EXCEPTION
  WHEN OTHERS THEN
  IF (SQLCODE <> -20001) THEN
    FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
    FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
    FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                    p_calling_sequence);
    FND_MESSAGE.SET_TOKEN('PARAMETERS',
               'P_PREPAY_INVOICE_ID    = '||P_PREPAY_INVOICE_ID
           ||', P_PREPAY_LINE_NUM      = '||P_PREPAY_LINE_NUM
           ||', P_INVOICE_ID           = '||P_INVOICE_ID
           ||', P_BATCH_ID             = '||P_BATCH_ID
           ||', P_LINE_NUMBER          = '||P_LINE_NUMBER
           ||', P_USER_ID              = '||P_USER_ID
           ||', P_LAST_UPDATE_LOGIN    = '||P_LAST_UPDATE_LOGIN);

    FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);

    IF INSTR(l_calling_program,'Apply Prepayment Form') > 0 THEN
      APP_EXCEPTION.RAISE_EXCEPTION;
    ELSE
      p_error_message := FND_MESSAGE.GET;
    END IF;

  END IF;

  l_result := AP_PREPAY_UTILS_PKG.Unlock_Line(
                p_prepay_invoice_id,
                p_prepay_line_num);
  RETURN (FALSE);

END Insert_Prepay_Dists;


FUNCTION Update_Prepayment(
          p_prepay_dist_info    IN      AP_PREPAY_PKG.Prepay_Dist_Tab_Type,
          p_prepay_invoice_id   IN      NUMBER,
          p_prepay_line_num     IN      NUMBER,
          p_invoice_id          IN      NUMBER,
          p_invoice_line_num    IN      NUMBER,
          p_appl_type           IN      VARCHAR2,
	        p_calling_mode	      IN      VARCHAR2  DEFAULT 'PREPAYMENT APPLICATION',
          p_calling_sequence    IN      VARCHAR2,
          P_error_message       OUT NOCOPY VARCHAR2)
RETURN BOOLEAN IS

  l_current_calling_sequence  VARCHAR2(2000);
  l_calling_program           VARCHAR2(1000);
  l_debug_info                VARCHAR2(4000);	--Changed length from 100 to 4000 (8534097)
  l_result                    BOOLEAN;
  l_api_name		      VARCHAR2(50);


BEGIN

  l_api_name := 'Update_Prepayment';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_PREPAY_PKG.Update_Prepayment(+)');
  END IF;

  l_current_calling_sequence := 'update_prepayment<-' ||p_calling_sequence;

  l_debug_info := 'Update Prepayment Info';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  -- 7338249
  UPDATE ap_invoice_distributions_all dp
     SET dp.prepay_amount_remaining = dp.total_dist_amount +
            (SELECT SUM(
                     (NVL(ds.amount, 0) + NVL(ds.prepay_tax_diff_amount, 0)))
                FROM ap_invoice_distributions_all ds
               WHERE ds.prepay_distribution_id = dp.invoice_distribution_id)
   WHERE dp.invoice_id = p_prepay_invoice_id
     AND (dp.invoice_line_number = p_prepay_line_num
          OR EXISTS (SELECT 'Exclusive Prepay Tax Line'
                       FROM ap_allocation_rule_lines arl
                      WHERE arl.invoice_id = p_prepay_invoice_id
                        AND arl.to_invoice_line_number = p_prepay_line_num
                        AND arl.chrg_invoice_line_number = dp.invoice_line_number));


  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_PREPAY_PKG.Update_Prepayment(-)');
  END IF;

RETURN (TRUE);

EXCEPTION
  WHEN OTHERS THEN
  IF (SQLCODE <> -20001) THEN
    FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
    FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
    FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                    l_current_calling_sequence);
    FND_MESSAGE.SET_TOKEN('PARAMETERS',
               'P_PREPAY_INVOICE_ID = '||P_PREPAY_INVOICE_ID
           ||', P_PREPAY_LINE_NUM   = '||P_PREPAY_LINE_NUM
           ||', P_INVOICE_ID        = '||P_INVOICE_ID
           ||', P_INVOICE_LINE_NUM  = '||P_INVOICE_LINE_NUM);

    FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);

    IF INSTR(l_calling_program,'Apply Prepayment Form') > 0 THEN
      APP_EXCEPTION.RAISE_EXCEPTION;
    ELSE
      p_error_message := FND_MESSAGE.GET;
    END IF;

  END IF;

  l_result := AP_PREPAY_UTILS_PKG.Unlock_Line(
                p_prepay_invoice_id,
                p_prepay_line_num);
  RETURN (FALSE);

END Update_Prepayment;


FUNCTION Update_PO_Receipt_Info(
          p_prepay_dist_info          IN      AP_PREPAY_PKG.Prepay_Dist_Tab_Type,
          p_prepay_invoice_id         IN      NUMBER,
          p_prepay_line_num           IN      NUMBER,
          p_invoice_id                IN      NUMBER,
          p_invoice_line_num          IN      NUMBER,
          p_po_line_location_id       IN      NUMBER,
          p_matched_UOM_lookup_code   IN      VARCHAR2,
          p_appl_type                 IN      VARCHAR2,
          p_match_basis               IN      VARCHAR2,
	  p_calling_sequence          IN      VARCHAR2,
          p_error_message             OUT NOCOPY  VARCHAR2)
RETURN BOOLEAN IS

l_current_calling_sequence      VARCHAR2(2000);
l_calling_program               VARCHAR2(1000);
l_debug_info                    VARCHAR2(4000);		--Changed length from 100 to 4000 (8534097)
l_loop_counter                  BINARY_INTEGER;

l_rcv_transaction_id     NUMBER;
l_po_distribution_id     NUMBER;
l_po_line_location_id    NUMBER;
l_unit_meas_lookup_code  NUMBER;
l_apply_amount           NUMBER;
l_quantity_invoiced      NUMBER;
l_match_basis            VARCHAR2(40);

--Contract Payments: Replacing the PO apis
--with new unified API
 l_po_ap_dist_rec               PO_AP_DIST_REC_TYPE;
 l_po_ap_line_loc_rec           PO_AP_LINE_LOC_REC_TYPE;
 l_api_name                     VARCHAR2(50);
 l_return_status                VARCHAR2(100);
 l_msg_data                     VARCHAR2(4000);
 l_shipment_quantity_recouped   NUMBER;
 l_shipment_amount_recouped	NUMBER;

CURSOR C_PO_Receipt_Update IS
SELECT ail.po_line_location_id,
       ail.unit_meas_lookup_code,
       aid.rcv_transaction_id,
       aid.po_distribution_id,
       aid.amount,
       aid.quantity_invoiced,
       plt.matching_basis
  FROM ap_invoice_distributions aid,
       ap_invoice_lines ail,
       po_lines pl, /* Amount Based Matching. PO related tables and conditions */
       po_line_locations pll,
       po_line_types_b plt,    --bug 5056269
       po_line_types_tl T
 WHERE aid.invoice_id             = ail.invoice_id
   AND aid.invoice_line_number    = ail.line_number
   AND aid.invoice_id             = p_invoice_id
   AND aid.invoice_line_number    = p_invoice_line_num
   AND NVL(aid.reversal_flag,'N') = 'Y'
   AND aid.parent_invoice_id      IS NOT NULL
   AND ail.po_line_location_id    = pll.line_location_id(+)
   and pll.po_line_id             = pl.po_line_id(+)
   and pl.line_type_id            = plt.line_type_id(+)
   and plt.LINE_TYPE_ID = T.LINE_TYPE_ID
   and  T.LANGUAGE = userenv('LANG');


  l_result   BOOLEAN;

BEGIN

  l_api_name := 'Update_Po_Receipt_Info';
  l_shipment_quantity_recouped := 0;
  l_shipment_amount_recouped := 0;

  l_calling_program := p_calling_sequence;

  -- Update the calling sequence for debugging purposes

  l_current_calling_sequence := 'update_po_receipt_info<-'||
                                  p_calling_sequence;
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_PREPAY_PKG.Update_PO_Receipt_Info(+)');
  END IF;

  l_debug_info := 'Create l_po_ap_dist_rec object';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  l_po_ap_dist_rec := PO_AP_DIST_REC_TYPE.create_object();

  l_debug_info := 'Create l_po_ap_line_loc_rec object and populate the data';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;


  IF p_appl_type = 'APPLICATION' THEN

    FOR l_loop_counter IN nvl(p_prepay_dist_info.FIRST,0) .. nvl(p_prepay_dist_info.LAST,0) LOOP

      IF (p_prepay_dist_info(l_loop_counter).ppay_po_distribution_id IS NOT NULL) THEN
        --SMYADAM: Need to modify this so that we call the PO apis to update
	--rather than the adjust po. For calling_mode of RECOUPMENT we need
	--to update the recouped_amounts as oppose to billed columns...

         l_po_ap_dist_rec.add_change(
			        p_po_distribution_id => p_prepay_dist_info(l_loop_counter).ppay_po_distribution_id,
                                p_uom_code           => p_matched_uom_lookup_code,
                                p_quantity_billed    => NULL,
                                p_amount_billed      => NULL,
                                p_quantity_financed  => NULL,
                                p_amount_financed    => NULL,
                                p_quantity_recouped  => (-1) *p_prepay_dist_info(l_loop_counter).prepay_quantity_invoiced ,
                                p_amount_recouped    => p_prepay_dist_info(l_loop_counter).prepay_apply_amount,
                                p_retainage_withheld_amt => NULL,
                                p_retainage_released_amt => NULL);

	 l_shipment_quantity_recouped := l_shipment_quantity_recouped +
					nvl((-1)*p_prepay_dist_info(l_loop_counter).prepay_quantity_invoiced,0);
	 l_shipment_amount_recouped := l_shipment_amount_recouped +
					nvl(p_prepay_dist_info(l_loop_counter).prepay_apply_amount,0);


      END IF;

      IF (p_prepay_dist_info(l_loop_counter).PPAY_RCV_TRANSACTION_ID IS NOT NULL) THEN

	 RCV_BILL_UPDATING_SV.ap_update_rcv_transactions(
             p_prepay_dist_info(l_loop_counter).ppay_rcv_transaction_id,
             p_prepay_dist_info(l_loop_counter).prepay_quantity_invoiced,
             p_matched_UOM_lookup_code,
             (-1) * p_prepay_dist_info(l_loop_counter).prepay_apply_amount,
             p_match_basis);

      END IF;

    END LOOP;

    IF (l_shipment_quantity_recouped <> 0 OR l_shipment_amount_recouped <> 0) THEN
       l_po_ap_line_loc_rec := PO_AP_LINE_LOC_REC_TYPE.create_object(
                                 p_po_line_location_id => p_po_line_location_id,
                                 p_uom_code            => p_matched_uom_lookup_code,
                                 p_quantity_billed     => NULL,
                                 p_amount_billed       => NULL,
                                 p_quantity_financed  => NULL,
                                 p_amount_financed    => NULL,
                                 p_quantity_recouped  => l_shipment_quantity_recouped,
                                 p_amount_recouped    => l_shipment_amount_recouped,
                                 p_retainage_withheld_amt => NULL,
                                 p_retainage_released_amt => NULL,
				 p_last_update_login  => NULL,
				 p_request_id	      => NULL
                                );

    END IF;


  ELSE

    OPEN C_PO_Receipt_Update;

    LOOP
      FETCH C_PO_Receipt_Update INTO
        l_po_line_location_id,
        l_unit_meas_lookup_code,
        l_rcv_transaction_id,
        l_po_distribution_id,
        l_apply_amount,
        l_quantity_invoiced,
        l_match_basis
        ;

      EXIT WHEN C_PO_Receipt_Update%NOTFOUND;

      IF (l_po_distribution_id IS NOT NULL) THEN

         l_po_ap_dist_rec.add_change(
			        p_po_distribution_id => l_po_distribution_id,
                                p_uom_code           => l_unit_meas_lookup_code,
                                p_quantity_billed    => NULL,
                                p_amount_billed      => NULL,
                                p_quantity_financed  => NULL,
                                p_amount_financed    => NULL,
                                p_quantity_recouped  => l_quantity_invoiced ,
                                p_amount_recouped    => l_apply_amount,
                                p_retainage_withheld_amt => NULL,
                                p_retainage_released_amt => NULL);

         l_shipment_quantity_recouped := l_shipment_quantity_recouped + nvl(l_quantity_invoiced,0);
	 l_shipment_amount_recouped := l_shipment_amount_recouped + nvl(l_apply_amount,0);

      END IF;

      IF (l_rcv_transaction_id IS NOT NULL) THEN

        RCV_BILL_UPDATING_SV.ap_update_rcv_transactions(
                l_rcv_transaction_id,
                l_quantity_invoiced,
                l_unit_meas_lookup_code,
                l_apply_amount,
                l_match_basis);

      END IF;

    END LOOP;

    CLOSE C_PO_Receipt_Update;

    IF (l_shipment_quantity_recouped <> 0 OR l_shipment_amount_recouped <> 0) THEN

       l_po_ap_line_loc_rec := PO_AP_LINE_LOC_REC_TYPE.create_object(
                                 p_po_line_location_id => l_po_line_location_id,
                                 p_uom_code            => l_unit_meas_lookup_code,
                                 p_quantity_billed     => NULL,
                                 p_amount_billed       => NULL,
                                 p_quantity_financed  => NULL,
                                 p_amount_financed    => NULL,
                                 p_quantity_recouped  => l_shipment_quantity_recouped,
                                 p_amount_recouped    => l_shipment_amount_recouped,
                                 p_retainage_withheld_amt => NULL,
                                 p_retainage_released_amt => NULL,
				 p_last_update_login  => NULL,
				 p_request_id	      => NULL
                                );

    END IF;

  END IF;  /* IF p_appl_type = ... */

  l_debug_info := 'Call the PO_AP_INVOICE_MATCH_GRP to update the Po Distributions and Po Line Locations';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  PO_AP_INVOICE_MATCH_GRP.Update_Document_Ap_Values(
                                        P_Api_Version => 1.0,
                                        P_Line_Loc_Changes_Rec => l_po_ap_line_loc_rec,
                                        P_Dist_Changes_Rec     => l_po_ap_dist_rec,
                                        X_Return_Status        => l_return_status,
                                        X_Msg_Data             => l_msg_data);

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_PREPAY_PKG.Update_PO_Receipt_Info(-)');
  END IF;

  RETURN (TRUE);
EXCEPTION
  WHEN OTHERS THEN
  IF (SQLCODE <> -20001) THEN
    FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
    FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
    FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                    l_current_calling_sequence);
    FND_MESSAGE.SET_TOKEN('PARAMETERS',
               'P_INVOICE_ID              = '||P_INVOICE_ID
           ||', P_INVOICE_LINE_NUM        = '||P_INVOICE_LINE_NUM
           ||', P_PO_LINE_LOCATION_ID     = '||P_PO_LINE_LOCATION_ID
           ||', P_MATCHED_UOM_LOOKUP_CODE = '||P_MATCHED_UOM_LOOKUP_CODE
           ||', P_APPL_TYPE               = '||P_APPL_TYPE);

    FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);

    IF INSTR(l_calling_program,'Apply Prepayment Form') > 0 THEN
      APP_EXCEPTION.RAISE_EXCEPTION;
    ELSE
      p_error_message := FND_MESSAGE.GET;
    END IF;

  END IF;

  l_result := AP_PREPAY_UTILS_PKG.Unlock_Line(
                p_prepay_invoice_id,
                p_prepay_line_num);

  RETURN (FALSE);
END Update_PO_Receipt_Info;


FUNCTION Update_Payment_Schedule(
          p_invoice_id              IN      NUMBER,
          p_prepay_invoice_id       IN      NUMBER,
          p_prepay_line_num         IN      NUMBER,
          p_apply_amount            IN      NUMBER,
          p_appl_type               IN      VARCHAR2,
          p_payment_currency_code   IN      VARCHAR2,
          p_user_id                 IN      NUMBER,
          p_last_update_login       IN      NUMBER,
          p_calling_sequence        IN      VARCHAR2,
	  p_calling_mode	    IN	    VARCHAR2 DEFAULT NULL,
          p_error_message           OUT NOCOPY VARCHAR2)
RETURN BOOLEAN IS

  l_debug_info                    VARCHAR2(4000);	--Changed length from 100 to 4000 (8534097)
  l_current_calling_sequence      VARCHAR2(2000);
  l_calling_program               VARCHAR2(1000);
  l_apply_amount_remaining        NUMBER;
  l_cursor_payment_num            NUMBER;
  l_cursor_amount                 NUMBER;
  l_result                        BOOLEAN;
  l_api_name			  VARCHAR2(50);

  l_amount_paid	NUMBER;

CURSOR  Schedules IS
SELECT  payment_num,
        DECODE(p_appl_type,
               'UNAPPLICATION', gross_amount - amount_remaining,
                amount_remaining)
  FROM  ap_payment_schedules
 WHERE  invoice_id               = p_invoice_id
   AND  (payment_status_flag||'' = 'P'
    OR   payment_status_flag||'' = DECODE(p_appl_type, 'UNAPPLICATION', 'Y', 'N'))
 ORDER BY DECODE(p_appl_type,
                 'UNAPPLICATION', DECODE(payment_status_flag,'P',1,'Y',2,3),
                 DECODE(NVL(hold_flag,'N'),'N',1,2)),
          DECODE(p_appl_type,
                 'UNAPPLICATION', due_date,
                  NULL) DESC,
          DECODE(p_appl_type,
                 'APPLICATION', due_date,
                 NULL),
          DECODE(p_appl_type,
                 'UNAPPLICATION', DECODE(hold_flag,'N',1,'Y',2,3),
                  DECODE(NVL(payment_status_flag,'N'),'P',1,'N',2,3));
BEGIN

    l_api_name := 'Update_Payment_Schedule';
    l_calling_program := p_calling_sequence;
    l_current_calling_sequence := 'update_payment_schedule<-'||
                                 p_calling_sequence;

    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_PREPAY_PKG.Update_Payment_Schedule(+)');
    END IF;

    IF (p_invoice_id            IS NULL OR
        p_apply_amount          IS NULL OR
        p_appl_type             IS NULL OR
        p_payment_currency_code IS NULL) THEN

      RAISE NO_DATA_FOUND;

    END IF;

    -- l_amount_apply_remaining will keep track of the apply amount that is
    -- remaining to be factored into amount remaining.

    l_apply_amount_remaining := p_apply_amount;

    l_debug_info := 'Open Payment Schedule Cursor';
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    OPEN SCHEDULES;

    LOOP

      l_debug_info := 'Fetch Schedules into local variables';
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;

      FETCH SCHEDULES INTO
            l_cursor_payment_num, l_cursor_amount;
      EXIT WHEN SCHEDULES%NOTFOUND;

       --Bug 8891266 Changes Start here
      IF (p_calling_mode = 'RECOUPMENT') THEN
		l_debug_info := 'Update ap_payment_schedule for the recoupments';
		IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
		END IF;

        UPDATE ap_payment_schedules
           SET amount_remaining = amount_remaining -
                                ap_utilities_pkg.ap_round_currency(
                                l_apply_amount_remaining,
                                p_payment_currency_code),
               payment_status_flag =
                           DECODE(amount_remaining -
                                ap_utilities_pkg.ap_round_currency(
                                l_apply_amount_remaining,
                                p_payment_currency_code),
                                0,'Y',
                                gross_amount, 'N',
                                'P'),
               last_update_date = SYSDATE,
               last_updated_by = p_user_id,
               last_update_login = p_last_update_login
         WHERE invoice_id = p_invoice_id
           AND payment_num = l_cursor_payment_num;

         EXIT;


     ELSE
       --Bug 8891266 Changes end here

      IF ((((l_apply_amount_remaining - l_cursor_amount) <= 0) AND
        (p_appl_type = 'APPLICATION')) OR
        (((l_apply_amount_remaining + l_cursor_amount) >= 0) AND
        (p_appl_type = 'UNAPPLICATION'))) THEN

    /*---------------------------------------------------------------------------+
     * Case 1 for                                                                *
     *   1. In apply prepayment(appl_type = 'APPLICATION'), the amount remaining *
     *     is greater than apply amount remaining.                               *
     *   2. In unapply prepayment, the apply amount (actually unapply amount     *
     *     here) is greater than amount_paid (gross amount-amount remaining).    *
     *                                                                           *
     *  It means that this schedule line has enough amount to apply(unapply)     *
     *  the whole apply_amount.                                                  *
     *                                                                           *
     *  Update the amount remaining for this payment schedule line so that:      *
     *  (amount remaining - apply amount remaining).                             *
     +---------------------------------------------------------------------------*/

        l_debug_info := 'Update ap_payment_schedule for the invoice, case 1';
	IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
	  FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
	END IF;

        UPDATE ap_payment_schedules
           SET amount_remaining = (amount_remaining -
                                   ap_utilities_pkg.ap_round_currency(
                                   l_apply_amount_remaining,
                                   p_payment_currency_code)),
               payment_status_flag =
                           DECODE(amount_remaining -
                                ap_utilities_pkg.ap_round_currency(
                                l_apply_amount_remaining,
                                p_payment_currency_code),
                                0,'Y',
                                gross_amount, 'N',
                                'P'),
               last_update_date = SYSDATE,
               last_updated_by = p_user_id,
               last_update_login = p_last_update_login
         WHERE invoice_id = p_invoice_id
           AND payment_num = l_cursor_payment_num;

         EXIT; -- No more amount left

      ELSE
    /*----------------------------------------------------------------------*
     *Case 2 for this line don't have enough amount to apply(unapply).      *
     *                                                                      *
     *   Update the amount_remaining to 0 and amount_apply_remaining become *
     *   (amount_apply - amount_remaining(this line)), then go to next      *
     *   schedule line.                                                     *
     *----------------------------------------------------------------------*/

        l_debug_info := 'Update ap_payment_schedule for the invoice, case 2';
	IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
	  FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
	END IF;

        UPDATE ap_payment_schedules
           SET amount_remaining = DECODE(p_appl_type,
                                         'APPLICATION',0,
                                         gross_amount),
               payment_status_flag = DECODE(p_appl_type,
                                           'APPLICATION','Y',
                                           'N'),
               last_update_date  = SYSDATE,
               last_updated_by   = p_user_id,
               last_update_login = p_last_update_login
        WHERE  invoice_id        = p_invoice_id
          AND  payment_num       = l_cursor_payment_num;

        IF (p_appl_type = 'APPLICATION') THEN
          l_apply_amount_remaining := l_apply_amount_remaining - l_cursor_amount;
        ELSE
          l_apply_amount_remaining := l_apply_amount_remaining + l_cursor_amount;
        END IF;

      END IF;
     END IF;
    END LOOP;

    l_debug_info := 'Close Schedule Cursor';
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    CLOSE SCHEDULES;

  --------------------------------------------------------------------------
  -- After update the payment schedules, the payment status flag should
  -- be updated according to the payment_status_flag of ap_payment_schedules
  -- to reflect the prepayment application
  --------------------------------------------------------------------------
  l_debug_info := 'Update ap_invoices to reflect the amount applied p_apply_amount, p_invoice_id '||p_apply_amount||','||p_invoice_id;
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;
  --Bug8414549 : Update the amount_paid column for Recoupment
  --IF nvl(p_calling_mode,'X') <> 'RECOUPMENT' THEN

    /*Bug 9643901: Moved the unused select to fetch amount paid, from after update to before
     and used it to check that amount paid does not go negative in case of unapplication.
     Similar check is present for amount remaining update on payment schedule above.*/

     SELECT nvl(amount_paid,0)
       into l_amount_paid
       from ap_invoices
      where invoice_id=p_invoice_id;

     if sign((l_amount_paid + p_apply_amount)) = -1 then
           l_amount_paid := 0;
     Else
           l_amount_paid := l_amount_paid + p_apply_amount;
     END if;
     /*Bug 9643901 end*/

     UPDATE ap_invoices
        SET amount_paid = l_amount_paid , /*Bug 9643901: replaced with local variable as set above*/
            payment_status_flag =
                        AP_INVOICES_UTILITY_PKG.get_payment_status(p_invoice_id ),
            last_update_date    = SYSDATE,
            last_updated_by     = P_user_id,
            last_update_login   = p_last_update_login
      WHERE invoice_id          = p_invoice_id;

   --END IF;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_PREPAY_PKG.Update_Payment_Schedule(-)');
   END IF;

   RETURN (TRUE);

EXCEPTION
  WHEN OTHERS THEN

    IF (SQLCODE <> -20001 ) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_current_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice_id = '||TO_CHAR(p_invoice_id)
             ||' APPLY_AMOUNT            = '||TO_CHAR(p_apply_amount)
             ||' APPLICATION_TYPE        = '||p_appl_type
             ||' APPLY_AMOUNT_REMAINING  = '||
                                     TO_CHAR(l_apply_amount_remaining)
             ||' CURSOR_AMOUNT           = '||TO_CHAR(l_cursor_amount)
             ||' CURSOR_PAYMENT_NUM      = '||TO_CHAR(l_cursor_payment_num)
             ||' USER_ID                 = '||TO_CHAR(p_user_id)
             ||' LAST_UPDATE_LOGIN       = '||TO_CHAR(p_last_update_login)
             ||' PAYMENT_CURRENCY_CODE   = '||p_payment_currency_code);

      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);

      IF INSTR(l_calling_program,'Apply Prepayment Form') > 0 THEN
        APP_EXCEPTION.RAISE_EXCEPTION;
      ELSE
        p_error_message := FND_MESSAGE.GET;
      END IF;

    END IF;

    l_result := AP_PREPAY_UTILS_PKG.Unlock_Line(
                p_prepay_invoice_id,
                p_prepay_line_num);

    RETURN (FALSE);

END update_payment_schedule;

-- bug 5056104 - removing obsolete functionality

--FUNCTION Update_Rounding_Amounts (
--          p_prepay_invoice_id      IN NUMBER,
--          p_prepay_line_num        IN NUMBER,
--          p_invoice_id             IN NUMBER,
--          p_line_number            IN NUMBER,
--          p_final_application      IN VARCHAR2,
--	  p_calling_sequence	   IN VARCHAR2 DEFAULT NULL,
--          p_error_message         OUT NOCOPY VARCHAR2)
--RETURN BOOLEAN IS
 -- bug 5056104 Removed code
--END Update_Rounding_Amounts;


FUNCTION Unapply_Prepay_Line (
          P_prepay_invoice_id IN NUMBER,
          P_prepay_line_num   IN NUMBER,
          P_invoice_id        IN NUMBER,
          P_line_num          IN NUMBER,
          P_unapply_amount    IN NUMBER,
          P_gl_date           IN DATE,
          P_period_name       IN VARCHAR2,
          P_prepay_included   IN VARCHAR2,
          P_user_id           IN NUMBER,
          P_last_update_login IN NUMBER,
          P_calling_sequence  IN VARCHAR2,
          P_error_message     OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS

-- Prepayment Invoice Related Variables

  l_ppay_inv_curr_code           ap_invoices_all.invoice_currency_code%TYPE;
  l_ppay_inv_pay_curr_code       ap_invoices_all.payment_currency_code%TYPE;
  l_ppay_inv_pay_cross_rate_date ap_invoices_all.payment_cross_rate_date%TYPE;
  l_ppay_inv_pay_cross_rate_type ap_invoices_all.payment_cross_rate_type%TYPE;
  l_ppay_apply_amt_in_pay_curr   NUMBER;
  l_prepay_line_rec              ap_invoice_lines_all%ROWTYPE;
  l_prepay_dist_info             AP_PREPAY_PKG.prepay_dist_tab_type;
  l_debug_info                   VARCHAR2(4000);	--Changed length from 100 to 4000 (8534097)
  l_current_calling_sequence     VARCHAR2(2000);
  l_calling_program                 VARCHAR2(1000);
  l_result                       BOOLEAN;
  l_dummy                        BOOLEAN;
--Bug 5225036 changed the datatype for l_error_code to VARCHAR2 from NUMBER
  l_error_code                   VARCHAR2(4000);
  l_token			 VARCHAR2(4000);

  tax_exception                  EXCEPTION;

CURSOR C_PPAY_INVOICE_INFO(CV_PPay_Invoice_ID IN NUMBER) IS
SELECT invoice_currency_code,
       payment_currency_code,
       payment_cross_rate_date,
       payment_cross_rate_type
  FROM AP_Invoices
 WHERE invoice_id = CV_PPay_Invoice_ID;

CURSOR C_PPAY_LINE_REC (CV_INVOICE_ID IN NUMBER,
                        CV_LINE_NUM   IN NUMBER)
IS
SELECT *
  FROM AP_INVOICE_LINES
 WHERE invoice_id  = CV_Invoice_ID
   AND line_number = CV_line_num;

BEGIN


  l_current_calling_sequence := 'Unapply_Prepay_Line <- '||p_calling_sequence;
  l_calling_program := p_calling_sequence;

  -- =============================================================
  -- Step 1: Get Required Information from the Prepayment Invoice
  --         and Line.
  -- =============================================================

  OPEN C_PPAY_INVOICE_INFO (P_PREPAY_INVOICE_ID);

  FETCH C_PPAY_INVOICE_INFO INTO
    l_ppay_inv_curr_code,
    l_ppay_inv_pay_curr_code,
    l_ppay_inv_pay_cross_rate_date,
    l_ppay_inv_pay_cross_rate_type;

  CLOSE C_PPAY_INVOICE_INFO;

  OPEN C_PPAY_LINE_REC (P_INVOICE_ID,
                        P_LINE_NUM);

  FETCH C_PPAY_LINE_REC INTO l_prepay_line_rec;

  CLOSE C_PPAY_LINE_REC;


  --Upgrade the PO Shipment if the invoice line is a matched one and if the
  --prepayment application had happened before upgrade to R12.

  AP_Matching_Utils_Pkg.AP_Upgrade_Po_Shipment(l_prepay_line_rec.po_line_location_id,
					       l_current_calling_sequence);


  -- Take the accounting_date and period_name passed from
  -- the form not the original ones in the Prepay Line.

  l_prepay_line_rec.accounting_date := P_gl_date;
  l_prepay_line_rec.period_name     := P_period_name;

  -- ==========================================================
  -- Step 1: Get Apply Amount in Payment Currency
  --         This information is used only when we update the
  --         Payment Schedules.
  --         Here we will get this amount and pass it to the
  --         Sub Procedure that updates the Payment Schedules.
  -- ==========================================================
  IF (l_ppay_inv_curr_code <> l_ppay_inv_pay_curr_code) THEN

    l_ppay_apply_amt_in_pay_curr :=
      GL_Currency_API.Convert_Amount
          (l_ppay_inv_curr_code,
           l_ppay_inv_pay_curr_code,
           l_ppay_inv_pay_cross_rate_date,
           l_ppay_inv_pay_cross_rate_type,
           P_unapply_amount);
  ELSE
    l_ppay_apply_amt_in_pay_curr := p_unapply_amount;
  END IF;

  -- ==========================================================
  -- Step 2: Discard PREPAY Line
  --         We will call the generic DISCARD LINE code that
  --         is written by Shelly. We don't have to rewrite this
  --         piece just for prepayments. We will still have to
  -- modify the code that she had written. I have listed them
  -- below:
  -- Parameters: We should be able to pass GL DATE and Period
  -- Name to it.
  -- The code should not do anything related to updating PO.
  -- We will address this during the Coding Stage.

  -- ==========================================================
  l_dummy := AP_INVOICE_LINES_PKG.Discard_Inv_Line (
               P_line_rec          => l_prepay_line_rec,
               P_calling_mode      => 'UNAPPLY_PREPAY',
               P_inv_cancellable   => 'Y',
               P_last_updated_by   => p_user_id,
               P_last_update_login => p_last_update_login,
               P_error_code        => l_error_code,
	       P_Token             => l_token,
               P_calling_sequence  => l_current_calling_sequence);

  IF l_dummy = FALSE THEN
    RETURN (FALSE);
  END IF;


  -- ===========================================================
  -- Step 3: Calculate Tax
  --          Call eTax service.
  -- ===========================================================
/* Bug 5388370: Tax unapplication will be handled in Discard_Inv_Line.
                Seperate call to tax calulation and determine_recovery
                is not required.

  l_debug_info := 'Call to calculate tax';
  IF NOT (ap_etax_pkg.calling_etax(
            p_invoice_id             => p_invoice_id,
            p_line_number            => l_prepay_line_rec.line_number,
            p_calling_mode           => 'UNAPPLY PREPAY',
            p_override_status        => NULL,
            p_line_number_to_delete  => NULL,
            P_Interface_Invoice_Id   => NULL,
            p_all_error_messages     => 'N',
            p_error_code             => p_error_message,
            p_calling_sequence       => l_current_calling_sequence)) THEN

         RAISE tax_exception;

  END IF;

  -- ===========================================================
  -- Step 4: Determine_recovery
  --          Call eTax service.
  -- ===========================================================
  l_debug_info := ' Call to Distribute tax';

  IF NOT (ap_etax_pkg.calling_etax(
            p_invoice_id             => p_invoice_id,
            p_line_number            => NULL,
            p_calling_mode           => 'DISTRIBUTE',
            p_override_status        => NULL,
            p_line_number_to_delete  => NULL,
            P_Interface_Invoice_Id   => NULL,
            p_all_error_messages     => 'N',
            p_error_code             => p_error_message,
            p_calling_sequence       => l_current_calling_sequence)) THEN

      RAISE tax_exception;

  END IF;
*/
  -- ===========================================================
  -- Step 6: Update Prepayment
  -- ===========================================================
  l_dummy := AP_PREPAY_PKG.Update_Prepayment(
               l_prepay_dist_info,
               p_prepay_invoice_id,
               p_prepay_line_num,
               p_invoice_id,
               p_line_num,
               'UNAPPLICATION',
	       NULL,    --p_calling_mode
               p_calling_sequence,
               p_error_message);

  IF l_dummy = FALSE THEN
    RETURN (FALSE);
  END IF;

  -- ===========================================================
  -- Step 7: Update PO/RCV information
  -- ===========================================================

  l_dummy := AP_PREPAY_PKG.Update_PO_Receipt_Info(
               l_prepay_dist_info,
               p_prepay_invoice_id,
               p_prepay_line_num,
               p_invoice_id,
               p_line_num,
               NULL,
               NULL,
              'UNAPPLICATION',
               NULL,
	       p_calling_sequence,
               p_error_message);

  IF l_dummy = FALSE THEN
    RETURN (FALSE);
  END IF;

  -- ===========================================================
  -- Step 8: Update Payment Schedules
  -- ===========================================================

  IF NVL(p_prepay_included, 'N') = 'N' THEN
    l_dummy := AP_PREPAY_PKG.Update_Payment_Schedule (
                p_invoice_id,
                p_prepay_invoice_id,
                p_prepay_line_num,
                l_ppay_apply_amt_in_pay_curr,
                'UNAPPLICATION',
                l_ppay_inv_pay_curr_code,
                p_user_id,
                p_last_update_login,
                p_calling_sequence,
		NULL,
                p_error_message);

    IF l_dummy = FALSE THEN
      RETURN (FALSE) ;
    END IF;

  END IF;

  -- ===========================================================
  -- Step 9: If we are here we have done everything we need to
  --          Hence we can return TRUE to the calling module.
  -- ===========================================================

  RETURN (TRUE);

EXCEPTION
  WHEN tax_exception THEN
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR', p_error_message, TRUE);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
     APP_EXCEPTION.RAISE_EXCEPTION;

  WHEN OTHERS THEN
  IF (SQLCODE <> -20001) THEN
    FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
    FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
    FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                    l_current_calling_sequence);
    FND_MESSAGE.SET_TOKEN('PARAMETERS',
               'P_PREPAY_INVOICE_ID       = '||P_PREPAY_INVOICE_ID
           ||', P_PREPAY_LINE_NUM         = '||P_PREPAY_LINE_NUM
           ||', P_INVOICE_ID              = '||P_INVOICE_ID
           ||', P_LINE_NUM                = '||P_LINE_NUM
           ||', P_GL_DATE                 = '||P_GL_DATE
           ||', P_PERIOD_NAME             = '||P_PERIOD_NAME
           ||', P_PREPAY_INCLUDED         = '||P_PREPAY_INCLUDED
           ||', P_UNAPPLY_AMOUNT          = '||P_UNAPPLY_AMOUNT
           ||', P_USER_ID                 = '||P_USER_ID
           ||', P_LAST_UPDATE_LOGIN       = '||P_LAST_UPDATE_LOGIN);

    FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);

    IF INSTR(l_calling_program,'Apply Prepayment Form') > 0 THEN
        APP_EXCEPTION.RAISE_EXCEPTION;
    ELSE
        p_error_message := FND_MESSAGE.GET;
    END IF;

  END IF;

  l_result := AP_PREPAY_UTILS_PKG.Unlock_Line(
                p_prepay_invoice_id,
                p_prepay_line_num);

  RETURN (FALSE);

END Unapply_Prepay_Line;


FUNCTION Apply_Prepay_FR_Prepay(
          p_invoice_id            IN     NUMBER,
          p_prepay_num            IN     VARCHAR2,
          p_vendor_id             IN     NUMBER,
          p_prepay_apply_amount   IN     NUMBER,
          p_prepay_gl_date        IN     DATE,
          p_prepay_period_name    IN     VARCHAR2,
          p_user_id               IN     NUMBER,
          p_last_update_login     IN     NUMBER,
          p_calling_sequence      IN     VARCHAR2,
          p_error_message         OUT NOCOPY VARCHAR2)
RETURN BOOLEAN IS

  l_prepay_dist_info          AP_PREPAY_PKG.PREPAY_DIST_TAB_TYPE;

  l_prepay_id                 NUMBER;
  l_prepay_num                VARCHAR2(50);
  l_prepay_ln_num             NUMBER;
  l_prepay_apply_amount       NUMBER      := p_prepay_apply_amount;
  l_apply_amount_remaining    NUMBER;
  l_cursor_amount_remaining   NUMBER;
  l_prepay_gl_date            DATE        := p_prepay_gl_date;
  l_prepay_period_name        VARCHAR2(15):= p_prepay_period_name;
  l_invoice_date              AP_INVOICES.INVOICE_DATE%TYPE;
  l_result                    BOOLEAN;
  l_debug_info                VARCHAR2(4000);	--Changed length from 100 to 4000 (8534097)
  l_current_calling_sequence  VARCHAR2(2000);
  l_calling_program           VARCHAR2(1000);
  l_apply_amount	      NUMBER;


CURSOR c_get_prepay_id (
             cv_prepay_num      VARCHAR2,
             cv_vendor_id       NUMBER) IS
SELECT  ai.invoice_id
  FROM  ap_invoices ai
 WHERE  ai.vendor_id                = cv_vendor_id
   AND  ai.invoice_num              = cv_prepay_num
   AND  ai.invoice_type_lookup_code = 'PREPAYMENT'
   AND  ai.payment_status_flag      = 'Y'
   AND  NVL(ai.earliest_settlement_date,sysdate+1) <= SYSDATE;

CURSOR c_case_c_apply(cv_prepay_invoice_id NUMBER) IS
SELECT ai.invoice_num,
       ail.line_number,
       AP_Prepay_Utils_PKG.get_line_prepay_amt_remaining
                           (ail.invoice_id,
                            ail.line_number)
  FROM  ap_invoices ai,
        ap_invoice_lines ail
 WHERE  ai.invoice_id                = cv_prepay_invoice_id
   AND  ail.invoice_id               = ai.invoice_id
   AND  AP_Prepay_Utils_PKG.get_line_prepay_amt_remaining
                           (ail.invoice_id,
                            ail.line_number) > 0
   AND  ail.line_type_lookup_code    = 'ITEM'
   AND  NVL(ail.discarded_flag,'N') <> 'Y'
 ORDER  BY ail.line_number;

BEGIN

  l_calling_program := p_calling_sequence;
  l_current_calling_sequence := 'Apply prepayment and prorate<-'
                                ||p_calling_sequence;

  l_apply_amount_remaining := l_prepay_apply_amount;

  OPEN  c_get_prepay_id (p_prepay_num, p_vendor_id);
  FETCH c_get_prepay_id INTO l_prepay_id;
  CLOSE c_get_prepay_id;

  OPEN c_case_c_apply(l_prepay_id);
    LOOP
      FETCH c_case_c_apply INTO
            l_prepay_num,
            l_prepay_ln_num,
            l_cursor_amount_remaining;
      EXIT WHEN c_case_c_apply%NOTFOUND or l_apply_amount_remaining = 0;

      -----------------------------------------------------------------
      -- To apply the specified prepayment to an invoice, we take the
      -- first available distribution line to apply, if it is enough
      -- to apply, exit from the loop; Otherwise, continue to the take
      -- the other distribution lines of the prepayment.
      ----------------------------------------------------------------

      IF (l_cursor_amount_remaining > l_apply_amount_remaining) THEN
        l_apply_amount := l_apply_amount_remaining;
      ELSE
        l_apply_amount := l_cursor_amount_remaining;
      END IF;

      l_apply_amount_remaining := l_apply_amount_remaining - l_apply_amount;

      l_result := AP_PREPAY_PKG.Apply_Prepay_Line (
                      l_prepay_id,
                      l_prepay_ln_num,
                      l_prepay_dist_info,
                      'Y',
                      p_invoice_id,
		      NULL, --p_invoice_line_number
                      l_apply_amount,
                      p_prepay_gl_date,
                      p_prepay_period_name,
                      'N',
                      p_user_id,
                      p_last_update_login,
		      l_current_calling_sequence,
		      'PREPAYMENT APPLICATION',
                      p_error_message);

      IF (l_apply_amount_remaining <= l_cursor_amount_remaining) THEN
        EXIT; -- We are done applying the last amount;
      ELSE
        IF l_result = FALSE THEN
          EXIT;
        ELSE
          -- No errors. So, application was
          -- successful. Therefore, update the apply_amount_remaining
          -- to go ahead with the next prepayment application.
          l_apply_amount_remaining := l_apply_amount_remaining -
                                      l_cursor_amount_remaining;

        END IF; -- IF (l_reject_code IS NOT NULL)
      END IF; -- IF (l_apply_amount_remaining <= l_prepay_apply_amount)

    END LOOP;
  CLOSE c_case_c_apply;

  RETURN (TRUE);

EXCEPTION
  WHEN OTHERS THEN
  IF (SQLCODE <> -20001) THEN
    FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
    FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
    FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                    l_current_calling_sequence);
    FND_MESSAGE.SET_TOKEN('PARAMETERS',
               'P_INVOICE_ID           = '||P_INVOICE_ID
           ||', P_PREPAY_NUM           = '||P_PREPAY_NUM
           ||', P_VENDOR_ID            = '||P_VENDOR_ID
           ||', P_PREPAY_APPLY_AMOUNT  = '||P_PREPAY_APPLY_AMOUNT
           ||', P_PREPAY_GL_DATE       = '||P_PREPAY_GL_DATE
           ||', P_PREPAY_PERIOD_NAME   = '||P_PREPAY_PERIOD_NAME
           ||', P_USER_ID                 = '||P_USER_ID
           ||', P_LAST_UPDATE_LOGIN       = '||P_LAST_UPDATE_LOGIN);

    FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);

    IF INSTR(l_calling_program,'Apply Prepayment Form') > 0 THEN
        APP_EXCEPTION.RAISE_EXCEPTION;
    ELSE
        p_error_message := FND_MESSAGE.GET;
    END IF;

  END IF;

  RETURN (FALSE);

END Apply_Prepay_FR_Prepay;


END AP_PREPAY_PKG;

/
