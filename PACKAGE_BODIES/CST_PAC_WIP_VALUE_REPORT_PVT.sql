--------------------------------------------------------
--  DDL for Package Body CST_PAC_WIP_VALUE_REPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_PAC_WIP_VALUE_REPORT_PVT" AS
/* $Header: CSTPWVRB.pls 120.9.12010000.2 2008/10/30 12:34:52 svelumur ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'CST_PAC_WIP_VALUE_REPORT_PVT';

/*-------------------------------------------------------------------------------
-- PROCEDURE    : Generate_XML
-- DESCRIPTION  : Procedure to call all the procedures which generates XML data
--------------------------------------------------------------------------------*/

PROCEDURE Generate_XMLData
                      (errbuf                 OUT     NOCOPY VARCHAR2,
                       retcode                OUT     NOCOPY NUMBER,
                       p_report_type          IN       VARCHAR2,
                       p_legal_entity_id      IN       VARCHAR2,
                       p_cost_type_id         IN       VARCHAR2,
                       p_pac_period_id        IN       NUMBER,
                       p_cost_group_id        IN       VARCHAR2,
                       p_set_of_books         IN       VARCHAR2,
                       p_class_type           IN       VARCHAR2,
                       p_from_job             IN       VARCHAR2,
                       p_to_job               IN       VARCHAR2,
                       p_from_assembly        IN       VARCHAR2,
                       p_to_assembly          IN       VARCHAR2,
                       p_currency_code        IN       VARCHAR2,
                       p_disp_inv_rate        IN       VARCHAR2,
                       p_exchange_rate_type   IN       NUMBER,
                       p_exchange_rate_char   IN       VARCHAR2,
                       p_stuct_number         IN       NUMBER
                      )
IS
  l_api_name     CONSTANT VARCHAR2(30) := 'Generate_XMLData';
  l_module       CONSTANT VARCHAR2(90) := 'cst.plsql.CST_PAC_WIP_Value_Report_PVT.Generate_XMLData';
  l_log_level    CONSTANT NUMBER       := fnd_log.G_CURRENT_RUNTIME_LEVEL;
  l_uLog         CONSTANT BOOLEAN := fnd_log.TEST(fnd_log.level_unexpected, l_module) AND fnd_log.level_unexpected >= l_log_level;
  l_errorLog     CONSTANT BOOLEAN := l_uLog AND fnd_log.level_error >= l_log_level;
  l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND fnd_log.level_exception >= l_log_level;
  l_eventLog     CONSTANT BOOLEAN := l_exceptionLog AND fnd_log.level_event >= l_log_level;
  l_pLog         CONSTANT BOOLEAN := l_eventLog AND fnd_log.level_procedure >= l_log_level;
  l_sLog         CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

  l_xml_doc             CLOB;
  l_amount              NUMBER;
  l_offset              NUMBER;
  l_length              NUMBER;
  l_buffer              VARCHAR2(32767);
  l_stmt_num            NUMBER;

  l_return_status       VARCHAR2(1);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);
  l_success             BOOLEAN;

  l_report_type        NUMBER;
  l_legal_entity_id    NUMBER;
  l_cost_type_id       NUMBER;
  l_cost_group_id      NUMBER;

