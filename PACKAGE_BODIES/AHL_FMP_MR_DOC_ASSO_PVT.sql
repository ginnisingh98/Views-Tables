--------------------------------------------------------
--  DDL for Package Body AHL_FMP_MR_DOC_ASSO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_FMP_MR_DOC_ASSO_PVT" AS
/* $Header: AHLVMRDB.pls 120.0.12010000.2 2010/01/11 07:16:51 snarkhed ship $ */

G_PKG_NAME    VARCHAR2(30):= 'AHL_FMP_MR_DOC_ASSO_PVT';
G_APPLN_USAGE           VARCHAR2(30):=RTRIM(LTRIM(FND_PROFILE.VALUE('AHL_APPLN_USAGE')));

 -- Populate doc table from RM table info.
PROCEDURE Populate_Doc_Tbl(
p_x_association_tbl	IN OUT NOCOPY	doc_association_tbl,
p_x_doc_assos_tbl	IN OUT NOCOPY 	AHL_DI_ASSO_DOC_GEN_PUB.association_tbl
)
IS

BEGIN

    IF p_x_association_tbl.count >0 THEN
      FOR i in p_x_association_tbl.FIRST .. p_x_association_tbl.LAST
      LOOP
	  p_x_doc_assos_tbl(i).DOC_TITLE_ASSO_ID	:= p_x_association_tbl(i).DOC_TITLE_ASSO_ID;
	  p_x_doc_assos_tbl(i).DOCUMENT_ID		:= p_x_association_tbl(i).DOCUMENT_ID;
	  p_x_doc_assos_tbl(i).DOCUMENT_NO		:= p_x_association_tbl(i).DOCUMENT_NO;
	  p_x_doc_assos_tbl(i).DOC_REVISION_ID		:= p_x_association_tbl(i).DOC_REVISION_ID;
	  p_x_doc_assos_tbl(i).REVISION_NO		:= p_x_association_tbl(i).REVISION_NO;
	  p_x_doc_assos_tbl(i).USE_LATEST_REV_FLAG	:= p_x_association_tbl(i).USE_LATEST_REV_FLAG;
	  p_x_doc_assos_tbl(i).ASO_OBJECT_TYPE_CODE	:= p_x_association_tbl(i).OBJECT_TYPE_CODE;
	  p_x_doc_assos_tbl(i).ASO_OBJECT_DESC		:= p_x_association_tbl(i).OBJECT_TYPE_DESC;
	  p_x_doc_assos_tbl(i).ASO_OBJECT_ID		:= p_x_association_tbl(i).MR_HEADER_ID;
	  p_x_doc_assos_tbl(i).SERIAL_NO		:= p_x_association_tbl(i).SERIAL_NO;
	  p_x_doc_assos_tbl(i).SOURCE_LANG		:= p_x_association_tbl(i).SOURCE_LANG;
	  p_x_doc_assos_tbl(i).CHAPTER			:= p_x_association_tbl(i).CHAPTER;
	  p_x_doc_assos_tbl(i).SECTION			:= p_x_association_tbl(i).SECTION;
	  p_x_doc_assos_tbl(i).SUBJECT			:= p_x_association_tbl(i).SUBJECT;
	  p_x_doc_assos_tbl(i).PAGE			:= p_x_association_tbl(i).PAGE;
	  p_x_doc_assos_tbl(i).FIGURE			:= p_x_association_tbl(i).FIGURE;
	  p_x_doc_assos_tbl(i).NOTE			:= p_x_association_tbl(i).NOTE;
	  p_x_doc_assos_tbl(i).SOURCE_REF_CODE		:= p_x_association_tbl(i).SOURCE_REF_CODE;
	  p_x_doc_assos_tbl(i).SOURCE_REF_MEAN		:= p_x_association_tbl(i).SOURCE_REF_MEAN;
	  p_x_doc_assos_tbl(i).OBJECT_VERSION_NUMBER	:= p_x_association_tbl(i).OBJECT_VERSION_NUMBER;
	  p_x_doc_assos_tbl(i).ATTRIBUTE_CATEGORY	:= p_x_association_tbl(i).ATTRIBUTE_CATEGORY;
	  p_x_doc_assos_tbl(i).ATTRIBUTE1		:= p_x_association_tbl(i).ATTRIBUTE1;
	  p_x_doc_assos_tbl(i).ATTRIBUTE2		:= p_x_association_tbl(i).ATTRIBUTE2;
	  p_x_doc_assos_tbl(i).ATTRIBUTE3		:= p_x_association_tbl(i).ATTRIBUTE3;
	  p_x_doc_assos_tbl(i).ATTRIBUTE4		:= p_x_association_tbl(i).ATTRIBUTE4;
	  p_x_doc_assos_tbl(i).ATTRIBUTE5		:= p_x_association_tbl(i).ATTRIBUTE5;
	  p_x_doc_assos_tbl(i).ATTRIBUTE6		:= p_x_association_tbl(i).ATTRIBUTE6;
	  p_x_doc_assos_tbl(i).ATTRIBUTE7		:= p_x_association_tbl(i).ATTRIBUTE7;
	  p_x_doc_assos_tbl(i).ATTRIBUTE8		:= p_x_association_tbl(i).ATTRIBUTE8;
	  p_x_doc_assos_tbl(i).ATTRIBUTE9		:= p_x_association_tbl(i).ATTRIBUTE9;
	  p_x_doc_assos_tbl(i).ATTRIBUTE10		:= p_x_association_tbl(i).ATTRIBUTE10;
	  p_x_doc_assos_tbl(i).ATTRIBUTE11		:= p_x_association_tbl(i).ATTRIBUTE11;
	  p_x_doc_assos_tbl(i).ATTRIBUTE12		:= p_x_association_tbl(i).ATTRIBUTE12;
	  p_x_doc_assos_tbl(i).ATTRIBUTE13		:= p_x_association_tbl(i).ATTRIBUTE13;
	  p_x_doc_assos_tbl(i).ATTRIBUTE14		:= p_x_association_tbl(i).ATTRIBUTE14;
	  p_x_doc_assos_tbl(i).ATTRIBUTE15		:= p_x_association_tbl(i).ATTRIBUTE15;
	  p_x_doc_assos_tbl(i).DML_OPERATION		:= p_x_association_tbl(i).DML_OPERATION;
      END LOOP;
   END IF;

