--------------------------------------------------------
--  DDL for Package Body AMS_BOM_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_BOM_PVT_W" as
  /* $Header: amswbomb.pls 115.8 2002/11/11 22:07:05 abhola ship $ */
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

  procedure ams_process_bom(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p_last_update_date  date
    , p_last_update_by  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  VARCHAR2 := fnd_api.g_miss_char
    , p8_a0  DATE := fnd_api.g_miss_date
    , p8_a1  DATE := fnd_api.g_miss_date
    , p8_a2  NUMBER := 0-1962.0724
    , p8_a3  VARCHAR2 := fnd_api.g_miss_char
    , p8_a4  NUMBER := 0-1962.0724
    , p8_a5  NUMBER := 0-1962.0724
    , p8_a6  NUMBER := 0-1962.0724
    , p8_a7  NUMBER := 0-1962.0724
    , p8_a8  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_bom_rec_type ams_bom_pvt.bom_rec_type;
    ddp_bom_comp_rec_type ams_bom_pvt.bom_comp_rec_type;
    ddp_last_update_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_bom_rec_type.inventory_item_id := rosetta_g_miss_num_map(p7_a0);
    ddp_bom_rec_type.organization_id := rosetta_g_miss_num_map(p7_a1);
    ddp_bom_rec_type.alternate_bom_code := p7_a2;
    ddp_bom_rec_type.assembly_type := rosetta_g_miss_num_map(p7_a3);
    ddp_bom_rec_type.transaction_type := p7_a4;
    ddp_bom_rec_type.return_status := p7_a5;

    ddp_bom_comp_rec_type.start_effective_date := rosetta_g_miss_date_in_map(p8_a0);
    ddp_bom_comp_rec_type.disable_date := rosetta_g_miss_date_in_map(p8_a1);
    ddp_bom_comp_rec_type.operation_sequence_number := rosetta_g_miss_num_map(p8_a2);
    ddp_bom_comp_rec_type.component_item_name := p8_a3;
    ddp_bom_comp_rec_type.component_item_id := rosetta_g_miss_num_map(p8_a4);
    ddp_bom_comp_rec_type.item_sequence_number := rosetta_g_miss_num_map(p8_a5);
    ddp_bom_comp_rec_type.quantity_per_assembly := rosetta_g_miss_num_map(p8_a6);
    ddp_bom_comp_rec_type.quantity_related := rosetta_g_miss_num_map(p8_a7);
    ddp_bom_comp_rec_type.return_status := p8_a8;

    ddp_last_update_date := rosetta_g_miss_date_in_map(p_last_update_date);


    -- here's the delegated call to the old PL/SQL routine
    ams_bom_pvt.ams_process_bom(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_bom_rec_type,
      ddp_bom_comp_rec_type,
      ddp_last_update_date,
      p_last_update_by);

    -- copy data back from the local OUT or IN-OUT args, if any










  end;

end ams_bom_pvt_w;

/
