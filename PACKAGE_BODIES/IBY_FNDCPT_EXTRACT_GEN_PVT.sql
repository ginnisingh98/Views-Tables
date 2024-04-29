--------------------------------------------------------
--  DDL for Package Body IBY_FNDCPT_EXTRACT_GEN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_FNDCPT_EXTRACT_GEN_PVT" AS
/* $Header: ibyfcxgb.pls 120.31.12010000.9 2010/01/07 08:56:43 sgogula ship $ */

  G_DEBUG_MODULE CONSTANT VARCHAR2(100) := 'iby.plsql.IBY_FNDCPT_EXTRACT_GEN_PVT';

  G_SRA_DELIVERY_METHOD_ATTR CONSTANT NUMBER := 1;
  G_SRA_EMAIL_ATTR CONSTANT NUMBER := 2;
  G_SRA_FAX_ATTR CONSTANT NUMBER := 3;
  G_SRA_REQ_FLAG_ATTR CONSTANT NUMBER := 4;
  G_SRA_PS_LANG_ATTR CONSTANT NUMBER := 5;
  G_SRA_PS_TERRITORY_ATTR CONSTANT NUMBER := 6;
  G_PF_FORMAT_ATTR CONSTANT NUMBER := 7;
  G_SRA_PN_CONDITION CONSTANT NUMBER := 8;
  G_SRA_PN_NUM_DOCUMENTS CONSTANT NUMBER := 9;


  G_SRA_DELIVERY_METHOD_PRINTED CONSTANT VARCHAR2(30) := 'PRINTED';
  G_SRA_DELIVERY_METHOD_EMAIL CONSTANT VARCHAR2(30) := 'EMAIL';
  G_SRA_DELIVERY_METHOD_FAX CONSTANT VARCHAR2(30) := 'FAX';

  G_EXTRACT_MODE_PMT CONSTANT NUMBER := 1;
  G_EXTRACT_MODE_SRA CONSTANT NUMBER := 2;

  G_Extract_Run_Mode NUMBER := G_EXTRACT_MODE_PMT;
  G_Extract_Run_Delivery_Method VARCHAR2(30);
  G_Extract_Run_Payment_id NUMBER;

  PROCEDURE Setup_for_Extract
  (
  p_sys_key          IN     iby_security_pkg.DES3_KEY_TYPE
  );

  FUNCTION Get_Payer_Notif_Where_cluase
  (
  p_mbatchid         IN     VARCHAR2,
  p_fromDate         IN     VARCHAR2,
  p_toDate           IN     VARCHAR2,
  p_fromPSON         IN     VARCHAR2,
  p_toPSON           IN     VARCHAR2,
  p_delivery_method  IN     VARCHAR2,
  p_format_code      IN     VARCHAR2,
  p_debug_module     IN     VARCHAR2
  ) RETURN VARCHAR2;


  FUNCTION Get_Payer_Notif_Where_cluase
  (
  p_mbatchid         IN     VARCHAR2,
  p_fromDate         IN     VARCHAR2,
  p_toDate           IN     VARCHAR2,
  p_fromPSON         IN     VARCHAR2,
  p_toPSON           IN     VARCHAR2,
  p_delivery_method  IN     VARCHAR2,
  p_format_code      IN     VARCHAR2,
  p_debug_module     IN     VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_Debug_Module   VARCHAR2(255);
    l_where_clause   VARCHAR2(4000);

  BEGIN

    l_Debug_Module := p_debug_module;

    iby_debug_pub.add(debug_msg => 'p_mbatchid: ' || p_mbatchid,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'p_fromDate: ' || p_fromDate,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'p_toDate: ' || p_toDate,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'p_fromPSON: ' || p_fromPSON,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'p_toPSON: ' || p_toPSON,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'p_delivery_method: ' || p_delivery_method,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'p_format_code: ' || p_format_code,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    -- back out this changes due to performance reasons
    -- from date is required program parameter
    -- to date is defaulted to sysdate
    -- this select assumes if the variables are not passed they are null so the variables should be set to null in that
    -- case in the module where the dynamic sql is executed.
    --l_where_clause := l_where_clause||' and txn.reqdate >= nvl(to_date(:p_fromDate, ''YYYY/MM/DD HH24:MI:SS''), SYSDATE) '
    --                                ||' and txn.reqdate <= nvl(to_date(:p_toDate, ''YYYY/MM/DD HH24:MI:SS''), SYSDATE) '
    --                                ||' and NVL(txn.mbatchid, -1) = NVL(:p_mbatchid, NVL(txn.mbatchid,-1)) '
    --                                ||' and txn.tangibleid >= NVL(:p_fromPSON, txn.tangibleid) '
    --                                ||' and txn.tangibleid <= NVL(:p_toPSON, txn.tangibleid) '
    --                                ||' and nvl(iby_fndcpt_extract_gen_pvt.Get_sra_Attribute(txn.trxnmid,1), ''x'') = nvl(:p_delivery_method, ''x'') ';

    -- from date is required program parameter
    l_where_clause := l_where_clause || ' and txn.reqdate >= nvl(to_date( :p_fromDate, ''YYYY/MM/DD HH24:MI:SS''), SYSDATE) ';

    IF nvl(upper(p_toDate), 'NULL') <> 'NULL' THEN
      l_where_clause := l_where_clause || ' and txn.reqdate <= nvl(to_date('|| ''''||p_toDate|| ''''||', ''YYYY/MM/DD HH24:MI:SS''), SYSDATE) ';
      l_where_clause := REPLACE(l_where_clause, 'p_toDate', REPLACE(p_toDate, '00:00:00', '23:59:59'));
    END IF;

    IF nvl(upper(p_mbatchid), 'NULL') <> 'NULL' THEN
      l_where_clause := l_where_clause || ' and txn.mbatchid = ' || p_mbatchid;
    END IF;

    IF nvl(upper(p_fromPSON), 'NULL') <> 'NULL' THEN
      l_where_clause := l_where_clause || ' and txn.tangibleid >= ' || '''' || p_fromPSON|| '''';
    END IF;

    IF nvl(upper(p_toPSON), 'NULL') <> 'NULL' THEN
      l_where_clause := l_where_clause || ' and txn.tangibleid <= ' || '''' || p_toPSON|| '''';
    END IF;

    -- p_delivery_method must not be null
    -- we don't create extract if p_delivery_method is null
    l_where_clause := l_where_clause || ' and nvl(iby_fndcpt_extract_gen_pvt.Get_sra_Attribute(txn.trxnmid,1), ''x'') = nvl (:p_delivery_method, ''x'') ';

    -- p_format_code must not be null
    -- we don't create extract if p_format_code is null
    l_where_clause := l_where_clause || ' and iby_fndcpt_extract_gen_pvt.Get_sra_Attribute(txn.trxnmid, 7) = :p_format_code ';

    RETURN l_where_clause;

  END Get_Payer_Notif_Where_cluase;


  -- bug 5115161: payer notification
  PROCEDURE Create_Payer_Notif_Extract_1_0
  (
  p_mbatchid         IN     VARCHAR2,
  p_fromDate         IN     VARCHAR2,
  p_toDate           IN     VARCHAR2,
  p_fromPSON         IN     VARCHAR2,
  p_toPSON           IN     VARCHAR2,
  p_delivery_method  IN     VARCHAR2,
  p_format_code      IN     VARCHAR2,
  p_txn_id           IN     NUMBER,
  p_sys_key          IN     iby_security_pkg.DES3_KEY_TYPE,
  x_extract_doc      OUT NOCOPY CLOB
  )
  IS
    l_Debug_Module   VARCHAR2(255) := G_DEBUG_MODULE || '.Create_Payer_Notif_Extract_1_0';
    l_xml XMLTYPE;
    l_where_clause    VARCHAR2(4000);
    l_extract_query   VARCHAR2(4000) :=
      'select XMLElement("FundsCapturePayerNotification", ' ||
      '         XMLElement("FormatProgramRequestID", fnd_global.CONC_REQUEST_ID), ' ||
      '         XMLAgg(xml_order.FNDCPT_ORDER)) ' ||
      '  from iby_trxn_summaries_all txn, IBY_XML_FNDCPT_ORDER_PN_1_0_V xml_order ' ||
      ' where txn.trxnmid = xml_order.trxnmid ' ||
      '   and nvl(txn.payer_notification_required, ''N'') = ''Y'' ';

