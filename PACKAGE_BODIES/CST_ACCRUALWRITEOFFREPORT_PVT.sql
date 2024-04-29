--------------------------------------------------------
--  DDL for Package Body CST_ACCRUALWRITEOFFREPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_ACCRUALWRITEOFFREPORT_PVT" AS
/* $Header: CSTVAWOB.pls 120.21.12010000.5 2010/04/23 13:45:19 mpuranik ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'CST_AccrualWriteOffReport_PVT';
G_LOG_HEADER CONSTANT VARCHAR2(100) := 'cst.plsql.CST_ACCRUAL_MISC_REPORT';
G_LOG_LEVEL CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

PROCEDURE Generate_WriteOffReportXml (
                errcode                 OUT NOCOPY      VARCHAR2,
                err_code                OUT NOCOPY      NUMBER,

                p_Chart_of_accounts_id  IN              NUMBER,
                p_bal_seg_val           IN              NUMBER,
                p_title                 IN              VARCHAR2,
                p_bal_segment_from      IN              VARCHAR2,
                p_bal_segment_to        IN              VARCHAR2,
                p_from_write_off_date   IN              VARCHAR2,
                p_to_write_off_date     IN              VARCHAR2,
                p_from_amount           IN              NUMBER,
                p_to_amount             IN              NUMBER,
                p_reason                IN              NUMBER,
                p_comments              IN              VARCHAR2,
                p_sort_by               IN              VARCHAR2  )
IS

        l_api_name      CONSTANT        VARCHAR2(100)   := 'Generate_WriteOffReportXml';
        l_api_version   CONSTANT        NUMBER          := 1.0;
        l_qryCtx                        NUMBER;
        l_ref_cur                       SYS_REFCURSOR;
        l_xml_doc                       CLOB;
        l_amount                        NUMBER ;
        l_offset                        NUMBER ;
        l_buffer                        VARCHAR2(32767);
        l_length                        NUMBER;
        l_from_write_off_date           DATE;
        l_to_write_off_date             DATE;

        l_return_status                 VARCHAR2(1);
        l_msg_count                     NUMBER;
        l_msg_data                      VARCHAR2(2000);
        l_stmt_num                      NUMBER;
        l_success                       BOOLEAN;
        l_current_org_id                NUMBER;
        l_error_message                 VARCHAR2(300);

        l_full_name     CONSTANT        VARCHAR2(2000)  := G_PKG_NAME || '.' || l_api_name;
        l_module        CONSTANT        VARCHAR2(2000)  := 'cst.plsql.' || l_full_name;

        l_uLog          CONSTANT        BOOLEAN         := FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL AND FND_LOG.TEST (FND_LOG.LEVEL_UNEXPECTED, l_module);
        l_errorLog      CONSTANT        BOOLEAN         := l_uLog AND (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
        l_eventLog      CONSTANT        BOOLEAN         := l_errorLog AND (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
        l_pLog          CONSTANT        BOOLEAN         := l_eventLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
        l_sLog         CONSTANT  BOOLEAN := l_pLog and (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

        l_conc_request         BOOLEAN;
	/*Bug 7305146*/
	l_encoding             VARCHAR2(20);
	l_xml_header           VARCHAR2(100);
 BEGIN

-- Initialze variables
        l_amount := 16383;
        l_offset := 1;
        l_return_status := fnd_api.g_ret_sts_success;
        l_msg_count := 0;

  -- select the operating unit for which the program is launched.

l_stmt_num := 5;

        l_current_org_id := MO_GLOBAL.get_current_org_id;

 -- Write the module name and user parameters to fnd log file

        IF (l_pLog) THEN
                FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                                l_module || '.begin',
                                '>>> ' || l_api_name || ':Parameters:
                                Org id:'||  l_current_org_id
                                || 'Title: '  || p_title
                                || 'Sort Option: ' || p_sort_by
                                || ' From Date: ' || p_from_write_off_date
                                || ' To Date: ' || p_to_write_off_date
                                || ' Reason: ' || p_reason
                                || ' Comments: ' || p_comments
                                || ' Min Amount: ' || p_from_amount
                                || ' Max Amount: ' || p_to_amount
                                || ' Balancing Segment From: ' || p_bal_segment_from
                                || ' Balancing Segment To: ' || p_bal_segment_to);

          END IF;


