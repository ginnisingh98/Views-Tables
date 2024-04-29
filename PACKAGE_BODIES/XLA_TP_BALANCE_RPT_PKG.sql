--------------------------------------------------------
--  DDL for Package Body XLA_TP_BALANCE_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_TP_BALANCE_RPT_PKG" AS
-- $Header: xlarptpb.pkb 120.22.12010000.4 2009/06/30 13:09:27 nksurana ship $
/*===========================================================================+
|  Copyright (c) 2003 Oracle Corporation BelmFont, California, USA           |
|                          ALL rights reserved.                              |
+============================================================================+
| FILENAME                                                                   |
|     xlarptpb.pkb                                                           |
|                                                                            |
| PACKAGE NAME                                                               |
|     xla_tp_balance_rpt_pkg                                                 |
|                                                                            |
| DESCRIPTION                                                                |
|     PACKAGE BODY. This provides XML extract for Third Party Balance Report |
|                                                                            |
| HISTORY                                                                    |
|     07/20/2005  V. Kumar        Created                                    |
|     12/27/2005  V.Swapna        Modified the package to use Data template  |
|     04/23/2006  A. Wan          5072266 - replace po_vendors with          |
|                                           ap_suppliers                     |
|     08/24/2006  E. Sayyed       5398825- p_je_source ==> p_je_source_name  |
|     09/01/2006  V. Swapna       Bug 5477846 - Raise an error if party type |
|                                 is null.                                   |
|     06/30/2009  N.K.Surana      Bug 8544794 - Changed                      |
|                                 hz_cust_accounts.cust_account_id to        |
|                                 hz_cust_accounts.account_number for party  |
|                                 number range in case of Customers.         |
+===========================================================================*/

--=============================================================================
--           ****************  declarations  ********************
--=============================================================================


-------------------------------------------------------------------------------
-- constant for getting leagal entity information
-------------------------------------------------------------------------------
C_NULL_LEGAL_ENT_COL     CONSTANT     VARCHAR2(4000) :=
   ' ,NULL                LEGAL_ENTITY_ID
     ,NULL                LEGAL_ENTITY_NAME
     ,NULL                LE_ADDRESS_LINE_1
     ,NULL                LE_ADDRESS_LINE_2
     ,NULL                LE_ADDRESS_LINE_3
     ,NULL                LE_CITY
     ,NULL                LE_REGION_1
     ,NULL                LE_REGION_2
     ,NULL                LE_REGION_3
     ,NULL                LE_POSTAL_CODE
     ,NULL                LE_COUNTRY
     ,NULL                LE_REGISTRATION_NUMBER
     ,NULL                LE_REGISTRATION_EFFECTIVE_FROM
     ,NULL                LE_ACTIVITY_CODE
     ,NULL                LE_SUB_ACTIVITY_CODE
     ,NULL                LE_CONTACT_NAME
     ,NULL                LE_CONTACT_PHONE_NUMBER';

C_LEGAL_ENT_COL     CONSTANT     VARCHAR2(4000) :=
   ' ,fiv.legal_entity_id                     LEGAL_ENTITY_ID
     ,fiv.NAME                                LEGAL_ENTITY_NAME
     ,fiv.ADDRESS_LINE_1                      LE_ADDRESS_LINE_1
     ,fiv.ADDRESS_LINE_2                      LE_ADDRESS_LINE_2
     ,fiv.ADDRESS_LINE_3                      LE_ADDRESS_LINE_3
     ,fiv.TOWN_OR_CITY                        LE_CITY
     ,fiv.REGION_1                            LE_REGION_1
     ,fiv.REGION_2                            LE_REGION_2
     ,fiv.REGION_3                            LE_REGION_3
     ,fiv.postal_code                         LE_POSTAL_CODE
     ,fiv.country                             LE_COUNTRY
     ,fiv.registration_number                 LE_REGISTRATION_NUMBER
     ,fiv.effective_from                      LE_REGISTRATION_EFFECTIVE_FROM
     ,fiv.activity_code                       LE_ACTIVITY_CODE
     ,fiv.sub_activity_code                   LE_SUB_ACTIVITY_CODE
     ,NULL                                    LE_CONTACT_NAME
     ,NULL                                    LE_CONTACT_PHONE_NUMBER';

C_LEGAL_ENT_FROM    CONSTANT    VARCHAR2(1000)  :=
   ' ,xle_firstparty_information_v   fiv
     ,gl_ledger_le_bsv_specific_v    gle';

C_LEGAL_ENT_JOIN   CONSTANT    VARCHAR2(2000) :=
   ' AND gle.ledger_id(+)            = TABLE1.ledger_id
     AND gle.segment_value(+)        = TABLE1.$leg_seg_val$
     AND fiv.legal_entity_id(+)      = gle.legal_entity_id';

C_ESTBLISHMENT_COL     CONSTANT     VARCHAR2(4000) :=
   ' ,xev.establishment_id                    LEGAL_ENTITY_ID
     ,xev.establishment_name                  LEGAL_ENTITY_NAME
     ,xev.address_line_1                      LE_ADDRESS_LINE_1
     ,xev.address_line_2                      LE_ADDRESS_LINE_2
     ,xev.address_line_3                      LE_ADDRESS_LINE_3
     ,xev.town_or_city                        LE_CITY
     ,xev.region_1                            LE_REGION_1
     ,xev.region_2                            LE_REGION_2
     ,xev.region_3                            LE_REGION_3
     ,xev.postal_code                         LE_POSTAL_CODE
     ,xev.country                             LE_COUNTRY
     ,xev.registration_number                 LE_REGISTRATION_NUMBER
     ,xev.effective_from                      LE_REGISTRATION_EFFECTIVE_FROM
     ,xev.activity_code                       LE_ACTIVITY_CODE
     ,xev.sub_activity_code                   LE_SUB_ACTIVITY_CODE
     ,NULL                                    LE_CONTACT_NAME
     ,NULL                                    LE_CONTACT_PHONE_NUMBER';

C_ESTABLISHMENT_FROM    CONSTANT    VARCHAR2(2000)  :=
   ' ,gl_ledger_le_bsv_specific_v      glv
     ,xle_bsv_associations             xba
     ,xle_establishment_v              xev ';

C_ESTABLISHMENT_JOIN   CONSTANT    VARCHAR2(2000) :=
   ' AND glv.ledger_id(+)            = TABLE1.ledger_id
     AND glv.segment_value(+)        = TABLE1.$leg_seg_val$
     AND xba.legal_parent_id(+)      = glv.legal_entity_id
     AND xba.entity_name(+)          = glv.segment_value
     AND xba.context(+)              = ''EST_BSV_MAPPING''
     AND xev.establishment_id(+)     = xba.legal_construct_id';

  --------------------------------------------------------------------------------
-- constant for COMMERCIAL_NUMBER details
--------------------------------------------------------------------------------
C_COMMERCIAL_QUERY  VARCHAR2(8000) :=
'SELECT nvl(xler.registration_number,0) LEGAL_COMMERCIAL_NUMBER
FROM XLE_REGISTRATIONS_V xler
WHERE  legislative_category = ''COMMERCIAL_LAW''
 AND legal_entity_id = :P_LEGAL_ENTITY_ID';

C_COMMERCIAL_NULL_QUERY  VARCHAR2(8000) :=
'select NULL LEGAL_COMMERCIAL_NUMBER from dual where 1>2';

  --------------------------------------------------------------------------------
-- constant for VAT_REGISTRATION details
--------------------------------------------------------------------------------
C_VAT_REGISTRATION_QUERY  VARCHAR2(8000) :=
'SELECT zptp.REP_REGISTRATION_NUMBER   LEGAL_VAT_REGISTRATION_NUMBER
FROM ZX_PARTY_TAX_PROFILE zptp ,XLE_ETB_PROFILES xetbp
WHERE zptp.PARTY_TYPE_CODE = ''LEGAL_ESTABLISHMENT''
AND xetbp.party_id=zptp.party_id
AND xetbp.MAIN_ESTABLISHMENT_FLAG = ''Y''
AND xetbp.LEGAL_ENTITY_ID = :P_LEGAL_ENTITY_ID' ;

