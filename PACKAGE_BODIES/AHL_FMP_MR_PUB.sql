--------------------------------------------------------
--  DDL for Package Body AHL_FMP_MR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_FMP_MR_PUB" AS
/* $Header: AHLPMRHB.pls 120.2.12010000.2 2009/09/04 05:33:39 sikumar ship $ */

PROCEDURE Create_Mr
(
	-- default IN params
	p_api_version			IN		NUMBER,
	p_init_msg_list			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_commit			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_validation_level		IN		NUMBER		:=FND_API.G_VALID_LEVEL_FULL,
	p_default			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_module_type			IN		VARCHAR2	:=NULL,
	-- default OUT params
	x_return_status             	OUT NOCOPY  	VARCHAR2,
	x_msg_count                	OUT NOCOPY  	NUMBER,
	x_msg_data                  	OUT NOCOPY  	VARCHAR2,
	-- functionality specific params
	p_x_mr_header_rec		IN OUT NOCOPY	AHL_FMP_MR_HEADER_PVT.mr_header_rec,
	p_x_mr_doc_tbl			IN OUT NOCOPY	AHL_FMP_MR_DOC_ASSO_PVT.doc_association_tbl,
	p_x_mr_route_tbl		IN OUT NOCOPY	AHL_FMP_MR_ROUTE_PVT.mr_route_tbl,
	p_x_mr_visit_type_tbl		IN OUT NOCOPY	AHL_FMP_MR_VISIT_TYPES_PVT.mr_visit_type_tbl_type,
	p_x_effectivity_tbl  		IN OUT NOCOPY 	AHL_FMP_MR_EFFECTIVITY_PVT.effectivity_tbl_type,
	p_x_mr_relation_tbl            	IN OUT NOCOPY 	AHL_FMP_MR_RELATION_PVT.mr_relation_tbl
)
IS
	-- 1.	Declare local variables
	l_api_name	CONSTANT	VARCHAR2(30)	:= 'Create_Mr';
	l_api_version	CONSTANT	NUMBER		:= 1.0;
	l_return_status			VARCHAR2(1);
	l_msg_count         		NUMBER;
	l_msg_data          		VARCHAR2(2000);
	L_DEBUG_MODULE	CONSTANT	VARCHAR2(100)	:= 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

