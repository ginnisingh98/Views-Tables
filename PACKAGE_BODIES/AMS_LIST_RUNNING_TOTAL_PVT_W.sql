--------------------------------------------------------
--  DDL for Package Body AMS_LIST_RUNNING_TOTAL_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LIST_RUNNING_TOTAL_PVT_W" as
  /* $Header: amswlrutb.pls 115.0 2003/11/19 19:06:09 huili noship $ */
  procedure rosetta_table_copy_in_p0(t out nocopy ams_list_running_total_pvt.sql_string_4k, a0 JTF_VARCHAR2_TABLE_4000) as
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
  procedure rosetta_table_copy_out_p0(t ams_list_running_total_pvt.sql_string_4k, a0 out nocopy JTF_VARCHAR2_TABLE_4000) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_4000();
  else
      a0 := JTF_VARCHAR2_TABLE_4000();
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

  procedure rosetta_table_copy_in_p1(t out nocopy ams_list_running_total_pvt.t_number, a0 JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t ams_list_running_total_pvt.t_number, a0 out nocopy JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_out_p1;

  procedure process_query(p_sql_string JTF_VARCHAR2_TABLE_4000
    , p_total_parameters JTF_NUMBER_TABLE
    , p_string_parameters JTF_VARCHAR2_TABLE_4000
    , p_template_id  NUMBER
    , p_parameters JTF_VARCHAR2_TABLE_4000
    , p_parameters_value JTF_NUMBER_TABLE
    , p_sql_results out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_sql_string ams_list_running_total_pvt.sql_string_4k;
    ddp_total_parameters ams_list_running_total_pvt.t_number;
    ddp_string_parameters ams_list_running_total_pvt.sql_string_4k;
    ddp_parameters ams_list_running_total_pvt.sql_string_4k;
    ddp_parameters_value ams_list_running_total_pvt.t_number;
    ddp_sql_results ams_list_running_total_pvt.t_number;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ams_list_running_total_pvt_w.rosetta_table_copy_in_p0(ddp_sql_string, p_sql_string);

    ams_list_running_total_pvt_w.rosetta_table_copy_in_p1(ddp_total_parameters, p_total_parameters);

    ams_list_running_total_pvt_w.rosetta_table_copy_in_p0(ddp_string_parameters, p_string_parameters);


    ams_list_running_total_pvt_w.rosetta_table_copy_in_p0(ddp_parameters, p_parameters);

    ams_list_running_total_pvt_w.rosetta_table_copy_in_p1(ddp_parameters_value, p_parameters_value);


    -- here's the delegated call to the old PL/SQL routine
    ams_list_running_total_pvt.process_query(ddp_sql_string,
      ddp_total_parameters,
      ddp_string_parameters,
      p_template_id,
      ddp_parameters,
      ddp_parameters_value,
      ddp_sql_results);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    ams_list_running_total_pvt_w.rosetta_table_copy_out_p1(ddp_sql_results, p_sql_results);
  end;

end ams_list_running_total_pvt_w;

/
