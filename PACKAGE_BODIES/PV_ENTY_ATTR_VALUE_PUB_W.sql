--------------------------------------------------------
--  DDL for Package Body PV_ENTY_ATTR_VALUE_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_ENTY_ATTR_VALUE_PUB_W" as
  /* $Header: pvxwavpb.pls 120.2 2005/11/11 15:27 amaram noship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy pv_enty_attr_value_pub.attr_value_tbl_type, a0 JTF_VARCHAR2_TABLE_2000
    , a1 JTF_VARCHAR2_TABLE_4000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).attr_value := a0(indx);
          t(ddindx).attr_value_extn := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t pv_enty_attr_value_pub.attr_value_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_2000
    , a1 out nocopy JTF_VARCHAR2_TABLE_4000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_2000();
    a1 := JTF_VARCHAR2_TABLE_4000();
  else
      a0 := JTF_VARCHAR2_TABLE_2000();
      a1 := JTF_VARCHAR2_TABLE_4000();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).attr_value;
          a1(indx) := t(ddindx).attr_value_extn;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p4(t out nocopy pv_enty_attr_value_pub.number_table, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is null then
    t := null;
  elsif a0.count = 0 then
    t := pv_enty_attr_value_pub.number_table();
  else
      if a0.count > 0 then
      t := pv_enty_attr_value_pub.number_table();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t pv_enty_attr_value_pub.number_table, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
  elsif t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure upsert_attr_value(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_attribute_id  NUMBER
    , p_entity  VARCHAR2
    , p_entity_id  NUMBER
    , p_version  NUMBER
    , p11_a0 JTF_VARCHAR2_TABLE_2000
    , p11_a1 JTF_VARCHAR2_TABLE_4000
  )

  as
    ddp_attr_val_tbl pv_enty_attr_value_pub.attr_value_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    pv_enty_attr_value_pub_w.rosetta_table_copy_in_p2(ddp_attr_val_tbl, p11_a0
      , p11_a1
      );

    -- here's the delegated call to the old PL/SQL routine
    pv_enty_attr_value_pub.upsert_attr_value(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_attribute_id,
      p_entity,
      p_entity_id,
      p_version,
      ddp_attr_val_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

  procedure copy_partner_attr_values(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_attr_id_tbl JTF_NUMBER_TABLE
    , p_entity  VARCHAR2
    , p_entity_id  NUMBER
    , p_partner_id  NUMBER
  )

  as
    ddp_attr_id_tbl pv_enty_attr_value_pub.number_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    pv_enty_attr_value_pub_w.rosetta_table_copy_in_p4(ddp_attr_id_tbl, p_attr_id_tbl);




    -- here's the delegated call to the old PL/SQL routine
    pv_enty_attr_value_pub.copy_partner_attr_values(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_attr_id_tbl,
      p_entity,
      p_entity_id,
      p_partner_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

  procedure upsert_partner_types(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_entity_id  NUMBER
    , p_version  NUMBER
    , p9_a0 JTF_VARCHAR2_TABLE_2000
    , p9_a1 JTF_VARCHAR2_TABLE_4000
  )

  as
    ddp_attr_val_tbl pv_enty_attr_value_pub.attr_value_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    pv_enty_attr_value_pub_w.rosetta_table_copy_in_p2(ddp_attr_val_tbl, p9_a0
      , p9_a1
      );

    -- here's the delegated call to the old PL/SQL routine
    pv_enty_attr_value_pub.upsert_partner_types(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_entity_id,
      p_version,
      ddp_attr_val_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

end pv_enty_attr_value_pub_w;

/