BEGIN
	-- Standard start of API savepoint
	SAVEPOINT Create_Mr_SP;

	-- Standard call to check for call compatibility
	IF NOT FND_API.compatible_api_call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message, depending on p_init_msg_list flag
	IF FND_API.TO_BOOLEAN(p_init_msg_list) THEN
		FND_MSG_PUB.Initialize;
	END IF;

	-- Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- Log API entry point
	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			L_DEBUG_MODULE||'.begin',
			'At the start of PLSQL procedure'
		);
	END IF;

	-- API body starts here
	IF p_x_mr_header_rec.DML_OPERATION = 'C'
	THEN
		AHL_FMP_MR_HEADER_PVT.CREATE_MR_HEADER
		(
			p_api_version          	=> 1.0,
			p_init_msg_list        	=> FND_API.G_FALSE,
			p_commit               	=> FND_API.G_FALSE,
			p_validation_level     	=> p_validation_level,
			p_default              	=> p_default,
			p_module_type          	=> p_module_type,
			x_return_status        	=> x_return_status,
			x_msg_count            	=> x_msg_count,
			x_msg_data             	=> x_msg_data,
			p_x_mr_header_rec      	=> p_x_mr_header_rec
		);

		x_msg_count := FND_MSG_PUB.count_msg;
		IF x_msg_count > 0 OR x_return_status <> FND_API.G_RET_STS_SUCCESS
		THEN
			RAISE FND_API.G_EXC_ERROR;
		END IF;

		IF (p_x_mr_header_rec.mr_header_id IS NULL)
		THEN
			IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.string
				(
					fnd_log.level_error,
					L_DEBUG_MODULE,
					'After AHL_FMP_MR_HEADER_PVT.CREATE_MR_HEADER, mr_header_id is NULL'
				);
			END IF;

			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_statement,
				L_DEBUG_MODULE,
				'AHL_FMP_MR_HEADER_PVT.CREATE_MR_HEADER successful with p_x_mr_header_rec.mr_header_id = '||TO_CHAR(p_x_mr_header_rec.mr_header_id)
			);
		END IF;
	ElSE
		FND_MESSAGE.SET_NAME('AHL', 'AHL_COM_INVALID_DML_FLAG');
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_error,
				L_DEBUG_MODULE,
				'Invalid DML Operation specified'
			);
		END IF;

		RAISE FND_API.G_EXC_ERROR;
	END IF;

	IF p_x_mr_doc_tbl.COUNT > 0
	THEN
		FOR i IN p_x_mr_doc_tbl.FIRST..p_x_mr_doc_tbl.LAST
		LOOP
			p_x_mr_doc_tbl(i).OBJECT_TYPE_CODE := 'MR';
			p_x_mr_doc_tbl(i).MR_HEADER_ID := p_x_mr_header_rec.mr_header_id;
			p_x_mr_doc_tbl(i).MR_TITLE := p_x_mr_header_rec.title;
			p_x_mr_doc_tbl(i).MR_VERSION_NUMBER := p_x_mr_header_rec.version_number;
			p_x_mr_doc_tbl(i).DML_OPERATION := 'C';
		END LOOP;

		AHL_FMP_MR_DOC_ASSO_PVT.Process_Doc_Association
		(
			p_api_version          	=> 1.0,
			p_init_msg_list        	=> FND_API.G_FALSE,
			p_commit               	=> FND_API.G_FALSE,
			p_validation_level     	=> p_validation_level,
			p_default              	=> p_default,
			p_module_type          	=> p_module_type,
			x_return_status        	=> x_return_status,
			x_msg_count            	=> x_msg_count,
			x_msg_data             	=> x_msg_data,
			p_x_association_tbl	=> p_x_mr_doc_tbl
		);

		x_msg_count := FND_MSG_PUB.count_msg;
		IF x_msg_count > 0 OR x_return_status <> FND_API.G_RET_STS_SUCCESS
		THEN
			RAISE FND_API.G_EXC_ERROR;
		END IF;

		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_statement,
				L_DEBUG_MODULE,
				'AHL_FMP_MR_DOC_ASSO_PVT.Process_Doc_Association is successful'
			);
		END IF;
	END IF;

	IF p_x_mr_route_tbl.COUNT > 0
	THEN
		FOR i IN p_x_mr_route_tbl.FIRST..p_x_mr_route_tbl.LAST
		LOOP
			p_x_mr_route_tbl(i).MR_HEADER_ID := p_x_mr_header_rec.mr_header_id;
			p_x_mr_route_tbl(i).MR_TITLE := p_x_mr_header_rec.title;
			p_x_mr_route_tbl(i).MR_VERSION_NUMBER := p_x_mr_header_rec.version_number;
			p_x_mr_route_tbl(i).DML_OPERATION := 'C';
		END LOOP;

		AHL_FMP_MR_ROUTE_PVT.PROCESS_MR_ROUTE
		(
			p_api_version          	=> 1.0,
			p_init_msg_list        	=> FND_API.G_FALSE,
			p_commit               	=> FND_API.G_FALSE,
			p_validation_level     	=> p_validation_level,
			p_default              	=> p_default,
			p_module_type          	=> p_module_type,
			x_return_status        	=> x_return_status,
			x_msg_count            	=> x_msg_count,
			x_msg_data             	=> x_msg_data,
			p_x_mr_route_tbl	=> p_x_mr_route_tbl
		);

		x_msg_count := FND_MSG_PUB.count_msg;
		IF x_msg_count > 0 OR x_return_status <> FND_API.G_RET_STS_SUCCESS
		THEN
			RAISE FND_API.G_EXC_ERROR;
		END IF;

		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_statement,
				L_DEBUG_MODULE,
				'AHL_FMP_MR_ROUTE_PVT.PROCESS_MR_ROUTE is successful'
			);
		END IF;
	END IF;

	IF p_x_mr_visit_type_tbl.COUNT > 0
	THEN
		FOR i IN p_x_mr_visit_type_tbl.FIRST..p_x_mr_visit_type_tbl.LAST
		LOOP
			p_x_mr_visit_type_tbl(i).MR_HEADER_ID := p_x_mr_header_rec.mr_header_id;
			p_x_mr_visit_type_tbl(i).DML_OPERATION := 'C';
		END LOOP;

		AHL_FMP_MR_VISIT_TYPES_PVT.PROCESS_MR_VISIT_TYPES
		(
			p_api_version          	=> 1.0,
			p_init_msg_list        	=> FND_API.G_FALSE,
			p_commit               	=> FND_API.G_FALSE,
			p_validation_level     	=> p_validation_level,
			p_default              	=> p_default,
			p_module_type          	=> p_module_type,
			x_return_status        	=> x_return_status,
			x_msg_count            	=> x_msg_count,
			x_msg_data             	=> x_msg_data,
			p_x_mr_visit_type_tbl	=> p_x_mr_visit_type_tbl
		);

		x_msg_count := FND_MSG_PUB.count_msg;
		IF x_msg_count > 0 OR x_return_status <> FND_API.G_RET_STS_SUCCESS
		THEN
			RAISE FND_API.G_EXC_ERROR;
		END IF;

		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_statement,
				L_DEBUG_MODULE,
				'AHL_FMP_MR_VISIT_TYPES_PVT.PROCESS_MR_VISIT_TYPES is successful'
			);
		END IF;
	END IF;

	IF p_x_effectivity_tbl.COUNT > 0
	THEN
		FOR i IN p_x_effectivity_tbl.FIRST..p_x_effectivity_tbl.LAST
		LOOP
			p_x_effectivity_tbl(i).DML_OPERATION := 'C';
		END LOOP;

		AHL_FMP_MR_EFFECTIVITY_PVT.process_effectivity
		(
			p_api_version          	=> 1.0,
			p_init_msg_list        	=> FND_API.G_FALSE,
			p_commit               	=> FND_API.G_FALSE,
			p_validation_level     	=> p_validation_level,
			p_default              	=> p_default,
			p_module_type          	=> p_module_type,
			x_return_status        	=> x_return_status,
			x_msg_count            	=> x_msg_count,
			x_msg_data             	=> x_msg_data,
			p_x_effectivity_tbl	=> p_x_effectivity_tbl,
			p_mr_header_id		=> p_x_mr_header_rec.mr_header_id,
			p_super_user		=> p_x_mr_header_rec.superuser_role
		);

		x_msg_count := FND_MSG_PUB.count_msg;
		IF x_msg_count > 0 OR x_return_status <> FND_API.G_RET_STS_SUCCESS
		THEN
			RAISE FND_API.G_EXC_ERROR;
		END IF;

		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_statement,
				L_DEBUG_MODULE,
				'AHL_FMP_MR_EFFECTIVITY_PVT.process_effectivity is successful'
			);
		END IF;
	END IF;

	IF p_x_mr_relation_tbl.COUNT > 0
	THEN
		FOR i IN p_x_mr_relation_tbl.FIRST..p_x_mr_relation_tbl.LAST
		LOOP
			p_x_mr_relation_tbl(i).MR_HEADER_ID := p_x_mr_header_rec.mr_header_id;
			p_x_mr_relation_tbl(i).MR_TITLE := p_x_mr_header_rec.title;
			p_x_mr_relation_tbl(i).MR_VERSION_NUMBER := p_x_mr_header_rec.version_number;
			p_x_mr_relation_tbl(i).DML_OPERATION := 'C';
		END LOOP;

		AHL_FMP_MR_RELATION_PVT.PROCESS_MR_RELATION
		(
			p_api_version          	=> 1.0,
			p_init_msg_list        	=> FND_API.G_FALSE,
			p_commit               	=> FND_API.G_FALSE,
			p_validation_level     	=> p_validation_level,
			p_default              	=> p_default,
			p_module_type          	=> p_module_type,
			x_return_status        	=> x_return_status,
			x_msg_count            	=> x_msg_count,
			x_msg_data             	=> x_msg_data,
			p_x_mr_relation_tbl	=> p_x_mr_relation_tbl
		);

		x_msg_count := FND_MSG_PUB.count_msg;
		IF x_msg_count > 0 OR x_return_status <> FND_API.G_RET_STS_SUCCESS
		THEN
			RAISE FND_API.G_EXC_ERROR;
		END IF;

		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_statement,
				L_DEBUG_MODULE,
				'AHL_FMP_MR_RELATION_PVT.PROCESS_MR_RELATION is successful'
			);
		END IF;
	END IF;

	-- API body ends here

	-- Log API exit point
	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
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

	-- Commit, depending on p_commit flag
	IF FND_API.TO_BOOLEAN(p_commit) THEN
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
		Rollback to Create_Mr_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to Create_Mr_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to Create_Mr_SP;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.add_exc_msg
			(
				p_pkg_name		=> G_PKG_NAME,
				p_procedure_name 	=> 'Create_Mr',
				p_error_text     	=> SUBSTR(SQLERRM,1,240)
			);
		END IF;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

