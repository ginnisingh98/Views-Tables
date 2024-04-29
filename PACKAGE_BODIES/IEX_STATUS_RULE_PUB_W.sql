--------------------------------------------------------
--  DDL for Package Body IEX_STATUS_RULE_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_STATUS_RULE_PUB_W" as
  /* $Header: iexwcstb.pls 120.1 2005/07/06 14:10:34 schekuri noship $ */
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

  procedure rosetta_table_copy_in_p1(t out nocopy iex_status_rule_pub.status_rule_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_200
    , a3 JTF_DATE_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).status_rule_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).status_rule_name := a1(indx);
          t(ddindx).status_rule_description := a2(indx);
          t(ddindx).start_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).end_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).security_group_id := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a12(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t iex_status_rule_pub.status_rule_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_200();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_200();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
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
        a9.extend(t.count);
        a10.extend(t.count);
        a11.extend(t.count);
        a12.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).status_rule_id);
          a1(indx) := t(ddindx).status_rule_name;
          a2(indx) := t(ddindx).status_rule_description;
          a3(indx) := t(ddindx).start_date;
          a4(indx) := t(ddindx).end_date;
          a5(indx) := t(ddindx).last_update_date;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a7(indx) := t(ddindx).creation_date;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).security_group_id);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p3(t out nocopy iex_status_rule_pub.status_rule_line_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).status_rule_line_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).delinquency_status := a1(indx);
          t(ddindx).priority := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).enabled_flag := a3(indx);
          t(ddindx).status_rule_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).security_group_id := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a12(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t iex_status_rule_pub.status_rule_line_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
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
        a9.extend(t.count);
        a10.extend(t.count);
        a11.extend(t.count);
        a12.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).status_rule_line_id);
          a1(indx) := t(ddindx).delinquency_status;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).priority);
          a3(indx) := t(ddindx).enabled_flag;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).status_rule_id);
          a5(indx) := t(ddindx).last_update_date;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a7(indx) := t(ddindx).creation_date;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).security_group_id);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p4(t out nocopy iex_status_rule_pub.status_rule_id_tbl_type, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
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
  procedure rosetta_table_copy_out_p4(t iex_status_rule_pub.status_rule_id_tbl_type, a0 out nocopy JTF_NUMBER_TABLE) as
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

  procedure rosetta_table_copy_in_p5(t out nocopy iex_status_rule_pub.status_rule_line_id_tbl_type, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
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
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t iex_status_rule_pub.status_rule_line_id_tbl_type, a0 out nocopy JTF_NUMBER_TABLE) as
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure create_status_rule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_dup_status out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_status_rule_id out nocopy  NUMBER
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  VARCHAR2 := fnd_api.g_miss_char
    , p3_a2  VARCHAR2 := fnd_api.g_miss_char
    , p3_a3  DATE := fnd_api.g_miss_date
    , p3_a4  DATE := fnd_api.g_miss_date
    , p3_a5  DATE := fnd_api.g_miss_date
    , p3_a6  NUMBER := 0-1962.0724
    , p3_a7  DATE := fnd_api.g_miss_date
    , p3_a8  NUMBER := 0-1962.0724
    , p3_a9  NUMBER := 0-1962.0724
    , p3_a10  NUMBER := 0-1962.0724
    , p3_a11  NUMBER := 0-1962.0724
    , p3_a12  NUMBER := 0-1962.0724
  )

  as
    ddp_status_rule_rec iex_status_rule_pub.status_rule_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_status_rule_rec.status_rule_id := rosetta_g_miss_num_map(p3_a0);
    ddp_status_rule_rec.status_rule_name := p3_a1;
    ddp_status_rule_rec.status_rule_description := p3_a2;
    ddp_status_rule_rec.start_date := rosetta_g_miss_date_in_map(p3_a3);
    ddp_status_rule_rec.end_date := rosetta_g_miss_date_in_map(p3_a4);
    ddp_status_rule_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a5);
    ddp_status_rule_rec.last_updated_by := rosetta_g_miss_num_map(p3_a6);
    ddp_status_rule_rec.creation_date := rosetta_g_miss_date_in_map(p3_a7);
    ddp_status_rule_rec.created_by := rosetta_g_miss_num_map(p3_a8);
    ddp_status_rule_rec.last_update_login := rosetta_g_miss_num_map(p3_a9);
    ddp_status_rule_rec.program_id := rosetta_g_miss_num_map(p3_a10);
    ddp_status_rule_rec.security_group_id := rosetta_g_miss_num_map(p3_a11);
    ddp_status_rule_rec.object_version_number := rosetta_g_miss_num_map(p3_a12);






    -- here's the delegated call to the old PL/SQL routine
    iex_status_rule_pub.create_status_rule(p_api_version,
      p_init_msg_list,
      p_commit,
      ddp_status_rule_rec,
      x_dup_status,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_status_rule_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_status_rule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0 JTF_NUMBER_TABLE
    , p3_a1 JTF_VARCHAR2_TABLE_100
    , p3_a2 JTF_VARCHAR2_TABLE_200
    , p3_a3 JTF_DATE_TABLE
    , p3_a4 JTF_DATE_TABLE
    , p3_a5 JTF_DATE_TABLE
    , p3_a6 JTF_NUMBER_TABLE
    , p3_a7 JTF_DATE_TABLE
    , p3_a8 JTF_NUMBER_TABLE
    , p3_a9 JTF_NUMBER_TABLE
    , p3_a10 JTF_NUMBER_TABLE
    , p3_a11 JTF_NUMBER_TABLE
    , p3_a12 JTF_NUMBER_TABLE
    , x_dup_status out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_status_rule_tbl iex_status_rule_pub.status_rule_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    iex_status_rule_pub_w.rosetta_table_copy_in_p1(ddp_status_rule_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      , p3_a9
      , p3_a10
      , p3_a11
      , p3_a12
      );





    -- here's the delegated call to the old PL/SQL routine
    iex_status_rule_pub.update_status_rule(p_api_version,
      p_init_msg_list,
      p_commit,
      ddp_status_rule_tbl,
      x_dup_status,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure delete_status_rule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_status_rule_id_tbl JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_status_rule_id_tbl iex_status_rule_pub.status_rule_id_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    iex_status_rule_pub_w.rosetta_table_copy_in_p4(ddp_status_rule_id_tbl, p_status_rule_id_tbl);




    -- here's the delegated call to the old PL/SQL routine
    iex_status_rule_pub.delete_status_rule(p_api_version,
      p_init_msg_list,
      p_commit,
      ddp_status_rule_id_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure create_status_rule_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  VARCHAR2 := fnd_api.g_miss_char
    , p3_a2  NUMBER := 0-1962.0724
    , p3_a3  VARCHAR2 := fnd_api.g_miss_char
    , p3_a4  NUMBER := 0-1962.0724
    , p3_a5  DATE := fnd_api.g_miss_date
    , p3_a6  NUMBER := 0-1962.0724
    , p3_a7  DATE := fnd_api.g_miss_date
    , p3_a8  NUMBER := 0-1962.0724
    , p3_a9  NUMBER := 0-1962.0724
    , p3_a10  NUMBER := 0-1962.0724
    , p3_a11  NUMBER := 0-1962.0724
    , p3_a12  NUMBER := 0-1962.0724
  )

  as
    ddp_status_rule_line_rec iex_status_rule_pub.status_rule_line_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_status_rule_line_rec.status_rule_line_id := rosetta_g_miss_num_map(p3_a0);
    ddp_status_rule_line_rec.delinquency_status := p3_a1;
    ddp_status_rule_line_rec.priority := rosetta_g_miss_num_map(p3_a2);
    ddp_status_rule_line_rec.enabled_flag := p3_a3;
    ddp_status_rule_line_rec.status_rule_id := rosetta_g_miss_num_map(p3_a4);
    ddp_status_rule_line_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a5);
    ddp_status_rule_line_rec.last_updated_by := rosetta_g_miss_num_map(p3_a6);
    ddp_status_rule_line_rec.creation_date := rosetta_g_miss_date_in_map(p3_a7);
    ddp_status_rule_line_rec.created_by := rosetta_g_miss_num_map(p3_a8);
    ddp_status_rule_line_rec.last_update_login := rosetta_g_miss_num_map(p3_a9);
    ddp_status_rule_line_rec.program_id := rosetta_g_miss_num_map(p3_a10);
    ddp_status_rule_line_rec.security_group_id := rosetta_g_miss_num_map(p3_a11);
    ddp_status_rule_line_rec.object_version_number := rosetta_g_miss_num_map(p3_a12);




    -- here's the delegated call to the old PL/SQL routine
    iex_status_rule_pub.create_status_rule_line(p_api_version,
      p_init_msg_list,
      p_commit,
      ddp_status_rule_line_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure update_status_rule_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0 JTF_NUMBER_TABLE
    , p3_a1 JTF_VARCHAR2_TABLE_100
    , p3_a2 JTF_NUMBER_TABLE
    , p3_a3 JTF_VARCHAR2_TABLE_100
    , p3_a4 JTF_NUMBER_TABLE
    , p3_a5 JTF_DATE_TABLE
    , p3_a6 JTF_NUMBER_TABLE
    , p3_a7 JTF_DATE_TABLE
    , p3_a8 JTF_NUMBER_TABLE
    , p3_a9 JTF_NUMBER_TABLE
    , p3_a10 JTF_NUMBER_TABLE
    , p3_a11 JTF_NUMBER_TABLE
    , p3_a12 JTF_NUMBER_TABLE
    , x_dup_status out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_status_rule_line_tbl iex_status_rule_pub.status_rule_line_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    iex_status_rule_pub_w.rosetta_table_copy_in_p3(ddp_status_rule_line_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      , p3_a9
      , p3_a10
      , p3_a11
      , p3_a12
      );





    -- here's the delegated call to the old PL/SQL routine
    iex_status_rule_pub.update_status_rule_line(p_api_version,
      p_init_msg_list,
      p_commit,
      ddp_status_rule_line_tbl,
      x_dup_status,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure delete_status_rule_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_status_rule_id  NUMBER
    , p_status_rule_line_id_tbl JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_status_rule_line_id_tbl iex_status_rule_pub.status_rule_line_id_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    iex_status_rule_pub_w.rosetta_table_copy_in_p5(ddp_status_rule_line_id_tbl, p_status_rule_line_id_tbl);




    -- here's the delegated call to the old PL/SQL routine
    iex_status_rule_pub.delete_status_rule_line(p_api_version,
      p_init_msg_list,
      p_commit,
      p_status_rule_id,
      ddp_status_rule_line_id_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

end iex_status_rule_pub_w;

/
