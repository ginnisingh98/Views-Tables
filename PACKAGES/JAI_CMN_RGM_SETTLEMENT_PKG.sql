--------------------------------------------------------
--  DDL for Package JAI_CMN_RGM_SETTLEMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_CMN_RGM_SETTLEMENT_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_cmn_rgm_stl.pls 120.3.12010000.2 2008/10/17 09:48:02 jmeena ship $ */
-- #****************************************************************************************************************************************************************************************
-- #
-- # Change History -
-- # 1. 27-Jan-2005   Sanjikum for Bug #4059774 Version #115.0
-- #                  New Package created for Service Tax settlement

--     2. 08-Jun-2005  Version 116.1 jai_cmn_rgm_stl -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
--    as required for CASE COMPLAINCE.

--	3. 25-April-2007   ssawant for bug 5879769 ,File version
--                Forward porting of
--		ENH : SERVICE TAX BY INVENTORY ORGANIZATION AND SERVICE TYPE SOLUTION from 11.5( bug no 5694855) to R12 (bug no 5879769).
--		Added p_service_type_code in get_last_balance_amount procedure
--	4.  14-OCT-2008		JMEENA for bug#7445742
--						Incorporate the changes of bug#6835541
-- # Future Dependencies For the release Of this Object:-
-- # (Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
-- #  A datamodel change )


--==============================================================================================================
-- #  --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- #  Current Version       Current Bug    Dependent           Files                                  Version     Author   Date         Remarks
-- #  Of File                              On Bug/Patchset    Dependent On
-- #  jai_rgm_settlement_pkg_s.sql
-- #  --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- #  115.0                 4068930         4146708                                                                 Sanjikum 27/01/2005   This file is part of Service tax enhancement. So
-- #                                                                                                                                      dependent on Service Tax and Education Cess Enhancement
-- #  115.2                 4245365         4245089                                                                Rchandan  17/03/2005   Changes were made to implement VAT. Two new procedures are added to this package
-- #  --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- # ****************************************************************************************************************************************************************************************

  PROCEDURE transfer_balance( pn_settlement_id    IN    jai_rgm_stl_balances.settlement_id%TYPE,
                              pv_process_flag OUT NOCOPY VARCHAR2,
                              pv_process_message OUT NOCOPY VARCHAR2);

  PROCEDURE create_invoice( pn_regime_id          IN  jai_rgm_settlements.regime_id%TYPE,
                            pn_settlement_id      IN  jai_rgm_settlements.settlement_id%TYPE,
                            pd_settlement_date    IN  jai_rgm_settlements.settlement_date%TYPE,
                            pn_vendor_id          IN  jai_rgm_settlements.tax_authority_id%TYPE,
                            pn_vendor_site_id     IN  jai_rgm_settlements.tax_authority_site_id%TYPE,
                            pn_calculated_amount  IN  jai_rgm_settlements.calculated_amount%TYPE,
                            pn_invoice_amount     IN  jai_rgm_settlements.payment_amount%TYPE,
                            pn_org_id             IN  jai_rgm_stl_balances.party_id%TYPE,
                            pv_regsitration_no    IN  jai_rgm_settlements.primary_registration_no%TYPE,
                            pn_created_by         IN  ap_invoices_interface.created_by%TYPE,
                            pd_creation_date      IN  ap_invoices_interface.creation_date%TYPE,
                            pn_last_updated_by    IN  ap_invoices_interface.last_updated_by%TYPE,
                            pd_last_update_date   IN  ap_invoices_interface.last_update_date%TYPE,
                            pn_last_update_login  IN  ap_invoices_interface.last_update_login%TYPE,
                            pv_system_invoice_no OUT NOCOPY jai_rgm_settlements.system_invoice_no%TYPE,
                            pv_process_flag OUT NOCOPY VARCHAR2,
                            pv_process_message OUT NOCOPY VARCHAR2);

  FUNCTION get_last_settlement_date(pn_org_id IN  jai_rgm_stl_balances.party_id%TYPE,
                                    /* Bug 5096787. Added by Lakshmi Gopalsami */
            pn_regime_id IN jai_rgm_settlements.regime_id%TYPE DEFAULT NULL
                                    )
    RETURN DATE;

  PROCEDURE get_last_balance_amount(pn_org_id         IN  jai_rgm_stl_balances.party_id%TYPE,
                                    pv_tax_type       IN  jai_rgm_stl_balances.tax_type%TYPE,
                                    pn_debit_amount OUT NOCOPY jai_rgm_stl_balances.debit_balance%TYPE,
                                    pn_credit_amount OUT NOCOPY jai_rgm_stl_balances.credit_balance%TYPE);

  PROCEDURE register_entry( pn_regime_id          IN  NUMBER,
                            pn_settlement_id      IN  NUMBER,
                            pd_transaction_date   IN  DATE,
                            pv_process_flag OUT NOCOPY VARCHAR2,
                            pv_process_message OUT NOCOPY VARCHAR2);

  FUNCTION get_last_settlement_date(pn_regime_id IN jai_rgm_settlements.regime_id%type,
                                    pn_org_id IN  jai_rgm_stl_balances.party_id%TYPE,
                                    pn_location_id IN  jai_rgm_stl_balances.location_id%TYPE)
    RETURN DATE; ---4245365
/*Below code add by JMEENA for bug#7445742 */
  /*
 	 ||The following function addded by rchandan for bug#6835541
 	 ||This function is used for VAT settlement where the user has the flexibility of
 	 || of doing settlement at either registartion or organization or organization-location level
 	 */
  FUNCTION get_last_settlement_date(pn_regime_id   IN NUMBER,
                                    pn_regn_no     IN VARCHAR2,
                                    pn_organization_id      IN NUMBER,
                                    pn_location_id IN NUMBER)
  RETURN DATE;

  PROCEDURE get_last_balance_amount(pn_regime_id      IN  jai_rgm_settlements.regime_id%type,
                                    pn_org_id         IN  jai_rgm_stl_balances.party_id%TYPE,
                                    pn_location_id    IN  jai_rgm_stl_balances.location_id%TYPE,
                                    pv_tax_type       IN  jai_rgm_stl_balances.tax_type%TYPE,
                                    pn_debit_amount   OUT NOCOPY jai_rgm_stl_balances.debit_balance%TYPE,
                                    pn_credit_amount  OUT NOCOPY jai_rgm_stl_balances.credit_balance%TYPE,
				    pv_service_type_code IN jai_rgm_stl_balances.service_type_code%TYPE DEFAULT NULL /* added by ssawant for bug 5879769 */
				    );   ---4245365

END jai_cmn_rgm_settlement_pkg;

/
