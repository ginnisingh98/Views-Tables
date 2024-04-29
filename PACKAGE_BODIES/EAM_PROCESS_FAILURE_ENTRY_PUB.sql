--------------------------------------------------------
--  DDL for Package Body EAM_PROCESS_FAILURE_ENTRY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_PROCESS_FAILURE_ENTRY_PUB" AS
/* $Header: EAMPFENB.pls 120.1.12010000.2 2009/04/20 05:43:51 vchidura ship $ */
G_PKG_NAME CONSTANT VARCHAR2(30):='EAM_Process_Failure_Entry_PUB';

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

  l_api_name            CONSTANT VARCHAR2(30) := 'Process_Failure_Entry';
  l_api_version         CONSTANT NUMBER       := 1.0;

  l_eam_failure_entry_record   Eam_Process_Failure_Entry_PUB.eam_failure_entry_record_typ;
  l_eam_failure_codes_tbl      Eam_Process_Failure_Entry_PUB.eam_failure_codes_tbl_typ;

  l_out_msg_count                  NUMBER  ;
  l_out_msg_data                   VARCHAR2(4000);
  l_out_eam_failure_entry_record   Eam_Process_Failure_Entry_PUB.eam_failure_entry_record_typ;
  l_out_eam_failure_codes_tbl      Eam_Process_Failure_Entry_PUB.eam_failure_codes_tbl_typ;


  l_object_type                    NUMBER;
  l_object_id                      NUMBER;
  l_source_id                      NUMBER;
  l_source_type                    NUMBER;
  l_failure_date                   DATE;
  l_maint_organization_id          NUMBER;
  l_current_organization_id        NUMBER;
  l_area_id                        NUMBER;

  l_department_id                  NUMBER;
  l_organization_id                NUMBER;

  l_msn_department_id              NUMBER;
  l_eam_location_id                NUMBER;

  l_failure_code                   VARCHAR2(80);
  l_cause_code                     VARCHAR2(80);
  l_resolution_code                VARCHAR2(80);
  l_comments                       VARCHAR2(2000);

  l_date_completed                 DATE;
  l_failure_code_required          VARCHAR2(1);