END Create_Mr;

PROCEDURE Modify_Mr
(
	-- default IN params
	p_api_version			IN		NUMBER,
	p_init_msg_list			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_commit			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_validation_level		IN		NUMBER		:=FND_API.G_VALID_LEVEL_FULL,
	p_default			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_module_type			IN		VARCHAR2	:=NULL,
	-- default OUT params
	x_return_status             	OUT NOCOPY  	VARCHAR2,
	x_msg_count                	OUT NOCOPY  	NUMBER,
	x_msg_data                  	OUT NOCOPY  	VARCHAR2,
	-- functionality specific params
	p_mr_header_rec			IN		AHL_FMP_MR_HEADER_PVT.mr_header_rec,
	p_x_mr_doc_tbl			IN OUT NOCOPY	AHL_FMP_MR_DOC_ASSO_PVT.doc_association_tbl,
	p_x_mr_route_tbl		IN OUT NOCOPY	AHL_FMP_MR_ROUTE_PVT.mr_route_tbl,
	p_x_mr_visit_type_tbl		IN OUT NOCOPY	AHL_FMP_MR_VISIT_TYPES_PVT.mr_visit_type_tbl_type,
	p_x_effectivity_tbl  		IN OUT NOCOPY 	AHL_FMP_MR_EFFECTIVITY_PVT.effectivity_tbl_type,
	p_x_mr_relation_tbl            	IN OUT NOCOPY 	AHL_FMP_MR_RELATION_PVT.mr_relation_tbl
)
IS
	-- 1.	Declare local variables
	l_api_name	CONSTANT	VARCHAR2(30)	:= 'Modify_Mr';
	l_api_version	CONSTANT	NUMBER		:= 1.0;
	l_return_status			VARCHAR2(1);
	l_msg_count         		NUMBER;
	l_msg_data          		VARCHAR2(2000);
	L_DEBUG_MODULE	CONSTANT	VARCHAR2(100)	:= 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

	l_mr_header_rec			AHL_FMP_MR_HEADER_PVT.mr_header_rec 	:= p_mr_header_rec;

