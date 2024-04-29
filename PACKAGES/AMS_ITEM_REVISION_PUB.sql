--------------------------------------------------------
--  DDL for Package AMS_ITEM_REVISION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_ITEM_REVISION_PUB" AUTHID CURRENT_USER AS
/* $Header: amsprevs.pls 115.4 2002/11/15 21:01:15 abhola ship $ */

--  ============================================================================
--  Global variables and cursors
--  ============================================================================

G_FILE_NAME    CONSTANT  VARCHAR2(12)  :=  'AMSPREVS.pls';

--  ============================================================================
--  Record Type:		Item_Revision_rec_type
--  ============================================================================

TYPE Item_Revision_rec_type IS RECORD
(
   inventory_item_id		NUMBER		:=  FND_API.g_MISS_NUM
,  organization_id		NUMBER		:=  FND_API.g_MISS_NUM
,  revision			VARCHAR2(3)	:=  FND_API.g_MISS_CHAR
,  description			VARCHAR2(240)	:=  FND_API.g_MISS_CHAR
,  change_notice		VARCHAR2(10)	:=  FND_API.g_MISS_CHAR
,  ecn_initiation_date		DATE		:=  FND_API.g_MISS_DATE
,  implementation_date		DATE		:=  FND_API.g_MISS_DATE
,  effectivity_date		DATE		:=  FND_API.g_MISS_DATE
,  revised_item_sequence_id	NUMBER		:=  FND_API.g_MISS_NUM
,  attribute_category		VARCHAR2(30)	:=  FND_API.g_MISS_CHAR
,  attribute1			VARCHAR2(150)	:=  FND_API.g_MISS_CHAR
,  attribute2			VARCHAR2(150)	:=  FND_API.g_MISS_CHAR
,  attribute3			VARCHAR2(150)	:=  FND_API.g_MISS_CHAR
,  attribute4			VARCHAR2(150)	:=  FND_API.g_MISS_CHAR
,  attribute5			VARCHAR2(150)	:=  FND_API.g_MISS_CHAR
,  attribute6			VARCHAR2(150)	:=  FND_API.g_MISS_CHAR
,  attribute7			VARCHAR2(150)	:=  FND_API.g_MISS_CHAR
,  attribute8			VARCHAR2(150)	:=  FND_API.g_MISS_CHAR
,  attribute9			VARCHAR2(150)	:=  FND_API.g_MISS_CHAR
,  attribute10			VARCHAR2(150)	:=  FND_API.g_MISS_CHAR
,  attribute11			VARCHAR2(150)	:=  FND_API.g_MISS_CHAR
,  attribute12			VARCHAR2(150)	:=  FND_API.g_MISS_CHAR
,  attribute13			VARCHAR2(150)	:=  FND_API.g_MISS_CHAR
,  attribute14			VARCHAR2(150)	:=  FND_API.g_MISS_CHAR
,  attribute15			VARCHAR2(150)	:=  FND_API.g_MISS_CHAR
,  creation_date		DATE		:=  FND_API.g_MISS_DATE
,  created_by			NUMBER		:=  FND_API.g_MISS_NUM
,  last_update_date		DATE		:=  FND_API.g_MISS_DATE
,  last_updated_by		NUMBER		:=  FND_API.g_MISS_NUM
,  last_update_login		NUMBER		:=  FND_API.g_MISS_NUM
,  request_id			NUMBER		:=  FND_API.g_MISS_NUM
,  program_application_id	NUMBER		:=  FND_API.g_MISS_NUM
,  program_id			NUMBER		:=  FND_API.g_MISS_NUM
,  program_update_date		DATE		:=  FND_API.g_MISS_DATE
,  object_version_number	NUMBER		:=  FND_API.g_MISS_NUM
);


--  ------------------- Variables representing missing values ------------------

g_Miss_Item_Revision_rec        Item_Revision_rec_type;


--  ============================================================================
--  Start of Comments
--
--  API Name:	Create_Item_Revision
--
--  Type:	Public
--
--  Pre-Req
--
--  Parameters
--
--   IN
--       p_api_version             IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--
--   IN OUT
--       p_Item_Revision_rec       IN OUT   Item_Revision_rec_type  Required
--
--  Version:	Current version 1.0
--
--  End of Comments
--  ============================================================================

PROCEDURE Create_Item_Revision
(
   p_api_version             IN   NUMBER
,  p_init_msg_list           IN   VARCHAR2   :=  FND_API.G_FALSE
,  p_commit                  IN   VARCHAR2   :=  FND_API.G_FALSE
,  p_validation_level        IN   NUMBER     :=  FND_API.G_VALID_LEVEL_FULL
,  x_return_status           OUT NOCOPY  VARCHAR2
,  x_msg_count               OUT NOCOPY  NUMBER
,  x_msg_data                OUT NOCOPY  VARCHAR2
,  p_Item_Revision_rec       IN   Item_Revision_rec_type
);

--  ============================================================================
--  Start of Comments
--
--  API Name:	Update_Item_Revision
--
--  Type:	Public
--
--  Pre-Req
--
--  Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_Item_Revision_rec       IN   Item_Revision_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--
--  Version:	Current version 1.0
--
--  End of Comments
--  ============================================================================

PROCEDURE Update_Item_Revision
(
   p_api_version             IN   NUMBER
,  p_init_msg_list           IN   VARCHAR2   :=  FND_API.g_FALSE
,  p_commit                  IN   VARCHAR2   :=  FND_API.g_FALSE
,  p_validation_level        IN   NUMBER     :=  FND_API.g_VALID_LEVEL_FULL
,  x_return_status           OUT NOCOPY  VARCHAR2
,  x_msg_count               OUT NOCOPY  NUMBER
,  x_msg_data                OUT NOCOPY  VARCHAR2
,  p_Item_Revision_rec       IN   Item_Revision_rec_type
);


--  ============================================================================
--  Start of Comments
--
--  API Name:	Delete_Item_Revision
--
--  Type:	Public
--
--  Pre-Req
--
--  Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_inventory_item_id       IN   NUMBER		Required
--       p_organization_id         IN   NUMBER		Required
--       p_revision                IN   VARCHAR2	Required
--       p_object_version_number   IN   NUMBER		Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--
--  Version:	Current version 1.0
--
--  End of Comments
--  ============================================================================

PROCEDURE Delete_Item_Revision
(
   p_api_version             IN   NUMBER
,  p_init_msg_list           IN   VARCHAR2   :=  FND_API.g_FALSE
,  p_commit                  IN   VARCHAR2   :=  FND_API.g_FALSE
,  p_validation_level        IN   NUMBER     :=  FND_API.g_VALID_LEVEL_FULL
,  x_return_status           OUT NOCOPY  VARCHAR2
,  x_msg_count               OUT NOCOPY  NUMBER
,  x_msg_data                OUT NOCOPY  VARCHAR2
,  p_inventory_item_id       IN   NUMBER
,  p_organization_id         IN   NUMBER
,  p_revision                IN   VARCHAR2
,  p_object_version_number   IN   NUMBER
);


END AMS_ITEM_REVISION_PUB;

 

/
