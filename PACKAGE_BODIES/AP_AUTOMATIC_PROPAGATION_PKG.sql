--------------------------------------------------------
--  DDL for Package Body AP_AUTOMATIC_PROPAGATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_AUTOMATIC_PROPAGATION_PKG" AS
/* $Header: apautprb.pls 120.0.12010000.3 2010/03/03 16:52:46 dawasthi noship $ */

FUNCTION Get_Affected_Invoices_Count(
   P_external_bank_account_id iby_ext_bank_accounts.ext_bank_account_id%TYPE,
   P_vendor_id                ap_suppliers.vendor_id%TYPE,
   P_vendor_site_id           ap_supplier_sites.vendor_site_id%TYPE DEFAULT NULL,
   P_party_Site_Id            ap_supplier_sites.party_site_id%TYPE  DEFAULT NULL,
   P_org_id                   ap_invoices.org_id%TYPE  DEFAULT NULL
  ) RETURN NUMBER IS
  l_affected_invoices NUMBER := 0;
BEGIN
  BEGIN
    --Address + OU level checking
    IF (P_party_Site_Id IS NOT NULL and P_org_Id IS NOT NULL) THEN
      SELECT COUNT(DISTINCT ai.invoice_id)
      INTO   l_affected_invoices
      FROM   ap_invoices_all ai, ap_payment_schedules_all aps
      WHERE  aps.external_bank_account_id  = p_external_bank_account_id
         AND    ai.invoice_id                 = aps.invoice_id
         AND    ai.payment_status_flag        IN ('N','P')
         AND    ai.cancelled_date             IS NULL
         AND    ai.vendor_id                = p_vendor_id
         AND    ai.org_id                   = p_org_id
         AND    (ai.party_site_id           = p_party_site_id
	         or ( ai.party_site_id is null
		      and  ai.vendor_site_id in (select vendor_site_id
		                                 from ap_supplier_sites ass
		                                 where ass.party_site_id = p_party_site_id
					           and ass.vendor_id   = p_vendor_id)
                    )
		 );

    --Address level checking
    ELSIF (P_party_Site_Id IS NOT NULL) THEN
      SELECT COUNT(DISTINCT ai.invoice_id)
      INTO   l_affected_invoices
      FROM   ap_invoices_all ai, ap_payment_schedules_all aps
      WHERE  aps.external_bank_account_id  = p_external_bank_account_id
         AND    ai.invoice_id                 = aps.invoice_id
         AND    ai.payment_status_flag        IN ('N','P')
         AND    ai.cancelled_date             IS NULL
         AND    ai.vendor_id                = p_vendor_id
         AND    (ai.party_site_id           = p_party_site_id
	         or ( ai.party_site_id is null
		      and  ai.vendor_site_id in (select vendor_site_id
		                                 from ap_supplier_sites ass
		                                 where ass.party_site_id = p_party_site_id
					           and ass.vendor_id   = p_vendor_id)
                    )
		 );

        --Supplier Site level checking
    ELSIF p_vendor_site_id IS NOT NULL THEN
      SELECT COUNT(DISTINCT ai.invoice_id)
      INTO   l_affected_invoices
      FROM   ap_invoices_all ai, ap_payment_schedules_all aps
      WHERE  aps.external_bank_account_id  = p_external_bank_account_id
        AND    ai.invoice_id                 = aps.invoice_id
        AND    ai.payment_status_flag        IN ('N','P')
        AND    ai.cancelled_date             IS NULL
        AND    ai.vendor_id                  = p_vendor_id
        AND    ai.vendor_site_id             = p_vendor_site_id;
              --Supplier level checking
    ELSE
      SELECT COUNT(DISTINCT ai.invoice_id)
      INTO   l_affected_invoices
      FROM   ap_invoices_all ai, ap_payment_schedules_all aps
      WHERE  aps.external_bank_account_id  = p_external_bank_account_id
        AND    ai.invoice_id                 = aps.invoice_id
        AND    ai.payment_status_flag        IN ('N','P')
        AND    ai.cancelled_date             IS NULL
        AND    ai.vendor_id                  = p_vendor_id;
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_affected_invoices := 0;
  END;
  RETURN l_affected_invoices;
END Get_Affected_Invoices_Count;

