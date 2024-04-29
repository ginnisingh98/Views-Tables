--------------------------------------------------------
--  DDL for Package Body AHL_UMP_UNPLANNED_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_UMP_UNPLANNED_PVT" AS
/* $Header: AHLVUUNB.pls 120.5.12010000.2 2008/12/27 03:24:31 sracha ship $ */

-----------
-- Common variables
-----------
l_dummy_varchar	    VARCHAR2(30);

G_USER_ID 	    CONSTANT NUMBER := TO_NUMBER(FND_GLOBAL.USER_ID);
G_LOGIN_ID 	    CONSTANT NUMBER := TO_NUMBER(FND_GLOBAL.LOGIN_ID);

-- FND Logging Constants
G_DEBUG_LEVEL       CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_DEBUG_PROC        CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
G_DEBUG_STMT        CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
G_DEBUG_UEXP        CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
G_DEBUG_ERROR       CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;

-------------------
-- Spec Procedure Signatures --
-------------------

PROCEDURE Create_Unit_Effectivity
(
	p_api_version		IN 		NUMBER,
	p_init_msg_list         IN              VARCHAR2  := FND_API.G_TRUE,
	p_commit                IN              VARCHAR2  := FND_API.G_FALSE,
	p_validation_level      IN              NUMBER    := FND_API.G_VALID_LEVEL_FULL,
	x_return_status       	OUT 	NOCOPY  VARCHAR2,
	x_msg_count           	OUT 	NOCOPY  NUMBER,
	x_msg_data            	OUT 	NOCOPY  VARCHAR2,
	p_mr_header_id	        IN	        NUMBER,
	p_instance_id 	        IN	        NUMBER,
	x_orig_ue_id	        OUT	NOCOPY  NUMBER
)
IS


        -- Cursors

        -- cursor to fetch all applicable MRs for the instance number
	Cursor Get_all_appl_mrs ( c_mr_header_id NUMBER , c_instance_id NUMBER )
	IS
	SELECT CSI_ITEM_INSTANCE_ID, MR_HEADER_ID, DESCENDENT_COUNT
	from
	AHL_APPLICABLE_MRS
	where
	MR_HEADER_ID = c_mr_header_id and
	CSI_ITEM_INSTANCE_ID =   c_instance_id;

        -- cursor to fetch all applicable MRs and their related MRs for the instance number
        Cursor Get_Appl_Mr_Relns
        IS
        SELECT CSI_ITEM_INSTANCE_ID, MR_HEADER_ID, RELATED_CSI_ITEM_INSTANCE_ID, RELATED_MR_HEADER_ID, UE_ID
        FROM AHL_APPLICABLE_MR_RELNS
        ORDER BY TREE_DEPTH_LEVEL;

        Cursor get_rel_mr_ue_id( c_mr_header_id NUMBER,c_item_instance_id NUMBER)
        IS
        SELECT UE_ID  FROM AHL_APPLICABLE_MR_RELNS
        where RELATED_MR_HEADER_ID = c_mr_header_id
        and RELATED_CSI_ITEM_INSTANCE_ID = c_item_instance_id; --amsriniv

        -- cursor to validate the Mr Header Id
	CURSOR check_mr_exists (c_mr_header_id NUMBER)
	IS
	SELECT 'X'
	FROM
	AHL_MR_HEADERS_APP_V
	where
	MR_HEADER_ID = c_mr_header_id;

        -- cursor to validate the Instance Id of the Item
	CURSOR check_instance_exists (c_instance_id NUMBER)
	IS
	SELECT 'X'
	FROM
	CSI_ITEM_INSTANCES
	where
	INSTANCE_ID = c_instance_id;

	-- check for group MR.
	CURSOR is_grp_mr_check(p_mr_header_id IN NUMBER) IS
	SELECT 'x'
	FROM DUAL
	WHERE EXISTS (SELECT r.related_mr_header_id
	              FROM ahl_mr_relationships r
                      WHERE r.mr_header_id = p_mr_header_id
	                AND EXISTS (SELECT m.mr_header_id
	                            FROM ahl_mr_headers_b M -- perf bug 6266738
	                            WHERE m.mr_header_id = r.related_mr_header_id
	                              AND (m.version_number) in (SELECT max(M1.version_number)
	                                                         from ahl_mr_headers_b M1
	                                                         where M1.title = m.title -- perf bug 6266738
	                                                           AND m1.mr_status_code = 'COMPLETE'
	                                                           AND SYSDATE between trunc(m1.effective_from)
                                                                   and trunc(nvl(m1.effective_to,SYSDATE+1))
	                                                         )
	                           )
                     );


	-- Declare local variables

	l_api_name	CONSTANT	VARCHAR2(30)	:= 'Create_Unit_Effectivity';
	l_api_version	CONSTANT	NUMBER		:= 1.0;
	l_return_status			VARCHAR2(1);
	l_msg_count         		NUMBER;
	l_msg_data          		VARCHAR2(2000);
	L_DEBUG_MODULE	CONSTANT	VARCHAR2(100)	:= 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;
        l_all_appl_mrs Get_all_appl_mrs%rowtype;
        l_appl_mrs_relns Get_Appl_Mr_Relns %rowtype;

	-- Procedure Returned Variables

	l_appln_code      VARCHAR2(30) ;
	l_rowid ROWID;
	l_unit_effectivity_id NUMBER;
        l_ue_relationship_id NUMBER;

        l_mr_applicable_flag  BOOLEAN;
        l_applicable_mr_tbl   AHL_FMP_PVT.applicable_mr_tbl_type;
        k                     NUMBER;