END Populate_Doc_Tbl;


PROCEDURE Process_Doc_Association
(
 p_api_version                  IN  		NUMBER    := 1.0,
 p_init_msg_list                IN  		VARCHAR2  := FND_API.G_TRUE,
 p_commit                       IN  		VARCHAR2  := FND_API.G_FALSE,
 p_validation_level             IN  		NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_validate_only            	IN  		VARCHAR2  := FND_API.G_TRUE,
 p_default                      IN  		VARCHAR2  := FND_API.G_FALSE,
 p_module_type                  IN  		VARCHAR2,
 x_return_status                OUT 		NOCOPY VARCHAR2,
 x_msg_count                    OUT 		NOCOPY NUMBER,
 x_msg_data                     OUT 		NOCOPY VARCHAR2,
 p_x_association_tbl            IN  OUT NOCOPY  doc_association_tbl
 )
IS

l_api_name                  VARCHAR2(30)   := 'PROCESS_DOC_ASSOCIATION';
l_api_version               NUMBER         := 1.0;
l_x_doc_assos_tbl           AHL_DI_ASSO_DOC_GEN_PUB.association_tbl;

-- FP #8410484
CURSOR mr_details_csr_type(p_mr_header_id  NUMBER)
IS
SELECT mr_status_code,type_code
From AHL_MR_HEADERS_APP_V
Where mr_header_id=p_mr_header_id
And mr_status_code IN('DRAFT','APPROVAL_REJECTED','COMPLETE');

