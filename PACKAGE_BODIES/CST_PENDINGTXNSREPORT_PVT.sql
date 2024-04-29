--------------------------------------------------------
--  DDL for Package Body CST_PENDINGTXNSREPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_PENDINGTXNSREPORT_PVT" AS
/* $Header: CSTVPTRB.pls 120.12.12010000.5 2008/11/13 22:25:56 mpuranik ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'CST_PendingTxnsReport_PVT';
G_LOG_LEVEL CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

--	API name 	: generateXML
--      Description     : The API is directly called by the Period Close Pending
--                        transactions report.
--      Parameters      :
--        p_org_id      : Organization ID
--        p_period_id   : Inventory accounting period for which XML data is generated
--        p_resolution_type:
--                            1 => All
--                            2 => Resolution Required
--                            3 => Resolution Recommended
--        p_transaction_type:
--                            1 => All
--                            2 => Unprocessed Material transactions
--                            3 => Uncosted Material transactions
--                            4 => Uncosted WIP transactions
--                            5 => Pending WSM interface transactions
--                            6 => Pending Receiving transactions
--                            7 => Pending Material Interface transactions
--                            8 => Pending Shop Floor Move transactions
--                            9 => Incomplete eAM Work Orders
--                           10 => Pending Shipping tranactions
PROCEDURE generateXML
          (errcode 		OUT NOCOPY 	VARCHAR2,
          errno 		OUT NOCOPY 	NUMBER,
          p_org_id 		IN 		NUMBER,
          p_period_id 		IN 		NUMBER,
          p_resolution_type 	IN 		NUMBER,
          p_transaction_type 	IN 		NUMBER)
IS
          l_api_name		CONSTANT VARCHAR2(30)	:= 'generateXML';
          l_xml_doc  		CLOB;
          l_period_start_date 	DATE;
          l_period_end_date 	DATE;
          l_amount 		NUMBER;
          l_offset 		NUMBER;
          l_length 		NUMBER;
          l_buffer 		VARCHAR2(32767);
          l_stmt_num            NUMBER;

          l_return_status	VARCHAR2(1);
          l_msg_count		NUMBER;
          l_msg_data		VARCHAR2(2000);
          l_success             BOOLEAN;
          l_record_count        NUMBER;
          l_temp_count          NUMBER;
          l_shipping_txn_hook   NUMBER;

          l_full_name           CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
          l_module              CONSTANT VARCHAR2(60) := 'cst.plsql.' || l_full_name;

          l_uLog  CONSTANT BOOLEAN := FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL AND FND_LOG.TEST (FND_LOG.LEVEL_UNEXPECTED, l_module);
          l_errorLog CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
          l_eventLog CONSTANT BOOLEAN := l_errorLog AND (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
          l_pLog CONSTANT BOOLEAN := l_eventLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
	  /*Bug 7305146*/
	  l_encoding             VARCHAR2(20);
	  l_xml_header           VARCHAR2(100);

BEGIN

  IF (l_pLog) THEN
       FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                       l_module || '.begin',
                       '>>> ' || l_api_name || ':Parameters:' ||
                       'Org id: ' ||  p_org_id ||
                       '; period id: '  || p_period_id ||
                       '; resolution type: ' || p_resolution_type ||
                       '; transaction type: ' || p_transaction_type);
  END IF;
  /* Initialze variables */
  DBMS_LOB.createtemporary(l_xml_doc, TRUE);

  /*Bug 7305146: The following 3 lines of code ensures that XML data generated here uses the right encoding*/
  l_encoding       := fnd_profile.value('ICX_CLIENT_IANA_ENCODING');
  l_xml_header     := '<?xml version="1.0" encoding="'|| l_encoding ||'"?>';
  DBMS_LOB.writeappend (l_xml_doc, length(l_xml_header), l_xml_header);

  DBMS_LOB.writeappend (l_xml_doc, 8, '<REPORT>');
  l_record_count := 0;

  l_stmt_num := 10;
  SELECT period_start_date, schedule_close_date
  INTO   l_period_start_date, l_period_end_date
  FROM   org_acct_periods
  WHERE  acct_period_id = p_period_id
  AND    organization_id = p_org_id;

  /* Initialize message stack */
  FND_MSG_PUB.initialize;

  /* Add Parameters */

  l_stmt_num := 20;
  add_parameters  (p_api_version	=>	1.0,
                  p_init_msg_list       =>      FND_API.G_FALSE,
                  p_validation_level    =>      FND_API.G_VALID_LEVEL_FULL,
                  x_return_status	=>	l_return_status,
                  x_msg_count		=>	l_msg_count,
                  x_msg_data		=>	l_msg_data,
                  i_org_id		=> 	p_org_id,
                  i_period_id		=>	p_period_id,
                  i_resolution_type	=>	p_resolution_type,
                  i_transaction_type	=>	p_transaction_type,
                  x_xml_doc		=>	l_xml_doc);

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  /* Validate which transactions need to be added for the parameter values */

  IF (p_resolution_type = 1 OR ((p_resolution_type = 2) AND
           (nvl(p_transaction_type,1) between 1 AND 5)))
  /* Resolution Type: All or resolution required */
  THEN
      IF (nvl(p_transaction_type,1) = 1 OR nvl(p_transaction_type,1) = 2)
      THEN
        l_stmt_num := 30;
            /* Transaction Type: All or Unprocessed MTL TRX */
        unprocessed_mtl_trx (p_api_version	=>	1.0,
                            p_init_msg_list     =>      FND_API.G_FALSE,
                            p_validation_level  =>      FND_API.G_VALID_LEVEL_FULL,
                            x_return_status	=>	l_return_status,
                            x_msg_count		=>	l_msg_count,
                            x_msg_data		=>	l_msg_data,
                            i_period_end_date	=>	l_period_end_date,
                            i_org_id		=>	p_org_id,
                            x_record_count      =>      l_temp_count,
                            x_xml_doc		=>	l_xml_doc);

        l_record_count := l_record_count + l_temp_count;

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;

      IF (nvl(p_transaction_type,1) = 1 OR nvl(p_transaction_type,1) = 3)
      THEN
            /* Transaction Type: All or Uncosted MTL TRX */
          l_stmt_num := 40;
          uncosted_mtl_trx(p_api_version	=>	1.0,
                           p_init_msg_list      =>      FND_API.G_FALSE,
                           p_validation_level   =>      FND_API.G_VALID_LEVEL_FULL,
                           x_return_status	=>	l_return_status,
                           x_msg_count		=>	l_msg_count,
                           x_msg_data		=>	l_msg_data,
                           i_period_end_date	=>	l_period_end_date,
                           i_org_id		=>	p_org_id,
                           x_record_count       =>      l_temp_count,
                           x_xml_doc		=>	l_xml_doc);

          l_record_count := l_record_count + l_temp_count;

          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
      END IF;

      IF (nvl(p_transaction_type,1) = 1 OR nvl(p_transaction_type,1) = 4)
      THEN
            /* Transaction Type: All or Uncosted WIP TRX */
            l_stmt_num := 50;
            uncosted_wip_trx (p_api_version	=> 1.0,
                              p_init_msg_list   => FND_API.G_FALSE,
                              p_validation_level=> FND_API.G_VALID_LEVEL_FULL,
                              x_return_status	=> l_return_status,
                              x_msg_count	=> l_msg_count,
                              x_msg_data	=> l_msg_data,
                              i_period_end_date	=> l_period_end_date,
                              i_org_id		=> p_org_id,
                              x_record_count    => l_temp_count,
                              x_xml_doc		=> l_xml_doc);

            l_record_count := l_record_count + l_temp_count;

            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
      END IF;

      IF (nvl(p_transaction_type,1) = 1 or nvl(p_transaction_type,1) = 5)
      THEN
            /* Transaction Type: All or Pending WSM TRX */
            l_stmt_num := 60;
            pending_wsm_trx (p_api_version	=>	1.0,
                            p_init_msg_list     =>      FND_API.G_FALSE,
                            p_validation_level  =>      FND_API.G_VALID_LEVEL_FULL,
                            x_return_status	=>	l_return_status,
                            x_msg_count		=>	l_msg_count,
                            x_msg_data		=>	l_msg_data,
                            i_period_end_date	=>	l_period_end_date,
                            i_org_id		=>	p_org_id,
                            x_record_count      =>      l_temp_count,
                            x_xml_doc		=>	l_xml_doc);

            l_record_count := l_record_count + l_temp_count;

            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
      END IF;

      /*Support for LCM*/
      IF (nvl(p_transaction_type,1) = 1 or nvl(p_transaction_type,1) = 11)
      THEN
            /* Transaction Type: All or Pending LCM TRX */
            l_stmt_num := 60;
            pending_lcm_trx (p_api_version	=>	1.0,
                            p_init_msg_list     =>      FND_API.G_FALSE,
                            p_validation_level  =>      FND_API.G_VALID_LEVEL_FULL,
                            x_return_status	=>	l_return_status,
                            x_msg_count		=>	l_msg_count,
                            x_msg_data		=>	l_msg_data,
                            i_period_end_date	=>	l_period_end_date,
                            i_org_id		=>	p_org_id,
                            x_record_count      =>      l_temp_count,
                            x_xml_doc		=>	l_xml_doc);

            l_record_count := l_record_count + l_temp_count;

            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
      END IF;
  END IF;

  IF (p_resolution_type = 1 OR
         ((p_resolution_type = 3) AND (nvl(p_transaction_type,1) IN (1, 6, 7, 8, 9))))
  /* Resolution Type: All or resolution recommended */
  THEN
      IF (nvl(p_transaction_type,1) = 1 OR nvl(p_transaction_type,1) = 6)
      THEN
            /* Transaction Type: All or Pending RCV TRX */
            l_stmt_num := 70;
            pending_rcv_trx (p_api_version	=>	1.0,
                            p_init_msg_list     =>      FND_API.G_FALSE,
                            p_validation_level  =>      FND_API.G_VALID_LEVEL_FULL,
                            x_return_status	=>	l_return_status,
                            x_msg_count		=>	l_msg_count,
                            x_msg_data		=>	l_msg_data,
                            i_period_end_date	=>	l_period_end_date,
                            i_org_id		=>	p_org_id,
                            x_record_count      =>      l_temp_count,
                            x_xml_doc		=>	l_xml_doc);

            l_record_count := l_record_count + l_temp_count;

            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
      END IF;

      IF (nvl(p_transaction_type,1) = 1 OR nvl(p_transaction_type,1) = 7)
      THEN
            /* Transaction Type: All or Pending material interface */
            l_stmt_num := 80;
            pending_mtl_interface_trx (p_api_version	 =>	1.0,
                                      p_init_msg_list    =>     FND_API.G_FALSE,
                                      p_validation_level =>     FND_API.G_VALID_LEVEL_FULL,
                                      x_return_status	 =>	l_return_status,
                                      x_msg_count        =>	l_msg_count,
                                      x_msg_data	 =>	l_msg_data,
                                      i_period_end_date	 =>	l_period_end_date,
                                      i_org_id		 =>	p_org_id,
                                      x_record_count     =>     l_temp_count,
                                      x_xml_doc		 =>	l_xml_doc);

            l_record_count := l_record_count + l_temp_count;

            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
      END IF;

      IF (nvl(p_transaction_type,1) = 1 OR nvl(p_transaction_type,1) = 8)
      THEN
            /* Transaction Type: All or Pending WIP Move trx */
            l_stmt_num := 90;
            pending_wip_move_trx (p_api_version		=>	1.0,
                                  p_init_msg_list       =>      FND_API.G_FALSE,
                                  p_validation_level    =>      FND_API.G_VALID_LEVEL_FULL,
                                  x_return_status	=>	l_return_status,
                                  x_msg_count		=>	l_msg_count,
                                  x_msg_data		=>	l_msg_data,
                                  i_period_end_date	=>	l_period_end_date,
                                  i_org_id		=>	p_org_id,
                                  x_record_count        =>      l_temp_count,
                                  x_xml_doc		=>	l_xml_doc);

            l_record_count := l_record_count + l_temp_count;

            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
      END IF;

      IF (nvl(p_transaction_type,1) = 1 OR nvl(p_transaction_type,1) = 9)
      THEN
            /* Transaction Type: All or Incomplete workorders */
            l_stmt_num := 100;
            incomplete_eam_wo (p_api_version	   =>  1.0,
                               p_init_msg_list     =>  FND_API.G_FALSE,
                               p_validation_level  =>  FND_API.G_VALID_LEVEL_FULL,
                               x_return_status	   =>  l_return_status,
                               x_msg_count	   =>  l_msg_count,
                               x_msg_data          =>  l_msg_data,
                               i_period_end_date   =>  l_period_end_date,
                               i_org_id		   =>  p_org_id,
                               x_record_count      =>  l_temp_count,
                               x_xml_doc	   =>  l_xml_doc);

            l_record_count := l_record_count + l_temp_count;

            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
      END IF;
  END IF;

  -- Check if shipping transactions are resolution required or resolution recommended
  l_stmt_num := 110;
  CST_PERIODCLOSEOPTION_PUB.shipping_txn_hook (p_api_version    => 1.0,
                                               i_org_id         => p_org_id,
                                               i_acct_period_id => p_period_id,
                                               x_close_option   => l_shipping_txn_hook,
                                               x_return_status  => l_return_status,
                                               x_msg_count      => l_msg_count,
                                               x_msg_data       => l_msg_data);
  IF (l_return_status <> 0) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- l_shipping_txn_hook = 0 if shipping transactions are resolution required
  --                     = 1 if shipping transactions are resolution recommended
  IF ((p_resolution_type = 1 OR (p_resolution_type = 2 AND l_shipping_txn_hook = 0)
      OR (p_resolution_type = 3 AND l_shipping_txn_hook = 1)) and
       (nvl(p_transaction_type,1) = 1 OR nvl(p_transaction_type,1) = 10))
  THEN
        /* Transaction Type: All or Pending Shipping trx */
        l_stmt_num := 120;
        pending_shipping_trx   (p_api_version	        =>	1.0,
                                p_init_msg_list         =>      FND_API.G_FALSE,
                                p_validation_level      =>      FND_API.G_VALID_LEVEL_FULL,
                                x_return_status	        =>	l_return_status,
                                x_msg_count		=>	l_msg_count,
                                x_msg_data		=>	l_msg_data,
                                i_period_start_date	=>	l_period_start_date,
                                i_period_end_date	=>	l_period_end_date,
                                i_org_id		=>	p_org_id,
                                x_record_count          =>      l_temp_count,
                                x_xml_doc		=>	l_xml_doc);

        l_record_count := l_record_count + l_temp_count;

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
  END IF;

  IF (l_record_count = 0) THEN
     DBMS_LOB.writeappend (l_xml_doc, 10, '<NO_DATA/>');
  END IF;
  DBMS_LOB.writeappend (l_xml_doc, 9, '</REPORT>');

  /* write to output file */

  l_length := nvl(DBMS_LOB.getlength(l_xml_doc), 0);
  l_offset := 1;
  l_amount := 16383;

  l_stmt_num := 130;
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

  /* free temporary memory */
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


