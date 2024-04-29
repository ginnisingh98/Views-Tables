--------------------------------------------------------
--  DDL for Package Body CN_QUOTA_RULE_UPLIFT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_QUOTA_RULE_UPLIFT_PVT_W" as
  /* $Header: cnwrlutb.pls 120.3 2005/09/14 04:29 rarajara ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy cn_quota_rule_uplift_pvt.quota_rule_uplift_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_DATE_TABLE
    , a11 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).org_id := a0(indx);
          t(ddindx).quota_rule_uplift_id := a1(indx);
          t(ddindx).quota_rule_id := a2(indx);
          t(ddindx).start_date := a3(indx);
          t(ddindx).end_date := a4(indx);
          t(ddindx).payment_factor := a5(indx);
          t(ddindx).quota_factor := a6(indx);
          t(ddindx).object_version_number := a7(indx);
          t(ddindx).rev_class_name := a8(indx);
          t(ddindx).rev_class_name_old := a9(indx);
          t(ddindx).start_date_old := a10(indx);
          t(ddindx).end_date_old := a11(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t cn_quota_rule_uplift_pvt.quota_rule_uplift_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_DATE_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).org_id;
          a1(indx) := t(ddindx).quota_rule_uplift_id;
          a2(indx) := t(ddindx).quota_rule_id;
          a3(indx) := t(ddindx).start_date;
          a4(indx) := t(ddindx).end_date;
          a5(indx) := t(ddindx).payment_factor;
          a6(indx) := t(ddindx).quota_factor;
          a7(indx) := t(ddindx).object_version_number;
          a8(indx) := t(ddindx).rev_class_name;
          a9(indx) := t(ddindx).rev_class_name_old;
          a10(indx) := t(ddindx).start_date_old;
          a11(indx) := t(ddindx).end_date_old;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure validate_uplift(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_action  VARCHAR2
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  NUMBER
    , p5_a2 in out nocopy  NUMBER
    , p5_a3 in out nocopy  DATE
    , p5_a4 in out nocopy  DATE
    , p5_a5 in out nocopy  NUMBER
    , p5_a6 in out nocopy  NUMBER
    , p5_a7 in out nocopy  NUMBER
    , p5_a8 in out nocopy  VARCHAR2
    , p5_a9 in out nocopy  VARCHAR2
    , p5_a10 in out nocopy  DATE
    , p5_a11 in out nocopy  DATE
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  NUMBER
    , p6_a3  DATE
    , p6_a4  DATE
    , p6_a5  NUMBER
    , p6_a6  NUMBER
    , p6_a7  NUMBER
    , p6_a8  VARCHAR2
    , p6_a9  VARCHAR2
    , p6_a10  DATE
    , p6_a11  DATE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_quota_rule_uplift cn_quota_rule_uplift_pvt.quota_rule_uplift_rec_type;
    ddp_old_quota_rule_uplift cn_quota_rule_uplift_pvt.quota_rule_uplift_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_quota_rule_uplift.org_id := p5_a0;
    ddp_quota_rule_uplift.quota_rule_uplift_id := p5_a1;
    ddp_quota_rule_uplift.quota_rule_id := p5_a2;
    ddp_quota_rule_uplift.start_date := p5_a3;
    ddp_quota_rule_uplift.end_date := p5_a4;
    ddp_quota_rule_uplift.payment_factor := p5_a5;
    ddp_quota_rule_uplift.quota_factor := p5_a6;
    ddp_quota_rule_uplift.object_version_number := p5_a7;
    ddp_quota_rule_uplift.rev_class_name := p5_a8;
    ddp_quota_rule_uplift.rev_class_name_old := p5_a9;
    ddp_quota_rule_uplift.start_date_old := p5_a10;
    ddp_quota_rule_uplift.end_date_old := p5_a11;

    ddp_old_quota_rule_uplift.org_id := p6_a0;
    ddp_old_quota_rule_uplift.quota_rule_uplift_id := p6_a1;
    ddp_old_quota_rule_uplift.quota_rule_id := p6_a2;
    ddp_old_quota_rule_uplift.start_date := p6_a3;
    ddp_old_quota_rule_uplift.end_date := p6_a4;
    ddp_old_quota_rule_uplift.payment_factor := p6_a5;
    ddp_old_quota_rule_uplift.quota_factor := p6_a6;
    ddp_old_quota_rule_uplift.object_version_number := p6_a7;
    ddp_old_quota_rule_uplift.rev_class_name := p6_a8;
    ddp_old_quota_rule_uplift.rev_class_name_old := p6_a9;
    ddp_old_quota_rule_uplift.start_date_old := p6_a10;
    ddp_old_quota_rule_uplift.end_date_old := p6_a11;




    -- here's the delegated call to the old PL/SQL routine
    cn_quota_rule_uplift_pvt.validate_uplift(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_action,
      ddp_quota_rule_uplift,
      ddp_old_quota_rule_uplift,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    p5_a0 := ddp_quota_rule_uplift.org_id;
    p5_a1 := ddp_quota_rule_uplift.quota_rule_uplift_id;
    p5_a2 := ddp_quota_rule_uplift.quota_rule_id;
    p5_a3 := ddp_quota_rule_uplift.start_date;
    p5_a4 := ddp_quota_rule_uplift.end_date;
    p5_a5 := ddp_quota_rule_uplift.payment_factor;
    p5_a6 := ddp_quota_rule_uplift.quota_factor;
    p5_a7 := ddp_quota_rule_uplift.object_version_number;
    p5_a8 := ddp_quota_rule_uplift.rev_class_name;
    p5_a9 := ddp_quota_rule_uplift.rev_class_name_old;
    p5_a10 := ddp_quota_rule_uplift.start_date_old;
    p5_a11 := ddp_quota_rule_uplift.end_date_old;




  end;

  procedure create_uplift(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  NUMBER
    , p4_a2 in out nocopy  NUMBER
    , p4_a3 in out nocopy  DATE
    , p4_a4 in out nocopy  DATE
    , p4_a5 in out nocopy  NUMBER
    , p4_a6 in out nocopy  NUMBER
    , p4_a7 in out nocopy  NUMBER
    , p4_a8 in out nocopy  VARCHAR2
    , p4_a9 in out nocopy  VARCHAR2
    , p4_a10 in out nocopy  DATE
    , p4_a11 in out nocopy  DATE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_quota_rule_uplift cn_quota_rule_uplift_pvt.quota_rule_uplift_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_quota_rule_uplift.org_id := p4_a0;
    ddp_quota_rule_uplift.quota_rule_uplift_id := p4_a1;
    ddp_quota_rule_uplift.quota_rule_id := p4_a2;
    ddp_quota_rule_uplift.start_date := p4_a3;
    ddp_quota_rule_uplift.end_date := p4_a4;
    ddp_quota_rule_uplift.payment_factor := p4_a5;
    ddp_quota_rule_uplift.quota_factor := p4_a6;
    ddp_quota_rule_uplift.object_version_number := p4_a7;
    ddp_quota_rule_uplift.rev_class_name := p4_a8;
    ddp_quota_rule_uplift.rev_class_name_old := p4_a9;
    ddp_quota_rule_uplift.start_date_old := p4_a10;
    ddp_quota_rule_uplift.end_date_old := p4_a11;




    -- here's the delegated call to the old PL/SQL routine
    cn_quota_rule_uplift_pvt.create_uplift(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_quota_rule_uplift,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := ddp_quota_rule_uplift.org_id;
    p4_a1 := ddp_quota_rule_uplift.quota_rule_uplift_id;
    p4_a2 := ddp_quota_rule_uplift.quota_rule_id;
    p4_a3 := ddp_quota_rule_uplift.start_date;
    p4_a4 := ddp_quota_rule_uplift.end_date;
    p4_a5 := ddp_quota_rule_uplift.payment_factor;
    p4_a6 := ddp_quota_rule_uplift.quota_factor;
    p4_a7 := ddp_quota_rule_uplift.object_version_number;
    p4_a8 := ddp_quota_rule_uplift.rev_class_name;
    p4_a9 := ddp_quota_rule_uplift.rev_class_name_old;
    p4_a10 := ddp_quota_rule_uplift.start_date_old;
    p4_a11 := ddp_quota_rule_uplift.end_date_old;



  end;

  procedure update_uplift(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  NUMBER
    , p4_a2 in out nocopy  NUMBER
    , p4_a3 in out nocopy  DATE
    , p4_a4 in out nocopy  DATE
    , p4_a5 in out nocopy  NUMBER
    , p4_a6 in out nocopy  NUMBER
    , p4_a7 in out nocopy  NUMBER
    , p4_a8 in out nocopy  VARCHAR2
    , p4_a9 in out nocopy  VARCHAR2
    , p4_a10 in out nocopy  DATE
    , p4_a11 in out nocopy  DATE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_quota_rule_uplift cn_quota_rule_uplift_pvt.quota_rule_uplift_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_quota_rule_uplift.org_id := p4_a0;
    ddp_quota_rule_uplift.quota_rule_uplift_id := p4_a1;
    ddp_quota_rule_uplift.quota_rule_id := p4_a2;
    ddp_quota_rule_uplift.start_date := p4_a3;
    ddp_quota_rule_uplift.end_date := p4_a4;
    ddp_quota_rule_uplift.payment_factor := p4_a5;
    ddp_quota_rule_uplift.quota_factor := p4_a6;
    ddp_quota_rule_uplift.object_version_number := p4_a7;
    ddp_quota_rule_uplift.rev_class_name := p4_a8;
    ddp_quota_rule_uplift.rev_class_name_old := p4_a9;
    ddp_quota_rule_uplift.start_date_old := p4_a10;
    ddp_quota_rule_uplift.end_date_old := p4_a11;




    -- here's the delegated call to the old PL/SQL routine
    cn_quota_rule_uplift_pvt.update_uplift(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_quota_rule_uplift,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := ddp_quota_rule_uplift.org_id;
    p4_a1 := ddp_quota_rule_uplift.quota_rule_uplift_id;
    p4_a2 := ddp_quota_rule_uplift.quota_rule_id;
    p4_a3 := ddp_quota_rule_uplift.start_date;
    p4_a4 := ddp_quota_rule_uplift.end_date;
    p4_a5 := ddp_quota_rule_uplift.payment_factor;
    p4_a6 := ddp_quota_rule_uplift.quota_factor;
    p4_a7 := ddp_quota_rule_uplift.object_version_number;
    p4_a8 := ddp_quota_rule_uplift.rev_class_name;
    p4_a9 := ddp_quota_rule_uplift.rev_class_name_old;
    p4_a10 := ddp_quota_rule_uplift.start_date_old;
    p4_a11 := ddp_quota_rule_uplift.end_date_old;



  end;

  procedure delete_uplift(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  NUMBER
    , p4_a2 in out nocopy  NUMBER
    , p4_a3 in out nocopy  DATE
    , p4_a4 in out nocopy  DATE
    , p4_a5 in out nocopy  NUMBER
    , p4_a6 in out nocopy  NUMBER
    , p4_a7 in out nocopy  NUMBER
    , p4_a8 in out nocopy  VARCHAR2
    , p4_a9 in out nocopy  VARCHAR2
    , p4_a10 in out nocopy  DATE
    , p4_a11 in out nocopy  DATE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_quota_rule_uplift cn_quota_rule_uplift_pvt.quota_rule_uplift_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_quota_rule_uplift.org_id := p4_a0;
    ddp_quota_rule_uplift.quota_rule_uplift_id := p4_a1;
    ddp_quota_rule_uplift.quota_rule_id := p4_a2;
    ddp_quota_rule_uplift.start_date := p4_a3;
    ddp_quota_rule_uplift.end_date := p4_a4;
    ddp_quota_rule_uplift.payment_factor := p4_a5;
    ddp_quota_rule_uplift.quota_factor := p4_a6;
    ddp_quota_rule_uplift.object_version_number := p4_a7;
    ddp_quota_rule_uplift.rev_class_name := p4_a8;
    ddp_quota_rule_uplift.rev_class_name_old := p4_a9;
    ddp_quota_rule_uplift.start_date_old := p4_a10;
    ddp_quota_rule_uplift.end_date_old := p4_a11;




    -- here's the delegated call to the old PL/SQL routine
    cn_quota_rule_uplift_pvt.delete_uplift(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_quota_rule_uplift,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := ddp_quota_rule_uplift.org_id;
    p4_a1 := ddp_quota_rule_uplift.quota_rule_uplift_id;
    p4_a2 := ddp_quota_rule_uplift.quota_rule_id;
    p4_a3 := ddp_quota_rule_uplift.start_date;
    p4_a4 := ddp_quota_rule_uplift.end_date;
    p4_a5 := ddp_quota_rule_uplift.payment_factor;
    p4_a6 := ddp_quota_rule_uplift.quota_factor;
    p4_a7 := ddp_quota_rule_uplift.object_version_number;
    p4_a8 := ddp_quota_rule_uplift.rev_class_name;
    p4_a9 := ddp_quota_rule_uplift.rev_class_name_old;
    p4_a10 := ddp_quota_rule_uplift.start_date_old;
    p4_a11 := ddp_quota_rule_uplift.end_date_old;



  end;

end cn_quota_rule_uplift_pvt_w;

/
