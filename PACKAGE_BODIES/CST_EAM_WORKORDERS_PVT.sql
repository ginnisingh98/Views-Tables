--------------------------------------------------------
--  DDL for Package Body CST_EAM_WORKORDERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_EAM_WORKORDERS_PVT" AS
/* $Header: CSTPEEAB.pls 120.3.12010000.2 2008/10/30 12:15:08 svelumur ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'CST_eAM_WorkOrders_PVT';

PROCEDURE Generate_XMLData (
                  errcode                OUT NOCOPY      VARCHAR2,
                  errno                  OUT NOCOPY      NUMBER,
                  p_legal_entity_id      IN              NUMBER,
                  p_cost_type_id         IN              NUMBER,
                  p_cost_group_id        IN              NUMBER,
                  p_range                IN              NUMBER,
                  p_dummy1               IN              NUMBER := NULL,
                  p_dummy2               IN              NUMBER := NULL,
                  p_from_workorder       IN              VARCHAR2 := NULL,
                  p_to_workorder         IN              VARCHAR2 := NULL,
                  p_specific_workorder   IN              NUMBER := NULL)
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'Generate_XMLData';
  l_xml_doc             CLOB;
  l_amount              NUMBER;
  l_offset              NUMBER;
  l_length              NUMBER;
  l_buffer              VARCHAR2(32767);

  l_return_status       VARCHAR2(1);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);
  l_success             BOOLEAN;
  l_stmt_num            NUMBER;

  l_module       CONSTANT VARCHAR2(90) := 'cst.plsql.CST_eAM_WorkOrders_PVT.Generate_XMLData';
  l_log_level    CONSTANT NUMBER := fnd_log.G_CURRENT_RUNTIME_LEVEL;
  l_uLog         CONSTANT BOOLEAN := fnd_log.TEST(fnd_log.level_unexpected, l_module) AND fnd_log.level_unexpected >= l_log_level;
  l_errorLog     CONSTANT BOOLEAN := l_uLog AND fnd_log.level_error >= l_log_level;
  l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND fnd_log.level_exception >= l_log_level;
  l_eventLog     CONSTANT BOOLEAN := l_exceptionLog AND fnd_log.level_event >= l_log_level;
  l_pLog         CONSTANT BOOLEAN := l_eventLog AND fnd_log.level_procedure >= l_log_level;
  l_sLog         CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

BEGIN

    IF l_plog THEN
      fnd_log.string(
        fnd_log.level_procedure,
        l_module||'.'||l_stmt_num,
        'Entering CST_eAM_WorkOrders_PVT.Generate_XMLData with '||
        'p_legal_entity_id = '||p_legal_entity_id||','||
        'p_cost_group_id = '||p_cost_group_id||','||
        'p_cost_type_id = '||p_cost_type_id||','||
        'p_range = '||p_range||','||
        'p_from_workorder = '||p_from_workorder||','||
        'p_to_workorder = '||p_to_workorder||','||
        'p_specific_workorder = '||p_specific_workorder
      );
    END IF;

      -- Initialze variables
      l_stmt_num := 0;
      DBMS_LOB.createtemporary(l_xml_doc, TRUE);

      -- Initialize message stack
      l_stmt_num := 10;
      FND_MSG_PUB.initialize;

      -----------------------------------------------------------------
      -- Generate XML data for displaying the report parameters values
      -----------------------------------------------------------------
      l_stmt_num := 20;
      Display_Parameters (p_api_version     => 1.0,
                          p_init_msg_list      => FND_API.G_FALSE,
                          p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
                          x_return_status      => l_return_status,
                          x_msg_count          => l_msg_count,
                          x_msg_data           => l_msg_data,
                          p_legal_entity_id    => p_legal_entity_id,
                          p_cost_group_id      => p_cost_group_id,
                          p_cost_type_id       => p_cost_type_id,
                          p_range              => p_range,
                          p_from_workorder     => p_from_workorder,
                          p_to_workorder  => p_to_workorder,
                          p_specific_workorder => p_specific_workorder,
                          x_xml_doc            => l_xml_doc);

      -- If return status is not success, add message to the log
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
          l_msg_data := 'Failed generating XML data for report parameter information';
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      ------------------------------------------------------------------------------------
      -- Generate Estimation, Actuals data for workoder for given Cost Type and Cost Group
      ------------------------------------------------------------------------------------
       l_stmt_num := 30;
       eAM_Est_Actual_details (p_api_version        => 1.0,
                               p_init_msg_list      => FND_API.G_FALSE,
                               p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
                               x_return_status      => l_return_status,
                               x_msg_count          => l_msg_count,
                               x_msg_data           => l_msg_data,
                               p_legal_entity_id    => p_legal_entity_id,
                               p_cost_group_id      => p_cost_group_id,
                               p_cost_type_id       => p_cost_type_id,
                               p_range              => p_range,
                               p_from_workorder     => p_from_workorder,
                               p_to_workorder       => p_to_workorder,
                               p_specific_workorder => p_specific_workorder,
                               x_xml_doc            => l_xml_doc);

      -- If return status is not success, add message to the log
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
          l_msg_data := 'Failed generating Workorder Estimation, Actuals details';
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Append the XML end tag
      l_stmt_num := 40;
      DBMS_LOB.writeappend (l_xml_doc, 9, '</REPORT>');

      -- Get length of the CLOB l_xml_doc
      l_stmt_num := 50;
      l_length := nvl(DBMS_LOB.getlength(l_xml_doc), 0);
      l_offset := 1;
      l_amount := 16383;

       -- Loop until the length of CLOB data is zero
       l_stmt_num := 60;
      LOOP
                EXIT WHEN l_length <= 0;
                DBMS_LOB.read (l_xml_doc, l_amount, l_offset, l_buffer);
                FND_FILE.PUT (FND_FILE.OUTPUT, l_buffer);
                l_length := l_length - l_amount;
                l_offset := l_offset + l_amount;
      END LOOP;

      -- free temporary memory
      l_stmt_num := 70;
      DBMS_LOB.FREETEMPORARY (l_xml_doc);

      l_success := FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL', 'Request Completed Successfully');


    IF l_plog THEN
      fnd_log.string(
        fnd_log.level_procedure,
        l_module||'.'||l_stmt_num,
        'Exiting CST_eAM_WorkOrders_PVT.Generate_XMLData with '||
        'errno = '||errno
      );
    END IF;

    EXCEPTION
          WHEN fnd_api.g_exc_unexpected_error THEN
            -- Set return status to error
	    l_msg_data := SUBSTRB (SQLERRM,1,240);
            l_success := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', l_msg_data);

            IF l_exceptionlog THEN
              fnd_msg_pub.add_exc_msg(
                p_pkg_name => 'CST_eAM_WorkOrders_PVT',
                p_procedure_name => 'Generate_XMLData',
                p_error_text => 'An exception has occurred.'
              );
              fnd_log.string(
                fnd_log.level_exception,
                l_module||'.'||l_stmt_num,
                'An exception has occurred.'
              );
              END IF;
          WHEN OTHERS THEN

	    l_msg_data := SUBSTRB (SQLERRM,1,240);
            l_success := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', l_msg_data);

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
END Generate_XMLData;

PROCEDURE  Display_Parameters(p_api_version          IN              NUMBER,
                              p_init_msg_list         IN              VARCHAR2,
                              p_validation_level      IN              NUMBER,
                              x_return_status         OUT NOCOPY      VARCHAR2,
                              x_msg_count             OUT NOCOPY      NUMBER,
                              x_msg_data              OUT NOCOPY      VARCHAR2,
                              p_legal_entity_id       IN              NUMBER,
                              p_cost_group_id         IN              NUMBER,
                              p_cost_type_id          IN              NUMBER,
                              p_range                 IN              NUMBER,
                              p_from_workorder        IN              VARCHAR2,
                              p_to_workorder          IN              VARCHAR2,
                              p_specific_workorder    IN              NUMBER,
                              x_xml_doc               IN OUT NOCOPY   CLOB)
IS
 l_api_name        CONSTANT VARCHAR2(30) := 'Display_Parameters';
 l_api_version     CONSTANT NUMBER       := 1.0;
 l_ref_cur         SYS_REFCURSOR;
 l_ctx             NUMBER;
 l_xml_temp        CLOB;
 l_offset          PLS_INTEGER;
 l_wip_entity_name VARCHAR2(240);
 l_stmt_num        NUMBER;

 l_legal_entity    VARCHAR2(240);
 l_cost_type       VARCHAR2(10);
 l_cost_group      VARCHAR2(10);

 l_module       CONSTANT VARCHAR2(90) := 'cst.plsql.CST_eAM_WorkOrders_PVT.Display_Parameters';
 l_log_level    CONSTANT NUMBER := fnd_log.G_CURRENT_RUNTIME_LEVEL;
 l_uLog         CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level AND
                                    fnd_log.TEST(fnd_log.level_unexpected, l_module);
 l_errorLog     CONSTANT BOOLEAN := l_uLog AND fnd_log.level_error >= l_log_level;
 l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND fnd_log.level_exception >= l_log_level;
 l_eventLog     CONSTANT BOOLEAN := l_exceptionLog AND fnd_log.level_event >= l_log_level;
 l_pLog         CONSTANT BOOLEAN := l_eventLog AND fnd_log.level_procedure >= l_log_level;
 l_sLog         CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;
 /*Bug 7305146*/
 l_encoding     VARCHAR2(20);
 l_xml_header   VARCHAR2(100);

