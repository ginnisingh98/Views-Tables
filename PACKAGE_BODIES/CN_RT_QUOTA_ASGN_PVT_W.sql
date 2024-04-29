--------------------------------------------------------
--  DDL for Package Body CN_RT_QUOTA_ASGN_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_RT_QUOTA_ASGN_PVT_W" as
  /* $Header: cnwrtqab.pls 120.2 2005/09/14 04:29 rarajara ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy cn_rt_quota_asgn_pvt.calc_formulas_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).name := a0(indx);
          t(ddindx).calc_formula_id := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t cn_rt_quota_asgn_pvt.calc_formulas_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).name;
          a1(indx) := t(ddindx).calc_formula_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p3(t out nocopy cn_rt_quota_asgn_pvt.rt_quota_asgn_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_200
    , a11 JTF_VARCHAR2_TABLE_200
    , a12 JTF_VARCHAR2_TABLE_200
    , a13 JTF_VARCHAR2_TABLE_200
    , a14 JTF_VARCHAR2_TABLE_200
    , a15 JTF_VARCHAR2_TABLE_200
    , a16 JTF_VARCHAR2_TABLE_200
    , a17 JTF_VARCHAR2_TABLE_200
    , a18 JTF_VARCHAR2_TABLE_200
    , a19 JTF_VARCHAR2_TABLE_200
    , a20 JTF_VARCHAR2_TABLE_200
    , a21 JTF_VARCHAR2_TABLE_200
    , a22 JTF_VARCHAR2_TABLE_200
    , a23 JTF_VARCHAR2_TABLE_200
    , a24 JTF_VARCHAR2_TABLE_200
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_DATE_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_DATE_TABLE
    , a30 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).name := a0(indx);
          t(ddindx).org_id := a1(indx);
          t(ddindx).rt_quota_asgn_id := a2(indx);
          t(ddindx).quota_id := a3(indx);
          t(ddindx).start_date := a4(indx);
          t(ddindx).end_date := a5(indx);
          t(ddindx).rate_schedule_id := a6(indx);
          t(ddindx).calc_formula_id := a7(indx);
          t(ddindx).calc_formula_name := a8(indx);
          t(ddindx).attribute_category := a9(indx);
          t(ddindx).attribute1 := a10(indx);
          t(ddindx).attribute2 := a11(indx);
          t(ddindx).attribute3 := a12(indx);
          t(ddindx).attribute4 := a13(indx);
          t(ddindx).attribute5 := a14(indx);
          t(ddindx).attribute6 := a15(indx);
          t(ddindx).attribute7 := a16(indx);
          t(ddindx).attribute8 := a17(indx);
          t(ddindx).attribute9 := a18(indx);
          t(ddindx).attribute10 := a19(indx);
          t(ddindx).attribute11 := a20(indx);
          t(ddindx).attribute12 := a21(indx);
          t(ddindx).attribute13 := a22(indx);
          t(ddindx).attribute14 := a23(indx);
          t(ddindx).attribute15 := a24(indx);
          t(ddindx).object_version_number := a25(indx);
          t(ddindx).created_by := a26(indx);
          t(ddindx).creation_date := a27(indx);
          t(ddindx).last_update_login := a28(indx);
          t(ddindx).last_update_date := a29(indx);
          t(ddindx).last_updated_by := a30(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t cn_rt_quota_asgn_pvt.rt_quota_asgn_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_200
    , a11 out nocopy JTF_VARCHAR2_TABLE_200
    , a12 out nocopy JTF_VARCHAR2_TABLE_200
    , a13 out nocopy JTF_VARCHAR2_TABLE_200
    , a14 out nocopy JTF_VARCHAR2_TABLE_200
    , a15 out nocopy JTF_VARCHAR2_TABLE_200
    , a16 out nocopy JTF_VARCHAR2_TABLE_200
    , a17 out nocopy JTF_VARCHAR2_TABLE_200
    , a18 out nocopy JTF_VARCHAR2_TABLE_200
    , a19 out nocopy JTF_VARCHAR2_TABLE_200
    , a20 out nocopy JTF_VARCHAR2_TABLE_200
    , a21 out nocopy JTF_VARCHAR2_TABLE_200
    , a22 out nocopy JTF_VARCHAR2_TABLE_200
    , a23 out nocopy JTF_VARCHAR2_TABLE_200
    , a24 out nocopy JTF_VARCHAR2_TABLE_200
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_DATE_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_DATE_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_200();
    a11 := JTF_VARCHAR2_TABLE_200();
    a12 := JTF_VARCHAR2_TABLE_200();
    a13 := JTF_VARCHAR2_TABLE_200();
    a14 := JTF_VARCHAR2_TABLE_200();
    a15 := JTF_VARCHAR2_TABLE_200();
    a16 := JTF_VARCHAR2_TABLE_200();
    a17 := JTF_VARCHAR2_TABLE_200();
    a18 := JTF_VARCHAR2_TABLE_200();
    a19 := JTF_VARCHAR2_TABLE_200();
    a20 := JTF_VARCHAR2_TABLE_200();
    a21 := JTF_VARCHAR2_TABLE_200();
    a22 := JTF_VARCHAR2_TABLE_200();
    a23 := JTF_VARCHAR2_TABLE_200();
    a24 := JTF_VARCHAR2_TABLE_200();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_DATE_TABLE();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_DATE_TABLE();
    a30 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_200();
      a11 := JTF_VARCHAR2_TABLE_200();
      a12 := JTF_VARCHAR2_TABLE_200();
      a13 := JTF_VARCHAR2_TABLE_200();
      a14 := JTF_VARCHAR2_TABLE_200();
      a15 := JTF_VARCHAR2_TABLE_200();
      a16 := JTF_VARCHAR2_TABLE_200();
      a17 := JTF_VARCHAR2_TABLE_200();
      a18 := JTF_VARCHAR2_TABLE_200();
      a19 := JTF_VARCHAR2_TABLE_200();
      a20 := JTF_VARCHAR2_TABLE_200();
      a21 := JTF_VARCHAR2_TABLE_200();
      a22 := JTF_VARCHAR2_TABLE_200();
      a23 := JTF_VARCHAR2_TABLE_200();
      a24 := JTF_VARCHAR2_TABLE_200();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_DATE_TABLE();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_DATE_TABLE();
      a30 := JTF_NUMBER_TABLE();
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
        a13.extend(t.count);
        a14.extend(t.count);
        a15.extend(t.count);
        a16.extend(t.count);
        a17.extend(t.count);
        a18.extend(t.count);
        a19.extend(t.count);
        a20.extend(t.count);
        a21.extend(t.count);
        a22.extend(t.count);
        a23.extend(t.count);
        a24.extend(t.count);
        a25.extend(t.count);
        a26.extend(t.count);
        a27.extend(t.count);
        a28.extend(t.count);
        a29.extend(t.count);
        a30.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).name;
          a1(indx) := t(ddindx).org_id;
          a2(indx) := t(ddindx).rt_quota_asgn_id;
          a3(indx) := t(ddindx).quota_id;
          a4(indx) := t(ddindx).start_date;
          a5(indx) := t(ddindx).end_date;
          a6(indx) := t(ddindx).rate_schedule_id;
          a7(indx) := t(ddindx).calc_formula_id;
          a8(indx) := t(ddindx).calc_formula_name;
          a9(indx) := t(ddindx).attribute_category;
          a10(indx) := t(ddindx).attribute1;
          a11(indx) := t(ddindx).attribute2;
          a12(indx) := t(ddindx).attribute3;
          a13(indx) := t(ddindx).attribute4;
          a14(indx) := t(ddindx).attribute5;
          a15(indx) := t(ddindx).attribute6;
          a16(indx) := t(ddindx).attribute7;
          a17(indx) := t(ddindx).attribute8;
          a18(indx) := t(ddindx).attribute9;
          a19(indx) := t(ddindx).attribute10;
          a20(indx) := t(ddindx).attribute11;
          a21(indx) := t(ddindx).attribute12;
          a22(indx) := t(ddindx).attribute13;
          a23(indx) := t(ddindx).attribute14;
          a24(indx) := t(ddindx).attribute15;
          a25(indx) := t(ddindx).object_version_number;
          a26(indx) := t(ddindx).created_by;
          a27(indx) := t(ddindx).creation_date;
          a28(indx) := t(ddindx).last_update_login;
          a29(indx) := t(ddindx).last_update_date;
          a30(indx) := t(ddindx).last_updated_by;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure create_rate_table_assignment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  VARCHAR2
    , p4_a1 in out nocopy  NUMBER
    , p4_a2 in out nocopy  NUMBER
    , p4_a3 in out nocopy  NUMBER
    , p4_a4 in out nocopy  DATE
    , p4_a5 in out nocopy  DATE
    , p4_a6 in out nocopy  NUMBER
    , p4_a7 in out nocopy  NUMBER
    , p4_a8 in out nocopy  VARCHAR2
    , p4_a9 in out nocopy  VARCHAR2
    , p4_a10 in out nocopy  VARCHAR2
    , p4_a11 in out nocopy  VARCHAR2
    , p4_a12 in out nocopy  VARCHAR2
    , p4_a13 in out nocopy  VARCHAR2
    , p4_a14 in out nocopy  VARCHAR2
    , p4_a15 in out nocopy  VARCHAR2
    , p4_a16 in out nocopy  VARCHAR2
    , p4_a17 in out nocopy  VARCHAR2
    , p4_a18 in out nocopy  VARCHAR2
    , p4_a19 in out nocopy  VARCHAR2
    , p4_a20 in out nocopy  VARCHAR2
    , p4_a21 in out nocopy  VARCHAR2
    , p4_a22 in out nocopy  VARCHAR2
    , p4_a23 in out nocopy  VARCHAR2
    , p4_a24 in out nocopy  VARCHAR2
    , p4_a25 in out nocopy  NUMBER
    , p4_a26 in out nocopy  NUMBER
    , p4_a27 in out nocopy  DATE
    , p4_a28 in out nocopy  NUMBER
    , p4_a29 in out nocopy  DATE
    , p4_a30 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_rt_quota_asgn cn_rt_quota_asgn_pvt.rt_quota_asgn_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_rt_quota_asgn.name := p4_a0;
    ddp_rt_quota_asgn.org_id := p4_a1;
    ddp_rt_quota_asgn.rt_quota_asgn_id := p4_a2;
    ddp_rt_quota_asgn.quota_id := p4_a3;
    ddp_rt_quota_asgn.start_date := p4_a4;
    ddp_rt_quota_asgn.end_date := p4_a5;
    ddp_rt_quota_asgn.rate_schedule_id := p4_a6;
    ddp_rt_quota_asgn.calc_formula_id := p4_a7;
    ddp_rt_quota_asgn.calc_formula_name := p4_a8;
    ddp_rt_quota_asgn.attribute_category := p4_a9;
    ddp_rt_quota_asgn.attribute1 := p4_a10;
    ddp_rt_quota_asgn.attribute2 := p4_a11;
    ddp_rt_quota_asgn.attribute3 := p4_a12;
    ddp_rt_quota_asgn.attribute4 := p4_a13;
    ddp_rt_quota_asgn.attribute5 := p4_a14;
    ddp_rt_quota_asgn.attribute6 := p4_a15;
    ddp_rt_quota_asgn.attribute7 := p4_a16;
    ddp_rt_quota_asgn.attribute8 := p4_a17;
    ddp_rt_quota_asgn.attribute9 := p4_a18;
    ddp_rt_quota_asgn.attribute10 := p4_a19;
    ddp_rt_quota_asgn.attribute11 := p4_a20;
    ddp_rt_quota_asgn.attribute12 := p4_a21;
    ddp_rt_quota_asgn.attribute13 := p4_a22;
    ddp_rt_quota_asgn.attribute14 := p4_a23;
    ddp_rt_quota_asgn.attribute15 := p4_a24;
    ddp_rt_quota_asgn.object_version_number := p4_a25;
    ddp_rt_quota_asgn.created_by := p4_a26;
    ddp_rt_quota_asgn.creation_date := p4_a27;
    ddp_rt_quota_asgn.last_update_login := p4_a28;
    ddp_rt_quota_asgn.last_update_date := p4_a29;
    ddp_rt_quota_asgn.last_updated_by := p4_a30;




    -- here's the delegated call to the old PL/SQL routine
    cn_rt_quota_asgn_pvt.create_rate_table_assignment(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_rt_quota_asgn,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := ddp_rt_quota_asgn.name;
    p4_a1 := ddp_rt_quota_asgn.org_id;
    p4_a2 := ddp_rt_quota_asgn.rt_quota_asgn_id;
    p4_a3 := ddp_rt_quota_asgn.quota_id;
    p4_a4 := ddp_rt_quota_asgn.start_date;
    p4_a5 := ddp_rt_quota_asgn.end_date;
    p4_a6 := ddp_rt_quota_asgn.rate_schedule_id;
    p4_a7 := ddp_rt_quota_asgn.calc_formula_id;
    p4_a8 := ddp_rt_quota_asgn.calc_formula_name;
    p4_a9 := ddp_rt_quota_asgn.attribute_category;
    p4_a10 := ddp_rt_quota_asgn.attribute1;
    p4_a11 := ddp_rt_quota_asgn.attribute2;
    p4_a12 := ddp_rt_quota_asgn.attribute3;
    p4_a13 := ddp_rt_quota_asgn.attribute4;
    p4_a14 := ddp_rt_quota_asgn.attribute5;
    p4_a15 := ddp_rt_quota_asgn.attribute6;
    p4_a16 := ddp_rt_quota_asgn.attribute7;
    p4_a17 := ddp_rt_quota_asgn.attribute8;
    p4_a18 := ddp_rt_quota_asgn.attribute9;
    p4_a19 := ddp_rt_quota_asgn.attribute10;
    p4_a20 := ddp_rt_quota_asgn.attribute11;
    p4_a21 := ddp_rt_quota_asgn.attribute12;
    p4_a22 := ddp_rt_quota_asgn.attribute13;
    p4_a23 := ddp_rt_quota_asgn.attribute14;
    p4_a24 := ddp_rt_quota_asgn.attribute15;
    p4_a25 := ddp_rt_quota_asgn.object_version_number;
    p4_a26 := ddp_rt_quota_asgn.created_by;
    p4_a27 := ddp_rt_quota_asgn.creation_date;
    p4_a28 := ddp_rt_quota_asgn.last_update_login;
    p4_a29 := ddp_rt_quota_asgn.last_update_date;
    p4_a30 := ddp_rt_quota_asgn.last_updated_by;



  end;

  procedure update_rate_table_assignment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  VARCHAR2
    , p4_a1 in out nocopy  NUMBER
    , p4_a2 in out nocopy  NUMBER
    , p4_a3 in out nocopy  NUMBER
    , p4_a4 in out nocopy  DATE
    , p4_a5 in out nocopy  DATE
    , p4_a6 in out nocopy  NUMBER
    , p4_a7 in out nocopy  NUMBER
    , p4_a8 in out nocopy  VARCHAR2
    , p4_a9 in out nocopy  VARCHAR2
    , p4_a10 in out nocopy  VARCHAR2
    , p4_a11 in out nocopy  VARCHAR2
    , p4_a12 in out nocopy  VARCHAR2
    , p4_a13 in out nocopy  VARCHAR2
    , p4_a14 in out nocopy  VARCHAR2
    , p4_a15 in out nocopy  VARCHAR2
    , p4_a16 in out nocopy  VARCHAR2
    , p4_a17 in out nocopy  VARCHAR2
    , p4_a18 in out nocopy  VARCHAR2
    , p4_a19 in out nocopy  VARCHAR2
    , p4_a20 in out nocopy  VARCHAR2
    , p4_a21 in out nocopy  VARCHAR2
    , p4_a22 in out nocopy  VARCHAR2
    , p4_a23 in out nocopy  VARCHAR2
    , p4_a24 in out nocopy  VARCHAR2
    , p4_a25 in out nocopy  NUMBER
    , p4_a26 in out nocopy  NUMBER
    , p4_a27 in out nocopy  DATE
    , p4_a28 in out nocopy  NUMBER
    , p4_a29 in out nocopy  DATE
    , p4_a30 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_rt_quota_asgn cn_rt_quota_asgn_pvt.rt_quota_asgn_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_rt_quota_asgn.name := p4_a0;
    ddp_rt_quota_asgn.org_id := p4_a1;
    ddp_rt_quota_asgn.rt_quota_asgn_id := p4_a2;
    ddp_rt_quota_asgn.quota_id := p4_a3;
    ddp_rt_quota_asgn.start_date := p4_a4;
    ddp_rt_quota_asgn.end_date := p4_a5;
    ddp_rt_quota_asgn.rate_schedule_id := p4_a6;
    ddp_rt_quota_asgn.calc_formula_id := p4_a7;
    ddp_rt_quota_asgn.calc_formula_name := p4_a8;
    ddp_rt_quota_asgn.attribute_category := p4_a9;
    ddp_rt_quota_asgn.attribute1 := p4_a10;
    ddp_rt_quota_asgn.attribute2 := p4_a11;
    ddp_rt_quota_asgn.attribute3 := p4_a12;
    ddp_rt_quota_asgn.attribute4 := p4_a13;
    ddp_rt_quota_asgn.attribute5 := p4_a14;
    ddp_rt_quota_asgn.attribute6 := p4_a15;
    ddp_rt_quota_asgn.attribute7 := p4_a16;
    ddp_rt_quota_asgn.attribute8 := p4_a17;
    ddp_rt_quota_asgn.attribute9 := p4_a18;
    ddp_rt_quota_asgn.attribute10 := p4_a19;
    ddp_rt_quota_asgn.attribute11 := p4_a20;
    ddp_rt_quota_asgn.attribute12 := p4_a21;
    ddp_rt_quota_asgn.attribute13 := p4_a22;
    ddp_rt_quota_asgn.attribute14 := p4_a23;
    ddp_rt_quota_asgn.attribute15 := p4_a24;
    ddp_rt_quota_asgn.object_version_number := p4_a25;
    ddp_rt_quota_asgn.created_by := p4_a26;
    ddp_rt_quota_asgn.creation_date := p4_a27;
    ddp_rt_quota_asgn.last_update_login := p4_a28;
    ddp_rt_quota_asgn.last_update_date := p4_a29;
    ddp_rt_quota_asgn.last_updated_by := p4_a30;




    -- here's the delegated call to the old PL/SQL routine
    cn_rt_quota_asgn_pvt.update_rate_table_assignment(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_rt_quota_asgn,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := ddp_rt_quota_asgn.name;
    p4_a1 := ddp_rt_quota_asgn.org_id;
    p4_a2 := ddp_rt_quota_asgn.rt_quota_asgn_id;
    p4_a3 := ddp_rt_quota_asgn.quota_id;
    p4_a4 := ddp_rt_quota_asgn.start_date;
    p4_a5 := ddp_rt_quota_asgn.end_date;
    p4_a6 := ddp_rt_quota_asgn.rate_schedule_id;
    p4_a7 := ddp_rt_quota_asgn.calc_formula_id;
    p4_a8 := ddp_rt_quota_asgn.calc_formula_name;
    p4_a9 := ddp_rt_quota_asgn.attribute_category;
    p4_a10 := ddp_rt_quota_asgn.attribute1;
    p4_a11 := ddp_rt_quota_asgn.attribute2;
    p4_a12 := ddp_rt_quota_asgn.attribute3;
    p4_a13 := ddp_rt_quota_asgn.attribute4;
    p4_a14 := ddp_rt_quota_asgn.attribute5;
    p4_a15 := ddp_rt_quota_asgn.attribute6;
    p4_a16 := ddp_rt_quota_asgn.attribute7;
    p4_a17 := ddp_rt_quota_asgn.attribute8;
    p4_a18 := ddp_rt_quota_asgn.attribute9;
    p4_a19 := ddp_rt_quota_asgn.attribute10;
    p4_a20 := ddp_rt_quota_asgn.attribute11;
    p4_a21 := ddp_rt_quota_asgn.attribute12;
    p4_a22 := ddp_rt_quota_asgn.attribute13;
    p4_a23 := ddp_rt_quota_asgn.attribute14;
    p4_a24 := ddp_rt_quota_asgn.attribute15;
    p4_a25 := ddp_rt_quota_asgn.object_version_number;
    p4_a26 := ddp_rt_quota_asgn.created_by;
    p4_a27 := ddp_rt_quota_asgn.creation_date;
    p4_a28 := ddp_rt_quota_asgn.last_update_login;
    p4_a29 := ddp_rt_quota_asgn.last_update_date;
    p4_a30 := ddp_rt_quota_asgn.last_updated_by;



  end;

  procedure delete_rate_table_assignment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  VARCHAR2
    , p4_a1 in out nocopy  NUMBER
    , p4_a2 in out nocopy  NUMBER
    , p4_a3 in out nocopy  NUMBER
    , p4_a4 in out nocopy  DATE
    , p4_a5 in out nocopy  DATE
    , p4_a6 in out nocopy  NUMBER
    , p4_a7 in out nocopy  NUMBER
    , p4_a8 in out nocopy  VARCHAR2
    , p4_a9 in out nocopy  VARCHAR2
    , p4_a10 in out nocopy  VARCHAR2
    , p4_a11 in out nocopy  VARCHAR2
    , p4_a12 in out nocopy  VARCHAR2
    , p4_a13 in out nocopy  VARCHAR2
    , p4_a14 in out nocopy  VARCHAR2
    , p4_a15 in out nocopy  VARCHAR2
    , p4_a16 in out nocopy  VARCHAR2
    , p4_a17 in out nocopy  VARCHAR2
    , p4_a18 in out nocopy  VARCHAR2
    , p4_a19 in out nocopy  VARCHAR2
    , p4_a20 in out nocopy  VARCHAR2
    , p4_a21 in out nocopy  VARCHAR2
    , p4_a22 in out nocopy  VARCHAR2
    , p4_a23 in out nocopy  VARCHAR2
    , p4_a24 in out nocopy  VARCHAR2
    , p4_a25 in out nocopy  NUMBER
    , p4_a26 in out nocopy  NUMBER
    , p4_a27 in out nocopy  DATE
    , p4_a28 in out nocopy  NUMBER
    , p4_a29 in out nocopy  DATE
    , p4_a30 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_rt_quota_asgn cn_rt_quota_asgn_pvt.rt_quota_asgn_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_rt_quota_asgn.name := p4_a0;
    ddp_rt_quota_asgn.org_id := p4_a1;
    ddp_rt_quota_asgn.rt_quota_asgn_id := p4_a2;
    ddp_rt_quota_asgn.quota_id := p4_a3;
    ddp_rt_quota_asgn.start_date := p4_a4;
    ddp_rt_quota_asgn.end_date := p4_a5;
    ddp_rt_quota_asgn.rate_schedule_id := p4_a6;
    ddp_rt_quota_asgn.calc_formula_id := p4_a7;
    ddp_rt_quota_asgn.calc_formula_name := p4_a8;
    ddp_rt_quota_asgn.attribute_category := p4_a9;
    ddp_rt_quota_asgn.attribute1 := p4_a10;
    ddp_rt_quota_asgn.attribute2 := p4_a11;
    ddp_rt_quota_asgn.attribute3 := p4_a12;
    ddp_rt_quota_asgn.attribute4 := p4_a13;
    ddp_rt_quota_asgn.attribute5 := p4_a14;
    ddp_rt_quota_asgn.attribute6 := p4_a15;
    ddp_rt_quota_asgn.attribute7 := p4_a16;
    ddp_rt_quota_asgn.attribute8 := p4_a17;
    ddp_rt_quota_asgn.attribute9 := p4_a18;
    ddp_rt_quota_asgn.attribute10 := p4_a19;
    ddp_rt_quota_asgn.attribute11 := p4_a20;
    ddp_rt_quota_asgn.attribute12 := p4_a21;
    ddp_rt_quota_asgn.attribute13 := p4_a22;
    ddp_rt_quota_asgn.attribute14 := p4_a23;
    ddp_rt_quota_asgn.attribute15 := p4_a24;
    ddp_rt_quota_asgn.object_version_number := p4_a25;
    ddp_rt_quota_asgn.created_by := p4_a26;
    ddp_rt_quota_asgn.creation_date := p4_a27;
    ddp_rt_quota_asgn.last_update_login := p4_a28;
    ddp_rt_quota_asgn.last_update_date := p4_a29;
    ddp_rt_quota_asgn.last_updated_by := p4_a30;




    -- here's the delegated call to the old PL/SQL routine
    cn_rt_quota_asgn_pvt.delete_rate_table_assignment(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_rt_quota_asgn,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := ddp_rt_quota_asgn.name;
    p4_a1 := ddp_rt_quota_asgn.org_id;
    p4_a2 := ddp_rt_quota_asgn.rt_quota_asgn_id;
    p4_a3 := ddp_rt_quota_asgn.quota_id;
    p4_a4 := ddp_rt_quota_asgn.start_date;
    p4_a5 := ddp_rt_quota_asgn.end_date;
    p4_a6 := ddp_rt_quota_asgn.rate_schedule_id;
    p4_a7 := ddp_rt_quota_asgn.calc_formula_id;
    p4_a8 := ddp_rt_quota_asgn.calc_formula_name;
    p4_a9 := ddp_rt_quota_asgn.attribute_category;
    p4_a10 := ddp_rt_quota_asgn.attribute1;
    p4_a11 := ddp_rt_quota_asgn.attribute2;
    p4_a12 := ddp_rt_quota_asgn.attribute3;
    p4_a13 := ddp_rt_quota_asgn.attribute4;
    p4_a14 := ddp_rt_quota_asgn.attribute5;
    p4_a15 := ddp_rt_quota_asgn.attribute6;
    p4_a16 := ddp_rt_quota_asgn.attribute7;
    p4_a17 := ddp_rt_quota_asgn.attribute8;
    p4_a18 := ddp_rt_quota_asgn.attribute9;
    p4_a19 := ddp_rt_quota_asgn.attribute10;
    p4_a20 := ddp_rt_quota_asgn.attribute11;
    p4_a21 := ddp_rt_quota_asgn.attribute12;
    p4_a22 := ddp_rt_quota_asgn.attribute13;
    p4_a23 := ddp_rt_quota_asgn.attribute14;
    p4_a24 := ddp_rt_quota_asgn.attribute15;
    p4_a25 := ddp_rt_quota_asgn.object_version_number;
    p4_a26 := ddp_rt_quota_asgn.created_by;
    p4_a27 := ddp_rt_quota_asgn.creation_date;
    p4_a28 := ddp_rt_quota_asgn.last_update_login;
    p4_a29 := ddp_rt_quota_asgn.last_update_date;
    p4_a30 := ddp_rt_quota_asgn.last_updated_by;



  end;

  procedure get_formula_rate_tables(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_type  VARCHAR2
    , p_quota_id  NUMBER
    , p_calc_formula_id  NUMBER
    , p7_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_NUMBER_TABLE
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_DATE_TABLE
    , p8_a5 out nocopy JTF_DATE_TABLE
    , p8_a6 out nocopy JTF_NUMBER_TABLE
    , p8_a7 out nocopy JTF_NUMBER_TABLE
    , p8_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a10 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a11 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a13 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a23 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a24 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a25 out nocopy JTF_NUMBER_TABLE
    , p8_a26 out nocopy JTF_NUMBER_TABLE
    , p8_a27 out nocopy JTF_DATE_TABLE
    , p8_a28 out nocopy JTF_NUMBER_TABLE
    , p8_a29 out nocopy JTF_DATE_TABLE
    , p8_a30 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_calc_formulas cn_rt_quota_asgn_pvt.calc_formulas_tbl_type;
    ddx_rate_tables cn_rt_quota_asgn_pvt.rt_quota_asgn_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any












    -- here's the delegated call to the old PL/SQL routine
    cn_rt_quota_asgn_pvt.get_formula_rate_tables(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_type,
      p_quota_id,
      p_calc_formula_id,
      ddx_calc_formulas,
      ddx_rate_tables,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    cn_rt_quota_asgn_pvt_w.rosetta_table_copy_out_p1(ddx_calc_formulas, p7_a0
      , p7_a1
      );

    cn_rt_quota_asgn_pvt_w.rosetta_table_copy_out_p3(ddx_rate_tables, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      , p8_a8
      , p8_a9
      , p8_a10
      , p8_a11
      , p8_a12
      , p8_a13
      , p8_a14
      , p8_a15
      , p8_a16
      , p8_a17
      , p8_a18
      , p8_a19
      , p8_a20
      , p8_a21
      , p8_a22
      , p8_a23
      , p8_a24
      , p8_a25
      , p8_a26
      , p8_a27
      , p8_a28
      , p8_a29
      , p8_a30
      );



  end;

  procedure validate_rate_table_assignment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_action  VARCHAR2
    , p5_a0 in out nocopy  VARCHAR2
    , p5_a1 in out nocopy  NUMBER
    , p5_a2 in out nocopy  NUMBER
    , p5_a3 in out nocopy  NUMBER
    , p5_a4 in out nocopy  DATE
    , p5_a5 in out nocopy  DATE
    , p5_a6 in out nocopy  NUMBER
    , p5_a7 in out nocopy  NUMBER
    , p5_a8 in out nocopy  VARCHAR2
    , p5_a9 in out nocopy  VARCHAR2
    , p5_a10 in out nocopy  VARCHAR2
    , p5_a11 in out nocopy  VARCHAR2
    , p5_a12 in out nocopy  VARCHAR2
    , p5_a13 in out nocopy  VARCHAR2
    , p5_a14 in out nocopy  VARCHAR2
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  VARCHAR2
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  VARCHAR2
    , p5_a19 in out nocopy  VARCHAR2
    , p5_a20 in out nocopy  VARCHAR2
    , p5_a21 in out nocopy  VARCHAR2
    , p5_a22 in out nocopy  VARCHAR2
    , p5_a23 in out nocopy  VARCHAR2
    , p5_a24 in out nocopy  VARCHAR2
    , p5_a25 in out nocopy  NUMBER
    , p5_a26 in out nocopy  NUMBER
    , p5_a27 in out nocopy  DATE
    , p5_a28 in out nocopy  NUMBER
    , p5_a29 in out nocopy  DATE
    , p5_a30 in out nocopy  NUMBER
    , p6_a0  VARCHAR2
    , p6_a1  NUMBER
    , p6_a2  NUMBER
    , p6_a3  NUMBER
    , p6_a4  DATE
    , p6_a5  DATE
    , p6_a6  NUMBER
    , p6_a7  NUMBER
    , p6_a8  VARCHAR2
    , p6_a9  VARCHAR2
    , p6_a10  VARCHAR2
    , p6_a11  VARCHAR2
    , p6_a12  VARCHAR2
    , p6_a13  VARCHAR2
    , p6_a14  VARCHAR2
    , p6_a15  VARCHAR2
    , p6_a16  VARCHAR2
    , p6_a17  VARCHAR2
    , p6_a18  VARCHAR2
    , p6_a19  VARCHAR2
    , p6_a20  VARCHAR2
    , p6_a21  VARCHAR2
    , p6_a22  VARCHAR2
    , p6_a23  VARCHAR2
    , p6_a24  VARCHAR2
    , p6_a25  NUMBER
    , p6_a26  NUMBER
    , p6_a27  DATE
    , p6_a28  NUMBER
    , p6_a29  DATE
    , p6_a30  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_rt_quota_asgn cn_rt_quota_asgn_pvt.rt_quota_asgn_rec_type;
    ddp_old_rt_quota_asgn cn_rt_quota_asgn_pvt.rt_quota_asgn_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rt_quota_asgn.name := p5_a0;
    ddp_rt_quota_asgn.org_id := p5_a1;
    ddp_rt_quota_asgn.rt_quota_asgn_id := p5_a2;
    ddp_rt_quota_asgn.quota_id := p5_a3;
    ddp_rt_quota_asgn.start_date := p5_a4;
    ddp_rt_quota_asgn.end_date := p5_a5;
    ddp_rt_quota_asgn.rate_schedule_id := p5_a6;
    ddp_rt_quota_asgn.calc_formula_id := p5_a7;
    ddp_rt_quota_asgn.calc_formula_name := p5_a8;
    ddp_rt_quota_asgn.attribute_category := p5_a9;
    ddp_rt_quota_asgn.attribute1 := p5_a10;
    ddp_rt_quota_asgn.attribute2 := p5_a11;
    ddp_rt_quota_asgn.attribute3 := p5_a12;
    ddp_rt_quota_asgn.attribute4 := p5_a13;
    ddp_rt_quota_asgn.attribute5 := p5_a14;
    ddp_rt_quota_asgn.attribute6 := p5_a15;
    ddp_rt_quota_asgn.attribute7 := p5_a16;
    ddp_rt_quota_asgn.attribute8 := p5_a17;
    ddp_rt_quota_asgn.attribute9 := p5_a18;
    ddp_rt_quota_asgn.attribute10 := p5_a19;
    ddp_rt_quota_asgn.attribute11 := p5_a20;
    ddp_rt_quota_asgn.attribute12 := p5_a21;
    ddp_rt_quota_asgn.attribute13 := p5_a22;
    ddp_rt_quota_asgn.attribute14 := p5_a23;
    ddp_rt_quota_asgn.attribute15 := p5_a24;
    ddp_rt_quota_asgn.object_version_number := p5_a25;
    ddp_rt_quota_asgn.created_by := p5_a26;
    ddp_rt_quota_asgn.creation_date := p5_a27;
    ddp_rt_quota_asgn.last_update_login := p5_a28;
    ddp_rt_quota_asgn.last_update_date := p5_a29;
    ddp_rt_quota_asgn.last_updated_by := p5_a30;

    ddp_old_rt_quota_asgn.name := p6_a0;
    ddp_old_rt_quota_asgn.org_id := p6_a1;
    ddp_old_rt_quota_asgn.rt_quota_asgn_id := p6_a2;
    ddp_old_rt_quota_asgn.quota_id := p6_a3;
    ddp_old_rt_quota_asgn.start_date := p6_a4;
    ddp_old_rt_quota_asgn.end_date := p6_a5;
    ddp_old_rt_quota_asgn.rate_schedule_id := p6_a6;
    ddp_old_rt_quota_asgn.calc_formula_id := p6_a7;
    ddp_old_rt_quota_asgn.calc_formula_name := p6_a8;
    ddp_old_rt_quota_asgn.attribute_category := p6_a9;
    ddp_old_rt_quota_asgn.attribute1 := p6_a10;
    ddp_old_rt_quota_asgn.attribute2 := p6_a11;
    ddp_old_rt_quota_asgn.attribute3 := p6_a12;
    ddp_old_rt_quota_asgn.attribute4 := p6_a13;
    ddp_old_rt_quota_asgn.attribute5 := p6_a14;
    ddp_old_rt_quota_asgn.attribute6 := p6_a15;
    ddp_old_rt_quota_asgn.attribute7 := p6_a16;
    ddp_old_rt_quota_asgn.attribute8 := p6_a17;
    ddp_old_rt_quota_asgn.attribute9 := p6_a18;
    ddp_old_rt_quota_asgn.attribute10 := p6_a19;
    ddp_old_rt_quota_asgn.attribute11 := p6_a20;
    ddp_old_rt_quota_asgn.attribute12 := p6_a21;
    ddp_old_rt_quota_asgn.attribute13 := p6_a22;
    ddp_old_rt_quota_asgn.attribute14 := p6_a23;
    ddp_old_rt_quota_asgn.attribute15 := p6_a24;
    ddp_old_rt_quota_asgn.object_version_number := p6_a25;
    ddp_old_rt_quota_asgn.created_by := p6_a26;
    ddp_old_rt_quota_asgn.creation_date := p6_a27;
    ddp_old_rt_quota_asgn.last_update_login := p6_a28;
    ddp_old_rt_quota_asgn.last_update_date := p6_a29;
    ddp_old_rt_quota_asgn.last_updated_by := p6_a30;




    -- here's the delegated call to the old PL/SQL routine
    cn_rt_quota_asgn_pvt.validate_rate_table_assignment(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_action,
      ddp_rt_quota_asgn,
      ddp_old_rt_quota_asgn,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    p5_a0 := ddp_rt_quota_asgn.name;
    p5_a1 := ddp_rt_quota_asgn.org_id;
    p5_a2 := ddp_rt_quota_asgn.rt_quota_asgn_id;
    p5_a3 := ddp_rt_quota_asgn.quota_id;
    p5_a4 := ddp_rt_quota_asgn.start_date;
    p5_a5 := ddp_rt_quota_asgn.end_date;
    p5_a6 := ddp_rt_quota_asgn.rate_schedule_id;
    p5_a7 := ddp_rt_quota_asgn.calc_formula_id;
    p5_a8 := ddp_rt_quota_asgn.calc_formula_name;
    p5_a9 := ddp_rt_quota_asgn.attribute_category;
    p5_a10 := ddp_rt_quota_asgn.attribute1;
    p5_a11 := ddp_rt_quota_asgn.attribute2;
    p5_a12 := ddp_rt_quota_asgn.attribute3;
    p5_a13 := ddp_rt_quota_asgn.attribute4;
    p5_a14 := ddp_rt_quota_asgn.attribute5;
    p5_a15 := ddp_rt_quota_asgn.attribute6;
    p5_a16 := ddp_rt_quota_asgn.attribute7;
    p5_a17 := ddp_rt_quota_asgn.attribute8;
    p5_a18 := ddp_rt_quota_asgn.attribute9;
    p5_a19 := ddp_rt_quota_asgn.attribute10;
    p5_a20 := ddp_rt_quota_asgn.attribute11;
    p5_a21 := ddp_rt_quota_asgn.attribute12;
    p5_a22 := ddp_rt_quota_asgn.attribute13;
    p5_a23 := ddp_rt_quota_asgn.attribute14;
    p5_a24 := ddp_rt_quota_asgn.attribute15;
    p5_a25 := ddp_rt_quota_asgn.object_version_number;
    p5_a26 := ddp_rt_quota_asgn.created_by;
    p5_a27 := ddp_rt_quota_asgn.creation_date;
    p5_a28 := ddp_rt_quota_asgn.last_update_login;
    p5_a29 := ddp_rt_quota_asgn.last_update_date;
    p5_a30 := ddp_rt_quota_asgn.last_updated_by;




  end;

end cn_rt_quota_asgn_pvt_w;

/
