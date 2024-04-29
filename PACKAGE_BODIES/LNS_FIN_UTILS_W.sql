--------------------------------------------------------
--  DDL for Package Body LNS_FIN_UTILS_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_FIN_UTILS_W" as
  /* $Header: LNS_FIN_UTILSJ_B.pls 120.0.12010000.3 2010/02/05 18:22:38 mbolli ship $ */
  procedure rosetta_table_copy_in_p0(t out nocopy lns_fin_utils.date_tbl, a0 JTF_DATE_TABLE) as
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
  procedure rosetta_table_copy_out_p0(t lns_fin_utils.date_tbl, a0 out nocopy JTF_DATE_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_DATE_TABLE();
  else
      a0 := JTF_DATE_TABLE();
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

  procedure rosetta_table_copy_in_p2(t out nocopy lns_fin_utils.payment_schedule_tbl, a0 JTF_DATE_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).period_begin_date := a0(indx);
          t(ddindx).period_end_date := a1(indx);
          t(ddindx).period_due_date := a2(indx);
          t(ddindx).contents := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t lns_fin_utils.payment_schedule_tbl, a0 out nocopy JTF_DATE_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_DATE_TABLE();
    a1 := JTF_DATE_TABLE();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_DATE_TABLE();
      a1 := JTF_DATE_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).period_begin_date;
          a1(indx) := t(ddindx).period_end_date;
          a2(indx) := t(ddindx).period_due_date;
          a3(indx) := t(ddindx).contents;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure isleapyear(p_year  NUMBER
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  )

  as
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval boolean;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := lns_fin_utils.isleapyear(p_year);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    if ddrosetta_retval is null
      then ddrosetta_retval_bool := null;
    elsif ddrosetta_retval
      then ddrosetta_retval_bool := 1;
    else ddrosetta_retval_bool := 0;
    end if;
  end;

end lns_fin_utils_w;

/
