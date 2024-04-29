--------------------------------------------------------
--  DDL for Package Body CN_QUOTA_ASSIGN_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_QUOTA_ASSIGN_PVT_W" as
  /* $Header: cnwpnagb.pls 120.4 2006/05/11 06:06 kjayapau noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy cn_quota_assign_pvt.quota_assign_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_1900
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).quota_assign_id := a0(indx);
          t(ddindx).quota_id := a1(indx);
          t(ddindx).comp_plan_id := a2(indx);
          t(ddindx).name := a3(indx);
          t(ddindx).description := a4(indx);
          t(ddindx).start_date := a5(indx);
          t(ddindx).end_date := a6(indx);
          t(ddindx).quota_sequence := a7(indx);
          t(ddindx).object_version_number := a8(indx);
          t(ddindx).org_id := a9(indx);
          t(ddindx).idq_flag := a10(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t cn_quota_assign_pvt.quota_assign_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_1900
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_1900();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_1900();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).quota_assign_id;
          a1(indx) := t(ddindx).quota_id;
          a2(indx) := t(ddindx).comp_plan_id;
          a3(indx) := t(ddindx).name;
          a4(indx) := t(ddindx).description;
          a5(indx) := t(ddindx).start_date;
          a6(indx) := t(ddindx).end_date;
          a7(indx) := t(ddindx).quota_sequence;
          a8(indx) := t(ddindx).object_version_number;
          a9(indx) := t(ddindx).org_id;
          a10(indx) := t(ddindx).idq_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure create_quota_assign(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  NUMBER
    , p4_a2 in out nocopy  NUMBER
    , p4_a3 in out nocopy  VARCHAR2
    , p4_a4 in out nocopy  VARCHAR2
    , p4_a5 in out nocopy  DATE
    , p4_a6 in out nocopy  DATE
    , p4_a7 in out nocopy  NUMBER
    , p4_a8 in out nocopy  NUMBER
    , p4_a9 in out nocopy  NUMBER
    , p4_a10 in out nocopy  VARCHAR
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_quota_assign cn_quota_assign_pvt.quota_assign_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_quota_assign.quota_assign_id := p4_a0;
    ddp_quota_assign.quota_id := p4_a1;
    ddp_quota_assign.comp_plan_id := p4_a2;
    ddp_quota_assign.name := p4_a3;
    ddp_quota_assign.description := p4_a4;
    ddp_quota_assign.start_date := p4_a5;
    ddp_quota_assign.end_date := p4_a6;
    ddp_quota_assign.quota_sequence := p4_a7;
    ddp_quota_assign.object_version_number := p4_a8;
    ddp_quota_assign.org_id := p4_a9;
    ddp_quota_assign.idq_flag := p4_a10;




    -- here's the delegated call to the old PL/SQL routine
    cn_quota_assign_pvt.create_quota_assign(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_quota_assign,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := ddp_quota_assign.quota_assign_id;
    p4_a1 := ddp_quota_assign.quota_id;
    p4_a2 := ddp_quota_assign.comp_plan_id;
    p4_a3 := ddp_quota_assign.name;
    p4_a4 := ddp_quota_assign.description;
    p4_a5 := ddp_quota_assign.start_date;
    p4_a6 := ddp_quota_assign.end_date;
    p4_a7 := ddp_quota_assign.quota_sequence;
    p4_a8 := ddp_quota_assign.object_version_number;
    p4_a9 := ddp_quota_assign.org_id;
    p4_a10 := ddp_quota_assign.idq_flag;



  end;

  procedure update_quota_assign(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  NUMBER
    , p4_a2 in out nocopy  NUMBER
    , p4_a3 in out nocopy  VARCHAR2
    , p4_a4 in out nocopy  VARCHAR2
    , p4_a5 in out nocopy  DATE
    , p4_a6 in out nocopy  DATE
    , p4_a7 in out nocopy  NUMBER
    , p4_a8 in out nocopy  NUMBER
    , p4_a9 in out nocopy  NUMBER
    , p4_a10 in out nocopy  VARCHAR
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_quota_assign cn_quota_assign_pvt.quota_assign_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_quota_assign.quota_assign_id := p4_a0;
    ddp_quota_assign.quota_id := p4_a1;
    ddp_quota_assign.comp_plan_id := p4_a2;
    ddp_quota_assign.name := p4_a3;
    ddp_quota_assign.description := p4_a4;
    ddp_quota_assign.start_date := p4_a5;
    ddp_quota_assign.end_date := p4_a6;
    ddp_quota_assign.quota_sequence := p4_a7;
    ddp_quota_assign.object_version_number := p4_a8;
    ddp_quota_assign.org_id := p4_a9;
    ddp_quota_assign.idq_flag := p4_a10;




    -- here's the delegated call to the old PL/SQL routine
    cn_quota_assign_pvt.update_quota_assign(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_quota_assign,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := ddp_quota_assign.quota_assign_id;
    p4_a1 := ddp_quota_assign.quota_id;
    p4_a2 := ddp_quota_assign.comp_plan_id;
    p4_a3 := ddp_quota_assign.name;
    p4_a4 := ddp_quota_assign.description;
    p4_a5 := ddp_quota_assign.start_date;
    p4_a6 := ddp_quota_assign.end_date;
    p4_a7 := ddp_quota_assign.quota_sequence;
    p4_a8 := ddp_quota_assign.object_version_number;
    p4_a9 := ddp_quota_assign.org_id;
    p4_a10 := ddp_quota_assign.idq_flag;



  end;

  procedure delete_quota_assign(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  NUMBER
    , p4_a3  VARCHAR2
    , p4_a4  VARCHAR2
    , p4_a5  DATE
    , p4_a6  DATE
    , p4_a7  NUMBER
    , p4_a8  NUMBER
    , p4_a9  NUMBER
    , p4_a10  VARCHAR
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_quota_assign cn_quota_assign_pvt.quota_assign_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_quota_assign.quota_assign_id := p4_a0;
    ddp_quota_assign.quota_id := p4_a1;
    ddp_quota_assign.comp_plan_id := p4_a2;
    ddp_quota_assign.name := p4_a3;
    ddp_quota_assign.description := p4_a4;
    ddp_quota_assign.start_date := p4_a5;
    ddp_quota_assign.end_date := p4_a6;
    ddp_quota_assign.quota_sequence := p4_a7;
    ddp_quota_assign.object_version_number := p4_a8;
    ddp_quota_assign.org_id := p4_a9;
    ddp_quota_assign.idq_flag := p4_a10;




    -- here's the delegated call to the old PL/SQL routine
    cn_quota_assign_pvt.delete_quota_assign(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_quota_assign,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure get_quota_assign(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_comp_plan_id  NUMBER
    , p5_a0 out nocopy JTF_NUMBER_TABLE
    , p5_a1 out nocopy JTF_NUMBER_TABLE
    , p5_a2 out nocopy JTF_NUMBER_TABLE
    , p5_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a4 out nocopy JTF_VARCHAR2_TABLE_1900
    , p5_a5 out nocopy JTF_DATE_TABLE
    , p5_a6 out nocopy JTF_DATE_TABLE
    , p5_a7 out nocopy JTF_NUMBER_TABLE
    , p5_a8 out nocopy JTF_NUMBER_TABLE
    , p5_a9 out nocopy JTF_NUMBER_TABLE
    , p5_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_quota_assign cn_quota_assign_pvt.quota_assign_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    cn_quota_assign_pvt.get_quota_assign(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_comp_plan_id,
      ddx_quota_assign,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    cn_quota_assign_pvt_w.rosetta_table_copy_out_p1(ddx_quota_assign, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      );



  end;

end cn_quota_assign_pvt_w;

/
