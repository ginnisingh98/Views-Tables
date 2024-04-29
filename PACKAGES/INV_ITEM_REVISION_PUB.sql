--------------------------------------------------------
--  DDL for Package INV_ITEM_REVISION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_ITEM_REVISION_PUB" AUTHID CURRENT_USER AS
/* $Header: INVPREVS.pls 120.4.12010000.2 2009/07/13 12:07:19 jiabraha ship $ */

--  ============================================================================
--  Global variables and cursors
--  ============================================================================

G_FILE_NAME    CONSTANT  VARCHAR2(12)  :=  'INVPREVS.pls';

--  ============================================================================
--  Record Type:		Item_Revision_rec_type
--  ============================================================================

TYPE Item_Revision_rec_type IS RECORD
(
   inventory_item_id		NUMBER
,  organization_id		NUMBER
,  revision_id                  NUMBER
,  revision			VARCHAR2(3)
,  description			VARCHAR2(240)
,  change_notice		VARCHAR2(10)
,  ecn_initiation_date		DATE
,  implementation_date		DATE
,  effectivity_date		DATE
,  revised_item_sequence_id	NUMBER
,  attribute_category		VARCHAR2(30)
,  attribute1			VARCHAR2(150)
,  attribute2			VARCHAR2(150)
,  attribute3			VARCHAR2(150)
,  attribute4			VARCHAR2(150)
,  attribute5			VARCHAR2(150)
,  attribute6			VARCHAR2(150)
,  attribute7			VARCHAR2(150)
,  attribute8			VARCHAR2(150)
,  attribute9			VARCHAR2(150)
,  attribute10			VARCHAR2(150)
,  attribute11			VARCHAR2(150)
,  attribute12			VARCHAR2(150)
,  attribute13			VARCHAR2(150)
,  attribute14			VARCHAR2(150)
,  attribute15			VARCHAR2(150)
,  creation_date		DATE
,  created_by			NUMBER
,  last_update_date		DATE
,  last_updated_by		NUMBER
,  last_update_login		NUMBER
,  request_id			NUMBER
,  program_application_id	NUMBER
,  program_id			NUMBER
,  program_update_date		DATE
,  object_version_number	NUMBER
,  revision_label		VARCHAR2(80)
,  revision_reason		VARCHAR2(30)
,  lifecycle_id                 NUMBER
,  current_phase_id             NUMBER
,  template_id                  MTL_ITEM_TEMPLATES_B.TEMPLATE_ID%TYPE    --5208102
,  template_name                MTL_ITEM_TEMPLATES_TL.TEMPLATE_NAME%TYPE --5208102
,  return_status                VARCHAR2(1)
,  transaction_type             VARCHAR2(30)
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
,  p_process_control         IN   VARCHAR2   :=  NULL
,  x_return_status           OUT  NOCOPY VARCHAR2
,  x_msg_count               OUT  NOCOPY NUMBER
,  x_msg_data                OUT  NOCOPY VARCHAR2
,  p_Item_Revision_rec       IN OUT NOCOPY   Item_Revision_rec_type
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
--       p_process_control         IN   VARCHAR2   :=  NULL  To identify the caller Bug 5525054
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
,  p_process_control         IN   VARCHAR2   :=  NULL
,  x_return_status           OUT  NOCOPY VARCHAR2
,  x_msg_count               OUT  NOCOPY NUMBER
,  x_msg_data                OUT  NOCOPY VARCHAR2
,  p_Item_Revision_rec       IN OUT NOCOPY Item_Revision_rec_type
);


--  ============================================================================
--  Start of Comments
--
--  API Name:	Lock_Item_Revision
--
--  Type:	Public
--
--  Note:	For usage in Oracle Forms Apps only.
--
--  Pre-Req
--
--  Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER		Required
--       p_init_msg_list           IN   VARCHAR2	Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2	Optional  Default = FND_API.G_FALSE
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

PROCEDURE Lock_Item_Revision
(
   p_api_version             IN   NUMBER
,  p_init_msg_list           IN   VARCHAR2   :=  FND_API.g_FALSE
,  x_return_status           OUT  NOCOPY VARCHAR2
,  x_msg_count               OUT  NOCOPY NUMBER
,  x_msg_data                OUT  NOCOPY VARCHAR2
,  p_inventory_item_id       IN   NUMBER
,  p_organization_id         IN   NUMBER
,  p_revision                IN   VARCHAR2
,  p_object_version_number   IN   NUMBER
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
,  x_return_status           OUT  NOCOPY VARCHAR2
,  x_msg_count               OUT  NOCOPY NUMBER
,  x_msg_data                OUT  NOCOPY VARCHAR2
,  p_inventory_item_id       IN   NUMBER
,  p_organization_id         IN   NUMBER
,  p_revision                IN   VARCHAR2
,  p_object_version_number   IN   NUMBER
);

