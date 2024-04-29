--------------------------------------------------------
--  DDL for Package Body AMV_SEARCH_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMV_SEARCH_PVT_W" as
  /* $Header: amvwserb.pls 120.2 2005/06/30 08:43 appldev ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  procedure rosetta_table_copy_in_p0(t out nocopy amv_search_pvt.amv_char_varray_type, a0 JTF_VARCHAR2_TABLE_4000) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is null then
    t := null;
  elsif a0.count = 0 then
    t := amv_search_pvt.amv_char_varray_type();
  else
      if a0.count > 0 then
      t := amv_search_pvt.amv_char_varray_type();
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
  procedure rosetta_table_copy_out_p0(t amv_search_pvt.amv_char_varray_type, a0 out nocopy JTF_VARCHAR2_TABLE_4000) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
  elsif t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_4000();
  else
      a0 := JTF_VARCHAR2_TABLE_4000();
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

  procedure rosetta_table_copy_in_p1(t out nocopy amv_search_pvt.amv_number_varray_type, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is null then
    t := null;
  elsif a0.count = 0 then
    t := amv_search_pvt.amv_number_varray_type();
  else
      if a0.count > 0 then
      t := amv_search_pvt.amv_number_varray_type();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t amv_search_pvt.amv_number_varray_type, a0 out nocopy JTF_NUMBER_TABLE) as
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p5(t out nocopy amv_search_pvt.amv_area_varray_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count=0 then
    t := amv_search_pvt.amv_area_varray_type();
  elsif a0 is not null and a0.count > 0 then
      if a0.count > 0 then
      t := amv_search_pvt.amv_area_varray_type();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).area_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).area_code := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t amv_search_pvt.amv_area_varray_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
    a1 := null;
  elsif t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).area_id);
          a1(indx) := t(ddindx).area_code;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p7(t out nocopy amv_search_pvt.amv_searchrep_varray_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count=0 then
    t := amv_search_pvt.amv_searchrep_varray_type();
  elsif a0 is not null and a0.count > 0 then
      if a0.count > 0 then
      t := amv_search_pvt.amv_searchrep_varray_type();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).repository_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).repository_code := a1(indx);
          t(ddindx).repository_name := a2(indx);
          t(ddindx).status := a3(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a4(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t amv_search_pvt.amv_searchrep_varray_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
    a1 := null;
    a2 := null;
    a3 := null;
    a4 := null;
  elsif t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).repository_id);
          a1(indx) := t(ddindx).repository_code;
          a2(indx) := t(ddindx).repository_name;
          a3(indx) := t(ddindx).status;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure rosetta_table_copy_in_p9(t out nocopy amv_search_pvt.amv_searchara_varray_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count=0 then
    t := amv_search_pvt.amv_searchara_varray_type();
  elsif a0 is not null and a0.count > 0 then
      if a0.count > 0 then
      t := amv_search_pvt.amv_searchara_varray_type();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).repository_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).repository_code := a1(indx);
          t(ddindx).area_indicator := a2(indx);
          t(ddindx).area_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).area_code := a4(indx);
          t(ddindx).area_name := a5(indx);
          t(ddindx).status := a6(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a7(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p9;
  procedure rosetta_table_copy_out_p9(t amv_search_pvt.amv_searchara_varray_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
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
  elsif t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        a7.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).repository_id);
          a1(indx) := t(ddindx).repository_code;
          a2(indx) := t(ddindx).area_indicator;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).area_id);
          a4(indx) := t(ddindx).area_code;
          a5(indx) := t(ddindx).area_name;
          a6(indx) := t(ddindx).status;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p9;

  procedure rosetta_table_copy_in_p11(t out nocopy amv_search_pvt.amv_searchpar_varray_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_400
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count=0 then
    t := amv_search_pvt.amv_searchpar_varray_type();
  elsif a0 is not null and a0.count > 0 then
      if a0.count > 0 then
      t := amv_search_pvt.amv_searchpar_varray_type();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).operator := a0(indx);
          t(ddindx).search_string := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p11;
  procedure rosetta_table_copy_out_p11(t amv_search_pvt.amv_searchpar_varray_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_400
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
    a1 := null;
  elsif t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_400();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_400();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).operator;
          a1(indx) := t(ddindx).search_string;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p11;

  procedure rosetta_table_copy_in_p13(t out nocopy amv_search_pvt.amv_searchres_varray_type, a0 JTF_VARCHAR2_TABLE_300
    , a1 JTF_VARCHAR2_TABLE_2000
    , a2 JTF_VARCHAR2_TABLE_4000
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count=0 then
    t := amv_search_pvt.amv_searchres_varray_type();
  elsif a0 is not null and a0.count > 0 then
      if a0.count > 0 then
      t := amv_search_pvt.amv_searchres_varray_type();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).title := a0(indx);
          t(ddindx).url_string := a1(indx);
          t(ddindx).description := a2(indx);
          t(ddindx).score := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).area_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).area_code := a5(indx);
          t(ddindx).user1 := a6(indx);
          t(ddindx).user2 := a7(indx);
          t(ddindx).user3 := a8(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p13;
  procedure rosetta_table_copy_out_p13(t amv_search_pvt.amv_searchres_varray_type, a0 out nocopy JTF_VARCHAR2_TABLE_300
    , a1 out nocopy JTF_VARCHAR2_TABLE_2000
    , a2 out nocopy JTF_VARCHAR2_TABLE_4000
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_300
    , a7 out nocopy JTF_VARCHAR2_TABLE_300
    , a8 out nocopy JTF_VARCHAR2_TABLE_300
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
  elsif t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_300();
    a1 := JTF_VARCHAR2_TABLE_2000();
    a2 := JTF_VARCHAR2_TABLE_4000();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_300();
    a7 := JTF_VARCHAR2_TABLE_300();
    a8 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_VARCHAR2_TABLE_300();
      a1 := JTF_VARCHAR2_TABLE_2000();
      a2 := JTF_VARCHAR2_TABLE_4000();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_300();
      a7 := JTF_VARCHAR2_TABLE_300();
      a8 := JTF_VARCHAR2_TABLE_300();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).title;
          a1(indx) := t(ddindx).url_string;
          a2(indx) := t(ddindx).description;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).score);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).area_id);
          a5(indx) := t(ddindx).area_code;
          a6(indx) := t(ddindx).user1;
          a7(indx) := t(ddindx).user2;
          a8(indx) := t(ddindx).user3;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p13;

  procedure find_repositories(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_object_version_number  NUMBER
    , p_repository_id  NUMBER
    , p_repository_code  VARCHAR2
    , p_repository_name  VARCHAR2
    , p_status  VARCHAR2
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a4 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddx_searchrep_array amv_search_pvt.amv_searchrep_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any













    -- here's the delegated call to the old PL/SQL routine
    amv_search_pvt.find_repositories(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_object_version_number,
      p_repository_id,
      p_repository_code,
      p_repository_name,
      p_status,
      ddx_searchrep_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












    amv_search_pvt_w.rosetta_table_copy_out_p7(ddx_searchrep_array, p12_a0
      , p12_a1
      , p12_a2
      , p12_a3
      , p12_a4
      );
  end;

  procedure find_repository_areas(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 out nocopy JTF_NUMBER_TABLE
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  VARCHAR2 := fnd_api.g_miss_char
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  VARCHAR2 := fnd_api.g_miss_char
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  NUMBER := 0-1962.0724
  )

  as
    ddp_searcharea_obj amv_search_pvt.amv_searchara_obj_type;
    ddx_searcharea_array amv_search_pvt.amv_searchara_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_searcharea_obj.repository_id := rosetta_g_miss_num_map(p7_a0);
    ddp_searcharea_obj.repository_code := p7_a1;
    ddp_searcharea_obj.area_indicator := p7_a2;
    ddp_searcharea_obj.area_id := rosetta_g_miss_num_map(p7_a3);
    ddp_searcharea_obj.area_code := p7_a4;
    ddp_searcharea_obj.area_name := p7_a5;
    ddp_searcharea_obj.status := p7_a6;
    ddp_searcharea_obj.object_version_number := rosetta_g_miss_num_map(p7_a7);


    -- here's the delegated call to the old PL/SQL routine
    amv_search_pvt.find_repository_areas(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      ddp_searcharea_obj,
      ddx_searcharea_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    amv_search_pvt_w.rosetta_table_copy_out_p9(ddx_searcharea_array, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      );
  end;

  procedure content_search(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_application_id  NUMBER
    , p_area_array JTF_VARCHAR2_TABLE_4000
    , p_content_array JTF_VARCHAR2_TABLE_4000
    , p10_a0 JTF_VARCHAR2_TABLE_100
    , p10_a1 JTF_VARCHAR2_TABLE_400
    , p_imt_string  VARCHAR2
    , p_days  NUMBER
    , p_user_id  NUMBER
    , p_category_id JTF_NUMBER_TABLE
    , p_include_subcats  VARCHAR2
    , p_external_contents  VARCHAR2
    , p18_a0 out nocopy  NUMBER
    , p18_a1 out nocopy  NUMBER
    , p18_a2 out nocopy  NUMBER
    , p19_a0 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a1 out nocopy JTF_VARCHAR2_TABLE_2000
    , p19_a2 out nocopy JTF_VARCHAR2_TABLE_4000
    , p19_a3 out nocopy JTF_NUMBER_TABLE
    , p19_a4 out nocopy JTF_NUMBER_TABLE
    , p19_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a7 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a8 out nocopy JTF_VARCHAR2_TABLE_300
    , p17_a0  NUMBER := 0-1962.0724
    , p17_a1  NUMBER := 0-1962.0724
    , p17_a2  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_area_array amv_search_pvt.amv_char_varray_type;
    ddp_content_array amv_search_pvt.amv_char_varray_type;
    ddp_param_array amv_search_pvt.amv_searchpar_varray_type;
    ddp_category_id amv_search_pvt.amv_number_varray_type;
    ddp_request_obj amv_search_pvt.amv_request_obj_type;
    ddx_return_obj amv_search_pvt.amv_return_obj_type;
    ddx_searchres_array amv_search_pvt.amv_searchres_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    amv_search_pvt_w.rosetta_table_copy_in_p0(ddp_area_array, p_area_array);

    amv_search_pvt_w.rosetta_table_copy_in_p0(ddp_content_array, p_content_array);

    amv_search_pvt_w.rosetta_table_copy_in_p11(ddp_param_array, p10_a0
      , p10_a1
      );




    amv_search_pvt_w.rosetta_table_copy_in_p1(ddp_category_id, p_category_id);



    ddp_request_obj.records_requested := rosetta_g_miss_num_map(p17_a0);
    ddp_request_obj.start_record_position := rosetta_g_miss_num_map(p17_a1);
    ddp_request_obj.return_total_count_flag := p17_a2;



    -- here's the delegated call to the old PL/SQL routine
    amv_search_pvt.content_search(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_application_id,
      ddp_area_array,
      ddp_content_array,
      ddp_param_array,
      p_imt_string,
      p_days,
      p_user_id,
      ddp_category_id,
      p_include_subcats,
      p_external_contents,
      ddp_request_obj,
      ddx_return_obj,
      ddx_searchres_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


















    p18_a0 := rosetta_g_miss_num_map(ddx_return_obj.returned_record_count);
    p18_a1 := rosetta_g_miss_num_map(ddx_return_obj.next_record_position);
    p18_a2 := rosetta_g_miss_num_map(ddx_return_obj.total_record_count);

    amv_search_pvt_w.rosetta_table_copy_out_p13(ddx_searchres_array, p19_a0
      , p19_a1
      , p19_a2
      , p19_a3
      , p19_a4
      , p19_a5
      , p19_a6
      , p19_a7
      , p19_a8
      );
  end;

  procedure build_imt_string(p_optional_array JTF_VARCHAR2_TABLE_4000
    , p_required_array JTF_VARCHAR2_TABLE_4000
    , p_excluded_array JTF_VARCHAR2_TABLE_4000
    , x_exc_flag out nocopy  VARCHAR2
    , x_imt_string out nocopy  VARCHAR2
  )

  as
    ddp_optional_array amv_search_pvt.amv_char_varray_type;
    ddp_required_array amv_search_pvt.amv_char_varray_type;
    ddp_excluded_array amv_search_pvt.amv_char_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    amv_search_pvt_w.rosetta_table_copy_in_p0(ddp_optional_array, p_optional_array);

    amv_search_pvt_w.rosetta_table_copy_in_p0(ddp_required_array, p_required_array);

    amv_search_pvt_w.rosetta_table_copy_in_p0(ddp_excluded_array, p_excluded_array);



    -- here's the delegated call to the old PL/SQL routine
    amv_search_pvt.build_imt_string(ddp_optional_array,
      ddp_required_array,
      ddp_excluded_array,
      x_exc_flag,
      x_imt_string);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




  end;

end amv_search_pvt_w;

/
