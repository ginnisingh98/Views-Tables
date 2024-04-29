--------------------------------------------------------
--  DDL for Package Body CN_ROLE_PLANS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_ROLE_PLANS_PUB_W" as
  /* $Header: cnwrlplb.pls 120.2 2005/09/14 03:41 vensrini ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy cn_role_plans_pub.role_plan_rec_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_200
    , a8 JTF_VARCHAR2_TABLE_200
    , a9 JTF_VARCHAR2_TABLE_200
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
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).role_name := a0(indx);
          t(ddindx).role_id := a1(indx);
          t(ddindx).comp_plan_name := a2(indx);
          t(ddindx).comp_plan_id := a3(indx);
          t(ddindx).start_date := a4(indx);
          t(ddindx).end_date := a5(indx);
          t(ddindx).attribute_category := a6(indx);
          t(ddindx).attribute1 := a7(indx);
          t(ddindx).attribute2 := a8(indx);
          t(ddindx).attribute3 := a9(indx);
          t(ddindx).attribute4 := a10(indx);
          t(ddindx).attribute5 := a11(indx);
          t(ddindx).attribute6 := a12(indx);
          t(ddindx).attribute7 := a13(indx);
          t(ddindx).attribute8 := a14(indx);
          t(ddindx).attribute9 := a15(indx);
          t(ddindx).attribute10 := a16(indx);
          t(ddindx).attribute11 := a17(indx);
          t(ddindx).attribute12 := a18(indx);
          t(ddindx).attribute13 := a19(indx);
          t(ddindx).attribute14 := a20(indx);
          t(ddindx).attribute15 := a21(indx);
          t(ddindx).object_version_number := a22(indx);
          t(ddindx).org_id := a23(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t cn_role_plans_pub.role_plan_rec_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_200
    , a8 out nocopy JTF_VARCHAR2_TABLE_200
    , a9 out nocopy JTF_VARCHAR2_TABLE_200
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
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_200();
    a8 := JTF_VARCHAR2_TABLE_200();
    a9 := JTF_VARCHAR2_TABLE_200();
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
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_200();
      a8 := JTF_VARCHAR2_TABLE_200();
      a9 := JTF_VARCHAR2_TABLE_200();
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
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).role_name;
          a1(indx) := t(ddindx).role_id;
          a2(indx) := t(ddindx).comp_plan_name;
          a3(indx) := t(ddindx).comp_plan_id;
          a4(indx) := t(ddindx).start_date;
          a5(indx) := t(ddindx).end_date;
          a6(indx) := t(ddindx).attribute_category;
          a7(indx) := t(ddindx).attribute1;
          a8(indx) := t(ddindx).attribute2;
          a9(indx) := t(ddindx).attribute3;
          a10(indx) := t(ddindx).attribute4;
          a11(indx) := t(ddindx).attribute5;
          a12(indx) := t(ddindx).attribute6;
          a13(indx) := t(ddindx).attribute7;
          a14(indx) := t(ddindx).attribute8;
          a15(indx) := t(ddindx).attribute9;
          a16(indx) := t(ddindx).attribute10;
          a17(indx) := t(ddindx).attribute11;
          a18(indx) := t(ddindx).attribute12;
          a19(indx) := t(ddindx).attribute13;
          a20(indx) := t(ddindx).attribute14;
          a21(indx) := t(ddindx).attribute15;
          a22(indx) := t(ddindx).object_version_number;
          a23(indx) := t(ddindx).org_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure create_role_plan(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0  VARCHAR2
    , p8_a1  NUMBER
    , p8_a2  VARCHAR2
    , p8_a3  NUMBER
    , p8_a4  DATE
    , p8_a5  DATE
    , p8_a6  VARCHAR2
    , p8_a7  VARCHAR2
    , p8_a8  VARCHAR2
    , p8_a9  VARCHAR2
    , p8_a10  VARCHAR2
    , p8_a11  VARCHAR2
    , p8_a12  VARCHAR2
    , p8_a13  VARCHAR2
    , p8_a14  VARCHAR2
    , p8_a15  VARCHAR2
    , p8_a16  VARCHAR2
    , p8_a17  VARCHAR2
    , p8_a18  VARCHAR2
    , p8_a19  VARCHAR2
    , p8_a20  VARCHAR2
    , p8_a21  VARCHAR2
    , p8_a22  NUMBER
    , p8_a23  NUMBER
    , x_role_plan_id out nocopy  NUMBER
    , x_obj_ver_num out nocopy  NUMBER
  )

  as
    ddp_role_plan_rec cn_role_plans_pub.role_plan_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_role_plan_rec.role_name := p8_a0;
    ddp_role_plan_rec.role_id := p8_a1;
    ddp_role_plan_rec.comp_plan_name := p8_a2;
    ddp_role_plan_rec.comp_plan_id := p8_a3;
    ddp_role_plan_rec.start_date := p8_a4;
    ddp_role_plan_rec.end_date := p8_a5;
    ddp_role_plan_rec.attribute_category := p8_a6;
    ddp_role_plan_rec.attribute1 := p8_a7;
    ddp_role_plan_rec.attribute2 := p8_a8;
    ddp_role_plan_rec.attribute3 := p8_a9;
    ddp_role_plan_rec.attribute4 := p8_a10;
    ddp_role_plan_rec.attribute5 := p8_a11;
    ddp_role_plan_rec.attribute6 := p8_a12;
    ddp_role_plan_rec.attribute7 := p8_a13;
    ddp_role_plan_rec.attribute8 := p8_a14;
    ddp_role_plan_rec.attribute9 := p8_a15;
    ddp_role_plan_rec.attribute10 := p8_a16;
    ddp_role_plan_rec.attribute11 := p8_a17;
    ddp_role_plan_rec.attribute12 := p8_a18;
    ddp_role_plan_rec.attribute13 := p8_a19;
    ddp_role_plan_rec.attribute14 := p8_a20;
    ddp_role_plan_rec.attribute15 := p8_a21;
    ddp_role_plan_rec.object_version_number := p8_a22;
    ddp_role_plan_rec.org_id := p8_a23;



    -- here's the delegated call to the old PL/SQL routine
    cn_role_plans_pub.create_role_plan(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_loading_status,
      x_msg_count,
      x_msg_data,
      ddp_role_plan_rec,
      x_role_plan_id,
      x_obj_ver_num);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

  procedure update_role_plan(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0  VARCHAR2
    , p8_a1  NUMBER
    , p8_a2  VARCHAR2
    , p8_a3  NUMBER
    , p8_a4  DATE
    , p8_a5  DATE
    , p8_a6  VARCHAR2
    , p8_a7  VARCHAR2
    , p8_a8  VARCHAR2
    , p8_a9  VARCHAR2
    , p8_a10  VARCHAR2
    , p8_a11  VARCHAR2
    , p8_a12  VARCHAR2
    , p8_a13  VARCHAR2
    , p8_a14  VARCHAR2
    , p8_a15  VARCHAR2
    , p8_a16  VARCHAR2
    , p8_a17  VARCHAR2
    , p8_a18  VARCHAR2
    , p8_a19  VARCHAR2
    , p8_a20  VARCHAR2
    , p8_a21  VARCHAR2
    , p8_a22  NUMBER
    , p8_a23  NUMBER
    , p_ovn in out nocopy  NUMBER
    , p10_a0  VARCHAR2
    , p10_a1  NUMBER
    , p10_a2  VARCHAR2
    , p10_a3  NUMBER
    , p10_a4  DATE
    , p10_a5  DATE
    , p10_a6  VARCHAR2
    , p10_a7  VARCHAR2
    , p10_a8  VARCHAR2
    , p10_a9  VARCHAR2
    , p10_a10  VARCHAR2
    , p10_a11  VARCHAR2
    , p10_a12  VARCHAR2
    , p10_a13  VARCHAR2
    , p10_a14  VARCHAR2
    , p10_a15  VARCHAR2
    , p10_a16  VARCHAR2
    , p10_a17  VARCHAR2
    , p10_a18  VARCHAR2
    , p10_a19  VARCHAR2
    , p10_a20  VARCHAR2
    , p10_a21  VARCHAR2
    , p10_a22  NUMBER
    , p10_a23  NUMBER
    , p_role_plan_id  NUMBER
  )

  as
    ddp_role_plan_rec_old cn_role_plans_pub.role_plan_rec_type;
    ddp_role_plan_rec_new cn_role_plans_pub.role_plan_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_role_plan_rec_old.role_name := p8_a0;
    ddp_role_plan_rec_old.role_id := p8_a1;
    ddp_role_plan_rec_old.comp_plan_name := p8_a2;
    ddp_role_plan_rec_old.comp_plan_id := p8_a3;
    ddp_role_plan_rec_old.start_date := p8_a4;
    ddp_role_plan_rec_old.end_date := p8_a5;
    ddp_role_plan_rec_old.attribute_category := p8_a6;
    ddp_role_plan_rec_old.attribute1 := p8_a7;
    ddp_role_plan_rec_old.attribute2 := p8_a8;
    ddp_role_plan_rec_old.attribute3 := p8_a9;
    ddp_role_plan_rec_old.attribute4 := p8_a10;
    ddp_role_plan_rec_old.attribute5 := p8_a11;
    ddp_role_plan_rec_old.attribute6 := p8_a12;
    ddp_role_plan_rec_old.attribute7 := p8_a13;
    ddp_role_plan_rec_old.attribute8 := p8_a14;
    ddp_role_plan_rec_old.attribute9 := p8_a15;
    ddp_role_plan_rec_old.attribute10 := p8_a16;
    ddp_role_plan_rec_old.attribute11 := p8_a17;
    ddp_role_plan_rec_old.attribute12 := p8_a18;
    ddp_role_plan_rec_old.attribute13 := p8_a19;
    ddp_role_plan_rec_old.attribute14 := p8_a20;
    ddp_role_plan_rec_old.attribute15 := p8_a21;
    ddp_role_plan_rec_old.object_version_number := p8_a22;
    ddp_role_plan_rec_old.org_id := p8_a23;


    ddp_role_plan_rec_new.role_name := p10_a0;
    ddp_role_plan_rec_new.role_id := p10_a1;
    ddp_role_plan_rec_new.comp_plan_name := p10_a2;
    ddp_role_plan_rec_new.comp_plan_id := p10_a3;
    ddp_role_plan_rec_new.start_date := p10_a4;
    ddp_role_plan_rec_new.end_date := p10_a5;
    ddp_role_plan_rec_new.attribute_category := p10_a6;
    ddp_role_plan_rec_new.attribute1 := p10_a7;
    ddp_role_plan_rec_new.attribute2 := p10_a8;
    ddp_role_plan_rec_new.attribute3 := p10_a9;
    ddp_role_plan_rec_new.attribute4 := p10_a10;
    ddp_role_plan_rec_new.attribute5 := p10_a11;
    ddp_role_plan_rec_new.attribute6 := p10_a12;
    ddp_role_plan_rec_new.attribute7 := p10_a13;
    ddp_role_plan_rec_new.attribute8 := p10_a14;
    ddp_role_plan_rec_new.attribute9 := p10_a15;
    ddp_role_plan_rec_new.attribute10 := p10_a16;
    ddp_role_plan_rec_new.attribute11 := p10_a17;
    ddp_role_plan_rec_new.attribute12 := p10_a18;
    ddp_role_plan_rec_new.attribute13 := p10_a19;
    ddp_role_plan_rec_new.attribute14 := p10_a20;
    ddp_role_plan_rec_new.attribute15 := p10_a21;
    ddp_role_plan_rec_new.object_version_number := p10_a22;
    ddp_role_plan_rec_new.org_id := p10_a23;


    -- here's the delegated call to the old PL/SQL routine
    cn_role_plans_pub.update_role_plan(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_loading_status,
      x_msg_count,
      x_msg_data,
      ddp_role_plan_rec_old,
      p_ovn,
      ddp_role_plan_rec_new,
      p_role_plan_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

  procedure delete_role_plan(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0  VARCHAR2
    , p8_a1  NUMBER
    , p8_a2  VARCHAR2
    , p8_a3  NUMBER
    , p8_a4  DATE
    , p8_a5  DATE
    , p8_a6  VARCHAR2
    , p8_a7  VARCHAR2
    , p8_a8  VARCHAR2
    , p8_a9  VARCHAR2
    , p8_a10  VARCHAR2
    , p8_a11  VARCHAR2
    , p8_a12  VARCHAR2
    , p8_a13  VARCHAR2
    , p8_a14  VARCHAR2
    , p8_a15  VARCHAR2
    , p8_a16  VARCHAR2
    , p8_a17  VARCHAR2
    , p8_a18  VARCHAR2
    , p8_a19  VARCHAR2
    , p8_a20  VARCHAR2
    , p8_a21  VARCHAR2
    , p8_a22  NUMBER
    , p8_a23  NUMBER
  )

  as
    ddp_role_plan_rec cn_role_plans_pub.role_plan_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_role_plan_rec.role_name := p8_a0;
    ddp_role_plan_rec.role_id := p8_a1;
    ddp_role_plan_rec.comp_plan_name := p8_a2;
    ddp_role_plan_rec.comp_plan_id := p8_a3;
    ddp_role_plan_rec.start_date := p8_a4;
    ddp_role_plan_rec.end_date := p8_a5;
    ddp_role_plan_rec.attribute_category := p8_a6;
    ddp_role_plan_rec.attribute1 := p8_a7;
    ddp_role_plan_rec.attribute2 := p8_a8;
    ddp_role_plan_rec.attribute3 := p8_a9;
    ddp_role_plan_rec.attribute4 := p8_a10;
    ddp_role_plan_rec.attribute5 := p8_a11;
    ddp_role_plan_rec.attribute6 := p8_a12;
    ddp_role_plan_rec.attribute7 := p8_a13;
    ddp_role_plan_rec.attribute8 := p8_a14;
    ddp_role_plan_rec.attribute9 := p8_a15;
    ddp_role_plan_rec.attribute10 := p8_a16;
    ddp_role_plan_rec.attribute11 := p8_a17;
    ddp_role_plan_rec.attribute12 := p8_a18;
    ddp_role_plan_rec.attribute13 := p8_a19;
    ddp_role_plan_rec.attribute14 := p8_a20;
    ddp_role_plan_rec.attribute15 := p8_a21;
    ddp_role_plan_rec.object_version_number := p8_a22;
    ddp_role_plan_rec.org_id := p8_a23;

    -- here's the delegated call to the old PL/SQL routine
    cn_role_plans_pub.delete_role_plan(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_loading_status,
      x_msg_count,
      x_msg_data,
      ddp_role_plan_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

end cn_role_plans_pub_w;

/
