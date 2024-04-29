--------------------------------------------------------
--  DDL for Package Body JTF_AMV_ITEM_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_AMV_ITEM_PUB_W" as
  /* $Header: jtfpitwb.pls 120.3 2005/09/13 11:09:54 vimohan ship $ */
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

  procedure rosetta_table_copy_in_p1(t out nocopy jtf_amv_item_pub.number_tab_type, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is null then
    t := null;
  elsif a0.count = 0 then
    t := jtf_amv_item_pub.number_tab_type();
  else
      if a0.count > 0 then
      t := jtf_amv_item_pub.number_tab_type();
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
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t jtf_amv_item_pub.number_tab_type, a0 out nocopy JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p2(t out nocopy jtf_amv_item_pub.char_tab_type, a0 JTF_VARCHAR2_TABLE_200) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is null then
    t := null;
  elsif a0.count = 0 then
    t := jtf_amv_item_pub.char_tab_type();
  else
      if a0.count > 0 then
      t := jtf_amv_item_pub.char_tab_type();
      t.extend(a0.count);
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
  procedure rosetta_table_copy_out_p2(t jtf_amv_item_pub.char_tab_type, a0 out nocopy JTF_VARCHAR2_TABLE_200) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
  elsif t.count = 0 then
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
  end rosetta_table_copy_out_p2;

  procedure create_item(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_item_id out nocopy  NUMBER
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  DATE := fnd_api.g_miss_date
    , p6_a2  NUMBER := 0-1962.0724
    , p6_a3  DATE := fnd_api.g_miss_date
    , p6_a4  NUMBER := 0-1962.0724
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  VARCHAR2 := fnd_api.g_miss_char
    , p6_a9  VARCHAR2 := fnd_api.g_miss_char
    , p6_a10  VARCHAR2 := fnd_api.g_miss_char
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  VARCHAR2 := fnd_api.g_miss_char
    , p6_a14  DATE := fnd_api.g_miss_date
    , p6_a15  DATE := fnd_api.g_miss_date
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
    , p6_a17  VARCHAR2 := fnd_api.g_miss_char
    , p6_a18  DATE := fnd_api.g_miss_date
    , p6_a19  VARCHAR2 := fnd_api.g_miss_char
    , p6_a20  NUMBER := 0-1962.0724
    , p6_a21  NUMBER := 0-1962.0724
    , p6_a22  NUMBER := 0-1962.0724
    , p6_a23  VARCHAR2 := fnd_api.g_miss_char
    , p6_a24  VARCHAR2 := fnd_api.g_miss_char
    , p6_a25  VARCHAR2 := fnd_api.g_miss_char
    , p6_a26  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_item_rec jtf_amv_item_pub.item_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_item_rec.item_id := rosetta_g_miss_num_map(p6_a0);
    ddp_item_rec.creation_date := rosetta_g_miss_date_in_map(p6_a1);
    ddp_item_rec.created_by := rosetta_g_miss_num_map(p6_a2);
    ddp_item_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a3);
    ddp_item_rec.last_updated_by := rosetta_g_miss_num_map(p6_a4);
    ddp_item_rec.last_update_login := rosetta_g_miss_num_map(p6_a5);
    ddp_item_rec.object_version_number := rosetta_g_miss_num_map(p6_a6);
    ddp_item_rec.application_id := rosetta_g_miss_num_map(p6_a7);
    ddp_item_rec.external_access_flag := p6_a8;
    ddp_item_rec.item_name := p6_a9;
    ddp_item_rec.description := p6_a10;
    ddp_item_rec.text_string := p6_a11;
    ddp_item_rec.language_code := p6_a12;
    ddp_item_rec.status_code := p6_a13;
    ddp_item_rec.effective_start_date := rosetta_g_miss_date_in_map(p6_a14);
    ddp_item_rec.expiration_date := rosetta_g_miss_date_in_map(p6_a15);
    ddp_item_rec.item_type := p6_a16;
    ddp_item_rec.url_string := p6_a17;
    ddp_item_rec.publication_date := rosetta_g_miss_date_in_map(p6_a18);
    ddp_item_rec.priority := p6_a19;
    ddp_item_rec.content_type_id := rosetta_g_miss_num_map(p6_a20);
    ddp_item_rec.owner_id := rosetta_g_miss_num_map(p6_a21);
    ddp_item_rec.default_approver_id := rosetta_g_miss_num_map(p6_a22);
    ddp_item_rec.item_destination_type := p6_a23;
    ddp_item_rec.access_name := p6_a24;
    ddp_item_rec.deliverable_type_code := p6_a25;
    ddp_item_rec.applicable_to_code := p6_a26;


    -- here's the delegated call to the old PL/SQL routine
    jtf_amv_item_pub.create_item(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_item_rec,
      x_item_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure update_item(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  DATE := fnd_api.g_miss_date
    , p6_a2  NUMBER := 0-1962.0724
    , p6_a3  DATE := fnd_api.g_miss_date
    , p6_a4  NUMBER := 0-1962.0724
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  VARCHAR2 := fnd_api.g_miss_char
    , p6_a9  VARCHAR2 := fnd_api.g_miss_char
    , p6_a10  VARCHAR2 := fnd_api.g_miss_char
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  VARCHAR2 := fnd_api.g_miss_char
    , p6_a14  DATE := fnd_api.g_miss_date
    , p6_a15  DATE := fnd_api.g_miss_date
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
    , p6_a17  VARCHAR2 := fnd_api.g_miss_char
    , p6_a18  DATE := fnd_api.g_miss_date
    , p6_a19  VARCHAR2 := fnd_api.g_miss_char
    , p6_a20  NUMBER := 0-1962.0724
    , p6_a21  NUMBER := 0-1962.0724
    , p6_a22  NUMBER := 0-1962.0724
    , p6_a23  VARCHAR2 := fnd_api.g_miss_char
    , p6_a24  VARCHAR2 := fnd_api.g_miss_char
    , p6_a25  VARCHAR2 := fnd_api.g_miss_char
    , p6_a26  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_item_rec jtf_amv_item_pub.item_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_item_rec.item_id := rosetta_g_miss_num_map(p6_a0);
    ddp_item_rec.creation_date := rosetta_g_miss_date_in_map(p6_a1);
    ddp_item_rec.created_by := rosetta_g_miss_num_map(p6_a2);
    ddp_item_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a3);
    ddp_item_rec.last_updated_by := rosetta_g_miss_num_map(p6_a4);
    ddp_item_rec.last_update_login := rosetta_g_miss_num_map(p6_a5);
    ddp_item_rec.object_version_number := rosetta_g_miss_num_map(p6_a6);
    ddp_item_rec.application_id := rosetta_g_miss_num_map(p6_a7);
    ddp_item_rec.external_access_flag := p6_a8;
    ddp_item_rec.item_name := p6_a9;
    ddp_item_rec.description := p6_a10;
    ddp_item_rec.text_string := p6_a11;
    ddp_item_rec.language_code := p6_a12;
    ddp_item_rec.status_code := p6_a13;
    ddp_item_rec.effective_start_date := rosetta_g_miss_date_in_map(p6_a14);
    ddp_item_rec.expiration_date := rosetta_g_miss_date_in_map(p6_a15);
    ddp_item_rec.item_type := p6_a16;
    ddp_item_rec.url_string := p6_a17;
    ddp_item_rec.publication_date := rosetta_g_miss_date_in_map(p6_a18);
    ddp_item_rec.priority := p6_a19;
    ddp_item_rec.content_type_id := rosetta_g_miss_num_map(p6_a20);
    ddp_item_rec.owner_id := rosetta_g_miss_num_map(p6_a21);
    ddp_item_rec.default_approver_id := rosetta_g_miss_num_map(p6_a22);
    ddp_item_rec.item_destination_type := p6_a23;
    ddp_item_rec.access_name := p6_a24;
    ddp_item_rec.deliverable_type_code := p6_a25;
    ddp_item_rec.applicable_to_code := p6_a26;

    -- here's the delegated call to the old PL/SQL routine
    jtf_amv_item_pub.update_item(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_item_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure get_item(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_item_id  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  DATE
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  DATE
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  DATE
    , p6_a15 out nocopy  DATE
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  DATE
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
  )

  as
    ddx_item_rec jtf_amv_item_pub.item_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    jtf_amv_item_pub.get_item(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_item_id,
      ddx_item_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_item_rec.item_id);
    p6_a1 := ddx_item_rec.creation_date;
    p6_a2 := rosetta_g_miss_num_map(ddx_item_rec.created_by);
    p6_a3 := ddx_item_rec.last_update_date;
    p6_a4 := rosetta_g_miss_num_map(ddx_item_rec.last_updated_by);
    p6_a5 := rosetta_g_miss_num_map(ddx_item_rec.last_update_login);
    p6_a6 := rosetta_g_miss_num_map(ddx_item_rec.object_version_number);
    p6_a7 := rosetta_g_miss_num_map(ddx_item_rec.application_id);
    p6_a8 := ddx_item_rec.external_access_flag;
    p6_a9 := ddx_item_rec.item_name;
    p6_a10 := ddx_item_rec.description;
    p6_a11 := ddx_item_rec.text_string;
    p6_a12 := ddx_item_rec.language_code;
    p6_a13 := ddx_item_rec.status_code;
    p6_a14 := ddx_item_rec.effective_start_date;
    p6_a15 := ddx_item_rec.expiration_date;
    p6_a16 := ddx_item_rec.item_type;
    p6_a17 := ddx_item_rec.url_string;
    p6_a18 := ddx_item_rec.publication_date;
    p6_a19 := ddx_item_rec.priority;
    p6_a20 := rosetta_g_miss_num_map(ddx_item_rec.content_type_id);
    p6_a21 := rosetta_g_miss_num_map(ddx_item_rec.owner_id);
    p6_a22 := rosetta_g_miss_num_map(ddx_item_rec.default_approver_id);
    p6_a23 := ddx_item_rec.item_destination_type;
    p6_a24 := ddx_item_rec.access_name;
    p6_a25 := ddx_item_rec.deliverable_type_code;
    p6_a26 := ddx_item_rec.applicable_to_code;
  end;

  procedure add_itemkeyword(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_item_id  NUMBER
    , p_keyword_tab JTF_VARCHAR2_TABLE_200
  )

  as
    ddp_keyword_tab jtf_amv_item_pub.char_tab_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    jtf_amv_item_pub_w.rosetta_table_copy_in_p2(ddp_keyword_tab, p_keyword_tab);

    -- here's the delegated call to the old PL/SQL routine
    jtf_amv_item_pub.add_itemkeyword(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_item_id,
      ddp_keyword_tab);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure delete_itemkeyword(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_item_id  NUMBER
    , p_keyword_tab JTF_VARCHAR2_TABLE_200
  )

  as
    ddp_keyword_tab jtf_amv_item_pub.char_tab_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    jtf_amv_item_pub_w.rosetta_table_copy_in_p2(ddp_keyword_tab, p_keyword_tab);

    -- here's the delegated call to the old PL/SQL routine
    jtf_amv_item_pub.delete_itemkeyword(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_item_id,
      ddp_keyword_tab);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure replace_itemkeyword(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_item_id  NUMBER
    , p_keyword_tab JTF_VARCHAR2_TABLE_200
  )

  as
    ddp_keyword_tab jtf_amv_item_pub.char_tab_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    jtf_amv_item_pub_w.rosetta_table_copy_in_p2(ddp_keyword_tab, p_keyword_tab);

    -- here's the delegated call to the old PL/SQL routine
    jtf_amv_item_pub.replace_itemkeyword(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_item_id,
      ddp_keyword_tab);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure get_itemkeyword(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_item_id  NUMBER
    , x_keyword_tab out nocopy JTF_VARCHAR2_TABLE_200
  )

  as
    ddx_keyword_tab jtf_amv_item_pub.char_tab_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    jtf_amv_item_pub.get_itemkeyword(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_item_id,
      ddx_keyword_tab);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    jtf_amv_item_pub_w.rosetta_table_copy_out_p2(ddx_keyword_tab, x_keyword_tab);
  end;

  procedure add_itemauthor(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_item_id  NUMBER
    , p_author_tab JTF_VARCHAR2_TABLE_200
  )

  as
    ddp_author_tab jtf_amv_item_pub.char_tab_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    jtf_amv_item_pub_w.rosetta_table_copy_in_p2(ddp_author_tab, p_author_tab);

    -- here's the delegated call to the old PL/SQL routine
    jtf_amv_item_pub.add_itemauthor(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_item_id,
      ddp_author_tab);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure delete_itemauthor(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_item_id  NUMBER
    , p_author_tab JTF_VARCHAR2_TABLE_200
  )

  as
    ddp_author_tab jtf_amv_item_pub.char_tab_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    jtf_amv_item_pub_w.rosetta_table_copy_in_p2(ddp_author_tab, p_author_tab);

    -- here's the delegated call to the old PL/SQL routine
    jtf_amv_item_pub.delete_itemauthor(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_item_id,
      ddp_author_tab);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure replace_itemauthor(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_item_id  NUMBER
    , p_author_tab JTF_VARCHAR2_TABLE_200
  )

  as
    ddp_author_tab jtf_amv_item_pub.char_tab_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    jtf_amv_item_pub_w.rosetta_table_copy_in_p2(ddp_author_tab, p_author_tab);

    -- here's the delegated call to the old PL/SQL routine
    jtf_amv_item_pub.replace_itemauthor(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_item_id,
      ddp_author_tab);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure get_itemauthor(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_item_id  NUMBER
    , x_author_tab out nocopy JTF_VARCHAR2_TABLE_200
  )

  as
    ddx_author_tab jtf_amv_item_pub.char_tab_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    jtf_amv_item_pub.get_itemauthor(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_item_id,
      ddx_author_tab);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    jtf_amv_item_pub_w.rosetta_table_copy_out_p2(ddx_author_tab, x_author_tab);
  end;

end jtf_amv_item_pub_w;

/
