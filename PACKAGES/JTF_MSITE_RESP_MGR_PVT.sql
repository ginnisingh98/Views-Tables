--------------------------------------------------------
--  DDL for Package JTF_MSITE_RESP_MGR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_MSITE_RESP_MGR_PVT" AUTHID CURRENT_USER AS
/* $Header: JTFVMRMS.pls 115.1 2001/03/02 19:08:21 pkm ship      $ */

-- Cursors with data for mini-site
TYPE MSITE_CSR IS REF CURSOR;
TYPE MSITE_RESP_CSR IS REF CURSOR;
TYPE RESPONSIBILITY_CSR IS REF CURSOR;

PROCEDURE Associate_Resps_To_MSite
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_msite_id                       IN NUMBER,
   p_responsibility_ids             IN JTF_NUMBER_TABLE,
   p_application_ids                IN JTF_NUMBER_TABLE,
   p_start_date_actives             IN JTF_DATE_TABLE,
   p_end_date_actives               IN JTF_DATE_TABLE,
   p_sort_orders                    IN JTF_NUMBER_TABLE,
   p_display_names                  IN JTF_VARCHAR2_TABLE_300,
   x_msite_resp_ids                 OUT JTF_NUMBER_TABLE,
   x_duplicate_association_status   OUT JTF_VARCHAR2_TABLE_100,
   x_is_any_duplicate_status        OUT VARCHAR2,
   x_return_status                  OUT VARCHAR2,
   x_msg_count                      OUT NUMBER,
   x_msg_data                       OUT VARCHAR2
  );

PROCEDURE Update_Delete_Msite_Resps
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_msite_resp_ids                 IN JTF_NUMBER_TABLE,
   p_object_version_numbers         IN JTF_NUMBER_TABLE,
   p_start_date_actives             IN JTF_DATE_TABLE,
   p_end_date_actives               IN JTF_DATE_TABLE,
   p_sort_orders                    IN JTF_NUMBER_TABLE,
   p_display_names                  IN JTF_VARCHAR2_TABLE_300,
   p_delete_flags                   IN JTF_VARCHAR2_TABLE_100,
   x_return_status                  OUT VARCHAR2,
   x_msg_count                      OUT NUMBER,
   x_msg_data                       OUT VARCHAR2
  );

PROCEDURE Load_MsiteResps_For_Msite
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_msite_id                       IN NUMBER,
   p_application_id                 IN NUMBER,
   x_msite_csr                      OUT MSITE_CSR,
   x_msite_resp_csr                 OUT MSITE_RESP_CSR,
   x_return_status                  OUT VARCHAR2,
   x_msg_count                      OUT NUMBER,
   x_msg_data                       OUT VARCHAR2
  );

PROCEDURE Get_Resp_Appl_Id_List
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_query_criteria                 IN VARCHAR2,
   p_criteria_value_str             IN VARCHAR2,
   p_application_id                 IN NUMBER,
   x_responsibility_csr             OUT RESPONSIBILITY_CSR,
   x_return_status                  OUT VARCHAR2,
   x_msg_count                      OUT NUMBER,
   x_msg_data                       OUT VARCHAR2
  );

PROCEDURE Get_Resp_Appl_Info_For_Lookup
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_responsibility_ids             IN JTF_NUMBER_TABLE,
   p_application_ids                IN JTF_NUMBER_TABLE,
   x_responsibility_csr             OUT RESPONSIBILITY_CSR,
   x_return_status                  OUT VARCHAR2,
   x_msg_count                      OUT NUMBER,
   x_msg_data                       OUT VARCHAR2
  );

END Jtf_Msite_Resp_Mgr_Pvt;

 

/