l_stmt_num := 10;

  /* check if to_date is greater than or equal to from_date */

 If (p_from_write_off_date is not null and p_to_write_off_date < p_from_write_off_date ) then

      l_error_message := 'CST_INVALID_TO_DATE';
      fnd_message.set_name('BOM','CST_INVALID_TO_DATE');
      RAISE fnd_api.g_exc_error;
    End If;

    l_stmt_num := 20;

 /* check if to_amount is greater than or equal to from_amount */

 If (p_from_amount is not null and p_to_amount < p_from_amount ) then

      l_error_message := 'CST_INVALID_TO_AMOUNT';
      fnd_message.set_name('BOM','CST_INVALID_TO_AMOUNT');
      RAISE fnd_api.g_exc_error;
    End If;

-- Initialze variables for storing XML Data

          DBMS_LOB.createtemporary(l_xml_doc, TRUE);

	  /*Bug 7305146*/
	  l_encoding       := fnd_profile.value('ICX_CLIENT_IANA_ENCODING');
	  l_xml_header     := '<?xml version="1.0" encoding="'|| l_encoding ||'"?>';
	  DBMS_LOB.writeappend (l_xml_doc, length(l_xml_header), l_xml_header);

          DBMS_LOB.writeappend (l_xml_doc, 8, '<REPORT>');

-- convert from date parameter to date type variable

l_stmt_num := 30;

        IF (p_from_write_off_date IS NOT NULL) THEN
                l_from_write_off_date := FND_DATE.canonical_to_date(p_from_write_off_date);
        ELSE
                l_from_write_off_date := NULL;
        END IF;

-- convert to date parameter to date type variable

l_stmt_num := 40;

        IF (p_to_write_off_date IS NOT NULL) THEN
                l_to_write_off_date := FND_DATE.canonical_to_date(p_to_write_off_date );
        ELSE
                l_to_write_off_date := NULL;
        END IF;


-- Initialize message stack

        FND_MSG_PUB.initialize;

-- Standard call to get message count and if count is 1, get message info.

        FND_MSG_PUB.Count_And_Get
        (       p_count         =>      l_msg_count,
                p_data          =>      l_msg_data
        );

/*========================================================================*/
-- Call to Procedure Add Parameters. To Add user entered Parameters to
-- XML data
/*========================================================================*/

l_stmt_num := 50;

        Add_Parameters  (p_api_version          => l_api_version,
                         p_init_msg_list        => FND_API.G_FALSE,
                         p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
                         x_return_status        => l_return_status,
                         x_msg_count            => l_msg_count,
                         x_msg_data             => l_msg_data,
                         i_title                => p_title,
                         i_from_write_off_date  => l_from_write_off_date,
                         i_to_write_off_date    => l_to_write_off_date,
                         i_reason               => p_reason,
                         i_comments             => p_comments ,
                         i_from_amount          => p_from_amount,
                         i_to_amount            => p_to_amount,
                         i_sort_by              => p_sort_by,
                         i_bal_segment_from     => p_bal_segment_from  ,
                         i_bal_segment_to       => p_bal_segment_to ,
                         x_xml_doc              => l_xml_doc);

-- Standard call to check the return status from API called

IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

/*========================================================================*/
-- Call to Procedure Add Parameters. To add write off data to XML data
/*========================================================================*/

l_stmt_num := 60;

        Add_WriteOffData (p_api_version         => l_api_version,
                          p_init_msg_list       => FND_API.G_FALSE,
                          p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
                          x_return_status       => l_return_status,
                          x_msg_count           => l_msg_count,
                          x_msg_data            => l_msg_data,
                          i_title               => p_title,
                          i_from_write_off_date => l_from_write_off_date,
                          i_to_write_off_date   => l_to_write_off_date,
                          i_reason              => p_reason,
                          i_comments            => p_comments ,
                          i_from_amount         => p_from_amount,
                          i_to_amount           => p_to_amount,
                          i_sort_by             => p_sort_by,
                          i_bal_segment_from    => p_bal_segment_from  ,
                          i_bal_segment_to      => p_bal_segment_to ,
                          x_xml_doc             => l_xml_doc);

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

        DBMS_XMLGEN.closeContext(l_qryCtx);

-- Write the event log to fnd log file

        IF (l_eventLog) THEN
                FND_LOG.STRING (FND_LOG.LEVEL_EVENT,
                                l_module || '.' || l_stmt_num,
                                'Completed writing to output file');
        END IF;