BEGIN
	-- Standard start of API savepoint
	SAVEPOINT Modify_Mr_SP;

	-- Standard call to check for call compatibility
	IF NOT FND_API.compatible_api_call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message, depending on p_init_msg_list flag
	IF FND_API.TO_BOOLEAN(p_init_msg_list) THEN
		FND_MSG_PUB.Initialize;
	END IF;

	-- Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- Log API entry point
	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			L_DEBUG_MODULE||'.begin',
			'At the start of PLSQL procedure'
		);
	END IF;

	-- API body starts here
	IF (l_mr_header_rec.mr_header_id IS NULL)
	THEN
		AHL_FMP_COMMON_PVT.mr_title_version_to_id
		(
			p_mr_title		=> l_mr_header_rec.title,
			p_mr_version_number	=> l_mr_header_rec.version_number,
			x_mr_header_id		=> l_mr_header_rec.mr_header_id,
			x_return_status		=> x_return_status
		);

		x_msg_count := FND_MSG_PUB.count_msg;
		IF x_msg_count > 0 OR x_return_status <> FND_API.G_RET_STS_SUCCESS
		THEN
			IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.string
				(
					fnd_log.level_error,
					L_DEBUG_MODULE||'.end',
					'AHL_FMP_COMMON_PVT.mr_title_version_to_id returned error'
				);
			END IF;
			RAISE FND_API.G_EXC_ERROR;
		END IF;
	END IF;

	IF l_mr_header_rec.DML_OPERATION = 'U'
	THEN
		AHL_FMP_MR_HEADER_PVT.UPDATE_MR_HEADER
		(
			p_api_version          	=> 1.0,
			p_init_msg_list        	=> FND_API.G_FALSE,
			p_commit               	=> FND_API.G_FALSE,
			p_validation_level     	=> p_validation_level,
			p_default              	=> p_default,
			p_module_type          	=> p_module_type,
			x_return_status        	=> x_return_status,
			x_msg_count            	=> x_msg_count,
			x_msg_data             	=> x_msg_data,
			p_x_mr_header_rec      	=> l_mr_header_rec
		);

		x_msg_count := FND_MSG_PUB.count_msg;
		IF x_msg_count > 0 OR x_return_status <> FND_API.G_RET_STS_SUCCESS
		THEN
			RAISE FND_API.G_EXC_ERROR;
		END IF;

		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_statement,
				L_DEBUG_MODULE,
				'AHL_FMP_MR_HEADER_PVT.UPDATE_MR_HEADER successful'
			);
		END IF;
	ElSIF (l_mr_header_rec.DML_OPERATION IS NOT NULL)
	THEN
		FND_MESSAGE.SET_NAME('AHL', 'AHL_COM_INVALID_DML_FLAG');
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_error,
				L_DEBUG_MODULE,
				'Invalid DML Operation specified'
			);
		END IF;

		RAISE FND_API.G_EXC_ERROR;
	END IF;

	IF p_x_mr_doc_tbl.COUNT > 0
	THEN
		FOR i IN p_x_mr_doc_tbl.FIRST..p_x_mr_doc_tbl.LAST
		LOOP
			p_x_mr_doc_tbl(i).OBJECT_TYPE_CODE := 'MR';
			p_x_mr_doc_tbl(i).MR_HEADER_ID := l_mr_header_rec.mr_header_id;
			p_x_mr_doc_tbl(i).MR_TITLE := l_mr_header_rec.title;
			p_x_mr_doc_tbl(i).MR_VERSION_NUMBER := l_mr_header_rec.version_number;
		END LOOP;

		AHL_FMP_MR_DOC_ASSO_PVT.Process_Doc_Association
		(
			p_api_version          	=> 1.0,
			p_init_msg_list        	=> FND_API.G_FALSE,
			p_commit               	=> FND_API.G_FALSE,
			p_validation_level     	=> p_validation_level,
			p_default              	=> p_default,
			p_module_type          	=> p_module_type,
			x_return_status        	=> x_return_status,
			x_msg_count            	=> x_msg_count,
			x_msg_data             	=> x_msg_data,
			p_x_association_tbl	=> p_x_mr_doc_tbl
		);

		x_msg_count := FND_MSG_PUB.count_msg;
		IF x_msg_count > 0 OR x_return_status <> FND_API.G_RET_STS_SUCCESS
		THEN
			RAISE FND_API.G_EXC_ERROR;
		END IF;

		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_statement,
				L_DEBUG_MODULE,
				'AHL_FMP_MR_DOC_ASSO_PVT.Process_Doc_Association is successful'
			);
		END IF;
	END IF;

	IF p_x_mr_route_tbl.COUNT > 0
	THEN
		FOR i IN p_x_mr_route_tbl.FIRST..p_x_mr_route_tbl.LAST
		LOOP
			p_x_mr_route_tbl(i).MR_HEADER_ID := l_mr_header_rec.mr_header_id;
			p_x_mr_route_tbl(i).MR_TITLE := l_mr_header_rec.title;
			p_x_mr_route_tbl(i).MR_VERSION_NUMBER := l_mr_header_rec.version_number;
		END LOOP;

		AHL_FMP_MR_ROUTE_PVT.PROCESS_MR_ROUTE
		(
			p_api_version          	=> 1.0,
			p_init_msg_list        	=> FND_API.G_FALSE,
			p_commit               	=> FND_API.G_FALSE,
			p_validation_level     	=> p_validation_level,
			p_default              	=> p_default,
			p_module_type          	=> p_module_type,
			x_return_status        	=> x_return_status,
			x_msg_count            	=> x_msg_count,
			x_msg_data             	=> x_msg_data,
			p_x_mr_route_tbl	=> p_x_mr_route_tbl
		);

		x_msg_count := FND_MSG_PUB.count_msg;
		IF x_msg_count > 0 OR x_return_status <> FND_API.G_RET_STS_SUCCESS
		THEN
			RAISE FND_API.G_EXC_ERROR;
		END IF;

		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_statement,
				L_DEBUG_MODULE,
				'AHL_FMP_MR_ROUTE_PVT.PROCESS_MR_ROUTE is successful'
			);
		END IF;
	END IF;

	IF p_x_mr_visit_type_tbl.COUNT > 0
	THEN
		FOR i IN p_x_mr_visit_type_tbl.FIRST..p_x_mr_visit_type_tbl.LAST
		LOOP
			p_x_mr_visit_type_tbl(i).MR_HEADER_ID := l_mr_header_rec.mr_header_id;
		END LOOP;

		AHL_FMP_MR_VISIT_TYPES_PVT.PROCESS_MR_VISIT_TYPES
		(
			p_api_version          	=> 1.0,
			p_init_msg_list        	=> FND_API.G_FALSE,
			p_commit               	=> FND_API.G_FALSE,
			p_validation_level     	=> p_validation_level,
			p_default              	=> p_default,
			p_module_type          	=> p_module_type,
			x_return_status        	=> x_return_status,
			x_msg_count            	=> x_msg_count,
			x_msg_data             	=> x_msg_data,
			p_x_mr_visit_type_tbl	=> p_x_mr_visit_type_tbl
		);

		x_msg_count := FND_MSG_PUB.count_msg;
		IF x_msg_count > 0 OR x_return_status <> FND_API.G_RET_STS_SUCCESS
		THEN
			RAISE FND_API.G_EXC_ERROR;
		END IF;

		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_statement,
				L_DEBUG_MODULE,
				'AHL_FMP_MR_VISIT_TYPES_PVT.PROCESS_MR_VISIT_TYPES is successful'
			);
		END IF;
	END IF;

	IF p_x_effectivity_tbl.COUNT > 0
	THEN
		AHL_FMP_MR_EFFECTIVITY_PVT.process_effectivity
		(
			p_api_version          	=> 1.0,
			p_init_msg_list        	=> FND_API.G_FALSE,
			p_commit               	=> FND_API.G_FALSE,
			p_validation_level     	=> p_validation_level,
			p_default              	=> p_default,
			p_module_type          	=> p_module_type,
			x_return_status        	=> x_return_status,
			x_msg_count            	=> x_msg_count,
			x_msg_data             	=> x_msg_data,
			p_x_effectivity_tbl	=> p_x_effectivity_tbl,
			p_mr_header_id		=> l_mr_header_rec.mr_header_id,
			p_super_user		=> l_mr_header_rec.superuser_role
		);

		x_msg_count := FND_MSG_PUB.count_msg;
		IF x_msg_count > 0 OR x_return_status <> FND_API.G_RET_STS_SUCCESS
		THEN
			RAISE FND_API.G_EXC_ERROR;
		END IF;

		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_statement,
				L_DEBUG_MODULE,
				'AHL_FMP_MR_EFFECTIVITY_PVT.process_effectivity is successful'
			);
		END IF;
	END IF;

	IF p_x_mr_relation_tbl.COUNT > 0
	THEN
		FOR i IN p_x_mr_relation_tbl.FIRST..p_x_mr_relation_tbl.LAST
		LOOP
			p_x_mr_relation_tbl(i).MR_HEADER_ID := l_mr_header_rec.mr_header_id;
			p_x_mr_relation_tbl(i).MR_TITLE := l_mr_header_rec.title;
			p_x_mr_relation_tbl(i).MR_VERSION_NUMBER := l_mr_header_rec.version_number;
		END LOOP;

		AHL_FMP_MR_RELATION_PVT.PROCESS_MR_RELATION
		(
			p_api_version          	=> 1.0,
			p_init_msg_list        	=> FND_API.G_FALSE,
			p_commit               	=> FND_API.G_FALSE,
			p_validation_level     	=> p_validation_level,
			p_default              	=> p_default,
			p_module_type          	=> p_module_type,
			x_return_status        	=> x_return_status,
			x_msg_count            	=> x_msg_count,
			x_msg_data             	=> x_msg_data,
			p_x_mr_relation_tbl	=> p_x_mr_relation_tbl
		);

		x_msg_count := FND_MSG_PUB.count_msg;
		IF x_msg_count > 0 OR x_return_status <> FND_API.G_RET_STS_SUCCESS
		THEN
			RAISE FND_API.G_EXC_ERROR;
		END IF;

		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_statement,
				L_DEBUG_MODULE,
				'AHL_FMP_MR_RELATION_PVT.PROCESS_MR_RELATION is successful'
			);
		END IF;
	END IF;

	-- API body ends here

	-- Log API exit point
	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
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

	-- Commit, depending on p_commit flag
	IF FND_API.TO_BOOLEAN(p_commit) THEN
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
		Rollback to Modify_Mr_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to Modify_Mr_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to Modify_Mr_SP;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.add_exc_msg
			(
				p_pkg_name		=> G_PKG_NAME,
				p_procedure_name 	=> 'Modify_Mr',
				p_error_text     	=> SUBSTR(SQLERRM,1,240)
			);
		END IF;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

