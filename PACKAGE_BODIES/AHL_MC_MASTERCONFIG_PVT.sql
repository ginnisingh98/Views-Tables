--------------------------------------------------------
--  DDL for Package Body AHL_MC_MASTERCONFIG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_MC_MASTERCONFIG_PVT" AS
/* $Header: AHLVMCXB.pls 120.4.12010000.2 2008/11/06 10:45:40 sathapli ship $ */

G_USER_ID 	CONSTANT 	NUMBER 		:= TO_NUMBER(FND_GLOBAL.USER_ID);
G_LOGIN_ID 	CONSTANT 	NUMBER 		:= TO_NUMBER(FND_GLOBAL.LOGIN_ID);
G_SYSDATE 	CONSTANT 	DATE 		:= SYSDATE;
G_TRUNC_DATE 	CONSTANT 	DATE 		:= TRUNC(SYSDATE);

-------------------
-- Common variables
-------------------
l_dummy_varchar		VARCHAR2(1);
l_dummy_number		NUMBER;

-------------------------------------
-- Validation procedure signatures --
-------------------------------------
PROCEDURE Validate_MC_Exists
(
	p_mc_header_id in number,
	p_object_ver_num in number
);

PROCEDURE Validate_MC_Name
(
	p_x_mc_header_rec in Header_Rec_Type
);

PROCEDURE Validate_MC_Revision
(
	p_x_mc_header_rec in Header_Rec_Type
);

-----------------------------------
-- Non-spec Procedure Signatures --
-----------------------------------
FUNCTION Get_MC_Status
(
	p_mc_header_id in number
)
RETURN VARCHAR2;

PROCEDURE Set_Header_Status
(
	p_mc_header_id IN NUMBER
);

PROCEDURE Check_MC_Complete
(
	p_mc_header_id IN NUMBER
);

---------------------
-- Spec Procedures --
---------------------
PROCEDURE Create_Master_Config
(
	p_api_version		IN 		NUMBER,
	p_init_msg_list       	IN 		VARCHAR2,
	p_commit              	IN 		VARCHAR2,
	p_validation_level    	IN 		NUMBER,
	x_return_status       	OUT 	NOCOPY  VARCHAR2,
	x_msg_count           	OUT 	NOCOPY  NUMBER,
	x_msg_data            	OUT 	NOCOPY  VARCHAR2,
	p_x_mc_header_rec     	IN OUT 	NOCOPY 	Header_Rec_Type,
	p_x_node_rec          	IN OUT 	NOCOPY 	AHL_MC_Node_PVT.Node_Rec_Type
)
IS
	-- Define cursor check_other_mc_name_unique to to check uniqueness of MC name across other MCs
	-- for the case of creating new revision of an MC
	CURSOR check_other_mc_name_unique
	(
		p_mc_name in varchar2,
		p_mc_id in number
	)
	IS
		SELECT 	'x'
		FROM 	ahl_mc_headers_b
		WHERE 	upper(name) = upper(p_mc_name) AND
			mc_id <> p_mc_id;

	-- 1.	Declare local variables
	l_api_name	CONSTANT	VARCHAR2(30)	:= 'Create_Master_Config';
	l_api_version	CONSTANT	NUMBER		:= 1.0;
	l_return_status			VARCHAR2(1);
	l_msg_count         		NUMBER;
	l_msg_data          		VARCHAR2(2000);

	l_row_id			ROWID;
	l_counter_rules_tbl		AHL_MC_Node_PVT.Counter_Rules_Tbl_Type;
	l_subconfig_tbl			AHL_MC_Node_PVT.Subconfig_Tbl_Type;

BEGIN

	-- Standard start of API savepoint
	SAVEPOINT Create_Master_Config_SP;

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

	IF (p_x_mc_header_rec.mc_id IS NULL)
	THEN
		-- 2.	Implies the MC is being created for the first time and a revision of existing MC is not being created

		-- 2a.	Validate p_x_mc_header_rec.name is unique
		Validate_MC_Name(p_x_mc_header_rec);
	ELSE
		-- 3.	Implies revision of an existing MC is being created

		-- 3a.	Validate an MC exists with MC_HEADER_ID = p_x_mc_header_rec.MC_ID
		Validate_MC_Exists(p_x_mc_header_rec.mc_id, null);

		-- 3b.	Validate p_x_mc_header_rec.name is unique across all other MCs
		-- Confirm user has entered MC Name, since it is mandatory
		IF (RTRIM(p_x_mc_header_rec.name) IS NULL)
		THEN
			FND_MESSAGE.Set_Name('AHL','AHL_MC_NAME_INVALID');
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
			OPEN check_other_mc_name_unique (p_x_mc_header_rec.name, p_x_mc_header_rec.mc_id);
			FETCH check_other_mc_name_unique INTO l_dummy_varchar;
			IF (check_other_mc_name_unique%FOUND)
			THEN
				FND_MESSAGE.Set_Name('AHL','AHL_MC_RNAME_EXISTS');
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
			CLOSE check_other_mc_name_unique;
		END IF;
	END IF;

	-- 3c.	Validate p_x_mc_header_rec.revision (unique across all revisions of the same MC + atleast one alphabetic character)
	Validate_MC_Revision(p_x_mc_header_rec);

	-- 4.	Validate p_x_mc_header_rec.config_status_code, should be defaulted to 'DRAFT'
	IF (p_x_mc_header_rec.config_status_code <> 'DRAFT')
	THEN
		FND_MESSAGE.Set_Name('AHL', 'AHL_MC_STATUS_INVALID');
		FND_MESSAGE.Set_Token('STATUS', p_x_mc_header_rec.config_status_meaning);
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

	-- Check Error Message stack.
	x_msg_count := FND_MSG_PUB.count_msg;
	IF x_msg_count > 0
	THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

  	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
			'Header validation successful'
		);
	END IF;

	-- 6.	Select next value from the AHL_MC_HEADERS_B_S sequence
	SELECT ahl_mc_headers_b_s.nextval INTO p_x_mc_header_rec.mc_header_id FROM dual;

	-- 7.	Set values for p_x_mc_header_rec
	p_x_mc_header_rec.object_version_number := 1;
	p_x_mc_header_rec.security_group_id := null;

	IF (p_x_mc_header_rec.version_number IS NULL)
	THEN
		p_x_mc_header_rec.version_number := 1;
	END IF;

	IF (p_x_mc_header_rec.revision IS NULL)
	THEN
		p_x_mc_header_rec.revision := to_char(p_x_mc_header_rec.version_number);
	END IF;

	-- Default mc_id = mc_header_id if null
	IF (p_x_mc_header_rec.mc_id IS NULL)
	THEN
		p_x_mc_header_rec.mc_id := p_x_mc_header_rec.mc_header_id;
	END IF;

	-- 8.	Call AHL_MC_HEADERS_PKG.INSERT_ROW with relevant attribute values
	AHL_MC_HEADERS_PKG.INSERT_ROW
	(
		X_ROWID			=> l_row_id,	-- passed as dummy, cannot pass null
		X_MC_HEADER_ID		=> p_x_mc_header_rec.mc_header_id,
		X_NAME			=> p_x_mc_header_rec.name,
		X_MC_ID			=> p_x_mc_header_rec.mc_id,
		X_VERSION_NUMBER	=> p_x_mc_header_rec.version_number,
		X_REVISION		=> p_x_mc_header_rec.revision,
		X_MODEL_CODE            => p_x_mc_header_rec.model_code, -- SATHAPLI::Enigma code changes, 26-Aug-2008
		X_CONFIG_STATUS_CODE	=> p_x_mc_header_rec.config_status_code,
		X_OBJECT_VERSION_NUMBER	=> p_x_mc_header_rec.object_version_number,
		X_SECURITY_GROUP_ID	=> p_x_mc_header_rec.security_group_id,
		X_ATTRIBUTE_CATEGORY	=> p_x_mc_header_rec.attribute_category,
		X_ATTRIBUTE1		=> p_x_mc_header_rec.attribute1,
		X_ATTRIBUTE2		=> p_x_mc_header_rec.attribute2,
		X_ATTRIBUTE3		=> p_x_mc_header_rec.attribute3,
		X_ATTRIBUTE4		=> p_x_mc_header_rec.attribute4,
		X_ATTRIBUTE5		=> p_x_mc_header_rec.attribute5,
		X_ATTRIBUTE6		=> p_x_mc_header_rec.attribute6,
		X_ATTRIBUTE7		=> p_x_mc_header_rec.attribute7,
		X_ATTRIBUTE8		=> p_x_mc_header_rec.attribute8,
		X_ATTRIBUTE9		=> p_x_mc_header_rec.attribute9,
		X_ATTRIBUTE10		=> p_x_mc_header_rec.attribute10,
		X_ATTRIBUTE11		=> p_x_mc_header_rec.attribute11,
		X_ATTRIBUTE12		=> p_x_mc_header_rec.attribute12,
		X_ATTRIBUTE13		=> p_x_mc_header_rec.attribute13,
		X_ATTRIBUTE14		=> p_x_mc_header_rec.attribute14,
		X_ATTRIBUTE15		=> p_x_mc_header_rec.attribute15,
		X_DESCRIPTION		=> p_x_mc_header_rec.description,
		X_CREATION_DATE		=> G_SYSDATE,
		X_CREATED_BY		=> G_USER_ID,
		X_LAST_UPDATE_DATE	=> G_SYSDATE,
		X_LAST_UPDATED_BY	=> G_USER_ID,
  		X_LAST_UPDATE_LOGIN	=> G_LOGIN_ID
	);

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
			'Header ['||p_x_mc_header_rec.mc_header_id||'] created'
		);
	END IF;

	-- 9.	Select next value from the AHL_MC_RELATIONSHIPS_S sequence
	SELECT ahl_mc_relationships_s.nextval INTO p_x_node_rec.relationship_id FROM dual;

	-- 10.	Set values for p_x_node_rec
	p_x_node_rec.mc_header_id := p_x_mc_header_rec.mc_header_id;
	p_x_node_rec.parent_relationship_id := null;
	p_x_node_rec.object_version_number := 1;
	IF (p_x_node_rec.operation_flag IS NULL)
	THEN
		-- This can also be G_DML_COPY, if not defined already default to G_DML_CREATE
		p_x_node_rec.operation_flag := G_DML_CREATE;
	END IF;

	IF (p_x_node_rec.position_key IS NULL)
	THEN
		SELECT ahl_mc_rel_pos_key_s.nextval INTO p_x_node_rec.position_key FROM dual;
	END IF;

	IF (p_x_node_rec.position_necessity_code <> 'MANDATORY')
	THEN
		FND_MESSAGE.Set_Name('AHL', 'AHL_MC_TOPNODE_NEC_INV');
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
   -- AnRaj: Bug # 5385301, Removed the hardcoded validation for UOM
	/*
   IF (p_x_node_rec.uom_code <> 'Ea')
	THEN
		FND_MESSAGE.Set_Name('AHL', 'AHL_MC_TOPNODE_UOM_INV');
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
   */
	IF (p_x_node_rec.quantity <> 1)
	THEN
		FND_MESSAGE.Set_Name('AHL', 'AHL_MC_TOPNODE_QTY_INV');
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

	IF (p_x_node_rec.display_order <> 1)
	THEN
		FND_MESSAGE.Set_Name('AHL', 'AHL_MC_TOPNODE_DSP_INV');
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

	-- Check Error Message stack.
	x_msg_count := FND_MSG_PUB.count_msg;
	IF x_msg_count > 0
	THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

  	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
			'Node validation successful... Calling AHL_MC_Node_PVT.Create_Node'
		);
	END IF;

	-- 11.	Call AHL_MC_NODE_PVT.Create_Node to create MC topnode
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
		p_x_counter_rules_tbl	=> l_counter_rules_tbl, -- passed as dummy, cannot pass null
		p_x_subconfig_tbl	=> l_subconfig_tbl	-- passed as dummy, cannot pass null
	);

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
	IF x_msg_count > 0
	THEN
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
		Rollback to Create_Master_Config_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to Create_Master_Config_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to Create_Master_Config_SP;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.add_exc_msg
			(
				p_pkg_name		=> G_PKG_NAME,
				p_procedure_name 	=> 'Create_Master_Config',
				p_error_text     	=> SUBSTR(SQLERRM,1,240)
			);
		END IF;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

