--------------------------------------------------------
--  DDL for Package Body HZ_FORMAT_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_FORMAT_PUB_W" as
  /* $Header: ARHFMTJB.pls 120.1 2005/07/29 19:45:29 jhuang noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p0(t out nocopy hz_format_pub.string_tbl_type, a0 JTF_VARCHAR2_TABLE_300) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p0;
  procedure rosetta_table_copy_out_p0(t hz_format_pub.string_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_300) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_VARCHAR2_TABLE_300();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p0;

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
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).line_number := a0(indx);
          t(ddindx).position := a1(indx);
          t(ddindx).attribute_code := a2(indx);
          t(ddindx).use_initial_flag := a3(indx);
          t(ddindx).uppercase_flag := a4(indx);
          t(ddindx).transform_function := a5(indx);
          t(ddindx).delimiter_before := a6(indx);
          t(ddindx).delimiter_after := a7(indx);
          t(ddindx).blank_lines_before := a8(indx);
          t(ddindx).blank_lines_after := a9(indx);
          t(ddindx).attribute_value := a10(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
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
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_300();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        a7.extend(t.count);
        a8.extend(t.count);
        a9.extend(t.count);
        a10.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).line_number;
          a1(indx) := t(ddindx).position;
          a2(indx) := t(ddindx).attribute_code;
          a3(indx) := t(ddindx).use_initial_flag;
          a4(indx) := t(ddindx).uppercase_flag;
          a5(indx) := t(ddindx).transform_function;
          a6(indx) := t(ddindx).delimiter_before;
          a7(indx) := t(ddindx).delimiter_after;
          a8(indx) := t(ddindx).blank_lines_before;
          a9(indx) := t(ddindx).blank_lines_after;
          a10(indx) := t(ddindx).attribute_value;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

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
  )

  as
    ddx_formatted_address_tbl hz_format_pub.string_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any














    -- here's the delegated call to the old PL/SQL routine
    hz_format_pub.format_address(p_location_id,
      p_style_code,
      p_style_format_code,
      p_line_break,
      p_space_replace,
      p_to_language_code,
      p_country_name_lang,
      p_from_territory_code,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_formatted_address,
      x_formatted_lines_cnt,
      ddx_formatted_address_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













    hz_format_pub_w.rosetta_table_copy_out_p0(ddx_formatted_address_tbl, x_formatted_address_tbl);
  end;

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
  )

  as
    ddx_formatted_address_tbl hz_format_pub.string_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
























    -- here's the delegated call to the old PL/SQL routine
    hz_format_pub.format_address(p_style_code,
      p_style_format_code,
      p_line_break,
      p_space_replace,
      p_to_language_code,
      p_country_name_lang,
      p_from_territory_code,
      p_address_line_1,
      p_address_line_2,
      p_address_line_3,
      p_address_line_4,
      p_city,
      p_postal_code,
      p_state,
      p_province,
      p_county,
      p_country,
      p_address_lines_phonetic,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_formatted_address,
      x_formatted_lines_cnt,
      ddx_formatted_address_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any























    hz_format_pub_w.rosetta_table_copy_out_p0(ddx_formatted_address_tbl, x_formatted_address_tbl);
  end;

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
  )

  as
    ddx_layout_tbl hz_format_pub.layout_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any













    -- here's the delegated call to the old PL/SQL routine
    hz_format_pub.format_address_layout(p_location_id,
      p_style_code,
      p_style_format_code,
      p_line_break,
      p_space_replace,
      p_to_language_code,
      p_country_name_lang,
      p_from_territory_code,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_layout_tbl_cnt,
      ddx_layout_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












    hz_format_pub_w.rosetta_table_copy_out_p2(ddx_layout_tbl, p12_a0
      , p12_a1
      , p12_a2
      , p12_a3
      , p12_a4
      , p12_a5
      , p12_a6
      , p12_a7
      , p12_a8
      , p12_a9
      , p12_a10
      );
  end;

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
  )

  as
    ddx_layout_tbl hz_format_pub.layout_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any























    -- here's the delegated call to the old PL/SQL routine
    hz_format_pub.format_address_layout(p_style_code,
      p_style_format_code,
      p_line_break,
      p_space_replace,
      p_to_language_code,
      p_country_name_lang,
      p_from_territory_code,
      p_address_line_1,
      p_address_line_2,
      p_address_line_3,
      p_address_line_4,
      p_city,
      p_postal_code,
      p_state,
      p_province,
      p_county,
      p_country,
      p_address_lines_phonetic,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_layout_tbl_cnt,
      ddx_layout_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






















    hz_format_pub_w.rosetta_table_copy_out_p2(ddx_layout_tbl, p22_a0
      , p22_a1
      , p22_a2
      , p22_a3
      , p22_a4
      , p22_a5
      , p22_a6
      , p22_a7
      , p22_a8
      , p22_a9
      , p22_a10
      );
  end;

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
  )

  as
    ddx_formatted_name_tbl hz_format_pub.string_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any













    -- here's the delegated call to the old PL/SQL routine
    hz_format_pub.format_name(p_party_id,
      p_style_code,
      p_style_format_code,
      p_line_break,
      p_space_replace,
      p_ref_language_code,
      p_ref_territory_code,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_formatted_name,
      x_formatted_lines_cnt,
      ddx_formatted_name_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












    hz_format_pub_w.rosetta_table_copy_out_p0(ddx_formatted_name_tbl, x_formatted_name_tbl);
  end;

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
  )

  as
    ddx_formatted_name_tbl hz_format_pub.string_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





















    -- here's the delegated call to the old PL/SQL routine
    hz_format_pub.format_name(p_style_code,
      p_style_format_code,
      p_line_break,
      p_space_replace,
      p_ref_language_code,
      p_ref_territory_code,
      p_person_title,
      p_person_first_name,
      p_person_middle_name,
      p_person_last_name,
      p_person_name_suffix,
      p_person_known_as,
      p_first_name_phonetic,
      p_middle_name_phonetic,
      p_last_name_phonetic,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_formatted_name,
      x_formatted_lines_cnt,
      ddx_formatted_name_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




















    hz_format_pub_w.rosetta_table_copy_out_p0(ddx_formatted_name_tbl, x_formatted_name_tbl);
  end;

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
  )

  as
    ddx_formatted_data_tbl hz_format_pub.string_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

















    -- here's the delegated call to the old PL/SQL routine
    hz_format_pub.format_data(p_object_code,
      p_object_key_1,
      p_object_key_2,
      p_object_key_3,
      p_object_key_4,
      p_style_code,
      p_style_format_code,
      p_line_break,
      p_space_replace,
      p_ref_language_code,
      p_ref_territory_code,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_formatted_data,
      x_formatted_lines_cnt,
      ddx_formatted_data_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
















    hz_format_pub_w.rosetta_table_copy_out_p0(ddx_formatted_data_tbl, x_formatted_data_tbl);
  end;

  procedure get_context_8(p0_a0 out nocopy  VARCHAR2
    , p0_a1 out nocopy  VARCHAR2
    , p0_a2 out nocopy  VARCHAR2
    , p0_a3 out nocopy  VARCHAR2
    , p0_a4 out nocopy  VARCHAR2
    , p0_a5 out nocopy  VARCHAR2
    , p0_a6 out nocopy  VARCHAR2
  )

  as
    ddx_context hz_format_pub.context_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    hz_format_pub.get_context(ddx_context);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    p0_a0 := ddx_context.style_code;
    p0_a1 := ddx_context.style_format_code;
    p0_a2 := ddx_context.to_territory_code;
    p0_a3 := ddx_context.to_language_code;
    p0_a4 := ddx_context.from_territory_code;
    p0_a5 := ddx_context.from_language_code;
    p0_a6 := ddx_context.country_name_lang;
  end;

end hz_format_pub_w;

/
