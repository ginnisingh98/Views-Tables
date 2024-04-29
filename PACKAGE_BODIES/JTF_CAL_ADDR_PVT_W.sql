--------------------------------------------------------
--  DDL for Package Body JTF_CAL_ADDR_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_CAL_ADDR_PVT_W" AS
/* $Header: jtfwcab.pls 115.2 2002/04/09 10:57:48 pkm ship      $ */

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

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  NUMBER
    , p7_a3  DATE
    , p7_a4  NUMBER
    , p7_a5  DATE
    , p7_a6  NUMBER
    , p7_a7  VARCHAR2
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  VARCHAR2
    , p7_a11  NUMBER
    , p7_a12  VARCHAR2
    , p7_a13  VARCHAR2
    , p7_a14  VARCHAR2
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
    , p7_a25  NUMBER
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  DATE
    , p7_a38  NUMBER
    , p7_a39  NUMBER
    , p7_a40  NUMBER
    , x_address_id out  NUMBER
  )
  as
    ddp_adr_rec jtf_cal_addr_pvt.addrrec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_adr_rec.address_id := p7_a0;
    ddp_adr_rec.resource_id := p7_a1;
    ddp_adr_rec.created_by := p7_a2;
    ddp_adr_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_adr_rec.last_updated_by := p7_a4;
    ddp_adr_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a5);
    ddp_adr_rec.last_update_login := p7_a6;
    ddp_adr_rec.last_name := p7_a7;
    ddp_adr_rec.first_name := p7_a8;
    ddp_adr_rec.job_title := p7_a9;
    ddp_adr_rec.company := p7_a10;
    ddp_adr_rec.primary_contact := p7_a11;
    ddp_adr_rec.contact1_type := p7_a12;
    ddp_adr_rec.contact1 := p7_a13;
    ddp_adr_rec.contact2_type := p7_a14;
    ddp_adr_rec.contact2 := p7_a15;
    ddp_adr_rec.contact3_type := p7_a16;
    ddp_adr_rec.contact3 := p7_a17;
    ddp_adr_rec.contact4_type := p7_a18;
    ddp_adr_rec.contact4 := p7_a19;
    ddp_adr_rec.contact5_type := p7_a20;
    ddp_adr_rec.contact5 := p7_a21;
    ddp_adr_rec.www_address := p7_a22;
    ddp_adr_rec.assistant_name := p7_a23;
    ddp_adr_rec.assistant_phone := p7_a24;
    ddp_adr_rec.category := p7_a25;
    ddp_adr_rec.address1 := p7_a26;
    ddp_adr_rec.address2 := p7_a27;
    ddp_adr_rec.address3 := p7_a28;
    ddp_adr_rec.address4 := p7_a29;
    ddp_adr_rec.city := p7_a30;
    ddp_adr_rec.county := p7_a31;
    ddp_adr_rec.state := p7_a32;
    ddp_adr_rec.zip := p7_a33;
    ddp_adr_rec.country := p7_a34;
    ddp_adr_rec.note := p7_a35;
    ddp_adr_rec.private_flag := p7_a36;
    ddp_adr_rec.deleted_as_of := rosetta_g_miss_date_in_map(p7_a37);
    ddp_adr_rec.application_id := p7_a38;
    ddp_adr_rec.security_group_id := p7_a39;
    ddp_adr_rec.object_version_number := p7_a40;


    -- here's the delegated call to the old PL/SQL routine
    jtf_cal_addr_pvt.insert_row(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_adr_rec,
      x_address_id);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  NUMBER
    , p7_a3  DATE
    , p7_a4  NUMBER
    , p7_a5  DATE
    , p7_a6  NUMBER
    , p7_a7  VARCHAR2
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  VARCHAR2
    , p7_a11  NUMBER
    , p7_a12  VARCHAR2
    , p7_a13  VARCHAR2
    , p7_a14  VARCHAR2
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
    , p7_a25  NUMBER
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  DATE
    , p7_a38  NUMBER
    , p7_a39  NUMBER
    , p7_a40  NUMBER
    , x_object_version_number out  NUMBER
  )
  as
    ddp_adr_rec jtf_cal_addr_pvt.addrrec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_adr_rec.address_id := p7_a0;
    ddp_adr_rec.resource_id := p7_a1;
    ddp_adr_rec.created_by := p7_a2;
    ddp_adr_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_adr_rec.last_updated_by := p7_a4;
    ddp_adr_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a5);
    ddp_adr_rec.last_update_login := p7_a6;
    ddp_adr_rec.last_name := p7_a7;
    ddp_adr_rec.first_name := p7_a8;
    ddp_adr_rec.job_title := p7_a9;
    ddp_adr_rec.company := p7_a10;
    ddp_adr_rec.primary_contact := p7_a11;
    ddp_adr_rec.contact1_type := p7_a12;
    ddp_adr_rec.contact1 := p7_a13;
    ddp_adr_rec.contact2_type := p7_a14;
    ddp_adr_rec.contact2 := p7_a15;
    ddp_adr_rec.contact3_type := p7_a16;
    ddp_adr_rec.contact3 := p7_a17;
    ddp_adr_rec.contact4_type := p7_a18;
    ddp_adr_rec.contact4 := p7_a19;
    ddp_adr_rec.contact5_type := p7_a20;
    ddp_adr_rec.contact5 := p7_a21;
    ddp_adr_rec.www_address := p7_a22;
    ddp_adr_rec.assistant_name := p7_a23;
    ddp_adr_rec.assistant_phone := p7_a24;
    ddp_adr_rec.category := p7_a25;
    ddp_adr_rec.address1 := p7_a26;
    ddp_adr_rec.address2 := p7_a27;
    ddp_adr_rec.address3 := p7_a28;
    ddp_adr_rec.address4 := p7_a29;
    ddp_adr_rec.city := p7_a30;
    ddp_adr_rec.county := p7_a31;
    ddp_adr_rec.state := p7_a32;
    ddp_adr_rec.zip := p7_a33;
    ddp_adr_rec.country := p7_a34;
    ddp_adr_rec.note := p7_a35;
    ddp_adr_rec.private_flag := p7_a36;
    ddp_adr_rec.deleted_as_of := rosetta_g_miss_date_in_map(p7_a37);
    ddp_adr_rec.application_id := p7_a38;
    ddp_adr_rec.security_group_id := p7_a39;
    ddp_adr_rec.object_version_number := p7_a40;


    -- here's the delegated call to the old PL/SQL routine
    jtf_cal_addr_pvt.update_row(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_adr_rec,
      x_object_version_number);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

end jtf_cal_addr_pvt_w;

/
