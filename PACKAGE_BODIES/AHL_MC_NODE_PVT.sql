--------------------------------------------------------
--  DDL for Package Body AHL_MC_NODE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_MC_NODE_PVT" AS
/* $Header: AHLVNODB.pls 120.6.12010000.6 2010/03/25 07:31:55 sathapli ship $ */

G_USER_ID	CONSTANT	NUMBER		:= TO_NUMBER(FND_GLOBAL.USER_ID);
G_LOGIN_ID	CONSTANT	NUMBER		:= TO_NUMBER(FND_GLOBAL.LOGIN_ID);
G_SYSDATE	CONSTANT	DATE		:= SYSDATE;
G_TRUNC_DATE	CONSTANT	DATE		:= TRUNC(SYSDATE);

-------------------
-- Common variables
-------------------
l_dummy_varchar		VARCHAR2(1);
l_dummy_number		NUMBER;

--------------------
-- Common cursors --
--------------------
CURSOR check_uom_exists
(
	p_uom_code IN VARCHAR2
)
IS
	SELECT 'x'
	FROM  MTL_UNITS_OF_MEASURE
	WHERE uom_code = p_uom_code;

-------------------------------------
-- Validation procedure	signatures --
-------------------------------------
PROCEDURE Validate_Node_Exists
(
	p_rel_id in	number,
	p_object_ver_num in	number
);

PROCEDURE Validate_Node
(
	p_x_node_rec in	out	nocopy Node_Rec_Type
);

PROCEDURE Validate_Counter_Exists
(
	p_ctr_rule_id in number,
	p_object_ver_num in	number
);

PROCEDURE Validate_Counter_Rule
(
	p_counter_rule_rec in Counter_Rule_Rec_Type
);

PROCEDURE Validate_Subconfig_Exists
(
	p_submc_assos_id in	number,
	p_object_ver_num in	number
);

PROCEDURE Validate_priority
(
	p_subconfig_tbl	in Subconfig_Tbl_Type
);

/* Jerry commented out on 08/12/2004 because it	is never used
PROCEDURE Check_Cyclic_Rel
(
	p_subconfig_id in number,
	p_rel_id in	number
);
*/

-----------------------------------
-- Non-spec	Procedure Signatures --
-----------------------------------
FUNCTION Get_MC_Status
(
	p_rel_id in	number,
	p_mc_header_id in number
)
RETURN VARCHAR2;
-- check whether cyclic	relation exist
FUNCTION Cyclic_Relation_Exists
(
	p_subconfig_id in number,
	p_dest_config_id in	number
)
RETURN BOOLEAN;

PROCEDURE Set_Header_Status
(
	p_rel_id IN	NUMBER
);

PROCEDURE Create_Counter_Rule
(
	p_x_counter_rule_rec	IN OUT	NOCOPY	Counter_Rule_Rec_Type
);

PROCEDURE Modify_Counter_Rule
(
	p_x_counter_rule_rec	IN OUT	NOCOPY	Counter_Rule_Rec_Type
);

PROCEDURE Delete_Counter_Rule
(
	p_ctr_update_rule_id	IN		NUMBER,
	p_object_ver_num		IN		NUMBER
);

PROCEDURE Attach_Subconfig
(
	p_x_subconfig_rec	IN OUT	NOCOPY	Subconfig_Rec_Type
);

PROCEDURE Modify_Subconfig
(
	p_x_subconfig_rec	IN OUT	NOCOPY	Subconfig_Rec_Type
);

PROCEDURE Detach_Subconfig
(
	p_mc_config_relation_id	IN		NUMBER,
	p_object_ver_num	IN		NUMBER
);

PROCEDURE Copy_Subconfig
(
	p_source_rel_id			IN		NUMBER,
	p_dest_rel_id		IN		NUMBER
);

---------------------
-- Spec	Procedures --
---------------------
PROCEDURE Create_Node
(
	p_api_version		IN		NUMBER,
	p_init_msg_list			IN		VARCHAR2	:= FND_API.G_FALSE,
	p_commit				IN		VARCHAR2	:= FND_API.G_FALSE,
	p_validation_level		IN		NUMBER		:= FND_API.G_VALID_LEVEL_FULL,
	x_return_status			OUT		NOCOPY	VARCHAR2,
	x_msg_count				OUT		NOCOPY	NUMBER,
	x_msg_data				OUT		NOCOPY	VARCHAR2,
	p_x_node_rec			IN OUT	NOCOPY	Node_Rec_Type,
	p_x_counter_rules_tbl	IN OUT	NOCOPY	Counter_Rules_Tbl_Type,
	p_x_subconfig_tbl		IN OUT	NOCOPY	SubConfig_Tbl_Type
)
IS

	-- Define cursor check_dup_poskey to check for duplicate position key within same MC
	CURSOR check_dup_poskey
	IS
		SELECT	'x'
		FROM	ahl_mc_relationships
		WHERE	mc_header_id = p_x_node_rec.mc_header_id AND
				position_key = p_x_node_rec.position_key;
				-- Since expired nodes are also	copied,	so duplicate position key check	must happen	for	expired	nodes also
				-- AND G_TRUNC_DATE	< trunc(nvl(p_x_node_rec.active_end_date, G_SYSDATE	+ 1));

	-- Define local	variables
	l_api_name	CONSTANT	VARCHAR2(30)	:= 'Create_Node';
	l_api_version	CONSTANT	NUMBER		:= 1.0;
	l_return_status			VARCHAR2(1);
	l_msg_count					NUMBER;
	l_msg_data					VARCHAR2(2000);

	l_header_status			VARCHAR2(30);

BEGIN

	-- Standard	start of API savepoint
	SAVEPOINT Create_Node_SP;

	-- Standard	call to	check for call compatibility
	IF NOT FND_API.compatible_api_call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END	IF;

	-- Initialize message list if p_init_msg_list is set to	TRUE
	IF FND_API.TO_BOOLEAN(p_init_msg_list)
	THEN
		FND_MSG_PUB.Initialize;
	END	IF;

	-- Initialize API return status	to success
	x_return_status	:= FND_API.G_RET_STS_SUCCESS;

	-- API body	starts here
	IF (fnd_log.level_procedure	>= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||'.begin',
			'At	the	start of PLSQL procedure'
		);
	END	IF;

	-- 1a.	Validate config_status_code	of the MC is 'DRAFT' or	'APPROVAL_REJECTED'
	IF (p_x_node_rec.parent_relationship_id	IS NOT NULL)
	THEN
		l_header_status	:= Get_MC_Status(null, p_x_node_rec.mc_header_id);
		IF NOT (l_header_status	IN ('DRAFT', 'APPROVAL_REJECTED'))
		THEN
			FND_MESSAGE.Set_Name('AHL',	'AHL_MC_NODE_STS_INV');
			FND_MSG_PUB.ADD;
			IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.message
				(
					fnd_log.level_exception,
					'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
					false
				);
			END	IF;
			RAISE FND_API.G_EXC_ERROR;
		ELSIF (l_header_status = 'APPROVAL_REJECTED')
		THEN
			-- 1b.	Set	status of MC to	DRAFT if APPROVAL_REJECTED
			Set_Header_Status(p_x_node_rec.relationship_id);
		END	IF;
	END	IF;
	-- 2.	For	the	MC node	with relationship_id = p_x_node_rec.parent_relationship_id [parent node]
	-- 3a.	Validate p_x_node_rec.position_ref_code	exists
	-- 3b.	Validate p_x_node_rec.position_necessity_code
	-- 3c.	Validate p_x_node_rec.quantity > 0
	-- 3d.	Validate p_x_node_rec.uom_code exists
	-- 3e.	Validate p_x_node_rec.item_group_id	exists
	-- 3f.	Validate p_x_node_rec.display_order	> 0
	-- 3g.	Validate p_x_node_rec.display_order	is not equal to	display_order of all nodes at the same level
	-- Validate	dates
	-- 3m.	Validate the item_group	does not have any item association with	quantity > 1
	Validate_Node(p_x_node_rec);

	IF (p_x_node_rec.position_key IS NULL)
	THEN
		SELECT ahl_mc_rel_pos_key_s.nextval	INTO p_x_node_rec.position_key FROM	DUAL;
	ELSE
		-- 3j.i.	Validate p_x_node_rec.position_key is unique within	this MC
		OPEN check_dup_poskey;
		FETCH check_dup_poskey INTO	l_dummy_varchar;
		IF (check_dup_poskey%FOUND)
		THEN
			FND_MESSAGE.Set_Name('AHL',	'AHL_MC_DUP_POSKEY');
			FND_MESSAGE.Set_Token('POSREF',	p_x_node_rec.position_ref_meaning);
			FND_MSG_PUB.ADD;
			IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.message
				(
					fnd_log.level_exception,
					'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
					false
				);
			END	IF;
		END	IF;
		CLOSE check_dup_poskey;
	END	IF;

	-- Check Error Message stack.
	x_msg_count	:= FND_MSG_PUB.count_msg;
	IF x_msg_count > 0 THEN
		RAISE FND_API.G_EXC_ERROR;
	END	IF;

	IF (fnd_log.level_statement	>= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
			'Node validation successful'
		);
	END	IF;

	SELECT ahl_mc_relationships_s.nextval INTO p_x_node_rec.relationship_id	FROM DUAL;
	p_x_node_rec.object_version_number := 1;
	p_x_node_rec.security_group_id := null;

	-- 4.	Insert the node	record into	AHL_MC_RELATIONSHIPS table
	INSERT INTO	AHL_MC_RELATIONSHIPS
	(
		RELATIONSHIP_ID,
		POSITION_REF_CODE,
		PARENT_RELATIONSHIP_ID,
		ITEM_GROUP_ID,
		UOM_CODE,
		QUANTITY,
		DISPLAY_ORDER,
		POSITION_NECESSITY_CODE,
		POSITION_KEY,
		MC_HEADER_ID,
		ACTIVE_START_DATE,
		ACTIVE_END_DATE,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_LOGIN,
		OBJECT_VERSION_NUMBER,
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
		--R12
		--priyan MEL-CDL
		ATA_CODE
	)
	VALUES
	(
		p_x_node_rec.relationship_id,
		p_x_node_rec.position_ref_code,
		p_x_node_rec.parent_relationship_id,
		p_x_node_rec.item_group_id,
		p_x_node_rec.uom_code,
		p_x_node_rec.quantity,
		p_x_node_rec.display_order,
		p_x_node_rec.position_necessity_code,
		p_x_node_rec.position_key,
		p_x_node_rec.mc_header_id,
		TRUNC(p_x_node_rec.active_start_date),
		TRUNC(p_x_node_rec.active_end_date),
		G_SYSDATE,
		G_USER_ID,
		G_SYSDATE,
		G_USER_ID,
		G_LOGIN_ID,
		p_x_node_rec.object_version_number,
		p_x_node_rec.security_group_id,
		p_x_node_rec.attribute_category,
		p_x_node_rec.attribute1,
		p_x_node_rec.attribute2,
		p_x_node_rec.attribute3,
		p_x_node_rec.attribute4,
		p_x_node_rec.attribute5,
		p_x_node_rec.attribute6,
		p_x_node_rec.attribute7,
		p_x_node_rec.attribute8,
		p_x_node_rec.attribute9,
		p_x_node_rec.attribute10,
		p_x_node_rec.attribute11,
		p_x_node_rec.attribute12,
		p_x_node_rec.attribute13,
		p_x_node_rec.attribute14,
		p_x_node_rec.attribute15,
		--R12
		--priyan MEL-CDL
		p_x_node_rec.ata_code
	);

	IF (fnd_log.level_statement	>= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
			'Node ['||p_x_node_rec.relationship_id||'] created'
		);
	END	IF;

	-- 5.	Iterate	through	the	counter	rules table
	IF (p_x_counter_rules_tbl.COUNT	> 0)
	THEN
		FOR	i IN p_x_counter_rules_tbl.FIRST..p_x_counter_rules_tbl.LAST
		LOOP
			-- 5a.i.	Populate the node relationship_id for the counter_rules_tbl	records
			p_x_counter_rules_tbl(i).relationship_id :=	p_x_node_rec.relationship_id;

			-- 5a.i.	Create the position	ratio records
			Create_Counter_Rule
			(
				p_x_counter_rules_tbl(i)
			);

			-- Check Error Message stack.
			x_msg_count	:= FND_MSG_PUB.count_msg;
			IF x_msg_count > 0 THEN
				RAISE FND_API.G_EXC_ERROR;
			END	IF;

			IF (fnd_log.level_statement	>= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.string
				(
					fnd_log.level_statement,
					'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
					'Counter rule ['||p_x_counter_rules_tbl(i).ctr_update_rule_id||'] created'
				);
			END	IF;
		END	LOOP;
	END	IF;

	-- 6.	Iterate	through	the	subconfigurations table	[This table	will in	all	probability	be null	according to the
	-- current design of Create_MC_Revision, Copy_Master_Config	and	Copy_MC_Nodes, but the following code is needed	in
	-- place to	account	for	the	case when the table	is not null]
	IF (p_x_subconfig_tbl.COUNT	> 0)
	THEN


		FOR	i IN p_x_subconfig_tbl.FIRST..p_x_subconfig_tbl.LAST
		LOOP
			-- 5a.i.	Populate the node relationship_id for the subconfig_tbl	records
			p_x_subconfig_tbl(i).relationship_id :=	p_x_node_rec.relationship_id;

			-- 5a.i.	Create the subconfiguration	records
			Attach_Subconfig
			(
				p_x_subconfig_tbl(i)
			);

			-- Check Error Message stack.
			x_msg_count	:= FND_MSG_PUB.count_msg;
			IF x_msg_count > 0 THEN
				RAISE FND_API.G_EXC_ERROR;
			END	IF;

			IF (fnd_log.level_statement	>= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.string
				(
					fnd_log.level_statement,
					'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
					'Counter rule ['||p_x_subconfig_tbl(i).mc_config_relation_id||'] created'
				);
			END	IF;
		END	LOOP;

				validate_priority(p_x_subconfig_tbl);

	END	IF;

	IF (fnd_log.level_procedure	>= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||'.end',
			'At	the	end	of PLSQL procedure'
		);
	END	IF;
	-- API body	ends here

	-- Check Error Message stack.
	x_msg_count	:= FND_MSG_PUB.count_msg;

	IF x_msg_count > 0 THEN
		RAISE FND_API.G_EXC_ERROR;
	END	IF;

	-- Standard	check for p_commit
	IF FND_API.TO_BOOLEAN (p_commit)
	THEN
		COMMIT WORK;
	END	IF;

	-- Standard	call to	get	message	count and if count is 1, get message info
	FND_MSG_PUB.count_and_get
	(
		p_count		=> x_msg_count,
		p_data		=> x_msg_data,
		p_encoded	=> FND_API.G_FALSE
	);

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status	:= FND_API.G_RET_STS_ERROR;
		Rollback to	Create_Node_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count		=> x_msg_count,
			p_data		=> x_msg_data,
			p_encoded	=> FND_API.G_FALSE
		);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR	THEN
		x_return_status	:= FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to	Create_Node_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count		=> x_msg_count,
			p_data		=> x_msg_data,
			p_encoded	=> FND_API.G_FALSE
		);

	WHEN OTHERS	THEN
		x_return_status	:= FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to	Create_Node_SP;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.add_exc_msg
			(
				p_pkg_name		=> G_PKG_NAME,
				p_procedure_name	=> 'Create_Node',
				p_error_text		=> SUBSTR(SQLERRM,1,240)
			);
		END	IF;
		FND_MSG_PUB.count_and_get
		(
			p_count		=> x_msg_count,
			p_data		=> x_msg_data,
			p_encoded	=> FND_API.G_FALSE
		);

END	Create_Node;

PROCEDURE Modify_Node
(
	p_api_version		IN		NUMBER,
	p_init_msg_list			IN		VARCHAR2	:= FND_API.G_FALSE,
	p_commit				IN		VARCHAR2	:= FND_API.G_FALSE,
	p_validation_level		IN		NUMBER		:= FND_API.G_VALID_LEVEL_FULL,
	x_return_status			OUT		NOCOPY	VARCHAR2,
	x_msg_count				OUT		NOCOPY	NUMBER,
	x_msg_data				OUT		NOCOPY	VARCHAR2,
	p_x_node_rec			IN OUT	NOCOPY	Node_Rec_Type,
	p_x_counter_rules_tbl	IN OUT	NOCOPY	Counter_Rules_Tbl_Type,
	p_x_subconfig_tbl		IN OUT	NOCOPY	SubConfig_Tbl_Type
)
IS

	-- Define cursor check_poskey_update to	verify whether the position	key	for	a MC node is updated
	CURSOR check_poskey_update
	IS
		SELECT	'x'
		FROM	ahl_mc_relationships
		WHERE	relationship_id	= p_x_node_rec.relationship_id AND
			position_key <>	p_x_node_rec.position_key;

	-- Define cursor get_node_details to retrieve details of the MC	node
	CURSOR get_node_details
	IS
		SELECT active_end_date
		FROM ahl_mc_relationships
		WHERE relationship_id =	p_x_node_rec.relationship_id;

	--R12
	--priyan MEL-CDL
	-- Defind to retrieve the ata codes	of all the Nodes that has attached the passed MC top node as subconfig
	CURSOR get_ata_for_top_node
	(
		p_rel_id in	number
	)
	IS
		SELECT	rel.ata_code, rel.position_ref_meaning , mch.name
		FROM	ahl_mc_relationships_v rel,	ahl_mc_headers_b mch
		WHERE	rel.relationship_id	IN
				(
					SELECT	relationship_id
					FROM	ahl_mc_config_relations
					WHERE	mc_header_id IN
							(
								SELECT	mc_header_id
								FROM	ahl_mc_relationships
								WHERE	relationship_id	= p_rel_id
							)
				)
				AND rel.mc_header_id = mch.mc_header_id;

	-- Defined to retrieve the ata codes of	subconfigs'	root nodes
	CURSOR get_ata_for_leaf_node
	(
		p_rel_id in	number
	)
	IS
		SELECT	rel.ata_code , mch.name, rel.position_ref_meaning
		FROM	ahl_mc_relationships_v rel,	ahl_mc_headers_b mch
		WHERE	rel.mc_header_id IN
				(
					SELECT	mc_header_id
					FROM	ahl_mc_config_relations
					WHERE	relationship_id	= p_rel_id
				)
				AND parent_relationship_id IS NULL
				AND mch.mc_header_id = rel.mc_header_id;

	-- Define check_root_node to check whether the node	to topnode of a	MC
	CURSOR check_root_node
	IS
		SELECT	'x'
		FROM	ahl_mc_relationships
		WHERE	parent_relationship_id is null AND
			relationship_id	= p_x_node_rec.relationship_id;

	-- Define check_leaf_node to check whether the node	a leaf node
	CURSOR check_leaf_node
	IS
		SELECT	'x'
		FROM	ahl_mc_relationships
		WHERE	parent_relationship_id = p_x_node_rec.relationship_id AND
			G_TRUNC_DATE < trunc(nvl(active_end_date, G_SYSDATE	+ 1));

	--End priyan Changes

	-- Define local	variables
	l_api_name	CONSTANT	VARCHAR2(30)	:= 'Modify_Node';
	l_api_version	CONSTANT	NUMBER		:= 1.0;
	l_return_status			VARCHAR2(1);
	l_msg_count					NUMBER;
	l_msg_data					VARCHAR2(2000);

	l_header_status			VARCHAR2(30);
	l_end_date			DATE;

	--R12
	--priyan MEL-CDL
	l_get_ata_top_node_rec		get_ata_for_top_node%rowtype;
	l_get_ata_leaf_node_rec		get_ata_for_leaf_node%rowtype;

