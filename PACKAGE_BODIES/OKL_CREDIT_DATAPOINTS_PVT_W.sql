--------------------------------------------------------
--  DDL for Package Body OKL_CREDIT_DATAPOINTS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CREDIT_DATAPOINTS_PVT_W" as
  /* $Header: OKLECDPB.pls 120.0.12010000.1 2008/07/25 08:01:18 appldev ship $ */
  procedure rosetta_table_copy_in_p4(t out nocopy okl_credit_datapoints_pvt.lap_dp_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_200
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := a0(indx);
          t(ddindx).object_version_number := a1(indx);
          t(ddindx).leaseapp_id := a2(indx);
          t(ddindx).data_point_id := a3(indx);
          t(ddindx).data_point_category := a4(indx);
          t(ddindx).data_point_value := a5(indx);
          t(ddindx).data_point_name := a6(indx);
          t(ddindx).description := a7(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t okl_credit_datapoints_pvt.lap_dp_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_200
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_200();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_200();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_200();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_200();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        a7.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).leaseapp_id;
          a3(indx) := t(ddindx).data_point_id;
          a4(indx) := t(ddindx).data_point_category;
          a5(indx) := t(ddindx).data_point_value;
          a6(indx) := t(ddindx).data_point_name;
          a7(indx) := t(ddindx).description;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure fetch_leaseapp_datapoints(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_leaseapp_id  NUMBER
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_NUMBER_TABLE
    , p3_a2 out nocopy JTF_NUMBER_TABLE
    , p3_a3 out nocopy JTF_NUMBER_TABLE
    , p3_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a5 out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_lap_dp_tbl_type okl_credit_datapoints_pvt.lap_dp_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    okl_credit_datapoints_pvt.fetch_leaseapp_datapoints(p_api_version,
      p_init_msg_list,
      p_leaseapp_id,
      ddx_lap_dp_tbl_type,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    okl_credit_datapoints_pvt_w.rosetta_table_copy_out_p4(ddx_lap_dp_tbl_type, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      );



  end;

  procedure store_leaseapp_datapoints(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0 JTF_NUMBER_TABLE
    , p2_a1 JTF_NUMBER_TABLE
    , p2_a2 JTF_NUMBER_TABLE
    , p2_a3 JTF_NUMBER_TABLE
    , p2_a4 JTF_VARCHAR2_TABLE_100
    , p2_a5 JTF_VARCHAR2_TABLE_200
    , p2_a6 JTF_VARCHAR2_TABLE_100
    , p2_a7 JTF_VARCHAR2_TABLE_200
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_lap_dp_tbl okl_credit_datapoints_pvt.lap_dp_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    okl_credit_datapoints_pvt_w.rosetta_table_copy_in_p4(ddp_lap_dp_tbl, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      , p2_a5
      , p2_a6
      , p2_a7
      );




    -- here's the delegated call to the old PL/SQL routine
    okl_credit_datapoints_pvt.store_leaseapp_datapoints(p_api_version,
      p_init_msg_list,
      ddp_lap_dp_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure leaseapp_datapoints_exists(p_leaseapp_id  NUMBER
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  )

  as
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval boolean;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := okl_credit_datapoints_pvt.leaseapp_datapoints_exists(p_leaseapp_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    if ddrosetta_retval is null
      then ddrosetta_retval_bool := null;
    elsif ddrosetta_retval
      then ddrosetta_retval_bool := 1;
    else ddrosetta_retval_bool := 0;
    end if;
  end;

end okl_credit_datapoints_pvt_w;

/
