--------------------------------------------------------
--  DDL for Package IBE_MSITE_PRTY_ACCSS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_MSITE_PRTY_ACCSS_PVT" AUTHID CURRENT_USER AS
/* $Header: IBEVMPRS.pls 115.1 2002/12/13 14:08:50 schak ship $ */

  -- HISTORY
  --   12/13/02           SCHAK         Modified for NOCOPY (Bug # 2691704)  Changes.
  -- *********************************************************************************

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
   x_msite_prty_accss_id            OUT NOCOPY NUMBER,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
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
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
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
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
  );

END Ibe_Msite_Prty_Accss_Pvt;

 

/
