--------------------------------------------------------
--  DDL for Package Body AHL_DI_FILEUPLOAD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_DI_FILEUPLOAD_PVT" AS
/* $Header: AHLVFUPB.pls 115.6 2004/01/21 09:07:58 adharia noship $ */
--
G_PKG_NAME  VARCHAR2(30)  := 'AHL_DI_FILEUPLOAD_PVT';

/*-----------------------------------------------------------*/
/* procedure name: UPLOAD_ITEM                               */
/* description: Procedure to insert/update content item for  */
/*              an associated document                       */
/*-----------------------------------------------------------*/




G_DEBUG 		 VARCHAR2(1):=AHL_DEBUG_PUB.is_log_enabled;



PROCEDURE UPLOAD_ITEM
 (p_api_version                  IN NUMBER    := 1.0,
  p_init_msg_list                IN VARCHAR2  := FND_API.G_TRUE,
  p_commit                       IN VARCHAR2  := FND_API.G_FALSE ,
  p_validation_level             IN NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  x_return_status                OUT NOCOPY VARCHAR2 ,
  x_msg_count                    OUT NOCOPY NUMBER ,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_x_ahl_fileupload_rec         IN OUT NOCOPY ahl_fileupload_rec
 )

 IS


 l_api_name      CONSTANT VARCHAR2(30) := 'UPLOAD_ITEM';
 l_api_version   CONSTANT NUMBER       := 1.0;
 l_init_msg_list          VARCHAR2(10) := FND_API.G_TRUE;
 l_msg_count                NUMBER;
 l_msg_data                 VARCHAR2(2000);
 l_return_status            VARCHAR2(1);
 l_rowid                    VARCHAR2(30);
 l_dummy NUMBER;
 l_object_version_number NUMBER;
 l_association_id        NUMBER;
 l_security_group_id NUMBER;

  --AHL Specific code  :

    l_is_exist_mid    NUMBER := 0 ;


    CURSOR c_association_id IS
          SELECT AHL_DOC_FILE_ASSOC_B_S.nextval
          FROM dual;


  CURSOR c_does_attach_exist (l_revid IN VARCHAR2) IS
     select  FUPV.FILE_ID , FUPV.FILE_NAME   from AHL_DOC_FILE_ASSOC_V FUPV, FND_LOBS FLOB
     where FUPV.REVISION_ID = l_revid
     and FUPV.FILE_ID  = FLOB.FILE_ID;

    l_attach_doc c_does_attach_exist%ROWTYPE;

 BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT UPLOAD_ITEM;

    -- Check if API is called in debug mode. If yes, enable debug.
    IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;

	END IF;
    -- Debug info.
    IF G_DEBUG='Y' THEN
        AHL_DEBUG_PUB.debug( 'enter private AHL_DI_FILEUPLOAD_PVT.UPLOAD_ITEM');


    END IF;


    -- Standard call to check for call compatibility.
    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                       p_api_version,
                                       l_api_name,G_PKG_NAME)
       THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_boolean(l_init_msg_list)
     THEN
       FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

 --Start of API body

 --Validations



   --Validate Document_Revision_id
   IF (p_x_ahl_fileupload_rec.p_revision_id IS NOT NULL) THEN
     BEGIN
       SELECT 1
       INTO l_dummy
       FROM AHL_DOC_REVISIONS_B
       WHERE DOC_REVISION_ID = p_x_ahl_fileupload_rec.p_revision_id;
     EXCEPTION
       WHEN no_data_found THEN
          FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_REV_ID_INVALID');
          FND_MSG_PUB.ADD;
          IF G_DEBUG='Y' THEN
	     AHL_DEBUG_PUB.debug( 'ERROR: AHL_DI_DOC REV ID:'||p_x_ahl_fileupload_rec.p_revision_id||': invalid');


          END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
       WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE;
     END;
   ELSE
     FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_REV_ID_NULL');
     FND_MSG_PUB.ADD;
     IF G_DEBUG='Y' THEN
     	 AHL_DEBUG_PUB.debug( 'ERROR: AHL_DI_DOC REV null');

     END IF;
     x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;





   --Validate file_id
   IF (p_x_ahl_fileupload_rec.p_file_id IS NOT NULL) THEN
     BEGIN
       SELECT distinct 1
       INTO l_dummy
       FROM FND_LOBS
       WHERE FILE_ID = p_x_ahl_fileupload_rec.p_file_id;
     EXCEPTION
       WHEN no_data_found THEN
           IF G_DEBUG='Y' THEN
	     AHL_DEBUG_PUB.debug( 'ERROR: AHL_DI_ATTACH_FILE_NOT_EXISTS');
           END IF;
           x_return_status := FND_API.G_RET_STS_ERROR;
       WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE;
     END;
   ELSE
      IF G_DEBUG='Y' THEN
      	AHL_DEBUG_PUB.debug( 'ERROR: AHL_DI_ATTACH_FILE IS Null');
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;


   -- check if association exists
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'checking for already existing file ');
     END IF;

    open c_does_attach_exist (p_x_ahl_fileupload_rec.p_revision_id);

     LOOP
       fetch c_does_attach_exist into l_attach_doc;
       exit when c_does_attach_exist%NOTFOUND;
       AHL_DEBUG_PUB.debug( 'l_attach_doc  value '||  l_attach_doc.file_id);
       AHL_DEBUG_PUB.debug( 'l_attach_doc  value '||  l_attach_doc.file_name);
       l_is_exist_mid := l_attach_doc.file_id;

    END LOOP;
  close c_does_attach_exist;



   if( l_is_exist_mid  <> 0)
   then
   DELETE_ITEM
           (
             p_api_version => 1.0,
   	     p_init_msg_list => FND_API.G_FALSE,
   	     p_commit => FND_API.G_FALSE,
   	     p_validation_level => FND_API.G_VALID_LEVEL_FULL,
   	     x_return_status => l_return_status,
   	     x_msg_count => l_msg_count,
   	     x_msg_data => l_msg_data,
             p_x_ahl_fileupload_rec => p_x_ahl_fileupload_rec
      );

   end if;
  IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.debug('completed delete if there are any  ');
    END IF;

 -- get new associationid from sequence.

   open c_association_id ;
   fetch c_association_id  into l_association_id;
   close c_association_id ;

   p_x_ahl_fileupload_rec.p_association_id := l_association_id;




   AHL_DOC_FILE_ASSOC_PKG.INSERT_ROW(
   X_ROWID => l_rowid ,
   X_ASSOCIATION_ID => l_association_id,
   X_OBJECT_VERSION_NUMBER => 1,
   X_FILE_ID => p_x_ahl_fileupload_rec.p_file_id,
   X_FILE_NAME => p_x_ahl_fileupload_rec.p_file_name,
   X_REVISION_ID => p_x_ahl_fileupload_rec.p_revision_id,
   X_DATATYPE_CODE => p_x_ahl_fileupload_rec.p_datatype_code,
   X_SECURITY_GROUP_ID => l_security_group_id,
   X_ATTRIBUTE_CATEGORY => p_x_ahl_fileupload_rec.p_attribute_category,
     X_ATTRIBUTE1 =>  p_x_ahl_fileupload_rec.p_attribute1,
     X_ATTRIBUTE2  => p_x_ahl_fileupload_rec.p_attribute2,
     X_ATTRIBUTE3  => p_x_ahl_fileupload_rec.p_attribute3,
     X_ATTRIBUTE4  => p_x_ahl_fileupload_rec.p_attribute4,
     X_ATTRIBUTE5 => p_x_ahl_fileupload_rec.p_attribute5,
     X_ATTRIBUTE6  => p_x_ahl_fileupload_rec.p_attribute6,
     X_ATTRIBUTE7  => p_x_ahl_fileupload_rec.p_attribute7,
     X_ATTRIBUTE8 => p_x_ahl_fileupload_rec.p_attribute8,
     X_ATTRIBUTE9  => p_x_ahl_fileupload_rec.p_attribute9,
     X_ATTRIBUTE10 => p_x_ahl_fileupload_rec.p_attribute10,
     X_ATTRIBUTE11  => p_x_ahl_fileupload_rec.p_attribute11,
     X_ATTRIBUTE12 => p_x_ahl_fileupload_rec.p_attribute12,
     X_ATTRIBUTE13 => p_x_ahl_fileupload_rec.p_attribute13,
     X_ATTRIBUTE14  => p_x_ahl_fileupload_rec.p_attribute14,
     X_ATTRIBUTE15 => p_x_ahl_fileupload_rec.p_attribute15,
   X_FILE_DESC =>  p_x_ahl_fileupload_rec.p_file_description,
   X_CREATION_DATE => sysdate,
   X_CREATED_BY => fnd_global.user_id,
   X_LAST_UPDATE_DATE => sysdate,
   X_LAST_UPDATED_BY => fnd_global.user_id,
   X_LAST_UPDATE_LOGIN => fnd_global.login_id
   );





   --Standard check for commit
      IF FND_API.TO_BOOLEAN(p_commit) THEN
         COMMIT;
      END IF;
      -- Debug info
      IF G_DEBUG='Y' THEN
        AHL_DEBUG_PUB.debug( 'End of private api UPLOAD_ITEM');


      END IF;
      -- Check if API is called in debug mode. If yes, disable debug.
      IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.disable_debug;

	END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO UPLOAD_ITEM;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);
       IF G_DEBUG='Y' THEN
         AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'ERROR' );
         AHL_DEBUG_PUB.debug( 'AHL_DI_FILEUPLOAD_PVT.UPLOAD_ITEM');

       -- Check if API is called in debug mode. If yes, disable debug.
         AHL_DEBUG_PUB.disable_debug;

	END IF;

    WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO UPLOAD_ITEM;
       X_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => X_msg_data);
       -- Debug info.
       IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
          AHL_DEBUG_PUB.debug( 'AHL_DI_FILEUPLOAD_PVT.UPLOAD_ITEM');

       -- Check if API is called in debug mode. If yes, disable debug.
          AHL_DEBUG_PUB.disable_debug;

	END IF;

    WHEN OTHERS THEN
       ROLLBACK TO UPLOAD_ITEM;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          fnd_msg_pub.add_exc_msg(p_pkg_name        =>  G_PKG_NAME,
                                  p_procedure_name  =>  l_api_name,
                                  p_error_text      => SUBSTR(SQLERRM,1,240));
       END IF;
       FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

       -- Debug info.
       IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'SQL ERROR' );
          AHL_DEBUG_PUB.debug( 'AHL_DI_FILEUPLOAD_PVT.UPLOAD_ITEM');

       -- Check if API is called in debug mode. If yes, disable debug.
          AHL_DEBUG_PUB.disable_debug;

	END IF;