END Create_Master_Config;

PROCEDURE Modify_Master_Config
(
	p_api_version		IN 		NUMBER,
	p_init_msg_list       	IN 		VARCHAR2,
	p_commit              	IN 		VARCHAR2,
	p_validation_level    	IN 		NUMBER,
	x_return_status       	OUT 	NOCOPY  VARCHAR2,
	x_msg_count           	OUT 	NOCOPY  NUMBER,
	x_msg_data            	OUT 	NOCOPY  VARCHAR2,
	p_x_mc_header_rec     	IN OUT 	NOCOPY 	Header_Rec_Type,
	p_x_node_rec          	IN OUT 	NOCOPY 	AHL_MC_Node_PVT.Node_Rec_Type
)
IS
	-- Define local variables
	l_api_name	CONSTANT	VARCHAR2(30)	:= 'Modify_Master_Config';
	l_api_version	CONSTANT	NUMBER		:= 1.0;
	l_return_status			VARCHAR2(1);
	l_msg_count         		NUMBER;
	l_msg_data          		VARCHAR2(2000);

	l_counter_rules_tbl		AHL_MC_Node_PVT.Counter_Rules_Tbl_Type;
	l_subconfig_tbl			AHL_MC_Node_PVT.Subconfig_Tbl_Type;
	l_header_status			VARCHAR2(30);

BEGIN

	-- Standard start of API savepoint
	SAVEPOINT Modify_Master_Config_SP;

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

	-- 1a.	Validate a MC with p_x_mc_header_rec.mc_header_id exists
	-- 1b.	Validate p_x_mc_header_rec.object_version_number
	Validate_MC_Exists(p_x_mc_header_rec.mc_header_id, nvl(p_x_mc_header_rec.object_version_number, 0));

	-- 1c.	Validate p_x_mc_header_rec.config_status_code, should be either DRAFT/ APPROVAL_REJECTED
	l_header_status := Get_MC_Status(p_x_mc_header_rec.mc_header_id);

	-- Fix for Bug #3523435
	-- Trying to modify status = COMPLETE without initiating approval
	IF (p_x_mc_header_rec.config_status_code = 'COMPLETE' AND l_header_status <> 'COMPLETE')
	THEN
		FND_MESSAGE.Set_Name('AHL', 'AHL_MC_INIT_APPR_COMP');
		FND_MESSAGE.Set_Token('MC_NAME', p_x_mc_header_rec.name);
		FND_MSG_PUB.ADD;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
	-- Fix for Bug #3523435

	IF (l_header_status = 'APPROVAL_REJECTED')
	THEN
		p_x_mc_header_rec.config_status_code := 'DRAFT';
	ELSIF (l_header_status <> 'DRAFT')
	THEN
		FND_MESSAGE.Set_Name('AHL', 'AHL_MC_EDIT_STS_INV');
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
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	-- Confirm name of the MC has not changed, since it is the user-enterable unique name
	Validate_MC_Name(p_x_mc_header_rec);

	IF (p_x_mc_header_rec.mc_id <> p_x_mc_header_rec.mc_header_id)
	THEN
		-- 1e.i.	Validate an MC exists with MC_HEADER_ID = p_x_mc_header_rec.MC_ID
		Validate_MC_Exists(p_x_mc_header_rec.mc_id, null);
	END IF;

	-- 1e.ii.	Validate p_x_mc_header_rec.revision (unique across all revisions of the same MC + atleast one alphabetic character)
	Validate_MC_Revision(p_x_mc_header_rec);

	-- Check Error Message stack.
	x_msg_count := FND_MSG_PUB.count_msg;
	IF x_msg_count > 0
	THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

  	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
			'Header validation successful'
		);
	END IF;

	-- Set values for p_x_mc_header_rec
	p_x_mc_header_rec.object_version_number := p_x_mc_header_rec.object_version_number + 1;

	IF (p_x_mc_header_rec.revision IS NULL AND p_x_mc_header_rec.version_number IS NOT NULL)
	THEN
		p_x_mc_header_rec.revision := to_char(p_x_mc_header_rec.version_number);
	END IF;

	-- 1h.	Call AHL_MC_HEADERS_PKG.UPDATE_ROW with relevant attribute values
	AHL_MC_HEADERS_PKG.UPDATE_ROW
	(
		X_MC_HEADER_ID		=> p_x_mc_header_rec.mc_header_id,
		X_NAME			=> p_x_mc_header_rec.name,
		X_MC_ID			=> p_x_mc_header_rec.mc_id,
		X_VERSION_NUMBER	=> p_x_mc_header_rec.version_number,
		X_REVISION		=> p_x_mc_header_rec.revision,
		X_MODEL_CODE            => p_x_mc_header_rec.model_code, -- SATHAPLI::Enigma code changes, 26-Aug-2008
		X_CONFIG_STATUS_CODE	=> p_x_mc_header_rec.config_status_code,
		X_OBJECT_VERSION_NUMBER	=> p_x_mc_header_rec.object_version_number,
		X_SECURITY_GROUP_ID	=> p_x_mc_header_rec.security_group_id,
		X_ATTRIBUTE_CATEGORY	=> p_x_mc_header_rec.attribute_category,
		X_ATTRIBUTE1		=> p_x_mc_header_rec.attribute1,
		X_ATTRIBUTE2		=> p_x_mc_header_rec.attribute2,
		X_ATTRIBUTE3		=> p_x_mc_header_rec.attribute3,
		X_ATTRIBUTE4		=> p_x_mc_header_rec.attribute4,
		X_ATTRIBUTE5		=> p_x_mc_header_rec.attribute5,
		X_ATTRIBUTE6		=> p_x_mc_header_rec.attribute6,
		X_ATTRIBUTE7		=> p_x_mc_header_rec.attribute7,
		X_ATTRIBUTE8		=> p_x_mc_header_rec.attribute8,
		X_ATTRIBUTE9		=> p_x_mc_header_rec.attribute9,
		X_ATTRIBUTE10		=> p_x_mc_header_rec.attribute10,
		X_ATTRIBUTE11		=> p_x_mc_header_rec.attribute11,
		X_ATTRIBUTE12		=> p_x_mc_header_rec.attribute12,
		X_ATTRIBUTE13		=> p_x_mc_header_rec.attribute13,
		X_ATTRIBUTE14		=> p_x_mc_header_rec.attribute14,
		X_ATTRIBUTE15		=> p_x_mc_header_rec.attribute15,
		X_DESCRIPTION		=> p_x_mc_header_rec.description,
		X_LAST_UPDATE_DATE	=> G_SYSDATE,
		X_LAST_UPDATED_BY	=> G_USER_ID,
  		X_LAST_UPDATE_LOGIN	=> G_LOGIN_ID
  	);

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
			'Header ['||p_x_mc_header_rec.mc_header_id||'] updated'
		);
	END IF;

	-- 2b.	Validate p_x_node_rec.mc_header_id = p_x_mc_header_rec.mc_header_id
	IF (p_x_node_rec.mc_header_id <> p_x_mc_header_rec.mc_header_id)
	THEN
		FND_MESSAGE.Set_Name('AHL', 'AHL_MC_TOPNODE_NOTFOUND');
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
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	IF (p_x_node_rec.position_necessity_code <> 'MANDATORY')
	THEN
		FND_MESSAGE.Set_Name('AHL', 'AHL_MC_TOPNODE_NEC_INV');
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

   -- AnRaj: Bug # 5385301, Removed the hardcoded validation for UOM
	/*
   IF (p_x_node_rec.uom_code <> 'Ea')
	THEN
		FND_MESSAGE.Set_Name('AHL', 'AHL_MC_TOPNODE_UOM_INV');
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
   */
	IF (p_x_node_rec.quantity <> 1)
	THEN
		FND_MESSAGE.Set_Name('AHL', 'AHL_MC_TOPNODE_QTY_INV');
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

	IF (p_x_node_rec.display_order <> 1)
	THEN
		FND_MESSAGE.Set_Name('AHL', 'AHL_MC_TOPNODE_DSP_INV');
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

	-- Check Error Message stack.
	x_msg_count := FND_MSG_PUB.count_msg;
	IF x_msg_count > 0
	THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

  	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
			'Node validation successful... Calling AHL_MC_Node_PVT.Modify_Node'
		);
	END IF;

	-- Set values for p_x_node_rec
	p_x_node_rec.mc_header_id := p_x_mc_header_rec.mc_header_id;
	p_x_node_rec.operation_flag := G_DML_UPDATE;

	-- 2g.	Call AHL_MC_NODE_PVT.Modify_Node to modify MC topnode
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
		p_x_counter_rules_tbl	=> l_counter_rules_tbl, -- passed as dummy, cannot pass null
		p_x_subconfig_tbl	=> l_subconfig_tbl	-- passed as dummy, cannot pass null
	);

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

	--Priyan
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
		Rollback to Modify_Master_Config_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to Modify_Master_Config_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to Modify_Master_Config_SP;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.add_exc_msg
			(
				p_pkg_name		=> G_PKG_NAME,
				p_procedure_name 	=> 'Modify_Master_Config',
				p_error_text     	=> SUBSTR(SQLERRM,1,240)
			);
		END IF;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