BEGIN

	-- Standard	start of API savepoint
	SAVEPOINT Modify_Node_SP;

	-- Standard	call to	check for call compatibility
	IF NOT FND_API.compatible_api_call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END	IF;

	-- Initialize message list if p_init_msg_list is set to	TRUE
	IF FND_API.TO_BOOLEAN(p_init_msg_list)
	THEN
		FND_MSG_PUB.Initialize;
	END	IF;

	-- Initialize API return status	to success
	x_return_status	:= FND_API.G_RET_STS_SUCCESS;

	-- API body	starts here
	IF (fnd_log.level_procedure	>= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||'.begin',
			' At	the	start of PLSQL procedure'
		);
	END	IF;

	IF (p_x_node_rec.operation_flag	= G_DML_UPDATE)
	THEN

		-- [node is	also being modified]
		-- 1a.i.	Validate config_status_code	of the MC is 'DRAFT' or	'APPROVAL_REJECTED'
		l_header_status	:= Get_MC_Status(null, p_x_node_rec.mc_header_id);
		IF NOT (l_header_status	IN ('DRAFT', 'APPROVAL_REJECTED'))
		THEN
			FND_MESSAGE.Set_Name('AHL',	'AHL_MC_NODE_STS_INV');
			FND_MSG_PUB.ADD;
			IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.message
				(
					fnd_log.level_exception,
					'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
					false
				);
			END	IF;
			RAISE FND_API.G_EXC_ERROR;

		ELSIF (l_header_status = 'APPROVAL_REJECTED')
		THEN
			-- 1a.ii.	Set	status of MC to	DRAFT if APPROVAL_REJECTED
			Set_Header_Status(p_x_node_rec.relationship_id);
		END	IF;

		-- 1b.	For	the	MC node	with relationship_id = p_x_node_rec.parent_relationship_id [parent node]
		-- 1c.i.	Validate a MC node with	relationship_id	= p_x_node_rec.relationship_id exists
		-- 1c.iii.	Validate p_x_node_rec.position_ref_code	exists
		-- 1c.iv.	Validate p_x_node_rec.position_necessity_code exists
		-- 1c.v.	Validate p_x_node_rec.quantity
		-- 1c.vi.	Validate p_x_node_rec.uom_code
		-- 1c.vii.	Validate p_x_node_rec.item_group_id	exists
		-- 1c.viii.	Validate p_x_node_rec.display_order	> 0	and	is not equal to	display_order of all nodes at the same level
		-- Validate	dates
		-- 1c.xvii.2	Validate the item_group	does not have any item association with	quantity > 1
		Validate_Node(p_x_node_rec);

		IF (p_x_node_rec.position_key IS NULL)
		THEN
			SELECT ahl_mc_rel_pos_key_s.nextval	INTO p_x_node_rec.position_key FROM	DUAL;
		ELSE
			-- 3j.i.Validate p_x_node_rec.position_key is unique within	this MC
			OPEN check_poskey_update;
			FETCH check_poskey_update INTO l_dummy_varchar;
			IF (check_poskey_update%FOUND)
			THEN
				FND_MESSAGE.Set_Name('AHL',	'AHL_MC_POSKEY_NOUPD');
				FND_MESSAGE.Set_Token('POSREF',	p_x_node_rec.position_ref_meaning);
				FND_MSG_PUB.ADD;

				IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
				THEN
					fnd_log.message
					(
						fnd_log.level_exception,
						'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
						false
					);
				END	IF;
			END	IF;
			CLOSE check_poskey_update;
		END	IF;

		-- ER #2631303 is not valid	since there	can	be no units	created	from DRAFT MCs

		-- Check Error Message stack.
		x_msg_count	:= FND_MSG_PUB.count_msg;
		IF x_msg_count > 0 THEN
			RAISE FND_API.G_EXC_ERROR;
		END	IF;

		IF (fnd_log.level_statement	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_statement,
				'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
				'Node validation successful'
			);
		END	IF;

		p_x_node_rec.object_version_number := p_x_node_rec.object_version_number + 1;

		-- 1d.	Update the node	record in AHL_MC_RELATIONSHIPS table
		UPDATE	AHL_MC_RELATIONSHIPS
		SET	POSITION_REF_CODE	= p_x_node_rec.position_ref_code,
			ITEM_GROUP_ID		= p_x_node_rec.item_group_id,
			UOM_CODE		= p_x_node_rec.uom_code,
			QUANTITY		= p_x_node_rec.quantity,
			DISPLAY_ORDER		= p_x_node_rec.display_order,
			POSITION_NECESSITY_CODE	= p_x_node_rec.position_necessity_code,
			POSITION_KEY		= p_x_node_rec.position_key,
			ACTIVE_START_DATE	= p_x_node_rec.active_start_date,
			ACTIVE_END_DATE		= p_x_node_rec.active_end_date,
			LAST_UPDATE_DATE	= G_SYSDATE,
			LAST_UPDATED_BY		= G_USER_ID,
			LAST_UPDATE_LOGIN	= G_LOGIN_ID,
			OBJECT_VERSION_NUMBER	= p_x_node_rec.object_version_number,
			SECURITY_GROUP_ID	= p_x_node_rec.security_group_id,
			ATTRIBUTE_CATEGORY	= p_x_node_rec.attribute_category,
			ATTRIBUTE1		= p_x_node_rec.attribute1,
			ATTRIBUTE2		= p_x_node_rec.attribute2,
			ATTRIBUTE3		= p_x_node_rec.attribute3,
			ATTRIBUTE4		= p_x_node_rec.attribute4,
			ATTRIBUTE5		= p_x_node_rec.attribute5,
			ATTRIBUTE6		= p_x_node_rec.attribute6,
			ATTRIBUTE7		= p_x_node_rec.attribute7,
			ATTRIBUTE8		= p_x_node_rec.attribute8,
			ATTRIBUTE9		= p_x_node_rec.attribute9,
			ATTRIBUTE10		= p_x_node_rec.attribute10,
			ATTRIBUTE11		= p_x_node_rec.attribute11,
			ATTRIBUTE12		= p_x_node_rec.attribute12,
			ATTRIBUTE13		= p_x_node_rec.attribute13,
			ATTRIBUTE14		= p_x_node_rec.attribute14,
			ATTRIBUTE15		= p_x_node_rec.attribute15,
			--R12
			--priyan MEL-CDL
			ATA_CODE		= p_x_node_rec.ata_code
		WHERE	RELATIONSHIP_ID	= p_x_node_rec.relationship_id;


		IF (fnd_log.level_statement	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_statement,
				'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
				'Node ['||p_x_node_rec.relationship_id||'] updated'
			);
		END	IF;

	ELSE
		-- [implies	the	node is	not	being updated, instead either subconfig	associations or	position ratios
		-- are being updated; User may only	update the subconfig table in the UI and leave the Node	details
		-- untouched, in this case it is better	to call	Modify_Node	with p_x_node_rec.operation_flag = null
		-- and p_x_subconfig_tbl <>	null]

		-- 2a.	Validate node with relationship_id = p_x_node_rec.relationship_id, object_version_number = p_x_node_rec.object_version_number
		Validate_Node_Exists(p_x_node_rec.relationship_id, null);

		l_header_status	:= Get_MC_Status(p_x_node_rec.relationship_id, null);
		IF NOT (l_header_status	IN ('DRAFT', 'APPROVAL_REJECTED'))
		THEN
			FND_MESSAGE.Set_Name('AHL',	'AHL_MC_NODE_STS_INV');
			FND_MSG_PUB.ADD;
			IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.message
				(
					fnd_log.level_exception,
					'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
					false
				);
			END	IF;
			RAISE FND_API.G_EXC_ERROR;
		ELSIF (l_header_status = 'APPROVAL_REJECTED')
		THEN
			-- 1a.ii.	Set	status of MC to	DRAFT if APPROVAL_REJECTED
			Set_Header_Status(p_x_node_rec.relationship_id);
		END	IF;

		OPEN get_node_details;
		FETCH get_node_details INTO	l_end_date;
		CLOSE get_node_details;

		-- Validate	active_end_date	>= sysdate exists
		IF (trunc(nvl(l_end_date, G_SYSDATE	+ 1)) <= G_TRUNC_DATE)
		THEN
			FND_MESSAGE.Set_Name('AHL',	'AHL_MC_END_DATE_INV');
			FND_MSG_PUB.ADD;
			IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.message
				(
					fnd_log.level_exception,
					'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
					false
				);
			END	IF;
		END	IF;

		-- Check Error Message stack.
		x_msg_count	:= FND_MSG_PUB.count_msg;
		IF x_msg_count > 0 THEN
			RAISE FND_API.G_EXC_ERROR;
		END	IF;

		IF (fnd_log.level_statement	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_statement,
				'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
				'Node validation successful'
			);
		END	IF;
	END	IF;

	IF (fnd_log.level_statement	>= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
			'Processing	counter	rules and subconfig	table'
		);
	END	IF;

	-- 3.	Iterate	through	the	counter	rules table
	IF (p_x_counter_rules_tbl.COUNT	> 0)
	THEN
		FOR	i IN p_x_counter_rules_tbl.FIRST..p_x_counter_rules_tbl.LAST
		LOOP
			-- 5a.i.	Populate the node relationship_id for the counter_rules_tbl	records
			p_x_counter_rules_tbl(i).relationship_id :=	p_x_node_rec.relationship_id;

			IF (p_x_counter_rules_tbl(i).operation_flag	= G_DML_CREATE)
			THEN
				Create_Counter_Rule
				(
					p_x_counter_rules_tbl(i)
				);
			ELSIF (p_x_counter_rules_tbl(i).operation_flag = G_DML_DELETE)
			THEN
				Delete_Counter_Rule
				(
					p_x_counter_rules_tbl(i).ctr_update_rule_id,
					p_x_counter_rules_tbl(i).object_version_number
				);
			ELSE
				Modify_Counter_Rule
				(
					p_x_counter_rules_tbl(i)
				);
			END	IF;

			-- Check Error Message stack.
			x_msg_count	:= FND_MSG_PUB.count_msg;
			IF x_msg_count > 0 THEN
				RAISE FND_API.G_EXC_ERROR;
			END	IF;
		END	LOOP;
	END	IF;

	-- 4.	Iterate	through	the	subconfigurations table
	IF (p_x_subconfig_tbl.COUNT	> 0)
	THEN
		FOR	i IN p_x_subconfig_tbl.FIRST..p_x_subconfig_tbl.LAST
		LOOP
			-- 5a.i.	Populate the node relationship_id for the subconfig_tbl	records
			p_x_subconfig_tbl(i).relationship_id :=	p_x_node_rec.relationship_id;

			IF (p_x_subconfig_tbl(i).operation_flag	= G_DML_CREATE)
			THEN
				Attach_Subconfig
				(
					p_x_subconfig_tbl(i)
				);
			ELSIF (p_x_subconfig_tbl(i).operation_flag = G_DML_DELETE)
			THEN
				Detach_Subconfig
				(
					p_x_subconfig_tbl(i).mc_config_relation_id,
					p_x_subconfig_tbl(i).object_version_number
				);
			ELSE
				Modify_Subconfig
				(
					p_x_subconfig_tbl(i)
				);
			END	IF;

			-- Check Error Message stack.
			x_msg_count	:= FND_MSG_PUB.count_msg;
			IF x_msg_count > 0 THEN
				RAISE FND_API.G_EXC_ERROR;
			END	IF;
		END	LOOP;

		validate_priority(p_x_subconfig_tbl);
	END	IF;

	IF (fnd_log.level_procedure	>= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||'.end',
			'At	the	end	of PLSQL procedure'
		);
	END	IF;
	-- API body	ends here

	-- Check Error Message stack.
	x_msg_count	:= FND_MSG_PUB.count_msg;
	IF x_msg_count > 0 THEN
		RAISE FND_API.G_EXC_ERROR;
	END	IF;

	--R12
	--Priyan MEL-CDL
	-- Call	the	cursor check_root_node to see if the node being	modified is	a top node or not .
	-- If the cursor check_root_node returns true then the cursor get_ata_for_top_node	,is	called
	-- to check	if any of the nodes	that has the top node's	MC attached	as a subconfig.	If then,the
	-- corresponding Nodes ATA Code	is retreived and is	checked	with the ATA code of the top node.
	-- If they are different then a	warning	message	is shown to	the	user.

	IF (p_x_node_rec.operation_flag	= G_DML_UPDATE)
	THEN
		OPEN check_root_node;
		FETCH check_root_node INTO l_dummy_varchar;

			IF (check_root_node%FOUND)
			THEN
				OPEN get_ata_for_top_node(p_x_node_rec.relationship_id);
				LOOP
					FETCH get_ata_for_top_node INTO	l_get_ata_top_node_rec ;
					EXIT WHEN get_ata_for_top_node%NOTFOUND;

					IF (l_get_ata_top_node_rec.ata_code	<> p_x_node_rec.ata_code)
					THEN

					-- Raise warning msg
						FND_MESSAGE.set_name('AHL',	'AHL_MC_POS_SUBMC_ATA_NOMATCH');
						FND_MESSAGE.Set_Token('POS', l_get_ata_top_node_rec.POSITION_REF_MEANING);
						FND_MESSAGE.Set_Token('MC',	l_get_ata_top_node_rec.NAME);
						FND_MESSAGE.Set_Token('SUBCONFIG', p_x_node_rec.POSITION_REF_MEANING);
						FND_MSG_PUB.add;
					END	IF;
				END	LOOP;

			CLOSE get_ata_for_top_node;
			END	IF;

		CLOSE check_root_node;

		-- Check if	the	node is	a leaf node	by calling the cursor check_leaf_node,
		-- If then , get all the ata codes of the subconfigs, attached.
		-- Get the ata code	of the top node	of the subconfigs and check	if the ata codes are the same
		-- If not then , raise a warning message.


		OPEN check_leaf_node;
		FETCH check_leaf_node INTO l_dummy_varchar;

			IF (check_leaf_node%NOTFOUND)
			THEN

				OPEN get_ata_for_leaf_node(p_x_node_rec.relationship_id);
				LOOP
					FETCH get_ata_for_leaf_node	INTO l_get_ata_leaf_node_rec ;
					EXIT WHEN get_ata_for_leaf_node%NOTFOUND;

					IF (l_get_ata_leaf_node_rec.ata_code <> p_x_node_rec.ata_code)
					THEN
						-- Raise warning msg
						FND_MESSAGE.set_name('AHL',	'AHL_MC_POS_SUBMC_ATA_NOMATCH');
						FND_MESSAGE.Set_Token('POS', p_x_node_rec.POSITION_REF_MEANING);
						FND_MESSAGE.Set_Token('MC',l_get_ata_leaf_node_rec.POSITION_REF_MEANING );
						FND_MESSAGE.Set_Token('SUBCONFIG', l_get_ata_leaf_node_rec.name);
						FND_MSG_PUB.add;
					END	IF;
				END	LOOP;
				CLOSE get_ata_for_leaf_node;
			END	IF;
		CLOSE check_leaf_node;
	END	IF; -- condition for DML Update

	-- Standard	check for p_commit
	IF FND_API.TO_BOOLEAN (p_commit)
	THEN
		COMMIT WORK;
	END	IF;

	-- Check Error Message stack.
	x_msg_count	:= FND_MSG_PUB.count_msg;

	IF ( x_msg_count > 0 and x_return_status <> FND_API.G_RET_STS_SUCCESS )  THEN
		RAISE FND_API.G_EXC_ERROR;
	END	IF;

	-- Standard	call to	get	message	count and if count is 1, get message info
	FND_MSG_PUB.count_and_get
	(
		p_count		=> x_msg_count,
		p_data		=> x_msg_data,
		p_encoded	=> FND_API.G_FALSE
	);

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status	:= FND_API.G_RET_STS_ERROR;
		Rollback to	Modify_Node_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count		=> x_msg_count,
			p_data		=> x_msg_data,
			p_encoded	=> FND_API.G_FALSE
		);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR	THEN
		x_return_status	:= FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to	Modify_Node_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count		=> x_msg_count,
			p_data		=> x_msg_data,
			p_encoded	=> FND_API.G_FALSE
		);

	WHEN OTHERS	THEN
		x_return_status	:= FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to	Modify_Node_SP;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.add_exc_msg
			(
				p_pkg_name		=> G_PKG_NAME,
				p_procedure_name	=> 'Modify_Node',
				p_error_text		=> SUBSTR(SQLERRM,1,240)
			);
		END	IF;
		FND_MSG_PUB.count_and_get
		(
			p_count		=> x_msg_count,
			p_data		=> x_msg_data,
			p_encoded	=> FND_API.G_FALSE
		);

END	Modify_Node;

PROCEDURE Delete_Node
(
	p_api_version		IN		NUMBER,
	p_init_msg_list			IN		VARCHAR2	:= FND_API.G_FALSE,
	p_commit				IN		VARCHAR2	:= FND_API.G_FALSE,
	p_validation_level		IN		NUMBER		:= FND_API.G_VALID_LEVEL_FULL,
	x_return_status			OUT		NOCOPY	VARCHAR2,
	x_msg_count				OUT		NOCOPY	NUMBER,
	x_msg_data				OUT		NOCOPY	VARCHAR2,
	p_node_id			IN		NUMBER,
	p_object_ver_num	IN		NUMBER
)
IS

	-- 1.	Define cursor get_mc_tree_csr to read all nodes	that are children to a particular MC node
	CURSOR get_mc_tree_csr
	(
		p_rel_id in	number
	)
	IS
		SELECT *
		FROM ahl_mc_relationships
		CONNECT	BY parent_relationship_id =	PRIOR relationship_id
		START WITH relationship_id = p_rel_id
		ORDER BY relationship_id DESC;

	-- 4.	Define local variables
	l_api_name	CONSTANT	VARCHAR2(30)	:= 'Delete_Node';
	l_api_version	CONSTANT	NUMBER		:= 1.0;
	l_return_status			VARCHAR2(1);
	l_msg_count					NUMBER;
	l_msg_data					VARCHAR2(2000);

	l_node_csr_rec			get_mc_tree_csr%rowtype;
	l_header_status			VARCHAR2(30);

BEGIN

	-- Standard	start of API savepoint
	SAVEPOINT Delete_Node_SP;

	-- Standard	call to	check for call compatibility
	IF NOT FND_API.compatible_api_call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END	IF;

	-- Initialize message list if p_init_msg_list is set to	TRUE
	IF FND_API.TO_BOOLEAN(p_init_msg_list)
	THEN
		FND_MSG_PUB.Initialize;
	END	IF;

	-- Initialize API return status	to success
	x_return_status	:= FND_API.G_RET_STS_SUCCESS;

	-- API body	starts here
	IF (fnd_log.level_procedure	>= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||'.begin',
			'At	the	start of PLSQL procedure'
		);
	END	IF;

	-- 5.	Validate a MC node with	relationship_id	= p_node_id	exists
	Validate_Node_Exists (p_node_id, nvl(p_object_ver_num, 0));

	l_header_status	:= Get_MC_Status(p_node_id,	null);
	-- 6i.	Validate that the config_status_code of	the	MC is 'DRAFT' or 'APPROVAL_REJECTED'
	IF NOT (l_header_status	IN ('DRAFT', 'APPROVAL_REJECTED'))
	THEN
		FND_MESSAGE.Set_Name('AHL',	'AHL_MC_NODE_STS_INV');
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
				false
			);
		END	IF;
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_header_status = 'APPROVAL_REJECTED')
	THEN
		-- 6ii.	Set	status of MC to	DRAFT if APPROVAL_REJECTED
		Set_Header_Status(p_node_id);
	END	IF;

	OPEN get_mc_tree_csr(p_node_id);
	LOOP
		FETCH get_mc_tree_csr INTO l_node_csr_rec;
		EXIT WHEN get_mc_tree_csr%NOTFOUND;

		-- ER #2631303 is not valid	since there	can	be no units	created	from DRAFT MCs

		-- 9d.	Delete all subconfiguration	associations with the current node
		DELETE FROM	ahl_mc_config_relations
		WHERE relationship_id =	l_node_csr_rec.relationship_id;

		IF (fnd_log.level_statement	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_statement,
				'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
				'Detached subconfigs for node ['||l_node_csr_rec.relationship_id||']'
			);
		END	IF;

		-- 9g.	Delete all counter rule	associations with the current node
		DELETE FROM	ahl_ctr_update_rules
		WHERE relationship_id =	l_node_csr_rec.relationship_id;

		IF (fnd_log.level_statement	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_statement,
				'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
				'Detached counter rules	for	node ['||l_node_csr_rec.relationship_id||']'
			);
		END	IF;

		-- 9h.	Delete all document	associations to	this particular	node
		AHL_DI_ASSO_DOC_GEN_PVT.DELETE_ALL_ASSOCIATIONS
		(
			p_api_version		=> 1.0,
			p_init_msg_list		=> FND_API.G_FALSE,
			p_commit		=> FND_API.G_FALSE,
			p_validate_only		=> FND_API.G_FALSE,
			p_validation_level	=> FND_API.G_VALID_LEVEL_FULL,
			p_aso_object_type_code	=> 'MC',
			p_aso_object_id		=> l_node_csr_rec.relationship_id,
			x_return_status		=> l_return_status,
			x_msg_count		=> l_msg_count,
			x_msg_data		=> l_msg_data
		);

		IF (fnd_log.level_statement	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_statement,
				'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
				'Deleted document associations for node	['||l_node_csr_rec.relationship_id||']'
			);
		END	IF;

		-- 9i.	Delete the MC node
		DELETE FROM	ahl_mc_relationships
		WHERE relationship_id =	l_node_csr_rec.relationship_id;

	END	LOOP;

	IF (fnd_log.level_procedure	>= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||'.end',
			'At	the	end	of PLSQL procedure'
		);
	END	IF;
	-- API body	ends here

	-- Check Error Message stack.
	x_msg_count	:= FND_MSG_PUB.count_msg;
	IF x_msg_count > 0 THEN
		RAISE FND_API.G_EXC_ERROR;
	END	IF;

	-- Standard	check for p_commit
	IF FND_API.TO_BOOLEAN (p_commit)
	THEN
		COMMIT WORK;
	END	IF;

	-- Standard	call to	get	message	count and if count is 1, get message info
	FND_MSG_PUB.count_and_get
	(
		p_count		=> x_msg_count,
		p_data		=> x_msg_data,
		p_encoded	=> FND_API.G_FALSE
	);

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status	:= FND_API.G_RET_STS_ERROR;
		Rollback to	Delete_Node_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count		=> x_msg_count,
			p_data		=> x_msg_data,
			p_encoded	=> FND_API.G_FALSE
		);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR	THEN
		x_return_status	:= FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to	Delete_Node_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count		=> x_msg_count,
			p_data		=> x_msg_data,
			p_encoded	=> FND_API.G_FALSE
		);
	WHEN OTHERS	THEN
		x_return_status	:= FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to	Delete_Node_SP;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.add_exc_msg
			(
				p_pkg_name		=> G_PKG_NAME,
				p_procedure_name	=> 'Delete_Node',
				p_error_text		=> SUBSTR(SQLERRM,1,240)
			);
		END	IF;
		FND_MSG_PUB.count_and_get
		(
			p_count		=> x_msg_count,
			p_data		=> x_msg_data,
			p_encoded	=> FND_API.G_FALSE
		);

