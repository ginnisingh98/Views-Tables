--------------------------------------------------------
--  DDL for Package Body EAM_PROCESS_FAILURE_ENTRY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_PROCESS_FAILURE_ENTRY_PVT" AS
/* $Header: EAMVFENB.pls 120.0.12010000.4 2012/03/09 14:02:11 vboddapa ship $ */
/***************************************************************************
--
--  Copyright (c) 2005 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--      EAMVFENS.pls
--
--  DESCRIPTION
--  This package defines private APIs
--    1. Failure Information insertion/ updation at Work Order Level
--
--  NOTES
--
--  HISTORY
--  03-JAN-2006    Bhushan Goel     Initial Creation
***************************************************************************/

G_PKG_NAME CONSTANT VARCHAR2(30):='Eam_Process_Failure_Entry_PVT';

/* Procedure to Validate the Failure Information Header Recrod */

PROCEDURE Validate_Failure_Entry_Record
(
   p_eam_failure_entry_record   IN  EAM_Process_Failure_Entry_PUB.EAM_Failure_Entry_Record_Typ
 , x_reason_failed              OUT NOCOPY VARCHAR2
 , x_token_name                 OUT NOCOPY VARCHAR2
 , x_token_value                OUT NOCOPY VARCHAR2
 , x_return_status              OUT NOCOPY BOOLEAN
) IS

l_eam_failure_entry_record      Eam_Process_Failure_Entry_PUB.Eam_Failure_Entry_Record_Typ;
l_eam_failure_codes_tbl         Eam_Process_Failure_Entry_PUB.Eam_Failure_Codes_Tbl_Typ;
l_eam_failure_codes_record      Eam_Process_Failure_Entry_PUB.Eam_Failure_Codes_Typ;

l_inventory_item_id             NUMBER;
l_organization_id               NUMBER;

l_valid_source_type             NUMBER;
l_valid_source_id               NUMBER;
l_valid_object_type             NUMBER;
l_valid_object_id               NUMBER;
l_valid_failure_codes_record    BOOLEAN;

l_failure_code_required         VARCHAR2(1);
l_reason_failed                 VARCHAR2(4000);

l_failure_id                    NUMBER;
l_failure_exists                NUMBER;

