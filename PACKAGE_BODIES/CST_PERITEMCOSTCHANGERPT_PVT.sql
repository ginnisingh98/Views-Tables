--------------------------------------------------------
--  DDL for Package Body CST_PERITEMCOSTCHANGERPT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_PERITEMCOSTCHANGERPT_PVT" AS
/* $Header: CSTVPICB.pls 120.2.12010000.3 2008/12/11 02:26:45 anjha ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'CST_PerItemCostChangeRpt_PVT';
G_LOG_LEVEL CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

--	API name 	: generateXML
--      Description     : The API is directly called by the Periodic Item Cost
--                        change report.
--      Parameters      :
--      p_legal_entity_id     : Legal Entity ID
--      p_cost_type_id        : Cost Type ID
--      p_pac_period_id       : PAC Period ID
--      p_cost_group_id       : Cost Group ID
--      p_category_set_id     : Category Set ID
--      p_item_master_org_id  : Item Master Organization ID
--      p_category_number     : Dummy Parameter
--      p_category_from       : From Category Name
--      p_category_to         : To Category Name
--      p_item_from           : From Item Name
--      p_item_to             : To Item Name
--      p_qty_precision       : Precision

PROCEDURE generateXML
          (errcode		  OUT NOCOPY 	VARCHAR2,
          errno			  OUT NOCOPY 	NUMBER,
          p_legal_entity_id	  IN		NUMBER,
          p_cost_type_id  	  IN		NUMBER,
          p_pac_period_id	  IN		NUMBER,
          p_cost_group_id  	  IN		NUMBER,
          p_category_set_id       IN            NUMBER,
          p_item_master_org_id    IN            NUMBER,
          p_category_number       IN            NUMBER,    /* Dummy */
          p_category_from         IN            VARCHAR2,
          p_category_to           IN            VARCHAR2,
          p_item_from             IN		VARCHAR2,
          p_item_to               IN		VARCHAR2,
          p_qty_precision         IN            NUMBER)