END Modify_Master_Config;

PROCEDURE Delete_Master_Config
(
	p_api_version		IN 		NUMBER,
	p_init_msg_list       	IN 		VARCHAR2	:= FND_API.G_FALSE,
	p_commit              	IN 		VARCHAR2 	:= FND_API.G_FALSE,
	p_validation_level    	IN 		NUMBER 		:= FND_API.G_VALID_LEVEL_FULL,
	x_return_status       	OUT 	NOCOPY  VARCHAR2,
	x_msg_count           	OUT 	NOCOPY  NUMBER,
	x_msg_data            	OUT 	NOCOPY  VARCHAR2,
	p_mc_header_id     	IN 		NUMBER,
	p_object_ver_num        IN 		NUMBER
)
IS
	-- Define cursor check_mc_not_subconfig to verify that MC is not associated as a subconfiguration
	-- ##TAMAL## -- Need to check for only non-expired subconfiguration associations, but also need to delete
	-- such associations from the table so that the draft MC can be deleted, else will throw foreign key
	-- validation error...
	-- ##TAMAL## -- Need some mechanism to check whether a subconfiguration association is logically expired,
	-- since any node up to the root node could be expired...
	CURSOR check_mc_not_subconfig
	(
		p_mc_header_id in number
	)
	IS
		SELECT 'x'
		FROM ahl_mc_config_relations
		WHERE mc_header_id = p_mc_header_id;

	-- Define get_mc_topnode_details to read the details of the MC topnode
	CURSOR get_mc_topnode_details
	(
		p_mc_header_id in number
	)
	IS
		SELECT 	relationship_id, object_version_number
		FROM 	ahl_mc_relationships
		WHERE 	mc_header_id = p_mc_header_id AND
			parent_relationship_id IS NULL;

	-- Define cursor check_unit_assigned to verify whether there are any units
	-- associated with the MC
	CURSOR check_unit_assigned
	(
		p_mc_header_id in number
	)
	IS
		SELECT 	'x'
		FROM 	ahl_unit_config_headers
		WHERE 	master_config_id = p_mc_header_id AND
			trunc(nvl(active_end_date, G_SYSDATE + 1)) > G_TRUNC_DATE;

		/*
		SELECT	'x'
		FROM	ahl_mc_relationships mcr, ahl_unit_config_headers uch
		WHERE	mcr.mc_header_id = p_mc_header_id AND
			mcr.parent_relationship_id IS NULL AND
			uch.master_config_id = mcr.relationship_id AND
			trunc(nvl(uch.active_end_date, G_SYSDATE + 1)) > G_TRUNC_DATE;
		*/

	-- 1.	Declare local variables
	l_api_name	CONSTANT	VARCHAR2(30)	:= 'Delete_Master_Config';
	l_api_version	CONSTANT	NUMBER		:= 1.0;
	l_return_status			VARCHAR2(1);
	l_msg_count         		NUMBER;
	l_msg_data          		VARCHAR2(2000);

	l_config_status_code		VARCHAR2(30);
	l_active_end_date		DATE;
	l_topnode_rel_id		NUMBER;
	l_topnode_object_ver_num	NUMBER;

BEGIN

	-- Standard start of API savepoint
	SAVEPOINT Delete_Master_Config_SP;

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

	-- 2.	Validate a MC with mc_header_id = p_mc_header_id exists, and object_version_number = p_object_ver_num
	Validate_MC_Exists(p_mc_header_id, nvl(p_object_ver_num, 0));

	-- 3.	Validate the MC is not associated as a subconfiguration
	OPEN check_mc_not_subconfig(p_mc_header_id);
	FETCH check_mc_not_subconfig INTO l_dummy_varchar;
	IF (check_mc_not_subconfig%FOUND)
	THEN
		FND_MESSAGE.Set_Name('AHL', 'AHL_MC_IS_SUBCONFIG');
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
		CLOSE check_mc_not_subconfig;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
	CLOSE check_mc_not_subconfig;

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
			'Header validation successful'
		);
	END IF;

	-- 4.	Query for the config_status_code of the MC with mc_header_id = p_mc_header_id
	l_config_status_code := Get_MC_Status(p_mc_header_id);
	IF (l_config_status_code IN ('CLOSED', 'EXPIRED'))
	THEN
		FND_MESSAGE.Set_Name('AHL', 'AHL_MC_DEL_STS_INV');
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
	ELSIF (l_config_status_code IN ('DRAFT', 'APPROVAL_REJECTED'))
	THEN
		-- 6.	If l_config_status_code = 'DRAFT' or 'APPROVAL_REJECTED' [Delete MC]

		-- 6a.	Call AHL_MC_RULE_PVT.Delete_Rules_For_MC to delete all the rules associated with this MC
		AHL_MC_RULE_PVT.Delete_Rules_For_MC
		(
			p_api_version 		=> 1.0,
			p_init_msg_list 	=> FND_API.G_FALSE,
			p_commit 		=> FND_API.G_FALSE,
			p_validation_level 	=> FND_API.G_VALID_LEVEL_FULL,
			x_return_status 	=> l_return_status,
			x_msg_count 		=> l_msg_count,
			x_msg_data 		=> l_msg_data,
			p_mc_header_id 		=> p_mc_header_id
		);

		-- Check Error Message stack.
		x_msg_count := FND_MSG_PUB.count_msg;
		IF x_msg_count > 0 THEN
			RAISE FND_API.G_EXC_ERROR;
		END IF;

		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_statement,
				'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
				'Deleted rules for MC'
			);
		END IF;

		-- 6b.	Call AHL_MC_PATH_POSITION_PVT.Delete_Positions_For_MC to delete all the position path records for this MC
		AHL_MC_PATH_POSITION_PVT.Delete_Positions_For_MC
		(
			p_api_version 		=> 1.0,
			p_init_msg_list 	=> FND_API.G_FALSE,
			p_commit 		=> FND_API.G_FALSE,
			p_validation_level 	=> FND_API.G_VALID_LEVEL_FULL,
			x_return_status 	=> l_return_status,
			x_msg_count 		=> l_msg_count,
			x_msg_data 		=> l_msg_data,
			p_mc_header_id 		=> p_mc_header_id
		);

		-- Check Error Message stack.
		x_msg_count := FND_MSG_PUB.count_msg;
		IF x_msg_count > 0 THEN
			RAISE FND_API.G_EXC_ERROR;
		END IF;

		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_statement,
				'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
				'Deleted position paths for MC'
			);
		END IF;

		-- 5.	Query for the topnode of the MC with MC_HEADER_ID = p_mc_header_id
		OPEN get_mc_topnode_details(p_mc_header_id);
		FETCH get_mc_topnode_details INTO l_topnode_rel_id, l_topnode_object_ver_num;
		CLOSE get_mc_topnode_details;

		-- 6c.	Call AHL_MC_NODE_PVT.Delete_Node to delete the MC tree starting from the topnode
		AHL_MC_NODE_PVT.Delete_Node
		(
			p_api_version 		=> 1.0,
			p_init_msg_list 	=> FND_API.G_FALSE,
			p_commit 		=> FND_API.G_FALSE,
			p_validation_level 	=> FND_API.G_VALID_LEVEL_FULL,
			x_return_status		=> l_return_status,
			x_msg_count 		=> l_msg_count,
			x_msg_data 		=> l_msg_data,
			p_node_id 		=> l_topnode_rel_id,
			p_object_ver_num 	=> l_topnode_object_ver_num
		);

		-- Check Error Message stack.
		x_msg_count := FND_MSG_PUB.count_msg;
		IF x_msg_count > 0 THEN
			RAISE FND_API.G_EXC_ERROR;
		END IF;

		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_statement,
				'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
				'Deleted nodes for MC'
			);
		END IF;

		-- 6d.	Call AHL_MC_HEADERS_PKG.DELETE_ROW to delete the MC
		AHL_MC_HEADERS_PKG.DELETE_ROW (p_mc_header_id);

		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_statement,
				'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
				'Deleted Header'
			);
		END IF;

	ELSIF (l_config_status_code = 'COMPLETE')
	THEN
		-- 7.	If l_config_status_code = 'COMPLETE' [Close MC]

		-- 7a.	Validate whether there are no units for this MC
		OPEN check_unit_assigned(p_mc_header_id);
		FETCH check_unit_assigned INTO l_dummy_varchar;
		IF (check_unit_assigned%FOUND)
		THEN
			FND_MESSAGE.Set_Name('AHL', 'AHL_MC_CLOSE_INVALID');
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
			CLOSE check_unit_assigned;
			RAISE FND_API.G_EXC_ERROR;
		END IF;
		CLOSE check_unit_assigned;

		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_statement,
				'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
				'Unit assignment for Header ['||p_mc_header_id||'] validated'
			);
		END IF;

		-- 7b.	Update the config_status_code = 'CLOSED' and object_version_number for the MC with MC_HEADER_ID = p_ mc_header_id
		UPDATE 	ahl_mc_headers_b
		SET 	object_version_number = p_object_ver_num + 1,
			config_status_code = 'CLOSED',
			last_update_date = G_SYSDATE,
			last_updated_by = G_USER_ID,
			last_update_login = G_LOGIN_ID
		WHERE 	mc_header_id = p_mc_header_id;

		-- Query for the topnode of the MC with MC_HEADER_ID = p_mc_header_id
		OPEN get_mc_topnode_details(p_mc_header_id);
		FETCH get_mc_topnode_details INTO l_topnode_rel_id, l_topnode_object_ver_num;
		CLOSE get_mc_topnode_details;

		-- 7c.	Update the active_end_date of the topnode of the MC with MC_HEADER_ID = p_mc_header_id
		UPDATE 	ahl_mc_relationships
		SET 	active_end_date = G_TRUNC_DATE,
			object_version_number = l_topnode_object_ver_num + 1,
			last_update_date = G_SYSDATE,
			last_updated_by = G_USER_ID,
			last_update_login = G_LOGIN_ID
		WHERE 	relationship_id = l_topnode_rel_id;

		-- ##TAMAL## -- Should expire all attached subconfiguration associations to the nodes of the MC?
		-- Consider the case that a particular draft MC automatically expires based on end-date, there is another draft
		-- MC associated with one of the nodes, the latter cannot be deleted ever since it is associated as a
		-- subconfig, since potentially the earlier MC can be reopened

		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_statement,
				'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
				'Header ['||p_mc_header_id||'] and topnode ['||l_topnode_rel_id||'] closed'
			);
		END IF;

	ELSE
		FND_MESSAGE.Set_Name('AHL', 'AHL_MC_DELETE_STS_INV');
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
		Rollback to Delete_Master_Config_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to Delete_Master_Config_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to Delete_Master_Config_SP;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.add_exc_msg
			(
				p_pkg_name		=> G_PKG_NAME,
				p_procedure_name 	=> 'Delete_Master_Config',
				p_error_text     	=> SUBSTR(SQLERRM,1,240)
			);
		END IF;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

