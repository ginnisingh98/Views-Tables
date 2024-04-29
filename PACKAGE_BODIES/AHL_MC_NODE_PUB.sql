--------------------------------------------------------
--  DDL for Package Body AHL_MC_NODE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_MC_NODE_PUB" AS
/* $Header: AHLPNODB.pls 120.3 2005/08/09 10:53:26 priyan noship $ */

---------------------
-- Spec Procedures --
---------------------
PROCEDURE Process_Node
(
	p_api_version		IN 		NUMBER,
	p_init_msg_list       	IN 		VARCHAR2	:= FND_API.G_FALSE,
	p_commit              	IN 		VARCHAR2 	:= FND_API.G_FALSE,
	p_validation_level    	IN 		NUMBER 		:= FND_API.G_VALID_LEVEL_FULL,
	p_module_type		IN		VARCHAR2	:= 'JSP',
	x_return_status       	OUT 	NOCOPY  VARCHAR2,
	x_msg_count           	OUT 	NOCOPY  NUMBER,
	x_msg_data            	OUT 	NOCOPY  VARCHAR2,
	p_x_node_rec 	    	IN OUT 	NOCOPY 	AHL_MC_Node_PVT.Node_Rec_Type,
	p_x_counter_rules_tbl  	IN OUT 	NOCOPY 	AHL_MC_Node_PVT.Counter_Rules_Tbl_Type,
	p_x_subconfig_tbl     	IN OUT 	NOCOPY 	AHL_MC_Node_PVT.SubConfig_Tbl_Type
)
IS
	-- Define validation cursors
	CURSOR get_item_group_id
	(
		p_ig_name in VARCHAR2
	)
	IS
		SELECT 	item_group_id
		FROM 	ahl_item_groups_b
		WHERE 	upper(name) = upper (p_ig_name) AND
			source_item_group_id IS NULL;

	-- Added Version Number Senthil.
	CURSOR get_subconfig_id
	(
		p_name in VARCHAR2,
		p_version_number NUMBER
	)
	IS
		SELECT 	mc_header_id
		FROM	ahl_mc_headers_b
		WHERE 	upper(name) = upper (p_name)
		  AND   version_number = p_version_number;

	-- Declare local variables
	l_api_name	CONSTANT	VARCHAR2(30)	:= 'Process_Node';
	l_api_version	CONSTANT	NUMBER		:= 1.0;
	l_return_status			VARCHAR2(1);
	l_msg_count         		NUMBER;
	l_msg_data          		VARCHAR2(2000);
	l_temp_num			NUMBER;

	l_ret_val			BOOLEAN;