IS
          l_api_name		CONSTANT VARCHAR2(30)	:= 'generateXML';
          l_xml_doc  		CLOB;
          l_xml_temp            CLOB;
          l_amount 		NUMBER;
          l_offset 		NUMBER;
          l_length 		NUMBER;
          l_buffer 		VARCHAR2(32767);
          l_stmt_num            NUMBER;
          l_ref_cur    	        SYS_REFCURSOR;
          l_ctx		        NUMBER;
          l_return_status	VARCHAR2(1);
          l_msg_count		NUMBER;
          l_msg_data		VARCHAR2(2000);
          l_success             BOOLEAN;
          l_full_name           CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
          l_module              CONSTANT VARCHAR2(60) := 'cst.plsql.' || l_full_name;

          l_item_where_clause   VARCHAR2 (2400);
          l_category_where_clause VARCHAR2 (2400);

          l_uLog  CONSTANT BOOLEAN := FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL AND FND_LOG.TEST (FND_LOG.LEVEL_UNEXPECTED, l_module);
          l_errorLog CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
          l_eventLog CONSTANT BOOLEAN := l_errorLog AND (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
          l_pLog CONSTANT BOOLEAN := l_eventLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
	  /*Bug 7346254*/
 	  l_encoding             VARCHAR2(20);
 	  l_xml_header           VARCHAR2(100);
BEGIN
  IF (l_pLog) THEN
       FND_LOG.STRING ( FND_LOG.LEVEL_PROCEDURE,
                       l_module || '.begin',
                       '>>> ' || l_api_name || ':Parameters:
                       Legal Entity id: ' ||  p_legal_entity_id || '
                       Cost Type ID: '  || p_cost_type_id || '
                       Cost Group ID: ' || p_cost_group_id || '
                       PAC Period ID: ' || p_pac_period_id || '
                       Item Master Org ID: ' || p_item_master_org_id || '
                       Category Set ID: ' || p_category_set_id || '
                       Category Number: ' || p_category_number || '
                       Category From: ' || p_category_from || '
                       Category To: ' || p_category_to || '
                       From Item: ' || p_item_from || '
                       To Item: ' || p_item_to || '
                       Quantity Precision: ' || p_qty_precision);
  END IF;

  l_stmt_num := 10;
  /* Initialze variables */
  DBMS_LOB.createtemporary(l_xml_doc, TRUE);

  /*Bug 7346254: The following 3 lines of code ensures that XML data generated here uses the right encoding*/
  l_encoding       := fnd_profile.value('ICX_CLIENT_IANA_ENCODING');
  l_xml_header     := '<?xml version="1.0" encoding="'|| l_encoding ||'"?>';
  DBMS_LOB.writeappend (l_xml_doc, length(l_xml_header), l_xml_header);

  DBMS_LOB.createtemporary(l_xml_temp, TRUE);
  DBMS_LOB.writeappend (l_xml_doc, 8, '<REPORT>');
  FND_MSG_PUB.initialize;

  /* Add Parameters */
  l_stmt_num := 20;
  add_parameters  (p_api_version	=>     1.0,
                  p_init_msg_list       =>     FND_API.G_FALSE,
                  p_validation_level    =>     FND_API.G_VALID_LEVEL_FULL,
                  x_return_status	=>     l_return_status,
                  x_msg_count		=>     l_msg_count,
                  x_msg_data		=>     l_msg_data,
                  i_legal_entity_id     =>     p_legal_entity_id,
                  i_cost_type_id        =>     p_cost_type_id,
                  i_cost_group_id       =>     p_cost_group_id,
                  i_pac_period_id       =>     p_pac_period_id,
                  i_category_set_id     =>     p_category_set_id,
                  i_item_master_org_id  =>     p_item_master_org_id,
                  i_category_from       =>     p_category_from,
                  i_category_to         =>     p_category_to,
                  i_item_from           =>     p_item_from,
                  i_item_to             =>     p_item_to,
                  x_xml_doc		=>     l_xml_doc);

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

   l_stmt_num := 30;
   OPEN l_ref_cur FOR
   'SELECT  mc.concatenated_segments  CATEGORY,
            msi.concatenated_segments ITEM,
            cppb.inventory_item_id INVENTORY_ITEM_ID,
            cppb.txn_category,
            ml.meaning STEP,
            round (nvl(cppb.txn_category_qty,0), :p_qty_precision) CATEGORY_QUANTITY,
            round (nvl(cppb.period_quantity, 0), :p_qty_precision) CUMULATIVE_QUANTITY,
            round (sum (nvl(cppb.periodic_cost,0)), 2) PERIODIC_COST,
            round (sum (nvl(cppb.txn_category_value,0)), 2) AMOUNT,
            round (sum (nvl(cppb.period_balance,0)), 2) CAV,
            round (sum (nvl(cppb.variance_amount,0)), 2) VARIANCE_AMOUNT
   FROM     cst_pac_period_balances cppb
            , mfg_lookups ml
            , mtl_item_categories mic
            , mtl_categories_kfv mc
            , mtl_system_items_kfv msi
   WHERE    CPPB.cost_group_id = :p_cost_group_id
   AND	    CPPB.pac_period_id = :p_pac_period_id
   AND	    CPPB.inventory_item_id = MSI.inventory_item_id
   AND      ml.lookup_type = ''CST_PAC_TXN_CATEGORY''
   /* The MFG LOOKUP exhibits inconsistent behavior with fractional number
      as lookup code. To ensure that the txn category is between 2 and 3 but
      also use the mfg lookup for meaning mfg lookup has been seeded with 11
      for txn_category 2.5 */
   AND      ml.lookup_code = decode(cppb.txn_category,2.5,11,cppb.txn_category)
   AND      mic.inventory_item_id = cppb.inventory_item_id
   AND      mic.organization_id = :p_item_master_org_id
   AND      mic.category_set_id = :p_category_set_id
   AND      mc.category_id = mic.category_id
   AND      msi.organization_id = mic.organization_id
   AND      msi.inventory_item_id = cppb.inventory_item_id
   AND      msi.concatenated_segments between
                nvl(:p_item_from, msi.concatenated_segments)
            AND nvl(:p_item_to, msi.concatenated_segments)
   AND      mc.concatenated_segments between
                nvl(:p_category_from, mc.concatenated_segments)
            AND nvl(:p_category_to, mc.concatenated_segments)
   GROUP BY mc.concatenated_segments,
            msi.concatenated_segments,
            cppb.inventory_item_id,
            CPPB.txn_category,
            ml.meaning,
            cppb.txn_category_qty,
            cppb.period_quantity
   ORDER BY mc.concatenated_segments, msi.concatenated_segments, cppb.txn_category'
   USING  p_qty_precision, p_qty_precision, p_cost_group_id, p_pac_period_id,
          p_item_master_org_id, p_category_set_id, p_item_from, p_item_to,
          p_category_from, p_category_to;


   /* create new context */
   l_stmt_num := 40;
   l_ctx := DBMS_XMLGEN.newContext (l_ref_cur);
   DBMS_XMLGEN.setRowSetTag (l_ctx,'ROWSET');
   DBMS_XMLGEN.setRowTag (l_ctx, 'ROW');

   /* get XML */
   l_stmt_num := 50;
   DBMS_XMLGEN.getXML (l_ctx, l_xml_temp, DBMS_XMLGEN.none);

   IF (DBMS_XMLGEN.getNumRowsProcessed(l_ctx) > 0) THEN
     l_offset := DBMS_LOB.instr (lob_loc => l_xml_temp,
                                 pattern => '>',
                                 offset  => 1,
                                 nth     => 1);
     DBMS_LOB.erase (l_xml_temp, l_offset, 1);
     DBMS_LOB.append (l_xml_doc, l_xml_temp);
   ELSE
     DBMS_LOB.writeappend (l_xml_doc, 10, '<NO_DATA/>');
   END IF;


   DBMS_LOB.writeappend (l_xml_doc, 9, '</REPORT>');

   /* write to output file */
   l_stmt_num := 60;
   l_length := nvl(DBMS_LOB.getlength(l_xml_doc), 0);
   l_offset := 1;
   l_amount := 16383; /*Bug 7346238*/

   LOOP
    EXIT WHEN l_length <= 0;
    DBMS_LOB.read (l_xml_doc, l_amount, l_offset, l_buffer);
    FND_FILE.PUT (FND_FILE.OUTPUT, l_buffer);
    l_length := l_length - l_amount;
    l_offset := l_offset + l_amount;
   END LOOP;

   IF (l_eventLog) THEN
      FND_LOG.STRING (FND_LOG.LEVEL_EVENT,
                  l_module || '.' || l_stmt_num,
                  'Completed writing to output file');
   END IF;

  l_stmt_num := 70;
  DBMS_LOB.FREETEMPORARY (l_xml_doc);
  l_success := FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL', 'Request Completed Successfully');

  IF (l_pLog) THEN
    FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                    l_module || '.end',
                    '<<< ' || l_api_name);
  END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      FND_MSG_PUB.Count_And_Get(p_count => l_msg_count,
                                p_data  => l_msg_data);

      CST_UTILITY_PUB.writelogmessages (p_api_version => 1.0,
                                       p_msg_count    => l_msg_count,
                                       p_msg_data     => l_msg_data,
                                       x_return_status=> l_return_status);
      l_msg_data := SUBSTRB (SQLERRM,1,240);
      l_success := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', l_msg_data);
      IF (l_uLog) THEN
          FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED,
                    l_module || '.' || l_stmt_num,
                    l_msg_data);
      END IF;
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
      FND_MSG_PUB.Count_And_Get (p_count  =>  l_msg_count,
                                 p_data   =>  l_msg_data);

      CST_UTILITY_PUB.writelogmessages (p_api_version => 1.0,
                                        p_msg_count    => l_msg_count,
                                        p_msg_data     => l_msg_data,
                                        x_return_status=> l_return_status);
      l_msg_data := SUBSTRB (SQLERRM,1, 240);
      l_success := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', l_msg_data);
