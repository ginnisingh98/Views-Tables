--------------------------------------------------------
--  DDL for Package Body CS_TP_CHOICES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_TP_CHOICES_PVT_W" as
  /* $Header: cstprcsb.pls 120.2 2005/06/30 11:01 appldev ship $ */
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

  procedure rosetta_table_copy_in_p1(t out nocopy cs_tp_choices_pvt.choice_list, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_1000
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).mchoiceid := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).mchoicename := a1(indx);
          t(ddindx).mlookupid := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).mscore := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).mlast_updated_date := a4(indx);
          t(ddindx).mdefaultchoiceflag := a5(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t cs_tp_choices_pvt.choice_list, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_1000
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_1000();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_1000();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).mchoiceid);
          a1(indx) := t(ddindx).mchoicename;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).mlookupid);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).mscore);
          a4(indx) := t(ddindx).mlast_updated_date;
          a5(indx) := t(ddindx).mdefaultchoiceflag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure add_choice(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_choice_id out nocopy  NUMBER
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  VARCHAR2 := fnd_api.g_miss_char
    , p3_a2  NUMBER := 0-1962.0724
    , p3_a3  NUMBER := 0-1962.0724
    , p3_a4  VARCHAR2 := fnd_api.g_miss_char
    , p3_a5  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_one_choice cs_tp_choices_pvt.choice;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_one_choice.mchoiceid := rosetta_g_miss_num_map(p3_a0);
    ddp_one_choice.mchoicename := p3_a1;
    ddp_one_choice.mlookupid := rosetta_g_miss_num_map(p3_a2);
    ddp_one_choice.mscore := rosetta_g_miss_num_map(p3_a3);
    ddp_one_choice.mlast_updated_date := p3_a4;
    ddp_one_choice.mdefaultchoiceflag := p3_a5;





    -- here's the delegated call to the old PL/SQL routine
    cs_tp_choices_pvt.add_choice(p_api_version_number,
      p_init_msg_list,
      p_commit,
      ddp_one_choice,
      x_msg_count,
      x_msg_data,
      x_return_status,
      x_choice_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure sort_choices(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR
    , p3_a0 JTF_NUMBER_TABLE
    , p3_a1 JTF_VARCHAR2_TABLE_1000
    , p3_a2 JTF_NUMBER_TABLE
    , p3_a3 JTF_NUMBER_TABLE
    , p3_a4 JTF_VARCHAR2_TABLE_100
    , p3_a5 JTF_VARCHAR2_TABLE_100
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_choices cs_tp_choices_pvt.choice_list;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    cs_tp_choices_pvt_w.rosetta_table_copy_in_p1(ddp_choices, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      );




    -- here's the delegated call to the old PL/SQL routine
    cs_tp_choices_pvt.sort_choices(p_api_version_number,
      p_init_msg_list,
      p_commit,
      ddp_choices,
      x_msg_count,
      x_msg_data,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure show_choices(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR
    , p_lookup_id  NUMBER
    , p_display_order  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_1000
    , p8_a2 out nocopy JTF_NUMBER_TABLE
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddx_choice_list_to_show cs_tp_choices_pvt.choice_list;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    cs_tp_choices_pvt.show_choices(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_lookup_id,
      p_display_order,
      x_msg_count,
      x_msg_data,
      x_return_status,
      ddx_choice_list_to_show);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    cs_tp_choices_pvt_w.rosetta_table_copy_out_p1(ddx_choice_list_to_show, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      );
  end;

  procedure update_choices(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR
    , p3_a0 JTF_NUMBER_TABLE
    , p3_a1 JTF_VARCHAR2_TABLE_1000
    , p3_a2 JTF_NUMBER_TABLE
    , p3_a3 JTF_NUMBER_TABLE
    , p3_a4 JTF_VARCHAR2_TABLE_100
    , p3_a5 JTF_VARCHAR2_TABLE_100
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_choices cs_tp_choices_pvt.choice_list;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    cs_tp_choices_pvt_w.rosetta_table_copy_in_p1(ddp_choices, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      );




    -- here's the delegated call to the old PL/SQL routine
    cs_tp_choices_pvt.update_choices(p_api_version_number,
      p_init_msg_list,
      p_commit,
      ddp_choices,
      x_msg_count,
      x_msg_data,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure add_freetext(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_freetext_id out nocopy  NUMBER
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  NUMBER := 0-1962.0724
    , p3_a2  VARCHAR2 := fnd_api.g_miss_char
    , p3_a3  NUMBER := 0-1962.0724
    , p3_a4  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_one_freetext cs_tp_choices_pvt.freetext;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_one_freetext.mfreetextid := rosetta_g_miss_num_map(p3_a0);
    ddp_one_freetext.mfreetextsize := rosetta_g_miss_num_map(p3_a1);
    ddp_one_freetext.mfreetextdefaulttext := p3_a2;
    ddp_one_freetext.mlookupid := rosetta_g_miss_num_map(p3_a3);
    ddp_one_freetext.mlast_updated_date := p3_a4;





    -- here's the delegated call to the old PL/SQL routine
    cs_tp_choices_pvt.add_freetext(p_api_version_number,
      p_init_msg_list,
      p_commit,
      ddp_one_freetext,
      x_msg_count,
      x_msg_data,
      x_return_status,
      x_freetext_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure show_freetext(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR
    , p_lookup_id  NUMBER
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  VARCHAR2
    , p7_a3 out nocopy  NUMBER
    , p7_a4 out nocopy  VARCHAR2
  )

  as
    ddx_freetext cs_tp_choices_pvt.freetext;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    -- here's the delegated call to the old PL/SQL routine
    cs_tp_choices_pvt.show_freetext(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_lookup_id,
      x_msg_count,
      x_msg_data,
      x_return_status,
      ddx_freetext);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddx_freetext.mfreetextid);
    p7_a1 := rosetta_g_miss_num_map(ddx_freetext.mfreetextsize);
    p7_a2 := ddx_freetext.mfreetextdefaulttext;
    p7_a3 := rosetta_g_miss_num_map(ddx_freetext.mlookupid);
    p7_a4 := ddx_freetext.mlast_updated_date;
  end;

end cs_tp_choices_pvt_w;

/
