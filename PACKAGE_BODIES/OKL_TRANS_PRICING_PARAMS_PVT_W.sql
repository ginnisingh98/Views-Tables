--------------------------------------------------------
--  DDL for Package Body OKL_TRANS_PRICING_PARAMS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TRANS_PRICING_PARAMS_PVT_W" as
  /* $Header: OKLESPMB.pls 120.2 2005/10/30 03:16:47 appldev noship $ */
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

  procedure rosetta_table_copy_in_p36(t out nocopy okl_trans_pricing_params_pvt.tpp_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_500
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).gtp_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).parameter_value := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p36;
  procedure rosetta_table_copy_out_p36(t okl_trans_pricing_params_pvt.tpp_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_500
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_500();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_500();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).gtp_id);
          a1(indx) := t(ddindx).parameter_value;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p36;

  procedure create_trans_pricing_params(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p_gts_id  NUMBER
    , p_sif_id  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_tpp_rec okl_trans_pricing_params_pvt.tpp_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tpp_rec.gtp_id := rosetta_g_miss_num_map(p5_a0);
    ddp_tpp_rec.parameter_value := p5_a1;




    -- here's the delegated call to the old PL/SQL routine
    okl_trans_pricing_params_pvt.create_trans_pricing_params(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tpp_rec,
      p_chr_id,
      p_gts_id,
      p_sif_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure create_trans_pricing_params(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_500
    , p_chr_id  NUMBER
    , p_gts_id  NUMBER
    , p_sif_id  NUMBER
  )

  as
    ddp_tpp_tbl okl_trans_pricing_params_pvt.tpp_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_trans_pricing_params_pvt_w.rosetta_table_copy_in_p36(ddp_tpp_tbl, p5_a0
      , p5_a1
      );




    -- here's the delegated call to the old PL/SQL routine
    okl_trans_pricing_params_pvt.create_trans_pricing_params(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tpp_tbl,
      p_chr_id,
      p_gts_id,
      p_sif_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

end okl_trans_pricing_params_pvt_w;

/
