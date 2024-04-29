--------------------------------------------------------
--  DDL for Package JG_ZZ_JGZZALRL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_ZZ_JGZZALRL_PKG" AUTHID CURRENT_USER AS
/*$Header: jgzzarls.pls 120.0.12000000.1 2007/04/11 10:55:28 mbarrett noship $*/

   p_vat_reporting_entity_id	JG_ZZ_VAT_REP_ENTITIES.vat_reporting_entity_id%Type;
   p_source			FND_LOOKUP_VALUES.lookup_code%Type;
   p_fin_tran_type		FND_LOOKUP_VALUES.lookup_code%Type;
   p_vat_tran_type		FND_LOOKUP_VALUES.lookup_code%Type;
   p_vat_regime			JG_ZZ_VAT_REP_ENTITIES.tax_regime_code%Type;
   p_tax_code			ZX_TAXES_B.tax%Type;
   p_tax_status			ZX_STATUS_B.tax_status_id%Type;
   p_tax_jurisdiction		ZX_JURISDICTIONS_B.tax_jurisdiction_code%Type;
   p_tax_rate_id		ZX_RATES_B.tax_rate_id%Type;
   p_tax_box			FND_LOOKUP_VALUES.lookup_code%Type;
   p_non_rec_tax_box		FND_LOOKUP_VALUES.lookup_code%Type;
   p_taxable_box		FND_LOOKUP_VALUES.lookup_code%Type;
   p_non_rec_taxable_box	FND_LOOKUP_VALUES.lookup_code%Type;

   FUNCTION get_entity_identifier Return Varchar2;
   Function get_source Return Varchar2;
   Function get_fin_tran_type Return Varchar2;
   Function get_vat_tran_type Return Varchar2;
   Function get_tax_status_code Return Varchar2;
   Function get_tax_rate_code Return Varchar2;
   Function get_tax_box Return Varchar2;
   Function get_non_rec_tax_box Return Varchar2;
   Function get_taxable_box Return Varchar2;
   Function get_non_rec_taxable_box Return Varchar2;

END JG_ZZ_JGZZALRL_PKG;


 

/
