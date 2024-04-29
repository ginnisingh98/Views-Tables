--------------------------------------------------------
--  DDL for Package Body JTF_TASK_RECURRENCES_PUB_OA_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_RECURRENCES_PUB_OA_W" as
  /* $Header: jtfbtkub.pls 115.1 2003/09/23 22:45:26 twan noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy jtf_task_recurrences_pub.output_dates_rec, a0 JTF_DATE_TABLE) as
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
  procedure rosetta_table_copy_out_p1(t jtf_task_recurrences_pub.output_dates_rec, a0 out nocopy JTF_DATE_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_DATE_TABLE();
  else
      a0 := JTF_DATE_TABLE();
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

  procedure create_task_recurrence(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_task_id  NUMBER
    , p_task_number  VARCHAR2
    , p_occurs_which  INTEGER
    , p_template_flag  VARCHAR2
    , p_day_of_week  INTEGER
    , p_date_of_month  INTEGER
    , p_occurs_month  INTEGER
    , p_occurs_uom  VARCHAR2
    , p_occurs_every  INTEGER
    , p_occurs_number  INTEGER
    , p_start_date_active  DATE
    , p_end_date_active  DATE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_recurrence_rule_id out nocopy  NUMBER
    , p19_a0 out nocopy  NUMBER
    , p19_a1 out nocopy  NUMBER
    , p19_a2 out nocopy  VARCHAR2
    , x_reccurences_generated out nocopy  INTEGER
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
    , p_sunday  VARCHAR2
    , p_monday  VARCHAR2
    , p_tuesday  VARCHAR2
    , p_wednesday  VARCHAR2
    , p_thursday  VARCHAR2
    , p_friday  VARCHAR2
    , p_saturday  VARCHAR2
  )

  as
    ddx_task_rec jtf_task_recurrences_pub.task_details_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any












































    -- here's the delegated call to the old PL/SQL routine
    jtf_task_recurrences_pub.create_task_recurrence(p_api_version,
      p_init_msg_list,
      p_commit,
      p_task_id,
      p_task_number,
      p_occurs_which,
      p_template_flag,
      p_day_of_week,
      p_date_of_month,
      p_occurs_month,
      p_occurs_uom,
      p_occurs_every,
      p_occurs_number,
      p_start_date_active,
      p_end_date_active,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_recurrence_rule_id,
      ddx_task_rec,
      x_reccurences_generated,
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
      p_sunday,
      p_monday,
      p_tuesday,
      p_wednesday,
      p_thursday,
      p_friday,
      p_saturday);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



















    p19_a0 := ddx_task_rec.task_id;
    p19_a1 := ddx_task_rec.task_number;
    p19_a2 := ddx_task_rec.task_name;
























  end;

end jtf_task_recurrences_pub_oa_w;

/
