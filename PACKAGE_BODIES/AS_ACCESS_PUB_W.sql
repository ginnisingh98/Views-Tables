--------------------------------------------------------
--  DDL for Package Body AS_ACCESS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_ACCESS_PUB_W" as
  /* $Header: asxwacsb.pls 120.1 2005/07/29 05:37 appldev ship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy as_access_pub.sales_team_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_300
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_300
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_DATE_TABLE
    , a31 JTF_VARCHAR2_TABLE_300
    , a32 JTF_DATE_TABLE
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_VARCHAR2_TABLE_200
    , a37 JTF_VARCHAR2_TABLE_200
    , a38 JTF_VARCHAR2_TABLE_200
    , a39 JTF_VARCHAR2_TABLE_200
    , a40 JTF_VARCHAR2_TABLE_200
    , a41 JTF_VARCHAR2_TABLE_200
    , a42 JTF_VARCHAR2_TABLE_200
    , a43 JTF_VARCHAR2_TABLE_200
    , a44 JTF_VARCHAR2_TABLE_200
    , a45 JTF_VARCHAR2_TABLE_200
    , a46 JTF_VARCHAR2_TABLE_200
    , a47 JTF_VARCHAR2_TABLE_200
    , a48 JTF_VARCHAR2_TABLE_200
    , a49 JTF_VARCHAR2_TABLE_200
    , a50 JTF_VARCHAR2_TABLE_200
    , a51 JTF_VARCHAR2_TABLE_100
    , a52 JTF_VARCHAR2_TABLE_100
    , a53 JTF_VARCHAR2_TABLE_100
    , a54 JTF_NUMBER_TABLE
    , a55 JTF_NUMBER_TABLE
    , a56 JTF_VARCHAR2_TABLE_100
    , a57 JTF_VARCHAR2_TABLE_100
    , a58 JTF_VARCHAR2_TABLE_100
    , a59 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).access_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a1(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).freeze_flag := a6(indx);
          t(ddindx).reassign_flag := a7(indx);
          t(ddindx).team_leader_flag := a8(indx);
          t(ddindx).customer_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).address_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).salesforce_id := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).person_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).job_title := a13(indx);
          t(ddindx).first_name := a14(indx);
          t(ddindx).last_name := a15(indx);
          t(ddindx).email_address := a16(indx);
          t(ddindx).work_telephone := a17(indx);
          t(ddindx).sales_group_id := rosetta_g_miss_num_map(a18(indx));
          t(ddindx).sales_group_name := a19(indx);
          t(ddindx).partner_customer_id := rosetta_g_miss_num_map(a20(indx));
          t(ddindx).partner_address_id := rosetta_g_miss_num_map(a21(indx));
          t(ddindx).partner_name := a22(indx);
          t(ddindx).partner_number := a23(indx);
          t(ddindx).partner_city := a24(indx);
          t(ddindx).partner_phone_number := a25(indx);
          t(ddindx).partner_area_code := a26(indx);
          t(ddindx).partner_extension := a27(indx);
          t(ddindx).created_person_id := rosetta_g_miss_num_map(a28(indx));
          t(ddindx).lead_id := rosetta_g_miss_num_map(a29(indx));
          t(ddindx).freeze_date := rosetta_g_miss_date_in_map(a30(indx));
          t(ddindx).reassign_reason := a31(indx);
          t(ddindx).reassign_request_date := rosetta_g_miss_date_in_map(a32(indx));
          t(ddindx).reassign_requested_person_id := rosetta_g_miss_num_map(a33(indx));
          t(ddindx).downloadable_flag := a34(indx);
          t(ddindx).attribute_category := a35(indx);
          t(ddindx).attribute1 := a36(indx);
          t(ddindx).attribute2 := a37(indx);
          t(ddindx).attribute3 := a38(indx);
          t(ddindx).attribute4 := a39(indx);
          t(ddindx).attribute5 := a40(indx);
          t(ddindx).attribute6 := a41(indx);
          t(ddindx).attribute7 := a42(indx);
          t(ddindx).attribute8 := a43(indx);
          t(ddindx).attribute9 := a44(indx);
          t(ddindx).attribute10 := a45(indx);
          t(ddindx).attribute11 := a46(indx);
          t(ddindx).attribute12 := a47(indx);
          t(ddindx).attribute13 := a48(indx);
          t(ddindx).attribute14 := a49(indx);
          t(ddindx).attribute15 := a50(indx);
          t(ddindx).salesforce_role_code := a51(indx);
          t(ddindx).salesforce_relationship_code := a52(indx);
          t(ddindx).salesforce_relationship := a53(indx);
          t(ddindx).sales_lead_id := rosetta_g_miss_num_map(a54(indx));
          t(ddindx).partner_cont_party_id := rosetta_g_miss_num_map(a55(indx));
          t(ddindx).owner_flag := a56(indx);
          t(ddindx).created_by_tap_flag := a57(indx);
          t(ddindx).prm_keep_flag := a58(indx);
          t(ddindx).contributor_flag := a59(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t as_access_pub.sales_team_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_300
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_300
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_DATE_TABLE
    , a31 out nocopy JTF_VARCHAR2_TABLE_300
    , a32 out nocopy JTF_DATE_TABLE
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_VARCHAR2_TABLE_200
    , a37 out nocopy JTF_VARCHAR2_TABLE_200
    , a38 out nocopy JTF_VARCHAR2_TABLE_200
    , a39 out nocopy JTF_VARCHAR2_TABLE_200
    , a40 out nocopy JTF_VARCHAR2_TABLE_200
    , a41 out nocopy JTF_VARCHAR2_TABLE_200
    , a42 out nocopy JTF_VARCHAR2_TABLE_200
    , a43 out nocopy JTF_VARCHAR2_TABLE_200
    , a44 out nocopy JTF_VARCHAR2_TABLE_200
    , a45 out nocopy JTF_VARCHAR2_TABLE_200
    , a46 out nocopy JTF_VARCHAR2_TABLE_200
    , a47 out nocopy JTF_VARCHAR2_TABLE_200
    , a48 out nocopy JTF_VARCHAR2_TABLE_200
    , a49 out nocopy JTF_VARCHAR2_TABLE_200
    , a50 out nocopy JTF_VARCHAR2_TABLE_200
    , a51 out nocopy JTF_VARCHAR2_TABLE_100
    , a52 out nocopy JTF_VARCHAR2_TABLE_100
    , a53 out nocopy JTF_VARCHAR2_TABLE_100
    , a54 out nocopy JTF_NUMBER_TABLE
    , a55 out nocopy JTF_NUMBER_TABLE
    , a56 out nocopy JTF_VARCHAR2_TABLE_100
    , a57 out nocopy JTF_VARCHAR2_TABLE_100
    , a58 out nocopy JTF_VARCHAR2_TABLE_100
    , a59 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_DATE_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_300();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_300();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_VARCHAR2_TABLE_100();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_VARCHAR2_TABLE_100();
    a27 := JTF_VARCHAR2_TABLE_100();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_DATE_TABLE();
    a31 := JTF_VARCHAR2_TABLE_300();
    a32 := JTF_DATE_TABLE();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_VARCHAR2_TABLE_100();
    a35 := JTF_VARCHAR2_TABLE_100();
    a36 := JTF_VARCHAR2_TABLE_200();
    a37 := JTF_VARCHAR2_TABLE_200();
    a38 := JTF_VARCHAR2_TABLE_200();
    a39 := JTF_VARCHAR2_TABLE_200();
    a40 := JTF_VARCHAR2_TABLE_200();
    a41 := JTF_VARCHAR2_TABLE_200();
    a42 := JTF_VARCHAR2_TABLE_200();
    a43 := JTF_VARCHAR2_TABLE_200();
    a44 := JTF_VARCHAR2_TABLE_200();
    a45 := JTF_VARCHAR2_TABLE_200();
    a46 := JTF_VARCHAR2_TABLE_200();
    a47 := JTF_VARCHAR2_TABLE_200();
    a48 := JTF_VARCHAR2_TABLE_200();
    a49 := JTF_VARCHAR2_TABLE_200();
    a50 := JTF_VARCHAR2_TABLE_200();
    a51 := JTF_VARCHAR2_TABLE_100();
    a52 := JTF_VARCHAR2_TABLE_100();
    a53 := JTF_VARCHAR2_TABLE_100();
    a54 := JTF_NUMBER_TABLE();
    a55 := JTF_NUMBER_TABLE();
    a56 := JTF_VARCHAR2_TABLE_100();
    a57 := JTF_VARCHAR2_TABLE_100();
    a58 := JTF_VARCHAR2_TABLE_100();
    a59 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_DATE_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_300();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_300();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_VARCHAR2_TABLE_100();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_VARCHAR2_TABLE_100();
      a27 := JTF_VARCHAR2_TABLE_100();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_DATE_TABLE();
      a31 := JTF_VARCHAR2_TABLE_300();
      a32 := JTF_DATE_TABLE();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_VARCHAR2_TABLE_100();
      a35 := JTF_VARCHAR2_TABLE_100();
      a36 := JTF_VARCHAR2_TABLE_200();
      a37 := JTF_VARCHAR2_TABLE_200();
      a38 := JTF_VARCHAR2_TABLE_200();
      a39 := JTF_VARCHAR2_TABLE_200();
      a40 := JTF_VARCHAR2_TABLE_200();
      a41 := JTF_VARCHAR2_TABLE_200();
      a42 := JTF_VARCHAR2_TABLE_200();
      a43 := JTF_VARCHAR2_TABLE_200();
      a44 := JTF_VARCHAR2_TABLE_200();
      a45 := JTF_VARCHAR2_TABLE_200();
      a46 := JTF_VARCHAR2_TABLE_200();
      a47 := JTF_VARCHAR2_TABLE_200();
      a48 := JTF_VARCHAR2_TABLE_200();
      a49 := JTF_VARCHAR2_TABLE_200();
      a50 := JTF_VARCHAR2_TABLE_200();
      a51 := JTF_VARCHAR2_TABLE_100();
      a52 := JTF_VARCHAR2_TABLE_100();
      a53 := JTF_VARCHAR2_TABLE_100();
      a54 := JTF_NUMBER_TABLE();
      a55 := JTF_NUMBER_TABLE();
      a56 := JTF_VARCHAR2_TABLE_100();
      a57 := JTF_VARCHAR2_TABLE_100();
      a58 := JTF_VARCHAR2_TABLE_100();
      a59 := JTF_VARCHAR2_TABLE_100();
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
        a44.extend(t.count);
        a45.extend(t.count);
        a46.extend(t.count);
        a47.extend(t.count);
        a48.extend(t.count);
        a49.extend(t.count);
        a50.extend(t.count);
        a51.extend(t.count);
        a52.extend(t.count);
        a53.extend(t.count);
        a54.extend(t.count);
        a55.extend(t.count);
        a56.extend(t.count);
        a57.extend(t.count);
        a58.extend(t.count);
        a59.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).access_id);
          a1(indx) := t(ddindx).last_update_date;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a3(indx) := t(ddindx).creation_date;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a6(indx) := t(ddindx).freeze_flag;
          a7(indx) := t(ddindx).reassign_flag;
          a8(indx) := t(ddindx).team_leader_flag;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).customer_id);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).address_id);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).salesforce_id);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).person_id);
          a13(indx) := t(ddindx).job_title;
          a14(indx) := t(ddindx).first_name;
          a15(indx) := t(ddindx).last_name;
          a16(indx) := t(ddindx).email_address;
          a17(indx) := t(ddindx).work_telephone;
          a18(indx) := rosetta_g_miss_num_map(t(ddindx).sales_group_id);
          a19(indx) := t(ddindx).sales_group_name;
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).partner_customer_id);
          a21(indx) := rosetta_g_miss_num_map(t(ddindx).partner_address_id);
          a22(indx) := t(ddindx).partner_name;
          a23(indx) := t(ddindx).partner_number;
          a24(indx) := t(ddindx).partner_city;
          a25(indx) := t(ddindx).partner_phone_number;
          a26(indx) := t(ddindx).partner_area_code;
          a27(indx) := t(ddindx).partner_extension;
          a28(indx) := rosetta_g_miss_num_map(t(ddindx).created_person_id);
          a29(indx) := rosetta_g_miss_num_map(t(ddindx).lead_id);
          a30(indx) := t(ddindx).freeze_date;
          a31(indx) := t(ddindx).reassign_reason;
          a32(indx) := t(ddindx).reassign_request_date;
          a33(indx) := rosetta_g_miss_num_map(t(ddindx).reassign_requested_person_id);
          a34(indx) := t(ddindx).downloadable_flag;
          a35(indx) := t(ddindx).attribute_category;
          a36(indx) := t(ddindx).attribute1;
          a37(indx) := t(ddindx).attribute2;
          a38(indx) := t(ddindx).attribute3;
          a39(indx) := t(ddindx).attribute4;
          a40(indx) := t(ddindx).attribute5;
          a41(indx) := t(ddindx).attribute6;
          a42(indx) := t(ddindx).attribute7;
          a43(indx) := t(ddindx).attribute8;
          a44(indx) := t(ddindx).attribute9;
          a45(indx) := t(ddindx).attribute10;
          a46(indx) := t(ddindx).attribute11;
          a47(indx) := t(ddindx).attribute12;
          a48(indx) := t(ddindx).attribute13;
          a49(indx) := t(ddindx).attribute14;
          a50(indx) := t(ddindx).attribute15;
          a51(indx) := t(ddindx).salesforce_role_code;
          a52(indx) := t(ddindx).salesforce_relationship_code;
          a53(indx) := t(ddindx).salesforce_relationship;
          a54(indx) := rosetta_g_miss_num_map(t(ddindx).sales_lead_id);
          a55(indx) := rosetta_g_miss_num_map(t(ddindx).partner_cont_party_id);
          a56(indx) := t(ddindx).owner_flag;
          a57(indx) := t(ddindx).created_by_tap_flag;
          a58(indx) := t(ddindx).prm_keep_flag;
          a59(indx) := t(ddindx).contributor_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure create_salesteam(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_identity_salesforce_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_access_id out nocopy  NUMBER
    , p4_a0  VARCHAR2 := fnd_api.g_miss_char
    , p4_a1  VARCHAR2 := fnd_api.g_miss_char
    , p4_a2  VARCHAR2 := fnd_api.g_miss_char
    , p4_a3  VARCHAR2 := fnd_api.g_miss_char
    , p4_a4  VARCHAR2 := fnd_api.g_miss_char
    , p9_a0  NUMBER := 0-1962.0724
    , p9_a1  DATE := fnd_api.g_miss_date
    , p9_a2  NUMBER := 0-1962.0724
    , p9_a3  DATE := fnd_api.g_miss_date
    , p9_a4  NUMBER := 0-1962.0724
    , p9_a5  NUMBER := 0-1962.0724
    , p9_a6  VARCHAR2 := fnd_api.g_miss_char
    , p9_a7  VARCHAR2 := fnd_api.g_miss_char
    , p9_a8  VARCHAR2 := fnd_api.g_miss_char
    , p9_a9  NUMBER := 0-1962.0724
    , p9_a10  NUMBER := 0-1962.0724
    , p9_a11  NUMBER := 0-1962.0724
    , p9_a12  NUMBER := 0-1962.0724
    , p9_a13  VARCHAR2 := fnd_api.g_miss_char
    , p9_a14  VARCHAR2 := fnd_api.g_miss_char
    , p9_a15  VARCHAR2 := fnd_api.g_miss_char
    , p9_a16  VARCHAR2 := fnd_api.g_miss_char
    , p9_a17  VARCHAR2 := fnd_api.g_miss_char
    , p9_a18  NUMBER := 0-1962.0724
    , p9_a19  VARCHAR2 := fnd_api.g_miss_char
    , p9_a20  NUMBER := 0-1962.0724
    , p9_a21  NUMBER := 0-1962.0724
    , p9_a22  VARCHAR2 := fnd_api.g_miss_char
    , p9_a23  VARCHAR2 := fnd_api.g_miss_char
    , p9_a24  VARCHAR2 := fnd_api.g_miss_char
    , p9_a25  VARCHAR2 := fnd_api.g_miss_char
    , p9_a26  VARCHAR2 := fnd_api.g_miss_char
    , p9_a27  VARCHAR2 := fnd_api.g_miss_char
    , p9_a28  NUMBER := 0-1962.0724
    , p9_a29  NUMBER := 0-1962.0724
    , p9_a30  DATE := fnd_api.g_miss_date
    , p9_a31  VARCHAR2 := fnd_api.g_miss_char
    , p9_a32  DATE := fnd_api.g_miss_date
    , p9_a33  NUMBER := 0-1962.0724
    , p9_a34  VARCHAR2 := fnd_api.g_miss_char
    , p9_a35  VARCHAR2 := fnd_api.g_miss_char
    , p9_a36  VARCHAR2 := fnd_api.g_miss_char
    , p9_a37  VARCHAR2 := fnd_api.g_miss_char
    , p9_a38  VARCHAR2 := fnd_api.g_miss_char
    , p9_a39  VARCHAR2 := fnd_api.g_miss_char
    , p9_a40  VARCHAR2 := fnd_api.g_miss_char
    , p9_a41  VARCHAR2 := fnd_api.g_miss_char
    , p9_a42  VARCHAR2 := fnd_api.g_miss_char
    , p9_a43  VARCHAR2 := fnd_api.g_miss_char
    , p9_a44  VARCHAR2 := fnd_api.g_miss_char
    , p9_a45  VARCHAR2 := fnd_api.g_miss_char
    , p9_a46  VARCHAR2 := fnd_api.g_miss_char
    , p9_a47  VARCHAR2 := fnd_api.g_miss_char
    , p9_a48  VARCHAR2 := fnd_api.g_miss_char
    , p9_a49  VARCHAR2 := fnd_api.g_miss_char
    , p9_a50  VARCHAR2 := fnd_api.g_miss_char
    , p9_a51  VARCHAR2 := fnd_api.g_miss_char
    , p9_a52  VARCHAR2 := fnd_api.g_miss_char
    , p9_a53  VARCHAR2 := fnd_api.g_miss_char
    , p9_a54  NUMBER := 0-1962.0724
    , p9_a55  NUMBER := 0-1962.0724
    , p9_a56  VARCHAR2 := fnd_api.g_miss_char
    , p9_a57  VARCHAR2 := fnd_api.g_miss_char
    , p9_a58  VARCHAR2 := fnd_api.g_miss_char
    , p9_a59  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_access_profile_rec as_access_pub.access_profile_rec_type;
    ddp_sales_team_rec as_access_pub.sales_team_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_access_profile_rec.cust_access_profile_value := p4_a0;
    ddp_access_profile_rec.lead_access_profile_value := p4_a1;
    ddp_access_profile_rec.opp_access_profile_value := p4_a2;
    ddp_access_profile_rec.mgr_update_profile_value := p4_a3;
    ddp_access_profile_rec.admin_update_profile_value := p4_a4;





    ddp_sales_team_rec.access_id := rosetta_g_miss_num_map(p9_a0);
    ddp_sales_team_rec.last_update_date := rosetta_g_miss_date_in_map(p9_a1);
    ddp_sales_team_rec.last_updated_by := rosetta_g_miss_num_map(p9_a2);
    ddp_sales_team_rec.creation_date := rosetta_g_miss_date_in_map(p9_a3);
    ddp_sales_team_rec.created_by := rosetta_g_miss_num_map(p9_a4);
    ddp_sales_team_rec.last_update_login := rosetta_g_miss_num_map(p9_a5);
    ddp_sales_team_rec.freeze_flag := p9_a6;
    ddp_sales_team_rec.reassign_flag := p9_a7;
    ddp_sales_team_rec.team_leader_flag := p9_a8;
    ddp_sales_team_rec.customer_id := rosetta_g_miss_num_map(p9_a9);
    ddp_sales_team_rec.address_id := rosetta_g_miss_num_map(p9_a10);
    ddp_sales_team_rec.salesforce_id := rosetta_g_miss_num_map(p9_a11);
    ddp_sales_team_rec.person_id := rosetta_g_miss_num_map(p9_a12);
    ddp_sales_team_rec.job_title := p9_a13;
    ddp_sales_team_rec.first_name := p9_a14;
    ddp_sales_team_rec.last_name := p9_a15;
    ddp_sales_team_rec.email_address := p9_a16;
    ddp_sales_team_rec.work_telephone := p9_a17;
    ddp_sales_team_rec.sales_group_id := rosetta_g_miss_num_map(p9_a18);
    ddp_sales_team_rec.sales_group_name := p9_a19;
    ddp_sales_team_rec.partner_customer_id := rosetta_g_miss_num_map(p9_a20);
    ddp_sales_team_rec.partner_address_id := rosetta_g_miss_num_map(p9_a21);
    ddp_sales_team_rec.partner_name := p9_a22;
    ddp_sales_team_rec.partner_number := p9_a23;
    ddp_sales_team_rec.partner_city := p9_a24;
    ddp_sales_team_rec.partner_phone_number := p9_a25;
    ddp_sales_team_rec.partner_area_code := p9_a26;
    ddp_sales_team_rec.partner_extension := p9_a27;
    ddp_sales_team_rec.created_person_id := rosetta_g_miss_num_map(p9_a28);
    ddp_sales_team_rec.lead_id := rosetta_g_miss_num_map(p9_a29);
    ddp_sales_team_rec.freeze_date := rosetta_g_miss_date_in_map(p9_a30);
    ddp_sales_team_rec.reassign_reason := p9_a31;
    ddp_sales_team_rec.reassign_request_date := rosetta_g_miss_date_in_map(p9_a32);
    ddp_sales_team_rec.reassign_requested_person_id := rosetta_g_miss_num_map(p9_a33);
    ddp_sales_team_rec.downloadable_flag := p9_a34;
    ddp_sales_team_rec.attribute_category := p9_a35;
    ddp_sales_team_rec.attribute1 := p9_a36;
    ddp_sales_team_rec.attribute2 := p9_a37;
    ddp_sales_team_rec.attribute3 := p9_a38;
    ddp_sales_team_rec.attribute4 := p9_a39;
    ddp_sales_team_rec.attribute5 := p9_a40;
    ddp_sales_team_rec.attribute6 := p9_a41;
    ddp_sales_team_rec.attribute7 := p9_a42;
    ddp_sales_team_rec.attribute8 := p9_a43;
    ddp_sales_team_rec.attribute9 := p9_a44;
    ddp_sales_team_rec.attribute10 := p9_a45;
    ddp_sales_team_rec.attribute11 := p9_a46;
    ddp_sales_team_rec.attribute12 := p9_a47;
    ddp_sales_team_rec.attribute13 := p9_a48;
    ddp_sales_team_rec.attribute14 := p9_a49;
    ddp_sales_team_rec.attribute15 := p9_a50;
    ddp_sales_team_rec.salesforce_role_code := p9_a51;
    ddp_sales_team_rec.salesforce_relationship_code := p9_a52;
    ddp_sales_team_rec.salesforce_relationship := p9_a53;
    ddp_sales_team_rec.sales_lead_id := rosetta_g_miss_num_map(p9_a54);
    ddp_sales_team_rec.partner_cont_party_id := rosetta_g_miss_num_map(p9_a55);
    ddp_sales_team_rec.owner_flag := p9_a56;
    ddp_sales_team_rec.created_by_tap_flag := p9_a57;
    ddp_sales_team_rec.prm_keep_flag := p9_a58;
    ddp_sales_team_rec.contributor_flag := p9_a59;





    -- here's the delegated call to the old PL/SQL routine
    as_access_pub.create_salesteam(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_access_profile_rec,
      p_check_access_flag,
      p_admin_flag,
      p_admin_group_id,
      p_identity_salesforce_id,
      ddp_sales_team_rec,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_access_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













  end;

  procedure update_salesteam(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_identity_salesforce_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_access_id out nocopy  NUMBER
    , p4_a0  VARCHAR2 := fnd_api.g_miss_char
    , p4_a1  VARCHAR2 := fnd_api.g_miss_char
    , p4_a2  VARCHAR2 := fnd_api.g_miss_char
    , p4_a3  VARCHAR2 := fnd_api.g_miss_char
    , p4_a4  VARCHAR2 := fnd_api.g_miss_char
    , p9_a0  NUMBER := 0-1962.0724
    , p9_a1  DATE := fnd_api.g_miss_date
    , p9_a2  NUMBER := 0-1962.0724
    , p9_a3  DATE := fnd_api.g_miss_date
    , p9_a4  NUMBER := 0-1962.0724
    , p9_a5  NUMBER := 0-1962.0724
    , p9_a6  VARCHAR2 := fnd_api.g_miss_char
    , p9_a7  VARCHAR2 := fnd_api.g_miss_char
    , p9_a8  VARCHAR2 := fnd_api.g_miss_char
    , p9_a9  NUMBER := 0-1962.0724
    , p9_a10  NUMBER := 0-1962.0724
    , p9_a11  NUMBER := 0-1962.0724
    , p9_a12  NUMBER := 0-1962.0724
    , p9_a13  VARCHAR2 := fnd_api.g_miss_char
    , p9_a14  VARCHAR2 := fnd_api.g_miss_char
    , p9_a15  VARCHAR2 := fnd_api.g_miss_char
    , p9_a16  VARCHAR2 := fnd_api.g_miss_char
    , p9_a17  VARCHAR2 := fnd_api.g_miss_char
    , p9_a18  NUMBER := 0-1962.0724
    , p9_a19  VARCHAR2 := fnd_api.g_miss_char
    , p9_a20  NUMBER := 0-1962.0724
    , p9_a21  NUMBER := 0-1962.0724
    , p9_a22  VARCHAR2 := fnd_api.g_miss_char
    , p9_a23  VARCHAR2 := fnd_api.g_miss_char
    , p9_a24  VARCHAR2 := fnd_api.g_miss_char
    , p9_a25  VARCHAR2 := fnd_api.g_miss_char
    , p9_a26  VARCHAR2 := fnd_api.g_miss_char
    , p9_a27  VARCHAR2 := fnd_api.g_miss_char
    , p9_a28  NUMBER := 0-1962.0724
    , p9_a29  NUMBER := 0-1962.0724
    , p9_a30  DATE := fnd_api.g_miss_date
    , p9_a31  VARCHAR2 := fnd_api.g_miss_char
    , p9_a32  DATE := fnd_api.g_miss_date
    , p9_a33  NUMBER := 0-1962.0724
    , p9_a34  VARCHAR2 := fnd_api.g_miss_char
    , p9_a35  VARCHAR2 := fnd_api.g_miss_char
    , p9_a36  VARCHAR2 := fnd_api.g_miss_char
    , p9_a37  VARCHAR2 := fnd_api.g_miss_char
    , p9_a38  VARCHAR2 := fnd_api.g_miss_char
    , p9_a39  VARCHAR2 := fnd_api.g_miss_char
    , p9_a40  VARCHAR2 := fnd_api.g_miss_char
    , p9_a41  VARCHAR2 := fnd_api.g_miss_char
    , p9_a42  VARCHAR2 := fnd_api.g_miss_char
    , p9_a43  VARCHAR2 := fnd_api.g_miss_char
    , p9_a44  VARCHAR2 := fnd_api.g_miss_char
    , p9_a45  VARCHAR2 := fnd_api.g_miss_char
    , p9_a46  VARCHAR2 := fnd_api.g_miss_char
    , p9_a47  VARCHAR2 := fnd_api.g_miss_char
    , p9_a48  VARCHAR2 := fnd_api.g_miss_char
    , p9_a49  VARCHAR2 := fnd_api.g_miss_char
    , p9_a50  VARCHAR2 := fnd_api.g_miss_char
    , p9_a51  VARCHAR2 := fnd_api.g_miss_char
    , p9_a52  VARCHAR2 := fnd_api.g_miss_char
    , p9_a53  VARCHAR2 := fnd_api.g_miss_char
    , p9_a54  NUMBER := 0-1962.0724
    , p9_a55  NUMBER := 0-1962.0724
    , p9_a56  VARCHAR2 := fnd_api.g_miss_char
    , p9_a57  VARCHAR2 := fnd_api.g_miss_char
    , p9_a58  VARCHAR2 := fnd_api.g_miss_char
    , p9_a59  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_access_profile_rec as_access_pub.access_profile_rec_type;
    ddp_sales_team_rec as_access_pub.sales_team_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_access_profile_rec.cust_access_profile_value := p4_a0;
    ddp_access_profile_rec.lead_access_profile_value := p4_a1;
    ddp_access_profile_rec.opp_access_profile_value := p4_a2;
    ddp_access_profile_rec.mgr_update_profile_value := p4_a3;
    ddp_access_profile_rec.admin_update_profile_value := p4_a4;





    ddp_sales_team_rec.access_id := rosetta_g_miss_num_map(p9_a0);
    ddp_sales_team_rec.last_update_date := rosetta_g_miss_date_in_map(p9_a1);
    ddp_sales_team_rec.last_updated_by := rosetta_g_miss_num_map(p9_a2);
    ddp_sales_team_rec.creation_date := rosetta_g_miss_date_in_map(p9_a3);
    ddp_sales_team_rec.created_by := rosetta_g_miss_num_map(p9_a4);
    ddp_sales_team_rec.last_update_login := rosetta_g_miss_num_map(p9_a5);
    ddp_sales_team_rec.freeze_flag := p9_a6;
    ddp_sales_team_rec.reassign_flag := p9_a7;
    ddp_sales_team_rec.team_leader_flag := p9_a8;
    ddp_sales_team_rec.customer_id := rosetta_g_miss_num_map(p9_a9);
    ddp_sales_team_rec.address_id := rosetta_g_miss_num_map(p9_a10);
    ddp_sales_team_rec.salesforce_id := rosetta_g_miss_num_map(p9_a11);
    ddp_sales_team_rec.person_id := rosetta_g_miss_num_map(p9_a12);
    ddp_sales_team_rec.job_title := p9_a13;
    ddp_sales_team_rec.first_name := p9_a14;
    ddp_sales_team_rec.last_name := p9_a15;
    ddp_sales_team_rec.email_address := p9_a16;
    ddp_sales_team_rec.work_telephone := p9_a17;
    ddp_sales_team_rec.sales_group_id := rosetta_g_miss_num_map(p9_a18);
    ddp_sales_team_rec.sales_group_name := p9_a19;
    ddp_sales_team_rec.partner_customer_id := rosetta_g_miss_num_map(p9_a20);
    ddp_sales_team_rec.partner_address_id := rosetta_g_miss_num_map(p9_a21);
    ddp_sales_team_rec.partner_name := p9_a22;
    ddp_sales_team_rec.partner_number := p9_a23;
    ddp_sales_team_rec.partner_city := p9_a24;
    ddp_sales_team_rec.partner_phone_number := p9_a25;
    ddp_sales_team_rec.partner_area_code := p9_a26;
    ddp_sales_team_rec.partner_extension := p9_a27;
    ddp_sales_team_rec.created_person_id := rosetta_g_miss_num_map(p9_a28);
    ddp_sales_team_rec.lead_id := rosetta_g_miss_num_map(p9_a29);
    ddp_sales_team_rec.freeze_date := rosetta_g_miss_date_in_map(p9_a30);
    ddp_sales_team_rec.reassign_reason := p9_a31;
    ddp_sales_team_rec.reassign_request_date := rosetta_g_miss_date_in_map(p9_a32);
    ddp_sales_team_rec.reassign_requested_person_id := rosetta_g_miss_num_map(p9_a33);
    ddp_sales_team_rec.downloadable_flag := p9_a34;
    ddp_sales_team_rec.attribute_category := p9_a35;
    ddp_sales_team_rec.attribute1 := p9_a36;
    ddp_sales_team_rec.attribute2 := p9_a37;
    ddp_sales_team_rec.attribute3 := p9_a38;
    ddp_sales_team_rec.attribute4 := p9_a39;
    ddp_sales_team_rec.attribute5 := p9_a40;
    ddp_sales_team_rec.attribute6 := p9_a41;
    ddp_sales_team_rec.attribute7 := p9_a42;
    ddp_sales_team_rec.attribute8 := p9_a43;
    ddp_sales_team_rec.attribute9 := p9_a44;
    ddp_sales_team_rec.attribute10 := p9_a45;
    ddp_sales_team_rec.attribute11 := p9_a46;
    ddp_sales_team_rec.attribute12 := p9_a47;
    ddp_sales_team_rec.attribute13 := p9_a48;
    ddp_sales_team_rec.attribute14 := p9_a49;
    ddp_sales_team_rec.attribute15 := p9_a50;
    ddp_sales_team_rec.salesforce_role_code := p9_a51;
    ddp_sales_team_rec.salesforce_relationship_code := p9_a52;
    ddp_sales_team_rec.salesforce_relationship := p9_a53;
    ddp_sales_team_rec.sales_lead_id := rosetta_g_miss_num_map(p9_a54);
    ddp_sales_team_rec.partner_cont_party_id := rosetta_g_miss_num_map(p9_a55);
    ddp_sales_team_rec.owner_flag := p9_a56;
    ddp_sales_team_rec.created_by_tap_flag := p9_a57;
    ddp_sales_team_rec.prm_keep_flag := p9_a58;
    ddp_sales_team_rec.contributor_flag := p9_a59;





    -- here's the delegated call to the old PL/SQL routine
    as_access_pub.update_salesteam(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_access_profile_rec,
      p_check_access_flag,
      p_admin_flag,
      p_admin_group_id,
      p_identity_salesforce_id,
      ddp_sales_team_rec,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_access_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













  end;

  procedure delete_salesteam(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_identity_salesforce_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  VARCHAR2 := fnd_api.g_miss_char
    , p4_a1  VARCHAR2 := fnd_api.g_miss_char
    , p4_a2  VARCHAR2 := fnd_api.g_miss_char
    , p4_a3  VARCHAR2 := fnd_api.g_miss_char
    , p4_a4  VARCHAR2 := fnd_api.g_miss_char
    , p9_a0  NUMBER := 0-1962.0724
    , p9_a1  DATE := fnd_api.g_miss_date
    , p9_a2  NUMBER := 0-1962.0724
    , p9_a3  DATE := fnd_api.g_miss_date
    , p9_a4  NUMBER := 0-1962.0724
    , p9_a5  NUMBER := 0-1962.0724
    , p9_a6  VARCHAR2 := fnd_api.g_miss_char
    , p9_a7  VARCHAR2 := fnd_api.g_miss_char
    , p9_a8  VARCHAR2 := fnd_api.g_miss_char
    , p9_a9  NUMBER := 0-1962.0724
    , p9_a10  NUMBER := 0-1962.0724
    , p9_a11  NUMBER := 0-1962.0724
    , p9_a12  NUMBER := 0-1962.0724
    , p9_a13  VARCHAR2 := fnd_api.g_miss_char
    , p9_a14  VARCHAR2 := fnd_api.g_miss_char
    , p9_a15  VARCHAR2 := fnd_api.g_miss_char
    , p9_a16  VARCHAR2 := fnd_api.g_miss_char
    , p9_a17  VARCHAR2 := fnd_api.g_miss_char
    , p9_a18  NUMBER := 0-1962.0724
    , p9_a19  VARCHAR2 := fnd_api.g_miss_char
    , p9_a20  NUMBER := 0-1962.0724
    , p9_a21  NUMBER := 0-1962.0724
    , p9_a22  VARCHAR2 := fnd_api.g_miss_char
    , p9_a23  VARCHAR2 := fnd_api.g_miss_char
    , p9_a24  VARCHAR2 := fnd_api.g_miss_char
    , p9_a25  VARCHAR2 := fnd_api.g_miss_char
    , p9_a26  VARCHAR2 := fnd_api.g_miss_char
    , p9_a27  VARCHAR2 := fnd_api.g_miss_char
    , p9_a28  NUMBER := 0-1962.0724
    , p9_a29  NUMBER := 0-1962.0724
    , p9_a30  DATE := fnd_api.g_miss_date
    , p9_a31  VARCHAR2 := fnd_api.g_miss_char
    , p9_a32  DATE := fnd_api.g_miss_date
    , p9_a33  NUMBER := 0-1962.0724
    , p9_a34  VARCHAR2 := fnd_api.g_miss_char
    , p9_a35  VARCHAR2 := fnd_api.g_miss_char
    , p9_a36  VARCHAR2 := fnd_api.g_miss_char
    , p9_a37  VARCHAR2 := fnd_api.g_miss_char
    , p9_a38  VARCHAR2 := fnd_api.g_miss_char
    , p9_a39  VARCHAR2 := fnd_api.g_miss_char
    , p9_a40  VARCHAR2 := fnd_api.g_miss_char
    , p9_a41  VARCHAR2 := fnd_api.g_miss_char
    , p9_a42  VARCHAR2 := fnd_api.g_miss_char
    , p9_a43  VARCHAR2 := fnd_api.g_miss_char
    , p9_a44  VARCHAR2 := fnd_api.g_miss_char
    , p9_a45  VARCHAR2 := fnd_api.g_miss_char
    , p9_a46  VARCHAR2 := fnd_api.g_miss_char
    , p9_a47  VARCHAR2 := fnd_api.g_miss_char
    , p9_a48  VARCHAR2 := fnd_api.g_miss_char
    , p9_a49  VARCHAR2 := fnd_api.g_miss_char
    , p9_a50  VARCHAR2 := fnd_api.g_miss_char
    , p9_a51  VARCHAR2 := fnd_api.g_miss_char
    , p9_a52  VARCHAR2 := fnd_api.g_miss_char
    , p9_a53  VARCHAR2 := fnd_api.g_miss_char
    , p9_a54  NUMBER := 0-1962.0724
    , p9_a55  NUMBER := 0-1962.0724
    , p9_a56  VARCHAR2 := fnd_api.g_miss_char
    , p9_a57  VARCHAR2 := fnd_api.g_miss_char
    , p9_a58  VARCHAR2 := fnd_api.g_miss_char
    , p9_a59  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_access_profile_rec as_access_pub.access_profile_rec_type;
    ddp_sales_team_rec as_access_pub.sales_team_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_access_profile_rec.cust_access_profile_value := p4_a0;
    ddp_access_profile_rec.lead_access_profile_value := p4_a1;
    ddp_access_profile_rec.opp_access_profile_value := p4_a2;
    ddp_access_profile_rec.mgr_update_profile_value := p4_a3;
    ddp_access_profile_rec.admin_update_profile_value := p4_a4;





    ddp_sales_team_rec.access_id := rosetta_g_miss_num_map(p9_a0);
    ddp_sales_team_rec.last_update_date := rosetta_g_miss_date_in_map(p9_a1);
    ddp_sales_team_rec.last_updated_by := rosetta_g_miss_num_map(p9_a2);
    ddp_sales_team_rec.creation_date := rosetta_g_miss_date_in_map(p9_a3);
    ddp_sales_team_rec.created_by := rosetta_g_miss_num_map(p9_a4);
    ddp_sales_team_rec.last_update_login := rosetta_g_miss_num_map(p9_a5);
    ddp_sales_team_rec.freeze_flag := p9_a6;
    ddp_sales_team_rec.reassign_flag := p9_a7;
    ddp_sales_team_rec.team_leader_flag := p9_a8;
    ddp_sales_team_rec.customer_id := rosetta_g_miss_num_map(p9_a9);
    ddp_sales_team_rec.address_id := rosetta_g_miss_num_map(p9_a10);
    ddp_sales_team_rec.salesforce_id := rosetta_g_miss_num_map(p9_a11);
    ddp_sales_team_rec.person_id := rosetta_g_miss_num_map(p9_a12);
    ddp_sales_team_rec.job_title := p9_a13;
    ddp_sales_team_rec.first_name := p9_a14;
    ddp_sales_team_rec.last_name := p9_a15;
    ddp_sales_team_rec.email_address := p9_a16;
    ddp_sales_team_rec.work_telephone := p9_a17;
    ddp_sales_team_rec.sales_group_id := rosetta_g_miss_num_map(p9_a18);
    ddp_sales_team_rec.sales_group_name := p9_a19;
    ddp_sales_team_rec.partner_customer_id := rosetta_g_miss_num_map(p9_a20);
    ddp_sales_team_rec.partner_address_id := rosetta_g_miss_num_map(p9_a21);
    ddp_sales_team_rec.partner_name := p9_a22;
    ddp_sales_team_rec.partner_number := p9_a23;
    ddp_sales_team_rec.partner_city := p9_a24;
    ddp_sales_team_rec.partner_phone_number := p9_a25;
    ddp_sales_team_rec.partner_area_code := p9_a26;
    ddp_sales_team_rec.partner_extension := p9_a27;
    ddp_sales_team_rec.created_person_id := rosetta_g_miss_num_map(p9_a28);
    ddp_sales_team_rec.lead_id := rosetta_g_miss_num_map(p9_a29);
    ddp_sales_team_rec.freeze_date := rosetta_g_miss_date_in_map(p9_a30);
    ddp_sales_team_rec.reassign_reason := p9_a31;
    ddp_sales_team_rec.reassign_request_date := rosetta_g_miss_date_in_map(p9_a32);
    ddp_sales_team_rec.reassign_requested_person_id := rosetta_g_miss_num_map(p9_a33);
    ddp_sales_team_rec.downloadable_flag := p9_a34;
    ddp_sales_team_rec.attribute_category := p9_a35;
    ddp_sales_team_rec.attribute1 := p9_a36;
    ddp_sales_team_rec.attribute2 := p9_a37;
    ddp_sales_team_rec.attribute3 := p9_a38;
    ddp_sales_team_rec.attribute4 := p9_a39;
    ddp_sales_team_rec.attribute5 := p9_a40;
    ddp_sales_team_rec.attribute6 := p9_a41;
    ddp_sales_team_rec.attribute7 := p9_a42;
    ddp_sales_team_rec.attribute8 := p9_a43;
    ddp_sales_team_rec.attribute9 := p9_a44;
    ddp_sales_team_rec.attribute10 := p9_a45;
    ddp_sales_team_rec.attribute11 := p9_a46;
    ddp_sales_team_rec.attribute12 := p9_a47;
    ddp_sales_team_rec.attribute13 := p9_a48;
    ddp_sales_team_rec.attribute14 := p9_a49;
    ddp_sales_team_rec.attribute15 := p9_a50;
    ddp_sales_team_rec.salesforce_role_code := p9_a51;
    ddp_sales_team_rec.salesforce_relationship_code := p9_a52;
    ddp_sales_team_rec.salesforce_relationship := p9_a53;
    ddp_sales_team_rec.sales_lead_id := rosetta_g_miss_num_map(p9_a54);
    ddp_sales_team_rec.partner_cont_party_id := rosetta_g_miss_num_map(p9_a55);
    ddp_sales_team_rec.owner_flag := p9_a56;
    ddp_sales_team_rec.created_by_tap_flag := p9_a57;
    ddp_sales_team_rec.prm_keep_flag := p9_a58;
    ddp_sales_team_rec.contributor_flag := p9_a59;




    -- here's the delegated call to the old PL/SQL routine
    as_access_pub.delete_salesteam(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_access_profile_rec,
      p_check_access_flag,
      p_admin_flag,
      p_admin_group_id,
      p_identity_salesforce_id,
      ddp_sales_team_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












  end;

  procedure validate_accessprofiles(p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  VARCHAR2 := fnd_api.g_miss_char
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  VARCHAR2 := fnd_api.g_miss_char
    , p1_a3  VARCHAR2 := fnd_api.g_miss_char
    , p1_a4  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_access_profile_rec as_access_pub.access_profile_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_access_profile_rec.cust_access_profile_value := p1_a0;
    ddp_access_profile_rec.lead_access_profile_value := p1_a1;
    ddp_access_profile_rec.opp_access_profile_value := p1_a2;
    ddp_access_profile_rec.mgr_update_profile_value := p1_a3;
    ddp_access_profile_rec.admin_update_profile_value := p1_a4;




    -- here's the delegated call to the old PL/SQL routine
    as_access_pub.validate_accessprofiles(p_init_msg_list,
      ddp_access_profile_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




  end;

  procedure has_viewcustomeraccess(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_person_id  NUMBER
    , p_customer_id  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_identity_salesforce_id  NUMBER
    , p_partner_cont_party_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_view_access_flag out nocopy  VARCHAR2
    , p3_a0  VARCHAR2 := fnd_api.g_miss_char
    , p3_a1  VARCHAR2 := fnd_api.g_miss_char
    , p3_a2  VARCHAR2 := fnd_api.g_miss_char
    , p3_a3  VARCHAR2 := fnd_api.g_miss_char
    , p3_a4  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_access_profile_rec as_access_pub.access_profile_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_access_profile_rec.cust_access_profile_value := p3_a0;
    ddp_access_profile_rec.lead_access_profile_value := p3_a1;
    ddp_access_profile_rec.opp_access_profile_value := p3_a2;
    ddp_access_profile_rec.mgr_update_profile_value := p3_a3;
    ddp_access_profile_rec.admin_update_profile_value := p3_a4;












    -- here's the delegated call to the old PL/SQL routine
    as_access_pub.has_viewcustomeraccess(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_access_profile_rec,
      p_admin_flag,
      p_admin_group_id,
      p_person_id,
      p_customer_id,
      p_check_access_flag,
      p_identity_salesforce_id,
      p_partner_cont_party_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_view_access_flag);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














  end;

  procedure has_updatecustomeraccess(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_person_id  NUMBER
    , p_customer_id  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_identity_salesforce_id  NUMBER
    , p_partner_cont_party_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_update_access_flag out nocopy  VARCHAR2
    , p3_a0  VARCHAR2 := fnd_api.g_miss_char
    , p3_a1  VARCHAR2 := fnd_api.g_miss_char
    , p3_a2  VARCHAR2 := fnd_api.g_miss_char
    , p3_a3  VARCHAR2 := fnd_api.g_miss_char
    , p3_a4  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_access_profile_rec as_access_pub.access_profile_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_access_profile_rec.cust_access_profile_value := p3_a0;
    ddp_access_profile_rec.lead_access_profile_value := p3_a1;
    ddp_access_profile_rec.opp_access_profile_value := p3_a2;
    ddp_access_profile_rec.mgr_update_profile_value := p3_a3;
    ddp_access_profile_rec.admin_update_profile_value := p3_a4;












    -- here's the delegated call to the old PL/SQL routine
    as_access_pub.has_updatecustomeraccess(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_access_profile_rec,
      p_admin_flag,
      p_admin_group_id,
      p_person_id,
      p_customer_id,
      p_check_access_flag,
      p_identity_salesforce_id,
      p_partner_cont_party_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_update_access_flag);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














  end;

  procedure has_updateleadaccess(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_person_id  NUMBER
    , p_sales_lead_id  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_identity_salesforce_id  NUMBER
    , p_partner_cont_party_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_update_access_flag out nocopy  VARCHAR2
    , p3_a0  VARCHAR2 := fnd_api.g_miss_char
    , p3_a1  VARCHAR2 := fnd_api.g_miss_char
    , p3_a2  VARCHAR2 := fnd_api.g_miss_char
    , p3_a3  VARCHAR2 := fnd_api.g_miss_char
    , p3_a4  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_access_profile_rec as_access_pub.access_profile_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_access_profile_rec.cust_access_profile_value := p3_a0;
    ddp_access_profile_rec.lead_access_profile_value := p3_a1;
    ddp_access_profile_rec.opp_access_profile_value := p3_a2;
    ddp_access_profile_rec.mgr_update_profile_value := p3_a3;
    ddp_access_profile_rec.admin_update_profile_value := p3_a4;












    -- here's the delegated call to the old PL/SQL routine
    as_access_pub.has_updateleadaccess(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_access_profile_rec,
      p_admin_flag,
      p_admin_group_id,
      p_person_id,
      p_sales_lead_id,
      p_check_access_flag,
      p_identity_salesforce_id,
      p_partner_cont_party_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_update_access_flag);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














  end;

  procedure has_updateopportunityaccess(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_person_id  NUMBER
    , p_opportunity_id  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_identity_salesforce_id  NUMBER
    , p_partner_cont_party_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_update_access_flag out nocopy  VARCHAR2
    , p3_a0  VARCHAR2 := fnd_api.g_miss_char
    , p3_a1  VARCHAR2 := fnd_api.g_miss_char
    , p3_a2  VARCHAR2 := fnd_api.g_miss_char
    , p3_a3  VARCHAR2 := fnd_api.g_miss_char
    , p3_a4  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_access_profile_rec as_access_pub.access_profile_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_access_profile_rec.cust_access_profile_value := p3_a0;
    ddp_access_profile_rec.lead_access_profile_value := p3_a1;
    ddp_access_profile_rec.opp_access_profile_value := p3_a2;
    ddp_access_profile_rec.mgr_update_profile_value := p3_a3;
    ddp_access_profile_rec.admin_update_profile_value := p3_a4;












    -- here's the delegated call to the old PL/SQL routine
    as_access_pub.has_updateopportunityaccess(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_access_profile_rec,
      p_admin_flag,
      p_admin_group_id,
      p_person_id,
      p_opportunity_id,
      p_check_access_flag,
      p_identity_salesforce_id,
      p_partner_cont_party_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_update_access_flag);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














  end;

  procedure has_updatepersonaccess(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_person_id  NUMBER
    , p_security_id  NUMBER
    , p_security_type  VARCHAR2
    , p_person_party_id  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_identity_salesforce_id  NUMBER
    , p_partner_cont_party_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_update_access_flag out nocopy  VARCHAR2
    , p3_a0  VARCHAR2 := fnd_api.g_miss_char
    , p3_a1  VARCHAR2 := fnd_api.g_miss_char
    , p3_a2  VARCHAR2 := fnd_api.g_miss_char
    , p3_a3  VARCHAR2 := fnd_api.g_miss_char
    , p3_a4  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_access_profile_rec as_access_pub.access_profile_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_access_profile_rec.cust_access_profile_value := p3_a0;
    ddp_access_profile_rec.lead_access_profile_value := p3_a1;
    ddp_access_profile_rec.opp_access_profile_value := p3_a2;
    ddp_access_profile_rec.mgr_update_profile_value := p3_a3;
    ddp_access_profile_rec.admin_update_profile_value := p3_a4;














    -- here's the delegated call to the old PL/SQL routine
    as_access_pub.has_updatepersonaccess(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_access_profile_rec,
      p_admin_flag,
      p_admin_group_id,
      p_person_id,
      p_security_id,
      p_security_type,
      p_person_party_id,
      p_check_access_flag,
      p_identity_salesforce_id,
      p_partner_cont_party_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_update_access_flag);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
















  end;

  procedure has_viewpersonaccess(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_person_id  NUMBER
    , p_security_id  NUMBER
    , p_security_type  VARCHAR2
    , p_person_party_id  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_identity_salesforce_id  NUMBER
    , p_partner_cont_party_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_view_access_flag out nocopy  VARCHAR2
    , p3_a0  VARCHAR2 := fnd_api.g_miss_char
    , p3_a1  VARCHAR2 := fnd_api.g_miss_char
    , p3_a2  VARCHAR2 := fnd_api.g_miss_char
    , p3_a3  VARCHAR2 := fnd_api.g_miss_char
    , p3_a4  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_access_profile_rec as_access_pub.access_profile_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_access_profile_rec.cust_access_profile_value := p3_a0;
    ddp_access_profile_rec.lead_access_profile_value := p3_a1;
    ddp_access_profile_rec.opp_access_profile_value := p3_a2;
    ddp_access_profile_rec.mgr_update_profile_value := p3_a3;
    ddp_access_profile_rec.admin_update_profile_value := p3_a4;














    -- here's the delegated call to the old PL/SQL routine
    as_access_pub.has_viewpersonaccess(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_access_profile_rec,
      p_admin_flag,
      p_admin_group_id,
      p_person_id,
      p_security_id,
      p_security_type,
      p_person_party_id,
      p_check_access_flag,
      p_identity_salesforce_id,
      p_partner_cont_party_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_view_access_flag);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
















  end;

  procedure has_viewleadaccess(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_person_id  NUMBER
    , p_sales_lead_id  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_identity_salesforce_id  NUMBER
    , p_partner_cont_party_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_view_access_flag out nocopy  VARCHAR2
    , p3_a0  VARCHAR2 := fnd_api.g_miss_char
    , p3_a1  VARCHAR2 := fnd_api.g_miss_char
    , p3_a2  VARCHAR2 := fnd_api.g_miss_char
    , p3_a3  VARCHAR2 := fnd_api.g_miss_char
    , p3_a4  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_access_profile_rec as_access_pub.access_profile_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_access_profile_rec.cust_access_profile_value := p3_a0;
    ddp_access_profile_rec.lead_access_profile_value := p3_a1;
    ddp_access_profile_rec.opp_access_profile_value := p3_a2;
    ddp_access_profile_rec.mgr_update_profile_value := p3_a3;
    ddp_access_profile_rec.admin_update_profile_value := p3_a4;












    -- here's the delegated call to the old PL/SQL routine
    as_access_pub.has_viewleadaccess(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_access_profile_rec,
      p_admin_flag,
      p_admin_group_id,
      p_person_id,
      p_sales_lead_id,
      p_check_access_flag,
      p_identity_salesforce_id,
      p_partner_cont_party_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_view_access_flag);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














  end;

  procedure has_viewopportunityaccess(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_person_id  NUMBER
    , p_opportunity_id  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_identity_salesforce_id  NUMBER
    , p_partner_cont_party_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_view_access_flag out nocopy  VARCHAR2
    , p3_a0  VARCHAR2 := fnd_api.g_miss_char
    , p3_a1  VARCHAR2 := fnd_api.g_miss_char
    , p3_a2  VARCHAR2 := fnd_api.g_miss_char
    , p3_a3  VARCHAR2 := fnd_api.g_miss_char
    , p3_a4  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_access_profile_rec as_access_pub.access_profile_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_access_profile_rec.cust_access_profile_value := p3_a0;
    ddp_access_profile_rec.lead_access_profile_value := p3_a1;
    ddp_access_profile_rec.opp_access_profile_value := p3_a2;
    ddp_access_profile_rec.mgr_update_profile_value := p3_a3;
    ddp_access_profile_rec.admin_update_profile_value := p3_a4;












    -- here's the delegated call to the old PL/SQL routine
    as_access_pub.has_viewopportunityaccess(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_access_profile_rec,
      p_admin_flag,
      p_admin_group_id,
      p_person_id,
      p_opportunity_id,
      p_check_access_flag,
      p_identity_salesforce_id,
      p_partner_cont_party_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_view_access_flag);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














  end;

  procedure has_organizationaccess(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_person_id  NUMBER
    , p_customer_id  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_identity_salesforce_id  NUMBER
    , p_partner_cont_party_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_access_privilege out nocopy  VARCHAR2
    , p3_a0  VARCHAR2 := fnd_api.g_miss_char
    , p3_a1  VARCHAR2 := fnd_api.g_miss_char
    , p3_a2  VARCHAR2 := fnd_api.g_miss_char
    , p3_a3  VARCHAR2 := fnd_api.g_miss_char
    , p3_a4  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_access_profile_rec as_access_pub.access_profile_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_access_profile_rec.cust_access_profile_value := p3_a0;
    ddp_access_profile_rec.lead_access_profile_value := p3_a1;
    ddp_access_profile_rec.opp_access_profile_value := p3_a2;
    ddp_access_profile_rec.mgr_update_profile_value := p3_a3;
    ddp_access_profile_rec.admin_update_profile_value := p3_a4;












    -- here's the delegated call to the old PL/SQL routine
    as_access_pub.has_organizationaccess(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_access_profile_rec,
      p_admin_flag,
      p_admin_group_id,
      p_person_id,
      p_customer_id,
      p_check_access_flag,
      p_identity_salesforce_id,
      p_partner_cont_party_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_access_privilege);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














  end;

  procedure has_personaccess(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_person_id  NUMBER
    , p_security_id  NUMBER
    , p_security_type  VARCHAR2
    , p_person_party_id  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_identity_salesforce_id  NUMBER
    , p_partner_cont_party_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_access_privilege out nocopy  VARCHAR2
    , p3_a0  VARCHAR2 := fnd_api.g_miss_char
    , p3_a1  VARCHAR2 := fnd_api.g_miss_char
    , p3_a2  VARCHAR2 := fnd_api.g_miss_char
    , p3_a3  VARCHAR2 := fnd_api.g_miss_char
    , p3_a4  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_access_profile_rec as_access_pub.access_profile_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_access_profile_rec.cust_access_profile_value := p3_a0;
    ddp_access_profile_rec.lead_access_profile_value := p3_a1;
    ddp_access_profile_rec.opp_access_profile_value := p3_a2;
    ddp_access_profile_rec.mgr_update_profile_value := p3_a3;
    ddp_access_profile_rec.admin_update_profile_value := p3_a4;














    -- here's the delegated call to the old PL/SQL routine
    as_access_pub.has_personaccess(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_access_profile_rec,
      p_admin_flag,
      p_admin_group_id,
      p_person_id,
      p_security_id,
      p_security_type,
      p_person_party_id,
      p_check_access_flag,
      p_identity_salesforce_id,
      p_partner_cont_party_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_access_privilege);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
















  end;

  procedure has_leadaccess(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_person_id  NUMBER
    , p_sales_lead_id  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_identity_salesforce_id  NUMBER
    , p_partner_cont_party_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_access_privilege out nocopy  VARCHAR2
    , p3_a0  VARCHAR2 := fnd_api.g_miss_char
    , p3_a1  VARCHAR2 := fnd_api.g_miss_char
    , p3_a2  VARCHAR2 := fnd_api.g_miss_char
    , p3_a3  VARCHAR2 := fnd_api.g_miss_char
    , p3_a4  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_access_profile_rec as_access_pub.access_profile_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_access_profile_rec.cust_access_profile_value := p3_a0;
    ddp_access_profile_rec.lead_access_profile_value := p3_a1;
    ddp_access_profile_rec.opp_access_profile_value := p3_a2;
    ddp_access_profile_rec.mgr_update_profile_value := p3_a3;
    ddp_access_profile_rec.admin_update_profile_value := p3_a4;












    -- here's the delegated call to the old PL/SQL routine
    as_access_pub.has_leadaccess(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_access_profile_rec,
      p_admin_flag,
      p_admin_group_id,
      p_person_id,
      p_sales_lead_id,
      p_check_access_flag,
      p_identity_salesforce_id,
      p_partner_cont_party_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_access_privilege);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














  end;

  procedure has_opportunityaccess(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_person_id  NUMBER
    , p_opportunity_id  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_identity_salesforce_id  NUMBER
    , p_partner_cont_party_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_access_privilege out nocopy  VARCHAR2
    , p3_a0  VARCHAR2 := fnd_api.g_miss_char
    , p3_a1  VARCHAR2 := fnd_api.g_miss_char
    , p3_a2  VARCHAR2 := fnd_api.g_miss_char
    , p3_a3  VARCHAR2 := fnd_api.g_miss_char
    , p3_a4  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_access_profile_rec as_access_pub.access_profile_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_access_profile_rec.cust_access_profile_value := p3_a0;
    ddp_access_profile_rec.lead_access_profile_value := p3_a1;
    ddp_access_profile_rec.opp_access_profile_value := p3_a2;
    ddp_access_profile_rec.mgr_update_profile_value := p3_a3;
    ddp_access_profile_rec.admin_update_profile_value := p3_a4;












    -- here's the delegated call to the old PL/SQL routine
    as_access_pub.has_opportunityaccess(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_access_profile_rec,
      p_admin_flag,
      p_admin_group_id,
      p_person_id,
      p_opportunity_id,
      p_check_access_flag,
      p_identity_salesforce_id,
      p_partner_cont_party_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_access_privilege);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














  end;

end as_access_pub_w;

/
