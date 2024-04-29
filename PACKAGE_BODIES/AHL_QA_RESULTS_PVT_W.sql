--------------------------------------------------------
--  DDL for Package Body AHL_QA_RESULTS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_QA_RESULTS_PVT_W" as
  /* $Header: AHLWQARB.pls 115.2 2002/11/14 23:06:22 shkalyan noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p1(t out nocopy ahl_qa_results_pvt.qa_results_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_2000
    , a2 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).char_id := a0(indx);
          t(ddindx).result_value := a1(indx);
          t(ddindx).result_id := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t ahl_qa_results_pvt.qa_results_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_2000
    , a2 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_2000();
    a2 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_2000();
      a2 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).char_id;
          a1(indx) := t(ddindx).result_value;
          a2(indx) := t(ddindx).result_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p3(t out nocopy ahl_qa_results_pvt.occurrence_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).element_count := a0(indx);
          t(ddindx).occurrence := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ahl_qa_results_pvt.occurrence_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).element_count;
          a1(indx) := t(ddindx).occurrence;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p5(t out nocopy ahl_qa_results_pvt.qa_context_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_2000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).name := a0(indx);
          t(ddindx).value := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t ahl_qa_results_pvt.qa_context_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_2000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_2000();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_2000();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).name;
          a1(indx) := t(ddindx).value;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure submit_qa_results(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_default  VARCHAR2
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_plan_id  NUMBER
    , p_organization_id  NUMBER
    , p_transaction_no  NUMBER
    , p_specification_id  NUMBER
    , p13_a0 JTF_NUMBER_TABLE
    , p13_a1 JTF_VARCHAR2_TABLE_2000
    , p13_a2 JTF_NUMBER_TABLE
    , p14_a0 JTF_NUMBER_TABLE
    , p14_a1 JTF_VARCHAR2_TABLE_2000
    , p14_a2 JTF_NUMBER_TABLE
    , p15_a0 JTF_VARCHAR2_TABLE_100
    , p15_a1 JTF_VARCHAR2_TABLE_2000
    , p_result_commit_flag  NUMBER
    , p_id_or_value  VARCHAR2
    , p_x_collection_id in out nocopy  NUMBER
    , p19_a0 in out nocopy JTF_NUMBER_TABLE
    , p19_a1 in out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_results_tbl ahl_qa_results_pvt.qa_results_tbl_type;
    ddp_hidden_results_tbl ahl_qa_results_pvt.qa_results_tbl_type;
    ddp_context_tbl ahl_qa_results_pvt.qa_context_tbl_type;
    ddp_x_occurrence_tbl ahl_qa_results_pvt.occurrence_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any













    ahl_qa_results_pvt_w.rosetta_table_copy_in_p1(ddp_results_tbl, p13_a0
      , p13_a1
      , p13_a2
      );

    ahl_qa_results_pvt_w.rosetta_table_copy_in_p1(ddp_hidden_results_tbl, p14_a0
      , p14_a1
      , p14_a2
      );

    ahl_qa_results_pvt_w.rosetta_table_copy_in_p5(ddp_context_tbl, p15_a0
      , p15_a1
      );




    ahl_qa_results_pvt_w.rosetta_table_copy_in_p3(ddp_x_occurrence_tbl, p19_a0
      , p19_a1
      );

    -- here's the delegated call to the old PL/SQL routine
    ahl_qa_results_pvt.submit_qa_results(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_default,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_plan_id,
      p_organization_id,
      p_transaction_no,
      p_specification_id,
      ddp_results_tbl,
      ddp_hidden_results_tbl,
      ddp_context_tbl,
      p_result_commit_flag,
      p_id_or_value,
      p_x_collection_id,
      ddp_x_occurrence_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



















    ahl_qa_results_pvt_w.rosetta_table_copy_out_p3(ddp_x_occurrence_tbl, p19_a0
      , p19_a1
      );
  end;

end ahl_qa_results_pvt_w;

/
