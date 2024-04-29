--------------------------------------------------------
--  DDL for Package Body FUN_REPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_REPORT_PVT" AS
/* $Header: FUNVRPTB.pls 120.15.12010000.5 2009/06/24 06:52:52 srampure ship $ */

g_pkg_name  CONSTANT VARCHAR2(30) := 'FUN_REPORT_PVT';




-------------------------------------------------------------------------------
--Start of Comments
--Function:
--  Build the outbound transaction query string for intercompany transaction
--  summary report based on report parameters
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE build_summary_outquery(
    x_return_status    OUT NOCOPY VARCHAR2,
    p_para_rec         IN FUN_REPORT_PVT.summaryreport_para_rec_type,
    x_outbound_query   OUT NOCOPY VARCHAR2
) IS
l_api_name VARCHAR2(30);
l_progress VARCHAR2(3);

l_person_id HZ_PARTIES.party_id%TYPE;
l_grantee_key FND_GRANTS.grantee_key%TYPE;
BEGIN
    l_api_name := 'build_summary_outquery';
    l_progress := '000';

    FUN_UTIL.log_conc_start(g_pkg_name, l_api_name);


    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Get parameters for security settings
    l_progress := '010';
    BEGIN
        SELECT distinct(HZP.party_id)
          INTO l_person_id
          FROM HZ_PARTIES HZP,
               FND_USER U,
               PER_ALL_PEOPLE_F PAP,
               (SELECT FND_GLOBAL.user_id() AS user_id FROM DUAL) CURR
         WHERE CURR.user_id = U.user_id
           AND U.employee_id = PAP.person_id
           AND PAP.party_id = HZP.party_id;
    EXCEPTION
        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            FUN_UTIL.log_conc_unexp(g_pkg_name, l_api_name, l_progress);
            RAISE;
    END;
    FUN_UTIL.log_conc_stmt(
        g_pkg_name, l_api_name, l_progress, 'l_person_id', l_person_id);

    l_grantee_key := 'HZ_PARTY:' || TO_CHAR(l_person_id);
    FUN_UTIL.log_conc_stmt(
        g_pkg_name, l_api_name, l_progress, 'l_grantee_key', l_grantee_key);


    -- Build query string for outbound transactions
    l_progress := '020';
    x_outbound_query := '
        SELECT FTB.batch_number batch_number,
               INIT_P.party_name initiator,
               XLE.name init_le,
               GL.name from_ledger_name,
               FCV.name entered_currency,
               FTB.exchange_rate_type exchange_rate_type,
               LKUP.meaning batch_status,
               FTB.description batch_description,
               FTB.note batch_note,
               FTTVL.trx_type_name transaction_type,
               FTB.gl_date gl_date,
               FTB.batch_date batch_date,
               FTB.reject_allow_flag reject_allow_flag,
               FTB_ORIG.batch_number original_batch_number,
               FTB_REV.batch_number reversed_batch_number,
               FTB.initiator_source initiator_source,
               FTB.attribute1,
               FTB.attribute2,
               FTB.attribute3,
               FTB.attribute4,
               FTB.attribute5,
               FTB.attribute6,
               FTB.attribute7,
               FTB.attribute8,
               FTB.attribute9,
               FTB.attribute10,
               FTB.attribute11,
               FTB.attribute12,
               FTB.attribute13,
               FTB.attribute14,
               FTB.attribute15,
               FTB.attribute_category,
               FTH.trx_number,
               RECI_P.party_name recipient,
               XLE1.name recipient_le,
               GL1.name to_ledger_name,
               LKUP1.meaning trx_status,
               FTH.init_amount_cr initiator_credit,
               FTH.init_amount_dr initiator_debit,
               FTH.reci_amount_cr recipient_credit,
               FTH.reci_amount_dr recipient_debit,
               FTH.ar_invoice_number ar_invoice_number,
               FTH.invoice_flag invoice_flag,
               FTH.approval_date,
               FTH_ORIG.trx_number orig_trx_number,
               FTH_REV.trx_number reversed_trx_number,
               FTH.initiator_instance_flag,
               FTH.recipient_instance_flag,
               FTH.reject_reason reject_reason,
               FTH.description header_description,
               FTH.attribute1,
               FTH.attribute2,
               FTH.attribute3,
               FTH.attribute4,
               FTH.attribute5,
               FTH.attribute6,
               FTH.attribute7,
               FTH.attribute8,
               FTH.attribute9,
               FTH.attribute10,
               FTH.attribute11,
               FTH.attribute12,
               FTH.attribute13,
               FTH.attribute14,
               FTH.attribute15,
               FTH.attribute_category
          FROM FUN_TRX_BATCHES FTB,
               FUN_TRX_HEADERS FTH,
               XLE_ENTITY_PROFILES  XLE,
               FND_LOOKUP_VALUES LKUP,
               HZ_PARTIES INIT_P,
               FUN_TRX_TYPES_VL FTTVL,
               FND_CURRENCIES_VL FCV,
               GL_LEDGERS GL,
               FUN_TRX_BATCHES FTB_ORIG,
               FUN_TRX_BATCHES FTB_REV,
               GL_LEDGERS GL1,
               FUN_TRX_HEADERS FTH_ORIG,
               FUN_TRX_HEADERS FTH_REV,
               HZ_PARTIES RECI_P,
               XLE_ENTITY_PROFILES  XLE1,
               FND_LOOKUP_VALUES LKUP1,
               FND_GRANTS FG,
       	       FND_OBJECT_INSTANCE_SETS FOIS,
               HZ_RELATIONSHIPS HZR,
               HZ_ORG_CONTACTS HZC,
               HZ_ORG_CONTACT_ROLES HZCR
         WHERE FTH.batch_id(+) = FTB.batch_id
           AND XLE.legal_entity_id = FTB.from_le_id
           AND LKUP.lookup_type = ''FUN_BATCH_STATUS''
           AND LKUP.lookup_code = FTB.status
	   AND LKUP.VIEW_APPLICATION_ID = 435
	   AND LKUP.language=USERENV(''LANG'')
	   AND LKUP.security_group_id=fnd_global.lookup_security_group(LKUP.lookup_type,435)
           AND FTB.status IN (''NEW'', ''SENT'', ''ERROR'', ''COMPLETE'')
           AND INIT_P.party_id = FTB.initiator_id
           AND FTTVL.trx_type_id = FTB.trx_type_id
           AND RECI_P.party_id(+) = FTH.recipient_id
           AND XLE1.legal_entity_id(+) = FTH.to_le_id
           AND FCV.currency_code = FTB.currency_code
           AND LKUP1.lookup_type(+) = ''FUN_TRX_STATUS''
           AND LKUP1.lookup_code(+) = FTH.status
           AND LKUP1.view_application_id = 435
           AND LKUP1.security_group_id=fnd_global.lookup_security_group(LKUP1.lookup_type,435)
           AND LKUP1.language = USERENV(''LANG'')
           AND GL.ledger_id = FTB.from_ledger_id
           AND FTB_ORIG.batch_id(+) = FTB.original_batch_id
           AND FTB_REV.batch_id(+) = FTB.reversed_batch_id
           AND GL1.ledger_id(+) = FTH.to_ledger_id
           AND FTH_ORIG.trx_id(+) = FTH.original_trx_id
           AND FTH_REV.trx_id(+) = FTH.reversed_trx_id
           AND FG.grantee_key = ''' || l_grantee_key
        || '''
           AND FG.parameter1 = TO_CHAR(FTB.initiator_id)
           AND FG.instance_set_id = FOIS.instance_set_id
           AND FOIS.instance_set_name = ''FUN_TRX_BATCHES_SET''
           AND HZR.RELATIONSHIP_CODE = ''CONTACT_OF''
           AND HZR.RELATIONSHIP_TYPE = ''CONTACT''
           AND HZC.PARTY_RELATIONSHIP_ID = HZR.RELATIONSHIP_ID
           AND HZCR.ORG_CONTACT_ID = HZC.ORG_CONTACT_ID
           AND HZCR.ROLE_TYPE = ''INTERCOMPANY_CONTACT_FOR''
           AND HZR.DIRECTIONAL_FLAG = ''F''
           AND HZR.SUBJECT_TABLE_NAME = ''HZ_PARTIES''
           AND HZR.OBJECT_TABLE_NAME = ''HZ_PARTIES''
           AND HZR.SUBJECT_TYPE = ''PERSON''
           AND HZR.OBJECT_ID = INIT_P.PARTY_ID
           AND HZR.STATUS = ''A''
           AND HZR.SUBJECT_ID= ' || l_person_id;


    -- Based on the passed in parameters, build additional query conditions
    l_progress := '030';
    IF (p_para_rec.initiator_id IS NOT NULL) THEN
        x_outbound_query :=  x_outbound_query ||
            ' AND FTB.initiator_id = ' || p_para_rec.initiator_id;
    END IF;

    IF (p_para_rec.recipient_id IS NOT NULL) THEN
        x_outbound_query :=  x_outbound_query ||
            ' AND FTH.recipient_id = ' || p_para_rec.recipient_id;
    END IF;

    IF (p_para_rec.batch_number_from IS NOT NULL) AND
        (p_para_rec.batch_number_to IS NOT NULL) THEN
        x_outbound_query :=  x_outbound_query ||
            ' AND FTB.batch_number BETWEEN ''' || p_para_rec.batch_number_from
            || ''' AND ''' || p_para_rec.batch_number_to || '''';
    END IF;

    IF (p_para_rec.gl_date_from IS NOT NULL) AND
        (p_para_rec.gl_date_to IS NOT NULL) THEN
        x_outbound_query :=  x_outbound_query ||
            ' AND FTB.gl_date BETWEEN TO_DATE(''' || p_para_rec.gl_date_from
            || ''', ''YYYY/MM/DD HH24:MI:SS'') AND '
            || ' TO_DATE(''' || p_para_rec.gl_date_to
            || ''', ''YYYY/MM/DD HH24:MI:SS'')';
    END IF;

    IF (p_para_rec.batch_date_from IS NOT NULL) AND
        (p_para_rec.batch_date_to IS NOT NULL) THEN
        x_outbound_query :=  x_outbound_query ||
            ' AND FTB.gl_date BETWEEN TO_DATE(''' || p_para_rec.batch_date_from
            || ''', ''YYYY/MM/DD HH24:MI:SS'') AND '
            || ' TO_DATE(''' || p_para_rec.batch_date_to
            || ''', ''YYYY/MM/DD HH24:MI:SS'')';
    END IF;

    IF (p_para_rec.batch_status IS NOT NULL) THEN
        x_outbound_query :=  x_outbound_query ||
            ' AND FTB.status = ''' || p_para_rec.batch_status || '''';
    END IF;

    IF (p_para_rec.transaction_status IS NOT NULL) THEN
        x_outbound_query :=  x_outbound_query ||
            ' AND FTH.status = ''' || p_para_rec.transaction_status || '''';
    END IF;

    IF (p_para_rec.trx_type_id IS NOT NULL) THEN
        x_outbound_query :=  x_outbound_query ||
            ' AND FTB.trx_type_id = ' || p_para_rec.trx_type_id;
    END IF;

    IF (p_para_rec.currency_code IS NOT NULL) THEN
        x_outbound_query :=  x_outbound_query ||
            ' AND FTB.currency_code = ''' || p_para_rec.currency_code || '''';
    END IF;

    IF (p_para_rec.invoice_flag IS NOT NULL) THEN
        x_outbound_query :=  x_outbound_query ||
            ' AND FTH.invoice_flag = ''' || p_para_rec.invoice_flag || '''';
    END IF;

    IF (p_para_rec.ar_invoice_number IS NOT NULL) THEN
        x_outbound_query :=  x_outbound_query ||
            ' AND FTH.ar_invoice_number = ''' || p_para_rec.ar_invoice_number
            || '''';
    END IF;

    FUN_UTIL.log_conc_stmt(
        g_pkg_name, l_api_name, l_progress, 'x_outbound_query', x_outbound_query);
    FUN_UTIL.log_conc_end(g_pkg_name, l_api_name);

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FUN_UTIL.log_conc_unexp(
            g_pkg_name, l_api_name, l_progress);
        RAISE;
END build_summary_outquery;

-------------------------------------------------------------------------------
--Start of Comments
--Function:
--  Build the outbound transaction query string for intercompany account
--  details report based on report parameters
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE build_account_outquery(
    x_return_status    OUT NOCOPY VARCHAR2,
    p_para_rec         IN FUN_REPORT_PVT.accountreport_para_rec_type,
    x_outbound_query   OUT NOCOPY VARCHAR2
) IS
l_api_name VARCHAR2(30);
l_progress VARCHAR2(3);

l_acc_segment fnd_id_flex_segments.application_column_name%TYPE;


l_person_id HZ_PARTIES.party_id%TYPE;
l_grantee_key FND_GRANTS.grantee_key%TYPE;
BEGIN
    l_api_name := 'build_account_outquery';
    l_progress := '000';

    FUN_UTIL.log_conc_start(g_pkg_name, l_api_name);


    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Get parameters for security settings
    l_progress := '010';
    BEGIN
        SELECT distinct(HZP.party_id)
          INTO l_person_id
          FROM HZ_PARTIES HZP,
               FND_USER U,
               PER_ALL_PEOPLE_F PAP,
               (SELECT FND_GLOBAL.user_id() AS user_id FROM DUAL) CURR
         WHERE CURR.user_id = U.user_id
           AND U.employee_id = PAP.person_id
           AND PAP.party_id = HZP.party_id;

        IF (p_para_rec.coa_initiator IS NOT NULL) THEN

              SELECT application_column_name
                INTO l_acc_segment
                FROM fnd_segment_attribute_values
               WHERE application_id = 101
                     AND id_flex_code = 'GL#'
                     AND id_flex_num  = p_para_rec.coa_initiator
                     AND segment_attribute_type = 'GL_ACCOUNT'
                     AND attribute_value = 'Y';
        end if;


    EXCEPTION
        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            FUN_UTIL.log_conc_unexp(g_pkg_name, l_api_name, l_progress);
            RAISE;
    END;
    FUN_UTIL.log_conc_stmt(
        g_pkg_name, l_api_name, l_progress, 'l_person_id', l_person_id);

    l_grantee_key := 'HZ_PARTY:' || TO_CHAR(l_person_id);
    FUN_UTIL.log_conc_stmt(
        g_pkg_name, l_api_name, l_progress, 'l_grantee_key', l_grantee_key);


    -- Build query string for outbound transactions
    l_progress := '020';
    x_outbound_query :='
    SELECT fun_trx_entry_util.get_concatenated_account(fdl.ccid) account,
	   ''OUTBOUND''                                       batch_type,
           lkup.meaning                                     account_type,
	   FTB.batch_number                                 batch_number,
	   FTH.trx_number                                   trx_number,
	   lkup1.meaning                                    batch_status,
	   FTB.batch_date                                     batch_date,
	   INIT_P.party_name                                   initiator,
	   RECI_P.party_name                                   recipient,
	   lkup2.meaning                                      trx_status,
	   FTTVL.trx_type_name                          transaction_type,
	   FTB.gl_date                                           gl_date,
	   GLP.period_name                                     gl_period,
	   FCV.name                                     entered_currency,
	   FDL.amount_cr                                  entered_credit,
	   fdl.amount_dr                                   entered_debit,
	   fdl.description                                   description,
	   FTH.invoice_flag                                 invoice_flag,
	   NVL2(FTH.original_trx_id,NVL2(FTH.reversed_trx_id,0,FTH_REV.trx_number),FTH_ORIG.trx_number)   reverse_reference,
           DECODE(NVL(FTH.original_trx_id,0),0,''N'',''Y'')   reverse_trx_flag,
           DECODE(NVL(FTH.reversed_trx_id,0),0,''N'',''Y'')   reversed_flag,
 	   FTH.ar_invoice_number                       ar_invoice_number,
	   FTH_ORIG.trx_number                           orig_trx_number,
	   FTH_REV.trx_number                             rev_trx_number,
	   FTB_ORIG.batch_number                       orig_batch_number,
	   FTB_REV.batch_number                         rev_batch_number,
	   FTB.reject_allow_flag                       reject_allow_flag,
	   FTB.initiator_source                         initiator_source,
	   FTB.description                              batch_description,
	   FTB.attribute1,
           FTB.attribute2,
           FTB.attribute3,
           FTB.attribute4,
           FTB.attribute5,
           FTB.attribute6,
           FTB.attribute7,
           FTB.attribute8,
           FTB.attribute9,
           FTB.attribute10,
           FTB.attribute11,
           FTB.attribute12,
           FTB.attribute13,
           FTB.attribute14,
           FTB.attribute15,
           FTB.attribute_category,
	   fdl.dist_number                           distribution_number,
	   fdl.party_type_flag                           party_type_flag,
	   fdl.dist_type_flag                             dist_type_flag,
	   fdl.auto_generate_flag                     auto_generate_flag,
	   fdl.attribute1,
	   fdl.attribute2,
	   fdl.attribute3,
	   fdl.attribute4,
	   fdl.attribute5,
	   fdl.attribute6,
	   fdl.attribute7,
           fdl.attribute8,
           fdl.attribute9,
	   fdl.attribute10,
	   fdl.attribute11,
	   fdl.attribute12,
	   fdl.attribute13,
	   fdl.attribute14,
	   fdl.attribute15,
	   fdl.attribute_category,
	   XLE.name                                    init_le,
	   XLE1.name                                   recipient_le,
	   GL0.name                                     from_ledger_name,
	   GL1.name                                    to_ledger_name,
	   FTH.init_amount_cr                          initiator_credit,
           FTH.init_amount_dr                          initiator_debit,
           FTH.reci_amount_cr                          recipient_credit,
           FTH.reci_amount_dr                          recipient_debit,
	   FTH.approval_date                           approval_date,
	   FTH.initiator_instance_flag                 initiator_instance_flag,
           FTH.recipient_instance_flag                 recipient_instance_flag,
           FTH.reject_reason                           reject_reason,
           FTH.description                             header_description,
	   FTH.attribute1,
           FTH.attribute2,
           FTH.attribute3,
           FTH.attribute4,
           FTH.attribute5,
           FTH.attribute6,
           FTH.attribute7,
           FTH.attribute8,
           FTH.attribute9,
           FTH.attribute10,
           FTH.attribute11,
           FTH.attribute12,
           FTH.attribute13,
           FTH.attribute14,
           FTH.attribute15,
           FTH.attribute_category
FROM   fun_dist_lines          fdl,
       gl_code_combinations    glcc,
	   fnd_lookups             lkup,
	   fnd_lookup_values             lkup1,
	   fnd_lookup_values             lkup2,
	   FUN_TRX_BATCHES         FTB,
	   FUN_TRX_BATCHES         FTB_REV,
	   FUN_TRX_BATCHES         FTB_ORIG,
	   HZ_PARTIES              INIT_P,
	   HZ_PARTIES              RECI_P,
	   FUN_TRX_HEADERS         FTH,
	   FUN_TRX_HEADERS         FTH_REV,
	   FUN_TRX_HEADERS         FTH_ORIG,
	   FUN_TRX_TYPES_VL        FTTVL,
	   GL_PERIODS              GLP,
	   FND_CURRENCIES_VL       FCV,
	   FUN_TRX_LINES           FTL,
	   GL_LEDGERS              GL0,
	   GL_LEDGERS              GL1,
	   XLE_ENTITY_PROFILES  XLE,
	   XLE_ENTITY_PROFILES  XLE1,
	   FND_GRANTS FG,
           FND_OBJECT_INSTANCE_SETS FOIS,
           HZ_RELATIONSHIPS HZR,
	   HZ_ORG_CONTACTS HZC,
	   HZ_ORG_CONTACT_ROLES HZCR
WHERE  fdl.ccid             = glcc.code_combination_id
AND    glcc.account_type    = lkup.lookup_code
AND    lkup.lookup_type     =''ACCOUNT_TYPE''
AND    lkup.lookup_code    IN (''A'',''E'',''L'',''R'', ''O'')
AND    lkup1.lookup_type    =''FUN_BATCH_STATUS''
AND    lkup1.view_application_id = 435
AND    lkup1.security_group_id = fnd_global.lookup_security_group(lkup1.lookup_type,435)
AND    lkup1.language = USERENV(''LANG'')
AND    lkup1.lookup_code     = FTB.status
AND    lkup1.lookup_code   IN (''NEW'',''SENT'',''ERROR'',''COMPLETE'')
AND    INIT_P.party_id      = FTB.initiator_id
AND    RECI_P.party_id(+)   = FTH.recipient_id
AND    lkup2.lookup_code    = FTH.status
AND    lkup2.view_application_id = 435
AND    lkup2.security_group_id = fnd_global.lookup_security_group(lkup2.lookup_type,435)
AND    lkup2.language = USERENV(''LANG'')
AND    LKUP2.lookup_type  = ''FUN_TRX_STATUS''
AND    FTH.batch_id(+)        = FTB.batch_id
AND    FTTVL.trx_type_id    = FTB.trx_type_id
AND    FTB.gl_date    BETWEEN GLP.start_date AND GLP.end_date
AND    FCV.currency_code    = FTB.currency_code
AND    FTL.trx_id           = FTH.trx_id
AND    FDL.line_id          = FTL.line_id
AND    FDL.party_type_flag  = ''I''
AND    FTH.original_trx_id=FTH_ORIG.trx_id(+)
AND    FTB.original_batch_id=FTB_ORIG.batch_id(+)
AND    FTH.reversed_trx_id=FTH_REV.trx_id(+)
AND    FTB.reversed_batch_id=FTB_REV.batch_id(+)
AND    XLE.legal_entity_id   = FTB.from_le_id
AND    XLE1.legal_entity_id(+) = FTH.to_le_id
AND    GL0.ledger_id  = FTB.from_ledger_id
AND    GL1.ledger_id(+) = FTH.to_ledger_id
AND    GLP.period_set_name =GL0.period_set_name
AND    GLP.period_type = GL0.accounted_period_type
AND    fdl.dist_type_flag IN (''R'',''L'')
AND    FG.grantee_key = ''' || l_grantee_key
|| '''
AND FG.parameter1 = TO_CHAR(FTB.initiator_id)
AND FG.instance_set_id = FOIS.instance_set_id
AND NVL(FG.end_date, SYSDATE+1) > SYSDATE
AND FOIS.instance_set_name = ''FUN_TRX_BATCHES_SET''
AND HZR.RELATIONSHIP_CODE = ''CONTACT_OF''
AND HZR.RELATIONSHIP_TYPE = ''CONTACT''
AND HZC.PARTY_RELATIONSHIP_ID = HZR.RELATIONSHIP_ID
AND HZCR.ORG_CONTACT_ID = HZC.ORG_CONTACT_ID
AND HZCR.ROLE_TYPE = ''INTERCOMPANY_CONTACT_FOR''
AND HZR.DIRECTIONAL_FLAG = ''F''
AND HZR.SUBJECT_TABLE_NAME = ''HZ_PARTIES''
AND HZR.OBJECT_TABLE_NAME = ''HZ_PARTIES''
AND HZR.SUBJECT_TYPE = ''PERSON''
AND HZR.direction_code=''P''
AND HZR.OBJECT_ID = INIT_P.PARTY_ID
AND HZR.STATUS = ''A''
AND HZR.SUBJECT_ID='|| l_person_id;





    -- Based on the passed in parameters, build additional query conditions
    l_progress := '030';


  IF ((p_para_rec.rec_account_from IS NOT NULL) AND (p_para_rec.rec_account_to
        IS NOT NULL) AND (p_para_rec.init_dist_acc_from IS NOT NULL) AND
        (p_para_rec.init_dist_acc_to IS NOT NULL)) THEN

         x_outbound_query:=x_outbound_query ||' AND GLCC.'||l_acc_segment||
 ' BETWEEN decode(fdl.dist_type_flag,''R'','||p_para_rec.rec_account_from||',''L'','||
                  p_para_rec.init_dist_acc_from||') '||
   ' AND decode(fdl.dist_type_flag,''R'','||p_para_rec.rec_account_to||',''L'','||
                 p_para_rec.init_dist_acc_to||') ';

   ELSIF ((p_para_rec.rec_account_from IS NOT NULL) AND
           (p_para_rec.rec_account_to  IS NOT NULL)) THEN

         x_outbound_query:=x_outbound_query ||' AND GLCC.'||l_acc_segment||
 ' BETWEEN decode(fdl.dist_type_flag,''R'','||p_para_rec.rec_account_from||',GLCC.'||l_acc_segment||') '||
 ' AND decode(fdl.dist_type_flag,''R'','||p_para_rec.rec_account_to||',GLCC.'||l_acc_segment||') ';


  ELSIF  ((p_para_rec.init_dist_acc_from IS NOT NULL) AND
           (p_para_rec.init_dist_acc_to  IS NOT NULL)) THEN

       x_outbound_query:=x_outbound_query ||' AND GLCC.'||l_acc_segment||
 ' BETWEEN decode(fdl.dist_type_flag,''L'','||p_para_rec.init_dist_acc_from||',GLCC.'||l_acc_segment||') '||
' AND decode(fdl.dist_type_flag,''L'','||p_para_rec.init_dist_acc_to||',GLCC.'||l_acc_segment||') ';


   END IF;



      -- Based on the passed in parameters, build additional query conditions
        l_progress := '030';


        IF ((p_para_rec.initiator_from IS NOT NULL) AND (p_para_rec.initiator_to
IS
    NOT NULL)) THEN
            x_outbound_query :=  x_outbound_query ||
               ' AND INIT_P.PARTY_NAME BETWEEN ''' || p_para_rec.initiator_from
