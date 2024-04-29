--------------------------------------------------------
--  DDL for Package Body CSP_EXCESS_LISTS_PKG_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_EXCESS_LISTS_PKG_W" as
  /* $Header: csptexcwb.pls 120.0.12010000.2 2010/11/15 11:39:12 htank noship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy csp_excess_lists_pkg.excess_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_200
    , a17 JTF_VARCHAR2_TABLE_200
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
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_VARCHAR2_TABLE_300
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).excess_line_id := a0(indx);
          t(ddindx).organization_id := a1(indx);
          t(ddindx).inventory_item_id := a2(indx);
          t(ddindx).excess_quantity := a3(indx);
          t(ddindx).condition_code := a4(indx);
          t(ddindx).created_by := a5(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).last_updated_by := a7(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).last_update_login := a9(indx);
          t(ddindx).subinventory_code := a10(indx);
          t(ddindx).returned_quantity := a11(indx);
          t(ddindx).current_return_qty := a12(indx);
          t(ddindx).requisition_line_id := a13(indx);
          t(ddindx).excess_status := a14(indx);
          t(ddindx).attribute_category := a15(indx);
          t(ddindx).attribute1 := a16(indx);
          t(ddindx).attribute2 := a17(indx);
          t(ddindx).attribute3 := a18(indx);
          t(ddindx).attribute4 := a19(indx);
          t(ddindx).attribute5 := a20(indx);
          t(ddindx).attribute6 := a21(indx);
          t(ddindx).attribute7 := a22(indx);
          t(ddindx).attribute8 := a23(indx);
          t(ddindx).attribute9 := a24(indx);
          t(ddindx).attribute10 := a25(indx);
          t(ddindx).attribute11 := a26(indx);
          t(ddindx).attribute12 := a27(indx);
          t(ddindx).attribute13 := a28(indx);
          t(ddindx).attribute14 := a29(indx);
          t(ddindx).attribute15 := a30(indx);
          t(ddindx).security_group_id := a31(indx);
          t(ddindx).reason_code := a32(indx);
          t(ddindx).return_organization_id := a33(indx);
          t(ddindx).return_subinventory_name := a34(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t csp_excess_lists_pkg.excess_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_200
    , a17 out nocopy JTF_VARCHAR2_TABLE_200
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
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_VARCHAR2_TABLE_300
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_200();
    a17 := JTF_VARCHAR2_TABLE_200();
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
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_VARCHAR2_TABLE_300();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_200();
      a17 := JTF_VARCHAR2_TABLE_200();
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
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_VARCHAR2_TABLE_300();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).excess_line_id;
          a1(indx) := t(ddindx).organization_id;
          a2(indx) := t(ddindx).inventory_item_id;
          a3(indx) := t(ddindx).excess_quantity;
          a4(indx) := t(ddindx).condition_code;
          a5(indx) := t(ddindx).created_by;
          a6(indx) := t(ddindx).creation_date;
          a7(indx) := t(ddindx).last_updated_by;
          a8(indx) := t(ddindx).last_update_date;
          a9(indx) := t(ddindx).last_update_login;
          a10(indx) := t(ddindx).subinventory_code;
          a11(indx) := t(ddindx).returned_quantity;
          a12(indx) := t(ddindx).current_return_qty;
          a13(indx) := t(ddindx).requisition_line_id;
          a14(indx) := t(ddindx).excess_status;
          a15(indx) := t(ddindx).attribute_category;
          a16(indx) := t(ddindx).attribute1;
          a17(indx) := t(ddindx).attribute2;
          a18(indx) := t(ddindx).attribute3;
          a19(indx) := t(ddindx).attribute4;
          a20(indx) := t(ddindx).attribute5;
          a21(indx) := t(ddindx).attribute6;
          a22(indx) := t(ddindx).attribute7;
          a23(indx) := t(ddindx).attribute8;
          a24(indx) := t(ddindx).attribute9;
          a25(indx) := t(ddindx).attribute10;
          a26(indx) := t(ddindx).attribute11;
          a27(indx) := t(ddindx).attribute12;
          a28(indx) := t(ddindx).attribute13;
          a29(indx) := t(ddindx).attribute14;
          a30(indx) := t(ddindx).attribute15;
          a31(indx) := t(ddindx).security_group_id;
          a32(indx) := t(ddindx).reason_code;
          a33(indx) := t(ddindx).return_organization_id;
          a34(indx) := t(ddindx).return_subinventory_name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure insert_row(px_excess_line_id in out nocopy  NUMBER
    , p_created_by  NUMBER
    , p_creation_date  date
    , p_last_updated_by  NUMBER
    , p_last_update_date  date
    , p_last_update_login  NUMBER
    , p_organization_id  NUMBER
    , p_subinventory_code  VARCHAR2
    , p_condition_code  VARCHAR2
    , p_inventory_item_id  NUMBER
    , p_excess_quantity  NUMBER
    , p_requisition_line_id  NUMBER
    , p_returned_quantity  NUMBER
    , p_current_return_qty  NUMBER
    , p_excess_status  VARCHAR2
    , p_return_org_id  NUMBER
    , p_return_sub_inv  VARCHAR2
    , p_attribute_category  VARCHAR2
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , p_attribute11  VARCHAR2
    , p_attribute12  VARCHAR2
    , p_attribute13  VARCHAR2
    , p_attribute14  VARCHAR2
    , p_attribute15  VARCHAR2
  )

  as
    ddp_creation_date date;
    ddp_last_update_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_creation_date := rosetta_g_miss_date_in_map(p_creation_date);


    ddp_last_update_date := rosetta_g_miss_date_in_map(p_last_update_date);





























    -- here's the delegated call to the old PL/SQL routine
    csp_excess_lists_pkg.insert_row(px_excess_line_id,
      p_created_by,
      ddp_creation_date,
      p_last_updated_by,
      ddp_last_update_date,
      p_last_update_login,
      p_organization_id,
      p_subinventory_code,
      p_condition_code,
      p_inventory_item_id,
      p_excess_quantity,
      p_requisition_line_id,
      p_returned_quantity,
      p_current_return_qty,
      p_excess_status,
      p_return_org_id,
      p_return_sub_inv,
      p_attribute_category,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
































  end;

  procedure update_row(p_excess_line_id  NUMBER
    , p_created_by  NUMBER
    , p_creation_date  date
    , p_last_updated_by  NUMBER
    , p_last_update_date  date
    , p_last_update_login  NUMBER
    , p_organization_id  NUMBER
    , p_subinventory_code  VARCHAR2
    , p_condition_code  VARCHAR2
    , p_inventory_item_id  NUMBER
    , p_excess_quantity  NUMBER
    , p_requisition_line_id  NUMBER
    , p_returned_quantity  NUMBER
    , p_current_return_qty  NUMBER
    , p_attribute_category  VARCHAR2
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , p_attribute11  VARCHAR2
    , p_attribute12  VARCHAR2
    , p_attribute13  VARCHAR2
    , p_attribute14  VARCHAR2
    , p_attribute15  VARCHAR2
  )

  as
    ddp_creation_date date;
    ddp_last_update_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_creation_date := rosetta_g_miss_date_in_map(p_creation_date);


    ddp_last_update_date := rosetta_g_miss_date_in_map(p_last_update_date);


























    -- here's the delegated call to the old PL/SQL routine
    csp_excess_lists_pkg.update_row(p_excess_line_id,
      p_created_by,
      ddp_creation_date,
      p_last_updated_by,
      ddp_last_update_date,
      p_last_update_login,
      p_organization_id,
      p_subinventory_code,
      p_condition_code,
      p_inventory_item_id,
      p_excess_quantity,
      p_requisition_line_id,
      p_returned_quantity,
      p_current_return_qty,
      p_attribute_category,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





























  end;

  procedure lock_row(p_excess_line_id  NUMBER
    , p_created_by  NUMBER
    , p_creation_date  date
    , p_last_updated_by  NUMBER
    , p_last_update_date  date
    , p_last_update_login  NUMBER
    , p_organization_id  NUMBER
    , p_subinventory_code  VARCHAR2
    , p_condition_code  VARCHAR2
    , p_inventory_item_id  NUMBER
    , p_excess_quantity  NUMBER
    , p_requisition_line_id  NUMBER
    , p_returned_quantity  NUMBER
    , p_current_return_qty  NUMBER
    , p_attribute_category  VARCHAR2
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , p_attribute11  VARCHAR2
    , p_attribute12  VARCHAR2
    , p_attribute13  VARCHAR2
    , p_attribute14  VARCHAR2
    , p_attribute15  VARCHAR2
  )

  as
    ddp_creation_date date;
    ddp_last_update_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_creation_date := rosetta_g_miss_date_in_map(p_creation_date);


    ddp_last_update_date := rosetta_g_miss_date_in_map(p_last_update_date);


























    -- here's the delegated call to the old PL/SQL routine
    csp_excess_lists_pkg.lock_row(p_excess_line_id,
      p_created_by,
      ddp_creation_date,
      p_last_updated_by,
      ddp_last_update_date,
      p_last_update_login,
      p_organization_id,
      p_subinventory_code,
      p_condition_code,
      p_inventory_item_id,
      p_excess_quantity,
      p_requisition_line_id,
      p_returned_quantity,
      p_current_return_qty,
      p_attribute_category,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





























  end;

end csp_excess_lists_pkg_w;

/