END	Delete_Node;

PROCEDURE Copy_Node
(
	p_api_version		IN		NUMBER,
	p_init_msg_list			IN		VARCHAR2	:= FND_API.G_FALSE,
	p_commit				IN		VARCHAR2	:= FND_API.G_FALSE,
	p_validation_level		IN		NUMBER		:= FND_API.G_VALID_LEVEL_FULL,
	x_return_status			OUT		NOCOPY	VARCHAR2,
	x_msg_count				OUT		NOCOPY	NUMBER,
	x_msg_data				OUT		NOCOPY	VARCHAR2,
	p_parent_rel_id			IN		NUMBER,
	p_parent_obj_ver_num	IN		NUMBER,
	p_x_node_id				IN OUT	NOCOPY	NUMBER,
	p_x_node_obj_ver_num	IN OUT	NOCOPY	NUMBER
)
IS

	-- Define local	variables
	l_api_name	CONSTANT	VARCHAR2(30)	:= 'Copy_Node';
	l_api_version	CONSTANT	NUMBER		:= 1.0;
	l_return_status			VARCHAR2(1);
	l_msg_count					NUMBER;
	l_msg_data					VARCHAR2(2000);

	l_header_status			VARCHAR2(30);

BEGIN

	-- Standard	start of API savepoint
	SAVEPOINT Copy_Node_SP;

	-- Standard	call to	check for call compatibility
	IF NOT FND_API.compatible_api_call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END	IF;

	-- Initialize message list if p_init_msg_list is set to	TRUE
	IF FND_API.TO_BOOLEAN(p_init_msg_list)
	THEN
		FND_MSG_PUB.Initialize;
	END	IF;

	-- Initialize API return status	to success
	x_return_status	:= FND_API.G_RET_STS_SUCCESS;

	-- API body	starts here
	IF (fnd_log.level_procedure	>= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||'.begin',
			'At	the	start of PLSQL procedure'
		);
	END	IF;

	-- 1.	Validate a MC node exists with RELATIONSHIP_ID = p_parent_rel_id
	-- 2.	Validate p_parent_obj_ver_num for the MC node with RELATIONSHIP_ID = p_parent_rel_id
	Validate_Node_Exists(p_parent_rel_id, nvl(p_parent_obj_ver_num,	0));

	l_header_status	:= Get_MC_Status(p_parent_rel_id, null);
	-- 3a.	Validate that the config_status_code of	the	MC is 'DRAFT' or 'APPROVAL_REJECTED'
	IF NOT (l_header_status	IN ('DRAFT', 'APPROVAL_REJECTED'))
	THEN
		FND_MESSAGE.Set_Name('AHL',	'AHL_MC_NODE_STS_INV');
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
				false
			);
		END	IF;
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_header_status = 'APPROVAL_REJECTED')
	THEN
		Set_Header_Status(p_parent_rel_id);
	END	IF;

	-- 4.	Validate a MC node exists with RELATIONSHIP_ID = p_x_node_id
	-- 5.	Validate p_x_node_rec.object_version_number	for	the	MC node	with RELATIONSHIP_ID = p_x_node_id
	Validate_Node_Exists(p_x_node_id, nvl(p_x_node_obj_ver_num,	0));

	-- Check Error Message stack.
	x_msg_count	:= FND_MSG_PUB.count_msg;
	IF x_msg_count > 0 THEN
		RAISE FND_API.G_EXC_ERROR;
	END	IF;

	IF (fnd_log.level_statement	>= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
			'Node validation successful... Calling Copy_MC_Nodes'
		);
	END	IF;

	-- 6.	Call AHL_MC_Node_PVT.Copy_MC_Nodes
	Copy_MC_Nodes
	(
		p_api_version		=> 1.0,
		p_init_msg_list		=> FND_API.G_FALSE,
		p_commit		=> FND_API.G_FALSE,
		p_validation_level	=> FND_API.G_VALID_LEVEL_FULL,
		x_return_status		=> l_return_status,
		x_msg_count			=> l_msg_count,
		x_msg_data		=> l_msg_data,
		p_source_rel_id		=> p_x_node_id,
		p_dest_rel_id		=> p_parent_rel_id,
		p_new_rev_flag		=> FALSE,
		p_node_copy		=> TRUE
	);

	-- Read	the	newly created node details into	the	in/out parameters
	BEGIN
		SELECT	new.relationship_id, new.object_version_number
		INTO	p_x_node_id, p_x_node_obj_ver_num
		FROM	ahl_mc_relationships new, ahl_mc_relationships old
		WHERE	new.position_ref_code =	old.position_ref_code AND
			old.relationship_id	= p_x_node_id AND
			new.parent_relationship_id = p_parent_rel_id;
	EXCEPTION
		WHEN OTHERS	THEN
			NULL;
	END;

	IF (fnd_log.level_procedure	>= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||'.end',
			'At	the	end	of PLSQL procedure'
		);
	END	IF;
	-- API body	ends here

	-- Check Error Message stack.
	x_msg_count	:= FND_MSG_PUB.count_msg;
	IF x_msg_count > 0 THEN
		RAISE FND_API.G_EXC_ERROR;
	END	IF;

	-- Standard	check for p_commit
	IF FND_API.TO_BOOLEAN (p_commit)
	THEN
		COMMIT WORK;
	END	IF;

	-- Standard	call to	get	message	count and if count is 1, get message info
	FND_MSG_PUB.count_and_get
	(
		p_count		=> x_msg_count,
		p_data		=> x_msg_data,
		p_encoded	=> FND_API.G_FALSE
	);

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status	:= FND_API.G_RET_STS_ERROR;
		Rollback to	Copy_Node_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count		=> x_msg_count,
			p_data		=> x_msg_data,
			p_encoded	=> FND_API.G_FALSE
		);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR	THEN
		x_return_status	:= FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to	Copy_Node_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count		=> x_msg_count,
			p_data		=> x_msg_data,
			p_encoded	=> FND_API.G_FALSE
		);

	WHEN OTHERS	THEN
		x_return_status	:= FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to	Copy_Node_SP;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.add_exc_msg
			(
				p_pkg_name		=> G_PKG_NAME,
				p_procedure_name	=> 'Copy_Node',
				p_error_text		=> SUBSTR(SQLERRM,1,240)
			);
		END	IF;
		FND_MSG_PUB.count_and_get
		(
			p_count		=> x_msg_count,
			p_data		=> x_msg_data,
			p_encoded	=> FND_API.G_FALSE
		);

END	Copy_Node;

PROCEDURE Copy_MC_Nodes
(
	p_api_version		IN		NUMBER,
	p_init_msg_list			IN		VARCHAR2	:= FND_API.G_FALSE,
	p_commit				IN		VARCHAR2	:= FND_API.G_FALSE,
	p_validation_level		IN		NUMBER		:= FND_API.G_VALID_LEVEL_FULL,
	x_return_status			OUT		NOCOPY	VARCHAR2,
	x_msg_count				OUT		NOCOPY	NUMBER,
	x_msg_data				OUT		NOCOPY	VARCHAR2,
	p_source_rel_id			IN		NUMBER,
	p_dest_rel_id			IN		NUMBER,
	p_new_rev_flag			IN		BOOLEAN		:= FALSE,
	p_node_copy		IN		BOOLEAN		:= FALSE
)
IS

	-- 1.	Define cursor get_mc_tree_csr to read all nodes	that are children to the topnode of	a particular MC
	-- changed by anraj	remove the CONNECT BY PRIOR	clause on joins
	CURSOR get_mc_tree_csr
	(
		p_topnode_id in	number
	)
	IS
		SELECT	*
		FROM	ahl_mc_relationships
		WHERE	relationship_id	<> p_topnode_id
			-- Expired nodes also to be	copied or else position	path copy will fail
			-- AND G_TRUNC_DATE	< trunc(nvl(active_end_date, G_SYSDATE + 1))
		CONNECT	BY parent_relationship_id =	PRIOR relationship_id
		START WITH relationship_id = p_topnode_id
		ORDER BY parent_relationship_id, display_order;

	CURSOR get_mc_details_csr
	(
		p_relationship_id in number
	)
	IS
		select POSITION_REF_MEANING,POSITION_NECESSITY_MEANING,GROUP_NAME,ATA_MEANING -- R12 priyan	MEL-CDL
		from ahl_mc_relationships_v
		where relationship_id =	p_relationship_id;

	-- 2.	Define cursor get_ctr_rule_update_csr to read all counter update rules for a particular	MC node
	CURSOR get_ctr_rule_update_csr
	(
		p_rel_id in	number
	)
	IS
		SELECT	*
		FROM	ahl_ctr_update_rules
		WHERE	relationship_id	= p_rel_id;

	TYPE Number_Tbl_Type IS	TABLE OF NUMBER	INDEX BY BINARY_INTEGER;

	-- Define get_mc_header_id to read the mc_header_id	of the destination MC node
	CURSOR get_mc_header_id
	IS
		SELECT mc_header_id
		FROM ahl_mc_relationships
		WHERE relationship_id =	p_dest_rel_id;

	-- Define cursor get_max_dispord to	read the maximum of	display	orders of the children of a	MC node	with relationship_id = p_rel_id
	CURSOR get_max_dispord
	(
		p_rel_id in	number
	)
	IS
		SELECT max(display_order)
		FROM ahl_mc_relationships
		WHERE parent_relationship_id = p_rel_id;

	-- Define cursor get_root_node to read details of the top node (in the case	of copy_node)
	CURSOR get_root_node
	(
		p_topnode_id in	number
	)
	IS
		SELECT *
		FROM ahl_mc_relationships_v
		WHERE relationship_id =	p_topnode_id;

	-- Define local	variables
	l_api_name	CONSTANT	VARCHAR2(30)	:= 'Copy_MC_Nodes';
	l_api_version	CONSTANT	NUMBER		:= 1.0;
	l_return_status			VARCHAR2(1);
	l_msg_count					NUMBER;
	l_msg_data					VARCHAR2(2000);

	l_node_rec			Node_Rec_Type;
	l_nodes_tbl				Node_Tbl_Type;
	l_node_csr_rec			get_mc_tree_csr%rowtype;

	l_root_node_csr_rec				ahl_mc_relationships_v%rowtype;



	-- declared	by anraj to	remove the CONNECT BY PRIOR	on joins
	l_mc_details_rec		get_mc_details_csr%rowtype;

	l_ctr_rule_rec			Counter_Rule_Rec_Type;
	l_ctr_rules_tbl			Counter_Rules_Tbl_Type;
	l_ctr_rule_csr_rec		get_ctr_rule_update_csr%rowtype;
	l_node_idx			NUMBER;
	l_ctr_rule_idx			NUMBER;
	l_old_node_id_tbl		Number_Tbl_Type;
	l_node_ctr_rules_tbl		Counter_Rules_Tbl_Type;
	l_subconfig_tbl			Subconfig_Tbl_Type;
	l_ctr_iterator			NUMBER;
	l_ret_val			BOOLEAN;
	l_mc_header_id			NUMBER;
	l_max_dispord			NUMBER;

