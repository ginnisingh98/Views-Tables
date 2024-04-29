--------------------------------------------------------
--  DDL for Package Body CSP_EXCESS_PARTS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_EXCESS_PARTS_PVT_W" as
  /* $Header: cspvpexwb.pls 120.0.12010000.2 2010/11/15 11:42:44 htank noship $ */
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

  procedure populate_excess_list(p0_a0 in out nocopy  NUMBER
    , p0_a1 in out nocopy  NUMBER
    , p0_a2 in out nocopy  NUMBER
    , p0_a3 in out nocopy  NUMBER
    , p0_a4 in out nocopy  VARCHAR2
    , p0_a5 in out nocopy  NUMBER
    , p0_a6 in out nocopy  DATE
    , p0_a7 in out nocopy  NUMBER
    , p0_a8 in out nocopy  DATE
    , p0_a9 in out nocopy  NUMBER
    , p0_a10 in out nocopy  VARCHAR2
    , p0_a11 in out nocopy  NUMBER
    , p0_a12 in out nocopy  NUMBER
    , p0_a13 in out nocopy  NUMBER
    , p0_a14 in out nocopy  VARCHAR2
    , p0_a15 in out nocopy  VARCHAR2
    , p0_a16 in out nocopy  VARCHAR2
    , p0_a17 in out nocopy  VARCHAR2
    , p0_a18 in out nocopy  VARCHAR2
    , p0_a19 in out nocopy  VARCHAR2
    , p0_a20 in out nocopy  VARCHAR2
    , p0_a21 in out nocopy  VARCHAR2
    , p0_a22 in out nocopy  VARCHAR2
    , p0_a23 in out nocopy  VARCHAR2
    , p0_a24 in out nocopy  VARCHAR2
    , p0_a25 in out nocopy  VARCHAR2
    , p0_a26 in out nocopy  VARCHAR2
    , p0_a27 in out nocopy  VARCHAR2
    , p0_a28 in out nocopy  VARCHAR2
    , p0_a29 in out nocopy  VARCHAR2
    , p0_a30 in out nocopy  VARCHAR2
    , p0_a31 in out nocopy  NUMBER
    , p0_a32 in out nocopy  VARCHAR2
    , p0_a33 in out nocopy  NUMBER
    , p0_a34 in out nocopy  VARCHAR2
    , p_is_insert_record  VARCHAR2
  )

  as
    ddp_excess_part csp_excess_lists_pkg.excess_record_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_excess_part.excess_line_id := p0_a0;
    ddp_excess_part.organization_id := p0_a1;
    ddp_excess_part.inventory_item_id := p0_a2;
    ddp_excess_part.excess_quantity := p0_a3;
    ddp_excess_part.condition_code := p0_a4;
    ddp_excess_part.created_by := p0_a5;
    ddp_excess_part.creation_date := rosetta_g_miss_date_in_map(p0_a6);
    ddp_excess_part.last_updated_by := p0_a7;
    ddp_excess_part.last_update_date := rosetta_g_miss_date_in_map(p0_a8);
    ddp_excess_part.last_update_login := p0_a9;
    ddp_excess_part.subinventory_code := p0_a10;
    ddp_excess_part.returned_quantity := p0_a11;
    ddp_excess_part.current_return_qty := p0_a12;
    ddp_excess_part.requisition_line_id := p0_a13;
    ddp_excess_part.excess_status := p0_a14;
    ddp_excess_part.attribute_category := p0_a15;
    ddp_excess_part.attribute1 := p0_a16;
    ddp_excess_part.attribute2 := p0_a17;
    ddp_excess_part.attribute3 := p0_a18;
    ddp_excess_part.attribute4 := p0_a19;
    ddp_excess_part.attribute5 := p0_a20;
    ddp_excess_part.attribute6 := p0_a21;
    ddp_excess_part.attribute7 := p0_a22;
    ddp_excess_part.attribute8 := p0_a23;
    ddp_excess_part.attribute9 := p0_a24;
    ddp_excess_part.attribute10 := p0_a25;
    ddp_excess_part.attribute11 := p0_a26;
    ddp_excess_part.attribute12 := p0_a27;
    ddp_excess_part.attribute13 := p0_a28;
    ddp_excess_part.attribute14 := p0_a29;
    ddp_excess_part.attribute15 := p0_a30;
    ddp_excess_part.security_group_id := p0_a31;
    ddp_excess_part.reason_code := p0_a32;
    ddp_excess_part.return_organization_id := p0_a33;
    ddp_excess_part.return_subinventory_name := p0_a34;


    -- here's the delegated call to the old PL/SQL routine
    csp_excess_parts_pvt.populate_excess_list(ddp_excess_part,
      p_is_insert_record);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    p0_a0 := ddp_excess_part.excess_line_id;
    p0_a1 := ddp_excess_part.organization_id;
    p0_a2 := ddp_excess_part.inventory_item_id;
    p0_a3 := ddp_excess_part.excess_quantity;
    p0_a4 := ddp_excess_part.condition_code;
    p0_a5 := ddp_excess_part.created_by;
    p0_a6 := ddp_excess_part.creation_date;
    p0_a7 := ddp_excess_part.last_updated_by;
    p0_a8 := ddp_excess_part.last_update_date;
    p0_a9 := ddp_excess_part.last_update_login;
    p0_a10 := ddp_excess_part.subinventory_code;
    p0_a11 := ddp_excess_part.returned_quantity;
    p0_a12 := ddp_excess_part.current_return_qty;
    p0_a13 := ddp_excess_part.requisition_line_id;
    p0_a14 := ddp_excess_part.excess_status;
    p0_a15 := ddp_excess_part.attribute_category;
    p0_a16 := ddp_excess_part.attribute1;
    p0_a17 := ddp_excess_part.attribute2;
    p0_a18 := ddp_excess_part.attribute3;
    p0_a19 := ddp_excess_part.attribute4;
    p0_a20 := ddp_excess_part.attribute5;
    p0_a21 := ddp_excess_part.attribute6;
    p0_a22 := ddp_excess_part.attribute7;
    p0_a23 := ddp_excess_part.attribute8;
    p0_a24 := ddp_excess_part.attribute9;
    p0_a25 := ddp_excess_part.attribute10;
    p0_a26 := ddp_excess_part.attribute11;
    p0_a27 := ddp_excess_part.attribute12;
    p0_a28 := ddp_excess_part.attribute13;
    p0_a29 := ddp_excess_part.attribute14;
    p0_a30 := ddp_excess_part.attribute15;
    p0_a31 := ddp_excess_part.security_group_id;
    p0_a32 := ddp_excess_part.reason_code;
    p0_a33 := ddp_excess_part.return_organization_id;
    p0_a34 := ddp_excess_part.return_subinventory_name;

  end;

end csp_excess_parts_pvt_w;

/