END generateXML;

PROCEDURE add_parameters (
                p_api_version        	IN		NUMBER,
                p_init_msg_list	        IN		VARCHAR2,
                p_validation_level	IN  		NUMBER,
                x_return_status	        OUT NOCOPY	VARCHAR2,
                x_msg_count		OUT NOCOPY	NUMBER,
                x_msg_data		OUT NOCOPY	VARCHAR2,
                i_legal_entity_id	IN		NUMBER,
                i_cost_type_id  	IN		NUMBER,
                i_pac_period_id		IN		NUMBER,
                i_cost_group_id  	IN		NUMBER,
                i_category_set_id       IN              NUMBER,
                i_item_master_org_id    IN              NUMBER,
                i_category_from         IN              VARCHAR2,
                i_category_to           IN              VARCHAR2,
                i_item_from             IN		VARCHAR2,
                i_item_to               IN		VARCHAR2,
                x_xml_doc 		IN OUT NOCOPY 	CLOB)
IS
         l_api_name	        CONSTANT VARCHAR2(30)	:= 'add_parameters';
         l_api_version          CONSTANT NUMBER 	:= 1.0;
         l_ref_cur    	        SYS_REFCURSOR;
         l_ctx		        NUMBER;
         l_xml_temp	        CLOB;
         l_offset	        PLS_INTEGER;
         l_stmt_num             NUMBER;
         l_legal_entity         HR_LEGAL_ENTITIES.NAME%TYPE;
         l_cost_type            CST_COST_TYPES.COST_TYPE%TYPE;
         l_cost_group           CST_COST_GROUPS.COST_GROUP%TYPE;
         l_pac_period           CST_PAC_PERIODS.PERIOD_NAME%TYPE;
         l_category_set         MTL_CATEGORY_SETS.CATEGORY_SET_NAME%TYPE;
         l_item                 VARCHAR2 (2000);
         l_category             VARCHAR2 (2000);
         l_item_master_org      MTL_PARAMETERS.ORGANIZATION_CODE%TYPE;
         l_currency_code        VARCHAR2(15);

         l_full_name            CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
         l_module               CONSTANT VARCHAR2(60) := 'cst.plsql.' || l_full_name;

         l_uLog  CONSTANT BOOLEAN := FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL AND FND_LOG.TEST (FND_LOG.LEVEL_UNEXPECTED, l_module);
         l_errorLog CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
         l_eventLog CONSTANT BOOLEAN := l_errorLog AND (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
         l_pLog CONSTANT BOOLEAN := l_eventLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);

