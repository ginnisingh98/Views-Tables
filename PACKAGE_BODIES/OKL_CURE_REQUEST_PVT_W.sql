--------------------------------------------------------
--  DDL for Package Body OKL_CURE_REQUEST_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CURE_REQUEST_PVT_W" as
  /* $Header: OKLEREQB.pls 120.1 2005/09/30 20:40:38 cklee noship $ */
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

  procedure send_cure_request(errbuf out nocopy  VARCHAR2
    , retcode out nocopy  NUMBER
    , p_vendor_number  NUMBER
    , p_report_number  VARCHAR2
    , p_report_date  date
  )

  as
    ddp_report_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_report_date := rosetta_g_miss_date_in_map(p_report_date);

    -- here's the delegated call to the old PL/SQL routine
    okl_cure_request_pvt.send_cure_request(errbuf,
      retcode,
      p_vendor_number,
      p_report_number,
      ddp_report_date);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




  end;

end okl_cure_request_pvt_w;

/
