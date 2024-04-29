--------------------------------------------------------
--  DDL for Package Body EAM_CONSTRUCTION_UNIT_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_CONSTRUCTION_UNIT_PUB_W" as
  /* $Header: EAMPCUWB.pls 120.0.12010000.2 2008/11/20 04:37:58 dsingire noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_high date := to_date('01/01/+4710', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_low date := to_date('01/01/-4710', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d > rosetta_g_mistake_date_high then return fnd_api.g_miss_date; end if;
    if d < rosetta_g_mistake_date_low then return fnd_api.g_miss_date; end if;
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

  procedure rosetta_table_copy_in_p2(t out nocopy eam_construction_unit_pub.cu_activity_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).cu_detail_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).cu_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).acct_class_code := a2(indx);
          t(ddindx).activity_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).cu_activity_qty := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).cu_activity_effective_from := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).cu_activity_effective_to := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).cu_assign_to_org := a7(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t eam_construction_unit_pub.cu_activity_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).cu_detail_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).cu_id);
          a2(indx) := t(ddindx).acct_class_code;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).activity_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).cu_activity_qty);
          a5(indx) := t(ddindx).cu_activity_effective_from;
          a6(indx) := t(ddindx).cu_activity_effective_to;
          a7(indx) := t(ddindx).cu_assign_to_org;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p4(t out nocopy eam_construction_unit_pub.cu_id_tbl, a0 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).cu_id := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t eam_construction_unit_pub.cu_id_tbl, a0 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).cu_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure create_construction_unit(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p3_a0 JTF_NUMBER_TABLE
    , p3_a1 JTF_NUMBER_TABLE
    , p3_a2 JTF_VARCHAR2_TABLE_100
    , p3_a3 JTF_NUMBER_TABLE
    , p3_a4 JTF_NUMBER_TABLE
    , p3_a5 JTF_DATE_TABLE
    , p3_a6 JTF_DATE_TABLE
    , p3_a7 JTF_VARCHAR2_TABLE_100
    , x_cu_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p2_a0  NUMBER := 0-1962.0724
    , p2_a1  VARCHAR2 := fnd_api.g_miss_char
    , p2_a2  VARCHAR2 := fnd_api.g_miss_char
    , p2_a3  NUMBER := 0-1962.0724
    , p2_a4  DATE := fnd_api.g_miss_date
    , p2_a5  DATE := fnd_api.g_miss_date
    , p2_a6  VARCHAR2 := fnd_api.g_miss_char
    , p2_a7  VARCHAR2 := fnd_api.g_miss_char
    , p2_a8  VARCHAR2 := fnd_api.g_miss_char
    , p2_a9  VARCHAR2 := fnd_api.g_miss_char
    , p2_a10  VARCHAR2 := fnd_api.g_miss_char
    , p2_a11  VARCHAR2 := fnd_api.g_miss_char
    , p2_a12  VARCHAR2 := fnd_api.g_miss_char
    , p2_a13  VARCHAR2 := fnd_api.g_miss_char
    , p2_a14  VARCHAR2 := fnd_api.g_miss_char
    , p2_a15  VARCHAR2 := fnd_api.g_miss_char
    , p2_a16  VARCHAR2 := fnd_api.g_miss_char
    , p2_a17  VARCHAR2 := fnd_api.g_miss_char
    , p2_a18  VARCHAR2 := fnd_api.g_miss_char
    , p2_a19  VARCHAR2 := fnd_api.g_miss_char
    , p2_a20  VARCHAR2 := fnd_api.g_miss_char
    , p2_a21  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_cu_rec eam_construction_unit_pub.cu_rec;
    ddp_cu_activity_tbl eam_construction_unit_pub.cu_activity_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_cu_rec.cu_id := rosetta_g_miss_num_map(p2_a0);
    ddp_cu_rec.cu_name := p2_a1;
    ddp_cu_rec.description := p2_a2;
    ddp_cu_rec.organization_id := rosetta_g_miss_num_map(p2_a3);
    ddp_cu_rec.cu_effective_from := rosetta_g_miss_date_in_map(p2_a4);
    ddp_cu_rec.cu_effective_to := rosetta_g_miss_date_in_map(p2_a5);
    ddp_cu_rec.attribute_category := p2_a6;
    ddp_cu_rec.attribute1 := p2_a7;
    ddp_cu_rec.attribute2 := p2_a8;
    ddp_cu_rec.attribute3 := p2_a9;
    ddp_cu_rec.attribute4 := p2_a10;
    ddp_cu_rec.attribute5 := p2_a11;
    ddp_cu_rec.attribute6 := p2_a12;
    ddp_cu_rec.attribute7 := p2_a13;
    ddp_cu_rec.attribute8 := p2_a14;
    ddp_cu_rec.attribute9 := p2_a15;
    ddp_cu_rec.attribute10 := p2_a16;
    ddp_cu_rec.attribute11 := p2_a17;
    ddp_cu_rec.attribute12 := p2_a18;
    ddp_cu_rec.attribute13 := p2_a19;
    ddp_cu_rec.attribute14 := p2_a20;
    ddp_cu_rec.attribute15 := p2_a21;

    eam_construction_unit_pub_w.rosetta_table_copy_in_p2(ddp_cu_activity_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      );





    -- here's the delegated call to the old PL/SQL routine
    eam_construction_unit_pub.create_construction_unit(p_api_version,
      p_commit,
      ddp_cu_rec,
      ddp_cu_activity_tbl,
      x_cu_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure update_construction_unit(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p3_a0 JTF_NUMBER_TABLE
    , p3_a1 JTF_NUMBER_TABLE
    , p3_a2 JTF_VARCHAR2_TABLE_100
    , p3_a3 JTF_NUMBER_TABLE
    , p3_a4 JTF_NUMBER_TABLE
    , p3_a5 JTF_DATE_TABLE
    , p3_a6 JTF_DATE_TABLE
    , p3_a7 JTF_VARCHAR2_TABLE_100
    , x_cu_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p2_a0  NUMBER := 0-1962.0724
    , p2_a1  VARCHAR2 := fnd_api.g_miss_char
    , p2_a2  VARCHAR2 := fnd_api.g_miss_char
    , p2_a3  NUMBER := 0-1962.0724
    , p2_a4  DATE := fnd_api.g_miss_date
    , p2_a5  DATE := fnd_api.g_miss_date
    , p2_a6  VARCHAR2 := fnd_api.g_miss_char
    , p2_a7  VARCHAR2 := fnd_api.g_miss_char
    , p2_a8  VARCHAR2 := fnd_api.g_miss_char
    , p2_a9  VARCHAR2 := fnd_api.g_miss_char
    , p2_a10  VARCHAR2 := fnd_api.g_miss_char
    , p2_a11  VARCHAR2 := fnd_api.g_miss_char
    , p2_a12  VARCHAR2 := fnd_api.g_miss_char
    , p2_a13  VARCHAR2 := fnd_api.g_miss_char
    , p2_a14  VARCHAR2 := fnd_api.g_miss_char
    , p2_a15  VARCHAR2 := fnd_api.g_miss_char
    , p2_a16  VARCHAR2 := fnd_api.g_miss_char
    , p2_a17  VARCHAR2 := fnd_api.g_miss_char
    , p2_a18  VARCHAR2 := fnd_api.g_miss_char
    , p2_a19  VARCHAR2 := fnd_api.g_miss_char
    , p2_a20  VARCHAR2 := fnd_api.g_miss_char
    , p2_a21  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_cu_rec eam_construction_unit_pub.cu_rec;
    ddp_cu_activity_tbl eam_construction_unit_pub.cu_activity_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_cu_rec.cu_id := rosetta_g_miss_num_map(p2_a0);
    ddp_cu_rec.cu_name := p2_a1;
    ddp_cu_rec.description := p2_a2;
    ddp_cu_rec.organization_id := rosetta_g_miss_num_map(p2_a3);
    ddp_cu_rec.cu_effective_from := rosetta_g_miss_date_in_map(p2_a4);
    ddp_cu_rec.cu_effective_to := rosetta_g_miss_date_in_map(p2_a5);
    ddp_cu_rec.attribute_category := p2_a6;
    ddp_cu_rec.attribute1 := p2_a7;
    ddp_cu_rec.attribute2 := p2_a8;
    ddp_cu_rec.attribute3 := p2_a9;
    ddp_cu_rec.attribute4 := p2_a10;
    ddp_cu_rec.attribute5 := p2_a11;
    ddp_cu_rec.attribute6 := p2_a12;
    ddp_cu_rec.attribute7 := p2_a13;
    ddp_cu_rec.attribute8 := p2_a14;
    ddp_cu_rec.attribute9 := p2_a15;
    ddp_cu_rec.attribute10 := p2_a16;
    ddp_cu_rec.attribute11 := p2_a17;
    ddp_cu_rec.attribute12 := p2_a18;
    ddp_cu_rec.attribute13 := p2_a19;
    ddp_cu_rec.attribute14 := p2_a20;
    ddp_cu_rec.attribute15 := p2_a21;

    eam_construction_unit_pub_w.rosetta_table_copy_in_p2(ddp_cu_activity_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      );





    -- here's the delegated call to the old PL/SQL routine
    eam_construction_unit_pub.update_construction_unit(p_api_version,
      p_commit,
      ddp_cu_rec,
      ddp_cu_activity_tbl,
      x_cu_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure copy_construction_unit(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p3_a0 JTF_NUMBER_TABLE
    , p3_a1 JTF_NUMBER_TABLE
    , p3_a2 JTF_VARCHAR2_TABLE_100
    , p3_a3 JTF_NUMBER_TABLE
    , p3_a4 JTF_NUMBER_TABLE
    , p3_a5 JTF_DATE_TABLE
    , p3_a6 JTF_DATE_TABLE
    , p3_a7 JTF_VARCHAR2_TABLE_100
    , p4_a0 JTF_NUMBER_TABLE
    , x_cu_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p2_a0  NUMBER := 0-1962.0724
    , p2_a1  VARCHAR2 := fnd_api.g_miss_char
    , p2_a2  VARCHAR2 := fnd_api.g_miss_char
    , p2_a3  NUMBER := 0-1962.0724
    , p2_a4  DATE := fnd_api.g_miss_date
    , p2_a5  DATE := fnd_api.g_miss_date
    , p2_a6  VARCHAR2 := fnd_api.g_miss_char
    , p2_a7  VARCHAR2 := fnd_api.g_miss_char
    , p2_a8  VARCHAR2 := fnd_api.g_miss_char
    , p2_a9  VARCHAR2 := fnd_api.g_miss_char
    , p2_a10  VARCHAR2 := fnd_api.g_miss_char
    , p2_a11  VARCHAR2 := fnd_api.g_miss_char
    , p2_a12  VARCHAR2 := fnd_api.g_miss_char
    , p2_a13  VARCHAR2 := fnd_api.g_miss_char
    , p2_a14  VARCHAR2 := fnd_api.g_miss_char
    , p2_a15  VARCHAR2 := fnd_api.g_miss_char
    , p2_a16  VARCHAR2 := fnd_api.g_miss_char
    , p2_a17  VARCHAR2 := fnd_api.g_miss_char
    , p2_a18  VARCHAR2 := fnd_api.g_miss_char
    , p2_a19  VARCHAR2 := fnd_api.g_miss_char
    , p2_a20  VARCHAR2 := fnd_api.g_miss_char
    , p2_a21  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_cu_rec eam_construction_unit_pub.cu_rec;
    ddp_cu_activity_tbl eam_construction_unit_pub.cu_activity_tbl;
    ddp_source_cu_id_tbl eam_construction_unit_pub.cu_id_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_cu_rec.cu_id := rosetta_g_miss_num_map(p2_a0);
    ddp_cu_rec.cu_name := p2_a1;
    ddp_cu_rec.description := p2_a2;
    ddp_cu_rec.organization_id := rosetta_g_miss_num_map(p2_a3);
    ddp_cu_rec.cu_effective_from := rosetta_g_miss_date_in_map(p2_a4);
    ddp_cu_rec.cu_effective_to := rosetta_g_miss_date_in_map(p2_a5);
    ddp_cu_rec.attribute_category := p2_a6;
    ddp_cu_rec.attribute1 := p2_a7;
    ddp_cu_rec.attribute2 := p2_a8;
    ddp_cu_rec.attribute3 := p2_a9;
    ddp_cu_rec.attribute4 := p2_a10;
    ddp_cu_rec.attribute5 := p2_a11;
    ddp_cu_rec.attribute6 := p2_a12;
    ddp_cu_rec.attribute7 := p2_a13;
    ddp_cu_rec.attribute8 := p2_a14;
    ddp_cu_rec.attribute9 := p2_a15;
    ddp_cu_rec.attribute10 := p2_a16;
    ddp_cu_rec.attribute11 := p2_a17;
    ddp_cu_rec.attribute12 := p2_a18;
    ddp_cu_rec.attribute13 := p2_a19;
    ddp_cu_rec.attribute14 := p2_a20;
    ddp_cu_rec.attribute15 := p2_a21;

    eam_construction_unit_pub_w.rosetta_table_copy_in_p2(ddp_cu_activity_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      );

    eam_construction_unit_pub_w.rosetta_table_copy_in_p4(ddp_source_cu_id_tbl, p4_a0
      );





    -- here's the delegated call to the old PL/SQL routine
    eam_construction_unit_pub.copy_construction_unit(p_api_version,
      p_commit,
      ddp_cu_rec,
      ddp_cu_activity_tbl,
      ddp_source_cu_id_tbl,
      x_cu_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

end eam_construction_unit_pub_w;

/
