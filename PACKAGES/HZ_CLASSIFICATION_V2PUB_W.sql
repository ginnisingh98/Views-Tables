--------------------------------------------------------
--  DDL for Package HZ_CLASSIFICATION_V2PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_CLASSIFICATION_V2PUB_W" AUTHID CURRENT_USER as
  /* $Header: asfwclss.pls 115.0 2001/12/11 12:38:26 pkm ship    $ */
  procedure create_class_category(p_init_msg_list  VARCHAR2
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
  procedure update_class_category(p_init_msg_list  VARCHAR2
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
  procedure get_class_category_rec(p_init_msg_list  VARCHAR2
    , p_class_category  VARCHAR2
    , p2_a0 out  VARCHAR2
    , p2_a1 out  VARCHAR2
    , p2_a2 out  VARCHAR2
    , p2_a3 out  VARCHAR2
    , p2_a4 out  VARCHAR2
    , p2_a5 out  NUMBER
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
  );
  procedure create_class_code_relation(p_init_msg_list  VARCHAR2
    , p1_a0  VARCHAR2 := fnd_api.g_miss_char
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  VARCHAR2 := fnd_api.g_miss_char
    , p1_a3  DATE := fnd_api.g_miss_date
    , p1_a4  DATE := fnd_api.g_miss_date
    , p1_a5  VARCHAR2 := fnd_api.g_miss_char
    , p1_a6  NUMBER := 0-1962.0724
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
  );
  procedure update_class_code_relation(p_init_msg_list  VARCHAR2
    , p1_a0  VARCHAR2 := fnd_api.g_miss_char
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  VARCHAR2 := fnd_api.g_miss_char
    , p1_a3  DATE := fnd_api.g_miss_date
    , p1_a4  DATE := fnd_api.g_miss_date
    , p1_a5  VARCHAR2 := fnd_api.g_miss_char
    , p1_a6  NUMBER := 0-1962.0724
    , p_object_version_number in out  NUMBER
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
  );
  procedure get_class_code_relation_rec(p_init_msg_list  VARCHAR2
    , p_class_category  VARCHAR2
    , p_class_code  VARCHAR2
    , p_sub_class_code  VARCHAR2
    , p_start_date_active  date
    , p5_a0 out  VARCHAR2
    , p5_a1 out  VARCHAR2
    , p5_a2 out  VARCHAR2
    , p5_a3 out  DATE
    , p5_a4 out  DATE
    , p5_a5 out  VARCHAR2
    , p5_a6 out  NUMBER
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
  );
  procedure create_code_assignment(p_init_msg_list  VARCHAR2
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  NUMBER := 0-1962.0724
    , p1_a3  VARCHAR2 := fnd_api.g_miss_char
    , p1_a4  VARCHAR2 := fnd_api.g_miss_char
    , p1_a5  VARCHAR2 := fnd_api.g_miss_char
    , p1_a6  VARCHAR2 := fnd_api.g_miss_char
    , p1_a7  DATE := fnd_api.g_miss_date
    , p1_a8  DATE := fnd_api.g_miss_date
    , p1_a9  VARCHAR2 := fnd_api.g_miss_char
    , p1_a10  VARCHAR2 := fnd_api.g_miss_char
    , p1_a11  NUMBER := 0-1962.0724
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , x_code_assignment_id out  NUMBER
  );
  procedure update_code_assignment(p_init_msg_list  VARCHAR2
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  NUMBER := 0-1962.0724
    , p1_a3  VARCHAR2 := fnd_api.g_miss_char
    , p1_a4  VARCHAR2 := fnd_api.g_miss_char
    , p1_a5  VARCHAR2 := fnd_api.g_miss_char
    , p1_a6  VARCHAR2 := fnd_api.g_miss_char
    , p1_a7  DATE := fnd_api.g_miss_date
    , p1_a8  DATE := fnd_api.g_miss_date
    , p1_a9  VARCHAR2 := fnd_api.g_miss_char
    , p1_a10  VARCHAR2 := fnd_api.g_miss_char
    , p1_a11  NUMBER := 0-1962.0724
    , p_object_version_number in out  NUMBER
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
  );
end hz_classification_v2pub_w;

 

/
