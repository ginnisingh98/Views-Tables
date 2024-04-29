--------------------------------------------------------
--  DDL for Package Body OKL_CURE_REQ_AMT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CURE_REQ_AMT_PVT_W" as
  /* $Header: OKLECRKB.pls 115.0 2003/04/25 04:16:04 smereddy noship $ */
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

  procedure rosetta_table_copy_in_p3(t out nocopy okl_cure_req_amt_pvt.cure_req_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).cure_amount_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).cure_report_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).chr_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).vendor_id := rosetta_g_miss_num_map(a3(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t okl_cure_req_amt_pvt.cure_req_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).cure_amount_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).cure_report_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).chr_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).vendor_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure update_cure_request(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_cure_req_tbl okl_cure_req_amt_pvt.cure_req_tbl_type;
    ddx_cure_req_tbl okl_cure_req_amt_pvt.cure_req_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_cure_req_amt_pvt_w.rosetta_table_copy_in_p3(ddp_cure_req_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_cure_req_amt_pvt.update_cure_request(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cure_req_tbl,
      ddx_cure_req_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_cure_req_amt_pvt_w.rosetta_table_copy_out_p3(ddx_cure_req_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      );
  end;

end okl_cure_req_amt_pvt_w;

/
