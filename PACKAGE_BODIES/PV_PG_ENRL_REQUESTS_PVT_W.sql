--------------------------------------------------------
--  DDL for Package Body PV_PG_ENRL_REQUESTS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PG_ENRL_REQUESTS_PVT_W" as
  /* $Header: pvxwperb.pls 120.1 2005/10/24 08:31 dgottlie noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p2(t out nocopy pv_pg_enrl_requests_pvt.enrl_request_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_DATE_TABLE
    , a13 JTF_DATE_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_DATE_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_DATE_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_DATE_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_VARCHAR2_TABLE_300
    , a30 JTF_VARCHAR2_TABLE_300
    , a31 JTF_VARCHAR2_TABLE_300
    , a32 JTF_VARCHAR2_TABLE_300
    , a33 JTF_VARCHAR2_TABLE_300
    , a34 JTF_VARCHAR2_TABLE_300
    , a35 JTF_VARCHAR2_TABLE_300
    , a36 JTF_VARCHAR2_TABLE_300
    , a37 JTF_VARCHAR2_TABLE_300
    , a38 JTF_VARCHAR2_TABLE_300
    , a39 JTF_VARCHAR2_TABLE_300
    , a40 JTF_VARCHAR2_TABLE_300
    , a41 JTF_VARCHAR2_TABLE_300
    , a42 JTF_VARCHAR2_TABLE_300
    , a43 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).enrl_request_id := a0(indx);
          t(ddindx).object_version_number := a1(indx);
          t(ddindx).program_id := a2(indx);
          t(ddindx).partner_id := a3(indx);
          t(ddindx).custom_setup_id := a4(indx);
          t(ddindx).requestor_resource_id := a5(indx);
          t(ddindx).request_status_code := a6(indx);
          t(ddindx).enrollment_type_code := a7(indx);
          t(ddindx).request_submission_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).contract_id := a9(indx);
          t(ddindx).request_initiated_by_code := a10(indx);
          t(ddindx).invite_header_id := a11(indx);
          t(ddindx).tentative_start_date := rosetta_g_miss_date_in_map(a12(indx));
          t(ddindx).tentative_end_date := rosetta_g_miss_date_in_map(a13(indx));
          t(ddindx).contract_status_code := a14(indx);
          t(ddindx).payment_status_code := a15(indx);
          t(ddindx).score_result_code := a16(indx);
          t(ddindx).created_by := a17(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a18(indx));
          t(ddindx).last_updated_by := a19(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a20(indx));
          t(ddindx).last_update_login := a21(indx);
          t(ddindx).order_header_id := a22(indx);
          t(ddindx).membership_fee := a23(indx);
          t(ddindx).dependent_program_id := a24(indx);
          t(ddindx).trans_curr_code := a25(indx);
          t(ddindx).contract_binding_contact_id := a26(indx);
          t(ddindx).contract_signed_date := rosetta_g_miss_date_in_map(a27(indx));
          t(ddindx).trxn_extension_id := a28(indx);
          t(ddindx).attribute1 := a29(indx);
          t(ddindx).attribute2 := a30(indx);
          t(ddindx).attribute3 := a31(indx);
          t(ddindx).attribute4 := a32(indx);
          t(ddindx).attribute5 := a33(indx);
          t(ddindx).attribute6 := a34(indx);
          t(ddindx).attribute7 := a35(indx);
          t(ddindx).attribute8 := a36(indx);
          t(ddindx).attribute9 := a37(indx);
          t(ddindx).attribute10 := a38(indx);
          t(ddindx).attribute11 := a39(indx);
          t(ddindx).attribute12 := a40(indx);
          t(ddindx).attribute13 := a41(indx);
          t(ddindx).attribute14 := a42(indx);
          t(ddindx).attribute15 := a43(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t pv_pg_enrl_requests_pvt.enrl_request_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_DATE_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_DATE_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_DATE_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_VARCHAR2_TABLE_300
    , a30 out nocopy JTF_VARCHAR2_TABLE_300
    , a31 out nocopy JTF_VARCHAR2_TABLE_300
    , a32 out nocopy JTF_VARCHAR2_TABLE_300
    , a33 out nocopy JTF_VARCHAR2_TABLE_300
    , a34 out nocopy JTF_VARCHAR2_TABLE_300
    , a35 out nocopy JTF_VARCHAR2_TABLE_300
    , a36 out nocopy JTF_VARCHAR2_TABLE_300
    , a37 out nocopy JTF_VARCHAR2_TABLE_300
    , a38 out nocopy JTF_VARCHAR2_TABLE_300
    , a39 out nocopy JTF_VARCHAR2_TABLE_300
    , a40 out nocopy JTF_VARCHAR2_TABLE_300
    , a41 out nocopy JTF_VARCHAR2_TABLE_300
    , a42 out nocopy JTF_VARCHAR2_TABLE_300
    , a43 out nocopy JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_DATE_TABLE();
    a13 := JTF_DATE_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_DATE_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_DATE_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_DATE_TABLE();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_VARCHAR2_TABLE_300();
    a30 := JTF_VARCHAR2_TABLE_300();
    a31 := JTF_VARCHAR2_TABLE_300();
    a32 := JTF_VARCHAR2_TABLE_300();
    a33 := JTF_VARCHAR2_TABLE_300();
    a34 := JTF_VARCHAR2_TABLE_300();
    a35 := JTF_VARCHAR2_TABLE_300();
    a36 := JTF_VARCHAR2_TABLE_300();
    a37 := JTF_VARCHAR2_TABLE_300();
    a38 := JTF_VARCHAR2_TABLE_300();
    a39 := JTF_VARCHAR2_TABLE_300();
    a40 := JTF_VARCHAR2_TABLE_300();
    a41 := JTF_VARCHAR2_TABLE_300();
    a42 := JTF_VARCHAR2_TABLE_300();
    a43 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_DATE_TABLE();
      a13 := JTF_DATE_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_DATE_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_DATE_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_DATE_TABLE();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_VARCHAR2_TABLE_300();
      a30 := JTF_VARCHAR2_TABLE_300();
      a31 := JTF_VARCHAR2_TABLE_300();
      a32 := JTF_VARCHAR2_TABLE_300();
      a33 := JTF_VARCHAR2_TABLE_300();
      a34 := JTF_VARCHAR2_TABLE_300();
      a35 := JTF_VARCHAR2_TABLE_300();
      a36 := JTF_VARCHAR2_TABLE_300();
      a37 := JTF_VARCHAR2_TABLE_300();
      a38 := JTF_VARCHAR2_TABLE_300();
      a39 := JTF_VARCHAR2_TABLE_300();
      a40 := JTF_VARCHAR2_TABLE_300();
      a41 := JTF_VARCHAR2_TABLE_300();
      a42 := JTF_VARCHAR2_TABLE_300();
      a43 := JTF_VARCHAR2_TABLE_300();
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
        a39.extend(t.count);
        a40.extend(t.count);
        a41.extend(t.count);
        a42.extend(t.count);
        a43.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).enrl_request_id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).program_id;
          a3(indx) := t(ddindx).partner_id;
          a4(indx) := t(ddindx).custom_setup_id;
          a5(indx) := t(ddindx).requestor_resource_id;
          a6(indx) := t(ddindx).request_status_code;
          a7(indx) := t(ddindx).enrollment_type_code;
          a8(indx) := t(ddindx).request_submission_date;
          a9(indx) := t(ddindx).contract_id;
          a10(indx) := t(ddindx).request_initiated_by_code;
          a11(indx) := t(ddindx).invite_header_id;
          a12(indx) := t(ddindx).tentative_start_date;
          a13(indx) := t(ddindx).tentative_end_date;
          a14(indx) := t(ddindx).contract_status_code;
          a15(indx) := t(ddindx).payment_status_code;
          a16(indx) := t(ddindx).score_result_code;
          a17(indx) := t(ddindx).created_by;
          a18(indx) := t(ddindx).creation_date;
          a19(indx) := t(ddindx).last_updated_by;
          a20(indx) := t(ddindx).last_update_date;
          a21(indx) := t(ddindx).last_update_login;
          a22(indx) := t(ddindx).order_header_id;
          a23(indx) := t(ddindx).membership_fee;
          a24(indx) := t(ddindx).dependent_program_id;
          a25(indx) := t(ddindx).trans_curr_code;
          a26(indx) := t(ddindx).contract_binding_contact_id;
          a27(indx) := t(ddindx).contract_signed_date;
          a28(indx) := t(ddindx).trxn_extension_id;
          a29(indx) := t(ddindx).attribute1;
          a30(indx) := t(ddindx).attribute2;
          a31(indx) := t(ddindx).attribute3;
          a32(indx) := t(ddindx).attribute4;
          a33(indx) := t(ddindx).attribute5;
          a34(indx) := t(ddindx).attribute6;
          a35(indx) := t(ddindx).attribute7;
          a36(indx) := t(ddindx).attribute8;
          a37(indx) := t(ddindx).attribute9;
          a38(indx) := t(ddindx).attribute10;
          a39(indx) := t(ddindx).attribute11;
          a40(indx) := t(ddindx).attribute12;
          a41(indx) := t(ddindx).attribute13;
          a42(indx) := t(ddindx).attribute14;
          a43(indx) := t(ddindx).attribute15;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure create_pg_enrl_requests(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  NUMBER
    , p7_a3  NUMBER
    , p7_a4  NUMBER
    , p7_a5  NUMBER
    , p7_a6  VARCHAR2
    , p7_a7  VARCHAR2
    , p7_a8  DATE
    , p7_a9  NUMBER
    , p7_a10  VARCHAR2
    , p7_a11  NUMBER
    , p7_a12  DATE
    , p7_a13  DATE
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
    , p7_a17  NUMBER
    , p7_a18  DATE
    , p7_a19  NUMBER
    , p7_a20  DATE
    , p7_a21  NUMBER
    , p7_a22  NUMBER
    , p7_a23  NUMBER
    , p7_a24  NUMBER
    , p7_a25  VARCHAR2
    , p7_a26  NUMBER
    , p7_a27  DATE
    , p7_a28  NUMBER
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  VARCHAR2
    , p7_a38  VARCHAR2
    , p7_a39  VARCHAR2
    , p7_a40  VARCHAR2
    , p7_a41  VARCHAR2
    , p7_a42  VARCHAR2
    , p7_a43  VARCHAR2
    , x_enrl_request_id out nocopy  NUMBER
  )

  as
    ddp_enrl_request_rec pv_pg_enrl_requests_pvt.enrl_request_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_enrl_request_rec.enrl_request_id := p7_a0;
    ddp_enrl_request_rec.object_version_number := p7_a1;
    ddp_enrl_request_rec.program_id := p7_a2;
    ddp_enrl_request_rec.partner_id := p7_a3;
    ddp_enrl_request_rec.custom_setup_id := p7_a4;
    ddp_enrl_request_rec.requestor_resource_id := p7_a5;
    ddp_enrl_request_rec.request_status_code := p7_a6;
    ddp_enrl_request_rec.enrollment_type_code := p7_a7;
    ddp_enrl_request_rec.request_submission_date := rosetta_g_miss_date_in_map(p7_a8);
    ddp_enrl_request_rec.contract_id := p7_a9;
    ddp_enrl_request_rec.request_initiated_by_code := p7_a10;
    ddp_enrl_request_rec.invite_header_id := p7_a11;
    ddp_enrl_request_rec.tentative_start_date := rosetta_g_miss_date_in_map(p7_a12);
    ddp_enrl_request_rec.tentative_end_date := rosetta_g_miss_date_in_map(p7_a13);
    ddp_enrl_request_rec.contract_status_code := p7_a14;
    ddp_enrl_request_rec.payment_status_code := p7_a15;
    ddp_enrl_request_rec.score_result_code := p7_a16;
    ddp_enrl_request_rec.created_by := p7_a17;
    ddp_enrl_request_rec.creation_date := rosetta_g_miss_date_in_map(p7_a18);
    ddp_enrl_request_rec.last_updated_by := p7_a19;
    ddp_enrl_request_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a20);
    ddp_enrl_request_rec.last_update_login := p7_a21;
    ddp_enrl_request_rec.order_header_id := p7_a22;
    ddp_enrl_request_rec.membership_fee := p7_a23;
    ddp_enrl_request_rec.dependent_program_id := p7_a24;
    ddp_enrl_request_rec.trans_curr_code := p7_a25;
    ddp_enrl_request_rec.contract_binding_contact_id := p7_a26;
    ddp_enrl_request_rec.contract_signed_date := rosetta_g_miss_date_in_map(p7_a27);
    ddp_enrl_request_rec.trxn_extension_id := p7_a28;
    ddp_enrl_request_rec.attribute1 := p7_a29;
    ddp_enrl_request_rec.attribute2 := p7_a30;
    ddp_enrl_request_rec.attribute3 := p7_a31;
    ddp_enrl_request_rec.attribute4 := p7_a32;
    ddp_enrl_request_rec.attribute5 := p7_a33;
    ddp_enrl_request_rec.attribute6 := p7_a34;
    ddp_enrl_request_rec.attribute7 := p7_a35;
    ddp_enrl_request_rec.attribute8 := p7_a36;
    ddp_enrl_request_rec.attribute9 := p7_a37;
    ddp_enrl_request_rec.attribute10 := p7_a38;
    ddp_enrl_request_rec.attribute11 := p7_a39;
    ddp_enrl_request_rec.attribute12 := p7_a40;
    ddp_enrl_request_rec.attribute13 := p7_a41;
    ddp_enrl_request_rec.attribute14 := p7_a42;
    ddp_enrl_request_rec.attribute15 := p7_a43;


    -- here's the delegated call to the old PL/SQL routine
    pv_pg_enrl_requests_pvt.create_pg_enrl_requests(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_enrl_request_rec,
      x_enrl_request_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_pg_enrl_requests(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  NUMBER
    , p7_a3  NUMBER
    , p7_a4  NUMBER
    , p7_a5  NUMBER
    , p7_a6  VARCHAR2
    , p7_a7  VARCHAR2
    , p7_a8  DATE
    , p7_a9  NUMBER
    , p7_a10  VARCHAR2
    , p7_a11  NUMBER
    , p7_a12  DATE
    , p7_a13  DATE
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
    , p7_a17  NUMBER
    , p7_a18  DATE
    , p7_a19  NUMBER
    , p7_a20  DATE
    , p7_a21  NUMBER
    , p7_a22  NUMBER
    , p7_a23  NUMBER
    , p7_a24  NUMBER
    , p7_a25  VARCHAR2
    , p7_a26  NUMBER
    , p7_a27  DATE
    , p7_a28  NUMBER
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  VARCHAR2
    , p7_a38  VARCHAR2
    , p7_a39  VARCHAR2
    , p7_a40  VARCHAR2
    , p7_a41  VARCHAR2
    , p7_a42  VARCHAR2
    , p7_a43  VARCHAR2
  )

  as
    ddp_enrl_request_rec pv_pg_enrl_requests_pvt.enrl_request_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_enrl_request_rec.enrl_request_id := p7_a0;
    ddp_enrl_request_rec.object_version_number := p7_a1;
    ddp_enrl_request_rec.program_id := p7_a2;
    ddp_enrl_request_rec.partner_id := p7_a3;
    ddp_enrl_request_rec.custom_setup_id := p7_a4;
    ddp_enrl_request_rec.requestor_resource_id := p7_a5;
    ddp_enrl_request_rec.request_status_code := p7_a6;
    ddp_enrl_request_rec.enrollment_type_code := p7_a7;
    ddp_enrl_request_rec.request_submission_date := rosetta_g_miss_date_in_map(p7_a8);
    ddp_enrl_request_rec.contract_id := p7_a9;
    ddp_enrl_request_rec.request_initiated_by_code := p7_a10;
    ddp_enrl_request_rec.invite_header_id := p7_a11;
    ddp_enrl_request_rec.tentative_start_date := rosetta_g_miss_date_in_map(p7_a12);
    ddp_enrl_request_rec.tentative_end_date := rosetta_g_miss_date_in_map(p7_a13);
    ddp_enrl_request_rec.contract_status_code := p7_a14;
    ddp_enrl_request_rec.payment_status_code := p7_a15;
    ddp_enrl_request_rec.score_result_code := p7_a16;
    ddp_enrl_request_rec.created_by := p7_a17;
    ddp_enrl_request_rec.creation_date := rosetta_g_miss_date_in_map(p7_a18);
    ddp_enrl_request_rec.last_updated_by := p7_a19;
    ddp_enrl_request_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a20);
    ddp_enrl_request_rec.last_update_login := p7_a21;
    ddp_enrl_request_rec.order_header_id := p7_a22;
    ddp_enrl_request_rec.membership_fee := p7_a23;
    ddp_enrl_request_rec.dependent_program_id := p7_a24;
    ddp_enrl_request_rec.trans_curr_code := p7_a25;
    ddp_enrl_request_rec.contract_binding_contact_id := p7_a26;
    ddp_enrl_request_rec.contract_signed_date := rosetta_g_miss_date_in_map(p7_a27);
    ddp_enrl_request_rec.trxn_extension_id := p7_a28;
    ddp_enrl_request_rec.attribute1 := p7_a29;
    ddp_enrl_request_rec.attribute2 := p7_a30;
    ddp_enrl_request_rec.attribute3 := p7_a31;
    ddp_enrl_request_rec.attribute4 := p7_a32;
    ddp_enrl_request_rec.attribute5 := p7_a33;
    ddp_enrl_request_rec.attribute6 := p7_a34;
    ddp_enrl_request_rec.attribute7 := p7_a35;
    ddp_enrl_request_rec.attribute8 := p7_a36;
    ddp_enrl_request_rec.attribute9 := p7_a37;
    ddp_enrl_request_rec.attribute10 := p7_a38;
    ddp_enrl_request_rec.attribute11 := p7_a39;
    ddp_enrl_request_rec.attribute12 := p7_a40;
    ddp_enrl_request_rec.attribute13 := p7_a41;
    ddp_enrl_request_rec.attribute14 := p7_a42;
    ddp_enrl_request_rec.attribute15 := p7_a43;

    -- here's the delegated call to the old PL/SQL routine
    pv_pg_enrl_requests_pvt.update_pg_enrl_requests(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_enrl_request_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_pg_enrl_requests(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p3_a0  NUMBER
    , p3_a1  NUMBER
    , p3_a2  NUMBER
    , p3_a3  NUMBER
    , p3_a4  NUMBER
    , p3_a5  NUMBER
    , p3_a6  VARCHAR2
    , p3_a7  VARCHAR2
    , p3_a8  DATE
    , p3_a9  NUMBER
    , p3_a10  VARCHAR2
    , p3_a11  NUMBER
    , p3_a12  DATE
    , p3_a13  DATE
    , p3_a14  VARCHAR2
    , p3_a15  VARCHAR2
    , p3_a16  VARCHAR2
    , p3_a17  NUMBER
    , p3_a18  DATE
    , p3_a19  NUMBER
    , p3_a20  DATE
    , p3_a21  NUMBER
    , p3_a22  NUMBER
    , p3_a23  NUMBER
    , p3_a24  NUMBER
    , p3_a25  VARCHAR2
    , p3_a26  NUMBER
    , p3_a27  DATE
    , p3_a28  NUMBER
    , p3_a29  VARCHAR2
    , p3_a30  VARCHAR2
    , p3_a31  VARCHAR2
    , p3_a32  VARCHAR2
    , p3_a33  VARCHAR2
    , p3_a34  VARCHAR2
    , p3_a35  VARCHAR2
    , p3_a36  VARCHAR2
    , p3_a37  VARCHAR2
    , p3_a38  VARCHAR2
    , p3_a39  VARCHAR2
    , p3_a40  VARCHAR2
    , p3_a41  VARCHAR2
    , p3_a42  VARCHAR2
    , p3_a43  VARCHAR2
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_enrl_request_rec pv_pg_enrl_requests_pvt.enrl_request_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_enrl_request_rec.enrl_request_id := p3_a0;
    ddp_enrl_request_rec.object_version_number := p3_a1;
    ddp_enrl_request_rec.program_id := p3_a2;
    ddp_enrl_request_rec.partner_id := p3_a3;
    ddp_enrl_request_rec.custom_setup_id := p3_a4;
    ddp_enrl_request_rec.requestor_resource_id := p3_a5;
    ddp_enrl_request_rec.request_status_code := p3_a6;
    ddp_enrl_request_rec.enrollment_type_code := p3_a7;
    ddp_enrl_request_rec.request_submission_date := rosetta_g_miss_date_in_map(p3_a8);
    ddp_enrl_request_rec.contract_id := p3_a9;
    ddp_enrl_request_rec.request_initiated_by_code := p3_a10;
    ddp_enrl_request_rec.invite_header_id := p3_a11;
    ddp_enrl_request_rec.tentative_start_date := rosetta_g_miss_date_in_map(p3_a12);
    ddp_enrl_request_rec.tentative_end_date := rosetta_g_miss_date_in_map(p3_a13);
    ddp_enrl_request_rec.contract_status_code := p3_a14;
    ddp_enrl_request_rec.payment_status_code := p3_a15;
    ddp_enrl_request_rec.score_result_code := p3_a16;
    ddp_enrl_request_rec.created_by := p3_a17;
    ddp_enrl_request_rec.creation_date := rosetta_g_miss_date_in_map(p3_a18);
    ddp_enrl_request_rec.last_updated_by := p3_a19;
    ddp_enrl_request_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a20);
    ddp_enrl_request_rec.last_update_login := p3_a21;
    ddp_enrl_request_rec.order_header_id := p3_a22;
    ddp_enrl_request_rec.membership_fee := p3_a23;
    ddp_enrl_request_rec.dependent_program_id := p3_a24;
    ddp_enrl_request_rec.trans_curr_code := p3_a25;
    ddp_enrl_request_rec.contract_binding_contact_id := p3_a26;
    ddp_enrl_request_rec.contract_signed_date := rosetta_g_miss_date_in_map(p3_a27);
    ddp_enrl_request_rec.trxn_extension_id := p3_a28;
    ddp_enrl_request_rec.attribute1 := p3_a29;
    ddp_enrl_request_rec.attribute2 := p3_a30;
    ddp_enrl_request_rec.attribute3 := p3_a31;
    ddp_enrl_request_rec.attribute4 := p3_a32;
    ddp_enrl_request_rec.attribute5 := p3_a33;
    ddp_enrl_request_rec.attribute6 := p3_a34;
    ddp_enrl_request_rec.attribute7 := p3_a35;
    ddp_enrl_request_rec.attribute8 := p3_a36;
    ddp_enrl_request_rec.attribute9 := p3_a37;
    ddp_enrl_request_rec.attribute10 := p3_a38;
    ddp_enrl_request_rec.attribute11 := p3_a39;
    ddp_enrl_request_rec.attribute12 := p3_a40;
    ddp_enrl_request_rec.attribute13 := p3_a41;
    ddp_enrl_request_rec.attribute14 := p3_a42;
    ddp_enrl_request_rec.attribute15 := p3_a43;





    -- here's the delegated call to the old PL/SQL routine
    pv_pg_enrl_requests_pvt.validate_pg_enrl_requests(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_enrl_request_rec,
      p_validation_mode,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure check_enrl_request_items(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  NUMBER
    , p0_a3  NUMBER
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  VARCHAR2
    , p0_a7  VARCHAR2
    , p0_a8  DATE
    , p0_a9  NUMBER
    , p0_a10  VARCHAR2
    , p0_a11  NUMBER
    , p0_a12  DATE
    , p0_a13  DATE
    , p0_a14  VARCHAR2
    , p0_a15  VARCHAR2
    , p0_a16  VARCHAR2
    , p0_a17  NUMBER
    , p0_a18  DATE
    , p0_a19  NUMBER
    , p0_a20  DATE
    , p0_a21  NUMBER
    , p0_a22  NUMBER
    , p0_a23  NUMBER
    , p0_a24  NUMBER
    , p0_a25  VARCHAR2
    , p0_a26  NUMBER
    , p0_a27  DATE
    , p0_a28  NUMBER
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  VARCHAR2
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  VARCHAR2
    , p0_a35  VARCHAR2
    , p0_a36  VARCHAR2
    , p0_a37  VARCHAR2
    , p0_a38  VARCHAR2
    , p0_a39  VARCHAR2
    , p0_a40  VARCHAR2
    , p0_a41  VARCHAR2
    , p0_a42  VARCHAR2
    , p0_a43  VARCHAR2
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_enrl_request_rec pv_pg_enrl_requests_pvt.enrl_request_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_enrl_request_rec.enrl_request_id := p0_a0;
    ddp_enrl_request_rec.object_version_number := p0_a1;
    ddp_enrl_request_rec.program_id := p0_a2;
    ddp_enrl_request_rec.partner_id := p0_a3;
    ddp_enrl_request_rec.custom_setup_id := p0_a4;
    ddp_enrl_request_rec.requestor_resource_id := p0_a5;
    ddp_enrl_request_rec.request_status_code := p0_a6;
    ddp_enrl_request_rec.enrollment_type_code := p0_a7;
    ddp_enrl_request_rec.request_submission_date := rosetta_g_miss_date_in_map(p0_a8);
    ddp_enrl_request_rec.contract_id := p0_a9;
    ddp_enrl_request_rec.request_initiated_by_code := p0_a10;
    ddp_enrl_request_rec.invite_header_id := p0_a11;
    ddp_enrl_request_rec.tentative_start_date := rosetta_g_miss_date_in_map(p0_a12);
    ddp_enrl_request_rec.tentative_end_date := rosetta_g_miss_date_in_map(p0_a13);
    ddp_enrl_request_rec.contract_status_code := p0_a14;
    ddp_enrl_request_rec.payment_status_code := p0_a15;
    ddp_enrl_request_rec.score_result_code := p0_a16;
    ddp_enrl_request_rec.created_by := p0_a17;
    ddp_enrl_request_rec.creation_date := rosetta_g_miss_date_in_map(p0_a18);
    ddp_enrl_request_rec.last_updated_by := p0_a19;
    ddp_enrl_request_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a20);
    ddp_enrl_request_rec.last_update_login := p0_a21;
    ddp_enrl_request_rec.order_header_id := p0_a22;
    ddp_enrl_request_rec.membership_fee := p0_a23;
    ddp_enrl_request_rec.dependent_program_id := p0_a24;
    ddp_enrl_request_rec.trans_curr_code := p0_a25;
    ddp_enrl_request_rec.contract_binding_contact_id := p0_a26;
    ddp_enrl_request_rec.contract_signed_date := rosetta_g_miss_date_in_map(p0_a27);
    ddp_enrl_request_rec.trxn_extension_id := p0_a28;
    ddp_enrl_request_rec.attribute1 := p0_a29;
    ddp_enrl_request_rec.attribute2 := p0_a30;
    ddp_enrl_request_rec.attribute3 := p0_a31;
    ddp_enrl_request_rec.attribute4 := p0_a32;
    ddp_enrl_request_rec.attribute5 := p0_a33;
    ddp_enrl_request_rec.attribute6 := p0_a34;
    ddp_enrl_request_rec.attribute7 := p0_a35;
    ddp_enrl_request_rec.attribute8 := p0_a36;
    ddp_enrl_request_rec.attribute9 := p0_a37;
    ddp_enrl_request_rec.attribute10 := p0_a38;
    ddp_enrl_request_rec.attribute11 := p0_a39;
    ddp_enrl_request_rec.attribute12 := p0_a40;
    ddp_enrl_request_rec.attribute13 := p0_a41;
    ddp_enrl_request_rec.attribute14 := p0_a42;
    ddp_enrl_request_rec.attribute15 := p0_a43;



    -- here's the delegated call to the old PL/SQL routine
    pv_pg_enrl_requests_pvt.check_enrl_request_items(ddp_enrl_request_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure validate_enrl_request_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  NUMBER
    , p5_a4  NUMBER
    , p5_a5  NUMBER
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  DATE
    , p5_a9  NUMBER
    , p5_a10  VARCHAR2
    , p5_a11  NUMBER
    , p5_a12  DATE
    , p5_a13  DATE
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  NUMBER
    , p5_a18  DATE
    , p5_a19  NUMBER
    , p5_a20  DATE
    , p5_a21  NUMBER
    , p5_a22  NUMBER
    , p5_a23  NUMBER
    , p5_a24  NUMBER
    , p5_a25  VARCHAR2
    , p5_a26  NUMBER
    , p5_a27  DATE
    , p5_a28  NUMBER
    , p5_a29  VARCHAR2
    , p5_a30  VARCHAR2
    , p5_a31  VARCHAR2
    , p5_a32  VARCHAR2
    , p5_a33  VARCHAR2
    , p5_a34  VARCHAR2
    , p5_a35  VARCHAR2
    , p5_a36  VARCHAR2
    , p5_a37  VARCHAR2
    , p5_a38  VARCHAR2
    , p5_a39  VARCHAR2
    , p5_a40  VARCHAR2
    , p5_a41  VARCHAR2
    , p5_a42  VARCHAR2
    , p5_a43  VARCHAR2
  )

  as
    ddp_enrl_request_rec pv_pg_enrl_requests_pvt.enrl_request_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_enrl_request_rec.enrl_request_id := p5_a0;
    ddp_enrl_request_rec.object_version_number := p5_a1;
    ddp_enrl_request_rec.program_id := p5_a2;
    ddp_enrl_request_rec.partner_id := p5_a3;
    ddp_enrl_request_rec.custom_setup_id := p5_a4;
    ddp_enrl_request_rec.requestor_resource_id := p5_a5;
    ddp_enrl_request_rec.request_status_code := p5_a6;
    ddp_enrl_request_rec.enrollment_type_code := p5_a7;
    ddp_enrl_request_rec.request_submission_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_enrl_request_rec.contract_id := p5_a9;
    ddp_enrl_request_rec.request_initiated_by_code := p5_a10;
    ddp_enrl_request_rec.invite_header_id := p5_a11;
    ddp_enrl_request_rec.tentative_start_date := rosetta_g_miss_date_in_map(p5_a12);
    ddp_enrl_request_rec.tentative_end_date := rosetta_g_miss_date_in_map(p5_a13);
    ddp_enrl_request_rec.contract_status_code := p5_a14;
    ddp_enrl_request_rec.payment_status_code := p5_a15;
    ddp_enrl_request_rec.score_result_code := p5_a16;
    ddp_enrl_request_rec.created_by := p5_a17;
    ddp_enrl_request_rec.creation_date := rosetta_g_miss_date_in_map(p5_a18);
    ddp_enrl_request_rec.last_updated_by := p5_a19;
    ddp_enrl_request_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a20);
    ddp_enrl_request_rec.last_update_login := p5_a21;
    ddp_enrl_request_rec.order_header_id := p5_a22;
    ddp_enrl_request_rec.membership_fee := p5_a23;
    ddp_enrl_request_rec.dependent_program_id := p5_a24;
    ddp_enrl_request_rec.trans_curr_code := p5_a25;
    ddp_enrl_request_rec.contract_binding_contact_id := p5_a26;
    ddp_enrl_request_rec.contract_signed_date := rosetta_g_miss_date_in_map(p5_a27);
    ddp_enrl_request_rec.trxn_extension_id := p5_a28;
    ddp_enrl_request_rec.attribute1 := p5_a29;
    ddp_enrl_request_rec.attribute2 := p5_a30;
    ddp_enrl_request_rec.attribute3 := p5_a31;
    ddp_enrl_request_rec.attribute4 := p5_a32;
    ddp_enrl_request_rec.attribute5 := p5_a33;
    ddp_enrl_request_rec.attribute6 := p5_a34;
    ddp_enrl_request_rec.attribute7 := p5_a35;
    ddp_enrl_request_rec.attribute8 := p5_a36;
    ddp_enrl_request_rec.attribute9 := p5_a37;
    ddp_enrl_request_rec.attribute10 := p5_a38;
    ddp_enrl_request_rec.attribute11 := p5_a39;
    ddp_enrl_request_rec.attribute12 := p5_a40;
    ddp_enrl_request_rec.attribute13 := p5_a41;
    ddp_enrl_request_rec.attribute14 := p5_a42;
    ddp_enrl_request_rec.attribute15 := p5_a43;

    -- here's the delegated call to the old PL/SQL routine
    pv_pg_enrl_requests_pvt.validate_enrl_request_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_enrl_request_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end pv_pg_enrl_requests_pvt_w;

/
