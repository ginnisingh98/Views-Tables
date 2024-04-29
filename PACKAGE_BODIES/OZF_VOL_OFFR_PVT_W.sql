--------------------------------------------------------
--  DDL for Package Body OZF_VOL_OFFR_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_VOL_OFFR_PVT_W" as
  /* $Header: ozfwvob.pls 120.0 2005/06/01 03:31:48 appldev noship $ */
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

  procedure rosetta_table_copy_in_p2(t OUT NOCOPY ozf_vol_offr_pvt.vol_offr_tier_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).volume_offer_tiers_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).qp_list_header_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).discount_type_code := a2(indx);
          t(ddindx).discount := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).break_type_code := a4(indx);
          t(ddindx).tier_value_from := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).tier_value_to := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).volume_type := a7(indx);
          t(ddindx).active := a8(indx);
          t(ddindx).uom_code := a9(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a10(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t ozf_vol_offr_pvt.vol_offr_tier_tbl_type, a0 OUT NOCOPY JTF_NUMBER_TABLE
    , a1 OUT NOCOPY JTF_NUMBER_TABLE
    , a2 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a3 OUT NOCOPY JTF_NUMBER_TABLE
    , a4 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a5 OUT NOCOPY JTF_NUMBER_TABLE
    , a6 OUT NOCOPY JTF_NUMBER_TABLE
    , a7 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a8 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a9 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a10 OUT NOCOPY JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).volume_offer_tiers_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).qp_list_header_id);
          a2(indx) := t(ddindx).discount_type_code;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).discount);
          a4(indx) := t(ddindx).break_type_code;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).tier_value_from);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).tier_value_to);
          a7(indx) := t(ddindx).volume_type;
          a8(indx) := t(ddindx).active;
          a9(indx) := t(ddindx).uom_code;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure create_vol_offr(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_volume_offer_tiers_id OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  NUMBER := 0-1962.0724
  )
  as
    ddp_vol_offr_tier_rec ozf_vol_offr_pvt.vol_offr_tier_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_vol_offr_tier_rec.volume_offer_tiers_id := rosetta_g_miss_num_map(p7_a0);
    ddp_vol_offr_tier_rec.qp_list_header_id := rosetta_g_miss_num_map(p7_a1);
    ddp_vol_offr_tier_rec.discount_type_code := p7_a2;
    ddp_vol_offr_tier_rec.discount := rosetta_g_miss_num_map(p7_a3);
    ddp_vol_offr_tier_rec.break_type_code := p7_a4;
    ddp_vol_offr_tier_rec.tier_value_from := rosetta_g_miss_num_map(p7_a5);
    ddp_vol_offr_tier_rec.tier_value_to := rosetta_g_miss_num_map(p7_a6);
    ddp_vol_offr_tier_rec.volume_type := p7_a7;
    ddp_vol_offr_tier_rec.active := p7_a8;
    ddp_vol_offr_tier_rec.uom_code := p7_a9;
    ddp_vol_offr_tier_rec.object_version_number := rosetta_g_miss_num_map(p7_a10);


    -- here's the delegated call to the old PL/SQL routine
    ozf_vol_offr_pvt.create_vol_offr(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_vol_offr_tier_rec,
      x_volume_offer_tiers_id);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure update_vol_offr(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_object_version_number OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  NUMBER := 0-1962.0724
  )
  as
    ddp_vol_offr_tier_rec ozf_vol_offr_pvt.vol_offr_tier_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_vol_offr_tier_rec.volume_offer_tiers_id := rosetta_g_miss_num_map(p7_a0);
    ddp_vol_offr_tier_rec.qp_list_header_id := rosetta_g_miss_num_map(p7_a1);
    ddp_vol_offr_tier_rec.discount_type_code := p7_a2;
    ddp_vol_offr_tier_rec.discount := rosetta_g_miss_num_map(p7_a3);
    ddp_vol_offr_tier_rec.break_type_code := p7_a4;
    ddp_vol_offr_tier_rec.tier_value_from := rosetta_g_miss_num_map(p7_a5);
    ddp_vol_offr_tier_rec.tier_value_to := rosetta_g_miss_num_map(p7_a6);
    ddp_vol_offr_tier_rec.volume_type := p7_a7;
    ddp_vol_offr_tier_rec.active := p7_a8;
    ddp_vol_offr_tier_rec.uom_code := p7_a9;
    ddp_vol_offr_tier_rec.object_version_number := rosetta_g_miss_num_map(p7_a10);


    -- here's the delegated call to the old PL/SQL routine
    ozf_vol_offr_pvt.update_vol_offr(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_vol_offr_tier_rec,
      x_object_version_number);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure validate_vol_offr(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  NUMBER := 0-1962.0724
    , p3_a2  VARCHAR2 := fnd_api.g_miss_char
    , p3_a3  NUMBER := 0-1962.0724
    , p3_a4  VARCHAR2 := fnd_api.g_miss_char
    , p3_a5  NUMBER := 0-1962.0724
    , p3_a6  NUMBER := 0-1962.0724
    , p3_a7  VARCHAR2 := fnd_api.g_miss_char
    , p3_a8  VARCHAR2 := fnd_api.g_miss_char
    , p3_a9  VARCHAR2 := fnd_api.g_miss_char
    , p3_a10  NUMBER := 0-1962.0724
  )
  as
    ddp_vol_offr_tier_rec ozf_vol_offr_pvt.vol_offr_tier_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_vol_offr_tier_rec.volume_offer_tiers_id := rosetta_g_miss_num_map(p3_a0);
    ddp_vol_offr_tier_rec.qp_list_header_id := rosetta_g_miss_num_map(p3_a1);
    ddp_vol_offr_tier_rec.discount_type_code := p3_a2;
    ddp_vol_offr_tier_rec.discount := rosetta_g_miss_num_map(p3_a3);
    ddp_vol_offr_tier_rec.break_type_code := p3_a4;
    ddp_vol_offr_tier_rec.tier_value_from := rosetta_g_miss_num_map(p3_a5);
    ddp_vol_offr_tier_rec.tier_value_to := rosetta_g_miss_num_map(p3_a6);
    ddp_vol_offr_tier_rec.volume_type := p3_a7;
    ddp_vol_offr_tier_rec.active := p3_a8;
    ddp_vol_offr_tier_rec.uom_code := p3_a9;
    ddp_vol_offr_tier_rec.object_version_number := rosetta_g_miss_num_map(p3_a10);





    -- here's the delegated call to the old PL/SQL routine
    ozf_vol_offr_pvt.validate_vol_offr(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_vol_offr_tier_rec,
      p_validation_mode,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure check_vol_offr_tier_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  VARCHAR2 := fnd_api.g_miss_char
    , p0_a3  NUMBER := 0-1962.0724
    , p0_a4  VARCHAR2 := fnd_api.g_miss_char
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  NUMBER := 0-1962.0724
  )
  as
    ddp_vol_offr_tier_rec ozf_vol_offr_pvt.vol_offr_tier_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_vol_offr_tier_rec.volume_offer_tiers_id := rosetta_g_miss_num_map(p0_a0);
    ddp_vol_offr_tier_rec.qp_list_header_id := rosetta_g_miss_num_map(p0_a1);
    ddp_vol_offr_tier_rec.discount_type_code := p0_a2;
    ddp_vol_offr_tier_rec.discount := rosetta_g_miss_num_map(p0_a3);
    ddp_vol_offr_tier_rec.break_type_code := p0_a4;
    ddp_vol_offr_tier_rec.tier_value_from := rosetta_g_miss_num_map(p0_a5);
    ddp_vol_offr_tier_rec.tier_value_to := rosetta_g_miss_num_map(p0_a6);
    ddp_vol_offr_tier_rec.volume_type := p0_a7;
    ddp_vol_offr_tier_rec.active := p0_a8;
    ddp_vol_offr_tier_rec.uom_code := p0_a9;
    ddp_vol_offr_tier_rec.object_version_number := rosetta_g_miss_num_map(p0_a10);



    -- here's the delegated call to the old PL/SQL routine
    ozf_vol_offr_pvt.check_vol_offr_tier_items(ddp_vol_offr_tier_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure validate_vol_offr_tier_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  NUMBER := 0-1962.0724
  )
  as
    ddp_vol_offr_tier_rec ozf_vol_offr_pvt.vol_offr_tier_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_vol_offr_tier_rec.volume_offer_tiers_id := rosetta_g_miss_num_map(p5_a0);
    ddp_vol_offr_tier_rec.qp_list_header_id := rosetta_g_miss_num_map(p5_a1);
    ddp_vol_offr_tier_rec.discount_type_code := p5_a2;
    ddp_vol_offr_tier_rec.discount := rosetta_g_miss_num_map(p5_a3);
    ddp_vol_offr_tier_rec.break_type_code := p5_a4;
    ddp_vol_offr_tier_rec.tier_value_from := rosetta_g_miss_num_map(p5_a5);
    ddp_vol_offr_tier_rec.tier_value_to := rosetta_g_miss_num_map(p5_a6);
    ddp_vol_offr_tier_rec.volume_type := p5_a7;
    ddp_vol_offr_tier_rec.active := p5_a8;
    ddp_vol_offr_tier_rec.uom_code := p5_a9;
    ddp_vol_offr_tier_rec.object_version_number := rosetta_g_miss_num_map(p5_a10);

    -- here's the delegated call to the old PL/SQL routine
    ozf_vol_offr_pvt.validate_vol_offr_tier_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_vol_offr_tier_rec);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

end ozf_vol_offr_pvt_w;

/
