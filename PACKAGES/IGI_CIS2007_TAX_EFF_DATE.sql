--------------------------------------------------------
--  DDL for Package IGI_CIS2007_TAX_EFF_DATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_CIS2007_TAX_EFF_DATE" AUTHID CURRENT_USER AS
-- $Header: igiefdts.pls 120.1.12010000.2 2008/12/19 12:56:34 gaprasad ship $
 g_old_p_vendor_id      ap_suppliers.vendor_id%type;
 g_old_p_vendor_site_id ap_supplier_sites_all.vendor_site_id%type;
 g_old_p_tax_grp_id     ap_awt_group_taxes_all.group_id%type;
 g_old_p_source         varchar2(30);
 g_old_p_effective_date date;

 global_eff_date date;

procedure main (
                p_vendor_id      in ap_suppliers.vendor_id%type,
                p_vendor_site_id in ap_supplier_sites_all.vendor_site_id%type,
                p_tax_grp_id in ap_awt_group_taxes_all.group_id%type,
                p_pay_tax_grp_id in ap_awt_group_taxes_all.group_id%type,                          /* Bug 7218825 */
                p_source         in varchar2,
                p_effective_date in date
                );

procedure set_eff_date(p_eff_date date);
function get_eff_date return date;

END IGI_CIS2007_TAX_EFF_DATE;


/