END Delete_Master_Config;

PROCEDURE Copy_Master_Config
(
	p_api_version		IN 		NUMBER,
	p_init_msg_list       	IN 		VARCHAR2	:= FND_API.G_FALSE,
	p_commit              	IN 		VARCHAR2 	:= FND_API.G_FALSE,
	p_validation_level    	IN 		NUMBER 		:= FND_API.G_VALID_LEVEL_FULL,
	x_return_status       	OUT 	NOCOPY  VARCHAR2,
	x_msg_count           	OUT 	NOCOPY  NUMBER,
	x_msg_data            	OUT 	NOCOPY  VARCHAR2,
	p_x_mc_header_rec     	IN OUT 	NOCOPY 	Header_Rec_Type,
	p_x_node_rec          	IN OUT 	NOCOPY 	AHL_MC_Node_PVT.Node_Rec_Type
)
IS

	-- 1.	Define local variables
	l_api_name	CONSTANT	VARCHAR2(30)	:= 'Copy_Master_Config';
	l_api_version	CONSTANT	NUMBER		:= 1.0;
	l_return_status			VARCHAR2(1);
	l_msg_count         		NUMBER;
	l_msg_data          		VARCHAR2(2000);

	l_old_mc_header_id 		NUMBER;
	l_old_node_id 			NUMBER;

BEGIN

	-- Standard start of API savepoint
	SAVEPOINT Copy_Master_Config_SP;

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

	Validate_MC_Exists (p_x_mc_header_rec.mc_header_id, nvl(p_x_mc_header_rec.object_version_number, 0));

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
			'Header validation successful'
		);
	END IF;

	l_old_mc_header_id := p_x_mc_header_rec.mc_header_id;
	l_old_node_id := p_x_node_rec.relationship_id;

	-- 5.	Set values for p_x_mc_header_rec
	p_x_mc_header_rec.mc_header_id := null;
	p_x_mc_header_rec.config_status_code := 'DRAFT';
	p_x_mc_header_rec.mc_id := null;
	p_x_mc_header_rec.version_number := 1;
	p_x_mc_header_rec.operation_flag := G_DML_CREATE;

	-- 6.	Set values for p_x_node_rec
	p_x_node_rec.mc_header_id := null;
	p_x_node_rec.parent_relationship_id := null;
	p_x_node_rec.operation_flag := G_DML_COPY;

	-- 7.	Call AHL_MC_MasterConfig_PVT.Create_Master_Config
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

	-- Check Error Message stack.
	x_msg_count := FND_MSG_PUB.count_msg;
	IF x_msg_count > 0 THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
			'Header ['||p_x_mc_header_rec.mc_header_id||'] and topnode ['||p_x_node_rec.relationship_id||'] copied'
		);

		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
			'Copying documents from topnode ['||l_old_node_id||'] to topnode ['||p_x_node_rec.relationship_id||']'
		);
	END IF;

	-- 8.	Copy all documents associated with the topnode
	AHL_DI_ASSO_DOC_GEN_PVT.COPY_ASSOCIATION
	(
		p_api_version         	=> 1.0,
		p_commit              	=> FND_API.G_FALSE,
		p_validation_level    	=> FND_API.G_VALID_LEVEL_FULL,
		p_from_object_id      	=> l_old_node_id,
		p_from_object_type    	=> 'MC',
		p_to_object_id        	=> p_x_node_rec.relationship_id,
		p_to_object_type      	=> 'MC',
		x_return_status       	=> l_return_status,
		x_msg_count           	=> l_msg_count,
		x_msg_data            	=> l_msg_data
	);

	-- Check Error Message stack.
	x_msg_count := FND_MSG_PUB.count_msg;
	IF x_msg_count > 0 THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
			'Copying nodes'
		);
	END IF;

	-- 9.	Copy all other child nodes to the topnode of the source MC
	AHL_MC_Node_PVT.Copy_MC_Nodes
	(
		p_api_version 		=> 1.0,
		p_init_msg_list 	=> FND_API.G_FALSE,
		p_commit 		=> FND_API.G_FALSE,
		p_validation_level 	=> FND_API.G_VALID_LEVEL_FULL,
		x_return_status 	=> l_return_status,
		x_msg_count 		=> l_msg_count,
		x_msg_data 		=> l_msg_data,
		p_source_rel_id 	=> l_old_node_id,
		p_dest_rel_id 		=> p_x_node_rec.relationship_id,
		p_new_rev_flag 		=> FALSE,
		p_node_copy		=> FALSE
	);

	-- Check Error Message stack.
	x_msg_count := FND_MSG_PUB.count_msg;
	IF x_msg_count > 0 THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
			'Copying position paths'
		);
	END IF;

	-- 10.	Copy position paths from the old MC to the new MC
	AHL_MC_PATH_POSITION_PVT.Copy_Positions_For_MC
	(
		p_api_version 		=> 1.0,
		p_init_msg_list 	=> FND_API.G_FALSE,
		p_commit 		=> FND_API.G_FALSE,
		p_validation_level 	=> FND_API.G_VALID_LEVEL_FULL,
		x_return_status 	=> l_return_status,
		x_msg_count 		=> l_msg_count,
		x_msg_data 		=> l_msg_data,
		p_from_mc_header_id 	=> l_old_mc_header_id,
		p_to_mc_header_id 	=> p_x_mc_header_rec.mc_header_id
	);

	-- Check Error Message stack.
	x_msg_count := FND_MSG_PUB.count_msg;
	IF x_msg_count > 0 THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
			'Copying rules'
		);
	END IF;

	-- 11.	Copy rules from the old MC to the new MC
	AHL_MC_RULE_PVT.Copy_Rules_For_MC
	(
		p_api_version 		=> 1.0,
		p_init_msg_list 	=> FND_API.G_FALSE,
		p_commit 		=> FND_API.G_FALSE,
		p_validation_level 	=> FND_API.G_VALID_LEVEL_FULL,
		x_return_status 	=> l_return_status,
		x_msg_count 		=> l_msg_count,
		x_msg_data 		=> l_msg_data,
		p_from_mc_header_id 	=> l_old_mc_header_id,
		p_to_mc_header_id 	=> p_x_mc_header_rec.mc_header_id
	);

	-- Check Error Message stack.
	x_msg_count := FND_MSG_PUB.count_msg;
	IF x_msg_count > 0 THEN
		RAISE FND_API.G_EXC_ERROR;
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
		Rollback to Copy_Master_Config_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to Copy_Master_Config_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to Copy_Master_Config_SP;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.add_exc_msg
			(
				p_pkg_name		=> G_PKG_NAME,
				p_procedure_name 	=> 'Copy_Master_Config',
				p_error_text     	=> SUBSTR(SQLERRM,1,240)
			);
		END IF;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

END Copy_Master_Config;

PROCEDURE Create_MC_Revision
(
	p_api_version		IN 		NUMBER,
	p_init_msg_list       	IN 		VARCHAR2	:= FND_API.G_FALSE,
	p_commit              	IN 		VARCHAR2 	:= FND_API.G_FALSE,
	p_validation_level    	IN 		NUMBER 		:= FND_API.G_VALID_LEVEL_FULL,
	x_return_status       	OUT 	NOCOPY  VARCHAR2,
	x_msg_count           	OUT 	NOCOPY  NUMBER,
	x_msg_data            	OUT 	NOCOPY  VARCHAR2,
	p_x_mc_header_id     	IN OUT	NOCOPY	NUMBER,
	p_object_ver_num        IN 		NUMBER
)
IS
	-- 1.	Define get_header_rec_csr to get the details of the header record for a particular MC
	CURSOR get_header_rec_csr
	(
		p_mc_header_id in number
	)
	IS
	SELECT	MC_HEADER_ID,
		NAME,
		MC_ID,
		VERSION_NUMBER,
		REVISION,
		MODEL_CODE, -- SATHAPLI::Enigma code changes, 26-Aug-2008
		CONFIG_STATUS_CODE,
		SECURITY_GROUP_ID,
		ATTRIBUTE_CATEGORY,
		ATTRIBUTE1,
		ATTRIBUTE2,
		ATTRIBUTE3,
		ATTRIBUTE4,
		ATTRIBUTE5,
		ATTRIBUTE6,
		ATTRIBUTE7,
		ATTRIBUTE8,
		ATTRIBUTE9,
		ATTRIBUTE10,
		ATTRIBUTE11,
		ATTRIBUTE12,
		ATTRIBUTE13,
		ATTRIBUTE14,
		ATTRIBUTE15,
		DESCRIPTION
	FROM 	AHL_MC_HEADERS_VL
	WHERE 	MC_HEADER_ID = p_mc_header_id;

	-- 2.	Define get_topnode_rec_csr to get the details of the topnode record for a particular MC
	CURSOR get_topnode_rec_csr
	(
		p_mc_header_id in number
	)
	IS
	SELECT	RELATIONSHIP_ID,
		POSITION_KEY,
		ITEM_GROUP_ID,
		GROUP_NAME,
		POSITION_REF_CODE,
		POSITION_REF_MEANING,
		POSITION_NECESSITY_CODE,
		POSITION_NECESSITY_MEANING,
		-- Priyan : Bug # 5639027
		ATA_CODE,
		ATA_MEANING,
		-- End Priyan : Bug # 5639027
		UOM_CODE,
		QUANTITY,
		DISPLAY_ORDER,
		ACTIVE_START_DATE,
		ACTIVE_END_DATE,
		SECURITY_GROUP_ID,
		ATTRIBUTE_CATEGORY,
		ATTRIBUTE1,
		ATTRIBUTE2,
		ATTRIBUTE3,
		ATTRIBUTE4,
		ATTRIBUTE5,
		ATTRIBUTE6,
		ATTRIBUTE7,
		ATTRIBUTE8,
		ATTRIBUTE9,
		ATTRIBUTE10,
		ATTRIBUTE11,
		ATTRIBUTE12,
		ATTRIBUTE13,
		ATTRIBUTE14,
		ATTRIBUTE15
	FROM 	AHL_MC_RELATIONSHIPS_V
	WHERE 	MC_HEADER_ID = p_mc_header_id AND
	      	PARENT_RELATIONSHIP_ID IS NULL;

	-- Define cursor check_latest_rev to validate latest revision of MC being used for copying
	CURSOR check_latest_rev
	(
		p_mc_id in number,
		p_version_number in number
	)
	IS
		SELECT 	'x'
		FROM 	ahl_mc_headers_b
		WHERE 	mc_id = p_mc_id AND
			nvl(version_number, 0) > nvl(p_version_number, 0);

	-- 2.	Define local variables
	l_api_name	CONSTANT	VARCHAR2(30)	:= 'Create_MC_Revision';
	l_api_version	CONSTANT	NUMBER		:= 1.0;
	l_return_status			VARCHAR2(1);
	l_msg_count         		NUMBER;
	l_msg_data          		VARCHAR2(2000);

	l_old_mc_header_id 		NUMBER;
	l_header_rec 			get_header_rec_csr%ROWTYPE;
	l_mc_header_rec 		Header_Rec_Type;
	l_old_node_id 			NUMBER;
	l_topnode_rec 			get_topnode_rec_csr%ROWTYPE;
	l_node_rec 			AHL_MC_Node_PVT.Node_Rec_Type;