BEGIN

     /* We are not validating the following Failure Information Fields
      * DEPARTMENT_ID
      * AREA_ID
      * MAINT_ORGANIZATION_ID
      * CURRENT_ORGANIZATION_ID
      */

     x_token_name   := NULL;
     x_token_value  := NULL;

     l_valid_source_type           := 0;
     l_valid_source_id             := 0;
     l_valid_object_type           := 0;
     l_valid_object_id             := 0;

     l_eam_failure_entry_record :=  p_eam_failure_entry_record;

     l_failure_exists     := 0;

     IF (     l_eam_failure_entry_record.transaction_type <> Eam_Process_Failure_Entry_PUB.G_FE_CREATE
          AND l_eam_failure_entry_record.transaction_type <> Eam_Process_Failure_Entry_PUB.G_FE_UPDATE
        )
     THEN
        /* Invalid Transaction Type */
        x_reason_failed := 'EAM_FA_INVALID_TXN_TYPE';
        x_return_status := false;
        return ;
     END IF;

     IF (    l_eam_failure_entry_record.failure_date IS NOT NULL
         AND l_eam_failure_entry_record.failure_date > SYSDATE
        ) THEN
        --Reported failure date can not be a future date
        x_reason_failed := 'EAM_DATE_GREATER_SYSDATE';
        x_return_status := false;
        return ;
     END IF;

     IF l_eam_failure_entry_record.transaction_type = Eam_Process_Failure_Entry_PUB.G_FE_CREATE
     THEN

        IF (   l_eam_failure_entry_record.source_id IS NULL
            OR l_eam_failure_entry_record.source_type IS NULL
            OR l_eam_failure_entry_record.object_id IS NULL
            OR l_eam_failure_entry_record.object_type IS NULL
           ) THEN
           -- Some of the following failure entry required parameters are null
           -- source_id, source_typ, object_id, object_typ
           x_reason_failed:='EAM_FAILURE_RECORD_NULL';
           x_return_status := false;
           return ;
        END IF;

        /* Validate object_typ and source_typ */
        SELECT COUNT(1)
          INTO l_valid_object_type
          FROM MFG_LOOKUPS
         WHERE lookup_type = 'EAM_ASSET_FAIL_SRC_TYPE'
           AND lookup_code = l_eam_failure_entry_record.source_type;

        IF l_valid_object_type = 0 THEN
           x_reason_failed:='EAM_INVALID_SRC_TYPE';
           x_token_name   := 'SOURCE_TYPE';
           x_token_value  := l_eam_failure_entry_record.source_type;
           x_return_status := false;
           return ;
        END IF;

        SELECT COUNT(1)
          INTO l_valid_object_type
          FROM MFG_LOOKUPS
         WHERE lookup_type = 'WIP_MAINTENANCE_OBJECT_TYPE'
           AND lookup_code = l_eam_failure_entry_record.object_type;

        IF l_valid_object_type = 0 THEN
           x_reason_failed:='EAM_INVALID_OBJECT_TYPE';
           x_token_name   := 'OBJECT_TYPE';
           x_token_value  := l_eam_failure_entry_record.object_type;
           x_return_status := false;
           return ;
        END IF;

        IF l_eam_failure_entry_record.object_type = 1 THEN
           SELECT COUNT(1)
             INTO l_valid_object_id
		FROM CSI_ITEM_INSTANCES
            WHERE instance_id = l_eam_failure_entry_record.object_id;
           IF l_valid_object_id = 0 THEN
              -- Object_id is not a valid maintenace object
              -- Not a Valid Maintenance Object Id
              x_reason_failed:='EAM_INVALID_OBJECT_ID';
              x_token_name   := 'ASSET_NUMBER';
              x_token_value  := l_eam_failure_entry_record.object_id;
              x_return_status := false;
              return ;
           END IF;
        END IF;

        IF l_eam_failure_entry_record.source_type = 1 THEN
           SELECT COUNT(1)
             INTO l_valid_source_id
             FROM wip_discrete_jobs wdj, wip_entities we
            WHERE wdj.wip_entity_id = we.wip_entity_id
              AND wdj.wip_entity_id = l_eam_failure_entry_record.source_id
              AND we.entity_type IN (6,7);

           IF l_valid_source_id = 0 THEN
              x_reason_failed:='EAM_INVALID_WIP_ENTITY_ID';
              x_token_name   := 'SOURCE_ID';
              x_token_value  := l_eam_failure_entry_record.source_id;
              x_return_status := false;
              return ;
           END IF;
        END IF;

        /* Check if the record already exists corresponding to
           the source_id, source_type */
        SELECT COUNT(1)
          INTO l_failure_exists
          FROM eam_asset_failures
         WHERE source_type = l_eam_failure_entry_record.source_type
           AND source_id = l_eam_failure_entry_record.source_id;

        IF l_failure_exists >= 1 THEN
           x_reason_failed:='EAM_FAILURE_EXISTS';
           x_token_name   := 'SOURCE_ID';
           x_token_value  := l_eam_failure_entry_record.source_id;
           x_return_status := false;
           return ;
        END IF;

     ELSIF l_eam_failure_entry_record.transaction_type = Eam_Process_Failure_Entry_PUB.G_FE_UPDATE THEN

     /* Failure Date is Already Validated on top of the API for both Create/ Update */

       SELECT COUNT(1)
         INTO l_failure_exists
         FROM eam_asset_failures
        WHERE failure_id = l_eam_failure_entry_record.failure_id;

       IF l_failure_exists = 0 THEN
          x_reason_failed:='EAM_FAILURE_NOT_EXISTS';
          x_token_name   := 'SOURCE_ID';
          x_token_value  := l_eam_failure_entry_record.source_id;
          x_return_status := false;
          return ;
       END IF;

     END IF;

     x_return_status := true;

END Validate_Failure_Entry_Record;


/* Procedure to Validate the Child Failure Information Record Table.
 */
PROCEDURE Validate_Failure_Codes
(
    p_eam_failure_codes_tbl_typ  IN  Eam_Process_Failure_Entry_Pub.Eam_Failure_Codes_Tbl_Typ
  , x_reason_failed              OUT NOCOPY VARCHAR2
  , x_token_name                 OUT NOCOPY VARCHAR2
  , x_token_value                OUT NOCOPY VARCHAR2
  , x_return_status              OUT NOCOPY BOOLEAN
) IS

l_eam_failure_codes_tbl         Eam_Process_Failure_Entry_PUB.eam_failure_codes_tbl_typ;
l_eam_failure_codes_record      Eam_Process_Failure_Entry_PUB.eam_failure_codes_typ;

l_valid_header_record           NUMBER;
l_valid_failure_code            NUMBER;
l_valid_cause_code              NUMBER;
l_valid_resolution_code         NUMBER;

l_failure_codes_exists          NUMBER;
l_validate_failure_codes        BOOLEAN;

l_inventory_item_id             NUMBER;

l_old_failure_code              VARCHAR2(80);
l_old_cause_code                VARCHAR2(80);
l_old_resolution_code           VARCHAR2(80);

