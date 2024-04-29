--------------------------------------------------------
--  DDL for Package Body AHL_RM_ASO_RESOURCE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_RM_ASO_RESOURCE_PVT_W" as
  /* $Header: AHLWASRB.pls 120.1.12010000.2 2008/10/24 09:35:42 pdoki ship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy ahl_rm_aso_resource_pvt.bom_resource_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_300
    , a11 JTF_VARCHAR2_TABLE_300
    , a12 JTF_DATE_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_300
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
    , a31 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).resource_mapping_id := a0(indx);
          t(ddindx).object_version_number := a1(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).last_updated_by := a3(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).created_by := a5(indx);
          t(ddindx).last_update_login := a6(indx);
          t(ddindx).bom_resource_id := a7(indx);
          t(ddindx).bom_org_id := a8(indx);
          t(ddindx).bom_resource_code := a9(indx);
          t(ddindx).bom_org_name := a10(indx);
          t(ddindx).discription := a11(indx);
          t(ddindx).disable_date := rosetta_g_miss_date_in_map(a12(indx));
          t(ddindx).department_id := a13(indx);
          t(ddindx).department_name := a14(indx);
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
          t(ddindx).dml_operation := a31(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t ahl_rm_aso_resource_pvt.bom_resource_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_300
    , a11 out nocopy JTF_VARCHAR2_TABLE_300
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_300
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
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
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
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_300();
    a11 := JTF_VARCHAR2_TABLE_300();
    a12 := JTF_DATE_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_300();
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
    a31 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_300();
      a11 := JTF_VARCHAR2_TABLE_300();
      a12 := JTF_DATE_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_300();
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
      a31 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).resource_mapping_id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).last_update_date;
          a3(indx) := t(ddindx).last_updated_by;
          a4(indx) := t(ddindx).creation_date;
          a5(indx) := t(ddindx).created_by;
          a6(indx) := t(ddindx).last_update_login;
          a7(indx) := t(ddindx).bom_resource_id;
          a8(indx) := t(ddindx).bom_org_id;
          a9(indx) := t(ddindx).bom_resource_code;
          a10(indx) := t(ddindx).bom_org_name;
          a11(indx) := t(ddindx).discription;
          a12(indx) := t(ddindx).disable_date;
          a13(indx) := t(ddindx).department_id;
          a14(indx) := t(ddindx).department_name;
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
          a31(indx) := t(ddindx).dml_operation;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure process_aso_resource(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_default  VARCHAR2
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0 in out nocopy  NUMBER
    , p9_a1 in out nocopy  NUMBER
    , p9_a2 in out nocopy  DATE
    , p9_a3 in out nocopy  NUMBER
    , p9_a4 in out nocopy  DATE
    , p9_a5 in out nocopy  NUMBER
    , p9_a6 in out nocopy  NUMBER
    , p9_a7 in out nocopy  NUMBER
    , p9_a8 in out nocopy  VARCHAR2
    , p9_a9 in out nocopy  VARCHAR2
    , p9_a10 in out nocopy  VARCHAR2
    , p9_a11 in out nocopy  VARCHAR2
    , p9_a12 in out nocopy  VARCHAR2
    , p9_a13 in out nocopy  VARCHAR2
    , p9_a14 in out nocopy  VARCHAR2
    , p9_a15 in out nocopy  VARCHAR2
    , p9_a16 in out nocopy  VARCHAR2
    , p9_a17 in out nocopy  VARCHAR2
    , p9_a18 in out nocopy  VARCHAR2
    , p9_a19 in out nocopy  VARCHAR2
    , p9_a20 in out nocopy  VARCHAR2
    , p9_a21 in out nocopy  VARCHAR2
    , p9_a22 in out nocopy  VARCHAR2
    , p9_a23 in out nocopy  VARCHAR2
    , p9_a24 in out nocopy  VARCHAR2
    , p9_a25 in out nocopy  VARCHAR2
    , p9_a26 in out nocopy  VARCHAR2
    , p9_a27 in out nocopy  VARCHAR2
    , p10_a0 in out nocopy JTF_NUMBER_TABLE
    , p10_a1 in out nocopy JTF_NUMBER_TABLE
    , p10_a2 in out nocopy JTF_DATE_TABLE
    , p10_a3 in out nocopy JTF_NUMBER_TABLE
    , p10_a4 in out nocopy JTF_DATE_TABLE
    , p10_a5 in out nocopy JTF_NUMBER_TABLE
    , p10_a6 in out nocopy JTF_NUMBER_TABLE
    , p10_a7 in out nocopy JTF_NUMBER_TABLE
    , p10_a8 in out nocopy JTF_NUMBER_TABLE
    , p10_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a10 in out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a11 in out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a12 in out nocopy JTF_DATE_TABLE
    , p10_a13 in out nocopy JTF_NUMBER_TABLE
    , p10_a14 in out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a15 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a30 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a31 in out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_x_aso_resource_rec ahl_rm_aso_resource_pvt.aso_resource_rec_type;
    ddp_x_bom_resource_tbl ahl_rm_aso_resource_pvt.bom_resource_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ddp_x_aso_resource_rec.resource_id := p9_a0;
    ddp_x_aso_resource_rec.object_version_number := p9_a1;
    ddp_x_aso_resource_rec.last_update_date := rosetta_g_miss_date_in_map(p9_a2);
    ddp_x_aso_resource_rec.last_updated_by := p9_a3;
    ddp_x_aso_resource_rec.creation_date := rosetta_g_miss_date_in_map(p9_a4);
    ddp_x_aso_resource_rec.created_by := p9_a5;
    ddp_x_aso_resource_rec.last_update_login := p9_a6;
    ddp_x_aso_resource_rec.resource_type_id := p9_a7;
    ddp_x_aso_resource_rec.resource_type := p9_a8;
    ddp_x_aso_resource_rec.name := p9_a9;
    ddp_x_aso_resource_rec.description := p9_a10;
    ddp_x_aso_resource_rec.attribute_category := p9_a11;
    ddp_x_aso_resource_rec.attribute1 := p9_a12;
    ddp_x_aso_resource_rec.attribute2 := p9_a13;
    ddp_x_aso_resource_rec.attribute3 := p9_a14;
    ddp_x_aso_resource_rec.attribute4 := p9_a15;
    ddp_x_aso_resource_rec.attribute5 := p9_a16;
    ddp_x_aso_resource_rec.attribute6 := p9_a17;
    ddp_x_aso_resource_rec.attribute7 := p9_a18;
    ddp_x_aso_resource_rec.attribute8 := p9_a19;
    ddp_x_aso_resource_rec.attribute9 := p9_a20;
    ddp_x_aso_resource_rec.attribute10 := p9_a21;
    ddp_x_aso_resource_rec.attribute11 := p9_a22;
    ddp_x_aso_resource_rec.attribute12 := p9_a23;
    ddp_x_aso_resource_rec.attribute13 := p9_a24;
    ddp_x_aso_resource_rec.attribute14 := p9_a25;
    ddp_x_aso_resource_rec.attribute15 := p9_a26;
    ddp_x_aso_resource_rec.dml_operation := p9_a27;

    ahl_rm_aso_resource_pvt_w.rosetta_table_copy_in_p2(ddp_x_bom_resource_tbl, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      , p10_a4
      , p10_a5
      , p10_a6
      , p10_a7
      , p10_a8
      , p10_a9
      , p10_a10
      , p10_a11
      , p10_a12
      , p10_a13
      , p10_a14
      , p10_a15
      , p10_a16
      , p10_a17
      , p10_a18
      , p10_a19
      , p10_a20
      , p10_a21
      , p10_a22
      , p10_a23
      , p10_a24
      , p10_a25
      , p10_a26
      , p10_a27
      , p10_a28
      , p10_a29
      , p10_a30
      , p10_a31
      );

    -- here's the delegated call to the old PL/SQL routine
    ahl_rm_aso_resource_pvt.process_aso_resource(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_default,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_x_aso_resource_rec,
      ddp_x_bom_resource_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    p9_a0 := ddp_x_aso_resource_rec.resource_id;
    p9_a1 := ddp_x_aso_resource_rec.object_version_number;
    p9_a2 := ddp_x_aso_resource_rec.last_update_date;
    p9_a3 := ddp_x_aso_resource_rec.last_updated_by;
    p9_a4 := ddp_x_aso_resource_rec.creation_date;
    p9_a5 := ddp_x_aso_resource_rec.created_by;
    p9_a6 := ddp_x_aso_resource_rec.last_update_login;
    p9_a7 := ddp_x_aso_resource_rec.resource_type_id;
    p9_a8 := ddp_x_aso_resource_rec.resource_type;
    p9_a9 := ddp_x_aso_resource_rec.name;
    p9_a10 := ddp_x_aso_resource_rec.description;
    p9_a11 := ddp_x_aso_resource_rec.attribute_category;
    p9_a12 := ddp_x_aso_resource_rec.attribute1;
    p9_a13 := ddp_x_aso_resource_rec.attribute2;
    p9_a14 := ddp_x_aso_resource_rec.attribute3;
    p9_a15 := ddp_x_aso_resource_rec.attribute4;
    p9_a16 := ddp_x_aso_resource_rec.attribute5;
    p9_a17 := ddp_x_aso_resource_rec.attribute6;
    p9_a18 := ddp_x_aso_resource_rec.attribute7;
    p9_a19 := ddp_x_aso_resource_rec.attribute8;
    p9_a20 := ddp_x_aso_resource_rec.attribute9;
    p9_a21 := ddp_x_aso_resource_rec.attribute10;
    p9_a22 := ddp_x_aso_resource_rec.attribute11;
    p9_a23 := ddp_x_aso_resource_rec.attribute12;
    p9_a24 := ddp_x_aso_resource_rec.attribute13;
    p9_a25 := ddp_x_aso_resource_rec.attribute14;
    p9_a26 := ddp_x_aso_resource_rec.attribute15;
    p9_a27 := ddp_x_aso_resource_rec.dml_operation;

    ahl_rm_aso_resource_pvt_w.rosetta_table_copy_out_p2(ddp_x_bom_resource_tbl, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      , p10_a4
      , p10_a5
      , p10_a6
      , p10_a7
      , p10_a8
      , p10_a9
      , p10_a10
      , p10_a11
      , p10_a12
      , p10_a13
      , p10_a14
      , p10_a15
      , p10_a16
      , p10_a17
      , p10_a18
      , p10_a19
      , p10_a20
      , p10_a21
      , p10_a22
      , p10_a23
      , p10_a24
      , p10_a25
      , p10_a26
      , p10_a27
      , p10_a28
      , p10_a29
      , p10_a30
      , p10_a31
      );
  end;

end ahl_rm_aso_resource_pvt_w;

/
