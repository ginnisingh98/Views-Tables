--------------------------------------------------------
--  DDL for Package Body OKL_CONTRACT_LINE_ITEM_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CONTRACT_LINE_ITEM_PVT_W" as
  /* $Header: OKLECLIB.pls 115.2 2003/10/16 01:14:18 smereddy noship $ */
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

  procedure rosetta_table_copy_in_p7(t out nocopy okl_contract_line_item_pvt.link_ast_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id1 := a0(indx);
          t(ddindx).id2 := a1(indx);
          t(ddindx).name := a2(indx);
          t(ddindx).object_code := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t okl_contract_line_item_pvt.link_ast_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_200();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_200();
      a2 := JTF_VARCHAR2_TABLE_300();
      a3 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).id1;
          a1(indx) := t(ddindx).id2;
          a2(indx) := t(ddindx).name;
          a3(indx) := t(ddindx).object_code;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure rosetta_table_copy_in_p11(t out nocopy okl_contract_line_item_pvt.line_item_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_200
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_2000
    , a8 JTF_VARCHAR2_TABLE_200
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).chr_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).parent_cle_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).cle_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).item_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).item_id1 := a4(indx);
          t(ddindx).item_id2 := a5(indx);
          t(ddindx).item_object1_code := a6(indx);
          t(ddindx).item_description := a7(indx);
          t(ddindx).name := a8(indx);
          t(ddindx).capital_amount := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).serv_cov_prd_id := rosetta_g_miss_num_map(a10(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p11;
  procedure rosetta_table_copy_out_p11(t okl_contract_line_item_pvt.line_item_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_200
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , a8 out nocopy JTF_VARCHAR2_TABLE_200
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_200();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_2000();
    a8 := JTF_VARCHAR2_TABLE_200();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_200();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_2000();
      a8 := JTF_VARCHAR2_TABLE_200();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).chr_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).parent_cle_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).cle_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).item_id);
          a4(indx) := t(ddindx).item_id1;
          a5(indx) := t(ddindx).item_id2;
          a6(indx) := t(ddindx).item_object1_code;
          a7(indx) := t(ddindx).item_description;
          a8(indx) := t(ddindx).name;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).capital_amount);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).serv_cov_prd_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p11;

  procedure create_contract_line_item(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_200
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_2000
    , p5_a8 JTF_VARCHAR2_TABLE_200
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_line_item_tbl okl_contract_line_item_pvt.line_item_tbl_type;
    ddx_line_item_tbl okl_contract_line_item_pvt.line_item_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_contract_line_item_pvt_w.rosetta_table_copy_in_p11(ddp_line_item_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_contract_line_item_pvt.create_contract_line_item(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_line_item_tbl,
      ddx_line_item_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_contract_line_item_pvt_w.rosetta_table_copy_out_p11(ddx_line_item_tbl, p6_a0
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
      );
  end;

  procedure update_contract_line_item(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_200
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_2000
    , p5_a8 JTF_VARCHAR2_TABLE_200
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_line_item_tbl okl_contract_line_item_pvt.line_item_tbl_type;
    ddx_line_item_tbl okl_contract_line_item_pvt.line_item_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_contract_line_item_pvt_w.rosetta_table_copy_in_p11(ddp_line_item_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_contract_line_item_pvt.update_contract_line_item(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_line_item_tbl,
      ddx_line_item_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_contract_line_item_pvt_w.rosetta_table_copy_out_p11(ddx_line_item_tbl, p6_a0
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
      );
  end;

  procedure delete_contract_line_item(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_200
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_2000
    , p5_a8 JTF_VARCHAR2_TABLE_200
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
  )

  as
    ddp_line_item_tbl okl_contract_line_item_pvt.line_item_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_contract_line_item_pvt_w.rosetta_table_copy_in_p11(ddp_line_item_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_contract_line_item_pvt.delete_contract_line_item(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_line_item_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_contract_line_item(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  NUMBER
    , p8_a4 out nocopy  NUMBER
    , p8_a5 out nocopy  NUMBER
    , p8_a6 out nocopy  NUMBER
    , p8_a7 out nocopy  NUMBER
    , p8_a8 out nocopy  VARCHAR2
    , p8_a9 out nocopy  VARCHAR2
    , p8_a10 out nocopy  NUMBER
    , p8_a11 out nocopy  VARCHAR2
    , p8_a12 out nocopy  NUMBER
    , p8_a13 out nocopy  VARCHAR2
    , p8_a14 out nocopy  VARCHAR2
    , p8_a15 out nocopy  VARCHAR2
    , p8_a16 out nocopy  VARCHAR2
    , p8_a17 out nocopy  VARCHAR2
    , p8_a18 out nocopy  NUMBER
    , p8_a19 out nocopy  NUMBER
    , p8_a20 out nocopy  NUMBER
    , p8_a21 out nocopy  NUMBER
    , p8_a22 out nocopy  VARCHAR2
    , p8_a23 out nocopy  VARCHAR2
    , p8_a24 out nocopy  VARCHAR2
    , p8_a25 out nocopy  VARCHAR2
    , p8_a26 out nocopy  VARCHAR2
    , p8_a27 out nocopy  VARCHAR2
    , p8_a28 out nocopy  DATE
    , p8_a29 out nocopy  VARCHAR2
    , p8_a30 out nocopy  DATE
    , p8_a31 out nocopy  DATE
    , p8_a32 out nocopy  DATE
    , p8_a33 out nocopy  VARCHAR2
    , p8_a34 out nocopy  NUMBER
    , p8_a35 out nocopy  VARCHAR2
    , p8_a36 out nocopy  NUMBER
    , p8_a37 out nocopy  VARCHAR2
    , p8_a38 out nocopy  VARCHAR2
    , p8_a39 out nocopy  VARCHAR2
    , p8_a40 out nocopy  VARCHAR2
    , p8_a41 out nocopy  VARCHAR2
    , p8_a42 out nocopy  VARCHAR2
    , p8_a43 out nocopy  VARCHAR2
    , p8_a44 out nocopy  VARCHAR2
    , p8_a45 out nocopy  VARCHAR2
    , p8_a46 out nocopy  VARCHAR2
    , p8_a47 out nocopy  VARCHAR2
    , p8_a48 out nocopy  VARCHAR2
    , p8_a49 out nocopy  VARCHAR2
    , p8_a50 out nocopy  VARCHAR2
    , p8_a51 out nocopy  VARCHAR2
    , p8_a52 out nocopy  VARCHAR2
    , p8_a53 out nocopy  VARCHAR2
    , p8_a54 out nocopy  NUMBER
    , p8_a55 out nocopy  DATE
    , p8_a56 out nocopy  NUMBER
    , p8_a57 out nocopy  DATE
    , p8_a58 out nocopy  VARCHAR2
    , p8_a59 out nocopy  VARCHAR2
    , p8_a60 out nocopy  VARCHAR2
    , p8_a61 out nocopy  NUMBER
    , p8_a62 out nocopy  VARCHAR2
    , p8_a63 out nocopy  VARCHAR2
    , p8_a64 out nocopy  VARCHAR2
    , p8_a65 out nocopy  VARCHAR2
    , p8_a66 out nocopy  VARCHAR2
    , p8_a67 out nocopy  NUMBER
    , p8_a68 out nocopy  NUMBER
    , p8_a69 out nocopy  NUMBER
    , p8_a70 out nocopy  DATE
    , p8_a71 out nocopy  NUMBER
    , p8_a72 out nocopy  DATE
    , p8_a73 out nocopy  NUMBER
    , p8_a74 out nocopy  NUMBER
    , p8_a75 out nocopy  VARCHAR2
    , p8_a76 out nocopy  VARCHAR2
    , p8_a77 out nocopy  NUMBER
    , p8_a78 out nocopy  NUMBER
    , p8_a79 out nocopy  VARCHAR2
    , p8_a80 out nocopy  VARCHAR2
    , p8_a81 out nocopy  NUMBER
    , p8_a82 out nocopy  VARCHAR2
    , p8_a83 out nocopy  NUMBER
    , p8_a84 out nocopy  NUMBER
    , p8_a85 out nocopy  NUMBER
    , p8_a86 out nocopy  NUMBER
    , p8_a87 out nocopy  VARCHAR2
    , p8_a88 out nocopy  NUMBER
    , p8_a89 out nocopy  NUMBER
    , p9_a0 out nocopy  NUMBER
    , p9_a1 out nocopy  NUMBER
    , p9_a2 out nocopy  NUMBER
    , p9_a3 out nocopy  NUMBER
    , p9_a4 out nocopy  VARCHAR2
    , p9_a5 out nocopy  VARCHAR2
    , p9_a6 out nocopy  VARCHAR2
    , p9_a7 out nocopy  NUMBER
    , p9_a8 out nocopy  NUMBER
    , p9_a9 out nocopy  DATE
    , p9_a10 out nocopy  NUMBER
    , p9_a11 out nocopy  NUMBER
    , p9_a12 out nocopy  NUMBER
    , p9_a13 out nocopy  NUMBER
    , p9_a14 out nocopy  NUMBER
    , p9_a15 out nocopy  NUMBER
    , p9_a16 out nocopy  NUMBER
    , p9_a17 out nocopy  NUMBER
    , p9_a18 out nocopy  NUMBER
    , p9_a19 out nocopy  NUMBER
    , p9_a20 out nocopy  DATE
    , p9_a21 out nocopy  DATE
    , p9_a22 out nocopy  NUMBER
    , p9_a23 out nocopy  NUMBER
    , p9_a24 out nocopy  DATE
    , p9_a25 out nocopy  DATE
    , p9_a26 out nocopy  DATE
    , p9_a27 out nocopy  NUMBER
    , p9_a28 out nocopy  NUMBER
    , p9_a29 out nocopy  NUMBER
    , p9_a30 out nocopy  NUMBER
    , p9_a31 out nocopy  NUMBER
    , p9_a32 out nocopy  NUMBER
    , p9_a33 out nocopy  NUMBER
    , p9_a34 out nocopy  DATE
    , p9_a35 out nocopy  VARCHAR2
    , p9_a36 out nocopy  DATE
    , p9_a37 out nocopy  VARCHAR2
    , p9_a38 out nocopy  NUMBER
    , p9_a39 out nocopy  NUMBER
    , p9_a40 out nocopy  NUMBER
    , p9_a41 out nocopy  VARCHAR2
    , p9_a42 out nocopy  DATE
    , p9_a43 out nocopy  NUMBER
    , p9_a44 out nocopy  NUMBER
    , p9_a45 out nocopy  DATE
    , p9_a46 out nocopy  NUMBER
    , p9_a47 out nocopy  DATE
    , p9_a48 out nocopy  DATE
    , p9_a49 out nocopy  DATE
    , p9_a50 out nocopy  NUMBER
    , p9_a51 out nocopy  NUMBER
    , p9_a52 out nocopy  VARCHAR2
    , p9_a53 out nocopy  NUMBER
    , p9_a54 out nocopy  NUMBER
    , p9_a55 out nocopy  VARCHAR2
    , p9_a56 out nocopy  VARCHAR2
    , p9_a57 out nocopy  NUMBER
    , p9_a58 out nocopy  DATE
    , p9_a59 out nocopy  NUMBER
    , p9_a60 out nocopy  VARCHAR2
    , p9_a61 out nocopy  VARCHAR2
    , p9_a62 out nocopy  VARCHAR2
    , p9_a63 out nocopy  VARCHAR2
    , p9_a64 out nocopy  VARCHAR2
    , p9_a65 out nocopy  VARCHAR2
    , p9_a66 out nocopy  VARCHAR2
    , p9_a67 out nocopy  VARCHAR2
    , p9_a68 out nocopy  VARCHAR2
    , p9_a69 out nocopy  VARCHAR2
    , p9_a70 out nocopy  VARCHAR2
    , p9_a71 out nocopy  VARCHAR2
    , p9_a72 out nocopy  VARCHAR2
    , p9_a73 out nocopy  VARCHAR2
    , p9_a74 out nocopy  VARCHAR2
    , p9_a75 out nocopy  VARCHAR2
    , p9_a76 out nocopy  NUMBER
    , p9_a77 out nocopy  NUMBER
    , p9_a78 out nocopy  NUMBER
    , p9_a79 out nocopy  DATE
    , p9_a80 out nocopy  NUMBER
    , p9_a81 out nocopy  DATE
    , p9_a82 out nocopy  NUMBER
    , p9_a83 out nocopy  DATE
    , p9_a84 out nocopy  DATE
    , p9_a85 out nocopy  DATE
    , p9_a86 out nocopy  DATE
    , p9_a87 out nocopy  NUMBER
    , p9_a88 out nocopy  NUMBER
    , p9_a89 out nocopy  NUMBER
    , p9_a90 out nocopy  VARCHAR2
    , p9_a91 out nocopy  NUMBER
    , p9_a92 out nocopy  VARCHAR2
    , p9_a93 out nocopy  NUMBER
    , p9_a94 out nocopy  NUMBER
    , p9_a95 out nocopy  DATE
    , p9_a96 out nocopy  VARCHAR2
    , p9_a97 out nocopy  VARCHAR2
    , p9_a98 out nocopy  NUMBER
    , p10_a0 out nocopy  NUMBER
    , p10_a1 out nocopy  NUMBER
    , p10_a2 out nocopy  NUMBER
    , p10_a3 out nocopy  NUMBER
    , p10_a4 out nocopy  NUMBER
    , p10_a5 out nocopy  NUMBER
    , p10_a6 out nocopy  VARCHAR2
    , p10_a7 out nocopy  VARCHAR2
    , p10_a8 out nocopy  VARCHAR2
    , p10_a9 out nocopy  VARCHAR2
    , p10_a10 out nocopy  VARCHAR2
    , p10_a11 out nocopy  NUMBER
    , p10_a12 out nocopy  VARCHAR2
    , p10_a13 out nocopy  NUMBER
    , p10_a14 out nocopy  VARCHAR2
    , p10_a15 out nocopy  NUMBER
    , p10_a16 out nocopy  DATE
    , p10_a17 out nocopy  NUMBER
    , p10_a18 out nocopy  DATE
    , p10_a19 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  DATE := fnd_api.g_miss_date
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  DATE := fnd_api.g_miss_date
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  DATE := fnd_api.g_miss_date
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  DATE := fnd_api.g_miss_date
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  NUMBER := 0-1962.0724
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  VARCHAR2 := fnd_api.g_miss_char
    , p5_a65  VARCHAR2 := fnd_api.g_miss_char
    , p5_a66  VARCHAR2 := fnd_api.g_miss_char
    , p5_a67  NUMBER := 0-1962.0724
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  NUMBER := 0-1962.0724
    , p5_a70  DATE := fnd_api.g_miss_date
    , p5_a71  NUMBER := 0-1962.0724
    , p5_a72  DATE := fnd_api.g_miss_date
    , p5_a73  NUMBER := 0-1962.0724
    , p5_a74  NUMBER := 0-1962.0724
    , p5_a75  VARCHAR2 := fnd_api.g_miss_char
    , p5_a76  VARCHAR2 := fnd_api.g_miss_char
    , p5_a77  NUMBER := 0-1962.0724
    , p5_a78  NUMBER := 0-1962.0724
    , p5_a79  VARCHAR2 := fnd_api.g_miss_char
    , p5_a80  VARCHAR2 := fnd_api.g_miss_char
    , p5_a81  NUMBER := 0-1962.0724
    , p5_a82  VARCHAR2 := fnd_api.g_miss_char
    , p5_a83  NUMBER := 0-1962.0724
    , p5_a84  NUMBER := 0-1962.0724
    , p5_a85  NUMBER := 0-1962.0724
    , p5_a86  NUMBER := 0-1962.0724
    , p5_a87  VARCHAR2 := fnd_api.g_miss_char
    , p5_a88  NUMBER := 0-1962.0724
    , p5_a89  NUMBER := 0-1962.0724
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  NUMBER := 0-1962.0724
    , p6_a3  NUMBER := 0-1962.0724
    , p6_a4  VARCHAR2 := fnd_api.g_miss_char
    , p6_a5  VARCHAR2 := fnd_api.g_miss_char
    , p6_a6  VARCHAR2 := fnd_api.g_miss_char
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  NUMBER := 0-1962.0724
    , p6_a9  DATE := fnd_api.g_miss_date
    , p6_a10  NUMBER := 0-1962.0724
    , p6_a11  NUMBER := 0-1962.0724
    , p6_a12  NUMBER := 0-1962.0724
    , p6_a13  NUMBER := 0-1962.0724
    , p6_a14  NUMBER := 0-1962.0724
    , p6_a15  NUMBER := 0-1962.0724
    , p6_a16  NUMBER := 0-1962.0724
    , p6_a17  NUMBER := 0-1962.0724
    , p6_a18  NUMBER := 0-1962.0724
    , p6_a19  NUMBER := 0-1962.0724
    , p6_a20  DATE := fnd_api.g_miss_date
    , p6_a21  DATE := fnd_api.g_miss_date
    , p6_a22  NUMBER := 0-1962.0724
    , p6_a23  NUMBER := 0-1962.0724
    , p6_a24  DATE := fnd_api.g_miss_date
    , p6_a25  DATE := fnd_api.g_miss_date
    , p6_a26  DATE := fnd_api.g_miss_date
    , p6_a27  NUMBER := 0-1962.0724
    , p6_a28  NUMBER := 0-1962.0724
    , p6_a29  NUMBER := 0-1962.0724
    , p6_a30  NUMBER := 0-1962.0724
    , p6_a31  NUMBER := 0-1962.0724
    , p6_a32  NUMBER := 0-1962.0724
    , p6_a33  NUMBER := 0-1962.0724
    , p6_a34  DATE := fnd_api.g_miss_date
    , p6_a35  VARCHAR2 := fnd_api.g_miss_char
    , p6_a36  DATE := fnd_api.g_miss_date
    , p6_a37  VARCHAR2 := fnd_api.g_miss_char
    , p6_a38  NUMBER := 0-1962.0724
    , p6_a39  NUMBER := 0-1962.0724
    , p6_a40  NUMBER := 0-1962.0724
    , p6_a41  VARCHAR2 := fnd_api.g_miss_char
    , p6_a42  DATE := fnd_api.g_miss_date
    , p6_a43  NUMBER := 0-1962.0724
    , p6_a44  NUMBER := 0-1962.0724
    , p6_a45  DATE := fnd_api.g_miss_date
    , p6_a46  NUMBER := 0-1962.0724
    , p6_a47  DATE := fnd_api.g_miss_date
    , p6_a48  DATE := fnd_api.g_miss_date
    , p6_a49  DATE := fnd_api.g_miss_date
    , p6_a50  NUMBER := 0-1962.0724
    , p6_a51  NUMBER := 0-1962.0724
    , p6_a52  VARCHAR2 := fnd_api.g_miss_char
    , p6_a53  NUMBER := 0-1962.0724
    , p6_a54  NUMBER := 0-1962.0724
    , p6_a55  VARCHAR2 := fnd_api.g_miss_char
    , p6_a56  VARCHAR2 := fnd_api.g_miss_char
    , p6_a57  NUMBER := 0-1962.0724
    , p6_a58  DATE := fnd_api.g_miss_date
    , p6_a59  NUMBER := 0-1962.0724
    , p6_a60  VARCHAR2 := fnd_api.g_miss_char
    , p6_a61  VARCHAR2 := fnd_api.g_miss_char
    , p6_a62  VARCHAR2 := fnd_api.g_miss_char
    , p6_a63  VARCHAR2 := fnd_api.g_miss_char
    , p6_a64  VARCHAR2 := fnd_api.g_miss_char
    , p6_a65  VARCHAR2 := fnd_api.g_miss_char
    , p6_a66  VARCHAR2 := fnd_api.g_miss_char
    , p6_a67  VARCHAR2 := fnd_api.g_miss_char
    , p6_a68  VARCHAR2 := fnd_api.g_miss_char
    , p6_a69  VARCHAR2 := fnd_api.g_miss_char
    , p6_a70  VARCHAR2 := fnd_api.g_miss_char
    , p6_a71  VARCHAR2 := fnd_api.g_miss_char
    , p6_a72  VARCHAR2 := fnd_api.g_miss_char
    , p6_a73  VARCHAR2 := fnd_api.g_miss_char
    , p6_a74  VARCHAR2 := fnd_api.g_miss_char
    , p6_a75  VARCHAR2 := fnd_api.g_miss_char
    , p6_a76  NUMBER := 0-1962.0724
    , p6_a77  NUMBER := 0-1962.0724
    , p6_a78  NUMBER := 0-1962.0724
    , p6_a79  DATE := fnd_api.g_miss_date
    , p6_a80  NUMBER := 0-1962.0724
    , p6_a81  DATE := fnd_api.g_miss_date
    , p6_a82  NUMBER := 0-1962.0724
    , p6_a83  DATE := fnd_api.g_miss_date
    , p6_a84  DATE := fnd_api.g_miss_date
    , p6_a85  DATE := fnd_api.g_miss_date
    , p6_a86  DATE := fnd_api.g_miss_date
    , p6_a87  NUMBER := 0-1962.0724
    , p6_a88  NUMBER := 0-1962.0724
    , p6_a89  NUMBER := 0-1962.0724
    , p6_a90  VARCHAR2 := fnd_api.g_miss_char
    , p6_a91  NUMBER := 0-1962.0724
    , p6_a92  VARCHAR2 := fnd_api.g_miss_char
    , p6_a93  NUMBER := 0-1962.0724
    , p6_a94  NUMBER := 0-1962.0724
    , p6_a95  DATE := fnd_api.g_miss_date
    , p6_a96  VARCHAR2 := fnd_api.g_miss_char
    , p6_a97  VARCHAR2 := fnd_api.g_miss_char
    , p6_a98  NUMBER := 0-1962.0724
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  DATE := fnd_api.g_miss_date
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  DATE := fnd_api.g_miss_date
    , p7_a19  NUMBER := 0-1962.0724
  )

  as
    ddp_clev_rec okl_contract_line_item_pvt.clev_rec_type;
    ddp_klev_rec okl_contract_line_item_pvt.klev_rec_type;
    ddp_cimv_rec okl_contract_line_item_pvt.cimv_rec_type;
    ddx_clev_rec okl_contract_line_item_pvt.clev_rec_type;
    ddx_klev_rec okl_contract_line_item_pvt.klev_rec_type;
    ddx_cimv_rec okl_contract_line_item_pvt.cimv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_clev_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_clev_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_clev_rec.sfwt_flag := p5_a2;
    ddp_clev_rec.chr_id := rosetta_g_miss_num_map(p5_a3);
    ddp_clev_rec.cle_id := rosetta_g_miss_num_map(p5_a4);
    ddp_clev_rec.cle_id_renewed := rosetta_g_miss_num_map(p5_a5);
    ddp_clev_rec.cle_id_renewed_to := rosetta_g_miss_num_map(p5_a6);
    ddp_clev_rec.lse_id := rosetta_g_miss_num_map(p5_a7);
    ddp_clev_rec.line_number := p5_a8;
    ddp_clev_rec.sts_code := p5_a9;
    ddp_clev_rec.display_sequence := rosetta_g_miss_num_map(p5_a10);
    ddp_clev_rec.trn_code := p5_a11;
    ddp_clev_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a12);
    ddp_clev_rec.comments := p5_a13;
    ddp_clev_rec.item_description := p5_a14;
    ddp_clev_rec.oke_boe_description := p5_a15;
    ddp_clev_rec.cognomen := p5_a16;
    ddp_clev_rec.hidden_ind := p5_a17;
    ddp_clev_rec.price_unit := rosetta_g_miss_num_map(p5_a18);
    ddp_clev_rec.price_unit_percent := rosetta_g_miss_num_map(p5_a19);
    ddp_clev_rec.price_negotiated := rosetta_g_miss_num_map(p5_a20);
    ddp_clev_rec.price_negotiated_renewed := rosetta_g_miss_num_map(p5_a21);
    ddp_clev_rec.price_level_ind := p5_a22;
    ddp_clev_rec.invoice_line_level_ind := p5_a23;
    ddp_clev_rec.dpas_rating := p5_a24;
    ddp_clev_rec.block23text := p5_a25;
    ddp_clev_rec.exception_yn := p5_a26;
    ddp_clev_rec.template_used := p5_a27;
    ddp_clev_rec.date_terminated := rosetta_g_miss_date_in_map(p5_a28);
    ddp_clev_rec.name := p5_a29;
    ddp_clev_rec.start_date := rosetta_g_miss_date_in_map(p5_a30);
    ddp_clev_rec.end_date := rosetta_g_miss_date_in_map(p5_a31);
    ddp_clev_rec.date_renewed := rosetta_g_miss_date_in_map(p5_a32);
    ddp_clev_rec.upg_orig_system_ref := p5_a33;
    ddp_clev_rec.upg_orig_system_ref_id := rosetta_g_miss_num_map(p5_a34);
    ddp_clev_rec.orig_system_source_code := p5_a35;
    ddp_clev_rec.orig_system_id1 := rosetta_g_miss_num_map(p5_a36);
    ddp_clev_rec.orig_system_reference1 := p5_a37;
    ddp_clev_rec.attribute_category := p5_a38;
    ddp_clev_rec.attribute1 := p5_a39;
    ddp_clev_rec.attribute2 := p5_a40;
    ddp_clev_rec.attribute3 := p5_a41;
    ddp_clev_rec.attribute4 := p5_a42;
    ddp_clev_rec.attribute5 := p5_a43;
    ddp_clev_rec.attribute6 := p5_a44;
    ddp_clev_rec.attribute7 := p5_a45;
    ddp_clev_rec.attribute8 := p5_a46;
    ddp_clev_rec.attribute9 := p5_a47;
    ddp_clev_rec.attribute10 := p5_a48;
    ddp_clev_rec.attribute11 := p5_a49;
    ddp_clev_rec.attribute12 := p5_a50;
    ddp_clev_rec.attribute13 := p5_a51;
    ddp_clev_rec.attribute14 := p5_a52;
    ddp_clev_rec.attribute15 := p5_a53;
    ddp_clev_rec.created_by := rosetta_g_miss_num_map(p5_a54);
    ddp_clev_rec.creation_date := rosetta_g_miss_date_in_map(p5_a55);
    ddp_clev_rec.last_updated_by := rosetta_g_miss_num_map(p5_a56);
    ddp_clev_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a57);
    ddp_clev_rec.price_type := p5_a58;
    ddp_clev_rec.currency_code := p5_a59;
    ddp_clev_rec.currency_code_renewed := p5_a60;
    ddp_clev_rec.last_update_login := rosetta_g_miss_num_map(p5_a61);
    ddp_clev_rec.old_sts_code := p5_a62;
    ddp_clev_rec.new_sts_code := p5_a63;
    ddp_clev_rec.old_ste_code := p5_a64;
    ddp_clev_rec.new_ste_code := p5_a65;
    ddp_clev_rec.call_action_asmblr := p5_a66;
    ddp_clev_rec.request_id := rosetta_g_miss_num_map(p5_a67);
    ddp_clev_rec.program_application_id := rosetta_g_miss_num_map(p5_a68);
    ddp_clev_rec.program_id := rosetta_g_miss_num_map(p5_a69);
    ddp_clev_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a70);
    ddp_clev_rec.price_list_id := rosetta_g_miss_num_map(p5_a71);
    ddp_clev_rec.pricing_date := rosetta_g_miss_date_in_map(p5_a72);
    ddp_clev_rec.price_list_line_id := rosetta_g_miss_num_map(p5_a73);
    ddp_clev_rec.line_list_price := rosetta_g_miss_num_map(p5_a74);
    ddp_clev_rec.item_to_price_yn := p5_a75;
    ddp_clev_rec.price_basis_yn := p5_a76;
    ddp_clev_rec.config_header_id := rosetta_g_miss_num_map(p5_a77);
    ddp_clev_rec.config_revision_number := rosetta_g_miss_num_map(p5_a78);
    ddp_clev_rec.config_complete_yn := p5_a79;
    ddp_clev_rec.config_valid_yn := p5_a80;
    ddp_clev_rec.config_top_model_line_id := rosetta_g_miss_num_map(p5_a81);
    ddp_clev_rec.config_item_type := p5_a82;
    ddp_clev_rec.config_item_id := rosetta_g_miss_num_map(p5_a83);
    ddp_clev_rec.cust_acct_id := rosetta_g_miss_num_map(p5_a84);
    ddp_clev_rec.bill_to_site_use_id := rosetta_g_miss_num_map(p5_a85);
    ddp_clev_rec.inv_rule_id := rosetta_g_miss_num_map(p5_a86);
    ddp_clev_rec.line_renewal_type_code := p5_a87;
    ddp_clev_rec.ship_to_site_use_id := rosetta_g_miss_num_map(p5_a88);
    ddp_clev_rec.payment_term_id := rosetta_g_miss_num_map(p5_a89);

    ddp_klev_rec.id := rosetta_g_miss_num_map(p6_a0);
    ddp_klev_rec.object_version_number := rosetta_g_miss_num_map(p6_a1);
    ddp_klev_rec.kle_id := rosetta_g_miss_num_map(p6_a2);
    ddp_klev_rec.sty_id := rosetta_g_miss_num_map(p6_a3);
    ddp_klev_rec.prc_code := p6_a4;
    ddp_klev_rec.fcg_code := p6_a5;
    ddp_klev_rec.nty_code := p6_a6;
    ddp_klev_rec.estimated_oec := rosetta_g_miss_num_map(p6_a7);
    ddp_klev_rec.lao_amount := rosetta_g_miss_num_map(p6_a8);
    ddp_klev_rec.title_date := rosetta_g_miss_date_in_map(p6_a9);
    ddp_klev_rec.fee_charge := rosetta_g_miss_num_map(p6_a10);
    ddp_klev_rec.lrs_percent := rosetta_g_miss_num_map(p6_a11);
    ddp_klev_rec.initial_direct_cost := rosetta_g_miss_num_map(p6_a12);
    ddp_klev_rec.percent_stake := rosetta_g_miss_num_map(p6_a13);
    ddp_klev_rec.percent := rosetta_g_miss_num_map(p6_a14);
    ddp_klev_rec.evergreen_percent := rosetta_g_miss_num_map(p6_a15);
    ddp_klev_rec.amount_stake := rosetta_g_miss_num_map(p6_a16);
    ddp_klev_rec.occupancy := rosetta_g_miss_num_map(p6_a17);
    ddp_klev_rec.coverage := rosetta_g_miss_num_map(p6_a18);
    ddp_klev_rec.residual_percentage := rosetta_g_miss_num_map(p6_a19);
    ddp_klev_rec.date_last_inspection := rosetta_g_miss_date_in_map(p6_a20);
    ddp_klev_rec.date_sold := rosetta_g_miss_date_in_map(p6_a21);
    ddp_klev_rec.lrv_amount := rosetta_g_miss_num_map(p6_a22);
    ddp_klev_rec.capital_reduction := rosetta_g_miss_num_map(p6_a23);
    ddp_klev_rec.date_next_inspection_due := rosetta_g_miss_date_in_map(p6_a24);
    ddp_klev_rec.date_residual_last_review := rosetta_g_miss_date_in_map(p6_a25);
    ddp_klev_rec.date_last_reamortisation := rosetta_g_miss_date_in_map(p6_a26);
    ddp_klev_rec.vendor_advance_paid := rosetta_g_miss_num_map(p6_a27);
    ddp_klev_rec.weighted_average_life := rosetta_g_miss_num_map(p6_a28);
    ddp_klev_rec.tradein_amount := rosetta_g_miss_num_map(p6_a29);
    ddp_klev_rec.bond_equivalent_yield := rosetta_g_miss_num_map(p6_a30);
    ddp_klev_rec.termination_purchase_amount := rosetta_g_miss_num_map(p6_a31);
    ddp_klev_rec.refinance_amount := rosetta_g_miss_num_map(p6_a32);
    ddp_klev_rec.year_built := rosetta_g_miss_num_map(p6_a33);
    ddp_klev_rec.delivered_date := rosetta_g_miss_date_in_map(p6_a34);
    ddp_klev_rec.credit_tenant_yn := p6_a35;
    ddp_klev_rec.date_last_cleanup := rosetta_g_miss_date_in_map(p6_a36);
    ddp_klev_rec.year_of_manufacture := p6_a37;
    ddp_klev_rec.coverage_ratio := rosetta_g_miss_num_map(p6_a38);
    ddp_klev_rec.remarketed_amount := rosetta_g_miss_num_map(p6_a39);
    ddp_klev_rec.gross_square_footage := rosetta_g_miss_num_map(p6_a40);
    ddp_klev_rec.prescribed_asset_yn := p6_a41;
    ddp_klev_rec.date_remarketed := rosetta_g_miss_date_in_map(p6_a42);
    ddp_klev_rec.net_rentable := rosetta_g_miss_num_map(p6_a43);
    ddp_klev_rec.remarket_margin := rosetta_g_miss_num_map(p6_a44);
    ddp_klev_rec.date_letter_acceptance := rosetta_g_miss_date_in_map(p6_a45);
    ddp_klev_rec.repurchased_amount := rosetta_g_miss_num_map(p6_a46);
    ddp_klev_rec.date_commitment_expiration := rosetta_g_miss_date_in_map(p6_a47);
    ddp_klev_rec.date_repurchased := rosetta_g_miss_date_in_map(p6_a48);
    ddp_klev_rec.date_appraisal := rosetta_g_miss_date_in_map(p6_a49);
    ddp_klev_rec.residual_value := rosetta_g_miss_num_map(p6_a50);
    ddp_klev_rec.appraisal_value := rosetta_g_miss_num_map(p6_a51);
    ddp_klev_rec.secured_deal_yn := p6_a52;
    ddp_klev_rec.gain_loss := rosetta_g_miss_num_map(p6_a53);
    ddp_klev_rec.floor_amount := rosetta_g_miss_num_map(p6_a54);
    ddp_klev_rec.re_lease_yn := p6_a55;
    ddp_klev_rec.previous_contract := p6_a56;
    ddp_klev_rec.tracked_residual := rosetta_g_miss_num_map(p6_a57);
    ddp_klev_rec.date_title_received := rosetta_g_miss_date_in_map(p6_a58);
    ddp_klev_rec.amount := rosetta_g_miss_num_map(p6_a59);
    ddp_klev_rec.attribute_category := p6_a60;
    ddp_klev_rec.attribute1 := p6_a61;
    ddp_klev_rec.attribute2 := p6_a62;
    ddp_klev_rec.attribute3 := p6_a63;
    ddp_klev_rec.attribute4 := p6_a64;
    ddp_klev_rec.attribute5 := p6_a65;
    ddp_klev_rec.attribute6 := p6_a66;
    ddp_klev_rec.attribute7 := p6_a67;
    ddp_klev_rec.attribute8 := p6_a68;
    ddp_klev_rec.attribute9 := p6_a69;
    ddp_klev_rec.attribute10 := p6_a70;
    ddp_klev_rec.attribute11 := p6_a71;
    ddp_klev_rec.attribute12 := p6_a72;
    ddp_klev_rec.attribute13 := p6_a73;
    ddp_klev_rec.attribute14 := p6_a74;
    ddp_klev_rec.attribute15 := p6_a75;
    ddp_klev_rec.sty_id_for := rosetta_g_miss_num_map(p6_a76);
    ddp_klev_rec.clg_id := rosetta_g_miss_num_map(p6_a77);
    ddp_klev_rec.created_by := rosetta_g_miss_num_map(p6_a78);
    ddp_klev_rec.creation_date := rosetta_g_miss_date_in_map(p6_a79);
    ddp_klev_rec.last_updated_by := rosetta_g_miss_num_map(p6_a80);
    ddp_klev_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a81);
    ddp_klev_rec.last_update_login := rosetta_g_miss_num_map(p6_a82);
    ddp_klev_rec.date_funding := rosetta_g_miss_date_in_map(p6_a83);
    ddp_klev_rec.date_funding_required := rosetta_g_miss_date_in_map(p6_a84);
    ddp_klev_rec.date_accepted := rosetta_g_miss_date_in_map(p6_a85);
    ddp_klev_rec.date_delivery_expected := rosetta_g_miss_date_in_map(p6_a86);
    ddp_klev_rec.oec := rosetta_g_miss_num_map(p6_a87);
    ddp_klev_rec.capital_amount := rosetta_g_miss_num_map(p6_a88);
    ddp_klev_rec.residual_grnty_amount := rosetta_g_miss_num_map(p6_a89);
    ddp_klev_rec.residual_code := p6_a90;
    ddp_klev_rec.rvi_premium := rosetta_g_miss_num_map(p6_a91);
    ddp_klev_rec.credit_nature := p6_a92;
    ddp_klev_rec.capitalized_interest := rosetta_g_miss_num_map(p6_a93);
    ddp_klev_rec.capital_reduction_percent := rosetta_g_miss_num_map(p6_a94);
    ddp_klev_rec.date_pay_investor_start := rosetta_g_miss_date_in_map(p6_a95);
    ddp_klev_rec.pay_investor_frequency := p6_a96;
    ddp_klev_rec.pay_investor_event := p6_a97;
    ddp_klev_rec.pay_investor_remittance_days := rosetta_g_miss_num_map(p6_a98);

    ddp_cimv_rec.id := rosetta_g_miss_num_map(p7_a0);
    ddp_cimv_rec.object_version_number := rosetta_g_miss_num_map(p7_a1);
    ddp_cimv_rec.cle_id := rosetta_g_miss_num_map(p7_a2);
    ddp_cimv_rec.chr_id := rosetta_g_miss_num_map(p7_a3);
    ddp_cimv_rec.cle_id_for := rosetta_g_miss_num_map(p7_a4);
    ddp_cimv_rec.dnz_chr_id := rosetta_g_miss_num_map(p7_a5);
    ddp_cimv_rec.object1_id1 := p7_a6;
    ddp_cimv_rec.object1_id2 := p7_a7;
    ddp_cimv_rec.jtot_object1_code := p7_a8;
    ddp_cimv_rec.uom_code := p7_a9;
    ddp_cimv_rec.exception_yn := p7_a10;
    ddp_cimv_rec.number_of_items := rosetta_g_miss_num_map(p7_a11);
    ddp_cimv_rec.upg_orig_system_ref := p7_a12;
    ddp_cimv_rec.upg_orig_system_ref_id := rosetta_g_miss_num_map(p7_a13);
    ddp_cimv_rec.priced_item_yn := p7_a14;
    ddp_cimv_rec.created_by := rosetta_g_miss_num_map(p7_a15);
    ddp_cimv_rec.creation_date := rosetta_g_miss_date_in_map(p7_a16);
    ddp_cimv_rec.last_updated_by := rosetta_g_miss_num_map(p7_a17);
    ddp_cimv_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a18);
    ddp_cimv_rec.last_update_login := rosetta_g_miss_num_map(p7_a19);




    -- here's the delegated call to the old PL/SQL routine
    okl_contract_line_item_pvt.create_contract_line_item(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_clev_rec,
      ddp_klev_rec,
      ddp_cimv_rec,
      ddx_clev_rec,
      ddx_klev_rec,
      ddx_cimv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := rosetta_g_miss_num_map(ddx_clev_rec.id);
    p8_a1 := rosetta_g_miss_num_map(ddx_clev_rec.object_version_number);
    p8_a2 := ddx_clev_rec.sfwt_flag;
    p8_a3 := rosetta_g_miss_num_map(ddx_clev_rec.chr_id);
    p8_a4 := rosetta_g_miss_num_map(ddx_clev_rec.cle_id);
    p8_a5 := rosetta_g_miss_num_map(ddx_clev_rec.cle_id_renewed);
    p8_a6 := rosetta_g_miss_num_map(ddx_clev_rec.cle_id_renewed_to);
    p8_a7 := rosetta_g_miss_num_map(ddx_clev_rec.lse_id);
    p8_a8 := ddx_clev_rec.line_number;
    p8_a9 := ddx_clev_rec.sts_code;
    p8_a10 := rosetta_g_miss_num_map(ddx_clev_rec.display_sequence);
    p8_a11 := ddx_clev_rec.trn_code;
    p8_a12 := rosetta_g_miss_num_map(ddx_clev_rec.dnz_chr_id);
    p8_a13 := ddx_clev_rec.comments;
    p8_a14 := ddx_clev_rec.item_description;
    p8_a15 := ddx_clev_rec.oke_boe_description;
    p8_a16 := ddx_clev_rec.cognomen;
    p8_a17 := ddx_clev_rec.hidden_ind;
    p8_a18 := rosetta_g_miss_num_map(ddx_clev_rec.price_unit);
    p8_a19 := rosetta_g_miss_num_map(ddx_clev_rec.price_unit_percent);
    p8_a20 := rosetta_g_miss_num_map(ddx_clev_rec.price_negotiated);
    p8_a21 := rosetta_g_miss_num_map(ddx_clev_rec.price_negotiated_renewed);
    p8_a22 := ddx_clev_rec.price_level_ind;
    p8_a23 := ddx_clev_rec.invoice_line_level_ind;
    p8_a24 := ddx_clev_rec.dpas_rating;
    p8_a25 := ddx_clev_rec.block23text;
    p8_a26 := ddx_clev_rec.exception_yn;
    p8_a27 := ddx_clev_rec.template_used;
    p8_a28 := ddx_clev_rec.date_terminated;
    p8_a29 := ddx_clev_rec.name;
    p8_a30 := ddx_clev_rec.start_date;
    p8_a31 := ddx_clev_rec.end_date;
    p8_a32 := ddx_clev_rec.date_renewed;
    p8_a33 := ddx_clev_rec.upg_orig_system_ref;
    p8_a34 := rosetta_g_miss_num_map(ddx_clev_rec.upg_orig_system_ref_id);
    p8_a35 := ddx_clev_rec.orig_system_source_code;
    p8_a36 := rosetta_g_miss_num_map(ddx_clev_rec.orig_system_id1);
    p8_a37 := ddx_clev_rec.orig_system_reference1;
    p8_a38 := ddx_clev_rec.attribute_category;
    p8_a39 := ddx_clev_rec.attribute1;
    p8_a40 := ddx_clev_rec.attribute2;
    p8_a41 := ddx_clev_rec.attribute3;
    p8_a42 := ddx_clev_rec.attribute4;
    p8_a43 := ddx_clev_rec.attribute5;
    p8_a44 := ddx_clev_rec.attribute6;
    p8_a45 := ddx_clev_rec.attribute7;
    p8_a46 := ddx_clev_rec.attribute8;
    p8_a47 := ddx_clev_rec.attribute9;
    p8_a48 := ddx_clev_rec.attribute10;
    p8_a49 := ddx_clev_rec.attribute11;
    p8_a50 := ddx_clev_rec.attribute12;
    p8_a51 := ddx_clev_rec.attribute13;
    p8_a52 := ddx_clev_rec.attribute14;
    p8_a53 := ddx_clev_rec.attribute15;
    p8_a54 := rosetta_g_miss_num_map(ddx_clev_rec.created_by);
    p8_a55 := ddx_clev_rec.creation_date;
    p8_a56 := rosetta_g_miss_num_map(ddx_clev_rec.last_updated_by);
    p8_a57 := ddx_clev_rec.last_update_date;
    p8_a58 := ddx_clev_rec.price_type;
    p8_a59 := ddx_clev_rec.currency_code;
    p8_a60 := ddx_clev_rec.currency_code_renewed;
    p8_a61 := rosetta_g_miss_num_map(ddx_clev_rec.last_update_login);
    p8_a62 := ddx_clev_rec.old_sts_code;
    p8_a63 := ddx_clev_rec.new_sts_code;
    p8_a64 := ddx_clev_rec.old_ste_code;
    p8_a65 := ddx_clev_rec.new_ste_code;
    p8_a66 := ddx_clev_rec.call_action_asmblr;
    p8_a67 := rosetta_g_miss_num_map(ddx_clev_rec.request_id);
    p8_a68 := rosetta_g_miss_num_map(ddx_clev_rec.program_application_id);
    p8_a69 := rosetta_g_miss_num_map(ddx_clev_rec.program_id);
    p8_a70 := ddx_clev_rec.program_update_date;
    p8_a71 := rosetta_g_miss_num_map(ddx_clev_rec.price_list_id);
    p8_a72 := ddx_clev_rec.pricing_date;
    p8_a73 := rosetta_g_miss_num_map(ddx_clev_rec.price_list_line_id);
    p8_a74 := rosetta_g_miss_num_map(ddx_clev_rec.line_list_price);
    p8_a75 := ddx_clev_rec.item_to_price_yn;
    p8_a76 := ddx_clev_rec.price_basis_yn;
    p8_a77 := rosetta_g_miss_num_map(ddx_clev_rec.config_header_id);
    p8_a78 := rosetta_g_miss_num_map(ddx_clev_rec.config_revision_number);
    p8_a79 := ddx_clev_rec.config_complete_yn;
    p8_a80 := ddx_clev_rec.config_valid_yn;
    p8_a81 := rosetta_g_miss_num_map(ddx_clev_rec.config_top_model_line_id);
    p8_a82 := ddx_clev_rec.config_item_type;
    p8_a83 := rosetta_g_miss_num_map(ddx_clev_rec.config_item_id);
    p8_a84 := rosetta_g_miss_num_map(ddx_clev_rec.cust_acct_id);
    p8_a85 := rosetta_g_miss_num_map(ddx_clev_rec.bill_to_site_use_id);
    p8_a86 := rosetta_g_miss_num_map(ddx_clev_rec.inv_rule_id);
    p8_a87 := ddx_clev_rec.line_renewal_type_code;
    p8_a88 := rosetta_g_miss_num_map(ddx_clev_rec.ship_to_site_use_id);
    p8_a89 := rosetta_g_miss_num_map(ddx_clev_rec.payment_term_id);

    p9_a0 := rosetta_g_miss_num_map(ddx_klev_rec.id);
    p9_a1 := rosetta_g_miss_num_map(ddx_klev_rec.object_version_number);
    p9_a2 := rosetta_g_miss_num_map(ddx_klev_rec.kle_id);
    p9_a3 := rosetta_g_miss_num_map(ddx_klev_rec.sty_id);
    p9_a4 := ddx_klev_rec.prc_code;
    p9_a5 := ddx_klev_rec.fcg_code;
    p9_a6 := ddx_klev_rec.nty_code;
    p9_a7 := rosetta_g_miss_num_map(ddx_klev_rec.estimated_oec);
    p9_a8 := rosetta_g_miss_num_map(ddx_klev_rec.lao_amount);
    p9_a9 := ddx_klev_rec.title_date;
    p9_a10 := rosetta_g_miss_num_map(ddx_klev_rec.fee_charge);
    p9_a11 := rosetta_g_miss_num_map(ddx_klev_rec.lrs_percent);
    p9_a12 := rosetta_g_miss_num_map(ddx_klev_rec.initial_direct_cost);
    p9_a13 := rosetta_g_miss_num_map(ddx_klev_rec.percent_stake);
    p9_a14 := rosetta_g_miss_num_map(ddx_klev_rec.percent);
    p9_a15 := rosetta_g_miss_num_map(ddx_klev_rec.evergreen_percent);
    p9_a16 := rosetta_g_miss_num_map(ddx_klev_rec.amount_stake);
    p9_a17 := rosetta_g_miss_num_map(ddx_klev_rec.occupancy);
    p9_a18 := rosetta_g_miss_num_map(ddx_klev_rec.coverage);
    p9_a19 := rosetta_g_miss_num_map(ddx_klev_rec.residual_percentage);
    p9_a20 := ddx_klev_rec.date_last_inspection;
    p9_a21 := ddx_klev_rec.date_sold;
    p9_a22 := rosetta_g_miss_num_map(ddx_klev_rec.lrv_amount);
    p9_a23 := rosetta_g_miss_num_map(ddx_klev_rec.capital_reduction);
    p9_a24 := ddx_klev_rec.date_next_inspection_due;
    p9_a25 := ddx_klev_rec.date_residual_last_review;
    p9_a26 := ddx_klev_rec.date_last_reamortisation;
    p9_a27 := rosetta_g_miss_num_map(ddx_klev_rec.vendor_advance_paid);
    p9_a28 := rosetta_g_miss_num_map(ddx_klev_rec.weighted_average_life);
    p9_a29 := rosetta_g_miss_num_map(ddx_klev_rec.tradein_amount);
    p9_a30 := rosetta_g_miss_num_map(ddx_klev_rec.bond_equivalent_yield);
    p9_a31 := rosetta_g_miss_num_map(ddx_klev_rec.termination_purchase_amount);
    p9_a32 := rosetta_g_miss_num_map(ddx_klev_rec.refinance_amount);
    p9_a33 := rosetta_g_miss_num_map(ddx_klev_rec.year_built);
    p9_a34 := ddx_klev_rec.delivered_date;
    p9_a35 := ddx_klev_rec.credit_tenant_yn;
    p9_a36 := ddx_klev_rec.date_last_cleanup;
    p9_a37 := ddx_klev_rec.year_of_manufacture;
    p9_a38 := rosetta_g_miss_num_map(ddx_klev_rec.coverage_ratio);
    p9_a39 := rosetta_g_miss_num_map(ddx_klev_rec.remarketed_amount);
    p9_a40 := rosetta_g_miss_num_map(ddx_klev_rec.gross_square_footage);
    p9_a41 := ddx_klev_rec.prescribed_asset_yn;
    p9_a42 := ddx_klev_rec.date_remarketed;
    p9_a43 := rosetta_g_miss_num_map(ddx_klev_rec.net_rentable);
    p9_a44 := rosetta_g_miss_num_map(ddx_klev_rec.remarket_margin);
    p9_a45 := ddx_klev_rec.date_letter_acceptance;
    p9_a46 := rosetta_g_miss_num_map(ddx_klev_rec.repurchased_amount);
    p9_a47 := ddx_klev_rec.date_commitment_expiration;
    p9_a48 := ddx_klev_rec.date_repurchased;
    p9_a49 := ddx_klev_rec.date_appraisal;
    p9_a50 := rosetta_g_miss_num_map(ddx_klev_rec.residual_value);
    p9_a51 := rosetta_g_miss_num_map(ddx_klev_rec.appraisal_value);
    p9_a52 := ddx_klev_rec.secured_deal_yn;
    p9_a53 := rosetta_g_miss_num_map(ddx_klev_rec.gain_loss);
    p9_a54 := rosetta_g_miss_num_map(ddx_klev_rec.floor_amount);
    p9_a55 := ddx_klev_rec.re_lease_yn;
    p9_a56 := ddx_klev_rec.previous_contract;
    p9_a57 := rosetta_g_miss_num_map(ddx_klev_rec.tracked_residual);
    p9_a58 := ddx_klev_rec.date_title_received;
    p9_a59 := rosetta_g_miss_num_map(ddx_klev_rec.amount);
    p9_a60 := ddx_klev_rec.attribute_category;
    p9_a61 := ddx_klev_rec.attribute1;
    p9_a62 := ddx_klev_rec.attribute2;
    p9_a63 := ddx_klev_rec.attribute3;
    p9_a64 := ddx_klev_rec.attribute4;
    p9_a65 := ddx_klev_rec.attribute5;
    p9_a66 := ddx_klev_rec.attribute6;
    p9_a67 := ddx_klev_rec.attribute7;
    p9_a68 := ddx_klev_rec.attribute8;
    p9_a69 := ddx_klev_rec.attribute9;
    p9_a70 := ddx_klev_rec.attribute10;
    p9_a71 := ddx_klev_rec.attribute11;
    p9_a72 := ddx_klev_rec.attribute12;
    p9_a73 := ddx_klev_rec.attribute13;
    p9_a74 := ddx_klev_rec.attribute14;
    p9_a75 := ddx_klev_rec.attribute15;
    p9_a76 := rosetta_g_miss_num_map(ddx_klev_rec.sty_id_for);
    p9_a77 := rosetta_g_miss_num_map(ddx_klev_rec.clg_id);
    p9_a78 := rosetta_g_miss_num_map(ddx_klev_rec.created_by);
    p9_a79 := ddx_klev_rec.creation_date;
    p9_a80 := rosetta_g_miss_num_map(ddx_klev_rec.last_updated_by);
    p9_a81 := ddx_klev_rec.last_update_date;
    p9_a82 := rosetta_g_miss_num_map(ddx_klev_rec.last_update_login);
    p9_a83 := ddx_klev_rec.date_funding;
    p9_a84 := ddx_klev_rec.date_funding_required;
    p9_a85 := ddx_klev_rec.date_accepted;
    p9_a86 := ddx_klev_rec.date_delivery_expected;
    p9_a87 := rosetta_g_miss_num_map(ddx_klev_rec.oec);
    p9_a88 := rosetta_g_miss_num_map(ddx_klev_rec.capital_amount);
    p9_a89 := rosetta_g_miss_num_map(ddx_klev_rec.residual_grnty_amount);
    p9_a90 := ddx_klev_rec.residual_code;
    p9_a91 := rosetta_g_miss_num_map(ddx_klev_rec.rvi_premium);
    p9_a92 := ddx_klev_rec.credit_nature;
    p9_a93 := rosetta_g_miss_num_map(ddx_klev_rec.capitalized_interest);
    p9_a94 := rosetta_g_miss_num_map(ddx_klev_rec.capital_reduction_percent);
    p9_a95 := ddx_klev_rec.date_pay_investor_start;
    p9_a96 := ddx_klev_rec.pay_investor_frequency;
    p9_a97 := ddx_klev_rec.pay_investor_event;
    p9_a98 := rosetta_g_miss_num_map(ddx_klev_rec.pay_investor_remittance_days);

    p10_a0 := rosetta_g_miss_num_map(ddx_cimv_rec.id);
    p10_a1 := rosetta_g_miss_num_map(ddx_cimv_rec.object_version_number);
    p10_a2 := rosetta_g_miss_num_map(ddx_cimv_rec.cle_id);
    p10_a3 := rosetta_g_miss_num_map(ddx_cimv_rec.chr_id);
    p10_a4 := rosetta_g_miss_num_map(ddx_cimv_rec.cle_id_for);
    p10_a5 := rosetta_g_miss_num_map(ddx_cimv_rec.dnz_chr_id);
    p10_a6 := ddx_cimv_rec.object1_id1;
    p10_a7 := ddx_cimv_rec.object1_id2;
    p10_a8 := ddx_cimv_rec.jtot_object1_code;
    p10_a9 := ddx_cimv_rec.uom_code;
    p10_a10 := ddx_cimv_rec.exception_yn;
    p10_a11 := rosetta_g_miss_num_map(ddx_cimv_rec.number_of_items);
    p10_a12 := ddx_cimv_rec.upg_orig_system_ref;
    p10_a13 := rosetta_g_miss_num_map(ddx_cimv_rec.upg_orig_system_ref_id);
    p10_a14 := ddx_cimv_rec.priced_item_yn;
    p10_a15 := rosetta_g_miss_num_map(ddx_cimv_rec.created_by);
    p10_a16 := ddx_cimv_rec.creation_date;
    p10_a17 := rosetta_g_miss_num_map(ddx_cimv_rec.last_updated_by);
    p10_a18 := ddx_cimv_rec.last_update_date;
    p10_a19 := rosetta_g_miss_num_map(ddx_cimv_rec.last_update_login);
  end;

  procedure update_contract_line_item(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  NUMBER
    , p8_a4 out nocopy  NUMBER
    , p8_a5 out nocopy  NUMBER
    , p8_a6 out nocopy  NUMBER
    , p8_a7 out nocopy  NUMBER
    , p8_a8 out nocopy  VARCHAR2
    , p8_a9 out nocopy  VARCHAR2
    , p8_a10 out nocopy  NUMBER
    , p8_a11 out nocopy  VARCHAR2
    , p8_a12 out nocopy  NUMBER
    , p8_a13 out nocopy  VARCHAR2
    , p8_a14 out nocopy  VARCHAR2
    , p8_a15 out nocopy  VARCHAR2
    , p8_a16 out nocopy  VARCHAR2
    , p8_a17 out nocopy  VARCHAR2
    , p8_a18 out nocopy  NUMBER
    , p8_a19 out nocopy  NUMBER
    , p8_a20 out nocopy  NUMBER
    , p8_a21 out nocopy  NUMBER
    , p8_a22 out nocopy  VARCHAR2
    , p8_a23 out nocopy  VARCHAR2
    , p8_a24 out nocopy  VARCHAR2
    , p8_a25 out nocopy  VARCHAR2
    , p8_a26 out nocopy  VARCHAR2
    , p8_a27 out nocopy  VARCHAR2
    , p8_a28 out nocopy  DATE
    , p8_a29 out nocopy  VARCHAR2
    , p8_a30 out nocopy  DATE
    , p8_a31 out nocopy  DATE
    , p8_a32 out nocopy  DATE
    , p8_a33 out nocopy  VARCHAR2
    , p8_a34 out nocopy  NUMBER
    , p8_a35 out nocopy  VARCHAR2
    , p8_a36 out nocopy  NUMBER
    , p8_a37 out nocopy  VARCHAR2
    , p8_a38 out nocopy  VARCHAR2
    , p8_a39 out nocopy  VARCHAR2
    , p8_a40 out nocopy  VARCHAR2
    , p8_a41 out nocopy  VARCHAR2
    , p8_a42 out nocopy  VARCHAR2
    , p8_a43 out nocopy  VARCHAR2
    , p8_a44 out nocopy  VARCHAR2
    , p8_a45 out nocopy  VARCHAR2
    , p8_a46 out nocopy  VARCHAR2
    , p8_a47 out nocopy  VARCHAR2
    , p8_a48 out nocopy  VARCHAR2
    , p8_a49 out nocopy  VARCHAR2
    , p8_a50 out nocopy  VARCHAR2
    , p8_a51 out nocopy  VARCHAR2
    , p8_a52 out nocopy  VARCHAR2
    , p8_a53 out nocopy  VARCHAR2
    , p8_a54 out nocopy  NUMBER
    , p8_a55 out nocopy  DATE
    , p8_a56 out nocopy  NUMBER
    , p8_a57 out nocopy  DATE
    , p8_a58 out nocopy  VARCHAR2
    , p8_a59 out nocopy  VARCHAR2
    , p8_a60 out nocopy  VARCHAR2
    , p8_a61 out nocopy  NUMBER
    , p8_a62 out nocopy  VARCHAR2
    , p8_a63 out nocopy  VARCHAR2
    , p8_a64 out nocopy  VARCHAR2
    , p8_a65 out nocopy  VARCHAR2
    , p8_a66 out nocopy  VARCHAR2
    , p8_a67 out nocopy  NUMBER
    , p8_a68 out nocopy  NUMBER
    , p8_a69 out nocopy  NUMBER
    , p8_a70 out nocopy  DATE
    , p8_a71 out nocopy  NUMBER
    , p8_a72 out nocopy  DATE
    , p8_a73 out nocopy  NUMBER
    , p8_a74 out nocopy  NUMBER
    , p8_a75 out nocopy  VARCHAR2
    , p8_a76 out nocopy  VARCHAR2
    , p8_a77 out nocopy  NUMBER
    , p8_a78 out nocopy  NUMBER
    , p8_a79 out nocopy  VARCHAR2
    , p8_a80 out nocopy  VARCHAR2
    , p8_a81 out nocopy  NUMBER
    , p8_a82 out nocopy  VARCHAR2
    , p8_a83 out nocopy  NUMBER
    , p8_a84 out nocopy  NUMBER
    , p8_a85 out nocopy  NUMBER
    , p8_a86 out nocopy  NUMBER
    , p8_a87 out nocopy  VARCHAR2
    , p8_a88 out nocopy  NUMBER
    , p8_a89 out nocopy  NUMBER
    , p9_a0 out nocopy  NUMBER
    , p9_a1 out nocopy  NUMBER
    , p9_a2 out nocopy  NUMBER
    , p9_a3 out nocopy  NUMBER
    , p9_a4 out nocopy  VARCHAR2
    , p9_a5 out nocopy  VARCHAR2
    , p9_a6 out nocopy  VARCHAR2
    , p9_a7 out nocopy  NUMBER
    , p9_a8 out nocopy  NUMBER
    , p9_a9 out nocopy  DATE
    , p9_a10 out nocopy  NUMBER
    , p9_a11 out nocopy  NUMBER
    , p9_a12 out nocopy  NUMBER
    , p9_a13 out nocopy  NUMBER
    , p9_a14 out nocopy  NUMBER
    , p9_a15 out nocopy  NUMBER
    , p9_a16 out nocopy  NUMBER
    , p9_a17 out nocopy  NUMBER
    , p9_a18 out nocopy  NUMBER
    , p9_a19 out nocopy  NUMBER
    , p9_a20 out nocopy  DATE
    , p9_a21 out nocopy  DATE
    , p9_a22 out nocopy  NUMBER
    , p9_a23 out nocopy  NUMBER
    , p9_a24 out nocopy  DATE
    , p9_a25 out nocopy  DATE
    , p9_a26 out nocopy  DATE
    , p9_a27 out nocopy  NUMBER
    , p9_a28 out nocopy  NUMBER
    , p9_a29 out nocopy  NUMBER
    , p9_a30 out nocopy  NUMBER
    , p9_a31 out nocopy  NUMBER
    , p9_a32 out nocopy  NUMBER
    , p9_a33 out nocopy  NUMBER
    , p9_a34 out nocopy  DATE
    , p9_a35 out nocopy  VARCHAR2
    , p9_a36 out nocopy  DATE
    , p9_a37 out nocopy  VARCHAR2
    , p9_a38 out nocopy  NUMBER
    , p9_a39 out nocopy  NUMBER
    , p9_a40 out nocopy  NUMBER
    , p9_a41 out nocopy  VARCHAR2
    , p9_a42 out nocopy  DATE
    , p9_a43 out nocopy  NUMBER
    , p9_a44 out nocopy  NUMBER
    , p9_a45 out nocopy  DATE
    , p9_a46 out nocopy  NUMBER
    , p9_a47 out nocopy  DATE
    , p9_a48 out nocopy  DATE
    , p9_a49 out nocopy  DATE
    , p9_a50 out nocopy  NUMBER
    , p9_a51 out nocopy  NUMBER
    , p9_a52 out nocopy  VARCHAR2
    , p9_a53 out nocopy  NUMBER
    , p9_a54 out nocopy  NUMBER
    , p9_a55 out nocopy  VARCHAR2
    , p9_a56 out nocopy  VARCHAR2
    , p9_a57 out nocopy  NUMBER
    , p9_a58 out nocopy  DATE
    , p9_a59 out nocopy  NUMBER
    , p9_a60 out nocopy  VARCHAR2
    , p9_a61 out nocopy  VARCHAR2
    , p9_a62 out nocopy  VARCHAR2
    , p9_a63 out nocopy  VARCHAR2
    , p9_a64 out nocopy  VARCHAR2
    , p9_a65 out nocopy  VARCHAR2
    , p9_a66 out nocopy  VARCHAR2
    , p9_a67 out nocopy  VARCHAR2
    , p9_a68 out nocopy  VARCHAR2
    , p9_a69 out nocopy  VARCHAR2
    , p9_a70 out nocopy  VARCHAR2
    , p9_a71 out nocopy  VARCHAR2
    , p9_a72 out nocopy  VARCHAR2
    , p9_a73 out nocopy  VARCHAR2
    , p9_a74 out nocopy  VARCHAR2
    , p9_a75 out nocopy  VARCHAR2
    , p9_a76 out nocopy  NUMBER
    , p9_a77 out nocopy  NUMBER
    , p9_a78 out nocopy  NUMBER
    , p9_a79 out nocopy  DATE
    , p9_a80 out nocopy  NUMBER
    , p9_a81 out nocopy  DATE
    , p9_a82 out nocopy  NUMBER
    , p9_a83 out nocopy  DATE
    , p9_a84 out nocopy  DATE
    , p9_a85 out nocopy  DATE
    , p9_a86 out nocopy  DATE
    , p9_a87 out nocopy  NUMBER
    , p9_a88 out nocopy  NUMBER
    , p9_a89 out nocopy  NUMBER
    , p9_a90 out nocopy  VARCHAR2
    , p9_a91 out nocopy  NUMBER
    , p9_a92 out nocopy  VARCHAR2
    , p9_a93 out nocopy  NUMBER
    , p9_a94 out nocopy  NUMBER
    , p9_a95 out nocopy  DATE
    , p9_a96 out nocopy  VARCHAR2
    , p9_a97 out nocopy  VARCHAR2
    , p9_a98 out nocopy  NUMBER
    , p10_a0 out nocopy  NUMBER
    , p10_a1 out nocopy  NUMBER
    , p10_a2 out nocopy  NUMBER
    , p10_a3 out nocopy  NUMBER
    , p10_a4 out nocopy  NUMBER
    , p10_a5 out nocopy  NUMBER
    , p10_a6 out nocopy  VARCHAR2
    , p10_a7 out nocopy  VARCHAR2
    , p10_a8 out nocopy  VARCHAR2
    , p10_a9 out nocopy  VARCHAR2
    , p10_a10 out nocopy  VARCHAR2
    , p10_a11 out nocopy  NUMBER
    , p10_a12 out nocopy  VARCHAR2
    , p10_a13 out nocopy  NUMBER
    , p10_a14 out nocopy  VARCHAR2
    , p10_a15 out nocopy  NUMBER
    , p10_a16 out nocopy  DATE
    , p10_a17 out nocopy  NUMBER
    , p10_a18 out nocopy  DATE
    , p10_a19 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  DATE := fnd_api.g_miss_date
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  DATE := fnd_api.g_miss_date
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  DATE := fnd_api.g_miss_date
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  DATE := fnd_api.g_miss_date
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  NUMBER := 0-1962.0724
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  VARCHAR2 := fnd_api.g_miss_char
    , p5_a65  VARCHAR2 := fnd_api.g_miss_char
    , p5_a66  VARCHAR2 := fnd_api.g_miss_char
    , p5_a67  NUMBER := 0-1962.0724
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  NUMBER := 0-1962.0724
    , p5_a70  DATE := fnd_api.g_miss_date
    , p5_a71  NUMBER := 0-1962.0724
    , p5_a72  DATE := fnd_api.g_miss_date
    , p5_a73  NUMBER := 0-1962.0724
    , p5_a74  NUMBER := 0-1962.0724
    , p5_a75  VARCHAR2 := fnd_api.g_miss_char
    , p5_a76  VARCHAR2 := fnd_api.g_miss_char
    , p5_a77  NUMBER := 0-1962.0724
    , p5_a78  NUMBER := 0-1962.0724
    , p5_a79  VARCHAR2 := fnd_api.g_miss_char
    , p5_a80  VARCHAR2 := fnd_api.g_miss_char
    , p5_a81  NUMBER := 0-1962.0724
    , p5_a82  VARCHAR2 := fnd_api.g_miss_char
    , p5_a83  NUMBER := 0-1962.0724
    , p5_a84  NUMBER := 0-1962.0724
    , p5_a85  NUMBER := 0-1962.0724
    , p5_a86  NUMBER := 0-1962.0724
    , p5_a87  VARCHAR2 := fnd_api.g_miss_char
    , p5_a88  NUMBER := 0-1962.0724
    , p5_a89  NUMBER := 0-1962.0724
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  NUMBER := 0-1962.0724
    , p6_a3  NUMBER := 0-1962.0724
    , p6_a4  VARCHAR2 := fnd_api.g_miss_char
    , p6_a5  VARCHAR2 := fnd_api.g_miss_char
    , p6_a6  VARCHAR2 := fnd_api.g_miss_char
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  NUMBER := 0-1962.0724
    , p6_a9  DATE := fnd_api.g_miss_date
    , p6_a10  NUMBER := 0-1962.0724
    , p6_a11  NUMBER := 0-1962.0724
    , p6_a12  NUMBER := 0-1962.0724
    , p6_a13  NUMBER := 0-1962.0724
    , p6_a14  NUMBER := 0-1962.0724
    , p6_a15  NUMBER := 0-1962.0724
    , p6_a16  NUMBER := 0-1962.0724
    , p6_a17  NUMBER := 0-1962.0724
    , p6_a18  NUMBER := 0-1962.0724
    , p6_a19  NUMBER := 0-1962.0724
    , p6_a20  DATE := fnd_api.g_miss_date
    , p6_a21  DATE := fnd_api.g_miss_date
    , p6_a22  NUMBER := 0-1962.0724
    , p6_a23  NUMBER := 0-1962.0724
    , p6_a24  DATE := fnd_api.g_miss_date
    , p6_a25  DATE := fnd_api.g_miss_date
    , p6_a26  DATE := fnd_api.g_miss_date
    , p6_a27  NUMBER := 0-1962.0724
    , p6_a28  NUMBER := 0-1962.0724
    , p6_a29  NUMBER := 0-1962.0724
    , p6_a30  NUMBER := 0-1962.0724
    , p6_a31  NUMBER := 0-1962.0724
    , p6_a32  NUMBER := 0-1962.0724
    , p6_a33  NUMBER := 0-1962.0724
    , p6_a34  DATE := fnd_api.g_miss_date
    , p6_a35  VARCHAR2 := fnd_api.g_miss_char
    , p6_a36  DATE := fnd_api.g_miss_date
    , p6_a37  VARCHAR2 := fnd_api.g_miss_char
    , p6_a38  NUMBER := 0-1962.0724
    , p6_a39  NUMBER := 0-1962.0724
    , p6_a40  NUMBER := 0-1962.0724
    , p6_a41  VARCHAR2 := fnd_api.g_miss_char
    , p6_a42  DATE := fnd_api.g_miss_date
    , p6_a43  NUMBER := 0-1962.0724
    , p6_a44  NUMBER := 0-1962.0724
    , p6_a45  DATE := fnd_api.g_miss_date
    , p6_a46  NUMBER := 0-1962.0724
    , p6_a47  DATE := fnd_api.g_miss_date
    , p6_a48  DATE := fnd_api.g_miss_date
    , p6_a49  DATE := fnd_api.g_miss_date
    , p6_a50  NUMBER := 0-1962.0724
    , p6_a51  NUMBER := 0-1962.0724
    , p6_a52  VARCHAR2 := fnd_api.g_miss_char
    , p6_a53  NUMBER := 0-1962.0724
    , p6_a54  NUMBER := 0-1962.0724
    , p6_a55  VARCHAR2 := fnd_api.g_miss_char
    , p6_a56  VARCHAR2 := fnd_api.g_miss_char
    , p6_a57  NUMBER := 0-1962.0724
    , p6_a58  DATE := fnd_api.g_miss_date
    , p6_a59  NUMBER := 0-1962.0724
    , p6_a60  VARCHAR2 := fnd_api.g_miss_char
    , p6_a61  VARCHAR2 := fnd_api.g_miss_char
    , p6_a62  VARCHAR2 := fnd_api.g_miss_char
    , p6_a63  VARCHAR2 := fnd_api.g_miss_char
    , p6_a64  VARCHAR2 := fnd_api.g_miss_char
    , p6_a65  VARCHAR2 := fnd_api.g_miss_char
    , p6_a66  VARCHAR2 := fnd_api.g_miss_char
    , p6_a67  VARCHAR2 := fnd_api.g_miss_char
    , p6_a68  VARCHAR2 := fnd_api.g_miss_char
    , p6_a69  VARCHAR2 := fnd_api.g_miss_char
    , p6_a70  VARCHAR2 := fnd_api.g_miss_char
    , p6_a71  VARCHAR2 := fnd_api.g_miss_char
    , p6_a72  VARCHAR2 := fnd_api.g_miss_char
    , p6_a73  VARCHAR2 := fnd_api.g_miss_char
    , p6_a74  VARCHAR2 := fnd_api.g_miss_char
    , p6_a75  VARCHAR2 := fnd_api.g_miss_char
    , p6_a76  NUMBER := 0-1962.0724
    , p6_a77  NUMBER := 0-1962.0724
    , p6_a78  NUMBER := 0-1962.0724
    , p6_a79  DATE := fnd_api.g_miss_date
    , p6_a80  NUMBER := 0-1962.0724
    , p6_a81  DATE := fnd_api.g_miss_date
    , p6_a82  NUMBER := 0-1962.0724
    , p6_a83  DATE := fnd_api.g_miss_date
    , p6_a84  DATE := fnd_api.g_miss_date
    , p6_a85  DATE := fnd_api.g_miss_date
    , p6_a86  DATE := fnd_api.g_miss_date
    , p6_a87  NUMBER := 0-1962.0724
    , p6_a88  NUMBER := 0-1962.0724
    , p6_a89  NUMBER := 0-1962.0724
    , p6_a90  VARCHAR2 := fnd_api.g_miss_char
    , p6_a91  NUMBER := 0-1962.0724
    , p6_a92  VARCHAR2 := fnd_api.g_miss_char
    , p6_a93  NUMBER := 0-1962.0724
    , p6_a94  NUMBER := 0-1962.0724
    , p6_a95  DATE := fnd_api.g_miss_date
    , p6_a96  VARCHAR2 := fnd_api.g_miss_char
    , p6_a97  VARCHAR2 := fnd_api.g_miss_char
    , p6_a98  NUMBER := 0-1962.0724
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  DATE := fnd_api.g_miss_date
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  DATE := fnd_api.g_miss_date
    , p7_a19  NUMBER := 0-1962.0724
  )

  as
    ddp_clev_rec okl_contract_line_item_pvt.clev_rec_type;
    ddp_klev_rec okl_contract_line_item_pvt.klev_rec_type;
    ddp_cimv_rec okl_contract_line_item_pvt.cimv_rec_type;
    ddx_clev_rec okl_contract_line_item_pvt.clev_rec_type;
    ddx_klev_rec okl_contract_line_item_pvt.klev_rec_type;
    ddx_cimv_rec okl_contract_line_item_pvt.cimv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_clev_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_clev_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_clev_rec.sfwt_flag := p5_a2;
    ddp_clev_rec.chr_id := rosetta_g_miss_num_map(p5_a3);
    ddp_clev_rec.cle_id := rosetta_g_miss_num_map(p5_a4);
    ddp_clev_rec.cle_id_renewed := rosetta_g_miss_num_map(p5_a5);
    ddp_clev_rec.cle_id_renewed_to := rosetta_g_miss_num_map(p5_a6);
    ddp_clev_rec.lse_id := rosetta_g_miss_num_map(p5_a7);
    ddp_clev_rec.line_number := p5_a8;
    ddp_clev_rec.sts_code := p5_a9;
    ddp_clev_rec.display_sequence := rosetta_g_miss_num_map(p5_a10);
    ddp_clev_rec.trn_code := p5_a11;
    ddp_clev_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a12);
    ddp_clev_rec.comments := p5_a13;
    ddp_clev_rec.item_description := p5_a14;
    ddp_clev_rec.oke_boe_description := p5_a15;
    ddp_clev_rec.cognomen := p5_a16;
    ddp_clev_rec.hidden_ind := p5_a17;
    ddp_clev_rec.price_unit := rosetta_g_miss_num_map(p5_a18);
    ddp_clev_rec.price_unit_percent := rosetta_g_miss_num_map(p5_a19);
    ddp_clev_rec.price_negotiated := rosetta_g_miss_num_map(p5_a20);
    ddp_clev_rec.price_negotiated_renewed := rosetta_g_miss_num_map(p5_a21);
    ddp_clev_rec.price_level_ind := p5_a22;
    ddp_clev_rec.invoice_line_level_ind := p5_a23;
    ddp_clev_rec.dpas_rating := p5_a24;
    ddp_clev_rec.block23text := p5_a25;
    ddp_clev_rec.exception_yn := p5_a26;
    ddp_clev_rec.template_used := p5_a27;
    ddp_clev_rec.date_terminated := rosetta_g_miss_date_in_map(p5_a28);
    ddp_clev_rec.name := p5_a29;
    ddp_clev_rec.start_date := rosetta_g_miss_date_in_map(p5_a30);
    ddp_clev_rec.end_date := rosetta_g_miss_date_in_map(p5_a31);
    ddp_clev_rec.date_renewed := rosetta_g_miss_date_in_map(p5_a32);
    ddp_clev_rec.upg_orig_system_ref := p5_a33;
    ddp_clev_rec.upg_orig_system_ref_id := rosetta_g_miss_num_map(p5_a34);
    ddp_clev_rec.orig_system_source_code := p5_a35;
    ddp_clev_rec.orig_system_id1 := rosetta_g_miss_num_map(p5_a36);
    ddp_clev_rec.orig_system_reference1 := p5_a37;
    ddp_clev_rec.attribute_category := p5_a38;
    ddp_clev_rec.attribute1 := p5_a39;
    ddp_clev_rec.attribute2 := p5_a40;
    ddp_clev_rec.attribute3 := p5_a41;
    ddp_clev_rec.attribute4 := p5_a42;
    ddp_clev_rec.attribute5 := p5_a43;
    ddp_clev_rec.attribute6 := p5_a44;
    ddp_clev_rec.attribute7 := p5_a45;
    ddp_clev_rec.attribute8 := p5_a46;
    ddp_clev_rec.attribute9 := p5_a47;
    ddp_clev_rec.attribute10 := p5_a48;
    ddp_clev_rec.attribute11 := p5_a49;
    ddp_clev_rec.attribute12 := p5_a50;
    ddp_clev_rec.attribute13 := p5_a51;
    ddp_clev_rec.attribute14 := p5_a52;
    ddp_clev_rec.attribute15 := p5_a53;
    ddp_clev_rec.created_by := rosetta_g_miss_num_map(p5_a54);
    ddp_clev_rec.creation_date := rosetta_g_miss_date_in_map(p5_a55);
    ddp_clev_rec.last_updated_by := rosetta_g_miss_num_map(p5_a56);
    ddp_clev_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a57);
    ddp_clev_rec.price_type := p5_a58;
    ddp_clev_rec.currency_code := p5_a59;
    ddp_clev_rec.currency_code_renewed := p5_a60;
    ddp_clev_rec.last_update_login := rosetta_g_miss_num_map(p5_a61);
    ddp_clev_rec.old_sts_code := p5_a62;
    ddp_clev_rec.new_sts_code := p5_a63;
    ddp_clev_rec.old_ste_code := p5_a64;
    ddp_clev_rec.new_ste_code := p5_a65;
    ddp_clev_rec.call_action_asmblr := p5_a66;
    ddp_clev_rec.request_id := rosetta_g_miss_num_map(p5_a67);
    ddp_clev_rec.program_application_id := rosetta_g_miss_num_map(p5_a68);
    ddp_clev_rec.program_id := rosetta_g_miss_num_map(p5_a69);
    ddp_clev_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a70);
    ddp_clev_rec.price_list_id := rosetta_g_miss_num_map(p5_a71);
    ddp_clev_rec.pricing_date := rosetta_g_miss_date_in_map(p5_a72);
    ddp_clev_rec.price_list_line_id := rosetta_g_miss_num_map(p5_a73);
    ddp_clev_rec.line_list_price := rosetta_g_miss_num_map(p5_a74);
    ddp_clev_rec.item_to_price_yn := p5_a75;
    ddp_clev_rec.price_basis_yn := p5_a76;
    ddp_clev_rec.config_header_id := rosetta_g_miss_num_map(p5_a77);
    ddp_clev_rec.config_revision_number := rosetta_g_miss_num_map(p5_a78);
    ddp_clev_rec.config_complete_yn := p5_a79;
    ddp_clev_rec.config_valid_yn := p5_a80;
    ddp_clev_rec.config_top_model_line_id := rosetta_g_miss_num_map(p5_a81);
    ddp_clev_rec.config_item_type := p5_a82;
    ddp_clev_rec.config_item_id := rosetta_g_miss_num_map(p5_a83);
    ddp_clev_rec.cust_acct_id := rosetta_g_miss_num_map(p5_a84);
    ddp_clev_rec.bill_to_site_use_id := rosetta_g_miss_num_map(p5_a85);
    ddp_clev_rec.inv_rule_id := rosetta_g_miss_num_map(p5_a86);
    ddp_clev_rec.line_renewal_type_code := p5_a87;
    ddp_clev_rec.ship_to_site_use_id := rosetta_g_miss_num_map(p5_a88);
    ddp_clev_rec.payment_term_id := rosetta_g_miss_num_map(p5_a89);

    ddp_klev_rec.id := rosetta_g_miss_num_map(p6_a0);
    ddp_klev_rec.object_version_number := rosetta_g_miss_num_map(p6_a1);
    ddp_klev_rec.kle_id := rosetta_g_miss_num_map(p6_a2);
    ddp_klev_rec.sty_id := rosetta_g_miss_num_map(p6_a3);
    ddp_klev_rec.prc_code := p6_a4;
    ddp_klev_rec.fcg_code := p6_a5;
    ddp_klev_rec.nty_code := p6_a6;
    ddp_klev_rec.estimated_oec := rosetta_g_miss_num_map(p6_a7);
    ddp_klev_rec.lao_amount := rosetta_g_miss_num_map(p6_a8);
    ddp_klev_rec.title_date := rosetta_g_miss_date_in_map(p6_a9);
    ddp_klev_rec.fee_charge := rosetta_g_miss_num_map(p6_a10);
    ddp_klev_rec.lrs_percent := rosetta_g_miss_num_map(p6_a11);
    ddp_klev_rec.initial_direct_cost := rosetta_g_miss_num_map(p6_a12);
    ddp_klev_rec.percent_stake := rosetta_g_miss_num_map(p6_a13);
    ddp_klev_rec.percent := rosetta_g_miss_num_map(p6_a14);
    ddp_klev_rec.evergreen_percent := rosetta_g_miss_num_map(p6_a15);
    ddp_klev_rec.amount_stake := rosetta_g_miss_num_map(p6_a16);
    ddp_klev_rec.occupancy := rosetta_g_miss_num_map(p6_a17);
    ddp_klev_rec.coverage := rosetta_g_miss_num_map(p6_a18);
    ddp_klev_rec.residual_percentage := rosetta_g_miss_num_map(p6_a19);
    ddp_klev_rec.date_last_inspection := rosetta_g_miss_date_in_map(p6_a20);
    ddp_klev_rec.date_sold := rosetta_g_miss_date_in_map(p6_a21);
    ddp_klev_rec.lrv_amount := rosetta_g_miss_num_map(p6_a22);
    ddp_klev_rec.capital_reduction := rosetta_g_miss_num_map(p6_a23);
    ddp_klev_rec.date_next_inspection_due := rosetta_g_miss_date_in_map(p6_a24);
    ddp_klev_rec.date_residual_last_review := rosetta_g_miss_date_in_map(p6_a25);
    ddp_klev_rec.date_last_reamortisation := rosetta_g_miss_date_in_map(p6_a26);
    ddp_klev_rec.vendor_advance_paid := rosetta_g_miss_num_map(p6_a27);
    ddp_klev_rec.weighted_average_life := rosetta_g_miss_num_map(p6_a28);
    ddp_klev_rec.tradein_amount := rosetta_g_miss_num_map(p6_a29);
    ddp_klev_rec.bond_equivalent_yield := rosetta_g_miss_num_map(p6_a30);
    ddp_klev_rec.termination_purchase_amount := rosetta_g_miss_num_map(p6_a31);
    ddp_klev_rec.refinance_amount := rosetta_g_miss_num_map(p6_a32);
    ddp_klev_rec.year_built := rosetta_g_miss_num_map(p6_a33);
    ddp_klev_rec.delivered_date := rosetta_g_miss_date_in_map(p6_a34);
    ddp_klev_rec.credit_tenant_yn := p6_a35;
    ddp_klev_rec.date_last_cleanup := rosetta_g_miss_date_in_map(p6_a36);
    ddp_klev_rec.year_of_manufacture := p6_a37;
    ddp_klev_rec.coverage_ratio := rosetta_g_miss_num_map(p6_a38);
    ddp_klev_rec.remarketed_amount := rosetta_g_miss_num_map(p6_a39);
    ddp_klev_rec.gross_square_footage := rosetta_g_miss_num_map(p6_a40);
    ddp_klev_rec.prescribed_asset_yn := p6_a41;
    ddp_klev_rec.date_remarketed := rosetta_g_miss_date_in_map(p6_a42);
    ddp_klev_rec.net_rentable := rosetta_g_miss_num_map(p6_a43);
    ddp_klev_rec.remarket_margin := rosetta_g_miss_num_map(p6_a44);
    ddp_klev_rec.date_letter_acceptance := rosetta_g_miss_date_in_map(p6_a45);
    ddp_klev_rec.repurchased_amount := rosetta_g_miss_num_map(p6_a46);
    ddp_klev_rec.date_commitment_expiration := rosetta_g_miss_date_in_map(p6_a47);
    ddp_klev_rec.date_repurchased := rosetta_g_miss_date_in_map(p6_a48);
    ddp_klev_rec.date_appraisal := rosetta_g_miss_date_in_map(p6_a49);
    ddp_klev_rec.residual_value := rosetta_g_miss_num_map(p6_a50);
    ddp_klev_rec.appraisal_value := rosetta_g_miss_num_map(p6_a51);
    ddp_klev_rec.secured_deal_yn := p6_a52;
    ddp_klev_rec.gain_loss := rosetta_g_miss_num_map(p6_a53);
    ddp_klev_rec.floor_amount := rosetta_g_miss_num_map(p6_a54);
    ddp_klev_rec.re_lease_yn := p6_a55;
    ddp_klev_rec.previous_contract := p6_a56;
    ddp_klev_rec.tracked_residual := rosetta_g_miss_num_map(p6_a57);
    ddp_klev_rec.date_title_received := rosetta_g_miss_date_in_map(p6_a58);
    ddp_klev_rec.amount := rosetta_g_miss_num_map(p6_a59);
    ddp_klev_rec.attribute_category := p6_a60;
    ddp_klev_rec.attribute1 := p6_a61;
    ddp_klev_rec.attribute2 := p6_a62;
    ddp_klev_rec.attribute3 := p6_a63;
    ddp_klev_rec.attribute4 := p6_a64;
    ddp_klev_rec.attribute5 := p6_a65;
    ddp_klev_rec.attribute6 := p6_a66;
    ddp_klev_rec.attribute7 := p6_a67;
    ddp_klev_rec.attribute8 := p6_a68;
    ddp_klev_rec.attribute9 := p6_a69;
    ddp_klev_rec.attribute10 := p6_a70;
    ddp_klev_rec.attribute11 := p6_a71;
    ddp_klev_rec.attribute12 := p6_a72;
    ddp_klev_rec.attribute13 := p6_a73;
    ddp_klev_rec.attribute14 := p6_a74;
    ddp_klev_rec.attribute15 := p6_a75;
    ddp_klev_rec.sty_id_for := rosetta_g_miss_num_map(p6_a76);
    ddp_klev_rec.clg_id := rosetta_g_miss_num_map(p6_a77);
    ddp_klev_rec.created_by := rosetta_g_miss_num_map(p6_a78);
    ddp_klev_rec.creation_date := rosetta_g_miss_date_in_map(p6_a79);
    ddp_klev_rec.last_updated_by := rosetta_g_miss_num_map(p6_a80);
    ddp_klev_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a81);
    ddp_klev_rec.last_update_login := rosetta_g_miss_num_map(p6_a82);
    ddp_klev_rec.date_funding := rosetta_g_miss_date_in_map(p6_a83);
    ddp_klev_rec.date_funding_required := rosetta_g_miss_date_in_map(p6_a84);
    ddp_klev_rec.date_accepted := rosetta_g_miss_date_in_map(p6_a85);
    ddp_klev_rec.date_delivery_expected := rosetta_g_miss_date_in_map(p6_a86);
    ddp_klev_rec.oec := rosetta_g_miss_num_map(p6_a87);
    ddp_klev_rec.capital_amount := rosetta_g_miss_num_map(p6_a88);
    ddp_klev_rec.residual_grnty_amount := rosetta_g_miss_num_map(p6_a89);
    ddp_klev_rec.residual_code := p6_a90;
    ddp_klev_rec.rvi_premium := rosetta_g_miss_num_map(p6_a91);
    ddp_klev_rec.credit_nature := p6_a92;
    ddp_klev_rec.capitalized_interest := rosetta_g_miss_num_map(p6_a93);
    ddp_klev_rec.capital_reduction_percent := rosetta_g_miss_num_map(p6_a94);
    ddp_klev_rec.date_pay_investor_start := rosetta_g_miss_date_in_map(p6_a95);
    ddp_klev_rec.pay_investor_frequency := p6_a96;
    ddp_klev_rec.pay_investor_event := p6_a97;
    ddp_klev_rec.pay_investor_remittance_days := rosetta_g_miss_num_map(p6_a98);

    ddp_cimv_rec.id := rosetta_g_miss_num_map(p7_a0);
    ddp_cimv_rec.object_version_number := rosetta_g_miss_num_map(p7_a1);
    ddp_cimv_rec.cle_id := rosetta_g_miss_num_map(p7_a2);
    ddp_cimv_rec.chr_id := rosetta_g_miss_num_map(p7_a3);
    ddp_cimv_rec.cle_id_for := rosetta_g_miss_num_map(p7_a4);
    ddp_cimv_rec.dnz_chr_id := rosetta_g_miss_num_map(p7_a5);
    ddp_cimv_rec.object1_id1 := p7_a6;
    ddp_cimv_rec.object1_id2 := p7_a7;
    ddp_cimv_rec.jtot_object1_code := p7_a8;
    ddp_cimv_rec.uom_code := p7_a9;
    ddp_cimv_rec.exception_yn := p7_a10;
    ddp_cimv_rec.number_of_items := rosetta_g_miss_num_map(p7_a11);
    ddp_cimv_rec.upg_orig_system_ref := p7_a12;
    ddp_cimv_rec.upg_orig_system_ref_id := rosetta_g_miss_num_map(p7_a13);
    ddp_cimv_rec.priced_item_yn := p7_a14;
    ddp_cimv_rec.created_by := rosetta_g_miss_num_map(p7_a15);
    ddp_cimv_rec.creation_date := rosetta_g_miss_date_in_map(p7_a16);
    ddp_cimv_rec.last_updated_by := rosetta_g_miss_num_map(p7_a17);
    ddp_cimv_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a18);
    ddp_cimv_rec.last_update_login := rosetta_g_miss_num_map(p7_a19);




    -- here's the delegated call to the old PL/SQL routine
    okl_contract_line_item_pvt.update_contract_line_item(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_clev_rec,
      ddp_klev_rec,
      ddp_cimv_rec,
      ddx_clev_rec,
      ddx_klev_rec,
      ddx_cimv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := rosetta_g_miss_num_map(ddx_clev_rec.id);
    p8_a1 := rosetta_g_miss_num_map(ddx_clev_rec.object_version_number);
    p8_a2 := ddx_clev_rec.sfwt_flag;
    p8_a3 := rosetta_g_miss_num_map(ddx_clev_rec.chr_id);
    p8_a4 := rosetta_g_miss_num_map(ddx_clev_rec.cle_id);
    p8_a5 := rosetta_g_miss_num_map(ddx_clev_rec.cle_id_renewed);
    p8_a6 := rosetta_g_miss_num_map(ddx_clev_rec.cle_id_renewed_to);
    p8_a7 := rosetta_g_miss_num_map(ddx_clev_rec.lse_id);
    p8_a8 := ddx_clev_rec.line_number;
    p8_a9 := ddx_clev_rec.sts_code;
    p8_a10 := rosetta_g_miss_num_map(ddx_clev_rec.display_sequence);
    p8_a11 := ddx_clev_rec.trn_code;
    p8_a12 := rosetta_g_miss_num_map(ddx_clev_rec.dnz_chr_id);
    p8_a13 := ddx_clev_rec.comments;
    p8_a14 := ddx_clev_rec.item_description;
    p8_a15 := ddx_clev_rec.oke_boe_description;
    p8_a16 := ddx_clev_rec.cognomen;
    p8_a17 := ddx_clev_rec.hidden_ind;
    p8_a18 := rosetta_g_miss_num_map(ddx_clev_rec.price_unit);
    p8_a19 := rosetta_g_miss_num_map(ddx_clev_rec.price_unit_percent);
    p8_a20 := rosetta_g_miss_num_map(ddx_clev_rec.price_negotiated);
    p8_a21 := rosetta_g_miss_num_map(ddx_clev_rec.price_negotiated_renewed);
    p8_a22 := ddx_clev_rec.price_level_ind;
    p8_a23 := ddx_clev_rec.invoice_line_level_ind;
    p8_a24 := ddx_clev_rec.dpas_rating;
    p8_a25 := ddx_clev_rec.block23text;
    p8_a26 := ddx_clev_rec.exception_yn;
    p8_a27 := ddx_clev_rec.template_used;
    p8_a28 := ddx_clev_rec.date_terminated;
    p8_a29 := ddx_clev_rec.name;
    p8_a30 := ddx_clev_rec.start_date;
    p8_a31 := ddx_clev_rec.end_date;
    p8_a32 := ddx_clev_rec.date_renewed;
    p8_a33 := ddx_clev_rec.upg_orig_system_ref;
    p8_a34 := rosetta_g_miss_num_map(ddx_clev_rec.upg_orig_system_ref_id);
    p8_a35 := ddx_clev_rec.orig_system_source_code;
    p8_a36 := rosetta_g_miss_num_map(ddx_clev_rec.orig_system_id1);
    p8_a37 := ddx_clev_rec.orig_system_reference1;
    p8_a38 := ddx_clev_rec.attribute_category;
    p8_a39 := ddx_clev_rec.attribute1;
    p8_a40 := ddx_clev_rec.attribute2;
    p8_a41 := ddx_clev_rec.attribute3;
    p8_a42 := ddx_clev_rec.attribute4;
    p8_a43 := ddx_clev_rec.attribute5;
    p8_a44 := ddx_clev_rec.attribute6;
    p8_a45 := ddx_clev_rec.attribute7;
    p8_a46 := ddx_clev_rec.attribute8;
    p8_a47 := ddx_clev_rec.attribute9;
    p8_a48 := ddx_clev_rec.attribute10;
    p8_a49 := ddx_clev_rec.attribute11;
    p8_a50 := ddx_clev_rec.attribute12;
    p8_a51 := ddx_clev_rec.attribute13;
    p8_a52 := ddx_clev_rec.attribute14;
    p8_a53 := ddx_clev_rec.attribute15;
    p8_a54 := rosetta_g_miss_num_map(ddx_clev_rec.created_by);
    p8_a55 := ddx_clev_rec.creation_date;
    p8_a56 := rosetta_g_miss_num_map(ddx_clev_rec.last_updated_by);
    p8_a57 := ddx_clev_rec.last_update_date;
    p8_a58 := ddx_clev_rec.price_type;
    p8_a59 := ddx_clev_rec.currency_code;
    p8_a60 := ddx_clev_rec.currency_code_renewed;
    p8_a61 := rosetta_g_miss_num_map(ddx_clev_rec.last_update_login);
    p8_a62 := ddx_clev_rec.old_sts_code;
    p8_a63 := ddx_clev_rec.new_sts_code;
    p8_a64 := ddx_clev_rec.old_ste_code;
    p8_a65 := ddx_clev_rec.new_ste_code;
    p8_a66 := ddx_clev_rec.call_action_asmblr;
    p8_a67 := rosetta_g_miss_num_map(ddx_clev_rec.request_id);
    p8_a68 := rosetta_g_miss_num_map(ddx_clev_rec.program_application_id);
    p8_a69 := rosetta_g_miss_num_map(ddx_clev_rec.program_id);
    p8_a70 := ddx_clev_rec.program_update_date;
    p8_a71 := rosetta_g_miss_num_map(ddx_clev_rec.price_list_id);
    p8_a72 := ddx_clev_rec.pricing_date;
    p8_a73 := rosetta_g_miss_num_map(ddx_clev_rec.price_list_line_id);
    p8_a74 := rosetta_g_miss_num_map(ddx_clev_rec.line_list_price);
    p8_a75 := ddx_clev_rec.item_to_price_yn;
    p8_a76 := ddx_clev_rec.price_basis_yn;
    p8_a77 := rosetta_g_miss_num_map(ddx_clev_rec.config_header_id);
    p8_a78 := rosetta_g_miss_num_map(ddx_clev_rec.config_revision_number);
    p8_a79 := ddx_clev_rec.config_complete_yn;
    p8_a80 := ddx_clev_rec.config_valid_yn;
    p8_a81 := rosetta_g_miss_num_map(ddx_clev_rec.config_top_model_line_id);
    p8_a82 := ddx_clev_rec.config_item_type;
    p8_a83 := rosetta_g_miss_num_map(ddx_clev_rec.config_item_id);
    p8_a84 := rosetta_g_miss_num_map(ddx_clev_rec.cust_acct_id);
    p8_a85 := rosetta_g_miss_num_map(ddx_clev_rec.bill_to_site_use_id);
    p8_a86 := rosetta_g_miss_num_map(ddx_clev_rec.inv_rule_id);
    p8_a87 := ddx_clev_rec.line_renewal_type_code;
    p8_a88 := rosetta_g_miss_num_map(ddx_clev_rec.ship_to_site_use_id);
    p8_a89 := rosetta_g_miss_num_map(ddx_clev_rec.payment_term_id);

    p9_a0 := rosetta_g_miss_num_map(ddx_klev_rec.id);
    p9_a1 := rosetta_g_miss_num_map(ddx_klev_rec.object_version_number);
    p9_a2 := rosetta_g_miss_num_map(ddx_klev_rec.kle_id);
    p9_a3 := rosetta_g_miss_num_map(ddx_klev_rec.sty_id);
    p9_a4 := ddx_klev_rec.prc_code;
    p9_a5 := ddx_klev_rec.fcg_code;
    p9_a6 := ddx_klev_rec.nty_code;
    p9_a7 := rosetta_g_miss_num_map(ddx_klev_rec.estimated_oec);
    p9_a8 := rosetta_g_miss_num_map(ddx_klev_rec.lao_amount);
    p9_a9 := ddx_klev_rec.title_date;
    p9_a10 := rosetta_g_miss_num_map(ddx_klev_rec.fee_charge);
    p9_a11 := rosetta_g_miss_num_map(ddx_klev_rec.lrs_percent);
    p9_a12 := rosetta_g_miss_num_map(ddx_klev_rec.initial_direct_cost);
    p9_a13 := rosetta_g_miss_num_map(ddx_klev_rec.percent_stake);
    p9_a14 := rosetta_g_miss_num_map(ddx_klev_rec.percent);
    p9_a15 := rosetta_g_miss_num_map(ddx_klev_rec.evergreen_percent);
    p9_a16 := rosetta_g_miss_num_map(ddx_klev_rec.amount_stake);
    p9_a17 := rosetta_g_miss_num_map(ddx_klev_rec.occupancy);
    p9_a18 := rosetta_g_miss_num_map(ddx_klev_rec.coverage);
    p9_a19 := rosetta_g_miss_num_map(ddx_klev_rec.residual_percentage);
    p9_a20 := ddx_klev_rec.date_last_inspection;
    p9_a21 := ddx_klev_rec.date_sold;
    p9_a22 := rosetta_g_miss_num_map(ddx_klev_rec.lrv_amount);
    p9_a23 := rosetta_g_miss_num_map(ddx_klev_rec.capital_reduction);
    p9_a24 := ddx_klev_rec.date_next_inspection_due;
    p9_a25 := ddx_klev_rec.date_residual_last_review;
    p9_a26 := ddx_klev_rec.date_last_reamortisation;
    p9_a27 := rosetta_g_miss_num_map(ddx_klev_rec.vendor_advance_paid);
    p9_a28 := rosetta_g_miss_num_map(ddx_klev_rec.weighted_average_life);
    p9_a29 := rosetta_g_miss_num_map(ddx_klev_rec.tradein_amount);
    p9_a30 := rosetta_g_miss_num_map(ddx_klev_rec.bond_equivalent_yield);
    p9_a31 := rosetta_g_miss_num_map(ddx_klev_rec.termination_purchase_amount);
    p9_a32 := rosetta_g_miss_num_map(ddx_klev_rec.refinance_amount);
    p9_a33 := rosetta_g_miss_num_map(ddx_klev_rec.year_built);
    p9_a34 := ddx_klev_rec.delivered_date;
    p9_a35 := ddx_klev_rec.credit_tenant_yn;
    p9_a36 := ddx_klev_rec.date_last_cleanup;
    p9_a37 := ddx_klev_rec.year_of_manufacture;
    p9_a38 := rosetta_g_miss_num_map(ddx_klev_rec.coverage_ratio);
    p9_a39 := rosetta_g_miss_num_map(ddx_klev_rec.remarketed_amount);
    p9_a40 := rosetta_g_miss_num_map(ddx_klev_rec.gross_square_footage);
    p9_a41 := ddx_klev_rec.prescribed_asset_yn;
    p9_a42 := ddx_klev_rec.date_remarketed;
    p9_a43 := rosetta_g_miss_num_map(ddx_klev_rec.net_rentable);
    p9_a44 := rosetta_g_miss_num_map(ddx_klev_rec.remarket_margin);
    p9_a45 := ddx_klev_rec.date_letter_acceptance;
    p9_a46 := rosetta_g_miss_num_map(ddx_klev_rec.repurchased_amount);
    p9_a47 := ddx_klev_rec.date_commitment_expiration;
    p9_a48 := ddx_klev_rec.date_repurchased;
    p9_a49 := ddx_klev_rec.date_appraisal;
    p9_a50 := rosetta_g_miss_num_map(ddx_klev_rec.residual_value);
    p9_a51 := rosetta_g_miss_num_map(ddx_klev_rec.appraisal_value);
    p9_a52 := ddx_klev_rec.secured_deal_yn;
    p9_a53 := rosetta_g_miss_num_map(ddx_klev_rec.gain_loss);
    p9_a54 := rosetta_g_miss_num_map(ddx_klev_rec.floor_amount);
    p9_a55 := ddx_klev_rec.re_lease_yn;
    p9_a56 := ddx_klev_rec.previous_contract;
    p9_a57 := rosetta_g_miss_num_map(ddx_klev_rec.tracked_residual);
    p9_a58 := ddx_klev_rec.date_title_received;
    p9_a59 := rosetta_g_miss_num_map(ddx_klev_rec.amount);
    p9_a60 := ddx_klev_rec.attribute_category;
    p9_a61 := ddx_klev_rec.attribute1;
    p9_a62 := ddx_klev_rec.attribute2;
    p9_a63 := ddx_klev_rec.attribute3;
    p9_a64 := ddx_klev_rec.attribute4;
    p9_a65 := ddx_klev_rec.attribute5;
    p9_a66 := ddx_klev_rec.attribute6;
    p9_a67 := ddx_klev_rec.attribute7;
    p9_a68 := ddx_klev_rec.attribute8;
    p9_a69 := ddx_klev_rec.attribute9;
    p9_a70 := ddx_klev_rec.attribute10;
    p9_a71 := ddx_klev_rec.attribute11;
    p9_a72 := ddx_klev_rec.attribute12;
    p9_a73 := ddx_klev_rec.attribute13;
    p9_a74 := ddx_klev_rec.attribute14;
    p9_a75 := ddx_klev_rec.attribute15;
    p9_a76 := rosetta_g_miss_num_map(ddx_klev_rec.sty_id_for);
    p9_a77 := rosetta_g_miss_num_map(ddx_klev_rec.clg_id);
    p9_a78 := rosetta_g_miss_num_map(ddx_klev_rec.created_by);
    p9_a79 := ddx_klev_rec.creation_date;
    p9_a80 := rosetta_g_miss_num_map(ddx_klev_rec.last_updated_by);
    p9_a81 := ddx_klev_rec.last_update_date;
    p9_a82 := rosetta_g_miss_num_map(ddx_klev_rec.last_update_login);
    p9_a83 := ddx_klev_rec.date_funding;
    p9_a84 := ddx_klev_rec.date_funding_required;
    p9_a85 := ddx_klev_rec.date_accepted;
    p9_a86 := ddx_klev_rec.date_delivery_expected;
    p9_a87 := rosetta_g_miss_num_map(ddx_klev_rec.oec);
    p9_a88 := rosetta_g_miss_num_map(ddx_klev_rec.capital_amount);
    p9_a89 := rosetta_g_miss_num_map(ddx_klev_rec.residual_grnty_amount);
    p9_a90 := ddx_klev_rec.residual_code;
    p9_a91 := rosetta_g_miss_num_map(ddx_klev_rec.rvi_premium);
    p9_a92 := ddx_klev_rec.credit_nature;
    p9_a93 := rosetta_g_miss_num_map(ddx_klev_rec.capitalized_interest);
    p9_a94 := rosetta_g_miss_num_map(ddx_klev_rec.capital_reduction_percent);
    p9_a95 := ddx_klev_rec.date_pay_investor_start;
    p9_a96 := ddx_klev_rec.pay_investor_frequency;
    p9_a97 := ddx_klev_rec.pay_investor_event;
    p9_a98 := rosetta_g_miss_num_map(ddx_klev_rec.pay_investor_remittance_days);

    p10_a0 := rosetta_g_miss_num_map(ddx_cimv_rec.id);
    p10_a1 := rosetta_g_miss_num_map(ddx_cimv_rec.object_version_number);
    p10_a2 := rosetta_g_miss_num_map(ddx_cimv_rec.cle_id);
    p10_a3 := rosetta_g_miss_num_map(ddx_cimv_rec.chr_id);
    p10_a4 := rosetta_g_miss_num_map(ddx_cimv_rec.cle_id_for);
    p10_a5 := rosetta_g_miss_num_map(ddx_cimv_rec.dnz_chr_id);
    p10_a6 := ddx_cimv_rec.object1_id1;
    p10_a7 := ddx_cimv_rec.object1_id2;
    p10_a8 := ddx_cimv_rec.jtot_object1_code;
    p10_a9 := ddx_cimv_rec.uom_code;
    p10_a10 := ddx_cimv_rec.exception_yn;
    p10_a11 := rosetta_g_miss_num_map(ddx_cimv_rec.number_of_items);
    p10_a12 := ddx_cimv_rec.upg_orig_system_ref;
    p10_a13 := rosetta_g_miss_num_map(ddx_cimv_rec.upg_orig_system_ref_id);
    p10_a14 := ddx_cimv_rec.priced_item_yn;
    p10_a15 := rosetta_g_miss_num_map(ddx_cimv_rec.created_by);
    p10_a16 := ddx_cimv_rec.creation_date;
    p10_a17 := rosetta_g_miss_num_map(ddx_cimv_rec.last_updated_by);
    p10_a18 := ddx_cimv_rec.last_update_date;
    p10_a19 := rosetta_g_miss_num_map(ddx_cimv_rec.last_update_login);
  end;

  procedure delete_contract_line_item(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  DATE := fnd_api.g_miss_date
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  DATE := fnd_api.g_miss_date
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  DATE := fnd_api.g_miss_date
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  DATE := fnd_api.g_miss_date
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  NUMBER := 0-1962.0724
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  VARCHAR2 := fnd_api.g_miss_char
    , p5_a65  VARCHAR2 := fnd_api.g_miss_char
    , p5_a66  VARCHAR2 := fnd_api.g_miss_char
    , p5_a67  NUMBER := 0-1962.0724
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  NUMBER := 0-1962.0724
    , p5_a70  DATE := fnd_api.g_miss_date
    , p5_a71  NUMBER := 0-1962.0724
    , p5_a72  DATE := fnd_api.g_miss_date
    , p5_a73  NUMBER := 0-1962.0724
    , p5_a74  NUMBER := 0-1962.0724
    , p5_a75  VARCHAR2 := fnd_api.g_miss_char
    , p5_a76  VARCHAR2 := fnd_api.g_miss_char
    , p5_a77  NUMBER := 0-1962.0724
    , p5_a78  NUMBER := 0-1962.0724
    , p5_a79  VARCHAR2 := fnd_api.g_miss_char
    , p5_a80  VARCHAR2 := fnd_api.g_miss_char
    , p5_a81  NUMBER := 0-1962.0724
    , p5_a82  VARCHAR2 := fnd_api.g_miss_char
    , p5_a83  NUMBER := 0-1962.0724
    , p5_a84  NUMBER := 0-1962.0724
    , p5_a85  NUMBER := 0-1962.0724
    , p5_a86  NUMBER := 0-1962.0724
    , p5_a87  VARCHAR2 := fnd_api.g_miss_char
    , p5_a88  NUMBER := 0-1962.0724
    , p5_a89  NUMBER := 0-1962.0724
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  NUMBER := 0-1962.0724
    , p6_a3  NUMBER := 0-1962.0724
    , p6_a4  VARCHAR2 := fnd_api.g_miss_char
    , p6_a5  VARCHAR2 := fnd_api.g_miss_char
    , p6_a6  VARCHAR2 := fnd_api.g_miss_char
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  NUMBER := 0-1962.0724
    , p6_a9  DATE := fnd_api.g_miss_date
    , p6_a10  NUMBER := 0-1962.0724
    , p6_a11  NUMBER := 0-1962.0724
    , p6_a12  NUMBER := 0-1962.0724
    , p6_a13  NUMBER := 0-1962.0724
    , p6_a14  NUMBER := 0-1962.0724
    , p6_a15  NUMBER := 0-1962.0724
    , p6_a16  NUMBER := 0-1962.0724
    , p6_a17  NUMBER := 0-1962.0724
    , p6_a18  NUMBER := 0-1962.0724
    , p6_a19  NUMBER := 0-1962.0724
    , p6_a20  DATE := fnd_api.g_miss_date
    , p6_a21  DATE := fnd_api.g_miss_date
    , p6_a22  NUMBER := 0-1962.0724
    , p6_a23  NUMBER := 0-1962.0724
    , p6_a24  DATE := fnd_api.g_miss_date
    , p6_a25  DATE := fnd_api.g_miss_date
    , p6_a26  DATE := fnd_api.g_miss_date
    , p6_a27  NUMBER := 0-1962.0724
    , p6_a28  NUMBER := 0-1962.0724
    , p6_a29  NUMBER := 0-1962.0724
    , p6_a30  NUMBER := 0-1962.0724
    , p6_a31  NUMBER := 0-1962.0724
    , p6_a32  NUMBER := 0-1962.0724
    , p6_a33  NUMBER := 0-1962.0724
    , p6_a34  DATE := fnd_api.g_miss_date
    , p6_a35  VARCHAR2 := fnd_api.g_miss_char
    , p6_a36  DATE := fnd_api.g_miss_date
    , p6_a37  VARCHAR2 := fnd_api.g_miss_char
    , p6_a38  NUMBER := 0-1962.0724
    , p6_a39  NUMBER := 0-1962.0724
    , p6_a40  NUMBER := 0-1962.0724
    , p6_a41  VARCHAR2 := fnd_api.g_miss_char
    , p6_a42  DATE := fnd_api.g_miss_date
    , p6_a43  NUMBER := 0-1962.0724
    , p6_a44  NUMBER := 0-1962.0724
    , p6_a45  DATE := fnd_api.g_miss_date
    , p6_a46  NUMBER := 0-1962.0724
    , p6_a47  DATE := fnd_api.g_miss_date
    , p6_a48  DATE := fnd_api.g_miss_date
    , p6_a49  DATE := fnd_api.g_miss_date
    , p6_a50  NUMBER := 0-1962.0724
    , p6_a51  NUMBER := 0-1962.0724
    , p6_a52  VARCHAR2 := fnd_api.g_miss_char
    , p6_a53  NUMBER := 0-1962.0724
    , p6_a54  NUMBER := 0-1962.0724
    , p6_a55  VARCHAR2 := fnd_api.g_miss_char
    , p6_a56  VARCHAR2 := fnd_api.g_miss_char
    , p6_a57  NUMBER := 0-1962.0724
    , p6_a58  DATE := fnd_api.g_miss_date
    , p6_a59  NUMBER := 0-1962.0724
    , p6_a60  VARCHAR2 := fnd_api.g_miss_char
    , p6_a61  VARCHAR2 := fnd_api.g_miss_char
    , p6_a62  VARCHAR2 := fnd_api.g_miss_char
    , p6_a63  VARCHAR2 := fnd_api.g_miss_char
    , p6_a64  VARCHAR2 := fnd_api.g_miss_char
    , p6_a65  VARCHAR2 := fnd_api.g_miss_char
    , p6_a66  VARCHAR2 := fnd_api.g_miss_char
    , p6_a67  VARCHAR2 := fnd_api.g_miss_char
    , p6_a68  VARCHAR2 := fnd_api.g_miss_char
    , p6_a69  VARCHAR2 := fnd_api.g_miss_char
    , p6_a70  VARCHAR2 := fnd_api.g_miss_char
    , p6_a71  VARCHAR2 := fnd_api.g_miss_char
    , p6_a72  VARCHAR2 := fnd_api.g_miss_char
    , p6_a73  VARCHAR2 := fnd_api.g_miss_char
    , p6_a74  VARCHAR2 := fnd_api.g_miss_char
    , p6_a75  VARCHAR2 := fnd_api.g_miss_char
    , p6_a76  NUMBER := 0-1962.0724
    , p6_a77  NUMBER := 0-1962.0724
    , p6_a78  NUMBER := 0-1962.0724
    , p6_a79  DATE := fnd_api.g_miss_date
    , p6_a80  NUMBER := 0-1962.0724
    , p6_a81  DATE := fnd_api.g_miss_date
    , p6_a82  NUMBER := 0-1962.0724
    , p6_a83  DATE := fnd_api.g_miss_date
    , p6_a84  DATE := fnd_api.g_miss_date
    , p6_a85  DATE := fnd_api.g_miss_date
    , p6_a86  DATE := fnd_api.g_miss_date
    , p6_a87  NUMBER := 0-1962.0724
    , p6_a88  NUMBER := 0-1962.0724
    , p6_a89  NUMBER := 0-1962.0724
    , p6_a90  VARCHAR2 := fnd_api.g_miss_char
    , p6_a91  NUMBER := 0-1962.0724
    , p6_a92  VARCHAR2 := fnd_api.g_miss_char
    , p6_a93  NUMBER := 0-1962.0724
    , p6_a94  NUMBER := 0-1962.0724
    , p6_a95  DATE := fnd_api.g_miss_date
    , p6_a96  VARCHAR2 := fnd_api.g_miss_char
    , p6_a97  VARCHAR2 := fnd_api.g_miss_char
    , p6_a98  NUMBER := 0-1962.0724
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  DATE := fnd_api.g_miss_date
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  DATE := fnd_api.g_miss_date
    , p7_a19  NUMBER := 0-1962.0724
  )

  as
    ddp_clev_rec okl_contract_line_item_pvt.clev_rec_type;
    ddp_klev_rec okl_contract_line_item_pvt.klev_rec_type;
    ddp_cimv_rec okl_contract_line_item_pvt.cimv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_clev_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_clev_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_clev_rec.sfwt_flag := p5_a2;
    ddp_clev_rec.chr_id := rosetta_g_miss_num_map(p5_a3);
    ddp_clev_rec.cle_id := rosetta_g_miss_num_map(p5_a4);
    ddp_clev_rec.cle_id_renewed := rosetta_g_miss_num_map(p5_a5);
    ddp_clev_rec.cle_id_renewed_to := rosetta_g_miss_num_map(p5_a6);
    ddp_clev_rec.lse_id := rosetta_g_miss_num_map(p5_a7);
    ddp_clev_rec.line_number := p5_a8;
    ddp_clev_rec.sts_code := p5_a9;
    ddp_clev_rec.display_sequence := rosetta_g_miss_num_map(p5_a10);
    ddp_clev_rec.trn_code := p5_a11;
    ddp_clev_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a12);
    ddp_clev_rec.comments := p5_a13;
    ddp_clev_rec.item_description := p5_a14;
    ddp_clev_rec.oke_boe_description := p5_a15;
    ddp_clev_rec.cognomen := p5_a16;
    ddp_clev_rec.hidden_ind := p5_a17;
    ddp_clev_rec.price_unit := rosetta_g_miss_num_map(p5_a18);
    ddp_clev_rec.price_unit_percent := rosetta_g_miss_num_map(p5_a19);
    ddp_clev_rec.price_negotiated := rosetta_g_miss_num_map(p5_a20);
    ddp_clev_rec.price_negotiated_renewed := rosetta_g_miss_num_map(p5_a21);
    ddp_clev_rec.price_level_ind := p5_a22;
    ddp_clev_rec.invoice_line_level_ind := p5_a23;
    ddp_clev_rec.dpas_rating := p5_a24;
    ddp_clev_rec.block23text := p5_a25;
    ddp_clev_rec.exception_yn := p5_a26;
    ddp_clev_rec.template_used := p5_a27;
    ddp_clev_rec.date_terminated := rosetta_g_miss_date_in_map(p5_a28);
    ddp_clev_rec.name := p5_a29;
    ddp_clev_rec.start_date := rosetta_g_miss_date_in_map(p5_a30);
    ddp_clev_rec.end_date := rosetta_g_miss_date_in_map(p5_a31);
    ddp_clev_rec.date_renewed := rosetta_g_miss_date_in_map(p5_a32);
    ddp_clev_rec.upg_orig_system_ref := p5_a33;
    ddp_clev_rec.upg_orig_system_ref_id := rosetta_g_miss_num_map(p5_a34);
    ddp_clev_rec.orig_system_source_code := p5_a35;
    ddp_clev_rec.orig_system_id1 := rosetta_g_miss_num_map(p5_a36);
    ddp_clev_rec.orig_system_reference1 := p5_a37;
    ddp_clev_rec.attribute_category := p5_a38;
    ddp_clev_rec.attribute1 := p5_a39;
    ddp_clev_rec.attribute2 := p5_a40;
    ddp_clev_rec.attribute3 := p5_a41;
    ddp_clev_rec.attribute4 := p5_a42;
    ddp_clev_rec.attribute5 := p5_a43;
    ddp_clev_rec.attribute6 := p5_a44;
    ddp_clev_rec.attribute7 := p5_a45;
    ddp_clev_rec.attribute8 := p5_a46;
    ddp_clev_rec.attribute9 := p5_a47;
    ddp_clev_rec.attribute10 := p5_a48;
    ddp_clev_rec.attribute11 := p5_a49;
    ddp_clev_rec.attribute12 := p5_a50;
    ddp_clev_rec.attribute13 := p5_a51;
    ddp_clev_rec.attribute14 := p5_a52;
    ddp_clev_rec.attribute15 := p5_a53;
    ddp_clev_rec.created_by := rosetta_g_miss_num_map(p5_a54);
    ddp_clev_rec.creation_date := rosetta_g_miss_date_in_map(p5_a55);
    ddp_clev_rec.last_updated_by := rosetta_g_miss_num_map(p5_a56);
    ddp_clev_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a57);
    ddp_clev_rec.price_type := p5_a58;
    ddp_clev_rec.currency_code := p5_a59;
    ddp_clev_rec.currency_code_renewed := p5_a60;
    ddp_clev_rec.last_update_login := rosetta_g_miss_num_map(p5_a61);
    ddp_clev_rec.old_sts_code := p5_a62;
    ddp_clev_rec.new_sts_code := p5_a63;
    ddp_clev_rec.old_ste_code := p5_a64;
    ddp_clev_rec.new_ste_code := p5_a65;
    ddp_clev_rec.call_action_asmblr := p5_a66;
    ddp_clev_rec.request_id := rosetta_g_miss_num_map(p5_a67);
    ddp_clev_rec.program_application_id := rosetta_g_miss_num_map(p5_a68);
    ddp_clev_rec.program_id := rosetta_g_miss_num_map(p5_a69);
    ddp_clev_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a70);
    ddp_clev_rec.price_list_id := rosetta_g_miss_num_map(p5_a71);
    ddp_clev_rec.pricing_date := rosetta_g_miss_date_in_map(p5_a72);
    ddp_clev_rec.price_list_line_id := rosetta_g_miss_num_map(p5_a73);
    ddp_clev_rec.line_list_price := rosetta_g_miss_num_map(p5_a74);
    ddp_clev_rec.item_to_price_yn := p5_a75;
    ddp_clev_rec.price_basis_yn := p5_a76;
    ddp_clev_rec.config_header_id := rosetta_g_miss_num_map(p5_a77);
    ddp_clev_rec.config_revision_number := rosetta_g_miss_num_map(p5_a78);
    ddp_clev_rec.config_complete_yn := p5_a79;
    ddp_clev_rec.config_valid_yn := p5_a80;
    ddp_clev_rec.config_top_model_line_id := rosetta_g_miss_num_map(p5_a81);
    ddp_clev_rec.config_item_type := p5_a82;
    ddp_clev_rec.config_item_id := rosetta_g_miss_num_map(p5_a83);
    ddp_clev_rec.cust_acct_id := rosetta_g_miss_num_map(p5_a84);
    ddp_clev_rec.bill_to_site_use_id := rosetta_g_miss_num_map(p5_a85);
    ddp_clev_rec.inv_rule_id := rosetta_g_miss_num_map(p5_a86);
    ddp_clev_rec.line_renewal_type_code := p5_a87;
    ddp_clev_rec.ship_to_site_use_id := rosetta_g_miss_num_map(p5_a88);
    ddp_clev_rec.payment_term_id := rosetta_g_miss_num_map(p5_a89);

    ddp_klev_rec.id := rosetta_g_miss_num_map(p6_a0);
    ddp_klev_rec.object_version_number := rosetta_g_miss_num_map(p6_a1);
    ddp_klev_rec.kle_id := rosetta_g_miss_num_map(p6_a2);
    ddp_klev_rec.sty_id := rosetta_g_miss_num_map(p6_a3);
    ddp_klev_rec.prc_code := p6_a4;
    ddp_klev_rec.fcg_code := p6_a5;
    ddp_klev_rec.nty_code := p6_a6;
    ddp_klev_rec.estimated_oec := rosetta_g_miss_num_map(p6_a7);
    ddp_klev_rec.lao_amount := rosetta_g_miss_num_map(p6_a8);
    ddp_klev_rec.title_date := rosetta_g_miss_date_in_map(p6_a9);
    ddp_klev_rec.fee_charge := rosetta_g_miss_num_map(p6_a10);
    ddp_klev_rec.lrs_percent := rosetta_g_miss_num_map(p6_a11);
    ddp_klev_rec.initial_direct_cost := rosetta_g_miss_num_map(p6_a12);
    ddp_klev_rec.percent_stake := rosetta_g_miss_num_map(p6_a13);
    ddp_klev_rec.percent := rosetta_g_miss_num_map(p6_a14);
    ddp_klev_rec.evergreen_percent := rosetta_g_miss_num_map(p6_a15);
    ddp_klev_rec.amount_stake := rosetta_g_miss_num_map(p6_a16);
    ddp_klev_rec.occupancy := rosetta_g_miss_num_map(p6_a17);
    ddp_klev_rec.coverage := rosetta_g_miss_num_map(p6_a18);
    ddp_klev_rec.residual_percentage := rosetta_g_miss_num_map(p6_a19);
    ddp_klev_rec.date_last_inspection := rosetta_g_miss_date_in_map(p6_a20);
    ddp_klev_rec.date_sold := rosetta_g_miss_date_in_map(p6_a21);
    ddp_klev_rec.lrv_amount := rosetta_g_miss_num_map(p6_a22);
    ddp_klev_rec.capital_reduction := rosetta_g_miss_num_map(p6_a23);
    ddp_klev_rec.date_next_inspection_due := rosetta_g_miss_date_in_map(p6_a24);
    ddp_klev_rec.date_residual_last_review := rosetta_g_miss_date_in_map(p6_a25);
    ddp_klev_rec.date_last_reamortisation := rosetta_g_miss_date_in_map(p6_a26);
    ddp_klev_rec.vendor_advance_paid := rosetta_g_miss_num_map(p6_a27);
    ddp_klev_rec.weighted_average_life := rosetta_g_miss_num_map(p6_a28);
    ddp_klev_rec.tradein_amount := rosetta_g_miss_num_map(p6_a29);
    ddp_klev_rec.bond_equivalent_yield := rosetta_g_miss_num_map(p6_a30);
    ddp_klev_rec.termination_purchase_amount := rosetta_g_miss_num_map(p6_a31);
    ddp_klev_rec.refinance_amount := rosetta_g_miss_num_map(p6_a32);
    ddp_klev_rec.year_built := rosetta_g_miss_num_map(p6_a33);
    ddp_klev_rec.delivered_date := rosetta_g_miss_date_in_map(p6_a34);
    ddp_klev_rec.credit_tenant_yn := p6_a35;
    ddp_klev_rec.date_last_cleanup := rosetta_g_miss_date_in_map(p6_a36);
    ddp_klev_rec.year_of_manufacture := p6_a37;
    ddp_klev_rec.coverage_ratio := rosetta_g_miss_num_map(p6_a38);
    ddp_klev_rec.remarketed_amount := rosetta_g_miss_num_map(p6_a39);
    ddp_klev_rec.gross_square_footage := rosetta_g_miss_num_map(p6_a40);
    ddp_klev_rec.prescribed_asset_yn := p6_a41;
    ddp_klev_rec.date_remarketed := rosetta_g_miss_date_in_map(p6_a42);
    ddp_klev_rec.net_rentable := rosetta_g_miss_num_map(p6_a43);
    ddp_klev_rec.remarket_margin := rosetta_g_miss_num_map(p6_a44);
    ddp_klev_rec.date_letter_acceptance := rosetta_g_miss_date_in_map(p6_a45);
    ddp_klev_rec.repurchased_amount := rosetta_g_miss_num_map(p6_a46);
    ddp_klev_rec.date_commitment_expiration := rosetta_g_miss_date_in_map(p6_a47);
    ddp_klev_rec.date_repurchased := rosetta_g_miss_date_in_map(p6_a48);
    ddp_klev_rec.date_appraisal := rosetta_g_miss_date_in_map(p6_a49);
    ddp_klev_rec.residual_value := rosetta_g_miss_num_map(p6_a50);
    ddp_klev_rec.appraisal_value := rosetta_g_miss_num_map(p6_a51);
    ddp_klev_rec.secured_deal_yn := p6_a52;
    ddp_klev_rec.gain_loss := rosetta_g_miss_num_map(p6_a53);
    ddp_klev_rec.floor_amount := rosetta_g_miss_num_map(p6_a54);
    ddp_klev_rec.re_lease_yn := p6_a55;
    ddp_klev_rec.previous_contract := p6_a56;
    ddp_klev_rec.tracked_residual := rosetta_g_miss_num_map(p6_a57);
    ddp_klev_rec.date_title_received := rosetta_g_miss_date_in_map(p6_a58);
    ddp_klev_rec.amount := rosetta_g_miss_num_map(p6_a59);
    ddp_klev_rec.attribute_category := p6_a60;
    ddp_klev_rec.attribute1 := p6_a61;
    ddp_klev_rec.attribute2 := p6_a62;
    ddp_klev_rec.attribute3 := p6_a63;
    ddp_klev_rec.attribute4 := p6_a64;
    ddp_klev_rec.attribute5 := p6_a65;
    ddp_klev_rec.attribute6 := p6_a66;
    ddp_klev_rec.attribute7 := p6_a67;
    ddp_klev_rec.attribute8 := p6_a68;
    ddp_klev_rec.attribute9 := p6_a69;
    ddp_klev_rec.attribute10 := p6_a70;
    ddp_klev_rec.attribute11 := p6_a71;
    ddp_klev_rec.attribute12 := p6_a72;
    ddp_klev_rec.attribute13 := p6_a73;
    ddp_klev_rec.attribute14 := p6_a74;
    ddp_klev_rec.attribute15 := p6_a75;
    ddp_klev_rec.sty_id_for := rosetta_g_miss_num_map(p6_a76);
    ddp_klev_rec.clg_id := rosetta_g_miss_num_map(p6_a77);
    ddp_klev_rec.created_by := rosetta_g_miss_num_map(p6_a78);
    ddp_klev_rec.creation_date := rosetta_g_miss_date_in_map(p6_a79);
    ddp_klev_rec.last_updated_by := rosetta_g_miss_num_map(p6_a80);
    ddp_klev_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a81);
    ddp_klev_rec.last_update_login := rosetta_g_miss_num_map(p6_a82);
    ddp_klev_rec.date_funding := rosetta_g_miss_date_in_map(p6_a83);
    ddp_klev_rec.date_funding_required := rosetta_g_miss_date_in_map(p6_a84);
    ddp_klev_rec.date_accepted := rosetta_g_miss_date_in_map(p6_a85);
    ddp_klev_rec.date_delivery_expected := rosetta_g_miss_date_in_map(p6_a86);
    ddp_klev_rec.oec := rosetta_g_miss_num_map(p6_a87);
    ddp_klev_rec.capital_amount := rosetta_g_miss_num_map(p6_a88);
    ddp_klev_rec.residual_grnty_amount := rosetta_g_miss_num_map(p6_a89);
    ddp_klev_rec.residual_code := p6_a90;
    ddp_klev_rec.rvi_premium := rosetta_g_miss_num_map(p6_a91);
    ddp_klev_rec.credit_nature := p6_a92;
    ddp_klev_rec.capitalized_interest := rosetta_g_miss_num_map(p6_a93);
    ddp_klev_rec.capital_reduction_percent := rosetta_g_miss_num_map(p6_a94);
    ddp_klev_rec.date_pay_investor_start := rosetta_g_miss_date_in_map(p6_a95);
    ddp_klev_rec.pay_investor_frequency := p6_a96;
    ddp_klev_rec.pay_investor_event := p6_a97;
    ddp_klev_rec.pay_investor_remittance_days := rosetta_g_miss_num_map(p6_a98);

    ddp_cimv_rec.id := rosetta_g_miss_num_map(p7_a0);
    ddp_cimv_rec.object_version_number := rosetta_g_miss_num_map(p7_a1);
    ddp_cimv_rec.cle_id := rosetta_g_miss_num_map(p7_a2);
    ddp_cimv_rec.chr_id := rosetta_g_miss_num_map(p7_a3);
    ddp_cimv_rec.cle_id_for := rosetta_g_miss_num_map(p7_a4);
    ddp_cimv_rec.dnz_chr_id := rosetta_g_miss_num_map(p7_a5);
    ddp_cimv_rec.object1_id1 := p7_a6;
    ddp_cimv_rec.object1_id2 := p7_a7;
    ddp_cimv_rec.jtot_object1_code := p7_a8;
    ddp_cimv_rec.uom_code := p7_a9;
    ddp_cimv_rec.exception_yn := p7_a10;
    ddp_cimv_rec.number_of_items := rosetta_g_miss_num_map(p7_a11);
    ddp_cimv_rec.upg_orig_system_ref := p7_a12;
    ddp_cimv_rec.upg_orig_system_ref_id := rosetta_g_miss_num_map(p7_a13);
    ddp_cimv_rec.priced_item_yn := p7_a14;
    ddp_cimv_rec.created_by := rosetta_g_miss_num_map(p7_a15);
    ddp_cimv_rec.creation_date := rosetta_g_miss_date_in_map(p7_a16);
    ddp_cimv_rec.last_updated_by := rosetta_g_miss_num_map(p7_a17);
    ddp_cimv_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a18);
    ddp_cimv_rec.last_update_login := rosetta_g_miss_num_map(p7_a19);

    -- here's the delegated call to the old PL/SQL routine
    okl_contract_line_item_pvt.delete_contract_line_item(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_clev_rec,
      ddp_klev_rec,
      ddp_cimv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure create_contract_line_item(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_200
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_VARCHAR2_TABLE_2000
    , p5_a14 JTF_VARCHAR2_TABLE_2000
    , p5_a15 JTF_VARCHAR2_TABLE_2000
    , p5_a16 JTF_VARCHAR2_TABLE_300
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_VARCHAR2_TABLE_100
    , p5_a24 JTF_VARCHAR2_TABLE_100
    , p5_a25 JTF_VARCHAR2_TABLE_2000
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_VARCHAR2_TABLE_200
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_VARCHAR2_TABLE_200
    , p5_a30 JTF_DATE_TABLE
    , p5_a31 JTF_DATE_TABLE
    , p5_a32 JTF_DATE_TABLE
    , p5_a33 JTF_VARCHAR2_TABLE_100
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_VARCHAR2_TABLE_100
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_VARCHAR2_TABLE_100
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_VARCHAR2_TABLE_500
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_VARCHAR2_TABLE_500
    , p5_a47 JTF_VARCHAR2_TABLE_500
    , p5_a48 JTF_VARCHAR2_TABLE_500
    , p5_a49 JTF_VARCHAR2_TABLE_500
    , p5_a50 JTF_VARCHAR2_TABLE_500
    , p5_a51 JTF_VARCHAR2_TABLE_500
    , p5_a52 JTF_VARCHAR2_TABLE_500
    , p5_a53 JTF_VARCHAR2_TABLE_500
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_DATE_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_DATE_TABLE
    , p5_a58 JTF_VARCHAR2_TABLE_100
    , p5_a59 JTF_VARCHAR2_TABLE_100
    , p5_a60 JTF_VARCHAR2_TABLE_100
    , p5_a61 JTF_NUMBER_TABLE
    , p5_a62 JTF_VARCHAR2_TABLE_100
    , p5_a63 JTF_VARCHAR2_TABLE_100
    , p5_a64 JTF_VARCHAR2_TABLE_100
    , p5_a65 JTF_VARCHAR2_TABLE_100
    , p5_a66 JTF_VARCHAR2_TABLE_100
    , p5_a67 JTF_NUMBER_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p5_a69 JTF_NUMBER_TABLE
    , p5_a70 JTF_DATE_TABLE
    , p5_a71 JTF_NUMBER_TABLE
    , p5_a72 JTF_DATE_TABLE
    , p5_a73 JTF_NUMBER_TABLE
    , p5_a74 JTF_NUMBER_TABLE
    , p5_a75 JTF_VARCHAR2_TABLE_100
    , p5_a76 JTF_VARCHAR2_TABLE_100
    , p5_a77 JTF_NUMBER_TABLE
    , p5_a78 JTF_NUMBER_TABLE
    , p5_a79 JTF_VARCHAR2_TABLE_100
    , p5_a80 JTF_VARCHAR2_TABLE_100
    , p5_a81 JTF_NUMBER_TABLE
    , p5_a82 JTF_VARCHAR2_TABLE_100
    , p5_a83 JTF_NUMBER_TABLE
    , p5_a84 JTF_NUMBER_TABLE
    , p5_a85 JTF_NUMBER_TABLE
    , p5_a86 JTF_NUMBER_TABLE
    , p5_a87 JTF_VARCHAR2_TABLE_100
    , p5_a88 JTF_NUMBER_TABLE
    , p5_a89 JTF_NUMBER_TABLE
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_VARCHAR2_TABLE_100
    , p6_a5 JTF_VARCHAR2_TABLE_100
    , p6_a6 JTF_VARCHAR2_TABLE_100
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_NUMBER_TABLE
    , p6_a9 JTF_DATE_TABLE
    , p6_a10 JTF_NUMBER_TABLE
    , p6_a11 JTF_NUMBER_TABLE
    , p6_a12 JTF_NUMBER_TABLE
    , p6_a13 JTF_NUMBER_TABLE
    , p6_a14 JTF_NUMBER_TABLE
    , p6_a15 JTF_NUMBER_TABLE
    , p6_a16 JTF_NUMBER_TABLE
    , p6_a17 JTF_NUMBER_TABLE
    , p6_a18 JTF_NUMBER_TABLE
    , p6_a19 JTF_NUMBER_TABLE
    , p6_a20 JTF_DATE_TABLE
    , p6_a21 JTF_DATE_TABLE
    , p6_a22 JTF_NUMBER_TABLE
    , p6_a23 JTF_NUMBER_TABLE
    , p6_a24 JTF_DATE_TABLE
    , p6_a25 JTF_DATE_TABLE
    , p6_a26 JTF_DATE_TABLE
    , p6_a27 JTF_NUMBER_TABLE
    , p6_a28 JTF_NUMBER_TABLE
    , p6_a29 JTF_NUMBER_TABLE
    , p6_a30 JTF_NUMBER_TABLE
    , p6_a31 JTF_NUMBER_TABLE
    , p6_a32 JTF_NUMBER_TABLE
    , p6_a33 JTF_NUMBER_TABLE
    , p6_a34 JTF_DATE_TABLE
    , p6_a35 JTF_VARCHAR2_TABLE_100
    , p6_a36 JTF_DATE_TABLE
    , p6_a37 JTF_VARCHAR2_TABLE_300
    , p6_a38 JTF_NUMBER_TABLE
    , p6_a39 JTF_NUMBER_TABLE
    , p6_a40 JTF_NUMBER_TABLE
    , p6_a41 JTF_VARCHAR2_TABLE_100
    , p6_a42 JTF_DATE_TABLE
    , p6_a43 JTF_NUMBER_TABLE
    , p6_a44 JTF_NUMBER_TABLE
    , p6_a45 JTF_DATE_TABLE
    , p6_a46 JTF_NUMBER_TABLE
    , p6_a47 JTF_DATE_TABLE
    , p6_a48 JTF_DATE_TABLE
    , p6_a49 JTF_DATE_TABLE
    , p6_a50 JTF_NUMBER_TABLE
    , p6_a51 JTF_NUMBER_TABLE
    , p6_a52 JTF_VARCHAR2_TABLE_100
    , p6_a53 JTF_NUMBER_TABLE
    , p6_a54 JTF_NUMBER_TABLE
    , p6_a55 JTF_VARCHAR2_TABLE_100
    , p6_a56 JTF_VARCHAR2_TABLE_100
    , p6_a57 JTF_NUMBER_TABLE
    , p6_a58 JTF_DATE_TABLE
    , p6_a59 JTF_NUMBER_TABLE
    , p6_a60 JTF_VARCHAR2_TABLE_100
    , p6_a61 JTF_VARCHAR2_TABLE_500
    , p6_a62 JTF_VARCHAR2_TABLE_500
    , p6_a63 JTF_VARCHAR2_TABLE_500
    , p6_a64 JTF_VARCHAR2_TABLE_500
    , p6_a65 JTF_VARCHAR2_TABLE_500
    , p6_a66 JTF_VARCHAR2_TABLE_500
    , p6_a67 JTF_VARCHAR2_TABLE_500
    , p6_a68 JTF_VARCHAR2_TABLE_500
    , p6_a69 JTF_VARCHAR2_TABLE_500
    , p6_a70 JTF_VARCHAR2_TABLE_500
    , p6_a71 JTF_VARCHAR2_TABLE_500
    , p6_a72 JTF_VARCHAR2_TABLE_500
    , p6_a73 JTF_VARCHAR2_TABLE_500
    , p6_a74 JTF_VARCHAR2_TABLE_500
    , p6_a75 JTF_VARCHAR2_TABLE_500
    , p6_a76 JTF_NUMBER_TABLE
    , p6_a77 JTF_NUMBER_TABLE
    , p6_a78 JTF_NUMBER_TABLE
    , p6_a79 JTF_DATE_TABLE
    , p6_a80 JTF_NUMBER_TABLE
    , p6_a81 JTF_DATE_TABLE
    , p6_a82 JTF_NUMBER_TABLE
    , p6_a83 JTF_DATE_TABLE
    , p6_a84 JTF_DATE_TABLE
    , p6_a85 JTF_DATE_TABLE
    , p6_a86 JTF_DATE_TABLE
    , p6_a87 JTF_NUMBER_TABLE
    , p6_a88 JTF_NUMBER_TABLE
    , p6_a89 JTF_NUMBER_TABLE
    , p6_a90 JTF_VARCHAR2_TABLE_100
    , p6_a91 JTF_NUMBER_TABLE
    , p6_a92 JTF_VARCHAR2_TABLE_100
    , p6_a93 JTF_NUMBER_TABLE
    , p6_a94 JTF_NUMBER_TABLE
    , p6_a95 JTF_DATE_TABLE
    , p6_a96 JTF_VARCHAR2_TABLE_100
    , p6_a97 JTF_VARCHAR2_TABLE_100
    , p6_a98 JTF_NUMBER_TABLE
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_VARCHAR2_TABLE_100
    , p7_a7 JTF_VARCHAR2_TABLE_200
    , p7_a8 JTF_VARCHAR2_TABLE_100
    , p7_a9 JTF_VARCHAR2_TABLE_100
    , p7_a10 JTF_VARCHAR2_TABLE_100
    , p7_a11 JTF_NUMBER_TABLE
    , p7_a12 JTF_VARCHAR2_TABLE_100
    , p7_a13 JTF_NUMBER_TABLE
    , p7_a14 JTF_VARCHAR2_TABLE_100
    , p7_a15 JTF_NUMBER_TABLE
    , p7_a16 JTF_DATE_TABLE
    , p7_a17 JTF_NUMBER_TABLE
    , p7_a18 JTF_DATE_TABLE
    , p7_a19 JTF_NUMBER_TABLE
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_NUMBER_TABLE
    , p8_a5 out nocopy JTF_NUMBER_TABLE
    , p8_a6 out nocopy JTF_NUMBER_TABLE
    , p8_a7 out nocopy JTF_NUMBER_TABLE
    , p8_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a10 out nocopy JTF_NUMBER_TABLE
    , p8_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a12 out nocopy JTF_NUMBER_TABLE
    , p8_a13 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a14 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a15 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a16 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a18 out nocopy JTF_NUMBER_TABLE
    , p8_a19 out nocopy JTF_NUMBER_TABLE
    , p8_a20 out nocopy JTF_NUMBER_TABLE
    , p8_a21 out nocopy JTF_NUMBER_TABLE
    , p8_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a25 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a28 out nocopy JTF_DATE_TABLE
    , p8_a29 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a30 out nocopy JTF_DATE_TABLE
    , p8_a31 out nocopy JTF_DATE_TABLE
    , p8_a32 out nocopy JTF_DATE_TABLE
    , p8_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a34 out nocopy JTF_NUMBER_TABLE
    , p8_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a36 out nocopy JTF_NUMBER_TABLE
    , p8_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a39 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a43 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a44 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a45 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a46 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a47 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a48 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a49 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a50 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a51 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a52 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a53 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a54 out nocopy JTF_NUMBER_TABLE
    , p8_a55 out nocopy JTF_DATE_TABLE
    , p8_a56 out nocopy JTF_NUMBER_TABLE
    , p8_a57 out nocopy JTF_DATE_TABLE
    , p8_a58 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a59 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a61 out nocopy JTF_NUMBER_TABLE
    , p8_a62 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a63 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a64 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a65 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a66 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a67 out nocopy JTF_NUMBER_TABLE
    , p8_a68 out nocopy JTF_NUMBER_TABLE
    , p8_a69 out nocopy JTF_NUMBER_TABLE
    , p8_a70 out nocopy JTF_DATE_TABLE
    , p8_a71 out nocopy JTF_NUMBER_TABLE
    , p8_a72 out nocopy JTF_DATE_TABLE
    , p8_a73 out nocopy JTF_NUMBER_TABLE
    , p8_a74 out nocopy JTF_NUMBER_TABLE
    , p8_a75 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a76 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a77 out nocopy JTF_NUMBER_TABLE
    , p8_a78 out nocopy JTF_NUMBER_TABLE
    , p8_a79 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a80 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a81 out nocopy JTF_NUMBER_TABLE
    , p8_a82 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a83 out nocopy JTF_NUMBER_TABLE
    , p8_a84 out nocopy JTF_NUMBER_TABLE
    , p8_a85 out nocopy JTF_NUMBER_TABLE
    , p8_a86 out nocopy JTF_NUMBER_TABLE
    , p8_a87 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a88 out nocopy JTF_NUMBER_TABLE
    , p8_a89 out nocopy JTF_NUMBER_TABLE
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_NUMBER_TABLE
    , p9_a2 out nocopy JTF_NUMBER_TABLE
    , p9_a3 out nocopy JTF_NUMBER_TABLE
    , p9_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a7 out nocopy JTF_NUMBER_TABLE
    , p9_a8 out nocopy JTF_NUMBER_TABLE
    , p9_a9 out nocopy JTF_DATE_TABLE
    , p9_a10 out nocopy JTF_NUMBER_TABLE
    , p9_a11 out nocopy JTF_NUMBER_TABLE
    , p9_a12 out nocopy JTF_NUMBER_TABLE
    , p9_a13 out nocopy JTF_NUMBER_TABLE
    , p9_a14 out nocopy JTF_NUMBER_TABLE
    , p9_a15 out nocopy JTF_NUMBER_TABLE
    , p9_a16 out nocopy JTF_NUMBER_TABLE
    , p9_a17 out nocopy JTF_NUMBER_TABLE
    , p9_a18 out nocopy JTF_NUMBER_TABLE
    , p9_a19 out nocopy JTF_NUMBER_TABLE
    , p9_a20 out nocopy JTF_DATE_TABLE
    , p9_a21 out nocopy JTF_DATE_TABLE
    , p9_a22 out nocopy JTF_NUMBER_TABLE
    , p9_a23 out nocopy JTF_NUMBER_TABLE
    , p9_a24 out nocopy JTF_DATE_TABLE
    , p9_a25 out nocopy JTF_DATE_TABLE
    , p9_a26 out nocopy JTF_DATE_TABLE
    , p9_a27 out nocopy JTF_NUMBER_TABLE
    , p9_a28 out nocopy JTF_NUMBER_TABLE
    , p9_a29 out nocopy JTF_NUMBER_TABLE
    , p9_a30 out nocopy JTF_NUMBER_TABLE
    , p9_a31 out nocopy JTF_NUMBER_TABLE
    , p9_a32 out nocopy JTF_NUMBER_TABLE
    , p9_a33 out nocopy JTF_NUMBER_TABLE
    , p9_a34 out nocopy JTF_DATE_TABLE
    , p9_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a36 out nocopy JTF_DATE_TABLE
    , p9_a37 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a38 out nocopy JTF_NUMBER_TABLE
    , p9_a39 out nocopy JTF_NUMBER_TABLE
    , p9_a40 out nocopy JTF_NUMBER_TABLE
    , p9_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a42 out nocopy JTF_DATE_TABLE
    , p9_a43 out nocopy JTF_NUMBER_TABLE
    , p9_a44 out nocopy JTF_NUMBER_TABLE
    , p9_a45 out nocopy JTF_DATE_TABLE
    , p9_a46 out nocopy JTF_NUMBER_TABLE
    , p9_a47 out nocopy JTF_DATE_TABLE
    , p9_a48 out nocopy JTF_DATE_TABLE
    , p9_a49 out nocopy JTF_DATE_TABLE
    , p9_a50 out nocopy JTF_NUMBER_TABLE
    , p9_a51 out nocopy JTF_NUMBER_TABLE
    , p9_a52 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a53 out nocopy JTF_NUMBER_TABLE
    , p9_a54 out nocopy JTF_NUMBER_TABLE
    , p9_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a57 out nocopy JTF_NUMBER_TABLE
    , p9_a58 out nocopy JTF_DATE_TABLE
    , p9_a59 out nocopy JTF_NUMBER_TABLE
    , p9_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a61 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a62 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a63 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a64 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a65 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a66 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a67 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a68 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a69 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a70 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a71 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a72 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a73 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a74 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a75 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a76 out nocopy JTF_NUMBER_TABLE
    , p9_a77 out nocopy JTF_NUMBER_TABLE
    , p9_a78 out nocopy JTF_NUMBER_TABLE
    , p9_a79 out nocopy JTF_DATE_TABLE
    , p9_a80 out nocopy JTF_NUMBER_TABLE
    , p9_a81 out nocopy JTF_DATE_TABLE
    , p9_a82 out nocopy JTF_NUMBER_TABLE
    , p9_a83 out nocopy JTF_DATE_TABLE
    , p9_a84 out nocopy JTF_DATE_TABLE
    , p9_a85 out nocopy JTF_DATE_TABLE
    , p9_a86 out nocopy JTF_DATE_TABLE
    , p9_a87 out nocopy JTF_NUMBER_TABLE
    , p9_a88 out nocopy JTF_NUMBER_TABLE
    , p9_a89 out nocopy JTF_NUMBER_TABLE
    , p9_a90 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a91 out nocopy JTF_NUMBER_TABLE
    , p9_a92 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a93 out nocopy JTF_NUMBER_TABLE
    , p9_a94 out nocopy JTF_NUMBER_TABLE
    , p9_a95 out nocopy JTF_DATE_TABLE
    , p9_a96 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a97 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a98 out nocopy JTF_NUMBER_TABLE
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_NUMBER_TABLE
    , p10_a3 out nocopy JTF_NUMBER_TABLE
    , p10_a4 out nocopy JTF_NUMBER_TABLE
    , p10_a5 out nocopy JTF_NUMBER_TABLE
    , p10_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a11 out nocopy JTF_NUMBER_TABLE
    , p10_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a13 out nocopy JTF_NUMBER_TABLE
    , p10_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a15 out nocopy JTF_NUMBER_TABLE
    , p10_a16 out nocopy JTF_DATE_TABLE
    , p10_a17 out nocopy JTF_NUMBER_TABLE
    , p10_a18 out nocopy JTF_DATE_TABLE
    , p10_a19 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_clev_tbl okl_contract_line_item_pvt.clev_tbl_type;
    ddp_klev_tbl okl_contract_line_item_pvt.klev_tbl_type;
    ddp_cimv_tbl okl_contract_line_item_pvt.cimv_tbl_type;
    ddx_clev_tbl okl_contract_line_item_pvt.clev_tbl_type;
    ddx_klev_tbl okl_contract_line_item_pvt.klev_tbl_type;
    ddx_cimv_tbl okl_contract_line_item_pvt.cimv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_okc_migration_pvt_w.rosetta_table_copy_in_p5(ddp_clev_tbl, p5_a0
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
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      , p5_a58
      , p5_a59
      , p5_a60
      , p5_a61
      , p5_a62
      , p5_a63
      , p5_a64
      , p5_a65
      , p5_a66
      , p5_a67
      , p5_a68
      , p5_a69
      , p5_a70
      , p5_a71
      , p5_a72
      , p5_a73
      , p5_a74
      , p5_a75
      , p5_a76
      , p5_a77
      , p5_a78
      , p5_a79
      , p5_a80
      , p5_a81
      , p5_a82
      , p5_a83
      , p5_a84
      , p5_a85
      , p5_a86
      , p5_a87
      , p5_a88
      , p5_a89
      );

    okl_kle_pvt_w.rosetta_table_copy_in_p8(ddp_klev_tbl, p6_a0
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
      , p6_a36
      , p6_a37
      , p6_a38
      , p6_a39
      , p6_a40
      , p6_a41
      , p6_a42
      , p6_a43
      , p6_a44
      , p6_a45
      , p6_a46
      , p6_a47
      , p6_a48
      , p6_a49
      , p6_a50
      , p6_a51
      , p6_a52
      , p6_a53
      , p6_a54
      , p6_a55
      , p6_a56
      , p6_a57
      , p6_a58
      , p6_a59
      , p6_a60
      , p6_a61
      , p6_a62
      , p6_a63
      , p6_a64
      , p6_a65
      , p6_a66
      , p6_a67
      , p6_a68
      , p6_a69
      , p6_a70
      , p6_a71
      , p6_a72
      , p6_a73
      , p6_a74
      , p6_a75
      , p6_a76
      , p6_a77
      , p6_a78
      , p6_a79
      , p6_a80
      , p6_a81
      , p6_a82
      , p6_a83
      , p6_a84
      , p6_a85
      , p6_a86
      , p6_a87
      , p6_a88
      , p6_a89
      , p6_a90
      , p6_a91
      , p6_a92
      , p6_a93
      , p6_a94
      , p6_a95
      , p6_a96
      , p6_a97
      , p6_a98
      );

    okl_okc_migration_pvt_w.rosetta_table_copy_in_p7(ddp_cimv_tbl, p7_a0
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
      );




    -- here's the delegated call to the old PL/SQL routine
    okl_contract_line_item_pvt.create_contract_line_item(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_clev_tbl,
      ddp_klev_tbl,
      ddp_cimv_tbl,
      ddx_clev_tbl,
      ddx_klev_tbl,
      ddx_cimv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    okl_okc_migration_pvt_w.rosetta_table_copy_out_p5(ddx_clev_tbl, p8_a0
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
      , p8_a31
      , p8_a32
      , p8_a33
      , p8_a34
      , p8_a35
      , p8_a36
      , p8_a37
      , p8_a38
      , p8_a39
      , p8_a40
      , p8_a41
      , p8_a42
      , p8_a43
      , p8_a44
      , p8_a45
      , p8_a46
      , p8_a47
      , p8_a48
      , p8_a49
      , p8_a50
      , p8_a51
      , p8_a52
      , p8_a53
      , p8_a54
      , p8_a55
      , p8_a56
      , p8_a57
      , p8_a58
      , p8_a59
      , p8_a60
      , p8_a61
      , p8_a62
      , p8_a63
      , p8_a64
      , p8_a65
      , p8_a66
      , p8_a67
      , p8_a68
      , p8_a69
      , p8_a70
      , p8_a71
      , p8_a72
      , p8_a73
      , p8_a74
      , p8_a75
      , p8_a76
      , p8_a77
      , p8_a78
      , p8_a79
      , p8_a80
      , p8_a81
      , p8_a82
      , p8_a83
      , p8_a84
      , p8_a85
      , p8_a86
      , p8_a87
      , p8_a88
      , p8_a89
      );

    okl_kle_pvt_w.rosetta_table_copy_out_p8(ddx_klev_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      , p9_a7
      , p9_a8
      , p9_a9
      , p9_a10
      , p9_a11
      , p9_a12
      , p9_a13
      , p9_a14
      , p9_a15
      , p9_a16
      , p9_a17
      , p9_a18
      , p9_a19
      , p9_a20
      , p9_a21
      , p9_a22
      , p9_a23
      , p9_a24
      , p9_a25
      , p9_a26
      , p9_a27
      , p9_a28
      , p9_a29
      , p9_a30
      , p9_a31
      , p9_a32
      , p9_a33
      , p9_a34
      , p9_a35
      , p9_a36
      , p9_a37
      , p9_a38
      , p9_a39
      , p9_a40
      , p9_a41
      , p9_a42
      , p9_a43
      , p9_a44
      , p9_a45
      , p9_a46
      , p9_a47
      , p9_a48
      , p9_a49
      , p9_a50
      , p9_a51
      , p9_a52
      , p9_a53
      , p9_a54
      , p9_a55
      , p9_a56
      , p9_a57
      , p9_a58
      , p9_a59
      , p9_a60
      , p9_a61
      , p9_a62
      , p9_a63
      , p9_a64
      , p9_a65
      , p9_a66
      , p9_a67
      , p9_a68
      , p9_a69
      , p9_a70
      , p9_a71
      , p9_a72
      , p9_a73
      , p9_a74
      , p9_a75
      , p9_a76
      , p9_a77
      , p9_a78
      , p9_a79
      , p9_a80
      , p9_a81
      , p9_a82
      , p9_a83
      , p9_a84
      , p9_a85
      , p9_a86
      , p9_a87
      , p9_a88
      , p9_a89
      , p9_a90
      , p9_a91
      , p9_a92
      , p9_a93
      , p9_a94
      , p9_a95
      , p9_a96
      , p9_a97
      , p9_a98
      );

    okl_okc_migration_pvt_w.rosetta_table_copy_out_p7(ddx_cimv_tbl, p10_a0
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
      );
  end;

  procedure update_contract_line_item(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_200
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_VARCHAR2_TABLE_2000
    , p5_a14 JTF_VARCHAR2_TABLE_2000
    , p5_a15 JTF_VARCHAR2_TABLE_2000
    , p5_a16 JTF_VARCHAR2_TABLE_300
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_VARCHAR2_TABLE_100
    , p5_a24 JTF_VARCHAR2_TABLE_100
    , p5_a25 JTF_VARCHAR2_TABLE_2000
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_VARCHAR2_TABLE_200
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_VARCHAR2_TABLE_200
    , p5_a30 JTF_DATE_TABLE
    , p5_a31 JTF_DATE_TABLE
    , p5_a32 JTF_DATE_TABLE
    , p5_a33 JTF_VARCHAR2_TABLE_100
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_VARCHAR2_TABLE_100
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_VARCHAR2_TABLE_100
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_VARCHAR2_TABLE_500
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_VARCHAR2_TABLE_500
    , p5_a47 JTF_VARCHAR2_TABLE_500
    , p5_a48 JTF_VARCHAR2_TABLE_500
    , p5_a49 JTF_VARCHAR2_TABLE_500
    , p5_a50 JTF_VARCHAR2_TABLE_500
    , p5_a51 JTF_VARCHAR2_TABLE_500
    , p5_a52 JTF_VARCHAR2_TABLE_500
    , p5_a53 JTF_VARCHAR2_TABLE_500
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_DATE_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_DATE_TABLE
    , p5_a58 JTF_VARCHAR2_TABLE_100
    , p5_a59 JTF_VARCHAR2_TABLE_100
    , p5_a60 JTF_VARCHAR2_TABLE_100
    , p5_a61 JTF_NUMBER_TABLE
    , p5_a62 JTF_VARCHAR2_TABLE_100
    , p5_a63 JTF_VARCHAR2_TABLE_100
    , p5_a64 JTF_VARCHAR2_TABLE_100
    , p5_a65 JTF_VARCHAR2_TABLE_100
    , p5_a66 JTF_VARCHAR2_TABLE_100
    , p5_a67 JTF_NUMBER_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p5_a69 JTF_NUMBER_TABLE
    , p5_a70 JTF_DATE_TABLE
    , p5_a71 JTF_NUMBER_TABLE
    , p5_a72 JTF_DATE_TABLE
    , p5_a73 JTF_NUMBER_TABLE
    , p5_a74 JTF_NUMBER_TABLE
    , p5_a75 JTF_VARCHAR2_TABLE_100
    , p5_a76 JTF_VARCHAR2_TABLE_100
    , p5_a77 JTF_NUMBER_TABLE
    , p5_a78 JTF_NUMBER_TABLE
    , p5_a79 JTF_VARCHAR2_TABLE_100
    , p5_a80 JTF_VARCHAR2_TABLE_100
    , p5_a81 JTF_NUMBER_TABLE
    , p5_a82 JTF_VARCHAR2_TABLE_100
    , p5_a83 JTF_NUMBER_TABLE
    , p5_a84 JTF_NUMBER_TABLE
    , p5_a85 JTF_NUMBER_TABLE
    , p5_a86 JTF_NUMBER_TABLE
    , p5_a87 JTF_VARCHAR2_TABLE_100
    , p5_a88 JTF_NUMBER_TABLE
    , p5_a89 JTF_NUMBER_TABLE
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_VARCHAR2_TABLE_100
    , p6_a5 JTF_VARCHAR2_TABLE_100
    , p6_a6 JTF_VARCHAR2_TABLE_100
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_NUMBER_TABLE
    , p6_a9 JTF_DATE_TABLE
    , p6_a10 JTF_NUMBER_TABLE
    , p6_a11 JTF_NUMBER_TABLE
    , p6_a12 JTF_NUMBER_TABLE
    , p6_a13 JTF_NUMBER_TABLE
    , p6_a14 JTF_NUMBER_TABLE
    , p6_a15 JTF_NUMBER_TABLE
    , p6_a16 JTF_NUMBER_TABLE
    , p6_a17 JTF_NUMBER_TABLE
    , p6_a18 JTF_NUMBER_TABLE
    , p6_a19 JTF_NUMBER_TABLE
    , p6_a20 JTF_DATE_TABLE
    , p6_a21 JTF_DATE_TABLE
    , p6_a22 JTF_NUMBER_TABLE
    , p6_a23 JTF_NUMBER_TABLE
    , p6_a24 JTF_DATE_TABLE
    , p6_a25 JTF_DATE_TABLE
    , p6_a26 JTF_DATE_TABLE
    , p6_a27 JTF_NUMBER_TABLE
    , p6_a28 JTF_NUMBER_TABLE
    , p6_a29 JTF_NUMBER_TABLE
    , p6_a30 JTF_NUMBER_TABLE
    , p6_a31 JTF_NUMBER_TABLE
    , p6_a32 JTF_NUMBER_TABLE
    , p6_a33 JTF_NUMBER_TABLE
    , p6_a34 JTF_DATE_TABLE
    , p6_a35 JTF_VARCHAR2_TABLE_100
    , p6_a36 JTF_DATE_TABLE
    , p6_a37 JTF_VARCHAR2_TABLE_300
    , p6_a38 JTF_NUMBER_TABLE
    , p6_a39 JTF_NUMBER_TABLE
    , p6_a40 JTF_NUMBER_TABLE
    , p6_a41 JTF_VARCHAR2_TABLE_100
    , p6_a42 JTF_DATE_TABLE
    , p6_a43 JTF_NUMBER_TABLE
    , p6_a44 JTF_NUMBER_TABLE
    , p6_a45 JTF_DATE_TABLE
    , p6_a46 JTF_NUMBER_TABLE
    , p6_a47 JTF_DATE_TABLE
    , p6_a48 JTF_DATE_TABLE
    , p6_a49 JTF_DATE_TABLE
    , p6_a50 JTF_NUMBER_TABLE
    , p6_a51 JTF_NUMBER_TABLE
    , p6_a52 JTF_VARCHAR2_TABLE_100
    , p6_a53 JTF_NUMBER_TABLE
    , p6_a54 JTF_NUMBER_TABLE
    , p6_a55 JTF_VARCHAR2_TABLE_100
    , p6_a56 JTF_VARCHAR2_TABLE_100
    , p6_a57 JTF_NUMBER_TABLE
    , p6_a58 JTF_DATE_TABLE
    , p6_a59 JTF_NUMBER_TABLE
    , p6_a60 JTF_VARCHAR2_TABLE_100
    , p6_a61 JTF_VARCHAR2_TABLE_500
    , p6_a62 JTF_VARCHAR2_TABLE_500
    , p6_a63 JTF_VARCHAR2_TABLE_500
    , p6_a64 JTF_VARCHAR2_TABLE_500
    , p6_a65 JTF_VARCHAR2_TABLE_500
    , p6_a66 JTF_VARCHAR2_TABLE_500
    , p6_a67 JTF_VARCHAR2_TABLE_500
    , p6_a68 JTF_VARCHAR2_TABLE_500
    , p6_a69 JTF_VARCHAR2_TABLE_500
    , p6_a70 JTF_VARCHAR2_TABLE_500
    , p6_a71 JTF_VARCHAR2_TABLE_500
    , p6_a72 JTF_VARCHAR2_TABLE_500
    , p6_a73 JTF_VARCHAR2_TABLE_500
    , p6_a74 JTF_VARCHAR2_TABLE_500
    , p6_a75 JTF_VARCHAR2_TABLE_500
    , p6_a76 JTF_NUMBER_TABLE
    , p6_a77 JTF_NUMBER_TABLE
    , p6_a78 JTF_NUMBER_TABLE
    , p6_a79 JTF_DATE_TABLE
    , p6_a80 JTF_NUMBER_TABLE
    , p6_a81 JTF_DATE_TABLE
    , p6_a82 JTF_NUMBER_TABLE
    , p6_a83 JTF_DATE_TABLE
    , p6_a84 JTF_DATE_TABLE
    , p6_a85 JTF_DATE_TABLE
    , p6_a86 JTF_DATE_TABLE
    , p6_a87 JTF_NUMBER_TABLE
    , p6_a88 JTF_NUMBER_TABLE
    , p6_a89 JTF_NUMBER_TABLE
    , p6_a90 JTF_VARCHAR2_TABLE_100
    , p6_a91 JTF_NUMBER_TABLE
    , p6_a92 JTF_VARCHAR2_TABLE_100
    , p6_a93 JTF_NUMBER_TABLE
    , p6_a94 JTF_NUMBER_TABLE
    , p6_a95 JTF_DATE_TABLE
    , p6_a96 JTF_VARCHAR2_TABLE_100
    , p6_a97 JTF_VARCHAR2_TABLE_100
    , p6_a98 JTF_NUMBER_TABLE
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_VARCHAR2_TABLE_100
    , p7_a7 JTF_VARCHAR2_TABLE_200
    , p7_a8 JTF_VARCHAR2_TABLE_100
    , p7_a9 JTF_VARCHAR2_TABLE_100
    , p7_a10 JTF_VARCHAR2_TABLE_100
    , p7_a11 JTF_NUMBER_TABLE
    , p7_a12 JTF_VARCHAR2_TABLE_100
    , p7_a13 JTF_NUMBER_TABLE
    , p7_a14 JTF_VARCHAR2_TABLE_100
    , p7_a15 JTF_NUMBER_TABLE
    , p7_a16 JTF_DATE_TABLE
    , p7_a17 JTF_NUMBER_TABLE
    , p7_a18 JTF_DATE_TABLE
    , p7_a19 JTF_NUMBER_TABLE
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_NUMBER_TABLE
    , p8_a5 out nocopy JTF_NUMBER_TABLE
    , p8_a6 out nocopy JTF_NUMBER_TABLE
    , p8_a7 out nocopy JTF_NUMBER_TABLE
    , p8_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a10 out nocopy JTF_NUMBER_TABLE
    , p8_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a12 out nocopy JTF_NUMBER_TABLE
    , p8_a13 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a14 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a15 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a16 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a18 out nocopy JTF_NUMBER_TABLE
    , p8_a19 out nocopy JTF_NUMBER_TABLE
    , p8_a20 out nocopy JTF_NUMBER_TABLE
    , p8_a21 out nocopy JTF_NUMBER_TABLE
    , p8_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a25 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a28 out nocopy JTF_DATE_TABLE
    , p8_a29 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a30 out nocopy JTF_DATE_TABLE
    , p8_a31 out nocopy JTF_DATE_TABLE
    , p8_a32 out nocopy JTF_DATE_TABLE
    , p8_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a34 out nocopy JTF_NUMBER_TABLE
    , p8_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a36 out nocopy JTF_NUMBER_TABLE
    , p8_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a39 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a43 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a44 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a45 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a46 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a47 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a48 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a49 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a50 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a51 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a52 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a53 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a54 out nocopy JTF_NUMBER_TABLE
    , p8_a55 out nocopy JTF_DATE_TABLE
    , p8_a56 out nocopy JTF_NUMBER_TABLE
    , p8_a57 out nocopy JTF_DATE_TABLE
    , p8_a58 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a59 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a61 out nocopy JTF_NUMBER_TABLE
    , p8_a62 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a63 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a64 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a65 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a66 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a67 out nocopy JTF_NUMBER_TABLE
    , p8_a68 out nocopy JTF_NUMBER_TABLE
    , p8_a69 out nocopy JTF_NUMBER_TABLE
    , p8_a70 out nocopy JTF_DATE_TABLE
    , p8_a71 out nocopy JTF_NUMBER_TABLE
    , p8_a72 out nocopy JTF_DATE_TABLE
    , p8_a73 out nocopy JTF_NUMBER_TABLE
    , p8_a74 out nocopy JTF_NUMBER_TABLE
    , p8_a75 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a76 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a77 out nocopy JTF_NUMBER_TABLE
    , p8_a78 out nocopy JTF_NUMBER_TABLE
    , p8_a79 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a80 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a81 out nocopy JTF_NUMBER_TABLE
    , p8_a82 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a83 out nocopy JTF_NUMBER_TABLE
    , p8_a84 out nocopy JTF_NUMBER_TABLE
    , p8_a85 out nocopy JTF_NUMBER_TABLE
    , p8_a86 out nocopy JTF_NUMBER_TABLE
    , p8_a87 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a88 out nocopy JTF_NUMBER_TABLE
    , p8_a89 out nocopy JTF_NUMBER_TABLE
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_NUMBER_TABLE
    , p9_a2 out nocopy JTF_NUMBER_TABLE
    , p9_a3 out nocopy JTF_NUMBER_TABLE
    , p9_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a7 out nocopy JTF_NUMBER_TABLE
    , p9_a8 out nocopy JTF_NUMBER_TABLE
    , p9_a9 out nocopy JTF_DATE_TABLE
    , p9_a10 out nocopy JTF_NUMBER_TABLE
    , p9_a11 out nocopy JTF_NUMBER_TABLE
    , p9_a12 out nocopy JTF_NUMBER_TABLE
    , p9_a13 out nocopy JTF_NUMBER_TABLE
    , p9_a14 out nocopy JTF_NUMBER_TABLE
    , p9_a15 out nocopy JTF_NUMBER_TABLE
    , p9_a16 out nocopy JTF_NUMBER_TABLE
    , p9_a17 out nocopy JTF_NUMBER_TABLE
    , p9_a18 out nocopy JTF_NUMBER_TABLE
    , p9_a19 out nocopy JTF_NUMBER_TABLE
    , p9_a20 out nocopy JTF_DATE_TABLE
    , p9_a21 out nocopy JTF_DATE_TABLE
    , p9_a22 out nocopy JTF_NUMBER_TABLE
    , p9_a23 out nocopy JTF_NUMBER_TABLE
    , p9_a24 out nocopy JTF_DATE_TABLE
    , p9_a25 out nocopy JTF_DATE_TABLE
    , p9_a26 out nocopy JTF_DATE_TABLE
    , p9_a27 out nocopy JTF_NUMBER_TABLE
    , p9_a28 out nocopy JTF_NUMBER_TABLE
    , p9_a29 out nocopy JTF_NUMBER_TABLE
    , p9_a30 out nocopy JTF_NUMBER_TABLE
    , p9_a31 out nocopy JTF_NUMBER_TABLE
    , p9_a32 out nocopy JTF_NUMBER_TABLE
    , p9_a33 out nocopy JTF_NUMBER_TABLE
    , p9_a34 out nocopy JTF_DATE_TABLE
    , p9_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a36 out nocopy JTF_DATE_TABLE
    , p9_a37 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a38 out nocopy JTF_NUMBER_TABLE
    , p9_a39 out nocopy JTF_NUMBER_TABLE
    , p9_a40 out nocopy JTF_NUMBER_TABLE
    , p9_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a42 out nocopy JTF_DATE_TABLE
    , p9_a43 out nocopy JTF_NUMBER_TABLE
    , p9_a44 out nocopy JTF_NUMBER_TABLE
    , p9_a45 out nocopy JTF_DATE_TABLE
    , p9_a46 out nocopy JTF_NUMBER_TABLE
    , p9_a47 out nocopy JTF_DATE_TABLE
    , p9_a48 out nocopy JTF_DATE_TABLE
    , p9_a49 out nocopy JTF_DATE_TABLE
    , p9_a50 out nocopy JTF_NUMBER_TABLE
    , p9_a51 out nocopy JTF_NUMBER_TABLE
    , p9_a52 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a53 out nocopy JTF_NUMBER_TABLE
    , p9_a54 out nocopy JTF_NUMBER_TABLE
    , p9_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a57 out nocopy JTF_NUMBER_TABLE
    , p9_a58 out nocopy JTF_DATE_TABLE
    , p9_a59 out nocopy JTF_NUMBER_TABLE
    , p9_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a61 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a62 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a63 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a64 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a65 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a66 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a67 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a68 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a69 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a70 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a71 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a72 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a73 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a74 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a75 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a76 out nocopy JTF_NUMBER_TABLE
    , p9_a77 out nocopy JTF_NUMBER_TABLE
    , p9_a78 out nocopy JTF_NUMBER_TABLE
    , p9_a79 out nocopy JTF_DATE_TABLE
    , p9_a80 out nocopy JTF_NUMBER_TABLE
    , p9_a81 out nocopy JTF_DATE_TABLE
    , p9_a82 out nocopy JTF_NUMBER_TABLE
    , p9_a83 out nocopy JTF_DATE_TABLE
    , p9_a84 out nocopy JTF_DATE_TABLE
    , p9_a85 out nocopy JTF_DATE_TABLE
    , p9_a86 out nocopy JTF_DATE_TABLE
    , p9_a87 out nocopy JTF_NUMBER_TABLE
    , p9_a88 out nocopy JTF_NUMBER_TABLE
    , p9_a89 out nocopy JTF_NUMBER_TABLE
    , p9_a90 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a91 out nocopy JTF_NUMBER_TABLE
    , p9_a92 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a93 out nocopy JTF_NUMBER_TABLE
    , p9_a94 out nocopy JTF_NUMBER_TABLE
    , p9_a95 out nocopy JTF_DATE_TABLE
    , p9_a96 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a97 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a98 out nocopy JTF_NUMBER_TABLE
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_NUMBER_TABLE
    , p10_a3 out nocopy JTF_NUMBER_TABLE
    , p10_a4 out nocopy JTF_NUMBER_TABLE
    , p10_a5 out nocopy JTF_NUMBER_TABLE
    , p10_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a11 out nocopy JTF_NUMBER_TABLE
    , p10_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a13 out nocopy JTF_NUMBER_TABLE
    , p10_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a15 out nocopy JTF_NUMBER_TABLE
    , p10_a16 out nocopy JTF_DATE_TABLE
    , p10_a17 out nocopy JTF_NUMBER_TABLE
    , p10_a18 out nocopy JTF_DATE_TABLE
    , p10_a19 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_clev_tbl okl_contract_line_item_pvt.clev_tbl_type;
    ddp_klev_tbl okl_contract_line_item_pvt.klev_tbl_type;
    ddp_cimv_tbl okl_contract_line_item_pvt.cimv_tbl_type;
    ddx_clev_tbl okl_contract_line_item_pvt.clev_tbl_type;
    ddx_klev_tbl okl_contract_line_item_pvt.klev_tbl_type;
    ddx_cimv_tbl okl_contract_line_item_pvt.cimv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_okc_migration_pvt_w.rosetta_table_copy_in_p5(ddp_clev_tbl, p5_a0
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
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      , p5_a58
      , p5_a59
      , p5_a60
      , p5_a61
      , p5_a62
      , p5_a63
      , p5_a64
      , p5_a65
      , p5_a66
      , p5_a67
      , p5_a68
      , p5_a69
      , p5_a70
      , p5_a71
      , p5_a72
      , p5_a73
      , p5_a74
      , p5_a75
      , p5_a76
      , p5_a77
      , p5_a78
      , p5_a79
      , p5_a80
      , p5_a81
      , p5_a82
      , p5_a83
      , p5_a84
      , p5_a85
      , p5_a86
      , p5_a87
      , p5_a88
      , p5_a89
      );

    okl_kle_pvt_w.rosetta_table_copy_in_p8(ddp_klev_tbl, p6_a0
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
      , p6_a36
      , p6_a37
      , p6_a38
      , p6_a39
      , p6_a40
      , p6_a41
      , p6_a42
      , p6_a43
      , p6_a44
      , p6_a45
      , p6_a46
      , p6_a47
      , p6_a48
      , p6_a49
      , p6_a50
      , p6_a51
      , p6_a52
      , p6_a53
      , p6_a54
      , p6_a55
      , p6_a56
      , p6_a57
      , p6_a58
      , p6_a59
      , p6_a60
      , p6_a61
      , p6_a62
      , p6_a63
      , p6_a64
      , p6_a65
      , p6_a66
      , p6_a67
      , p6_a68
      , p6_a69
      , p6_a70
      , p6_a71
      , p6_a72
      , p6_a73
      , p6_a74
      , p6_a75
      , p6_a76
      , p6_a77
      , p6_a78
      , p6_a79
      , p6_a80
      , p6_a81
      , p6_a82
      , p6_a83
      , p6_a84
      , p6_a85
      , p6_a86
      , p6_a87
      , p6_a88
      , p6_a89
      , p6_a90
      , p6_a91
      , p6_a92
      , p6_a93
      , p6_a94
      , p6_a95
      , p6_a96
      , p6_a97
      , p6_a98
      );

    okl_okc_migration_pvt_w.rosetta_table_copy_in_p7(ddp_cimv_tbl, p7_a0
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
      );




    -- here's the delegated call to the old PL/SQL routine
    okl_contract_line_item_pvt.update_contract_line_item(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_clev_tbl,
      ddp_klev_tbl,
      ddp_cimv_tbl,
      ddx_clev_tbl,
      ddx_klev_tbl,
      ddx_cimv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    okl_okc_migration_pvt_w.rosetta_table_copy_out_p5(ddx_clev_tbl, p8_a0
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
      , p8_a31
      , p8_a32
      , p8_a33
      , p8_a34
      , p8_a35
      , p8_a36
      , p8_a37
      , p8_a38
      , p8_a39
      , p8_a40
      , p8_a41
      , p8_a42
      , p8_a43
      , p8_a44
      , p8_a45
      , p8_a46
      , p8_a47
      , p8_a48
      , p8_a49
      , p8_a50
      , p8_a51
      , p8_a52
      , p8_a53
      , p8_a54
      , p8_a55
      , p8_a56
      , p8_a57
      , p8_a58
      , p8_a59
      , p8_a60
      , p8_a61
      , p8_a62
      , p8_a63
      , p8_a64
      , p8_a65
      , p8_a66
      , p8_a67
      , p8_a68
      , p8_a69
      , p8_a70
      , p8_a71
      , p8_a72
      , p8_a73
      , p8_a74
      , p8_a75
      , p8_a76
      , p8_a77
      , p8_a78
      , p8_a79
      , p8_a80
      , p8_a81
      , p8_a82
      , p8_a83
      , p8_a84
      , p8_a85
      , p8_a86
      , p8_a87
      , p8_a88
      , p8_a89
      );

    okl_kle_pvt_w.rosetta_table_copy_out_p8(ddx_klev_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      , p9_a7
      , p9_a8
      , p9_a9
      , p9_a10
      , p9_a11
      , p9_a12
      , p9_a13
      , p9_a14
      , p9_a15
      , p9_a16
      , p9_a17
      , p9_a18
      , p9_a19
      , p9_a20
      , p9_a21
      , p9_a22
      , p9_a23
      , p9_a24
      , p9_a25
      , p9_a26
      , p9_a27
      , p9_a28
      , p9_a29
      , p9_a30
      , p9_a31
      , p9_a32
      , p9_a33
      , p9_a34
      , p9_a35
      , p9_a36
      , p9_a37
      , p9_a38
      , p9_a39
      , p9_a40
      , p9_a41
      , p9_a42
      , p9_a43
      , p9_a44
      , p9_a45
      , p9_a46
      , p9_a47
      , p9_a48
      , p9_a49
      , p9_a50
      , p9_a51
      , p9_a52
      , p9_a53
      , p9_a54
      , p9_a55
      , p9_a56
      , p9_a57
      , p9_a58
      , p9_a59
      , p9_a60
      , p9_a61
      , p9_a62
      , p9_a63
      , p9_a64
      , p9_a65
      , p9_a66
      , p9_a67
      , p9_a68
      , p9_a69
      , p9_a70
      , p9_a71
      , p9_a72
      , p9_a73
      , p9_a74
      , p9_a75
      , p9_a76
      , p9_a77
      , p9_a78
      , p9_a79
      , p9_a80
      , p9_a81
      , p9_a82
      , p9_a83
      , p9_a84
      , p9_a85
      , p9_a86
      , p9_a87
      , p9_a88
      , p9_a89
      , p9_a90
      , p9_a91
      , p9_a92
      , p9_a93
      , p9_a94
      , p9_a95
      , p9_a96
      , p9_a97
      , p9_a98
      );

    okl_okc_migration_pvt_w.rosetta_table_copy_out_p7(ddx_cimv_tbl, p10_a0
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
      );
  end;

  procedure delete_contract_line_item(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_200
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_VARCHAR2_TABLE_2000
    , p5_a14 JTF_VARCHAR2_TABLE_2000
    , p5_a15 JTF_VARCHAR2_TABLE_2000
    , p5_a16 JTF_VARCHAR2_TABLE_300
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_VARCHAR2_TABLE_100
    , p5_a24 JTF_VARCHAR2_TABLE_100
    , p5_a25 JTF_VARCHAR2_TABLE_2000
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_VARCHAR2_TABLE_200
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_VARCHAR2_TABLE_200
    , p5_a30 JTF_DATE_TABLE
    , p5_a31 JTF_DATE_TABLE
    , p5_a32 JTF_DATE_TABLE
    , p5_a33 JTF_VARCHAR2_TABLE_100
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_VARCHAR2_TABLE_100
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_VARCHAR2_TABLE_100
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_VARCHAR2_TABLE_500
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_VARCHAR2_TABLE_500
    , p5_a47 JTF_VARCHAR2_TABLE_500
    , p5_a48 JTF_VARCHAR2_TABLE_500
    , p5_a49 JTF_VARCHAR2_TABLE_500
    , p5_a50 JTF_VARCHAR2_TABLE_500
    , p5_a51 JTF_VARCHAR2_TABLE_500
    , p5_a52 JTF_VARCHAR2_TABLE_500
    , p5_a53 JTF_VARCHAR2_TABLE_500
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_DATE_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_DATE_TABLE
    , p5_a58 JTF_VARCHAR2_TABLE_100
    , p5_a59 JTF_VARCHAR2_TABLE_100
    , p5_a60 JTF_VARCHAR2_TABLE_100
    , p5_a61 JTF_NUMBER_TABLE
    , p5_a62 JTF_VARCHAR2_TABLE_100
    , p5_a63 JTF_VARCHAR2_TABLE_100
    , p5_a64 JTF_VARCHAR2_TABLE_100
    , p5_a65 JTF_VARCHAR2_TABLE_100
    , p5_a66 JTF_VARCHAR2_TABLE_100
    , p5_a67 JTF_NUMBER_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p5_a69 JTF_NUMBER_TABLE
    , p5_a70 JTF_DATE_TABLE
    , p5_a71 JTF_NUMBER_TABLE
    , p5_a72 JTF_DATE_TABLE
    , p5_a73 JTF_NUMBER_TABLE
    , p5_a74 JTF_NUMBER_TABLE
    , p5_a75 JTF_VARCHAR2_TABLE_100
    , p5_a76 JTF_VARCHAR2_TABLE_100
    , p5_a77 JTF_NUMBER_TABLE
    , p5_a78 JTF_NUMBER_TABLE
    , p5_a79 JTF_VARCHAR2_TABLE_100
    , p5_a80 JTF_VARCHAR2_TABLE_100
    , p5_a81 JTF_NUMBER_TABLE
    , p5_a82 JTF_VARCHAR2_TABLE_100
    , p5_a83 JTF_NUMBER_TABLE
    , p5_a84 JTF_NUMBER_TABLE
    , p5_a85 JTF_NUMBER_TABLE
    , p5_a86 JTF_NUMBER_TABLE
    , p5_a87 JTF_VARCHAR2_TABLE_100
    , p5_a88 JTF_NUMBER_TABLE
    , p5_a89 JTF_NUMBER_TABLE
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_VARCHAR2_TABLE_100
    , p6_a5 JTF_VARCHAR2_TABLE_100
    , p6_a6 JTF_VARCHAR2_TABLE_100
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_NUMBER_TABLE
    , p6_a9 JTF_DATE_TABLE
    , p6_a10 JTF_NUMBER_TABLE
    , p6_a11 JTF_NUMBER_TABLE
    , p6_a12 JTF_NUMBER_TABLE
    , p6_a13 JTF_NUMBER_TABLE
    , p6_a14 JTF_NUMBER_TABLE
    , p6_a15 JTF_NUMBER_TABLE
    , p6_a16 JTF_NUMBER_TABLE
    , p6_a17 JTF_NUMBER_TABLE
    , p6_a18 JTF_NUMBER_TABLE
    , p6_a19 JTF_NUMBER_TABLE
    , p6_a20 JTF_DATE_TABLE
    , p6_a21 JTF_DATE_TABLE
    , p6_a22 JTF_NUMBER_TABLE
    , p6_a23 JTF_NUMBER_TABLE
    , p6_a24 JTF_DATE_TABLE
    , p6_a25 JTF_DATE_TABLE
    , p6_a26 JTF_DATE_TABLE
    , p6_a27 JTF_NUMBER_TABLE
    , p6_a28 JTF_NUMBER_TABLE
    , p6_a29 JTF_NUMBER_TABLE
    , p6_a30 JTF_NUMBER_TABLE
    , p6_a31 JTF_NUMBER_TABLE
    , p6_a32 JTF_NUMBER_TABLE
    , p6_a33 JTF_NUMBER_TABLE
    , p6_a34 JTF_DATE_TABLE
    , p6_a35 JTF_VARCHAR2_TABLE_100
    , p6_a36 JTF_DATE_TABLE
    , p6_a37 JTF_VARCHAR2_TABLE_300
    , p6_a38 JTF_NUMBER_TABLE
    , p6_a39 JTF_NUMBER_TABLE
    , p6_a40 JTF_NUMBER_TABLE
    , p6_a41 JTF_VARCHAR2_TABLE_100
    , p6_a42 JTF_DATE_TABLE
    , p6_a43 JTF_NUMBER_TABLE
    , p6_a44 JTF_NUMBER_TABLE
    , p6_a45 JTF_DATE_TABLE
    , p6_a46 JTF_NUMBER_TABLE
    , p6_a47 JTF_DATE_TABLE
    , p6_a48 JTF_DATE_TABLE
    , p6_a49 JTF_DATE_TABLE
    , p6_a50 JTF_NUMBER_TABLE
    , p6_a51 JTF_NUMBER_TABLE
    , p6_a52 JTF_VARCHAR2_TABLE_100
    , p6_a53 JTF_NUMBER_TABLE
    , p6_a54 JTF_NUMBER_TABLE
    , p6_a55 JTF_VARCHAR2_TABLE_100
    , p6_a56 JTF_VARCHAR2_TABLE_100
    , p6_a57 JTF_NUMBER_TABLE
    , p6_a58 JTF_DATE_TABLE
    , p6_a59 JTF_NUMBER_TABLE
    , p6_a60 JTF_VARCHAR2_TABLE_100
    , p6_a61 JTF_VARCHAR2_TABLE_500
    , p6_a62 JTF_VARCHAR2_TABLE_500
    , p6_a63 JTF_VARCHAR2_TABLE_500
    , p6_a64 JTF_VARCHAR2_TABLE_500
    , p6_a65 JTF_VARCHAR2_TABLE_500
    , p6_a66 JTF_VARCHAR2_TABLE_500
    , p6_a67 JTF_VARCHAR2_TABLE_500
    , p6_a68 JTF_VARCHAR2_TABLE_500
    , p6_a69 JTF_VARCHAR2_TABLE_500
    , p6_a70 JTF_VARCHAR2_TABLE_500
    , p6_a71 JTF_VARCHAR2_TABLE_500
    , p6_a72 JTF_VARCHAR2_TABLE_500
    , p6_a73 JTF_VARCHAR2_TABLE_500
    , p6_a74 JTF_VARCHAR2_TABLE_500
    , p6_a75 JTF_VARCHAR2_TABLE_500
    , p6_a76 JTF_NUMBER_TABLE
    , p6_a77 JTF_NUMBER_TABLE
    , p6_a78 JTF_NUMBER_TABLE
    , p6_a79 JTF_DATE_TABLE
    , p6_a80 JTF_NUMBER_TABLE
    , p6_a81 JTF_DATE_TABLE
    , p6_a82 JTF_NUMBER_TABLE
    , p6_a83 JTF_DATE_TABLE
    , p6_a84 JTF_DATE_TABLE
    , p6_a85 JTF_DATE_TABLE
    , p6_a86 JTF_DATE_TABLE
    , p6_a87 JTF_NUMBER_TABLE
    , p6_a88 JTF_NUMBER_TABLE
    , p6_a89 JTF_NUMBER_TABLE
    , p6_a90 JTF_VARCHAR2_TABLE_100
    , p6_a91 JTF_NUMBER_TABLE
    , p6_a92 JTF_VARCHAR2_TABLE_100
    , p6_a93 JTF_NUMBER_TABLE
    , p6_a94 JTF_NUMBER_TABLE
    , p6_a95 JTF_DATE_TABLE
    , p6_a96 JTF_VARCHAR2_TABLE_100
    , p6_a97 JTF_VARCHAR2_TABLE_100
    , p6_a98 JTF_NUMBER_TABLE
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_VARCHAR2_TABLE_100
    , p7_a7 JTF_VARCHAR2_TABLE_200
    , p7_a8 JTF_VARCHAR2_TABLE_100
    , p7_a9 JTF_VARCHAR2_TABLE_100
    , p7_a10 JTF_VARCHAR2_TABLE_100
    , p7_a11 JTF_NUMBER_TABLE
    , p7_a12 JTF_VARCHAR2_TABLE_100
    , p7_a13 JTF_NUMBER_TABLE
    , p7_a14 JTF_VARCHAR2_TABLE_100
    , p7_a15 JTF_NUMBER_TABLE
    , p7_a16 JTF_DATE_TABLE
    , p7_a17 JTF_NUMBER_TABLE
    , p7_a18 JTF_DATE_TABLE
    , p7_a19 JTF_NUMBER_TABLE
  )

  as
    ddp_clev_tbl okl_contract_line_item_pvt.clev_tbl_type;
    ddp_klev_tbl okl_contract_line_item_pvt.klev_tbl_type;
    ddp_cimv_tbl okl_contract_line_item_pvt.cimv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_okc_migration_pvt_w.rosetta_table_copy_in_p5(ddp_clev_tbl, p5_a0
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
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      , p5_a58
      , p5_a59
      , p5_a60
      , p5_a61
      , p5_a62
      , p5_a63
      , p5_a64
      , p5_a65
      , p5_a66
      , p5_a67
      , p5_a68
      , p5_a69
      , p5_a70
      , p5_a71
      , p5_a72
      , p5_a73
      , p5_a74
      , p5_a75
      , p5_a76
      , p5_a77
      , p5_a78
      , p5_a79
      , p5_a80
      , p5_a81
      , p5_a82
      , p5_a83
      , p5_a84
      , p5_a85
      , p5_a86
      , p5_a87
      , p5_a88
      , p5_a89
      );

    okl_kle_pvt_w.rosetta_table_copy_in_p8(ddp_klev_tbl, p6_a0
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
      , p6_a36
      , p6_a37
      , p6_a38
      , p6_a39
      , p6_a40
      , p6_a41
      , p6_a42
      , p6_a43
      , p6_a44
      , p6_a45
      , p6_a46
      , p6_a47
      , p6_a48
      , p6_a49
      , p6_a50
      , p6_a51
      , p6_a52
      , p6_a53
      , p6_a54
      , p6_a55
      , p6_a56
      , p6_a57
      , p6_a58
      , p6_a59
      , p6_a60
      , p6_a61
      , p6_a62
      , p6_a63
      , p6_a64
      , p6_a65
      , p6_a66
      , p6_a67
      , p6_a68
      , p6_a69
      , p6_a70
      , p6_a71
      , p6_a72
      , p6_a73
      , p6_a74
      , p6_a75
      , p6_a76
      , p6_a77
      , p6_a78
      , p6_a79
      , p6_a80
      , p6_a81
      , p6_a82
      , p6_a83
      , p6_a84
      , p6_a85
      , p6_a86
      , p6_a87
      , p6_a88
      , p6_a89
      , p6_a90
      , p6_a91
      , p6_a92
      , p6_a93
      , p6_a94
      , p6_a95
      , p6_a96
      , p6_a97
      , p6_a98
      );

    okl_okc_migration_pvt_w.rosetta_table_copy_in_p7(ddp_cimv_tbl, p7_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_contract_line_item_pvt.delete_contract_line_item(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_clev_tbl,
      ddp_klev_tbl,
      ddp_cimv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

end okl_contract_line_item_pvt_w;

/