BEGIN

	-- Standard start of API savepoint
	SAVEPOINT Create_MC_Revision_SP;

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

	Validate_MC_Exists (p_x_mc_header_id, nvl(p_object_ver_num, 0));

	OPEN get_header_rec_csr(p_x_mc_header_id);
	FETCH get_header_rec_csr INTO l_header_rec;
	CLOSE get_header_rec_csr;

	l_old_mc_header_id := p_x_mc_header_id;

	-- 7.	Validate l_header_rec.config_status_code = 'COMPLETE'
	IF (l_header_rec.config_status_code <> 'COMPLETE')
	THEN
		FND_MESSAGE.Set_Name('AHL', 'AHL_MC_REV_STS_INV');
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

	-- 8.	Validate latest revision of MC being used for copying
	OPEN check_latest_rev (l_header_rec.mc_id, l_header_rec.version_number);
	FETCH check_latest_rev INTO l_dummy_varchar;
	IF (check_latest_rev%FOUND)
	THEN
		FND_MESSAGE.Set_Name('AHL', 'AHL_MC_NOT_LATEST_REV');
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

	-- Check Error Message stack.
	x_msg_count := FND_MSG_PUB.count_msg;
	IF x_msg_count > 0 THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

  	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
			'Header validation successful'
		);
	END IF;

	-- 9.	Set values for l_mc_header_rec
  	l_mc_header_rec.mc_header_id := null;
  	l_mc_header_rec.object_version_number := 1;
  	l_mc_header_rec.mc_id := nvl(l_header_rec.mc_id, l_header_rec.mc_header_id);
  	l_mc_header_rec.version_number := nvl(l_header_rec.version_number, 0) + 1;
  	l_mc_header_rec.revision := null;
	l_mc_header_rec.model_code := l_header_rec.model_code; -- SATHAPLI::Enigma code changes, 26-Aug-2008
  	l_mc_header_rec.config_status_code := 'DRAFT';
  	l_mc_header_rec.name := l_header_rec.name;
  	l_mc_header_rec.description := l_header_rec.description;
  	l_mc_header_rec.security_group_id := l_header_rec.security_group_id;
  	l_mc_header_rec.attribute_category := l_header_rec.attribute_category;
  	l_mc_header_rec.attribute1 := l_header_rec.attribute1;
  	l_mc_header_rec.attribute2 := l_header_rec.attribute2;
  	l_mc_header_rec.attribute3 := l_header_rec.attribute3;
  	l_mc_header_rec.attribute4 := l_header_rec.attribute4;
  	l_mc_header_rec.attribute5 := l_header_rec.attribute5;
  	l_mc_header_rec.attribute6 := l_header_rec.attribute6;
  	l_mc_header_rec.attribute7 := l_header_rec.attribute7;
  	l_mc_header_rec.attribute8 := l_header_rec.attribute8;
  	l_mc_header_rec.attribute9 := l_header_rec.attribute9;
  	l_mc_header_rec.attribute10 := l_header_rec.attribute10;
  	l_mc_header_rec.attribute11 := l_header_rec.attribute11;
  	l_mc_header_rec.attribute12 := l_header_rec.attribute12;
  	l_mc_header_rec.attribute13 := l_header_rec.attribute13;
  	l_mc_header_rec.attribute14 := l_header_rec.attribute14;
  	l_mc_header_rec.attribute15 := l_header_rec.attribute15;
  	l_mc_header_rec.operation_flag := G_DML_CREATE;

  	OPEN get_topnode_rec_csr(l_old_mc_header_id);
  	FETCH get_topnode_rec_csr INTO l_topnode_rec;
  	CLOSE get_topnode_rec_csr;

  	l_old_node_id := l_topnode_rec.relationship_id;

  	-- 13.	Set values for l_node_rec
  	l_node_rec.mc_header_id := null;
  	l_node_rec.object_version_number := 1;
  	l_node_rec.parent_relationship_id := null;
  	l_node_rec.position_key := l_topnode_rec.position_key;
  	l_node_rec.position_ref_code := l_topnode_rec.position_ref_code;
  	l_node_rec.position_ref_meaning := l_topnode_rec.position_ref_meaning;
  	l_node_rec.position_necessity_code := l_topnode_rec.position_necessity_code;
  	l_node_rec.position_necessity_meaning := l_topnode_rec.position_necessity_meaning;
	-- Priyan : Bug # 5639027
	l_node_rec.ata_code := l_topnode_rec.ata_code;
  	l_node_rec.ata_meaning := l_topnode_rec.ata_meaning;
	-- End Priyan : Bug # 5639027
  	l_node_rec.uom_code := l_topnode_rec.uom_code;
  	l_node_rec.quantity := l_topnode_rec.quantity;
  	l_node_rec.display_order := l_topnode_rec.display_order;
  	l_node_rec.item_group_id := l_topnode_rec.item_group_id;
  	l_node_rec.item_group_name := l_topnode_rec.group_name;
  	l_node_rec.active_start_date := l_topnode_rec.active_start_date;
  	l_node_rec.active_end_date := l_topnode_rec.active_end_date;
  	l_node_rec.security_group_id := l_topnode_rec.security_group_id;
  	l_node_rec.attribute_category := l_topnode_rec.attribute_category;
  	l_node_rec.attribute1 := l_topnode_rec.attribute1;
  	l_node_rec.attribute2 := l_topnode_rec.attribute2;
  	l_node_rec.attribute3 := l_topnode_rec.attribute3;
  	l_node_rec.attribute4 := l_topnode_rec.attribute4;
  	l_node_rec.attribute5 := l_topnode_rec.attribute5;
  	l_node_rec.attribute6 := l_topnode_rec.attribute6;
  	l_node_rec.attribute7 := l_topnode_rec.attribute7;
  	l_node_rec.attribute8 := l_topnode_rec.attribute8;
  	l_node_rec.attribute9 := l_topnode_rec.attribute9;
  	l_node_rec.attribute10 := l_topnode_rec.attribute10;
  	l_node_rec.attribute11 := l_topnode_rec.attribute11;
  	l_node_rec.attribute12 := l_topnode_rec.attribute12;
  	l_node_rec.attribute13 := l_topnode_rec.attribute13;
  	l_node_rec.attribute14 := l_topnode_rec.attribute14;
  	l_node_rec.attribute15 := l_topnode_rec.attribute15;
  	l_node_rec.operation_flag := G_DML_COPY;
  	l_node_rec.parent_node_rec_index := null;

  	-- 14.	Call AHL_MC_MasterConfig_PVT.Create_Master_Config
  	AHL_MC_MasterConfig_PVT.Create_Master_Config
	(
		p_api_version 		=> 1.0,
		p_init_msg_list 	=> FND_API.G_FALSE,
		p_commit 		=> FND_API.G_FALSE,
		p_validation_level 	=> FND_API.G_VALID_LEVEL_FULL,
		x_return_status 	=> l_return_status,
		x_msg_count 		=> l_msg_count,
		x_msg_data 		=> l_msg_data,
		p_x_mc_header_rec 	=> l_mc_header_rec,
		p_x_node_rec 		=> l_node_rec
	);

	-- Check Error Message stack.
	x_msg_count := FND_MSG_PUB.count_msg;
	IF x_msg_count > 0 THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
			'Header ['||l_mc_header_rec.mc_header_id||'] and topnode ['||l_node_rec.relationship_id||'] created'
		);
	END IF;

	-- 15.	Set p_x_mc_header_id := l_header_rec.mc_header_id, to return the header-id of the created MC
	p_x_mc_header_id := l_mc_header_rec.mc_header_id;

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
			'Copying documents from topnode ['||l_old_node_id||'] to topnode ['||l_node_rec.relationship_id||']'
		);
	END IF;

	-- 16.	Copy all documents associated with the topnode
	AHL_DI_ASSO_DOC_GEN_PVT.COPY_ASSOCIATION
	(
		p_api_version         	=> 1.0,
		p_commit              	=> FND_API.G_FALSE,
		p_validation_level    	=> FND_API.G_VALID_LEVEL_FULL,
		p_from_object_id      	=> l_old_node_id,
		p_from_object_type    	=> 'MC',
		p_to_object_id        	=> l_node_rec.relationship_id,
		p_to_object_type      	=> 'MC',
		x_return_status       	=> l_return_status,
		x_msg_count           	=> l_msg_count,
		x_msg_data            	=> l_msg_data
	);

	-- Check Error Message stack.
	x_msg_count := FND_MSG_PUB.count_msg;
	IF x_msg_count > 0 THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
			'Copying nodes'
		);
	END IF;

	-- 17.	Copy all other child nodes to the topnode of the source MC
	AHL_MC_Node_PVT.Copy_MC_Nodes
	(
		p_api_version 		=> 1.0,
		p_init_msg_list 	=> FND_API.G_FALSE,
		p_commit 		=> FND_API.G_FALSE,
		p_validation_level 	=> FND_API.G_VALID_LEVEL_FULL,
		x_return_status 	=> l_return_status,
		x_msg_count 		=> l_msg_count,
		x_msg_data 		=> l_msg_data,
		p_source_rel_id 	=> l_old_node_id,
		p_dest_rel_id 		=> l_node_rec.relationship_id,
		p_new_rev_flag 		=> FALSE,
		p_node_copy		=> FALSE
	);

	-- Check Error Message stack.
	x_msg_count := FND_MSG_PUB.count_msg;
	IF x_msg_count > 0 THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
			'Copying position paths'
		);
	END IF;

	-- 18.	Copy position paths from the old MC to the new MC
	AHL_MC_PATH_POSITION_PVT.Copy_Positions_For_MC
	(
		p_api_version 		=> 1.0,
		p_init_msg_list 	=> FND_API.G_FALSE,
		p_commit 		=> FND_API.G_FALSE,
		p_validation_level 	=> FND_API.G_VALID_LEVEL_FULL,
		x_return_status 	=> l_return_status,
		x_msg_count 		=> l_msg_count,
		x_msg_data 		=> l_msg_data,
		p_from_mc_header_id 	=> l_old_mc_header_id,
		p_to_mc_header_id 	=> p_x_mc_header_id
	);

	-- Check Error Message stack.
	x_msg_count := FND_MSG_PUB.count_msg;
	IF x_msg_count > 0 THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
			'Copying rules'
		);
	END IF;

	-- 12.	Copy rules from the old MC to the new MC
	AHL_MC_RULE_PVT.Copy_Rules_For_MC
	(
		p_api_version 		=> 1.0,
		p_init_msg_list 	=> FND_API.G_FALSE,
		p_commit 		=> FND_API.G_FALSE,
		p_validation_level 	=> FND_API.G_VALID_LEVEL_FULL,
		x_return_status 	=> l_return_status,
		x_msg_count 		=> l_msg_count,
		x_msg_data 		=> l_msg_data,
		p_from_mc_header_id 	=> l_old_mc_header_id,
		p_to_mc_header_id 	=> p_x_mc_header_id
	);

	-- Check Error Message stack.
	x_msg_count := FND_MSG_PUB.count_msg;
	IF x_msg_count > 0 THEN
		RAISE FND_API.G_EXC_ERROR;
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
		Rollback to Create_MC_Revision_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to Create_MC_Revision_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to Create_MC_Revision_SP;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.add_exc_msg
			(
				p_pkg_name		=> G_PKG_NAME,
				p_procedure_name 	=> 'Create_MC_Revision',
				p_error_text     	=> SUBSTR(SQLERRM,1,240)
			);
		END IF;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

