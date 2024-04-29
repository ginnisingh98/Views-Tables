--------------------------------------------------------
--  DDL for Package Body AP_UPDATE_1099_AWT_DISTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_UPDATE_1099_AWT_DISTS_PKG" AS
/* $Header: apupawtb.pls 120.0 2003/06/13 17:56:21 isartawi noship $ */

----------------------------------------------------------------------------
FUNCTION Get_Income_Tax_Region(
                P_invoice_id           IN     NUMBER,
                P_calling_sequence     IN     VARCHAR2 )
RETURN    VARCHAR2  IS
    --
    l_result                      BOOLEAN;
    l_state                       VARCHAR2(10);
    l_debug_info                  VARCHAR2(240);
    l_current_calling_sequence    VARCHAR2(200);
    --
BEGIN
    l_current_calling_sequence := P_calling_sequence||'->'||
                    'Get_Income_Tax_Region';
    --
    l_debug_info := 'Get Income Tax Region';
    --
    SELECT  SUBSTR(state, 1, 10)
    INTO    l_state
    FROM    po_vendor_sites   PVS,
            ap_invoices       AI
    WHERE   AI.invoice_id       = P_invoice_id
    AND     PVS.vendor_site_id  = AI.vendor_site_id;
    --
    return (l_state);
    --
EXCEPTION
    WHEN OTHERS THEN
    IF (SQLCODE <> -20001 ) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info );
        FND_MESSAGE.SET_TOKEN('PARAMETERS','P_invoice_id: '
                              ||TO_CHAR(P_invoice_id)
                              );
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
    --
END Get_Income_Tax_Region;
--
PROCEDURE Upgrade(
            errbuf             OUT NOCOPY VARCHAR2,
            retcode            OUT NOCOPY NUMBER,
            P_calling_sequence IN  VARCHAR2 ) IS
    --
    l_request_id               NUMBER;
    l_login_id                 NUMBER;
    l_user_id                  NUMBER;
    l_program_application_id   NUMBER;
    l_program_id               NUMBER;
    l_result                   BOOLEAN;
    l_debug_info               VARCHAR2(240);
    l_date                     VARCHAR2(10);
    l_Start_dt                 VARCHAR2(10);
    l_Start_date               DATE;
    l_mm                       NUMBER;
    l_yyyy                     NUMBER;
    l_count                    INTEGER := 0;
    l_total_count              INTEGER := 0;
    --
    l_enable_1099_on_awt_flag  ap_system_parameters.enable_1099_on_awt_flag%TYPE;
    l_federal_reportable_flag  po_vendors.federal_reportable_flag%TYPE;
    l_type_1099                ap_invoice_distributions.type_1099%TYPE;
    l_combined_filing_flag     ap_system_parameters.combined_filing_flag%TYPE;
    l_income_tax_region_asp    ap_system_parameters.income_tax_region%TYPE;
    l_income_tax_region_pvs    ap_system_parameters.income_tax_region%TYPE;
    l_income_tax_region        ap_system_parameters.income_tax_region%TYPE;
    l_income_tax_region_flag   ap_system_parameters.income_tax_region_flag%TYPE;
    --
    l_commit_size                   INTEGER := 10000;
    l_min_invoice_distribution_id   NUMBER;
    l_max_invoice_distribution_id   NUMBER;

    l_current_calling_sequence  VARCHAR2(2000);
