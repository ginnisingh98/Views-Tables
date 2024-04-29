--------------------------------------------------------
--  DDL for Package Body OZF_OFFER_BACKDATE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_OFFER_BACKDATE_PVT_W" as
  /* $Header: ozfwobdb.pls 120.0 2005/05/31 23:14:49 appldev noship $ */
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

  procedure rosetta_table_copy_in_p3(t OUT NOCOPY ozf_offer_backdate_pvt.offer_backdate_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_2000
    , a9 JTF_DATE_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).offer_adjustment_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).effective_date := rosetta_g_miss_date_in_map(a1(indx));
          t(ddindx).approved_date := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).settlement_code := a3(indx);
          t(ddindx).status_code := a4(indx);
          t(ddindx).list_header_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).version := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).budget_adjusted_flag := a7(indx);
          t(ddindx).comments := a8(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a11(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).security_group_id := rosetta_g_miss_num_map(a15(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ozf_offer_backdate_pvt.offer_backdate_tbl_type, a0 OUT NOCOPY JTF_NUMBER_TABLE
    , a1 OUT NOCOPY JTF_DATE_TABLE
    , a2 OUT NOCOPY JTF_DATE_TABLE
    , a3 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a4 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a5 OUT NOCOPY JTF_NUMBER_TABLE
    , a6 OUT NOCOPY JTF_NUMBER_TABLE
    , a7 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a8 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , a9 OUT NOCOPY JTF_DATE_TABLE
    , a10 OUT NOCOPY JTF_NUMBER_TABLE
    , a11 OUT NOCOPY JTF_DATE_TABLE
    , a12 OUT NOCOPY JTF_NUMBER_TABLE
    , a13 OUT NOCOPY JTF_NUMBER_TABLE
    , a14 OUT NOCOPY JTF_NUMBER_TABLE
    , a15 OUT NOCOPY JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_DATE_TABLE();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_2000();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_DATE_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_2000();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).offer_adjustment_id);
          a1(indx) := t(ddindx).effective_date;
          a2(indx) := t(ddindx).approved_date;
          a3(indx) := t(ddindx).settlement_code;
          a4(indx) := t(ddindx).status_code;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).list_header_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).version);
          a7(indx) := t(ddindx).budget_adjusted_flag;
          a8(indx) := t(ddindx).comments;
          a9(indx) := t(ddindx).last_update_date;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a11(indx) := t(ddindx).creation_date;
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).security_group_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure create_offer_backdate(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_offer_adjustment_id OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  DATE := fnd_api.g_miss_date
    , p7_a3  VARCHAR2 := fnd_api.g_miss_char
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  DATE := fnd_api.g_miss_date
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  DATE := fnd_api.g_miss_date
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  NUMBER := 0-1962.0724
  )
  as
    ddp_offer_backdate_rec ozf_offer_backdate_pvt.offer_backdate_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_offer_backdate_rec.offer_adjustment_id := rosetta_g_miss_num_map(p7_a0);
    ddp_offer_backdate_rec.effective_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_offer_backdate_rec.approved_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_offer_backdate_rec.settlement_code := p7_a3;
    ddp_offer_backdate_rec.status_code := p7_a4;
    ddp_offer_backdate_rec.list_header_id := rosetta_g_miss_num_map(p7_a5);
    ddp_offer_backdate_rec.version := rosetta_g_miss_num_map(p7_a6);
    ddp_offer_backdate_rec.budget_adjusted_flag := p7_a7;
    ddp_offer_backdate_rec.comments := p7_a8;
    ddp_offer_backdate_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a9);
    ddp_offer_backdate_rec.last_updated_by := rosetta_g_miss_num_map(p7_a10);
    ddp_offer_backdate_rec.creation_date := rosetta_g_miss_date_in_map(p7_a11);
    ddp_offer_backdate_rec.created_by := rosetta_g_miss_num_map(p7_a12);
    ddp_offer_backdate_rec.last_update_login := rosetta_g_miss_num_map(p7_a13);
    ddp_offer_backdate_rec.object_version_number := rosetta_g_miss_num_map(p7_a14);
    ddp_offer_backdate_rec.security_group_id := rosetta_g_miss_num_map(p7_a15);


    -- here's the delegated call to the old PL/SQL routine
    ozf_offer_backdate_pvt.create_offer_backdate(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_offer_backdate_rec,
      x_offer_adjustment_id);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure update_offer_backdate(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_object_version_number OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  DATE := fnd_api.g_miss_date
    , p7_a3  VARCHAR2 := fnd_api.g_miss_char
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  DATE := fnd_api.g_miss_date
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  DATE := fnd_api.g_miss_date
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  NUMBER := 0-1962.0724
  )
  as
    ddp_offer_backdate_rec ozf_offer_backdate_pvt.offer_backdate_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_offer_backdate_rec.offer_adjustment_id := rosetta_g_miss_num_map(p7_a0);
    ddp_offer_backdate_rec.effective_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_offer_backdate_rec.approved_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_offer_backdate_rec.settlement_code := p7_a3;
    ddp_offer_backdate_rec.status_code := p7_a4;
    ddp_offer_backdate_rec.list_header_id := rosetta_g_miss_num_map(p7_a5);
    ddp_offer_backdate_rec.version := rosetta_g_miss_num_map(p7_a6);
    ddp_offer_backdate_rec.budget_adjusted_flag := p7_a7;
    ddp_offer_backdate_rec.comments := p7_a8;
    ddp_offer_backdate_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a9);
    ddp_offer_backdate_rec.last_updated_by := rosetta_g_miss_num_map(p7_a10);
    ddp_offer_backdate_rec.creation_date := rosetta_g_miss_date_in_map(p7_a11);
    ddp_offer_backdate_rec.created_by := rosetta_g_miss_num_map(p7_a12);
    ddp_offer_backdate_rec.last_update_login := rosetta_g_miss_num_map(p7_a13);
    ddp_offer_backdate_rec.object_version_number := rosetta_g_miss_num_map(p7_a14);
    ddp_offer_backdate_rec.security_group_id := rosetta_g_miss_num_map(p7_a15);


    -- here's the delegated call to the old PL/SQL routine
    ozf_offer_backdate_pvt.update_offer_backdate(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_offer_backdate_rec,
      x_object_version_number);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure validate_offer_backdate(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  DATE := fnd_api.g_miss_date
    , p3_a2  DATE := fnd_api.g_miss_date
    , p3_a3  VARCHAR2 := fnd_api.g_miss_char
    , p3_a4  VARCHAR2 := fnd_api.g_miss_char
    , p3_a5  NUMBER := 0-1962.0724
    , p3_a6  NUMBER := 0-1962.0724
    , p3_a7  VARCHAR2 := fnd_api.g_miss_char
    , p3_a8  VARCHAR2 := fnd_api.g_miss_char
    , p3_a9  DATE := fnd_api.g_miss_date
    , p3_a10  NUMBER := 0-1962.0724
    , p3_a11  DATE := fnd_api.g_miss_date
    , p3_a12  NUMBER := 0-1962.0724
    , p3_a13  NUMBER := 0-1962.0724
    , p3_a14  NUMBER := 0-1962.0724
    , p3_a15  NUMBER := 0-1962.0724
  )
  as
    ddp_offer_backdate_rec ozf_offer_backdate_pvt.offer_backdate_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_offer_backdate_rec.offer_adjustment_id := rosetta_g_miss_num_map(p3_a0);
    ddp_offer_backdate_rec.effective_date := rosetta_g_miss_date_in_map(p3_a1);
    ddp_offer_backdate_rec.approved_date := rosetta_g_miss_date_in_map(p3_a2);
    ddp_offer_backdate_rec.settlement_code := p3_a3;
    ddp_offer_backdate_rec.status_code := p3_a4;
    ddp_offer_backdate_rec.list_header_id := rosetta_g_miss_num_map(p3_a5);
    ddp_offer_backdate_rec.version := rosetta_g_miss_num_map(p3_a6);
    ddp_offer_backdate_rec.budget_adjusted_flag := p3_a7;
    ddp_offer_backdate_rec.comments := p3_a8;
    ddp_offer_backdate_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a9);
    ddp_offer_backdate_rec.last_updated_by := rosetta_g_miss_num_map(p3_a10);
    ddp_offer_backdate_rec.creation_date := rosetta_g_miss_date_in_map(p3_a11);
    ddp_offer_backdate_rec.created_by := rosetta_g_miss_num_map(p3_a12);
    ddp_offer_backdate_rec.last_update_login := rosetta_g_miss_num_map(p3_a13);
    ddp_offer_backdate_rec.object_version_number := rosetta_g_miss_num_map(p3_a14);
    ddp_offer_backdate_rec.security_group_id := rosetta_g_miss_num_map(p3_a15);





    -- here's the delegated call to the old PL/SQL routine
    ozf_offer_backdate_pvt.validate_offer_backdate(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_offer_backdate_rec,
      p_validation_mode,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure check_offer_backdate_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  DATE := fnd_api.g_miss_date
    , p0_a3  VARCHAR2 := fnd_api.g_miss_char
    , p0_a4  VARCHAR2 := fnd_api.g_miss_char
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  DATE := fnd_api.g_miss_date
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  DATE := fnd_api.g_miss_date
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  NUMBER := 0-1962.0724
    , p0_a15  NUMBER := 0-1962.0724
  )
  as
    ddp_offer_backdate_rec ozf_offer_backdate_pvt.offer_backdate_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_offer_backdate_rec.offer_adjustment_id := rosetta_g_miss_num_map(p0_a0);
    ddp_offer_backdate_rec.effective_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_offer_backdate_rec.approved_date := rosetta_g_miss_date_in_map(p0_a2);
    ddp_offer_backdate_rec.settlement_code := p0_a3;
    ddp_offer_backdate_rec.status_code := p0_a4;
    ddp_offer_backdate_rec.list_header_id := rosetta_g_miss_num_map(p0_a5);
    ddp_offer_backdate_rec.version := rosetta_g_miss_num_map(p0_a6);
    ddp_offer_backdate_rec.budget_adjusted_flag := p0_a7;
    ddp_offer_backdate_rec.comments := p0_a8;
    ddp_offer_backdate_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a9);
    ddp_offer_backdate_rec.last_updated_by := rosetta_g_miss_num_map(p0_a10);
    ddp_offer_backdate_rec.creation_date := rosetta_g_miss_date_in_map(p0_a11);
    ddp_offer_backdate_rec.created_by := rosetta_g_miss_num_map(p0_a12);
    ddp_offer_backdate_rec.last_update_login := rosetta_g_miss_num_map(p0_a13);
    ddp_offer_backdate_rec.object_version_number := rosetta_g_miss_num_map(p0_a14);
    ddp_offer_backdate_rec.security_group_id := rosetta_g_miss_num_map(p0_a15);



    -- here's the delegated call to the old PL/SQL routine
    ozf_offer_backdate_pvt.check_offer_backdate_items(ddp_offer_backdate_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure validate_offer_backdate_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  DATE := fnd_api.g_miss_date
    , p5_a2  DATE := fnd_api.g_miss_date
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
  )
  as
    ddp_offer_backdate_rec ozf_offer_backdate_pvt.offer_backdate_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_offer_backdate_rec.offer_adjustment_id := rosetta_g_miss_num_map(p5_a0);
    ddp_offer_backdate_rec.effective_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_offer_backdate_rec.approved_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_offer_backdate_rec.settlement_code := p5_a3;
    ddp_offer_backdate_rec.status_code := p5_a4;
    ddp_offer_backdate_rec.list_header_id := rosetta_g_miss_num_map(p5_a5);
    ddp_offer_backdate_rec.version := rosetta_g_miss_num_map(p5_a6);
    ddp_offer_backdate_rec.budget_adjusted_flag := p5_a7;
    ddp_offer_backdate_rec.comments := p5_a8;
    ddp_offer_backdate_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_offer_backdate_rec.last_updated_by := rosetta_g_miss_num_map(p5_a10);
    ddp_offer_backdate_rec.creation_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_offer_backdate_rec.created_by := rosetta_g_miss_num_map(p5_a12);
    ddp_offer_backdate_rec.last_update_login := rosetta_g_miss_num_map(p5_a13);
    ddp_offer_backdate_rec.object_version_number := rosetta_g_miss_num_map(p5_a14);
    ddp_offer_backdate_rec.security_group_id := rosetta_g_miss_num_map(p5_a15);

    -- here's the delegated call to the old PL/SQL routine
    ozf_offer_backdate_pvt.validate_offer_backdate_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_offer_backdate_rec);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

end ozf_offer_backdate_pvt_w;

/