BEGIN

	-- Standard	start of API savepoint
	SAVEPOINT Copy_MC_Nodes_SP;

	-- Standard	call to	check for call compatibility
	IF NOT FND_API.compatible_api_call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END	IF;

	-- Initialize message list if p_init_msg_list is set to	TRUE
	IF FND_API.TO_BOOLEAN(p_init_msg_list)
	THEN
		FND_MSG_PUB.Initialize;
	END	IF;

	-- Initialize API return status	to success
	x_return_status	:= FND_API.G_RET_STS_SUCCESS;

	-- API body	starts here
	IF (fnd_log.level_procedure	>= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||'.begin',
			'At	the	start of PLSQL procedure'
		);
	END	IF;

	OPEN get_mc_header_id;
	FETCH get_mc_header_id INTO	l_mc_header_id;
	CLOSE get_mc_header_id;

	IF (fnd_log.level_statement	>= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
			'Starting the copy of the node tree	for	node ['||p_source_rel_id||'] to	node ['||p_dest_rel_id||']'
		);
	END	IF;

	l_node_idx := 0;
	l_ctr_rule_idx := 0;

	IF (p_node_copy	= TRUE)
	THEN
		-- For Copy_Node call for copying an MC	into a node
		-- ##TAMAL## This can be avoided if	the	topnode	is created in the procedure	Copy_Node itself and pass
		-- p_node_copy = FALSE to this method, similar to Copy_Master_Config and Create_MC_Revision
		OPEN get_root_node (p_source_rel_id);
		FETCH get_root_node	INTO l_root_node_csr_rec;
		CLOSE get_root_node;

		IF (l_root_node_csr_rec.relationship_id	IS NOT NULL)
		THEN
			l_node_rec.relationship_id := l_root_node_csr_rec.relationship_id;
			l_node_rec.mc_header_id	:= l_mc_header_id;
			l_node_rec.position_key	:= l_root_node_csr_rec.position_key;
			l_node_rec.position_ref_code :=	l_root_node_csr_rec.position_ref_code;
			l_node_rec.position_ref_meaning	:= l_root_node_csr_rec.position_ref_meaning;
			l_node_rec.position_necessity_code := l_root_node_csr_rec.position_necessity_code;
			l_node_rec.position_necessity_meaning := l_root_node_csr_rec.position_necessity_meaning;
			--R12
			--priyan MEL-CDL
			l_node_rec.ata_code	:= l_root_node_csr_rec.ata_code;
			l_node_rec.ata_meaning := l_root_node_csr_rec.ata_meaning;
			l_node_rec.uom_code	:= l_root_node_csr_rec.uom_code;
			l_node_rec.quantity	:= l_root_node_csr_rec.quantity;
			l_node_rec.parent_relationship_id := l_root_node_csr_rec.parent_relationship_id;
			l_node_rec.item_group_id :=	l_root_node_csr_rec.item_group_id;
			l_node_rec.item_group_name := l_root_node_csr_rec.group_name;
			l_node_rec.display_order :=	l_root_node_csr_rec.display_order;
			l_node_rec.active_start_date :=	l_root_node_csr_rec.active_start_date;
			l_node_rec.active_end_date := l_root_node_csr_rec.active_end_date;
			l_node_rec.object_version_number :=	1;
			l_node_rec.security_group_id :=	l_root_node_csr_rec.security_group_id;
			l_node_rec.attribute_category := l_root_node_csr_rec.attribute_category;
			l_node_rec.attribute1 := l_root_node_csr_rec.attribute1;
			l_node_rec.attribute2 := l_root_node_csr_rec.attribute2;
			l_node_rec.attribute3 := l_root_node_csr_rec.attribute3;
			l_node_rec.attribute4 := l_root_node_csr_rec.attribute4;
			l_node_rec.attribute5 := l_root_node_csr_rec.attribute5;
			l_node_rec.attribute6 := l_root_node_csr_rec.attribute6;
			l_node_rec.attribute7 := l_root_node_csr_rec.attribute7;
			l_node_rec.attribute8 := l_root_node_csr_rec.attribute8;
			l_node_rec.attribute9 := l_root_node_csr_rec.attribute9;
			l_node_rec.attribute10 := l_root_node_csr_rec.attribute10;
			l_node_rec.attribute11 := l_root_node_csr_rec.attribute11;
			l_node_rec.attribute12 := l_root_node_csr_rec.attribute12;
			l_node_rec.attribute13 := l_root_node_csr_rec.attribute13;
			l_node_rec.attribute14 := l_root_node_csr_rec.attribute14;
			l_node_rec.attribute15 := l_root_node_csr_rec.attribute15;
			l_node_rec.operation_flag := G_DML_COPY;
			l_node_rec.parent_node_rec_index :=	null;

			l_node_idx := l_node_idx + 1;
			l_nodes_tbl(l_node_idx)	:= l_node_rec;

			-- Since this is the topnode of	a MC, no counter rules exist
		END	IF;
	END	IF;

	OPEN get_mc_tree_csr (p_source_rel_id);
	LOOP
		FETCH get_mc_tree_csr INTO l_node_csr_rec;
		EXIT WHEN get_mc_tree_csr%NOTFOUND;

		IF (l_node_csr_rec.parent_relationship_id IS NOT NULL)
		THEN
			-- Since the topnode would already be created in the Create_MC_Revision	/ Copy_Master_Config call...

			OPEN get_mc_details_csr(l_node_csr_rec.relationship_id);
			FETCH get_mc_details_csr INTO l_mc_details_rec;
			CLOSE get_mc_details_csr;
			-- 7a.	Read all values	from l_node_csr_rec	into l_node_rec
			l_node_rec.relationship_id := l_node_csr_rec.relationship_id;
			l_node_rec.mc_header_id	:= l_mc_header_id;
			l_node_rec.position_key	:= l_node_csr_rec.position_key;
			l_node_rec.position_ref_code :=	l_node_csr_rec.position_ref_code;
			-- changed
			l_node_rec.position_ref_meaning	:= l_mc_details_rec.POSITION_REF_MEANING;
			l_node_rec.position_necessity_code := l_node_csr_rec.position_necessity_code;

			--R12
			--priyan MEL-CDL
			l_node_rec.ata_meaning := l_mc_details_rec.ata_meaning;
			l_node_rec.ata_code	:= l_node_csr_rec.ata_code;
			-- changed
			l_node_rec.position_necessity_meaning := l_mc_details_rec.POSITION_NECESSITY_MEANING;
			l_node_rec.uom_code	:= l_node_csr_rec.uom_code;
			l_node_rec.quantity	:= l_node_csr_rec.quantity;
			l_node_rec.parent_relationship_id := l_node_csr_rec.parent_relationship_id;
			l_node_rec.item_group_id :=	l_node_csr_rec.item_group_id;
			-- changed
			l_node_rec.item_group_name := l_mc_details_rec.GROUP_NAME;
			l_node_rec.display_order :=	l_node_csr_rec.display_order;
			l_node_rec.active_start_date :=	l_node_csr_rec.active_start_date;
			l_node_rec.active_end_date := l_node_csr_rec.active_end_date;
			l_node_rec.object_version_number :=	1;
			l_node_rec.security_group_id :=	l_node_csr_rec.security_group_id;
			l_node_rec.attribute_category := l_node_csr_rec.attribute_category;
			l_node_rec.attribute1 := l_node_csr_rec.attribute1;
			l_node_rec.attribute2 := l_node_csr_rec.attribute2;
			l_node_rec.attribute3 := l_node_csr_rec.attribute3;
			l_node_rec.attribute4 := l_node_csr_rec.attribute4;
			l_node_rec.attribute5 := l_node_csr_rec.attribute5;
			l_node_rec.attribute6 := l_node_csr_rec.attribute6;
			l_node_rec.attribute7 := l_node_csr_rec.attribute7;
			l_node_rec.attribute8 := l_node_csr_rec.attribute8;
			l_node_rec.attribute9 := l_node_csr_rec.attribute9;
			l_node_rec.attribute10 := l_node_csr_rec.attribute10;
			l_node_rec.attribute11 := l_node_csr_rec.attribute11;
			l_node_rec.attribute12 := l_node_csr_rec.attribute12;
			l_node_rec.attribute13 := l_node_csr_rec.attribute13;
			l_node_rec.attribute14 := l_node_csr_rec.attribute14;
			l_node_rec.attribute15 := l_node_csr_rec.attribute15;
			l_node_rec.operation_flag := G_DML_COPY;
			l_node_rec.parent_node_rec_index :=	null;

			l_node_idx := l_node_idx + 1;
			l_nodes_tbl(l_node_idx)	:= l_node_rec;

			OPEN get_ctr_rule_update_csr (l_node_csr_rec.relationship_id);
			LOOP
				FETCH get_ctr_rule_update_csr INTO l_ctr_rule_csr_rec;
				EXIT WHEN get_ctr_rule_update_csr%NOTFOUND;

				-- 7g.v.	Read all values	from l_ctr_rule_csr_rec	into l_ctr_rule_rec
				l_ctr_rule_rec.ctr_update_rule_id := l_ctr_rule_csr_rec.ctr_update_rule_id;
				l_ctr_rule_rec.relationship_id := l_ctr_rule_csr_rec.relationship_id;
				l_ctr_rule_rec.uom_code	:= l_ctr_rule_csr_rec.uom_code;
				l_ctr_rule_rec.rule_code :=	l_ctr_rule_csr_rec.rule_code;
				AHL_UTIL_MC_PKG.Convert_To_LookupMeaning ('AHL_COUNTER_RULE_TYPE', l_ctr_rule_rec.rule_code, l_ctr_rule_rec.rule_meaning, l_ret_val);
				l_ctr_rule_rec.ratio :=	l_ctr_rule_csr_rec.ratio;
				l_ctr_rule_rec.object_version_number :=	1;
				l_ctr_rule_rec.attribute_category := l_ctr_rule_csr_rec.attribute_category;
				l_ctr_rule_rec.attribute1 := l_ctr_rule_csr_rec.attribute1;
				l_ctr_rule_rec.attribute2 := l_ctr_rule_csr_rec.attribute2;
				l_ctr_rule_rec.attribute3 := l_ctr_rule_csr_rec.attribute3;
				l_ctr_rule_rec.attribute4 := l_ctr_rule_csr_rec.attribute4;
				l_ctr_rule_rec.attribute5 := l_ctr_rule_csr_rec.attribute5;
				l_ctr_rule_rec.attribute6 := l_ctr_rule_csr_rec.attribute6;
				l_ctr_rule_rec.attribute7 := l_ctr_rule_csr_rec.attribute7;
				l_ctr_rule_rec.attribute8 := l_ctr_rule_csr_rec.attribute8;
				l_ctr_rule_rec.attribute9 := l_ctr_rule_csr_rec.attribute9;
				l_ctr_rule_rec.attribute10 := l_ctr_rule_csr_rec.attribute10;
				l_ctr_rule_rec.attribute11 := l_ctr_rule_csr_rec.attribute11;
				l_ctr_rule_rec.attribute12 := l_ctr_rule_csr_rec.attribute12;
				l_ctr_rule_rec.attribute13 := l_ctr_rule_csr_rec.attribute13;
				l_ctr_rule_rec.attribute14 := l_ctr_rule_csr_rec.attribute14;
				l_ctr_rule_rec.attribute15 := l_ctr_rule_csr_rec.attribute15;
				l_ctr_rule_rec.operation_flag := G_DML_CREATE;

				l_ctr_rule_rec.node_tbl_index := l_node_idx;
				l_ctr_rule_idx := l_ctr_rule_idx + 1;
				l_ctr_rules_tbl(l_ctr_rule_idx)	:= l_ctr_rule_rec;
			END	LOOP;
			CLOSE get_ctr_rule_update_csr;
		END	IF;
	END	LOOP;
	CLOSE get_mc_tree_csr;

	IF (l_nodes_tbl.COUNT >	0)
	THEN
		IF (p_node_copy	= TRUE)
		THEN
			-- Implies copying a MC	node to	another	MC node
			l_nodes_tbl(1).parent_relationship_id := p_dest_rel_id;

			-- Read	max	display_order of the children of p_dest_rel_id
			OPEN get_max_dispord(p_dest_rel_id);
			FETCH get_max_dispord INTO l_max_dispord;
			CLOSE get_max_dispord;

			l_nodes_tbl(1).display_order :=	nvl(l_max_dispord, 0) +	1;
		END	IF;

		-- 7j.	Iterate	through	the	l_nodes_tbl, to	nullify	relationship_id	and	populate parent_node_rec_index
		FOR	i IN 1..l_nodes_tbl.COUNT
		LOOP
			FOR	j IN i+1..l_nodes_tbl.LAST
			LOOP
				IF (l_nodes_tbl(j).PARENT_RELATIONSHIP_ID =	l_nodes_tbl(i).RELATIONSHIP_ID)
				THEN
					l_nodes_tbl(j).PARENT_NODE_REC_INDEX :=	i;
					l_nodes_tbl(j).PARENT_RELATIONSHIP_ID := NULL;
				END	IF;
			END	LOOP;

			-- For documents copy and subconfigurations	copy
			l_old_node_id_tbl(i) :=	l_nodes_tbl(i).RELATIONSHIP_ID;
			l_nodes_tbl(i).RELATIONSHIP_ID := NULL;
		END	LOOP;

		-- 7l.	Iterate	through	the	l_nodes_tbl	table to create	the	nodes and associated counter rules
		FOR	i IN l_nodes_tbl.FIRST..l_nodes_tbl.LAST
		LOOP
			IF (p_node_copy	= FALSE	AND	l_nodes_tbl(i).parent_relationship_id =	p_source_rel_id)
			THEN
				-- Implies copying entire MC tree into another with	the	topnode	already	created
				l_nodes_tbl(i).parent_relationship_id := p_dest_rel_id;
			END	IF;

			l_ctr_iterator := 0;

			IF (fnd_log.level_statement	>= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.string
				(
					fnd_log.level_statement,
					'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
					'Creating new node with	parent node	['||l_nodes_tbl(i).parent_relationship_id||'], position	reference ['||l_nodes_tbl(i).position_ref_code||']'
				);
			END	IF;

			-- 7l.iii.	Iterate	through	the	l_ctr_rules_table and construct	a counter rules	table for the particular node in consideration
			IF (l_ctr_rules_tbl.COUNT >	0)
			THEN
				FOR	j IN l_ctr_rules_tbl.FIRST..l_ctr_rules_tbl.LAST
				LOOP
					IF (l_ctr_rules_tbl(j).node_tbl_index =	i)
					THEN
						l_ctr_iterator := l_ctr_iterator + 1;
						l_node_ctr_rules_tbl(l_ctr_iterator) :=	l_ctr_rules_tbl(j);

						IF (fnd_log.level_statement	>= fnd_log.g_current_runtime_level)
						THEN
							fnd_log.string
							(
								fnd_log.level_statement,
								'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
								'Creating new counter rule ['||l_node_ctr_rules_tbl(l_ctr_iterator).ctr_update_rule_id||']'
							);
						END	IF;
					END	IF;
				END	LOOP;
			END	IF;

			-- 7l.iv.	Call AHL_MC_Node_PVT.Create_Node
			Create_Node
			(
				p_api_version		=> 1.0,
				p_init_msg_list		=> FND_API.G_FALSE,
				p_commit		=> FND_API.G_FALSE,
				p_validation_level	=> FND_API.G_VALID_LEVEL_FULL,
				x_return_status		=> l_return_status,
				x_msg_count			=> l_msg_count,
				x_msg_data		=> l_msg_data,
				p_x_node_rec		=> l_nodes_tbl(i),
				p_x_counter_rules_tbl	=> l_node_ctr_rules_tbl,
				p_x_subconfig_tbl	=> l_subconfig_tbl
			);

			-- Check Error Message stack.
			x_msg_count	:= FND_MSG_PUB.count_msg;
			IF x_msg_count > 0 THEN
				RAISE FND_API.G_EXC_ERROR;
			END	IF;

			IF (fnd_log.level_statement	>= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.string
				(
					fnd_log.level_statement,
					'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
					'New Node ['||l_nodes_tbl(i).relationship_id||', '||l_nodes_tbl(i).position_ref_code||'] created'
				);
			END	IF;

			-- 7l.v.	Set	parent_relationship_id for all nodes that refer	this newly created node	as parent
			FOR	x IN i+1..l_nodes_tbl.COUNT
			LOOP
				IF (l_nodes_tbl(x).PARENT_NODE_REC_INDEX = i)
				THEN
					l_nodes_tbl(x).PARENT_RELATIONSHIP_ID := l_nodes_tbl(i).RELATIONSHIP_ID;

					IF (fnd_log.level_statement	>= fnd_log.g_current_runtime_level)
					THEN
						fnd_log.string
						(
							fnd_log.level_statement,
							'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
							'Populated node	['||l_nodes_tbl(x).position_ref_code||'] with parent relationship id ['||l_nodes_tbl(i).RELATIONSHIP_ID||']'
						);
					END	IF;
				END	IF;
			END	LOOP;
		END	LOOP;

		-- 7m.	Iterate	through	the	l_node_tbl table to	copy all document and subconfiguration associations
		FOR	i IN l_nodes_tbl.FIRST..l_nodes_tbl.LAST
		LOOP
			IF (fnd_log.level_statement	>= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.string
				(
					fnd_log.level_statement,
					'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
					'Document associations for node	['||l_old_node_id_tbl(i)||'] copied	to node	['||l_nodes_tbl(i).relationship_id||']'
				);
			END	IF;

			-- 7m.i.	Call AHL_DI_ASSO_DOC_GEN_PVT.COPY_ASSOCIATION
			AHL_DI_ASSO_DOC_GEN_PVT.COPY_ASSOCIATION
			(
				p_api_version		  => 1.0,
				p_commit			  => FND_API.G_FALSE,
				p_validation_level	  => FND_API.G_VALID_LEVEL_FULL,
				p_from_object_id	  => l_old_node_id_tbl(i),
				p_from_object_type	  => 'MC',
				p_to_object_id		  => l_nodes_tbl(i).relationship_id,
				p_to_object_type	  => 'MC',
				x_return_status		  => l_return_status,
				x_msg_count			  => l_msg_count,
				x_msg_data			  => l_msg_data
			);

			-- Check Error Message stack.
			x_msg_count	:= FND_MSG_PUB.count_msg;
			IF x_msg_count > 0 THEN
				RAISE FND_API.G_EXC_ERROR;
			END	IF;

			IF (fnd_log.level_statement	>= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.string
				(
					fnd_log.level_statement,
					'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
					'Subconfig associations	for	node ['||l_old_node_id_tbl(i)||'] copied to	node ['||l_nodes_tbl(i).relationship_id||']'
				);
			END	IF;

			-- 7m.ii.	Call AHL_MC_SubConfig_PVT.Copy_SubConfig
			Copy_SubConfig
			(
				l_old_node_id_tbl(i),
				l_nodes_tbl(i).relationship_id
			);

			-- Check Error Message stack.
			x_msg_count	:= FND_MSG_PUB.count_msg;
			IF x_msg_count > 0 THEN
				RAISE FND_API.G_EXC_ERROR;
			END	IF;
		END	LOOP;
	END	IF;

	IF (fnd_log.level_procedure	>= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||'.end',
			'At	the	end	of PLSQL procedure'
		);
	END	IF;
	-- API body	ends here

	-- Check Error Message stack.
	x_msg_count	:= FND_MSG_PUB.count_msg;
	IF x_msg_count > 0 THEN
		RAISE FND_API.G_EXC_ERROR;
	END	IF;

	-- Standard	check for p_commit
	IF FND_API.TO_BOOLEAN (p_commit)
	THEN
		COMMIT WORK;
	END	IF;

	-- Standard	call to	get	message	count and if count is 1, get message info
	FND_MSG_PUB.count_and_get
	(
		p_count		=> x_msg_count,
		p_data		=> x_msg_data,
		p_encoded	=> FND_API.G_FALSE
	);

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status	:= FND_API.G_RET_STS_ERROR;
		Rollback to	Copy_MC_Nodes_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count		=> x_msg_count,
			p_data		=> x_msg_data,
			p_encoded	=> FND_API.G_FALSE
		);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR	THEN
		x_return_status	:= FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to	Copy_MC_Nodes_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count		=> x_msg_count,
			p_data		=> x_msg_data,
			p_encoded	=> FND_API.G_FALSE
		);

	WHEN OTHERS	THEN
		x_return_status	:= FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to	Copy_MC_Nodes_SP;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.add_exc_msg
			(
				p_pkg_name		=> G_PKG_NAME,
				p_procedure_name	=> 'Copy_MC_Nodes',
				p_error_text		=> SUBSTR(SQLERRM,1,240)
			);
		END	IF;
		FND_MSG_PUB.count_and_get
		(
			p_count		=> x_msg_count,
			p_data		=> x_msg_data,
			p_encoded	=> FND_API.G_FALSE
		);

END	Copy_MC_Nodes;

PROCEDURE Process_Documents
(
	p_api_version		IN		NUMBER,
	p_init_msg_list			IN		VARCHAR2	:= FND_API.G_FALSE,
	p_commit				IN		VARCHAR2	:= FND_API.G_FALSE,
	p_validation_level		IN		NUMBER		:= FND_API.G_VALID_LEVEL_FULL,
	x_return_status			OUT		NOCOPY	VARCHAR2,
	x_msg_count				OUT		NOCOPY	NUMBER,
	x_msg_data				OUT		NOCOPY	VARCHAR2,
	p_node_id		IN		NUMBER,
	p_x_documents_tbl	IN OUT	NOCOPY	AHL_DI_ASSO_DOC_GEN_PUB.association_tbl
)
IS

	-- 1.	Define local variables
	l_api_name	CONSTANT	VARCHAR2(30)	:= 'Process_Documents';
	l_api_version	CONSTANT	NUMBER		:= 1.0;
	l_return_status			VARCHAR2(1);
	l_msg_count					NUMBER;
	l_msg_data					VARCHAR2(2000);

	l_header_status			VARCHAR2(30);

BEGIN

	-- Standard	start of API savepoint
	SAVEPOINT Process_Documents_SP;

	-- Standard	call to	check for call compatibility
	IF NOT FND_API.compatible_api_call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END	IF;

	-- Initialize message list if p_init_msg_list is set to	TRUE
	IF FND_API.TO_BOOLEAN(p_init_msg_list)
	THEN
		FND_MSG_PUB.Initialize;
	END	IF;

	-- Initialize API return status	to success
	x_return_status	:= FND_API.G_RET_STS_SUCCESS;

	-- API body	starts here
	IF (fnd_log.level_procedure	>= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||'.begin',
			'At	the	start of PLSQL procedure'
		);
	END	IF;

	-- 5.	Validate a MC node with	relationship_id	= p_node_id	exists
	Validate_Node_Exists (p_node_id, null);

	l_header_status	:= Get_MC_Status(p_node_id,	null);
	-- 6i.	Validate that the config_status_code of	the	MC is 'DRAFT' or 'APPROVAL_REJECTED'
        -- FP #8410484
	IF NOT (l_header_status	IN ('DRAFT', 'APPROVAL_REJECTED', 'COMPLETE'))
	THEN
		FND_MESSAGE.Set_Name('AHL', 'AHL_DI_ASSO_UPDATE_ERROR');
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
				false
			);
		END	IF;
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_header_status = 'APPROVAL_REJECTED')
	THEN
		-- 6ii.	Set	status of MC to	DRAFT if APPROVAL_REJECTED
		Set_Header_Status(p_node_id);
	END	IF;

	-- Check Error Message stack.
	x_msg_count	:= FND_MSG_PUB.count_msg;
	IF x_msg_count > 0 THEN
		RAISE FND_API.G_EXC_ERROR;
	END	IF;

	IF (fnd_log.level_statement	>= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
			'Node validation successful'
		);
	END	IF;

	IF (p_x_documents_tbl.COUNT	> 0)
	THEN
		FOR	i IN p_x_documents_tbl.FIRST..p_x_documents_tbl.LAST
		LOOP
			p_x_documents_tbl(i).aso_object_id := p_node_id;
			p_x_documents_tbl(i).aso_object_type_code := 'MC';

			-- If revision not chosen, throw error
			IF (p_x_documents_tbl(i).REVISION_NO IS	NULL AND p_x_documents_tbl(i).dml_operation	<> G_DML_DELETE)
			THEN
				FND_MESSAGE.Set_Name('AHL',	'AHL_MC_DOC_NO_REV');
				FND_MESSAGE.Set_Token('DOC', p_x_documents_tbl(i).DOCUMENT_NO);
				FND_MSG_PUB.ADD;
				IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
				THEN
					fnd_log.message
					(
						fnd_log.level_exception,
						'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
						false
					);
				END	IF;
			END	IF;
		END	LOOP;

		-- Check Error Message stack.
		x_msg_count	:= FND_MSG_PUB.count_msg;
		IF x_msg_count > 0 THEN
			RAISE FND_API.G_EXC_ERROR;
		END	IF;

		IF (fnd_log.level_statement	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_statement,
				'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
				'Document association validations successful...	Calling	AHL_DI_ASSO_DOC_GEN_PUB.PROCESS_ASSOCIATION'
			);
		END	IF;

		AHL_DI_ASSO_DOC_GEN_PUB.PROCESS_ASSOCIATION
		(
			p_api_version			=> 1.0,
			p_init_msg_list		=> FND_API.G_FALSE,
			p_commit		=> FND_API.G_FALSE,
			p_validate_only		=> FND_API.G_FALSE,
			p_validation_level	=> FND_API.G_VALID_LEVEL_FULL,
			p_x_association_tbl	=> p_x_documents_tbl,
			p_module_type		=> 'JSP',
			x_return_status			=> l_return_status,
			x_msg_count				=> l_msg_count,
			x_msg_data				=> l_msg_data
		);
	END	IF;

	IF (fnd_log.level_procedure	>= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||'.end',
			'At	the	end	of PLSQL procedure'
		);
	END	IF;
	-- API body	ends here

	-- Check Error Message stack.
	x_msg_count	:= FND_MSG_PUB.count_msg;
	IF x_msg_count > 0 THEN
		RAISE FND_API.G_EXC_ERROR;
	END	IF;

	-- Standard	check for p_commit
	IF FND_API.TO_BOOLEAN (p_commit)
	THEN
		COMMIT WORK;
	END	IF;

	-- Standard	call to	get	message	count and if count is 1, get message info
	FND_MSG_PUB.count_and_get
	(
		p_count		=> x_msg_count,
		p_data		=> x_msg_data,
		p_encoded	=> FND_API.G_FALSE
	);

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status	:= FND_API.G_RET_STS_ERROR;
		Rollback to	Process_Documents_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count		=> x_msg_count,
			p_data		=> x_msg_data,
			p_encoded	=> FND_API.G_FALSE
		);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR	THEN
		x_return_status	:= FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to	Process_Documents_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count		=> x_msg_count,
			p_data		=> x_msg_data,
			p_encoded	=> FND_API.G_FALSE
		);

	WHEN OTHERS	THEN
		x_return_status	:= FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to	Process_Documents_SP;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.add_exc_msg
			(
				p_pkg_name		=> G_PKG_NAME,
				p_procedure_name	=> 'Process_Documents',
				p_error_text		=> SUBSTR(SQLERRM,1,240)
			);
		END	IF;
		FND_MSG_PUB.count_and_get
		(
			p_count		=> x_msg_count,
			p_data		=> x_msg_data,
			p_encoded	=> FND_API.G_FALSE
		);

END	Process_Documents;

PROCEDURE Associate_Item_Group
(
	p_api_version		IN		NUMBER,
	p_init_msg_list			IN		VARCHAR2	:= FND_API.G_FALSE,
	p_commit				IN		VARCHAR2	:= FND_API.G_FALSE,
	p_validation_level		IN		NUMBER		:= FND_API.G_VALID_LEVEL_FULL,
	x_return_status			OUT		NOCOPY	VARCHAR2,
	x_msg_count				OUT		NOCOPY	NUMBER,
	x_msg_data				OUT		NOCOPY	VARCHAR2,
	p_nodes_tbl		IN		Node_Tbl_Type
)
IS

	-- Define cursor get_item_group_det	to validate	item group exists
	CURSOR get_item_group_det
	(
		p_ig_id	in number
	)
	IS
		SELECT	type_code, name
		FROM	ahl_item_groups_b
		WHERE	item_group_id =	p_ig_id;

	-- Define get_item_group_id	to retrieve	item_group_id given	name of	the	item group
        -- SATHAPLI::made the item group name join case sensitive
	CURSOR get_item_group_csr
	(
		p_ig_name in VARCHAR2
	)
	IS
		SELECT	item_group_id, type_code, name
		FROM	ahl_item_groups_b
		WHERE	name = p_ig_name AND
			source_item_group_id IS	NULL;

	-- 1.	Define local variables
	l_api_name	CONSTANT	VARCHAR2(30)	:= 'Associate_Item_Group';
	l_api_version	CONSTANT	NUMBER		:= 1.0;

	l_header_status			VARCHAR2(30);
	l_item_group_id			NUMBER;
	l_type_code						VARCHAR2(30);
	l_item_group_name				VARCHAR2(80);