BEGIN

	-- Log API entry point
	IF (G_DEBUG_PROC >= G_DEBUG_LEVEL)THEN
		fnd_log.string
		(
			G_DEBUG_PROC,
			'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
			'At the start of PLSQL procedure'
		);
	END IF;

	SAVEPOINT sp_create_unit_effectivity;

	-- Initialize return status to success initially
	x_return_status:=FND_API.G_RET_STS_SUCCESS;

	IF NOT FND_API.compatible_api_call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Call the procedure AHL_UTIL_PKG.Get_Appln_Usage
	AHL_UTIL_PKG.Get_Appln_Usage
	(
	     x_appln_code    => l_appln_code,
	     x_return_status => l_return_status
	);

	l_msg_count := FND_MSG_PUB.COUNT_MSG;
	IF (l_msg_count > 0 OR l_return_status <> FND_API.G_RET_STS_SUCCESS)
	THEN
	      RAISE FND_API.G_EXC_ERROR;
	END IF;

	IF (G_DEBUG_STMT >= G_DEBUG_LEVEL      ) THEN
	    FND_LOG.STRING(G_DEBUG_STMT, L_DEBUG_MODULE , ' After Calling AHL_UTIL_PKG.Get_Appln_Usage successfully' );
	    FND_LOG.STRING(G_DEBUG_STMT, L_DEBUG_MODULE , ' l_appln_code: ' ||  l_appln_code);
	    FND_LOG.STRING(G_DEBUG_STMT, L_DEBUG_MODULE , ' l_return_status: ' || l_return_status);
	END IF;


        IF (p_init_msg_list = FND_API.G_TRUE) THEN
           FND_MSG_PUB.Initialize;
        END IF;

	-- API body starts here
	-- If (p_mr_header_id is null or p_instance_id is null), then display error
	IF
	(
		p_mr_header_id IS NULL OR p_mr_header_id = FND_API.G_MISS_NUM OR
		p_instance_id IS NULL OR p_instance_id = FND_API.G_MISS_NUM
	)
	THEN
		FND_MESSAGE.SET_NAME('AHL', 'AHL_COM_INVALID_PROCEDURE_CALL');
		FND_MESSAGE.SET_TOKEN('PROCEDURE', l_api_name);
		FND_MSG_PUB.ADD;
		IF (G_DEBUG_ERROR >= G_DEBUG_LEVEL      )THEN
			fnd_log.string
			(
				G_DEBUG_ERROR,
				'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
				'Invalid Procedure Call'
			);
		END IF;
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	-- validate the mr header id
	OPEN check_mr_exists (p_mr_header_id);
	FETCH check_mr_exists INTO l_dummy_varchar;
	IF (check_mr_exists%NOTFOUND)
	THEN
		FND_MESSAGE.SET_NAME('AHL', 'AHL_UA_MR_NOT_FOUND');
		FND_MSG_PUB.ADD;
		CLOSE check_mr_exists;
		IF (G_DEBUG_ERROR >= G_DEBUG_LEVEL      )THEN
			fnd_log.string
			(
				G_DEBUG_ERROR,
				'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
				'MR is not found'
			);
		END IF;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
	CLOSE check_mr_exists;

	-- validate the instance id
	OPEN check_instance_exists (p_instance_id);
	FETCH check_instance_exists INTO l_dummy_varchar;
	IF (check_instance_exists%NOTFOUND)
	THEN
		FND_MESSAGE.SET_NAME('AHL', 'AHL_UMP_INVALID_CSI_INSTANCE');  --message reused
		FND_MSG_PUB.ADD;
		CLOSE check_instance_exists;
		IF (G_DEBUG_ERROR >= G_DEBUG_LEVEL      )THEN
			fnd_log.string
			(
				G_DEBUG_ERROR,
				'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
				'Instance Number is invalid'
			);
		END IF;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
	CLOSE check_instance_exists;

	--Set the return status to an error and raise an error message if the application code returned is not AHL
	IF (l_appln_code <> 'AHL') THEN
	     x_return_status := FND_API.G_RET_STS_ERROR;
	     FND_MESSAGE.set_name('AHL', 'AHL_COM_APPL_USG_MODE_INVALID');
	     FND_MSG_PUB.add;
		IF (G_DEBUG_ERROR >= G_DEBUG_LEVEL)THEN
			fnd_log.string
			(
				G_DEBUG_ERROR,
				'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
				'Application Usage Mode is not defined or is invalid'
			);
		END IF;
	     RAISE FND_API.G_EXC_ERROR;
	END IF;

        OPEN is_grp_mr_check(p_mr_header_id);
        FETCH is_grp_mr_check INTO l_dummy_varchar;
        IF (is_grp_mr_check%FOUND) THEN

           CLOSE is_grp_mr_check;

           -- call AHL_FMP_COMMON_PVT.Populate_Appl_MRs to populate the AHL_APPLICABLE_MRS temporary table
           -- call the API with input p_include_doNotImplmt = 'Y', otherwise descendent_count is not populated.

           AHL_FMP_COMMON_PVT.Populate_Appl_MRs (
         	p_csi_ii_id => p_instance_id,
        	p_include_doNotImplmt => 'Y',
        	x_return_status => x_return_status,
        	x_msg_count => x_msg_count,
        	x_msg_data => x_msg_data);

          x_msg_count := FND_MSG_PUB.count_msg;
          IF ( x_msg_count > 0 OR x_return_status <> FND_API.G_RET_STS_SUCCESS )
	  THEN
            RAISE FND_API.G_EXC_ERROR;
	  END IF;

          IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
            FND_LOG.STRING(G_DEBUG_STMT, L_DEBUG_MODULE , 'AFTER Calling AHL_FMP_COMMON_PVT.Populate_Appl_MRs to populate AHL_APPLICABLE_MRS');
          END IF;

          --loop not need as only one record.The Top Group MR is returned.
          OPEN Get_all_appl_mrs ( p_mr_header_id , p_instance_id );
          FETCH Get_all_appl_mrs INTO l_all_appl_mrs;
  	  IF (Get_all_appl_mrs%NOTFOUND)
 	  THEN
		FND_MESSAGE.SET_NAME('AHL', 'AHL_UA_UE_NOT_FOUND');
		FND_MSG_PUB.ADD;
		CLOSE Get_all_appl_mrs;
		RAISE FND_API.G_EXC_ERROR;
	  END IF;

          CLOSE Get_all_appl_mrs;

        ELSE
          CLOSE is_grp_mr_check;

          -- call only for instance and mr combination.
          -- Check MR - Instance Applicability by calling FMP API
          AHL_FMP_PVT.GET_APPLICABLE_MRS(p_api_version       => 1.0,
                                         x_return_status     => x_return_status,
                                         x_msg_count         => x_msg_count,
                                         x_msg_data          => x_msg_data,
                                         p_item_instance_id  => p_instance_id,
                                         p_mr_header_id      => p_mr_header_id,
                                         p_components_flag   => 'N',  -- get applicability for only this instance.
                                         x_applicable_mr_tbl => l_applicable_mr_tbl);

          x_msg_count := FND_MSG_PUB.count_msg;
	  IF ( x_msg_count > 0 OR x_return_status <> FND_API.G_RET_STS_SUCCESS )
	  THEN
		RAISE FND_API.G_EXC_ERROR;
	  END IF;

          IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
             FND_LOG.STRING(G_DEBUG_STMT, L_DEBUG_MODULE , 'AFTER Calling AHL_FMP_PVT.GET_APPLICABLE_MRS to validate MR-Instance applicability' );
          END IF;

          l_mr_applicable_flag := false;
          IF (l_applicable_mr_tbl.COUNT > 0) THEN
            FOR j IN l_applicable_mr_tbl.FIRST .. l_applicable_mr_tbl.LAST LOOP
              IF (l_applicable_mr_tbl(j).MR_HEADER_ID = p_mr_header_id AND
                  l_applicable_mr_tbl(j).ITEM_INSTANCE_ID = p_instance_id) THEN
                      l_mr_applicable_flag := true;
                      k := j;
                      EXIT;
              END IF;  -- Applicable
            END LOOP;  -- All Applicable MRs
          END IF;  -- Table Count > 0

          IF (l_mr_applicable_flag = false) THEN
            FND_MESSAGE.SET_NAME('AHL', 'AHL_UA_UE_NOT_FOUND');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
          END IF;  -- MR applicable

          l_all_appl_mrs.csi_item_instance_id := p_instance_id;
          l_all_appl_mrs.mr_header_id := p_mr_header_id;
          l_all_appl_mrs.descendent_count := l_applicable_mr_tbl(k).descendent_count;

        END IF; -- is_grp_mr_check%FOUND

       	SELECT AHL_UNIT_EFFECTIVITIES_B_S.NEXTVAL INTO l_unit_effectivity_id FROM DUAL;

	AHL_UNIT_EFFECTIVITIES_PKG.INSERT_ROW (
	   X_ROWID                => l_rowid,
	   X_UNIT_EFFECTIVITY_ID  => l_unit_effectivity_id,
	   X_EARLIEST_DUE_DATE    => NULL ,
	   X_LATEST_DUE_DATE      => NULL ,
	   X_ACCOMPLISHED_DATE    => NULL ,
	   X_SERVICE_LINE_ID      => NULL ,
	   X_PROGRAM_MR_HEADER_ID => NULL,
	   X_CANCEL_REASON_CODE   => NULL ,
	   X_ATTRIBUTE_CATEGORY   => NULL ,
	   X_ATTRIBUTE1           => NULL ,
	   X_ATTRIBUTE2           => NULL ,
	   X_ATTRIBUTE3           => NULL ,
	   X_ATTRIBUTE4           => NULL ,
	   X_ATTRIBUTE5           => NULL ,
	   X_ATTRIBUTE6           => NULL ,
	   X_ATTRIBUTE7           => NULL ,
	   X_ATTRIBUTE8           => NULL ,
	   X_ATTRIBUTE9           => NULL ,
	   X_ATTRIBUTE10          => NULL ,
	   X_ATTRIBUTE11          => NULL ,
	   X_ATTRIBUTE12          => NULL ,
	   X_ATTRIBUTE13          => NULL ,
	   X_ATTRIBUTE14          => NULL ,
	   X_ATTRIBUTE15          => NULL ,
	   X_OBJECT_VERSION_NUMBER => 1 ,
	   --X_CSI_ITEM_INSTANCE_ID  => l_all_appl_mrs.CSI_ITEM_INSTANCE_ID,
	   --X_MR_HEADER_ID          => l_all_appl_mrs.MR_HEADER_ID,
	   X_CSI_ITEM_INSTANCE_ID  => p_instance_id,
	   X_MR_HEADER_ID          => p_mr_header_id,
	   X_MR_EFFECTIVITY_ID     => NULL ,
	   X_MR_INTERVAL_ID        => NULL ,
	   X_STATUS_CODE           => NULL ,
	   X_DUE_DATE              => NULL ,
	   X_DUE_COUNTER_VALUE     => NULL ,
	   X_FORECAST_SEQUENCE     => NULL ,
	   X_REPETITIVE_MR_FLAG    => NULL ,
	   X_TOLERANCE_FLAG        => NULL ,
	   X_MESSAGE_CODE          => NULL ,
	   X_DATE_RUN              => NULL ,
	   X_PRECEDING_UE_ID       => NULL ,
	   X_SET_DUE_DATE          => NULL ,
	   X_REMARKS               => NULL ,
	   X_DEFER_FROM_UE_ID      => NULL ,
	   X_CS_INCIDENT_ID        => NULL ,
	   X_QA_COLLECTION_ID      => NULL ,
	   X_ORIG_DEFERRAL_UE_ID   => NULL ,
	   X_APPLICATION_USG_CODE  => l_appln_code,
	   X_OBJECT_TYPE           => 'MR',
	   X_COUNTER_ID            => NULL ,
	   X_MANUALLY_PLANNED_FLAG => 'Y',
           X_LOG_SERIES_CODE       => NULL,
           X_LOG_SERIES_NUMBER     => NULL,
           X_FLIGHT_NUMBER         => NULL,
           X_MEL_CDL_TYPE_CODE     => NULL,
           X_POSITION_PATH_ID      => NULL,
           X_ATA_CODE              => NULL,
           X_UNIT_CONFIG_HEADER_ID  => NULL,
	   X_CREATION_DATE         => sysdate,
	   X_CREATED_BY            => G_USER_ID,
	   X_LAST_UPDATE_DATE      => sysdate,
	   X_LAST_UPDATED_BY       => G_USER_ID,
	   X_LAST_UPDATE_LOGIN     => G_LOGIN_ID );

        x_orig_ue_id :=  l_unit_effectivity_id;

        -- Initialize temporary table.

        -- Process_Group_MRs() is not used as this takes all Group MRs in AHL_APPLICABLE_MRS and calls
        -- process_Group_MR_Instance() on all of them.

        -- for the particular record of interest in AHL_APPLICABLE_MRS, process_Group_MR_Instance() should
        -- get the whole tree
        IF( l_all_appl_mrs.DESCENDENT_COUNT  > 0  )
        THEN

		-- call the API AHL_UMP_UTIL_PKG.process_Group_MR_Instance for the relevant MR in AHL_APPLICABLE_MRS
		AHL_UMP_UTIL_PKG.process_Group_MR_Instance(
		p_top_mr_id            => l_all_appl_mrs.MR_HEADER_ID ,
		p_top_item_instance_id => l_all_appl_mrs.CSI_ITEM_INSTANCE_ID ,
		p_init_temp_table      => 'Y');  -- To clean up temp table first

		x_msg_count := FND_MSG_PUB.count_msg;
		IF x_msg_count > 0
		THEN
		    RAISE FND_API.G_EXC_ERROR;
		END IF;

		IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
		   FND_LOG.STRING(G_DEBUG_STMT, L_DEBUG_MODULE , ' AFTER Calling AHL_UMP_UTIL_PKG.process_Group_MR_Instance to populate AHL_APPLICABLE_MR_RELNS' );
		END IF;


		-- create Unit Effectivities from Related MRs also

		IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
		     FND_LOG.STRING(G_DEBUG_STMT, L_DEBUG_MODULE , ' BEFORE Calling AHL_UNIT_EFFECTIVITIES_PKG.Insert_Row for Related MRs from AHL_APPLICABLE_MR_RELNS' );
		END IF;

		FOR l_appl_mrs_relns IN Get_Appl_Mr_Relns
		LOOP

			SELECT AHL_UNIT_EFFECTIVITIES_B_S.NEXTVAL INTO l_unit_effectivity_id FROM DUAL;

			AHL_UNIT_EFFECTIVITIES_PKG.INSERT_ROW (
				   X_ROWID                => l_rowid,
				   X_UNIT_EFFECTIVITY_ID  => l_unit_effectivity_id,
				   X_EARLIEST_DUE_DATE    => NULL ,
				   X_LATEST_DUE_DATE      => NULL ,
				   X_ACCOMPLISHED_DATE    => NULL ,
				   X_SERVICE_LINE_ID      => NULL ,
				   X_PROGRAM_MR_HEADER_ID => NULL,
				   X_CANCEL_REASON_CODE   => NULL ,
				   X_ATTRIBUTE_CATEGORY   => NULL ,
				   X_ATTRIBUTE1           => NULL ,
				   X_ATTRIBUTE2           => NULL ,
				   X_ATTRIBUTE3           => NULL ,
				   X_ATTRIBUTE4           => NULL ,
				   X_ATTRIBUTE5           => NULL ,
				   X_ATTRIBUTE6           => NULL ,
				   X_ATTRIBUTE7           => NULL ,
				   X_ATTRIBUTE8           => NULL ,
				   X_ATTRIBUTE9           => NULL ,
				   X_ATTRIBUTE10          => NULL ,
				   X_ATTRIBUTE11          => NULL ,
				   X_ATTRIBUTE12          => NULL ,
				   X_ATTRIBUTE13          => NULL ,
				   X_ATTRIBUTE14          => NULL ,
				   X_ATTRIBUTE15          => NULL ,
				   X_OBJECT_VERSION_NUMBER => 1 ,
				   --X_CSI_ITEM_INSTANCE_ID  => l_appl_mrs_relns.CSI_ITEM_INSTANCE_ID,
				   X_CSI_ITEM_INSTANCE_ID  => l_appl_mrs_relns.RELATED_CSI_ITEM_INSTANCE_ID,
				   X_MR_HEADER_ID          => l_appl_mrs_relns.RELATED_MR_HEADER_ID,
				   X_MR_EFFECTIVITY_ID     => NULL ,
				   X_MR_INTERVAL_ID        => NULL ,
				   X_STATUS_CODE           => NULL ,
				   X_DUE_DATE              => NULL ,
				   X_DUE_COUNTER_VALUE     => NULL ,
				   X_FORECAST_SEQUENCE     => NULL ,
				   X_REPETITIVE_MR_FLAG    => NULL ,
				   X_TOLERANCE_FLAG        => NULL ,
				   X_MESSAGE_CODE          => NULL ,
				   X_DATE_RUN              => NULL ,
				   X_PRECEDING_UE_ID       => NULL ,
				   X_SET_DUE_DATE          => NULL ,
				   X_REMARKS               => NULL ,
				   X_DEFER_FROM_UE_ID      => NULL ,
				   X_CS_INCIDENT_ID        => NULL ,
				   X_QA_COLLECTION_ID      => NULL ,
				   X_ORIG_DEFERRAL_UE_ID   => NULL ,
				   X_APPLICATION_USG_CODE  => l_appln_code,
				   X_OBJECT_TYPE           => 'MR',
				   X_COUNTER_ID            => NULL ,
				   X_MANUALLY_PLANNED_FLAG => 'Y',
                                   X_LOG_SERIES_CODE       => NULL,
                                   X_LOG_SERIES_NUMBER     => NULL,
                                   X_FLIGHT_NUMBER         => NULL,
                                   X_MEL_CDL_TYPE_CODE     => NULL,
                                   X_POSITION_PATH_ID      => NULL,
                                   X_ATA_CODE              => NULL,
                                   X_UNIT_CONFIG_HEADER_ID  => NULL,
				   X_CREATION_DATE         => sysdate,
				   X_CREATED_BY            => G_USER_ID,
				   X_LAST_UPDATE_DATE      => sysdate,
				   X_LAST_UPDATED_BY       => G_USER_ID,
				   X_LAST_UPDATE_LOGIN     => G_LOGIN_ID );
			-- additional column added to the table AHL_UNIT_EFFECTIVITIES

			-- update the table AHL_APPLICABLE_MR_RELNS with the new UE_IDs generated in AHL_UNIT_EFFECTIVITIES

			UPDATE AHL_APPLICABLE_MR_RELNS
			SET
			 UE_ID = l_unit_effectivity_id  --MANUALLY_PLANNED = 'Y'
			where CSI_ITEM_INSTANCE_ID = l_appl_mrs_relns.CSI_ITEM_INSTANCE_ID
                        and MR_HEADER_ID = l_appl_mrs_relns.MR_HEADER_ID --amsriniv
			and RELATED_CSI_ITEM_INSTANCE_ID  = l_appl_mrs_relns.RELATED_CSI_ITEM_INSTANCE_ID
			and RELATED_MR_HEADER_ID  = l_appl_mrs_relns.RELATED_MR_HEADER_ID ;

		END LOOP;

		IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
		     FND_LOG.STRING(G_DEBUG_STMT, L_DEBUG_MODULE , ' AFTER Calling AHL_UNIT_EFFECTIVITIES_PKG.Insert_Row for Related MRs from AHL_APPLICABLE_MR_RELNS' );
		END IF;

		-- to update the AHL_UE_RELATIONSHIPS table with the Unit Effectivity Relationships

		FOR l_appl_mrs_relns IN Get_Appl_Mr_Relns
		LOOP

			IF ( l_appl_mrs_relns.MR_HEADER_ID =  p_mr_header_id)
			THEN

			    l_unit_effectivity_id := x_orig_ue_id;

			ELSE

			    OPEN get_rel_mr_ue_id(l_appl_mrs_relns.MR_HEADER_ID,
                                                  l_appl_mrs_relns.CSI_ITEM_INSTANCE_ID); --amsriniv;
			    FETCH get_rel_mr_ue_id into l_unit_effectivity_id;
			    CLOSE get_rel_mr_ue_id;
			END IF;

			SELECT AHL_UE_RELATIONSHIPS_S.NEXTVAL INTO l_ue_relationship_id FROM DUAL;

			AHL_UE_RELATIONSHIPS_PKG.INSERT_ROW
			(
			   X_UE_RELATIONSHIP_ID    => l_ue_relationship_id,
			   X_UE_ID                 => l_unit_effectivity_id,
			   X_RELATED_UE_ID         => l_appl_mrs_relns.ue_id,
			   X_RELATIONSHIP_CODE     => 'PARENT',
			   X_ORIGINATOR_UE_ID      => x_orig_ue_id,
			   X_ATTRIBUTE_CATEGORY    => NULL,
			   X_ATTRIBUTE1            => NULL,
			   X_ATTRIBUTE2            => NULL,
			   X_ATTRIBUTE3            => NULL,
			   X_ATTRIBUTE4            => NULL,
			   X_ATTRIBUTE5            => NULL,
			   X_ATTRIBUTE6            => NULL,
			   X_ATTRIBUTE7            => NULL,
			   X_ATTRIBUTE8            => NULL,
			   X_ATTRIBUTE9            => NULL,
			   X_ATTRIBUTE10           => NULL,
			   X_ATTRIBUTE11           => NULL,
			   X_ATTRIBUTE12           => NULL,
			   X_ATTRIBUTE13           => NULL,
			   X_ATTRIBUTE14           => NULL,
			   X_ATTRIBUTE15           => NULL,
			   X_OBJECT_VERSION_NUMBER => 1,
			   X_LAST_UPDATE_DATE      => sysdate,
			   X_LAST_UPDATED_BY       => G_USER_ID,
			   X_CREATION_DATE         => sysdate,
			   X_CREATED_BY            => G_USER_ID,
			   X_LAST_UPDATE_LOGIN     => G_LOGIN_ID
			);
		END LOOP;

		IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
		     FND_LOG.STRING(G_DEBUG_STMT, L_DEBUG_MODULE , ' AFTER Calling AHL_UE_RELATIONSHIPS_PKG.INSERT_ROW for Related MRs from AHL_APPLICABLE_MR_RELNS' );
		END IF;
        END IF;



	-- API body ends here

	-- Log API exit point
	IF (G_DEBUG_PROC >= G_DEBUG_LEVEL)
	THEN
		fnd_log.string
		(
			G_DEBUG_PROC,
			L_DEBUG_MODULE||'.end',
			'At the end of PLSQL procedure'
		);
	END IF;

	-- Check Error Message stack.
	x_msg_count := FND_MSG_PUB.count_msg;
	IF x_msg_count > 0
	THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;


EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
                Rollback to sp_create_unit_effectivity;
		x_return_status := FND_API.G_RET_STS_ERROR;
		IF (G_DEBUG_ERROR >= G_DEBUG_LEVEL)THEN
			fnd_log.string
			(
				G_DEBUG_ERROR,
				'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
				'Expected error'
			);
		END IF;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                Rollback to sp_create_unit_effectivity;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF (G_DEBUG_ERROR >= G_DEBUG_LEVEL)THEN
			fnd_log.string
			(
				G_DEBUG_ERROR,
				'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
				'Unexpected error'
			);
		END IF;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN OTHERS THEN
                Rollback to sp_create_unit_effectivity;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.add_exc_msg
			(
				p_pkg_name		=> G_PKG_NAME,
				p_procedure_name 	=> 'Create_Unit_Effectivity',
				p_error_text     	=> SUBSTR(SQLERRM,1,240)
			);
		END IF;
		IF (G_DEBUG_ERROR >= G_DEBUG_LEVEL)THEN
			fnd_log.string
			(
				G_DEBUG_ERROR,
				'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
				'Other errors'
			);
		END IF;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
	);
END Create_Unit_Effectivity;


PROCEDURE Delete_Unit_Effectivity
(
	p_api_version		IN 		NUMBER,
	p_init_msg_list         IN              VARCHAR2  := FND_API.G_TRUE,
	p_commit                IN              VARCHAR2  := FND_API.G_FALSE,
	p_validation_level      IN              NUMBER    := FND_API.G_VALID_LEVEL_FULL,
	x_return_status       	OUT 	NOCOPY  VARCHAR2,
	x_msg_count           	OUT 	NOCOPY  NUMBER,
	x_msg_data            	OUT 	NOCOPY  VARCHAR2,
	p_unit_effectivity_id	        IN	NUMBER
)
IS

        -- Cursor definitions

        -- given the ue id get the originator ue id.
        Cursor GetOrigUeId ( c_ue_id NUMBER)
        IS
        SELECT ORIGINATOR_UE_ID
        FROM
        AHL_UE_RELATIONSHIPS
        WHERE
        RELATED_UE_ID = c_ue_id ;

        --given the Top Ue Id, get the whole tree

        Cursor GetAllUeIds ( c_ue_id NUMBER)
        IS
        SELECT UE_RELATIONSHIP_ID , UE_ID , RELATED_UE_ID , ORIGINATOR_UE_ID
        FROM
        AHL_UE_RELATIONSHIPS
	START WITH UE_ID = c_ue_id
	CONNECT BY UE_ID = PRIOR RELATED_UE_ID order by RELATED_UE_ID;

        -- get the status code of the UE before deleting it.
        Cursor GetStatusCode(c_ue_id NUMBER)
        IS
        SELECT STATUS_CODE,OBJECT_TYPE FROM AHL_UNIT_EFFECTIVITIES_APP_V
        WHERE UNIT_EFFECTIVITY_ID = c_ue_id
        and MANUALLY_PLANNED_FLAG = 'Y';

	-- Declare local variables
	l_api_name	CONSTANT	VARCHAR2(30)	:= 'Delete_Unit_Effectivity';
	l_api_version	CONSTANT	NUMBER		:= 1.0;

	L_DEBUG_MODULE	CONSTANT	VARCHAR2(100)	:= 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

        l_originator_ue_id     NUMBER;
        l_appln_code      VARCHAR2(30) ;
	l_msg_count            NUMBER;
        l_get_orig_ue          NUMBER;
        l_all_ue_ids           GetAllUeIds%rowtype;
        l_get_status_code      VARCHAR2(30);

	l_return_status	       VARCHAR2(1);
	l_object_type          VARCHAR2(30);

