--------------------------------------------------------
--  DDL for Package IBE_MSITE_PRTY_ACCSS_MGR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_MSITE_PRTY_ACCSS_MGR_PVT" AUTHID CURRENT_USER AS
/* $Header: IBEVMPMS.pls 115.3 2003/05/05 23:25:23 jqu ship $ */

  -- HISTORY
  --   12/13/02           SCHAK         Modified for NOCOPY (Bug # 2691704)  Changes.
  --   01/10/03           JQU           Delete procedure Get_Party_Id_List for bug 2699536
  --   05/05/03           JQU           Delete procedure Get_Party_Info_For_Lookup for performance bug 2935856
  -- *********************************************************************************

-- Cursors with data for mini-site
TYPE MSITE_CSR IS REF CURSOR;
TYPE MSITE_PRTY_ACCSS_CSR IS REF CURSOR;
TYPE PARTY_CSR IS REF CURSOR;
TYPE PARTY_ACCESS_CODE_CSR IS REF CURSOR;
TYPE CUST_ACCOUNT_CSR IS REF CURSOR;

PROCEDURE Associate_Parties_To_MSite
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_msite_id                       IN NUMBER,
   p_party_ids                      IN JTF_NUMBER_TABLE,
   p_start_date_actives             IN JTF_DATE_TABLE,
   p_end_date_actives               IN JTF_DATE_TABLE,
   x_msite_prty_accss_ids           OUT NOCOPY JTF_NUMBER_TABLE,
   x_duplicate_association_status   OUT NOCOPY JTF_VARCHAR2_TABLE_100,
   x_is_any_duplicate_status        OUT NOCOPY VARCHAR2,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  );

PROCEDURE Update_Delete_Msite_Prty
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_msite_prty_accss_ids           IN JTF_NUMBER_TABLE,
   p_object_version_numbers         IN JTF_NUMBER_TABLE,
   p_msite_ids                      IN JTF_NUMBER_TABLE,
   p_party_ids                      IN JTF_NUMBER_TABLE,
   p_start_date_actives             IN JTF_DATE_TABLE,
   p_end_date_actives               IN JTF_DATE_TABLE,
   p_delete_flags                   IN JTF_VARCHAR2_TABLE_100,
   p_msite_id                       IN NUMBER,
   p_party_access_code              IN VARCHAR2,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  );

PROCEDURE Load_MsiteParties_For_Msite
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_msite_id                       IN NUMBER,
   x_party_access_code_csr          OUT NOCOPY PARTY_ACCESS_CODE_CSR,
   x_msite_csr                      OUT NOCOPY MSITE_CSR,
   x_msite_prty_accss_csr           OUT NOCOPY MSITE_PRTY_ACCSS_CSR,
   x_cust_account_csr               OUT NOCOPY CUST_ACCOUNT_CSR,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  );

END Ibe_Msite_Prty_Accss_Mgr_Pvt;

 

/
