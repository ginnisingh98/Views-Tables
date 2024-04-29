--------------------------------------------------------
--  DDL for Package Body OKL_REVERSAL_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_REVERSAL_PVT_W" as
  /* $Header: OKLEREVB.pls 120.1 2005/07/11 14:19:56 asawanka noship $ */
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

  procedure rosetta_table_copy_in_p0(t out nocopy okl_reversal_pvt.source_id_tbl_type, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p0;
  procedure rosetta_table_copy_out_p0(t okl_reversal_pvt.source_id_tbl_type, a0 out nocopy JTF_NUMBER_TABLE) as
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p0;

  procedure reverse_entries(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_source_id  NUMBER
    , p_source_table  VARCHAR2
    , p_acct_date  date
  )

  as
    ddp_acct_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_acct_date := rosetta_g_miss_date_in_map(p_acct_date);

    -- here's the delegated call to the old PL/SQL routine
    okl_reversal_pvt.reverse_entries(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_source_id,
      p_source_table,
      ddp_acct_date);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure reverse_entries(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_source_table  VARCHAR2
    , p_acct_date  date
    , p_source_id_tbl JTF_NUMBER_TABLE
  )

  as
    ddp_acct_date date;
    ddp_source_id_tbl okl_reversal_pvt.source_id_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_acct_date := rosetta_g_miss_date_in_map(p_acct_date);

    okl_reversal_pvt_w.rosetta_table_copy_in_p0(ddp_source_id_tbl, p_source_id_tbl);

    -- here's the delegated call to the old PL/SQL routine
    okl_reversal_pvt.reverse_entries(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_source_table,
      ddp_acct_date,
      ddp_source_id_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

end okl_reversal_pvt_w;

/
