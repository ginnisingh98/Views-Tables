--------------------------------------------------------
--  DDL for Package IBE_MSITE_RESP_MGR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_MSITE_RESP_MGR_PVT" AUTHID CURRENT_USER AS
/* $Header: IBEVMRMS.pls 120.0.12010000.3 2016/10/18 19:59:52 ytian ship $ */

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
   x_msite_resp_ids                 OUT NOCOPY JTF_NUMBER_TABLE,
   x_duplicate_association_status   OUT NOCOPY JTF_VARCHAR2_TABLE_100,
   x_is_any_duplicate_status        OUT NOCOPY VARCHAR2,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  );

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
   p_ordertype_ids                  IN JTF_NUMBER_TABLE,
   x_msite_resp_ids                 OUT NOCOPY JTF_NUMBER_TABLE,
   x_duplicate_association_status   OUT NOCOPY JTF_VARCHAR2_TABLE_100,
   x_is_any_duplicate_status        OUT NOCOPY VARCHAR2,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
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
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  );

PROCEDURE Update_Delete_Msite_Resps
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_msite_resp_ids                 IN JTF_NUMBER_TABLE,
   p_msite_ids 			    IN JTF_NUMBER_TABLE,
   p_responsibility_ids 	    IN JTF_NUMBER_TABLE,
   p_application_ids		    IN JTF_NUMBER_TABLE,
   p_object_version_numbers         IN JTF_NUMBER_TABLE,
   p_start_date_actives             IN JTF_DATE_TABLE,
   p_end_date_actives               IN JTF_DATE_TABLE,
   p_sort_orders                    IN JTF_NUMBER_TABLE,
   p_display_names                  IN JTF_VARCHAR2_TABLE_300,
   p_group_codes                    IN JTF_VARCHAR2_TABLE_300,
   p_delete_flags                   IN JTF_VARCHAR2_TABLE_100,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
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
   p_order_type_ids                  IN JTF_NUMBER_TABLE,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  );


PROCEDURE Load_MsiteResps_For_Msite
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_msite_id                       IN NUMBER,
   p_application_id                 IN NUMBER,
   x_msite_csr                      OUT NOCOPY MSITE_CSR,
   x_msite_resp_csr                 OUT NOCOPY MSITE_RESP_CSR,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  );


PROCEDURE Update_Msite_Resps
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_msite_resp_ids                 IN JTF_NUMBER_TABLE,
   p_object_version_numbers         IN JTF_NUMBER_TABLE,
   p_sort_orders                    IN JTF_NUMBER_TABLE,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  );

END Ibe_Msite_Resp_Mgr_Pvt;

/