PROCEDURE Process_Item_Revision
(
   p_inventory_item_id            IN NUMBER
,  p_organization_id              IN NUMBER
,  p_revision                     IN VARCHAR2
,  p_description                  IN VARCHAR2 := NULL
,  p_change_notice                IN VARCHAR2 := NULL
,  p_ecn_initiation_date          IN DATE := NULL
,  p_implementation_date          IN DATE := NULL
,  p_effectivity_date             IN DATE := NULL
,  p_revised_item_sequence_id     IN NUMBER := NULL
,  p_attribute_category           IN VARCHAR2 := NULL
,  p_attribute1                   IN VARCHAR2 := NULL
,  p_attribute2                   IN VARCHAR2 := NULL
,  p_attribute3                   IN VARCHAR2 := NULL
,  p_attribute4                   IN VARCHAR2 := NULL
,  p_attribute5                   IN VARCHAR2 := NULL
,  p_attribute6                   IN VARCHAR2 := NULL
,  p_attribute7                   IN VARCHAR2 := NULL
,  p_attribute8                   IN VARCHAR2 := NULL
,  p_attribute9                   IN VARCHAR2 := NULL
,  p_attribute10                  IN VARCHAR2 := NULL
,  p_attribute11                  IN VARCHAR2 := NULL
,  p_attribute12                  IN VARCHAR2 := NULL
,  p_attribute13                  IN VARCHAR2 := NULL
,  p_attribute14                  IN VARCHAR2 := NULL
,  p_attribute15                  IN VARCHAR2 := NULL
,  p_object_version_number        IN NUMBER
,  p_revision_label		  IN VARCHAR2 := NULL
,  p_revision_reason		  IN VARCHAR2 := NULL
,  p_lifecycle_id                 IN NUMBER := NULL
,  p_current_phase_id             IN NUMBER := NULL
,  p_template_id                  IN NUMBER := NULL   --5208102
,  p_template_name                IN VARCHAR2 := NULL --5208102
,  p_language_code                IN VARCHAR2 := 'US'
,  p_transaction_type             IN VARCHAR2
,  p_message_API                  IN VARCHAR2 := 'FND'
,  p_init_msg_list                IN VARCHAR2 :=  FND_API.G_TRUE
,  x_Return_Status                OUT NOCOPY VARCHAR2
,  x_msg_count                    OUT NOCOPY NUMBER
,  x_msg_data					  OUT NOCOPY VARCHAR2 /*Added for bug 8634732 to ensure error message is displayed*/
,  x_revision_id                  IN OUT NOCOPY NUMBER
,  x_object_version_number        IN OUT NOCOPY NUMBER
,  p_debug                        IN  VARCHAR2 := 'N'
,  p_output_dir                   IN  VARCHAR2 := NULL
,  p_debug_filename               IN  VARCHAR2 := 'Ego_Item_Revision.log'
,  p_revision_id                  IN  NUMBER   := NULL
,  p_process_control              IN  VARCHAR2 := NULL
);


--  ============================================================================
--  Start of Comments
--
--  API Name:	Copy_Rev_UDA
--
--  Type:	Public
--
--  Pre-Req
--
--  Parameters
--
--   IN
--       p_organization_id         IN   NUMBER     Required
--       p_inventory_item_id       IN   NUMBER     Required
--       p_revision_id             IN   NUMBER     Required
--       p_revision                IN   VARCHAR2	 Required
--       p_source_revision_id      IN   NUMBER		 Optionsal Default NULL
--
--   OUT
--
--  Version:	Current version 1.0
--
--  End of Comments
--  ============================================================================
PROCEDURE Copy_Rev_UDA
(
    p_organization_id    IN NUMBER
  , p_inventory_item_id  IN NUMBER
  , p_revision_id        IN NUMBER
  , p_revision           IN VARCHAR2
  , p_source_revision_id IN NUMBER   DEFAULT NULL
);


END INV_ITEM_REVISION_PUB;

/