BEGIN
    IF l_plog THEN
      fnd_log.string(
        fnd_log.level_procedure,
        l_module||'.'||l_stmt_num,
        'Entering CST_eAM_WorkOrders_PVT.Display_Parameters with '||
        'p_init_msg_list = '||p_init_msg_list||','||
        'p_validation_level = '||p_validation_level||','||
        'p_legal_entity_id = '||p_legal_entity_id||','||
        'p_cost_group_id = '||p_cost_group_id||','||
        'p_cost_type_id = '||p_cost_type_id||','||
        'p_range = '||p_range||','||
        'p_from_workorder = '||p_from_workorder||','||
        'p_to_workorder = '||p_to_workorder||','||
        'p_specific_workorder = '||p_specific_workorder
      );
    END IF;

       l_stmt_num := 0;
       IF NOT FND_API.Compatible_API_Call (l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME )
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        --  Initialize API return status to success
        l_stmt_num := 10;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- Create CLOB object to store the XML data
        l_stmt_num := 20;
        DBMS_LOB.createtemporary(l_xml_temp, TRUE);

        -- If it is Specific WorkOrder then get the WP entity Name
        IF (p_range = 2) THEN
           l_stmt_num := 30;
           SELECT wip_entity_name
           INTO   l_wip_entity_name
           FROM   wip_entities
           WHERE  wip_entity_id = p_specific_workorder;
        END IF;

        l_stmt_num := 30;
	-- Get Legal Entity Name
	SELECT xle.name
	INTO   l_legal_entity
	FROM   xle_firstparty_information_v xle
	WHERE  xle.legal_entity_id = p_legal_entity_id;

        l_stmt_num := 40;
	-- Get PAC Cost Type Name
	SELECT cct.COST_TYPE
	INTO   l_cost_type
	FROM   cst_cost_types cct
	WHERE  cct.cost_type_id = p_cost_type_id;

        l_stmt_num := 50;
	-- Get PAC Cost group Name
	SELECT ccg.cost_group
	INTO   l_cost_group
	FROM   cst_cost_groups ccg
	WHERE  ccg.cost_group_id = p_cost_group_id
	AND    NVL(ccg.cost_group_type,1) = 2;


        -- Get the report parameter value for displaying in the report
        l_stmt_num := 60;
        OPEN l_ref_cur FOR
	            'SELECT
		            :l_legal_entity NAME,
                            :l_cost_type COST_TYPE,
                            :l_cost_group COST_GROUP,
                            LU.meaning RANGE,
                            :p_from_workorder FROM_WO,
                            :p_to_workorder TO_WO,
                            :l_wip_entity_name ENTITY
                      FROM  mfg_lookups LU
                      WHERE LU.lookup_type = ''CST_PAC_EAM_JOB_OPTION''
                      AND   LU.lookup_code = :p_range'
                      USING l_legal_entity, l_cost_type,  l_cost_group,
		            p_from_workorder, p_to_workorder, l_wip_entity_name, p_range;

          -- create a new context with the SQL query
          l_stmt_num := 50;
          l_ctx := DBMS_XMLGEN.newContext (l_ref_cur);
          DBMS_XMLGEN.setRowSetTag (l_ctx,'REPORTPARAMETERS');
          DBMS_XMLGEN.setRowTag (l_ctx,NULL);

          -- generate XML data
          l_stmt_num := 70;
          DBMS_XMLGEN.getXML (l_ctx, l_xml_temp, DBMS_XMLGEN.none);

          l_stmt_num := 80;
          l_offset := DBMS_LOB.instr (lob_loc => l_xml_temp,
                                      pattern => '>',
                                      offset  => 1,
                                      nth     => 1);

          /*Bug 7305146*/
          /*-- Copy XML header part to the destination XML doc
          l_stmt_num := 90;
          DBMS_LOB.copy (x_xml_doc, l_xml_temp, l_offset + 1);*/

           -- Remove the header
	   l_stmt_num := 90;
	   DBMS_LOB.erase (l_xml_temp, l_offset,1);

           l_stmt_num := 100;
           /*The following 3 lines of code ensures that XML data generated here uses the right encoding*/
	   l_encoding       := fnd_profile.value('ICX_CLIENT_IANA_ENCODING');
	   l_xml_header     := '<?xml version="1.0" encoding="'|| l_encoding ||'"?>';
	   DBMS_LOB.writeappend (x_xml_doc, length(l_xml_header), l_xml_header);

           --  append the REPORT tag to XML
           l_stmt_num := 110;
           DBMS_LOB.writeappend (X_xml_doc, 8, '<REPORT>');

           -- Append the rest to xml output
           l_stmt_num := 120;
           DBMS_LOB.append (x_xml_doc, l_xml_temp);

        /* close context and free memory */
        l_stmt_num := 130;
        DBMS_XMLGEN.closeContext(l_ctx);
        CLOSE l_ref_cur;
        DBMS_LOB.FREETEMPORARY (l_xml_temp);

    IF l_plog THEN
      fnd_log.string(
        fnd_log.level_procedure,
        l_module||'.'||l_stmt_num,
        'Exiting CST_eAM_WorkOrders_PVT.Display_Parameters with '||
        'x_return_status = '||x_return_status||','||
        'x_msg_count = '||x_msg_count||','||
        'x_msg_data = '||x_msg_data
      );
    END IF;
 EXCEPTION
  WHEN fnd_api.g_exc_unexpected_error THEN
    IF l_exceptionlog THEN
      fnd_msg_pub.add_exc_msg(
        p_pkg_name => 'CST_eAM_WorkOrders_PVT',
        p_procedure_name => 'Display_Parameters',
        p_error_text => 'An exception has occurred.'
      );
      fnd_log.string(
        fnd_log.level_exception,
        l_module||'.'||l_stmt_num,
        'An exception has occurred.'
      );
      END IF;
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
END Display_Parameters;

