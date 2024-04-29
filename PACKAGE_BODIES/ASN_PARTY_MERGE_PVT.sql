--------------------------------------------------------
--  DDL for Package Body ASN_PARTY_MERGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASN_PARTY_MERGE_PVT" AS
/* $Header: asnvpmgb.pls 120.2 2005/09/13 15:44:00 rradhakr noship $ */


  G_PKG_NAME  CONSTANT VARCHAR2(30):='ASN_PARTY_MERGE_PVT';
  G_FILE_NAME CONSTANT VARCHAR2(12):='ASNVPMGB.pls';

  G_PROC_NAME CONSTANT VARCHAR2(25) := 'MERGE_ACCOUNT_PLANS';

  /* Logging related constants */
  G_PROC_LEVEL NUMBER := FND_LOG.LEVEL_PROCEDURE;
  G_STMT_LEVEL NUMBER := FND_LOG.LEVEL_STATEMENT;
  G_EXCP_LEVEL NUMBER := FND_LOG.LEVEL_EXCEPTION;
  G_DEBUG_LEVEL NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;



 PROCEDURE  MERGE_ACCOUNT_PLANS
    (
       p_entity_name                 IN     VARCHAR2,
       p_from_id                     IN     NUMBER,
       x_to_id                       OUT  NOCOPY NUMBER,
       p_from_fk_id                  IN      NUMBER,
       p_to_fk_id                    IN      NUMBER,
       p_parent_entity_name          IN      VARCHAR2,
       p_batch_id                    IN      NUMBER,
       p_batch_party_id              IN      NUMBER,
       x_return_status               OUT NOCOPY VARCHAR2
    )
    IS

      l_api_name               CONSTANT VARCHAR2(30) := 'MERGE_ACCOUNT_PLANS';
      l_api_version                  CONSTANT NUMBER       := 1.0;
      l_account_plan_id  NUMBER(10);

      CURSOR c_merge_acctplan   IS
      SELECT 1
      FROM as_ap_account_plans
      WHERE cust_party_id = p_from_fk_id
      FOR UPDATE NOWAIT;

      CURSOR   c_account_plan   IS
      SELECT   account_plan_id
      FROM     as_ap_account_plans
      WHERE   cust_party_id = p_to_fk_id;


 BEGIN

     IF (G_PROC_LEVEL >= G_DEBUG_LEVEL) THEN
       FND_LOG.String(G_PROC_LEVEL,
                      G_PROC_NAME,
                      'begin');
     END IF;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF p_from_fk_id = p_to_fk_id THEN
       x_to_id := p_from_id;
       RETURN;
     END IF;

     IF   p_from_fk_id  <>  p_to_fk_id  THEN
       IF  p_parent_entity_name = 'HZ_PARTIES'  THEN
          OPEN c_account_plan;
           FETCH c_account_plan into l_account_plan_id;
           IF c_account_plan%NOTFOUND  THEN
              OPEN c_merge_acctplan;
              CLOSE c_merge_acctplan;
              UPDATE   as_ap_account_plans
              SET      cust_party_id = p_to_fk_id,
                       last_update_date = hz_utility_pub.last_update_date,
                       last_updated_by  = hz_utility_pub.user_id,
                       last_update_login = hz_utility_pub.last_update_login
              WHERE    cust_party_id = p_from_fk_id;
           END IF;
           CLOSE c_account_plan;
         END IF;
     END IF;
 EXCEPTION
   WHEN OTHERS THEN

     x_return_status :=  FND_API.G_RET_STS_ERROR;

     IF (G_PROC_LEVEL >= G_DEBUG_LEVEL)  THEN
        FND_LOG.String(G_PROC_LEVEL,
                       G_PROC_NAME,
                       'Return Status'|| x_return_status
				   ||' '|| SQLCODE ||'Error'
				   ||substr(SQLERRM,1,1950));
     END IF;
     RAISE;

 END MERGE_ACCOUNT_PLANS;
END;

/