END UPLOAD_ITEM;


 PROCEDURE DELETE_ITEM
  (
   p_api_version                  IN  NUMBER    := 1.0               ,
   p_init_msg_list                IN  VARCHAR2  := FND_API.G_TRUE      ,
   p_commit                       IN  VARCHAR2  := FND_API.G_FALSE     ,
   p_validation_level             IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
   x_return_status                OUT NOCOPY VARCHAR2,
   x_msg_count                    OUT NOCOPY NUMBER,
   x_msg_data                     OUT NOCOPY VARCHAR2,
   p_x_ahl_fileupload_rec           IN ahl_fileupload_rec
 )

  IS

   l_api_name      CONSTANT VARCHAR2(30) := 'DELETE_ITEM';
   l_api_version   CONSTANT NUMBER       := 1.0;
   l_init_msg_list          VARCHAR2(10) := FND_API.G_TRUE;
   l_msg_count                NUMBER;
   l_msg_data                 VARCHAR2(2000);
   l_return_status            VARCHAR2(1);

   l_dummy NUMBER;
   l_assoc_id  NUMBER;
   l_security_group_id NUMBER;

  CURSOR c_get_association_id (l_revid IN VARCHAR2) IS
       select  FUPV.ASSOCIATION_ID  from AHL_DOC_FILE_ASSOC_V FUPV , FND_LOBS FLOB
       where FUPV.REVISION_ID = l_revid
     and FUPV.FILE_ID  = FLOB.FILE_ID;

  BEGIN
    -- Standard Start of API savepoint
        SAVEPOINT Delete_Item;

        -- Check if API is called in debug mode. If yes, enable debug.
        IF G_DEBUG='Y' THEN
  		  AHL_DEBUG_PUB.enable_debug;

  	END IF;
        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.debug( 'enter private AHL_DI_FILEUPLOAD_PVT.DELETE_ITEM');
        END IF;


        -- Standard call to check for call compatibility.
        IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                           p_api_version,
                                           l_api_name,G_PKG_NAME) THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
       -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_boolean(l_init_msg_list) THEN
           FND_MSG_PUB.initialize;
        END IF;

        --  Initialize API return status to success
         x_return_status := FND_API.G_RET_STS_SUCCESS;

   --Start of API body

   --Validations



    --Validate Document Revision Id

      IF G_DEBUG='Y' THEN
           AHL_DEBUG_PUB.debug( 'enter private AHL_DI_FILEUPLOAD_PVT.DELETE_ITEM');
      END IF;

      IF (p_x_ahl_fileupload_rec.p_revision_id IS NOT NULL) THEN
              BEGIN
                SELECT 1
  	      INTO l_dummy
  	      FROM AHL_DOC_REVISIONS_B
                WHERE DOC_REVISION_ID = p_x_ahl_fileupload_rec.p_revision_id;
              EXCEPTION
                WHEN no_data_found THEN
                    IF G_DEBUG='Y' THEN
  		      AHL_DEBUG_PUB.debug( 'ERROR: AHL_DI_DOC_REV_ID_INVALID');


                    END IF;
                    FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_REV_ID_INVALID');
                    FND_MSG_PUB.ADD;
                    x_return_status := FND_API.G_RET_STS_ERROR;
                WHEN OTHERS THEN
                    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                RAISE;
              END;
            ELSE
               IF G_DEBUG='Y' THEN
  	     	 AHL_DEBUG_PUB.debug( 'ERROR: AHL_DI_DOC_REV_ID is null');


               END IF;
               FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_REV_ID_INVALID');
               FND_MSG_PUB.ADD;
               x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;


    --Validate if file exists in FND_LOBS

    IF (p_x_ahl_fileupload_rec.p_file_id IS NOT NULL) THEN
         BEGIN
           SELECT distinct 1
           INTO l_dummy
           FROM FND_LOBS
           WHERE FILE_ID = p_x_ahl_fileupload_rec.p_file_id;
         EXCEPTION
           WHEN no_data_found THEN
               IF G_DEBUG='Y' THEN
    	     AHL_DEBUG_PUB.debug( 'ERROR: AHL_DI_ATTACH_FILE_NOT_EXISTS');


               END IF;
               x_return_status := FND_API.G_RET_STS_ERROR;
           WHEN OTHERS THEN
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           RAISE;
         END;
       ELSE
          IF G_DEBUG='Y' THEN
          	AHL_DEBUG_PUB.debug( 'ERROR: AHL_DI_ATTACH_FILE IS Null');


          END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;


       -- Validate if association exists and retrieve the association id to be deleted.

       l_assoc_id := 0;

       IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug( 'checking for already existing file ');
         END IF;

        open c_get_association_id (p_x_ahl_fileupload_rec.p_revision_id);

         LOOP
           fetch c_get_association_id  into l_assoc_id;
           exit when c_get_association_id %NOTFOUND;
           AHL_DEBUG_PUB.debug( 'l_assoc_id  value to be deleted'||  l_assoc_id);
         END LOOP;
        close c_get_association_id;

        -- if association id not found then raise error.
        IF(l_assoc_id = 0)THEN

          FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_FILE_ASSOC_INVALID');
	  FND_MSG_PUB.ADD;
	  x_return_status := FND_API.G_RET_STS_ERROR;

	  IF G_DEBUG='Y' THEN
    	   AHL_DEBUG_PUB.debug( 'ERROR: the file association to be deleted is not found ');
          END IF;

        END IF;






   AHL_DOC_FILE_ASSOC_PKG.DELETE_ROW(

      X_ASSOCIATION_ID => l_assoc_id

      );


  IF   l_return_status = FND_API.G_RET_STS_ERROR  THEN
                RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_API.TO_BOOLEAN(p_commit) THEN
             COMMIT;
         END IF;

        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.debug( 'exit private AHL_DI_FILEUPLOAD_PVT.DELETE_ITEM');
        END IF;

       EXCEPTION
             WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO Delete_Item;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                                           p_count => x_msg_count,
                                           p_data  => x_msg_data);
                IF G_DEBUG='Y' THEN
                  AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'ERROR' );
                  AHL_DEBUG_PUB.debug( 'AHL_DI_FILEUPLOAD_PVT.DELETE_ITEMS');


                -- Check if API is called in debug mode. If yes, disable debug.
                  AHL_DEBUG_PUB.disable_debug;

       	END IF;

             WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO Delete_Item;
                X_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                                           p_count => x_msg_count,
                                           p_data  => X_msg_data);
                -- Debug info.
                IF G_DEBUG='Y' THEN
                   AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
                   AHL_DEBUG_PUB.debug( 'AHL_DI_FILEUPLOAD_PVT.DELETE_ITEMS:');


                -- Check if API is called in debug mode. If yes, disable debug.
                   AHL_DEBUG_PUB.disable_debug;

       	END IF;

             WHEN OTHERS THEN
                ROLLBACK TO Delete_Item;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                   fnd_msg_pub.add_exc_msg(p_pkg_name        =>  G_PKG_NAME,
                                           p_procedure_name  =>  l_api_name,
                                           p_error_text      => SUBSTR(SQLERRM,1,240));
                END IF;
                FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                                           p_count => x_msg_count,
                                           p_data  => x_msg_data);

                -- Debug info.
                IF G_DEBUG='Y' THEN
                   AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'SQL ERROR' );
                   AHL_DEBUG_PUB.debug( 'AHL_DI_FILEUPLOAD_PVT.DELETE_ITEM');


                -- Check if API is called in debug mode. If yes, disable debug.
                   AHL_DEBUG_PUB.disable_debug;

       	END IF;


  END DELETE_ITEM;


 PROCEDURE PROCESS_ITEM
     (p_api_version                  IN NUMBER    DEFAULT 1.0,
      p_init_msg_list                IN VARCHAR2  DEFAULT FND_API.G_TRUE,
      p_commit                       IN VARCHAR2  DEFAULT FND_API.G_FALSE ,
      p_validation_level             IN NUMBER    DEFAULT FND_API.G_VALID_LEVEL_FULL,
      x_return_status                OUT NOCOPY VARCHAR2 ,
      x_msg_count                    OUT NOCOPY NUMBER ,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_x_ahl_fileupload_rec            IN OUT NOCOPY ahl_fileupload_rec,
      p_delete_flag                  IN VARCHAR2
     )

     IS

      l_ahl_fileupload_rec ahl_fileupload_rec;
      l_api_name      CONSTANT VARCHAR2(30) := 'PROCESS_ITEM';
      l_api_version   CONSTANT NUMBER       := 1.0;
      l_init_msg_list          VARCHAR2(10) := FND_API.G_TRUE;

     BEGIN
     -- Standard Start of API savepoint
        SAVEPOINT process_item;
      IF G_DEBUG='Y' THEN
         		  AHL_DEBUG_PUB.enable_debug;

         	END IF;
             -- Debug info.
             IF G_DEBUG='Y' THEN
                 AHL_DEBUG_PUB.debug( 'enter private AHL_DI_FILEUPLOAD_PVT.PROCESS_ITEM');


             END IF;


             -- Standard call to check for call compatibility.
             IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                                p_api_version,
                                                l_api_name,G_PKG_NAME)
                THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
            -- Initialize message list if p_init_msg_list is set to TRUE.
             IF FND_API.to_boolean(l_init_msg_list)
              THEN
                FND_MSG_PUB.initialize;
             END IF;

             --  Initialize API return status to success
              x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Start of API body

	IF ( p_delete_flag ='Y') THEN

		DELETE_ITEM
		(
		  p_api_version => 1.0,
		  p_init_msg_list => FND_API.G_FALSE,
		  p_commit => FND_API.G_FALSE,
		  p_validation_level => FND_API.G_VALID_LEVEL_FULL,
		  x_return_status => x_return_status,
		  x_msg_count => x_msg_count,
		  x_msg_data => x_msg_data,
		  p_x_ahl_fileupload_rec => p_x_ahl_fileupload_rec
	        );

	ELSIF ( p_delete_flag = 'N') THEN
	         UPLOAD_ITEM
	   	 (
	   	  p_api_version => 1.0,
	   	  p_init_msg_list => FND_API.G_TRUE,
	   	  p_commit => FND_API.G_FALSE,
	   	  p_validation_level => FND_API.G_VALID_LEVEL_FULL,
	   	  x_return_status => x_return_status,
	   	  x_msg_count => x_msg_count,
	    	  x_msg_data => x_msg_data,
	   	  p_x_ahl_fileupload_rec => p_x_ahl_fileupload_rec
                 );

        ELSE
                  RAISE FND_API.G_EXC_ERROR;
        END IF;

       IF G_DEBUG='Y' THEN
         AHL_DEBUG_PUB.debug( 'exit private AHL_DI_FILEUPLOAD_PVT.PROCESS_ITEM');
       END IF;
       EXCEPTION
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO process_item;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                                     p_count => x_msg_count,
                                     p_data  => x_msg_data);
          IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'ERROR' );
            AHL_DEBUG_PUB.debug( 'AHL_DI_FILEUPLOAD_PVT.PROCESS_ITEM');


          -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

 	END IF;

       WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO process_item;
          X_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                                     p_count => x_msg_count,
                                     p_data  => X_msg_data);
          -- Debug info.
          IF G_DEBUG='Y' THEN
             AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
             AHL_DEBUG_PUB.debug( 'AHL_DI_CONTENT_MGMT_PVT.PROCESS_ITEM');


          -- Check if API is called in debug mode. If yes, disable debug.
             AHL_DEBUG_PUB.disable_debug;

 	END IF;

       WHEN OTHERS THEN
          ROLLBACK TO process_item;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             fnd_msg_pub.add_exc_msg(p_pkg_name        =>  G_PKG_NAME,
                                     p_procedure_name  =>  l_api_name,
                                     p_error_text      => SUBSTR(SQLERRM,1,240));
          END IF;
          FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                                     p_count => x_msg_count,
                                     p_data  => x_msg_data);

          -- Debug info.
          IF G_DEBUG='Y' THEN
             AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'SQL ERROR' );
             AHL_DEBUG_PUB.debug( 'AHL_DI_FILEUPLOAD_PVT.PROCESS_ITEM');


          -- Check if API is called in debug mode. If yes, disable debug.
             AHL_DEBUG_PUB.disable_debug;

 	END IF;

     END PROCESS_ITEM;




END AHL_DI_FILEUPLOAD_PVT;


/