||''' AND'''||
                p_para_rec.initiator_to||'''';
        END IF;



   IF ((p_para_rec.recipient_from IS NOT NULL) AND (p_para_rec.recipient_to IS
        NOT NULL)) THEN
            x_outbound_query :=  x_outbound_query ||
               ' AND RECI_P.PARTY_NAME BETWEEN ''' || p_para_rec.recipient_from
||''' AND'''||
                p_para_rec.recipient_to||'''';
        END IF;
        IF (p_para_rec.transact_le IS NOT NULL) THEN
             x_outbound_query:= x_outbound_query||
               ' AND XLE.NAME = '''|| p_para_rec.transact_le||'''';
        END IF;

        IF (p_para_rec.trading_le IS NOT NULL) THEN
             x_outbound_query:= x_outbound_query ||
                ' AND XLE1.NAME ='''||p_para_rec.trading_le||'''';
        END IF;
        IF (p_para_rec.transact_ledger IS NOT NULL) THEN
             x_outbound_query:=x_outbound_query ||
               ' AND GL0.ledger_id ='||p_para_rec.transact_ledger;
        end if;

        IF (p_para_rec.trading_ledger IS NOT NULL) THEN
             x_outbound_query:= x_outbound_query ||
              '  AND GL1.ledger_id(+)='||p_para_rec.trading_ledger;
        END IF;


    IF (p_para_rec.batch_number_from IS NOT NULL) AND
        (p_para_rec.batch_number_to IS NOT NULL) THEN
        x_outbound_query :=  x_outbound_query ||
            ' AND FTB.batch_number BETWEEN ''' || p_para_rec.batch_number_from
            || ''' AND ''' || p_para_rec.batch_number_to || '''';
    END IF;

    IF (p_para_rec.gl_date_from IS NOT NULL) AND
        (p_para_rec.gl_date_to IS NOT NULL) THEN
        x_outbound_query :=  x_outbound_query ||
            ' AND FTB.gl_date BETWEEN TO_DATE(''' || p_para_rec.gl_date_from
            || ''', ''YYYY/MM/DD HH24:MI:SS'') AND '
            || ' TO_DATE(''' || p_para_rec.gl_date_to
            || ''', ''YYYY/MM/DD HH24:MI:SS'')';
    END IF;
    IF (p_para_rec.batch_status IS NOT NULL) THEN
        x_outbound_query :=  x_outbound_query ||
            ' AND FTB.status = ''' || p_para_rec.batch_status || '''';
    END IF;

    IF (p_para_rec.transaction_status IS NOT NULL) THEN
        x_outbound_query :=  x_outbound_query ||
            ' AND FTH.status = ''' || p_para_rec.transaction_status || '''';
    END IF;

    IF (p_para_rec.trx_type_id IS NOT NULL) THEN
        x_outbound_query :=  x_outbound_query ||
            ' AND FTB.trx_type_id = ' || p_para_rec.trx_type_id;
    END IF;

    IF (p_para_rec.currency_code IS NOT NULL) THEN
        x_outbound_query :=  x_outbound_query ||
            ' AND FTB.currency_code = ''' || p_para_rec.currency_code || '''';
    END IF;
    IF (p_para_rec.account_type IS NOT NULL) THEN
	x_outbound_query:= x_outbound_query ||
		' AND lkup.lookup_code ='''||p_para_rec.account_type||'''';

    END IF;



    IF (p_para_rec.ar_invoice_number IS NOT NULL) THEN
        x_outbound_query :=  x_outbound_query ||
            ' AND FTH.ar_invoice_number = ''' || p_para_rec.ar_invoice_number
            || '''';
    END IF;

    FUN_UTIL.log_conc_stmt(
        g_pkg_name, l_api_name, l_progress, 'x_outbound_query', x_outbound_query);
    FUN_UTIL.log_conc_end(g_pkg_name, l_api_name);

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FUN_UTIL.log_conc_unexp(
            g_pkg_name, l_api_name, l_progress);
        RAISE;
END build_account_outquery;






-------------------------------------------------------------------------------
--Start of Comments
--Function:
--  Build the inbound transaction query string for intercompany transaction
--  summary report based on report parameters
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE build_summary_inquery(
    x_return_status    OUT NOCOPY VARCHAR2,
    p_para_rec         IN FUN_REPORT_PVT.summaryreport_para_rec_type,
    x_inbound_query    OUT NOCOPY VARCHAR2
) IS
l_api_name VARCHAR2(30);
l_progress VARCHAR2(3);

l_person_id HZ_PARTIES.party_id%TYPE;
l_grantee_key FND_GRANTS.grantee_key%TYPE;
BEGIN
    l_api_name := 'build_summary_inquery';
    l_progress := '000';

    FUN_UTIL.log_conc_start(g_pkg_name, l_api_name);


    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Get parameters for security settings
    l_progress := '010';
    BEGIN
        SELECT distinct(HZP.party_id)
          INTO l_person_id
          FROM HZ_PARTIES HZP,
               FND_USER U,
               PER_ALL_PEOPLE_F PAP,
               (SELECT FND_GLOBAL.user_id() AS user_id FROM DUAL) CURR
         WHERE CURR.user_id = U.user_id
           AND U.employee_id = PAP.person_id
           AND PAP.party_id = HZP.party_id;
    EXCEPTION
        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            FUN_UTIL.log_conc_unexp(g_pkg_name, l_api_name, l_progress);
            RAISE;
    END;
    FUN_UTIL.log_conc_stmt(
        g_pkg_name, l_api_name, l_progress, 'l_person_id', l_person_id);

    l_grantee_key := 'HZ_PARTY:' || TO_CHAR(l_person_id);
    FUN_UTIL.log_conc_stmt(
        g_pkg_name, l_api_name, l_progress, 'l_grantee_key', l_grantee_key);


    -- Build query string for inbound transactions
    l_progress := '020';
    x_inbound_query := '
        SELECT FTB.batch_number batch_number,
               INIT_P.party_name initiator,
               XLE.name init_le,
               GL.name from_ledger_name,
               FCV.name entered_currency,
               FTB.exchange_rate_type exchange_rate_type,
               LKUP.meaning batch_status,
               FTB.description batch_description,
               FTB.note batch_note,
               FTTVL.trx_type_name transaction_type,
               FTB.gl_date gl_date,
               FTB.batch_date batch_date,
               FTB.reject_allow_flag reject_allow_flag,
               FTB_ORIG.batch_number original_batch_number,
               FTB_REV.batch_number reversed_batch_number,
               FTB.initiator_source initiator_source,
               FTB.attribute1,
               FTB.attribute2,
               FTB.attribute3,
               FTB.attribute4,
               FTB.attribute5,
               FTB.attribute6,
               FTB.attribute7,
               FTB.attribute8,
               FTB.attribute9,
               FTB.attribute10,
               FTB.attribute11,
               FTB.attribute12,
               FTB.attribute13,
               FTB.attribute14,
               FTB.attribute15,
               FTB.attribute_category,
               FTH.trx_number,
               RECI_P.party_name recipient,
               XLE1.name recipient_le,
               GL1.name to_ledger_name,
               LKUP1.meaning trx_status,
               FTH.init_amount_cr initiator_credit,
               FTH.init_amount_dr initiator_debit,
               FTH.reci_amount_cr recipient_credit,
               FTH.reci_amount_dr recipient_debit,
               FTH.ar_invoice_number ar_invoice_number,
               FTH.invoice_flag invoice_flag,
               FTH.approval_date,
               FTH_ORIG.trx_number orig_trx_number,
               FTH_REV.trx_number reversed_trx_number,
               FTH.initiator_instance_flag,
               FTH.recipient_instance_flag,
               FTH.reject_reason reject_reason,
               FTH.description header_description,
               FTH.attribute1,
               FTH.attribute2,
               FTH.attribute3,
               FTH.attribute4,
               FTH.attribute5,
               FTH.attribute6,
               FTH.attribute7,
               FTH.attribute8,
               FTH.attribute9,
               FTH.attribute10,
               FTH.attribute11,
               FTH.attribute12,
               FTH.attribute13,
               FTH.attribute14,
               FTH.attribute15,
               FTH.attribute_category
          FROM FUN_TRX_BATCHES FTB,
               FUN_TRX_HEADERS FTH,
               XLE_ENTITY_PROFILES  XLE,
               FND_LOOKUP_VALUES LKUP,
               HZ_PARTIES INIT_P,
               FUN_TRX_TYPES_VL FTTVL,
               FND_CURRENCIES_VL FCV,
               GL_LEDGERS GL,
               FUN_TRX_BATCHES FTB_ORIG,
               FUN_TRX_BATCHES FTB_REV,
               GL_LEDGERS GL1,
               FUN_TRX_HEADERS FTH_ORIG,
               FUN_TRX_HEADERS FTH_REV,
               HZ_PARTIES RECI_P,
               XLE_ENTITY_PROFILES  XLE1,
               FND_LOOKUP_VALUES LKUP1,
               FND_GRANTS FG,
       	       FND_OBJECT_INSTANCE_SETS FOIS
         WHERE FTH.batch_id(+) = FTB.batch_id
           AND XLE.legal_entity_id = FTB.from_le_id
           AND LKUP.lookup_type = ''FUN_BATCH_STATUS''
           AND LKUP.lookup_code = FTB.status
           AND LKUP.view_application_id = 435
	   AND LKUP.security_group_id=fnd_global.lookup_security_group(lkup.lookup_type,435)
	   AND LKUP.language = USERENV(''LANG'')
           AND FTH.status IN (''RECEIVED'', ''APPROVED'', ''REJECTED'',
               ''COMPLETE'', ''XFER_RECI_GL'', ''XFER_AR'', ''XFER_INI_GL'')
           AND INIT_P.party_id = FTB.initiator_id
           AND FTTVL.trx_type_id = FTB.trx_type_id
           AND RECI_P.party_id(+) = FTH.recipient_id
           AND XLE1.legal_entity_id(+) = FTH.to_le_id
           AND FCV.currency_code = FTB.currency_code
           AND LKUP1.lookup_type(+) = ''FUN_TRX_STATUS''
           AND LKUP1.view_application_id = 435
           AND LKUP1.security_group_id=fnd_global.lookup_security_group(lkup1.lookup_type,435)
           AND LKUP1.language = USERENV(''LANG'')
           AND LKUP1.lookup_code(+) = FTH.status
           AND GL.ledger_id = FTB.from_ledger_id
           AND FTB_ORIG.batch_id(+) = FTB.original_batch_id
           AND FTB_REV.batch_id(+) = FTB.reversed_batch_id
           AND GL1.ledger_id(+) = FTH.to_ledger_id
           AND FTH_ORIG.trx_id(+) = FTH.original_trx_id
           AND FTH_REV.trx_id(+) = FTH.reversed_trx_id
	   AND FG.parameter1 = TO_CHAR(FTH.recipient_id)
           AND FG.instance_set_id = FOIS.instance_set_id
           AND FOIS.instance_set_name = ''FUN_TRX_HEADERS_SET''
           AND NVL(FG.end_date, SYSDATE+1) > SYSDATE
           AND FG.grantee_key = ''' || l_grantee_key || '''';


    -- Based on the passed in parameters, build additional query conditions
    l_progress := '030';
    IF (p_para_rec.initiator_id IS NOT NULL) THEN
        x_inbound_query :=  x_inbound_query ||
            ' AND FTB.initiator_id = ' || p_para_rec.initiator_id;
    END IF;

    IF (p_para_rec.recipient_id IS NOT NULL) THEN
        x_inbound_query :=  x_inbound_query ||
            ' AND FTH.recipient_id = ' || p_para_rec.recipient_id;
    END IF;

    IF (p_para_rec.batch_number_from IS NOT NULL) AND
        (p_para_rec.batch_number_to IS NOT NULL) THEN
        x_inbound_query :=  x_inbound_query ||
            ' AND FTB.batch_number BETWEEN ''' || p_para_rec.batch_number_from
            || ''' AND ''' || p_para_rec.batch_number_to || '''';
    END IF;

    IF (p_para_rec.gl_date_from IS NOT NULL) AND
        (p_para_rec.gl_date_to IS NOT NULL) THEN
        x_inbound_query :=  x_inbound_query ||
            ' AND FTB.gl_date BETWEEN TO_DATE(''' || p_para_rec.gl_date_from
            || ''', ''YYYY/MM/DD HH24:MI:SS'') AND '
            || ' TO_DATE(''' || p_para_rec.gl_date_to
            || ''', ''YYYY/MM/DD HH24:MI:SS'')';
    END IF;

    IF (p_para_rec.batch_date_from IS NOT NULL) AND
        (p_para_rec.batch_date_to IS NOT NULL) THEN
        x_inbound_query :=  x_inbound_query ||
            ' AND FTB.gl_date BETWEEN TO_DATE(''' || p_para_rec.batch_date_from
            ||  ''', ''YYYY/MM/DD HH24:MI:SS'') AND '
            || ' TO_DATE(''' || p_para_rec.batch_date_to
            || ''', ''YYYY/MM/DD HH24:MI:SS'')';
    END IF;



    IF (p_para_rec.batch_status IS NOT NULL) THEN
        x_inbound_query :=  x_inbound_query ||
            ' AND FTB.status = ''' || p_para_rec.batch_status || '''';
    END IF;
    IF (p_para_rec.transaction_status IS NOT NULL) THEN
        x_inbound_query :=  x_inbound_query ||
            ' AND FTH.status = ''' || p_para_rec.transaction_status || '''';
    END IF;
    IF (p_para_rec.trx_type_id IS NOT NULL) THEN
        x_inbound_query :=  x_inbound_query ||
            ' AND FTB.trx_type_id = ' || p_para_rec.trx_type_id;
    END IF;
    IF (p_para_rec.currency_code IS NOT NULL) THEN
        x_inbound_query :=  x_inbound_query ||
            ' AND FTB.currency_code = ''' || p_para_rec.currency_code || '''';
    END IF;
    IF (p_para_rec.invoice_flag IS NOT NULL) THEN
        x_inbound_query :=  x_inbound_query ||
            ' AND FTH.invoice_flag = ''' || p_para_rec.invoice_flag || '''';
    END IF;
    IF (p_para_rec.ar_invoice_number IS NOT NULL) THEN
        x_inbound_query :=  x_inbound_query ||
            ' AND FTH.ar_invoice_number = ''' || p_para_rec.ar_invoice_number
            || '''';
    END IF;

    FUN_UTIL.log_conc_stmt(
        g_pkg_name, l_api_name, l_progress, 'x_inbound_query', x_inbound_query);
    FUN_UTIL.log_conc_end(g_pkg_name, l_api_name);

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FUN_UTIL.log_conc_unexp(
            g_pkg_name, l_api_name, l_progress);
        RAISE;
END build_summary_inquery;



-------------------------------------------------------------------------------
--Start of Comments
--Function:
--  Build the inbound account query string for intercompany account
--  details report based on report parameters
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE build_account_inquery(
    x_return_status    OUT NOCOPY VARCHAR2,
    p_para_rec         IN FUN_REPORT_PVT.accountreport_para_rec_type,
    x_inbound_query    OUT NOCOPY VARCHAR2
) IS
l_api_name VARCHAR2(30);
l_progress VARCHAR2(30);

l_acc_segment fnd_id_flex_segments.application_column_name%TYPE;

l_person_id HZ_PARTIES.party_id%TYPE;
l_grantee_key FND_GRANTS.grantee_key%TYPE;
BEGIN
    l_api_name := 'build_account_inquery';
    l_progress := '000';

    FUN_UTIL.log_conc_start(g_pkg_name, l_api_name);


    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Get parameters for security settings
    l_progress := '010';
    BEGIN
        SELECT distinct(HZP.party_id)
          INTO l_person_id
          FROM HZ_PARTIES HZP,
               FND_USER U,
               PER_ALL_PEOPLE_F PAP,
               (SELECT FND_GLOBAL.user_id() AS user_id FROM DUAL) CURR
         WHERE CURR.user_id = U.user_id
           AND U.employee_id = PAP.person_id
           AND PAP.party_id = HZP.party_id;

      IF (p_para_rec.coa_recipient IS NOT NULL) THEN

         SELECT application_column_name
           INTO l_acc_segment
           FROM fnd_segment_attribute_values
          WHERE application_id = 101
                AND id_flex_code = 'GL#'
                AND id_flex_num  = p_para_rec.coa_recipient
                AND segment_attribute_type = 'GL_ACCOUNT'
                AND attribute_value = 'Y';
      end if;

   EXCEPTION
        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            FUN_UTIL.log_conc_unexp(g_pkg_name, l_api_name, l_progress);
            RAISE;
    END;
    FUN_UTIL.log_conc_stmt(
        g_pkg_name, l_api_name, l_progress, 'l_person_id', l_person_id);

    l_grantee_key := 'HZ_PARTY:' || TO_CHAR(l_person_id);
    FUN_UTIL.log_conc_stmt(
        g_pkg_name, l_api_name, l_progress, 'l_grantee_key', l_grantee_key);


    -- Build query string for inbound transactions
    l_progress := '020';
    x_inbound_query := '
     SELECT fun_trx_entry_util.get_concatenated_account(fdl.ccid) account,
	   ''INBOUND''                                         batch_type,
           lkup.meaning                                     account_type,
	   FTB.batch_number                                 batch_number,
	   FTH.trx_number                                   trx_number,
	   lkup1.meaning                                    batch_status,
	   FTB.batch_date                                     batch_date,
	   INIT_P.party_name                                   initiator,
	   RECI_P.party_name                                   recipient,
	   lkup2.meaning                                      trx_status,
	   FTTVL.trx_type_name                          transaction_type,
	   FTB.gl_date                                           gl_date,
	   GLP.period_name                                     gl_period,
	   FCV.name                                     entered_currency,
	   FDL.amount_cr                                  entered_credit,
	   fdl.amount_dr                                   entered_debit,
	   fdl.description                                   description,
	   FTH.invoice_flag                                 invoice_flag,
	   NVL2(FTH.original_trx_id,NVL2(FTH.reversed_trx_id,0,FTH_REV.trx_number),FTH_ORIG.trx_number)   reverse_reference,
           DECODE(NVL(FTH.original_trx_id,0),0,''N'',''Y'')   reverse_trx_flag,
           DECODE(NVL(FTH.reversed_trx_id,0),0,''N'',''Y'')   reversed_flag,
 	   FTH.ar_invoice_number                       ar_invoice_number,
	   FTH_ORIG.trx_number                           orig_trx_number,
	   FTH_REV.trx_number                             rev_trx_number,
	   FTB_ORIG.batch_number                       orig_batch_number,
	   FTB_REV.batch_number                         rev_batch_number,
	   FTB.reject_allow_flag                       reject_allow_flag,
	   FTB.initiator_source                         initiator_source,
	   FTB.description                              batch_description,
	   FTB.attribute1,
           FTB.attribute2,
           FTB.attribute3,
           FTB.attribute4,
           FTB.attribute5,
           FTB.attribute6,
           FTB.attribute7,
           FTB.attribute8,
           FTB.attribute9,
           FTB.attribute10,
           FTB.attribute11,
           FTB.attribute12,
           FTB.attribute13,
           FTB.attribute14,
           FTB.attribute15,
           FTB.attribute_category,
	   fdl.dist_number                           distribution_number,
	   fdl.party_type_flag                           party_type_flag,
	   fdl.dist_type_flag                             dist_type_flag,
	   fdl.auto_generate_flag                     auto_generate_flag,
	   fdl.attribute1,
	   fdl.attribute2,
	   fdl.attribute3,
	   fdl.attribute4,
	   fdl.attribute5,
	   fdl.attribute6,
	   fdl.attribute7,
           fdl.attribute8,
           fdl.attribute9,
	   fdl.attribute10,
	   fdl.attribute11,
	   fdl.attribute12,
	   fdl.attribute13,
	   fdl.attribute14,
	   fdl.attribute15,
	   fdl.attribute_category,
	   XLE.name                                    init_le,
	   XLE1.name                                   recipient_le,
	   GL0.name                                     from_ledger_name,
	   GL1.name                                    to_ledger_name,
	   FTH.init_amount_cr                          initiator_credit,
           FTH.init_amount_dr                          initiator_debit,
           FTH.reci_amount_cr                          recipient_credit,
           FTH.reci_amount_dr                          recipient_debit,
	   FTH.approval_date                           approval_date,
	   FTH.initiator_instance_flag                 initiator_instance_flag,
           FTH.recipient_instance_flag                 recipient_instance_flag,
           FTH.reject_reason                           reject_reason,
           FTH.description                             header_description,
	   FTH.attribute1,
           FTH.attribute2,
           FTH.attribute3,
           FTH.attribute4,
           FTH.attribute5,
           FTH.attribute6,
           FTH.attribute7,
           FTH.attribute8,
           FTH.attribute9,
           FTH.attribute10,
           FTH.attribute11,
           FTH.attribute12,
           FTH.attribute13,
           FTH.attribute14,
           FTH.attribute15,
           FTH.attribute_category
FROM   fun_dist_lines          fdl,
       gl_code_combinations    glcc,
	   fnd_lookups             lkup,
	   fnd_lookup_values             lkup1,
	   fnd_lookup_values             lkup2,
	   FUN_TRX_BATCHES         FTB,
	   FUN_TRX_BATCHES         FTB_REV,
	   FUN_TRX_BATCHES         FTB_ORIG,
	   HZ_PARTIES              INIT_P,
	   HZ_PARTIES              RECI_P,
	   FUN_TRX_HEADERS         FTH,
	   FUN_TRX_HEADERS         FTH_REV,
	   FUN_TRX_HEADERS         FTH_ORIG,
	   FUN_TRX_TYPES_VL        FTTVL,
	   GL_PERIODS              GLP,
	   FND_CURRENCIES_VL       FCV,
	   FUN_TRX_LINES           FTL,
	   GL_LEDGERS              GL0,
	   GL_LEDGERS              GL1,
	   XLE_ENTITY_PROFILES  XLE,
	   XLE_ENTITY_PROFILES  XLE1,
	   FND_GRANTS FG,
       FND_OBJECT_INSTANCE_SETS FOIS
WHERE  fdl.ccid             = glcc.code_combination_id
AND    glcc.account_type    = lkup.lookup_code
AND    lkup.lookup_type     =''ACCOUNT_TYPE''
AND    lkup.lookup_code    IN (''A'',''E'',''L'',''R'', ''O'')
AND    lkup1.lookup_type    =''FUN_BATCH_STATUS''
AND    lkup1.lookup_code     = FTB.status
AND    lkup1.view_application_id = 435
AND    lkup1.security_group_id =fnd_global.lookup_security_group(lkup1.lookup_type,435)
AND    lkup1.language = USERENV(''LANG'')
AND    INIT_P.party_id      = FTB.initiator_id
AND    RECI_P.party_id(+)   = FTH.recipient_id
AND    lkup2.lookup_code     = FTH.status
AND    LKUP2.lookup_type  = ''FUN_TRX_STATUS''
AND    lkup2.view_application_id = 435
AND    lkup2.security_group_id =fnd_global.lookup_security_group(lkup2.lookup_type,435)
AND    lkup2.language = USERENV(''LANG'')
AND    LKUP2.lookup_code IN (''RECEIVED'',''APPROVED'',''REJECTED'',''COMPLETE'',''XFER_RECI_GL'',''XFER_AR'',''XFER_INI_GL'')
AND    FTH.batch_id(+)      = FTB.batch_id
AND    FTTVL.trx_type_id    = FTB.trx_type_id
AND    FTB.gl_date    BETWEEN GLP.start_date AND GLP.end_date
AND    FCV.currency_code    = FTB.currency_code
AND    FTL.trx_id           = FTH.trx_id
AND    FDL.party_type_flag =''R''
AND    FDL.line_id          = FTL.line_id
AND    FTH.original_trx_id=FTH_ORIG.trx_id(+)
AND    FTB.original_batch_id=FTB_ORIG.batch_id(+)
AND    FTH.reversed_trx_id=FTH_REV.trx_id(+)
AND    FTB.reversed_batch_id=FTB_REV.batch_id(+)
AND    XLE.legal_entity_id   = FTB.from_le_id
AND    XLE1.legal_entity_id  = FTH.to_le_id
AND    fdl.dist_type_flag IN (''P'',''L'')
AND    GL0.ledger_id = FTB.from_ledger_id
AND    GLP.period_set_name =GL0.period_set_name
AND    GLP.period_type = GL0.accounted_period_type
AND    GL1.ledger_id(+) = FTH.to_ledger_id
AND    FG.parameter1 = TO_CHAR(FTH.recipient_id)
AND    FG.instance_set_id = FOIS.instance_set_id
AND    FOIS.instance_set_name = ''FUN_TRX_HEADERS_SET''
AND    NVL(FG.end_date, SYSDATE+1) > SYSDATE
AND    FG.grantee_key = ''' || l_grantee_key||'''';




  IF ((p_para_rec.pay_account_from IS NOT NULL) AND (p_para_rec.pay_account_to
        IS NOT NULL) AND (p_para_rec.rec_dist_acc_from IS NOT NULL) AND
        (p_para_rec.rec_dist_acc_to IS NOT NULL)) THEN

         x_inbound_query:=x_inbound_query ||' AND GLCC.'||l_acc_segment||
 ' BETWEEN decode(fdl.dist_type_flag,''P'','||p_para_rec.pay_account_from||',''L'','||
                  p_para_rec.rec_dist_acc_from||') '||


   ' AND decode(fdl.dist_type_flag,''P'','||p_para_rec.pay_account_to||',''L'','||
                 p_para_rec.rec_dist_acc_to||') ';

   ELSIF ((p_para_rec.pay_account_from IS NOT NULL) AND
           (p_para_rec.pay_account_to  IS NOT NULL)) THEN

         x_inbound_query:=x_inbound_query ||' AND GLCC.'||l_acc_segment||
 ' BETWEEN decode(fdl.dist_type_flag,''P'','||p_para_rec.rec_account_from||',GLCC.'||l_acc_segment||') '||
 ' AND decode(fdl.dist_type_flag,''P'','||p_para_rec.rec_account_to||',GLCC.'||l_acc_segment||') ';



  ELSIF  ((p_para_rec.rec_dist_acc_from IS NOT NULL) AND
           (p_para_rec.rec_dist_acc_to  IS NOT NULL)) THEN

       x_inbound_query:=x_inbound_query ||' AND GLCC.'||l_acc_segment||
 ' BETWEEN decode(fdl.dist_type_flag,''L'','||p_para_rec.rec_dist_acc_from||',GLCC.'||l_acc_segment||') '||
 ' AND decode(fdl.dist_type_flag,''L'','||p_para_rec.rec_dist_acc_to||',GLCC.'||l_acc_segment||') ';



   END IF;




  -- Based on the passed in parameters, build additional query conditions
    l_progress := '030';



    IF ((p_para_rec.initiator_from IS NOT NULL) AND (p_para_rec.initiator_to IS
NOT NULL)) THEN
        x_inbound_query :=  x_inbound_query ||
           ' AND INIT_P.PARTY_NAME BETWEEN ''' || p_para_rec.initiator_from ||''' AND'''||
            p_para_rec.initiator_to||'''';
    END IF;
    IF ((p_para_rec.recipient_from IS NOT NULL) AND (p_para_rec.recipient_to IS
NOT NULL)) THEN
        x_inbound_query :=  x_inbound_query ||
           ' AND RECI_P.PARTY_NAME BETWEEN ''' || p_para_rec.recipient_from ||''' AND'''||
            p_para_rec.recipient_to||'''';
    END IF;
    IF (p_para_rec.transact_le IS NOT NULL) THEN
         x_inbound_query:= x_inbound_query||
           ' AND XLE.NAME = '''|| p_para_rec.transact_le||'''';
    END IF;

    IF (p_para_rec.trading_le IS NOT NULL) THEN
         x_inbound_query:= x_inbound_query ||
            ' AND XLE1.NAME ='''||p_para_rec.trading_le||'''';
    END IF;
    IF (p_para_rec.transact_ledger IS NOT NULL) THEN
         x_inbound_query:=x_inbound_query ||
           ' AND GL0.ledger_id ='||p_para_rec.transact_ledger;
    end if;

    IF (p_para_rec.trading_ledger IS NOT NULL) THEN
         x_inbound_query:= x_inbound_query ||
          '  AND GL1.ledger_id(+)='||p_para_rec.trading_ledger;
    END IF;


    IF (p_para_rec.batch_number_from IS NOT NULL) AND
        (p_para_rec.batch_number_to IS NOT NULL) THEN
        x_inbound_query :=  x_inbound_query ||
            ' AND FTB.batch_number BETWEEN ''' || p_para_rec.batch_number_from
            || ''' AND ''' || p_para_rec.batch_number_to || '''';
    END IF;



    IF (p_para_rec.gl_date_from IS NOT NULL) AND
        (p_para_rec.gl_date_to IS NOT NULL) THEN
        x_inbound_query :=  x_inbound_query ||
            ' AND FTB.gl_date BETWEEN TO_DATE(''' || p_para_rec.gl_date_from
            || ''', ''YYYY/MM/DD HH24:MI:SS'') AND '
            || ' TO_DATE(''' || p_para_rec.gl_date_to
            || ''', ''YYYY/MM/DD HH24:MI:SS'')';
    END IF;
    IF (p_para_rec.batch_status IS NOT NULL) THEN
        x_inbound_query :=  x_inbound_query ||
            ' AND FTB.status = ''' || p_para_rec.batch_status || '''';
    END IF;
    IF (p_para_rec.transaction_status IS NOT NULL) THEN
        x_inbound_query :=  x_inbound_query ||
            ' AND FTH.status = ''' || p_para_rec.transaction_status || '''';
    END IF;
    IF (p_para_rec.trx_type_id IS NOT NULL) THEN
        x_inbound_query :=  x_inbound_query ||
            ' AND FTB.trx_type_id = ' || p_para_rec.trx_type_id;
    END IF;
    IF (p_para_rec.currency_code IS NOT NULL) THEN
        x_inbound_query :=  x_inbound_query ||
            ' AND FTB.currency_code = ''' || p_para_rec.currency_code || '''';
    END IF;
    IF (p_para_rec.ar_invoice_number IS NOT NULL) THEN
        x_inbound_query :=  x_inbound_query ||
            ' AND FTH.ar_invoice_number = ''' || p_para_rec.ar_invoice_number
            || '''';
    END IF;

    IF (p_para_rec.account_type IS NOT NULL) THEN
	x_inbound_query:= x_inbound_query ||
		' AND lkup.lookup_code ='''||p_para_rec.account_type||'''';
    END IF;





    FUN_UTIL.log_conc_stmt(
        g_pkg_name, l_api_name, l_progress, 'x_inbound_query', x_inbound_query);
    FUN_UTIL.log_conc_end(g_pkg_name, l_api_name);

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FUN_UTIL.log_conc_unexp(
            g_pkg_name, l_api_name, l_progress);
        RAISE;
END build_account_inquery;




-------------------------------------------------------------------------------
--Start of Comments
--Function:
--  Return XML data given the query string
--  Also change XML data to given rowset tag and row tag
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_xml(
    x_return_status OUT NOCOPY VARCHAR2,
    p_query         IN VARCHAR2,
    p_rowset_tag    IN VARCHAR2 DEFAULT NULL,
    p_row_tag       IN VARCHAR2 DEFAULT NULL,
    x_xml           OUT NOCOPY CLOB
) IS
l_api_name VARCHAR2(20);
l_progress VARCHAR2(3);

l_ctx dbms_xmlgen.ctxHandle;
BEGIN
    l_api_name := 'get_xml';
    l_progress := '000';

    FUN_UTIL.log_conc_start(g_pkg_name, l_api_name);

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_progress := '010';
    l_ctx := DBMS_XMLGEN.newcontext(p_query);
    FUN_UTIL.log_conc_stmt(
        g_pkg_name, l_api_name, l_progress, 'l_ctx', l_ctx);


    -- change rowset tag
    IF p_rowset_tag IS NOT NULL THEN
        DBMS_XMLGEN.setRowSetTag(l_ctx,  p_rowset_tag);
    END IF;

    -- change row tag
    IF p_row_tag IS NOT NULL THEN
        DBMS_XMLGEN.setRowTag(l_ctx, p_row_tag);
    END IF;


    l_progress := '020';
    x_xml := DBMS_XMLGEN.getXML(l_ctx);

    DBMS_XMLGEN.closecontext(l_ctx);

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        DBMS_XMLGEN.closecontext(l_ctx);
        FUN_UTIL.log_conc_unexp(g_pkg_name, l_api_name, l_progress);
        RAISE;
END get_xml;




-------------------------------------------------------------------------------
--Start of Comments
--Function:
--  Construct XML data source based on report parameters, XML data of
--  outbound/inbound, format the data source to be XML Publisher compatible
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE construct_output(
    x_return_status OUT NOCOPY VARCHAR2,
    p_para_rec      IN FUN_REPORT_PVT.summaryreport_para_rec_type,
    p_outbound_trxs IN CLOB,
    p_inbound_trxs  IN CLOB
) IS
l_api_name VARCHAR2(30);
l_progress VARCHAR2(5);

l_para_meaning_list VARCHAR2(2000);

l_initiator_name HZ_PARTIES.party_name%TYPE;
l_recipient_name HZ_PARTIES.party_name%TYPE;
l_batch_status FND_LOOKUPS.meaning%TYPE;
l_trx_status FND_LOOKUPS.meaning%TYPE;
l_trx_type FUN_TRX_TYPES_VL.trx_type_name%TYPE;
l_currency FND_CURRENCIES_VL.name%TYPE;
l_encoding              VARCHAR2(20);
l_offset INTEGER;
BEGIN
    l_api_name := 'construct_output';
    l_progress := '000';

    FUN_UTIL.log_conc_start(g_pkg_name, l_api_name);


    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Construct the parameter list section
    l_progress := '010';

    BEGIN
        IF p_para_rec.initiator_id IS NOT NULL THEN
            SELECT party_name
              INTO l_initiator_name
              FROM HZ_PARTIES
             WHERE party_id = p_para_rec.initiator_id;
        END IF;
        IF p_para_rec.recipient_id IS NOT NULL THEN
            SELECT party_name
              INTO l_recipient_name
              FROM HZ_PARTIES
             WHERE party_id = p_para_rec.recipient_id;
        END IF;
        IF p_para_rec.batch_status IS NOT NULL THEN
            SELECT meaning
              INTO l_batch_status
              FROM FND_LOOKUP_VALUES
             WHERE lookup_type = 'FUN_BATCH_STATUS'
	       AND view_application_id = 435
	       AND security_group_id =fnd_global.lookup_security_group(lookup_type,435)
	       AND language = USERENV('LANG')
               AND lookup_code = p_para_rec.batch_status;
        END IF;

         IF p_para_rec.transaction_status IS NOT NULL THEN
            SELECT meaning
              INTO l_trx_status
              FROM FND_LOOKUP_VALUES
             WHERE lookup_type = 'FUN_TRX_STATUS'
              AND view_application_id = 435
              AND security_group_id=fnd_global.lookup_security_group(lookup_type,435)
              AND language = USERENV('LANG')
              AND lookup_code = p_para_rec.transaction_status;
         END IF;
        IF p_para_rec.trx_type_id IS NOT NULL THEN
            SELECT trx_type_name
              INTO l_trx_type
              FROM FUN_TRX_TYPES_VL
             WHERE trx_type_id = p_para_rec.trx_type_id;
         END IF;
        IF p_para_rec.currency_code IS NOT NULL THEN
            SELECT name
              INTO l_currency
              FROM FND_CURRENCIES_VL
             WHERE currency_code = p_para_rec.currency_code;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            FUN_UTIL.log_conc_unexp(g_pkg_name, l_api_name, l_progress);
    END;
    l_encoding       := fnd_profile.value('ICX_CLIENT_IANA_ENCODING');
    l_para_meaning_list :=
        '<?xml version="1.0" encoding="'||l_encoding||'"?>' ||
        '<REPORT_ROOT>' ||
        '<PARAMETERS>' ||
        '<PARA_BATCH_TYPE>' || p_para_rec.batch_type || '</PARA_BATCH_TYPE>' ||
        '<PARA_INITIATOR>' || l_initiator_name || '</PARA_INITIATOR>' ||
        '<PARA_RECIPIENT>' || l_recipient_name || '</PARA_RECIPIENT>' ||
        '<PARA_GL_DATE_FROM>' || p_para_rec.gl_date_from || '</PARA_GL_DATE_FROM>' ||
        '<PARA_GL_DATE_TO>' || p_para_rec.gl_date_to ||'</PARA_GL_DATE_TO>' ||
        '<PARA_BATCH_DATE_FROM>' || p_para_rec.batch_date_from || '</PARA_BATCH_DATE_FROM>' ||
        '<PARA_BATCH_DATE_TO>' || p_para_rec.batch_date_to || '</PARA_BATCH_DATE_TO>' ||
        '<PARA_BATCH_NUMBER_FROM>' || p_para_rec.batch_number_from || '</PARA_BATCH_NUMBER_FROM>' ||
        '<PARA_BATCH_NUMBER_TO>' || p_para_rec.batch_number_to || '</PARA_BATCH_NUMBER_TO>' ||
        '<PARA_BATCH_STATUS>' || l_batch_status || '</PARA_BATCH_STATUS>' ||
        '<PARA_TRX_STATUS>' || l_trx_status || '</PARA_TRX_STATUS>' ||
        '<PARA_TRX_TYPE>' || l_trx_type || '</PARA_TRX_TYPE>' ||
        '<PARA_CURRENCY>' || l_currency || '</PARA_CURRENCY>' ||
        '<PARA_INVOCING_RULE>' || p_para_rec.invoice_flag || '</PARA_INVOCING_RULE>' ||
        '<PARA_INVOICE_NUMBER>' || p_para_rec.ar_invoice_number || '</PARA_INVOICE_NUMBER>' ||
        '</PARAMETERS>';


    -- Save the parameter list to output file
    l_progress := '020';
    FND_FILE.put_line(FND_FILE.output, l_para_meaning_list);


    -- Process the XML data source and save to output file
    l_progress := '030';
    IF (p_para_rec.batch_type = 'BOTH') THEN
        FUN_UTIL.log_conc_stmt(
            g_pkg_name, l_api_name, l_progress, 'construct both', '');
        IF DBMS_LOB.getlength(p_outbound_trxs) IS NULL THEN
            l_progress := '030.a';
            FND_FILE.put_line(FND_FILE.output, '<OUTBOUND> </OUTBOUND>');
        ELSE
            -- trim header of outbound trxs
            -- save outbound trxs
            l_progress := '030.b';
            l_offset := DBMS_LOB.instr (
                            lob_loc => p_outbound_trxs,
                            pattern => '?>',
                            offset  => 1,
                            nth     => 1);
            FUN_UTIL.log_conc_stmt(
                g_pkg_name, l_api_name, l_progress, 'l_offset', l_offset);

            save_xml(
                x_return_status => x_return_status,
                p_trxs          => p_outbound_trxs,
                p_offset        => l_offset+2);
        END IF;

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


        IF DBMS_LOB.getlength(p_inbound_trxs) IS NULL THEN
            l_progress := '030.c';
            FND_FILE.put_line(FND_FILE.output, '<INBOUND> </INBOUND>');
        ELSE
            -- trim header of inbound trxs
            -- save inbound trxs
            l_progress := '030.d';
            l_offset := DBMS_LOB.instr (
                            lob_loc => p_inbound_trxs,
                            pattern => '?>',
                            offset  => 1,
                            nth     => 1);
            FUN_UTIL.log_conc_stmt(
                g_pkg_name, l_api_name, l_progress, 'l_offset', l_offset);

            save_xml(
                x_return_status => x_return_status,
                p_trxs          => p_inbound_trxs,
                p_offset        => l_offset+2);
        END IF;



    ELSIF (p_para_rec.batch_type = 'IN') THEN
        FND_FILE.put_line(FND_FILE.output, '<OUTBOUND> </OUTBOUND>');

        IF DBMS_LOB.getlength(p_inbound_trxs) IS NULL THEN
            l_progress := '030.e';
            FND_FILE.put_line(FND_FILE.output, '<INBOUND> </INBOUND>');
        ELSE
            -- trim header of inbound trxs
            -- append inbound trxs to outbound trxs
            l_progress := '030.f';
            l_offset := DBMS_LOB.instr (
                            lob_loc => p_inbound_trxs,
                            pattern => '?>',
                            offset  => 1,
                            nth     => 1);
            FUN_UTIL.log_conc_stmt(
                g_pkg_name, l_api_name, l_progress, 'l_offset', l_offset);

            save_xml(
                x_return_status => x_return_status,
                p_trxs          => p_inbound_trxs,
                p_offset        => l_offset+2);
        END IF;

    ELSE -- (p_para_rec.batch_type = 'OUT')
        IF DBMS_LOB.getlength(p_outbound_trxs) IS NULL THEN
            l_progress := '030.g';
            FND_FILE.put_line(FND_FILE.output, '<OUTBOUND> </OUTBOUND>');
        ELSE
            -- trim header of outbound trxs
            -- append outbound trxs to outbound trxs
            l_progress := '030.h';
            l_offset := DBMS_LOB.instr (
                            lob_loc => p_outbound_trxs,
                            pattern => '?>',
                            offset  => 1,
                            nth     => 1);
            FUN_UTIL.log_conc_stmt(
                g_pkg_name, l_api_name, l_progress, 'l_offset', l_offset);

            save_xml(
                x_return_status => x_return_status,
                p_trxs          => p_outbound_trxs,
                p_offset        => l_offset+2);
        END IF;

        FND_FILE.put_line(FND_FILE.output, '<INBOUND> </INBOUND>');

    END IF;

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    FND_FILE.put_line(FND_FILE.output, '</REPORT_ROOT>');


    FUN_UTIL.log_conc_end(g_pkg_name, l_api_name);

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FUN_UTIL.log_conc_err(
            g_pkg_name, l_api_name, l_progress, 'error in construct_output');
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FUN_UTIL.log_conc_err(
            g_pkg_name, l_api_name, l_progress, 'error in construct_output');
        RAISE FND_API.G_EXC_ERROR;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FUN_UTIL.log_conc_unexp(
            g_pkg_name, l_api_name, l_progress);
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END construct_output;





-------------------------------------------------------------------------------
--Start of Comments
--Function:
--  Construct XML data source based on report parameters, XML data of
--  outbound/inbound, format the data source to be XML Publisher compatible
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE construct_account_output(
    x_return_status OUT NOCOPY VARCHAR2,
    p_para_rec      IN FUN_REPORT_PVT.accountreport_para_rec_type,
    p_trxs IN CLOB
) IS
l_api_name VARCHAR2(30);
l_progress VARCHAR2(5);

l_para_meaning_list VARCHAR2(2000);

l_initiator_name HZ_PARTIES.party_name%TYPE;
l_recipient_name HZ_PARTIES.party_name%TYPE;
l_batch_status FND_LOOKUPS.meaning%TYPE;
l_trx_status FND_LOOKUPS.meaning%TYPE;
l_acc_type   FND_LOOKUPS.meaning%TYPE;
l_trx_type FUN_TRX_TYPES_VL.trx_type_name%TYPE;
l_currency FND_CURRENCIES_VL.name%TYPE;
l_transact_ledger GL_LEDGERS.name%TYPE;
l_trading_ledger  GL_LEDGERS.name%TYPE;
l_encoding              VARCHAR2(20);
l_offset INTEGER;
BEGIN
    l_api_name := 'construct_account_output';
    l_progress := '000';

    FUN_UTIL.log_conc_start(g_pkg_name, l_api_name);


    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Construct the parameter list section
    l_progress := '010';

    BEGIN
        IF p_para_rec.batch_status IS NOT NULL THEN
            SELECT meaning
              INTO l_batch_status
              FROM FND_LOOKUP_VALUES
             WHERE lookup_type = 'FUN_BATCH_STATUS'
               AND view_application_id = 435
               AND security_group_id=fnd_global.lookup_security_group(lookup_type,435)
               AND language = USERENV('LANG')
               AND lookup_code = p_para_rec.batch_status;
        END IF;
        IF p_para_rec.transaction_status IS NOT NULL THEN
            SELECT meaning
              INTO l_trx_status
              FROM FND_LOOKUP_VALUES
             WHERE lookup_type = 'FUN_TRX_STATUS'
	       AND view_application_id = 435
               AND security_group_id=fnd_global.lookup_security_group(lookup_type,435)
               AND language = USERENV('LANG')
               AND lookup_code = p_para_rec.transaction_status;
        END IF;
        IF p_para_rec.trx_type_id IS NOT NULL THEN
            SELECT trx_type_name
              INTO l_trx_type
              FROM FUN_TRX_TYPES_VL
             WHERE trx_type_id = p_para_rec.trx_type_id;
        END IF;
        IF p_para_rec.currency_code IS NOT NULL THEN
            SELECT name
              INTO l_currency
              FROM FND_CURRENCIES_VL
             WHERE currency_code = p_para_rec.currency_code;
        END IF;
        IF p_para_rec.account_type IS NOT NULL THEN
           SELECT meaning
             INTO l_acc_type
             FROM FND_LOOKUPS
            WHERE lookup_code = p_para_rec.account_type
	     AND  lookup_type ='ACCOUNT_TYPE';
	END IF;
        IF p_para_rec.transact_ledger IS NOT NULL THEN
            SELECT name
              INTO l_transact_ledger
              FROM gl_ledgers
             WHERE ledger_id = p_para_rec.transact_ledger;
        END IF;
        IF p_para_rec.trading_ledger IS NOT NULL THEN
            SELECT name
              INTO l_trading_ledger
 	      FROM gl_ledgers
            WHERE  ledger_id = p_para_rec.trading_ledger;
	END IF;
    EXCEPTION
        WHEN OTHERS THEN
            FUN_UTIL.log_conc_unexp(g_pkg_name, l_api_name, l_progress);
    END;
    l_encoding       := fnd_profile.value('ICX_CLIENT_IANA_ENCODING');
    l_para_meaning_list :=
        '<?xml version="1.0" encoding="'||l_encoding||'"?>' ||
        '<REPORT_ROOT>' ||
        '<PARAMETERS>' ||
        '<PARA_INITIATOR_FROM>'||p_para_rec.initiator_from||
'</PARA_INITIATOR_FROM>'||
        '<PARA_INITIATOR_TO>'||p_para_rec.initiator_to||'</PARA_INITIATOR_TO>'||
        '<PARA_TRANSACT_LE>'||p_para_rec.transact_le||'</PARA_TRANSACT_LE>'||
        '<PARA_TRANSACT_LEDGER>'||l_transact_ledger||'</PARA_TRANSACT_LEDGER>'||
        '<PARA_RECIPIENT_FROM>'||p_para_rec.recipient_from||'</PARA_RECIPIENT_FROM>'||
        '<PARA_RECIPIENT_TO>'||p_para_rec.recipient_to||'</PARA_RECIPIENT_TO>'||
        '<PARA_TRADING_LE>'||p_para_rec.trading_le||'</PARA_TRADING_LE>'||
        '<PARA_TRADING_LEDGER>'||l_trading_ledger||'</PARA_TRADING_LEDGER>'||
        '<PARA_GL_DATE_FROM>' || p_para_rec.gl_date_from || '</PARA_GL_DATE_FROM>' ||
        '<PARA_GL_DATE_TO>' || p_para_rec.gl_date_to ||'</PARA_GL_DATE_TO>' ||
        '<PARA_BATCH_TYPE>' || p_para_rec.batch_type || '</PARA_BATCH_TYPE>' ||
   '<PARA_BATCH_NUMBER_FROM>' || p_para_rec.batch_number_from || '</PARA_BATCH_NUMBER_FROM>' ||
        '<PARA_BATCH_NUMBER_TO>' || p_para_rec.batch_number_to || '</PARA_BATCH_NUMBER_TO>' ||
        '<PARA_BATCH_STATUS>' || l_batch_status || '</PARA_BATCH_STATUS>' ||
        '<PARA_TRX_STATUS>' || l_trx_status || '</PARA_TRX_STATUS>' ||
        '<PARA_TRX_TYPE>' || l_trx_type || '</PARA_TRX_TYPE>' ||
        '<PARA_ACC_TYPE>' || l_acc_type || '</PARA_ACC_TYPE>' ||
        '<PARA_CURRENCY>' || l_currency || '</PARA_CURRENCY>' ||
  '<PARA_RECEIV_ACCOUNT_FROM>'||p_para_rec.rec_account_from||'</PARA_RECEIV_ACCOUNT_FROM>'||
  '<PARA_RECEIV_ACCOUNT_TO>'||p_para_rec.rec_account_to||'</PARA_RECEIV_ACCOUNT_TO>'||
  '<PARA_PAY_ACCOUNT_FROM>'||p_para_rec.pay_account_from||'</PARA_PAY_ACCOUNT_FROM>'||
  '<PARA_PAY_ACCOUNT_TO>'||p_para_rec.pay_account_to||'</PARA_PAY_ACCOUNT_TO>'||
'<PARA_INIT_DIST_ACCOUNT_FROM>'||p_para_rec.init_dist_acc_from||'</PARA_INIT_DIST_ACCOUNT_FROM>'||
'<PARA_INIT_DIST_ACCOUNT_TO>'||p_para_rec.init_dist_acc_to||'</PARA_INIT_DIST_ACCOUNT_TO>'||
'<PARA_RECIP_DIST_ACCOUNT_FROM>'||p_para_rec.rec_dist_acc_from||'</PARA_RECIP_DIST_ACCOUNT_FROM>'||
'<PARA_RECIP_DIST_ACCOUNT_TO>'||p_para_rec.rec_dist_acc_to||'</PARA_RECIP_DIST_ACCOUNT_TO>'||
          '<PARA_INVOICE_NUMBER>' || p_para_rec.ar_invoice_number || '</PARA_INVOICE_NUMBER>' ||

        '</PARAMETERS>';


    -- Save the parameter list to output file
    l_progress := '020';
    FND_FILE.put_line(FND_FILE.output, l_para_meaning_list);
FUN_UTIL.log_conc_stmt(
        g_pkg_name, l_api_name, l_progress, 'xml_parameters',l_para_meaning_list);



    -- Process the XML data source and save to output file
    l_progress := '030';


        FUN_UTIL.log_conc_stmt(
            g_pkg_name, l_api_name, l_progress, 'construct both', '');
        IF DBMS_LOB.getlength(p_trxs) IS NULL THEN
            l_progress := '030.a';
        ELSE
            -- trim header of  trxs
            -- save trxs
            l_progress := '030.b';
            l_offset := DBMS_LOB.instr (
                            lob_loc => p_trxs,
                            pattern => '?>',
                            offset  => 1,
                            nth     => 1);
            FUN_UTIL.log_conc_stmt(
                g_pkg_name, l_api_name, l_progress, 'l_offset', l_offset);

            save_xml(
                x_return_status => x_return_status,
                p_trxs          => p_trxs,
                p_offset        => l_offset+2);
        END IF;

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;






    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    FND_FILE.put_line(FND_FILE.output, '</REPORT_ROOT>');


    FUN_UTIL.log_conc_end(g_pkg_name, l_api_name);

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FUN_UTIL.log_conc_err(
            g_pkg_name, l_api_name, l_progress, 'error in construct_output');
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FUN_UTIL.log_conc_err(
            g_pkg_name, l_api_name, l_progress, 'error in construct_output');
        RAISE FND_API.G_EXC_ERROR;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FUN_UTIL.log_conc_unexp(
            g_pkg_name, l_api_name, l_progress);
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END construct_account_output;




-------------------------------------------------------------------------------
--Start of Comments
--Function:
--  Save CLOB to concurrent program output file given CLOB offset
--
--End of Comments
------------------------------------------------------------------------------
PROCEDURE save_xml(
    x_return_status OUT NOCOPY VARCHAR2,
    p_trxs          IN CLOB,
    p_offset        IN INTEGER DEFAULT 1
) IS
l_api_name VARCHAR2(100);
l_progress VARCHAR2(3);

l_length INTEGER;
l_buffer VARCHAR2(32766);
l_amount BINARY_INTEGER := 8175;     -- 32700/4 Since a single character can accomidate 4 bites
l_pos    INTEGER;
BEGIN
    l_api_name := 'save_xml';
    l_progress := '000';
    l_pos := p_offset;

    FUN_UTIL.log_conc_start(g_pkg_name, l_api_name);


    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_progress := '010';
    l_length := DBMS_LOB.getlength(p_trxs);
    FUN_UTIL.log_conc_stmt(
        g_pkg_name, l_api_name, l_progress, 'l_length', l_length);

    WHILE (l_pos <= l_length)
        LOOP
            DBMS_LOB.read(p_trxs, l_amount, l_pos, l_buffer);
           FND_FILE.put(FND_FILE.output, l_buffer);

-- FUN_UTIL.log_conc_stmt(g_pkg_name, l_api_name, l_progress, 'xml_date',l_buffer);
--           l_buffer:=NULL;

            l_pos := l_pos + l_amount;
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FUN_UTIL.log_conc_unexp(
            g_pkg_name, l_api_name, l_progress);
        RAISE;
END save_xml;




-------------------------------------------------------------------------------
--Start of Comments
--Function:
--  Main program of data extractor for Intercompany Transaction Summary
--  Report, and save the XML Publisher compatible data to concurrent
--  program output file
--
--End of Comments
------------------------------------------------------------------------------
PROCEDURE create_summaryreport(
    errbuf               OUT NOCOPY VARCHAR2,
    retcode              OUT NOCOPY NUMBER,
    p_batch_type         IN VARCHAR2,
    p_initiator_id       IN NUMBER DEFAULT NULL,
    p_recipient_id       IN NUMBER DEFAULT NULL,
    p_batch_number_from  IN VARCHAR2 DEFAULT NULL,
    p_batch_number_to    IN VARCHAR2 DEFAULT NULL,
    p_gl_date_from       IN VARCHAR2 DEFAULT NULL,
    p_gl_date_to         IN VARCHAR2 DEFAULT NULL,
    p_batch_date_from    IN VARCHAR2 DEFAULT NULL,
    p_batch_date_to      IN VARCHAR2 DEFAULT NULL,
    p_batch_status       IN VARCHAR2 DEFAULT NULL,
    p_transaction_status IN VARCHAR2 DEFAULT NULL,
    p_trx_type_id        IN NUMBER DEFAULT NULL,
    p_currency_code      IN VARCHAR2 DEFAULT NULL,
    p_invoice_flag       IN VARCHAR2 DEFAULT NULL,
    p_ar_invoice_number  IN VARCHAR2 DEFAULT NULL
) IS
l_api_name VARCHAR2(30);
l_progress VARCHAR2(3);

l_para_rec FUN_REPORT_PVT.summaryreport_para_rec_type;
l_return_status VARCHAR2(20);
l_outbound_query VARCHAR2(20000);
l_inbound_query VARCHAR2(20000);
l_trxs CLOB;
l_outbound_trxs CLOB;
l_inbound_trxs CLOB;
BEGIN
    l_api_name := 'create_summaryreport';
    l_progress := '000';
    errbuf := NULL;
    retcode := 0;


    -- Save the in parameters in fnd log file
    FUN_UTIL.log_conc_start(g_pkg_name, l_api_name);
    FUN_UTIL.log_conc_stmt(
        g_pkg_name, l_api_name, l_progress, 'p_batch_type', p_batch_type);
    FUN_UTIL.log_conc_stmt(
        g_pkg_name, l_api_name, l_progress, 'p_initiator_id', p_initiator_id);
    FUN_UTIL.log_conc_stmt(
        g_pkg_name, l_api_name, l_progress, 'p_recipient_id', p_recipient_id);
    FUN_UTIL.log_conc_stmt(
        g_pkg_name, l_api_name, l_progress, 'p_batch_number_from', p_batch_number_from);
    FUN_UTIL.log_conc_stmt(
        g_pkg_name, l_api_name, l_progress, 'p_batch_number_to', p_batch_number_to);
    FUN_UTIL.log_conc_stmt(
        g_pkg_name, l_api_name, l_progress, 'p_gl_date_from', p_gl_date_from);
    FUN_UTIL.log_conc_stmt(
        g_pkg_name, l_api_name, l_progress, 'p_gl_date_to', p_gl_date_to);
    FUN_UTIL.log_conc_stmt(
        g_pkg_name, l_api_name, l_progress, 'p_batch_date_from', p_batch_date_from);
    FUN_UTIL.log_conc_stmt(
        g_pkg_name, l_api_name, l_progress, 'p_batch_date_to', p_batch_date_to);
    FUN_UTIL.log_conc_stmt(
        g_pkg_name, l_api_name, l_progress, 'p_batch_status', p_batch_status);
    FUN_UTIL.log_conc_stmt(
        g_pkg_name, l_api_name, l_progress, 'p_transaction_status', p_transaction_status);
    FUN_UTIL.log_conc_stmt(
        g_pkg_name, l_api_name, l_progress, 'p_trx_type_id', p_trx_type_id);
    FUN_UTIL.log_conc_stmt(
        g_pkg_name, l_api_name, l_progress, 'p_currency_code', p_currency_code);
    FUN_UTIL.log_conc_stmt(
        g_pkg_name, l_api_name, l_progress, 'p_invoice_flag', p_invoice_flag);
    FUN_UTIL.log_conc_stmt(
        g_pkg_name, l_api_name, l_progress, 'p_ar_invoice_number', p_ar_invoice_number);


    -- initialize summaryreport parameters record
    l_progress := '010';
    l_para_rec.batch_type := p_batch_type;
    l_para_rec.initiator_id := p_initiator_id;
    l_para_rec.recipient_id := p_recipient_id;
    l_para_rec.batch_number_from := p_batch_number_from;
    l_para_rec.batch_number_to := p_batch_number_to;
    l_para_rec.gl_date_from := p_gl_date_from;
    l_para_rec.gl_date_to := p_gl_date_to;
    l_para_rec.batch_date_from := p_batch_date_from;
    l_para_rec.batch_date_to := p_batch_date_to;
    l_para_rec.batch_status := p_batch_status;
    l_para_rec.transaction_status := p_transaction_status;
    l_para_rec.trx_type_id := p_trx_type_id;
    l_para_rec.currency_code := p_currency_code;
    l_para_rec.invoice_flag := p_invoice_flag;
    l_para_rec.ar_invoice_number := p_ar_invoice_number;


    -- Based on batch type, build the query to get inbound, outbound or both
    -- transactions
    l_progress := '030';
    IF (p_batch_type = 'BOTH') THEN
        FUN_UTIL.log_conc_stmt(
            g_pkg_name, l_api_name, l_progress, '', 'call build_summary_outquery');
        build_summary_outquery(
            x_return_status  => l_return_status,
            p_para_rec       => l_para_rec,
            x_outbound_query => l_outbound_query
        );

        FUN_UTIL.log_conc_stmt(
            g_pkg_name, l_api_name, l_progress, '', 'call build_summary_inquery');
        build_summary_inquery(
            x_return_status  => l_return_status,
            p_para_rec       => l_para_rec,
            x_inbound_query  => l_inbound_query
        );
    ELSIF (p_batch_type = 'IN') THEN
        FUN_UTIL.log_conc_stmt(
            g_pkg_name, l_api_name, l_progress, '', 'call build_summary_inquery');
        build_summary_inquery(
            x_return_status  => l_return_status,
            p_para_rec       => l_para_rec,
            x_inbound_query  => l_inbound_query
        );
    ELSIF (p_batch_type = 'OUT') THEN
        FUN_UTIL.log_conc_stmt(
            g_pkg_name, l_api_name, l_progress, '', 'call build_summary_outquery');
        build_summary_outquery(
            x_return_status  => l_return_status,
            p_para_rec       => l_para_rec,
            x_outbound_query => l_outbound_query
        );
    ELSE
        FUN_UTIL.log_conc_stmt(
            g_pkg_name, l_api_name, l_progress, 'batch type is incorrect');
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Get the XML data source
    l_progress := '040';
    IF (p_batch_type = 'BOTH') THEN
        FUN_UTIL.log_conc_stmt(
            g_pkg_name, l_api_name, l_progress, '', 'call get_xml for outbound');
        get_xml(
            x_return_status => l_return_status,
            p_query         => l_outbound_query,
            p_rowset_tag    => 'OUTBOUND',
            p_row_tag       => 'OUTBOUND_BATCH',
            x_xml           => l_outbound_trxs
        );

        FUN_UTIL.log_conc_stmt(
            g_pkg_name, l_api_name, l_progress, '', 'call get_xml for inbound');
        get_xml(
            x_return_status => l_return_status,
            p_query         => l_inbound_query,
            p_rowset_tag    => 'INBOUND',
            p_row_tag       => 'INBOUND_BATCH',
            x_xml           => l_inbound_trxs
        );
    ELSIF (p_batch_type = 'IN') THEN
        FUN_UTIL.log_conc_stmt(
            g_pkg_name, l_api_name, l_progress, '', 'call get_xml for inbound');
        get_xml(
            x_return_status => l_return_status,
            p_query         => l_inbound_query,
            p_rowset_tag    => 'INBOUND',
            p_row_tag       => 'INBOUND_BATCH',
            x_xml           => l_inbound_trxs
        );
    ELSIF (p_batch_type = 'OUT') THEN
        FUN_UTIL.log_conc_stmt(
            g_pkg_name, l_api_name, l_progress, '', 'call get_xml for outbound');
        get_xml(
            x_return_status => l_return_status,
            p_query         => l_outbound_query,
            p_rowset_tag    => 'OUTBOUND',
            p_row_tag       => 'OUTBOUND_BATCH',
            x_xml           => l_outbound_trxs
        );
    END IF;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    -- Manupulate XML data source to XML Publisher compatiable format
    -- and save it to output file
    l_progress := '050';
    FUN_UTIL.log_conc_stmt(
        g_pkg_name, l_api_name, l_progress, '', 'call construct_output');
    construct_output(
        x_return_status => l_return_status,
        p_para_rec      => l_para_rec,
        p_outbound_trxs => l_outbound_trxs,
        p_inbound_trxs  => l_inbound_trxs
    );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    FUN_UTIL.log_conc_end(g_pkg_name, l_api_name);

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        retcode := 2;
        FUN_UTIL.log_conc_err(
            g_pkg_name, l_api_name, l_progress, 'error in create_summaryreport');
    WHEN FND_API.G_EXC_ERROR THEN
        retcode := 2;
        FUN_UTIL.log_conc_unexp(
            g_pkg_name, l_api_name, l_progress);
        FUN_UTIL.log_conc_err(
            g_pkg_name, l_api_name, l_progress, 'error in create_summaryreport');
    WHEN OTHERS THEN
        retcode := 2;
        FUN_UTIL.log_conc_err(
            g_pkg_name, l_api_name, l_progress, 'error in create_summaryreport');
END create_summaryreport;


-------------------------------------------------------------------------------
--Start of Comments
--Function:
--  Main program of data extractor for Intercompany Account details
--  Report, and save the XML Publisher compatible data to concurrent
--  program output file
--
--End of Comments
------------------------------------------------------------------------------
PROCEDURE create_accountreport(
    errbuf               OUT NOCOPY VARCHAR2,
    retcode              OUT NOCOPY NUMBER,
    p_initiator_from     IN VARCHAR2 DEFAULT NULL,
         p_initiator_to       IN VARCHAR2 DEFAULT NULL,
         p_transact_le        IN VARCHAR2 DEFAULT NULL,
         p_transact_ledger_id          IN NUMBER   DEFAULT NULL,
         p_recipient_from     IN VARCHAR2 DEFAULT NULL,
         p_recipient_to       IN VARCHAR2 DEFAULT NULL,
         p_trading_le         IN VARCHAR2 DEFAULT NULL,
         p_trading_ledger_id  IN NUMBER   DEFAULT NULL,
         p_gl_date_from       IN VARCHAR2 DEFAULT NULL,
         p_gl_date_to         IN VARCHAR2 DEFAULT NULL,
         p_batch_type         IN VARCHAR2,
         p_batch_number_from  IN VARCHAR2 DEFAULT NULL,
         p_batch_number_to    IN VARCHAR2 DEFAULT NULL,
         p_batch_status       IN VARCHAR2 DEFAULT NULL,
         p_transaction_status IN VARCHAR2 DEFAULT NULL,
         p_trx_type_id        IN NUMBER DEFAULT NULL,
         p_currency_code      IN VARCHAR2 DEFAULT NULL,
         p_acc_type           IN VARCHAR2 DEFAULT NULL,
         p_coa_initiator      IN NUMBER DEFAULT NULL,
         p_coa_recipient      IN NUMBER DEFAULT NULL,
         p_rec_account_from   IN VARCHAR2 DEFAULT NULL,
         p_rec_account_to     IN VARCHAR2 DEFAULT NULL,
         p_pay_account_from   IN VARCHAR2 DEFAULT NULL,
         p_pay_account_to     IN VARCHAR2 DEFAULT NULL,
         p_init_d_account_from IN VARCHAR2 DEFAULT NULL,
         p_init_d_account_to  IN VARCHAR2 DEFAULT NULL,
         p_recip_d_account_from IN VARCHAR2 DEFAULT NULL,
         p_recip_d_account_to  IN VARCHAR2 DEFAULT NULL,
         p_ar_invoice_number  IN VARCHAR2 DEFAULT NULL
) IS
l_api_name VARCHAR2(30);
l_progress VARCHAR2(3);

l_para_rec FUN_REPORT_PVT.accountreport_para_rec_type;
l_return_status VARCHAR2(20);
l_outbound_query VARCHAR2(15000) DEFAULT NULL;
l_inbound_query VARCHAR2(15000)  DEFAULT NULL;
l_query         VARCHAR2(31000);
l_trxs CLOB;
BEGIN
    l_api_name := 'create_accountreport';
    l_progress := '000';
    errbuf := NULL;
    retcode := 0;


    -- Save the in parameters in fnd log file
    FUN_UTIL.log_conc_start(g_pkg_name, l_api_name);
    FUN_UTIL.log_conc_stmt(
        g_pkg_name, l_api_name, l_progress, 'p_batch_type', p_batch_type);
    FUN_UTIL.log_conc_stmt(
        g_pkg_name, l_api_name, l_progress, 'p_initiator_from', p_initiator_from);
    FUN_UTIL.log_conc_stmt(
        g_pkg_name, l_api_name, l_progress, 'p_recipient_from', p_recipient_from);
    FUN_UTIL.log_conc_stmt(
        g_pkg_name, l_api_name, l_progress, 'p_batch_number_from', p_batch_number_from);
    FUN_UTIL.log_conc_stmt(
        g_pkg_name, l_api_name, l_progress, 'p_batch_number_to', p_batch_number_to);
    FUN_UTIL.log_conc_stmt(
        g_pkg_name, l_api_name, l_progress, 'p_gl_date_from', p_gl_date_from);
    FUN_UTIL.log_conc_stmt(
        g_pkg_name, l_api_name, l_progress, 'p_gl_date_to', p_gl_date_to);
    FUN_UTIL.log_conc_stmt(
        g_pkg_name, l_api_name, l_progress, 'p_batch_status', p_batch_status);
    FUN_UTIL.log_conc_stmt(
        g_pkg_name, l_api_name, l_progress, 'p_transaction_status', p_transaction_status);
    FUN_UTIL.log_conc_stmt(
        g_pkg_name, l_api_name, l_progress, 'p_trx_type_id', p_trx_type_id);
    FUN_UTIL.log_conc_stmt(
        g_pkg_name, l_api_name, l_progress, 'p_currency_code', p_currency_code);
    FUN_UTIL.log_conc_stmt(
        g_pkg_name, l_api_name, l_progress, 'p_acc_type', p_acc_type);
    FUN_UTIL.log_conc_stmt(
        g_pkg_name, l_api_name, l_progress, 'p_ar_invoice_number', p_ar_invoice_number);


    -- initialize accountreport parameters record
    l_progress := '010';
    l_para_rec.batch_type := p_batch_type;
    l_para_rec.initiator_from := p_initiator_from;
    l_para_rec.initiator_to := p_initiator_to;
    l_para_rec.transact_le  := p_transact_le;
    l_para_rec.transact_ledger:=p_transact_ledger_id;
    l_para_rec.recipient_to := p_recipient_to;
    l_para_rec.recipient_from := p_recipient_from;
    l_para_rec.trading_le := p_trading_le;
    l_para_rec.trading_ledger:=p_trading_ledger_id;
    l_para_rec.batch_number_from := p_batch_number_from;
    l_para_rec.batch_number_to := p_batch_number_to;
    l_para_rec.gl_date_from := p_gl_date_from;
    l_para_rec.gl_date_to := p_gl_date_to;
    l_para_rec.batch_status := p_batch_status;
    l_para_rec.transaction_status := p_transaction_status;
    l_para_rec.trx_type_id := p_trx_type_id;
    l_para_rec.currency_code := p_currency_code;
    l_para_rec.account_type := p_acc_type;
    l_para_rec.rec_account_from :=p_rec_account_from;
    l_para_rec.rec_account_to := p_rec_account_to;
    l_para_rec.pay_account_from:=p_pay_account_from;
    l_para_rec.pay_account_to:= p_pay_account_to;
    l_para_rec.init_dist_acc_from:= p_init_d_account_from;
    l_para_rec.init_dist_acc_to:=p_init_d_account_to;
    l_para_rec.rec_dist_acc_from:=p_recip_d_account_from;
    l_para_rec.rec_dist_acc_to:=p_recip_d_account_to;
    l_para_rec.ar_invoice_number := p_ar_invoice_number;
    l_para_rec.coa_initiator:= p_coa_initiator;
    l_para_rec.coa_recipient:=p_coa_recipient;


    -- Based on batch type, build the query to get inbound, outbound or both
    -- transactions
    l_progress := '030';



    IF (p_batch_type = 'BOTH') THEN
        FUN_UTIL.log_conc_stmt(
            g_pkg_name, l_api_name, l_progress, '', 'call build_account_outquery');
        build_account_outquery(
            x_return_status  => l_return_status,
            p_para_rec       => l_para_rec,
            x_outbound_query => l_outbound_query
        );

        FUN_UTIL.log_conc_stmt(
            g_pkg_name, l_api_name, l_progress, '', 'call build_account_inquery');
        build_account_inquery(
            x_return_status  => l_return_status,
            p_para_rec       => l_para_rec,
            x_inbound_query  => l_inbound_query
        );
    ELSIF (p_batch_type = 'IN') THEN
        FUN_UTIL.log_conc_stmt(
            g_pkg_name, l_api_name, l_progress, '', 'call build_account_inquery');
        build_account_inquery(
            x_return_status  => l_return_status,
            p_para_rec       => l_para_rec,
            x_inbound_query  => l_inbound_query
        );
    ELSIF (p_batch_type = 'OUT') THEN
        FUN_UTIL.log_conc_stmt(
            g_pkg_name, l_api_name, l_progress, '', 'call build_account_outquery');
        build_account_outquery(
            x_return_status  => l_return_status,
            p_para_rec       => l_para_rec,
            x_outbound_query => l_outbound_query
        );
    ELSE
        FUN_UTIL.log_conc_stmt(
            g_pkg_name, l_api_name, l_progress, 'batch type is incorrect');
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

   if (l_outbound_query IS NULL) THEN
     l_query:=l_inbound_query;
   elsif (l_inbound_query IS NULL) THEN
     l_query:=l_outbound_query;
   else
      l_query:= l_outbound_query||' union '||l_inbound_query;
   end if;


    -- Get the XML data source
    l_progress := '040';

       get_xml(
            x_return_status => l_return_status,
            p_query         => l_query,
            p_rowset_tag    => 'TRANSACTION_BATCHES',
            p_row_tag       => 'BATCH',
            x_xml           => l_trxs
        );
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    -- Manupulate XML data source to XML Publisher compatiable format
    -- and save it to output file
    l_progress := '050';
    FUN_UTIL.log_conc_stmt(
        g_pkg_name, l_api_name, l_progress, '', 'call construct_account_output');
    construct_account_output(
        x_return_status => l_return_status,
        p_para_rec      => l_para_rec,
        p_trxs => l_trxs
    );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    FUN_UTIL.log_conc_end(g_pkg_name, l_api_name);

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        retcode := 2;
        FUN_UTIL.log_conc_err(
            g_pkg_name, l_api_name, l_progress, 'error in create_accountreport');
    WHEN FND_API.G_EXC_ERROR THEN
        retcode := 2;
        FUN_UTIL.log_conc_unexp(
            g_pkg_name, l_api_name, l_progress);
        FUN_UTIL.log_conc_err(
            g_pkg_name, l_api_name, l_progress, 'error in create_accountreport');
    WHEN OTHERS THEN
        retcode := 2;
        FUN_UTIL.log_conc_err(
            g_pkg_name, l_api_name, l_progress, 'error in create_accountreport');
END create_accountreport;

END FUN_REPORT_PVT;



/
