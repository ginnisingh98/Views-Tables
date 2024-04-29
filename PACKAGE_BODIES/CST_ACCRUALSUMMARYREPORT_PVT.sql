--------------------------------------------------------
--  DDL for Package Body CST_ACCRUALSUMMARYREPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_ACCRUALSUMMARYREPORT_PVT" AS
/* $Header: CSTVASRB.pls 120.14.12010000.2 2008/10/30 13:55:39 svelumur ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'CST_AccrualSummaryReport_PVT';
G_LOG_LEVEL CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

PROCEDURE Generate_SummaryReportXml (
                errcode                 OUT NOCOPY      VARCHAR2,
                errno                   OUT NOCOPY      NUMBER,

                p_Chart_of_accounts_id  IN              NUMBER,
                p_bal_seg_val           IN              NUMBER,
                p_title                 IN              VARCHAR2,
                p_bal_segment_from      IN              VARCHAR2,
                p_bal_segment_to        IN              VARCHAR2 )
 IS

        l_api_name      CONSTANT        VARCHAR2(100)   := 'Generate_SummaryReportXml';
        l_api_version   CONSTANT        NUMBER          := 1.0;

        l_xml_doc                       CLOB;
        l_qryCtx                        NUMBER;
        l_amount                        NUMBER ;
        l_offset                        NUMBER ;
        l_length                        NUMBER;
        l_offset_val                    PLS_INTEGER;
        l_buffer                        VARCHAR2(32767);
        l_msg_count                     NUMBER;
        l_stmt_num                      NUMBER;
        l_success                       BOOLEAN;
        l_return_status                 VARCHAR2(1);
        l_msg_data                      VARCHAR2(2000);
        l_current_org_id                NUMBER;

        l_full_name     CONSTANT        VARCHAR2(2000)  := G_PKG_NAME || '.' || l_api_name;
        l_module        CONSTANT        VARCHAR2(2000)  := 'cst.plsql.' || l_full_name;

         l_uLog          CONSTANT        BOOLEAN         := FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL AND FND_LOG.TEST (FND_LOG.LEVEL_UNEXPECTED,
l_module);
        l_errorLog      CONSTANT        BOOLEAN         := l_uLog AND (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
        l_eventLog      CONSTANT        BOOLEAN         := l_errorLog AND (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
        l_pLog          CONSTANT        BOOLEAN         := l_eventLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
	/*Bug 7305146*/
	l_encoding             VARCHAR2(20);
	l_xml_header           VARCHAR2(100);

 BEGIN

-- Initialze variables
        l_amount := 16383;
        l_offset := 1;
        l_msg_count := 0;
        l_offset_val := 21;

-- select the operating unit for which the program is launched.

l_stmt_num := 10;

        l_current_org_id := MO_GLOBAL.get_current_org_id;

 -- Write the module name and user parameters to fnd log file

        IF (l_pLog) THEN
                FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                                l_module || '.begin',
                                '>>> ' || l_api_name || ':Parameters:
                                Org id:'||  l_current_org_id
                                || 'Title: '  || p_title
                                || ' Balancing Segment From: ' || p_bal_segment_from
                                || ' Balancing Segment To: ' || p_bal_segment_to );

        END IF;

-- Initialze variables for storing XML Data

        DBMS_LOB.createtemporary(l_xml_doc, TRUE);

	/*Bug 7305146*/
	l_encoding       := fnd_profile.value('ICX_CLIENT_IANA_ENCODING');
	l_xml_header     := '<?xml version="1.0" encoding="'|| l_encoding ||'"?>';
	DBMS_LOB.writeappend (l_xml_doc, length(l_xml_header), l_xml_header);

        DBMS_LOB.writeappend (l_xml_doc, 8, '<REPORT>');

-- Initialize message stack
        FND_MSG_PUB.initialize;

-- Standard call to get message count and if count is 1, get message info.

        FND_MSG_PUB.Count_And_Get
        (       p_count    =>      l_msg_count,
                p_data     =>      l_msg_data
        );

/*========================================================================*/
-- Call to Procedure Add Parameters. To Add user entered Parameters to
-- XML data
/*========================================================================*/

