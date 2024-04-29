--------------------------------------------------------
--  DDL for Package Body AP_VENDOR_PUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_VENDOR_PUB_PKG" AS
/* $Header: appvndrb.pls 120.78.12010000.83 2010/04/27 21:00:55 vinaik ship $ */

  --Global constants for logging
  G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AP_VENDOR_PUB_PKG';
  G_MSG_UERROR        CONSTANT NUMBER := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
  G_MSG_ERROR         CONSTANT NUMBER := FND_MSG_PUB.G_MSG_LVL_ERROR;
  G_MSG_SUCCESS       CONSTANT NUMBER := FND_MSG_PUB.G_MSG_LVL_SUCCESS;
  G_MSG_HIGH          CONSTANT NUMBER := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
  G_MSG_MEDIUM        CONSTANT NUMBER := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
  G_MSG_LOW           CONSTANT NUMBER := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;
  G_LINES_PER_FETCH   CONSTANT NUMBER := 1000;

  G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_LEVEL_UNEXPECTED      CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR           CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION       CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT           CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE       CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT       CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME           CONSTANT VARCHAR2(100) := 'AP.PLSQL.AP_VENDOR_PUB_PKG';

  G_Vendor_Type_Lookup_Code VARCHAR2(30);

  -- Global Constants to set null
  ap_null_num             CONSTANT NUMBER := FND_API.G_NULL_NUM;
  ap_null_char            CONSTANT VARCHAR2(1) := FND_API.G_NULL_CHAR;
  ap_null_date            CONSTANT DATE     := FND_API.G_NULL_DATE;

--Function: Insert_Rejections
--This function is called whenever the process needs to insert a
--rejection into new supplier interface rejection table.

FUNCTION Insert_Rejections (
          p_parent_table        IN     VARCHAR2,
          p_parent_id           IN     NUMBER,
          p_reject_code         IN     VARCHAR2,
          p_last_updated_by     IN     NUMBER,
          p_last_update_login   IN     NUMBER,
          p_calling_sequence    IN     VARCHAR2)
RETURN BOOLEAN IS

  l_current_calling_sequence    VARCHAR2(2000);
  l_debug_info                  VARCHAR2(500);
  l_api_name           CONSTANT VARCHAR2(100) := 'INSERT_REJECTIONS';

BEGIN
  -- Update the calling sequence
  l_current_calling_sequence := 'AP_VENDOR_PUB_PKG.Insert_rejections<-'
                              ||P_calling_sequence;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'Parameters: '
                     ||' p_parent_table: '|| p_parent_table
                     ||', p_parent_id: '||to_char(p_parent_id)
                     ||', p_reject_code: '||p_reject_code);
  END IF;
  --
  l_debug_info := '(Insert Rejections 1) Insert into AP_SUPPLIER_INT_REJECTIONS, '||
                'REJECT CODE:'||p_reject_code;
  --
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  INSERT INTO AP_SUPPLIER_INT_REJECTIONS(
          parent_table,
          parent_id,
          reject_lookup_code,
          last_updated_by,
          last_update_date,
          last_update_login,
          created_by,
          creation_date)
  VALUES (
          p_parent_table,
          p_parent_id,
          p_reject_code,
          p_last_updated_by,
          SYSDATE,
          p_last_update_login,
          p_last_updated_by,
          SYSDATE);

  RETURN(TRUE);

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001 ) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM );
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_current_calling_sequence );
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info );
    END IF;
    --
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,SQLERRM);
    END IF;

    RETURN (FALSE);

END Insert_Rejections;
--

PROCEDURE Val_Currency_Code(p_currency_code IN         VARCHAR2,
                            x_valid         OUT NOCOPY BOOLEAN
                            )
IS
  l_count          NUMBER := 0;

BEGIN
  x_valid := TRUE;

  IF p_currency_code IS NOT NULL THEN
     SELECT COUNT(*)
     INTO   l_count
     FROM   fnd_currencies_vl
     WHERE  currency_code = p_currency_code
     AND    enabled_flag = 'Y'
     AND    currency_flag = 'Y'
     AND    TRUNC(NVL(start_date_active, SYSDATE)) <= TRUNC(SYSDATE)
     AND    TRUNC(NVL(end_date_active, SYSDATE))>= TRUNC(SYSDATE);

     IF l_count < 1 THEN
	x_valid    := FALSE;
       	FND_MESSAGE.SET_NAME('SQLGL','GL_API_INVALID_CURR');
	FND_MSG_PUB.ADD;

     END IF;
   END IF;

END Val_Currency_Code;

PROCEDURE Validate_Lookups(
        p_column_name          IN      VARCHAR2,
        p_column_value         IN      VARCHAR2,
        p_lookup_type          IN      VARCHAR2,
        p_lookup_table         IN      VARCHAR2,
 	x_valid            OUT NOCOPY BOOLEAN
        )

	IS
   	l_dummy_lookup       VARCHAR2(30);

BEGIN
   x_valid    := TRUE;

   IF p_lookup_table = 'AP_LOOKUP_CODES' THEN

        Begin
                SELECT lookup_code
                INTO l_dummy_lookup
                FROM ap_lookup_codes
                WHERE lookup_type = p_lookup_type
                AND lookup_code = p_column_value
                AND enabled_flag = 'Y'
                AND nvl(inactive_date,sysdate+1) > sysdate;


	EXCEPTION
	 WHEN NO_DATA_FOUND THEN
         x_valid    := FALSE;
         FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
         FND_MESSAGE.SET_TOKEN('COLUMN_NAME', p_column_name );
	 FND_MSG_PUB.ADD;

	End;
   ELSIF p_lookup_table = 'PO_LOOKUP_CODES' THEN
        Begin
                SELECT lookup_code
                INTO l_dummy_lookup
                FROM po_lookup_codes
                WHERE lookup_type = p_lookup_type
                AND lookup_code = p_column_value
                AND enabled_flag = 'Y'
                AND nvl(inactive_date,sysdate+1) > sysdate;


	       EXCEPTION
         WHEN NO_DATA_FOUND THEN
         x_valid    := FALSE;
         FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
         FND_MESSAGE.SET_TOKEN('COLUMN_NAME', p_column_name );
	 FND_MSG_PUB.ADD;

	End;

   ELSIF p_lookup_table = 'FND_LOOKUP_VALUES' THEN
        Begin
                SELECT lookup_code
                INTO l_dummy_lookup
                FROM fnd_lookups
                --FROM fnd_lookup_vlaues
                --modified by abhsaxen from fnd_lookup_vlaues to fnd_lookups
                --as fnd_lookups is respecting user language.
                WHERE lookup_type = p_lookup_type
                AND lookup_code = p_column_value
                AND enabled_flag = 'Y'
                AND nvl(end_date_active,sysdate+1) > sysdate;

               EXCEPTION
         WHEN NO_DATA_FOUND THEN
         x_valid    := FALSE;
         FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
         FND_MESSAGE.SET_TOKEN('COLUMN_NAME', p_column_name );
	 FND_MSG_PUB.ADD;
        End;

   END IF;

END validate_lookups;


 PROCEDURE Check_dup_vendor_site ( x_vendor_id             IN NUMBER,
                                   x_vendor_site_code      IN VARCHAR2,
                                   x_org_name              IN VARCHAR2,
                                   x_org_id                IN NUMBER,
                                   x_valid                 OUT NOCOPY BOOLEAN)
IS

        l_dup_count_org_id              number;
        l_dup_count_org_name            number;

 BEGIN

   IF x_org_id is NOT NULL THEN
       SELECT count(*)
        INTO   l_dup_count_org_id
	-- bug 7430783 Changing validation table to ap_supplier_sites_all
        --FROM   po_vendor_sites_all SITE
	FROM   ap_supplier_sites_all SITE
        WHERE  SITE.vendor_id = x_vendor_id
        AND    SITE.org_id = x_org_id
        AND    UPPER(SITE.vendor_site_code) = UPPER(x_vendor_site_code);

   ELSIF (x_org_id is NULL and x_org_name is NOT NULL)  THEN
       SELECT count(*)
        INTO   l_dup_count_org_name
	-- bug 7430783 Changing validation table to ap_supplier_sites_all
        --FROM   po_vendor_sites_all SITE, HR_OPERATING_UNITS ORG
	FROM   ap_supplier_sites_all SITE, HR_OPERATING_UNITS ORG
        WHERE  SITE.vendor_id = x_vendor_id
        AND    ORG.name = x_org_name
        AND    UPPER(vendor_site_code) = UPPER(x_vendor_site_code)
        AND    SITE.org_id = ORG.organization_id;

   END IF;

      IF (l_dup_count_org_id > 0 OR l_dup_count_org_name > 0 ) THEN
	 x_valid    := FALSE;
         fnd_message.set_name('SQLAP','AP_VEN_DUPLICATE_VEN_SITE');
	 FND_MSG_PUB.ADD;
      END IF;

 END Check_dup_vendor_site;

 --
 -- Check if the 1099 type is expected here
 --
 PROCEDURE Check_Valid_1099_type(p_1099_type    IN        VARCHAR2,
                                 p_federal_flag IN        VARCHAR2,
				 x_valid         OUT NOCOPY BOOLEAN
                                 ) IS
 BEGIN
    x_valid    := TRUE;


	IF (nvl(p_federal_flag,'N') = 'N' and p_1099_type is NOT NULL) THEN
         x_valid    := FALSE;
         FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMNS_INCONSISTENT');
         FND_MESSAGE.SET_TOKEN('ID','FEDERAL_REPORTABLE_FLAG');
         FND_MESSAGE.SET_TOKEN('NAME','1099_TYPE');
	 FND_MSG_PUB.ADD;
        END IF;

 END Check_Valid_1099_type;

 --
 -- Check if the Payment_Priority number is valid
 --
 PROCEDURE Check_Payment_Priority(p_payment_priority   IN         NUMBER,
                              x_valid                   OUT NOCOPY BOOLEAN
                              ) IS
 BEGIN
    x_valid    := TRUE;


        IF ((p_payment_priority < 1)  OR
            (p_payment_priority > 99) OR
            (p_payment_priority <> trunc(p_payment_priority))) THEN

         x_valid    := FALSE;

         FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
         FND_MESSAGE.SET_TOKEN('COLUMN_NAME','PAYMENT_PRIORITY' );
	 FND_MSG_PUB.ADD;
        END IF;
 END Check_Payment_Priority;

 --
 -- Check if the Employee is valid
 --
 PROCEDURE Check_Valid_Employee(p_employee_id    IN         NUMBER,
                              x_valid            OUT NOCOPY BOOLEAN
                              ) IS
    l_dummy          hr_employees_current_v.employee_id%TYPE;

 BEGIN
    x_valid    := TRUE;

       SELECT employee_id
       INTO   l_dummy
       FROM   hr_employees_current_v
       WHERE  employee_id  = p_employee_id;


     EXCEPTION
    -- Trap validation error
    WHEN NO_DATA_FOUND THEN
         x_valid    := FALSE;

         FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
	 FND_MESSAGE.SET_TOKEN('COLUMN_NAME','EMPLOYEE_ID' );
	 FND_MSG_PUB.ADD;

 END Check_Valid_Employee;

 --
 -- Check if Inspection_required_flag and Receipt_required_flag are valid
 --
 PROCEDURE Check_Valid_match_level(p_inspection_reqd_flag      IN         VARCHAR2,
                                   p_receipt_reqd_flag         IN         VARCHAR2,
                                   x_valid                     OUT NOCOPY BOOLEAN
                                   ) IS

 BEGIN
    x_valid    := TRUE;

     IF (p_receipt_reqd_flag = 'N' and p_inspection_reqd_flag = 'Y') THEN
        x_valid    := FALSE;
         FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMNS_INCONSISTENT');
         FND_MESSAGE.SET_TOKEN('ID','INSPECTION_REQUIRED_FLAG');
         FND_MESSAGE.SET_TOKEN('NAME','RECEIPT_REQUIRED_FLAG');
	 FND_MSG_PUB.ADD;
     END IF;

 END Check_Valid_match_level;

 --
 -- Check if the Name_control is valid
 --
 PROCEDURE Check_Valid_name_control(p_name_control     IN         VARCHAR2,
                                    x_valid            OUT NOCOPY BOOLEAN
                                    ) IS

 BEGIN
    x_valid    := TRUE;

	IF (nvl(NVL(length(ltrim(translate(p_name_control,
		'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789&- ',
		'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'),'X')), 0),0) > 0) THEN

                x_valid    := FALSE;
                FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
                FND_MESSAGE.SET_TOKEN('COLUMN_NAME','NAME_CONTROL' );
		FND_MSG_PUB.ADD;
	END IF;

 END Check_Valid_name_control;

 --
 -- Check if ship_via_lookup_code is valid
 --
 PROCEDURE Check_Valid_ship_via(p_ship_via_lookup_code      IN  VARCHAR2,
                                p_inventory_org_id          IN  NUMBER DEFAULT NULL,
				x_valid            	    OUT NOCOPY BOOLEAN
                              ) IS
    l_dummy          number;

 BEGIN
    x_valid    := TRUE;

       SELECT nvl(count(freight_code),0)
       INTO   l_dummy
       FROM   org_freight
       WHERE  organization_id = p_inventory_org_id
       AND    nvl(disable_date, sysdate +1 ) > sysdate
       AND    freight_code = p_ship_via_lookup_code;


       IF l_dummy < 1 THEN
         x_valid    := FALSE;

         FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
         FND_MESSAGE.SET_TOKEN('COLUMN_NAME','SHIP_VIA_LOOKUP_CODE' );
	 FND_MSG_PUB.ADD;
       END IF;

 END Check_Valid_ship_via;

 --
 -- Check if the set_of_books_id is valid
 --
 PROCEDURE Check_Valid_Sob_Id(p_sob_id           IN         NUMBER,
                            x_valid            OUT NOCOPY BOOLEAN
                            ) IS
    l_dummy          GL_SETS_OF_BOOKS.set_of_books_id%TYPE;

 BEGIN
    x_valid    := TRUE;

       SELECT set_of_books_id
       INTO   l_dummy
       FROM   GL_SETS_OF_BOOKS
       WHERE  set_of_books_id = p_sob_id;


 EXCEPTION
    -- Trap validation error
    WHEN NO_DATA_FOUND THEN
         x_valid    := FALSE;
         FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
         FND_MESSAGE.SET_TOKEN('COLUMN_NAME','SET_OF_BOOKS_ID' );
	 FND_MSG_PUB.ADD;
 END Check_Valid_Sob_Id;

 --
 -- Check if the Employee has already been assigned
 --
 PROCEDURE Chk_Dup_Employee(p_vendor_id   IN         NUMBER,
                            p_employee_id IN         NUMBER,
                            x_valid       OUT NOCOPY BOOLEAN
                           ) IS
    l_count          NUMBER := 0;

 BEGIN
    x_valid    := TRUE;


       SELECT COUNT(*)
       INTO   l_count
       FROM   po_vendors
       WHERE  (p_vendor_id IS NULL OR p_vendor_id = ap_null_num OR vendor_id <> p_vendor_id) --bug7023543
       AND    employee_id = p_employee_id;

       IF l_count > 0 THEN
		x_valid    := FALSE;

		FND_MESSAGE.SET_NAME('SQLAP','AP_EMPLOYEE_ASSIGNED');
		FND_MSG_PUB.ADD;
       END IF;

 END Chk_Dup_Employee;

 --
 -- Check for duplicate vendor number
 --
 PROCEDURE Chk_Dup_segment1_int(p_segment1      IN VARCHAR2,
                                x_valid         OUT NOCOPY BOOLEAN
                               ) IS

   l_count          NUMBER := 1;

 BEGIN
   x_valid    := TRUE;
   --Bug 7526020 Validating SEGMENT1 against ap_suppliers instead of ap_suppliers_int
   SELECT COUNT(*)
   INTO   l_count
   FROM   ap_suppliers
   WHERE segment1 = p_segment1;

   IF l_count > 1 THEN
	x_valid    := FALSE;
      	FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
      	FND_MESSAGE.SET_TOKEN('COLUMN_NAME','SEGMENT1' );
	FND_MSG_PUB.ADD;
   END IF;

 END Chk_Dup_segment1_int;

--
-- Check for duplicate vendor names
--
/* Bug 6939863 - Made Chk_Dup_Vendor_Name_new with same logic as update.
 * Bug 5606948 added a call to Chk_Dup_Vendor_Name_update in
 * PROCEDURE Validate_Vendor even in Insert mode.
 * Chk_Dup_Vendor_Name_new is not called from anywhere, so made this similar
 * to Chk_Dup_Vendor_Name_update and also corrected employee_id logic
 * in both calls.
PROCEDURE Chk_Dup_Vendor_Name_new(p_vendor_name    IN VARCHAR2,
                              x_valid          OUT NOCOPY BOOLEAN
                              ) IS
  l_count          NUMBER := 0;

BEGIN
   x_valid    := TRUE;

   SELECT COUNT(*)
   INTO   l_count
   FROM   ap_suppliers_int
   WHERE  UPPER(vendor_name) = UPPER(p_vendor_name);

    IF l_count > 1 THEN
      x_valid    := FALSE;
      FND_MESSAGE.SET_NAME('SQLAP','AP_VEN_DUPLICATE_NAME');
      FND_MSG_PUB.ADD;
    END IF;

END Chk_Dup_Vendor_Name_new;
Bug 6939863 */

PROCEDURE Chk_Dup_Vendor_Name_new(p_vendor_name    IN VARCHAR2,
                                  p_vendor_id      IN NUMBER,
                                  p_vendor_type_lookup_code IN VARCHAR2,
                                  p_employee_id    IN NUMBER,
                                  x_valid          OUT NOCOPY BOOLEAN
                                 ) IS
  l_count          NUMBER := 0;

BEGIN

   x_valid    := TRUE;

   --open issue 1 with manoj regarding whether the vendor name
   --will even be denormalized into po_vendors

   -- Added following if condition for bug 6775797

   IF ((p_vendor_type_lookup_code  IS NOT NULL AND
       p_vendor_type_lookup_code <> 'EMPLOYEE')
       OR p_vendor_type_lookup_code IS NULL) THEN

     -- Bug 7596921 - Start
     /*
     SELECT COUNT(*)
     INTO   l_count
     FROM   ap_suppliers
     WHERE  UPPER(vendor_name) = UPPER(p_vendor_name)
     AND    (p_vendor_id IS NULL OR vendor_id <> p_vendor_id);  --bug 5606948
     */

     BEGIN
       SELECT 1
       INTO   l_count
       FROM   ap_suppliers
       WHERE  UPPER(vendor_name) = UPPER(p_vendor_name)
       AND    (p_vendor_id IS NULL OR vendor_id <> p_vendor_id)
       AND    ROWNUM = 1;
     EXCEPTION WHEN NO_DATA_FOUND THEN
       l_count := 0;
     END;

   ELSE

     /*
     SELECT COUNT(*)
     INTO   l_count
     FROM   ap_suppliers
     WHERE  UPPER(vendor_name) = UPPER(p_vendor_name)
     AND    (p_vendor_id IS NULL OR vendor_id <> p_vendor_id)
     --bug 6939863 - changed <> to = for employee_id
     AND    (p_employee_id IS NULL OR employee_id = p_employee_id);
     */

     BEGIN
       SELECT 1
       INTO   l_count
       FROM   ap_suppliers
       WHERE  UPPER(vendor_name) = UPPER(p_vendor_name)
       AND    (p_vendor_id IS NULL OR vendor_id <> p_vendor_id)
       --bug 6939863 - changed <> to = for employee_id
       AND    (p_employee_id IS NULL OR employee_id = p_employee_id)
       AND    ROWNUM = 1;
     EXCEPTION WHEN NO_DATA_FOUND THEN
       l_count := 0;
     END;

     -- Bug 7596921 - End

   END IF;

   IF l_count > 0 THEN
      x_valid    := FALSE;
      FND_MESSAGE.SET_NAME('SQLAP','AP_VEN_DUPLICATE_NAME');
      FND_MSG_PUB.ADD;
    END IF;

END Chk_Dup_Vendor_Name_new;


--
-- Check for duplicate vendor number
--
PROCEDURE Chk_Dup_Vendor_Number(p_vendor_id     IN NUMBER,
                                p_segment1      IN VARCHAR2,
                                x_valid         OUT NOCOPY BOOLEAN
                               ) IS

   l_count          NUMBER := 0;

BEGIN
   x_valid    := TRUE;

   SELECT COUNT(*)
   INTO   l_count
   FROM   po_vendors
   WHERE  (p_vendor_id IS NULL OR vendor_id <> p_vendor_id)
   AND    segment1 = p_segment1;

   IF l_count = 0 THEN
     SELECT count(*)
     INTO   l_count
     FROM   po_history_vendors
     WHERE  segment1 = p_segment1;
   END IF;

   IF l_count > 0 THEN
      x_valid    := FALSE;
      FND_MESSAGE.SET_NAME('SQLAP','AP_VEN_DUPLICATE_VEN_NUM');
      FND_MSG_PUB.ADD;
   END IF;

 END Chk_Dup_Vendor_Number;

 --
 -- Check if the receiving_routing_id is valid
 --
 PROCEDURE Chk_rcv_routing_id(p_rcv_rtg_id         IN         NUMBER,
                            x_valid            OUT NOCOPY BOOLEAN
                            ) IS
    l_dummy          RCV_ROUTING_HEADERS.routing_header_id%TYPE;

 BEGIN
    x_valid    := TRUE;

       SELECT routing_header_id
       INTO  l_dummy
       FROM  RCV_ROUTING_HEADERS
       WHERE routing_header_id = p_rcv_rtg_id;


 EXCEPTION
    -- Trap validation error
    WHEN NO_DATA_FOUND THEN
         x_valid    := FALSE;
	 FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
         FND_MESSAGE.SET_TOKEN('COLUMN_NAME','RECEIVING_ROUTING_ID' );
	 FND_MSG_PUB.ADD;
 END Chk_rcv_routing_id;

   --
   -- This procedure should perform Other Employee Validations
   --
   PROCEDURE employee_type_checks(p_vendor_type     IN         VARCHAR2,
                                p_employee_id     IN         NUMBER,
                                p_valid           OUT NOCOPY BOOLEAN
                               ) IS

   BEGIN
      p_valid := TRUE;

      IF ( (p_vendor_type <> 'EMPLOYEE'
            AND (p_employee_id is Not Null AND p_employee_id <> ap_null_num))
            OR
           (p_vendor_type = 'EMPLOYEE'  --bug6050423
            AND (p_employee_id is Null OR p_employee_id = ap_null_num)) ) THEN

         p_valid    := FALSE;
         FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMNS_INCONSISTENT');
         FND_MESSAGE.SET_TOKEN('ID','VENDOR_TYPE_LOOKUP_CODE');
         FND_MESSAGE.SET_TOKEN('NAME','EMPLOYEE_ID');
	 FND_MSG_PUB.ADD;
      END IF;

   END employee_type_checks;

   --
   --  This procedure should ensure the value for 'payment_currency_code' exists as a valid
   --  currency_code on the target database
   --  Bug 2931673, replaced parameter p_vendor_id with p_invoice_currency_code
   --
   PROCEDURE payment_currency_code_valid(p_payment_currency_code  IN         VARCHAR2,
                                         p_invoice_currency_code  IN         VARCHAR2,
                                         p_valid                  OUT NOCOPY BOOLEAN
                                        ) IS
      l_count                  NUMBER := 1;

   BEGIN
      p_valid := TRUE;


      /*
       * assumes p_invoice_currency_code is valid
       * only validate if they're different
       */
      IF(p_payment_currency_code<>p_invoice_currency_code) THEN

        SELECT count(*)
        INTO   l_count
        FROM   fnd_currencies_vl
        WHERE  currency_code = p_payment_currency_code
        AND    (gl_currency_api.is_fixed_rate(p_invoice_currency_code
                                              ,currency_code
                                              ,sysdate)= 'Y'
               AND enabled_flag = 'Y'
               AND trunc(nvl(start_date_active,sysdate)) <= trunc(sysdate)
               AND trunc(nvl(end_date_active,sysdate)) >= trunc(sysdate)
               );

        IF (l_count = 0) THEN
	   FND_MESSAGE.SET_NAME('SQLAP','AP_API_INVALID_PAYMENT_CURR');
           p_valid := FALSE;
	   FND_MSG_PUB.ADD;
        END IF;

      END IF;

   END payment_currency_code_valid;

 --
 -- Validate the Income Tax Type
 --
 PROCEDURE Val_Income_Tax_Type(p_type_1099 IN         VARCHAR2,
                               x_valid     OUT NOCOPY BOOLEAN
                               ) IS
    l_count          NUMBER := 0;

 BEGIN
    x_valid    := TRUE;

       SELECT COUNT(*)
       INTO   l_count
       FROM   ap_income_tax_types
       WHERE  income_tax_type = p_type_1099
       AND    TRUNC(SYSDATE) < TRUNC(NVL(inactive_date, SYSDATE+1));

       IF l_count < 1 THEN
       	x_valid    := FALSE;
	FND_MESSAGE.SET_NAME('SQLAP','AP_API_INVALID_IN_TAX_TYPE');
	FND_MSG_PUB.ADD;
       END IF;

 END Val_Income_Tax_Type;

PROCEDURE Validate_CCIDs(
        p_column_name          IN      VARCHAR2,
        p_ccid         	       IN      NUMBER,
        p_sob_id               IN      NUMBER,
        x_valid            OUT NOCOPY  BOOLEAN
        )

        IS
        l_ccid       gl_code_combinations.Code_Combination_Id%TYPE;

BEGIN
   x_valid    := TRUE;

   IF p_column_name = 'ACCTS_PAY_CCID' THEN

        Begin
                SELECT GCC.code_combination_id
                INTO l_ccid
                FROM GL_CODE_COMBINATIONS GCC, GL_SETS_OF_BOOKS GSOB
                WHERE GCC.code_combination_id = p_ccid
                AND GCC.account_type = 'L'
                AND GCC.enabled_flag = 'Y'
                AND GCC.detail_posting_allowed_flag = 'Y'
                AND GSOB.set_of_books_id = p_sob_id
                AND GSOB.chart_of_accounts_id = GCC.chart_of_accounts_id
		AND nvl(GCC.end_date_active,sysdate+1) > sysdate;


        EXCEPTION
         WHEN NO_DATA_FOUND THEN
         x_valid    := FALSE;
         FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
         FND_MESSAGE.SET_TOKEN('COLUMN_NAME', p_column_name );
	 FND_MSG_PUB.ADD;
        End;
   ELSE
        Begin
		SELECT GCC.code_combination_id
                INTO l_ccid
                FROM GL_CODE_COMBINATIONS GCC, GL_SETS_OF_BOOKS GSOB
                WHERE GCC.code_combination_id = p_ccid
                AND GCC.enabled_flag = 'Y'
                AND GCC.detail_posting_allowed_flag = 'Y'
                AND GCC.chart_of_accounts_id = GSOB.chart_of_accounts_id
                AND GSOB.set_of_books_id = p_sob_id
		AND nvl(GCC.end_date_active,sysdate+1) > sysdate;

         EXCEPTION
         WHEN NO_DATA_FOUND THEN
         x_valid    := FALSE;
         FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
         FND_MESSAGE.SET_TOKEN('COLUMN_NAME', p_column_name );
	 FND_MSG_PUB.ADD;
        End;
   END IF;

END validate_CCIDs;

--
-- Check for duplicate vendor names
--
-- Added parameter p_vendor_type_lookup_code and p_employee_id
-- for bug 6775797
PROCEDURE Chk_Dup_Vendor_Name_update(p_vendor_name    IN VARCHAR2,
         			     p_vendor_id      IN NUMBER,
                                     p_vendor_type_lookup_code IN VARCHAR2,
                                     p_employee_id    IN NUMBER,
                                     x_valid          OUT NOCOPY BOOLEAN
                                     ) IS
  l_count          NUMBER := 0;

BEGIN

   x_valid    := TRUE;

   --open issue 1 with manoj regarding whether the vendor name
   --will even be denormalized into po_vendors

   -- Added following if condition for bug 6775797

   IF ((p_vendor_type_lookup_code  IS NOT NULL AND
       p_vendor_type_lookup_code <> 'EMPLOYEE')
       OR p_vendor_type_lookup_code IS NULL) THEN

     -- Bug 7596921-Start
     /*
     SELECT COUNT(*)
     INTO   l_count
     FROM   ap_suppliers
     WHERE  UPPER(vendor_name) = UPPER(p_vendor_name)
     AND    (p_vendor_id IS NULL OR vendor_id <> p_vendor_id);  --bug 5606948
     */

     BEGIN
       SELECT 1
       INTO   l_count
       FROM   ap_suppliers
       WHERE  UPPER(vendor_name) = UPPER(p_vendor_name)
       AND    (p_vendor_id IS NULL OR vendor_id <> p_vendor_id)
       AND    ROWNUM = 1;  --bug 5606948
     EXCEPTION WHEN NO_DATA_FOUND THEN
       l_count := 0;
     END;

   ELSE

     /*
     SELECT COUNT(*)
     INTO   l_count
     FROM   ap_suppliers
     WHERE  UPPER(vendor_name) = UPPER(p_vendor_name)
     AND    (p_vendor_id IS NULL OR vendor_id <> p_vendor_id)
     --bug 6939863 - changed <> to = for employee_id
     AND    (p_employee_id IS NULL OR employee_id = p_employee_id);
     */

     BEGIN
       SELECT 1
       INTO   l_count
       FROM   ap_suppliers
       WHERE  UPPER(vendor_name) = UPPER(p_vendor_name)
       AND    (p_vendor_id IS NULL OR vendor_id <> p_vendor_id)
       --bug 6939863 - changed <> to = for employee_id
       AND    (p_employee_id IS NULL OR employee_id = p_employee_id)
       AND    ROWNUM = 1;
     EXCEPTION
     WHEN NO_DATA_FOUND THEN
       l_count := 0;
     END;

     -- Bug 7596921-End

   END IF;

   IF l_count > 0 THEN
      x_valid    := FALSE;
      FND_MESSAGE.SET_NAME('SQLAP','AP_VEN_DUPLICATE_NAME');
      FND_MSG_PUB.ADD;
    END IF;

END Chk_Dup_Vendor_Name_update;

--
-- Check for duplicate vendor number
--
PROCEDURE Chk_Null_Vendor_Number(p_segment1     IN  VARCHAR2 default null,
                                x_valid         OUT NOCOPY BOOLEAN
                               ) IS

   l_ven_num_code    financials_system_parameters.user_defined_vendor_num_code%TYPE;

 BEGIN

   x_valid    := TRUE;
--sally
        SELECT supplier_numbering_method
        INTO   l_ven_num_code
        FROM   ap_product_setup;

        IF ((NVL(l_ven_num_code, 'MANUAL') = 'MANUAL') AND
            (p_segment1 is Null)) THEN
      		x_valid    := FALSE;
      		FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
      		FND_MESSAGE.SET_TOKEN('COLUMN_NAME','SEGMENT1');
		FND_MSG_PUB.ADD;
        ELSIF l_ven_num_code not in ('MANUAL','AUTOMATIC') then
      		x_valid    := FALSE;
      		FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
		FND_MESSAGE.SET_TOKEN('COLUMN_NAME','USER_DEFINED_VENDOR_NUM_CODE');
		FND_MSG_PUB.ADD;
	END IF;

 END Chk_Null_Vendor_Number;

-- Method to verify a taxpayer id is valid
-- Bug 5291571
-- Modified the registration number validation calls to LE Teams API.
--
function is_taxpayer_id_valid(
    p_taxpayer_id     IN VARCHAR2,
    p_country         IN VARCHAR2
)
RETURN VARCHAR2
IS
    l_ret_value VARCHAR2(1);
    l_outcome   VARCHAR2(1);
    l_out_msg   VARCHAR2(255);
    l_legislative_cat_code VARCHAR2(30);
    l_required_flag VARCHAR2(1);
    l_registration_code VARCHAR2(100);
    l_return_status VARCHAR2(50);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(1000);

BEGIN
    l_ret_value := 'Y';
    l_legislative_cat_code := 'INCOME_TAX';
    l_required_flag := 'Y';                        --7442513
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_country = 'US') THEN
        FV_AP_TIN_PKG.TIN_VALIDATE(p_taxpayer_id, l_outcome, l_out_msg);
    ELSIF (p_country = 'IT') THEN
        l_registration_code := 'FCIT';
        XLE_REGISTRATIONS_VAL_PVT.do_it_regnum_validations
        (l_legislative_cat_code,
         l_required_flag,
         l_registration_code,
         p_taxpayer_id,
         l_return_status,
         l_msg_data,
         l_msg_count);
    ELSIF (p_country = 'ES') THEN
        l_registration_code := 'NIF';
        XLE_REGISTRATIONS_VAL_PVT.do_es_regnum_validations
        (l_legislative_cat_code,
         l_required_flag,
         l_registration_code,
         p_taxpayer_id,
         l_return_status,
         l_msg_data,
         l_msg_count);
    ELSIF (p_country = 'PT') THEN
        l_registration_code := 'NIPC';
        XLE_REGISTRATIONS_VAL_PVT.do_pt_regnum_validations
        (l_legislative_cat_code,
         l_required_flag,
         l_registration_code,
         p_taxpayer_id,
         l_return_status,
         l_msg_data,
         l_msg_count);
    END IF;

    IF p_country = 'US' THEN
       IF (l_outcome = 'F') THEN
          FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
          FND_MESSAGE.SET_TOKEN('COLUMN_NAME','NUM_1099' );
          FND_MSG_PUB.ADD; --bug6050423
          l_ret_value := 'N';
       END IF;
    END IF;
    IF p_country IN ('IT','ES','PT') THEN
       IF l_return_status = FND_API.G_RET_STS_ERROR
       THEN
         FND_MESSAGE.SET_NAME('XLE', 'XLE_INVALID_REG_NUM_ERR');
         FND_MESSAGE.SET_TOKEN('REG_CODE', l_registration_code);
         FND_MESSAGE.SET_TOKEN('REG_NUM', p_taxpayer_id);
         FND_MSG_PUB.ADD;   --bug6050423
         l_ret_value := 'N'; --bug6050423
       END IF;
     END IF;

    return l_ret_value;

END is_taxpayer_id_valid;

 --
 -- Validate and generate Vendor Number.
 --

 PROCEDURE Check_valid_vendor_num(p_segment1                     IN VARCHAR2,
		                  x_valid                        OUT NOCOPY BOOLEAN
                                  ) IS

      l_ven_num_code   ap_product_setup.SUPPLIER_NUMBERING_METHOD%TYPE;

  BEGIN

	/*Open Issue 11 -- This select needs to be adjusted for MOAC*/
        SELECT nvl(supplier_numbering_method, 'MANUAL')
        INTO   l_ven_num_code
        FROM   ap_product_setup;

       IF ((l_ven_num_code = 'MANUAL') and (p_segment1 is NULL)) THEN

           x_valid    := FALSE;
           FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
           FND_MESSAGE.SET_TOKEN('COLUMN_NAME','SEGMENT1' );
	   FND_MSG_PUB.ADD;
       END IF;

  END Check_valid_vendor_num;

 --
 -- Check if the Match_Option value is valid
 --
 PROCEDURE Check_Valid_Match_Option(p_match_option   IN         VARCHAR2,
                                  x_valid            OUT NOCOPY BOOLEAN
                                  ) IS

 BEGIN
    x_valid    := TRUE;

	IF p_match_option not IN ('P','R') THEN
         x_valid    := FALSE;
         FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
         FND_MESSAGE.SET_TOKEN('COLUMN_NAME','MATCH_OPTION' );
	 FND_MSG_PUB.ADD;
        END IF;

 END Check_Valid_Match_Option;

 --
 -- Check if the allow_awt_flag is valid
 --
 PROCEDURE Chk_allow_awt_flag(p_allow_awt_flag         IN         VARCHAR2,
			    p_org_id		       IN NUMBER,
                            x_valid                    OUT NOCOPY BOOLEAN
                            ) IS
    l_asp_awt_flag      VARCHAR2(1);

 BEGIN
    x_valid    := TRUE;

       SELECT allow_awt_flag
       INTO l_asp_awt_flag
       FROM ap_system_parameters
       WHERE org_id = p_org_id;

       IF l_asp_awt_flag = 'N'
          AND p_allow_awt_flag = 'Y' THEN
         x_valid    := FALSE;
	 FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
         FND_MESSAGE.SET_TOKEN('COLUMN_NAME','ALLOW_AWT_FLAG' );
	 FND_MSG_PUB.ADD;
       END IF;

 END Chk_allow_awt_flag;

 --
 -- Check if the awt_group_id and name are in sync.
 --

 PROCEDURE Chk_awt_grp_id_name(p_awt_id          IN OUT NOCOPY NUMBER,
                              p_awt_name         IN         VARCHAR2,
                              p_allow_awt_flag   IN         VARCHAR2,
                              x_valid            OUT NOCOPY BOOLEAN
                           ) IS

    l_dummy_id            AP_AWT_GROUPS.group_id%TYPE;
    l_dummy_name          AP_AWT_GROUPS.name%TYPE;

  BEGIN
    x_valid    := TRUE;

   IF p_allow_awt_flag = 'N' THEN
     BEGIN
      If p_awt_id is NOT NULL then

         x_valid    := FALSE;
         FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMNS_INCONSISTENT');
         FND_MESSAGE.SET_TOKEN('ID','ALLOW_AWT_FLAG');
         FND_MESSAGE.SET_TOKEN('NAME','AWT_GROUP_ID');
         FND_MSG_PUB.ADD;
      Elsif p_awt_name is NOT NULL Then

         x_valid    := FALSE;
         FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMNS_INCONSISTENT');
         FND_MESSAGE.SET_TOKEN('ID','ALLOW_AWT_FLAG');
         FND_MESSAGE.SET_TOKEN('NAME','AWT_GROUP_NAME');
         FND_MSG_PUB.ADD;
      End If;

     END;

   ELSIF (p_allow_awt_flag = 'Y' and (p_awt_id is NOT NULL and p_awt_name is NULL)) THEN
     BEGIN

       SELECT name
       INTO   l_dummy_name
       FROM   AP_AWT_GROUPS
       WHERE  group_id = p_awt_id
       AND    sysdate < nvl(inactive_date, sysdate + 1);

     EXCEPTION
     -- Trap validation error
     WHEN NO_DATA_FOUND THEN
         x_valid    := FALSE;
         FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
         FND_MESSAGE.SET_TOKEN('COLUMN_NAME','AWT_GROUP_ID' );
	 FND_MSG_PUB.ADD;
     END;

   ELSIF (p_allow_awt_flag = 'Y' and (p_awt_id is NOT NULL and p_awt_name is NOT NULL)) THEN
     BEGIN

       SELECT group_id
       INTO   l_dummy_id
       FROM   AP_AWT_GROUPS
       WHERE  group_id = p_awt_id
       AND    name = p_awt_name
       AND    sysdate < nvl(inactive_date, sysdate + 1);

     EXCEPTION
     -- Trap validation error
     WHEN NO_DATA_FOUND THEN
         x_valid    := FALSE;
	 FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMNS_NOT_MATCHED');
         FND_MESSAGE.SET_TOKEN('ID','AWT_GROUP_ID');
         FND_MESSAGE.SET_TOKEN('NAME','AWT_GROUP_NAME');
    	 FND_MSG_PUB.ADD;
     END;

   ELSIF (p_allow_awt_flag = 'Y' and (p_awt_id is NULL and p_awt_name is NOT NULL)) THEN
      BEGIN

       SELECT group_id
       INTO   p_awt_id
       FROM   AP_AWT_GROUPS
       WHERE  name = p_awt_name
       AND    sysdate < nvl(inactive_date, sysdate + 1);

      EXCEPTION
      -- Trap validation error
      WHEN NO_DATA_FOUND THEN
         x_valid    := FALSE;
         FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
         FND_MESSAGE.SET_TOKEN('COLUMN_NAME','AWT_GROUP_NAME' );
      	 FND_MSG_PUB.ADD;
     END;

    END IF;

 END Chk_awt_grp_id_name;


/* Bug9589179 */
 --
 -- Check if the pay_awt_group_id and name are in sync.
 --

 PROCEDURE Chk_pay_awt_grp_id_name(p_pay_awt_id          IN OUT NOCOPY NUMBER,
                              p_pay_awt_name         IN         VARCHAR2,
                              p_allow_awt_flag   IN         VARCHAR2,
                              x_valid            OUT NOCOPY BOOLEAN
                           ) IS

    l_dummy_id            AP_AWT_GROUPS.group_id%TYPE;
    l_dummy_name          AP_AWT_GROUPS.name%TYPE;

  BEGIN


    x_valid    := TRUE;

   IF p_allow_awt_flag = 'N' THEN
     BEGIN
      If p_pay_awt_id is NOT NULL then

         x_valid    := FALSE;
         FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMNS_INCONSISTENT');
         FND_MESSAGE.SET_TOKEN('ID','ALLOW_AWT_FLAG');
         FND_MESSAGE.SET_TOKEN('NAME','AWT_GROUP_ID');
         FND_MSG_PUB.ADD;
      Elsif p_pay_awt_name is NOT NULL Then

         x_valid    := FALSE;
         FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMNS_INCONSISTENT');
         FND_MESSAGE.SET_TOKEN('ID','ALLOW_AWT_FLAG');
         FND_MESSAGE.SET_TOKEN('NAME','AWT_GROUP_NAME');
         FND_MSG_PUB.ADD;
      End If;

     END;

   ELSIF (p_allow_awt_flag = 'Y' and (p_pay_awt_id is NOT NULL and p_pay_awt_name is NULL)) THEN

     BEGIN

       SELECT name
       INTO   l_dummy_name
       FROM   AP_AWT_GROUPS
       WHERE  group_id = p_pay_awt_id
       AND    sysdate < nvl(inactive_date, sysdate + 1);

     EXCEPTION
     -- Trap validation error
     WHEN NO_DATA_FOUND THEN
         x_valid    := FALSE;
         FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
         FND_MESSAGE.SET_TOKEN('COLUMN_NAME','AWT_GROUP_ID' );
	 FND_MSG_PUB.ADD;
     END;

   ELSIF (p_allow_awt_flag = 'Y' and (p_pay_awt_id is NOT NULL and p_pay_awt_name is NOT NULL)) THEN
     BEGIN

       SELECT group_id
       INTO   l_dummy_id
       FROM   AP_AWT_GROUPS
       WHERE  group_id = p_pay_awt_id
       AND    name = p_pay_awt_name
       AND    sysdate < nvl(inactive_date, sysdate + 1);

     EXCEPTION
     -- Trap validation error
     WHEN NO_DATA_FOUND THEN
         x_valid    := FALSE;
	 FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMNS_NOT_MATCHED');
         FND_MESSAGE.SET_TOKEN('ID','AWT_GROUP_ID');
         FND_MESSAGE.SET_TOKEN('NAME','AWT_GROUP_NAME');
    	 FND_MSG_PUB.ADD;
     END;

   ELSIF (p_allow_awt_flag = 'Y' and (p_pay_awt_id is NULL and p_pay_awt_name is NOT NULL)) THEN
      BEGIN

       SELECT group_id
       INTO   p_pay_awt_id
       FROM   AP_AWT_GROUPS
       WHERE  name = p_pay_awt_name
       AND    sysdate < nvl(inactive_date, sysdate + 1);

      EXCEPTION
      -- Trap validation error
      WHEN NO_DATA_FOUND THEN
         x_valid    := FALSE;
         FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
         FND_MESSAGE.SET_TOKEN('COLUMN_NAME','AWT_GROUP_NAME' );
      	 FND_MSG_PUB.ADD;
     END;

    END IF;

 END Chk_pay_awt_grp_id_name; /*Bug 9589179 */
 --
 -- Check if the Hold_by is valid
 --
 PROCEDURE Check_Valid_Hold_by(p_hold_by      IN         NUMBER,
                              x_valid            OUT NOCOPY BOOLEAN
                              ) IS
    l_dummy          hr_employees_current_v.employee_id%TYPE;

 BEGIN
    x_valid    := TRUE;

       SELECT employee_id
       INTO   l_dummy
       FROM   hr_employees_current_v
       WHERE  employee_id = p_hold_by;


 EXCEPTION
    -- Trap validation error
    WHEN NO_DATA_FOUND THEN
         x_valid    := FALSE;

         FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
         FND_MESSAGE.SET_TOKEN('COLUMN_NAME','HOLD_BY' );
	 FND_MSG_PUB.ADD;
 END Check_Valid_Hold_by;

 --
 -- Check that terms_id and terms_name are in sync.
 --

 PROCEDURE Check_terms_id_code(p_terms_id         IN OUT NOCOPY NUMBER,
                              p_terms_name        IN            VARCHAR2,
                              p_default_terms_id  IN            NUMBER,
                              x_valid             OUT NOCOPY    BOOLEAN
                              ) IS

    l_terms_id       AP_TERMS_TL.term_id%TYPE;
    l_terms_name     AP_TERMS_TL.name%TYPE;

 BEGIN
    x_valid    := TRUE;

  IF (p_terms_id is NULL and p_terms_name is NULL) THEN
        p_terms_id := p_default_terms_id;

  ELSIF (p_terms_id is NOT NULL and p_terms_name is NULL) THEN
     BEGIN
        SELECT name
        INTO   l_terms_name
        FROM   AP_TERMS_TL
        WHERE  term_id = p_terms_id
        AND    language = userenv('LANG')
        AND    sysdate < nvl(end_date_active, sysdate+1);

    EXCEPTION
    -- Trap validation error
    WHEN NO_DATA_FOUND THEN
         x_valid    := FALSE;

         FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
         FND_MESSAGE.SET_TOKEN('COLUMN_NAME','TERMS_ID' );
         FND_MSG_PUB.ADD;
     END;

  ELSIF (p_terms_id is NOT NULL and p_terms_name is NOT NULL) THEN
    BEGIN
	SELECT term_id
        INTO   l_terms_id
        FROM   AP_TERMS_TL
        WHERE  term_id = p_terms_id
        AND    name = p_terms_name
        AND    language = userenv('LANG')
        AND    sysdate < nvl(end_date_active, sysdate+1);

    EXCEPTION
    -- Trap validation error
    WHEN NO_DATA_FOUND THEN
         x_valid    := FALSE;

         FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMNS_NOT_MATCHED');
         FND_MESSAGE.SET_TOKEN('ID','TERMS_ID');
         FND_MESSAGE.SET_TOKEN('NAME','TERMS_NAME');
	 FND_MSG_PUB.ADD;
     END;

    ELSIF (p_terms_id is NULL and p_terms_name is NOT NULL) THEN
    BEGIN
        SELECT term_id
        INTO   p_terms_id
        FROM   AP_TERMS_TL
        WHERE  name = p_terms_name
        AND    language = userenv('LANG')
        AND    sysdate < nvl(end_date_active, sysdate+1);

    EXCEPTION
    -- Trap validation error
    WHEN NO_DATA_FOUND THEN
         x_valid    := FALSE;

         FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
         FND_MESSAGE.SET_TOKEN('COLUMN_NAME','TERMS_NAME' );
	 FND_MSG_PUB.ADD;
      END;

    END IF;

 END Check_terms_id_code;

 --
 -- Check that dist_set_id and name are in sync.

 PROCEDURE Check_dist_set_id_name(p_dist_id            IN OUT NOCOPY  NUMBER,
   	                         p_dist_name           IN             VARCHAR2,
                                 p_default_dist_id     IN             NUMBER,
                                 x_valid               OUT NOCOPY     BOOLEAN
                                 ) IS

    l_dist_id      AP_DISTRIBUTION_SETS_ALL.distribution_set_id%TYPE;
    l_dist_name    AP_DISTRIBUTION_SETS_ALL.distribution_set_name%TYPE;

 BEGIN
    x_valid    := TRUE;

  IF (p_dist_id is NULL and p_dist_name is NULL) THEN

        p_dist_id := p_default_dist_id;

  ELSIF p_dist_id is NOT NULL and p_dist_name is NOT NULL THEN
      BEGIN
       SELECT distribution_set_id
       INTO   l_dist_id
       FROM   AP_DISTRIBUTION_SETS_ALL
       WHERE  distribution_set_id = p_dist_id
       AND    distribution_set_name  = p_dist_name
       AND    sysdate < nvl(inactive_date, sysdate+1);

    EXCEPTION
    -- Trap validation error
    WHEN NO_DATA_FOUND THEN
    x_valid    := FALSE;

         FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMNS_NOT_MATCHED');
         FND_MESSAGE.SET_TOKEN('ID','DISTRIBUTION_SET_ID');
         FND_MESSAGE.SET_TOKEN('NAME','DISTRIBUTION_SET_NAME');
         FND_MSG_PUB.ADD;
     END;

    ELSIF p_dist_id is NULL and p_dist_name is NOT NULL THEN
     BEGIN
       SELECT distribution_set_id
       INTO   p_dist_id
       FROM   AP_DISTRIBUTION_SETS_ALL
       WHERE  distribution_set_name  = p_dist_name
       AND    sysdate < nvl(inactive_date, sysdate+1);

    EXCEPTION
    -- Trap validation error
    WHEN NO_DATA_FOUND THEN
    x_valid    := FALSE;

         FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
         FND_MESSAGE.SET_TOKEN('COLUMN_NAME','DISTRIBUTION_SET_NAME' );
         FND_MSG_PUB.ADD;
      END;

    ELSIF p_dist_id is NOT NULL and p_dist_name is NULL THEN
     BEGIN
       SELECT distribution_set_name
       INTO   l_dist_name
       FROM   AP_DISTRIBUTION_SETS_ALL
       WHERE  distribution_set_id = p_dist_id
       AND    sysdate < nvl(inactive_date, sysdate+1);

    EXCEPTION
    -- Trap validation error
    WHEN NO_DATA_FOUND THEN
         x_valid    := FALSE;

         FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
         FND_MESSAGE.SET_TOKEN('COLUMN_NAME','DISTRIBUTION_SET_ID' );
         FND_MSG_PUB.ADD;
     END;

    END IF;

 END Check_dist_set_id_name;

 --
 -- Check that ship_to_location_id and ship_to_location_code are in sync.
 --

 PROCEDURE Check_ship_locn_id_code(p_ship_location_id     IN OUT NOCOPY NUMBER,
                              p_ship_location_code        IN          VARCHAR2,
			      p_default_ship_to_loc_id    IN          NUMBER,
                              x_valid            	  OUT NOCOPY  BOOLEAN
                              ) IS

    l_ship_locn_id       HR_LOCATIONS_ALL.ship_to_location_id%TYPE;
    l_ship_locn_code     HR_LOCATIONS_ALL.location_code%TYPE;

 BEGIN
    x_valid    := TRUE;

  IF (p_ship_location_id is NULL and p_ship_location_code is NULL) THEN

        p_ship_location_id := p_default_ship_to_loc_id;

  ELSIF (p_ship_location_id is NOT NULL and p_ship_location_code is NULL) THEN

     BEGIN
     SELECT lot.location_code
       INTO   l_ship_locn_code
       FROM   HR_LOCATIONS_ALL loc, HR_LOCATIONS_ALL_TL lot
       WHERE  loc.location_id = p_ship_location_id
       AND     sysdate < nvl(loc.inactive_date, sysdate + 1)
       AND     loc.location_id = lot.location_id
       AND     lot.language = userenv('LANG')
       AND     (nvl(loc.business_group_id,nvl(hr_general.get_business_group_id,-99))=
                nvl(hr_general.get_business_group_id,-99))
       AND     loc.ship_to_site_flag = 'Y';

    EXCEPTION
    -- Trap validation error
      WHEN NO_DATA_FOUND THEN
         x_valid    := FALSE;

         FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
         FND_MESSAGE.SET_TOKEN('COLUMN_NAME','SHIP_TO_LOCATION_ID' );
	 FND_MSG_PUB.ADD;
     END;

  ELSIF (p_ship_location_id is NOT NULL and p_ship_location_code is NOT NULL) THEN
    BEGIN
     SELECT loc.location_id
       INTO   l_ship_locn_id
       FROM   HR_LOCATIONS_ALL loc, HR_LOCATIONS_ALL_TL lot
       WHERE  lot.location_code = p_ship_location_code
       AND    loc.location_id = p_ship_location_id
       AND     sysdate < nvl(loc.inactive_date, sysdate + 1)
       AND     loc.location_id = lot.location_id
       AND     lot.language = userenv('LANG')
       AND     (nvl(loc.business_group_id,nvl(hr_general.get_business_group_id,-99))=
        	nvl(hr_general.get_business_group_id,-99))
       AND     loc.ship_to_site_flag = 'Y';

    EXCEPTION
    -- Trap validation error
    WHEN NO_DATA_FOUND THEN
         x_valid    := FALSE;

         FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMNS_NOT_MATCHED');
         FND_MESSAGE.SET_TOKEN('ID','SHIP_TO_LOCATION_ID');
         FND_MESSAGE.SET_TOKEN('NAME','SHIP_TO_LOCATION_CODE');
	 FND_MSG_PUB.ADD;
     END;

  ELSIF (p_ship_location_id is NULL and p_ship_location_code is NOT NULL) THEN
    BEGIN
     SELECT loc.location_id
       INTO   p_ship_location_id
       FROM   HR_LOCATIONS_ALL loc, HR_LOCATIONS_ALL_TL lot
       WHERE  lot.location_code = p_ship_location_code
       AND     sysdate < nvl(loc.inactive_date, sysdate + 1)
       AND     loc.location_id = lot.location_id
       AND     lot.language = userenv('LANG')
       AND     (nvl(loc.business_group_id,nvl(hr_general.get_business_group_id,-99))=
                nvl(hr_general.get_business_group_id,-99))
       AND     loc.ship_to_site_flag = 'Y';

    EXCEPTION
    -- Trap validation error
      WHEN NO_DATA_FOUND THEN
         x_valid    := FALSE;

         FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
         FND_MESSAGE.SET_TOKEN('COLUMN_NAME','SHIP_TO_LOCATION_CODE' );
	 FND_MSG_PUB.ADD;
      END;

  END IF;

 END Check_ship_locn_id_code;

 --
 -- Check that bill_to_location_id and bill_to_location_code are in sync.
 --

 PROCEDURE Check_bill_locn_id_code(p_bill_location_id     IN OUT NOCOPY NUMBER,
                              p_bill_location_code        IN         VARCHAR2,
                              p_default_bill_to_loc_id    IN         NUMBER,
                              x_valid                     OUT NOCOPY BOOLEAN
                             ) IS

    l_bill_locn_id       HR_LOCATIONS_ALL.location_id%TYPE;
    l_bill_locn_code     HR_LOCATIONS_ALL.location_code%TYPE;

 BEGIN
    x_valid    := TRUE;

  IF (p_bill_location_id is NULL and p_bill_location_code is NULL) THEN
  	p_bill_location_id := p_default_bill_to_loc_id;

  ELSIF (p_bill_location_id is NOT NULL and p_bill_location_code is NULL) THEN
     BEGIN
     SELECT lot.location_code
       INTO  l_bill_locn_code
       FROM   HR_LOCATIONS_ALL loc, HR_LOCATIONS_ALL_TL lot
       WHERE  loc.location_id = p_bill_location_id
       AND     sysdate < nvl(loc.inactive_date, sysdate + 1)
       AND     loc.location_id = lot.location_id
       AND     lot.language = userenv('LANG')
       AND     (nvl(loc.business_group_id,nvl(hr_general.get_business_group_id,-99))=
                nvl(hr_general.get_business_group_id,-99))
       AND     loc.bill_to_site_flag = 'Y';

   EXCEPTION
    -- Trap validation error
      WHEN NO_DATA_FOUND THEN
         x_valid    := FALSE;

         FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
         FND_MESSAGE.SET_TOKEN('COLUMN_NAME','BILL_TO_LOCATION_ID' );
	 FND_MSG_PUB.ADD;
     END;

  ELSIF p_bill_location_id is NOT NULL and p_bill_location_code is NOT NULL THEN

     BEGIN
       SELECT loc.location_id
       INTO   l_bill_locn_id
       FROM   HR_LOCATIONS_ALL loc, HR_LOCATIONS_ALL_TL lot
       WHERE  loc.location_id = p_bill_location_id
       AND    lot.location_code = p_bill_location_code
       AND     sysdate < nvl(loc.inactive_date, sysdate + 1)
       AND     loc.location_id = lot.location_id
       AND     lot.language = userenv('LANG')
       AND     (nvl(loc.business_group_id,nvl(hr_general.get_business_group_id,-99))=
                nvl(hr_general.get_business_group_id,-99))
       AND     loc.bill_to_site_flag = 'Y';

    EXCEPTION
    -- Trap validation error
    WHEN NO_DATA_FOUND THEN
         x_valid    := FALSE;

         FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMNS_NOT_MATCHED');
         FND_MESSAGE.SET_TOKEN('ID','BILL_TO_LOCATION_ID');
         FND_MESSAGE.SET_TOKEN('NAME','BILL_TO_LOCATION_CODE');
 	 FND_MSG_PUB.ADD;
     END;

  ELSIF p_bill_location_id is NULL and p_bill_location_code is NOT NULL THEN

     BEGIN
       SELECT loc.location_id
       INTO   p_bill_location_id
       FROM   HR_LOCATIONS_ALL loc, HR_LOCATIONS_ALL_TL lot
       WHERE  lot.location_code = p_bill_location_code
       AND     sysdate < nvl(loc.inactive_date, sysdate + 1)
       AND     loc.location_id = lot.location_id
       AND     lot.language = userenv('LANG')
       AND     (nvl(loc.business_group_id,nvl(hr_general.get_business_group_id,-99))=
                nvl(hr_general.get_business_group_id,-99))
       AND     loc.bill_to_site_flag = 'Y';

    EXCEPTION
    -- Trap validation error
      WHEN NO_DATA_FOUND THEN
         x_valid    := FALSE;

         FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
         FND_MESSAGE.SET_TOKEN('COLUMN_NAME','BILL_TO_LOCATION_CODE' );
	 FND_MSG_PUB.ADD;
      END;

  END IF;

 END Check_bill_locn_id_code;

 --
 -- Check if the Default_pay_site_id is valid
 --
 PROCEDURE Check_Default_pay_site(p_default_pay_site_id    IN         NUMBER,
                                  p_vendor_id              IN         NUMBER,
                                  p_org_id                 IN         NUMBER,
                                  x_valid                  OUT NOCOPY BOOLEAN
                                  ) IS
    l_dummy          po_vendor_sites_all.vendor_site_id%TYPE;

 BEGIN
    x_valid    := TRUE;

       SELECT vendor_site_id
       INTO   l_dummy
       FROM  po_vendor_sites_all
       WHERE  vendor_id = p_vendor_id
       AND  vendor_site_id = p_default_pay_site_id
       AND  org_id  = p_org_id
       AND  nvl(inactive_date, sysdate +1 ) > sysdate
       AND  pay_site_flag = 'Y';


     EXCEPTION
    -- Trap validation error
    WHEN NO_DATA_FOUND THEN
         x_valid    := FALSE;

         FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
         FND_MESSAGE.SET_TOKEN('COLUMN_NAME','DEFAULT_PAY_SITE_ID' );
	 FND_MSG_PUB.ADD;
 END Check_Default_pay_site;

   --
   -- This procedure should ensure the value for 'state' exists on the
   -- target database.
   --
   PROCEDURE state_valid(p_state    IN         VARCHAR2,
                         p_valid    OUT NOCOPY BOOLEAN
                        ) IS
      l_count     NUMBER := 0;

   BEGIN
      p_valid := TRUE;

      SELECT count(*)
      INTO   l_count
      FROM   ap_income_tax_regions
      WHERE  region_short_name = p_state
      AND    sysdate < nvl(inactive_date,sysdate+1);

      IF (l_count = 0) THEN
	 FND_MESSAGE.SET_NAME('SQLAP','AP_API_INVALID_STATE');
	 FND_MSG_PUB.ADD;
         p_valid := FALSE;
      END IF;

   END state_valid;

--
-- Check that Org_Id and Operating Unit name are in sync
-- Modified for 11i Import functionality

 PROCEDURE Check_org_id_name(p_org_id          IN OUT NOCOPY NUMBER,
                             p_org_name        IN VARCHAR2,
                             p_int_table       IN VARCHAR2,
                             p_int_key         IN NUMBER,
                             x_valid           OUT NOCOPY    BOOLEAN
                              ) IS

    l_org_id       HR_OPERATING_UNITS.organization_id%TYPE;
    l_org_name     HR_OPERATING_UNITS.name%TYPE;
    l_api_name                  CONSTANT VARCHAR2(30)   := 'Check_Org_Id_Name';
 BEGIN
    x_valid    := TRUE;

    IF (p_org_id is NOT NULL and p_org_name is NOT NULL) THEN
    BEGIN
     SELECT organization_id
       INTO   l_org_id
       FROM   HR_OPERATING_UNITS
       WHERE  organization_id = p_org_id
       AND    name = p_org_name
       AND    sysdate < nvl(date_to, sysdate + 1);

     EXCEPTION
     -- Trap validation error
     WHEN NO_DATA_FOUND THEN
       x_valid    := FALSE;
       IF g_source = 'IMPORT' THEN
         IF (Insert_Rejections(
           p_int_table,
           p_int_key,
           'AP_INCONSISTENT_ORG_INFO',
           g_user_id,
           g_login_id,
           'Check_Org_Id_Name') <> TRUE) THEN
          --
           IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'Parameters: '
                     ||' P_Org_Id: '|| p_org_id
                     ||', P_Org_Name: '||p_org_name
                     ||', P_Int_Table: '||p_int_table
                     ||', P_Int_Key: '||p_int_key);
           END IF;
         END IF;
       ELSE
            -- Bug 5491139 hkaniven start --
         FND_MESSAGE.SET_NAME('SQLAP','AP_INCONSISTENT_ORG_INFO');
         FND_MSG_PUB.ADD;
            -- Bug 5491139 hkaniven end --
       END IF;
     END;

   ELSIF (p_org_id is NULL and p_org_name is NOT NULL) THEN

     BEGIN
       SELECT organization_id
       INTO   p_org_id
       FROM   HR_OPERATING_UNITS
       WHERE  name = p_org_name
       AND    sysdate < nvl(date_to, sysdate + 1);

     EXCEPTION
     -- Trap validation error
     WHEN NO_DATA_FOUND THEN
       x_valid    := FALSE;
       IF g_source = 'IMPORT' THEN
         IF (Insert_Rejections(
           p_int_table,
           p_int_key,
           'AP_INVALID_ORG_INFO',
           g_user_id,
           g_login_id,
           'Check_Org_Id_Name') <> TRUE) THEN
          --
           IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'Parameters: '
                     ||' P_Org_Id: '|| p_org_id
                     ||', P_Org_Name: '||p_org_name
                     ||', P_Int_Table: '||p_int_table
                     ||', P_Int_Key: '||p_int_key);
           END IF;
         END IF;
       ELSE
            -- Bug 5491139 hkaniven start --
         FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_ORG_INFO');
         FND_MSG_PUB.ADD;
            -- Bug 5491139 hkaniven end --
       END IF;
     END;

    ELSIF (p_org_id is NOT NULL and p_org_name is NULL) THEN

     BEGIN
       SELECT name
       INTO  l_org_name
       FROM  HR_OPERATING_UNITS
       WHERE  organization_id = p_org_id
       AND    sysdate < nvl(date_to, sysdate + 1);

     EXCEPTION
     -- Trap validation error
     WHEN NO_DATA_FOUND THEN
       x_valid    := FALSE;
       IF g_source = 'IMPORT' THEN
         IF (Insert_Rejections(
           p_int_table,
           p_int_key,
           'AP_INVALID_ORG_INFO',
           g_user_id,
           g_login_id,
           'Check_Org_Id_Name') <> TRUE) THEN
          --
           IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'Parameters: '
                     ||' P_Org_Id: '|| p_org_id
                     ||', P_Org_Name: '||p_org_name
                     ||', P_Int_Table: '||p_int_table
                     ||', P_Int_Key: '||p_int_key);
           END IF;
         END IF;
       ELSE
            -- Bug 5491139 hkaniven start --
        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_ORG_INFO');
        FND_MSG_PUB.ADD;
            -- Bug 5491139 hkaniven end --
       END IF;
     END;
   END IF;

 END Check_org_id_name;

 PROCEDURE Check_pay_on_rec_sum_code(p_pay_on_code            IN      VARCHAR2,
                                p_pay_on_receipt_summary_code IN OUT NOCOPY VARCHAR2,
                                x_valid                       OUT NOCOPY BOOLEAN
                                ) IS

     e_apps_exception    EXCEPTION;

 BEGIN
    x_valid    := TRUE;

   IF ((p_pay_on_receipt_summary_code is NULL) or(p_pay_on_receipt_summary_code=fnd_api.g_null_char )) THEN --Bug8512030
      p_pay_on_receipt_summary_code := 'PAY_SITE';

   ELSIF p_pay_on_receipt_summary_code is NOT NULL THEN

     IF ((p_pay_on_code = 'RECEIPT') AND (p_pay_on_receipt_summary_code not IN
                                       ('PACKING_SLIP','PAY_SITE','RECEIPT'))) THEN

         Raise e_apps_exception;

     ELSIF ((p_pay_on_code = 'USE') AND (p_pay_on_receipt_summary_code not IN
                                      ('CONSUMPTION_ADVICE','PAY_SITE')))  THEN

         Raise e_apps_exception;

     ELSIF ((p_pay_on_code = 'RECEIPT_AND_USE') AND (p_pay_on_receipt_summary_code not IN
                                                  ('PAY_SITE'))) THEN

         Raise e_apps_exception;

     END IF;

   END IF;

     EXCEPTION
        WHEN e_apps_exception THEN
         x_valid    := FALSE;
         FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMNS_INCONSISTENT');
         FND_MESSAGE.SET_TOKEN('ID','PAY_ON_CODE');
         FND_MESSAGE.SET_TOKEN('NAME','PAY_ON_RECEIPT_SUMMARY_CODE');
	 FND_MSG_PUB.ADD;
 END Check_pay_on_rec_sum_code;

 --
 -- Check if the Shipping_Control value is valid
 --

 PROCEDURE Check_Shipping_Control(p_shipping_control    IN  VARCHAR2,
                              x_valid            OUT NOCOPY BOOLEAN
                              ) IS

 BEGIN
    x_valid    := TRUE;

     IF upper(p_shipping_control) NOT IN ('SUPPLIER','BUYER') THEN

	x_valid    := FALSE;

        FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
        FND_MESSAGE.SET_TOKEN('COLUMN_NAME','SHIPPING_CONTROL' );
	FND_MSG_PUB.ADD;
     END IF;

 END Check_Shipping_Control;

 --
 -- Check the pay_on_code values
 --
 PROCEDURE Check_Valid_pay_on_code(p_pay_on_code            IN  VARCHAR2,
                                p_purchasing_site_flag      IN  VARCHAR2 DEFAULT NULL,
                                p_pay_site_flag             IN  VARCHAR2,
                                p_default_pay_site_id       IN  NUMBER DEFAULT NULL,
                                x_valid                     OUT NOCOPY BOOLEAN
                              ) IS

     l_dummy                VARCHAR2(1);
     l_default_pay_site_id  NUMBER;

 BEGIN
    x_valid    := TRUE;
    -- Bug #7197985 Checking the default pay site id
    IF(p_default_pay_site_id IS NULL OR p_default_pay_site_id = ap_null_num) THEN
       l_default_pay_site_id := NULL;
    ELSE
       l_default_pay_site_id := p_default_pay_site_id;
    END IF;


   IF (nvl(p_purchasing_site_flag,'N') = 'N') THEN
        x_valid    := FALSE;
         FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMNS_INCONSISTENT');
         FND_MESSAGE.SET_TOKEN('ID','PAY_ON_CODE');
         FND_MESSAGE.SET_TOKEN('NAME','PURCHASING_SITE_FLAG');
 	 FND_MSG_PUB.ADD;
   ELSIF (nvl(p_purchasing_site_flag,'N') = 'Y') THEN

         If p_pay_on_code IN ('RECEIPT','USE','RECEIPT_AND_USE') Then
            l_dummy := 'Y';
         Else l_dummy := 'N';
         End If;

         IF l_dummy = 'N' THEN
		x_valid    := FALSE;
         	FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
         	FND_MESSAGE.SET_TOKEN('COLUMN_NAME','PAY_ON_CODE' );
 		FND_MSG_PUB.ADD;
         ELSIF (p_pay_site_flag = 'N' and l_default_pay_site_id IS NULL) THEN
		x_valid    := FALSE;
         	FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMNS_INCONSISTENT');
         	FND_MESSAGE.SET_TOKEN('ID','PAY_ON_CODE');
         	FND_MESSAGE.SET_TOKEN('NAME','PAY_SITE_FLAG');
 		FND_MSG_PUB.ADD;
         END IF;

   END IF;

 END Check_Valid_pay_on_Code;

   --
   -- This procedure should ensure the value for 'pay_on_receipt_summary_code'
   -- exists on the target database
   --
   PROCEDURE pay_on_receipt_summary_valid( p_pay_on_receipt_summary_code IN         VARCHAR2,
                                           p_pay_on_code                 IN         VARCHAR2,
                                           p_valid                       OUT NOCOPY BOOLEAN
                                          ) IS
      l_count     NUMBER := 0;

   BEGIN
      p_valid := TRUE;

      SELECT count(*)
      INTO   l_count
      FROM   po_lookup_codes
      WHERE  lookup_code = p_pay_on_receipt_summary_code
      AND    lookup_type = 'ERS INVOICE_SUMMARY_CONSIGNED' -- bug 8429005 'ERS INVOICE_SUMMARY'
      AND    sysdate < nvl(inactive_date,sysdate+1)
      AND    (lookup_code = 'PAY_SITE'
              OR (p_pay_on_code = 'USE' AND lookup_code = 'CONSUMPTION_ADVICE')
              OR (p_pay_on_code = 'RECEIPT' and lookup_code IN ('RECEIPT','PACKING_SLIP'))
             );

      IF (l_count = 0) THEN
	 FND_MESSAGE.SET_NAME('SQLAP','AP_API_INVALID_RECPT_SUMM');
	 FND_MSG_PUB.ADD;
         p_valid := FALSE;
      END IF;

   END pay_on_receipt_summary_valid;

 --
 -- Check for matching address
 --

 PROCEDURE Check_Valid_Location(p_party_site_id    IN OUT NOCOPY  VARCHAR2,
                                p_address_line1     IN    VARCHAR2,
                                p_address_line2     IN    VARCHAR2,
                                p_address_line3     IN    VARCHAR2,
                                p_address_line4     IN    VARCHAR2,
                                p_city              IN    VARCHAR2,
                                p_state             IN    VARCHAR2,
                                p_zip               IN    VARCHAR2,
                                p_province          IN    VARCHAR2,
				p_country	    IN	  VARCHAR2,
				p_county	    IN	  VARCHAR2,
				p_language	    IN	  VARCHAR2,
				p_address_style	    IN 	  VARCHAR2,
				p_vendor_id	    IN 	  NUMBER,
				x_location_id	    OUT NOCOPY NUMBER,
                                x_valid             OUT NOCOPY BOOLEAN,
                                x_loc_count         OUT NOCOPY NUMBER -- Bug 7429668
                                      ) IS

	l_dummy		NUMBER;
	l_sync_count	NUMBER;

 BEGIN
    x_valid    := TRUE;
    x_loc_count := 0; -- Bug 7429668

    --Open Issue 2 should they match if they are null?
    IF p_party_site_id IS NOT NULL THEN
    	SELECT hl.location_id
    	INTO x_location_id
    	FROM HZ_Locations hl, HZ_Party_Sites hps,
             fnd_languages fl
    	WHERE hl.language = fl.language_code(+) AND
        nvl(upper(hl.country), 'dummy') =
		nvl(upper(p_country), 'dummy') AND
	nvl(upper(hl.address1), 'dummy') =
		nvl(upper(p_address_line1), 'dummy') AND
	nvl(upper(hl.address2), 'dummy') =
		nvl(upper(p_address_line2), 'dummy') AND
	nvl(upper(hl.address3), 'dummy') =
		nvl(upper(p_address_line3), 'dummy') AND
	nvl(upper(hl.address4), 'dummy') =
		nvl(upper(p_address_line4), 'dummy') AND
	nvl(upper(hl.city), 'dummy') = nvl(upper(p_city), 'dummy') AND
	nvl(upper(hl.state), 'dummy') = nvl(upper(p_state), 'dummy') AND
	nvl(upper(hl.postal_code), 'dummy') = nvl(upper(p_zip), 'dummy') AND
	nvl(upper(hl.province), 'dummy') =
		 nvl(upper(p_province), 'dummy') AND
	nvl(upper(hl.county), 'dummy') = nvl(upper(p_county), 'dummy') AND
	nvl(upper(fl.nls_language), 'dummy') =
		nvl(upper(p_language), 'dummy') AND
	nvl(upper(hl.address_style), 'dummy') =
		nvl(upper(p_address_style), 'dummy') AND
   	hl.location_id = hps.location_id AND
     	hps.party_site_id = p_party_site_id ;
    ELSE

	SELECT hl.location_id, hps.party_site_id
        INTO x_location_id, p_party_site_id
        FROM HZ_Locations hl,
             HZ_Party_Sites hps,
             po_vendors pv,
             fnd_languages fl
        WHERE nvl(upper(hl.country), 'dummy') =
                nvl(upper(p_country), 'dummy') AND
        nvl(upper(hl.address1), 'dummy') =
                nvl(upper(p_address_line1), 'dummy') AND
        nvl(upper(hl.address2), 'dummy') =
                nvl(upper(p_address_line2), 'dummy') AND
        nvl(upper(hl.address3), 'dummy') =
                nvl(upper(p_address_line3), 'dummy') AND
        nvl(upper(hl.address4), 'dummy') =
                nvl(upper(p_address_line4), 'dummy') AND
        nvl(upper(hl.city), 'dummy') = nvl(upper(p_city), 'dummy') AND
        nvl(upper(hl.state), 'dummy') = nvl(upper(p_state), 'dummy') AND
        nvl(upper(hl.postal_code), 'dummy') = nvl(upper(p_zip), 'dummy') AND
        nvl(upper(hl.province), 'dummy') =
                 nvl(upper(p_province), 'dummy') AND
        nvl(upper(hl.county), 'dummy') = nvl(upper(p_county), 'dummy') AND
        nvl(upper(fl.nls_language), 'dummy') =
                nvl(upper(p_language), 'dummy') AND
        nvl(upper(hl.address_style), 'dummy') =
                nvl(upper(p_address_style), 'dummy') AND
        hl.location_id = hps.location_id AND
        hps.party_id = pv.party_id  AND
	pv.vendor_id = p_vendor_id AND
        hl.language = fl.language_code(+);
    END IF;

    IF x_location_id IS NULL THEN
	x_valid := FALSE;
    END IF;

    EXCEPTION
    -- Trap validation error
      WHEN NO_DATA_FOUND THEN
         x_valid    := FALSE;
      -- Bug 7429668 Trap validation error when more than 1 row is found
      WHEN OTHERS THEN
	    x_valid    := FALSE;
	    x_loc_count := 2;
 END Check_Valid_Location;

 --
 -- Take care of CCID etc. defaulting from Parameters for SITE Import
 --
 PROCEDURE Default_CCIDs_for_Site(p_org_id              IN NUMBER DEFAULT NULL,
				  p_org_name            IN VARCHAR2 DEFAULT NULL,
                                  p_multi_org_flag      IN            VARCHAR2,
                                  p_accts_pay_ccid      IN OUT NOCOPY NUMBER,
                                  p_prepay_ccid         IN OUT NOCOPY NUMBER,
                                  p_future_pay_ccid     IN OUT NOCOPY NUMBER,
                                  p_rfq_site_flag       IN OUT NOCOPY VARCHAR2 ,
				  p_country_code	IN OUT NOCOPY VARCHAR2,
				  p_ship_via_lookup_code IN OUT NOCOPY VARCHAR2
                                  ) IS

        l_rfq_only_site    FINANCIALS_SYSTEM_PARAMS_ALL.rfq_only_site_flag%TYPE;
        l_accts_pay_ccid   FINANCIALS_SYSTEM_PARAMS_ALL.accts_pay_code_combination_id%TYPE;
        l_prepay_ccid      FINANCIALS_SYSTEM_PARAMS_ALL.prepay_code_combination_id%TYPE;
        l_future_pay_ccid  FINANCIALS_SYSTEM_PARAMS_ALL.future_dated_payment_ccid%TYPE;
	l_home_country_code  FINANCIALS_SYSTEM_PARAMS_ALL.vat_country_code%TYPE;
	l_default_country_code  FINANCIALS_SYSTEM_PARAMS_ALL.vat_country_code%TYPE;

 BEGIN

       	SELECT FIN.rfq_only_site_flag,
              FIN.accts_pay_code_combination_id,
              FIN.prepay_code_combination_id,
              FIN.future_dated_payment_ccid,
	      fin.vat_country_code,
	      fin.ship_via_lookup_code
       	INTO  l_rfq_only_site,
             l_accts_pay_ccid,
             l_prepay_ccid,
             l_future_pay_ccid,
	     l_home_country_code,
	     p_ship_via_lookup_code
       	FROM  FINANCIALS_SYSTEM_PARAMS_ALL FIN,
             HR_OPERATING_UNITS HR
      	WHERE HR.organization_id = FIN.org_id
       	AND  ( HR.name = p_org_name  OR
             HR.organization_id = p_org_id);

   	fnd_profile.get('DEFAULT_COUNTRY',l_default_country_code);
   	--
   	--
   	if  ( l_default_country_code is null ) then
         	p_country_code := l_home_country_code;
  	end if;

       IF p_multi_org_flag = 'Y' THEN

	  IF p_accts_pay_ccid is NULL THEN
             p_accts_pay_ccid := l_accts_pay_ccid;
          END IF;

          IF p_prepay_ccid is NULL THEN
              p_prepay_ccid := l_prepay_ccid;
          END IF;

          IF p_future_pay_ccid is NULL THEN
             p_future_pay_ccid := l_future_pay_ccid;
          END IF;

          IF p_rfq_site_flag is NULL THEN
             p_rfq_site_flag := l_rfq_only_site;
          END IF;

      END IF;

 END Default_CCIDs_for_Site;

 --
 -- Do some validation checks in Apps and in Interface table
 --

 PROCEDURE Validate_unique_per_vendor(
        p_column_name      IN          VARCHAR2,
        p_vendor_id        IN          NUMBER,
        p_vendor_site_id   IN NUMBER DEFAULT NULL,
        p_org_id           IN NUMBER DEFAULT NULL,
        p_org_name         IN VARCHAR2 DEFAULT NULL,
        x_valid            OUT NOCOPY  BOOLEAN
        )
        IS

    l_dummy_1       	NUMBER;
    l_dummy_2           NUMBER;

 BEGIN
   x_valid    := TRUE;

   IF p_column_name = 'PRIMARY_PAY_SITE_FLAG' THEN

        Begin

               SELECT nvl(count(primary_pay_site_flag),0)
               INTO  l_dummy_1
               FROM  ap_vendor_sites_v
               WHERE nvl(primary_pay_site_flag,'N') = 'Y'
               AND   vendor_id = p_vendor_id
               AND   nvl(inactive_date, sysdate + 1) > sysdate
               AND   nvl(vendor_site_id, -99) <> nvl(p_vendor_site_id, -99);

		SELECT count(*)
                INTO l_dummy_2
                FROM AP_SUPPLIER_SITES_INT
                WHERE vendor_id = p_vendor_id
                AND nvl(inactive_date ,sysdate+1) > sysdate
                AND primary_pay_site_flag = 'Y'
                AND (org_id = p_org_id OR
                     operating_unit_name = p_org_name);

	 IF (l_dummy_1 > 0 or l_dummy_2 > 1) THEN
           x_valid    := FALSE;
           FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
           FND_MESSAGE.SET_TOKEN('COLUMN_NAME', p_column_name );
	   FND_MSG_PUB.ADD;
	END IF;

	End;
   ELSIF p_column_name = 'TAX_REPORTING_SITE_FLAG' THEN

	       SELECT nvl(count(tax_reporting_site_flag),0)
               INTO  l_dummy_1
               FROM  ap_vendor_sites_v
               WHERE nvl(tax_reporting_site_flag,'N') = 'Y'
               AND   vendor_id = p_vendor_id
               AND   nvl(inactive_date, sysdate + 1) > sysdate
               AND   nvl(vendor_site_id, -99) <> nvl(p_vendor_site_id, -99);

                SELECT count(*)
                INTO l_dummy_2
                FROM AP_SUPPLIER_SITES_INT
                WHERE vendor_id = p_vendor_id
                AND nvl(inactive_date ,sysdate+1) > sysdate
                AND tax_reporting_site_flag = 'Y'
                AND (org_id = p_org_id OR
                     operating_unit_name = p_org_name);

         IF (l_dummy_1 > 0 or l_dummy_2 > 1) THEN
           x_valid    := FALSE;
           FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
           FND_MESSAGE.SET_TOKEN('COLUMN_NAME', p_column_name );
 	   FND_MSG_PUB.ADD;
        END IF;

   END IF;

  END Validate_unique_per_vendor;

   --
   -- This procedure should ensure the value for 'country_of_origin_code' exists
   -- on the target database
   --
   PROCEDURE country_of_origin_valid(p_country_of_origin_code IN         VARCHAR2,
                                     p_valid           OUT NOCOPY BOOLEAN
                                    ) IS
      l_count     NUMBER := 0;

   BEGIN
      p_valid := TRUE;

      SELECT count(*)
      INTO   l_count
      FROM   fnd_territories_vl
      WHERE  territory_code = p_country_of_origin_code;

      IF (l_count = 0) THEN
	 FND_MESSAGE.SET_NAME('SQLAP','AP_API_INVALID_COUNTRY_OF_ORIG');
	 FND_MSG_PUB.ADD;

         p_valid := FALSE;
      END IF;

   END country_of_origin_valid;

-- Bug 5100831
-- Added the validations related the Gapless Invoice Numbering Feature.
-- Validations Performed are:
-- 1) If Gapless Invoice Number is Y then Selling Company Identifier should
--    be populated.

   PROCEDURE Check_Gapless_Inv_Num
                (p_gapless_inv_num_flag       IN         VARCHAR2,
                 p_selling_company_identifier IN         VARCHAR2,
		 p_vendor_id	  IN NUMBER, --Bug5260465
                 p_valid                      OUT NOCOPY BOOLEAN
                                    ) IS
   l_column_name VARCHAR2(30);
   l_vendor_count   NUMBER := 0; --Bug5260465


   BEGIN

      p_valid := TRUE;
      l_column_name := 'SELLING_COMPANY_IDENTIFIER';
      IF nvl(p_gapless_inv_num_flag,'N') = 'Y' THEN
         IF (p_selling_company_identifier IS NULL OR
            p_selling_company_identifier = ap_null_char) THEN
            FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
            FND_MESSAGE.SET_TOKEN('COLUMN_NAME', l_column_name);
            FND_MSG_PUB.ADD;
            p_valid := FALSE;
         END IF;
      END IF;

	--Bug5260465 starts Adding validation if Selling company identifier is unique for supplier
      IF p_selling_company_identifier is not null THEN

	   SELECT COUNT(vendor_id)
	   INTO l_vendor_count
	   FROM po_vendor_sites_all
	   WHERE selling_company_identifier = p_selling_company_identifier
	   AND vendor_id <> p_vendor_id;

	   IF l_vendor_count > 0 THEN
	    FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
            FND_MESSAGE.SET_TOKEN('COLUMN_NAME', l_column_name);
            FND_MSG_PUB.ADD;
            p_valid := FALSE;
	   END IF;

	END IF;
	--Bud5260465 ends
   END Check_Gapless_Inv_Num;

 --
 -- Check if the Supplier_Notif_Method is valid
 --
 PROCEDURE Check_Valid_Sup_Notif_Method(p_sup_notif_method      IN         VARCHAR2,
                              x_valid            		OUT NOCOPY BOOLEAN
                              ) IS

 BEGIN
    x_valid    := TRUE;

	IF p_sup_notif_method NOT IN ('EMAIL','PRINT','FAX') THEN

         x_valid    := FALSE;

         FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
         FND_MESSAGE.SET_TOKEN('COLUMN_NAME','SUPPLIER_NOTIF_METHOD' );
	 FND_MSG_PUB.ADD;
	END IF;

 END Check_Valid_Sup_Notif_Method;

 -- Bug 8422781 ...
 --
 -- Check if the Remit_Advice_Delivery_Method is valid
 --
 PROCEDURE Check_Valid_Remit_Adv_Del_Mthd(p_remit_advice_delivery_method  IN  VARCHAR2,
                              x_valid            		OUT NOCOPY BOOLEAN
                              ) IS

 BEGIN
    x_valid    := TRUE;

	--IF p_remit_advice_delivery_method NOT IN ('EMAIL','PRINT','FAX') THEN  ..B 8561342
	IF p_remit_advice_delivery_method NOT IN ('EMAIL','PRINTED','FAX') THEN  --B 8561342

         x_valid    := FALSE;

         FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
         FND_MESSAGE.SET_TOKEN('COLUMN_NAME','REMIT_ADVICE_DELIVERY_METHOD' );
	 FND_MSG_PUB.ADD;
	END IF;

 END Check_Valid_Remit_Adv_Del_Mthd ;
 -- end Bug 8422781

 --
 -- Validate and default Tolerance_Id and Tolerance_Name.
 --

 PROCEDURE Check_tolerance_id_code(p_tolerance_id         IN OUT NOCOPY NUMBER,
                              p_tolerance_name            IN            VARCHAR2,
                              p_org_id                    IN      NUMBER DEFAULT NULL,
                              p_org_name                  IN      VARCHAR2 DEFAULT NULL,
                              x_valid                     OUT NOCOPY    BOOLEAN,
                              p_tolerance_type            IN  VARCHAR2
                              ) IS

    l_tolerance_id       AP_TOLERANCE_TEMPLATES.tolerance_id%TYPE;
    l_tolerance_name     AP_TOLERANCE_TEMPLATES.tolerance_name%TYPE;
    l_default_tolerance  AP_TOLERANCE_TEMPLATES.tolerance_id%TYPE;

 BEGIN
    x_valid    := TRUE;

    IF (p_org_id is NULL and p_org_name is NULL)  THEN

       --bug6335105
       IF p_tolerance_type = 'QUANTITY' then

          SELECT tolerance_id
          INTO l_default_tolerance
          FROM ap_system_parameters;

       ELSE

         SELECT services_tolerance_id
         INTO   l_default_tolerance
         FROM ap_system_parameters;

       END IF;

   ELSE

       --bug6335105
       IF p_tolerance_type = 'QUANTITY' then

          SELECT ASP.tolerance_id
          INTO l_default_tolerance
          FROM ap_system_parameters_all ASP, HR_OPERATING_UNITS ORG
          WHERE ASP.org_id = ORG.organization_id
          AND   (ORG.organization_id = p_org_id OR
                 ORG.name = p_org_name);

       ELSE

         SELECT ASP.services_tolerance_id
         INTO l_default_tolerance
         FROM ap_system_parameters_all ASP, HR_OPERATING_UNITS ORG
         WHERE ASP.org_id = ORG.organization_id
         AND   (ORG.organization_id = p_org_id OR
                ORG.name = p_org_name);

      END IF;

   END IF;


  IF (p_tolerance_id is NULL and p_tolerance_name is NULL) THEN

        p_tolerance_id := l_default_tolerance;

    ELSIF (p_tolerance_id is NOT NULL and p_tolerance_name is NULL) THEN
     BEGIN
        SELECT tolerance_name
        INTO   l_tolerance_name
        FROM   AP_TOLERANCE_TEMPLATES
        WHERE  tolerance_id = p_tolerance_id;

    EXCEPTION
    -- Trap validation error
    WHEN NO_DATA_FOUND THEN
         x_valid    := FALSE;

         IF p_tolerance_type = 'QUANTITY' THEN
            FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
            FND_MESSAGE.SET_TOKEN('COLUMN_NAME','TOLERANCE_ID' );
	    FND_MSG_PUB.ADD;
         ELSE
            FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
            FND_MESSAGE.SET_TOKEN('COLUMN_NAME','SERVICES_TOLERANCE_ID' );
            FND_MSG_PUB.ADD;
         END IF;
     END;

  ELSIF (p_tolerance_id is NOT NULL and p_tolerance_name is NOT NULL) THEN
    BEGIN
        SELECT tolerance_id
        INTO   l_tolerance_id
        FROM   AP_TOLERANCE_TEMPLATES
        WHERE  tolerance_id = p_tolerance_id
        AND    tolerance_name = p_tolerance_name;

    EXCEPTION
    -- Trap validation error
    WHEN NO_DATA_FOUND THEN
         x_valid    := FALSE;

         IF p_tolerance_type = 'QUANTITY' THEN
            FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMNS_NOT_MATCHED');
            FND_MESSAGE.SET_TOKEN('ID','TOLERANCE_ID');
            FND_MESSAGE.SET_TOKEN('NAME','TOLERANCE_NAME');
	    FND_MSG_PUB.ADD;
         ELSE
            FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMNS_NOT_MATCHED');
            FND_MESSAGE.SET_TOKEN('ID','SERVICES_TOLERANCE_ID');
            FND_MESSAGE.SET_TOKEN('NAME','SERVICES_TOLERANCE_NAME');
            FND_MSG_PUB.ADD;
         END IF;
     END;

    ELSIF (p_tolerance_id is NULL and p_tolerance_name is NOT NULL) THEN
    BEGIN
        SELECT tolerance_id
        INTO   p_tolerance_id
        FROM   AP_TOLERANCE_TEMPLATES
        WHERE  tolerance_name = p_tolerance_name;

    EXCEPTION
    -- Trap validation error
    WHEN NO_DATA_FOUND THEN
         x_valid    := FALSE;
         IF p_tolerance_type = 'QUANTITY' THEN
            FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
            FND_MESSAGE.SET_TOKEN('COLUMN_NAME','TOLERANCE_NAME' );
	    FND_MSG_PUB.ADD;
         ELSE
            FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
            FND_MESSAGE.SET_TOKEN('COLUMN_NAME','SERVICES_TOLERANCE_NAME' );
            FND_MSG_PUB.ADD;
         END IF;
      END;
    END IF;

 END Check_tolerance_id_code;

--
-- Check if ship_via_lookup_code is valid for the site
--
 PROCEDURE Check_Site_Ship_Via(p_ship_via_lookup_code      IN      VARCHAR2,
                                p_org_id                   IN      NUMBER,
                                x_valid                    OUT NOCOPY BOOLEAN
                              ) IS
    l_dummy          org_freight.freight_code%TYPE;

 BEGIN
    x_valid    := TRUE;

       SELECT FRT.freight_code
       INTO   l_dummy
       FROM   org_freight FRT, financials_system_params_all FIN
       WHERE  FRT.organization_id = FIN.inventory_organization_id
       AND    FIN.org_id = p_org_id
       AND    nvl(FRT.disable_date, sysdate +1 ) > sysdate
       AND    FRT.freight_code = p_ship_via_lookup_code;

 EXCEPTION
    -- Trap validation error
    WHEN NO_DATA_FOUND THEN
         x_valid    := FALSE;

         FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
         FND_MESSAGE.SET_TOKEN('COLUMN_NAME','SHIP_VIA_LOOKUP_CODE' );
	 FND_MSG_PUB.ADD;
 END Check_Site_Ship_Via;

 --
 -- Check if the party_id is valid
 --
 PROCEDURE Check_Valid_Party_Id(p_party_id    IN         NUMBER,
                              x_valid            OUT NOCOPY BOOLEAN
                              ) IS
    l_dummy          NUMBER;
    l_count	     NUMBER;

 BEGIN
    x_valid    := TRUE;

       SELECT party_id
       INTO   l_dummy
       FROM   hz_parties
       WHERE  party_id  = p_party_id;


     EXCEPTION
    -- Trap validation error
    WHEN NO_DATA_FOUND THEN
         x_valid    := FALSE;

         FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
	 FND_MESSAGE.SET_TOKEN('COLUMN_NAME','PARTY_ID' );
	 FND_MSG_PUB.ADD;

   IF x_valid = TRUE THEN
	--check usage status
   	SELECT count(party_id)
   	INTO l_count
   	FROM HZ_PARTY_USG_ASSIGNMENTS HPUA
   	WHERE HPUA.PARTY_USAGE_CODE in
	('SUPPLIER','SUPPLIER_CONTACT', 'ORG_CONTACT')
   	AND HPUA.PARTY_ID = p_party_id;

   	IF nvl(l_count, -1) > 0 THEN
		x_valid    := FALSE;

         	FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
         	FND_MESSAGE.SET_TOKEN('COLUMN_NAME','PARTY_ID' );
         	FND_MSG_PUB.ADD;
	END IF;
   END IF;

 END Check_Valid_Party_Id;

 --
 -- Check if the location_id is valid
 --
 PROCEDURE Check_Valid_Location_Id(p_location_id    IN         NUMBER,
				p_party_site_id		IN 	NUMBER,
                              x_valid            OUT NOCOPY BOOLEAN
                              ) IS
    l_dummy          NUMBER;

 BEGIN
    x_valid    := TRUE;

    SELECT Count(*)
       INTO   l_dummy
       FROM   hz_locations hl, hz_party_sites hps
       WHERE  hl.location_id  = p_location_id
	AND hl.location_id = hps.location_id
	AND hps.party_site_id = nvl(p_party_site_id, hps.party_site_id);

    IF nvl(l_dummy,0) = 0 THEN
         x_valid    := FALSE;

         FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
	 FND_MESSAGE.SET_TOKEN('COLUMN_NAME','LOCATION_ID' );
	 FND_MSG_PUB.ADD;
    END IF;

 END Check_Valid_Location_Id;

 --
 -- Check if the party_site_id is valid
 --
 PROCEDURE Check_Valid_Party_Site_Id(p_party_Site_id    IN         NUMBER,
				p_location_id IN	NUMBER,
                              x_valid            OUT NOCOPY BOOLEAN
                              ) IS
    l_dummy          NUMBER;

 BEGIN
    x_valid    := TRUE;

    SELECT Count(*)
       INTO   l_dummy
       FROM   hz_party_sites hps
       WHERE ( hps.location_id  = nvl(p_location_id, hps.location_id)
	AND hps.party_site_id = p_party_site_id);

    IF nvl(l_dummy,0) = 0 THEN
         x_valid    := FALSE;

         FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
	 FND_MESSAGE.SET_TOKEN('COLUMN_NAME','PARTY_SITE_ID' );
	 FND_MSG_PUB.ADD;
    END IF;


 END Check_Valid_Party_Site_Id;

 --
 -- Check if relationship_id is valid
 --
 PROCEDURE Check_Valid_Relationship_Id
                    (p_relationship_id    IN         NUMBER,
                     x_valid              OUT NOCOPY BOOLEAN) IS

    l_dummy          NUMBER;

 BEGIN
       x_valid    := TRUE;

       SELECT relationship_id
       INTO   l_dummy
       FROM   hz_relationships
       WHERE  relationship_id = p_relationship_id
       AND rownum < 2;


  EXCEPTION
    -- Trap validation error
    WHEN NO_DATA_FOUND THEN
         x_valid    := FALSE;

         FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
	     FND_MESSAGE.SET_TOKEN('COLUMN_NAME','RELATIONSHIP_ID' );
	     FND_MSG_PUB.ADD;

 END Check_Valid_Relationship_Id;

 --
 -- Check if org_contact_id is valid
 --
 PROCEDURE Check_Valid_Org_Contact_Id
                    (p_org_contact_id    IN         NUMBER,
                     x_valid             OUT NOCOPY BOOLEAN) IS

    l_dummy          NUMBER;

 BEGIN
       x_valid    := TRUE;

       SELECT org_contact_id
       INTO   l_dummy
       FROM   hz_org_contacts
       WHERE  org_contact_id = p_org_contact_id;


  EXCEPTION
    -- Trap validation error
    WHEN NO_DATA_FOUND THEN
         x_valid    := FALSE;

         FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
	     FND_MESSAGE.SET_TOKEN('COLUMN_NAME','ORG_CONTACT_ID' );
	     FND_MSG_PUB.ADD;

 END Check_Valid_Org_Contact_Id;

 -- This procedure for Import functionality from 11i
 -- Check that If the vendor_site_id is valid in
 -- Supplier Site Contact Interface table
 PROCEDURE Check_Vendor_site_id
                     (p_vendor_site_id         IN  NUMBER,
                      p_int_table              IN  VARCHAR2,
                      p_int_key                IN  VARCHAR2,
                      x_valid                  OUT NOCOPY BOOLEAN) IS

   l_dummy          po_vendor_sites_all.vendor_site_id%TYPE;
   l_api_name       CONSTANT VARCHAR2(30)   := 'Check_Vendor_Site_Id';
 BEGIN

   x_valid    := TRUE;

   SELECT vendor_site_id
   INTO  l_dummy
   FROM  po_vendor_sites_all
   WHERE vendor_site_id = p_vendor_site_id
   AND  nvl(inactive_date, sysdate +1 ) > sysdate;

 EXCEPTION
   -- Trap validation error
   WHEN NO_DATA_FOUND THEN
     x_valid    := FALSE;
     IF g_source = 'IMPORT' THEN
       IF (Insert_Rejections(
           p_int_table,
           p_int_key,
           'AP_INVALID_VENDOR_SITE_ID',
           g_user_id,
           g_login_id,
           'Check_Vendor_Site_Id') <> TRUE) THEN
          --
         IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'Parameters: '
                     ||' P_Vendor_Site_Id: '|| p_vendor_site_id
                     ||', P_Int_Table: '||p_int_table
                     ||', P_Int_Key: '||p_int_key);
         END IF;
       END IF;
     ELSE
            -- Bug 5491139 hkaniven start --
        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_VENDOR_SITE_ID');
        FND_MSG_PUB.ADD;
            -- Bug 5491139 hkaniven end --
     END IF;
     -- Trap unknown errors
   WHEN OTHERS THEN
     x_valid    := FALSE;
     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'Parameters: '
                     ||' P_Vendor_Site_Id: '|| p_vendor_site_id
                     ||', P_Int_Table: '||p_int_table
                     ||', P_Int_Key: '||p_int_key
                     ||', ERROR: '||SUBSTR(SQLERRM,1,200));
     END IF;
 END Check_Vendor_site_id;

 -- This procedure for Import functionality from 11i
 -- Check that If the org_id or operating_unit is
 -- sync with vendor site code
 -- Supplier Site Contact Interface table
 PROCEDURE Check_org_id_name_site_code
                     (p_org_id           IN      NUMBER,
                      p_org_name         IN      VARCHAR2,
                      p_vendor_site_id   IN OUT  NOCOPY NUMBER,
                      p_vendor_site_code IN      VARCHAR2,
                      p_int_table        IN  VARCHAR2,
                      p_int_key          IN  VARCHAR2,
                      x_valid            OUT NOCOPY BOOLEAN) IS

    l_org_id           HR_OPERATING_UNITS.organization_id%TYPE;
    l_org_name         HR_OPERATING_UNITS.name%TYPE;
    l_vendor_site_code PO_VENDOR_SITES_ALL.vendor_site_code%TYPE;
    l_api_name       CONSTANT VARCHAR2(30)   := 'Check_Org_Id_Name_Site_Code';
 BEGIN
   x_valid    := TRUE;

   IF (p_org_id IS NOT NULL AND p_vendor_site_code IS NOT NULL) THEN
     BEGIN
        /*Bug 4592201.This is to make sure that we don't say that
          there is an inconsistency when two different suppliers have same
          vendor-site-code*/
        /*Since the vendor-site-id can be null in the case when he just passes
          the vendor-site-code,we have split the statement into two cases*/
        if(p_vendor_site_id is not null) then
         SELECT vendor_site_code, vendor_site_id
         INTO   l_vendor_site_code,p_vendor_site_id
         FROM   PO_VENDOR_SITES_ALL
         WHERE  org_id = p_org_id
         AND    vendor_site_code  = p_vendor_site_code
         AND    vendor_site_id=p_vendor_site_id;
        else
         SELECT vendor_site_code, vendor_site_id
         INTO   l_vendor_site_code,p_vendor_site_id
         FROM   PO_VENDOR_SITES_ALL
         WHERE  org_id = p_org_id
         AND    vendor_site_code=p_vendor_site_code;
        end if;
        /*Bug4592201*/
     EXCEPTION
       -- Trap validation error
       WHEN NO_DATA_FOUND THEN
         x_valid    := FALSE;
         IF g_source = 'IMPORT' THEN
           IF (Insert_Rejections(
             p_int_table,
             p_int_key,
             'AP_INVALID_VENDOR_SITE_CODE',
             g_user_id,
             g_login_id,
            'Check_Org_Id_Name_Site_Code') <> TRUE) THEN
          --
             IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'Parameters: '
                     ||' P_Org_Id: '||p_org_id
                     ||', P_Org_Name: '||p_org_name
                     ||', P_Vendor_Site_Code: '||p_vendor_site_code
                     ||', P_Vendor_Site_Id: '|| p_vendor_site_id
                     ||', P_Int_Table: '||p_int_table
                     ||', P_Int_Key: '||p_int_key);
             END IF;
           END IF;
         ELSE
            -- Bug 5491139 hkaniven start --
            FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_VENDOR_SITE_CODE');
            FND_MSG_PUB.ADD;
            -- Bug 5491139 hkaniven end --
         END IF;
     END;

   ELSIF (p_org_id IS NULL AND
          p_org_name IS NOT NULL AND
          p_vendor_site_code is NOT NULL) THEN

     BEGIN
       SELECT SITE.vendor_site_code,vendor_site_id
       INTO   l_vendor_site_code,p_vendor_site_id
       FROM   PO_VENDOR_SITES_ALL SITE, HR_OPERATING_UNITS ORG
       WHERE  ORG.name = p_org_name
       AND    SITE.org_id = ORG.organization_id
       AND    SITE.vendor_site_code = p_vendor_site_code;

     EXCEPTION
       -- Trap validation error
       WHEN NO_DATA_FOUND THEN
         x_valid    := FALSE;
          IF g_source = 'IMPORT' THEN
           IF (Insert_Rejections(
             p_int_table,
             p_int_key,
             'AP_INVALID_VENDOR_SITE_CODE',
             g_user_id,
             g_login_id,
            'Check_Org_Id_Name_Site_Code') <> TRUE) THEN
          --
             IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'Parameters: '
                     ||' P_Org_Id: '||p_org_id
                     ||', P_Org_Name: '||p_org_name
                     ||', P_Vendor_Site_Code: '||p_vendor_site_code
                     ||', P_Vendor_Site_Id: '|| p_vendor_site_id
                     ||', P_Int_Table: '||p_int_table
                     ||', P_Int_Key: '||p_int_key);
             END IF;
           END IF;
         ELSE
            -- Bug 5491139 hkaniven start --
            FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_VENDOR_SITE_CODE');
            FND_MSG_PUB.ADD;
            -- Bug 5491139 hkaniven end --
         END IF;
     END;

   END IF;

 EXCEPTION
  -- Trap unknown errors
   WHEN OTHERS THEN
     x_valid    := FALSE;
     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'Parameters: '
                     ||' P_Org_Id: '||p_org_id
                     ||', P_Org_Name: '||p_org_name
                     ||', P_Vendor_Site_Code: '||p_vendor_site_code
                     ||', P_Vendor_Site_Id: '|| p_vendor_site_id
                     ||', P_Int_Table: '||p_int_table
                     ||', P_Int_Key: '||p_int_key
                     ||', ERROR: '||SUBSTR(SQLERRM,1,200));
     END IF;
 END Check_org_id_name_site_code;

 /* udhenuko bug 7013954 added procedure
 This procedure is used to check if the org_id or operating_unit is in
 sync with Party Site Name of hz_parties and ap_supplier_sites
 for Supplier Site Contact Interface table*/
 PROCEDURE Check_org_id_party_site_name
                     (p_org_id           IN      NUMBER,
                      p_org_name         IN      VARCHAR2,
                      p_party_site_id    IN OUT NOCOPY NUMBER,
                      p_party_site_name  IN  VARCHAR2,
                      p_vendor_id        IN  NUMBER,
                      p_int_table        IN  VARCHAR2,
                      p_int_key          IN  VARCHAR2,
                      x_valid            OUT NOCOPY BOOLEAN) IS

    l_org_id           HR_OPERATING_UNITS.organization_id%TYPE;
    l_org_name         HR_OPERATING_UNITS.name%TYPE;
    l_party_site_name hz_party_sites.party_site_name%TYPE;
    l_api_name       CONSTANT VARCHAR2(30)   := 'Check_org_id_party_site_name';
 BEGIN
   x_valid    := TRUE;

   IF (p_org_id IS NOT NULL AND p_party_site_name IS NOT NULL) THEN
     BEGIN
        /*If party_site_id is null then we derive it based on the
		party_site_name field provided. But in case of Upgraded records there
		can be multiple records in hz_party_sites with same party_site_name
		for the same party. We can link the ap_supplier_sites_all table
		to get unique record based on the input info*/

        if(p_party_site_id is not null) then
         SELECT hzps.party_site_name, hzps.party_site_id
           INTO   l_party_site_name,p_party_site_id
         FROM   hz_party_sites hzps, ap_suppliers aps
         WHERE  hzps.party_site_name  = p_party_site_name
           AND    hzps.party_site_id = p_party_site_id
		   AND    aps.vendor_id = p_vendor_id;
        else
         SELECT hzps.party_site_name, hzps.party_site_id
           INTO   l_party_site_name,p_party_site_id
         FROM   hz_party_sites hzps, ap_supplier_sites_all aps
         WHERE  aps.org_id = p_org_id
           AND    hzps.party_site_name = p_party_site_name
		   AND    hzps.party_site_id = aps.party_site_id
		   AND    aps.vendor_id = p_vendor_id;
        end if;
		IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME,'Check_org_id_party_site_name : '
                     ||' P_Party_Site_Id: '|| p_party_site_id);
		END IF;
     EXCEPTION
       -- Trap validation error
       WHEN NO_DATA_FOUND THEN
         x_valid    := FALSE;
     END;

   ELSIF (p_org_id IS NULL AND
          p_org_name IS NOT NULL AND
          p_party_site_name is NOT NULL) THEN

     BEGIN
       SELECT hzps.party_site_name, hzps.party_site_id
         INTO   l_party_site_name,p_party_site_id
       FROM   hz_party_sites hzps, ap_supplier_sites_all aps,
		 HR_OPERATING_UNITS ORG
       WHERE  ORG.name = p_org_name
         AND    aps.org_id = ORG.organization_id
         AND    hzps.party_site_name = p_party_site_name
	     AND    hzps.party_site_id = aps.party_site_id
	     AND    aps.vendor_id = p_vendor_id;

     EXCEPTION
       -- Trap validation error
       WHEN NO_DATA_FOUND THEN
         x_valid    := FALSE;
     END;

   END IF;

 EXCEPTION
  -- Trap unknown errors
   WHEN OTHERS THEN
     x_valid    := FALSE;
     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'Parameters: '
                     ||' P_Org_Id: '||p_org_id
                     ||', P_Org_Name: '||p_org_name
                     ||', p_party_site_name: '||p_party_site_name
                     ||', p_party_site_id: '|| p_party_site_id
					 ||', p_vendor_id: '|| p_vendor_id
                     ||', P_Int_Table: '||p_int_table
                     ||', P_Int_Key: '||p_int_key
                     ||', ERROR: '||SUBSTR(SQLERRM,1,200));
     END IF;
 END Check_org_id_party_site_name;

---------------------------------------------------------------------
--  PROCEDURE : Chk_new_duns_number
--  PURPOSE   : Validates the Duns number passed as argument
--              Added for the FSIO gap in R12(bug6053476)
---------------------------------------------------------------------

 PROCEDURE Chk_new_duns_number(p_duns_number    IN  VARCHAR2,
                               x_valid           OUT NOCOPY BOOLEAN
                               ) IS

    e_apps_exception       EXCEPTION;

 BEGIN
    x_valid    := TRUE;

    -- B# 8715186
    --If ((translate(p_duns_number,'1234567890','9999999999') <> '999999999' ) OR
    --    (length(p_duns_number) <> 9)) Then
    --     Raise e_apps_exception;
    --End If;

    If ((translate(p_duns_number,'1234567890','9999999999') = '999999999' ) OR
       (length(p_duns_number) = 9) OR
       (translate(p_duns_number,'1234567890','9999999999') = '9999999999999' ) OR
       (length(p_duns_number) = 13)) THEN
           NULL;
    Else

         Raise e_apps_exception;
    End If;

    -- end B# 8715186

 EXCEPTION
 -- Trap validation error
    WHEN e_apps_exception THEN
         x_valid    := FALSE;

         FND_MESSAGE.SET_NAME('SQLAP','AP_IMPORT_COLUMN_INVALID');
         FND_MESSAGE.SET_TOKEN('COLUMN_NAME','DUNS_NUMBER' );
         FND_MSG_PUB.ADD;
 END Chk_new_duns_number;


-----------------------------------------------------------------------------
-- PROCEDURE : Update_supplier_JFMIP_checks
-- PURPOSE   : Checks if one is trying to update the restricted fields on a
--             CCR supplier.
--             Added for the R12 FSIO gap.(bug6053476)
------------------------------------------------------------------------------


 PROCEDURE update_supplier_JFMIP_checks(p_vendor_rec         IN  r_vendor_rec_type,
                                        p_calling_prog       IN  VARCHAR2,
                                        x_valid              OUT NOCOPY BOOLEAN
                                        ) IS
    e_apps_exception  EXCEPTION;

 BEGIN
    x_valid    := TRUE;

    IF ((AP_UTILITIES_PKG.get_ccr_status(p_vendor_rec.vendor_id,'S') = 'T')
        AND (nvl(p_calling_prog,'NOT CCR') <> 'CCRImport')) THEN
      If (p_vendor_rec.jgzz_fiscal_code is NOT NULL) THEN
          Raise e_apps_exception;
      End If;
    END IF;

     EXCEPTION
       -- Trap validation error
       WHEN e_apps_exception THEN
            x_valid    := FALSE;

           FND_MESSAGE.SET_NAME('SQLAP','AP_CCR_NO_UPDATE');
	   FND_MSG_PUB.ADD;
 END update_supplier_JFMIP_checks;


-----------------------------------------------------------------------------
-- PROCEDURE : Chk_Update_site_CCR_values
-- PURPOSE   : Checks if one is trying to update the restricted fields on a
--             CCR supplier site.
--             Added for the R12 FSIO gap.(bug6053476)
------------------------------------------------------------------------------


 PROCEDURE Chk_update_site_ccr_values(p_vendor_site_rec   IN    r_vendor_site_rec_type,
       				      p_calling_prog      IN    VARCHAR2,
                                      x_valid             OUT   NOCOPY BOOLEAN
                                      ) IS
  e_apps_exception  EXCEPTION;

 BEGIN
    x_valid    := TRUE;

    IF ((AP_UTILITIES_PKG.get_ccr_status(p_vendor_site_rec.vendor_site_id, 'T') = 'T')
        AND (nvl(p_calling_prog,'NOT CCR') <> 'CCRImport')) THEN

       If (( p_vendor_site_rec.duns_number is NOT NULL)
        OR ( p_vendor_site_rec.country is NOT NULL)
        OR ( p_vendor_site_rec.address_line1 is NOT NULL)
        OR ( p_vendor_site_rec.address_line2 is NOT NULL)
        OR ( p_vendor_site_rec.address_line3 is NOT NULL)
        OR ( p_vendor_site_rec.address_line4 is NOT NULL)
        OR ( p_vendor_site_rec.city is NOT NULL)
        OR ( p_vendor_site_rec.state is NOT NULL)
        OR ( p_vendor_site_rec.zip is NOT NULL)
        OR ( p_vendor_site_rec.province is NOT NULL)
        -- starting the Changes for CLM reference data management bug#9499174
        OR ( p_vendor_site_rec.cage_code is NOT NULL)
        OR ( p_vendor_site_rec.legal_business_name is NOT NULL)
        OR ( p_vendor_site_rec.doing_bus_as_name is NOT NULL)
        OR ( p_vendor_site_rec.division_name is NOT NULL))  THEN
        -- Ending the Changes for CLM reference data management bug#9499174

       Raise e_apps_exception;
      End If;
   END IF;

     EXCEPTION
     -- Trap validation error
     WHEN e_apps_exception THEN
         x_valid    := FALSE;
         FND_MESSAGE.SET_NAME('SQLAP','AP_CCR_NO_UPDATE');
         FND_MSG_PUB.ADD;

 END Chk_update_site_ccr_values;


PROCEDURE Create_Vendor
( 	p_api_version           IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	IN  	NUMBER	:=
						FND_API.G_VALID_LEVEL_FULL,
	x_return_status		OUT	NOCOPY VARCHAR2		  	,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_vendor_rec		IN	r_vendor_rec_type,
	x_vendor_id		OUT	NOCOPY AP_SUPPLIERS.VENDOR_ID%TYPE,
	x_party_id		OUT	NOCOPY HZ_PARTIES.PARTY_ID%TYPE
)
IS


    l_api_name			CONSTANT VARCHAR2(30)	:= 'Create_Vendor';
    l_api_version           	CONSTANT NUMBER 		:= 1.0;

    l_vendor_rec		r_vendor_rec_type;

    -- define variables for initialization
    l_user_defined_vendor_num_code      VARCHAR2(255);
    l_manual_vendor_num_type            VARCHAR2(255);
    l_rfq_only_site_flag                VARCHAR2(255);
    l_ship_to_location_id               NUMBER;
    l_ship_to_location_code             VARCHAR2(255);
    l_bill_to_location_id               NUMBER;
    l_bill_to_location_code             VARCHAR2(255);
    l_fob_lookup_code                   VARCHAR2(255);
    l_freight_terms_lookup_code         VARCHAR2(255);
    l_terms_id                          NUMBER;
    l_terms_disp                        VARCHAR2(255);
    l_distribution_set_id		NUMBER;
    l_always_take_disc_flag             VARCHAR2(1);
    l_invoice_currency_code             VARCHAR2(255);
    l_org_id                            NUMBER;
    l_set_of_books_id                   NUMBER;
    l_short_name                        VARCHAR2(255);
    l_payment_currency_code             VARCHAR2(255);
    l_accts_pay_ccid                    NUMBER;
    l_future_dated_payment_ccid         NUMBER;
    l_prepay_code_combination_id        NUMBER;
    l_vendor_pay_group_lookup_code      VARCHAR2(255);
    l_sys_auto_calc_int_flag            VARCHAR2(255);
    l_terms_date_basis                  VARCHAR2(255);
    l_terms_date_basis_disp             VARCHAR2(255);
    l_chart_of_accounts_id              NUMBER;
    l_fob_lookup_disp                   VARCHAR2(255);
    l_freight_terms_lookup_disp         VARCHAR2(255);
    l_vendor_pay_group_disp             VARCHAR2(255);
    l_fin_require_matching              VARCHAR2(255);
    l_sys_require_matching              VARCHAR2(255);
    l_fin_match_option                  VARCHAR2(255);
    l_po_create_dm_flag                 VARCHAR2(255);
    l_exclusive_payment                 VARCHAR2(255);
    l_vendor_auto_int_default           VARCHAR2(255);
    l_inventory_organization_id         NUMBER;
    l_ship_via_lookup_code              VARCHAR2(255);
    l_ship_via_disp                     VARCHAR2(255);
    l_sysdate                           DATE;
    l_enforce_ship_to_loc_code          VARCHAR2(255);
    l_receiving_routing_id              NUMBER;
    l_qty_rcv_tolerance                 NUMBER;
    l_qty_rcv_exception_code            VARCHAR2(255);
    l_days_early_receipt_allowed        NUMBER;
    l_days_late_receipt_allowed         NUMBER;
    l_allow_sub_receipts_flag           VARCHAR2(255);
    l_allow_unord_receipts_flag         VARCHAR2(255);
    l_receipt_days_exception_code       VARCHAR2(255);
    l_enforce_ship_to_loc_disp          VARCHAR2(255);
    l_qty_rcv_exception_disp            VARCHAR2(255);
    l_receipt_days_exception_disp       VARCHAR2(255);
    l_receipt_required_flag             VARCHAR2(255);
    l_inspection_required_flag          VARCHAR2(255);
    l_payment_method_lookup_code        VARCHAR2(255);
    l_payment_method_disp               VARCHAR2(255);
    l_pay_date_basis_lookup_code        VARCHAR2(255);
    l_pay_date_basis_disp               VARCHAR2(255);
    l_receiving_routing_name            VARCHAR2(255);
    l_ap_inst_flag                      VARCHAR2(255);
    l_po_inst_flag                      VARCHAR2(255);
    l_home_country_code                 VARCHAR2(255);
    l_default_awt_group_id              NUMBER;
    l_default_awt_group_name            VARCHAR2(255);
    l_pay_awt_group_id                  NUMBER; /* Bug9589179*/
    l_pay_awt_group_name                VARCHAR2(255);/* Bug9589179*/
    l_allow_awt_flag                    VARCHAR2(255);
    l_base_currency_code                VARCHAR2(255);
    l_address_style                     VARCHAR2(255);
    l_obsolete                          VARCHAR2(255);
    l_use_bank_charge_flag              VARCHAR2(255);
    l_bank_charge_bearer                VARCHAR2(255);
    l_hold_unmatched_invoices_flag	VARCHAR2(1);

    l_user_id                		number := FND_GLOBAL.USER_ID;
    l_last_update_login      		number := FND_GLOBAL.LOGIN_ID;
    l_program_application_id 		number := FND_GLOBAL.prog_appl_id;
    l_program_id             		number := FND_GLOBAL.conc_program_id;
    l_request_id            	 	number := FND_GLOBAL.conc_request_id;
    l_val_return_status      		VARCHAR2(50);
    l_val_msg_count	    		NUMBER;
    l_val_msg_data			VARCHAR2(1000);
    l_creation_date			DATE;
    l_created_by			NUMBER;
    l_org_return_status                 VARCHAR2(50);
    l_org_msg_count                     NUMBER;
    l_org_msg_data                      VARCHAR2(1000);
    l_pay_return_status                 VARCHAR2(50);
    l_pay_msg_count                     NUMBER;
    l_pay_msg_data                      VARCHAR2(1000);
    l_zx_return_status                  VARCHAR2(50);
    l_zx_msg_count                      NUMBER;
    l_zx_msg_data                       VARCHAR2(1000);
    l_party_valid			VARCHAR2(1);
    l_payee_valid                       VARCHAR2(1);
    l_row_id				VARCHAR2(255);
    l_vendor_id				NUMBER;
    l_party_rec			HZ_PARTY_V2PUB.party_rec_type;
    l_org_rec			HZ_PARTY_V2PUB.organization_rec_type;
    l_org_party_id		NUMBER;
    l_org_party_number		VARCHAR2(30);
    l_org_profile_ID		NUMBER;
    l_party_num			VARCHAR2(1);

    --
    -- Added Sync Party Related return variables
    --
    l_sync_return_status                 VARCHAR2(50);
    l_sync_msg_count                     NUMBER;
    l_sync_msg_data                      VARCHAR2(1000);


    /* Variable Declaration for IBY */
    ext_payee_tab               IBY_DISBURSEMENT_SETUP_PUB.External_Payee_Tab_Type;
    ext_payee_id_tab            IBY_DISBURSEMENT_SETUP_PUB.Ext_Payee_Id_Tab_Type;
    ext_payee_create_tab        IBY_DISBURSEMENT_SETUP_PUB.Ext_Payee_Create_Tab_Type;

    l_ext_payee_rec		IBY_DISBURSEMENT_SETUP_PUB.EXTERNAL_PAYEE_REC_TYPE;
    l_party_usg_rec   HZ_PARTY_USG_ASSIGNMENT_PVT.party_usg_assignment_rec_type; --Bug6648405
    l_party_usg_validation_level NUMBER;
    l_debug_info      VARCHAR2(500); -- Bug 6823885

    l_contact_point_rec		HZ_CONTACT_POINT_V2PUB.contact_point_rec_type;	--B 7831956
    l_url_rec			HZ_CONTACT_POINT_V2PUB.web_rec_type;		--B 7831956
    l_url_return_status	VARCHAR2(50)	:= FND_API.G_RET_STS_SUCCESS;		--B 7831956
    l_url_msg_count		NUMBER;						--B 7831956
    l_url_msg_data		VARCHAR2(1000);					--B 7831956
    l_url_contact_point_id	NUMBER;						--B 7831956

    l_offset_tax_flag	        VARCHAR2(1) ;			--B 9202909
    l_auto_tax_calc_flag        VARCHAR2(1) ;			--B 9202909
    l_tax_classification_code   ZX_PARTY_TAX_PROFILE.TAX_CLASSIFICATION_CODE%TYPE ; --B 9202909
    l_party_id				NUMBER ; --B 9202909
    L_PARTY_TAX_PROFILE_ID	zx_party_tax_profile.party_tax_profile_id%type; -- B 9202909
    l_return_status             VARCHAR2(50);  -- B 9202909

BEGIN
	-- Standard Start of API savepoint
    SAVEPOINT	Create_Vendor_PUB;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
    THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_org_return_status := FND_API.G_RET_STS_SUCCESS;
    l_val_return_status := FND_API.G_RET_STS_SUCCESS;
    l_pay_return_status := FND_API.G_RET_STS_SUCCESS;
    l_sync_return_status := FND_API.G_RET_STS_SUCCESS;

    -- API body

    -- Run initialize and get required default values
    ap_apxvdmvd_pkg.initialize_supplier_attr(
        x_user_defined_vendor_num_code  => l_user_defined_vendor_num_code,
        x_manual_vendor_num_type        => l_manual_vendor_num_type,
        x_terms_id                      => l_terms_id,
        x_terms_disp                    => l_terms_disp,
        x_always_take_disc_flag         => l_always_take_disc_flag,
        x_invoice_currency_code         => l_invoice_currency_code,
        x_vendor_pay_group_lookup_code  => l_vendor_pay_group_lookup_code,
        x_sys_auto_calc_int_flag        => l_sys_auto_calc_int_flag,
        x_terms_date_basis              => l_terms_date_basis,
        x_terms_date_basis_disp         => l_terms_date_basis_disp,
        x_vendor_pay_group_disp         => l_vendor_pay_group_disp,
        x_fin_require_matching          => l_fin_require_matching,
        x_fin_match_option              => l_fin_match_option,
        x_sysdate                       => l_sysdate,
        x_pay_date_basis_lookup_code    => l_pay_date_basis_lookup_code,
        x_pay_date_basis_disp           => l_pay_date_basis_disp,
        x_ap_inst_flag                  => l_ap_inst_flag,
        x_use_bank_charge_flag          => l_use_bank_charge_flag,
        x_bank_charge_bearer            => l_bank_charge_bearer,
        x_calling_sequence              => ''); --l_calling_sequence


    l_vendor_rec := p_vendor_rec;

    --All fields that use to be defaulted from po_system_parameters
    --in the initialization procedure will no longer be defaulted at
    --the supplier level because system parameters are org specific
    l_vendor_rec.summary_flag := nvl(l_vendor_rec.summary_flag, 'N');
    l_vendor_rec.enabled_flag := nvl(l_vendor_rec.enabled_flag, 'Y');
    l_last_update_login := fnd_global.login_id;
    l_creation_date := sysdate;
    l_created_by := fnd_global.user_id;
    l_vendor_rec.one_time_flag   := nvl(l_vendor_rec.one_time_flag,'N');

    -- Bug 6085640 - Terms ID should not be set to default if Terms Name
    --               has been given.
    -- added by abhsaxen on 06-May-2008 for bug#7008314
    IF l_vendor_rec.terms_name IS NULL or l_vendor_rec.terms_name = ap_null_char
       THEN l_vendor_rec.terms_id    := nvl(l_vendor_rec.terms_id,
                                            l_terms_id);
       ELSE l_vendor_rec.terms_id    := l_vendor_rec.terms_id;
    END IF;

    l_vendor_rec.always_take_disc_flag
	:= nvl(l_vendor_rec.always_take_disc_flag, l_always_take_disc_flag);
    l_vendor_rec.pay_date_basis_lookup_code
	:= nvl(l_vendor_rec.pay_date_basis_lookup_code,
			l_pay_date_basis_lookup_code);
    l_vendor_rec.pay_group_lookup_code
	:= nvl(l_vendor_rec.pay_group_lookup_code,
		l_vendor_pay_group_lookup_code);
    l_vendor_rec.payment_priority    := nvl(l_vendor_rec.payment_priority, 99);
    l_vendor_rec.invoice_currency_code
	:= nvl(l_vendor_rec.invoice_currency_code, l_invoice_currency_code);

    -- Payment Currency Defaulting at the supplier level
    -- With the MOAC Project the payment currency defaulting was left
    -- out. Added defaulting logic to use invoice currency default from
    -- product setup for supplier level payment currency defaulting
    -- if a value is not provided in the input vendor record.

    l_vendor_rec.payment_currency_code
	:= nvl(l_vendor_rec.payment_currency_code, l_invoice_currency_code);
    l_vendor_rec.hold_all_payments_flag
	:= nvl(l_vendor_rec.hold_all_payments_flag, 'N');
    l_vendor_rec.hold_future_payments_flag
	:= nvl(l_vendor_rec.hold_future_payments_flag, 'N');
    l_vendor_rec.start_date_active
	:= nvl(l_vendor_rec.start_date_active, SYSDATE);
    /*po defaults
    l_vendor_rec.qty_rcv_tolerance
	:= nvl(l_vendor_rec.qty_rcv_tolerance, l_qty_rcv_tolerance);
    */
    l_vendor_rec.women_owned_flag  := NVL(l_vendor_rec.women_owned_flag, 'N');
    l_vendor_rec.small_business_flag
	:= NVL(l_vendor_rec.small_business_flag, 'N');
    l_vendor_rec.hold_flag  := nvl(l_vendor_rec.hold_flag, 'N');
    l_vendor_rec.terms_date_basis
	:= nvl(l_vendor_rec.terms_date_basis, l_terms_date_basis);
    /*po defaults
    l_vendor_rec.days_early_receipt_allowed
	:= nvl(l_vendor_rec.days_early_receipt_allowed,
		l_days_early_receipt_allowed);
    l_vendor_rec.days_late_receipt_allowed
	:= nvl(l_vendor_rec.days_late_receipt_allowed,
		l_days_late_receipt_allowed);
    l_vendor_rec.enforce_ship_to_location_code
	:= nvl(l_vendor_rec.enforce_ship_to_location_code,
		l_enforce_ship_to_loc_code);
    */
    l_vendor_rec.federal_reportable_flag
	:= nvl(l_vendor_rec.federal_reportable_flag, 'N');
    --bug6401663
    l_vendor_rec.hold_unmatched_invoices_flag
	:= nvl(l_vendor_rec.hold_unmatched_invoices_flag,
	        l_fin_require_matching);
    --bug6075649
    l_vendor_rec.match_option
	:= nvl(l_vendor_rec.match_option, l_fin_match_option);
    /*l_vendor_rec.create_debit_memo_flag
	:= nvl(l_vendor_rec.create_debit_memo_flag, l_po_create_dm_flag);
    l_vendor_rec.inspection_required_flag
	:= nvl(l_vendor_rec.inspection_required_flag,
		l_inspection_required_flag);
    l_vendor_rec.receipt_required_flag
	:= nvl(l_vendor_rec.receipt_required_flag, l_receipt_required_flag);
    l_vendor_rec.receiving_routing_id
	:= nvl(l_vendor_rec.receiving_routing_id, l_receiving_routing_id);
    */
    l_vendor_rec.auto_calculate_interest_flag
	:= nvl(l_vendor_rec.auto_calculate_interest_flag,
		l_sys_auto_calc_int_flag);
    /*po defaults
    l_vendor_rec.allow_substitute_receipts_flag
	:= nvl(l_vendor_rec.allow_substitute_receipts_flag,
		l_allow_sub_receipts_flag);
    l_vendor_rec.allow_unordered_receipts_flag
	:= nvl(l_vendor_rec.allow_unordered_receipts_flag,
		l_allow_unord_receipts_flag);
    l_vendor_rec.qty_rcv_exception_code
	:= nvl(l_vendor_rec.qty_rcv_exception_code, l_qty_rcv_exception_code);
    */
    l_vendor_rec.exclude_freight_from_discount
	:= nvl(l_vendor_rec.exclude_freight_from_discount, 'N');

    validate_vendor(p_api_version => 1.0,
		p_init_msg_list => FND_API.G_FALSE,
		p_commit  => FND_API.G_FALSE,
		x_return_status => l_val_return_status,
		x_msg_count => l_val_msg_count,
		x_msg_data => l_val_msg_data,
		p_vendor_rec => l_vendor_rec,
		P_mode => 'I',
		P_calling_prog => 'NOT ISETUP',
		x_party_valid => l_party_valid,
		x_payee_valid => l_payee_valid,
		p_vendor_id => x_vendor_id);


--bug 6371419.Added the below if clause to create a party in hz,external payee
--in iby,tax code assignment in zx,supplier in AP only if the
--SUPPLIER IS VALID.
  IF (l_val_return_status = FND_API.G_RET_STS_SUCCESS) THEN

    IF l_party_valid = 'N' THEN -- party_id was null

	l_org_rec.created_by_module := 'AP_SUPPLIERS_API';
        l_org_rec.application_id := 200;
        l_org_rec.organization_name := l_vendor_rec.vendor_name;
        l_org_rec.organization_name_phonetic :=
		l_vendor_rec.vendor_name_alt;

        --bug6050423.Pass null value to jgzz_fiscal_code in hz_parties for
        --individual contractors and employees.
        --taxpayer id of individual contractors is stored only in ap_suppliers.
        --bug6691916.commented the below if clause and added the one below that.
	--as per analysis,only organization lookup code of type individual
	--and foreign individual belong to individual suppliers category.
         /*IF ( ((UPPER(p_vendor_rec.vendor_type_lookup_code)='CONTRACTOR')
                AND UPPER(p_vendor_rec.organization_type_lookup_code) IN
                        ('INDIVIDUAL','FOREIGN INDIVIDUAL',
                        'PARTNERSHIP','FOREIGN PARTNERSHIP') )
             OR  (UPPER(p_vendor_rec.vendor_type_lookup_code)='EMPLOYEE')) THEN*/

         IF (  UPPER(p_vendor_rec.organization_type_lookup_code) IN
                        ('INDIVIDUAL','FOREIGN INDIVIDUAL')
               OR
               (UPPER(p_vendor_rec.vendor_type_lookup_code)='EMPLOYEE')) THEN
                 l_org_rec.jgzz_fiscal_code :=NULL;
         ELSE
                l_org_rec.jgzz_fiscal_code := l_vendor_rec.jgzz_fiscal_code;

         END IF;

        -- Discussed with Indrajit. We will not pass the SIC Code
        -- TCA as the AP's SIC code is free form entry field.
        -- Commenting this code as part of bug 5066199
	-- l_org_rec.sic_code := l_vendor_rec.sic_code;
	l_org_rec.tax_reference := l_vendor_rec.tax_reference;

	fnd_profile.get('HZ_GENERATE_PARTY_NUMBER', l_party_num);
	IF nvl(l_party_num, 'Y') = 'N' THEN
		SELECT HZ_PARTY_NUMBER_S.Nextval
		INTO l_party_rec.party_number
		FROM DUAL;
	END IF;

	l_org_rec.party_rec := l_party_rec;


	l_org_rec.ceo_name := l_vendor_rec.ceo_name ;  -- B 9081643
	l_org_rec.ceo_title := l_vendor_rec.ceo_title ;  -- B 9081643

	hz_party_v2pub.create_organization(
		p_init_msg_list => FND_API.G_FALSE,
		p_organization_rec => l_org_rec,
		p_party_usage_code => 'SUPPLIER',
	--	p_commit => FND_API.G_FALSE,
		x_return_status => l_org_return_status,
		x_msg_count => l_org_msg_count,
		x_msg_data => l_org_msg_data,
		x_party_id => l_org_party_id,
		x_party_number => l_org_party_number,
		x_profile_id => l_org_profile_id);
		IF l_org_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      ------------------------------------------------------------------------
      l_debug_info := 'After call to hz_party_v2pub.create_organization';
      l_debug_info := l_debug_info||' Return status : '||l_org_return_status||' Error : '||l_org_msg_data;
      ------------------------------------------------------------------------
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;
    END IF;

        l_vendor_rec.party_id := l_org_party_id;

    END IF; --party_id was null

    -- B 7831956 start ...
    IF l_vendor_rec.url	IS NOT NULL THEN

		--populate contact point record
		l_contact_point_rec.owner_table_name := 'HZ_PARTIES' ;
		l_contact_point_rec.owner_table_id := l_vendor_rec.party_id ;
		l_contact_point_rec.created_by_module := 'AP_SUPPLIERS_API' ;
		l_contact_point_rec.application_id := 200 ;

		--populate url record

		l_contact_point_rec.contact_point_type := 'WEB';
		l_contact_point_rec.primary_flag := 'Y';
		l_contact_point_rec.contact_point_purpose := 'HOMEPAGE'; --bug5875982
		l_contact_point_rec.primary_by_purpose := 'Y';
		--Open Issue 5
		l_url_rec.web_type := 'HTTP';
		l_url_rec.url := l_vendor_rec.url ;

		hz_contact_point_v2pub.create_web_contact_point(
			p_init_msg_list => FND_API.G_FALSE,
			p_contact_point_rec => l_contact_point_rec,
			p_web_rec => l_url_rec,
			--p_commit => FND_API.G_FALSE,
			x_return_status => l_url_return_status,
			x_msg_count => l_url_msg_count,
			x_msg_data => l_url_msg_data,
			x_contact_point_id => l_url_contact_point_id);
			IF l_url_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        ------------------------------------------------------------------------
        l_debug_info := 'After call to hz_contact_point_v2pub.create_web_contact_point';
        l_debug_info := l_debug_info||' Return status : '||l_url_return_status||' Error : '||l_url_msg_data;
        ------------------------------------------------------------------------
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;
      END IF;

    END IF; -- B 7831956 ... end

    --Bug6677806
        l_party_usg_validation_level := HZ_PARTY_USG_ASSIGNMENT_PVT.G_VALID_LEVEL_NONE;
        l_party_usg_rec.party_id := nvl(l_vendor_rec.party_id,l_org_party_id);
        l_party_usg_rec.party_usage_code := 'SUPPLIER';
        l_party_usg_rec.created_by_module := 'AP_SUPPLIERS_API';--Bug6678590

        HZ_PARTY_USG_ASSIGNMENT_PVT.assign_party_usage (
        p_validation_level          => l_party_usg_validation_level,
        p_party_usg_assignment_rec  => l_party_usg_rec,
        x_return_status             => l_org_return_status,
        x_msg_count                 => l_org_msg_count,
        x_msg_data                  => l_org_msg_data);
        IF l_org_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          ------------------------------------------------------------------------
          l_debug_info := 'After call to HZ_PARTY_USG_ASSIGNMENT_PVT.assign_party_usage';
          l_debug_info := l_debug_info||' Return status : '||l_org_return_status||' Error : '||l_org_msg_data;
          ------------------------------------------------------------------------
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
          END IF;
        END IF;

    IF l_payee_valid = 'N' THEN --payee record is valid

    -- As per the discussion with Omar/Jayanta, we will only
    -- have payables payment function and no more employee expenses
    -- payment function.


        IF l_vendor_rec.ext_payee_rec.payment_function IS NULL THEN

	    l_ext_payee_rec.payee_party_id := l_vendor_rec.party_id;
        l_ext_payee_rec.payment_function  := 'PAYABLES_DISB';
        l_ext_payee_rec.exclusive_pay_flag   := 'N';

		-- Bug 6458813
        l_ext_payee_rec.default_pmt_method        := l_vendor_rec.ext_payee_rec.default_pmt_method;
		l_ext_payee_rec.ece_tp_loc_code           := l_vendor_rec.ext_payee_rec.ece_tp_loc_code;
        l_ext_payee_rec.bank_charge_bearer        := l_vendor_rec.ext_payee_rec.bank_charge_bearer;
        l_ext_payee_rec.bank_instr1_code          := l_vendor_rec.ext_payee_rec.bank_instr1_code;
        l_ext_payee_rec.bank_instr2_code          := l_vendor_rec.ext_payee_rec.bank_instr2_code;
        l_ext_payee_rec.bank_instr_detail         := l_vendor_rec.ext_payee_rec.bank_instr_detail;
        l_ext_payee_rec.pay_reason_code           := l_vendor_rec.ext_payee_rec.pay_reason_code;
        l_ext_payee_rec.pay_reason_com            := l_vendor_rec.ext_payee_rec.pay_reason_com;
        l_ext_payee_rec.pay_message1              := l_vendor_rec.ext_payee_rec.pay_message1;
        l_ext_payee_rec.pay_message2              := l_vendor_rec.ext_payee_rec.pay_message2;
        l_ext_payee_rec.pay_message3              := l_vendor_rec.ext_payee_rec.pay_message3;
        l_ext_payee_rec.delivery_channel          := l_vendor_rec.ext_payee_rec.delivery_channel;
        l_ext_payee_rec.pmt_format                := l_vendor_rec.ext_payee_rec.pmt_format;
        l_ext_payee_rec.settlement_priority       := l_vendor_rec.ext_payee_rec.settlement_priority;
        -- Bug 6458813 ends

        -- Bug 8216762
        -- B# 7583123
        l_ext_payee_rec.remit_advice_delivery_method := l_vendor_rec.supplier_notif_method;
        l_ext_payee_rec.remit_advice_email           := l_vendor_rec.remittance_email;

	ext_payee_tab(1)   := l_ext_payee_rec;
	ELSE

           ext_payee_tab(1)   := l_vendor_rec.ext_payee_rec;

        END IF;

        /* Calling IBY Payee Creation API */
        IBY_DISBURSEMENT_SETUP_PUB.Create_External_Payee
              ( p_api_version         => 1.0,
                p_init_msg_list       => FND_API.G_FALSE,
                p_ext_payee_tab       => ext_payee_tab,
                x_return_status       => l_pay_return_status,
                x_msg_count           => l_pay_msg_count,
                x_msg_data            => l_pay_msg_data,
                x_ext_payee_id_tab    => ext_payee_id_tab,
                x_ext_payee_status_tab => ext_payee_create_tab);
        IF l_pay_return_status = FND_API.G_RET_STS_SUCCESS THEN
          ------------------------------------------------------------------------
          l_debug_info := 'After call to IBY_DISBURSEMENT_SETUP_PUB.Create_External_Payee';
          l_debug_info := l_debug_info||' Return status : '||l_pay_return_status||' Error : '||l_pay_msg_data;
          ------------------------------------------------------------------------
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
          END IF;
        END IF;

    END IF;

    IF l_vendor_rec.party_id IS NOT NULL AND
       p_vendor_rec.vendor_type_lookup_code IS NOT NULL THEN

	zx_tcm_bes_registration_pvt.synch_ptp_code_assigment(
				p_party_id       => l_vendor_rec.party_id,
				p_class_category => 'SUPPLIER_TYPE',
				p_class_code     => p_vendor_rec.vendor_type_lookup_code,
				x_return_status  => l_zx_return_status,
				x_msg_count      => l_zx_msg_count,
				x_msg_data       => l_zx_msg_data );
			IF l_zx_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        ------------------------------------------------------------------------
        l_debug_info := 'After call to zx_tcm_bes_registration_pvt.synch_ptp_code_assigment';
        l_debug_info := l_debug_info||' Return status : '||l_zx_return_status||' Error : '||l_zx_msg_data;
        ------------------------------------------------------------------------
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;
      END IF;

    END IF;


   -- B 9202909 ... start
   l_party_id := nvl(l_vendor_rec.party_id,l_org_party_id);



       BEGIN
	   SELECT PROCESS_FOR_APPLICABILITY_FLAG, ALLOW_OFFSET_TAX_FLAG, TAX_CLASSIFICATION_CODE,
		   PARTY_TAX_PROFILE_ID
	     INTO l_auto_tax_calc_flag,l_offset_tax_flag, l_tax_classification_code,
		   L_PARTY_TAX_PROFILE_ID
            FROM ZX_PARTY_TAX_PROFILE
            WHERE PARTY_ID = l_party_id
            AND PARTY_TYPE_CODE = 'THIRD_PARTY'
            AND ROWNUM = 1;

          EXCEPTION
            WHEN OTHERS THEN
               L_PARTY_TAX_PROFILE_ID := NULL;
               l_debug_info := 'No data returned from ZX_PARTY_TAX_PROFILE for party_id = '||l_party_id;
               IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
               END IF;
       END;

       l_vendor_rec.OFFSET_TAX_FLAG := nvl(l_vendor_rec.OFFSET_TAX_FLAG, l_offset_tax_flag);
       l_vendor_rec.AUTO_TAX_CALC_FLAG := nvl(l_vendor_rec.AUTO_TAX_CALC_FLAG, l_auto_tax_calc_flag);
       l_vendor_rec.VAT_CODE := nvl(l_vendor_rec.VAT_CODE, l_tax_classification_code);

       l_offset_tax_flag :=  l_vendor_rec.OFFSET_TAX_FLAG;
       l_auto_tax_calc_flag := l_vendor_rec.AUTO_TAX_CALC_FLAG;
       l_tax_classification_code :=  l_vendor_rec.VAT_CODE;

       IF (l_vendor_rec.vat_registration_num is not null
         or l_auto_tax_calc_flag is not null or l_offset_tax_flag is not null -- Bug#7371143 zrehman
         or l_tax_classification_code is not null) THEN -- Bug#7642742

	IF L_PARTY_TAX_PROFILE_ID IS NOT NULL THEN

          ZX_PARTY_TAX_PROFILE_PKG.update_row (
          P_PARTY_TAX_PROFILE_ID => L_PARTY_TAX_PROFILE_ID,
           P_COLLECTING_AUTHORITY_FLAG => null,
           P_PROVIDER_TYPE_CODE => null,
           P_CREATE_AWT_DISTS_TYPE_CODE => null,
           P_CREATE_AWT_INVOICES_TYPE_COD => null,
           P_TAX_CLASSIFICATION_CODE => l_tax_classification_code, -- Bug#7506443 zrehman
           P_SELF_ASSESS_FLAG => null,
           P_ALLOW_OFFSET_TAX_FLAG => l_offset_tax_flag,-- Bug#7371143 zrehman
           P_REP_REGISTRATION_NUMBER => l_vendor_rec.vat_registration_num,
           P_EFFECTIVE_FROM_USE_LE => null,
           P_RECORD_TYPE_CODE => null,
           P_REQUEST_ID => null,
           P_ATTRIBUTE1 => null,
           P_ATTRIBUTE2 => null,
           P_ATTRIBUTE3 => null,
           P_ATTRIBUTE4 => null,
           P_ATTRIBUTE5 => null,
           P_ATTRIBUTE6 => null,
           P_ATTRIBUTE7 => null,
           P_ATTRIBUTE8 => null,
           P_ATTRIBUTE9 => null,
           P_ATTRIBUTE10 => null,
           P_ATTRIBUTE11 => null,
           P_ATTRIBUTE12 => null,
           P_ATTRIBUTE13 => null,
           P_ATTRIBUTE14 => null,
           P_ATTRIBUTE15 => null,
           P_ATTRIBUTE_CATEGORY => null,
           P_PARTY_ID => null,
           P_PROGRAM_LOGIN_ID => null,
           P_PARTY_TYPE_CODE => null,
           P_SUPPLIER_FLAG => null,
           P_CUSTOMER_FLAG => null,
           P_SITE_FLAG => null,
           P_PROCESS_FOR_APPLICABILITY_FL => l_auto_tax_calc_flag,-- Bug#7371143 zrehman
           P_ROUNDING_LEVEL_CODE => null,
           P_ROUNDING_RULE_CODE => null,
           P_WITHHOLDING_START_DATE => null,
           P_INCLUSIVE_TAX_FLAG => null,
           P_ALLOW_AWT_FLAG => null,
           P_USE_LE_AS_SUBSCRIBER_FLAG => null,
           P_LEGAL_ESTABLISHMENT_FLAG => null,
           P_FIRST_PARTY_LE_FLAG => null,
           P_REPORTING_AUTHORITY_FLAG => null,
           X_RETURN_STATUS => l_return_status,
           P_REGISTRATION_TYPE_CODE => null,
           P_COUNTRY_CODE => null
           );

           IF l_return_status <> fnd_api.g_ret_sts_success THEN
		l_debug_info := 'ZX_PARTY_TAX_PROFILE_PKG.update_row';
		l_debug_info := l_debug_info||' Return status : '||l_return_status;
		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            		FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
		END IF;
           END IF;
	END IF;
       END IF;
      -- B 9202909 ... end

   --bug 6371419.commented the below condition as it was checked already
   -- IF (l_val_return_status = FND_API.G_RET_STS_SUCCESS) AND
        IF      (l_org_return_status = FND_API.G_RET_STS_SUCCESS) AND
		(l_payee_valid = 'N' OR
		l_pay_return_status = FND_API.G_RET_STS_SUCCESS) THEN

	ap_vendors_pkg.insert_row(
		p_vendor_rec => l_vendor_rec
		,p_last_update_date => sysdate
		,p_last_updated_by => nvl(l_user_id,-1)
		,p_last_update_login => nvl(l_last_update_login,-1)
		,p_creation_date => sysdate
		,p_created_by => nvl(l_user_id,-1)
		,p_request_id => l_request_id
		,p_program_application_id => l_program_application_id
		,p_program_id => l_program_id
		,p_program_update_date => sysdate
		,x_rowid => l_row_id
        	,x_vendor_id => l_vendor_id);
        ------------------------------------------------------------------------
        l_debug_info := 'After call to ap_vendors_pkg.insert_row';
        ------------------------------------------------------------------------
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;

        --
        -- Added Call to Sync the Party Information into ap_supplier
        -- record for the performance reasons.
        --
        AP_TCA_SUPPLIER_SYNC_PKG.SYNC_Supplier(
                        l_sync_return_status,
                        l_sync_msg_count,
                        l_sync_msg_data,
                        l_vendor_rec.party_id);
        IF l_sync_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          ------------------------------------------------------------------------
          l_debug_info := 'After call to AP_TCA_SUPPLIER_SYNC_PKG.SYNC_Supplier';
          l_debug_info := l_debug_info||' Return status : '||l_sync_return_status||' Error : '||l_sync_msg_data;
          ------------------------------------------------------------------------
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
          END IF;
        END IF;

        IF l_sync_return_status = FND_API.G_RET_STS_SUCCESS THEN
           Raise_Supplier_Event( i_vendor_id => l_vendor_id ); -- Bug 7307669
	   x_return_status := FND_API.G_RET_STS_SUCCESS;
        END IF;
        -- Bug 5570585
	x_party_id := nvl(l_vendor_rec.party_id,l_org_party_id);
	x_vendor_id := l_vendor_id;

      END IF; --bug6371419.end of l_org_return_status SUCCESS

 ELSIF (l_val_return_status = FND_API.G_RET_STS_UNEXP_ERROR) OR
		(l_org_return_status = FND_API.G_RET_STS_UNEXP_ERROR) OR
		(l_pay_return_status = FND_API.G_RET_STS_UNEXP_ERROR) OR
                (l_sync_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN

	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

 ELSE

	x_return_status := FND_API.G_RET_STS_ERROR;
 END IF;  --Supplier Valid

    -- End of API body.

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
	COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1,
    -- get message info.
    FND_MSG_PUB.Count_And_Get(
	p_count         	=>      x_msg_count     	,
        p_data          	=>      x_msg_data
    	);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Create_Vendor_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Create_Vendor_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);
	WHEN OTHERS THEN
		ROLLBACK TO Create_Vendor_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);
END Create_Vendor;

PROCEDURE Update_Vendor
( 	p_api_version           IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	IN  	NUMBER	:=
						FND_API.G_VALID_LEVEL_FULL,
	x_return_status		OUT	NOCOPY VARCHAR2		  	,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_vendor_rec		IN	r_vendor_rec_type,
	p_vendor_id		IN	NUMBER
)
IS
    l_api_name			CONSTANT VARCHAR2(30)	:= 'Update_Vendor';
    l_api_version           	CONSTANT NUMBER 		:= 1.0;

    l_def_org_id		NUMBER;
    l_org_context		VARCHAR2(1);

    l_user_id                	number := FND_GLOBAL.USER_ID;
    l_last_update_login      	number := FND_GLOBAL.LOGIN_ID;
    l_program_application_id 	number := FND_GLOBAL.prog_appl_id;
    l_program_id             	number := FND_GLOBAL.conc_program_id;
    l_request_id             	number := FND_GLOBAL.conc_request_id;

    l_vendor_rec		r_vendor_rec_type;
    l_val_return_status                 VARCHAR2(50);
    l_val_msg_count                     NUMBER;
    l_val_msg_data                      VARCHAR2(1000);
    l_party_valid		VARCHAR2(1);
    l_payee_valid                       VARCHAR2(1);
    l_rowid			VARCHAR2(255);

    l_sync_return_status                 VARCHAR2(50);
    l_sync_msg_count                     NUMBER;
    l_sync_msg_data                      VARCHAR2(1000);
    l_org_party_id                       NUMBER;


BEGIN
	-- Standard Start of API savepoint
    SAVEPOINT	Update_Vendor_PUB;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
    THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_sync_return_status := FND_API.G_RET_STS_SUCCESS;


    -- API body

   /*
   If (FV_INSTALL.ENABLED(l_def_org_id)) THEN
      g_fed_fin_installed := 'Y';
   Else
	g_fed_fin_installed := 'N';
   End If;
   */

    l_vendor_rec := p_vendor_rec;

   validate_vendor(p_api_version => 1.0,
		p_init_msg_list => FND_API.G_FALSE,
		p_commit  => FND_API.G_FALSE,
		x_return_status => l_val_return_status,
		x_msg_count => l_val_msg_count,
		x_msg_data => l_val_msg_data,
		p_vendor_rec => l_vendor_rec,
		P_mode => 'U',
		P_calling_prog => 'NOT ISETUP',
		x_party_valid => l_party_valid,
		x_payee_valid => l_payee_valid,
		p_vendor_id => p_vendor_id );

    IF (l_val_return_status = FND_API.G_RET_STS_SUCCESS) THEN

	-- Select all the values needed to pass to update_row
	-- from PO_VENDORS
    	SELECT
		decode(l_vendor_rec.allow_awt_flag,
                   ap_null_char, NULL,
                   nvl(l_vendor_rec.allow_awt_flag, allow_awt_flag))
		,decode(l_vendor_rec.allow_substitute_receipts_flag,
                    ap_null_char, NULL,
                    nvl(l_vendor_rec.allow_substitute_receipts_flag,
                        allow_substitute_receipts_flag))
		,decode(l_vendor_rec.allow_unordered_receipts_flag,
                    ap_null_char, NULL,
                    nvl(l_vendor_rec.allow_unordered_receipts_flag,
                        allow_unordered_receipts_flag))
		,decode(l_vendor_rec.always_take_disc_flag,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.always_take_disc_flag,
                        always_take_disc_flag))
		,decode(l_vendor_rec.attribute_category,
                    ap_null_char, NULL,
                    nvl(l_vendor_rec.attribute_category,
                        attribute_category))
		,decode(l_vendor_rec.attribute1,
                    ap_null_char, NULL,
                   nvl(l_vendor_rec.attribute1, attribute1))
		,decode(l_vendor_rec.attribute10,
                    ap_null_char, NULL,
                   nvl(l_vendor_rec.attribute10, attribute10))
		,decode(l_vendor_rec.attribute11,
                    ap_null_char, NULL,
                   nvl(l_vendor_rec.attribute11, attribute11))
		,decode(l_vendor_rec.attribute12,
                    ap_null_char, NULL,
                   nvl(l_vendor_rec.attribute12, attribute12))
		,decode(l_vendor_rec.attribute13,
                    ap_null_char, NULL,
                   nvl(l_vendor_rec.attribute13, attribute13))
		,decode(l_vendor_rec.attribute14,
                    ap_null_char, NULL,
                   nvl(l_vendor_rec.attribute14, attribute14))
		,decode(l_vendor_rec.attribute15,
                    ap_null_char, NULL,
                   nvl(l_vendor_rec.attribute15, attribute15))
		,decode(l_vendor_rec.attribute2,
                    ap_null_char, NULL,
                   nvl(l_vendor_rec.attribute2, attribute2))
		,decode(l_vendor_rec.attribute3,
                    ap_null_char, NULL,
                   nvl(l_vendor_rec.attribute3, attribute3))
		,decode(l_vendor_rec.attribute4,
                    ap_null_char, NULL,
                   nvl(l_vendor_rec.attribute4, attribute4))
		,decode(l_vendor_rec.attribute5,
                    ap_null_char, NULL,
                   nvl(l_vendor_rec.attribute5, attribute5))
		,decode(l_vendor_rec.attribute6,
                    ap_null_char, NULL,
                   nvl(l_vendor_rec.attribute6, attribute6))
		,decode(l_vendor_rec.attribute7,
                    ap_null_char, NULL,
                   nvl(l_vendor_rec.attribute7, attribute7))
		,decode(l_vendor_rec.attribute8,
                    ap_null_char, NULL,
                   nvl(l_vendor_rec.attribute8, attribute8))
		,decode(l_vendor_rec.attribute9,
                    ap_null_char, NULL,
                   nvl(l_vendor_rec.attribute9, attribute9))
		,decode(l_vendor_rec.auto_calculate_interest_flag,
                    ap_null_char, NULL,
                    nvl(l_vendor_rec.auto_calculate_interest_flag,
                        auto_calculate_interest_flag))
		,decode(l_vendor_rec.awt_group_id,
                    ap_null_num,NULL,
                    nvl(l_vendor_rec.awt_group_id,
                        awt_group_id))
		,decode(l_vendor_rec.bank_charge_bearer,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.bank_charge_bearer,
                        bank_charge_bearer))
		,decode(l_vendor_rec.check_digits,
                    ap_null_char, NULL,
                    nvl(l_vendor_rec.check_digits,
                        check_digits))
		,decode(l_vendor_rec.create_debit_memo_flag,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.create_debit_memo_flag,
                        create_debit_memo_flag))
		,decode(l_vendor_rec.customer_num,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.customer_num,
                        customer_num))
		,decode(l_vendor_rec.days_early_receipt_allowed,
                    ap_null_num,NULL,
                    nvl(l_vendor_rec.days_early_receipt_allowed,
                        days_early_receipt_allowed))
		,decode(l_vendor_rec.days_late_receipt_allowed,
                    ap_null_num,NULL,
                    nvl(l_vendor_rec.days_late_receipt_allowed,
                        days_late_receipt_allowed))
		,decode(l_vendor_rec.employee_id,
                    ap_null_num,NULL,
                    nvl(l_vendor_rec.employee_id,
                        employee_id))
		,decode(l_vendor_rec.enabled_flag,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.enabled_flag,
                        enabled_flag))
		,decode(l_vendor_rec.end_date_active,
                    ap_null_date,NULL,
                    nvl(l_vendor_rec.end_date_active,
                        end_date_active))
		,decode(l_vendor_rec.enforce_ship_to_location_code,
                    ap_null_char, NULL,
                    nvl(l_vendor_rec.enforce_ship_to_location_code,
                        enforce_ship_to_location_code ))
		,decode(l_vendor_rec.exclude_freight_from_discount,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.exclude_freight_from_discount,
                        exclude_freight_from_discount))
		,decode(l_vendor_rec.federal_reportable_flag,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.federal_reportable_flag,
                        federal_reportable_flag))
		,decode(l_vendor_rec.global_attribute_category,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.global_attribute_category,
                        global_attribute_category))
		,decode(l_vendor_rec.global_attribute1,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.global_attribute1,
                        global_attribute1))
		,decode(l_vendor_rec.global_attribute2,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.global_attribute2,
                        global_attribute2))
		,decode(l_vendor_rec.global_attribute3,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.global_attribute3,
                        global_attribute3))
		,decode(l_vendor_rec.global_attribute4,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.global_attribute4,
                        global_attribute4))
		,decode(l_vendor_rec.global_attribute5,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.global_attribute5,
                        global_attribute5))
		,decode(l_vendor_rec.global_attribute6,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.global_attribute6,
                        global_attribute6))
		,decode(l_vendor_rec.global_attribute7,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.global_attribute7,
                        global_attribute7))
		,decode(l_vendor_rec.global_attribute8,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.global_attribute8,
                        global_attribute8))
		,decode(l_vendor_rec.global_attribute9,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.global_attribute9,
                        global_attribute9))
		,decode(l_vendor_rec.global_attribute10,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.global_attribute10,
                        global_attribute10))
		,decode(l_vendor_rec.global_attribute11,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.global_attribute11,
                        global_attribute11))
		,decode(l_vendor_rec.global_attribute12,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.global_attribute12,
                        global_attribute12))
		,decode(l_vendor_rec.global_attribute13,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.global_attribute13,
                        global_attribute13))
		,decode(l_vendor_rec.global_attribute14,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.global_attribute14,
                        global_attribute14))
		,decode(l_vendor_rec.global_attribute15,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.global_attribute15,
                        global_attribute15))
		,decode(l_vendor_rec.global_attribute16,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.global_attribute16,
                        global_attribute16))
		,decode(l_vendor_rec.global_attribute17,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.global_attribute17,
                        global_attribute17))
		,decode(l_vendor_rec.global_attribute18,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.global_attribute18,
                        global_attribute18))
		,decode(l_vendor_rec.global_attribute19,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.global_attribute19,
                        global_attribute19))
		,decode(l_vendor_rec.global_attribute20,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.global_attribute20,
                        global_attribute20))
		,decode(l_vendor_rec.hold_all_payments_flag,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.hold_all_payments_flag,
                        hold_all_payments_flag))
		,decode(l_vendor_rec.hold_by,
                    ap_null_num, NULL,
                    nvl(l_vendor_rec.hold_by, hold_by))
		,decode(l_vendor_rec.hold_date,
                    ap_null_date,NULL,
                    nvl(l_vendor_rec.hold_date, hold_date))
		,decode(l_vendor_rec.hold_flag,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.hold_flag, hold_flag))
		,decode(l_vendor_rec.hold_future_payments_flag,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.hold_future_payments_flag,
                        hold_future_payments_flag))
		,decode(l_vendor_rec.hold_reason,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.hold_reason, hold_reason))
		,decode(l_vendor_rec.hold_unmatched_invoices_flag,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.hold_unmatched_invoices_flag,
                        hold_unmatched_invoices_flag))
		,decode(l_vendor_rec.inspection_required_flag,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.inspection_required_flag,
                        inspection_required_flag ))
		,decode(l_vendor_rec.invoice_amount_limit,
                    ap_null_num, NULL,
                    nvl(l_vendor_rec.invoice_amount_limit,
                        invoice_amount_limit))
		,decode(l_vendor_rec.invoice_currency_code,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.invoice_currency_code,
                        invoice_currency_code))
		,decode(l_vendor_rec.match_option,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.match_option, match_option))
		,decode(l_vendor_rec.min_order_amount,
                    ap_null_num,NULL,
                    nvl(l_vendor_rec.min_order_amount,
                        min_order_amount))
		,decode(l_vendor_rec.minority_group_lookup_code,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.minority_group_lookup_code,
                        minority_group_lookup_code))
		,decode(l_vendor_rec.name_control,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.name_control, name_control))
		,decode(l_vendor_rec.one_time_flag,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.one_time_flag, one_time_flag ))
		,decode(l_vendor_rec.organization_type_lookup_code,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.organization_type_lookup_code,
                        organization_type_lookup_code))
		,decode(l_vendor_rec.parent_vendor_id,
                    ap_null_num,NULL,
                    nvl(l_vendor_rec.parent_vendor_id,
                        parent_vendor_id))
		,decode(l_vendor_rec.parent_party_id,
                    ap_null_num,NULL,
                    nvl(l_vendor_rec.parent_party_id,
                        parent_party_id))
		,decode(l_vendor_rec.party_id,
                    ap_null_num,NULL,
                    nvl(l_vendor_rec.party_id, party_id))
		,decode(l_vendor_rec.pay_date_basis_lookup_code,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.pay_date_basis_lookup_code,
                        pay_date_basis_lookup_code))
		,decode(l_vendor_rec.pay_group_lookup_code,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.pay_group_lookup_code,
                        pay_group_lookup_code))
		,decode(l_vendor_rec.payment_currency_code,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.payment_currency_code,
                        payment_currency_code))
		,decode(l_vendor_rec.payment_priority,
                    ap_null_num,NULL,
                    nvl(l_vendor_rec.payment_priority,
                        payment_priority))
		,decode(l_vendor_rec.purchasing_hold_reason,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.purchasing_hold_reason,
                        purchasing_hold_reason))
		,decode(l_vendor_rec.qty_rcv_exception_code,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.qty_rcv_exception_code,
                        qty_rcv_exception_code))
		,decode(l_vendor_rec.qty_rcv_tolerance,
                    ap_null_num,NULL,
                    nvl(l_vendor_rec.qty_rcv_tolerance,
                        qty_rcv_tolerance))
		,decode(l_vendor_rec.receipt_days_exception_code,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.receipt_days_exception_code,
                        receipt_days_exception_code))
		,decode(l_vendor_rec.receipt_required_flag,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.receipt_required_flag,
                        receipt_required_flag))
		,decode(l_vendor_rec.receiving_routing_id,
                    ap_null_num,NULL,
                    nvl(l_vendor_rec.receiving_routing_id,
                        receiving_routing_id))
		,decode(l_vendor_rec.segment1,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.segment1, segment1 ))
		,decode(l_vendor_rec.segment2,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.segment2, segment2 ))
		,decode(l_vendor_rec.segment3,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.segment3, segment3 ))
		,decode(l_vendor_rec.segment4,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.segment4, segment4 ))
		,decode(l_vendor_rec.segment5,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.segment5, segment5 ))
		,decode(l_vendor_rec.set_of_books_id,
                    ap_null_num,NULL,
                    nvl(l_vendor_rec.set_of_books_id,
                        set_of_books_id))
		,decode(l_vendor_rec.small_business_flag,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.small_business_flag,
                        small_business_flag ))
		,decode(l_vendor_rec.start_date_active,
                    ap_null_date,NULL,
                    nvl(l_vendor_rec.start_date_active,
                        start_date_active))
		,decode(l_vendor_rec.state_reportable_flag,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.state_reportable_flag,
                        state_reportable_flag))
		,decode(l_vendor_rec.summary_flag,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.summary_flag, summary_flag))
		,decode(l_vendor_rec.tax_reporting_name,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.tax_reporting_name,
                        tax_reporting_name))
		,decode(l_vendor_rec.tax_verification_date,
                    ap_null_date,NULL,
                    nvl(l_vendor_rec.tax_verification_date,
                        tax_verification_date))
		,decode(l_vendor_rec.terms_date_basis,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.terms_date_basis,
                        terms_date_basis))
		,decode(l_vendor_rec.terms_id,
                    ap_null_num,NULL,
                    nvl(l_vendor_rec.terms_id, terms_id ))
                --bug6050423 starts.system inserts taxpayer id
                --of individual contractors into ap_suppliers
                ,decode(l_vendor_rec.jgzz_fiscal_code,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.jgzz_fiscal_code,nvl(individual_1099,num_1099)))
                --bug6050423 ends
		,decode(l_vendor_rec.type_1099,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.type_1099, type_1099))
        ,decode(l_vendor_rec.validation_number,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.validation_number,
					validation_number))
        ,decode(l_vendor_rec.vendor_type_lookup_code,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.vendor_type_lookup_code,
					vendor_type_lookup_code))
        ,decode(l_vendor_rec.withholding_start_date,
                    ap_null_date,NULL,
                    nvl(l_vendor_rec.withholding_start_date,
					withholding_start_date))
        ,decode(l_vendor_rec.withholding_status_lookup_code,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.withholding_status_lookup_code,
					withholding_status_lookup_code))
        ,decode(l_vendor_rec.women_owned_flag,
                    ap_null_char,NULL,
                    nvl(l_vendor_rec.women_owned_flag,women_owned_flag))
		-- bug7561758
		,decode(l_vendor_rec.pay_awt_group_id,
                    ap_null_num,NULL,
                    nvl(l_vendor_rec.pay_awt_group_id,
                        pay_awt_group_id))
		,rowid
	INTO
		l_vendor_rec.allow_awt_flag
		,l_vendor_rec.allow_substitute_receipts_flag
		,l_vendor_rec.allow_unordered_receipts_flag
		,l_vendor_rec.always_take_disc_flag
		,l_vendor_rec.attribute_category
		,l_vendor_rec.attribute1
		,l_vendor_rec.attribute10
		,l_vendor_rec.attribute11
		,l_vendor_rec.attribute12
		,l_vendor_rec.attribute13
		,l_vendor_rec.attribute14
		,l_vendor_rec.attribute15
		,l_vendor_rec.attribute2
		,l_vendor_rec.attribute3
		,l_vendor_rec.attribute4
		,l_vendor_rec.attribute5
		,l_vendor_rec.attribute6
		,l_vendor_rec.attribute7
		,l_vendor_rec.attribute8
		,l_vendor_rec.attribute9
		,l_vendor_rec.auto_calculate_interest_flag
		,l_vendor_rec.awt_group_id
		,l_vendor_rec.bank_charge_bearer
		,l_vendor_rec.check_digits
		,l_vendor_rec.create_debit_memo_flag
		,l_vendor_rec.customer_num
		,l_vendor_rec.days_early_receipt_allowed
		,l_vendor_rec.days_late_receipt_allowed
	    ,l_vendor_rec.employee_id
		,l_vendor_rec.enabled_flag
		,l_vendor_rec.end_date_active
		,l_vendor_rec.enforce_ship_to_location_code
		,l_vendor_rec.exclude_freight_from_discount
		,l_vendor_rec.federal_reportable_flag
		,l_vendor_rec.global_attribute_category
		,l_vendor_rec.global_attribute1
		,l_vendor_rec.global_attribute2
		,l_vendor_rec.global_attribute3
		,l_vendor_rec.global_attribute4
		,l_vendor_rec.global_attribute5
		,l_vendor_rec.global_attribute6
		,l_vendor_rec.global_attribute7
		,l_vendor_rec.global_attribute8
		,l_vendor_rec.global_attribute9
		,l_vendor_rec.global_attribute10
		,l_vendor_rec.global_attribute11
		,l_vendor_rec.global_attribute12
		,l_vendor_rec.global_attribute13
		,l_vendor_rec.global_attribute14
		,l_vendor_rec.global_attribute15
		,l_vendor_rec.global_attribute16
		,l_vendor_rec.global_attribute17
		,l_vendor_rec.global_attribute18
		,l_vendor_rec.global_attribute19
		,l_vendor_rec.global_attribute20
		,l_vendor_rec.hold_all_payments_flag
		,l_vendor_rec.hold_by
		,l_vendor_rec.hold_date
		,l_vendor_rec.hold_flag
		,l_vendor_rec.hold_future_payments_flag
		,l_vendor_rec.hold_reason
		,l_vendor_rec.hold_unmatched_invoices_flag
		,l_vendor_rec.inspection_required_flag
		,l_vendor_rec.invoice_amount_limit
		,l_vendor_rec.invoice_currency_code
		,l_vendor_rec.match_option
		,l_vendor_rec.min_order_amount
		,l_vendor_rec.minority_group_lookup_code
		,l_vendor_rec.name_control
		,l_vendor_rec.one_time_flag
		,l_vendor_rec.organization_type_lookup_code
		,l_vendor_rec.parent_vendor_id
		,l_vendor_rec.parent_party_id
		,l_vendor_rec.party_id
		,l_vendor_rec.pay_date_basis_lookup_code
		,l_vendor_rec.pay_group_lookup_code
		,l_vendor_rec.payment_currency_code
		,l_vendor_rec.payment_priority
		,l_vendor_rec.purchasing_hold_reason
		,l_vendor_rec.qty_rcv_exception_code
		,l_vendor_rec.qty_rcv_tolerance
		,l_vendor_rec.receipt_days_exception_code
		,l_vendor_rec.receipt_required_flag
		,l_vendor_rec.receiving_routing_id
		,l_vendor_rec.segment1
		,l_vendor_rec.segment2
		,l_vendor_rec.segment3
		,l_vendor_rec.segment4
		,l_vendor_rec.segment5
		,l_vendor_rec.set_of_books_id
		,l_vendor_rec.small_business_flag
		,l_vendor_rec.start_date_active
		,l_vendor_rec.state_reportable_flag
		,l_vendor_rec.summary_flag
		,l_vendor_rec.tax_reporting_name
		,l_vendor_rec.tax_verification_date
		,l_vendor_rec.terms_date_basis
		,l_vendor_rec.terms_id
        ,l_vendor_rec.jgzz_fiscal_code --bug6050423
		,l_vendor_rec.type_1099
		,l_vendor_rec.validation_number
		,l_vendor_rec.vendor_type_lookup_code
		,l_vendor_rec.withholding_start_date
		,l_vendor_rec.withholding_status_lookup_code
		,l_vendor_rec.women_owned_flag
		,l_vendor_rec.pay_awt_group_id         -- bug7561758
		,l_rowid
    	FROM po_vendors
    	WHERE vendor_id = p_vendor_id;

	ap_vendors_pkg.update_row(
		p_vendor_rec => l_vendor_rec,
		p_last_update_date => sysdate,
		p_last_updated_by => l_user_id,
		p_last_update_login => l_last_update_login,
		p_request_id => l_request_id ,
		p_program_application_id => l_program_application_id,
		p_program_id => l_program_id,
		p_program_update_date => sysdate,
		p_rowid => l_rowid,
        	p_vendor_id => p_vendor_id);

        --
        -- Added Call to Sync the Party Information into ap_supplier
        -- record for the performance reasons.
        --

        AP_TCA_SUPPLIER_SYNC_PKG.SYNC_Supplier(
                        l_sync_return_status,
                        l_sync_msg_count,
                        l_sync_msg_data,
                        l_vendor_rec.party_id);

	IF l_sync_return_status = FND_API.G_RET_STS_SUCCESS THEN
	   Raise_Supplier_Event( i_vendor_id => p_vendor_id ); -- Bug 7307669
           x_return_status := FND_API.G_RET_STS_SUCCESS;
        END IF;

    ELSIF (l_val_return_status = FND_API.G_RET_STS_UNEXP_ERROR OR
           l_sync_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN

	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    ELSE

	x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    --set access mode back to original value
    IF l_org_context <> mo_global.get_access_mode THEN
    	MO_GLOBAL.set_policy_context(l_org_context,l_def_org_id);
    END IF;

    -- End of API body.

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
	COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1,
    -- get message info.
    FND_MSG_PUB.Count_And_Get(
	p_count         	=>      x_msg_count     	,
        p_data          	=>      x_msg_data
    	);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Update_Vendor_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Update_Vendor_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);
	WHEN OTHERS THEN
		ROLLBACK TO Update_Vendor_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);
END Update_Vendor;

PROCEDURE Validate_Vendor
( 	p_api_version           IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	IN  	NUMBER	:=
						FND_API.G_VALID_LEVEL_FULL,
	x_return_status		OUT	NOCOPY VARCHAR2		  	,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_vendor_rec		IN OUT	NOCOPY r_vendor_rec_type,
	p_mode			IN	VARCHAR2,
	p_calling_prog		IN	VARCHAR2,
	x_party_valid		OUT	NOCOPY VARCHAR2,
	x_payee_valid		OUT 	NOCOPY VARCHAR2,
	p_vendor_id		IN	NUMBER

)
IS
    l_api_name			CONSTANT VARCHAR2(30)	:= 'Validate_Vendor';
    l_api_version           	CONSTANT NUMBER 		:= 1.0;

    l_def_org_id		NUMBER;
    l_debug_info		VARCHAR2(2000);
    x_valid			BOOLEAN;
    l_segment1			VARCHAR2(30);
    l_payee_return_status	VARCHAR2(50);
    l_payee_msg_count		NUMBER;
    l_payee_msg_data		VARCHAR2(1000);
    l_default_country_code      VARCHAR2(25); --bug6050423
    l_msg_count      NUMBER; --bug 7572325
    l_msg_data       varchar2(4000); --bug 7572325
    l_error_code     VARCHAR2(4000); --bug 7572325
    l_status                    NUMBER ; -- B 9202909

BEGIN
	-- Standard Start of API savepoint
    SAVEPOINT	Validate_Vendor_PUB;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
    THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- API body

    -- Open Issue 7 Call eTax Validation

    ------------------------------------------------------------------------
    l_debug_info := 'Call to Validate inspection_required_flag';
    ------------------------------------------------------------------------
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    --
    -- Validate inspection_required_flag
    --
    IF p_vendor_rec.inspection_required_flag is NOT NULL
       AND p_vendor_rec.inspection_required_flag <> ap_null_char THEN

      Validate_Lookups( 'INSPECTION_REQUIRED_FLAG', p_vendor_rec.inspection_required_flag,'YES/NO',
                                    'PO_LOOKUP_CODES',x_valid);
      IF NOT x_valid THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF g_source = 'IMPORT' THEN
          IF (Insert_Rejections(
                    'AP_SUPPLIERS_INT',
                    p_vendor_rec.vendor_interface_id,
                    'AP_INVALID_INSP_REQ_FLAG',
                    g_user_id,
                    g_login_id,
                    'Validate_Vendor') <> TRUE) THEN
           --
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                   l_api_name,'Parameters: '
                   ||' Vendor_Interface_Id: '||p_vendor_rec.vendor_interface_id
                   ||' ,Inspection_Required_Flag: '||p_vendor_rec.inspection_required_flag);
            END IF;
          END IF;
         ELSE
            -- Bug 5491139 hkaniven start --
          FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_INSP_REQ_FLAG');
          FND_MSG_PUB.ADD;
            -- Bug 5491139 hkaniven end --
        END IF;
      END IF;
    END IF;


   -- B 9202909 ... start
    -- Bug 6645014 starts: To import Vat code
    ------------------------------------------------------------------------
    l_debug_info := 'Call to Validate vat_code';
    ------------------------------------------------------------------------
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    END IF;
    --
    -- Validate vat_code
    --
    IF p_vendor_rec.vat_code is NOT NULL THEN
    -- Checking the vat code in the tax tables
          l_status := 0;
          SELECT COUNT(*)  INTO l_status FROM DUAL WHERE EXISTS (
            SELECT 'Y'
            FROM zx_input_classifications_v
            WHERE lookup_type in ('ZX_INPUT_CLASSIFICATIONS', 'ZX_WEB_EXP_TAX_CLASSIFICATIONS')
            AND org_id = -99
            AND enabled_flag = 'Y'
            AND LOOKUP_CODE = p_vendor_rec.VAT_CODE );


      IF l_status = 0  THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF g_source = 'IMPORT' THEN
          IF (Insert_Rejections(
                'AP_SUPPLIERS_INT',
                p_vendor_rec.vendor_interface_id,
                'AP_INVALID_VAT_CODE',
                g_user_id,
                g_login_id,
                'Validate_Vendor') <> TRUE) THEN
            --
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                l_api_name,'Parameters: '
                ||' Vendor_Interface_Id: '||p_vendor_rec.vendor_interface_id
                ||' ,Vat_Code: '
                ||p_vendor_rec.vat_code);
            END IF;
          END IF;
        ELSE
            FND_MESSAGE.SET_NAME('SQLAP', 'AP_INVALID_VAT_CODE');
            FND_MSG_PUB.ADD;
            -- Bug 8438716 Start
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                l_api_name,'After call to VAT_CODE validation... Parameters: '
                ||' Vendor_Interface_Id: '||p_vendor_rec.vendor_interface_id
                ||' ,Vat_Code: '
                ||p_vendor_rec.vat_code);
            END IF;
            -- Bug 8438716 End
        END IF;
      END IF;
    END IF;
    -- Bug 6645014 ends
   -- B 9202909 ... end

    ------------------------------------------------------------------------
    l_debug_info := 'Call to Validate receipt_required_flag';
    ------------------------------------------------------------------------
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME|| l_api_name,l_debug_info);
    END IF;
    --
    -- Validate receipt_required_flag
    --
    IF p_vendor_rec.receipt_required_flag is NOT NULL
       AND p_vendor_rec.receipt_required_flag <> ap_null_char THEN

      Validate_Lookups( 'RECEIPT_REQUIRED_FLAG', p_vendor_rec.receipt_required_flag,'YES/NO',
                                    'PO_LOOKUP_CODES',x_valid);
      IF NOT x_valid THEN
      	x_return_status := FND_API.G_RET_STS_ERROR;
        IF g_source = 'IMPORT' THEN
          IF (Insert_Rejections(
                    'AP_SUPPLIERS_INT',
                    p_vendor_rec.vendor_interface_id,
                    'AP_INVALID_REC_REQ_FLAG',
                    g_user_id,
                    g_login_id,
                    'Validate_Vendor') <> TRUE) THEN
           --
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                   l_api_name,'Parameters: '
                   ||' Vendor_Interface_Id: '||p_vendor_rec.vendor_interface_id
                   ||' ,Receipt_Required_Flag: '||p_vendor_rec.receipt_required_flag);
            END IF;
          END IF;

        ELSE
            -- Bug 5491139 hkaniven start --
            FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_REC_REQ_FLAG');
            FND_MSG_PUB.ADD;
            -- Bug 5491139 hkaniven end --
        END IF;
      END IF;
    END IF;

    ------------------------------------------------------------------------
    l_debug_info := 'Call to Validate Payment_Priority';
    ------------------------------------------------------------------------
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    END IF;
    --
    -- Validate Payment_Priority
    --
    IF p_vendor_rec.payment_priority is NOT NULL
       AND p_vendor_rec.payment_priority <> ap_null_num THEN

      Check_payment_priority(p_vendor_rec.payment_priority,
                             x_valid
                            );
      IF NOT x_valid THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF g_source = 'IMPORT' THEN
          IF (Insert_Rejections(
                    'AP_SUPPLIERS_INT',
                    p_vendor_rec.vendor_interface_id,
                    'AP_INVALID_PAYMENT_PRIORITY',
                    g_user_id,
                    g_login_id,
                    'Validate_Vendor') <> TRUE) THEN
           --
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                   l_api_name,'Parameters: '
                   ||' Vendor_Interface_Id: '||p_vendor_rec.vendor_interface_id
                   ||' ,Payment_Priority: '||p_vendor_rec.payment_priority);
            END IF;
          END IF;
        ELSE
            -- Bug 5491139 hkaniven start --
            FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_PAYMENT_PRIORITY');
            FND_MSG_PUB.ADD;
            -- Bug 5491139 hkaniven end --
        END IF;
      END IF;
    END IF;

    ------------------------------------------------------------------------
    l_debug_info := 'Call to Validate the 1099_type value';
    ------------------------------------------------------------------------
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    END IF;
    --
    -- Validate the 1099_type value
    --
    IF p_vendor_rec.type_1099 IS NOT NULL
       AND p_vendor_rec.type_1099 <> ap_null_char THEN
      Check_Valid_1099_type(p_vendor_rec.type_1099,
                            p_vendor_rec.federal_reportable_flag,
                            x_valid
                           );
      IF NOT x_valid THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF g_source = 'IMPORT' THEN
          IF (Insert_Rejections(
                    'AP_SUPPLIERS_INT',
                    p_vendor_rec.vendor_interface_id,
                    'AP_INCONSISTENT_1099_TYPE',
                    g_user_id,
                    g_login_id,
                    'Validate_Vendor') <> TRUE) THEN
           --
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                   l_api_name,'Parameters: '
                   ||' Vendor_Interface_Id: '||p_vendor_rec.vendor_interface_id
                   ||' ,Type_1099: '||p_vendor_rec.type_1099
                   ||' ,Federal_Reportable_Flag: '||p_vendor_rec.federal_reportable_flag);
            END IF;
          END IF;
        ELSE
            -- Bug 5491139 hkaniven start --
            FND_MESSAGE.SET_NAME('SQLAP','AP_INCONSISTENT_1099_TYPE');
            FND_MSG_PUB.ADD;
            -- Bug 5491139 hkaniven end --
        END IF;
      END IF;
    END IF;

    --bug6050423.Added the below validation for num_1099 for
    --contractor individuals
    --bug6691916.commented the below if clause and added the one below that.
    --as per analysis,only organization lookup code of type individual
    --and foreign individual belong to individual suppliers category.

  /* if ( UPPER(p_vendor_rec.vendor_type_lookup_code)='CONTRACTOR'
        AND UPPER(p_vendor_rec.organization_type_lookup_code) IN
                ('INDIVIDUAL','FOREIGN INDIVIDUAL',
                'PARTNERSHIP','FOREIGN PARTNERSHIP') )THEN*/
    if ( UPPER(p_vendor_rec.organization_type_lookup_code) IN
                ('INDIVIDUAL','FOREIGN INDIVIDUAL') )THEN
    ------------------------------------------------------------------------
    l_debug_info := 'Call to Validate the jgzz_fiscal_code value';
    ------------------------------------------------------------------------
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    END IF;
    --
    -- Validate the jgzz_fiscal_code value
    --


    fnd_profile.get('DEFAULT_COUNTRY',l_default_country_code);

    IF( l_default_country_code is null
        AND
        p_vendor_rec.set_of_books_id IS NOT NULL) then

	-- Commented for Bug 6852552

	/*
	SELECT   FIN.vat_country_code
        INTO     l_default_country_code
        FROM     FINANCIALS_SYSTEM_PARAMS_ALL FIN,
                 AP_SYSTEM_PARAMETERS_ALL ASP
        WHERE    ASP.set_of_books_id=p_vendor_rec.set_of_books_id
        AND      FIN.org_id = ASP.org_id;
	*/

	-- Added for Bug 6852552
        IF g_source = 'IMPORT' THEN
          IF (Insert_Rejections(
                    'AP_SUPPLIERS_INT',
                    p_vendor_rec.vendor_interface_id,
                    'AP_DEFAULT_COUNTRY_CODE_NULL',
                    g_user_id,
                    g_login_id,
                    'Validate_Vendor') <> TRUE) THEN
           --
        	IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                   l_api_name,'Default Country is Null');
           	END IF;
          END IF;

        ELSE
            FND_MESSAGE.SET_NAME('SQLAP','AP_DEFAULT_COUNTRY_CODE_NULL');
            FND_MSG_PUB.ADD;
        END IF;

	-- End of Bug 6852552
    END IF;

    IF p_vendor_rec.jgzz_fiscal_code IS NOT NULL
       AND p_vendor_rec.jgzz_fiscal_code <> ap_null_char
       AND l_default_country_code IS NOT NULL  THEN

      IF(is_taxpayer_id_valid(p_vendor_rec.jgzz_fiscal_code,
                              l_default_country_code) = 'N') THEN

         x_return_status := FND_API.G_RET_STS_ERROR;
        IF g_source = 'IMPORT' THEN
          IF (Insert_Rejections(
                    'AP_SUPPLIERS_INT',
                    p_vendor_rec.vendor_interface_id,
                    'AP_INVALID_TAXPAYER_ID',
                    g_user_id,
                    g_login_id,
                    'Validate_Vendor') <> TRUE) THEN
           --
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                   l_api_name,'Parameters: '
                   ||' Vendor_Interface_Id: '||p_vendor_rec.vendor_interface_id
                   ||' ,NUM_1099: '||p_vendor_rec.jgzz_fiscal_code
                   ||' ,Federal_Reportable_Flag: '||p_vendor_rec.federal_reportable_flag);
            END IF;
          END IF;
        ELSE
            FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_TAXPAYER_ID');
            FND_MSG_PUB.ADD;
        END IF;
      END IF;
    END IF;

  END IF;--end check for contractor type suppliers
  --bug6050423 ends

    ------------------------------------------------------------------------
    l_debug_info := 'Call to Validate the Employee_Id';
    ------------------------------------------------------------------------
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    END IF;
    --
    -- Employee_Id validation
    --
         -- start added by abhsaxen for bug 7147735
      IF (p_vendor_rec.employee_id is null AND
      UPPER(p_vendor_rec.vendor_type_lookup_code)='EMPLOYEE') THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
          IF g_source = 'IMPORT' THEN
            IF (Insert_Rejections(
                      'AP_SUPPLIERS_INT',
                      p_vendor_rec.vendor_interface_id,
                      'AP_INVALID_EMPLOYEE_ID',
                      g_user_id,
                      g_login_id,
                      'Validate_Vendor') <> TRUE) THEN
              IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                     l_api_name,'Parameters: '
                     ||' Vendor_Interface_Id: '||p_vendor_rec.vendor_interface_id
                     ||' ,Vendor_Type_Lookup_Code: '||p_vendor_rec.vendor_type_lookup_code
                     ||' ,Employee_Id: NULL');
              END IF;
            END IF;
          ELSE
              FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_EMPLOYEE_ID');
              FND_MSG_PUB.ADD;
          END IF;
      END IF;
      -- end added by abhsaxen for bug 7147735
    IF p_vendor_rec.employee_id is NOT NULL
       AND p_vendor_rec.employee_id <> fnd_api.g_miss_num THEN
      Check_Valid_Employee (p_vendor_rec.employee_id,
                            x_valid);
      IF NOT x_valid THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF g_source = 'IMPORT' THEN
          IF (Insert_Rejections(
                    'AP_SUPPLIERS_INT',
                    p_vendor_rec.vendor_interface_id,
                    'AP_INVALID_EMPLOYEE_ID',
                    g_user_id,
                    g_login_id,
                    'Validate_Vendor') <> TRUE) THEN
           --
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                   l_api_name,'Parameters: '
                   ||' Vendor_Interface_Id: '||p_vendor_rec.vendor_interface_id
                   ||' ,Employee_Id: '||p_vendor_rec.employee_id);
            END IF;
          END IF;
        ELSE
            -- Bug 5491139 hkaniven start --
            FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_EMPLOYEE_ID');
            FND_MSG_PUB.ADD;
            -- Bug 5491139 hkaniven end --
        END IF;
      END IF;
      -- start added by abhsaxen for bug 7147735
     IF x_valid THEN
      BEGIN
         SELECT PPF.PARTY_ID
          INTO P_VENDOR_REC.PARTY_ID
         FROM   PER_PEOPLE_F PPF
         WHERE  PPF.PERSON_ID  = P_VENDOR_REC.EMPLOYEE_ID
         AND TRUNC(SYSDATE) BETWEEN
           TRUNC(ppf.effective_start_date) AND
           TRUNC(ppf.effective_end_date);
      EXCEPTION
        WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
          IF g_source = 'IMPORT' THEN
            IF (Insert_Rejections(
                      'AP_SUPPLIERS_INT',
                      p_vendor_rec.vendor_interface_id,
                      'AP_INVALID_EMPLOYEE_ID',
                      g_user_id,
                      g_login_id,
                      'Validate_Vendor') <> TRUE) THEN
             --
              IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                     l_api_name,'Parameters: '
                     ||' Vendor_Interface_Id: '||p_vendor_rec.vendor_interface_id
                     ||' ,Vendor_Type_Lookup_Code: '||p_vendor_rec.vendor_type_lookup_code
                     ||' ,Not able to get Party Id From Employee Id.');
              END IF;
            END IF;
          ELSE
              FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_EMPLOYEE_ID');
              FND_MSG_PUB.ADD;
          END IF;
      END;
      -- end added by abhsaxen for bug 7147735
    END IF;
    END IF;

    ------------------------------------------------------------------------
    l_debug_info := 'Call to Validate inspection_required_flag and receipt_required_flag';
    ------------------------------------------------------------------------
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    END IF;
   --
   -- Validate inspection_required_flag and receipt_required_flag
   --
   IF (p_vendor_rec.inspection_required_flag is NOT NULL AND
       p_vendor_rec.receipt_required_flag is NOT NULL AND
       p_vendor_rec.inspection_required_flag <> ap_null_char AND
       p_vendor_rec.receipt_required_flag <> ap_null_char) THEN

    	Check_Valid_match_level(p_vendor_rec.inspection_required_flag,
                            p_vendor_rec.receipt_required_flag,
                            x_valid
                            );
      IF NOT x_valid THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF g_source = 'IMPORT' THEN
          IF (Insert_Rejections(
                    'AP_SUPPLIERS_INT',
                    p_vendor_rec.vendor_interface_id,
                    'AP_INCONSISTENT_INSPEC_RECEIPT',
                    g_user_id,
                    g_login_id,
                    'Validate_Vendor') <> TRUE) THEN
           --
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                   l_api_name,'Parameters: '
                   ||' Vendor_Interface_Id: '||p_vendor_rec.vendor_interface_id
                   ||' ,Inspection_Required_Flag: '||p_vendor_rec.inspection_required_flag
                   ||' ,Receipt_Required_Flag: '||p_vendor_rec.receipt_required_flag);
            END IF;
          END IF;
        ELSE
            -- Bug 5491139 hkaniven start --
            FND_MESSAGE.SET_NAME('SQLAP','AP_INCONSISTENT_INSPEC_RECEIPT');
            FND_MSG_PUB.ADD;
            -- Bug 5491139 hkaniven end --
        END IF;
      END IF;
    END IF;

    ------------------------------------------------------------------------
    l_debug_info := 'Call to Validate Name Control';
    ------------------------------------------------------------------------
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    END IF;
    --
    -- Validate the Name Control value
    --
    IF p_vendor_rec.name_control IS NOT NULL
       AND p_vendor_rec.name_control <> ap_null_char THEN
     	Check_Valid_name_control(p_vendor_rec.name_control,
                             x_valid);
       IF NOT x_valid THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF g_source = 'IMPORT' THEN
          IF (Insert_Rejections(
                    'AP_SUPPLIERS_INT',
                    p_vendor_rec.vendor_interface_id,
                    'AP_INVALID_NAME_CONTROL',
                    g_user_id,
                    g_login_id,
                    'Validate_Vendor') <> TRUE) THEN
           --
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                   l_api_name,'Parameters: '
                   ||' Vendor_Interface_Id: '||p_vendor_rec.vendor_interface_id
                   ||' ,Name_Control: '||p_vendor_rec.name_control);
            END IF;
          END IF;
        ELSE
            -- Bug 5491139 hkaniven start --
            FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_NAME_CONTROL');
            FND_MSG_PUB.ADD;
            -- Bug 5491139 hkaniven end --
        END IF;
      END IF;
    END IF;

/*
    ------------------------------------------------------------------------
    l_debug_info := 'Call to Validate ship_via_lookup_code';
    ------------------------------------------------------------------------
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    END IF;
    --
    -- Validate ship_via_lookup_code
    --
    IF (p_vendor_rec.ship_via_lookup_code is NOT NULL and
        p_vendor_rec.inventory_organization_id is NOT NULL AND
        p_vendor_rec.ship_via_lookup_code <> ap_null_char AND
        p_vendor_rec.inventory_organization_id <> ap_null_num) THEN

      Check_Valid_ship_via(p_vendor_rec.ship_via_lookup_code,
                           p_vendor_rec.inventory_organization_id,
                           x_valid
                           );

       IF NOT x_valid THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF g_source = 'IMPORT' THEN
          IF (Insert_Rejections(
                    'AP_SUPPLIERS_INT',
                    p_vendor_rec.vendor_interface_id,
                    'AP_INCONSISTENT_SHIP_INVENTORY',
                    g_user_id,
                    g_login_id,
                    'Validate_Vendor') <> TRUE) THEN
           --
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                   l_api_name,'Parameters: '
                   ||' Vendor_Interface_Id: '||p_vendor_rec.vendor_interface_id
                   ||' ,Ship_Via_Lookup_Code: '||p_vendor_rec.ship_via_lookup_code
                   ||' ,Inventory_Organization_Id: '||p_vendor_rec.inventory_organization_id);
            END IF;
          END IF;
        ELSE
            -- Bug 5491139 hkaniven start --
            FND_MESSAGE.SET_NAME('SQLAP','AP_INCONSISTENT_SHIP_INVENTORY');
            FND_MSG_PUB.ADD;
            -- Bug 5491139 hkaniven end --
        END IF;
      END IF;
    END IF;
*/

    ------------------------------------------------------------------------
    l_debug_info := 'Call to Validate set_of_books_id';
    ------------------------------------------------------------------------
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    END IF;
    --
    -- Set_of_books_Id validation
    --
    IF p_vendor_rec.set_of_books_id is NOT NULL AND
       p_vendor_rec.set_of_books_id <> ap_null_num THEN
       	Check_Valid_Sob_Id(p_vendor_rec.set_of_books_id,
                           x_valid);

      IF NOT x_valid THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF g_source = 'IMPORT' THEN
          IF (Insert_Rejections(
                    'AP_SUPPLIERS_INT',
                    p_vendor_rec.vendor_interface_id,
                    'AP_INVALID_SOB',
                    g_user_id,
                    g_login_id,
                    'Validate_Vendor') <> TRUE) THEN
           --
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                   l_api_name,'Parameters: '
                   ||' Vendor_Interface_Id: '||p_vendor_rec.vendor_interface_id
                   ||' ,Set_Of_Books_Id: '||p_vendor_rec.set_of_books_id);
            END IF;
          END IF;
        ELSE
            -- Bug 5491139 hkaniven start --
            FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_SOB');
            FND_MSG_PUB.ADD;
            -- Bug 5491139 hkaniven end --
        END IF;
      END IF;
    END IF;

    ------------------------------------------------------------------------
    l_debug_info := 'Call to Check for duplicate Employee assignment';
    ------------------------------------------------------------------------
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    END IF;
    --
    -- Check for duplicate employee assignment
    --
    IF (p_vendor_rec.employee_id IS NOT NULL and         --bug7023543 removed condition p_vendor_rec.vendor_id
        p_vendor_rec.employee_id <> ap_null_num) THEN    --is not null
     	Chk_Dup_Employee(p_vendor_id,
                      p_vendor_rec.employee_id,
                      x_valid);

     	IF NOT x_valid THEN
        	x_return_status := FND_API.G_RET_STS_ERROR;
     	END IF;
    END IF;

    ------------------------------------------------------------------------
    l_debug_info := 'Call to Check for duplicate vendor number';
    ------------------------------------------------------------------------
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    END IF;
    --
    -- Check for potential duplicate vendor numbers in Interface table
    --
    IF p_vendor_rec.segment1 IS NOT NULL AND
       p_vendor_rec.segment1 <> ap_null_char THEN
     	Chk_Dup_segment1_int(p_vendor_rec.segment1,
                           x_valid);

      IF NOT x_valid THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF g_source = 'IMPORT' THEN
          IF (Insert_Rejections(
                    'AP_SUPPLIERS_INT',
                    p_vendor_rec.vendor_interface_id,
                    --'DUPLICATE SEGMENT1 INT',
                    'AP_INVALID_SEGMENT1_INT',
                    g_user_id,
                    g_login_id,
                    'Validate_Vendor') <> TRUE) THEN
           --
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                   l_api_name,'Parameters: '
                   ||' Vendor_Interface_Id: '||p_vendor_rec.vendor_interface_id
                   ||' ,Segment1: '||p_vendor_rec.segment1);
            END IF;
          END IF;
        ELSE
            -- Bug 5491139 hkaniven start --
            FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_SEGMENT1_INT');
            FND_MSG_PUB.ADD;
            -- Bug 5491139 hkaniven end --
        END IF;
      END IF;
    END IF;

   /*Open Issue 1 -- no longer checking name uniqueness
    ------------------------------------------------------------------------
    l_debug_info := 'Call to Check for duplicate vendor name in interface table';
    ------------------------------------------------------------------------
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    END IF;
    --
    -- Check for duplicate vendor names in Interface table too
    --
    IF p_vendor_rec.vendor_name IS NOT NULL THEN
     	Chk_Dup_Vendor_Name_new(p_vendor_rec.vendor_name,
                           x_valid);

     	IF NOT x_valid THEN
        	x_return_status := FND_API.G_RET_STS_ERROR;
     	END IF;
    END IF;
    */

    ------------------------------------------------------------------------
    l_debug_info := 'Call to Check Duplicate Vendor Number in PO_VENDORS';
    ------------------------------------------------------------------------
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    END IF;
    --
    -- Check for duplicate vendor number
    --
    IF p_vendor_rec.segment1 IS NOT NULL AND
       p_vendor_rec.segment1 <> ap_null_char THEN
     	Chk_Dup_Vendor_Number(p_vendor_id,
                           p_vendor_rec.segment1,
                           x_valid);
     	IF NOT x_valid THEN
        	x_return_status := FND_API.G_RET_STS_ERROR;
                --bug 5606948
                IF g_source = 'IMPORT' THEN
                   IF (Insert_Rejections(
                                         'AP_SUPPLIERS_INT',
                                         p_vendor_rec.vendor_interface_id,
                                         'AP_VEN_DUPLICATE_VEN_NUM',
                                         g_user_id,
                                         g_login_id,
                                        'Validate_Vendor') <> TRUE) THEN

                         IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                             FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                                            l_api_name,'Parameters: '
                                            ||' Vendor_Interface_Id: '||p_vendor_rec.vendor_interface_id
                                            ||' ,Segment1: '||p_vendor_rec.segment1);
                         END IF;
                    END IF;
        	END IF;
       END IF;
    END IF;

    ------------------------------------------------------------------------
    l_debug_info := 'Call to Validate receiving_routing_id';
    ------------------------------------------------------------------------
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    END IF;
    --
    -- Validate receiving_routing_id
    --
    IF p_vendor_rec.receiving_routing_id is NOT NULL and
       p_vendor_rec.receiving_routing_id <> ap_null_num THEN

      	Chk_rcv_routing_id(p_vendor_rec.receiving_routing_id ,
                         x_valid);
      IF NOT x_valid THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF g_source = 'IMPORT' THEN
          IF (Insert_Rejections(
                    'AP_SUPPLIERS_INT',
                    p_vendor_rec.vendor_interface_id,
                    'AP_INVALID_RCV_ROUTING',
                    g_user_id,
                    g_login_id,
                    'Validate_Vendor') <> TRUE) THEN
           --
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                   l_api_name,'Parameters: '
                   ||' Vendor_Interface_Id: '||p_vendor_rec.vendor_interface_id
                   ||' ,Receiving_Routing_Id: '||p_vendor_rec.receiving_routing_id);
            END IF;
          END IF;
        ELSE
            -- Bug 5491139 hkaniven start --
        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_RCV_ROUTING');
        FND_MSG_PUB.ADD;
            -- Bug 5491139 hkaniven end --
        END IF;
      END IF;
    END IF;

    ------------------------------------------------------------------------
    l_debug_info := 'Call to Validate Employee type Vendor`';
    ------------------------------------------------------------------------
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    END IF;
    --
    -- Employee type Vendor validations
    --

    --
    IF p_vendor_rec.vendor_type_lookup_code is NOT NULL and
       p_vendor_rec.vendor_type_lookup_code <> ap_null_char THEN

          employee_type_checks(p_vendor_rec.vendor_type_lookup_code,
                               p_vendor_rec.employee_id,
                               x_valid
                               );

      IF NOT x_valid THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF g_source = 'IMPORT' THEN
          IF (Insert_Rejections(
                    'AP_SUPPLIERS_INT',
                    p_vendor_rec.vendor_interface_id,
                    'AP_INCONSISTENT_VENDOR_TYPE',
                    g_user_id,
                    g_login_id,
                    'Validate_Vendor') <> TRUE) THEN
           --
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                   l_api_name,'Parameters: '
                   ||' Vendor_Interface_Id: '||p_vendor_rec.vendor_interface_id
                   ||' ,Vendor_Type_Lookup_Code: '||p_vendor_rec.vendor_type_lookup_code
                   ||' ,Employee_Id: '||p_vendor_rec.employee_id);
            END IF;
          END IF;
        ELSE

            -- Bug 5491139 hkaniven start --
            FND_MESSAGE.SET_NAME('SQLAP','AP_INCONSISTENT_VENDOR_TYPE');
            FND_MSG_PUB.ADD;
            -- Bug 5491139 hkaniven end --

        END IF;
      END IF;
    END IF;

    ------------------------------------------------------------------------
    l_debug_info := 'Call to Validate Invoice Currency Code';
    ------------------------------------------------------------------------
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    END IF;

    IF (p_vendor_rec.invoice_currency_code is not null
        and p_vendor_rec.invoice_currency_code <> ap_null_char) THEN
      val_currency_code(p_vendor_rec.invoice_currency_code,
                        x_valid);
      IF NOT x_valid THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF g_source = 'IMPORT' THEN
          IF (Insert_Rejections(
                    'AP_SUPPLIERS_INT',
                    p_vendor_rec.vendor_interface_id,
                    'AP_INVALID_INV_CURRENCY',
                    g_user_id,
                    g_login_id,
                    'Validate_Vendor') <> TRUE) THEN
           --
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                   l_api_name,'Parameters: '
                   ||' Vendor_Interface_Id: '||p_vendor_rec.vendor_interface_id
                   ||' ,Invoice_Currency_Code: '||p_vendor_rec.invoice_currency_code);
            END IF;
          END IF;
        ELSE

            -- Bug 5491139 hkaniven start --
            FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_INV_CURRENCY');
            FND_MSG_PUB.ADD;
            -- Bug 5491139 hkaniven end --

        END IF;
      END IF;
    END IF;

    ------------------------------------------------------------------------
    l_debug_info := 'Call to Validate Payment Currency Code';
    ------------------------------------------------------------------------

    IF (p_vendor_rec.payment_currency_code is not null
       AND p_vendor_rec.invoice_currency_code is not null and
           p_vendor_rec.payment_currency_code <> ap_null_char and
           p_vendor_rec.invoice_currency_code <> ap_null_char) THEN
      payment_currency_code_valid(p_vendor_rec.payment_currency_code,
                                  p_vendor_rec.invoice_currency_code,
                                  x_valid);

      IF NOT x_valid THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF g_source = 'IMPORT' THEN
          IF (Insert_Rejections(
                    'AP_SUPPLIERS_INT',
                    p_vendor_rec.vendor_interface_id,
                    'AP_INVALID_PAY_CURRENCY',
                    g_user_id,
                    g_login_id,
                    'Validate_Vendor') <> TRUE) THEN
           --
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                   l_api_name,'Parameters: '
                   ||' Vendor_Interface_Id: '||p_vendor_rec.vendor_interface_id
                   ||' ,Invoice_Currency_Code: '||p_vendor_rec.invoice_currency_code
                   ||' ,Payment_Currency_Code: '||p_vendor_rec.payment_currency_code);
            END IF;
          END IF;
        ELSE

            -- Bug 5491139 hkaniven start --
            FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_PAY_CURRENCY');
            FND_MSG_PUB.ADD;
            -- Bug 5491139 hkaniven end --

        END IF;
      END IF;
    END IF;

    ------------------------------------------------------------------------
    l_debug_info := 'Call to Validate Income Tax Type';
    ------------------------------------------------------------------------
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    END IF;
    --
    -- Validate the Income Tax Type
    --
    IF p_vendor_rec.type_1099 IS NOT NULL AND
       p_vendor_rec.type_1099 <> ap_null_char THEN
     Val_Income_Tax_Type(p_vendor_rec.type_1099,
                         x_valid);
     	IF NOT x_valid THEN
        	x_return_status := FND_API.G_RET_STS_ERROR;
        IF g_source = 'IMPORT' THEN
          IF (Insert_Rejections(
                    'AP_SUPPLIERS_INT',
                    p_vendor_rec.vendor_interface_id,
                    'AP_INVALID_TYPE_1099',
                    g_user_id,
                    g_login_id,
                    'Validate_Vendor') <> TRUE) THEN
           --
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                   l_api_name,'Parameters: '
                   ||' Vendor_Interface_Id: '||p_vendor_rec.vendor_interface_id
                   ||' ,Type_1099: '||p_vendor_rec.type_1099);
            END IF;
          END IF;
        ELSE

            -- Bug 5491139 hkaniven start --
            FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_TYPE_1099');
            FND_MSG_PUB.ADD;
            -- Bug 5491139 hkaniven end --

        END IF;
      END IF;
    END IF;

    IF p_mode = 'U' THEN

	--update validations

        /* open issue 1 -- no longer need to check for name duplicates
	------------------------------------------------------------------------
    	l_debug_info := 'Call to Validate vendor name';
    	------------------------------------------------------------------------
     	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    	END IF;
	--
	-- Check for duplicate vendor names
	--
   	IF p_vendor_rec.vendor_name IS NOT NULL THEN
     		Chk_Dup_Vendor_Name_update(p_vendor_rec.vendor_name,
                                p_vendor_id,
                                x_valid);

     		IF NOT x_valid THEN
        		x_return_status := FND_API.G_RET_STS_ERROR;
     		END IF;
   	END IF;
        */
	null;
    ------------------------------------------------------------------------
    l_debug_info := 'Call for prohibiting update of CCR vendor';
    ------------------------------------------------------------------------
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME|| l_api_name,l_debug_info);
    END IF;

    --
    --calling the API to check if we are trying to update
    --any restricted field on a CCR vendor. Added for R12
    --FSIO gap.(bug6053476)
    --

    update_supplier_JFMIP_checks(p_vendor_rec,
                                 p_calling_prog,
                                 x_valid);

    IF NOT x_valid THEN
      	x_return_status := FND_API.G_RET_STS_ERROR;
        IF g_source = 'IMPORT' THEN
          IF (Insert_Rejections(
                    'AP_SUPPLIERS_INT',
                     p_vendor_rec.vendor_interface_id,
                    'AP_CCR_NO_UPDATE',
                     g_user_id,
                     g_login_id,
                    'Validate_Vendor') <> TRUE) THEN

            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                   l_api_name,'Parameters: '
                   ||'Cannot Update CCR vendor, Vendor_id'||p_vendor_rec.vendor_id);
            END IF;
          END IF;

        ELSE

            FND_MESSAGE.SET_NAME('SQLAP','AP_CANT_UPDATE_CCR_VENDOR');
            FND_MSG_PUB.ADD;

        END IF;
    END IF;

    ELSIF p_mode = 'I' THEN

        --bug 5606948
        ------------------------------------------------------------------------
    	l_debug_info := 'Call to Validate vendor name';
    	------------------------------------------------------------------------
       if g_source= 'IMPORT' Then
     	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    	END IF;
	--
	-- Check for duplicate vendor names
	--
   	IF p_vendor_rec.vendor_name IS NOT NULL THEN
                   -- Bug 6775797. Added parameters vendor type and employee id
                   -- Bug 6939863. Changed from update to new since this is
                   --              insert mode.

                      Chk_Dup_Vendor_Name_new(p_vendor_rec.vendor_name,
                                p_vendor_id,
                                p_vendor_rec.vendor_type_lookup_code,
                                p_vendor_rec.employee_id,
                                x_valid);

                      IF NOT x_valid THEN
        		x_return_status := FND_API.G_RET_STS_ERROR;


                         IF (Insert_Rejections(
                                         'AP_SUPPLIERS_INT',
                                         p_vendor_rec.vendor_interface_id,
                                         'AP_VEN_DUPLICATE_NAME',
                                         g_user_id,
                                         g_login_id,
                                        'Validate_Vendor') <> TRUE) THEN

                         IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                             FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                                            l_api_name,'Parameters: '
                                            ||' Vendor_Interface_Id: '||p_vendor_rec.vendor_interface_id
                                            ||' ,Vendor_name: '||p_vendor_rec.vendor_name);
                         END IF;

                        END IF;
                       END IF;


          END IF;
   	END IF;
        ------------------------------------------------------------------------
        l_debug_info := 'Call to Validate payee';
        ------------------------------------------------------------------------
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
        END IF;
        --
	--  Calling IBY Payee Validation API
	--
	IF p_vendor_rec.ext_payee_rec.payer_org_type IS NOT NULL THEN

	  /*Bug 7572325- added the call to count_and_get to get the count
            before call to IBY API in local variable*/
           FND_MSG_PUB.Count_And_Get(p_count => l_msg_count,
                                     p_data => l_msg_data);

          IBY_DISBURSEMENT_SETUP_PUB.Validate_External_Payee
            ( p_api_version     => 1.0,
              p_init_msg_list   => FND_API.G_FALSE,
              p_ext_payee_rec   => p_vendor_rec.ext_payee_rec,
              x_return_status   => l_payee_return_status,
              x_msg_count       => l_payee_msg_count,
              x_msg_data        => l_payee_msg_data);

	   IF l_payee_return_status = FND_API.G_RET_STS_SUCCESS THEN
		x_payee_valid := 'V';
	   ELSE
		x_payee_valid := 'F';
		x_return_status := l_payee_return_status;
		IF g_source = 'IMPORT' THEN
                    IF (Insert_Rejections(
                      'AP_SUPPLIERS_INT',
                      p_vendor_rec.vendor_interface_id,
                      --'AP_INVALID_PAYEE',
                      'AP_INVALID_PAYEE_INFO',/*bug 7572325*/
                      g_user_id,
                      g_login_id,
                      'Validate_Vendor') <> TRUE) THEN
                      --
                      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                          l_api_name,'Parameters: '
                          ||' Vendor_Interface_Id:' ||
				p_vendor_rec.vendor_interface_id);
                      END IF;
                    END IF;

		   --bug 7572325 addded below file logging for improved exception
                   --message handling
                    IF (l_payee_msg_data IS NOT NULL) THEN
                     -- Print the error returned from the IBY service even if the debug
                     -- mode is off
                      AP_IMPORT_UTILITIES_PKG.Print('Y', '1)Error in '||l_debug_info||
                                                    '---------------------->'||
                                                    l_payee_msg_data);

                    ELSE
                      -- If the l_payee_msg_data is null then the IBY service returned
                      -- more than one error.  The calling module will need to get
                      -- them from the message stack
                     FOR i IN l_msg_count..l_payee_msg_count
                      LOOP
                       l_error_code := FND_MSG_PUB.Get(p_msg_index => i,
                                                       p_encoded => 'F');

                        If i = l_msg_count then
                          l_error_code := '1)Error in '||l_debug_info||
                                                    '---------------------->'||
                                                    l_error_code;
                        end if;

		        AP_IMPORT_UTILITIES_PKG.Print('Y', l_error_code);

                      END LOOP;

                     END IF;--bug 7572325
                ELSE

                    -- Bug 5491139 hkaniven start --
                    --FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_PAYEE'); --bug 7572325
		    FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_PAYEE_INFO'); --bug 7572325
                    FND_MSG_PUB.ADD;
                    -- Bug 5491139 hkaniven end --

                END IF;
	   END IF;
 	ELSE
	   x_payee_valid := 'N';
	END IF; --payee valid

	------------------------------------------------------------------------
    	l_debug_info := 'Call to Validate party_id';
    	------------------------------------------------------------------------
     	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    	END IF;
	--
	-- Check for validity of party_id
	--
   	IF p_vendor_rec.party_id IS NOT NULL and
         p_vendor_rec.party_id <> ap_null_num THEN
     		Check_Valid_Party_ID(p_vendor_rec.party_id,
                                x_valid);

     		IF NOT x_valid THEN
       		  x_party_valid := 'F';
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  IF g_source = 'IMPORT' THEN
                    IF (Insert_Rejections(
                      'AP_SUPPLIERS_INT',
                      p_vendor_rec.vendor_interface_id,
                      'AP_INVALID_PARTY_ID',
                      g_user_id,
                      g_login_id,
                      'Validate_Vendor') <> TRUE) THEN
                      --
                      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                          l_api_name,'Parameters: '
                          ||' Vendor_Interface_Id: '||p_vendor_rec.vendor_interface_id
                          ||' ,Party_Id: '||p_vendor_rec.party_id);
                      END IF;
                    END IF;
                  ELSE

                    -- Bug 5491139 hkaniven start --
                    FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_PARTY_ID');
                    FND_MSG_PUB.ADD;
                    -- Bug 5491139 hkaniven end --

                  END IF;
		ELSE
			x_party_valid := 'V';
     		END IF;
	ELSE
		x_party_valid := 'N';

   	END IF;


	--insert validations

	------------------------------------------------------------------------
    	l_debug_info := 'Call to Validate vendor number';
    	------------------------------------------------------------------------
     	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    	END IF;
	--
	-- Check for Null vendor number
	--
   	IF p_vendor_rec.segment1 IS NULL and
         p_vendor_rec.segment1 <> ap_null_char THEN
     		Chk_Null_Vendor_Number(p_vendor_rec.segment1,
                           x_valid);
          IF NOT x_valid THEN
                  x_return_status := FND_API.G_RET_STS_ERROR;
            IF g_source = 'IMPORT' THEN
              IF (Insert_Rejections(
                    'AP_SUPPLIERS_INT',
                    p_vendor_rec.vendor_interface_id,
                    'AP_NULL_VENDOR_NUMBER',           --bug 5568861
                    g_user_id,
                    g_login_id,
                    'Validate_Vendor') <> TRUE) THEN
           --
                IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                   l_api_name,'Parameters: '
                   ||' Vendor_Interface_Id: '||p_vendor_rec.vendor_interface_id
                   ||' ,Segment1: '||p_vendor_rec.segment1);
                END IF;
              END IF;
            ELSE

                -- Bug 5491139 hkaniven start --
                FND_MESSAGE.SET_NAME('SQLAP','AP_NULL_VENDOR_NUMBER');
                FND_MSG_PUB.ADD;
                -- Bug 5491139 hkaniven end --

            END IF;
          END IF;
   	END IF;

	IF p_calling_prog <> 'ISETUP' THEN

		--addl insert validations

		---------------------------------------------------------------
    		l_debug_info := 'Call to Validate one_time_flag';
    		---------------------------------------------------------------
     		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate one_time_flag
		--
   		IF p_vendor_rec.one_time_flag is NOT NULL and
               p_vendor_rec.one_time_flag <> ap_null_char THEN

      			Validate_Lookups(
			'ONE_TIME_FLAG',p_vendor_rec.one_time_flag,'YES/NO',
                                    'PO_LOOKUP_CODES',x_valid);
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                         'AP_SUPPLIERS_INT',
                         p_vendor_rec.vendor_interface_id,
                         'AP_INVALID_ONE_TIME_FLAG',
                         g_user_id,
                         g_login_id,
                         'Validate_Vendor') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Interface_Id:'
				||p_vendor_rec.vendor_interface_id
                            ||' ,One_Time_Flag: '||p_vendor_rec.one_time_flag);
                        END IF;
                      END IF;
                    ELSE

                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_ONE_TIME_FLAG');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --

                    END IF;
                  END IF;
   		END IF;

    		----------------------------------------------------------------
    		l_debug_info := 'Call to Validate Summary_flag';
    		---------------------------------------------------------------
     		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate Summary_flag
		--
   		IF p_vendor_rec.summary_flag is NOT NULL AND
               p_vendor_rec.summary_flag <> ap_null_char THEN

      			Validate_Lookups(
			'SUMMARY_FLAG',p_vendor_rec.summary_flag,'YES/NO',
                                    'PO_LOOKUP_CODES',x_valid);
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                         'AP_SUPPLIERS_INT',
                         p_vendor_rec.vendor_interface_id,
                         'AP_INVALID_SUMMARY_FLAG',
                         g_user_id,
                         g_login_id,
                         'Validate_Vendor') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Interface_Id:'
				||p_vendor_rec.vendor_interface_id
                            ||' ,Summary_Flag: '||p_vendor_rec.summary_flag);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_SUMMARY_FLAG');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                    END IF;
                  END IF;
   		END IF;

    		----------------------------------------------------------------
    		l_debug_info := 'Call to Validate Enabled_flag';
    		---------------------------------------------------------------
     		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate Enabled_flag
		--
   		IF p_vendor_rec.enabled_flag is NOT NULL
               AND p_vendor_rec.enabled_flag <> ap_null_char THEN

      		   Validate_Lookups(
			'ENABLED_FLAG',p_vendor_rec.enabled_flag,'YES/NO',
                                    'PO_LOOKUP_CODES',x_valid);
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                         'AP_SUPPLIERS_INT',
                         p_vendor_rec.vendor_interface_id,
                         'AP_INVALID_ENABLED_FLAG',
                         g_user_id,
                         g_login_id,
                         'Validate_Vendor') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Interface_Id:'
				||p_vendor_rec.vendor_interface_id
                            ||' ,Enabled_Flag: '||p_vendor_rec.enabled_flag);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_ENABLED_FLAG');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                    END IF;
                  END IF;
   		END IF;

    		---------------------------------------------------------------
    		l_debug_info := 'Call to Validate vendor_type_lookup_code';
    		---------------------------------------------------------------
     		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    		END IF;

		-- Validate vendor_type_lookup_code
		--
   		IF p_vendor_rec.vendor_type_lookup_code is NOT NULL
               AND p_vendor_rec.vendor_type_lookup_code <> ap_null_char THEN

      			Validate_Lookups( 'VENDOR_TYPE_LOOKUP_CODE',
			p_vendor_rec.vendor_type_lookup_code,'VENDOR TYPE',
                                    'PO_LOOKUP_CODES',x_valid);
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                         'AP_SUPPLIERS_INT',
                         p_vendor_rec.vendor_interface_id,
                         'AP_INVALID_VENDOR_TYPE',
                         g_user_id,
                         g_login_id,
                         'Validate_Vendor') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Interface_Id:'
				||p_vendor_rec.vendor_interface_id
                            ||' ,Vendor_Type_Lookup_Code: '
                            ||p_vendor_rec.vendor_type_lookup_code);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_VENDOR_TYPE');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                    END IF;
                  END IF;
   		END IF;

    		---------------------------------------------------------------
    		l_debug_info := 'Call to Validate pay_date_basis_lookup_code';
    		----------------------------------------------------------------
     		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate pay_date_basis_lookup_code
		--
   		IF p_vendor_rec.pay_date_basis_lookup_code is NOT NULL
               AND p_vendor_rec.pay_date_basis_lookup_code <> ap_null_char THEN
      			Validate_Lookups( 'PAY_DATE_BASIS_LOOKUP_CODE',
				p_vendor_rec.pay_date_basis_lookup_code,
				'PAY DATE BASIS',
				'PO_LOOKUP_CODES',x_valid);
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                         'AP_SUPPLIERS_INT',
                         p_vendor_rec.vendor_interface_id,
                         'AP_INVALID_PAY_DATE_BASIS',
                         g_user_id,
                         g_login_id,
                         'Validate_Vendor') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Interface_Id:'
				||p_vendor_rec.vendor_interface_id
                            ||' ,Pay_Date_Basis_Lookup_Code: '
                            || p_vendor_rec.pay_date_basis_lookup_code);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_PAY_DATE_BASIS');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                    END IF;
                  END IF;
   		END IF;
    		---------------------------------------------------------------
    		l_debug_info := 'Call to Validate pay_group_lookup_code';
    		----------------------------------------------------------------
     		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate pay_group_lookup_code
		--
   		IF p_vendor_rec.pay_group_lookup_code is NOT NULL
               AND p_vendor_rec.pay_group_lookup_code <> ap_null_char THEN

      			Validate_Lookups( 'PAY_GROUP_LOOKUP_CODE',
			p_vendor_rec.pay_group_lookup_code,'PAY GROUP',
                                    'PO_LOOKUP_CODES',x_valid);
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                         'AP_SUPPLIERS_INT',
                         p_vendor_rec.vendor_interface_id,
                         'AP_INVALID_PAY_GROUP',
                         g_user_id,
                         g_login_id,
                         'Validate_Vendor') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Interface_Id:'
				||p_vendor_rec.vendor_interface_id
                            ||' ,Pay_Group_Lookup_Code:'
                              ||p_vendor_rec.pay_group_lookup_code);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_PAY_GROUP');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --

                    END IF;
                  END IF;
   		END IF;

    		----------------------------------------------------------------
    		l_debug_info := 'Call to Validate org type_lookup code';
    		---------------------------------------------------------------
     		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate organization_type_lookup_code
		--
   		IF p_vendor_rec.organization_type_lookup_code is NOT NULL
               AND p_vendor_rec.organization_type_lookup_code <> ap_null_char THEN

      		  Validate_Lookups( 'ORGANIZATION_TYPE_LOOKUP_CODE',
			p_vendor_rec.organization_type_lookup_code,
			'ORGANIZATION TYPE',
                                    'PO_LOOKUP_CODES',x_valid);
   	          IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                         'AP_SUPPLIERS_INT',
                         p_vendor_rec.vendor_interface_id,
                         'AP_INVALID_ORG_TYPE',
                         g_user_id,
                         g_login_id,
                         'Validate_Vendor') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Interface_Id:'
				||p_vendor_rec.vendor_interface_id
                            ||' ,Organization_Type_Lookup_Code:'
                              ||p_vendor_rec.organization_type_lookup_code);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_ORG_TYPE');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                    END IF;
                  END IF;
                END IF;

    		---------------------------------------------------------------
    		l_debug_info := 'Call to Validate minority_group_lookup_code';
    		---------------------------------------------------------------
     		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate minority_group_lookup_code
		--
   		IF p_vendor_rec.minority_group_lookup_code is NOT NULL
               AND p_vendor_rec.minority_group_lookup_code <> ap_null_char THEN

      			Validate_Lookups( 'MINORITY_GROUP_LOOKUP_CODE',
		p_vendor_rec.minority_group_lookup_code,'MINORITY GROUP',
                                    'PO_LOOKUP_CODES',x_valid);
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                         'AP_SUPPLIERS_INT',
                         p_vendor_rec.vendor_interface_id,
                         'AP_INVALID_MINORITY_GROUP',
                         g_user_id,
                         g_login_id,
                         'Validate_Vendor') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Interface_Id:'
				||p_vendor_rec.vendor_interface_id
                            ||' ,Minority_Group_Lookup_Code:'
                              ||p_vendor_rec.minority_group_lookup_code);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_MINORITY_GROUP');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                    END IF;
                  END IF;
   		END IF;

    		---------------------------------------------------------------
    		l_debug_info := 'Call to Validate terms_date_basis';
    		----------------------------------------------------------------
     		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate terms_date_basis
		--
   		IF p_vendor_rec.terms_date_basis is NOT NULL
               AND p_vendor_rec.terms_date_basis <> ap_null_char THEN

      			Validate_Lookups( 'TERMS_DATE_BASIS',
			p_vendor_rec.terms_date_basis,'TERMS DATE BASIS',
                                    'AP_LOOKUP_CODES',x_valid);
   	          IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                         'AP_SUPPLIERS_INT',
                         p_vendor_rec.vendor_interface_id,
                         'AP_INVALID_TERMS_DATE',
                         g_user_id,
                         g_login_id,
                         'Validate_Vendor') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Interface_Id:'
				||p_vendor_rec.vendor_interface_id
                            ||' ,Terms_Date_Basis:'
                              ||p_vendor_rec.terms_date_basis);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_TERMS_DATE');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                    END IF;
                  END IF;
                END IF;

    		---------------------------------------------------------------
    		l_debug_info := 'Call to Validate qty_rcv_exception_code';
    		---------------------------------------------------------------
     		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate qty_rcv_exception_code
		--
   		IF p_vendor_rec.qty_rcv_exception_code is NOT NULL
               AND p_vendor_rec.qty_rcv_exception_code <> ap_null_char THEN

      			Validate_Lookups( 'QTY_RCV_EXCEPTION_CODE',
			p_vendor_rec.qty_rcv_exception_code,'RCV OPTION',
                                    'PO_LOOKUP_CODES',x_valid);
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                         'AP_SUPPLIERS_INT',
                         p_vendor_rec.vendor_interface_id,
                         'AP_INVALID_QTY_RCV_OPTION',
                         g_user_id,
                         g_login_id,
                         'Validate_Vendor') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Interface_Id:'
				||p_vendor_rec.vendor_interface_id
                            ||' ,Qty_Rcv_Execption_Code:'
                              ||p_vendor_rec.Qty_Rcv_Exception_code);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_QTY_RCV_OPTION');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                    END IF;
                  END IF;
   		END IF;

    		------------------------------------------------------------------------
    		l_debug_info := 'Call to Validate ship to loc code';
    		------------------------------------------------------------------------
     		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate enforce_ship_to_location_code
		--
   		IF p_vendor_rec.enforce_ship_to_location_code is NOT NULL
               AND p_vendor_rec.enforce_ship_to_location_code <> ap_null_char THEN

      		  Validate_Lookups( 'ENFORCE_SHIP_TO_LOCATION_CODE',
			p_vendor_rec.enforce_ship_to_location_code,'RCV OPTION',
                                    'PO_LOOKUP_CODES',x_valid);
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                         'AP_SUPPLIERS_INT',
                         p_vendor_rec.vendor_interface_id,
                         'AP_INVALID_SHIP_RCV_OPTION',
                         g_user_id,
                         g_login_id,
                         'Validate_Vendor') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Interface_Id:'
				||p_vendor_rec.vendor_interface_id
                            ||' ,Enforce_Ship_To_Location_Code:'
                              ||p_vendor_rec.enforce_ship_to_location_code);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_SHIP_RCV_OPTION');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                    END IF;
                  END IF;
   		END IF;

    		---------------------------------------------------------------
    		l_debug_info := 'Call to Validate receipt_days_exception_code';
    		----------------------------------------------------------------
     		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate receipt_days_exception_code
		--
   		IF p_vendor_rec.receipt_days_exception_code is NOT NULL
               AND p_vendor_rec.receipt_days_exception_code <> ap_null_char THEN

      			Validate_Lookups( 'RECEIPT_DAYS_EXCEPTION_CODE',
			p_vendor_rec.receipt_days_exception_code,'RCV OPTION',
                                    'PO_LOOKUP_CODES',x_valid);
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                         'AP_SUPPLIERS_INT',
                         p_vendor_rec.vendor_interface_id,
                         'AP_INVALID_REC_RCV_OPTION',
                         g_user_id,
                         g_login_id,
                         'Validate_Vendor') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Interface_Id:'
				||p_vendor_rec.vendor_interface_id
                            ||' ,Receipt_Days_Exception_Code:'
                              ||p_vendor_rec.receipt_days_exception_code);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_REC_RCV_OPTION');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                    END IF;
                  END IF;
   		END IF;

		---------------------------------------------------------------
    		l_debug_info := 'Call to Validate create_debit_memo_flag';
    		----------------------------------------------------------------
     		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate create_debit_memo_flag
		--
   		IF p_vendor_rec.create_debit_memo_flag is NOT NULL
               AND p_vendor_rec.create_debit_memo_flag <> ap_null_char THEN

      			Validate_Lookups( 'CREATE_DEBIT_MEMO_FLAG',
			p_vendor_rec.create_debit_memo_flag ,'YES/NO',
                                    'PO_LOOKUP_CODES',x_valid);
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                         'AP_SUPPLIERS_INT',
                         p_vendor_rec.vendor_interface_id,
                         'AP_INVALID_DEBIT_MEMO',
                         g_user_id,
                         g_login_id,
                         'Validate_Vendor') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Interface_Id:'
				||p_vendor_rec.vendor_interface_id
                            ||' ,Create_Debit_Memo_Flag:'
                              ||p_vendor_rec.create_debit_memo_flag);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_DEBIT_MEMO');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                    END IF;
                  END IF;
   		END IF;

    		---------------------------------------------------------------
    		l_debug_info := 'Call to Validate federal_reportable_flag';
    		---------------------------------------------------------------
     		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate federal_reportable_flag
		--
   		IF p_vendor_rec.federal_reportable_flag is NOT NULL
               AND p_vendor_rec.federal_reportable_flag <> ap_null_char THEN

      			Validate_Lookups( 'FEDERAL_REPORTABLE_FLAG',
			p_vendor_rec.federal_reportable_flag ,'YES/NO',
                                    'PO_LOOKUP_CODES',x_valid);
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                         'AP_SUPPLIERS_INT',
                         p_vendor_rec.vendor_interface_id,
                         'AP_INVALID_FED_REPORTABLE',
                         g_user_id,
                         g_login_id,
                         'Validate_Vendor') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Interface_Id:'
				||p_vendor_rec.vendor_interface_id
                            ||' ,Federal_Reportable_Flag:'
                              ||p_vendor_rec.federal_reportable_flag);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_FED_REPORTABLE');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                    END IF;
                  END IF;
   		END IF;

    		----------------------------------------------------------------
    		l_debug_info := 'Call to Validate state_reportable_flag';
    		----------------------------------------------------------------
     		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate state_reportable_flag
		--
   		IF p_vendor_rec.state_reportable_flag is NOT NULL
               AND p_vendor_rec.state_reportable_flag <> ap_null_char THEN

      			Validate_Lookups('STATE_REPORTABLE_FLAG',
			p_vendor_rec.state_reportable_flag ,'YES/NO',
                                    'PO_LOOKUP_CODES', x_valid);
                 IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                         'AP_SUPPLIERS_INT',
                         p_vendor_rec.vendor_interface_id,
                         'AP_INVALID_STATE_REPORTABLE',
                         g_user_id,
                         g_login_id,
                         'Validate_Vendor') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Interface_Id:'
				||p_vendor_rec.vendor_interface_id
                            ||' ,State_Reportable_Flag:'
                              ||p_vendor_rec.state_reportable_flag);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_STATE_REPORTABLE');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                    END IF;
                  END IF;
   		END IF;

    		---------------------------------------------------------------
    		l_debug_info := 'Call to Validate auto_calculate_interest_flag';
    		----------------------------------------------------------------
     		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate auto_calculate_interest_flag
		--
   		IF p_vendor_rec.auto_calculate_interest_flag is NOT NULL
               AND p_vendor_rec.auto_calculate_interest_flag <> ap_null_char THEN

      			Validate_Lookups('AUTO_CALCULATE_INTEREST_FLAG',
			 p_vendor_rec.auto_calculate_interest_flag,'YES/NO',
                                    'PO_LOOKUP_CODES', x_valid);
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                         'AP_SUPPLIERS_INT',
                         p_vendor_rec.vendor_interface_id,
                         'AP_INVALID_CALC_INT',
                         g_user_id,
                         g_login_id,
                         'Validate_Vendor') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Interface_Id:'
				||p_vendor_rec.vendor_interface_id
                            ||' , Auto_Calculate_Interest_Flag'
                              ||p_vendor_rec.auto_calculate_interest_flag);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_CALC_INT');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                    END IF;
                  END IF;
   		END IF;

    		---------------------------------------------------------------
    		l_debug_info := 'Call to Validate excl freight from disc';
    		---------------------------------------------------------------
     		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate exclude_freight_from_discount
		--
   		IF p_vendor_rec.exclude_freight_from_discount is NOT NULL
               AND p_vendor_rec.exclude_freight_from_discount <> ap_null_char THEN

      			Validate_Lookups( 'EXCLUDE_FREIGHT_FROM_DISCOUNT',
			p_vendor_rec.exclude_freight_from_discount ,'YES/NO',
                                    'PO_LOOKUP_CODES',x_valid);
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                         'AP_SUPPLIERS_INT',
                         p_vendor_rec.vendor_interface_id,
                         'AP_INVALID_EXC_FR_DISC',
                         g_user_id,
                         g_login_id,
                         'Validate_Vendor') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Interface_Id:'
				||p_vendor_rec.vendor_interface_id
                            ||' ,Exclude_Freight_From_Discount:'
                              ||p_vendor_rec.exclude_freight_from_discount);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_EXC_FR_DISC');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                    END IF;
                  END IF;
   		END IF;

		----------------------------------------------------------------
    		l_debug_info := 'Call to Validate hold_unmatched_invoices_flag';
    		----------------------------------------------------------------
     		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate hold_unmatched_invoices_flag
		--
   		IF p_vendor_rec.hold_unmatched_invoices_flag is NOT NULL
               AND p_vendor_rec.hold_unmatched_invoices_flag <> ap_null_char THEN

      			Validate_Lookups('HOLD_UNMATCHED_INVOICES_FLAG',
			p_vendor_rec.hold_unmatched_invoices_flag ,'YES/NO',
                                    'PO_LOOKUP_CODES',x_valid);
   	          IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                         'AP_SUPPLIERS_INT',
                         p_vendor_rec.vendor_interface_id,
                         'AP_INVALID_HOLD_UNMAT_INV',
                         g_user_id,
                         g_login_id,
                         'Validate_Vendor') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Interface_Id:'
				||p_vendor_rec.vendor_interface_id
                            ||' ,Hold_Unmatched_Invoices_Flag:'
                              ||p_vendor_rec.hold_unmatched_invoices_flag);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_HOLD_UNMAT_INV');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                    END IF;
                  END IF;
                END IF;

    		---------------------------------------------------------------
    		l_debug_info := 'Call to Validate allow_unord_receipts_flag';
    		---------------------------------------------------------------
     		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate allow_unord_receipts_flag
		--
   		IF p_vendor_rec.allow_unordered_receipts_flag is NOT NULL
               AND p_vendor_rec.allow_unordered_receipts_flag <> ap_null_char THEN

      			Validate_Lookups('ALLOW_UNORDERED_RECEIPTS_FLAG',
				p_vendor_rec.allow_unordered_receipts_flag,'YES/NO',
                                    'PO_LOOKUP_CODES', x_valid);
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                         'AP_SUPPLIERS_INT',
                         p_vendor_rec.vendor_interface_id,
                         'AP_INVALID_UNORD_RCV',
                         g_user_id,
                         g_login_id,
                         'Validate_Vendor') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Interface_Id:'
				||p_vendor_rec.vendor_interface_id
                            ||' ,Allow_Unordered_Receipts_Flag:'
                              ||p_vendor_rec.allow_unordered_receipts_flag);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_UNORD_RCV');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                    END IF;
                  END IF;
   		END IF;

    		---------------------------------------------------------------
    		l_debug_info :=
			'Call to Validate allow_substitute_receipts_flag';
    		-------------------------------------------------------------
     		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate allow_substitute_receipts_flag
		--
   		IF p_vendor_rec.allow_substitute_receipts_flag is NOT NULL
               AND p_vendor_rec.allow_substitute_receipts_flag <> ap_null_char THEN

      			Validate_Lookups('ALLOW_SUBSTITUTE_RECEIPTS_FLAG',
				p_vendor_rec.allow_substitute_receipts_flag,'YES/NO',
                                    'PO_LOOKUP_CODES', x_valid);
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                         'AP_SUPPLIERS_INT',
                         p_vendor_rec.vendor_interface_id,
                         'AP_INVALID_SUBS_RCV',
                         g_user_id,
                         g_login_id,
                         'Validate_Vendor') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Interface_Id:'
				||p_vendor_rec.vendor_interface_id
                            ||' ,Allow_Substitute_Receipts_Flag:'
                              ||p_vendor_rec.allow_substitute_receipts_flag);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_SUB_RCV');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                    END IF;
                  END IF;
   		END IF;

    		---------------------------------------------------------------
    		l_debug_info := 'Call to Validate hold_flag';
    		----------------------------------------------------------------
     		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate hold_flag
		--
   		IF p_vendor_rec.hold_flag is NOT NULL
               AND p_vendor_rec.hold_flag <> ap_null_char THEN

      			Validate_Lookups('HOLD_FLAG', p_vendor_rec.hold_flag,
					'YES/NO',
                                    'PO_LOOKUP_CODES', x_valid);
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                         'AP_SUPPLIERS_INT',
                         p_vendor_rec.vendor_interface_id,
                         'AP_INVALID_HOLD',
                         g_user_id,
                         g_login_id,
                         'Validate_Vendor') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Interface_Id:'
				||p_vendor_rec.vendor_interface_id
                            ||' ,Hold_Flag:'
                              ||p_vendor_rec.hold_flag);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_HOLD');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                    END IF;
                  END IF;
   		END IF;

    		----------------------------------------------------------------
    		l_debug_info := 'Call to Validate small_business_flag';
    		---------------------------------------------------------------
     		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate small_business_flag
		--
   		IF p_vendor_rec.small_business_flag is NOT NULL
               AND p_vendor_rec.small_business_flag <> ap_null_char THEN

      			Validate_Lookups('SMALL_BUSINESS_FLAG',
			p_vendor_rec.small_business_flag,'YES/NO',
                                    'PO_LOOKUP_CODES',x_valid);
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                         'AP_SUPPLIERS_INT',
                         p_vendor_rec.vendor_interface_id,
                         'AP_INVALID_SMALL_BUSINESS',
                         g_user_id,
                         g_login_id,
                         'Validate_Vendor') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Interface_Id:'
				||p_vendor_rec.vendor_interface_id
                            ||' ,Small_Business_Flag:'
                              ||p_vendor_rec.small_business_flag);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_SMALL_BUSINESS');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                    END IF;
                  END IF;
   		END IF;

    		----------------------------------------------------------------
    		l_debug_info := 'Call to Validate women_owned_flag';
    		---------------------------------------------------------------
     		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate women_owned_flag
		--
   		IF p_vendor_rec.women_owned_flag is NOT NULL
               AND p_vendor_rec.women_owned_flag <> ap_null_char THEN

      			Validate_Lookups('WOMEN_OWNED_FLAG',
			p_vendor_rec.women_owned_flag,'YES/NO',
                                    'PO_LOOKUP_CODES', x_valid);
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                         'AP_SUPPLIERS_INT',
                         p_vendor_rec.vendor_interface_id,
                         'AP_INVALID_WOMEN_OWNED',
                         g_user_id,
                         g_login_id,
                         'Validate_Vendor') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Interface_Id:'
				||p_vendor_rec.vendor_interface_id
                            ||' ,Women_Owned_Flag:'
                              ||p_vendor_rec.women_owned_flag);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_WOMEN_OWNED');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                    END IF;
                  END IF;
   		END IF;

    		--------------------------------------------------------------
    		l_debug_info := 'Call to Validate hold_future_payments_flag';
    		---------------------------------------------------------------
     		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate hold_future_payments_flag
		--
   		IF p_vendor_rec.hold_future_payments_flag is NOT NULL
               AND p_vendor_rec.hold_future_payments_flag <> ap_null_char THEN

     			Validate_Lookups('HOLD_FUTURE_PAYMENTS_FLAG',
			p_vendor_rec.hold_future_payments_flag,'YES/NO',
                                    'PO_LOOKUP_CODES', x_valid);
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                         'AP_SUPPLIERS_INT',
                         p_vendor_rec.vendor_interface_id,
                         'AP_INVALID_HOLD_FUT_PAY',
                         g_user_id,
                         g_login_id,
                         'Validate_Vendor') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Interface_Id:'
				||p_vendor_rec.vendor_interface_id
                            ||' ,Hold_Future_Payments_Flag:'
                              ||p_vendor_rec.hold_future_payments_flag);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_HOLD_FUT_PAY');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                    END IF;
                  END IF;
   		END IF;

    		----------------------------------------------------------------
    		l_debug_info := 'Call to Validate hold_all_payments_flag';
    		----------------------------------------------------------------
     		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate hold_all_payments_flag
		--
   		IF p_vendor_rec.hold_all_payments_flag is NOT NULL
               AND p_vendor_rec.hold_all_payments_flag <> ap_null_char THEN

      			Validate_Lookups('HOLD_ALL_PAYMENTS_FLAG',
			p_vendor_rec.hold_all_payments_flag,'YES/NO',
                                    'PO_LOOKUP_CODES', x_valid);
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                         'AP_SUPPLIERS_INT',
                         p_vendor_rec.vendor_interface_id,
                         'AP_INVALID_HOLD_ALL_PAY',
                         g_user_id,
                         g_login_id,
                         'Validate_Vendor') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Interface_Id:'
				||p_vendor_rec.vendor_interface_id
                            ||' ,Hold_All_Payments_Flag:'
                              ||p_vendor_rec.hold_all_payments_flag);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_HOLD_ALL_PAY');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                    END IF;
                  END IF;
   		END IF;

    		---------------------------------------------------------------
    		l_debug_info := 'Call to Validate always_take_disc_flag';
    		----------------------------------------------------------------
     		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate always_take_disc_flag
		--
   		IF p_vendor_rec.always_take_disc_flag is NOT NULL
               AND p_vendor_rec.always_take_disc_flag <> ap_null_char THEN

      			Validate_Lookups( 'ALWAYS_TAKE_DISC_FLAG',
			p_vendor_rec.always_take_disc_flag,'YES/NO',
                                    'PO_LOOKUP_CODES', x_valid);
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                         'AP_SUPPLIERS_INT',
                         p_vendor_rec.vendor_interface_id,
                         'AP_INVALID_TAKE_DISC',
                         g_user_id,
                         g_login_id,
                         'Validate_Vendor') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Interface_Id:'
				||p_vendor_rec.vendor_interface_id
                            ||' ,Always_Take_Disc_Flag:'
                              ||p_vendor_rec.always_take_disc_flag);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_TAKE_DISC');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                    END IF;
                  END IF;
   		END IF;

		----------------------------------------------------------------
    		l_debug_info := 'Call to Validate Vendor Number';
    		----------------------------------------------------------------
     		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    		END IF;

		-- Generate and validate Vendor Number

        	l_segment1   := p_vendor_rec.segment1;

        	Check_valid_vendor_num(l_segment1,
		                       x_valid);

                   IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                         'AP_SUPPLIERS_INT',
                         p_vendor_rec.vendor_interface_id,
                         'AP_NULL_VENDOR_NUMBER',     --bug5568861
                         g_user_id,
                         g_login_id,
                         'Validate_Vendor') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Interface_Id:'
				||p_vendor_rec.vendor_interface_id);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_NULL_VENDOR_NUMBER');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                    END IF;
                  END IF;

    		----------------------------------------------------------------
    		l_debug_info := 'Call to Validate match_option';
    		----------------------------------------------------------------
     		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate match_option
		--
   		IF p_vendor_rec.match_option is NOT NULL
               AND p_vendor_rec.match_option <> ap_null_char THEN

     			Check_Valid_Match_Option(p_vendor_rec.match_option,
                              x_valid
                              );
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                         'AP_SUPPLIERS_INT',
                         p_vendor_rec.vendor_interface_id,
                         'AP_INVALID_MATCH_OPTION',
                         g_user_id,
                         g_login_id,
                         'Validate_Vendor') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Interface_Id:'
				||p_vendor_rec.vendor_interface_id
                            ||' ,Match_Option:'
                              ||p_vendor_rec.match_option);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_MATCH_OPTION');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                    END IF;
                  END IF;
   		END IF;

    		---------------------------------------------------------------
    		l_debug_info :=
		'Call to Validate awt_group_id and awt_group_name';
    		---------------------------------------------------------------
     		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate awt_group_id and awt_group_name
		--
   		IF ((p_vendor_rec.awt_group_id is NOT NULL AND
                 p_vendor_rec.awt_group_id <> ap_null_num)
		or (p_vendor_rec.awt_group_name is NOT NULL AND
                p_vendor_rec.awt_group_name <> ap_null_char)) AND
		(p_vendor_rec.allow_awt_flag = 'Y') THEN

        		Chk_awt_grp_id_name(p_vendor_rec.awt_group_id,
                            p_vendor_rec.awt_group_name,
                            p_vendor_rec.allow_awt_flag,
                            x_valid
                            );

                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                         'AP_SUPPLIERS_INT',
                         p_vendor_rec.vendor_interface_id,
                         'AP_INCONSISTENT_AWT_GROUP',
                         g_user_id,
                         g_login_id,
                         'Validate_Vendor') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Interface_Id:'
				||p_vendor_rec.vendor_interface_id
                            ||' ,Awt_Group_Id: '||p_vendor_rec.awt_group_id
                            ||' ,Awt_Group_Name:'
				||p_vendor_rec.awt_group_name);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INCONSISTENT_AWT_GROUP');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                    END IF;
                  END IF;

  		 END IF;

                  /* Bug 9589179 */
                   ---------------------------------------------------------------
    		l_debug_info :=
		'Call to Validate pay_awt_group_id and pay_awt_group_name';
    		---------------------------------------------------------------
     		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate pay_awt_group_id and pay_awt_group_name
		--

   		IF ((p_vendor_rec.pay_awt_group_id is NOT NULL AND
                 p_vendor_rec.pay_awt_group_id <> ap_null_num)
		or (p_vendor_rec.pay_awt_group_name is NOT NULL AND
                p_vendor_rec.pay_awt_group_name <> ap_null_char)) AND
		(p_vendor_rec.allow_awt_flag = 'Y') THEN

        		Chk_pay_awt_grp_id_name(p_vendor_rec.pay_awt_group_id,
                            p_vendor_rec.pay_awt_group_name,
                            p_vendor_rec.allow_awt_flag,
                            x_valid
                            );

                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                         'AP_SUPPLIERS_INT',
                         p_vendor_rec.vendor_interface_id,
                         'AP_INCONSISTENT_AWT_GROUP',
                         g_user_id,
                         g_login_id,
                         'Validate_Vendor') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Interface_Id:'
				||p_vendor_rec.vendor_interface_id
                            ||' ,Awt_Group_Id: '||p_vendor_rec.pay_awt_group_id
                            ||' ,Awt_Group_Name:'
				||p_vendor_rec.pay_awt_group_name);
                        END IF;
                      END IF;
                    ELSE

                        FND_MESSAGE.SET_NAME('SQLAP','AP_INCONSISTENT_AWT_GROUP');
                        FND_MSG_PUB.ADD;

                    END IF;
                  END IF;

  		 END IF; /* Bug9589179 */
		------------------------------------------------------------------------
    		l_debug_info := 'Call to Validate Hold_by';
    		------------------------------------------------------------------------
     		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    		END IF;

		-- Hold_by validation

   		IF p_vendor_rec.hold_by is NOT NULL
               AND p_vendor_rec.hold_by <> ap_null_num THEN
     			Check_Valid_Hold_by (p_vendor_rec.hold_by,
                         x_valid);

			IF NOT x_valid THEN
       				x_return_status := FND_API.G_RET_STS_ERROR;
     			END IF;
   		END IF;

		------------------------------------------------------------------------
    		l_debug_info := 'Call to Validate Terms_Id and Terms_Name';
    		------------------------------------------------------------------------
     		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    		END IF;

		-- Terms_Id and Terms_Name validation

   		IF ((p_vendor_rec.terms_id is NOT NULL AND
                 p_vendor_rec.terms_id <> ap_null_num) OR
			    (p_vendor_rec.terms_name is NOT NULL AND
                   p_vendor_rec.terms_name <> ap_null_char) OR
             (p_vendor_rec.default_terms_id is NOT NULL AND
                   p_vendor_rec.default_terms_id <> ap_null_num) --6393761
             ) THEN

        		Check_terms_id_code(p_vendor_rec.terms_id,
                               p_vendor_rec.terms_name,
                               p_vendor_rec.default_terms_id,
                               x_valid);

                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                         'AP_SUPPLIERS_INT',
                         p_vendor_rec.vendor_interface_id,
                         'AP_INCONSISTENT_TERM',
                         g_user_id,
                         g_login_id,
                         'Validate_Vendor') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Interface_Id: '
				||p_vendor_rec.vendor_interface_id
                            ||' ,Terms_Id: '||p_vendor_rec.terms_id
                            ||' ,Terms_Name: '||p_vendor_rec.terms_name);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INCONSISTENT_TERM');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                    END IF;
                  END IF;
                END IF;


	END IF; -- not ISETUP
    END IF; --p_mode

    -- End of API body

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
	COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1,
    -- get message info.
    FND_MSG_PUB.Count_And_Get(
	p_count         	=>      x_msg_count     	,
        p_data          	=>      x_msg_data
    	);


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Validate_Vendor_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Validate_Vendor_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);
	WHEN OTHERS THEN
		ROLLBACK TO Validate_Vendor_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);
END Validate_Vendor;

PROCEDURE Create_Vendor_Site
( 	p_api_version           IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	IN  	NUMBER	:=
						FND_API.G_VALID_LEVEL_FULL,
	x_return_status		OUT	NOCOPY VARCHAR2		  	,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_vendor_site_rec	IN	r_vendor_site_rec_type,
	x_vendor_site_id	OUT	NOCOPY NUMBER,
	x_party_site_id		OUT	NOCOPY NUMBER,
	x_location_id		OUT	NOCOPY NUMBER
)
IS
    l_api_name			CONSTANT VARCHAR2(30)	:= 'Create_Vendor_Site';
    l_api_version           	CONSTANT NUMBER 		:= 1.0;

    l_def_org_id			NUMBER;
    l_party_site_rec			HZ_PARTY_SITE_V2PUB.party_site_rec_type;
    l_location_rec			HZ_LOCATION_V2PUB.location_rec_type;

    -- variables for retrieving defaults from PO_VENDORS
    l_rowid                         	VARCHAR2(255);
    l_vendor_site_id                	NUMBER;
    l_vendor_site_code              	VARCHAR2(255);
    l_purchasing_site_flag          	VARCHAR2(255);
    l_rfq_only_site_flag            	VARCHAR2(255);
    l_pay_site_flag                 	VARCHAR2(255);
    l_attention_ar_flag             	VARCHAR2(255);
    l_customer_num                  	VARCHAR2(255);
    l_ship_to_location_id           	NUMBER;
    l_bill_to_location_id           	NUMBER;
    l_ship_via_lookup_code          	VARCHAR2(255);
    l_sys_ship_via_lookup_code          VARCHAR2(255);
    l_freight_terms_lookup_code     	VARCHAR2(255);
    l_fob_lookup_code               	VARCHAR2(255);
    l_fax                           	VARCHAR2(255);
    l_fax_area_code                 	VARCHAR2(255);
    l_telex                         	VARCHAR2(255);
    l_payment_method_lookup_code    	VARCHAR2(255);
    l_bank_account_name             	VARCHAR2(255);
    l_bank_account_num              	VARCHAR2(255);
    l_bank_num                      	VARCHAR2(255);
    l_bank_account_type             	VARCHAR2(255);
    l_terms_date_basis              	VARCHAR2(255);
    l_sup_terms_date_basis                  VARCHAR2(255);
    l_current_catalog_num           	VARCHAR2(255);
    l_distribution_set_id           	NUMBER;
    l_future_pay_ccid     	NUMBER;
    l_prepay_code_combination_id    	NUMBER;
    l_pay_group_lookup_code         	VARCHAR2(255);
    l_sup_pay_group_lookup_code             VARCHAR2(255);
    l_payment_priority              	NUMBER;
    l_terms_id                      	NUMBER;
    l_sup_terms_id                          NUMBER;
    l_invoice_amount_limit          	NUMBER;
    l_pay_date_basis_lookup_code    	VARCHAR2(255);
    l_sup_pay_date_basis_lk_code        VARCHAR2(255);
    l_always_take_disc_flag         	VARCHAR2(255);
    l_sup_always_take_disc_flag             VARCHAR2(255);
    l_invoice_currency_code         	VARCHAR2(255);
    l_sup_invoice_currency_code             VARCHAR2(255);
    l_payment_currency_code         	VARCHAR2(255);
    l_sup_payment_currency_code             VARCHAR2(255);
    l_hold_all_payments_flag        	VARCHAR2(255);
    l_hold_future_payments_flag     	VARCHAR2(255);
    l_hold_reason                   	VARCHAR2(255);
    l_hold_unmatched_invoices_flag  	VARCHAR2(255);
    l_match_option                  	VARCHAR2(255);
    l_create_debit_memo_flag        	VARCHAR2(255);
    l_tax_reporting_site_flag       	VARCHAR2(255);
    l_attribute_category            	VARCHAR2(255);
    l_validation_number             	NUMBER;
    l_exclude_freight_from_disc     	VARCHAR2(255);
    l_check_digits                  	VARCHAR2(255);
    l_address_style                 	VARCHAR2(255);
    l_language                      	VARCHAR2(255);
    l_allow_awt_flag                	VARCHAR2(255);
    l_awt_group_id                  	NUMBER;
    l_pay_on_code                   	VARCHAR2(255);
    l_default_pay_site_id           	NUMBER;
    l_pay_on_receipt_summary_code   	VARCHAR2(255);
    l_vendor_site_code_alt          	VARCHAR2(255);
    l_address_lines_alt             	VARCHAR2(255);
    l_pcard_site_flag               	VARCHAR2(255);
    l_country_of_origin_code        	VARCHAR2(255);
    l_calling_sequence              	VARCHAR2(255);
    l_shipping_location_id          	NUMBER;
    l_supplier_notif_method         	VARCHAR2(255);
    l_email_address                 	VARCHAR2(255);
    l_remittance_email              	VARCHAR2(255);
    l_bank_charge_bearer            	VARCHAR2(255);
    l_sup_bank_charge_bearer                VARCHAR2(255);

    l_inventory_org_id                  NUMBER;

    l_old_org_id                    	VARCHAR2(255);
    l_org_id                            NUMBER;
    l_not_used                     	VARCHAR2(2000);
    l_default_country               	VARCHAR2(255);
    l_federal_reportable_flag		VARCHAR2(1);    -- Supplier Import
    l_org_type_lookup_code              VARCHAR2(25);   -- Supplier Import
    l_set_of_books_id                   NUMBER;         -- Supplier Import
    l_pay_on_rec_summary_code           VARCHAR2(25);   -- Supplier Import

    l_duns_number                       VARCHAR2(30);
    l_tolerance_id                      NUMBER;

    l_accts_pay_ccid_def                VARCHAR2(255);
    l_prepay_ccid_def                   VARCHAR2(255);
    l_future_pay_ccid_def               VARCHAR2(255);

    l_user_id                		number := FND_GLOBAL.USER_ID;
    l_last_update_login      		number := FND_GLOBAL.LOGIN_ID;
    l_program_application_id 		number := FND_GLOBAL.prog_appl_id;
    l_program_id             		number := FND_GLOBAL.conc_program_id;
    l_request_id             		number := FND_GLOBAL.conc_request_id;

    l_val_return_status                 VARCHAR2(50);
    l_val_msg_count                     NUMBER;
    l_val_msg_data                      VARCHAR2(2000);
    l_loc_return_status                 VARCHAR2(50);
    l_loc_msg_count                     NUMBER;
    l_loc_msg_data                      VARCHAR2(2000);
    l_site_return_status                 VARCHAR2(50);
    l_site_msg_count                     NUMBER;
    l_site_msg_data                      VARCHAR2(2000);
    l_pay_return_status                 VARCHAR2(50);
    l_pay_msg_count                     NUMBER;
    l_pay_msg_data                      VARCHAR2(2000);
    l_org_context			VARCHAR2(1);
    l_multi_org_flag			VARCHAR2(1);
    l_debug_info			VARCHAR2(2000);
    l_party_id				NUMBER;
    l_vendor_type_lookup_code		VARCHAR2(30);
    l_vendor_site_rec			r_vendor_site_rec_type;
    l_accts_pay_ccid                	NUMBER;
    l_prepay_ccid                   	NUMBER;
    l_future_ccid                   	NUMBER;
    l_last_updated_by			NUMBER;
    l_created_by			NUMBER;
    l_default_country_code		VARCHAR2(25);
    l_home_country_code			VARCHAR2(25);
    l_location_valid			VARCHAR2(1);
    l_party_site_valid			VARCHAR2(1);
    l_payee_valid                  	VARCHAR2(1);
    l_loc_id				NUMBER;
    l_party_site_id			NUMBER;
    l_party_site_number			VARCHAR2(30);
    l_org_id_derive                     NUMBER;
    x_valid                             BOOLEAN;
    -- bug 7371143 start
    l_offset_tax_flag	                VARCHAR2(1);
    l_auto_tax_calc_flag                VARCHAR2(1);
    -- bug 7371143 end

    /* Variable Declaration for IBY */
    ext_payee_tab
		IBY_DISBURSEMENT_SETUP_PUB.External_Payee_Tab_Type;
    ext_payee_id_tab
		IBY_DISBURSEMENT_SETUP_PUB.Ext_Payee_Id_Tab_Type;
    ext_payee_create_tab
		IBY_DISBURSEMENT_SETUP_PUB.Ext_Payee_Create_Tab_Type;

    l_ext_payee_rec IBY_DISBURSEMENT_SETUP_PUB.EXTERNAL_PAYEE_REC_TYPE;

      -- Bug#7506443 start
       l_tax_classification_code         ZX_PARTY_TAX_PROFILE.TAX_CLASSIFICATION_CODE%TYPE;
       l_pymt_method_code     iby_external_payees_all.default_payment_method_code%TYPE;
       l_inactive_date        iby_external_payees_all.Inactive_Date%TYPE;
       l_primary_flag         iby_ext_party_pmt_mthds.primary_flag%TYPE;
       l_Exclusive_Pay_Flag    IBY_EXTERNAL_PAYEES_ALL.exclusive_payment_flag%TYPE;
-- Debug Bug 8769088 start
    l_delivery_channel_code IBY_EXTERNAL_PAYEES_ALL.delivery_channel_code%TYPE;
    l_bank_instruction1_code IBY_EXTERNAL_PAYEES_ALL.bank_instruction1_code%TYPE;
    l_bank_instruction2_code IBY_EXTERNAL_PAYEES_ALL.bank_instruction2_code%TYPE;
    l_bank_instr_detail IBY_EXTERNAL_PAYEES_ALL.bank_instruction_details%TYPE;
    l_settlement_priority IBY_EXTERNAL_PAYEES_ALL.settlement_priority%TYPE;
    l_payment_text_msg1 IBY_EXTERNAL_PAYEES_ALL.payment_text_message1%TYPE;
    l_payment_text_msg2 IBY_EXTERNAL_PAYEES_ALL.payment_text_message2%TYPE;
    l_payment_text_msg3 IBY_EXTERNAL_PAYEES_ALL.payment_text_message3%TYPE;
    l_payment_reason_code IBY_EXTERNAL_PAYEES_ALL.payment_reason_code%TYPE;
    l_paymt_rsn_comts IBY_EXTERNAL_PAYEES_ALL.payment_reason_comments%TYPE;
    l_pmt_format IBY_EXTERNAL_PAYEES_ALL.payment_format_code%TYPE;
    l_remt_advc_dlvry_mthd IBY_EXTERNAL_PAYEES_ALL.remit_advice_delivery_method%TYPE;
    l_remit_advice_email IBY_EXTERNAL_PAYEES_ALL.remit_advice_email%TYPE;
    l_remit_advice_fax IBY_EXTERNAL_PAYEES_ALL.remit_advice_fax%TYPE;
-- Debug Bug 8769088 end
       -- Bug#7506443 start

    l_sync_return_status                 VARCHAR2(50);
    l_sync_msg_count                     NUMBER;
    l_sync_msg_data                      VARCHAR2(2000);
    l_sup_awt_flag                       VARCHAR2(1);
	-- BUG 6739544 Start
	ORG_ID_EXCEPTION EXCEPTION;
	-- BUG 6739544 End

	l_party_site_num			VARCHAR2(1); -- Bug 6823885
	l_addr_val_status                       VARCHAR2(255); -- bug9128869
	l_addr_warn_msg                         VARCHAR2(2000); -- bug9128869

    L_PARTY_TAX_PROFILE_ID               zx_party_tax_profile.party_tax_profile_id%type; -- Bug 7207314
    l_return_status                      VARCHAR2(2000); --Bug 7207314
       -- changes for Bug#7506443 start
          Cursor get_iby_dtls_csr(p_prty_id NUMBER) is
          SELECT pmtmthdAssignmentseo.Payment_Method_Code,
                 pmtmthdAssignmentseo.InActive_Date,
                 pmtmthdAssignmentseo.Primary_Flag,
              --iep.exclusive_payment_flag 	.. B 8900634/8889211
              NVL(iep.exclusive_payment_flag,'N') exclusive_payment_flag,  -- B 8900634/8889211
              iep.Bank_instruction1_code, -- Bug 8769088 start
	      iep.Bank_instruction2_code,
	      iep.Delivery_channel_code,
	      iep.bank_instruction_details,
	      iep.settlement_priority,
	      iep.payment_text_message1,
	      iep.payment_text_message2,
	      iep.payment_text_message3,
	      iep.bank_charge_bearer,
	      iep.payment_reason_code,
	      iep.payment_reason_comments,
	      iep.payment_format_code,
	      iep.remit_advice_delivery_method, -- separate remittance advice delivery
	      iep.remit_advice_email,  -- separate remittance advice delivery
	      iep.remit_advice_fax    -- separate remittance advice delivery
                                  -- Bug 8769088 end
           FROM iBy_Payment_Methods_vl pmthds,
                iBy_ext_Party_pmt_mthds pmtmthdAssignmentseo,
                iBy_External_Payees_All iep
          WHERE pmthds.Payment_Method_Code = pmtmthdAssignmentseo.Payment_Method_Code (+)
            AND pmtmthdAssignmentseo.Payment_Flow = 'DISBURSEMENTS'
            AND Nvl(pmthds.InActive_Date,Trunc(SYSDATE + 1)) > Trunc(SYSDATE)
            AND pmtmthdAssignmentseo.Payment_Function = 'PAYABLES_DISB'
            AND pmtmthdAssignmentseo.ext_pmt_Party_Id = iep.ext_payee_id
            AND iep.Payee_Party_Id = p_prty_id
            AND Party_Site_Id IS NULL
            AND Supplier_Site_Id IS NULL;

 L_ROUNDING_LEVEL_CODE                                VARCHAR2(30) ; /* B 9530837  */
 L_ROUNDING_RULE_CODE                                 VARCHAR2(30) ; /* B 9530837  */
 L_INCLUSIVE_TAX_FLAG                                 VARCHAR2(1) ; /* B 9530837  */



BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT	Create_Vendor_Site_PUB;

    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
    THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
    END IF;
    -- Bug 5055120
    -- This call is incorrect. The correct call is to have the calling
    -- modules set the context and call this API with the right ORG_ID.

    -- Bug 6812010 :Due to 5055120, Payables' own supplier site import program fails
    -- because MO initialization is not happening.To fix 6812010 and keep 5055120 intact,
    -- strategy is that if calling application id is not AP then we will not call MO_GLOBAL.INIT
    -- since it is calling module's responsibility to perform MO initialization.
    -- Bug 6930102
    If (l_program_application_id = 200 OR l_program_application_id = -1)then
    MO_GLOBAL.INIT ('SQLAP');
    end if;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_val_return_status := FND_API.G_RET_STS_SUCCESS;
    l_loc_return_status := FND_API.G_RET_STS_SUCCESS;
    l_site_return_status := FND_API.G_RET_STS_SUCCESS;
    l_pay_return_status := FND_API.G_RET_STS_SUCCESS;
    l_sync_return_status := FND_API.G_RET_STS_SUCCESS;

    -- API body
    ------------------------------------------------------------------------
    l_debug_info := 'Call Org_Id and Operating_unit_name validation for Import';
    ------------------------------------------------------------------------
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    END IF;

    -- Org_Id and Operating_unit_name validation
    -- This is to make sure if org_id is not provided but
    -- org_name is provided then derive the org_id from operating_unit

    IF (p_vendor_site_rec.org_id is NULL AND
        p_vendor_site_rec.org_name is NOT NULL) THEN

      Check_org_id_name(l_org_id_derive,
                        p_vendor_site_rec.org_name,
                        'AP_SUPPLIER_SITES_INT',
                        p_vendor_site_rec.vendor_site_interface_id,
                        x_valid);

      IF NOT x_valid THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

    END IF;

    IF l_org_id_derive IS NOT NULL THEN
         l_def_org_id := l_org_id_derive;
    ELSE
         l_def_org_id := p_vendor_site_rec.org_id;
    END IF;

    IF l_def_org_id IS NULL THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF g_source = 'IMPORT' THEN
          IF (Insert_Rejections(
                    'AP_SUPPLIER_SITES_INT',
                    p_vendor_site_rec.vendor_site_interface_id,
                    'AP_ORG_INFO_NULL',     --bug 5568861
                    g_user_id,
                    g_login_id,
                    'Create_Vendor_Site') <> TRUE) THEN
           --
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                   l_api_name,'Parameters: '
                 ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                   ||' ,Vendor_Site_Code: '||p_vendor_site_rec.vendor_site_code);
            END IF;
          END IF;
        ELSE
            -- Bug 5491139 hkaniven start --
            FND_MESSAGE.SET_NAME('SQLAP','AP_ORG_INFO_NULL');
            FND_MSG_PUB.ADD;
            -- Bug 5491139 hkaniven end --
            -- Bug 8438716 Start
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                   l_api_name,'Parameters: '
                 ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                   ||' ,Vendor_Site_Code: '||p_vendor_site_rec.vendor_site_code);
            END IF;
            -- Bug 8438716 End

        END IF;
    --    RAISE FND_API.G_EXC_ERROR;         BUG 6739544
	      RAISE ORG_ID_EXCEPTION; -- BUG 6739544
    END IF;
    -- Bug 5055120
    -- Added validation of org_id
    BEGIN

      MO_GLOBAL.validate_orgid_pub_api(l_def_org_id,
                                     'N',
                                     x_return_status);
    EXCEPTION
      WHEN OTHERS
      THEN
        IF g_source = 'IMPORT' THEN
          IF (Insert_Rejections(
                    'AP_SUPPLIER_SITES_INT',
                    p_vendor_site_rec.vendor_site_interface_id,
                    'AP_ORG_INFO_NULL',  --bug 5568861
                    g_user_id,
                    g_login_id,
                    'Create_Vendor_Site') <> TRUE) THEN
           --
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                   l_api_name,'Parameters: '
                 ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                   ||' ,Vendor_Site_Code: '||p_vendor_site_rec.vendor_site_code);
            END IF;
          END IF;
        ELSE
            -- Bug 5491139 hkaniven start --
            FND_MESSAGE.SET_NAME('SQLAP','AP_ORG_INFO_NULL');
            FND_MSG_PUB.ADD;
            -- Bug 5491139 hkaniven end --
            -- Bug 8438716 Start
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                   l_api_name,'Error after MO_GLOBAL.validate_orgid_pub_api Parameters: '
                 ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                   ||' ,Vendor_Site_Code: '||p_vendor_site_rec.vendor_site_code);
            END IF;
            -- Bug 8438716 End
        END IF;
      --  RAISE FND_API.G_EXC_ERROR;
		RAISE ORG_ID_EXCEPTION; -- BUG 6739544
    END;


    l_org_context := mo_global.get_access_mode;

    IF nvl(l_org_context, 'K') <> 'S' THEN
	MO_GLOBAL.set_policy_context('S',l_def_org_id);
    END IF;

    SELECT nvl(multi_org_flag,'N')
    INTO l_multi_org_flag
    FROM FND_PRODUCT_GROUPS;

    l_vendor_site_rec := p_vendor_site_rec;

    l_vendor_site_rec.org_id := l_def_org_id;

    --Open Issue 14 -- need to call initialize procedure due to MOAC changes
    l_debug_info := 'Call to default CCIDs from FINANCIAL_SYSTEM_PARAMETERS';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    --
    -- Get default CCIDs from FINANCIAL_SYSTEM_PARAMETERS
    --

    ap_apxvdmvd_pkg.initialize(
        x_user_defined_vendor_num_code  => l_not_used,
        x_manual_vendor_num_type        => l_not_used,
        x_rfq_only_site_flag            => l_rfq_only_site_flag,
        x_ship_to_location_id           => l_ship_to_location_id,
        x_ship_to_location_code         => l_not_used,
        x_bill_to_location_id           => l_bill_to_location_id,
        x_bill_to_location_code         => l_not_used,
        x_fob_lookup_code               => l_fob_lookup_code,
        x_freight_terms_lookup_code     => l_freight_terms_lookup_code,
        x_terms_id                      => l_terms_id,
        x_terms_disp                    => l_not_used,
        x_always_take_disc_flag         => l_always_take_disc_flag,
        x_invoice_currency_code         => l_invoice_currency_code,
        x_org_id                        => l_vendor_site_rec.org_id,
        x_set_of_books_id               => l_not_used,
        x_short_name                    => l_not_used,
        x_payment_currency_code         => l_payment_currency_code,
        x_accts_pay_ccid                => l_accts_pay_ccid,
        x_future_dated_payment_ccid     => l_future_pay_ccid,
        x_prepay_code_combination_id    => l_prepay_ccid,
        x_vendor_pay_group_lookup_code  => l_pay_group_lookup_code,
        x_sys_auto_calc_int_flag        => l_not_used,
        x_terms_date_basis              => l_terms_date_basis,
        x_terms_date_basis_disp         => l_not_used,
        x_chart_of_accounts_id          => l_not_used,
        x_fob_lookup_disp               => l_not_used,
        x_freight_terms_lookup_disp     => l_not_used,
        x_vendor_pay_group_disp         => l_not_used,
        /* x_fin_require_matching          => l_hold_unmatched_invoices_flag, --Bug 7651872 Commented for Bug#9193468 */
        x_fin_require_matching          => l_not_used, /* Added for bug#9193468 */
        x_sys_require_matching          => l_not_used,
        x_fin_match_option              => l_not_used,
        x_po_create_dm_flag             => l_not_used,
        x_exclusive_payment             => l_not_used,
        x_vendor_auto_int_default       => l_not_used,
        x_inventory_organization_id     => l_not_used,
        x_ship_via_lookup_code          => l_ship_via_lookup_code,
        x_ship_via_disp                 => l_not_used,
        x_sysdate                       => l_not_used,
        x_enforce_ship_to_loc_code      => l_not_used,
        x_receiving_routing_id          => l_not_used,
        x_qty_rcv_tolerance             => l_not_used,
        x_qty_rcv_exception_code        => l_not_used,
        x_days_early_receipt_allowed    => l_not_used,
        x_days_late_receipt_allowed     => l_not_used,
        x_allow_sub_receipts_flag       => l_not_used,
        x_allow_unord_receipts_flag     => l_not_used,
        x_receipt_days_exception_code   => l_not_used,
        x_enforce_ship_to_loc_disp      => l_not_used,
        x_qty_rcv_exception_disp        => l_not_used,
        x_receipt_days_exception_disp   => l_not_used,
        x_receipt_required_flag         => l_not_used,
        x_inspection_required_flag      => l_not_used,
        x_payment_method_lookup_code    => l_not_used,
        x_payment_method_disp           => l_not_used,
        x_pay_date_basis_lookup_code    => l_not_used,
        x_pay_date_basis_disp           => l_not_used,
        x_receiving_routing_name        => l_not_used,
        x_ap_inst_flag                  => l_not_used,
        x_po_inst_flag                  => l_not_used,
        x_home_country_code             => l_home_country_code,
        x_default_country_code          => l_default_country,
        x_default_country_disp          => l_not_used,
        x_default_awt_group_id          => l_awt_group_id,
        x_default_awt_group_name        => l_not_used,
        x_allow_awt_flag                => l_allow_awt_flag,
        x_base_currency_code            => l_not_used,
        x_address_style                 => l_not_used,
        x_use_bank_charge_flag          => l_not_used,
        x_bank_charge_bearer            => l_bank_charge_bearer,
        x_calling_sequence              => null);

    -- Retrieve defaults from the vendor master

    /* Bug 7155121 Modified the below select to get values from both ap_system_parameters_all and po_vendors*/

    /* Bug 8200984 - Modified to get these fields from AP_PRODUCT_SETUP instead of
AP_SYSTEM_PARAMETERS.
       terms_date_basis
       match_option,
       pay_date_basis_lookup_code,
       terms_id
    */

    /* Bug 8280106 - Modified to get these fields from Supplier Only.
       terms_date_basis
       match_option,
       pay_date_basis_lookup_code,
       terms_id
    */

        /*             BUG 8892266
       Done Changes for Supplier Attribute Project
       Have modified the defaulting logic for follwowing columns :
       invoice_currency_code,
       terms_date_basis,
       pay_date_basis_lookup_code,
       terms_id and
       pay_group_lookup_code

       Now the values will be defaulting from ap_system_parameters_all
       to ap_supplier_sites_all and in case if it is null in ap_system_parameters_all then
       it will default from ap_suppliers as per bug8892266  */



    SELECT   --8892266 pv.terms_date_basis -- Bug#7506443 --bug 8200984 (changed to aps)--Bug8280106
             --8892266, pv.pay_group_lookup_code
          pv.payment_priority
--	, asp.always_take_disc_flag	.. B# 8260603
	, pv.always_take_disc_flag	-- B# 8260603
        , pv.hold_all_payments_flag
        , pv.hold_future_payments_flag
        , pv.hold_reason
        --Bug6317600 Commenting awt_group_id. AWT should be defaulted from Payables options  and not Supplier
        --, pv.awt_group_id
        , asp.bank_charge_bearer
        , pv.match_option -- bug 8200984 (changed to aps)-Bug 8280106(changed to default from Supplier only)
--8892266        , pv.pay_date_basis_lookup_code -- bug 8200984 (changed to aps)-Bug 8280106(changed to default from Supplier only)
        , pv.invoice_amount_limit
--8892266        , NVL(pv.invoice_currency_code,asp.invoice_currency_code) --bug:7282105
--8892266        , NVL(pv.payment_currency_code,asp.payment_currency_code) --bug:7282105
--8892266        , pv.terms_id   -- Bug#7506443--8200984 (changed to aps)-Bug 8280106(changed to default from Supplier only)
        , pv.federal_reportable_flag
        , pv.organization_type_lookup_code
        , asp.set_of_books_id
        --Bug 7651872, asp.hold_unmatched_invoices_flag
        , decode(pv.vendor_type_lookup_code
             ,'EMPLOYEE'
             ,asp.hold_unmatched_invoices_flag
             ,pv.hold_unmatched_invoices_flag) /* Added for bug#9193468 */
             /* ,l_hold_unmatched_invoices_flag) -- Bug 8614887 Commented for bug#9193468 */
        , pv.exclude_freight_from_discount
        , pv.party_id
        , pv.vendor_type_lookup_code
        , nvl(pv.allow_awt_flag, 'N')
        , pv.CREATE_DEBIT_MEMO_FLAG --Bug8373166
    INTO
--8892266	 l_sup_terms_date_basis
--8892266	, l_sup_pay_group_lookup_code
          l_payment_priority
	, l_sup_always_take_disc_flag
	, l_hold_all_payments_flag
        , l_hold_future_payments_flag
	, l_hold_reason
	--Bug6317600
	--, l_awt_group_id
	, l_sup_bank_charge_bearer
	, l_match_option
--8892266        , l_sup_pay_date_basis_lk_code
        , l_invoice_amount_limit
--8892266	, l_sup_invoice_currency_code
--8892266   , l_sup_payment_currency_code
--8892266	, l_sup_terms_id
        , l_federal_reportable_flag
        , l_org_type_lookup_code
	, l_set_of_books_id
	--Bug 7651872, l_hold_unmatched_invoices_flag
        , l_hold_unmatched_invoices_flag --Bug 8614887
        , l_exclude_freight_from_disc
	, l_party_id
	, l_vendor_type_lookup_code
        , l_sup_awt_flag
        ,l_create_debit_memo_flag --Bug8373166
    FROM  po_vendors pv,
          ap_system_parameters_all asp,
          ap_product_setup aps    -- Bug 8200984
    WHERE pv.vendor_id = p_vendor_site_rec.vendor_id
    AND   asp.org_id=l_def_org_id;

    l_last_updated_by               		:=  fnd_global.user_id;
    l_last_update_login             		:=  fnd_global.login_id;
    l_created_by                    		:=  fnd_global.user_id;

    /* Start of bug8892266 */
    SELECT  NVL(asp.invoice_currency_code, pv.invoice_currency_code) invoice_currency_code,
            NVL(asp.payment_currency_code, pv.payment_currency_code) payment_currency_code,
            NVL(asp.vendor_pay_group_lookup_code, pv.pay_group_lookup_code) pay_group_lookup_code,
            NVL(asp.terms_date_basis, pv.terms_date_basis) terms_date_basis,
            NVL(asp.pay_date_basis_lookup_code, pv.pay_date_basis_lookup_code) pay_date_basis_lookup_code,
            NVL(asp.terms_id, pv.terms_id) terms_id
    INTO    l_sup_invoice_currency_code,
            l_sup_payment_currency_code,
            l_sup_pay_group_lookup_code,
            l_sup_terms_date_basis,
            l_sup_pay_date_basis_lk_code,
            l_sup_terms_id
    FROM    po_vendors pv,
            ap_system_parameters_all asp
    WHERE   pv.vendor_id = p_vendor_site_rec.vendor_id
    AND     asp.org_id=l_def_org_id;

     /* Partial End of bug8892266 */


     --Bug6679696
    IF l_vendor_type_lookup_code = 'EMPLOYEE' then
    l_vendor_site_rec.pay_site_flag := nvl(l_vendor_site_rec.pay_site_flag,'Y');
    END IF;
    G_vendor_type_lookup_code := l_vendor_type_lookup_code;
    l_vendor_site_rec.rfq_only_site_flag
	:=  nvl(l_vendor_site_rec.rfq_only_site_flag, l_rfq_only_site_flag);
    l_vendor_site_rec.attention_ar_flag             :=
		nvl(l_vendor_site_rec.attention_ar_flag, 'N');
    -- Bug 8627216 Start
    if (l_vendor_site_rec.SHIP_TO_LOCATION_CODE is null) then
    l_vendor_site_rec.ship_to_location_id
	:=  nvl(l_vendor_site_rec.ship_to_location_id, l_ship_to_location_id);
    end if;
    if (l_vendor_site_rec.BILL_TO_LOCATION_CODE is null) then
    l_vendor_site_rec.bill_to_location_id
	:=  nvl(l_vendor_site_rec.bill_to_location_id, l_bill_to_location_id);
    end if;
    -- Bug 8627216 End
    l_vendor_site_rec.ship_via_lookup_code
	:=  nvl(l_vendor_site_rec.ship_via_lookup_code, l_ship_via_lookup_code);
    l_vendor_site_rec.freight_terms_lookup_code
	:=  nvl(l_vendor_site_rec.freight_terms_lookup_code,
		l_freight_terms_lookup_code);
    l_vendor_site_rec.fob_lookup_code
	:=  nvl(l_vendor_site_rec.fob_lookup_code, l_fob_lookup_code);
     -- Bug#7506443 start
    /*    l_vendor_site_rec.terms_date_basis      :=
		nvl(l_vendor_site_rec.terms_date_basis, nvl(l_terms_date_basis,
/*bug8892266    l_vendor_site_rec.terms_date_basis      :=
		nvl(l_vendor_site_rec.terms_date_basis, nvl(l_sup_terms_date_basis,
				l_terms_date_basis));   */
l_vendor_site_rec.terms_date_basis      := NVL(l_vendor_site_rec.terms_date_basis, l_sup_terms_date_basis); --bug8892266

    -- Bug#7506443 end
    l_vendor_site_rec.accts_pay_code_combination_id
	:=  nvl(l_vendor_site_rec.accts_pay_code_combination_id,
		l_accts_pay_ccid);
    l_vendor_site_rec.future_dated_payment_ccid
	:=  nvl(l_vendor_site_rec.future_dated_payment_ccid,
		l_future_pay_ccid);
    l_vendor_site_rec.prepay_code_combination_id
	:=  nvl(l_vendor_site_rec.prepay_code_combination_id,
		l_prepay_ccid);
    -- Bug 5409457. Pay Group should be based supplier, if there is no value at
    -- supplier then from product setup level.
    /*  bug8892266   l_vendor_site_rec.pay_group_lookup_code
	:=  nvl(l_vendor_site_rec.pay_group_lookup_code,
		nvl(l_sup_pay_group_lookup_code, l_pay_group_lookup_code)); */   --bug8892266
l_vendor_site_rec.pay_group_lookup_code := NVL(l_vendor_site_rec.pay_group_lookup_code, l_sup_pay_group_lookup_code);--bug8892266

    l_vendor_site_rec.payment_priority
		:=  nvl(l_vendor_site_rec.payment_priority, l_payment_priority);
    -- Bug#7506443 start
    /*l_vendor_site_rec.terms_id  :=  nvl(l_vendor_site_rec.terms_id,
					nvl(l_terms_id, l_sup_terms_id));  */

/*l_vendor_site_rec.terms_id := NVL(l_vendor_site_rec.terms_id, l_sup_terms_id); --bug8892266   commented for Bug9318374 */

    -- Bug#8680310 start
    IF (l_vendor_site_rec.terms_name IS NULL OR
                 l_vendor_site_rec.terms_name = ap_null_char) THEN
      l_vendor_site_rec.terms_id  :=  nvl(l_vendor_site_rec.terms_id,
                                             nvl(l_sup_terms_id, l_terms_id));
    END IF;
    -- Bug#8680310 end
    -- Bug#7506443 end
    l_vendor_site_rec.invoice_amount_limit
	:=  nvl(l_vendor_site_rec.invoice_amount_limit, l_invoice_amount_limit);
    /* bug8892266   l_vendor_site_rec.pay_date_basis_lookup_code
	:=  nvl(l_vendor_site_rec.pay_date_basis_lookup_code,
		nvl(l_pay_date_basis_lookup_code, l_sup_pay_date_basis_lk_code)); */  --bug8892266
l_vendor_site_rec.pay_date_basis_lookup_code := NVL(l_vendor_site_rec.pay_date_basis_lookup_code, l_sup_pay_date_basis_lk_code); --bug8892266

    -- bug6680946
    l_vendor_site_rec.always_take_disc_flag
	:=  nvl(l_vendor_site_rec.always_take_disc_flag, l_sup_always_take_disc_flag);
   /*    l_vendor_site_rec.invoice_currency_code
	:=  nvl(l_vendor_site_rec.invoice_currency_code,
		nvl(l_sup_invoice_currency_code, l_invoice_currency_code )); --Bug 7282105 */ --bug8892266
l_vendor_site_rec.invoice_currency_code := NVL(l_vendor_site_rec.invoice_currency_code, l_sup_invoice_currency_code);  --bug8892266

    l_vendor_site_rec.payment_currency_code
	:=  nvl(l_vendor_site_rec.payment_currency_code,
		l_sup_payment_currency_code); --bug 8892266
    l_vendor_site_rec.hold_all_payments_flag
	:=  nvl(l_vendor_site_rec.hold_all_payments_flag,
		l_hold_all_payments_flag);
    l_vendor_site_rec.hold_future_payments_flag
	:=  nvl(l_vendor_site_rec.hold_future_payments_flag,
		l_hold_future_payments_flag);
    l_vendor_site_rec.hold_reason
		:=  nvl(l_vendor_site_rec.hold_reason, l_hold_reason);
    l_vendor_site_rec.hold_unmatched_invoices_flag
	:=  nvl(l_vendor_site_rec.hold_unmatched_invoices_flag,
		l_hold_unmatched_invoices_flag);
    l_vendor_site_rec.match_option
		:=  nvl(l_vendor_site_rec.match_option, l_match_option);
    l_vendor_site_rec.create_debit_memo_flag
		--:=  nvl(l_vendor_site_rec.create_debit_memo_flag, 'N');--Bug8373166
    	:=  nvl(l_vendor_site_rec.create_debit_memo_flag, l_create_debit_memo_flag);--Bug8373166
    l_vendor_site_rec.tax_reporting_site_flag
		:=  nvl(l_vendor_site_rec.tax_reporting_site_flag, 'N');
    l_vendor_site_rec.validation_number
		:=  nvl(l_vendor_site_rec.validation_number, 0);
    l_vendor_site_rec.exclude_freight_from_discount
	 :=  nvl(l_vendor_site_rec.exclude_freight_from_discount,
		l_exclude_freight_from_disc);
    --Bug 7384699 populate allow_awt_flag only iff Supplier awt_flag is enabled
    if(l_sup_awt_flag = 'Y') THEN
      l_vendor_site_rec.allow_awt_flag
                :=  nvl(l_vendor_site_rec.allow_awt_flag, l_allow_awt_flag);
    else
      l_vendor_site_rec.allow_awt_flag := 'N';
    end if;
    --Bug6317600 Populate awt_group_id only if allow_awt_flag is Y
    if nvl( l_vendor_site_rec.allow_awt_flag,'N') = 'Y'  and
    (p_vendor_site_rec.awt_group_name is NULL or p_vendor_site_rec.awt_group_name = ap_null_char) /*Bug 9592253 */
    THEN
    l_vendor_site_rec.awt_group_id
		:=  nvl(l_vendor_site_rec.awt_group_id, l_awt_group_id);
    end if;
    l_vendor_site_rec.bank_charge_bearer
	:=  nvl(l_vendor_site_rec.bank_charge_bearer,
		nvl(l_bank_charge_bearer, l_sup_bank_charge_bearer));
    l_vendor_site_rec.pcard_site_flag
		:=  nvl(l_vendor_site_rec.pcard_site_flag, 'N');
    l_vendor_site_rec.country_of_origin_code
	:=  nvl(l_vendor_site_rec.country_of_origin_code, l_default_country);
    l_vendor_site_rec.org_id  :=  nvl(l_vendor_site_rec.org_id, l_org_id);
    l_vendor_site_rec.duns_number
		:=  nvl(l_vendor_site_rec.duns_number, l_duns_number);

    validate_vendor_site(p_api_version => 1.0,
		p_init_msg_list => FND_API.G_FALSE,
		p_commit  => FND_API.G_FALSE,
		x_return_status => l_val_return_status,
		x_msg_count => l_val_msg_count,
		x_msg_data => l_val_msg_data,
		p_vendor_site_rec => l_vendor_site_rec,
		P_mode => 'I',
		P_calling_prog => 'NOT ISETUP',
		x_party_site_valid => l_party_site_valid,
		x_location_valid => l_location_valid,
		x_payee_valid	=> l_payee_valid,
		p_vendor_site_id => x_vendor_site_id);

    -- Bug 7429668 Adding condition of l_val_return_status to ensure that
	-- locations are created only if the validation passes successfully.
	IF l_location_valid = 'N' AND nvl(l_val_return_status,FND_API.G_RET_STS_SUCCESS) =
			FND_API.G_RET_STS_SUCCESS THEN -- location_id was null

	l_location_rec.created_by_module := 'AP_SUPPLIERS_API';
	l_location_rec.application_id := 200;
	l_location_rec.address_style := l_vendor_site_rec.address_style;
	l_location_rec.province := l_vendor_site_rec.province;
	l_location_rec.country := l_vendor_site_rec.country;
	l_location_rec.county := l_vendor_site_rec.county;
	l_location_rec.address1 := l_vendor_site_rec.address_line1;
	l_location_rec.address2 := l_vendor_site_rec.address_line2;
	l_location_rec.address3 := l_vendor_site_rec.address_line3;
	l_location_rec.address4 := l_vendor_site_rec.address_line4;
	l_location_rec.address_lines_phonetic := l_vendor_site_rec.address_lines_alt;
	l_location_rec.city := l_vendor_site_rec.city;
	l_location_rec.state := l_vendor_site_rec.state;
	l_location_rec.postal_code := l_vendor_site_rec.zip;

        -- The input language that we get from suppliers
        -- open interface will be NLS_LANGUAGE and will not be
        -- language code. So it needs to be converted to
        -- language_code before passed to TCA API.

        IF l_vendor_site_rec.language IS NOT NULL THEN
          BEGIN
            SELECT language_code
            INTO   l_location_rec.language
            FROM   fnd_languages
            WHERE  nls_language = l_vendor_site_rec.language;
          EXCEPTION
            WHEN OTHERS THEN
              l_location_rec.language := NULL;
          END;
        END IF;

	--Open Issue 4, check for needed parameters
        --Bug6648405
        --Bug 6753822 - Added NVL on vendor_type_lookup_code
       IF (NVL(l_vendor_type_lookup_code,'DUMMY') <> 'EMPLOYEE') then
	hz_location_v2pub.create_location(
	 	p_init_msg_list => FND_API.G_FALSE,
		p_location_rec => l_location_rec,
		p_do_addr_val => 'Y',  -- bug 9128869
		x_addr_val_status => l_addr_val_status, -- bug 9128869
		x_addr_warn_msg => l_addr_warn_msg, -- bug 9128869
	--	p_commit => FND_API.G_FALSE,
		x_return_status => l_loc_return_status,
		x_msg_count => l_loc_msg_count,
		x_msg_data => l_loc_msg_data,
		x_location_id => l_loc_id);

-- Bug 9128869 Start

		IF l_addr_val_status <> FND_API.G_RET_STS_SUCCESS THEN

          ------------------------------------------------------------------------
          l_debug_info := ' Address Validation status : '||l_addr_val_status;
          l_debug_info := l_debug_info ||' Address Warning message : '||l_addr_warn_msg;
          ------------------------------------------------------------------------

		  IF l_addr_val_status = 'W' THEN  -- Warning case is accepted as Validate case.
                                            -- Please refer PM commments in Bug 9128869.
              IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
              END IF;
		  END IF;

		  IF l_addr_val_status not in ('S','W') THEN

            x_return_status := FND_API.G_RET_STS_ERROR; -- If address validation fails then
                                                        -- throw the error message.
            IF g_source = 'IMPORT' THEN
              IF (Insert_Rejections(
                    'AP_SUPPLIER_SITES_INT',
                    p_vendor_site_rec.vendor_site_interface_id,
                    'AP_INVALID_TCA_ERROR',
                    g_user_id,
                    g_login_id,
                    'Validate_Vendor_Site') <> TRUE) THEN

                IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
                END IF;
              END IF;
            ELSE
                FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_TCA_ERROR');
                FND_MSG_PUB.ADD;
                IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
                END IF;
            END IF;
		  END IF;

		END IF;
-- Bug 9128869 End

		IF l_loc_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      ------------------------------------------------------------------------
      l_debug_info := 'After call to hz_location_v2pub.create_location';
      l_debug_info := l_debug_info||' Return status : '||l_loc_return_status||' Error : '||l_loc_msg_data;
      ------------------------------------------------------------------------
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;
    END IF;
        END IF;
	l_vendor_site_rec.location_id := l_loc_id;

    END IF; --location_id was null

    IF l_party_site_valid = 'N' and
		l_location_valid <> 'F' and
		nvl(l_loc_return_status,FND_API.G_RET_STS_SUCCESS) =
			FND_API.G_RET_STS_SUCCESS  AND
		-- Bug 7429668
		nvl(l_val_return_status,FND_API.G_RET_STS_SUCCESS) =
			FND_API.G_RET_STS_SUCCESS THEN

	--populate party site record
	l_party_site_rec.location_id := l_vendor_site_rec.location_id;
	l_party_site_rec.created_by_module := 'AP_SUPPLIERS_API';
	l_party_site_rec.application_id := 200;
	l_party_site_rec.party_id := l_party_id;

        --Uncommenting the line below for the R12 FSIO gap,
        --as we want the duns number to be imported on
        --supplier sites(bug6053476)
	l_party_site_rec.duns_number_c := l_vendor_site_rec.duns_number;
        --Bug5896973
        --Added code to populate City + State + Country in party_site_name field of hz_party_sites table
        --l_party_site_rec.party_site_name :=
        --        nvl(l_vendor_site_rec.city,'')||' '
        --        ||nvl(l_vendor_site_rec.state,'')||' '
        --        ||nvl(l_vendor_site_rec.country,'');
        --Bug 7316431
        l_party_site_rec.party_site_name := nvl(l_vendor_site_rec.vendor_site_code,'');

	--Open Issue 4, check for needed parameters
        --Bug6648405
        --Bug 6753822 - Added NVL on vendor_type_lookup_code
       IF (NVL(l_vendor_type_lookup_code,'DUMMY') <> 'EMPLOYEE') then
          -- udhenuko Bug 6823885 start
          --We need to populate the party site number based on profile value.
          fnd_profile.get('HZ_GENERATE_PARTY_SITE_NUMBER', l_party_site_num);
        	IF nvl(l_party_site_num, 'Y') = 'N' THEN
        		SELECT HZ_PARTY_SITE_NUMBER_S.Nextval
        		INTO l_party_site_rec.party_site_number
        		FROM DUAL;
        	END IF;
        	-- udhenuko Bug 6823885 End
	hz_party_site_v2pub.create_party_site(
		p_init_msg_list => FND_API.G_FALSE,
		p_party_site_rec => l_party_site_rec,
		--p_commit => FND_API.G_FALSE,
		x_return_status => l_site_return_status,
		x_msg_count => l_site_msg_count,
		x_msg_data => l_site_msg_data,
		x_party_site_id => l_party_site_id,
		x_party_site_number => l_party_site_number);
		  IF l_site_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        ------------------------------------------------------------------------
        l_debug_info := 'After call to hz_party_site_v2pub.create_party_site';
        l_debug_info := l_debug_info||' Return status : '||l_site_return_status||' Error : '||l_site_msg_data;
        ------------------------------------------------------------------------
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;
      END IF;
       END IF;
	l_vendor_site_rec.party_site_id := l_party_site_id;
    -- udhenuko Bug 6823885 Added the else condition to populate the party site id.
	  -- If part site is valid then the id can be found in the vendor site rec.
    ELSE
      -- Assign the Party Site Id and Location Id from the record to the varialbes.
      l_party_site_id := l_vendor_site_rec.party_site_id;
      l_loc_id := l_vendor_site_rec.location_id;
      -- udhenuko Bug 6823885 End
    END IF; -- party_site_id was null

	L_ROUNDING_LEVEL_CODE	:= NULL ;   	/* B 9530837  */
	L_ROUNDING_RULE_CODE	:= NULL ;   	/* B 9530837  */
	L_INCLUSIVE_TAX_FLAG	:= NULL ;   	/* B 9530837  */

     -- Bug#7371143 zrehman changes started
           BEGIN
           SELECT PROCESS_FOR_APPLICABILITY_FLAG, ALLOW_OFFSET_TAX_FLAG
             	   , TAX_CLASSIFICATION_CODE -- Bug#7506443
		,ROUNDING_LEVEL_CODE ,ROUNDING_RULE_CODE ,INCLUSIVE_TAX_FLAG /* B 9530837  */
	     INTO l_auto_tax_calc_flag,l_offset_tax_flag,
	     l_tax_classification_code  -- Bug#7506443
		,L_ROUNDING_LEVEL_CODE ,L_ROUNDING_RULE_CODE ,L_INCLUSIVE_TAX_FLAG /* B 9530837  */
             FROM ZX_PARTY_TAX_PROFILE
            WHERE PARTY_ID = l_party_id
              AND PARTY_TYPE_CODE = 'THIRD_PARTY'
              AND ROWNUM = 1;
            EXCEPTION
               WHEN OTHERS THEN
                  l_debug_info := 'No data returned from ZX_PARTY_TAX_PROFILE for party_id = '||l_party_id;
                   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
                   END IF;
             END;
    -- Bug#7642742 start

   -- Bug#7506443 start
      l_vendor_site_rec.OFFSET_TAX_FLAG :=  nvl(l_vendor_site_rec.OFFSET_TAX_FLAG, l_offset_tax_flag);
      l_vendor_site_rec.AUTO_TAX_CALC_FLAG :=  nvl(l_vendor_site_rec.AUTO_TAX_CALC_FLAG, l_auto_tax_calc_flag);
      l_vendor_site_rec.VAT_CODE :=  nvl(l_vendor_site_rec.VAT_CODE, l_tax_classification_code);
   -- Bug#7506443 start
        l_offset_tax_flag         :=  l_vendor_site_rec.OFFSET_TAX_FLAG;
        l_auto_tax_calc_flag      :=  l_vendor_site_rec.AUTO_TAX_CALC_FLAG;
        l_tax_classification_code :=  l_vendor_site_rec.VAT_CODE;
   -- Bug#7642742 end

	/* B 9530837 start  */
	l_vendor_site_rec.AP_TAX_ROUNDING_RULE :=
		nvl(l_vendor_site_rec.AP_TAX_ROUNDING_RULE, L_ROUNDING_RULE_CODE ) ;
	L_ROUNDING_RULE_CODE :=  l_vendor_site_rec.AP_TAX_ROUNDING_RULE ;

	l_vendor_site_rec.AMOUNT_INCLUDES_TAX_FLAG :=
		nvl(l_vendor_site_rec.AMOUNT_INCLUDES_TAX_FLAG, L_INCLUSIVE_TAX_FLAG) ;
	L_INCLUSIVE_TAX_FLAG	:=  l_vendor_site_rec.AMOUNT_INCLUDES_TAX_FLAG ;
	/* end B 9530837 */



    -- Start Bug 7207314. Update Tax Registration Number in ZX_PARTY_TAX_PROFILE
    -- VAT Registration Number is not stored at site level or HZ Party Site.
    -- This info is maintained by ZX Party Profile as 3rd party site tax profile.

        IF (l_vendor_site_rec.vat_registration_num is not null
	    or l_auto_tax_calc_flag is not null or l_offset_tax_flag is not null -- Bug#7371143 zrehman
	    /* or l_tax_classification_code is not null) then -- Bug#7642742 -- B 9530837 start  */
	    or l_tax_classification_code is not null
	    or L_ROUNDING_LEVEL_CODE is not null
	    or L_ROUNDING_RULE_CODE is not null
	    or L_INCLUSIVE_TAX_FLAG is not null) then  /* B 9530837 end  */

          IF ( (l_location_valid = 'V' OR (l_location_valid = 'N' and l_loc_return_status = FND_API.G_RET_STS_SUCCESS))
           AND (l_party_site_valid = 'V' OR (l_party_site_valid = 'N' and l_site_return_status =
                FND_API.G_RET_STS_SUCCESS)) ) THEN

            BEGIN
           SELECT PARTY_TAX_PROFILE_ID INTO L_PARTY_TAX_PROFILE_ID
            FROM ZX_PARTY_TAX_PROFILE
            WHERE PARTY_ID = l_party_site_id
            AND PARTY_TYPE_CODE = 'THIRD_PARTY_SITE'
            AND ROWNUM = 1;
          EXCEPTION
            WHEN OTHERS THEN
              L_PARTY_TAX_PROFILE_ID := NULL;
          END;

          IF L_PARTY_TAX_PROFILE_ID IS NOT NULL THEN
          ZX_PARTY_TAX_PROFILE_PKG.update_row (
          P_PARTY_TAX_PROFILE_ID => L_PARTY_TAX_PROFILE_ID,
           P_COLLECTING_AUTHORITY_FLAG => null,
           P_PROVIDER_TYPE_CODE => null,
           P_CREATE_AWT_DISTS_TYPE_CODE => null,
           P_CREATE_AWT_INVOICES_TYPE_COD => null,
           P_TAX_CLASSIFICATION_CODE => l_tax_classification_code, -- Bug#7506443 zrehman
           P_SELF_ASSESS_FLAG => null,
           P_ALLOW_OFFSET_TAX_FLAG => l_offset_tax_flag,-- Bug#7371143 zrehman
           P_REP_REGISTRATION_NUMBER => l_vendor_site_rec.vat_registration_num,
           P_EFFECTIVE_FROM_USE_LE => null,
           P_RECORD_TYPE_CODE => null,
           P_REQUEST_ID => null,
           P_ATTRIBUTE1 => null,
           P_ATTRIBUTE2 => null,
           P_ATTRIBUTE3 => null,
           P_ATTRIBUTE4 => null,
           P_ATTRIBUTE5 => null,
           P_ATTRIBUTE6 => null,
           P_ATTRIBUTE7 => null,
           P_ATTRIBUTE8 => null,
           P_ATTRIBUTE9 => null,
           P_ATTRIBUTE10 => null,
           P_ATTRIBUTE11 => null,
           P_ATTRIBUTE12 => null,
           P_ATTRIBUTE13 => null,
           P_ATTRIBUTE14 => null,
           P_ATTRIBUTE15 => null,
           P_ATTRIBUTE_CATEGORY => null,
           P_PARTY_ID => null,
           P_PROGRAM_LOGIN_ID => null,
           P_PARTY_TYPE_CODE => null,
           P_SUPPLIER_FLAG => null,
           P_CUSTOMER_FLAG => null,
           P_SITE_FLAG => null,
           P_PROCESS_FOR_APPLICABILITY_FL => l_auto_tax_calc_flag,-- Bug#7371143 zrehman
           /*P_ROUNDING_LEVEL_CODE => null,    B 9530837  */
           P_ROUNDING_LEVEL_CODE => L_ROUNDING_LEVEL_CODE , /* B 9530837  */
           /*P_ROUNDING_RULE_CODE => null,    B 9530837  */
           P_ROUNDING_RULE_CODE => L_ROUNDING_RULE_CODE , /* B 9530837  */
           P_WITHHOLDING_START_DATE => null,
           /*P_INCLUSIVE_TAX_FLAG => null,    B 9530837  */
           P_INCLUSIVE_TAX_FLAG => L_INCLUSIVE_TAX_FLAG , /* B 9530837  */
           P_ALLOW_AWT_FLAG => null,
           P_USE_LE_AS_SUBSCRIBER_FLAG => null,
           P_LEGAL_ESTABLISHMENT_FLAG => null,
           P_FIRST_PARTY_LE_FLAG => null,
           P_REPORTING_AUTHORITY_FLAG => null,
           X_RETURN_STATUS => l_return_status,
           P_REGISTRATION_TYPE_CODE => null,
           P_COUNTRY_CODE => null
           );
            IF l_return_status <> fnd_api.g_ret_sts_success THEN
                l_debug_info := 'ZX_PARTY_TAX_PROFILE_PKG.update_row';
                l_debug_info := l_debug_info||' Return status : '||l_return_status;
                IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
                END IF;
            END IF;
           END IF;
          END IF;
        END IF;
    -- End Bug 7207314

    -- Bug 5244172
    -- Allow the vendor site creation even if we do not have
    -- location or party site IDs and the vendor type is
    -- Employee.

    IF (l_val_return_status = FND_API.G_RET_STS_SUCCESS) AND
		((l_loc_return_status = FND_API.G_RET_STS_SUCCESS) OR
                (l_loc_return_status <> FND_API.G_RET_STS_SUCCESS AND
                 l_vendor_site_rec.location_id IS NULL AND
                 l_vendor_type_lookup_code = 'EMPLOYEE')) AND
		((l_site_return_status = FND_API.G_RET_STS_SUCCESS) OR
                (l_site_return_status <> FND_API.G_RET_STS_SUCCESS AND
                 l_vendor_site_rec.party_site_id IS NULL AND
                 l_vendor_type_lookup_code = 'EMPLOYEE')) AND
		(l_payee_valid = 'N' OR
                l_pay_return_status = FND_API.G_RET_STS_SUCCESS) THEN

	ap_vendor_sites_pkg.insert_row(
		p_vendor_site_rec => l_vendor_site_rec,
		p_last_update_date => sysdate,
		p_last_updated_by => nvl(l_user_id,-1),
		p_last_update_login => nvl(l_last_update_login, -1),
		p_creation_date => sysdate,
		p_created_by => nvl(l_user_id, -1) ,
		p_request_id => l_request_id ,
		p_program_application_id => l_program_application_id,
		p_program_id => l_program_id,
		p_program_update_date => sysdate,
		p_AP_Tax_Rounding_Rule => SUBSTR(L_ROUNDING_RULE_CODE,1,1),	/* 9530837 */
		p_Amount_Includes_Tax_Flag => L_INCLUSIVE_TAX_FLAG,		/* 9530837 */
		x_rowid => l_rowid,
        	x_vendor_site_id => l_vendor_site_id);
        ------------------------------------------------------------------------
        l_debug_info := 'After call to ap_vendor_sites_pkg.insert_row';
        ------------------------------------------------------------------------
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;
        --Bug6648405
        --Bug 6753822 - Added NVL on vendor_type_lookup_code
       IF (NVL(l_vendor_type_lookup_code,'DUMMY') <> 'EMPLOYEE') then

        AP_TCA_SUPPLIER_SYNC_PKG.SYNC_Supplier_Sites(
                l_sync_return_status,
                l_sync_msg_count,
                l_sync_msg_data,
                l_vendor_site_rec.location_id,
                l_vendor_site_rec.party_site_id);
        IF l_sync_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          ------------------------------------------------------------------------
          l_debug_info := 'After call to AP_TCA_SUPPLIER_SYNC_PKG.SYNC_Supplier_Sites';
          l_debug_info := l_debug_info||' Return status : '||l_sync_return_status||' Error : '||l_sync_msg_data;
          ------------------------------------------------------------------------
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
          END IF;
        END IF;
       END IF;

	IF l_sync_return_status = FND_API.G_RET_STS_SUCCESS THEN
 	   Raise_Supplier_Event( i_vendor_site_id => l_vendor_site_id ); -- Bug 7307669
           x_return_status := FND_API.G_RET_STS_SUCCESS;
        END IF;
	x_party_site_id := l_party_site_id;
	x_location_id	:= l_loc_id;
	x_vendor_site_id := l_vendor_site_id;

    ELSIF (l_val_return_status = FND_API.G_RET_STS_UNEXP_ERROR) OR
		((l_loc_return_status = FND_API.G_RET_STS_UNEXP_ERROR) AND
                (l_vendor_type_lookup_code <> 'EMPLOYEE') AND
                (l_vendor_site_rec.location_id IS NULL)) OR
		((l_site_return_status = FND_API.G_RET_STS_UNEXP_ERROR) AND
                (l_vendor_type_lookup_code <> 'EMPLOYEE') AND
                (l_vendor_site_rec.party_site_id IS NULL)) OR
		(l_pay_return_status = FND_API.G_RET_STS_UNEXP_ERROR) OR
                (l_sync_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN

	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    ELSE

	x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    IF l_payee_valid = 'N' THEN --payee record is valid

    -- As per the discussion with Omar/Jayanta, we will only
    -- have payables payment function and no more employee expenses
    -- payment function.

	 -- changes for Bug#7506443 start
           Open get_iby_dtls_csr(l_party_id);
          Fetch get_iby_dtls_csr INTO l_pymt_method_code
                                     ,l_inactive_date
                                     ,l_primary_flag
                                     ,l_Exclusive_Pay_Flag
				  ,l_bank_instruction1_code -- Bug 8769088 Start
				  ,l_bank_instruction2_code
				  ,l_delivery_channel_code
				  ,l_bank_instr_detail
				  ,l_settlement_priority
				  ,l_payment_text_msg1
				  ,l_payment_text_msg2
				  ,l_payment_text_msg3
				  ,l_bank_charge_bearer
				  ,l_payment_reason_code
				  ,l_paymt_rsn_comts
				  ,l_pmt_format
				  ,l_remt_advc_dlvry_mthd
				  ,l_remit_advice_email
				  ,l_remit_advice_fax; -- Bug 8769088 End
          Close get_iby_dtls_csr;

          -- changes for Bug#7506443 end


       IF l_vendor_site_rec.ext_payee_rec.payment_function IS NULL THEN

          l_ext_payee_rec.payee_party_id := l_party_id;
          l_ext_payee_rec.payee_party_site_id := l_vendor_site_rec.party_site_id;
          l_ext_payee_rec.supplier_site_id := l_vendor_site_id;
          l_ext_payee_rec.payment_function  := 'PAYABLES_DISB';
          l_ext_payee_rec.payer_org_id := l_vendor_site_rec.org_id;
          l_ext_payee_rec.payer_org_type       := 'OPERATING_UNIT';
          /* l_ext_payee_rec.exclusive_pay_flag   := 'N'; Commented for bug#9066129 */

		  -- 6458813 starts
          -- 7506443 changes start
          l_ext_payee_rec.default_pmt_method        := nvl (l_vendor_site_rec.ext_payee_rec.default_pmt_method,
	                                                          l_pymt_method_code);
          l_ext_payee_rec.inactive_date             := l_inactive_date;
   --     l_ext_payee_rec.Exclusive_Pay_Flag        := l_Exclusive_Pay_Flag;    -- Bug8200842
          -- B 8900634/8889211: Revert the change for Bug 8200842
          l_ext_payee_rec.Exclusive_Pay_Flag        := nvl(l_Exclusive_Pay_Flag,'N');     --Bug 8200842 Added the NVL Condition for bug#9066129
          -- 7506443 changes start

          l_ext_payee_rec.ece_tp_loc_code           := l_vendor_site_rec.ext_payee_rec.ece_tp_loc_code;
          l_ext_payee_rec.bank_charge_bearer        := nvl(l_vendor_site_rec.ext_payee_rec.bank_charge_bearer, l_bank_charge_bearer);
	  l_ext_payee_rec.bank_instr1_code          := nvl(l_vendor_site_rec.ext_payee_rec.bank_instr1_code, l_bank_instruction1_code);
          l_ext_payee_rec.bank_instr2_code          := nvl(l_vendor_site_rec.ext_payee_rec.bank_instr2_code, l_bank_instruction2_code);
	  l_ext_payee_rec.bank_instr_detail         := nvl(l_vendor_site_rec.ext_payee_rec.bank_instr_detail, l_bank_instr_detail);
          l_ext_payee_rec.pay_reason_code           := nvl(l_vendor_site_rec.ext_payee_rec.pay_reason_code, l_payment_reason_code);
          l_ext_payee_rec.pay_reason_com            := nvl(l_vendor_site_rec.ext_payee_rec.pay_reason_com, l_paymt_rsn_comts);
          l_ext_payee_rec.pay_message1              := nvl(l_vendor_site_rec.ext_payee_rec.pay_message1, l_payment_text_msg1);
          l_ext_payee_rec.pay_message2              := nvl(l_vendor_site_rec.ext_payee_rec.pay_message2, l_payment_text_msg2);
          l_ext_payee_rec.pay_message3              := nvl(l_vendor_site_rec.ext_payee_rec.pay_message3, l_payment_text_msg3);
	  l_ext_payee_rec.delivery_channel          := nvl(l_vendor_site_rec.ext_payee_rec.delivery_channel,l_delivery_channel_code);
          l_ext_payee_rec.pmt_format                := nvl(l_vendor_site_rec.ext_payee_rec.pmt_format, l_pmt_format);
          l_ext_payee_rec.settlement_priority       := nvl(l_vendor_site_rec.ext_payee_rec.settlement_priority,l_settlement_priority);
		  -- 6458813 ends

	  -- B# 7339389
          --l_ext_payee_rec.remit_advice_delivery_method := l_vendor_site_rec.supplier_notif_method ;  .. B 8422781
          l_ext_payee_rec.remit_advice_delivery_method := nvl(l_vendor_site_rec.remit_advice_delivery_method, l_remt_advc_dlvry_mthd) ;  -- Bug 8422781
          l_ext_payee_rec.remit_advice_email           := nvl(l_vendor_site_rec.remittance_email, l_remit_advice_email);
          l_ext_payee_rec.remit_advice_fax             := NVL(l_vendor_site_rec.remit_advice_fax, l_remit_advice_fax);
	  -- Bug 8769088 end

		  ext_payee_tab(1)   := l_ext_payee_rec;

        ELSE
        -- 7506443 changes start
           l_vendor_site_rec.ext_payee_rec.default_pmt_method  :=nvl (l_vendor_site_rec.ext_payee_rec.default_pmt_method,l_pymt_method_code);
	  -- Bug 8769088 start
	  l_vendor_site_rec.ext_payee_rec.bank_instr1_code          := nvl(l_vendor_site_rec.ext_payee_rec.bank_instr1_code, l_bank_instruction1_code);
          l_vendor_site_rec.ext_payee_rec.bank_instr2_code          := nvl(l_vendor_site_rec.ext_payee_rec.bank_instr2_code, l_bank_instruction2_code);
	  l_vendor_site_rec.ext_payee_rec.delivery_channel          := nvl(l_vendor_site_rec.ext_payee_rec.delivery_channel,l_delivery_channel_code);
	  -- Bug 8769088 end
           l_vendor_site_rec.ext_payee_rec.inactive_date       := l_inactive_date;
           l_ext_payee_rec.Exclusive_Pay_Flag                  := nvl(l_Exclusive_Pay_Flag,'N');     /* Added the NVL Condition for bug#9066129 */

        -- 7506443 changes start
          ext_payee_tab(1)   := l_vendor_site_rec.ext_payee_rec;

        END IF;

        /* Calling IBY Payee Creation API */
        IBY_DISBURSEMENT_SETUP_PUB.Create_External_Payee
              ( p_api_version         => 1.0,
                p_init_msg_list       => FND_API.G_FALSE,
                p_ext_payee_tab       => ext_payee_tab,
                x_return_status       => l_pay_return_status,
                x_msg_count           => l_pay_msg_count,
                x_msg_data            => l_pay_msg_data,
                x_ext_payee_id_tab    => ext_payee_id_tab,
                x_ext_payee_status_tab => ext_payee_create_tab);
      IF l_pay_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        ------------------------------------------------------------------------
        l_debug_info := 'After call to IBY_DISBURSEMENT_SETUP_PUB.Create_External_Payee';
        l_debug_info := l_debug_info||' Return status : '||l_pay_return_status||' Error : '||l_pay_msg_data;
        ------------------------------------------------------------------------
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;
      END IF;
     END IF;

    /* Bug 5310356 */
    IF l_org_context <> MO_Global.Get_Access_Mode THEN
      MO_GLOBAL.Set_Policy_Context(l_org_context, l_def_org_id);
    END IF;

    -- End of API body.

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
	COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1,
    -- get message info.
    FND_MSG_PUB.Count_And_Get(
	p_count         	=>      x_msg_count     	,
        p_data          	=>      x_msg_data
    	);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Create_Vendor_Site_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Create_Vendor_Site_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);
	-- BUG 6739544 START
	WHEN ORG_ID_EXCEPTION THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
			(  	p_count         	=>      x_msg_count,
				p_data          	=>      x_msg_data
			);
    -- BUG 6739544 END.
	WHEN OTHERS THEN
		ROLLBACK TO Create_Vendor_Site_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);
END Create_Vendor_Site;

PROCEDURE Update_Vendor_Site
( 	p_api_version           IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	IN  	NUMBER	:=
						FND_API.G_VALID_LEVEL_FULL,
	x_return_status		OUT	NOCOPY VARCHAR2		  	,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_vendor_site_rec	IN	r_vendor_site_rec_type,
	p_vendor_site_id	IN	NUMBER,
	p_calling_prog		IN	VARCHAR2 DEFAULT 'NOT ISETUP'
)
IS
    l_api_name			CONSTANT VARCHAR2(30)	:= 'Update_Vendor_Site';
    l_api_version           	CONSTANT NUMBER 		:= 1.0;

    l_def_org_id		NUMBER;

    l_user_id                		number := FND_GLOBAL.USER_ID;
    l_last_update_login      		number := FND_GLOBAL.LOGIN_ID;
    l_program_application_id 		number := FND_GLOBAL.prog_appl_id;
    l_program_id             		number := FND_GLOBAL.conc_program_id;
    l_request_id             		number := FND_GLOBAL.conc_request_id;
    l_vendor_site_rec				r_vendor_site_rec_type;
    l_org_context			VARCHAR2(1);
    l_val_return_status                 VARCHAR2(50);
    l_val_msg_count                     NUMBER;
    l_val_msg_data                      VARCHAR2(1000);
    l_org_id				NUMBER;
    l_party_site_valid			VARCHAR2(1);
    l_location_valid			VARCHAR2(1);
    l_payee_valid                       VARCHAR2(1);

    l_sync_return_status                 VARCHAR2(50);
    l_sync_msg_count                     NUMBER;
    l_sync_msg_data                      VARCHAR2(1000);



BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT	Update_Vendor_Site_PUB;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
    THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_val_return_status :=  FND_API.G_RET_STS_SUCCESS;

    -- API body

    -- Bug 5055120
    -- This call is incorrect. The correct call is to have the calling
    -- modules set the context and call this API with the right ORG_ID.

    -- Bug 6812010 :Due to 5055120, Payables' own supplier site import program fails
    -- because MO initialization is not happening.To fix 6812010 and keep 5055120 intact,
    -- strategy is that if calling application id is not AP then we will not call MO_GLOBAL.INIT
    -- since it is calling module's responsibility to perform MO initialization.

    -- Bug 6930102
    If (l_program_application_id = 200 OR l_program_application_id = -1)then
    MO_GLOBAL.INIT ('SQLAP');
    end if;

    --get org_id from existing record
    SELECT org_id
    INTO l_org_id
    FROM po_vendor_sites_all pvs
    WHERE pvs.vendor_site_id = p_vendor_site_id;

    l_org_context := mo_global.get_access_mode;

    IF nvl(l_org_context, 'K') <> 'S' THEN
	MO_GLOBAL.set_policy_context('S',l_org_id);
    END IF;

    l_vendor_site_rec := p_vendor_site_rec;

    --added ap_null_num condition by abhsaxen on 06-May-2008 for bug 7008314
    IF (l_vendor_site_rec.org_id IS NULL OR l_vendor_site_rec.org_id = ap_null_num) THEN
       l_vendor_site_rec.org_id := l_org_id;
    END IF;

    validate_vendor_site(p_api_version => 1.0,
		p_init_msg_list => FND_API.G_FALSE,
		p_commit  => FND_API.G_FALSE,
		x_return_status => l_val_return_status,
		x_msg_count => l_val_msg_count,
		x_msg_data => l_val_msg_data,
		p_vendor_site_rec => l_vendor_site_rec,
		P_mode => 'U',
		P_calling_prog => p_calling_prog,
		x_party_site_valid => l_party_site_valid,
		x_location_valid => l_location_valid,
		x_payee_valid 	=> l_payee_valid,
		p_vendor_site_id => p_vendor_site_id);

    IF (l_val_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	--populate existing values
	SELECT
		decode(l_vendor_site_rec.AREA_CODE,
                   ap_null_char,NULL,
                   nvl(l_vendor_site_rec.AREA_CODE, AREA_CODE))
		,decode(l_vendor_site_rec.PHONE,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.PHONE, PHONE))
		,decode(l_vendor_site_rec.CUSTOMER_NUM,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.CUSTOMER_NUM, CUSTOMER_NUM))
		,decode(l_vendor_site_rec.SHIP_TO_LOCATION_ID,
                    ap_null_num,NULL,
                    nvl(l_vendor_site_rec.SHIP_TO_LOCATION_ID, SHIP_TO_LOCATION_ID))
		,decode(l_vendor_site_rec.BILL_TO_LOCATION_ID,
                    ap_null_num,NULL,
                    nvl(l_vendor_site_rec.BILL_TO_LOCATION_ID, BILL_TO_LOCATION_ID))
		,decode(l_vendor_site_rec.SHIP_VIA_LOOKUP_CODE,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.SHIP_VIA_LOOKUP_CODE, SHIP_VIA_LOOKUP_CODE))
		,decode(l_vendor_site_rec.FREIGHT_TERMS_LOOKUP_CODE,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.FREIGHT_TERMS_LOOKUP_CODE,
                        FREIGHT_TERMS_LOOKUP_CODE))
		,decode(l_vendor_site_rec.FOB_LOOKUP_CODE,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.FOB_LOOKUP_CODE,
                        FOB_LOOKUP_CODE))
		,decode(l_vendor_site_rec.INACTIVE_DATE,
                    ap_null_date,NULL,
                    nvl(l_vendor_site_rec.INACTIVE_DATE,
                        INACTIVE_DATE))
		,decode(l_vendor_site_rec.FAX,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.FAX, FAX))
		,decode(l_vendor_site_rec.FAX_AREA_CODE,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.FAX_AREA_CODE,
                        FAX_AREA_CODE))
		,decode(l_vendor_site_rec.TELEX,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.TELEX, TELEX))
		,decode(l_vendor_site_rec.TERMS_DATE_BASIS,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.TERMS_DATE_BASIS,
                        TERMS_DATE_BASIS))
		,decode(l_vendor_site_rec.DISTRIBUTION_SET_ID,
                    ap_null_num,NULL,
                    nvl(l_vendor_site_rec.DISTRIBUTION_SET_ID, DISTRIBUTION_SET_ID))
		,decode(l_vendor_site_rec.ACCTS_PAY_CODE_COMBINATION_ID,
                    ap_null_num,NULL,
                    nvl(l_vendor_site_rec.ACCTS_PAY_CODE_COMBINATION_ID,
                        ACCTS_PAY_CODE_COMBINATION_ID))
		,decode(l_vendor_site_rec.PREPAY_CODE_COMBINATION_ID,
                    ap_null_num,NULL,
                    nvl(l_vendor_site_rec.PREPAY_CODE_COMBINATION_ID,
                        PREPAY_CODE_COMBINATION_ID))
		,decode(l_vendor_site_rec.PAY_GROUP_LOOKUP_CODE,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.PAY_GROUP_LOOKUP_CODE, PAY_GROUP_LOOKUP_CODE))
		,decode(l_vendor_site_rec.PAYMENT_PRIORITY,
                    ap_null_num,NULL,
                    nvl(l_vendor_site_rec.PAYMENT_PRIORITY, PAYMENT_PRIORITY))
		,decode(l_vendor_site_rec.TERMS_ID,
                    ap_null_num,NULL,
                    nvl(l_vendor_site_rec.TERMS_ID, TERMS_ID))
		,decode(l_vendor_site_rec.INVOICE_AMOUNT_LIMIT,
                    ap_null_num,NULL,
                    nvl(l_vendor_site_rec.INVOICE_AMOUNT_LIMIT, INVOICE_AMOUNT_LIMIT))
		,decode(l_vendor_site_rec.PAY_DATE_BASIS_LOOKUP_CODE,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.PAY_DATE_BASIS_LOOKUP_CODE, PAY_DATE_BASIS_LOOKUP_CODE))
		,decode(l_vendor_site_rec.ALWAYS_TAKE_DISC_FLAG,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.ALWAYS_TAKE_DISC_FLAG, ALWAYS_TAKE_DISC_FLAG))
		,decode(l_vendor_site_rec.INVOICE_CURRENCY_CODE,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.INVOICE_CURRENCY_CODE, INVOICE_CURRENCY_CODE))
		,decode(l_vendor_site_rec.PAYMENT_CURRENCY_CODE,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.PAYMENT_CURRENCY_CODE, PAYMENT_CURRENCY_CODE))
		,decode(l_vendor_site_rec.VENDOR_SITE_ID,
                    ap_null_num,NULL,
                    nvl(l_vendor_site_rec.VENDOR_SITE_ID, VENDOR_SITE_ID))
		,decode(l_vendor_site_rec.VENDOR_ID,
                    ap_null_num,NULL,
                    nvl(l_vendor_site_rec.VENDOR_ID, VENDOR_ID))
		,decode(l_vendor_site_rec.VENDOR_SITE_CODE,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.VENDOR_SITE_CODE, VENDOR_SITE_CODE))
		,decode(l_vendor_site_rec.VENDOR_SITE_CODE_ALT,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.VENDOR_SITE_CODE_ALT, VENDOR_SITE_CODE_ALT))
		,decode(l_vendor_site_rec.PURCHASING_SITE_FLAG,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.PURCHASING_SITE_FLAG, PURCHASING_SITE_FLAG))
		,decode(l_vendor_site_rec.RFQ_ONLY_SITE_FLAG,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.RFQ_ONLY_SITE_FLAG, RFQ_ONLY_SITE_FLAG))
		,decode(l_vendor_site_rec.PAY_SITE_FLAG,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.PAY_SITE_FLAG, PAY_SITE_FLAG))
		,decode(l_vendor_site_rec.ATTENTION_AR_FLAG,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.ATTENTION_AR_FLAG, ATTENTION_AR_FLAG))
		,decode(l_vendor_site_rec.HOLD_ALL_PAYMENTS_FLAG,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.HOLD_ALL_PAYMENTS_FLAG, HOLD_ALL_PAYMENTS_FLAG))
		,decode(l_vendor_site_rec.HOLD_FUTURE_PAYMENTS_FLAG,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.HOLD_FUTURE_PAYMENTS_FLAG, HOLD_FUTURE_PAYMENTS_FLAG))
		,decode(l_vendor_site_rec.HOLD_REASON,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.HOLD_REASON, HOLD_REASON))
		,decode(l_vendor_site_rec.HOLD_UNMATCHED_INVOICES_FLAG,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.HOLD_UNMATCHED_INVOICES_FLAG, HOLD_UNMATCHED_INVOICES_FLAG))
		,decode(l_vendor_site_rec.TAX_REPORTING_SITE_FLAG,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.TAX_REPORTING_SITE_FLAG, TAX_REPORTING_SITE_FLAG))
		,decode(l_vendor_site_rec.ATTRIBUTE_CATEGORY,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.ATTRIBUTE_CATEGORY, ATTRIBUTE_CATEGORY))
		,decode(l_vendor_site_rec.ATTRIBUTE1,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.ATTRIBUTE1, ATTRIBUTE1))
		,decode(l_vendor_site_rec.ATTRIBUTE2,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.ATTRIBUTE2, ATTRIBUTE2))
		,decode(l_vendor_site_rec.ATTRIBUTE3,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.ATTRIBUTE3, ATTRIBUTE3))
		,decode(l_vendor_site_rec.ATTRIBUTE4,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.ATTRIBUTE4, ATTRIBUTE4))
		,decode(l_vendor_site_rec.ATTRIBUTE5,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.ATTRIBUTE5, ATTRIBUTE5))
		,decode(l_vendor_site_rec.ATTRIBUTE6,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.ATTRIBUTE6, ATTRIBUTE6))
		,decode(l_vendor_site_rec.ATTRIBUTE7,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.ATTRIBUTE7, ATTRIBUTE7))
		,decode(l_vendor_site_rec.ATTRIBUTE8,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.ATTRIBUTE8, ATTRIBUTE8))
		,decode(l_vendor_site_rec.ATTRIBUTE9,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.ATTRIBUTE9, ATTRIBUTE9))
		,decode(l_vendor_site_rec.ATTRIBUTE10,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.ATTRIBUTE10, ATTRIBUTE10))
		,decode(l_vendor_site_rec.ATTRIBUTE11,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.ATTRIBUTE11, ATTRIBUTE11))
		,decode(l_vendor_site_rec.ATTRIBUTE12,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.ATTRIBUTE12, ATTRIBUTE12))
		,decode(l_vendor_site_rec.ATTRIBUTE13,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.ATTRIBUTE13, ATTRIBUTE13))
		,decode(l_vendor_site_rec.ATTRIBUTE14,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.ATTRIBUTE14, ATTRIBUTE14))
		,decode(l_vendor_site_rec.ATTRIBUTE15,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.ATTRIBUTE15, ATTRIBUTE15))
		,decode(l_vendor_site_rec.VALIDATION_NUMBER,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.VALIDATION_NUMBER, VALIDATION_NUMBER))
		,decode(l_vendor_site_rec.EXCLUDE_FREIGHT_FROM_DISCOUNT,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.EXCLUDE_FREIGHT_FROM_DISCOUNT,
                        EXCLUDE_FREIGHT_FROM_DISCOUNT))
		,decode(l_vendor_site_rec.BANK_CHARGE_BEARER,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.BANK_CHARGE_BEARER, BANK_CHARGE_BEARER))
		,decode(l_vendor_site_rec.ORG_ID,
                    ap_null_num,NULL,
                    nvl(l_vendor_site_rec.ORG_ID, ORG_ID))
		,decode(l_vendor_site_rec.CHECK_DIGITS,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.CHECK_DIGITS, CHECK_DIGITS))
		,decode(l_vendor_site_rec.ALLOW_AWT_FLAG,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.ALLOW_AWT_FLAG, ALLOW_AWT_FLAG))
		,decode(l_vendor_site_rec.AWT_GROUP_ID,
                    ap_null_num,NULL,
                    nvl(l_vendor_site_rec.AWT_GROUP_ID, AWT_GROUP_ID))
		,decode(l_vendor_site_rec.DEFAULT_PAY_SITE_ID,
                    ap_null_num,NULL,
                   nvl(l_vendor_site_rec.DEFAULT_PAY_SITE_ID, DEFAULT_PAY_SITE_ID))
		,decode(l_vendor_site_rec.PAY_ON_CODE,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.PAY_ON_CODE, PAY_ON_CODE))
		,decode(l_vendor_site_rec.PAY_ON_RECEIPT_SUMMARY_CODE,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.PAY_ON_RECEIPT_SUMMARY_CODE, PAY_ON_RECEIPT_SUMMARY_CODE))
		,decode(l_vendor_site_rec.GLOBAL_ATTRIBUTE_CATEGORY,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.GLOBAL_ATTRIBUTE_CATEGORY, GLOBAL_ATTRIBUTE_CATEGORY))
		,decode(l_vendor_site_rec.GLOBAL_ATTRIBUTE1,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.GLOBAL_ATTRIBUTE1, GLOBAL_ATTRIBUTE1))
		,decode(l_vendor_site_rec.GLOBAL_ATTRIBUTE2,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.GLOBAL_ATTRIBUTE2, GLOBAL_ATTRIBUTE2))
		,decode(l_vendor_site_rec.GLOBAL_ATTRIBUTE3,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.GLOBAL_ATTRIBUTE3, GLOBAL_ATTRIBUTE3))
		,decode(l_vendor_site_rec.GLOBAL_ATTRIBUTE4,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.GLOBAL_ATTRIBUTE4, GLOBAL_ATTRIBUTE4))
		,decode(l_vendor_site_rec.GLOBAL_ATTRIBUTE5,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.GLOBAL_ATTRIBUTE5, GLOBAL_ATTRIBUTE5))
		,decode(l_vendor_site_rec.GLOBAL_ATTRIBUTE6,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.GLOBAL_ATTRIBUTE6, GLOBAL_ATTRIBUTE6))
		,decode(l_vendor_site_rec.GLOBAL_ATTRIBUTE7,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.GLOBAL_ATTRIBUTE7, GLOBAL_ATTRIBUTE7))
		,decode(l_vendor_site_rec.GLOBAL_ATTRIBUTE8,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.GLOBAL_ATTRIBUTE8, GLOBAL_ATTRIBUTE8))
		,decode(l_vendor_site_rec.GLOBAL_ATTRIBUTE9,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.GLOBAL_ATTRIBUTE9, GLOBAL_ATTRIBUTE9))
		,decode(l_vendor_site_rec.GLOBAL_ATTRIBUTE10,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.GLOBAL_ATTRIBUTE10, GLOBAL_ATTRIBUTE10))
		,decode(l_vendor_site_rec.GLOBAL_ATTRIBUTE11,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.GLOBAL_ATTRIBUTE11, GLOBAL_ATTRIBUTE11))
		,decode(l_vendor_site_rec.GLOBAL_ATTRIBUTE12,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.GLOBAL_ATTRIBUTE12, GLOBAL_ATTRIBUTE12))
		,decode(l_vendor_site_rec.GLOBAL_ATTRIBUTE13,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.GLOBAL_ATTRIBUTE13, GLOBAL_ATTRIBUTE13))
		,decode(l_vendor_site_rec.GLOBAL_ATTRIBUTE14,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.GLOBAL_ATTRIBUTE14, GLOBAL_ATTRIBUTE14))
		,decode(l_vendor_site_rec.GLOBAL_ATTRIBUTE15,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.GLOBAL_ATTRIBUTE15, GLOBAL_ATTRIBUTE15))
		,decode(l_vendor_site_rec.GLOBAL_ATTRIBUTE16,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.GLOBAL_ATTRIBUTE16, GLOBAL_ATTRIBUTE16))
		,decode(l_vendor_site_rec.GLOBAL_ATTRIBUTE17,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.GLOBAL_ATTRIBUTE17, GLOBAL_ATTRIBUTE17))
		,decode(l_vendor_site_rec.GLOBAL_ATTRIBUTE18,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.GLOBAL_ATTRIBUTE18, GLOBAL_ATTRIBUTE18))
		,decode(l_vendor_site_rec.GLOBAL_ATTRIBUTE19,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.GLOBAL_ATTRIBUTE19, GLOBAL_ATTRIBUTE19))
		,decode(l_vendor_site_rec.GLOBAL_ATTRIBUTE20,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.GLOBAL_ATTRIBUTE20, GLOBAL_ATTRIBUTE20))
		,decode(l_vendor_site_rec.TP_HEADER_ID,
                    ap_null_num,NULL,
                    nvl(l_vendor_site_rec.TP_HEADER_ID, TP_HEADER_ID))
		,decode(l_vendor_site_rec.ECE_TP_LOCATION_CODE,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.ECE_TP_LOCATION_CODE, ECE_TP_LOCATION_CODE))
		,decode(l_vendor_site_rec.PCARD_SITE_FLAG,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.PCARD_SITE_FLAG, PCARD_SITE_FLAG))
		,decode(l_vendor_site_rec.MATCH_OPTION,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.MATCH_OPTION, MATCH_OPTION))
		,decode(l_vendor_site_rec.COUNTRY_OF_ORIGIN_CODE,
                    ap_null_char,NULL,
                   nvl(l_vendor_site_rec.COUNTRY_OF_ORIGIN_CODE, COUNTRY_OF_ORIGIN_CODE))
		,decode(l_vendor_site_rec.FUTURE_DATED_PAYMENT_CCID,
                    ap_null_num,NULL,
                    nvl(l_vendor_site_rec.FUTURE_DATED_PAYMENT_CCID, FUTURE_DATED_PAYMENT_CCID))
		,decode(l_vendor_site_rec.CREATE_DEBIT_MEMO_FLAG,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.CREATE_DEBIT_MEMO_FLAG, CREATE_DEBIT_MEMO_FLAG))
		,decode(l_vendor_site_rec.SUPPLIER_NOTIF_METHOD,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.SUPPLIER_NOTIF_METHOD, SUPPLIER_NOTIF_METHOD))
		,decode(l_vendor_site_rec.EMAIL_ADDRESS,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.EMAIL_ADDRESS, EMAIL_ADDRESS))
		,decode(l_vendor_site_rec.PRIMARY_PAY_SITE_FLAG,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.PRIMARY_PAY_SITE_FLAG, PRIMARY_PAY_SITE_FLAG))
		,decode(l_vendor_site_rec.SHIPPING_CONTROL,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.SHIPPING_CONTROL, SHIPPING_CONTROL))
		,decode(l_vendor_site_rec.SELLING_COMPANY_IDENTIFIER,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.SELLING_COMPANY_IDENTIFIER, SELLING_COMPANY_IDENTIFIER))
		,decode(l_vendor_site_rec.GAPLESS_INV_NUM_FLAG,
                    ap_null_char,NULL,
                    nvl(l_vendor_site_rec.GAPLESS_INV_NUM_FLAG, GAPLESS_INV_NUM_FLAG))
		,decode(l_vendor_site_rec.LOCATION_ID,
                    ap_null_num,NULL,
                    nvl(l_vendor_site_rec.LOCATION_ID, LOCATION_ID))
		,decode(l_vendor_site_rec.PARTY_SITE_ID,
                    ap_null_num,NULL,
                    nvl(l_vendor_site_rec.PARTY_SITE_ID, PARTY_SITE_ID))
		,decode(l_vendor_site_rec.TOLERANCE_ID,
                    ap_null_num,NULL,
                    nvl(l_vendor_site_rec.TOLERANCE_ID, TOLERANCE_ID))
        ,decode(l_vendor_site_rec.services_tolerance_id,
                    ap_null_num,NULL,
                    nvl(l_vendor_site_rec.services_tolerance_id,services_tolerance_id))
        ,decode(l_vendor_site_rec.retainage_rate,
                    ap_null_num,NULL,
                    nvl(l_vendor_site_rec.retainage_rate,retainage_rate))
        --bug6388041
        ,decode(l_vendor_site_rec.duns_number,
                    ap_null_char, NULL,
                    nvl(l_vendor_site_rec.duns_number,duns_number))
		 -- bug 7437549
	    ,decode(l_vendor_site_rec.EDI_ID_NUMBER,
			        ap_null_char,NULL,
			        nvl(l_vendor_site_rec.EDI_ID_NUMBER, EDI_ID_NUMBER))
		--bug7561758
		,decode(l_vendor_site_rec.PAY_AWT_GROUP_ID,
                    ap_null_num,NULL,
                    nvl(l_vendor_site_rec.PAY_AWT_GROUP_ID, PAY_AWT_GROUP_ID))
-- bug 7673494 start
	/*Bug9290488 start*/
        ,decode(l_vendor_site_rec.address_line1,
                    ap_null_char, NULL,
                    l_vendor_site_rec.address_line1)
        ,decode(l_vendor_site_rec.address_lines_alt,
                    ap_null_char, NULL,
                    l_vendor_site_rec.address_lines_alt)
        ,decode(l_vendor_site_rec.address_line2,
                    ap_null_char, NULL,
                    l_vendor_site_rec.address_line2)
        ,decode(l_vendor_site_rec.address_line3,
                    ap_null_char, NULL,
                    l_vendor_site_rec.address_line3)
        ,decode(l_vendor_site_rec.city,
                    ap_null_char, NULL,
                    l_vendor_site_rec.city)
        ,decode(l_vendor_site_rec.state,
                    ap_null_char, NULL,
                    l_vendor_site_rec.state)
        ,decode(l_vendor_site_rec.zip,
                    ap_null_char, NULL,
                    l_vendor_site_rec.zip)
        ,decode(l_vendor_site_rec.province,
                    ap_null_char, NULL,
                    l_vendor_site_rec.province)
        ,decode(l_vendor_site_rec.country,
                    ap_null_char, NULL,
                    l_vendor_site_rec.country)
        ,decode(l_vendor_site_rec.address_line4,
                    ap_null_char, NULL,
                    l_vendor_site_rec.address_line4)
        ,decode(l_vendor_site_rec.county,
                    ap_null_char, NULL,
                    l_vendor_site_rec.county)
        ,decode(l_vendor_site_rec.address_style,
                    ap_null_char, NULL,
                    l_vendor_site_rec.address_style)
        ,decode(l_vendor_site_rec.language,
                    ap_null_char, NULL,
                    l_vendor_site_rec.language)
        /*Bug9290488 end*/
	-- bug 7673494 end
        -- starting the Changes for CLM reference data management bug#9499174
        ,decode(l_vendor_site_rec.cage_code,
                     ap_null_num,NULL,
                     nvl(l_vendor_site_rec.CAGE_CODE, CAGE_CODE))
        ,decode(l_vendor_site_rec.legal_business_name,
                     ap_null_char,NULL,
                     nvl(l_vendor_site_rec.LEGAL_BUSINESS_NAME, LEGAL_BUSINESS_NAME))
        ,decode(l_vendor_site_rec.doing_bus_as_name,
                     ap_null_char,NULL,
                     nvl(l_vendor_site_rec.DOING_BUS_AS_NAME, DOING_BUS_AS_NAME))
        ,decode(l_vendor_site_rec.division_name,
                     ap_null_char,NULL,
                     nvl(l_vendor_site_rec.DIVISION_NAME, DIVISION_NAME))
        ,decode(l_vendor_site_rec.small_business_code,
                     ap_null_char,NULL,
                     nvl(l_vendor_site_rec.SMALL_BUSINESS_CODE, SMALL_BUSINESS_CODE))
        ,decode(l_vendor_site_rec.CCR_COMMENTS ,
                     ap_null_char,NULL,
                     nvl(l_vendor_site_rec.CCR_COMMENTS , CCR_COMMENTS ))
        ,decode(l_vendor_site_rec.DEBARMENT_START_DATE,
                     ap_null_date,NULL,
                     nvl(l_vendor_site_rec.DEBARMENT_START_DATE,DEBARMENT_START_DATE) )
        ,decode(l_vendor_site_rec.DEBARMENT_END_DATE ,
                     ap_null_date,NULL,
                     nvl(l_vendor_site_rec.DEBARMENT_END_DATE,DEBARMENT_END_DATE) )
                -- Ending the Changes for CLM reference data management bug#9499174
	INTO
		l_vendor_site_rec.AREA_CODE
		,l_vendor_site_rec.PHONE
		,l_vendor_site_rec.CUSTOMER_NUM
		,l_vendor_site_rec.SHIP_TO_LOCATION_ID
		,l_vendor_site_rec.BILL_TO_LOCATION_ID
		,l_vendor_site_rec.SHIP_VIA_LOOKUP_CODE
		,l_vendor_site_rec.FREIGHT_TERMS_LOOKUP_CODE
		,l_vendor_site_rec.FOB_LOOKUP_CODE
		,l_vendor_site_rec.INACTIVE_DATE
		,l_vendor_site_rec.FAX
		,l_vendor_site_rec.FAX_AREA_CODE
		,l_vendor_site_rec.TELEX
		,l_vendor_site_rec.TERMS_DATE_BASIS
		,l_vendor_site_rec.DISTRIBUTION_SET_ID
		,l_vendor_site_rec.ACCTS_PAY_CODE_COMBINATION_ID
		,l_vendor_site_rec.PREPAY_CODE_COMBINATION_ID
		,l_vendor_site_rec.PAY_GROUP_LOOKUP_CODE
		,l_vendor_site_rec.PAYMENT_PRIORITY
		,l_vendor_site_rec.TERMS_ID
		,l_vendor_site_rec.INVOICE_AMOUNT_LIMIT
		,l_vendor_site_rec.PAY_DATE_BASIS_LOOKUP_CODE
		,l_vendor_site_rec.ALWAYS_TAKE_DISC_FLAG
		,l_vendor_site_rec.INVOICE_CURRENCY_CODE
		,l_vendor_site_rec.PAYMENT_CURRENCY_CODE
		,l_vendor_site_rec.VENDOR_SITE_ID
		,l_vendor_site_rec.VENDOR_ID
		,l_vendor_site_rec.VENDOR_SITE_CODE
		,l_vendor_site_rec.VENDOR_SITE_CODE_ALT
		,l_vendor_site_rec.PURCHASING_SITE_FLAG
		,l_vendor_site_rec.RFQ_ONLY_SITE_FLAG
		,l_vendor_site_rec.PAY_SITE_FLAG
		,l_vendor_site_rec.ATTENTION_AR_FLAG
		,l_vendor_site_rec.HOLD_ALL_PAYMENTS_FLAG
		,l_vendor_site_rec.HOLD_FUTURE_PAYMENTS_FLAG
		,l_vendor_site_rec.HOLD_REASON
		,l_vendor_site_rec.HOLD_UNMATCHED_INVOICES_FLAG
		,l_vendor_site_rec.TAX_REPORTING_SITE_FLAG
		,l_vendor_site_rec.ATTRIBUTE_CATEGORY
		,l_vendor_site_rec.ATTRIBUTE1
		,l_vendor_site_rec.ATTRIBUTE2
		,l_vendor_site_rec.ATTRIBUTE3
		,l_vendor_site_rec.ATTRIBUTE4
		,l_vendor_site_rec.ATTRIBUTE5
		,l_vendor_site_rec.ATTRIBUTE6
		,l_vendor_site_rec.ATTRIBUTE7
		,l_vendor_site_rec.ATTRIBUTE8
		,l_vendor_site_rec.ATTRIBUTE9
		,l_vendor_site_rec.ATTRIBUTE10
		,l_vendor_site_rec.ATTRIBUTE11
		,l_vendor_site_rec.ATTRIBUTE12
		,l_vendor_site_rec.ATTRIBUTE13
		,l_vendor_site_rec.ATTRIBUTE14
		,l_vendor_site_rec.ATTRIBUTE15
		,l_vendor_site_rec.VALIDATION_NUMBER
		,l_vendor_site_rec.EXCLUDE_FREIGHT_FROM_DISCOUNT
		,l_vendor_site_rec.BANK_CHARGE_BEARER
		,l_vendor_site_rec.ORG_ID
		,l_vendor_site_rec.CHECK_DIGITS
		,l_vendor_site_rec.ALLOW_AWT_FLAG
		,l_vendor_site_rec.AWT_GROUP_ID
		,l_vendor_site_rec.DEFAULT_PAY_SITE_ID
		,l_vendor_site_rec.PAY_ON_CODE
		,l_vendor_site_rec.PAY_ON_RECEIPT_SUMMARY_CODE
		,l_vendor_site_rec.GLOBAL_ATTRIBUTE_CATEGORY
		,l_vendor_site_rec.GLOBAL_ATTRIBUTE1
		,l_vendor_site_rec.GLOBAL_ATTRIBUTE2
		,l_vendor_site_rec.GLOBAL_ATTRIBUTE3
		,l_vendor_site_rec.GLOBAL_ATTRIBUTE4
		,l_vendor_site_rec.GLOBAL_ATTRIBUTE5
		,l_vendor_site_rec.GLOBAL_ATTRIBUTE6
		,l_vendor_site_rec.GLOBAL_ATTRIBUTE7
		,l_vendor_site_rec.GLOBAL_ATTRIBUTE8
		,l_vendor_site_rec.GLOBAL_ATTRIBUTE9
		,l_vendor_site_rec.GLOBAL_ATTRIBUTE10
		,l_vendor_site_rec.GLOBAL_ATTRIBUTE11
		,l_vendor_site_rec.GLOBAL_ATTRIBUTE12
		,l_vendor_site_rec.GLOBAL_ATTRIBUTE13
		,l_vendor_site_rec.GLOBAL_ATTRIBUTE14
		,l_vendor_site_rec.GLOBAL_ATTRIBUTE15
		,l_vendor_site_rec.GLOBAL_ATTRIBUTE16
		,l_vendor_site_rec.GLOBAL_ATTRIBUTE17
		,l_vendor_site_rec.GLOBAL_ATTRIBUTE18
		,l_vendor_site_rec.GLOBAL_ATTRIBUTE19
		,l_vendor_site_rec.GLOBAL_ATTRIBUTE20
		,l_vendor_site_rec.TP_HEADER_ID
		,l_vendor_site_rec.ECE_TP_LOCATION_CODE
		,l_vendor_site_rec.PCARD_SITE_FLAG
		,l_vendor_site_rec.MATCH_OPTION
		,l_vendor_site_rec.COUNTRY_OF_ORIGIN_CODE
		,l_vendor_site_rec.FUTURE_DATED_PAYMENT_CCID
		,l_vendor_site_rec.CREATE_DEBIT_MEMO_FLAG
		,l_vendor_site_rec.SUPPLIER_NOTIF_METHOD
		,l_vendor_site_rec.EMAIL_ADDRESS
		,l_vendor_site_rec.PRIMARY_PAY_SITE_FLAG
		,l_vendor_site_rec.SHIPPING_CONTROL
		,l_vendor_site_rec.SELLING_COMPANY_IDENTIFIER
		,l_vendor_site_rec.GAPLESS_INV_NUM_FLAG
		,l_vendor_site_rec.LOCATION_ID
		,l_vendor_site_rec.PARTY_SITE_ID
		,l_vendor_site_rec.TOLERANCE_ID
        ,l_vendor_site_rec.services_tolerance_id
        ,l_vendor_site_rec.retainage_rate
        ,l_vendor_site_rec.duns_number     --bug6388041
		,l_vendor_site_rec.EDI_ID_NUMBER   --bug7437549
		,l_vendor_site_rec.PAY_AWT_GROUP_ID    --bug7561758
-- bug 7673494 start
                ,l_vendor_site_rec.address_line1
                ,l_vendor_site_rec.address_lines_alt
                ,l_vendor_site_rec.address_line2
                ,l_vendor_site_rec.address_line3
                ,l_vendor_site_rec.city
                ,l_vendor_site_rec.state
                ,l_vendor_site_rec.zip
                ,l_vendor_site_rec.province
                ,l_vendor_site_rec.country
                ,l_vendor_site_rec.address_line4
                ,l_vendor_site_rec.county
                ,l_vendor_site_rec.address_style
                ,l_vendor_site_rec.language
                -- bug 7673494 end
     -- starting the Changes for CLM reference data management bug#9499174
		,l_vendor_site_rec.CAGE_CODE
                ,l_vendor_site_rec.LEGAL_BUSINESS_NAME
                ,l_vendor_site_rec.DOING_BUS_AS_NAME
                ,l_vendor_site_rec.DIVISION_NAME
                ,l_vendor_site_rec.SMALL_BUSINESS_CODE
                ,l_vendor_site_rec.CCR_COMMENTS
                ,l_vendor_site_rec.DEBARMENT_START_DATE
                ,l_vendor_site_rec.DEBARMENT_END_DATE
    -- Ending the Changes for CLM reference data management bug#9499174

	FROM po_vendor_sites_all pvs
	WHERE pvs.vendor_site_id = p_vendor_site_id;
	ap_vendor_sites_pkg.update_row(
		p_vendor_site_rec => l_vendor_site_rec,
		p_last_update_date => sysdate,
		p_last_updated_by => l_user_id,
		p_last_update_login => l_last_update_login,
		p_request_id => l_request_id ,
		p_program_application_id => l_program_application_id,
		p_program_id => l_program_id,
		p_program_update_date => sysdate,
		p_vendor_site_id => p_vendor_site_id);

        AP_TCA_SUPPLIER_SYNC_PKG.SYNC_Supplier_Sites(
                l_sync_return_status,
                l_sync_msg_count,
                l_sync_msg_data,
                l_vendor_site_rec.location_id,
                l_vendor_site_rec.party_site_id,
		p_vendor_site_id); --bug 8723400

        IF l_sync_return_status = FND_API.G_RET_STS_SUCCESS THEN
	   Raise_Supplier_Event( i_vendor_site_id => p_vendor_site_id ); -- Bug 7307669
           x_return_status := FND_API.G_RET_STS_SUCCESS;
        END IF;

    ELSIF (l_val_return_status = FND_API.G_RET_STS_UNEXP_ERROR) OR
          (l_sync_return_status = FND_API.G_RET_STS_UNEXP_ERROR)THEN

	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    ELSE

	x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    --set access mode back to original value
    IF l_org_context <> mo_global.get_access_mode THEN
    	MO_GLOBAL.set_policy_context(l_org_context,l_def_org_id);
    END IF;

    -- End of API body.

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
	COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1,
    -- get message info.
    FND_MSG_PUB.Count_And_Get(
	p_count         	=>      x_msg_count     	,
        p_data          	=>      x_msg_data
    	);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Update_Vendor_Site_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Update_Vendor_Site_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);
	WHEN OTHERS THEN
		ROLLBACK TO Update_Vendor_Site_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);
END Update_Vendor_Site;

PROCEDURE Validate_Vendor_Site
( 	p_api_version           IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	IN  	NUMBER	:=
						FND_API.G_VALID_LEVEL_FULL,
	x_return_status		OUT	NOCOPY VARCHAR2		  	,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_vendor_site_rec	IN OUT	NOCOPY r_vendor_site_rec_type,
	p_mode			IN	VARCHAR2,
	p_calling_prog		IN	VARCHAR2,
	x_party_site_valid	OUT	NOCOPY VARCHAR2,
	x_location_valid	OUT	NOCOPY VARCHAR2,
        x_payee_valid           OUT     NOCOPY VARCHAR2,
	p_vendor_site_id	IN	NUMBER
)
IS
    l_api_name			CONSTANT VARCHAR2(30)	:= 'Validate_Vendor_Site';
    l_api_version           	CONSTANT NUMBER 		:= 1.0;
    l_org_context			VARCHAR2(1);--Bug 7476500
    l_program_application_id 		number := FND_GLOBAL.prog_appl_id;--Bug 7476500
    l_def_org_id		NUMBER;
    l_debug_info		VARCHAR2(2000);
    x_valid			BOOLEAN;
    l_sob			NUMBER;
    l_location_id		NUMBER;
    l_payee_return_status       VARCHAR2(50);
    l_payee_msg_count           NUMBER;
    l_payee_msg_data            VARCHAR2(1000);
    l_tolerance_type            VARCHAR2(50);
    l_status                    NUMBER;
    -- Bug 6645014 l_status added to import vat_code
    -- Bug 6918411/6808171 CTETALA
	-- l_dummy added for usage in validating country code
	l_dummy                     VARCHAR2(2);
    x_loc_count                 NUMBER := 0; -- Bug 7429668
    l_msg_count NUMBER; --bug 7572325
    l_msg_data  VARCHAR2(4000); --bug 7572325
    l_error_code VARCHAR2(4000); --bug 7572325

   --Bug 7835321 - Code to check if language for site is not invalid or disabled
   l_installed_flag VARCHAR2(10);
   l_language VARCHAR2(10);
   valid_language_flag BOOLEAN := TRUE ;
       cursor c_lang_is IS
            SELECT language_code,installed_flag
            FROM   fnd_languages
            WHERE  nls_language = p_vendor_site_rec.language
            AND nvl(Installed_flag,'I') in ('I','B','D');

 --Bug 7835321

BEGIN

    l_tolerance_type := 'QUANTITY';
     --Bug 7476500 start
    If (l_program_application_id = 200 OR l_program_application_id = -1)then
    MO_GLOBAL.INIT ('SQLAP');
    end if;

    l_org_context := mo_global.get_access_mode;
    IF nvl(l_org_context, 'K') <> 'S' THEN
  	MO_GLOBAL.set_policy_context('S',p_vendor_site_rec.org_id);
    END IF;
   --Bug 7476500 End
    -- Standard Start of API savepoint
    SAVEPOINT	Validate_Vendor_Site_PUB;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
    THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- API body

    --get sob
    --Bug 4597347
    --Bug 5305536
    IF p_vendor_site_rec.org_id IS NOT NULL THEN
      SELECT Set_Of_Books_Id
      INTO l_sob
      FROM ap_system_parameters
      WHERE org_id = p_vendor_site_rec.org_id;
    END IF;

    -- Call eTax Validation

    ------------------------------------------------------------------------
    l_debug_info := 'Call to Validate hold_unmatched_invoices_flag';
    ------------------------------------------------------------------------
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    END IF;
    --
    -- Validate hold_unmatched_invoices_flag
    --
    IF p_vendor_site_rec.hold_unmatched_invoices_flag is NOT NULL
       AND p_vendor_site_rec.hold_unmatched_invoices_flag <> ap_null_char THEN

      Validate_Lookups('HOLD_UNMATCHED_INVOICES_FLAG',
                          p_vendor_site_rec.hold_unmatched_invoices_flag ,'YES/NO',
                         'PO_LOOKUP_CODES',x_valid);
      IF NOT x_valid THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF g_source = 'IMPORT' THEN
          IF (Insert_Rejections(
                'AP_SUPPLIER_SITES_INT',
                p_vendor_site_rec.vendor_site_interface_id,
                'AP_INVALID_HOLD_UNMAT_INV',
                g_user_id,
                g_login_id,
                'Validate_Vendor_Site') <> TRUE) THEN
            --
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                l_api_name,'Parameters: '
                ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                ||' ,Hold_Unmatched_Invoices_Flag: '
                ||p_vendor_site_rec.hold_unmatched_invoices_flag);
            END IF;
          END IF;
        ELSE
            -- Bug 5491139 hkaniven start --
            FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_HOLD_UNMAT_INV');
            FND_MSG_PUB.ADD;
            -- Bug 5491139 hkaniven end --
            -- Bug 8438716 Start
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                l_api_name,'After call Validate_Lookups(HOLD_UNMATCHED_INVOICES_FLAG..)... Parameters: '
                ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                ||' ,Hold_Unmatched_Invoices_Flag: '
                ||p_vendor_site_rec.hold_unmatched_invoices_flag);
            END IF;
            -- Bug 8438716 End
        END IF;
      END IF;
    END IF;

    -- Bug 8930706 Start
    ------------------------------------------------------------------------
    l_debug_info := 'Validate Vendor Site Code for Supplier type EMPLOYEE' ;
    ------------------------------------------------------------------------
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    END IF;
    --
    -- Validate Vendor Site Code for Supplier type EMPLOYEE
    --
    IF G_vendor_type_lookup_code = 'EMPLOYEE'   THEN
      IF   p_vendor_site_rec.vendor_site_code IS NOT NULL
       AND p_vendor_site_rec.vendor_site_code <> 'HOME'
       AND p_vendor_site_rec.vendor_site_code <> 'OFFICE'
       AND p_vendor_site_rec.vendor_site_code <> 'PROVISIONAL'
	    THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF g_source = 'IMPORT' THEN
          IF (Insert_Rejections(
                'AP_SUPPLIER_SITES_INT',
                p_vendor_site_rec.vendor_site_interface_id,
		'AP_INVALID_VENDOR_SITE_CODE',
                g_user_id,
                g_login_id,
                'Validate_Vendor_Site') <> TRUE) THEN
            --
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                l_api_name,'Parameters: '
                ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
	        ||' ,Vendor_Site_Code: '||p_vendor_site_rec.vendor_site_code);
            END IF;
          END IF;
        ELSE
            -- Bug 5491139 hkaniven start --
	    FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_VENDOR_SITE_CODE');
            FND_MSG_PUB.ADD;
            -- Bug 5491139 hkaniven end --
            -- Bug 8438716 Start
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                l_api_name,'After Validate Vendor Site Code for Supplier type EMPLOYEE ... '
                ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
	        ||' ,Vendor_Site_Code: '||p_vendor_site_rec.vendor_site_code);
            END IF;
            -- Bug 8438716 End
        END IF;
      ELSE
        -- null out address fields for EMPLOYEE
        p_vendor_site_rec.address_line1	:= NULL ;
        p_vendor_site_rec.address_line2	:= NULL ;
        p_vendor_site_rec.address_line3	:= NULL ;
        p_vendor_site_rec.address_line4	:= NULL ;
        p_vendor_site_rec.address_lines_alt	:= NULL ;
        p_vendor_site_rec.address_style	:= NULL ;
       END IF;
    END IF;
    -- End Bug 8930706

    ------------------------------------------------------------------------
    l_debug_info := 'Call to Validate tax_reporting_site_flag';
    ------------------------------------------------------------------------
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    END IF;
    --
    -- Validate tax_reporting_site_flag
    --
    IF p_vendor_site_rec.tax_reporting_site_flag is NOT NULL
       AND p_vendor_site_rec.tax_reporting_site_flag <> ap_null_char THEN

      Validate_Lookups( 'TAX_REPORTING_SITE_FLAG',
                         p_vendor_site_rec.tax_reporting_site_flag ,'YES/NO',
                        'PO_LOOKUP_CODES',x_valid);
      IF NOT x_valid THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF g_source = 'IMPORT' THEN
          IF (Insert_Rejections(
                'AP_SUPPLIER_SITES_INT',
                p_vendor_site_rec.vendor_site_interface_id,
                'AP_INVALID_TAX_RS_FLAG',
                g_user_id,
                g_login_id,
                'Validate_Vendor_Site') <> TRUE) THEN
            --
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                l_api_name,'Parameters: '
                ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                ||' ,Tax_Reporting_Site_Flag: '
                ||p_vendor_site_rec.tax_reporting_site_flag);
            END IF;
          END IF;
        ELSE
            -- Bug 5491139 hkaniven start --
            FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_TAX_RS_FLAG');
            FND_MSG_PUB.ADD;
            -- Bug 5491139 hkaniven end --
            -- Bug 8438716 Start
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                l_api_name,'Validate_Lookups(TAX_REPORTING_SITE_FLAG...)... Parameters: '
                ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                ||' ,Tax_Reporting_Site_Flag: '
                ||p_vendor_site_rec.tax_reporting_site_flag);
            END IF;
            -- Bug 8438716 End
        END IF;
      END IF;
    END IF;

    -- Bug 6645014 starts: To import Vat code
    ------------------------------------------------------------------------
    l_debug_info := 'Call to Validate vat_code';
    ------------------------------------------------------------------------
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    END IF;
    --
    -- Validate vat_code
    --
    IF p_vendor_site_rec.vat_code is NOT NULL THEN
    -- Checking the vat code in the tax tables
          l_status := 0;
          SELECT COUNT(*)  INTO l_status FROM DUAL WHERE EXISTS (
            SELECT 'Y'
            FROM zx_input_classifications_v
            WHERE lookup_type in ('ZX_INPUT_CLASSIFICATIONS', 'ZX_WEB_EXP_TAX_CLASSIFICATIONS')
            AND org_id in ( p_vendor_site_rec.org_id, -99)
            AND enabled_flag = 'Y'
            AND LOOKUP_CODE = p_vendor_site_rec.VAT_CODE );


      IF l_status = 0  THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF g_source = 'IMPORT' THEN
          IF (Insert_Rejections(
                'AP_SUPPLIER_SITES_INT',
                p_vendor_site_rec.vendor_site_interface_id,
                'AP_INVALID_VAT_CODE',
                g_user_id,
                g_login_id,
                'Validate_Vendor_Site') <> TRUE) THEN
            --
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                l_api_name,'Parameters: '
                ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                ||' ,Vat_Code: '
                ||p_vendor_site_rec.vat_code);
            END IF;
          END IF;
        ELSE
            FND_MESSAGE.SET_NAME('SQLAP', 'AP_INVALID_VAT_CODE');
            FND_MSG_PUB.ADD;
            -- Bug 8438716 Start
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                l_api_name,'After call to VAT_CODE validation... Parameters: '
                ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                ||' ,Vat_Code: '
                ||p_vendor_site_rec.vat_code);
            END IF;
            -- Bug 8438716 End
        END IF;
      END IF;
    END IF;
    -- Bug 6645014 ends


    ------------------------------------------------------------------------
    l_debug_info := 'Call to Validate default_pay_site_id';
    ------------------------------------------------------------------------
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    END IF;
    --
    -- We should check for Valid Sites for any default_pay_site_id
    --
    IF (p_vendor_site_rec.default_pay_site_id is NOT NULL) AND
        (p_vendor_site_rec.default_pay_site_id <> ap_null_num) THEN

      Check_Default_pay_site(p_vendor_site_rec.default_pay_site_id,
                             p_vendor_site_rec.vendor_id,
                             p_vendor_site_rec.org_id,
                             x_valid
                             );
      IF NOT x_valid THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF g_source = 'IMPORT' THEN
          IF (Insert_Rejections(
                'AP_SUPPLIER_SITES_INT',
                p_vendor_site_rec.vendor_site_interface_id,
                'AP_INVALID_DEF_PAY_SITE',
                g_user_id,
                g_login_id,
                'Validate_Vendor_Site') <> TRUE) THEN
            --
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                l_api_name,'Parameters: '
                ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                ||' ,Vendor_Id: '||p_vendor_site_rec.vendor_id
                ||' ,Org_Id: '||p_vendor_site_rec.org_id
                ||' ,Deafult_Pay_Site_Id: '
                ||p_vendor_site_rec.default_pay_site_id);
            END IF;
          END IF;
        ELSE
            -- Bug 5491139 hkaniven start --
            FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_DEF_PAY_SITE');
            FND_MSG_PUB.ADD;
            -- Bug 5491139 hkaniven end --
            -- Bug 8438716 Start
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                l_api_name,'Call after Check_Default_pay_site... Parameters: '
                ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                ||' ,Vendor_Id: '||p_vendor_site_rec.vendor_id
                ||' ,Org_Id: '||p_vendor_site_rec.org_id
                ||' ,Deafult_Pay_Site_Id: '
                ||p_vendor_site_rec.default_pay_site_id);
            END IF;
            -- Bug 8438716 End
        END IF;
      END IF;
    END IF;


    -- Validate that no duplicate Vendor Site Code exist in applications
    --
    ------------------------------------------------------------------------
    l_debug_info := 'Call to Validate Vendor Site Code';
    ------------------------------------------------------------------------
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                    l_api_name,l_debug_info);
    END IF;

    IF p_vendor_site_rec.vendor_site_code is not null
	AND p_mode = 'I' -- should skip this check for Update, xili, 12/18/2006
       AND p_vendor_site_rec.vendor_site_code <> ap_null_char THEN

      Check_dup_vendor_site ( p_vendor_site_rec.vendor_id,
                           p_vendor_site_rec.vendor_site_code,
                           p_vendor_site_rec.org_name,
                           p_vendor_site_rec.org_id,
			   x_valid);
      IF NOT x_valid THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF g_source = 'IMPORT' THEN
          IF (Insert_Rejections(
                'AP_SUPPLIER_SITES_INT',
                p_vendor_site_rec.vendor_site_interface_id,
                'AP_DUPLICATE_VENDOR_SITE',
                g_user_id,
                g_login_id,
                'Validate_Vendor_Site') <> TRUE) THEN
            --
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                l_api_name,'Parameters: '
                ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                ||' ,Vendor_Id: '||p_vendor_site_rec.vendor_id
                ||' ,Org_Id: '||p_vendor_site_rec.org_id
                ||' ,Vendor_Site_Code: '
                ||p_vendor_site_rec.vendor_site_code);
            END IF;
          END IF;
        ELSE
            -- Bug 5491139 hkaniven start --
            FND_MESSAGE.SET_NAME('SQLAP','AP_DUPLICATE_VENDOR_SITE');
            FND_MSG_PUB.ADD;
            -- Bug 5491139 hkaniven end --
            -- Bug 8438716 Start
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                l_api_name,'Call after Check_dup_vendor_site... Parameters: '
                ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                ||' ,Vendor_Id: '||p_vendor_site_rec.vendor_id
                ||' ,Org_Id: '||p_vendor_site_rec.org_id
                ||' ,Vendor_Site_Code: '
                ||p_vendor_site_rec.vendor_site_code);
            END IF;
            -- Bug 8438716 End
        END IF;
      END IF;
    END IF;

    ------------------------------------------------------------------------
    l_debug_info := 'Call Org_Id and Operating_unit_name validation';
    ------------------------------------------------------------------------
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    END IF;

   -- Org_Id and Operating_unit_name validation
    IF (p_vendor_site_rec.org_id is NOT NULL AND
        p_vendor_site_rec.org_id <> ap_null_num) OR
       (p_vendor_site_rec.org_name is NOT NULL AND
        p_vendor_site_rec.org_name <> ap_null_char) THEN

      	Check_org_id_name(p_vendor_site_rec.org_id,
                          p_vendor_site_rec.org_name,
                          'AP_SUPPLIER_SITES_INT',
                          p_vendor_site_rec.vendor_site_interface_id,
                          x_valid);

       	IF NOT x_valid THEN
       		x_return_status := FND_API.G_RET_STS_ERROR;
       		-- Bug 8438716 Start
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                l_api_name,'Call after Check_org_id_name... Parameters: '
                ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                ||' ,p_vendor_site_rec.org_name: '||p_vendor_site_rec.org_name);
            END IF;
       		-- Bug 8438716 End
     	END IF;

    END IF;


    ------------------------------------------------------------------------
    l_debug_info := 'Call to Validate pay_on_receipt_summary_code';
    ------------------------------------------------------------------------
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    END IF;
    --
    -- Validate and default pay_on_receipt_summary_code
    --
    IF p_vendor_site_rec.pay_on_code is NOT NULL  AND
       p_vendor_site_rec.pay_on_code <> ap_null_char THEN

        Check_pay_on_rec_sum_code(p_vendor_site_rec.pay_on_code,
                                p_vendor_site_rec.pay_on_receipt_summary_code,
                                x_valid);
      IF NOT x_valid THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF g_source = 'IMPORT' THEN
          IF (Insert_Rejections(
                'AP_SUPPLIER_SITES_INT',
                p_vendor_site_rec.vendor_site_interface_id,
                'AP_INVALID_PAY_ON_RCE',
                g_user_id,
                g_login_id,
                'Validate_Vendor_Site') <> TRUE) THEN
            --
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                l_api_name,'Parameters: '
                ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                ||' ,Pay_On_Code: '||p_vendor_site_rec.pay_on_code
                ||' ,Pay_On_Receipt_Summary_Code: '
                ||p_vendor_site_rec.pay_on_receipt_summary_code);
            END IF;
          END IF;
        ELSE
            -- Bug 5491139 hkaniven start --
            FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_PAY_ON_RCE');
            FND_MSG_PUB.ADD;
            -- Bug 5491139 hkaniven end --
            -- Bug 8438716 Start
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                l_api_name,'Call after Check_pay_on_rec_sum_code... Parameters: '
                ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                ||' ,Pay_On_Code: '||p_vendor_site_rec.pay_on_code
                ||' ,Pay_On_Receipt_Summary_Code: '
                ||p_vendor_site_rec.pay_on_receipt_summary_code);
            END IF;
            -- Bug 8438716 End
        END IF;
      END IF;
    END IF;

    ------------------------------------------------------------------------
    l_debug_info := 'Call to Validate shipping_control';
    ------------------------------------------------------------------------
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    END IF;
    --
    -- Validate shipping_control
    --
    IF p_vendor_site_rec.shipping_control is NOT NULL
       AND p_vendor_site_rec.shipping_control  <> ap_null_char THEN

       	Check_Shipping_Control(p_vendor_site_rec.shipping_control,
                                x_valid
                                );

      IF NOT x_valid THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF g_source = 'IMPORT' THEN
          IF (Insert_Rejections(
                'AP_SUPPLIER_SITES_INT',
                p_vendor_site_rec.vendor_site_interface_id,
                'AP_INVALID_SHIPPING_CONTROL',
                g_user_id,
                g_login_id,
                'Validate_Vendor_Site') <> TRUE) THEN
            --
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                l_api_name,'Parameters: '
                ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                ||' ,Shipping_Control: '||p_vendor_site_rec.shipping_control);
            END IF;
          END IF;
        ELSE
            -- Bug 5491139 hkaniven start --
            FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_SHIPPING_CONTROL');
            FND_MSG_PUB.ADD;
            -- Bug 5491139 hkaniven end --
            -- Bug 8438716 Start
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                l_api_name,'Call Check_Shipping_Control after... Parameters: '
                ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                ||' ,Shipping_Control: '||p_vendor_site_rec.shipping_control);
            END IF;
            -- Bug 8438716 End
        END IF;
      END IF;
    END IF;

    ------------------------------------------------------------------------
    l_debug_info := 'Call to Validate Terms_Id and Terms_Name';
    ------------------------------------------------------------------------
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    END IF;

    -- Terms_Id and Terms_Name validation

    IF ((p_vendor_site_rec.terms_id is NOT NULL AND
         p_vendor_site_rec.terms_id <> ap_null_num) OR
        (p_vendor_site_rec.terms_name is NOT NULL AND
         p_vendor_site_rec.terms_name <> ap_null_char) OR
        (p_vendor_site_rec.default_terms_id is NOT NULL AND
         p_vendor_site_rec.default_terms_id <> ap_null_num) --6393761
        ) THEN

      Check_terms_id_code(p_vendor_site_rec.terms_id,
                               p_vendor_site_rec.terms_name,
                               p_vendor_site_rec.default_terms_id,
                               x_valid);
      IF NOT x_valid THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF g_source = 'IMPORT' THEN
          IF (Insert_Rejections(
                'AP_SUPPLIER_SITES_INT',
                p_vendor_site_rec.vendor_site_interface_id,
                'AP_INCONSISTENT_TERM',
                g_user_id,
                g_login_id,
                'Validate_Vendor_Site') <> TRUE) THEN
            --
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                l_api_name,'Parameters: '
                ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                ||' ,Terms_Id: '||p_vendor_site_rec.terms_id
                ||' ,Terms_Name: '||p_vendor_site_rec.terms_name
                ||' ,Default_Terms_Id: '||p_vendor_site_rec.default_terms_Id);
            END IF;
          END IF;
        ELSE
            -- Bug 5491139 hkaniven start --
            FND_MESSAGE.SET_NAME('SQLAP','AP_INCONSISTENT_TERM');
            FND_MSG_PUB.ADD;
            -- Bug 5491139 hkaniven end --
            -- Bug 8438716 Start
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                l_api_name,'Call after Check_terms_id_code... Parameters: '
                ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                ||' ,Terms_Id: '||p_vendor_site_rec.terms_id
                ||' ,Terms_Name: '||p_vendor_site_rec.terms_name
                ||' ,Default_Terms_Id: '||p_vendor_site_rec.default_terms_Id);
            END IF;
            -- Bug 8438716 End
        END IF;
      END IF;
    END IF;

    ------------------------------------------------------------------------
    l_debug_info := 'Call to Validate pay_on_code';
    ------------------------------------------------------------------------
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    END IF;
    --
    -- Validate pay_on_code
    --
    IF p_vendor_site_rec.pay_on_code is NOT NULL  AND
       p_vendor_site_rec.pay_on_code <> ap_null_char THEN

 	Check_Valid_pay_on_code(p_vendor_site_rec.pay_on_code,
                                p_vendor_site_rec.purchasing_site_flag,
       				p_vendor_site_rec.pay_site_flag,
       				p_vendor_site_rec.default_pay_site_id,
                                x_valid);

      IF NOT x_valid THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF g_source = 'IMPORT' THEN
          IF (Insert_Rejections(
                'AP_SUPPLIER_SITES_INT',
                p_vendor_site_rec.vendor_site_interface_id,
                'AP_INVALID_PAY_ON_CODE',
                g_user_id,
                g_login_id,
                'Validate_Vendor_Site') <> TRUE) THEN
            --
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                l_api_name,'Parameters: '
                ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                ||' ,Pay_On_Code: '||p_vendor_site_rec.pay_on_code
                ||' ,Purchasing_Site_Flag: '||p_vendor_site_rec.purchasing_site_flag
                ||' ,Pay_Site_Flag: '||p_vendor_site_rec.pay_site_flag);
            END IF;
          END IF;
        ELSE
            -- Bug 5491139 hkaniven start --
            FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_PAY_ON_CODE');
            FND_MSG_PUB.ADD;
            -- Bug 5491139 hkaniven end --
            -- Bug 8438716 Start
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                l_api_name,'Call after Check_Valid_pay_on_code... Parameters: '
                ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                ||' ,Pay_On_Code: '||p_vendor_site_rec.pay_on_code
                ||' ,Purchasing_Site_Flag: '||p_vendor_site_rec.purchasing_site_flag
                ||' ,Pay_Site_Flag: '||p_vendor_site_rec.pay_site_flag);
            END IF;
            -- Bug 8438716 End
        END IF;
      END IF;
    END IF;

    ------------------------------------------------------------------------
    l_debug_info := 'Call to Validate pay_on_code and pay_on_receipt_summary_code';
    ------------------------------------------------------------------------
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    END IF;

    IF (p_vendor_site_rec.pay_on_receipt_summary_code is not null AND
        p_vendor_site_rec.pay_on_receipt_summary_code <> ap_null_char
       AND p_vendor_site_rec.pay_on_code is not null AND
           p_vendor_site_rec.pay_on_code <> ap_null_char) THEN
      pay_on_receipt_summary_valid(p_vendor_site_rec.pay_on_receipt_summary_code,
                                   p_vendor_site_rec.pay_on_code,
                                   x_valid);
      IF NOT x_valid THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF g_source = 'IMPORT' THEN
          IF (Insert_Rejections(
                'AP_SUPPLIER_SITES_INT',
                p_vendor_site_rec.vendor_site_interface_id,
                'AP_INVALID_PAY_ON_RCE',
                g_user_id,
                g_login_id,
                'Validate_Vendor_Site') <> TRUE) THEN
            --
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                l_api_name,'Parameters: '
                ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                ||' ,Pay_On_Code: '||p_vendor_site_rec.pay_on_code
                ||' ,Pay_On_Receipt_Summary_Code: '
                ||p_vendor_site_rec.pay_on_receipt_summary_code);
            END IF;
          END IF;
        ELSE
            -- Bug 5491139 hkaniven start --
            FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_PAY_ON_RCE');
            FND_MSG_PUB.ADD;
            -- Bug 5491139 hkaniven end --
            -- Bug 8438716 Start
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                l_api_name,'Call after pay_on_receipt_summary_valid... Parameters: '
                ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                ||' ,Pay_On_Code: '||p_vendor_site_rec.pay_on_code
                ||' ,Pay_On_Receipt_Summary_Code: '
                ||p_vendor_site_rec.pay_on_receipt_summary_code);
            END IF;
            -- Bug 8438716 End
        END IF;
      END IF;
    END IF;

    ------------------------------------------------------------------------
    l_debug_info := 'Call to Validate Payment_Priority';
    ------------------------------------------------------------------------
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    END IF;
    --
    -- Validate Payment_Priority
    --
    IF p_vendor_site_rec.payment_priority is NOT NULL AND
       p_vendor_site_rec.payment_priority <> ap_null_num THEN

    	Check_payment_priority(p_vendor_site_rec.payment_priority,
                           x_valid
                           );
      IF NOT x_valid THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF g_source = 'IMPORT' THEN
          IF (Insert_Rejections(
                'AP_SUPPLIER_SITES_INT',
                p_vendor_site_rec.vendor_site_interface_id,
                'AP_INVALID_PAY_PRIORITY',
                g_user_id,
                g_login_id,
                'Validate_Vendor_Site') <> TRUE) THEN
            --
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                l_api_name,'Parameters: '
                ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                ||' ,Payment_Priority: '||p_vendor_site_rec.payment_priority);
            END IF;
          END IF;
        ELSE
            -- Bug 5491139 hkaniven start --
            FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_PAYMENT_PRIORITY');
            FND_MSG_PUB.ADD;
            -- Bug 5491139 hkaniven end --
            -- Bug 8438716 Start
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                l_api_name,'Call after Check_payment_priority... Parameters: '
                ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                ||' ,Payment_Priority: '||p_vendor_site_rec.payment_priority);
            END IF;
            -- Bug 8438716 End
        END IF;
      END IF;
    END IF;

    ------------------------------------------------------------------------
    l_debug_info := 'Call to Validate Invoice Currency Code';
    ------------------------------------------------------------------------
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                   l_api_name,l_debug_info);
    END IF;

    IF (p_vendor_site_rec.invoice_currency_code is not null AND
        p_vendor_site_rec.invoice_currency_code  <> ap_null_char) THEN
      	val_currency_code(p_vendor_site_rec.invoice_currency_code,
                        x_valid);
      IF NOT x_valid THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF g_source = 'IMPORT' THEN
          IF (Insert_Rejections(
                'AP_SUPPLIER_SITES_INT',
                p_vendor_site_rec.vendor_site_interface_id,
                'AP_INVALID_INV_CURRENCY',
                g_user_id,
                g_login_id,
                'Validate_Vendor_Site') <> TRUE) THEN
            --
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                l_api_name,'Parameters: '
                ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                ||' ,Invoice_Currency_Code: '||p_vendor_site_rec.invoice_currency_code);
            END IF;
          END IF;
        ELSE
            -- Bug 5491139 hkaniven start --
            FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_INV_CURRENCY');
            FND_MSG_PUB.ADD;
            -- Bug 5491139 hkaniven end --
            -- Bug 8438716 Start
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                l_api_name,'Call after val_currency_code... Parameters: '
                ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                ||' ,Invoice_Currency_Code: '||p_vendor_site_rec.invoice_currency_code);
            END IF;
            -- Bug 8438716 End
        END IF;
      END IF;
    END IF;

    ------------------------------------------------------------------------
    l_debug_info := 'Call to Validate Payment Currency Code';
    ------------------------------------------------------------------------
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    END IF;

    IF (p_vendor_site_rec.payment_currency_code is not null
        AND p_vendor_site_rec.payment_currency_code <> ap_null_char
       AND p_vendor_site_rec.invoice_currency_code is not null
       AND p_vendor_site_rec.invoice_currency_code <> ap_null_char) THEN
      	payment_currency_code_valid(p_vendor_site_rec.payment_currency_code,
                                  p_vendor_site_rec.invoice_currency_code,
                                  x_valid);
      IF NOT x_valid THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF g_source = 'IMPORT' THEN
          IF (Insert_Rejections(
                'AP_SUPPLIER_SITES_INT',
                p_vendor_site_rec.vendor_site_interface_id,
                'AP_INVALID_PAY_CURRENCY',
                g_user_id,
                g_login_id,
                'Validate_Vendor_Site') <> TRUE) THEN
            --
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                l_api_name,'Parameters: '
                ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                ||' ,Invoice_Currency_Code: '||p_vendor_site_rec.invoice_currency_code
                ||' ,Payment_Currency_Code: '||p_vendor_site_rec.payment_currency_code);
            END IF;
          END IF;
        ELSE
            -- Bug 5491139 hkaniven start --
            FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_PAY_CURRENCY');
            FND_MSG_PUB.ADD;
            -- Bug 5491139 hkaniven end --
            -- Bug 8438716 Start
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                l_api_name,'Call after payment_currency_code_valid... Parameters: '
                ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                ||' ,Invoice_Currency_Code: '||p_vendor_site_rec.invoice_currency_code
                ||' ,Payment_Currency_Code: '||p_vendor_site_rec.payment_currency_code);
            END IF;
            -- Bug 8438716 End
        END IF;
      END IF;
    END IF;

    ------------------------------------------------------------------------
    l_debug_info := 'Call to Validate accts_pay_ccid';
    ------------------------------------------------------------------------
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    END IF;
    --
    -- Validate accts_pay_ccid
    --
    IF p_vendor_site_rec.accts_pay_code_combination_id is NOT NULL
       AND p_vendor_site_rec.accts_pay_code_combination_id <> ap_null_num THEN

     	Validate_CCIDs('ACCTS_PAY_CCID',
		p_vendor_site_rec.accts_pay_code_combination_id, l_sob,
                                     x_valid);
      IF NOT x_valid THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF g_source = 'IMPORT' THEN
          IF (Insert_Rejections(
                    'AP_SUPPLIER_SITES_INT',
                    p_vendor_site_rec.vendor_site_interface_id,
                    'AP_INVALID_ACCOUNTS_PAY_CCID',
                    g_user_id,
                    g_login_id,
                    'Validate_Vendor_Site') <> TRUE) THEN
           --
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                l_api_name,'Parameters: '
                ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                ||' ,Accts_Pay_Code_Comb_Id: '
                ||p_vendor_site_rec.accts_pay_code_combination_id
                ||' ,Set_Of_Books_Id: '||l_sob);
            END IF;
          END IF;
        ELSE
            -- Bug 5491139 hkaniven start --
            FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_ACCOUNTS_PAY_CCID');
            FND_MSG_PUB.ADD;
            -- Bug 5491139 hkaniven end --
            -- Bug 8438716 Start
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                l_api_name,'Call after Validate_CCIDs(ACCTS_PAY_CCID...) ... Parameters: '
                ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                ||' ,Accts_Pay_Code_Comb_Id: '
                ||p_vendor_site_rec.accts_pay_code_combination_id
                ||' ,Set_Of_Books_Id: '||l_sob);
            END IF;
            -- Bug 8438716 End
        END IF;
      END IF;
    END IF;

    ------------------------------------------------------------------------
    l_debug_info := 'Call to Validate prepay_ccid';
    ------------------------------------------------------------------------
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    END IF;
    --
    -- Validate prepay_code_combination_id
    --
    IF p_vendor_site_rec.prepay_code_combination_id is NOT NULL AND
       p_vendor_site_rec.prepay_code_combination_id <> ap_null_num THEN
      	Validate_CCIDs( 'PREPAY_CCID',
		p_vendor_site_rec.prepay_code_combination_id, l_sob,
                                    x_valid);
      IF NOT x_valid THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF g_source = 'IMPORT' THEN
          IF (Insert_Rejections(
                    'AP_SUPPLIER_SITES_INT',
                    p_vendor_site_rec.vendor_site_interface_id,
                    'AP_SUPP_INVALID_CCID',
                    g_user_id,
                    g_login_id,
                    'Validate_Vendor_Site') <> TRUE) THEN
           --
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                l_api_name,'Parameters: '
                ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                ||' ,Prepay_Code_Combination_Id: '
                ||p_vendor_site_rec.prepay_code_combination_id
                ||' ,Set_Of_Books_Id: '||l_sob);
            END IF;
          END IF;
        ELSE
            -- Bug 5491139 hkaniven start --
            FND_MESSAGE.SET_NAME('SQLAP','AP_SUPP_INVALID_CCID');
            FND_MSG_PUB.ADD;
            -- Bug 5491139 hkaniven end --
            -- Bug 8438716 Start
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                l_api_name,'Call after Validate_CCIDs(PREPAY_CCID...)... Parameters: '
                ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                ||' ,Prepay_Code_Combination_Id: '
                ||p_vendor_site_rec.prepay_code_combination_id
                ||' ,Set_Of_Books_Id: '||l_sob);
            END IF;
            -- Bug 8438716 End
        END IF;
      END IF;
    END IF;

    ------------------------------------------------------------------------
    l_debug_info := 'Call to Validate future_dated_payment_ccid';
    ------------------------------------------------------------------------
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    END IF;
    --
    -- Validate future_dated_payment_ccid
    --
    IF p_vendor_site_rec.future_dated_payment_ccid is NOT NULL AND
       p_vendor_site_rec.future_dated_payment_ccid <> ap_null_num THEN
	Validate_CCIDs( 'FUTURE_DATED_PAYMENT_CCID',
		p_vendor_site_rec.future_dated_payment_ccid, l_sob,
                                    x_valid);
      IF NOT x_valid THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF g_source = 'IMPORT' THEN
          IF (Insert_Rejections(
                    'AP_SUPPLIER_SITES_INT',
                    p_vendor_site_rec.vendor_site_interface_id,
                    'AP_SUPP_INVALID_CCID',
                    g_user_id,
                    g_login_id,
                    'Validate_Vendor_Site') <> TRUE) THEN
           --
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                l_api_name,'Parameters: '
                ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                ||' ,Future_Dated_Payment_Ccid: '
                ||p_vendor_site_rec.future_dated_payment_ccid
                ||' ,Set_Of_Books_Id: '||l_sob);
            END IF;
          END IF;
        ELSE
            -- Bug 5491139 hkaniven start --
            FND_MESSAGE.SET_NAME('SQLAP','AP_SUPP_INVALID_CCID');
            FND_MSG_PUB.ADD;
            -- Bug 5491139 hkaniven end --
            -- Bug 8438716 Start
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                l_api_name,'Call after Validate_CCIDs(FUTURE_DATED_PAYMENT_CCID...)... Parameters: '
                ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                ||' ,Future_Dated_Payment_Ccid: '
                ||p_vendor_site_rec.future_dated_payment_ccid
                ||' ,Set_Of_Books_Id: '||l_sob);
            END IF;
            -- Bug 8438716 End
        END IF;
      END IF;
    END IF;

    ------------------------------------------------------------------------
    l_debug_info := 'Call to Validate duns_number';
    ------------------------------------------------------------------------
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    END IF;
    --
    -- Validate supplier site duns number
    -- Added for the R12 FSIO gap
    --(bug6053476)
    IF p_vendor_site_rec.duns_number is NOT NULL
       AND p_vendor_site_rec.duns_number <> ap_null_char THEN

       --call the duns number validaton API
       Chk_new_duns_number(p_vendor_site_rec.duns_number,
                           x_valid);

      IF NOT x_valid THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF g_source = 'IMPORT' THEN
          IF (Insert_Rejections(
                'AP_SUPPLIER_SITES_INT',
                p_vendor_site_rec.vendor_site_interface_id,
                'AP_INVALID_DUNS_NUMBER',
                g_user_id,
                g_login_id,
                'Validate_Vendor_Site') <> TRUE) THEN
            --
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                l_api_name,'Parameters: '
                ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                ||' ,Invalid_Duns_number: '
                ||p_vendor_site_rec.duns_number);
            END IF;
          END IF;
        ELSE
            FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_DUNS_NUMBER');
            FND_MSG_PUB.ADD;
            -- Bug 8438716 Start
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                l_api_name,'Call after Chk_new_duns_number... Parameters: '
                ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                ||' ,Invalid_Duns_number: '
                ||p_vendor_site_rec.duns_number);
            END IF;
            -- Bug 8438716 End
        END IF;
      END IF;
    END IF;
     -- starting the Changes for CLM reference data management bug#9499174
      --
      -- Logic to check if user is ISP UI is available or not.
      -- If ISP UI is not available then reject record if
      -- data present in any of new CCR Columns

       -----------------------------------------------------------------------------------
        l_debug_info := 'Call to validate User Interface availability for Referenec Data';
       -----------------------------------------------------------------------------------
      If ((PO_ISPCODELEVEL_PVT.get_curr_isp_supp_code_level
          < PO_ISPCODELEVEL_PVT.G_ISP_SUP_CODE_LEVEL_CLM_BASE)
          AND
          (p_vendor_site_rec.cage_code is not null
            OR p_vendor_site_rec.cage_code is not null
            OR p_vendor_site_rec.legal_business_name is not null
            OR p_vendor_site_rec.doing_bus_as_name is not null
            OR p_vendor_site_rec.small_business_code is not null
            OR p_vendor_site_rec.ccr_comments is not null
            OR p_vendor_site_rec.debarment_start_date is not null
            OR p_vendor_site_rec.debarment_end_date is not null
       )) THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
           IF g_source = 'IMPORT' THEN
             IF (Insert_Rejections(
                'AP_SUPPLIER_SITES_INT',
                p_vendor_site_rec.vendor_site_interface_id,
                'AP_ISP_NOT_AVAILABLE',
                g_user_id,
                g_login_id,
                'Validate_Vendor_Site') <> TRUE) THEN
               IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME
                               ||l_api_name,'Parameters: '
                               ||' Vendor_Site_Interface_Id:'
      		                     ||p_vendor_site_rec.vendor_site_interface_id
                               ||' ISP page not available and CCR data available');
               END IF;
             END IF;
           ELSE
               FND_MESSAGE.SET_NAME('SQLAP','AP_ISP_NOT_AVAILABLE');
               FND_MSG_PUB.ADD;
           END IF;
      END IF ;

  ------------------------------------------------------
  l_debug_info := 'Call to validate small business code';
  ------------------------------------------------------

   IF ((p_vendor_site_rec.small_business_code IS NOT NULL)
          AND
          (
                  p_vendor_site_rec.small_business_code<>ap_null_char
          )
          ) THEN
          validate_lookups('SMALL_BUSINESS_CODE'
                           ,p_vendor_site_rec.small_business_code
                           ,'SMALL_NOT_SMALL_BUSINESS_CODE'
                           ,'AP_LOOKUP_CODES'
                           ,x_valid);
          IF (NOT x_valid) THEN
                  x_return_status :=  FND_API.G_RET_STS_ERROR;
                  IF g_source = 'IMPORT' THEN
                          IF (Insert_Rejections( 'AP_SUPPLIER_SITES_INT',
                                                  p_vendor_site_rec.vendor_site_interface_id,
                                                  'AP_INVALID_SMALL_NSMALL_CODE',
                                                  g_user_id,
                                                  g_login_id,
                                                  'Validate_Vendor_Site') <> TRUE) THEN
                                  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME
                                          ||l_api_name,'Parameters: '
                                          ||' Vendor site interface id '
                                          ||p_vendor_site_rec.vendor_site_interface_id
                                          ||', Small business code '
                                          ||p_vendor_site_rec.small_business_code);
                                  END IF;
                          END IF;
                  ELSE
                          FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_SMALL_NSMALL_CODE');
                          FND_MSG_PUB.ADD;
                  END IF;
          END IF;

   END IF;
   -- Ending the Changes for CLM reference data management bug#9499174


    IF p_mode = 'U' THEN

	--update validations

	null;

     ------------------------------------------------------------------------
    l_debug_info := 'check for prohibiting the update of CCR vendor site';
    ------------------------------------------------------------------------
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    END IF;
    --
    -- Check if there is an attempt to update any restricted
    -- fields for a CCR vendor site. Added for the R12 FSIO
    -- GAP.(bug6053476)

      Chk_update_site_ccr_values(p_vendor_site_rec,
                                 p_calling_prog,
				 x_valid);

      IF NOT x_valid THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF g_source = 'IMPORT' THEN
          IF (Insert_Rejections(
                'AP_SUPPLIER_SITES_INT',
                 p_vendor_site_rec.vendor_site_interface_id,
                'AP_CCR_NO_UPDATE',
                 g_user_id,
                 g_login_id,
                'Validate_Vendor_Site') <> TRUE) THEN

            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                l_api_name,'Parameters: '
                ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                ||' ,attempting to update non-updatablee elements on CCR site : '
                ||p_vendor_site_rec.vendor_site_id);
            END IF;
          END IF;
        ELSE
            FND_MESSAGE.SET_NAME('SQLAP','AP_CCR_NO_UPDATE');
            FND_MSG_PUB.ADD;
            -- Bug 8438716 Start
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                l_api_name,'Call after Chk_update_site_ccr_values... Parameters: '
                ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                ||' ,attempting to update non-updatablee elements on CCR site : '
                ||p_vendor_site_rec.vendor_site_id);
            END IF;
            -- Bug 8438716 End
        END IF;
   END IF;

    ELSIF p_mode = 'I' THEN

	--insert validations

        ------------------------------------------------------------------------
        l_debug_info := 'Call to Validate payee';
        ------------------------------------------------------------------------
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
        END IF;
        --
        --  Calling IBY Payee Validation API
        --
        IF p_vendor_site_rec.ext_payee_rec.payer_org_type IS NOT NULL THEN

	  /*Bug 7572325- added the call to count_and_get to get the count
            before call to IBY API in local variable*/

          FND_MSG_PUB.Count_And_Get(p_count => l_msg_count,
                                    p_data => l_msg_data);

          IBY_DISBURSEMENT_SETUP_PUB.Validate_External_Payee
            ( p_api_version     => 1.0,
              p_init_msg_list   => FND_API.G_FALSE,
              p_ext_payee_rec   => p_vendor_site_rec.ext_payee_rec,
              x_return_status   => l_payee_return_status,
              x_msg_count       => l_payee_msg_count,
              x_msg_data        => l_payee_msg_data);

           IF l_payee_return_status = FND_API.G_RET_STS_SUCCESS THEN
                x_payee_valid := 'V';
           ELSE
                x_payee_valid := 'F';
		x_return_status := l_payee_return_status;
                IF g_source = 'IMPORT' THEN
                    IF (Insert_Rejections(
                      'AP_SUPPLIER_SITES_INT',
                      p_vendor_site_rec.vendor_site_interface_id,
                      --'AP_INVALID_PAYEE',
                      'AP_INVALID_PAYEE_INFO',/*bug 7572325*/
                      g_user_id,
                      g_login_id,
                      'Validate_Vendor_Site') <> TRUE) THEN
                      --
                      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                          l_api_name,'Parameters: '
                          ||' Vendor_Site_Interface_Id:' ||
                                p_vendor_site_rec.vendor_interface_id);
                      END IF;
                    END IF;

		    --bug 7572325 addded below file logging for improved exception
                   --message handling
                    IF (l_payee_msg_data IS NOT NULL) THEN
                     -- Print the error returned from the IBY service even if the debug
                     -- mode is off
                      AP_IMPORT_UTILITIES_PKG.Print('Y', '2)Error in '||l_debug_info||
                                                    '---------------------->'||
                                                    l_payee_msg_data);

                    ELSE
                      -- If the l_payee_msg_data is null then the IBY service returned
                      -- more than one error.  The calling module will need to get
                      -- them from the message stack
                     FOR i IN l_msg_count..l_payee_msg_count
                      LOOP
                       l_error_code := FND_MSG_PUB.Get(p_msg_index => i,
                                                       p_encoded => 'F');

                        If i = l_msg_count then
                          l_error_code := '2)Error in '||l_debug_info||
                                                    '---------------------->'||
                                                    l_error_code;
                        end if;

                        AP_IMPORT_UTILITIES_PKG.Print('Y', l_error_code);

                      END LOOP;

                     END IF;--bug 7572325
                ELSE
                    -- Bug 5491139 hkaniven start --
                    --FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_PAYEE'); --bug 7572325
		    FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_PAYEE_INFO'); --bug 7572325
                    FND_MSG_PUB.ADD;
                    -- Bug 5491139 hkaniven end --
                    -- Bug 8438716 Start
                      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                          l_api_name,'Call after IBY_DISBURSEMENT_SETUP_PUB.Validate_External_Payee... Parameters: '
                          ||' Vendor_Site_Interface_Id:' ||
                                p_vendor_site_rec.vendor_interface_id);
                      END IF;
                    -- Bug 8438716 End
                END IF;
           END IF;
        ELSE
           x_payee_valid := 'N';
        END IF; --payee valid

	--call location validation to validate entered id
	--and/or compare address componenets
	--and that the location is already in use by existing supplier

-- Bug 6918411/6808171 CTETALA Begin
-- Added code to validate country code
        ----------------------------------------------------------------------------------------------------
        l_debug_info := 'Call to Validate country code';
        ----------------------------------------------------------------------------------------------------
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
        END IF;

        IF(p_vendor_site_rec.country IS NOT NULL) THEN
                BEGIN
                        SELECT null INTO l_dummy
                        FROM   FND_TERRITORIES
                        WHERE  TERRITORY_CODE = p_vendor_site_rec.country
                        AND    OBSOLETE_FLAG = 'N';
                        x_valid := TRUE;

                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            x_valid := FALSE;
                END;

                IF NOT x_valid THEN
                       x_return_status := FND_API.G_RET_STS_ERROR;
                       IF g_source = 'IMPORT' THEN
                          IF (Insert_Rejections
						        (
                                 'AP_SUPPLIER_SITES_INT',
                                 p_vendor_site_rec.vendor_site_interface_id,
                                 'AP_API_INVALID_COUNTRY',
                                 g_user_id,
                                 g_login_id,
                                 'Validate_Vendor_Site') <> TRUE) THEN
                                 IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                                     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                                                    l_api_name,'Parameters: '
                                                    ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                                                    ||' ,Country code validation '
                                                    ||p_vendor_site_rec.country);
                                 END IF;
                          END IF;
                       ELSE
                          FND_MESSAGE.SET_NAME('SQLAP','AP_API_INVALID_COUNTRY');
                          FND_MSG_PUB.ADD;
                          -- Bug 8438716 Start
                                 IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                                     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                                                    l_api_name,'Error After validating p_vendor_site_rec.country... Parameters: '
                                                    ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                                                    ||' ,Country code validation '
                                                    ||p_vendor_site_rec.country);
                                 END IF;
                          -- Bug 8438716 End
                       END IF; --import
                END IF; --country invalid
        END IF;

-- Bug 6918411/6808171 CTETALA End

	 -- Bug 7429668 If Party_Site_Name is provided, derive the party_site_id.
	 IF (p_vendor_site_rec.party_site_name IS NOT NULL AND
              p_vendor_site_rec.party_site_id IS NULL AND
              (p_vendor_site_rec.org_id IS NOT NULL OR
               p_vendor_site_rec.ORG_NAME IS NOT NULL) AND
			   p_vendor_site_rec.vendor_id IS NOT NULL)THEN
       Check_org_id_party_site_name(p_vendor_site_rec.org_id,
                                       p_vendor_site_rec.ORG_NAME,
                                       p_vendor_site_rec.party_site_id,
                                       p_vendor_site_rec.party_site_name,
                                       p_vendor_site_rec.vendor_id,
                                       'AP_SUPPLIER_SITES_INT',
                                       p_vendor_site_rec.vendor_site_interface_id,
                                       x_valid);
       IF NOT x_valid THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
		 IF g_source = 'IMPORT' THEN
           IF (Insert_Rejections(
             'AP_SUPPLIER_SITES_INT',
             p_vendor_site_rec.vendor_site_interface_id,
             'AP_INVALID_PARTY_SITE',
             g_user_id,
             g_login_id,
            'Validate_Vendor_Site') <> TRUE) THEN

             IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'Parameters: '
                     ||' Org_Id: '||p_vendor_site_rec.org_id
                     ||', Org_Name: '||p_vendor_site_rec.ORG_NAME
                     ||', Party_site_name: '||p_vendor_site_rec.party_site_name
                     ||', Party_site_id: '|| p_vendor_site_rec.party_site_id
					 ||', Vendor_id: '|| p_vendor_site_rec.vendor_id
                     ||', Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id);
             END IF;
           END IF;
         ELSE
            FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_PARTY_SITE');
            FND_MSG_PUB.ADD;
            -- Bug 8438716 Start
             IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'Call after Check_org_id_party_site_name... Parameters: '
                     ||' Org_Id: '||p_vendor_site_rec.org_id
                     ||', Org_Name: '||p_vendor_site_rec.ORG_NAME
                     ||', Party_site_name: '||p_vendor_site_rec.party_site_name
                     ||', Party_site_id: '|| p_vendor_site_rec.party_site_id
					 ||', Vendor_id: '|| p_vendor_site_rec.vendor_id
                     ||', Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id);
             END IF;
            -- Bug 8438716 End
         END IF;
       END IF;
	END IF;
	------------------------------------------------------------------------
    	l_debug_info := 'Call to Validate location';
    	------------------------------------------------------------------------
       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    	END IF;
	--
	-- Check for validity of location_id
	--
   	IF p_vendor_site_rec.location_id IS NOT NULL THEN
     		Check_Valid_Location_ID(p_vendor_site_rec.location_id,
				p_vendor_site_rec.party_site_id,
                                x_valid);

     		IF NOT x_valid THEN
			--location_id does not exist
        		x_location_valid := 'F';
        		-- Bug 8438716 Start
                IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
            		FND_LOG.STRING	(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'Parameters: '
                     				||', x_location_valid: '||x_location_valid
                    			 ||', P_Int_Key: '||p_vendor_site_rec.vendor_site_interface_id);
           		END IF;
        		-- Bug 8438716 End
		ELSE
			--location_id was valid
			x_location_valid := 'V';
     		END IF;
	ELSE

     --Bug 7835321 start
        IF p_vendor_site_rec.language IS NOT NULL THEN

         BEGIN
         OPEN c_lang_is ;
         FETCH c_lang_is into l_language,l_installed_flag;


        IF c_lang_is%NOTFOUND THEN
             valid_language_flag := False;
 	         --  x_valid := FALSE;
       	   IF g_source = 'IMPORT' THEN
        	      IF (Insert_Rejections(
          			 'AP_SUPPLIER_SITES_INT',
                  p_vendor_site_rec.vendor_site_interface_id,
          			 'INVALID_NLS_LANGUAGE',
          			 g_user_id,
          			 g_login_id,
           			'Create_Vendor_Site') <> TRUE)
                   THEN
                       IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
            				 FND_LOG.STRING	(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'Parameters: '
                     				||', P_Int_Table: '||'AP_SUPPLIER_SITES_INT'
                    			 ||', P_Int_Key: '||p_vendor_site_rec.vendor_site_interface_id
                            ||', P_Language: '||'LANGUAGE');
           		         END IF;
                END IF;

          ELSE
                   -- Bug 5491139 hkaniven start --
        	      FND_MESSAGE.SET_NAME('SQLAP','INVALID_NLS_LANGUAGE');
        	      FND_MSG_PUB.ADD;
                  -- Bug 5491139 hkaniven end --
          END IF;
           -- We have to ensure that no new locations are created in this case.
                      x_location_valid := 'F';
                      x_return_status := FND_API.G_RET_STS_ERROR;
      ELSE
            IF(l_installed_flag='D')
            THEN
            valid_language_flag := False;
           -- x_valid := FALSE;
      	   IF g_source = 'IMPORT' THEN
         	   IF (Insert_Rejections(
                 'AP_SUPPLIER_SITES_INT',
                 p_vendor_site_rec.vendor_site_interface_id,
          	 		 'DISABLED_NLS_LANGUAGE',
          			 g_user_id,
           			 g_login_id,
           			'Create_Vendor_Site') <> TRUE)
              THEN
          		  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
             				FND_LOG.STRING	(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'Parameters: '
                    			 ||', P_Int_Table: '||'AP_SUPPLIER_SITES_INT'
                    			 ||', P_Int_Key: '||p_vendor_site_rec.vendor_site_interface_id
                           ||',P_Language: '||'LANGUAGE');
          		  END IF;
             END IF;

           ELSE
                   -- Bug 5491139 hkaniven start --
        	      FND_MESSAGE.SET_NAME('SQLAP','DISABLED_NLS_LANGUAGE');
        	      FND_MSG_PUB.ADD;
                  -- Bug 5491139 hkaniven end --
      	   END IF;
           -- We have to ensure that no new locations are created in this case.
                      x_location_valid := 'F';
                      x_return_status := FND_API.G_RET_STS_ERROR;

   END IF;

   CLOSE c_lang_is;

END IF;
END;
END IF;

IF (Valid_language_flag) ---Bug 7835321 End
THEN

		Check_Valid_Location(
		p_party_site_id  => p_vendor_site_rec.party_site_id,
		p_address_line1  => p_vendor_site_rec.address_line1,
		p_address_line2  => p_vendor_site_rec.address_line2,
		p_address_line3  => p_vendor_site_rec.address_line3,
		p_address_line4  => p_vendor_site_rec.address_line4,
		p_city  => p_vendor_site_rec.city       ,
		p_state => p_vendor_site_rec.state    ,
		p_zip    => p_vendor_site_rec.zip ,
		p_province  => p_vendor_site_rec.province  ,
		p_country => p_vendor_site_rec.country,
		p_county => p_vendor_site_rec.county,
		p_language => p_vendor_site_rec.language,
		p_address_style	=> p_vendor_site_rec.address_style  ,
		p_vendor_id => p_vendor_site_rec.vendor_id,
		x_location_id	 => l_location_id,
		x_valid => x_valid,
		x_loc_count => x_loc_count); -- Bug 7429668

     		IF NOT x_valid THEN
			--no existing matching location
        		x_location_valid := 'N';
                    -- Bug 7429668 Start
                    IF x_loc_count > 1 THEN
                      -- We have to ensure that no new locations are created in this case.
                      x_location_valid := 'F';
                      x_return_status := FND_API.G_RET_STS_ERROR;

                      IF g_source = 'IMPORT' THEN

                         IF (Insert_Rejections(
                                               'AP_SUPPLIER_SITES_INT',
                                                p_vendor_site_rec.vendor_site_interface_id,
                                                'AP_MULTIPLE_ADDRESS',
                                                g_user_id,
                                                g_login_id,
                                               'Validate_Vendor_Site') <> TRUE) THEN

                               IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                                     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                                                    l_api_name,'Parameters: '
                                                    ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                                                    ||' ,Vendor_Id: '||p_vendor_site_rec.vendor_id
                                                    ||' ,Party_site_id: '||p_vendor_site_rec.party_site_id);
                               END IF;

                         END IF;
                     ELSE
                       -- Bug 5584046 --
                         FND_MESSAGE.SET_NAME('SQLAP','AP_MULTIPLE_ADDRESS');
                         FND_MSG_PUB.ADD;
                         -- Bug 8438716 Start
                               IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                                     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                                                    l_api_name,'Call after Check_Valid_Location Error-AP_MULTIPLE_ADDRESS... Parameters: '
                                                    ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                                                    ||' ,Vendor_Id: '||p_vendor_site_rec.vendor_id
                                                    ||' ,Party_site_id: '||p_vendor_site_rec.party_site_id);
                               END IF;
                         -- Bug 8438716 End
                     END IF; --import
				ELSIF x_loc_count = 0 AND
				      p_vendor_site_rec.party_site_id IS NOT NULL THEN
                      -- We have to ensure that no new locations are created in this case.
                      x_location_valid := 'F';
                      x_return_status := FND_API.G_RET_STS_ERROR;

                      IF g_source = 'IMPORT' THEN

                         IF (Insert_Rejections(
                                               'AP_SUPPLIER_SITES_INT',
                                                p_vendor_site_rec.vendor_site_interface_id,
                                                'AP_INCONSISTENT_ADDRESS',
                                                g_user_id,
                                                g_login_id,
                                               'Validate_Vendor_Site') <> TRUE) THEN

                               IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                                     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                                                    l_api_name,'Parameters: '
                                                    ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                                                    ||' ,Vendor_Id: '||p_vendor_site_rec.vendor_id
                                                    ||' ,Party_site_id: '||p_vendor_site_rec.party_site_id);
                               END IF;

                         END IF;
                     ELSE
                       -- Bug 5584046 --
                         FND_MESSAGE.SET_NAME('SQLAP','AP_INCONSISTENT_ADDRESS');
                         FND_MSG_PUB.ADD;
                         -- Bug 8438716 Start
                               IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                                     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                                                    l_api_name,'Call after Check_Valid_Location... Error-AP_INCONSISTENT_ADDRESS...  Parameters: '
                                                    ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                                                    ||' ,Vendor_Id: '||p_vendor_site_rec.vendor_id
                                                    ||' ,Party_site_id: '||p_vendor_site_rec.party_site_id);
                               END IF;
                         -- Bug 8438716 End
                     END IF; --import
				-- Bug 7429668 End
        		ELSE
                   /*bug 5584046 Before calling the HZ api we need to ensure that
                  Country and address_line1 coulumns are not null*/
                  IF(p_vendor_site_rec.country IS NULL)
                     AND (NVL(G_Vendor_Type_Lookup_Code,'DUMMY') <> 'EMPLOYEE') THEN

                      x_return_status := FND_API.G_RET_STS_ERROR;

                      IF g_source = 'IMPORT' THEN

                         IF (Insert_Rejections(
                                               'AP_SUPPLIER_SITES_INT',
                                                p_vendor_site_rec.vendor_site_interface_id,
                                                'AP_NULL_COUNTRY_NAME',
                                                g_user_id,
                                                g_login_id,
                                               'Validate_Vendor_Site') <> TRUE) THEN

                               IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                                     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                                                    l_api_name,'Parameters: '
                                                    ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                                                    ||' ,Vendor_Id: '||p_vendor_site_rec.vendor_id
                                                    ||' ,Org_id: '||p_vendor_site_rec.org_id
                                                    ||' ,Org_Name: '||p_vendor_site_rec.org_name);
                               END IF;

                         END IF;
                     ELSE
                       -- Bug 5584046 --
                         FND_MESSAGE.SET_NAME('SQLAP','AP_NULL_COUNTRY_NAME');
                         FND_MSG_PUB.ADD;
                         -- Bug 8438716 Start
                               IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                                     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                                                    l_api_name,'Validation error-p_vendor_site_rec.country is null-AP_NULL_COUNTRY_NAME... Parameters: '
                                                    ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                                                    ||' ,Vendor_Id: '||p_vendor_site_rec.vendor_id
                                                    ||' ,Org_id: '||p_vendor_site_rec.org_id
                                                    ||' ,Org_Name: '||p_vendor_site_rec.org_name);
                               END IF;
                         -- Bug 8438716 End
                     END IF; --import
                  END IF;

                  IF(p_vendor_site_rec.address_line1 IS NULL)
                    AND (NVL(G_Vendor_Type_Lookup_Code,'DUMMY') <> 'EMPLOYEE') THEN

                      x_return_status := FND_API.G_RET_STS_ERROR;

                      IF g_source = 'IMPORT' THEN

                         IF (Insert_Rejections(
                                               'AP_SUPPLIER_SITES_INT',
                                                p_vendor_site_rec.vendor_site_interface_id,
                                                'AP_NULL_ADDRESS_LINE1',
                                                g_user_id,
                                                g_login_id,
                                               'Validate_Vendor_Site') <> TRUE) THEN

                               IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                                     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                                                    l_api_name,'Parameters: '
                                                    ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                                                    ||' ,Vendor_Id: '||p_vendor_site_rec.vendor_id
                                                    ||' ,Org_id: '||p_vendor_site_rec.org_id
                                                    ||' ,Org_Name: '||p_vendor_site_rec.org_name);
                               END IF;

                         END IF;
                     ELSE
                        -- Bug 5584046
                         FND_MESSAGE.SET_NAME('SQLAP','AP_NULL_ADDRESS_LINE1');
                         FND_MSG_PUB.ADD;
                         -- Bug 8438716 Start
                               IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                                     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                                                    l_api_name,'Validation error p_vendor_site_rec.address_line1-AP_NULL_ADDRESS_LINE1... Parameters: '
                                                    ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                                                    ||' ,Vendor_Id: '||p_vendor_site_rec.vendor_id
                                                    ||' ,Org_id: '||p_vendor_site_rec.org_id
                                                    ||' ,Org_Name: '||p_vendor_site_rec.org_name);
                               END IF;
                         -- Bug 8438716 End
                     END IF; --import
                    END IF;
                     --bug 5584046
                  END IF;

		ELSE
			--found valid matching location
			x_location_valid := 'V';
			p_vendor_site_rec.location_id := l_location_id;
     		END IF;

   	END IF;
END IF; --Bug7835321
	------------------------------------------------------------------------
    	l_debug_info := 'Call to Validate party_site_id';
    	------------------------------------------------------------------------
       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    	END IF;
	--
	-- Check for validity of party_site_id
	--

   	IF p_vendor_site_rec.party_site_id IS NOT NULL THEN
     		Check_Valid_Party_Site_ID(p_vendor_site_rec.party_site_id,
				p_vendor_site_rec.location_id,
                                x_valid);

     		IF NOT x_valid THEN
			--party_site_id does not exist
        		x_party_site_valid := 'F';
                         -- Bug 8438716 Start
                               IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                                     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                                                    l_api_name,'Call after Check_Valid_Party_Site_ID - party_site_id does not exist');
                               END IF;
                         -- Bug 8438716 End
		ELSE
			--party_site_id was valid
			x_party_site_valid := 'V';
     		END IF;
	ELSE
		--party_site_id is null
		x_party_site_valid := 'N';

        -- Bug 8438716 Start
        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
              l_api_name,'Call after Check_Valid_Party_Site_ID - party_site_id is null');
        END IF;
        -- Bug 8438716 End

	END IF;

     	------------------------------------------------------------------------
    	l_debug_info := 'Call to Validate primary_pay_site_flag unique per Vendor';
    	------------------------------------------------------------------------
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    	END IF;
	--
	-- Validate primary_pay_site_flag - unique per vendor
	--

   	IF (p_vendor_site_rec.primary_pay_site_flag = 'Y')  THEN

    		Validate_unique_per_vendor('PRIMARY_PAY_SITE_FLAG',
        		p_vendor_site_rec.vendor_id,
                        p_vendor_site_id,
         	        p_vendor_site_rec.org_id,
                        p_vendor_site_rec.org_name,
                        x_valid
        		);
          IF NOT x_valid THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            IF g_source = 'IMPORT' THEN
              IF (Insert_Rejections(
                    'AP_SUPPLIER_SITES_INT',
                    p_vendor_site_rec.vendor_site_interface_id,
                    'AP_INVALID_PRIM_PAY_SITE',
                    g_user_id,
                    g_login_id,
                    'Validate_Vendor_Site') <> TRUE) THEN
               --
                IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                   l_api_name,'Parameters: '
                ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                ||' ,Vendor_Id: '||p_vendor_site_rec.vendor_id
                ||' ,Org_id: '||p_vendor_site_rec.org_id
                ||' ,Org_Name: '||p_vendor_site_rec.org_name);
                END IF;
              END IF;
            ELSE
                -- Bug 5491139 hkaniven start --
                FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_PRIM_PAY_SITE');
                FND_MSG_PUB.ADD;
                -- Bug 5491139 hkaniven end --
                -- Bug 8438716 Start
                IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                   l_api_name,'Call after Validate_unique_per_vendor... Parameters: '
                ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                ||' ,Vendor_Id: '||p_vendor_site_rec.vendor_id
                ||' ,Org_id: '||p_vendor_site_rec.org_id
                ||' ,Org_Name: '||p_vendor_site_rec.org_name);
                END IF;
                -- Bug 8438716 End
            END IF;
          END IF;
   	END IF;

    	------------------------------------------------------------------------
    	l_debug_info := 'Call to Validate Country of Origin Code';
    	------------------------------------------------------------------------
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                l_api_name,l_debug_info);
    	END IF;

   	IF (p_vendor_site_rec.country_of_origin_code is not null) THEN
      		country_of_origin_valid(p_vendor_site_rec.country_of_origin_code,
                              x_valid);
          IF NOT x_valid THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            IF g_source = 'IMPORT' THEN
              IF (Insert_Rejections(
                    'AP_SUPPLIER_SITES_INT',
                    p_vendor_site_rec.vendor_site_interface_id,
                    'AP_INVALID_COUNTRY_ORIGIN',
                    g_user_id,
                    g_login_id,
                    'Validate_Vendor_Site') <> TRUE) THEN
               --
                IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                   l_api_name,'Parameters: '
                ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                ||' ,Country_Of_Origin_Code: '||p_vendor_site_rec.country_of_origin_code);
                END IF;
              END IF;
            ELSE
                -- Bug 5491139 hkaniven start --
                FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_COUNTRY_ORIGIN');
                FND_MSG_PUB.ADD;
                -- Bug 5491139 hkaniven end --
                -- Bug 8438716 Start
                IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                   l_api_name,'Call after country_of_origin_valid... Parameters: '
                ||' Vendor_Site_Interface_Id: '||p_vendor_site_rec.vendor_site_interface_id
                ||' ,Country_Of_Origin_Code: '||p_vendor_site_rec.country_of_origin_code);
                END IF;
                -- Bug 8438716 End
            END IF;
          END IF;
   	END IF;

	IF p_calling_prog <> 'ISETUP' THEN

		--addl insert validations

    		------------------------------------------------------------------------
    		l_debug_info := 'Call to Validate pcard_site_flag';
    		------------------------------------------------------------------------
        	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         		FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                		l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate pcard_site_flag
		--
   		IF p_vendor_site_rec.pcard_site_flag is NOT NULL THEN

      			Validate_Lookups( 'PCARD_SITE_FLAG', p_vendor_site_rec.pcard_site_flag ,'YES/NO',
                                    'PO_LOOKUP_CODES',x_valid);
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                       'AP_SUPPLIER_SITES_INT',
                        p_vendor_site_rec.vendor_site_interface_id,
                       'AP_INVALID_PCARD_FLAG',
                        g_user_id,
                        g_login_id,
                       'Validate_Vendor_Site') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Pcard_Site_Flag: '
                            ||p_vendor_site_rec.pcard_site_flag);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_PCARD_SITE');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                        -- Bug 8438716 Start
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Call after Validate_Lookups(PCARD_SITE_FLAG...)... Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Pcard_Site_Flag: '
                            ||p_vendor_site_rec.pcard_site_flag);
                        END IF;
                        -- Bug 8438716 End
                    END IF;
                  END IF;
   		END IF;

    		------------------------------------------------------------------------
    		l_debug_info := 'Call to Validate Purchasing Site Flag';
    		------------------------------------------------------------------------
        	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         		FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                		l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate purchasing_site_flag
		--
   		IF p_vendor_site_rec.purchasing_site_flag is NOT NULL THEN

      			Validate_Lookups( 'PURCHASING_SITE_FLAG', p_vendor_site_rec.purchasing_site_flag,'YES/NO',
                                    'PO_LOOKUP_CODES', x_valid);
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                       'AP_SUPPLIER_SITES_INT',
                        p_vendor_site_rec.vendor_site_interface_id,
                       'AP_INVALID_PURCHASING_FLAG',
                        g_user_id,
                        g_login_id,
                       'Validate_Vendor_Site') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Purchasing_Site_Flag: '
                            ||p_vendor_site_rec.purchasing_site_flag);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_PURCHASING_FLAG');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                        -- Bug 8438716 Start
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Call after Validate_Lookups(PURCHASING_SITE_FLAG...)... Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Purchasing_Site_Flag: '
                            ||p_vendor_site_rec.purchasing_site_flag);
                        END IF;
                        -- Bug 8438716 End
                    END IF;
                  END IF;
   		END IF;

    		------------------------------------------------------------------------
    		l_debug_info := 'Call to Validate rfq_only_site_flag';
    		------------------------------------------------------------------------
        	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         		FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                		l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate rfq_only_site_flag
		--
   		IF p_vendor_site_rec.rfq_only_site_flag is NOT NULL THEN

      			Validate_Lookups( 'RFQ_ONLY_SITE_FLAG', p_vendor_site_rec.rfq_only_site_flag,'YES/NO',
                                    'PO_LOOKUP_CODES', x_valid);
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                       'AP_SUPPLIER_SITES_INT',
                        p_vendor_site_rec.vendor_site_interface_id,
                       'AP_INVALID_RFQ_FLAG',
                        g_user_id,
                        g_login_id,
                       'Validate_Vendor_Site') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Rfq_Only_Site_Flag: '
                            ||p_vendor_site_rec.rfq_only_site_flag);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_RFQ_FLAG');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                        -- Bug 8438716 Start
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Call after Validate_Lookups(RFQ_ONLY_SITE_FLAG...)... Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Rfq_Only_Site_Flag: '
                            ||p_vendor_site_rec.rfq_only_site_flag);
                        END IF;
                        -- Bug 8438716 End
                    END IF;
                  END IF;
   		END IF;

    		------------------------------------------------------------------------
    		l_debug_info := 'Call to Validate pay_site_flag';
    		------------------------------------------------------------------------
        	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         		FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                		l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate pay_site_flag
		--
   		IF p_vendor_site_rec.pay_site_flag is NOT NULL THEN

      			Validate_Lookups( 'PAY_SITE_FLAG', p_vendor_site_rec.pay_site_flag,'YES/NO',
                                    'PO_LOOKUP_CODES', x_valid);
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                       'AP_SUPPLIER_SITES_INT',
                        p_vendor_site_rec.vendor_site_interface_id,
                       'AP_INVALID_PAY_SITE_FLAG',
                        g_user_id,
                        g_login_id,
                       'Validate_Vendor_Site') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Pay_Site_Flag: '
                            ||p_vendor_site_rec.pay_site_flag);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_PAY_SITE_FLAG');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                        -- Bug 8438716 Start
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Call after Validate_Lookups(PAY_SITE_FLAG...)... Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Pay_Site_Flag: '
                            ||p_vendor_site_rec.pay_site_flag);
                        END IF;
                        -- Bug 8438716 End
                    END IF;
                  END IF;
   		END IF;

    		------------------------------------------------------------------------
    		l_debug_info := 'Call to Validate attention_ar_flag';
    		------------------------------------------------------------------------
        	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         		FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                		l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate attention_ar_flag
		--
   		IF p_vendor_site_rec.attention_ar_flag is NOT NULL THEN

      			Validate_Lookups( 'ATTENTION_AR_FLAG', p_vendor_site_rec.attention_ar_flag,'YES/NO',
                                    'PO_LOOKUP_CODES', x_valid);
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                       'AP_SUPPLIER_SITES_INT',
                        p_vendor_site_rec.vendor_site_interface_id,
                       'AP_INVALID_ATTN_AR_FLAG',
                        g_user_id,
                        g_login_id,
                       'Validate_Vendor_Site') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Attention_Ar_Flag: '
                            ||p_vendor_site_rec.attention_ar_flag);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_ATTN_AR_FLAG');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                        -- Bug 8438716 Start
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Call after Validate_Lookups(ATTENTION_AR_FLAG...)... Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Attention_Ar_Flag: '
                            ||p_vendor_site_rec.attention_ar_flag);
                        END IF;
                        -- Bug 8438716 End
                    END IF;
                  END IF;
   		END IF;

    		------------------------------------------------------------------------
    		l_debug_info := 'Call to Validate primary_pay_site_flag';
    		------------------------------------------------------------------------
        	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         		FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                		l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate primary_pay_site_flag
		--
   		IF p_vendor_site_rec.primary_pay_site_flag  is NOT NULL THEN

      			Validate_Lookups( 'PRIMARY_PAY_SITE_FLAG', p_vendor_site_rec.primary_pay_site_flag,'YES/NO',
                                    'PO_LOOKUP_CODES',x_valid);
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                       'AP_SUPPLIER_SITES_INT',
                        p_vendor_site_rec.vendor_site_interface_id,
                       'AP_INVALID_PRIMPAY_SITE_FLAG',
                        g_user_id,
                        g_login_id,
                       'Validate_Vendor_Site') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Primary_Pay_Site_Flag: '
                            ||p_vendor_site_rec.primary_pay_site_flag);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_PRIM_PAY_SITE');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                        -- Bug 8438716 Start
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Call after Validate_Lookups(PRIMARY_PAY_SITE_FLAG...)... Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Primary_Pay_Site_Flag: '
                            ||p_vendor_site_rec.primary_pay_site_flag);
                        END IF;
                        -- Bug 8438716 End
                    END IF;
                  END IF;
   		END IF;

    		------------------------------------------------------------------------
    		l_debug_info := 'Call to Validate freight_terms_lookup_code';
    		------------------------------------------------------------------------
        	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         		FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                		l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate freight_terms_lookup_code
		--
   		IF p_vendor_site_rec.freight_terms_lookup_code is NOT NULL THEN

      			Validate_Lookups( 'FREIGHT_TERMS_LOOKUP_CODE',
				p_vendor_site_rec.freight_terms_lookup_code,'FREIGHT TERMS',
                                    'PO_LOOKUP_CODES',x_valid);
                   IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                       'AP_SUPPLIER_SITES_INT',
                        p_vendor_site_rec.vendor_site_interface_id,
                       'AP_INVALID_FREIGHT_TERMS',
                        g_user_id,
                        g_login_id,
                       'Validate_Vendor_Site') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Freight_Terms_Lookup_Code '
                            ||p_vendor_site_rec.freight_terms_lookup_code);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_FREIGHT_TERMS');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                        -- Bug 8438716 Start
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Freight_Terms_Lookup_Code '
                            ||p_vendor_site_rec.freight_terms_lookup_code);
                        END IF;
                        -- Bug 8438784 End
                    END IF;
                  END IF;
                END IF;

    		------------------------------------------------------------------------
    		l_debug_info := 'Call to Validate fob_lookup_code';
    		------------------------------------------------------------------------
        	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         		FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                		l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate fob_lookup_code
		--
   		IF p_vendor_site_rec.fob_lookup_code is NOT NULL THEN

      			Validate_Lookups( 'FOB_LOOKUP_CODE',p_vendor_site_rec.fob_lookup_code,'FOB',
                                    'PO_LOOKUP_CODES',x_valid);
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                       'AP_SUPPLIER_SITES_INT',
                        p_vendor_site_rec.vendor_site_interface_id,
                       'AP_INVALID_FOB',
                        g_user_id,
                        g_login_id,
                       'Validate_Vendor_Site') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Fob_Lookup_Code '
                            ||p_vendor_site_rec.fob_lookup_code);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_FOB');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                        -- Bug 8438716 Start
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Call after validating FOB_LOOKUP_CODE Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Fob_Lookup_Code '
                            ||p_vendor_site_rec.fob_lookup_code);
                        END IF;
                        -- Bug 8438716 End
                    END IF;
                  END IF;
   		END IF;

    		------------------------------------------------------------------------
    		l_debug_info := 'Call to Validate pay_date_basis_lookup_code';
    		------------------------------------------------------------------------
        	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         		FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                		l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate pay_date_basis_lookup_code
		--
   		IF p_vendor_site_rec.pay_date_basis_lookup_code is NOT NULL THEN

      			Validate_Lookups( 'PAY_DATE_BASIS_LOOKUP_CODE',
				p_vendor_site_rec.pay_date_basis_lookup_code,'PAY DATE BASIS',
                                    'PO_LOOKUP_CODES',x_valid);
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                       'AP_SUPPLIER_SITES_INT',
                        p_vendor_site_rec.vendor_site_interface_id,
                       'AP_INVALID_PAY_DATE_BASIS',
                        g_user_id,
                        g_login_id,
                       'Validate_Vendor_Site') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Pay_Date_Basis_Lookup_Code '
                            ||p_vendor_site_rec.pay_date_basis_lookup_code);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_PAY_DATE_BASIS');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                        -- Bug 8438716 Start
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Call after validating PAY_DATE_BASIS_LOOKUP_CODE... Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Pay_Date_Basis_Lookup_Code '
                            ||p_vendor_site_rec.pay_date_basis_lookup_code);
                        END IF;
                        -- Bug 8438716 End
                    END IF;
                  END IF;
   		END IF;

    		------------------------------------------------------------------------
    		l_debug_info := 'Call to Validate pay_group_lookup_code';
    		------------------------------------------------------------------------
        	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         		FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                		l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate pay_group_lookup_code
		--
   		IF p_vendor_site_rec.pay_group_lookup_code is NOT NULL THEN

      			Validate_Lookups( 'PAY_GROUP_LOOKUP_CODE',
				p_vendor_site_rec.pay_group_lookup_code,'PAY GROUP',
                                    'PO_LOOKUP_CODES',x_valid);
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                       'AP_SUPPLIER_SITES_INT',
                        p_vendor_site_rec.vendor_site_interface_id,
                       'AP_INVALID_PAY_GROUP',
                        g_user_id,
                        g_login_id,
                       'Validate_Vendor_Site') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Pay_Group_Lookup_Code '
                            ||p_vendor_site_rec.pay_group_lookup_code);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_PAY_GROUP');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                        -- Bug 8438716 Start
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Call after validating PAY_GROUP_LOOKUP_CODE... Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Pay_Group_Lookup_Code '
                            ||p_vendor_site_rec.pay_group_lookup_code);
                        END IF;
                        -- Bug 8438716 End
                    END IF;
                  END IF;
   		END IF;

    		------------------------------------------------------------------------
    		l_debug_info := 'Call to Validate terms_date_basis';
    		------------------------------------------------------------------------
        	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         		FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                		l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate terms_date_basis
		--
   		IF p_vendor_site_rec.terms_date_basis is NOT NULL THEN

      			Validate_Lookups( 'TERMS_DATE_BASIS',p_vendor_site_rec.terms_date_basis,'TERMS DATE BASIS',
                                    'AP_LOOKUP_CODES',x_valid);
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                       'AP_SUPPLIER_SITES_INT',
                        p_vendor_site_rec.vendor_site_interface_id,
                       'AP_INVALID_TERMS_DATE',
                        g_user_id,
                        g_login_id,
                       'Validate_Vendor_Site') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Terms_Date_Basis '
                            ||p_vendor_site_rec.terms_date_basis);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_TERMS_DATE');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                        -- Bug 8438716 Start
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Call after validating TERMS_DATE_BASIS... Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Terms_Date_Basis '
                            ||p_vendor_site_rec.terms_date_basis);
                        END IF;
                        -- Bug 8438716 End
                    END IF;
                  END IF;
   		END IF;


		------------------------------------------------------------------------
    		l_debug_info := 'Call to Validate create_debit_memo_flag';
    		------------------------------------------------------------------------
        	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         		FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                		l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate create_debit_memo_flag
		--
   		IF p_vendor_site_rec.create_debit_memo_flag is NOT NULL THEN

      			Validate_Lookups( 'CREATE_DEBIT_MEMO_FLAG',
				p_vendor_site_rec.create_debit_memo_flag ,'YES/NO',
                                    'PO_LOOKUP_CODES',x_valid);
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                       'AP_SUPPLIER_SITES_INT',
                        p_vendor_site_rec.vendor_site_interface_id,
                       'AP_INVALID_DEBIT_MEMO',
                        g_user_id,
                        g_login_id,
                       'Validate_Vendor_Site') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Create_Debit_Memo_Flag '
                            ||p_vendor_site_rec.create_debit_memo_flag);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_DEBIT_MEMO');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                        -- Bug 8438716 Start
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Call after validating CREATE_DEBIT_MEMO_FLAG... Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Create_Debit_Memo_Flag '
                            ||p_vendor_site_rec.create_debit_memo_flag);
                        END IF;
                        -- Bug 8438716 End
                    END IF;
                  END IF;
   		END IF;

		------------------------------------------------------------------------
    		l_debug_info := 'Call to Validate exclude_freight_from_discount';
    		------------------------------------------------------------------------
        	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         		FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                		l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate exclude_freight_from_discount
		--
   		IF p_vendor_site_rec.exclude_freight_from_discount is NOT NULL THEN

      			Validate_Lookups( 'EXCLUDE_FREIGHT_FROM_DISCOUNT',
				p_vendor_site_rec.exclude_freight_from_discount ,'YES/NO',
                                    'PO_LOOKUP_CODES',x_valid);
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                       'AP_SUPPLIER_SITES_INT',
                        p_vendor_site_rec.vendor_site_interface_id,
                       'AP_INVALID_EXC_FR_DISC',
                        g_user_id,
                        g_login_id,
                       'Validate_Vendor_Site') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Exclude_Freight_From_Discount '
                            ||p_vendor_site_rec.exclude_freight_from_discount);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_EXC_FR_DISC');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                        -- Bug 8438716 Start
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Call after validating EXCLUDE_FREIGHT_FROM_DISCOUNT... Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Exclude_Freight_From_Discount '
                            ||p_vendor_site_rec.exclude_freight_from_discount);
                        END IF;
                        -- Bug 8438716 End
                    END IF;
                  END IF;
   		END IF;


    		------------------------------------------------------------------------
    		l_debug_info := 'Call to Validate hold_future_payments_flag';
    		------------------------------------------------------------------------
        	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         		FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                		l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate hold_future_payments_flag
		--
   		IF p_vendor_site_rec.hold_future_payments_flag is NOT NULL THEN

     			Validate_Lookups('HOLD_FUTURE_PAYMENTS_FLAG', p_vendor_site_rec.hold_future_payments_flag,'YES/NO',
                                    'PO_LOOKUP_CODES', x_valid);
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                       'AP_SUPPLIER_SITES_INT',
                        p_vendor_site_rec.vendor_site_interface_id,
                        'AP_INVALID_HOLD_FUT_PAY',
                        g_user_id,
                        g_login_id,
                       'Validate_Vendor_Site') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Hold_Future_Payments_Flag '
                            ||p_vendor_site_rec.hold_future_payments_flag);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_HOLD_FUT_PAY');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                        -- Bug 8438716 Start
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Call after validating HOLD_FUTURE_PAYMENTS_FLAG... Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Hold_Future_Payments_Flag '
                            ||p_vendor_site_rec.hold_future_payments_flag);
                        END IF;
                        -- Bug 8438716 End
                    END IF;
                  END IF;
   		END IF;

    		------------------------------------------------------------------------
    		l_debug_info := 'Call to Validate hold_all_payments_flag';
    		------------------------------------------------------------------------
        	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         		FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                		l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate hold_all_payments_flag
		--
   		IF p_vendor_site_rec.hold_all_payments_flag is NOT NULL THEN

      			Validate_Lookups('HOLD_ALL_PAYMENTS_FLAG', p_vendor_site_rec.hold_all_payments_flag,'YES/NO',
                                    'PO_LOOKUP_CODES', x_valid);
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                       'AP_SUPPLIER_SITES_INT',
                        p_vendor_site_rec.vendor_site_interface_id,
                       'AP_INVALID_HOLD_ALL_PAY',
                        g_user_id,
                        g_login_id,
                       'Validate_Vendor_Site') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Hold_All_Payments_Flag '
                            ||p_vendor_site_rec.hold_all_payments_flag);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_HOLD_ALL_PAY');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                        -- Bug 8438716 Start
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Call after validating HOLD_ALL_PAYMENTS_FLAG... Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Hold_All_Payments_Flag '
                            ||p_vendor_site_rec.hold_all_payments_flag);
                        END IF;
                        -- Bug 8438716 End
                    END IF;
                  END IF;
   		END IF;

    		------------------------------------------------------------------------
    		l_debug_info := 'Call to Validate always_take_disc_flag';
    		------------------------------------------------------------------------
        	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         		FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                		l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate always_take_disc_flag
		--
   		IF p_vendor_site_rec.always_take_disc_flag is NOT NULL THEN

      			Validate_Lookups( 'ALWAYS_TAKE_DISC_FLAG', p_vendor_site_rec.always_take_disc_flag,'YES/NO',
                                    'PO_LOOKUP_CODES', x_valid);
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                       'AP_SUPPLIER_SITES_INT',
                        p_vendor_site_rec.vendor_site_interface_id,
                       'AP_INVALID_TAKE_DISC',
                        g_user_id,
                        g_login_id,
                       'Validate_Vendor_Site') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Always_Take_Disc_Flag '
                            ||p_vendor_site_rec.always_take_disc_flag);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_TAKE_DISC');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                        -- Bug 8438716 Start
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Call after validating ALWAYS_TAKE_DISC_FLAG... Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Always_Take_Disc_Flag '
                            ||p_vendor_site_rec.always_take_disc_flag);
                        END IF;
                        -- Bug 8438716 End
                    END IF;
                  END IF;
   		END IF;

    		------------------------------------------------------------------------
    		l_debug_info := 'Call to Validate match_option';
    		------------------------------------------------------------------------
        	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         		FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                		l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate match_option
		--
   		IF p_vendor_site_rec.match_option is NOT NULL THEN

     			Check_Valid_Match_Option(p_vendor_site_rec.match_option,
                              x_valid
                              );
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                       'AP_SUPPLIER_SITES_INT',
                        p_vendor_site_rec.vendor_site_interface_id,
                       'AP_INVALID_MATCH_OPTION',
                        g_user_id,
                        g_login_id,
                       'Validate_Vendor_Site') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Match_Option '
                            ||p_vendor_site_rec.match_option);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_MATCH_OPTION');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                        -- Bug 8438716 Start
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Call after Check_Valid_Match_Option()... Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Match_Option '
                            ||p_vendor_site_rec.match_option);
                        END IF;
                        -- Bug 8438716 End
                    END IF;
                  END IF;
   		END IF;

    		------------------------------------------------------------------------
    		l_debug_info := 'Call to Validate allow_awt_flag';
    		------------------------------------------------------------------------
        	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         		FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                		l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate allow_awt_flag
		--
   		IF p_vendor_site_rec.allow_awt_flag is NOT NULL THEN

        		Chk_allow_awt_flag(p_vendor_site_rec.allow_awt_flag,
			   p_vendor_site_rec.org_id,
                           x_valid
                           );
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                       'AP_SUPPLIER_SITES_INT',
                        p_vendor_site_rec.vendor_site_interface_id,
                       'AP_INVALID_ALLOW_AWT',
                        g_user_id,
                        g_login_id,
                       'Validate_Vendor_Site') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Allow_Awt_Flag '
                            ||p_vendor_site_rec.allow_awt_flag);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_ALLOW_AWT');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                        -- Bug 8438716 Start
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Call after Chk_allow_awt_flag()... Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Allow_Awt_Flag '
                            ||p_vendor_site_rec.allow_awt_flag);
                        END IF;
                        -- Bug 8438716 End
                    END IF;
                  END IF;
   		END IF;

    		------------------------------------------------------------------------
    		l_debug_info := 'Call to Validate awt_group_id and awt_group_name';
    		------------------------------------------------------------------------
        	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         		FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                		l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate awt_group_id and awt_group_name
		--
		--Bug6317600 Added conditions to resolve the null case for AWT
		--Do not call the AWT validation if AWT_FLAG is not 'Y'
  		IF ((p_vendor_site_rec.awt_group_id is NOT NULL AND
                 p_vendor_site_rec.awt_group_id <> ap_null_num)
		or (p_vendor_site_rec.awt_group_name is NOT NULL AND
                p_vendor_site_rec.awt_group_name <> ap_null_char)) AND
		(p_vendor_site_rec.allow_awt_flag = 'Y')    THEN

        		Chk_awt_grp_id_name(p_vendor_site_rec.awt_group_id,
                            p_vendor_site_rec.awt_group_name,
                            p_vendor_site_rec.allow_awt_flag,
                            x_valid
                            );
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                       'AP_SUPPLIER_SITES_INT',
                        p_vendor_site_rec.vendor_site_interface_id,
                       'AP_INCONSISTENT_AWT_GROUP',
                        g_user_id,
                        g_login_id,
                       'Validate_Vendor_Site') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Allow_Awt_Flag '
                            ||p_vendor_site_rec.allow_awt_flag
                            ||' , Awt_Group_Id: '||p_vendor_site_rec.awt_group_id
                            ||' ,Awt_Group_Name: '||p_vendor_site_rec.awt_group_name);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INCONSISTENT_AWT_GROUP');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                        -- Bug 8438716 Start
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Call after Chk_awt_grp_id_name()... Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Allow_Awt_Flag '
                            ||p_vendor_site_rec.allow_awt_flag
                            ||' , Awt_Group_Id: '||p_vendor_site_rec.awt_group_id
                            ||' ,Awt_Group_Name: '||p_vendor_site_rec.awt_group_name);
                        END IF;
                        -- Bug 8438716 End
                    END IF;
                  END IF;
  		END IF;

                  /*Bug9589179 */
                   ------------------------------------------------------------------------
    		l_debug_info := 'Call to Validate pay_awt_group_id and pay_awt_group_name';
    		------------------------------------------------------------------------
        	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         		FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                		l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate awt_group_id and awt_group_name
		--
		--Bug6317600 Added conditions to resolve the null case for AWT
		--Do not call the AWT validation if AWT_FLAG is not 'Y'

  		IF ((p_vendor_site_rec.pay_awt_group_id is NOT NULL AND
                 p_vendor_site_rec.pay_awt_group_id <> ap_null_num)
		or (p_vendor_site_rec.pay_awt_group_name is NOT NULL AND
                p_vendor_site_rec.pay_awt_group_name <> ap_null_char)) AND
		(p_vendor_site_rec.allow_awt_flag = 'Y')    THEN

        		Chk_pay_awt_grp_id_name(p_vendor_site_rec.pay_awt_group_id,
                            p_vendor_site_rec.pay_awt_group_name,
                            p_vendor_site_rec.allow_awt_flag,
                            x_valid
                            );
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                       'AP_SUPPLIER_SITES_INT',
                        p_vendor_site_rec.vendor_site_interface_id,
                       'AP_INCONSISTENT_AWT_GROUP',
                        g_user_id,
                        g_login_id,
                       'Validate_Vendor_Site') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Allow_Awt_Flag '
                            ||p_vendor_site_rec.allow_awt_flag
                            ||' , Awt_Group_Id: '||p_vendor_site_rec.pay_awt_group_id
                            ||' ,Awt_Group_Name: '||p_vendor_site_rec.pay_awt_group_name);
                        END IF;
                      END IF;
                    ELSE

                        FND_MESSAGE.SET_NAME('SQLAP','AP_INCONSISTENT_AWT_GROUP');
                        FND_MSG_PUB.ADD;

                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Call after Chk_pay_awt_grp_id_name()... Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Allow_Awt_Flag '
                            ||p_vendor_site_rec.allow_awt_flag
                            ||' , Awt_Group_Id: '||p_vendor_site_rec.pay_awt_group_id
                            ||' ,Awt_Group_Name: '||p_vendor_site_rec.pay_awt_group_name);
                        END IF;

                    END IF;
                  END IF;
  		END IF; /*Bug9589179 */

		------------------------------------------------------------------------
    		l_debug_info := 'Call to Validate Distribution_set_Id and Distribution_set_name';
    		------------------------------------------------------------------------
        	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         		FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                		l_api_name,l_debug_info);
    		END IF;

		-- Distribution_set_Id and Distribution_set_name validation

   		IF (p_vendor_site_rec.distribution_set_id is NOT NULL OR p_vendor_site_rec.distribution_set_name is NOT NULL
        		OR p_vendor_site_rec.default_dist_set_id is NOT NULL) THEN

        		Check_dist_set_id_name(p_vendor_site_rec.distribution_set_id,
                               p_vendor_site_rec.distribution_set_name,
                               p_vendor_site_rec.default_dist_set_id,
                               x_valid);
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                       'AP_SUPPLIER_SITES_INT',
                        p_vendor_site_rec.vendor_site_interface_id,
                       'AP_INCONSISTENT_DIST_SET',
                        g_user_id,
                        g_login_id,
                       'Validate_Vendor_Site') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Distribution_Set_Id '
                            ||p_vendor_site_rec.distribution_set_id
                            ||' , Distribution_Set_Name: '
                            ||p_vendor_site_rec.distribution_set_name
                            ||' ,Default_Dist_Set_Id: '
                            ||p_vendor_site_rec.default_dist_set_id);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INCONSISTENT_DIST_SET');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                        -- Bug 8438716 Start
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Call after Check_dist_set_id_name() Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Distribution_Set_Id '
                            ||p_vendor_site_rec.distribution_set_id
                            ||' , Distribution_Set_Name: '
                            ||p_vendor_site_rec.distribution_set_name
                            ||' ,Default_Dist_Set_Id: '
                            ||p_vendor_site_rec.default_dist_set_id);
                        END IF;
                        -- Bug 8438716 End
                    END IF;
                  END IF;
   		END IF;

    		------------------------------------------------------------------------
    		l_debug_info := 'Call to Validate Ship_to_location_Id and Ship_to_location_code`';
    		------------------------------------------------------------------------
        	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         		FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                		l_api_name,l_debug_info);
    		END IF;

		-- Ship_to_location_Id and Ship_to_location_code validation

   		IF (p_vendor_site_rec.ship_to_location_id is NOT NULL OR p_vendor_site_rec.ship_to_location_code is NOT NULL
       			OR p_vendor_site_rec.default_ship_to_loc_id is NOT NULL) THEN

        		Check_ship_locn_id_code(p_vendor_site_rec.ship_to_location_id,
                               p_vendor_site_rec.ship_to_location_code,
                               p_vendor_site_rec.default_ship_to_loc_id,
                               x_valid);
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                       'AP_SUPPLIER_SITES_INT',
                        p_vendor_site_rec.vendor_site_interface_id,
                       'AP_INCONSISTENT_SHIP_LOC',
                        g_user_id,
                        g_login_id,
                       'Validate_Vendor_Site') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Ship_To_Location_Id '
                            ||p_vendor_site_rec.ship_to_location_id
                            ||' , Ship_To_Location_Code '
                            ||p_vendor_site_rec.ship_to_location_code
                            ||' ,Default_ship_to_loc_Id: '
                            ||p_vendor_site_rec.default_ship_to_loc_id);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INCONSISTENT_SHIP_LOC');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                        -- Bug 8438716 Start
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Call after Check_ship_locn_id_code()... Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Ship_To_Location_Id '
                            ||p_vendor_site_rec.ship_to_location_id
                            ||' , Ship_To_Location_Code '
                            ||p_vendor_site_rec.ship_to_location_code
                            ||' ,Default_ship_to_loc_Id: '
                            ||p_vendor_site_rec.default_ship_to_loc_id);
                        END IF;
                        -- Bug 8438716 End
                    END IF;
                  END IF;
   		END IF;

    		------------------------------------------------------------------------
    		l_debug_info := 'Call to Validate Bill_to_location_Id and Bill_to_location_code';
    		------------------------------------------------------------------------
        	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         		FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                		l_api_name,l_debug_info);
    		END IF;

		-- Bill_to_location_Id and Bill_to_location_code validation

   		IF (p_vendor_site_rec.bill_to_location_id is NOT NULL OR p_vendor_site_rec.bill_to_location_code is NOT NULL
       			OR p_vendor_site_rec.default_bill_to_loc_id is NOT NULL) THEN

        		Check_bill_locn_id_code(p_vendor_site_rec.bill_to_location_id,
                               p_vendor_site_rec.bill_to_location_code,
                               p_vendor_site_rec.default_bill_to_loc_id,
                               x_valid);
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                       'AP_SUPPLIER_SITES_INT',
                        p_vendor_site_rec.vendor_site_interface_id,
                       'AP_INCONSISTENT_BILL_LOC',
                        g_user_id,
                        g_login_id,
                       'Validate_Vendor_Site') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Bill_To_Location_Id '
                            ||p_vendor_site_rec.bill_to_location_id
                            ||' , Bill_To_Location_Code '
                            ||p_vendor_site_rec.bill_to_location_code
                            ||' ,Default_bill_to_loc_Id: '
                            ||p_vendor_site_rec.default_bill_to_loc_id);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INCONSISTENT_BILL_LOC');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                        -- Bug 8438716 Start
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Call after Check_bill_locn_id_code()... Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Bill_To_Location_Id '
                            ||p_vendor_site_rec.bill_to_location_id
                            ||' , Bill_To_Location_Code '
                            ||p_vendor_site_rec.bill_to_location_code
                            ||' ,Default_bill_to_loc_Id: '
                            ||p_vendor_site_rec.default_bill_to_loc_id);
                        END IF;
                        -- Bug 8438716 End
                    END IF;
                  END IF;
   		END IF;

		------------------------------------------------------------------------
    		l_debug_info := 'Call to Validate supplier_notification_method';
    		------------------------------------------------------------------------
        	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         		FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                		l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate supplier_notification_method
		--
   		IF p_vendor_site_rec.supplier_notif_method is NOT NULL THEN

   			 Check_Valid_Sup_Notif_Method(p_vendor_site_rec.supplier_notif_method,
                                 x_valid
                                 );
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                       'AP_SUPPLIER_SITES_INT',
                        p_vendor_site_rec.vendor_site_interface_id,
                        'AP_INVALID_NOTIF_METHOD',
                        g_user_id,
                        g_login_id,
                       'Validate_Vendor_Site') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Supplier_Notif_Method: '
                            ||p_vendor_site_rec.supplier_notif_method);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_NOTIF_METHOD');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                        -- Bug 8438716 Start
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Call after Check_Valid_Sup_Notif_Method()... Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Supplier_Notif_Method: '
                            ||p_vendor_site_rec.supplier_notif_method);
                        END IF;
                        -- Bug 8438716 End
                    END IF;
                  END IF;
   		END IF;

		-- Bug 8422781 ...
		------------------------------------------------------------------------
    		l_debug_info := 'Call to Validate remit_advice_delivery_method';
    		------------------------------------------------------------------------
        	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         		FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                		l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate remit_advice_delivery_method
		--
   		IF p_vendor_site_rec.remit_advice_delivery_method is NOT NULL THEN

   			 Check_Valid_Remit_Adv_Del_Mthd(p_vendor_site_rec.remit_advice_delivery_method,
                                 x_valid
                                 );
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                       'AP_SUPPLIER_SITES_INT',
                        p_vendor_site_rec.vendor_site_interface_id,
                        'AP_REMIT_ADVICE_FLAG_INVALID',
                        g_user_id,
                        g_login_id,
                       'Validate_Vendor_Site') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Remit_Advice_Delivery_Method: '
                            ||p_vendor_site_rec.remit_advice_delivery_method);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_REMIT_ADVICE_FLAG_INVALID');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                        -- Bug 8438716 Start
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Call after Check_Valid_Remit_Adv_Del_Mthd()... Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Supplier_Notif_Method: '
                            ||p_vendor_site_rec.supplier_notif_method);
                        END IF;
                        -- Bug 8438716 End
                    END IF;
                  END IF;
   		END IF;
		-- end Bug 8422781

    		------------------------------------------------------------------------
    		l_debug_info := 'Checking Tolerance_Id / Name information';
   		------------------------------------------------------------------------
        	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         		FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                		l_api_name,l_debug_info);
    		END IF;
                --bug6335105
		/*IF (p_vendor_site_rec.tolerance_name is NOT NULL
       			OR p_vendor_site_rec.tolerance_id is NOT NULL) THEN*/

                        l_tolerance_type := 'QUANTITY';

      			Check_tolerance_id_code(p_vendor_site_rec.tolerance_id,
                              p_vendor_site_rec.tolerance_name,
                              p_vendor_site_rec.org_id,
                              p_vendor_site_rec.org_name,
                              x_valid,
                              l_tolerance_type
                              );
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                       'AP_SUPPLIER_SITES_INT',
                        p_vendor_site_rec.vendor_site_interface_id,
                       'AP_INCONSISTENT_TOLERANCE',
                        g_user_id,
                        g_login_id,
                       'Validate_Vendor_Site') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Toleranace_Id: '
                            ||p_vendor_site_rec.tolerance_id
                            ||' ,Tolerance_Name: '||p_vendor_site_rec.tolerance_name);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INCONSISTENT_TOLERANCE');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                        -- Bug 8438716 Start
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Call after Check_tolerance_id_code()... Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Toleranace_Id: '
                            ||p_vendor_site_rec.tolerance_id
                            ||' ,Tolerance_Name: '||p_vendor_site_rec.tolerance_name);
                        END IF;
                        -- Bug 8438716 End
                    END IF;
                  END IF;
	        --END IF;

                ------------------------------------------------------------------------
                l_debug_info := 'Checking Services Tolerance_Id / Name information';
                ------------------------------------------------------------------------
                IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                                l_api_name,l_debug_info);
                END IF;
                --bug6335105
                /*IF (p_vendor_site_rec.services_tolerance_name is NOT NULL
                        OR p_vendor_site_rec.services_tolerance_id is NOT NULL) THEN*/

                        l_tolerance_type := 'SERVICE';

                        Check_tolerance_id_code(p_vendor_site_rec.services_tolerance_id,
                              p_vendor_site_rec.services_tolerance_name,
                              p_vendor_site_rec.org_id,
                              p_vendor_site_rec.org_name,
                              x_valid,
                              l_tolerance_type
                              );
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                       'AP_SUPPLIER_SITES_INT',
                        p_vendor_site_rec.vendor_site_interface_id,
                       'AP_INCONSISTENT_SERVICE_TOL',
                        g_user_id,
                        g_login_id,
                       'Validate_Vendor_Site') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Toleranace_Id: '
                            ||p_vendor_site_rec.services_tolerance_id
                            ||' ,Tolerance_Name: '||p_vendor_site_rec.services_tolerance_name);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INCONSIS_SERVICE_TOL');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                        -- Bug 8438716 Start
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Call after Check_tolerance_id_code()... Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Toleranace_Id: '
                            ||p_vendor_site_rec.services_tolerance_id
                            ||' ,Tolerance_Name: '||p_vendor_site_rec.services_tolerance_name);
                        END IF;
                        -- Bug 8438716 End
                    END IF;
                  END IF;
                --END IF;


                ------------------------------------------------------------------------
                l_debug_info := 'Call to Validate retainage_rate';
                ------------------------------------------------------------------------
                IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                                l_api_name,l_debug_info);
                END IF;

                IF p_vendor_site_rec.retainage_rate is NOT NULL THEN

                   IF NOT (p_vendor_site_rec.retainage_rate <  0    OR
			   p_vendor_site_rec.retainage_rate >  100) THEN

                      x_return_status := FND_API.G_RET_STS_ERROR;
                      IF g_source = 'IMPORT' THEN
                         IF (Insert_Rejections(
                                'AP_SUPPLIER_SITES_INT',
                                p_vendor_site_rec.vendor_site_interface_id,
                                'AP_INVALID_RETAINAGE_RATE',
                                g_user_id,
                                g_login_id,
                                'Validate_Vendor_Site') <> TRUE) THEN
                            --
                            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                               FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                                                    l_api_name,'Parameters: '
                                                ||' Vendor_Site_Interface_Id: '
                                                ||p_vendor_site_rec.vendor_site_interface_id
                                                ||' ,Retainage_Rate '
                                                ||p_vendor_site_rec.retainage_rate);
                            END IF;
                         END IF;
                        ELSE
                            -- Bug 5491139 hkaniven start --
                            FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_RETAINAGE_RATE');
                            FND_MSG_PUB.ADD;
                            -- Bug 5491139 hkaniven end --
                            -- Bug 8438716 Start
                            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                               FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                                                    l_api_name,'Call after validating p_vendor_site_rec.retainage_rate... Parameters: '
                                                ||' Vendor_Site_Interface_Id: '
                                                ||p_vendor_site_rec.vendor_site_interface_id
                                                ||' ,Retainage_Rate '
                                                ||p_vendor_site_rec.retainage_rate);
                            END IF;
                            -- Bug 8438716 End
                      END IF;
                   END IF;
                END IF;

    		------------------------------------------------------------------------
    		l_debug_info := 'Call to Validate ship_via_lookup_code';
    		------------------------------------------------------------------------
        	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         		FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                		l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate ship_via_lookup_code
		--
   		IF p_vendor_site_rec.ship_via_lookup_code is NOT NULL THEN

            		Check_Site_Ship_Via(p_vendor_site_rec.ship_via_lookup_code,
                                p_vendor_site_rec.org_id,
                                x_valid
                              );
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                       'AP_SUPPLIER_SITES_INT',
                        p_vendor_site_rec.vendor_site_interface_id,
                       'AP_INVALID_SHIP_VIA',
                        g_user_id,
                        g_login_id,
                       'Validate_Vendor_Site') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Ship_Via_Lookup_Code: '
                            ||p_vendor_site_rec.ship_via_lookup_code);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_SHIP_VIA');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                        -- Bug 8438716 Start
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Call after Check_Site_Ship_Via()... Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' ,Ship_Via_Lookup_Code: '
                            ||p_vendor_site_rec.ship_via_lookup_code);
                        END IF;
                        -- Bug 8438716 End
                    END IF;
                  END IF;
   		END IF;

    		------------------------------------------------------------------------
    		l_debug_info := 'Call to Validate tax_reporting_site_flag';
    		------------------------------------------------------------------------
        	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         		FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                		l_api_name,l_debug_info);
    		END IF;
		--
		-- Validate tax_reporting_site_flag
		--
   		IF p_vendor_site_rec.tax_reporting_site_flag = 'Y' THEN

			Validate_unique_per_vendor('TAX_REPORTING_SITE_FLAG',
                        p_vendor_site_rec.vendor_id,
                        p_vendor_site_rec.vendor_site_id,
  			p_vendor_site_rec.org_id,
                        p_vendor_site_rec.org_name,
                        x_valid
                        );
                  IF NOT x_valid THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    IF g_source = 'IMPORT' THEN
                      IF (Insert_Rejections(
                       'AP_SUPPLIER_SITES_INT',
                        p_vendor_site_rec.vendor_site_interface_id,
                       'AP_DUPLICATE_TAX_RS',
                        g_user_id,
                        g_login_id,
                       'Validate_Vendor_Site') <> TRUE) THEN
                       --
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' Vendor_Id: '||p_vendor_site_rec.vendor_id
                            ||' Vendor_Site_Id: '||p_vendor_site_rec.vendor_site_id
                            ||' Org_Id: '||p_vendor_site_rec.org_id
                            ||' Org_Name: '||p_vendor_site_rec.org_name
                            ||' ,Tax_Reporting_Site_Flag: '
                            ||p_vendor_site_rec.tax_reporting_site_flag);
                        END IF;
                      END IF;
                    ELSE
                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_DUPLICATE_TAX_RS');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                        -- Bug 8438716 Start
                        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                            l_api_name,'Call after validating p_vendor_site_rec.tax_reporting_site_flag... Parameters: '
                            ||' Vendor_Site_Interface_Id: '
                            ||p_vendor_site_rec.vendor_site_interface_id
                            ||' Vendor_Id: '||p_vendor_site_rec.vendor_id
                            ||' Vendor_Site_Id: '||p_vendor_site_rec.vendor_site_id
                            ||' Org_Id: '||p_vendor_site_rec.org_id
                            ||' Org_Name: '||p_vendor_site_rec.org_name
                            ||' ,Tax_Reporting_Site_Flag: '
                            ||p_vendor_site_rec.tax_reporting_site_flag);
                        END IF;
                        -- Bug 8438716 End
                    END IF;
                  END IF;
   		END IF;

                IF p_vendor_site_rec.gapless_inv_num_flag is NOT NULL
                   AND p_vendor_site_rec.gapless_inv_num_flag  <>
                       ap_null_char THEN

                   Check_Gapless_Inv_Num
                          (p_vendor_site_rec.gapless_inv_num_flag,
                           p_vendor_site_rec.selling_company_identifier,
			   p_vendor_site_rec.vendor_id,--Bug5260465
                           x_valid);

                   IF NOT x_valid THEN
                      x_return_status := FND_API.G_RET_STS_ERROR;
                      IF g_source = 'IMPORT' THEN
                         IF (Insert_Rejections(
                                     'AP_SUPPLIER_SITES_INT',
                                     p_vendor_site_rec.vendor_site_interface_id,
                                     'AP_INVALID_SHIPPING_CONTROL',
                                     g_user_id,
                                     g_login_id,
                                     'Validate_Vendor_Site') <> TRUE) THEN
                          --
                            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL)
                            THEN
                               FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                                              l_api_name,'Parameters: '
                                              ||' Vendor_Site_Interface_Id: '
                                              ||p_vendor_site_rec.vendor_site_interface_id
                                              ||' Gapless Invoice Num Flag: '
                                              ||p_vendor_site_rec.gapless_inv_num_flag
                                              ||' Selling Company Identifier: '
                                              ||p_vendor_site_rec.selling_company_identifier);
                            END IF;
                         END IF;
                        ELSE
                            -- Bug 5491139 hkaniven start --
                            FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_SHIPPING_CONTROL');
                            FND_MSG_PUB.ADD;
                            -- Bug 5491139 hkaniven end --
                            -- Bug 8438716 Start
                            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL)
                            THEN
                               FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                                              l_api_name,'Call after Check_Gapless_Inv_Num()... Parameters: '
                                              ||' Vendor_Site_Interface_Id: '
                                              ||p_vendor_site_rec.vendor_site_interface_id
                                              ||' Gapless Invoice Num Flag: '
                                              ||p_vendor_site_rec.gapless_inv_num_flag
                                              ||' Selling Company Identifier: '
                                              ||p_vendor_site_rec.selling_company_identifier);
                            END IF;
                            -- Bug 8438716 End
                      END IF;
                   END IF;
                END IF;


	END IF; -- not ISETUP
    END IF; --p_mode

    -- End of API body.

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
	COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1,
    -- get message info.
    FND_MSG_PUB.Count_And_Get(
	p_count         	=>      x_msg_count     	,
        p_data          	=>      x_msg_data
    	);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Validate_Vendor_Site_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Validate_Vendor_Site_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);
	WHEN OTHERS THEN
		ROLLBACK TO Validate_Vendor_Site_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);
END Validate_Vendor_Site;

PROCEDURE Create_Vendor_Contact
( 	p_api_version           IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	IN  	NUMBER	:=
						FND_API.G_VALID_LEVEL_FULL,
	x_return_status		OUT	NOCOPY VARCHAR2		  	,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_vendor_contact_rec	IN	r_vendor_contact_rec_type,
	x_vendor_contact_id	OUT	NOCOPY NUMBER,
	x_per_party_id		OUT	NOCOPY NUMBER,
	x_rel_party_id		OUT 	NOCOPY NUMBER,
	x_rel_id		OUT	NOCOPY NUMBER,
	x_org_contact_id	OUT	NOCOPY NUMBER,
	x_party_site_id		OUT	NOCOPY NUMBER
)
IS


    l_api_name			CONSTANT VARCHAR2(30)	:= 'Create_Vendor_Contact';
    l_api_version           	CONSTANT NUMBER 		:= 1.0;

    l_def_org_id		NUMBER;
    l_vendor_contact_rec	r_vendor_contact_rec_type;
    l_party_rec			HZ_PARTY_V2PUB.party_rec_type;
    l_per_rec			HZ_PARTY_V2PUB.person_rec_type;
    l_rel_rec			HZ_RELATIONSHIP_V2PUB.relationship_rec_type;
    l_org_contact_rec		HZ_PARTY_CONTACT_V2PUB.org_contact_rec_type;
    l_party_site_rec		HZ_PARTY_SITE_V2PUB.party_site_rec_type;
    l_contact_point_rec		HZ_CONTACT_POINT_V2PUB.contact_point_rec_type;
    l_email_rec			HZ_CONTACT_POINT_V2PUB.email_rec_type;
    l_phone_rec			HZ_CONTACT_POINT_V2PUB.phone_rec_type;
    l_alt_phone_rec		HZ_CONTACT_POINT_V2PUB.phone_rec_type;
    l_fax_rec			HZ_CONTACT_POINT_V2PUB.phone_rec_type;
    l_url_rec			HZ_CONTACT_POINT_V2PUB.web_rec_type;
    l_party_usg_rec   HZ_PARTY_USG_ASSIGNMENT_PVT.party_usg_assignment_rec_type;

    l_user_id                number := FND_GLOBAL.USER_ID;
    l_last_update_login      number := FND_GLOBAL.LOGIN_ID;
    l_program_application_id number := FND_GLOBAL.prog_appl_id;
    l_program_id             number := FND_GLOBAL.conc_program_id;
    l_request_id             number := FND_GLOBAL.conc_request_id;

    l_val_return_status VARCHAR2(50);
    l_val_msg_count		NUMBER;
    l_val_msg_data		VARCHAR2(1000);
    l_party_site_valid 	VARCHAR2(1);
    l_rel_party_valid	VARCHAR2(1);
    l_per_party_valid	VARCHAR2(1);
    l_rel_valid		VARCHAR2(1);
    l_org_party_valid	VARCHAR2(1);
    l_location_valid	VARCHAR2(1);
    l_org_contact_valid VARCHAR2(1);
    l_per_return_status	VARCHAR2(50);
    l_per_msg_count		NUMBER;
    l_per_msg_data		VARCHAR2(1000);
    l_per_party_id		NUMBER;
    l_per_party_number	VARCHAR2(30);
    l_per_profile_id	NUMBER;
    l_org_contact_return_status	VARCHAR2(50);
    l_org_contact_msg_count	NUMBER;
    l_org_contact_msg_data	VARCHAR2(1000);
    l_org_contact_id	NUMBER;
    l_rel_party_id		NUMBER;
    l_rel_party_number	VARCHAR2(30);
    l_site_return_status	VARCHAR2(50);
    l_site_msg_count	NUMBER;
    l_site_msg_data		VARCHAR2(1000);
    l_party_site_id		NUMBER;
    l_phone_return_status	VARCHAR2(50);
    l_phone_msg_count	NUMBER;
    l_phone_msg_data	VARCHAR2(1000);
    l_phone_contact_point_id	NUMBER;
    l_alt_phone_return_status	VARCHAR2(50);
    l_alt_phone_msg_count	NUMBER;
    l_alt_phone_msg_data	VARCHAR2(1000);
    l_alt_phone_contact_point_id	NUMBER;
    l_fax_return_status	VARCHAR2(50);
    l_fax_msg_count		NUMBER;
    l_fax_msg_data		VARCHAR2(1000);
    l_fax_contact_point_id	NUMBER;
    l_email_return_status	VARCHAR2(50);
    l_email_msg_count	NUMBER;
    l_email_msg_data	VARCHAR2(1000);
    l_email_contact_point_id	NUMBER;
    l_url_return_status	VARCHAR2(50);
    l_url_msg_count		NUMBER;
    l_url_msg_data		VARCHAR2(1000);
    l_url_contact_point_id	NUMBER;

    l_org_party_id		NUMBER;
    l_location_id		NUMBER;
    l_rel_id			NUMBER;
    l_party_id			NUMBER;
    l_party_number		VARCHAR2(30);
    l_party_site_number		VARCHAR2(30);
    l_party_num			VARCHAR2(1);
    l_debug_info    VARCHAR2(500); -- Bug 6823885
    l_party_site_num			VARCHAR2(1); -- Bug 6823885

BEGIN
	-- Standard Start of API savepoint
    SAVEPOINT	Create_Vendor_Contact_PUB;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
    THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- API body

    --default return stati
    l_val_return_status := FND_API.G_RET_STS_SUCCESS;
    l_per_return_status := FND_API.G_RET_STS_SUCCESS;
    l_org_contact_return_status := FND_API.G_RET_STS_SUCCESS;
    l_site_return_status := FND_API.G_RET_STS_SUCCESS;
    l_phone_return_status := FND_API.G_RET_STS_SUCCESS;
    l_alt_phone_return_status  := FND_API.G_RET_STS_SUCCESS;
    l_fax_return_status  := FND_API.G_RET_STS_SUCCESS;
    l_email_return_status := FND_API.G_RET_STS_SUCCESS;
    l_url_return_status := FND_API.G_RET_STS_SUCCESS;

    l_vendor_contact_rec := p_vendor_contact_rec;

    validate_vendor_contact(p_api_version => 1.0,
		p_init_msg_list => FND_API.G_FALSE,
		p_commit  => FND_API.G_FALSE,
		p_validation_level => FND_API.G_VALID_LEVEL_FULL,
		x_return_status => l_val_return_status,
		x_msg_count => l_val_msg_count,
		x_msg_data => l_val_msg_data,
		p_vendor_contact_rec => l_vendor_contact_rec,
		x_party_site_valid => l_party_site_valid ,
		x_rel_party_valid => l_rel_party_valid,
		x_per_party_valid => l_per_party_valid,
		x_rel_valid => l_rel_valid,
		x_org_contact_valid => l_org_contact_valid,
		x_org_party_id	=> l_org_party_id,
		x_location_id => l_location_id);

    IF  l_per_party_valid = 'N'  THEN
	 -- create new party record

	l_per_rec.person_first_name := l_vendor_contact_rec.person_first_name;
	l_per_rec.person_middle_name := l_vendor_contact_rec.person_middle_name;
	l_per_rec.person_last_name := l_vendor_contact_rec.person_last_name;
	l_per_rec.person_title := l_vendor_contact_rec.person_title;
	l_per_rec.person_first_name_phonetic := l_vendor_contact_rec.person_first_name_phonetic;
	l_per_rec.person_last_name_phonetic := l_vendor_contact_rec.person_last_name_phonetic;
	l_per_rec.created_by_module := 'AP_SUPPLIERS_API';
	l_per_rec.application_id := 200;

	-- bug 6745669 - added attribute_category
	l_per_rec.attribute_category := l_vendor_contact_rec.attribute_category;

	l_per_rec.attribute1 := l_vendor_contact_rec.attribute1;
	l_per_rec.attribute2 := l_vendor_contact_rec.attribute2;
	l_per_rec.attribute3 := l_vendor_contact_rec.attribute3;
	l_per_rec.attribute4 := l_vendor_contact_rec.attribute4;
	l_per_rec.attribute5 := l_vendor_contact_rec.attribute5;
	l_per_rec.attribute6 := l_vendor_contact_rec.attribute6;
	l_per_rec.attribute7 := l_vendor_contact_rec.attribute7;
	l_per_rec.attribute8 := l_vendor_contact_rec.attribute8;
	l_per_rec.attribute9 := l_vendor_contact_rec.attribute9;
	l_per_rec.attribute10 := l_vendor_contact_rec.attribute10;
	l_per_rec.attribute11 := l_vendor_contact_rec.attribute11;
	l_per_rec.attribute12 := l_vendor_contact_rec.attribute12;
	l_per_rec.attribute13 := l_vendor_contact_rec.attribute13;
	l_per_rec.attribute14 := l_vendor_contact_rec.attribute14;
	l_per_rec.attribute15 := l_vendor_contact_rec.attribute15;

        l_per_rec.person_pre_name_adjunct := l_vendor_contact_rec.prefix;
        l_per_rec.person_name_phonetic    := l_vendor_contact_rec.contact_name_phonetic;

	fnd_profile.get('HZ_GENERATE_PARTY_NUMBER', l_party_num);
        IF nvl(l_party_num, 'Y') = 'N' THEN
                SELECT HZ_PARTY_NUMBER_S.Nextval
                INTO l_party_rec.party_number
                FROM DUAL;
        END IF;

        l_per_rec.party_rec := l_party_rec;

	hz_party_v2pub.create_person(
		p_init_msg_list => FND_API.G_FALSE,
		p_person_rec => l_per_rec,
		p_party_usage_code => 'SUPPLIER_CONTACT',
        	--p_commit => FND_API.G_FALSE,
		x_return_status => l_per_return_status,
		x_msg_count => l_per_msg_count,
		x_msg_data => l_per_msg_data,
		x_party_id => l_per_party_id,
		x_party_number => l_per_party_number,
		x_profile_id => l_per_profile_id);
		IF l_per_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      ------------------------------------------------------------------------
      l_debug_info := 'After call to hz_party_v2pub.create_person';
      l_debug_info := l_debug_info||' Return status : '||l_per_return_status||' Error : '||l_per_msg_data;
      ------------------------------------------------------------------------
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;
	-- Bug 6886893: Start
	IF g_source = 'IMPORT' THEN

               IF ( NVL(l_per_msg_count, 0) > 1 ) THEN
		      FOR i IN 1..l_per_msg_count
		      LOOP
		          -- built the complete message with new line separator if
		          -- called API returns message count > 1
		          x_msg_data := x_msg_data||FND_MSG_PUB.Get(p_msg_index => i, p_encoded => 'T') ||' ';
		          --delete the message stack for the index
		          --already fetched
		          FND_MSG_PUB.DELETE_MSG(p_msg_index => i);
		      END LOOP;
		ELSIF (l_per_msg_data is not null) THEN
		      x_msg_data := x_msg_data||l_per_msg_data;
		END IF;

            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,x_msg_data);
            END IF;

            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,x_msg_data);
            END IF;

	    IF (Insert_Rejections(
				  p_parent_table => 'AP_SUP_SITE_CONTACT_INT',
				  p_parent_id => p_vendor_contact_rec.vendor_contact_interface_id,
				  p_reject_code => 'AP_INVALID_TCA_ERROR',
				  p_last_updated_by => g_user_id,
				  p_last_update_login => g_login_id,
				  p_calling_sequence => 'hz_party_v2pub.create_person'
				 ) <> TRUE) THEN

			     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
				    FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
				    l_api_name,'Error logging into Rejections table');
			     END IF;
    END IF;
	ELSE
	   fnd_message.set_name('SQLAP', 'AP_INVALID_TCA_ERROR');
	   fnd_msg_pub.add;
	END IF;
	-- Bug 6886893: End

        END IF;

		l_vendor_contact_rec.per_party_id := l_per_party_id;

    END IF; --party did not exist

    IF l_rel_party_valid = 'N' AND
	l_per_party_valid <> 'F' AND
	l_rel_valid = 'N' AND
	l_org_contact_valid = 'N' THEN -- create new org contact

	/*checking proper approach
	l_party_usg_rec.party_id := l_per_party_id;
	l_party_usg_rec.party_usage_code := 'ORG_CONTACT';
	l_party_usg_rec.created_by_module := 'AP_SUPPLIERS_API';

	HZ_PARTY_USG_ASSIGNMENT_PVT.assign_party_usage(
		p_init_msg_list => FND_API.G_FALSE,
		p_party_usg_assignment_rec  => l_party_usg_rec,
		x_return_status => l_per_return_status,
                x_msg_count => l_per_msg_count,
                x_msg_data => l_per_msg_data);
	*/

	--populate relationship record

	l_rel_rec.end_date := l_vendor_contact_rec.inactive_date;
	l_rel_rec.subject_id := l_per_party_id;
	l_rel_rec.subject_type := 'PERSON';
	l_rel_rec.subject_table_name := 'HZ_PARTIES';
	l_rel_rec.object_id := l_org_party_id;
	l_rel_rec.object_type := 'ORGANIZATION';
	l_rel_rec.object_table_name := 'HZ_PARTIES';
	l_rel_rec.relationship_code := 'CONTACT_OF';
	l_rel_rec.relationship_type := 'CONTACT';
	l_rel_rec.start_date := sysdate;
	l_rel_rec.created_by_module := 'AP_SUPPLIERS_API';
	l_rel_rec.application_id := 200;

        fnd_profile.get('HZ_GENERATE_PARTY_NUMBER', l_party_num);
        IF nvl(l_party_num, 'Y') = 'N' THEN
                SELECT HZ_PARTY_NUMBER_S.Nextval
                INTO l_party_rec.party_number
                FROM DUAL;
        END IF;

	l_rel_rec.party_rec := l_party_rec;

	--populate org contact record
	l_org_contact_rec.department := l_vendor_contact_rec.department;
	-- job title [Bug 6648967]
	l_org_contact_rec.job_title := l_vendor_contact_rec.person_title;
	--contact_number
	l_org_contact_rec.created_by_module := 'AP_SUPPLIERS_API';
	l_org_contact_rec.application_id := 200;
	l_org_contact_rec.party_rel_rec := l_rel_rec;

	hz_party_contact_v2pub.create_org_contact(
		p_init_msg_list => FND_API.G_FALSE,
		p_org_contact_rec => l_org_contact_rec,
		--p_commit => FND_API.G_FALSE,
		x_return_status => l_org_contact_return_status,
		x_msg_count => l_org_contact_msg_count,
		x_msg_data => l_org_contact_msg_data,
		x_org_contact_id => l_org_contact_id,
		x_party_rel_id => l_rel_id,
		x_party_id => l_rel_party_id,
		x_party_number => l_rel_party_number);
	IF l_org_contact_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    ------------------------------------------------------------------------
    l_debug_info := 'After call to hz_party_contact_v2pub.create_org_contact';
    l_debug_info := l_debug_info||' Return status : '||l_org_contact_return_status||' Error : '||l_org_contact_msg_data;
    ------------------------------------------------------------------------
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
	-- Bug 6886893: Start
	IF g_source = 'IMPORT' THEN

               IF ( NVL(l_per_msg_count, 0) > 1 ) THEN
		      FOR i IN 1..l_per_msg_count
		      LOOP
		          -- built the complete message with new line separator if
		          -- called API returns message count > 1
		          x_msg_data := x_msg_data||FND_MSG_PUB.Get(p_msg_index => i, p_encoded => 'T') ||' ';
		          --delete the message stack for the index
		          --already fetched
		          FND_MSG_PUB.DELETE_MSG(p_msg_index => i);
		      END LOOP;
		ELSIF (l_per_msg_data is not null) THEN
		      x_msg_data := x_msg_data||l_per_msg_data;
		END IF;

            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,x_msg_data);
            END IF;

            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,x_msg_data);
            END IF;

	    IF (Insert_Rejections(
				  p_parent_table => 'AP_SUP_SITE_CONTACT_INT',
				  p_parent_id => p_vendor_contact_rec.vendor_contact_interface_id,
				  p_reject_code => 'AP_INVALID_TCA_ERROR',
				  p_last_updated_by => g_user_id,
				  p_last_update_login => g_login_id,
				  p_calling_sequence => 'hz_party_v2pub.create_person'
				 ) <> TRUE) THEN

			     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
				    FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
				    l_api_name,'Error logging into Rejections table');
			     END IF;
	    END IF;
	ELSE
	   fnd_message.set_name('SQLAP', 'AP_INVALID_TCA_ERROR');
	   fnd_msg_pub.add;
	END IF;
	-- Bug 6886893: End

  END IF;

	l_vendor_contact_rec.relationship_id := l_rel_id;
	l_vendor_contact_rec.rel_party_id := l_rel_party_id;
	l_vendor_contact_rec.org_contact_id := l_org_contact_id;

    END IF; -- org contact null

    IF l_rel_party_valid <> 'F' AND
	l_per_party_valid <> 'F' AND
	l_rel_valid <> 'F' AND
	l_org_contact_valid <> 'F' AND
	l_party_site_valid = 'N' THEN -- create new party site

	--populate party site record
	l_party_site_rec.mailstop := l_vendor_contact_rec.mail_stop;
	l_party_site_rec.location_id := l_location_id;
	l_party_site_rec.created_by_module := 'AP_SUPPLIERS_API';
	l_party_site_rec.application_id := 200;
	l_party_site_rec.party_id :=  l_vendor_contact_rec.rel_party_id;
	-- udhenuko Bug 6823885 start. Party site number populated based on profile.
  fnd_profile.get('HZ_GENERATE_PARTY_SITE_NUMBER', l_party_site_num);
	IF nvl(l_party_site_num, 'Y') = 'N' THEN
		SELECT HZ_PARTY_SITE_NUMBER_S.Nextval
		INTO l_party_site_rec.party_site_number
		FROM DUAL;
	END IF;
	-- udhenuko Bug 6823885 End

	hz_party_site_v2pub.create_party_site(
		p_init_msg_list => FND_API.G_FALSE,
		p_party_site_rec => l_party_site_rec,
		--p_commit => FND_API.G_FALSE,
		x_return_status => l_site_return_status,
		x_msg_count => l_site_msg_count,
		x_msg_data => l_site_msg_data,
		x_party_site_id => l_party_site_id,
		x_party_site_number => l_party_site_number);
	IF l_site_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    ------------------------------------------------------------------------
    l_debug_info := 'After call to hz_party_site_v2pub.create_party_site';
    l_debug_info := l_debug_info||' Return status : '||l_site_return_status||' Error : '||l_site_msg_data;
    ------------------------------------------------------------------------
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

	-- Bug 6886893: Start
	IF g_source = 'IMPORT' THEN

               IF ( NVL(l_per_msg_count, 0) > 1 ) THEN
		      FOR i IN 1..l_per_msg_count
		      LOOP
		          -- built the complete message with new line separator if
		          -- called API returns message count > 1
		          x_msg_data := x_msg_data||FND_MSG_PUB.Get(p_msg_index => i, p_encoded => 'T') ||' ';
		          --delete the message stack for the index
		          --already fetched
		          FND_MSG_PUB.DELETE_MSG(p_msg_index => i);
		      END LOOP;
		ELSIF (l_per_msg_data is not null) THEN
		      x_msg_data := x_msg_data||l_per_msg_data;
		END IF;

            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,x_msg_data);
            END IF;

            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,x_msg_data);
            END IF;

	    IF (Insert_Rejections(
				  p_parent_table => 'AP_SUP_SITE_CONTACT_INT',
				  p_parent_id => p_vendor_contact_rec.vendor_contact_interface_id,
				  p_reject_code => 'AP_INVALID_TCA_ERROR',
				  p_last_updated_by => g_user_id,
				  p_last_update_login => g_login_id,
				  p_calling_sequence => 'hz_party_v2pub.create_person'
				 ) <> TRUE) THEN

			     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
				    FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
				    l_api_name,'Error logging into Rejections table');
			     END IF;
	    END IF;
	ELSE
	   fnd_message.set_name('SQLAP', 'AP_INVALID_TCA_ERROR');
	   fnd_msg_pub.add;
	END IF;
	-- Bug 6886893: End

  END IF;

	l_vendor_contact_rec.party_site_id := l_party_site_id;

    END IF; -- party site null

    IF l_rel_party_valid <> 'F' AND
	l_per_party_valid <> 'F' AND
	l_rel_valid <> 'F' AND
	l_org_contact_valid <> 'F' AND
	l_party_site_valid <> 'F' THEN -- create contact points

	--populate contact point record
	l_contact_point_rec.owner_table_name := 'HZ_PARTIES';
	l_contact_point_rec.owner_table_id := l_vendor_contact_rec.rel_party_id;
	l_contact_point_rec.created_by_module := 'AP_SUPPLIERS_API';
	l_contact_point_rec.application_id := 200;

	IF l_vendor_contact_rec.phone IS NOT NULL THEN

		--populate primary phone record

		l_contact_point_rec.contact_point_type := 'PHONE';
		l_contact_point_rec.primary_flag := 'Y';
		l_contact_point_rec.contact_point_purpose := 'BUSINESS';
		l_contact_point_rec.primary_by_purpose := 'Y';
		l_phone_rec.phone_area_code := l_vendor_contact_rec.area_code;
		l_phone_rec.phone_number := l_vendor_contact_rec.phone;
                --
                -- Bug 5117377
                -- Changed the phone line type to GEN.
                --
		l_phone_rec.phone_line_type := 'GEN';

		hz_contact_point_v2pub.create_phone_contact_point(
			p_init_msg_list => FND_API.G_FALSE,
			p_contact_point_rec => l_contact_point_rec,
			p_phone_rec => l_phone_rec,
			--p_commit => FND_API.G_FALSE,
			x_return_status => l_phone_return_status,
			x_msg_count => l_phone_msg_count,
			x_msg_data => l_phone_msg_data,
			x_contact_point_id => l_phone_contact_point_id);
		IF l_phone_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      ------------------------------------------------------------------------
      l_debug_info := 'After call to hz_contact_point_v2pub.create_phone_contact_point Primary Phone';
      l_debug_info := l_debug_info||' Return status : '||l_phone_return_status||' Error : '||l_phone_msg_data;
      ------------------------------------------------------------------------
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;

	-- Bug 6886893: Start
	IF g_source = 'IMPORT' THEN

               IF ( NVL(l_per_msg_count, 0) > 1 ) THEN
		      FOR i IN 1..l_per_msg_count
		      LOOP
		          -- built the complete message with new line separator if
		          -- called API returns message count > 1
		          x_msg_data := x_msg_data||FND_MSG_PUB.Get(p_msg_index => i, p_encoded => 'T') ||' ';
		          --delete the message stack for the index
		          --already fetched
		          FND_MSG_PUB.DELETE_MSG(p_msg_index => i);
		      END LOOP;
		ELSIF (l_per_msg_data is not null) THEN
		      x_msg_data := x_msg_data||l_per_msg_data;
		END IF;

            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,x_msg_data);
            END IF;

            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,x_msg_data);
            END IF;

	    IF (Insert_Rejections(
				  p_parent_table => 'AP_SUP_SITE_CONTACT_INT',
				  p_parent_id => p_vendor_contact_rec.vendor_contact_interface_id,
				  p_reject_code => 'AP_INVALID_TCA_ERROR',
				  p_last_updated_by => g_user_id,
				  p_last_update_login => g_login_id,
				  p_calling_sequence => 'hz_party_v2pub.create_person'
				 ) <> TRUE) THEN

			     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
				    FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
				    l_api_name,'Error logging into Rejections table');
			     END IF;
	    END IF;
	ELSE
	   fnd_message.set_name('SQLAP', 'AP_INVALID_TCA_ERROR');
	   fnd_msg_pub.add;
	END IF;
	-- Bug 6886893: End

    END IF;


	END IF; --primary phone

	IF l_vendor_contact_rec.alt_phone IS NOT NULL THEN

		--populate alt phone record

		l_contact_point_rec.contact_point_type := 'PHONE';
		l_contact_point_rec.primary_flag := 'N';
		l_contact_point_rec.contact_point_purpose := 'BUSINESS';
		l_contact_point_rec.primary_by_purpose := 'N';
		l_alt_phone_rec.phone_area_code := l_vendor_contact_rec.alt_area_code;
		l_alt_phone_rec.phone_number := l_vendor_contact_rec.alt_phone;
                --
                -- Bug 5117377
                -- Changed the phone line type to GEN.
                --
		l_alt_phone_rec.phone_line_type := 'GEN';

		hz_contact_point_v2pub.create_phone_contact_point(
			p_init_msg_list => FND_API.G_FALSE,
			p_contact_point_rec => l_contact_point_rec,
			p_phone_rec => l_alt_phone_rec,
			--p_commit => FND_API.G_FALSE,
			x_return_status => l_alt_phone_return_status,
			x_msg_count => l_alt_phone_msg_count,
			x_msg_data => l_alt_phone_msg_data,
			x_contact_point_id => l_alt_phone_contact_point_id);
		IF l_alt_phone_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      ------------------------------------------------------------------------
      l_debug_info := 'After call to hz_contact_point_v2pub.create_phone_contact_point Alt Phone';
      l_debug_info := l_debug_info||' Return status : '||l_alt_phone_return_status||' Error : '||l_alt_phone_msg_data;
      ------------------------------------------------------------------------
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;

	-- Bug 6886893: Start
	IF g_source = 'IMPORT' THEN

               IF ( NVL(l_per_msg_count, 0) > 1 ) THEN
		      FOR i IN 1..l_per_msg_count
		      LOOP
		          -- built the complete message with new line separator if
		          -- called API returns message count > 1
		          x_msg_data := x_msg_data||FND_MSG_PUB.Get(p_msg_index => i, p_encoded => 'T') ||' ';
		          --delete the message stack for the index
		          --already fetched
		          FND_MSG_PUB.DELETE_MSG(p_msg_index => i);
		      END LOOP;
		ELSIF (l_per_msg_data is not null) THEN
		      x_msg_data := x_msg_data||l_per_msg_data;
		END IF;

            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,x_msg_data);
            END IF;

            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,x_msg_data);
            END IF;

	    IF (Insert_Rejections(
				  p_parent_table => 'AP_SUP_SITE_CONTACT_INT',
				  p_parent_id => p_vendor_contact_rec.vendor_contact_interface_id,
				  p_reject_code => 'AP_INVALID_TCA_ERROR',
				  p_last_updated_by => g_user_id,
				  p_last_update_login => g_login_id,
				  p_calling_sequence => 'hz_party_v2pub.create_person'
				 ) <> TRUE) THEN

			     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
				    FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
				    l_api_name,'Error logging into Rejections table');
			     END IF;
	    END IF;
	ELSE
	   fnd_message.set_name('SQLAP', 'AP_INVALID_TCA_ERROR');
	   fnd_msg_pub.add;
	END IF;
	-- Bug 6886893: End

    END IF;


	END IF; --alt phone

	IF l_vendor_contact_rec.fax_phone IS NOT NULL THEN

		--populate fax phone record

		l_contact_point_rec.contact_point_type := 'PHONE';
		l_contact_point_rec.primary_flag := 'N';
		l_contact_point_rec.contact_point_purpose := 'BUSINESS';
		l_contact_point_rec.primary_by_purpose := 'N';
		l_fax_rec.phone_area_code := l_vendor_contact_rec.fax_area_code;
		l_fax_rec.phone_number := l_vendor_contact_rec.fax_phone;
		l_fax_rec.phone_line_type := 'FAX';

		hz_contact_point_v2pub.create_phone_contact_point(
			p_init_msg_list => FND_API.G_FALSE,
			p_contact_point_rec => l_contact_point_rec,
			p_phone_rec => l_fax_rec,
			--p_commit => FND_API.G_FALSE,
			x_return_status => l_fax_return_status,
			x_msg_count => l_fax_msg_count,
			x_msg_data => l_fax_msg_data,
			x_contact_point_id => l_fax_contact_point_id);
			IF l_fax_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        ------------------------------------------------------------------------
        l_debug_info := 'After call to hz_contact_point_v2pub.create_phone_contact_point Fax Phone';
        l_debug_info := l_debug_info||' Return status : '||l_fax_return_status||' Error : '||l_fax_msg_data;
        ------------------------------------------------------------------------
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;

	-- Bug 6886893: Start
	IF g_source = 'IMPORT' THEN

               IF ( NVL(l_per_msg_count, 0) > 1 ) THEN
		      FOR i IN 1..l_per_msg_count
		      LOOP
		          -- built the complete message with new line separator if
		          -- called API returns message count > 1
		          x_msg_data := x_msg_data||FND_MSG_PUB.Get(p_msg_index => i, p_encoded => 'T') ||' ';
		          --delete the message stack for the index
		          --already fetched
		          FND_MSG_PUB.DELETE_MSG(p_msg_index => i);
		      END LOOP;
		ELSIF (l_per_msg_data is not null) THEN
		      x_msg_data := x_msg_data||l_per_msg_data;
		END IF;

            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,x_msg_data);
            END IF;

            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,x_msg_data);
            END IF;

	    IF (Insert_Rejections(
				  p_parent_table => 'AP_SUP_SITE_CONTACT_INT',
				  p_parent_id => p_vendor_contact_rec.vendor_contact_interface_id,
				  p_reject_code => 'AP_INVALID_TCA_ERROR',
				  p_last_updated_by => g_user_id,
				  p_last_update_login => g_login_id,
				  p_calling_sequence => 'hz_party_v2pub.create_person'
				 ) <> TRUE) THEN

			     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
				    FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
				    l_api_name,'Error logging into Rejections table');
			     END IF;
	    END IF;
	ELSE
	   fnd_message.set_name('SQLAP', 'AP_INVALID_TCA_ERROR');
	   fnd_msg_pub.add;
	END IF;
	-- Bug 6886893: End

      END IF;

	END IF; --fax phone

	IF l_vendor_contact_rec.email_address IS NOT NULL THEN

		--populate email record

		l_contact_point_rec.contact_point_type := 'EMAIL';
		l_contact_point_rec.primary_flag := 'Y';
		l_contact_point_rec.contact_point_purpose := 'BUSINESS';
		l_contact_point_rec.primary_by_purpose := 'N';
		l_email_rec.email_address := l_vendor_contact_rec.email_address;

		hz_contact_point_v2pub.create_email_contact_point(
			p_init_msg_list => FND_API.G_FALSE,
			p_contact_point_rec => l_contact_point_rec,
			p_email_rec => l_email_rec,
			--p_commit => FND_API.G_FALSE,
			x_return_status => l_email_return_status,
			x_msg_count => l_email_msg_count,
			x_msg_data => l_email_msg_data,
			x_contact_point_id => l_email_contact_point_id);
			IF l_email_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        ------------------------------------------------------------------------
        l_debug_info := 'After call to hz_contact_point_v2pub.create_email_contact_point';
        l_debug_info := l_debug_info||' Return status : '||l_email_return_status||' Error : '||l_email_msg_data;
        ------------------------------------------------------------------------
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;

	-- Bug 6886893: Start
	IF g_source = 'IMPORT' THEN

               IF ( NVL(l_per_msg_count, 0) > 1 ) THEN
		      FOR i IN 1..l_per_msg_count
		      LOOP
		          -- built the complete message with new line separator if
		          -- called API returns message count > 1
		          x_msg_data := x_msg_data||FND_MSG_PUB.Get(p_msg_index => i, p_encoded => 'T') ||' ';
		          --delete the message stack for the index
		          --already fetched
		          FND_MSG_PUB.DELETE_MSG(p_msg_index => i);
		      END LOOP;
		ELSIF (l_per_msg_data is not null) THEN
		      x_msg_data := x_msg_data||l_per_msg_data;
		END IF;

            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,x_msg_data);
            END IF;

            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,x_msg_data);
            END IF;

	    IF (Insert_Rejections(
				  p_parent_table => 'AP_SUP_SITE_CONTACT_INT',
				  p_parent_id => p_vendor_contact_rec.vendor_contact_interface_id,
				  p_reject_code => 'AP_INVALID_TCA_ERROR',
				  p_last_updated_by => g_user_id,
				  p_last_update_login => g_login_id,
				  p_calling_sequence => 'hz_party_v2pub.create_person'
				 ) <> TRUE) THEN

			     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
				    FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
				    l_api_name,'Error logging into Rejections table');
			     END IF;
	    END IF;
	ELSE
	   fnd_message.set_name('SQLAP', 'AP_INVALID_TCA_ERROR');
	   fnd_msg_pub.add;
	END IF;
	-- Bug 6886893: End

      END IF;

	END IF; --email

	IF l_vendor_contact_rec.url IS NOT NULL THEN

		--populate url record

		l_contact_point_rec.contact_point_type := 'WEB';
		l_contact_point_rec.primary_flag := 'Y';
		l_contact_point_rec.contact_point_purpose := 'HOMEPAGE'; --bug5875982
		l_contact_point_rec.primary_by_purpose := 'N';
		--Open Issue 5
		l_url_rec.web_type := 'HTTP';
		l_url_rec.url := l_vendor_contact_rec.url;

		hz_contact_point_v2pub.create_web_contact_point(
			p_init_msg_list => FND_API.G_FALSE,
			p_contact_point_rec => l_contact_point_rec,
			p_web_rec => l_url_rec,
			--p_commit => FND_API.G_FALSE,
			x_return_status => l_url_return_status,
			x_msg_count => l_url_msg_count,
			x_msg_data => l_url_msg_data,
			x_contact_point_id => l_url_contact_point_id);
			IF l_url_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        ------------------------------------------------------------------------
        l_debug_info := 'After call to hz_contact_point_v2pub.create_web_contact_point';
        l_debug_info := l_debug_info||' Return status : '||l_url_return_status||' Error : '||l_url_msg_data;
        ------------------------------------------------------------------------
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;

	-- Bug 6886893: Start
	IF g_source = 'IMPORT' THEN

               IF ( NVL(l_per_msg_count, 0) > 1 ) THEN
		      FOR i IN 1..l_per_msg_count
		      LOOP
		          -- built the complete message with new line separator if
		          -- called API returns message count > 1
		          x_msg_data := x_msg_data||FND_MSG_PUB.Get(p_msg_index => i, p_encoded => 'T') ||' ';
		          --delete the message stack for the index
		          --already fetched
		          FND_MSG_PUB.DELETE_MSG(p_msg_index => i);
		      END LOOP;
		ELSIF (l_per_msg_data is not null) THEN
		      x_msg_data := x_msg_data||l_per_msg_data;
		END IF;

            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,x_msg_data);
            END IF;

            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,x_msg_data);
            END IF;

	    IF (Insert_Rejections(
				  p_parent_table => 'AP_SUP_SITE_CONTACT_INT',
				  p_parent_id => p_vendor_contact_rec.vendor_contact_interface_id,
				  p_reject_code => 'AP_INVALID_TCA_ERROR',
				  p_last_updated_by => g_user_id,
				  p_last_update_login => g_login_id,
				  p_calling_sequence => 'hz_party_v2pub.create_person'
				 ) <> TRUE) THEN

			     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
				    FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
				    l_api_name,'Error logging into Rejections table');
			     END IF;
	    END IF;
	ELSE
	   fnd_message.set_name('SQLAP', 'AP_INVALID_TCA_ERROR');
	   fnd_msg_pub.add;
	END IF;
	-- Bug 6886893: End

      END IF;

	END IF; --url

    END IF; --contact points

    IF (l_val_return_status = FND_API.G_RET_STS_SUCCESS) AND
		(l_per_return_status = FND_API.G_RET_STS_SUCCESS) AND
		(l_org_contact_return_status = FND_API.G_RET_STS_SUCCESS) AND
		(l_site_return_status = FND_API.G_RET_STS_SUCCESS) AND
		(l_phone_return_status = FND_API.G_RET_STS_SUCCESS) AND
		(l_alt_phone_return_status  = FND_API.G_RET_STS_SUCCESS) AND
		(l_fax_return_status  = FND_API.G_RET_STS_SUCCESS) AND
		(l_email_return_status = FND_API.G_RET_STS_SUCCESS) AND
		(l_url_return_status  = FND_API.G_RET_STS_SUCCESS) THEN


	SELECT po_vendor_contacts_s.nextval
    	INTO   l_vendor_contact_rec.vendor_contact_id
    	FROM   dual;

	INSERT INTO ap_supplier_contacts(
        	per_party_id,
		relationship_id,
		rel_party_id,
		party_site_id,
		org_contact_id,
		org_party_site_id,
		--vendor_site_id, Bug 7013954 Vendor Site info no longer used
		vendor_contact_id,
        	last_update_date,
        	last_updated_by,
        	creation_date,
        	created_by,
        	last_update_login,
		request_id,
		program_application_id,
		program_id,
		program_update_date,
	        inactive_date, --Bug 4994974
            attribute_category,  --bug 6745669 -- added dff columns
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
                attribute15
                --bug 6745669
    	)VALUES(
        	l_vendor_contact_rec.per_party_id,
		l_vendor_contact_rec.relationship_id,
		l_vendor_contact_rec.rel_party_id,
		l_vendor_contact_rec.party_site_id,
		l_vendor_contact_rec.org_contact_id,
		l_vendor_contact_rec.org_party_site_id,
		--l_vendor_contact_rec.vendor_site_id, Bug 7013954 Vendor Site info no longer used
		l_vendor_contact_rec.vendor_contact_id,
        	SYSDATE,
        	nvl(fnd_global.user_id,-1),
        	SYSDATE,
        	nvl(fnd_global.user_id,-1),
        	nvl(fnd_global.login_id,-1),
		nvl(FND_GLOBAL.conc_request_id,-1),
		nvl(FND_GLOBAL.prog_appl_id,-1),
		nvl(FND_GLOBAL.conc_program_id,-1),
		sysdate,
                l_vendor_contact_rec.inactive_date, --Bug 4994974
                l_vendor_contact_rec.attribute_category,  --bug 6745669 -- added dff columns
                l_vendor_contact_rec.attribute1,
                l_vendor_contact_rec.attribute2,
                l_vendor_contact_rec.attribute3,
                l_vendor_contact_rec.attribute4,
                l_vendor_contact_rec.attribute5,
                l_vendor_contact_rec.attribute6,
                l_vendor_contact_rec.attribute7,
                l_vendor_contact_rec.attribute8,
                l_vendor_contact_rec.attribute9,
                l_vendor_contact_rec.attribute10,
                l_vendor_contact_rec.attribute11,
                l_vendor_contact_rec.attribute12,
                l_vendor_contact_rec.attribute13,
                l_vendor_contact_rec.attribute14,
                l_vendor_contact_rec.attribute15
    	);

	x_vendor_contact_id := l_vendor_contact_rec.vendor_contact_id;
	x_per_party_id := l_vendor_contact_rec.per_party_id;
	x_rel_party_id := l_vendor_contact_rec.rel_party_id;
	x_rel_id := l_vendor_contact_rec.relationship_id;
	x_org_contact_id := l_vendor_contact_rec.org_contact_id;
	x_party_site_id := l_vendor_contact_rec.party_site_id;

    Raise_Supplier_Event( i_vendor_contact_id => x_vendor_contact_id ); -- Bug 7307669

    ELSIF (l_val_return_status = FND_API.G_RET_STS_UNEXP_ERROR) OR
		(l_per_return_status = FND_API.G_RET_STS_UNEXP_ERROR) OR
		(l_org_contact_return_status = FND_API.G_RET_STS_UNEXP_ERROR) OR
		(l_site_return_status = FND_API.G_RET_STS_UNEXP_ERROR) OR
		(l_phone_return_status = FND_API.G_RET_STS_UNEXP_ERROR) OR
		(l_alt_phone_return_status  = FND_API.G_RET_STS_UNEXP_ERROR) OR
		(l_fax_return_status  = FND_API.G_RET_STS_UNEXP_ERROR) OR
		(l_email_return_status = FND_API.G_RET_STS_UNEXP_ERROR) OR
		(l_url_return_status  = FND_API.G_RET_STS_UNEXP_ERROR) THEN

	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    ELSE

	x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- End of API body.

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
	COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1,
    -- get message info.
    FND_MSG_PUB.Count_And_Get(
	p_count         	=>      x_msg_count     	,
        p_data          	=>      x_msg_data
    	);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Create_Vendor_Contact_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Create_Vendor_Contact_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);
	WHEN OTHERS THEN
		ROLLBACK TO Create_Vendor_Contact_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);
END Create_Vendor_Contact;

PROCEDURE Update_Vendor_Contact
( 	p_api_version       IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	IN  	NUMBER	:=  FND_API.G_VALID_LEVEL_FULL,
	p_vendor_contact_rec	IN	r_vendor_contact_rec_type,
	x_return_status		OUT	NOCOPY VARCHAR2		  	,
	x_msg_count		    OUT	NOCOPY NUMBER,
	x_msg_data		    OUT	NOCOPY VARCHAR2

)
IS
    l_api_name	    CONSTANT VARCHAR2(30)	:= 'Update_Vendor_Contact';
    l_api_version   CONSTANT NUMBER 		:= 1.0;

BEGIN
	-- Standard Start of API savepoint
    SAVEPOINT	Update_Vendor_Contact_PUB;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
    THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- API body

    IF ( p_vendor_contact_rec.PER_PARTY_ID  IS NOT NULL AND
         p_vendor_contact_rec.RELATIONSHIP_ID IS NOT NULL AND
         p_vendor_contact_rec.REL_PARTY_ID  IS NOT NULL AND
         p_vendor_contact_rec.PARTY_SITE_ID IS NOT NULL AND
         p_vendor_contact_rec.ORG_CONTACT_ID  IS NOT NULL AND
         p_vendor_contact_rec.ORG_PARTY_SITE_ID IS NOT NULL AND
         p_vendor_contact_rec.VENDOR_CONTACT_ID IS NOT NULL
        )
    THEN
        UPDATE ap_supplier_contacts set
             	last_update_date = SYSDATE,
               	last_updated_by = g_user_id,
            	last_update_login = g_login_id,
                inactive_date =p_vendor_contact_rec.inactive_date
        WHERE per_party_id = p_vendor_contact_rec.per_party_id AND
               relationship_id =p_vendor_contact_rec.relationship_id AND
               rel_party_id= p_vendor_contact_rec.rel_party_id AND
               party_site_id = p_vendor_contact_rec.party_site_id AND
               org_contact_id =p_vendor_contact_rec.org_contact_id AND
               vendor_contact_id =p_vendor_contact_rec.vendor_contact_id;

	Raise_Supplier_Event( i_vendor_contact_id => p_vendor_contact_rec.vendor_contact_id ); -- Bug 7307669

    ELSE
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END IF;

    -- End of API body.

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
	COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1,
    -- get message info.
    FND_MSG_PUB.Count_And_Get(
	p_count         	=>      x_msg_count     	,
        p_data          	=>      x_msg_data
    	);

EXCEPTION
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Update_Vendor_Contact_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);
	WHEN OTHERS THEN
		ROLLBACK TO Update_Vendor_Contact_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);
END Update_Vendor_Contact;


PROCEDURE Validate_Vendor_Contact
( 	p_api_version           IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	IN  	NUMBER	:=
						FND_API.G_VALID_LEVEL_FULL,
	x_return_status		OUT	NOCOPY VARCHAR2		  	,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_vendor_contact_rec	IN OUT	NOCOPY r_vendor_contact_rec_type,
	x_rel_party_valid 	OUT 	NOCOPY VARCHAR2,
	x_per_party_valid 	OUT 	NOCOPY VARCHAR2,
	x_rel_valid 		OUT 	NOCOPY VARCHAR2,
        x_org_party_id          OUT     NOCOPY NUMBER,
	x_org_contact_valid 	OUT 	NOCOPY VARCHAR2,
	x_location_id		OUT	NOCOPY NUMBER,
	x_party_site_valid	OUT  	NOCOPY VARCHAR2
)
IS
    l_api_name		CONSTANT VARCHAR2(30)	:= 'Validate_Vendor_Contact';
    l_api_version       CONSTANT NUMBER 		:= 1.0;

    l_def_org_id		NUMBER;
    l_debug_info		VARCHAR2(2000);
    x_valid			BOOLEAN;

	-- Bug 8557954 ...
	l_vend_party_id		NUMBER ;
	l_vend_org_id		NUMBER ;
	l_vend_cont_party_id	NUMBER ;
	l_vend_cont_last_name	hz_parties.person_last_name%TYPE ;
	l_combo_ct		NUMBER ;

BEGIN
    -- Bug 7013954 The validation logic is modified to accomodate the changes
    -- related to contacts. The Contacts are now associated at Party Site/Address
    -- or at Supplier level. Supplier Site level association is deprecated in R12.
    -- Standard Start of API savepoint
	SAVEPOINT	Validate_Vendor_Contact_PUB;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
    THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- API body

	-- Special logic for Import

-- Bug 8549900
-- Removing the logic for Creating contacts from CONTRACTS
-- Commenting the code written for IMPORT only

-- IF g_source = 'IMPORT' THEN
     -- Org_Id and Operating_unit_name validation
     IF p_vendor_contact_rec.org_id IS NOT NULL OR
        p_vendor_contact_rec.operating_unit_name IS NOT NULL THEN

       Check_org_id_name(p_vendor_contact_rec.org_id,
                         p_vendor_contact_rec.operating_unit_name,
                         'AP_SUP_SITE_CONTACT_INT',
                         p_vendor_contact_rec.vendor_contact_interface_id,
                         x_valid);
       IF NOT x_valid THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
	 END IF;

	 -- Bug 7013954 If Party_Site_Name is provided, derive the party_site_id.
	 IF (p_vendor_contact_rec.party_site_name IS NOT NULL AND
              p_vendor_contact_rec.org_party_site_id IS NULL AND
              (p_vendor_contact_rec.org_id IS NOT NULL OR
               p_vendor_contact_rec.operating_unit_name IS NOT NULL) AND
			   p_vendor_contact_rec.vendor_id IS NOT NULL)THEN
       Check_org_id_party_site_name(p_vendor_contact_rec.org_id,
                                       p_vendor_contact_rec.operating_unit_name,
                                       p_vendor_contact_rec.org_party_site_id,
                                       p_vendor_contact_rec.party_site_name,
                                       p_vendor_contact_rec.vendor_id,
                                       'AP_SUP_SITE_CONTACT_INT',
                                       p_vendor_contact_rec.vendor_contact_interface_id,
                                       x_valid);
       IF NOT x_valid THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
	 -- Vendor_Site_Id Validation
	 -- We need to take vendor_site_id info only when party site info is null
     ELSIF p_vendor_contact_rec.vendor_site_id IS NOT NULL AND
              p_vendor_contact_rec.org_party_site_id IS NULL AND
              p_vendor_contact_rec.PARTY_SITE_NAME IS NULL THEN
       Check_Vendor_site_id(p_vendor_contact_rec.vendor_site_id,
                                'AP_SUP_SITE_CONTACT_INT',
                                p_vendor_contact_rec.vendor_contact_interface_id,
                                x_valid);
       IF NOT x_valid THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
       ELSE
		  SELECT hps.party_id,
		    hps.location_id
		  INTO x_org_party_id,
		    x_location_id
		  FROM HZ_Party_Sites hps, po_vendor_sites_all pvs
		  WHERE pvs.vendor_site_id = p_vendor_contact_rec.vendor_site_id
		  AND pvs.party_site_id = hps.party_site_id;

		  SELECT party_site_id
		  INTO p_vendor_contact_rec.org_party_site_id
		  FROM po_vendor_sites
		  WHERE vendor_site_id = p_vendor_contact_rec.vendor_site_id;
	   END IF;
	 ELSIF (p_vendor_contact_rec.vendor_site_code IS NOT NULL AND
              p_vendor_contact_rec.org_party_site_id IS NULL AND
              p_vendor_contact_rec.PARTY_SITE_NAME IS NULL AND
              (p_vendor_contact_rec.org_id IS NOT NULL OR
               p_vendor_contact_rec.operating_unit_name IS NOT NULL))THEN
              Check_Org_Id_Name_Site_Code(p_vendor_contact_rec.org_id,
                                       p_vendor_contact_rec.operating_unit_name,
                                       p_vendor_contact_rec.vendor_site_id,
                                       p_vendor_contact_rec.vendor_site_code,
                                       'AP_SUP_SITE_CONTACT_INT',
                                       p_vendor_contact_rec.vendor_contact_interface_id,
                                       x_valid);
              IF NOT x_valid THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
-- B# 8219586
              ELSE
          SELECT hps.party_id,
            hps.location_id
          INTO x_org_party_id,
            x_location_id
          FROM HZ_Party_Sites hps, po_vendor_sites_all pvs
          WHERE pvs.vendor_site_id = p_vendor_contact_rec.vendor_site_id
          AND pvs.party_site_id = hps.party_site_id;

          SELECT party_site_id
          INTO p_vendor_contact_rec.org_party_site_id
          FROM po_vendor_sites_all
          WHERE vendor_site_id = p_vendor_contact_rec.vendor_site_id;
-- end B# 8219586
              END IF;
	 END IF;
-- Commented for Bug 8549900
--END IF;


	------------------------------------------------------------------------
	l_debug_info := 'Call to Validate party_site_id';
	------------------------------------------------------------------------
	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
				l_api_name,l_debug_info);
	END IF;
	-- Check for validity of party_site_id
	--
	IF p_vendor_contact_rec.party_site_id IS NOT NULL THEN
		Check_Valid_Party_Site_ID(p_vendor_contact_rec.party_site_id,
						x_location_id,
						x_valid);

		IF NOT x_valid THEN
				--party_site_id does not exist
		  x_return_status := FND_API.G_RET_STS_ERROR;
		  x_party_site_valid := 'F';
		  -- Special logic for Import
		  IF g_source = 'IMPORT' THEN
			IF (Insert_Rejections(
				  'AP_SUP_SITE_CONTACT_INT',
				  p_vendor_contact_rec.vendor_contact_interface_id,
				  'AP_INVALID_PARTY_SITE',
				  g_user_id,
				  g_login_id,
				  'Validate_Vendor_Contact') <> TRUE) THEN
			 --
			  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
				FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
				  l_api_name,'Parameters: '
				  ||' Vendor_Contact_Interface_Id: '||
				  p_vendor_contact_rec.vendor_contact_interface_id
				  --||' Vendor_Site_Id: '||p_vendor_contact_rec.vendor_site_id
				  ||', Party_Site_Id: '||p_vendor_contact_rec.party_site_id);
			  END IF;
			END IF;
		  ELSE
			-- Bug 5491139 hkaniven start --
			FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_PARTY_SITE');
			FND_MSG_PUB.ADD;
			-- Bug 5491139 hkaniven end --
		  END IF;
		ELSE
				--party_site_id was valid
				x_party_site_valid := 'V';
		END IF;
	ELSE
		--party_site_id is null
		x_party_site_valid := 'N';
	END IF;

	x_valid := TRUE;
	--set some values
	IF p_vendor_contact_rec.org_party_site_id IS NOT NULL THEN
		Check_Valid_Party_Site_ID(p_vendor_contact_rec.org_party_site_id,
						x_location_id,
						x_valid);
		IF x_valid THEN

		  SELECT hps.party_id,
		    hps.location_id
		  INTO x_org_party_id,
		    x_location_id
		  FROM HZ_Party_Sites hps
		  WHERE hps.party_site_id =
		    p_vendor_contact_rec.org_party_site_id;
		END if;
		--open issue 12, no way to populate vendor_site_id

	-- Bug 7013954
	-- If the contact is to be created at supplier level then
	-- party_site_id is null. We need to populate org_party_id
	-- based on the vendor_id value. We should also set party_site_valid
	-- variable as valid because there is no party site associated with	the
	-- contact and we should not create one in create_vendor_contact method.
	ELSIF p_vendor_contact_rec.vendor_site_id IS NULL and
	    p_vendor_contact_rec.vendor_site_code IS NULL and
	    p_vendor_contact_rec.org_party_site_id IS NULL and
	    p_vendor_contact_rec.PARTY_SITE_NAME IS NULL and
	    p_vendor_contact_rec.vendor_id IS NOT NULL THEN
	    SELECT aps.party_id
	       INTO x_org_party_id
	    FROM AP_SUPPLIERS aps
	    WHERE aps.vendor_id = p_vendor_contact_rec.vendor_id;

	    x_party_site_valid := 'V';
	    x_valid := TRUE;
		/*
		-- new message
		x_return_status := FND_API.G_RET_STS_ERROR;
                -- Special logic for Import
                IF g_source = 'IMPORT' THEN
                  IF (Insert_Rejections(
                          'AP_SUP_SITE_CONTACT_INT',
                          p_vendor_contact_rec.vendor_contact_interface_id,
                          'AP_INCONSISTENT_PARTY_SITE',
                          g_user_id,
                          g_login_id,
                          'Validate_Vendor_Contact') <> TRUE) THEN
                    --
                    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                          l_api_name,'Parameters: '
                          ||' Vendor_Contact_Interface_Id: '||
                                   p_vendor_contact_rec.vendor_contact_interface_id
                          ||',Vendor_Site_Id: '||p_vendor_contact_rec.vendor_site_id
                          ||', Org_Party_Site_Id: '||p_vendor_contact_rec.org_party_site_id);
                    END IF;
                  END IF;
                ELSE
                    -- Bug 5491139 hkaniven start --
                    FND_MESSAGE.SET_NAME('SQLAP','AP_INCONSISTENT_PARTY_SITE');
                    FND_MSG_PUB.ADD;
                    -- Bug 5491139 hkaniven end --
                END IF;*/
	END IF;

	-- We need to first check if the org_party_site_id provided/ derived is
	-- valid. If x_valid is false then the party site info is invalid.
	IF NOT x_valid THEN
		  --party_site_id does not exist
		  x_return_status := FND_API.G_RET_STS_ERROR;
		  -- Special logic for Import
		  IF g_source = 'IMPORT' THEN
			IF (Insert_Rejections(
				  'AP_SUP_SITE_CONTACT_INT',
				  p_vendor_contact_rec.vendor_contact_interface_id,
				  'AP_INVALID_PARTY_SITE',
				  g_user_id,
				  g_login_id,
				  'Validate_Vendor_Contact') <> TRUE) THEN
			 --
			  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
				FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
				  l_api_name,'Parameters: '
				  ||' Vendor_Contact_Interface_Id: '||
				  p_vendor_contact_rec.vendor_contact_interface_id
				  --||' Vendor_Site_Id: '||p_vendor_contact_rec.vendor_site_id
				  ||', Org_Party_Site_Id: '||p_vendor_contact_rec.org_party_site_id);
			  END IF;
			END IF;
		  ELSE
			-- Bug 5491139 hkaniven start --
			FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_PARTY_SITE');
			FND_MSG_PUB.ADD;
			-- Bug 5491139 hkaniven end --
		  END IF;
		END IF;
    -----------------------------------------------------------------------
	l_debug_info := 'Call to Validate party_id';
	--------------------------------------------------------------
	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
				l_api_name,l_debug_info);
	END IF;

	-- Check for validity of party_id
	--
	IF p_vendor_contact_rec.per_party_id IS NOT NULL THEN
		Check_Valid_Party_ID(p_vendor_contact_rec.per_party_id,
						x_valid);

		IF NOT x_valid THEN
		  x_return_status := FND_API.G_RET_STS_ERROR;
		  x_per_party_valid := 'F';
		  -- Special logic for Import
		  IF g_source = 'IMPORT' THEN
			IF (Insert_Rejections(
				  'AP_SUP_SITE_CONTACT_INT',
				  p_vendor_contact_rec.vendor_contact_interface_id,
				  'AP_INVALID_PARTY_SITE',
				  g_user_id,
				  g_login_id,
				  'Validate_Vendor_Contact') <> TRUE) THEN
			 --
			  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
				FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
				  l_api_name,'Parameters: '
				  ||' Vendor_Contact_Interface_Id: '||
				  p_vendor_contact_rec.vendor_contact_interface_id
				  --||' Vendor_Site_Id: '||p_vendor_contact_rec.vendor_site_id
				  ||', Party_Site_Id: '||p_vendor_contact_rec.party_site_id);
			  END IF;
			END IF;
		  ELSE
			-- Bug 5491139 hkaniven start --
			FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_PARTY_SITE');
			FND_MSG_PUB.ADD;
			-- Bug 5491139 hkaniven end --
		  END IF;
		ELSE
			x_per_party_valid := 'V';
		END IF;
	ELSE  --  ... for IF p_vendor_contact_rec.per_party_id IS NOT NULL ...
		-- Bug 8557954 -Start
		-- derive the party_id from first name, middle_name, last name and
		-- 	phone_area_code, PHONE_NUMBER, and email_address
		--
		-- first, get party_id of the Vendor for the vendor-site
		--
		Select party_id into l_vend_party_id
		  from ap_suppliers
		  where vendor_id = p_vendor_contact_rec.vendor_id ;

		-- populate all contact related details for the contact-vendor relationship.
		x_per_party_valid := 'V' ;
		BEGIN
			select	hpc.party_id,
				hr.relationship_id,
				hr.party_id
			  into				p_vendor_contact_rec.per_party_id,
							p_vendor_contact_rec.relationship_id,
							p_vendor_contact_rec.rel_party_id
			from hz_parties hpc,
			     hz_contact_points hcpp,
			     hz_contact_points hcpe,
			     hz_relationships hr
			where hr.subject_id = l_vend_party_id	--  <party_id of vendor>
			  And hcpp.owner_table_name(+) = 'HZ_PARTIES'
			  And hcpp.owner_table_id(+) = hr.PARTY_ID
			  And hcpp.phone_line_type(+) = 'GEN'
			  And hcpp.contact_point_type(+) = 'PHONE'
			  And hcpe.OWNER_TABLE_NAME(+) = 'HZ_PARTIES'
			  and hcpe.OWNER_TABLE_ID(+) = hr.PARTY_ID
			  And hcpe.CONTACT_POINT_TYPE(+) = 'EMAIL'
			  and hr.object_id = hpc.party_id
			  and hr.subject_type = 'ORGANIZATION'
			  and hr.subject_table_name = 'HZ_PARTIES'
			  and hr.object_table_name = 'HZ_PARTIES'
			  and hr.object_type = 'PERSON'
			  and hr.relationship_code = 'CONTACT'
			  and hr.directional_flag = 'B'
			  and hr.relationship_type = 'CONTACT'
			  and hpc.PARTY_TYPE = 'PERSON'
			  and nvl(upper(hpc.person_first_name),'DUMMY')
				= nvl(upper(p_vendor_contact_rec.person_first_name),'DUMMY')
			  and nvl(upper(hpc.person_middle_name),'DUMMY')
				= nvl(upper(p_vendor_contact_rec.person_middle_name),'DUMMY')
			  and nvl(upper(hpc.person_last_name),'DUMMY')
				= nvl(upper(p_vendor_contact_rec.person_last_name),'DUMMY')
			  and nvl(upper(hcpp.phone_area_code),'DUMMY')
				= nvl(upper(p_vendor_contact_rec.area_code),'DUMMY')
			  and nvl(upper(hcpp.PHONE_NUMBER),'DUMMY')
				= nvl(upper(p_vendor_contact_rec.phone),'DUMMY')
			  and nvl(upper(hcpe.email_address),'DUMMY')
				= nvl(upper(p_vendor_contact_rec.email_address),'DUMMY')

			  and rownum < 2 ;

			EXCEPTION
			WHEN NO_DATA_FOUND THEN
				x_per_party_valid := 'N' ;
		END ;

		IF x_per_party_valid <> 'N' THEN
			BEGIN
				Select org_contact_id into p_vendor_contact_rec.org_contact_id
				from ap_supplier_contacts
				where per_party_id	= p_vendor_contact_rec.per_party_id
				  and relationship_id	= p_vendor_contact_rec.relationship_id
				  and rel_party_id	= p_vendor_contact_rec.rel_party_id
				  and rownum < 2 ;
				EXCEPTION
				WHEN NO_DATA_FOUND THEN
					x_per_party_valid := 'N';
			END ;
		END IF ;

		IF x_per_party_valid <> 'N' THEN
			--check if same combination of per_party_id / org_party_site_id
			-- exists in ap_supplier_contacts
			Select count(*) into l_combo_ct from ap_supplier_contacts
			where per_party_id = p_vendor_contact_rec.per_party_id
			  and relationship_id = p_vendor_contact_rec.relationship_id
			  and rel_party_id = p_vendor_contact_rec.rel_party_id
			  and NVL(org_party_site_id, -1) = NVL(p_vendor_contact_rec.org_party_site_id, -1) ;
			  -- NVL used because contacts can be directly associated
			  --  can be directly associated to supplier. In such cases org_party_site_id would be null.
     		    IF l_combo_ct > 0 THEN
				-- throw duplicate contact for same supplier error.
				x_return_status := FND_API.G_RET_STS_ERROR;
				x_per_party_valid := 'F';
          		  -- Special logic for Import
          		IF g_source = 'IMPORT' THEN
          		   IF (Insert_Rejections(
          				  'AP_SUP_SITE_CONTACT_INT',
          				  p_vendor_contact_rec.vendor_contact_interface_id,
          				  'AP_VEN_CONTACT_DUP_NAME',
          				  g_user_id,
          				  g_login_id,
          				  'Validate_Vendor_Contact') <> TRUE) THEN

        				-- put true message to conc log file
        			l_debug_info := '***** ERROR :  Contact information you are trying to import is already associated ';
        			l_debug_info := l_debug_info || 'with the Supplier ....  Vendor_Id: ' ||p_vendor_contact_rec.vendor_id;
        			AP_IMPORT_UTILITIES_PKG.Print( 'Y', l_debug_info) ;
        			-- put true message to fnd log file
        			IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        				FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
        			END IF ;
        			-- 2nd part of message ...
        			l_debug_info := 'Contact last_name ' || p_vendor_contact_rec.person_last_name;
        			l_debug_info := l_debug_info || '    first_name ' || p_vendor_contact_rec.person_first_name;
        			l_debug_info := l_debug_info || '  middle_name ' || p_vendor_contact_rec.person_middle_name;
        			AP_IMPORT_UTILITIES_PKG.Print( 'Y', l_debug_info) ;
        			IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        			    FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
        			END IF ;
          		   END IF;
          		ELSE

          			FND_MESSAGE.SET_NAME('SQLAP','AP_VEN_CONTACT_DUP_NAME');
          			FND_MSG_PUB.ADD;
        			-- put true message to conc log file
        			l_debug_info := '***** ERROR :  Contact information you are trying to import is already associated ';
        			l_debug_info := l_debug_info || 'with the Supplier ....  Vendor_Id: ' ||p_vendor_contact_rec.vendor_id;
        			AP_IMPORT_UTILITIES_PKG.Print( 'Y', l_debug_info) ;
        			-- put true message to fnd log file
        			IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        				FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
        			END IF ;
        			-- 2nd part of message ...
        			l_debug_info := 'Contact last_name ' || p_vendor_contact_rec.person_last_name;
        			l_debug_info := l_debug_info || '    first_name ' || p_vendor_contact_rec.person_first_name;
        			l_debug_info := l_debug_info || '  middle_name ' || p_vendor_contact_rec.person_middle_name;
                                AP_IMPORT_UTILITIES_PKG.Print( 'Y', l_debug_info) ;
        			IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        				FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
        			END IF ;
          		  END IF;
			END IF ;
		END IF ;
		-- B 8557954 end

	END IF; --  ... for IF p_vendor_contact_rec.per_party_id IS NOT NULL ... Bug 8557954 End

	-----------------------------------------------------------------------
	l_debug_info := 'Call to Validate rel_party_id';
	--------------------------------------------------------------
	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
					l_api_name,l_debug_info);
	END IF;

	-- Check for validity of rel_party_id
	--
	IF p_vendor_contact_rec.rel_party_id IS NOT NULL THEN
		Check_Valid_Party_ID(p_vendor_contact_rec.rel_party_id,
						x_valid);

		IF NOT x_valid THEN
		  x_return_status := FND_API.G_RET_STS_ERROR;
		  x_rel_party_valid := 'F';
		  -- Special logic for Import
		  IF g_source = 'IMPORT' THEN
			IF (Insert_Rejections(
				  'AP_SUP_SITE_CONTACT_INT',
				  p_vendor_contact_rec.vendor_contact_interface_id,
				  'AP_INVALID_REL_PARTY',
				  g_user_id,
				  g_login_id,
				  'Validate_Vendor_Contact') <> TRUE) THEN
			 --
			  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
				FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
				  l_api_name,'Parameters: '
				  ||' Vendor_Contact_Interface_Id: '||
				  p_vendor_contact_rec.vendor_contact_interface_id
				  ||' Party_Site_Id: '||p_vendor_contact_rec.org_party_site_id
				  ||', rel_party_id: '||p_vendor_contact_rec.rel_party_id);
			  END IF;
			END IF;
		  ELSE
			-- Bug 5491139 hkaniven start --
			FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_REL_PARTY');
			FND_MSG_PUB.ADD;
			-- Bug 5491139 hkaniven end --
		  END IF;
		ELSE
				x_rel_party_valid := 'V';
		END IF;
	ELSE
		x_rel_party_valid := 'N';
	END IF;

	--call relationship validations

        --------------------------------------------------------------
        l_debug_info := 'Call to Validate relationship_id';
        --------------------------------------------------------------
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                        l_api_name,l_debug_info);
        END IF;

	-- Check for validity of relationship_id
	--
	IF p_vendor_contact_rec.relationship_id IS NOT NULL THEN

	   Check_Valid_Relationship_ID(p_vendor_contact_rec.relationship_id,
								   x_valid);

	   IF NOT x_valid THEN
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 x_rel_valid := 'F';
		 IF g_source = 'IMPORT' THEN
		   IF (Insert_Rejections(
					  'AP_SUP_SITE_CONTACT_INT',
					  p_vendor_contact_rec.vendor_contact_interface_id,
					  'AP_INVALID_RELATIONSHIP',
					  g_user_id,
					  g_login_id,
					  'Validate_Vendor_Contact') <> TRUE) THEN
			 --
			 IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
					FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
					l_api_name,'Parameters: '
					||' Vendor_Contact_Interface_Id: '||
				  p_vendor_contact_rec.vendor_contact_interface_id
					||' Vendor_Interface_Id: '||p_vendor_contact_rec.vendor_interface_id
					||', Relationship_Id: '||p_vendor_contact_rec.relationship_id);
			 END IF;
		   END IF;
		 ELSE
			-- Bug 5491139 hkaniven start --
			FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_RELATIONSHIP');
			FND_MSG_PUB.ADD;
			-- Bug 5491139 hkaniven end --
		 END IF;
	   ELSE
		  x_rel_valid := 'V';
	   END IF;
    ELSE
	  x_rel_valid := 'N';
    END IF;

    -- call org contact validation

    --------------------------------------------------------------
    l_debug_info := 'Call to Validate org_contact_id';
    --------------------------------------------------------------
	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
					l_api_name,l_debug_info);
	END IF;

    -- Check for validity of org_contact_id
    --
    IF p_vendor_contact_rec.org_contact_id IS NOT NULL THEN

	  Check_Valid_Org_Contact_ID(p_vendor_contact_rec.org_contact_id,
								 x_valid);

	  IF NOT x_valid THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		x_org_contact_valid := 'F';
		-- Special logic for Import
		IF g_source = 'IMPORT' THEN
		  IF (Insert_Rejections(
					  'AP_SUP_SITE_CONTACT_INT',
					  p_vendor_contact_rec.vendor_contact_interface_id,
					  'AP_INVALID_ORG_CONTACT',
					  g_user_id,
					  g_login_id,
					  'Validate_Vendor_Contact') <> TRUE) THEN
		  --
			IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
					FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
					l_api_name,'Parameters: '
					||' Vendor_Contact_Interface_Id: '||
					p_vendor_contact_rec.vendor_contact_interface_id
					||' Vendor_Interface_Id: '||p_vendor_contact_rec.vendor_id
					||', org_contact_id: '||p_vendor_contact_rec.org_contact_id);
			END IF;
		  END IF;
		ELSE
			-- Bug 5491139 hkaniven start --
			FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_ORG_CONTACT');
			FND_MSG_PUB.ADD;
			-- Bug 5491139 hkaniven end --
		END IF;
	  ELSE
		 x_org_contact_valid := 'V';
	  END IF;
    ELSE
	  x_org_contact_valid := 'N';
    END IF;
    -- End of API body.

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
	COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1,
    -- get message info.
    FND_MSG_PUB.Count_And_Get(
	p_count         	=>      x_msg_count     	,
        p_data          	=>      x_msg_data
    	);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Validate_Vendor_Contact_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Validate_Vendor_Contact_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);
	WHEN OTHERS THEN
		ROLLBACK TO Validate_Vendor_Contact_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);
END Validate_Vendor_Contact;

PROCEDURE Import_Vendors
(       p_api_version           IN      NUMBER,
        p_source                IN      VARCHAR2 DEFAULT 'IMPORT',
        p_what_to_import        IN      VARCHAR2 DEFAULT NULL,
        p_commit_size           IN      NUMBER   DEFAULT 1000,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2
)
IS

    l_api_name                  CONSTANT VARCHAR2(30)   := 'Import_Vendors';
    l_api_version               CONSTANT NUMBER         := 1.0;

    l_program_application_id    NUMBER  := FND_GLOBAL.prog_appl_id;
    l_program_id                NUMBER  := FND_GLOBAL.conc_program_id;
    l_request_id                NUMBER  := FND_GLOBAL.conc_request_id;

    l_return_status             VARCHAR2(2000);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);
    l_vendor_id                 NUMBER;
    l_party_id                  NUMBER;

    CURSOR vendor_int_cur IS
    SELECT *
    FROM Ap_Suppliers_Int
    WHERE import_request_id = l_request_id
    AND   vendor_interface_id IS NOT NULL
    ORDER BY segment1;

    vendor_int_rec             vendor_int_cur%ROWTYPE;
    vendor_rec                 r_vendor_rec_type;

    /* Variable Declaration for IBY */
    ext_payee_rec               IBY_DISBURSEMENT_SETUP_PUB.External_Payee_Rec_Type;
    ext_payee_tab               IBY_DISBURSEMENT_SETUP_PUB.External_Payee_Tab_Type;
    ext_payee_id_rec            IBY_DISBURSEMENT_SETUP_PUB.Ext_Payee_Id_Rec_Type;
    ext_payee_id_tab            IBY_DISBURSEMENT_SETUP_PUB.Ext_Payee_Id_Tab_Type;
    ext_payee_create_rec        IBY_DISBURSEMENT_SETUP_PUB.Ext_Payee_Create_Rec_Type;
    ext_payee_create_tab        IBY_DISBURSEMENT_SETUP_PUB.Ext_Payee_Create_Tab_Type;
    l_temp_ext_acct_id          NUMBER;
    ext_response_rec            IBY_FNDCPT_COMMON_PUB.Result_Rec_Type;

    l_ext_payee_id              NUMBER;
    l_bank_acct_id              NUMBER;

    CURSOR IBY_EXT_ACCTS_CUR (p_unique_ref IN NUMBER) IS
    SELECT temp_ext_bank_acct_id
    FROM IBY_TEMP_EXT_BANK_ACCTS
    WHERE calling_app_unique_ref1 = p_unique_ref
    --Bug 7412849 (Base Bug 7387700)  As status can be NULL, this where condition always resolves to FALSE.
    --Added NVL around 'status'.
    --AND status  <> 'PROCESSED';
    AND nvl(status,'NEW')  <> 'PROCESSED';

    l_debug_info                 varchar2(500); -- Bug 6823885
    l_rollback_vendor            varchar2(1) := 'N'; --Bug 8275512
    l_payee_msg_count           NUMBER; --Bug 7572325
    l_payee_msg_data            VARCHAR2(4000); --Bug 7572325
    l_error_code                VARCHAR2(4000); --Bug 7572325
    /* Added for bug#9204866 Start */
    l_unique                    VARCHAR2(1);
    l_vendor_id_vat             NUMBER;
    /* Added for bug#9204866 Start */
    /* Bug 9580651 - Variable to hold the value of the profile "Allow Suppliers with duplicated TP id". Value: Y or N */
    l_allow_dupe_taxpyr_id	varchar2(1) := 'N';

BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT   Import_Vendor_PUB;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    FND_MSG_PUB.initialize;

    g_user_id       := FND_GLOBAL.USER_ID;
    g_login_id      := FND_GLOBAL.LOGIN_ID;
    g_source        := p_source;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- API body

    IF g_source <> 'IMPORT' THEN
      NULL;
    ELSE

      --udhenuko Bug 6823885 This update statement resets the unprocessed rows so
      -- that they get picked in the current run.
      UPDATE Ap_Suppliers_Int api
      SET import_request_id = NULL
      WHERE import_request_id IS NOT NULL
        AND NVL(status,'NEW') IN ('NEW', 'REJECTED')
        AND EXISTS
                ( SELECT 'Request Completed'
                    FROM fnd_concurrent_requests fcr
                  WHERE fcr.request_id = api.import_request_id
                    AND fcr.phase_code = 'C' );
      -- udhenuko Bug 6823885 End
      --bug 5591652
      DELETE AP_SUPPLIER_INT_REJECTIONS
      WHERE PARENT_TABLE='AP_SUPPLIERS_INT';
      -- Updating Interface Record with request id

      UPDATE Ap_Suppliers_Int
      SET    import_request_id = l_request_id
      WHERE  import_request_id IS NULL AND
             ((p_what_to_import = 'ALL' AND nvl(status,'NEW') in ('NEW', 'REJECTED')) OR
             (p_what_to_import = 'NEW' AND nvl(status,'NEW') = 'NEW') OR
             (p_what_to_import = 'REJECTED' AND nvl(status,'NEW') = 'REJECTED'));

      COMMIT;

      SAVEPOINT   Import_Vendor_PUB; --Bug 8275512 incase there is an unexpected error in loop below,
                                     --the rollback in exception can happen to this savepoint, since
				     --after commit the savepoint set at the begining would be lost.

      -- Cursor processing for vendor contact interface record
      OPEN vendor_int_cur;
      LOOP

        FETCH vendor_int_cur
        INTO vendor_int_rec;
        EXIT WHEN vendor_int_cur%NOTFOUND;

        vendor_rec.vendor_interface_id          := vendor_int_rec.vendor_interface_id;
        vendor_rec.vendor_name                  := vendor_int_rec.vendor_name;
        vendor_rec.segment1                     := vendor_int_rec.segment1;
        vendor_rec.vendor_name_alt              := vendor_int_rec.vendor_name_alt;
        vendor_rec.summary_flag                 := vendor_int_rec.summary_flag;
        vendor_rec.enabled_flag                 := vendor_int_rec.enabled_flag;
        vendor_rec.employee_id                  := vendor_int_rec.employee_id;
        vendor_rec.vendor_type_lookup_code      := vendor_int_rec.vendor_type_lookup_code;
        vendor_rec.customer_num                 := vendor_int_rec.customer_num;
        vendor_rec.one_time_flag                := vendor_int_rec.one_time_flag;
        vendor_rec.min_order_amount             := vendor_int_rec.min_order_amount;
        vendor_rec.terms_id                     := vendor_int_rec.terms_id;
        vendor_rec.terms_name                   := vendor_int_rec.terms_name;
        vendor_rec.set_of_books_id              := vendor_int_rec.set_of_books_id;
        vendor_rec.always_take_disc_flag        := vendor_int_rec.always_take_disc_flag;
        vendor_rec.pay_date_basis_lookup_code   := vendor_int_rec.pay_date_basis_lookup_code;
        vendor_rec.pay_group_lookup_code        := vendor_int_rec.pay_group_lookup_code;
        vendor_rec.payment_priority             := vendor_int_rec.payment_priority;
        vendor_rec.invoice_currency_code        := vendor_int_rec.invoice_currency_code;
        vendor_rec.payment_currency_code        := vendor_int_rec.payment_currency_code;
        vendor_rec.invoice_amount_limit         := vendor_int_rec.invoice_amount_limit;
        vendor_rec.hold_all_payments_flag       := vendor_int_rec.hold_all_payments_flag;
        vendor_rec.hold_future_payments_flag    := vendor_int_rec.hold_future_payments_flag;
        vendor_rec.hold_reason                  := vendor_int_rec.hold_reason;

        /* Added for bug#7711402 Start */
        IF length(vendor_int_rec.num_1099) > 20 THEN

           UPDATE Ap_Suppliers_Int
              SET status = 'REJECTED'
            WHERE vendor_interface_id = vendor_int_rec.vendor_interface_id;

           IF ( Insert_Rejections(
                    'AP_SUPPLIERS_INT',
                    vendor_int_rec.vendor_interface_id,
                    'AP_INVALID_NUM_1099',
                    g_user_id,
                    g_login_id,
                    'Import_Vendor') <> TRUE
              )
           THEN
             --
             IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_MSG_PUB.Count_And_Get(
                      p_count   =>   l_msg_count,
                      p_data    =>   l_msg_data);
                FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                    l_api_name,'Parameters: '
                    ||' Vendor_Interface_Id:  '||vendor_int_rec.vendor_interface_id
                    ||' Vendor NUM_1099 : '||vendor_int_rec.num_1099);
             END IF;
           END IF;

           goto continue_next_record; /* Added for bug#bug#8539358 replaced continue with goto as continue is not there in 10g */
	   /* continue; Continue to next record, reject this record Commented for bug#8539358 */

        /* Added for bug#9204866 Start */
        ELSIF vendor_int_rec.num_1099 IS NOT NULL
        THEN

          l_vendor_id_vat  := NULL;

	  /* Bug 9580651 - Check whether the profile "Allow Suppliers with duplicated TP id" ("POS_ALLOW_SUPP_DUPE_TAXPYR_ID")
	  is set to
	  -Yes then continue creating supplier with duplicate Taxpayer Id.
	  -No then system will throw an error message and prevent supplier creation.
	  -POS (UI) implemented this thru bug 8819829 */

	  l_unique         := 'Y';  /* Bug 9580651 - assigned 'Y' instead of NULL */
          /* Bug 9580651 - Getting the value of the profile "Allow Suppliers with duplicated TP id" */
	  fnd_profile.get('POS_ALLOW_SUPP_DUPE_TAXPYR_ID',l_allow_dupe_taxpyr_id);
	  if (l_allow_dupe_taxpyr_id = 'N') then
		  pos_vendor_reg_pkg.is_taxpayer_id_unique
		  ( p_supp_regid   => -1
		  , p_taxpayer_id  => vendor_int_rec.num_1099
		  , p_country      => NULL
		  , x_is_unique    => l_unique
		  , x_vendor_id    => l_vendor_id_vat
		  );
	  end if;

          IF l_unique <> 'Y'
          THEN

            UPDATE Ap_Suppliers_Int
               SET status = 'REJECTED'
             WHERE vendor_interface_id = vendor_int_rec.vendor_interface_id;

            IF ( Insert_Rejections(
                    'AP_SUPPLIERS_INT',
                    vendor_int_rec.vendor_interface_id,
                    'POS_SPM_CREATE_SUPP_ERR2',
                    g_user_id,
                    g_login_id,
                    'Import_Vendor') <> TRUE
              )
            THEN
              --
              IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_MSG_PUB.Count_And_Get(
                      p_count   =>   l_msg_count,
                      p_data    =>   l_msg_data);

                 FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                    l_api_name,'Parameters: '
                    ||' Vendor_Interface_Id:  '||vendor_int_rec.vendor_interface_id
                    ||' Vendor num_1099 : '||vendor_int_rec.num_1099);
              END IF;
            END IF;
            goto continue_next_record; /* Added for bug#bug#8539358 replaced continue with goto as continue is not there in 10g */
            /* continue; Continue to next record, reject this record Commented for bug#8539358 */
          END IF;
          /* Added for bug#9204866 End */

        END IF; /* length > 20 check */
        /* Added for bug#7711402 End */

        vendor_rec.jgzz_fiscal_code             := vendor_int_rec.num_1099;--bug6050423
        vendor_rec.type_1099                    := vendor_int_rec.type_1099;
        vendor_rec.organization_type_lookup_code :=
                                         vendor_int_rec.organization_type_lookup_code;
        vendor_rec.start_date_active            := vendor_int_rec.start_date_active;
        vendor_rec.end_date_active              := vendor_int_rec.end_date_active;
        vendor_rec.minority_group_lookup_code   := vendor_int_rec.minority_group_lookup_code;
        vendor_rec.women_owned_flag             := vendor_int_rec.women_owned_flag;
        vendor_rec.small_business_flag          := vendor_int_rec.small_business_flag;
        vendor_rec.SIC_Code      		:= vendor_int_rec.standard_industry_class;
        vendor_rec.hold_flag                    := vendor_int_rec.hold_flag;
        vendor_rec.purchasing_hold_reason       := vendor_int_rec.purchasing_hold_reason;
        vendor_rec.hold_by                      := vendor_int_rec.hold_by;
        vendor_rec.hold_date                    := vendor_int_rec.hold_date;
        vendor_rec.terms_date_basis             := vendor_int_rec.terms_date_basis;
        vendor_rec.inspection_required_flag     := vendor_int_rec.inspection_required_flag;
        vendor_rec.receipt_required_flag        := vendor_int_rec.receipt_required_flag;
        vendor_rec.qty_rcv_tolerance            := vendor_int_rec.qty_rcv_tolerance;
        vendor_rec.qty_rcv_exception_code       := vendor_int_rec.qty_rcv_exception_code;
        vendor_rec.enforce_ship_to_location_code :=
                                         vendor_int_rec.enforce_ship_to_location_code;
        vendor_rec.days_early_receipt_allowed   := vendor_int_rec.days_early_receipt_allowed;
        vendor_rec.days_late_receipt_allowed    := vendor_int_rec.days_late_receipt_allowed;
        vendor_rec.receipt_days_exception_code := vendor_int_rec.receipt_days_exception_code;
        vendor_rec.receiving_routing_id         := vendor_int_rec.receiving_routing_id;
        vendor_rec.allow_substitute_receipts_flag :=
                                        vendor_int_rec.allow_substitute_receipts_flag;
        vendor_rec.allow_unordered_receipts_flag :=
                                        vendor_int_rec.allow_unordered_receipts_flag;
        vendor_rec.hold_unmatched_invoices_flag  :=
                                        vendor_int_rec.hold_unmatched_invoices_flag;
        vendor_rec.tax_verification_date        := vendor_int_rec.tax_verification_date;
        vendor_rec.name_control                 := vendor_int_rec.name_control;
        vendor_rec.state_reportable_flag        := vendor_int_rec.state_reportable_flag;
        vendor_rec.federal_reportable_flag      := vendor_int_rec.federal_reportable_flag;
        vendor_rec.attribute_category           := vendor_int_rec.attribute_category;
        vendor_rec.attribute1                   := vendor_int_rec.attribute1;
        vendor_rec.attribute2                   := vendor_int_rec.attribute2;
        vendor_rec.attribute3                   := vendor_int_rec.attribute3;
        vendor_rec.attribute4                   := vendor_int_rec.attribute4;
        vendor_rec.attribute5                   := vendor_int_rec.attribute5;
        vendor_rec.attribute6                   := vendor_int_rec.attribute6;
        vendor_rec.attribute7                   := vendor_int_rec.attribute7;
        vendor_rec.attribute8                   := vendor_int_rec.attribute8;
        vendor_rec.attribute9                   := vendor_int_rec.attribute9;
        vendor_rec.attribute10                  := vendor_int_rec.attribute10;
        vendor_rec.attribute11                  := vendor_int_rec.attribute11;
        vendor_rec.attribute12                  := vendor_int_rec.attribute12;
        vendor_rec.attribute13                  := vendor_int_rec.attribute13;
        vendor_rec.attribute14                  := vendor_int_rec.attribute14;
        vendor_rec.attribute15                  := vendor_int_rec.attribute15;
        vendor_rec.auto_calculate_interest_flag :=
                                       vendor_int_rec.auto_calculate_interest_flag;
        vendor_rec.exclude_freight_from_discount :=
                                       vendor_int_rec.exclude_freight_from_discount;
        vendor_rec.tax_reporting_name           := vendor_int_rec.tax_reporting_name;
        vendor_rec.allow_awt_flag               := vendor_int_rec.allow_awt_flag;
        vendor_rec.awt_group_id                 := vendor_int_rec.awt_group_id;
        vendor_rec.awt_group_name               := vendor_int_rec.awt_group_name;
        vendor_rec.pay_awt_group_id             := vendor_int_rec.pay_awt_group_id;/*Bug9589179 */
        vendor_rec.pay_awt_group_name            := vendor_int_rec.pay_awt_group_name;/*Bug9589179 */
        vendor_rec.global_attribute1            := vendor_int_rec.global_attribute1;
        vendor_rec.global_attribute2            := vendor_int_rec.global_attribute2;
        vendor_rec.global_attribute3            := vendor_int_rec.global_attribute3;
        vendor_rec.global_attribute4            := vendor_int_rec.global_attribute4;
        vendor_rec.global_attribute5            := vendor_int_rec.global_attribute5;
        vendor_rec.global_attribute6            := vendor_int_rec.global_attribute6;
        vendor_rec.global_attribute7            := vendor_int_rec.global_attribute7;
        vendor_rec.global_attribute8            := vendor_int_rec.global_attribute8;
        vendor_rec.global_attribute9            := vendor_int_rec.global_attribute9;
        vendor_rec.global_attribute10           := vendor_int_rec.global_attribute10;
        vendor_rec.global_attribute11           := vendor_int_rec.global_attribute11;
        vendor_rec.global_attribute12           := vendor_int_rec.global_attribute12;
        vendor_rec.global_attribute13           := vendor_int_rec.global_attribute13;
        vendor_rec.global_attribute14           := vendor_int_rec.global_attribute14;
        vendor_rec.global_attribute15           := vendor_int_rec.global_attribute15;
        vendor_rec.global_attribute16           := vendor_int_rec.global_attribute16;
        vendor_rec.global_attribute17           := vendor_int_rec.global_attribute17;
        vendor_rec.global_attribute18           := vendor_int_rec.global_attribute18;
        vendor_rec.global_attribute19           := vendor_int_rec.global_attribute19;
        vendor_rec.global_attribute20           := vendor_int_rec.global_attribute20;
        vendor_rec.global_attribute_category    := vendor_int_rec.global_attribute_category;
        vendor_rec.bank_charge_bearer           := vendor_int_rec.bank_charge_bearer;
        vendor_rec.match_option                 := vendor_int_rec.match_option;
        vendor_rec.create_debit_memo_flag       := vendor_int_rec.create_debit_memo_flag;

        /* Added for bug#9204866 Start */
        IF vendor_int_rec.vat_registration_num IS NOT NULL
        THEN

          l_vendor_id_vat  := NULL;
          l_unique         := NULL;
          pos_vendor_reg_pkg.is_taxregnum_unique
          ( p_supp_regid     => -1
          , p_taxreg_num     => vendor_int_rec.vat_registration_num
          , p_country        => null
          , x_is_unique      => l_unique
          , x_vendor_id      => l_vendor_id_vat
          );

          IF l_unique <> 'Y'
          THEN

            UPDATE Ap_Suppliers_Int
               SET status = 'REJECTED'
             WHERE vendor_interface_id = vendor_int_rec.vendor_interface_id;

            IF ( Insert_Rejections(
                    'AP_SUPPLIERS_INT',
                    vendor_int_rec.vendor_interface_id,
                    'POS_SPM_CREATE_SUPP_ERR1',
                    g_user_id,
                    g_login_id,
                    'Import_Vendor') <> TRUE
              )
            THEN
              --
              IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_MSG_PUB.Count_And_Get(
                      p_count   =>   l_msg_count,
                      p_data    =>   l_msg_data);

                 FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                    l_api_name,'Parameters: '
                    ||' Vendor_Interface_Id:  '||vendor_int_rec.vendor_interface_id
                    ||' Vendor vat_registration_num : '||vendor_int_rec.vat_registration_num);
              END IF;
            END IF;
            goto continue_next_record; /* Added for bug#bug#8539358 replaced continue with goto as continue is not there in 10g */
            /* continue; Continue to next record, reject this record Commented for bug#8539358 */
          END IF;
        END IF;
        /* Added for bug#9204866 End */

        vendor_rec.tax_reference                := vendor_int_rec.vat_registration_num;   --bug6070735
        vendor_rec.url				:= vendor_int_rec.url ;   -- B# 7831956

        vendor_rec.vat_code			:= vendor_int_rec.vat_code ;   -- B# 9202909
        vendor_rec.auto_tax_calc_flag		:= vendor_int_rec.auto_tax_calc_flag ;--B#9202909
        vendor_rec.offset_tax_flag		:= vendor_int_rec.offset_tax_flag ; --B#9202909
        vendor_rec.vat_registration_num         := vendor_int_rec.vat_registration_num ; --B#9202909

        /* Populating IBY Records and Table */
        -- As per the discussion with Omar/Jayanta, we will only
        -- have payables payment function and no more employee expenses
        -- payment function.

        ext_payee_rec.payment_function        := 'PAYABLES_DISB';
       -- ext_payee_rec.payer_org_type            := 'OPERATING_UNIT'; --bug7583123
        ext_payee_rec.exclusive_pay_flag        :=NVL(vendor_int_rec.exclusive_payment_flag,'N');
        --bug6495364
--CD
        ext_payee_rec.default_pmt_method        := vendor_int_rec.payment_method_lookup_code;
        ext_payee_rec.ece_tp_loc_code           := vendor_int_rec.ece_tp_location_code;
        ext_payee_rec.bank_charge_bearer        := vendor_int_rec.iby_bank_charge_bearer;
        ext_payee_rec.bank_instr1_code          := vendor_int_rec.bank_instruction1_code;
        ext_payee_rec.bank_instr2_code          := vendor_int_rec.bank_instruction2_code;
        ext_payee_rec.bank_instr_detail         := vendor_int_rec.bank_instruction_details;
        ext_payee_rec.pay_reason_code           := vendor_int_rec.payment_reason_code;
        ext_payee_rec.pay_reason_com            := vendor_int_rec.payment_reason_comments;
        ext_payee_rec.pay_message1              := vendor_int_rec.payment_text_message1;
        ext_payee_rec.pay_message2              := vendor_int_rec.payment_text_message2;
        ext_payee_rec.pay_message3              := vendor_int_rec.payment_text_message3;
        ext_payee_rec.delivery_channel          := vendor_int_rec.delivery_channel_code;
        ext_payee_rec.pmt_format                := vendor_int_rec.payment_format_code;
        ext_payee_rec.settlement_priority       := vendor_int_rec.settlement_priority;
	-- Bug 7437549 Start
        -- Note that we must populate these EDI related fields only to ext_payee_rec
        -- Because only this record is passed for call to IBY. There is no need
        -- to populate vendor_rec.ext_payee_rec. Even if we pass it wont be used.
        ext_payee_rec.edi_payment_format         := vendor_int_rec.edi_payment_format;
        ext_payee_rec.edi_transaction_handling   := vendor_int_rec.edi_transaction_handling;
        ext_payee_rec.edi_payment_method         := vendor_int_rec.edi_payment_method;
        ext_payee_rec.edi_remittance_method      := vendor_int_rec.edi_remittance_method;
        ext_payee_rec.edi_remittance_instruction := vendor_int_rec.edi_remittance_instruction;
        -- Bug 7437549 End
	--Bug 7583123
       ext_payee_rec.remit_advice_delivery_method     := vendor_int_rec.supplier_notif_method;
       ext_payee_rec.remit_advice_email               := vendor_int_rec.remittance_email;

        --bug 8222964
       ext_payee_rec.remit_advice_fax             := vendor_int_rec.remit_advice_fax;

	--6458813 Populating the ext_payee_rec of Vendor_rec
	vendor_rec.ext_payee_rec.default_pmt_method        := vendor_int_rec.payment_method_lookup_code;
        --bug6495364
        vendor_rec.ext_payee_rec.payment_function          := 'PAYABLES_DISB';
        vendor_rec.ext_payee_rec.payer_org_type            := 'OPERATING_UNIT';
        vendor_rec.ext_payee_rec.exclusive_pay_flag        := nvl(vendor_int_rec.exclusive_payment_flag,'N');
        vendor_rec.ext_payee_rec.ece_tp_loc_code           := vendor_int_rec.ece_tp_location_code;
        vendor_rec.ext_payee_rec.bank_charge_bearer        := vendor_int_rec.iby_bank_charge_bearer;
        vendor_rec.ext_payee_rec.bank_instr1_code          := vendor_int_rec.bank_instruction1_code;
        vendor_rec.ext_payee_rec.bank_instr2_code          := vendor_int_rec.bank_instruction2_code;
        vendor_rec.ext_payee_rec.bank_instr_detail         := vendor_int_rec.bank_instruction_details;
        vendor_rec.ext_payee_rec.pay_reason_code           := vendor_int_rec.payment_reason_code;
        vendor_rec.ext_payee_rec.pay_reason_com            := vendor_int_rec.payment_reason_comments;
        vendor_rec.ext_payee_rec.pay_message1              := vendor_int_rec.payment_text_message1;
        vendor_rec.ext_payee_rec.pay_message2              := vendor_int_rec.payment_text_message2;
        vendor_rec.ext_payee_rec.pay_message3              := vendor_int_rec.payment_text_message3;
        vendor_rec.ext_payee_rec.delivery_channel          := vendor_int_rec.delivery_channel_code;
        vendor_rec.ext_payee_rec.pmt_format                := vendor_int_rec.payment_format_code;
        vendor_rec.ext_payee_rec.settlement_priority       := vendor_int_rec.settlement_priority;
		-- 6458813 ends

	-- bug 8222964
	vendor_rec.ext_payee_rec.remit_advice_fax          := vendor_int_rec.remit_advice_fax;

        -- B# 7583123
        vendor_rec.supplier_notif_method	:= vendor_int_rec.supplier_notif_method;
        vendor_rec.remittance_email 	:= vendor_int_rec.remittance_email;


        vendor_rec.ceo_name	:= vendor_int_rec.ceo_name ;  -- B 9081643
        vendor_rec.ceo_title 	:= vendor_int_rec.ceo_title ;  -- B 9081643


        /*bug 8275512 begin: As per the bug requirement and PM inputs it was
       decided to reject supplier creation when user is importing
       supplier with bank account and the related bank account record
       fails validation. To implement this, creating a save point before
       vendor creation looked the most feasible approach and also avoid
       fetch out of sequence error. If related bank
       fails validation we shall rollback to this savepoint and update
       the supplier record as "REJECTED" and insert a record into Rejection
       table and thereafter commit the work.*/

        SAVEPOINT   Import_Vendor_PUB2;
      /*bug 8275512 end*/

        Create_Vendor
          ( p_api_version       =>  1.0,
            p_init_msg_list     =>  FND_API.G_FALSE,
            p_commit            =>  FND_API.G_FALSE,
            p_validation_level  =>  FND_API.G_VALID_LEVEL_FULL,
            x_return_status     =>  l_return_status,
            x_msg_count         =>  l_msg_count,
            x_msg_data          =>  l_msg_data,
            p_vendor_rec        =>  vendor_rec,
            x_vendor_id         =>  l_vendor_id,
            x_party_id          =>  l_party_id);

        IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

          UPDATE Ap_Suppliers_Int
          SET    status = 'PROCESSED'
          WHERE  vendor_interface_id = vendor_rec.vendor_interface_id;

          UPDATE Ap_Supplier_Sites_Int
          SET    vendor_id = l_vendor_id
          WHERE  vendor_interface_id = vendor_rec.vendor_interface_id;

          UPDATE Ap_Sup_Site_Contact_Int
          SET    vendor_id = l_vendor_id
          WHERE  vendor_interface_id = vendor_rec.vendor_interface_id;

          ext_payee_rec.payee_party_id         := l_party_id;

	  /*Bug 7572325- added the call to count_and_get to get the count
          before call to IBY API in local variable*/
          FND_MSG_PUB.Count_And_Get(p_count => l_payee_msg_count,
                                    p_data => l_payee_msg_data);

          /* Calling IBY Payee Validation API */
          IBY_DISBURSEMENT_SETUP_PUB.Validate_External_Payee
            ( p_api_version     => 1.0,
              p_init_msg_list   => FND_API.G_FALSE,
              p_ext_payee_rec   => ext_payee_rec,
              x_return_status   => l_return_status,
              x_msg_count       => l_msg_count,
              x_msg_data        => l_msg_data);

          IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

            --bug 5568861 ext_payee_tab(ext_payee_tab.first)      := ext_payee_rec;
            ext_payee_tab(1)      := ext_payee_rec;

           /*Calling IBY Payee Creation API */
            IBY_DISBURSEMENT_SETUP_PUB.Create_External_Payee
              ( p_api_version         => 1.0,
                p_init_msg_list       => FND_API.G_FALSE,
                p_ext_payee_tab       => ext_payee_tab,
                x_return_status       => l_return_status,
                x_msg_count           => l_msg_count,
                x_msg_data            => l_msg_data,
                x_ext_payee_id_tab    => ext_payee_id_tab,
                x_ext_payee_status_tab => ext_payee_create_tab);

            IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
              --bug 5568861
              l_ext_payee_id     := ext_payee_id_tab(1).ext_payee_id;

              UPDATE IBY_TEMP_EXT_BANK_ACCTS
              SET ext_payee_id = l_ext_payee_id
                 ,account_owner_party_id = l_party_id -- bug 6753331
              WHERE calling_app_unique_ref1 = vendor_rec.vendor_interface_id;

              -- Cursor processing for iby temp bank account record
              OPEN iby_ext_accts_cur(vendor_rec.vendor_interface_id);
              LOOP

                FETCH iby_ext_accts_cur
                INTO l_temp_ext_acct_id;
                EXIT WHEN iby_ext_accts_cur%NOTFOUND;
--Commenting for Bug 9012321
                /* Calling IBY Bank Account Validation API */
           /*     IBY_DISBURSEMENT_SETUP_PUB.Validate_Temp_Ext_Bank_Acct
                 ( p_api_version         => 1.0,
                   p_init_msg_list       => FND_API.G_FALSE,
                   x_return_status       => l_return_status,
                   x_msg_count           => l_msg_count,
                   x_msg_data            => l_msg_data,
                   p_temp_ext_acct_id    => l_temp_ext_acct_id);

                IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN */--Commenting for Bug 9012321
                  /* Calling IBY Bank Account Creation API */
                  -- Bug 6845995. Calling overloaded procedure
                  -- which will create the association between
                  -- supplier and bank account.
                  IBY_DISBURSEMENT_SETUP_PUB.Create_Temp_Ext_Bank_Acct
                   ( p_api_version         => 1.0,
                     p_init_msg_list       => FND_API.G_FALSE,
                     x_return_status       => l_return_status,
                     x_msg_count           => l_msg_count,
                     x_msg_data            => l_msg_data,
                     p_temp_ext_acct_id    => l_temp_ext_acct_id,
                     p_association_level   => 'S',
                     p_supplier_site_id    => null,
                     p_party_site_id       => null,
                     p_org_id              => null,
                     p_org_type            => null, -- veramach added p_org_type as a new paramter for bug 7153777
                     x_bank_acc_id         => l_bank_acct_id,
                     x_response            => ext_response_rec);

                  IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                    UPDATE iby_temp_ext_bank_accts
                    SET status = 'PROCESSED'
                    WHERE temp_ext_bank_acct_id = l_temp_ext_acct_id;

                  ELSE
                    --bug 8275512 moved the below code after cursor iby_ext_accts_cur close
                    /*UPDATE iby_temp_ext_bank_accts
                       SET status = 'REJECTED'
                      WHERE temp_ext_bank_acct_id = l_temp_ext_acct_id;

                    IF (Insert_Rejections(
                      'IBY_TEMP_EXT_BANK_ACCTS',
                       vendor_rec.vendor_interface_id,
                      'AP_BANK_ACCT_CREATION',
                      g_user_id,
                      g_login_id,
                      'Import_Vendor') <> TRUE) THEN
                     --
                      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_MSG_PUB.Count_And_Get(
                          p_count   =>   l_msg_count,
                          p_data    =>   l_msg_data);
                        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                          l_api_name,'Parameters: '
                          ||' Vendor_Interface_Id: '||vendor_rec.vendor_interface_id
                          ||' Acct Validation Msg: '||l_msg_data);
                      END IF;
                    END IF;*/

                        l_rollback_vendor := 'Y'; --bug 8275512

                        -- Bug 5491139 hkaniven start --
                        FND_MESSAGE.SET_NAME('SQLAP','AP_BANK_ACCT_CREATION');
                        FND_MSG_PUB.ADD;
                        -- Bug 5491139 hkaniven end --
                  END IF;    -- Bank Account Creation API
--Commenting for Bug9012321
             /*  ELSE
                  --bug 8275512 moved the below code after cursor iby_ext_accts_cur close
                  UPDATE iby_temp_ext_bank_accts
                    SET status = 'REJECTED'
                   WHERE temp_ext_bank_acct_id = l_temp_ext_acct_id;

                  IF (Insert_Rejections(
                    'IBY_TEMP_EXT_BANK_ACCTS',
                    vendor_rec.vendor_interface_id,
                    'AP_INVALID_BANK_ACCT_INFO',
                    g_user_id,
                    g_login_id,
                    'Import_Vendor') <> TRUE) THEN
                   --
                    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_MSG_PUB.Count_And_Get(
                        p_count   =>   l_msg_count,
                        p_data    =>   l_msg_data);
                      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                        l_api_name,'Parameters: '
                        ||' Vendor_Interface_Id: '||vendor_rec.vendor_interface_id
                        ||' Acct Validation Msg: '||l_msg_data);
                    END IF;
                  END IF;

                    l_rollback_vendor := 'Y'; --bug 8275512

                    -- Bug 5491139 hkaniven start --
                    FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_BANK_ACCT_INFO');
                    FND_MSG_PUB.ADD;
                    -- Bug 5491139 hkaniven end --
                END IF;  -- Bank Account Validation API  */ --Commenting for Bug 9012321

              END LOOP;
              CLOSE iby_ext_accts_cur;

	      /*Bug 8275512 begin -- rollback if bank account creation fails*/
	        If l_rollback_vendor = 'Y' then

                  ROLLBACK TO Import_Vendor_PUB2;

                  UPDATE Ap_Suppliers_Int
                    SET    status = 'REJECTED'
                  WHERE  vendor_interface_id = vendor_rec.vendor_interface_id;

                  UPDATE iby_temp_ext_bank_accts
                  SET status = 'REJECTED'
                  WHERE temp_ext_bank_acct_id = l_temp_ext_acct_id;

                  -- Bug 9259355 Start
                 fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                           p_count => l_msg_count,
                                           p_data  => l_msg_data);

                 IF ( NVL(l_msg_count, 0) > 1 ) THEN

                    FOR i IN 1..l_msg_count
                    LOOP
                    l_msg_data := FND_MSG_PUB.Get(p_msg_index => i, p_encoded => 'F');

                    IF (FND_GLOBAL.conc_request_id = -1) THEN
                    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                        l_api_name,'Parameters: '
                        ||' Vendor_Interface_Id: '||vendor_rec.vendor_interface_id
                        ||' Acct Validation Msg: '||l_msg_data);
                    END IF;
                    ELSE
                    AP_IMPORT_UTILITIES_PKG.Print('Y', l_api_name ||': '|| l_msg_data);
                    END IF;

                    END LOOP;

                 ELSIF (l_msg_data is not null) THEN

                    IF (FND_GLOBAL.conc_request_id = -1) THEN
                    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                        l_api_name,'Parameters: '
                        ||' Vendor_Interface_Id: '||vendor_rec.vendor_interface_id
                        ||' Acct Validation Msg: '||l_msg_data);
                    END IF;
                    ELSE
                    AP_IMPORT_UTILITIES_PKG.Print('Y', l_api_name ||': '|| l_msg_data);
                    END IF;

                 END IF;
                 -- Bug 9259355 End

                  IF (Insert_Rejections(
                    --'IBY_TEMP_EXT_BANK_ACCTS',
                    'AP_SUPPLIERS_INT', --bug 8275512
                    vendor_rec.vendor_interface_id,
                    'AP_INVALID_BANK_ACCT_INFO',
                    g_user_id,
                    g_login_id,
                    'Import_Vendor') <> TRUE) THEN
                   --
                    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_MSG_PUB.Count_And_Get(
                        p_count   =>   l_msg_count,
                        p_data    =>   l_msg_data);
                      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                        l_api_name,'Parameters: '
                        ||' Vendor_Interface_Id: '||vendor_rec.vendor_interface_id
                        ||' Acct Validation Msg: '||l_msg_data);
                    END IF;
                  END IF;

		   l_rollback_vendor := 'N'; --resetting the value to initial
                 END IF;
                  /*Bug 8275512 end*/
            ELSE
              IF (Insert_Rejections(
                    'AP_SUPPLIERS_INT',
                    vendor_rec.vendor_interface_id,
                    'AP_PAYEE_CREATION',
                    g_user_id,
                    g_login_id,
                    'Import_Vendor') <> TRUE) THEN
               --
                IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_MSG_PUB.Count_And_Get(
                    p_count   =>   l_msg_count,
                    p_data    =>   l_msg_data);
                  FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                    l_api_name,'Parameters: '
                    ||' Vendor_Interface_Id: '||vendor_rec.vendor_interface_id
                    ||' Payee Validation Msg: '||l_msg_data);
                END IF;
              END IF;

                -- Bug 5491139 hkaniven start --
                FND_MESSAGE.SET_NAME('SQLAP','AP_PAYEE_CREATION');
                FND_MSG_PUB.ADD;
                -- Bug 5491139 hkaniven end --
            END IF;   -- Payee Creation API

          ELSE
                  -- Bug 9259355 Start
                 fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                           p_count => l_msg_count,
                                           p_data  => l_msg_data);

                 IF ( NVL(l_msg_count, 0) > 1 ) THEN

                    FOR i IN 1..l_msg_count
                    LOOP
                    l_msg_data := FND_MSG_PUB.Get(p_msg_index => i, p_encoded => 'F');

                    IF (FND_GLOBAL.conc_request_id = -1) THEN
                    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                        l_api_name,'Parameters: '
                        ||' Vendor_Interface_Id: '||vendor_rec.vendor_interface_id
                        ||' Acct Validation Msg: '||l_msg_data);
                    END IF;
                    ELSE
                    AP_IMPORT_UTILITIES_PKG.Print('Y', l_api_name ||': '|| l_msg_data);
                    END IF;

                    END LOOP;

                 ELSIF (l_msg_data is not null) THEN

                    IF (FND_GLOBAL.conc_request_id = -1) THEN
                    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                        l_api_name,'Parameters: '
                        ||' Vendor_Interface_Id: '||vendor_rec.vendor_interface_id
                        ||' Acct Validation Msg: '||l_msg_data);
                    END IF;
                    ELSE
                    AP_IMPORT_UTILITIES_PKG.Print('Y', l_api_name ||': '|| l_msg_data);
                    END IF;

                 END IF;
                 -- Bug 9259355 End

            IF (Insert_Rejections(
                    'AP_SUPPLIERS_INT',
                    vendor_rec.vendor_interface_id,
                    --'AP_INVALID_PAYEE',
                    'AP_INVALID_PAYEE_INFO',/*bug 7572325*/
                    g_user_id,
                    g_login_id,
                    'Import_Vendor') <> TRUE) THEN
           --
              IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_MSG_PUB.Count_And_Get(
                  p_count   =>   l_msg_count,
                  p_data    =>   l_msg_data);
                FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                   l_api_name,'Parameters: '
                   ||' Vendor_Interface_Id: '||vendor_rec.vendor_interface_id
                   ||' Payee Validation Msg: '||l_msg_data);
              END IF;
            END IF;

	           --bug 7572325 addded below file logging for improved exception
                   --message handling
                   l_debug_info := 'Calling IBY Payee Validation API in import';
                    IF (l_msg_data IS NOT NULL) THEN
                     -- Print the error returned from the IBY service even if the debug
                     -- mode is off
                      AP_IMPORT_UTILITIES_PKG.Print('Y', '3)Error in '||l_debug_info||
                                                    '---------------------->'||
                                                    l_msg_data);

                    ELSE
                      -- If the l_msg_data is null then the IBY service returned
                      -- more than one error.  The calling module will need to get
                      -- them from the message stack
                     FOR i IN l_payee_msg_count..l_msg_count
                      LOOP
                       l_error_code := FND_MSG_PUB.Get(p_msg_index => i,
                                                       p_encoded => 'F');

                        If i = l_payee_msg_count then
                          l_error_code := '3)Error in '||l_debug_info||
                                                    '---------------------->'||
                                                    l_error_code;
                        end if;

                        AP_IMPORT_UTILITIES_PKG.Print('Y', l_error_code);

                      END LOOP;

                     END IF;--bug 7572325

            -- Bug 5491139 hkaniven start --
            --FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_PAYEE'); --bug 7572325
	    FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_PAYEE_INFO'); --bug 7572325
            FND_MSG_PUB.ADD;
            -- Bug 5491139 hkaniven end --
          END IF;  -- Payee Validation API

        ELSE

          UPDATE Ap_Suppliers_Int
          SET    status = 'REJECTED'
          WHERE  vendor_interface_id = vendor_rec.vendor_interface_id;

          IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
             ' Rejected Vendor_Interface_Id: '
             ||vendor_rec.vendor_interface_id
             ||', No. of Messages from Create_Vendor API: '|| l_msg_count
             ||', Message From Create_Vendor API: '||l_msg_data);
          END IF;

        END IF;  -- Supplier Creation API
        <<continue_next_record>> NULL; /* Added for bug#8539358 */
      END LOOP;

      CLOSE vendor_int_cur;

    END IF;
    -- End of API body.

    COMMIT WORK;

    -- Standard call to get message count and if count is 1,
    -- get message info.
    FND_MSG_PUB.Count_And_Get(
        p_count                 =>      x_msg_count,
        p_data                  =>      x_msg_data
        );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Import_Vendor_PUB;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      x_msg_count,
                        p_data                  =>      x_msg_data
                );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Import_Vendor_PUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      x_msg_count,
                        p_data                  =>      x_msg_data
                );
  WHEN OTHERS THEN
    ROLLBACK TO Import_Vendor_PUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level
         (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg
                        (       G_PKG_NAME,
                                l_api_name
                        );
    END IF;
    FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      x_msg_count,
                        p_data                  =>      x_msg_data
                );
END Import_Vendors;

PROCEDURE Import_Vendor_Sites
(       p_api_version           IN      NUMBER,
        p_source                IN      VARCHAR2 DEFAULT 'IMPORT',
        p_what_to_import        IN      VARCHAR2 DEFAULT NULL,
        p_commit_size           IN      NUMBER   DEFAULT 1000,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2
)
IS

    l_api_name                  CONSTANT VARCHAR2(30)   := 'Import_Vendor_Sites';
    l_api_version               CONSTANT NUMBER         := 1.0;

    l_program_application_id    NUMBER  := FND_GLOBAL.prog_appl_id;
    l_program_id                NUMBER  := FND_GLOBAL.conc_program_id;
    l_request_id                NUMBER  := FND_GLOBAL.conc_request_id;

    l_return_status             VARCHAR2(2000);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);
    l_vendor_site_id            NUMBER;
    l_party_site_id             NUMBER;
    l_location_id               NUMBER;

    CURSOR site_int_cur IS
    SELECT *
    FROM Ap_Supplier_Sites_Int
    WHERE import_request_id = l_request_id
    AND  (org_id IS NOT NULL OR operating_unit_name IS NOT NULL)
    AND vendor_id IS NOT NULL;

    site_int_rec               site_int_cur%ROWTYPE;
    site_rec                   r_vendor_site_rec_type;

    /* Variable Declaration for IBY */
    ext_payee_rec               IBY_DISBURSEMENT_SETUP_PUB.External_Payee_Rec_Type;
    ext_payee_tab               IBY_DISBURSEMENT_SETUP_PUB.External_Payee_Tab_Type;
    ext_payee_id_rec            IBY_DISBURSEMENT_SETUP_PUB.Ext_Payee_Id_Rec_Type;
    ext_payee_id_tab            IBY_DISBURSEMENT_SETUP_PUB.Ext_Payee_Id_Tab_Type;
    ext_payee_create_rec        IBY_DISBURSEMENT_SETUP_PUB.Ext_Payee_Create_Rec_Type;
    ext_payee_create_tab        IBY_DISBURSEMENT_SETUP_PUB.Ext_Payee_Create_Tab_Type;
    l_temp_ext_acct_id          NUMBER;
    ext_response_rec            IBY_FNDCPT_COMMON_PUB.Result_Rec_Type;

    l_party_id                  NUMBER;
    l_ext_payee_id              NUMBER;
    l_bank_acct_id              NUMBER;

    CURSOR IBY_EXT_ACCTS_CUR (p_unique_ref IN NUMBER) IS
    SELECT temp_ext_bank_acct_id
    FROM IBY_TEMP_EXT_BANK_ACCTS
    WHERE calling_app_unique_ref2 = p_unique_ref
    --Bug 7412849 (Base Bug 7387700)  As status can be NULL, this where condition always resolves to FALSE.
    --Added NVL around 'status'.
    --AND status  <> 'PROCESSED';
    AND nvl(status,'NEW')  <> 'PROCESSED';

    l_debug_info                 varchar2(500); -- Bug 6823885
    l_rollback_vendor_site       varchar2(1) := 'N'; --Bug 8275512
    l_payee_msg_count           NUMBER; --Bug 7572325
    l_payee_msg_data            VARCHAR2(4000); --Bug 7572325
    l_error_code                VARCHAR2(4000); --Bug 7572325
BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT   Import_Vendor_Sites_PUB;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    FND_MSG_PUB.initialize;

    g_user_id       := FND_GLOBAL.USER_ID;
    g_login_id      := FND_GLOBAL.LOGIN_ID;
    g_source        := p_source;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- API body

    IF g_source <> 'IMPORT' THEN
     NULL;
    ELSE
      --udhenuko Bug 6823885 This update statement resets the unprocessed rows so
      -- that they get picked in the current run.
      UPDATE Ap_Supplier_Sites_Int api
      SET import_request_id = NULL
      WHERE import_request_id IS NOT NULL
        AND NVL(status,'NEW') IN ('NEW', 'REJECTED')
        AND EXISTS
                ( SELECT 'Request Completed'
                    FROM fnd_concurrent_requests fcr
                  WHERE fcr.request_id = api.import_request_id
                    AND fcr.phase_code = 'C' );
      -- udhenuko Bug 6823885 End
      --bug 5584046
      DELETE AP_SUPPLIER_INT_REJECTIONS
      WHERE PARENT_TABLE='AP_SUPPLIER_SITES_INT';

      -- Updating Interface Record with request id


      UPDATE Ap_Supplier_Sites_Int
      SET    import_request_id = l_request_id
      WHERE  import_request_id IS NULL AND
             ((p_what_to_import = 'ALL' AND nvl(status,'NEW') in ('NEW', 'REJECTED')) OR
             (p_what_to_import = 'NEW' AND nvl(status,'NEW') = 'NEW') OR
             (p_what_to_import = 'REJECTED' AND nvl(status,'NEW') = 'REJECTED'));

      UPDATE Ap_Supplier_Sites_Int
      SET    status = 'REJECTED',
             import_request_id = l_request_id
      WHERE  (operating_unit_name IS NULL AND org_id IS NULL) OR
             vendor_id IS NULL ;

      --bug 5584046
      INSERT INTO Ap_Supplier_Int_Rejections
      (SELECT 'AP_SUPPLIER_SITES_INT',vendor_site_interface_id,'AP_ORG_INFO_NULL',
              g_user_id,SYSDATE,g_login_id,g_user_id,SYSDATE
      FROM   Ap_Supplier_Sites_Int
      WHERE  STATUS='REJECTED'
      AND    import_request_id=l_request_id
      AND    (operating_unit_name IS NULL and org_id IS NULL))
      UNION
      select 'AP_SUPPLIER_SITES_INT',vendor_site_interface_id,'AP_VENDOR_ID_NULL',
             g_user_id,SYSDATE,g_login_id,g_user_id,SYSDATE
      from   Ap_Supplier_Sites_Int
      where status='REJECTED'
      AND import_request_id=l_request_id
      AND vendor_id IS NULL;
      --bug 5584046
      COMMIT;

      SAVEPOINT   Import_Vendor_Sites_PUB; --Bug 8275512 incase there is an unexpected error in loop below,
                                           --the rollback in exception can happen to this savepoint, since
				           --after commit the savepoint set at the begining would be lost.

      -- Cursor processing for vendor contact interface record
      OPEN site_int_cur;
      LOOP

        FETCH site_int_cur
        INTO site_int_rec;
        EXIT WHEN site_int_cur%NOTFOUND;

        site_rec.vendor_site_interface_id     := site_int_rec.vendor_site_interface_id;
        site_rec.vendor_interface_id          := site_int_rec.vendor_interface_id;
        site_rec.vendor_id                    := site_int_rec.vendor_id;
        site_rec.vendor_site_code             := site_int_rec.vendor_site_code;
        site_rec.vendor_site_code_alt         := site_int_rec.vendor_site_code_alt;
        site_rec.purchasing_site_flag         := site_int_rec.purchasing_site_flag;
        site_rec.rfq_only_site_flag           := site_int_rec.rfq_only_site_flag;
        site_rec.pay_site_flag                := site_int_rec.pay_site_flag;
        site_rec.attention_ar_flag            := site_int_rec.attention_ar_flag;
       /* Bug 6620831. Trimming Trailing Spaces for address related fields */
        site_rec.address_line1                := rtrim(site_int_rec.address_line1);
        site_rec.address_lines_alt            := rtrim(site_int_rec.address_lines_alt);
        site_rec.address_line2                := rtrim(site_int_rec.address_line2);
        site_rec.address_line3                := rtrim(site_int_rec.address_line3);
        site_rec.city                         := rtrim(site_int_rec.city);
        site_rec.state                        := rtrim(site_int_rec.state);
        site_rec.zip                          := site_int_rec.zip;
        site_rec.province                     := site_int_rec.province;
        site_rec.country                      := site_int_rec.country;
        site_rec.phone                        := site_int_rec.phone;
        site_rec.area_code                    := site_int_rec.area_code;
        site_rec.customer_num                 := site_int_rec.customer_num;
        site_rec.ship_to_location_id          := site_int_rec.ship_to_location_id;
        site_rec.ship_to_location_code        := site_int_rec.ship_to_location_code;
        site_rec.bill_to_location_id          := site_int_rec.bill_to_location_id;
        site_rec.bill_to_location_code        := site_int_rec.bill_to_location_code;
        site_rec.ship_via_lookup_code         := site_int_rec.ship_via_lookup_code;
        site_rec.freight_terms_lookup_code    := site_int_rec.freight_terms_lookup_code;
        site_rec.fob_lookup_code              := site_int_rec.fob_lookup_code;
        site_rec.inactive_date                := site_int_rec.inactive_date;
        site_rec.fax                          := site_int_rec.fax;
        site_rec.fax_area_code                := site_int_rec.fax_area_code;
        site_rec.telex                        := site_int_rec.telex;
        site_rec.terms_date_basis             := site_int_rec.terms_date_basis;
        site_rec.distribution_set_id          := site_int_rec.distribution_set_id;
        site_rec.distribution_set_name        := site_int_rec.distribution_set_name;
        site_rec.accts_pay_code_combination_id :=
                                              site_int_rec.accts_pay_code_combination_id;
        site_rec.prepay_code_combination_id   := site_int_rec.prepay_code_combination_id;
        site_rec.pay_group_lookup_code        := site_int_rec.pay_group_lookup_code;
        site_rec.payment_priority             := site_int_rec.payment_priority;
        site_rec.terms_id                     := site_int_rec.terms_id;
        site_rec.terms_name                    := site_int_rec.terms_name;
        /* Added for bug#7363316 Start */
        site_rec.tolerance_id                 := site_int_rec.tolerance_id;
        site_rec.tolerance_name               := site_int_rec.tolerance_name;
        /* Added for bug#7363316 End */
        site_rec.invoice_amount_limit         := site_int_rec.invoice_amount_limit;
        site_rec.pay_date_basis_lookup_code   := site_int_rec.pay_date_basis_lookup_code;
        site_rec.always_take_disc_flag        := site_int_rec.always_take_disc_flag;
        site_rec.invoice_currency_code        := site_int_rec.invoice_currency_code;
        site_rec.payment_currency_code        := site_int_rec.payment_currency_code;
        site_rec.hold_all_payments_flag       := site_int_rec.hold_all_payments_flag;
        site_rec.hold_future_payments_flag    := site_int_rec.hold_future_payments_flag;
        site_rec.hold_reason                  := site_int_rec.hold_reason;
        site_rec.hold_unmatched_invoices_flag := site_int_rec.hold_unmatched_invoices_flag;
        site_rec.tax_reporting_site_flag      := site_int_rec.tax_reporting_site_flag;
        site_rec.attribute_category           := site_int_rec.attribute_category;
        site_rec.attribute1                   := site_int_rec.attribute1;
        site_rec.attribute2                   := site_int_rec.attribute2;
        site_rec.attribute3                   := site_int_rec.attribute3;
        site_rec.attribute4                   := site_int_rec.attribute4;
        site_rec.attribute5                   := site_int_rec.attribute5;
        site_rec.attribute6                   := site_int_rec.attribute6;
        site_rec.attribute7                   := site_int_rec.attribute7;
        site_rec.attribute8                   := site_int_rec.attribute8;
        site_rec.attribute9                   := site_int_rec.attribute9;
        site_rec.attribute10                  := site_int_rec.attribute10;
        site_rec.attribute11                  := site_int_rec.attribute11;
        site_rec.attribute12                  := site_int_rec.attribute12;
        site_rec.attribute13                  := site_int_rec.attribute13;
        site_rec.attribute14                  := site_int_rec.attribute14;
        site_rec.attribute15                  := site_int_rec.attribute15;
        site_rec.exclude_freight_from_discount:= site_int_rec.exclude_freight_from_discount;
        site_rec.org_id                       := site_int_rec.org_id;
        site_rec.org_name                     := site_int_rec.operating_unit_name;
        site_rec.address_line4                := rtrim(site_int_rec.address_line4);
        site_rec.county                       := site_int_rec.county;
        site_rec.address_style                := site_int_rec.address_style;
        site_rec.language                     := site_int_rec.language;
        site_rec.allow_awt_flag               := site_int_rec.allow_awt_flag;
        site_rec.awt_group_id                 := site_int_rec.awt_group_id;
        site_rec.awt_group_name               := site_int_rec.awt_group_name;
        site_rec.pay_awt_group_id             := site_int_rec.pay_awt_group_id; /* Bug9589179 */
        site_rec.pay_awt_group_name           := site_int_rec.pay_awt_group_name;/* Bug9589179 */
        site_rec.global_attribute1            := site_int_rec.global_attribute1;
        site_rec.global_attribute2            := site_int_rec.global_attribute2;
        site_rec.global_attribute3            := site_int_rec.global_attribute3;
        site_rec.global_attribute4            := site_int_rec.global_attribute4;
        site_rec.global_attribute5            := site_int_rec.global_attribute5;
        site_rec.global_attribute6            := site_int_rec.global_attribute6;
        site_rec.global_attribute7            := site_int_rec.global_attribute7;
        site_rec.global_attribute8            := site_int_rec.global_attribute8;
        site_rec.global_attribute9            := site_int_rec.global_attribute9;
        site_rec.global_attribute10           := site_int_rec.global_attribute10;
        site_rec.global_attribute11           := site_int_rec.global_attribute11;
        site_rec.global_attribute12           := site_int_rec.global_attribute12;
        site_rec.global_attribute13           := site_int_rec.global_attribute13;
        site_rec.global_attribute14           := site_int_rec.global_attribute14;
        site_rec.global_attribute15           := site_int_rec.global_attribute15;
        site_rec.global_attribute16           := site_int_rec.global_attribute16;
        site_rec.global_attribute17           := site_int_rec.global_attribute17;
        site_rec.global_attribute18           := site_int_rec.global_attribute18;
        site_rec.global_attribute19           := site_int_rec.global_attribute19;
        site_rec.global_attribute20           := site_int_rec.global_attribute20;
        site_rec.global_attribute_category    := site_int_rec.global_attribute_category;
        site_rec.bank_charge_bearer           := site_int_rec.bank_charge_bearer;
        site_rec.pay_on_code                  := site_int_rec.pay_on_code;
        site_rec.pay_on_receipt_summary_code  := site_int_rec.pay_on_receipt_summary_code;
        site_rec.default_pay_site_id          := site_int_rec.default_pay_site_id;
        site_rec.tp_header_id                 := site_int_rec.tp_header_id;
        site_rec.ece_tp_location_code         := site_int_rec.ece_tp_location_code;
        site_rec.pcard_site_flag              := site_int_rec.pcard_site_flag;
        site_rec.match_option                 := site_int_rec.match_option;
        site_rec.country_of_origin_code       := site_int_rec.country_of_origin_code;
        site_rec.future_dated_payment_ccid    := site_int_rec.future_dated_payment_ccid;
        site_rec.create_debit_memo_flag       := site_int_rec.create_debit_memo_flag;
        site_rec.supplier_notif_method        := site_int_rec.supplier_notif_method;
        site_rec.email_address                := site_int_rec.email_address;
        site_rec.primary_pay_site_flag        := site_int_rec.primary_pay_site_flag;
        site_rec.shipping_control             := site_int_rec.shipping_control;
        site_rec.duns_number                  := site_int_rec.duns_number;
	site_rec.retainage_rate		      := site_int_rec.retainage_rate;
        site_rec.vat_code                     := site_int_rec.vat_code;
        -- bug 6645014 To Import VAT Code.
	site_rec.vat_registration_num         := site_int_rec.vat_registration_num; -- Bug 7207314
	site_rec.edi_id_number                  := site_int_rec.edi_id_number;      -- Bug 7437549

        site_rec.remit_advice_delivery_method := site_int_rec.remit_advice_delivery_method;  -- Bug 8422781

        ext_payee_rec.payer_org_type            := 'OPERATING_UNIT';
        ext_payee_rec.exclusive_pay_flag        :=NVL(site_int_rec.exclusive_payment_flag,'N');
            --bug6495364

        -- udhenuko Bug 6823885 Removed the comment for default payment method as this
        -- should be populated to create payment methods in IBY tables.
        ext_payee_rec.default_pmt_method        := site_int_rec.payment_method_lookup_code;
        ext_payee_rec.ece_tp_loc_code           := site_int_rec.ece_tp_location_code;
        --BG
        ext_payee_rec.bank_charge_bearer        := site_int_rec.iby_bank_charge_bearer;
        ext_payee_rec.bank_instr1_code          := site_int_rec.bank_instruction1_code;
        ext_payee_rec.bank_instr2_code          := site_int_rec.bank_instruction2_code;
        ext_payee_rec.bank_instr_detail         := site_int_rec.bank_instruction_details;
        ext_payee_rec.pay_reason_code           := site_int_rec.payment_reason_code;
        ext_payee_rec.pay_reason_com            := site_int_rec.payment_reason_comments;
        ext_payee_rec.pay_message1              := site_int_rec.payment_text_message1;
        ext_payee_rec.pay_message2              := site_int_rec.payment_text_message2;
        ext_payee_rec.pay_message3              := site_int_rec.payment_text_message3;
        ext_payee_rec.delivery_channel          := site_int_rec.delivery_channel_code;
        ext_payee_rec.pmt_format                := site_int_rec.payment_format_code;
        ext_payee_rec.settlement_priority       := site_int_rec.settlement_priority;
	-- Bug 7437549 Start
        -- Note that we must populate these EDI related fields only to ext_payee_rec
        -- Because only this record is passed for call to IBY in case of import.
        -- There is no need to populate site_rec.ext_payee_rec.
        -- Even if we pass it wont be used.
        ext_payee_rec.edi_payment_format         := site_int_rec.edi_payment_format;
        ext_payee_rec.edi_transaction_handling   := site_int_rec.edi_transaction_handling;
        ext_payee_rec.edi_payment_method         := site_int_rec.edi_payment_method;
        ext_payee_rec.edi_remittance_method      := site_int_rec.edi_remittance_method;
        ext_payee_rec.edi_remittance_instruction := site_int_rec.edi_remittance_instruction;
        -- Bug 7437549 End

	--bug 8222964
	ext_payee_rec.remit_advice_fax           := site_int_rec.remit_advice_fax;

		-- 6458813 Populating the ext_payee_rec of site_rec
         site_rec.ext_payee_rec.payer_org_type            := 'OPERATING_UNIT';--bug6495364
        site_rec.ext_payee_rec.payment_function          := 'PAYABLES_DISB';--bug6495364
        site_rec.ext_payee_rec.exclusive_pay_flag        := nvl(site_int_rec.exclusive_payment_flag,'N');--bug6495364
        site_rec.ext_payee_rec.default_pmt_method        := site_int_rec.payment_method_lookup_code;
        site_rec.ext_payee_rec.ece_tp_loc_code           := site_int_rec.ece_tp_location_code;
        site_rec.ext_payee_rec.bank_charge_bearer        := site_int_rec.iby_bank_charge_bearer;
        site_rec.ext_payee_rec.bank_instr1_code          := site_int_rec.bank_instruction1_code;
        site_rec.ext_payee_rec.bank_instr2_code          := site_int_rec.bank_instruction2_code;
        site_rec.ext_payee_rec.bank_instr_detail         := site_int_rec.bank_instruction_details;
        site_rec.ext_payee_rec.pay_reason_code           := site_int_rec.payment_reason_code;
        site_rec.ext_payee_rec.pay_reason_com            := site_int_rec.payment_reason_comments;
        site_rec.ext_payee_rec.pay_message1              := site_int_rec.payment_text_message1;
        site_rec.ext_payee_rec.pay_message2              := site_int_rec.payment_text_message2;
        site_rec.ext_payee_rec.pay_message3              := site_int_rec.payment_text_message3;
        site_rec.ext_payee_rec.delivery_channel          := site_int_rec.delivery_channel_code;
        site_rec.ext_payee_rec.pmt_format                := site_int_rec.payment_format_code;
        site_rec.ext_payee_rec.settlement_priority       := site_int_rec.settlement_priority;
		-- 6458813 ends

	-- bug 8222964
	site_rec.ext_payee_rec.remit_advice_fax          :=  site_int_rec.remit_advice_fax;

	-- B# 7339389
        site_rec.supplier_notif_method	:= site_int_rec.supplier_notif_method;
        site_rec.email_address		:= site_int_rec.email_address;
        site_rec.remittance_email 	:= site_int_rec.remittance_email ;

        --site_rec.ext_payee_rec.remit_advice_delivery_method     := site_int_rec.supplier_notif_method;  .. B 8422781
        site_rec.ext_payee_rec.remit_advice_delivery_method     := site_int_rec.remit_advice_delivery_method ;  -- Bug 8422781
        site_rec.ext_payee_rec.remit_advice_email               := site_int_rec.remittance_email ;

        -- Bug 7429668 start
        site_rec.party_site_id                                  := site_int_rec.party_site_id;
        site_rec.party_site_name                                := site_int_rec.party_site_name ;
        -- Bug 7429668 end
	-- Bug#7642742
        site_rec.auto_tax_calc_flag                             := site_int_rec.auto_tax_calc_flag ;
        site_rec.offset_tax_flag                                := site_int_rec.offset_tax_flag ;
    -- starting the Changes for CLM reference data management bug#9499174
        Site_rec.cage_code                              := site_int_rec.cage_code;
        Site_rec.legal_business_name                    := site_int_rec.legal_business_name;
        site_rec.DOING_BUS_AS_NAME                      := site_int_rec.DOING_BUS_AS_NAME;
        site_rec.division_name                          := site_int_rec.division_name;
        site_rec.small_business_code                    := site_int_rec.small_business_code;
        site_rec.ccr_comments                           := site_int_rec.ccr_comments;
        site_rec.debarment_start_date                   := site_int_rec.debarment_start_date;
        site_rec.debarment_end_date                     := site_int_rec.debarment_end_date;
     -- Ending the Changes for CLM reference data management bug#9499174

	/*bug 8275512 begin: As per the bug requirement and PM inputs it was
         decided to reject supplier creation when user is importing
         supplier site with bank account and the related bank account record
         fails validation. To implement this, creating a save point before
         vendor site creation looked the most feasible approach and also avoid
         fetch out of sequence error. If related bank
         fails validation we shall rollback to this savepoint and update
         the supplier site record as "REJECTED" and insert a record into Rejection
         table and thereafter commit the work.*/

         SAVEPOINT   Import_Vendor_Sites_PUB2;

         /*bug 8275512 end*/

        Create_Vendor_Site
          ( p_api_version       =>  1.0,
            p_init_msg_list     =>  FND_API.G_FALSE,
            p_commit            =>  FND_API.G_FALSE,
            p_validation_level  =>  FND_API.G_VALID_LEVEL_FULL,
            x_return_status     =>  l_return_status,
            x_msg_count         =>  l_msg_count,
            x_msg_data          =>  l_msg_data,
            p_vendor_site_rec   =>  site_rec,
            x_vendor_site_id    =>  l_vendor_site_id,
            x_party_site_id     =>  l_party_site_id,
            x_location_id       =>  l_location_id);

        IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

          UPDATE Ap_Supplier_Sites_Int
          SET    status = 'PROCESSED'
          WHERE  vendor_site_interface_id =
                        site_rec.vendor_site_interface_id;

          UPDATE AP_Sup_Site_Contact_Int
          SET    vendor_site_id = l_vendor_site_id
          WHERE  vendor_id = site_rec.vendor_id
          AND    vendor_site_code = site_rec.vendor_site_code
          AND    (org_id = site_rec.org_id OR
                  operating_unit_name = site_rec.org_name);

          ext_payee_rec.supplier_site_id        := l_vendor_site_id;
          ext_payee_rec.payee_party_site_id     := l_party_site_id;

          SELECT org_id
          INTO ext_payee_rec.payer_org_id
          FROM Po_Vendor_Sites_All
          WHERE vendor_site_id = l_vendor_site_id;

          -- As per the discussion with Omar/Jayanta, we will only
          -- have payables payment function and no more employee expenses
          -- payment function.


          SELECT party_id, 'PAYABLES_DISB'
          INTO ext_payee_rec.payee_party_id,
               ext_payee_rec.payment_function
          FROM Po_Vendors
          WHERE vendor_id = site_rec.vendor_id;

	  /*Bug 7572325- added the call to count_and_get to get the count
          before call to IBY API in local variable*/
          FND_MSG_PUB.Count_And_Get(p_count => l_payee_msg_count,
                                    p_data => l_payee_msg_data);

          /* Calling IBY Payee Validation API */
          IBY_DISBURSEMENT_SETUP_PUB.Validate_External_Payee
            ( p_api_version     => 1.0,
              p_init_msg_list   => FND_API.G_FALSE,
              p_ext_payee_rec   => ext_payee_rec,
              x_return_status   => l_return_status,
              x_msg_count       => l_msg_count,
              x_msg_data        => l_msg_data);

          IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN


	-- B# 7339389
        --ext_payee_rec.remit_advice_delivery_method     := site_int_rec.supplier_notif_method;  .. Bug 8422781
        ext_payee_rec.remit_advice_delivery_method     := site_int_rec.remit_advice_delivery_method ;  -- Bug 8422781
        ext_payee_rec.remit_advice_email               := site_int_rec.remittance_email;

            --bug 5569961  ext_payee_tab(ext_payee_tab.first)      := ext_payee_rec;
             ext_payee_tab(1)      := ext_payee_rec;

            /* Calling IBY Payee Creation API */
            IBY_DISBURSEMENT_SETUP_PUB.Create_External_Payee
              ( p_api_version         => 1.0,
                p_init_msg_list       => FND_API.G_FALSE,
                p_ext_payee_tab       => ext_payee_tab,
                x_return_status       => l_return_status,
                x_msg_count           => l_msg_count,
                x_msg_data            => l_msg_data,
                x_ext_payee_id_tab    => ext_payee_id_tab,
                x_ext_payee_status_tab => ext_payee_create_tab);

            IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
              --bug 5568861 l_ext_payee_id     := ext_payee_id_tab(ext_payee_id_tab.first).ext_payee_id;
               l_ext_payee_id     := ext_payee_id_tab(1).ext_payee_id;

              UPDATE IBY_TEMP_EXT_BANK_ACCTS
              SET ext_payee_id = l_ext_payee_id
                 ,account_owner_party_id = ext_payee_rec.payee_party_id --bug 6753331
              WHERE calling_app_unique_ref2 = site_rec.vendor_site_interface_id;

              -- Cursor processing for iby temp bank account record
              OPEN iby_ext_accts_cur(site_rec.vendor_site_interface_id);
              LOOP

                FETCH iby_ext_accts_cur
                INTO l_temp_ext_acct_id;
                EXIT WHEN iby_ext_accts_cur%NOTFOUND;

                 /* Calling IBY Bank Account Validation API */
                  --commented for Bug 9012321
             /*   IBY_DISBURSEMENT_SETUP_PUB.Validate_Temp_Ext_Bank_Acct
                 ( p_api_version         => 1.0,
                   p_init_msg_list       => FND_API.G_FALSE,
                   x_return_status       => l_return_status,
                   x_msg_count           => l_msg_count,
                   x_msg_data            => l_msg_data,
                   p_temp_ext_acct_id    => l_temp_ext_acct_id);

                IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN */ --Commented for Bug 9012321
                  /* Calling IBY Bank Account Creation API */
                  -- Bug 6845995. Calling overloaded procedure
                  -- which will create the association between
                  -- supplier site and bank account.
                  IBY_DISBURSEMENT_SETUP_PUB.Create_Temp_Ext_Bank_Acct
                   ( p_api_version         => 1.0,
                     p_init_msg_list       => FND_API.G_FALSE,
                     x_return_status       => l_return_status,
                     x_msg_count           => l_msg_count,
                     x_msg_data            => l_msg_data,
                     p_temp_ext_acct_id    => l_temp_ext_acct_id,
                     p_association_level   => 'SS',
                     p_supplier_site_id    => l_vendor_site_id,
                     p_party_site_id       => ext_payee_rec.payee_party_site_id,
                     p_org_id              => ext_payee_rec.payer_org_id,
                     p_org_type            => 'OPERATING_UNIT', -- veramach added p_org_type as a new paramter for bug 7153777
                     x_bank_acc_id         => l_bank_acct_id,
                     x_response            => ext_response_rec);

                  IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                    UPDATE iby_temp_ext_bank_accts
                    SET status = 'PROCESSED'
                    WHERE temp_ext_bank_acct_id = l_temp_ext_acct_id;

                  ELSE -- Bank Account Creation API
                    --bug 8275512 moved the below code after cursor iby_ext_accts_cur close
		    /*UPDATE iby_temp_ext_bank_accts
                      SET status = 'REJECTED'
                      WHERE temp_ext_bank_acct_id = l_temp_ext_acct_id;

                    IF (Insert_Rejections(
                      'IBY_TEMP_EXT_BANK_ACCTS',
                       site_rec.vendor_site_interface_id,
                      'AP_BANK_ACCT_CREATION',
                      g_user_id,
                      g_login_id,
                      'Import_Vendor_Site') <> TRUE) THEN
                     --
                      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_MSG_PUB.Count_And_Get(
                          p_count   =>   l_msg_count,
                          p_data    =>   l_msg_data);
                        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                          l_api_name,'Parameters: '
                          ||' Vendor_Site_Interface_Id: '||site_rec.vendor_site_interface_id
                          ||' Acct Validation Msg: '||l_msg_data);
                      END IF;
                    END IF; */

                    l_rollback_vendor_site := 'Y'; --Bug 8275512

                    -- Bug 5491139 hkaniven start --
                    FND_MESSAGE.SET_NAME('SQLAP','AP_BANK_ACCT_CREATION');
                    FND_MSG_PUB.ADD;
                    -- Bug 5491139 hkaniven end --
                  END IF;    -- Bank Account Creation API
--Commented for Bug 9012321
          /*      ELSE  -- Bank Account Validation API
                  --bug 8275512 moved the below code after cursor iby_ext_accts_cur close

                  /*UPDATE iby_temp_ext_bank_accts
                  SET status = 'REJECTED'
                  WHERE temp_ext_bank_acct_id = l_temp_ext_acct_id;

                  IF (Insert_Rejections(
                    --'IBY_TEMP_EXT_BANK_ACCTS',
                    'AP_SUPPLIER_SITES_INT', --bug 8275512
                    site_rec.vendor_site_interface_id,
                    'AP_INVALID_BANK_ACCT_INFO',
                    g_user_id,
                    g_login_id,
                    'Import_Vendor_Site') <> TRUE) THEN
                   --
                    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_MSG_PUB.Count_And_Get(
                        p_count   =>   l_msg_count,
                        p_data    =>   l_msg_data);
                      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                        l_api_name,'Parameters: '
                        ||' Vendor_Site_Interface_Id: '||site_rec.vendor_site_interface_id
                        ||' Acct Validation Msg: '||l_msg_data);
                    END IF;
                  END IF;

                    l_rollback_vendor_site := 'Y'; --Bug 8275512

                    -- Bug 5491139 hkaniven start --
                    FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_BANK_ACCT_INFO');
                    FND_MSG_PUB.ADD;
                    -- Bug 5491139 hkaniven end --
                END IF;  -- Bank Account Validation API */--Commented for Bug 9012321

              END LOOP;
              CLOSE iby_ext_accts_cur;

	      /*Bug 8275512 begin -- rollback if bank account creation fails*/
              IF l_rollback_vendor_site = 'Y' then

                  ROLLBACK TO Import_Vendor_Sites_PUB2;

                  UPDATE Ap_Supplier_Sites_Int
                   SET    status = 'REJECTED'
                  WHERE  vendor_site_interface_id = site_rec.vendor_site_interface_id;


                  UPDATE iby_temp_ext_bank_accts
                  SET status = 'REJECTED'
                  WHERE temp_ext_bank_acct_id = l_temp_ext_acct_id;

                  -- Bug 9259355 Start
                 fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                           p_count => l_msg_count,
                                           p_data  => l_msg_data);

                 IF ( NVL(l_msg_count, 0) > 1 ) THEN

                    FOR i IN 1..l_msg_count
                    LOOP
                    l_msg_data := FND_MSG_PUB.Get(p_msg_index => i, p_encoded => 'F');

                    IF (FND_GLOBAL.conc_request_id = -1) THEN
                    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                        l_api_name,'Parameters: '
                        ||' Vendor_Site_Interface_Id: '||site_rec.vendor_site_interface_id
                        ||' Acct Validation Msg: '||l_msg_data);
                    END IF;
                    ELSE
                    AP_IMPORT_UTILITIES_PKG.Print('Y', l_api_name ||': '|| l_msg_data);
                    END IF;

                    END LOOP;

                 ELSIF (l_msg_data is not null) THEN

                    IF (FND_GLOBAL.conc_request_id = -1) THEN
                    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                        l_api_name,'Parameters: '
                        ||' Vendor_Site_Interface_Id: '||site_rec.vendor_site_interface_id
                        ||' Acct Validation Msg: '||l_msg_data);
                    END IF;
                    ELSE
                    AP_IMPORT_UTILITIES_PKG.Print('Y', l_api_name ||': '|| l_msg_data);
                    END IF;

                 END IF;
                 -- Bug 9259355 End

                  IF (Insert_Rejections(
                    --'IBY_TEMP_EXT_BANK_ACCTS',
                    'AP_SUPPLIER_SITES_INT', --bug 8275512
                    site_rec.vendor_site_interface_id,
                    'AP_INVALID_BANK_ACCT_INFO',
                    g_user_id,
                    g_login_id,
                    'Import_Vendor_Site') <> TRUE) THEN
                   --
                    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_MSG_PUB.Count_And_Get(
                        p_count   =>   l_msg_count,
                        p_data    =>   l_msg_data);
                      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                        l_api_name,'Parameters: '
                        ||' Vendor_Site_Interface_Id: '||site_rec.vendor_site_interface_id
                        ||' Acct Validation Msg: '||l_msg_data);
                    END IF;
                  END IF;

		  l_rollback_vendor_site := 'N'; --resetting the value to initial
		End if;
                 /*Bug 8275512 end*/

            ELSE  -- Payee Creation API

                  -- Bug 9259355 Start
                 fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                           p_count => l_msg_count,
                                           p_data  => l_msg_data);

                 IF ( NVL(l_msg_count, 0) > 1 ) THEN

                    FOR i IN 1..l_msg_count
                    LOOP
                    l_msg_data := FND_MSG_PUB.Get(p_msg_index => i, p_encoded => 'F');

                    IF (FND_GLOBAL.conc_request_id = -1) THEN
                    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                        l_api_name,'Parameters: '
                        ||' Vendor_Site_Interface_Id: '||site_rec.vendor_site_interface_id
                        ||' Acct Validation Msg: '||l_msg_data);
                    END IF;
                    ELSE
                    AP_IMPORT_UTILITIES_PKG.Print('Y', l_api_name ||': '|| l_msg_data);
                    END IF;

                    END LOOP;

                 ELSIF (l_msg_data is not null) THEN

                    IF (FND_GLOBAL.conc_request_id = -1) THEN
                    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                        l_api_name,'Parameters: '
                        ||' Vendor_Site_Interface_Id: '||site_rec.vendor_site_interface_id
                        ||' Acct Validation Msg: '||l_msg_data);
                    END IF;
                    ELSE
                    AP_IMPORT_UTILITIES_PKG.Print('Y', l_api_name ||': '|| l_msg_data);
                    END IF;

                 END IF;
                 -- Bug 9259355 End

              IF (Insert_Rejections(
                    'AP_SUPPLIER_SITES_INT',
                    site_rec.vendor_site_interface_id,
                    'AP_PAYEE_CREATION',
                    g_user_id,
                    g_login_id,
                    'Import_Vendor_Site') <> TRUE) THEN
               --
                IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_MSG_PUB.Count_And_Get(
                    p_count   =>   l_msg_count,
                    p_data    =>   l_msg_data);
                  FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                    l_api_name,'Parameters: '
                    ||' Vendor_Site_Interface_Id: '||site_rec.vendor_site_interface_id
                    ||' Payee Validation Msg: '||l_msg_data);
                END IF;
              END IF;

                -- Bug 5491139 hkaniven start --
                FND_MESSAGE.SET_NAME('SQLAP','AP_PAYEE_CREATION');
                FND_MSG_PUB.ADD;
                -- Bug 5491139 hkaniven end --
            END IF;   -- Payee Creation API

          ELSE  -- Payee Validation API

                  -- Bug 9259355 Start
                 fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                           p_count => l_msg_count,
                                           p_data  => l_msg_data);

                 IF ( NVL(l_msg_count, 0) > 1 ) THEN

                    FOR i IN 1..l_msg_count
                    LOOP
                    l_msg_data := FND_MSG_PUB.Get(p_msg_index => i, p_encoded => 'F');

                    IF (FND_GLOBAL.conc_request_id = -1) THEN
                    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                        l_api_name,'Parameters: '
                        ||' Vendor_Site_Interface_Id: '||site_rec.vendor_site_interface_id
                        ||' Acct Validation Msg: '||l_msg_data);
                    END IF;
                    ELSE
                    AP_IMPORT_UTILITIES_PKG.Print('Y', l_api_name ||': '|| l_msg_data);
                    END IF;

                    END LOOP;

                 ELSIF (l_msg_data is not null) THEN

                    IF (FND_GLOBAL.conc_request_id = -1) THEN
                    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                        l_api_name,'Parameters: '
                        ||' Vendor_Site_Interface_Id: '||site_rec.vendor_site_interface_id
                        ||' Acct Validation Msg: '||l_msg_data);
                    END IF;
                    ELSE
                    AP_IMPORT_UTILITIES_PKG.Print('Y', l_api_name ||': '|| l_msg_data);
                    END IF;

                 END IF;
                 -- Bug 9259355 End

            IF (Insert_Rejections(
                    'AP_SUPPLIER_SITES_INT',
                    site_rec.vendor_site_interface_id,
                    'AP_INVALID_PAYEE_INFO',
                    g_user_id,
                    g_login_id,
                    'Import_Vendor_Site') <> TRUE) THEN
           --
              IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_MSG_PUB.Count_And_Get(
                  p_count   =>   l_msg_count,
                  p_data    =>   l_msg_data);
                FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
                   l_api_name,'Parameters: '
                   ||' Vendor_Site_Interface_Id: '||site_rec.vendor_site_interface_id
                   ||' Payee Validation Msg: '||l_msg_data);
              END IF;
            END IF;

	           --bug 7572325 addded below file logging for improved exception
                   --message handling
                   l_debug_info := 'Calling IBY Payee Validation API in import site';
                    IF (l_msg_data IS NOT NULL) THEN
                     -- Print the error returned from the IBY service even if the debug
                     -- mode is off
                      AP_IMPORT_UTILITIES_PKG.Print('Y', '4)Error in '||l_debug_info||
                                                    '---------------------->'||
                                                    l_msg_data);

                    ELSE
                      -- If the l_msg_data is null then the IBY service returned
                      -- more than one error.  The calling module will need to get
                      -- them from the message stack
                     FOR i IN l_payee_msg_count..l_msg_count
                      LOOP
                       l_error_code := FND_MSG_PUB.Get(p_msg_index => i,
                                                       p_encoded => 'F');

                        If i = l_payee_msg_count then
                          l_error_code := '4)Error in '||l_debug_info||
                                                    '---------------------->'||
                                                    l_error_code;
                        end if;

                        AP_IMPORT_UTILITIES_PKG.Print('Y', l_error_code);

                      END LOOP;

                     END IF;--bug 7572325

            -- Bug 5491139 hkaniven start --
            FND_MESSAGE.SET_NAME('SQLAP','AP_INVALID_PAYEE_INFO');
            FND_MSG_PUB.ADD;
            -- Bug 5491139 hkaniven end --
          END IF;  -- Payee Validation API

        ELSE    -- Supplier Site Creation API

          UPDATE Ap_Supplier_Sites_Int
          SET    status = 'REJECTED'
          WHERE  vendor_site_interface_id =
                        site_rec.vendor_site_interface_id;

          IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
             ' Rejected Vendor_Site_Interface_Id: '
             ||site_rec.vendor_site_interface_id
             ||', No. of Messages from Create_Vendor_Site API: '|| l_msg_count
             ||', Message From Create_Vendor_Site API: '||l_msg_data);
          END IF;

        END IF;   -- Supplier Site Creation API

      END LOOP;

      CLOSE site_int_cur;

    END IF;
    -- End of API body.

    -- Standard check of p_commit.
    COMMIT WORK;

    -- Standard call to get message count and if count is 1,
    -- get message info.
    FND_MSG_PUB.Count_And_Get(
        p_count                 =>      x_msg_count,
        p_data                  =>      x_msg_data
        );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Import_Vendor_Sites_PUB;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      x_msg_count,
                        p_data                  =>      x_msg_data
                );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Import_Vendor_Sites_PUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      x_msg_count,
                        p_data                  =>      x_msg_data
                );
  WHEN OTHERS THEN
    ROLLBACK TO Import_Vendor_Sites_PUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level
         (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg
                        (       G_PKG_NAME,
                                l_api_name
                        );
    END IF;
    FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      x_msg_count,
                        p_data                  =>      x_msg_data
                );
END Import_Vendor_Sites;

PROCEDURE Import_Vendor_Contacts
(       p_api_version           IN      NUMBER,
        p_source                IN      VARCHAR2 DEFAULT 'IMPORT',
        p_what_to_import        IN      VARCHAR2 DEFAULT NULL,
        p_commit_size           IN      NUMBER   DEFAULT 1000,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2
)
IS

    l_api_name                  CONSTANT VARCHAR2(30)   := 'Import_Vendor_Contacts';
    l_api_version               CONSTANT NUMBER         := 1.0;

    l_program_application_id    NUMBER  := FND_GLOBAL.prog_appl_id;
    l_program_id                NUMBER  := FND_GLOBAL.conc_program_id;
    l_request_id                NUMBER  := FND_GLOBAL.conc_request_id;

    l_return_status             VARCHAR2(2000);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);
    l_vendor_contact_id         NUMBER;
    l_per_party_id              NUMBER;
    l_rel_party_id              NUMBER;
    l_rel_id                    NUMBER;
    l_org_contact_id            NUMBER;
    l_party_site_id             NUMBER;

    CURSOR contact_int_cur IS
    SELECT *
    FROM Ap_Sup_Site_Contact_Int
    WHERE import_request_id = l_request_id
    AND vendor_id IS NOT NULL
    AND (org_id IS NOT NULL OR operating_unit_name IS NOT NULL )
    AND vendor_id not in(select vendor_id from ap_suppliers
                         where vendor_type_lookup_code = 'EMPLOYEE') --Bug6648405

    -- Bug 7013954 Contacts can be created at Supplier level. So cannot mandate
	-- the site information to be present.
    -- AND (vendor_site_code IS NOT NULL OR vendor_site_id IS NOT NULL)
    AND last_name IS NOT NULL
	FOR UPDATE OF status;        --Bug6413297

    contact_int_rec            contact_int_cur%ROWTYPE;
    vendor_contact_rec         r_vendor_contact_rec_type;

BEGIN

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    FND_MSG_PUB.initialize;

    g_user_id       := FND_GLOBAL.USER_ID;
    g_login_id      := FND_GLOBAL.LOGIN_ID;
    g_source        := p_source;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- API body

    IF g_source <> 'IMPORT' THEN
      NULL;
    ELSE
      --udhenuko Bug 6823885 This update statement resets the unprocessed rows so
      -- that they get picked in the current run.
      UPDATE Ap_Sup_Site_Contact_Int api
      SET import_request_id = NULL
      WHERE import_request_id IS NOT NULL
        AND NVL(status,'NEW') IN ('NEW', 'REJECTED')
        AND EXISTS
                ( SELECT 'Request Completed'
                    FROM fnd_concurrent_requests fcr
                  WHERE fcr.request_id = api.import_request_id
                    AND fcr.phase_code = 'C' );
      --udhenuko Bug 6823885 End
      --bug 5591652
       DELETE AP_SUPPLIER_INT_REJECTIONS
       WHERE PARENT_TABLE='AP_SUP_SITE_CONTACT_INT';
      -- Updating Interface Record with request id

      UPDATE Ap_Sup_Site_Contact_Int
      SET    import_request_id = l_request_id
      WHERE  import_request_id IS NULL AND
             ((p_what_to_import = 'ALL' AND nvl(status,'NEW') in ('NEW', 'REJECTED')) OR
             (p_what_to_import = 'NEW' AND nvl(status,'NEW') = 'NEW') OR
             (p_what_to_import = 'REJECTED' AND nvl(status,'NEW') = 'REJECTED'));

      UPDATE Ap_Sup_Site_Contact_Int
      SET    status = 'REJECTED',
             import_request_id = l_request_id
      WHERE ((vendor_id IS NULL) OR
             (operating_unit_name IS NULL AND org_id IS NULL) OR
             -- Bug 7013954 Vendor site info no longer used for validation
             -- (vendor_site_code IS NULL and vendor_site_id IS NULL) OR
             (last_name IS NULL) OR
             --Bug7390094 - rejecting contacts for Employee type suppliers.
             (vendor_id in(select vendor_id from ap_suppliers
                         where vendor_type_lookup_code = 'EMPLOYEE')));

      --bug 5591652
      insert into ap_supplier_int_rejections
      (select 'AP_SUP_SITE_CONTACT_INT',vendor_contact_interface_id,'AP_ORG_INFO_NULL',
              g_user_id,SYSDATE,g_login_id,g_user_id,SYSDATE
      from ap_sup_site_contact_int
      where status='REJECTED'
      AND import_request_id=l_request_id
      AND (operating_unit_name IS NULL and org_id IS NULL))
      -- Bug 7013954 Conditions related to supplier site needs to be commented.
      /*UNION
     (select 'AP_SUP_SITE_CONTACT_INT',vendor_contact_interface_id,'AP_VENDOR_SITE_INFO_NULL',
               g_user_id,SYSDATE,g_login_id,g_user_id,SYSDATE
      from  ap_sup_site_contact_int
      where status='REJECTED'
      AND import_request_id=l_request_id
      AND (vendor_site_code IS NULL and vendor_site_id IS NULL))*/
      UNION
     (select 'AP_SUP_SITE_CONTACT_INT',vendor_contact_interface_id,'AP_LAST_NAME_NULL',
              g_user_id,SYSDATE,g_login_id,g_user_id,SYSDATE
      from  ap_sup_site_contact_int
      where status='REJECTED'
      AND import_request_id=l_request_id
      AND last_name IS NULL)
      UNION
     (select 'AP_SUP_SITE_CONTACT_INT',vendor_contact_interface_id,'AP_VENDOR_ID_NULL',
             g_user_id,SYSDATE,g_login_id,g_user_id,SYSDATE
      from  ap_sup_site_contact_int
      where status='REJECTED'
      AND import_request_id=l_request_id
      AND vendor_id IS NULL)
      -- Bug 7390094 Prevent contacts import for employee type supplier.
      UNION
      (select 'AP_SUP_SITE_CONTACT_INT',vendor_contact_interface_id,'AP_EMPLOYEE_CONTACTS',
             g_user_id,SYSDATE,g_login_id,g_user_id,SYSDATE
      from  ap_sup_site_contact_int
      where status='REJECTED'
      AND import_request_id=l_request_id
      AND vendor_id in(select vendor_id from ap_suppliers
                         where vendor_type_lookup_code = 'EMPLOYEE'));

      COMMIT;

	  -- Bug 7013954 Standard Start of API savepoint
      SAVEPOINT   Import_Vendor_Contact_PUB;

      -- Cursor processing for vendor contact interface record
      OPEN contact_int_cur;
      LOOP

        FETCH contact_int_cur
        INTO contact_int_rec;
        EXIT WHEN contact_int_cur%NOTFOUND;

        vendor_contact_rec.vendor_contact_interface_id :=
                                            contact_int_rec.vendor_contact_interface_id;
        vendor_contact_rec.vendor_site_id    := contact_int_rec.vendor_site_id;
        vendor_contact_rec.person_first_name := contact_int_rec.first_name;
        vendor_contact_rec.person_middle_name:= contact_int_rec.middle_name;
        vendor_contact_rec.person_last_name  := contact_int_rec.last_name;
        vendor_contact_rec.person_title      := contact_int_rec.title;
        vendor_contact_rec.person_first_name_phonetic :=
                                                contact_int_rec.first_name_alt;
        vendor_contact_rec.person_last_name_phonetic  :=
                                                contact_int_rec.last_name_alt;
        vendor_contact_rec.contact_name_phonetic :=
                                             contact_int_rec.contact_name_alt;
        vendor_contact_rec.prefix            := contact_int_rec.prefix;
        vendor_contact_rec.inactive_date     := contact_int_rec.inactive_date;
        vendor_contact_rec.department        := contact_int_rec.department;
        vendor_contact_rec.mail_stop         := contact_int_rec.mail_stop;
        vendor_contact_rec.area_code         := contact_int_rec.area_code;
        vendor_contact_rec.phone             := contact_int_rec.phone;
        vendor_contact_rec.alt_area_code     := contact_int_rec.alt_area_code;
        vendor_contact_rec.alt_phone         := contact_int_rec.alt_phone;
        vendor_contact_rec.fax_area_code     := contact_int_rec.fax_area_code;
        vendor_contact_rec.fax_phone         := contact_int_rec.fax;
        vendor_contact_rec.email_address     := contact_int_rec.email_address;
        vendor_contact_rec.url               := contact_int_rec.url;
        vendor_contact_rec.vendor_site_code  := contact_int_rec.vendor_site_code;
        vendor_contact_rec.org_id            := contact_int_rec.org_id;
        vendor_contact_rec.operating_unit_name  :=
                                             contact_int_rec.operating_unit_name;
        vendor_contact_rec.vendor_interface_id := contact_int_rec.vendor_interface_id;
        vendor_contact_rec.vendor_id         := contact_int_rec.vendor_id;
        -- Bug 7013954 start Need to populate party site related info
        vendor_contact_rec.org_party_site_id := contact_int_rec.party_site_id;
        vendor_contact_rec.party_site_name   := contact_int_rec.party_site_name;
        -- Bug 7013954 end

        Create_Vendor_Contact
          ( p_api_version       =>  1.0,
            p_init_msg_list     =>  FND_API.G_FALSE,
            p_commit            =>  FND_API.G_FALSE,
            p_validation_level  =>  FND_API.G_VALID_LEVEL_FULL,
            x_return_status     =>  l_return_status,
            x_msg_count         =>  l_msg_count,
            x_msg_data          =>  l_msg_data,
            p_vendor_contact_rec => vendor_contact_rec,
            x_vendor_contact_id =>  l_vendor_contact_id,
            x_per_party_id      =>  l_per_party_id,
            x_rel_party_id      =>  l_rel_party_id,
            x_rel_id            =>  l_rel_id,
            x_org_contact_id    =>  l_org_contact_id,
            x_party_site_id     =>  l_party_site_id);

        IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

          UPDATE Ap_Sup_Site_Contact_Int
          SET    status = 'PROCESSED'
		  WHERE CURRENT OF contact_int_cur;    --Bug6413297
          /*WHERE  vendor_contact_interface_id =
                   vendor_contact_rec.vendor_contact_interface_id;*/--Bug6413297

        ELSE

          UPDATE Ap_Sup_Site_Contact_Int
          SET    status = 'REJECTED'
          WHERE CURRENT OF contact_int_cur;   --Bug6413297
		  /*WHERE  vendor_contact_interface_id =
                   vendor_contact_rec.vendor_contact_interface_id;*/--Bug6413297

          IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
             ' Rejected Vendor_Contact_Interface_Id: '
             ||vendor_contact_rec.vendor_contact_interface_id
             ||', No. of Messages from Create_Vendor_Contact API: '|| l_msg_count
             ||', Message From Create_Vendor_Contact API: '||l_msg_data);
          END IF;

        END IF;

      END LOOP;

      CLOSE contact_int_cur;

    END IF;
    -- End of API body.

    COMMIT WORK;

    -- Standard call to get message count and if count is 1,
    -- get message info.
    FND_MSG_PUB.Count_And_Get(
        p_count                 =>      x_msg_count,
        p_data                  =>      x_msg_data
        );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Import_Vendor_Contact_PUB;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      x_msg_count,
                        p_data                  =>      x_msg_data
                );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Import_Vendor_Contact_PUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      x_msg_count,
                        p_data                  =>      x_msg_data
                );
  WHEN OTHERS THEN
    ROLLBACK TO Import_Vendor_Contact_PUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level
         (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg
                        (       G_PKG_NAME,
                                l_api_name
                        );
    END IF;
    FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      x_msg_count,
                        p_data                  =>      x_msg_data
                );
END Import_Vendor_Contacts;

-- Bug 6745669: Added the API Update_Address_Assignments_DFF to update
--              DFFs of the Vendor Contacts
--

PROCEDURE Update_Address_Assignments_DFF(
        p_api_version           IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
        p_contact_party_id      IN      NUMBER,
        p_org_party_site_id     IN      NUMBER,
        p_attribute_category    IN      VARCHAR2 DEFAULT NULL,
        p_attribute1            IN      VARCHAR2 DEFAULT NULL,
        p_attribute2            IN      VARCHAR2 DEFAULT NULL,
        p_attribute3            IN      VARCHAR2 DEFAULT NULL,
        p_attribute4            IN      VARCHAR2 DEFAULT NULL,
        p_attribute5            IN      VARCHAR2 DEFAULT NULL,
        p_attribute6            IN      VARCHAR2 DEFAULT NULL,
        p_attribute7            IN      VARCHAR2 DEFAULT NULL,
        p_attribute8            IN      VARCHAR2 DEFAULT NULL,
        p_attribute9            IN      VARCHAR2 DEFAULT NULL,
        p_attribute10           IN      VARCHAR2 DEFAULT NULL,
        p_attribute11           IN      VARCHAR2 DEFAULT NULL,
        p_attribute12           IN      VARCHAR2 DEFAULT NULL,
        p_attribute13           IN      VARCHAR2 DEFAULT NULL,
        p_attribute14           IN      VARCHAR2 DEFAULT NULL,
        p_attribute15           IN      VARCHAR2 DEFAULT NULL,
        x_return_status		OUT	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2

)

IS
    l_api_name	    CONSTANT VARCHAR2(30)	:= 'Update_Address_Assignments_DFF';
    l_api_version   CONSTANT NUMBER 		:= 1.0;
    l_count         NUMBER                      := 0;
    l_event_vendor_contact_id   AP_SUPPLIER_CONTACTS.vendor_contact_id%TYPE; --Bug 7307669
BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT	Update_Address_Assign_DFF_PUB;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
    THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- API body


    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
         'Updating dffs for contact_party_id: ' || p_contact_party_id
         || ', org_party_site_id: '|| p_org_party_site_id);
    END IF;


   UPDATE ap_supplier_contacts
   SET    attribute_category=p_attribute_category,
          attribute1 = p_attribute1,
          attribute2 = p_attribute2,
          attribute3 = p_attribute3,
          attribute4 = p_attribute4,
          attribute5 = p_attribute5,
          attribute6 = p_attribute6,
          attribute7 = p_attribute7,
          attribute8 = p_attribute8,
          attribute9 = p_attribute9,
          attribute10 = p_attribute10,
          attribute11 = p_attribute11,
          attribute12 = p_attribute12,
          attribute13 = p_attribute13,
          attribute14 = p_attribute14,
          attribute15 = p_attribute15
   WHERE  per_party_id=p_contact_party_id
   AND    org_party_site_id=p_org_party_site_id
   AND    NVL(inactive_date, SYSDATE+1 ) > SYSDATE
   ;

   l_count := SQL%ROWCOUNT;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
       ' Updated '
       ||l_count
       ||' rows.');
   END IF;

   BEGIN  -- Bug 7307669 : Begin
        SELECT  vendor_contact_id
        INTO    l_event_vendor_contact_id
        FROM    ap_supplier_contacts
        WHERE   per_party_id=p_contact_party_id
        AND     org_party_site_id=p_org_party_site_id
        AND     NVL(inactive_date, SYSDATE+1 ) > SYSDATE ;

	Raise_Supplier_Event( i_vendor_contact_id => l_event_vendor_contact_id );
   EXCEPTION
        WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
	    	IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
	            FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME || l_api_name, SQLERRM);
		END IF;
    		APP_EXCEPTION.RAISE_EXCEPTION;
   END; -- Bug 7307669 : End

    -- End of API body.

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
	COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1,
    -- get message info.
    FND_MSG_PUB.Count_And_Get(
	p_count         	=>      x_msg_count     	,
        p_data          	=>      x_msg_data
    	);

EXCEPTION
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Update_Address_Assign_DFF_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);
	WHEN OTHERS THEN
		ROLLBACK TO Update_Address_Assign_DFF_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);
END Update_Address_Assignments_DFF;

-- Bug 7307669 : Added the procedure Raise_Supplier_Event to raise a worklflow
--		 event whenever a Supplier / Supplier Site / Supplier Contact
--		 is created or updated

PROCEDURE Raise_Supplier_Event (
				i_vendor_id          IN  NUMBER  DEFAULT NULL,
        		        i_vendor_site_id     IN  NUMBER  DEFAULT NULL,
		                i_vendor_contact_id  IN  NUMBER  DEFAULT NULL
 	                       )
IS
	l_api_name		CONSTANT VARCHAR2(200) := ' Raise_Supplier_Event';
	l_debug_info		VARCHAR2(2000);
	l_parameter_list	wf_parameter_list_t;
	l_event_key		VARCHAR2(100);
	l_event_name		VARCHAR2(100) := 'oracle.apps.ap.supplier.event';
	l_vendor_id		AP_SUPPLIERS.vendor_id%TYPE;
BEGIN
	l_debug_info := 'Called with parameters : i_vendor_id = '
		        || to_char(i_vendor_id)	     || ', i_vendor_site_id = '
		        || to_char(i_vendor_site_id) || ', i_vendor_contact_id = '
		        || to_char(i_vendor_contact_id);
	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_api_name,
                       		l_debug_info);
	END IF;

	-- If vendor_id was not passed then we should derive it based on
	-- vendor_site_id or vendor_contact_id
	IF i_vendor_id IS NULL THEN
		IF i_vendor_site_id IS NOT NULL THEN
			SELECT	vendor_id
			INTO	l_vendor_id
			FROM	ap_supplier_sites_all
			WHERE	vendor_site_id = i_vendor_site_id;
		END IF;

		IF i_vendor_contact_id IS NOT NULL THEN
			SELECT	vendor_id
			INTO	l_vendor_id
			FROM	po_vendor_contacts
			WHERE	vendor_contact_id = i_vendor_contact_id
			AND	ROWNUM = 1;
		END IF;
	ELSE
		l_vendor_id := i_vendor_id;
	END IF;

	l_parameter_list := wf_parameter_list_t(
						wf_parameter_t('VENDOR_ID',
						to_char(l_vendor_id) ),
						wf_parameter_t('VENDOR_SITE_ID',
						to_char(i_vendor_site_id) ),
						wf_parameter_t('VENDOR_CONTACT_ID',
					    	to_char(i_vendor_contact_id) )
					       );

	SELECT	to_char(ap_supplier_event_s.nextval)
	INTO	l_event_key
	FROM 	dual;

	wf_event.raise( p_event_name => l_event_name,
		        p_event_key  => l_event_key,
		        p_parameters => l_parameter_list);

	l_debug_info := 'After raising workflow event : '
		        || 'event_name = ' || l_event_name
		        || ' event_key = ' || l_event_key ;

	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                       		l_debug_info);
	END IF;

        EXCEPTION
		WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
			IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
				FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME || l_api_name,
                               			SQLERRM);
			END IF;
    			APP_EXCEPTION.RAISE_EXCEPTION;
	    WHEN OTHERS THEN
	        	WF_CORE.CONTEXT(G_MODULE_NAME, l_api_name, l_event_name,
                                	l_event_key);
		    	RAISE;
END Raise_Supplier_Event;

-- Bug 9143273 Added API Is_Vendor_Site_Merged for ISP to decide if a supplier is
--             merged or not. If the Supplier is merged then ISP should make the
--             end date field as the merged date and protect this field from the
--             UI update.
FUNCTION Is_Vendor_Site_Merged(
    p_vendor_site_id IN VARCHAR2
    )
RETURN VARCHAR2
IS
          l_ret_value            VARCHAR2(1);
          l_vndr_site_merged_cnt NUMBER;
BEGIN
    l_ret_value := 'N';

    SELECT COUNT( * )
      INTO l_vndr_site_merged_cnt
      FROM ap_duplicate_vendors_all adv
     WHERE adv.duplicate_vendor_site_id = p_vendor_site_id
       AND NVL(adv.process_flag,'N') = 'Y'
       AND ROWNUM=1;

    IF l_vndr_site_merged_cnt = 0 THEN
       l_ret_value       := 'N';
    ELSE
       l_ret_value       := 'Y';
    END IF;

   RETURN l_ret_value;

END Is_Vendor_Site_Merged;
--Bug 9143273 End


END AP_VENDOR_PUB_PKG;

/