BEGIN

     l_valid_header_record         := 0;
     l_valid_failure_code          := 0;
     l_valid_cause_code            := 0;
     l_valid_resolution_code       := 0;

     l_failure_codes_exists         := 0;
     l_validate_failure_codes      := true;

     l_eam_failure_codes_tbl       := p_eam_failure_codes_tbl_typ;

     /* Validate each Failure Codes Record One By One */
     FOR i in 1..l_eam_failure_codes_tbl.count
     LOOP

       l_eam_failure_codes_record    :=  l_eam_failure_codes_tbl(i);

       IF l_eam_failure_codes_record.transaction_type IN (Eam_Process_Failure_Entry_PUB.G_FE_CREATE, Eam_Process_Failure_Entry_PUB.G_FE_UPDATE) THEN

          SELECT count(1)
	    INTO l_valid_header_record
	    FROM eam_asset_failures eaf
	   WHERE eaf.failure_id = l_eam_failure_codes_record.failure_id;

	  IF l_valid_header_record = 0 THEN
	     x_reason_failed:= 'EAM_HEADER_REC_NOT_EXISTS';
             x_return_status := false;
             return ;
          END IF;

          IF l_eam_failure_codes_record.transaction_type = Eam_Process_Failure_Entry_PUB.G_FE_UPDATE THEN
             BEGIN
               SELECT failure_code, cause_code, resolution_code
                 INTO l_old_failure_code, l_old_cause_code, l_old_resolution_code
                 FROM eam_asset_failure_codes
                WHERE failure_entry_id = l_eam_failure_codes_record.failure_entry_id;
             EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  x_reason_failed:='EAM_FAILURE_CHILD_NOT_EXISTS';
                  x_return_status := false;
                  return ;
             END;

             IF ( (     nvl(l_eam_failure_codes_record.failure_code,'NULL VALUE')    = nvl(l_old_failure_code,'NULL VALUE')
	            AND nvl(l_eam_failure_codes_record.cause_code,'NULL VALUE')      = nvl(l_old_cause_code,'NULL VALUE')
	            AND nvl(l_eam_failure_codes_record.resolution_code,'NULL VALUE') = nvl(l_old_resolution_code,'NULL VALUE')
	          ) /*OR
	          (
	                l_eam_failure_codes_record.failure_code    IS NULL
		    AND l_eam_failure_codes_record.cause_code      IS NULL
	            AND l_eam_failure_codes_record.resolution_code IS NULL
	          ) */
	        ) THEN
                 l_validate_failure_codes := false;

             ELSE

               SELECT count(1)
                 INTO l_failure_codes_exists
                 FROM eam_asset_failure_codes eafc
                WHERE eafc.failure_id = l_eam_failure_codes_record.failure_id
                  AND nvl(eafc.failure_code,'NULL VALUE') = nvl(l_eam_failure_codes_record.failure_code,'NULL VALUE')
                  AND nvl(eafc.cause_code,'NULL VALUE')   = nvl(l_eam_failure_codes_record.cause_code,'NULL VALUE')
                  AND nvl(eafc.resolution_code,'NULL VALUE') = nvl(l_eam_failure_codes_record.resolution_code,'NULL VALUE');

               IF l_failure_codes_exists <> 0 THEN
                  x_reason_failed:='EAM_FAILURE_ALREADY_EXISTS';
                  x_return_status := false;
                  return ;
               END IF;

             END IF;

          ELSIF l_eam_failure_codes_record.transaction_type = Eam_Process_Failure_Entry_PUB.G_FE_CREATE THEN

            IF (    l_eam_failure_codes_record.failure_code IS NULL
	        AND l_eam_failure_codes_record.cause_code IS NULL
	        AND l_eam_failure_codes_record.resolution_code IS NULL
	        AND l_eam_failure_codes_record.comments IS NULL
               )
            THEN
              x_reason_failed:='EAM_FAILURE_CHILD_NULL';
              x_return_status := false;
              return ;
            END IF;

            IF (    l_eam_failure_codes_record.failure_code   IS NOT NULL
		OR l_eam_failure_codes_record.cause_code      IS NOT NULL
	        OR l_eam_failure_codes_record.resolution_code IS NOT NULL
               )
            THEN

               /* Check if the record already exists corresponding to the failure_id */
	       SELECT COUNT(1)
	         INTO l_failure_codes_exists
	         FROM eam_asset_failure_codes eafc
	        WHERE eafc.failure_id = l_eam_failure_codes_record.failure_id;

	       IF l_failure_codes_exists >= 1 THEN
	          x_reason_failed:='EAM_MULTIPLE_CHILD';
                  x_return_status := false;
	          return ;
               END IF;

               l_failure_codes_exists := 0;

               /* Check for the Existing Record */
               SELECT count(1)
                 INTO l_failure_codes_exists
                 FROM eam_asset_failure_codes eafc
                WHERE eafc.failure_id = l_eam_failure_codes_record.failure_id
                  AND nvl(eafc.failure_code,'NULL VALUE') = nvl(l_eam_failure_codes_record.failure_code,'NULL VALUE')
                  AND nvl(eafc.cause_code,'NULL VALUE')   = nvl(l_eam_failure_codes_record.cause_code,'NULL VALUE')
                  AND nvl(eafc.resolution_code,'NULL VALUE') = nvl(l_eam_failure_codes_record.resolution_code,'NULL VALUE');

               IF l_failure_codes_exists <> 0 THEN
                  x_reason_failed:='EAM_FAILURE_ALREADY_EXISTS';
                  x_return_status := false;
                  return ;
               END IF;


            /*************
            Need to Verify Whether to Support Multiple Child Records with Comments Only
            ELSE
               SELECT count(1)
	         INTO l_failure_codes_exists
	         FROM eam_asset_failure_codes eafc
                WHERE eafc.failure_id = l_eam_failure_codes_record.failure_id
            *************/
            END IF;
          END IF; /* Create/ Update transaction type validation of failure codes */

       ELSE
          x_reason_failed:= 'EAM_FA_INVALID_TXN_TYPE';
          x_return_status := false;
          return ;
       END IF;

       /***************************************
       No need to Validate Inventory Item Id Here, It has to validated
       while creating the Header Record for the Failure Information.
       In case of creating the Failure Information child record only,
       we are validating the existance for the Failure Information Header
       Required to Validate the Failure Codes.
       */
       BEGIN
         SELECT inventory_item_id
           INTO l_inventory_item_id
		FROM CSI_ITEM_INSTANCES
          WHERE instance_id = ( SELECT object_id FROM eam_asset_failures
                                   WHERE failure_id = l_eam_failure_codes_record.failure_id
                                 );
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
            -- Object_id is not a valid maintenace object
            -- Not a Valid Maintenance Object Id
            x_reason_failed:='EAM_INVALID_OBJECT_ID';
            x_return_status := false;
            return ;
       END;


       IF (    l_eam_failure_codes_record.failure_code IS NOT NULL
           AND l_validate_failure_codes
          ) THEN

	--Modified for 13011472
          SELECT COUNT(1)
            INTO l_valid_failure_code
            FROM eam_failure_combinations EFC,
                 eam_failure_set_associations EFSA
	   WHERE EFC.failure_code = l_eam_failure_codes_record.failure_code
	     AND EFSA.inventory_item_id = l_inventory_item_id
	     AND EFSA.effective_end_date is null
	     AND EFSA.set_id = EFC.set_id
	     AND exists ( SELECT /*+ no_unnest */ 'x'
                                FROM EAM_FAILURE_COMBINATIONS EFC2
                               WHERE NVL(EFC2.EFFECTIVE_END_DATE, SYSDATE) >=  SYSDATE
                                 AND EFC2.SET_ID = EFSA.SET_ID
			    )
             AND exists ( SELECT 'x'
			        FROM EAM_FAILURE_SETS EFS
			       WHERE NVL(EFS.EFFECTIVE_END_DATE, SYSDATE) >= SYSDATE
			         AND EFS.SET_ID =  EFSA.SET_ID
			    )
	     AND rownum = 1;
	 -- end of 13011472

	  IF l_valid_failure_code = 0 THEN
             -- Failure code is not valid for this maintenance object id
             -- Not a Valid Failure Code
            x_reason_failed:='EAM_INVALID_FAILURE_CODE';
            x_token_name   := 'FAILURE_CODE';
            x_token_value  := l_eam_failure_codes_record.failure_code;
            x_return_status := false;
            return ;
          END IF;

       END IF;

       IF (   l_eam_failure_codes_record.cause_code IS NOT NULL
           AND l_validate_failure_codes
          ) THEN

          SELECT count(1)
            INTO l_valid_cause_code
            FROM eam_failure_combinations EFC,
                 eam_failure_set_associations EFSA
           WHERE EFC.cause_code = l_eam_failure_codes_record.cause_code
             AND EFSA.inventory_item_id = l_inventory_item_id
             AND EFSA.effective_end_date IS NULL
             AND EFSA.set_id = efc.set_id
             AND efc.failure_code = l_eam_failure_codes_record.failure_code
             AND SYSDATE <= ( SELECT min(nvl(EFC2.effective_end_date, sysdate))
                                FROM eam_failure_combinations EFC2
                               WHERE nvl(EFC2.effective_end_date, sysdate) >= sysdate
                                 AND EFC2.set_id = EFSA.set_id
                            )
             AND SYSDATE <= ( SELECT min(nvl(EFS.EFFECTIVE_END_DATE, SYSDATE))
			        FROM EAM_FAILURE_SETS EFS
			       WHERE nvl(EFS.EFFECTIVE_END_DATE, SYSDATE) >= sysdate
			         AND EFS.SET_ID = EFSA.SET_ID
			    );
          IF l_valid_cause_code = 0 THEN
             -- Cause code is not valid for this maintenance object id
             -- Not a Valid Cause Code
             x_reason_failed:='EAM_INVALID_CAUSE_CODE';
             x_token_name   := 'CAUSE_CODE';
             x_token_value  := l_eam_failure_codes_record.cause_code;
             x_return_status := false;
             return ;
          END IF;

       END IF;

       IF (    l_eam_failure_codes_record.resolution_code IS NOT NULL
           AND l_validate_failure_codes
          ) THEN

           SELECT COUNT(1)
             INTO l_valid_resolution_code
	     FROM eam_failure_combinations EFC,
	          eam_failure_set_associations EFSA
	    WHERE EFC.resolution_code = l_eam_failure_codes_record.resolution_code
	      AND EFSA.inventory_item_id = l_inventory_item_id
	      AND EFSA.EFFECTIVE_END_DATE IS NULL
	      AND EFSA.set_id = efc.set_id
	      AND EFC.failure_code = l_eam_failure_codes_record.failure_code
	      AND EFC.cause_code = l_eam_failure_codes_record.cause_code
	      AND SYSDATE <= ( SELECT min(nvl(EFC2.effective_end_date, sysdate))
	                         FROM eam_failure_combinations EFC2
	                        WHERE nvl(EFC2.effective_end_date, sysdate) >= sysdate
	                          AND EFC2.set_id = EFSA.set_id
	                     )
             AND SYSDATE <= ( SELECT min(nvl(EFS.EFFECTIVE_END_DATE, SYSDATE))
			        FROM EAM_FAILURE_SETS EFS
			       WHERE nvl(EFS.EFFECTIVE_END_DATE, SYSDATE) >= sysdate
			         AND EFS.SET_ID = EFSA.SET_ID
			    );

           IF l_valid_resolution_code = 0 THEN
              -- Resolution code is not valid for this maintenance object id
              -- Not a Valid Resolution Code
	      x_reason_failed:='EAM_INVALID_RESOLUTION_CODE';
              x_token_name   := 'RESOLUTION_CODE';
              x_token_value  := l_eam_failure_codes_record.resolution_code;
              x_return_status := false;
              return ;
           END IF;

       END IF;
       l_eam_failure_codes_record := NULL;

     END LOOP;
     x_return_status := true;