C_VAT_REGISTRATION_NULL_QUERY  VARCHAR2(8000) :=
'select NULL LEGAL_VAT_REGISTRATION_NUMBER from dual where 1>2';


C_QUALIFIED_SEGMENT CONSTANT VARCHAR2(1000) :=
'         ,$alias_balancing_segment$      BALANCING_SEGMENT
          ,$alias_account_segment$        NATURAL_ACCOUNT_SEGMENT
          ,$alias_costcenter_segment$     COST_CENTER_SEGMENT
          ,$alias_management_segment$     MANAGEMENT_SEGMENT
          ,$alias_intercompany_segment$   INTERCOMPANY_SEGMENT
           $seg_desc_column$ ';

C_NULL_PARTY_COLS CONSTANT VARCHAR2(1000) :=
    ' ,NULL                   PARTY_ID
      ,NULL                   PARTY_NUMBER
      ,NULL                   PARTY_NAME
      ,NULL                   PARTY_SITE_ID
      ,NULL                   PARTY_SITE_NUMBER
      ,NULL                   PARTY_SITE_TAX_REGS_NUMBER';

-------------------------------------------------------------------------------
-- constant for User Transaction Identifiers name and values
-------------------------------------------------------------------------------



--=============================================================================
--        **************  forward  declarations  ******************
--=============================================================================
--------------------------------------------------------------------------------
-- procedure to create the main SQL
--------------------------------------------------------------------------------
--=============================================================================
--               *********** Local Trace Routine **********
--=============================================================================
C_LEVEL_STATEMENT     CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
C_LEVEL_PROCEDURE     CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
C_LEVEL_EVENT         CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
C_LEVEL_EXCEPTION     CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
C_LEVEL_ERROR         CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
C_LEVEL_UNEXPECTED    CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;

C_LEVEL_LOG_DISABLED  CONSTANT NUMBER := 99;
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240):= 'xla.plsql.xla_tp_balance_rpt_pkg';

g_log_level                     NUMBER;
g_log_enabled                   BOOLEAN;
g_je_source_application_id      VARCHAR2(30);

PROCEDURE trace
       (p_msg                        IN VARCHAR2
       ,p_level                      IN NUMBER
       ,p_module                     IN VARCHAR2) IS
BEGIN
   IF (p_msg IS NULL AND p_level >= g_log_level) THEN
      fnd_log.message(p_level, NVL(p_module,C_DEFAULT_MODULE));
   ELSIF p_level >= g_log_level THEN
      fnd_log.string(p_level, NVL(p_module,C_DEFAULT_MODULE), p_msg);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_tp_balance_rpt_pkg.trace');
END trace;

/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
|    get_flex_range_where                                               |
|                                                                       |
|                                                                       |
|    Return where clauses for flexfield ranges                          |
|                                                                       |
+======================================================================*/

FUNCTION get_flex_range_where
  (p_coa_id                     IN NUMBER
  ,p_accounting_flexfield_from  IN VARCHAR2
  ,p_accounting_flexfield_to    IN VARCHAR2) RETURN VARCHAR

IS

   l_log_module           VARCHAR2(240);

   l_where                VARCHAR2(32000);
   l_bind_variables       fnd_flex_xml_publisher_apis.bind_variables;
   l_numof_bind_variables NUMBER;
   l_segment_name         VARCHAR2(30);
   l_segment_value        VARCHAR2(1000);
   l_data_type            VARCHAR2(30);

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_flex_range_where';
   END IF;
   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of get_flex_range_where'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg   => 'p_coa_id = '||to_char(p_coa_id)
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module );

      trace
         (p_msg   => 'p_accounting_flexfield_from  = '||to_char(p_accounting_flexfield_from )
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module );

      trace
         (p_msg   => 'p_accounting_flexfield_to = '||to_char(p_accounting_flexfield_to)
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module );

   END IF;

   --
   --  e.g. l_where stores the following:
   --       gcck.SEGMENT1 BETWEEN :FLEX_PARM1 AND :FLEX_PARM2
   --   AND gcck.SEGMENT2 BETWEEN :FLEX_PARM3 AND :FLEX_PARM4 ...
   --
   fnd_flex_xml_publisher_apis.kff_where
     (p_lexical_name                 => 'FLEX_PARM'
     ,p_application_short_name       => 'SQLGL'
     ,p_id_flex_code                 => 'GL#'
     ,p_id_flex_num                  => p_coa_id
     ,p_code_combination_table_alias => 'gcck'
     ,p_segments                     => 'ALL'
     ,p_operator                     => 'BETWEEN'
     ,p_operand1                     => p_accounting_flexfield_from
     ,p_operand2                     => p_accounting_flexfield_to
     ,x_where_expression             => l_where
     ,x_numof_bind_variables         => l_numof_bind_variables
     ,x_bind_variables               => l_bind_variables);

   FOR i IN l_bind_variables.FIRST .. l_bind_variables.LAST LOOP

      l_segment_name := l_bind_variables(i).name;
      l_data_type    := l_bind_variables(i).data_type;

      IF (l_data_type='VARCHAR2') THEN

         l_segment_value := '''' || l_bind_variables(i).varchar2_value || '''';

      ELSIF (l_data_type='NUMBER') THEN

         l_segment_value :=  l_bind_variables(i).canonical_value;

      ELSIF (l_data_type='DATE')  THEN

         l_segment_value := '''' ||  TO_CHAR(l_bind_variables(i).date_value
                                    ,'yyyy-mm-dd HH24:MI:SS') || '''';

      END IF;

     --
     -- Use REGEXP_REPLACE instead of REPLACE not to replace
     -- string 'SEGMENT1' in 'SEGMENT10'.
     -- REGEXP_REPLACE replaces the first occurent of a segment name
     -- e.g.
     --  BETWEEN :FLEX_PARM9 AND :FLEX_PARM10
     --  =>
     --  BETWEEN '000' AND '100'
     --
     l_where := REGEXP_REPLACE
                  (l_where
                  ,':' || l_segment_name
                  ,l_segment_value
                  ,1    -- Position
                  ,1    -- The first occurence
                  , 'c'  -- Case sensitive
                  );

   END LOOP ;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of get_flex_range_where'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   RETURN l_where;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_tb_report_pvt.get_flex_range_where');

END get_flex_range_where;
--=============================================================================
--          *********** public procedures and functions **********
--=============================================================================
--=============================================================================
--
--
--
--
--
--
--
--
--
--
-- Following are public routines
--
--    1.  beforeReport
--
--
--
--
--
--
--
--
--
--
--
--=============================================================================
--=============================================================================
--
--
--
--=============================================================================
FUNCTION beforeReport  RETURN BOOLEAN IS

