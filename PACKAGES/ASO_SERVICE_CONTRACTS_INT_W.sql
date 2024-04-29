--------------------------------------------------------
--  DDL for Package ASO_SERVICE_CONTRACTS_INT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_SERVICE_CONTRACTS_INT_W" AUTHID CURRENT_USER as
  /* $Header: asovqwss.pls 120.1 2005/06/29 12:44:40 appldev ship $ */
  procedure rosetta_table_copy_in_p2(t OUT NOCOPY aso_service_contracts_int.order_service_tbl_type, a0 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p2(t aso_service_contracts_int.order_service_tbl_type, a0 OUT NOCOPY JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p4(t OUT NOCOPY aso_service_contracts_int.war_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_2000
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_DATE_TABLE
    );
  procedure rosetta_table_copy_out_p4(t aso_service_contracts_int.war_tbl_type, a0 OUT NOCOPY JTF_NUMBER_TABLE
    , a1 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , a2 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a3 OUT NOCOPY JTF_NUMBER_TABLE
    , a4 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a5 OUT NOCOPY JTF_NUMBER_TABLE
    , a6 OUT NOCOPY JTF_DATE_TABLE
    , a7 OUT NOCOPY JTF_DATE_TABLE
    );

  procedure available_services(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , p6_a0 OUT NOCOPY JTF_NUMBER_TABLE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  DATE := fnd_api.g_miss_date
  );
  procedure get_warranty(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p_org_id  NUMBER
    , p_organization_id  NUMBER
    , p_product_item_id  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , p8_a0 OUT NOCOPY JTF_NUMBER_TABLE
    , p8_a1 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , p8_a2 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , p8_a3 OUT NOCOPY JTF_NUMBER_TABLE
    , p8_a4 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , p8_a5 OUT NOCOPY JTF_NUMBER_TABLE
    , p8_a6 OUT NOCOPY JTF_DATE_TABLE
    , p8_a7 OUT NOCOPY JTF_DATE_TABLE
  );

  procedure GET_SERVICES (
     x_item_number_tbl    OUT NOCOPY JTF_VARCHAR2_TABLE_2000,
     x_item_desc_tbl      OUT NOCOPY JTF_VARCHAR2_TABLE_2000,
     x_start_date_tbl     OUT NOCOPY JTF_DATE_TABLE,
     x_duration_tbl       OUT NOCOPY JTF_NUMBER_TABLE,
     x_period_code_tbl    OUT NOCOPY JTF_VARCHAR2_TABLE_100,
     x_warranty_flag_tbl  OUT NOCOPY JTF_VARCHAR2_TABLE_100,
     p_source             IN VARCHAR2,
     p_source_id          IN NUMBER,
     p_api_version_number IN NUMBER,
     p_init_msg_list      IN VARCHAR2,
     x_return_status      OUT NOCOPY VARCHAR2,
     x_msg_count          OUT NOCOPY NUMBER,
     x_msg_data           OUT NOCOPY VARCHAR2);

  procedure is_service_available (
     p_api_version_number  IN NUMBER
   , p_init_msg_list       IN VARCHAR2
   , x_return_status       OUT NOCOPY VARCHAR2
   , x_msg_count           OUT NOCOPY  NUMBER
   , x_msg_data            OUT NOCOPY  VARCHAR2
   , p_product_item_id     IN Number
   , p_service_item_id     IN  Number
   , p_customer_id  	  IN Number
   , p_product_revision    IN Varchar2
   , p_request_date        IN Date
   , X_Available_YN        OUT NOCOPY /* file.sql.39 change */ varchar2);

  procedure available_services(
     x_Inventory_organization_id           OUT NOCOPY  JTF_NUMBER_TABLE
   , x_Service_item_id	                  OUT NOCOPY  JTF_NUMBER_TABLE
   , x_Concatenated_segments               OUT NOCOPY  JTF_VARCHAR2_TABLE_1000
   , x_Description                         OUT NOCOPY  JTF_VARCHAR2_TABLE_1000
   , x_Primary_uom_code                    OUT NOCOPY  JTF_VARCHAR2_TABLE_300
   , x_Serviceable_product_flag            OUT NOCOPY  JTF_VARCHAR2_TABLE_100
   , x_Service_item_flag                   OUT NOCOPY  JTF_VARCHAR2_TABLE_100
   , x_Bom_item_type                       OUT NOCOPY  JTF_NUMBER_TABLE
   , x_Item_type                           OUT NOCOPY  JTF_VARCHAR2_TABLE_1000
   , x_Service_duration                    OUT NOCOPY  JTF_NUMBER_TABLE
   , x_Service_duration_period_code        OUT NOCOPY  JTF_VARCHAR2_TABLE_1000
   , x_Shippable_item_flag                 OUT NOCOPY  JTF_VARCHAR2_TABLE_100
   , x_Returnable_flag                     OUT NOCOPY  JTF_VARCHAR2_TABLE_100
   , p_api_version_number                  IN NUMBER := 1.0
   , p_init_msg_list                       IN VARCHAR2 := FND_API.G_MISS_CHAR
   , p_commit                              IN VARCHAR2:= FND_API.g_false
   , p_search_input                        IN VARCHAR2 := FND_API.G_MISS_CHAR
   , p_product_item_id                     IN Number := FND_API.G_MISS_NUM
   , p_customer_id                         IN Number := FND_API.G_MISS_NUM
   , p_product_revision                    IN Varchar2 := FND_API.G_MISS_CHAR
   , p_request_date                        IN Date := FND_API.G_MISS_DATE
   , x_return_status                       OUT NOCOPY VARCHAR2
   , x_msg_count                           OUT NOCOPY  NUMBER
   , x_msg_data                            OUT NOCOPY  VARCHAR2);


end aso_service_contracts_int_w;


 

/