END Modify_Mr;

PROCEDURE Delete_Mr
(
	-- standard IN params
	p_api_version			IN		NUMBER,
	p_init_msg_list			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_commit			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_validation_level		IN		NUMBER		:=FND_API.G_VALID_LEVEL_FULL,
	p_default			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_module_type			IN		VARCHAR2	:=NULL,
	-- standard OUT params
	x_return_status             	OUT NOCOPY  	VARCHAR2,
	x_msg_count                	OUT NOCOPY  	NUMBER,
	x_msg_data                  	OUT NOCOPY  	VARCHAR2,
	-- procedure params
	p_mr_header_id 			IN          	NUMBER,
	p_mr_title			IN		VARCHAR2,
	p_mr_version_number		IN		NUMBER,
	p_mr_object_version  		IN          	NUMBER
)
IS
	-- 1.	Declare local variables
	l_api_name	CONSTANT	VARCHAR2(30)	:= 'Delete_Mr';
	l_api_version	CONSTANT	NUMBER		:= 1.0;
	l_return_status			VARCHAR2(1);
	l_msg_count         		NUMBER;
	l_msg_data          		VARCHAR2(2000);
	L_DEBUG_MODULE	CONSTANT	VARCHAR2(100)	:= 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

	l_mr_header_id			NUMBER 		:= p_mr_header_id;

BEGIN
	-- Standard start of API savepoint
	SAVEPOINT Delete_Mr_SP;

	-- Standard call to check for call compatibility
	IF NOT FND_API.compatible_api_call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message, depending on p_init_msg_list flag
	IF FND_API.TO_BOOLEAN(p_init_msg_list) THEN
		FND_MSG_PUB.Initialize;
	END IF;

	-- Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- Log API entry point
	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			L_DEBUG_MODULE||'.begin',
			'At the start of PLSQL procedure'
		);
	END IF;

	-- API body starts here
	IF (l_mr_header_id IS NULL)
	THEN
		AHL_FMP_COMMON_PVT.mr_title_version_to_id
		(
			p_mr_title		=> p_mr_title,
			p_mr_version_number	=> p_mr_version_number,
			x_mr_header_id		=> l_mr_header_id,
			x_return_status		=> x_return_status
		);

		x_msg_count := FND_MSG_PUB.count_msg;
		IF x_msg_count > 0 OR x_return_status <> FND_API.G_RET_STS_SUCCESS
		THEN
			IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.string
				(
					fnd_log.level_error,
					L_DEBUG_MODULE||'.end',
					'AHL_FMP_COMMON_PVT.mr_title_version_to_id returned error'
				);
			END IF;
			RAISE FND_API.G_EXC_ERROR;
		END IF;
	END IF;

	AHL_FMP_MR_HEADER_PVT.DELETE_MR_HEADER
	(
		p_api_version          	=> 1.0,
		p_init_msg_list        	=> FND_API.G_FALSE,
		p_commit               	=> FND_API.G_FALSE,
		p_validation_level     	=> p_validation_level,
		p_default              	=> p_default,
		p_module_type          	=> p_module_type,
		x_return_status        	=> x_return_status,
		x_msg_count            	=> x_msg_count,
		x_msg_data             	=> x_msg_data,
		p_mr_header_id      	=> l_mr_header_id,
		p_OBJECT_VERSION_NUMBER	=> p_mr_object_version
	);

	x_msg_count := FND_MSG_PUB.count_msg;
	IF x_msg_count > 0 OR x_return_status <> FND_API.G_RET_STS_SUCCESS
	THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	-- API body ends here

	-- Log API exit point
	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
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

	-- Commit, depending on p_commit flag
	IF FND_API.TO_BOOLEAN(p_commit) THEN
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
		Rollback to Delete_Mr_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to Delete_Mr_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to Delete_Mr_SP;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.add_exc_msg
			(
				p_pkg_name		=> G_PKG_NAME,
				p_procedure_name 	=> 'Delete_Mr',
				p_error_text     	=> SUBSTR(SQLERRM,1,240)
			);
		END IF;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

END Delete_Mr;

PROCEDURE Create_Mr_Revision
(
	-- standard IN params
	p_api_version			IN		NUMBER,
	p_init_msg_list			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_commit			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_validation_level		IN		NUMBER		:=FND_API.G_VALID_LEVEL_FULL,
	p_default			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_module_type			IN		VARCHAR2	:=NULL,
	-- standard OUT params
	x_return_status             	OUT NOCOPY  	VARCHAR2,
	x_msg_count                	OUT NOCOPY  	NUMBER,
	x_msg_data                  	OUT NOCOPY  	VARCHAR2,
	-- procedure params
	p_mr_header_id 			IN          	NUMBER,
	p_mr_title			IN		VARCHAR2,
	p_mr_version_number		IN		NUMBER,
	p_mr_object_version		IN		NUMBER,
	x_new_mr_header_id         	OUT NOCOPY  	NUMBER
)
IS
	-- 1.	Declare local variables
	l_api_name	CONSTANT	VARCHAR2(30)	:= 'Create_Mr_Revision';
	l_api_version	CONSTANT	NUMBER		:= 1.0;
	l_return_status			VARCHAR2(1);
	l_msg_count         		NUMBER;
	l_msg_data          		VARCHAR2(2000);
	L_DEBUG_MODULE	CONSTANT	VARCHAR2(100)	:= 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

	l_mr_header_id			NUMBER 		:= p_mr_header_id;

