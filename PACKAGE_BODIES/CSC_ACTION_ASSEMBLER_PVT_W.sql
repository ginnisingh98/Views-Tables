--------------------------------------------------------
--  DDL for Package Body CSC_ACTION_ASSEMBLER_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_ACTION_ASSEMBLER_PVT_W" as
  /* $Header: cscwpotb.pls 115.1 2003/03/05 21:54:03 jamose noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p1(t out nocopy csc_action_assembler_pvt.results_tab_type, a0 JTF_VARCHAR2_TABLE_1000
    , a1 JTF_VARCHAR2_TABLE_1000
    , a2 JTF_VARCHAR2_TABLE_1800
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).name := a0(indx);
          t(ddindx).type := a1(indx);
          t(ddindx).description := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t csc_action_assembler_pvt.results_tab_type, a0 out nocopy JTF_VARCHAR2_TABLE_1000
    , a1 out nocopy JTF_VARCHAR2_TABLE_1000
    , a2 out nocopy JTF_VARCHAR2_TABLE_1800
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_1000();
    a1 := JTF_VARCHAR2_TABLE_1000();
    a2 := JTF_VARCHAR2_TABLE_1800();
  else
      a0 := JTF_VARCHAR2_TABLE_1000();
      a1 := JTF_VARCHAR2_TABLE_1000();
      a2 := JTF_VARCHAR2_TABLE_1800();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).name;
          a1(indx) := t(ddindx).type;
          a2(indx) := t(ddindx).description;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure enable_plan_and_get_outcomes(p_party_id  NUMBER
    , p_cust_account_id  NUMBER
    , p_end_user_type  VARCHAR2
    , p_application_short_name  VARCHAR2
    , p4_a0 JTF_VARCHAR2_TABLE_200
    , p4_a1 JTF_VARCHAR2_TABLE_300
    , p5_a0 out nocopy JTF_VARCHAR2_TABLE_1000
    , p5_a1 out nocopy JTF_VARCHAR2_TABLE_1000
    , p5_a2 out nocopy JTF_VARCHAR2_TABLE_1800
  )

  as
    ddp_msg_tbl okc_aq_pvt.msg_tab_typ;
    ddx_results_tbl csc_action_assembler_pvt.results_tab_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    okc_aq_pvt_w.rosetta_table_copy_in_p1(ddp_msg_tbl, p4_a0
      , p4_a1
      );


    -- here's the delegated call to the old PL/SQL routine
    csc_action_assembler_pvt.enable_plan_and_get_outcomes(p_party_id,
      p_cust_account_id,
      p_end_user_type,
      p_application_short_name,
      ddp_msg_tbl,
      ddx_results_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    csc_action_assembler_pvt_w.rosetta_table_copy_out_p1(ddx_results_tbl, p5_a0
      , p5_a1
      , p5_a2
      );
  end;

  procedure get_outcomes(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_action_id  NUMBER
    , p_application_short_name  VARCHAR2
    , p4_a0 JTF_VARCHAR2_TABLE_200
    , p4_a1 JTF_VARCHAR2_TABLE_300
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0 in out nocopy JTF_VARCHAR2_TABLE_1000
    , p8_a1 in out nocopy JTF_VARCHAR2_TABLE_1000
    , p8_a2 in out nocopy JTF_VARCHAR2_TABLE_1800
  )

  as
    ddp_msg_tbl okc_aq_pvt.msg_tab_typ;
    ddx_results_tbl csc_action_assembler_pvt.results_tab_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    okc_aq_pvt_w.rosetta_table_copy_in_p1(ddp_msg_tbl, p4_a0
      , p4_a1
      );




    csc_action_assembler_pvt_w.rosetta_table_copy_in_p1(ddx_results_tbl, p8_a0
      , p8_a1
      , p8_a2
      );

    -- here's the delegated call to the old PL/SQL routine
    csc_action_assembler_pvt.get_outcomes(p_api_version_number,
      p_init_msg_list,
      p_action_id,
      p_application_short_name,
      ddp_msg_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_results_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    csc_action_assembler_pvt_w.rosetta_table_copy_out_p1(ddx_results_tbl, p8_a0
      , p8_a1
      , p8_a2
      );
  end;

end csc_action_assembler_pvt_w;

/