BEGIN

	-- Standard start of API savepoint
	SAVEPOINT Process_Node_SP;

	-- Standard call to check for call compatibility
	IF NOT FND_API.compatible_api_call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE
	IF FND_API.TO_BOOLEAN(p_init_msg_list)
	THEN
		FND_MSG_PUB.Initialize;
	END IF;

	-- Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- API body starts here
	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||'.begin',
			'At the start of PLSQL procedure'
		);
	END IF;

	IF (p_module_type = 'JSP' AND p_x_node_rec.operation_flag <> G_DML_DELETE)
	THEN
		-- Validate and Convert node position reference meaning to code
		p_x_node_rec.position_ref_meaning := RTRIM(p_x_node_rec.position_ref_meaning);

		-- This field is represented in UI with an LOV, hence need to check for validity of the meaning only
		IF (p_x_node_rec.position_ref_meaning IS NULL)
		THEN
			-- This is a mandatory field, hence throw error
			FND_MESSAGE.Set_Name('AHL','AHL_MC_POSREF_NULL');
			FND_MSG_PUB.ADD;
			IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.message
				(
					fnd_log.level_exception,
					'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
					false
				);
			END IF;
		ELSE
			AHL_UTIL_MC_PKG.Convert_To_LookupCode
			(
				'AHL_POSITION_REFERENCE',
				p_x_node_rec.position_ref_meaning,
				p_x_node_rec.position_ref_code,
				l_ret_val
			);

			IF NOT (l_ret_val)
			THEN
				FND_MESSAGE.Set_Name('AHL', 'AHL_MC_POSREF_INVALID');
				FND_MESSAGE.Set_Token('POSREF', p_x_node_rec.position_ref_meaning);
				FND_MSG_PUB.ADD;
				IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
				THEN
					fnd_log.message
					(
						fnd_log.level_exception,
						'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
						false
					);
				END IF;
			END IF;
		END IF;

		--priyan MEL-CDL
		---- Validate and Convert node ata meaning to code
			p_x_node_rec.ata_meaning := RTRIM(p_x_node_rec.ata_meaning);

		---- This field is represented in UI with an LOV, hence need to check for validity of the meaning only
		IF (p_x_node_rec.ata_meaning IS NOT NULL AND p_x_node_rec.ata_meaning <> FND_API.G_MISS_CHAR)
		THEN
			AHL_UTIL_MC_PKG.Convert_To_LookupCode
			(
				'AHL_ATA_CODE',
				p_x_node_rec.ata_meaning,
				p_x_node_rec.ata_code,
				l_ret_val
			);

			IF NOT (l_ret_val)
			THEN
			 	FND_MESSAGE.Set_Name('AHL', 'AHL_MC_ATASEQ_INVALID');
				FND_MESSAGE.Set_Token('ATAMEANING', p_x_node_rec.ata_meaning);
				FND_MSG_PUB.ADD;
				IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
				THEN
					fnd_log.message
					(
						fnd_log.level_exception,
						'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
						false
					);
				END IF;
			END IF;
		ELSE
			-- Not a mandatory field, hence ensure no ID is passed to PVT if there is no name
			p_x_node_rec.ata_code := null;
		END IF;

		/*(p_x_node_rec.ata_code IS NOT NULL AND p_x_node_rec.ata_code <> FND_API.G_MISS_CHAR AND NOT (AHL_UTIL_MC_PKG.Validate_Lookup_Code('AHL_ATA_CODE', p_x_node_rec.ata_code)))
		THEN
			FND_MESSAGE.Set_Name('AHL', 'AHL_MC_ATASEQ_INVALID');
			FND_MESSAGE.Set_Token('ATA', p_x_node_rec.ata_meaning);
			FND_MESSAGE.Set_Token('CODE', p_x_node_rec.ata_code);
			FND_MSG_PUB.ADD;
			IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.message
				(
					fnd_log.level_exception,
					'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
					false
				);
			END IF; */



		-- Validate node position necessity code
		-- This field is represented in UI with a dropdown, hence need to check for validity of the code only
		IF (p_x_node_rec.position_necessity_code IS NULL)
		THEN
			-- This is a mandatory field, hence throw error
			FND_MESSAGE.Set_Name('AHL','AHL_MC_NECESSITY_NULL');
			FND_MSG_PUB.ADD;
			IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.message
				(
					fnd_log.level_exception,
					'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
					false
				);
			END IF;
		ELSIF NOT (AHL_UTIL_MC_PKG.Validate_Lookup_Code('AHL_POSITION_NECESSITY', p_x_node_rec.position_necessity_code))
		THEN
			FND_MESSAGE.Set_Name('AHL', 'AHL_MC_NECESSITY_INVALID');
			FND_MESSAGE.Set_Token('POSREF', p_x_node_rec.position_ref_meaning);
			FND_MESSAGE.Set_Token('CODE', p_x_node_rec.position_necessity_code);
			FND_MSG_PUB.ADD;
			IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.message
				(
					fnd_log.level_exception,
					'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
					false
				);
			END IF;
		END IF;

		-- Validate and Convert node item group name to id
		p_x_node_rec.item_group_name := RTRIM(p_x_node_rec.item_group_name);

		-- This field is represented in UI with an LOV, hence need to check for validity of the name only
		-- This is not a mandatory field
		IF (p_x_node_rec.item_group_name IS NOT NULL)
		THEN
			OPEN get_item_group_id (p_x_node_rec.item_group_name);
			FETCH get_item_group_id INTO p_x_node_rec.item_group_id;
			IF (get_item_group_id%NOTFOUND)
			THEN
				FND_MESSAGE.Set_Name('AHL', 'AHL_MC_ITEMGRP_INVALID');
				FND_MESSAGE.Set_Token('ITEM_GRP', p_x_node_rec.item_group_name);
				FND_MSG_PUB.ADD;
				IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
				THEN
					fnd_log.message
					(
						fnd_log.level_exception,
						'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
						false
					);
				END IF;
			END IF;
			CLOSE get_item_group_id;
		ELSE
			-- Not a mandatory field, hence ensure no ID is passed to PVT if there is no name
			p_x_node_rec.item_group_id := null;
		END IF;

		-- Validate and Covert subconfig header name to id
		IF (p_x_subconfig_tbl.COUNT > 0)
		THEN
			FOR i in p_x_subconfig_tbl.FIRST..p_x_subconfig_tbl.LAST
			LOOP
				IF (p_x_subconfig_tbl(i).operation_flag <> G_DML_DELETE)
				THEN
					p_x_subconfig_tbl(i).name := RTRIM(p_x_subconfig_tbl(i).name);

					-- This field is represented in UI with an LOV, hence need to check for validity of the name only
					IF (p_x_subconfig_tbl(i).name IS NOT NULL)
					THEN
						OPEN get_subconfig_id (p_x_subconfig_tbl(i).name,
						                       p_x_subconfig_tbl(i).version_number);
						FETCH get_subconfig_id INTO l_temp_num;
						IF (get_subconfig_id%NOTFOUND)
						THEN
							FND_MESSAGE.Set_Name('AHL', 'AHL_MC_MC_INVALID');
							FND_MESSAGE.Set_Token('MC_NAME', p_x_subconfig_tbl(i).name);
							FND_MSG_PUB.ADD;
							IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
							THEN
								fnd_log.message
								(
									fnd_log.level_exception,
									'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
									false
								);
							END IF;
						ELSE
							p_x_subconfig_tbl(i).mc_header_id := l_temp_num;
						END IF;
						CLOSE get_subconfig_id;
					ELSE
						FND_MESSAGE.Set_Name('AHL', 'AHL_MC_SUBMC_NULL');
						FND_MSG_PUB.ADD;
						IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
						THEN
							fnd_log.message
							(
								fnd_log.level_exception,
								'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
								false
							);
						END IF;
					END IF;
				END IF;
			END LOOP;
		END IF;

		-- Validate counter rule code
		IF (p_x_counter_rules_tbl.COUNT > 0)
		THEN
			FOR i in p_x_counter_rules_tbl.FIRST..p_x_counter_rules_tbl.LAST
			LOOP
				IF (p_x_counter_rules_tbl(i).operation_flag <> G_DML_DELETE)
				THEN
					-- This field is represented in UI with a dropdown, hence need to check for validity of the code only
					IF (p_x_counter_rules_tbl(i).rule_code IS NULL)
					THEN
						-- This is a mandatory field, hence throw error
						FND_MESSAGE.Set_Name('AHL', 'AHL_MC_RULE_NULL');
						FND_MSG_PUB.ADD;
						IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
						THEN
							fnd_log.message
							(
								fnd_log.level_exception,
								'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
								false
							);
						END IF;
					ELSIF NOT (AHL_UTIL_MC_PKG.Validate_Lookup_Code('AHL_COUNTER_RULE_TYPE', p_x_counter_rules_tbl(i).rule_code))
					THEN
						FND_MESSAGE.Set_Name('AHL', 'AHL_MC_RULE_INVALID');
						FND_MESSAGE.Set_Token('RULE', p_x_counter_rules_tbl(i).rule_meaning);
						FND_MSG_PUB.ADD;
						IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
						THEN
							fnd_log.message
							(
								fnd_log.level_exception,
								'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
								false
							);
						END IF;
					END IF;
				END IF;
			END LOOP;
		END IF;

		-- Check Error Message stack.
		x_msg_count := FND_MSG_PUB.count_msg;
		IF ( x_msg_count > 0 ) THEN
			RAISE FND_API.G_EXC_ERROR;
		END IF;
	END IF;

	-- Call PVT APIs accordingly
	IF (p_x_node_rec.operation_flag = G_DML_CREATE)
	THEN
		AHL_MC_Node_PVT.Create_Node
		(
			p_api_version		=> 1.0,
			p_init_msg_list		=> FND_API.G_FALSE,
			p_commit		=> FND_API.G_FALSE,
			p_validation_level	=> FND_API.G_VALID_LEVEL_FULL,
			x_return_status		=> l_return_status,
			x_msg_count		=> l_msg_count,
			x_msg_data		=> l_msg_data,
			p_x_node_rec		=> p_x_node_rec,
			p_x_counter_rules_tbl	=> p_x_counter_rules_tbl,
			p_x_subconfig_tbl	=> p_x_subconfig_tbl
		);
	ELSIF (p_x_node_rec.operation_flag = G_DML_DELETE)
	THEN
		AHL_MC_Node_PVT.Delete_Node
		(
			p_api_version 		=> 1.0,
			p_init_msg_list 	=> FND_API.G_FALSE,
			p_commit 		=> FND_API.G_FALSE,
			p_validation_level 	=> FND_API.G_VALID_LEVEL_FULL,
			x_return_status 	=> l_return_status,
			x_msg_count 		=> l_msg_count,
			x_msg_data 		=> l_msg_data,
			p_node_id		=> p_x_node_rec.relationship_id,
			p_object_ver_num	=> p_x_node_rec.object_version_number
		);
	ELSE
		AHL_MC_Node_PVT.Modify_Node
		(
			p_api_version		=> 1.0,
			p_init_msg_list		=> FND_API.G_FALSE,
			p_commit		=> FND_API.G_FALSE,
			p_validation_level	=> FND_API.G_VALID_LEVEL_FULL,
			x_return_status		=> l_return_status,
			x_msg_count		=> l_msg_count,
			x_msg_data		=> l_msg_data,
			p_x_node_rec		=> p_x_node_rec,
			p_x_counter_rules_tbl	=> p_x_counter_rules_tbl,
			p_x_subconfig_tbl	=> p_x_subconfig_tbl
		);
  	END IF;

	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||'.end',
			'At the end of PLSQL procedure'
		);
	END IF;
	-- API body ends here

	-- Check Error Message stack.
	x_msg_count := FND_MSG_PUB.count_msg;

	--priyan MEL_CDL
	IF ( x_msg_count > 0  and l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

  	-- Standard check for p_commit
	IF FND_API.TO_BOOLEAN (p_commit)
	THEN
		COMMIT WORK;
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
		x_return_status := FND_API.G_RET_STS_ERROR;
		Rollback to Process_Node_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to Process_Node_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to Process_Node_SP;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.add_exc_msg
			(
				p_pkg_name		=> G_PKG_NAME,
				p_procedure_name 	=> 'Process_Node',
				p_error_text     	=> SUBSTR(SQLERRM,1,240)
			);
		END IF;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

END Process_Node;



PROCEDURE Delete_Nodes
(
	p_api_version		IN 		NUMBER,
	p_init_msg_list       	IN 		VARCHAR2	:= FND_API.G_FALSE,
	p_commit              	IN 		VARCHAR2 	:= FND_API.G_FALSE,
	p_validation_level    	IN 		NUMBER 		:= FND_API.G_VALID_LEVEL_FULL,
	x_return_status       	OUT 	NOCOPY  VARCHAR2,
	x_msg_count           	OUT 	NOCOPY  NUMBER,
	x_msg_data            	OUT 	NOCOPY  VARCHAR2,
	p_nodes_tbl		IN		AHL_MC_Node_PVT.Node_Tbl_Type
)
IS

	-- 1.	Define local variables
	l_api_name	CONSTANT	VARCHAR2(30)	:= 'Delete_Nodes';
	l_api_version	CONSTANT	NUMBER		:= 1.0;
	l_return_status			VARCHAR2(1);
	l_msg_count         		NUMBER;
	l_msg_data          		VARCHAR2(2000);

BEGIN

	-- Standard start of API savepoint
	SAVEPOINT Delete_Nodes_SP;

	-- Standard call to check for call compatibility
	IF NOT FND_API.compatible_api_call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE
	IF FND_API.TO_BOOLEAN(p_init_msg_list)
	THEN
		FND_MSG_PUB.Initialize;
	END IF;

	-- Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- API body starts here
	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||'.begin',
			'At the start of PLSQL procedure'
		);
	END IF;

	IF (p_nodes_tbl.COUNT > 0)
	THEN
		FOR i IN p_nodes_tbl.FIRST..p_nodes_tbl.LAST
		LOOP
			AHL_MC_Node_PVT.Delete_Node
			(
				p_api_version 		=> 1.0,
				p_init_msg_list 	=> FND_API.G_FALSE,
				p_commit		=> FND_API.G_FALSE,
				p_validation_level	=> FND_API.G_VALID_LEVEL_FULL,
				x_return_status		=> l_return_status,
				x_msg_count		=> l_msg_count,
				x_msg_data		=> l_msg_data,
				p_node_id		=> p_nodes_tbl(i).relationship_id,
				p_object_ver_num	=> p_nodes_tbl(i).object_version_number
			);

			IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.string
				(
					fnd_log.level_statement,
					'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
					'Deleted Node ['||p_nodes_tbl(i).relationship_id||']'
				);
			END IF;

			-- Check Error Message stack.
			x_msg_count := FND_MSG_PUB.count_msg;
			IF x_msg_count > 0 THEN
				RAISE FND_API.G_EXC_ERROR;
			END IF;
		END LOOP;
	END IF;

	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||'.end',
			'At the end of PLSQL procedure'
		);
	END IF;
	-- API body ends here

	-- Check Error Message stack.
	x_msg_count := FND_MSG_PUB.count_msg;
	IF x_msg_count > 0 THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

  	-- Standard check for p_commit
	IF FND_API.TO_BOOLEAN (p_commit)
	THEN
		COMMIT WORK;
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
		x_return_status := FND_API.G_RET_STS_ERROR;
		Rollback to Delete_Nodes_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to Delete_Nodes_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to Delete_Nodes_SP;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.add_exc_msg
			(
				p_pkg_name		=> G_PKG_NAME,
				p_procedure_name 	=> 'Delete_Nodes',
				p_error_text     	=> SUBSTR(SQLERRM,1,240)
			);
		END IF;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

END Delete_Nodes;

End AHL_MC_Node_PUB;

/
