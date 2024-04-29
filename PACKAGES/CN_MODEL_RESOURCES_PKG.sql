--------------------------------------------------------
--  DDL for Package CN_MODEL_RESOURCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_MODEL_RESOURCES_PKG" AUTHID CURRENT_USER AS
  /*$Header: cntmlrss.pls 115.2 2002/01/28 20:04:52 pkm ship      $*/

PROCEDURE insert_row
  (P_MODEL_RESOURCE_ID	         IN   NUMBER   := FND_API.G_MISS_NUM,
   P_RESOURCE_ID                 IN   NUMBER,
   P_NAME                        IN   VARCHAR2,
   P_SRP_ID                      IN   NUMBER,
   P_ATTRIBUTE_CATEGORY          IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE1                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE2                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE3                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE4                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE5                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE6                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE7                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE8                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE9                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE10                 IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE11                 IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE12                 IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE13                 IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE14                 IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE15                 IN   VARCHAR2 := FND_API.G_MISS_CHAR);

PROCEDURE update_row
  (P_MODEL_RESOURCE_ID	         IN   NUMBER,
   P_RESOURCE_ID                 IN   NUMBER   := FND_API.G_MISS_NUM,
   P_NAME                        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_SRP_ID                      IN   NUMBER   := FND_API.G_MISS_NUM,
   P_ATTRIBUTE_CATEGORY          IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE1                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE2                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE3                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE4                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE5                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE6                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE7                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE8                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE9                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE10                 IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE11                 IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE12                 IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE13                 IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE14                 IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ATTRIBUTE15                 IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_OBJECT_VERSION_NUMBER       IN   NUMBER   := FND_API.G_MISS_NUM );

PROCEDURE delete_row
  (P_MODEL_RESOURCE_ID               IN   NUMBER);

END cn_model_resources_pkg;

 

/