PROCEDURE eAM_Est_Actual_details(p_api_version        IN         NUMBER,
                                 p_init_msg_list      IN         VARCHAR2,
                                 p_validation_level   IN         NUMBER,
                                 x_return_status      OUT NOCOPY VARCHAR2,
                                 x_msg_count          OUT NOCOPY NUMBER,
                                 x_msg_data           OUT NOCOPY VARCHAR2,
                                 p_legal_entity_id    IN         NUMBER,
                                 p_cost_group_id      IN         NUMBER,
                                 p_cost_type_id       IN         NUMBER,
                                 p_range              IN         NUMBER,
                                 p_from_workorder     IN         VARCHAR2,
                                 p_to_workorder       IN         VARCHAR2,
                                 p_specific_workorder IN         NUMBER,
                                 x_xml_doc            IN OUT NOCOPY   CLOB)
IS
 l_api_name             CONSTANT VARCHAR2(30)   := 'eAM_Est_Actual_details';
 l_api_version          CONSTANT NUMBER         := 1.0;
 l_ref_cur              SYS_REFCURSOR;
 l_ctx                  NUMBER;
 l_xml_temp             CLOB;
 l_offset               PLS_INTEGER;
 l_total_rows_processed NUMBER;
 l_stmt_num             NUMBER;

 l_module       CONSTANT VARCHAR2(90) := 'cst.plsql.CST_eAM_WorkOrders_PVT.eAM_Est_Actual_details';
 l_log_level    CONSTANT NUMBER := fnd_log.G_CURRENT_RUNTIME_LEVEL;
 l_uLog         CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level AND
                                    fnd_log.TEST(fnd_log.level_unexpected, l_module);
 l_errorLog     CONSTANT BOOLEAN := l_uLog AND fnd_log.level_error >= l_log_level;
 l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND fnd_log.level_exception >= l_log_level;
 l_eventLog     CONSTANT BOOLEAN := l_exceptionLog AND fnd_log.level_event >= l_log_level;
 l_pLog         CONSTANT BOOLEAN := l_eventLog AND fnd_log.level_procedure >= l_log_level;
 l_sLog         CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

