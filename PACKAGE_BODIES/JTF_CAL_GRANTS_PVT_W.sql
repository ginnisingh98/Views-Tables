--------------------------------------------------------
--  DDL for Package Body JTF_CAL_GRANTS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_CAL_GRANTS_PVT_W" as
  /* $Header: jtfwcgtb.pls 115.5 2002/11/15 00:23:08 jawang ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p1(t out nocopy jtf_cal_grants_pvt.granteetbl, a0 JTF_VARCHAR2_TABLE_300
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).granteekey := a0(indx);
          t(ddindx).granttype := a1(indx);
          t(ddindx).accesslevel := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t jtf_cal_grants_pvt.granteetbl, a0 out nocopy JTF_VARCHAR2_TABLE_300
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_300();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_300();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).granteekey;
          a1(indx) := t(ddindx).granttype;
          a2(indx) := t(ddindx).accesslevel;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure has_access_level(p_resourceid  VARCHAR2
    , p_groupid  VARCHAR2
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  )

  as
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval boolean;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := jtf_cal_grants_pvt.has_access_level(p_resourceid,
      p_groupid);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    if ddrosetta_retval is null
      then ddrosetta_retval_bool := null;
    elsif ddrosetta_retval
      then ddrosetta_retval_bool := 1;
    else ddrosetta_retval_bool := 0;
    end if;

  end;

end jtf_cal_grants_pvt_w;

/
