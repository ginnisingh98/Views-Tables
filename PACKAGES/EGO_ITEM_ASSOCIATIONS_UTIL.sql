--------------------------------------------------------
--  DDL for Package EGO_ITEM_ASSOCIATIONS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_ITEM_ASSOCIATIONS_UTIL" AUTHID CURRENT_USER AS
/* $Header: EGOVIAUS.pls 120.1 2007/03/26 15:22:12 earumuga noship $ */

  G_SUPPLIER_NAME VARCHAR2(500) := 'aas.vendor_name';
  G_SUPPLIER_NUMBER VARCHAR2(500) := 'aas.segment1';
  G_DUNS_NUMBER VARCHAR2(500) := 'hp.duns_number_c';
  G_TAX_PAYER_ID VARCHAR2(500) := 'aas.num_1099';
  G_TAX_REGISTRATION_NUMBER VARCHAR2(500) :='aas.vat_registration_num';
  G_SUPPLIER_SITE_NAME VARCHAR2(500) := 'asa.vendor_site_code';
  G_CITY VARCHAR2(500) := 'asa.city';
  G_STATE VARCHAR2(500) := 'asa.state';
  G_COUNTRY VARCHAR2(500) := 'asa.country';

  -- Start of comments
  --  API name  : search_supplier_and_site
  --  Type      : Private.
  --  Function  : Searches the supplier and site for the given criteria
  --  Pre-reqs  :
  --                i) Search criteria is built using the constants specified in ego_item_associations_util or EgoSearchAssociationAM.
  --                ii) Search Columns and Criteria has same number of values
  --                iii) If p_search_sites is fnd_api.G_FALSE, then the criteria
  --                   for those columns should not be passed.
  --                   Will result in SQL exception if passed.
  --                iv) Atleast one criteria has been specified to search.
  --                v) Passed organization id should be master organization id.  No validation will be done from search.  Wrong value
  --                    will result in no rows.
  --  Parameters  :
  --  IN          :  p_api_version       IN NUMBER Required
  --                 p_batch_id    INOUT NOCOPY NUMBER Required
  --                 p_search_cols IN EGO_VARCHAR_TBL_TYPE Required
  --                 p_search_criteria IN EGO_VARCHAR_TBL_TYPE Required
  --                 p_search_sites IN VARCHAR2 Optional Default fnd_api.G_FALSE
  --                 p_filter_rows IN VARCHAR2 Optional Default fnd_api.G_FALSE
  --                 p_inventory_item_id IN NUMBER Optional Default NULL
  --                 p_master_org_id  IN NUMBER Required
  --                 p_search_existing_site_only IN VARCHAR2 Optional Default fnd_api.G_FALSE
  --  Version     :  Current version 1.0
  --                 Initial version   1.0
  --  Notes       :  p_search_cols contains the search criteria columns.  The list of columns are
  --                 defined as constants in ego_item_associations_util.
  --                 p_search_criteria will be corresponding search criteria for the columns.
  --                 Criteria and column names mapped based on index of the tables.
  --                 p_search_sites allows to search/return site results.
  --                 p_filter_rows specifies whether already associated needs to be filtered or not
  --                 p_master_org_id  Master Organization Id in context of which the search needs to be performed
  --                 p_search_existing_site_only Searches only existing sites.  Used in item-site-org flow
  --
  -- End of comments
  PROCEDURE search_supplier_and_site
  (
    p_api_version  IN NUMBER
    ,p_batch_id    IN OUT NOCOPY NUMBER
    ,p_search_cols IN EGO_VARCHAR_TBL_TYPE
    ,p_search_criteria IN EGO_VARCHAR_TBL_TYPE
    ,p_search_sites IN VARCHAR2 DEFAULT fnd_api.G_FALSE
    ,p_filter_rows IN VARCHAR2 := fnd_api.G_FALSE
    ,p_inventory_item_id IN NUMBER := NULL
    ,p_master_org_id IN NUMBER
    ,p_search_existing_site_only IN VARCHAR2 := fnd_api.G_FALSE
    ,p_filter_suppliers IN VARCHAR2 := fnd_api.G_FALSE
  );

  /*PROCEDURE a_debug(p_msg VARCHAR2);*/

  FUNCTION is_supplier_contact(p_party_id IN NUMBER) RETURN VARCHAR2;

END ego_item_associations_util;

/
