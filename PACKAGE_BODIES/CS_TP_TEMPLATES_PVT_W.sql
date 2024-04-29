--------------------------------------------------------
--  DDL for Package Body CS_TP_TEMPLATES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_TP_TEMPLATES_PVT_W" as
  /* $Header: cstprtmb.pls 120.2 2005/06/30 11:07 appldev ship $ */
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

  procedure rosetta_table_copy_in_p1(t out nocopy cs_tp_templates_pvt.template_list, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_1000
    , a2 JTF_VARCHAR2_TABLE_200
    , a3 JTF_VARCHAR2_TABLE_200
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_600
    , a6 JTF_VARCHAR2_TABLE_200
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).mtemplateid := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).mtemplatename := a1(indx);
          t(ddindx).mstartdate := a2(indx);
          t(ddindx).menddate := a3(indx);
          t(ddindx).mdefaultflag := a4(indx);
          t(ddindx).mshortcode := a5(indx);
          t(ddindx).mlast_updated_date := a6(indx);
          t(ddindx).muniquestionnoteflag := a7(indx);
          t(ddindx).muniquestionnotetype := a8(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t cs_tp_templates_pvt.template_list, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_1000
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    , a3 out nocopy JTF_VARCHAR2_TABLE_200
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_600
    , a6 out nocopy JTF_VARCHAR2_TABLE_200
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_1000();
    a2 := JTF_VARCHAR2_TABLE_200();
    a3 := JTF_VARCHAR2_TABLE_200();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_600();
    a6 := JTF_VARCHAR2_TABLE_200();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_1000();
      a2 := JTF_VARCHAR2_TABLE_200();
      a3 := JTF_VARCHAR2_TABLE_200();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_600();
      a6 := JTF_VARCHAR2_TABLE_200();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).mtemplateid);
          a1(indx) := t(ddindx).mtemplatename;
          a2(indx) := t(ddindx).mstartdate;
          a3(indx) := t(ddindx).menddate;
          a4(indx) := t(ddindx).mdefaultflag;
          a5(indx) := t(ddindx).mshortcode;
          a6(indx) := t(ddindx).mlast_updated_date;
          a7(indx) := t(ddindx).muniquestionnoteflag;
          a8(indx) := t(ddindx).muniquestionnotetype;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p3(t out nocopy cs_tp_templates_pvt.template_attribute_list, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_1000
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_200
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_200
    , a7 JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).mattributeid := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).mattributename := a1(indx);
          t(ddindx).mstartthreshold := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).mendthreshold := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).mjtf_object_code := a4(indx);
          t(ddindx).mother_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).mdefaultflag := a6(indx);
          t(ddindx).mlast_updated_date := a7(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t cs_tp_templates_pvt.template_attribute_list, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_1000
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_200
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_200
    , a7 out nocopy JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_1000();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_200();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_200();
    a7 := JTF_VARCHAR2_TABLE_200();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_1000();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_200();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_200();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).mattributeid);
          a1(indx) := t(ddindx).mattributename;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).mstartthreshold);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).mendthreshold);
          a4(indx) := t(ddindx).mjtf_object_code;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).mother_id);
          a6(indx) := t(ddindx).mdefaultflag;
          a7(indx) := t(ddindx).mlast_updated_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p5(t out nocopy cs_tp_templates_pvt.template_link_list, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_1000
    , a2 JTF_VARCHAR2_TABLE_1000
    , a3 JTF_VARCHAR2_TABLE_200
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
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
          t(ddindx).mlinkid := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).mlinkname := a1(indx);
          t(ddindx).mlinkdesc := a2(indx);
          t(ddindx).mjtf_object_code := a3(indx);
          t(ddindx).mother_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).lookup_code := a5(indx);
          t(ddindx).lookup_type := a6(indx);
          t(ddindx).mlast_updated_date := a7(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t cs_tp_templates_pvt.template_link_list, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_1000
    , a2 out nocopy JTF_VARCHAR2_TABLE_1000
    , a3 out nocopy JTF_VARCHAR2_TABLE_200
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_1000();
    a2 := JTF_VARCHAR2_TABLE_1000();
    a3 := JTF_VARCHAR2_TABLE_200();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_200();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_1000();
      a2 := JTF_VARCHAR2_TABLE_1000();
      a3 := JTF_VARCHAR2_TABLE_200();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).mlinkid);
          a1(indx) := t(ddindx).mlinkname;
          a2(indx) := t(ddindx).mlinkdesc;
          a3(indx) := t(ddindx).mjtf_object_code;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).mother_id);
          a5(indx) := t(ddindx).lookup_code;
          a6(indx) := t(ddindx).lookup_type;
          a7(indx) := t(ddindx).mlast_updated_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p7(t out nocopy cs_tp_templates_pvt.id_name_pairs, a0 JTF_VARCHAR2_TABLE_1000
    , a1 JTF_VARCHAR2_TABLE_1000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).mobject_code := a0(indx);
          t(ddindx).mname := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t cs_tp_templates_pvt.id_name_pairs, a0 out nocopy JTF_VARCHAR2_TABLE_1000
    , a1 out nocopy JTF_VARCHAR2_TABLE_1000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_1000();
    a1 := JTF_VARCHAR2_TABLE_1000();
  else
      a0 := JTF_VARCHAR2_TABLE_1000();
      a1 := JTF_VARCHAR2_TABLE_1000();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).mobject_code;
          a1(indx) := t(ddindx).mname;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure rosetta_table_copy_in_p9(t out nocopy cs_tp_templates_pvt.object_other_id_pairs, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_1000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).mother_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).mlookup_code := a1(indx);
          t(ddindx).mobject_code := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p9;
  procedure rosetta_table_copy_out_p9(t cs_tp_templates_pvt.object_other_id_pairs, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_1000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_1000();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_1000();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).mother_id);
          a1(indx) := t(ddindx).mlookup_code;
          a2(indx) := t(ddindx).mobject_code;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p9;

  procedure add_template(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_template_id out nocopy  NUMBER
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  VARCHAR2 := fnd_api.g_miss_char
    , p3_a2  VARCHAR2 := fnd_api.g_miss_char
    , p3_a3  VARCHAR2 := fnd_api.g_miss_char
    , p3_a4  VARCHAR2 := fnd_api.g_miss_char
    , p3_a5  VARCHAR2 := fnd_api.g_miss_char
    , p3_a6  VARCHAR2 := fnd_api.g_miss_char
    , p3_a7  VARCHAR2 := fnd_api.g_miss_char
    , p3_a8  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_one_template cs_tp_templates_pvt.template;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_one_template.mtemplateid := rosetta_g_miss_num_map(p3_a0);
    ddp_one_template.mtemplatename := p3_a1;
    ddp_one_template.mstartdate := p3_a2;
    ddp_one_template.menddate := p3_a3;
    ddp_one_template.mdefaultflag := p3_a4;
    ddp_one_template.mshortcode := p3_a5;
    ddp_one_template.mlast_updated_date := p3_a6;
    ddp_one_template.muniquestionnoteflag := p3_a7;
    ddp_one_template.muniquestionnotetype := p3_a8;





    -- here's the delegated call to the old PL/SQL routine
    cs_tp_templates_pvt.add_template(p_api_version_number,
      p_init_msg_list,
      p_commit,
      ddp_one_template,
      x_msg_count,
      x_msg_data,
      x_return_status,
      x_template_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure update_template(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  VARCHAR2 := fnd_api.g_miss_char
    , p3_a2  VARCHAR2 := fnd_api.g_miss_char
    , p3_a3  VARCHAR2 := fnd_api.g_miss_char
    , p3_a4  VARCHAR2 := fnd_api.g_miss_char
    , p3_a5  VARCHAR2 := fnd_api.g_miss_char
    , p3_a6  VARCHAR2 := fnd_api.g_miss_char
    , p3_a7  VARCHAR2 := fnd_api.g_miss_char
    , p3_a8  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_one_template cs_tp_templates_pvt.template;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_one_template.mtemplateid := rosetta_g_miss_num_map(p3_a0);
    ddp_one_template.mtemplatename := p3_a1;
    ddp_one_template.mstartdate := p3_a2;
    ddp_one_template.menddate := p3_a3;
    ddp_one_template.mdefaultflag := p3_a4;
    ddp_one_template.mshortcode := p3_a5;
    ddp_one_template.mlast_updated_date := p3_a6;
    ddp_one_template.muniquestionnoteflag := p3_a7;
    ddp_one_template.muniquestionnotetype := p3_a8;




    -- here's the delegated call to the old PL/SQL routine
    cs_tp_templates_pvt.update_template(p_api_version_number,
      p_init_msg_list,
      p_commit,
      ddp_one_template,
      x_msg_count,
      x_msg_data,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure update_template_attributes(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR
    , p_template_id  NUMBER
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_VARCHAR2_TABLE_1000
    , p4_a2 JTF_NUMBER_TABLE
    , p4_a3 JTF_NUMBER_TABLE
    , p4_a4 JTF_VARCHAR2_TABLE_200
    , p4_a5 JTF_NUMBER_TABLE
    , p4_a6 JTF_VARCHAR2_TABLE_200
    , p4_a7 JTF_VARCHAR2_TABLE_200
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_template_attributes cs_tp_templates_pvt.template_attribute_list;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    cs_tp_templates_pvt_w.rosetta_table_copy_in_p3(ddp_template_attributes, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      , p4_a6
      , p4_a7
      );




    -- here's the delegated call to the old PL/SQL routine
    cs_tp_templates_pvt.update_template_attributes(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_template_id,
      ddp_template_attributes,
      x_msg_count,
      x_msg_data,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure update_template_links(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR
    , p_template_id  NUMBER
    , p_jtf_object_code  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_1000
    , p5_a2 JTF_VARCHAR2_TABLE_1000
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_200
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_template_links cs_tp_templates_pvt.template_link_list;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    cs_tp_templates_pvt_w.rosetta_table_copy_in_p5(ddp_template_links, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      );




    -- here's the delegated call to the old PL/SQL routine
    cs_tp_templates_pvt.update_template_links(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_template_id,
      p_jtf_object_code,
      ddp_template_links,
      x_msg_count,
      x_msg_data,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure show_templates(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_template_name  VARCHAR2
    , p_start_template  NUMBER
    , p_end_template  NUMBER
    , p_display_order  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_VARCHAR2_TABLE_1000
    , p10_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a5 out nocopy JTF_VARCHAR2_TABLE_600
    , p10_a6 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , x_total_templates out nocopy  NUMBER
    , x_retrieved_template_num out nocopy  NUMBER
  )

  as
    ddx_template_list_to_show cs_tp_templates_pvt.template_list;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any













    -- here's the delegated call to the old PL/SQL routine
    cs_tp_templates_pvt.show_templates(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_template_name,
      p_start_template,
      p_end_template,
      p_display_order,
      x_msg_count,
      x_msg_data,
      x_return_status,
      ddx_template_list_to_show,
      x_total_templates,
      x_retrieved_template_num);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    cs_tp_templates_pvt_w.rosetta_table_copy_out_p1(ddx_template_list_to_show, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      , p10_a4
      , p10_a5
      , p10_a6
      , p10_a7
      , p10_a8
      );


  end;

  procedure show_template(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR
    , p_template_id  NUMBER
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  VARCHAR2
    , p7_a2 out nocopy  VARCHAR2
    , p7_a3 out nocopy  VARCHAR2
    , p7_a4 out nocopy  VARCHAR2
    , p7_a5 out nocopy  VARCHAR2
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  VARCHAR2
    , p7_a8 out nocopy  VARCHAR2
  )

  as
    ddx_template_to_show cs_tp_templates_pvt.template;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    -- here's the delegated call to the old PL/SQL routine
    cs_tp_templates_pvt.show_template(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_template_id,
      x_msg_count,
      x_msg_data,
      x_return_status,
      ddx_template_to_show);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddx_template_to_show.mtemplateid);
    p7_a1 := ddx_template_to_show.mtemplatename;
    p7_a2 := ddx_template_to_show.mstartdate;
    p7_a3 := ddx_template_to_show.menddate;
    p7_a4 := ddx_template_to_show.mdefaultflag;
    p7_a5 := ddx_template_to_show.mshortcode;
    p7_a6 := ddx_template_to_show.mlast_updated_date;
    p7_a7 := ddx_template_to_show.muniquestionnoteflag;
    p7_a8 := ddx_template_to_show.muniquestionnotetype;
  end;

  procedure show_templates_with_link(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR
    , p3_a0 JTF_NUMBER_TABLE
    , p3_a1 JTF_VARCHAR2_TABLE_100
    , p3_a2 JTF_VARCHAR2_TABLE_1000
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_VARCHAR2_TABLE_1000
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a5 out nocopy JTF_VARCHAR2_TABLE_600
    , p7_a6 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a8 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_object_other_list cs_tp_templates_pvt.object_other_id_pairs;
    ddx_template_list cs_tp_templates_pvt.template_list;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    cs_tp_templates_pvt_w.rosetta_table_copy_in_p9(ddp_object_other_list, p3_a0
      , p3_a1
      , p3_a2
      );





    -- here's the delegated call to the old PL/SQL routine
    cs_tp_templates_pvt.show_templates_with_link(p_api_version_number,
      p_init_msg_list,
      p_commit,
      ddp_object_other_list,
      x_msg_count,
      x_msg_data,
      x_return_status,
      ddx_template_list);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    cs_tp_templates_pvt_w.rosetta_table_copy_out_p1(ddx_template_list, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      , p7_a8
      );
  end;

  procedure show_template_attributes(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR
    , p_template_id  NUMBER
    , p_jtf_object_code  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_1000
    , p8_a2 out nocopy JTF_NUMBER_TABLE
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a5 out nocopy JTF_NUMBER_TABLE
    , p8_a6 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a7 out nocopy JTF_VARCHAR2_TABLE_200
  )

  as
    ddx_template_attributes cs_tp_templates_pvt.template_attribute_list;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    cs_tp_templates_pvt.show_template_attributes(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_template_id,
      p_jtf_object_code,
      x_msg_count,
      x_msg_data,
      x_return_status,
      ddx_template_attributes);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    cs_tp_templates_pvt_w.rosetta_table_copy_out_p3(ddx_template_attributes, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      );
  end;

  procedure show_template_links(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR
    , p_template_id  NUMBER
    , p_jtf_object_code  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_1000
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_1000
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a4 out nocopy JTF_NUMBER_TABLE
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 out nocopy JTF_VARCHAR2_TABLE_200
  )

  as
    ddx_template_links cs_tp_templates_pvt.template_link_list;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    cs_tp_templates_pvt.show_template_links(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_template_id,
      p_jtf_object_code,
      x_msg_count,
      x_msg_data,
      x_return_status,
      ddx_template_links);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    cs_tp_templates_pvt_w.rosetta_table_copy_out_p5(ddx_template_links, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      );
  end;

  procedure show_non_asso_links(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR
    , p_template_id  NUMBER
    , p_jtf_object_code  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_1000
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_1000
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a4 out nocopy JTF_NUMBER_TABLE
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 out nocopy JTF_VARCHAR2_TABLE_200
  )

  as
    ddx_template_link_list cs_tp_templates_pvt.template_link_list;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    cs_tp_templates_pvt.show_non_asso_links(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_template_id,
      p_jtf_object_code,
      x_msg_count,
      x_msg_data,
      x_return_status,
      ddx_template_link_list);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    cs_tp_templates_pvt_w.rosetta_table_copy_out_p5(ddx_template_link_list, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      );
  end;

  procedure show_link_attribute_list(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_identify  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p7_a0 out nocopy JTF_VARCHAR2_TABLE_1000
    , p7_a1 out nocopy JTF_VARCHAR2_TABLE_1000
  )

  as
    ddx_idname_pairs cs_tp_templates_pvt.id_name_pairs;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    -- here's the delegated call to the old PL/SQL routine
    cs_tp_templates_pvt.show_link_attribute_list(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_identify,
      x_msg_count,
      x_msg_data,
      x_return_status,
      ddx_idname_pairs);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    cs_tp_templates_pvt_w.rosetta_table_copy_out_p7(ddx_idname_pairs, p7_a0
      , p7_a1
      );
  end;

  procedure retrieve_constants(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p6_a0 out nocopy JTF_VARCHAR2_TABLE_1000
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_1000
  )

  as
    ddx_idname_pairs cs_tp_templates_pvt.id_name_pairs;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    cs_tp_templates_pvt.retrieve_constants(p_api_version_number,
      p_init_msg_list,
      p_commit,
      x_msg_count,
      x_msg_data,
      x_return_status,
      ddx_idname_pairs);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    cs_tp_templates_pvt_w.rosetta_table_copy_out_p7(ddx_idname_pairs, p6_a0
      , p6_a1
      );
  end;

  procedure show_default_template(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
  )

  as
    ddx_default_template cs_tp_templates_pvt.template;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    cs_tp_templates_pvt.show_default_template(p_api_version_number,
      p_init_msg_list,
      p_commit,
      x_msg_count,
      x_msg_data,
      x_return_status,
      ddx_default_template);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_default_template.mtemplateid);
    p6_a1 := ddx_default_template.mtemplatename;
    p6_a2 := ddx_default_template.mstartdate;
    p6_a3 := ddx_default_template.menddate;
    p6_a4 := ddx_default_template.mdefaultflag;
    p6_a5 := ddx_default_template.mshortcode;
    p6_a6 := ddx_default_template.mlast_updated_date;
    p6_a7 := ddx_default_template.muniquestionnoteflag;
    p6_a8 := ddx_default_template.muniquestionnotetype;
  end;

  procedure show_template_links_two(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR
    , p_template_id  NUMBER
    , p_jtf_object_code  VARCHAR2
    , p_start_link  NUMBER
    , p_end_link  NUMBER
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_VARCHAR2_TABLE_1000
    , p10_a2 out nocopy JTF_VARCHAR2_TABLE_1000
    , p10_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a4 out nocopy JTF_NUMBER_TABLE
    , p10_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , x_total_link_number out nocopy  NUMBER
    , x_retrieved_link_number out nocopy  NUMBER
  )

  as
    ddx_template_links cs_tp_templates_pvt.template_link_list;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any













    -- here's the delegated call to the old PL/SQL routine
    cs_tp_templates_pvt.show_template_links_two(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_template_id,
      p_jtf_object_code,
      p_start_link,
      p_end_link,
      x_msg_count,
      x_msg_data,
      x_return_status,
      ddx_template_links,
      x_total_link_number,
      x_retrieved_link_number);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    cs_tp_templates_pvt_w.rosetta_table_copy_out_p5(ddx_template_links, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      , p10_a4
      , p10_a5
      , p10_a6
      , p10_a7
      );


  end;

  procedure show_non_asso_links_two(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR
    , p_template_id  NUMBER
    , p_jtf_object_code  VARCHAR2
    , p_start_link  NUMBER
    , p_end_link  NUMBER
    , p_link_name  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_VARCHAR2_TABLE_1000
    , p11_a2 out nocopy JTF_VARCHAR2_TABLE_1000
    , p11_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a4 out nocopy JTF_NUMBER_TABLE
    , p11_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , x_total_link_number out nocopy  NUMBER
    , x_retrieved_link_number out nocopy  NUMBER
  )

  as
    ddx_template_link_list cs_tp_templates_pvt.template_link_list;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any














    -- here's the delegated call to the old PL/SQL routine
    cs_tp_templates_pvt.show_non_asso_links_two(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_template_id,
      p_jtf_object_code,
      p_start_link,
      p_end_link,
      p_link_name,
      x_msg_count,
      x_msg_data,
      x_return_status,
      ddx_template_link_list,
      x_total_link_number,
      x_retrieved_link_number);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











    cs_tp_templates_pvt_w.rosetta_table_copy_out_p5(ddx_template_link_list, p11_a0
      , p11_a1
      , p11_a2
      , p11_a3
      , p11_a4
      , p11_a5
      , p11_a6
      , p11_a7
      );


  end;

  procedure delete_template_links(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR
    , p_template_id  NUMBER
    , p_jtf_object_code  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_1000
    , p5_a2 JTF_VARCHAR2_TABLE_1000
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_200
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_template_links cs_tp_templates_pvt.template_link_list;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    cs_tp_templates_pvt_w.rosetta_table_copy_in_p5(ddp_template_links, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      );




    -- here's the delegated call to the old PL/SQL routine
    cs_tp_templates_pvt.delete_template_links(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_template_id,
      p_jtf_object_code,
      ddp_template_links,
      x_msg_count,
      x_msg_data,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure add_template_links(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR
    , p_template_id  NUMBER
    , p_jtf_object_code  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_1000
    , p5_a2 JTF_VARCHAR2_TABLE_1000
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_200
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_template_links cs_tp_templates_pvt.template_link_list;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    cs_tp_templates_pvt_w.rosetta_table_copy_in_p5(ddp_template_links, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      );




    -- here's the delegated call to the old PL/SQL routine
    cs_tp_templates_pvt.add_template_links(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_template_id,
      p_jtf_object_code,
      ddp_template_links,
      x_msg_count,
      x_msg_data,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

end cs_tp_templates_pvt_w;

/
