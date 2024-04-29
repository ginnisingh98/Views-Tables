--------------------------------------------------------
--  DDL for Package CSI_SOURCE_IB_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_SOURCE_IB_TYPES_PKG" AUTHID CURRENT_USER as
/* $Header: csitsits.pls 115.2 2002/11/12 00:23:38 rmamidip noship $ */
-- Start of Comments
-- Package name     : CSI_SOURCE_IB_TYPES_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          p_TRANSACTION_TYPE_ID    NUMBER,
          px_SUB_TYPE_ID   IN OUT NOCOPY NUMBER,
          p_DEFAULT_FLAG    VARCHAR2,
          p_UPDATE_IB_FLAG    VARCHAR2);

PROCEDURE Update_Row(
          p_TRANSACTION_TYPE_ID    NUMBER,
          p_SUB_TYPE_ID    NUMBER,
          p_DEFAULT_FLAG    VARCHAR2,
          p_UPDATE_IB_FLAG    VARCHAR2);

PROCEDURE Lock_Row(
          p_TRANSACTION_TYPE_ID    NUMBER,
          p_SUB_TYPE_ID    NUMBER,
          p_DEFAULT_FLAG    VARCHAR2,
          p_UPDATE_IB_FLAG    VARCHAR2);

PROCEDURE Delete_Row(
    p_SUB_TYPE_ID  NUMBER);
End CSI_SOURCE_IB_TYPES_PKG;

 

/