BEGIN
        l_stmt_num := 0;
        IF l_plog THEN
              fnd_log.string(
                fnd_log.level_procedure,
                l_module||'.'||l_stmt_num,
                'Entering CST_PAC_WIP_Value_Report_PVT.Generate_XMLData with << '||
                'p_report_type = '||p_report_type||','||
                'p_legal_entity_id = '||p_legal_entity_id||','||
                'p_cost_group_id = '||p_cost_group_id||','||
                'p_cost_type_id = '||p_cost_type_id||','||
                'p_pac_period_id = '||p_pac_period_id||','||
                'p_class_type = '||p_class_type||','||
                'p_from_job = '||p_from_job||','||
                'p_to_job = '||p_to_job||','||
                'p_from_assembly = '||p_from_assembly||','||
                'p_to_assembly = '||p_to_assembly||','||
                'p_exchange_rate_char = '||p_exchange_rate_char||','||
                'p_currency_code = '||p_currency_code
              );
        END IF;

        -- Convert to NUMBER data type
        l_report_type     := TO_NUMBER(p_report_type);
        l_legal_entity_id := TO_NUMBER(p_legal_entity_id);
        l_cost_type_id    := TO_NUMBER(p_cost_type_id);
        l_cost_group_id   := TO_NUMBER(p_cost_group_id);

        l_stmt_num := 20;
        -- Create CLOB object to store AML data
        DBMS_LOB.createtemporary(l_xml_doc, TRUE);

        -- Initialize message stack
         FND_MSG_PUB.initialize;

        ------------------------------------------------------------------
        -- Populate temporary table for given PAC CostType and CostGroup
        ------------------------------------------------------------------
        l_stmt_num := 30;
        Periodic_WIP_value_rpt_details(p_api_version        => 1.0,
                                       p_init_msg_list      => FND_API.G_FALSE,
                                       p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
                                       x_return_status      => l_return_status,
                                       x_msg_count          => l_msg_count,
                                       x_msg_data           => l_msg_data,
                                       p_report_type        => p_report_type,
                                       p_pac_period_id      => p_pac_period_id,
                                       p_cost_group_id      => p_cost_group_id,
                                       p_cost_type_id       => p_cost_type_id,
                                       p_legal_entity_id    => p_legal_entity_id);



        -- If return status is not success, add message to the log
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
            l_msg_data := 'Failed generating Periodic WIP value details information';
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -----------------------------------------------------------------
        -- Generate XML data for displaying the report parameters values
        -----------------------------------------------------------------
        l_stmt_num := 40;
        Display_Parameters (p_api_version        => 1.0,
                            p_init_msg_list      => FND_API.G_FALSE,
                            p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
                            x_return_status      => l_return_status,
                            x_msg_count          => l_msg_count,
                            x_msg_data           => l_msg_data,
                            p_report_type        => p_report_type,
                            p_legal_entity_id    => p_legal_entity_id,
                            p_cost_group_id      => p_cost_group_id,
                            p_cost_type_id       => p_cost_type_id,
                            p_pac_period_id      => p_pac_period_id,
                            p_class_type         => p_class_type,
                            p_from_job           => p_from_job,
                            p_to_job             => p_to_job,
                            p_from_assembly      => p_from_assembly,
                            p_to_assembly        => p_to_assembly,
                            p_exchange_rate_char => p_exchange_rate_char,
                            p_currency_code      => p_currency_code,
                            x_xml_doc            => l_xml_doc);

        -- If return status is not success, add message to the log
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
            l_msg_data := 'Failed generating XML data for report parameter information';
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -----------------------------------------------------------------
        -- Generate XML data for displaying the report parameters values
        -----------------------------------------------------------------
         l_stmt_num := 50;
         Get_XMLData(p_api_version        => 1.0,
                     p_init_msg_list      => FND_API.G_FALSE,
                     p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
                     x_return_status      => l_return_status,
                     x_msg_count          => l_msg_count,
                     x_msg_data           => l_msg_data,
                     p_legal_entity_id    => p_legal_entity_id,
                     p_cost_group_id      => p_cost_group_id,
                     p_cost_type_id       => p_cost_type_id,
                     p_pac_period_id      =>  p_pac_period_id ,
                     p_class_type         => p_class_type,
                     p_from_job           => p_from_job,
                     p_to_job             => p_to_job,
                     p_from_assembly      => p_from_assembly,
                     p_to_assembly        => p_to_assembly,
                     p_exchange_rate_char => p_exchange_rate_char,
                     p_currency_code      => p_currency_code,
                     x_xml_doc            => l_xml_doc);

        -- If return status is not success, add message to the log
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
           l_msg_data := 'Failed generating XML data of the report output';
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        DBMS_LOB.writeappend (l_xml_doc, 9, '</REPORT>');

        -- Get length of the CLOB l_xml_doc
        l_stmt_num := 60;
        l_length := nvl(DBMS_LOB.getlength(l_xml_doc), 0);
        l_offset := 1;
        l_amount := 16383;

        -- Loop until the length of CLOB data is zero
        l_stmt_num := 70;
        LOOP
            EXIT WHEN l_length <= 0;
            -- Read 32 KB of data and print it to the report output
            DBMS_LOB.read (l_xml_doc, l_amount, l_offset, l_buffer);
            FND_FILE.PUT (FND_FILE.OUTPUT, l_buffer);
            l_length := l_length - l_amount;
            l_offset := l_offset + l_amount;
        END LOOP;

        DBMS_LOB.FREETEMPORARY (l_xml_doc);

        l_success := FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL', 'Request Completed Successfully');

        IF l_plog THEN
          fnd_log.string(
            fnd_log.level_procedure,
            l_module||'.'||l_stmt_num,
            'Exiting CST_PAC_WIP_Value_Report_PVT.Generate_XMLData >> ');
        END IF;

      EXCEPTION
        WHEN fnd_api.g_exc_unexpected_error THEN

            IF l_exceptionlog THEN
              fnd_msg_pub.add_exc_msg(
                p_pkg_name => 'CST_PAC_WIP_Value_Report_PVT',
                p_procedure_name => 'Generate_XMLData',
                p_error_text => 'An exception has occurred.'
              );
              fnd_log.string(
                fnd_log.level_exception,
                l_module||'.'||l_stmt_num,
                'An exception has occurred.'
              );
              END IF;
              l_success := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', 'Exception Occured');

        WHEN OTHERS THEN
            IF l_uLog THEN
              fnd_message.set_name('BOM','CST_UNEXPECTED');
              fnd_message.set_token('SQLERRM',SQLERRM);
              fnd_msg_pub.add;
              fnd_log.message(
                fnd_log.level_unexpected,
                l_module||'.'||l_stmt_num,
                FALSE
              );
            END IF;
            l_success := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', 'An unexpected error has occurred');
END Generate_XMLData;

-----------------------------------------------------------------------------
-- PROCEDURE    : Display_Parameters
-- DESCRIPTION  : Procedure for to display all the concurrent request
--                parameters in XML
-----------------------------------------------------------------------------

PROCEDURE  Display_Parameters (p_api_version         IN         NUMBER,
                               p_init_msg_list       IN         VARCHAR2,
                               p_validation_level    IN         NUMBER,
                               x_return_status       OUT NOCOPY VARCHAR2,
                               x_msg_count           OUT NOCOPY NUMBER,
                               x_msg_data            OUT NOCOPY VARCHAR2,
                               p_report_type         IN         NUMBER,
                               p_legal_entity_id     IN         NUMBER,
                               p_cost_group_id       IN         NUMBER,
                               p_cost_type_id        IN         NUMBER,
                               p_pac_period_id       IN         NUMBER,
                               p_class_type          IN         VARCHAR2,
                               p_from_job            IN         VARCHAR2,
                               p_to_job              IN         VARCHAR2,
                               p_from_assembly       IN         VARCHAR2,
                               p_to_assembly         IN         VARCHAR2,
                               p_exchange_rate_char  IN         VARCHAR2,
                               p_currency_code       IN         VARCHAR2,
                               x_xml_doc             IN OUT NOCOPY  CLOB)
IS
 l_api_name     CONSTANT VARCHAR2(30)   := 'Display_Parameters';
 l_api_version  CONSTANT NUMBER         := 1.0;

 l_module       CONSTANT VARCHAR2(90) := 'cst.plsql.CST_PAC_WIP_Value_Report_PVT.Display_Parameters';
 l_log_level    CONSTANT NUMBER       := fnd_log.G_CURRENT_RUNTIME_LEVEL;
 l_uLog         CONSTANT BOOLEAN      := fnd_log.level_unexpected >= l_log_level AND
                                         fnd_log.TEST(fnd_log.level_unexpected, l_module);
 l_errorLog     CONSTANT BOOLEAN := l_uLog AND fnd_log.level_error >= l_log_level;
 l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND fnd_log.level_exception >= l_log_level;
 l_eventLog     CONSTANT BOOLEAN := l_exceptionLog AND fnd_log.level_event >= l_log_level;
 l_pLog         CONSTANT BOOLEAN := l_eventLog AND fnd_log.level_procedure >= l_log_level;
 l_sLog         CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

 l_ref_cur         SYS_REFCURSOR;
 l_ctx             NUMBER;
 l_xml_temp        CLOB;
 l_offset          PLS_INTEGER;
 l_wip_entity_name VARCHAR2(240);
 l_stmt_num        NUMBER;
 /*Bug 7305146*/
 l_encoding        VARCHAR2(20);
 l_xml_header      VARCHAR2(100);

