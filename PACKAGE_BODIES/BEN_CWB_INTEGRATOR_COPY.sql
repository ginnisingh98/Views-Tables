--------------------------------------------------------
--  DDL for Package Body BEN_CWB_INTEGRATOR_COPY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CWB_INTEGRATOR_COPY" as
/* $Header: bencwbic.pkb 120.0.12010000.3 2009/10/08 07:45:05 kgowripe noship $ */

g_package  Varchar2(30) := 'BEN_CWB_INTEGRATOR_COPY.';
g_debug boolean := hr_utility.debug_enabled;

--
-------------------------- copy_integrator ----------------------
--

PROCEDURE copy_integrator( p_group_pl_id     IN NUMBER,
			   p_integrator_code IN VARCHAR2
                        )
IS

l_suffix varchar2(100) := '_' || trim(p_group_pl_id);
l_new_integrator_code varchar2(100) := 'BEN_CWB_WS_INTG' || l_suffix;
l_new_interface_code varchar2(100) := 'BEN_CWB_WS_INTF' || l_suffix;
l_new_content_code varchar2(100) := 'BEN_CWB_WS_CNT' || l_suffix;
l_new_mapping_code varchar2(100) := 'BEN_CWB_WS_MAP' || l_suffix;
l_new_layout_code varchar2(100) ;
l_layout_count number := 1;
l_step varchar2(100);
l_plan_name varchar2(100);
cursor c_plan_name is
select name || ' - ' from ben_cwb_pl_dsgn
where pl_id = p_group_pl_id and pl_id = group_pl_id
and oipl_id = -1 and group_oipl_id = -1;

