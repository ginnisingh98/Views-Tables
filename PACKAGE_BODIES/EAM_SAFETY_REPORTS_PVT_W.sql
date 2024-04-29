--------------------------------------------------------
--  DDL for Package Body EAM_SAFETY_REPORTS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_SAFETY_REPORTS_PVT_W" as
  /* $Header: EAMWSRPB.pls 120.0.12010000.1 2010/04/16 10:58:06 somitra noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_high date := to_date('01/01/+4710', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_low date := to_date('01/01/-4710', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d > rosetta_g_mistake_date_high then return fnd_api.g_miss_date; end if;
    if d < rosetta_g_mistake_date_low then return fnd_api.g_miss_date; end if;
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

  procedure rosetta_table_copy_in_p1(t out nocopy eam_safety_reports_pvt.eam_permit_tab_type, a0 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count=0 then
    t := eam_safety_reports_pvt.eam_permit_tab_type();
  elsif a0 is not null and a0.count > 0 then
      if a0.count > 0 then
      t := eam_safety_reports_pvt.eam_permit_tab_type();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).permit_id := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t eam_safety_reports_pvt.eam_permit_tab_type, a0 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
  elsif t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).permit_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  function getworkpermitreportxml(p0_a0 JTF_NUMBER_TABLE
    , p_file_attachment_flag  NUMBER
    , p_work_order_flag  NUMBER
  ) return clob

  as
    ddp_permit_ids eam_safety_reports_pvt.eam_permit_tab_type;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval clob;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    eam_safety_reports_pvt_w.rosetta_table_copy_in_p1(ddp_permit_ids, p0_a0
      );



    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := eam_safety_reports_pvt.getworkpermitreportxml(ddp_permit_ids,
      p_file_attachment_flag,
      p_work_order_flag);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    return ddrosetta_retval;
  end;

  function convert_to_client_time(p_server_time  date
  ) return date

  as
    ddp_server_time date;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval date;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_server_time := rosetta_g_miss_date_in_map(p_server_time);

    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := eam_safety_reports_pvt.convert_to_client_time(ddp_server_time);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    return ddrosetta_retval;
  end;

end eam_safety_reports_pvt_w;

/
