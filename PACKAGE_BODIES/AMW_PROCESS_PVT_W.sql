--------------------------------------------------------
--  DDL for Package Body AMW_PROCESS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_PROCESS_PVT_W" as
  /* $Header: amwwprlb.pls 115.1 2003/06/23 20:27:07 mpande noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p3(t out nocopy amw_process_pvt.process_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_DATE_TABLE
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_200
    , a19 JTF_VARCHAR2_TABLE_200
    , a20 JTF_VARCHAR2_TABLE_200
    , a21 JTF_VARCHAR2_TABLE_200
    , a22 JTF_VARCHAR2_TABLE_200
    , a23 JTF_VARCHAR2_TABLE_200
    , a24 JTF_VARCHAR2_TABLE_200
    , a25 JTF_VARCHAR2_TABLE_200
    , a26 JTF_VARCHAR2_TABLE_200
    , a27 JTF_VARCHAR2_TABLE_200
    , a28 JTF_VARCHAR2_TABLE_200
    , a29 JTF_VARCHAR2_TABLE_200
    , a30 JTF_VARCHAR2_TABLE_200
    , a31 JTF_VARCHAR2_TABLE_200
    , a32 JTF_VARCHAR2_TABLE_200
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_NUMBER_TABLE
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).significant_process_flag := a0(indx);
          t(ddindx).standard_process_flag := a1(indx);
          t(ddindx).approval_status := a2(indx);
          t(ddindx).certification_status := a3(indx);
          t(ddindx).process_owner_id := a4(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).last_updated_by := a6(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).created_by := a8(indx);
          t(ddindx).last_update_login := a9(indx);
          t(ddindx).item_type := a10(indx);
          t(ddindx).name := a11(indx);
          t(ddindx).created_from := a12(indx);
          t(ddindx).request_id := a13(indx);
          t(ddindx).program_application_id := a14(indx);
          t(ddindx).program_id := a15(indx);
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a16(indx));
          t(ddindx).attribute_category := a17(indx);
          t(ddindx).attribute1 := a18(indx);
          t(ddindx).attribute2 := a19(indx);
          t(ddindx).attribute3 := a20(indx);
          t(ddindx).attribute4 := a21(indx);
          t(ddindx).attribute5 := a22(indx);
          t(ddindx).attribute6 := a23(indx);
          t(ddindx).attribute7 := a24(indx);
          t(ddindx).attribute8 := a25(indx);
          t(ddindx).attribute9 := a26(indx);
          t(ddindx).attribute10 := a27(indx);
          t(ddindx).attribute11 := a28(indx);
          t(ddindx).attribute12 := a29(indx);
          t(ddindx).attribute13 := a30(indx);
          t(ddindx).attribute14 := a31(indx);
          t(ddindx).attribute15 := a32(indx);
          t(ddindx).security_group_id := a33(indx);
          t(ddindx).object_version_number := a34(indx);
          t(ddindx).process_id := a35(indx);
          t(ddindx).control_count := a36(indx);
          t(ddindx).risk_count := a37(indx);
          t(ddindx).org_count := a38(indx);
          t(ddindx).process_rev_id := a39(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t amw_process_pvt.process_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_200
    , a19 out nocopy JTF_VARCHAR2_TABLE_200
    , a20 out nocopy JTF_VARCHAR2_TABLE_200
    , a21 out nocopy JTF_VARCHAR2_TABLE_200
    , a22 out nocopy JTF_VARCHAR2_TABLE_200
    , a23 out nocopy JTF_VARCHAR2_TABLE_200
    , a24 out nocopy JTF_VARCHAR2_TABLE_200
    , a25 out nocopy JTF_VARCHAR2_TABLE_200
    , a26 out nocopy JTF_VARCHAR2_TABLE_200
    , a27 out nocopy JTF_VARCHAR2_TABLE_200
    , a28 out nocopy JTF_VARCHAR2_TABLE_200
    , a29 out nocopy JTF_VARCHAR2_TABLE_200
    , a30 out nocopy JTF_VARCHAR2_TABLE_200
    , a31 out nocopy JTF_VARCHAR2_TABLE_200
    , a32 out nocopy JTF_VARCHAR2_TABLE_200
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_NUMBER_TABLE
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_DATE_TABLE();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_200();
    a19 := JTF_VARCHAR2_TABLE_200();
    a20 := JTF_VARCHAR2_TABLE_200();
    a21 := JTF_VARCHAR2_TABLE_200();
    a22 := JTF_VARCHAR2_TABLE_200();
    a23 := JTF_VARCHAR2_TABLE_200();
    a24 := JTF_VARCHAR2_TABLE_200();
    a25 := JTF_VARCHAR2_TABLE_200();
    a26 := JTF_VARCHAR2_TABLE_200();
    a27 := JTF_VARCHAR2_TABLE_200();
    a28 := JTF_VARCHAR2_TABLE_200();
    a29 := JTF_VARCHAR2_TABLE_200();
    a30 := JTF_VARCHAR2_TABLE_200();
    a31 := JTF_VARCHAR2_TABLE_200();
    a32 := JTF_VARCHAR2_TABLE_200();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_NUMBER_TABLE();
    a38 := JTF_NUMBER_TABLE();
    a39 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_DATE_TABLE();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_200();
      a19 := JTF_VARCHAR2_TABLE_200();
      a20 := JTF_VARCHAR2_TABLE_200();
      a21 := JTF_VARCHAR2_TABLE_200();
      a22 := JTF_VARCHAR2_TABLE_200();
      a23 := JTF_VARCHAR2_TABLE_200();
      a24 := JTF_VARCHAR2_TABLE_200();
      a25 := JTF_VARCHAR2_TABLE_200();
      a26 := JTF_VARCHAR2_TABLE_200();
      a27 := JTF_VARCHAR2_TABLE_200();
      a28 := JTF_VARCHAR2_TABLE_200();
      a29 := JTF_VARCHAR2_TABLE_200();
      a30 := JTF_VARCHAR2_TABLE_200();
      a31 := JTF_VARCHAR2_TABLE_200();
      a32 := JTF_VARCHAR2_TABLE_200();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_NUMBER_TABLE();
      a38 := JTF_NUMBER_TABLE();
      a39 := JTF_NUMBER_TABLE();
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
        a31.extend(t.count);
        a32.extend(t.count);
        a33.extend(t.count);
        a34.extend(t.count);
        a35.extend(t.count);
        a36.extend(t.count);
        a37.extend(t.count);
        a38.extend(t.count);
        a39.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).significant_process_flag;
          a1(indx) := t(ddindx).standard_process_flag;
          a2(indx) := t(ddindx).approval_status;
          a3(indx) := t(ddindx).certification_status;
          a4(indx) := t(ddindx).process_owner_id;
          a5(indx) := t(ddindx).last_update_date;
          a6(indx) := t(ddindx).last_updated_by;
          a7(indx) := t(ddindx).creation_date;
          a8(indx) := t(ddindx).created_by;
          a9(indx) := t(ddindx).last_update_login;
          a10(indx) := t(ddindx).item_type;
          a11(indx) := t(ddindx).name;
          a12(indx) := t(ddindx).created_from;
          a13(indx) := t(ddindx).request_id;
          a14(indx) := t(ddindx).program_application_id;
          a15(indx) := t(ddindx).program_id;
          a16(indx) := t(ddindx).program_update_date;
          a17(indx) := t(ddindx).attribute_category;
          a18(indx) := t(ddindx).attribute1;
          a19(indx) := t(ddindx).attribute2;
          a20(indx) := t(ddindx).attribute3;
          a21(indx) := t(ddindx).attribute4;
          a22(indx) := t(ddindx).attribute5;
          a23(indx) := t(ddindx).attribute6;
          a24(indx) := t(ddindx).attribute7;
          a25(indx) := t(ddindx).attribute8;
          a26(indx) := t(ddindx).attribute9;
          a27(indx) := t(ddindx).attribute10;
          a28(indx) := t(ddindx).attribute11;
          a29(indx) := t(ddindx).attribute12;
          a30(indx) := t(ddindx).attribute13;
          a31(indx) := t(ddindx).attribute14;
          a32(indx) := t(ddindx).attribute15;
          a33(indx) := t(ddindx).security_group_id;
          a34(indx) := t(ddindx).object_version_number;
          a35(indx) := t(ddindx).process_id;
          a36(indx) := t(ddindx).control_count;
          a37(indx) := t(ddindx).risk_count;
          a38(indx) := t(ddindx).org_count;
          a39(indx) := t(ddindx).process_rev_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure create_process_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  VARCHAR2
    , p7_a1  VARCHAR2
    , p7_a2  VARCHAR2
    , p7_a3  VARCHAR2
    , p7_a4  NUMBER
    , p7_a5  DATE
    , p7_a6  NUMBER
    , p7_a7  DATE
    , p7_a8  NUMBER
    , p7_a9  NUMBER
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  NUMBER
    , p7_a14  NUMBER
    , p7_a15  NUMBER
    , p7_a16  DATE
    , p7_a17  VARCHAR2
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  VARCHAR2
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  NUMBER
    , p7_a34  NUMBER
    , p7_a35  NUMBER
    , p7_a36  NUMBER
    , p7_a37  NUMBER
    , p7_a38  NUMBER
    , p7_a39  NUMBER
    , x_process_id out nocopy  NUMBER
  )

  as
    ddp_process_rec amw_process_pvt.process_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_process_rec.significant_process_flag := p7_a0;
    ddp_process_rec.standard_process_flag := p7_a1;
    ddp_process_rec.approval_status := p7_a2;
    ddp_process_rec.certification_status := p7_a3;
    ddp_process_rec.process_owner_id := p7_a4;
    ddp_process_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a5);
    ddp_process_rec.last_updated_by := p7_a6;
    ddp_process_rec.creation_date := rosetta_g_miss_date_in_map(p7_a7);
    ddp_process_rec.created_by := p7_a8;
    ddp_process_rec.last_update_login := p7_a9;
    ddp_process_rec.item_type := p7_a10;
    ddp_process_rec.name := p7_a11;
    ddp_process_rec.created_from := p7_a12;
    ddp_process_rec.request_id := p7_a13;
    ddp_process_rec.program_application_id := p7_a14;
    ddp_process_rec.program_id := p7_a15;
    ddp_process_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a16);
    ddp_process_rec.attribute_category := p7_a17;
    ddp_process_rec.attribute1 := p7_a18;
    ddp_process_rec.attribute2 := p7_a19;
    ddp_process_rec.attribute3 := p7_a20;
    ddp_process_rec.attribute4 := p7_a21;
    ddp_process_rec.attribute5 := p7_a22;
    ddp_process_rec.attribute6 := p7_a23;
    ddp_process_rec.attribute7 := p7_a24;
    ddp_process_rec.attribute8 := p7_a25;
    ddp_process_rec.attribute9 := p7_a26;
    ddp_process_rec.attribute10 := p7_a27;
    ddp_process_rec.attribute11 := p7_a28;
    ddp_process_rec.attribute12 := p7_a29;
    ddp_process_rec.attribute13 := p7_a30;
    ddp_process_rec.attribute14 := p7_a31;
    ddp_process_rec.attribute15 := p7_a32;
    ddp_process_rec.security_group_id := p7_a33;
    ddp_process_rec.object_version_number := p7_a34;
    ddp_process_rec.process_id := p7_a35;
    ddp_process_rec.control_count := p7_a36;
    ddp_process_rec.risk_count := p7_a37;
    ddp_process_rec.org_count := p7_a38;
    ddp_process_rec.process_rev_id := p7_a39;


    -- here's the delegated call to the old PL/SQL routine
    amw_process_pvt.create_process_rec(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_process_rec,
      x_process_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure create_process(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 JTF_VARCHAR2_TABLE_100
    , p7_a1 JTF_VARCHAR2_TABLE_100
    , p7_a2 JTF_VARCHAR2_TABLE_100
    , p7_a3 JTF_VARCHAR2_TABLE_100
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_DATE_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_DATE_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_NUMBER_TABLE
    , p7_a10 JTF_VARCHAR2_TABLE_100
    , p7_a11 JTF_VARCHAR2_TABLE_100
    , p7_a12 JTF_VARCHAR2_TABLE_100
    , p7_a13 JTF_NUMBER_TABLE
    , p7_a14 JTF_NUMBER_TABLE
    , p7_a15 JTF_NUMBER_TABLE
    , p7_a16 JTF_DATE_TABLE
    , p7_a17 JTF_VARCHAR2_TABLE_100
    , p7_a18 JTF_VARCHAR2_TABLE_200
    , p7_a19 JTF_VARCHAR2_TABLE_200
    , p7_a20 JTF_VARCHAR2_TABLE_200
    , p7_a21 JTF_VARCHAR2_TABLE_200
    , p7_a22 JTF_VARCHAR2_TABLE_200
    , p7_a23 JTF_VARCHAR2_TABLE_200
    , p7_a24 JTF_VARCHAR2_TABLE_200
    , p7_a25 JTF_VARCHAR2_TABLE_200
    , p7_a26 JTF_VARCHAR2_TABLE_200
    , p7_a27 JTF_VARCHAR2_TABLE_200
    , p7_a28 JTF_VARCHAR2_TABLE_200
    , p7_a29 JTF_VARCHAR2_TABLE_200
    , p7_a30 JTF_VARCHAR2_TABLE_200
    , p7_a31 JTF_VARCHAR2_TABLE_200
    , p7_a32 JTF_VARCHAR2_TABLE_200
    , p7_a33 JTF_NUMBER_TABLE
    , p7_a34 JTF_NUMBER_TABLE
    , p7_a35 JTF_NUMBER_TABLE
    , p7_a36 JTF_NUMBER_TABLE
    , p7_a37 JTF_NUMBER_TABLE
    , p7_a38 JTF_NUMBER_TABLE
    , p7_a39 JTF_NUMBER_TABLE
  )

  as
    ddp_process_tbl amw_process_pvt.process_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    amw_process_pvt_w.rosetta_table_copy_in_p3(ddp_process_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      , p7_a8
      , p7_a9
      , p7_a10
      , p7_a11
      , p7_a12
      , p7_a13
      , p7_a14
      , p7_a15
      , p7_a16
      , p7_a17
      , p7_a18
      , p7_a19
      , p7_a20
      , p7_a21
      , p7_a22
      , p7_a23
      , p7_a24
      , p7_a25
      , p7_a26
      , p7_a27
      , p7_a28
      , p7_a29
      , p7_a30
      , p7_a31
      , p7_a32
      , p7_a33
      , p7_a34
      , p7_a35
      , p7_a36
      , p7_a37
      , p7_a38
      , p7_a39
      );

    -- here's the delegated call to the old PL/SQL routine
    amw_process_pvt.create_process(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_process_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure update_process_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  VARCHAR2
    , p7_a1  VARCHAR2
    , p7_a2  VARCHAR2
    , p7_a3  VARCHAR2
    , p7_a4  NUMBER
    , p7_a5  DATE
    , p7_a6  NUMBER
    , p7_a7  DATE
    , p7_a8  NUMBER
    , p7_a9  NUMBER
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  NUMBER
    , p7_a14  NUMBER
    , p7_a15  NUMBER
    , p7_a16  DATE
    , p7_a17  VARCHAR2
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  VARCHAR2
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  NUMBER
    , p7_a34  NUMBER
    , p7_a35  NUMBER
    , p7_a36  NUMBER
    , p7_a37  NUMBER
    , p7_a38  NUMBER
    , p7_a39  NUMBER
    , x_object_version_number out nocopy  NUMBER
  )

  as
    ddp_process_rec amw_process_pvt.process_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_process_rec.significant_process_flag := p7_a0;
    ddp_process_rec.standard_process_flag := p7_a1;
    ddp_process_rec.approval_status := p7_a2;
    ddp_process_rec.certification_status := p7_a3;
    ddp_process_rec.process_owner_id := p7_a4;
    ddp_process_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a5);
    ddp_process_rec.last_updated_by := p7_a6;
    ddp_process_rec.creation_date := rosetta_g_miss_date_in_map(p7_a7);
    ddp_process_rec.created_by := p7_a8;
    ddp_process_rec.last_update_login := p7_a9;
    ddp_process_rec.item_type := p7_a10;
    ddp_process_rec.name := p7_a11;
    ddp_process_rec.created_from := p7_a12;
    ddp_process_rec.request_id := p7_a13;
    ddp_process_rec.program_application_id := p7_a14;
    ddp_process_rec.program_id := p7_a15;
    ddp_process_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a16);
    ddp_process_rec.attribute_category := p7_a17;
    ddp_process_rec.attribute1 := p7_a18;
    ddp_process_rec.attribute2 := p7_a19;
    ddp_process_rec.attribute3 := p7_a20;
    ddp_process_rec.attribute4 := p7_a21;
    ddp_process_rec.attribute5 := p7_a22;
    ddp_process_rec.attribute6 := p7_a23;
    ddp_process_rec.attribute7 := p7_a24;
    ddp_process_rec.attribute8 := p7_a25;
    ddp_process_rec.attribute9 := p7_a26;
    ddp_process_rec.attribute10 := p7_a27;
    ddp_process_rec.attribute11 := p7_a28;
    ddp_process_rec.attribute12 := p7_a29;
    ddp_process_rec.attribute13 := p7_a30;
    ddp_process_rec.attribute14 := p7_a31;
    ddp_process_rec.attribute15 := p7_a32;
    ddp_process_rec.security_group_id := p7_a33;
    ddp_process_rec.object_version_number := p7_a34;
    ddp_process_rec.process_id := p7_a35;
    ddp_process_rec.control_count := p7_a36;
    ddp_process_rec.risk_count := p7_a37;
    ddp_process_rec.org_count := p7_a38;
    ddp_process_rec.process_rev_id := p7_a39;


    -- here's the delegated call to the old PL/SQL routine
    amw_process_pvt.update_process_rec(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_process_rec,
      x_object_version_number);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_process(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 JTF_VARCHAR2_TABLE_100
    , p7_a1 JTF_VARCHAR2_TABLE_100
    , p7_a2 JTF_VARCHAR2_TABLE_100
    , p7_a3 JTF_VARCHAR2_TABLE_100
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_DATE_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_DATE_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_NUMBER_TABLE
    , p7_a10 JTF_VARCHAR2_TABLE_100
    , p7_a11 JTF_VARCHAR2_TABLE_100
    , p7_a12 JTF_VARCHAR2_TABLE_100
    , p7_a13 JTF_NUMBER_TABLE
    , p7_a14 JTF_NUMBER_TABLE
    , p7_a15 JTF_NUMBER_TABLE
    , p7_a16 JTF_DATE_TABLE
    , p7_a17 JTF_VARCHAR2_TABLE_100
    , p7_a18 JTF_VARCHAR2_TABLE_200
    , p7_a19 JTF_VARCHAR2_TABLE_200
    , p7_a20 JTF_VARCHAR2_TABLE_200
    , p7_a21 JTF_VARCHAR2_TABLE_200
    , p7_a22 JTF_VARCHAR2_TABLE_200
    , p7_a23 JTF_VARCHAR2_TABLE_200
    , p7_a24 JTF_VARCHAR2_TABLE_200
    , p7_a25 JTF_VARCHAR2_TABLE_200
    , p7_a26 JTF_VARCHAR2_TABLE_200
    , p7_a27 JTF_VARCHAR2_TABLE_200
    , p7_a28 JTF_VARCHAR2_TABLE_200
    , p7_a29 JTF_VARCHAR2_TABLE_200
    , p7_a30 JTF_VARCHAR2_TABLE_200
    , p7_a31 JTF_VARCHAR2_TABLE_200
    , p7_a32 JTF_VARCHAR2_TABLE_200
    , p7_a33 JTF_NUMBER_TABLE
    , p7_a34 JTF_NUMBER_TABLE
    , p7_a35 JTF_NUMBER_TABLE
    , p7_a36 JTF_NUMBER_TABLE
    , p7_a37 JTF_NUMBER_TABLE
    , p7_a38 JTF_NUMBER_TABLE
    , p7_a39 JTF_NUMBER_TABLE
  )

  as
    ddp_process_tbl amw_process_pvt.process_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    amw_process_pvt_w.rosetta_table_copy_in_p3(ddp_process_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      , p7_a8
      , p7_a9
      , p7_a10
      , p7_a11
      , p7_a12
      , p7_a13
      , p7_a14
      , p7_a15
      , p7_a16
      , p7_a17
      , p7_a18
      , p7_a19
      , p7_a20
      , p7_a21
      , p7_a22
      , p7_a23
      , p7_a24
      , p7_a25
      , p7_a26
      , p7_a27
      , p7_a28
      , p7_a29
      , p7_a30
      , p7_a31
      , p7_a32
      , p7_a33
      , p7_a34
      , p7_a35
      , p7_a36
      , p7_a37
      , p7_a38
      , p7_a39
      );

    -- here's the delegated call to the old PL/SQL routine
    amw_process_pvt.update_process(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_process_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_process(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p3_a0  VARCHAR2
    , p3_a1  VARCHAR2
    , p3_a2  VARCHAR2
    , p3_a3  VARCHAR2
    , p3_a4  NUMBER
    , p3_a5  DATE
    , p3_a6  NUMBER
    , p3_a7  DATE
    , p3_a8  NUMBER
    , p3_a9  NUMBER
    , p3_a10  VARCHAR2
    , p3_a11  VARCHAR2
    , p3_a12  VARCHAR2
    , p3_a13  NUMBER
    , p3_a14  NUMBER
    , p3_a15  NUMBER
    , p3_a16  DATE
    , p3_a17  VARCHAR2
    , p3_a18  VARCHAR2
    , p3_a19  VARCHAR2
    , p3_a20  VARCHAR2
    , p3_a21  VARCHAR2
    , p3_a22  VARCHAR2
    , p3_a23  VARCHAR2
    , p3_a24  VARCHAR2
    , p3_a25  VARCHAR2
    , p3_a26  VARCHAR2
    , p3_a27  VARCHAR2
    , p3_a28  VARCHAR2
    , p3_a29  VARCHAR2
    , p3_a30  VARCHAR2
    , p3_a31  VARCHAR2
    , p3_a32  VARCHAR2
    , p3_a33  NUMBER
    , p3_a34  NUMBER
    , p3_a35  NUMBER
    , p3_a36  NUMBER
    , p3_a37  NUMBER
    , p3_a38  NUMBER
    , p3_a39  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_process_rec amw_process_pvt.process_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_process_rec.significant_process_flag := p3_a0;
    ddp_process_rec.standard_process_flag := p3_a1;
    ddp_process_rec.approval_status := p3_a2;
    ddp_process_rec.certification_status := p3_a3;
    ddp_process_rec.process_owner_id := p3_a4;
    ddp_process_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a5);
    ddp_process_rec.last_updated_by := p3_a6;
    ddp_process_rec.creation_date := rosetta_g_miss_date_in_map(p3_a7);
    ddp_process_rec.created_by := p3_a8;
    ddp_process_rec.last_update_login := p3_a9;
    ddp_process_rec.item_type := p3_a10;
    ddp_process_rec.name := p3_a11;
    ddp_process_rec.created_from := p3_a12;
    ddp_process_rec.request_id := p3_a13;
    ddp_process_rec.program_application_id := p3_a14;
    ddp_process_rec.program_id := p3_a15;
    ddp_process_rec.program_update_date := rosetta_g_miss_date_in_map(p3_a16);
    ddp_process_rec.attribute_category := p3_a17;
    ddp_process_rec.attribute1 := p3_a18;
    ddp_process_rec.attribute2 := p3_a19;
    ddp_process_rec.attribute3 := p3_a20;
    ddp_process_rec.attribute4 := p3_a21;
    ddp_process_rec.attribute5 := p3_a22;
    ddp_process_rec.attribute6 := p3_a23;
    ddp_process_rec.attribute7 := p3_a24;
    ddp_process_rec.attribute8 := p3_a25;
    ddp_process_rec.attribute9 := p3_a26;
    ddp_process_rec.attribute10 := p3_a27;
    ddp_process_rec.attribute11 := p3_a28;
    ddp_process_rec.attribute12 := p3_a29;
    ddp_process_rec.attribute13 := p3_a30;
    ddp_process_rec.attribute14 := p3_a31;
    ddp_process_rec.attribute15 := p3_a32;
    ddp_process_rec.security_group_id := p3_a33;
    ddp_process_rec.object_version_number := p3_a34;
    ddp_process_rec.process_id := p3_a35;
    ddp_process_rec.control_count := p3_a36;
    ddp_process_rec.risk_count := p3_a37;
    ddp_process_rec.org_count := p3_a38;
    ddp_process_rec.process_rev_id := p3_a39;




    -- here's the delegated call to the old PL/SQL routine
    amw_process_pvt.validate_process(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_process_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure check_process_items(p0_a0  VARCHAR2
    , p0_a1  VARCHAR2
    , p0_a2  VARCHAR2
    , p0_a3  VARCHAR2
    , p0_a4  NUMBER
    , p0_a5  DATE
    , p0_a6  NUMBER
    , p0_a7  DATE
    , p0_a8  NUMBER
    , p0_a9  NUMBER
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  NUMBER
    , p0_a14  NUMBER
    , p0_a15  NUMBER
    , p0_a16  DATE
    , p0_a17  VARCHAR2
    , p0_a18  VARCHAR2
    , p0_a19  VARCHAR2
    , p0_a20  VARCHAR2
    , p0_a21  VARCHAR2
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  VARCHAR2
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  VARCHAR2
    , p0_a32  VARCHAR2
    , p0_a33  NUMBER
    , p0_a34  NUMBER
    , p0_a35  NUMBER
    , p0_a36  NUMBER
    , p0_a37  NUMBER
    , p0_a38  NUMBER
    , p0_a39  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_process_rec amw_process_pvt.process_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_process_rec.significant_process_flag := p0_a0;
    ddp_process_rec.standard_process_flag := p0_a1;
    ddp_process_rec.approval_status := p0_a2;
    ddp_process_rec.certification_status := p0_a3;
    ddp_process_rec.process_owner_id := p0_a4;
    ddp_process_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a5);
    ddp_process_rec.last_updated_by := p0_a6;
    ddp_process_rec.creation_date := rosetta_g_miss_date_in_map(p0_a7);
    ddp_process_rec.created_by := p0_a8;
    ddp_process_rec.last_update_login := p0_a9;
    ddp_process_rec.item_type := p0_a10;
    ddp_process_rec.name := p0_a11;
    ddp_process_rec.created_from := p0_a12;
    ddp_process_rec.request_id := p0_a13;
    ddp_process_rec.program_application_id := p0_a14;
    ddp_process_rec.program_id := p0_a15;
    ddp_process_rec.program_update_date := rosetta_g_miss_date_in_map(p0_a16);
    ddp_process_rec.attribute_category := p0_a17;
    ddp_process_rec.attribute1 := p0_a18;
    ddp_process_rec.attribute2 := p0_a19;
    ddp_process_rec.attribute3 := p0_a20;
    ddp_process_rec.attribute4 := p0_a21;
    ddp_process_rec.attribute5 := p0_a22;
    ddp_process_rec.attribute6 := p0_a23;
    ddp_process_rec.attribute7 := p0_a24;
    ddp_process_rec.attribute8 := p0_a25;
    ddp_process_rec.attribute9 := p0_a26;
    ddp_process_rec.attribute10 := p0_a27;
    ddp_process_rec.attribute11 := p0_a28;
    ddp_process_rec.attribute12 := p0_a29;
    ddp_process_rec.attribute13 := p0_a30;
    ddp_process_rec.attribute14 := p0_a31;
    ddp_process_rec.attribute15 := p0_a32;
    ddp_process_rec.security_group_id := p0_a33;
    ddp_process_rec.object_version_number := p0_a34;
    ddp_process_rec.process_id := p0_a35;
    ddp_process_rec.control_count := p0_a36;
    ddp_process_rec.risk_count := p0_a37;
    ddp_process_rec.org_count := p0_a38;
    ddp_process_rec.process_rev_id := p0_a39;



    -- here's the delegated call to the old PL/SQL routine
    amw_process_pvt.check_process_items(ddp_process_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure validate_process_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  VARCHAR2
    , p5_a1  VARCHAR2
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  NUMBER
    , p5_a5  DATE
    , p5_a6  NUMBER
    , p5_a7  DATE
    , p5_a8  NUMBER
    , p5_a9  NUMBER
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  NUMBER
    , p5_a14  NUMBER
    , p5_a15  NUMBER
    , p5_a16  DATE
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  VARCHAR2
    , p5_a22  VARCHAR2
    , p5_a23  VARCHAR2
    , p5_a24  VARCHAR2
    , p5_a25  VARCHAR2
    , p5_a26  VARCHAR2
    , p5_a27  VARCHAR2
    , p5_a28  VARCHAR2
    , p5_a29  VARCHAR2
    , p5_a30  VARCHAR2
    , p5_a31  VARCHAR2
    , p5_a32  VARCHAR2
    , p5_a33  NUMBER
    , p5_a34  NUMBER
    , p5_a35  NUMBER
    , p5_a36  NUMBER
    , p5_a37  NUMBER
    , p5_a38  NUMBER
    , p5_a39  NUMBER
  )

  as
    ddp_process_rec amw_process_pvt.process_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_process_rec.significant_process_flag := p5_a0;
    ddp_process_rec.standard_process_flag := p5_a1;
    ddp_process_rec.approval_status := p5_a2;
    ddp_process_rec.certification_status := p5_a3;
    ddp_process_rec.process_owner_id := p5_a4;
    ddp_process_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_process_rec.last_updated_by := p5_a6;
    ddp_process_rec.creation_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_process_rec.created_by := p5_a8;
    ddp_process_rec.last_update_login := p5_a9;
    ddp_process_rec.item_type := p5_a10;
    ddp_process_rec.name := p5_a11;
    ddp_process_rec.created_from := p5_a12;
    ddp_process_rec.request_id := p5_a13;
    ddp_process_rec.program_application_id := p5_a14;
    ddp_process_rec.program_id := p5_a15;
    ddp_process_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_process_rec.attribute_category := p5_a17;
    ddp_process_rec.attribute1 := p5_a18;
    ddp_process_rec.attribute2 := p5_a19;
    ddp_process_rec.attribute3 := p5_a20;
    ddp_process_rec.attribute4 := p5_a21;
    ddp_process_rec.attribute5 := p5_a22;
    ddp_process_rec.attribute6 := p5_a23;
    ddp_process_rec.attribute7 := p5_a24;
    ddp_process_rec.attribute8 := p5_a25;
    ddp_process_rec.attribute9 := p5_a26;
    ddp_process_rec.attribute10 := p5_a27;
    ddp_process_rec.attribute11 := p5_a28;
    ddp_process_rec.attribute12 := p5_a29;
    ddp_process_rec.attribute13 := p5_a30;
    ddp_process_rec.attribute14 := p5_a31;
    ddp_process_rec.attribute15 := p5_a32;
    ddp_process_rec.security_group_id := p5_a33;
    ddp_process_rec.object_version_number := p5_a34;
    ddp_process_rec.process_id := p5_a35;
    ddp_process_rec.control_count := p5_a36;
    ddp_process_rec.risk_count := p5_a37;
    ddp_process_rec.org_count := p5_a38;
    ddp_process_rec.process_rev_id := p5_a39;

    -- here's the delegated call to the old PL/SQL routine
    amw_process_pvt.validate_process_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_process_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end amw_process_pvt_w;

/