cursor c_bne_integrators is
select a.application_short_name,
          v.integrator_code,
          substr(fnd_load_util.owner_name(v.last_updated_by),1,30) owner,
          v.object_version_number,
          v.enabled_flag,
          substr(bne_lct_tools_pkg.app_id_to_asn(v.upload_param_list_app_id),1,30) upl_param_list_asn,
          v.upload_param_list_code upl_param_list_code,
          substr(bne_lct_tools_pkg.app_id_to_asn(v.upload_serv_param_list_app_id),1,30) upl_serv_param_list_asn,
          v.upload_serv_param_list_code upl_serv_param_list_code,
          substr(bne_lct_tools_pkg.app_id_to_asn(v.import_param_list_app_id),1,30) import_param_list_asn,
          v.import_param_list_code,
          v.date_format,
          v.import_type,
          v.uploader_class,
          v.user_name,
          v.upload_header,
          v.upload_title_bar,
          to_char(v.last_update_date, 'yyyy/mm/dd') last_update_date,
          substr(bne_lct_tools_pkg.app_id_to_asn(v.create_doc_list_app_id),1,30) create_doc_param_list_asn,
          v.create_doc_list_code create_doc_param_list_code,
          v.new_session_flag,
          v.layout_resolver_class,
          v.layout_verifier_class,
          v.session_config_class,
          substr(bne_lct_tools_pkg.app_id_to_asn(v.session_param_list_app_id),1,30) session_param_list_asn,
          v.session_param_list_code,
          substr(bne_lct_tools_pkg.app_id_to_asn(s.application_id),1,30),
          s.object_code,
          s.object_type,
          v.display_flag
   from bne_integrators_vl v, bne_secured_objects s, fnd_application a
   where v.application_id = a.application_id
   and   v.application_id = s.application_id (+)
   and   v.integrator_code = s.object_code (+)
   and   s.object_type (+) = 'INTEGRATOR'
   and   v.integrator_code = p_integrator_code
   and   a.application_short_name = 'PER'
   order by a.application_short_name, v.integrator_code;

 cursor c_bne_interfaces is
 select a.application_short_name,
           v.interface_code,
           substr(fnd_load_util.owner_name(v.last_updated_by),1,30) owner,
           v.object_version_number,
           v.interface_name,
           v.upload_type,
           v.upload_obj_name,
           substr(bne_lct_tools_pkg.app_id_to_asn(v.upload_param_list_app_id),1,30) upload_param_list_asn,
           v.upload_param_list_code,
           v.upload_order,
           v.user_name,
           to_char(v.last_update_date, 'yyyy/mm/dd') last_update_date
    from bne_interfaces_vl v, fnd_application a
    where v.application_id = a.application_id
    and   v.integrator_code = p_integrator_code
    and   a.application_short_name = 'PER'
   order by a.application_short_name, v.interface_code;

 cursor c_bne_interface_cols (
 	v_interface_code IN VARCHAR2 ) is
 select v.sequence_num,
           substr(fnd_load_util.owner_name(v.last_updated_by),1,30) owner,
           v.object_version_number,
           v.interface_col_type,
           v.interface_col_name,
           v.enabled_flag,
           v.required_flag,
           v.display_flag,
           v.read_only_flag,
           v.not_null_flag,
           v.summary_flag,
           v.mapping_enabled_flag,
           v.data_type,
           v.field_size,
           v.default_type,
           v.default_value,
           v.segment_number,
           v.group_name,
           v.oa_flex_code,
           v.oa_concat_flex,
           v.val_type,
           v.val_id_col,
           v.val_mean_col,
           v.val_desc_col,
           v.val_obj_name,
           v.val_addl_w_c,
           substr(bne_lct_tools_pkg.app_id_to_asn(v.val_component_app_id),1,30) val_component_asn,
           v.val_component_code,
           v.oa_flex_num,
           v.oa_flex_application_id,
           v.display_order,
           v.upload_param_list_item_num,
           v.expanded_sql_query,
           v.user_hint,
           v.prompt_left,
           v.prompt_above,
           v.user_help_text,
           to_char(v.last_update_date, 'yyyy/mm/dd') last_update_date,
           v.lov_type,
           v.offline_lov_enabled_flag,
           v.variable_data_type_class,
           v.viewer_group,
           v.edit_type,
           v.display_width,
           substr(bne_lct_tools_pkg.app_id_to_asn(v.val_query_app_id),1,30) val_query_asn,
           v.val_query_code,
           substr(bne_lct_tools_pkg.app_id_to_asn(v.expanded_sql_query_app_id),1,30) expanded_sql_query_asn,
           v.expanded_sql_query_code
    from bne_interface_cols_vl v, fnd_application a
    where v.application_id = a.application_id
    and   v.interface_code = v_interface_code
    and   a.application_short_name = 'PER'
   order by a.application_short_name, v.interface_code, v.sequence_num;

  cursor c_bne_contents is
  select a.application_short_name,
            v.content_code,
            v.object_version_number,
            substr(fnd_load_util.owner_name(v.last_updated_by),1,30) owner,
            substr(bne_lct_tools_pkg.app_id_to_asn(v.param_list_app_id),1,30) param_list_asn,
            v.param_list_code,
            v.content_class,
            v.user_name,
            to_char(v.last_update_date, 'yyyy/mm/dd') last_update_date,
            v.once_only_download_flag
     from bne_contents_vl v, fnd_application a
     where v.integrator_app_id = a.application_id
     and   v.integrator_code = p_integrator_code
     and   a.application_short_name = 'PER'
   order by a.application_short_name, v.content_code;

   cursor c_bne_content_cols (
 	v_content_code IN VARCHAR2 )  is
   select v.sequence_num,
             v.object_version_number,
             substr(fnd_load_util.owner_name(v.last_updated_by),1,30) owner,
             v.col_name,
             v.user_name,
             to_char(v.last_update_date, 'yyyy/mm/dd') last_update_date,
             v.read_only_flag
      from bne_content_cols_vl v, fnd_application a
      where v.application_id = a.application_id
      and   v.content_code = v_content_code
      and   a.application_short_name = 'PER'
   order by a.application_short_name, v.content_code, v.sequence_num;

   cursor c_bne_stored_sql (
 	v_content_code IN VARCHAR2 )  is
   select v.object_version_number,
             v.query,
             substr(bne_lct_tools_pkg.app_id_to_asn(v.query_app_id),1,30) bne_query_query_asn,
             v.query_code,
             substr(fnd_load_util.owner_name(v.last_updated_by),1,30) owner,
             to_char(v.last_update_date, 'yyyy/mm/dd') last_update_date
      from bne_stored_sql v, fnd_application a
      where v.application_id = a.application_id
      and   v.content_code = v_content_code
   and   a.application_short_name = 'PER';

   cursor c_bne_mappings is
   select a.application_short_name,
             v.mapping_code,
             v.reporting_flag,
             substr(bne_lct_tools_pkg.app_id_to_asn(v.reporting_interface_app_id),1,30) reporting_interface_asn,
             v.reporting_interface_code,
             v.user_name,
             substr(fnd_load_util.owner_name(v.last_updated_by),1,30) owner,
             v.object_version_number,
             to_char(v.last_update_date, 'yyyy/mm/dd') last_update_date
      from bne_mappings_vl v, fnd_application a
      where v.application_id = a.application_id
      and   v.integrator_code = p_integrator_code
      and   a.application_short_name = 'PER'
   order by a.application_short_name, v.mapping_code;

   cursor c_bne_mapping_lines (
 	v_mapping_code IN VARCHAR2 ) is
   select v.sequence_num,
             substr(bne_lct_tools_pkg.app_id_to_asn(v.interface_app_id),1,30) interface_asn,
             v.interface_code,
             v.interface_seq_num,
             substr(fnd_load_util.owner_name(v.last_updated_by),1,30) owner,
             v.decode_flag,
             v.object_version_number,
             substr(bne_lct_tools_pkg.app_id_to_asn(v.content_app_id),1,30) content_asn,
             v.content_code,
             v.content_seq_num,
             to_char(v.last_update_date, 'yyyy/mm/dd') last_update_date
      from bne_mapping_lines v, fnd_application a
      where v.application_id = a.application_id
      and   v.mapping_code = v_mapping_code
      and   a.application_short_name = 'PER'
   order by a.application_short_name, v.mapping_code, v.sequence_num;

   cursor c_bne_layouts is
   select a.application_short_name,
             v.layout_code,
             substr(fnd_load_util.owner_name(v.last_updated_by),1,30) owner,
             v.object_version_number,
             substr(bne_lct_tools_pkg.app_id_to_asn(v.stylesheet_app_id),1,30) stylesheet_asn,
             v.stylesheet_code,
             v.style,
             v.style_class,
             v.reporting_flag,
             substr(bne_lct_tools_pkg.app_id_to_asn(v.reporting_interface_app_id),1,30) reporting_interface_asn,
             v.reporting_interface_code,
             v.user_name,
             to_char(v.last_update_date, 'yyyy/mm/dd') last_update_date,
             substr(bne_lct_tools_pkg.app_id_to_asn(v.create_doc_list_app_id),1,30) create_doc_list_asn,
             v.create_doc_list_code
      from bne_layouts_vl v, fnd_application a
      where v.integrator_app_id = a.application_id
      and   v.integrator_code like p_integrator_code
      and   a.application_short_name like 'PER'
   order by a.application_short_name, v.layout_code desc;

  cursor c_bne_layout_blocks(
  	v_layout_code IN varchar2) is
  select v.block_id,
          substr(fnd_load_util.owner_name(v.last_updated_by),1,30) owner,
          v.object_version_number,
          v.parent_id,
          v.layout_element,
          v.style_class,
          v.style,
          v.row_style_class,
          v.row_style,
          v.col_style_class,
          v.col_style,
          v.prompt_displayed_flag,
          v.prompt_style_class,
          v.prompt_style,
          v.hint_displayed_flag,
          v.hint_style_class,
          v.hint_style,
          v.orientation,
          v.layout_control,
          v.display_flag,
          v.blocksize,
          v.minsize,
          v.maxsize,
          v.sequence_num,
          v.prompt_colspan,
          v.hint_colspan,
          v.row_colspan,
          v.summary_style_class,
          v.summary_style,
          v.user_name,
          to_char(v.last_update_date, 'yyyy/mm/dd') last_update_date,
          v.title_style_class,
          v.title_style,
          v.prompt_above
   from bne_layout_blocks_vl v, fnd_application a
   where v.application_id = a.application_id
   and   v.layout_code = v_layout_code
   and   a.application_short_name = 'PER'
   order by a.application_short_name, v.layout_code, v.block_id;

  cursor c_bne_layout_cols (
  	v_layout_code IN varchar2,
  	v_block_id IN varchar2) is
  select v.sequence_num,
          substr(fnd_load_util.owner_name(v.last_updated_by),1,30) owner,
          v.object_version_number,
          substr(bne_lct_tools_pkg.app_id_to_asn(v.interface_app_id),1,30) interface_asn,
          v.interface_code,
          v.interface_seq_num,
          v.style_class,
          v.style,
          v.prompt_style_class,
          v.prompt_style,
          v.hint_style_class,
          v.hint_style,
          v.default_value,
          v.default_type,
          v.display_width,
          to_char(v.last_update_date, 'yyyy/mm/dd') last_update_date,
          v.read_only_flag
   from bne_layout_cols v, fnd_application a
   where v.application_id = a.application_id
   and   v.layout_code = v_layout_code
   and   a.application_short_name = 'PER'
   and   v.block_id = v_block_id
   order by a.application_short_name, v.layout_code, v.block_id, v.sequence_num;

   cursor c_bne_secured_objects is
   select a.application_short_name,
             v.object_code,
             v.object_type,
             v.object_version_number,
             substr(bne_lct_tools_pkg.app_id_to_asn(v.security_rule_app_id),1,30) rule_security_rule_asn,
             v.security_rule_code rule_security_rule_code,
             substr(fnd_load_util.owner_name(v.last_updated_by),1,30) owner,
             to_char(v.last_update_date, 'yyyy/mm/dd') last_update_date,
             v.security_rule_app_id
      from bne_secured_objects v, fnd_application a
      where v.application_id = a.application_id
      and   v.object_code = p_integrator_code
      and   v.object_type = 'INTEGRATOR'
      and   a.application_short_name = 'PER'
   order by a.application_short_name, v.object_code, v.object_type;

  cursor c_bne_security_rules(
  	v_security_rule_code IN VARCHAR2) is
  select a.application_short_name,
          v.security_code,
          v.object_version_number,
          v.security_type,
          v.security_value,
          substr(fnd_load_util.owner_name(v.last_updated_by),1,30) owner,
          to_char(v.last_update_date, 'yyyy/mm/dd') last_update_date
   from bne_security_rules v, fnd_application a
   where v.application_id = a.application_id
   and   v.security_code = v_security_rule_code
   and   a.application_short_name = 'PER'
   order by a.application_short_name, v.security_code;


