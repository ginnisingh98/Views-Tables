--------------------------------------------------------
--  DDL for Package JTF_MSITE_PRTY_ACCSS_MGR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_MSITE_PRTY_ACCSS_MGR_PVT" AUTHID CURRENT_USER AS
/* $Header: JTFVMPMS.pls 115.2 2001/03/06 12:36:34 pkm ship      $ */

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
   x_msite_prty_accss_ids           OUT JTF_NUMBER_TABLE,
   x_duplicate_association_status   OUT JTF_VARCHAR2_TABLE_100,
   x_is_any_duplicate_status        OUT VARCHAR2,
   x_return_status                  OUT VARCHAR2,
   x_msg_count                      OUT NUMBER,
   x_msg_data                       OUT VARCHAR2
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
   x_return_status                  OUT VARCHAR2,
   x_msg_count                      OUT NUMBER,
   x_msg_data                       OUT VARCHAR2
  );

PROCEDURE Load_MsiteParties_For_Msite
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_msite_id                       IN NUMBER,
   x_party_access_code_csr          OUT PARTY_ACCESS_CODE_CSR,
   x_msite_csr                      OUT MSITE_CSR,
   x_msite_prty_accss_csr           OUT MSITE_PRTY_ACCSS_CSR,
   x_cust_account_csr               OUT CUST_ACCOUNT_CSR,
   x_return_status                  OUT VARCHAR2,
   x_msg_count                      OUT NUMBER,
   x_msg_data                       OUT VARCHAR2
  );

PROCEDURE Get_Party_Id_List
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_query_criteria                 IN VARCHAR2,
   p_criteria_value_str             IN VARCHAR2,
   x_party_csr                      OUT PARTY_CSR,
   x_return_status                  OUT VARCHAR2,
   x_msg_count                      OUT NUMBER,
   x_msg_data                       OUT VARCHAR2
  );

PROCEDURE Get_Party_Info_For_Lookup
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_party_ids                      IN JTF_NUMBER_TABLE,
   x_party_csr                      OUT PARTY_CSR,
   x_cust_account_csr               OUT CUST_ACCOUNT_CSR,
   x_return_status                  OUT VARCHAR2,
   x_msg_count                      OUT NUMBER,
   x_msg_data                       OUT VARCHAR2
  );

END Jtf_Msite_Prty_Accss_Mgr_Pvt;

 

/
