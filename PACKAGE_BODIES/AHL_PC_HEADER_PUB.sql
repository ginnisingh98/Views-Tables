--------------------------------------------------------
--  DDL for Package Body AHL_PC_HEADER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PC_HEADER_PUB" AS
/* $Header: AHLPPCHB.pls 115.12 2003/10/20 19:36:19 sikumar noship $ */

	---------------------------
	-- VALIDATE_FND_LOOKUPS  --
	---------------------------
--G_DEBUG VARCHAR2(1):=FND_PROFILE.VALUE('AHL_API_FILE_DEBUG_ON');
  G_DEBUG                VARCHAR2(1)   := AHL_DEBUG_PUB.is_log_enabled;

	PROCEDURE VALIDATE_FND_LOOKUPS
	(
       		p_lookup_meaning  IN OUT NOCOPY VARCHAR2,
       		p_lookup_code     IN OUT NOCOPY VARCHAR2,
       		p_lookup_type     IN     VARCHAR2,
       		p_error_exists    IN     VARCHAR2,
       		p_error_reqd      IN     VARCHAR2
      	)
	IS
		cursor check_fnd_lookup
		(
			p_lookup_type IN VARCHAR2,
			p_lookup_meaning IN VARCHAR2 :=NULL,
			p_lookup_code IN VARCHAR2 :=NULL
		)
		is
			SELECT LOOKUP_CODE , MEANING
			FROM  FND_LOOKUP_VALUES_VL
			WHERE LOOKUP_TYPE = p_lookup_type
			AND MEANING LIKE NVL(p_lookup_meaning,'%')
			AND LOOKUP_CODE LIKE NVL(p_lookup_code,'%');

		l_lookup_code        varchar2(30);
		l_lookup_meaning     varchar2(80);

	BEGIN
		IF TRIM(p_lookup_meaning) IS NULL AND TRIM(p_lookup_code) IS NULL
		THEN
			FND_MESSAGE.Set_Name('AHL',p_error_reqd);
			FND_MSG_PUB.ADD;
		ELSE
			OPEN check_fnd_lookup(p_lookup_type ,p_lookup_meaning, p_lookup_code);
			FETCH check_fnd_lookup into p_lookup_code,p_lookup_meaning;
			IF check_fnd_lookup%NOTFOUND
			THEN
				FND_MESSAGE.Set_Name('AHL',p_error_exists);
				FND_MSG_PUB.ADD;
				CLOSE check_fnd_lookup;
			END IF;
		END IF;

	END VALIDATE_FND_LOOKUPS;

	----------------------
	-- VALIDATE_HEADER  --
	----------------------
	PROCEDURE VALIDATE_HEADER ( p_x_pc_header_rec IN OUT NOCOPY AHL_PC_HEADER_PUB.PC_HEADER_REC )
	IS

	BEGIN
		IF (p_x_pc_header_rec.OPERATION_FLAG <> AHL_PC_HEADER_PVT.G_DML_DELETE)
		THEN
			p_x_pc_header_rec.NAME := TRIM(p_x_pc_header_rec.NAME);
			p_x_pc_header_rec.DESCRIPTION := TRIM(p_x_pc_header_rec.DESCRIPTION);

			-- PC name is mandatory
			IF TRIM(p_x_pc_header_rec.NAME) IS NULL
			THEN
				FND_MESSAGE.Set_Name('AHL','AHL_PC_NAME_REQD');
				FND_MSG_PUB.ADD;
			END IF;

			VALIDATE_FND_LOOKUPS
			(
				p_x_pc_header_rec.STATUS_DESC,
				p_x_pc_header_rec.STATUS,
				'AHL_PC_STATUS',
				'AHL_PC_STATUS_NOT_FOUND',
				'AHL_PC_STATUS_REQD'
			);

			-- FND check for PRIMARY_FLAG
			VALIDATE_FND_LOOKUPS
			(
				p_x_pc_header_rec.PRIMARY_FLAG_DESC,
				p_x_pc_header_rec.PRIMARY_FLAG,
				'YES_NO',
				'AHL_PC_PRIMARY_FLAG_NOT_FOUND',
				'AHL_PC_PRIMARY_FLAG_REQD'
			);

			-- FND check for ASSOCIATION_TYPE
			VALIDATE_FND_LOOKUPS
			(
				p_x_pc_header_rec.ASSOCIATION_TYPE_DESC,
				p_x_pc_header_rec.ASSOCIATION_TYPE_FLAG,
				'AHL_PC_ASSOS_TYPE',
				'AHL_PC_ASSOCIATION_TYPE_NOT_FOUND',
				'AHL_PC_ASSOCIATION_TYPE_REQD'
			);
		END IF;

		IF (p_x_pc_header_rec.OPERATION_FLAG <> AHL_PC_HEADER_PVT.G_DML_CREATE)
		THEN
			IF TRIM(p_x_pc_header_rec.PC_HEADER_ID) IS NULL
			THEN
				FND_MESSAGE.Set_Name('AHL','AHL_PC_HEADER_ID_REQCD');
				FND_MSG_PUB.ADD;
			END IF;
               	END IF;

	END VALIDATE_HEADER;

	-------------------------------------
	-- CONVERT_ITEM_TYPE_DESC_TO_CODE  --
	-------------------------------------
	PROCEDURE CONVERT_ITEM_TYPE_DESC_TO_CODE ( p_x_pc_header_rec IN OUT NOCOPY AHL_PC_HEADER_PUB.PC_HEADER_REC )
	IS

	CURSOR get_item_type_code (p_pc_item_type_desc IN VARCHAR2)
	IS
		select lookup_code, meaning
		from fnd_lookup_values_vl
		where lookup_type = 'ITEM_TYPE' and
		      upper(meaning) = upper(p_pc_item_type_desc) and
		      view_application_id = 3 and
		      enabled_flag = 'Y' and
		      sysdate between nvl(start_date_active, sysdate) and nvl(end_date_active, sysdate);

	CURSOR check_item_type_desc_and_code (p_pc_item_type_code IN VARCHAR2, p_pc_item_type_desc IN VARCHAR2)
	IS
		select lookup_code, meaning
		from fnd_lookup_values_vl
		where lookup_type = 'ITEM_TYPE' and
		      upper(meaning) = upper(p_pc_item_type_desc) and
		      lookup_code = p_pc_item_type_code and
		      view_application_id = 3 and
		      enabled_flag = 'Y' and
		      sysdate between nvl(start_date_active, sysdate) and nvl(end_date_active, sysdate);

	l_item_type_code		VARCHAR2(30);
	l_dummy_code			VARCHAR2(30);
	l_item_type_desc		VARCHAR2(80);
	l_dummy_desc			VARCHAR2(80);

	BEGIN

		-- Item Type Desc is not passed from frontend, then ERROR
		IF (p_x_pc_header_rec.PRODUCT_TYPE_DESC) IS NULL
		THEN
			FND_MESSAGE.SET_NAME('AHL','AHL_PC_PRODUCT_TYPE_REQD');
			FND_MSG_PUB.ADD;
			RAISE FND_API.G_EXC_ERROR;
		ELSE
			OPEN get_item_type_code (p_x_pc_header_rec.PRODUCT_TYPE_DESC);
			FETCH get_item_type_code INTO l_item_type_code, l_item_type_desc;
			-- No such Item Type found for passed Item Type Desc, then ERROR
			IF (get_item_type_code%NOTFOUND)
			THEN
				FND_MESSAGE.SET_NAME('AHL','AHL_PC_PRODUCT_TYPE_NOT_FOUND');
				FND_MSG_PUB.ADD;
				CLOSE get_item_type_code;
				RAISE FND_API.G_EXC_ERROR;
			ELSE
				FETCH get_item_type_code INTO l_dummy_code, l_dummy_desc;
				-- Multiple matches for Item Type Desc
				IF get_item_type_code%FOUND
				THEN
					-- Check if user had navigated to LOV and later changed the desc to something else that also has multiple matches
					OPEN check_item_type_desc_and_code (p_x_pc_header_rec.PRODUCT_TYPE_CODE, p_x_pc_header_rec.PRODUCT_TYPE_DESC);
					FETCH check_item_type_desc_and_code INTO l_dummy_code, l_dummy_desc;
					IF (check_item_type_desc_and_code%NOTFOUND)
					THEN
						FND_MESSAGE.SET_NAME('AHL','AHL_PC_DUP_PROD_CODE_FOR_DESC');
						FND_MSG_PUB.ADD;
						CLOSE check_item_type_desc_and_code;
						CLOSE get_item_type_code;
						RAISE FND_API.G_EXC_ERROR;
					ELSE
					        IF ( p_x_pc_header_rec.PRODUCT_TYPE_CODE) IS NULL
						THEN
							FND_MESSAGE.SET_NAME('AHL','AHL_PC_DUP_PROD_CODE_FOR_DESC');
							FND_MSG_PUB.ADD;
							CLOSE check_item_type_desc_and_code;
							CLOSE get_item_type_code;
							RAISE FND_API.G_EXC_ERROR;
						END IF;
					END IF;
				ELSE
				     	p_x_pc_header_rec.PRODUCT_TYPE_CODE := l_item_type_code;
				     	CLOSE get_item_type_code;
				END IF;
			END IF;
		END IF;

	END CONVERT_ITEM_TYPE_DESC_TO_CODE;

	-------------------------
	-- PROCESS_PC_HEADER  --
	-------------------------
	PROCEDURE PROCESS_PC_HEADER (
		p_api_version         IN            NUMBER,
		p_init_msg_list       IN            VARCHAR2  := FND_API.G_FALSE,
		p_commit              IN            VARCHAR2  := FND_API.G_FALSE,
		p_validation_level    IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
		p_module_type         IN            VARCHAR2  := NULL,
    		p_x_pc_header_rec     IN OUT NOCOPY AHL_PC_HEADER_PUB.PC_HEADER_REC,
		x_return_status       OUT    NOCOPY           VARCHAR2,
		x_msg_count           OUT    NOCOPY       NUMBER,
		x_msg_data            OUT    NOCOPY       VARCHAR2
	) IS

	l_api_name			CONSTANT	VARCHAR2(30)	:= 'PROCESS_PC_HEADER';
	l_api_version			CONSTANT	NUMBER		:= 1.0;
	l_return_status			VARCHAR2(1);

	l_debug VARCHAR2(2000);

	BEGIN
		-- Standard start of API savepoint
  		SAVEPOINT PROCESS_PC_HEADER_PUB;

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

		x_return_status := FND_API.G_RET_STS_SUCCESS;

		IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.ENABLE_DEBUG;
              	END IF;

		-- If module type is JSP (or undefined), and it is not Delete PC operation
		-- Then item_type_desc should be converted to item_type_code
		-- Also nullify status_desc, association_type_desc, primary_flag_desc -- no scenario where these values will change through some user-action
		IF ( p_module_type = 'JSP' OR p_module_type IS NULL ) AND
		   ( p_x_pc_header_rec.operation_flag <> AHL_PC_HEADER_PVT.G_DML_DELETE )
		THEN
			CONVERT_ITEM_TYPE_DESC_TO_CODE (p_x_pc_header_rec);
			IF G_DEBUG='Y' THEN
		  	   AHL_DEBUG_PUB.debug('PCH -- PUB -- Item_Code='||p_x_pc_header_rec.PRODUCT_TYPE_CODE);
              		END IF;

			p_x_pc_header_rec.STATUS_DESC := NULL;
			p_x_pc_header_rec.ASSOCIATION_TYPE_DESC := NULL;
			p_x_pc_header_rec.PRIMARY_FLAG_DESC := NULL;
		END IF;

		VALIDATE_HEADER (p_x_pc_header_rec);

		-- Check Error Message stack.
		x_msg_count := FND_MSG_PUB.count_msg;
		IF x_msg_count > 0
		THEN
			RAISE  FND_API.G_EXC_ERROR;
		END IF;

		-- Call PVT APIs
		x_return_status := FND_API.G_RET_STS_SUCCESS;

		IF (p_x_pc_header_rec.operation_flag = AHL_PC_HEADER_PVT.G_DML_CREATE)
		THEN
			IF G_DEBUG='Y' THEN
		  	 	AHL_DEBUG_PUB.debug('PCH -- PUB -- Calling CREATE_PC_HEADER for Name='||p_x_pc_header_rec.NAME);
              		END IF;

			AHL_PC_HEADER_PVT.CREATE_PC_HEADER
			(
				p_api_version           => 1.0,
				p_init_msg_list         => FND_API.G_FALSE,
				p_commit                => FND_API.G_FALSE,
				p_validation_level      => p_validation_level,
				p_x_pc_header_rec	=> p_x_pc_header_rec,
				x_return_status         => x_return_status,
				x_msg_count             => x_msg_count,
				x_msg_data              => x_msg_data
			);
		ELSIF (p_x_pc_header_rec.operation_flag = AHL_PC_HEADER_PVT.G_DML_UPDATE)
		THEN
			IF G_DEBUG='Y' THEN
		  		AHL_DEBUG_PUB.debug('PCH -- PUB -- Calling UPDATE_PC_HEADER for ID='||p_x_pc_header_rec.PC_HEADER_ID);
              		END IF;

			AHL_PC_HEADER_PVT.UPDATE_PC_HEADER
			(
				p_api_version           => 1.0,
				p_init_msg_list         => FND_API.G_FALSE,
				p_commit                => FND_API.G_FALSE,
				p_validation_level      => p_validation_level,
				p_x_pc_header_rec	=> p_x_pc_header_rec,
				x_return_status         => x_return_status,
				x_msg_count             => x_msg_count,
				x_msg_data              => x_msg_data
			);
		ELSIF (p_x_pc_header_rec.operation_flag = AHL_PC_HEADER_PVT.G_DML_COPY)
		THEN
			IF G_DEBUG='Y' THEN
		  		AHL_DEBUG_PUB.debug('PCH -- PUB -- Calling COPY_PC_HEADER for ID='||p_x_pc_header_rec.PC_HEADER_ID||' -- New Name='||p_x_pc_header_rec.NAME);
              		END IF;

			AHL_PC_HEADER_PVT.COPY_PC_HEADER
			(
				p_api_version           => 1.0,
				p_init_msg_list         => FND_API.G_FALSE,
				p_commit                => FND_API.G_FALSE,
				p_validation_level      => p_validation_level,
				p_x_pc_header_rec	=> p_x_pc_header_rec,
				x_return_status         => x_return_status,
				x_msg_count             => x_msg_count,
				x_msg_data              => x_msg_data
			);
		ELSIF (p_x_pc_header_rec.operation_flag = AHL_PC_HEADER_PVT.G_DML_DELETE)
		THEN
			IF G_DEBUG='Y' THEN
		  		AHL_DEBUG_PUB.debug('PCH -- PUB -- Calling DELETE_PC_HEADER for ID='||p_x_pc_header_rec.PC_HEADER_ID);
              		END IF;

			AHL_PC_HEADER_PVT.DELETE_PC_HEADER
			(
				p_api_version           => 1.0,
				p_init_msg_list         => FND_API.G_FALSE,
				p_commit                => FND_API.G_FALSE,
				p_validation_level      => p_validation_level,
				p_x_pc_header_rec	=> p_x_pc_header_rec,
				x_return_status         => x_return_status,
				x_msg_count             => x_msg_count,
				x_msg_data              => x_msg_data
			);
		END IF;

    		-- Check Error Message stack.
		x_msg_count := FND_MSG_PUB.count_msg;
		IF x_msg_count > 0
		THEN
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
	   		Rollback to PROCESS_PC_HEADER_PUB;
	   		FND_MSG_PUB.count_and_get( p_count => x_msg_count,
				      		   p_data  => x_msg_data,
				       		   p_encoded => fnd_api.g_false );

	 	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	   		Rollback to PROCESS_PC_HEADER_PUB;
	   		FND_MSG_PUB.count_and_get( p_count => x_msg_count,
				      		   p_data  => x_msg_data,
				      		   p_encoded => fnd_api.g_false );

	 	WHEN OTHERS THEN
	    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	    		Rollback to PROCESS_PC_HEADER_PUB;
          		IF FND_MSG_PUB.check_msg_level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	    		THEN
	       			fnd_msg_pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
				       			 p_procedure_name => 'PROCESS_PC_HEADER',
				       			 p_error_text     => SUBSTR(SQLERRM,1,240) );
	    		END IF;
	    		FND_MSG_PUB.count_and_get( p_count => x_msg_count,
				        	   p_data  => x_msg_data,
				       	  	   p_encoded => fnd_api.g_false );

	END PROCESS_PC_HEADER ;

END AHL_PC_HEADER_PUB;

/
