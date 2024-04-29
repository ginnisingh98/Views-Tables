--------------------------------------------------------
--  DDL for Package Body MSC_SUPPLIER_PWB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_SUPPLIER_PWB" as
/*  $Header: MSCFNSCB.pls 120.0 2005/05/25 19:09:21 appldev noship $ */


  -- 1 valid <= 0 invalid input
  function valid_supplier_type(p_unique_id in varchar2,
                            p_user_id in number,
                            p_supplier_id in number,
                            p_supplier_site_id in number)
            return number is

    cursor c_user_resp (p_user number, p_resp number, p_app number) is
    select count(*)
    from fnd_user_resp_groups
    where user_id = p_user
    and responsibility_id= p_resp
    and responsibility_application_id = p_app ;

    l_supplier_id number;
    l_count number := 0;
    l_retval boolean := false;
  begin
     --check whether this user has supplier resp
     open c_user_resp(fnd_global.user_id, 23815, 724);
     fetch c_user_resp into l_count;
     close c_user_resp ;

     if ( l_count = 0 ) then
       return -3;
     end if;

     --check whether supplier org mode
      l_retval := modelled_as_org;
     if (not l_retval) then
       --check whether supplier mode
       l_supplier_id := modelled_as_supplier;
       if ( l_supplier_id is null) then
          return -1; --invalid supplier
       else
          --check supplier has any plans
          l_retval :=check_supplier_plans(l_supplier_id);
          if (not l_retval) then
            return -2;  --supplier does not have plans
          end if;
       end if;
     end if;
    return 1;
  end valid_supplier_type ;

  procedure enable_fn_sec is
    l_item_grp_name   constant varchar2(30) := 'MSC_ITEMS_FN';
    l_res_grp_name    constant varchar2(30) := 'MSC_RES_FN';
    l_sup_grp_name    constant varchar2(30) := 'MSC_SUP_FN';
    l_schain_grp_name constant varchar2(30) := 'MSC_SCHAIN_FN';
    l_plan_grp_name   constant varchar2(30) := 'MSC_PLAN_FN';
    l_gc_grp_name     constant varchar2(30) := 'MSC_GC_FN';
    l_kpi_grp_name    constant varchar2(30) := 'MSC_KPI_FN';
    l_peg_grp_name    constant varchar2(30) := 'MSC_PEG_FN';
    l_exepln_grp_name constant varchar2(30) := 'MSC_EXEPLN_FN';
    l_replan_grp_name constant varchar2(30) := 'MSCREPLAN';
    l_cp_grp_name     constant varchar2(30) := 'MSC_CP_FN';
    l_opt_grp_name    constant varchar2(30) := 'MSC_OPT_FN';
    l_undo_grp_name   constant varchar2(30) := 'MSC_UNDO_FN';
    l_bom_grp_name    constant varchar2(30) := 'MSC_BOM_FN';
    l_invlv_grp_name  constant varchar2(30) := 'MSCINVLV';
    l_res_batch_name  constant varchar2(30) := 'MSC_RES_BATCH_FN';
   /*---------------------Enhancement for LA by :Satyagi---------*/
    l_liability_name  constant varchar2(30) := 'MSC_LIABILITY_FN';
   /*----------------------Enhancement for LA by :Satyagi---------*/

  begin

    g_item_grp := fnd_function.test(l_item_grp_name);
    if ( g_item_grp ) then
      g_item_fn := 1;
      --utham 2777366 always disable for cp user..wrong
      g_psub_fn := 1;
    end if;

    g_res_grp := fnd_function.test(l_res_grp_name);
    if ( g_res_grp ) then
      g_res_fn := 1;
    end if;

    g_opt_grp := fnd_function.test(l_opt_grp_name);
    if ( g_opt_grp ) then
     g_option_fn := 1;
     g_pref_fn := 1;
    end if;

    g_bom_grp := fnd_function.test(l_bom_grp_name);
    if ( g_bom_grp ) then
      g_oper_fn := 1;
      g_comp_fn := 1;
      g_used_fn := 1;
      g_peff_fn := 1;
      g_coprod_fn := 1;
    end if;
    g_cp_grp := fnd_function.test(l_cp_grp_name);
    if ( g_cp_grp ) then
     g_23b_fn := 1;
    end if;
    g_undo_grp := fnd_function.test(l_undo_grp_name);
    if ( g_undo_grp ) then
      g_undo_fn := 1;
    end if;
    g_sup_grp := fnd_function.test(l_sup_grp_name);
    if ( g_sup_grp ) then
      g_supp_fn := 1;
    end if;
    g_schain_grp := fnd_function.test(l_schain_grp_name);
    if ( g_schain_grp ) then
      g_bill_fn := 1;
      g_sour_fn := 1;
      g_dest_fn := 1;
    end if;
    g_plan_grp := fnd_function.test(l_plan_grp_name);
    if ( g_plan_grp ) then
      g_excp_fn := 1;
      g_hz_fn := 1;
      g_vert_fn := 1;
      g_28_fn := 1;
      g_pcr_fn := 1;
      --utham 2777366 always disable for cp user ..wrong
      g_ss_fn := 1;
      g_21a_fn := 1;
    end if;
    g_gc_grp := fnd_function.test(l_gc_grp_name);
    if ( g_gc_grp ) then
      g_gc_fn := 1;
    end if;
    g_kpi_grp := fnd_function.test(l_kpi_grp_name);
    if ( g_kpi_grp ) then
      g_kpi_fn := 1;
    end if;
    g_peg_grp := fnd_function.test(l_peg_grp_name);
    if ( g_peg_grp ) then
      g_peg_fn := 1;
    end if;
    g_exepln_grp := fnd_function.test(l_exepln_grp_name);
    if ( g_exepln_grp ) then
      g_23a_fn := 1;
      g_21b_fn := 1;
    end if;
    g_replan_grp := fnd_function.test(l_replan_grp_name);
    if ( g_replan_grp ) then
      g_replan_fn := 1;
    end if;
    g_invlv_grp := fnd_function.test(l_invlv_grp_name);
    if ( g_invlv_grp ) then
      g_invlv_fn := 1;
    end if;
    g_res_batch_grp := fnd_function.test(l_res_batch_name);
    if ( g_res_batch_grp ) then
      g_res_batch_fn := 1;
    end if;
   /*---------------------Enhancement for LA by :Satyagi---------*/
    g_liability_grp := fnd_function.test(l_liability_name);
    if ( g_liability_grp ) then
      g_liability_fn := 1;
    end if;
   /*----------------------Enhancement for LA by :Satyagi---------*/
  end enable_fn_sec ;

  function get_fn_status(p_fn_name in varchar2) return NUMBER IS
   l_excp_fn_name		constant varchar2(30) := 'MSC_EXCP_FN';
   l_res_fn_name		constant varchar2(30) := 'MSC_RES_FN';
   l_supp_fn_name		constant varchar2(30) := 'MSC_SUPPLIER_FN';
   l_oper_fn_name		constant varchar2(30) := 'MSC_OPER_FN';
   l_kpi_fn_name		constant varchar2(30) := 'MSC_KPI_FN';
   l_peg_fn_name		constant varchar2(30) := 'MSC_PEG_FN';
   l_hz_fn_name			constant varchar2(30) := 'MSC_HZ_FN';
   l_vert_fn_name		constant varchar2(30) := 'MSC_VERT_FN';
   l_gc_fn_name			constant varchar2(30) := 'MSC_GC_FN';
   l_bill_fn_name		constant varchar2(30) := 'MSC_BILL_FN';
   l_item_fn_name		constant varchar2(30) := 'MSC_ITEM_FN';
   l_comp_fn_name		constant varchar2(30) := 'MSC_COMP_FN';
   l_used_fn_name		constant varchar2(30) := 'MSC_USED_FN';
   l_sour_fn_name		constant varchar2(30) := 'MSC_SOUR_FN';
   l_dest_fn_name		constant varchar2(30) := 'MSC_DEST_FN';
   l_peff_fn_name		constant varchar2(30) := 'MSC_PEFF_FN';
   l_coprod_fn_name		constant varchar2(30) := 'MSC_COPROD_FN';
   l_ss_fn_name			constant varchar2(30) := 'MSC_SS_FN';
   l_psub_fn_name		constant varchar2(30) := 'MSC_PSUB_FN';
   l_replan_fn_name		constant varchar2(30) := 'MSC_REPLAN_FN';
   l_21a_fn_name		constant varchar2(30) := 'MSC_21A_FN';
   l_21b_fn_name		constant varchar2(30) := 'MSC_21B_FN';
   l_option_fn_name		constant varchar2(30) := 'MSC_OPTION_FN';
   l_23a_fn_name		constant varchar2(30) := 'MSC_23A_FN';
   l_23b_fn_name		constant varchar2(30) := 'MSC_23B_FN';
   l_pref_fn_name		constant varchar2(30) := 'MSC_PREF_FN';
   l_undo_fn_name		constant varchar2(30) := 'MSC_UNDO_FN';
   l_pcr_fn_name		constant varchar2(30) := 'MSC_PCR_FN';
   l_28_fn_name			constant varchar2(30) := 'MSC_28_FN';
   l_cal_fn_name		constant varchar2(30) := 'MSC_CAL_FN';
   l_invlv_fn_name		constant varchar2(30) := 'MSC_MSCINVLV';
   l_res_batch_name             constant varchar2(30) := 'MSC_RES_BATCH_FN';
   /*---------------------Enhancement for LA by :Satyagi---------*/
   l_liability_name              constant varchar2(30) := 'MSC_LIABILITY_FN';
  /* ----------------------Enhancement for LA by :Satyagi---------*/
  begin
   if (p_fn_name = l_excp_fn_name ) then
     return g_excp_fn;
   elsif (p_fn_name = l_res_batch_name ) then
     return g_res_batch_fn;
   /*---------------------Enhancement for LA by :Satyagi---------*/
   elsif (p_fn_name = l_liability_name ) then
     return g_liability_fn;
  /*----------------------Enhancement for LA by :Satyagi---------*/
   elsif (p_fn_name = l_res_fn_name ) then
     return g_res_fn;
   elsif (p_fn_name = l_supp_fn_name ) then
     return g_supp_fn;
   elsif (p_fn_name = l_oper_fn_name ) then
     return g_oper_fn;
   elsif (p_fn_name = l_kpi_fn_name ) then
     return g_kpi_fn;
   elsif (p_fn_name = l_peg_fn_name ) then
     return g_peg_fn;
   elsif (p_fn_name = l_hz_fn_name ) then
     return g_hz_fn;
   elsif (p_fn_name = l_vert_fn_name ) then
     return g_vert_fn;
   elsif (p_fn_name = l_gc_fn_name ) then
     return g_gc_fn;
   elsif (p_fn_name = l_bill_fn_name ) then
     return g_bill_fn;
   elsif (p_fn_name = l_item_fn_name ) then
     return g_item_fn;
   elsif (p_fn_name = l_comp_fn_name ) then
     return g_comp_fn;
   elsif (p_fn_name = l_used_fn_name ) then
     return g_used_fn;
   elsif (p_fn_name = l_sour_fn_name ) then
     return g_sour_fn;
   elsif (p_fn_name = l_dest_fn_name ) then
     return g_dest_fn;
   elsif (p_fn_name = l_peff_fn_name ) then
     return g_peff_fn;
   elsif (p_fn_name = l_coprod_fn_name ) then
     return g_coprod_fn;
   elsif (p_fn_name = l_ss_fn_name ) then
     return g_ss_fn;
   elsif (p_fn_name = l_psub_fn_name ) then
     return g_psub_fn;
   elsif (p_fn_name = l_replan_fn_name ) then
     return g_replan_fn;
   elsif (p_fn_name = l_21a_fn_name ) then
     return g_21a_fn;
   elsif (p_fn_name = l_21b_fn_name ) then
     return g_21b_fn;
   elsif (p_fn_name = l_option_fn_name ) then
     return g_option_fn;
   elsif (p_fn_name = l_23a_fn_name ) then
     return g_23a_fn;
   elsif (p_fn_name = l_23b_fn_name ) then
     return g_23b_fn;
   elsif (p_fn_name = l_pref_fn_name ) then
     return g_pref_fn;
   elsif (p_fn_name = l_undo_fn_name ) then
     return g_undo_fn;
   elsif (p_fn_name = l_pcr_fn_name ) then
     return g_pcr_fn;
   elsif (p_fn_name = l_28_fn_name ) then
     return g_pcr_fn;
   elsif (p_fn_name = l_cal_fn_name ) then
     return g_cal_fn;
   elsif (p_fn_name = l_invlv_fn_name ) then
     return g_invlv_fn;
   else
     --Acutally invalid input from the caller
     return -1;
   end if;
  end get_fn_status ;

  procedure invoke_mscfnscwb( p_resp_app in varchar2,
                              p_resp_key in varchar2,
                              p_secgrp_key in varchar2,
                              p_err_msg out nocopy varchar2,
                              p_url out nocopy varchar2) is

   l_apps_web_agent varchar2(250);
   l_plsql_proc varchar2(250);
   l_actual_params varchar2(250);
   l_temp varchar2(250);
   l_length number ;
   l_amp varchar2(2) := fnd_global.local_chr(38);
   l_found number;

  begin
   p_err_msg := null; --initialize to null
   p_url := null;

   l_apps_web_agent := fnd_profile.value('APPS_WEB_AGENT');

   --check if the last char is '/', else append
   l_length := length(l_apps_web_agent);
   l_temp := substr(l_apps_web_agent,l_length,1);
   l_found :=  instr(l_temp,'/');
   if ( l_found <= 0 )  then
     l_apps_web_agent := l_apps_web_agent||'/';
     --dbms_output.put_line(' l_apps_web_agent appended  '||l_apps_web_agent );
   end if;

   l_plsql_proc := 'fnd_icx_launch.runforms?';
   l_actual_params := 'ICX_TICKET='||l_amp||
                    'RESP_APP='||p_resp_app||l_amp||
                    'RESP_KEY='||p_resp_key||l_amp||
                    'SECGRP_KEY='||p_secgrp_key;

   p_url := l_apps_web_agent||l_plsql_proc||l_actual_params;
   --dbms_output.put_line(' p_url  '||p_url );
  exception
    when others then
      p_err_msg := sqlerrm;
      p_url := null;
  end invoke_mscfnscwb;

  procedure launch_supplier_pwb ( p_unique_id in varchar2,
                                  p_user_id in number,
                                  p_supplier_id in number,
                                  p_supplier_site_id in number,
                                  p_err_msg out nocopy varchar2,
                                  p_url out nocopy varchar2 ) is
  l_valid_input number;
  begin
    p_err_msg := null;
    p_url := null;

    --validate the input
    l_valid_input  := msc_supplier_pwb.valid_supplier_type(p_unique_id,
                            p_user_id, p_supplier_id, p_supplier_site_id);
    if ( l_valid_input = -1 ) then
      p_err_msg := 'MSC_FSEC_INVALID_SUPPLIER';
      return;
    elsif ( l_valid_input = -2 ) then
      p_err_msg := 'MSC_FSEC_SUPPLIER_NO_PLANS';
      return;
    elsif ( l_valid_input = -3 ) then
      p_err_msg := 'MSC_FSEC_NO_RESPONSIBILITY';
      return;
    elsif ( l_valid_input < 0 ) then
      p_err_msg := 'MSC_FSEC_INVALID_INPUT';
      return;
    end if;
    --validate the input ends

    --store the context values in global vars
    g_supplier_id := p_supplier_id;
    g_supp_site_id := p_supplier_site_id;
    --g_inst_id, g_org_id, g_partner_type are set in valid_supplier_type fn


  --set the global parameters if required ..hardcoded.
  --g_resp_app   := 'MSC';
  --g_resp_key   := 'MSC_TEST_RESP';
  --g_secgrp_key := 'STANDARD';
  --g_func       := 'MSCFNSCW-VSCP';

  --build the url, based on parameters
  msc_supplier_pwb.invoke_mscfnscwb( g_resp_app,
                            g_resp_key,
                            g_secgrp_key,
                            p_err_msg,
                            p_url);
  exception
    when others then
      p_err_msg := sqlerrm;
      p_url := null;
  end launch_supplier_pwb;

  FUNCTION check_supplier_plans (p_supplier_id number) return boolean IS
    CURSOR c_supp (l_supplier_id in number) IS
    SELECT count(*)
    FROM msc_designators d,
     msc_plans p,
     msc_item_suppliers mis
    WHERE p.organization_id = d.organization_id
    AND p.sr_instance_id = d.sr_instance_id
    AND p.compile_designator = d.designator
    AND p.plan_completion_date IS NOT NULL
    AND p.data_completion_date IS NOT NULL
    AND p.plan_id <> -1
    AND nvl(d.production,2) = 1
    AND p.curr_plan_type in (1,2,3)
    AND p.plan_id = mis.plan_id
    AND p.sr_instance_id = mis.sr_instance_id
    AND p.organization_id = mis.organization_id
    AND mis.supplier_id = l_supplier_id;

   l_temp number;
  BEGIN
   open c_supp (p_supplier_id);
   fetch c_supp into l_temp;
   close c_supp;
   if (l_temp = 0 ) then
     return FALSE;
   else
     return TRUE;
   end if;

  END check_supplier_plans ;

  FUNCTION modelled_as_org return boolean IS

    CURSOR c_org IS
    select count(*)
    from fnd_user fu,
      msc_company_users mcu,
      msc_trading_partner_maps map,
      msc_company_relationships mcrs,
      msc_trading_partners mtp
    where fu.user_id = mcu.user_id
      and mcu.company_id = mcrs.object_id
      and mcrs.subject_id = 1
      and mcrs.relationship_type = 2
      and mcrs.relationship_id = map.company_key
      and map.map_type = 1
      and map.tp_key = mtp.modeled_supplier_id
      and mtp.partner_type = 3
     and fu.user_id = fnd_global.user_id;
     l_temp number;
  BEGIN
   open c_org;
   fetch c_org into l_temp;
   close c_org;

   if (l_temp = 0 ) then
     return FALSE;
   else
     return TRUE;
   end if;
  END modelled_as_org ;

  FUNCTION modelled_as_supplier return number IS

   CURSOR c_sup IS
   select mtp.sr_instance_id, mtp.partner_id
    from fnd_user fu,
     msc_company_users mcu,
     msc_trading_partner_maps map,
     msc_company_relationships mcrs,
     msc_trading_partners mtp
    where fu.user_id = mcu.user_id
      and mcu.company_id = mcrs.object_id
      and mcrs.subject_id = 1
      and mcrs.relationship_type = 2
      and mcrs.relationship_id = map.company_key
      and map.map_type = 1
      and map.tp_key = mtp.partner_id
    and fu.user_id = fnd_global.user_id ;

   l_sup number;
   l_inst number;
  BEGIN
    open c_sup;
    fetch c_sup into l_inst, l_sup;
    close c_sup;

    return l_sup;

  END modelled_as_supplier;

end msc_supplier_pwb ;

/
