--------------------------------------------------------
--  DDL for Package Body JG_ZZ_JGZZALRL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_ZZ_JGZZALRL_PKG" AS
/*$Header: jgzzarlb.pls 120.0.12000000.2 2007/04/11 15:24:10 mbarrett noship $*/

   FUNCTION get_entity_identifier Return Varchar2 Is
      l_entity_identifier JG_ZZ_VAT_REP_ENTITIES.entity_identifier%Type := Null;
   begin
      Select entity_identifier
      Into l_entity_identifier
      From JG_ZZ_VAT_REP_ENTITIES
      where vat_reporting_entity_id = p_vat_reporting_entity_id;

      Return l_entity_identifier;
   Exception
      When Others Then
         Return l_entity_identifier;
   End get_entity_identifier;

   Function get_source Return Varchar2 Is
      l_source FND_LOOKUP_VALUES.meaning%Type := Null;
   Begin
      select meaning
      Into l_source
      From FND_LOOKUP_VALUES
      Where lookup_type='JGZZ_SOURCE'
      And lookup_code = p_source
      And language = userenv('LANG');

      Return l_source;
   Exception
      When Others Then
         Return l_source;
   End get_source;

   Function get_fin_tran_type Return Varchar2 Is
      l_fin_tran_type FND_LOOKUP_VALUES.meaning%Type := Null;
   Begin
      Select meaning
      Into l_fin_tran_type
      From FND_LOOKUP_VALUES
      Where ( (p_source = 'AP'
               and lookup_type = 'JGZZ_AP_OF_TRANS_TYPE')
             Or
              (p_source = 'AR'
               and lookup_type = 'JGZZ_AR_OF_TRANS_TYPE')
             Or
              (p_source = 'GL'
               and lookup_type = 'JGZZ_GL_OF_TRANS_TYPE')
             Or
              (p_source = 'ALL'
               and lookup_type in ('JGZZ_AP_OF_TRANS_TYPE'
                                  ,'JGZZ_AR_OF_TRANS_TYPE'
                                  ,'JGZZ_GL_OF_TRANS_TYPE')))
      And lookup_code = p_fin_tran_type
      And language = userenv('LANG');

      Return l_fin_tran_type;
   Exception
      When Others Then
         Return l_fin_tran_type;
   End get_fin_tran_type;

   Function get_vat_tran_type Return Varchar2 Is
      l_vat_tran_type FND_LOOKUP_VALUES.meaning%Type := Null;
   Begin
      Select meaning
      Into l_vat_tran_type
      From FND_LOOKUP_VALUES
      Where lookup_type = 'ZX_JEBE_VAT_TRANS_TYPE'
      And lookup_code = p_vat_tran_type
      And language = userenv('LANG');

      Return l_vat_tran_type;
   Exception
      When Others Then
         Return l_vat_tran_type;
   End get_vat_tran_type;

   Function get_tax_status_code Return Varchar2 Is
      l_tax_status_code ZX_STATUS_B.tax_status_code%Type := Null;
   Begin
      Select tax_status_code
      Into l_tax_status_code
      From ZX_STATUS_B
      Where tax = nvl(p_tax_code,tax)
      And tax_regime_code = nvl(p_vat_regime,tax_regime_code)
      And tax_status_id = p_tax_status;

      Return l_tax_status_code;
   Exception
      When Others Then
         Return l_tax_status_code;
   End get_tax_status_code;

   Function get_tax_rate_code Return Varchar2 Is
      l_tax_rate_code ZX_RATES_B.tax_rate_code%Type;
   Begin
      Select rates.TAX_RATE_CODE
      Into l_tax_rate_code
      From ZX_RATES_B rates
      Where rates.tax_rate_id = p_tax_rate_id;

      Return l_tax_rate_code;
   Exception
      When Others Then
         Return l_tax_rate_code;
   End get_tax_rate_code;


   Function get_tax_box Return Varchar2 Is
      l_tax_box FND_LOOKUP_VALUES.meaning%Type := Null;
   Begin
      Select meaning
      Into l_tax_box
      From fnd_lookup_values
      WHERE lookup_type='JGZZ_VAT_REPORT_BOXES'
      And lookup_code = p_tax_box
      And language = userenv('LANG');

      Return l_tax_box;
   Exception
      When Others Then
         Return l_tax_box;
   End get_tax_box;

   Function get_non_rec_tax_box Return Varchar2 Is
      l_non_rec_tax_box FND_LOOKUP_VALUES.meaning%Type := Null;
   Begin
      Select meaning
      Into l_non_rec_tax_box
      From fnd_lookup_values
      WHERE lookup_type='JGZZ_VAT_REPORT_BOXES'
      And lookup_code = p_non_rec_tax_box
      And language = userenv('LANG');

      Return l_non_rec_tax_box;
   Exception
      When Others Then
         Return l_non_rec_tax_box;
   End get_non_rec_tax_box;

   Function get_taxable_box Return Varchar2 Is
      l_taxable_box FND_LOOKUP_VALUES.meaning%Type := Null;
   Begin
      Select meaning
      Into l_taxable_box
      From fnd_lookup_values
      WHERE lookup_type='JGZZ_VAT_REPORT_BOXES'
      And lookup_code = p_taxable_box
      And language = userenv('LANG');

      Return l_taxable_box;
   Exception
      When Others Then
         Return l_taxable_box;
   End get_taxable_box;

   Function get_non_rec_taxable_box Return Varchar2 Is
     l_non_rec_taxable_box FND_LOOKUP_VALUES.meaning%Type := Null;
   Begin
      Select meaning
      Into l_non_rec_taxable_box
      From fnd_lookup_values
      WHERE lookup_type='JGZZ_VAT_REPORT_BOXES'
      And lookup_code = p_non_rec_taxable_box
      And language = userenv('LANG');

      Return l_non_rec_taxable_box;
   Exception
      When Others Then
         Return l_non_rec_taxable_box;
   End get_non_rec_taxable_box;

END JG_ZZ_JGZZALRL_PKG;

/