l_stmt_num := 20;

        Add_Parameters  (p_api_version          => l_api_version,
                         x_return_status        => l_return_status,
                         p_init_msg_list        => FND_API.G_FALSE,
                         p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
                         x_msg_count            => l_msg_count,
                         x_msg_data             => l_msg_data,
                         i_title                => p_title,
                         i_bal_segment_from     => p_bal_segment_from,
                         i_bal_segment_to       => p_bal_segment_to,
                         x_xml_doc              => l_xml_doc);

-- Standard call to check the return status from API called

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

/*========================================================================*/
-- Call to Procedure Add Parameters. To add summary data to XML data
/*========================================================================*/

l_stmt_num := 30;

        Add_SummaryData (p_api_version          => l_api_version,
                         p_init_msg_list        => FND_API.G_FALSE,
                         p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
                         x_return_status        => l_return_status,
                         x_msg_count            => l_msg_count,
                         x_msg_data             => l_msg_data,
                         i_title                => p_title,
                         i_bal_segment_from     => p_bal_segment_from,
                         i_bal_segment_to       => p_bal_segment_to,
                         x_xml_doc              => l_xml_doc);

-- Standard call to check the return status from API called

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

-- write the closing tag to the XML data

        DBMS_LOB.writeappend (l_xml_doc, 9, '</REPORT>');

-- write xml data to the output file

        l_length := nvl(dbms_lob.getlength(l_xml_doc),0);
        LOOP
                EXIT WHEN l_length <= 0;
                dbms_lob.read (l_xml_doc, l_amount, l_offset, l_buffer);
                FND_FILE.PUT (FND_FILE.OUTPUT, l_buffer);
                l_length := l_length - l_amount;
                l_offset := l_offset + l_amount;
        END LOOP;

-- Write the event log to fnd log file

        IF (l_eventLog) THEN
                FND_LOG.STRING (FND_LOG.LEVEL_EVENT,
                                l_module || '.' || l_stmt_num,
                                'Completed writing to output file');
        END IF;

-- free temporary memory

        DBMS_XMLGEN.closeContext(l_qryCtx);
        DBMS_LOB.FREETEMPORARY (l_xml_doc);

        l_success := FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL', 'Request Completed Successfully');

-- Write the module name to fnd log file

        IF (l_pLog) THEN
                FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                                l_module || '.end',
                                '<<< ' || l_api_name);
        END IF;

  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                l_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count     =>      l_msg_count,
                        p_data      =>      l_msg_data
                );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                FND_MSG_PUB.Count_And_Get
                (       p_count => l_msg_count,
                        p_data  => l_msg_data
                );

                CST_UTILITY_PUB.writelogmessages
                (       p_api_version   => 1.0,
                        p_msg_count     => l_msg_count,
                        p_msg_data      => l_msg_data,
                        x_return_status => l_return_status);

                l_msg_data      := SUBSTRB (SQLERRM,1,240);
                l_success       := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', l_msg_data);

        WHEN OTHERS THEN
                IF (l_uLog) THEN
                        FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED,
                        l_module || '.' || l_stmt_num,
                        SUBSTRB (SQLERRM , 1 , 240));
                END IF;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,l_api_name);
                END IF;

                FND_MSG_PUB.Count_And_Get
                (       p_count  =>  l_msg_count,
                        p_data   =>  l_msg_data
                );

                CST_UTILITY_PUB.writelogmessages
                (       p_api_version   => l_api_version,
                        p_msg_count     => l_msg_count,
                        p_msg_data      => l_msg_data,
                        x_return_status => l_return_status);

                l_msg_data      := SUBSTRB (SQLERRM,1,240);
                l_success       := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', l_msg_data);

END Generate_SummaryReportXml;

PROCEDURE Add_Parameters
                (p_api_version          IN              NUMBER,
                p_init_msg_list         IN              VARCHAR2 ,
                p_validation_level      IN              NUMBER,

                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,

                i_title                 IN              VARCHAR2,
                i_bal_segment_from      IN              VARCHAR2,
                i_bal_segment_to        IN              VARCHAR2,

                x_xml_doc               IN OUT NOCOPY   CLOB)
