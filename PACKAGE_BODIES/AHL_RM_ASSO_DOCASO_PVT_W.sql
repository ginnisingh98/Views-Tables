--------------------------------------------------------
--  DDL for Package Body AHL_RM_ASSO_DOCASO_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_RM_ASSO_DOCASO_PVT_W" as
  /* $Header: AHLWRODB.pls 120.0 2005/05/26 00:21:52 appldev noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p1(t out nocopy ahl_rm_asso_docaso_pvt.doc_association_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_300
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_2000
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_200
    , a24 JTF_VARCHAR2_TABLE_200
    , a25 JTF_VARCHAR2_TABLE_200
    , a26 JTF_VARCHAR2_TABLE_200
    , a27 JTF_VARCHAR2_TABLE_200
    , a28 JTF_VARCHAR2_TABLE_200
    , a29 JTF_VARCHAR2_TABLE_200
    , a30 JTF_VARCHAR2_TABLE_200
    , a31 JTF_VARCHAR2_TABLE_200
    , a32 JTF_VARCHAR2_TABLE_200
    , a33 JTF_VARCHAR2_TABLE_200
    , a34 JTF_VARCHAR2_TABLE_200
    , a35 JTF_VARCHAR2_TABLE_200
    , a36 JTF_VARCHAR2_TABLE_200
    , a37 JTF_VARCHAR2_TABLE_200
    , a38 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).doc_title_asso_id := a0(indx);
          t(ddindx).document_id := a1(indx);
          t(ddindx).document_no := a2(indx);
          t(ddindx).doc_revision_id := a3(indx);
          t(ddindx).revision_no := a4(indx);
          t(ddindx).use_latest_rev_flag := a5(indx);
          t(ddindx).object_type_code := a6(indx);
          t(ddindx).object_type_desc := a7(indx);
          t(ddindx).object_id := a8(indx);
          t(ddindx).object_number := a9(indx);
          t(ddindx).object_revision := a10(indx);
          t(ddindx).serial_no := a11(indx);
          t(ddindx).source_lang := a12(indx);
          t(ddindx).chapter := a13(indx);
          t(ddindx).section := a14(indx);
          t(ddindx).subject := a15(indx);
          t(ddindx).page := a16(indx);
          t(ddindx).figure := a17(indx);
          t(ddindx).note := a18(indx);
          t(ddindx).source_ref_code := a19(indx);
          t(ddindx).source_ref_mean := a20(indx);
          t(ddindx).object_version_number := a21(indx);
          t(ddindx).attribute_category := a22(indx);
          t(ddindx).attribute1 := a23(indx);
          t(ddindx).attribute2 := a24(indx);
          t(ddindx).attribute3 := a25(indx);
          t(ddindx).attribute4 := a26(indx);
          t(ddindx).attribute5 := a27(indx);
          t(ddindx).attribute6 := a28(indx);
          t(ddindx).attribute7 := a29(indx);
          t(ddindx).attribute8 := a30(indx);
          t(ddindx).attribute9 := a31(indx);
          t(ddindx).attribute10 := a32(indx);
          t(ddindx).attribute11 := a33(indx);
          t(ddindx).attribute12 := a34(indx);
          t(ddindx).attribute13 := a35(indx);
          t(ddindx).attribute14 := a36(indx);
          t(ddindx).attribute15 := a37(indx);
          t(ddindx).dml_operation := a38(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t ahl_rm_asso_docaso_pvt.doc_association_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_300
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_2000
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_200
    , a24 out nocopy JTF_VARCHAR2_TABLE_200
    , a25 out nocopy JTF_VARCHAR2_TABLE_200
    , a26 out nocopy JTF_VARCHAR2_TABLE_200
    , a27 out nocopy JTF_VARCHAR2_TABLE_200
    , a28 out nocopy JTF_VARCHAR2_TABLE_200
    , a29 out nocopy JTF_VARCHAR2_TABLE_200
    , a30 out nocopy JTF_VARCHAR2_TABLE_200
    , a31 out nocopy JTF_VARCHAR2_TABLE_200
    , a32 out nocopy JTF_VARCHAR2_TABLE_200
    , a33 out nocopy JTF_VARCHAR2_TABLE_200
    , a34 out nocopy JTF_VARCHAR2_TABLE_200
    , a35 out nocopy JTF_VARCHAR2_TABLE_200
    , a36 out nocopy JTF_VARCHAR2_TABLE_200
    , a37 out nocopy JTF_VARCHAR2_TABLE_200
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_300();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_2000();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_200();
    a24 := JTF_VARCHAR2_TABLE_200();
    a25 := JTF_VARCHAR2_TABLE_200();
    a26 := JTF_VARCHAR2_TABLE_200();
    a27 := JTF_VARCHAR2_TABLE_200();
    a28 := JTF_VARCHAR2_TABLE_200();
    a29 := JTF_VARCHAR2_TABLE_200();
    a30 := JTF_VARCHAR2_TABLE_200();
    a31 := JTF_VARCHAR2_TABLE_200();
    a32 := JTF_VARCHAR2_TABLE_200();
    a33 := JTF_VARCHAR2_TABLE_200();
    a34 := JTF_VARCHAR2_TABLE_200();
    a35 := JTF_VARCHAR2_TABLE_200();
    a36 := JTF_VARCHAR2_TABLE_200();
    a37 := JTF_VARCHAR2_TABLE_200();
    a38 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_300();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_2000();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_200();
      a24 := JTF_VARCHAR2_TABLE_200();
      a25 := JTF_VARCHAR2_TABLE_200();
      a26 := JTF_VARCHAR2_TABLE_200();
      a27 := JTF_VARCHAR2_TABLE_200();
      a28 := JTF_VARCHAR2_TABLE_200();
      a29 := JTF_VARCHAR2_TABLE_200();
      a30 := JTF_VARCHAR2_TABLE_200();
      a31 := JTF_VARCHAR2_TABLE_200();
      a32 := JTF_VARCHAR2_TABLE_200();
      a33 := JTF_VARCHAR2_TABLE_200();
      a34 := JTF_VARCHAR2_TABLE_200();
      a35 := JTF_VARCHAR2_TABLE_200();
      a36 := JTF_VARCHAR2_TABLE_200();
      a37 := JTF_VARCHAR2_TABLE_200();
      a38 := JTF_VARCHAR2_TABLE_100();
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
        a37.extend(t.count);
        a38.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).doc_title_asso_id;
          a1(indx) := t(ddindx).document_id;
          a2(indx) := t(ddindx).document_no;
          a3(indx) := t(ddindx).doc_revision_id;
          a4(indx) := t(ddindx).revision_no;
          a5(indx) := t(ddindx).use_latest_rev_flag;
          a6(indx) := t(ddindx).object_type_code;
          a7(indx) := t(ddindx).object_type_desc;
          a8(indx) := t(ddindx).object_id;
          a9(indx) := t(ddindx).object_number;
          a10(indx) := t(ddindx).object_revision;
          a11(indx) := t(ddindx).serial_no;
          a12(indx) := t(ddindx).source_lang;
          a13(indx) := t(ddindx).chapter;
          a14(indx) := t(ddindx).section;
          a15(indx) := t(ddindx).subject;
          a16(indx) := t(ddindx).page;
          a17(indx) := t(ddindx).figure;
          a18(indx) := t(ddindx).note;
          a19(indx) := t(ddindx).source_ref_code;
          a20(indx) := t(ddindx).source_ref_mean;
          a21(indx) := t(ddindx).object_version_number;
          a22(indx) := t(ddindx).attribute_category;
          a23(indx) := t(ddindx).attribute1;
          a24(indx) := t(ddindx).attribute2;
          a25(indx) := t(ddindx).attribute3;
          a26(indx) := t(ddindx).attribute4;
          a27(indx) := t(ddindx).attribute5;
          a28(indx) := t(ddindx).attribute6;
          a29(indx) := t(ddindx).attribute7;
          a30(indx) := t(ddindx).attribute8;
          a31(indx) := t(ddindx).attribute9;
          a32(indx) := t(ddindx).attribute10;
          a33(indx) := t(ddindx).attribute11;
          a34(indx) := t(ddindx).attribute12;
          a35(indx) := t(ddindx).attribute13;
          a36(indx) := t(ddindx).attribute14;
          a37(indx) := t(ddindx).attribute15;
          a38(indx) := t(ddindx).dml_operation;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure process_association(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_validate_only  VARCHAR2
    , p_default  VARCHAR2
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p10_a0 in out nocopy JTF_NUMBER_TABLE
    , p10_a1 in out nocopy JTF_NUMBER_TABLE
    , p10_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a3 in out nocopy JTF_NUMBER_TABLE
    , p10_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a8 in out nocopy JTF_NUMBER_TABLE
    , p10_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a10 in out nocopy JTF_NUMBER_TABLE
    , p10_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a13 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a15 in out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a16 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a17 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a18 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p10_a19 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a21 in out nocopy JTF_NUMBER_TABLE
    , p10_a22 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a30 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a31 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a32 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a33 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a34 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a35 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a36 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a37 in out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a38 in out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_x_association_tbl ahl_rm_asso_docaso_pvt.doc_association_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ahl_rm_asso_docaso_pvt_w.rosetta_table_copy_in_p1(ddp_x_association_tbl, p10_a0
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
      , p10_a32
      , p10_a33
      , p10_a34
      , p10_a35
      , p10_a36
      , p10_a37
      , p10_a38
      );

    -- here's the delegated call to the old PL/SQL routine
    ahl_rm_asso_docaso_pvt.process_association(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_validate_only,
      p_default,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_x_association_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    ahl_rm_asso_docaso_pvt_w.rosetta_table_copy_out_p1(ddp_x_association_tbl, p10_a0
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
      , p10_a32
      , p10_a33
      , p10_a34
      , p10_a35
      , p10_a36
      , p10_a37
      , p10_a38
      );
  end;

end ahl_rm_asso_docaso_pvt_w;

/