PROCEDURE add_parameters
         (p_api_version        	IN		NUMBER,
         p_init_msg_list	IN		VARCHAR2,
         p_validation_level	IN  		NUMBER,
         x_return_status	OUT NOCOPY	VARCHAR2,
         x_msg_count		OUT NOCOPY	NUMBER,
         x_msg_data		OUT NOCOPY	VARCHAR2,
         i_org_id 		IN 		NUMBER,
         i_period_id 		IN 		NUMBER,
         i_resolution_type 	IN 		NUMBER,
         i_transaction_type 	IN 		NUMBER,
         x_xml_doc 		IN OUT NOCOPY 	CLOB)
IS
         l_api_name	        CONSTANT VARCHAR2(30)	:= 'add_parameters';
         l_api_version          CONSTANT NUMBER 	:= 1.0;
         l_ref_cur    	        SYS_REFCURSOR;
         l_ctx		        NUMBER;
         l_xml_temp	        CLOB;
         l_offset	        PLS_INTEGER;
         l_org_code             CST_ORGANIZATION_DEFINITIONS.ORGANIZATION_CODE%TYPE;
         l_period_name          ORG_ACCT_PERIODS.PERIOD_NAME%TYPE;
         l_resolution_type      MFG_LOOKUPS.MEANING%TYPE;
         l_temp                 VARCHAR2(240);
         l_stmt_num             NUMBER;

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

   l_stmt_num := 10;
   SELECT ORGANIZATION_CODE
   INTO	  l_org_code
   FROM	  mtl_parameters
   WHERE  organization_id = i_org_id;

   l_stmt_num := 20;
   SELECT PERIOD_NAME
   INTO	  l_period_name
   FROM   org_acct_periods
   WHERE  acct_period_id = i_period_id
   AND    organization_id = i_org_id;

   l_stmt_num := 25;
   SELECT ML.MEANING
   INTO   l_resolution_type
   FROM   MFG_LOOKUPS ml
   WHERE  ml.lookup_type = 'CST_SRS_RESOLUTION_TYPES'
   AND    ml.lookup_code = i_resolution_type;

   /* Open Ref Cursor */

   l_stmt_num := 30;
   OPEN l_ref_cur FOR
     'SELECT :l_org_code ORG_CODE,
             :l_period_name PERIOD_NAME,
             :l_resolution_type RESOLUTION_TYPE,
             ml.meaning TXN_TYPE
      FROM   MFG_LOOKUPS ml
      WHERE  ml.lookup_type = ''CST_SRS_TRANSACTION_TYPES''
      AND    ml.lookup_code = :i_transaction_type'
   USING  l_org_code, l_period_name, l_resolution_type, i_transaction_type;

   /* create new context */
   l_stmt_num := 40;
   l_ctx := DBMS_XMLGEN.newContext (l_ref_cur);
   DBMS_XMLGEN.setRowSetTag (l_ctx,'PARAMETERS');
   DBMS_XMLGEN.setRowTag (l_ctx, NULL);

   /* get XML */
   l_stmt_num := 50;
   DBMS_XMLGEN.getXML (l_ctx, l_xml_temp, DBMS_XMLGEN.none);

   /* Add the XML header as the first line of output. add data to end */
   IF (DBMS_XMLGEN.getNumRowsProcessed(l_ctx) > 0) THEN
     l_offset := DBMS_LOB.instr (lob_loc => l_xml_temp,
                                 pattern => '>',
                                 offset  => 1,
                                 nth     => 1);
     /*Bug 7305146*/
     /*DBMS_LOB.copy (x_xml_doc, l_xml_temp, l_offset + 1);
     DBMS_LOB.writeappend (x_xml_doc, 8, '<REPORT>');*/
     DBMS_LOB.erase(l_xml_temp, l_offset, 1);
     DBMS_LOB.append (x_xml_doc, l_xml_temp);
   END IF;

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
           (  	p_count         	=>      x_msg_count,
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

PROCEDURE unprocessed_mtl_trx
          (p_api_version       	IN		NUMBER,
          p_init_msg_list	IN		VARCHAR2,
          p_validation_level	IN  		NUMBER,
          x_return_status	OUT NOCOPY	VARCHAR2,
          x_msg_count		OUT NOCOPY	NUMBER,
          x_msg_data		OUT NOCOPY	VARCHAR2,
          i_period_end_date 	IN 		DATE,
          i_org_id 		IN 		NUMBER,
          x_record_count        OUT NOCOPY      NUMBER,
          x_xml_doc 		IN OUT NOCOPY 	CLOB)
IS
          l_api_name	        CONSTANT VARCHAR2(30)	:= 'unprocessed_mtl_trx';
          l_api_version         CONSTANT NUMBER 	:= 1.0;
          l_ref_cur    	        SYS_REFCURSOR;
          l_ctx		        NUMBER;
          l_xml_temp	        CLOB;
          l_offset	        PLS_INTEGER;
          l_stmt_num            NUMBER;

          l_full_name           CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
          l_module              CONSTANT VARCHAR2(60) := 'cst.plsql.' || l_full_name;

          l_uLog  CONSTANT BOOLEAN := FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL AND  FND_LOG.TEST (FND_LOG.LEVEL_UNEXPECTED, l_module);
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

  /* Open Ref Cursor */
  l_stmt_num := 10;
  OPEN l_ref_cur FOR
     'SELECT  mmtt.TRANSACTION_TEMP_ID,
              mmtt.TRANSACTION_HEADER_ID,
              mmtt.SOURCE_CODE,
              mif.ITEM_NUMBER,
              mmtt.INVENTORY_ITEM_ID,
              mmtt.SUBINVENTORY_CODE,
              mmtt.LOCATOR_ID,
              mmtt.REVISION,
              mtlt.LOT_NUMBER,
              msnt.FM_SERIAL_NUMBER,
              msnt.TO_SERIAL_NUMBER,
              mmtt.TRANSACTION_DATE,
              mmtt.TRANSACTION_QUANTITY,
              mmtt.PRIMARY_QUANTITY,
              mmtt.TRANSACTION_UOM,
              mmtt.TRANSACTION_COST,
              mtt.TRANSACTION_TYPE_NAME,
              mmtt.TRANSACTION_TYPE_ID,
              ml.MEANING  TRANSACTION_ACTION,     /*TXN Action meaning*/
              mmtt.TRANSACTION_ACTION_ID,
              mtst.TRANSACTION_SOURCE_TYPE_NAME,
              mmtt.TRANSACTION_SOURCE_TYPE_ID,
              mmtt.TRANSACTION_SOURCE_ID,
              mmtt.RCV_TRANSACTION_ID,
              mmtt.MOVE_ORDER_LINE_ID,
              mmtt.COMPLETION_TRANSACTION_ID,
              mmtt.PROCESS_FLAG,
              mmtt.LOCK_FLAG,
              mmtt.TRANSACTION_MODE,
              ml1.MEANING TRANSACTION_MODE,       /*TXN mode meaning*/
              mmtt.REQUEST_ID,
              mmtt.TRANSFER_SUBINVENTORY,
              mmtt.TRANSFER_TO_LOCATION,
              mmtt.PICK_SLIP_NUMBER,
              mmtt.PICKING_LINE_ID,
              mmtt.RESERVATION_ID,
              mmtt.WMS_TASK_TYPE,
              mmtt.STANDARD_OPERATION_ID,
              mmtt.ERROR_CODE,
              mmtt.ERROR_EXPLANATION
     FROM     MTL_MATERIAL_TRANSACTIONS_TEMP mmtt,
              MTL_ITEM_FLEXFIELDS mif,
              MTL_TRANSACTION_TYPES mtt,
              MTL_TXN_SOURCE_TYPES mtst,
              MFG_LOOKUPS ml,
              MFG_LOOKUPS ml1,
              MTL_TRANSACTION_LOTS_TEMP mtlt,
              MTL_SERIAL_NUMBERS_TEMP msnt
     WHERE    mmtt.organization_id = :i_org_id
     AND      mmtt.transaction_date <= :i_period_end_date
     AND      NVL(mmtt.transaction_status,0) <> 2
     AND      mmtt.inventory_item_id = mif.inventory_item_id(+)
     AND      mmtt.organization_id = mif.organization_id(+)
     AND      mmtt.transaction_type_id = mtt.transaction_type_id(+)
     AND      mmtt.transaction_source_type_id = mtst.transaction_source_type_id(+)
     AND      mmtt.transaction_action_id = ml.lookup_code
     AND      ml.lookup_type = ''MTL_TRANSACTION_ACTION''
     AND      (mtlt.transaction_temp_id (+) = mmtt.transaction_temp_id
                 AND msnt.transaction_temp_id (+) = mmtt.transaction_temp_id)
     AND      ml1.lookup_type = ''MTL_TRANSACTION_MODE''
     AND      ml1.lookup_code(+) = mmtt.transaction_mode
        ORDER BY mmtt.TRANSACTION_DATE, TRANSACTION_TEMP_ID'
     USING i_org_id, i_period_end_date;

  /* create new context */
  l_stmt_num := 20;
  l_ctx := DBMS_XMLGEN.newContext (l_ref_cur);
  DBMS_XMLGEN.setRowSetTag (l_ctx,'UNPROCESSED_MTL_TRX');
  DBMS_XMLGEN.setRowTag (l_ctx,'UNPROCESSED_MTL_TRANSACTION');

  /* get XML */
  l_stmt_num := 30;
  DBMS_XMLGEN.getXML (l_ctx, l_xml_temp, DBMS_XMLGEN.none);

  x_record_count := DBMS_XMLGEN.getNumRowsProcessed(l_ctx);
  /* remove the header and append the rest to xml output */
  IF (x_record_count > 0) THEN
        /* Find the number of characters in the header and delete
        them. Header ends with '>'. Hence find first occurrence of
        '>' in the CLOB */
          l_offset := DBMS_LOB.instr (lob_loc => l_xml_temp,
                                      pattern => '>',
                                      offset  => 1,
                                      nth     => 1);
          DBMS_LOB.erase (l_xml_temp, l_offset, 1);
          DBMS_LOB.append (x_xml_doc, l_xml_temp);
  END IF;
  /* close context and free memory */
  DBMS_XMLGEN.closeContext(l_ctx);
  CLOSE l_ref_cur;
  DBMS_LOB.FREETEMPORARY (l_xml_temp);

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                            p_data  => x_msg_data);

  IF (l_pLog) THEN
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      l_module || '.end',
                      '<<< ' || l_api_name);
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                                     p_data  => x_msg_data);
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
          FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                                     p_data => x_msg_data);
