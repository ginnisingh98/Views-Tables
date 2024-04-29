--------------------------------------------------------
--  DDL for Package Body ZX_C_TAX_EXTRACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_C_TAX_EXTRACT" as
/* $Header: zxrxcalextpb.pls 120.5.12010000.2 2008/12/03 18:38:34 bibeura ship $ */

--5336803
  g_current_runtime_level           NUMBER ;
  g_level_statement       CONSTANT  NUMBER  := FND_LOG.LEVEL_STATEMENT;
  g_level_procedure       CONSTANT  NUMBER  := FND_LOG.LEVEL_PROCEDURE;
  g_level_event           CONSTANT  NUMBER  := FND_LOG.LEVEL_EVENT;
  g_level_unexpected      CONSTANT  NUMBER  := FND_LOG.LEVEL_UNEXPECTED;

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
  argument43        in  varchar2  default  null,   -- p_accounting_status
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
  argument100       in  varchar2  default  null)
is
-- apai **  v_third_party_level              varchar2(80);
  v_request_id                     number;
  v_matrix_report                  varchar2(10);
  v_reporting_level                varchar2(50);
  v_reporting_context              number;
  v_company_name                   number; -- Used to get the Legal Entity Id for Reporting Level = 'Ledger'
  v_register_type                  varchar2(80);
--apai **  v_tax_class                      varchar2(20);
  v_summary_level                  varchar2(50);
  v_product                        varchar2(30);
  v_gl_date_low                    date;
  v_gl_date_high                   date;
  v_trx_date_low                   date;
  v_trx_date_high                  date;
  v_tax_code_low                   varchar2(50);
  v_tax_code_high                  varchar2(50);
  v_currency_code_low              varchar2(15);
  v_currency_code_high             varchar2(15);
  v_posting_status                 varchar2(30);
  /* apai */
  v_tax_regime_code                varchar2(30);
  v_tax                            varchar2(30);
  v_tax_jurisdiction               varchar2(30);
  v_tax_status_code                varchar2(30);
  /* ** */
  v_ar_exemption_status            varchar2(30);
  v_trx_number                     varchar2(50);
-- apai **  v_trx_class                      varchar2(50);
  V_INCLUDE_AP_STD_TRX_CLASS       varchar2(1);
  V_INCLUDE_AP_DM_TRX_CLASS        varchar2(1);
  V_INCLUDE_AP_CM_TRX_CLASS        varchar2(1);
  V_INCLUDE_AP_PREP_TRX_CLASS      varchar2(1);
  V_INCLUDE_AP_MIX_TRX_CLASS       varchar2(1);
  V_INCLUDE_AP_EXP_TRX_CLASS       varchar2(1);
  V_INCLUDE_AR_INV_TRX_CLASS       varchar2(1);
  V_INCLUDE_AR_APPL_TRX_CLASS      varchar2(1);
  V_INCLUDE_AR_ADJ_TRX_CLASS       varchar2(1);
  V_INCLUDE_AR_MISC_TRX_CLASS      varchar2(1);
  V_INCLUDE_AR_BR_TRX_CLASS        varchar2(1);
  v_tax_code_vat_trx_type          varchar2(30);
  v_tax_code_type_low              varchar2(50);
  v_tax_code_type_high             varchar2(50);
  debug_flag                       varchar2(1);
  sql_trace                        varchar2(1);
  v_include_Accounting_segments    varchar2(3);
  v_include_discounts              varchar2(3);
  v_report_name                    varchar2(8);
  v_accounting_status              varchar2(30);
  v_ca_set_of_books_id             number;  --bug#3453804
