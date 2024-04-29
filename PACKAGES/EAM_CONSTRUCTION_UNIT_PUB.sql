--------------------------------------------------------
--  DDL for Package EAM_CONSTRUCTION_UNIT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_CONSTRUCTION_UNIT_PUB" AUTHID CURRENT_USER as
/* $Header: EAMPCUS.pls 120.0.12010000.2 2008/11/19 14:28:35 dsingire noship $*/

TYPE CU_rec IS RECORD(
	    CU_ID			                NUMBER        	:= FND_API.G_MISS_NUM
     ,CU_NAME			              VARCHAR2(50)	  := FND_API.G_MISS_CHAR
     ,DESCRIPTION		            VARCHAR2(240) 	:= FND_API.G_MISS_CHAR
     ,ORGANIZATION_ID	          NUMBER  	      := FND_API.G_MISS_NUM
     ,CU_EFFECTIVE_FROM         DATE          	:= FND_API.G_MISS_DATE
     ,CU_EFFECTIVE_TO           DATE          	:= FND_API.G_MISS_DATE
	   ,ATTRIBUTE_CATEGORY        VARCHAR2(30)		:= FND_API.G_MISS_CHAR
     ,ATTRIBUTE1                VARCHAR2(150)		:= FND_API.G_MISS_CHAR
     ,ATTRIBUTE2                VARCHAR2(150)		:= FND_API.G_MISS_CHAR
     ,ATTRIBUTE3                VARCHAR2(150)		:= FND_API.G_MISS_CHAR
     ,ATTRIBUTE4                VARCHAR2(150)		:= FND_API.G_MISS_CHAR
     ,ATTRIBUTE5                VARCHAR2(150)		:= FND_API.G_MISS_CHAR
     ,ATTRIBUTE6                VARCHAR2(150)		:= FND_API.G_MISS_CHAR
     ,ATTRIBUTE7                VARCHAR2(150)		:= FND_API.G_MISS_CHAR
     ,ATTRIBUTE8                VARCHAR2(150)		:= FND_API.G_MISS_CHAR
     ,ATTRIBUTE9                VARCHAR2(150)		:= FND_API.G_MISS_CHAR
     ,ATTRIBUTE10               VARCHAR2(150)		:= FND_API.G_MISS_CHAR
     ,ATTRIBUTE11               VARCHAR2(150)		:= FND_API.G_MISS_CHAR
     ,ATTRIBUTE12               VARCHAR2(150)		:= FND_API.G_MISS_CHAR
     ,ATTRIBUTE13               VARCHAR2(150)		:= FND_API.G_MISS_CHAR
     ,ATTRIBUTE14               VARCHAR2(150)		:= FND_API.G_MISS_CHAR
     ,ATTRIBUTE15               VARCHAR2(150)		:= FND_API.G_MISS_CHAR
      );

TYPE CU_Activity_rec IS RECORD(
      CU_DETAIL_ID			          NUMBER            := FND_API.G_MISS_NUM
     ,CU_ID			                  NUMBER            := FND_API.G_MISS_NUM
     ,ACCT_CLASS_CODE             VARCHAR2(10)	    := FND_API.G_MISS_CHAR
     ,ACTIVITY_ID                 NUMBER            := FND_API.G_MISS_NUM
     ,CU_ACTIVITY_QTY		          NUMBER            := FND_API.G_MISS_NUM
     ,CU_ACTIVITY_EFFECTIVE_FROM  DATE              := FND_API.G_MISS_DATE
     ,CU_ACTIVITY_EFFECTIVE_TO    DATE              := FND_API.G_MISS_DATE
     ,CU_ASSIGN_TO_ORG            VARCHAR2(2)	      := FND_API.G_MISS_CHAR
      );
TYPE  CU_Activity_tbl      IS TABLE OF CU_Activity_rec
      INDEX BY BINARY_INTEGER;

TYPE CU_ID_rec IS RECORD(
      CU_ID			                  NUMBER            := FND_API.G_MISS_NUM
      );

TYPE CU_ID_tbl IS TABLE OF CU_ID_rec INDEX BY BINARY_INTEGER;

PROCEDURE create_construction_unit(
      p_api_version             IN      NUMBER
     ,p_commit                  IN      VARCHAR2
     ,p_cu_rec			            IN    CU_rec
     ,p_cu_activity_tbl         IN    CU_Activity_tbl
     ,x_cu_id                   OUT   NOCOPY  NUMBER
     ,x_return_status           OUT   NOCOPY VARCHAR2
     ,x_msg_count               OUT   NOCOPY NUMBER
     ,x_msg_data                OUT   NOCOPY VARCHAR2
      );

PROCEDURE update_construction_unit(
      p_api_version             IN      NUMBER
     ,p_commit                  IN      VARCHAR2
     ,p_cu_rec			            IN    EAM_CONSTRUCTION_UNIT_PUB.CU_rec
     ,p_cu_activity_tbl         IN    EAM_CONSTRUCTION_UNIT_PUB.CU_Activity_tbl
     ,x_cu_id                   OUT   NOCOPY  NUMBER
     ,x_return_status           OUT   NOCOPY VARCHAR2
     ,x_msg_count               OUT   NOCOPY NUMBER
     ,x_msg_data                OUT   NOCOPY VARCHAR2
      );

PROCEDURE copy_construction_unit(
      p_api_version             IN      NUMBER
     ,p_commit                  IN      VARCHAR2
     ,p_cu_rec			            IN    EAM_CONSTRUCTION_UNIT_PUB.CU_rec
     ,p_cu_activity_tbl         IN    EAM_CONSTRUCTION_UNIT_PUB.CU_Activity_tbl
     ,p_source_cu_id_tbl        IN    EAM_CONSTRUCTION_UNIT_PUB.CU_ID_tbl
     ,x_cu_id                   OUT   NOCOPY  NUMBER
     ,x_return_status           OUT   NOCOPY VARCHAR2
     ,x_msg_count               OUT   NOCOPY NUMBER
     ,x_msg_data                OUT   NOCOPY VARCHAR2
      );

End EAM_CONSTRUCTION_UNIT_PUB;

/
