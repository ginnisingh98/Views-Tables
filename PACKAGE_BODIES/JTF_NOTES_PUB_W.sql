--------------------------------------------------------
--  DDL for Package Body JTF_NOTES_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_NOTES_PUB_W" as
  /* $Header: jtfntswb.pls 120.2 2006/04/26 23:08 mpadhiar ship $ */
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

  procedure rosetta_table_copy_in_p1(t out nocopy jtf_notes_pub.jtf_note_contexts_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).note_context_id := a0(indx);
          t(ddindx).jtf_note_id := a1(indx);
          t(ddindx).note_context_type := a2(indx);
          t(ddindx).note_context_type_id := a3(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).last_updated_by := a5(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).created_by := a7(indx);
          t(ddindx).last_update_login := a8(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t jtf_notes_pub.jtf_note_contexts_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_300();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
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
          a0(indx) := t(ddindx).note_context_id;
          a1(indx) := t(ddindx).jtf_note_id;
          a2(indx) := t(ddindx).note_context_type;
          a3(indx) := t(ddindx).note_context_type_id;
          a4(indx) := t(ddindx).last_update_date;
          a5(indx) := t(ddindx).last_updated_by;
          a6(indx) := t(ddindx).creation_date;
          a7(indx) := t(ddindx).created_by;
          a8(indx) := t(ddindx).last_update_login;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure create_note(p_parent_note_id  NUMBER
    , p_jtf_note_id  NUMBER
    , p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_org_id  NUMBER
    , p_source_object_id  NUMBER
    , p_source_object_code  VARCHAR2
    , p_notes  VARCHAR2
    , p_notes_detail  VARCHAR2
    , p_note_status  VARCHAR2
    , p_entered_by  NUMBER
    , p_entered_date  date
    , x_jtf_note_id out nocopy  NUMBER
    , p_last_update_date  date
    , p_last_updated_by  NUMBER
    , p_creation_date  date
    , p_created_by  NUMBER
    , p_last_update_login  NUMBER
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
    , p_context  VARCHAR2
    , p_note_type  VARCHAR2
    , p40_a0 JTF_NUMBER_TABLE
    , p40_a1 JTF_NUMBER_TABLE
    , p40_a2 JTF_VARCHAR2_TABLE_300
    , p40_a3 JTF_NUMBER_TABLE
    , p40_a4 JTF_DATE_TABLE
    , p40_a5 JTF_NUMBER_TABLE
    , p40_a6 JTF_DATE_TABLE
    , p40_a7 JTF_NUMBER_TABLE
    , p40_a8 JTF_NUMBER_TABLE
  )

  as
    ddp_entered_date date;
    ddp_last_update_date date;
    ddp_creation_date date;
    ddp_jtf_note_contexts_tab jtf_notes_pub.jtf_note_contexts_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
















    ddp_entered_date := rosetta_g_miss_date_in_map(p_entered_date);


    ddp_last_update_date := rosetta_g_miss_date_in_map(p_last_update_date);


    ddp_creation_date := rosetta_g_miss_date_in_map(p_creation_date);




















    jtf_notes_pub_w.rosetta_table_copy_in_p1(ddp_jtf_note_contexts_tab, p40_a0
      , p40_a1
      , p40_a2
      , p40_a3
      , p40_a4
      , p40_a5
      , p40_a6
      , p40_a7
      , p40_a8
      );

    -- here's the delegated call to the old PL/SQL routine
    jtf_notes_pub.create_note(p_parent_note_id,
      p_jtf_note_id,
      p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_org_id,
      p_source_object_id,
      p_source_object_code,
      p_notes,
      p_notes_detail,
      p_note_status,
      p_entered_by,
      ddp_entered_date,
      x_jtf_note_id,
      ddp_last_update_date,
      p_last_updated_by,
      ddp_creation_date,
      p_created_by,
      p_last_update_login,
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
      p_context,
      p_note_type,
      ddp_jtf_note_contexts_tab);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








































  end;

  procedure update_note(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_jtf_note_id  NUMBER
    , p_entered_by  NUMBER
    , p_last_updated_by  NUMBER
    , p_last_update_date  date
    , p_last_update_login  NUMBER
    , p_notes  VARCHAR2
    , p_notes_detail  VARCHAR2
    , p_append_flag  VARCHAR2
    , p_note_status  VARCHAR2
    , p_note_type  VARCHAR2
    , p17_a0 JTF_NUMBER_TABLE
    , p17_a1 JTF_NUMBER_TABLE
    , p17_a2 JTF_VARCHAR2_TABLE_300
    , p17_a3 JTF_NUMBER_TABLE
    , p17_a4 JTF_DATE_TABLE
    , p17_a5 JTF_NUMBER_TABLE
    , p17_a6 JTF_DATE_TABLE
    , p17_a7 JTF_NUMBER_TABLE
    , p17_a8 JTF_NUMBER_TABLE
  )

  as
    ddp_last_update_date date;
    ddp_jtf_note_contexts_tab jtf_notes_pub.jtf_note_contexts_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ddp_last_update_date := rosetta_g_miss_date_in_map(p_last_update_date);







    jtf_notes_pub_w.rosetta_table_copy_in_p1(ddp_jtf_note_contexts_tab, p17_a0
      , p17_a1
      , p17_a2
      , p17_a3
      , p17_a4
      , p17_a5
      , p17_a6
      , p17_a7
      , p17_a8
      );

    -- here's the delegated call to the old PL/SQL routine
    jtf_notes_pub.update_note(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_jtf_note_id,
      p_entered_by,
      p_last_updated_by,
      ddp_last_update_date,
      p_last_update_login,
      p_notes,
      p_notes_detail,
      p_append_flag,
      p_note_status,
      p_note_type,
      ddp_jtf_note_contexts_tab);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

















  end;

  procedure create_note_context(p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , p_jtf_note_id  NUMBER
    , p_last_update_date  date
    , p_last_updated_by  NUMBER
    , p_creation_date  date
    , p_created_by  NUMBER
    , p_last_update_login  NUMBER
    , p_note_context_type_id  NUMBER
    , p_note_context_type  VARCHAR2
    , x_note_context_id out nocopy  NUMBER
  )

  as
    ddp_last_update_date date;
    ddp_creation_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_last_update_date := rosetta_g_miss_date_in_map(p_last_update_date);


    ddp_creation_date := rosetta_g_miss_date_in_map(p_creation_date);






    -- here's the delegated call to the old PL/SQL routine
    jtf_notes_pub.create_note_context(p_validation_level,
      x_return_status,
      p_jtf_note_id,
      ddp_last_update_date,
      p_last_updated_by,
      ddp_creation_date,
      p_created_by,
      p_last_update_login,
      p_note_context_type_id,
      p_note_context_type,
      x_note_context_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

  procedure update_note_context(p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , p_note_context_id  NUMBER
    , p_jtf_note_id  NUMBER
    , p_note_context_type_id  NUMBER
    , p_note_context_type  VARCHAR2
    , p_last_updated_by  NUMBER
    , p_last_update_date  date
    , p_last_update_login  NUMBER
  )

  as
    ddp_last_update_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_last_update_date := rosetta_g_miss_date_in_map(p_last_update_date);


    -- here's the delegated call to the old PL/SQL routine
    jtf_notes_pub.update_note_context(p_validation_level,
      x_return_status,
      p_note_context_id,
      p_jtf_note_id,
      p_note_context_type_id,
      p_note_context_type,
      p_last_updated_by,
      ddp_last_update_date,
      p_last_update_login);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure secure_create_note(p_parent_note_id  NUMBER
    , p_jtf_note_id  NUMBER
    , p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_org_id  NUMBER
    , p_source_object_id  NUMBER
    , p_source_object_code  VARCHAR2
    , p_notes  VARCHAR2
    , p_notes_detail  VARCHAR2
    , p_note_status  VARCHAR2
    , p_entered_by  NUMBER
    , p_entered_date  date
    , x_jtf_note_id out nocopy  NUMBER
    , p_last_update_date  date
    , p_last_updated_by  NUMBER
    , p_creation_date  date
    , p_created_by  NUMBER
    , p_last_update_login  NUMBER
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
    , p_context  VARCHAR2
    , p_note_type  VARCHAR2
    , p40_a0 JTF_NUMBER_TABLE
    , p40_a1 JTF_NUMBER_TABLE
    , p40_a2 JTF_VARCHAR2_TABLE_300
    , p40_a3 JTF_NUMBER_TABLE
    , p40_a4 JTF_DATE_TABLE
    , p40_a5 JTF_NUMBER_TABLE
    , p40_a6 JTF_DATE_TABLE
    , p40_a7 JTF_NUMBER_TABLE
    , p40_a8 JTF_NUMBER_TABLE
    , p_use_aol_security  VARCHAR2
  )

  as
    ddp_entered_date date;
    ddp_last_update_date date;
    ddp_creation_date date;
    ddp_jtf_note_contexts_tab jtf_notes_pub.jtf_note_contexts_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
















    ddp_entered_date := rosetta_g_miss_date_in_map(p_entered_date);


    ddp_last_update_date := rosetta_g_miss_date_in_map(p_last_update_date);


    ddp_creation_date := rosetta_g_miss_date_in_map(p_creation_date);




















    jtf_notes_pub_w.rosetta_table_copy_in_p1(ddp_jtf_note_contexts_tab, p40_a0
      , p40_a1
      , p40_a2
      , p40_a3
      , p40_a4
      , p40_a5
      , p40_a6
      , p40_a7
      , p40_a8
      );


    -- here's the delegated call to the old PL/SQL routine
    jtf_notes_pub.secure_create_note(p_parent_note_id,
      p_jtf_note_id,
      p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_org_id,
      p_source_object_id,
      p_source_object_code,
      p_notes,
      p_notes_detail,
      p_note_status,
      p_entered_by,
      ddp_entered_date,
      x_jtf_note_id,
      ddp_last_update_date,
      p_last_updated_by,
      ddp_creation_date,
      p_created_by,
      p_last_update_login,
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
      p_context,
      p_note_type,
      ddp_jtf_note_contexts_tab,
      p_use_aol_security);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









































  end;

  procedure secure_update_note(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_jtf_note_id  NUMBER
    , p_entered_by  NUMBER
    , p_last_updated_by  NUMBER
    , p_last_update_date  date
    , p_last_update_login  NUMBER
    , p_notes  VARCHAR2
    , p_notes_detail  VARCHAR2
    , p_append_flag  VARCHAR2
    , p_note_status  VARCHAR2
    , p_note_type  VARCHAR2
    , p17_a0 JTF_NUMBER_TABLE
    , p17_a1 JTF_NUMBER_TABLE
    , p17_a2 JTF_VARCHAR2_TABLE_300
    , p17_a3 JTF_NUMBER_TABLE
    , p17_a4 JTF_DATE_TABLE
    , p17_a5 JTF_NUMBER_TABLE
    , p17_a6 JTF_DATE_TABLE
    , p17_a7 JTF_NUMBER_TABLE
    , p17_a8 JTF_NUMBER_TABLE
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
    , p_context  VARCHAR2
    , p_use_aol_security  VARCHAR2
  )

  as
    ddp_last_update_date date;
    ddp_jtf_note_contexts_tab jtf_notes_pub.jtf_note_contexts_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ddp_last_update_date := rosetta_g_miss_date_in_map(p_last_update_date);







    jtf_notes_pub_w.rosetta_table_copy_in_p1(ddp_jtf_note_contexts_tab, p17_a0
      , p17_a1
      , p17_a2
      , p17_a3
      , p17_a4
      , p17_a5
      , p17_a6
      , p17_a7
      , p17_a8
      );


















    -- here's the delegated call to the old PL/SQL routine
    jtf_notes_pub.secure_update_note(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_jtf_note_id,
      p_entered_by,
      p_last_updated_by,
      ddp_last_update_date,
      p_last_update_login,
      p_notes,
      p_notes_detail,
      p_append_flag,
      p_note_status,
      p_note_type,
      ddp_jtf_note_contexts_tab,
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
      p_context,
      p_use_aol_security);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


































  end;

end jtf_notes_pub_w;

/
