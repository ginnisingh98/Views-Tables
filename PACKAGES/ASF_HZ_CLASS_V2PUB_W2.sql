--------------------------------------------------------
--  DDL for Package ASF_HZ_CLASS_V2PUB_W2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASF_HZ_CLASS_V2PUB_W2" AUTHID CURRENT_USER as
  /* $Header: asfwcl2s.pls 115.1 2002/03/25 17:19:13 pkm ship    $ */
  procedure get_code_assignment_rec(p_init_msg_list  VARCHAR2
    , p_code_assignment_id  NUMBER
    , p2_a0 out  NUMBER
    , p2_a1 out  VARCHAR2
    , p2_a2 out  NUMBER
    , p2_a3 out  VARCHAR2
    , p2_a4 out  VARCHAR2
    , p2_a5 out  VARCHAR2
    , p2_a6 out  VARCHAR2
    , p2_a7 out  DATE
    , p2_a8 out  DATE
    , p2_a9 out  VARCHAR2
    , p2_a10 out  VARCHAR2
    , p2_a11 out  NUMBER
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
  );
  procedure create_class_category_use(p_init_msg_list  VARCHAR2
    , p1_a0  VARCHAR2 := fnd_api.g_miss_char
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  VARCHAR2 := fnd_api.g_miss_char
    , p1_a3  VARCHAR2 := fnd_api.g_miss_char
    , p1_a4  VARCHAR2 := fnd_api.g_miss_char
    , p1_a5  NUMBER := 0-1962.0724
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
  );
  procedure update_class_category_use(p_init_msg_list  VARCHAR2
    , p1_a0  VARCHAR2 := fnd_api.g_miss_char
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  VARCHAR2 := fnd_api.g_miss_char
    , p1_a3  VARCHAR2 := fnd_api.g_miss_char
    , p1_a4  VARCHAR2 := fnd_api.g_miss_char
    , p1_a5  NUMBER := 0-1962.0724
    , p_object_version_number in out  NUMBER
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
  );
  procedure get_class_category_use_rec(p_init_msg_list  VARCHAR2
    , p_class_category  VARCHAR2
    , p_owner_table  VARCHAR2
    , p3_a0 out  VARCHAR2
    , p3_a1 out  VARCHAR2
    , p3_a2 out  VARCHAR2
    , p3_a3 out  VARCHAR2
    , p3_a4 out  VARCHAR2
    , p3_a5 out  NUMBER
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
  );
end asf_hz_class_v2pub_w2;

 

/