BEGIN
	-- Standard start of API savepoint
	SAVEPOINT Create_Mr_Revision_SP;

	-- Standard call to check for call compatibility
	IF NOT FND_API.compatible_api_call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message, depending on p_init_msg_list flag
	IF FND_API.TO_BOOLEAN(p_init_msg_list) THEN
		FND_MSG_PUB.Initialize;
	END IF;

	-- Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- Log API entry point
	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			L_DEBUG_MODULE||'.begin',
			'At the start of PLSQL procedure'
		);
	END IF;

	-- API body starts here
	IF (l_mr_header_id IS NULL)
	THEN
		AHL_FMP_COMMON_PVT.mr_title_version_to_id
		(
			p_mr_title		=> p_mr_title,
			p_mr_version_number	=> p_mr_version_number,
			x_mr_header_id		=> l_mr_header_id,
			x_return_status		=> x_return_status
		);

		x_msg_count := FND_MSG_PUB.count_msg;
		IF x_msg_count > 0 OR x_return_status <> FND_API.G_RET_STS_SUCCESS
		THEN
			IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.string
				(
					fnd_log.level_error,
					L_DEBUG_MODULE||'.end',
					'AHL_FMP_COMMON_PVT.mr_title_version_to_id returned error'
				);
			END IF;
			RAISE FND_API.G_EXC_ERROR;
		END IF;
	END IF;

	-- Need to check for object_version_number here...

	AHL_FMP_MR_REVISION_PVT.CREATE_MR_REVISION
	(
		p_api_version          	=> 1.0,
		p_init_msg_list        	=> FND_API.G_FALSE,
		p_commit               	=> FND_API.G_FALSE,
		p_validation_level     	=> p_validation_level,
		p_default              	=> p_default,
		p_module_type          	=> p_module_type,
		x_return_status        	=> x_return_status,
		x_msg_count            	=> x_msg_count,
		x_msg_data             	=> x_msg_data,
		p_source_mr_header_id   => l_mr_header_id,
		x_new_mr_header_id	=> x_new_mr_header_id
	);

	x_msg_count := FND_MSG_PUB.count_msg;
	IF x_msg_count > 0 OR x_return_status <> FND_API.G_RET_STS_SUCCESS
	THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	-- API body ends here

	-- Log API exit point
	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
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

	-- Commit, depending on p_commit flag
	IF FND_API.TO_BOOLEAN(p_commit) THEN
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
		Rollback to Create_Mr_Revision_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to Create_Mr_Revision_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to Create_Mr_Revision_SP;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.add_exc_msg
			(
				p_pkg_name		=> G_PKG_NAME,
				p_procedure_name 	=> 'Create_Mr_Revision',
				p_error_text     	=> SUBSTR(SQLERRM,1,240)
			);
		END IF;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

END Create_Mr_Revision;

PROCEDURE Initiate_Mr_Approval
(
	-- standard IN params
	p_api_version			IN		NUMBER,
	p_init_msg_list			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_commit			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_validation_level		IN		NUMBER		:=FND_API.G_VALID_LEVEL_FULL,
	p_default			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_module_type			IN		VARCHAR2	:=NULL,
	-- standard OUT params
	x_return_status             	OUT NOCOPY  	VARCHAR2,
	x_msg_count                	OUT NOCOPY  	NUMBER,
	x_msg_data                  	OUT NOCOPY  	VARCHAR2,
	-- procedure params
	p_mr_header_id 			IN          	NUMBER,
	p_mr_title			IN		VARCHAR2,
	p_mr_version_number		IN		NUMBER,
	p_mr_object_version	     	IN          	NUMBER,
	p_apprv_type		     	IN          	VARCHAR2	:='COMPLETE'
)
IS
	-- 1.	Declare local variables
	l_api_name	CONSTANT	VARCHAR2(30)	:= 'Initiate_Mr_Approval';
	l_api_version	CONSTANT	NUMBER		:= 1.0;
	l_return_status			VARCHAR2(1);
	l_msg_count         		NUMBER;
	l_msg_data          		VARCHAR2(2000);
	L_DEBUG_MODULE	CONSTANT	VARCHAR2(100)	:= 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

	l_mr_header_id			NUMBER 		:= p_mr_header_id;

BEGIN
	-- Standard start of API savepoint
	SAVEPOINT Initiate_Mr_Approval_SP;

	-- Standard call to check for call compatibility
	IF NOT FND_API.compatible_api_call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message, depending on p_init_msg_list flag
	IF FND_API.TO_BOOLEAN(p_init_msg_list) THEN
		FND_MSG_PUB.Initialize;
	END IF;

	-- Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- Log API entry point
	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			L_DEBUG_MODULE||'.begin',
			'At the start of PLSQL procedure'
		);
	END IF;

	-- API body starts here
	IF (l_mr_header_id IS NULL)
	THEN
		AHL_FMP_COMMON_PVT.mr_title_version_to_id
		(
			p_mr_title		=> p_mr_title,
			p_mr_version_number	=> p_mr_version_number,
			x_mr_header_id		=> l_mr_header_id,
			x_return_status		=> x_return_status
		);

		x_msg_count := FND_MSG_PUB.count_msg;
		IF x_msg_count > 0 OR x_return_status <> FND_API.G_RET_STS_SUCCESS
		THEN
			IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.string
				(
					fnd_log.level_error,
					L_DEBUG_MODULE||'.end',
					'AHL_FMP_COMMON_PVT.mr_title_version_to_id returned error'
				);
			END IF;
			RAISE FND_API.G_EXC_ERROR;
		END IF;
	END IF;

	AHL_FMP_MR_REVISION_PVT.INITIATE_MR_APPROVAL
	(
		p_api_version          	=> 1.0,
		p_init_msg_list        	=> FND_API.G_FALSE,
		p_commit               	=> FND_API.G_FALSE,
		p_validation_level     	=> p_validation_level,
		p_default              	=> p_default,
		p_module_type          	=> p_module_type,
		x_return_status        	=> x_return_status,
		x_msg_count            	=> x_msg_count,
		x_msg_data             	=> x_msg_data,
		p_source_mr_header_id  	=> l_mr_header_id,
		p_object_Version_number	=> p_mr_object_version,
		p_apprv_type		=> p_apprv_type
	);

	x_msg_count := FND_MSG_PUB.count_msg;
	IF x_msg_count > 0 OR x_return_status <> FND_API.G_RET_STS_SUCCESS
	THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	-- API body ends here

	-- Log API exit point
	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
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

	-- Commit, depending on p_commit flag
	IF FND_API.TO_BOOLEAN(p_commit) THEN
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
		Rollback to Initiate_Mr_Approval_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to Initiate_Mr_Approval_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to Initiate_Mr_Approval_SP;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.add_exc_msg
			(
				p_pkg_name		=> G_PKG_NAME,
				p_procedure_name 	=> 'Initiate_Mr_Approval',
				p_error_text     	=> SUBSTR(SQLERRM,1,240)
			);
		END IF;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

