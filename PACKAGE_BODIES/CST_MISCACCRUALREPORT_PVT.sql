--------------------------------------------------------
--  DDL for Package Body CST_MISCACCRUALREPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_MISCACCRUALREPORT_PVT" AS
/* $Header: CSTVAMRB.pls 120.20.12010000.4 2010/04/23 13:47:11 mpuranik ship $ */

G_PKG_NAME CONSTANT VARCHAR2(2000) := 'CST_MiscAccrualReport_PVT';
G_LOG_HEADER CONSTANT VARCHAR2(100) := 'cst.plsql.CST_ACCRUAL_MISC_REPORT';
G_LOG_LEVEL CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

PROCEDURE Generate_MiscReportXml (
                   errcode                      OUT NOCOPY      VARCHAR2,
                   errno                        OUT NOCOPY      NUMBER,

                   p_Chart_of_accounts_id       IN              NUMBER,
                   p_bal_seg_val                IN              NUMBER,
                   p_title                      IN              VARCHAR2,
                   p_bal_segment_from           IN              VARCHAR2,
                   p_bal_segment_to             IN              VARCHAR2,
                   p_from_date                  IN              VARCHAR2,
                   p_to_date                    IN              VARCHAR2,
                   p_from_amount                IN              NUMBER,
                   p_to_amount                  IN              NUMBER,
                   p_from_item                  IN              VARCHAR2,
                   p_to_item                    IN              VARCHAR2,
                   p_sort_by                    IN              VARCHAR2 )
IS

        l_api_name      CONSTANT        VARCHAR2(2000)   := 'Generate_MiscAccrualReportXml';
        l_api_version   CONSTANT        NUMBER          := 1.0;

        l_xml_doc                       CLOB;
        l_qryCtx                        NUMBER;
        l_from_date                     DATE;
        l_to_date                       DATE;
        l_current_org_id                NUMBER;

        l_amount                        NUMBER ;
        l_offset                        NUMBER ;
        l_length                        NUMBER;
        l_buffer                        VARCHAR2(32767);
        l_stmt_num                      NUMBER;
        l_msg_count                     NUMBER;
        l_msg_data                      VARCHAR2(2000);
        l_return_status                 VARCHAR2(1);
        l_success                       BOOLEAN;
        l_error_message                 VARCHAR2(300);

        l_full_name     CONSTANT        VARCHAR2(4000)  := G_PKG_NAME || '.' || l_api_name;
        l_module        CONSTANT        VARCHAR2(4000)  := 'cst.plsql.' || l_full_name;

         l_uLog          CONSTANT        BOOLEAN         := FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL AND FND_LOG.TEST (FND_LOG.LEVEL_UNEXPECTED,
l_module);
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
        l_amount := 16383; --Changed for bug 7013852
        l_offset := 1;
        l_return_status := fnd_api.g_ret_sts_success;
        l_msg_count := 0;



 -- select the operating unit for which the program is launched.

l_stmt_num := 5;

        l_current_org_id := MO_GLOBAL.get_current_org_id;

-- Initialze variables for storing XML Data

           DBMS_LOB.createtemporary(l_xml_doc, TRUE);
	   /*Bug 7305146*/
	   l_encoding       := fnd_profile.value('ICX_CLIENT_IANA_ENCODING');
	   l_xml_header     := '<?xml version="1.0" encoding="'|| l_encoding ||'"?>';
	   DBMS_LOB.writeappend (l_xml_doc, length(l_xml_header), l_xml_header);

           DBMS_LOB.writeappend (l_xml_doc, 8, '<REPORT>');

-- convert from date parameter to date type variable

l_stmt_num := 10;

        IF (p_from_date IS NOT NULL) THEN
                l_from_date := FND_DATE.canonical_to_date(p_from_date);
        ELSE
                l_from_date := NULL;
        END IF;

