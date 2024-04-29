--------------------------------------------------------
--  DDL for Package Body AHL_MC_MASTERCONFIG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_MC_MASTERCONFIG_PUB" AS
/* $Header: AHLPMCXB.pls 120.2.12010000.2 2008/11/06 09:58:38 sathapli ship $ */

---------------------
-- Spec Procedures --
---------------------
PROCEDURE Process_Master_Config
(
	p_api_version		IN 		NUMBER,
	p_init_msg_list       	IN 		VARCHAR2	:= FND_API.G_FALSE,
	p_commit              	IN 		VARCHAR2 	:= FND_API.G_FALSE,
	p_validation_level    	IN 		NUMBER 		:= FND_API.G_VALID_LEVEL_FULL,
	p_module_type		IN		VARCHAR2	:= 'JSP',
	x_return_status       	OUT 	NOCOPY  VARCHAR2,
	x_msg_count           	OUT 	NOCOPY  NUMBER,
	x_msg_data            	OUT 	NOCOPY  VARCHAR2,
	p_x_mc_header_rec     	IN OUT 	NOCOPY 	AHL_MC_MasterConfig_PVT.Header_Rec_Type,
	p_x_node_rec          	IN OUT 	NOCOPY 	AHL_MC_Node_PVT.Node_Rec_Type
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

	-- Declare local variables
	l_api_name	CONSTANT	VARCHAR2(30)	:= 'Process_Master_Config';
	l_api_version	CONSTANT	NUMBER		:= 1.0;
	l_return_status			VARCHAR2(1);
	l_msg_count         		NUMBER;
	l_msg_data          		VARCHAR2(2000);

	l_ret_val			BOOLEAN;
	-- Fix for Bug #3523435
	l_lookup_code			VARCHAR2(30);
	l_resolved_id			NUMBER;
	-- Fix for Bug #3523435

BEGIN

	-- Standard start of API savepoint
	SAVEPOINT Process_Master_Config_SP;

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

	-- Fix for Bug #3523435
	-- IF (p_module_type = 'JSP' AND p_x_mc_header_rec.operation_flag <> G_DML_DELETE)
	IF (p_x_mc_header_rec.operation_flag <> G_DML_DELETE)
	THEN
		-- Validate header status code
		-- This field is represented in UI with a dropdown, hence need to check for validity of the code only
		IF (p_x_mc_header_rec.config_status_code IS NULL)
		THEN
			-- This is a mandatory field, hence throw error
			FND_MESSAGE.Set_Name('AHL','AHL_MC_STATUS_NULL');
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
		ELSIF NOT (AHL_UTIL_MC_PKG.Validate_Lookup_Code('AHL_CONFIG_STATUS', p_x_mc_header_rec.config_status_code))
		THEN
			FND_MESSAGE.Set_Name('AHL', 'AHL_MC_STATUS_INVALID');
			FND_MESSAGE.Set_Token('STATUS', p_x_mc_header_rec.config_status_code);
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
				l_lookup_code,
				l_ret_val
			);

			-- Fix for Bug #3523435
			-- If p_module_type <> 'JSP' then lookup code and meaning should match, else resolve on meaning
			-- IF NOT (l_ret_val)
			IF (NOT l_ret_val OR (NOT (p_module_type IS NOT NULL AND p_module_type = 'JSP') AND l_lookup_code <> p_x_node_rec.position_ref_code))
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
			-- Fix for Bug #3523435
			ELSE
				p_x_node_rec.position_ref_code := l_lookup_code;
			-- Fix for Bug #3523435
			END IF;
		END IF;

		-----R12
		---- priyan MEL-CDL
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
			FETCH get_item_group_id INTO l_resolved_id;
			-- Fix for Bug #3523435
			-- If p_module_type <> 'JSP' then id and name should match, else resolve on name
			-- IF (get_item_group_id%NOTFOUND)
			IF (get_item_group_id%NOTFOUND OR (NOT (p_module_type IS NOT NULL AND p_module_type = 'JSP') AND l_resolved_id <> p_x_node_rec.item_group_id))
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
			ELSE
				p_x_node_rec.item_group_id := l_resolved_id;
			END IF;
			CLOSE get_item_group_id;
		ELSE
			-- Not a mandatory field, hence ensure no ID is passed to PVT if there is no name
			p_x_node_rec.item_group_id := null;
		END IF;



      -- SATHAPLI::Enigma code changes, 26-Aug-2008
      -- This field is represented in UI with an LOV, hence need to check for validity of the meaning only
		IF (p_x_mc_header_rec.model_meaning IS NOT NULL AND p_x_mc_header_rec.model_meaning <> FND_API.G_MISS_CHAR)
		THEN
			AHL_UTIL_MC_PKG.Convert_To_LookupCode
			(
				'AHL_ENIGMA_MODEL_CODE',
				p_x_mc_header_rec.model_meaning,
				p_x_mc_header_rec.model_code,
				l_ret_val
			);

			IF NOT (l_ret_val)
			THEN
			 	FND_MESSAGE.Set_Name('AHL', 'AHL_MC_MODEL_INVALID');
				FND_MESSAGE.Set_Token('MODEL_MEANING', p_x_mc_header_rec.model_meaning);
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
			p_x_mc_header_rec.model_code := null;
		END IF;

		-- Check Error Message stack.
		x_msg_count := FND_MSG_PUB.count_msg;
		IF x_msg_count > 0 THEN
			RAISE FND_API.G_EXC_ERROR;
		END IF;
	END IF;

	-- Call PVT APIs accordingly
  	IF (p_x_mc_header_rec.operation_flag = G_DML_CREATE)
  	THEN
  		-- Fix for Bug #3523435
  		-- Invalid version number...
		IF (NVL(p_x_mc_header_rec.version_number, 1) <> 1)
		THEN
			FND_MESSAGE.Set_Name('AHL', 'AHL_MC_INV_VERNUM');
			FND_MESSAGE.Set_Token('MC_NAME', p_x_mc_header_rec.name);
			FND_MSG_PUB.ADD;
		END IF;
  		-- Fix for Bug #3523435

  		AHL_MC_MasterConfig_PVT.Create_Master_Config
		(
			p_api_version 		=> 1.0,
			p_init_msg_list 	=> FND_API.G_FALSE,
			p_commit 		=> FND_API.G_FALSE,
			p_validation_level 	=> FND_API.G_VALID_LEVEL_FULL,
			x_return_status 	=> l_return_status,
			x_msg_count 		=> l_msg_count,
			x_msg_data 		=> l_msg_data,
			p_x_mc_header_rec 	=> p_x_mc_header_rec,
			p_x_node_rec 		=> p_x_node_rec
		);
  	ELSIF (p_x_mc_header_rec.operation_flag = G_DML_DELETE)
  	THEN
  		AHL_MC_MasterConfig_PVT.Delete_Master_Config
		(
			p_api_version 		=> 1.0,
			p_init_msg_list 	=> FND_API.G_FALSE,
			p_commit 		=> FND_API.G_FALSE,
			p_validation_level 	=> FND_API.G_VALID_LEVEL_FULL,
			x_return_status 	=> l_return_status,
			x_msg_count 		=> l_msg_count,
			x_msg_data 		=> l_msg_data,
			p_mc_header_id 		=> p_x_mc_header_rec.mc_header_id,
			p_object_ver_num	=> p_x_mc_header_rec.object_version_number
		);
	-- Fix for Bug #3523435
	-- Invalid operation flag...
	-- ELSE
  	ELSIF (p_x_mc_header_rec.operation_flag = G_DML_UPDATE)
  	THEN

		AHL_MC_MasterConfig_PVT.Modify_Master_Config
		(
			p_api_version 		=> 1.0,
			p_init_msg_list 	=> FND_API.G_FALSE,
			p_commit 		=> FND_API.G_FALSE,
			p_validation_level 	=> FND_API.G_VALID_LEVEL_FULL,
			x_return_status 	=> l_return_status,
			x_msg_count 		=> l_msg_count,
			x_msg_data 		=> l_msg_data,
			p_x_mc_header_rec 	=> p_x_mc_header_rec,
			p_x_node_rec 		=> p_x_node_rec
		);

	-- Fix for Bug #3523435
	ELSE
		FND_MESSAGE.Set_Name('AHL', 'AHL_COM_INVALID_DML');
		FND_MESSAGE.Set_Token('FIELD', p_x_mc_header_rec.operation_flag);
		IF (p_x_mc_header_rec.name IS NOT NULL)
		THEN
			FND_MESSAGE.Set_Token('RECORD', p_x_mc_header_rec.name);
		ELSE
			FND_MESSAGE.Set_Token('RECORD', p_x_mc_header_rec.mc_header_id);
		END IF;
		FND_MSG_PUB.ADD;
		RAISE FND_API.G_EXC_ERROR;
  	-- Fix for Bug #3523435
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
	-- API body ends heres

	-- Check Error Message stack.
	x_msg_count := FND_MSG_PUB.count_msg;

	--priyan
	--R12 MEL/CDL
	IF ( x_msg_count > 0  AND l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
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
		Rollback to Process_Master_Config_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to Process_Master_Config_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to Process_Master_Config_SP;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.add_exc_msg
			(
				p_pkg_name		=> G_PKG_NAME,
				p_procedure_name 	=> 'Process_Master_Config',
				p_error_text     	=> SUBSTR(SQLERRM,1,240)
			);
		END IF;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

END Process_Master_Config;

End AHL_MC_MasterConfig_PUB;

/
