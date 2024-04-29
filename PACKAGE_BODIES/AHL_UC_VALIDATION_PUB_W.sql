--------------------------------------------------------
--  DDL for Package Body AHL_UC_VALIDATION_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_UC_VALIDATION_PUB_W" as
  /* $Header: AHLWUCVB.pls 115.0 2003/08/11 21:36:11 cxcheng noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p0(t out nocopy ahl_uc_validation_pub.error_tbl_type, a0 JTF_VARCHAR2_TABLE_2000) as
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
  procedure rosetta_table_copy_out_p0(t ahl_uc_validation_pub.error_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_2000) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_2000();
  else
      a0 := JTF_VARCHAR2_TABLE_2000();
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

  procedure validate_completeness(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_unit_header_id  NUMBER
    , x_error_tbl out nocopy JTF_VARCHAR2_TABLE_2000
  )

  as
    ddx_error_tbl ahl_uc_validation_pub.error_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    ahl_uc_validation_pub.validate_completeness(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_unit_header_id,
      ddx_error_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    ahl_uc_validation_pub_w.rosetta_table_copy_out_p0(ddx_error_tbl, x_error_tbl);
  end;

  procedure validate_complete_for_pos(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_csi_instance_id  NUMBER
    , x_error_tbl out nocopy JTF_VARCHAR2_TABLE_2000
  )

  as
    ddx_error_tbl ahl_uc_validation_pub.error_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    ahl_uc_validation_pub.validate_complete_for_pos(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_csi_instance_id,
      ddx_error_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    ahl_uc_validation_pub_w.rosetta_table_copy_out_p0(ddx_error_tbl, x_error_tbl);
  end;

end ahl_uc_validation_pub_w;

/
