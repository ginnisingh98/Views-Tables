--------------------------------------------------------
--  DDL for Package HZ_ORIG_SYSTEM_REF_PVT_JW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_ORIG_SYSTEM_REF_PVT_JW" AUTHID CURRENT_USER as
  /* $Header: ARHMOSJS.pls 120.5 2006/05/31 12:18:18 idali noship $ */
  procedure create_orig_sys_entity_mapp_1(p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p2_a0  VARCHAR2 := null
    , p2_a1  VARCHAR2 := null
    , p2_a2  VARCHAR2 := null
    , p2_a3  VARCHAR2 := null
    , p2_a4  VARCHAR2 := null
    , p2_a5  VARCHAR2 := null
    , p2_a6  NUMBER := null
    , p2_a7  VARCHAR2 := null
    , p2_a8  VARCHAR2 := null
    , p2_a9  VARCHAR2 := null
    , p2_a10  VARCHAR2 := null
    , p2_a11  VARCHAR2 := null
    , p2_a12  VARCHAR2 := null
    , p2_a13  VARCHAR2 := null
    , p2_a14  VARCHAR2 := null
    , p2_a15  VARCHAR2 := null
    , p2_a16  VARCHAR2 := null
    , p2_a17  VARCHAR2 := null
    , p2_a18  VARCHAR2 := null
    , p2_a19  VARCHAR2 := null
    , p2_a20  VARCHAR2 := null
    , p2_a21  VARCHAR2 := null
    , p2_a22  VARCHAR2 := null
    , p2_a23  VARCHAR2 := null
    , p2_a24  VARCHAR2 := null
    , p2_a25  VARCHAR2 := null
    , p2_a26  VARCHAR2 := null
    , p2_a27  VARCHAR2 := null
  );
  procedure update_orig_sys_entity_mapp_2(p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p2_a0  VARCHAR2 := null
    , p2_a1  VARCHAR2 := null
    , p2_a2  VARCHAR2 := null
    , p2_a3  VARCHAR2 := null
    , p2_a4  VARCHAR2 := null
    , p2_a5  VARCHAR2 := null
    , p2_a6  NUMBER := null
    , p2_a7  VARCHAR2 := null
    , p2_a8  VARCHAR2 := null
    , p2_a9  VARCHAR2 := null
    , p2_a10  VARCHAR2 := null
    , p2_a11  VARCHAR2 := null
    , p2_a12  VARCHAR2 := null
    , p2_a13  VARCHAR2 := null
    , p2_a14  VARCHAR2 := null
    , p2_a15  VARCHAR2 := null
    , p2_a16  VARCHAR2 := null
    , p2_a17  VARCHAR2 := null
    , p2_a18  VARCHAR2 := null
    , p2_a19  VARCHAR2 := null
    , p2_a20  VARCHAR2 := null
    , p2_a21  VARCHAR2 := null
    , p2_a22  VARCHAR2 := null
    , p2_a23  VARCHAR2 := null
    , p2_a24  VARCHAR2 := null
    , p2_a25  VARCHAR2 := null
    , p2_a26  VARCHAR2 := null
    , p2_a27  VARCHAR2 := null
  );
  procedure create_orig_system_referenc_3(p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p2_a0  NUMBER := null
    , p2_a1  VARCHAR2 := null
    , p2_a2  VARCHAR2 := null
    , p2_a3  VARCHAR2 := null
    , p2_a4  NUMBER := null
    , p2_a5  NUMBER := null
    , p2_a6  VARCHAR2 := null
    , p2_a7  VARCHAR2 := null
    , p2_a8  VARCHAR2 := null
    , p2_a9  DATE := null
    , p2_a10  DATE := null
    , p2_a11  VARCHAR2 := null
    , p2_a12  NUMBER := null
    , p2_a13  VARCHAR2 := null
    , p2_a14  VARCHAR2 := null
    , p2_a15  VARCHAR2 := null
    , p2_a16  VARCHAR2 := null
    , p2_a17  VARCHAR2 := null
    , p2_a18  VARCHAR2 := null
    , p2_a19  VARCHAR2 := null
    , p2_a20  VARCHAR2 := null
    , p2_a21  VARCHAR2 := null
    , p2_a22  VARCHAR2 := null
    , p2_a23  VARCHAR2 := null
    , p2_a24  VARCHAR2 := null
    , p2_a25  VARCHAR2 := null
    , p2_a26  VARCHAR2 := null
    , p2_a27  VARCHAR2 := null
    , p2_a28  VARCHAR2 := null
    , p2_a29  VARCHAR2 := null
    , p2_a30  VARCHAR2 := null
    , p2_a31  VARCHAR2 := null
    , p2_a32  VARCHAR2 := null
    , p2_a33  VARCHAR2 := null
  );
  procedure update_orig_system_referenc_4(p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p2_a0  NUMBER := null
    , p2_a1  VARCHAR2 := null
    , p2_a2  VARCHAR2 := null
    , p2_a3  VARCHAR2 := null
    , p2_a4  NUMBER := null
    , p2_a5  NUMBER := null
    , p2_a6  VARCHAR2 := null
    , p2_a7  VARCHAR2 := null
    , p2_a8  VARCHAR2 := null
    , p2_a9  DATE := null
    , p2_a10  DATE := null
    , p2_a11  VARCHAR2 := null
    , p2_a12  NUMBER := null
    , p2_a13  VARCHAR2 := null
    , p2_a14  VARCHAR2 := null
    , p2_a15  VARCHAR2 := null
    , p2_a16  VARCHAR2 := null
    , p2_a17  VARCHAR2 := null
    , p2_a18  VARCHAR2 := null
    , p2_a19  VARCHAR2 := null
    , p2_a20  VARCHAR2 := null
    , p2_a21  VARCHAR2 := null
    , p2_a22  VARCHAR2 := null
    , p2_a23  VARCHAR2 := null
    , p2_a24  VARCHAR2 := null
    , p2_a25  VARCHAR2 := null
    , p2_a26  VARCHAR2 := null
    , p2_a27  VARCHAR2 := null
    , p2_a28  VARCHAR2 := null
    , p2_a29  VARCHAR2 := null
    , p2_a30  VARCHAR2 := null
    , p2_a31  VARCHAR2 := null
    , p2_a32  VARCHAR2 := null
    , p2_a33  VARCHAR2 := null
  );
  procedure get_orig_sys_reference_rec_5(p_init_msg_list  VARCHAR2
    , p_orig_system_ref_id  NUMBER
    , p2_a0 out nocopy  NUMBER
    , p2_a1 out nocopy  VARCHAR2
    , p2_a2 out nocopy  VARCHAR2
    , p2_a3 out nocopy  VARCHAR2
    , p2_a4 out nocopy  NUMBER
    , p2_a5 out nocopy  NUMBER
    , p2_a6 out nocopy  VARCHAR2
    , p2_a7 out nocopy  VARCHAR2
    , p2_a8 out nocopy  VARCHAR2
    , p2_a9 out nocopy  DATE
    , p2_a10 out nocopy  DATE
    , p2_a11 out nocopy  VARCHAR2
    , p2_a12 out nocopy  NUMBER
    , p2_a13 out nocopy  VARCHAR2
    , p2_a14 out nocopy  VARCHAR2
    , p2_a15 out nocopy  VARCHAR2
    , p2_a16 out nocopy  VARCHAR2
    , p2_a17 out nocopy  VARCHAR2
    , p2_a18 out nocopy  VARCHAR2
    , p2_a19 out nocopy  VARCHAR2
    , p2_a20 out nocopy  VARCHAR2
    , p2_a21 out nocopy  VARCHAR2
    , p2_a22 out nocopy  VARCHAR2
    , p2_a23 out nocopy  VARCHAR2
    , p2_a24 out nocopy  VARCHAR2
    , p2_a25 out nocopy  VARCHAR2
    , p2_a26 out nocopy  VARCHAR2
    , p2_a27 out nocopy  VARCHAR2
    , p2_a28 out nocopy  VARCHAR2
    , p2_a29 out nocopy  VARCHAR2
    , p2_a30 out nocopy  VARCHAR2
    , p2_a31 out nocopy  VARCHAR2
    , p2_a32 out nocopy  VARCHAR2
    , p2_a33 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure create_orig_system_6(p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p2_a0  NUMBER := null
    , p2_a1  VARCHAR2 := null
    , p2_a2  VARCHAR2 := null
    , p2_a3  VARCHAR2 := null
    , p2_a4  VARCHAR2 := null
    , p2_a5  VARCHAR2 := null
    , p2_a6  VARCHAR2 := null
    , p2_a7  VARCHAR2 := null
    , p2_a8  VARCHAR2 := null
    , p2_a9  VARCHAR2 := null
    , p2_a10  VARCHAR2 := null
    , p2_a11  VARCHAR2 := null
    , p2_a12  VARCHAR2 := null
    , p2_a13  VARCHAR2 := null
    , p2_a14  VARCHAR2 := null
    , p2_a15  VARCHAR2 := null
    , p2_a16  VARCHAR2 := null
    , p2_a17  VARCHAR2 := null
    , p2_a18  VARCHAR2 := null
    , p2_a19  VARCHAR2 := null
    , p2_a20  VARCHAR2 := null
    , p2_a21  VARCHAR2 := null
    , p2_a22  VARCHAR2 := null
    , p2_a23  VARCHAR2 := null
    , p2_a24  VARCHAR2 := null
    , p2_a25  VARCHAR2 := null
    , p2_a26  VARCHAR2 := null
    , p2_a27  VARCHAR2 := null
    , p2_a28  VARCHAR2 := null
  );
  procedure update_orig_system_7(p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p2_a0  NUMBER := null
    , p2_a1  VARCHAR2 := null
    , p2_a2  VARCHAR2 := null
    , p2_a3  VARCHAR2 := null
    , p2_a4  VARCHAR2 := null
    , p2_a5  VARCHAR2 := null
    , p2_a6  VARCHAR2 := null
    , p2_a7  VARCHAR2 := null
    , p2_a8  VARCHAR2 := null
    , p2_a9  VARCHAR2 := null
    , p2_a10  VARCHAR2 := null
    , p2_a11  VARCHAR2 := null
    , p2_a12  VARCHAR2 := null
    , p2_a13  VARCHAR2 := null
    , p2_a14  VARCHAR2 := null
    , p2_a15  VARCHAR2 := null
    , p2_a16  VARCHAR2 := null
    , p2_a17  VARCHAR2 := null
    , p2_a18  VARCHAR2 := null
    , p2_a19  VARCHAR2 := null
    , p2_a20  VARCHAR2 := null
    , p2_a21  VARCHAR2 := null
    , p2_a22  VARCHAR2 := null
    , p2_a23  VARCHAR2 := null
    , p2_a24  VARCHAR2 := null
    , p2_a25  VARCHAR2 := null
    , p2_a26  VARCHAR2 := null
    , p2_a27  VARCHAR2 := null
    , p2_a28  VARCHAR2 := null
  );
end hz_orig_system_ref_pvt_jw;

 

/