BEGIN
       l_stmt_num := 0;
       IF l_plog THEN
           fnd_log.string(
                     fnd_log.level_procedure,
                     l_module||'.'||l_stmt_num,
                     'Entering CST_PAC_WIP_Value_Report_PVT.Display_Parameters with << '||
                     'p_init_msg_list = '||p_init_msg_list||','||
                     'p_validation_level = '||p_validation_level||','||
                     'p_report_type = '||p_report_type||','||
                     'p_legal_entity_id = '||p_legal_entity_id||','||
                     'p_cost_group_id = '||p_cost_group_id||','||
                     'p_cost_type_id = '||p_cost_type_id||','||
                     'p_pac_period_id = '||p_pac_period_id||','||
                     'p_class_type = '||p_class_type||','||
                     'p_from_job = '||p_from_job||','||
                     'p_to_job = '||p_to_job||','||
                     'p_from_assembly = '||p_from_assembly||','||
                     'p_to_assembly = '||p_to_assembly||','||
                     'p_exchange_rate_char = '||p_exchange_rate_char||','||
                     'p_currency_code = '||p_currency_code
                   );
        END IF;

       l_stmt_num := 10;
       IF NOT FND_API.Compatible_API_Call (l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME )
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        --  Initialize API return status to success
       l_stmt_num := 20;
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       DBMS_LOB.createtemporary(l_xml_temp, TRUE);

       -------------------------------------------------------------------------------
        -- Open reference cursor for fetching data related to report parameter values
       -------------------------------------------------------------------------------
        l_stmt_num := 30;
        OPEN l_ref_cur FOR  SELECT xle.name,
                            cct.cost_type,
                            cpp.PERIOD_NAME,
                            ccg.cost_group,
                            p_class_type className,
                            p_from_job from_job,
                            p_to_job to_job,
                            p_from_assembly from_aasembly,
                            p_to_assembly to_aasembly,
                            p_exchange_rate_char exchange_rate_char,
                            p_currency_code currency_code,
                            m1.meaning   rep_type
         FROM xle_entity_profiles xle,
              cst_pac_periods cpp,
              cst_cost_types cct,
              cst_le_cost_types clct,
              cst_cost_groups ccg,
              mfg_lookups m1
        WHERE xle.legal_entity_id = p_legal_entity_id
          AND clct.legal_entity = xle.legal_entity_id
          AND clct.cost_type_id = cct.cost_type_id
          AND cct.cost_type_id = p_cost_type_id
          AND cpp.legal_entity = clct.legal_entity
          AND cpp.cost_type_id = cct.cost_type_id
          AND cpp.pac_period_id = p_pac_period_id
          AND ccg.cost_group_id = p_cost_group_id
          AND ccg.legal_entity = clct.legal_entity
          AND m1.lookup_type = 'WIP_REP_VAL_TYPE'
          AND m1.lookup_code = p_report_type;

        -- create a new context with the SQL query
        l_stmt_num := 40;
        l_ctx := DBMS_XMLGEN.newContext (l_ref_cur);

        -- Set the row tag and rowset tag
        l_stmt_num := 50;
        DBMS_XMLGEN.setRowSetTag(l_ctx,'REPORTPARAMETERS');
        DBMS_XMLGEN.setRowTag(l_ctx,NULL);

          -- generate XML data
          l_stmt_num := 60;
          DBMS_XMLGEN.getXML (l_ctx, l_xml_temp, DBMS_XMLGEN.none);

          l_stmt_num := 70;
          l_offset := DBMS_LOB.instr (lob_loc => l_xml_temp,
                                      pattern => '>',
                                      offset  => 1,
                                      nth     => 1);

          /*Bug 7305146
	  -- Copy XML header part to the destination XML doc
          l_stmt_num := 80;
          DBMS_LOB.copy (x_xml_doc, l_xml_temp, l_offset + 1);*/

           -- Remove the header
           l_stmt_num := 80;
           DBMS_LOB.erase (l_xml_temp, l_offset,1);

           l_stmt_num := 90;
	   l_encoding       := fnd_profile.value('ICX_CLIENT_IANA_ENCODING');
	   l_xml_header     := '<?xml version="1.0" encoding="'|| l_encoding ||'"?>';
	   DBMS_LOB.writeappend (x_xml_doc, length(l_xml_header), l_xml_header);

	   --  append the REPORT tag to XML
           l_stmt_num := 100;
           DBMS_LOB.writeappend (X_xml_doc, 8, '<REPORT>');

           l_stmt_num := 110;
           -- Append the rest to xml output
           DBMS_LOB.append (x_xml_doc, l_xml_temp);

          -- close context and free memory
          l_stmt_num := 120;
          DBMS_XMLGEN.closeContext(l_ctx);
          CLOSE l_ref_cur;
          DBMS_LOB.FREETEMPORARY (l_xml_temp);

          IF l_plog THEN
            fnd_log.string(
              fnd_log.level_procedure,
              l_module||'.'||l_stmt_num,
              'Exiting CST_PAC_WIP_Value_Report_PVT.Display_Parameters >> ');
          END IF;

 EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF l_exceptionlog THEN
         fnd_msg_pub.add_exc_msg(
           p_pkg_name => 'CST_PAC_WIP_Value_Report_PVT',
           p_procedure_name => 'Display_Parameters',
           p_error_text => 'An exception has occurred.'
         );
               IF l_uLog THEN
                  fnd_log.string(
                          fnd_log.level_exception,
                          l_module||'.'||l_stmt_num,
                         'An exception has occurred.'
                         );
               END IF;
       END IF;
    WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF l_uLog THEN
         fnd_log.string(
                        FND_LOG.LEVEL_UNEXPECTED,
                        l_module || '.' || l_stmt_num,
                        SUBSTRB (SQLERRM , 1 , 230)
                       );
      END IF;
