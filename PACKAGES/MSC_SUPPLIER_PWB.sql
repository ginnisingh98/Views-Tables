--------------------------------------------------------
--  DDL for Package MSC_SUPPLIER_PWB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_SUPPLIER_PWB" AUTHID CURRENT_USER as
/* $Header: MSCFNSCS.pls 120.0 2005/05/25 18:45:41 appldev noship $ */

  --global constants
  g_resp_app_name   CONSTANT	varchar2(20) := 'MSC';
  g_resp_key_name   CONSTANT	varchar2(100) := 'MSC_ADV_SUPPLY_CHAIN_SUPPLIER';
  g_secgrp_key_name CONSTANT    varchar2(100) := 'STANDARD';
  g_func_name       CONSTANT    varchar2(100) := 'MSCFNSCW-VSPWB';

  --Function Groups
  --1.  Items : 11,19
  --2.  Resources : 2
  --3.  Supplier : 3
  --4.	Supply Chain :10,14,15
  --5.	Plan Output : 1,7,8,28m26,18,21A
  --6.	Gantt Chart : 9
  --7.	Kpis : 5
  --8.	Pegging : 6
  --9.	Execute Plan : 23,21B
  --10. Replan : 20
  --11. CP : 23B
  --12. Undo : 25
  --13. Plan Settings 22,24
  --14. Bom/Routings 12,13,17,4,16
  --15. Resource Batches
/*---------------------Enhancement for LA by :Satyagi---------*/
  --16. Liability
/*----------------------Enhancement for LA by :Satyagi---------*/
   g_item_grp		boolean;
   g_res_grp		boolean;
   g_sup_grp		boolean;
   g_schain_grp		boolean;
   g_plan_grp		boolean;
   g_gc_grp		boolean;
   g_kpi_grp		boolean;
   g_peg_grp		boolean;
   g_exepln_grp		boolean;
   g_replan_grp		boolean;
   g_cp_grp		boolean;
   g_undo_grp		boolean;
   g_opt_grp		boolean;
   g_bom_grp		boolean;
   g_invlv_grp          boolean;
   g_res_batch_grp      boolean;
/*---------------------Enhancement for LA by :Satyagi---------*/
   g_liability_grp	boolean;
/*----------------------Enhancement for LA by :Satyagi---------*/
   --Function Names

   --1.Exceptions  - Actions, Exception Details, Related Exceptions,Save Actions
   --2.Resources   - Resources, Resource Requirements, Resource Availability,
   --3.Supplier    - Supplier capacity, Supplier Flex fences, Supplier variability
   --4.Operations  - Routing Operations, Operation Networks
   --5.Key Indicators 6.Pegging 7.HzPlan 8.Vert Plan 9.GC 10.SCBill 11.Items 12.Components
   --13.Where Used 14.Sourcing 15.Destination 16.ProcEff 17.Coprod 18.SS 19.PSub
   --20.Replan     - Start ,Stop ,Online Replan,Status,Batch Replan,Launch,Copy,Purge Plan.
   --21a.View Notifications  21b. Launch notifications
   --22.Options    - Plan Options
   --23a.Release    - Select All for Release, Release
   --23b.collaboration - publish order forecast, supply commits
   --24.Pref
   --25.Undo 26.PCR
   --27.PDR. not used
   --28.supply/demand
/*---------------------Enhancement for LA by :Satyagi---------*/
   --29.Liability
/*----------------------Enhancement for LA by :Satyagi---------*/
   g_excp_fn   NUMBER := 2 ;
   g_res_fn    NUMBER := 2 ;
   g_supp_fn   NUMBER := 2 ;
   g_oper_fn   NUMBER := 2 ;
   g_kpi_fn    NUMBER := 2 ;
   g_peg_fn    NUMBER := 2 ;
   g_hz_fn     NUMBER := 2 ;
   g_vert_fn   NUMBER := 2 ;
   g_gc_fn     NUMBER := 2 ;
   g_bill_fn   NUMBER := 2 ;
   g_item_fn   NUMBER := 2 ;
   g_comp_fn   NUMBER := 2 ;
   g_used_fn   NUMBER := 2 ;
   g_sour_fn   NUMBER := 2 ;
   g_dest_fn   NUMBER := 2 ;
   g_peff_fn   NUMBER := 2 ;
   g_coprod_fn NUMBER := 2 ;
   g_ss_fn     NUMBER := 2 ;
   g_psub_fn   NUMBER := 2 ;
   g_replan_fn NUMBER := 2 ;
   g_21a_fn    NUMBER := 2 ;
   g_21b_fn    NUMBER := 2 ;
   g_option_fn NUMBER := 2 ;
   g_23a_fn    NUMBER := 2 ;
   g_23b_fn    NUMBER := 2 ;
   g_pref_fn   NUMBER := 2 ;
   g_undo_fn   NUMBER := 2 ;
   --g_pdr_fn    NUMBER := 2 ;
   g_pcr_fn    NUMBER := 2 ;
   g_28_fn     NUMBER := 2 ;
   g_29_fn     NUMBER := 2 ;
   g_30_fn     NUMBER := 2 ;
   g_cal_fn     NUMBER := 2 ;
   g_invlv_fn  NUMBER := 2 ;
   g_res_batch_fn  NUMBER := 2 ;
   /*---------------------Enhancement for LA by :Satyagi---------*/
   g_liability_fn  NUMBER := 2 ;
   /*----------------------Enhancement for LA by :Satyagi---------*/

  --fnd-function context
  g_resp_app varchar2(20) := g_resp_app_name ;
  g_resp_key varchar2(100) := g_resp_key_name ;
  g_secgrp_key varchar2(100) := g_secgrp_key_name ;
  g_func       varchar2(100) := g_func_name ;

  --aps context
  g_org_id number;
  g_inst_id number;
  g_partner_type number;
  g_supplier_id number;
  g_supp_site_id number;

  procedure invoke_mscfnscwb( p_resp_app in varchar2,
                            p_resp_key in varchar2,
                            p_secgrp_key in varchar2,
                            p_err_msg out nocopy varchar2,
                            p_url out nocopy varchar2);

  procedure launch_supplier_pwb(p_unique_id in varchar2,
                            p_user_id in number,
                            p_supplier_id in number,
                            p_supplier_site_id in number,
                            p_err_msg out nocopy varchar2,
                            p_url out nocopy varchar2 );

  procedure enable_fn_sec;

  function get_fn_status(p_fn_name in varchar2) return NUMBER ;

  --procedure enable_disable_fn_sec(p_enable boolean default false);

  FUNCTION modelled_as_org return boolean ;
  FUNCTION modelled_as_supplier  return number;
  FUNCTION check_supplier_plans (p_supplier_id number) return boolean ;

end msc_supplier_pwb ;

 

/