-- convert to date parameter to date type variable

 l_stmt_num := 20;

        IF (p_to_date IS NOT NULL) THEN
                l_to_date := FND_DATE.canonical_to_date(p_to_date );
        ELSE
                l_to_date := NULL;
        END IF;

 -- Write the module name and user parameters to fnd log file

        IF (l_pLog) THEN
         FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                         l_module || '.begin',
                         '>>> ' || l_api_name || ':Parameters:
                         Org id:'||  l_current_org_id
                         || 'Title: '  || p_title
                         || 'Sort Option: ' || p_sort_by
                         || ' From Date: ' || l_from_date
                         || ' To Date: ' || l_to_date
                         || ' From Item: ' || p_from_item
                         || ' To Item: ' || p_to_item
                         || ' From Amount: ' || p_from_amount
                         || ' To Amount: ' || p_to_amount
                         || ' Balancing Segment From: ' || p_bal_segment_from
                         || ' Balancing Segment To: ' || p_bal_segment_to );

        END IF;

l_stmt_num := 30;

  /* check if to_date is greater than or equal to to_date */

 If (p_from_date is not null and p_to_date < p_from_date ) then

      l_error_message := 'CST_INVALID_TO_DATE';
      fnd_message.set_name('BOM','CST_INVALID_TO_DATE');
      RAISE fnd_api.g_exc_error;
    End If;

/* check if to_amount is greater than or equal to from_amount */

 If (p_from_amount is not null and p_to_amount < p_from_amount ) then

      l_error_message := 'CST_INVALID_TO_AMOUNT';
      fnd_message.set_name('BOM','CST_INVALID_TO_AMOUNT');
      RAISE fnd_api.g_exc_error;
    End If;


-- Standard call to get message count and if count is 1, get message info.

        FND_MSG_PUB.Count_And_Get
        (       p_count         =>      l_msg_count,
                p_data          =>      l_msg_data
        );



/*========================================================================*/
-- Call to Procedure Add Parameters. To Add user entered Parameters to
-- XML data
/*========================================================================*/

l_stmt_num := 40;

                Add_Parameters  (p_api_version          => l_api_version,
                                 p_init_msg_list        => FND_API.G_FALSE,
                                 p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
                                 x_return_status        => l_return_status,
                                 x_msg_count            => l_msg_count,
                                 x_msg_data             => l_msg_data,
                                 i_title                => p_title,
                                 i_sort_by              => p_sort_by,
                                 i_from_date            => l_from_date,
                                 i_to_date              => l_to_date,
                                 i_from_item            => p_from_item,
                                 i_to_item              => p_to_item,
                                 i_from_amount          => p_from_amount,
                                 i_to_amount            => p_to_amount,
                                 i_bal_segment_from     => p_bal_segment_from,
                                 i_bal_segment_to       => p_bal_segment_to,
                                 x_xml_doc              => l_xml_doc);

-- Standard call to check the return status from API called

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


/*========================================================================*/
-- Call to Procedure Add Parameters. To add misc data to XML data
/*========================================================================*/