BEGIN
        l_stmt_num := 0;
        IF l_plog THEN
        fnd_log.string(
          fnd_log.level_procedure,
          l_module||'.'||l_stmt_num,
          'Entering CST_eAM_WorkOrders_PVT.eAM_Est_Actual_details with '||
          'p_init_msg_list = '||p_init_msg_list||','||
          'p_validation_level = '||p_validation_level||','||
          'p_legal_entity_id = '||p_legal_entity_id||','||
          'p_cost_group_id = '||p_cost_group_id||','||
          'p_cost_type_id = '||p_cost_type_id||','||
          'p_range = '||p_range||','||
          'p_from_workorder = '||p_from_workorder||','||
          'p_to_workorder = '||p_to_workorder||','||
          'p_specific_workorder = '||p_specific_workorder
        );
        END IF;

        --  Initialize API return status to success
	l_stmt_num := 10;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        --Create the CLOB object to store XML data
        l_stmt_num := 15;
        l_offset   := 21;
        DBMS_LOB.createtemporary(l_xml_temp, TRUE);

        -- Standard call to check for call compatibility.
        l_stmt_num := 20;
        IF NOT FND_API.Compatible_API_Call (    l_api_version,
                                                p_api_version,
                                                l_api_name,
                                                G_PKG_NAME )
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

   /* 1 - ALL , 2 - Specific  3 - Range */
   l_stmt_num := 30;
   IF (p_range = 1) THEN

       OPEN l_ref_cur FOR '
        select we.WIP_ENTITY_NAME ENTITY_NAME,
               mp.organization_code ORGANIZATION,
               lu1.meaning CATEGORY,
               bd.department_code DEPARTMENT,
               wpepb.operation_seq_num OPERATION_SEQ,
               sum(nvl(wpepb.system_estimated_mat_cost,0)) EST_MATL_COST,
               sum(nvl(wpepb.system_estimated_lab_cost,0)) EST_LABR_COST,
               sum(nvl(wpepb.system_estimated_eqp_cost,0)) EST_EQUIP_COST,
               sum(nvl(wpepb.actual_mat_cost,0)) ACT_MATL_COST,
               sum(nvl(wpepb.actual_lab_cost,0)) ACT_LABR_COST,
               sum(nvl(wpepb.actual_eqp_cost,0)) ACT_EQUIP_COST,
               sum(nvl(wpepb.system_estimated_mat_cost,0)) - sum(nvl(wpepb.actual_mat_cost,0)) VAR_MATL_COST,
                sum(nvl(wpepb.system_estimated_lab_cost,0)) - sum(nvl(wpepb.actual_lab_cost,0)) VAR_LABR_COST,
                sum(nvl(wpepb.system_estimated_eqp_cost,0)) -  sum(nvl(wpepb.actual_eqp_cost,0)) VAR_EQUIP_COST
        FROM CST_PAC_EAM_PERIOD_BALANCES WPEPB,
             MTL_PARAMETERS mp,
             WIP_ENTITIES we,
             BOM_DEPARTMENTS bd,
             MFG_LOOKUPS lu1

        Where wpepb.legal_entity_id = :p_legal_entity_id
          and wpepb.cost_group_id =  :p_cost_group_id
          and wpepb.Cost_type_id = :p_cost_type_id
          and wpepb.wip_entity_id =  we.wip_entity_id
          and wpepb.organization_id = mp.organization_id
          and we.organization_id = mp.organization_id
          and we.ENTITY_TYPE in (6,7)
          and bd.department_id = wpepb.owning_dept_id
          and bd.organization_id = wpepb.organization_id
          and lu1.lookup_type = ''BOM_EAM_COST_CATEGORY''
          and lu1.lookup_code = wpepb.maint_cost_category
          group by we.WIP_ENTITY_NAME,
                   mp.organization_code,
                   lu1.meaning,
                   bd.department_code,
                   wpepb.operation_seq_num' using p_legal_entity_id, p_cost_group_id, p_cost_type_id ;

     ELSIF (p_range = 2) THEN
       l_stmt_num := 40;
       OPEN l_ref_cur FOR '
        select we.WIP_ENTITY_NAME ENTITY_NAME,
               mp.organization_code ORGANIZATION,
               lu1.meaning CATEGORY,
               bd.department_code DEPARTMENT,
               wpepb.operation_seq_num OPERATION_SEQ,
               sum(nvl(wpepb.system_estimated_mat_cost,0)) EST_MATL_COST,
               sum(nvl(wpepb.system_estimated_lab_cost,0)) EST_LABR_COST,
               sum(nvl(wpepb.system_estimated_eqp_cost,0)) EST_EQUIP_COST,
               sum(nvl(wpepb.actual_mat_cost,0)) ACT_MATL_COST,
               sum(nvl(wpepb.actual_lab_cost,0)) ACT_LABR_COST,
               sum(nvl(wpepb.actual_eqp_cost,0)) ACT_EQUIP_COST,
               sum(nvl(wpepb.system_estimated_mat_cost,0)) - sum(nvl(wpepb.actual_mat_cost,0)) VAR_MATL_COST,
                sum(nvl(wpepb.system_estimated_lab_cost,0)) - sum(nvl(wpepb.actual_lab_cost,0)) VAR_LABR_COST,
                sum(nvl(wpepb.system_estimated_eqp_cost,0)) -  sum(nvl(wpepb.actual_eqp_cost,0)) VAR_EQUIP_COST

        FROM CST_PAC_EAM_PERIOD_BALANCES WPEPB,
             MTL_PARAMETERS mp,
             WIP_ENTITIES we,
             BOM_DEPARTMENTS bd,
             MFG_LOOKUPS lu1

        Where wpepb.legal_entity_id = :p_legal_entity_id
          and wpepb.cost_group_id = :p_cost_group_id
          and wpepb.Cost_type_id = :p_cost_type_id
          and wpepb.wip_entity_id =  we.wip_entity_id
          and we.wip_entity_id = :p_specific_workorder
          /*  1 - ALL , 2 - Specific  3 - Range */
          and wpepb.organization_id = mp.organization_id
          and we.organization_id = mp.organization_id
          and we.ENTITY_TYPE in (6,7)
          and bd.department_id = wpepb.owning_dept_id
          and bd.organization_id = wpepb.organization_id
          and lu1.lookup_type = ''BOM_EAM_COST_CATEGORY''
          and lu1.lookup_code = wpepb.maint_cost_category
          group by we.WIP_ENTITY_NAME,
                   mp.organization_code,
                   lu1.meaning,
                   bd.department_code,
                   wpepb.operation_seq_num' using p_legal_entity_id, p_cost_group_id, p_cost_type_id, p_specific_workorder ;

     ELSE
          l_stmt_num := 50;
          OPEN l_ref_cur FOR '
        SELECT we.WIP_ENTITY_NAME ENTITY_NAME,
               mp.organization_code ORGANIZATION,
               lu1.meaning CATEGORY,
               bd.department_code DEPARTMENT,
               wpepb.operation_seq_num OPERATION_SEQ,
               sum(nvl(wpepb.system_estimated_mat_cost,0)) EST_MATL_COST,
               sum(nvl(wpepb.system_estimated_lab_cost,0)) EST_LABR_COST,
               sum(nvl(wpepb.system_estimated_eqp_cost,0)) EST_EQUIP_COST,
               sum(nvl(wpepb.actual_mat_cost,0)) ACT_MATL_COST,
               sum(nvl(wpepb.actual_lab_cost,0)) ACT_LABR_COST,
               sum(nvl(wpepb.actual_eqp_cost,0)) ACT_EQUIP_COST,
               sum(nvl(wpepb.system_estimated_mat_cost,0)) - sum(nvl(wpepb.actual_mat_cost,0)) VAR_MATL_COST,
               sum(nvl(wpepb.system_estimated_lab_cost,0)) - sum(nvl(wpepb.actual_lab_cost,0)) VAR_LABR_COST,
                sum(nvl(wpepb.system_estimated_eqp_cost,0)) -  sum(nvl(wpepb.actual_eqp_cost,0)) VAR_EQUIP_COST

        FROM CST_PAC_EAM_PERIOD_BALANCES WPEPB,
             MTL_PARAMETERS mp,
             WIP_ENTITIES we,
             BOM_DEPARTMENTS bd,
             MFG_LOOKUPS lu1

        Where wpepb.legal_entity_id = :p_legal_entity_id
          and wpepb.cost_group_id = :p_cost_group_id
          and wpepb.Cost_type_id = :p_cost_type_id
          and wpepb.wip_entity_id =  we.wip_entity_id
          and we.wip_entity_name between :p_from_workorder
                                   AND :p_to_workorder
          and wpepb.organization_id = mp.organization_id
          and we.organization_id = mp.organization_id
          and we.ENTITY_TYPE in (6,7)
          and bd.department_id = wpepb.owning_dept_id
          and bd.organization_id = wpepb.organization_id
          and lu1.lookup_type = ''BOM_EAM_COST_CATEGORY''
          and lu1.lookup_code = wpepb.maint_cost_category
          group by we.WIP_ENTITY_NAME,
                   mp.organization_code,
                   lu1.meaning,
                   bd.department_code,
                   wpepb.operation_seq_num' using p_legal_entity_id, p_cost_group_id, p_cost_type_id, p_from_workorder, p_to_workorder ;
     END IF;

        -- create a new context with the SQL query
        l_stmt_num := 60;
        l_ctx := DBMS_XMLGEN.newContext (l_ref_cur);

        -- Set the row tag and rowset tag
        l_stmt_num := 70;
        DBMS_XMLGEN.setRowSetTag (l_ctx,'eAMWorkOrders');
        DBMS_XMLGEN.setRowTag (l_ctx,'eAMWorkOrderopSeq');

        -- generate XML data
        l_stmt_num := 80;
        DBMS_XMLGEN.getXML (l_ctx, l_xml_temp, DBMS_XMLGEN.none);

        -- remove the header (21 characters) and append the rest to xml output
        l_stmt_num := 90;
         l_total_rows_processed :=  DBMS_XMLGEN.getNumRowsProcessed(l_ctx);
        IF ( l_total_rows_processed > 0) THEN
                DBMS_LOB.erase (l_xml_temp, l_offset,1);
                DBMS_LOB.append (x_xml_doc, l_xml_temp);
        END IF;

        -- close context and free memory
        l_stmt_num := 100;
        DBMS_XMLGEN.closeContext(l_ctx);
        CLOSE l_ref_cur;
        DBMS_LOB.FREETEMPORARY (l_xml_temp);


       -- Add tag ROW_COUNT and total number rows
        l_stmt_num := 110;
        DBMS_LOB.writeappend (X_xml_doc, 11, '<ROW_COUNT>');
        DBMS_LOB.writeappend (X_xml_doc, 10, '<TOT_ROWS>');
        DBMS_LOB.writeappend (X_xml_doc, length (to_char(l_total_rows_processed)), to_char(l_total_rows_processed));
        DBMS_LOB.writeappend (X_xml_doc, 11, '</TOT_ROWS>');
        DBMS_LOB.writeappend (X_xml_doc, 12, '</ROW_COUNT>');

       l_stmt_num := 120;
        IF l_plog THEN
          fnd_log.string(
            fnd_log.level_procedure,
            l_module||'.'||l_stmt_num,
            'Exiting CST_eAM_WorkOrders_PVT.eAM_Est_Actual_details with '||
            'x_return_status = '||x_return_status||','||
            'x_msg_count = '||x_msg_count||','||
            'x_msg_data = '||x_msg_data
          );
        END IF;

EXCEPTION
  WHEN fnd_api.g_exc_unexpected_error THEN
    IF l_exceptionlog THEN
      fnd_msg_pub.add_exc_msg(
        p_pkg_name => 'CST_eAM_WorkOrders_PVT',
        p_procedure_name => 'eAM_Est_Actual_details',
        p_error_text => 'An exception has occurred.'
      );
      fnd_log.string(
        fnd_log.level_exception,
        l_module||'.'||l_stmt_num,
        'An exception has occurred.'
      );
      END IF;
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
END eAM_Est_Actual_details;

END CST_eAM_WorkOrders_PVT;

/