END;


/**************************************************************************
-- Start of comments
--	API name 	: Process_Failure_Entry
--	Type		: Public.
--	Function	: Insert/ Update Failure Information corresponding
--	                  to a work order
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: p_api_version      IN NUMBER   Required
--			  p_init_msg_list    IN VARCHAR2 Optional
--				 Default = FND_API.G_FALSE
--	   		  p_commit           IN VARCHAR2 Optional
--                               Default = FND_API.G_FALSE
--                        p_eam_failure_entry_record   IN
--                              Eam_Process_Failure_Entry_PUB.eam_failure_entry_record_typ
--                        p_eam_failure_codes_tbl      IN
--                              Eam_Process_Failure_Entry_PUB.eam_failure_codes_tbl_typ
--	OUT		: x_return_status    OUT NOCOPY  VARCHAR2(1)
--                        x_msg_count        OUT NOCOPY  NUMBER
--			  x_msg_data         OUT NOCOPY  VARCHAR2(2000)
--			  x_eam_failure_entry_record   OUT NOCOPY
--			         Eam_Process_Failure_Entry_PUB.eam_failure_entry_record_typ
--			  x_eam_failure_codes_tbl      OUT NOCOPY
--			         Eam_Process_Failure_Entry_PUB.eam_failure_codes_tbl_typ
--	Version	: Current version	1.0.
--		  Initial version 	1.0
-- End of comments
***************************************************************************/