END Create_MC_Revision;

PROCEDURE Reopen_Master_Config
(
	p_api_version		IN 		NUMBER,
	p_init_msg_list       	IN 		VARCHAR2	:= FND_API.G_FALSE,
	p_commit              	IN 		VARCHAR2 	:= FND_API.G_FALSE,
	p_validation_level    	IN 		NUMBER 		:= FND_API.G_VALID_LEVEL_FULL,
	x_return_status       	OUT 	NOCOPY  VARCHAR2,
	x_msg_count           	OUT 	NOCOPY  NUMBER,
	x_msg_data            	OUT 	NOCOPY  VARCHAR2,
	p_mc_header_id     	IN		NUMBER,
	p_object_ver_num        IN 		NUMBER
)
IS
	-- Define cursor get_mc_details to read details of the MC
	CURSOR get_mc_details
	(
		p_mc_header_id in number
	)
	IS
		SELECT 	mch.config_status_code,
			mcr.relationship_id,
			mcr.object_version_number,
			mcr.item_group_id
		FROM 	ahl_mc_headers_v mch,
			ahl_mc_relationships mcr
		WHERE 	mch.mc_header_id = p_mc_header_id AND
			mch.mc_header_id = mcr.mc_header_id AND
			mcr.parent_relationship_id IS NULL;

	-- Define get_mc_topnode_details to read the details of the MC topnode
	CURSOR get_mc_topnode_details
	(
		p_mc_header_id in number
	)
	IS
		SELECT 	relationship_id, object_version_number
		FROM 	ahl_mc_relationships
		WHERE 	mc_header_id = p_mc_header_id AND
			parent_relationship_id IS NULL;

	-- Define get_topnode_item_group to retrieve the item group details of the top node
	CURSOR get_topnode_itemgroup
	(
		p_item_group_id in number
	)
	IS
		SELECT 	status_code,object_version_number
		FROM 	ahl_item_groups_b igp
		WHERE 	item_group_id = p_item_group_id;

	-- Define cursor get_mc_status to retrieve the old/actual status of expired MCs
	CURSOR get_mc_status
	(
		p_mc_header_id in number
	)
	IS
		SELECT config_status_code
		FROM ahl_mc_headers_b
		WHERE mc_header_id = p_mc_header_id;

	-- 1.	Define local variables
	l_api_name	CONSTANT	VARCHAR2(30)	:= 'Reopen_Master_Config';
	l_api_version	CONSTANT	NUMBER		:= 1.0;
	l_return_status			VARCHAR2(1);
	l_msg_count         		NUMBER;
	l_msg_data          		VARCHAR2(2000);

	l_config_status_code		VARCHAR2(30);
	l_topnode_rel_id		NUMBER;
	l_topnode_object_ver_num	NUMBER;

	-- added for item group validation
	l_item_group_status		VARCHAR2(30);
	l_item_group_id 		NUMBER;
	l_igp_object_ver_num	NUMBER;

BEGIN

	-- Standard start of API savepoint
	SAVEPOINT Reopen_Master_Config_SP;

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

	-- 2.	Validate a MC with mc_header_id = p_mc_header_id exists, and object_version_number = p_object_ver_num
	Validate_MC_Exists (p_mc_header_id, nvl(p_object_ver_num, 0));

	-- 3.	Query for the config_status_code, active_end_date of the MC with mc_header_id = p_mc_header_id
	-- Query for the topnode details of the MC
	OPEN get_mc_details (p_mc_header_id);
	FETCH get_mc_details INTO l_config_status_code, l_topnode_rel_id, l_topnode_object_ver_num,l_item_group_id;
	CLOSE get_mc_details;

	IF NOT (l_config_status_code IN ('CLOSED', 'EXPIRED'))
	THEN
		FND_MESSAGE.Set_Name('AHL', 'AHL_MC_REOPEN_INV_MC');
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
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_config_status_code = 'CLOSED')
	THEN
		l_config_status_code := 'COMPLETE';
	ELSE
		OPEN get_mc_status(p_mc_header_id);
		FETCH get_mc_status INTO l_config_status_code;
		CLOSE get_mc_status;
	END IF;

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
			'Header validation successful'
		);
	END IF;

	--  added by anraj to fix bug number 3908014
	-- Check whether the Item Group of the Top node is removed
	-- if Removed then Re-open the Item Group.
	OPEN get_topnode_itemgroup(l_item_group_id);
	FETCH get_topnode_itemgroup INTO l_item_group_status,l_igp_object_ver_num;
	IF (get_topnode_itemgroup%NOTFOUND) THEN
		FND_MESSAGE.Set_Name('AHL', 'AHL_MC_ITEMGROUP_INVALID');
		--FND_MESSAGE.Set_Token('ITEM_GRP', l_item_group_name);
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
		RAISE FND_API.G_EXC_ERROR;
	ELSE
		IF(l_item_group_status = 'REMOVED') THEN
  			UPDATE ahl_item_groups_b
    		SET  status_code ='COMPLETE',
        		object_version_number = object_version_number +1
   			WHERE item_group_id = l_item_group_id;
   		END IF;
   	END IF;



	-- 4.	Reopen the MC header
	UPDATE 	ahl_mc_headers_b
	SET 	config_status_code = l_config_status_code,
	    	object_version_number = p_object_ver_num + 1,
		last_update_date = G_SYSDATE,
		last_updated_by = G_USER_ID,
		last_update_login = G_LOGIN_ID
	WHERE 	mc_header_id = p_mc_header_id;

	-- 5.	Update the topnode of the MC
	UPDATE 	ahl_mc_relationships
	SET	active_end_date = null,
		object_version_number = l_topnode_object_ver_num + 1,
		last_update_date = G_SYSDATE,
		last_updated_by = G_USER_ID,
		last_update_login = G_LOGIN_ID
	WHERE 	relationship_id = l_topnode_rel_id;

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
			'Header ['||p_mc_header_id||'] and topnode ['||l_topnode_rel_id||'] reopened'
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
		Rollback to Reopen_Master_Config_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to Reopen_Master_Config_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to Reopen_Master_Config_SP;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.add_exc_msg
			(
				p_pkg_name		=> G_PKG_NAME,
				p_procedure_name 	=> 'Reopen_Master_Config',
				p_error_text     	=> SUBSTR(SQLERRM,1,240)
			);
		END IF;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

END Reopen_Master_Config;

PROCEDURE Initiate_MC_Approval
(
	p_api_version		IN 		NUMBER,
	p_init_msg_list       	IN 		VARCHAR2	:= FND_API.G_FALSE,
	p_commit              	IN 		VARCHAR2 	:= FND_API.G_FALSE,
	p_validation_level    	IN 		NUMBER 		:= FND_API.G_VALID_LEVEL_FULL,
	x_return_status       	OUT 	NOCOPY  VARCHAR2,
	x_msg_count           	OUT 	NOCOPY  NUMBER,
	x_msg_data            	OUT 	NOCOPY  VARCHAR2,
	p_mc_header_id     	IN		NUMBER,
	p_object_ver_num        IN 		NUMBER
)
IS

	-- 1.	Define local variables
	l_api_name	CONSTANT	VARCHAR2(30)	:= 'Initiate_MC_Approval';
	l_api_version	CONSTANT	NUMBER		:= 1.0;
	l_return_status			VARCHAR2(1);
	l_msg_count         		NUMBER;
	l_msg_data          		VARCHAR2(2000);

	l_config_status_code 		VARCHAR2(30);
	l_object_version_number		NUMBER;
	l_active			VARCHAR2(1);
	l_process_name      		VARCHAR2(30);
	l_item_type         		VARCHAR2(8);