BEGIN

	SAVEPOINT sp_delete_unit_effectivity;
	-- Standard call to check for call compatibility
	IF NOT FND_API.compatible_api_call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Log API entry point
	IF (G_DEBUG_PROC >= G_DEBUG_LEVEL)
	THEN
		fnd_log.string
		(
			G_DEBUG_PROC,
			L_DEBUG_MODULE||'.begin',
			'At the start of PLSQL procedure'
		);
	END IF;

	-- API body starts here
	-- Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	--Call the procedure AHL_UTIL_PKG.Get_Appln_Usage
	AHL_UTIL_PKG.Get_Appln_Usage
	(
	     x_appln_code    => l_appln_code,
	     x_return_status => l_return_status
	);

	l_msg_count := FND_MSG_PUB.COUNT_MSG;
	IF (l_msg_count > 0)
	THEN
	      RAISE FND_API.G_EXC_ERROR;
	END IF;

        -- if the UE Id passed is a middle node then get the Top Node UE Id.
        OPEN GetOrigUeId ( p_unit_effectivity_id );
        		FETCH GetOrigUeId INTO l_get_orig_ue;
        		IF (GetOrigUeId%NOTFOUND)
        		THEN
          		 l_originator_ue_id := p_unit_effectivity_id;
          		 -- if not found then must be the top node itself or doesnt have any children.
        		ELSE
          		 l_originator_ue_id := l_get_orig_ue;

        		END IF;
        CLOSE GetOrigUeId;

        IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
     	     FND_LOG.STRING(G_DEBUG_STMT, L_DEBUG_MODULE , ' AFTER finding the originator UE id '|| l_originator_ue_id );
        END IF;


        -- if the ue id to be deleted is not found
       IF (l_originator_ue_id IS NULL)
          THEN
            FND_MESSAGE.SET_NAME('AHL', 'AHL_UA_UE_NOT_FOUND');
			FND_MSG_PUB.ADD;
			RAISE FND_API.G_EXC_ERROR;
        ELSE
           -- validate the existance of the Unit Effectivity Id
          OPEN  GetStatusCode (p_unit_effectivity_id);
          FETCH GetStatusCode INTO l_get_status_code,l_object_type;
		  IF (GetStatusCode%NOTFOUND)	THEN
			FND_MESSAGE.SET_NAME('AHL', 'AHL_UA_UE_NOT_FOUND');
			FND_MSG_PUB.ADD;
			CLOSE GetStatusCode;
			RAISE FND_API.G_EXC_ERROR;
		  ELSIF ( l_get_status_code IS NOT NULL AND  l_get_status_code NOT IN ('EXCEPTION')
                  AND l_object_type = 'SR')THEN
			FND_MESSAGE.SET_NAME('AHL', 'AHL_UA_UE_CANNOT_DELETE');
			FND_MSG_PUB.ADD;
			IF (G_DEBUG_ERROR >= G_DEBUG_LEVEL)THEN
				fnd_log.string
				(
					G_DEBUG_ERROR,
					'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
					'Cannot delete UE'
												);
			END IF;
		  END IF;
		  CLOSE GetStatusCode;
		END IF;

        FOR l_all_ue_ids IN GetAllUeIds(l_originator_ue_id)
        LOOP

										OPEN GetStatusCode( l_all_ue_ids.RELATED_UE_ID);
										FETCH GetStatusCode into l_get_status_code,l_object_type ;
										IF (GetStatusCode%NOTFOUND)
										THEN
										  FND_MESSAGE.SET_NAME('AHL', 'AHL_UMP_STATUS_NULL');  -- mesg reused
										  FND_MSG_PUB.ADD;
										  CLOSE GetStatusCode;
										  RAISE FND_API.G_EXC_ERROR;
										END IF;
										CLOSE GetStatusCode;
										IF ( l_get_status_code IS NULL OR l_get_status_code IN ('EXCEPTION') )
										THEN
													-- delete the corresponding relationships records too.
													AHL_UE_RELATIONSHIPS_PKG.DELETE_ROW( l_all_ue_ids.UE_RELATIONSHIP_ID);
													-- deletes all related ue ids of the originator ue id of the ue id passed for deletion.
													AHL_UNIT_EFFECTIVITIES_PKG.DELETE_ROW( l_all_ue_ids.RELATED_UE_ID);

									ELSE
												FND_MESSAGE.SET_NAME('AHL', 'AHL_UA_UE_CANNOT_DELETE');
												FND_MSG_PUB.ADD;
												IF (G_DEBUG_ERROR >= G_DEBUG_LEVEL)THEN
												fnd_log.string
												(
												G_DEBUG_ERROR,
													'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
												'Cannot delete UE'
												);
									END IF;
									RAISE FND_API.G_EXC_ERROR;

									END IF;

	END LOOP;

        IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
     	     FND_LOG.STRING(G_DEBUG_STMT, L_DEBUG_MODULE , ' AFTER deleting all related UE s and their relationships');
        END IF;


       -- deletes the top node UE id

    AHL_UNIT_EFFECTIVITIES_PKG.DELETE_ROW(l_originator_ue_id);

	IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
	     FND_LOG.STRING(G_DEBUG_STMT, L_DEBUG_MODULE , ' AFTER deleting the originator UE ');
        END IF;
	-- API body ends here

	-- Log API exit point
	IF (G_DEBUG_PROC >= G_DEBUG_LEVEL)
	THEN
		fnd_log.string
		(
			G_DEBUG_PROC,
			L_DEBUG_MODULE||'.end',
			'At the end of PLSQL procedure'
		);
	END IF;

	-- Check Error Message stack.
	x_msg_count := FND_MSG_PUB.count_msg;
	IF x_msg_count > 0
	THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	-- Standard call to get message count and if count is 1, get message info
	FND_MSG_PUB.count_and_get
	(
		p_count 	=> x_msg_count,
		p_data  	=> x_msg_data,
		p_encoded 	=> FND_API.G_FALSE
	);

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
                Rollback to sp_delete_unit_effectivity;
		x_return_status := FND_API.G_RET_STS_ERROR;
		IF (G_DEBUG_ERROR >= G_DEBUG_LEVEL)THEN
			fnd_log.string
			(
				G_DEBUG_ERROR,
				'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
				'Expected error'
			);
		END IF;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		Rollback to sp_delete_unit_effectivity;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF (G_DEBUG_ERROR >= G_DEBUG_LEVEL)THEN
			fnd_log.string
			(
				G_DEBUG_ERROR,
				'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
				'Unexpected error'
			);
		END IF;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN OTHERS THEN
		Rollback to sp_delete_unit_effectivity;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.add_exc_msg
			(
				p_pkg_name		=> G_PKG_NAME,
				p_procedure_name 	=> 'Delete_Unit_Effectivity',
				p_error_text     	=> SUBSTR(SQLERRM,1,240)
			);
		END IF;
		IF (G_DEBUG_ERROR >= G_DEBUG_LEVEL)THEN
			fnd_log.string
			(
				G_DEBUG_ERROR,
				'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
				'Other errors'
			);
		END IF;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
	);
End Delete_Unit_Effectivity;

End AHL_UMP_UNPLANNED_PVT;

/
