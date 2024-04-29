--------------------------------------------------------
--  DDL for Package Body CUG_SR_TYPE_ATTR_MAPS_PKG_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CUG_SR_TYPE_ATTR_MAPS_PKG_W" as
  /* $Header: CUGSRTYB.pls 115.6 2004/03/29 21:44:16 aneemuch ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure insert_row(x_rowid in out nocopy  VARCHAR2
    , x_sr_type_attr_map_id  NUMBER
    , x_sr_type_attr_seq_num  NUMBER
    , x_object_version_number  NUMBER
    , x_incident_type_id  NUMBER
    , x_sr_attribute_code  VARCHAR2
    , x_sr_attr_mandatory_flag  VARCHAR2
    , x_sr_attr_displayed_flag  VARCHAR2
    , x_sr_attr_dup_check_flag  VARCHAR2
    , x_sr_attribute_list_name  VARCHAR2
    , x_attribute1  VARCHAR2
    , x_attribute2  VARCHAR2
    , x_attribute3  VARCHAR2
    , x_attribute4  VARCHAR2
    , x_attribute5  VARCHAR2
    , x_attribute6  VARCHAR2
    , x_attribute7  VARCHAR2
    , x_attribute8  VARCHAR2
    , x_attribute9  VARCHAR2
    , x_attribute10  VARCHAR2
    , x_attribute11  VARCHAR2
    , x_attribute12  VARCHAR2
    , x_attribute13  VARCHAR2
    , x_attribute14  VARCHAR2
    , x_attribute15  VARCHAR2
    , x_attribute_category  VARCHAR2
    , x_start_date_active  date
    , x_end_date_active  date
    , x_security_group_id  NUMBER
    , x_template_id  NUMBER
    , x_reqd_for_close_flag  VARCHAR2
    , x_show_on_update_flag  VARCHAR2
    , x_update_allowed_flag  VARCHAR2
    , x_sr_attr_default_value  VARCHAR2
    , x_creation_date  date
    , x_created_by  NUMBER
    , x_last_update_date  date
    , x_last_updated_by  NUMBER
    , x_last_update_login  NUMBER
  )

  as
    ddx_start_date_active date;
    ddx_end_date_active date;
    ddx_creation_date date;
    ddx_last_update_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


























    ddx_start_date_active := rosetta_g_miss_date_in_map(x_start_date_active);

    ddx_end_date_active := rosetta_g_miss_date_in_map(x_end_date_active);







    ddx_creation_date := rosetta_g_miss_date_in_map(x_creation_date);


    ddx_last_update_date := rosetta_g_miss_date_in_map(x_last_update_date);



    -- here's the delegated call to the old PL/SQL routine
    cug_sr_type_attr_maps_pkg.insert_row(x_rowid,
      x_sr_type_attr_map_id,
      x_sr_type_attr_seq_num,
      x_object_version_number,
      x_incident_type_id,
      x_sr_attribute_code,
      x_sr_attr_mandatory_flag,
      x_sr_attr_displayed_flag,
      x_sr_attr_dup_check_flag,
      x_sr_attribute_list_name,
      x_attribute1,
      x_attribute2,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute10,
      x_attribute11,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15,
      x_attribute_category,
      ddx_start_date_active,
      ddx_end_date_active,
      x_security_group_id,
      x_template_id,
      x_reqd_for_close_flag,
      x_show_on_update_flag,
      x_update_allowed_flag,
      x_sr_attr_default_value,
      ddx_creation_date,
      x_created_by,
      ddx_last_update_date,
      x_last_updated_by,
      x_last_update_login);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






































  end;

  procedure lock_row(x_sr_type_attr_map_id  NUMBER
    , x_sr_type_attr_seq_num  NUMBER
    , x_object_version_number  NUMBER
    , x_incident_type_id  NUMBER
    , x_sr_attribute_code  VARCHAR2
    , x_sr_attr_mandatory_flag  VARCHAR2
    , x_sr_attr_displayed_flag  VARCHAR2
    , x_sr_attr_dup_check_flag  VARCHAR2
    , x_sr_attribute_list_name  VARCHAR2
    , x_attribute1  VARCHAR2
    , x_attribute2  VARCHAR2
    , x_attribute3  VARCHAR2
    , x_attribute4  VARCHAR2
    , x_attribute5  VARCHAR2
    , x_attribute6  VARCHAR2
    , x_attribute7  VARCHAR2
    , x_attribute8  VARCHAR2
    , x_attribute9  VARCHAR2
    , x_attribute10  VARCHAR2
    , x_attribute11  VARCHAR2
    , x_attribute12  VARCHAR2
    , x_attribute13  VARCHAR2
    , x_attribute14  VARCHAR2
    , x_attribute15  VARCHAR2
    , x_attribute_category  VARCHAR2
    , x_start_date_active  date
    , x_end_date_active  date
    , x_security_group_id  NUMBER
    , x_template_id  NUMBER
    , x_reqd_for_close_flag  VARCHAR2
    , x_show_on_update_flag  VARCHAR2
    , x_update_allowed_flag  VARCHAR2
    , x_sr_attr_default_value  VARCHAR2
  )

  as
    ddx_start_date_active date;
    ddx_end_date_active date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

























    ddx_start_date_active := rosetta_g_miss_date_in_map(x_start_date_active);

    ddx_end_date_active := rosetta_g_miss_date_in_map(x_end_date_active);







    -- here's the delegated call to the old PL/SQL routine
    cug_sr_type_attr_maps_pkg.lock_row(x_sr_type_attr_map_id,
      x_sr_type_attr_seq_num,
      x_object_version_number,
      x_incident_type_id,
      x_sr_attribute_code,
      x_sr_attr_mandatory_flag,
      x_sr_attr_displayed_flag,
      x_sr_attr_dup_check_flag,
      x_sr_attribute_list_name,
      x_attribute1,
      x_attribute2,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute10,
      x_attribute11,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15,
      x_attribute_category,
      ddx_start_date_active,
      ddx_end_date_active,
      x_security_group_id,
      x_template_id,
      x_reqd_for_close_flag,
      x_show_on_update_flag,
      x_update_allowed_flag,
      x_sr_attr_default_value);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
































  end;

  procedure update_row(x_sr_type_attr_map_id  NUMBER
    , x_sr_type_attr_seq_num  NUMBER
    , x_object_version_number  NUMBER
    , x_incident_type_id  NUMBER
    , x_sr_attribute_code  VARCHAR2
    , x_sr_attr_mandatory_flag  VARCHAR2
    , x_sr_attr_displayed_flag  VARCHAR2
    , x_sr_attr_dup_check_flag  VARCHAR2
    , x_sr_attribute_list_name  VARCHAR2
    , x_attribute1  VARCHAR2
    , x_attribute2  VARCHAR2
    , x_attribute3  VARCHAR2
    , x_attribute4  VARCHAR2
    , x_attribute5  VARCHAR2
    , x_attribute6  VARCHAR2
    , x_attribute7  VARCHAR2
    , x_attribute8  VARCHAR2
    , x_attribute9  VARCHAR2
    , x_attribute10  VARCHAR2
    , x_attribute11  VARCHAR2
    , x_attribute12  VARCHAR2
    , x_attribute13  VARCHAR2
    , x_attribute14  VARCHAR2
    , x_attribute15  VARCHAR2
    , x_attribute_category  VARCHAR2
    , x_start_date_active  date
    , x_end_date_active  date
    , x_security_group_id  NUMBER
    , x_template_id  NUMBER
    , x_reqd_for_close_flag  VARCHAR2
    , x_show_on_update_flag  VARCHAR2
    , x_update_allowed_flag  VARCHAR2
    , x_sr_attr_default_value  VARCHAR2
    , x_last_update_date  date
    , x_last_updated_by  NUMBER
    , x_last_update_login  NUMBER
  )

  as
    ddx_start_date_active date;
    ddx_end_date_active date;
    ddx_last_update_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

























    ddx_start_date_active := rosetta_g_miss_date_in_map(x_start_date_active);

    ddx_end_date_active := rosetta_g_miss_date_in_map(x_end_date_active);







    ddx_last_update_date := rosetta_g_miss_date_in_map(x_last_update_date);



    -- here's the delegated call to the old PL/SQL routine
    cug_sr_type_attr_maps_pkg.update_row(x_sr_type_attr_map_id,
      x_sr_type_attr_seq_num,
      x_object_version_number,
      x_incident_type_id,
      x_sr_attribute_code,
      x_sr_attr_mandatory_flag,
      x_sr_attr_displayed_flag,
      x_sr_attr_dup_check_flag,
      x_sr_attribute_list_name,
      x_attribute1,
      x_attribute2,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute10,
      x_attribute11,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15,
      x_attribute_category,
      ddx_start_date_active,
      ddx_end_date_active,
      x_security_group_id,
      x_template_id,
      x_reqd_for_close_flag,
      x_show_on_update_flag,
      x_update_allowed_flag,
      x_sr_attr_default_value,
      ddx_last_update_date,
      x_last_updated_by,
      x_last_update_login);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



































  end;

  procedure load_row(x_sr_type_attr_map_id  NUMBER
    , x_incident_type_id  NUMBER
    , x_sr_attribute_code  VARCHAR2
    , x_sr_attr_mandatory_flag  VARCHAR2
    , x_sr_attr_displayed_flag  VARCHAR2
    , x_sr_attr_dup_check_flag  VARCHAR2
    , x_sr_attribute_list_name  VARCHAR2
    , x_start_date_active  date
    , x_end_date_active  date
    , x_sr_attr_default_value  VARCHAR2
    , x_template_id  NUMBER
    , x_reqd_for_close_flag  VARCHAR2
    , x_show_on_update_flag  VARCHAR2
    , x_update_allowed_flag  VARCHAR2
    , x_sr_type_attr_seq_num  NUMBER
    , x_security_group_id  NUMBER
    , x_creation_date  VARCHAR2
    , x_created_by  NUMBER
    , x_last_update_date  VARCHAR2
    , x_last_updated_by  NUMBER
    , x_last_update_login  NUMBER
    , x_owner  VARCHAR2
  )

  as
    ddx_start_date_active date;
    ddx_end_date_active date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddx_start_date_active := rosetta_g_miss_date_in_map(x_start_date_active);

    ddx_end_date_active := rosetta_g_miss_date_in_map(x_end_date_active);














    -- here's the delegated call to the old PL/SQL routine
    cug_sr_type_attr_maps_pkg.load_row(x_sr_type_attr_map_id,
      x_incident_type_id,
      x_sr_attribute_code,
      x_sr_attr_mandatory_flag,
      x_sr_attr_displayed_flag,
      x_sr_attr_dup_check_flag,
      x_sr_attribute_list_name,
      ddx_start_date_active,
      ddx_end_date_active,
      x_sr_attr_default_value,
      x_template_id,
      x_reqd_for_close_flag,
      x_show_on_update_flag,
      x_update_allowed_flag,
      x_sr_type_attr_seq_num,
      x_security_group_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_owner);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





















  end;

end cug_sr_type_attr_maps_pkg_w;

/
