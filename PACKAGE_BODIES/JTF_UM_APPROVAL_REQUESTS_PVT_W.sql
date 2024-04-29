--------------------------------------------------------
--  DDL for Package Body JTF_UM_APPROVAL_REQUESTS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_UM_APPROVAL_REQUESTS_PVT_W" AS
  /* $Header: JTFWAPRB.pls 120.2.12010000.3 2013/03/27 08:02:57 anurtrip ship $ */
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

  procedure rosetta_table_copy_in_p1(t out nocopy jtf_um_approval_requests_pvt.approval_request_table_type, a0 JTF_DATE_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_400
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_1000
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).reg_last_update_date := rosetta_g_miss_date_in_map(a0(indx));
          t(ddindx).user_name := a1(indx);
          t(ddindx).company_name := a2(indx);
          t(ddindx).entity_source := a3(indx);
          t(ddindx).entity_name := a4(indx);
          t(ddindx).wf_item_type := a5(indx);
          t(ddindx).reg_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).approver := a7(indx);
          t(ddindx).error_activity := rosetta_g_miss_num_map(a8(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t jtf_um_approval_requests_pvt.approval_request_table_type, a0 out nocopy JTF_DATE_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_400
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_1000
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_DATE_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_400();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_1000();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_DATE_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_400();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_1000();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        a7.extend(t.count);
        a8.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).reg_last_update_date;
          a1(indx) := t(ddindx).user_name;
          a2(indx) := t(ddindx).company_name;
          a3(indx) := t(ddindx).entity_source;
          a4(indx) := t(ddindx).entity_name;
          a5(indx) := t(ddindx).wf_item_type;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).reg_id);
          a7(indx) := t(ddindx).approver;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).error_activity);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure pending_approval_sysadmin(p_sort_order  VARCHAR2
    , p_number_of_records  NUMBER
    , p2_a0 out nocopy JTF_DATE_TABLE
    , p2_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a2 out nocopy JTF_VARCHAR2_TABLE_400
    , p2_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a4 out nocopy JTF_VARCHAR2_TABLE_1000
    , p2_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a6 out nocopy JTF_NUMBER_TABLE
    , p2_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a8 out nocopy JTF_NUMBER_TABLE
    , p_sort_option varchar2
  )

  as
    ddx_result jtf_um_approval_requests_pvt.approval_request_table_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    -- here's the delegated call to the old PL/SQL routine
    jtf_um_approval_requests_pvt.pending_approval_sysadmin(p_sort_order,
      p_number_of_records,
      ddx_result,p_sort_option);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    jtf_um_approval_requests_pvt_w.rosetta_table_copy_out_p1(ddx_result, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      , p2_a5
      , p2_a6
      , p2_a7
      , p2_a8
      );
  end;

  procedure pending_approval_primary(p_sort_order  VARCHAR2
    , p_number_of_records  NUMBER
    , p_approver_user_id  NUMBER
    , p3_a0 out nocopy JTF_DATE_TABLE
    , p3_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a2 out nocopy JTF_VARCHAR2_TABLE_400
    , p3_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a4 out nocopy JTF_VARCHAR2_TABLE_1000
    , p3_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a6 out nocopy JTF_NUMBER_TABLE
    , p3_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a8 out nocopy JTF_NUMBER_TABLE
    , p_sort_option varchar2
  )

  as
    ddx_result jtf_um_approval_requests_pvt.approval_request_table_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    -- here's the delegated call to the old PL/SQL routine
    jtf_um_approval_requests_pvt.pending_approval_primary(p_sort_order,
      p_number_of_records,
      p_approver_user_id,
      ddx_result,p_sort_option);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    jtf_um_approval_requests_pvt_w.rosetta_table_copy_out_p1(ddx_result, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      );
  end;

  procedure pending_approval_owner(p_sort_order  VARCHAR2
    , p_number_of_records  NUMBER
    , p_approver_user_id  NUMBER
    , p3_a0 out nocopy JTF_DATE_TABLE
    , p3_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a2 out nocopy JTF_VARCHAR2_TABLE_400
    , p3_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a4 out nocopy JTF_VARCHAR2_TABLE_1000
    , p3_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a6 out nocopy JTF_NUMBER_TABLE
    , p3_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a8 out nocopy JTF_NUMBER_TABLE
    , p_sort_option varchar2
  )

  as
    ddx_result jtf_um_approval_requests_pvt.approval_request_table_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    -- here's the delegated call to the old PL/SQL routine
    jtf_um_approval_requests_pvt.pending_approval_owner(p_sort_order,
      p_number_of_records,
      p_approver_user_id,
      ddx_result,p_sort_option);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    jtf_um_approval_requests_pvt_w.rosetta_table_copy_out_p1(ddx_result, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      );
  end;

end jtf_um_approval_requests_pvt_w;

/
