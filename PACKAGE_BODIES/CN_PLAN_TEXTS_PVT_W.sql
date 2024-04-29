--------------------------------------------------------
--  DDL for Package Body CN_PLAN_TEXTS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PLAN_TEXTS_PVT_W" as
  /* $Header: cnwsptb.pls 115.8 2002/12/04 05:03:44 fmburu ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p1(t out nocopy cn_plan_texts_pvt.plan_text_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_2000
    , a6 JTF_VARCHAR2_TABLE_2000
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).plan_text_id := a0(indx);
          t(ddindx).role_id := a1(indx);
          t(ddindx).sequence_id := a2(indx);
          t(ddindx).quota_category_id := a3(indx);
          t(ddindx).text_type := a4(indx);
          t(ddindx).text := a5(indx);
          t(ddindx).text2 := a6(indx);
          t(ddindx).object_version_number := a7(indx);
          t(ddindx).role_model_id := a8(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t cn_plan_texts_pvt.plan_text_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_2000
    , a6 out nocopy JTF_VARCHAR2_TABLE_2000
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_2000();
    a6 := JTF_VARCHAR2_TABLE_2000();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_2000();
      a6 := JTF_VARCHAR2_TABLE_2000();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
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
          a0(indx) := t(ddindx).plan_text_id;
          a1(indx) := t(ddindx).role_id;
          a2(indx) := t(ddindx).sequence_id;
          a3(indx) := t(ddindx).quota_category_id;
          a4(indx) := t(ddindx).text_type;
          a5(indx) := t(ddindx).text;
          a6(indx) := t(ddindx).text2;
          a7(indx) := t(ddindx).object_version_number;
          a8(indx) := t(ddindx).role_model_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p3(t out nocopy cn_plan_texts_pvt.quota_cate_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).quota_cate_id := a0(indx);
          t(ddindx).quota_name := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t cn_plan_texts_pvt.quota_cate_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
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
          a0(indx) := t(ddindx).quota_cate_id;
          a1(indx) := t(ddindx).quota_name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure create_plan_text(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  NUMBER
    , p4_a3  NUMBER
    , p4_a4  VARCHAR2
    , p4_a5  VARCHAR2
    , p4_a6  VARCHAR2
    , p4_a7  NUMBER
    , p4_a8  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_plan_text cn_plan_texts_pvt.plan_text_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_plan_text.plan_text_id := p4_a0;
    ddp_plan_text.role_id := p4_a1;
    ddp_plan_text.sequence_id := p4_a2;
    ddp_plan_text.quota_category_id := p4_a3;
    ddp_plan_text.text_type := p4_a4;
    ddp_plan_text.text := p4_a5;
    ddp_plan_text.text2 := p4_a6;
    ddp_plan_text.object_version_number := p4_a7;
    ddp_plan_text.role_model_id := p4_a8;




    -- here's the delegated call to the old PL/SQL routine
    cn_plan_texts_pvt.create_plan_text(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_plan_text,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure update_plan_text(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  NUMBER
    , p4_a3  NUMBER
    , p4_a4  VARCHAR2
    , p4_a5  VARCHAR2
    , p4_a6  VARCHAR2
    , p4_a7  NUMBER
    , p4_a8  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_plan_text cn_plan_texts_pvt.plan_text_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_plan_text.plan_text_id := p4_a0;
    ddp_plan_text.role_id := p4_a1;
    ddp_plan_text.sequence_id := p4_a2;
    ddp_plan_text.quota_category_id := p4_a3;
    ddp_plan_text.text_type := p4_a4;
    ddp_plan_text.text := p4_a5;
    ddp_plan_text.text2 := p4_a6;
    ddp_plan_text.object_version_number := p4_a7;
    ddp_plan_text.role_model_id := p4_a8;




    -- here's the delegated call to the old PL/SQL routine
    cn_plan_texts_pvt.update_plan_text(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_plan_text,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure delete_plan_text(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  NUMBER
    , p4_a3  NUMBER
    , p4_a4  VARCHAR2
    , p4_a5  VARCHAR2
    , p4_a6  VARCHAR2
    , p4_a7  NUMBER
    , p4_a8  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_plan_text cn_plan_texts_pvt.plan_text_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_plan_text.plan_text_id := p4_a0;
    ddp_plan_text.role_id := p4_a1;
    ddp_plan_text.sequence_id := p4_a2;
    ddp_plan_text.quota_category_id := p4_a3;
    ddp_plan_text.text_type := p4_a4;
    ddp_plan_text.text := p4_a5;
    ddp_plan_text.text2 := p4_a6;
    ddp_plan_text.object_version_number := p4_a7;
    ddp_plan_text.role_model_id := p4_a8;




    -- here's the delegated call to the old PL/SQL routine
    cn_plan_texts_pvt.delete_plan_text(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_plan_text,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure get_plan_texts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_role_id  NUMBER
    , p_role_model_id  NUMBER
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , x_updatable out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_plan_texts cn_plan_texts_pvt.plan_text_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    -- here's the delegated call to the old PL/SQL routine
    cn_plan_texts_pvt.get_plan_texts(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_role_id,
      p_role_model_id,
      ddx_plan_texts,
      x_updatable,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    cn_plan_texts_pvt_w.rosetta_table_copy_out_p1(ddx_plan_texts, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      );




  end;

  procedure get_fixed_quota_cates(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_role_id  NUMBER
    , p_role_model_id  NUMBER
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_quota_cates cn_plan_texts_pvt.quota_cate_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    -- here's the delegated call to the old PL/SQL routine
    cn_plan_texts_pvt.get_fixed_quota_cates(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_role_id,
      p_role_model_id,
      ddx_quota_cates,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    cn_plan_texts_pvt_w.rosetta_table_copy_out_p3(ddx_quota_cates, p6_a0
      , p6_a1
      );



  end;

  procedure get_var_quota_cates(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_role_id  NUMBER
    , p_role_model_id  NUMBER
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_quota_cates cn_plan_texts_pvt.quota_cate_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    -- here's the delegated call to the old PL/SQL routine
    cn_plan_texts_pvt.get_var_quota_cates(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_role_id,
      p_role_model_id,
      ddx_quota_cates,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    cn_plan_texts_pvt_w.rosetta_table_copy_out_p3(ddx_quota_cates, p6_a0
      , p6_a1
      );



  end;

  procedure get_quota_cates(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_role_id  NUMBER
    , p_role_model_id  NUMBER
    , p_quota_cate_type  VARCHAR2
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_quota_cates cn_plan_texts_pvt.quota_cate_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    -- here's the delegated call to the old PL/SQL routine
    cn_plan_texts_pvt.get_quota_cates(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_role_id,
      p_role_model_id,
      p_quota_cate_type,
      ddx_quota_cates,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    cn_plan_texts_pvt_w.rosetta_table_copy_out_p3(ddx_quota_cates, p7_a0
      , p7_a1
      );



  end;

end cn_plan_texts_pvt_w;

/