BEGIN

	-- Standard	start of API savepoint
	SAVEPOINT Associate_Item_Group_SP;

	-- Standard	call to	check for call compatibility
	IF NOT FND_API.compatible_api_call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END	IF;

	-- Initialize message list if p_init_msg_list is set to	TRUE
	IF FND_API.TO_BOOLEAN(p_init_msg_list)
	THEN
		FND_MSG_PUB.Initialize;
	END	IF;

	-- Initialize API return status	to success
	x_return_status	:= FND_API.G_RET_STS_SUCCESS;

	-- API body	starts here
	IF (fnd_log.level_procedure	>= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||'.begin',
			'At	the	start of PLSQL procedure'
		);
	END	IF;

	IF (p_nodes_tbl.COUNT >	0)
	THEN
		FOR	i IN p_nodes_tbl.FIRST..p_nodes_tbl.LAST
		LOOP
			-- Validate	config_status_code of the MC is	'DRAFT'	or 'APPROVAL_REJECTED'
			l_header_status	:= Get_MC_Status(p_nodes_tbl(i).relationship_id, null);
			IF NOT (l_header_status	IN ('DRAFT', 'APPROVAL_REJECTED'))
			THEN
				FND_MESSAGE.Set_Name('AHL',	'AHL_MC_NODE_STS_INV');
				FND_MSG_PUB.ADD;
				IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
				THEN
					fnd_log.message
					(
						fnd_log.level_exception,
						'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
						false
					);
				END	IF;
				RAISE FND_API.G_EXC_ERROR;
			ELSIF (l_header_status = 'APPROVAL_REJECTED')
			THEN
				-- Set status of MC	to DRAFT if	APPROVAL_REJECTED
				Set_Header_Status(p_nodes_tbl(i).relationship_id);
			END	IF;

			-- Validate	a MC node with relationship_id = p_x_node_rec.relationship_id exists
			Validate_Node_Exists(p_nodes_tbl(i).relationship_id, null);

			-- Validate	p_x_node_rec.item_group_id exists
			IF (p_nodes_tbl(i).ITEM_GROUP_ID IS	NOT	NULL)
			THEN
				OPEN get_item_group_det	(p_nodes_tbl(i).item_group_id);
				FETCH get_item_group_det INTO l_type_code,l_item_group_name;
				IF (get_item_group_det%NOTFOUND)
				THEN
					FND_MESSAGE.Set_Name('AHL',	'AHL_MC_ITEMGRP_INVALID');
					FND_MESSAGE.Set_Token('ITEM_GRP', p_nodes_tbl(i).item_group_id);
					FND_MSG_PUB.ADD;
					IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
					THEN
						fnd_log.message
						(
							fnd_log.level_exception,
							'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
							false
						);
					END	IF;
				ELSE
						IF l_type_code = 'TRACKED' THEN
						l_item_group_id	:= p_nodes_tbl(i).item_group_id;
					ELSE
						FND_MESSAGE.Set_Name('AHL',	'AHL_MC_IG_NOT_TRACKED');
						FND_MESSAGE.Set_Token('IG_NAME', l_item_group_name);
						FND_MSG_PUB.ADD;
					END	IF;

				END	IF;
				CLOSE get_item_group_det;
			ELSIF (p_nodes_tbl(i).item_group_name IS NOT NULL)
			THEN
				OPEN get_item_group_csr	(p_nodes_tbl(i).item_group_name);
				FETCH get_item_group_csr INTO l_item_group_id,l_type_code,l_item_group_name;
				IF (get_item_group_csr%NOTFOUND)
				THEN
					FND_MESSAGE.Set_Name('AHL',	'AHL_MC_ITEMGRP_INVALID');
					FND_MESSAGE.Set_Token('ITEM_GRP', p_nodes_tbl(i).item_group_name);
					FND_MSG_PUB.ADD;
					IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
					THEN
						fnd_log.message
						(
							fnd_log.level_exception,
							'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
							false
						);
					END	IF;
				ELSIF l_type_code <> 'TRACKED' THEN
					FND_MESSAGE.Set_Name('AHL',	'AHL_MC_IG_NOT_TRACKED');
					FND_MESSAGE.Set_Token('IG_NAME', l_item_group_name);
					FND_MSG_PUB.ADD;
				END	IF;
				CLOSE get_item_group_csr;
			ELSE
				FND_MESSAGE.Set_Name('AHL',	'AHL_MC_ITEMGRP_NULL');
				FND_MSG_PUB.ADD;
				IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
				THEN
					fnd_log.message
					(
						fnd_log.level_exception,
						'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
						false
					);
				END	IF;
			END	IF;

			IF (fnd_log.level_statement	>= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.string
				(
					fnd_log.level_statement,
					'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
					'Validation	successful'
				);
			END	IF;

			-- Check Error Message stack.
			x_msg_count	:= FND_MSG_PUB.count_msg;
			IF x_msg_count > 0 THEN
				RAISE FND_API.G_EXC_ERROR;
			END	IF;

			UPDATE ahl_mc_relationships
			SET	item_group_id =	l_item_group_id
			WHERE relationship_id =	p_nodes_tbl(i).relationship_id;

			IF (fnd_log.level_statement	>= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.string
				(
					fnd_log.level_statement,
					'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
					'Updated MC	node ['||p_nodes_tbl(i).relationship_id||']	with new item group	id ['||l_item_group_id||']'
				);
			END	IF;
		END	LOOP;
	END	IF;

	IF (fnd_log.level_procedure	>= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||'.end',
			'At	the	end	of PLSQL procedure'
		);
	END	IF;
	-- API body	ends here

	-- Check Error Message stack.
	x_msg_count	:= FND_MSG_PUB.count_msg;
	IF x_msg_count > 0 THEN
		RAISE FND_API.G_EXC_ERROR;
	END	IF;

	-- Standard	check for p_commit
	IF FND_API.TO_BOOLEAN (p_commit)
	THEN
		COMMIT WORK;
	END	IF;

	-- Standard	call to	get	message	count and if count is 1, get message info
	FND_MSG_PUB.count_and_get
	(
		p_count		=> x_msg_count,
		p_data		=> x_msg_data,
		p_encoded	=> FND_API.G_FALSE
	);

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status	:= FND_API.G_RET_STS_ERROR;
		Rollback to	Associate_Item_Group_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count		=> x_msg_count,
			p_data		=> x_msg_data,
			p_encoded	=> FND_API.G_FALSE
		);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR	THEN
		x_return_status	:= FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to	Associate_Item_Group_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count		=> x_msg_count,
			p_data		=> x_msg_data,
			p_encoded	=> FND_API.G_FALSE
		);

	WHEN OTHERS	THEN
		x_return_status	:= FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to	Associate_Item_Group_SP;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.add_exc_msg
			(
				p_pkg_name		=> G_PKG_NAME,
				p_procedure_name	=> 'Associate_Item_Group',
				p_error_text		=> SUBSTR(SQLERRM,1,240)
			);
		END	IF;
		FND_MSG_PUB.count_and_get
		(
			p_count		=> x_msg_count,
			p_data		=> x_msg_data,
			p_encoded	=> FND_API.G_FALSE
		);

END	Associate_Item_Group;

---------------------------
-- Validation procedures --
---------------------------
PROCEDURE Validate_Node_Exists
(
	p_rel_id in	number,
	p_object_ver_num in	number
)
IS

	CURSOR check_node_exists
	IS
		SELECT	object_version_number
		FROM	ahl_mc_relationships
		WHERE	relationship_id	= p_rel_id;

BEGIN

	OPEN check_node_exists;
	FETCH check_node_exists	INTO l_dummy_number;
	IF (check_node_exists%NOTFOUND)
	THEN
		FND_MESSAGE.Set_Name('AHL',	'AHL_MC_NODE_NOT_FOUND');
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.'||G_PKG_NAME||'.Validate_Node_Exists',
				false
			);
		END	IF;
		CLOSE check_node_exists;
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (NVL(p_object_ver_num, l_dummy_number) <>	l_dummy_number)
	THEN
		FND_MESSAGE.Set_Name('AHL',	'AHL_COM_RECORD_CHANGED');
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.'||G_PKG_NAME||'.Validate_Node_Exists',
				false
			);
		END	IF;
		CLOSE check_node_exists;
		RAISE FND_API.G_EXC_ERROR;
	END	IF;
	CLOSE check_node_exists;

END	Validate_Node_Exists;

PROCEDURE Validate_Node
(
	p_x_node_rec in	out	nocopy Node_Rec_Type
)
IS
	-- Define cursor get_node_details to check parent quantity = 1 and not expired
	CURSOR get_node_details
	IS
		SELECT	quantity,
			active_end_date
		FROM	ahl_mc_relationships
		WHERE	relationship_id	= p_x_node_rec.parent_relationship_id;

	-- Define cursor check_subconfig_assos to check	whether	the	parent node	has	any	subconfig associations
	CURSOR check_subconfig_assos
	IS
		SELECT	'x'
		FROM	ahl_mc_config_relations
		WHERE	relationship_id	= p_x_node_rec.parent_relationship_id;
			-- Since expired subconfig associations	can	be unexpired, so no	need to	filter on active_end_date
			-- AND G_TRUNC_DATE	< trunc(nvl(active_end_date, G_SYSDATE + 1));

	-- Define cursor check_dup_pos_ref to check	whether	the	parent node	does not have the same position	reference
	CURSOR check_dup_pos_ref
	IS
		SELECT	'x'
		FROM	ahl_mc_relationships
		WHERE	position_ref_code =	p_x_node_rec.position_ref_code AND
			parent_relationship_id = p_x_node_rec.parent_relationship_id AND
			G_TRUNC_DATE < trunc(nvl(active_end_date, G_SYSDATE	+ 1)) AND
			relationship_id	<> nvl(p_x_node_rec.relationship_id, -1);

	-- Define cursor check_topnode_exists to check whether a topnode already exists	for	the	MC
	CURSOR check_topnode_exists
	IS
		SELECT	'x'
		FROM	ahl_mc_relationships
		WHERE	parent_relationship_id is null AND
			mc_header_id = p_x_node_rec.mc_header_id;

	-- Define cursor get_item_group_id to retrieve item	group id, type and status
        -- SATHAPLI::Bug 9089133, 08-Feb-2010, made the item group name join case sensitive
	CURSOR get_item_group_id
	IS
		SELECT	item_group_id, type_code, status_code
		FROM	ahl_item_groups_b
		WHERE	name = p_x_node_rec.item_group_name AND
			source_item_group_id IS	NULL;

	-- Define cursor check_item_assos_qty to check quantity	 = 1 for all item associations
        -- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 04-Dec-2007
        -- As non-serialized items having quantities greater than 1 can be associated to an item group now,
        -- this check should not be there to restrict them from being used in MC positions.
        /*
	CURSOR check_item_assos_qty
	IS
		SELECT	'x'
		FROM	ahl_item_associations_b
		WHERE	item_group_id =	p_x_node_rec.item_group_id AND
				quantity <>	1;
        */

	-- Define cursor check_child_exists	to check whether the node has any children in which	case quantity =	1
	CURSOR check_child_exists
	IS
		SELECT	'x'
		FROM	ahl_mc_relationships
		WHERE	parent_relationship_id = p_x_node_rec.relationship_id
			AND	G_TRUNC_DATE < trunc(nvl(active_end_date, G_SYSDATE	+ 1));

	-- Define cursor check_dup_display_order to	check display order	duplication
	CURSOR check_dup_display_order
	IS
		SELECT	'x'
		FROM	ahl_mc_relationships
		WHERE	display_order =	p_x_node_rec.display_order AND
			parent_relationship_id = p_x_node_rec.parent_relationship_id AND
			G_TRUNC_DATE < trunc(nvl(active_end_date, G_SYSDATE	+ 1)) AND
				relationship_id	<> nvl(p_x_node_rec.relationship_id, -1);

	-- Define cursor get_node_dates	to retrieve	start and end date of the node
	CURSOR get_node_dates
	IS
		SELECT active_start_date, active_end_date
		FROM ahl_mc_relationships
		WHERE relationship_id =	p_x_node_rec.relationship_id;

	-- Declare local variables
	l_qty		NUMBER;
	l_ret_val	BOOLEAN;
	l_ig_type	VARCHAR2(30);
	l_ig_status	VARCHAR2(30);
	l_start_date	DATE;
	l_end_date	DATE;

BEGIN

	-- Validate	MC parent node
	IF (p_x_node_rec.parent_relationship_id	IS NOT NULL)
	THEN
		OPEN get_node_details;
		FETCH get_node_details INTO	l_qty, l_end_date;
		IF (get_node_details%NOTFOUND)
		THEN
			-- 2a.	Validate that the parent node exists
			FND_MESSAGE.Set_Name('AHL',	'AHL_MC_PARENT_INVALID');
			FND_MSG_PUB.ADD;
			IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.message
				(
					fnd_log.level_exception,
					'ahl.plsql.'||G_PKG_NAME||'.Validate_Node',
					false
				);
			END	IF;

			CLOSE get_node_details;
			RAISE FND_API.G_EXC_ERROR;
		ELSE
			CLOSE get_node_details;

			-- 2c.	Validate that the parent node has quantity = 1 [only in	this can a child node be added to the parent position]
			IF (l_qty <> 1)
			THEN
				FND_MESSAGE.Set_Name('AHL',	'AHL_MC_PARENT_QTY_INV');
				FND_MSG_PUB.ADD;
				IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
				THEN
					fnd_log.message
					(
						fnd_log.level_exception,
						'ahl.plsql.'||G_PKG_NAME||'.Validate_Node',
						false
					);
				END	IF;
			END	IF;

			-- 2d.	Validate for the parent	node active_end_date > SYSDATE
			IF (trunc(nvl(l_end_date, G_SYSDATE	+ 1)) <= G_TRUNC_DATE)
			THEN
				FND_MESSAGE.Set_Name('AHL',	'AHL_MC_PARENT_DATE_INV');
				FND_MSG_PUB.ADD;
				IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
				THEN
					fnd_log.message
					(
						fnd_log.level_exception,
						'ahl.plsql.'||G_PKG_NAME||'.Validate_Node',
						false
					);
				END	IF;
			END	IF;

			-- 2e.	Validate that the parent node has no subconfiguration associations
			OPEN check_subconfig_assos;
			FETCH check_subconfig_assos	INTO l_dummy_varchar;
			IF (check_subconfig_assos%FOUND)
			THEN
				FND_MESSAGE.Set_Name('AHL',	'AHL_MC_PARENT_HAS_SUBMC');
				FND_MSG_PUB.ADD;
				IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
				THEN
					fnd_log.message
					(
						fnd_log.level_exception,
						'ahl.plsql.'||G_PKG_NAME||'.Validate_Node',
						false
					);
				END	IF;
			END	IF;
			CLOSE check_subconfig_assos;

			-- 2f.	Validate that the parent node does not already have	any	child node with	the	same position reference	code
			OPEN check_dup_pos_ref;
			FETCH check_dup_pos_ref	INTO l_dummy_varchar;
			IF (check_dup_pos_ref%FOUND)
			THEN
				FND_MESSAGE.Set_Name('AHL',	'AHL_MC_PARCHD_INVALID');
				FND_MESSAGE.Set_Token('CHILD', p_x_node_rec.position_ref_meaning);
				FND_MSG_PUB.ADD;
				IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
				THEN
					fnd_log.message
					(
						fnd_log.level_exception,
						'ahl.plsql.'||G_PKG_NAME||'.Validate_Node',
						false
					);
				END	IF;
			END	IF;
			CLOSE check_dup_pos_ref;
		END	IF;
	ELSIF (p_x_node_rec.operation_flag = G_DML_CREATE OR p_x_node_rec.operation_flag = G_DML_COPY)
	THEN
		-- Validate	whether	a root-node	exists already
		OPEN check_topnode_exists;
		FETCH check_topnode_exists INTO	l_dummy_varchar;
		IF (check_topnode_exists%FOUND)
		THEN
			FND_MESSAGE.Set_Name('AHL',	'AHL_MC_PARENT_EXISTS');
			FND_MSG_PUB.ADD;
			IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.message
				(
					fnd_log.level_exception,
					'ahl.plsql.'||G_PKG_NAME||'.Validate_Node',
					false
				);
			END	IF;
			CLOSE check_topnode_exists;
			RAISE FND_API.G_EXC_ERROR;
		END	IF;
		CLOSE check_topnode_exists;
	END	IF;

	-- Validate	position reference
	p_x_node_rec.position_ref_meaning := RTRIM(p_x_node_rec.position_ref_meaning);

	IF (p_x_node_rec.position_ref_meaning IS NULL)
	THEN
		-- This	is a mandatory field, hence	throw error
		FND_MESSAGE.Set_Name('AHL',	'AHL_MC_POSREF_NULL');
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.'||G_PKG_NAME||'.Validate_Node',
				false
			);
		END	IF;
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
			FND_MESSAGE.Set_Name('AHL',	'AHL_MC_POSREF_INVALID');
			FND_MESSAGE.Set_Token('POSREF',	p_x_node_rec.position_ref_meaning);
			FND_MSG_PUB.ADD;
			IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.message
				(
					fnd_log.level_exception,
					'ahl.plsql.'||G_PKG_NAME||'.Validate_Node',
					false
				);
			END	IF;
		END	IF;
	END	IF;

	-- Validate	position Necessity
	IF (p_x_node_rec.position_necessity_code IS	NULL)
	THEN
		-- This	is a mandatory field, hence	throw error
		FND_MESSAGE.Set_Name('AHL',	'AHL_MC_NECESSITY_NULL');
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.'||G_PKG_NAME||'.Validate_Node',
				false
			);
		END	IF;
	ELSIF NOT (AHL_UTIL_MC_PKG.Validate_Lookup_Code('AHL_POSITION_NECESSITY', p_x_node_rec.position_necessity_code))
	THEN
		FND_MESSAGE.Set_Name('AHL',	'AHL_MC_NECESSITY_INVALID');
		FND_MESSAGE.Set_Token('POSREF',	p_x_node_rec.position_ref_meaning);
		FND_MESSAGE.Set_Token('CODE', p_x_node_rec.position_necessity_code);
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.'||G_PKG_NAME||'.Validate_Node',
				false
			);
		END	IF;
	END	IF;

	-- Validate	item group
	p_x_node_rec.item_group_name :=	RTRIM(p_x_node_rec.item_group_name);

	IF (p_x_node_rec.item_group_name IS	NOT	NULL)
	THEN
		OPEN get_item_group_id;
		FETCH get_item_group_id	INTO p_x_node_rec.item_group_id, l_ig_type,	l_ig_status;
		IF (get_item_group_id%NOTFOUND)
		THEN
			FND_MESSAGE.Set_Name('AHL',	'AHL_MC_ITEMGRP_INVALID');
			FND_MESSAGE.Set_Token('ITEM_GRP', p_x_node_rec.item_group_name);
			FND_MSG_PUB.ADD;
			IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.message
				(
					fnd_log.level_exception,
					'ahl.plsql.'||G_PKG_NAME||'.Validate_Node',
					false
				);
			END	IF;
		ELSE

                        -- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 04-Dec-2007
                        -- As non-serialized items having quantities greater than 1 can be associated to an item group now,
                        -- this check should not be there to restrict them from being used in MC positions.
                        /*
			-- Validate	quantity = 1 for all item associations to the itemgroup
			OPEN check_item_assos_qty;
			FETCH check_item_assos_qty INTO	l_dummy_varchar;
			IF (check_item_assos_qty%FOUND)
			THEN
				FND_MESSAGE.Set_Name('AHL',	'AHL_MC_ITEM_ASSOS_QTY_INV');
				FND_MSG_PUB.ADD;
				IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
				THEN
					fnd_log.message
					(
						fnd_log.level_exception,
						'ahl.plsql.'||G_PKG_NAME||'.Validate_Node',
						false
					);
				END	IF;
			END	IF;
			CLOSE check_item_assos_qty;
                        */

			-- Validate	item group is trackable
			IF (l_ig_type <> 'TRACKED')
			THEN
				FND_MESSAGE.Set_Name('AHL',	'AHL_MC_IG_NOT_TRACKED');
				FND_MESSAGE.Set_Token('IG_NAME', p_x_node_rec.item_group_name);
				FND_MSG_PUB.ADD;
				IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
				THEN
					fnd_log.message
					(
						fnd_log.level_exception,
						'ahl.plsql.'||G_PKG_NAME||'.Validate_Node',
						false
					);
				END	IF;
			END	IF;

			-- Validate	itemgroup status is	not	REMOVED
			IF (l_ig_status	= 'REMOVED')
			THEN
				FND_MESSAGE.Set_Name('AHL',	'AHL_MC_IG_STS_INV');
				FND_MESSAGE.Set_Token('IG_NAME', p_x_node_rec.item_group_name);
				FND_MSG_PUB.ADD;
				IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
				THEN
					fnd_log.message
					(
						fnd_log.level_exception,
						'ahl.plsql.'||G_PKG_NAME||'.Validate_Node',
						false
					);
				END	IF;
			END	IF;
		END	IF;
		CLOSE get_item_group_id;
	ELSE
		-- Not a mandatory field, hence	nullify	ID
		p_x_node_rec.item_group_id := null;
	END	IF;

	-- Validate	quantity
	IF (p_x_node_rec.quantity IS NULL)
	THEN
		FND_MESSAGE.Set_Name('AHL',	'AHL_MC_QUANTITY_NULL');
		FND_MESSAGE.Set_Token('POSREF',	p_x_node_rec.position_ref_meaning);
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.'||G_PKG_NAME||'.Validate_Node',
				false
			);
		END	IF;
	ELSIF (p_x_node_rec.quantity <=	0)
	THEN
		FND_MESSAGE.Set_Name('AHL',	'AHL_MC_QUANTITY_INVALID');
		FND_MESSAGE.Set_Token('QTY', p_x_node_rec.quantity);
		FND_MESSAGE.Set_Token('POSREF',	p_x_node_rec.position_ref_meaning);
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.'||G_PKG_NAME||'.Validate_Node',
				false
			);
		END	IF;
	ELSIF (p_x_node_rec.quantity > 1 AND p_x_node_rec.relationship_id IS NOT NULL)
	THEN
		OPEN check_child_exists;
		FETCH check_child_exists INTO l_dummy_varchar;
		IF (check_child_exists%FOUND)
		THEN
			FND_MESSAGE.Set_Name('AHL',	'AHL_MC_PAR_QTY_INV');
			FND_MESSAGE.Set_Token('POSREF',	p_x_node_rec.position_ref_meaning);
			FND_MSG_PUB.ADD;
			IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.message
				(
					fnd_log.level_exception,
					'ahl.plsql.'||G_PKG_NAME||'.Validate_Node',
					false
				);
			END	IF;
		END	IF;
		CLOSE check_child_exists;
	END	IF;

	-- Validate	display	order
	IF (p_x_node_rec.display_order IS NULL)
	THEN
		FND_MESSAGE.Set_Name('AHL',	'AHL_MC_DISPORD_NULL');
		FND_MESSAGE.Set_Token('POSREF',	p_x_node_rec.position_ref_meaning);
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.'||G_PKG_NAME||'.Validate_Node',
				false
			);
		END	IF;
	ELSIF (p_x_node_rec.display_order <= 0)
	THEN
		FND_MESSAGE.Set_Name('AHL',	'AHL_MC_DISPORD_INVALID');
		FND_MESSAGE.Set_Token('DSP', p_x_node_rec.display_order);
		FND_MESSAGE.Set_Token('POSREF',	p_x_node_rec.position_ref_meaning);
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.'||G_PKG_NAME||'.Validate_Node',
				false
			);
		END	IF;
	ELSE
		-- Validate	display_order is not equal to the same for any other node at the same level
		OPEN check_dup_display_order;
		FETCH check_dup_display_order INTO l_dummy_varchar;
		IF (check_dup_display_order%FOUND)
		THEN
			FND_MESSAGE.Set_Name('AHL',	'AHL_MC_DISPORD_EXISTS');
			FND_MESSAGE.Set_Token('DSP', p_x_node_rec.display_order);
			FND_MESSAGE.Set_Token('POSREF',	p_x_node_rec.position_ref_meaning);
			FND_MSG_PUB.ADD;
			IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.message
				(
					fnd_log.level_exception,
					'ahl.plsql.'||G_PKG_NAME||'.Validate_Node',
					false
				);
			END	IF;
		END	IF;
		CLOSE check_dup_display_order;
	END	IF;

	-- Validate	UOM
	IF (p_x_node_rec.uom_code IS NULL)
	THEN
		FND_MESSAGE.Set_Name('AHL',	'AHL_MC_UOM_NULL');
		FND_MESSAGE.Set_Token('POSREF',	p_x_node_rec.position_ref_meaning);
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.'||G_PKG_NAME||'.Validate_Node',
				false
			);
		END	IF;
	ELSE
		OPEN check_uom_exists(p_x_node_rec.uom_code);
		FETCH check_uom_exists INTO	l_dummy_varchar;
		IF (check_uom_exists%NOTFOUND)
		THEN
			FND_MESSAGE.Set_Name('AHL',	'AHL_MC_UOM_INVALID');
			FND_MESSAGE.Set_Token('POSREF',	p_x_node_rec.position_ref_meaning);
			FND_MESSAGE.Set_Token('UOM', p_x_node_rec.uom_code);
			FND_MSG_PUB.ADD;
			IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.message
				(
					fnd_log.level_exception,
					'ahl.plsql.'||G_PKG_NAME||'.Validate_Node',
					false
				);
			END	IF;
		END	IF;
		CLOSE check_uom_exists;
	END	IF;

	-- Validate	dates
	-- ##TAMAL## Date validations may fail in the case of creating a node initiated	from a copy_node / copy_mc /
	-- create_mc_revision call since expired nodes are to be created, thus do not perform date validations for
	-- such	a case.	For	any	such copy operation, the p_x_node_rec.operation_flag = G_DML_COPY instead of
	-- G_DML_CREATE, and thus date validations may be avoided for such a case.
	IF (p_x_node_rec.operation_flag	= G_DML_UPDATE)
	THEN
		OPEN get_node_dates;
		FETCH get_node_dates INTO l_start_date,	l_end_date;
		CLOSE get_node_dates;

		IF (G_TRUNC_DATE >=	trunc(nvl(l_end_date, G_SYSDATE	+ 1)))
		THEN
			FND_MESSAGE.Set_Name('AHL',	'AHL_MC_NODE_DATE_INV');
			FND_MSG_PUB.ADD;
			IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.message
				(
					fnd_log.level_exception,
					'ahl.plsql.'||G_PKG_NAME||'.Validate_Node',
					false
				);
			END	IF;
		END	IF;

		IF (p_x_node_rec.active_start_date IS NOT NULL AND trunc(nvl(l_start_date, G_SYSDATE)) <> trunc(p_x_node_rec.active_start_date)	AND	trunc(p_x_node_rec.active_start_date) <	G_TRUNC_DATE)
		THEN
			FND_MESSAGE.Set_Name('AHL',	'AHL_MC_START_DATE_INV');
			FND_MSG_PUB.ADD;
			IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.message
				(
					fnd_log.level_exception,
					'ahl.plsql.'||G_PKG_NAME||'.Validate_Node',
					false
				);
			END	IF;
		END	IF;

		IF (trunc(nvl(l_end_date, G_SYSDATE)) <> trunc(nvl(p_x_node_rec.active_end_date, G_SYSDATE)) AND trunc(nvl(p_x_node_rec.active_end_date, G_SYSDATE + 1)) <=	G_TRUNC_DATE)
		THEN
			FND_MESSAGE.Set_Name('AHL',	'AHL_MC_END_DATE_INV');
			FND_MSG_PUB.ADD;
			IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.message
				(
					fnd_log.level_exception,
					'ahl.plsql.'||G_PKG_NAME||'.Validate_Node',
					false
				);
			END	IF;
		END	IF;
	ELSIF (p_x_node_rec.operation_flag = G_DML_CREATE)
	THEN
		IF (trunc(nvl(p_x_node_rec.active_start_date, G_SYSDATE)) <	G_TRUNC_DATE)
		THEN
			FND_MESSAGE.Set_Name('AHL',	'AHL_MC_START_DATE_INV');
			FND_MSG_PUB.ADD;
			IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.message
				(
					fnd_log.level_exception,
					'ahl.plsql.'||G_PKG_NAME||'.Validate_Node',
					false
				);
			END	IF;
		END	IF;

		IF (trunc(nvl(p_x_node_rec.active_end_date,	G_SYSDATE +	1))	<= G_TRUNC_DATE)
		THEN
			FND_MESSAGE.Set_Name('AHL',	'AHL_MC_END_DATE_INV');
			FND_MSG_PUB.ADD;
			IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.message
				(
					fnd_log.level_exception,
					'ahl.plsql.'||G_PKG_NAME||'.Validate_Node',
					false
				);
			END	IF;
		END	IF;
	END	IF;

	IF (p_x_node_rec.operation_flag	<> G_DML_COPY AND trunc(nvl(p_x_node_rec.active_end_date, nvl(p_x_node_rec.active_start_date, G_SYSDATE) + 1)) <= trunc(nvl(p_x_node_rec.active_start_date,	G_SYSDATE)))
	THEN
		FND_MESSAGE.Set_Name('AHL',	'AHL_MC_START_END_INV');
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.'||G_PKG_NAME||'.Validate_Node',
				false
			);
		END	IF;
	END	IF;