END Display_Parameters;

-----------------------------------------------------------------------------
-- PROCEDURE    : Periodic_WIP_Value_Rpt_Details
-- DESCRIPTION  : Procedure for to populate the table cst_wip_pac_period_bal_tmp
--                For a given pac period, pac cost type and pac cost group
-----------------------------------------------------------------------------

PROCEDURE Periodic_WIP_Value_Rpt_Details( p_api_version         IN         NUMBER,
                                          p_init_msg_list       IN         VARCHAR2,
                                          p_validation_level    IN         NUMBER,
                                          x_return_status       OUT NOCOPY VARCHAR2,
                                          x_msg_count           OUT NOCOPY NUMBER,
                                          x_msg_data            OUT NOCOPY VARCHAR2,
                                          p_report_type         IN         NUMBER,
                                          p_pac_period_id       IN         NUMBER,
                                          p_cost_group_id       IN         NUMBER,
                                          p_cost_type_id        IN         NUMBER,
                                          p_legal_entity_id     IN         NUMBER)
IS

 l_module       CONSTANT VARCHAR2(90) := 'cst.plsql.CST_PAC_WIP_Value_Report_PVT.Periodic_WIP_Value_Rpt_Details';
 l_log_level    CONSTANT NUMBER := fnd_log.G_CURRENT_RUNTIME_LEVEL;
 l_uLog         CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level AND
                                    fnd_log.TEST(fnd_log.level_unexpected, l_module);
 l_errorLog     CONSTANT BOOLEAN := l_uLog AND fnd_log.level_error >= l_log_level;
 l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND fnd_log.level_exception >= l_log_level;
 l_eventLog     CONSTANT BOOLEAN := l_exceptionLog AND fnd_log.level_event >= l_log_level;
 l_pLog         CONSTANT BOOLEAN := l_eventLog AND fnd_log.level_procedure >= l_log_level;
 l_sLog         CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;


CURSOR wip_pac_bal is
    SELECT wip_entity_id,
           organization_id,
           line_id,
           /* All In */
           sum( nvl(pl_material_in, 0))  material_in,
           sum( nvl(pl_material_overhead_in, 0))  material_ovhd_in ,
           sum( nvl(tl_resource_in ,0) + nvl( pl_resource_in,0)) Resource_in,
           sum( nvl(tl_overhead_in ,0) + nvl( pl_overhead_in, 0))  overhead_in,
           sum( nvl(tl_outside_processing_in ,0) + nvl( pl_outside_processing_in,0)) osp_in,
           /* All out */
           sum( nvl(pl_material_out, 0) ) material_out,
           sum( nvl(pl_material_overhead_out , 0)) material_ovhd_out,
           sum( nvl(tl_resource_out ,0) + nvl( pl_resource_out, 0)) resource_out,
           sum( nvl(tl_outside_processing_out ,0) + nvl( pl_outside_processing_out,0)) osp_out,
           sum( nvl(tl_overhead_out ,0) + nvl( pl_overhead_out, 0))  overhead_out,
           /* All var */
           sum( nvl(pl_material_var, 0) ) material_var,
           sum( nvl(pl_material_overhead_var , 0)) material_ovhd_var,
           sum( nvl(tl_resource_var ,0) + nvl(pl_resource_var, 0)) resource_var,
           sum( nvl(tl_outside_processing_var ,0) + nvl(pl_outside_processing_var,0)) osp_var,
           sum( nvl(tl_overhead_var,0) + nvl(pl_overhead_var, 0))  overhead_var

FROM       wip_pac_period_balances wppb
WHERE      wppb.pac_period_id = p_pac_period_id
AND        wppb.cost_type_id =  p_cost_type_id
AND        wppb.cost_group_id = p_cost_group_id
GROUP BY   wppb.wip_entity_id,
           wppb.organization_id,
           wppb.line_id;

 l_begining_material         NUMBER;
 l_begining_material_ovhd    NUMBER;
 l_begining_resource         NUMBER;
 l_begining_overhead         NUMBER;
 l_begining_osp              NUMBER;

 l_prev_material_in          NUMBER;
 l_prev_material_ovhd_in     NUMBER;
 l_prev_resource_in          NUMBER;
 l_prev_overhead_in          NUMBER;
 l_prev_osp_in               NUMBER;

 l_prev_material_out         NUMBER;
 l_prev_material_ovhd_out    NUMBER;
 l_prev_resource_out         NUMBER;
 l_prev_overhead_out         NUMBER;
 l_prev_osp_out              NUMBER;

 l_prev_material_var         NUMBER;
 l_prev_material_ovhd_var    NUMBER;
 l_prev_resource_var         NUMBER;
 l_prev_overhead_var         NUMBER;
 l_prev_osp_var              NUMBER;

 l_prev_period_id            NUMBER;
 l_stmt_num                  NUMBER;
 l_ctr                       NUMBER;

