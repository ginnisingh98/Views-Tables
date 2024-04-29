--------------------------------------------------------
--  DDL for Package Body JL_ZZ_SH_LIBRARY_1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_ZZ_SH_LIBRARY_1_PKG" AS
/* $Header: jlzzwl1b.pls 120.4 2005/12/03 01:12:29 pla ship $ */

Procedure get_vat_count(sitevat        IN  Varchar2,
                        tot_rec        IN OUT NOCOPY Number,
                        row_number     IN Number,
                        errcd          IN OUT NOCOPY Number) Is
Begin
  errcd := 0;
  select count(*)
  into tot_rec
  from ap_lookup_codes lc,ap_tax_codes tc
  where lc.lookup_type = 'TAX TYPE'
  and tc.tax_type = 'ICMS'
  and lc.lookup_code = tc.tax_type
  and sysdate < nvl(lc.inactive_date, sysdate+1)
  and sysdate < nvl(tc.inactive_date, sysdate+1)
  and tc.name = sitevat;
Exception
  When Others Then
  errcd := sqlcode;
End get_vat_count;

Procedure get_translated_label
    (p_lookup_code   IN            Varchar2,
     p_label            OUT NOCOPY Varchar2,
     p_errcd            OUT NOCOPY Number) Is
Begin
  p_errcd := 0;

  Select   meaning
    Into   p_label
    From   fnd_lookup_values_vl
    Where  lookup_type = 'JLZZ_AR_TX_LABEL'
      And  lookup_code = p_lookup_code
      And  enabled_flag = 'Y'
      And  view_application_id = 0
      And  security_group_id = 0;

Exception
  When Others Then
     p_errcd := sqlcode;
End get_translated_label;

END JL_ZZ_SH_LIBRARY_1_PKG;

/