IS

        l_api_name      CONSTANT        VARCHAR2(30)    := 'add_parameters';
        l_api_version   CONSTANT        NUMBER := 1.0;

        l_ref_cur                       SYS_REFCURSOR;
        l_qryCtx                        NUMBER;
        l_xml_temp                      CLOB;
        l_offset                        PLS_INTEGER;
        l_org_code                      VARCHAR2(300);
        l_stmt_num                      NUMBER;
        l_current_org_id                NUMBER;
        l_org_name                      VARCHAR2(300);

        l_full_name     CONSTANT        VARCHAR2(2000)  := G_PKG_NAME || '.' || l_api_name;
        l_module        CONSTANT        VARCHAR2(2000)  := 'cst.plsql.' || l_full_name;

         l_uLog          CONSTANT        BOOLEAN         := FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL AND FND_LOG.TEST (FND_LOG.LEVEL_UNEXPECTED,
l_module);
        l_errorLog      CONSTANT        BOOLEAN         := l_uLog AND (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
        l_eventLog      CONSTANT        BOOLEAN         := l_errorLog AND (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
        l_pLog          CONSTANT        BOOLEAN         := l_eventLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);

BEGIN

-- Write the module name to fnd log file

        IF (l_pLog) THEN
                FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                l_module || '.begin',
                '>>> ' || l_api_name);
        END IF;

-- Standard call to check for call compatibility.

        IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                             p_api_version,
                                             l_api_name,
                                             G_PKG_NAME )
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

-- Initialize message list if p_init_msg_list is set to TRUE.

        IF FND_API.to_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;

--  Initialize API return status to success

        x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Initialize temporary variable to hold xml data

         DBMS_LOB.createtemporary(l_xml_temp, TRUE);
         l_offset := 21;

-- select the operating unit for which the program is launched.

l_stmt_num := 10;

        l_current_org_id := MO_GLOBAL.get_current_org_id;

-- select the operating unit code for which the program is launched.

l_stmt_num := 20;

        begin
        select mp.organization_code
        into   l_org_code
        from   mtl_parameters                  mp
        where  mp.organization_id  = l_current_org_id;

exception
when no_data_found then
l_org_code := NULL;

end;

-- select the operating unit name for which the program is launched.

l_stmt_num := 30;

        select hr.NAME
        into   l_org_name
        from   HR_ALL_ORGANIZATION_UNITS       hr
        where  hr.ORGANIZATION_ID  = l_current_org_id;

-- Open Ref Cursor to collect the report parameters

 l_stmt_num := 40;

        OPEN l_ref_cur FOR 'SELECT      :l_org_code                     org_code,
                                        :l_org_name                     org_name,
                                         xla.NAME                       ledger_name,
                                         xla.currency_code              CUR_CODE,
                                        :i_title                        TITLE_NAME,
                                        :i_bal_segment_from             from_seg,
                                        :i_bal_segment_to               to_seg
                            FROM        XLA_GL_LEDGERS_V                xla,
                                        HR_ORGANIZATION_INFORMATION     hoi
                            WHERE       hoi.ORGANIZATION_ID = :l_current_org_id
                            and         hoi.ORG_INFORMATION_CONTEXT = ''Operating Unit Information''
                            and         xla.LEDGER_ID = hoi.ORG_INFORMATION3 '
                            USING       l_org_code,
                                        l_org_name,
                                        i_title,
                                        i_bal_segment_from,
                                        i_bal_segment_to,
                                        l_current_org_id;


 -- create new context

l_stmt_num := 50;

        l_qryCtx := DBMS_XMLGEN.newContext (l_ref_cur);
        DBMS_XMLGEN.setRowSetTag (l_qryCtx,'PARAMETERS');
        DBMS_XMLGEN.setRowTag (l_qryCtx,NULL);

-- get XML into the temporary clob variable

l_stmt_num := 60;

        DBMS_XMLGEN.getXML (l_qryCtx, l_xml_temp, DBMS_XMLGEN.none);

-- remove the header (21 characters) and append the rest to xml output

        IF (DBMS_XMLGEN.getNumRowsProcessed(l_qryCtx) > 0) THEN
                DBMS_LOB.erase (l_xml_temp, l_offset,1);
                DBMS_LOB.append (x_xml_doc, l_xml_temp);
        END IF;

-- close context and free memory

        DBMS_XMLGEN.closeContext(l_qryCtx);
        CLOSE l_ref_cur;
        DBMS_LOB.FREETEMPORARY (l_xml_temp);

