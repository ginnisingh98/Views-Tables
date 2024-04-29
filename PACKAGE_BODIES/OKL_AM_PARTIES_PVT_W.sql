--------------------------------------------------------
--  DDL for Package Body OKL_AM_PARTIES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_PARTIES_PVT_W" as
  /* $Header: OKLEAMPB.pls 115.10 2002/12/13 19:30:18 gkadarka noship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy okl_am_parties_pvt.q_party_uv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_DATE_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_200
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_400
    , a20 JTF_VARCHAR2_TABLE_2000
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_200
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_400
    , a25 JTF_VARCHAR2_TABLE_2000
    , a26 JTF_VARCHAR2_TABLE_2000
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_DATE_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_VARCHAR2_TABLE_2000
    , a33 JTF_VARCHAR2_TABLE_2000
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).quote_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).contract_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).k_buy_or_sell := a2(indx);
          t(ddindx).qp_party_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).qp_role_code := a4(indx);
          t(ddindx).qp_party_role := a5(indx);
          t(ddindx).qp_date_sent := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).qp_date_hold := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).qp_created_by := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).qp_creation_date := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).qp_last_updated_by := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).qp_last_update_date := rosetta_g_miss_date_in_map(a11(indx));
          t(ddindx).qp_last_update_login := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).kp_party_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).kp_role_code := a14(indx);
          t(ddindx).kp_party_role := a15(indx);
          t(ddindx).po_party_id1 := a16(indx);
          t(ddindx).po_party_id2 := a17(indx);
          t(ddindx).po_party_object := a18(indx);
          t(ddindx).po_party_name := a19(indx);
          t(ddindx).po_party_desc := a20(indx);
          t(ddindx).co_contact_id1 := a21(indx);
          t(ddindx).co_contact_id2 := a22(indx);
          t(ddindx).co_contact_object := a23(indx);
          t(ddindx).co_contact_name := a24(indx);
          t(ddindx).co_contact_desc := a25(indx);
          t(ddindx).co_email := a26(indx);
          t(ddindx).co_order_num := rosetta_g_miss_num_map(a27(indx));
          t(ddindx).co_date_sent := rosetta_g_miss_date_in_map(a28(indx));
          t(ddindx).cp_point_id := rosetta_g_miss_num_map(a29(indx));
          t(ddindx).cp_point_type := a30(indx);
          t(ddindx).cp_primary_flag := a31(indx);
          t(ddindx).cp_email := a32(indx);
          t(ddindx).cp_details := a33(indx);
          t(ddindx).cp_order_num := rosetta_g_miss_num_map(a34(indx));
          t(ddindx).cp_date_sent := rosetta_g_miss_date_in_map(a35(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t okl_am_parties_pvt.q_party_uv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_200
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_400
    , a20 out nocopy JTF_VARCHAR2_TABLE_2000
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_200
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_VARCHAR2_TABLE_400
    , a25 out nocopy JTF_VARCHAR2_TABLE_2000
    , a26 out nocopy JTF_VARCHAR2_TABLE_2000
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_DATE_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_VARCHAR2_TABLE_2000
    , a33 out nocopy JTF_VARCHAR2_TABLE_2000
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_DATE_TABLE
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
    a6 := JTF_DATE_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_200();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_VARCHAR2_TABLE_400();
    a20 := JTF_VARCHAR2_TABLE_2000();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_VARCHAR2_TABLE_200();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_VARCHAR2_TABLE_400();
    a25 := JTF_VARCHAR2_TABLE_2000();
    a26 := JTF_VARCHAR2_TABLE_2000();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_DATE_TABLE();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_VARCHAR2_TABLE_100();
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_VARCHAR2_TABLE_2000();
    a33 := JTF_VARCHAR2_TABLE_2000();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_200();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_VARCHAR2_TABLE_400();
      a20 := JTF_VARCHAR2_TABLE_2000();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_VARCHAR2_TABLE_200();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_VARCHAR2_TABLE_400();
      a25 := JTF_VARCHAR2_TABLE_2000();
      a26 := JTF_VARCHAR2_TABLE_2000();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_DATE_TABLE();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_VARCHAR2_TABLE_100();
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_VARCHAR2_TABLE_2000();
      a33 := JTF_VARCHAR2_TABLE_2000();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_DATE_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).quote_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).contract_id);
          a2(indx) := t(ddindx).k_buy_or_sell;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).qp_party_id);
          a4(indx) := t(ddindx).qp_role_code;
          a5(indx) := t(ddindx).qp_party_role;
          a6(indx) := t(ddindx).qp_date_sent;
          a7(indx) := t(ddindx).qp_date_hold;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).qp_created_by);
          a9(indx) := t(ddindx).qp_creation_date;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).qp_last_updated_by);
          a11(indx) := t(ddindx).qp_last_update_date;
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).qp_last_update_login);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).kp_party_id);
          a14(indx) := t(ddindx).kp_role_code;
          a15(indx) := t(ddindx).kp_party_role;
          a16(indx) := t(ddindx).po_party_id1;
          a17(indx) := t(ddindx).po_party_id2;
          a18(indx) := t(ddindx).po_party_object;
          a19(indx) := t(ddindx).po_party_name;
          a20(indx) := t(ddindx).po_party_desc;
          a21(indx) := t(ddindx).co_contact_id1;
          a22(indx) := t(ddindx).co_contact_id2;
          a23(indx) := t(ddindx).co_contact_object;
          a24(indx) := t(ddindx).co_contact_name;
          a25(indx) := t(ddindx).co_contact_desc;
          a26(indx) := t(ddindx).co_email;
          a27(indx) := rosetta_g_miss_num_map(t(ddindx).co_order_num);
          a28(indx) := t(ddindx).co_date_sent;
          a29(indx) := rosetta_g_miss_num_map(t(ddindx).cp_point_id);
          a30(indx) := t(ddindx).cp_point_type;
          a31(indx) := t(ddindx).cp_primary_flag;
          a32(indx) := t(ddindx).cp_email;
          a33(indx) := t(ddindx).cp_details;
          a34(indx) := rosetta_g_miss_num_map(t(ddindx).cp_order_num);
          a35(indx) := t(ddindx).cp_date_sent;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p3(t out nocopy okl_am_parties_pvt.party_object_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_200
    , a3 JTF_VARCHAR2_TABLE_400
    , a4 JTF_VARCHAR2_TABLE_2000
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_200
    , a8 JTF_VARCHAR2_TABLE_400
    , a9 JTF_VARCHAR2_TABLE_2000
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_200
    , a13 JTF_VARCHAR2_TABLE_400
    , a14 JTF_VARCHAR2_TABLE_2000
    , a15 JTF_VARCHAR2_TABLE_2000
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_2000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).p_code := a0(indx);
          t(ddindx).p_id1 := a1(indx);
          t(ddindx).p_id2 := a2(indx);
          t(ddindx).p_name := a3(indx);
          t(ddindx).p_desc := a4(indx);
          t(ddindx).s_code := a5(indx);
          t(ddindx).s_id1 := a6(indx);
          t(ddindx).s_id2 := a7(indx);
          t(ddindx).s_name := a8(indx);
          t(ddindx).s_desc := a9(indx);
          t(ddindx).c_code := a10(indx);
          t(ddindx).c_id1 := a11(indx);
          t(ddindx).c_id2 := a12(indx);
          t(ddindx).c_name := a13(indx);
          t(ddindx).c_desc := a14(indx);
          t(ddindx).c_email := a15(indx);
          t(ddindx).c_person_id := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).pcp_id := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).pcp_primary := a18(indx);
          t(ddindx).pcp_email := a19(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t okl_am_parties_pvt.party_object_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    , a3 out nocopy JTF_VARCHAR2_TABLE_400
    , a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_200
    , a8 out nocopy JTF_VARCHAR2_TABLE_400
    , a9 out nocopy JTF_VARCHAR2_TABLE_2000
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_200
    , a13 out nocopy JTF_VARCHAR2_TABLE_400
    , a14 out nocopy JTF_VARCHAR2_TABLE_2000
    , a15 out nocopy JTF_VARCHAR2_TABLE_2000
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_2000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_200();
    a3 := JTF_VARCHAR2_TABLE_400();
    a4 := JTF_VARCHAR2_TABLE_2000();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_200();
    a8 := JTF_VARCHAR2_TABLE_400();
    a9 := JTF_VARCHAR2_TABLE_2000();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_200();
    a13 := JTF_VARCHAR2_TABLE_400();
    a14 := JTF_VARCHAR2_TABLE_2000();
    a15 := JTF_VARCHAR2_TABLE_2000();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_VARCHAR2_TABLE_2000();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_200();
      a3 := JTF_VARCHAR2_TABLE_400();
      a4 := JTF_VARCHAR2_TABLE_2000();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_200();
      a8 := JTF_VARCHAR2_TABLE_400();
      a9 := JTF_VARCHAR2_TABLE_2000();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_200();
      a13 := JTF_VARCHAR2_TABLE_400();
      a14 := JTF_VARCHAR2_TABLE_2000();
      a15 := JTF_VARCHAR2_TABLE_2000();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_VARCHAR2_TABLE_2000();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).p_code;
          a1(indx) := t(ddindx).p_id1;
          a2(indx) := t(ddindx).p_id2;
          a3(indx) := t(ddindx).p_name;
          a4(indx) := t(ddindx).p_desc;
          a5(indx) := t(ddindx).s_code;
          a6(indx) := t(ddindx).s_id1;
          a7(indx) := t(ddindx).s_id2;
          a8(indx) := t(ddindx).s_name;
          a9(indx) := t(ddindx).s_desc;
          a10(indx) := t(ddindx).c_code;
          a11(indx) := t(ddindx).c_id1;
          a12(indx) := t(ddindx).c_id2;
          a13(indx) := t(ddindx).c_name;
          a14(indx) := t(ddindx).c_desc;
          a15(indx) := t(ddindx).c_email;
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).c_person_id);
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).pcp_id);
          a18(indx) := t(ddindx).pcp_primary;
          a19(indx) := t(ddindx).pcp_email;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure fetch_rule_quote_parties(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_DATE_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_600
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_DATE_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_DATE_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a3 out nocopy JTF_NUMBER_TABLE
    , p7_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a6 out nocopy JTF_DATE_TABLE
    , p7_a7 out nocopy JTF_DATE_TABLE
    , p7_a8 out nocopy JTF_NUMBER_TABLE
    , p7_a9 out nocopy JTF_DATE_TABLE
    , p7_a10 out nocopy JTF_NUMBER_TABLE
    , p7_a11 out nocopy JTF_DATE_TABLE
    , p7_a12 out nocopy JTF_NUMBER_TABLE
    , p7_a13 out nocopy JTF_NUMBER_TABLE
    , p7_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a19 out nocopy JTF_VARCHAR2_TABLE_400
    , p7_a20 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a24 out nocopy JTF_VARCHAR2_TABLE_400
    , p7_a25 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a26 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a27 out nocopy JTF_NUMBER_TABLE
    , p7_a28 out nocopy JTF_DATE_TABLE
    , p7_a29 out nocopy JTF_NUMBER_TABLE
    , p7_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a32 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a33 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a34 out nocopy JTF_NUMBER_TABLE
    , p7_a35 out nocopy JTF_DATE_TABLE
    , x_record_count out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  DATE := fnd_api.g_miss_date
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  DATE := fnd_api.g_miss_date
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  DATE := fnd_api.g_miss_date
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  VARCHAR2 := fnd_api.g_miss_char
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  DATE := fnd_api.g_miss_date
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  NUMBER := 0-1962.0724
    , p5_a60  NUMBER := 0-1962.0724
    , p5_a61  NUMBER := 0-1962.0724
    , p5_a62  NUMBER := 0-1962.0724
    , p5_a63  DATE := fnd_api.g_miss_date
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  DATE := fnd_api.g_miss_date
    , p5_a66  NUMBER := 0-1962.0724
    , p5_a67  DATE := fnd_api.g_miss_date
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  NUMBER := 0-1962.0724
    , p5_a70  VARCHAR2 := fnd_api.g_miss_char
    , p5_a71  NUMBER := 0-1962.0724
    , p5_a72  NUMBER := 0-1962.0724
    , p5_a73  NUMBER := 0-1962.0724
    , p5_a74  NUMBER := 0-1962.0724
    , p5_a75  VARCHAR2 := fnd_api.g_miss_char
    , p5_a76  VARCHAR2 := fnd_api.g_miss_char
    , p5_a77  VARCHAR2 := fnd_api.g_miss_char
    , p5_a78  NUMBER := 0-1962.0724
    , p5_a79  DATE := fnd_api.g_miss_date
  )

  as
    ddp_qtev_rec okl_am_parties_pvt.qtev_rec_type;
    ddx_qpyv_tbl okl_am_parties_pvt.qpyv_tbl_type;
    ddx_q_party_uv_tbl okl_am_parties_pvt.q_party_uv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_qtev_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_qtev_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_qtev_rec.sfwt_flag := p5_a2;
    ddp_qtev_rec.qrs_code := p5_a3;
    ddp_qtev_rec.qst_code := p5_a4;
    ddp_qtev_rec.qtp_code := p5_a5;
    ddp_qtev_rec.trn_code := p5_a6;
    ddp_qtev_rec.pop_code_end := p5_a7;
    ddp_qtev_rec.pop_code_early := p5_a8;
    ddp_qtev_rec.consolidated_qte_id := rosetta_g_miss_num_map(p5_a9);
    ddp_qtev_rec.khr_id := rosetta_g_miss_num_map(p5_a10);
    ddp_qtev_rec.art_id := rosetta_g_miss_num_map(p5_a11);
    ddp_qtev_rec.pdt_id := rosetta_g_miss_num_map(p5_a12);
    ddp_qtev_rec.early_termination_yn := p5_a13;
    ddp_qtev_rec.partial_yn := p5_a14;
    ddp_qtev_rec.preproceeds_yn := p5_a15;
    ddp_qtev_rec.date_requested := rosetta_g_miss_date_in_map(p5_a16);
    ddp_qtev_rec.date_proposal := rosetta_g_miss_date_in_map(p5_a17);
    ddp_qtev_rec.date_effective_to := rosetta_g_miss_date_in_map(p5_a18);
    ddp_qtev_rec.date_accepted := rosetta_g_miss_date_in_map(p5_a19);
    ddp_qtev_rec.summary_format_yn := p5_a20;
    ddp_qtev_rec.consolidated_yn := p5_a21;
    ddp_qtev_rec.principal_paydown_amount := rosetta_g_miss_num_map(p5_a22);
    ddp_qtev_rec.residual_amount := rosetta_g_miss_num_map(p5_a23);
    ddp_qtev_rec.yield := rosetta_g_miss_num_map(p5_a24);
    ddp_qtev_rec.rent_amount := rosetta_g_miss_num_map(p5_a25);
    ddp_qtev_rec.date_restructure_end := rosetta_g_miss_date_in_map(p5_a26);
    ddp_qtev_rec.date_restructure_start := rosetta_g_miss_date_in_map(p5_a27);
    ddp_qtev_rec.term := rosetta_g_miss_num_map(p5_a28);
    ddp_qtev_rec.purchase_percent := rosetta_g_miss_num_map(p5_a29);
    ddp_qtev_rec.comments := p5_a30;
    ddp_qtev_rec.date_due := rosetta_g_miss_date_in_map(p5_a31);
    ddp_qtev_rec.payment_frequency := p5_a32;
    ddp_qtev_rec.remaining_payments := rosetta_g_miss_num_map(p5_a33);
    ddp_qtev_rec.date_effective_from := rosetta_g_miss_date_in_map(p5_a34);
    ddp_qtev_rec.quote_number := rosetta_g_miss_num_map(p5_a35);
    ddp_qtev_rec.requested_by := rosetta_g_miss_num_map(p5_a36);
    ddp_qtev_rec.approved_yn := p5_a37;
    ddp_qtev_rec.accepted_yn := p5_a38;
    ddp_qtev_rec.payment_received_yn := p5_a39;
    ddp_qtev_rec.date_payment_received := rosetta_g_miss_date_in_map(p5_a40);
    ddp_qtev_rec.attribute_category := p5_a41;
    ddp_qtev_rec.attribute1 := p5_a42;
    ddp_qtev_rec.attribute2 := p5_a43;
    ddp_qtev_rec.attribute3 := p5_a44;
    ddp_qtev_rec.attribute4 := p5_a45;
    ddp_qtev_rec.attribute5 := p5_a46;
    ddp_qtev_rec.attribute6 := p5_a47;
    ddp_qtev_rec.attribute7 := p5_a48;
    ddp_qtev_rec.attribute8 := p5_a49;
    ddp_qtev_rec.attribute9 := p5_a50;
    ddp_qtev_rec.attribute10 := p5_a51;
    ddp_qtev_rec.attribute11 := p5_a52;
    ddp_qtev_rec.attribute12 := p5_a53;
    ddp_qtev_rec.attribute13 := p5_a54;
    ddp_qtev_rec.attribute14 := p5_a55;
    ddp_qtev_rec.attribute15 := p5_a56;
    ddp_qtev_rec.date_approved := rosetta_g_miss_date_in_map(p5_a57);
    ddp_qtev_rec.approved_by := rosetta_g_miss_num_map(p5_a58);
    ddp_qtev_rec.org_id := rosetta_g_miss_num_map(p5_a59);
    ddp_qtev_rec.request_id := rosetta_g_miss_num_map(p5_a60);
    ddp_qtev_rec.program_application_id := rosetta_g_miss_num_map(p5_a61);
    ddp_qtev_rec.program_id := rosetta_g_miss_num_map(p5_a62);
    ddp_qtev_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a63);
    ddp_qtev_rec.created_by := rosetta_g_miss_num_map(p5_a64);
    ddp_qtev_rec.creation_date := rosetta_g_miss_date_in_map(p5_a65);
    ddp_qtev_rec.last_updated_by := rosetta_g_miss_num_map(p5_a66);
    ddp_qtev_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a67);
    ddp_qtev_rec.last_update_login := rosetta_g_miss_num_map(p5_a68);
    ddp_qtev_rec.purchase_amount := rosetta_g_miss_num_map(p5_a69);
    ddp_qtev_rec.purchase_formula := p5_a70;
    ddp_qtev_rec.asset_value := rosetta_g_miss_num_map(p5_a71);
    ddp_qtev_rec.residual_value := rosetta_g_miss_num_map(p5_a72);
    ddp_qtev_rec.unbilled_receivables := rosetta_g_miss_num_map(p5_a73);
    ddp_qtev_rec.gain_loss := rosetta_g_miss_num_map(p5_a74);
    ddp_qtev_rec.currency_code := p5_a75;
    ddp_qtev_rec.currency_conversion_code := p5_a76;
    ddp_qtev_rec.currency_conversion_type := p5_a77;
    ddp_qtev_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a78);
    ddp_qtev_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a79);




    -- here's the delegated call to the old PL/SQL routine
    okl_am_parties_pvt.fetch_rule_quote_parties(p_api_version,
      p_init_msg_list,
      x_msg_count,
      x_msg_data,
      x_return_status,
      ddp_qtev_rec,
      ddx_qpyv_tbl,
      ddx_q_party_uv_tbl,
      x_record_count);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_qpy_pvt_w.rosetta_table_copy_out_p5(ddx_qpyv_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      , p6_a10
      , p6_a11
      , p6_a12
      , p6_a13
      , p6_a14
      , p6_a15
      , p6_a16
      , p6_a17
      , p6_a18
      , p6_a19
      );

    okl_am_parties_pvt_w.rosetta_table_copy_out_p2(ddx_q_party_uv_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      , p7_a8
      , p7_a9
      , p7_a10
      , p7_a11
      , p7_a12
      , p7_a13
      , p7_a14
      , p7_a15
      , p7_a16
      , p7_a17
      , p7_a18
      , p7_a19
      , p7_a20
      , p7_a21
      , p7_a22
      , p7_a23
      , p7_a24
      , p7_a25
      , p7_a26
      , p7_a27
      , p7_a28
      , p7_a29
      , p7_a30
      , p7_a31
      , p7_a32
      , p7_a33
      , p7_a34
      , p7_a35
      );

  end;

  procedure create_partner_as_recipient(p_validate_only  number
    , p2_a0 out nocopy JTF_NUMBER_TABLE
    , p2_a1 out nocopy JTF_NUMBER_TABLE
    , p2_a2 out nocopy JTF_NUMBER_TABLE
    , p2_a3 out nocopy JTF_NUMBER_TABLE
    , p2_a4 out nocopy JTF_DATE_TABLE
    , p2_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a6 out nocopy JTF_NUMBER_TABLE
    , p2_a7 out nocopy JTF_NUMBER_TABLE
    , p2_a8 out nocopy JTF_VARCHAR2_TABLE_600
    , p2_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a11 out nocopy JTF_VARCHAR2_TABLE_200
    , p2_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p2_a15 out nocopy JTF_NUMBER_TABLE
    , p2_a16 out nocopy JTF_DATE_TABLE
    , p2_a17 out nocopy JTF_NUMBER_TABLE
    , p2_a18 out nocopy JTF_DATE_TABLE
    , p2_a19 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  VARCHAR2 := fnd_api.g_miss_char
    , p0_a3  VARCHAR2 := fnd_api.g_miss_char
    , p0_a4  VARCHAR2 := fnd_api.g_miss_char
    , p0_a5  VARCHAR2 := fnd_api.g_miss_char
    , p0_a6  VARCHAR2 := fnd_api.g_miss_char
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  NUMBER := 0-1962.0724
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  DATE := fnd_api.g_miss_date
    , p0_a17  DATE := fnd_api.g_miss_date
    , p0_a18  DATE := fnd_api.g_miss_date
    , p0_a19  DATE := fnd_api.g_miss_date
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  VARCHAR2 := fnd_api.g_miss_char
    , p0_a22  NUMBER := 0-1962.0724
    , p0_a23  NUMBER := 0-1962.0724
    , p0_a24  NUMBER := 0-1962.0724
    , p0_a25  NUMBER := 0-1962.0724
    , p0_a26  DATE := fnd_api.g_miss_date
    , p0_a27  DATE := fnd_api.g_miss_date
    , p0_a28  NUMBER := 0-1962.0724
    , p0_a29  NUMBER := 0-1962.0724
    , p0_a30  VARCHAR2 := fnd_api.g_miss_char
    , p0_a31  DATE := fnd_api.g_miss_date
    , p0_a32  VARCHAR2 := fnd_api.g_miss_char
    , p0_a33  NUMBER := 0-1962.0724
    , p0_a34  DATE := fnd_api.g_miss_date
    , p0_a35  NUMBER := 0-1962.0724
    , p0_a36  NUMBER := 0-1962.0724
    , p0_a37  VARCHAR2 := fnd_api.g_miss_char
    , p0_a38  VARCHAR2 := fnd_api.g_miss_char
    , p0_a39  VARCHAR2 := fnd_api.g_miss_char
    , p0_a40  DATE := fnd_api.g_miss_date
    , p0_a41  VARCHAR2 := fnd_api.g_miss_char
    , p0_a42  VARCHAR2 := fnd_api.g_miss_char
    , p0_a43  VARCHAR2 := fnd_api.g_miss_char
    , p0_a44  VARCHAR2 := fnd_api.g_miss_char
    , p0_a45  VARCHAR2 := fnd_api.g_miss_char
    , p0_a46  VARCHAR2 := fnd_api.g_miss_char
    , p0_a47  VARCHAR2 := fnd_api.g_miss_char
    , p0_a48  VARCHAR2 := fnd_api.g_miss_char
    , p0_a49  VARCHAR2 := fnd_api.g_miss_char
    , p0_a50  VARCHAR2 := fnd_api.g_miss_char
    , p0_a51  VARCHAR2 := fnd_api.g_miss_char
    , p0_a52  VARCHAR2 := fnd_api.g_miss_char
    , p0_a53  VARCHAR2 := fnd_api.g_miss_char
    , p0_a54  VARCHAR2 := fnd_api.g_miss_char
    , p0_a55  VARCHAR2 := fnd_api.g_miss_char
    , p0_a56  VARCHAR2 := fnd_api.g_miss_char
    , p0_a57  DATE := fnd_api.g_miss_date
    , p0_a58  NUMBER := 0-1962.0724
    , p0_a59  NUMBER := 0-1962.0724
    , p0_a60  NUMBER := 0-1962.0724
    , p0_a61  NUMBER := 0-1962.0724
    , p0_a62  NUMBER := 0-1962.0724
    , p0_a63  DATE := fnd_api.g_miss_date
    , p0_a64  NUMBER := 0-1962.0724
    , p0_a65  DATE := fnd_api.g_miss_date
    , p0_a66  NUMBER := 0-1962.0724
    , p0_a67  DATE := fnd_api.g_miss_date
    , p0_a68  NUMBER := 0-1962.0724
    , p0_a69  NUMBER := 0-1962.0724
    , p0_a70  VARCHAR2 := fnd_api.g_miss_char
    , p0_a71  NUMBER := 0-1962.0724
    , p0_a72  NUMBER := 0-1962.0724
    , p0_a73  NUMBER := 0-1962.0724
    , p0_a74  NUMBER := 0-1962.0724
    , p0_a75  VARCHAR2 := fnd_api.g_miss_char
    , p0_a76  VARCHAR2 := fnd_api.g_miss_char
    , p0_a77  VARCHAR2 := fnd_api.g_miss_char
    , p0_a78  NUMBER := 0-1962.0724
    , p0_a79  DATE := fnd_api.g_miss_date
  )

  as
    ddp_qtev_rec okl_am_parties_pvt.qtev_rec_type;
    ddp_validate_only boolean;
    ddx_qpyv_tbl okl_am_parties_pvt.qpyv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_qtev_rec.id := rosetta_g_miss_num_map(p0_a0);
    ddp_qtev_rec.object_version_number := rosetta_g_miss_num_map(p0_a1);
    ddp_qtev_rec.sfwt_flag := p0_a2;
    ddp_qtev_rec.qrs_code := p0_a3;
    ddp_qtev_rec.qst_code := p0_a4;
    ddp_qtev_rec.qtp_code := p0_a5;
    ddp_qtev_rec.trn_code := p0_a6;
    ddp_qtev_rec.pop_code_end := p0_a7;
    ddp_qtev_rec.pop_code_early := p0_a8;
    ddp_qtev_rec.consolidated_qte_id := rosetta_g_miss_num_map(p0_a9);
    ddp_qtev_rec.khr_id := rosetta_g_miss_num_map(p0_a10);
    ddp_qtev_rec.art_id := rosetta_g_miss_num_map(p0_a11);
    ddp_qtev_rec.pdt_id := rosetta_g_miss_num_map(p0_a12);
    ddp_qtev_rec.early_termination_yn := p0_a13;
    ddp_qtev_rec.partial_yn := p0_a14;
    ddp_qtev_rec.preproceeds_yn := p0_a15;
    ddp_qtev_rec.date_requested := rosetta_g_miss_date_in_map(p0_a16);
    ddp_qtev_rec.date_proposal := rosetta_g_miss_date_in_map(p0_a17);
    ddp_qtev_rec.date_effective_to := rosetta_g_miss_date_in_map(p0_a18);
    ddp_qtev_rec.date_accepted := rosetta_g_miss_date_in_map(p0_a19);
    ddp_qtev_rec.summary_format_yn := p0_a20;
    ddp_qtev_rec.consolidated_yn := p0_a21;
    ddp_qtev_rec.principal_paydown_amount := rosetta_g_miss_num_map(p0_a22);
    ddp_qtev_rec.residual_amount := rosetta_g_miss_num_map(p0_a23);
    ddp_qtev_rec.yield := rosetta_g_miss_num_map(p0_a24);
    ddp_qtev_rec.rent_amount := rosetta_g_miss_num_map(p0_a25);
    ddp_qtev_rec.date_restructure_end := rosetta_g_miss_date_in_map(p0_a26);
    ddp_qtev_rec.date_restructure_start := rosetta_g_miss_date_in_map(p0_a27);
    ddp_qtev_rec.term := rosetta_g_miss_num_map(p0_a28);
    ddp_qtev_rec.purchase_percent := rosetta_g_miss_num_map(p0_a29);
    ddp_qtev_rec.comments := p0_a30;
    ddp_qtev_rec.date_due := rosetta_g_miss_date_in_map(p0_a31);
    ddp_qtev_rec.payment_frequency := p0_a32;
    ddp_qtev_rec.remaining_payments := rosetta_g_miss_num_map(p0_a33);
    ddp_qtev_rec.date_effective_from := rosetta_g_miss_date_in_map(p0_a34);
    ddp_qtev_rec.quote_number := rosetta_g_miss_num_map(p0_a35);
    ddp_qtev_rec.requested_by := rosetta_g_miss_num_map(p0_a36);
    ddp_qtev_rec.approved_yn := p0_a37;
    ddp_qtev_rec.accepted_yn := p0_a38;
    ddp_qtev_rec.payment_received_yn := p0_a39;
    ddp_qtev_rec.date_payment_received := rosetta_g_miss_date_in_map(p0_a40);
    ddp_qtev_rec.attribute_category := p0_a41;
    ddp_qtev_rec.attribute1 := p0_a42;
    ddp_qtev_rec.attribute2 := p0_a43;
    ddp_qtev_rec.attribute3 := p0_a44;
    ddp_qtev_rec.attribute4 := p0_a45;
    ddp_qtev_rec.attribute5 := p0_a46;
    ddp_qtev_rec.attribute6 := p0_a47;
    ddp_qtev_rec.attribute7 := p0_a48;
    ddp_qtev_rec.attribute8 := p0_a49;
    ddp_qtev_rec.attribute9 := p0_a50;
    ddp_qtev_rec.attribute10 := p0_a51;
    ddp_qtev_rec.attribute11 := p0_a52;
    ddp_qtev_rec.attribute12 := p0_a53;
    ddp_qtev_rec.attribute13 := p0_a54;
    ddp_qtev_rec.attribute14 := p0_a55;
    ddp_qtev_rec.attribute15 := p0_a56;
    ddp_qtev_rec.date_approved := rosetta_g_miss_date_in_map(p0_a57);
    ddp_qtev_rec.approved_by := rosetta_g_miss_num_map(p0_a58);
    ddp_qtev_rec.org_id := rosetta_g_miss_num_map(p0_a59);
    ddp_qtev_rec.request_id := rosetta_g_miss_num_map(p0_a60);
    ddp_qtev_rec.program_application_id := rosetta_g_miss_num_map(p0_a61);
    ddp_qtev_rec.program_id := rosetta_g_miss_num_map(p0_a62);
    ddp_qtev_rec.program_update_date := rosetta_g_miss_date_in_map(p0_a63);
    ddp_qtev_rec.created_by := rosetta_g_miss_num_map(p0_a64);
    ddp_qtev_rec.creation_date := rosetta_g_miss_date_in_map(p0_a65);
    ddp_qtev_rec.last_updated_by := rosetta_g_miss_num_map(p0_a66);
    ddp_qtev_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a67);
    ddp_qtev_rec.last_update_login := rosetta_g_miss_num_map(p0_a68);
    ddp_qtev_rec.purchase_amount := rosetta_g_miss_num_map(p0_a69);
    ddp_qtev_rec.purchase_formula := p0_a70;
    ddp_qtev_rec.asset_value := rosetta_g_miss_num_map(p0_a71);
    ddp_qtev_rec.residual_value := rosetta_g_miss_num_map(p0_a72);
    ddp_qtev_rec.unbilled_receivables := rosetta_g_miss_num_map(p0_a73);
    ddp_qtev_rec.gain_loss := rosetta_g_miss_num_map(p0_a74);
    ddp_qtev_rec.currency_code := p0_a75;
    ddp_qtev_rec.currency_conversion_code := p0_a76;
    ddp_qtev_rec.currency_conversion_type := p0_a77;
    ddp_qtev_rec.currency_conversion_rate := rosetta_g_miss_num_map(p0_a78);
    ddp_qtev_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p0_a79);

    if p_validate_only is null
      then ddp_validate_only := null;
    elsif p_validate_only = 0
      then ddp_validate_only := false;
    else ddp_validate_only := true;
    end if;



    -- here's the delegated call to the old PL/SQL routine
    okl_am_parties_pvt.create_partner_as_recipient(ddp_qtev_rec,
      ddp_validate_only,
      ddx_qpyv_tbl,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    okl_qpy_pvt_w.rosetta_table_copy_out_p5(ddx_qpyv_tbl, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      , p2_a5
      , p2_a6
      , p2_a7
      , p2_a8
      , p2_a9
      , p2_a10
      , p2_a11
      , p2_a12
      , p2_a13
      , p2_a14
      , p2_a15
      , p2_a16
      , p2_a17
      , p2_a18
      , p2_a19
      );

  end;

  procedure create_quote_parties(p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_NUMBER_TABLE
    , p1_a2 JTF_NUMBER_TABLE
    , p1_a3 JTF_NUMBER_TABLE
    , p1_a4 JTF_DATE_TABLE
    , p1_a5 JTF_VARCHAR2_TABLE_100
    , p1_a6 JTF_NUMBER_TABLE
    , p1_a7 JTF_NUMBER_TABLE
    , p1_a8 JTF_VARCHAR2_TABLE_600
    , p1_a9 JTF_VARCHAR2_TABLE_100
    , p1_a10 JTF_VARCHAR2_TABLE_100
    , p1_a11 JTF_VARCHAR2_TABLE_200
    , p1_a12 JTF_VARCHAR2_TABLE_100
    , p1_a13 JTF_VARCHAR2_TABLE_100
    , p1_a14 JTF_VARCHAR2_TABLE_200
    , p1_a15 JTF_NUMBER_TABLE
    , p1_a16 JTF_DATE_TABLE
    , p1_a17 JTF_NUMBER_TABLE
    , p1_a18 JTF_DATE_TABLE
    , p1_a19 JTF_NUMBER_TABLE
    , p_validate_only  number
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_NUMBER_TABLE
    , p3_a2 out nocopy JTF_NUMBER_TABLE
    , p3_a3 out nocopy JTF_NUMBER_TABLE
    , p3_a4 out nocopy JTF_DATE_TABLE
    , p3_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a6 out nocopy JTF_NUMBER_TABLE
    , p3_a7 out nocopy JTF_NUMBER_TABLE
    , p3_a8 out nocopy JTF_VARCHAR2_TABLE_600
    , p3_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a11 out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a15 out nocopy JTF_NUMBER_TABLE
    , p3_a16 out nocopy JTF_DATE_TABLE
    , p3_a17 out nocopy JTF_NUMBER_TABLE
    , p3_a18 out nocopy JTF_DATE_TABLE
    , p3_a19 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  VARCHAR2 := fnd_api.g_miss_char
    , p0_a3  VARCHAR2 := fnd_api.g_miss_char
    , p0_a4  VARCHAR2 := fnd_api.g_miss_char
    , p0_a5  VARCHAR2 := fnd_api.g_miss_char
    , p0_a6  VARCHAR2 := fnd_api.g_miss_char
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  NUMBER := 0-1962.0724
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  DATE := fnd_api.g_miss_date
    , p0_a17  DATE := fnd_api.g_miss_date
    , p0_a18  DATE := fnd_api.g_miss_date
    , p0_a19  DATE := fnd_api.g_miss_date
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  VARCHAR2 := fnd_api.g_miss_char
    , p0_a22  NUMBER := 0-1962.0724
    , p0_a23  NUMBER := 0-1962.0724
    , p0_a24  NUMBER := 0-1962.0724
    , p0_a25  NUMBER := 0-1962.0724
    , p0_a26  DATE := fnd_api.g_miss_date
    , p0_a27  DATE := fnd_api.g_miss_date
    , p0_a28  NUMBER := 0-1962.0724
    , p0_a29  NUMBER := 0-1962.0724
    , p0_a30  VARCHAR2 := fnd_api.g_miss_char
    , p0_a31  DATE := fnd_api.g_miss_date
    , p0_a32  VARCHAR2 := fnd_api.g_miss_char
    , p0_a33  NUMBER := 0-1962.0724
    , p0_a34  DATE := fnd_api.g_miss_date
    , p0_a35  NUMBER := 0-1962.0724
    , p0_a36  NUMBER := 0-1962.0724
    , p0_a37  VARCHAR2 := fnd_api.g_miss_char
    , p0_a38  VARCHAR2 := fnd_api.g_miss_char
    , p0_a39  VARCHAR2 := fnd_api.g_miss_char
    , p0_a40  DATE := fnd_api.g_miss_date
    , p0_a41  VARCHAR2 := fnd_api.g_miss_char
    , p0_a42  VARCHAR2 := fnd_api.g_miss_char
    , p0_a43  VARCHAR2 := fnd_api.g_miss_char
    , p0_a44  VARCHAR2 := fnd_api.g_miss_char
    , p0_a45  VARCHAR2 := fnd_api.g_miss_char
    , p0_a46  VARCHAR2 := fnd_api.g_miss_char
    , p0_a47  VARCHAR2 := fnd_api.g_miss_char
    , p0_a48  VARCHAR2 := fnd_api.g_miss_char
    , p0_a49  VARCHAR2 := fnd_api.g_miss_char
    , p0_a50  VARCHAR2 := fnd_api.g_miss_char
    , p0_a51  VARCHAR2 := fnd_api.g_miss_char
    , p0_a52  VARCHAR2 := fnd_api.g_miss_char
    , p0_a53  VARCHAR2 := fnd_api.g_miss_char
    , p0_a54  VARCHAR2 := fnd_api.g_miss_char
    , p0_a55  VARCHAR2 := fnd_api.g_miss_char
    , p0_a56  VARCHAR2 := fnd_api.g_miss_char
    , p0_a57  DATE := fnd_api.g_miss_date
    , p0_a58  NUMBER := 0-1962.0724
    , p0_a59  NUMBER := 0-1962.0724
    , p0_a60  NUMBER := 0-1962.0724
    , p0_a61  NUMBER := 0-1962.0724
    , p0_a62  NUMBER := 0-1962.0724
    , p0_a63  DATE := fnd_api.g_miss_date
    , p0_a64  NUMBER := 0-1962.0724
    , p0_a65  DATE := fnd_api.g_miss_date
    , p0_a66  NUMBER := 0-1962.0724
    , p0_a67  DATE := fnd_api.g_miss_date
    , p0_a68  NUMBER := 0-1962.0724
    , p0_a69  NUMBER := 0-1962.0724
    , p0_a70  VARCHAR2 := fnd_api.g_miss_char
    , p0_a71  NUMBER := 0-1962.0724
    , p0_a72  NUMBER := 0-1962.0724
    , p0_a73  NUMBER := 0-1962.0724
    , p0_a74  NUMBER := 0-1962.0724
    , p0_a75  VARCHAR2 := fnd_api.g_miss_char
    , p0_a76  VARCHAR2 := fnd_api.g_miss_char
    , p0_a77  VARCHAR2 := fnd_api.g_miss_char
    , p0_a78  NUMBER := 0-1962.0724
    , p0_a79  DATE := fnd_api.g_miss_date
  )

  as
    ddp_qtev_rec okl_am_parties_pvt.qtev_rec_type;
    ddp_qpyv_tbl okl_am_parties_pvt.qpyv_tbl_type;
    ddp_validate_only boolean;
    ddx_qpyv_tbl okl_am_parties_pvt.qpyv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_qtev_rec.id := rosetta_g_miss_num_map(p0_a0);
    ddp_qtev_rec.object_version_number := rosetta_g_miss_num_map(p0_a1);
    ddp_qtev_rec.sfwt_flag := p0_a2;
    ddp_qtev_rec.qrs_code := p0_a3;
    ddp_qtev_rec.qst_code := p0_a4;
    ddp_qtev_rec.qtp_code := p0_a5;
    ddp_qtev_rec.trn_code := p0_a6;
    ddp_qtev_rec.pop_code_end := p0_a7;
    ddp_qtev_rec.pop_code_early := p0_a8;
    ddp_qtev_rec.consolidated_qte_id := rosetta_g_miss_num_map(p0_a9);
    ddp_qtev_rec.khr_id := rosetta_g_miss_num_map(p0_a10);
    ddp_qtev_rec.art_id := rosetta_g_miss_num_map(p0_a11);
    ddp_qtev_rec.pdt_id := rosetta_g_miss_num_map(p0_a12);
    ddp_qtev_rec.early_termination_yn := p0_a13;
    ddp_qtev_rec.partial_yn := p0_a14;
    ddp_qtev_rec.preproceeds_yn := p0_a15;
    ddp_qtev_rec.date_requested := rosetta_g_miss_date_in_map(p0_a16);
    ddp_qtev_rec.date_proposal := rosetta_g_miss_date_in_map(p0_a17);
    ddp_qtev_rec.date_effective_to := rosetta_g_miss_date_in_map(p0_a18);
    ddp_qtev_rec.date_accepted := rosetta_g_miss_date_in_map(p0_a19);
    ddp_qtev_rec.summary_format_yn := p0_a20;
    ddp_qtev_rec.consolidated_yn := p0_a21;
    ddp_qtev_rec.principal_paydown_amount := rosetta_g_miss_num_map(p0_a22);
    ddp_qtev_rec.residual_amount := rosetta_g_miss_num_map(p0_a23);
    ddp_qtev_rec.yield := rosetta_g_miss_num_map(p0_a24);
    ddp_qtev_rec.rent_amount := rosetta_g_miss_num_map(p0_a25);
    ddp_qtev_rec.date_restructure_end := rosetta_g_miss_date_in_map(p0_a26);
    ddp_qtev_rec.date_restructure_start := rosetta_g_miss_date_in_map(p0_a27);
    ddp_qtev_rec.term := rosetta_g_miss_num_map(p0_a28);
    ddp_qtev_rec.purchase_percent := rosetta_g_miss_num_map(p0_a29);
    ddp_qtev_rec.comments := p0_a30;
    ddp_qtev_rec.date_due := rosetta_g_miss_date_in_map(p0_a31);
    ddp_qtev_rec.payment_frequency := p0_a32;
    ddp_qtev_rec.remaining_payments := rosetta_g_miss_num_map(p0_a33);
    ddp_qtev_rec.date_effective_from := rosetta_g_miss_date_in_map(p0_a34);
    ddp_qtev_rec.quote_number := rosetta_g_miss_num_map(p0_a35);
    ddp_qtev_rec.requested_by := rosetta_g_miss_num_map(p0_a36);
    ddp_qtev_rec.approved_yn := p0_a37;
    ddp_qtev_rec.accepted_yn := p0_a38;
    ddp_qtev_rec.payment_received_yn := p0_a39;
    ddp_qtev_rec.date_payment_received := rosetta_g_miss_date_in_map(p0_a40);
    ddp_qtev_rec.attribute_category := p0_a41;
    ddp_qtev_rec.attribute1 := p0_a42;
    ddp_qtev_rec.attribute2 := p0_a43;
    ddp_qtev_rec.attribute3 := p0_a44;
    ddp_qtev_rec.attribute4 := p0_a45;
    ddp_qtev_rec.attribute5 := p0_a46;
    ddp_qtev_rec.attribute6 := p0_a47;
    ddp_qtev_rec.attribute7 := p0_a48;
    ddp_qtev_rec.attribute8 := p0_a49;
    ddp_qtev_rec.attribute9 := p0_a50;
    ddp_qtev_rec.attribute10 := p0_a51;
    ddp_qtev_rec.attribute11 := p0_a52;
    ddp_qtev_rec.attribute12 := p0_a53;
    ddp_qtev_rec.attribute13 := p0_a54;
    ddp_qtev_rec.attribute14 := p0_a55;
    ddp_qtev_rec.attribute15 := p0_a56;
    ddp_qtev_rec.date_approved := rosetta_g_miss_date_in_map(p0_a57);
    ddp_qtev_rec.approved_by := rosetta_g_miss_num_map(p0_a58);
    ddp_qtev_rec.org_id := rosetta_g_miss_num_map(p0_a59);
    ddp_qtev_rec.request_id := rosetta_g_miss_num_map(p0_a60);
    ddp_qtev_rec.program_application_id := rosetta_g_miss_num_map(p0_a61);
    ddp_qtev_rec.program_id := rosetta_g_miss_num_map(p0_a62);
    ddp_qtev_rec.program_update_date := rosetta_g_miss_date_in_map(p0_a63);
    ddp_qtev_rec.created_by := rosetta_g_miss_num_map(p0_a64);
    ddp_qtev_rec.creation_date := rosetta_g_miss_date_in_map(p0_a65);
    ddp_qtev_rec.last_updated_by := rosetta_g_miss_num_map(p0_a66);
    ddp_qtev_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a67);
    ddp_qtev_rec.last_update_login := rosetta_g_miss_num_map(p0_a68);
    ddp_qtev_rec.purchase_amount := rosetta_g_miss_num_map(p0_a69);
    ddp_qtev_rec.purchase_formula := p0_a70;
    ddp_qtev_rec.asset_value := rosetta_g_miss_num_map(p0_a71);
    ddp_qtev_rec.residual_value := rosetta_g_miss_num_map(p0_a72);
    ddp_qtev_rec.unbilled_receivables := rosetta_g_miss_num_map(p0_a73);
    ddp_qtev_rec.gain_loss := rosetta_g_miss_num_map(p0_a74);
    ddp_qtev_rec.currency_code := p0_a75;
    ddp_qtev_rec.currency_conversion_code := p0_a76;
    ddp_qtev_rec.currency_conversion_type := p0_a77;
    ddp_qtev_rec.currency_conversion_rate := rosetta_g_miss_num_map(p0_a78);
    ddp_qtev_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p0_a79);

    okl_qpy_pvt_w.rosetta_table_copy_in_p5(ddp_qpyv_tbl, p1_a0
      , p1_a1
      , p1_a2
      , p1_a3
      , p1_a4
      , p1_a5
      , p1_a6
      , p1_a7
      , p1_a8
      , p1_a9
      , p1_a10
      , p1_a11
      , p1_a12
      , p1_a13
      , p1_a14
      , p1_a15
      , p1_a16
      , p1_a17
      , p1_a18
      , p1_a19
      );

    if p_validate_only is null
      then ddp_validate_only := null;
    elsif p_validate_only = 0
      then ddp_validate_only := false;
    else ddp_validate_only := true;
    end if;



    -- here's the delegated call to the old PL/SQL routine
    okl_am_parties_pvt.create_quote_parties(ddp_qtev_rec,
      ddp_qpyv_tbl,
      ddp_validate_only,
      ddx_qpyv_tbl,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    okl_qpy_pvt_w.rosetta_table_copy_out_p5(ddx_qpyv_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      , p3_a9
      , p3_a10
      , p3_a11
      , p3_a12
      , p3_a13
      , p3_a14
      , p3_a15
      , p3_a16
      , p3_a17
      , p3_a18
      , p3_a19
      );

  end;

  procedure get_party_details(p_id_code  VARCHAR2
    , p_id_value  VARCHAR2
    , p2_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p2_a3 out nocopy JTF_VARCHAR2_TABLE_400
    , p2_a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , p2_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p2_a8 out nocopy JTF_VARCHAR2_TABLE_400
    , p2_a9 out nocopy JTF_VARCHAR2_TABLE_2000
    , p2_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p2_a13 out nocopy JTF_VARCHAR2_TABLE_400
    , p2_a14 out nocopy JTF_VARCHAR2_TABLE_2000
    , p2_a15 out nocopy JTF_VARCHAR2_TABLE_2000
    , p2_a16 out nocopy JTF_NUMBER_TABLE
    , p2_a17 out nocopy JTF_NUMBER_TABLE
    , p2_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a19 out nocopy JTF_VARCHAR2_TABLE_2000
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddx_party_object_tbl okl_am_parties_pvt.party_object_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    -- here's the delegated call to the old PL/SQL routine
    okl_am_parties_pvt.get_party_details(p_id_code,
      p_id_value,
      ddx_party_object_tbl,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    okl_am_parties_pvt_w.rosetta_table_copy_out_p3(ddx_party_object_tbl, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      , p2_a5
      , p2_a6
      , p2_a7
      , p2_a8
      , p2_a9
      , p2_a10
      , p2_a11
      , p2_a12
      , p2_a13
      , p2_a14
      , p2_a15
      , p2_a16
      , p2_a17
      , p2_a18
      , p2_a19
      );

  end;

  procedure get_quote_parties(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_DATE_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_DATE_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_DATE_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_400
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_400
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_DATE_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_DATE_TABLE
    , x_record_count out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  DATE := fnd_api.g_miss_date
  )

  as
    ddp_q_party_uv_rec okl_am_parties_pvt.q_party_uv_rec_type;
    ddx_q_party_uv_tbl okl_am_parties_pvt.q_party_uv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_q_party_uv_rec.quote_id := rosetta_g_miss_num_map(p5_a0);
    ddp_q_party_uv_rec.contract_id := rosetta_g_miss_num_map(p5_a1);
    ddp_q_party_uv_rec.k_buy_or_sell := p5_a2;
    ddp_q_party_uv_rec.qp_party_id := rosetta_g_miss_num_map(p5_a3);
    ddp_q_party_uv_rec.qp_role_code := p5_a4;
    ddp_q_party_uv_rec.qp_party_role := p5_a5;
    ddp_q_party_uv_rec.qp_date_sent := rosetta_g_miss_date_in_map(p5_a6);
    ddp_q_party_uv_rec.qp_date_hold := rosetta_g_miss_date_in_map(p5_a7);
    ddp_q_party_uv_rec.qp_created_by := rosetta_g_miss_num_map(p5_a8);
    ddp_q_party_uv_rec.qp_creation_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_q_party_uv_rec.qp_last_updated_by := rosetta_g_miss_num_map(p5_a10);
    ddp_q_party_uv_rec.qp_last_update_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_q_party_uv_rec.qp_last_update_login := rosetta_g_miss_num_map(p5_a12);
    ddp_q_party_uv_rec.kp_party_id := rosetta_g_miss_num_map(p5_a13);
    ddp_q_party_uv_rec.kp_role_code := p5_a14;
    ddp_q_party_uv_rec.kp_party_role := p5_a15;
    ddp_q_party_uv_rec.po_party_id1 := p5_a16;
    ddp_q_party_uv_rec.po_party_id2 := p5_a17;
    ddp_q_party_uv_rec.po_party_object := p5_a18;
    ddp_q_party_uv_rec.po_party_name := p5_a19;
    ddp_q_party_uv_rec.po_party_desc := p5_a20;
    ddp_q_party_uv_rec.co_contact_id1 := p5_a21;
    ddp_q_party_uv_rec.co_contact_id2 := p5_a22;
    ddp_q_party_uv_rec.co_contact_object := p5_a23;
    ddp_q_party_uv_rec.co_contact_name := p5_a24;
    ddp_q_party_uv_rec.co_contact_desc := p5_a25;
    ddp_q_party_uv_rec.co_email := p5_a26;
    ddp_q_party_uv_rec.co_order_num := rosetta_g_miss_num_map(p5_a27);
    ddp_q_party_uv_rec.co_date_sent := rosetta_g_miss_date_in_map(p5_a28);
    ddp_q_party_uv_rec.cp_point_id := rosetta_g_miss_num_map(p5_a29);
    ddp_q_party_uv_rec.cp_point_type := p5_a30;
    ddp_q_party_uv_rec.cp_primary_flag := p5_a31;
    ddp_q_party_uv_rec.cp_email := p5_a32;
    ddp_q_party_uv_rec.cp_details := p5_a33;
    ddp_q_party_uv_rec.cp_order_num := rosetta_g_miss_num_map(p5_a34);
    ddp_q_party_uv_rec.cp_date_sent := rosetta_g_miss_date_in_map(p5_a35);



    -- here's the delegated call to the old PL/SQL routine
    okl_am_parties_pvt.get_quote_parties(p_api_version,
      p_init_msg_list,
      x_msg_count,
      x_msg_data,
      x_return_status,
      ddp_q_party_uv_rec,
      ddx_q_party_uv_tbl,
      x_record_count);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_am_parties_pvt_w.rosetta_table_copy_out_p2(ddx_q_party_uv_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      , p6_a10
      , p6_a11
      , p6_a12
      , p6_a13
      , p6_a14
      , p6_a15
      , p6_a16
      , p6_a17
      , p6_a18
      , p6_a19
      , p6_a20
      , p6_a21
      , p6_a22
      , p6_a23
      , p6_a24
      , p6_a25
      , p6_a26
      , p6_a27
      , p6_a28
      , p6_a29
      , p6_a30
      , p6_a31
      , p6_a32
      , p6_a33
      , p6_a34
      , p6_a35
      );

  end;

  procedure get_quote_party_contacts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_DATE_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_DATE_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_DATE_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_400
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_400
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_DATE_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_DATE_TABLE
    , x_record_count out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  DATE := fnd_api.g_miss_date
  )

  as
    ddp_q_party_uv_rec okl_am_parties_pvt.q_party_uv_rec_type;
    ddx_q_party_uv_tbl okl_am_parties_pvt.q_party_uv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_q_party_uv_rec.quote_id := rosetta_g_miss_num_map(p5_a0);
    ddp_q_party_uv_rec.contract_id := rosetta_g_miss_num_map(p5_a1);
    ddp_q_party_uv_rec.k_buy_or_sell := p5_a2;
    ddp_q_party_uv_rec.qp_party_id := rosetta_g_miss_num_map(p5_a3);
    ddp_q_party_uv_rec.qp_role_code := p5_a4;
    ddp_q_party_uv_rec.qp_party_role := p5_a5;
    ddp_q_party_uv_rec.qp_date_sent := rosetta_g_miss_date_in_map(p5_a6);
    ddp_q_party_uv_rec.qp_date_hold := rosetta_g_miss_date_in_map(p5_a7);
    ddp_q_party_uv_rec.qp_created_by := rosetta_g_miss_num_map(p5_a8);
    ddp_q_party_uv_rec.qp_creation_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_q_party_uv_rec.qp_last_updated_by := rosetta_g_miss_num_map(p5_a10);
    ddp_q_party_uv_rec.qp_last_update_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_q_party_uv_rec.qp_last_update_login := rosetta_g_miss_num_map(p5_a12);
    ddp_q_party_uv_rec.kp_party_id := rosetta_g_miss_num_map(p5_a13);
    ddp_q_party_uv_rec.kp_role_code := p5_a14;
    ddp_q_party_uv_rec.kp_party_role := p5_a15;
    ddp_q_party_uv_rec.po_party_id1 := p5_a16;
    ddp_q_party_uv_rec.po_party_id2 := p5_a17;
    ddp_q_party_uv_rec.po_party_object := p5_a18;
    ddp_q_party_uv_rec.po_party_name := p5_a19;
    ddp_q_party_uv_rec.po_party_desc := p5_a20;
    ddp_q_party_uv_rec.co_contact_id1 := p5_a21;
    ddp_q_party_uv_rec.co_contact_id2 := p5_a22;
    ddp_q_party_uv_rec.co_contact_object := p5_a23;
    ddp_q_party_uv_rec.co_contact_name := p5_a24;
    ddp_q_party_uv_rec.co_contact_desc := p5_a25;
    ddp_q_party_uv_rec.co_email := p5_a26;
    ddp_q_party_uv_rec.co_order_num := rosetta_g_miss_num_map(p5_a27);
    ddp_q_party_uv_rec.co_date_sent := rosetta_g_miss_date_in_map(p5_a28);
    ddp_q_party_uv_rec.cp_point_id := rosetta_g_miss_num_map(p5_a29);
    ddp_q_party_uv_rec.cp_point_type := p5_a30;
    ddp_q_party_uv_rec.cp_primary_flag := p5_a31;
    ddp_q_party_uv_rec.cp_email := p5_a32;
    ddp_q_party_uv_rec.cp_details := p5_a33;
    ddp_q_party_uv_rec.cp_order_num := rosetta_g_miss_num_map(p5_a34);
    ddp_q_party_uv_rec.cp_date_sent := rosetta_g_miss_date_in_map(p5_a35);



    -- here's the delegated call to the old PL/SQL routine
    okl_am_parties_pvt.get_quote_party_contacts(p_api_version,
      p_init_msg_list,
      x_msg_count,
      x_msg_data,
      x_return_status,
      ddp_q_party_uv_rec,
      ddx_q_party_uv_tbl,
      x_record_count);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_am_parties_pvt_w.rosetta_table_copy_out_p2(ddx_q_party_uv_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      , p6_a10
      , p6_a11
      , p6_a12
      , p6_a13
      , p6_a14
      , p6_a15
      , p6_a16
      , p6_a17
      , p6_a18
      , p6_a19
      , p6_a20
      , p6_a21
      , p6_a22
      , p6_a23
      , p6_a24
      , p6_a25
      , p6_a26
      , p6_a27
      , p6_a28
      , p6_a29
      , p6_a30
      , p6_a31
      , p6_a32
      , p6_a33
      , p6_a34
      , p6_a35
      );

  end;

  procedure get_quote_contact_points(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_DATE_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_DATE_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_DATE_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_400
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_400
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_DATE_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_DATE_TABLE
    , x_record_count out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  DATE := fnd_api.g_miss_date
  )

  as
    ddp_q_party_uv_rec okl_am_parties_pvt.q_party_uv_rec_type;
    ddx_q_party_uv_tbl okl_am_parties_pvt.q_party_uv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_q_party_uv_rec.quote_id := rosetta_g_miss_num_map(p5_a0);
    ddp_q_party_uv_rec.contract_id := rosetta_g_miss_num_map(p5_a1);
    ddp_q_party_uv_rec.k_buy_or_sell := p5_a2;
    ddp_q_party_uv_rec.qp_party_id := rosetta_g_miss_num_map(p5_a3);
    ddp_q_party_uv_rec.qp_role_code := p5_a4;
    ddp_q_party_uv_rec.qp_party_role := p5_a5;
    ddp_q_party_uv_rec.qp_date_sent := rosetta_g_miss_date_in_map(p5_a6);
    ddp_q_party_uv_rec.qp_date_hold := rosetta_g_miss_date_in_map(p5_a7);
    ddp_q_party_uv_rec.qp_created_by := rosetta_g_miss_num_map(p5_a8);
    ddp_q_party_uv_rec.qp_creation_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_q_party_uv_rec.qp_last_updated_by := rosetta_g_miss_num_map(p5_a10);
    ddp_q_party_uv_rec.qp_last_update_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_q_party_uv_rec.qp_last_update_login := rosetta_g_miss_num_map(p5_a12);
    ddp_q_party_uv_rec.kp_party_id := rosetta_g_miss_num_map(p5_a13);
    ddp_q_party_uv_rec.kp_role_code := p5_a14;
    ddp_q_party_uv_rec.kp_party_role := p5_a15;
    ddp_q_party_uv_rec.po_party_id1 := p5_a16;
    ddp_q_party_uv_rec.po_party_id2 := p5_a17;
    ddp_q_party_uv_rec.po_party_object := p5_a18;
    ddp_q_party_uv_rec.po_party_name := p5_a19;
    ddp_q_party_uv_rec.po_party_desc := p5_a20;
    ddp_q_party_uv_rec.co_contact_id1 := p5_a21;
    ddp_q_party_uv_rec.co_contact_id2 := p5_a22;
    ddp_q_party_uv_rec.co_contact_object := p5_a23;
    ddp_q_party_uv_rec.co_contact_name := p5_a24;
    ddp_q_party_uv_rec.co_contact_desc := p5_a25;
    ddp_q_party_uv_rec.co_email := p5_a26;
    ddp_q_party_uv_rec.co_order_num := rosetta_g_miss_num_map(p5_a27);
    ddp_q_party_uv_rec.co_date_sent := rosetta_g_miss_date_in_map(p5_a28);
    ddp_q_party_uv_rec.cp_point_id := rosetta_g_miss_num_map(p5_a29);
    ddp_q_party_uv_rec.cp_point_type := p5_a30;
    ddp_q_party_uv_rec.cp_primary_flag := p5_a31;
    ddp_q_party_uv_rec.cp_email := p5_a32;
    ddp_q_party_uv_rec.cp_details := p5_a33;
    ddp_q_party_uv_rec.cp_order_num := rosetta_g_miss_num_map(p5_a34);
    ddp_q_party_uv_rec.cp_date_sent := rosetta_g_miss_date_in_map(p5_a35);



    -- here's the delegated call to the old PL/SQL routine
    okl_am_parties_pvt.get_quote_contact_points(p_api_version,
      p_init_msg_list,
      x_msg_count,
      x_msg_data,
      x_return_status,
      ddp_q_party_uv_rec,
      ddx_q_party_uv_tbl,
      x_record_count);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_am_parties_pvt_w.rosetta_table_copy_out_p2(ddx_q_party_uv_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      , p6_a10
      , p6_a11
      , p6_a12
      , p6_a13
      , p6_a14
      , p6_a15
      , p6_a16
      , p6_a17
      , p6_a18
      , p6_a19
      , p6_a20
      , p6_a21
      , p6_a22
      , p6_a23
      , p6_a24
      , p6_a25
      , p6_a26
      , p6_a27
      , p6_a28
      , p6_a29
      , p6_a30
      , p6_a31
      , p6_a32
      , p6_a33
      , p6_a34
      , p6_a35
      );

  end;

end okl_am_parties_pvt_w;

/
