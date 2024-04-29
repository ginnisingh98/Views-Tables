--------------------------------------------------------
--  DDL for Package EGO_ITEM_STATUSES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_ITEM_STATUSES_PUB" AUTHID CURRENT_USER AS
/* $Header: EGOITEMSTATUSS.pls 120.0 2005/05/26 21:38:24 appldev noship $ */

PROCEDURE Create_Item_Status(
    p_api_version                 IN   NUMBER
  , p_item_status_code            IN   VARCHAR2
  , p_item_status_code_tl         IN   VARCHAR2
  , p_description                 IN   VARCHAR2
  , p_inactive_date               IN   VARCHAR2
  , p_attribute1                  IN   VARCHAR2
  , p_attribute2                  IN   VARCHAR2
  , p_attribute3                  IN   VARCHAR2
  , p_attribute4                  IN   VARCHAR2
  , p_attribute5                  IN   VARCHAR2
  , p_attribute6                  IN   VARCHAR2
  , p_attribute7                  IN   VARCHAR2
  , p_attribute8                  IN   VARCHAR2
  , p_attribute9                  IN   VARCHAR2
  , p_attribute10                  IN   VARCHAR2
  , p_attribute11                  IN   VARCHAR2
  , p_attribute12                  IN   VARCHAR2
  , p_attribute13                  IN   VARCHAR2
  , p_attribute14                  IN   VARCHAR2
  , p_attribute15                  IN   VARCHAR2
  , p_attribute_category           IN   VARCHAR2
  , p_init_msg_list               IN   VARCHAR2   := fnd_api.g_FALSE
  , p_commit                      IN   VARCHAR2   := fnd_api.g_FALSE
  , x_return_status               OUT  NOCOPY VARCHAR2
  , x_errorcode                   OUT  NOCOPY NUMBER
  , x_msg_count                   OUT  NOCOPY NUMBER
  , x_msg_data                    OUT  NOCOPY VARCHAR2
);

PROCEDURE Update_Item_Status(
    p_api_version                 IN   NUMBER
  , p_item_status_code            IN   VARCHAR2
  , p_item_status_code_tl         IN   VARCHAR2
  , p_description                 IN   VARCHAR2
  , p_inactive_date               IN   VARCHAR2
  , p_attribute1                  IN   VARCHAR2
  , p_attribute2                  IN   VARCHAR2
  , p_attribute3                  IN   VARCHAR2
  , p_attribute4                  IN   VARCHAR2
  , p_attribute5                  IN   VARCHAR2
  , p_attribute6                  IN   VARCHAR2
  , p_attribute7                  IN   VARCHAR2
  , p_attribute8                  IN   VARCHAR2
  , p_attribute9                  IN   VARCHAR2
  , p_attribute10                  IN   VARCHAR2
  , p_attribute11                  IN   VARCHAR2
  , p_attribute12                  IN   VARCHAR2
  , p_attribute13                  IN   VARCHAR2
  , p_attribute14                  IN   VARCHAR2
  , p_attribute15                  IN   VARCHAR2
  , p_attribute_category           IN   VARCHAR2
  , p_init_msg_list               IN   VARCHAR2   := fnd_api.g_FALSE
  , p_commit                      IN   VARCHAR2   := fnd_api.g_FALSE
  , x_return_status               OUT  NOCOPY VARCHAR2
  , x_errorcode                   OUT  NOCOPY NUMBER
  , x_msg_count                   OUT  NOCOPY NUMBER
  , x_msg_data                    OUT  NOCOPY VARCHAR2
);

PROCEDURE Create_Item_Status_Attr_Values(
    p_api_version                 IN   NUMBER
  , p_item_status_code            IN   VARCHAR2
  , p_attribute_name              IN   VARCHAR2
  , p_attribute_value             IN   VARCHAR2
  , p_init_msg_list               IN   VARCHAR2   := fnd_api.g_FALSE
  , p_commit                      IN   VARCHAR2   := fnd_api.g_FALSE
  , x_return_status               OUT  NOCOPY VARCHAR2
  , x_errorcode                   OUT  NOCOPY NUMBER
  , x_msg_count                   OUT  NOCOPY NUMBER
  , x_msg_data                    OUT  NOCOPY VARCHAR2
);

PROCEDURE Update_Item_Status_Attr_Values(
    p_api_version                 IN   NUMBER
  , p_item_status_code            IN   VARCHAR2
  , p_attribute_name              IN   VARCHAR2
  , p_attribute_value             IN   VARCHAR2
  , p_init_msg_list               IN   VARCHAR2   := fnd_api.g_FALSE
  , p_commit                      IN   VARCHAR2   := fnd_api.g_FALSE
  , x_return_status               OUT  NOCOPY VARCHAR2
  , x_errorcode                   OUT  NOCOPY NUMBER
  , x_msg_count                   OUT  NOCOPY NUMBER
  , x_msg_data                    OUT  NOCOPY VARCHAR2
);

END EGO_ITEM_STATUSES_PUB;

 

/