BEGIN

  l_stmt_num := 0;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_plog THEN
    fnd_log.string(
      fnd_log.level_procedure,
      l_module||'.'||l_stmt_num,
      'Entering CST_PAC_WIP_Value_Report_PVT.Periodic_WIP_Value_Rpt_Details with '||
      'p_init_msg_list = '||p_init_msg_list||','||
      'p_validation_level = '||p_validation_level||','||
      'p_report_type = '||p_report_type||','||
      'p_pac_period_id = '||p_pac_period_id||','||
      'p_cost_group_id = '||p_cost_group_id||','||
      'p_legal_entity_id = '||p_legal_entity_id||','||
      'p_cost_type_id = '||p_cost_type_id
    );
  END IF;

  -------------------------------------------------
  -- Get the prior PAC period Id
  -------------------------------------------------
  l_stmt_num := 10;

  SELECT nvl(max(cpp.pac_period_id), -1)
  INTO   l_prev_period_id
  FROM   cst_pac_process_phases cppp,
         cst_pac_periods cpp
  WHERE cppp.pac_period_id = cpp.pac_period_id
  AND   cppp.cost_group_id = p_cost_group_id
  AND   cpp.cost_type_id = p_cost_type_id
  AND   cpp.legal_entity = p_legal_entity_id
  AND   cpp.pac_period_id < p_pac_period_id;

  l_stmt_num := 20;
  l_ctr := 0;

  FOR temp_rec IN wip_pac_bal LOOP
  ---------------------------------------------------------------------------
  -- If prior period exist the get the prior period details from WPPB table
  ---------------------------------------------------------------------------
  l_begining_material         := 0;
  l_begining_material_ovhd    := 0;
  l_begining_Resource         := 0;
  l_begining_overhead         := 0;
  l_begining_osp              := 0;

  l_prev_material_in          := 0;
  l_prev_material_ovhd_in     := 0;
  l_prev_resource_in          := 0;
  l_prev_overhead_in          := 0;
  l_prev_osp_in               := 0;

  l_prev_material_out         := 0;
  l_prev_material_ovhd_out    := 0;
  l_prev_resource_out         := 0;
  l_prev_overhead_out         := 0;
  l_prev_osp_out              := 0;

  l_prev_material_var          := 0;
  l_prev_material_ovhd_var     := 0;
  l_prev_resource_var          := 0;
  l_prev_overhead_var          := 0;
  l_prev_osp_var               := 0;

  l_ctr := l_ctr + 1;
  ---------------------------------------------------------------------------
  -- If prior period exist the get the prior period details from WPPB table
  ---------------------------------------------------------------------------
  IF (l_prev_period_id <> -1 ) THEN

   -------------------------------------------------------------------------------------------------------
   -- Get the ending balance of prior period, Total incurred value and relieved value till prior period
   --  Begining Balance in current period = Ending Balance of prior period
   -------------------------------------------------------------------------------------------------------
   l_stmt_num := 30;
   SELECT
          SUM( nvl(pl_material_in, 0) - nvl(pl_material_out, 0) - nvl(pl_material_var, 0) ),
          SUM( nvl(pl_material_overhead_in, 0) - nvl(pl_material_overhead_out,0) - nvl(pl_material_overhead_var,0)),
          SUM( nvl(tl_resource_in ,0) + nvl( pl_resource_in,0)
               - nvl(tl_resource_out ,0) - nvl( pl_resource_out, 0)
               - nvl(tl_resource_var ,0) - nvl( pl_resource_var, 0) ),
          SUM( nvl(tl_overhead_in ,0) + nvl( pl_overhead_in, 0)
                - nvl(tl_overhead_out ,0) - nvl( pl_overhead_out, 0)
                -  nvl(tl_overhead_var,0) - nvl( pl_overhead_var, 0) ) ,
          SUM( nvl(tl_outside_processing_in ,0) + nvl( pl_outside_processing_in,0)
               - nvl(tl_outside_processing_out ,0) - nvl( pl_outside_processing_out,0)
               - nvl(tl_outside_processing_var ,0) - nvl( pl_outside_processing_var,0) ),
         /* Total incurred value till previous period */
          SUM ( nvl(pl_material_in, 0)  ) ,
          SUM( nvl(pl_material_overhead_in, 0)) ,
          SUM( nvl(tl_resource_in ,0) + nvl( pl_resource_in,0) ) ,
          SUM( nvl(tl_overhead_in ,0) + nvl( pl_overhead_in, 0) ) ,
          SUM( nvl(tl_outside_processing_in ,0) + nvl(pl_outside_processing_in,0)),
          /* Total relieved value till prior period */
          SUM( nvl(pl_material_out, 0)  ) ,
          SUM( nvl(pl_material_overhead_out, 0)) ,
          SUM( nvl(tl_resource_out ,0) + nvl( pl_resource_in,0) ) ,
          SUM( nvl(tl_overhead_out ,0) + nvl( pl_overhead_in, 0) ) ,
          SUM( nvl(tl_outside_processing_out ,0) + nvl(pl_outside_processing_out,0) ),
            /* Total  variance till prior period */
           sum( nvl(pl_material_var, 0) ) material_var,
           sum( nvl(pl_material_overhead_var , 0)) material_ovhd_var,
           sum( nvl(tl_resource_var ,0) + nvl(pl_resource_var, 0)) resource_var,
           sum( nvl(tl_outside_processing_var ,0) + nvl(pl_outside_processing_var,0)) osp_var,
           sum( nvl(tl_overhead_var,0) + nvl(pl_overhead_var, 0))  overhead_var

   INTO  l_begining_material,
         l_begining_material_ovhd,
         l_begining_resource,
         l_begining_overhead,
         l_begining_osp,
         l_prev_material_in,
         l_prev_material_ovhd_in,
         l_prev_resource_in,
         l_prev_overhead_in,
         l_prev_osp_in,
         l_prev_material_out,
         l_prev_material_ovhd_out,
         l_prev_resource_out,
         l_prev_overhead_out,
         l_prev_osp_out,
         l_prev_material_var,
         l_prev_material_ovhd_var,
         l_prev_resource_var,
         l_prev_overhead_var,
         l_prev_osp_var
   FROM  wip_pac_period_balances wppb
   WHERE wppb.pac_period_id = l_prev_period_id
   AND   wppb.wip_entity_id = temp_rec.wip_entity_id
   AND   nvl(wppb.line_id,-99) = nvl(temp_rec.line_id,-99)
   AND   wppb.cost_type_id  = p_cost_type_id;

  END IF;

  FOR i IN 1..5 LOOP

      --------------------------------------------------------------------
      -- Insert the values into Temporary table cst_wip_pac_period_bal_tmp
      --------------------------------------------------------------------
      l_stmt_num := 40;
      INSERT INTO cst_wip_pac_period_bal_tmp (cost_group_id,
                                              pac_period_id,
                                              cost_type_id,
                                              wip_entity_id,
                                              organization_id,
                                              line_id,
                                              cost_element_id,
                                              begining_balance,
                                              costs_incurred,
                                              costs_relieved,
                                              ending_balance,
                                              variance_amount)
         VALUES (p_cost_group_id,
                 p_pac_period_id,
                 p_cost_type_id,
                 temp_rec.wip_entity_id,
                 temp_rec.organization_id,
                 temp_rec.line_id,
                 i, -- Cost Element
                 DECODE(i,1,DECODE(p_report_type,1,nvl(l_begining_material,0),0),
                          2,DECODE(p_report_type,1,nvl(l_begining_material_ovhd,0),0),
                          3,DECODE(p_report_type,1,nvl(l_begining_Resource,0),0),
                          4,DECODE(p_report_type,1,nvl(l_begining_osp,0),0),
                          5,DECODE(p_report_type,1,nvl(l_begining_overhead,0),0)
                       ),
                 DECODE(i,1,temp_rec.material_in - DECODE(p_report_type,1,nvl(l_prev_material_in,0),0),
                          2,temp_rec.material_ovhd_in - DECODE(p_report_type,1,nvl(l_prev_material_ovhd_in,0),0),
                          3,temp_rec.Resource_in - DECODE(p_report_type,1,nvl(l_prev_Resource_in,0),0),
                          4,temp_rec.osp_in - DECODE(p_report_type,1,nvl(l_prev_osp_in,0),0),
                          5,temp_rec.overhead_in - DECODE(p_report_type,1,nvl(l_prev_overhead_in,0),0)
                       ),
                 DECODE(i,1,temp_rec.material_out - DECODE(p_report_type,1,nvl(l_prev_material_out,0),0),
                          2,temp_rec.material_ovhd_out - DECODE(p_report_type,1,nvl(l_prev_material_ovhd_out,0),0),
                          3,temp_rec.Resource_out - DECODE(p_report_type,1,nvl(l_prev_Resource_out,0),0) ,
                          4,temp_rec.osp_out - DECODE(p_report_type,1,nvl(l_prev_osp_out,0),0),
                          5,temp_rec.overhead_out - DECODE(p_report_type,1,nvl(l_prev_overhead_out,0),0)
                       ),
                DECODE(i,1,(temp_rec.material_in - temp_rec.material_out - temp_rec.material_var ),
                         2,(temp_rec.material_ovhd_in - temp_rec.material_ovhd_out - temp_rec.material_ovhd_var),
                         3,(temp_rec.Resource_in - temp_rec.Resource_out  - temp_rec.Resource_var),
                         4,(temp_rec.osp_in - temp_rec.osp_out - temp_rec.osp_var),
                         5,(temp_rec.overhead_in - temp_rec.overhead_out - temp_rec.overhead_var)
                      ),
                 DECODE(i,1,temp_rec.material_var - DECODE(p_report_type,1,nvl(l_prev_material_var,0),0),
                          2,temp_rec.material_ovhd_var - DECODE(p_report_type,1,nvl(l_prev_material_ovhd_var,0),0),
                          3,temp_rec.Resource_var - DECODE(p_report_type,1,nvl(l_prev_Resource_var,0),0) ,
                          4,temp_rec.osp_var - DECODE(p_report_type,1,nvl(l_prev_osp_var,0),0) ,
                          5,temp_rec.overhead_var - DECODE(p_report_type,1,nvl(l_prev_overhead_var,0),0)
                       )
                );
      END LOOP;
  END LOOP;

  COMMIT;
  IF l_plog THEN
   fnd_log.string(
    fnd_log.level_procedure,
    l_module||'.'||l_stmt_num,
    'Inserted '||l_ctr|| ' rows into temp table.' ||
    'Exiting CST_PAC_WIP_Value_Report_PVT.Periodic_WIP_Value_Rpt_Details >> ');
  END IF;