BEGIN

	-- Standard start of API savepoint
	SAVEPOINT Initiate_MC_Approval_SP;

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

	Validate_MC_Exists(p_mc_header_id, nvl(p_object_ver_num, 0));

	-- Check for status = draft / approval rejected
	l_config_status_code := Get_MC_Status(p_mc_header_id);
	IF NOT (l_config_status_code IN ('DRAFT', 'APPROVAL_REJECTED'))
	THEN
		FND_MESSAGE.Set_Name('AHL', 'AHL_MC_WF_STS_INVALID');
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
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
			'Header validation successful'
		);
	END IF;

	-- 4.	Call Check_MC_Complete to validate all itemgroup and subconfiguration associations are complete
	Check_MC_Complete (p_mc_header_id);

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
			'Check for MC completion is successful'
		);
	END IF;

	-- Check Error Message stack.
	x_msg_count := FND_MSG_PUB.count_msg;
	IF x_msg_count > 0
	THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	-- No need to check for any profile option for enabled/disabled workflow

	-- 5a.	Retrieve the workflow process name for object 'MC'
	ahl_utility_pvt.get_wf_process_name
	(
		p_object 	=> 'MC',
		x_active 	=> l_active,
		x_process_name 	=> l_process_name ,
		x_item_type 	=> l_item_type,
		x_return_status => l_return_status,
		x_msg_count 	=> l_msg_count,
		x_msg_data 	=> l_msg_data
	);

	-- Check Error Message stack.
	x_msg_count := FND_MSG_PUB.count_msg;
	IF x_msg_count > 0 THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	IF (l_active = 'Y')
	THEN
		-- 5b.	If workflow is active
		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_statement,
				'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
				'MC Approval workflow process is active'
			);
		END IF;

		-- 54b.i. Update the status and object_version_number of the MC header record
		UPDATE 	ahl_mc_headers_b
		SET	config_status_code = 'APPROVAL_PENDING',
			object_version_number = p_object_ver_num + 1,
			last_update_date = G_SYSDATE,
			last_updated_by = G_USER_ID,
			last_update_login = G_LOGIN_ID
		WHERE	mc_header_id = p_mc_header_id AND
			object_version_number = p_object_ver_num;

		-- 5b.ii. Start the 'MC' approval process for this MC
		ahl_generic_aprv_pvt.start_wf_process
		(
			P_OBJECT                => 'MC',
			P_ACTIVITY_ID           => p_mc_header_id,
			P_APPROVAL_TYPE         => 'CONCEPT',
			P_OBJECT_VERSION_NUMBER => p_object_ver_num + 1,
			P_ORIG_STATUS_CODE      => 'DRAFT',
			P_NEW_STATUS_CODE       => 'COMPLETE',
			P_REJECT_STATUS_CODE    => 'APPROVAL_REJECTED',
			P_REQUESTER_USERID      => G_USER_ID,
			P_NOTES_FROM_REQUESTER  => null,
			P_WORKFLOWPROCESS       => l_process_name,
			P_ITEM_TYPE             => l_item_type
		);

		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_statement,
				'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
				'Approval process for MC ['||p_mc_header_id||', '||to_char(p_object_ver_num + 1)||'] has been started'
			);
		END IF;
	ELSE
		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_statement,
				'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
				'MC Approval workflow process is inactive'
			);
		END IF;

		-- If wortkflow process is inactive, then force complete the MC
		UPDATE 	ahl_mc_headers_b
		SET	config_status_code = 'COMPLETE',
			object_version_number = p_object_ver_num + 1,
			last_update_date = G_SYSDATE,
			last_updated_by = G_USER_ID,
			last_update_login = G_LOGIN_ID
		WHERE	mc_header_id = p_mc_header_id AND
			object_version_number = p_object_ver_num;
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
		Rollback to Initiate_MC_Approval_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to Initiate_MC_Approval_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to Initiate_MC_Approval_SP;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.add_exc_msg
			(
				p_pkg_name		=> G_PKG_NAME,
				p_procedure_name 	=> 'Initiate_MC_Approval',
				p_error_text     	=> SUBSTR(SQLERRM,1,240)
			);
		END IF;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

END Initiate_MC_Approval;

---------------------------
-- Validation procedures --
---------------------------
PROCEDURE Validate_MC_Exists
(
	p_mc_header_id in number,
	p_object_ver_num in number
)
IS

	CURSOR check_mc_exists
	(
		p_mc_header_id in number
	)
	IS
		SELECT 	object_version_number
		FROM 	ahl_mc_headers_b
		WHERE 	mc_header_id = p_mc_header_id;

BEGIN

	OPEN check_mc_exists (p_mc_header_id);
	FETCH check_mc_exists INTO l_dummy_number;
	IF (check_mc_exists%NOTFOUND)
	THEN
		FND_MESSAGE.Set_Name('AHL','AHL_MC_NOT_FOUND');
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.'||G_PKG_NAME||'.Validate_MC_Exists',
				false
			);
		END IF;
		CLOSE check_mc_exists;
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (NVL(p_object_ver_num, l_dummy_number) <> l_dummy_number)
	THEN
		FND_MESSAGE.Set_Name('AHL', 'AHL_COM_RECORD_CHANGED');
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.'||G_PKG_NAME||'.Validate_MC_Exists',
				false
			);
		END IF;
		CLOSE check_mc_exists;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
	CLOSE check_mc_exists;

END Validate_MC_Exists;

-- Define procedure Validate_MC_Name to check uniqueness / non-update of the user-entered MC name
PROCEDURE Validate_MC_Name
(
	p_x_mc_header_rec in Header_Rec_Type
)
IS

	CURSOR check_mc_name_unique
	(
		p_mc_name in varchar2
	)
	IS
		SELECT 	'x'
		FROM 	ahl_mc_headers_b
		WHERE 	upper(name) = upper(p_mc_name);

	CURSOR check_mc_name_noupdate
	(
		p_mc_header_id in number
	)
	IS
		SELECT 	name
		FROM 	ahl_mc_headers_b
		WHERE 	mc_header_id = p_mc_header_id;

	l_dummy_name	VARCHAR2(80);
BEGIN

	-- Confirm user has entered MC Name, since it is mandatory
	IF (RTRIM(p_x_mc_header_rec.name) IS NULL)
	THEN
		FND_MESSAGE.Set_Name('AHL','AHL_MC_NAME_INVALID');
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.'||G_PKG_NAME||'.Validate_MC_Name',
				false
			);
		END IF;
	ELSE
		IF (p_x_mc_header_rec.mc_header_id IS NULL)
		THEN
			-- Implies MC is being created, check name uniqueness
			OPEN check_mc_name_unique (p_x_mc_header_rec.name);
			FETCH check_mc_name_unique INTO l_dummy_varchar;
			IF (check_mc_name_unique%FOUND)
			THEN
				FND_MESSAGE.Set_Name('AHL','AHL_MC_RNAME_EXISTS');
				FND_MSG_PUB.ADD;
				IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
				THEN
					fnd_log.message
					(
						fnd_log.level_exception,
						'ahl.plsql.'||G_PKG_NAME||'.Validate_MC_Name',
						false
					);
				END IF;
			END IF;
			CLOSE check_mc_name_unique;
		ELSE
			-- Implies MC is being updated, check name is not updated
			OPEN check_mc_name_noupdate(p_x_mc_header_rec.mc_header_id);
			FETCH check_mc_name_noupdate INTO l_dummy_name;
			IF (l_dummy_name <> p_x_mc_header_rec.name)
			THEN
				FND_MESSAGE.Set_Name('AHL', 'AHL_MC_RNAME_NOUPDATE');
				FND_MSG_PUB.ADD;
				IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
				THEN
					fnd_log.message
					(
						fnd_log.level_exception,
						'ahl.plsql.'||G_PKG_NAME||'.Validate_MC_Name',
						false
					);
				END IF;
			END IF;
			CLOSE check_mc_name_noupdate;
		END IF;
	END IF;

END Validate_MC_Name;

-- Define procedure Validate_MC_Revision to check for uniqueness of the MC revision
PROCEDURE Validate_MC_Revision
(
	p_x_mc_header_rec in Header_Rec_Type
)
IS

	CURSOR check_mc_revision_unique
	(
		p_mc_header_id in number,
		p_mc_revision in varchar2,
		p_mc_id in number
	)
	IS
		SELECT 	'x'
		FROM 	ahl_mc_headers_b
		WHERE 	upper(revision) = upper(p_mc_revision) AND
			mc_id = p_mc_id and
			mc_header_id <> p_mc_header_id;

	CURSOR get_mc_revision
	(
		p_mc_header_id in number
	)
	IS
		SELECT revision
		FROM ahl_mc_headers_b
		WHERE mc_header_id = p_mc_header_id;

	l_ret_val	BOOLEAN;
	l_dummy_rev	VARCHAR2(30);
	l_str_len	NUMBER;
	l_temp_num	NUMBER;

BEGIN

	IF (RTRIM(p_x_mc_header_rec.revision) IS NOT NULL)
	THEN
		-- p_x_mc_header_rec.mc_id = p_x_mc_header_rec.mc_header_id for the first draft of the MC
		IF (p_x_mc_header_rec.mc_id <> p_x_mc_header_rec.mc_header_id)
		THEN
			-- Confirm it is unique across all revisions of the same MC
			OPEN check_mc_revision_unique (p_x_mc_header_rec.mc_header_id, p_x_mc_header_rec.revision, p_x_mc_header_rec.mc_id);
			FETCH check_mc_revision_unique INTO l_dummy_varchar;
			IF (check_mc_revision_unique%FOUND)
			THEN
				FND_MESSAGE.Set_Name('AHL','AHL_MC_REV_EXISTS');
				FND_MSG_PUB.ADD;
				IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
				THEN
					fnd_log.message
					(
						fnd_log.level_exception,
						'ahl.plsql.'||G_PKG_NAME||'.Validate_MC_Revision',
						false
					);
				END IF;
			END IF;
			CLOSE check_mc_revision_unique;
		END IF;

		OPEN get_mc_revision(p_x_mc_header_rec.mc_header_id);
		FETCH get_mc_revision INTO l_dummy_rev;
		CLOSE get_mc_revision;

		-- Confirm that the revision is user-entered and not the same as in the DB (it may be populated
		-- through the backend and is typically a number)
		IF (nvl(l_dummy_rev, -1) <> p_x_mc_header_rec.revision)
		THEN
			-- Confirm that the user-entered revision has atleast one alphabetic character
			BEGIN
				l_str_len := LENGTH(p_x_mc_header_rec.revision);

				-- There should be something faster than the following iterative approach
				FOR i IN 1..l_str_len
				LOOP
					SELECT TO_NUMBER(SUBSTR(p_x_mc_header_rec.revision,i,1)) INTO l_temp_num FROM DUAL;
				END LOOP;

				FND_MESSAGE.Set_Name('AHL','AHL_MC_NO_ALPHA_REV');
				FND_MSG_PUB.ADD;
				IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
				THEN
					fnd_log.message
					(
						fnd_log.level_exception,
						'ahl.plsql.'||G_PKG_NAME||'.Validate_MC_Revision',
						false
					);
				END IF;

			EXCEPTION
				WHEN INVALID_NUMBER THEN
					NULL;
			END;
		END IF;
	END IF;

