--------------------------------------------------------
--  DDL for Package Body JTF_FM_REQUEST_GRP_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_FM_REQUEST_GRP_W" as
  /* $Header: jtfgfmwb.pls 120.2 2005/12/27 00:33 anchaudh ship $ */
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

  procedure rosetta_table_copy_in_p3(t out nocopy jtf_fm_request_grp.g_varchar_tbl_type, a0 JTF_VARCHAR2_TABLE_1000) as
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
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t jtf_fm_request_grp.g_varchar_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_1000) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_1000();
  else
      a0 := JTF_VARCHAR2_TABLE_1000();
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
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p5(t out nocopy jtf_fm_request_grp.g_number_tbl_type, a0 JTF_NUMBER_TABLE) as
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
  procedure rosetta_table_copy_out_p5(t jtf_fm_request_grp.g_number_tbl_type, a0 out nocopy JTF_NUMBER_TABLE) as
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

  procedure get_content_xml(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_content_id  NUMBER
    , p_content_nm  VARCHAR2
    , p_document_type  VARCHAR2
    , p_quantity  NUMBER
    , p_media_type  VARCHAR2
    , p_printer  VARCHAR2
    , p_email  VARCHAR2
    , p_fax  VARCHAR2
    , p_file_path  VARCHAR2
    , p_user_note  VARCHAR2
    , p_content_type  VARCHAR2
    , p_bind_var JTF_VARCHAR2_TABLE_1000
    , p_bind_val JTF_VARCHAR2_TABLE_1000
    , p_bind_var_type JTF_VARCHAR2_TABLE_1000
    , p_request_id  NUMBER
    , x_content_xml out nocopy  VARCHAR2
  )

  as
    ddp_bind_var jtf_fm_request_grp.g_varchar_tbl_type;
    ddp_bind_val jtf_fm_request_grp.g_varchar_tbl_type;
    ddp_bind_var_type jtf_fm_request_grp.g_varchar_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


















    jtf_fm_request_grp_w.rosetta_table_copy_in_p3(ddp_bind_var, p_bind_var);

    jtf_fm_request_grp_w.rosetta_table_copy_in_p3(ddp_bind_val, p_bind_val);

    jtf_fm_request_grp_w.rosetta_table_copy_in_p3(ddp_bind_var_type, p_bind_var_type);



    -- here's the delegated call to the old PL/SQL routine
    jtf_fm_request_grp.get_content_xml(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_content_id,
      p_content_nm,
      p_document_type,
      p_quantity,
      p_media_type,
      p_printer,
      p_email,
      p_fax,
      p_file_path,
      p_user_note,
      p_content_type,
      ddp_bind_var,
      ddp_bind_val,
      ddp_bind_var_type,
      p_request_id,
      x_content_xml);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






















  end;

  procedure get_content_xml(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_content_id  NUMBER
    , p_content_nm  VARCHAR2
    , p_document_type  VARCHAR2
    , p_quantity  NUMBER
    , p_media_type  VARCHAR2
    , p_printer  VARCHAR2
    , p_email  VARCHAR2
    , p_fax  VARCHAR2
    , p_file_path  VARCHAR2
    , p_user_note  VARCHAR2
    , p_content_type  VARCHAR2
    , p_bind_var JTF_VARCHAR2_TABLE_1000
    , p_bind_val JTF_VARCHAR2_TABLE_1000
    , p_bind_var_type JTF_VARCHAR2_TABLE_1000
    , p_request_id  NUMBER
    , x_content_xml out nocopy  VARCHAR2
    , p_content_source  VARCHAR2
    , p_version  NUMBER
  )

  as
    ddp_bind_var jtf_fm_request_grp.g_varchar_tbl_type;
    ddp_bind_val jtf_fm_request_grp.g_varchar_tbl_type;
    ddp_bind_var_type jtf_fm_request_grp.g_varchar_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


















    jtf_fm_request_grp_w.rosetta_table_copy_in_p3(ddp_bind_var, p_bind_var);

    jtf_fm_request_grp_w.rosetta_table_copy_in_p3(ddp_bind_val, p_bind_val);

    jtf_fm_request_grp_w.rosetta_table_copy_in_p3(ddp_bind_var_type, p_bind_var_type);





    -- here's the delegated call to the old PL/SQL routine
    jtf_fm_request_grp.get_content_xml(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_content_id,
      p_content_nm,
      p_document_type,
      p_quantity,
      p_media_type,
      p_printer,
      p_email,
      p_fax,
      p_file_path,
      p_user_note,
      p_content_type,
      ddp_bind_var,
      ddp_bind_val,
      ddp_bind_var_type,
      p_request_id,
      x_content_xml,
      p_content_source,
      p_version);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
























  end;

  procedure cancel_request(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_request_id  NUMBER
    , p_submit_dt_tm  date
  )

  as
    ddp_submit_dt_tm date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_submit_dt_tm := rosetta_g_miss_date_in_map(p_submit_dt_tm);

    -- here's the delegated call to the old PL/SQL routine
    jtf_fm_request_grp.cancel_request(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_request_id,
      ddp_submit_dt_tm);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure get_multiple_content_xml(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_request_id  NUMBER
    , p_content_type JTF_VARCHAR2_TABLE_1000
    , p_content_id JTF_NUMBER_TABLE
    , p_content_nm JTF_VARCHAR2_TABLE_1000
    , p_document_type JTF_VARCHAR2_TABLE_1000
    , p_media_type JTF_VARCHAR2_TABLE_1000
    , p_printer JTF_VARCHAR2_TABLE_1000
    , p_email JTF_VARCHAR2_TABLE_1000
    , p_fax JTF_VARCHAR2_TABLE_1000
    , p_file_path JTF_VARCHAR2_TABLE_1000
    , p_user_note JTF_VARCHAR2_TABLE_1000
    , p_quantity JTF_NUMBER_TABLE
    , x_content_xml out nocopy  VARCHAR2
  )

  as
    ddp_content_type jtf_fm_request_grp.g_varchar_tbl_type;
    ddp_content_id jtf_fm_request_grp.g_number_tbl_type;
    ddp_content_nm jtf_fm_request_grp.g_varchar_tbl_type;
    ddp_document_type jtf_fm_request_grp.g_varchar_tbl_type;
    ddp_media_type jtf_fm_request_grp.g_varchar_tbl_type;
    ddp_printer jtf_fm_request_grp.g_varchar_tbl_type;
    ddp_email jtf_fm_request_grp.g_varchar_tbl_type;
    ddp_fax jtf_fm_request_grp.g_varchar_tbl_type;
    ddp_file_path jtf_fm_request_grp.g_varchar_tbl_type;
    ddp_user_note jtf_fm_request_grp.g_varchar_tbl_type;
    ddp_quantity jtf_fm_request_grp.g_number_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    jtf_fm_request_grp_w.rosetta_table_copy_in_p3(ddp_content_type, p_content_type);

    jtf_fm_request_grp_w.rosetta_table_copy_in_p5(ddp_content_id, p_content_id);

    jtf_fm_request_grp_w.rosetta_table_copy_in_p3(ddp_content_nm, p_content_nm);

    jtf_fm_request_grp_w.rosetta_table_copy_in_p3(ddp_document_type, p_document_type);

    jtf_fm_request_grp_w.rosetta_table_copy_in_p3(ddp_media_type, p_media_type);

    jtf_fm_request_grp_w.rosetta_table_copy_in_p3(ddp_printer, p_printer);

    jtf_fm_request_grp_w.rosetta_table_copy_in_p3(ddp_email, p_email);

    jtf_fm_request_grp_w.rosetta_table_copy_in_p3(ddp_fax, p_fax);

    jtf_fm_request_grp_w.rosetta_table_copy_in_p3(ddp_file_path, p_file_path);

    jtf_fm_request_grp_w.rosetta_table_copy_in_p3(ddp_user_note, p_user_note);

    jtf_fm_request_grp_w.rosetta_table_copy_in_p5(ddp_quantity, p_quantity);


    -- here's the delegated call to the old PL/SQL routine
    jtf_fm_request_grp.get_multiple_content_xml(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_request_id,
      ddp_content_type,
      ddp_content_id,
      ddp_content_nm,
      ddp_document_type,
      ddp_media_type,
      ddp_printer,
      ddp_email,
      ddp_fax,
      ddp_file_path,
      ddp_user_note,
      ddp_quantity,
      x_content_xml);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



















  end;

  procedure submit_batch_request(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_template_id  NUMBER
    , p_subject  VARCHAR2
    , p_user_id  NUMBER
    , p_source_code_id  NUMBER
    , p_source_code  VARCHAR2
    , p_object_type  VARCHAR2
    , p_object_id  NUMBER
    , p_order_id  NUMBER
    , p_doc_id  NUMBER
    , p_doc_ref  VARCHAR2
    , p_list_type  VARCHAR2
    , p_view_nm  VARCHAR2
    , p_party_id JTF_NUMBER_TABLE
    , p_party_name JTF_VARCHAR2_TABLE_1000
    , p_printer JTF_VARCHAR2_TABLE_1000
    , p_email JTF_VARCHAR2_TABLE_1000
    , p_fax JTF_VARCHAR2_TABLE_1000
    , p_file_path JTF_VARCHAR2_TABLE_1000
    , p_server_id  NUMBER
    , p_queue_response  VARCHAR2
    , p_extended_header  VARCHAR2
    , p_content_xml  VARCHAR2
    , p_request_id  NUMBER
    , p_per_user_history  VARCHAR2
  )

  as
    ddp_party_id jtf_fm_request_grp.g_number_tbl_type;
    ddp_party_name jtf_fm_request_grp.g_varchar_tbl_type;
    ddp_printer jtf_fm_request_grp.g_varchar_tbl_type;
    ddp_email jtf_fm_request_grp.g_varchar_tbl_type;
    ddp_fax jtf_fm_request_grp.g_varchar_tbl_type;
    ddp_file_path jtf_fm_request_grp.g_varchar_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



















    jtf_fm_request_grp_w.rosetta_table_copy_in_p5(ddp_party_id, p_party_id);

    jtf_fm_request_grp_w.rosetta_table_copy_in_p3(ddp_party_name, p_party_name);

    jtf_fm_request_grp_w.rosetta_table_copy_in_p3(ddp_printer, p_printer);

    jtf_fm_request_grp_w.rosetta_table_copy_in_p3(ddp_email, p_email);

    jtf_fm_request_grp_w.rosetta_table_copy_in_p3(ddp_fax, p_fax);

    jtf_fm_request_grp_w.rosetta_table_copy_in_p3(ddp_file_path, p_file_path);







    -- here's the delegated call to the old PL/SQL routine
    jtf_fm_request_grp.submit_batch_request(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_template_id,
      p_subject,
      p_user_id,
      p_source_code_id,
      p_source_code,
      p_object_type,
      p_object_id,
      p_order_id,
      p_doc_id,
      p_doc_ref,
      p_list_type,
      p_view_nm,
      ddp_party_id,
      ddp_party_name,
      ddp_printer,
      ddp_email,
      ddp_fax,
      ddp_file_path,
      p_server_id,
      p_queue_response,
      p_extended_header,
      p_content_xml,
      p_request_id,
      p_per_user_history);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






























  end;

  procedure submit_mass_request(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_template_id  NUMBER
    , p_subject  VARCHAR2
    , p_user_id  NUMBER
    , p_source_code_id  NUMBER
    , p_source_code  VARCHAR2
    , p_object_type  VARCHAR2
    , p_object_id  NUMBER
    , p_order_id  NUMBER
    , p_doc_id  NUMBER
    , p_doc_ref  VARCHAR2
    , p_list_type  VARCHAR2
    , p_view_nm  VARCHAR2
    , p_server_id  NUMBER
    , p_queue_response  VARCHAR2
    , p_extended_header  VARCHAR2
    , p_content_xml  VARCHAR2
    , p_request_id  NUMBER
    , p_per_user_history  VARCHAR2
    , p_mass_query_id  NUMBER
    , p_mass_bind_var JTF_VARCHAR2_TABLE_1000
    , p_mass_bind_var_type JTF_VARCHAR2_TABLE_1000
    , p_mass_bind_val JTF_VARCHAR2_TABLE_1000
  )

  as
    ddp_mass_bind_var jtf_fm_request_grp.g_varchar_tbl_type;
    ddp_mass_bind_var_type jtf_fm_request_grp.g_varchar_tbl_type;
    ddp_mass_bind_val jtf_fm_request_grp.g_varchar_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


























    jtf_fm_request_grp_w.rosetta_table_copy_in_p3(ddp_mass_bind_var, p_mass_bind_var);

    jtf_fm_request_grp_w.rosetta_table_copy_in_p3(ddp_mass_bind_var_type, p_mass_bind_var_type);

    jtf_fm_request_grp_w.rosetta_table_copy_in_p3(ddp_mass_bind_val, p_mass_bind_val);

    -- here's the delegated call to the old PL/SQL routine
    jtf_fm_request_grp.submit_mass_request(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_template_id,
      p_subject,
      p_user_id,
      p_source_code_id,
      p_source_code,
      p_object_type,
      p_object_id,
      p_order_id,
      p_doc_id,
      p_doc_ref,
      p_list_type,
      p_view_nm,
      p_server_id,
      p_queue_response,
      p_extended_header,
      p_content_xml,
      p_request_id,
      p_per_user_history,
      p_mass_query_id,
      ddp_mass_bind_var,
      ddp_mass_bind_var_type,
      ddp_mass_bind_val);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




























  end;

  procedure new_cancel_request(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_request_id  NUMBER
    , p_submit_dt_tm  date
  )

  as
    ddp_submit_dt_tm date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_submit_dt_tm := rosetta_g_miss_date_in_map(p_submit_dt_tm);

    -- here's the delegated call to the old PL/SQL routine
    jtf_fm_request_grp.new_cancel_request(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_request_id,
      ddp_submit_dt_tm);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure correct_malformed(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_request_id  NUMBER
    , p_job JTF_NUMBER_TABLE
    , p_corrected_address JTF_VARCHAR2_TABLE_1000
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_job jtf_fm_request_grp.g_number_tbl_type;
    ddp_corrected_address jtf_fm_request_grp.g_varchar_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    jtf_fm_request_grp_w.rosetta_table_copy_in_p5(ddp_job, p_job);

    jtf_fm_request_grp_w.rosetta_table_copy_in_p3(ddp_corrected_address, p_corrected_address);


    -- here's the delegated call to the old PL/SQL routine
    jtf_fm_request_grp.correct_malformed(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_msg_count,
      x_msg_data,
      p_request_id,
      ddp_job,
      ddp_corrected_address,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure resubmit_malformed(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_request_id  NUMBER
    , x_request_id out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddx_request_id jtf_fm_request_grp.g_number_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    jtf_fm_request_grp.resubmit_malformed(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_msg_count,
      x_msg_data,
      p_request_id,
      ddx_request_id,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    jtf_fm_request_grp_w.rosetta_table_copy_out_p5(ddx_request_id, x_request_id);

  end;

end jtf_fm_request_grp_w;

/