END	Validate_Node;

PROCEDURE Validate_Counter_Exists
(
	p_ctr_rule_id in number,
	p_object_ver_num in	number
)
IS

	CURSOR check_counter_exists
	IS
		SELECT	object_version_number
		FROM	ahl_ctr_update_rules
		WHERE	ctr_update_rule_id = p_ctr_rule_id;

BEGIN

	OPEN check_counter_exists;
	FETCH check_counter_exists INTO	l_dummy_number;
	IF (check_counter_exists%NOTFOUND)
	THEN
		FND_MESSAGE.Set_Name('AHL',	'AHL_MC_CTR_NOT_FOUND');
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.'||G_PKG_NAME||'.Validate_Counter_Exists',
				false
			);
		END	IF;
		CLOSE check_counter_exists;
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (NVL(p_object_ver_num, l_dummy_number) <>	l_dummy_number)
	THEN
		FND_MESSAGE.Set_Name('AHL',	'AHL_COM_RECORD_CHANGED');
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.'||G_PKG_NAME||'.Validate_Counter_Exists',
				false
			);
		END	IF;
		CLOSE check_counter_exists;
		RAISE FND_API.G_EXC_ERROR;
	END	IF;
	CLOSE check_counter_exists;

END	Validate_Counter_Exists;

PROCEDURE Validate_Counter_Rule
(
	p_counter_rule_rec in Counter_Rule_Rec_Type
)
IS
	-- Define cursor get_node_posref to	read the position reference	of the MC node,	used for displaying	errors
	CURSOR get_node_posref
	IS
		SELECT position_ref_meaning
		FROM  ahl_mc_relationships_v
		WHERE relationship_id =	p_counter_rule_rec.relationship_id;

	-- Define cursor check_uom_rule	to check whether the same combination of UOM and rule
	-- already exists for the node or not
	CURSOR check_uom_rule
	IS
		SELECT	'x'
		FROM	ahl_ctr_update_rules
		WHERE	relationship_id	= p_counter_rule_rec.relationship_id AND
			rule_code =	p_counter_rule_rec.rule_code AND
			uom_code = p_counter_rule_rec.uom_code AND
			ctr_update_rule_id <> nvl(p_counter_rule_rec.ctr_update_rule_id, -1);

	-- Declare local variables
	l_posref_meaning	VARCHAR2(80);

BEGIN
	OPEN get_node_posref;
	FETCH get_node_posref INTO l_posref_meaning;
	CLOSE get_node_posref;

	-- Validate	p_counter_rule_rec.uom_code
	IF (p_counter_rule_rec.uom_code	IS NULL)
	THEN
		FND_MESSAGE.Set_Name('AHL',	'AHL_MC_UOM_NULL');
		FND_MESSAGE.Set_Token('POSREF',	l_posref_meaning);
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.'||G_PKG_NAME||'.Validate_Counter_Rule',
				false
			);
		END	IF;
	ELSE
		OPEN check_uom_exists(p_counter_rule_rec.uom_code);
		FETCH check_uom_exists INTO	l_dummy_varchar;
		IF (check_uom_exists%NOTFOUND)
		THEN
			FND_MESSAGE.Set_Name('AHL',	'AHL_MC_UOM_INVALID');
			FND_MESSAGE.Set_Token('POSREF',	l_posref_meaning);
			FND_MESSAGE.Set_Token('UOM', p_counter_rule_rec.uom_code);
			FND_MSG_PUB.ADD;
			IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.message
				(
					fnd_log.level_exception,
					'ahl.plsql.'||G_PKG_NAME||'.Validate_Counter_Rule',
					false
				);
			END	IF;
		END	IF;
		CLOSE check_uom_exists;
	END	IF;

	-- Validate	p_counter_rule_rec.rule_code
	IF (p_counter_rule_rec.rule_code IS	NULL)
	THEN
		FND_MESSAGE.Set_Name('AHL',	'AHL_MC_RCODE_NULL');
		FND_MESSAGE.Set_Token('POSREF',	l_posref_meaning);
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.'||G_PKG_NAME||'.Validate_Counter_Rule',
				false
			);
		END	IF;
	ELSIF NOT(AHL_UTIL_MC_PKG.Validate_Lookup_Code('AHL_COUNTER_RULE_TYPE',	p_counter_rule_rec.rule_code))
	THEN
		FND_MESSAGE.Set_Name('AHL',	'AHL_MC_RCODE_INVALID');
		FND_MESSAGE.Set_Token('POSREF',	l_posref_meaning);
		FND_MESSAGE.Set_Token('RULE_CODE', p_counter_rule_rec.rule_meaning);
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.'||G_PKG_NAME||'.Validate_Counter_Rule',
				false
			);
		END	IF;
	END	IF;

	-- Validate	whether	the	same combination of	UOM	and	Rule does not exist	for	this node
	OPEN check_uom_rule;
	FETCH check_uom_rule INTO l_dummy_varchar;
	IF (check_uom_rule%FOUND)
	THEN
		FND_MESSAGE.Set_Name('AHL',	'AHL_MC_CTRRULE_EXISTS');
		FND_MESSAGE.Set_Token('POSREF',	l_posref_meaning);
		FND_MESSAGE.Set_Token('UOM', p_counter_rule_rec.uom_code);
		FND_MESSAGE.Set_Token('RULE', p_counter_rule_rec.rule_code);
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.'||G_PKG_NAME||'.Validate_Counter_Rule',
				false
			);
		END	IF;
	END	IF;
	CLOSE check_uom_rule;

	-- Validate	counter	rule ratio is a	positive number
	IF (nvl(p_counter_rule_rec.ratio, 0) <=	0)
	THEN
		FND_MESSAGE.Set_Name('AHL',	'AHL_MC_RATIO_INVALID');
		FND_MESSAGE.Set_Token('POSREF',	l_posref_meaning);
		FND_MESSAGE.Set_Token('RATIO', p_counter_rule_rec.ratio);
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.'||G_PKG_NAME||'.Validate_Counter_Rule',
				false
			);
		END	IF;
	END	IF;

END	Validate_Counter_Rule;

PROCEDURE Validate_Subconfig_Exists
(
	p_submc_assos_id in	number,
	p_object_ver_num in	number
)
IS

	CURSOR check_submc_exists
	IS
		SELECT	object_version_number
		FROM	ahl_mc_config_relations
		WHERE	mc_config_relation_id =	p_submc_assos_id;

BEGIN

	OPEN check_submc_exists;
	FETCH check_submc_exists INTO l_dummy_number;
	IF (check_submc_exists%NOTFOUND)
	THEN
		FND_MESSAGE.Set_Name('AHL',	'AHL_MC_SUBMC_NOT_FOUND');
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.'||G_PKG_NAME||'.Validate_Subconfig_Exists',
				false
			);
		END	IF;
		CLOSE check_submc_exists;
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (NVL(p_object_ver_num, l_dummy_number) <>	l_dummy_number)
	THEN
		FND_MESSAGE.Set_Name('AHL',	'AHL_COM_RECORD_CHANGED');
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.'||G_PKG_NAME||'.Validate_Subconfig_Exists',
				false
			);
		END	IF;
		CLOSE check_submc_exists;
		RAISE FND_API.G_EXC_ERROR;
	END	IF;
	CLOSE check_submc_exists;

END	Validate_Subconfig_Exists;


PROCEDURE Validate_priority
(
	p_subconfig_tbl	in Subconfig_Tbl_Type
) IS

	CURSOR check_priority_dup_exists
	IS
		SELECT	priority
		FROM	ahl_mc_config_relations
		WHERE	relationship_id	= p_subconfig_tbl(1).relationship_id
		group by priority
		having count(mc_config_relation_id)	> 1;

	l_priority NUMBER;

BEGIN


	OPEN check_priority_dup_exists;
	FETCH check_priority_dup_exists	INTO l_priority;
	IF (check_priority_dup_exists%FOUND)
	THEN
		FND_MESSAGE.Set_Name('AHL',	'AHL_MC_PRIORITY_NON_UNIQUE');
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.'||G_PKG_NAME||'.Validate_priority',
				true
			);
		END	IF;
		CLOSE check_priority_dup_exists;
		RAISE FND_API.G_EXC_ERROR;
	END	IF;

END	Validate_priority;

/* Jerry commented out on 08/12/2004 because it	is never used
PROCEDURE Check_Cyclic_Rel
(
	p_subconfig_id in number,
	p_rel_id in	number
)
IS

	-- Define cursor check_cyclic_rel_csr to establish a parent-child relationship between the MC in question and
	-- subconfigs associated with its nodes	(down to the last level), then search for the subconfig	in question
	-- from	that list
	CURSOR check_cyclic_rel_csr
	IS
	SELECT 'x'
	FROM
	(
		-- Establish parent-child relationship between subconfiguration	associations
		-- and the MC to which they	are	associated
		SELECT submc.mc_header_id child, node.mc_header_id parent
		FROM ahl_mc_config_relations submc,	ahl_mc_relationships node
		WHERE submc.relationship_id	= node.relationship_id
		CONNECT	BY node.mc_header_id = PRIOR submc.mc_header_id
		START WITH node.mc_header_id = p_subconfig_id
	) submc_tree, ahl_mc_relationships mc_node
	WHERE	submc_tree.child = mc_node.mc_header_id	AND
		mc_node.relationship_id	= p_rel_id;

	-- Define cursor get_node_mc_details to	read detail	of the MC of a MC node
	CURSOR get_node_mc_details
	IS
		SELECT	mch.name
		FROM	ahl_mc_headers_b mch, ahl_mc_relationships mcr
		WHERE	mch.mc_header_id = mcr.mc_header_id	AND
			mcr.relationship_id	= p_rel_id;

	-- Define cursor get_mc_details	to read	detail of a	MC
	CURSOR get_mc_details
	IS
		SELECT	name
		FROM	ahl_mc_headers_b
		WHERE	mc_header_id = p_subconfig_id;

	-- Define local	variables
	l_mc_name	VARCHAR2(80);
	l_submc_name	VARCHAR2(80);

BEGIN
	OPEN check_cyclic_rel_csr;
	FETCH check_cyclic_rel_csr INTO	l_dummy_varchar;
	IF (check_cyclic_rel_csr%FOUND)
	THEN
		OPEN get_node_mc_details;
		FETCH get_node_mc_details INTO l_mc_name;
		CLOSE get_node_mc_details;

		OPEN get_mc_details;
		FETCH get_mc_details INTO l_submc_name;
		CLOSE get_mc_details;

		FND_MESSAGE.Set_Name('AHL',	'AHL_MC_CYCLIC_REL_EXIST');
		FND_MESSAGE.Set_Token('MC',	l_mc_name);
		FND_MESSAGE.Set_Token('SUBMC', l_submc_name);
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.'||G_PKG_NAME||'.Check_Cyclic_Rel',
				false
			);
		END	IF;
	END	IF;
	CLOSE check_cyclic_rel_csr;

END	Check_Cyclic_Rel;
*/

-------------------------
-- Non-spec	Procedures --
-------------------------
FUNCTION Get_MC_Status
(
	p_rel_id in	number,
	p_mc_header_id in number
)
RETURN VARCHAR2
IS
	CURSOR get_mc_status
	IS
		SELECT	config_status_code
		FROM	ahl_mc_headers_v
		WHERE	mc_header_id = p_mc_header_id;

	CURSOR get_node_mc_status
	IS
		SELECT	mch.config_status_code
		FROM	ahl_mc_headers_v mch, ahl_mc_relationships mcr
		WHERE	mch.mc_header_id = mcr.mc_header_id	AND
			mcr.relationship_id	= p_rel_id;

	l_status	VARCHAR2(30);

BEGIN

	IF (p_rel_id IS	NOT	NULL)
	THEN
		OPEN get_node_mc_status;
		FETCH get_node_mc_status INTO l_status;
		IF (get_node_mc_status%NOTFOUND)
		THEN
			FND_MESSAGE.Set_Name('AHL',	'AHL_MC_NOT_FOUND');
			FND_MSG_PUB.ADD;
			IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.message
				(
					fnd_log.level_exception,
					'ahl.plsql.'||G_PKG_NAME||'.Get_MC_Status',
					false
				);
			END	IF;
			CLOSE get_node_mc_status;
			RAISE FND_API.G_EXC_ERROR;
		END	IF;
		CLOSE get_node_mc_status;
	ELSIF (p_mc_header_id IS NOT NULL)
	THEN
		OPEN get_mc_status;
		FETCH get_mc_status	INTO l_status;
		IF (get_mc_status%NOTFOUND)
		THEN
			FND_MESSAGE.Set_Name('AHL',	'AHL_MC_NOT_FOUND');
			FND_MSG_PUB.ADD;
			IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.message
				(
					fnd_log.level_exception,
					'ahl.plsql.'||G_PKG_NAME||'.Get_MC_Status',
					false
				);
			END	IF;
			CLOSE get_mc_status;
			RAISE FND_API.G_EXC_ERROR;
		END	IF;
		CLOSE get_mc_status;
	END	IF;

	return l_status;