END Validate_MC_Revision;

-------------------------
-- Non-spec Procedures --
-------------------------
FUNCTION Get_MC_Status
(
	p_mc_header_id in number
)
RETURN VARCHAR2
IS
	CURSOR get_mc_status
	IS
		SELECT 	config_status_code
		FROM 	ahl_mc_headers_v
		WHERE	mc_header_id = p_mc_header_id;

	l_status	VARCHAR2(30);

BEGIN

	IF (p_mc_header_id IS NOT NULL)
	THEN
		OPEN get_mc_status;
		FETCH get_mc_status INTO l_status;
		IF (get_mc_status%NOTFOUND)
		THEN
			FND_MESSAGE.Set_Name('AHL','AHL_MC_NOT_FOUND');
			FND_MSG_PUB.ADD;
			IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.message
				(
					fnd_log.level_exception,
					'ahl.plsql.'||G_PKG_NAME||'.Get_MC_Status',
					false
				);
			END IF;
			CLOSE get_mc_status;
			RAISE FND_API.G_EXC_ERROR;
		END IF;
		CLOSE get_mc_status;
	END IF;

	RETURN l_status;

END Get_MC_Status;

PROCEDURE Set_Header_Status
(
	p_mc_header_id IN NUMBER
)
IS

	-- 1.	Define cursor get_mc_header_status to read status of the MC header
	CURSOR get_mc_header_status
	(
		p_mc_header_id in number
	)
	IS
		SELECT config_status_code
		FROM ahl_mc_headers_b
		WHERE mc_header_id = p_mc_header_id;

	-- 2.	Define local variables
	l_status 	VARCHAR2(30) := 'DRAFT';

BEGIN

	OPEN get_mc_header_status(p_mc_header_id);
	FETCH get_mc_header_status INTO l_status;

	-- 5.	If (record is found and l_status = 'APPROVAL_REJECTED'), then Update config_status_code = 'DRAFT'
	IF (get_mc_header_status%FOUND)
	THEN
		IF (l_status = 'APPROVAL_REJECTED')
		THEN
			UPDATE ahl_mc_headers_b
			SET config_status_code = 'DRAFT'
			WHERE mc_header_id = p_mc_header_id;
		END IF;
	END IF;

	CLOSE get_mc_header_status;

END Set_Header_Status;

PROCEDURE Check_MC_Complete
(
	p_mc_header_id IN NUMBER
)
IS

	-- 1.	Define cursor get_mc_nodes_csr to read all nodes associated with a MC
	CURSOR get_mc_nodes_csr
	(
		p_mc_header_id IN NUMBER
	)
	IS
		SELECT relationship_id, position_ref_meaning, position_necessity_code
		FROM ahl_mc_relationships_v
		WHERE mc_header_id = p_mc_header_id;

	-- 2.	Define cursor get_node_subconfigs_csr to read details about MCs associated as subconfigs to a MC node
	CURSOR get_node_subconfigs_csr
	(
		p_relationship_id IN NUMBER
	)
	IS
		SELECT 	mch.name, mch.config_status_code
		FROM 	ahl_mc_config_relations mccr, ahl_mc_headers_b mch
		WHERE 	mccr.relationship_id = p_relationship_id AND
	      		mccr.mc_header_id = mch.mc_header_id;
	      		-- Since expired subconfig associations can be unexpired, so no need to filter on active_end_date
	      		-- AND trunc(nvl(mccr.active_end_date, G_SYSDATE + 1)) > G_TRUNC_DATE;

	-- 3.	Define get_node_itemgroups_csr to read details about itemgroups associated with a MC node
	CURSOR get_node_itemgroups_csr
	(
		p_relationship_id IN NUMBER
	)
	IS
		SELECT 	ig.item_group_id, ig.name, ig.type_code, ig.status_code
		FROM 	ahl_mc_relationships mcr, ahl_item_groups_b ig
		WHERE 	mcr.relationship_id = p_relationship_id AND
	      		ig.item_group_id = mcr.item_group_id;

	-- 4.	Define local variables
	l_relationship_id 	NUMBER;
	l_necessity_code 	VARCHAR2(30);
	l_posref_meaning 	VARCHAR2(80);
	l_mc_name 		VARCHAR2(80);
	l_mc_status 		VARCHAR2(30);
	l_item_group_id 	NUMBER;
	l_item_group_name 	VARCHAR2(80);
	l_item_group_type 	VARCHAR2(30);
	l_item_group_status 	VARCHAR2(30);
	l_has_itemgroup 	BOOLEAN := TRUE;
	l_has_subconfig		BOOLEAN := FALSE;
        l_return_status         VARCHAR2(1);
        l_msg_count             NUMBER;
        l_msg_data              VARCHAR2(2000);

BEGIN

	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.'||G_PKG_NAME||'.Check_MC_Complete.begin',
			'At the start of PLSQL procedure '||G_PKG_NAME||'.Check_MC_Complete'
		);
	END IF;

	OPEN get_mc_nodes_csr (p_mc_header_id);
	LOOP
		FETCH get_mc_nodes_csr INTO l_relationship_id, l_posref_meaning, l_necessity_code;
		EXIT WHEN get_mc_nodes_csr%NOTFOUND;

		-- Mark node with no itemgroup association
		l_has_itemgroup := FALSE;

		OPEN get_node_itemgroups_csr (l_relationship_id);
		LOOP
			FETCH get_node_itemgroups_csr INTO l_item_group_id, l_item_group_name, l_item_group_type, l_item_group_status;
			EXIT WHEN get_node_itemgroups_csr%NOTFOUND;

			-- Mark node with itemgroup association
			l_has_itemgroup := TRUE;

			-- Check itemgroup associated is complete
			IF (l_item_group_status <> 'COMPLETE')
			THEN
				FND_MESSAGE.Set_Name('AHL', 'AHL_MC_IG_NOT_COMP');
				FND_MESSAGE.Set_Token('IG_NAME', l_item_group_name);
				FND_MESSAGE.Set_Token('POS_REF', l_posref_meaning);
				FND_MSG_PUB.ADD;
				IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
				THEN
					fnd_log.message
					(
						fnd_log.level_exception,
						'ahl.plsql.'||G_PKG_NAME||'.Check_MC_Complete',
						false
					);
				END IF;
			END IF;
		END LOOP;
		CLOSE get_node_itemgroups_csr;

		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_statement,
				'ahl.plsql.'||G_PKG_NAME||'.Check_MC_Complete',
				'Item group validation done for Node ['||l_relationship_id||']'
			);
		END IF;

		-- Mark node with no subconfig association
		l_has_subconfig := FALSE;

		OPEN get_node_subconfigs_csr (l_relationship_id);
		LOOP
			FETCH get_node_subconfigs_csr INTO l_mc_name, l_mc_status;
			EXIT WHEN get_node_subconfigs_csr%NOTFOUND;

			-- Mark node with atleast one subconfig association
			l_has_subconfig := TRUE;

			-- Check subconfig associated is complete
			IF (l_mc_status <> 'COMPLETE')
			THEN
				FND_MESSAGE.Set_Name('AHL', 'AHL_MC_SUBMC_NOT_COMP');
				FND_MESSAGE.Set_Token('MC_NAME', l_mc_name);
				FND_MESSAGE.Set_Token('POS_REF', l_posref_meaning);
				FND_MSG_PUB.ADD;
				IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
				THEN
					fnd_log.message
					(
						fnd_log.level_exception,
						'ahl.plsql.'||G_PKG_NAME||'.Check_MC_Complete',
						false
					);
				END IF;
			END IF;
		END LOOP;
		CLOSE get_node_subconfigs_csr;

		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_statement,
				'ahl.plsql.'||G_PKG_NAME||'.Check_MC_Complete',
				'Subconfig validation done for Node ['||l_relationship_id||']'
			);
		END IF;

		IF (l_has_itemgroup = FALSE AND l_has_subconfig = FALSE)
		THEN
			FND_MESSAGE.Set_Name('AHL', 'AHL_MC_NODE_NO_ASSOS');
			FND_MESSAGE.Set_Token('POS_REF', l_posref_meaning);
			FND_MSG_PUB.ADD;
			IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.message
				(
					fnd_log.level_exception,
					'ahl.plsql.'||G_PKG_NAME||'.Check_MC_Complete',
					false
				);
			END IF;
		END IF;
	END LOOP;
	CLOSE get_mc_nodes_csr;

        -- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 04-Dec-2007
        -- Call the API AHL_MC_RULE_STMT_PVT.validate_quantity_rules_for_mc for Quantity Rule Validation
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string
          (
              fnd_log.level_statement,
              'ahl.plsql.'||G_PKG_NAME||'.Check_MC_Complete',
              'Calling API AHL_MC_RULE_STMT_PVT.validate_quantity_rules_for_mc for '||
              'Quantity Rule Validation for mc_header_id ['||p_mc_header_id||']'
          );
        END IF;

        -- Do not need to check for the status after API call, as we need only FND_MSG stack's validation errors.
        AHL_MC_RULE_STMT_PVT.validate_quantity_rules_for_mc
        (
            p_api_version           => 1.0,
            p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
            p_mc_header_id          => p_mc_header_id,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data
        );

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string
          (
              fnd_log.level_statement,
              'ahl.plsql.'||G_PKG_NAME||'.Check_MC_Complete',
              'Returned from calling API AHL_MC_RULE_STMT_PVT.validate_quantity_rules_for_mc for '||
              'Quantity Rule Validation for mc_header_id ['||p_mc_header_id||']'
          );
        END IF;

	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.'||G_PKG_NAME||'.Check_MC_Complete.end',
			'At the end of PLSQL procedure '||G_PKG_NAME||'.Check_MC_Complete'
		);
	END IF;

END Check_MC_Complete;

End AHL_MC_MasterConfig_PVT;

/