PROCEDURE Process_Failure_Entry
(  p_api_version                IN  NUMBER   := 1.0
 , p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE
 , p_commit                     IN  VARCHAR2 := FND_API.G_FALSE
 , p_eam_failure_entry_record   IN  Eam_Process_Failure_Entry_PUB.eam_failure_entry_record_typ
 , p_eam_failure_codes_tbl      IN  Eam_Process_Failure_Entry_PUB.eam_failure_codes_tbl_typ
 , x_return_status              OUT NOCOPY VARCHAR2
 , x_msg_count                  OUT NOCOPY NUMBER
 , x_msg_data                   OUT NOCOPY VARCHAR2
 , x_eam_failure_entry_record   OUT NOCOPY  Eam_Process_Failure_Entry_PUB.eam_failure_entry_record_typ
 , x_eam_failure_codes_tbl      OUT NOCOPY  Eam_Process_Failure_Entry_PUB.eam_failure_codes_tbl_typ
) IS

l_api_name      CONSTANT VARCHAR2(30) := 'Process_Failure_Entry';
l_api_version   CONSTANT NUMBER       := 1.0;

l_eam_failure_entry_record         Eam_Process_Failure_Entry_Pub.Eam_Failure_Entry_Record_Typ;
l_eam_failure_codes_tbl            Eam_Process_Failure_Entry_Pub.Eam_Failure_Codes_Tbl_Typ;
l_eam_failure_codes_record         Eam_Process_Failure_Entry_Pub.Eam_Failure_Codes_Typ;

l_eam_asset_failure_codes_rec      Eam_Asset_Failure_Codes%ROWTYPE;

l_failure_id              NUMBER;

l_inventory_item_id       NUMBER;
l_organization_id         NUMBER;

l_validate_failure_codes     BOOLEAN;

l_return_status              BOOLEAN ;

l_reason_failed           VARCHAR2(4000);
l_message_name            VARCHAR2(20000);

l_failure_entry_id        NUMBER;

l_combination_id          NUMBER;


