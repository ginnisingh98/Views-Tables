--------------------------------------------------------
--  DDL for Package Body CS_TP_QUESTIONS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_TP_QUESTIONS_PVT_W" as
  /* $Header: cstprqsb.pls 120.2 2005/06/30 11:04 appldev ship $ */
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

  procedure rosetta_table_copy_in_p1(t out nocopy cs_tp_questions_pvt.question_list, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_2000
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
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
          t(ddindx).mquestionid := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).mquestionname := a1(indx);
          t(ddindx).manswertype := a2(indx);
          t(ddindx).mmandatoryflag := a3(indx);
          t(ddindx).mscoringflag := a4(indx);
          t(ddindx).mlookupid := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).mlast_updated_date := a6(indx);
          t(ddindx).mnotetype := a7(indx);
          t(ddindx).mshowoncreationflag := a8(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t cs_tp_questions_pvt.question_list, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_2000
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_2000();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_2000();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).mquestionid);
          a1(indx) := t(ddindx).mquestionname;
          a2(indx) := t(ddindx).manswertype;
          a3(indx) := t(ddindx).mmandatoryflag;
          a4(indx) := t(ddindx).mscoringflag;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).mlookupid);
          a6(indx) := t(ddindx).mlast_updated_date;
          a7(indx) := t(ddindx).mnotetype;
          a8(indx) := t(ddindx).mshowoncreationflag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure add_question(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR
    , p_template_id  NUMBER
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_question_id out nocopy  NUMBER
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  VARCHAR2 := fnd_api.g_miss_char
    , p3_a2  VARCHAR2 := fnd_api.g_miss_char
    , p3_a3  VARCHAR2 := fnd_api.g_miss_char
    , p3_a4  VARCHAR2 := fnd_api.g_miss_char
    , p3_a5  NUMBER := 0-1962.0724
    , p3_a6  VARCHAR2 := fnd_api.g_miss_char
    , p3_a7  VARCHAR2 := fnd_api.g_miss_char
    , p3_a8  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_one_question cs_tp_questions_pvt.question;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_one_question.mquestionid := rosetta_g_miss_num_map(p3_a0);
    ddp_one_question.mquestionname := p3_a1;
    ddp_one_question.manswertype := p3_a2;
    ddp_one_question.mmandatoryflag := p3_a3;
    ddp_one_question.mscoringflag := p3_a4;
    ddp_one_question.mlookupid := rosetta_g_miss_num_map(p3_a5);
    ddp_one_question.mlast_updated_date := p3_a6;
    ddp_one_question.mnotetype := p3_a7;
    ddp_one_question.mshowoncreationflag := p3_a8;






    -- here's the delegated call to the old PL/SQL routine
    cs_tp_questions_pvt.add_question(p_api_version_number,
      p_init_msg_list,
      p_commit,
      ddp_one_question,
      p_template_id,
      x_msg_count,
      x_msg_data,
      x_return_status,
      x_question_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_question(p_api_version_number  NUMBER
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
    , p3_a5  NUMBER := 0-1962.0724
    , p3_a6  VARCHAR2 := fnd_api.g_miss_char
    , p3_a7  VARCHAR2 := fnd_api.g_miss_char
    , p3_a8  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_one_question cs_tp_questions_pvt.question;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_one_question.mquestionid := rosetta_g_miss_num_map(p3_a0);
    ddp_one_question.mquestionname := p3_a1;
    ddp_one_question.manswertype := p3_a2;
    ddp_one_question.mmandatoryflag := p3_a3;
    ddp_one_question.mscoringflag := p3_a4;
    ddp_one_question.mlookupid := rosetta_g_miss_num_map(p3_a5);
    ddp_one_question.mlast_updated_date := p3_a6;
    ddp_one_question.mnotetype := p3_a7;
    ddp_one_question.mshowoncreationflag := p3_a8;




    -- here's the delegated call to the old PL/SQL routine
    cs_tp_questions_pvt.update_question(p_api_version_number,
      p_init_msg_list,
      p_commit,
      ddp_one_question,
      x_msg_count,
      x_msg_data,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure sort_questions(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR
    , p3_a0 JTF_NUMBER_TABLE
    , p3_a1 JTF_VARCHAR2_TABLE_2000
    , p3_a2 JTF_VARCHAR2_TABLE_100
    , p3_a3 JTF_VARCHAR2_TABLE_100
    , p3_a4 JTF_VARCHAR2_TABLE_100
    , p3_a5 JTF_NUMBER_TABLE
    , p3_a6 JTF_VARCHAR2_TABLE_100
    , p3_a7 JTF_VARCHAR2_TABLE_100
    , p3_a8 JTF_VARCHAR2_TABLE_100
    , p_template_id  NUMBER
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_questions cs_tp_questions_pvt.question_list;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    cs_tp_questions_pvt_w.rosetta_table_copy_in_p1(ddp_questions, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      );





    -- here's the delegated call to the old PL/SQL routine
    cs_tp_questions_pvt.sort_questions(p_api_version_number,
      p_init_msg_list,
      p_commit,
      ddp_questions,
      p_template_id,
      x_msg_count,
      x_msg_data,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure show_questions(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR
    , p_template_id  NUMBER
    , p_start_question  NUMBER
    , p_end_question  NUMBER
    , p_display_order  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_VARCHAR2_TABLE_2000
    , p10_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a5 out nocopy JTF_NUMBER_TABLE
    , p10_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , x_total_questions out nocopy  NUMBER
    , x_retrieved_question_number out nocopy  NUMBER
  )

  as
    ddx_question_list_to_show cs_tp_questions_pvt.question_list;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any













    -- here's the delegated call to the old PL/SQL routine
    cs_tp_questions_pvt.show_questions(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_template_id,
      p_start_question,
      p_end_question,
      p_display_order,
      x_msg_count,
      x_msg_data,
      x_return_status,
      ddx_question_list_to_show,
      x_total_questions,
      x_retrieved_question_number);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    cs_tp_questions_pvt_w.rosetta_table_copy_out_p1(ddx_question_list_to_show, p10_a0
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

  procedure show_question(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR
    , p_question_id  NUMBER
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  VARCHAR2
    , p7_a2 out nocopy  VARCHAR2
    , p7_a3 out nocopy  VARCHAR2
    , p7_a4 out nocopy  VARCHAR2
    , p7_a5 out nocopy  NUMBER
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  VARCHAR2
    , p7_a8 out nocopy  VARCHAR2
  )

  as
    ddx_question_to_show cs_tp_questions_pvt.question;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    -- here's the delegated call to the old PL/SQL routine
    cs_tp_questions_pvt.show_question(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_question_id,
      x_msg_count,
      x_msg_data,
      x_return_status,
      ddx_question_to_show);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddx_question_to_show.mquestionid);
    p7_a1 := ddx_question_to_show.mquestionname;
    p7_a2 := ddx_question_to_show.manswertype;
    p7_a3 := ddx_question_to_show.mmandatoryflag;
    p7_a4 := ddx_question_to_show.mscoringflag;
    p7_a5 := rosetta_g_miss_num_map(ddx_question_to_show.mlookupid);
    p7_a6 := ddx_question_to_show.mlast_updated_date;
    p7_a7 := ddx_question_to_show.mnotetype;
    p7_a8 := ddx_question_to_show.mshowoncreationflag;
  end;

end cs_tp_questions_pvt_w;

/
