--------------------------------------------------------
--  DDL for Package PV_PRGM_PTR_TYPES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_PRGM_PTR_TYPES_PVT_W" AUTHID CURRENT_USER as
  /* $Header: pvxwprps.pls 115.2 2002/11/27 22:09:33 ktsao ship $ */
  procedure rosetta_table_copy_in_p2(t OUT NOCOPY pv_prgm_ptr_types_pvt.prgm_ptr_types_rec_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p2(t pv_prgm_ptr_types_pvt.prgm_ptr_types_rec_tbl_type, a0 OUT NOCOPY JTF_NUMBER_TABLE
    , a1 OUT NOCOPY JTF_NUMBER_TABLE
    , a2 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a3 OUT NOCOPY JTF_DATE_TABLE
    , a4 OUT NOCOPY JTF_NUMBER_TABLE
    , a5 OUT NOCOPY JTF_DATE_TABLE
    , a6 OUT NOCOPY JTF_NUMBER_TABLE
    , a7 OUT NOCOPY JTF_NUMBER_TABLE
    , a8 OUT NOCOPY JTF_NUMBER_TABLE
    );

  procedure create_prgm_ptr_type(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  DATE
    , p7_a4  NUMBER
    , p7_a5  DATE
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , x_program_partner_types_id OUT NOCOPY  NUMBER
  );
  procedure update_prgm_ptr_type(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  DATE
    , p7_a4  NUMBER
    , p7_a5  DATE
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  NUMBER
  );
  procedure validate_prgm_ptr_type(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_validation_mode  VARCHAR2
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  VARCHAR2
    , p4_a3  DATE
    , p4_a4  NUMBER
    , p4_a5  DATE
    , p4_a6  NUMBER
    , p4_a7  NUMBER
    , p4_a8  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
  );
  procedure check_items(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  VARCHAR2
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  DATE
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
  );
  procedure validate_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  DATE
    , p5_a4  NUMBER
    , p5_a5  DATE
    , p5_a6  NUMBER
    , p5_a7  NUMBER
    , p5_a8  NUMBER
  );
  procedure complete_rec(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  VARCHAR2
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  DATE
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p1_a0 OUT NOCOPY  NUMBER
    , p1_a1 OUT NOCOPY  NUMBER
    , p1_a2 OUT NOCOPY  VARCHAR2
    , p1_a3 OUT NOCOPY  DATE
    , p1_a4 OUT NOCOPY  NUMBER
    , p1_a5 OUT NOCOPY  DATE
    , p1_a6 OUT NOCOPY  NUMBER
    , p1_a7 OUT NOCOPY  NUMBER
    , p1_a8 OUT NOCOPY  NUMBER
  );
end pv_prgm_ptr_types_pvt_w;

 

/