EXCEPTION
  WHEN fnd_api.g_exc_unexpected_error THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF l_exceptionlog THEN
      fnd_msg_pub.add_exc_msg(
        p_pkg_name => 'CST_PAC_WIP_Value_Report_PVT',
        p_procedure_name => 'Periodic_WIP_Value_Rpt_Details',
        p_error_text => 'An exception has occurred.'
      );
           IF l_uLog THEN
              fnd_log.string(
                fnd_log.level_exception,
                l_module||'.'||l_stmt_num,
                'An exception has occurred.'
              );
           END IF;
   END IF;

 WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF l_uLog THEN
       FND_LOG.STRING(
                      FND_LOG.LEVEL_UNEXPECTED,
                      l_module || '.' || l_stmt_num,
                      SUBSTRB (SQLERRM , 1 , 230)
                     );
    END IF;

End Periodic_WIP_Value_Rpt_Details;

-----------------------------------------------------------------------------
-- PROCEDURE    : Get_XMLData
-- DESCRIPTION  : Procedure for to generare XML data for given parameter values
--
-----------------------------------------------------------------------------

PROCEDURE Get_XMLData(p_api_version         IN             NUMBER,
                      p_init_msg_list       IN             VARCHAR2,
                      p_validation_level    IN             NUMBER,
                      x_return_status       OUT NOCOPY     VARCHAR2,
                      x_msg_count           OUT NOCOPY     NUMBER,
                      x_msg_data            OUT NOCOPY     VARCHAR2,
                      p_legal_entity_id     IN             NUMBER,
                      p_cost_group_id       IN             NUMBER,
                      p_cost_type_id        IN             NUMBER,
                      p_pac_period_id       IN             NUMBER,
                      p_class_type          IN             VARCHAR2,
                      p_from_job            IN             VARCHAR2,
                      p_to_job              IN             VARCHAR2,
                      p_from_assembly       IN             VARCHAR2,
                      p_to_assembly         IN             VARCHAR2,
                      p_exchange_rate_char  IN             VARCHAR2,
                      p_currency_code       IN             VARCHAR2,
                      x_xml_doc             IN OUT NOCOPY  CLOB)
