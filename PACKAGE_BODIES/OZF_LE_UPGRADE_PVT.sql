--------------------------------------------------------
--  DDL for Package Body OZF_LE_UPGRADE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_LE_UPGRADE_PVT" AS
/* $Header: ozfvcleb.pls 120.1 2005/10/14 02:24:40 kdhulipa noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_LE_UPGRADE_PVT
-- Purpose
--
-- History
--
-- NOTE : This package is created for Legal Entity Stamping.
--
-- End of Comments
-- ===============================================================


G_PKG_NAME  CONSTANT VARCHAR2(30) := 'OZF_LE_UPGRADE_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozfvcleb.pls';

---------------------------------------------------------------------
-- PROCEDURE
--    Start_Process
--
-- HISTORY
-- 30-Sep-2005       kdhulipa   Created.
--
---------------------------------------------------------------------
PROCEDURE Start_Process(
    ERRBUF             OUT NOCOPY VARCHAR2,
    RETCODE            OUT NOCOPY NUMBER,
    p_org_id           IN  NUMBER DEFAULT NULL
)
IS

l_retcode                    NUMBER := 0;
l_return_status              VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS ;
l_msg_count                  NUMBER;
l_msg_Data                   VARCHAR2(2000);
l_object_version             NUMBER(9);

l_org_id   NUMBER :=0;
l_claim_id NUMBER := 0;
l_legal_entity_id   XLE_ENTITY_PROFILES.LEGAL_ENTITY_ID%TYPE;
l_ou_le_info 	xle_businessinfo_grp.OU_LE_Tbl_Type;

CURSOR claim_org_id_csr IS
SELECT claim_id, org_id
FROM   ozf_claims_all
WHERE  legal_entity_id is null;

BEGIN
    SAVEPOINT Start_Process;
    FND_FILE.PUT_LINE(FND_FILE.LOG, '+------------------- LEGAL ENTITY PROCESS START SUMMARY -------------------+');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Job Starts on: '||to_char(sysdate,'MM-DD-YYYY HH24:MI:SS'));
    FND_FILE.PUT_LINE(FND_FILE.LOG, '+---------------------------------------------------------------------------+');

    -- Main Cursor
    OPEN claim_org_id_csr;
    LOOP
    FETCH claim_org_id_csr INTO l_claim_id, l_org_id;
    EXIT when claim_org_id_csr%NOTFOUND;

    -- Fetch the legal entity id into l_legal_entity_id from API

       xle_businessinfo_grp.get_operatingunit_info (
            x_return_status    =>  l_return_status
            ,x_msg_data        =>  l_msg_data
            ,p_operating_unit  =>  l_org_id
            ,p_legal_entity_id =>  NULL
            ,p_party_id        =>  NULL
            ,x_ou_le_info      =>  l_ou_le_info
       );

       IF ( l_return_status = FND_API.g_ret_sts_error
             OR  l_return_status = FND_API.g_ret_sts_unexp_error ) THEN
             ROLLBACK TO Start_Process;
             FND_FILE.PUT_LINE(FND_FILE.LOG, 'Legal Entity ID is FAILED for the ORG_ID : '||l_org_id);
	     FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Legal Entity ID is FAILED for the ORG_ID : '||l_org_id);
             OZF_UTILITY_PVT.write_conc_log;
       END IF;

       l_legal_entity_id   := l_ou_le_info(1).legal_entity_id;


       IF l_legal_entity_id  IS NULL  THEN
           FND_FILE.PUT_LINE(FND_FILE.LOG, 'Legal Entity ID is NULL for the ORG_ID : '||l_org_id);
       ELSE

           UPDATE OZF_CLAIMS_ALL
           SET legal_entity_id = l_legal_entity_id
           WHERE claim_id = l_claim_id;

           FND_FILE.PUT_LINE(FND_FILE.LOG, '--------------BEGIN------------ ');
           FND_FILE.PUT_LINE(FND_FILE.LOG, 'Legal Entity ID is SET for the Claim_id : '||l_claim_id);
           FND_FILE.PUT_LINE(FND_FILE.LOG, 'ORG ID : '||l_org_id);
           FND_FILE.PUT_LINE(FND_FILE.LOG, 'Legal Entity ID : '||l_legal_entity_id);
	       FND_FILE.PUT_LINE(FND_FILE.LOG, '--------------END------------ ');
           OZF_UTILITY_PVT.write_conc_log;
       END IF;

    END LOOP;
    CLOSE claim_org_id_csr;

    FND_FILE.PUT_LINE(FND_FILE.LOG, '+-------------------- LEGAL ENTITY PROCESS END SUMMARY --------------------+');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Job Ended on: '||to_char(sysdate,'MM-DD-YYYY HH24:MI:SS'));

    EXCEPTION
    WHEN FND_API.g_exc_error THEN
    ROLLBACK TO Start_Process;
    FND_FILE.PUT_LINE(FND_FILE.LOG, '/*--- Error happened during LE ---*/');
    OZF_UTILITY_PVT.Write_Conc_Log;
    ERRBUF  := l_msg_data;
    RETCODE := 1;

    WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Start_Process;
    FND_FILE.PUT_LINE(FND_FILE.LOG, '/*--- Error happened during LE ---*/');
    OZF_UTILITY_PVT.Write_Conc_Log;
    ERRBUF  := l_msg_data;
    RETCODE := 2;

    WHEN OTHERS THEN
    ROLLBACK TO Start_Process;
    FND_FILE.PUT_LINE(FND_FILE.LOG, '/*--- Inside Others, Error happened during LE ---*/');
    OZF_UTILITY_PVT.Write_Conc_Log;
    ERRBUF  := l_msg_data;
    RETCODE := 2;

 END Start_Process;

END OZF_LE_UPGRADE_PVT;

/
