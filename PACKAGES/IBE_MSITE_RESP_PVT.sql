--------------------------------------------------------
--  DDL for Package IBE_MSITE_RESP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_MSITE_RESP_PVT" AUTHID CURRENT_USER AS
/* $Header: IBEVMRSS.pls 120.0.12010000.3 2016/10/18 19:57:22 ytian ship $ */



PROCEDURE Create_Msite_Resp
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_msite_resp_id		    IN NUMBER   := FND_API.G_MISS_NUM,
   p_msite_id                       IN NUMBER,
   p_responsibility_id              IN NUMBER,
   p_application_id                 IN NUMBER,
   p_start_date_active              IN DATE,
   p_end_date_active                IN DATE     := FND_API.G_MISS_DATE,
   p_sort_order                     IN NUMBER   := FND_API.G_MISS_NUM,
   p_display_name                   IN VARCHAR2,
   p_group_code                     IN VARCHAR2 default null,
   x_msite_resp_id                  OUT NOCOPY NUMBER,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  );

PROCEDURE Create_Msite_Resp
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_msite_resp_id		    IN NUMBER   := FND_API.G_MISS_NUM,
   p_msite_id                       IN NUMBER,
   p_responsibility_id              IN NUMBER,
   p_application_id                 IN NUMBER,
   p_start_date_active              IN DATE,
   p_end_date_active                IN DATE     := FND_API.G_MISS_DATE,
   p_sort_order                     IN NUMBER   := FND_API.G_MISS_NUM,
   p_display_name                   IN VARCHAR2,
   p_group_code                     IN VARCHAR2 default null,
   p_ordertype_id                     IN NUMBER,
   x_msite_resp_id                  OUT NOCOPY NUMBER,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  );

PROCEDURE Update_Msite_Resp
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_msite_resp_id                  IN NUMBER   := FND_API.G_MISS_NUM,
   p_object_version_number          IN NUMBER,
   p_msite_id                       IN NUMBER   := FND_API.G_MISS_NUM,
   p_responsibility_id              IN NUMBER   := FND_API.G_MISS_NUM,
   p_application_id                 IN NUMBER   := FND_API.G_MISS_NUM,
   p_start_date_active              IN DATE     := FND_API.G_MISS_DATE,
   p_end_date_active                IN DATE     := FND_API.G_MISS_DATE,
   p_sort_order                     IN NUMBER   := FND_API.G_MISS_NUM,
   p_display_name                   IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_group_code                     IN VARCHAR2 default null,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  );

PROCEDURE Update_Msite_Resp
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_msite_resp_id                  IN NUMBER   := FND_API.G_MISS_NUM,
   p_object_version_number          IN NUMBER,
   p_msite_id                       IN NUMBER   := FND_API.G_MISS_NUM,
   p_responsibility_id              IN NUMBER   := FND_API.G_MISS_NUM,
   p_application_id                 IN NUMBER   := FND_API.G_MISS_NUM,
   p_start_date_active              IN DATE     := FND_API.G_MISS_DATE,
   p_end_date_active                IN DATE     := FND_API.G_MISS_DATE,
   p_sort_order                     IN NUMBER   := FND_API.G_MISS_NUM,
   p_display_name                   IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_group_code                     IN VARCHAR2 default null,
   p_order_type_id                  IN NUMBER,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  );


PROCEDURE Delete_Msite_Resp
  (
   p_api_version                 IN NUMBER,
   p_init_msg_list               IN VARCHAR2    := FND_API.G_FALSE,
   p_commit                      IN VARCHAR2    := FND_API.G_FALSE,
   p_validation_level            IN NUMBER      := FND_API.G_VALID_LEVEL_FULL,
   p_msite_resp_id               IN NUMBER      := FND_API.G_MISS_NUM,
   p_msite_id                    IN NUMBER      := FND_API.G_MISS_NUM,
   p_responsibility_id           IN NUMBER      := FND_API.G_MISS_NUM,
   p_application_id              IN NUMBER      := FND_API.G_MISS_NUM,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
  );

PROCEDURE Delete_Msite_Resp_Group
  (
   p_api_version                 IN NUMBER,
   p_init_msg_list               IN VARCHAR2    := FND_API.G_FALSE,
   p_commit                      IN VARCHAR2    := FND_API.G_FALSE,
   p_validation_level            IN NUMBER      := FND_API.G_VALID_LEVEL_FULL,
   p_msite_resp_id               IN NUMBER      := FND_API.G_MISS_NUM,
   p_msite_id                    IN NUMBER      := FND_API.G_MISS_NUM,
   p_responsibility_id           IN NUMBER      := FND_API.G_MISS_NUM,
   p_application_id              IN NUMBER      := FND_API.G_MISS_NUM,
   p_group_code                  IN VARCHAR2 default null,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
  );


END Ibe_Msite_Resp_Pvt;

/
