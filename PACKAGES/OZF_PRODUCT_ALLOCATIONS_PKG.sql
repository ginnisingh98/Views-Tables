--------------------------------------------------------
--  DDL for Package OZF_PRODUCT_ALLOCATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_PRODUCT_ALLOCATIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: ozftpals.pls 115.1 2003/11/18 23:54:37 mkothari noship $  */

---g_version	CONSTANT CHAR(80)    := '$Header: ozftpals.pls 115.1 2003/11/18 23:54:37 mkothari noship $';
   G_PKG_NAME   CONSTANT VARCHAR2(30):='OZF_PRODUCT_ALLOCATIONS_PKG';
   G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozftpals.pls';

   OZF_DEBUG_HIGH_ON CONSTANT BOOLEAN   := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
   OZF_DEBUG_MEDIUM_ON CONSTANT BOOLEAN := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);
   OZF_DEBUG_LOW_ON CONSTANT BOOLEAN    := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low);





--  ========================================================
--
--  NAME
--  Insert_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Insert_Row(
          px_product_allocation_id   IN OUT NOCOPY NUMBER,
          p_allocation_for                         VARCHAR2,
          p_allocation_for_id                      NUMBER,
          p_fund_id                                NUMBER,
          p_item_type                              VARCHAR2,
          p_item_id                                NUMBER,
          p_selected_flag                          VARCHAR2,
          p_target                                 NUMBER,
          p_lysp_sales                             NUMBER,
          p_parent_product_allocation_id           NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_creation_date                          DATE,
          p_created_by                             NUMBER,
          p_last_update_date                       DATE,
          p_last_updated_by                        NUMBER,
          p_last_update_login                      NUMBER,
          p_attribute_category                     VARCHAR2,
          p_attribute1                             VARCHAR2,
          p_attribute2                             VARCHAR2,
          p_attribute3                             VARCHAR2,
          p_attribute4                             VARCHAR2,
          p_attribute5                             VARCHAR2,
          p_attribute6                             VARCHAR2,
          p_attribute7                             VARCHAR2,
          p_attribute8                             VARCHAR2,
          p_attribute9                             VARCHAR2,
          p_attribute10                            VARCHAR2,
          p_attribute11                            VARCHAR2,
          p_attribute12                            VARCHAR2,
          p_attribute13                            VARCHAR2,
          p_attribute14                            VARCHAR2,
          p_attribute15                            VARCHAR2,
          px_org_id                  IN OUT NOCOPY NUMBER);



--  ========================================================
--
--  NAME
--  Update_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Update_Row(
          p_product_allocation_id                  NUMBER,
          p_allocation_for                         VARCHAR2,
          p_allocation_for_id                      NUMBER,
          p_fund_id                                NUMBER,
          p_item_type                              VARCHAR2,
          p_item_id                                NUMBER,
          p_selected_flag                          VARCHAR2,
          p_target                                 NUMBER,
          p_lysp_sales                             NUMBER,
          p_parent_product_allocation_id           NUMBER,
          p_object_version_number               IN NUMBER,
          p_last_update_date                       DATE,
          p_last_updated_by                        NUMBER,
          p_last_update_login                      NUMBER,
          p_attribute_category                     VARCHAR2,
          p_attribute1                             VARCHAR2,
          p_attribute2                             VARCHAR2,
          p_attribute3                             VARCHAR2,
          p_attribute4                             VARCHAR2,
          p_attribute5                             VARCHAR2,
          p_attribute6                             VARCHAR2,
          p_attribute7                             VARCHAR2,
          p_attribute8                             VARCHAR2,
          p_attribute9                             VARCHAR2,
          p_attribute10                            VARCHAR2,
          p_attribute11                            VARCHAR2,
          p_attribute12                            VARCHAR2,
          p_attribute13                            VARCHAR2,
          p_attribute14                            VARCHAR2,
          p_attribute15                            VARCHAR2);



--  ========================================================
--
--  NAME
--  Delete_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Delete_Row(
    p_product_allocation_id  NUMBER,
    p_object_version_number  NUMBER);




--  ========================================================
--
--  NAME
--  Lock_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Lock_Row(
    p_product_allocation_id  NUMBER,
    p_object_version_number  NUMBER);


END OZF_PRODUCT_ALLOCATIONS_PKG;

 

/