l_stmt_num := 50;

                Add_MiscData    (p_api_version          => l_api_version,
                                 p_init_msg_list        => FND_API.G_FALSE,
                                 p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
                                 x_return_status        => l_return_status,
                                 x_msg_count            => l_msg_count,
                                 x_msg_data             => l_msg_data,
                                 i_title                => p_title,
                                 i_sort_by              => p_sort_by,
                                 i_from_date            => l_from_date   ,
                                 i_to_date              => l_to_date,
                                 i_from_item            => p_from_item,
                                 i_to_item              => p_to_item,
                                 i_from_amount          => p_from_amount,
                                 i_to_amount            => p_to_amount,
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

        DBMS_XMLGEN.closeContext(l_qryCtx);


-- Write the event log to fnd log file

        IF (l_eventLog) THEN
                FND_LOG.STRING (FND_LOG.LEVEL_EVENT,
                                l_module || '.' || l_stmt_num,
                                'Completed writing to output file');
        END IF;

-- free temporary memory and close the context
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
                (       p_api_version   => l_api_version,
                        p_msg_count     => l_msg_count,
                        p_msg_data      => l_msg_data,
                        x_return_status => l_return_status);

                l_msg_data      := SUBSTRB (SQLERRM,1,240);
                l_success       := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', l_msg_data);

END Generate_MiscReportXml;

PROCEDURE Add_Parameters
                (p_api_version          IN              NUMBER,
                p_init_msg_list         IN              VARCHAR2,
                p_validation_level      IN              NUMBER,

                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,

                i_title                 IN              VARCHAR2,
                i_sort_by               IN              VARCHAR2,
                i_from_date             IN              DATE,
                i_to_date               IN              DATE,
                i_from_item             IN              VARCHAR2,
                i_to_item               IN              VARCHAR2,
                i_from_amount           IN              NUMBER,
                i_to_amount             IN              NUMBER,
                i_bal_segment_from      IN              VARCHAR2,
                i_bal_segment_to        IN              VARCHAR2,

                x_xml_doc               IN OUT NOCOPY   CLOB)
IS

        l_api_name      CONSTANT        VARCHAR2(3000)    := 'ADD_PARAMETERS';
        l_api_version   CONSTANT        NUMBER          := 1.0;
        l_ref_cur                       SYS_REFCURSOR;
        l_qryCtx                        NUMBER;
        l_xml_temp                      CLOB;
        l_offset                        PLS_INTEGER;
        l_stmt_num                      NUMBER;
        l_current_org_id                NUMBER;
        l_age_option                    NUMBER;
        l_org_code                      VARCHAR2(3000);
        l_org_name                      VARCHAR2(3000);

        l_full_name     CONSTANT        VARCHAR2(3000)  := G_PKG_NAME || '.' || l_api_name;
        l_module        CONSTANT        VARCHAR2(3000)  := 'cst.plsql.' || l_full_name;

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

l_stmt_num := 10;

-- Get the proile value to determine the aging basis

        fnd_profile.get('CST_ACCRUAL_AGE_IN_DAYS', l_age_option);


-- select the operating unit for which the program is launched.

l_stmt_num := 20;

        l_current_org_id := MO_GLOBAL.get_current_org_id;

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

        OPEN l_ref_cur FOR 'SELECT      :l_org_code                     org_code,
                                        :l_org_name                     org_name,
                                        xla.NAME                        ledger_name,
                                        xla.currency_code               CUR_CODE,
                                        :i_title                        TITLE_NAME,
                                        crs.displayed_field             sort_option,
                                        :i_from_date                    from_date,
                                        :i_to_date                      to_date,
                                        :i_from_item                    from_item,
                                        :i_to_item                      to_item,
                                        :i_from_amount                  from_amount,
                                        :i_to_amount                    to_amount,
                                        :i_bal_segment_from             bal_seg_from,
                                        :i_bal_segment_to               bal_seg_to,
                                        decode(:l_age_option,
                                           1,
                                           ''Last Receipt Date'',
                                           ''Last Activity Date'')      age_option
                            FROM        cst_reconciliation_codes        crs,
                                        XLA_GL_LEDGERS_V                xla,
                                        HR_ORGANIZATION_INFORMATION     hoi
                            WHERE       hoi.ORGANIZATION_ID = :l_current_org_id
                            and         hoi.ORG_INFORMATION_CONTEXT = ''Operating Unit Information''
                            and         xla.LEDGER_ID = hoi.ORG_INFORMATION3
                            AND         crs.lookup_type = ''SRS ACCRUAL ORDER BY''
                            AND         crs.LOOKUP_CODE = :i_sort_by'
                            USING       l_org_code,
                                        l_org_name,
                                        i_title,
                                        i_from_date  ,
                                        i_to_date  ,
                                        i_from_item ,
                                        i_to_item ,
                                        i_from_amount,
                                        i_to_amount,
                                        i_bal_segment_from,
                                        i_bal_segment_to,
                                        l_age_option,
                                        l_current_org_id,
                                        i_sort_by;

--  create new context

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
   (    p_count         =>      x_msg_count,
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


PROCEDURE Add_MiscData
                (p_api_version          IN              NUMBER,
                p_init_msg_list         IN              VARCHAR2,
                p_validation_level      IN              NUMBER,

                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,

                i_title                 IN              VARCHAR2,
                i_sort_by               IN              VARCHAR2,
                i_from_date             IN              DATE,
                i_to_date               IN              DATE,
                i_from_item             IN              VARCHAR2,
                i_to_item               IN              VARCHAR2,
                i_from_amount           IN              NUMBER,
                i_to_amount             IN              NUMBER,
                i_bal_segment_from      IN              VARCHAR2,
                i_bal_segment_to        IN              VARCHAR2,

                x_xml_doc               IN OUT NOCOPY   CLOB)
IS

        l_api_name      CONSTANT        VARCHAR2(3000)    := 'MISC_REPORT_DATA';
        l_api_version   CONSTANT        NUMBER          := 1.0;
        l_ref_cur                       SYS_REFCURSOR;
        l_qryCtx                        NUMBER;
        l_xml_temp                      CLOB;
        l_offset                        PLS_INTEGER;
        l_bal_segment                   VARCHAR2(50);
        l_items_null                    VARCHAR2(1);
        l_count                         NUMBER;
        l_stmt_num                      NUMBER;
        l_current_org_id                NUMBER;
        l_account_range                 NUMBER;
        l_age_option                    NUMBER;

        l_full_name     CONSTANT        VARCHAR2(3000)  := G_PKG_NAME || '.' || l_api_name;
        l_module        CONSTANT        VARCHAR2(3000)  := 'cst.plsql.' || l_full_name;

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

l_stmt_num := 5;

-- Get the proile value to determine the aging basis

        fnd_profile.get('CST_ACCRUAL_AGE_IN_DAYS', l_age_option);

-- select the operating unit for which the program is launched.

l_stmt_num := 10;

        l_current_org_id := MO_GLOBAL.get_current_org_id;


-- Check if item range is given

l_stmt_num := 20;

        IF (  (i_from_item IS NULL)   AND   (i_to_item IS NULL)  ) THEN
                l_items_null := 'Y';

        ELSE

                l_items_null := 'N';

        END IF;

-- select the balancing segment value

 l_stmt_num := 30;

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

-- open ref cur to fetch misc data

 l_stmt_num := 40;

      OPEN l_ref_cur FOR 'SELECT  gcc.concatenated_segments                             account,
                                  decode(cmr.invoice_distribution_id,
                                  NULL,
                                  decode ( cmr.transaction_type_code,
                                          ''CONSIGNMENT'',
                                          (SELECT crc.displayed_field
                                          FROM cst_reconciliation_codes crc
                                          WHERE crc.lookup_code =
                                                   cmr.transaction_type_code
                                          AND crc.lookup_type IN
                                                 ( ''ACCRUAL WRITE-OFF ACTION'',''ACCRUAL TYPE'')),
                                          (SELECT mtt.transaction_type_name
                                          FROM mtl_transaction_types          mtt
                                          WHERE cmr.transaction_type_code =
                                                         to_char(mtt.transaction_type_id) )),
                                  (SELECT crc.displayed_field
                                  FROM cst_reconciliation_codes crc
                                  WHERE crc.lookup_code =
                                          cmr.transaction_type_code
                                  AND crc.lookup_type IN
                                   ( ''ACCRUAL WRITE-OFF ACTION'',''ACCRUAL TYPE'')))   transaction_type,
                                  decode(cmr.invoice_distribution_id,
                                  NULL,
                                  ''INV'',
                                  ''AP'')                                               transaction_source,
                                  cmr.transaction_date                                  transaction_date,
                                  cmr.quantity                                          quantity,
                                  cmr.amount                                            amount,
                                  cmr.entered_amount                                    entered_amount,
                                  cmr.currency_code                                     currency_code,
                                  apia.invoice_num                                      invoice_number,
                                  aida.invoice_line_number                              invoice_line,
                                  NVL(poh.CLM_DOCUMENT_NUMBER,poh.SEGMENT1)            po_number,--Changed as a part of CLM
                                  por.release_num                                       po_release,
                                  nvl(POL.LINE_NUM_DISPLAY, to_char(POL.LINE_NUM))      po_line,--Changed as a part of CLM
                                  poll.shipment_num                                     po_shipment,
                                  pod.distribution_num                                  po_distribution,
                                  cmr.po_distribution_id                                po_distribution_id,
                                  cmr.inventory_transaction_id                          inventory_transaction_id,
                                  decode(cmr.inventory_item_id, null, null,
                                           (select msi.concatenated_segments from
                                            mtl_system_items_vl msi
                                            where inventory_item_id = cmr.inventory_item_id
                                           and rownum <2)
                                           )                                            item,
                                  decode(cmr.invoice_distribution_id,
                                  NULL,
                                  mmt.TRANSACTION_UOM,
                                  pol.UNIT_MEAS_LOOKUP_CODE)                            uom,
                                 trunc (decode (cmr.transaction_type_code,
                                        ''CONSIGNMENT'', decode(cmr.po_distribution_id,
                                                null, null,
                                                decode ( :l_age_option, 1,
                                                (sysdate - nvl( (select max(cmr2.transaction_date)
                                                 from cst_misc_reconciliation cmr2
                                                 where cmr2.po_distribution_id= cmr.po_distribution_id
						 and  cmr2.inventory_transaction_id is not null
						 and cmr2.transaction_type_code = ''CONSIGNMENT''
						 ),
						 (select max(cmr2.transaction_date)
						      from cst_misc_reconciliation cmr2
						      where cmr2.po_distribution_id = cmr.po_distribution_id
						      and cmr2.inventory_transaction_id is null
						      and cmr2.transaction_type_code = ''CONSIGNMENT''
						      and cmr2.invoice_distribution_id is not null)
						 )),
                                                 (sysdate - greatest(  nvl( (select max(cmr2.transaction_date)
                                                 from cst_misc_reconciliation cmr2
                                                 where cmr2.po_distribution_id= cmr.po_distribution_id
						 and  cmr2.inventory_transaction_id is not null
						 and cmr2.transaction_type_code = ''CONSIGNMENT''),
						 (select max(cmr2.transaction_date)
						      from cst_misc_reconciliation cmr2
						      where cmr2.po_distribution_id = cmr.po_distribution_id
						      and cmr2.inventory_transaction_id is null
						      and cmr2.transaction_type_code = ''CONSIGNMENT''
						      and cmr2.invoice_distribution_id is not null)
						 ),
                                                 NVL((select max(cmr2.transaction_date)
						      from cst_misc_reconciliation cmr2
						      where cmr2.po_distribution_id = cmr.po_distribution_id
						      and cmr2.inventory_transaction_id is null
						      and cmr2.transaction_type_code = ''CONSIGNMENT''
						      and cmr2.invoice_distribution_id is not null),
                                                 (select max(cmr2.transaction_date)
                                                 from cst_misc_reconciliation cmr2
                                                 where cmr2.po_distribution_id= cmr.po_distribution_id
						 and  cmr2.inventory_transaction_id is not null
						 and cmr2.transaction_type_code = ''CONSIGNMENT'')
						 )
                                                 )) -- age option 2
                                                 ) --po dist id not null, age option 1
                                                 ), --po dist_id null
                                           null) --txn_type_code not consignment
					   )                                       age_in_days,
                                  pov.vendor_name                                       vendor,
                                  mp.organization_code                                  org
                          FROM    cst_misc_reconciliation                               cmr,
                                  ap_invoices_all                                       apia,
                                  ap_invoice_distributions_all                          aida,
                                  po_vendors                                            pov,
                                  mtl_parameters                                        mp,
                                  gl_code_combinations_kfv                              gcc,
                                  po_distributions_all                                  pod,
                                  po_line_locations_all                                 poll,
                                  po_releases_all                                       por,
                                  po_lines_all                                          pol,
                                  po_headers_all                                        poh,
				  mtl_material_transactions                             mmt
                          WHERE   cmr.invoice_distribution_id = aida.invoice_distribution_id(+)
                          AND     aida.invoice_id = apia.invoice_id(+)
                          AND     cmr.vendor_id = pov.vendor_id(+)
                          AND     cmr.inventory_organization_id = mp.organization_id(+)
                          AND     cmr.accrual_account_id  = gcc.code_combination_id
                          AND     pod.po_distribution_id(+) = cmr.po_distribution_id
			  and     cmr.inventory_transaction_id = mmt.transaction_id (+)
                          AND     poll.line_location_id(+) = pod.line_location_id
                          AND     pod.po_release_id = por.po_release_id(+)
                          AND     pol.po_line_id(+) = pod.po_line_id
                          AND     poh.po_header_id(+) = pod.po_header_id
                          AND     cmr.operating_unit_id = :l_current_org_id
                          AND     cmr.transaction_date BETWEEN
                                        nvl( :i_from_date ,cmr.transaction_date )
                                        AND nvl(:i_to_date ,cmr.transaction_date)
                          AND     cmr.amount BETWEEN nvl(:i_from_amount,cmr.amount)
                                        AND nvl(:i_to_amount,cmr.amount)
                          AND       (:l_items_null  = ''Y''
                                      OR (:l_items_null  = ''N''
                                      AND decode(cmr.inventory_item_id, null, null,
                                           (select msi.concatenated_segments
                                            from mtl_system_items_vl msi
                                            where inventory_item_id = cmr.inventory_item_id
                                            and rownum <2))
                                      between nvl(:i_from_item, decode(cmr.inventory_item_id, null,
                                                                       null,
                                                                       (select msi.concatenated_segments
                                                                        from mtl_system_items_vl msi
                                                                        where inventory_item_id = cmr.inventory_item_id
                                                                        and rownum <2)))
                                      and nvl(:i_to_item ,decode(cmr.inventory_item_id, null, null,
                                                                (select msi.concatenated_segments
                                                                 from mtl_system_items_vl msi
                                                                 where inventory_item_id = cmr.inventory_item_id
                                                                 and rownum <2)))
                                          ))
                          AND       (( :l_account_range = 0 )
                                                OR (  :l_account_range = 1 AND
                                                      gcc.' || l_bal_segment || ' >=  :i_bal_segment_from)
                                                OR  (  :l_account_range = 2 AND
                                                      gcc.' || l_bal_segment || ' <=  :i_bal_segment_to)
                                                OR (  :l_account_range = 3 AND
                                                      gcc.' || l_bal_segment || ' BETWEEN :i_bal_segment_from
                                                AND :i_bal_segment_to   )    )
                          ORDER BY decode( :i_sort_by ,
                                           ''ITEM'', item,
                                           ''AMOUNT'', decode(sign(amount),-1,
                                                                   chr(0) || translate( to_char(abs(amount), ''000000000999.999''),
                                                                    ''0123456789'', ''9876543210''), to_char(amount, ''000000000999.999'' ) ),
                                           ''DATE'', to_char(transaction_date, ''yyyymmddhh24miss'')) '
                          USING   l_age_option,
                                  l_current_org_id,
                                  i_from_date,
                                  i_to_date,
                                  i_from_amount,
                                  i_to_amount,
                                  l_items_null,
                                  l_items_null,
                                  i_from_item,
                                  i_to_item,
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

l_stmt_num := 50;

        l_qryCtx := DBMS_XMLGEN.newContext (l_ref_cur);
        DBMS_XMLGEN.setRowSetTag (l_qryCtx,'MISC_DATA');
        DBMS_XMLGEN.setRowTag (l_qryCtx,'MISC');

-- get XML into the temporary clob variable

l_stmt_num := 60;

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

-- open ref cursor to get the number of rows processed

l_stmt_num := 70;

        OPEN l_ref_cur FOR  SELECT l_count l_count FROM dual ;

-- create new context

l_stmt_num := 80;

        l_qryCtx := DBMS_XMLGEN.newContext (l_ref_cur);
        DBMS_XMLGEN.setRowSetTag (l_qryCtx,'record_num');
        DBMS_XMLGEN.setRowTag (l_qryCtx,NULL);

-- get XML to add the number of rows processed

l_stmt_num := 90;

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

END Add_MiscData;

END CST_MiscAccrualReport_PVT ;

/
