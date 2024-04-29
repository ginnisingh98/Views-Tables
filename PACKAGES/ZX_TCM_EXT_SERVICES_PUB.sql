--------------------------------------------------------
--  DDL for Package ZX_TCM_EXT_SERVICES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TCM_EXT_SERVICES_PUB" AUTHID CURRENT_USER AS
/* $Header: zxpservs.pls 120.9 2005/12/15 19:34:10 hsi ship $ */

Procedure GET_DEFAULT_STATUS_RATES(
            p_tax_regime_code        IN  ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
            p_tax                    IN  ZX_TAXES_B.TAX%TYPE,
            p_date                   IN  DATE,
            p_tax_status_code        OUT NOCOPY ZX_STATUS_B.TAX_STATUS_CODE%TYPE,
            p_tax_rate_code          OUT NOCOPY ZX_RATES_B.TAX_RATE_CODE%TYPE,
            P_RETURN_STATUS          OUT NOCOPY VARCHAR2);

Procedure GET_DEFAULT_CLASSIF_CODE(
            p_fiscal_type_code       IN  ZX_FC_TYPES_B.CLASSIFICATION_TYPE_CODE%TYPE,
            p_country_code           IN  FND_TERRITORIES.TERRITORY_CODE%TYPE,
            p_application_id         IN ZX_EVNT_CLS_MAPPINGS.APPLICATION_ID%TYPE,
            p_entity_code            IN ZX_EVNT_CLS_MAPPINGS.ENTITY_CODE%TYPE,
            p_event_class_code       IN ZX_EVNT_CLS_MAPPINGS.EVENT_CLASS_CODE%TYPE,
            p_source_event_class_code       IN ZX_EVNT_CLS_MAPPINGS.EVENT_CLASS_CODE%TYPE,
            p_item_id                IN MTL_SYSTEM_ITEMS_B.INVENTORY_ITEM_ID%TYPE,
            p_org_id                 IN MTL_SYSTEM_ITEMS_B.ORGANIZATION_ID%TYPE,
            p_default_code           OUT NOCOPY VARCHAR2,
            P_RETURN_STATUS          OUT NOCOPY VARCHAR2);


Procedure GET_DEFAULT_PRODUCT_CLASSIF(
            p_country_code           IN  FND_TERRITORIES.TERRITORY_CODE%TYPE,
            p_item_id                IN MTL_SYSTEM_ITEMS_B.INVENTORY_ITEM_ID%TYPE,
            p_org_id                 IN MTL_SYSTEM_ITEMS_B.ORGANIZATION_ID%TYPE,
            p_default_code           OUT NOCOPY VARCHAR2,
            P_RETURN_STATUS          OUT NOCOPY VARCHAR2);

FUNCTION  ZX_GET_PROD_CATEG (p_product_category IN OUT  NOCOPY VARCHAR2,
                   p_product_fc IN OUT  NOCOPY VARCHAR2,
                   p_country_code IN  VARCHAR2) RETURN VARCHAR2;

FUNCTION IS_INV_INSTALLED RETURN BOOLEAN;

/**************************************************************************
 *                                                                        *
 * Name       : Get_Default_Tax_Reg                                       *
 * Purpose    : Returns the Default Registration Number for a Given Party *
 * Logic      : In case there is tax registration mark as default         *
 *              the function will return the registration number          *
 *              associated to that record. Second case the function will  *
 *              look for the registration row with null regime            *
 *              (migrated records)                                        *
 * Parameters : P_Party_ID ------------ P_Party_Type                      *
 *              Party_Id                CUSTOMER                          *
 *              Party_Site_Id           CUSTOMER_SITE                     *
 *              Vendor_id               SUPPLIER                          *
 *              Vendor_Site_ID          SUPPLIER_SITE                     *
 *              Party_ID                LEGAL_ESTABLISHMENT               *
 *                                                                        *
 *                                                                        *
 **************************************************************************/
FUNCTION Get_Default_Tax_Reg
              (P_Party_ID          IN         zx_party_tax_profile.party_id%Type,
               P_Party_Type        IN         zx_party_tax_profile.party_type_code%Type,
               P_Effective_Date    IN         zx_registrations.effective_from%Type,
               x_return_status     OUT NOCOPY VARCHAR2
              )
RETURN Varchar2;

/* ======================================================================*
 | API TO GET  LE FOR AP IMPORT TRANSACTIONS                             |
 * ======================================================================*/
FUNCTION get_le_from_tax_registration
       (
          x_return_status     OUT NOCOPY VARCHAR2,
          p_registration_num  IN         ZX_REGISTRATIONS.Registration_Number%type,
          p_effective_date    IN         ZX_REGISTRATIONS.effective_from%type,
          p_country           IN         ZX_PARTY_TAX_PROFILE.Country_code%type
       ) RETURN Number;
END ZX_TCM_EXT_SERVICES_PUB;


 

/
