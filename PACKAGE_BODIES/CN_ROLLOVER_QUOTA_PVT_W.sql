--------------------------------------------------------
--  DDL for Package Body CN_ROLLOVER_QUOTA_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_ROLLOVER_QUOTA_PVT_W" as
  /* $Header: cnwrqb.pls 115.1 2002/12/04 02:44:05 clku noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p1(t out nocopy cn_rollover_quota_pvt.rollover_quota_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
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
    , a19 JTF_VARCHAR2_TABLE_200
    , a20 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).rollover_quota_id := a0(indx);
          t(ddindx).quota_id := a1(indx);
          t(ddindx).source_quota_id := a2(indx);
          t(ddindx).rollover := a3(indx);
          t(ddindx).attribute_category := a4(indx);
          t(ddindx).attribute1 := a5(indx);
          t(ddindx).attribute2 := a6(indx);
          t(ddindx).attribute3 := a7(indx);
          t(ddindx).attribute4 := a8(indx);
          t(ddindx).attribute5 := a9(indx);
          t(ddindx).attribute6 := a10(indx);
          t(ddindx).attribute7 := a11(indx);
          t(ddindx).attribute8 := a12(indx);
          t(ddindx).attribute9 := a13(indx);
          t(ddindx).attribute10 := a14(indx);
          t(ddindx).attribute11 := a15(indx);
          t(ddindx).attribute12 := a16(indx);
          t(ddindx).attribute13 := a17(indx);
          t(ddindx).attribute14 := a18(indx);
          t(ddindx).attribute15 := a19(indx);
          t(ddindx).object_version_number := a20(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t cn_rollover_quota_pvt.rollover_quota_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a19 out nocopy JTF_VARCHAR2_TABLE_200
    , a20 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
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
    a19 := JTF_VARCHAR2_TABLE_200();
    a20 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
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
      a19 := JTF_VARCHAR2_TABLE_200();
      a20 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).rollover_quota_id;
          a1(indx) := t(ddindx).quota_id;
          a2(indx) := t(ddindx).source_quota_id;
          a3(indx) := t(ddindx).rollover;
          a4(indx) := t(ddindx).attribute_category;
          a5(indx) := t(ddindx).attribute1;
          a6(indx) := t(ddindx).attribute2;
          a7(indx) := t(ddindx).attribute3;
          a8(indx) := t(ddindx).attribute4;
          a9(indx) := t(ddindx).attribute5;
          a10(indx) := t(ddindx).attribute6;
          a11(indx) := t(ddindx).attribute7;
          a12(indx) := t(ddindx).attribute8;
          a13(indx) := t(ddindx).attribute9;
          a14(indx) := t(ddindx).attribute10;
          a15(indx) := t(ddindx).attribute11;
          a16(indx) := t(ddindx).attribute12;
          a17(indx) := t(ddindx).attribute13;
          a18(indx) := t(ddindx).attribute14;
          a19(indx) := t(ddindx).attribute15;
          a20(indx) := t(ddindx).object_version_number;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure create_rollover_quota(p_api_version  NUMBER
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
    , p4_a19  VARCHAR2
    , p4_a20  NUMBER
    , x_rollover_quota_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_rollover_quota cn_rollover_quota_pvt.rollover_quota_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_rollover_quota.rollover_quota_id := p4_a0;
    ddp_rollover_quota.quota_id := p4_a1;
    ddp_rollover_quota.source_quota_id := p4_a2;
    ddp_rollover_quota.rollover := p4_a3;
    ddp_rollover_quota.attribute_category := p4_a4;
    ddp_rollover_quota.attribute1 := p4_a5;
    ddp_rollover_quota.attribute2 := p4_a6;
    ddp_rollover_quota.attribute3 := p4_a7;
    ddp_rollover_quota.attribute4 := p4_a8;
    ddp_rollover_quota.attribute5 := p4_a9;
    ddp_rollover_quota.attribute6 := p4_a10;
    ddp_rollover_quota.attribute7 := p4_a11;
    ddp_rollover_quota.attribute8 := p4_a12;
    ddp_rollover_quota.attribute9 := p4_a13;
    ddp_rollover_quota.attribute10 := p4_a14;
    ddp_rollover_quota.attribute11 := p4_a15;
    ddp_rollover_quota.attribute12 := p4_a16;
    ddp_rollover_quota.attribute13 := p4_a17;
    ddp_rollover_quota.attribute14 := p4_a18;
    ddp_rollover_quota.attribute15 := p4_a19;
    ddp_rollover_quota.object_version_number := p4_a20;





    -- here's the delegated call to the old PL/SQL routine
    cn_rollover_quota_pvt.create_rollover_quota(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_rollover_quota,
      x_rollover_quota_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_rollover_quota(p_api_version  NUMBER
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
    , p4_a19  VARCHAR2
    , p4_a20  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_rollover_quota cn_rollover_quota_pvt.rollover_quota_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_rollover_quota.rollover_quota_id := p4_a0;
    ddp_rollover_quota.quota_id := p4_a1;
    ddp_rollover_quota.source_quota_id := p4_a2;
    ddp_rollover_quota.rollover := p4_a3;
    ddp_rollover_quota.attribute_category := p4_a4;
    ddp_rollover_quota.attribute1 := p4_a5;
    ddp_rollover_quota.attribute2 := p4_a6;
    ddp_rollover_quota.attribute3 := p4_a7;
    ddp_rollover_quota.attribute4 := p4_a8;
    ddp_rollover_quota.attribute5 := p4_a9;
    ddp_rollover_quota.attribute6 := p4_a10;
    ddp_rollover_quota.attribute7 := p4_a11;
    ddp_rollover_quota.attribute8 := p4_a12;
    ddp_rollover_quota.attribute9 := p4_a13;
    ddp_rollover_quota.attribute10 := p4_a14;
    ddp_rollover_quota.attribute11 := p4_a15;
    ddp_rollover_quota.attribute12 := p4_a16;
    ddp_rollover_quota.attribute13 := p4_a17;
    ddp_rollover_quota.attribute14 := p4_a18;
    ddp_rollover_quota.attribute15 := p4_a19;
    ddp_rollover_quota.object_version_number := p4_a20;




    -- here's the delegated call to the old PL/SQL routine
    cn_rollover_quota_pvt.update_rollover_quota(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_rollover_quota,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure delete_rollover_quota(p_api_version  NUMBER
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
    , p4_a19  VARCHAR2
    , p4_a20  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_rollover_quota cn_rollover_quota_pvt.rollover_quota_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_rollover_quota.rollover_quota_id := p4_a0;
    ddp_rollover_quota.quota_id := p4_a1;
    ddp_rollover_quota.source_quota_id := p4_a2;
    ddp_rollover_quota.rollover := p4_a3;
    ddp_rollover_quota.attribute_category := p4_a4;
    ddp_rollover_quota.attribute1 := p4_a5;
    ddp_rollover_quota.attribute2 := p4_a6;
    ddp_rollover_quota.attribute3 := p4_a7;
    ddp_rollover_quota.attribute4 := p4_a8;
    ddp_rollover_quota.attribute5 := p4_a9;
    ddp_rollover_quota.attribute6 := p4_a10;
    ddp_rollover_quota.attribute7 := p4_a11;
    ddp_rollover_quota.attribute8 := p4_a12;
    ddp_rollover_quota.attribute9 := p4_a13;
    ddp_rollover_quota.attribute10 := p4_a14;
    ddp_rollover_quota.attribute11 := p4_a15;
    ddp_rollover_quota.attribute12 := p4_a16;
    ddp_rollover_quota.attribute13 := p4_a17;
    ddp_rollover_quota.attribute14 := p4_a18;
    ddp_rollover_quota.attribute15 := p4_a19;
    ddp_rollover_quota.object_version_number := p4_a20;




    -- here's the delegated call to the old PL/SQL routine
    cn_rollover_quota_pvt.delete_rollover_quota(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_rollover_quota,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

end cn_rollover_quota_pvt_w;

/
