--------------------------------------------------------
--  DDL for Package Body AS_SCORECARD_RULES_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_SCORECARD_RULES_PUB_W" as
  /* $Header: asxwscob.pls 120.2 2006/03/09 15:41 solin ship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy as_scorecard_rules_pub.cardrule_qual_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_DATE_TABLE
    , a16 JTF_DATE_TABLE
    , a17 JTF_DATE_TABLE
    , a18 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).qual_value_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a1(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).scorecard_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).score := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).card_rule_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).seed_qual_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).high_value_number := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).low_value_number := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).high_value_char := a12(indx);
          t(ddindx).low_value_char := a13(indx);
          t(ddindx).currency_code := a14(indx);
          t(ddindx).low_value_date := rosetta_g_miss_date_in_map(a15(indx));
          t(ddindx).high_value_date := rosetta_g_miss_date_in_map(a16(indx));
          t(ddindx).start_date_active := rosetta_g_miss_date_in_map(a17(indx));
          t(ddindx).end_date_active := rosetta_g_miss_date_in_map(a18(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t as_scorecard_rules_pub.cardrule_qual_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_DATE_TABLE
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_DATE_TABLE
    , a18 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_DATE_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_DATE_TABLE();
    a16 := JTF_DATE_TABLE();
    a17 := JTF_DATE_TABLE();
    a18 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_DATE_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_DATE_TABLE();
      a16 := JTF_DATE_TABLE();
      a17 := JTF_DATE_TABLE();
      a18 := JTF_DATE_TABLE();
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
        a13.extend(t.count);
        a14.extend(t.count);
        a15.extend(t.count);
        a16.extend(t.count);
        a17.extend(t.count);
        a18.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).qual_value_id);
          a1(indx) := t(ddindx).last_update_date;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a3(indx) := t(ddindx).creation_date;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).scorecard_id);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).score);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).card_rule_id);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).seed_qual_id);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).high_value_number);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).low_value_number);
          a12(indx) := t(ddindx).high_value_char;
          a13(indx) := t(ddindx).low_value_char;
          a14(indx) := t(ddindx).currency_code;
          a15(indx) := t(ddindx).low_value_date;
          a16(indx) := t(ddindx).high_value_date;
          a17(indx) := t(ddindx).start_date_active;
          a18(indx) := t(ddindx).end_date_active;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure create_scorecard(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_scorecard_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  DATE := fnd_api.g_miss_date
    , p7_a9  DATE := fnd_api.g_miss_date
  )

  as
    ddp_scorecard_rec as_scorecard_rules_pub.scorecard_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_scorecard_rec.scorecard_id := rosetta_g_miss_num_map(p7_a0);
    ddp_scorecard_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_scorecard_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_scorecard_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_scorecard_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_scorecard_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_scorecard_rec.description := p7_a6;
    ddp_scorecard_rec.enabled_flag := p7_a7;
    ddp_scorecard_rec.start_date_active := rosetta_g_miss_date_in_map(p7_a8);
    ddp_scorecard_rec.end_date_active := rosetta_g_miss_date_in_map(p7_a9);


    -- here's the delegated call to the old PL/SQL routine
    as_scorecard_rules_pub.create_scorecard(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_scorecard_rec,
      x_scorecard_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_scorecard(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  DATE := fnd_api.g_miss_date
    , p7_a9  DATE := fnd_api.g_miss_date
  )

  as
    ddp_scorecard_rec as_scorecard_rules_pub.scorecard_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_scorecard_rec.scorecard_id := rosetta_g_miss_num_map(p7_a0);
    ddp_scorecard_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_scorecard_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_scorecard_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_scorecard_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_scorecard_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_scorecard_rec.description := p7_a6;
    ddp_scorecard_rec.enabled_flag := p7_a7;
    ddp_scorecard_rec.start_date_active := rosetta_g_miss_date_in_map(p7_a8);
    ddp_scorecard_rec.end_date_active := rosetta_g_miss_date_in_map(p7_a9);

    -- here's the delegated call to the old PL/SQL routine
    as_scorecard_rules_pub.update_scorecard(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_scorecard_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure create_cardrule_qual(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_qual_value_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  DATE := fnd_api.g_miss_date
    , p7_a16  DATE := fnd_api.g_miss_date
    , p7_a17  DATE := fnd_api.g_miss_date
    , p7_a18  DATE := fnd_api.g_miss_date
  )

  as
    ddp_cardrule_qual_rec as_scorecard_rules_pub.cardrule_qual_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_cardrule_qual_rec.qual_value_id := rosetta_g_miss_num_map(p7_a0);
    ddp_cardrule_qual_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_cardrule_qual_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_cardrule_qual_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_cardrule_qual_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_cardrule_qual_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_cardrule_qual_rec.scorecard_id := rosetta_g_miss_num_map(p7_a6);
    ddp_cardrule_qual_rec.score := rosetta_g_miss_num_map(p7_a7);
    ddp_cardrule_qual_rec.card_rule_id := rosetta_g_miss_num_map(p7_a8);
    ddp_cardrule_qual_rec.seed_qual_id := rosetta_g_miss_num_map(p7_a9);
    ddp_cardrule_qual_rec.high_value_number := rosetta_g_miss_num_map(p7_a10);
    ddp_cardrule_qual_rec.low_value_number := rosetta_g_miss_num_map(p7_a11);
    ddp_cardrule_qual_rec.high_value_char := p7_a12;
    ddp_cardrule_qual_rec.low_value_char := p7_a13;
    ddp_cardrule_qual_rec.currency_code := p7_a14;
    ddp_cardrule_qual_rec.low_value_date := rosetta_g_miss_date_in_map(p7_a15);
    ddp_cardrule_qual_rec.high_value_date := rosetta_g_miss_date_in_map(p7_a16);
    ddp_cardrule_qual_rec.start_date_active := rosetta_g_miss_date_in_map(p7_a17);
    ddp_cardrule_qual_rec.end_date_active := rosetta_g_miss_date_in_map(p7_a18);


    -- here's the delegated call to the old PL/SQL routine
    as_scorecard_rules_pub.create_cardrule_qual(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cardrule_qual_rec,
      x_qual_value_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_cardrule_qual(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  DATE := fnd_api.g_miss_date
    , p7_a16  DATE := fnd_api.g_miss_date
    , p7_a17  DATE := fnd_api.g_miss_date
    , p7_a18  DATE := fnd_api.g_miss_date
  )

  as
    ddp_cardrule_qual_rec as_scorecard_rules_pub.cardrule_qual_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_cardrule_qual_rec.qual_value_id := rosetta_g_miss_num_map(p7_a0);
    ddp_cardrule_qual_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_cardrule_qual_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_cardrule_qual_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_cardrule_qual_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_cardrule_qual_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_cardrule_qual_rec.scorecard_id := rosetta_g_miss_num_map(p7_a6);
    ddp_cardrule_qual_rec.score := rosetta_g_miss_num_map(p7_a7);
    ddp_cardrule_qual_rec.card_rule_id := rosetta_g_miss_num_map(p7_a8);
    ddp_cardrule_qual_rec.seed_qual_id := rosetta_g_miss_num_map(p7_a9);
    ddp_cardrule_qual_rec.high_value_number := rosetta_g_miss_num_map(p7_a10);
    ddp_cardrule_qual_rec.low_value_number := rosetta_g_miss_num_map(p7_a11);
    ddp_cardrule_qual_rec.high_value_char := p7_a12;
    ddp_cardrule_qual_rec.low_value_char := p7_a13;
    ddp_cardrule_qual_rec.currency_code := p7_a14;
    ddp_cardrule_qual_rec.low_value_date := rosetta_g_miss_date_in_map(p7_a15);
    ddp_cardrule_qual_rec.high_value_date := rosetta_g_miss_date_in_map(p7_a16);
    ddp_cardrule_qual_rec.start_date_active := rosetta_g_miss_date_in_map(p7_a17);
    ddp_cardrule_qual_rec.end_date_active := rosetta_g_miss_date_in_map(p7_a18);

    -- here's the delegated call to the old PL/SQL routine
    as_scorecard_rules_pub.update_cardrule_qual(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cardrule_qual_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

end as_scorecard_rules_pub_w;

/