BEGIN

    /* We Need to Validate the Client Side Validations Here in the Public API.
     * 1. Failure Codes has to be Mandatory Entered for the 'Completed Work Order'
     *    if the Failure Code Required is YES
     * 2.
     */

    -- API savepoint
    SAVEPOINT Process_Failure_Entry_PUB;

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

    l_eam_failure_entry_record   := p_eam_failure_entry_record;
    l_eam_failure_codes_tbl      := p_eam_failure_codes_tbl;

    /*******************************
     Following Validations Are for 11510 Design.
    ********************************/
    IF ((    l_eam_failure_entry_record.transaction_type <> Eam_Process_Failure_Entry_PUB.G_FE_CREATE
        AND l_eam_failure_entry_record.transaction_type <> Eam_Process_Failure_Entry_PUB.G_FE_UPDATE)
        OR l_eam_failure_entry_record.transaction_type IS NULL
       )
    THEN
      /* Invalid Transaction Type */
      FND_MESSAGE.SET_NAME ('EAM', 'EAM_FA_INVALID_TXN_TYPE');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_eam_failure_codes_tbl.count > 1
    THEN
      FND_MESSAGE.SET_NAME ('EAM', 'EAM_MULTIPLE_CHILD');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (    l_eam_failure_codes_tbl.count = 1
           AND l_eam_failure_codes_tbl(1).transaction_type <> Eam_Process_Failure_Entry_PUB.G_FE_CREATE
           AND l_eam_failure_codes_tbl(1).transaction_type <> Eam_Process_Failure_Entry_PUB.G_FE_UPDATE
          )
    THEN
      FND_MESSAGE.SET_NAME ('EAM', 'EAM_FA_INVALID_TXN_TYPE');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (    l_eam_failure_codes_tbl.count = 1
           AND l_eam_failure_codes_tbl(1).failure_id IS NOT NULL
           AND l_eam_failure_codes_tbl(1).failure_id <> l_eam_failure_entry_record.failure_id
          )
    THEN
      FND_MESSAGE.SET_NAME ('EAM', 'EAM_CHILD_NOT_SYNC');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;


  IF l_eam_failure_entry_record.transaction_type = EAM_Process_Failure_Entry_PUB.G_FE_CREATE THEN

     IF l_eam_failure_entry_record.source_type = 1
     THEN

        IF l_eam_failure_entry_record.source_id IS NULL THEN
           BEGIN
             SELECT wip_entity_id
               INTO l_eam_failure_entry_record.source_id
               FROM wip_entities
              WHERE wip_entity_name = l_eam_failure_entry_record.source_name
                AND organization_id = l_eam_failure_entry_record.maint_organization_id
                AND entity_type in (6,7);
           EXCEPTION
             WHEN NO_DATA_FOUND THEN
               FND_MESSAGE.SET_NAME ('EAM', 'EAM_INVALID_WIP_ENTITY_ID');
               FND_MESSAGE.SET_TOKEN(  token     => 'SOURCE_ID'
                                     , value     => l_eam_failure_entry_record.source_name
                                    );
               FND_MSG_PUB.Add;
               RAISE FND_API.G_EXC_ERROR;
           END;
        END IF;

        BEGIN
          SELECT maintenance_object_id, maintenance_object_type, owning_department, organization_id
            INTO l_object_id          , l_object_type          , l_department_id  , l_organization_id
            FROM wip_discrete_jobs
           WHERE wip_entity_id = l_eam_failure_entry_record.source_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME ('EAM', 'EAM_INVALID_WIP_ENTITY_ID');
            fnd_message.set_token(  token     => 'SOURCE_ID'
                                  , value     => l_eam_failure_entry_record.source_id
                                 );
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
        END;

        IF(    l_eam_failure_entry_record.object_type IS NOT NULL
           AND (   ( l_object_type IS NULL AND l_eam_failure_entry_record.object_type IS NOT NULL)
                OR ( l_object_type <> l_eam_failure_entry_record.object_type)
               )
          )
        THEN
          FND_MESSAGE.SET_NAME ('EAM', 'EAM_INVALID_OBJECT_TYPE');
          FND_MESSAGE.SET_TOKEN(  token     => 'OBJECT_TYPE'
                                , value     => l_eam_failure_entry_record.object_type
                               );
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          l_eam_failure_entry_record.object_type := l_object_type;
        END IF;

        IF(    l_eam_failure_entry_record.object_id IS NOT NULL
           AND (    (l_object_id IS NULL AND l_eam_failure_entry_record.object_id IS NOT NULL)
                 OR (l_object_id <> l_eam_failure_entry_record.object_id)
               )
          )
        THEN
          FND_MESSAGE.SET_NAME ('EAM', 'EAM_INVALID_OBJECT_ID');
          FND_MESSAGE.SET_TOKEN(  token     => 'ASSET_NUMBER'
                                , value     => l_eam_failure_entry_record.object_id
                               );
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          l_eam_failure_entry_record.object_id := l_object_id;
        END IF;

        IF(    l_eam_failure_entry_record.maint_organization_id IS NOT NULL
           AND (   (l_organization_id IS NULL AND l_eam_failure_entry_record.maint_organization_id IS NOT NULL)
                OR (l_organization_id <> l_eam_failure_entry_record.maint_organization_id)
               )
          )
        THEN
          FND_MESSAGE.SET_NAME ('EAM', 'EAM_INVALID_MAINT_ORG');
          FND_MESSAGE.SET_TOKEN(  token     => 'MAINT_ORG_ID'
                                , value     => l_eam_failure_entry_record.maint_organization_id
                               );
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          l_eam_failure_entry_record.maint_organization_id := l_organization_id;
        END IF;

        IF(    l_eam_failure_entry_record.current_organization_id IS NOT NULL
           AND (   (l_organization_id IS NULL AND l_eam_failure_entry_record.current_organization_id IS NOT NULL)
                OR (l_organization_id <> l_eam_failure_entry_record.current_organization_id)
               )
          )
        THEN
          FND_MESSAGE.SET_NAME ('EAM', 'EAM_INVALID_CURRENT_ORG');
          FND_MESSAGE.SET_TOKEN(  token     => 'CURR_ORG_ID'
                                , value     => l_eam_failure_entry_record.current_organization_id
                               );
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          l_eam_failure_entry_record.current_organization_id := l_organization_id;
        END IF;

        BEGIN

          SELECT eomd.owning_department_id,eomd.area_id
	    INTO l_msn_department_id, l_eam_location_id
	    FROM csi_item_instances cii,
             eam_org_maint_defaults eomd,mtl_parameters mp
	   WHERE cii.instance_id = l_object_id
       AND   cii.instance_id = eomd.object_id(+)
       AND   eomd.object_type(+)= 50
       AND cii.last_vld_organization_id = mp.organization_id
       AND ( eomd.organization_id IS NULL OR
       mp.maint_organization_id = eomd.organization_id);

	EXCEPTION
	  WHEN NO_DATA_FOUND THEN
		l_msn_department_id := NULL;
		l_eam_location_id := NULL;
	  WHEN OTHERS THEN
            FND_MESSAGE.SET_NAME ('EAM', 'EAM_INVALID_OBJECT_ID');
            FND_MESSAGE.SET_TOKEN( token  => 'ASSET_NUMBER'
                                  ,value => l_eam_failure_entry_record.object_id
                                 );
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
	END;

        IF (l_department_id IS NULL) THEN
	   l_department_id := l_msn_department_id;
	END IF;

        IF(    l_eam_failure_entry_record.department_id IS NOT NULL
           AND ( (l_department_id IS NULL AND l_eam_failure_entry_record.department_id IS NOT NULL)
                OR l_department_id <> l_eam_failure_entry_record.department_id
               )
          )
        THEN
          FND_MESSAGE.SET_NAME ('EAM', 'EAM_INVALID_DEPARTMENT');
          FND_MESSAGE.SET_TOKEN( token  => 'DEPARTMENT'
                                ,value => l_eam_failure_entry_record.department_id
                               );
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          l_eam_failure_entry_record.department_id := l_department_id;
        END IF;

        IF(    l_eam_failure_entry_record.area_id IS NOT NULL
           AND (   (l_eam_location_id IS NULL AND l_eam_failure_entry_record.area_id IS NOT NULL)
                OR (l_eam_location_id <> l_eam_failure_entry_record.area_id)
               )
          )
        THEN
          FND_MESSAGE.SET_NAME ('EAM', 'EAM_INVALID_AREA');
          FND_MESSAGE.SET_TOKEN( token  => 'AREA'
                                ,value => l_eam_failure_entry_record.area_id
                               );
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          l_eam_failure_entry_record.area_id := l_eam_location_id;
        END IF;

     END IF;

  ELSIF l_eam_failure_entry_record.transaction_type = EAM_Process_Failure_Entry_PUB.G_FE_UPDATE THEN

     IF l_eam_failure_entry_record.failure_id IS NULL THEN

        IF (    l_eam_failure_entry_record.source_type = 1
            AND (    l_eam_failure_entry_record.source_id IS NOT NULL
                  OR (    l_eam_failure_entry_record.source_name IS NOT NULL
                      AND l_eam_failure_entry_record.maint_organization_id IS NOT NULL
                     )
                )
           )
        THEN
           BEGIN
             IF l_eam_failure_entry_record.source_id IS NOT NULL THEN
               SELECT failure_id
                 INTO l_eam_failure_entry_record.failure_id
                 FROM eam_asset_failures
                WHERE source_id   = l_eam_failure_entry_record.source_id
                  AND source_type = 1;
             ELSE
               SELECT failure_id
                 INTO l_eam_failure_entry_record.failure_id
                 FROM eam_asset_failures
                WHERE source_id   = ( SELECT wip_entity_id
                                        FROM WIP_ENTITIES
                                       WHERE WIP_ENTITY_NAME = l_eam_failure_entry_record.source_name
                                         AND organization_id = l_eam_failure_entry_record.maint_organization_id
                                    )
                  AND source_type = 1;
             END IF;
           EXCEPTION
             WHEN NO_DATA_FOUND THEN
               FND_MESSAGE.SET_NAME ('EAM', 'EAM_INVALID_WIP_ENTITY_ID');
               FND_MESSAGE.SET_TOKEN(  token     => 'SOURCE_ID'
                                     , value     => l_eam_failure_entry_record.source_id||l_eam_failure_entry_record.source_name
                                    );
               FND_MSG_PUB.Add;
               RAISE FND_API.G_EXC_ERROR;
           END;
        ELSE
           FND_MESSAGE.SET_NAME ('EAM', 'EAM_INVALID_FAILURE_ID');
	   FND_MSG_PUB.Add;
	   RAISE FND_API.G_EXC_ERROR;
        END IF;
     END IF;


     BEGIN
       SELECT object_type  , object_id   , source_id  , source_type  , failure_date  , maint_organization_id  , current_organization_id  , area_id
         INTO l_object_type, l_object_id , l_source_id, l_source_type, l_failure_date, l_maint_organization_id, l_current_organization_id, l_area_id
         FROM eam_asset_failures
        WHERE failure_id = l_eam_failure_entry_record.failure_id;
       l_eam_failure_entry_record.source_id := l_source_id;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         FND_MESSAGE.SET_NAME ('EAM', 'EAM_FAILURE_NOT_EXISTS');
         FND_MESSAGE.SET_TOKEN(  token     => 'SOURCE_ID'
                               , value     => 'Failure Id :'||l_eam_failure_entry_record.failure_id
                              );
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
     END;

     IF l_source_type = 1
     THEN
        /***************************************************************
        Don't Validate the drived columns.
        IF(   (    l_eam_failure_entry_record.object_type IS NOT NULL
              AND l_eam_failure_entry_record.object_type <> FND_API.G_MISS_NUM
              AND (   l_object_type IS NULL
                   OR l_object_type <> l_eam_failure_entry_record.object_type
                  )
             )
           OR
             (    l_eam_failure_entry_record.object_type = FND_API.G_MISS_NUM
	      AND l_object_type IS NOT NULL
             )
          )
        THEN
          FND_MESSAGE.SET_NAME ('EAM', 'EAM_CANNOT_UPDATE');
          FND_MESSAGE.SET_TOKEN(  token     => 'ATTRIBUTE'
                                , value     => 'OBJECT_TYPE'
                               );
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF(   (   l_eam_failure_entry_record.object_id IS NOT NULL
              AND l_eam_failure_entry_record.object_id <> FND_API.G_MISS_NUM
              AND (   l_object_id IS NULL
                   OR l_object_id <> l_eam_failure_entry_record.object_id
                  )
             )
           OR
             (    l_eam_failure_entry_record.object_id = FND_API.G_MISS_NUM
	      AND l_object_id IS NOT NULL
             )
          )
        THEN
          FND_MESSAGE.SET_NAME ('EAM', 'EAM_CANNOT_UPDATE');
          FND_MESSAGE.SET_TOKEN(  token     => 'ATTRIBUTE'
                                , value     => 'OBJECT_ID'
                               );
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF(   (    l_eam_failure_entry_record.source_type IS NOT NULL
              AND l_eam_failure_entry_record.source_type <> FND_API.G_MISS_NUM
              AND (   l_source_type IS NULL
                   OR l_source_type <> l_eam_failure_entry_record.source_type
                  )
             )
           OR
             (    l_eam_failure_entry_record.source_type = FND_API.G_MISS_NUM
	      AND l_source_type IS NOT NULL
             )
          )
        THEN
          FND_MESSAGE.SET_NAME ('EAM', 'EAM_CANNOT_UPDATE');
          FND_MESSAGE.SET_TOKEN(  token     => 'ATTRIBUTE'
                                , value     => 'SOURCE_TYPE'
                               );
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF(   (    l_eam_failure_entry_record.source_id IS NOT NULL
              AND l_eam_failure_entry_record.source_id <> FND_API.G_MISS_NUM
              AND (   l_source_id IS NULL
                   OR l_source_id <> l_eam_failure_entry_record.source_id
                  )
             )
           OR
             (    l_eam_failure_entry_record.source_id = FND_API.G_MISS_NUM
	      AND l_source_id IS NOT NULL
             )
          )
        THEN
          FND_MESSAGE.SET_NAME ('EAM', 'EAM_CANNOT_UPDATE');
          FND_MESSAGE.SET_TOKEN(  token     => 'ATTRIBUTE'
                                , value     => 'SOURCE_ID'
                               );
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          l_eam_failure_entry_record.source_id := l_source_id;
        END IF;
        ***************************************************************/

        BEGIN
          SELECT owning_department   , organization_id
            INTO l_department_id , l_organization_id
            FROM WIP_DISCRETE_JOBS
           WHERE wip_entity_id = l_source_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
          FND_MESSAGE.SET_NAME ('EAM', 'EAM_INVALID_WIP_ENTITY_ID');
          FND_MESSAGE.SET_TOKEN(  token     => 'SOURCE_ID'
                                , value     => l_eam_failure_entry_record.source_id
                               );
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END;

        IF(  (    l_eam_failure_entry_record.maint_organization_id IS NOT NULL
              AND l_eam_failure_entry_record.maint_organization_id <> FND_API.G_MISS_NUM
              AND (   l_organization_id IS NULL
                   OR l_organization_id <> l_eam_failure_entry_record.maint_organization_id
                  )
             )
           OR
             (    l_eam_failure_entry_record.maint_organization_id = FND_API.G_MISS_NUM
	      AND l_organization_id IS NOT NULL
             )
          )
        THEN
          FND_MESSAGE.SET_NAME ('EAM', 'EAM_INVALID_MAINT_ORG');
          FND_MESSAGE.SET_TOKEN(  token     => 'MAINT_ORG_ID'
                                , value     => l_eam_failure_entry_record.maint_organization_id
                               );
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          l_eam_failure_entry_record.maint_organization_id := l_organization_id;
        END IF;

        IF(  (    l_eam_failure_entry_record.current_organization_id IS NOT NULL
              AND l_eam_failure_entry_record.current_organization_id <> FND_API.G_MISS_NUM
              AND ( l_current_organization_id IS NULL
                   OR l_current_organization_id <> l_eam_failure_entry_record.current_organization_id
                  )
             )
           OR
             (    l_eam_failure_entry_record.current_organization_id = FND_API.G_MISS_NUM
	      AND l_current_organization_id IS NOT NULL
             )
          )
        THEN
          FND_MESSAGE.SET_NAME ('EAM', 'EAM_INVALID_CURRENT_ORG');
          FND_MESSAGE.SET_TOKEN(  token     => 'CURR_ORG_ID'
                                , value     => l_eam_failure_entry_record.current_organization_id
                               );
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          l_eam_failure_entry_record.current_organization_id := l_current_organization_id;
        END IF;

        BEGIN

          SELECT eomd.owning_department_id,eomd.area_id
	    INTO l_msn_department_id, l_eam_location_id
	    FROM csi_item_instances cii,
             eam_org_maint_defaults eomd,mtl_parameters mp
	   WHERE cii.instance_id = l_object_id
       AND   cii.instance_id = eomd.object_id(+)
       AND   eomd.object_type(+)= 50
       AND cii.last_vld_organization_id = mp.organization_id
       AND ( eomd.organization_id IS NULL OR
       mp.maint_organization_id = eomd.organization_id);


	EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	    l_msn_department_id := NULL;
	    l_eam_location_id := NULL;
	  WHEN OTHERS THEN
            FND_MESSAGE.SET_NAME ('EAM', 'EAM_INVALID_OBJECT_ID');
            FND_MESSAGE.SET_TOKEN( token  => 'ASSET_NUMBER'
                                  ,value => l_object_id
                                 );
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
	END;

        IF (l_department_id IS NULL) THEN
	   l_department_id := l_msn_department_id;
	END IF;


        IF(  (    l_eam_failure_entry_record.department_id IS NOT NULL
              AND l_eam_failure_entry_record.department_id <> FND_API.G_MISS_NUM
              AND ( l_department_id IS NULL
                   OR l_department_id <> l_eam_failure_entry_record.department_id
                  )
             )
           OR
             (    l_eam_failure_entry_record.department_id = FND_API.G_MISS_NUM
	      AND l_department_id IS NOT NULL
             )
          )
        THEN
          FND_MESSAGE.SET_NAME ('EAM', 'EAM_INVALID_DEPARTMENT');
          FND_MESSAGE.SET_TOKEN( token  => 'DEPARTMENT'
                                ,value => l_eam_failure_entry_record.department_id
                               );
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          l_eam_failure_entry_record.department_id := l_department_id;
        END IF;


        IF(  (    l_eam_failure_entry_record.area_id IS NOT NULL
              AND l_eam_failure_entry_record.area_id <> FND_API.G_MISS_NUM
              AND (   l_eam_location_id IS NULL
                   OR l_eam_location_id <> l_eam_failure_entry_record.area_id
                  )
             )
           OR
             (    l_eam_failure_entry_record.area_id = FND_API.G_MISS_NUM
	      AND l_eam_location_id IS NOT NULL
             )
          )
        THEN
          FND_MESSAGE.SET_NAME ('EAM', 'EAM_INVALID_AREA');
          FND_MESSAGE.SET_TOKEN( token  => 'AREA'
                                ,value => l_eam_failure_entry_record.area_id
                               );
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          l_eam_failure_entry_record.area_id := l_eam_location_id;
        END IF;

     ELSE
       IF l_eam_failure_entry_record.maint_organization_id = FND_API.G_MISS_NUM THEN
          l_eam_failure_entry_record.maint_organization_id := NULL;
       ELSIF l_eam_failure_entry_record.maint_organization_id IS NULL THEN
          l_eam_failure_entry_record.maint_organization_id := l_maint_organization_id;
       END IF;

       IF l_eam_failure_entry_record.current_organization_id = FND_API.G_MISS_NUM THEN
          l_eam_failure_entry_record.current_organization_id := NULL;
       ELSIF l_eam_failure_entry_record.current_organization_id IS NULL THEN
          l_eam_failure_entry_record.current_organization_id := l_current_organization_id;
       END IF;

       IF l_eam_failure_entry_record.department_id = FND_API.G_MISS_NUM THEN
          l_eam_failure_entry_record.department_id := NULL;
       ELSIF l_eam_failure_entry_record.department_id IS NULL THEN
          l_eam_failure_entry_record.department_id := l_department_id;
       END IF;

       IF l_eam_failure_entry_record.area_id = FND_API.G_MISS_NUM THEN
          l_eam_failure_entry_record.area_id := NULL;
       ELSIF l_eam_failure_entry_record.area_id IS NULL THEN
          l_eam_failure_entry_record.area_id := l_maint_organization_id;
       END IF;

     END IF;

     IF l_eam_failure_entry_record.failure_date = FND_API.G_MISS_DATE THEN
	l_eam_failure_entry_record.failure_date := NULL;
     ELSIF l_eam_failure_entry_record.failure_date IS NULL THEN
        l_eam_failure_entry_record.failure_date := l_failure_date;
     END IF;
  END IF;

  FOR i in 1..l_eam_failure_codes_tbl.count
  LOOP

    IF l_eam_failure_codes_tbl(i).transaction_type = EAM_Process_Failure_Entry_PUB.G_FE_UPDATE THEN

      l_eam_failure_codes_tbl(i).failure_id := l_eam_failure_entry_record.failure_id;

      IF l_eam_failure_codes_tbl(i).failure_entry_id IS NULL
      THEN

       BEGIN
         SELECT failure_entry_id , failure_code, cause_code, resolution_code, comments
           INTO l_eam_failure_codes_tbl(i).failure_entry_id, l_failure_code, l_cause_code, l_resolution_code, l_comments
           FROM eam_asset_failure_codes
          WHERE failure_id = l_eam_failure_codes_tbl(i).failure_id;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
           FND_MESSAGE.SET_NAME ('EAM', 'EAM_INVALID_FAILURE');
           FND_MESSAGE.SET_TOKEN(  token     => 'SOURCE_ID'
                                 , value     => l_eam_failure_codes_tbl(i).failure_id
                                );
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
       END;

      ELSE

         BEGIN
          SELECT failure_id , failure_code, cause_code, resolution_code, comments
            INTO l_eam_failure_codes_tbl(i).failure_id, l_failure_code, l_cause_code, l_resolution_code, l_comments
            FROM eam_asset_failure_codes
           WHERE failure_entry_id = l_eam_failure_codes_tbl(i).failure_entry_id;
         EXCEPTION
          WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME ('EAM', 'EAM_INVALID_FAILURE_ENTRY_ID');
	    FND_MSG_PUB.Add;
	    RAISE FND_API.G_EXC_ERROR;
         END;

         IF l_eam_failure_codes_tbl(i).failure_id <> l_eam_failure_entry_record.failure_id
         THEN
            FND_MESSAGE.SET_NAME ('EAM', 'EAM_CHILD_NOT_SYNC');
	    FND_MSG_PUB.Add;
	    RAISE FND_API.G_EXC_ERROR;
         END IF;

      END IF;

      IF l_eam_failure_codes_tbl(i).failure_code = FND_API.G_MISS_CHAR THEN
         l_eam_failure_codes_tbl(i).failure_code := NULL;
      ELSIF l_eam_failure_codes_tbl(i).failure_code IS NULL THEN
         l_eam_failure_codes_tbl(i).failure_code := l_failure_code;
      END IF;

      IF l_eam_failure_codes_tbl(i).cause_code = FND_API.G_MISS_CHAR THEN
         l_eam_failure_codes_tbl(i).cause_code := NULL;
      ELSIF l_eam_failure_codes_tbl(i).cause_code IS NULL THEN
         l_eam_failure_codes_tbl(i).cause_code := l_cause_code;
      END IF;

      IF l_eam_failure_codes_tbl(i).resolution_code = FND_API.G_MISS_CHAR THEN
         l_eam_failure_codes_tbl(i).resolution_code := NULL;
      ELSIF l_eam_failure_codes_tbl(i).resolution_code IS NULL THEN
         l_eam_failure_codes_tbl(i).resolution_code := l_resolution_code;
      END IF;

      IF l_eam_failure_codes_tbl(i).comments = FND_API.G_MISS_CHAR THEN
         l_eam_failure_codes_tbl(i).comments := NULL;
      ELSIF l_eam_failure_codes_tbl(i).comments IS NULL THEN
         l_eam_failure_codes_tbl(i).comments := l_comments;
      END IF;

    ELSIF l_eam_failure_codes_tbl(i).transaction_type = EAM_Process_Failure_Entry_PUB.G_FE_CREATE THEN

      l_eam_failure_codes_tbl(i).failure_id := l_eam_failure_entry_record.failure_id;

    END IF;

  END LOOP;

  /* Client Side Validation
   * For the Completed Work Orders, Will do the validation
   * after calling the API. Since the Master Data has to
   * be validated against the child data.
   */
  IF l_eam_failure_entry_record.source_type = 1
  THEN

    BEGIN
      SELECT wdj.date_completed, nvl(edw.failure_code_required, 'N')
        INTO l_date_completed  , l_failure_code_required
        FROM wip_discrete_jobs wdj, eam_work_order_details edw
       WHERE wdj.wip_entity_id = edw.wip_entity_id
         AND wdj.wip_entity_id = l_eam_failure_entry_record.source_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME ('EAM', 'EAM_INVALID_WIP_ENTITY_ID');
        FND_MESSAGE.SET_TOKEN(  token     => 'SOURCE_ID'
                              , value     => l_eam_failure_entry_record.source_name
                              );
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    END;

    /********************************
    Following Validations for Complete Work Order are as per the 11510 design.
    ********************************/
    l_failure_date := l_eam_failure_entry_record.failure_date;
    IF l_date_completed IS NOT NULL THEN
       /* Completed Work Order */
       IF l_eam_failure_codes_tbl.count = 1
       THEN
         l_failure_code    := l_eam_failure_codes_tbl(1).failure_code;
         l_cause_code      := l_eam_failure_codes_tbl(1).cause_code;
         l_resolution_code := l_eam_failure_codes_tbl(1).resolution_code;
         l_comments        := l_eam_failure_codes_tbl(1).comments;
       ELSE
         BEGIN
           SELECT failure_code  , cause_code  , resolution_code  , comments
             INTO l_failure_code, l_cause_code, l_resolution_code, l_comments
             FROM eam_asset_failure_codes
            WHERE failure_id = l_eam_failure_entry_record.failure_id;
         EXCEPTION
           WHEN NO_DATA_FOUND THEN
             FND_MESSAGE.SET_NAME ('EAM', 'EAM_ENTER_FAILURE_INFO');
             FND_MSG_PUB.Add;
             RAISE FND_API.G_EXC_ERROR;
         END;
       END IF;

       IF l_failure_code_required = 'Y'
       THEN
         IF NOT( l_failure_date       IS NOT NULL
                AND l_failure_code    IS NOT NULL
                AND l_cause_code      IS NOT NULL
                AND l_resolution_code IS NOT NULL
               )
         THEN
           FND_MESSAGE.SET_NAME ('EAM', 'EAM_ENTER_FAILURE_INFO');
	   FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
         END IF;
       ELSE

         IF l_comments IS NOT NULL THEN
            IF (   l_failure_date    IS NULL
                OR l_failure_code    IS NULL
                OR l_cause_code      IS NULL
                OR l_resolution_code IS NULL
               )
            THEN
              FND_MESSAGE.SET_NAME ('EAM', 'EAM_ENTER_FAILURE_INFO');
	      FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
            END IF;
         ELSE
           IF NOT ( (  l_failure_date       IS NOT NULL
                      AND l_failure_code    IS NOT NULL
                      AND l_cause_code      IS NOT NULL
                      AND l_resolution_code IS NOT NULL
                    )
                    OR
                    (  l_failure_date       IS NULL
                      AND l_failure_code    IS NULL
                      AND l_cause_code      IS NULL
                      AND l_resolution_code IS NULL
                    )
                  )
           THEN
              FND_MESSAGE.SET_NAME ('EAM', 'EAM_ENTER_FAILURE_INFO');
	      FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
           END IF;
         END IF;

       END IF;
    ELSE /* Completed Date is null */
       IF l_failure_date IS NULL THEN
         IF ( l_eam_failure_codes_tbl.count = 1
              AND l_eam_failure_codes_tbl(1).comments IS NOT NULL
            )
         THEN
           FND_MESSAGE.SET_NAME ('EAM', 'EAM_ENTER_FAILURE_INFO');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
         ELSIF l_eam_failure_codes_tbl.count = 0
         THEN
           BEGIN
             SELECT comments
               INTO l_comments
               FROM eam_asset_failure_codes
              WHERE failure_id = l_eam_failure_entry_record.failure_id;
             IF l_comments IS NOT NULL THEN
               FND_MESSAGE.SET_NAME ('EAM', 'EAM_ENTER_FAILURE_INFO');
               FND_MSG_PUB.Add;
               RAISE FND_API.G_EXC_ERROR;
             END IF;
           EXCEPTION
            WHEN NO_DATA_FOUND THEN
            NULL;
           END;
         END IF;

       END IF;
    END IF;
  END IF;

  EAM_Process_Failure_Entry_PVT.Process_Failure_Entry
  (
      p_api_version                => p_api_version
    , p_init_msg_list              => P_init_msg_list
    , p_commit                     => p_commit
    , p_eam_failure_entry_record   => l_eam_failure_entry_record
    , p_eam_failure_codes_tbl      => l_eam_failure_codes_tbl
    , x_return_status              => x_return_status
    , x_msg_count                  => l_out_msg_count
    , x_msg_data                   => l_out_msg_count
    , x_eam_failure_entry_record   => l_out_eam_failure_entry_record
    , x_eam_failure_codes_tbl      => l_out_eam_failure_codes_tbl
  );

  IF nvl(x_return_status,'Q') <> 'S' THEN
     rollback to Process_Failure_Entry_PUB;
     x_return_status := FND_API.G_RET_STS_ERROR;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  x_eam_failure_entry_record := l_out_eam_failure_entry_record;
  x_eam_failure_codes_tbl    := l_out_eam_failure_codes_tbl;

  IF FND_API.to_Boolean( p_commit ) THEN
     COMMIT;
  END IF;

EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO Process_Failure_Entry_PUB;
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get
    	  (
    	     p_count => x_msg_count     	,
             p_data  => x_msg_data
    	  );
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO Process_Failure_Entry_PUB;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get
    	  (
    	    p_count => x_msg_count,
            p_data  => x_msg_data
    	  );
     WHEN OTHERS THEN
	ROLLBACK TO Process_Failure_Entry_PUB;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
           FND_MSG_PUB.Add_Exc_Msg
    	    (
    	      G_PKG_NAME,
    	      l_api_name
	    );
	END IF;
	FND_MSG_PUB.Count_And_Get
    	 (
    	  p_count => x_msg_count,
          p_data  => x_msg_data
    	 );
END;


END EAM_Process_Failure_Entry_PUB;

/