-- Standard call to get message count and if count is 1, get message info.

   FND_MSG_PUB.Count_And_Get
   (    p_count         =>       x_msg_count,
        p_data          =>       x_msg_data);

-- Write the module name to fnd log file

   IF (l_pLog) THEN
        FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                        l_module || '.end',
                        '<<< ' || l_api_name);
   END IF;

 EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count         =>      x_msg_count,
                        p_data          =>      x_msg_data
                );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count         =>      x_msg_count,
                        p_data          =>      x_msg_data
                );

        WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF (l_uLog) THEN
                        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                                       l_module || '.' || l_stmt_num,
                                       SUBSTRB (SQLERRM , 1 , 240));
                END IF;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                        FND_MSG_PUB.Add_Exc_Msg
                        (       G_PKG_NAME,
                                l_api_name
                        );
                END IF;

                FND_MSG_PUB.Count_And_Get
                (       p_count         =>      x_msg_count,
                        p_data          =>      x_msg_data
                );

END Add_Parameters;

PROCEDURE Add_SummaryData
                (p_api_version          IN              NUMBER,
                p_init_msg_list         IN              VARCHAR2 ,
                p_validation_level      IN              NUMBER,

                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,

                i_title                 IN              VARCHAR2,
                i_bal_segment_from      IN              VARCHAR2,
                i_bal_segment_to        IN              VARCHAR2,

                x_xml_doc               IN OUT NOCOPY   CLOB)
IS

        l_api_name      CONSTANT        VARCHAR2(30)    := 'SUMMARY_DATA';
        l_api_version   CONSTANT        NUMBER          := 1.0;
        l_ref_cur                       SYS_REFCURSOR;
        l_qryCtx                        NUMBER;
        l_xml_temp                      CLOB;
        l_offset                        PLS_INTEGER;
        l_bal_segment                   VARCHAR2(50);
        l_stmt_num                      NUMBER;
        l_count                         NUMBER;
        l_current_org_id                NUMBER;
        l_account_range                 NUMBER;

        l_full_name     CONSTANT        VARCHAR2(2000)  := G_PKG_NAME || '.' || l_api_name;
        l_module        CONSTANT        VARCHAR2(2000)  := 'cst.plsql.' || l_full_name;

        l_uLog          CONSTANT        BOOLEAN         := FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL AND FND_LOG.TEST (FND_LOG.LEVEL_UNEXPECTED,
l_module);
        l_errorLog      CONSTANT        BOOLEAN         := l_uLog AND (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
        l_eventLog      CONSTANT        BOOLEAN         := l_errorLog AND (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
        l_pLog          CONSTANT        BOOLEAN         := l_eventLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);

BEGIN

-- Write the module name to fnd log file

         IF (l_pLog) THEN
                FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                                l_module || '.begin',
                                '>>> ' || l_api_name);
         END IF;

-- Standard call to check for call compatibility.

        IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                             p_api_version,
                                             l_api_name,
                                             G_PKG_NAME )
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

-- Initialize message list if p_init_msg_list is set to TRUE.

        IF FND_API.to_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;

--  Initialize API return status to success

        x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Initialize temporary variable to hold xml data

        DBMS_LOB.createtemporary(l_xml_temp, TRUE);
        l_offset := 21;

-- select the operating unit for which the program is launched.

l_stmt_num := 10;

        l_current_org_id := MO_GLOBAL.get_current_org_id;


-- select the balancing segment value

l_stmt_num := 20;

        SELECT  fav.application_column_name
        INTO    l_bal_segment
        FROM    gl_sets_of_books                gl,
                fnd_segment_attribute_values    fav,
                hr_organization_information     hr
        WHERE   hr.org_information_context      = 'Operating Unit Information'
        AND     hr.organization_id              = l_current_org_id
        AND     to_number(hr.org_information3)  = gl.set_of_books_id
        AND     fav.segment_attribute_type      = 'GL_BALANCING'
        AND     fav.attribute_value             = 'Y'
        AND     fav.application_id              = 101
        AND     fav.id_flex_code                = 'GL#'
        AND     id_flex_num                     = gl.chart_of_accounts_id;