begin
  --
  -- Assign parameters doing any necessary mappings
  -- e.g. date/number conversion

   g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   IF (g_level_procedure >= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_C_TAX_EXTRACT.populate_tax.BEGIN',
				      'ZX_C_TAX_EXTRACT:populate_tax(+)');
	FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_C_TAX_EXTRACT.populate_tax',
				      'argument2 --> '||argument2);
	FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_C_TAX_EXTRACT.populate_tax',
				      'argument3 --> '||argument3);
	FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_C_TAX_EXTRACT.populate_tax',
				      'argument4 --> '||argument4);
   END IF;

  v_request_id                       := fnd_global.conc_request_id;
  v_reporting_level                  := argument1;
  v_reporting_context                := to_number(argument2); -- 5336803
  v_company_name                     := to_number(argument3); -- 5336803
  v_ca_set_of_books_id               := to_number(argument4);  --bug#3453804 /5336803
  v_register_type                    := argument5;
-- apai **  v_tax_class                        := argument5;
  v_summary_level                    := argument6;
  v_product                          := argument7;
  v_gl_date_low                      := fnd_date.canonical_to_date(argument8);
  v_gl_date_high                     := fnd_date.canonical_to_date(argument9);
  v_trx_date_low                     := fnd_date.canonical_to_date(argument10);
  v_trx_date_high                    := fnd_date.canonical_to_date(argument11);
  v_tax_code_vat_trx_type            := argument12;
  v_tax_code_type_low                := argument13;
  v_tax_code_type_high               := argument14;
  /* apai */
  v_tax_regime_code                  := argument15;
  v_tax                              := argument16;
  v_tax_jurisdiction                 := argument17;
  v_tax_status_code                  := argument18;
  /* ** */
  v_tax_code_low                     := argument19;
  v_tax_code_high                    := argument20;
  v_currency_code_low                := argument21;
  v_currency_code_high               := argument22;
  v_posting_status                   := argument23;
  v_ar_exemption_status              := argument24;
  v_trx_number                       := argument25;
  V_INCLUDE_AP_STD_TRX_CLASS         := argument26;
  V_INCLUDE_AP_DM_TRX_CLASS          := argument27;
  V_INCLUDE_AP_CM_TRX_CLASS          := argument28;
  V_INCLUDE_AP_PREP_TRX_CLASS        := argument29;
  V_INCLUDE_AP_MIX_TRX_CLASS         := argument30;
  V_INCLUDE_AP_EXP_TRX_CLASS         := argument31;
  V_INCLUDE_AR_INV_TRX_CLASS         := argument32;
  V_INCLUDE_AR_APPL_TRX_CLASS        := argument33;
  V_INCLUDE_AR_ADJ_TRX_CLASS         := argument34;
  V_INCLUDE_AR_MISC_TRX_CLASS        := argument35;
  V_INCLUDE_AR_BR_TRX_CLASS          := argument36;
  debug_flag                         := upper(substrb(argument37,1,1));
  sql_trace                          := upper(substrb(argument38,1,1));
  v_matrix_report                    := argument39;
-- apai **  v_third_party_level                := argument27;
  v_include_accounting_Segments      := argument40;
  v_include_discounts                := argument41; --apai
  v_report_name                      := argument42; --apai
  v_accounting_status                := argument43;

  -- bug 3334864 for Family Pack F: comment out the trace call
  --
  -- SQL Trace switches and debug flags are optional
  -- but highly recommended.

--  if sql_trace = 'Y' then
--        fa_rx_util_pkg.enable_trace;
--  end if;
  if debug_flag = 'Y' then
        fa_rx_util_pkg.enable_debug;
  end if;



 -- g_current_runtime_level := 1;