BEGIN

  IF (l_pLog) THEN
   FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                  l_module || '.begin',
                  '>>> ' || l_api_name);
  END IF;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
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

   /* Initialize */
   DBMS_LOB.createtemporary(l_xml_temp, TRUE);

   /* Get Legal Entity Name */
   l_stmt_num := 10;
   SELECT  name
   INTO    l_legal_entity
   FROM    xle_entity_profiles
   WHERE   legal_entity_id = i_legal_entity_id;

   /* Get Cost Type Name */
   l_stmt_num := 20;
   SELECT  cost_type
   INTO    l_cost_type
   FROM    cst_cost_types
   WHERE   cost_type_id = i_cost_type_id;

   /* Get Cost Group Name */
   l_stmt_num := 30;
   SELECT  cost_group
   INTO    l_cost_group
   FROM    cst_cost_groups
   WHERE   cost_group_id = i_cost_group_id
   AND     cost_group_type = 2;

   /* Get PAC Period Name */
   l_stmt_num := 40;
   SELECT  period_name
   INTO    l_pac_period
   FROM    cst_pac_periods
   WHERE   pac_period_id = i_pac_period_id
   AND     legal_entity = i_legal_entity_id
   AND     cost_type_id = i_cost_type_id;

   /* Get Category Set Name */
   l_stmt_num := 50;
   SELECT  category_set_name
   INTO    l_category_set
   FROM    mtl_category_sets
   WHERE   category_set_id = i_category_set_id;

   /* Get Item Master Organization Name */
   l_stmt_num := 60;
   SELECT  organization_code
   INTO    l_item_master_org
   FROM    mtl_parameters
   WHERE   organization_id = i_item_master_org_id;

   /* Get Currency Code */
   l_stmt_num := 65;
   SELECT  currency_code
   INTO    l_currency_code
   FROM    gl_ledger_le_v
   WHERE   legal_entity_id = i_legal_entity_id
   AND     ledger_category_code = 'PRIMARY';

   l_stmt_num := 70;
   OPEN l_ref_cur FOR
      'SELECT :l_legal_entity LEGAL_ENTITY,
              :l_cost_type COST_TYPE,
              :l_pac_period PAC_PERIOD,
              :l_cost_group COST_GROUP,
              :l_category_set CATEGORY_SET,
              :l_item_master_org ITEM_MASTER_ORG,
              :i_category_from CATEGORY_FROM,
              :i_category_to CATEGORY_TO,
              :i_item_from ITEM_FROM,
              :i_item_to ITEM_TO,
              :l_currency_code CURRENCY_CODE
       FROM   dual'
   USING  l_legal_entity, l_cost_type, l_pac_period, l_cost_group,
          l_category_set, l_item_master_org, i_category_from, i_category_to,
          i_item_from, i_item_to, l_currency_code;

   /* create new context */
   l_stmt_num := 80;
   l_ctx := DBMS_XMLGEN.newContext (l_ref_cur);
   DBMS_XMLGEN.setRowSetTag (l_ctx,'PARAMETERS');
   DBMS_XMLGEN.setRowTag (l_ctx, NULL);

   /* get XML */
   l_stmt_num := 90;
   DBMS_XMLGEN.getXML (l_ctx, l_xml_temp, DBMS_XMLGEN.none);

   l_stmt_num := 100;
   /* Add the XML header as the first line of output. add data to end */
   IF (DBMS_XMLGEN.getNumRowsProcessed(l_ctx) > 0) THEN
     l_offset := DBMS_LOB.instr (lob_loc => l_xml_temp,
                                 pattern => '>',
                                 offset  => 1,
                                 nth     => 1);
     /*Bug 7346254*/
     /*DBMS_LOB.copy (x_xml_doc, l_xml_temp, l_offset + 1);
     DBMS_LOB.writeappend (x_xml_doc, 8, '<REPORT>');*/
     DBMS_LOB.erase(l_xml_temp, l_offset, 1);
     DBMS_LOB.append (x_xml_doc, l_xml_temp);
   END IF;

   l_stmt_num := 110;
   /* close context and free memory */
   DBMS_XMLGEN.closeContext(l_ctx);
   CLOSE l_ref_cur;
   DBMS_LOB.FREETEMPORARY (l_xml_temp);

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                              p_data  => x_msg_data);

   IF (l_pLog) THEN
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      l_module || '.end',
                      '<<< ' || l_api_name);
   END IF;
 EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
     (  p_count         	=>      x_msg_count,
        p_data          	=>      x_msg_data
     );
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     IF (l_uLog) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                        l_module || '.' || l_stmt_num,
                        SUBSTRB (SQLERRM , 1 , 240));
     END IF;

     IF 	FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
             FND_MSG_PUB.Add_Exc_Msg
             (	G_PKG_NAME,
                  l_api_name
             );
     END IF;
     FND_MSG_PUB.Count_And_Get
     (p_count         	=>      x_msg_count,
     p_data          	=>      x_msg_data
     );
END add_parameters;
END CST_PerItemCostChangeRpt_PVT;

/
