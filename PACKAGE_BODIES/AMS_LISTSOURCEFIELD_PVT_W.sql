--------------------------------------------------------
--  DDL for Package Body AMS_LISTSOURCEFIELD_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LISTSOURCEFIELD_PVT_W" as
  /* $Header: amswlsfb.pls 115.0 2000/02/05 17:52:09 pkm ship    $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  function rosetta_g_miss_num_map(n number) return number is
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date is
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

end ams_listsourcefield_pvt_w;

/