l_source_application_id         NUMBER;
l_start_period_num              NUMBER;
l_end_period_num                NUMBER;
l_start_date                    DATE;
l_end_date                      DATE;
l_select_str                    VARCHAR2(4000);
l_from_str                      VARCHAR2(240);
l_where_str                     VARCHAR2(4000);
l_lang                          VARCHAR2(80);
l_count                         NUMBER;
l_ledger_id                     NUMBER;
l_coa_id                        NUMBER;
l_object_type                   VARCHAR2(30);
l_balancing_segment             VARCHAR2(80);
l_account_segment               VARCHAR2(80);
l_costcenter_segment            VARCHAR2(80);
l_management_segment            VARCHAR2(80);
l_intercompany_segment          VARCHAR2(80);
l_alias_balancing_segment       VARCHAR2(80);
l_alias_account_segment         VARCHAR2(80);
l_alias_costcenter_segment      VARCHAR2(80);
l_alias_management_segment      VARCHAR2(80);
l_alias_intercompany_segment    VARCHAR2(80);
l_seg_desc_column               VARCHAR2(2000);
l_seg_desc_from                 VARCHAR2(1000);
l_seg_desc_join                 VARCHAR2(1000);
l_fnd_flex_hint                 VARCHAR2(500);
l_other_filter                  VARCHAR2(2000);
l_log_module                    VARCHAR2(240);
l_insert_query                  VARCHAR2(4000);
l_balance_query                 VARCHAR2(32000);
l_flex_range_where              VARCHAR2(32000);
l_ledger_set_from               VARCHAR2(1000) := ' ';
l_ledger_set_where              VARCHAR2(1000) := ' ';
type t_array_app_id is table of NUMBER index by binary_integer;

l_responsibility_ids            t_array_app_id;

i                               number;
l_temp                          number;


   --bug#7828983
   CURSOR c_alc_ledger_check(l_ledger_id gl_ledgers.ledger_id%TYPE)  IS
    SELECT primary_ledger_id
      FROM gl_ledger_relationships
      WHERE target_ledger_id = l_ledger_id
      AND relationship_type_code = 'SUBLEDGER'
      AND target_ledger_category_code = 'ALC'
      AND application_id =101;

   l_primary_ledger_id  gl_ledgers.ledger_id%TYPE;
   --end bug#7828983

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.beforeReport';
   END IF;
   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of beforeReport'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'party type is:'||p_party_type
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   --
   -- default values
   --
   P_INCLUDE_DRAFT_ACTIVITY_FLAG := NVL(P_INCLUDE_DRAFT_ACTIVITY_FLAG,'N');
   P_INCLUDE_ZERO_AMT_LINES_FLAG := NVL(P_INCLUDE_ZERO_AMT_LINES_FLAG,'N');
   P_INCLUDE_USER_TRX_ID_FLAG    := NVL(P_INCLUDE_USER_TRX_ID_FLAG,'N');
   P_INCLUDE_TAX_DETAILS_FLAG    := NVL(P_INCLUDE_TAX_DETAILS_FLAG,'N');
   P_INCLUDE_LE_INFO_FLAG        := NVL(P_INCLUDE_LE_INFO_FLAG,'NONE');

   IF p_je_source_name = '#ALL#' THEN
      p_je_source_name := 'ALL';
   END IF;

   IF p_party_type is NULL THEN  -- Bug 5477846
       xla_exceptions_pkg.raise_message
             (p_appli_s_name   => 'XLA'
             ,p_msg_name       => 'XLA_COMMON_ERROR'
             ,p_token_1        => 'ERROR'
             ,p_value_1        => 'Party type parameter is mandatory, but missing.'||
                                  'Please populate the party type.'
             ,p_token_2        => 'LOCATION'
             ,p_value_2        => 'xla_tp_balance_rpt_pkg.beforeReport');
   END IF;

   BEGIN
      SELECT application_id
        INTO g_je_source_application_id
        FROM xla_subledgers
       WHERE je_source_name = p_je_source_name;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      g_je_source_application_id := NULL;
   END;

--
-- following will set the right transaction security.
--
xla_security_pkg.set_security_context(g_je_source_application_id);



   --
   -- User Transaction Identifiers
   --
   IF p_include_user_trx_id_flag = 'Y' AND
      g_je_source_application_id IS NOT NULL
   THEN

          xla_report_utility_pkg.get_transaction_id
               (p_resp_application_id  => g_je_source_application_id
               ,p_ledger_id            => p_ledger_id
               ,p_trx_identifiers_1    => p_trx_identifiers_1
               ,p_trx_identifiers_2    => p_trx_identifiers_2
               ,p_trx_identifiers_3    => p_trx_identifiers_3
               ,p_trx_identifiers_4    => p_trx_identifiers_4
               ,p_trx_identifiers_5    => p_trx_identifiers_5);  --Added for bug 7580995
      ELSE
         p_trx_identifiers_1  := ',NULL  USERIDS '; --Added for bug 7580995
    END IF;


--
-- Identifying ledger as Ledger or Ledger Set and get value for language
--
SELECT object_type_code, USERENV('LANG')
  INTO l_object_type, l_lang
  FROM gl_ledgers
 WHERE ledger_id = p_ledger_id;

IF(P_JE_SOURCE_NAME='ALL') THEN
  select application_id
    bulk COLLECT into l_responsibility_ids
    from xla_subledgers
   WHERE control_account_type_code = 'Y' or control_account_type_code = P_PARTY_TYPE;
END IF;
--
-- build join condition based on if ledger passed is a ledger set or a ledger
--
IF l_object_type = 'S' THEN
   l_ledger_set_from  := l_ledger_set_from ||' ,gl_ledger_set_assignments  glst ';
   l_ledger_set_where := l_ledger_set_where||' AND glst.ledger_set_id      = :P_LEDGER_ID '||
                         ' AND gll.ledger_id      = glst.ledger_id ';

   SELECT ledger_id
     INTO l_ledger_id
     FROM gl_ledger_set_assignments
    WHERE ledger_set_id = p_ledger_id
      AND ROWNUM = 1;
ELSE
   l_ledger_set_where := l_ledger_set_where||' AND gll.ledger_id      = :P_LEDGER_ID ';
   l_ledger_id := p_ledger_id;

END IF;

   SELECT  effective_period_num
          ,START_DATE
    INTO   l_start_period_num
          ,l_start_date
    FROM   gl_period_statuses
   WHERE   application_id = 101
     AND   ledger_id      = l_ledger_id
     AND   period_name    = p_period_from;

   SELECT  effective_period_num
          ,end_date
    INTO   l_end_period_num
          ,l_end_date
    FROM   gl_period_statuses
   WHERE   application_id = 101
     AND   ledger_id      = l_ledger_id
     AND   period_name    = p_period_to;

