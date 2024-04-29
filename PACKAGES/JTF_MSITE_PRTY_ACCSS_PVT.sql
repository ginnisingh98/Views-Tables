--------------------------------------------------------
--  DDL for Package JTF_MSITE_PRTY_ACCSS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_MSITE_PRTY_ACCSS_PVT" AUTHID CURRENT_USER AS
/* $Header: JTFVMPRS.pls 115.1 2001/03/02 19:08:12 pkm ship      $ */

PROCEDURE Create_Msite_Prty_Accss
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_msite_id                       IN NUMBER,
   p_party_id                       IN NUMBER,
   p_start_date_active              IN DATE,
   p_end_date_active                IN DATE     := FND_API.G_MISS_DATE,
   x_msite_prty_accss_id            OUT NUMBER,
   x_return_status                  OUT VARCHAR2,
   x_msg_count                      OUT NUMBER,
   x_msg_data                       OUT VARCHAR2
  );

PROCEDURE Update_Msite_Prty_Accss
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_msite_prty_accss_id            IN NUMBER   := FND_API.G_MISS_NUM,
   p_object_version_number          IN NUMBER,
   p_msite_id                       IN NUMBER   := FND_API.G_MISS_NUM,
   p_party_id                       IN NUMBER   := FND_API.G_MISS_NUM,
   p_start_date_active              IN DATE     := FND_API.G_MISS_DATE,
   p_end_date_active                IN DATE     := FND_API.G_MISS_DATE,
   x_return_status                  OUT VARCHAR2,
   x_msg_count                      OUT NUMBER,
   x_msg_data                       OUT VARCHAR2
  );

PROCEDURE Delete_Msite_Prty_Accss
  (
   p_api_version                 IN NUMBER,
   p_init_msg_list               IN VARCHAR2    := FND_API.G_FALSE,
   p_commit                      IN VARCHAR2    := FND_API.G_FALSE,
   p_validation_level            IN NUMBER      := FND_API.G_VALID_LEVEL_FULL,
   p_msite_prty_accss_id         IN NUMBER      := FND_API.G_MISS_NUM,
   p_msite_id                    IN NUMBER      := FND_API.G_MISS_NUM,
   p_party_id                    IN NUMBER      := FND_API.G_MISS_NUM,
   x_return_status               OUT VARCHAR2,
   x_msg_count                   OUT NUMBER,
   x_msg_data                    OUT VARCHAR2
  );

END Jtf_Msite_Prty_Accss_Pvt;

 

/