END unprocessed_mtl_trx;

PROCEDURE uncosted_mtl_trx
          (p_api_version       	IN		NUMBER,
          p_init_msg_list	IN		VARCHAR2,
          p_validation_level	IN  		NUMBER,
          x_return_status	OUT NOCOPY	VARCHAR2,
          x_msg_count		OUT NOCOPY	NUMBER,
          x_msg_data		OUT NOCOPY	VARCHAR2,
          i_period_end_date 	IN 		DATE,
          i_org_id 		IN 		NUMBER,
          x_record_count        OUT NOCOPY      NUMBER,
          x_xml_doc 		IN OUT NOCOPY 	CLOB)
IS
          l_api_name		CONSTANT VARCHAR2(30)	:= 'uncosted_mtl_trx';
          l_api_version        	CONSTANT NUMBER 	:= 1.0;
          l_ref_cur    		SYS_REFCURSOR;
          l_ctx			NUMBER;
          l_xml_temp		CLOB;
          l_offset		PLS_INTEGER;
          l_stmt_num            NUMBER;

          l_full_name           CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
          l_module              CONSTANT VARCHAR2(60) := 'cst.plsql.' || l_full_name;

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
                                      G_PKG_NAME)
  THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean (p_init_msg_list) THEN
          FND_MSG_PUB.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /* Initialize */
  DBMS_LOB.createtemporary(l_xml_temp, TRUE);

  /* Open Ref Cursor */
  l_stmt_num := 10;
  OPEN l_ref_cur FOR
    'SELECT  mmt.TRANSACTION_ID,
             mif.ITEM_NUMBER,
             mmt.INVENTORY_ITEM_ID,
             mmt.TRANSACTION_DATE,
             mmt.TRANSACTION_QUANTITY,
             mmt.PRIMARY_QUANTITY,
             mmt.TRANSACTION_UOM,
             mtt.TRANSACTION_TYPE_NAME,
             mmt.TRANSACTION_TYPE_ID,
             mmt.SUBINVENTORY_CODE,
             mmt.LOCATOR_ID,
             mmt.REVISION,
             mmt.COSTED_FLAG,
             mmt.COST_GROUP_ID,
             mmt.TRANSACTION_GROUP_ID,
             mmt.TRANSACTION_SET_ID,
             mmt.LAST_UPDATE_DATE,
             mmt.TRANSACTION_ACTION_ID,
             mmt.COMPLETION_TRANSACTION_ID,
             mtst.TRANSACTION_SOURCE_TYPE_NAME,
             mmt.TRANSACTION_SOURCE_TYPE_ID,
             mmt.TRANSACTION_SOURCE_ID,
             mmt.TRANSACTION_SOURCE_NAME,
             mmt.SOURCE_CODE,
             mmt.SOURCE_LINE_ID,
             mmt.REQUEST_ID,
             mmt.TRANSFER_TRANSACTION_ID,
             mmt.TRANSFER_ORGANIZATION_ID,
             mp.ORGANIZATION_CODE TRANSFER_ORGANIZATION_CODE,
             mmt.TRANSFER_SUBINVENTORY,
             mmt.ERROR_CODE,
             mmt.ERROR_EXPLANATION
    FROM     mtl_material_transactions mmt,
             mtl_item_flexfields mif,
             mtl_transaction_types mtt,
             mtl_txn_source_types mtst,
             mtl_parameters mp
    WHERE    mmt.organization_id = :i_org_id
    AND      mmt.transaction_date <= :i_period_end_date
    AND      mmt.costed_flag in (''N'',''E'')
    AND      mmt.inventory_item_id = mif.inventory_item_id (+)
    AND      mmt.organization_id = mif.organization_id (+)
    AND      mmt.transaction_type_id = mtt.transaction_type_id (+)
    AND      mmt.transaction_source_type_id = mtst.transaction_source_type_id(+)
    AND      mmt.transfer_organization_id = mp.organization_id (+)
    ORDER BY mmt.TRANSACTION_DATE, mmt.TRANSACTION_ID'
  USING  i_org_id, i_period_end_date;

  /* create new context */
  l_stmt_num := 20;
  l_ctx := DBMS_XMLGEN.newContext (l_ref_cur);
  DBMS_XMLGEN.setRowSetTag (l_ctx,'UNCOSTED_MTL_TRX');
  DBMS_XMLGEN.setRowTag (l_ctx,'UNCOSTED_MTL_TRANSACTION');

  /* get XML */
  l_stmt_num := 30;
  DBMS_XMLGEN.getXML (l_ctx, l_xml_temp, DBMS_XMLGEN.none);

  x_record_count := DBMS_XMLGEN.getNumRowsProcessed(l_ctx);
  /* remove the header and append the rest to xml output */
  IF (x_record_count > 0) THEN
       /* Find the number of characters in the header and delete
        them. Header ends with '>'. Hence find first occurrence of
        '>' in the CLOB */
          l_offset := DBMS_LOB.instr (lob_loc => l_xml_temp,
                                      pattern => '>',
                                      offset  => 1,
                                      nth     => 1);
          DBMS_LOB.erase (l_xml_temp, l_offset,1);
          DBMS_LOB.append (x_xml_doc, l_xml_temp);
  END IF;

  /* close context and free memory */
  DBMS_XMLGEN.closeContext(l_ctx);
  CLOSE l_ref_cur;
  DBMS_LOB.FREETEMPORARY (l_xml_temp);

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                            p_data  => x_msg_data);

  IF (l_pLog) THEN
     FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                     l_module || '.end',
                     '<<< ' || l_api_name);
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                                     p_data  => x_msg_data);
  WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF (l_uLog) THEN
            FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED,
                           l_module || '.' || l_stmt_num,
                           SUBSTRB (SQLERRM , 1 , 240));
          END IF;

          IF 	FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
                  FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                                     p_data  => x_msg_data);
END uncosted_mtl_trx;

PROCEDURE uncosted_wip_trx
          (p_api_version        IN		NUMBER,
          p_init_msg_list	IN		VARCHAR2,
          p_validation_level	IN  		NUMBER,
          x_return_status	OUT NOCOPY	VARCHAR2,
          x_msg_count		OUT NOCOPY	NUMBER,
          x_msg_data		OUT NOCOPY	VARCHAR2,
          i_period_end_date 	IN 		DATE,
          i_org_id 		IN 		NUMBER,
          x_record_count        OUT NOCOPY      NUMBER,
          x_xml_doc 		IN OUT NOCOPY 	CLOB)
