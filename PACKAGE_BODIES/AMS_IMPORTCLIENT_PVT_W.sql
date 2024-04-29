--------------------------------------------------------
--  DDL for Package Body AMS_IMPORTCLIENT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_IMPORTCLIENT_PVT_W" as
  /* $Header: amswmicb.pls 115.9 2003/05/15 22:36:28 huili ship $ */
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

  procedure rosetta_table_copy_in_p0(t OUT NOCOPY ams_importclient_pvt.char_data_set_type_w, a0 JTF_VARCHAR2_TABLE_4000) as
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
  procedure rosetta_table_copy_out_p0(t ams_importclient_pvt.char_data_set_type_w, a0 OUT NOCOPY JTF_VARCHAR2_TABLE_4000) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_4000();
  else
      a0 := JTF_VARCHAR2_TABLE_4000();
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

  procedure rosetta_table_copy_in_p1(t OUT NOCOPY ams_importclient_pvt.num_data_set_type_w, a0 JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t ams_importclient_pvt.num_data_set_type_w, a0 OUT NOCOPY JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
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
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p2(t OUT NOCOPY ams_importclient_pvt.varchar2_4000_set_type, a0 JTF_VARCHAR2_TABLE_4000) as
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
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t ams_importclient_pvt.varchar2_4000_set_type, a0 OUT NOCOPY JTF_VARCHAR2_TABLE_4000) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_4000();
  else
      a0 := JTF_VARCHAR2_TABLE_4000();
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
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p3(t OUT NOCOPY ams_importclient_pvt.varchar2_150_set_type, a0 JTF_VARCHAR2_TABLE_200) as
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
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ams_importclient_pvt.varchar2_150_set_type, a0 OUT NOCOPY JTF_VARCHAR2_TABLE_200) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_200();
  else
      a0 := JTF_VARCHAR2_TABLE_200();
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
  end rosetta_table_copy_out_p3;

  procedure insert_lead_data(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_import_list_header_id  NUMBER
    , p_data JTF_VARCHAR2_TABLE_4000
    , p_error_rows JTF_NUMBER_TABLE
    , p_row_count  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
  )

  as
    ddp_data ams_importclient_pvt.char_data_set_type_w;
    ddp_error_rows ams_importclient_pvt.num_data_set_type_w;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ams_importclient_pvt_w.rosetta_table_copy_in_p0(ddp_data, p_data);

    ams_importclient_pvt_w.rosetta_table_copy_in_p1(ddp_error_rows, p_error_rows);





    -- here's the delegated call to the old PL/SQL routine
    ams_importclient_pvt.insert_lead_data(p_api_version,
      p_init_msg_list,
      p_commit,
      p_import_list_header_id,
      ddp_data,
      ddp_error_rows,
      p_row_count,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure insert_list_data(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_import_list_header_id  NUMBER
    , p_data JTF_VARCHAR2_TABLE_4000
    , p_row_count  NUMBER
    , p_error_rows JTF_NUMBER_TABLE
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
  )

  as
    ddp_data ams_importclient_pvt.char_data_set_type_w;
    ddp_error_rows ams_importclient_pvt.num_data_set_type_w;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ams_importclient_pvt_w.rosetta_table_copy_in_p0(ddp_data, p_data);


    ams_importclient_pvt_w.rosetta_table_copy_in_p1(ddp_error_rows, p_error_rows);




    -- here's the delegated call to the old PL/SQL routine
    ams_importclient_pvt.insert_list_data(p_api_version,
      p_init_msg_list,
      p_commit,
      p_import_list_header_id,
      ddp_data,
      p_row_count,
      ddp_error_rows,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

end ams_importclient_pvt_w;

/
