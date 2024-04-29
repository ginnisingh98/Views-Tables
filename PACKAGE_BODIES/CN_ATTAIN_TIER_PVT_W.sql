--------------------------------------------------------
--  DDL for Package Body CN_ATTAIN_TIER_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_ATTAIN_TIER_PVT_W" as
  /* $Header: cnwattrb.pls 115.3 2002/11/25 22:22:46 nkodkani ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p1(t out nocopy cn_attain_tier_pvt.attain_tier_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_200
    , a5 JTF_VARCHAR2_TABLE_200
    , a6 JTF_VARCHAR2_TABLE_200
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
    , a19 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).attain_tier_id := a0(indx);
          t(ddindx).attain_schedule_id := a1(indx);
          t(ddindx).percent := a2(indx);
          t(ddindx).attribute_category := a3(indx);
          t(ddindx).attribute1 := a4(indx);
          t(ddindx).attribute2 := a5(indx);
          t(ddindx).attribute3 := a6(indx);
          t(ddindx).attribute4 := a7(indx);
          t(ddindx).attribute5 := a8(indx);
          t(ddindx).attribute6 := a9(indx);
          t(ddindx).attribute7 := a10(indx);
          t(ddindx).attribute8 := a11(indx);
          t(ddindx).attribute9 := a12(indx);
          t(ddindx).attribute10 := a13(indx);
          t(ddindx).attribute11 := a14(indx);
          t(ddindx).attribute12 := a15(indx);
          t(ddindx).attribute13 := a16(indx);
          t(ddindx).attribute14 := a17(indx);
          t(ddindx).attribute15 := a18(indx);
          t(ddindx).object_version_number := a19(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t cn_attain_tier_pvt.attain_tier_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_200
    , a5 out nocopy JTF_VARCHAR2_TABLE_200
    , a6 out nocopy JTF_VARCHAR2_TABLE_200
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
    , a19 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_200();
    a5 := JTF_VARCHAR2_TABLE_200();
    a6 := JTF_VARCHAR2_TABLE_200();
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
    a19 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_200();
      a5 := JTF_VARCHAR2_TABLE_200();
      a6 := JTF_VARCHAR2_TABLE_200();
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
      a19 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).attain_tier_id;
          a1(indx) := t(ddindx).attain_schedule_id;
          a2(indx) := t(ddindx).percent;
          a3(indx) := t(ddindx).attribute_category;
          a4(indx) := t(ddindx).attribute1;
          a5(indx) := t(ddindx).attribute2;
          a6(indx) := t(ddindx).attribute3;
          a7(indx) := t(ddindx).attribute4;
          a8(indx) := t(ddindx).attribute5;
          a9(indx) := t(ddindx).attribute6;
          a10(indx) := t(ddindx).attribute7;
          a11(indx) := t(ddindx).attribute8;
          a12(indx) := t(ddindx).attribute9;
          a13(indx) := t(ddindx).attribute10;
          a14(indx) := t(ddindx).attribute11;
          a15(indx) := t(ddindx).attribute12;
          a16(indx) := t(ddindx).attribute13;
          a17(indx) := t(ddindx).attribute14;
          a18(indx) := t(ddindx).attribute15;
          a19(indx) := t(ddindx).object_version_number;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure create_attain_tier(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  NUMBER
    , p4_a3  VARCHAR2
    , p4_a4  VARCHAR2
    , p4_a5  VARCHAR2
    , p4_a6  VARCHAR2
    , p4_a7  VARCHAR2
    , p4_a8  VARCHAR2
    , p4_a9  VARCHAR2
    , p4_a10  VARCHAR2
    , p4_a11  VARCHAR2
    , p4_a12  VARCHAR2
    , p4_a13  VARCHAR2
    , p4_a14  VARCHAR2
    , p4_a15  VARCHAR2
    , p4_a16  VARCHAR2
    , p4_a17  VARCHAR2
    , p4_a18  VARCHAR2
    , p4_a19  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_attain_tier cn_attain_tier_pvt.attain_tier_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_attain_tier.attain_tier_id := p4_a0;
    ddp_attain_tier.attain_schedule_id := p4_a1;
    ddp_attain_tier.percent := p4_a2;
    ddp_attain_tier.attribute_category := p4_a3;
    ddp_attain_tier.attribute1 := p4_a4;
    ddp_attain_tier.attribute2 := p4_a5;
    ddp_attain_tier.attribute3 := p4_a6;
    ddp_attain_tier.attribute4 := p4_a7;
    ddp_attain_tier.attribute5 := p4_a8;
    ddp_attain_tier.attribute6 := p4_a9;
    ddp_attain_tier.attribute7 := p4_a10;
    ddp_attain_tier.attribute8 := p4_a11;
    ddp_attain_tier.attribute9 := p4_a12;
    ddp_attain_tier.attribute10 := p4_a13;
    ddp_attain_tier.attribute11 := p4_a14;
    ddp_attain_tier.attribute12 := p4_a15;
    ddp_attain_tier.attribute13 := p4_a16;
    ddp_attain_tier.attribute14 := p4_a17;
    ddp_attain_tier.attribute15 := p4_a18;
    ddp_attain_tier.object_version_number := p4_a19;




    -- here's the delegated call to the old PL/SQL routine
    cn_attain_tier_pvt.create_attain_tier(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_attain_tier,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure update_attain_tier(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  NUMBER
    , p4_a3  VARCHAR2
    , p4_a4  VARCHAR2
    , p4_a5  VARCHAR2
    , p4_a6  VARCHAR2
    , p4_a7  VARCHAR2
    , p4_a8  VARCHAR2
    , p4_a9  VARCHAR2
    , p4_a10  VARCHAR2
    , p4_a11  VARCHAR2
    , p4_a12  VARCHAR2
    , p4_a13  VARCHAR2
    , p4_a14  VARCHAR2
    , p4_a15  VARCHAR2
    , p4_a16  VARCHAR2
    , p4_a17  VARCHAR2
    , p4_a18  VARCHAR2
    , p4_a19  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_attain_tier cn_attain_tier_pvt.attain_tier_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_attain_tier.attain_tier_id := p4_a0;
    ddp_attain_tier.attain_schedule_id := p4_a1;
    ddp_attain_tier.percent := p4_a2;
    ddp_attain_tier.attribute_category := p4_a3;
    ddp_attain_tier.attribute1 := p4_a4;
    ddp_attain_tier.attribute2 := p4_a5;
    ddp_attain_tier.attribute3 := p4_a6;
    ddp_attain_tier.attribute4 := p4_a7;
    ddp_attain_tier.attribute5 := p4_a8;
    ddp_attain_tier.attribute6 := p4_a9;
    ddp_attain_tier.attribute7 := p4_a10;
    ddp_attain_tier.attribute8 := p4_a11;
    ddp_attain_tier.attribute9 := p4_a12;
    ddp_attain_tier.attribute10 := p4_a13;
    ddp_attain_tier.attribute11 := p4_a14;
    ddp_attain_tier.attribute12 := p4_a15;
    ddp_attain_tier.attribute13 := p4_a16;
    ddp_attain_tier.attribute14 := p4_a17;
    ddp_attain_tier.attribute15 := p4_a18;
    ddp_attain_tier.object_version_number := p4_a19;




    -- here's the delegated call to the old PL/SQL routine
    cn_attain_tier_pvt.update_attain_tier(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_attain_tier,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure delete_attain_tier(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  NUMBER
    , p4_a3  VARCHAR2
    , p4_a4  VARCHAR2
    , p4_a5  VARCHAR2
    , p4_a6  VARCHAR2
    , p4_a7  VARCHAR2
    , p4_a8  VARCHAR2
    , p4_a9  VARCHAR2
    , p4_a10  VARCHAR2
    , p4_a11  VARCHAR2
    , p4_a12  VARCHAR2
    , p4_a13  VARCHAR2
    , p4_a14  VARCHAR2
    , p4_a15  VARCHAR2
    , p4_a16  VARCHAR2
    , p4_a17  VARCHAR2
    , p4_a18  VARCHAR2
    , p4_a19  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_attain_tier cn_attain_tier_pvt.attain_tier_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_attain_tier.attain_tier_id := p4_a0;
    ddp_attain_tier.attain_schedule_id := p4_a1;
    ddp_attain_tier.percent := p4_a2;
    ddp_attain_tier.attribute_category := p4_a3;
    ddp_attain_tier.attribute1 := p4_a4;
    ddp_attain_tier.attribute2 := p4_a5;
    ddp_attain_tier.attribute3 := p4_a6;
    ddp_attain_tier.attribute4 := p4_a7;
    ddp_attain_tier.attribute5 := p4_a8;
    ddp_attain_tier.attribute6 := p4_a9;
    ddp_attain_tier.attribute7 := p4_a10;
    ddp_attain_tier.attribute8 := p4_a11;
    ddp_attain_tier.attribute9 := p4_a12;
    ddp_attain_tier.attribute10 := p4_a13;
    ddp_attain_tier.attribute11 := p4_a14;
    ddp_attain_tier.attribute12 := p4_a15;
    ddp_attain_tier.attribute13 := p4_a16;
    ddp_attain_tier.attribute14 := p4_a17;
    ddp_attain_tier.attribute15 := p4_a18;
    ddp_attain_tier.object_version_number := p4_a19;




    -- here's the delegated call to the old PL/SQL routine
    cn_attain_tier_pvt.delete_attain_tier(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_attain_tier,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure get_attain_tier(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_attain_schedule_id  NUMBER
    , p5_a0 out nocopy JTF_NUMBER_TABLE
    , p5_a1 out nocopy JTF_NUMBER_TABLE
    , p5_a2 out nocopy JTF_NUMBER_TABLE
    , p5_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a4 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a5 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a6 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a9 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a10 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a11 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a13 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a19 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_attain_tier cn_attain_tier_pvt.attain_tier_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    cn_attain_tier_pvt.get_attain_tier(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_attain_schedule_id,
      ddx_attain_tier,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    cn_attain_tier_pvt_w.rosetta_table_copy_out_p1(ddx_attain_tier, p5_a0
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
      );



  end;

end cn_attain_tier_pvt_w;

/