IS
          l_api_name		CONSTANT VARCHAR2(30)	:= 'uncosted_wip_trx';
          l_api_version         CONSTANT NUMBER 	:= 1.0;
          l_ref_cur    		SYS_REFCURSOR;
          l_ctx			NUMBER;
          l_xml_temp		CLOB;
          l_offset		PLS_INTEGER;
          l_stmt_num            NUMBER;

          l_full_name           CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
          l_module              CONSTANT VARCHAR2(60) := 'cst.plsql.' || l_full_name;

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

  /* Open Ref Cursor */
  l_stmt_num := 10;
  OPEN l_ref_cur FOR
    'SELECT  wcti.TRANSACTION_ID,
             mif.ITEM_NUMBER,
             wcti.PRIMARY_ITEM_ID,
             wcti.WIP_ENTITY_ID,
             wcti.WIP_ENTITY_NAME,
             wcti.ENTITY_TYPE,
             wcti.REPETITIVE_SCHEDULE_ID,
             wcti.TRANSACTION_DATE,
             wcti.TRANSACTION_QUANTITY,
             wcti.TRANSACTION_UOM,
             wcti.TRANSACTION_TYPE,
             ml.meaning TRANSACTION_TYPE_CODE,
             wcti.AUTOCHARGE_TYPE,
             wcti.BASIS_TYPE,
             ml1.meaning BASIS_TYPE_CODE,
             wcti.RESOURCE_TYPE,
             wcti.STANDARD_RATE_FLAG,
             wcti.REQUEST_ID,
             wcti.GROUP_ID,
             wcti.OPERATION_SEQ_NUM,
             wcti.RESOURCE_SEQ_NUM,
             wcti.RESOURCE_ID,
             br.RESOURCE_CODE,
             wcti.COMPLETION_TRANSACTION_ID,
             wcti.MOVE_TRANSACTION_ID,
             wcti.PROCESS_PHASE,
             wcti.PROCESS_STATUS,
             ml2.meaning PROCESS_STATUS_CODE,
             wcti.SOURCE_CODE,
             wcti.SOURCE_LINE_ID,
             wtie.ERROR_COLUMN,
             wtie.ERROR_MESSAGE
    FROM     wip_cost_txn_interface wcti,
             wip_txn_interface_errors wtie,
             mtl_item_flexfields mif,
             bom_resources br,
             mfg_lookups ml,
             mfg_lookups ml1,
             mfg_lookups ml2
    WHERE    wcti.organization_id = :i_org_id
    AND      transaction_date <= :i_period_end_date
    AND	     wtie.transaction_id (+) = wcti.transaction_id
    AND      wcti.organization_id = mif.organization_id (+)
    AND      NVL( wcti.primary_item_id, -1) = mif.inventory_item_id(+)
    AND      wcti.resource_id = br.resource_id (+)
    AND      ml.lookup_type = ''WIP_TRANSACTION_TYPE''
    AND      ml.lookup_code(+) = wcti.transaction_type
    AND      ml1.lookup_type = ''CST_BASIS''
    AND      ml1.lookup_code(+) = wcti.basis_type
    AND      ml2.lookup_type = ''WIP_PROCESS_STATUS''
    AND      ml2.lookup_code = wcti.process_status
    ORDER BY wcti.TRANSACTION_DATE, wcti.TRANSACTION_ID'
  USING  i_org_id, i_period_end_date;

  /* create new context */
  l_stmt_num := 20;
  l_ctx := DBMS_XMLGEN.newContext (l_ref_cur);
  DBMS_XMLGEN.setRowSetTag (l_ctx,'UNCOSTED_WIP_TRX');
  DBMS_XMLGEN.setRowTag (l_ctx,'UNCOSTED_WIP_TRANSACTION');

  /* get XML */
  l_stmt_num := 30;
  DBMS_XMLGEN.getXML (l_ctx, l_xml_temp, DBMS_XMLGEN.none);

  x_record_count := DBMS_XMLGEN.getNumRowsProcessed(l_ctx);
  /* remove the header and append the rest to xml output */
  IF (x_record_count > 0) THEN
       /* Find the number of characters in the header and delete
        them. Header ends with '>'. Hence find first occurrence of
        '>' in the CLOB */
          l_offset := DBMS_LOB.instr (lob_loc => l_xml_temp,
                                      pattern => '>',
                                      offset  => 1,
                                      nth     => 1);
          DBMS_LOB.erase (l_xml_temp, l_offset,1);
          DBMS_LOB.append (x_xml_doc, l_xml_temp);
  END IF;
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
          FND_MSG_PUB.Count_And_Get (p_count => x_msg_count ,
                                     p_data  => x_msg_data);
  WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF (l_uLog) THEN
            FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED,
                           l_module || '.' || l_stmt_num,
                           SUBSTRB (SQLERRM , 1 , 240));
          END IF;

          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
                  FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                                     p_data  => x_msg_data);
END uncosted_wip_trx;

PROCEDURE pending_wsm_trx
          (p_api_version       	IN		NUMBER,
          p_init_msg_list	IN		VARCHAR2,
          p_validation_level	IN  		NUMBER,
          x_return_status	OUT NOCOPY	VARCHAR2,
          x_msg_count		OUT NOCOPY	NUMBER,
          x_msg_data		OUT NOCOPY	VARCHAR2,
          i_period_end_date 	IN 		DATE,
          i_org_id 		IN 		NUMBER,
          x_record_count        OUT NOCOPY      NUMBER,
          x_xml_doc 		IN OUT NOCOPY 	CLOB)
