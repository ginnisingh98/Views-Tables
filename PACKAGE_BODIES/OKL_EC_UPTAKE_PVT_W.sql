--------------------------------------------------------
--  DDL for Package Body OKL_EC_UPTAKE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_EC_UPTAKE_PVT_W" as
  /* $Header: OKLEECXB.pls 120.7 2006/03/08 11:34:39 ssdeshpa noship $ */
  procedure rosetta_table_copy_in_p18(t out nocopy okl_ec_uptake_pvt.okl_number_table_type, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p18;
  procedure rosetta_table_copy_out_p18(t okl_ec_uptake_pvt.okl_number_table_type, a0 out nocopy JTF_NUMBER_TABLE) as
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
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p18;

  procedure rosetta_table_copy_in_p19(t out nocopy okl_ec_uptake_pvt.okl_varchar2_table_type, a0 JTF_VARCHAR2_TABLE_300) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p19;
  procedure rosetta_table_copy_out_p19(t okl_ec_uptake_pvt.okl_varchar2_table_type, a0 out nocopy JTF_VARCHAR2_TABLE_300) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_VARCHAR2_TABLE_300();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p19;

  procedure rosetta_table_copy_in_p20(t out nocopy okl_ec_uptake_pvt.okl_date_tabe_type, a0 JTF_DATE_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p20;
  procedure rosetta_table_copy_out_p20(t okl_ec_uptake_pvt.okl_date_tabe_type, a0 out nocopy JTF_DATE_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_DATE_TABLE();
  else
      a0 := JTF_DATE_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p20;

  procedure rosetta_table_copy_in_p22(t out nocopy okl_ec_uptake_pvt.okl_qa_result_tbl_type, a0 JTF_VARCHAR2_TABLE_300
    , a1 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).message := a0(indx);
          t(ddindx).status := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p22;
  procedure rosetta_table_copy_out_p22(t okl_ec_uptake_pvt.okl_qa_result_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_300
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_300();
    a1 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_300();
      a1 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).message;
          a1(indx) := t(ddindx).status;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p22;

  procedure rosetta_table_copy_in_p24(t out nocopy okl_ec_uptake_pvt.okl_lease_rate_set_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_200
    , a4 JTF_VARCHAR2_TABLE_2000
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := a0(indx);
          t(ddindx).rate_set_version_id := a1(indx);
          t(ddindx).version_number := a2(indx);
          t(ddindx).name := a3(indx);
          t(ddindx).description := a4(indx);
          t(ddindx).effective_from := a5(indx);
          t(ddindx).effective_to := a6(indx);
          t(ddindx).lrs_rate := a7(indx);
          t(ddindx).sts_code := a8(indx);
          t(ddindx).frq_code := a9(indx);
          t(ddindx).frq_meaning := a10(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p24;
  procedure rosetta_table_copy_out_p24(t okl_ec_uptake_pvt.okl_lease_rate_set_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_200
    , a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_200();
    a4 := JTF_VARCHAR2_TABLE_2000();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_200();
      a4 := JTF_VARCHAR2_TABLE_2000();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_300();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).id;
          a1(indx) := t(ddindx).rate_set_version_id;
          a2(indx) := t(ddindx).version_number;
          a3(indx) := t(ddindx).name;
          a4(indx) := t(ddindx).description;
          a5(indx) := t(ddindx).effective_from;
          a6(indx) := t(ddindx).effective_to;
          a7(indx) := t(ddindx).lrs_rate;
          a8(indx) := t(ddindx).sts_code;
          a9(indx) := t(ddindx).frq_code;
          a10(indx) := t(ddindx).frq_meaning;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p24;

  procedure rosetta_table_copy_in_p26(t out nocopy okl_ec_uptake_pvt.okl_std_rate_tmpl_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_VARCHAR2_TABLE_2000
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_DATE_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := a0(indx);
          t(ddindx).std_rate_tmpl_ver_id := a1(indx);
          t(ddindx).version_number := a2(indx);
          t(ddindx).name := a3(indx);
          t(ddindx).description := a4(indx);
          t(ddindx).frq_code := a5(indx);
          t(ddindx).effective_from := a6(indx);
          t(ddindx).effective_to := a7(indx);
          t(ddindx).srt_rate := a8(indx);
          t(ddindx).sts_code := a9(indx);
          t(ddindx).day_convention_code := a10(indx);
          t(ddindx).frq_meaning := a11(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p26;
  procedure rosetta_table_copy_out_p26(t okl_ec_uptake_pvt.okl_std_rate_tmpl_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    , a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_300();
    a4 := JTF_VARCHAR2_TABLE_2000();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_300();
      a4 := JTF_VARCHAR2_TABLE_2000();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_300();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).id;
          a1(indx) := t(ddindx).std_rate_tmpl_ver_id;
          a2(indx) := t(ddindx).version_number;
          a3(indx) := t(ddindx).name;
          a4(indx) := t(ddindx).description;
          a5(indx) := t(ddindx).frq_code;
          a6(indx) := t(ddindx).effective_from;
          a7(indx) := t(ddindx).effective_to;
          a8(indx) := t(ddindx).srt_rate;
          a9(indx) := t(ddindx).sts_code;
          a10(indx) := t(ddindx).day_convention_code;
          a11(indx) := t(ddindx).frq_meaning;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p26;

  procedure rosetta_table_copy_in_p28(t out nocopy okl_ec_uptake_pvt.okl_prod_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_VARCHAR2_TABLE_200
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_2000
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_200
    , a7 JTF_VARCHAR2_TABLE_4000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := a0(indx);
          t(ddindx).name := a1(indx);
          t(ddindx).product_subclass := a2(indx);
          t(ddindx).version := a3(indx);
          t(ddindx).description := a4(indx);
          t(ddindx).product_status_code := a5(indx);
          t(ddindx).deal_type := a6(indx);
          t(ddindx).deal_type_meaning := a7(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p28;
  procedure rosetta_table_copy_out_p28(t okl_ec_uptake_pvt.okl_prod_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_200
    , a7 out nocopy JTF_VARCHAR2_TABLE_4000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_200();
    a2 := JTF_VARCHAR2_TABLE_200();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_2000();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_200();
    a7 := JTF_VARCHAR2_TABLE_4000();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_200();
      a2 := JTF_VARCHAR2_TABLE_200();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_2000();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_200();
      a7 := JTF_VARCHAR2_TABLE_4000();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        a7.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).id;
          a1(indx) := t(ddindx).name;
          a2(indx) := t(ddindx).product_subclass;
          a3(indx) := t(ddindx).version;
          a4(indx) := t(ddindx).description;
          a5(indx) := t(ddindx).product_status_code;
          a6(indx) := t(ddindx).deal_type;
          a7(indx) := t(ddindx).deal_type_meaning;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p28;

  procedure rosetta_table_copy_in_p30(t out nocopy okl_ec_uptake_pvt.okl_vp_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_DATE_TABLE
    , a3 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := a0(indx);
          t(ddindx).contract_number := a1(indx);
          t(ddindx).start_date := a2(indx);
          t(ddindx).end_date := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p30;
  procedure rosetta_table_copy_out_p30(t okl_ec_uptake_pvt.okl_vp_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_200();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_200();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_DATE_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).id;
          a1(indx) := t(ddindx).contract_number;
          a2(indx) := t(ddindx).start_date;
          a3(indx) := t(ddindx).end_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p30;

  procedure populate_lease_rate_set(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_target_id  NUMBER
    , p_target_type  VARCHAR2
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_NUMBER_TABLE
    , p4_a2 out nocopy JTF_NUMBER_TABLE
    , p4_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , p4_a5 out nocopy JTF_DATE_TABLE
    , p4_a6 out nocopy JTF_DATE_TABLE
    , p4_a7 out nocopy JTF_NUMBER_TABLE
    , p4_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a10 out nocopy JTF_VARCHAR2_TABLE_300
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_okl_lrs_table okl_ec_uptake_pvt.okl_lease_rate_set_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    -- here's the delegated call to the old PL/SQL routine
    okl_ec_uptake_pvt.populate_lease_rate_set(p_api_version,
      p_init_msg_list,
      p_target_id,
      p_target_type,
      ddx_okl_lrs_table,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    okl_ec_uptake_pvt_w.rosetta_table_copy_out_p24(ddx_okl_lrs_table, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      , p4_a6
      , p4_a7
      , p4_a8
      , p4_a9
      , p4_a10
      );



  end;

  procedure populate_std_rate_tmpl(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_target_id  NUMBER
    , p_target_type  VARCHAR2
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_NUMBER_TABLE
    , p4_a2 out nocopy JTF_NUMBER_TABLE
    , p4_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , p4_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a6 out nocopy JTF_DATE_TABLE
    , p4_a7 out nocopy JTF_DATE_TABLE
    , p4_a8 out nocopy JTF_NUMBER_TABLE
    , p4_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a11 out nocopy JTF_VARCHAR2_TABLE_300
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_okl_srt_table okl_ec_uptake_pvt.okl_std_rate_tmpl_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    -- here's the delegated call to the old PL/SQL routine
    okl_ec_uptake_pvt.populate_std_rate_tmpl(p_api_version,
      p_init_msg_list,
      p_target_id,
      p_target_type,
      ddx_okl_srt_table,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    okl_ec_uptake_pvt_w.rosetta_table_copy_out_p26(ddx_okl_srt_table, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      , p4_a6
      , p4_a7
      , p4_a8
      , p4_a9
      , p4_a10
      , p4_a11
      );



  end;

  procedure populate_lease_rate_set(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_target_id  NUMBER
    , p_target_type  VARCHAR2
    , p_target_eff_from  DATE
    , p_term  NUMBER
    , p_territory  VARCHAR2
    , p_deal_size  NUMBER
    , p_customer_credit_class  VARCHAR2
    , p_down_payment  NUMBER
    , p_advance_rent  NUMBER
    , p_trade_in_value  NUMBER
    , p_currency_code  VARCHAR2
    , p_item_table JTF_NUMBER_TABLE
    , p_item_categories_table JTF_NUMBER_TABLE
    , p15_a0 out nocopy JTF_NUMBER_TABLE
    , p15_a1 out nocopy JTF_NUMBER_TABLE
    , p15_a2 out nocopy JTF_NUMBER_TABLE
    , p15_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , p15_a5 out nocopy JTF_DATE_TABLE
    , p15_a6 out nocopy JTF_DATE_TABLE
    , p15_a7 out nocopy JTF_NUMBER_TABLE
    , p15_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a10 out nocopy JTF_VARCHAR2_TABLE_300
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_item_table okl_ec_uptake_pvt.okl_number_table_type;
    ddp_item_categories_table okl_ec_uptake_pvt.okl_number_table_type;
    ddx_okl_lrs_table okl_ec_uptake_pvt.okl_lease_rate_set_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any













    okl_ec_uptake_pvt_w.rosetta_table_copy_in_p18(ddp_item_table, p_item_table);

    okl_ec_uptake_pvt_w.rosetta_table_copy_in_p18(ddp_item_categories_table, p_item_categories_table);





    -- here's the delegated call to the old PL/SQL routine
    okl_ec_uptake_pvt.populate_lease_rate_set(p_api_version,
      p_init_msg_list,
      p_target_id,
      p_target_type,
      p_target_eff_from,
      p_term,
      p_territory,
      p_deal_size,
      p_customer_credit_class,
      p_down_payment,
      p_advance_rent,
      p_trade_in_value,
      p_currency_code,
      ddp_item_table,
      ddp_item_categories_table,
      ddx_okl_lrs_table,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any















    okl_ec_uptake_pvt_w.rosetta_table_copy_out_p24(ddx_okl_lrs_table, p15_a0
      , p15_a1
      , p15_a2
      , p15_a3
      , p15_a4
      , p15_a5
      , p15_a6
      , p15_a7
      , p15_a8
      , p15_a9
      , p15_a10
      );



  end;

  procedure populate_std_rate_tmpl(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_target_id  NUMBER
    , p_target_type  VARCHAR2
    , p_target_eff_from  DATE
    , p_term  NUMBER
    , p_territory  VARCHAR2
    , p_deal_size  NUMBER
    , p_customer_credit_class  VARCHAR2
    , p_down_payment  NUMBER
    , p_advance_rent  NUMBER
    , p_trade_in_value  NUMBER
    , p_currency_code  VARCHAR2
    , p_item_table JTF_NUMBER_TABLE
    , p_item_categories_table JTF_NUMBER_TABLE
    , p15_a0 out nocopy JTF_NUMBER_TABLE
    , p15_a1 out nocopy JTF_NUMBER_TABLE
    , p15_a2 out nocopy JTF_NUMBER_TABLE
    , p15_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p15_a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , p15_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a6 out nocopy JTF_DATE_TABLE
    , p15_a7 out nocopy JTF_DATE_TABLE
    , p15_a8 out nocopy JTF_NUMBER_TABLE
    , p15_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a11 out nocopy JTF_VARCHAR2_TABLE_300
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_item_table okl_ec_uptake_pvt.okl_number_table_type;
    ddp_item_categories_table okl_ec_uptake_pvt.okl_number_table_type;
    ddx_okl_srt_table okl_ec_uptake_pvt.okl_std_rate_tmpl_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any













    okl_ec_uptake_pvt_w.rosetta_table_copy_in_p18(ddp_item_table, p_item_table);

    okl_ec_uptake_pvt_w.rosetta_table_copy_in_p18(ddp_item_categories_table, p_item_categories_table);





    -- here's the delegated call to the old PL/SQL routine
    okl_ec_uptake_pvt.populate_std_rate_tmpl(p_api_version,
      p_init_msg_list,
      p_target_id,
      p_target_type,
      p_target_eff_from,
      p_term,
      p_territory,
      p_deal_size,
      p_customer_credit_class,
      p_down_payment,
      p_advance_rent,
      p_trade_in_value,
      p_currency_code,
      ddp_item_table,
      ddp_item_categories_table,
      ddx_okl_srt_table,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any















    okl_ec_uptake_pvt_w.rosetta_table_copy_out_p26(ddx_okl_srt_table, p15_a0
      , p15_a1
      , p15_a2
      , p15_a3
      , p15_a4
      , p15_a5
      , p15_a6
      , p15_a7
      , p15_a8
      , p15_a9
      , p15_a10
      , p15_a11
      );



  end;

  procedure populate_product(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_target_id  NUMBER
    , p_target_type  VARCHAR2
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a3 out nocopy JTF_NUMBER_TABLE
    , p4_a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , p4_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a6 out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a7 out nocopy JTF_VARCHAR2_TABLE_4000
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_okl_prod_table okl_ec_uptake_pvt.okl_prod_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    -- here's the delegated call to the old PL/SQL routine
    okl_ec_uptake_pvt.populate_product(p_api_version,
      p_init_msg_list,
      p_target_id,
      p_target_type,
      ddx_okl_prod_table,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    okl_ec_uptake_pvt_w.rosetta_table_copy_out_p28(ddx_okl_prod_table, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      , p4_a6
      , p4_a7
      );



  end;

  procedure populate_vendor_program(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_target_id  NUMBER
    , p_target_type  VARCHAR2
    , p_target_eff_from  DATE
    , p_term  NUMBER
    , p_territory  VARCHAR2
    , p_deal_size  NUMBER
    , p_customer_credit_class  VARCHAR2
    , p_down_payment  NUMBER
    , p_advance_rent  NUMBER
    , p_trade_in_value  NUMBER
    , p_item_table JTF_NUMBER_TABLE
    , p_item_categories_table JTF_NUMBER_TABLE
    , p14_a0 out nocopy JTF_NUMBER_TABLE
    , p14_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a2 out nocopy JTF_DATE_TABLE
    , p14_a3 out nocopy JTF_DATE_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_item_table okl_ec_uptake_pvt.okl_number_table_type;
    ddp_item_categories_table okl_ec_uptake_pvt.okl_number_table_type;
    ddx_okl_vp_table okl_ec_uptake_pvt.okl_vp_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any












    okl_ec_uptake_pvt_w.rosetta_table_copy_in_p18(ddp_item_table, p_item_table);

    okl_ec_uptake_pvt_w.rosetta_table_copy_in_p18(ddp_item_categories_table, p_item_categories_table);





    -- here's the delegated call to the old PL/SQL routine
    okl_ec_uptake_pvt.populate_vendor_program(p_api_version,
      p_init_msg_list,
      p_target_id,
      p_target_type,
      p_target_eff_from,
      p_term,
      p_territory,
      p_deal_size,
      p_customer_credit_class,
      p_down_payment,
      p_advance_rent,
      p_trade_in_value,
      ddp_item_table,
      ddp_item_categories_table,
      ddx_okl_vp_table,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














    okl_ec_uptake_pvt_w.rosetta_table_copy_out_p30(ddx_okl_vp_table, p14_a0
      , p14_a1
      , p14_a2
      , p14_a3
      );



  end;

end okl_ec_uptake_pvt_w;

/
