--------------------------------------------------------
--  DDL for Package Body IEM_EML_CLASSIFICATIONS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_EML_CLASSIFICATIONS_PVT_W" as
  /* $Header: IEMVCLSB.pls 115.8 2003/08/06 20:54:50 ukari shipped $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p1(t out nocopy iem_eml_classifications_pvt.emclass_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).classification_id := a0(indx);
          t(ddindx).classification := a1(indx);
          t(ddindx).score := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t iem_eml_classifications_pvt.emclass_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).classification_id;
          a1(indx) := t(ddindx).classification;
          a2(indx) := t(ddindx).score;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure create_item(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_email_account_id  NUMBER
    , p_classification_id  NUMBER
    , p_score  NUMBER
    , p_message_id  NUMBER
    , p_created_by  NUMBER
    , p_creation_date  date
    , p_last_updated_by  NUMBER
    , p_last_update_date  date
    , p_last_update_login  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_creation_date date;
    ddp_last_update_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_creation_date := rosetta_g_miss_date_in_map(p_creation_date);


    ddp_last_update_date := rosetta_g_miss_date_in_map(p_last_update_date);





    -- here's the delegated call to the old PL/SQL routine
    iem_eml_classifications_pvt.create_item(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_email_account_id,
      p_classification_id,
      p_score,
      p_message_id,
      p_created_by,
      ddp_creation_date,
      p_last_updated_by,
      ddp_last_update_date,
      p_last_update_login,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














  end;

  procedure getclassification(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_email_account_id  NUMBER
    , p_message_id  NUMBER
    , p5_a0 out nocopy JTF_NUMBER_TABLE
    , p5_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a2 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_email_classn_tbl iem_eml_classifications_pvt.emclass_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    iem_eml_classifications_pvt.getclassification(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_email_account_id,
      p_message_id,
      ddx_email_classn_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    iem_eml_classifications_pvt_w.rosetta_table_copy_out_p1(ddx_email_classn_tbl, p5_a0
      , p5_a1
      , p5_a2
      );



  end;

  procedure getclassification(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_email_account_id  NUMBER
    , p_message_id  NUMBER
    , x_category_id out nocopy  NUMBER
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_email_classn_tbl iem_eml_classifications_pvt.emclass_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    -- here's the delegated call to the old PL/SQL routine
    iem_eml_classifications_pvt.getclassification(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_email_account_id,
      p_message_id,
      x_category_id,
      ddx_email_classn_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    iem_eml_classifications_pvt_w.rosetta_table_copy_out_p1(ddx_email_classn_tbl, p6_a0
      , p6_a1
      , p6_a2
      );



  end;

  procedure create_item(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_email_account_id  NUMBER
    , p_classification_id  NUMBER
    , p_score  NUMBER
    , p_message_id  NUMBER
    , p_class_string  VARCHAR2
    , p_created_by  NUMBER
    , p_creation_date  date
    , p_last_updated_by  NUMBER
    , p_last_update_date  date
    , p_last_update_login  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_creation_date date;
    ddp_last_update_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ddp_creation_date := rosetta_g_miss_date_in_map(p_creation_date);


    ddp_last_update_date := rosetta_g_miss_date_in_map(p_last_update_date);





    -- here's the delegated call to the old PL/SQL routine
    iem_eml_classifications_pvt.create_item(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_email_account_id,
      p_classification_id,
      p_score,
      p_message_id,
      p_class_string,
      p_created_by,
      ddp_creation_date,
      p_last_updated_by,
      ddp_last_update_date,
      p_last_update_login,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any















  end;

end iem_eml_classifications_pvt_w;

/