-- find if balancing segment range is given

 IF (  (i_bal_segment_from IS NULL)   AND   (i_bal_segment_to IS NULL)  ) THEN

       l_account_range := 0;

 ELSIF (  (i_bal_segment_from IS NOT NULL)   AND   (i_bal_segment_to IS NULL)  ) THEN

                l_account_range := 1;

         ELSIF (  (i_bal_segment_from IS NULL)   AND   (i_bal_segment_to IS NOT NULL)  ) THEN

                        l_account_range := 2;
         ELSE

                        l_account_range := 3;
END IF;



-- open ref cur to fetch summary data

l_stmt_num := 30;

      OPEN l_ref_cur FOR ' SELECT       account,
                                        transaction_type,
                                        amount_written_off,
                                        outstanding_balance
                           FROM
                                (SELECT         gcc.concatenated_segments       account,
                                                ''AP-PO''                       transaction_type,
                                                SUM(crs.write_off_balance)      amount_written_off,
                                                SUM(crs.ap_balance +
                                                crs.po_balance +
                                                crs.write_off_balance)          outstanding_balance
                                 FROM           cst_reconciliation_summary      crs,
                                                gl_code_combinations_kfv        gcc
                                 WHERE          crs.accrual_account_id = gcc.code_combination_id
                                 AND            crs.operating_unit_id  = :l_current_org_id
                                 AND            (( :l_account_range = 0 )
                                                OR (  :l_account_range = 1 AND
                                                      gcc.' || l_bal_segment || ' >=  :i_bal_segment_from)
                                                OR  (  :l_account_range = 2 AND
                                                      gcc.' || l_bal_segment || ' <=  :i_bal_segment_to)
                                                OR (  :l_account_range = 3 AND
                                                      gcc.' || l_bal_segment || ' BETWEEN :i_bal_segment_from
                                                AND :i_bal_segment_to   )    )
                                 GROUP BY       crs.accrual_account_id,
                                                gcc.concatenated_segments
                           UNION
                                  SELECT         gcc.concatenated_segments                      account,
                                              decode( cmr.transaction_type_code, ''CONSIGNMENT'',
                                                        (SELECT crc.displayed_field
                                                        FROM cst_reconciliation_codes crc
                                                        WHERE crc.lookup_code =
                                                             cmr.transaction_type_code
                                                        AND crc.lookup_type IN
                                                        ( ''ACCRUAL WRITE-OFF ACTION'',''ACCRUAL TYPE'' )  ) ,
                                                    decode (min(nvl(INVENTORY_TRANSACTION_ID,-1)),  -1,
                                                    (SELECT crc.displayed_field
                                                    FROM cst_reconciliation_codes crc
                                                    WHERE crc.lookup_code = cmr.transaction_type_code
                                                    AND crc.lookup_type IN
                                                    ( ''ACCRUAL WRITE-OFF ACTION'',''ACCRUAL TYPE'' )  ),
                                                    (SELECT mtt.transaction_type_name
                                                        FROM mtl_transaction_types      mtt
                                                        WHERE cmr.transaction_type_code =
                                                        to_char(mtt.transaction_type_id) ))) transaction_type,
                                                (select nvl(sum (cwo.write_off_amount) ,0)
                                                        from cst_write_offs         cwo ,
                                                             cst_write_off_details  cwod
                                                where  cwo.accrual_account_id =
                                                                cmr.accrual_account_id
                                                and    cmr.TRANSACTION_TYPE_CODE =
                                                                cwod.TRANSACTION_TYPE_CODE
                                                and    cwod.write_off_id =
                                                                cwo.write_off_id) amount_written_off,
                                                SUM(cmr.amount) outstanding_balance
                                FROM            gl_code_combinations_kfv        gcc,
                                                cst_misc_reconciliation         cmr
                                WHERE           cmr.accrual_account_id = gcc.code_combination_id
                                AND             cmr.operating_unit_id  = :l_current_org_id
                                AND            (( :l_account_range = 0 )
                                                OR (  :l_account_range = 1 AND
                                                      gcc.' || l_bal_segment || ' >=  :i_bal_segment_from)
                                                OR  (  :l_account_range = 2 AND
                                                      gcc.' || l_bal_segment || ' <=  :i_bal_segment_to)
                                                OR (  :l_account_range = 3 AND
                                                      gcc.' || l_bal_segment || ' BETWEEN :i_bal_segment_from
                                                AND :i_bal_segment_to   )    )
                               GROUP BY        cmr.accrual_account_id,
                                               gcc.concatenated_segments,
                                               cmr.transaction_type_code    )'
                                USING           l_current_org_id,
                                                l_account_range,
                                                l_account_range,
                                                i_bal_segment_from,
                                                l_account_range,
                                                i_bal_segment_to,
                                                l_account_range,
                                                i_bal_segment_from,
                                                i_bal_segment_to,
                                                l_current_org_id,
                                                l_account_range,
                                                l_account_range,
                                                i_bal_segment_from,
                                                l_account_range,
                                                i_bal_segment_to,
                                                l_account_range,
                                                i_bal_segment_from,
                                                i_bal_segment_to ;

