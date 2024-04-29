--------------------------------------------------------
--  DDL for Package CN_ROLE_MODELS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_ROLE_MODELS_PKG" AUTHID CURRENT_USER AS
  /*$Header: cntrlmls.pls 115.2 2002/01/28 20:05:33 pkm ship      $*/

PROCEDURE insert_row
  (P_ROLE_MODEL_ID	         IN   NUMBER   := FND_API.G_MISS_NUM,
   P_ROLE_ID                     IN   NUMBER,
   P_NAME                        IN   VARCHAR2,
   P_DESCRIPTION                 IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_SEQ 	                 IN   NUMBER   := FND_API.G_MISS_NUM,
   P_STATUS 	                 IN   VARCHAR2,
   P_ACTIVATE_STATUS             IN   VARCHAR2,
   P_CLUB_ELIGIBLE_FLAG	         IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_OTE		         IN   NUMBER   := FND_API.G_MISS_NUM,
   P_ROUNDING_FACTOR             IN   NUMBER   := FND_API.G_MISS_NUM,
   P_ATTAIN_SCHEDULE_ID	         IN   NUMBER   := FND_API.G_MISS_NUM,
   P_PLAN_LEVEL		         IN   NUMBER   := FND_API.G_MISS_NUM,
   P_QUOTA_MIN		         IN   NUMBER   := FND_API.G_MISS_NUM,
   P_QUOTA_MAX		         IN   NUMBER   := FND_API.G_MISS_NUM,
   P_ESTIMATED_PAYOUT	         IN   NUMBER   := FND_API.G_MISS_NUM,
   P_SRP_ROLE_ID                 IN   NUMBER   := FND_API.G_MISS_NUM,
   P_START_DATE		         IN   DATE,
   P_END_DATE		         IN   DATE     := FND_API.G_MISS_DATE,
   P_SCENARIO_STATUS	         IN   VARCHAR2 := FND_API.G_MISS_CHAR,
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
   P_ATTRIBUTE15                 IN   VARCHAR2 := FND_API.G_MISS_CHAR);

PROCEDURE update_row
  (P_ROLE_MODEL_ID	         IN   NUMBER,
   P_ROLE_ID                     IN   NUMBER   := FND_API.G_MISS_NUM,
   P_NAME                        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_DESCRIPTION                 IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_SEQ 	                 IN   NUMBER   := FND_API.G_MISS_NUM,
   P_STATUS 	                 IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_ACTIVATE_STATUS             IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_CLUB_ELIGIBLE_FLAG	         IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   P_OTE		         IN   NUMBER   := FND_API.G_MISS_NUM,
   P_ROUNDING_FACTOR             IN   NUMBER   := FND_API.G_MISS_NUM,
   P_ATTAIN_SCHEDULE_ID	         IN   NUMBER   := FND_API.G_MISS_NUM,
   P_PLAN_LEVEL		         IN   NUMBER   := FND_API.G_MISS_NUM,
   P_QUOTA_MIN		         IN   NUMBER   := FND_API.G_MISS_NUM,
   P_QUOTA_MAX		         IN   NUMBER   := FND_API.G_MISS_NUM,
   P_ESTIMATED_PAYOUT	         IN   NUMBER   := FND_API.G_MISS_NUM,
   P_SRP_ROLE_ID	         IN   NUMBER   := FND_API.G_MISS_NUM,
   P_START_DATE		         IN   DATE     := FND_API.G_MISS_DATE,
   P_END_DATE		         IN   DATE     := FND_API.G_MISS_DATE,
   P_SCENARIO_STATUS	         IN   VARCHAR2 := FND_API.G_MISS_CHAR,
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
  (P_ROLE_MODEL_ID               IN   NUMBER);

END cn_role_models_pkg;

 

/