IS
 l_api_name     CONSTANT   VARCHAR2(30)   := 'Get_XMLData';
 l_api_version  CONSTANT   NUMBER         := 1.0;
 l_module       CONSTANT VARCHAR2(90)     := 'cst.plsql.CST_PAC_WIP_Value_Report_PVT.Get_XMLData';
 l_log_level    CONSTANT NUMBER           := fnd_log.G_CURRENT_RUNTIME_LEVEL;
 l_uLog         CONSTANT BOOLEAN := fnd_log.TEST(fnd_log.level_unexpected, l_module) AND fnd_log.level_unexpected >= l_log_level;
 l_errorLog     CONSTANT BOOLEAN := l_uLog AND fnd_log.level_error >= l_log_level;
 l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND fnd_log.level_exception >= l_log_level;
 l_eventLog     CONSTANT BOOLEAN := l_exceptionLog AND fnd_log.level_event >= l_log_level;
 l_pLog         CONSTANT BOOLEAN := l_eventLog AND fnd_log.level_procedure >= l_log_level;
 l_sLog         CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

 l_ref_cur                  SYS_REFCURSOR;
 l_ctx                      NUMBER;
 l_xml_temp                 CLOB;
 l_offset                   PLS_INTEGER;
 l_total_rows_processed     NUMBER;

 l_sql_stsmt                VARCHAR2(4000);
 l_where_clause             VARCHAR2(2000);
 l_group_by_clause          VARCHAR2(2000);

 l_sql_stsmt1               VARCHAR2(4000);
 l_where_clause1            VARCHAR2(2000);
 l_group_by_clause1         VARCHAR2(2000);

 l_exchange_rate            NUMBER;
 l_precision                NUMBER;
 l_period_end_date          DATE;
 l_stmt_num                 NUMBER;

BEGIN

       l_stmt_num := 0;
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       IF l_plog THEN
              fnd_log.string(
                fnd_log.level_procedure,
                l_module||'.'||l_stmt_num,
                'Entering CST_PAC_WIP_Value_Report_PVT.Get_XMLData with '||
                'p_init_msg_list = '||p_init_msg_list||','||
                'p_validation_level = '||p_validation_level||','||
                'p_legal_entity_id = '||p_legal_entity_id||','||
                'p_cost_group_id = '||p_cost_group_id||','||
                'p_cost_type_id = '||p_cost_type_id||','||
                'p_pac_period_id = '||p_pac_period_id||','||
                'p_class_type = '||p_class_type||','||
                'p_from_job = '||p_from_job||','||
                'p_to_job = '||p_to_job||','||
                'p_from_assembly = '||p_from_assembly||','||
                'p_to_assembly = '||p_to_assembly||','||
                'p_exchange_rate_char = '||p_exchange_rate_char||','||
                'p_currency_code = '||p_currency_code
              );
       END IF;

       l_exchange_rate := fnd_number.canonical_to_number(P_EXCHANGE_RATE_CHAR);

       l_stmt_num := 5;
       IF  (p_currency_code is NOT NULL) THEN
            SELECT fc.precision
            INTO   l_precision
            FROM   fnd_currencies fc
            WHERE  fc.currency_code = p_currency_code;
       END IF;
       l_stmt_num := 10;

       SELECT cpp.period_end_date
       INTO   l_period_end_date
       FROM   cst_pac_periods cpp
       WHERE  cpp.pac_period_id = P_PAC_PERIOD_ID;

       l_stmt_num := 20;

       l_offset := 21;
       DBMS_LOB.createtemporary(l_xml_temp, TRUE);

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (    l_api_version,
                                                p_api_version,
                                                l_api_name,
                                                G_PKG_NAME )
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


        -- Execute the Query
        l_stmt_num := 140;
        OPEN l_ref_cur FOR
select
  min(ml.meaning) Class_type,
  we.wip_entity_name,
  mp.organization_code,
  msik.concatenated_segments Assembly,
  min(ml2.meaning) job_status,
  wdj.scheduled_start_date scheduled_start_date,
  cce.cost_element,
  sum(round( wppb.BEGINING_BALANCE * l_exchange_rate, l_precision )) BeginingBalance,
  sum(round( wppb.COSTS_INCURRED   * l_exchange_rate, l_precision )) CostsIncurred,
  sum(round( wppb.costs_relieved   * l_exchange_rate, l_precision )) CostsRelieved,
  sum(round( wppb.ENDING_BALANCE   * l_exchange_rate, l_precision )) EndingBalance,
  sum(round( wppb.VARIANCE_AMOUNT  * l_exchange_rate, l_precision )) VarianceAmount
from
  wip_entities we,
  mfg_lookups ml,
  cst_wip_pac_period_bal_tmp wppb,
  wip_discrete_jobs wdj,
  wip_accounting_classes wac,
  mfg_lookups ml2,
  mtl_parameters mp,
  cst_cost_elements cce,
  mtl_system_items_kfv msik
where
      wppb.cost_group_id = P_COST_GROUP_ID
  and wppb.pac_period_id = P_PAC_PERIOD_ID
  and wdj.wip_entity_id = wppb.wip_entity_id
  and wdj.organization_id = wppb.organization_id
  and we.wip_entity_id = wdj.wip_entity_id
  and wac.class_code = wdj.class_code
  and wac.organization_id = wdj.organization_id
  and ml.lookup_type = 'WIP_CLASS_TYPE_CAP'
  and ml.lookup_code = wac.class_type
  and msik.organization_id = wdj.organization_id
  and msik.inventory_item_id = wdj.primary_item_id
  and ml2.lookup_type = 'WIP_JOB_STATUS'
  and ml2.lookup_code = wdj.status_type
  and mp.organization_id = wppb.organization_id
  and cce.cost_element_id = WPPB.cost_element_id
  and ( p_class_type    is null or wac.class_type = p_class_type )
  and ( p_from_job      is null or WE.WIP_ENTITY_NAME >= P_FROM_JOB )
  and ( p_to_job        is null or WE.WIP_ENTITY_NAME <= P_TO_JOB )
  and ( p_from_assembly is null or msik.concatenated_segments >= p_from_assembly )
  and ( p_to_assembly   is null or msik.concatenated_segments <= p_to_assembly )
GROUP BY
  wac.class_type,
  wppb.wip_entity_id,
  we.wip_entity_name,
  mp.organization_code,
  wdj.scheduled_start_date,
  wdj.primary_item_id,
  msik.concatenated_segments,
  wdj.status_type,
  wppb.pac_period_id,
  wppb.cost_element_id,
  cce.cost_element
