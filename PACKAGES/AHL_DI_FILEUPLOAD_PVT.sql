--------------------------------------------------------
--  DDL for Package AHL_DI_FILEUPLOAD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_DI_FILEUPLOAD_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVFUPS.pls 115.2 2004/01/21 09:07:22 adharia noship $ */

-- Declare records and table types

TYPE ahl_fileupload_rec IS RECORD
  (
   p_association_id    NUMBER,
   p_file_id           NUMBER,
   p_file_name               VARCHAR2(256),
   p_file_description        VARCHAR2(2000),
   p_revision_id       NUMBER,
   p_datatype_code VARCHAR2(30),
			p_attribute_category VARCHAR2(30),
			p_attribute1 VARCHAR2(150),
			p_attribute2 VARCHAR2(150),
			p_attribute3 VARCHAR2(150),
			p_attribute4 VARCHAR2(150),
			p_attribute5 VARCHAR2(150),
			p_attribute6 VARCHAR2(150),
			p_attribute7 VARCHAR2(150),
			p_attribute8 VARCHAR2(150),
			p_attribute9 VARCHAR2(150),
			p_attribute10 VARCHAR2(150),
			p_attribute11 VARCHAR2(150),
			p_attribute12 VARCHAR2(150),
			p_attribute13 VARCHAR2(150),
			p_attribute14 VARCHAR2(150),
			p_attribute15 VARCHAR2(150),
   p_x_object_version_number  NUMBER

  );


-- Procedure to insert/update file for an associated document
 PROCEDURE UPLOAD_ITEM
 (
  p_api_version                  IN NUMBER    DEFAULT 1.0,
  p_init_msg_list                IN VARCHAR2  DEFAULT FND_API.G_TRUE,
  p_commit                       IN VARCHAR2  DEFAULT FND_API.G_FALSE ,
  p_validation_level             IN NUMBER    DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status                OUT NOCOPY VARCHAR2 ,
  x_msg_count                    OUT NOCOPY NUMBER ,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_x_ahl_fileupload_rec            IN OUT NOCOPY ahl_fileupload_rec
 );




-- Procedure to delete association for the file for an associated document
 PROCEDURE DELETE_ITEM
  (
   p_api_version                  IN  NUMBER    := 1.0               ,
   p_init_msg_list                IN  VARCHAR2  := FND_API.G_TRUE      ,
   p_commit                       IN  VARCHAR2  := FND_API.G_FALSE     ,
   p_validation_level             IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
   x_return_status                OUT NOCOPY VARCHAR2,
   x_msg_count                    OUT NOCOPY NUMBER,
   x_msg_data                     OUT NOCOPY VARCHAR2,
   p_x_ahl_fileupload_rec          IN ahl_fileupload_rec
 );

-- Procedure to process (insert/delete) items for the file for an associated document

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
 );

END AHL_DI_FILEUPLOAD_PVT;




 

/