IS
          l_api_name	        CONSTANT VARCHAR2(30)	:= 'pending_wsm_trx';
          l_api_version         CONSTANT NUMBER 	:= 1.0;
          l_ref_cur    	        SYS_REFCURSOR;
          l_ctx		        NUMBER;
          l_xml_wsmti	        CLOB;
          l_xml_wlmti		CLOB;
          l_xml_wlsmi		CLOB;
          l_offset	        PLS_INTEGER;
          l_wsmti_flag		VARCHAR2(1);
          l_wlmti_flag		VARCHAR2(1);
          l_wlsmi_flag		VARCHAR2(1);
          l_stmt_num            NUMBER;

          l_full_name           CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
          l_module              CONSTANT VARCHAR2(60) := 'cst.plsql.' || l_full_name;

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
  DBMS_LOB.createtemporary(l_xml_wsmti, TRUE);
  DBMS_LOB.createtemporary(l_xml_wlmti, TRUE);
  DBMS_LOB.createtemporary(l_xml_wlsmi, TRUE);
  l_wsmti_flag := FND_API.G_FALSE;
  l_wlmti_flag := FND_API.G_FALSE;
  l_wlsmi_flag := FND_API.G_FALSE;

  /* Open Ref Cursor for WSM_SPLIT_MERGE_TXN_INTERFACE */
  l_stmt_num := 10;
  OPEN l_ref_cur FOR
    'SELECT   wsmti.HEADER_ID,
              wsmti.TRANSACTION_TYPE_ID,
              ml.meaning TRANSACTION_TYPE_NAME,
              wsmti.TRANSACTION_DATE,
              wsmti.PROCESS_STATUS,
              ml1.meaning PROCESS_STATUS_CODE,
              wsmti.TRANSACTION_ID,
              /* Pick resulting lot as reference lot for merge and bonus
              Pick starting lot for other transactions */
              decode (wsmti.transaction_type_id,
                     2, wrji.wip_entity_name,
                     4, wrji.wip_entity_name,
                     wsji.wip_entity_name) REFERENCE_LOT,
              wsmti.GROUP_ID,
              wsmti.REQUEST_ID,
              wsmti.ERROR_MESSAGE
    FROM      wsm_split_merge_txn_interface wsmti,
              wsm_starting_jobs_interface wsji,
              wsm_resulting_jobs_interface wrji,
              mfg_lookups ml,
              mfg_lookups ml1
    WHERE     wsmti.header_id = wsji.header_id(+)
    AND       wsmti.header_id = wrji.header_id(+)
    AND       ml.lookup_type = ''WSM_WIP_LOT_TXN_TYPE''
    AND       ml.lookup_code = wsmti.transaction_type_id
    AND       ml1.lookup_type = ''WIP_PROCESS_STATUS''
    AND       ml1.lookup_code = wsmti.process_status
    AND       wsmti.organization_id = :i_org_id
    AND       wsmti.process_status <> 4
    AND       wsmti.transaction_date <= :i_period_end_date
    ORDER     BY TRANSACTION_DATE, HEADER_ID'
  USING  i_org_id, i_period_end_date;

  /* create new context */
  l_stmt_num := 20;
  l_ctx := DBMS_XMLGEN.newContext (l_ref_cur);
  DBMS_XMLGEN.setRowSetTag (l_ctx,'PENDING_WSMTI_TRX');
  DBMS_XMLGEN.setRowTag (l_ctx,'PENDING_WSMTI_TRANSACTION');

  /* get XML */
  l_stmt_num := 30;
  DBMS_XMLGEN.getXML (l_ctx, l_xml_wsmti, DBMS_XMLGEN.none);

  x_record_count := DBMS_XMLGEN.getNumRowsProcessed(l_ctx);
  /* remove the header*/
  IF (x_record_count > 0) THEN
          l_wsmti_flag := FND_API.G_TRUE;
          l_offset := DBMS_LOB.instr (lob_loc => l_xml_wsmti,
                                      pattern => '>',
                                      offset  => 1,
                                      nth     => 1);
          DBMS_LOB.erase (l_xml_wsmti, l_offset,1);
  END IF;
  /* close context */
  DBMS_XMLGEN.closeContext(l_ctx);
  CLOSE l_ref_cur;

  IF (l_eventLog) THEN
            FND_LOG.STRING (FND_LOG.LEVEL_EVENT,
                                l_module || '.' || l_stmt_num,
                                'Completed WSMTI transactions');
  END IF;

  /* Open Ref Cursor for WSM_LOT_MOVE_TXN_INTERFACE */
  l_stmt_num := 40;
  OPEN l_ref_cur FOR
    'SELECT  wlmti.TRANSACTION_ID,
             wlmti.REQUEST_ID,
             wlmti.GROUP_ID,
             wlmti.SOURCE_CODE,
             wlmti.SOURCE_LINE_ID,
             wlmti.STATUS,
             ml.MEANING STATUS_CODE,
             wlmti.TRANSACTION_TYPE,
             wlmti.ORGANIZATION_ID,
             wlmti.ORGANIZATION_CODE,
             wlmti.WIP_ENTITY_ID,
             wlmti.WIP_ENTITY_NAME,
             wlmti.ENTITY_TYPE,
             wlmti.PRIMARY_ITEM_ID,
             mif.ITEM_NUMBER,
             wlmti.REPETITIVE_SCHEDULE_ID,
             wlmti.TRANSACTION_DATE,
             wlmti.ACCT_PERIOD_ID,
             wlmti.FM_OPERATION_SEQ_NUM,
             wlmti.FM_OPERATION_CODE,
             wlmti.FM_DEPARTMENT_ID,
             wlmti.FM_DEPARTMENT_CODE,
             wlmti.TO_OPERATION_SEQ_NUM,
             wlmti.TO_OPERATION_CODE,
             wlmti.TO_DEPARTMENT_ID,
             wlmti.TO_DEPARTMENT_CODE,
             wlmti.TRANSACTION_QUANTITY,
             wlmti.PRIMARY_QUANTITY,
             wlmti.SCRAP_QUANTITY,
             wlmti.PRIMARY_SCRAP_QUANTITY,
             wlmti.ERROR,
             wlmti.HEADER_ID,
             wlmti.REASON_NAME
    FROM     wsm_lot_move_txn_interface wlmti,
             mtl_item_flexfields mif,
             mfg_lookups ml
    WHERE    wlmti.organization_id = :i_org_id
    AND      wlmti.transaction_date <= :i_period_end_date
    AND      wlmti.status <> 4
    AND      NVL(wlmti.primary_item_id, -1) = mif.inventory_item_id(+)
    AND	     wlmti.organization_id = mif.organization_id (+)
    AND      ml.lookup_type = ''WIP_PROCESS_STATUS''
    AND      ml.lookup_code = wlmti.status
    ORDER BY TRANSACTION_DATE'
  USING  i_org_id, i_period_end_date;

  /* create new context */
  l_stmt_num := 50;
  l_ctx := DBMS_XMLGEN.newContext (l_ref_cur);
  DBMS_XMLGEN.setRowSetTag (l_ctx,'PENDING_WLMTI_TRX');
  DBMS_XMLGEN.setRowTag (l_ctx,'PENDING_WLMTI_TRANSACTION');

  /* get XML */
  l_stmt_num := 60;
  DBMS_XMLGEN.getXML (l_ctx, l_xml_wlmti, DBMS_XMLGEN.none);

  x_record_count := x_record_count + DBMS_XMLGEN.getNumRowsProcessed(l_ctx);
  /* remove the header */
  IF (DBMS_XMLGEN.getNumRowsProcessed(l_ctx) > 0) THEN
          l_wlmti_flag := FND_API.G_TRUE;
          l_offset := DBMS_LOB.instr (lob_loc => l_xml_wlmti,
                                      pattern => '>',
                                      offset  => 1,
                                      nth     => 1);
          DBMS_LOB.erase (l_xml_wlmti, l_offset,1);
  END IF;
  /* close context */
  DBMS_XMLGEN.closeContext(l_ctx);
  CLOSE l_ref_cur;

  IF (l_eventLog) THEN
            FND_LOG.STRING (FND_LOG.LEVEL_EVENT,
                                l_module || '.' || l_stmt_num,
                                'Completed WLMTI transactions');
  END IF;

  /* Open Ref Cursor for WSM_LOT_SPLIT_MERGES_INTERFACE */
  l_stmt_num := 70;
  OPEN l_ref_cur FOR
    'SELECT  wlsmi.transaction_id,
             wlsmi.transaction_type_id,
             ml.meaning transaction_type_name,
             wlsmi.organization_id,
             wlsmi.wip_flag,
             wlsmi.split_flag,
             wlsmi.transaction_date,
             wlsmi.request_id,
             wlsmi.process_status,
             ml1.meaning process_status_code,
             wlsmi.error_message,
             wlsmi.group_id,
             wlsmi.transaction_reason,
             wlsmi.header_id,
             /* Pick resulting lot as reference lot for merge transactions
             Pick starting lot for split, transfer and translate transactions */
             decode (wlsmi.transaction_type_id,
                     2, wrli.lot_number,
                     wsli.lot_number) reference_lot
    FROM     wsm_lot_split_merges_interface wlsmi,
             wsm_starting_lots_interface wsli,
             wsm_resulting_lots_interface wrli,
             mfg_lookups ml,
             mfg_lookups ml1
    WHERE    wlsmi.organization_id = :i_org_id
    AND      ml.lookup_type = ''WSM_INV_LOT_TXN_TYPE''
    AND      ml.lookup_code = wlsmi.transaction_type_id
    AND      ml1.lookup_type = ''WIP_PROCESS_STATUS''
    AND      ml1.lookup_code(+) = wlsmi.process_status
    AND      wlsmi.transaction_date <= :i_period_end_date
    AND      wlsmi.process_status <> 4
    AND      nvl(wlsmi.header_id, -1) = wsli.header_id(+)
    AND      nvl(wlsmi.header_id, -1) = wrli.header_id(+)
    ORDER BY TRANSACTION_DATE, HEADER_ID'
  USING  i_org_id, i_period_end_date;

  /* create new context */
  l_stmt_num := 80;
  l_ctx := DBMS_XMLGEN.newContext (l_ref_cur);
  DBMS_XMLGEN.setRowSetTag (l_ctx,'PENDING_WLSMI_TRX');
  DBMS_XMLGEN.setRowTag (l_ctx,'PENDING_WLSMI_TRANSACTION');

  /* get XML */
  l_stmt_num := 90;
  DBMS_XMLGEN.getXML (l_ctx, l_xml_wlsmi, DBMS_XMLGEN.none);

  x_record_count := x_record_count + DBMS_XMLGEN.getNumRowsProcessed(l_ctx);
  /* remove the header */
  IF (DBMS_XMLGEN.getNumRowsProcessed(l_ctx) > 0) THEN
          l_wlsmi_flag := FND_API.G_TRUE;
          l_offset := DBMS_LOB.instr (lob_loc => l_xml_wlsmi,
                                      pattern => '>',
                                      offset  => 1,
                                      nth     => 1);
          DBMS_LOB.erase (l_xml_wlsmi, l_offset,1);
  END IF;
  /* close context */
  DBMS_XMLGEN.closeContext(l_ctx);
  CLOSE l_ref_cur;

  IF (l_eventLog) THEN
            FND_LOG.STRING (FND_LOG.LEVEL_EVENT,
                                l_module || '.' || l_stmt_num,
                                'Completed WLSMI transactions');
  END IF;

  IF (FND_API.to_Boolean (l_wsmti_flag) OR FND_API.to_Boolean (l_wlmti_flag)
         OR FND_API.to_Boolean (l_wlsmi_flag) ) THEN
     /* Atleast one transaction is present */
     l_stmt_num := 100;
     DBMS_LOB.writeappend (x_xml_doc, 17, '<PENDING_WSM_TRX>');
     IF (FND_API.to_Boolean (l_wsmti_flag)) THEN
        DBMS_LOB.append (x_xml_doc, l_xml_wsmti);
     END IF;
     IF (FND_API.to_Boolean (l_wlmti_flag)) THEN
        DBMS_LOB.append (x_xml_doc, l_xml_wlmti);
     END IF;
     IF (FND_API.to_Boolean (l_wlsmi_flag)) THEN
        DBMS_LOB.append (x_xml_doc, l_xml_wlsmi);
     END IF;
     DBMS_LOB.writeappend (x_xml_doc, 18, '</PENDING_WSM_TRX>');
  END IF;

  DBMS_LOB.FREETEMPORARY (l_xml_wsmti);
  DBMS_LOB.FREETEMPORARY (l_xml_wlmti);
  DBMS_LOB.FREETEMPORARY (l_xml_wlsmi);

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
          FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                                     p_data  => x_msg_data);
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
          FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                                     p_data  => x_msg_data);
END pending_wsm_trx;

PROCEDURE pending_mtl_interface_trx
          (p_api_version       	IN		NUMBER,
          p_init_msg_list	IN		VARCHAR2,
          p_validation_level	IN  		NUMBER,
          x_return_status	OUT NOCOPY	VARCHAR2,
          x_msg_count		OUT NOCOPY	NUMBER,
          x_msg_data		OUT NOCOPY	VARCHAR2,
          i_period_end_date 	IN 		DATE,
          i_org_id 		IN 		NUMBER,
          x_record_count        OUT NOCOPY      NUMBER,
          x_xml_doc 		IN OUT NOCOPY	CLOB)
IS
          l_api_name		CONSTANT VARCHAR2(30)	:= 'pending_mtl_interface_trx';
          l_api_version        	CONSTANT NUMBER 	:= 1.0;
          l_ref_cur    	        SYS_REFCURSOR;
          l_ctx		        NUMBER;
          l_xml_temp	        CLOB;
          l_offset	        PLS_INTEGER;
          l_stmt_num            NUMBER;
          l_min_txn_if_id       MTL_TRANSACTIONS_INTERFACE.TRANSACTION_INTERFACE_ID%TYPE;
          l_max_txn_if_id       MTL_TRANSACTIONS_INTERFACE.TRANSACTION_INTERFACE_ID%TYPE;
          l_full_name           CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
          l_module              CONSTANT VARCHAR2(70) := 'cst.plsql.' || l_full_name;

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

  SELECT   min (TRANSACTION_INTERFACE_ID)
    INTO   l_min_txn_if_id
    FROM   mtl_transactions_interface
   WHERE   organization_id = i_org_id
     AND   transaction_date <= i_period_end_date
     AND   process_flag <> 9;

  SELECT   max (TRANSACTION_INTERFACE_ID)
    INTO   l_max_txn_if_id
    FROM   mtl_transactions_interface
   WHERE   organization_id = i_org_id
     AND   transaction_date <= i_period_end_date
     AND   process_flag <> 9;

  /* Open Ref Cursor */
  l_stmt_num := 10;
  OPEN l_ref_cur FOR
    'SELECT  mti.TRANSACTION_INTERFACE_ID,
             mti.TRANSACTION_HEADER_ID,
             mif.ITEM_NUMBER,
             mti.INVENTORY_ITEM_ID,
             mti.SUBINVENTORY_CODE,
             mti.LOCATOR_ID,
             mtli.LOT_NUMBER,
             mti.REVISION,
             msni.FM_SERIAL_NUMBER,
             msni.TO_SERIAL_NUMBER,
             mti.TRANSACTION_QUANTITY,
             mti.PRIMARY_QUANTITY,
             mti.TRANSACTION_UOM,
             mti.TRANSACTION_COST,
             mtt.TRANSACTION_TYPE_NAME,
             mti.TRANSACTION_TYPE_ID,
             ml4.meaning TRANSACTION_ACTION_NAME,
             mti.TRANSACTION_ACTION_ID,
             mtst.TRANSACTION_SOURCE_TYPE_NAME,
             mti.TRANSACTION_SOURCE_TYPE_ID,
             mti.TRANSACTION_SOURCE_NAME,
             mti.TRANSACTION_SOURCE_ID,
             mti.TRANSACTION_DATE,
             mti.TRANSFER_SUBINVENTORY,
             mp.ORGANIZATION_CODE TRANSFER_ORGANIZATION_CODE,
             mti.TRANSFER_ORGANIZATION,
             mti.REQUEST_ID,
             mti.SOURCE_CODE,
             mti.SOURCE_LINE_ID,
             mti.SOURCE_HEADER_ID,
             ml3.meaning PROCESS_FLAG_DESC,
             mti.PROCESS_FLAG,
             ml2.meaning TRANSACTION_MODE_DESC,
             mti.TRANSACTION_MODE,
             ml1.meaning LOCK_FLAG_DESC,
             mti.LOCK_FLAG,
             mti.ERROR_CODE,
             mti.ERROR_EXPLANATION
    FROM     mtl_transactions_interface mti,
             mtl_item_flexfields mif,
             mtl_serial_numbers_interface msni,
             mtl_transaction_lots_interface mtli,
             mtl_parameters mp,
             mfg_lookups ml1,
             mfg_lookups ml2,
             mfg_lookups ml3,
             mfg_lookups ml4,
             mtl_txn_source_types mtst,
             mtl_transaction_types mtt
    WHERE    mti.organization_id = :i_org_id
    AND      mti.transaction_date <= :i_period_end_date
    AND      mti.process_flag <> 9
    AND      mti.transaction_interface_id
               between :l_min_txn_if_id AND :l_max_txn_if_id
    AND      mti.organization_id = mif.organization_id (+)
    AND      mti.inventory_item_id = mif.inventory_item_id (+)
    AND      (mtli.transaction_interface_id (+) = mti.transaction_interface_id
             AND msni.transaction_interface_id (+) = mti.transaction_interface_id)
    AND      ml1.lookup_type  = ''SYS_YES_NO''
    AND      ml1.lookup_code (+) = mti.lock_flag
    AND      ml2.lookup_type  = ''MTL_TRANSACTION_MODE''
    AND      ml2.lookup_code (+) = mti.transaction_mode
    AND      ml3.lookup_type  = ''INV_YES_NO_ERROR''
    AND      ml3.lookup_code (+) = mti.process_flag
    AND      ml4.lookup_type  = ''MTL_TRANSACTION_ACTION''
    AND      ml4.lookup_code (+) = mti.transaction_action_id
    AND      mp.organization_id (+) = mti.transfer_organization
    AND      mtst.transaction_source_type_id (+) = mti.transaction_source_type_id
    AND      mtt.transaction_type_id = mti.transaction_type_id
    ORDER BY mti.transaction_date, mti.transaction_interface_id'
  USING  i_org_id, i_period_end_date, l_min_txn_if_id, l_max_txn_if_id;

  /* create new context */
  l_stmt_num := 20;
  l_ctx := DBMS_XMLGEN.newContext (l_ref_cur);
  DBMS_XMLGEN.setRowSetTag (l_ctx,'PENDING_MTL_INTERFACE_TRX');
  DBMS_XMLGEN.setRowTag (l_ctx,'PENDING_MTL_INTERFACE_TRANSACTION');

  /* get XML */
  l_stmt_num := 30;
  DBMS_XMLGEN.getXML (l_ctx, l_xml_temp, DBMS_XMLGEN.none);

  x_record_count := DBMS_XMLGEN.getNumRowsProcessed(l_ctx);
  /* remove the header and append the rest to xml output */
  IF (x_record_count > 0) THEN
       /* Find the number of characters in the header and delete
        them. Header ends with '>'. Hence find first occurrence of
        '>' in the CLOB */
          l_offset := DBMS_LOB.instr (lob_loc => l_xml_temp,
                                      pattern => '>',
                                      offset  => 1,
                                      nth     => 1);
          DBMS_LOB.erase (l_xml_temp, l_offset,1);
          DBMS_LOB.append (x_xml_doc, l_xml_temp);
  END IF;
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
          FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                                     p_data  => x_msg_data);
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
          FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                                     p_data  => x_msg_data);