BEGIN

  --g_proc := 'Copy_Integrator';
  --g_actn := 'Copy_Integrator...';
   --dbms_output.put_line('Copy_Integrator');
  SAVEPOINT copy_integrator;

  if (p_group_pl_id is null or p_integrator_code is null) then
    return;
  end if;
  open c_plan_name;
  fetch c_plan_name into l_plan_name;
  close c_plan_name;

   fnd_file.put_line(Fnd_file.LOG,'1.Creating the integrator...');
  l_step := 'Integrator Creation';
  FOR l_bne_integrator in c_bne_integrators
  LOOP
  	bne_integrators_pkg.load_row(
	          x_integrator_asn              => l_bne_integrator.application_short_name,
	          x_integrator_code             => l_new_integrator_code ,
	          x_object_version_number       => 1 ,
	          x_enabled_flag                => l_bne_integrator.enabled_flag ,
	          x_upload_param_list_asn       => l_bne_integrator.upl_param_list_asn ,
	          x_upload_param_list_code      => l_bne_integrator.upl_param_list_code ,
	          x_upload_serv_param_list_asn  => l_bne_integrator.upl_serv_param_list_asn ,
	          x_upload_serv_param_list_code => l_bne_integrator.upl_serv_param_list_code  ,
	          x_import_param_list_asn       => l_bne_integrator.import_param_list_asn ,
	          x_import_param_code           => l_bne_integrator.import_param_list_code ,
	          x_date_format                 => l_bne_integrator.date_format ,
	          x_import_type                 => l_bne_integrator.import_type ,
	          x_uploader_class              => l_bne_integrator.uploader_class ,
	          x_user_name                   => l_plan_name || l_bne_integrator.user_name,
	          x_upload_header               => l_bne_integrator.upload_header ,
	          x_upload_title_bar            => l_bne_integrator.upload_title_bar  ,
	          x_owner                       => l_bne_integrator.owner,
	          x_last_update_date            => l_bne_integrator.last_update_date,
	          x_custom_mode                 => null ,
	          x_create_doc_list_asn         => l_bne_integrator.create_doc_param_list_asn ,
	          x_create_doc_list_code        => l_bne_integrator.create_doc_param_list_code ,
	          x_new_session_flag            => l_bne_integrator.new_session_flag ,
	          x_layout_resolver_class       => l_bne_integrator.layout_resolver_class ,
	          x_layout_verifier_class       => l_bne_integrator.layout_verifier_class ,
	          x_session_config_class        => l_bne_integrator.session_config_class ,
	          x_session_param_list_asn      => l_bne_integrator.session_param_list_asn ,
	          x_session_param_list_code     => l_bne_integrator.session_param_list_code ,
	          x_display_flag                => l_bne_integrator.display_flag
        );
         fnd_file.put_line(Fnd_file.LOG,'2.Creating the interface...');
	  l_step := 'Interface Creation';
	  FOR l_bne_interface in c_bne_interfaces
	     LOOP
		bne_interfaces_pkg.load_row(
		          x_interface_asn          => l_bne_interface.application_short_name ,
		          x_interface_code         => l_new_interface_code  ,
		          x_object_version_number  => 1 ,
		          x_integrator_asn         => 'PER' ,
		          x_integrator_code        => l_new_integrator_code ,
		          x_interface_name         => l_bne_interface.interface_name ,
		          x_upload_type            => l_bne_interface.upload_type ,
		          x_upload_obj_name        => l_bne_interface.upload_obj_name  ,
		          x_upload_param_list_asn  => l_bne_interface.upload_param_list_asn ,
		          x_upload_param_list_code => l_bne_interface.upload_param_list_code  ,
		          x_upload_order           => l_bne_interface.upload_order  ,
		          x_user_name              => l_bne_interface.user_name   ,
		          x_owner                  => l_bne_interface.owner ,
		          x_last_update_date       => l_bne_interface.last_update_date ,
		          x_custom_mode            => null
	        );
          --fnd_file.put_line(Fnd_file.LOG,'2.2.Creating the interface columns...');
		  l_step := 'Interface Columns Creation';
		  FOR l_bne_interface_col in c_bne_interface_cols(l_bne_interface.interface_code)
		       LOOP
		  	bne_interface_cols_pkg.load_row(
			          x_interface_asn              =>  'PER' ,
			          x_interface_code             =>  l_new_interface_code  ,
			          x_sequence_num               =>  l_bne_interface_col.sequence_num              ,
			          x_interface_col_type         =>  l_bne_interface_col.interface_col_type        ,
			          x_interface_col_name         =>  l_bne_interface_col.interface_col_name        ,
			          x_enabled_flag               =>  l_bne_interface_col.enabled_flag               ,
			          x_required_flag              =>  l_bne_interface_col.required_flag              ,
			          x_display_flag               =>  l_bne_interface_col.display_flag               ,
			          x_read_only_flag             =>  l_bne_interface_col.read_only_flag             ,
			          x_not_null_flag              =>  l_bne_interface_col.not_null_flag              ,
			          x_summary_flag               =>  l_bne_interface_col.summary_flag               ,
			          x_mapping_enabled_flag       =>  l_bne_interface_col.mapping_enabled_flag       ,
			          x_data_type                  =>  l_bne_interface_col.data_type                  ,
			          x_field_size                 =>  l_bne_interface_col.field_size                 ,
			          x_default_type               =>  l_bne_interface_col.default_type               ,
			          x_default_value              =>  l_bne_interface_col.default_value              ,
			          x_segment_number             =>  l_bne_interface_col.segment_number             ,
			          x_group_name                 =>  l_bne_interface_col.group_name                 ,
			          x_oa_flex_code               =>  l_bne_interface_col.oa_flex_code               ,
			          x_oa_concat_flex             =>  l_bne_interface_col.oa_concat_flex             ,
			          x_val_type                   =>  l_bne_interface_col.val_type                   ,
			          x_val_id_col                 =>  l_bne_interface_col.val_id_col                 ,
			          x_val_mean_col               =>  l_bne_interface_col.val_mean_col               ,
			          x_val_desc_col               =>  l_bne_interface_col.val_desc_col               ,
			          x_val_obj_name               =>  l_bne_interface_col.val_obj_name               ,
			          x_val_addl_w_c               =>  l_bne_interface_col.val_addl_w_c               ,
			          x_val_component_asn          =>  l_bne_interface_col.val_component_asn          ,
			          x_val_component_code         =>  l_bne_interface_col.val_component_code         ,
			          x_oa_flex_num                =>  l_bne_interface_col.oa_flex_num                ,
			          x_oa_flex_application_id     =>  l_bne_interface_col.oa_flex_application_id     ,
			          x_display_order              =>  l_bne_interface_col.display_order              ,
			          x_upload_param_list_item_num =>  l_bne_interface_col.upload_param_list_item_num ,
			          x_expanded_sql_query         =>  l_bne_interface_col.expanded_sql_query         ,
			          x_object_version_number      =>  l_bne_interface_col.object_version_number      ,
			          x_user_hint                  =>  l_bne_interface_col.user_hint                  ,
			          x_prompt_left                =>  l_bne_interface_col.prompt_left                ,
			          x_user_help_text             =>  l_bne_interface_col.user_help_text             ,
			          x_prompt_above               =>  l_bne_interface_col.prompt_above               ,
			          x_owner                      =>  l_bne_interface_col.owner                      ,
			          x_last_update_date           =>  l_bne_interface_col.last_update_date          ,
			          x_lov_type                   =>  l_bne_interface_col.lov_type                   ,
			          x_offline_lov_enabled_flag   =>  l_bne_interface_col.offline_lov_enabled_flag   ,
			          x_custom_mode                =>  null ,
			          x_variable_data_type_class   =>  l_bne_interface_col.variable_data_type_class   ,
			          x_viewer_group               =>  l_bne_interface_col.viewer_group               ,
			          x_edit_type                  =>  l_bne_interface_col.edit_type                  ,
			          x_display_width              =>  l_bne_interface_col.display_width              ,
			          x_val_query_asn              =>  l_bne_interface_col.val_query_asn              ,
			          x_val_query_code             =>  l_bne_interface_col.val_query_code             ,
			          x_expanded_sql_query_asn     =>  l_bne_interface_col.expanded_sql_query_asn     ,
			          x_expanded_sql_query_code    =>  l_bne_interface_col.expanded_sql_query_code
		        );

  		END LOOP; -- interface columns

  	END LOOP; -- interface

  	 fnd_file.put_line(Fnd_file.LOG,'3.Creating the contents...');
	  l_step := 'Contents Creation';
	  FOR l_bne_content in c_bne_contents
	      LOOP
	      bne_contents_pkg.load_row(
	                x_content_asn             =>   l_bne_content.application_short_name              ,
	                x_content_code            =>   l_new_content_code           ,
	                x_object_version_number   =>   1  ,
	                x_integrator_asn          =>   'PER'         ,
	                x_integrator_code         =>   l_new_integrator_code  ,
	                x_param_list_asn          =>   l_bne_content.param_list_asn           ,
	                x_param_list_code         =>   l_bne_content.param_list_code           ,
	                x_content_class           =>   l_bne_content.content_class            ,
	                x_user_name               =>   l_bne_content.user_name                ,
	                x_owner                   =>   l_bne_content.owner                    ,
	                x_last_update_date        =>   l_bne_content.last_update_date        ,
	                x_custom_mode             =>   null ,
	                x_once_only_download_flag =>   l_bne_content.once_only_download_flag
	        );

		  -- fnd_file.put_line(Fnd_file.LOG,'3.2.Creating the contents columns...');
		  l_step := 'Contents Columns Creation';
		  FOR l_bne_content_col in c_bne_content_cols (l_bne_content.content_code)
		      LOOP
		      bne_content_cols_pkg.load_row(
		                x_content_asn          =>   'PER'           ,
		                x_content_code         =>   l_new_content_code           ,
		                x_sequence_num         =>   l_bne_content_col.sequence_num           ,
		                x_object_version_number=>   1  ,
		                x_col_name             =>   l_bne_content_col.col_name               ,
		                x_user_name            =>   l_bne_content_col.user_name              ,
		                x_owner                =>   l_bne_content_col.owner                  ,
		                x_last_update_date     =>   l_bne_content_col.last_update_date       ,
		                x_custom_mode          =>   null         ,
		                x_read_only_flag       =>   l_bne_content_col.read_only_flag
		        );

		  END LOOP; -- contents columns

		  -- fnd_file.put_line(Fnd_file.LOG,'3.3.Creating the bne_stored_sql...');
		  l_step := 'Stored Sql Creation';
		  FOR l_bne_stored_sql in c_bne_stored_sql (l_bne_content.content_code)
		      LOOP
		      bne_stored_sql_pkg.load_row(
		                x_content_asn          =>   'PER'           ,
		                x_content_code         =>   l_new_content_code       ,
		                x_object_version_number=>   1  ,
		                x_query                =>   l_bne_stored_sql.query                  ,
		                x_owner                =>   l_bne_stored_sql.owner                  ,
		                x_last_update_date     =>   l_bne_stored_sql.last_update_date       ,
		                x_custom_mode          =>   null          ,
		                x_query_app_asn        =>   l_bne_stored_sql.bne_query_query_asn          ,
		                x_query_code           =>   l_bne_stored_sql.query_code
		        );

  		END LOOP; -- bne_stored_sql

  	END LOOP; -- contents

  	 fnd_file.put_line(Fnd_file.LOG,'4.Creating the mapping...');
	  l_step := 'Mapping Creation';
	  FOR l_bne_mapping in c_bne_mappings
	      LOOP
	      bne_mappings_pkg.load_row(
	                x_mapping_asn             =>   l_bne_mapping.application_short_name               ,
	                x_mapping_code            =>   l_new_mapping_code   ,
	                x_integrator_asn          =>   'PER'          ,
	                x_integrator_code         =>   l_new_integrator_code   ,
	                x_reporting_flag          =>   l_bne_mapping.reporting_flag            ,
	                x_reporting_interface_asn =>   l_bne_mapping.reporting_interface_asn   ,
	                x_reporting_interface_code=>   l_bne_mapping.reporting_interface_code  ,
	                x_user_name               =>   l_bne_mapping.user_name                 ,
	                x_object_version_number   =>   1     ,
	                x_owner                   =>   l_bne_mapping.owner                     ,
	                x_last_update_date        =>   l_bne_mapping.last_update_date         ,
	                x_custom_mode             =>   null
	        );
	       --  fnd_file.put_line(Fnd_file.LOG,'4.2.Creating the mapping lines...');
		  l_step := 'Mapping Lines Creation';
		  FOR l_bne_mapping_line in c_bne_mapping_lines (l_bne_mapping.mapping_code)
		      LOOP
		      bne_mapping_lines_pkg.load_row(
		                x_mapping_asn          =>   'PER'         ,
		                x_mapping_code         =>   l_new_mapping_code      ,
		                x_interface_asn        =>   l_bne_mapping_line.interface_asn          ,
		                x_interface_code       =>   l_new_interface_code      ,
		                x_interface_seq_num    =>   l_bne_mapping_line.interface_seq_num      ,
		                x_decode_flag          =>   l_bne_mapping_line.decode_flag            ,
		                x_object_version_number=>   1 ,
		                x_sequence_num         =>   l_bne_mapping_line.sequence_num           ,
		                x_content_asn          =>   l_bne_mapping_line.content_asn            ,
		                x_content_code         =>   l_new_content_code         ,
		                x_content_seq_num      =>   l_bne_mapping_line.content_seq_num        ,
		                x_owner                =>   l_bne_mapping_line.owner                  ,
		                x_last_update_date     =>   l_bne_mapping_line.last_update_date     ,
		                x_custom_mode          =>   null
		        );

  		END LOOP; -- mapping lines.

  	END LOOP;  --mapping

  	   fnd_file.put_line(Fnd_file.LOG,'5.Creating the layouts...');
  	  l_step := 'Layout Creation';
	  l_layout_count := 1;
	    FOR l_bne_layout in c_bne_layouts
	        LOOP
		l_new_layout_code := 'BEN_CWB_WS_LYT' || l_layout_count || l_suffix;
		l_layout_count := l_layout_count + 1;
	        bne_layouts_pkg.load_row(
		          x_layout_asn                 =>   l_bne_layout.application_short_name               ,
		          x_layout_code                =>   l_new_layout_code         ,
		          x_object_version_number      =>   1    ,
		          x_stylesheet_asn             =>   l_bne_layout.stylesheet_asn           ,
		          x_stylesheet_code            =>   l_bne_layout.stylesheet_code          ,
		          x_integrator_asn             =>   'PER'          ,
		          x_integrator_code            =>   l_new_integrator_code          ,
		          x_style                      =>   l_bne_layout.style                    ,
		          x_style_class                =>   l_bne_layout.style_class              ,
		          x_reporting_flag             =>   l_bne_layout.reporting_flag           ,
		          x_reporting_interface_asn    =>   l_bne_layout.reporting_interface_asn  ,
		          x_report_interface_code      =>   l_bne_layout.reporting_interface_code    ,
		          x_user_name                  =>   l_bne_layout.user_name                ,
		          x_owner                      =>   l_bne_layout.owner                    ,
		          x_last_update_date           =>   l_bne_layout.last_update_date        ,
		          x_custom_mode                =>   null             ,
		          x_create_doc_list_asn        =>   l_bne_layout.create_doc_list_asn      ,
		          x_create_doc_list_code       =>   l_bne_layout.create_doc_list_code
	        );
	        l_step := 'Layout Block Creation';
	        FOR l_bne_layout_block in c_bne_layout_blocks(l_bne_layout.layout_code)
		        LOOP
		        bne_layout_blocks_pkg.load_row(
			          x_layout_asn                 =>   l_bne_layout.application_short_name              ,
			          x_layout_code                =>   l_new_layout_code          ,
			          x_block_id                   =>   l_bne_layout_block.block_id                ,
			          x_object_version_number      =>   1  ,
			          x_parent_id                  =>   l_bne_layout_block.parent_id               ,
			          x_layout_element             =>   l_bne_layout_block.layout_element          ,
			          x_style_class                =>   l_bne_layout_block.style_class             ,
			          x_style                      =>   l_bne_layout_block.style                   ,
			          x_row_style_class            =>   l_bne_layout_block.row_style_class         ,
			          x_row_style                  =>   l_bne_layout_block.row_style               ,
			          x_col_style_class            =>   l_bne_layout_block.col_style_class         ,
			          x_col_style                  =>   l_bne_layout_block.col_style               ,
			          x_prompt_displayed_flag      =>   l_bne_layout_block.prompt_displayed_flag   ,
			          x_prompt_style_class         =>   l_bne_layout_block.prompt_style_class      ,
			          x_prompt_style               =>   l_bne_layout_block.prompt_style            ,
			          x_hint_displayed_flag        =>   l_bne_layout_block.hint_displayed_flag     ,
			          x_hint_style_class           =>   l_bne_layout_block.hint_style_class        ,
			          x_hint_style                 =>   l_bne_layout_block.hint_style              ,
			          x_orientation                =>   l_bne_layout_block.orientation             ,
			          x_layout_control             =>   l_bne_layout_block.layout_control          ,
			          x_display_flag               =>   l_bne_layout_block.display_flag            ,
			          x_blocksize                  =>   l_bne_layout_block.blocksize               ,
			          x_minsize                    =>   l_bne_layout_block.minsize                 ,
			          x_maxsize                    =>   l_bne_layout_block.maxsize                 ,
			          x_sequence_num               =>   l_bne_layout_block.sequence_num            ,
			          x_prompt_colspan             =>   l_bne_layout_block.prompt_colspan          ,
			          x_hint_colspan               =>   l_bne_layout_block.hint_colspan            ,
			          x_row_colspan                =>   l_bne_layout_block.row_colspan             ,
			          x_summary_style_class        =>   l_bne_layout_block.summary_style_class     ,
			          x_summary_style              =>   l_bne_layout_block.summary_style           ,
			          x_title_style_class          =>   l_bne_layout_block.title_style_class       ,
			          x_title_style                =>   l_bne_layout_block.title_style             ,
			          x_user_name                  =>   l_bne_layout_block.user_name               ,
			          x_prompt_above               =>   l_bne_layout_block.prompt_above            ,
			          x_owner                      =>   l_bne_layout_block.owner                   ,
			          x_last_update_date           =>   l_bne_layout_block.last_update_date        ,
			          x_custom_mode                =>   null
	        	);
	        	l_step := 'Layout Columns Creation';
	        	FOR l_bne_layout_col in c_bne_layout_cols(l_bne_layout.layout_code,l_bne_layout_block.block_id)
			        LOOP
			        BNE_LAYOUT_COLS_PKG.LOAD_ROW(
				          x_layout_asn                 =>   l_bne_layout.application_short_name        ,
				          x_layout_code                =>   l_new_layout_code    ,
				          x_block_id                   =>   l_bne_layout_block.block_id            ,
				          x_sequence_num               =>   l_bne_layout_col.sequence_num        ,
				          x_object_version_number      =>   1  ,
				          x_interface_asn              =>   l_bne_layout_col.interface_asn       ,
				          x_interface_code             =>   l_new_interface_code  ,
				          x_interface_seq_num          =>   l_bne_layout_col.interface_seq_num   ,
				          x_style_class                =>   l_bne_layout_col.style_class         ,
				          x_hint_style                 =>   l_bne_layout_col.hint_style          ,
				          x_hint_style_class           =>   l_bne_layout_col.hint_style_class    ,
				          x_prompt_style               =>   l_bne_layout_col.prompt_style        ,
				          x_prompt_style_class         =>   l_bne_layout_col.prompt_style_class  ,
				          x_default_type               =>   l_bne_layout_col.default_type        ,
				          x_default_value              =>   l_bne_layout_col.default_value       ,
				          x_display_width              =>   l_bne_layout_col.display_width       ,
				          x_style                      =>   l_bne_layout_col.style               ,
				          x_read_only_flag             =>   l_bne_layout_col.read_only_flag      ,
				          x_owner                      =>   l_bne_layout_col.owner               ,
				          x_last_update_date           =>   l_bne_layout_col.last_update_date   ,
				          x_custom_mode                =>   null
	        		);

	  		END LOOP; -- layout cols

	  	END LOOP; -- layout block

  	END LOOP; -- layouts

  	 fnd_file.put_line(Fnd_file.LOG,'6.Creating the secured objects...');
  	l_step := 'Secured objects Creation';
	  FOR l_bne_secured_object in c_bne_secured_objects
	  	LOOP
	        bne_secured_objects_pkg.load_row(
		          x_secured_object_asn   =>   l_bne_secured_object.application_short_name     ,
		          x_secured_object_code  =>   l_new_integrator_code    ,
		          x_secured_object_type  =>   l_bne_secured_object.object_type    ,
		          x_object_version_number=>   1  ,
		          x_security_rule_app_id =>   l_bne_secured_object.rule_security_rule_asn   ,
		          x_security_rule_code   =>   l_new_integrator_code     ,
		          x_owner                =>   l_bne_secured_object.owner                  ,
		          x_last_update_date     =>   l_bne_secured_object.last_update_date       ,
		          x_custom_mode          =>   null
	        );
	        l_step := 'Security rule Creation';
	        FOR l_bne_security_rule in c_bne_security_rules (l_bne_secured_object.rule_security_rule_code)
	  		LOOP
	  		bne_security_rules_pkg.load_row(
			          x_security_rule_asn    =>   l_bne_security_rule.application_short_name     ,
			          x_security_rule_code   =>
l_new_integrator_code,
			          x_object_version_number=>   1 ,
			          x_security_type        =>   l_bne_security_rule.security_type         ,
			          x_security_value       =>   l_bne_security_rule.security_value        ,
			          x_owner                =>   l_bne_security_rule.owner                 ,
			          x_last_update_date     =>   l_bne_security_rule.last_update_date      ,
			          x_custom_mode          =>  null
	        	);
	  	END LOOP;  -- security_rule

  	END LOOP; -- secured objects.

  END LOOP; -- integrator

   update ben_cwb_pl_dsgn set custom_integrator = l_new_integrator_code
   where pl_id = p_group_pl_id and pl_id = group_pl_id
   and oipl_id = -1 and group_oipl_id = -1;

   COMMIT;
   fnd_file.put_line(Fnd_file.LOG,'Successfully created the Integrator Setup');

  EXCEPTION
        WHEN OTHERS
        THEN
	       fnd_file.put_line(Fnd_file.LOG,'Error at step : '||l_step);
           fnd_file.put_line(Fnd_file.LOG,'Error in copy_integrator : '||SQLERRM);
          ROLLBACK TO copy_integrator;
    END;
--
-------------------------- copy_integrator ----------------------
--



END ben_cwb_integrator_copy;


/