--    l_trxn_id          iby_trxn_summaries_all.trxnmid%TYPE;
--    l_mbatchid         VARCHAR2(100);
--    l_toDate           VARCHAR2(100);
--    l_delivery_method  VARCHAR2(30);
--    l_fromPSON         iby_trxn_summaries_all.tangibleid%TYPE;
--    l_toPSON           iby_trxn_summaries_all.tangibleid%TYPE;

  BEGIN

    iby_debug_pub.add(debug_msg => 'Enter: '  || l_Debug_Module,
                      debug_level => FND_LOG.LEVEL_PROCEDURE,
                      module => l_Debug_Module);

    CEP_STANDARD.init_security;

    l_where_clause := Get_Payer_Notif_Where_cluase
    (
    p_mbatchid         => p_mbatchid,
    p_fromDate         => p_fromDate,
    p_toDate           => p_toDate,
    p_fromPSON         => p_fromPSON,
    p_toPSON           => p_toPSON,
    p_delivery_method  => p_delivery_method,
    p_format_code      => p_format_code,
    p_debug_module     => l_Debug_Module
    );

    l_extract_query := l_extract_query || l_where_clause;

    IF p_txn_id <> -99 THEN
      l_extract_query := l_extract_query || ' and txn.trxnmid = ' || p_txn_id;
    END IF;

    -- back out this changes for performance reasons
    -- this is required since the variables come to the word null to determine
    -- it is a null value
    -- IF nvl(upper(p_mbatchid), 'NULL') <> 'NULL' THEN
    --   l_mbatchid := p_mbatchid;
    -- END IF;

    -- IF nvl(upper(p_toDate), 'NULL') <> 'NULL' THEN
    --   IF instr(p_toDate, '00:00:00') <> 0 THEN
    --     l_toDate := REPLACE(p_toDate, '00:00:00', '23:59:59');
    --   ELSE
    --     l_toDate := p_toDate;
    --   END IF;
    -- END IF;

    -- IF nvl(upper(p_fromPSON), 'NULL') <> 'NULL' THEN
    --   l_fromPSON := p_fromPSON;
    -- END IF;

    -- IF nvl(upper(p_toPSON), 'NULL') <> 'NULL' THEN
    --   l_toPSON := p_toPSON;
    -- END IF;

    -- IF nvl(upper(p_delivery_method), 'NULL') <> 'NULL' THEN
    --   l_delivery_method := p_delivery_method;
    -- END IF;

    -- IF p_txn_id <> -99 THEN
    --   l_trxn_id := p_txn_id;
    -- END IF;

    -- l_extract_query := l_extract_query||' and txn.trxnmid = NVL(:p_txn_id, txn.trxnmid) ';

    G_Extract_Run_Mode := G_EXTRACT_MODE_SRA;
    G_Extract_Run_Delivery_Method := p_delivery_method;
    G_Extract_Run_Payment_id := p_txn_id;

    Setup_for_Extract(p_sys_key);

    iby_debug_pub.add(debug_msg => 'After Setup_for_Extract() ',
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'Before executing dynamic query.',
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'l_extract_query: ' || l_extract_query,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    --iby_debug_pub.add(debug_msg => 'variables: '||p_fromDate||':'||l_toDate||':'||
    --                  l_mbatchid||':'||l_fromPSON||':'||l_toPSON||':'||
    --                  l_delivery_method||':'||p_format_code||':'||l_trxn_id,
    --                  debug_level => FND_LOG.LEVEL_STATEMENT,
    --                  module => l_Debug_Module);

    EXECUTE IMMEDIATE l_extract_query INTO l_xml USING p_fromDate, p_delivery_method, p_format_code;

    -- EXECUTE IMMEDIATE l_extract_query INTO l_xml
    --        USING p_fromDate, l_toDate, l_mbatchid,
    --              l_fromPSON, l_toPSON,
    --              l_delivery_method, p_format_code,
    --              l_trxn_id;

    x_extract_doc := XMLType.getClobVal(l_xml);

    iby_debug_pub.add(debug_msg => 'Exit: '  || l_Debug_Module,
                      debug_level => FND_LOG.LEVEL_PROCEDURE,
                      module => l_Debug_Module);

    -- clears out data from global temporary table
    COMMIT;

    EXCEPTION
      WHEN OTHERS THEN
        -- make sure procedure is not exited before a COMMIT
        -- so as to remove security keys
        COMMIT;
        RAISE;

  END Create_Payer_Notif_Extract_1_0;


  -- shared. Main entry point for FC accompany letter
  PROCEDURE Setup_for_Extract
  (
  p_sys_key          IN     iby_security_pkg.DES3_KEY_TYPE
  )
  IS
    lx_err_code       VARCHAR2(30);
    l_xml_base        VARCHAR2(255);
    l_char_extract_mdoe VARCHAR2(255) := 'G_EXTRACT_MODE_PMT';
    l_Debug_Module    VARCHAR2(255) :=
      G_DEBUG_MODULE || '.Setup_for_Extract [Shared]';
  BEGIN

    iby_utility_pvt.get_property('IBY_XML_BASE',l_xml_base);

    iby_utility_pvt.set_view_param(G_VP_XML_BASE,NVL(l_xml_base,''));

    IF G_Extract_Run_Mode = G_EXTRACT_MODE_SRA THEN
      l_char_extract_mdoe := 'G_EXTRACT_MODE_SRA';
    END IF;

    iby_utility_pvt.set_view_param(G_VP_EXTRACT_MODE, l_char_extract_mdoe);

    iby_debug_pub.add(debug_msg => 'The extract mode is: ' || G_Extract_Run_Mode,
                    debug_level => FND_LOG.LEVEL_STATEMENT,
                    module => l_Debug_Module);

    IF (NOT p_sys_key IS NULL) THEN
      iby_security_pkg.validate_sys_key(p_sys_key,lx_err_code);
      IF (NOT lx_err_code IS NULL) THEN
       	raise_application_error(-20000,lx_err_code, FALSE);
      END IF;
      iby_utility_pvt.set_view_param(G_VP_SYS_KEY,p_sys_key);
    END IF;

  END Setup_for_Extract;

  -- shared. Main entry point for FC accompany letter
  PROCEDURE Create_Extract_1_0
  (
  p_instr_type       IN     VARCHAR2,
  p_req_type         IN     VARCHAR2,
  p_txn_id           IN     NUMBER,
  p_sys_key          IN     iby_security_pkg.DES3_KEY_TYPE,
  x_extract_doc      OUT NOCOPY CLOB
  )
  IS
    l_Debug_Module    VARCHAR2(255) :=
      G_DEBUG_MODULE || '.Create_Extract_1_0 [Shared]';
  BEGIN

    Setup_for_Extract(p_sys_key);

    IF ((p_req_type = 'ORAPMTCLOSEBATCH')
      OR (p_req_type = 'ORAPMTEFTCLOSEBATCH')
      OR (p_req_type = 'ORAPMTPDCCLOSEBATCH')) THEN

      SELECT XMLType.getClobVal(instruction)
      INTO x_extract_doc
      FROM iby_xml_batch_fci_1_0_v
      WHERE mbatchid=p_txn_id
      AND rownum=1;
    ELSE
      SELECT XMLType.getClobVal(instruction)
      INTO x_extract_doc
      FROM iby_xml_online_fci_1_0_v
      WHERE trxnmid=p_txn_id
      AND rownum=1;
    END IF;

    -- clears out data from global temporary table
    COMMIT;

    EXCEPTION
      WHEN OTHERS THEN
        -- make sure procedure is not exited before a COMMIT
        -- so as to remove security keys
        COMMIT;
        RAISE;

  END Create_Extract_1_0;


  -- overloaded version with
  -- p_sec_val for credit card cvv2
  PROCEDURE Create_Extract_1_0
  (
  p_instr_type       IN     VARCHAR2,
  p_req_type         IN     VARCHAR2,
  p_txn_id           IN     NUMBER,
  p_sys_key          IN     iby_security_pkg.DES3_KEY_TYPE,
  p_sec_val          IN     VARCHAR2,
  x_extract_doc      OUT NOCOPY CLOB
  )
  IS
    l_xml_base        VARCHAR2(255);
    lx_err_code       VARCHAR2(30);
  BEGIN

    G_Extract_Run_Mode := G_EXTRACT_MODE_PMT;

    iby_utility_pvt.set_view_param(G_VP_SEC_VAL ,NVL(p_sec_val,' '));

    Create_Extract_1_0
    (
    p_instr_type       => p_instr_type,
    p_req_type         => p_req_type,
    p_txn_id           => p_txn_id,
    p_sys_key          => p_sys_key,
    x_extract_doc      => x_extract_doc
    );

  END Create_Extract_1_0;

  -- obselete per bug 5115161
  FUNCTION Get_Ins_PayeeAcctAgg(p_mbatch_id IN NUMBER)
  RETURN XMLTYPE
  IS

    l_payeeacct_agg XMLTYPE;
    l_Debug_Module   VARCHAR2(255) := G_DEBUG_MODULE || '.Get_Ins_PayeeAcctAgg';

    -- the cursors should be kept in-sync with IBY_XML_FNDCPT_ACCT_1_0_V
    -- electronic payer notification
    CURSOR l_payeeacct_ele_csr (p_mbatch_id IN NUMBER) IS
    SELECT
      XMLElement("PayeeAccount",
        XMLElement("PaymentSystemAccount",
          XMLElement("AccountName",txn.bepkey),
          Extract(XMLAgg(XMLElement("OptionSet",opts.account_options)),
                  'OptionSet[1]/*')
        ),
        CASE WHEN (NOT xml_bank.instrid IS NULL) THEN
         Extract(XMLAgg(XMLElement("BankAccount",xml_bank.bank_account_content)),
                 '/BankAccount[1]')
        END,
        XMLElement("Payee",
          XMLElement("Name",payee.name),
          XMLElement("Address",
            XMLElement("AddressLine1",null),
            XMLForest(null AS "AddressLine2",null AS "AddressLine3"),
            XMLElement("City",null),
            XMLElement("State",null),
            XMLElement("Country",null),
            XMLElement("PostalCode",null)
          ),
          XMLForest(DECODE(payee.mcc_code, -1,null, payee.mcc_code) AS "MCC")
        ),
        XMLElement("OrderCount",count(txn.trxnmid)),
        XMLElement("AccountTotals",
          XMLElement("AuthorizationsTotal",
            XMLElement("Value",
             DECODE(txn.INSTRTYPE, 'PINLESSDEBITCARD', 0,
                                   'BANKACCOUNT', 0,
                                    SUM(DECODE(txn.trxntypeid, 2,txn.amount, 0)) )),
            XMLElement("Currency",
              XMLElement("Code",MAX(txn.currencynamecode))
            )
          ),
          XMLElement("CapturesTotal",
            XMLElement("Value",
              DECODE(txn.INSTRTYPE, 'PINLESSDEBITCARD', SUM(DECODE(txn.trxntypeid, 2,txn.amount, 0)),
                                    'BANKACCOUNT', SUM(DECODE(txn.REQTYPE, 'ORAPMTREQ',txn.amount, 0)),
              SUM(DECODE(txn.trxntypeid, 3,txn.amount, 8,txn.amount, 0)) )),
            XMLElement("Currency",
              XMLElement("Code",MAX(txn.currencynamecode))
            )
          ),
          XMLElement("CreditsTotal",
            XMLElement("Value",
            DECODE(txn.INSTRTYPE, 'PINLESSDEBITCARD', 0,
    	                                'BANKACCOUNT', SUM(DECODE(txn.REQTYPE, 'ORAPMTCREDIT',txn.amount, 0)),
              SUM(DECODE(txn.trxntypeid, 5,txn.amount, 11,txn.amount, 0)) )),
            XMLElement("Currency",
              XMLElement("Code",MAX(txn.currencynamecode))
            )
          )
        ),
        XMLAgg(xml_order.fndcpt_order)
      )--,
      --txn.mbatchid,
      --txn.payeeinstrid
    FROM
      iby_trxn_summaries_all txn,
      iby_payee payee,
      iby_bepkeys keys,
      iby_xml_fndcpt_bankaccount_v xml_bank,
      iby_xml_bep_acct_options_v opts,
      iby_xml_fndcpt_order_1_0_v xml_order
     WHERE   (txn.payeeid = payee.payeeid)
      AND (txn.payeeinstrid = xml_bank.instrid(+))
      AND (txn.payeeid = keys.ownerid)
      AND (txn.bepkey = keys.key)
      AND (keys.ownertype = 'PAYEE')
      AND (keys.bep_account_id = opts.bep_account_id(+))
      AND (txn.trxnmid = xml_order.trxnmid)
      AND txn.trxnmid = G_Extract_Run_Payment_id
      AND txn.mbatchid = p_mbatch_id
    GROUP BY
      txn.mbatchid, txn.payeeinstrid, txn.instrtype, txn.bepkey,
      payee.name, payee.mcc_code, opts.bep_account_id,
      xml_bank.instrid;

    CURSOR l_payeeacct_prt_csr (p_mbatch_id IN NUMBER) IS
    SELECT
      XMLElement("PayeeAccount",
        XMLElement("PaymentSystemAccount",
          XMLElement("AccountName",txn.bepkey),
          Extract(XMLAgg(XMLElement("OptionSet",opts.account_options)),
                  'OptionSet[1]/*')
        ),
        CASE WHEN (NOT xml_bank.instrid IS NULL) THEN
         Extract(XMLAgg(XMLElement("BankAccount",xml_bank.bank_account_content)),
                 '/BankAccount[1]')
        END,
        XMLElement("Payee",
          XMLElement("Name",payee.name),
          XMLElement("Address",
            XMLElement("AddressLine1",null),
            XMLForest(null AS "AddressLine2",null AS "AddressLine3"),
            XMLElement("City",null),
            XMLElement("State",null),
            XMLElement("Country",null),
            XMLElement("PostalCode",null)
          ),
          XMLForest(DECODE(payee.mcc_code, -1,null, payee.mcc_code) AS "MCC")
        ),
        XMLElement("OrderCount",count(txn.trxnmid)),
        XMLElement("AccountTotals",
          XMLElement("AuthorizationsTotal",
            XMLElement("Value",
             DECODE(txn.INSTRTYPE, 'PINLESSDEBITCARD', 0,
                                   'BANKACCOUNT', 0,
                                    SUM(DECODE(txn.trxntypeid, 2,txn.amount, 0)) )),
            XMLElement("Currency",
              XMLElement("Code",MAX(txn.currencynamecode))
            )
          ),
          XMLElement("CapturesTotal",
            XMLElement("Value",
              DECODE(txn.INSTRTYPE, 'PINLESSDEBITCARD', SUM(DECODE(txn.trxntypeid, 2,txn.amount, 0)),
                                    'BANKACCOUNT', SUM(DECODE(txn.REQTYPE, 'ORAPMTREQ',txn.amount, 0)),
              SUM(DECODE(txn.trxntypeid, 3,txn.amount, 8,txn.amount, 0)) )),
            XMLElement("Currency",
              XMLElement("Code",MAX(txn.currencynamecode))
            )
          ),
          XMLElement("CreditsTotal",
            XMLElement("Value",
            DECODE(txn.INSTRTYPE, 'PINLESSDEBITCARD', 0,
    	                                'BANKACCOUNT', SUM(DECODE(txn.REQTYPE, 'ORAPMTCREDIT',txn.amount, 0)),
              SUM(DECODE(txn.trxntypeid, 5,txn.amount, 11,txn.amount, 0)) )),
            XMLElement("Currency",
              XMLElement("Code",MAX(txn.currencynamecode))
            )
          )
        ),
        XMLAgg(xml_order.fndcpt_order)
      )--,
      --txn.mbatchid,
      --txn.payeeinstrid
    FROM
      iby_trxn_summaries_all txn,
      iby_payee payee,
      iby_bepkeys keys,
      iby_xml_fndcpt_bankaccount_v xml_bank,
      iby_xml_bep_acct_options_v opts,
      iby_xml_fndcpt_order_1_0_v xml_order
     WHERE   (txn.payeeid = payee.payeeid)
      AND (txn.payeeinstrid = xml_bank.instrid(+))
      AND (txn.payeeid = keys.ownerid)
      AND (txn.bepkey = keys.key)
      AND (keys.ownertype = 'PAYEE')
      AND (keys.bep_account_id = opts.bep_account_id(+))
      AND (txn.trxnmid = xml_order.trxnmid)
      AND Get_SRA_Attribute(txn.trxnmid, G_SRA_DELIVERY_METHOD_ATTR) = G_SRA_DELIVERY_METHOD_PRINTED
      AND txn.mbatchid = p_mbatch_id
    GROUP BY
      txn.mbatchid, txn.payeeinstrid, txn.instrtype, txn.bepkey,
      payee.name, payee.mcc_code, opts.bep_account_id,
      xml_bank.instrid;

  BEGIN

    iby_debug_pub.add(debug_msg => 'Enter: '  || l_Debug_Module,
                      debug_level => FND_LOG.LEVEL_PROCEDURE,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'Extract mode is G_EXTRACT_MODE_SRA. ',
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    IF G_Extract_Run_Delivery_Method = G_SRA_DELIVERY_METHOD_PRINTED THEN

      iby_debug_pub.add(debug_msg => 'Delivery method is printed. ',
                        debug_level => FND_LOG.LEVEL_STATEMENT,
                        module => l_Debug_Module);

       OPEN l_payeeacct_prt_csr (p_mbatch_id);
      FETCH l_payeeacct_prt_csr INTO l_payeeacct_agg;
      CLOSE l_payeeacct_prt_csr;

     iby_debug_pub.add(debug_msg => 'After fetch from payee account cursor. ',
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    ELSIF G_Extract_Run_Delivery_Method = G_SRA_DELIVERY_METHOD_EMAIL OR
          G_Extract_Run_Delivery_Method = G_SRA_DELIVERY_METHOD_FAX   THEN

      iby_debug_pub.add(debug_msg => 'Delivery method is Email/Fax. ',
                        debug_level => FND_LOG.LEVEL_STATEMENT,
                        module => l_Debug_Module);

       OPEN l_payeeacct_ele_csr (p_mbatch_id);
      FETCH l_payeeacct_ele_csr INTO l_payeeacct_agg;
      CLOSE l_payeeacct_ele_csr;

     iby_debug_pub.add(debug_msg => 'After fetch from payee account cursor. ',
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);
    END IF;

    RETURN l_payeeacct_agg;

    iby_debug_pub.add(debug_msg => 'Exit: '  || l_Debug_Module,
                      debug_level => FND_LOG.LEVEL_PROCEDURE,
                      module => l_Debug_Module);

  END Get_Ins_PayeeAcctAgg;


  FUNCTION Get_SRA_Attribute(p_trxnmid IN NUMBER, p_attribute_type IN NUMBER)
  RETURN VARCHAR2
  IS
    l_instrument_type              VARCHAR2(30);
    l_sra_delivery_method          VARCHAR2(30);
    l_pf_sra_format                VARCHAR2(30);
    l_override_payer_flag          VARCHAR2(1);
    l_pf_sra_delivery_method       VARCHAR2(30);
    l_ps_lang                      VARCHAR2(4);
    l_ps_territory                 VARCHAR2(60);
    l_sra_pn_condition             VARCHAR2(30);
    l_sra_pn_document_count        VARCHAR2(10);

    CURSOR l_instrument_type_csr (p_trxnmid IN NUMBER) IS
    SELECT bat.instrument_type
      FROM iby_trxn_summaries_all txn, iby_batches_all bat
     WHERE txn.trxnmid = p_trxnmid
       AND txn.mbatchid = bat.mbatchid;

    CURSOR l_eft_sra_setup_csr (p_trxnmid IN NUMBER) IS
    SELECT sys_pf.OVERRIDE_PAYER_DELIVERY_FLAG, sys_pf.PAYER_NOTIFICATION_DEL_METHOD,
           sys_pf.payer_notification_format, sys_pf.PAYER_NOTIFICATION_CONDITION, sys_pf.PN_COND_NUM_OF_RECEIPTS
      FROM iby_trxn_summaries_all txn, iby_batches_all bat,
           iby_fndcpt_sys_eft_pf_b sys_pf, iby_fndcpt_user_eft_pf_b user_pf
     WHERE txn.trxnmid = p_trxnmid
       AND txn.mbatchid = bat.mbatchid
       AND bat.process_profile_code = user_pf.user_eft_profile_code
       AND user_pf.sys_eft_profile_code = sys_pf.sys_eft_profile_code;

    CURSOR l_cc_sra_setup_csr (p_trxnmid IN NUMBER) IS
    SELECT sys_pf.OVERRIDE_PAYER_DELIVERY_FLAG, sys_pf.PAYER_NOTIFICATION_DEL_METHOD,
           sys_pf.payer_notification_format, sys_pf.PAYER_NOTIFICATION_CONDITION, sys_pf.PN_COND_NUM_OF_RECEIPTS
      FROM iby_trxn_summaries_all txn, iby_batches_all bat,
           iby_fndcpt_sys_cc_pf_b sys_pf, iby_fndcpt_user_cc_pf_b user_pf
     WHERE txn.trxnmid = p_trxnmid
       AND txn.mbatchid = bat.mbatchid
       AND bat.process_profile_code = user_pf.user_cc_profile_code
       AND user_pf.sys_cc_profile_code = sys_pf.sys_cc_profile_code;

    CURSOR l_dc_sra_setup_csr (p_trxnmid IN NUMBER) IS
    SELECT sys_pf.OVERRIDE_PAYER_DELIVERY_FLAG, sys_pf.PAYER_NOTIFICATION_DEL_METHOD,
           sys_pf.payer_notification_format, sys_pf.PAYER_NOTIFICATION_CONDITION, sys_pf.PN_COND_NUM_OF_RECEIPTS
      FROM iby_trxn_summaries_all txn, iby_batches_all bat,
           iby_fndcpt_sys_dc_pf_b sys_pf, iby_fndcpt_user_dc_pf_b user_pf
     WHERE txn.trxnmid = p_trxnmid
       AND txn.mbatchid = bat.mbatchid
       AND bat.process_profile_code = user_pf.user_dc_profile_code
       AND user_pf.sys_dc_profile_code = sys_pf.sys_dc_profile_code;

    CURSOR l_lang_territory_csr (p_trxnmid IN NUMBER) IS
    SELECT loc.language, loc.country
      FROM hz_party_sites ps, hz_locations loc,
           iby_trxn_summaries_all txn, hz_cust_site_uses_all hz_csu,
           hz_cust_acct_sites_all hz_cs
     where txn.trxnmid = p_trxnmid
       and hz_csu.cust_acct_site_id = hz_cs.cust_acct_site_id
       and hz_cs.party_site_id = ps.party_site_id
       AND txn.acct_site_use_id = hz_csu.site_use_id(+)
       AND loc.location_id = ps.location_id;

  BEGIN

    IF p_attribute_type = G_SRA_DELIVERY_METHOD_ATTR OR
       p_attribute_type = G_PF_FORMAT_ATTR OR
       p_attribute_type = G_SRA_PN_CONDITION OR
       p_attribute_type = G_SRA_PN_NUM_DOCUMENTS THEN

       OPEN l_instrument_type_csr (p_trxnmid);
      FETCH l_instrument_type_csr INTO l_instrument_type;
      CLOSE l_instrument_type_csr;

      IF l_instrument_type = 'BANKACCOUNT' THEN

         OPEN l_eft_sra_setup_csr (p_trxnmid);
        FETCH l_eft_sra_setup_csr INTO l_override_payer_flag, l_pf_sra_delivery_method, l_pf_sra_format, l_sra_pn_condition, l_sra_pn_document_count;
        CLOSE l_eft_sra_setup_csr;

      ELSIF l_instrument_type = 'CREDITCARD' THEN

         OPEN l_cc_sra_setup_csr (p_trxnmid);
        FETCH l_cc_sra_setup_csr INTO l_override_payer_flag, l_pf_sra_delivery_method, l_pf_sra_format, l_sra_pn_condition, l_sra_pn_document_count;
        CLOSE l_cc_sra_setup_csr;

      ELSIF l_instrument_type = 'DEBITCARD' THEN

         OPEN l_dc_sra_setup_csr (p_trxnmid);
        FETCH l_dc_sra_setup_csr INTO l_override_payer_flag, l_pf_sra_delivery_method, l_pf_sra_format, l_sra_pn_condition, l_sra_pn_document_count;
        CLOSE l_dc_sra_setup_csr;

      END IF;

      IF p_attribute_type = G_PF_FORMAT_ATTR THEN
        RETURN l_pf_sra_format;
      END IF;

      IF p_attribute_type = G_SRA_PN_CONDITION THEN
        RETURN l_sra_pn_condition;
      END IF;

      IF p_attribute_type = G_SRA_PN_NUM_DOCUMENTS THEN
        RETURN l_sra_pn_document_count;
      END IF;

      IF l_override_payer_flag = 'Y' THEN
        l_sra_delivery_method := l_pf_sra_delivery_method;

      ELSE
         l_sra_delivery_method := Get_Payer_Default_Attribute(p_trxnmid, p_attribute_type);

         IF l_sra_delivery_method is null THEN
           l_sra_delivery_method := l_pf_sra_delivery_method;
         END IF;
      END IF;

      return l_sra_delivery_method;

    ELSIF p_attribute_type = G_SRA_REQ_FLAG_ATTR THEN

      return 'Y';

    ELSIF p_attribute_type = G_SRA_PS_LANG_ATTR OR
          p_attribute_type = G_SRA_PS_TERRITORY_ATTR THEN

       OPEN l_lang_territory_csr (p_trxnmid);
      FETCH l_lang_territory_csr INTO l_ps_lang, l_ps_territory;
      CLOSE l_lang_territory_csr;

      IF p_attribute_type = G_SRA_PS_LANG_ATTR THEN
        return l_ps_lang;
      ELSE
        return l_ps_territory;
      END IF;

    ELSE
      return Get_Payer_Default_Attribute(p_trxnmid, p_attribute_type);
    END IF;

  END Get_SRA_Attribute;


  FUNCTION Get_Payer_Default_Attribute(p_trxnmid IN NUMBER, p_attribute_type IN NUMBER)
  RETURN VARCHAR2
  IS

      l_attribute_val     VARCHAR2(1000);

      CURSOR l_payer_defaulting_cur (p_trxnmid NUMBER) IS
      SELECT payer.debit_advice_delivery_method,
             payer.debit_advice_email,
             payer.debit_advice_fax
        FROM iby_external_payers_all payer,
       	     iby_trxn_summaries_all txn
       WHERE payer.party_id = txn.payer_party_id
         AND (payer.org_id is NULL OR (payer.org_id = txn.org_id AND payer.org_type = txn.org_type))
         AND (payer.cust_account_id is NULL OR payer.cust_account_id = txn.cust_account_id)
         AND (payer.acct_site_use_id is NULL OR payer.acct_site_use_id = txn.acct_site_use_id)
         AND txn.trxnmid = p_trxnmid
    ORDER BY payer.acct_site_use_id, payer.cust_account_id, payer.org_id;

  BEGIN

    FOR l_default_rec in l_payer_defaulting_cur(p_trxnmid) LOOP
      IF (l_attribute_val is NULL) THEN
        IF p_attribute_type = G_SRA_DELIVERY_METHOD_ATTR THEN
          l_attribute_val := l_default_rec.debit_advice_delivery_method;
        ELSIF p_attribute_type = G_SRA_EMAIL_ATTR THEN
          l_attribute_val := l_default_rec.debit_advice_email;
        ELSIF p_attribute_type = G_SRA_FAX_ATTR THEN
          l_attribute_val := l_default_rec.debit_advice_fax;
        END IF;
      END IF;
    END LOOP;

    return l_attribute_val;
  END Get_Payer_Default_Attribute;


  FUNCTION Get_Batch_Format(p_batchid IN VARCHAR2, p_format_type IN VARCHAR2)
  RETURN VARCHAR2
  IS

    CURSOR l_instrument_type_csr (p_batchid IN VARCHAR2) IS
    SELECT bat.instrument_type
      FROM iby_batches_all bat
     WHERE bat.batchid = p_batchid;

    CURSOR l_eft_format_csr (p_batchid IN VARCHAR2) IS
    SELECT sys_pf.PAYER_NOTIFICATION_FORMAT, sys_pf.ACCOMPANY_LETTER_FORMAT
      FROM iby_batches_all bat,
           iby_fndcpt_sys_eft_pf_b sys_pf, iby_fndcpt_user_eft_pf_b user_pf
     WHERE bat.batchid = p_batchid
       AND bat.process_profile_code = user_pf.user_eft_profile_code
       AND user_pf.sys_eft_profile_code = sys_pf.sys_eft_profile_code;

    CURSOR l_cc_format_csr (p_batchid IN VARCHAR2) IS
    SELECT sys_pf.PAYER_NOTIFICATION_FORMAT
      FROM iby_batches_all bat,
           iby_fndcpt_sys_cc_pf_b sys_pf, iby_fndcpt_user_cc_pf_b user_pf
     WHERE bat.batchid = p_batchid
       AND bat.process_profile_code = user_pf.user_cc_profile_code
       AND user_pf.sys_cc_profile_code = sys_pf.sys_cc_profile_code;

    CURSOR l_dc_format_csr (p_batchid IN VARCHAR2) IS
    SELECT sys_pf.PAYER_NOTIFICATION_FORMAT
      FROM iby_batches_all bat,
           iby_fndcpt_sys_dc_pf_b sys_pf, iby_fndcpt_user_dc_pf_b user_pf
     WHERE bat.batchid = p_batchid
       AND bat.process_profile_code = user_pf.user_dc_profile_code
       AND user_pf.sys_dc_profile_code = sys_pf.sys_dc_profile_code;

    l_instr_type VARCHAR2(30);
    l_acp_ltr_format VARCHAR2(30);
    l_payer_notif_format VARCHAR2(30);

  BEGIN

     OPEN l_instrument_type_csr (p_batchid);
    FETCH l_instrument_type_csr INTO l_instr_type;
    CLOSE l_instrument_type_csr;

    IF l_instr_type = 'BANKACCOUNT' THEN

      OPEN l_eft_format_csr (p_batchid);
     FETCH l_eft_format_csr INTO l_payer_notif_format, l_acp_ltr_format;
     CLOSE l_eft_format_csr;

    ELSIF l_instr_type = 'CREDITCARD' THEN

      OPEN l_cc_format_csr (p_batchid);
     FETCH l_cc_format_csr INTO l_payer_notif_format;
     CLOSE l_cc_format_csr;

    ELSIF l_instr_type = 'DEBITCARD' THEN

      OPEN l_dc_format_csr (p_batchid);
     FETCH l_dc_format_csr INTO l_payer_notif_format;
     CLOSE l_dc_format_csr;

    END IF;

    IF p_format_type = 'PAYER_NOTIFICATION' THEN
      RETURN l_payer_notif_format;
    ELSIF p_format_type = 'FUNDS_CAPTURE_ACCOMPANY_LETTER' THEN
      RETURN l_acp_ltr_format;
    END IF;

  END Get_Batch_Format;


  -- obsolete use Update_Pmt_SRA_Attr_Ele()
  PROCEDURE Update_Pmt_SRA_Attr_Prt
  (
  p_mbatchid         IN     VARCHAR2,
  p_fromDate         IN     VARCHAR2,
  p_toDate           IN     VARCHAR2,
  p_fromPSON         IN     VARCHAR2,
  p_toPSON           IN     VARCHAR2,
  p_delivery_method  IN     VARCHAR2,
  p_format_code      IN     VARCHAR2
  )
  IS
    l_Debug_Module   VARCHAR2(255) := G_DEBUG_MODULE || '.Update_Pmt_SRA_Attr_Prt';

    l_where_clause    VARCHAR2(4000);
    l_update_stmt     VARCHAR2(4000) :=
      'UPDATE iby_trxn_summaries_all txn SET ' ||
      '  debit_advice_delivery_method = ''PRINTED'', ' ||
      '  debit_advice_email = null, ' ||
      '  debit_advice_fax = null, ' ||
      '  payer_notification_created = ''Y'', ' ||
      '  object_version_number    = object_version_number + 1, ' ||
      '  last_updated_by          = fnd_global.user_id, ' ||
      '  last_update_date         = SYSDATE, ' ||
      '  last_update_login        = nvl(fnd_global.LOGIN_ID, fnd_global.conc_login_id) ' ||
      'WHERE nvl(txn.payer_notification_required, ''N'') = ''Y'' ';

  BEGIN

    iby_debug_pub.add(debug_msg => 'Enter: '  || l_Debug_Module,
                      debug_level => FND_LOG.LEVEL_PROCEDURE,
                      module => l_Debug_Module);

    l_where_clause := Get_Payer_Notif_Where_cluase
    (
    p_mbatchid         => p_mbatchid,
    p_fromDate         => p_fromDate,
    p_toDate           => p_toDate,
    p_fromPSON         => p_fromPSON,
    p_toPSON           => p_toPSON,
    p_delivery_method  => p_delivery_method,
    p_format_code      => p_format_code,
    p_debug_module     => l_Debug_Module
    );

    l_update_stmt := l_update_stmt || l_where_clause;

    iby_debug_pub.add(debug_msg => 'Before executing dynamic update statement.',
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'l_update_stmt: ' || l_update_stmt,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    EXECUTE IMMEDIATE l_update_stmt;

    iby_debug_pub.add(debug_msg => 'Exit: '  || l_Debug_Module,
                      debug_level => FND_LOG.LEVEL_PROCEDURE,
                      module => l_Debug_Module);

  END Update_Pmt_SRA_Attr_Prt;


  PROCEDURE Update_Pmt_SRA_Attr_Ele
  (
  p_trxnmid                      IN     NUMBER,
  p_delivery_method              IN     VARCHAR2,
  p_recipient_email              IN     VARCHAR2,
  p_recipient_fax                IN     VARCHAR2
  )
  IS
  BEGIN

    IF p_delivery_method = 'EMAIL' THEN
      UPDATE
        iby_trxn_summaries_all
      SET
        debit_advice_delivery_method = p_delivery_method,
        debit_advice_email = p_recipient_email,
        debit_advice_fax = null,
        payer_notification_created = 'Y',
        object_version_number    = object_version_number + 1,
        last_updated_by          = fnd_global.user_id,
        last_update_date         = SYSDATE,
        last_update_login        = nvl(fnd_global.LOGIN_ID, fnd_global.conc_login_id)
      WHERE trxnmid = p_trxnmid;
    ELSIF p_delivery_method = 'FAX' THEN
      UPDATE
        iby_trxn_summaries_all
      SET
        debit_advice_delivery_method = p_delivery_method,
        debit_advice_email = null,
        debit_advice_fax = p_recipient_fax,
        payer_notification_created = 'Y',
        object_version_number    = object_version_number + 1,
        last_updated_by          = fnd_global.user_id,
        last_update_date         = SYSDATE,
        last_update_login        = nvl(fnd_global.LOGIN_ID, fnd_global.conc_login_id)
      WHERE trxnmid = p_trxnmid;
    ELSIF p_delivery_method = 'PRINTED' THEN
      UPDATE
        iby_trxn_summaries_all
      SET
        debit_advice_delivery_method = p_delivery_method,
        debit_advice_email = NULL,
        debit_advice_fax = NULL,
        payer_notification_created = 'Y',
        object_version_number    = object_version_number + 1,
        last_updated_by          = fnd_global.user_id,
        last_update_date         = SYSDATE,
        last_update_login        = nvl(fnd_global.LOGIN_ID, fnd_global.conc_login_id)
      WHERE trxnmid = p_trxnmid;
    END IF;

    COMMIT;

  END Update_Pmt_SRA_Attr_Ele;

  FUNCTION submit_payer_notification
  (
    p_bep_type             IN VARCHAR2,
    p_settlement_batch     IN VARCHAR2 DEFAULT NULL,
    p_from_settlement_date IN DATE DEFAULT NULL,
    p_to_settlement_date   IN DATE DEFAULT NULL,
    p_from_PSON            IN VARCHAR2 DEFAULT NULL,
    p_to_PSON              IN VARCHAR2 DEFAULT NULL
  ) RETURN NUMBER
  IS
    l_request_id            NUMBER;
    l_reqdate               DATE;
    l_Debug_Module          VARCHAR2(255) := G_DEBUG_MODULE || '.submit_payer_notification';
    l_icx_numeric_characters   VARCHAR2(30); -- Bug 6411356
    l_bool_val   boolean;  -- Bug 6411356

  BEGIN

    iby_debug_pub.add(debug_msg => 'Enter: '  || l_Debug_Module, debug_level => FND_LOG.LEVEL_PROCEDURE,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'p_bep_type: '||p_bep_type, debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'p_from_settlement_date: '||p_from_settlement_date, debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'p_to_settlement_date: '||p_to_settlement_date, debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'p_settlement_batch: '||p_settlement_batch, debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'p_from_PSON: '||p_from_PSON, debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'p_to_PSON: '||p_to_PSON, debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    -- The settlement date is required for the concurrent request, so included
    -- logic in API to get the settlement date based on query from concurrent
    -- request.
    IF p_from_settlement_date IS NULL AND p_bep_type = 'PROCESSOR' THEN
      BEGIN
        SELECT MIN(reqdate)
          INTO l_reqdate
          FROM iby_trxn_summaries_all
         WHERE batchid = p_settlement_batch
           AND NVL(payer_notification_required, 'N') = 'Y';
      EXCEPTION
        WHEN others THEN NULL;
      END;

      iby_debug_pub.add(debug_msg => 'Reqdate is not passed and type is PROCESSOR. l_reqdate='||l_reqdate,
        debug_level => FND_LOG.LEVEL_STATEMENT, module => l_Debug_Module);

    END IF;

    iby_debug_pub.add(debug_msg => 'Before Calling FND_REQUEST.SUBMIT_REQUEST()', debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

	 --Bug 6411356
	 --below code added to set the current nls character setting
	 --before submitting a child requests.
	 fnd_profile.get('ICX_NUMERIC_CHARACTERS',l_icx_numeric_characters);
	 l_bool_val:= FND_REQUEST.SET_OPTIONS( numeric_characters => l_icx_numeric_characters);

    -- submit the extract program
    l_request_id := FND_REQUEST.SUBMIT_REQUEST
    (
      'IBY',
      'IBY_FC_PAYER_NOTIF_FORMAT',
      null,  -- description
      null,  -- start_time
      FALSE, -- sub_request
      p_settlement_batch,
      NVL(p_from_settlement_date, l_reqdate),
      p_to_settlement_date,
      p_from_PSON,
      p_to_PSON,
      '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', ''
    );

    -- Added explicit commit in pl/sql.  Request id is logged, but the request is not created in FND
    COMMIT;

    iby_debug_pub.add(debug_msg => 'After Calling FND_REQUEST.SUBMIT_REQUEST()',
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);
    iby_debug_pub.add(debug_msg => 'Request id: ' || l_request_id,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'Exit: ' || l_Debug_Module,
                    debug_level => FND_LOG.LEVEL_PROCEDURE,
                    module => l_Debug_Module);

    RETURN l_request_id;

  END submit_payer_notification;


  FUNCTION submit_accompany_letter
  (
    p_settlement_batch     IN VARCHAR2
  ) RETURN NUMBER
  IS
    l_request_id            NUMBER;
    l_Debug_Module          VARCHAR2(255) := G_DEBUG_MODULE || '.submit_accompany_letter';
    l_icx_numeric_characters   VARCHAR2(30); -- Bug 6411356
    l_bool_val   boolean;  -- Bug 6411356


  BEGIN

    iby_debug_pub.add(debug_msg => 'Enter: '  || l_Debug_Module, debug_level => FND_LOG.LEVEL_PROCEDURE,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'p_settlement_batch: '||p_settlement_batch, debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'Before Calling FND_REQUEST.SUBMIT_REQUEST()', debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);


	 --Bug 6411356
	 --below code added to set the current nls character setting
	 --before submitting a child requests.
	 fnd_profile.get('ICX_NUMERIC_CHARACTERS',l_icx_numeric_characters);
	 l_bool_val:= FND_REQUEST.SET_OPTIONS( numeric_characters => l_icx_numeric_characters);

    -- submit the extract program
    l_request_id := FND_REQUEST.SUBMIT_REQUEST
    (
      'IBY',
      'IBY_FC_ACP_LTR_FORMAT',
      null,  -- description
      null,  -- start_time
      FALSE, -- sub_request
      p_settlement_batch,
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', ''
    );

    -- Added explicit commit in pl/sql.  Request id is logged, but the request is not created in FND
    COMMIT;

    iby_debug_pub.add(debug_msg => 'After Calling FND_REQUEST.SUBMIT_REQUEST()',
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);
    iby_debug_pub.add(debug_msg => 'Request id: ' || l_request_id,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'Exit: ' || l_Debug_Module,
                    debug_level => FND_LOG.LEVEL_PROCEDURE,
                    module => l_Debug_Module);

    RETURN l_request_id;

  END submit_accompany_letter;


/*
   is_amended: Gives whether the mandate has been amended or not.
*/

 FUNCTION is_amended
       ( p_mandate_id IN iby_debit_authorizations.debit_authorization_id%TYPE )
  RETURN varchar2
    IS
      l_count number(6);
    BEGIN

      SELECT  count(*) INTO l_count
        FROM  iby_debit_authorizations
       WHERE  initial_debit_authorization_id = ( SELECT initial_debit_authorization_id
                                                   FROM iby_debit_authorizations
                                                  WHERE debit_authorization_id = p_mandate_id );

      IF (l_count >1)
        THEN RETURN 'TRUE';
      ELSE RETURN 'FALSE';
      END IF;

      RETURN 'FALSE';

    EXCEPTION WHEN OTHERS THEN
       RETURN 'FALSE';

END is_amended;



/*
   get_assignment_iban: Returns the IBN Number for an Bank Account Assignment.
*/


FUNCTION get_assignment_iban
       ( p_assign_id IN iby_debit_authorizations.external_bank_account_use_id%TYPE )
 RETURN varchar2
    IS
       l_iban iby_ext_bank_accounts.iban%TYPE;
  BEGIN

     IF (p_assign_id IS NULL) THEN
        RETURN NULL;
     END IF;

    SELECT  iby_ext_bankacct_pub.Uncipher_Bank_Number (ext_ba.iban, ext_ba.iban_sec_segment_id, iby_utility_pvt.get_view_param('SYS_KEY'),
                 ibk.subkey_cipher_text, ibs.segment_cipher_text, ibs.encoding_scheme, ext_ba.ba_mask_setting, ext_ba.ba_unmask_length)
      INTO  l_iban
      FROM  iby_pmt_instr_uses_all iu
            ,iby_ext_bank_accounts ext_ba
            ,iby_sys_security_subkeys ibk
            ,iby_security_segments ibs
     WHERE  iu.instrument_payment_use_id = p_assign_id
       AND  iu.instrument_type = 'BANKACCOUNT'
       AND  iu.instrument_id = ext_ba.ext_bank_account_id
       AND  (ext_ba.iban_sec_segment_id  = ibs.sec_segment_id(+))
       AND  (ibs.sec_subkey_id  = ibk.sec_subkey_id(+));

    RETURN l_iban;

    EXCEPTION WHEN others THEN
       RETURN Null;

END get_assignment_iban;


/*
   get_mandate_details: Returns the Mandate details for an bank account.
*/


FUNCTION get_mandate_details
       ( p_mandate_id IN iby_debit_authorizations.debit_authorization_id%TYPE )
 RETURN XMLType
    IS
    l_doc_rec  XMLType;

    CURSOR l_mandate
       (c_mandate_id iby_debit_authorizations.debit_authorization_id%TYPE) IS
      SELECT MandateDetails from (
           SELECT debit_id, XMLElement("MandateDetails", XMLConcat( XMLElement("AuthorizationReference", curr_auth_ref)
                  , XMLElement("AuthorizationSignDate", curr_sign_date)
                  , XMLElement("AmendmentIndicator", amend_indicator) ,  XMLElement("OrgnlAuthReference", prev_auth_ref)
                  , XMLElement("OrgnlCreditor", prev_cred_name)  , XMLElement("OrgnlCreditorId", prev_cred_id)
                   , XMLElement("IBAN", iban)  ,  XMLElement("CreditorName", curr_cred_name) ) ) MandateDetails
             FROM (
                SELECT  curr_mandate.debit_authorization_id debit_id
                      , curr_mandate.authorization_reference_number curr_auth_ref, curr_mandate.auth_sign_date curr_sign_date
                     ,is_amended(curr_mandate.debit_authorization_id) amend_indicator
                    , prev_mandate.authorization_reference_number prev_auth_ref , prev_mandate.creditor_le_name prev_cred_name
                    , prev_mandate.creditor_identifier prev_cred_id
                    ,get_assignment_iban(prev_mandate.external_bank_account_use_id) iban
                    ,curr_mandate.creditor_le_name curr_cred_name
                      FROM iby_debit_authorizations curr_mandate , iby_debit_authorizations prev_mandate
                      WHERE curr_mandate.initial_debit_authorization_id = prev_mandate.initial_debit_authorization_id(+)
                      AND curr_mandate.debit_authorization_id <> prev_mandate.debit_authorization_id(+)
                      ORDER BY prev_mandate.authorization_revision_number DESC )
                        WHERE  debit_id = c_mandate_id
                        AND ROWNUM < 2 );

  BEGIN

     IF (p_mandate_id IS NULL) THEN
        RETURN NULL;
     END IF;

     IF (l_mandate%ISOPEN) THEN
          CLOSE l_mandate;
     END IF;

     OPEN l_mandate(p_mandate_id);
     FETCH l_mandate INTO l_doc_rec;
     IF (l_mandate%NOTFOUND) THEN
       l_doc_rec := NULL;
     END IF;
     CLOSE l_mandate;
     RETURN l_doc_rec;

     EXCEPTION WHEN OTHERS THEN
       RETURN NULL;
 END get_mandate_details;


END IBY_FNDCPT_EXTRACT_GEN_PVT;


/