-- g_level_procedure := 2;

  -- Run the Tax Extract

   IF (g_level_statement >= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_C_TAX_EXTRACT.populate_tax',
				      'Before Call to ZX_EXTRACT_PKG.POPULATE_TAX_DATA ');
   END IF;

  ZX_EXTRACT_PKG.POPULATE_TAX_DATA
      ( p_matrix_report                   =>  v_matrix_report,
        p_reporting_level                 =>  v_reporting_level,
        p_reporting_context               =>  v_reporting_context,
        p_legal_entity_id                 =>  v_company_name,
        p_ledger_id                       =>  v_ca_set_of_books_id,  --bug#3453804
        p_register_type                   =>  v_register_type,
--apai **       p_tax_class                       =>  v_tax_class,
        p_summary_level                   =>  v_summary_level,
        p_product                         =>  v_product,
        p_gl_date_low                     =>  v_gl_date_low,
        p_gl_date_high                    =>  v_gl_date_high,
        p_trx_date_low                    =>  v_trx_date_low,
        p_trx_date_high                   =>  v_trx_date_high,
        p_vat_transaction_type_code       =>  v_tax_code_vat_trx_type,
        p_tax_type_code_low               =>  v_tax_code_type_low,
        p_tax_type_code_high              =>  v_tax_code_type_high,
/* apai */
        p_tax_regime_code                 =>  v_tax_regime_code,
        p_tax                             =>  v_tax,
        p_tax_jurisdiction_code           =>  v_tax_jurisdiction,
        p_tax_status_code                 =>  v_tax_status_code,
/* ** */
        p_tax_rate_code_low               =>  v_tax_code_low,
        p_tax_rate_code_high              =>  v_tax_code_high,
        p_currency_code_low               =>  v_currency_code_low,
        p_currency_code_high              =>  v_currency_code_high,
        p_posting_status                  =>  v_posting_status,
        p_ar_exemption_status             =>  v_ar_exemption_status,
--apai **        p_trx_number                      =>  v_trx_number,
/* apai */
        p_trx_number_low                  =>  v_trx_number,
        p_trx_number_high                 =>  v_trx_number,
/* ** */
--apai **       p_trx_class                       =>  v_trx_class,
/* apai */
        P_INCLUDE_AP_STD_TRX_CLASS        =>  V_INCLUDE_AP_STD_TRX_CLASS,
        P_INCLUDE_AP_DM_TRX_CLASS         =>  V_INCLUDE_AP_DM_TRX_CLASS,
        P_INCLUDE_AP_CM_TRX_CLASS         =>  V_INCLUDE_AP_CM_TRX_CLASS,
        P_INCLUDE_AP_PREP_TRX_CLASS       =>  V_INCLUDE_AP_PREP_TRX_CLASS,
        P_INCLUDE_AP_MIX_TRX_CLASS        =>  V_INCLUDE_AP_MIX_TRX_CLASS,
        P_INCLUDE_AP_EXP_TRX_CLASS        =>  V_INCLUDE_AP_EXP_TRX_CLASS,
        P_INCLUDE_AR_INV_TRX_CLASS        =>  V_INCLUDE_AR_INV_TRX_CLASS,
        P_INCLUDE_AR_APPL_TRX_CLASS       =>  V_INCLUDE_AR_APPL_TRX_CLASS,
        P_INCLUDE_AR_ADJ_TRX_CLASS        =>  V_INCLUDE_AR_ADJ_TRX_CLASS,
        P_INCLUDE_AR_MISC_TRX_CLASS       =>  V_INCLUDE_AR_MISC_TRX_CLASS,
        P_INCLUDE_AR_BR_TRX_CLASS         =>  V_INCLUDE_AR_BR_TRX_CLASS,
/* ** */
        p_request_id                      =>  v_request_id,
--apai **       p_third_party_reporting_level     =>  v_third_party_level,
        p_include_accounting_segments     =>  v_include_accounting_segments,
        p_include_discounts               =>  v_include_discounts,
        p_report_name                     =>  v_report_name,
        p_accounting_status              => v_accounting_status,
        p_retcode                         =>  retcode,
        p_errbuf                          =>  errbuf);

  -- bug 3334864 for Family Pack F: comment out the trace call
  --
  --
  -- Now Disable the SQL Trace and Debug Flag if enabled
  --
--  if sql_trace = 'Y' then
--        fa_rx_util_pkg.disable_trace;
--  end if;
  if debug_flag = 'Y' then
        fa_rx_util_pkg.disable_debug;
  end if;

   IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_C_TAX_EXTRACT.populate_tax.BEGIN',
                                      'ZX_C_TAX_EXTRACT:populate_tax(-)');
   END IF;

END POPULATE_TAX;

end ZX_C_TAX_EXTRACT;

/
