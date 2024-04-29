--------------------------------------------------------
--  DDL for Package Body CSP_REQUIREMENT_HEADERS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_REQUIREMENT_HEADERS_PVT_W" as
  /* $Header: csprqhpvtwb.pls 120.0.12010000.3 2012/02/13 07:22:20 htank noship $ */
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

  procedure rosetta_table_copy_in_p3(t out nocopy csp_requirement_headers_pvt.requirement_header_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_DATE_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_200
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
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).requirement_header_id := a0(indx);
          t(ddindx).created_by := a1(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).last_updated_by := a3(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).last_update_login := a5(indx);
          t(ddindx).open_requirement := a6(indx);
          t(ddindx).ship_to_location_id := a7(indx);
          t(ddindx).task_id := a8(indx);
          t(ddindx).task_assignment_id := a9(indx);
          t(ddindx).shipping_method_code := a10(indx);
          t(ddindx).need_by_date := rosetta_g_miss_date_in_map(a11(indx));
          t(ddindx).destination_organization_id := a12(indx);
          t(ddindx).parts_defined := a13(indx);
          t(ddindx).attribute_category := a14(indx);
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
          t(ddindx).order_type_id := a30(indx);
          t(ddindx).address_type := a31(indx);
          t(ddindx).resource_id := a32(indx);
          t(ddindx).resource_type := a33(indx);
          t(ddindx).timezone_id := a34(indx);
          t(ddindx).destination_subinventory := a35(indx);
          t(ddindx).ship_to_contact_id := a36(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t csp_requirement_headers_pvt.requirement_header_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_300
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_200
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
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_300();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_200();
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
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_VARCHAR2_TABLE_100();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_VARCHAR2_TABLE_100();
    a36 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_300();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_200();
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
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_VARCHAR2_TABLE_100();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_VARCHAR2_TABLE_100();
      a36 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).requirement_header_id;
          a1(indx) := t(ddindx).created_by;
          a2(indx) := t(ddindx).creation_date;
          a3(indx) := t(ddindx).last_updated_by;
          a4(indx) := t(ddindx).last_update_date;
          a5(indx) := t(ddindx).last_update_login;
          a6(indx) := t(ddindx).open_requirement;
          a7(indx) := t(ddindx).ship_to_location_id;
          a8(indx) := t(ddindx).task_id;
          a9(indx) := t(ddindx).task_assignment_id;
          a10(indx) := t(ddindx).shipping_method_code;
          a11(indx) := t(ddindx).need_by_date;
          a12(indx) := t(ddindx).destination_organization_id;
          a13(indx) := t(ddindx).parts_defined;
          a14(indx) := t(ddindx).attribute_category;
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
          a30(indx) := t(ddindx).order_type_id;
          a31(indx) := t(ddindx).address_type;
          a32(indx) := t(ddindx).resource_id;
          a33(indx) := t(ddindx).resource_type;
          a34(indx) := t(ddindx).timezone_id;
          a35(indx) := t(ddindx).destination_subinventory;
          a36(indx) := t(ddindx).ship_to_contact_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure create_requirement_headers(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  DATE
    , p4_a3  NUMBER
    , p4_a4  DATE
    , p4_a5  NUMBER
    , p4_a6  VARCHAR2
    , p4_a7  NUMBER
    , p4_a8  NUMBER
    , p4_a9  NUMBER
    , p4_a10  VARCHAR2
    , p4_a11  DATE
    , p4_a12  NUMBER
    , p4_a13  VARCHAR2
    , p4_a14  VARCHAR2
    , p4_a15  VARCHAR2
    , p4_a16  VARCHAR2
    , p4_a17  VARCHAR2
    , p4_a18  VARCHAR2
    , p4_a19  VARCHAR2
    , p4_a20  VARCHAR2
    , p4_a21  VARCHAR2
    , p4_a22  VARCHAR2
    , p4_a23  VARCHAR2
    , p4_a24  VARCHAR2
    , p4_a25  VARCHAR2
    , p4_a26  VARCHAR2
    , p4_a27  VARCHAR2
    , p4_a28  VARCHAR2
    , p4_a29  VARCHAR2
    , p4_a30  NUMBER
    , p4_a31  VARCHAR2
    , p4_a32  NUMBER
    , p4_a33  VARCHAR2
    , p4_a34  NUMBER
    , p4_a35  VARCHAR2
    , p4_a36  NUMBER
    , x_requirement_header_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_requirement_header_rec csp_requirement_headers_pvt.requirement_header_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_requirement_header_rec.requirement_header_id := p4_a0;
    ddp_requirement_header_rec.created_by := p4_a1;
    ddp_requirement_header_rec.creation_date := rosetta_g_miss_date_in_map(p4_a2);
    ddp_requirement_header_rec.last_updated_by := p4_a3;
    ddp_requirement_header_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a4);
    ddp_requirement_header_rec.last_update_login := p4_a5;
    ddp_requirement_header_rec.open_requirement := p4_a6;
    ddp_requirement_header_rec.ship_to_location_id := p4_a7;
    ddp_requirement_header_rec.task_id := p4_a8;
    ddp_requirement_header_rec.task_assignment_id := p4_a9;
    ddp_requirement_header_rec.shipping_method_code := p4_a10;
    ddp_requirement_header_rec.need_by_date := rosetta_g_miss_date_in_map(p4_a11);
    ddp_requirement_header_rec.destination_organization_id := p4_a12;
    ddp_requirement_header_rec.parts_defined := p4_a13;
    ddp_requirement_header_rec.attribute_category := p4_a14;
    ddp_requirement_header_rec.attribute1 := p4_a15;
    ddp_requirement_header_rec.attribute2 := p4_a16;
    ddp_requirement_header_rec.attribute3 := p4_a17;
    ddp_requirement_header_rec.attribute4 := p4_a18;
    ddp_requirement_header_rec.attribute5 := p4_a19;
    ddp_requirement_header_rec.attribute6 := p4_a20;
    ddp_requirement_header_rec.attribute7 := p4_a21;
    ddp_requirement_header_rec.attribute8 := p4_a22;
    ddp_requirement_header_rec.attribute9 := p4_a23;
    ddp_requirement_header_rec.attribute10 := p4_a24;
    ddp_requirement_header_rec.attribute11 := p4_a25;
    ddp_requirement_header_rec.attribute12 := p4_a26;
    ddp_requirement_header_rec.attribute13 := p4_a27;
    ddp_requirement_header_rec.attribute14 := p4_a28;
    ddp_requirement_header_rec.attribute15 := p4_a29;
    ddp_requirement_header_rec.order_type_id := p4_a30;
    ddp_requirement_header_rec.address_type := p4_a31;
    ddp_requirement_header_rec.resource_id := p4_a32;
    ddp_requirement_header_rec.resource_type := p4_a33;
    ddp_requirement_header_rec.timezone_id := p4_a34;
    ddp_requirement_header_rec.destination_subinventory := p4_a35;
    ddp_requirement_header_rec.ship_to_contact_id := p4_a36;





    -- here's the delegated call to the old PL/SQL routine
    csp_requirement_headers_pvt.create_requirement_headers(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_requirement_header_rec,
      x_requirement_header_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_requirement_headers(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  DATE
    , p4_a3  NUMBER
    , p4_a4  DATE
    , p4_a5  NUMBER
    , p4_a6  VARCHAR2
    , p4_a7  NUMBER
    , p4_a8  NUMBER
    , p4_a9  NUMBER
    , p4_a10  VARCHAR2
    , p4_a11  DATE
    , p4_a12  NUMBER
    , p4_a13  VARCHAR2
    , p4_a14  VARCHAR2
    , p4_a15  VARCHAR2
    , p4_a16  VARCHAR2
    , p4_a17  VARCHAR2
    , p4_a18  VARCHAR2
    , p4_a19  VARCHAR2
    , p4_a20  VARCHAR2
    , p4_a21  VARCHAR2
    , p4_a22  VARCHAR2
    , p4_a23  VARCHAR2
    , p4_a24  VARCHAR2
    , p4_a25  VARCHAR2
    , p4_a26  VARCHAR2
    , p4_a27  VARCHAR2
    , p4_a28  VARCHAR2
    , p4_a29  VARCHAR2
    , p4_a30  NUMBER
    , p4_a31  VARCHAR2
    , p4_a32  NUMBER
    , p4_a33  VARCHAR2
    , p4_a34  NUMBER
    , p4_a35  VARCHAR2
    , p4_a36  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_requirement_header_rec csp_requirement_headers_pvt.requirement_header_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_requirement_header_rec.requirement_header_id := p4_a0;
    ddp_requirement_header_rec.created_by := p4_a1;
    ddp_requirement_header_rec.creation_date := rosetta_g_miss_date_in_map(p4_a2);
    ddp_requirement_header_rec.last_updated_by := p4_a3;
    ddp_requirement_header_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a4);
    ddp_requirement_header_rec.last_update_login := p4_a5;
    ddp_requirement_header_rec.open_requirement := p4_a6;
    ddp_requirement_header_rec.ship_to_location_id := p4_a7;
    ddp_requirement_header_rec.task_id := p4_a8;
    ddp_requirement_header_rec.task_assignment_id := p4_a9;
    ddp_requirement_header_rec.shipping_method_code := p4_a10;
    ddp_requirement_header_rec.need_by_date := rosetta_g_miss_date_in_map(p4_a11);
    ddp_requirement_header_rec.destination_organization_id := p4_a12;
    ddp_requirement_header_rec.parts_defined := p4_a13;
    ddp_requirement_header_rec.attribute_category := p4_a14;
    ddp_requirement_header_rec.attribute1 := p4_a15;
    ddp_requirement_header_rec.attribute2 := p4_a16;
    ddp_requirement_header_rec.attribute3 := p4_a17;
    ddp_requirement_header_rec.attribute4 := p4_a18;
    ddp_requirement_header_rec.attribute5 := p4_a19;
    ddp_requirement_header_rec.attribute6 := p4_a20;
    ddp_requirement_header_rec.attribute7 := p4_a21;
    ddp_requirement_header_rec.attribute8 := p4_a22;
    ddp_requirement_header_rec.attribute9 := p4_a23;
    ddp_requirement_header_rec.attribute10 := p4_a24;
    ddp_requirement_header_rec.attribute11 := p4_a25;
    ddp_requirement_header_rec.attribute12 := p4_a26;
    ddp_requirement_header_rec.attribute13 := p4_a27;
    ddp_requirement_header_rec.attribute14 := p4_a28;
    ddp_requirement_header_rec.attribute15 := p4_a29;
    ddp_requirement_header_rec.order_type_id := p4_a30;
    ddp_requirement_header_rec.address_type := p4_a31;
    ddp_requirement_header_rec.resource_id := p4_a32;
    ddp_requirement_header_rec.resource_type := p4_a33;
    ddp_requirement_header_rec.timezone_id := p4_a34;
    ddp_requirement_header_rec.destination_subinventory := p4_a35;
    ddp_requirement_header_rec.ship_to_contact_id := p4_a36;




    -- here's the delegated call to the old PL/SQL routine
    csp_requirement_headers_pvt.update_requirement_headers(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_requirement_header_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure delete_requirement_headers(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  DATE
    , p4_a3  NUMBER
    , p4_a4  DATE
    , p4_a5  NUMBER
    , p4_a6  VARCHAR2
    , p4_a7  NUMBER
    , p4_a8  NUMBER
    , p4_a9  NUMBER
    , p4_a10  VARCHAR2
    , p4_a11  DATE
    , p4_a12  NUMBER
    , p4_a13  VARCHAR2
    , p4_a14  VARCHAR2
    , p4_a15  VARCHAR2
    , p4_a16  VARCHAR2
    , p4_a17  VARCHAR2
    , p4_a18  VARCHAR2
    , p4_a19  VARCHAR2
    , p4_a20  VARCHAR2
    , p4_a21  VARCHAR2
    , p4_a22  VARCHAR2
    , p4_a23  VARCHAR2
    , p4_a24  VARCHAR2
    , p4_a25  VARCHAR2
    , p4_a26  VARCHAR2
    , p4_a27  VARCHAR2
    , p4_a28  VARCHAR2
    , p4_a29  VARCHAR2
    , p4_a30  NUMBER
    , p4_a31  VARCHAR2
    , p4_a32  NUMBER
    , p4_a33  VARCHAR2
    , p4_a34  NUMBER
    , p4_a35  VARCHAR2
    , p4_a36  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_requirement_header_rec csp_requirement_headers_pvt.requirement_header_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_requirement_header_rec.requirement_header_id := p4_a0;
    ddp_requirement_header_rec.created_by := p4_a1;
    ddp_requirement_header_rec.creation_date := rosetta_g_miss_date_in_map(p4_a2);
    ddp_requirement_header_rec.last_updated_by := p4_a3;
    ddp_requirement_header_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a4);
    ddp_requirement_header_rec.last_update_login := p4_a5;
    ddp_requirement_header_rec.open_requirement := p4_a6;
    ddp_requirement_header_rec.ship_to_location_id := p4_a7;
    ddp_requirement_header_rec.task_id := p4_a8;
    ddp_requirement_header_rec.task_assignment_id := p4_a9;
    ddp_requirement_header_rec.shipping_method_code := p4_a10;
    ddp_requirement_header_rec.need_by_date := rosetta_g_miss_date_in_map(p4_a11);
    ddp_requirement_header_rec.destination_organization_id := p4_a12;
    ddp_requirement_header_rec.parts_defined := p4_a13;
    ddp_requirement_header_rec.attribute_category := p4_a14;
    ddp_requirement_header_rec.attribute1 := p4_a15;
    ddp_requirement_header_rec.attribute2 := p4_a16;
    ddp_requirement_header_rec.attribute3 := p4_a17;
    ddp_requirement_header_rec.attribute4 := p4_a18;
    ddp_requirement_header_rec.attribute5 := p4_a19;
    ddp_requirement_header_rec.attribute6 := p4_a20;
    ddp_requirement_header_rec.attribute7 := p4_a21;
    ddp_requirement_header_rec.attribute8 := p4_a22;
    ddp_requirement_header_rec.attribute9 := p4_a23;
    ddp_requirement_header_rec.attribute10 := p4_a24;
    ddp_requirement_header_rec.attribute11 := p4_a25;
    ddp_requirement_header_rec.attribute12 := p4_a26;
    ddp_requirement_header_rec.attribute13 := p4_a27;
    ddp_requirement_header_rec.attribute14 := p4_a28;
    ddp_requirement_header_rec.attribute15 := p4_a29;
    ddp_requirement_header_rec.order_type_id := p4_a30;
    ddp_requirement_header_rec.address_type := p4_a31;
    ddp_requirement_header_rec.resource_id := p4_a32;
    ddp_requirement_header_rec.resource_type := p4_a33;
    ddp_requirement_header_rec.timezone_id := p4_a34;
    ddp_requirement_header_rec.destination_subinventory := p4_a35;
    ddp_requirement_header_rec.ship_to_contact_id := p4_a36;




    -- here's the delegated call to the old PL/SQL routine
    csp_requirement_headers_pvt.delete_requirement_headers(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_requirement_header_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

end csp_requirement_headers_pvt_w;

/
