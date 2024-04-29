--------------------------------------------------------
--  DDL for Package JTF_AMV_ITEM_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_AMV_ITEM_PUB_W" AUTHID CURRENT_USER as
  /* $Header: jtfpitws.pls 120.3 2005/09/13 11:09:59 vimohan ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy jtf_amv_item_pub.number_tab_type, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p1(t jtf_amv_item_pub.number_tab_type, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p2(t out nocopy jtf_amv_item_pub.char_tab_type, a0 JTF_VARCHAR2_TABLE_200);
  procedure rosetta_table_copy_out_p2(t jtf_amv_item_pub.char_tab_type, a0 out nocopy JTF_VARCHAR2_TABLE_200);

  procedure create_item(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_item_id out nocopy  NUMBER
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  DATE := fnd_api.g_miss_date
    , p6_a2  NUMBER := 0-1962.0724
    , p6_a3  DATE := fnd_api.g_miss_date
    , p6_a4  NUMBER := 0-1962.0724
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  VARCHAR2 := fnd_api.g_miss_char
    , p6_a9  VARCHAR2 := fnd_api.g_miss_char
    , p6_a10  VARCHAR2 := fnd_api.g_miss_char
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  VARCHAR2 := fnd_api.g_miss_char
    , p6_a14  DATE := fnd_api.g_miss_date
    , p6_a15  DATE := fnd_api.g_miss_date
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
    , p6_a17  VARCHAR2 := fnd_api.g_miss_char
    , p6_a18  DATE := fnd_api.g_miss_date
    , p6_a19  VARCHAR2 := fnd_api.g_miss_char
    , p6_a20  NUMBER := 0-1962.0724
    , p6_a21  NUMBER := 0-1962.0724
    , p6_a22  NUMBER := 0-1962.0724
    , p6_a23  VARCHAR2 := fnd_api.g_miss_char
    , p6_a24  VARCHAR2 := fnd_api.g_miss_char
    , p6_a25  VARCHAR2 := fnd_api.g_miss_char
    , p6_a26  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure update_item(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  DATE := fnd_api.g_miss_date
    , p6_a2  NUMBER := 0-1962.0724
    , p6_a3  DATE := fnd_api.g_miss_date
    , p6_a4  NUMBER := 0-1962.0724
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  VARCHAR2 := fnd_api.g_miss_char
    , p6_a9  VARCHAR2 := fnd_api.g_miss_char
    , p6_a10  VARCHAR2 := fnd_api.g_miss_char
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  VARCHAR2 := fnd_api.g_miss_char
    , p6_a14  DATE := fnd_api.g_miss_date
    , p6_a15  DATE := fnd_api.g_miss_date
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
    , p6_a17  VARCHAR2 := fnd_api.g_miss_char
    , p6_a18  DATE := fnd_api.g_miss_date
    , p6_a19  VARCHAR2 := fnd_api.g_miss_char
    , p6_a20  NUMBER := 0-1962.0724
    , p6_a21  NUMBER := 0-1962.0724
    , p6_a22  NUMBER := 0-1962.0724
    , p6_a23  VARCHAR2 := fnd_api.g_miss_char
    , p6_a24  VARCHAR2 := fnd_api.g_miss_char
    , p6_a25  VARCHAR2 := fnd_api.g_miss_char
    , p6_a26  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure get_item(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_item_id  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  DATE
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  DATE
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  DATE
    , p6_a15 out nocopy  DATE
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  DATE
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
  );
  procedure add_itemkeyword(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_item_id  NUMBER
    , p_keyword_tab JTF_VARCHAR2_TABLE_200
  );
  procedure delete_itemkeyword(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_item_id  NUMBER
    , p_keyword_tab JTF_VARCHAR2_TABLE_200
  );
  procedure replace_itemkeyword(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_item_id  NUMBER
    , p_keyword_tab JTF_VARCHAR2_TABLE_200
  );
  procedure get_itemkeyword(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_item_id  NUMBER
    , x_keyword_tab out nocopy JTF_VARCHAR2_TABLE_200
  );
  procedure add_itemauthor(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_item_id  NUMBER
    , p_author_tab JTF_VARCHAR2_TABLE_200
  );
  procedure delete_itemauthor(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_item_id  NUMBER
    , p_author_tab JTF_VARCHAR2_TABLE_200
  );
  procedure replace_itemauthor(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_item_id  NUMBER
    , p_author_tab JTF_VARCHAR2_TABLE_200
  );
  procedure get_itemauthor(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_item_id  NUMBER
    , x_author_tab out nocopy JTF_VARCHAR2_TABLE_200
  );
end jtf_amv_item_pub_w;

 

/
