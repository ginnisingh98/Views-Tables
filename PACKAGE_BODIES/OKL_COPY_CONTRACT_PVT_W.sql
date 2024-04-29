--------------------------------------------------------
--  DDL for Package Body OKL_COPY_CONTRACT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_COPY_CONTRACT_PVT_W" as
  /* $Header: OKLECOPB.pls 120.1 2005/07/08 12:20:48 dkagrawa noship $ */
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

  procedure rosetta_table_copy_in_p29(t out nocopy okl_copy_contract_pvt.api_components_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).to_k := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).component_type := a2(indx);
          t(ddindx).attribute1 := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p29;
  procedure rosetta_table_copy_out_p29(t okl_copy_contract_pvt.api_components_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).to_k);
          a2(indx) := t(ddindx).component_type;
          a3(indx) := t(ddindx).attribute1;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p29;

  procedure rosetta_table_copy_in_p31(t out nocopy okl_copy_contract_pvt.api_lines_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).to_k := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).to_line := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).lse_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).line_exists_yn := a4(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p31;
  procedure rosetta_table_copy_out_p31(t okl_copy_contract_pvt.api_lines_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).to_k);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).to_line);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).lse_id);
          a4(indx) := t(ddindx).line_exists_yn;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p31;

  procedure is_copy_allowed(p_chr_id  NUMBER
    , p_sts_code  VARCHAR2
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  )

  as
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval boolean;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := okl_copy_contract_pvt.is_copy_allowed(p_chr_id,
      p_sts_code);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    if ddrosetta_retval is null
      then ddrosetta_retval_bool := null;
    elsif ddrosetta_retval
      then ddrosetta_retval_bool := 1;
    else ddrosetta_retval_bool := 0;
    end if;

  end;

  procedure is_subcontract_allowed(p_chr_id  NUMBER
    , p_sts_code  VARCHAR2
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  )

  as
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval boolean;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := okl_copy_contract_pvt.is_subcontract_allowed(p_chr_id,
      p_sts_code);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    if ddrosetta_retval is null
      then ddrosetta_retval_bool := null;
    elsif ddrosetta_retval
      then ddrosetta_retval_bool := 1;
    else ddrosetta_retval_bool := 0;
    end if;

  end;

  procedure update_target_contract(p_chr_id  NUMBER
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  )

  as
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval boolean;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := okl_copy_contract_pvt.update_target_contract(p_chr_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    if ddrosetta_retval is null
      then ddrosetta_retval_bool := null;
    elsif ddrosetta_retval
      then ddrosetta_retval_bool := 1;
    else ddrosetta_retval_bool := 0;
    end if;
  end;

  procedure copy_components(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_from_chr_id  NUMBER
    , p_to_chr_id  NUMBER
    , p_contract_number  VARCHAR2
    , p_contract_number_modifier  VARCHAR2
    , p_to_template_yn  VARCHAR2
    , p_copy_reference  VARCHAR2
    , p_copy_line_party_yn  VARCHAR2
    , p_scs_code  VARCHAR2
    , p_intent  VARCHAR2
    , p_prospect  VARCHAR2
    , p15_a0 JTF_NUMBER_TABLE
    , p15_a1 JTF_NUMBER_TABLE
    , p15_a2 JTF_VARCHAR2_TABLE_100
    , p15_a3 JTF_VARCHAR2_TABLE_100
    , p16_a0 JTF_NUMBER_TABLE
    , p16_a1 JTF_NUMBER_TABLE
    , p16_a2 JTF_NUMBER_TABLE
    , p16_a3 JTF_NUMBER_TABLE
    , p16_a4 JTF_VARCHAR2_TABLE_100
    , x_chr_id out nocopy  NUMBER
  )

  as
    ddp_components_tbl okl_copy_contract_pvt.api_components_tbl;
    ddp_lines_tbl okl_copy_contract_pvt.api_lines_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any















    okl_copy_contract_pvt_w.rosetta_table_copy_in_p29(ddp_components_tbl, p15_a0
      , p15_a1
      , p15_a2
      , p15_a3
      );

    okl_copy_contract_pvt_w.rosetta_table_copy_in_p31(ddp_lines_tbl, p16_a0
      , p16_a1
      , p16_a2
      , p16_a3
      , p16_a4
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_copy_contract_pvt.copy_components(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_from_chr_id,
      p_to_chr_id,
      p_contract_number,
      p_contract_number_modifier,
      p_to_template_yn,
      p_copy_reference,
      p_copy_line_party_yn,
      p_scs_code,
      p_intent,
      p_prospect,
      ddp_components_tbl,
      ddp_lines_tbl,
      x_chr_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

















  end;

end okl_copy_contract_pvt_w;

/
