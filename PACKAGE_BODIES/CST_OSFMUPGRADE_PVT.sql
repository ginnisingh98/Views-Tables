--------------------------------------------------------
--  DDL for Package Body CST_OSFMUPGRADE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_OSFMUPGRADE_PVT" AS
/* $Header: CSTVUPGB.pls 120.2 2006/02/10 11:44:28 ssreddy noship $ */

G_PKG_NAME VARCHAR2(240) := 'CST_OSFMUpgrade_PVT';

PROCEDURE Update_Quantity_Issued(
                                 ERRBUF        OUT NOCOPY VARCHAR2,
                                 RETCODE       OUT NOCOPY NUMBER,
                                 p_organization_id   IN   NUMBER,
                                 p_api_version       IN   NUMBER  ) IS
   l_stmt_num 		NUMBER;
   l_mmtt     		NUMBER;
   l_uncosted_mmt	NUMBER;
   /* API */
   l_api_name    CONSTANT    VARCHAR2(240)  := 'Update_Quantity_Issued';
   l_api_version CONSTANT    NUMBER         := 1.0;
   conc_status               BOOLEAN;
BEGIN

   l_stmt_num := 5;
   IF NOT FND_API.COMPATIBLE_API_CALL (
                               l_api_version,
                               p_api_version,
                               l_api_name,
                               G_PKG_NAME ) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   /* Check for any uncosted WIP transactions. All WIP transactions
      will have to be costed before the upgrade can take place */
   l_stmt_num := 10;
   SELECT  count(*)
   INTO    l_mmtt
   FROM    mtl_material_transactions_temp mmtt,
           mtl_parameters MP
   WHERE   mmtt.organization_id = MP.organization_id and
           MP.wsm_enabled_flag = 'Y' and
           mmtt.transaction_source_type_id = 5 and
           mmtt.transaction_status <> 2 and
           MP.organization_id = nvl(p_organization_id, MP.organization_id) and
           rownum = 1;

   l_stmt_num := 20;
   SELECT  count(*)
   INTO    l_uncosted_mmt
   FROM    mtl_material_transactions mmt,
           mtl_parameters MP
   WHERE   mmt.organization_id = MP.organization_id and
           mmt.costed_flag IN ('N','E') and
           MP.wsm_enabled_flag = 'Y' and
           mmt.transaction_source_type_id = 5 and
           MP.organization_id = nvl(p_organization_id, MP.organization_id) and
           rownum = 1;

   if (l_mmtt <> 0 OR l_uncosted_mmt <> 0 ) THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Uncosted transactions exist. Please ensure that '||
				       'all transactions are costed before running this script');
       FND_FILE.PUT_LINE(FND_FILE.LOG,' Pending MMTT txns : '||l_mmtt||
				      ' Uncosted/Errored MMT txns :'||l_uncosted_mmt);
       CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','Uncosted transactions exists. Please ensure that all transactions are costed');
       RETURN;
   END IF;

   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Updating WRO ...');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'p_organization_id : '||p_organization_id);

   IF (p_organization_id IS NULL) THEN
   l_stmt_num := 30;
   UPDATE wip_requirement_operations wro
   SET costed_quantity_issued = NVL(quantity_issued,0),
       costed_quantity_relieved = NVL(quantity_relieved,0)
   WHERE exists ( SELECT 1
	          FROM wip_entities we, wip_discrete_jobs wdj
	  	  WHERE we.wip_entity_id = wro.wip_entity_id
		  AND we.organization_id = wro.organization_id
		  AND we.entity_type = 5
		  AND we.wip_entity_id = wdj.wip_entity_id
		  AND we.organization_id = wdj.organization_id
		  AND wdj.status_type NOT IN (1,12));

   ELSE
   l_stmt_num := 40;
   UPDATE wip_requirement_operations wro
   SET costed_quantity_issued = NVL(quantity_issued,0),
       costed_quantity_relieved = NVL(quantity_relieved,0)
   WHERE wro.organization_id = p_organization_id
   AND exists ( SELECT 1
	          FROM wip_entities we, wip_discrete_jobs wdj
	  	  WHERE we.wip_entity_id = wro.wip_entity_id
		  AND we.organization_id = wro.organization_id
		  AND we.entity_type = 5
		  AND we.wip_entity_id = wdj.wip_entity_id
		  AND we.organization_id = wdj.organization_id
		  AND wdj.status_type NOT IN (1,12));

   END IF;
   COMMIT;

   RETURN;
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RETCODE := SQLCODE;
    ERRBUF  := 'Inconsistent API version'||l_stmt_num||'): '||
			substr(SQLERRM, 1, 200);
    CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', ERRBUF);
    fnd_file.put_line(fnd_file.log,ERRBUF);
   WHEN OTHERS THEN
    RETCODE := SQLCODE;
    ERRBUF := 'CST_OSFMUpgrade_PVT.update_quantity_issued('||l_stmt_num||'):'||
			substr(SQLERRM, 1, 200);
    CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', ERRBUF);
    fnd_file.put_line(fnd_file.log,ERRBUF);

END Update_Quantity_Issued;

END CST_OSFMUpgrade_PVT;

/
