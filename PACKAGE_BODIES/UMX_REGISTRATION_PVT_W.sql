--------------------------------------------------------
--  DDL for Package Body UMX_REGISTRATION_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."UMX_REGISTRATION_PVT_W" as
  /* $Header: UMXWREGB.pls 120.1.12010000.2 2009/07/22 19:06:00 jstyles ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p1(t out nocopy umx_registration_pvt.umx_registration_data_tbl, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_2000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).attr_name := a0(indx);
          t(ddindx).attr_value := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;

  procedure rosetta_table_copy_out_p1(t umx_registration_pvt.umx_registration_data_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_100
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
          a0(indx) := t(ddindx).attr_name;
          a1(indx) := t(ddindx).attr_value;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure umx_process_reg_request(p0_a0 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a1 in out nocopy JTF_VARCHAR2_TABLE_2000
    , x_return_status out NOCOPY varchar2
 	  , x_message_data out NOCOPY varchar2) as

    ddp_registration_data umx_registration_pvt.umx_registration_data_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    umx_registration_pvt_w.rosetta_table_copy_in_p1(ddp_registration_data, p0_a0 , p0_a1);

    -- here's the delegated call to the old PL/SQL routine
    umx_registration_pvt.umx_process_reg_request(ddp_registration_data,x_return_status, x_message_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    umx_registration_pvt_w.rosetta_table_copy_out_p1(ddp_registration_data, p0_a0 , p0_a1);
  end;

  procedure populate_reg_data(p0_a0 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a1 in out nocopy JTF_VARCHAR2_TABLE_2000
  )

  as
    ddp_registration_data umx_registration_pvt.umx_registration_data_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    umx_registration_pvt_w.rosetta_table_copy_in_p1(ddp_registration_data, p0_a0 , p0_a1);

    -- here's the delegated call to the old PL/SQL routine
    umx_registration_pvt.populate_reg_data(ddp_registration_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    umx_registration_pvt_w.rosetta_table_copy_out_p1(ddp_registration_data, p0_a0 , p0_a1);
  end;

  procedure assign_role(p0_a0 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a1 in out nocopy JTF_VARCHAR2_TABLE_2000
    , x_return_status out NOCOPY varchar2
 		, x_message_data out NOCOPY varchar2)   as
    ddp_registration_data umx_registration_pvt.umx_registration_data_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    umx_registration_pvt_w.rosetta_table_copy_in_p1(ddp_registration_data, p0_a0
      , p0_a1
      );

    -- here's the delegated call to the old PL/SQL routine
    umx_registration_pvt.assign_role(ddp_registration_data, x_return_status, x_message_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    umx_registration_pvt_w.rosetta_table_copy_out_p1(ddp_registration_data, p0_a0
      , p0_a1
      );
  end;

end umx_registration_pvt_w;

/