PROCEDURE Update_Payment_Schedules (
    p_from_bank_account_id iby_ext_bank_accounts.ext_bank_account_id%TYPE,
    p_to_bank_account_id   iby_ext_bank_accounts.ext_bank_account_id%TYPE,
    p_vendor_id            ap_suppliers.vendor_id%TYPE,
    P_vendor_site_id       ap_supplier_sites.vendor_site_id%TYPE DEFAULT NULL,
    P_party_Site_Id        ap_supplier_sites.party_site_id%TYPE  DEFAULT NULL,
    P_org_id               ap_invoices.org_id%TYPE  DEFAULT NULL,
    P_party_id             ap_suppliers.party_id%TYPE	DEFAULT NULL			-- Added for bug 9410719
   ) IS

-- Added for bug 9410719
G_LEVEL_STATEMENT       CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_MODULE_NAME           CONSTANT VARCHAR2(50) := 'AP_AUTOMATIC_PROPAGATION_PKG';

l_api_name              VARCHAR2(100) := 'Update_Payment_Schedules';
l_debug_info            varchar2(3000);

l_to_bank_account_id    iby_ext_bank_accounts.ext_bank_account_id%TYPE;
P_org_type		IBY_EXTERNAL_PAYEES_ALL.org_type%TYPE	:= 'OPERATING_UNIT';
P_pmt_function		IBY_EXTERNAL_PAYEES_ALL.payment_function%TYPE	:= 'PAYABLES_DISB';

BEGIN
   -- Added debug messages for bug 9410719
    l_debug_info := 'ENTER Update_Payment_Schedules';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    l_debug_info := 'P_org_Id :'||P_org_Id;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    l_debug_info := 'P_from_bank_account_id :'||p_from_bank_account_id;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    l_debug_info := 'p_vendor_id :'||p_vendor_id;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    l_debug_info := 'p_party_id :'||p_party_id;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    l_debug_info := 'P_party_Site_Id :'||P_party_Site_Id;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    l_debug_info := 'Calling IBY_DISBURSE_UI_API_PUB_PKG.intialize';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    IBY_DISBURSE_UI_API_PUB_PKG.initialize;

   IF (P_party_Site_Id IS NOT NULL and P_org_Id IS NOT NULL) THEN
	-- Added For Loop/IBY Call for bug 9410719
	FOR x IN (SELECT aps.invoice_id, aps.payment_num, ai.payment_currency_code, ai.vendor_site_id
                  FROM   ap_payment_schedules_all aps,ap_invoices_all ai
                  WHERE  aps.invoice_id = ai.invoice_id
                  AND    aps.external_bank_account_id = p_from_bank_account_id
                  AND    ai.payment_status_flag        IN ('N','P')
                  AND    ai.cancelled_date             IS NULL
                  AND    ai.vendor_id                  = p_vendor_id
                  AND    ai.org_id                     = p_org_id
                  AND   (ai.party_site_id              = p_party_site_id
                         OR   (ai.party_site_id is NULL
                               AND  ai.vendor_site_id in (SELECT vendor_site_id
                                                          FROM ap_supplier_sites ass
                                                          WHERE ass.party_site_id = p_party_site_id
                                                          AND ass.vendor_id   = p_vendor_id)
                              )
                        )
                  )
          LOOP
                BEGIN
			IBY_DISBURSE_UI_API_PUB_PKG.get_default_bank_acct(x.payment_currency_code,
				                                          P_party_id,
					                                  P_party_Site_Id,
						                          x.vendor_site_id,
							                  P_org_id,
								          P_org_type,
									  P_pmt_function,
									  p_from_bank_account_id,
	                                                                  l_to_bank_account_id
		                                                         );

			l_debug_info := '1. l_to_bank_account_id returned :'||p_to_bank_account_id;
	                IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
	                END IF;


			UPDATE ap_payment_schedules_all aps
			SET aps.external_bank_account_id = l_to_bank_account_id,
		            last_update_date  = SYSDATE,
			    last_updated_by   = FND_GLOBAL.user_id,
		            last_update_login = FND_GLOBAL.login_id
		        WHERE aps.invoice_id = x.invoice_id -- Added and commented below code for bug 9410719
			AND   aps.payment_num = x.payment_num;

/*			WHERE aps.invoice_id IN
           (SELECT DISTINCT ai.invoice_id
            FROM   ap_invoices_all ai, ap_payment_schedules_all aps
            WHERE  aps.external_bank_account_id  = p_from_bank_account_id
            AND    ai.invoice_id                 = aps.invoice_id
            AND    ai.payment_status_flag        IN ('N','P')
            AND    ai.cancelled_date             IS NULL
            AND    ai.vendor_id                  = p_vendor_id
            AND    ai.org_id                     = p_org_id
            AND   (ai.party_site_id           = p_party_site_id
	           or ( ai.party_site_id is null
		      and  ai.vendor_site_id in (select vendor_site_id
		                                 from ap_supplier_sites ass
		                                 where ass.party_site_id = p_party_site_id
					           and ass.vendor_id   = p_vendor_id)
                     )
		   )
	    );
  */
