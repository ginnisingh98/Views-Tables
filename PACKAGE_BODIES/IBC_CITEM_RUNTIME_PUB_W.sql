--------------------------------------------------------
--  DDL for Package Body IBC_CITEM_RUNTIME_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_CITEM_RUNTIME_PUB_W" as
  /* $Header: ibcwcirb.pls 120.1 2005/05/31 01:00:40 appldev  $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return NULL; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p0(t out nocopy ibc_citem_runtime_pub.rendition_file_name_tbl, a0 JTF_VARCHAR2_TABLE_300) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is null then
    t := null;
  elsif a0.count = 0 then
    t := ibc_citem_runtime_pub.rendition_file_name_tbl();
  else
      if a0.count > 0 then
      t := ibc_citem_runtime_pub.rendition_file_name_tbl();
      t.extend(a0.count);
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
  procedure rosetta_table_copy_out_p0(t ibc_citem_runtime_pub.rendition_file_name_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_300) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
  elsif t.count = 0 then
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

  procedure rosetta_table_copy_in_p1(t out nocopy ibc_citem_runtime_pub.rendition_file_id_tbl, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is null then
    t := null;
  elsif a0.count = 0 then
    t := ibc_citem_runtime_pub.rendition_file_id_tbl();
  else
      if a0.count > 0 then
      t := ibc_citem_runtime_pub.rendition_file_id_tbl();
      t.extend(a0.count);
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
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t ibc_citem_runtime_pub.rendition_file_id_tbl, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
  elsif t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
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
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p2(t out nocopy ibc_citem_runtime_pub.rendition_mime_type_tbl, a0 JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is null then
    t := null;
  elsif a0.count = 0 then
    t := ibc_citem_runtime_pub.rendition_mime_type_tbl();
  else
      if a0.count > 0 then
      t := ibc_citem_runtime_pub.rendition_mime_type_tbl();
      t.extend(a0.count);
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
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t ibc_citem_runtime_pub.rendition_mime_type_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
  elsif t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
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
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p3(t out nocopy ibc_citem_runtime_pub.rendition_name_tbl, a0 JTF_VARCHAR2_TABLE_300) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is null then
    t := null;
  elsif a0.count = 0 then
    t := ibc_citem_runtime_pub.rendition_name_tbl();
  else
      if a0.count > 0 then
      t := ibc_citem_runtime_pub.rendition_name_tbl();
      t.extend(a0.count);
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
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ibc_citem_runtime_pub.rendition_name_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_300) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
  elsif t.count = 0 then
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
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p4(t out nocopy ibc_citem_runtime_pub.comp_item_attrib_tcode_tbl, a0 JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is null then
    t := null;
  elsif a0.count = 0 then
    t := ibc_citem_runtime_pub.comp_item_attrib_tcode_tbl();
  else
      if a0.count > 0 then
      t := ibc_citem_runtime_pub.comp_item_attrib_tcode_tbl();
      t.extend(a0.count);
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
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t ibc_citem_runtime_pub.comp_item_attrib_tcode_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
  elsif t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
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
  end rosetta_table_copy_out_p4;

  procedure rosetta_table_copy_in_p5(t out nocopy ibc_citem_runtime_pub.comp_item_citem_id_tbl, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is null then
    t := null;
  elsif a0.count = 0 then
    t := ibc_citem_runtime_pub.comp_item_citem_id_tbl();
  else
      if a0.count > 0 then
      t := ibc_citem_runtime_pub.comp_item_citem_id_tbl();
      t.extend(a0.count);
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
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t ibc_citem_runtime_pub.comp_item_citem_id_tbl, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
  elsif t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
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
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p7(t out nocopy ibc_citem_runtime_pub.content_item_meta_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_VARCHAR2_TABLE_2000
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count=0 then
    t := ibc_citem_runtime_pub.content_item_meta_tbl();
  elsif a0 is not null and a0.count > 0 then
      if a0.count > 0 then
      t := ibc_citem_runtime_pub.content_item_meta_tbl();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).content_item_id := a0(indx);
          t(ddindx).version_number := a1(indx);
          t(ddindx).available_date := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).expiration_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).content_type_code := a4(indx);
          t(ddindx).item_reference_code := a5(indx);
          t(ddindx).encrypt_flag := a6(indx);
          t(ddindx).content_item_name := a7(indx);
          t(ddindx).description := a8(indx);
          t(ddindx).attachment_file_name := a9(indx);
          t(ddindx).attachment_file_id := a10(indx);
          t(ddindx).default_mime_type := a11(indx);
          t(ddindx).default_rendition_name := a12(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t ibc_citem_runtime_pub.content_item_meta_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_300
    , a8 out nocopy JTF_VARCHAR2_TABLE_2000
    , a9 out nocopy JTF_VARCHAR2_TABLE_300
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
    a1 := null;
    a2 := null;
    a3 := null;
    a4 := null;
    a5 := null;
    a6 := null;
    a7 := null;
    a8 := null;
    a9 := null;
    a10 := null;
    a11 := null;
    a12 := null;
  elsif t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_300();
    a8 := JTF_VARCHAR2_TABLE_2000();
    a9 := JTF_VARCHAR2_TABLE_300();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_300();
      a8 := JTF_VARCHAR2_TABLE_2000();
      a9 := JTF_VARCHAR2_TABLE_300();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_300();
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
        a11.extend(t.count);
        a12.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).content_item_id;
          a1(indx) := t(ddindx).version_number;
          a2(indx) := t(ddindx).available_date;
          a3(indx) := t(ddindx).expiration_date;
          a4(indx) := t(ddindx).content_type_code;
          a5(indx) := t(ddindx).item_reference_code;
          a6(indx) := t(ddindx).encrypt_flag;
          a7(indx) := t(ddindx).content_item_name;
          a8(indx) := t(ddindx).description;
          a9(indx) := t(ddindx).attachment_file_name;
          a10(indx) := t(ddindx).attachment_file_id;
          a11(indx) := t(ddindx).default_mime_type;
          a12(indx) := t(ddindx).default_rendition_name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure rosetta_table_copy_in_p9(t out nocopy ibc_citem_runtime_pub.content_item_id_tbl, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is null then
    t := null;
  elsif a0.count = 0 then
    t := ibc_citem_runtime_pub.content_item_id_tbl();
  else
      if a0.count > 0 then
      t := ibc_citem_runtime_pub.content_item_id_tbl();
      t.extend(a0.count);
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
  end rosetta_table_copy_in_p9;
  procedure rosetta_table_copy_out_p9(t ibc_citem_runtime_pub.content_item_id_tbl, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
  elsif t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
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
  end rosetta_table_copy_out_p9;

  procedure get_citems_meta_by_assoc(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_association_type_code  VARCHAR2
    , p_associated_object_val1  VARCHAR2
    , p_associated_object_val2  VARCHAR2
    , p_associated_object_val3  VARCHAR2
    , p_associated_object_val4  VARCHAR2
    , p_associated_object_val5  VARCHAR2
    , p_label_code  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_NUMBER_TABLE
    , p12_a2 out nocopy JTF_DATE_TABLE
    , p12_a3 out nocopy JTF_DATE_TABLE
    , p12_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a7 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a8 out nocopy JTF_VARCHAR2_TABLE_2000
    , p12_a9 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a10 out nocopy JTF_NUMBER_TABLE
    , p12_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a12 out nocopy JTF_VARCHAR2_TABLE_300
  )

  as
    ddx_content_item_meta_tbl ibc_citem_runtime_pub.content_item_meta_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any













    -- here's the delegated call to the old PL/SQL routine
    ibc_citem_runtime_pub.get_citems_meta_by_assoc(p_api_version,
      p_init_msg_list,
      p_association_type_code,
      p_associated_object_val1,
      p_associated_object_val2,
      p_associated_object_val3,
      p_associated_object_val4,
      p_associated_object_val5,
      p_label_code,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_content_item_meta_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












    ibc_citem_runtime_pub_w.rosetta_table_copy_out_p7(ddx_content_item_meta_tbl, p12_a0
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
      , p12_a11
      , p12_a12
      );
  end;

  procedure get_citems_meta_by_assoc_ctyp(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_association_type_code  VARCHAR2
    , p_associated_object_val1  VARCHAR2
    , p_associated_object_val2  VARCHAR2
    , p_associated_object_val3  VARCHAR2
    , p_associated_object_val4  VARCHAR2
    , p_associated_object_val5  VARCHAR2
    , p_content_type_code  VARCHAR2
    , p_label_code  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p13_a0 out nocopy JTF_NUMBER_TABLE
    , p13_a1 out nocopy JTF_NUMBER_TABLE
    , p13_a2 out nocopy JTF_DATE_TABLE
    , p13_a3 out nocopy JTF_DATE_TABLE
    , p13_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a7 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a8 out nocopy JTF_VARCHAR2_TABLE_2000
    , p13_a9 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a10 out nocopy JTF_NUMBER_TABLE
    , p13_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a12 out nocopy JTF_VARCHAR2_TABLE_300
  )

  as
    ddx_content_item_meta_tbl ibc_citem_runtime_pub.content_item_meta_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any














    -- here's the delegated call to the old PL/SQL routine
    ibc_citem_runtime_pub.get_citems_meta_by_assoc_ctyp(p_api_version,
      p_init_msg_list,
      p_association_type_code,
      p_associated_object_val1,
      p_associated_object_val2,
      p_associated_object_val3,
      p_associated_object_val4,
      p_associated_object_val5,
      p_content_type_code,
      p_label_code,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_content_item_meta_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













    ibc_citem_runtime_pub_w.rosetta_table_copy_out_p7(ddx_content_item_meta_tbl, p13_a0
      , p13_a1
      , p13_a2
      , p13_a3
      , p13_a4
      , p13_a5
      , p13_a6
      , p13_a7
      , p13_a8
      , p13_a9
      , p13_a10
      , p13_a11
      , p13_a12
      );
  end;

  procedure get_citems_meta(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_content_item_ids JTF_NUMBER_TABLE
    , p_label_code  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_DATE_TABLE
    , p7_a3 out nocopy JTF_DATE_TABLE
    , p7_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a7 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a8 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a9 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a10 out nocopy JTF_NUMBER_TABLE
    , p7_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a12 out nocopy JTF_VARCHAR2_TABLE_300
  )

  as
    ddp_content_item_ids ibc_citem_runtime_pub.content_item_id_tbl;
    ddx_content_item_meta_tbl ibc_citem_runtime_pub.content_item_meta_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ibc_citem_runtime_pub_w.rosetta_table_copy_in_p9(ddp_content_item_ids, p_content_item_ids);






    -- here's the delegated call to the old PL/SQL routine
    ibc_citem_runtime_pub.get_citems_meta(p_api_version,
      p_init_msg_list,
      ddp_content_item_ids,
      p_label_code,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_content_item_meta_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    ibc_citem_runtime_pub_w.rosetta_table_copy_out_p7(ddx_content_item_meta_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      , p7_a8
      , p7_a9
      , p7_a10
      , p7_a11
      , p7_a12
      );
  end;

  procedure get_citem_meta(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_content_item_id  NUMBER
    , p_label_code  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  DATE
    , p7_a3 out nocopy  DATE
    , p7_a4 out nocopy  VARCHAR2
    , p7_a5 out nocopy  VARCHAR2
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  VARCHAR2
    , p7_a8 out nocopy  VARCHAR2
    , p7_a9 out nocopy  VARCHAR2
    , p7_a10 out nocopy  NUMBER
    , p7_a11 out nocopy  VARCHAR2
    , p7_a12 out nocopy  VARCHAR2
  )

  as
    ddx_content_item_meta ibc_citem_runtime_pub.content_item_meta_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    -- here's the delegated call to the old PL/SQL routine
    ibc_citem_runtime_pub.get_citem_meta(p_api_version,
      p_init_msg_list,
      p_content_item_id,
      p_label_code,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_content_item_meta);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddx_content_item_meta.content_item_id;
    p7_a1 := ddx_content_item_meta.version_number;
    p7_a2 := ddx_content_item_meta.available_date;
    p7_a3 := ddx_content_item_meta.expiration_date;
    p7_a4 := ddx_content_item_meta.content_type_code;
    p7_a5 := ddx_content_item_meta.item_reference_code;
    p7_a6 := ddx_content_item_meta.encrypt_flag;
    p7_a7 := ddx_content_item_meta.content_item_name;
    p7_a8 := ddx_content_item_meta.description;
    p7_a9 := ddx_content_item_meta.attachment_file_name;
    p7_a10 := ddx_content_item_meta.attachment_file_id;
    p7_a11 := ddx_content_item_meta.default_mime_type;
    p7_a12 := ddx_content_item_meta.default_rendition_name;
  end;

  procedure get_citem_basic(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_content_item_id  NUMBER
    , p_label_code  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  DATE
    , p7_a3 out nocopy  DATE
    , p7_a4 out nocopy  VARCHAR2
    , p7_a5 out nocopy  VARCHAR2
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  VARCHAR2
    , p7_a8 out nocopy  VARCHAR2
    , p7_a9 out nocopy  VARCHAR2
    , p7_a10 out nocopy  NUMBER
    , p7_a11 out nocopy  JTF_VARCHAR2_TABLE_300
    , p7_a12 out nocopy  JTF_NUMBER_TABLE
    , p7_a13 out nocopy  JTF_VARCHAR2_TABLE_100
    , p7_a14 out nocopy  JTF_VARCHAR2_TABLE_300
    , p7_a15 out nocopy  VARCHAR2
    , p7_a16 out nocopy  VARCHAR2
    , p7_a17 out nocopy  CLOB
    , p7_a18 out nocopy  JTF_VARCHAR2_TABLE_100
    , p7_a19 out nocopy  JTF_NUMBER_TABLE
  )

  as
    ddx_content_item_basic ibc_citem_runtime_pub.content_item_basic_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    -- here's the delegated call to the old PL/SQL routine
    ibc_citem_runtime_pub.get_citem_basic(p_api_version,
      p_init_msg_list,
      p_content_item_id,
      p_label_code,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_content_item_basic);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddx_content_item_basic.content_item_id;
    p7_a1 := ddx_content_item_basic.version_number;
    p7_a2 := ddx_content_item_basic.available_date;
    p7_a3 := ddx_content_item_basic.expiration_date;
    p7_a4 := ddx_content_item_basic.content_type_code;
    p7_a5 := ddx_content_item_basic.item_reference_code;
    p7_a6 := ddx_content_item_basic.encrypt_flag;
    p7_a7 := ddx_content_item_basic.content_item_name;
    p7_a8 := ddx_content_item_basic.description;
    p7_a9 := ddx_content_item_basic.attachment_file_name;
    p7_a10 := ddx_content_item_basic.attachment_file_id;
    ibc_citem_runtime_pub_w.rosetta_table_copy_out_p0(ddx_content_item_basic.rendition_file_names, p7_a11);
    ibc_citem_runtime_pub_w.rosetta_table_copy_out_p1(ddx_content_item_basic.rendition_file_ids, p7_a12);
    ibc_citem_runtime_pub_w.rosetta_table_copy_out_p2(ddx_content_item_basic.rendition_mime_types, p7_a13);
    ibc_citem_runtime_pub_w.rosetta_table_copy_out_p3(ddx_content_item_basic.rendition_names, p7_a14);
    p7_a15 := ddx_content_item_basic.default_mime_type;
    p7_a16 := ddx_content_item_basic.default_rendition_name;
    p7_a17 := ddx_content_item_basic.attribute_bundle;
    ibc_citem_runtime_pub_w.rosetta_table_copy_out_p4(ddx_content_item_basic.comp_item_attrib_tcodes, p7_a18);
    ibc_citem_runtime_pub_w.rosetta_table_copy_out_p5(ddx_content_item_basic.comp_item_citem_ids, p7_a19);
  end;

end ibc_citem_runtime_pub_w;

/
