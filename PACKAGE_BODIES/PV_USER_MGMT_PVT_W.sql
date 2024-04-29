--------------------------------------------------------
--  DDL for Package Body PV_USER_MGMT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_USER_MGMT_PVT_W" as
  /* $Header: pvxwummb.pls 120.7 2006/01/17 13:10 ktsao ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
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

  procedure rosetta_table_copy_in_p5(t out nocopy pv_user_mgmt_pvt.partner_types_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).partner_type := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t pv_user_mgmt_pvt.partner_types_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).partner_type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure register_partner_and_user(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_partner_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  VARCHAR2 := fnd_api.g_miss_char
    , p3_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
  )

  as
    ddp_partner_rec pv_user_mgmt_pvt.partner_rec_type;
    ddp_partner_user_rec pv_user_mgmt_pvt.partner_user_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_partner_rec.partner_party_id := rosetta_g_miss_num_map(p3_a0);
    ddp_partner_rec.member_type := p3_a1;
    ddp_partner_rec.global_prtnr_org_number := p3_a2;


    ddp_partner_user_rec.user_id := rosetta_g_miss_num_map(p5_a0);
    ddp_partner_user_rec.person_rel_party_id := rosetta_g_miss_num_map(p5_a1);
    ddp_partner_user_rec.user_name := p5_a2;
    ddp_partner_user_rec.user_type_id := rosetta_g_miss_num_map(p5_a3);




    -- here's the delegated call to the old PL/SQL routine
    pv_user_mgmt_pvt.register_partner_and_user(p_api_version_number,
      p_init_msg_list,
      p_commit,
      ddp_partner_rec,
      p_partner_type,
      ddp_partner_user_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure register_partner_user(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  NUMBER := 0-1962.0724
    , p3_a2  VARCHAR2 := fnd_api.g_miss_char
    , p3_a3  NUMBER := 0-1962.0724
  )

  as
    ddp_partner_user_rec pv_user_mgmt_pvt.partner_user_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_partner_user_rec.user_id := rosetta_g_miss_num_map(p3_a0);
    ddp_partner_user_rec.person_rel_party_id := rosetta_g_miss_num_map(p3_a1);
    ddp_partner_user_rec.user_name := p3_a2;
    ddp_partner_user_rec.user_type_id := rosetta_g_miss_num_map(p3_a3);




    -- here's the delegated call to the old PL/SQL routine
    pv_user_mgmt_pvt.register_partner_user(p_api_version_number,
      p_init_msg_list,
      p_commit,
      ddp_partner_user_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

end pv_user_mgmt_pvt_w;

/
