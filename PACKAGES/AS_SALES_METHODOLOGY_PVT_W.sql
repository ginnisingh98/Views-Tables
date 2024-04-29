--------------------------------------------------------
--  DDL for Package AS_SALES_METHODOLOGY_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_SALES_METHODOLOGY_PVT_W" AUTHID CURRENT_USER as
  /* $Header: asxsmws.pls 120.1 2005/06/17 02:59 appldev  $ */
  procedure create_sales_methodology(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validate_level  VARCHAR2
    , p_sales_methodology_name  VARCHAR2
    , p_start_date_active  date
    , p_end_date_active  date
    , p_autocreatetask_flag  VARCHAR2
    , p_description  VARCHAR2
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , p_attribute11  VARCHAR2
    , p_attribute12  VARCHAR2
    , p_attribute13  VARCHAR2
    , p_attribute14  VARCHAR2
    , p_attribute15  VARCHAR2
    , p_attribute_category  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_sales_methodology_id out nocopy  NUMBER
  );
  procedure update_sales_methodology(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validate_level  VARCHAR2
    , p_sales_methodology_id  NUMBER
    , p_sales_methodology_name  VARCHAR2
    , p_start_date_active  date
    , p_end_date_active  date
    , p_autocreatetask_flag  VARCHAR2
    , p_description  VARCHAR2
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , p_attribute11  VARCHAR2
    , p_attribute12  VARCHAR2
    , p_attribute13  VARCHAR2
    , p_attribute14  VARCHAR2
    , p_attribute15  VARCHAR2
    , p_attribute_category  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_object_version_number in out nocopy  NUMBER
  );
end as_sales_methodology_pvt_w;

 

/
