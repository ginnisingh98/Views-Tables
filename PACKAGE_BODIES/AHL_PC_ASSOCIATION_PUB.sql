--------------------------------------------------------
--  DDL for Package Body AHL_PC_ASSOCIATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PC_ASSOCIATION_PUB" AS
/* $Header: AHLPPCAB.pls 120.1 2006/02/20 02:49:04 sathapli noship $ */

	G_DML_CREATE	CONSTANT	VARCHAR2(1)	:= 'C';
	G_DML_UPDATE	CONSTANT	VARCHAR2(1)	:= 'U';
	G_DML_DELETE	CONSTANT	VARCHAR2(1)	:= 'D';
	G_DML_COPY	CONSTANT	VARCHAR2(1)	:= 'X';
	G_DML_ASSIGN	CONSTANT	VARCHAR2(1)	:= 'A';
	G_DML_LINK	CONSTANT	VARCHAR2(1)	:= 'L';

	G_UNIT		CONSTANT	VARCHAR2(1)	:= 'U';
	G_PART		CONSTANT	VARCHAR2(1)	:= 'I';

	--G_DEBUG VARCHAR2(1):=FND_PROFILE.VALUE('AHL_API_FILE_DEBUG_ON');
      G_DEBUG                VARCHAR2(1)   := AHL_DEBUG_PUB.is_log_enabled;

	-----------------------------
	-- CONVERT UNIT NAME TO ID --
	-----------------------------
	PROCEDURE CONVERT_UNIT_NAME_TO_ID ( p_x_assos_rec IN OUT NOCOPY AHL_PC_ASSOCIATION_PUB.PC_ASSOS_REC )
	IS

	l_unit_id NUMBER;

	CURSOR get_id_for_name (p_pc_unit_name IN VARCHAR2)
	IS
                -- SATHAPLI :: Change for fix of Bug# 4913757 --
                /*
		select unit_config_header_id
		FROM ahl_unit_header_details_v
		where name = p_pc_unit_name;
                */
                SELECT unit_config_header_id
                FROM   ahl_unit_config_headers
                WHERE  name = p_pc_unit_name;

	BEGIN
		IF (p_x_assos_rec.unit_item_id IS NULL)
		THEN
			OPEN get_id_for_name (p_x_assos_rec.unit_item_name);
			FETCH get_id_for_name INTO l_unit_id;
			IF (get_id_for_name%NOTFOUND)
			THEN
				FND_MESSAGE.Set_Name('AHL','AHL_PC_UNIT_NOT_FOUND');
				FND_MSG_PUB.ADD;
				RAISE FND_API.G_EXC_ERROR;
			ELSE
				p_x_assos_rec.unit_item_id := l_unit_id;
			END IF;
			CLOSE get_id_for_name;
		END IF;

	END CONVERT_UNIT_NAME_TO_ID;

	-----------------------------
	-- CONVERT UNIT NAME TO ID --
	-----------------------------
	PROCEDURE CONVERT_PART_NAME_TO_ID ( p_x_assos_rec IN OUT NOCOPY AHL_PC_ASSOCIATION_PUB.PC_ASSOS_REC )
	IS

	l_part_id NUMBER;

	CURSOR get_id_for_name (p_pc_part_name IN VARCHAR2)
	IS
		select inventory_item_id
		FROM mtl_system_items_kfv
		where concatenated_segments = p_pc_part_name;

	BEGIN
		IF (p_x_assos_rec.unit_item_id IS NULL)
		THEN
			OPEN get_id_for_name (p_x_assos_rec.unit_item_name);
			FETCH get_id_for_name INTO l_part_id;
			IF (get_id_for_name%NOTFOUND)
			THEN
				FND_MESSAGE.Set_Name('AHL','AHL_PC_ITEM_NOT_FOUND');
				FND_MSG_PUB.ADD;
				RAISE FND_API.G_EXC_ERROR;
			ELSE
				p_x_assos_rec.unit_item_id := l_part_id;
			END IF;
			CLOSE get_id_for_name;
		END IF;

	END CONVERT_PART_NAME_TO_ID;

	------------------------
	-- Declare Procedures --
	------------------------
	PROCEDURE PROCESS_ASSOCIATIONS (
		p_api_version         IN            NUMBER,
		p_init_msg_list       IN            VARCHAR2  := FND_API.G_TRUE,
		p_commit              IN            VARCHAR2  := FND_API.G_FALSE,
		p_validation_level    IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
		p_module_type         IN            VARCHAR2  := NULL,
    		p_x_assos_tbl         IN OUT NOCOPY AHL_PC_ASSOCIATION_PUB.PC_ASSOS_TBL,
		x_return_status       OUT  NOCOPY         VARCHAR2,
		x_msg_count           OUT  NOCOPY         NUMBER,
		x_msg_data            OUT  NOCOPY         VARCHAR2
	) IS

	l_api_name			CONSTANT	VARCHAR2(30)	:= 'PROCESS_ASSOCIATIONS';
	l_api_version			CONSTANT	NUMBER		:= 1.0;
	l_return_status			VARCHAR2(1);

	BEGIN
		-- Standard start of API savepoint
  		SAVEPOINT PROCESS_ASSOCIATION_PUB;

  		-- Standard call to check for call compatibility
		IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
		THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

		-- Initialize message list if p_init_msg_list is set to TRUE
		IF FND_API.To_Boolean(p_init_msg_list)
		THEN
			FND_MSG_PUB.Initialize;
		END IF;

		-- Initialize API return status to success
  		x_return_status := FND_API.G_RET_STS_SUCCESS;

		IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.ENABLE_DEBUG;
              	END IF;

		IF (p_x_assos_tbl.COUNT > 0)
		THEN
			FOR i IN p_x_assos_tbl.FIRST..p_x_assos_tbl.LAST
			LOOP
				-- Call PVT APIs
				IF (p_x_assos_tbl(i).operation_flag = G_DML_CREATE OR p_x_assos_tbl(i).operation_flag = G_DML_ASSIGN)
				THEN
					IF (p_x_assos_tbl(i).pc_association_id IS NULL)
					THEN
						p_x_assos_tbl(i).object_version_number := 1;
					END IF;

					p_x_assos_tbl(i).unit_item_name := TRIM(p_x_assos_tbl(i).unit_item_name);

					IF (p_x_assos_tbl(i).association_type_flag = G_UNIT)
					THEN
						IF p_module_type IS NULL OR p_module_type = 'JSP'
						THEN
							p_x_assos_tbl(i).unit_item_id := NULL;
							CONVERT_UNIT_NAME_TO_ID(p_x_assos_tbl(i));
						END IF;

						IF G_DEBUG='Y' THEN
		  				   AHL_DEBUG_PUB.debug('PCA -- PUB -- Calling ATTACH_UNIT for p_x_assos_tbl('||i||').unit_id'||p_x_assos_tbl(i).unit_item_id);
              					END IF;

						AHL_PC_ASSOCIATION_PVT.ATTACH_UNIT
						(
							p_api_version           => l_api_version,
							p_init_msg_list		=> FND_API.G_FALSE,
							p_commit		=> FND_API.G_FALSE,
							p_validation_level 	=> p_validation_level,
							p_x_assos_rec		=> p_x_assos_tbl(i),
							x_return_status         => x_return_status,
							x_msg_count             => x_msg_count,
							x_msg_data              => x_msg_data
						);
					ELSIF (p_x_assos_tbl(i).association_type_flag = G_PART)
					THEN
						IF p_module_type IS NULL OR p_module_type = 'JSP'
						THEN
							p_x_assos_tbl(i).unit_item_id := NULL;
							CONVERT_PART_NAME_TO_ID(p_x_assos_tbl(i));
						END IF;

						IF G_DEBUG='Y' THEN
		  					AHL_DEBUG_PUB.debug('PCA -- PUB -- Calling ATTACH_PART for p_x_assos_tbl('||i||').item_id'||p_x_assos_tbl(i).unit_item_id);
              					END IF;

						AHL_PC_ASSOCIATION_PVT.ATTACH_ITEM
						(
							p_api_version           => l_api_version,
							p_init_msg_list		=> FND_API.G_FALSE,
							p_commit		=> FND_API.G_FALSE,
							p_validation_level 	=> p_validation_level,
							p_x_assos_rec		=> p_x_assos_tbl(i),
							x_return_status         => x_return_status,
							x_msg_count             => x_msg_count,
							x_msg_data              => x_msg_data
						);
					END IF;
				ELSIF (p_x_assos_tbl(i).operation_flag = G_DML_DELETE)
				THEN
					IF (p_x_assos_tbl(i).association_type_flag = G_UNIT)
					THEN
						IF p_module_type IS NULL OR p_module_type = 'JSP'
						THEN
							p_x_assos_tbl(i).unit_item_id := NULL;
							CONVERT_UNIT_NAME_TO_ID(p_x_assos_tbl(i));
						END IF;

						IF G_DEBUG='Y' THEN
		  					AHL_DEBUG_PUB.debug('PCA -- PUB -- Calling DETACH_UNIT for p_x_assos_tbl('||i||').unit_id'||p_x_assos_tbl(i).unit_item_id);
              					END IF;

						AHL_PC_ASSOCIATION_PVT.DETACH_UNIT
						(
							p_api_version           => l_api_version,
							p_init_msg_list		=> FND_API.G_FALSE,
							p_commit		=> FND_API.G_FALSE,
							p_validation_level 	=> p_validation_level,
							p_x_assos_rec		=> p_x_assos_tbl(i),
							x_return_status         => x_return_status,
							x_msg_count             => x_msg_count,
							x_msg_data              => x_msg_data
						);
					ELSIF (p_x_assos_tbl(i).association_type_flag = G_PART)
					THEN
						IF p_module_type IS NULL OR p_module_type = 'JSP'
						THEN
							p_x_assos_tbl(i).unit_item_id := NULL;
							CONVERT_PART_NAME_TO_ID(p_x_assos_tbl(i));
						END IF;

						IF G_DEBUG='Y' THEN
		  					AHL_DEBUG_PUB.debug('PCA -- PUB -- Calling DETACH_PART for p_x_assos_tbl('||i||').item_id'||p_x_assos_tbl(i).unit_item_id);
              					END IF;

						AHL_PC_ASSOCIATION_PVT.DETACH_ITEM
						(
							p_api_version           => l_api_version,
							p_init_msg_list		=> FND_API.G_FALSE,
							p_commit		=> FND_API.G_FALSE,
							p_validation_level 	=> p_validation_level,
							p_x_assos_rec		=> p_x_assos_tbl(i),
							x_return_status         => x_return_status,
							x_msg_count             => x_msg_count,
							x_msg_data              => x_msg_data
						);
					END IF;
				END IF;
			END LOOP;
		END IF;

    		-- Check Error Message stack.
		x_msg_count := FND_MSG_PUB.count_msg;
		IF x_msg_count > 0 THEN
			RAISE FND_API.G_EXC_ERROR;
  		END IF;

		-- Standard check for p_commit
    		IF FND_API.To_Boolean (p_commit)
    		THEN
    			COMMIT WORK;
    		END IF;

		-- Standard call to get message count and if count is 1, get message info
		FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
		      			    p_data  => x_msg_data,
      					    p_encoded => fnd_api.g_false );

	EXCEPTION
		WHEN FND_API.G_EXC_ERROR THEN
	   		x_return_status := FND_API.G_RET_STS_ERROR;
	   		Rollback to PROCESS_ASSOCIATION_PUB;
	   		FND_MSG_PUB.count_and_get( p_count => x_msg_count,
				      		   p_data  => x_msg_data,
				       		   p_encoded => fnd_api.g_false );

	 	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	   		Rollback to PROCESS_ASSOCIATION_PUB;
	   		FND_MSG_PUB.count_and_get( p_count => x_msg_count,
				      		   p_data  => x_msg_data,
				      		   p_encoded => fnd_api.g_false );

	 	WHEN OTHERS THEN
	    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	    		Rollback to PROCESS_ASSOCIATION_PUB;
	    		IF FND_MSG_PUB.check_msg_level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	    		THEN
	       			fnd_msg_pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
				       			 p_procedure_name => 'PROCESS_ASSOCIATIONS',
				       			 p_error_text     => SUBSTR(SQLERRM,1,240) );
	    		END IF;
	    		FND_MSG_PUB.count_and_get( p_count => x_msg_count,
				        	   p_data  => x_msg_data,
				       	  	   p_encoded => fnd_api.g_false );

	END PROCESS_ASSOCIATIONS;

	PROCEDURE PROCESS_DOCUMENT (
		p_api_version         IN            NUMBER,
		p_init_msg_list       IN            VARCHAR2  := FND_API.G_FALSE,
		p_commit              IN            VARCHAR2  := FND_API.G_FALSE,
		p_validation_level    IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
		p_module_type	      IN            VARCHAR2  := NULL,
		p_x_assos_tbl         IN OUT NOCOPY AHL_DI_ASSO_DOC_GEN_PUB.association_tbl,
		x_return_status       OUT    NOCOPY       VARCHAR2,
		x_msg_count           OUT    NOCOPY       NUMBER,
		x_msg_data            OUT    NOCOPY       VARCHAR2
	)
	IS

	l_api_name			CONSTANT	VARCHAR2(30)	:= 'PROCESS_DOCUMENT';
	l_api_version			CONSTANT	NUMBER		:= 1.0;
	l_return_status			VARCHAR2(1);

	BEGIN
		-- Standard start of API savepoint
  		SAVEPOINT PROCESS_DOCUMENT_PUB;

  		-- Standard call to check for call compatibility
		IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
		THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

		-- Initialize message list if p_init_msg_list is set to TRUE
		IF FND_API.To_Boolean(p_init_msg_list)
		THEN
			FND_MSG_PUB.Initialize;
		END IF;

		-- Initialize API return status to success
  		x_return_status := FND_API.G_RET_STS_SUCCESS;

		IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.ENABLE_DEBUG;
              	END IF;

		AHL_PC_ASSOCIATION_PVT.PROCESS_DOCUMENT
		(
			p_api_version           => l_api_version,
			p_init_msg_list		=> FND_API.G_FALSE,
			p_commit		=> FND_API.G_FALSE,
			p_validation_level 	=> p_validation_level,
			p_module_type		=> p_module_type,
			p_x_assos_tbl		=> p_x_assos_tbl,
			x_return_status         => x_return_status,
			x_msg_count             => x_msg_count,
			x_msg_data              => x_msg_data
		);

    		-- Check Error Message stack.
		x_msg_count := FND_MSG_PUB.count_msg;
		IF x_msg_count > 0 THEN
			RAISE FND_API.G_EXC_ERROR;
  		END IF;

		-- Standard check for p_commit
    		IF FND_API.To_Boolean (p_commit)
    		THEN
    			COMMIT WORK;
    		END IF;

		-- Standard call to get message count and if count is 1, get message info
		FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
		      			    p_data  => x_msg_data,
      					    p_encoded => fnd_api.g_false );

	EXCEPTION
		WHEN FND_API.G_EXC_ERROR THEN
			x_return_status := FND_API.G_RET_STS_ERROR;
			Rollback to PROCESS_DOCUMENT_PUB;
			FND_MSG_PUB.count_and_get( p_count => x_msg_count,
						   p_data  => x_msg_data,
						   p_encoded => fnd_api.g_false );

		WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			Rollback to PROCESS_DOCUMENT_PUB;
			FND_MSG_PUB.count_and_get( p_count => x_msg_count,
						   p_data  => x_msg_data,
						   p_encoded => fnd_api.g_false );

		WHEN OTHERS THEN
			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			Rollback to PROCESS_DOCUMENT_PUB;
			IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			THEN
				fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
							 p_procedure_name => 'PROCESS_DOCUMENT',
							 p_error_text     => SUBSTR(SQLERRM, 1, 240));
			END IF;
			FND_MSG_PUB.count_and_get( p_count => x_msg_count,
						   p_data  => x_msg_data,
					   	   p_encoded => fnd_api.g_false );

	END PROCESS_DOCUMENT;

END AHL_PC_ASSOCIATION_PUB;

/
