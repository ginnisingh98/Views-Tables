--------------------------------------------------------
--  DDL for Package Body OKL_MASS_REBOOK_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_MASS_REBOOK_PVT_W" as
  /* $Header: OKLEMRPB.pls 120.3 2007/07/11 16:52:03 ssdeshpa ship $ */
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

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  procedure rosetta_table_copy_in_p31(t out nocopy okl_mass_rebook_pvt.crit_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_200
    , a3 JTF_VARCHAR2_TABLE_200
    , a4 JTF_VARCHAR2_TABLE_200
    , a5 JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).line_number := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).criteria_code := a1(indx);
          t(ddindx).operand := a2(indx);
          t(ddindx).criteria_value1 := a3(indx);
          t(ddindx).criteria_value2 := a4(indx);
          t(ddindx).set_value := a5(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p31;
  procedure rosetta_table_copy_out_p31(t okl_mass_rebook_pvt.crit_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    , a3 out nocopy JTF_VARCHAR2_TABLE_200
    , a4 out nocopy JTF_VARCHAR2_TABLE_200
    , a5 out nocopy JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_200();
    a3 := JTF_VARCHAR2_TABLE_200();
    a4 := JTF_VARCHAR2_TABLE_200();
    a5 := JTF_VARCHAR2_TABLE_200();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_200();
      a3 := JTF_VARCHAR2_TABLE_200();
      a4 := JTF_VARCHAR2_TABLE_200();
      a5 := JTF_VARCHAR2_TABLE_200();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).line_number);
          a1(indx) := t(ddindx).criteria_code;
          a2(indx) := t(ddindx).operand;
          a3(indx) := t(ddindx).criteria_value1;
          a4(indx) := t(ddindx).criteria_value2;
          a5(indx) := t(ddindx).set_value;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p31;

  procedure rosetta_table_copy_in_p33(t out nocopy okl_mass_rebook_pvt.rbk_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_600
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).khr_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).contract_number := a1(indx);
          t(ddindx).kle_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).description := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p33;
  procedure rosetta_table_copy_out_p33(t okl_mass_rebook_pvt.rbk_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_600
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_200();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_600();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_200();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_600();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).khr_id);
          a1(indx) := t(ddindx).contract_number;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).kle_id);
          a3(indx) := t(ddindx).description;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p33;

  procedure rosetta_table_copy_in_p35(t out nocopy okl_mass_rebook_pvt.strm_lalevl_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_500
    , a3 JTF_VARCHAR2_TABLE_500
    , a4 JTF_VARCHAR2_TABLE_500
    , a5 JTF_VARCHAR2_TABLE_500
    , a6 JTF_VARCHAR2_TABLE_500
    , a7 JTF_VARCHAR2_TABLE_500
    , a8 JTF_VARCHAR2_TABLE_500
    , a9 JTF_VARCHAR2_TABLE_500
    , a10 JTF_VARCHAR2_TABLE_500
    , a11 JTF_VARCHAR2_TABLE_500
    , a12 JTF_VARCHAR2_TABLE_500
    , a13 JTF_VARCHAR2_TABLE_500
    , a14 JTF_VARCHAR2_TABLE_500
    , a15 JTF_VARCHAR2_TABLE_500
    , a16 JTF_VARCHAR2_TABLE_500
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_200
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_200
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_200
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).chr_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).cle_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).rule_information1 := a2(indx);
          t(ddindx).rule_information2 := a3(indx);
          t(ddindx).rule_information3 := a4(indx);
          t(ddindx).rule_information4 := a5(indx);
          t(ddindx).rule_information5 := a6(indx);
          t(ddindx).rule_information6 := a7(indx);
          t(ddindx).rule_information7 := a8(indx);
          t(ddindx).rule_information8 := a9(indx);
          t(ddindx).rule_information9 := a10(indx);
          t(ddindx).rule_information10 := a11(indx);
          t(ddindx).rule_information11 := a12(indx);
          t(ddindx).rule_information12 := a13(indx);
          t(ddindx).rule_information13 := a14(indx);
          t(ddindx).rule_information14 := a15(indx);
          t(ddindx).rule_information15 := a16(indx);
          t(ddindx).rule_information_category := a17(indx);
          t(ddindx).object1_id1 := a18(indx);
          t(ddindx).object1_id2 := a19(indx);
          t(ddindx).object2_id1 := a20(indx);
          t(ddindx).object2_id2 := a21(indx);
          t(ddindx).object3_id1 := a22(indx);
          t(ddindx).object3_id2 := a23(indx);
          t(ddindx).jtot_object1_code := a24(indx);
          t(ddindx).jtot_object2_code := a25(indx);
          t(ddindx).jtot_object3_code := a26(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p35;
  procedure rosetta_table_copy_out_p35(t okl_mass_rebook_pvt.strm_lalevl_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_500
    , a3 out nocopy JTF_VARCHAR2_TABLE_500
    , a4 out nocopy JTF_VARCHAR2_TABLE_500
    , a5 out nocopy JTF_VARCHAR2_TABLE_500
    , a6 out nocopy JTF_VARCHAR2_TABLE_500
    , a7 out nocopy JTF_VARCHAR2_TABLE_500
    , a8 out nocopy JTF_VARCHAR2_TABLE_500
    , a9 out nocopy JTF_VARCHAR2_TABLE_500
    , a10 out nocopy JTF_VARCHAR2_TABLE_500
    , a11 out nocopy JTF_VARCHAR2_TABLE_500
    , a12 out nocopy JTF_VARCHAR2_TABLE_500
    , a13 out nocopy JTF_VARCHAR2_TABLE_500
    , a14 out nocopy JTF_VARCHAR2_TABLE_500
    , a15 out nocopy JTF_VARCHAR2_TABLE_500
    , a16 out nocopy JTF_VARCHAR2_TABLE_500
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_200
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_200
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_200
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_500();
    a3 := JTF_VARCHAR2_TABLE_500();
    a4 := JTF_VARCHAR2_TABLE_500();
    a5 := JTF_VARCHAR2_TABLE_500();
    a6 := JTF_VARCHAR2_TABLE_500();
    a7 := JTF_VARCHAR2_TABLE_500();
    a8 := JTF_VARCHAR2_TABLE_500();
    a9 := JTF_VARCHAR2_TABLE_500();
    a10 := JTF_VARCHAR2_TABLE_500();
    a11 := JTF_VARCHAR2_TABLE_500();
    a12 := JTF_VARCHAR2_TABLE_500();
    a13 := JTF_VARCHAR2_TABLE_500();
    a14 := JTF_VARCHAR2_TABLE_500();
    a15 := JTF_VARCHAR2_TABLE_500();
    a16 := JTF_VARCHAR2_TABLE_500();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_VARCHAR2_TABLE_200();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_VARCHAR2_TABLE_200();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_200();
    a24 := JTF_VARCHAR2_TABLE_100();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_500();
      a3 := JTF_VARCHAR2_TABLE_500();
      a4 := JTF_VARCHAR2_TABLE_500();
      a5 := JTF_VARCHAR2_TABLE_500();
      a6 := JTF_VARCHAR2_TABLE_500();
      a7 := JTF_VARCHAR2_TABLE_500();
      a8 := JTF_VARCHAR2_TABLE_500();
      a9 := JTF_VARCHAR2_TABLE_500();
      a10 := JTF_VARCHAR2_TABLE_500();
      a11 := JTF_VARCHAR2_TABLE_500();
      a12 := JTF_VARCHAR2_TABLE_500();
      a13 := JTF_VARCHAR2_TABLE_500();
      a14 := JTF_VARCHAR2_TABLE_500();
      a15 := JTF_VARCHAR2_TABLE_500();
      a16 := JTF_VARCHAR2_TABLE_500();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_VARCHAR2_TABLE_200();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_VARCHAR2_TABLE_200();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_200();
      a24 := JTF_VARCHAR2_TABLE_100();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).chr_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).cle_id);
          a2(indx) := t(ddindx).rule_information1;
          a3(indx) := t(ddindx).rule_information2;
          a4(indx) := t(ddindx).rule_information3;
          a5(indx) := t(ddindx).rule_information4;
          a6(indx) := t(ddindx).rule_information5;
          a7(indx) := t(ddindx).rule_information6;
          a8(indx) := t(ddindx).rule_information7;
          a9(indx) := t(ddindx).rule_information8;
          a10(indx) := t(ddindx).rule_information9;
          a11(indx) := t(ddindx).rule_information10;
          a12(indx) := t(ddindx).rule_information11;
          a13(indx) := t(ddindx).rule_information12;
          a14(indx) := t(ddindx).rule_information13;
          a15(indx) := t(ddindx).rule_information14;
          a16(indx) := t(ddindx).rule_information15;
          a17(indx) := t(ddindx).rule_information_category;
          a18(indx) := t(ddindx).object1_id1;
          a19(indx) := t(ddindx).object1_id2;
          a20(indx) := t(ddindx).object2_id1;
          a21(indx) := t(ddindx).object2_id2;
          a22(indx) := t(ddindx).object3_id1;
          a23(indx) := t(ddindx).object3_id2;
          a24(indx) := t(ddindx).jtot_object1_code;
          a25(indx) := t(ddindx).jtot_object2_code;
          a26(indx) := t(ddindx).jtot_object3_code;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p35;

  procedure rosetta_table_copy_in_p37(t out nocopy okl_mass_rebook_pvt.strm_trx_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).chr_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).trx_number := rosetta_g_miss_num_map(a1(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p37;
  procedure rosetta_table_copy_out_p37(t okl_mass_rebook_pvt.strm_trx_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).chr_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).trx_number);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p37;

  procedure rosetta_table_copy_in_p39(t out nocopy okl_mass_rebook_pvt.kle_tbl_type, a0 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p39;
  procedure rosetta_table_copy_out_p39(t okl_mass_rebook_pvt.kle_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p39;

  procedure build_and_get_contracts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_request_name  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_VARCHAR2_TABLE_600
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_VARCHAR2_TABLE_100
    , p6_a4 JTF_VARCHAR2_TABLE_100
    , p6_a5 JTF_VARCHAR2_TABLE_100
    , p6_a6 JTF_VARCHAR2_TABLE_600
    , p6_a7 JTF_VARCHAR2_TABLE_600
    , p6_a8 JTF_VARCHAR2_TABLE_600
    , p6_a9 JTF_VARCHAR2_TABLE_2000
    , p6_a10 JTF_VARCHAR2_TABLE_100
    , p6_a11 JTF_VARCHAR2_TABLE_100
    , p6_a12 JTF_VARCHAR2_TABLE_500
    , p6_a13 JTF_VARCHAR2_TABLE_500
    , p6_a14 JTF_VARCHAR2_TABLE_500
    , p6_a15 JTF_VARCHAR2_TABLE_500
    , p6_a16 JTF_VARCHAR2_TABLE_500
    , p6_a17 JTF_VARCHAR2_TABLE_500
    , p6_a18 JTF_VARCHAR2_TABLE_500
    , p6_a19 JTF_VARCHAR2_TABLE_500
    , p6_a20 JTF_VARCHAR2_TABLE_500
    , p6_a21 JTF_VARCHAR2_TABLE_500
    , p6_a22 JTF_VARCHAR2_TABLE_500
    , p6_a23 JTF_VARCHAR2_TABLE_500
    , p6_a24 JTF_VARCHAR2_TABLE_500
    , p6_a25 JTF_VARCHAR2_TABLE_500
    , p6_a26 JTF_VARCHAR2_TABLE_500
    , p6_a27 JTF_NUMBER_TABLE
    , p6_a28 JTF_DATE_TABLE
    , p6_a29 JTF_NUMBER_TABLE
    , p6_a30 JTF_DATE_TABLE
    , p6_a31 JTF_NUMBER_TABLE
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a2 out nocopy JTF_NUMBER_TABLE
    , p7_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a4 out nocopy JTF_VARCHAR2_TABLE_600
    , p7_a5 out nocopy JTF_NUMBER_TABLE
    , p7_a6 out nocopy JTF_NUMBER_TABLE
    , p7_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a25 out nocopy JTF_NUMBER_TABLE
    , p7_a26 out nocopy JTF_DATE_TABLE
    , p7_a27 out nocopy JTF_NUMBER_TABLE
    , p7_a28 out nocopy JTF_DATE_TABLE
    , p7_a29 out nocopy JTF_NUMBER_TABLE
    , p7_a30 out nocopy JTF_DATE_TABLE
    , x_rbk_count out nocopy  NUMBER
  )

  as
    ddp_mrbv_tbl okl_mass_rebook_pvt.mrbv_tbl_type;
    ddx_mstv_tbl okl_mass_rebook_pvt.mstv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    okl_mrb_pvt_w.rosetta_table_copy_in_p2(ddp_mrbv_tbl, p6_a0
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
      );



    -- here's the delegated call to the old PL/SQL routine
    okl_mass_rebook_pvt.build_and_get_contracts(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_request_name,
      ddp_mrbv_tbl,
      ddx_mstv_tbl,
      x_rbk_count);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    okl_mst_pvt_w.rosetta_table_copy_out_p2(ddx_mstv_tbl, p7_a0
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
      );

  end;

  procedure build_and_get_contracts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_request_name  VARCHAR2
    , p_transaction_date  date
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_VARCHAR2_TABLE_600
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_VARCHAR2_TABLE_100
    , p7_a4 JTF_VARCHAR2_TABLE_100
    , p7_a5 JTF_VARCHAR2_TABLE_100
    , p7_a6 JTF_VARCHAR2_TABLE_600
    , p7_a7 JTF_VARCHAR2_TABLE_600
    , p7_a8 JTF_VARCHAR2_TABLE_600
    , p7_a9 JTF_VARCHAR2_TABLE_2000
    , p7_a10 JTF_VARCHAR2_TABLE_100
    , p7_a11 JTF_VARCHAR2_TABLE_100
    , p7_a12 JTF_VARCHAR2_TABLE_500
    , p7_a13 JTF_VARCHAR2_TABLE_500
    , p7_a14 JTF_VARCHAR2_TABLE_500
    , p7_a15 JTF_VARCHAR2_TABLE_500
    , p7_a16 JTF_VARCHAR2_TABLE_500
    , p7_a17 JTF_VARCHAR2_TABLE_500
    , p7_a18 JTF_VARCHAR2_TABLE_500
    , p7_a19 JTF_VARCHAR2_TABLE_500
    , p7_a20 JTF_VARCHAR2_TABLE_500
    , p7_a21 JTF_VARCHAR2_TABLE_500
    , p7_a22 JTF_VARCHAR2_TABLE_500
    , p7_a23 JTF_VARCHAR2_TABLE_500
    , p7_a24 JTF_VARCHAR2_TABLE_500
    , p7_a25 JTF_VARCHAR2_TABLE_500
    , p7_a26 JTF_VARCHAR2_TABLE_500
    , p7_a27 JTF_NUMBER_TABLE
    , p7_a28 JTF_DATE_TABLE
    , p7_a29 JTF_NUMBER_TABLE
    , p7_a30 JTF_DATE_TABLE
    , p7_a31 JTF_NUMBER_TABLE
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a2 out nocopy JTF_NUMBER_TABLE
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_600
    , p8_a5 out nocopy JTF_NUMBER_TABLE
    , p8_a6 out nocopy JTF_NUMBER_TABLE
    , p8_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a25 out nocopy JTF_NUMBER_TABLE
    , p8_a26 out nocopy JTF_DATE_TABLE
    , p8_a27 out nocopy JTF_NUMBER_TABLE
    , p8_a28 out nocopy JTF_DATE_TABLE
    , p8_a29 out nocopy JTF_NUMBER_TABLE
    , p8_a30 out nocopy JTF_DATE_TABLE
    , x_rbk_count out nocopy  NUMBER
  )

  as
    ddp_transaction_date date;
    ddp_mrbv_tbl okl_mass_rebook_pvt.mrbv_tbl_type;
    ddx_mstv_tbl okl_mass_rebook_pvt.mstv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_transaction_date := rosetta_g_miss_date_in_map(p_transaction_date);

    okl_mrb_pvt_w.rosetta_table_copy_in_p2(ddp_mrbv_tbl, p7_a0
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
      );



    -- here's the delegated call to the old PL/SQL routine
    okl_mass_rebook_pvt.build_and_get_contracts(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_request_name,
      ddp_transaction_date,
      ddp_mrbv_tbl,
      ddx_mstv_tbl,
      x_rbk_count);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    okl_mst_pvt_w.rosetta_table_copy_out_p2(ddx_mstv_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      , p8_a8
      , p8_a9
      , p8_a10
      , p8_a11
      , p8_a12
      , p8_a13
      , p8_a14
      , p8_a15
      , p8_a16
      , p8_a17
      , p8_a18
      , p8_a19
      , p8_a20
      , p8_a21
      , p8_a22
      , p8_a23
      , p8_a24
      , p8_a25
      , p8_a26
      , p8_a27
      , p8_a28
      , p8_a29
      , p8_a30
      );

  end;

  procedure apply_mass_rebook(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_200
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_600
    , p_deprn_method_code  VARCHAR2
    , p_in_service_date  date
    , p_life_in_months  NUMBER
    , p_basic_rate  NUMBER
    , p_adjusted_rate  NUMBER
    , p_residual_value  NUMBER
    , p12_a0 JTF_NUMBER_TABLE
    , p12_a1 JTF_NUMBER_TABLE
    , p12_a2 JTF_VARCHAR2_TABLE_500
    , p12_a3 JTF_VARCHAR2_TABLE_500
    , p12_a4 JTF_VARCHAR2_TABLE_500
    , p12_a5 JTF_VARCHAR2_TABLE_500
    , p12_a6 JTF_VARCHAR2_TABLE_500
    , p12_a7 JTF_VARCHAR2_TABLE_500
    , p12_a8 JTF_VARCHAR2_TABLE_500
    , p12_a9 JTF_VARCHAR2_TABLE_500
    , p12_a10 JTF_VARCHAR2_TABLE_500
    , p12_a11 JTF_VARCHAR2_TABLE_500
    , p12_a12 JTF_VARCHAR2_TABLE_500
    , p12_a13 JTF_VARCHAR2_TABLE_500
    , p12_a14 JTF_VARCHAR2_TABLE_500
    , p12_a15 JTF_VARCHAR2_TABLE_500
    , p12_a16 JTF_VARCHAR2_TABLE_500
    , p12_a17 JTF_VARCHAR2_TABLE_100
    , p12_a18 JTF_VARCHAR2_TABLE_100
    , p12_a19 JTF_VARCHAR2_TABLE_200
    , p12_a20 JTF_VARCHAR2_TABLE_100
    , p12_a21 JTF_VARCHAR2_TABLE_200
    , p12_a22 JTF_VARCHAR2_TABLE_100
    , p12_a23 JTF_VARCHAR2_TABLE_200
    , p12_a24 JTF_VARCHAR2_TABLE_100
    , p12_a25 JTF_VARCHAR2_TABLE_100
    , p12_a26 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_rbk_tbl okl_mass_rebook_pvt.rbk_tbl_type;
    ddp_in_service_date date;
    ddp_strm_lalevl_tbl okl_mass_rebook_pvt.strm_lalevl_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_mass_rebook_pvt_w.rosetta_table_copy_in_p33(ddp_rbk_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      );


    ddp_in_service_date := rosetta_g_miss_date_in_map(p_in_service_date);





    okl_mass_rebook_pvt_w.rosetta_table_copy_in_p35(ddp_strm_lalevl_tbl, p12_a0
      , p12_a1
      , p12_a2
      , p12_a3
      , p12_a4
      , p12_a5
      , p12_a6
      , p12_a7
      , p12_a8
      , p12_a9
      , p12_a10
      , p12_a11
      , p12_a12
      , p12_a13
      , p12_a14
      , p12_a15
      , p12_a16
      , p12_a17
      , p12_a18
      , p12_a19
      , p12_a20
      , p12_a21
      , p12_a22
      , p12_a23
      , p12_a24
      , p12_a25
      , p12_a26
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_mass_rebook_pvt.apply_mass_rebook(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rbk_tbl,
      p_deprn_method_code,
      ddp_in_service_date,
      p_life_in_months,
      p_basic_rate,
      p_adjusted_rate,
      p_residual_value,
      ddp_strm_lalevl_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












  end;

  procedure apply_mass_rebook(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_200
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_600
    , p_deprn_method_code  VARCHAR2
    , p_in_service_date  date
    , p_life_in_months  NUMBER
    , p_basic_rate  NUMBER
    , p_adjusted_rate  NUMBER
    , p_residual_value  NUMBER
    , p12_a0 JTF_NUMBER_TABLE
    , p12_a1 JTF_NUMBER_TABLE
    , p12_a2 JTF_VARCHAR2_TABLE_500
    , p12_a3 JTF_VARCHAR2_TABLE_500
    , p12_a4 JTF_VARCHAR2_TABLE_500
    , p12_a5 JTF_VARCHAR2_TABLE_500
    , p12_a6 JTF_VARCHAR2_TABLE_500
    , p12_a7 JTF_VARCHAR2_TABLE_500
    , p12_a8 JTF_VARCHAR2_TABLE_500
    , p12_a9 JTF_VARCHAR2_TABLE_500
    , p12_a10 JTF_VARCHAR2_TABLE_500
    , p12_a11 JTF_VARCHAR2_TABLE_500
    , p12_a12 JTF_VARCHAR2_TABLE_500
    , p12_a13 JTF_VARCHAR2_TABLE_500
    , p12_a14 JTF_VARCHAR2_TABLE_500
    , p12_a15 JTF_VARCHAR2_TABLE_500
    , p12_a16 JTF_VARCHAR2_TABLE_500
    , p12_a17 JTF_VARCHAR2_TABLE_100
    , p12_a18 JTF_VARCHAR2_TABLE_100
    , p12_a19 JTF_VARCHAR2_TABLE_200
    , p12_a20 JTF_VARCHAR2_TABLE_100
    , p12_a21 JTF_VARCHAR2_TABLE_200
    , p12_a22 JTF_VARCHAR2_TABLE_100
    , p12_a23 JTF_VARCHAR2_TABLE_200
    , p12_a24 JTF_VARCHAR2_TABLE_100
    , p12_a25 JTF_VARCHAR2_TABLE_100
    , p12_a26 JTF_VARCHAR2_TABLE_100
    , p13_a0 out nocopy JTF_NUMBER_TABLE
    , p13_a1 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_rbk_tbl okl_mass_rebook_pvt.rbk_tbl_type;
    ddp_in_service_date date;
    ddp_strm_lalevl_tbl okl_mass_rebook_pvt.strm_lalevl_tbl_type;
    ddx_stream_trx_tbl okl_mass_rebook_pvt.strm_trx_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_mass_rebook_pvt_w.rosetta_table_copy_in_p33(ddp_rbk_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      );


    ddp_in_service_date := rosetta_g_miss_date_in_map(p_in_service_date);





    okl_mass_rebook_pvt_w.rosetta_table_copy_in_p35(ddp_strm_lalevl_tbl, p12_a0
      , p12_a1
      , p12_a2
      , p12_a3
      , p12_a4
      , p12_a5
      , p12_a6
      , p12_a7
      , p12_a8
      , p12_a9
      , p12_a10
      , p12_a11
      , p12_a12
      , p12_a13
      , p12_a14
      , p12_a15
      , p12_a16
      , p12_a17
      , p12_a18
      , p12_a19
      , p12_a20
      , p12_a21
      , p12_a22
      , p12_a23
      , p12_a24
      , p12_a25
      , p12_a26
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_mass_rebook_pvt.apply_mass_rebook(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rbk_tbl,
      p_deprn_method_code,
      ddp_in_service_date,
      p_life_in_months,
      p_basic_rate,
      p_adjusted_rate,
      p_residual_value,
      ddp_strm_lalevl_tbl,
      ddx_stream_trx_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













    okl_mass_rebook_pvt_w.rosetta_table_copy_out_p37(ddx_stream_trx_tbl, p13_a0
      , p13_a1
      );
  end;

  procedure apply_mass_rebook(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_200
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_600
    , p_deprn_method_code  VARCHAR2
    , p_in_service_date  date
    , p_life_in_months  NUMBER
    , p_basic_rate  NUMBER
    , p_adjusted_rate  NUMBER
    , p_residual_value  NUMBER
    , p12_a0 JTF_NUMBER_TABLE
    , p12_a1 JTF_NUMBER_TABLE
    , p12_a2 JTF_VARCHAR2_TABLE_500
    , p12_a3 JTF_VARCHAR2_TABLE_500
    , p12_a4 JTF_VARCHAR2_TABLE_500
    , p12_a5 JTF_VARCHAR2_TABLE_500
    , p12_a6 JTF_VARCHAR2_TABLE_500
    , p12_a7 JTF_VARCHAR2_TABLE_500
    , p12_a8 JTF_VARCHAR2_TABLE_500
    , p12_a9 JTF_VARCHAR2_TABLE_500
    , p12_a10 JTF_VARCHAR2_TABLE_500
    , p12_a11 JTF_VARCHAR2_TABLE_500
    , p12_a12 JTF_VARCHAR2_TABLE_500
    , p12_a13 JTF_VARCHAR2_TABLE_500
    , p12_a14 JTF_VARCHAR2_TABLE_500
    , p12_a15 JTF_VARCHAR2_TABLE_500
    , p12_a16 JTF_VARCHAR2_TABLE_500
    , p12_a17 JTF_VARCHAR2_TABLE_100
    , p12_a18 JTF_VARCHAR2_TABLE_100
    , p12_a19 JTF_VARCHAR2_TABLE_200
    , p12_a20 JTF_VARCHAR2_TABLE_100
    , p12_a21 JTF_VARCHAR2_TABLE_200
    , p12_a22 JTF_VARCHAR2_TABLE_100
    , p12_a23 JTF_VARCHAR2_TABLE_200
    , p12_a24 JTF_VARCHAR2_TABLE_100
    , p12_a25 JTF_VARCHAR2_TABLE_100
    , p12_a26 JTF_VARCHAR2_TABLE_100
    , p_transaction_date  date
    , p14_a0 out nocopy JTF_NUMBER_TABLE
    , p14_a1 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_rbk_tbl okl_mass_rebook_pvt.rbk_tbl_type;
    ddp_in_service_date date;
    ddp_strm_lalevl_tbl okl_mass_rebook_pvt.strm_lalevl_tbl_type;
    ddp_transaction_date date;
    ddx_stream_trx_tbl okl_mass_rebook_pvt.strm_trx_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_mass_rebook_pvt_w.rosetta_table_copy_in_p33(ddp_rbk_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      );


    ddp_in_service_date := rosetta_g_miss_date_in_map(p_in_service_date);





    okl_mass_rebook_pvt_w.rosetta_table_copy_in_p35(ddp_strm_lalevl_tbl, p12_a0
      , p12_a1
      , p12_a2
      , p12_a3
      , p12_a4
      , p12_a5
      , p12_a6
      , p12_a7
      , p12_a8
      , p12_a9
      , p12_a10
      , p12_a11
      , p12_a12
      , p12_a13
      , p12_a14
      , p12_a15
      , p12_a16
      , p12_a17
      , p12_a18
      , p12_a19
      , p12_a20
      , p12_a21
      , p12_a22
      , p12_a23
      , p12_a24
      , p12_a25
      , p12_a26
      );

    ddp_transaction_date := rosetta_g_miss_date_in_map(p_transaction_date);


    -- here's the delegated call to the old PL/SQL routine
    okl_mass_rebook_pvt.apply_mass_rebook(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rbk_tbl,
      p_deprn_method_code,
      ddp_in_service_date,
      p_life_in_months,
      p_basic_rate,
      p_adjusted_rate,
      p_residual_value,
      ddp_strm_lalevl_tbl,
      ddp_transaction_date,
      ddx_stream_trx_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














    okl_mass_rebook_pvt_w.rosetta_table_copy_out_p37(ddx_stream_trx_tbl, p14_a0
      , p14_a1
      );
  end;

  procedure apply_mass_rebook(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_200
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_600
    , p_deprn_method_code  VARCHAR2
    , p_in_service_date  date
    , p_life_in_months  NUMBER
    , p_basic_rate  NUMBER
    , p_adjusted_rate  NUMBER
    , p_residual_value  NUMBER
    , p12_a0 JTF_NUMBER_TABLE
    , p12_a1 JTF_NUMBER_TABLE
    , p12_a2 JTF_VARCHAR2_TABLE_500
    , p12_a3 JTF_VARCHAR2_TABLE_500
    , p12_a4 JTF_VARCHAR2_TABLE_500
    , p12_a5 JTF_VARCHAR2_TABLE_500
    , p12_a6 JTF_VARCHAR2_TABLE_500
    , p12_a7 JTF_VARCHAR2_TABLE_500
    , p12_a8 JTF_VARCHAR2_TABLE_500
    , p12_a9 JTF_VARCHAR2_TABLE_500
    , p12_a10 JTF_VARCHAR2_TABLE_500
    , p12_a11 JTF_VARCHAR2_TABLE_500
    , p12_a12 JTF_VARCHAR2_TABLE_500
    , p12_a13 JTF_VARCHAR2_TABLE_500
    , p12_a14 JTF_VARCHAR2_TABLE_500
    , p12_a15 JTF_VARCHAR2_TABLE_500
    , p12_a16 JTF_VARCHAR2_TABLE_500
    , p12_a17 JTF_VARCHAR2_TABLE_100
    , p12_a18 JTF_VARCHAR2_TABLE_100
    , p12_a19 JTF_VARCHAR2_TABLE_200
    , p12_a20 JTF_VARCHAR2_TABLE_100
    , p12_a21 JTF_VARCHAR2_TABLE_200
    , p12_a22 JTF_VARCHAR2_TABLE_100
    , p12_a23 JTF_VARCHAR2_TABLE_200
    , p12_a24 JTF_VARCHAR2_TABLE_100
    , p12_a25 JTF_VARCHAR2_TABLE_100
    , p12_a26 JTF_VARCHAR2_TABLE_100
    , p_source_trx_id  NUMBER
    , p_source_trx_type  VARCHAR2
    , x_mass_rebook_trx_id out nocopy  NUMBER
  )

  as
    ddp_rbk_tbl okl_mass_rebook_pvt.rbk_tbl_type;
    ddp_in_service_date date;
    ddp_strm_lalevl_tbl okl_mass_rebook_pvt.strm_lalevl_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_mass_rebook_pvt_w.rosetta_table_copy_in_p33(ddp_rbk_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      );


    ddp_in_service_date := rosetta_g_miss_date_in_map(p_in_service_date);





    okl_mass_rebook_pvt_w.rosetta_table_copy_in_p35(ddp_strm_lalevl_tbl, p12_a0
      , p12_a1
      , p12_a2
      , p12_a3
      , p12_a4
      , p12_a5
      , p12_a6
      , p12_a7
      , p12_a8
      , p12_a9
      , p12_a10
      , p12_a11
      , p12_a12
      , p12_a13
      , p12_a14
      , p12_a15
      , p12_a16
      , p12_a17
      , p12_a18
      , p12_a19
      , p12_a20
      , p12_a21
      , p12_a22
      , p12_a23
      , p12_a24
      , p12_a25
      , p12_a26
      );




    -- here's the delegated call to the old PL/SQL routine
    okl_mass_rebook_pvt.apply_mass_rebook(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rbk_tbl,
      p_deprn_method_code,
      ddp_in_service_date,
      p_life_in_months,
      p_basic_rate,
      p_adjusted_rate,
      p_residual_value,
      ddp_strm_lalevl_tbl,
      p_source_trx_id,
      p_source_trx_type,
      x_mass_rebook_trx_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any















  end;

  procedure apply_mass_rebook(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_200
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_600
    , p_deprn_method_code  VARCHAR2
    , p_in_service_date  date
    , p_life_in_months  NUMBER
    , p_basic_rate  NUMBER
    , p_adjusted_rate  NUMBER
    , p_residual_value  NUMBER
    , p12_a0 JTF_NUMBER_TABLE
    , p12_a1 JTF_NUMBER_TABLE
    , p12_a2 JTF_VARCHAR2_TABLE_500
    , p12_a3 JTF_VARCHAR2_TABLE_500
    , p12_a4 JTF_VARCHAR2_TABLE_500
    , p12_a5 JTF_VARCHAR2_TABLE_500
    , p12_a6 JTF_VARCHAR2_TABLE_500
    , p12_a7 JTF_VARCHAR2_TABLE_500
    , p12_a8 JTF_VARCHAR2_TABLE_500
    , p12_a9 JTF_VARCHAR2_TABLE_500
    , p12_a10 JTF_VARCHAR2_TABLE_500
    , p12_a11 JTF_VARCHAR2_TABLE_500
    , p12_a12 JTF_VARCHAR2_TABLE_500
    , p12_a13 JTF_VARCHAR2_TABLE_500
    , p12_a14 JTF_VARCHAR2_TABLE_500
    , p12_a15 JTF_VARCHAR2_TABLE_500
    , p12_a16 JTF_VARCHAR2_TABLE_500
    , p12_a17 JTF_VARCHAR2_TABLE_100
    , p12_a18 JTF_VARCHAR2_TABLE_100
    , p12_a19 JTF_VARCHAR2_TABLE_200
    , p12_a20 JTF_VARCHAR2_TABLE_100
    , p12_a21 JTF_VARCHAR2_TABLE_200
    , p12_a22 JTF_VARCHAR2_TABLE_100
    , p12_a23 JTF_VARCHAR2_TABLE_200
    , p12_a24 JTF_VARCHAR2_TABLE_100
    , p12_a25 JTF_VARCHAR2_TABLE_100
    , p12_a26 JTF_VARCHAR2_TABLE_100
    , p_source_trx_id  NUMBER
    , p_source_trx_type  VARCHAR2
    , p_transaction_date  date
    , x_mass_rebook_trx_id out nocopy  NUMBER
  )

  as
    ddp_rbk_tbl okl_mass_rebook_pvt.rbk_tbl_type;
    ddp_in_service_date date;
    ddp_strm_lalevl_tbl okl_mass_rebook_pvt.strm_lalevl_tbl_type;
    ddp_transaction_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_mass_rebook_pvt_w.rosetta_table_copy_in_p33(ddp_rbk_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      );


    ddp_in_service_date := rosetta_g_miss_date_in_map(p_in_service_date);





    okl_mass_rebook_pvt_w.rosetta_table_copy_in_p35(ddp_strm_lalevl_tbl, p12_a0
      , p12_a1
      , p12_a2
      , p12_a3
      , p12_a4
      , p12_a5
      , p12_a6
      , p12_a7
      , p12_a8
      , p12_a9
      , p12_a10
      , p12_a11
      , p12_a12
      , p12_a13
      , p12_a14
      , p12_a15
      , p12_a16
      , p12_a17
      , p12_a18
      , p12_a19
      , p12_a20
      , p12_a21
      , p12_a22
      , p12_a23
      , p12_a24
      , p12_a25
      , p12_a26
      );



    ddp_transaction_date := rosetta_g_miss_date_in_map(p_transaction_date);


    -- here's the delegated call to the old PL/SQL routine
    okl_mass_rebook_pvt.apply_mass_rebook(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rbk_tbl,
      p_deprn_method_code,
      ddp_in_service_date,
      p_life_in_months,
      p_basic_rate,
      p_adjusted_rate,
      p_residual_value,
      ddp_strm_lalevl_tbl,
      p_source_trx_id,
      p_source_trx_type,
      ddp_transaction_date,
      x_mass_rebook_trx_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
















  end;

  procedure apply_mass_rebook(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p6_a0 JTF_NUMBER_TABLE
    , p_source_trx_id  NUMBER
    , p_source_trx_type  VARCHAR2
    , p_transaction_date  date
    , x_mass_rebook_trx_id out nocopy  NUMBER
    , p_ppd_amount  NUMBER
    , p_ppd_reason_code  VARCHAR2
    , p13_a0 JTF_NUMBER_TABLE
    , p13_a1 JTF_NUMBER_TABLE
    , p13_a2 JTF_VARCHAR2_TABLE_500
    , p13_a3 JTF_VARCHAR2_TABLE_500
    , p13_a4 JTF_VARCHAR2_TABLE_500
    , p13_a5 JTF_VARCHAR2_TABLE_500
    , p13_a6 JTF_VARCHAR2_TABLE_500
    , p13_a7 JTF_VARCHAR2_TABLE_500
    , p13_a8 JTF_VARCHAR2_TABLE_500
    , p13_a9 JTF_VARCHAR2_TABLE_500
    , p13_a10 JTF_VARCHAR2_TABLE_500
    , p13_a11 JTF_VARCHAR2_TABLE_500
    , p13_a12 JTF_VARCHAR2_TABLE_500
    , p13_a13 JTF_VARCHAR2_TABLE_500
    , p13_a14 JTF_VARCHAR2_TABLE_500
    , p13_a15 JTF_VARCHAR2_TABLE_500
    , p13_a16 JTF_VARCHAR2_TABLE_500
    , p13_a17 JTF_VARCHAR2_TABLE_100
    , p13_a18 JTF_VARCHAR2_TABLE_100
    , p13_a19 JTF_VARCHAR2_TABLE_200
    , p13_a20 JTF_VARCHAR2_TABLE_100
    , p13_a21 JTF_VARCHAR2_TABLE_200
    , p13_a22 JTF_VARCHAR2_TABLE_100
    , p13_a23 JTF_VARCHAR2_TABLE_200
    , p13_a24 JTF_VARCHAR2_TABLE_100
    , p13_a25 JTF_VARCHAR2_TABLE_100
    , p13_a26 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_kle_tbl okl_mass_rebook_pvt.kle_tbl_type;
    ddp_transaction_date date;
    ddp_payment_struc okl_mass_rebook_pvt.strm_lalevl_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    okl_mass_rebook_pvt_w.rosetta_table_copy_in_p39(ddp_kle_tbl, p6_a0
      );



    ddp_transaction_date := rosetta_g_miss_date_in_map(p_transaction_date);




    okl_mass_rebook_pvt_w.rosetta_table_copy_in_p35(ddp_payment_struc, p13_a0
      , p13_a1
      , p13_a2
      , p13_a3
      , p13_a4
      , p13_a5
      , p13_a6
      , p13_a7
      , p13_a8
      , p13_a9
      , p13_a10
      , p13_a11
      , p13_a12
      , p13_a13
      , p13_a14
      , p13_a15
      , p13_a16
      , p13_a17
      , p13_a18
      , p13_a19
      , p13_a20
      , p13_a21
      , p13_a22
      , p13_a23
      , p13_a24
      , p13_a25
      , p13_a26
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_mass_rebook_pvt.apply_mass_rebook(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_chr_id,
      ddp_kle_tbl,
      p_source_trx_id,
      p_source_trx_type,
      ddp_transaction_date,
      x_mass_rebook_trx_id,
      p_ppd_amount,
      p_ppd_reason_code,
      ddp_payment_struc);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













  end;

  procedure update_mass_rbk_contract(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_200
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_VARCHAR2_TABLE_600
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_500
    , p5_a11 JTF_VARCHAR2_TABLE_500
    , p5_a12 JTF_VARCHAR2_TABLE_500
    , p5_a13 JTF_VARCHAR2_TABLE_500
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_VARCHAR2_TABLE_500
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_DATE_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_600
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a25 out nocopy JTF_NUMBER_TABLE
    , p6_a26 out nocopy JTF_DATE_TABLE
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_DATE_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_DATE_TABLE
  )

  as
    ddp_mstv_tbl okl_mass_rebook_pvt.mstv_tbl_type;
    ddx_mstv_tbl okl_mass_rebook_pvt.mstv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_mst_pvt_w.rosetta_table_copy_in_p2(ddp_mstv_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_mass_rebook_pvt.update_mass_rbk_contract(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_mstv_tbl,
      ddx_mstv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_mst_pvt_w.rosetta_table_copy_out_p2(ddx_mstv_tbl, p6_a0
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
      );
  end;

  procedure create_mass_rbk_set_values(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_request_name  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_VARCHAR2_TABLE_600
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_VARCHAR2_TABLE_100
    , p6_a4 JTF_VARCHAR2_TABLE_100
    , p6_a5 JTF_VARCHAR2_TABLE_100
    , p6_a6 JTF_VARCHAR2_TABLE_600
    , p6_a7 JTF_VARCHAR2_TABLE_600
    , p6_a8 JTF_VARCHAR2_TABLE_600
    , p6_a9 JTF_VARCHAR2_TABLE_2000
    , p6_a10 JTF_VARCHAR2_TABLE_100
    , p6_a11 JTF_VARCHAR2_TABLE_100
    , p6_a12 JTF_VARCHAR2_TABLE_500
    , p6_a13 JTF_VARCHAR2_TABLE_500
    , p6_a14 JTF_VARCHAR2_TABLE_500
    , p6_a15 JTF_VARCHAR2_TABLE_500
    , p6_a16 JTF_VARCHAR2_TABLE_500
    , p6_a17 JTF_VARCHAR2_TABLE_500
    , p6_a18 JTF_VARCHAR2_TABLE_500
    , p6_a19 JTF_VARCHAR2_TABLE_500
    , p6_a20 JTF_VARCHAR2_TABLE_500
    , p6_a21 JTF_VARCHAR2_TABLE_500
    , p6_a22 JTF_VARCHAR2_TABLE_500
    , p6_a23 JTF_VARCHAR2_TABLE_500
    , p6_a24 JTF_VARCHAR2_TABLE_500
    , p6_a25 JTF_VARCHAR2_TABLE_500
    , p6_a26 JTF_VARCHAR2_TABLE_500
    , p6_a27 JTF_NUMBER_TABLE
    , p6_a28 JTF_DATE_TABLE
    , p6_a29 JTF_NUMBER_TABLE
    , p6_a30 JTF_DATE_TABLE
    , p6_a31 JTF_NUMBER_TABLE
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_VARCHAR2_TABLE_600
    , p7_a2 out nocopy JTF_NUMBER_TABLE
    , p7_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a6 out nocopy JTF_VARCHAR2_TABLE_600
    , p7_a7 out nocopy JTF_VARCHAR2_TABLE_600
    , p7_a8 out nocopy JTF_VARCHAR2_TABLE_600
    , p7_a9 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a27 out nocopy JTF_NUMBER_TABLE
    , p7_a28 out nocopy JTF_DATE_TABLE
    , p7_a29 out nocopy JTF_NUMBER_TABLE
    , p7_a30 out nocopy JTF_DATE_TABLE
    , p7_a31 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_mrbv_tbl okl_mass_rebook_pvt.mrbv_tbl_type;
    ddx_mrbv_tbl okl_mass_rebook_pvt.mrbv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    okl_mrb_pvt_w.rosetta_table_copy_in_p2(ddp_mrbv_tbl, p6_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_mass_rebook_pvt.create_mass_rbk_set_values(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_request_name,
      ddp_mrbv_tbl,
      ddx_mrbv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    okl_mrb_pvt_w.rosetta_table_copy_out_p2(ddx_mrbv_tbl, p7_a0
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
      );
  end;

end okl_mass_rebook_pvt_w;

/