UNION ALL
select
  min(ml.meaning) Class_type,
  wl.line_code wip_entity_name,
  mp.organization_code,
  msik.concatenated_segments Assembly,
  decode( sign( l_period_end_date - NVL(min(NVL(wl.disable_date,l_period_end_date + 1)), l_period_end_date + 1 )),
          1, 'Line Disabled', 'Line Open')  job_status ,
  to_date(NULL) scheduled_start_date,
  cce.cost_element ,
  sum(round( wppb.BEGINING_BALANCE * l_exchange_rate, l_precision )) BeginingBalance,
  sum(round( wppb.COSTS_INCURRED   * l_exchange_rate, l_precision )) CostsIncurred,
  sum(round( wppb.costs_relieved   * l_exchange_rate, l_precision )) CostsRelieved,
  sum(round( wppb.ENDING_BALANCE   * l_exchange_rate, l_precision )) EndingBalance,
  sum(round( wppb.VARIANCE_AMOUNT  * l_exchange_rate, l_precision )) VarianceAmount
FROM
  wip_lines wl ,
  mfg_lookups ml ,
  cst_wip_pac_period_bal_tmp wppb ,
  wip_repetitive_items wri ,
  mtl_system_items_kfv msik ,
  wip_accounting_classes wac ,
  wip_entities we ,
  mtl_parameters mp ,
  cst_cost_elements cce
WHERE
      wppb.cost_group_id = P_COST_GROUP_ID
  and wppb.pac_period_id = P_PAC_PERIOD_ID
  and wl.line_id = wppb.line_id
  and wri.wip_entity_id = wppb.wip_entity_id
  and wri.line_id = wppb.line_id
  and we.wip_entity_id = wppb.wip_entity_id
  and wac.class_code = wri.class_code
  and wac.organization_id = wppb.organization_id
  and ml.lookup_type = 'WIP_CLASS_TYPE_CAP'
  and ml.lookup_code = wac.class_type
  and msik.organization_id = wppb.organization_id
  and msik.inventory_item_id = wri.primary_item_id
  and mp.organization_id = wppb.organization_id
  and cce.cost_element_id = WPPB.cost_element_id
  and ( p_class_type    is null or wac.class_type = p_class_type )
  and ( p_from_job      is null or WE.WIP_ENTITY_NAME >= P_FROM_JOB )
  and ( p_to_job        is null or WE.WIP_ENTITY_NAME <= P_TO_JOB )
  and ( p_from_assembly is null or msik.concatenated_segments >= p_from_assembly )
  and ( p_to_assembly   is null or msik.concatenated_segments <= p_to_assembly )
GROUP BY
  wac.class_type,
  WPPB.wip_entity_id,
  wl.line_code,
  mp.organization_code,
  wri.primary_item_id,
  msik.concatenated_segments,
  wppb.pac_period_id,
  wppb.cost_element_id,
  cce.cost_element
ORDER  BY
  1,2,3,4,5,6,7;




       -- create new context
        l_stmt_num := 150;
        l_ctx := DBMS_XMLGEN.newContext (l_ref_cur);

        DBMS_XMLGEN.setRowSetTag (l_ctx,'PACwipentites');
        DBMS_XMLGEN.setRowTag (l_ctx,'CostElements');

        -- get XML
        l_stmt_num := 160;
        DBMS_XMLGEN.getXML (l_ctx, l_xml_temp, DBMS_XMLGEN.none);

        -- Remove the header (21 characters) and append the rest to xml output
        l_stmt_num := 170;
        l_total_rows_processed :=  DBMS_XMLGEN.getNumRowsProcessed(l_ctx);

        l_stmt_num := 180;
        IF ( l_total_rows_processed > 0) THEN
                DBMS_LOB.erase (l_xml_temp, l_offset,1);
                DBMS_LOB.append (x_xml_doc, l_xml_temp);
        END IF;

        -- close context and free memory
        l_stmt_num := 190;
        DBMS_XMLGEN.closeContext(l_ctx);
        CLOSE l_ref_cur;
        DBMS_LOB.FREETEMPORARY (l_xml_temp);

        l_stmt_num := 200;
        DBMS_LOB.createtemporary(l_xml_temp, TRUE);

        l_stmt_num := 210;
       -- create new context to get the total number rows processes
        open  l_ref_cur FOR select l_total_rows_processed row_count from DUAL;
        l_ctx := DBMS_XMLGEN.newContext (l_ref_cur);
        DBMS_XMLGEN.setRowSetTag (l_ctx,NULL);
        DBMS_XMLGEN.setRowTag (l_ctx,NULL);

        l_stmt_num := 220;
        -- get XML
        DBMS_XMLGEN.getXML (l_ctx, l_xml_temp, DBMS_XMLGEN.none);

        -- remove the header (21 characters) and append the rest to xml output
        l_stmt_num := 230;
        l_total_rows_processed :=  DBMS_XMLGEN.getNumRowsProcessed(l_ctx);

        -- Check the number of rows more than zero then add XML result
        l_stmt_num := 240;
        IF ( l_total_rows_processed > 0) THEN
                DBMS_LOB.erase (l_xml_temp, l_offset,1);
                DBMS_LOB.append (x_xml_doc, l_xml_temp);
        END IF;

        l_stmt_num := 250;
        -- close context and free memory
        DBMS_XMLGEN.closeContext(l_ctx);
        CLOSE l_ref_cur;
        DBMS_LOB.FREETEMPORARY (l_xml_temp);

        IF l_plog THEN
              fnd_log.string(
                fnd_log.level_procedure,
                l_module||'.'||l_stmt_num,
                'Exiting CST_PAC_WIP_Value_Report_PVT.Get_XMLData >> ');
        END IF;


EXCEPTION
  WHEN fnd_api.g_exc_unexpected_error THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF l_exceptionlog THEN
      fnd_msg_pub.add_exc_msg(
        p_pkg_name => 'CST_PAC_WIP_Value_Report_PVT',
        p_procedure_name => 'Get_XMLData',
        p_error_text => 'An exception has occurred.'
      );
           IF l_uLog THEN
              fnd_log.string(
                fnd_log.level_exception,
                l_module||'.'||l_stmt_num,
                'An exception has occurred.'
              );
           END IF;
   END IF;

  WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   IF l_uLog THEN
      FND_LOG.STRING(
                     FND_LOG.LEVEL_UNEXPECTED,
                     l_module || '.' || l_stmt_num,
                     SUBSTRB (SQLERRM , 1 , 230)
                    );
   END IF;
END Get_XMLData;

END CST_PAC_WIP_VALUE_REPORT_PVT;

/
