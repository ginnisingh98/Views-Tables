--------------------------------------------------------
--  DDL for Package Body OKL_GL_TRANSFER_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_GL_TRANSFER_PVT_W" as
  /* $Header: OKLEGLTB.pls 120.1 2005/07/11 12:49:56 dkagrawa noship $ */
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

  procedure okl_gl_transfer_con(p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_batch_name  VARCHAR2
    , p_from_date  date
    , p_to_date  date
    , p_validate_account  VARCHAR2
    , p_gl_transfer_mode  VARCHAR2
    , p_submit_journal_import  VARCHAR2
    , x_request_id out nocopy  NUMBER
  )

  as
    ddp_from_date date;
    ddp_to_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_from_date := rosetta_g_miss_date_in_map(p_from_date);

    ddp_to_date := rosetta_g_miss_date_in_map(p_to_date);





    -- here's the delegated call to the old PL/SQL routine
    okl_gl_transfer_pvt.okl_gl_transfer_con(p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_batch_name,
      ddp_from_date,
      ddp_to_date,
      p_validate_account,
      p_gl_transfer_mode,
      p_submit_journal_import,
      x_request_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

end okl_gl_transfer_pvt_w;

/
