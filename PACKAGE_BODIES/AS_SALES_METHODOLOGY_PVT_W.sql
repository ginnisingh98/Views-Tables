--------------------------------------------------------
--  DDL for Package Body AS_SALES_METHODOLOGY_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_SALES_METHODOLOGY_PVT_W" as
  /* $Header: asxsmwb.pls 120.1 2005/06/17 03:00 appldev  $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
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

  procedure create_sales_methodology(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validate_level  VARCHAR2
    , p_sales_methodology_name  VARCHAR2
    , p_start_date_active  date
    , p_end_date_active  date
    , p_autocreatetask_flag  VARCHAR2
    , p_description  VARCHAR2
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , p_attribute11  VARCHAR2
    , p_attribute12  VARCHAR2
    , p_attribute13  VARCHAR2
    , p_attribute14  VARCHAR2
    , p_attribute15  VARCHAR2
    , p_attribute_category  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_sales_methodology_id out nocopy  NUMBER
  )

  as
    ddp_start_date_active date;
    ddp_end_date_active date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_start_date_active := rosetta_g_miss_date_in_map(p_start_date_active);

    ddp_end_date_active := rosetta_g_miss_date_in_map(p_end_date_active);























    -- here's the delegated call to the old PL/SQL routine
    as_sales_methodology_pvt.create_sales_methodology(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validate_level,
      p_sales_methodology_name,
      ddp_start_date_active,
      ddp_end_date_active,
      p_autocreatetask_flag,
      p_description,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15,
      p_attribute_category,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_sales_methodology_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




























  end;

  procedure update_sales_methodology(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validate_level  VARCHAR2
    , p_sales_methodology_id  NUMBER
    , p_sales_methodology_name  VARCHAR2
    , p_start_date_active  date
    , p_end_date_active  date
    , p_autocreatetask_flag  VARCHAR2
    , p_description  VARCHAR2
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , p_attribute11  VARCHAR2
    , p_attribute12  VARCHAR2
    , p_attribute13  VARCHAR2
    , p_attribute14  VARCHAR2
    , p_attribute15  VARCHAR2
    , p_attribute_category  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_object_version_number in out nocopy  NUMBER
  )

  as
    ddp_start_date_active date;
    ddp_end_date_active date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_start_date_active := rosetta_g_miss_date_in_map(p_start_date_active);

    ddp_end_date_active := rosetta_g_miss_date_in_map(p_end_date_active);























    -- here's the delegated call to the old PL/SQL routine
    as_sales_methodology_pvt.update_sales_methodology(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validate_level,
      p_sales_methodology_id,
      p_sales_methodology_name,
      ddp_start_date_active,
      ddp_end_date_active,
      p_autocreatetask_flag,
      p_description,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15,
      p_attribute_category,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_object_version_number);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





























  end;

end as_sales_methodology_pvt_w;

/