--
-- Third party information based on application_id
--
    -- 5072266 Modify po_vendors to use ap_suppliers
    -- po_vendors pov  -> ap_supplier  ap
    -- pov.segment1    -> aps.segment1
    -- pov.vendor_name -> vendor_name
    -- pov.party_id -> aps.vendor_id
    IF p_party_type = 'SUPPLIER' THEN
       p_party_col := ',aps.vendor_id                   PARTY_ID '
                    ||',aps.segment1                    PARTY_NUMBER'
                    ||',aps.vendor_name                 PARTY_NAME'
                    ||',NVL(apss.vendor_site_id,-999)   PARTY_SITE_ID'
                    ||',hps.party_site_number           PARTY_SITE_NUMBER'
                    ||',NULL                            PARTY_SITE_TAX_REGS_NUMBER';

       p_party_tab := ' ,ap_suppliers          aps
                        ,ap_supplier_sites_all apss ';

       p_party_join :=  'AND  aps.vendor_id          = xcb.party_id  '
                      ||'AND  hzp.party_id           = aps.party_id  '
                      ||'AND  apss.vendor_site_id(+) = xcb.party_site_id '
                      ||'AND  hps.party_site_id(+)   = apss.party_site_id';


   ELSIF p_party_type = 'CUSTOMER' THEN
        p_party_col := ',hca.cust_account_id           PARTY_ID'
                     ||',hca.account_number            PARTY_NUMBER'
                     ||',hzp.party_name                PARTY_NAME '
                     ||',NVL(hzcu.site_use_id, -999)   PARTY_SITE_ID'
                     ||',hps.party_site_number         PARTY_SITE_NUMBER'
                     ||',hzcu.tax_reference            PARTY_SITE_TAX_REGS_NUMBER';

       p_party_tab := ',hz_cust_accounts             hca '
                    ||',hz_cust_acct_sites_all       hcas'
                    ||',hz_cust_site_uses_all        hzcu';

       p_party_join :=' AND  hzp.party_id              = hca.party_id '
                    ||' AND  hca.cust_account_id       = xcb.party_id '
                    ||' AND  hzcu.site_use_id(+)       = xcb.party_site_id'
                    ||' AND  hcas.cust_acct_site_id(+) = hzcu.cust_acct_site_id'
                    ||' AND  hps.party_site_id(+)      = hcas.party_site_id ';
   ELSE
      p_party_col := C_NULL_PARTY_COLS;
   END IF;

   p_commercial_query := C_COMMERCIAL_QUERY;
   p_vat_registration_query := C_VAT_REGISTRATION_QUERY;

   --
   -- Qualified segments
   --
   p_qualifier_segment := C_QUALIFIED_SEGMENT;

   --
   -- get COA for the ledger/ledger set
   --

   SELECT chart_of_accounts_id
     INTO l_coa_id
     FROM gl_ledgers
    WHERE ledger_id = p_ledger_id;

   ----------------------------------------------------------------------------
   -- get qualifier segments for the COA
   ----------------------------------------------------------------------------
    xla_report_utility_pkg.get_acct_qualifier_segs
       (p_coa_id                    => l_coa_id
       ,p_balance_segment           => l_balancing_segment
       ,p_account_segment           => l_account_segment
       ,p_cost_center_segment       => l_costcenter_segment
       ,p_management_segment        => l_management_segment
       ,p_intercompany_segment      => l_intercompany_segment);

   --
   -- attach table alias to the column names
   --
   IF l_balancing_segment = 'NULL' THEN
      l_alias_balancing_segment := 'NULL';
   ELSE
      l_alias_balancing_segment := 'gcck.'||l_balancing_segment;
   END IF;

   IF l_account_segment = 'NULL' THEN
      l_alias_account_segment := 'NULL';
   ELSE
      l_alias_account_segment := 'gcck.'||l_account_segment;
   END IF;

   IF l_costcenter_segment = 'NULL' THEN
      l_alias_costcenter_segment := 'NULL';
   ELSE
      l_alias_costcenter_segment := 'gcck.'||l_costcenter_segment;
   END IF;

   IF l_management_segment = 'NULL' THEN
      l_alias_management_segment := 'NULL';
   ELSE
      l_alias_management_segment := 'gcck.'||l_management_segment;
   END IF;

   IF l_intercompany_segment = 'NULL' THEN
      l_alias_intercompany_segment := 'NULL';
   ELSE
      l_alias_intercompany_segment := 'gcck.'||l_intercompany_segment;
   END IF;

   --
   -- replace placeholders for the qualified segemnts
   --
   p_qualifier_segment:= REPLACE(p_qualifier_segment
                                 ,'$alias_balancing_segment$'
                                 ,l_alias_balancing_segment);

   p_qualifier_segment := REPLACE(p_qualifier_segment
                                 ,'$alias_account_segment$'
                                 ,l_alias_account_segment);

   p_qualifier_segment := REPLACE(p_qualifier_segment
                                 ,'$alias_costcenter_segment$'
                                 ,l_alias_costcenter_segment);

   p_qualifier_segment := REPLACE(p_qualifier_segment
                                 ,'$alias_management_segment$'
                                 ,l_alias_management_segment);

   p_qualifier_segment := REPLACE(p_qualifier_segment
                                 ,'$alias_intercompany_segment$'
                                 ,l_alias_intercompany_segment);

   -- bug 8295104

  xla_report_utility_pkg.get_segment_info
     (p_coa_id                    => l_coa_id
     ,p_balancing_segment         => l_balancing_segment
     ,p_account_segment           => l_account_segment
     ,p_costcenter_segment        => l_costcenter_segment
     ,p_management_segment        => l_management_segment
     ,p_intercompany_segment      => l_intercompany_segment
     ,p_alias_balancing_segment   => l_alias_balancing_segment
     ,p_alias_account_segment     => l_alias_account_segment
     ,p_alias_costcenter_segment  => l_alias_costcenter_segment
     ,p_alias_management_segment  => l_alias_management_segment
     ,p_alias_intercompany_segment=> l_alias_intercompany_segment
     ,p_seg_desc_column           => l_seg_desc_column
     ,p_seg_desc_from             => l_seg_desc_from
     ,p_seg_desc_join             => l_seg_desc_join
     ,p_hint                      => l_fnd_flex_hint
     );


   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg   => 'seg_desc_column ='||l_seg_desc_column
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module);
      trace
         (p_msg   => 'seg_desc_from ='||l_seg_desc_from
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module);
      trace
         (p_msg   => 'seg_desc_join ='||l_seg_desc_join
         ,p_level => C_LEVEL_STATEMENT
         ,p_module=> l_log_module);
   END IF;
   --
   -- replace placeholders for the qualified segemnts
   --
   p_qualifier_segment := REPLACE(p_qualifier_segment
                                 ,'$seg_desc_column$'
                                 ,l_seg_desc_column);

   p_seg_desc_from := l_seg_desc_from;

   p_seg_desc_join := l_seg_desc_join;

   --
   -- Legal Entity Information
   --

   --
   -- Replace placeholders for Legal entity information
   --
   IF p_include_le_info_flag = 'LEGAL_ENTITY' THEN
      p_legal_ent_col   := C_LEGAL_ENT_COL;
      p_legal_ent_from  := C_LEGAL_ENT_FROM;
      p_legal_ent_join  := C_LEGAL_ENT_JOIN;

      p_legal_ent_join  := REPLACE(p_legal_ent_join,'$leg_seg_val$',l_balancing_segment);

      IF p_legal_entity_id IS NOT NULL THEN

          --bug#7828983
          -- Check whether the ledger is an ALC ledger if yes change
          -- the join condition of the ledger with the primary ledger.
          -- As for ALC ledger there is no record in gl_ledger_le_bsv_specific_v table.
          -- gl_ledger_le_bsv_specific_v has a record for primary and secondary ledger for a
          -- given legal entity

            OPEN c_alc_ledger_check(l_ledger_id);
            FETCH c_alc_ledger_check INTO l_primary_ledger_id;
            CLOSE c_alc_ledger_check;


           IF l_primary_ledger_id IS NOT NULL THEN --indicates its a ALC ledger

            -- change the join condition. Join with primary ledger obtained from the cursor.

             p_legal_ent_join  := REPLACE(p_legal_ent_join, 'TABLE1.ledger_id', l_primary_ledger_id);
             p_legal_ent_join := p_legal_ent_join ||
                                ' AND gle.legal_entity_id = '||p_legal_entity_id;

          ELSE
            p_legal_ent_join := p_legal_ent_join ||
                              ' AND gle.legal_entity_id = '||p_legal_entity_id;

           END IF;

           --End bug#7828983

      END IF;
   ELSIF p_include_le_info_flag = 'ESTABLISHMENT' THEN
      p_legal_ent_col   := C_ESTBLISHMENT_COL;
      p_legal_ent_from  := C_ESTABLISHMENT_FROM;
      p_legal_ent_join  := C_ESTABLISHMENT_JOIN;

      p_legal_ent_join  := REPLACE(p_legal_ent_join,'$leg_seg_val$',l_balancing_segment);

      IF p_legal_entity_id IS NOT NULL THEN
          p_legal_ent_join := p_legal_ent_join ||
                              ' AND glv.legal_entity_id = '||p_legal_entity_id;
      END IF;
   ELSE -- p_include_le_info_flag = 'NONE' THEN
      p_legal_ent_col   := C_NULL_LEGAL_ENT_COL;
      p_legal_ent_from  := ' ';
      p_legal_ent_join  := ' ';

      IF p_legal_entity_id IS NOT NULL THEN
         p_legal_ent_from  := ' ,gl_ledger_le_bsv_specific_v gle ';
         p_legal_ent_join  := ' AND gle.ledger_id(+)        = TABLE1.LEDGER_ID '||
                              ' AND gle.segment_value(+)    = TABLE1.$leg_seg_val$ '||
                              ' AND gle.legal_entity_id(+)  = '||p_legal_entity_id;

         p_legal_ent_join  := REPLACE(p_legal_ent_join,'$leg_seg_val$',l_balancing_segment);
      END IF;
   END IF;


   --===========================================================================
   -- Build Filter condition based on parameters
   --===========================================================================
   --
   -- Filter based on Balancing Segment Value
   --
   IF p_balancing_segment_from IS NOT NULL AND
      p_balancing_segment_to IS NOT NULL THEN
      l_other_filter :=
         l_other_filter ||' AND '||l_alias_balancing_segment||' BETWEEN '''
         ||p_balancing_segment_from ||'''  AND  '''||p_balancing_segment_to||'''';
   END IF;
   --
   -- Filter based on Natural Account Segment Value
   --
   IF p_account_segment_from IS NOT NULL AND
      p_account_segment_to IS NOT NULL THEN
      l_other_filter :=
         l_other_filter ||' AND '||l_alias_account_segment||' BETWEEN '''
         ||p_account_segment_from ||'''  AND  '''||p_account_segment_to||'''';
   END IF;


   --
   -- <conditions based on side>
   --
   IF UPPER(p_balance_side_code) = 'DEBIT' THEN
      IF p_include_draft_activity ='Y' THEN
         IF p_balance_amount_from IS NOT NULL THEN
            l_other_filter :=
               l_other_filter ||
               ' AND((( NVL(xcb.beginning_balance_cr,0)
                      + NVL(xcb.period_balance_cr,0)
                      + NVL(xcb.draft_beginning_balance_cr,0)
                      + NVL(xcb.period_draft_balance_cr,0))
                    - ( NVL(xcb.beginning_balance_dr,0)
                      + NVL(xcb.period_balance_dr,0)
                      + NVL(xcb.draft_beginning_balance_dr,0)
                      + NVL(xcb.period_draft_balance_dr,0))) < -'
                      ||p_balance_amount_from ||' )';
         ELSE
           l_other_filter :=
               l_other_filter ||
               ' AND((( NVL(xcb.beginning_balance_cr,0)
                      + NVL(xcb.period_balance_cr,0)
                      + NVL(xcb.draft_beginning_balance_cr,0)
                      + NVL(xcb.period_draft_balance_cr,0))
                    - ( NVL(xcb.beginning_balance_dr,0)
                      + NVL(xcb.period_balance_dr,0)
                      + NVL(xcb.draft_beginning_balance_dr,0)
                      + NVL(xcb.period_draft_balance_dr,0))) < 0 )';
         END IF;
         IF p_balance_amount_to IS NOT NULL THEN
            l_other_filter :=
                l_other_filter ||
                ' AND((( NVL(xcb.beginning_balance_cr,0)
                       + NVL(xcb.period_balance_cr,0)
                       + NVL(xcb.draft_beginning_balance_cr,0)
                       + NVL(xcb.period_draft_balance_cr,0))
                     - ( NVL(xcb.beginning_balance_dr,0)
                       + NVL(xcb.period_balance_dr,0)
                       + NVL(xcb.draft_beginning_balance_dr,0)
                       + NVL(xcb.period_draft_balance_dr,0))) > -'
                       ||p_balance_amount_to ||' )';
         END IF;
      ELSE
         IF p_balance_amount_from IS NOT NULL THEN
            l_other_filter :=
               l_other_filter ||
               ' AND ((( NVL(xcb.beginning_balance_cr,0)
                       + NVL(xcb.period_balance_cr,0))
                     - ( NVL(xcb.beginning_balance_dr,0)
                       + NVL(xcb.period_balance_dr,0))) < -'
                       ||p_balance_amount_from||' )';
         ELSE
            l_other_filter :=
               l_other_filter ||
               ' AND((( NVL(xcb.beginning_balance_cr,0)
                      + NVL(xcb.period_balance_cr,0))
                    - ( NVL(xcb.beginning_balance_dr,0)
                      + NVL(xcb.period_balance_dr,0))) < 0 )';
         END IF;
         IF p_balance_amount_to IS NOT NULL THEN
            l_other_filter :=
               l_other_filter ||
               ' AND((( NVL(xcb.beginning_balance_cr,0)
                      + NVL(xcb.period_balance_cr,0))
                    - ( NVL(xcb.beginning_balance_dr,0)
                      + NVL(xcb.period_balance_dr,0))) > -'
                      ||p_balance_amount_to ||' ) ';
         END IF;
      END IF;
   ELSIF UPPER(p_balance_side_code) = 'CREDIT' THEN
      IF p_include_draft_activity ='Y' THEN
         IF p_balance_amount_from IS NOT NULL THEN
            l_other_filter :=
               l_other_filter ||
               ' AND ((( NVL(xcb.beginning_balance_cr,0)
                       + NVL(xcb.period_balance_cr,0)
                       + NVL(xcb.draft_beginning_balance_cr,0)
                       + NVL(xcb.period_draft_balance_cr,0))
                     - ( NVL(xcb.beginning_balance_dr,0)
                       + NVL(xcb.period_balance_dr,0)
                       + NVL(xcb.draft_beginning_balance_dr,0)
                       + NVL(xcb.period_draft_balance_dr,0)))> '
                       ||p_balance_amount_from ||' ) ';
      ELSE
         l_other_filter :=
            l_other_filter ||
            ' AND((( NVL(xcb.beginning_balance_cr,0)
                   + NVL(xcb.period_balance_cr,0)
                   + NVL(xcb.draft_beginning_balance_cr,0)
                   + NVL(xcb.period_draft_balance_cr,0))
                 - ( NVL(xcb.beginning_balance_dr,0)
                   + NVL(xcb.period_balance_dr,0)
                   + NVL(xcb.draft_beginning_balance_dr,0)
                   + NVL(xcb.period_draft_balance_dr,0))) > 0 )';
      END IF;
      IF p_balance_amount_to IS NOT NULL THEN
         l_other_filter :=
            l_other_filter ||
            ' AND((( NVL(xcb.beginning_balance_cr,0)
                   + NVL(xcb.period_balance_cr,0)
                   + NVL(xcb.draft_beginning_balance_cr,0)
                   + NVL(xcb.period_draft_balance_cr,0))
                  - (NVL(xcb.beginning_balance_dr,0)
                   + NVL(xcb.period_balance_dr,0)
                   + NVL(xcb.draft_beginning_balance_dr,0)
                   + NVL(xcb.period_draft_balance_dr,0))) < '
                   ||p_balance_amount_to ||' )';
      END IF;
      ELSE
         IF p_balance_amount_from IS NOT NULL THEN
            l_other_filter :=
               l_other_filter ||
               ' AND ((( NVL(xcb.beginning_balance_cr,0)
                       + NVL(xcb.period_balance_cr,0))
                     - ( NVL(xcb.beginning_balance_dr,0)
                       + NVL(xcb.period_balance_dr,0))) > '
                       ||p_balance_amount_from||' ) ';
         ELSE
            l_other_filter :=
               l_other_filter ||
               ' AND((( NVL(xcb.beginning_balance_cr,0)
                      + NVL(xcb.period_balance_cr,0))
                    - ( NVL(xcb.beginning_balance_dr,0))
                      + NVL(xcb.period_balance_dr,0))) > 0 )';
         END IF;
         IF p_balance_amount_to IS NOT NULL THEN
            l_other_filter :=
               l_other_filter ||
                ' AND ((( NVL(xcb.beginning_balance_cr,0)
                        + NVL(xcb.period_balance_cr,0))
                      - ( NVL(xcb.beginning_balance_dr,0)
                        + NVL(xcb.period_balance_dr,0))) < '
                        ||p_balance_amount_to|| ' )';
         END IF;
      END IF;
   END IF;

   --
   -- <condition for party type
   --
   IF p_party_type IS NOT NULL THEN
     IF p_party_type = 'CUSTOMER' THEN
       l_other_filter := l_other_filter||' AND xcb.party_type_code = ''C''';
     ELSIF p_party_type = 'SUPPLIER' THEN
       l_other_filter := l_other_filter||' AND xcb.party_type_code = ''S''';
     END IF;
   END IF;

   --
   -- <condition for party id
   --
   IF p_party_id IS NOT NULL THEN
      l_other_filter := l_other_filter||' AND xcb.party_id = '
                              ||p_party_id;
   END IF;

   --
   -- <condition for party site id
   --
   IF p_party_site_id IS NOT NULL THEN
      l_other_filter := l_other_filter||' AND xcb.party_site_id = '
                              ||p_party_site_id;
   END IF;

   --
   -- <condition for party number range
   -- parameter names changed for bug 5635953
   --
   IF p_party_number_from IS NOT NULL  AND
      p_party_number_to   IS NOT NULL  THEN
      IF p_party_type = 'CUSTOMER' THEN
         l_other_filter :=
            l_other_filter||' AND hca.account_number BETWEEN '''||p_party_number_from||
            ''' AND '''||p_party_number_to||''''; --bug 8544794 changed cust_account_id to account_number
      ELSIF p_party_type = 'SUPPLIER' THEN
         l_other_filter :=
            l_other_filter||' AND aps.segment1 BETWEEN '''||p_party_number_from||
            ''' AND '''||p_party_number_to||'''';
      END IF;
   END IF;

   --
   -- <condition based on Include Draft activity >
   --
   IF p_include_draft_activity_flag = 'Y' THEN
      p_other_filter :=p_other_filter||' AND aeh.accounting_entry_status_code IN (''D'',''F'')';
   ELSE
      p_other_filter :=p_other_filter||' AND aeh.accounting_entry_status_code = ''F'' ';
   END IF;

   --
   -- <condition for Including zero amount lines>
   --
   IF p_include_zero_amt_lines_flag = 'N' THEN
     p_other_filter := p_other_filter||' AND (NVL(ael.accounted_dr,0) <> 0
                     OR NVL(ael.accounted_cr,0) <> 0) ';

   END IF;

   p_lang := l_lang;
   p_start_period_num := l_start_period_num;
   p_end_period_num   := l_end_period_num;
   p_start_date := l_start_date;
   p_end_date   := l_end_date;

l_balance_query :=
   '
INSERT INTO xla_report_balances_gt
    (ledger_id
    ,ledger_short_name
    ,ledger_description
    ,ledger_name
    ,ledger_currency
    ,legal_entity_id
    ,legal_entity_name
    ,le_address_line_1
    ,le_address_line_2
    ,le_address_line_3
    ,le_city
    ,le_region_1
    ,le_region_2
    ,le_region_3
    ,le_postal_code
    ,le_country
    ,le_registration_number
    ,le_registration_effective_from
    ,le_activity_code
    ,le_sub_activity_code
    ,le_contact_name
    ,le_contact_phone_number
    ,party_type_code
    ,party_id
    ,party_number
    ,party_name
    ,party_site_id
    ,party_site_number
    ,party_site_tax_regs_number
    ,party_type_taxpayer_id
    ,party_tax_registration_number
    ,party_address_1
    ,party_address_2
    ,party_address_3
    ,party_address_4
    ,party_city
    ,party_zip_code
    ,party_state
    ,party_province
    ,party_country
    ,party_county
    ,party_site_name
    ,party_site_address_line_1
    ,party_site_address_line_2
    ,party_site_address_line_3
    ,party_site_address_line_4
    ,party_site_city
    ,party_site_zip_code
    ,party_site_state
    ,party_site_province
    ,party_site_country
    ,party_site_county
    ,application_id
    ,application_name
    ,je_source_name
    ,period_year
    ,period_number
    ,period_name
    ,period_start_date
    ,period_end_date
    ,begin_balance_dr
    ,begin_balance_cr
    ,period_net_dr
    ,period_net_cr
    ,begin_draft_balance_dr
    ,begin_draft_balance_cr
    ,period_draft_net_dr
    ,period_draft_net_cr
    ,code_combination_id
    ,accounting_code_combination
    ,code_combination_description
    ,balancing_segment
    ,natural_account_segment
    ,cost_center_segment
    ,management_segment
    ,intercompany_segment
    ,balancing_segment_desc
    ,natural_account_desc
    ,cost_center_desc
    ,management_segment_desc
    ,intercompany_segment_desc
    ,segment1
    ,segment2
    ,segment3
    ,segment4
    ,segment5
    ,segment6
    ,segment7
    ,segment8
    ,segment9
    ,segment10
    ,segment11
    ,segment12
    ,segment13
    ,segment14
    ,segment15
    ,segment16
    ,segment17
    ,segment18
    ,segment19
    ,segment20
    ,segment21
    ,segment22
    ,segment23
    ,segment24
    ,segment25
    ,segment26
    ,segment27
    ,segment28
    ,segment29
    ,segment30)
(
SELECT TABLE1.LEDGER_ID                              LEDGER_ID
      ,TABLE1.LEDGER_SHORT_NAME                      LEDGER_SHORT_NAME
      ,TABLE1.LEDGER_DESCRIPTION                     LEDGER_DESCRIPTION
      ,TABLE1.LEDGER_NAME                            LEDGER_NAME
      ,TABLE1.LEDGER_CURRENCY                        LEDGER_CURRENCY
      $legal_entity_columns$
      ,TABLE1.PARTY_TYPE_CODE                        PARTY_TYPE_CODE
      ,TABLE1.PARTY_ID                               PARTY_ID
      ,TABLE1.PARTY_NUMBER                           PARTY_NUMBER
      ,TABLE1.PARTY_NAME                             PARTY_NAME
      ,TABLE1.PARTY_SITE_ID                          PARTY_SITE_ID
      ,TABLE1.PARTY_SITE_NUMBER                      PARTY_SITE_NUMBER
      ,TABLE1.PARTY_SITE_TAX_REGS_NUMBER             PARTY_SITE_TAX_REGS_NUMBER
      ,TABLE1.PARTY_TYPE_TAXPAYER_ID                 PARTY_TYPE_TAXPAYER_ID
      ,TABLE1.PARTY_TAX_REGISTRATION_NUMBER          PARTY_TAX_REGISTRATION_NUMBER
      ,TABLE1.PARTY_ADDRESS_1                        PARTY_ADDRESS_1
      ,TABLE1.PARTY_ADDRESS_2                        PARTY_ADDRESS_2
      ,TABLE1.PARTY_ADDRESS_3                        PARTY_ADDRESS_3
      ,TABLE1.PARTY_ADDRESS_4                        PARTY_ADDRESS_4
      ,TABLE1.PARTY_CITY                             PARTY_CITY
      ,TABLE1.PARTY_ZIP_CODE                         PARTY_ZIP_CODE
      ,TABLE1.PARTY_STATE                            PARTY_STATE
      ,TABLE1.PARTY_PROVINCE                         PARTY_PROVINCE
      ,TABLE1.PARTY_COUNTRY                          PARTY_COUNTRY
      ,TABLE1.PARTY_COUNTY                           PARTY_COUNTY
      ,TABLE1.PARTY_SITE_NAME                        PARTY_SITE_NAME
      ,TABLE1.PARTY_SITE_ADDRESS_LINE_1              PARTY_SITE_ADDRESS_LINE_1
      ,TABLE1.PARTY_SITE_ADDRESS_LINE_2              PARTY_SITE_ADDRESS_LINE_2
      ,TABLE1.PARTY_SITE_ADDRESS_LINE_3              PARTY_SITE_ADDRESS_LINE_3
      ,TABLE1.PARTY_SITE_ADDRESS_LINE_4              PARTY_SITE_ADDRESS_LINE_4
      ,TABLE1.PARTY_SITE_CITY                        PARTY_SITE_CITY
      ,TABLE1.PARTY_SITE_ZIP_CODE                    PARTY_SITE_ZIP_CODE
      ,TABLE1.PARTY_SITE_STATE                       PARTY_SITE_STATE
      ,TABLE1.PARTY_SITE_PROVINCE                    PARTY_SITE_PROVINCE
      ,TABLE1.PARTY_SITE_COUNTRY                     PARTY_SITE_COUNTRY
      ,TABLE1.PARTY_SITE_COUNTY                      PARTY_SITE_COUNTY
      ,TABLE1.APPLICATION_ID                         APPLICATION_ID
      ,TABLE1.APPLICATION_NAME                       APPLICATION_NAME
      ,TABLE1.JE_SOURCE_NAME                         JE_SOURCE_NAME
      ,TABLE1.PERIOD_YEAR                            PERIOD_YEAR
      ,TABLE1.PERIOD_NUMBER                          PERIOD_NUMBER
      ,TABLE1.PERIOD_NAME                            PERIOD_NAME
      ,TABLE1.PERIOD_START_DATE                      PERIOD_START_DATE
      ,TABLE1.PERIOD_END_DATE                        PERIOD_END_DATE
      ,TABLE1.BEGIN_BALANCE_DR                       BEGIN_BALANCE_DR
      ,TABLE1.BEGIN_BALANCE_CR                       BEGIN_BALANCE_CR
      ,TABLE1.PERIOD_NET_DR                          PERIOD_NET_DR
      ,TABLE1.PERIOD_NET_CR                          PERIOD_NET_CR
      ,TABLE1.BEGIN_DRAFT_BALANCE_DR                 BEGIN_DRAFT_BALANCE_DR
      ,TABLE1.BEGIN_DRAFT_BALANCE_CR                 BEGIN_DRAFT_BALANCE_CR
      ,TABLE1.PERIOD_DRAFT_NET_DR                    PERIOD_DRAFT_NET_DR
      ,TABLE1.PERIOD_DRAFT_NET_CR                    PERIOD_DRAFT_NET_CR
      ,TABLE1.CODE_COMBINATION_ID                    CODE_COMBINATION_ID
      ,TABLE1.ACCOUNTING_CODE_COMBINATION            ACCOUNTING_CODE_COMBINATION
      ,TABLE1.CODE_COMBINATION_DESCRIPTION           CODE_COMBINATION_DESCRIPTION
      ,TABLE1.BALANCING_SEGMENT                      BALANCING_SEGMENT
      ,TABLE1.NATURAL_ACCOUNT_SEGMENT                NATURAL_ACCOUNT_SEGMENT
      ,TABLE1.COST_CENTER_SEGMENT                    COST_CENTER_SEGMENT
      ,TABLE1.MANAGEMENT_SEGMENT                     MANAGEMENT_SEGMENT
      ,TABLE1.INTERCOMPANY_SEGMENT                   INTERCOMPANY_SEGMENT
      ,TABLE1.BALANCING_SEGMENT_DESC                 BALANCING_SEGMENT_DESC
      ,TABLE1.NATURAL_ACCOUNT_DESC                   NATURAL_ACCOUNT_DESC
      ,TABLE1.COST_CENTER_DESC                       COST_CENTER_DESC
      ,TABLE1.MANAGEMENT_SEGMENT_DESC                MANAGEMENT_SEGMENT_DESC
      ,TABLE1.INTERCOMPANY_SEGMENT_DESC              INTERCOMPANY_SEGMENT_DESC
      ,TABLE1.SEGMENT1                               SEGMENT1
      ,TABLE1.SEGMENT2                               SEGMENT2
      ,TABLE1.SEGMENT3                               SEGMENT3
      ,TABLE1.SEGMENT4                               SEGMENT4
      ,TABLE1.SEGMENT5                               SEGMENT5
      ,TABLE1.SEGMENT6                               SEGMENT6
      ,TABLE1.SEGMENT7                               SEGMENT7
      ,TABLE1.SEGMENT8                               SEGMENT8
      ,TABLE1.SEGMENT9                               SEGMENT9
      ,TABLE1.SEGMENT10                              SEGMENT10
      ,TABLE1.SEGMENT11                              SEGMENT11
      ,TABLE1.SEGMENT12                              SEGMENT12
      ,TABLE1.SEGMENT13                              SEGMENT13
      ,TABLE1.SEGMENT14                              SEGMENT14
      ,TABLE1.SEGMENT15                              SEGMENT15
      ,TABLE1.SEGMENT16                              SEGMENT16
      ,TABLE1.SEGMENT17                              SEGMENT17
      ,TABLE1.SEGMENT18                              SEGMENT18
      ,TABLE1.SEGMENT19                              SEGMENT19
      ,TABLE1.SEGMENT20                              SEGMENT20
      ,TABLE1.SEGMENT21                              SEGMENT21
      ,TABLE1.SEGMENT22                              SEGMENT22
      ,TABLE1.SEGMENT23                              SEGMENT23
      ,TABLE1.SEGMENT24                              SEGMENT24
      ,TABLE1.SEGMENT25                              SEGMENT25
      ,TABLE1.SEGMENT26                              SEGMENT26
      ,TABLE1.SEGMENT27                              SEGMENT27
      ,TABLE1.SEGMENT28                              SEGMENT28
      ,TABLE1.SEGMENT29                              SEGMENT29
      ,TABLE1.SEGMENT30                              SEGMENT30
  FROM
   (SELECT gll.ledger_id                          LEDGER_ID
          ,gll.short_name                         LEDGER_SHORT_NAME
          ,gll.description                        LEDGER_DESCRIPTION
          ,gll.NAME                               LEDGER_NAME
          ,gll.currency_code                      LEDGER_CURRENCY
          ,xcb.party_type_code                    PARTY_TYPE_CODE
          $party_col$
          ,hzp.jgzz_fiscal_code                   PARTY_TYPE_TAXPAYER_ID
          ,hzp.tax_reference                      PARTY_TAX_REGISTRATION_NUMBER
          ,hzp.address1                           PARTY_ADDRESS_1
          ,hzp.address2                           PARTY_ADDRESS_2
          ,hzp.address3                           PARTY_ADDRESS_3
          ,hzp.address4                           PARTY_ADDRESS_4
          ,hzp.city                               PARTY_CITY
          ,hzp.postal_code                        PARTY_ZIP_CODE
          ,hzp.state                              PARTY_STATE
          ,hzp.province                           PARTY_PROVINCE
          ,hzp.country                            PARTY_COUNTRY
          ,hzp.county                             PARTY_COUNTY
          ,hps.party_site_name                    PARTY_SITE_NAME
          ,hzl.address1                           PARTY_SITE_ADDRESS_LINE_1
          ,hzl.address2                           PARTY_SITE_ADDRESS_LINE_2
          ,hzl.address3                           PARTY_SITE_ADDRESS_LINE_3
          ,hzl.address4                           PARTY_SITE_ADDRESS_LINE_4
          ,hzl.city                               PARTY_SITE_CITY
          ,hzl.postal_code                        PARTY_SITE_ZIP_CODE
          ,hzl.state                              PARTY_SITE_STATE
          ,hzl.province                           PARTY_SITE_PROVINCE
          ,hzl.country                            PARTY_SITE_COUNTRY
          ,hzl.county                             PARTY_SITE_COUNTY
          ,xcb.application_id                     APPLICATION_ID
          ,fap.application_name                   APPLICATION_NAME
          ,gjst.user_je_source_name               JE_SOURCE_NAME
          ,gls.period_year                        PERIOD_YEAR
          ,gls.period_num                         PERIOD_NUMBER
          ,xcb.period_name                        PERIOD_NAME
          ,trunc(gls.START_DATE)                  PERIOD_START_DATE
          ,trunc(gls.end_date)                    PERIOD_END_DATE
          ,NVL(xcb.beginning_balance_dr,0)         BEGIN_BALANCE_DR
          ,NVL(xcb.beginning_balance_cr,0)         BEGIN_BALANCE_CR
          ,NVL(xcb.period_balance_dr,0)            PERIOD_NET_DR
          ,NVL(xcb.period_balance_cr,0)            PERIOD_NET_CR
          ,NVL(xcb.draft_beginning_balance_dr,0)   BEGIN_DRAFT_BALANCE_DR
          ,NVL(xcb.draft_beginning_balance_cr,0)   BEGIN_DRAFT_BALANCE_CR
          ,NVL(xcb.period_draft_balance_dr,0)      PERIOD_DRAFT_NET_DR
          ,NVL(xcb.period_draft_balance_cr,0)      PERIOD_DRAFT_NET_CR
          ,xcb.code_combination_id                 CODE_COMBINATION_ID
          ,gcck.concatenated_segments              ACCOUNTING_CODE_COMBINATION
          ,xla_report_utility_pkg.get_ccid_desc
              (gll.chart_of_accounts_id
              ,xcb.code_combination_id)            CODE_COMBINATION_DESCRIPTION
          $seg_desc_column$
          ,gcck.segment1                           SEGMENT1
          ,gcck.segment2                           SEGMENT2
          ,gcck.segment3                           SEGMENT3
          ,gcck.segment4                           SEGMENT4
          ,gcck.segment5                           SEGMENT5
          ,gcck.segment6                           SEGMENT6
          ,gcck.segment7                           SEGMENT7
          ,gcck.segment8                           SEGMENT8
          ,gcck.segment9                           SEGMENT9
          ,gcck.segment10                          SEGMENT10
          ,gcck.segment11                          SEGMENT11
          ,gcck.segment12                          SEGMENT12
          ,gcck.segment13                          SEGMENT13
          ,gcck.segment14                          SEGMENT14
          ,gcck.segment15                          SEGMENT15
          ,gcck.segment16                          SEGMENT16
          ,gcck.segment17                          SEGMENT17
          ,gcck.segment18                          SEGMENT18
          ,gcck.segment19                          SEGMENT19
          ,gcck.segment20                          SEGMENT20
          ,gcck.segment21                          SEGMENT21
          ,gcck.segment22                          SEGMENT22
          ,gcck.segment23                          SEGMENT23
          ,gcck.segment24                          SEGMENT24
          ,gcck.segment25                          SEGMENT25
          ,gcck.segment26                          SEGMENT26
          ,gcck.segment27                          SEGMENT27
          ,gcck.segment28                          SEGMENT28
          ,gcck.segment29                          SEGMENT29
          ,gcck.segment30                          SEGMENT30
      FROM gl_ledgers                        gll
          ,xla_control_balances              xcb
          ,gl_period_statuses                gls
          ,gl_code_combinations_kfv          gcck
          ,hz_parties                        hzp
          ,hz_party_sites                    hps
          ,hz_locations                      hzl
          ,fnd_application_tl                fap
          ,xla_subledgers                    xls
          ,gl_je_sources_tl                  gjst
          $party_tab$
          $seg_desc_from$
          $l_ledger_set_from$
     WHERE gls.ledger_id              = gll.ledger_id
       AND gls.application_id         = 101
       AND gls.effective_period_num   BETWEEN :P_START_PERIOD_NUM AND :P_END_PERIOD_NUM
       AND xcb.ledger_id              = gll.ledger_id
       AND xcb.application_id         = :G_JE_SOURCE_APPLICATION_ID
       AND xcb.period_name            = gls.period_name
       AND gcck.code_combination_id   = xcb.code_combination_id
       AND hzl.location_id(+)         = hps.location_id
       AND fap.application_id         = xcb.application_id
       AND fap.LANGUAGE               = :P_LANG
       AND xls.application_id         = xcb.application_id
       AND gjst.je_source_name        = xls.je_source_name
       AND gjst.LANGUAGE              = :P_LANG
       $other_filter$
       $p_party_join$
       $seg_desc_join$
       $l_ledger_set_where$
       $account_range$)  TABLE1
       $legal_entity_from$
 WHERE 1 = 1
       $legal_entity_join$
)' ;

   l_balance_query  := REPLACE(l_balance_query
                                        ,'$legal_entity_columns$'
                                        ,p_legal_ent_col);
   l_balance_query := REPLACE(l_balance_query
                                        ,'$party_col$'
                                        ,p_party_col);
   l_balance_query  := REPLACE(l_balance_query
                                        ,'$seg_desc_column$'
                                        ,p_qualifier_segment);
   l_balance_query  := REPLACE(l_balance_query
                                        ,'$party_tab$'
                                        ,p_party_tab);
   l_balance_query  := REPLACE(l_balance_query
                                        ,'$legal_entity_from$'
                                        ,p_legal_ent_from);
   l_balance_query  := REPLACE(l_balance_query
                                        ,'$seg_desc_from$'
                                       ,p_seg_desc_from);
   l_balance_query  := REPLACE(l_balance_query
                                        ,'$other_filter$'
                                        ,l_other_filter);
   l_balance_query  := REPLACE(l_balance_query
                                        ,'$p_party_join$'
                                        ,p_party_join);
   l_balance_query  := REPLACE(l_balance_query
                                        ,'$legal_entity_join$'
                                        ,p_legal_ent_join);
   l_balance_query  := REPLACE(l_balance_query
                                        ,'$seg_desc_join$'
                                        ,p_seg_desc_join);
   l_balance_query  := REPLACE(l_balance_query
                                        ,'$l_ledger_set_from$'
                                        ,l_ledger_set_from);
   l_balance_query  := REPLACE(l_balance_query
                                        ,'$l_ledger_set_where$'
                                        ,l_ledger_set_where);

   IF p_accounting_flexfield_from IS NOT NULL THEN
      l_flex_range_where :=
         get_flex_range_where
            (p_coa_id       => l_coa_id
            ,p_accounting_flexfield_from  => p_accounting_flexfield_from
            ,p_accounting_flexfield_to    => p_accounting_flexfield_to   );

         l_balance_query := REPLACE (l_balance_query
                                    ,'$account_range$'
                                    ,' AND '||l_flex_range_where);
   ELSE
      l_balance_query := REPLACE(l_balance_query, '$account_range$', '');
   END IF;

   IF(P_JE_SOURCE_NAME='ALL') THEN
      FORALL i IN 1..l_responsibility_ids.count
        execute immediate l_balance_query
        using p_start_period_num
           ,p_end_period_num
           ,l_responsibility_ids(i)
           ,p_lang
           ,p_lang
           ,p_ledger_id;
   ELSE
      execute immediate l_balance_query
      using p_start_period_num
         ,p_end_period_num
         ,g_je_source_application_id
         ,p_lang
         ,p_lang
         ,p_ledger_id;
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace
            (p_msg      => 'END of beforeReport'
            ,p_level    => C_LEVEL_PROCEDURE
            ,p_module   => l_log_module);
   END IF;

   RETURN TRUE;

EXCEPTION
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location  => 'xla_tp_balance_rpt_pkg.beforeReport ');
END beforeReport;


--=============================================================================
--          *********** Initialization routine **********
--=============================================================================

--=============================================================================
--
--
--
--
--
--
--
--
--
--
-- Following code is executed when the package body is referenced for the first
-- time
--
--
--
--
--
--
--
--
--
--
--
--
--=============================================================================

BEGIN
   g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled    := fnd_log.test
                          (log_level  => g_log_level
                          ,MODULE     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;


END XLA_TP_BALANCE_RPT_PKG;




/
