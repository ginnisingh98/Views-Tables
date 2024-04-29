--------------------------------------------------------
--  DDL for Package Body PV_PG_MEMBERSHIPS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PG_MEMBERSHIPS_PVT_W" as
  /* $Header: pvxwmemb.pls 120.1 2005/10/24 09:37 dgottlie noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p2(t out nocopy pv_pg_memberships_pvt.memb_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_DATE_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_300
    , a16 JTF_VARCHAR2_TABLE_300
    , a17 JTF_VARCHAR2_TABLE_300
    , a18 JTF_VARCHAR2_TABLE_300
    , a19 JTF_VARCHAR2_TABLE_300
    , a20 JTF_VARCHAR2_TABLE_300
    , a21 JTF_VARCHAR2_TABLE_300
    , a22 JTF_VARCHAR2_TABLE_300
    , a23 JTF_VARCHAR2_TABLE_300
    , a24 JTF_VARCHAR2_TABLE_300
    , a25 JTF_VARCHAR2_TABLE_300
    , a26 JTF_VARCHAR2_TABLE_300
    , a27 JTF_VARCHAR2_TABLE_300
    , a28 JTF_VARCHAR2_TABLE_300
    , a29 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).membership_id := a0(indx);
          t(ddindx).object_version_number := a1(indx);
          t(ddindx).partner_id := a2(indx);
          t(ddindx).program_id := a3(indx);
          t(ddindx).start_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).original_end_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).actual_end_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).membership_status_code := a7(indx);
          t(ddindx).status_reason_code := a8(indx);
          t(ddindx).enrl_request_id := a9(indx);
          t(ddindx).created_by := a10(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a11(indx));
          t(ddindx).last_updated_by := a12(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a13(indx));
          t(ddindx).last_update_login := a14(indx);
          t(ddindx).attribute1 := a15(indx);
          t(ddindx).attribute2 := a16(indx);
          t(ddindx).attribute3 := a17(indx);
          t(ddindx).attribute4 := a18(indx);
          t(ddindx).attribute5 := a19(indx);
          t(ddindx).attribute6 := a20(indx);
          t(ddindx).attribute7 := a21(indx);
          t(ddindx).attribute8 := a22(indx);
          t(ddindx).attribute9 := a23(indx);
          t(ddindx).attribute10 := a24(indx);
          t(ddindx).attribute11 := a25(indx);
          t(ddindx).attribute12 := a26(indx);
          t(ddindx).attribute13 := a27(indx);
          t(ddindx).attribute14 := a28(indx);
          t(ddindx).attribute15 := a29(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t pv_pg_memberships_pvt.memb_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_300
    , a16 out nocopy JTF_VARCHAR2_TABLE_300
    , a17 out nocopy JTF_VARCHAR2_TABLE_300
    , a18 out nocopy JTF_VARCHAR2_TABLE_300
    , a19 out nocopy JTF_VARCHAR2_TABLE_300
    , a20 out nocopy JTF_VARCHAR2_TABLE_300
    , a21 out nocopy JTF_VARCHAR2_TABLE_300
    , a22 out nocopy JTF_VARCHAR2_TABLE_300
    , a23 out nocopy JTF_VARCHAR2_TABLE_300
    , a24 out nocopy JTF_VARCHAR2_TABLE_300
    , a25 out nocopy JTF_VARCHAR2_TABLE_300
    , a26 out nocopy JTF_VARCHAR2_TABLE_300
    , a27 out nocopy JTF_VARCHAR2_TABLE_300
    , a28 out nocopy JTF_VARCHAR2_TABLE_300
    , a29 out nocopy JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_DATE_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_VARCHAR2_TABLE_300();
    a16 := JTF_VARCHAR2_TABLE_300();
    a17 := JTF_VARCHAR2_TABLE_300();
    a18 := JTF_VARCHAR2_TABLE_300();
    a19 := JTF_VARCHAR2_TABLE_300();
    a20 := JTF_VARCHAR2_TABLE_300();
    a21 := JTF_VARCHAR2_TABLE_300();
    a22 := JTF_VARCHAR2_TABLE_300();
    a23 := JTF_VARCHAR2_TABLE_300();
    a24 := JTF_VARCHAR2_TABLE_300();
    a25 := JTF_VARCHAR2_TABLE_300();
    a26 := JTF_VARCHAR2_TABLE_300();
    a27 := JTF_VARCHAR2_TABLE_300();
    a28 := JTF_VARCHAR2_TABLE_300();
    a29 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_DATE_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_VARCHAR2_TABLE_300();
      a16 := JTF_VARCHAR2_TABLE_300();
      a17 := JTF_VARCHAR2_TABLE_300();
      a18 := JTF_VARCHAR2_TABLE_300();
      a19 := JTF_VARCHAR2_TABLE_300();
      a20 := JTF_VARCHAR2_TABLE_300();
      a21 := JTF_VARCHAR2_TABLE_300();
      a22 := JTF_VARCHAR2_TABLE_300();
      a23 := JTF_VARCHAR2_TABLE_300();
      a24 := JTF_VARCHAR2_TABLE_300();
      a25 := JTF_VARCHAR2_TABLE_300();
      a26 := JTF_VARCHAR2_TABLE_300();
      a27 := JTF_VARCHAR2_TABLE_300();
      a28 := JTF_VARCHAR2_TABLE_300();
      a29 := JTF_VARCHAR2_TABLE_300();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).membership_id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).partner_id;
          a3(indx) := t(ddindx).program_id;
          a4(indx) := t(ddindx).start_date;
          a5(indx) := t(ddindx).original_end_date;
          a6(indx) := t(ddindx).actual_end_date;
          a7(indx) := t(ddindx).membership_status_code;
          a8(indx) := t(ddindx).status_reason_code;
          a9(indx) := t(ddindx).enrl_request_id;
          a10(indx) := t(ddindx).created_by;
          a11(indx) := t(ddindx).creation_date;
          a12(indx) := t(ddindx).last_updated_by;
          a13(indx) := t(ddindx).last_update_date;
          a14(indx) := t(ddindx).last_update_login;
          a15(indx) := t(ddindx).attribute1;
          a16(indx) := t(ddindx).attribute2;
          a17(indx) := t(ddindx).attribute3;
          a18(indx) := t(ddindx).attribute4;
          a19(indx) := t(ddindx).attribute5;
          a20(indx) := t(ddindx).attribute6;
          a21(indx) := t(ddindx).attribute7;
          a22(indx) := t(ddindx).attribute8;
          a23(indx) := t(ddindx).attribute9;
          a24(indx) := t(ddindx).attribute10;
          a25(indx) := t(ddindx).attribute11;
          a26(indx) := t(ddindx).attribute12;
          a27(indx) := t(ddindx).attribute13;
          a28(indx) := t(ddindx).attribute14;
          a29(indx) := t(ddindx).attribute15;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p4(t out nocopy pv_pg_memberships_pvt.number_table, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is null then
    t := null;
  elsif a0.count = 0 then
    t := pv_pg_memberships_pvt.number_table();
  else
      if a0.count > 0 then
      t := pv_pg_memberships_pvt.number_table();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t pv_pg_memberships_pvt.number_table, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
  elsif t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure create_pg_memberships(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  NUMBER
    , p7_a3  NUMBER
    , p7_a4  DATE
    , p7_a5  DATE
    , p7_a6  DATE
    , p7_a7  VARCHAR2
    , p7_a8  VARCHAR2
    , p7_a9  NUMBER
    , p7_a10  NUMBER
    , p7_a11  DATE
    , p7_a12  NUMBER
    , p7_a13  DATE
    , p7_a14  NUMBER
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
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
    , x_membership_id out nocopy  NUMBER
  )

  as
    ddp_memb_rec pv_pg_memberships_pvt.memb_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_memb_rec.membership_id := p7_a0;
    ddp_memb_rec.object_version_number := p7_a1;
    ddp_memb_rec.partner_id := p7_a2;
    ddp_memb_rec.program_id := p7_a3;
    ddp_memb_rec.start_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_memb_rec.original_end_date := rosetta_g_miss_date_in_map(p7_a5);
    ddp_memb_rec.actual_end_date := rosetta_g_miss_date_in_map(p7_a6);
    ddp_memb_rec.membership_status_code := p7_a7;
    ddp_memb_rec.status_reason_code := p7_a8;
    ddp_memb_rec.enrl_request_id := p7_a9;
    ddp_memb_rec.created_by := p7_a10;
    ddp_memb_rec.creation_date := rosetta_g_miss_date_in_map(p7_a11);
    ddp_memb_rec.last_updated_by := p7_a12;
    ddp_memb_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a13);
    ddp_memb_rec.last_update_login := p7_a14;
    ddp_memb_rec.attribute1 := p7_a15;
    ddp_memb_rec.attribute2 := p7_a16;
    ddp_memb_rec.attribute3 := p7_a17;
    ddp_memb_rec.attribute4 := p7_a18;
    ddp_memb_rec.attribute5 := p7_a19;
    ddp_memb_rec.attribute6 := p7_a20;
    ddp_memb_rec.attribute7 := p7_a21;
    ddp_memb_rec.attribute8 := p7_a22;
    ddp_memb_rec.attribute9 := p7_a23;
    ddp_memb_rec.attribute10 := p7_a24;
    ddp_memb_rec.attribute11 := p7_a25;
    ddp_memb_rec.attribute12 := p7_a26;
    ddp_memb_rec.attribute13 := p7_a27;
    ddp_memb_rec.attribute14 := p7_a28;
    ddp_memb_rec.attribute15 := p7_a29;


    -- here's the delegated call to the old PL/SQL routine
    pv_pg_memberships_pvt.create_pg_memberships(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_memb_rec,
      x_membership_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_pg_memberships(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  NUMBER
    , p7_a3  NUMBER
    , p7_a4  DATE
    , p7_a5  DATE
    , p7_a6  DATE
    , p7_a7  VARCHAR2
    , p7_a8  VARCHAR2
    , p7_a9  NUMBER
    , p7_a10  NUMBER
    , p7_a11  DATE
    , p7_a12  NUMBER
    , p7_a13  DATE
    , p7_a14  NUMBER
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
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
  )

  as
    ddp_memb_rec pv_pg_memberships_pvt.memb_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_memb_rec.membership_id := p7_a0;
    ddp_memb_rec.object_version_number := p7_a1;
    ddp_memb_rec.partner_id := p7_a2;
    ddp_memb_rec.program_id := p7_a3;
    ddp_memb_rec.start_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_memb_rec.original_end_date := rosetta_g_miss_date_in_map(p7_a5);
    ddp_memb_rec.actual_end_date := rosetta_g_miss_date_in_map(p7_a6);
    ddp_memb_rec.membership_status_code := p7_a7;
    ddp_memb_rec.status_reason_code := p7_a8;
    ddp_memb_rec.enrl_request_id := p7_a9;
    ddp_memb_rec.created_by := p7_a10;
    ddp_memb_rec.creation_date := rosetta_g_miss_date_in_map(p7_a11);
    ddp_memb_rec.last_updated_by := p7_a12;
    ddp_memb_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a13);
    ddp_memb_rec.last_update_login := p7_a14;
    ddp_memb_rec.attribute1 := p7_a15;
    ddp_memb_rec.attribute2 := p7_a16;
    ddp_memb_rec.attribute3 := p7_a17;
    ddp_memb_rec.attribute4 := p7_a18;
    ddp_memb_rec.attribute5 := p7_a19;
    ddp_memb_rec.attribute6 := p7_a20;
    ddp_memb_rec.attribute7 := p7_a21;
    ddp_memb_rec.attribute8 := p7_a22;
    ddp_memb_rec.attribute9 := p7_a23;
    ddp_memb_rec.attribute10 := p7_a24;
    ddp_memb_rec.attribute11 := p7_a25;
    ddp_memb_rec.attribute12 := p7_a26;
    ddp_memb_rec.attribute13 := p7_a27;
    ddp_memb_rec.attribute14 := p7_a28;
    ddp_memb_rec.attribute15 := p7_a29;

    -- here's the delegated call to the old PL/SQL routine
    pv_pg_memberships_pvt.update_pg_memberships(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_memb_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_pg_memberships(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p3_a0  NUMBER
    , p3_a1  NUMBER
    , p3_a2  NUMBER
    , p3_a3  NUMBER
    , p3_a4  DATE
    , p3_a5  DATE
    , p3_a6  DATE
    , p3_a7  VARCHAR2
    , p3_a8  VARCHAR2
    , p3_a9  NUMBER
    , p3_a10  NUMBER
    , p3_a11  DATE
    , p3_a12  NUMBER
    , p3_a13  DATE
    , p3_a14  NUMBER
    , p3_a15  VARCHAR2
    , p3_a16  VARCHAR2
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
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_memb_rec pv_pg_memberships_pvt.memb_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_memb_rec.membership_id := p3_a0;
    ddp_memb_rec.object_version_number := p3_a1;
    ddp_memb_rec.partner_id := p3_a2;
    ddp_memb_rec.program_id := p3_a3;
    ddp_memb_rec.start_date := rosetta_g_miss_date_in_map(p3_a4);
    ddp_memb_rec.original_end_date := rosetta_g_miss_date_in_map(p3_a5);
    ddp_memb_rec.actual_end_date := rosetta_g_miss_date_in_map(p3_a6);
    ddp_memb_rec.membership_status_code := p3_a7;
    ddp_memb_rec.status_reason_code := p3_a8;
    ddp_memb_rec.enrl_request_id := p3_a9;
    ddp_memb_rec.created_by := p3_a10;
    ddp_memb_rec.creation_date := rosetta_g_miss_date_in_map(p3_a11);
    ddp_memb_rec.last_updated_by := p3_a12;
    ddp_memb_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a13);
    ddp_memb_rec.last_update_login := p3_a14;
    ddp_memb_rec.attribute1 := p3_a15;
    ddp_memb_rec.attribute2 := p3_a16;
    ddp_memb_rec.attribute3 := p3_a17;
    ddp_memb_rec.attribute4 := p3_a18;
    ddp_memb_rec.attribute5 := p3_a19;
    ddp_memb_rec.attribute6 := p3_a20;
    ddp_memb_rec.attribute7 := p3_a21;
    ddp_memb_rec.attribute8 := p3_a22;
    ddp_memb_rec.attribute9 := p3_a23;
    ddp_memb_rec.attribute10 := p3_a24;
    ddp_memb_rec.attribute11 := p3_a25;
    ddp_memb_rec.attribute12 := p3_a26;
    ddp_memb_rec.attribute13 := p3_a27;
    ddp_memb_rec.attribute14 := p3_a28;
    ddp_memb_rec.attribute15 := p3_a29;





    -- here's the delegated call to the old PL/SQL routine
    pv_pg_memberships_pvt.validate_pg_memberships(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_memb_rec,
      p_validation_mode,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure check_memb_items(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  NUMBER
    , p0_a3  NUMBER
    , p0_a4  DATE
    , p0_a5  DATE
    , p0_a6  DATE
    , p0_a7  VARCHAR2
    , p0_a8  VARCHAR2
    , p0_a9  NUMBER
    , p0_a10  NUMBER
    , p0_a11  DATE
    , p0_a12  NUMBER
    , p0_a13  DATE
    , p0_a14  NUMBER
    , p0_a15  VARCHAR2
    , p0_a16  VARCHAR2
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
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_memb_rec pv_pg_memberships_pvt.memb_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_memb_rec.membership_id := p0_a0;
    ddp_memb_rec.object_version_number := p0_a1;
    ddp_memb_rec.partner_id := p0_a2;
    ddp_memb_rec.program_id := p0_a3;
    ddp_memb_rec.start_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_memb_rec.original_end_date := rosetta_g_miss_date_in_map(p0_a5);
    ddp_memb_rec.actual_end_date := rosetta_g_miss_date_in_map(p0_a6);
    ddp_memb_rec.membership_status_code := p0_a7;
    ddp_memb_rec.status_reason_code := p0_a8;
    ddp_memb_rec.enrl_request_id := p0_a9;
    ddp_memb_rec.created_by := p0_a10;
    ddp_memb_rec.creation_date := rosetta_g_miss_date_in_map(p0_a11);
    ddp_memb_rec.last_updated_by := p0_a12;
    ddp_memb_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a13);
    ddp_memb_rec.last_update_login := p0_a14;
    ddp_memb_rec.attribute1 := p0_a15;
    ddp_memb_rec.attribute2 := p0_a16;
    ddp_memb_rec.attribute3 := p0_a17;
    ddp_memb_rec.attribute4 := p0_a18;
    ddp_memb_rec.attribute5 := p0_a19;
    ddp_memb_rec.attribute6 := p0_a20;
    ddp_memb_rec.attribute7 := p0_a21;
    ddp_memb_rec.attribute8 := p0_a22;
    ddp_memb_rec.attribute9 := p0_a23;
    ddp_memb_rec.attribute10 := p0_a24;
    ddp_memb_rec.attribute11 := p0_a25;
    ddp_memb_rec.attribute12 := p0_a26;
    ddp_memb_rec.attribute13 := p0_a27;
    ddp_memb_rec.attribute14 := p0_a28;
    ddp_memb_rec.attribute15 := p0_a29;



    -- here's the delegated call to the old PL/SQL routine
    pv_pg_memberships_pvt.check_memb_items(ddp_memb_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure validate_memb_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  NUMBER
    , p5_a4  DATE
    , p5_a5  DATE
    , p5_a6  DATE
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  NUMBER
    , p5_a10  NUMBER
    , p5_a11  DATE
    , p5_a12  NUMBER
    , p5_a13  DATE
    , p5_a14  NUMBER
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
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
  )

  as
    ddp_memb_rec pv_pg_memberships_pvt.memb_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_memb_rec.membership_id := p5_a0;
    ddp_memb_rec.object_version_number := p5_a1;
    ddp_memb_rec.partner_id := p5_a2;
    ddp_memb_rec.program_id := p5_a3;
    ddp_memb_rec.start_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_memb_rec.original_end_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_memb_rec.actual_end_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_memb_rec.membership_status_code := p5_a7;
    ddp_memb_rec.status_reason_code := p5_a8;
    ddp_memb_rec.enrl_request_id := p5_a9;
    ddp_memb_rec.created_by := p5_a10;
    ddp_memb_rec.creation_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_memb_rec.last_updated_by := p5_a12;
    ddp_memb_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a13);
    ddp_memb_rec.last_update_login := p5_a14;
    ddp_memb_rec.attribute1 := p5_a15;
    ddp_memb_rec.attribute2 := p5_a16;
    ddp_memb_rec.attribute3 := p5_a17;
    ddp_memb_rec.attribute4 := p5_a18;
    ddp_memb_rec.attribute5 := p5_a19;
    ddp_memb_rec.attribute6 := p5_a20;
    ddp_memb_rec.attribute7 := p5_a21;
    ddp_memb_rec.attribute8 := p5_a22;
    ddp_memb_rec.attribute9 := p5_a23;
    ddp_memb_rec.attribute10 := p5_a24;
    ddp_memb_rec.attribute11 := p5_a25;
    ddp_memb_rec.attribute12 := p5_a26;
    ddp_memb_rec.attribute13 := p5_a27;
    ddp_memb_rec.attribute14 := p5_a28;
    ddp_memb_rec.attribute15 := p5_a29;

    -- here's the delegated call to the old PL/SQL routine
    pv_pg_memberships_pvt.validate_memb_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_memb_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_membership_end_date(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_membership_id  NUMBER
    , p_new_date  date
    , p_comments  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_new_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_new_date := rosetta_g_miss_date_in_map(p_new_date);





    -- here's the delegated call to the old PL/SQL routine
    pv_pg_memberships_pvt.update_membership_end_date(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_membership_id,
      ddp_new_date,
      p_comments,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

end pv_pg_memberships_pvt_w;

/
