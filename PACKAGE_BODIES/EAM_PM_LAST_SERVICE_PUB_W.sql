--------------------------------------------------------
--  DDL for Package Body EAM_PM_LAST_SERVICE_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_PM_LAST_SERVICE_PUB_W" as
  /* $Header: EAMWPLSB.pls 120.2 2008/01/26 01:50:52 devijay ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy eam_pm_last_service_pub.pm_last_service_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).meter_id := a0(indx);
          t(ddindx).last_service_reading := a1(indx);
          t(ddindx).prev_service_reading := a2(indx);
          t(ddindx).wip_entity_id := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t eam_pm_last_service_pub.pm_last_service_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).meter_id;
          a1(indx) := t(ddindx).last_service_reading;
          a2(indx) := t(ddindx).prev_service_reading;
          a3(indx) := t(ddindx).wip_entity_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure process_pm_last_service(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p_actv_assoc_id  NUMBER
  )

  as
    ddp_pm_last_service_tbl eam_pm_last_service_pub.pm_last_service_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    eam_pm_last_service_pub_w.rosetta_table_copy_in_p1(ddp_pm_last_service_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      );


    -- here's the delegated call to the old PL/SQL routine
    eam_pm_last_service_pub.process_pm_last_service(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pm_last_service_tbl,
      p_actv_assoc_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

end eam_pm_last_service_pub_w;

/