l_token_name              VARCHAR2(30);
l_token_value             VARCHAR2(100);

BEGIN

     /* dbms_output.put_line('Start Processing Process_Failure_Entry'); */

     -- API savepoint
     SAVEPOINT Process_Failure_Entry_PVT;

     -- check for call compatibility.
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
     l_token_name    := NULL;
     l_token_value   := NULL;

     l_eam_failure_entry_record := p_eam_failure_entry_record;
     l_eam_failure_codes_tbl    := p_eam_failure_codes_tbl;

     IF l_eam_failure_entry_record.transaction_type IS NULL THEN
        --Don't validate the header record
        NULL;
     ELSIF l_eam_failure_entry_record.transaction_type IN (Eam_Process_Failure_Entry_PUB.G_FE_CREATE, Eam_Process_Failure_Entry_PUB.G_FE_UPDATE) THEN
        /* dbms_output.put_line('Befor Validate_failure_entry_record'); */
        l_return_status := true;
        validate_failure_entry_record(
		    p_eam_failure_entry_record => l_eam_failure_entry_record
		  , x_reason_failed            => l_reason_failed
		  , x_token_name               => l_token_name
		  , x_token_value              => l_token_value
		  , x_return_status            => l_return_status
                                      );
        /* dbms_output.put_line('After Validate_failure_entry_record'); */
        IF (NOT l_return_status) THEN
	   /* dbms_output.put_line('failure_entry_record is not valid'); */
	   FND_MESSAGE.SET_NAME ('EAM', l_reason_failed);
	   IF ( l_token_name is not null AND l_token_value IS NOT NULL )
	   THEN
	      fnd_message.set_token
	             (  token     => l_token_name
	              , value     => l_token_value
                     );
	   END IF;
	   FND_MSG_PUB.Add;
	   RAISE FND_API.G_EXC_ERROR;
        END IF;

     ELSE
        /* dbms_output.put_line('After Validate_failure_entry_record1'); */
        --Please Enter a Valid Transaction typ:
	--1: Failure Information Entry
	--2: Failure Information Update
	FND_MESSAGE.SET_NAME ('EAM', 'EAM_FA_INVALID_TXN_TYPE');
	FND_MSG_PUB.Add;
	RAISE FND_API.G_EXC_ERROR;
	/* dbms_output.put_line('After Validate_failure_entry_record2'); */

     END IF;

     /* dbms_output.put_line('Just Before Inserting the data into eam_asset_failures00');  */

     IF l_eam_failure_entry_record.transaction_type IS NOT NULL THEN

        IF l_eam_failure_entry_record.transaction_type = Eam_Process_Failure_Entry_PUB.G_FE_CREATE THEN
           /* dbms_output.put_line('Just Before Inserting the data into eam_asset_failures0'); */
           SELECT eam_asset_failures_s.nextval
             INTO l_failure_id
             FROM DUAL;
           l_eam_failure_entry_record.failure_id := l_failure_id;
     	   /* dbms_output.put_line('Just Before Inserting the data into eam_asset_failures');  */
           INSERT INTO eam_asset_failures
           (
           	FAILURE_ID,
     		FAILURE_DATE,
     		SOURCE_TYPE,
     		SOURCE_ID,
     		OBJECT_TYPE,
     		OBJECT_ID,
                MAINT_ORGANIZATION_ID,
                CURRENT_ORGANIZATION_ID,
     		DEPARTMENT_ID,
     		AREA_ID,
     		CREATED_BY,
     		CREATION_DATE,
     		LAST_UPDATE_DATE,
     		LAST_UPDATED_BY,
     		LAST_UPDATE_LOGIN
           )
           VALUES
           (
           	l_eam_failure_entry_record.failure_id,
           	l_eam_failure_entry_record.failure_date,
           	l_eam_failure_entry_record.source_type,
           	l_eam_failure_entry_record.source_id,
           	l_eam_failure_entry_record.object_type,
           	l_eam_failure_entry_record.object_id,
                l_eam_failure_entry_record.maint_organization_id,
                l_eam_failure_entry_record.current_organization_id,
           	l_eam_failure_entry_record.department_id,
           	l_eam_failure_entry_record.area_id,
           	FND_GLOBAL.user_id,
           	SYSDATE,
           	SYSDATE,
           	FND_GLOBAL.user_id,
           	FND_GLOBAL.user_id
           );
           /* dbms_output.put_line('Just After Inserting the data into eam_asset_failures'); */

           FOR i IN 1..l_eam_failure_codes_tbl.count
           LOOP
             IF l_eam_failure_codes_tbl(i).transaction_type = Eam_Process_Failure_Entry_PUB.G_FE_CREATE THEN
	        l_eam_failure_codes_tbl(i).failure_id := l_failure_id;
             END IF;
           END LOOP;

        ELSIF l_eam_failure_entry_record.transaction_type = Eam_Process_Failure_Entry_PUB.G_FE_UPDATE THEN
           /* dbms_output.put_line('Just Before Updating the data into eam_asset_failures'); */
           UPDATE eam_asset_failures
              SET failure_date     =  l_eam_failure_entry_record.failure_date
     	      /* ,source_typ       =  l_eam_failure_entry_record.source_typ
                 ,source_id        =  l_eam_failure_entry_record.source_id
     	         ,object_typ       =  l_eam_failure_entry_record.object_typ
     		 ,object_id        =  l_eam_failure_entry_record.object_id
                 ,maint_organization_id   = l_eam_failure_entry_record.maint_organization_id
                 ,current_organization_id = l_eam_failure_entry_record.current_organization_id */
     		 ,department_id    =  l_eam_failure_entry_record.department_id
     		 ,area_id          =  l_eam_failure_entry_record.area_id
     		 ,last_update_date =  SYSDATE
     		 ,last_updated_by  =  FND_GLOBAL.user_id
     		 ,last_update_login=  FND_GLOBAL.user_id
            WHERE failure_id = l_eam_failure_entry_record.failure_id;
           /* dbms_output.put_line('Just After Updating the data into eam_asset_failures'); */

        END IF;
     END IF;
     /* dbms_output.put_line('Just Before Validating the data into eam_asset_failures_codes');  */
     --Validate the child records
     l_return_status := true;
     validate_failure_codes(
	    p_eam_failure_codes_tbl_typ  => l_eam_failure_codes_tbl
          , x_reason_failed              => l_reason_failed
          , x_token_name                 => l_token_name
          , x_token_value                => l_token_value
          , x_return_status              => l_return_status
                          );
     /* dbms_output.put_line('Just After Validating the data into eam_asset_failures_codes');  */
     IF (NOT l_return_status ) THEN
     	FND_MESSAGE.SET_NAME ('EAM', l_reason_failed);
     	IF ( l_token_name is not null AND l_token_value IS NOT NULL )
	THEN
	   fnd_message.set_token
	   (  token     => l_token_name
	    , value     => l_token_value
	   );
	END IF;
     	FND_MSG_PUB.Add;
     	RAISE FND_API.G_EXC_ERROR;
     END IF;

     FOR i IN 1..l_eam_failure_codes_tbl.count
     LOOP
       l_eam_failure_codes_record := l_eam_failure_codes_tbl(i);
       IF l_eam_failure_codes_record.transaction_type IS NOT NULL THEN

          l_combination_id := NULL;
          IF(    l_eam_failure_codes_record.failure_code IS NOT NULL
             AND l_eam_failure_codes_record.cause_code IS NOT NULL
             AND l_eam_failure_codes_record.resolution_code IS NOT NULL
            )
          THEN
            BEGIN

              SELECT inventory_item_id
                INTO l_inventory_item_id
                  FROM CSI_ITEM_INSTANCES
               WHERE instance_id = ( SELECT object_id
                                         FROM eam_asset_failures
                                        WHERE failure_id = l_eam_failure_codes_record.failure_id
                                     );
              SELECT COMBINATION_ID
                INTO l_combination_id
                FROM eam_failure_combinations EFC,
                     eam_failure_set_associations EFSA
               WHERE EFC.failure_code       = l_eam_failure_codes_record.failure_code
                 AND EFC.cause_code         = l_eam_failure_codes_record.cause_code
                 AND EFC.resolution_code    = l_eam_failure_codes_record.resolution_code
                 AND EFSA.inventory_item_id = l_inventory_item_id
                 AND EFSA.effective_end_date is null
                 AND EFSA.set_id            = EFC.set_id
	         AND SYSDATE <= ( SELECT min(nvl(EFC2.effective_end_date, sysdate))
	                            FROM eam_failure_combinations EFC2
	                           WHERE nvl(EFC2.effective_end_date, sysdate) >= sysdate
	                             AND EFC2.set_id = EFSA.set_id
	                        )
                 AND SYSDATE <= ( SELECT min(nvl(EFS.EFFECTIVE_END_DATE, SYSDATE))
		                    FROM EAM_FAILURE_SETS EFS
		                   WHERE nvl(EFS.EFFECTIVE_END_DATE, SYSDATE) >= sysdate
		                     AND EFS.SET_ID = EFSA.SET_ID
		                );
	     EXCEPTION
	       WHEN NO_DATA_FOUND THEN
	       l_combination_id := NULL;
	     END;
          END IF;
          l_eam_failure_codes_record.combination_id := l_combination_id;

          IF l_eam_failure_codes_record.transaction_type = Eam_Process_Failure_Entry_PUB.G_FE_CREATE THEN

             /* dbms_output.put_line('Just Before Inserting the data into eam_asset_failure_codes'); */

             SELECT eam_asset_failure_codes_s.nextval
	       INTO l_failure_entry_id
               FROM DUAL;
             l_eam_failure_codes_record.failure_entry_id := l_failure_entry_id;

             INSERT INTO eam_asset_failure_codes
	             (
	     	   	failure_id,
	     	   	failure_entry_id,
	     	   	combination_id,
	     	   	failure_code,
	     	   	cause_code,
	     	   	resolution_code,
	     	   	comments,
	     	   	created_by,
	     	   	creation_date,
	     		last_update_date,
	     		last_updated_by,
	     		last_update_login
	             )
	             VALUES
	             (
	               	l_eam_failure_codes_record.failure_id,
	               	l_eam_failure_codes_record.failure_entry_id,
	               	l_eam_failure_codes_record.combination_id,
	               	l_eam_failure_codes_record.failure_code,
	               	l_eam_failure_codes_record.cause_code,
	               	l_eam_failure_codes_record.resolution_code,
	               	l_eam_failure_codes_record.comments,
	               	FND_GLOBAL.user_id,
	              	SYSDATE,
	               	SYSDATE,
	               	FND_GLOBAL.user_id,
	               	FND_GLOBAL.user_id
                     );
             /* dbms_output.put_line('Just After Inserting the data into eam_asset_failure_codes'); */

          ELSIF l_eam_failure_entry_record.transaction_type = Eam_Process_Failure_Entry_PUB.G_FE_UPDATE THEN

             UPDATE eam_asset_failure_codes
                SET failure_code           = l_eam_failure_codes_record.failure_code
                   ,cause_code             = l_eam_failure_codes_record.cause_code
                   ,resolution_code        = l_eam_failure_codes_record.resolution_code
                   ,combination_id         = nvl( l_eam_failure_codes_record.combination_id, combination_id)
                   ,comments               = l_eam_failure_codes_record.comments
                   ,last_update_date       = SYSDATE
                   ,last_updated_by        = FND_GLOBAL.user_id
                   ,last_update_login      = FND_GLOBAL.user_id
              WHERE failure_id = l_eam_failure_codes_record.failure_id
                AND failure_entry_id = l_eam_failure_codes_record.failure_entry_id;

          END IF;
       END IF;
       l_eam_failure_codes_tbl(i) := l_eam_failure_codes_record;
       l_eam_failure_codes_record := NULL;
     END LOOP;
     x_eam_failure_entry_record := l_eam_failure_entry_record;
     x_eam_failure_codes_tbl    := l_eam_failure_codes_tbl;

   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO Process_Failure_Entry_PVT;
	x_return_status := FND_API.G_RET_STS_ERROR ;
	/* FND_MSG_PUB.Count_And_Get
    	  (
    	     p_count => x_msg_count     	,
             p_data  => x_msg_data
    	  ); */
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO Process_Failure_Entry_PVT;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	/* FND_MSG_PUB.Count_And_Get
    	  (
    	    p_count => x_msg_count,
            p_data  => x_msg_data
    	  ); */
     WHEN OTHERS THEN
	ROLLBACK TO Process_Failure_Entry_PVT;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
           FND_MSG_PUB.Add_Exc_Msg
    	    (
    	      G_PKG_NAME,
    	      l_api_name
	    );
	END IF;
	/* FND_MSG_PUB.Count_And_Get
    	 (
    	  p_count => x_msg_count,
          p_data  => x_msg_data
    	 ); */

   END process_failure_entry;

    PROCEDURE Delete_Failure_Entry
 (  p_api_version                IN  NUMBER   := 1.0
  , p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE
  , p_commit                     IN  VARCHAR2 := FND_API.G_FALSE
  , p_source_id                  IN  NUMBER
  , x_return_status              OUT NOCOPY VARCHAR2
  , x_msg_count                  OUT NOCOPY NUMBER
  , x_msg_data                   OUT NOCOPY VARCHAR2
 ) IS
  l_count NUMBER;
  l_failure_id NUMBER;
  l_api_version NUMBER   := 1.0;
  l_api_name VARCHAR2(200) := 'Delete_Failure_Entry';
 BEGIN
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(G_PKG_NAME||' Delete_Failure_Entry : Start') ; END IF;

  -- API savepoint
     SAVEPOINT Delete_Failure_Entry_pvt;

     -- check for call compatibility.
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

     SELECT COUNT(1) INTO  l_count FROM eam_asset_failures WHERE source_id = p_source_id;

     IF l_count >=1 THEN

      IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(G_PKG_NAME||' Delete_Failure_Entry : Deleting the earlier failure data') ; END IF;

      SELECT failure_id INTO  l_failure_id  FROM eam_asset_failures WHERE source_id = p_source_id;

      DELETE FROM eam_asset_failure_codes eafc
      WHERE eafc.failure_id=l_failure_id;

      DELETE FROM eam_asset_failures eaf
      WHERE eaf.failure_id=l_failure_id;
    ELSE
      IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(G_PKG_NAME||' Delete_Failure_Entry : Failure information doesn''t exist') ; END IF;
    END IF;

    IF(p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO Delete_Failure_Entry_pvt;
      IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(G_PKG_NAME||' Delete_Failure_Entry : Error in deleting the existing failure data:'||SQLERRM) ; END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;

 END Delete_Failure_Entry;


END Eam_Process_Failure_Entry_PVT;

/
