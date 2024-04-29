--------------------------------------------------------
--  DDL for Package AMS_ACTPRODUCT_PVT_OA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_ACTPRODUCT_PVT_OA" AUTHID CURRENT_USER as
  /* $Header: amsaacps.pls 120.0 2005/08/31 09:45 gramanat noship $ */
  procedure create_act_product(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  DATE
    , p7_a2  NUMBER
    , p7_a3  DATE
    , p7_a4  NUMBER
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  NUMBER
    , p7_a14  NUMBER
    , p7_a15  NUMBER
    , p7_a16  NUMBER
    , p7_a17  VARCHAR2
    , p7_a18  NUMBER
    , p7_a19  NUMBER
    , p7_a20  VARCHAR2
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  NUMBER
    , p7_a37  VARCHAR2
    , p7_a38  NUMBER
    , p7_a39  NUMBER
    , p7_a40  NUMBER
    , p7_a41  VARCHAR2
    , x_act_product_id out nocopy  NUMBER
  );
  procedure update_act_product(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  DATE
    , p7_a2  NUMBER
    , p7_a3  DATE
    , p7_a4  NUMBER
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  NUMBER
    , p7_a14  NUMBER
    , p7_a15  NUMBER
    , p7_a16  NUMBER
    , p7_a17  VARCHAR2
    , p7_a18  NUMBER
    , p7_a19  NUMBER
    , p7_a20  VARCHAR2
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  NUMBER
    , p7_a37  VARCHAR2
    , p7_a38  NUMBER
    , p7_a39  NUMBER
    , p7_a40  NUMBER
    , p7_a41  VARCHAR2
  );
  procedure validate_act_product(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  DATE
    , p6_a2  NUMBER
    , p6_a3  DATE
    , p6_a4  NUMBER
    , p6_a5  NUMBER
    , p6_a6  NUMBER
    , p6_a7  NUMBER
    , p6_a8  VARCHAR2
    , p6_a9  VARCHAR2
    , p6_a10  VARCHAR2
    , p6_a11  VARCHAR2
    , p6_a12  VARCHAR2
    , p6_a13  NUMBER
    , p6_a14  NUMBER
    , p6_a15  NUMBER
    , p6_a16  NUMBER
    , p6_a17  VARCHAR2
    , p6_a18  NUMBER
    , p6_a19  NUMBER
    , p6_a20  VARCHAR2
    , p6_a21  VARCHAR2
    , p6_a22  VARCHAR2
    , p6_a23  VARCHAR2
    , p6_a24  VARCHAR2
    , p6_a25  VARCHAR2
    , p6_a26  VARCHAR2
    , p6_a27  VARCHAR2
    , p6_a28  VARCHAR2
    , p6_a29  VARCHAR2
    , p6_a30  VARCHAR2
    , p6_a31  VARCHAR2
    , p6_a32  VARCHAR2
    , p6_a33  VARCHAR2
    , p6_a34  VARCHAR2
    , p6_a35  VARCHAR2
    , p6_a36  NUMBER
    , p6_a37  VARCHAR2
    , p6_a38  NUMBER
    , p6_a39  NUMBER
    , p6_a40  NUMBER
    , p6_a41  VARCHAR2
  );
  procedure validate_act_product_items(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  VARCHAR2
    , p0_a9  VARCHAR2
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  NUMBER
    , p0_a14  NUMBER
    , p0_a15  NUMBER
    , p0_a16  NUMBER
    , p0_a17  VARCHAR2
    , p0_a18  NUMBER
    , p0_a19  NUMBER
    , p0_a20  VARCHAR2
    , p0_a21  VARCHAR2
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  VARCHAR2
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  VARCHAR2
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  VARCHAR2
    , p0_a35  VARCHAR2
    , p0_a36  NUMBER
    , p0_a37  VARCHAR2
    , p0_a38  NUMBER
    , p0_a39  NUMBER
    , p0_a40  NUMBER
    , p0_a41  VARCHAR2
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  );
  procedure validate_act_product_record(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  VARCHAR2
    , p0_a9  VARCHAR2
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  NUMBER
    , p0_a14  NUMBER
    , p0_a15  NUMBER
    , p0_a16  NUMBER
    , p0_a17  VARCHAR2
    , p0_a18  NUMBER
    , p0_a19  NUMBER
    , p0_a20  VARCHAR2
    , p0_a21  VARCHAR2
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  VARCHAR2
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  VARCHAR2
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  VARCHAR2
    , p0_a35  VARCHAR2
    , p0_a36  NUMBER
    , p0_a37  VARCHAR2
    , p0_a38  NUMBER
    , p0_a39  NUMBER
    , p0_a40  NUMBER
    , p0_a41  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  );
  procedure complete_act_product_rec(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  VARCHAR2
    , p0_a9  VARCHAR2
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  NUMBER
    , p0_a14  NUMBER
    , p0_a15  NUMBER
    , p0_a16  NUMBER
    , p0_a17  VARCHAR2
    , p0_a18  NUMBER
    , p0_a19  NUMBER
    , p0_a20  VARCHAR2
    , p0_a21  VARCHAR2
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  VARCHAR2
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  VARCHAR2
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  VARCHAR2
    , p0_a35  VARCHAR2
    , p0_a36  NUMBER
    , p0_a37  VARCHAR2
    , p0_a38  NUMBER
    , p0_a39  NUMBER
    , p0_a40  NUMBER
    , p0_a41  VARCHAR2
    , p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  DATE
    , p1_a2 out nocopy  NUMBER
    , p1_a3 out nocopy  DATE
    , p1_a4 out nocopy  NUMBER
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  NUMBER
    , p1_a8 out nocopy  VARCHAR2
    , p1_a9 out nocopy  VARCHAR2
    , p1_a10 out nocopy  VARCHAR2
    , p1_a11 out nocopy  VARCHAR2
    , p1_a12 out nocopy  VARCHAR2
    , p1_a13 out nocopy  NUMBER
    , p1_a14 out nocopy  NUMBER
    , p1_a15 out nocopy  NUMBER
    , p1_a16 out nocopy  NUMBER
    , p1_a17 out nocopy  VARCHAR2
    , p1_a18 out nocopy  NUMBER
    , p1_a19 out nocopy  NUMBER
    , p1_a20 out nocopy  VARCHAR2
    , p1_a21 out nocopy  VARCHAR2
    , p1_a22 out nocopy  VARCHAR2
    , p1_a23 out nocopy  VARCHAR2
    , p1_a24 out nocopy  VARCHAR2
    , p1_a25 out nocopy  VARCHAR2
    , p1_a26 out nocopy  VARCHAR2
    , p1_a27 out nocopy  VARCHAR2
    , p1_a28 out nocopy  VARCHAR2
    , p1_a29 out nocopy  VARCHAR2
    , p1_a30 out nocopy  VARCHAR2
    , p1_a31 out nocopy  VARCHAR2
    , p1_a32 out nocopy  VARCHAR2
    , p1_a33 out nocopy  VARCHAR2
    , p1_a34 out nocopy  VARCHAR2
    , p1_a35 out nocopy  VARCHAR2
    , p1_a36 out nocopy  NUMBER
    , p1_a37 out nocopy  VARCHAR2
    , p1_a38 out nocopy  NUMBER
    , p1_a39 out nocopy  NUMBER
    , p1_a40 out nocopy  NUMBER
    , p1_a41 out nocopy  VARCHAR2
  );
end ams_actproduct_pvt_oa;

 

/
