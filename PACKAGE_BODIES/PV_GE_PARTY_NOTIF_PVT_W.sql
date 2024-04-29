--------------------------------------------------------
--  DDL for Package Body PV_GE_PARTY_NOTIF_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_GE_PARTY_NOTIF_PVT_W" as
  /* $Header: pvxwgpnb.pls 115.4 2002/12/11 12:44:39 rdsharma ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p2(t out nocopy pv_ge_party_notif_pvt.pgp_notif_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).party_notification_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).notification_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).partner_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).recipient_user_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).notif_for_entity_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).arc_notif_for_entity_code := a6(indx);
          t(ddindx).notif_type_code := a7(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a11(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a12(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t pv_ge_party_notif_pvt.pgp_notif_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).party_notification_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).notification_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).partner_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).recipient_user_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).notif_for_entity_id);
          a6(indx) := t(ddindx).arc_notif_for_entity_code;
          a7(indx) := t(ddindx).notif_type_code;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a9(indx) := t(ddindx).creation_date;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a11(indx) := t(ddindx).last_update_date;
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure create_ge_party_notif(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_party_notification_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  DATE := fnd_api.g_miss_date
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  DATE := fnd_api.g_miss_date
    , p7_a12  NUMBER := 0-1962.0724
  )

  as
    ddp_pgp_notif_rec pv_ge_party_notif_pvt.pgp_notif_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_pgp_notif_rec.party_notification_id := rosetta_g_miss_num_map(p7_a0);
    ddp_pgp_notif_rec.notification_id := rosetta_g_miss_num_map(p7_a1);
    ddp_pgp_notif_rec.object_version_number := rosetta_g_miss_num_map(p7_a2);
    ddp_pgp_notif_rec.partner_id := rosetta_g_miss_num_map(p7_a3);
    ddp_pgp_notif_rec.recipient_user_id := rosetta_g_miss_num_map(p7_a4);
    ddp_pgp_notif_rec.notif_for_entity_id := rosetta_g_miss_num_map(p7_a5);
    ddp_pgp_notif_rec.arc_notif_for_entity_code := p7_a6;
    ddp_pgp_notif_rec.notif_type_code := p7_a7;
    ddp_pgp_notif_rec.created_by := rosetta_g_miss_num_map(p7_a8);
    ddp_pgp_notif_rec.creation_date := rosetta_g_miss_date_in_map(p7_a9);
    ddp_pgp_notif_rec.last_updated_by := rosetta_g_miss_num_map(p7_a10);
    ddp_pgp_notif_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a11);
    ddp_pgp_notif_rec.last_update_login := rosetta_g_miss_num_map(p7_a12);


    -- here's the delegated call to the old PL/SQL routine
    pv_ge_party_notif_pvt.create_ge_party_notif(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pgp_notif_rec,
      x_party_notification_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_ge_party_notif(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  DATE := fnd_api.g_miss_date
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  DATE := fnd_api.g_miss_date
    , p7_a12  NUMBER := 0-1962.0724
  )

  as
    ddp_pgp_notif_rec pv_ge_party_notif_pvt.pgp_notif_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_pgp_notif_rec.party_notification_id := rosetta_g_miss_num_map(p7_a0);
    ddp_pgp_notif_rec.notification_id := rosetta_g_miss_num_map(p7_a1);
    ddp_pgp_notif_rec.object_version_number := rosetta_g_miss_num_map(p7_a2);
    ddp_pgp_notif_rec.partner_id := rosetta_g_miss_num_map(p7_a3);
    ddp_pgp_notif_rec.recipient_user_id := rosetta_g_miss_num_map(p7_a4);
    ddp_pgp_notif_rec.notif_for_entity_id := rosetta_g_miss_num_map(p7_a5);
    ddp_pgp_notif_rec.arc_notif_for_entity_code := p7_a6;
    ddp_pgp_notif_rec.notif_type_code := p7_a7;
    ddp_pgp_notif_rec.created_by := rosetta_g_miss_num_map(p7_a8);
    ddp_pgp_notif_rec.creation_date := rosetta_g_miss_date_in_map(p7_a9);
    ddp_pgp_notif_rec.last_updated_by := rosetta_g_miss_num_map(p7_a10);
    ddp_pgp_notif_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a11);
    ddp_pgp_notif_rec.last_update_login := rosetta_g_miss_num_map(p7_a12);

    -- here's the delegated call to the old PL/SQL routine
    pv_ge_party_notif_pvt.update_ge_party_notif(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pgp_notif_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_ge_party_notif(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  NUMBER := 0-1962.0724
    , p3_a2  NUMBER := 0-1962.0724
    , p3_a3  NUMBER := 0-1962.0724
    , p3_a4  NUMBER := 0-1962.0724
    , p3_a5  NUMBER := 0-1962.0724
    , p3_a6  VARCHAR2 := fnd_api.g_miss_char
    , p3_a7  VARCHAR2 := fnd_api.g_miss_char
    , p3_a8  NUMBER := 0-1962.0724
    , p3_a9  DATE := fnd_api.g_miss_date
    , p3_a10  NUMBER := 0-1962.0724
    , p3_a11  DATE := fnd_api.g_miss_date
    , p3_a12  NUMBER := 0-1962.0724
  )

  as
    ddp_pgp_notif_rec pv_ge_party_notif_pvt.pgp_notif_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_pgp_notif_rec.party_notification_id := rosetta_g_miss_num_map(p3_a0);
    ddp_pgp_notif_rec.notification_id := rosetta_g_miss_num_map(p3_a1);
    ddp_pgp_notif_rec.object_version_number := rosetta_g_miss_num_map(p3_a2);
    ddp_pgp_notif_rec.partner_id := rosetta_g_miss_num_map(p3_a3);
    ddp_pgp_notif_rec.recipient_user_id := rosetta_g_miss_num_map(p3_a4);
    ddp_pgp_notif_rec.notif_for_entity_id := rosetta_g_miss_num_map(p3_a5);
    ddp_pgp_notif_rec.arc_notif_for_entity_code := p3_a6;
    ddp_pgp_notif_rec.notif_type_code := p3_a7;
    ddp_pgp_notif_rec.created_by := rosetta_g_miss_num_map(p3_a8);
    ddp_pgp_notif_rec.creation_date := rosetta_g_miss_date_in_map(p3_a9);
    ddp_pgp_notif_rec.last_updated_by := rosetta_g_miss_num_map(p3_a10);
    ddp_pgp_notif_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a11);
    ddp_pgp_notif_rec.last_update_login := rosetta_g_miss_num_map(p3_a12);





    -- here's the delegated call to the old PL/SQL routine
    pv_ge_party_notif_pvt.validate_ge_party_notif(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_pgp_notif_rec,
      p_validation_mode,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure check_pgp_notif_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  NUMBER := 0-1962.0724
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  VARCHAR2 := fnd_api.g_miss_char
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  DATE := fnd_api.g_miss_date
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  DATE := fnd_api.g_miss_date
    , p0_a12  NUMBER := 0-1962.0724
  )

  as
    ddp_pgp_notif_rec pv_ge_party_notif_pvt.pgp_notif_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_pgp_notif_rec.party_notification_id := rosetta_g_miss_num_map(p0_a0);
    ddp_pgp_notif_rec.notification_id := rosetta_g_miss_num_map(p0_a1);
    ddp_pgp_notif_rec.object_version_number := rosetta_g_miss_num_map(p0_a2);
    ddp_pgp_notif_rec.partner_id := rosetta_g_miss_num_map(p0_a3);
    ddp_pgp_notif_rec.recipient_user_id := rosetta_g_miss_num_map(p0_a4);
    ddp_pgp_notif_rec.notif_for_entity_id := rosetta_g_miss_num_map(p0_a5);
    ddp_pgp_notif_rec.arc_notif_for_entity_code := p0_a6;
    ddp_pgp_notif_rec.notif_type_code := p0_a7;
    ddp_pgp_notif_rec.created_by := rosetta_g_miss_num_map(p0_a8);
    ddp_pgp_notif_rec.creation_date := rosetta_g_miss_date_in_map(p0_a9);
    ddp_pgp_notif_rec.last_updated_by := rosetta_g_miss_num_map(p0_a10);
    ddp_pgp_notif_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a11);
    ddp_pgp_notif_rec.last_update_login := rosetta_g_miss_num_map(p0_a12);



    -- here's the delegated call to the old PL/SQL routine
    pv_ge_party_notif_pvt.check_pgp_notif_items(ddp_pgp_notif_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure validate_pgp_notif_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  NUMBER := 0-1962.0724
  )

  as
    ddp_pgp_notif_rec pv_ge_party_notif_pvt.pgp_notif_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_pgp_notif_rec.party_notification_id := rosetta_g_miss_num_map(p5_a0);
    ddp_pgp_notif_rec.notification_id := rosetta_g_miss_num_map(p5_a1);
    ddp_pgp_notif_rec.object_version_number := rosetta_g_miss_num_map(p5_a2);
    ddp_pgp_notif_rec.partner_id := rosetta_g_miss_num_map(p5_a3);
    ddp_pgp_notif_rec.recipient_user_id := rosetta_g_miss_num_map(p5_a4);
    ddp_pgp_notif_rec.notif_for_entity_id := rosetta_g_miss_num_map(p5_a5);
    ddp_pgp_notif_rec.arc_notif_for_entity_code := p5_a6;
    ddp_pgp_notif_rec.notif_type_code := p5_a7;
    ddp_pgp_notif_rec.created_by := rosetta_g_miss_num_map(p5_a8);
    ddp_pgp_notif_rec.creation_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_pgp_notif_rec.last_updated_by := rosetta_g_miss_num_map(p5_a10);
    ddp_pgp_notif_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_pgp_notif_rec.last_update_login := rosetta_g_miss_num_map(p5_a12);

    -- here's the delegated call to the old PL/SQL routine
    pv_ge_party_notif_pvt.validate_pgp_notif_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pgp_notif_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end pv_ge_party_notif_pvt_w;

/