END pending_mtl_interface_trx;

PROCEDURE pending_rcv_trx
          (p_api_version       	IN		NUMBER,
          p_init_msg_list	IN		VARCHAR2,
          p_validation_level	IN  		NUMBER,
          x_return_status	OUT NOCOPY	VARCHAR2,
          x_msg_count		OUT NOCOPY	NUMBER,
          x_msg_data		OUT NOCOPY	VARCHAR2,
          i_period_end_date 	IN 		DATE,
          i_org_id 		IN 		NUMBER,
          x_record_count        OUT NOCOPY      NUMBER,
          x_xml_doc 		IN OUT NOCOPY 	CLOB)
IS
          l_api_name		CONSTANT VARCHAR2(30)	:= 'pending_rcv_trx';
          l_api_version         CONSTANT NUMBER 	:= 1.0;
          l_ref_cur    	        SYS_REFCURSOR;
          l_ctx		        NUMBER;
          l_xml_temp	        CLOB;
          l_offset	        PLS_INTEGER;
          l_stmt_num            NUMBER;

          l_full_name           CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
          l_module              CONSTANT VARCHAR2(60) := 'cst.plsql.' || l_full_name;

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

  /* Open Ref Cursor */
  l_stmt_num := 10;
  OPEN l_ref_cur FOR
   'SELECT  rti.INTERFACE_TRANSACTION_ID,
            rti.HEADER_INTERFACE_ID,
            mif.ITEM_NUMBER,
            rti.ITEM_ID,
            rti.GROUP_ID,
            rti.TRANSACTION_TYPE,
            rti.TRANSACTION_DATE,
            rti.PROCESSING_STATUS_CODE,
            rti.PROCESSING_MODE_CODE,
            rti.TRANSACTION_STATUS_CODE,
            rti.QUANTITY,
            rti.UNIT_OF_MEASURE,
            rti.AUTO_TRANSACT_CODE,
            rti.RECEIPT_SOURCE_CODE,
            rti.DESTINATION_TYPE_CODE,
            rti.SOURCE_DOCUMENT_CODE,
            rti.CURRENCY_CODE,
            rti.DOCUMENT_NUM,
            rti.SHIP_TO_LOCATION_ID,
            hl.LOCATION_CODE,
            rti.PARENT_TRANSACTION_ID,
            rti.PO_HEADER_ID,
            rti.PO_LINE_ID,
            rti.PO_RELEASE_ID,
            por.RELEASE_NUM,
            poh.SEGMENT1,
            rti.VENDOR_ID,
            rti.VENDOR_SITE_ID,
            rti.OE_ORDER_HEADER_ID,
            rti.OE_ORDER_LINE_ID,
            rti.VALIDATION_FLAG,
            rti.SUBINVENTORY,
            pol.LINE_NUM,
            pie.COLUMN_NAME,
            pie.ERROR_MESSAGE
   FROM     rcv_transactions_interface rti,
            po_interface_errors pie,
            mtl_item_flexfields mif,
            po_headers_all poh,
            po_lines_all pol,
            po_releases_all por,
            hr_locations_all hl
   WHERE    to_organization_id = :i_org_id
   AND      transaction_date <= :i_period_end_date
   AND      destination_type_code  in (''INVENTORY'', ''SHOP FLOOR'')
   AND      rti.po_header_id = poh.po_header_id(+)
   AND      rti.po_line_id = pol.po_line_id(+)
   AND      rti.po_release_id = por.po_release_id(+)
   AND      rti.to_organization_id = mif.organization_id (+)
   AND      rti.item_id = mif.inventory_item_id (+)
   AND      rti.interface_transaction_id = pie.interface_transaction_id(+)
   AND      rti.ship_to_location_id = hl.location_id (+)
   ORDER BY rti.TRANSACTION_DATE, rti.INTERFACE_TRANSACTION_ID'
  USING  i_org_id, i_period_end_date;

   /* create new context */
   l_stmt_num := 20;
   l_ctx := DBMS_XMLGEN.newContext (l_ref_cur);
   DBMS_XMLGEN.setRowSetTag (l_ctx,'PENDING_RCV_TRX');
   DBMS_XMLGEN.setRowTag (l_ctx,'PENDING_RCV_TRANSACTION');

   /* get XML */
   l_stmt_num := 30;
   DBMS_XMLGEN.getXML (l_ctx, l_xml_temp, DBMS_XMLGEN.none);

   x_record_count := DBMS_XMLGEN.getNumRowsProcessed(l_ctx);
   /* remove the header and append the rest to xml output */
   IF (x_record_count > 0) THEN
        /* Find the number of characters in the header and delete
         them. Header ends with '>'. Hence find first occurrence of
         '>' in the CLOB */
           l_offset := DBMS_LOB.instr (lob_loc => l_xml_temp,
                                       pattern => '>',
                                       offset  => 1,
                                       nth     => 1);
           DBMS_LOB.erase (l_xml_temp, l_offset,1);
           DBMS_LOB.append (x_xml_doc, l_xml_temp);
   END IF;

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
           FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                                      p_data  => x_msg_data);
   WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF (l_uLog) THEN
            FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED,
                           l_module || '.' || l_stmt_num,
                           SUBSTRB (SQLERRM , 1 , 240));
          END IF;

           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
           THEN
                   FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,l_api_name);
           END IF;
           FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                                      p_data  => x_msg_data);
END pending_rcv_trx;

PROCEDURE pending_wip_move_trx
          (p_api_version       	IN		NUMBER,
          p_init_msg_list	IN		VARCHAR2,
          p_validation_level	IN  		NUMBER,
          x_return_status	OUT NOCOPY	VARCHAR2,
          x_msg_count		OUT NOCOPY	NUMBER,
          x_msg_data		OUT NOCOPY	VARCHAR2,
          i_period_end_date 	IN 		DATE,
          i_org_id 		IN 		NUMBER,
          x_record_count        OUT NOCOPY      NUMBER,
          x_xml_doc 		IN OUT NOCOPY 	CLOB)
IS
          l_api_name		CONSTANT VARCHAR2(30)	:= 'pending_wip_move_trx';
          l_api_version		CONSTANT NUMBER 	:= 1.0;
          l_ref_cur    	        SYS_REFCURSOR;
          l_ctx		        NUMBER;
          l_xml_temp	        CLOB;
          l_offset	        PLS_INTEGER;
          l_stmt_num            NUMBER;

          l_full_name           CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
          l_module              CONSTANT VARCHAR2(60) := 'cst.plsql.' || l_full_name;

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

  /* Open Ref Cursor */
  l_stmt_num := 10;
  OPEN l_ref_cur FOR
    'SELECT  wmti.TRANSACTION_ID,
             wmti.GROUP_ID,
             wmti.PROCESS_PHASE_MEANING,
             wmti.PROCESS_PHASE,
             wmti.PROCESS_STATUS_MEANING,
             wmti.PROCESS_STATUS,
             mif.ITEM_NUMBER,
             wmti.PRIMARY_ITEM_ID,
             wmti.ENTITY_TYPE,
             wmti.WIP_ENTITY_NAME,
             wmti.WIP_ENTITY_ID,
             wmti.TRANSACTION_TYPE_MEANING,
             wmti.TRANSACTION_TYPE,
             wmti.TRANSACTION_DATE,
             wmti.TRANSACTION_QUANTITY,
             wmti.TRANSACTION_UOM,
             wmti.PRIMARY_QUANTITY,
             wmti.PRIMARY_UOM,
             wmti.SOURCE_CODE,
             wmti.SOURCE_LINE_ID,
             wmti.REPETITIVE_SCHEDULE_ID,
             wmti.FM_OPERATION_SEQ_NUM,
             wmti.FM_INTRAOPERATION_STEP_TYPE,
             wmti.TO_OPERATION_SEQ_NUM,
             wmti.TO_INTRAOPERATION_STEP_TYPE,
             wmti.OVERCOMPLETION_TRANSACTION_QTY,
             wmti.SCRAP_ACCOUNT_ID,
             wmti.REQUEST_ID,
             wtie.ERROR_COLUMN,
             wtie.ERROR_MESSAGE
    FROM     wip_move_txn_interface_v wmti,
             wip_txn_interface_errors wtie,
             mtl_item_flexfields mif
    WHERE    wmti.organization_id = :i_org_id
    AND      wmti.transaction_date <= :i_period_end_date
    AND      wtie.transaction_id(+) = wmti.transaction_id
    AND      wmti.organization_id = mif.organization_id (+)
    AND      NVL( wmti.primary_item_id, -1) = mif.inventory_item_id(+)
    ORDER BY wmti.TRANSACTION_DATE, wmti.TRANSACTION_ID'
  USING  i_org_id, i_period_end_date;

  /* create new context */
  l_stmt_num := 20;
  l_ctx := DBMS_XMLGEN.newContext (l_ref_cur);
  DBMS_XMLGEN.setRowSetTag (l_ctx,'PENDING_WIP_MOVE_TRX');
  DBMS_XMLGEN.setRowTag (l_ctx,'PENDING_WIP_MOVE_TRANSACTION');

  /* get XML */
  l_stmt_num := 30;
  DBMS_XMLGEN.getXML (l_ctx, l_xml_temp, DBMS_XMLGEN.none);

  x_record_count := DBMS_XMLGEN.getNumRowsProcessed(l_ctx);
  /* remove the header and append the rest to xml output */
  IF (x_record_count > 0) THEN
       /* Find the number of characters in the header and delete
        them. Header ends with '>'. Hence find first occurrence of
        '>' in the CLOB */
          l_offset := DBMS_LOB.instr (lob_loc => l_xml_temp,
                                      pattern => '>',
                                      offset  => 1,
                                      nth     => 1);
          DBMS_LOB.erase (l_xml_temp, l_offset,1);
          DBMS_LOB.append (x_xml_doc, l_xml_temp);
  END IF;
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
          FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                                     p_data  => x_msg_data);

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
          FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                                     p_data  => x_msg_data);
