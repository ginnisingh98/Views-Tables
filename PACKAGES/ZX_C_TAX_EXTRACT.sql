--------------------------------------------------------
--  DDL for Package ZX_C_TAX_EXTRACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_C_TAX_EXTRACT" AUTHID CURRENT_USER as
/* $Header: zxrxcalextps.pls 120.3 2006/01/21 00:37:50 apai ship $ */

PROCEDURE POPULATE_TAX(
  errbuf            out NOCOPY varchar2,
  retcode           out NOCOPY varchar2,
  argument1         in  varchar2,                  -- p_reporting_level
  argument2         in  varchar2,                  -- p_reporting_context
  argument3         in  varchar2,                  -- p_company_name
  argument4         in  varchar2,                  -- p_sob_currency_code bug#3453804
  argument5         in  varchar2,                  -- p_register_type
-- apai **  argument5         in  varchar2,                  -- p_tax_class
  argument6         in  varchar2,                  -- p_summary_level
  argument7         in  varchar2,                  -- p_product
  argument8         in  varchar2,                  -- p_gl_date_low
  argument9         in  varchar2  default  null,   -- p_gl_date_high
  argument10         in  varchar2  default  null,   -- p_trx_date_low
  argument11        in  varchar2  default  null,   -- p_trx_date_high
  argument12        in  varchar2  default  null,   -- p_tax_code_vat_trx_type
  argument13        in  varchar2  default  null,   -- p_tax_code_type_low
  argument14        in  varchar2  default  null,   -- p_tax_code_type_high
  argument15        in  varchar2  default  null,   -- p_tax_regime_code
  argument16        in  varchar2  default  null,   -- p_tax
  argument17        in  varchar2  default  null,   -- p_tax_jurisdiction
  argument18        in  varchar2  default  null,   -- p_tax_status_code
  argument19        in  varchar2  default  null,   -- p_tax_code_low
  argument20        in  varchar2  default  null,   -- p_tax_code_high
  argument21        in  varchar2  default  null,   -- p_currency_code_low
  argument22        in  varchar2  default  null,   -- p_currency_code_high
  argument23        in  varchar2  default  null,   -- p_posting_status
  argument24        in  varchar2  default  null,   -- p_ar_exemption_status
  argument25        in  varchar2  default  null,   -- p_trx_number
  argument26        in  varchar2  default  null,   -- P_INCLUDE_AP_STD_TRX_CLASS
  argument27        in  varchar2  default  null,   -- P_INCLUDE_AP_DM_TRX_CLASS
  argument28        in  varchar2  default  null,   -- P_INCLUDE_AP_CM_TRX_CLASS
  argument29        in  varchar2  default  null,   -- P_INCLUDE_AP_PREP_TRX_CLASS
  argument30        in  varchar2  default  null,   -- P_INCLUDE_AP_MIX_TRX_CLASS
  argument31        in  varchar2  default  null,   -- P_INCLUDE_AP_EXP_TRX_CLASS
  argument32        in  varchar2  default  null,   -- P_INCLUDE_AR_INV_TRX_CLASS
  argument33        in  varchar2  default  null,   -- P_INCLUDE_AR_APPL_TRX_CLASS
  argument34        in  varchar2  default  null,   -- P_INCLUDE_AR_ADJ_TRX_CLASS
  argument35        in  varchar2  default  null,   -- P_INCLUDE_AR_MISC_TRX_CLASS
  argument36        in  varchar2  default  null,   -- P_INCLUDE_AR_BR_TRX_CLASS
  argument37        in  varchar2  default  null,   -- debug flag
  argument38        in  varchar2  default  null,   -- SQL trace flag
  argument39        in  varchar2  default  null,   -- p_matrix_report
  argument40        in  varchar2  default  null,   -- p_include_accounting_segments
  argument41        in  varchar2  default  null,   -- p_include_discount
  argument42        in  varchar2  default  null,   -- p_report_name
  argument43        in  varchar2  default  null,
  argument44        in  varchar2  default  null,
  argument45        in  varchar2  default  null,
  argument46        in  varchar2  default  null,
  argument47        in  varchar2  default  null,
  argument48        in  varchar2  default  null,
  argument49        in  varchar2  default  null,
  argument50        in  varchar2  default  null,
  argument51        in  varchar2  default  null,
  argument52        in  varchar2  default  null,
  argument53        in  varchar2  default  null,
  argument54        in  varchar2  default  null,
  argument55        in  varchar2  default  null,
  argument56        in  varchar2  default  null,
  argument57        in  varchar2  default  null,
  argument58        in  varchar2  default  null,
  argument59        in  varchar2  default  null,
  argument60        in  varchar2  default  null,
  argument61        in  varchar2  default  null,
  argument62        in  varchar2  default  null,
  argument63        in  varchar2  default  null,
  argument64        in  varchar2  default  null,
  argument65        in  varchar2  default  null,
  argument66        in  varchar2  default  null,
  argument67        in  varchar2  default  null,
  argument68        in  varchar2  default  null,
  argument69        in  varchar2  default  null,
  argument70        in  varchar2  default  null,
  argument71        in  varchar2  default  null,
  argument72        in  varchar2  default  null,
  argument73        in  varchar2  default  null,
  argument74        in  varchar2  default  null,
  argument75        in  varchar2  default  null,
  argument76        in  varchar2  default  null,
  argument77        in  varchar2  default  null,
  argument78        in  varchar2  default  null,
  argument79        in  varchar2  default  null,
  argument80        in  varchar2  default  null,
  argument81        in  varchar2  default  null,
  argument82        in  varchar2  default  null,
  argument83        in  varchar2  default  null,
  argument84        in  varchar2  default  null,
  argument85        in  varchar2  default  null,
  argument86        in  varchar2  default  null,
  argument87        in  varchar2  default  null,
  argument88        in  varchar2  default  null,
  argument89        in  varchar2  default  null,
  argument90        in  varchar2  default  null,
  argument91        in  varchar2  default  null,
  argument92        in  varchar2  default  null,
  argument93        in  varchar2  default  null,
  argument94        in  varchar2  default  null,
  argument95        in  varchar2  default  null,
  argument96        in  varchar2  default  null,
  argument97        in  varchar2  default  null,
  argument98        in  varchar2  default  null,
  argument99        in  varchar2  default  null,
  argument100       in  varchar2  default  null);


END ZX_C_TAX_EXTRACT;

 

/