END	Get_MC_Status;
-- Returns true	if the MC ,	p_subconfig_id contains	the	MC p_dest_config_id, as
-- a subconfig some	where down the tree.
FUNCTION Cyclic_Relation_Exists
(
	p_subconfig_id in number,
	p_dest_config_id in	number
)
RETURN BOOLEAN
IS
	-- Define local	variables
	TYPE subconfig_Tbl_Type	IS TABLE OF	NUMBER INDEX BY	BINARY_INTEGER;
	l_subconfigs_table subconfig_Tbl_Type;
	l_dummy_varchar	VARCHAR2(1);
	-- cursor to check whether the Cyclic relation really exist.
        -- SATHAPLI::Bug 9020738, 25-Mar-2010, re-defined the cursor, as hierarchical query is not needed here.
        -- Also, changed IN to EXISTS.
	CURSOR CHECK_RELATIONS_CYCLE
	IS
	/*	SELECT 'X' FROM	ahl_mc_config_relations
	WHERE mc_header_id = p_dest_config_id
	AND	relationship_id	IN
		( SELECT relationship_id from ahl_mc_relationships
		  WHERE	mc_header_id = p_subconfig_id
		  START	WITH parent_relationship_id	IS NULL
		  CONNECT BY parent_relationship_id	=  prior relationship_id);
        */
        SELECT 'X'
          FROM ahl_mc_config_relations cnr
         WHERE cnr.mc_header_id = p_dest_config_id
           AND EXISTS
               ( SELECT 'X'
                   FROM ahl_mc_relationships mcr
                  WHERE mcr.mc_header_id    = p_subconfig_id
                    AND mcr.relationship_id = cnr.relationship_id );

	BEGIN
	-- check whether cycle is there
	OPEN CHECK_RELATIONS_CYCLE;
	FETCH CHECK_RELATIONS_CYCLE	INTO l_dummy_varchar;
	IF (CHECK_RELATIONS_CYCLE%FOUND) THEN
		CLOSE CHECK_RELATIONS_CYCLE;
		-- Cycle is	found
		RETURN TRUE;
	ELSE
		CLOSE CHECK_RELATIONS_CYCLE;
		-- get the next	level of subconfigs
                -- SATHAPLI::Bug 9020738, 25-Mar-2010, re-defined the query, as hierarchical query is not needed here.
                -- Also, changed IN to EXISTS.
		/* SELECT mc_header_id	 bulk collect
		INTO l_subconfigs_table
		FROM ahl_mc_config_relations WHERE relationship_id IN
							  (	SELECT relationship_id FROM	 ahl_mc_relationships
							  WHERE	mc_header_id =	p_subconfig_id
							  START	WITH parent_relationship_id	IS NULL
							  CONNECT BY parent_relationship_id	 = prior relationship_id );
                */
                SELECT mc_header_id BULK COLLECT
                  INTO l_subconfigs_table
                  FROM ahl_mc_config_relations cnr
                 WHERE EXISTS
                       ( SELECT 'X'
                           FROM ahl_mc_relationships mcr
                          WHERE mcr.mc_header_id    =  p_subconfig_id
                            AND mcr.relationship_id = cnr.relationship_id );

		IF ( l_subconfigs_table.COUNT >	0 )	THEN
			FOR	i IN l_subconfigs_table.FIRST..l_subconfigs_table.LAST LOOP
				IF Cyclic_Relation_Exists(l_subconfigs_table(i),p_dest_config_id) THEN
					RETURN TRUE;
				END	IF;
			END	LOOP;
		END	IF;
	END	IF;
	RETURN FALSE;
END	Cyclic_Relation_Exists;

PROCEDURE Set_Header_Status
(
	p_rel_id IN	NUMBER
)
IS

	CURSOR get_mc_header_status
	(
		p_rel_id in	number
	)
	IS
		SELECT	mch.mc_header_id, mch.config_status_code
		FROM	ahl_mc_headers_b mch, ahl_mc_relationships mcr
		WHERE	mch.mc_header_id = mcr.mc_header_id	AND
			mcr.relationship_id	= p_rel_id;

	l_mc_header_id	NUMBER;
	l_status	VARCHAR2(30) :=	'DRAFT';

BEGIN

	OPEN get_mc_header_status(p_rel_id);
	FETCH get_mc_header_status INTO	l_mc_header_id,	l_status;

	IF (get_mc_header_status%FOUND)
	THEN
		IF (l_status = 'APPROVAL_REJECTED')
		THEN
			UPDATE	ahl_mc_headers_b
			SET		config_status_code = 'DRAFT'
			WHERE	mc_header_id = l_mc_header_id;
		END	IF;
	END	IF;

	CLOSE get_mc_header_status;

END	Set_Header_Status;

PROCEDURE Create_Counter_Rule
(
	p_x_counter_rule_rec	IN OUT	NOCOPY	Counter_Rule_Rec_Type
)
IS
	-- Define local	variables
	l_api_name	CONSTANT	VARCHAR2(30)	:= 'Create_Counter_Rule';
	l_msg_count			NUMBER;

	l_posref_meaning	VARCHAR2(80);

BEGIN

	-- API body	starts here
	IF (fnd_log.level_procedure	>= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
			'At	the	start of PLSQL procedure'
		);
	END	IF;

	-- Validate	p_x_counter_rule_rec.relationship_id exists
	Validate_Node_Exists(p_x_counter_rule_rec.relationship_id, null);

	-- Validate	UOM, Rule and Ratio	for	the	counter	rule
	Validate_Counter_Rule(p_x_counter_rule_rec);

	-- Check Error Message stack.
	l_msg_count	:= FND_MSG_PUB.count_msg;
	IF l_msg_count > 0 THEN
		RAISE FND_API.G_EXC_ERROR;
	END	IF;

	IF (fnd_log.level_statement	>= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
			'Counter rule validation successful'
		);
	END	IF;

	SELECT ahl_ctr_update_rules_s.nextval INTO p_x_counter_rule_rec.ctr_update_rule_id FROM	DUAL;
	p_x_counter_rule_rec.object_version_number := 1;
	p_x_counter_rule_rec.security_group_id := null;

	INSERT INTO	AHL_CTR_UPDATE_RULES
	(
		CTR_UPDATE_RULE_ID,
		RELATIONSHIP_ID,
		UOM_CODE,
		RULE_CODE,
		RATIO,
		OBJECT_VERSION_NUMBER,
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
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_LOGIN
	)
	VALUES
	(
		p_x_counter_rule_rec.ctr_update_rule_id,
		p_x_counter_rule_rec.relationship_id,
		p_x_counter_rule_rec.uom_code,
		p_x_counter_rule_rec.rule_code,
		p_x_counter_rule_rec.ratio,
		p_x_counter_rule_rec.object_version_number,
		p_x_counter_rule_rec.security_group_id,
		p_x_counter_rule_rec.ATTRIBUTE_CATEGORY,
		p_x_counter_rule_rec.ATTRIBUTE1,
		p_x_counter_rule_rec.ATTRIBUTE2,
		p_x_counter_rule_rec.ATTRIBUTE3,
		p_x_counter_rule_rec.ATTRIBUTE4,
		p_x_counter_rule_rec.ATTRIBUTE5,
		p_x_counter_rule_rec.ATTRIBUTE6,
		p_x_counter_rule_rec.ATTRIBUTE7,
		p_x_counter_rule_rec.ATTRIBUTE8,
		p_x_counter_rule_rec.ATTRIBUTE9,
		p_x_counter_rule_rec.ATTRIBUTE10,
		p_x_counter_rule_rec.ATTRIBUTE11,
		p_x_counter_rule_rec.ATTRIBUTE12,
		p_x_counter_rule_rec.ATTRIBUTE13,
		p_x_counter_rule_rec.ATTRIBUTE14,
		p_x_counter_rule_rec.ATTRIBUTE15,
		G_SYSDATE,
		G_USER_ID,
		G_SYSDATE,
		G_USER_ID,
		G_LOGIN_ID
	);

	-- API body	ends here

END	Create_Counter_Rule;

PROCEDURE Modify_Counter_Rule
(
	p_x_counter_rule_rec	IN OUT	NOCOPY	Counter_Rule_Rec_Type
)
IS

	-- Define cursor get_node_posref to	read the position reference	of the MC node,	used for displaying	errors
	CURSOR get_node_posref
	IS
		SELECT position_ref_meaning
		FROM  ahl_mc_relationships_v
		WHERE relationship_id =	p_x_counter_rule_rec.relationship_id;

	-- Define cursor check_uom_rule	to check whether the same combination of UOM and rule
	-- already exists for the node or not
	CURSOR check_uom_rule
	IS
		SELECT	'x'
		FROM	ahl_ctr_update_rules
		WHERE	relationship_id	= p_x_counter_rule_rec.relationship_id AND
			rule_code =	p_x_counter_rule_rec.rule_code AND
			uom_code = p_x_counter_rule_rec.uom_code AND
			ctr_update_rule_id <> p_x_counter_rule_rec.ctr_update_rule_id;

	-- Define local	variables
	l_api_name	CONSTANT	VARCHAR2(30)	:= 'Modify_Counter_Rule';
	l_msg_count			NUMBER;

	l_posref_meaning		VARCHAR2(80);

BEGIN

	-- API body	starts here
	IF (fnd_log.level_procedure	>= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||'.begin',
			'At	the	start of PLSQL procedure'
		);
	END	IF;

	-- Validate	p_x_counter_rule_rec.relationship_id exists
	Validate_Node_Exists(p_x_counter_rule_rec.relationship_id, null);

	-- Validate	p_x_counter_rule_rec.ctr_update_rule_id	exists
	Validate_Counter_Exists(p_x_counter_rule_rec.ctr_update_rule_id, nvl(p_x_counter_rule_rec.object_version_number, 0));

	-- Validate	UOM, Rule and Ratio	for	the	counter	rule
	Validate_Counter_Rule(p_x_counter_rule_rec);

	-- Check Error Message stack.
	l_msg_count	:= FND_MSG_PUB.count_msg;
	IF l_msg_count > 0 THEN
		RAISE FND_API.G_EXC_ERROR;
	END	IF;

	IF (fnd_log.level_statement	>= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
			'Counter rule validation successful'
		);
	END	IF;

	p_x_counter_rule_rec.object_version_number := p_x_counter_rule_rec.object_version_number + 1;

	UPDATE	AHL_CTR_UPDATE_RULES
	SET		RATIO			= p_x_counter_rule_rec.RATIO,
		RULE_CODE		= p_x_counter_rule_rec.RULE_CODE,
		OBJECT_VERSION_NUMBER	= p_x_counter_rule_rec.OBJECT_VERSION_NUMBER,
		SECURITY_GROUP_ID	= p_x_counter_rule_rec.SECURITY_GROUP_ID,
		ATTRIBUTE_CATEGORY	= p_x_counter_rule_rec.ATTRIBUTE_CATEGORY,
		ATTRIBUTE1		= p_x_counter_rule_rec.ATTRIBUTE1,
		ATTRIBUTE2		= p_x_counter_rule_rec.ATTRIBUTE2,
		ATTRIBUTE3		= p_x_counter_rule_rec.ATTRIBUTE3,
		ATTRIBUTE4		= p_x_counter_rule_rec.ATTRIBUTE4,
		ATTRIBUTE5		= p_x_counter_rule_rec.ATTRIBUTE5,
		ATTRIBUTE6		= p_x_counter_rule_rec.ATTRIBUTE6,
		ATTRIBUTE7		= p_x_counter_rule_rec.ATTRIBUTE7,
		ATTRIBUTE8		= p_x_counter_rule_rec.ATTRIBUTE8,
		ATTRIBUTE9		= p_x_counter_rule_rec.ATTRIBUTE9,
		ATTRIBUTE10			= p_x_counter_rule_rec.ATTRIBUTE10,
		ATTRIBUTE11			= p_x_counter_rule_rec.ATTRIBUTE11,
		ATTRIBUTE12			= p_x_counter_rule_rec.ATTRIBUTE12,
		ATTRIBUTE13			= p_x_counter_rule_rec.ATTRIBUTE13,
		ATTRIBUTE14			= p_x_counter_rule_rec.ATTRIBUTE14,
		ATTRIBUTE15			= p_x_counter_rule_rec.ATTRIBUTE15,
		LAST_UPDATE_DATE	= G_SYSDATE,
		LAST_UPDATED_BY		= G_USER_ID,
		LAST_UPDATE_LOGIN	= G_LOGIN_ID
	WHERE	CTR_UPDATE_RULE_ID = p_x_counter_rule_rec.CTR_UPDATE_RULE_ID;

	-- API body	ends here

END	Modify_Counter_Rule;

PROCEDURE Delete_Counter_Rule
(
	p_ctr_update_rule_id	IN		NUMBER,
	p_object_ver_num		IN		NUMBER
)
IS

	-- Declare local variables
	l_api_name	CONSTANT	VARCHAR2(30)	:= 'Delete_Counter_Rule';

BEGIN

	-- API body	starts here
	IF (fnd_log.level_procedure	>= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||'.begin',
			'At	the	start of PLSQL procedure'
		);
	END	IF;

	-- Validate	p_ctr_update_rule_id exists
	Validate_Counter_Exists(p_ctr_update_rule_id, nvl(p_object_ver_num,	0));

	DELETE FROM	ahl_ctr_update_rules
	WHERE ctr_update_rule_id = p_ctr_update_rule_id;

	IF (fnd_log.level_procedure	>= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||'.end',
			'At	the	end	of PLSQL procedure'
		);
	END	IF;
	-- API body	ends here

END	Delete_Counter_Rule;

PROCEDURE Attach_Subconfig
(
	p_x_subconfig_rec	IN OUT	NOCOPY	Subconfig_Rec_Type
)
IS
	-- Define cursor check_submc_exists	to check whether the subconfiguration association already exists for this node
	CURSOR check_submc_exists
	IS
		SELECT	name
		FROM	ahl_mc_config_relations	submc, ahl_mc_headers_b	mch
		WHERE	submc.mc_header_id = mch.mc_header_id AND
			submc.relationship_id =	p_x_subconfig_rec.relationship_id AND
			submc.mc_header_id = p_x_subconfig_rec.mc_header_id;
			-- Since expired subconfig associations	can	be unexpired, so no	need to	filter on active_end_date
			-- AND G_TRUNC_DATE	< trunc(nvl(submc.active_end_date, G_SYSDATE + 1));

	-- Define check_root_node to check whether the node	to which subconfiguration is being associated is not a topnode of a	MC
	CURSOR check_root_node
	IS
		SELECT	'x'
		FROM	ahl_mc_relationships
		WHERE	parent_relationship_id is null AND
			relationship_id	= p_x_subconfig_rec.relationship_id;

	-- Define check_leaf_node to check whether the node	to which subconfiguration is being associated is a leaf	node
	CURSOR check_leaf_node
	IS
		SELECT	'x'
		FROM	ahl_mc_relationships
		WHERE	parent_relationship_id = p_x_subconfig_rec.relationship_id AND
			G_TRUNC_DATE < trunc(nvl(active_end_date, G_SYSDATE	+ 1));

	-- Define a	cursor to get the MC header	id , when a	relationship id	is given
	CURSOR get_dest_header_id(p_dest_rel_id	in number)
	IS
		SELECT mc_header_id
		FROM ahl_mc_relationships
		WHERE relationship_id =	p_dest_rel_id;
	-- Define cursor get_node_mc_details to	read detail	of the MC of a MC node
	CURSOR get_node_mc_details(p_dest_rel_id in	number)
	IS
		SELECT	mch.name
		FROM	ahl_mc_headers_b mch, ahl_mc_relationships mcr
		WHERE	mch.mc_header_id = mcr.mc_header_id	AND
			mcr.relationship_id	= p_dest_rel_id;
	-- Define cursor get_mc_details	to read	detail of a	MC
	CURSOR get_mc_details(p_subconfig_id  in number	)
	IS
		SELECT	name
		FROM	ahl_mc_headers_b
		WHERE	mc_header_id = p_subconfig_id;
	-- Declare local variables
	l_api_name	CONSTANT	VARCHAR2(30)	:= 'Attach_Subconfig';
	l_msg_count			NUMBER;

	l_header_status			VARCHAR2(30);
	l_mc_name			VARCHAR2(80);
	-- new local variables declared
	l_mc_config_rel_id		 NUMBER;
	l_cyclic_relation_exist	 BOOLEAN :=	FALSE;
	l_dest_header_id		 NUMBER;
	l_submc_name			 VARCHAR2(80);

BEGIN

	-- API body	starts here
	IF (fnd_log.level_procedure	>= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||'.begin',
			'At	the	start of PLSQL procedure'
		);
	END	IF;

	-- Validate	a MC node with relationship_id = p_x_subconfig_rec.relationship_id exists
	Validate_Node_Exists(p_x_subconfig_rec.relationship_id,	null);

	-- Validate	the	MC node	with relationship_id = p_x_subconfig_rec.relationship_id is	a leaf node
	OPEN check_root_node;
	FETCH check_root_node INTO l_dummy_varchar;
	IF (check_root_node%FOUND)
	THEN
		FND_MESSAGE.Set_Name('AHL',	'AHL_MC_NOT_TOP_NODE');
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
				false
			);
		END	IF;
		RAISE FND_API.G_EXC_ERROR;
	END	IF;
	CLOSE check_root_node;

	OPEN check_leaf_node;
	FETCH check_leaf_node INTO l_dummy_varchar;
	IF (check_leaf_node%FOUND)
	THEN
		FND_MESSAGE.Set_Name('AHL',	'AHL_MC_NOT_LEAF_NODE');
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
				false
			);
		END	IF;
		RAISE FND_API.G_EXC_ERROR;
	END	IF;
	CLOSE check_leaf_node;

	-- Validate	the	MC with	mc_header_id = p_x_subconfig_rec.mc_header_id is complete/draft/approval_rejected
	l_header_status	:= Get_MC_Status(null, p_x_subconfig_rec.mc_header_id);
	IF (l_header_status	NOT	IN ('APPROVAL_PENDING',	'COMPLETE',	'DRAFT', 'APPROVAL_REJECTED'))
	THEN
		FND_MESSAGE.Set_Name('AHL',	'AHL_MC_SUBMC_STS_INV');
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
				false
			);
		END	IF;
		RAISE FND_API.G_EXC_ERROR;
	END	IF;

	-- Validate	whether	the	subconfiguration is	not	already	associated with	the	MC node
	OPEN check_submc_exists;
	FETCH check_submc_exists INTO l_mc_name;
	IF (check_submc_exists%FOUND)
	THEN
		FND_MESSAGE.Set_Name('AHL',	'AHL_MC_SUBMC_EXISTS');
		FND_MESSAGE.Set_Token('SUBMC', l_mc_name);
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
				false
			);
		END	IF;

		CLOSE check_submc_exists;
		RAISE FND_API.G_EXC_ERROR;
	END	IF;
	CLOSE check_submc_exists;

	-- anraj changed for fixing	the	bug	# 3696668
	-- Check cyclic	relationship for subconfig = p_x_subconfig_rec.mc_header_id	and	node = p_x_subconfig_rec.relationship_id
	--Check_Cyclic_Rel(p_x_subconfig_rec.mc_header_id, p_x_subconfig_rec.relationship_id);
	OPEN get_dest_header_id(p_x_subconfig_rec.relationship_id);
	FETCH get_dest_header_id into l_dest_header_id;
	CLOSE get_dest_header_id;
	l_cyclic_relation_exist	:= Cyclic_Relation_Exists(p_x_subconfig_rec.mc_header_id,l_dest_header_id);
	IF (l_cyclic_relation_exist) THEN
		OPEN get_node_mc_details(p_x_subconfig_rec.relationship_id);
		FETCH get_node_mc_details INTO l_mc_name;
		CLOSE get_node_mc_details;
		OPEN get_mc_details(p_x_subconfig_rec.mc_header_id);
		FETCH get_mc_details INTO l_submc_name;
		CLOSE get_mc_details;
		FND_MESSAGE.Set_Name('AHL',	'AHL_MC_CYCLIC_REL_EXIST');
		FND_MESSAGE.Set_Token('MC',	l_mc_name);
		FND_MESSAGE.Set_Token('SUBMC', l_submc_name);
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
		THEN
		  fnd_log.message
		  (
			  fnd_log.level_exception,
			  'ahl.plsql.'||G_PKG_NAME||'.Check_Cyclic_Rel',
			   false
		  );
		END	IF;
	 END IF;


	-- Check Error Message stack.
	l_msg_count	:= FND_MSG_PUB.count_msg;
	IF l_msg_count > 0 THEN
		RAISE FND_API.G_EXC_ERROR;
	END	IF;

	-- Validate	dates for the subconfig	association
	IF (trunc(nvl(p_x_subconfig_rec.active_start_date, G_SYSDATE)) < G_TRUNC_DATE)
	THEN
		FND_MESSAGE.Set_Name('AHL',	'AHL_MC_START_DATE_INV');
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
				false
			);
		END	IF;
	END	IF;

	IF (trunc(nvl(p_x_subconfig_rec.active_end_date, G_SYSDATE + 1)) <=	G_TRUNC_DATE)
	THEN
		FND_MESSAGE.Set_Name('AHL',	'AHL_MC_END_DATE_INV');
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
				false
			);
		END	IF;
	END	IF;

	IF (trunc(nvl(p_x_subconfig_rec.active_end_date, nvl(p_x_subconfig_rec.active_start_date, G_SYSDATE) + 1)) <= trunc(nvl(p_x_subconfig_rec.active_start_date, G_SYSDATE)))
	THEN
		FND_MESSAGE.Set_Name('AHL',	'AHL_MC_START_END_INV');
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
				false
			);
		END	IF;
	END	IF;

	IF (p_x_subconfig_rec.priority IS NULL)
	THEN
		FND_MESSAGE.Set_Name('AHL',	'AHL_MC_PRIORITY_SUBMC_NULL');
				FND_MESSAGE.Set_Token('SUB_MC',p_x_subconfig_rec.name);
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
				false
			);
		END	IF;
		ELSIF  (p_x_subconfig_rec.priority <= 0)
		THEN
		FND_MESSAGE.Set_Name('AHL',	'AHL_MC_PRIORITY_INVALID_JSP');
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
				false
			);
		END	IF;
	END	IF;

	-- Check Error Message stack.
	l_msg_count	:= FND_MSG_PUB.count_msg;
	IF l_msg_count > 0 THEN
		RAISE FND_API.G_EXC_ERROR;
	END	IF;

	IF (fnd_log.level_statement	>= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
			'Subconfiguration association validation successful'
		);
	END	IF;

	-- Set values for p_x_subconfig_rec
	SELECT ahl_mc_config_rel_s.nextval INTO	p_x_subconfig_rec.mc_config_relation_id	FROM DUAL;
	p_x_subconfig_rec.object_version_number	:= 1;
	p_x_subconfig_rec.security_group_id	:= null;

	-- Create association record for destination node
	INSERT INTO	AHL_MC_CONFIG_RELATIONS
	(
		MC_CONFIG_RELATION_ID,
		RELATIONSHIP_ID,
		MC_HEADER_ID,
		ACTIVE_START_DATE,
		ACTIVE_END_DATE,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_LOGIN,
		OBJECT_VERSION_NUMBER,
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
		PRIORITY
	)
	VALUES
	(
		p_x_subconfig_rec.MC_CONFIG_RELATION_ID,
		p_x_subconfig_rec.RELATIONSHIP_ID,
		p_x_subconfig_rec.MC_HEADER_ID,
		TRUNC(p_x_subconfig_rec.ACTIVE_START_DATE),
		TRUNC(p_x_subconfig_rec.ACTIVE_END_DATE),
		G_SYSDATE,
		G_USER_ID,
		G_SYSDATE,
		G_USER_ID,
		G_LOGIN_ID,
		p_x_subconfig_rec.OBJECT_VERSION_NUMBER,
		p_x_subconfig_rec.SECURITY_GROUP_ID,
		p_x_subconfig_rec.ATTRIBUTE_CATEGORY,
		p_x_subconfig_rec.ATTRIBUTE1,
		p_x_subconfig_rec.ATTRIBUTE2,
		p_x_subconfig_rec.ATTRIBUTE3,
		p_x_subconfig_rec.ATTRIBUTE4,
		p_x_subconfig_rec.ATTRIBUTE5,
		p_x_subconfig_rec.ATTRIBUTE6,
		p_x_subconfig_rec.ATTRIBUTE7,
		p_x_subconfig_rec.ATTRIBUTE8,
		p_x_subconfig_rec.ATTRIBUTE9,
		p_x_subconfig_rec.ATTRIBUTE10,
		p_x_subconfig_rec.ATTRIBUTE11,
		p_x_subconfig_rec.ATTRIBUTE12,
		p_x_subconfig_rec.ATTRIBUTE13,
		p_x_subconfig_rec.ATTRIBUTE14,
		p_x_subconfig_rec.ATTRIBUTE15,
		p_x_subconfig_rec.priority
	);

	-- API body	ends here