END Initiate_Mr_Approval;

PROCEDURE Process_Mr_Route_Seq
(
	-- default IN params
	p_api_version			IN		NUMBER,
	p_init_msg_list			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_commit			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_validation_level		IN		NUMBER		:=FND_API.G_VALID_LEVEL_FULL,
	p_default			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_module_type			IN		VARCHAR2	:=NULL,
	-- default OUT params
	x_return_status             	OUT NOCOPY  	VARCHAR2,
	x_msg_count                	OUT NOCOPY  	NUMBER,
	x_msg_data                  	OUT NOCOPY  	VARCHAR2,
	-- functionality specific params
	p_x_mr_route_seq_tbl           	IN OUT NOCOPY 	AHL_FMP_MR_ROUTE_SEQNCE_PVT.mr_route_seq_tbl
)
IS
	-- 1.	Declare local variables
	l_api_name	CONSTANT	VARCHAR2(30)	:= 'Process_Mr_Route_Seq';
	l_api_version	CONSTANT	NUMBER		:= 1.0;
	l_return_status			VARCHAR2(1);
	l_msg_count         		NUMBER;
	l_msg_data          		VARCHAR2(2000);
	L_DEBUG_MODULE	CONSTANT	VARCHAR2(100)	:= 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

BEGIN
	-- Standard start of API savepoint
	SAVEPOINT Process_Mr_Route_Seq_SP;

	-- Standard call to check for call compatibility
	IF NOT FND_API.compatible_api_call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message, depending on p_init_msg_list flag
	IF FND_API.TO_BOOLEAN(p_init_msg_list) THEN
		FND_MSG_PUB.Initialize;
	END IF;

	-- Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- Log API entry point
	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			L_DEBUG_MODULE||'.begin',
			'At the start of PLSQL procedure'
		);
	END IF;

	-- API body starts here
	IF p_x_mr_route_seq_tbl.COUNT > 0
	THEN
		AHL_FMP_MR_ROUTE_SEQNCE_PVT.PROCESS_MR_ROUTE_SEQ
		(
			p_api_version          	=> 1.0,
			p_init_msg_list        	=> FND_API.G_FALSE,
			p_commit               	=> FND_API.G_FALSE,
			p_validation_level     	=> p_validation_level,
			p_default              	=> p_default,
			p_module_type          	=> p_module_type,
			x_return_status        	=> x_return_status,
			x_msg_count            	=> x_msg_count,
			x_msg_data             	=> x_msg_data,
			p_x_mr_route_seq_tbl	=> p_x_mr_route_seq_tbl
 		);

 		x_msg_count := FND_MSG_PUB.count_msg;
		IF x_msg_count > 0 OR x_return_status <> FND_API.G_RET_STS_SUCCESS
		THEN
			RAISE FND_API.G_EXC_ERROR;
		END IF;
	END IF;


	-- API body ends here

	-- Log API exit point
	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
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

	-- Commit, depending on p_commit flag
	IF FND_API.TO_BOOLEAN(p_commit) THEN
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
		Rollback to Process_Mr_Route_Seq_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to Process_Mr_Route_Seq_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to Process_Mr_Route_Seq_SP;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.add_exc_msg
			(
				p_pkg_name		=> G_PKG_NAME,
				p_procedure_name 	=> 'Process_Mr_Route_Seq',
				p_error_text     	=> SUBSTR(SQLERRM,1,240)
			);
		END IF;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

END Process_Mr_Route_Seq;

PROCEDURE Process_Mr_Effectivities
(
	-- standard IN params
	p_api_version			IN		NUMBER,
	p_init_msg_list			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_commit			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_validation_level		IN		NUMBER		:=FND_API.G_VALID_LEVEL_FULL,
	p_default			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_module_type			IN		VARCHAR2	:=NULL,
	-- standard OUT params
	x_return_status             	OUT NOCOPY  	VARCHAR2,
	x_msg_count                	OUT NOCOPY  	NUMBER,
	x_msg_data                  	OUT NOCOPY  	VARCHAR2,
	-- procedure params
	p_mr_header_id                 	IN  		NUMBER,
	p_mr_title			IN  		VARCHAR2,
	p_mr_version_number		IN  		NUMBER,
	p_super_user			IN		VARCHAR2	:='N',
	p_mr_effectivity_id            	IN  		NUMBER,
	p_mr_effectivity_name		IN  		VARCHAR2,
	p_x_mr_effectivity_detail_tbl  	IN OUT NOCOPY   AHL_FMP_EFFECTIVITY_DTL_PVT.effectivity_detail_tbl_type,
  p_x_effty_ext_detail_tbl       IN OUT NOCOPY  AHL_FMP_EFFECTIVITY_DTL_PVT.effty_ext_detail_tbl_type,
	p_x_mr_threshold_rec		IN OUT NOCOPY   AHL_FMP_MR_INTERVAL_PVT.threshold_rec_type,
	p_x_mr_interval_tbl		IN OUT NOCOPY   AHL_FMP_MR_INTERVAL_PVT.interval_tbl_type
)
IS
	-- 1.	Declare local variables
	l_api_name	CONSTANT	VARCHAR2(30)	:= 'Process_Mr_Effectivities';
	l_api_version	CONSTANT	NUMBER		:= 1.0;
	l_return_status			VARCHAR2(1);
	l_msg_count         		NUMBER;
	l_msg_data          		VARCHAR2(2000);
	L_DEBUG_MODULE	CONSTANT	VARCHAR2(100)	:= 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

	l_mr_header_id			NUMBER		:= p_mr_header_id;
	l_mr_effectivity_id		NUMBER		:= p_mr_effectivity_id;