l_mr_rec               mr_details_csr_type%rowtype;

BEGIN
        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
			'At the start of PLSQL procedure'
		);
        END IF;

	--  Initialize API return status to success
	x_return_status:=FND_API.G_RET_STS_SUCCESS ;

	-- Standard Start of API savepoint
	SAVEPOINT process_association_pvt;

	-- Standard call to check for call compatibility.
	IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
				       p_api_version,
				       l_api_name,G_PKG_NAME)
	THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_boolean(p_init_msg_list)
	THEN
		FND_MSG_PUB.initialize;
	END IF;

	--Check application usage code is not null
	IF g_appln_usage is null
	THEN
		FND_MESSAGE.SET_NAME('AHL','AHL_COM_APP_PRFL_UNDEF');
		FND_MSG_PUB.ADD;
		IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		 fnd_log.string
		 (
		     fnd_log.level_error,
		    'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
		     'Error -- Application usage code is null'
		 );
		END IF;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
	         fnd_log.string
	         (
		     fnd_log.level_statement,
	            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
		     'Before doing value to id conversion.....'
	         );
        END IF;

	IF p_x_association_tbl.count >0 THEN
	    FOR i in p_x_association_tbl.FIRST .. p_x_association_tbl.LAST
	    LOOP
		 -- Convert(if required) and validate the object_type lookup
		 AHL_RM_ROUTE_UTIL.validate_lookup(
			x_return_status 	=>	x_return_status,
			x_msg_data		=>	x_msg_data,
			p_lookup_type		=>	'AHL_OBJECT_TYPE',
			p_lookup_meaning	=>	p_x_association_tbl(i).object_type_desc,
			p_x_lookup_code		=>	p_x_association_tbl(i).object_type_code
		   );
		  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
		     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
			 fnd_log.string
			 (
			     fnd_log.level_statement,
			    'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			     'Error -- Invalid lookup specified'
			 );
		     END IF;
		     RAISE FND_API.G_EXC_ERROR;
		  END IF;

		IF p_x_association_tbl(i).mr_header_id IS NULL THEN
		    -- Function to convert mr_title,mr_version_number to id
		    AHL_FMP_COMMON_PVT.mr_title_version_to_id(
			    p_mr_title		=>	p_x_association_tbl(i).mr_title,
			    p_mr_version_number	=>	p_x_association_tbl(i).mr_version_number,
			    x_mr_header_id	=>	p_x_association_tbl(i).mr_header_id,
			    x_return_status	=>	x_return_status
			    );
		    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
		       IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
			 fnd_log.string
			 (
			     fnd_log.level_error,
			    'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			     'Invalid MR Title, Version Number provided'
			 );
		      END IF;
		      RAISE FND_API.G_EXC_ERROR;
		   END IF;
		END IF;

		--App usage code related code
		IF p_x_association_tbl(i).mr_header_id IS NOT NULL OR
		   p_x_association_tbl(i).mr_header_id <> FND_API.G_MISS_NUM
		THEN
			OPEN mr_details_csr_type(p_x_association_tbl(i).mr_header_id);

			FETCH mr_details_csr_type  into l_mr_rec;

			IF mr_details_csr_type%NOTFOUND
			THEN
				FND_MESSAGE.SET_NAME('AHL','AHL_DI_ASSO_UPDATE_ERROR');
				FND_MSG_PUB.ADD;
				IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
				 fnd_log.string
				 (
				     fnd_log.level_error,
				    'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
				     'Invalid MR Info..'
				 );
				END IF;
				RAISE FND_API.G_EXC_ERROR;
			ELSE
			     -- Preventive Maintenance Code
			     IF G_APPLN_USAGE='PM'
			     THEN
				     IF l_mr_rec.type_code='PROGRAM'
				     THEN
						FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_TYPE_CODE_PROGRAM');
						FND_MSG_PUB.ADD;
						IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
						 fnd_log.string
						 (
						     fnd_log.level_error,
						    'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
						     'Application usage code PM is invalid for MR with program type'||
						     l_mr_rec.type_code
						 );
						END IF;
						RAISE FND_API.G_EXC_ERROR;
				     END IF;
			     END IF;
			END IF;
			CLOSE mr_details_csr_type;
		END IF;

	   END LOOP;
	END IF;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
	         fnd_log.string
	         (
		     fnd_log.level_statement,
	            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
		     'Before copying mr table of records into doc table of records'
	         );
        END IF;

	-- Populate doc table from RM table info. procedure added in 11.5.10
	populate_doc_tbl(
	p_x_association_tbl	=> p_x_association_tbl,
	p_x_doc_assos_tbl	=> l_x_doc_assos_tbl
	);

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
	         fnd_log.string
	         (
		     fnd_log.level_statement,
	            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
		     'Before calling AHL_DI_ASSO_DOC_GEN_PUB.PROCESS_ASSOCIATION..'
	         );
        END IF;

	-- Call DI Public API for doc association.

	AHL_DI_ASSO_DOC_GEN_PUB.PROCESS_ASSOCIATION
	(
	 p_api_version               => p_api_version ,
	 p_init_msg_list             => p_init_msg_list ,
	 p_commit                    => FND_API.G_FALSE ,
	 p_validation_level          => p_validation_level ,
	 p_validate_only             => p_validate_only ,
	 p_module_type               => p_module_type ,
	 x_return_status             => x_return_status ,
	 x_msg_count                 => x_msg_count ,
	 x_msg_data                  => x_msg_data ,
	 p_x_association_tbl         => l_x_doc_assos_tbl
	) ;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
	         fnd_log.string
	         (
		     fnd_log.level_statement,
	            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
		     'After calling AHL_DI_ASSO_DOC_GEN_PUB.PROCESS_ASSOCIATION'
    	         );
        END IF;

	-- If any severe error occurs, then, abort API.
	IF x_return_status = FND_API.G_RET_STS_ERROR THEN
		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		 fnd_log.string
		 (
		     fnd_log.level_statement,
		    'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
		     'Invalid MR Title, Version Number provided'
		 );
		END IF;
	    	RAISE FND_API.G_EXC_ERROR;
	ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		 fnd_log.string
		 (
		     fnd_log.level_statement,
		    'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
		     'Invalid MR Title, Version Number provided'
		 );
		END IF;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Standard check for p_commit
	IF FND_API.To_Boolean (p_commit)
	THEN
		COMMIT;
	END IF;

	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.end',
			'At the end of PLSQL procedure'
		);
  	END IF;

  EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		Rollback to process_association_pvt;
		FND_MSG_PUB.count_and_get( p_count => x_msg_count,
					p_data  => x_msg_data,
					p_encoded => fnd_api.g_false);
		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		 fnd_log.string
		 (
		     fnd_log.level_statement,
		    'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
		     'FND_API.G_EXC_ERROR!!'
		 );
		END IF;


	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to process_association_pvt;
		FND_MSG_PUB.count_and_get( p_count => x_msg_count,
					p_data  => x_msg_data,
					 p_encoded => fnd_api.g_false);
		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		 fnd_log.string
		 (
		     fnd_log.level_statement,
		    'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
		     'FND_API.G_EXC_UNEXPECTED_ERROR!!'
		 );
		END IF;

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		Rollback to process_association_pvt;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
		 fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
					 p_procedure_name => 'Process_Doc_Association',
					 p_error_text     => SQLERRM);
		END IF;
		FND_MSG_PUB.count_and_get( p_count => x_msg_count,
					 p_data  => x_msg_data,
					  p_encoded => fnd_api.g_false);
		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		 fnd_log.string
		 (
		     fnd_log.level_statement,
		    'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
		     'Un expected error(other errors)!!'
		 );
		END IF;

END Process_Doc_Association;

END AHL_FMP_MR_DOC_ASSO_PVT;


/
