--------------------------------------------------------
--  DDL for Package Body AMS_LISTIMPORT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LISTIMPORT_PVT_W" as
  /* $Header: amswimlb.pls 115.15 2002/11/12 23:44:36 jieli noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure import_process(p_import_list_header_id  NUMBER
    , p_start_time  date
    , p_control_file  VARCHAR2
    , p_staged_only  VARCHAR2
    , p_owner_user_id  NUMBER
    , p_generate_list  VARCHAR2
    , p_list_name  VARCHAR2
    , x_request_id OUT NOCOPY  NUMBER
  )

  as
    ddp_start_time date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_start_time := rosetta_g_miss_date_in_map(p_start_time);







    -- here's the delegated call to the old PL/SQL routine
    ams_listimport_pvt.import_process(p_import_list_header_id,
      ddp_start_time,
      p_control_file,
      p_staged_only,
      p_owner_user_id,
      p_generate_list,
      p_list_name,
      x_request_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

end ams_listimport_pvt_w;

/
