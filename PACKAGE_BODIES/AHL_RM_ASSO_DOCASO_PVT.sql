--------------------------------------------------------
--  DDL for Package Body AHL_RM_ASSO_DOCASO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_RM_ASSO_DOCASO_PVT" AS
/* $Header: AHLVRODB.pls 120.0.12010000.2 2010/01/11 07:11:53 snarkhed ship $ */

G_PKG_NAME    VARCHAR2(30):= 'AHL_RM_ASSO_DOCASO_PVT';
G_DEBUG  VARCHAR2(1)   := NVL(AHL_DEBUG_PUB.is_log_enabled,'N');

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
	  p_x_doc_assos_tbl(i).ASO_OBJECT_ID		:= p_x_association_tbl(i).OBJECT_ID;
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


PROCEDURE PROCESS_ASSOCIATION
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

cursor get_route_status (p_route_id in number)
is
select revision_status_code
from ahl_routes_app_v
where route_id = p_route_id;

l_obj_status 			VARCHAR2(30);

cursor get_oper_status (p_operation_id in number)
is
select revision_status_code
from ahl_operations_b
where operation_id = p_operation_id;

l_api_name                  VARCHAR2(30)   := 'process_association';
l_api_version               NUMBER         := 1.0;
l_return_status             VARCHAR2(1);
l_msg_count                 NUMBER	       := NULL;
l_msg_data			VARCHAR2(2000);
l_x_operation_rec           AHL_RM_OPERATION_PVT.operation_rec_type ;
l_x_route_rec               AHL_RM_ROUTE_PVT.route_rec_type ;
l_x_doc_assos_tbl           AHL_DI_ASSO_DOC_GEN_PUB.association_tbl;
l_object_status		   VARCHAR2(30)		:=NULL;
BEGIN


	-- Standard call to check for call compatibility.
	IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
				       p_api_version,
				       l_api_name,G_PKG_NAME)
	THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Standard Start of API savepoint
	SAVEPOINT process_association;

	-- Check if API is called in debug mode. If yes, enable debug.

	IF G_DEBUG='Y' THEN
	AHL_DEBUG_PUB.enable_debug;
	END IF;

	-- Debug info.

	IF G_DEBUG='Y' THEN
	AHL_DEBUG_PUB.debug( 'enter ahl_rm_asso_doc_aso_pub.Process Association');
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_boolean(p_init_msg_list)
	THEN
		FND_MSG_PUB.initialize;
	END IF;

	--  Initialize API return status to success

	x_return_status:=FND_API.G_RET_STS_SUCCESS ;

        IF p_x_association_tbl.count >0 THEN
         FOR i in p_x_association_tbl.FIRST .. p_x_association_tbl.LAST
         LOOP
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

	  -- If Id is null derive object id from object Number and revision
	  -- This will fail if no record are passed to this API or if records with different association types are passed. This needs to be fixed sooner or later. - Balaji
	  IF p_x_association_tbl(i).object_id IS NULL THEN
		IF p_x_association_tbl(i).object_type_code = 'ROUTE' THEN
		  -- Function to convert Operation number, operation revision to id
		  AHL_RM_ROUTE_UTIL.Route_Number_To_Id
		  (
		   p_route_number		=>	p_x_association_tbl(i).object_number,
		   p_route_revision		=>	p_x_association_tbl(i).object_revision,
		   x_route_id			=>	p_x_association_tbl(i).object_id,
		   x_return_status		=>	x_return_status
		  );
		ELSIF p_x_association_tbl(i).object_type_code = 'OPERATION' THEN
		  -- Function to convert Operation number, operation revision to id
		  AHL_RM_ROUTE_UTIL.Operation_Number_To_Id
		  (
		   p_operation_number		=>	p_x_association_tbl(i).object_number,
		   p_operation_revision		=>	p_x_association_tbl(i).object_revision,
		   x_operation_id		=>	p_x_association_tbl(i).object_id,
		   x_return_status		=>	x_return_status
		  );
		END IF;
		IF x_return_status = FND_API.G_RET_STS_ERROR THEN
		     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
			 fnd_log.string
			 (
			     fnd_log.level_statement,
			    'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			     'Error in converting Object Number, Object Revision to ID'
			 );
		     END IF;
		     RAISE FND_API.G_EXC_ERROR;
		END IF;
	   END IF;
	  END LOOP;
	END IF;

	--l_x_association_tbl  := p_x_association_tbl  ;

	--This is to be added before calling   AHL_DI_ASSO_DOC_GEN_PUB.PROCESS_ASSOCIATION ()
	-- Validate Application Usage
	IF (p_x_association_tbl(1).object_type_code = 'ROUTE')
	THEN
	  AHL_RM_ROUTE_UTIL.validate_ApplnUsage
	  (
	     p_object_id              => p_x_association_tbl(1).OBJECT_ID,
	     p_association_type       => p_x_association_tbl(1).OBJECT_TYPE_CODE,
	     x_return_status          => x_return_status,
	     x_msg_data               => x_msg_data
	  );

	-- If any severe error occurs, then, abort API.
	  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
	    RAISE FND_API.G_EXC_ERROR;
	  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	  END IF;
	END IF;

	-- Populate doc table from RM table info. procedure added in 11.5.10
	populate_doc_tbl(
	p_x_association_tbl	=> p_x_association_tbl,
	p_x_doc_assos_tbl	=> l_x_doc_assos_tbl
	);


	 AHL_DEBUG_PUB.debug( 'before call on AHL_DI_ASSO_DOC_GEN_PUB.PROCESS_ASSOCIATION');

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

	l_msg_count := FND_MSG_PUB.count_msg;

	IF l_msg_count > 0 THEN
	   X_msg_count := l_msg_count;
	   X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	   RAISE FND_API.G_EXC_ERROR;
	END IF;

	-- call is success so copy the DOC_TITLE_ASSO_ID and Object_version_number back into RM record structure. Balaji added in 11510+ as a part of code cleanup.
	FOR i IN l_x_doc_assos_tbl.FIRST..l_x_doc_assos_tbl.LAST
	LOOP
		p_x_association_tbl(i).DOC_TITLE_ASSO_ID := l_x_doc_assos_tbl(i).DOC_TITLE_ASSO_ID;
		p_x_association_tbl(i).OBJECT_VERSION_NUMBER := l_x_doc_assos_tbl(i).OBJECT_VERSION_NUMBER;
	END LOOP;

	IF G_DEBUG='Y' THEN
	    AHL_DEBUG_PUB.debug( 'AHL_DI_ASSO_DOC_GEN_PUB.PROCESS_ASSOCIATION is called');
	    AHL_DEBUG_PUB.debug( 'PRITHWI the aso object type code is '||  p_x_association_tbl(1).object_type_code );
	END IF;

	IF ( p_x_association_tbl(1).object_type_code = 'OPERATION')
	THEN
		  IF G_DEBUG='Y' THEN
			AHL_DEBUG_PUB.debug( 'aso_object_type_code = OPERATION');
		  END IF;

		-- Check if the Route is existing and in Draft status
		--FP #8410484
		--AHL_RM_ROUTE_UTIL.validate_operation_status
		--(
			--p_x_association_tbl(1).OBJECT_ID,
			--l_msg_data,
			--l_return_status
		--);

		OPEN get_oper_status( p_x_association_tbl(1).OBJECT_ID);
		FETCH get_oper_status INTO l_object_status;
		IF get_oper_status%NOTFOUND THEN
			l_return_status := FND_API.G_RET_STS_ERROR;
			l_msg_data := 'AHL_RM_INVALID_OPERATION';
		END IF;
		IF ( l_object_status <> 'DRAFT' AND
			l_object_status <> 'APPROVAL_REJECTED' AND
			l_object_status <> 'COMPLETE') THEN
			l_return_status := FND_API.G_RET_STS_ERROR;
			l_msg_data := 'AHL_RM_INVALID_OPER_STATUS';
		END IF;
		CLOSE get_oper_status;
		-- End of FP #8410484
		IF l_return_status = FND_API.G_RET_STS_ERROR THEN
			FND_MESSAGE.SET_NAME('AHL',l_msg_data);
			FND_MSG_PUB.ADD;
			x_return_status := l_return_status;
			RETURN;
		END IF;

		-- Update route status from APPROVAL_REJECTED to DRAFT
		OPEN get_oper_status (p_x_association_tbl(1).OBJECT_ID);
		FETCH get_oper_status INTO l_obj_status;
		IF (get_oper_status%FOUND AND l_obj_status = 'APPROVAL_REJECTED')
		THEN
			UPDATE ahl_operations_b
			SET revision_status_code = 'DRAFT'
			WHERE operation_id = p_x_association_tbl(1).OBJECT_ID;
		END IF;
		CLOSE get_oper_status;


	ELSIF ( p_x_association_tbl(1).object_type_code = 'ROUTE')
	THEN
		IF G_DEBUG='Y' THEN
			AHL_DEBUG_PUB.debug( 'aso_object_type_code = ROUTE');
		END IF;

		-- Check if the Route is existing and in Draft status
		-- FP #8410484
		--AHL_RM_ROUTE_UTIL.validate_route_status
		--(
			--p_x_association_tbl(1).OBJECT_ID,
			--l_msg_data,
			--l_return_status
		--);
		OPEN get_route_status( p_x_association_tbl(1).OBJECT_ID);
		FETCH get_route_status INTO l_object_status;
		IF get_route_status%NOTFOUND THEN
			l_return_status := FND_API.G_RET_STS_ERROR;
			l_msg_data := 'AHL_RM_INVALID_ROUTE';
		END IF;
		IF ( l_object_status <> 'DRAFT' AND
			l_object_status <> 'APPROVAL_REJECTED' AND
			l_object_status <> 'COMPLETE') THEN
			l_return_status := FND_API.G_RET_STS_ERROR;
			l_msg_data := 'AHL_RM_INVALID_ROUTE_STATUS';
		END IF;
		CLOSE get_route_status;
		--End of FP #8410484
		IF l_return_status = FND_API.G_RET_STS_ERROR THEN
			FND_MESSAGE.SET_NAME('AHL',l_msg_data);
			FND_MSG_PUB.ADD;
			x_return_status := l_return_status;
			RETURN;
		END IF;

		-- Update route status from APPROVAL_REJECTED to DRAFT
  		OPEN get_route_status (p_x_association_tbl(1).OBJECT_ID);
		FETCH get_route_status INTO l_obj_status;
		IF (get_route_status%FOUND AND l_obj_status = 'APPROVAL_REJECTED')
		THEN
			UPDATE ahl_routes_b
			SET revision_status_code = 'DRAFT'
			WHERE route_id = p_x_association_tbl(1).OBJECT_ID;
		END IF;
		CLOSE get_route_status;

	END IF ;
	l_msg_count := FND_MSG_PUB.count_msg;

	IF l_msg_count > 0 THEN
	   X_msg_count := l_msg_count;
	   X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	   RAISE FND_API.G_EXC_ERROR;
	END IF;

	 IF FND_API.TO_BOOLEAN(p_commit) THEN
	    COMMIT;
	 END IF;

	-- Check if API is called in debug mode. If yes, disable debug.

	IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.disable_debug;
	END IF;

	EXCEPTION
	 WHEN FND_API.G_EXC_ERROR THEN
	    ROLLBACK TO process_association;
	    x_return_status := FND_API.G_RET_STS_ERROR;
	    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
				       p_count => x_msg_count,
				       p_data  => X_msg_data);
		-- Debug info.
		IF G_DEBUG='Y' THEN
			  AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
			  AHL_DEBUG_PUB.debug( 'ahl_rm_asso_doc_aso_pub.Process Association');
			  AHL_DEBUG_PUB.disable_debug;
		END IF;

	 WHEN OTHERS THEN
	    ROLLBACK TO process_association;
	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	    THEN
	    fnd_msg_pub.add_exc_msg(p_pkg_name        =>G_PKG_NAME ,
				    p_procedure_name  => 'PROCESS_ASSOCIATION',
				    p_error_text      => SUBSTR(SQLERRM,1,240));
	    END IF;
	    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
				       p_count => x_msg_count,
				       p_data  => X_msg_data);



END process_association;

END AHL_RM_ASSO_DOCASO_PVT;

/
