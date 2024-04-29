--------------------------------------------------------
--  DDL for Package JTF_MSITE_RESP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_MSITE_RESP_PVT" AUTHID CURRENT_USER AS
/* $Header: JTFVMRSS.pls 115.2 2002/02/14 05:49:41 appldev ship $ */

PROCEDURE Create_Msite_Resp
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_msite_id                       IN NUMBER,
   p_responsibility_id              IN NUMBER,
   p_application_id                 IN NUMBER,
   p_start_date_active              IN DATE,
   p_end_date_active                IN DATE     := FND_API.G_MISS_DATE,
   p_sort_order                     IN NUMBER   := FND_API.G_MISS_NUM,
   p_display_name                   IN VARCHAR2,
   x_msite_resp_id                  OUT NUMBER,
   x_return_status                  OUT VARCHAR2,
   x_msg_count                      OUT NUMBER,
   x_msg_data                       OUT VARCHAR2
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
   x_return_status                  OUT VARCHAR2,
   x_msg_count                      OUT NUMBER,
   x_msg_data                       OUT VARCHAR2
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
   x_return_status               OUT VARCHAR2,
   x_msg_count                   OUT NUMBER,
   x_msg_data                    OUT VARCHAR2
  );

END Jtf_Msite_Resp_Pvt;

 

/
