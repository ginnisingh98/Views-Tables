--------------------------------------------------------
--  DDL for Package Body AHL_PC_NODE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PC_NODE_PUB" AS
/* $Header: AHLPPCNB.pls 115.7 2003/10/20 19:36:20 sikumar noship $ */

	-------------------
	-- PROCESS_NODES --
	-------------------
--G_DEBUG VARCHAR2(1):=FND_PROFILE.VALUE('AHL_API_FILE_DEBUG_ON');
  G_DEBUG                VARCHAR2(1)   := AHL_DEBUG_PUB.is_log_enabled;

	PROCEDURE PROCESS_NODES (
		p_api_version         IN            NUMBER,
		p_init_msg_list       IN            VARCHAR2  := FND_API.G_TRUE,
		p_commit              IN            VARCHAR2  := FND_API.G_FALSE,
		p_validation_level    IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
		p_module_type         IN            VARCHAR2  := NULL,
    		p_x_nodes_tbl         IN OUT NOCOPY AHL_PC_NODE_PUB.PC_NODE_TBL,
		x_return_status       OUT    NOCOPY       VARCHAR2,
		x_msg_count           OUT    NOCOPY       NUMBER,
		x_msg_data            OUT    NOCOPY       VARCHAR2
	) IS

	l_api_name	CONSTANT	VARCHAR2(30)	:= 'PROCESS_NODES';
	l_api_version	CONSTANT	NUMBER		:= 1.0;
	l_return_status			VARCHAR2(1);

	BEGIN
		-- Standard start of API savepoint
  		SAVEPOINT PROCESS_NODE_PUB;

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

		IF (p_x_nodes_tbl.COUNT > 0)
		THEN
			FOR i IN p_x_nodes_tbl.FIRST..p_x_nodes_tbl.LAST
			LOOP
				IF (p_x_nodes_tbl(i).operation_flag <> G_DML_DELETE)
				THEN
					p_x_nodes_tbl(i).name := TRIM(p_x_nodes_tbl(i).name);
					p_x_nodes_tbl(i).description := TRIM(p_x_nodes_tbl(i).description);

					-- Node name is mandatory
					IF (p_x_nodes_tbl(i).name IS NULL)
					THEN
						FND_MESSAGE.Set_Name('AHL','AHL_PC_NODE_NAME_REQD');
						FND_MSG_PUB.ADD;
						RAISE FND_API.G_EXC_ERROR;
					END IF;

					-- Node child count is default 0
					IF (p_x_nodes_tbl(i).child_count IS NULL)
					THEN
						p_x_nodes_tbl(i).child_count := 0;
					END IF;

					IF (p_x_nodes_tbl(i).pc_node_id IS NULL)
					THEN
						p_x_nodes_tbl(i).object_version_number := 1;
					END IF;
				END IF;

				-- Call PVT APIs
				IF (p_x_nodes_tbl(i).operation_flag = G_DML_CREATE)
				THEN
					IF G_DEBUG='Y' THEN
		  				AHL_DEBUG_PUB.debug('PCN -- PUB -- Calling CREATE_NODE for Name='||p_x_nodes_tbl(i).name);
              				END IF;

					AHL_PC_NODE_PVT.CREATE_NODE(
						p_api_version           => l_api_version,
						p_init_msg_list		=> FND_API.G_FALSE,
						p_commit		=> FND_API.G_FALSE,
						p_validation_level 	=> p_validation_level,
                              			p_x_node_rec		=> p_x_nodes_tbl(i),
						x_return_status         => x_return_status,
						x_msg_count             => x_msg_count,
						x_msg_data              => x_msg_data
					);
				ELSIF (p_x_nodes_tbl(i).operation_flag = G_DML_UPDATE)
				THEN
					IF G_DEBUG='Y' THEN
		  				AHL_DEBUG_PUB.debug('PCN -- PUB -- Calling UPDATE_NODE for ID='||p_x_nodes_tbl(i).pc_node_id);
              				END IF;

					AHL_PC_NODE_PVT.UPDATE_NODE(
						p_api_version           => l_api_version,
						p_init_msg_list		=> FND_API.G_FALSE,
						p_commit		=> FND_API.G_FALSE,
						p_validation_level 	=> p_validation_level,
                              			p_x_node_rec		=> p_x_nodes_tbl(i),
						x_return_status         => x_return_status,
						x_msg_count             => x_msg_count,
						x_msg_data              => x_msg_data
					);
				ELSIF (p_x_nodes_tbl(i).operation_flag = G_DML_DELETE)
				THEN
					IF G_DEBUG='Y' THEN
		  				AHL_DEBUG_PUB.debug('PCN -- PUB -- Calling DELETE_NODE for ID='||p_x_nodes_tbl(i).pc_node_id);
              				END IF;

					AHL_PC_NODE_PVT.DELETE_NODES(
						p_api_version           => l_api_version,
						p_init_msg_list		=> FND_API.G_FALSE,
						p_commit		=> FND_API.G_FALSE,
						p_validation_level 	=> p_validation_level,
                              			p_x_node_rec		=> p_x_nodes_tbl(i),
						x_return_status         => x_return_status,
						x_msg_count             => x_msg_count,
						x_msg_data              => x_msg_data
					);
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
	   		Rollback to PROCESS_NODE_PUB;
	   		FND_MSG_PUB.count_and_get( p_count => x_msg_count,
				      		   p_data  => x_msg_data,
				       		   p_encoded => fnd_api.g_false );

	 	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	   		Rollback to PROCESS_NODE_PUB;
	   		FND_MSG_PUB.count_and_get( p_count => x_msg_count,
				      		   p_data  => x_msg_data,
				      		   p_encoded => fnd_api.g_false );

	 	WHEN OTHERS THEN
	    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	    		Rollback to PROCESS_NODE_PUB;
	    		IF FND_MSG_PUB.check_msg_level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	    		THEN
	       			fnd_msg_pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
				       			 p_procedure_name => 'PROCESS_NODES',
				       			 p_error_text     => SUBSTR(SQLERRM,1,240) );
	    		END IF;
	    		FND_MSG_PUB.count_and_get( p_count => x_msg_count,
				        	   p_data  => x_msg_data,
				       	  	   p_encoded => fnd_api.g_false );

	END PROCESS_NODES;

END AHL_PC_NODE_PUB;

/
