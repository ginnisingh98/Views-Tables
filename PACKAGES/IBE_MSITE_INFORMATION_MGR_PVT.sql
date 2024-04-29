--------------------------------------------------------
--  DDL for Package IBE_MSITE_INFORMATION_MGR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_MSITE_INFORMATION_MGR_PVT" AUTHID CURRENT_USER AS
/* $Header: IBEVMIMS.pls 115.3 2003/08/20 16:09:56 jshang ship $ */

  -- HISTORY
  --   12/13/02           SCHAK          Modified for NOCOPY (Bug # 2691704) Changes.
  -- *********************************************************************************

-- Cursors with data for mini-site
TYPE MSITE_CSR IS REF CURSOR;
TYPE MSITE_INFO_CSR IS REF CURSOR;

PROCEDURE Change_Msite_Info
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_operation_flags                IN JTF_VARCHAR2_TABLE_100,
   p_msite_information_ids          IN JTF_NUMBER_TABLE,
   p_object_version_numbers         IN JTF_NUMBER_TABLE,
   p_msite_ids                      IN JTF_NUMBER_TABLE,
   p_msite_information_contexts     IN JTF_VARCHAR2_TABLE_100,
   p_msite_informations1            IN JTF_VARCHAR2_TABLE_300,
   p_msite_informations2            IN JTF_VARCHAR2_TABLE_300,
   p_msite_informations3            IN JTF_VARCHAR2_TABLE_300,
   p_msite_informations4            IN JTF_VARCHAR2_TABLE_300,
   p_msite_informations5            IN JTF_VARCHAR2_TABLE_300,
   p_msite_informations6            IN JTF_VARCHAR2_TABLE_300,
   p_msite_informations7            IN JTF_VARCHAR2_TABLE_300,
   p_msite_informations8            IN JTF_VARCHAR2_TABLE_300,
   p_msite_informations9            IN JTF_VARCHAR2_TABLE_300,
   p_msite_informations10           IN JTF_VARCHAR2_TABLE_300,
   p_msite_informations11           IN JTF_VARCHAR2_TABLE_300,
   p_msite_informations12           IN JTF_VARCHAR2_TABLE_300,
   p_msite_informations13           IN JTF_VARCHAR2_TABLE_300,
   p_msite_informations14           IN JTF_VARCHAR2_TABLE_300,
   p_msite_informations15           IN JTF_VARCHAR2_TABLE_300,
   p_msite_informations16           IN JTF_VARCHAR2_TABLE_300,
   p_msite_informations17           IN JTF_VARCHAR2_TABLE_300,
   p_msite_informations18           IN JTF_VARCHAR2_TABLE_300,
   p_msite_informations19           IN JTF_VARCHAR2_TABLE_300,
   p_msite_informations20           IN JTF_VARCHAR2_TABLE_300,
   p_attribute_categorys            IN JTF_VARCHAR2_TABLE_100,
   p_attributes1                    IN JTF_VARCHAR2_TABLE_300,
   p_attributes2                    IN JTF_VARCHAR2_TABLE_300,
   p_attributes3                    IN JTF_VARCHAR2_TABLE_300,
   p_attributes4                    IN JTF_VARCHAR2_TABLE_300,
   p_attributes5                    IN JTF_VARCHAR2_TABLE_300,
   p_attributes6                    IN JTF_VARCHAR2_TABLE_300,
   p_attributes7                    IN JTF_VARCHAR2_TABLE_300,
   p_attributes8                    IN JTF_VARCHAR2_TABLE_300,
   p_attributes9                    IN JTF_VARCHAR2_TABLE_300,
   p_attributes10                   IN JTF_VARCHAR2_TABLE_300,
   p_attributes11                   IN JTF_VARCHAR2_TABLE_300,
   p_attributes12                   IN JTF_VARCHAR2_TABLE_300,
   p_attributes13                   IN JTF_VARCHAR2_TABLE_300,
   p_attributes14                   IN JTF_VARCHAR2_TABLE_300,
   p_attributes15                   IN JTF_VARCHAR2_TABLE_300,
   x_msite_information_ids          OUT NOCOPY JTF_NUMBER_TABLE,
   x_msite_info_return_statuses     OUT NOCOPY JTF_VARCHAR2_TABLE_100,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  );

PROCEDURE Load_MsiteInformation
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_msite_id                       IN NUMBER,
   p_msite_information_context      IN VARCHAR2,
   x_msite_csr                      OUT NOCOPY MSITE_CSR,
   x_msite_information_csr          OUT NOCOPY MSITE_INFO_CSR,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  );

PROCEDURE duplicate_msite_info(
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_source_msite_id                IN NUMBER,
   p_target_msite_id                IN NUMBER,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  );

END Ibe_Msite_Information_Mgr_Pvt;

 

/