-- Added Exception handling for above code for bug 9410719
		EXCEPTION
			WHEN OTHERS THEN
				l_debug_info := 'Exception occured when party_site_id and org_id is not null :'||SQLERRM;
				IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
		                END IF;
                END;
          END LOOP;

   ELSIF (P_party_Site_Id IS NOT NULL) THEN
	-- Added For Loop/IBY Call for bug 9410719
	FOR x IN (SELECT aps.invoice_id, aps.payment_num, ai.payment_currency_code, ai.vendor_site_id, ai.org_id
                  FROM ap_payment_schedules_all aps,ap_invoices_all ai
                  WHERE aps.invoice_id		    = ai.invoice_id
                  AND aps.external_bank_account_id  = p_from_bank_account_id
                  AND    ai.payment_status_flag     IN ('N','P')
                  AND    ai.cancelled_date          IS NULL
                  AND    ai.vendor_id               = p_vendor_id
                  AND   (ai.party_site_id           = p_party_site_id
                          OR (ai.party_site_id IS NULL
                              AND  ai.vendor_site_id IN (SELECT vendor_site_id
                                                         FROM ap_supplier_sites ass
                                                         WHERE ass.party_site_id = p_party_site_id
                                                         AND ass.vendor_id   = p_vendor_id)
                              )
                          )
                  )
          LOOP
                BEGIN
			IBY_DISBURSE_UI_API_PUB_PKG.get_default_bank_acct(x.payment_currency_code,
				                                          P_party_id,
					                                  P_party_Site_Id,
						                          x.vendor_site_id,
							                  x.org_id,
								          P_org_type,
									  P_pmt_function,
									  p_from_bank_account_id,
	                                                                  l_to_bank_account_id
		                                                          );

			l_debug_info := '2. l_to_bank_account_id returned :'||p_to_bank_account_id;
	                IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
	                END IF;

			UPDATE ap_payment_schedules_all aps
		        SET aps.external_bank_account_id = l_to_bank_account_id,
		            last_update_date  = SYSDATE,
		            last_updated_by   = FND_GLOBAL.user_id,
		            last_update_login = FND_GLOBAL.login_id
		        WHERE aps.invoice_id = x.invoice_id -- Added and commented below code for bug 9410719
			AND   aps.payment_num = x.payment_num;

/*			WHERE aps.invoice_id IN
           (SELECT DISTINCT ai.invoice_id
            FROM   ap_invoices_all ai, ap_payment_schedules_all aps
            WHERE  aps.external_bank_account_id  = p_from_bank_account_id
            AND    ai.invoice_id                 = aps.invoice_id
            AND    ai.payment_status_flag        IN ('N','P')
            AND    ai.cancelled_date             IS NULL
            AND    ai.vendor_id                  = p_vendor_id
            AND   (ai.party_site_id           = p_party_site_id
	           or ( ai.party_site_id is null
		      and  ai.vendor_site_id in (select vendor_site_id
		                                 from ap_supplier_sites ass
		                                 where ass.party_site_id = p_party_site_id
					           and ass.vendor_id   = p_vendor_id)
                     )
		   )
	    );
 */
