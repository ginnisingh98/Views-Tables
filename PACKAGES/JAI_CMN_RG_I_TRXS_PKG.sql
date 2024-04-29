--------------------------------------------------------
--  DDL for Package JAI_CMN_RG_I_TRXS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_CMN_RG_I_TRXS_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_cmn_rg_i.pls 120.2 2007/05/02 11:04:04 bduvarag ship $ */

	PROCEDURE validate_rg1_balances(
		P_ORGANIZATION_ID                 IN NUMBER,
		P_LOCATION_ID                     IN NUMBER,
		P_INVENTORY_ITEM_ID               IN NUMBER,
		P_FIN_YEAR                        IN NUMBER,
		P_QUANTITY                        IN NUMBER,
		P_TRANSACTION_UOM_CODE            IN VARCHAR2,
		P_TRANSACTION_TYPE                IN VARCHAR2,
		P_ERR_BUF OUT NOCOPY VARCHAR2
	);

	FUNCTION get_rg1_transaction_id(
		P_TRANSACTION_TYPE                IN VARCHAR2,
		P_ISSUE_TYPE                      IN VARCHAR2,
		P_CALLED_FROM                     IN VARCHAR2
	) RETURN NUMBER;

	PROCEDURE create_rg1_entry(
		P_REGISTER_ID OUT NOCOPY NUMBER,
		P_REGISTER_ID_PART_II             IN NUMBER,
		P_FIN_YEAR                        IN NUMBER,
		P_SLNO OUT NOCOPY NUMBER,
		P_TRANSACTION_ID                  IN NUMBER,
		P_ORGANIZATION_ID                 IN NUMBER,
		P_LOCATION_ID                     IN NUMBER,
		P_TRANSACTION_DATE                IN DATE,
		P_INVENTORY_ITEM_ID               IN NUMBER,
		P_TRANSACTION_TYPE                IN VARCHAR2,
		P_REF_DOC_ID                      IN VARCHAR2,
		P_QUANTITY                        IN NUMBER,
		P_TRANSACTION_UOM_CODE            IN VARCHAR2,
		P_ISSUE_TYPE                      IN VARCHAR2,
		P_EXCISE_DUTY_AMOUNT              IN NUMBER,
		P_EXCISE_INVOICE_NUMBER           IN VARCHAR2,
		P_EXCISE_INVOICE_DATE             IN DATE,
		P_PAYMENT_REGISTER                IN VARCHAR2,
		P_CHARGE_ACCOUNT_ID               IN NUMBER,
		P_RANGE_NO                        IN VARCHAR2,
		P_DIVISION_NO                     IN VARCHAR2,
		P_REMARKS                         IN VARCHAR2,
		P_BASIC_ED                        IN NUMBER,
		P_ADDITIONAL_ED                   IN NUMBER,
		P_OTHER_ED                        IN NUMBER,
		P_ASSESSABLE_VALUE                IN NUMBER,
		P_EXCISE_DUTY_RATE                IN NUMBER,
		P_VENDOR_ID                       IN NUMBER,
		P_VENDOR_SITE_ID                  IN NUMBER,
		P_CUSTOMER_ID                     IN NUMBER,
		P_CUSTOMER_SITE_ID                IN NUMBER,
		P_CREATION_DATE                   IN DATE,
		P_CREATED_BY                      IN NUMBER,
		P_LAST_UPDATE_DATE                IN DATE,
		P_LAST_UPDATED_BY                 IN NUMBER,
		P_LAST_UPDATE_LOGIN               IN NUMBER,
		P_CALLED_FROM                     IN VARCHAR2,
P_CESS_AMOUNT                     IN NUMBER DEFAULT NULL,/*Added for the Bug
2942973 to resolve compilation error - bduvarag*/
		P_SH_CESS_AMOUNT                  IN NUMBER DEFAULT NULL/*Bug 5989740 bduvarag*/
	);

END jai_cmn_rg_i_trxs_pkg;

/
