--------------------------------------------------------
--  DDL for Package AMS_ITEM_OWNERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_ITEM_OWNERS_PKG" AUTHID CURRENT_USER as
/* $Header: amstinvs.pls 115.6 2002/11/11 22:05:14 abhola ship $ */
-- Start of Comments
-- Package name     : AMS_ITEM_OWNERS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_ITEM_OWNER_ID   IN OUT NOCOPY NUMBER,
          px_OBJECT_VERSION_NUMBER   IN OUT NOCOPY NUMBER,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_ITEM_NUMBER    VARCHAR2,
          p_OWNER_ID    NUMBER,
          p_STATUS_CODE    VARCHAR2,
          p_EFFECTIVE_DATE    DATE,
	  p_IS_MASTER_ITEM VARCHAR2,
	  p_ITEM_SETUP_TYPE VARCHAR2 ,
          p_custom_setup_id NUMBER);

PROCEDURE Update_Row(
          p_ITEM_OWNER_ID    NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_ITEM_NUMBER    VARCHAR2,
          p_OWNER_ID    NUMBER,
          p_STATUS_CODE    VARCHAR2,
          p_EFFECTIVE_DATE    DATE,
	  p_IS_MASTER_ITEM  VARCHAR2,
	  p_ITEM_SETUP_TYPE VARCHAR2);

PROCEDURE Lock_Row(
          p_ITEM_OWNER_ID    NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_ITEM_NUMBER    VARCHAR2,
          p_OWNER_ID    NUMBER,
          p_STATUS_CODE    VARCHAR2,
          p_EFFECTIVE_DATE    DATE,
	p_IS_MASTER_ITEM  VARCHAR2,
	p_ITEM_SETUP_TYPE VARCHAR2);

PROCEDURE Delete_Row(
    p_ITEM_OWNER_ID  NUMBER);
End AMS_ITEM_OWNERS_PKG;

 

/