BEGIN
	-- Standard start of API savepoint
	SAVEPOINT Process_Mr_Effectivities_SP;

	-- Standard call to check for call compatibility
	IF NOT FND_API.compatible_api_call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message, depending on p_init_msg_list flag
	IF FND_API.TO_BOOLEAN(p_init_msg_list) THEN
		FND_MSG_PUB.Initialize;
	END IF;

	-- Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- Log API entry point
	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			L_DEBUG_MODULE||'.begin',
			'At the start of PLSQL procedure'
		);
	END IF;

	-- API body starts here
	IF (l_mr_header_id IS NULL)
	THEN
		AHL_FMP_COMMON_PVT.mr_title_version_to_id
		(
			p_mr_title		=> p_mr_title,
			p_mr_version_number	=> p_mr_version_number,
			x_mr_header_id		=> l_mr_header_id,
			x_return_status		=> x_return_status
		);

		x_msg_count := FND_MSG_PUB.count_msg;
		IF x_msg_count > 0 OR x_return_status <> FND_API.G_RET_STS_SUCCESS
		THEN
			IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.string
				(
					fnd_log.level_error,
					L_DEBUG_MODULE||'.end',
					'AHL_FMP_COMMON_PVT.mr_title_version_to_id returned error'
				);
			END IF;
			RAISE FND_API.G_EXC_ERROR;
		END IF;
	END IF;

	IF (l_mr_effectivity_id IS NULL)
	THEN
		AHL_FMP_COMMON_PVT.Mr_Effectivity_Name_To_Id
		(
			p_mr_header_id		=> l_mr_header_id,
			p_mr_effectivity_name	=> p_mr_effectivity_name,
			x_mr_effectivity_id	=> l_mr_effectivity_id,
			x_return_status		=> x_return_status
		);

		x_msg_count := FND_MSG_PUB.count_msg;
		IF x_msg_count > 0 OR x_return_status <> FND_API.G_RET_STS_SUCCESS
		THEN
			IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.string
				(
					fnd_log.level_error,
					L_DEBUG_MODULE||'.end',
					'AHL_FMP_COMMON_PVT.Mr_Effectivity_Name_To_Id returned error'
				);
			END IF;
			RAISE FND_API.G_EXC_ERROR;
		END IF;
	END IF;

	IF p_x_mr_effectivity_detail_tbl.COUNT > 0 OR p_x_effty_ext_detail_tbl.COUNT > 0
	THEN
		AHL_FMP_EFFECTIVITY_DTL_PVT.process_effectivity_detail
		(
			p_api_version          		=> 1.0,
			p_init_msg_list        		=> FND_API.G_FALSE,
			p_commit               		=> FND_API.G_FALSE,
			p_validation_level     		=> p_validation_level,
			p_default              		=> p_default,
			p_module_type          		=> p_module_type,
			x_return_status        		=> x_return_status,
			x_msg_count            		=> x_msg_count,
			x_msg_data             		=> x_msg_data,
			p_x_effectivity_detail_tbl	=> p_x_mr_effectivity_detail_tbl,
      p_x_effty_ext_detail_tbl    => p_x_effty_ext_detail_tbl,
			p_mr_header_id			=> l_mr_header_id,
			p_mr_effectivity_id		=> l_mr_effectivity_id
		);

		x_msg_count := FND_MSG_PUB.count_msg;
		IF x_msg_count > 0 OR x_return_status <> FND_API.G_RET_STS_SUCCESS
		THEN
			RAISE FND_API.G_EXC_ERROR;
		END IF;
	END IF;

	IF (p_x_mr_interval_tbl.COUNT > 0 OR
    (p_x_mr_threshold_rec.threshold_date IS NOT NULL AND p_x_mr_threshold_rec.threshold_date <> FND_API.G_MISS_DATE) OR
    (p_x_mr_threshold_rec.program_duration IS NOT NULL AND p_x_mr_threshold_rec.program_duration <> FND_API.G_MISS_NUM ))
	THEN
        AHL_FMP_MR_INTERVAL_PVT.process_interval
        (
            p_api_version		=> 1.0,
            p_init_msg_list		=> FND_API.G_FALSE,
            p_commit		=> FND_API.G_FALSE,
            p_validation_level	=> p_validation_level,
            p_default		=> p_default,
            p_module_type		=> p_module_type,
            x_return_status		=> x_return_status,
            x_msg_count		=> x_msg_count,
            x_msg_data		=> x_msg_data,
            p_x_threshold_rec	=> p_x_mr_threshold_rec,
            p_x_interval_tbl	=> p_x_mr_interval_tbl,
            p_mr_header_id		=> l_mr_header_id,
            p_super_user		=> p_super_user
        );
    END IF;

	x_msg_count := FND_MSG_PUB.count_msg;
	IF x_msg_count > 0 OR x_return_status <> FND_API.G_RET_STS_SUCCESS
	THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	-- API body ends here

	-- Log API exit point
	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
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

	-- Commit, depending on p_commit flag
	IF FND_API.TO_BOOLEAN(p_commit) THEN
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
		Rollback to Process_Mr_Effectivities_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to Process_Mr_Effectivities_SP;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to Process_Mr_Effectivities_SP;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.add_exc_msg
			(
				p_pkg_name		=> G_PKG_NAME,
				p_procedure_name 	=> 'Process_Mr_Effectivities',
				p_error_text     	=> SUBSTR(SQLERRM,1,240)
			);
		END IF;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

END Process_Mr_Effectivities;

END AHL_FMP_MR_PUB;

/
