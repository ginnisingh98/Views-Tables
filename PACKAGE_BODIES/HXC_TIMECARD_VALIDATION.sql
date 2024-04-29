--------------------------------------------------------
--  DDL for Package Body HXC_TIMECARD_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TIMECARD_VALIDATION" as
/* $Header: hxctimevalid.pkb 120.2 2005/07/06 12:08:29 gpaytonm noship $ */

type retrieval_ref_cursor IS ref cursor;

   Function get_otm_app_attributes
              (p_attributes in            hxc_attribute_table_type,
               p_messages   in out nocopy hxc_message_table_type)
      return hxc_self_service_time_deposit.app_attributes_info is

      cursor c_deposit_process is
        select deposit_process_id
          from hxc_deposit_processes
         where name = 'OTL Deposit Process';

      l_deposit_process_id hxc_deposit_processes.deposit_process_id%type;
      l_app_attributes     hxc_self_service_time_deposit.app_attributes_info;

   begin

      open c_deposit_process;
      fetch c_deposit_process into l_deposit_process_id;
      if(c_deposit_process%notfound) then
         close c_deposit_process;
         hxc_timecard_message_helper.addErrorToCollection
            (p_messages,
             'HXC_NO_OTL_DEPOSIT_PROC',
             hxc_timecard.c_error,
             null,
             null,
             hxc_timecard.c_hxc,
             null,
             null,
             null,
             null
             );

      else
         close c_deposit_process;

         l_app_attributes :=
            hxc_app_attribute_utils.create_app_attributes
              (p_attributes           => p_attributes,
               p_retrieval_process_id => null,
               p_deposit_process_id   => l_deposit_process_id
               );
      end if;

      return l_app_attributes;

   end get_otm_app_attributes;

   Function find_retrieval_process_id
              (p_time_recipient_id
                  in hxc_time_recipients.time_recipient_id%type,
               p_retrieval_function
                  in hxc_time_recipients.application_retrieval_function%type)
      Return number is

      c_ret_pro              retrieval_ref_cursor;
      l_sql                  VARCHAR2(32000);
      l_retrieval_process_id hxc_retrieval_processes.retrieval_process_id%type;

   Begin

      l_sql := 'select retrieval_process_id
                  from hxc_retrieval_processes
                  where time_recipient_id = '|| p_time_recipient_id
             ||' and name = '||p_retrieval_function;

      open c_ret_pro for l_sql;
      fetch c_ret_pro into l_retrieval_process_id;

      if c_ret_pro%notfound then
         close c_ret_pro;
         fnd_message.set_name('hxc','hxc_xxxxx_no_app_ret_proc_name');
         fnd_msg_pub.add;
      else
         close c_ret_pro;
      end if;

      return l_retrieval_process_id;

   End find_retrieval_process_id;

   Function recipients
              (p_application_set_id in number)
      Return recipient_application_table is

      cursor csr_time_recipients(p_application_set_id in number) is
        select tr.time_recipient_id,
               tr.name,
               tr.application_retrieval_function,
               tr.application_update_process,
               tr.appl_validation_process
          from hxc_time_recipients tr,
               hxc_application_set_comps_v asc1
         where p_application_set_id = asc1.application_set_id
           and asc1.time_recipient_id = tr.time_recipient_id
           and tr.application_retrieval_function is not null;

      l_appl_recipients recipient_application_table;
      l_index           pls_integer;

   Begin

      l_index := 0;
      for recip_rec in csr_time_recipients(p_application_set_id) loop
         l_index := l_index +1;
         l_appl_recipients(l_index).time_recipient_id
            := recip_rec.time_recipient_id;
         l_appl_recipients(l_index).name := recip_rec.name;
         l_appl_recipients(l_index).application_retrieval_function
            := recip_rec.application_retrieval_function;
         l_appl_recipients(l_index).application_update_process
            := recip_rec.application_update_process;
         l_appl_recipients(l_index).appl_validation_process
            := recip_rec.appl_validation_process;
         l_appl_recipients(l_index).appl_retrieval_process_id
            := find_retrieval_process_id
                 (recip_rec.time_recipient_id,
                  recip_rec.application_retrieval_function);
      end loop;

      return l_appl_recipients;

   End recipients;

   Procedure update_attributes
               (p_attributes in out nocopy hxc_attribute_table_type) is

      l_app_attributes hxc_self_service_time_deposit.app_attributes_info;

   Begin

      l_app_attributes := hxc_self_service_time_deposit.get_app_attributes;

      hxc_app_attribute_utils.update_attributes
         (p_attributes => p_attributes,
          p_app_attributes => l_app_attributes
          );

   End update_attributes;

   Procedure set_attributes
               (p_blocks               in hxc_block_table_type,
                p_attributes           in hxc_attribute_table_type,
                p_old_style_attrs      in hxc_self_service_time_deposit.building_block_attribute_info,
                p_retrieval_process_id in number,
                p_recipients           in recipient_application_table,
                p_elp_enabled          in boolean
                ) is

      l_app_attributes hxc_self_service_time_deposit.app_attributes_info;
      l_messages       hxc_self_service_time_deposit.message_table;

   Begin

      if(p_elp_enabled) then

         l_app_attributes
            := hxc_app_attribute_utils.create_app_attributes
                 (p_blocks => p_blocks,
                  p_attributes => p_attributes,
                  p_deposit_process_id => null,
                  p_retrieval_process_id => p_retrieval_process_id,
                  p_recipients => p_recipients
                  );

      else

         l_app_attributes
            := hxc_app_attribute_utils.create_app_attributes
                 (p_attributes => p_attributes,
                  p_deposit_process_id => null,
                  p_retrieval_process_id => p_retrieval_process_id
                  );
      end if;

      hxc_self_service_time_deposit.initialize_globals;
      hxc_self_service_time_deposit.set_update_phase(true);


      hxc_self_service_time_deposit.set_app_hook_params
         (p_building_blocks
            => hxc_timecard_block_utils.convert_to_dpwr_blocks(p_blocks),
          p_app_attributes  => l_app_attributes,
          p_messages        => l_messages
          );


      hxc_self_service_time_deposit.set_g_attributes
         (p_attributes => p_old_style_attrs );


   End set_attributes;

   Procedure update_messages
               (p_messages             in out nocopy hxc_message_table_type,
                p_retrieval_process_id in            number) is

      l_messages hxc_self_service_time_deposit.message_table;
   Begin

      l_messages := hxc_self_service_time_deposit.get_messages;
      hxc_timecard_message_utils.append_old_messages
         (p_messages             => p_messages,
          p_old_messages         => l_messages,
          p_retrieval_process_id => p_retrieval_process_id
         );

   End update_messages;

   procedure update_phase
               (p_recipients       in            recipient_application_table,
                p_blocks           in            hxc_block_table_type,
                p_attributes       in out nocopy hxc_attribute_table_type,
                p_old_style_attrs  in hxc_self_service_time_deposit.building_block_attribute_info,
                p_messages         in out nocopy hxc_message_table_type,
                p_deposit_mode     in            varchar2,
                p_projects_tr_id   in            number,
                p_validate_on_save in            varchar2
                ) is

      l_elp_blocks hxc_block_table_type;
      l_index      pls_integer;
      l_upd_sql    varchar2(2000);

   Begin
      l_elp_blocks := hxc_block_table_type();
      l_index := p_recipients.first;
      Loop
         Exit when not p_recipients.exists(l_index);
         if((p_recipients(l_index).application_update_process is not null)
            AND
            (p_recipients(l_index).appl_retrieval_process_id is not null)) then

            if((p_deposit_mode <> hxc_timecard.c_save)
               OR(
                  (p_deposit_mode = hxc_timecard.c_save)
                  AND
                     (p_recipients(l_index).time_recipient_id = p_projects_tr_id)
                  )
               OR(
                  (p_deposit_mode = hxc_timecard.c_save)
                  AND
                     (p_validate_on_save = hxc_timecard.c_yes)
                  )) then

               set_attributes
                  (p_blocks,
                   p_attributes,
                   p_old_style_attrs,
                   p_recipients(l_index).appl_retrieval_process_id,
                   p_recipients,
                   false
                   );

               l_upd_sql := 'BEGIN '||fnd_global.newline
                  ||p_recipients(l_index).application_update_process ||fnd_global.newline
                  ||'(p_operation => :1);'||fnd_global.newline
                  ||'END;';

               EXECUTE IMMEDIATE l_upd_sql using IN p_deposit_mode;

               update_attributes(p_attributes);

               update_messages
                  (p_messages,
                   p_recipients(l_index).appl_retrieval_process_id
                   );

            end if;

         end if;
         l_index := p_recipients.next(l_index);
      End loop;

   End update_phase;

   Procedure validate_phase
               (p_recipients       in            recipient_application_table,
                p_blocks           in            hxc_block_table_type,
                p_attributes       in out nocopy hxc_attribute_table_type,
                p_old_style_attrs  in hxc_self_service_time_deposit.building_block_attribute_info,
                p_messages         in out nocopy hxc_message_table_type,
                p_deposit_mode     in            varchar2,
                p_elp_terg_id      in            number,
                p_projects_tr_id   in            number,
                p_validate_on_save in            varchar2
                ) is

      l_elp_blocks  hxc_block_table_type;
      l_index       pls_integer;
      l_val_sql     varchar2(2000);
      l_elp_enabled boolean := false;

   Begin

      l_index := p_recipients.first;
      Loop
         Exit when not p_recipients.exists(l_index);

         if((p_recipients(l_index).appl_validation_process is not null)
            AND
            (p_recipients(l_index).appl_retrieval_process_id is not null))then

            if((p_deposit_mode <> hxc_timecard.c_save)
               OR(
                  (p_deposit_mode = hxc_timecard.c_save)
                  AND
                  (p_recipients(l_index).time_recipient_id = p_projects_tr_id)
                 )
               OR((p_deposit_mode = hxc_timecard.c_save)
                  AND
                  (p_validate_on_save = hxc_timecard.c_yes)
                 )) then

               if(p_elp_terg_id is not null) then
                  l_elp_blocks := hxc_elp_utils.build_elp_objects
                                    (p_elp_time_building_blocks =>  p_blocks,
                                     p_elp_time_attributes => p_attributes,
                                     p_time_recipient_id    =>  p_recipients(l_index).time_recipient_id
                                     );
                  l_elp_enabled := true;
               else
                  l_elp_blocks := p_blocks;
               end if;

               set_attributes
                  (l_elp_blocks,
                   p_attributes,
                   p_old_style_attrs,
                   p_recipients(l_index).appl_retrieval_process_id,
                   p_recipients,
                   l_elp_enabled
                   );

               l_val_sql := 'BEGIN '||fnd_global.newline
                  ||p_recipients(l_index).appl_validation_process ||fnd_global.newline
                  ||'(p_operation => :1);'||fnd_global.newline
                  ||'END;';

               EXECUTE IMMEDIATE l_val_sql using IN p_deposit_mode;

               update_messages
                  (p_messages,
                   p_recipients(l_index).appl_retrieval_process_id
                   );

            end if; -- is this save and PA? or non-save?

         end if;
         l_index := p_recipients.next(l_index);
      End loop;

   End validate_phase;

   Function template_name_exists
              (p_resource_id in number,
               p_name_to_check in varchar2,
               p_time_building_block_id in number,
               p_template_type in varchar2,
               p_business_group_id in varchar2
               )
      Return boolean is

      cursor c_is_dynamic_template
               (p_name_to_check in varchar2) is
        select 'Y'
          from hr_lookups
         where lookup_type = 'HXC_DYNAMIC_TEMPLATES'
           and meaning = p_name_to_check;

      cursor c_is_private_template
               (p_name_to_check in varchar2,
                p_resoure_id in number,
                p_time_building_block_id in number
                ) is
        select 'Y'
          from hxc_template_summary
         where template_type = 'PRIVATE'
           and template_id <> p_time_building_block_id
           and template_name = p_name_to_check
           and resource_id = p_resource_id;

      cursor c_is_public_template
               (p_name_to_check in varchar2,
                p_time_building_block_id in number,
                p_business_group_id in varchar2) is
        select 'Y'
          from hxc_template_summary
         where template_type = 'PUBLIC'
           and template_id <> p_time_building_block_id
           and template_name = p_name_to_check
           and business_group_id =p_business_group_id ;

      l_dummy varchar2(2);
      value boolean := false;

   Begin

      open c_is_dynamic_template(p_name_to_check);
      fetch c_is_dynamic_template into l_dummy;
      if c_is_dynamic_template%NOTFOUND then
         close c_is_dynamic_template;
         if(p_template_type = 'PRIVATE') THEN
            open c_is_private_template(p_name_to_check,p_resource_id,p_time_building_block_id);
            fetch c_is_private_template into l_dummy;
            if c_is_private_template%NOTFOUND then
               close c_is_private_template;
            else
               close c_is_private_template;
               value:=true;
            end if;
         elsif(p_template_type = 'PUBLIC') THEN
            open c_is_public_template(p_name_to_check,p_time_building_block_id,p_business_group_id);
            fetch c_is_public_template into l_dummy;
            if c_is_public_template%NOTFOUND then
               close c_is_public_template;
            else
               close c_is_public_template;
               value:=true;
            end if;
         end if;
      else
         close c_is_dynamic_template;
         value := true;
      end if;

      return value;

   end template_name_exists;

   Procedure template_validation
               (p_blocks     in out nocopy hxc_block_table_type,
                p_attributes in out nocopy hxc_attribute_table_type,
                p_messages   in out nocopy hxc_message_table_type,
                p_can_deposit   out nocopy boolean
                ) is

      l_template_index number;
      l_template_name  hxc_time_attributes.attribute1%type;
      l_security_index number;
      l_business_group_id  hxc_time_attributes.attribute1%type;

   Begin

      p_can_deposit := true;
      l_template_index := hxc_timecard_attribute_utils.get_attribute_index
                            (p_attributes,
                             hxc_timecard.c_template_attribute,
                             null
                             );
      l_security_index := hxc_timecard_attribute_utils.get_attribute_index
                            (p_attributes,
                             hxc_timecard.c_security_attribute,
                             null
                             );

      l_template_name := p_attributes(l_template_index).attribute1;
      l_business_group_id := p_attributes(l_security_index).attribute2;

      if(template_name_exists
           (p_blocks(1).resource_id
            ,l_template_name
            ,p_attributes(l_template_index).building_block_id
            ,p_attributes(l_template_index).attribute2,
            l_business_group_id)) then

         p_can_deposit := false;

         hxc_timecard_message_helper.addErrorToCollection
            (p_messages,
             'HXC_366204_TEMPLATE_NAME',
             hxc_timecard.c_error,
             null,
             'TEMPLATE_NAME&'||l_template_name,
             hxc_timecard.c_hxc,
             null,
             null,
             null,
             null
             );

      End if;

   End template_validation;

   Procedure change_late_audit_validation
      (p_old_style_blks   in            hxc_self_service_time_deposit.timecard_info,
       p_old_style_attrs in            hxc_self_service_time_deposit.building_block_attribute_info,
       p_props           in            hxc_timecard_prop_table_type,
       p_eval_start_date in            date,
       p_eval_end_date   in            date,
       p_messages        in out nocopy hxc_message_table_type
       ) is

      l_cla_terg_id  number;
      l_old_messages hxc_self_service_time_deposit.message_table;

   Begin

      l_cla_terg_id := to_number(
                         hxc_timecard_properties.find_property_value
                            (p_props,
                             'TsPerAuditRequirementsAuditRequirements',
                             null,
                             null,
                             p_eval_start_date,
                             p_eval_end_date
                             ));

      if(l_cla_terg_id is not null) then
         hxc_time_entry_rules_utils_pkg.execute_cla_time_entry_rules
            (p_time_building_blocks        =>  p_old_style_blks,
             p_time_attributes             =>  p_old_style_attrs,
             p_messages                    =>  l_old_messages,
             p_time_entry_rule_group_id    =>  l_cla_terg_id
             );

         hxc_timecard_message_utils.append_old_messages
            (p_messages             => p_messages,
             p_old_messages         => l_old_messages,
             p_retrieval_process_id => null
             );
      end if;

   End change_late_audit_validation;

   Procedure recipients_update_validation
      (p_blocks          in out nocopy hxc_block_table_type,
       p_attributes      in out nocopy hxc_attribute_table_type,
       p_old_style_blks  in            hxc_self_service_time_deposit.timecard_info,
       p_old_style_attrs in            hxc_self_service_time_deposit.building_block_attribute_info,
       p_props           in            hxc_timecard_prop_table_type,
       p_eval_date       in            date,
       p_deposit_mode    in            varchar2,
       p_resubmit        in            varchar2,
       p_messages        in out nocopy hxc_message_table_type
       ) is

      cursor c_pa_tr_id is
        select time_recipient_id
          from hxc_time_recipients
         where upper(name) = 'PROJECTS';

      l_application_set_id  number;
      l_elp_terg_id         number;
      l_eval_date           date;
      l_appl_recipients     recipient_application_table;
      l_old_messages        hxc_self_service_time_deposit.message_table;
      l_otm_attributes      hxc_self_service_time_deposit.app_attributes_info;
      l_timecard_start_time date;
      l_timecard_stop_time  date;
      l_projects_tr_id      number;
      l_validate_on_save    hxc_pref_hierarchies.attribute1%type;
      l_app_attributes hxc_self_service_time_deposit.app_attributes_info;
      l_messages       hxc_self_service_time_deposit.message_table;

   Begin

      open c_pa_tr_id;
      fetch c_pa_tr_id into l_projects_tr_id;
      close c_pa_tr_id;

      l_timecard_start_time :=
         hxc_timecard_block_utils.date_value
           (p_blocks(hxc_timecard_block_utils.find_active_timecard_index(p_blocks)).start_time);
      l_timecard_stop_time:=
         hxc_timecard_block_utils.date_value
           (p_blocks(hxc_timecard_block_utils.find_active_timecard_index(p_blocks)).stop_time);


      l_application_set_id := to_number
         (hxc_timecard_properties.find_property_value
            (p_props,
             'TsPerApplicationSetTsApplicationSet',
             null,
             null,
             l_timecard_start_time,
             l_timecard_stop_time
             ));

      l_validate_on_save :=
         hxc_timecard_properties.find_property_value
           (p_props,
            'TsPerValidateOnSaveValidateOnSave',
            null,
            null,
            l_timecard_start_time,
            l_timecard_stop_time
            );

      if(l_validate_on_save is null) then
         l_validate_on_save := hxc_timecard.c_no;
      end if;

      l_appl_recipients := recipients(l_application_set_id);

      if(l_appl_recipients.count>0) then

         hxc_app_attribute_utils.cache_mappings;

         update_phase
            (l_appl_recipients,
             p_blocks,
             p_attributes,
             p_old_style_attrs,
             p_messages,
             p_deposit_mode,
             l_projects_tr_id,
             l_validate_on_save
             );

         l_elp_terg_id := to_number
            (hxc_timecard_properties.find_property_value
                (p_props,
                 'TsPerElpRulesElpTimeEntryRuleGroup',
                 null,
                 null,
                 l_timecard_start_time,
                 l_timecard_stop_time
                 ));

         hxc_time_category_utils_pkg.push_timecard
            (p_blocks,
             p_attributes);

         if(l_elp_terg_id is not null) then
            hxc_time_entry_rules_utils_pkg.execute_elp_time_entry_rules
               (p_time_building_blocks        =>  p_blocks,
                p_time_attributes             =>  p_attributes,
                p_messages                    =>  l_old_messages,
                p_time_entry_rule_group_id    =>  l_elp_terg_id
                );
         end if;

         hxc_elp_utils.set_time_bb_appl_set_id
            (p_time_building_blocks        =>  p_blocks,
             p_time_attributes             =>  p_attributes,
             p_messages                    =>  l_old_messages,
             p_pte_terg_id                 =>  l_elp_terg_id,
             p_application_set_id          =>  l_application_set_id
             );

         hxc_timecard_message_utils.append_old_messages
            (p_messages             => p_messages,
             p_old_messages         => l_old_messages,
             p_retrieval_process_id => null
             );

         validate_phase
            (l_appl_recipients,
             p_blocks,
             p_attributes,
             p_old_style_attrs,
             p_messages,
             p_deposit_mode,
             l_elp_terg_id,
             l_projects_tr_id,
             l_validate_on_save
             );

      end if;

      l_old_messages.delete;

      -- GPM v115.12 WWB 3470294
      -- set the bld blks and app attribute structures to show the non
      -- non filtered ELP structures
      -- ARR 115.25 Now use this l_app_attributes structure of the otm
      -- validation as well, since TERs do not change the values in here
      --

      l_app_attributes := get_otm_app_attributes
         (p_attributes,
          p_messages);

      -- GPM v115.12 WWB 3470294


  -- GPM v115.26 start
  -- added calls to set_update_phase and set_g_attributes
  -- otherwise g_attributes and g_timecard are not available to
  -- TER when no recipient validation is called

  hxc_self_service_time_deposit.set_update_phase(true);

  hxc_self_service_time_deposit.set_app_hook_params
    (p_building_blocks => p_old_style_blks
    ,p_app_attributes  => l_app_attributes
    ,p_messages        => l_messages );

  hxc_self_service_time_deposit.set_update_phase(false);

  hxc_self_service_time_deposit.set_g_attributes
     ( p_attributes     =>  p_old_style_attrs );

  -- GPM v115.26 end

      hxc_time_entry_rules_utils_pkg.execute_time_entry_rules
         (p_operation => p_deposit_mode,
          p_time_building_blocks =>  p_old_style_blks,
          p_time_attributes => p_old_style_attrs,
          p_messages => l_old_messages,
          p_resubmit => p_resubmit,
          p_blocks => p_blocks,
          p_attributes => p_attributes
          );

      hxc_timecard_message_utils.append_old_messages
         (p_messages             => p_messages,
          p_old_messages         => l_old_messages,
          p_retrieval_process_id => null
          );

      --
      -- Now include the OTM validation, which was included in the set up
      -- validation called previously.
      --
      l_old_messages.delete;

      hxt_hxc_retrieval_process.otlr_validation_required
         (p_operation            => p_deposit_mode,
          p_otm_explosion        => hxc_timecard_properties.find_property_value
             (p_props,
              'TcWRulesEvaluationRulesEvaluation',
              null,
              null,
              p_eval_date
              ),
          p_otm_rtr_id           => hxc_timecard_properties.find_property_value
             (p_props,
              'TcWRulesEvaluationAppRulesEvaluation',
              null,
              null,
              p_eval_date
              ),
          p_app_set_id           => l_application_set_id,
          p_timecard_id          => p_blocks(hxc_timecard_block_utils.find_active_timecard_index(p_blocks)).time_building_block_id,
          p_timecard_ovn         => p_blocks(hxc_timecard_block_utils.find_active_timecard_index(p_blocks)).object_version_number,
          p_time_building_blocks => p_old_style_blks,
          p_time_att_info        => l_app_attributes,
          p_messages             => l_old_messages
          );

      hxc_timecard_message_utils.append_old_messages
         (p_messages             => p_messages,
          p_old_messages         => l_old_messages,
          p_retrieval_process_id => null
          );

   End recipients_update_validation;

   Procedure recipients_update_validation
      (p_blocks       in out nocopy hxc_block_table_type,
       p_attributes   in out nocopy hxc_attribute_table_type,
       p_messages     in out nocopy hxc_message_table_type,
       p_props        in            hxc_timecard_prop_table_type,
       p_deposit_mode in            varchar2,
       p_resubmit     in            varchar2
       ) is

      l_eval_date       date;
      l_old_style_blks  HXC_SELF_SERVICE_TIME_DEPOSIT.timecard_info;
      l_old_style_attrs hxc_self_service_time_deposit.building_block_attribute_info;

   Begin
      l_old_style_blks := HXC_TIMECARD_BLOCK_UTILS.convert_to_dpwr_blocks(p_blocks);
      l_old_style_attrs := HXC_TIMECARD_ATTRIBUTE_UTILS.convert_to_dpwr_attributes(p_attributes);
      l_eval_date := fnd_date.canonical_to_date(p_blocks(hxc_timecard_block_utils.find_active_timecard_index(p_blocks)).start_time);

      recipients_update_validation
         (p_blocks          => p_blocks,
          p_attributes      => p_attributes,
          p_old_style_blks  => l_old_style_blks,
          p_old_style_attrs => l_old_style_attrs,
          p_props           => p_props,
          p_eval_date       => l_eval_date,
          p_deposit_mode    => p_deposit_mode,
          p_resubmit        => p_resubmit,
          p_messages        => p_messages
          );

   End recipients_update_validation;

   Procedure  data_set_validation
      (p_blocks        in out nocopy hxc_block_table_type,
       p_messages      in out nocopy hxc_message_table_type
       ) is

      cursor c_data_set( p_stop_time date) is
        select 1
          from hxc_data_sets  d
         where p_stop_time between d.start_date and d.end_date
           and status in ('OFF_LINE','BACKUP_IN_PROGRESS','RESTORE_IN_PROGRESS');

      l_timecard_start_time date;
      l_timecard_stop_time  date;
      l_dummy               number;

   Begin

      l_timecard_start_time := hxc_timecard_block_utils.date_value
         (p_blocks(hxc_timecard_block_utils.find_active_timecard_index(p_blocks)).start_time);

      l_timecard_stop_time := hxc_timecard_block_utils.date_value
         (p_blocks(hxc_timecard_block_utils.find_active_timecard_index(p_blocks)).stop_time);

      open c_data_set(l_timecard_stop_time);
      fetch c_data_set into l_dummy;
      if c_data_set%found then
         close c_data_set;
         hxc_timecard_message_helper.addErrorToCollection
            (p_messages,
             'HXC_TC_OFFLINE_PERIOD_CONFLICT',
             hxc_timecard.c_error,
             null,
             null,
             hxc_timecard.c_hxc,
             p_blocks(hxc_timecard_block_utils.find_active_timecard_index(p_blocks)).time_building_block_id,
             p_blocks(hxc_timecard_block_utils.find_active_timecard_index(p_blocks)).object_version_number,
             null,
             null
             );
      else
         close c_data_set;
      end if;
   End data_set_validation;

   Procedure timecard_validation
      (p_blocks       in out nocopy hxc_block_table_type,
       p_attributes   in out nocopy hxc_attribute_table_type,
       p_messages     in out nocopy hxc_message_table_type,
       p_props        in            hxc_timecard_prop_table_type,
       p_deposit_mode in            varchar2,
       p_resubmit     in            varchar2
       ) is

      l_tc_start_date      date;
      l_tc_end_date        date;
      l_old_style_blks     HXC_SELF_SERVICE_TIME_DEPOSIT.timecard_info;
      l_old_style_attrs    hxc_self_service_time_deposit.building_block_attribute_info;

   Begin
      l_old_style_blks := HXC_TIMECARD_BLOCK_UTILS.convert_to_dpwr_blocks
         (p_blocks);

      l_old_style_attrs := HXC_TIMECARD_ATTRIBUTE_UTILS.convert_to_dpwr_attributes
         (p_attributes);

      l_tc_start_date:= fnd_date.canonical_to_date
         (p_blocks(hxc_timecard_block_utils.find_active_timecard_index(p_blocks)).start_time);
      l_tc_end_date  := fnd_date.canonical_to_date
         (p_blocks(hxc_timecard_block_utils.find_active_timecard_index(p_blocks)).stop_time);

      recipients_update_validation
         (p_blocks          => p_blocks,
          p_attributes      => p_attributes,
          p_old_style_blks  => l_old_style_blks,
          p_old_style_attrs => l_old_style_attrs,
          p_props           => p_props,
          p_eval_date       => l_tc_start_date,
          p_deposit_mode    => p_deposit_mode,
          p_resubmit        => p_resubmit,
          p_messages        => p_messages
         );

      change_late_audit_validation
         (p_old_style_blks  => l_old_style_blks,
          p_old_style_attrs => l_old_style_attrs,
          p_props           => p_props,
          p_eval_start_date => l_tc_start_date,
          p_eval_end_date   => l_tc_end_date,
          p_messages        => p_messages
         );

      data_set_validation
         (p_blocks       => p_blocks,
          p_messages     => p_messages
          );

   End timecard_validation;

   procedure deposit_validation
      (p_blocks       in out nocopy hxc_block_table_type,
       p_attributes   in out nocopy hxc_attribute_table_type,
       p_messages     in out nocopy hxc_message_table_type,
       p_props        in            hxc_timecard_prop_table_type,
       p_deposit_mode in            varchar2,
       p_template     in            varchar2,
       p_resubmit     in            varchar2,
       p_can_deposit     out nocopy boolean
      ) is

   Begin

      if(p_template = 'Y') then
         if(p_deposit_mode <> hxc_timecard.c_delete) then
            template_validation
               (p_blocks     => p_blocks,
                p_attributes => p_attributes,
                p_messages   => p_messages,
                p_can_deposit=> p_can_deposit
                );
         end if;
      else
         timecard_validation
            (p_blocks       => p_blocks,
             p_attributes   => p_attributes,
             p_messages     => p_messages,
             p_props        => p_props,
             p_deposit_mode => p_deposit_mode,
             p_resubmit     => p_resubmit
             );
      end if;

   End deposit_validation;

end hxc_timecard_validation;

/
