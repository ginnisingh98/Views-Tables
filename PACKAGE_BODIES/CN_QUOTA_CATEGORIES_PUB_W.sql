--------------------------------------------------------
--  DDL for Package Body CN_QUOTA_CATEGORIES_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_QUOTA_CATEGORIES_PUB_W" as
  /* $Header: cnwqcatb.pls 115.8 2002/11/25 22:26:17 nkodkani ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p1(t out nocopy cn_quota_categories_pub.quota_categories_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).quota_category_id := a0(indx);
          t(ddindx).name := a1(indx);
          t(ddindx).description := a2(indx);
          t(ddindx).type := a3(indx);
          t(ddindx).type_meaning := a4(indx);
          t(ddindx).compute_flag := a5(indx);
          t(ddindx).computed := a6(indx);
          t(ddindx).interval_type_id := a7(indx);
          t(ddindx).quota_unit_code := a8(indx);
          t(ddindx).object_version_number := a9(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t cn_quota_categories_pub.quota_categories_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).quota_category_id;
          a1(indx) := t(ddindx).name;
          a2(indx) := t(ddindx).description;
          a3(indx) := t(ddindx).type;
          a4(indx) := t(ddindx).type_meaning;
          a5(indx) := t(ddindx).compute_flag;
          a6(indx) := t(ddindx).computed;
          a7(indx) := t(ddindx).interval_type_id;
          a8(indx) := t(ddindx).quota_unit_code;
          a9(indx) := t(ddindx).object_version_number;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure create_quota_category(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  VARCHAR2
    , p4_a2  VARCHAR2
    , p4_a3  VARCHAR2
    , p4_a4  VARCHAR2
    , p4_a5  VARCHAR2
    , p4_a6  VARCHAR2
    , p4_a7  NUMBER
    , p4_a8  VARCHAR2
    , p4_a9  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_quota_category_id out nocopy  NUMBER
  )

  as
    ddp_rec cn_quota_categories_pub.quota_category_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_rec.quota_category_id := p4_a0;
    ddp_rec.name := p4_a1;
    ddp_rec.description := p4_a2;
    ddp_rec.type := p4_a3;
    ddp_rec.type_meaning := p4_a4;
    ddp_rec.compute_flag := p4_a5;
    ddp_rec.computed := p4_a6;
    ddp_rec.interval_type_id := p4_a7;
    ddp_rec.quota_unit_code := p4_a8;
    ddp_rec.object_version_number := p4_a9;





    -- here's the delegated call to the old PL/SQL routine
    cn_quota_categories_pub.create_quota_category(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_rec,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_quota_category_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_quota_category(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  VARCHAR2
    , p4_a2  VARCHAR2
    , p4_a3  VARCHAR2
    , p4_a4  VARCHAR2
    , p4_a5  VARCHAR2
    , p4_a6  VARCHAR2
    , p4_a7  NUMBER
    , p4_a8  VARCHAR2
    , p4_a9  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_rec cn_quota_categories_pub.quota_category_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_rec.quota_category_id := p4_a0;
    ddp_rec.name := p4_a1;
    ddp_rec.description := p4_a2;
    ddp_rec.type := p4_a3;
    ddp_rec.type_meaning := p4_a4;
    ddp_rec.compute_flag := p4_a5;
    ddp_rec.computed := p4_a6;
    ddp_rec.interval_type_id := p4_a7;
    ddp_rec.quota_unit_code := p4_a8;
    ddp_rec.object_version_number := p4_a9;




    -- here's the delegated call to the old PL/SQL routine
    cn_quota_categories_pub.update_quota_category(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure get_quota_category_details(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_start_record  NUMBER
    , p_increment_count  NUMBER
    , p_search_name  VARCHAR2
    , p_search_type  VARCHAR2
    , p_search_unit  VARCHAR2
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a7 out nocopy JTF_NUMBER_TABLE
    , p11_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a9 out nocopy JTF_NUMBER_TABLE
    , x_total_records out nocopy  NUMBER
  )

  as
    ddx_quota_categories_tbl cn_quota_categories_pub.quota_categories_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any













    -- here's the delegated call to the old PL/SQL routine
    cn_quota_categories_pub.get_quota_category_details(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_start_record,
      p_increment_count,
      p_search_name,
      p_search_type,
      p_search_unit,
      ddx_quota_categories_tbl,
      x_total_records);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











    cn_quota_categories_pub_w.rosetta_table_copy_out_p1(ddx_quota_categories_tbl, p11_a0
      , p11_a1
      , p11_a2
      , p11_a3
      , p11_a4
      , p11_a5
      , p11_a6
      , p11_a7
      , p11_a8
      , p11_a9
      );

  end;

end cn_quota_categories_pub_w;

/