-- Added Exception handling for above code for bug 9410719
		EXCEPTION
                    WHEN OTHERS THEN
                         l_debug_info := 'Exception occured when party_site_id is not null :'||SQLERRM;
                         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
                         END IF;
                END;
        END LOOP;

   ELSIF (p_vendor_site_id IS NOT NULL) THEN
	-- Added For Loop/IBY Call for bug 9410719
	FOR x in (SELECT aps.invoice_id, aps.payment_num, ai.payment_currency_code, ai.party_site_id, ai.org_id
                  FROM ap_payment_schedules_all aps,ap_invoices_all ai
                  WHERE aps.invoice_id = ai.invoice_id
                  AND aps.external_bank_account_id     = p_from_bank_account_id
                  AND    ai.payment_status_flag        IN ('N','P')
	          AND    ai.cancelled_date             IS NULL
		  AND    ai.vendor_id                  = p_vendor_id
                  AND    ai.vendor_site_id             = p_vendor_site_id
                 )
        LOOP
            BEGIN
		IBY_DISBURSE_UI_API_PUB_PKG.get_default_bank_acct(x.payment_currency_code,
                                                                  P_party_id,
                                                                  x.party_Site_Id,
                                                                  P_vendor_site_id,
                                                                  x.org_id,
                                                                  P_org_type,
                                                                  P_pmt_function,
								  p_from_bank_account_id,
                                                                  l_to_bank_account_id
                                                                  );

                l_debug_info := '3. l_to_bank_account_id returned :'||p_to_bank_account_id;
                IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
                END IF;

	       UPDATE ap_payment_schedules_all aps
	       SET aps.external_bank_account_id = l_to_bank_account_id,
	            last_update_date  = SYSDATE,
		    last_updated_by   = FND_GLOBAL.user_id,
	            last_update_login = FND_GLOBAL.login_id
		WHERE aps.invoice_id = x.invoice_id -- Added and commented below code for bug 9410719
		AND   aps.payment_num = x.payment_num;

/*		WHERE aps.invoice_id IN
           (SELECT DISTINCT ai.invoice_id
            FROM   ap_invoices_all ai, ap_payment_schedules_all aps
            WHERE  aps.external_bank_account_id  = p_from_bank_account_id
            AND    ai.invoice_id                 = aps.invoice_id
            AND    ai.payment_status_flag        IN ('N','P')
            AND    ai.cancelled_date             IS NULL
            AND    ai.vendor_id                  = p_vendor_id
            AND    ai.vendor_site_id             = p_vendor_site_id);
*/
-- Added Exception handling for above code for bug 9410719
	   EXCEPTION
                  WHEN OTHERS THEN
                       l_debug_info := 'Exception occured when vendor_site_id is not null :'||SQLERRM;
                       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
                       END IF;
           END;
        END LOOP;

   ELSE
   -- Added For Loop/IBY Call for bug 9410719
	FOR x in (SELECT aps.invoice_id, aps.payment_num, ai.payment_currency_code, ai.party_site_id, ai.org_id, ai.vendor_site_id
                  FROM ap_payment_schedules_all aps,ap_invoices_all ai
                  WHERE aps.invoice_id		       = ai.invoice_id
                  AND aps.external_bank_account_id     = p_from_bank_account_id
                  AND    ai.payment_status_flag        IN ('N','P')
                  AND    ai.cancelled_date             IS NULL
                  AND    ai.vendor_id                  = p_vendor_id
                  )
        LOOP
            BEGIN
                IBY_DISBURSE_UI_API_PUB_PKG.get_default_bank_acct(x.payment_currency_code,
                                                                  P_party_id,
                                                                  x.party_Site_Id,
                                                                  x.vendor_site_id,
                                                                  x.org_id,
                                                                  P_org_type,
                                                                  P_pmt_function,
								  p_from_bank_account_id,
                                                                  l_to_bank_account_id
                                                                  );

                l_debug_info := '4. l_to_bank_account_id returned :'||p_to_bank_account_id;
                IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
                END IF;


		UPDATE ap_payment_schedules_all aps
		SET aps.external_bank_account_id = l_to_bank_account_id,
	            last_update_date  = SYSDATE,
	            last_updated_by   = FND_GLOBAL.user_id,
	            last_update_login = FND_GLOBAL.login_id
		WHERE aps.invoice_id = x.invoice_id -- Added and commented below code for bug 9410719
		AND   aps.payment_num = x.payment_num;

/*		WHERE aps.invoice_id IN
           (SELECT DISTINCT ai.invoice_id
            FROM   ap_invoices_all ai, ap_payment_schedules_all aps
            WHERE  aps.external_bank_account_id  = p_from_bank_account_id
            AND    ai.invoice_id                 = aps.invoice_id
            AND    ai.payment_status_flag        IN ('N','P')
            AND    ai.cancelled_date             IS NULL
            AND    ai.vendor_id                  = p_vendor_id)
*/
	    EXCEPTION
                WHEN OTHERS THEN
                     l_debug_info := 'Exception occured when vendor_id is not null :'||SQLERRM;
                     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
                     END IF;
            END;
        END LOOP;
 END IF;
EXCEPTION WHEN OTHERS THEN
	l_debug_info := 'Exception occured :'||SQLERRM;
	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
	END IF;

END Update_Payment_Schedules;

END AP_AUTOMATIC_PROPAGATION_PKG;

/