END pending_wip_move_trx;

PROCEDURE pending_shipping_trx
          (p_api_version       	IN		NUMBER,
          p_init_msg_list	IN		VARCHAR2,
          p_validation_level	IN  		NUMBER,
          x_return_status	OUT NOCOPY	VARCHAR2,
          x_msg_count		OUT NOCOPY	NUMBER,
          x_msg_data		OUT NOCOPY	VARCHAR2,
          i_period_start_date 	IN 		DATE,
          i_period_end_date 	IN 		DATE,
          i_org_id 		IN 		NUMBER,
          x_record_count        OUT NOCOPY      NUMBER,
          x_xml_doc 		IN OUT NOCOPY 	CLOB)
IS
          l_api_name		CONSTANT VARCHAR2(30)	:= 'pending_shipping_trx';
          l_api_version        	CONSTANT NUMBER 	:= 1.0;
          l_ref_cur    	        SYS_REFCURSOR;
          l_ctx		        NUMBER;
          l_xml_temp	        CLOB;
          l_offset	        PLS_INTEGER;
          l_stmt_num            NUMBER;

          l_full_name           CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
          l_module              CONSTANT VARCHAR2(60) := 'cst.plsql.' || l_full_name;

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
  IF NOT FND_API.Compatible_API_Call (l_api_version ,
                                      p_api_version ,
                                      l_api_name ,
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

  /* Open Ref Cursor */

  /* This cursor SQL should be dual maintained with the one used to
     get the pending shipping transaction count in WSH_INTEGRATION.
     GET_UNTRXD_SHPG_LINES_COUNT */

  l_stmt_num := 10;
  OPEN l_ref_cur FOR
    'SELECT  wdd.DELIVERY_DETAIL_ID,
             wnd.DELIVERY_ID,
             wdd.SOURCE_CODE,
             wdd.SOURCE_HEADER_ID,
             wdd.SOURCE_LINE_ID,
             wdd.SOURCE_HEADER_NUMBER,
             wdd.SOURCE_LINE_NUMBER,
             mif.ITEM_NUMBER,
             wdd.INVENTORY_ITEM_ID,
             wdd.ITEM_DESCRIPTION
    FROM     wsh_delivery_details wdd,
             wsh_delivery_assignments wda,
             wsh_new_deliveries wnd,
             wsh_delivery_legs wdl,
             wsh_trip_stops wts,
             mtl_item_flexfields mif
    WHERE    wdd.source_code = ''OE''
    AND      wdd.released_status = ''C''
    AND      wdd.inv_interfaced_flag in (''N'' ,''P'')
    AND      wdd.organization_id = :i_org_id
    AND      wda.delivery_detail_id = wdd.delivery_detail_id
    AND      wnd.delivery_id = wda.delivery_id
    AND	     wnd.status_code in (''CL'',''IT'')
    AND      wdl.delivery_id = wnd.delivery_id
    AND      wts.pending_interface_flag in (''Y'', ''P'')
    AND      trunc(wts.actual_departure_date) between :i_period_start_date
                          AND :i_period_end_date
    AND      wdl.pick_up_stop_id = wts.stop_id
    AND      wdd.organization_id = mif.organization_id (+)
    AND      wdd.inventory_item_id = mif.inventory_item_id (+)
    UNION ALL
    SELECT   wdd.DELIVERY_DETAIL_ID,
             wnd.DELIVERY_ID,
             wdd.SOURCE_CODE,
             wdd.SOURCE_HEADER_ID,
             wdd.SOURCE_LINE_ID,
             wdd.SOURCE_HEADER_NUMBER,
             wdd.SOURCE_LINE_NUMBER,
             mif.ITEM_NUMBER,
             wdd.INVENTORY_ITEM_ID,
             wdd.ITEM_DESCRIPTION
    FROM     wsh_delivery_details wdd,
             wsh_delivery_assignments wda,
             wsh_new_deliveries wnd,
             wsh_delivery_legs wdl,
             wsh_trip_stops wts,
             oe_order_lines_all oel,
             po_requisition_lines_all pl,
             mtl_item_flexfields mif
    WHERE    wdd.source_code = ''OE''
    AND      wdd.released_status = ''C''
    AND      wdd.inv_interfaced_flag in (''N'' ,''P'')
    AND      wda.delivery_detail_id = wdd.delivery_detail_id
    AND      wnd.delivery_id = wda.delivery_id
    AND      wnd.status_code in (''CL'',''IT'')
    AND      wdl.delivery_id = wnd.delivery_id
    AND      wts.pending_interface_flag in (''Y'', ''P'')
    AND      trunc(wts.actual_departure_date) between :i_period_start_date
                          AND :i_period_end_date
    AND      wdd.source_line_id = oel.line_id
    AND      wdd.source_document_type_id = 10
    AND      oel.source_document_line_id = pl.requisition_line_id
    AND      pl.destination_organization_id = :i_org_id
    AND      pl.destination_organization_id <> pl.source_organization_id
    AND      pl.destination_type_code = ''EXPENSE''
    AND      wdl.pick_up_stop_id = wts.stop_id
    AND      wts.stop_location_id = wnd.initial_pickup_location_id
    AND      wdd.organization_id = mif.organization_id (+)
    AND      wdd.inventory_item_id = mif.inventory_item_id (+)
    UNION ALL
    SELECT   wdd.DELIVERY_DETAIL_ID,
             wnd.DELIVERY_ID,
             wdd.SOURCE_CODE,
             wdd.SOURCE_HEADER_ID,
             wdd.SOURCE_LINE_ID,
             wdd.SOURCE_HEADER_NUMBER,
             wdd.SOURCE_LINE_NUMBER,
             mif.ITEM_NUMBER,
             wdd.INVENTORY_ITEM_ID,
             wdd.ITEM_DESCRIPTION
    FROM     wsh_delivery_details wdd,
             wsh_delivery_assignments wda,
             wsh_new_deliveries wnd,
             wsh_delivery_legs wdl,
             wsh_trip_stops wts,
             oe_order_lines_all oel,
             po_requisition_lines_all pl,
             mtl_interorg_parameters mip,
             mtl_item_flexfields mif
    WHERE    wdd.source_code = ''OE''
    AND      wdd.released_status = ''C''
    AND      wdd.inv_interfaced_flag in (''N'' ,''P'')
    AND      wda.delivery_detail_id = wdd.delivery_detail_id
    AND      wnd.delivery_id = wda.delivery_id
    AND      wnd.status_code in (''CL'',''IT'')
    AND      wdl.delivery_id = wnd.delivery_id
    AND      wts.pending_interface_flag in (''Y'', ''P'')
    AND      trunc(wts.actual_departure_date) between :i_period_start_date
                          AND :i_period_end_date
    AND      wdd.source_line_id = oel.line_id
    AND      wdd.source_document_type_id = 10
    AND      oel.source_document_line_id = pl.requisition_line_id
    AND      pl.destination_organization_id = :i_org_id
    AND      pl.destination_organization_id <> pl.source_organization_id
    AND      pl.destination_organization_id = mip.to_organization_id
    AND      pl.source_organization_id = mip.from_organization_id
    AND      mip.intransit_type = 1
    AND      pl.destination_type_code <> ''EXPENSE''
    AND      wdl.pick_up_stop_id = wts.stop_id
    AND      wts.stop_location_id = wnd.initial_pickup_location_id
    AND      wdd.organization_id = mif.organization_id (+)
    AND      wdd.inventory_item_id = mif.inventory_item_id (+)
    ORDER BY 1'
  USING  i_org_id, i_period_start_date, i_period_end_date,
         i_period_start_date, i_period_end_date, i_org_id,
         i_period_start_date, i_period_end_date, i_org_id;

  /* create new context */
  l_stmt_num := 20;
  l_ctx := DBMS_XMLGEN.newContext (l_ref_cur);
  DBMS_XMLGEN.setRowSetTag (l_ctx,'PENDING_SHIPPING_TRX');
  DBMS_XMLGEN.setRowTag (l_ctx,'PENDING_SHIPPING_TRANSACTION');

  /* get XML */
  l_stmt_num := 30;
  DBMS_XMLGEN.getXML (l_ctx, l_xml_temp, DBMS_XMLGEN.none);

  x_record_count := DBMS_XMLGEN.getNumRowsProcessed(l_ctx);
  /* remove the header and append the rest to xml output */
  IF (x_record_count > 0) THEN
       /* Find the number of characters in the header and delete
        them. Header ends with '>'. Hence find first occurrence of
        '>' in the CLOB */
          l_offset := DBMS_LOB.instr (lob_loc => l_xml_temp,
                                      pattern => '>',
                                      offset  => 1,
                                      nth     => 1);
          DBMS_LOB.erase (l_xml_temp, l_offset,1);
          DBMS_LOB.append (x_xml_doc, l_xml_temp);
  END IF;
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
          FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                                     p_data  => x_msg_data);
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
          FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                                     p_data  => x_msg_data);
END pending_shipping_trx;