-- create new context

l_stmt_num := 40;

        l_qryCtx := DBMS_XMLGEN.newContext (l_ref_cur);
        DBMS_XMLGEN.setRowSetTag (l_qryCtx,'SUMMARY_DATA');
        DBMS_XMLGEN.setRowTag (l_qryCtx,'SUMMARY');



-- get XML into the temporary clob variable

l_stmt_num := 50;

        DBMS_XMLGEN.getXML (l_qryCtx, l_xml_temp, DBMS_XMLGEN.none);

-- remove the header (21 characters) and append the rest to xml output

        l_count := DBMS_XMLGEN.getNumRowsProcessed(l_qryCtx);

        IF (DBMS_XMLGEN.getNumRowsProcessed(l_qryCtx) > 0) THEN
                DBMS_LOB.erase (l_xml_temp, l_offset,1);
                DBMS_LOB.append (x_xml_doc, l_xml_temp);
        END IF;

-- close context and free memory

        DBMS_XMLGEN.closeContext(l_qryCtx);
        CLOSE l_ref_cur;
        DBMS_LOB.FREETEMPORARY (l_xml_temp);

-- to add number of rows processed

        DBMS_LOB.createtemporary(l_xml_temp, TRUE);

-- open ref cursor to add number of rows processed

l_stmt_num := 60;

        OPEN l_ref_cur FOR  SELECT  l_count l_count FROM dual  ;

-- create new context

l_stmt_num := 70;

        l_qryCtx := DBMS_XMLGEN.newContext (l_ref_cur);
        DBMS_XMLGEN.setRowSetTag (l_qryCtx,'record_num');
        DBMS_XMLGEN.setRowTag (l_qryCtx,NULL);


-- get XML to add the number of rows processed

l_stmt_num := 80;

        DBMS_XMLGEN.getXML (l_qryCtx, l_xml_temp, DBMS_XMLGEN.none);

-- remove the header (21 characters) and append the rest to xml output

        IF ( DBMS_XMLGEN.getNumRowsProcessed(l_qryCtx) > 0 ) THEN
                DBMS_LOB.erase (l_xml_temp, l_offset,1);
                DBMS_LOB.append (x_xml_doc, l_xml_temp);
        END IF;

-- close context and free memory

        DBMS_XMLGEN.closeContext(l_qryCtx);
        CLOSE l_ref_cur;
        DBMS_LOB.FREETEMPORARY (l_xml_temp);

-- Standard call to get message count and if count is 1, get message info.

        FND_MSG_PUB.Count_And_Get
        (       p_count         =>      x_msg_count,
                p_data          =>      x_msg_data
        );

-- Write the module name to fnd log file

        IF (l_pLog) THEN
                FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                                l_module || '.end',
                                '<<< ' || l_api_name);
        END IF;

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count         =>      x_msg_count,
                        p_data          =>      x_msg_data
                );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count         =>      x_msg_count,
                        p_data          =>      x_msg_data);

        WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF (l_uLog) THEN
                        FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED,
                                        l_module || '.' || l_stmt_num,
                                        SUBSTRB (SQLERRM , 1 , 240));
                END IF;

          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
                  FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
          END IF;

          FND_MSG_PUB.Count_And_Get
          (     p_count         =>      x_msg_count,
                p_data          =>      x_msg_data
          );

END Add_SummaryData;


END CST_AccrualSummaryReport_PVT;

/
