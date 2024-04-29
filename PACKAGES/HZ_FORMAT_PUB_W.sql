--------------------------------------------------------
--  DDL for Package HZ_FORMAT_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_FORMAT_PUB_W" AUTHID CURRENT_USER as
  /* $Header: ARHFMTJS.pls 120.1 2005/07/29 19:45:15 jhuang noship $ */
  procedure rosetta_table_copy_in_p0(t out nocopy hz_format_pub.string_tbl_type, a0 JTF_VARCHAR2_TABLE_300);
  procedure rosetta_table_copy_out_p0(t hz_format_pub.string_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_300);

  procedure rosetta_table_copy_in_p2(t out nocopy hz_format_pub.layout_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_300
    );
  procedure rosetta_table_copy_out_p2(t hz_format_pub.layout_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_300
    );

  procedure format_address_1(p_location_id  NUMBER
    , p_style_code  VARCHAR2
    , p_style_format_code  VARCHAR2
    , p_line_break  VARCHAR2
    , p_space_replace  VARCHAR2
    , p_to_language_code  VARCHAR2
    , p_country_name_lang  VARCHAR2
    , p_from_territory_code  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_formatted_address out nocopy  VARCHAR2
    , x_formatted_lines_cnt out nocopy  NUMBER
    , x_formatted_address_tbl out nocopy JTF_VARCHAR2_TABLE_300
  );
  procedure format_address_2(p_style_code  VARCHAR2
    , p_style_format_code  VARCHAR2
    , p_line_break  VARCHAR2
    , p_space_replace  VARCHAR2
    , p_to_language_code  VARCHAR2
    , p_country_name_lang  VARCHAR2
    , p_from_territory_code  VARCHAR2
    , p_address_line_1  VARCHAR2
    , p_address_line_2  VARCHAR2
    , p_address_line_3  VARCHAR2
    , p_address_line_4  VARCHAR2
    , p_city  VARCHAR2
    , p_postal_code  VARCHAR2
    , p_state  VARCHAR2
    , p_province  VARCHAR2
    , p_county  VARCHAR2
    , p_country  VARCHAR2
    , p_address_lines_phonetic  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_formatted_address out nocopy  VARCHAR2
    , x_formatted_lines_cnt out nocopy  NUMBER
    , x_formatted_address_tbl out nocopy JTF_VARCHAR2_TABLE_300
  );
  procedure format_address_layout_3(p_location_id  NUMBER
    , p_style_code  VARCHAR2
    , p_style_format_code  VARCHAR2
    , p_line_break  VARCHAR2
    , p_space_replace  VARCHAR2
    , p_to_language_code  VARCHAR2
    , p_country_name_lang  VARCHAR2
    , p_from_territory_code  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_layout_tbl_cnt out nocopy  NUMBER
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_NUMBER_TABLE
    , p12_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a8 out nocopy JTF_NUMBER_TABLE
    , p12_a9 out nocopy JTF_NUMBER_TABLE
    , p12_a10 out nocopy JTF_VARCHAR2_TABLE_300
  );
  procedure format_address_layout_4(p_style_code  VARCHAR2
    , p_style_format_code  VARCHAR2
    , p_line_break  VARCHAR2
    , p_space_replace  VARCHAR2
    , p_to_language_code  VARCHAR2
    , p_country_name_lang  VARCHAR2
    , p_from_territory_code  VARCHAR2
    , p_address_line_1  VARCHAR2
    , p_address_line_2  VARCHAR2
    , p_address_line_3  VARCHAR2
    , p_address_line_4  VARCHAR2
    , p_city  VARCHAR2
    , p_postal_code  VARCHAR2
    , p_state  VARCHAR2
    , p_province  VARCHAR2
    , p_county  VARCHAR2
    , p_country  VARCHAR2
    , p_address_lines_phonetic  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_layout_tbl_cnt out nocopy  NUMBER
    , p22_a0 out nocopy JTF_NUMBER_TABLE
    , p22_a1 out nocopy JTF_NUMBER_TABLE
    , p22_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p22_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p22_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p22_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p22_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p22_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p22_a8 out nocopy JTF_NUMBER_TABLE
    , p22_a9 out nocopy JTF_NUMBER_TABLE
    , p22_a10 out nocopy JTF_VARCHAR2_TABLE_300
  );
  procedure format_name_5(p_party_id  NUMBER
    , p_style_code  VARCHAR2
    , p_style_format_code  VARCHAR2
    , p_line_break  VARCHAR2
    , p_space_replace  VARCHAR2
    , p_ref_language_code  VARCHAR2
    , p_ref_territory_code  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_formatted_name out nocopy  VARCHAR2
    , x_formatted_lines_cnt out nocopy  NUMBER
    , x_formatted_name_tbl out nocopy JTF_VARCHAR2_TABLE_300
  );
  procedure format_name_6(p_style_code  VARCHAR2
    , p_style_format_code  VARCHAR2
    , p_line_break  VARCHAR2
    , p_space_replace  VARCHAR2
    , p_ref_language_code  VARCHAR2
    , p_ref_territory_code  VARCHAR2
    , p_person_title  VARCHAR2
    , p_person_first_name  VARCHAR2
    , p_person_middle_name  VARCHAR2
    , p_person_last_name  VARCHAR2
    , p_person_name_suffix  VARCHAR2
    , p_person_known_as  VARCHAR2
    , p_first_name_phonetic  VARCHAR2
    , p_middle_name_phonetic  VARCHAR2
    , p_last_name_phonetic  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_formatted_name out nocopy  VARCHAR2
    , x_formatted_lines_cnt out nocopy  NUMBER
    , x_formatted_name_tbl out nocopy JTF_VARCHAR2_TABLE_300
  );
  procedure format_data_7(p_object_code  VARCHAR2
    , p_object_key_1  VARCHAR2
    , p_object_key_2  VARCHAR2
    , p_object_key_3  VARCHAR2
    , p_object_key_4  VARCHAR2
    , p_style_code  VARCHAR2
    , p_style_format_code  VARCHAR2
    , p_line_break  VARCHAR2
    , p_space_replace  VARCHAR2
    , p_ref_language_code  VARCHAR2
    , p_ref_territory_code  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_formatted_data out nocopy  VARCHAR2
    , x_formatted_lines_cnt out nocopy  NUMBER
    , x_formatted_data_tbl out nocopy JTF_VARCHAR2_TABLE_300
  );
  procedure get_context_8(p0_a0 out nocopy  VARCHAR2
    , p0_a1 out nocopy  VARCHAR2
    , p0_a2 out nocopy  VARCHAR2
    , p0_a3 out nocopy  VARCHAR2
    , p0_a4 out nocopy  VARCHAR2
    , p0_a5 out nocopy  VARCHAR2
    , p0_a6 out nocopy  VARCHAR2
  );
end hz_format_pub_w;

 

/