PROCEDURE incomplete_eam_wo
          (p_api_version       	IN		NUMBER,
          p_init_msg_list	IN		VARCHAR2,
          p_validation_level	IN  		NUMBER,
          x_return_status	OUT NOCOPY	VARCHAR2,
          x_msg_count		OUT NOCOPY	NUMBER,
          x_msg_data		OUT NOCOPY	VARCHAR2,
          i_period_end_date 	IN 		DATE,
          i_org_id 		IN 		NUMBER,
          x_record_count        OUT NOCOPY      NUMBER,
          x_xml_doc 		IN OUT NOCOPY 	CLOB)
IS
          l_api_name		CONSTANT VARCHAR2(30)	:= 'incomplete_eam_wo';
          l_api_version        	CONSTANT NUMBER 	:= 1.0;
          l_ref_cur    	        SYS_REFCURSOR;
          l_ctx		        NUMBER;
          l_xml_temp	        CLOB;
          l_offset	        PLS_INTEGER;
          l_stmt_num            NUMBER;

          l_full_name           CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
          l_module              CONSTANT VARCHAR2(60) := 'cst.plsql.' || l_full_name;

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
  IF NOT FND_API.Compatible_API_Call (l_api_version ,
                                      p_api_version ,
                                      l_api_name ,
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

  /* Open Ref Cursor */
  l_stmt_num := 10;
  OPEN l_ref_cur FOR
    'SELECT  wdj.WIP_ENTITY_ID,
             we.WIP_ENTITY_NAME,
             we.ENTITY_TYPE,
             wdj.ORGANIZATION_ID,
             wdj.DESCRIPTION,
             mif.CONCATENATED_SEGMENTS ACTIVITY,
             NVL (wdj.asset_number, NVL (wdj1.asset_number, wdj1.rebuild_serial_number)) ASSET_NUMBER,
             mif2.CONCATENATED_SEGMENTS ASSET_GROUP,
             decode(wdj.maintenance_object_type,
                    3, cii.instance_description,
                    2, ( SELECT description
                         FROM   mtl_system_items
                         WHERE  inventory_item_id = wdj.rebuild_item_id
                         AND    rownum = 1)) ASSET_DESCRIPTION,
             (SELECT department_code
              FROM   bom_departments
              WHERE  organization_id = wdj.organization_id
              AND    department_id = wdj.owning_department) OWNING_DEPARTMENT_CODE,
             wdj.CLASS_CODE,
             wdj.STATUS_TYPE,
             ewodv.USER_DEFINED_STATUS_ID,
             ewodv.WORK_ORDER_STATUS,
             wdj.SCHEDULED_START_DATE,
             wdj.SCHEDULED_COMPLETION_DATE,
             pjm_project.all_proj_idtoname(wdj.project_id) PROJECT_NAME,
             pjm_project.all_task_idtoname(wdj.task_id) TASK_NAME,
             (SELECT meaning
              FROM   mfg_lookups
              WHERE  lookup_code = wdj.activity_type
              AND    lookup_type = ''MTL_EAM_ACTIVITY_TYPE'') ACTIVITY_TYPE_DISP,
             (SELECT meaning
              FROM   mfg_lookups
              WHERE  lookup_code = wdj.activity_cause
              AND    lookup_type = ''MTL_EAM_ACTIVITY_CAUSE'') ACTIVITY_CAUSE_DISP,
             (SELECT meaning
              FROM   mfg_lookups
              WHERE  lookup_code = wdj.activity_source
              AND    lookup_type = ''MTL_EAM_ACTIVITY_SOURCE'') ACTIVITY_SOURCE_MEANING,
              cii.serial_number ASSET_SERIAL_NUMBER,
             (SELECT meaning
              FROM   mfg_lookups
              WHERE  lookup_code = wdj.work_order_type
              AND    lookup_type = ''WIP_EAM_WORK_ORDER_TYPE'') WORK_ORDER_TYPE_DISP,
             wdj.DATE_RELEASED,
             wdj.DATE_COMPLETED,
             wdj.DATE_CLOSED,
             wdj.ESTIMATION_STATUS,
             (SELECT wip_entity_name
              FROM   wip_entities
              WHERE  wip_entity_id = wdj.parent_wip_entity_id
              AND    organization_id = wdj.organization_id) PARENT_WIP_ENTITY_NAME,
             ewodv.WORK_ORDER_STATUS_PENDING,
             pjm_project.all_proj_idtonum(wdj.project_id) PROJECT_NUMBER,
             pjm_project.all_task_idtonum(wdj.task_id) TASK_NUMBER
    FROM     wip_entities we,
             wip_discrete_jobs wdj1,
             wip_discrete_jobs wdj,
             mtl_system_items_kfv mif,
             mtl_system_items_kfv mif2,
             eam_work_order_details_v ewodv,
             csi_item_instances cii
    WHERE    wdj.organization_id = :i_org_id
    AND      we.entity_type = 6
    AND      wdj.status_type = 3                     /* Released */
    AND      wdj.scheduled_completion_date <= :i_period_end_date
    AND      wdj.organization_id = mif.organization_id (+)
    AND      wdj.primary_item_id = mif.inventory_item_id (+)
    AND      wdj.organization_id = mif2.organization_id (+)
    AND      wdj.asset_group_id = mif2.inventory_item_id (+)
    AND      wdj.wip_entity_id = we.wip_entity_id
    AND      wdj.organization_id = we.organization_id
    AND      wdj.parent_wip_entity_id = wdj1.wip_entity_id(+)
    AND      wdj.organization_id = wdj1.organization_id(+)
    AND      ewodv.wip_entity_id = wdj.wip_entity_id
    AND      ewodv.organization_id = wdj.organization_id
    AND      DECODE(wdj.maintenance_object_type,3,wdj.maintenance_object_id,NULL) = cii.instance_id(+)'
  USING  i_org_id, i_period_end_date;

  /* create new context */
  l_stmt_num := 20;
  l_ctx := DBMS_XMLGEN.newContext (l_ref_cur);
  DBMS_XMLGEN.setRowSetTag (l_ctx,'INCOMPLETE_EAM_WO');
  DBMS_XMLGEN.setRowTag (l_ctx,'EAM_WORKORDER');

  /* get XML */
  l_stmt_num := 30;
  DBMS_XMLGEN.getXML (l_ctx, l_xml_temp, DBMS_XMLGEN.none);

  x_record_count := DBMS_XMLGEN.getNumRowsProcessed(l_ctx);

  /* remove the header and append the rest to xml output */
  IF (x_record_count > 0) THEN
       /* Find the number of characters in the header and delete
        them. Header ends with '>'. Hence find first occurrence of
        '>' in the CLOB */
          l_offset := DBMS_LOB.instr (lob_loc => l_xml_temp,
                                      pattern => '>',
                                      offset  => 1,
                                      nth     => 1);
          DBMS_LOB.erase (l_xml_temp, l_offset,1);
          DBMS_LOB.append (x_xml_doc, l_xml_temp);
  END IF;
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
          FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                                     p_data  => x_msg_data);
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
          FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                                     p_data  => x_msg_data);
END incomplete_eam_wo;

PROCEDURE pending_lcm_trx
          (p_api_version        IN		NUMBER,
          p_init_msg_list	IN		VARCHAR2,
          p_validation_level	IN  		NUMBER,
          x_return_status	OUT NOCOPY	VARCHAR2,
          x_msg_count		OUT NOCOPY	NUMBER,
          x_msg_data		OUT NOCOPY	VARCHAR2,
          i_period_end_date 	IN 		DATE,
          i_org_id 		IN 		NUMBER,
          x_record_count        OUT NOCOPY      NUMBER,
          x_xml_doc 		IN OUT NOCOPY 	CLOB)
IS
          l_api_name		CONSTANT VARCHAR2(30)	:= 'pending_lcm_trx';
          l_api_version         CONSTANT NUMBER 	:= 1.0;
          l_ref_cur    		SYS_REFCURSOR;
          l_ctx			NUMBER;
          l_xml_temp		CLOB;
          l_offset		PLS_INTEGER;
          l_stmt_num            NUMBER;

          l_full_name           CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
          l_module              CONSTANT VARCHAR2(60) := 'cst.plsql.' || l_full_name;

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

  /* Open Ref Cursor */
  l_stmt_num := 10;
  OPEN l_ref_cur FOR
   'SELECT  clai.transaction_id,
             clai.rcv_transaction_id,
             clai.organization_id,
             clai.inventory_item_id,
             clai.transaction_date,
             clai.prior_landed_cost,
             clai.new_landed_cost,
             clai.group_id,
	     clai.request_id,
             mif.item_number,
             clai.process_status,
             ml.meaning process_status_code,
             err.error_column,
             err.error_message
    FROM     cst_lc_adj_interface clai,
             cst_lc_adj_interface_errors err,
             mtl_item_flexfields mif,
             mfg_lookups ml
    WHERE    clai.organization_id = :i_org_id
    AND      transaction_date <= :i_period_end_date
    AND	     err.transaction_id (+) = clai.transaction_id
    AND      clai.organization_id = mif.organization_id (+)
    AND      clai.inventory_item_id = mif.inventory_item_id(+)
    AND      ml.lookup_type = ''LANDED_COST_ADJ_PROCESS_STATUS''
    AND      ml.lookup_code = clai.process_status
    ORDER BY clai.transaction_date, clai.transaction_id'
  USING  i_org_id, i_period_end_date;

  /* create new context */
  l_stmt_num := 20;
  l_ctx := DBMS_XMLGEN.newContext (l_ref_cur);
  DBMS_XMLGEN.setRowSetTag (l_ctx,'PENDING_LCM_TRX');
  DBMS_XMLGEN.setRowTag (l_ctx,'PENDING_LCM_TRANSACTION');

  /* get XML */
  l_stmt_num := 30;
  DBMS_XMLGEN.getXML (l_ctx, l_xml_temp, DBMS_XMLGEN.none);

  x_record_count := DBMS_XMLGEN.getNumRowsProcessed(l_ctx);
  /* remove the header and append the rest to xml output */
  IF (x_record_count > 0) THEN
       /* Find the number of characters in the header and delete
        them. Header ends with '>'. Hence find first occurrence of
        '>' in the CLOB */
          l_offset := DBMS_LOB.instr (lob_loc => l_xml_temp,
                                      pattern => '>',
                                      offset  => 1,
                                      nth     => 1);
          DBMS_LOB.erase (l_xml_temp, l_offset,1);
          DBMS_LOB.append (x_xml_doc, l_xml_temp);
  END IF;
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
          FND_MSG_PUB.Count_And_Get (p_count => x_msg_count ,
                                     p_data  => x_msg_data);
  WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF (l_uLog) THEN
            FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED,
                           l_module || '.' || l_stmt_num,
                           SUBSTRB (SQLERRM , 1 , 240));
          END IF;

          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
                  FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                                     p_data  => x_msg_data);
END pending_lcm_trx;

END CST_PendingTxnsReport_PVT;

/