BEGIN
    --
    l_current_calling_sequence := P_calling_sequence||'->'||
           'Ap_Update_1099_Awt_Dists_Pkg.Upgrade';
    --
    SELECT  TO_CHAR(SYSDATE, 'YYYY/MM/DD' )
    INTO    l_date
    FROM    dual;
    --
    l_debug_info := 'Sysdate '||l_date;
    --
    l_mm := to_number(SUBSTR(l_date, 6, 2));
    l_yyyy := to_number(substr(l_date, 1, 4));
    if l_mm < 3 then
        l_yyyy := l_yyyy -1;
    end if;
    --
    l_start_dt   := to_char(l_yyyy)||'/01/01';
    --
    l_debug_info := 'l_start_dt  '||l_start_dt;
    --
    l_start_date := FND_DATE.CANONICAL_TO_DATE(l_start_dt);
    --
    l_debug_info := 'Get Profiles';
    --
    l_user_id                := FND_GLOBAL.user_id;
    l_request_id             := FND_GLOBAL.conc_request_id;
    l_login_id               := FND_GLOBAL.login_id;
    l_program_application_id := FND_GLOBAL.prog_appl_id;
    l_program_id             := FND_GLOBAL.conc_program_id;

    l_debug_info := 'Get Info from Ap System Parameters';
    --
    SELECT NVL(enable_1099_on_awt_flag, 'N'),
           combined_filing_flag,
           income_tax_region_flag,
           income_tax_region
    INTO   l_enable_1099_on_awt_flag,
           l_combined_filing_flag,
           l_income_tax_region_flag,
           l_income_tax_region
    FROM   ap_system_parameters;
    --
    SELECT NVL(MIN(invoice_distribution_id),0),
           NVL(MAX(invoice_distribution_id),0)
    INTO   l_min_invoice_distribution_id, l_max_invoice_distribution_id
    FROM   ap_invoice_distributions ID,
           ap_invoices AI,
           po_vendor_sites PVS,
           po_vendors PV
    WHERE  ID.invoice_id = AI.invoice_id
    AND    AI.vendor_site_id = PVS.vendor_site_id
    AND    PV.vendor_id = PVS.vendor_id
    AND    PV.federal_reportable_flag =  'Y'
    AND    PVS.tax_reporting_site_flag = 'Y'
    AND    NVL(ID.type_1099, 'DUMMY') <> 'MISC4'
    AND    ID.line_type_lookup_code = 'AWT'
    AND    (ID.invoice_id IN (SELECT IP.invoice_id
                              FROM   AP_Invoice_Payments IP
                              WHERE  ID.invoice_id = IP.invoice_id
                              AND    nvl(IP.accounting_date,sysdate)
                                       BETWEEN l_start_date AND sysdate
                                 )
           OR
           ID.invoice_id IN (SELECT  AI.invoice_id
                             FROM    Ap_Invoices AI
                             WHERE   ID.invoice_id = AI.invoice_id
                             AND     NVL(AI.PAYMENT_STATUS_FLAG, 'N') <> 'Y'
                             )
           );
    --
    WHILE ( l_min_invoice_distribution_id <= l_max_invoice_distribution_id AND
           l_max_invoice_distribution_id <> 0)
    --
    LOOP
        l_debug_info := 'Update TYPE_1099 on AID';
        --
        UPDATE  ap_invoice_distributions ID
        SET     ID.type_1099 = 'MISC4',
                ID.income_tax_Region =
                    decode(l_combined_filing_flag, 'Y',
                           decode(l_income_tax_region_flag, 'Y',
                           Ap_Update_1099_Awt_Dists_Pkg.Get_Income_tax_region(
                                                    ID.invoice_id,
                                                    l_current_calling_sequence),
                           l_income_tax_region
                                  ), NULL
                           ),
                ID.last_update_date = SYSDATE,
                ID.last_updated_by = l_user_id,
                ID.last_update_login = l_login_id,
                ID.program_update_date = SYSDATE,
                ID.program_application_id = l_program_application_id,
                ID.program_id = l_program_id,
                ID.request_id = l_request_id
        WHERE   ID.invoice_id IN (
                   SELECT    AI.invoice_id
                   FROM      ap_invoices AI,
                             po_vendors PV,
                             po_vendor_sites PVS
                   WHERE     AI.vendor_id      = PV.vendor_id
                   AND       AI.vendor_site_id = PVS.vendor_site_id
                   AND       PV.vendor_id = PVS.vendor_id
                   AND       PV.federal_reportable_flag =  'Y'
                   AND       PVS.tax_reporting_site_flag = 'Y'
                                 )
        AND     (ID.invoice_id IN (SELECT IP.invoice_id
                                  FROM   AP_Invoice_Payments IP
                                  WHERE  ID.invoice_id = IP.invoice_id
                                  AND    nvl(IP.accounting_date,sysdate)
                                       BETWEEN l_start_date AND sysdate
                                 )
                OR
                ID.invoice_id IN (SELECT  AI.invoice_id
                                  FROM    Ap_Invoices AI
                                  WHERE   ID.invoice_id = AI.invoice_id
                                  AND     NVL(AI.PAYMENT_STATUS_FLAG, 'N') <> 'Y'
                                  )
                )
        AND    ID.line_type_lookup_code = 'AWT'
        AND    NVL(ID.type_1099, 'DUMMY') <> 'MISC4'
        AND    invoice_distribution_id
                  BETWEEN l_min_invoice_distribution_id
    	          AND     l_min_invoice_distribution_id + l_commit_size - 1 ;
        l_count := SQL%ROWCOUNT;
        --
        COMMIT;
        --
        l_min_invoice_distribution_id := l_min_invoice_distribution_id +
                                                             l_commit_size;
        --
        l_total_count := l_count + l_total_count;
   END LOOP;
              AP_Debug_Pkg.Print('Y', '  ');
              AP_Debug_Pkg.Print('Y', 'Number of Distributions Updated  : '
                              || TO_CHAR(l_total_count));
              AP_Debug_Pkg.Print('Y', '  ');

EXCEPTION
    --
    WHEN OTHERS THEN
    IF (SQLCODE <> -20001 ) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM );
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_current_calling_sequence );
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info );
    END IF;
    --
    errbuf := FND_MESSAGE.GET;
    retcode := 2;
    --
END Upgrade;
--
END Ap_Update_1099_Awt_Dists_Pkg;

/