-- free temporary memory
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
   ROLLBACK;
   l_return_status := FND_API.g_ret_sts_error;
   If l_errorLog then
     fnd_log.message(FND_LOG.LEVEL_ERROR,
                    G_LOG_HEADER || '.' || l_api_name || '(' ||to_char(l_stmt_num)||')',
                    FALSE
                    );
   end If;

   fnd_msg_pub.add;

   If l_slog then
     fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                    G_LOG_HEADER || '.'||l_api_name||'('||to_char(l_stmt_num)||')',
                    l_error_message
                   );
   End If;

   FND_MSG_PUB.count_and_get
             (  p_count => l_msg_count
              , p_data  => l_msg_data
              );


 CST_UTILITY_PUB.writelogmessages
                (       p_api_version   => l_api_version,
                        p_msg_count     => l_msg_count,
                        p_msg_data      => l_msg_data,
                        x_return_status => l_return_status);

                l_msg_data      := SUBSTRB (SQLERRM,1,240);
                l_success       := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', l_msg_data);

   l_conc_request := fnd_concurrent.set_completion_status('ERROR',substr(fnd_message.get_string('BOM',l_error_message),1,240));

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                FND_MSG_PUB.Count_And_Get
                (       p_count => l_msg_count,
                        p_data  => l_msg_data
                );

                CST_UTILITY_PUB.writelogmessages
                (       p_api_version   => l_api_version,
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
                (       p_api_version   => 1.0,
                        p_msg_count     => l_msg_count,
                        p_msg_data      => l_msg_data,
                        x_return_status => l_return_status);

                l_msg_data      := SUBSTRB (SQLERRM,1,240);
                l_success       := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', l_msg_data);

END Generate_WriteOffReportXml;

PROCEDURE Add_Parameters
                (p_api_version          IN              NUMBER,
                p_init_msg_list         IN              VARCHAR2 ,
                p_validation_level      IN              NUMBER,

                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,

                i_title                 IN              VARCHAR2,
                i_from_write_off_date   IN              DATE,
                i_to_write_off_date     IN              DATE,
                i_reason                IN              NUMBER,
                i_comments              IN              VARCHAR2,
                i_from_amount           IN              NUMBER,
                i_to_amount             IN              NUMBER,
                i_sort_by               IN              VARCHAR2,
                i_bal_segment_from      IN              VARCHAR2 ,
                i_bal_segment_to        IN              VARCHAR2 ,

                x_xml_doc               IN OUT NOCOPY   CLOB)
IS

        l_api_name      CONSTANT        VARCHAR2(30)    := 'ADD_PARAMETERS';
        l_api_version   CONSTANT        NUMBER          := 1.0;

        l_ref_cur                       SYS_REFCURSOR;
        l_qryCtx                        NUMBER;
        l_xml_temp                      CLOB;
        l_offset                        PLS_INTEGER;
        l_org_code                      VARCHAR2(300);
        l_org_name                      VARCHAR2(300);
        l_reason                        VARCHAR2(2000);
        l_stmt_num                      NUMBER;
        l_current_org_id                NUMBER;

        l_full_name     CONSTANT        VARCHAR2(2000)  := G_PKG_NAME || '.' || l_api_name;
        l_module        CONSTANT        VARCHAR2(2000)  := 'cst.plsql.' || l_full_name;

        l_uLog          CONSTANT        BOOLEAN         := FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL AND FND_LOG.TEST (FND_LOG.LEVEL_UNEXPECTED, l_module);
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

-- select the reason name for the user entered user id

l_stmt_num := 20;

        IF (i_reason IS NULL) THEN
                l_reason := NULL;
        ELSE
                SELECT mtr.reason_name
                INTO l_reason
                FROM  mtl_transaction_reasons     mtr
                WHERE mtr.reason_id = i_reason;
        END IF;
  -- select the operating unit code for which the program is launched.

l_stmt_num := 30;

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

l_stmt_num := 40;

        select hr.NAME
        into   l_org_name
        from   HR_ALL_ORGANIZATION_UNITS       hr
        where  hr.ORGANIZATION_ID  = l_current_org_id;

-- Open Ref Cursor to collect the report parameters

l_stmt_num := 50;

        OPEN l_ref_cur FOR 'SELECT  :l_org_code                         org_code,
                                    :l_org_name                         org_name,
                                    xla.NAME                            ledger_name,
                                    xla.currency_code                   CUR_CODE,
                                    :i_title                            TITLE_NAME,
                                    :i_from_write_off_date              from_write_date,
                                    :i_to_write_off_date                to_write_date,
                                    :l_reason                           reason_name,
                                    decode(:i_comments, ''N'', ''No'',
                                            ''Yes'')                    comments,
                                    :i_from_amount                      min_amount,
                                    :i_to_amount                        max_amount,
                                    crs.displayed_field                 sort_option,
                                    :i_bal_segment_from                 bal_seg_from,
                                    :i_bal_segment_to                   bal_seg_to
                            FROM    cst_reconciliation_codes             crs,
                                    XLA_GL_LEDGERS_V                     xla,
                                    HR_ORGANIZATION_INFORMATION          hoi
                            WHERE   hoi.ORGANIZATION_ID = :l_current_org_id
                            and     hoi.ORG_INFORMATION_CONTEXT = ''Operating Unit Information''
                            and     xla.LEDGER_ID = hoi.ORG_INFORMATION3
                            AND     crs.lookup_type = ''SRS ACCRUAL ORDER BY''
                            AND     crs.LOOKUP_CODE = :i_sort_by'
                            USING   l_org_code,
                                    l_org_name,
                                    i_title,
                                    i_from_write_off_date  ,
                                    i_to_write_off_date  ,
                                    l_reason,
                                    i_comments ,
                                    i_from_amount ,
                                    i_to_amount ,
                                    i_bal_segment_from,
                                    i_bal_segment_to,
                                    l_current_org_id,
                                    i_sort_by;

-- create new context

l_stmt_num := 60;

        l_qryCtx := DBMS_XMLGEN.newContext (l_ref_cur);
        DBMS_XMLGEN.setRowSetTag (l_qryCtx,'PARAMETERS');
        DBMS_XMLGEN.setRowTag (l_qryCtx,NULL);

-- get XML into the temporary clob variable

l_stmt_num := 70;

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
        (       p_count                 =>      x_msg_count,
                p_data                  =>      x_msg_data
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

PROCEDURE Add_WriteOffData
                (p_api_version          IN              NUMBER,
                p_init_msg_list         IN              VARCHAR2 ,
                p_validation_level      IN              NUMBER  ,

                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,

                i_title                 IN              VARCHAR2,
                i_from_write_off_date   IN              DATE,
                i_to_write_off_date     IN              DATE,
                i_reason                IN              NUMBER,
                i_comments              IN              VARCHAR2,
                i_from_amount           IN              NUMBER,
                i_to_amount             IN              NUMBER,
                i_sort_by               IN              VARCHAR2,
                i_bal_segment_from      IN              VARCHAR2 ,
                i_bal_segment_to        IN              VARCHAR2 ,

                x_xml_doc               IN OUT NOCOPY   CLOB)
IS

        l_api_name      CONSTANT        VARCHAR2(30)    := 'WRITE_OFF_DATA';
        l_api_version   CONSTANT        NUMBER          := 1.0;

        l_ref_cur                       SYS_REFCURSOR;
        l_qryCtx                        NUMBER;
        l_xml_temp                      CLOB;
        l_offset                        PLS_INTEGER;
        l_bal_segment                   VARCHAR2(50);
        l_count                         NUMBER;
        l_stmt_num                      NUMBER;
        l_current_org_id                NUMBER;
        l_account_range                 NUMBER;
        l_currency                      VARCHAR2(50);

        l_full_name     CONSTANT        VARCHAR2(2000)  := G_PKG_NAME || '.' || l_api_name;
        l_module        CONSTANT        VARCHAR2(2000)  := 'cst.plsql.' || l_full_name;

        l_uLog          CONSTANT        BOOLEAN         := FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL AND FND_LOG.TEST (FND_LOG.LEVEL_UNEXPECTED, l_module);
        l_errorLog      CONSTANT        BOOLEAN         := l_uLog AND (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
        l_eventLog      CONSTANT        BOOLEAN         := l_errorLog AND (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
        l_pLog          CONSTANT        BOOLEAN         := l_eventLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);

BEGIN

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

-- select the currency code

select   xla.currency_code
into     l_currency
from     XLA_GL_LEDGERS_V                             xla,
         HR_ORGANIZATION_INFORMATION                  hoi
where    hoi.ORGANIZATION_ID = l_current_org_id
and      hoi.ORG_INFORMATION_CONTEXT = 'Operating Unit Information'
and      xla.LEDGER_ID = hoi.ORG_INFORMATION3;

-- open ref cur to fetch write off data

l_stmt_num := 30;

 OPEN l_ref_cur FOR 'SELECT     gcc.concatenated_segments               account,
                                cwo.write_off_id                        write_off_id,
                                cwo.write_off_amount                    write_off_amount,
                                cwo.transaction_date                    write_off_date,
                                (SELECT gcc2.concatenated_segments
                                FROM    gl_code_combinations_kfv gcc2,
                                        cst_write_offs cwo2
                                WHERE   cwo2.offset_account_id  =
                                            gcc2.code_combination_id
                                AND     cwo2.accrual_account_id =
                                            cwo.accrual_account_id
                                AND     cwo2.write_off_id =
                                            cwo.write_off_id
                                AND     cwo2.offset_account_id =
                                            cwo.offset_account_id)      offset_account,
                                decode ( cwo.transaction_type_code,
                                        ''REVERSE WRITE OFF'',
                                        cwo.reversal_id,
                                        NULL)                           reversal_id,
                                decode(cwo.inventory_item_id, null, null,
                                           (select msi.concatenated_segments from
                                            mtl_system_items_vl msi
                                            where inventory_item_id = cwo.inventory_item_id
                                           and rownum <2)
                                           )                            item,
                               decode (cwod.write_off_transaction_id,
                                        NULL,
                                        decode(cwod.inventory_transaction_id,
                                                NULL,
                                                decode( cwod.invoice_distribution_id,
                                                        NULL,
                                                        pol.UNIT_MEAS_LOOKUP_CODE,
                                                        pol.UNIT_MEAS_LOOKUP_CODE),
                                                mmt.TRANSACTION_UOM),
                                        null)                                        uom,
                                pdt.displayed_field                        destination,
                                pov.vendor_name                         vendor,
                                mtr.reason_name                         reason,
                                :l_currency                             l_currency,
                                decode( :i_comments,
                                        ''Y'',
                                        cwo.comments,
                                        NULL)                           comments,
                                NVL(poh.CLM_DOCUMENT_NUMBER,poh.SEGMENT1)                            po_number,--Changed as a part of CLM
                                por.release_num                         po_release,
				nvl(POL.LINE_NUM_DISPLAY, to_char(POL.LINE_NUM))                           po_line,--Changed as a part of CLM
                                poll.shipment_num                       po_shipment,
                                pod.distribution_num                    po_distribution,
                                cwo.po_distribution_id                  po_distribution_id,
                                decode (cwod.write_off_transaction_id,
                                        NULL,
                                        decode(cwod.inventory_transaction_id,
                                                NULL,
                                                decode( cwod.invoice_distribution_id,
                                                        NULL,
                                                        ''PO'',
                                                        ''AP''),
                                                ''INV''),
                                        ''WO'')                         transaction_source,
                                decode( cwod.inventory_transaction_id,
                                NULL,
                                (SELECT crc2.displayed_field
                                FROM cst_reconciliation_codes crc2
                                WHERE to_char(crc2.lookup_code) =
                                        to_char(cwod.transaction_type_code)
                                AND crc2.lookup_type IN
                                        ( ''RCV TRANSACTION TYPE'',
                                        ''ACCRUAL WRITE-OFF ACTION'',
                                        ''ACCRUAL TYPE'') ) ,
                                (SELECT mtt.transaction_type_name
                                 FROM mtl_transaction_types          mtt
                                 WHERE to_char(mtt.transaction_type_id) =
                                           to_char(cwod.transaction_type_code)
                                       ))                               transaction_type,
                                cwod.transaction_date                   transaction_date,
                                cwod.quantity                           quantity,
				decode ( cwo.transaction_type_code,
                                        ''REVERSE WRITE OFF'',
                                        cwod.amount,
                                        (-1*cwod.amount))               abs_amount,
                                cwod.amount                             amount,
                                cwod.entered_amount                     entered_amount,
                                cwod.currency_code                      currency_code,
                                apia.invoice_num                        invoice_number,
                                aida.distribution_line_number           invoice_line,
                                rsh.receipt_num                         receipt_number,
                                cwod.inventory_transaction_id           inventory_transaction_id,
                                cwod.write_off_transaction_id           write_off_trans_id,
                                mp.organization_code                    org
                     FROM       cst_write_offs                          cwo,
                                po_vendors                              pov,
                                mtl_transaction_reasons                 mtr,
                                po_headers_all                          poh,
                                po_lines_all                            pol,
                                po_releases_all                         por,
                                po_line_locations_all                   poll,
                                po_distributions_all                    pod,
                                cst_write_off_details                   cwod,
                                ap_invoices_all                         apia,
                                ap_invoice_distributions_all            aida,
                                rcv_transactions                        rct,
                                rcv_shipment_headers                    rsh,
                                mtl_parameters                          mp,
                                po_destination_types_all_v              pdt,
                                gl_code_combinations_kfv                gcc,
				mtl_material_transactions               mmt
                     WHERE      cwo.write_off_id = cwod.write_off_id
                     AND        pov.vendor_id(+) = cwo.vendor_id
                     AND        mtr.reason_id(+) = cwo.reason_id
                     AND        pod.po_distribution_id(+) = cwo.po_distribution_id
                     AND        poll.line_location_id(+) = pod.line_location_id
                     AND        pol.po_line_id(+) = pod.po_line_id
                     AND        por.po_release_id(+) = pod.po_release_id
                     AND        poh.po_header_id(+) = pod.po_header_id
                     AND        cwod.invoice_distribution_id = aida.invoice_distribution_id (+)
                     AND        apia.invoice_id(+) = aida.invoice_id
                     AND        cwod.rcv_transaction_id = rct.transaction_id(+)
                     AND        rsh.shipment_header_id(+) = rct.shipment_header_id
                     AND        pdt.lookup_code(+) = cwo.destination_type_code
                     AND        cwod.inventory_organization_id = mp.organization_id(+)
		     and        cwod.inventory_transaction_id = mmt.transaction_id (+)
                     AND        cwo.accrual_account_id  = gcc.code_combination_id
                     AND        cwo.operating_unit_id = :l_current_org_id
                     AND        cwod.operating_unit_id = :l_current_org_id
                     AND        cwo.WRITE_OFF_AMOUNT
                                BETWEEN nvl(:i_from_amount,cwo.WRITE_OFF_AMOUNT)
                                AND nvl(:i_to_amount,cwo.WRITE_OFF_AMOUNT)
                     AND        cwo.transaction_date
                                BETWEEN nvl( :i_from_write_off_date,cwo.transaction_date )
                                AND nvl(:i_to_write_off_date ,cwo.transaction_date )
                     AND        nvl(:i_reason ,nvl(cwo.reason_id,-1)) = nvl(cwo.reason_id,-1)
                     AND       (( :l_account_range = 0 )
                                                OR (  :l_account_range = 1 AND
                                                      gcc.' || l_bal_segment || ' >=  :i_bal_segment_from)
                                                OR  (  :l_account_range = 2 AND
                                                      gcc.' || l_bal_segment || ' <=  :i_bal_segment_to)
                                                OR (  :l_account_range = 3 AND
                                                      gcc.' || l_bal_segment || ' BETWEEN :i_bal_segment_from
                                                AND :i_bal_segment_to   )    )
                     ORDER BY   decode( :i_sort_by ,
                                        ''REASON'',mtr.reason_name,
                                        ''AMOUNT'', decode(sign(write_off_amount),-1,
                                                                   chr(0) || translate( to_char(abs(write_off_amount), ''000000000999.999''),
                                                                    ''0123456789'', ''9876543210''), to_char(write_off_amount, ''000000000999.999'' ) ),
                                        ''OFFSET ACCOUNT'', cwo.offset_account_id,
                                        ''DATE'', to_char(transaction_date, ''yyyymmddhh24miss'')) '
                     USING      l_currency,
                                i_comments,
                                l_current_org_id,
                                l_current_org_id,
                                i_from_amount,
                                i_to_amount,
                                i_from_write_off_date,
                                i_to_write_off_date,
                                i_reason,
                                l_account_range,
                                l_account_range,
                                i_bal_segment_from,
                                l_account_range,
                                i_bal_segment_to,
                                l_account_range,
                                i_bal_segment_from,
                                i_bal_segment_to,
                                i_sort_by;

-- create new context

l_stmt_num := 40;

        l_qryCtx := DBMS_XMLGEN.newContext (l_ref_cur);
        DBMS_XMLGEN.setRowSetTag (l_qryCtx,'WRITE_OFF_DATA');
        DBMS_XMLGEN.setRowTag (l_qryCtx,'WRITE_OFF');

--  get XML into the temporary clob variable

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

        OPEN l_ref_cur FOR  SELECT  l_count l_count FROM dual ;

-- create new context

l_stmt_num := 70;

        l_qryCtx := DBMS_XMLGEN.newContext (l_ref_cur);
        DBMS_XMLGEN.setRowSetTag (l_qryCtx,'RECORD_NUM');
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
        (       p_count                 =>      x_msg_count,
                p_data                  =>      x_msg_data
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

END Add_WriteOffData;

END CST_AccrualWriteOffReport_PVT ;

/
