--------------------------------------------------------
--  DDL for Package CN_ROLE_PAY_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_ROLE_PAY_GROUPS_PKG" AUTHID CURRENT_USER AS
/* $Header: cntrlpgs.pls 120.3 2005/07/26 02:39:16 sjustina noship $ */

procedure INSERT_ROW
  (
   X_ROWID      		  IN OUT NOCOPY VARCHAR2,  -- required
   X_ROLE_PAY_GROUP_ID	  IN OUT NOCOPY NUMBER,        -- required
   X_ROLE_ID	       	          IN NUMBER,        -- required
   X_PAY_GROUP_ID	       	  IN NUMBER,        -- required
   X_START_DATE                   IN DATE,          -- required
   X_END_DATE                     IN DATE     := FND_API.G_MISS_DATE,
   X_ATTRIBUTE_CATEGORY           IN VARCHAR2 := FND_API.G_MISS_CHAR,
   X_ATTRIBUTE1		       	  IN VARCHAR2 := FND_API.G_MISS_CHAR,
   X_ATTRIBUTE2		       	  IN VARCHAR2 := FND_API.G_MISS_CHAR,
   X_ATTRIBUTE3		       	  IN VARCHAR2 := FND_API.G_MISS_CHAR,
   X_ATTRIBUTE4		       	  IN VARCHAR2 := FND_API.G_MISS_CHAR,
   X_ATTRIBUTE5		       	  IN VARCHAR2 := FND_API.G_MISS_CHAR,
   X_ATTRIBUTE6		       	  IN VARCHAR2 := FND_API.G_MISS_CHAR,
   X_ATTRIBUTE7		       	  IN VARCHAR2 := FND_API.G_MISS_CHAR,
   X_ATTRIBUTE8		       	  IN VARCHAR2 := FND_API.G_MISS_CHAR,
   X_ATTRIBUTE9		       	  IN VARCHAR2 := FND_API.G_MISS_CHAR,
   X_ATTRIBUTE10       	       	  IN VARCHAR2 := FND_API.G_MISS_CHAR,
   X_ATTRIBUTE11       	       	  IN VARCHAR2 := FND_API.G_MISS_CHAR,
   X_ATTRIBUTE12       	       	  IN VARCHAR2 := FND_API.G_MISS_CHAR,
   X_ATTRIBUTE13       	       	  IN VARCHAR2 := FND_API.G_MISS_CHAR,
   X_ATTRIBUTE14       	       	  IN VARCHAR2 := FND_API.G_MISS_CHAR,
   X_ATTRIBUTE15	       	  IN VARCHAR2 := FND_API.G_MISS_CHAR,
   X_CREATED_BY	       		  IN NUMBER   := FND_API.G_MISS_NUM,
   X_CREATION_DATE		  IN DATE     := FND_API.G_MISS_DATE,
   X_LAST_UPDATE_LOGIN	       	  IN NUMBER   := FND_API.G_MISS_NUM,
   X_LAST_UPDATE_DATE		  IN DATE     := FND_API.G_MISS_DATE,
   X_LAST_UPDATED_BY		  IN NUMBER   := FND_API.G_MISS_NUM,
   X_ORG_ID                   IN NUMBER   := FND_API.G_MISS_NUM,
   X_OBJECT_VERSION_NUMBER   OUT NOCOPY NUMBER);

procedure DELETE_ROW (X_ROLE_PAY_GROUP_ID	  IN  NUMBER);

END cn_role_pay_groups_pkg;
 

/