END	Attach_Subconfig;

PROCEDURE Modify_Subconfig
(
	p_x_subconfig_rec	IN OUT	NOCOPY	Subconfig_Rec_Type
)
IS

	-- Define cursor get_subconfig_dates to	retrieve information about dates
	CURSOR get_subconfig_dates
	(
		p_mc_config_rel_id in number
	)
	IS
		SELECT active_start_date, active_end_date
		FROM ahl_mc_config_relations
		WHERE mc_config_relation_id	= p_mc_config_rel_id;

	-- Declare local variables
	l_api_name	CONSTANT	VARCHAR2(30)	:= 'Modify_Subconfig';
	l_msg_count			NUMBER;

	l_header_status			VARCHAR2(30);
	l_start_date			DATE;
	l_end_date			DATE;

BEGIN

	-- API body	starts here
	IF (fnd_log.level_procedure	>= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||'.begin',
			'At	the	start of PLSQL procedure'
		);
	END	IF;

	-- Validate	that the subconfiguration association exists
	Validate_Subconfig_Exists(p_x_subconfig_rec.mc_config_relation_id, nvl(p_x_subconfig_rec.object_version_number,	0));

	-- Validate	a MC node with relationship_id = p_x_subconfig_rec.relationship_id exists
	Validate_Node_Exists(p_x_subconfig_rec.relationship_id,	null);

	-- Validate	the	MC with	mc_header_id = p_x_subconfig_rec.mc_header_id is complete
	l_header_status	:= Get_MC_Status(null, p_x_subconfig_rec.mc_header_id);
	IF (l_header_status	NOT	IN ('APPROVAL_PENDING',	'COMPLETE',	'DRAFT', 'APPROVAL_REJECTED'))
	THEN
		FND_MESSAGE.Set_Name('AHL',	'AHL_MC_SUBMC_STS_INV');
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
				false
			);
		END	IF;
		RAISE FND_API.G_EXC_ERROR;
	END	IF;

	-- Validate	dates for the subconfig	association
	OPEN get_subconfig_dates(p_x_subconfig_rec.mc_config_relation_id);
	FETCH get_subconfig_dates INTO l_start_date, l_end_date;
	CLOSE get_subconfig_dates;

	/*
	-- Should be able to unexpire an expired subconfiguration association
	IF (G_TRUNC_DATE >=	trunc(nvl(l_end_date, G_SYSDATE	+ 1)))
	THEN
		FND_MESSAGE.Set_Name('AHL',	'AHL_MC_SUBMC_DATE_INV');
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
				false
			);
		END	IF;
	END	IF;
	*/

	IF (p_x_subconfig_rec.active_start_date	IS NOT NULL	AND	trunc(nvl(l_start_date,	G_SYSDATE))	<> trunc(p_x_subconfig_rec.active_start_date) AND trunc(p_x_subconfig_rec.active_start_date) < G_TRUNC_DATE)
	THEN
		FND_MESSAGE.Set_Name('AHL',	'AHL_MC_START_DATE_INV');
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
				false
			);
		END	IF;
	END	IF;

	IF (trunc(nvl(l_end_date, G_SYSDATE)) <> trunc(nvl(p_x_subconfig_rec.active_end_date, G_SYSDATE)) AND trunc(nvl(p_x_subconfig_rec.active_end_date, G_SYSDATE + 1)) <= G_TRUNC_DATE)
	THEN
		FND_MESSAGE.Set_Name('AHL',	'AHL_MC_END_DATE_INV');
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
				false
			);
		END	IF;
	END	IF;

	IF (trunc(nvl(p_x_subconfig_rec.active_end_date, nvl(p_x_subconfig_rec.active_start_date, G_SYSDATE) + 1)) <= trunc(nvl(p_x_subconfig_rec.active_start_date, G_SYSDATE)))
	THEN
		FND_MESSAGE.Set_Name('AHL',	'AHL_MC_START_END_INV');
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
				false
			);
		END	IF;
	END	IF;


	IF (p_x_subconfig_rec.priority IS NULL)
	THEN
		FND_MESSAGE.Set_Name('AHL',	'AHL_MC_PRIORITY_SUBMC_NULL');
				FND_MESSAGE.Set_Token('SUB_MC',p_x_subconfig_rec.name);
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
				false
			);
		END	IF;
		ELSIF  (p_x_subconfig_rec.priority <= 0)
		THEN
		FND_MESSAGE.Set_Name('AHL',	'AHL_MC_PRIORITY_INVALID_JSP');
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
				false
			);
		END	IF;

	END	IF;

	-- Check Error Message stack.
	l_msg_count	:= FND_MSG_PUB.count_msg;
	IF l_msg_count > 0 THEN
		RAISE FND_API.G_EXC_ERROR;
	END	IF;

	IF (fnd_log.level_statement	>= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
			'Subconfiguration association validation successful'
		);
	END	IF;

	p_x_subconfig_rec.OBJECT_VERSION_NUMBER	:= p_x_subconfig_rec.OBJECT_VERSION_NUMBER + 1;

	-- Create association record for destination node
	UPDATE	AHL_MC_CONFIG_RELATIONS
	SET	PRIORITY				= p_x_subconfig_rec.priority,
		ACTIVE_START_DATE	= p_x_subconfig_rec.ACTIVE_START_DATE,
		ACTIVE_END_DATE		= p_x_subconfig_rec.ACTIVE_END_DATE,
		LAST_UPDATE_DATE	= G_SYSDATE,
		LAST_UPDATED_BY		= G_USER_ID,
		LAST_UPDATE_LOGIN	= G_LOGIN_ID,
		OBJECT_VERSION_NUMBER	= p_x_subconfig_rec.OBJECT_VERSION_NUMBER,
		SECURITY_GROUP_ID	= p_x_subconfig_rec.SECURITY_GROUP_ID,
		ATTRIBUTE_CATEGORY	= p_x_subconfig_rec.ATTRIBUTE_CATEGORY,
		ATTRIBUTE1		= p_x_subconfig_rec.ATTRIBUTE1,
		ATTRIBUTE2		= p_x_subconfig_rec.ATTRIBUTE2,
		ATTRIBUTE3		= p_x_subconfig_rec.ATTRIBUTE3,
		ATTRIBUTE4		= p_x_subconfig_rec.ATTRIBUTE4,
		ATTRIBUTE5		= p_x_subconfig_rec.ATTRIBUTE5,
		ATTRIBUTE6		= p_x_subconfig_rec.ATTRIBUTE6,
		ATTRIBUTE7		= p_x_subconfig_rec.ATTRIBUTE7,
		ATTRIBUTE8		= p_x_subconfig_rec.ATTRIBUTE8,
		ATTRIBUTE9		= p_x_subconfig_rec.ATTRIBUTE9,
		ATTRIBUTE10		= p_x_subconfig_rec.ATTRIBUTE10,
		ATTRIBUTE11		= p_x_subconfig_rec.ATTRIBUTE11,
		ATTRIBUTE12		= p_x_subconfig_rec.ATTRIBUTE12,
		ATTRIBUTE13		= p_x_subconfig_rec.ATTRIBUTE13,
		ATTRIBUTE14		= p_x_subconfig_rec.ATTRIBUTE14,
		ATTRIBUTE15		= p_x_subconfig_rec.ATTRIBUTE15
	WHERE	MC_CONFIG_RELATION_ID	= p_x_subconfig_rec.MC_CONFIG_RELATION_ID;

	-- API body	ends here

END	Modify_Subconfig;

PROCEDURE Detach_Subconfig
(
	p_mc_config_relation_id	IN		NUMBER,
	p_object_ver_num	IN		NUMBER
)
IS
	-- Define local	variables
	l_api_name	CONSTANT	VARCHAR2(30)	:= 'Detach_Subconfig';

BEGIN

	-- API body	starts here
	IF (fnd_log.level_procedure	>= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||'.begin',
			'At	the	start of PLSQL procedure'
		);
	END	IF;

	-- Validate	p_mc_config_relation_id	exists
	Validate_Subconfig_Exists(p_mc_config_relation_id, nvl(p_object_ver_num, 0));

	DELETE FROM	ahl_mc_config_relations
	WHERE mc_config_relation_id	= p_mc_config_relation_id;

	IF (fnd_log.level_procedure	>= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||'.end',
			'At	the	end	of PLSQL procedure'
		);
	END	IF;
	-- API body	ends here

END	Detach_Subconfig;

PROCEDURE Copy_Subconfig
(
	p_source_rel_id			IN		NUMBER,
	p_dest_rel_id		IN		NUMBER
)
IS
	-- Define a	cursor to get the MC header	id , when a	relationship id	is given
	CURSOR get_dest_header_id
	IS
		SELECT mc_header_id
		FROM ahl_mc_relationships
		WHERE relationship_id =	p_dest_rel_id;
	-- Define cursor get_node_mc_details to	read detail	of the MC of a MC node
	CURSOR get_node_mc_details
	IS
		SELECT	mch.name
		FROM	ahl_mc_headers_b mch, ahl_mc_relationships mcr
		WHERE	mch.mc_header_id = mcr.mc_header_id	AND
			mcr.relationship_id	= p_dest_rel_id;
	-- Define cursor get_mc_details	to read	detail of a	MC
	CURSOR get_mc_details(p_subconfig_id in	number)
	IS
		SELECT	name
		FROM	ahl_mc_headers_b
		WHERE	mc_header_id = p_subconfig_id;
	-- Define cursor get_subconfigs	to read	all	valid subconfiguration associations	with a particular MC node
	CURSOR get_subconfigs
	IS
		SELECT	*
		FROM	ahl_mc_config_relations
		WHERE	relationship_id	= p_source_rel_id;
			-- Expired subconfig associations also need	to be copied or	else copying position paths	will fail
			-- AND G_TRUNC_DATE	< trunc(nvl(active_end_date, G_SYSDATE + 1));

	-- Define check_leaf_node to check whether the node	to which subconfiguration is being associated is a leaf	node
	CURSOR check_leaf_node
	(
		p_rel_id in	number
	)
	IS
		SELECT	'x'
		FROM	ahl_mc_relationships
		WHERE	parent_relationship_id = p_rel_id AND
			G_TRUNC_DATE < trunc(nvl(active_end_date, G_SYSDATE	+ 1));

	-- Declare local variables
	l_api_name	CONSTANT	VARCHAR2(30)	:= 'Copy_Subconfig';
	l_msg_count			NUMBER;

	l_subconfig_csr_rec		get_subconfigs%rowtype;
	-- new local variables declared
	l_mc_config_rel_id		 NUMBER;
	l_cyclic_relation_exist	 BOOLEAN :=	FALSE;
	l_dest_header_id		 NUMBER;
	l_mc_name				 VARCHAR2(80);
	l_submc_name			 VARCHAR2(80);

BEGIN

	-- API body	starts here
	IF (fnd_log.level_procedure	>= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||'.begin',
			'At	the	start of PLSQL procedure'
		);
	END	IF;

	-- Validate	p_source_rel_id	exists
	Validate_Node_Exists(p_source_rel_id, null);

	-- Validate	p_dest_rel_id exists
	Validate_Node_Exists(p_dest_rel_id,	null);

	-- Check Error Message stack.
	l_msg_count	:= FND_MSG_PUB.count_msg;
	IF l_msg_count > 0 THEN
		RAISE FND_API.G_EXC_ERROR;
	END	IF;

	IF (fnd_log.level_statement	>= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
			'Source	and	destination	node validation	successful'
		);
	END	IF;

	-- Retrieve	all	subconfigurations associations with	p_source_rel_id
	OPEN get_subconfigs;
	LOOP
		FETCH get_subconfigs INTO l_subconfig_csr_rec;
		EXIT WHEN get_subconfigs% NOTFOUND;

		-- Validte p_dest_rel_id is	leaf node
		OPEN check_leaf_node(p_dest_rel_id);
		FETCH check_leaf_node INTO l_dummy_varchar;
		IF (check_leaf_node%FOUND)
		THEN
			FND_MESSAGE.Set_Name('AHL',	'AHL_MC_NOT_LEAF_NODE');
			FND_MSG_PUB.ADD;
			IF (fnd_log.level_exception	>= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.message
				(
					fnd_log.level_exception,
					'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
					false
				);
			END	IF;
			RAISE FND_API.G_EXC_ERROR;
		END	IF;
		CLOSE check_leaf_node;

		-- anraj changed for fixing	the	bug	# 3696668
		-- Check cyclic	relationship for this association
		-- Check_Cyclic_Rel(l_subconfig_csr_rec.mc_header_id, p_dest_rel_id);
		OPEN get_dest_header_id;
		FETCH get_dest_header_id into l_dest_header_id;
		CLOSE get_dest_header_id;
		IF (l_subconfig_csr_rec.mc_header_id = l_dest_header_id) THEN
			l_cyclic_relation_exist	:= TRUE;
		ELSE
			l_cyclic_relation_exist	:= Cyclic_Relation_Exists(l_subconfig_csr_rec.mc_header_id,l_dest_header_id);
		END	IF;
		IF (l_cyclic_relation_exist) THEN
		  OPEN get_node_mc_details;
		  FETCH	get_node_mc_details	INTO l_mc_name;
		  CLOSE	get_node_mc_details;

		  OPEN get_mc_details(l_subconfig_csr_rec.mc_header_id);
		  FETCH	get_mc_details INTO	l_submc_name;
		  CLOSE	get_mc_details;
		  FND_MESSAGE.Set_Name('AHL', 'AHL_MC_CYCLIC_REL_EXIST');
		  FND_MESSAGE.Set_Token('MC', l_mc_name);
		  FND_MESSAGE.Set_Token('SUBMC', l_submc_name);
		  FND_MSG_PUB.ADD;
		  IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
		  THEN
			  fnd_log.message
			  (
				fnd_log.level_exception,
				'ahl.plsql.'||G_PKG_NAME||'.Check_Cyclic_Rel',
				false
			   );
		  END IF;
		END	IF;
		-- Check Error Message stack.
		l_msg_count	:= FND_MSG_PUB.count_msg;
		IF l_msg_count > 0 THEN
			RAISE FND_API.G_EXC_ERROR;
		END	IF;

		IF (fnd_log.level_statement	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_statement,
				'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
				'Cyclic	relation check for node	['||p_dest_rel_id||'] and subconfiguration ['||l_subconfig_csr_rec.mc_header_id||']	is successful'
			);
		END	IF;

		-- Set values for l_subconfig_csr_rec
		SELECT ahl_mc_config_rel_s.nextval INTO	l_mc_config_rel_id FROM	DUAL;

		-- Create association record for destination node
		INSERT INTO	AHL_MC_CONFIG_RELATIONS
		(
			MC_CONFIG_RELATION_ID,
			RELATIONSHIP_ID,
			MC_HEADER_ID,
			ACTIVE_START_DATE,
			ACTIVE_END_DATE,
			LAST_UPDATE_DATE,
			LAST_UPDATED_BY,
			CREATION_DATE,
			CREATED_BY,
			LAST_UPDATE_LOGIN,
			OBJECT_VERSION_NUMBER,
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
			PRIORITY
		)
		VALUES
		(
			l_mc_config_rel_id,
			p_dest_rel_id,
			l_subconfig_csr_rec.MC_HEADER_ID,
			TRUNC(l_subconfig_csr_rec.ACTIVE_START_DATE),
			TRUNC(l_subconfig_csr_rec.ACTIVE_END_DATE),
			G_SYSDATE,
			G_USER_ID,
			G_SYSDATE,
			G_USER_ID,
			G_LOGIN_ID,
			1,
			l_subconfig_csr_rec.SECURITY_GROUP_ID,
			l_subconfig_csr_rec.ATTRIBUTE_CATEGORY,
			l_subconfig_csr_rec.ATTRIBUTE1,
			l_subconfig_csr_rec.ATTRIBUTE2,
			l_subconfig_csr_rec.ATTRIBUTE3,
			l_subconfig_csr_rec.ATTRIBUTE4,
			l_subconfig_csr_rec.ATTRIBUTE5,
			l_subconfig_csr_rec.ATTRIBUTE6,
			l_subconfig_csr_rec.ATTRIBUTE7,
			l_subconfig_csr_rec.ATTRIBUTE8,
			l_subconfig_csr_rec.ATTRIBUTE9,
			l_subconfig_csr_rec.ATTRIBUTE10,
			l_subconfig_csr_rec.ATTRIBUTE11,
			l_subconfig_csr_rec.ATTRIBUTE12,
			l_subconfig_csr_rec.ATTRIBUTE13,
			l_subconfig_csr_rec.ATTRIBUTE14,
			l_subconfig_csr_rec.ATTRIBUTE15,
			l_subconfig_csr_rec.PRIORITY
		);

		IF (fnd_log.level_statement	>= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_statement,
				'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
				'Subconfiguration association ['||l_subconfig_csr_rec.mc_config_relation_id||']	copied to ['||l_mc_config_rel_id||']'
			);
		END	IF;
	END	LOOP;
	CLOSE get_subconfigs;

	IF (fnd_log.level_procedure	>= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||'.end',
			'At	the	end	of PLSQL procedure'
		);
	END	IF;
	-- API body	ends here

END	Copy_Subconfig;

End	AHL_MC_Node_PVT;

/
