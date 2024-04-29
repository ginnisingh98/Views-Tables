--------------------------------------------------------
--  DDL for Package Body OKC_XPRT_QA_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_XPRT_QA_PVT_W" as
  /* $Header: OKCWXRULQAB.pls 120.0 2005/05/25 22:55:47 appldev noship $ */
  procedure rosetta_table_copy_in_p0(t out nocopy okc_xprt_qa_pvt.ruleidlist, a0 JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_in_p0;
  procedure rosetta_table_copy_out_p0(t okc_xprt_qa_pvt.ruleidlist, a0 out nocopy JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_out_p0;

  procedure qa_rules(p_qa_mode  VARCHAR2
    , p_ruleid_tbl JTF_NUMBER_TABLE
    , x_sequence_id out nocopy  NUMBER
    , x_qa_status out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_ruleid_tbl okc_xprt_qa_pvt.ruleidlist;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    okc_xprt_qa_pvt_w.rosetta_table_copy_in_p0(ddp_ruleid_tbl, p_ruleid_tbl);






    -- here's the delegated call to the old PL/SQL routine
    okc_xprt_qa_pvt.qa_rules(p_qa_mode,
      ddp_ruleid_tbl,
      x_sequence_id,
      x_qa_status,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure sync_rules(p_sync_mode  VARCHAR2
    , p_org_id  NUMBER
    , p_ruleid_tbl JTF_NUMBER_TABLE
    , x_request_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_ruleid_tbl okc_xprt_qa_pvt.ruleidlist;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    okc_xprt_qa_pvt_w.rosetta_table_copy_in_p0(ddp_ruleid_tbl, p_ruleid_tbl);





    -- here's the delegated call to the old PL/SQL routine
    okc_xprt_qa_pvt.sync_rules(p_sync_mode,
      p_org_id,
      ddp_ruleid_tbl,
      x_request_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

end okc_xprt_qa_pvt_w;

/
