--------------------------------------------------------
--  DDL for Package Body CN_COMP_PLAN_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_COMP_PLAN_PVT_W" as
  /* $Header: cnwcmpnb.pls 120.2.12010000.2 2009/08/04 17:22:15 rnagaraj ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy cn_comp_plan_pvt.comp_plan_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_1900
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_DATE_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_DATE_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
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
    , a25 JTF_VARCHAR2_TABLE_200
    , a26 JTF_VARCHAR2_TABLE_200
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).comp_plan_id := a0(indx);
          t(ddindx).name := a1(indx);
          t(ddindx).version := a2(indx);
          t(ddindx).description := a3(indx);
          t(ddindx).status_code := a4(indx);
          t(ddindx).complete_flag := a5(indx);
          t(ddindx).on_quota_date := a6(indx);
          t(ddindx).allow_rev_class_overlap := a7(indx);
          t(ddindx).sum_trx_flag := a8(indx);
          t(ddindx).start_date := a9(indx);
          t(ddindx).end_date := a10(indx);
          t(ddindx).attribute_category := a11(indx);
          t(ddindx).attribute1 := a12(indx);
          t(ddindx).attribute2 := a13(indx);
          t(ddindx).attribute3 := a14(indx);
          t(ddindx).attribute4 := a15(indx);
          t(ddindx).attribute5 := a16(indx);
          t(ddindx).attribute6 := a17(indx);
          t(ddindx).attribute7 := a18(indx);
          t(ddindx).attribute8 := a19(indx);
          t(ddindx).attribute9 := a20(indx);
          t(ddindx).attribute10 := a21(indx);
          t(ddindx).attribute11 := a22(indx);
          t(ddindx).attribute12 := a23(indx);
          t(ddindx).attribute13 := a24(indx);
          t(ddindx).attribute14 := a25(indx);
          t(ddindx).attribute15 := a26(indx);
          t(ddindx).object_version_number := a27(indx);
          t(ddindx).org_id := a28(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t cn_comp_plan_pvt.comp_plan_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_1900
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a25 out nocopy JTF_VARCHAR2_TABLE_200
    , a26 out nocopy JTF_VARCHAR2_TABLE_200
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_1900();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
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
    a25 := JTF_VARCHAR2_TABLE_200();
    a26 := JTF_VARCHAR2_TABLE_200();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_1900();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
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
      a25 := JTF_VARCHAR2_TABLE_200();
      a26 := JTF_VARCHAR2_TABLE_200();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).comp_plan_id;
          a1(indx) := t(ddindx).name;
          a2(indx) := t(ddindx).version;
          a3(indx) := t(ddindx).description;
          a4(indx) := t(ddindx).status_code;
          a5(indx) := t(ddindx).complete_flag;
          a6(indx) := t(ddindx).on_quota_date;
          a7(indx) := t(ddindx).allow_rev_class_overlap;
          a8(indx) := t(ddindx).sum_trx_flag;
          a9(indx) := t(ddindx).start_date;
          a10(indx) := t(ddindx).end_date;
          a11(indx) := t(ddindx).attribute_category;
          a12(indx) := t(ddindx).attribute1;
          a13(indx) := t(ddindx).attribute2;
          a14(indx) := t(ddindx).attribute3;
          a15(indx) := t(ddindx).attribute4;
          a16(indx) := t(ddindx).attribute5;
          a17(indx) := t(ddindx).attribute6;
          a18(indx) := t(ddindx).attribute7;
          a19(indx) := t(ddindx).attribute8;
          a20(indx) := t(ddindx).attribute9;
          a21(indx) := t(ddindx).attribute10;
          a22(indx) := t(ddindx).attribute11;
          a23(indx) := t(ddindx).attribute12;
          a24(indx) := t(ddindx).attribute13;
          a25(indx) := t(ddindx).attribute14;
          a26(indx) := t(ddindx).attribute15;
          a27(indx) := t(ddindx).object_version_number;
          a28(indx) := t(ddindx).org_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p5(t out nocopy cn_comp_plan_pvt.sales_role_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_200
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).role_plan_id := a0(indx);
          t(ddindx).role_id := a1(indx);
          t(ddindx).comp_plan_id := a2(indx);
          t(ddindx).name := a3(indx);
          t(ddindx).description := a4(indx);
          t(ddindx).start_date := a5(indx);
          t(ddindx).end_date := a6(indx);
          t(ddindx).object_version_number := a7(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t cn_comp_plan_pvt.sales_role_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_200
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_200();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_200();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_DATE_TABLE();
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
          a0(indx) := t(ddindx).role_plan_id;
          a1(indx) := t(ddindx).role_id;
          a2(indx) := t(ddindx).comp_plan_id;
          a3(indx) := t(ddindx).name;
          a4(indx) := t(ddindx).description;
          a5(indx) := t(ddindx).start_date;
          a6(indx) := t(ddindx).end_date;
          a7(indx) := t(ddindx).object_version_number;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p7(t out nocopy cn_comp_plan_pvt.srp_plan_assign_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_400
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_DATE_TABLE
    , a7 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).srp_plan_assign_id := a0(indx);
          t(ddindx).salesrep_id := a1(indx);
          t(ddindx).role_id := a2(indx);
          t(ddindx).role_name := a3(indx);
          t(ddindx).salesrep_name := a4(indx);
          t(ddindx).employee_number := a5(indx);
          t(ddindx).start_date := a6(indx);
          t(ddindx).end_date := a7(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t cn_comp_plan_pvt.srp_plan_assign_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_400
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_400();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_400();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_DATE_TABLE();
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
          a0(indx) := t(ddindx).srp_plan_assign_id;
          a1(indx) := t(ddindx).salesrep_id;
          a2(indx) := t(ddindx).role_id;
          a3(indx) := t(ddindx).role_name;
          a4(indx) := t(ddindx).salesrep_name;
          a5(indx) := t(ddindx).employee_number;
          a6(indx) := t(ddindx).start_date;
          a7(indx) := t(ddindx).end_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure create_comp_plan(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  VARCHAR2
    , p4_a2 in out nocopy  VARCHAR2
    , p4_a3 in out nocopy  VARCHAR2
    , p4_a4 in out nocopy  VARCHAR2
    , p4_a5 in out nocopy  VARCHAR2
    , p4_a6 in out nocopy  DATE
    , p4_a7 in out nocopy  VARCHAR2
    , p4_a8 in out nocopy  VARCHAR2
    , p4_a9 in out nocopy  DATE
    , p4_a10 in out nocopy  DATE
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
    , p4_a25 in out nocopy  VARCHAR2
    , p4_a26 in out nocopy  VARCHAR2
    , p4_a27 in out nocopy  NUMBER
    , p4_a28 in out nocopy  NUMBER
    , x_comp_plan_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_comp_plan cn_comp_plan_pvt.comp_plan_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_comp_plan.comp_plan_id := p4_a0;
    ddp_comp_plan.name := p4_a1;
    ddp_comp_plan.version := p4_a2;
    ddp_comp_plan.description := p4_a3;
    ddp_comp_plan.status_code := p4_a4;
    ddp_comp_plan.complete_flag := p4_a5;
    ddp_comp_plan.on_quota_date := p4_a6;
    ddp_comp_plan.allow_rev_class_overlap := p4_a7;
    ddp_comp_plan.sum_trx_flag := p4_a8;
    ddp_comp_plan.start_date := p4_a9;
    ddp_comp_plan.end_date := p4_a10;
    ddp_comp_plan.attribute_category := p4_a11;
    ddp_comp_plan.attribute1 := p4_a12;
    ddp_comp_plan.attribute2 := p4_a13;
    ddp_comp_plan.attribute3 := p4_a14;
    ddp_comp_plan.attribute4 := p4_a15;
    ddp_comp_plan.attribute5 := p4_a16;
    ddp_comp_plan.attribute6 := p4_a17;
    ddp_comp_plan.attribute7 := p4_a18;
    ddp_comp_plan.attribute8 := p4_a19;
    ddp_comp_plan.attribute9 := p4_a20;
    ddp_comp_plan.attribute10 := p4_a21;
    ddp_comp_plan.attribute11 := p4_a22;
    ddp_comp_plan.attribute12 := p4_a23;
    ddp_comp_plan.attribute13 := p4_a24;
    ddp_comp_plan.attribute14 := p4_a25;
    ddp_comp_plan.attribute15 := p4_a26;
    ddp_comp_plan.object_version_number := p4_a27;
    ddp_comp_plan.org_id := p4_a28;





    -- here's the delegated call to the old PL/SQL routine
    cn_comp_plan_pvt.create_comp_plan(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_comp_plan,
      x_comp_plan_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := ddp_comp_plan.comp_plan_id;
    p4_a1 := ddp_comp_plan.name;
    p4_a2 := ddp_comp_plan.version;
    p4_a3 := ddp_comp_plan.description;
    p4_a4 := ddp_comp_plan.status_code;
    p4_a5 := ddp_comp_plan.complete_flag;
    p4_a6 := ddp_comp_plan.on_quota_date;
    p4_a7 := ddp_comp_plan.allow_rev_class_overlap;
    p4_a8 := ddp_comp_plan.sum_trx_flag;
    p4_a9 := ddp_comp_plan.start_date;
    p4_a10 := ddp_comp_plan.end_date;
    p4_a11 := ddp_comp_plan.attribute_category;
    p4_a12 := ddp_comp_plan.attribute1;
    p4_a13 := ddp_comp_plan.attribute2;
    p4_a14 := ddp_comp_plan.attribute3;
    p4_a15 := ddp_comp_plan.attribute4;
    p4_a16 := ddp_comp_plan.attribute5;
    p4_a17 := ddp_comp_plan.attribute6;
    p4_a18 := ddp_comp_plan.attribute7;
    p4_a19 := ddp_comp_plan.attribute8;
    p4_a20 := ddp_comp_plan.attribute9;
    p4_a21 := ddp_comp_plan.attribute10;
    p4_a22 := ddp_comp_plan.attribute11;
    p4_a23 := ddp_comp_plan.attribute12;
    p4_a24 := ddp_comp_plan.attribute13;
    p4_a25 := ddp_comp_plan.attribute14;
    p4_a26 := ddp_comp_plan.attribute15;
    p4_a27 := ddp_comp_plan.object_version_number;
    p4_a28 := ddp_comp_plan.org_id;




  end;

  procedure update_comp_plan(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  VARCHAR2
    , p4_a2 in out nocopy  VARCHAR2
    , p4_a3 in out nocopy  VARCHAR2
    , p4_a4 in out nocopy  VARCHAR2
    , p4_a5 in out nocopy  VARCHAR2
    , p4_a6 in out nocopy  DATE
    , p4_a7 in out nocopy  VARCHAR2
    , p4_a8 in out nocopy  VARCHAR2
    , p4_a9 in out nocopy  DATE
    , p4_a10 in out nocopy  DATE
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
    , p4_a25 in out nocopy  VARCHAR2
    , p4_a26 in out nocopy  VARCHAR2
    , p4_a27 in out nocopy  NUMBER
    , p4_a28 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_comp_plan cn_comp_plan_pvt.comp_plan_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_comp_plan.comp_plan_id := p4_a0;
    ddp_comp_plan.name := p4_a1;
    ddp_comp_plan.version := p4_a2;
    ddp_comp_plan.description := p4_a3;
    ddp_comp_plan.status_code := p4_a4;
    ddp_comp_plan.complete_flag := p4_a5;
    ddp_comp_plan.on_quota_date := p4_a6;
    ddp_comp_plan.allow_rev_class_overlap := p4_a7;
    ddp_comp_plan.sum_trx_flag := p4_a8;
    ddp_comp_plan.start_date := p4_a9;
    ddp_comp_plan.end_date := p4_a10;
    ddp_comp_plan.attribute_category := p4_a11;
    ddp_comp_plan.attribute1 := p4_a12;
    ddp_comp_plan.attribute2 := p4_a13;
    ddp_comp_plan.attribute3 := p4_a14;
    ddp_comp_plan.attribute4 := p4_a15;
    ddp_comp_plan.attribute5 := p4_a16;
    ddp_comp_plan.attribute6 := p4_a17;
    ddp_comp_plan.attribute7 := p4_a18;
    ddp_comp_plan.attribute8 := p4_a19;
    ddp_comp_plan.attribute9 := p4_a20;
    ddp_comp_plan.attribute10 := p4_a21;
    ddp_comp_plan.attribute11 := p4_a22;
    ddp_comp_plan.attribute12 := p4_a23;
    ddp_comp_plan.attribute13 := p4_a24;
    ddp_comp_plan.attribute14 := p4_a25;
    ddp_comp_plan.attribute15 := p4_a26;
    ddp_comp_plan.object_version_number := p4_a27;
    ddp_comp_plan.org_id := p4_a28;




    -- here's the delegated call to the old PL/SQL routine
    cn_comp_plan_pvt.update_comp_plan(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_comp_plan,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := ddp_comp_plan.comp_plan_id;
    p4_a1 := ddp_comp_plan.name;
    p4_a2 := ddp_comp_plan.version;
    p4_a3 := ddp_comp_plan.description;
    p4_a4 := ddp_comp_plan.status_code;
    p4_a5 := ddp_comp_plan.complete_flag;
    p4_a6 := ddp_comp_plan.on_quota_date;
    p4_a7 := ddp_comp_plan.allow_rev_class_overlap;
    p4_a8 := ddp_comp_plan.sum_trx_flag;
    p4_a9 := ddp_comp_plan.start_date;
    p4_a10 := ddp_comp_plan.end_date;
    p4_a11 := ddp_comp_plan.attribute_category;
    p4_a12 := ddp_comp_plan.attribute1;
    p4_a13 := ddp_comp_plan.attribute2;
    p4_a14 := ddp_comp_plan.attribute3;
    p4_a15 := ddp_comp_plan.attribute4;
    p4_a16 := ddp_comp_plan.attribute5;
    p4_a17 := ddp_comp_plan.attribute6;
    p4_a18 := ddp_comp_plan.attribute7;
    p4_a19 := ddp_comp_plan.attribute8;
    p4_a20 := ddp_comp_plan.attribute9;
    p4_a21 := ddp_comp_plan.attribute10;
    p4_a22 := ddp_comp_plan.attribute11;
    p4_a23 := ddp_comp_plan.attribute12;
    p4_a24 := ddp_comp_plan.attribute13;
    p4_a25 := ddp_comp_plan.attribute14;
    p4_a26 := ddp_comp_plan.attribute15;
    p4_a27 := ddp_comp_plan.object_version_number;
    p4_a28 := ddp_comp_plan.org_id;



  end;

  procedure delete_comp_plan(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  VARCHAR2
    , p4_a2 in out nocopy  VARCHAR2
    , p4_a3 in out nocopy  VARCHAR2
    , p4_a4 in out nocopy  VARCHAR2
    , p4_a5 in out nocopy  VARCHAR2
    , p4_a6 in out nocopy  DATE
    , p4_a7 in out nocopy  VARCHAR2
    , p4_a8 in out nocopy  VARCHAR2
    , p4_a9 in out nocopy  DATE
    , p4_a10 in out nocopy  DATE
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
    , p4_a25 in out nocopy  VARCHAR2
    , p4_a26 in out nocopy  VARCHAR2
    , p4_a27 in out nocopy  NUMBER
    , p4_a28 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_comp_plan cn_comp_plan_pvt.comp_plan_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_comp_plan.comp_plan_id := p4_a0;
    ddp_comp_plan.name := p4_a1;
    ddp_comp_plan.version := p4_a2;
    ddp_comp_plan.description := p4_a3;
    ddp_comp_plan.status_code := p4_a4;
    ddp_comp_plan.complete_flag := p4_a5;
    ddp_comp_plan.on_quota_date := p4_a6;
    ddp_comp_plan.allow_rev_class_overlap := p4_a7;
    ddp_comp_plan.sum_trx_flag := p4_a8;
    ddp_comp_plan.start_date := p4_a9;
    ddp_comp_plan.end_date := p4_a10;
    ddp_comp_plan.attribute_category := p4_a11;
    ddp_comp_plan.attribute1 := p4_a12;
    ddp_comp_plan.attribute2 := p4_a13;
    ddp_comp_plan.attribute3 := p4_a14;
    ddp_comp_plan.attribute4 := p4_a15;
    ddp_comp_plan.attribute5 := p4_a16;
    ddp_comp_plan.attribute6 := p4_a17;
    ddp_comp_plan.attribute7 := p4_a18;
    ddp_comp_plan.attribute8 := p4_a19;
    ddp_comp_plan.attribute9 := p4_a20;
    ddp_comp_plan.attribute10 := p4_a21;
    ddp_comp_plan.attribute11 := p4_a22;
    ddp_comp_plan.attribute12 := p4_a23;
    ddp_comp_plan.attribute13 := p4_a24;
    ddp_comp_plan.attribute14 := p4_a25;
    ddp_comp_plan.attribute15 := p4_a26;
    ddp_comp_plan.object_version_number := p4_a27;
    ddp_comp_plan.org_id := p4_a28;




    -- here's the delegated call to the old PL/SQL routine
    cn_comp_plan_pvt.delete_comp_plan(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_comp_plan,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := ddp_comp_plan.comp_plan_id;
    p4_a1 := ddp_comp_plan.name;
    p4_a2 := ddp_comp_plan.version;
    p4_a3 := ddp_comp_plan.description;
    p4_a4 := ddp_comp_plan.status_code;
    p4_a5 := ddp_comp_plan.complete_flag;
    p4_a6 := ddp_comp_plan.on_quota_date;
    p4_a7 := ddp_comp_plan.allow_rev_class_overlap;
    p4_a8 := ddp_comp_plan.sum_trx_flag;
    p4_a9 := ddp_comp_plan.start_date;
    p4_a10 := ddp_comp_plan.end_date;
    p4_a11 := ddp_comp_plan.attribute_category;
    p4_a12 := ddp_comp_plan.attribute1;
    p4_a13 := ddp_comp_plan.attribute2;
    p4_a14 := ddp_comp_plan.attribute3;
    p4_a15 := ddp_comp_plan.attribute4;
    p4_a16 := ddp_comp_plan.attribute5;
    p4_a17 := ddp_comp_plan.attribute6;
    p4_a18 := ddp_comp_plan.attribute7;
    p4_a19 := ddp_comp_plan.attribute8;
    p4_a20 := ddp_comp_plan.attribute9;
    p4_a21 := ddp_comp_plan.attribute10;
    p4_a22 := ddp_comp_plan.attribute11;
    p4_a23 := ddp_comp_plan.attribute12;
    p4_a24 := ddp_comp_plan.attribute13;
    p4_a25 := ddp_comp_plan.attribute14;
    p4_a26 := ddp_comp_plan.attribute15;
    p4_a27 := ddp_comp_plan.object_version_number;
    p4_a28 := ddp_comp_plan.org_id;



  end;

  procedure get_comp_plan_sum(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_start_record  NUMBER
    , p_fetch_size  NUMBER
    , p_search_name  VARCHAR2
    , p_search_date  DATE
    , p_search_status  VARCHAR2
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a3 out nocopy JTF_VARCHAR2_TABLE_1900
    , p9_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a6 out nocopy JTF_DATE_TABLE
    , p9_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a9 out nocopy JTF_DATE_TABLE
    , p9_a10 out nocopy JTF_DATE_TABLE
    , p9_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a13 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a23 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a24 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a25 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a26 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a27 out nocopy JTF_NUMBER_TABLE
    , p9_a28 out nocopy JTF_NUMBER_TABLE
    , x_total_record out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_comp_plan cn_comp_plan_pvt.comp_plan_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any














    -- here's the delegated call to the old PL/SQL routine
    cn_comp_plan_pvt.get_comp_plan_sum(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_start_record,
      p_fetch_size,
      p_search_name,
      p_search_date,
      p_search_status,
      ddx_comp_plan,
      x_total_record,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    cn_comp_plan_pvt_w.rosetta_table_copy_out_p1(ddx_comp_plan, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      , p9_a7
      , p9_a8
      , p9_a9
      , p9_a10
      , p9_a11
      , p9_a12
      , p9_a13
      , p9_a14
      , p9_a15
      , p9_a16
      , p9_a17
      , p9_a18
      , p9_a19
      , p9_a20
      , p9_a21
      , p9_a22
      , p9_a23
      , p9_a24
      , p9_a25
      , p9_a26
      , p9_a27
      , p9_a28
      );




  end;

  procedure get_comp_plan_dtl(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_comp_plan_id  NUMBER
    , p5_a0 out nocopy JTF_NUMBER_TABLE
    , p5_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a3 out nocopy JTF_VARCHAR2_TABLE_1900
    , p5_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a6 out nocopy JTF_DATE_TABLE
    , p5_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a9 out nocopy JTF_DATE_TABLE
    , p5_a10 out nocopy JTF_DATE_TABLE
    , p5_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a13 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a23 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a24 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a25 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a26 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a27 out nocopy JTF_NUMBER_TABLE
    , p5_a28 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_comp_plan cn_comp_plan_pvt.comp_plan_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    cn_comp_plan_pvt.get_comp_plan_dtl(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_comp_plan_id,
      ddx_comp_plan,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    cn_comp_plan_pvt_w.rosetta_table_copy_out_p1(ddx_comp_plan, p5_a0
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
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      );



  end;

  procedure get_sales_role(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_comp_plan_id  NUMBER
    , p5_a0 out nocopy JTF_NUMBER_TABLE
    , p5_a1 out nocopy JTF_NUMBER_TABLE
    , p5_a2 out nocopy JTF_NUMBER_TABLE
    , p5_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a4 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a5 out nocopy JTF_DATE_TABLE
    , p5_a6 out nocopy JTF_DATE_TABLE
    , p5_a7 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_sales_role cn_comp_plan_pvt.sales_role_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    cn_comp_plan_pvt.get_sales_role(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_comp_plan_id,
      ddx_sales_role,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    cn_comp_plan_pvt_w.rosetta_table_copy_out_p5(ddx_sales_role, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      );



  end;

  procedure validate_comp_plan(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  VARCHAR2
    , p4_a2  VARCHAR2
    , p4_a3  VARCHAR2
    , p4_a4  VARCHAR2
    , p4_a5  VARCHAR2
    , p4_a6  DATE
    , p4_a7  VARCHAR2
    , p4_a8  VARCHAR2
    , p4_a9  DATE
    , p4_a10  DATE
    , p4_a11  VARCHAR2
    , p4_a12  VARCHAR2
    , p4_a13  VARCHAR2
    , p4_a14  VARCHAR2
    , p4_a15  VARCHAR2
    , p4_a16  VARCHAR2
    , p4_a17  VARCHAR2
    , p4_a18  VARCHAR2
    , p4_a19  VARCHAR2
    , p4_a20  VARCHAR2
    , p4_a21  VARCHAR2
    , p4_a22  VARCHAR2
    , p4_a23  VARCHAR2
    , p4_a24  VARCHAR2
    , p4_a25  VARCHAR2
    , p4_a26  VARCHAR2
    , p4_a27  NUMBER
    , p4_a28  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_comp_plan cn_comp_plan_pvt.comp_plan_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_comp_plan.comp_plan_id := p4_a0;
    ddp_comp_plan.name := p4_a1;
    ddp_comp_plan.version := p4_a2;
    ddp_comp_plan.description := p4_a3;
    ddp_comp_plan.status_code := p4_a4;
    ddp_comp_plan.complete_flag := p4_a5;
    ddp_comp_plan.on_quota_date := p4_a6;
    ddp_comp_plan.allow_rev_class_overlap := p4_a7;
    ddp_comp_plan.sum_trx_flag := p4_a8;
    ddp_comp_plan.start_date := p4_a9;
    ddp_comp_plan.end_date := p4_a10;
    ddp_comp_plan.attribute_category := p4_a11;
    ddp_comp_plan.attribute1 := p4_a12;
    ddp_comp_plan.attribute2 := p4_a13;
    ddp_comp_plan.attribute3 := p4_a14;
    ddp_comp_plan.attribute4 := p4_a15;
    ddp_comp_plan.attribute5 := p4_a16;
    ddp_comp_plan.attribute6 := p4_a17;
    ddp_comp_plan.attribute7 := p4_a18;
    ddp_comp_plan.attribute8 := p4_a19;
    ddp_comp_plan.attribute9 := p4_a20;
    ddp_comp_plan.attribute10 := p4_a21;
    ddp_comp_plan.attribute11 := p4_a22;
    ddp_comp_plan.attribute12 := p4_a23;
    ddp_comp_plan.attribute13 := p4_a24;
    ddp_comp_plan.attribute14 := p4_a25;
    ddp_comp_plan.attribute15 := p4_a26;
    ddp_comp_plan.object_version_number := p4_a27;
    ddp_comp_plan.org_id := p4_a28;




    -- here's the delegated call to the old PL/SQL routine
    cn_comp_plan_pvt.validate_comp_plan(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_comp_plan,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure get_assigned_salesreps(p_comp_plan_id  NUMBER
    , p_range_low  NUMBER
    , p_range_high  NUMBER
    , x_total_rows out nocopy  NUMBER
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_NUMBER_TABLE
    , p4_a2 out nocopy JTF_NUMBER_TABLE
    , p4_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a4 out nocopy JTF_VARCHAR2_TABLE_400
    , p4_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a6 out nocopy JTF_DATE_TABLE
    , p4_a7 out nocopy JTF_DATE_TABLE
  )

  as
    ddx_result_tbl cn_comp_plan_pvt.srp_plan_assign_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    -- here's the delegated call to the old PL/SQL routine
    cn_comp_plan_pvt.get_assigned_salesreps(p_comp_plan_id,
      p_range_low,
      p_range_high,
      x_total_rows,
      ddx_result_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    cn_comp_plan_pvt_w.rosetta_table_copy_out_p7(ddx_result_tbl, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      , p4_a6
      , p4_a7
      );
  end;

end cn_comp_plan_pvt_w;

/
