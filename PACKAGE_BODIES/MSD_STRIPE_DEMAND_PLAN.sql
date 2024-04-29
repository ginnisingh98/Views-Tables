--------------------------------------------------------
--  DDL for Package Body MSD_STRIPE_DEMAND_PLAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_STRIPE_DEMAND_PLAN" AS
/* $Header: msdstrpb.pls 120.11.12010000.2 2008/09/10 13:08:31 nallkuma ship $ */

  --
  -- Private procedures
  --

  /********************************************************************
   *  Build the level values stripe in a temporary table.
   */

  procedure create_level_val_stripe (errbuf           out nocopy varchar2,
                                     retcode          out nocopy varchar2,
                                     p_demand_plan_id in         number,
                                     p_stripe_instance in varchar2,
                                     p_stripe_level_id in number,
                                     p_stripe_sr_level_pk in varchar2);

  procedure create_level_val_stripe_stream (errbuf out nocopy varchar2,
                                        retcode out nocopy varchar2,
                                        p_demand_plan_id in number,
                                        p_stripe_stream_name in varchar2,
                                        p_stripe_stream_desig in varchar2);

  /********************************************************************
   * Helper for create_level_val_stripe.
   * Walk up a hierarchy and insert parents into temporary table.
   */
   procedure walk_up_hierarchy (errbuf           out nocopy varchar2,
                                retcode          out nocopy varchar2,
                                p_demand_plan_id in number,
                                p_level_id       in number);

  /********************************************************************
   *  Helper for create_level_val_stripe.
   *  Walk down a hierarchy and insert children into temporary table.
   */

   procedure walk_down_hierarchy (errbuf           out nocopy varchar2,
                                  retcode          out nocopy varchar2,
                                  p_demand_plan_id in  number,
                                  p_level_id       in  number);

  /********************************************************************
   *  Helper for create_level_val_stripe.
   *  Insert orgs into stripe which are related to level values in
   *  stripe.
   */

   procedure insert_related_orgs (errbuf          out nocopy varchar2,
                                  retcode         out nocopy varchar2,
                                  p_demand_plan_id in number,
                                  p_level_id in number);

  /********************************************************************
   *  Helper for create_level_val_stripe.
   *  Insert level values into stripe which are related to orgs in
   *  stripe.
   */

   procedure insert_related_level_values (errbuf          out nocopy varchar2,
                                  retcode         out nocopy varchar2,
                                  p_demand_plan_id in number,
                                  p_level_id in number);


  /********************************************************************
   *  Helper for create_level_val_stripe.
   *  Insert level values for non-striped dimensions.
   */

   procedure insert_non_stripe_level_values (errbuf           out nocopy varchar2,
                                            retcode          out nocopy varchar2,
                                            p_demand_plan_id in         number,
                                            p_insert_rep in         varchar2,
                                            p_insert_geo in         varchar2);

  /********************************************************************
   *  Helper for create_level_val_stripe.
   *  Determine which level values should be striped.
   */

   procedure handle_remaining_level_values (errbuf           out nocopy varchar2,
                                            retcode          out nocopy varchar2,
                                            p_demand_plan_id in         number);


  /********************************************************************
   * Copies the level values stripe from temporary table to stripe table.
   */

   procedure copy_level_val_stripe (errbuf           out nocopy varchar2,
                                    retcode          out nocopy varchar2,
                                    p_demand_plan_id in         number);

  /********************************************************************
   * Insert Fact Data into Stripe.
   */

   procedure insert_fact_data  (errbuf           out nocopy varchar2,
                                retcode          out nocopy varchar2,
                                p_demand_plan_id in         number,
                                p_fast_refresh   in         varchar2);

  /********************************************************************
   * Delete Fact Data from Stripe.
   */

   procedure delete_fact_data  (errbuf           out nocopy varchar2,
                                retcode          out nocopy varchar2,
                                p_demand_plan_id in         number);

  /********************************************************************
   * Update Parameters Stripe Information.
   */

   procedure update_dp_parameters_ds  (errbuf           out nocopy varchar2,
                                       retcode          out nocopy varchar2,
                                       p_demand_plan_id in         number);
   --
   -- Private functions
   --

   /*********************************************************************
    * Returns True or False if stripe in temp table equals previous stripe
    */

   function is_level_val_stripe_equal (errbuf           out nocopy varchar2,
                                       retcode          out nocopy varchar2,
                                       p_demand_plan_id in         number) return varchar2;

   /***********************************************************************
    * Returns True or False if level values collected is newer than stripe.
    */

   function is_level_val_collected (errbuf           out nocopy varchar2,
                                    retcode          out nocopy varchar2,
                                    p_demand_plan_id in         number) return varchar2;

   function is_dimension_changed (errbuf           out nocopy varchar2,
                                  retcode          out nocopy varchar2,
                                  p_demand_plan_id in         number) return varchar2;


  function is_event_collected (errbuf           out nocopy varchar2,
                             retcode          out nocopy varchar2,
                             p_demand_plan_id in  number) return varchar2;

   /***********************************************************************
    * Returns True or False if user changed stripe level value from
    * that previously used.
    */

   function is_new_stripe (errbuf           out nocopy varchar2,
                           retcode          out nocopy varchar2,
                           p_demand_plan_id in         number,
                           p_stripe_instance in varchar2,
                           p_stripe_level_id in number,
                           p_stripe_sr_level_pk in varchar2,
                           p_build_stripe_level_pk in number,
			   p_build_stripe_stream_name in varchar2) return varchar2;

   /***********************************************************************
    * Returns True or False if user changed stripe stream value from
    * that previously used.
    */

   function is_new_stream_stripe (errbuf           out nocopy varchar2,
                                  retcode          out nocopy varchar2,
                                  p_demand_plan_id in         number,
                                  p_build_stripe_level_pk in number,
                                  p_stripe_stream_name in varchar2,
                                  p_stripe_stream_desig in varchar2,
                                  p_build_stripe_stream_name in varchar2,
                                  p_build_stripe_stream_desig in varchar2,
                                  p_build_stripe_stream_ref_num in number) return varchar2;

   /***********************************************************************
    * Returns True or False if user changed stripe stream value from
    * that previously used.
    */

   function is_new_lob_stream_stripe (errbuf           out nocopy varchar2,
                                      retcode          out nocopy varchar2,
                                      p_demand_plan_id in         number,
                                      p_stripe_instance in varchar2,
                                      p_stripe_level_id in number,
                                      p_stripe_sr_level_pk in varchar2,
                                      p_build_stripe_level_pk in number,
                                      p_stripe_stream_name in varchar2,
                                      p_stripe_stream_desig in varchar2,
                                      p_build_stripe_stream_name in varchar2,
                                      p_build_stripe_stream_desig in varchar2,
                                      p_build_stripe_stream_ref_num in number) return varchar2;

   /************************************************************************
    * Stripe Demand Plan w/LOB defined only.
    */
   procedure stripe_demand_plan_lob (errbuf                   out nocopy varchar2,
                                     retcode                  out nocopy varchar2,
                                     p_demand_plan_id         in         number,
                                     p_stripe_instance        in         varchar2,
                                     p_stripe_level_id        in         number,
                                     p_stripe_sr_level_pk     in         varchar2,
                                     p_build_stripe_level_pk  in         varchar2,
				     p_build_stripe_stream_name in 	 varchar2);

/************ TO BE CODED ************************/
   /************************************************************************
    * Stripe Demand Plan w/Stream defined only.
    */
   procedure stripe_demand_plan_stream (errbuf           out nocopy varchar2,
                                        retcode          out nocopy varchar2,
                                        p_demand_plan_id in         number,
                                        p_build_stripe_level_pk in number,
                                        p_stripe_stream_name in varchar2,
                                        p_stripe_stream_desig in varchar2,
                                        p_build_stripe_stream_name in varchar2,
                                        p_build_stripe_stream_desig in varchar2,
                                        p_build_stripe_stream_ref_num in number);

   /************************************************************************
    * Stripe Demand Plan w/LOB and Stream defined.
    */
   procedure stripe_demand_plan_lob_stream (errbuf           out nocopy varchar2,
                                            retcode          out nocopy varchar2,
                                            p_demand_plan_id in         number,
                                   p_stripe_instance in varchar2,
                                   p_stripe_level_id in number,
                                   p_stripe_sr_level_pk in varchar2,
                                   p_build_stripe_level_pk in number,
                                     p_stripe_stream_name in varchar2,
                                     p_stripe_stream_desig in varchar2,
                                     p_build_stripe_stream_name in varchar2,
                                     p_build_stripe_stream_desig in varchar2,
                                     p_build_stripe_stream_ref_num in number);

   /***************************************************************************
    * Check to see if values are populated for a level from associations.
    * If not then dump all level values for that level.
    */
   function chk_insert_no_associations (errbuf              out nocopy varchar2,
                                         retcode             out nocopy varchar2,
                                         p_demand_plan_id    in         number,
                                         p_level_id          in         number) return varchar2;

   procedure chk_insert_org_no_associations (errbuf              out nocopy varchar2,
                                      retcode             out nocopy varchar2,
                                      p_demand_plan_id    in         number,
                                      p_level_id          in         number);

   procedure create_lvl_val_stripe_strm_lob (errbuf out nocopy varchar2,
                                          retcode out nocopy varchar2,
                                          p_demand_plan_id in number,
                                          p_stripe_instance in varchar2,
                                          p_stripe_level_id in number,
                                          p_stripe_sr_level_pk in varchar2 ,
                                          p_stripe_stream_name in varchar2,
                                          p_stripe_stream_desig in varchar2);

   procedure insert_stream_items(errbuf out nocopy varchar2,
                                        retcode out nocopy varchar2,
                                        p_demand_plan_id in number,
                                        p_stripe_stream_name in varchar2,
                                        p_stripe_stream_desig in varchar2,
                                        p_dim_code in varchar2);

   procedure filter_stream_items(errbuf out nocopy varchar2,
                                        retcode out nocopy varchar2,
                                        p_demand_plan_id in number,
                                        p_stripe_stream_name in varchar2,
                                        p_stripe_stream_desig in varchar2,
                                        p_dim_code in varchar2);
   procedure insert_supercession_items (errbuf out nocopy varchar2,
                                        retcode out nocopy varchar2,
                                        p_demand_plan_id in number);

   procedure handle_fact_data (errbuf out nocopy varchar2,
                               retcode out nocopy varchar2,
                               p_demand_plan_id in number);

   procedure ins_pseudo_level_pk (errbuf out nocopy varchar2,
                                  retcode out nocopy varchar2,
                                  p_demand_plan_id in number);

   procedure ins_other_level_val (errbuf out nocopy varchar2,
                                  retcode out nocopy varchar2,
                                  p_demand_plan_id in number);
   procedure ins_all_level_val (errbuf out nocopy varchar2,
 	                                   retcode out nocopy varchar2,
 	                                   p_demand_plan_id in number);

   function get_desig_clmn_name (p_cs_id in number) return VARCHAR2;

   function is_dim_in_plan (p_demand_plan_id in number, p_dim_code in varchar2) return varchar2;

   /********************************************************************
   * ISO Code Change
   * This function checks whether there is any change in the ISO orgs
   * attached to the demand plan
   */
   FUNCTION is_iso_orgs_changed (errbuf           OUT NOCOPY VARCHAR2,
                                 retcode          OUT NOCOPY VARCHAR2,
                                 p_demand_plan_id IN         NUMBER)
      RETURN VARCHAR2;

    --
    -- Constants
    --

    C_TRUE      Constant varchar2(30):='TRUE';
    C_FALSE     Constant varchar2(30):='FALSE';
    C_FAST_REF  Constant varchar2(30):='FAST';
    C_FULL_REF  Constant varchar2(30):='FULL';
    C_FACT      Constant varchar2(30):='FACT';
    C_LVL_VAL   Constant varchar2(30):='LEVEL_VALUES';
    C_DIM       Constant varchar2(30):='DIMENSION';
    C_EVENT     Constant varchar2(30):='EVENT';
    C_NPI_BASE_PRODUCT Constant varchar2(1):='1';
    C_YES_FLAG  Constant varchar2(30):='Y';
    C_PRE_PROC Constant varchar2(30) := 'PRE-PROCESS';
    C_POS_PROC Constant varchar2(30) := 'POST-PROCESS';
    C_PROCESS Constant varchar2(30) := 'PROCESSED';
    C_PSEUDO_PK Constant number := 0;

    C_LEVEL_PLAN Constant number := -1;

    C_ITEM_LEVEL_ID Constant number := 1;
    C_ORGS_LEVEL_ID Constant number := 7;
    C_SHIP_LEVEL_ID Constant number := 11;
    C_REPS_LEVEL_ID Constant number := 18;

    C_PRD_DIM_CODE  Constant varchar2(30) := 'PRD';
    C_ORG_DIM_CODE  Constant varchar2(30) := 'ORG';
    C_GEO_DIM_CODE  Constant varchar2(30) := 'GEO';
    C_REP_DIM_CODE  Constant varchar2(30) := 'REP';
    C_TIM_DIM_CODE  Constant varchar2(30) := 'TIM';

    FATAL_ERROR Constant varchar2(30):='FATAL_ERROR';
    ERROR       Constant varchar2(30):='ERROR';
    WARNING     Constant varchar2(30):='WARNING';
    INFORMATION Constant varchar2(30):='INFORMATION';
    HEADING     Constant varchar2(30):='HEADING';
    SECTION     Constant varchar2(30):='SECTION';
    SUCCESS	Constant varchar2(30):='SUCCESS';

    l_system_attribute1 VARCHAR2(240) := MSD_COMMON_UTILITIES.GET_SYSTEM_ATTRIBUTE1_DESC('I');  --Bug#4249928

    l_debug     VARCHAR2(240) := NVL(fnd_profile.value('MRP_DEBUG'), 'N');
    l_result varchar2(300);

    g_ret_code      number;
    --
    -- USED BY DISPLAY_MESSAGE
    --
    l_last_msg_type varchar2(30);
    --
    -- Define Exception
    --
    EX_FATAL_ERROR Exception;
    --
    -- Fast Refresh or Full refresh for Fact Data.
    --
    l_fast_refresh_fact varchar2(100);
    --
    -- Status for Customization
    --
    l_status varchar2(100);

    --
    -- get demand plan record
    --

    CURSOR get_dp (p_demand_plan_id NUMBER) IS
    SELECT demand_plan_id,
           demand_plan_name,
           stripe_instance,
           stripe_level_id,
           stripe_sr_level_pk,
           build_stripe_level_pk,
           stripe_stream_name,
           stripe_stream_desig,
           build_stripe_stream_name,
           build_stripe_stream_desig,
           build_stripe_stream_ref_num
    FROM   msd_demand_plans
    WHERE  demand_plan_id = p_demand_plan_id;

    --
    -- get last refresh num
    --

    CURSOR get_refresh_num(p_name in varchar2, p_desig in varchar2) IS
    select last_refresh_num
      from msd_cs_data_headers
     where cs_definition_id = (select cs_definition_id
                                from msd_cs_definitions
                               where name = p_name)
       and cs_name = nvl(p_desig, cs_name)
  order by last_refresh_num desc;

    --
    -- Private functions/proceudres
    --
    --
    -- Store result
    --
    Procedure calc_result ( p_msg_type in varchar2) is
    Begin
        if p_msg_type = FATAL_ERROR then
            g_ret_code := 4;
            l_result := FATAL_ERROR;
        elsif p_msg_type = ERROR then
            g_ret_code := 2;
            l_result   := p_msg_type;
        elsif p_msg_type = WARNING then
            if g_ret_code <> 2 then
                g_ret_code := 1;
                l_result := p_msg_type;
            end if;
        end if;
    End;
    --
    Procedure show_message(p_text in varchar2) is
    Begin
        fnd_file.put_line(fnd_file.log, p_text);
--        dbms_output.put_line(p_text);
    end;

    Procedure debug_out(p_text in varchar2) is
    i number := 1;
    Begin
      while i<= length(p_text) loop
        fnd_file.put_line(fnd_file.output, substr(p_text, i, 90));
--        dbms_output.put_line(substr(p_text, i, 90));
	i := i+90;
      end loop;
    end;
    --

    Procedure display_message(p_text varchar2, msg_type varchar2 default null) is
        l_tab           varchar2(4):='    ';
        L_MAX_LENGTH    number:=90;
    Begin
        if msg_type = SECTION then
            if nvl(l_last_msg_type, 'xx') <> SECTION then
                show_message('');
            end if;
            --
            show_message( substr(p_text, 1, L_MAX_LENGTH) );
            --
        elsif msg_type in (INFORMATION, HEADING) then
            show_message( l_tab || substr(p_text, 1, L_MAX_LENGTH));
        else
            show_message( l_tab || rpad(p_text, L_MAX_LENGTH) || ' ' || msg_type );
        end if;
        --
        if msg_type in (ERROR, WARNING, FATAL_ERROR) then
            calc_result (msg_type);
        end if;
        --
        if msg_type = FATAL_ERROR then
            show_message(' ');
            show_message( l_tab || 'Exiting Demand Plan validation process with FATAL ERROR');
            raise   EX_FATAL_ERROR;
        end if;
        --
        l_last_msg_type := msg_type;
    End;
    --
    Procedure Blank_Line is
    Begin
       fnd_file.put_line(fnd_file.log, '');
--        dbms_output.put_line('');
    End;
    --

Procedure set_demand_plan(
        p_demand_plan_id in number) is

begin

  if (p_demand_plan_id is not null) then

    delete from msd_dp_session;

    insert into msd_dp_session
     ( demand_plan_id )
    values
     ( p_demand_plan_id );

    -- Incorporate later into msd_analyze
    --fnd_stats.gather_table_stats('MSD', 'MSD_DP_SESSION', 10, 4);

  end if;

end;


Procedure stripe_demand_plan(
        errbuf          out nocopy varchar2,
        retcode         out nocopy varchar2,
        p_demand_plan_id in number) is

l_dp_rec        get_dp%rowtype;

Begin

    if l_debug = C_YES_FLAG then
      debug_out( 'Entering stripe_demand_plan ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;
    --
    -- initialize
    --
    l_result := SUCCESS;
    g_ret_code := 0;
    --
    -- find demand plan
    --

    --
    -- Retrieve Demand Plan information.
    --
    open get_dp(p_demand_plan_id);
    fetch get_dp into l_dp_rec;
    close get_dp;


    --
    -- If both LOB and Stream is specified.
    --
    if ((l_dp_rec.stripe_sr_level_pk is not null) and (l_dp_rec.stripe_stream_name is not null)) then

      msd_stripe_custom.custom_populate (errbuf,
                                          retcode,
                                          l_dp_rec.demand_plan_id,
                                          C_PRE_PROC,
                                          l_status,
                                          null,null,null,null,null);

      if (l_status is null or l_status <> C_PROCESS) then
         stripe_demand_plan_lob_stream (errbuf,
                                        retcode,
                                        l_dp_rec.demand_plan_id,
                                        l_dp_rec.stripe_instance,
                                        l_dp_rec.stripe_level_id,
                                        l_dp_rec.stripe_sr_level_pk,
                                        l_dp_rec.build_stripe_level_pk,
                                        l_dp_rec.stripe_stream_name,
                                        l_dp_rec.stripe_stream_desig,
                                        l_dp_rec.build_stripe_stream_name,
                                        l_dp_rec.build_stripe_stream_desig,
                                        l_dp_rec.build_stripe_stream_ref_num);
      end if;

      msd_stripe_custom.custom_populate (errbuf,
                                          retcode,
                                          l_dp_rec.demand_plan_id,
                                          C_POS_PROC,
                                          l_status,
                                          null,null,null,null,null);


       handle_fact_data (errbuf, retcode, p_demand_plan_id);

    --
    -- If LOB, but not Stream is specified.
    --
    elsif ((l_dp_rec.stripe_sr_level_pk is not null) and (l_dp_rec.stripe_stream_name is null)) then

     msd_stripe_custom.custom_populate (errbuf,
                                          retcode,
                                          l_dp_rec.demand_plan_id,
                                          C_PRE_PROC,
                                          l_status,
                                          null,null,null,null,null);

      if (l_status is null or l_status <> C_PROCESS) then
          stripe_demand_plan_lob (errbuf,
                              retcode,
                              l_dp_rec.demand_plan_id,
                              l_dp_rec.stripe_instance,
                              l_dp_rec.stripe_level_id,
                              l_dp_rec.stripe_sr_level_pk,
                              l_dp_rec.build_stripe_level_pk,
			      l_dp_rec.build_stripe_stream_name);
     end if;

      msd_stripe_custom.custom_populate (errbuf,
                                          retcode,
                                          l_dp_rec.demand_plan_id,
                                          C_POS_PROC,
                                          l_status,
                                          null,null,null,null,null);


       handle_fact_data (errbuf, retcode, p_demand_plan_id);

    --
    -- If LOB is not specified, but Stream is specified.
    --
    elsif ((l_dp_rec.stripe_sr_level_pk is null) and (l_dp_rec.stripe_stream_name is not null)) then

     msd_stripe_custom.custom_populate (errbuf,
                                          retcode,
                                          l_dp_rec.demand_plan_id,
                                          C_PRE_PROC,
                                          l_status,
                                          null,null,null,null,null);

      if (l_status is null or l_status <> C_PROCESS) then
        stripe_demand_plan_stream (errbuf,
                                     retcode,
                                     l_dp_rec.demand_plan_id,
                                     l_dp_rec.build_stripe_level_pk,
                                     l_dp_rec.stripe_stream_name,
                                     l_dp_rec.stripe_stream_desig,
                                     l_dp_rec.build_stripe_stream_name,
                                     l_dp_rec.build_stripe_stream_desig,
                                     l_dp_rec.build_stripe_stream_ref_num);
     end if;

      msd_stripe_custom.custom_populate (errbuf,
                                          retcode,
                                          l_dp_rec.demand_plan_id,
                                          C_POS_PROC,
                                          l_status,
                                          null,null,null,null,null);


       handle_fact_data (errbuf, retcode, p_demand_plan_id);
    --
    -- If LOB is not specified and Stream is not specified, but existing partition exists.
    --
    elsif ((l_dp_rec.build_stripe_level_pk is not null) or (l_dp_rec.build_stripe_stream_name is not null)) then

      delete from msd_level_values_ds
      where demand_plan_id = p_demand_plan_id;

      delete from msd_cs_Data_ds
      where demand_plan_id = p_demand_plan_id;

      delete from msd_dp_parameters_ds
      where demand_plan_id = p_demand_plan_id;

      update msd_demand_plans
      set build_stripe_level_pk = null,
          build_stripe_stream_name = null,
          build_stripe_stream_desig = null,
          build_stripe_stream_ref_num = null
      where demand_plan_id = p_demand_plan_id;
    --
    -- If LOB is not specified and Stream is not specified, and no existing partition exists.
    --
    else
      null;
    end if;

    if l_debug = C_YES_FLAG then
      debug_out( 'Exiting stripe_demand_plan ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;

Exception when others then
    retcode := 2;
    errbuf := substr( sqlerrm, 1, 80);
    rollback;
End;


procedure walk_down_hierarchy (errbuf          out nocopy varchar2,
                               retcode         out nocopy varchar2,
                               p_demand_plan_id in number,
                               p_level_id in number) is

cursor c0 is
select dimension_code
  from msd_levels ml
 where level_id = p_level_id;

cursor c1(p_hierarchy_id in number,
          p_parent_level_id in number) is
select mhl.level_id
  from msd_hierarchy_levels mhl
 where mhl.hierarchy_id = p_hierarchy_id
   and mhl.parent_level_id = p_parent_level_id;

cursor c2 (p_dimension_code in varchar2) is
select hierarchy_id
  from msd_hierarchies
 where dimension_code = p_dimension_code;

x_current_parent_level_id number;
x_child_level number;
l_rec_0 c0%rowtype;

begin

if l_debug = C_YES_FLAG then
    debug_out( 'Entering walk_down_hierarchy ' || to_char(sysdate, 'hh24:mi:ss'));
end if;


open c0;
fetch c0 into l_rec_0;
close c0;

for c2_rec in c2 (l_rec_0.dimension_code) loop

  x_current_parent_level_id := p_level_id;

  loop

     open c1(c2_rec.hierarchy_id, x_current_parent_level_id);
     fetch c1 into x_child_level;

     if (c1%NOTFOUND) then
       close c1;
       exit;
     end if;

     close c1;

     insert into msd_level_values_ds_temp
        (
          DEMAND_PLAN_ID,
          INSTANCE,
          LEVEL_ID,
          SR_LEVEL_PK,
          LEVEL_PK,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
	  SYSTEM_ATTRIBUTE1,
	  SYSTEM_ATTRIBUTE2,
	  DP_ENABLED_FLAG
        )
        select distinct
               p_demand_plan_id,
               mlv.instance,
               mlv.level_id,
               mlv.sr_level_pk,
               mlv.level_pk,
               sysdate,
               fnd_global.user_id,
               sysdate,
               fnd_global.user_id,
	       mlv.system_attribute1,
   	       mlv.system_attribute2,
	       mlv.dp_enabled_flag
	  from msd_level_values mlv,
               msd_level_values_ds_temp mld,
               msd_level_associations mla
         where mla.level_id = x_child_level
           and mla.parent_level_id = x_current_parent_level_id
           and mla.parent_level_id = mld.level_id
           and mla.sr_parent_level_pk = mld.sr_level_pk
           and mlv.instance = mla.instance
           and mla.instance = mld.instance
           and mlv.level_id = mla.level_id
           and mlv.sr_level_pk = mla.sr_level_pk
           and mld.demand_plan_id = p_demand_plan_id
         minus
        select p_demand_plan_id,
               instance,
               level_id,
               sr_level_pk,
               level_pk,
               sysdate,
               fnd_global.user_id,
               sysdate,
               fnd_global.user_id,
	       system_attribute1,
	       system_attribute2,
	       dp_enabled_flag
	  from msd_level_values_ds_temp
         where demand_plan_id = p_demand_plan_id;


        x_current_parent_level_id := x_child_level;

      end loop;
    end loop;

if l_debug = C_YES_FLAG then
    debug_out( 'Exiting walk_down_hierarchy ' || to_char(sysdate, 'hh24:mi:ss'));
end if;

end;

procedure walk_up_hierarchy (errbuf          out nocopy varchar2,
                             retcode         out nocopy varchar2,
                             p_demand_plan_id in number,
                             p_level_id in number) is

cursor c0 is
select dimension_code
  from msd_levels ml
 where level_id = p_level_id;

cursor c1(p_hierarchy_id in number,
          p_child_level_id in number) is
select mhl.parent_level_id
  from msd_hierarchy_levels mhl
 where mhl.hierarchy_id = p_hierarchy_id
   and mhl.level_id = p_child_level_id;

cursor c2 (p_dimension_code in varchar2) is
select hierarchy_id
  from msd_hierarchies
 where dimension_code = p_dimension_code;

x_current_child_level_id number;
x_parent_level number;
l_rec_0 c0%rowtype;

begin

if l_debug = C_YES_FLAG then
    debug_out( 'Entering walk_up_hierarchy ' || to_char(sysdate, 'hh24:mi:ss'));
end if;

open c0;
fetch c0 into l_rec_0;
close c0;

for c2_rec in c2 (l_rec_0.dimension_code) loop

  x_current_child_level_id := p_level_id;

  loop

     open c1(c2_rec.hierarchy_id, x_current_child_level_id);
     fetch c1 into x_parent_level;

     if (c1%NOTFOUND) then
       close c1;
       exit;
     end if;

     close c1;

     insert into msd_level_values_ds_temp
        (
          DEMAND_PLAN_ID,
          INSTANCE,
          LEVEL_ID,
          SR_LEVEL_PK,
          LEVEL_PK,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
	  SYSTEM_ATTRIBUTE1,
	  SYSTEM_ATTRIBUTE2,
	  DP_ENABLED_FLAG
	  )
        select distinct
               p_demand_plan_id,
               mlv.instance,
               mlv.level_id,
               mlv.sr_level_pk,
               mlv.level_pk,
               sysdate,
               fnd_global.user_id,
               sysdate,
               fnd_global.user_id,
	       mlv.system_attribute1,
	       mlv.system_attribute2,
	       mlv.dp_enabled_flag
	  from msd_level_values mlv,
               msd_level_values_ds_temp mld,
               msd_level_associations mla
         where mla.parent_level_id = x_parent_level
           and mla.level_id = x_current_child_level_id
           and mla.level_id = mld.level_id
           and mla.sr_level_pk = mld.sr_level_pk
           and mlv.instance = mla.instance
           and mla.instance = mld.instance
           and mlv.level_id = mla.parent_level_id
           and mlv.sr_level_pk = mla.sr_parent_level_pk
           and mld.demand_plan_id = p_demand_plan_id
         minus
        select p_demand_plan_id,
               instance,
               level_id,
               sr_level_pk,
               level_pk,
               sysdate,
               fnd_global.user_id,
               sysdate,
               fnd_global.user_id,
	       system_attribute1,
 	       system_attribute2,
	       dp_enabled_flag
	  from msd_level_values_ds_temp
         where demand_plan_id = p_demand_plan_id;

        x_current_child_level_id := x_parent_level;

      end loop;
    end loop;

if l_debug = C_YES_FLAG then
    debug_out( 'Exiting walk_up_hierarchy ' || to_char(sysdate, 'hh24:mi:ss'));
end if;

end;

procedure insert_related_orgs (errbuf          out nocopy varchar2,
                               retcode         out nocopy varchar2,
                               p_demand_plan_id in number,
                               p_level_id in number) is

begin

if l_debug = C_YES_FLAG then
    debug_out( 'Entering insert_related_orgs ' || to_char(sysdate, 'hh24:mi:ss'));
end if;


  insert into msd_level_values_ds_temp
  (
          DEMAND_PLAN_ID,
          INSTANCE,
          LEVEL_ID,
          SR_LEVEL_PK,
          LEVEL_PK,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
	  SYSTEM_ATTRIBUTE1,
	  SYSTEM_ATTRIBUTE2,
	  DP_ENABLED_FLAG
	  )
        select p_demand_plan_id,
               mlv.instance,
               mlv.level_id,
               mlv.sr_level_pk,
               mlv.level_pk,
               sysdate,
               fnd_global.user_id,
               sysdate,
               fnd_global.user_id,
	       mlv.system_attribute1,
	       mlv.system_attribute2,
	       mlv.dp_enabled_flag
	  from msd_level_org_asscns mlo,
               msd_level_values mlv,
               msd_level_values_ds_temp mld
         where mld.demand_plan_id = p_demand_plan_id
           and mlo.instance = mld.instance
           and mlo.org_level_id = p_level_id
           and mlo.org_sr_level_pk = mlv.sr_level_pk
           and mlo.instance = mlv.instance
           and mlo.org_level_id = mlv.level_id
           and mlo.level_id = mld.level_id
           and mlo.sr_level_pk = mld.sr_level_pk
         minus
        select p_demand_plan_id,
               instance,
               level_id,
               sr_level_pk,
               level_pk,
               sysdate,
               fnd_global.user_id,
               sysdate,
               fnd_global.user_id,
	       system_attribute1,
	       system_attribute2,
	       dp_enabled_flag
	  from msd_level_values_ds_temp
         where demand_plan_id = p_demand_plan_id;

   chk_insert_org_no_associations (errbuf,
                                   retcode,
                                   p_demand_plan_id,
                                   C_ORGS_LEVEL_ID);

if l_debug = C_YES_FLAG then
    debug_out( 'Exiting insert_related_orgs ' || to_char(sysdate, 'hh24:mi:ss'));
end if;

end;

procedure insert_related_level_values (errbuf          out nocopy varchar2,
                               retcode         out nocopy varchar2,
                               p_demand_plan_id in number,
                               p_level_id in number) is

cursor chk_dim (p_dim_code in varchar2) is
select C_TRUE
  from msd_dp_dimensions
 where demand_plan_id = p_demand_plan_id
   and dimension_code = p_dim_code;

   /* ISO Code Change */
   CURSOR c_get_internal_desc
   IS
      SELECT meaning
         FROM fnd_lookup_values_vl
         WHERE
                lookup_type = 'MSD_LEVEL_VALUE_DESC'
            AND lookup_code = 'I';

v_is_dp_dim varchar2(30) := C_FALSE;

   /* ISO Code Change */
   v_internal_desc    VARCHAR2(100);

begin

if l_debug = C_YES_FLAG then
    debug_out( 'Entering insert_related_level_values ' || to_char(sysdate, 'hh24:mi:ss'));
end if;

   /* ISO Code Change */
   OPEN  c_get_internal_desc;
   FETCH c_get_internal_desc INTO v_internal_desc;
   CLOSE c_get_internal_desc;

  -- For Sales Rep and Ship to Location, only insert
  -- related level values if attached to Demand Plan.
  -- Otherwise, insert all level values.

  if (p_level_id in (C_REPS_LEVEL_ID)) then
    open chk_dim(C_REP_DIM_CODE);
    fetch chk_dim into v_is_dp_dim;
    close chk_dim;
  elsif (p_level_id in (C_SHIP_LEVEL_ID)) then
    open chk_dim(C_GEO_DIM_CODE);
    fetch chk_dim into v_is_dp_dim;
    close chk_dim;
  else
    v_is_dp_dim := C_TRUE;
  end if;

  if (v_is_dp_dim = C_TRUE) then

    insert into msd_level_values_ds_temp
    (
            DEMAND_PLAN_ID,
            INSTANCE,
            LEVEL_ID,
            SR_LEVEL_PK,
            LEVEL_PK,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
	    SYSTEM_ATTRIBUTE1,
	    SYSTEM_ATTRIBUTE2,
	    DP_ENABLED_FLAG
	  )
          select p_demand_plan_id,
                 mlv.instance,
                 mlv.level_id,
                 mlv.sr_level_pk,
                 mlv.level_pk,
                 sysdate,
                 fnd_global.user_id,
                 sysdate,
                 fnd_global.user_id,
	         mlv.system_attribute1,
	         mlv.system_attribute2,
	         mlv.dp_enabled_flag
	  from msd_level_org_asscns mlo,
                 msd_level_values mlv,
                 msd_level_values_ds_temp mld
           where mld.demand_plan_id = p_demand_plan_id
             and mlo.instance = mld.instance
           --  and mlo.org_level_id = mld.level_id                                                 Bug# 4929528
             and mlo.org_level_id = decode(p_level_id,C_ITEM_LEVEL_ID, 7, 8)                    -- Bug# 4929528
             and mld.level_id = decode(p_level_id,C_ITEM_LEVEL_ID, 7, 8)                        -- Bug# 4929528
             and mlo.org_sr_level_pk = mld.sr_level_pk
             and mlo.instance = mlv.instance
             and mlo.level_id = mlv.level_id
             and mlo.level_id = p_level_id
             and mlo.sr_level_pk = mlv.sr_level_pk
             and nvl(mlv.system_attribute1, '123') <> v_internal_desc                           -- ISO Code Change
           minus
          select p_demand_plan_id,
                 instance,
                 level_id,
                 sr_level_pk,
                 level_pk,
                 sysdate,
                 fnd_global.user_id,
                 sysdate,
                 fnd_global.user_id,
	         system_attribute1,
	         system_attribute2,
	         dp_enabled_flag
	  from msd_level_values_ds_temp
           where demand_plan_id = p_demand_plan_id;

     /* ISO Code Change - Only for GEO dimension - Insert the internal sites for the
      *                                            ISO orgs attached to the plan
      */
     IF (p_level_id in (C_SHIP_LEVEL_ID)) THEN

        INSERT INTO msd_level_values_ds_temp
                    ( DEMAND_PLAN_ID,
                      INSTANCE,
                      LEVEL_ID,
                      SR_LEVEL_PK,
                      LEVEL_PK,
                      LAST_UPDATE_DATE,
                      LAST_UPDATED_BY,
                      CREATION_DATE,
                      CREATED_BY,
	              SYSTEM_ATTRIBUTE1,
	              SYSTEM_ATTRIBUTE2,
	              DP_ENABLED_FLAG )
                   SELECT p_demand_plan_id,
                          mlv.instance,
                          mlv.level_id,
                          mlv.sr_level_pk,
                          mlv.level_pk,
                          sysdate,
                          fnd_global.user_id,
                          sysdate,
                          fnd_global.user_id,
	                  mlv.system_attribute1,
	                  mlv.system_attribute2,
	                  mlv.dp_enabled_flag
	              FROM msd_dp_iso_organizations mdio,
	                   msd_level_org_asscns mloa,
	                   msd_level_values mlv
	              WHERE
	                     mdio.demand_plan_id = p_demand_plan_id
	                 AND mloa.instance = mdio.sr_instance_id
	                 AND mloa.level_id = 11
	                 AND mloa.org_level_id = 7
	                 AND mloa.org_sr_level_pk = mdio.sr_organization_id
	                 AND mlv.instance = mloa.instance
	                 AND mlv.level_id = 11
	                 AND mlv.sr_level_pk = mloa.sr_level_pk
	                 AND mlv.system_attribute1 = v_internal_desc
	           MINUS
                   SELECT p_demand_plan_id,
                          instance,
                          level_id,
                          sr_level_pk,
                          level_pk,
                          sysdate,
                          fnd_global.user_id,
                          sysdate,
                          fnd_global.user_id,
	                  system_attribute1,
	                  system_attribute2,
	                  dp_enabled_flag
	              FROM msd_level_values_ds_temp
                      WHERE demand_plan_id = p_demand_plan_id;

     END IF;
  end if;


if l_debug = C_YES_FLAG then
    debug_out( 'Exiting insert_related_level_values ' || to_char(sysdate, 'hh24:mi:ss'));
end if;

end;


procedure insert_non_stripe_level_values (errbuf          out nocopy varchar2,
                                         retcode         out nocopy varchar2,
                                         p_demand_plan_id in number,
                                         p_insert_rep in         varchar2,
                                         p_insert_geo in         varchar2) is

begin

if l_debug = C_YES_FLAG then
    debug_out( 'Entering insert_non_stripe_level_values ' || to_char(sysdate, 'hh24:mi:ss'));
end if;

if ((p_insert_rep is null) and (p_insert_geo is null)) then

  insert into msd_level_values_ds_temp
  (
          DEMAND_PLAN_ID,
          INSTANCE,
          LEVEL_ID,
          SR_LEVEL_PK,
          LEVEL_PK,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
	  SYSTEM_ATTRIBUTE1,
	  SYSTEM_ATTRIBUTE2,
	  DP_ENABLED_FLAG
	  )
  select  p_demand_plan_id,
          mlv.instance,
          mlv.level_id,
          mlv.sr_level_pk,
          mlv.level_pk,
          sysdate,
          fnd_global.user_id,
          sysdate,
          fnd_global.user_id,
	  mlv.system_attribute1,
	  mlv.system_attribute2,
	  mlv.dp_enabled_flag
      from msd_level_values mlv,
      msd_levels ml
  where ml.level_id = mlv.level_id
  and ml.dimension_code not in (C_PRD_DIM_CODE,C_ORG_DIM_CODE,C_REP_DIM_CODE,C_GEO_DIM_CODE)
         minus
        select p_demand_plan_id,
               instance,
               level_id,
               sr_level_pk,
               level_pk,
               sysdate,
               fnd_global.user_id,
               sysdate,
               fnd_global.user_id,
	       system_attribute1,
	       system_attribute2,
	       dp_enabled_flag
	  from msd_level_values_ds_temp
         where demand_plan_id = p_demand_plan_id;

elsif ((p_insert_rep is not null) and (p_insert_geo is null)) then

  insert into msd_level_values_ds_temp
  (
          DEMAND_PLAN_ID,
          INSTANCE,
          LEVEL_ID,
          SR_LEVEL_PK,
          LEVEL_PK,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
	  SYSTEM_ATTRIBUTE1,
	  SYSTEM_ATTRIBUTE2,
	  DP_ENABLED_FLAG
	  )
  select  p_demand_plan_id,
          mlv.instance,
          mlv.level_id,
          mlv.sr_level_pk,
          mlv.level_pk,
          sysdate,
          fnd_global.user_id,
          sysdate,
          fnd_global.user_id,
	  mlv.system_attribute1,
	  mlv.system_attribute2,
	  mlv.dp_enabled_flag
      from msd_level_values mlv,
      msd_levels ml
  where ml.level_id = mlv.level_id
  and ml.dimension_code not in (C_PRD_DIM_CODE,C_ORG_DIM_CODE,C_GEO_DIM_CODE)
         minus
        select p_demand_plan_id,
               instance,
               level_id,
               sr_level_pk,
               level_pk,
               sysdate,
               fnd_global.user_id,
               sysdate,
               fnd_global.user_id,
	       system_attribute1,
	       system_attribute2,
	       dp_enabled_flag
	  from msd_level_values_ds_temp
         where demand_plan_id = p_demand_plan_id;

elsif ((p_insert_rep is null) and (p_insert_geo is not null)) then

  insert into msd_level_values_ds_temp
  (
          DEMAND_PLAN_ID,
          INSTANCE,
          LEVEL_ID,
          SR_LEVEL_PK,
          LEVEL_PK,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
	  SYSTEM_ATTRIBUTE1,
	  SYSTEM_ATTRIBUTE2,
	  DP_ENABLED_FLAG
	  )
  select  p_demand_plan_id,
          mlv.instance,
          mlv.level_id,
          mlv.sr_level_pk,
          mlv.level_pk,
          sysdate,
          fnd_global.user_id,
          sysdate,
          fnd_global.user_id,
	  mlv.system_attribute1,
	  mlv.system_attribute2,
	  mlv.dp_enabled_flag
      from msd_level_values mlv,
      msd_levels ml
  where ml.level_id = mlv.level_id
  and ml.dimension_code not in (C_PRD_DIM_CODE,C_GEO_DIM_CODE,C_REP_DIM_CODE)
         minus
        select p_demand_plan_id,
               instance,
               level_id,
               sr_level_pk,
               level_pk,
               sysdate,
               fnd_global.user_id,
               sysdate,
               fnd_global.user_id,
	       system_attribute1,
	       system_attribute2,
	       dp_enabled_flag
	  from msd_level_values_ds_temp
         where demand_plan_id = p_demand_plan_id;

elsif ((p_insert_rep is not null) and (p_insert_geo is not null)) then

  insert into msd_level_values_ds_temp
  (
          DEMAND_PLAN_ID,
          INSTANCE,
          LEVEL_ID,
          SR_LEVEL_PK,
          LEVEL_PK,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
	  SYSTEM_ATTRIBUTE1,
	  SYSTEM_ATTRIBUTE2,
	  DP_ENABLED_FLAG
	  )
  select  p_demand_plan_id,
          mlv.instance,
          mlv.level_id,
          mlv.sr_level_pk,
          mlv.level_pk,
          sysdate,
          fnd_global.user_id,
          sysdate,
          fnd_global.user_id,
	  mlv.system_attribute1,
	  mlv.system_attribute2,
	  mlv.dp_enabled_flag
      from msd_level_values mlv,
      msd_levels ml
  where ml.level_id = mlv.level_id
  and ml.dimension_code not in (C_PRD_DIM_CODE,C_ORG_DIM_CODE)
         minus
        select p_demand_plan_id,
               instance,
               level_id,
               sr_level_pk,
               level_pk,
               sysdate,
               fnd_global.user_id,
               sysdate,
               fnd_global.user_id,
	       system_attribute1,
	       system_attribute2,
	       dp_enabled_flag
	  from msd_level_values_ds_temp
         where demand_plan_id = p_demand_plan_id;
end if;

-- Bug 3239820. Cannot Download Input Scenario if LOB used
-- Performance enhancement to insert level_pk 0.

          ins_pseudo_level_pk (errbuf,
                               retcode,
                               p_demand_plan_id);

          ins_other_level_val (errbuf,
                               retcode,
                               p_demand_plan_id);
          ins_all_level_val (errbuf,
 	                                retcode,
 	                                p_demand_plan_id);

if l_debug = C_YES_FLAG then
    debug_out( 'Exiting insert_non_stripe_level_values ' || to_char(sysdate, 'hh24:mi:ss'));
end if;

end;

procedure handle_remaining_level_values (errbuf           out nocopy varchar2,
                                         retcode          out nocopy varchar2,
                                         p_demand_plan_id in         number) is

x_rep_dim_code varchar2(30);
x_geo_dim_code varchar2(30);

begin

if l_debug = C_YES_FLAG then
    debug_out( 'Entering handle_remaining_level_values ' || to_char(sysdate, 'hh24:mi:ss'));
end if;

if (is_dim_in_plan(p_demand_plan_id, C_REP_DIM_CODE) = C_TRUE) then

  insert_related_level_values(errbuf, retcode, p_demand_plan_id, C_REPS_LEVEL_ID);

  if (chk_insert_no_associations (errbuf,
                                  retcode,
                                  p_demand_plan_id,
                                  C_REPS_LEVEL_ID) = C_TRUE) then

    x_rep_dim_code := C_REP_DIM_CODE;

  else

    walk_up_hierarchy(errbuf, retcode, p_demand_plan_id, C_REPS_LEVEL_ID);

  end if;
else
  x_rep_dim_code := C_REP_DIM_CODE;
end if;

if (is_dim_in_plan(p_demand_plan_id, C_GEO_DIM_CODE) = C_TRUE) then

  insert_related_level_values(errbuf, retcode, p_demand_plan_id, C_SHIP_LEVEL_ID);

  if (chk_insert_no_associations (errbuf,
                                  retcode,
                                  p_demand_plan_id,
                                  C_SHIP_LEVEL_ID) = C_TRUE) then

    x_geo_dim_code := C_GEO_DIM_CODE;

  else

   walk_up_hierarchy(errbuf, retcode, p_demand_plan_id, C_SHIP_LEVEL_ID);

  end if;

else
  x_geo_dim_code := C_GEO_DIM_CODE;
end if;

insert_non_stripe_level_values( errbuf, retcode, p_demand_plan_id, x_rep_dim_code, x_geo_dim_code);

if l_debug = C_YES_FLAG then
    debug_out( 'Exiting handle_remaining_level_values ' || to_char(sysdate, 'hh24:mi:ss'));
end if;

end;


-- This Procedure Produces and executes a dynamic sql statement
-- to insert data into the fact stripe table. Here's an example
-- of what the sql looks like :
--    insert into msd_cs_data_ds
--    (
--      demand_plan_id,
--      cs_data_id,
--      cs_definition_id,
--      cs_name,
--      last_update_date,
--      last_updated_by,
--      creation_date,
--      created_by
--    )
--      select mds.demand_plan_id,
--             csd.cs_data_id,
--             csd.cs_definition_id,
--             csd.cs_name,
--             sysdate,
--             fnd_global.user_id,
--             sysdate,
--             fnd_global.user_id
--        from (select demand_plan_id from msd_dp_session) mds,
--             msd_cs_data_v1 csd,
--             msd_level_values_ds mld
--       where csd.cs_definition_id =  21
--         and mld.level_pk = csd.product_lvl_pk

procedure insert_fact_data (errbuf          out nocopy varchar2,
                                         retcode         out nocopy varchar2,
                                         p_demand_plan_id in number,
                                         p_fast_refresh  in varchar2) is
cursor c0 is
select distinct
       parameter_type,
       parameter_name
from msd_dp_parameters
where demand_plan_id = p_demand_plan_id;

cursor c1(p_cs_defn_name in varchar2) is
select cs_definition_id,
       multiple_stream_flag,
       stripe_flag
from msd_cs_definitions
where name = p_cs_defn_name;

cursor c2(p_cs_id in number) is
select dimension_code
from msd_cs_defn_dim_dtls
where cs_definition_id = p_cs_id
and collect_flag = C_YES_FLAG
and dimension_code <> 'TIM';

cursor c4 (p_cs_id in number, p_cs_name in varchar2) is
select last_refresh_num
from msd_cs_data_headers
where cs_definition_id = p_cs_id
and cs_name = nvl(p_cs_name, cs_name)
order by last_refresh_num desc;

cursor c5 (p_parameter_type in varchar2, p_parameter_name in varchar2) is
select refresh_num
from msd_dp_parameters_ds
where demand_plan_id = p_demand_plan_id
and parameter_type = p_parameter_type
and nvl(parameter_name, '&*') = nvl(p_parameter_name, nvl(parameter_name, '&*'))
and data_type = C_FACT;

fact_refresh number;
stripe_refresh number;

i number:= 0;
x_dim_level_id_clmn varchar2(100);
x_dim_level_pk_clmn varchar2(100);
x_str_name varchar2(1000);

v_sql_stmt varchar2(5000);
v_sql_where_stmt varchar2(5000);
v_sql_refresh_stmt varchar2(500);

l_c1_rec c1%rowtype;

begin

if l_debug = C_YES_FLAG then
    debug_out( 'Entering insert_fact_data ' || to_char(sysdate, 'hh24:mi:ss'));
end if;


for c0_rec in c0 loop

  v_sql_stmt := '';
  v_sql_where_stmt := '';
  i := 0;

  for c1_rec in c1(c0_rec.parameter_type) loop

    if (c1_rec.stripe_flag = 'N') then
      exit;
    end if;

    if (p_fast_refresh = C_FAST_REF) then

      open c4(c1_rec.cs_definition_id, c0_rec.parameter_name);
      fetch c4 into fact_refresh;
      close c4;

      open c5(c0_rec.parameter_type, c0_rec.parameter_name);
      fetch c5 into stripe_refresh;
      close c5;

      if (stripe_refresh >= fact_refresh) then
        exit;
      end if;

      /* append the following sql to the insert statement */
      /* This will only insert records which have last_refresh num > the current one */
      if (stripe_refresh < fact_refresh) then
        v_sql_refresh_stmt := ' and created_by_refresh_num > ' || stripe_refresh;
      end if;

    else

      open c5(c0_rec.parameter_type, c0_rec.parameter_name);
      fetch c5 into stripe_refresh;
      close c5;

      /* Check to see if this stripe has been built already. */

      if (stripe_refresh is not null) then

        /* check if delete by parameter_name is necesary */
        if (c1_rec.multiple_stream_flag = C_YES_FLAG) then
          delete from msd_cs_data_ds
                where demand_plan_id = p_demand_plan_id
                  and cs_definition_id = c1_rec.cs_definition_id
                  and cs_name = c0_rec.parameter_name;
        else
          delete from msd_cs_data_ds
                where demand_plan_id = p_demand_plan_id
                  and cs_definition_id = c1_rec.cs_definition_id;
        end if;
      end if;
    end if;




    v_sql_stmt := v_sql_stmt || ' insert into msd_cs_data_ds ';
    v_sql_stmt := v_sql_stmt || ' (demand_plan_id, cs_data_id, cs_definition_id, cs_name, ';
    v_sql_stmt := v_sql_stmt || ' last_update_date, last_updated_by, creation_date, created_by) ';
    v_sql_stmt := v_sql_stmt || ' select /*+ ORDERED */ mds.demand_plan_id, cdv.cs_data_id, cdv.cs_definition_id, cdv.cs_name, sysdate,  fnd_global.user_id, sysdate, fnd_global.user_id ';
    v_sql_stmt := v_sql_stmt || ' from (select demand_plan_id from msd_dp_session) mds, ';
    v_sql_stmt := v_sql_stmt || ' msd_cs_data_v1 cdv ';
    v_sql_where_stmt := v_sql_where_stmt || ' where cdv.cs_definition_id =  ' || c1_rec.cs_definition_id || ' and mds.demand_plan_id = ' || p_demand_plan_id;

    for c2_rec in c2(c1_rec.cs_definition_id) loop

      i := i + 1;
      v_sql_stmt := v_sql_stmt || ' , ' || ' msd_level_values_ds mld' || i ;

        v_sql_where_stmt := v_sql_where_stmt || ' and mld' || i || '.level_pk = cdv.' || c2_rec.dimension_code || '_LEVEL_VALUE_PK ';
        v_sql_where_stmt := v_sql_where_stmt || ' and mld' || i || '.demand_plan_id = mds.demand_plan_id ';
    end loop;

    if (c1_rec.multiple_stream_flag = C_YES_FLAG) then

      x_str_name := get_desig_clmn_name(c1_rec.cs_definition_id);

      v_sql_where_stmt := v_sql_where_stmt || ' and cdv.' || x_str_name || ' = :parameter_name ' ;

    end if;

    v_sql_stmt := v_sql_stmt || v_sql_where_stmt;

    -- Fast Refresh
    if ( p_fast_refresh = C_FAST_REF ) then
      v_sql_stmt := v_sql_stmt || v_sql_refresh_stmt;
    end if;


    if l_debug = C_YES_FLAG then
      i := 1;
      while i<= length(v_sql_stmt) loop
           debug_out( substr(v_sql_stmt, i, 90));
           i := i+90;
      end loop;
    end if;

    /* Set demand plan for session */
    msd_stripe_demand_plan.set_demand_plan(p_demand_plan_id);

    -- Execute Statement
    if (c1_rec.multiple_stream_flag = C_YES_FLAG) then
      execute immediate v_sql_stmt using c0_rec.parameter_name;
    else
      execute immediate v_sql_stmt;
    end if;


      fact_refresh := null;
      stripe_refresh := null;
    end loop;
end loop;


if l_debug = C_YES_FLAG then
    debug_out( 'Exiting insert_fact_data ' || to_char(sysdate, 'hh24:mi:ss'));
end if;


end;

procedure create_level_val_stripe (errbuf           out nocopy varchar2,
                                   retcode          out nocopy varchar2,
                                   p_demand_plan_id in number,
                                   p_stripe_instance in varchar2,
                                   p_stripe_level_id in number,
                                   p_stripe_sr_level_pk in varchar2

) is

x_dimension_code varchar2(300);

x_lv_last_refresh_num number;
x_dp_lv_last_refresh_num number;
l_refresh_level_values varchar2(100) := C_FALSE;

cursor c0(p_level_id in number) is
select dimension_code
  from msd_levels ml
 where level_id = p_level_id;

/* Bug# 4937978
 * The columns system_attribute1, system_attribute2 and dp_enabled_flag
 * should also be inserted.
 */
cursor c1(p_instance in varchar2,
          p_level_id in number,
          p_sr_level_pk in varchar2) is
select level_pk, level_value, system_attribute1, system_attribute2, dp_enabled_flag
  from msd_level_values
 where instance = p_instance
   and level_id = p_level_id
   and sr_level_pk = p_sr_level_pk;

l_c1_rec c1%rowtype;

begin

if l_debug = C_YES_FLAG then
    debug_out( 'Entering create_level_val_stripe ' || to_char(sysdate, 'hh24:mi:ss'));
end if;


    delete from msd_level_values_ds_temp
    where demand_plan_id = p_demand_plan_id;


    open c1(p_stripe_instance, p_stripe_level_id, p_stripe_sr_level_pk);
    fetch c1 into l_c1_rec;
    close c1;

    insert into msd_level_values_ds_temp
        (
          DEMAND_PLAN_ID,
          INSTANCE,
          LEVEL_ID,
          SR_LEVEL_PK,
          LEVEL_PK,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          SYSTEM_ATTRIBUTE1,                  -- Bug# 4937978
          SYSTEM_ATTRIBUTE2,
          DP_ENABLED_FLAG
        ) VALUES
        (
          p_demand_plan_id,
          p_stripe_instance,
          p_stripe_level_id,
          p_stripe_sr_level_pk,
          l_c1_rec.level_pk,
          sysdate,
          fnd_global.user_id,
          sysdate,
          fnd_global.user_id,
          l_c1_rec.system_attribute1,         -- Bug# 4937978
          l_c1_rec.system_attribute2,
          l_c1_rec.dp_enabled_flag
        );

    update msd_demand_plans
    set build_stripe_level_pk = l_c1_rec.level_pk,
        build_stripe_stream_name = null,
        build_stripe_stream_desig = null,
        build_stripe_stream_ref_num = null
    where demand_plan_id = p_demand_plan_id;

    walk_down_hierarchy(errbuf, retcode, p_demand_plan_id, p_stripe_level_id);

    open c0(p_stripe_level_id);
    fetch c0 into x_dimension_code;
    close c0;

    if (x_dimension_code = C_PRD_DIM_CODE) then
       insert_related_orgs(errbuf, retcode, p_demand_plan_id, C_ORGS_LEVEL_ID);
    end if;

    walk_up_hierarchy(errbuf, retcode, p_demand_plan_id, C_ORGS_LEVEL_ID);

    -- Checking for Org Dimension
    if (x_dimension_code <> C_PRD_DIM_CODE) then
       insert_related_level_values(errbuf, retcode, p_demand_plan_id, C_ITEM_LEVEL_ID);
    end if;

    /* insert supercession items */
    insert_supercession_items(errbuf, retcode, p_demand_plan_id);

    walk_up_hierarchy(errbuf, retcode, p_demand_plan_id, C_ITEM_LEVEL_ID);
    handle_remaining_level_values( errbuf, retcode, p_demand_plan_id);

if l_debug = C_YES_FLAG then
    debug_out( 'Exiting create_level_val_stripe ' || to_char(sysdate, 'hh24:mi:ss'));
end if;

Exception
When EX_FATAL_ERROR then
    retcode := 2;
    errbuf := substr( sqlerrm, 1, 80);
when others then
    retcode := 2;
    errbuf := substr( sqlerrm, 1, 80);
End;

function is_level_val_stripe_equal (errbuf          out nocopy varchar2,
                                           retcode         out nocopy varchar2,
                                           p_demand_plan_id in number) return varchar2 is
cursor c1 is
select demand_plan_id, instance, level_id, sr_level_pk
from msd_level_values_ds
where demand_plan_id = p_demand_plan_id
minus
select demand_plan_id, instance, level_id, sr_level_pk
from msd_level_values_ds_temp
where demand_plan_id = p_demand_plan_id;

cursor c2 is
select demand_plan_id, instance, level_id, sr_level_pk
from msd_level_values_ds_temp
where demand_plan_id = p_demand_plan_id
minus
select demand_plan_id, instance, level_id, sr_level_pk
from msd_level_values_ds
where demand_plan_id = p_demand_plan_id;

l_rec_1 c1%rowtype;
l_rec_2 c2%rowtype;
x_equal varchar2(30) := C_FALSE;

begin

open c1;
fetch c1 into l_rec_1;
if (c1%NOTFOUND) then
  open c2;
  fetch c2 into l_rec_2;
  if (c2%NOTFOUND) then
    x_equal := C_TRUE;
  end if;
end if;

return x_equal;
end;


procedure copy_level_val_stripe (errbuf          out nocopy varchar2,
                                   retcode         out nocopy varchar2,
                                       p_demand_plan_id in number) is

begin

if l_debug = C_YES_FLAG then
    debug_out( 'Entering copy_level_val_stripe ' || to_char(sysdate, 'hh24:mi:ss'));
end if;


  delete from msd_level_values_ds
  where demand_plan_id = p_demand_plan_id;

  insert into msd_level_values_ds
       (
          DEMAND_PLAN_ID,
          INSTANCE,
          LEVEL_ID,
          SR_LEVEL_PK,
          LEVEL_PK,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
	  SYSTEM_ATTRIBUTE1,
	  SYSTEM_ATTRIBUTE2,
	  DP_ENABLED_FLAG
	  )
  select DEMAND_PLAN_ID,
          INSTANCE,
          LEVEL_ID,
          SR_LEVEL_PK,
          LEVEL_PK,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
	  SYSTEM_ATTRIBUTE1,
	  SYSTEM_ATTRIBUTE2,
	  DP_ENABLED_FLAG
  from msd_level_values_ds_temp
  where demand_plan_id = p_demand_plan_id;

  delete from msd_level_values_ds_temp
  where demand_plan_id = p_demand_plan_id;

  /* Bug# 5078878
     Calling analyze table MSD_LEVEL_VALUES_DS so that the statistics
     are upto date when insert into msd_cs_data_ds is done.
   */
  commit;
  MSD_ANALYZE_TABLES.analyze_table('MSD_LEVEL_VALUES_DS',null);

if l_debug = C_YES_FLAG then
    debug_out( 'Exiting copy_level_val_stripe ' || to_char(sysdate, 'hh24:mi:ss'));
end if;

end;

function is_level_val_collected (errbuf          out nocopy varchar2,
                                           retcode         out nocopy varchar2,
                                           p_demand_plan_id in number) return varchar2 is


x_lv_last_refresh_num number;
x_dp_lv_last_refresh_num number;
l_refresh_level_values varchar2(100) := C_TRUE;

cursor c2 is
select refresh_num
from msd_dp_parameters_ds
where demand_plan_id = C_LEVEL_PLAN
and data_type = C_LVL_VAL;

cursor c3 is
select refresh_num
from msd_dp_parameters_ds
where demand_plan_id = p_demand_plan_id
and data_type = C_LVL_VAL;

begin

    open c2;
    fetch c2 into x_lv_last_refresh_num;
    close c2;

    open c3;
    fetch c3 into x_dp_lv_last_refresh_num;
    close c3;

    if (x_dp_lv_last_refresh_num >= x_lv_last_refresh_num) then
      l_refresh_level_values := C_FALSE;
    end if;

    return l_refresh_level_values;

end;

-- This function checks to see whether the GEO or REP dimensions
-- were previously attached and not attached now, or previously
-- attached and now not attached to plan. This is needed because
-- if these plans are not attached to plan then they should not
-- be striped.

function is_dimension_changed (errbuf           out nocopy varchar2,
                               retcode          out nocopy varchar2,
                               p_demand_plan_id in         number) return varchar2 is

cursor chk_change_dim1 is
select dimension_code
from msd_dp_dimensions
where demand_plan_id = p_demand_plan_id
and dimension_code in (C_REP_DIM_CODE,C_GEO_DIM_CODE)
minus
select parameter_type
from msd_dp_parameters_ds
where demand_plan_id = p_demand_plan_id
and data_type = C_DIM
and parameter_type in (C_REP_DIM_CODE,C_GEO_DIM_CODE);

cursor chk_change_dim2 is
select parameter_type
from msd_dp_parameters_ds
where demand_plan_id = p_demand_plan_id
and data_type = C_DIM
and parameter_type in (C_REP_DIM_CODE,C_GEO_DIM_CODE)
minus
select dimension_code
from msd_dp_dimensions
where demand_plan_id = p_demand_plan_id
and dimension_code in (C_REP_DIM_CODE,C_GEO_DIM_CODE);

x_dim_code varchar2(30);

begin

open chk_change_dim1;
fetch chk_change_dim1 into x_dim_code;
close chk_change_dim1;

if (x_dim_code is not null) then
  return C_TRUE;
end if;

open chk_change_dim2;
fetch chk_change_dim2 into x_dim_code;
close chk_change_dim2;

if (x_dim_code is not null) then
  return C_TRUE;
else
  return C_FALSE;
end if;

end is_dimension_changed;

function is_event_collected (errbuf           out nocopy varchar2,
                             retcode          out nocopy varchar2,
                             p_demand_plan_id in  number) return varchar2 is

l_refresh_events varchar2(30) := C_FALSE;
x_instance varchar2(100);
x_level_id number;
x_sr_level_pk varchar2(240);

cursor c1 is
select mlv.instance,
       mlv.level_id,
       mlv.sr_level_pk
 from msd_events me,
      msd_dp_events mde,
      msd_event_products mep,
      msd_evt_prod_relationships mepr,
      msd_level_values_ds mlvd,
      msd_level_values mlv
where mepr.instance = mlvd.instance
  and mepr.product_lvl_id = mlvd.level_id
  and mlvd.level_id = 1
  and mepr.sr_product_lvl_pk = mlvd.sr_level_pk
  and mep.event_id = mepr.event_id
  and mep.seq_id = mepr.seq_id
  and mepr.npi_prod_relationship = C_NPI_BASE_PRODUCT
  and me.event_id = mep.event_id
  and me.event_type = 3
  and me.event_id = mde.event_id
  and mde.demand_plan_id = p_demand_plan_id
  and mlv.instance = mep.instance
  and mlv.sr_level_pk = mep.sr_product_lvl_pk
  and mlv.level_id = mep.product_lvl_id
  and mlvd.demand_plan_id = p_demand_plan_id
minus
select instance,
       level_id,
       sr_level_pk
  from msd_level_values_ds
 where demand_plan_id = p_demand_plan_id;

begin

  if l_debug = C_YES_FLAG then
      debug_out( 'Entering is_event_collected ' || to_char(sysdate, 'hh24:mi:ss'));
  end if;

    open c1;
    fetch c1 into x_instance, x_level_id, x_sr_level_pk;
    close c1;

    if (x_sr_level_pk is not null) then
      l_refresh_events := C_TRUE;
    end if;

    if l_debug = C_YES_FLAG then
      debug_out( 'Exiting is_event_collected ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;

    return l_refresh_events;

end is_event_collected;

function is_new_stripe (errbuf          out nocopy varchar2,
                        retcode         out nocopy varchar2,
                        p_demand_plan_id in number,
                        p_stripe_instance in varchar2,
                        p_stripe_level_id in number,
                        p_stripe_sr_level_pk in varchar2,
                        p_build_stripe_level_pk in number,
			p_build_stripe_stream_name in varchar2) return varchar2 is

cursor c1(p_instance in varchar2,
          p_level_id in number,
          p_sr_level_pk in varchar2) is
select level_pk, level_value
  from msd_level_values
 where instance = p_instance
   and level_id = p_level_id
   and sr_level_pk = p_sr_level_pk;

l_new_stripe varchar2(100) := C_TRUE;
l_c1_rec c1%rowtype;

begin

    --
    -- check to see if previous stripe existed with stripe stream
    -- if so, then this time stripe could be new.
    --
    if (p_build_stripe_stream_name is not null ) then
      return l_new_stripe;
    end if;

    open c1 (p_stripe_instance, p_stripe_level_id, p_stripe_sr_level_pk);
    fetch c1 into l_c1_rec;
    close c1;

    if (l_c1_rec.level_pk = p_build_stripe_level_pk) then
      l_new_stripe := C_FALSE;
    end if;

    return l_new_stripe;

end;


procedure delete_fact_data  (errbuf           out nocopy varchar2,
                             retcode          out nocopy varchar2,
                             p_demand_plan_id in  number) is

cursor c1 is
select parameter_type, parameter_name
from msd_dp_parameters_ds
where demand_plan_id = p_demand_plan_id
and data_type = C_FACT
minus
select parameter_type, parameter_name
from msd_dp_parameters
where demand_plan_id = p_demand_plan_id;

begin

if l_debug = C_YES_FLAG then
    debug_out( 'Entering delete_fact_data ' || to_char(sysdate, 'hh24:mi:ss'));
end if;


for c1_rec in c1 loop

  if (c1_rec.parameter_name is not null) then

    delete from msd_cs_data_ds
    where cs_definition_id = (select cs_definition_id
				from msd_cs_definitions
                               where name = c1_rec.parameter_type)
    and cs_name = c1_rec.parameter_name
    and demand_plan_id = p_demand_plan_id;

  else

    delete from msd_cs_data_ds
    where cs_definition_id = (select cs_definition_id
                                from msd_cs_definitions
                               where name = c1_rec.parameter_type)
    and demand_plan_id = p_demand_plan_id;

  end if;

end loop;

if l_debug = C_YES_FLAG then
    debug_out( 'Exiting delete_fact_data ' || to_char(sysdate, 'hh24:mi:ss'));
end if;

end;

procedure update_dp_parameters_ds  (errbuf          out nocopy varchar2,
                                    retcode         out nocopy varchar2,
                                    p_demand_plan_id in number) is



begin

if l_debug = C_YES_FLAG then
    debug_out( 'Entering update_dp_parameters_ds ' || to_char(sysdate, 'hh24:mi:ss'));
end if;



delete from msd_dp_parameters_ds
where demand_plan_id = p_demand_plan_id;

insert into msd_dp_parameters_ds
(  DEMAND_PLAN_ID,
   DATA_TYPE,
   PARAMETER_TYPE,
   PARAMETER_NAME,
   REFRESH_NUM,
   LAST_UPDATE_DATE,
   LAST_UPDATED_BY,
   CREATION_DATE,
   CREATED_BY
)
  select p_demand_plan_id,
         C_LVL_VAL,
         null,
         null,
         refresh_num,
         sysdate,
         fnd_global.user_id,
         sysdate,
         fnd_global.user_id
    from msd_dp_parameters_ds
   where demand_plan_id =  C_LEVEL_PLAN
     and data_type = C_LVL_VAL
   union all
  select p_demand_plan_id,
         C_FACT,
         mdp.parameter_type,
         mdp.parameter_name,
         max(csh.last_refresh_num),
         sysdate,
         fnd_global.user_id,
         sysdate,
         fnd_global.user_id
    from msd_dp_parameters mdp,
         msd_cs_data_headers csh,
         msd_cs_definitions csd
   where mdp.parameter_type = csd.name
     and csd.cs_definition_id = csh.cs_definition_id
     and csh.cs_name = nvl(mdp.parameter_name, csh.cs_name)
     and mdp.demand_plan_id = p_demand_plan_id
group by mdp.parameter_type, mdp.parameter_name
   union all
  select p_demand_plan_id,
         C_DIM,
         mdd.dimension_code,
         null,
         null,
         sysdate,
         fnd_global.user_id,
         sysdate,
         fnd_global.user_id
    from msd_dp_dimensions mdd
   where mdd.demand_plan_id = p_demand_plan_id;

if l_debug = C_YES_FLAG then
    debug_out( 'Exiting update_dp_parameters_ds ' || to_char(sysdate, 'hh24:mi:ss'));
end if;

end;



Procedure stripe_demand_plan_lob (errbuf                   out nocopy varchar2,
                                  retcode                  out nocopy varchar2,
                                  p_demand_plan_id         in         number,
                                  p_stripe_instance               in         varchar2,
                                  p_stripe_level_id        in         number,
                                  p_stripe_sr_level_pk     in         varchar2,
                                  p_build_stripe_level_pk  in         varchar2,
				  p_build_stripe_stream_name in varchar2) IS

Begin
    if l_debug = C_YES_FLAG then
      debug_out( 'Entering stripe_demand_plan_lob ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;
    --
    -- Set the demand plan Id in the temp table.
    --
    set_demand_plan(p_demand_plan_id);

    --
    -- Check if level values has been re-collected or a different LOB
    -- has been selected.
    --
    if ((is_level_val_collected (errbuf, retcode, p_demand_plan_id) = C_TRUE) or
        (is_event_collected(errbuf,retcode,p_demand_plan_id) = C_TRUE) or
        (is_new_stripe (errbuf,retcode,p_demand_plan_id,
                                 p_stripe_instance,
                                 p_stripe_level_id,
                                 p_stripe_sr_level_pk,
                                 p_build_stripe_level_pk,
				 p_build_stripe_stream_name) = C_TRUE) or
        (is_dimension_changed(errbuf, retcode, p_demand_plan_id) = C_TRUE) or
        (is_iso_orgs_changed (errbuf, retcode, p_demand_plan_id) = C_TRUE)) then  /* ISO Code Change */

        --
        -- Create the Stripe in the Temp Stripe Table.
        --
        create_level_val_stripe (errbuf,
                                 retcode,
                                 p_demand_plan_id,
                                 p_stripe_instance,
                                 p_stripe_level_id,
                                 p_stripe_sr_level_pk);


        --
        -- If the stripe is different then copy it into the Stripe Table.
        --
        if (is_level_val_stripe_equal(errbuf, retcode, p_demand_plan_id) = C_FALSE) then
          copy_level_val_stripe (errbuf, retcode, p_demand_plan_id);
          l_fast_refresh_fact := C_FULL_REF;
        else
          l_fast_refresh_fact := C_FAST_REF;
        end if;
    else
        l_fast_refresh_fact := C_FAST_REF;
    end if;

    if l_debug = C_YES_FLAG then
      debug_out( 'Exiting stripe_demand_plan_lob ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;
end;

procedure stripe_demand_plan_stream (errbuf           out nocopy varchar2,
                                     retcode          out nocopy varchar2,
                                     p_demand_plan_id in         number,
                                     p_build_stripe_level_pk in number,
                                     p_stripe_stream_name in varchar2,
                                     p_stripe_stream_desig in varchar2,
                                     p_build_stripe_stream_name in varchar2,
                                     p_build_stripe_stream_desig in varchar2,
                                     p_build_stripe_stream_ref_num in number) IS

Begin
    if l_debug = C_YES_FLAG then
      debug_out( 'Entering stripe_demand_plan_stream ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;
    --
    -- Set the demand plan Id in the temp table.
    --
    set_demand_plan(p_demand_plan_id);

    --
    -- Check if level values has been re-collected or a different LOB
    -- has been selected.
    --
    if ((is_level_val_collected (errbuf, retcode, p_demand_plan_id) = C_TRUE) OR
        (is_event_collected(errbuf,retcode,p_demand_plan_id) = C_TRUE) or
        (is_new_stream_stripe(errbuf, retcode, p_demand_plan_id,
                               p_build_stripe_level_pk,
                               p_stripe_stream_name,
                               p_stripe_stream_desig ,
                               p_build_stripe_stream_name,
                               p_build_stripe_stream_desig,
                               p_build_stripe_stream_ref_num) = C_TRUE) or
        (is_dimension_changed(errbuf, retcode, p_demand_plan_id) = C_TRUE) or
        (is_iso_orgs_changed (errbuf, retcode, p_demand_plan_id) = C_TRUE)) then  /* ISO Code Change */

        --
        -- Create the Stripe in the Temp Stripe Table.
        --
        create_level_val_stripe_stream (errbuf,
                                        retcode,
                                        p_demand_plan_id,
                                        p_stripe_stream_name,
                                        p_stripe_stream_desig);


        --
        -- If the stripe is different then copy it into the Stripe Table.
        --
        if (is_level_val_stripe_equal(errbuf, retcode, p_demand_plan_id) = C_FALSE) then
          copy_level_val_stripe (errbuf, retcode, p_demand_plan_id);
          l_fast_refresh_fact := C_FULL_REF;
        else
          l_fast_refresh_fact := C_FAST_REF;
        end if;
    else
        l_fast_refresh_fact := C_FAST_REF;
    end if;


    --
    -- For each input parameter insert data into stripe fact table.
    --
    insert_fact_data  (errbuf, retcode, p_demand_plan_id, l_fast_refresh_fact);

    --
    -- For deleted input parameter remove data from stripe fact table.
    --
    delete_fact_data  (errbuf, retcode, p_demand_plan_id);

    --
    -- Record what information was used to build the stripe.
    --
    update_dp_parameters_ds (errbuf, retcode, p_demand_plan_id);

    commit;
    MSD_ANALYZE_TABLES.analyze_table(null,7);

    if l_debug = C_YES_FLAG then
      debug_out( 'Exiting stripe_demand_plan_stream ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;
end;


function chk_insert_no_associations (errbuf              out nocopy varchar2,
                                      retcode             out nocopy varchar2,
                                      p_demand_plan_id    in         number,
                                      p_level_id          in         number) return varchar2 IS

cursor chk_row_count is
select 1
  from msd_level_values_ds_temp
 where demand_plan_id = p_demand_plan_id
   and level_id = p_level_id
   and rownum = 1;

x_cnt number;

begin

open chk_row_count;
fetch chk_row_count into x_cnt;

if (chk_row_count%NOTFOUND) then
  close chk_row_count;
  return C_TRUE;
else
  close chk_row_count;
  return C_FALSE;
end if;

end chk_insert_no_associations;

procedure create_level_val_stripe_stream (errbuf out nocopy varchar2,
                                        retcode out nocopy varchar2,
                                        p_demand_plan_id in number,
                                        p_stripe_stream_name in varchar2,
                                        p_stripe_stream_desig in varchar2) IS

x_dimension_code varchar2(300);

x_lv_last_refresh_num number;
x_dp_lv_last_refresh_num number;
l_refresh_level_values varchar2(100) := C_FALSE;
x_refresh_num number;

cursor c0(p_level_id in number) is
select dimension_code
  from msd_levels ml
 where level_id = p_level_id;

begin

if l_debug = C_YES_FLAG then
    debug_out( 'Entering create_level_val_stripe_stream ' || to_char(sysdate, 'hh24:mi:ss'));
end if;

    delete from msd_level_values_ds_temp
    where demand_plan_id = p_demand_plan_id;

    insert_stream_items(errbuf,
                        retcode,
                        p_demand_plan_id,
                        p_stripe_stream_name,
                        p_stripe_stream_desig,
                        C_PRD_DIM_CODE);

    /* insert supercession items */
    insert_supercession_items(errbuf, retcode, p_demand_plan_id);

    open get_refresh_num(p_stripe_stream_name, p_stripe_stream_desig);
    fetch get_refresh_num into x_refresh_num;
    close get_refresh_num;

    update msd_demand_plans
    set build_stripe_stream_name = p_stripe_stream_name,
        build_stripe_stream_desig = p_stripe_stream_desig,
        build_stripe_stream_ref_num = x_refresh_num,
        build_stripe_level_pk = null
    where demand_plan_id = p_demand_plan_id;

    insert_related_orgs(errbuf, retcode, p_demand_plan_id, C_ORGS_LEVEL_ID);

    walk_up_hierarchy(errbuf, retcode, p_demand_plan_id, C_ORGS_LEVEL_ID);
    walk_up_hierarchy(errbuf, retcode, p_demand_plan_id, C_ITEM_LEVEL_ID);

    handle_remaining_level_values( errbuf, retcode, p_demand_plan_id);

if l_debug = C_YES_FLAG then
    debug_out( 'Exiting create_level_val_stripe_stream ' || to_char(sysdate, 'hh24:mi:ss'));
end if;
END create_level_val_stripe_stream;

procedure create_lvl_val_stripe_strm_lob (errbuf out nocopy varchar2,
                                          retcode out nocopy varchar2,
                                          p_demand_plan_id in number,
                                          p_stripe_instance in varchar2,
                                          p_stripe_level_id in number,
                                          p_stripe_sr_level_pk in varchar2 ,
                                          p_stripe_stream_name in varchar2,
                                          p_stripe_stream_desig in varchar2) IS
x_dimension_code varchar2(300);

x_lv_last_refresh_num number;
x_dp_lv_last_refresh_num number;
l_refresh_level_values varchar2(100) := C_FALSE;

cursor c0(p_level_id in number) is
select dimension_code
  from msd_levels ml
 where level_id = p_level_id;

/* Bug# 4937978
 * The columns system_attribute1, system_attribute2 and dp_enabled_flag
 * should also be inserted.
 */
cursor c1(p_instance in varchar2,
          p_level_id in number,
          p_sr_level_pk in varchar2) is
select level_pk, level_value, system_attribute1, system_attribute2, dp_enabled_flag
  from msd_level_values
 where instance = p_instance
   and level_id = p_level_id
   and sr_level_pk = p_sr_level_pk;

l_c1_rec c1%rowtype;
x_refresh_num number;

BEGIN

    delete from msd_level_values_ds_temp
    where demand_plan_id = p_demand_plan_id;

    open c1(p_stripe_instance, p_stripe_level_id, p_stripe_sr_level_pk);
    fetch c1 into l_c1_rec;
    close c1;

    insert into msd_level_values_ds_temp
        (
          DEMAND_PLAN_ID,
          INSTANCE,
          LEVEL_ID,
          SR_LEVEL_PK,
          LEVEL_PK,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          SYSTEM_ATTRIBUTE1,                  -- Bug# 4937978
          SYSTEM_ATTRIBUTE2,
          DP_ENABLED_FLAG
        ) VALUES
        (
          p_demand_plan_id,
          p_stripe_instance,
          p_stripe_level_id,
          p_stripe_sr_level_pk,
          l_c1_rec.level_pk,
          sysdate,
          fnd_global.user_id,
          sysdate,
          fnd_global.user_id,
          l_c1_rec.system_attribute1,         -- Bug# 4937978
          l_c1_rec.system_attribute2,
          l_c1_rec.dp_enabled_flag
        );

    open get_refresh_num(p_stripe_stream_name, p_stripe_stream_desig);
    fetch get_refresh_num into x_refresh_num;
    close get_refresh_num;

    update msd_demand_plans
    set build_stripe_level_pk = l_c1_rec.level_pk,
        build_stripe_stream_name = p_stripe_stream_name,
        build_stripe_stream_desig = p_stripe_stream_desig,
        build_stripe_stream_ref_num = x_refresh_num
    where demand_plan_id = p_demand_plan_id;

    walk_down_hierarchy(errbuf, retcode, p_demand_plan_id, p_stripe_level_id);

    open c0(p_stripe_level_id);
    fetch c0 into x_dimension_code;
    close c0;

    if (x_dimension_code = C_ORG_DIM_CODE) then
       insert_related_level_values(errbuf, retcode, p_demand_plan_id, C_ITEM_LEVEL_ID);
    end if;

    filter_stream_items(errbuf,
                        retcode,
                        p_demand_plan_id,
                        p_stripe_stream_name,
                        p_stripe_stream_desig,
                        C_PRD_DIM_CODE);

    /* insert supercession items */
    insert_supercession_items(errbuf, retcode, p_demand_plan_id);

    -- If Product Stripe then insert orgs
    if (x_dimension_code = C_PRD_DIM_CODE) then
       insert_related_orgs(errbuf, retcode, p_demand_plan_id, C_ORGS_LEVEL_ID);
    end if;

    walk_up_hierarchy(errbuf, retcode, p_demand_plan_id, C_ORGS_LEVEL_ID);
    walk_up_hierarchy(errbuf, retcode, p_demand_plan_id, C_ITEM_LEVEL_ID);

    handle_remaining_level_values( errbuf, retcode, p_demand_plan_id);

END create_lvl_val_stripe_strm_lob;

procedure stripe_demand_plan_lob_stream (errbuf           out nocopy varchar2,
                                            retcode          out nocopy varchar2,
                                            p_demand_plan_id in         number,
                                   p_stripe_instance in varchar2,
                                   p_stripe_level_id in number,
                                   p_stripe_sr_level_pk in varchar2,
                                   p_build_stripe_level_pk in number,
                                     p_stripe_stream_name in varchar2,
                                     p_stripe_stream_desig in varchar2,
                                     p_build_stripe_stream_name in varchar2,
                                     p_build_stripe_stream_desig in varchar2,
                                     p_build_stripe_stream_ref_num in number) is

Begin
    if l_debug = C_YES_FLAG then
      debug_out( 'Entering stripe_demand_plan_lob_stream ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;
    --
    -- Set the demand plan Id in the temp table.
    --
    set_demand_plan(p_demand_plan_id);


    --
    -- Check if level values has been re-collected or a different LOB
    -- has been selected.
    --
    if ((is_level_val_collected (errbuf, retcode, p_demand_plan_id) = C_TRUE) or
        (is_event_collected(errbuf,retcode,p_demand_plan_id) = C_TRUE) or
        (is_new_lob_stream_stripe (errbuf,
                                   retcode,
                                   p_demand_plan_id,
                                   p_stripe_instance,
                                   p_stripe_level_id,
                                   p_stripe_sr_level_pk,
                                   p_build_stripe_level_pk,
                                   p_stripe_stream_name,
                                   p_stripe_stream_desig,
                                   p_build_stripe_stream_name,
                                   p_build_stripe_stream_desig,
                                   p_build_stripe_stream_ref_num) = C_TRUE) or
        (is_dimension_changed(errbuf, retcode, p_demand_plan_id) = C_TRUE) or
        (is_iso_orgs_changed (errbuf, retcode, p_demand_plan_id) = C_TRUE)) then  /* ISO Code Change */

        --
        -- Create the Stripe in the Temp Stripe Table.
        --
        create_lvl_val_stripe_strm_lob (errbuf,
                                        retcode ,
                                        p_demand_plan_id ,
                                        p_stripe_instance ,
                                        p_stripe_level_id ,
                                        p_stripe_sr_level_pk ,
                                        p_stripe_stream_name ,
                                        p_stripe_stream_desig );


        --
        -- If the stripe is different then copy it into the Stripe Table.
        --
        if (is_level_val_stripe_equal(errbuf, retcode, p_demand_plan_id) = C_FALSE) then
          copy_level_val_stripe (errbuf, retcode, p_demand_plan_id);
          l_fast_refresh_fact := C_FULL_REF;
        else
          l_fast_refresh_fact := C_FAST_REF;
        end if;
    else
        l_fast_refresh_fact := C_FAST_REF;
    end if;

    if l_debug = C_YES_FLAG then
      debug_out( 'Exiting stripe_demand_plan_stream_lob ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;
end;

procedure insert_stream_items(errbuf out nocopy varchar2,
                                        retcode out nocopy varchar2,
                                        p_demand_plan_id in number,
                                        p_stripe_stream_name in varchar2,
                                        p_stripe_stream_desig in varchar2,
                                        p_dim_code in varchar2) IS

cursor get_stream_defn(p_name in varchar2) is
select mcd.cs_definition_id,
       mcd.name,
       mcd.multiple_stream_flag,
       mcd.stripe_flag,
       nvl(mcd.planning_server_view_name, 'MSD_CS_DATA_V')
from msd_cs_definitions mcd
where name = p_name;

cursor get_dim_col_id (p_cs_id in number) is
SELECT collect_level_id
  FROM msd_cs_defn_dim_dtls
 where dimension_code = p_dim_code
   and collect_flag = 'Y'
   and cs_definition_id = p_cs_id;

cursor get_dim_lvl_clmn_name(p_cs_id in number) IS
SELECT planning_view_column_name
  FROM msd_cs_defn_column_dtls_v
 WHERE column_identifier  = upper(p_dim_code)||'_LEVEL_ID'
   AND identifier_type    = 'DIMENSION_ID'
   AND cs_definition_id   = p_cs_id;

l_sql_stmt varchar2(2000);
x_cs_definition_id number;
x_name varchar2(30);
x_multiple_stream_flag varchar2(30);
x_stripe_flag varchar2(30);
x_planning_server_view_name varchar2(30);
x_dim_col_id number;
x_dim_lvl_clmn_name varchar2(30);
x_desig_clmn_name varchar2(30);

begin

if l_debug = C_YES_FLAG then
    debug_out( 'Entering insert_stream_items ' || to_char(sysdate, 'hh24:mi:ss'));
end if;

open get_stream_defn(p_stripe_stream_name);
fetch get_stream_defn into x_cs_definition_id,
                           x_name,
x_multiple_stream_flag,
x_stripe_flag,
x_planning_server_view_name;
close get_stream_defn;

open get_dim_lvl_clmn_name(x_cs_definition_id);
fetch get_dim_lvl_clmn_name into x_dim_lvl_clmn_name;
close get_dim_lvl_clmn_name;

open get_dim_col_id (x_cs_definition_id);
fetch get_dim_col_id into x_dim_col_id;
close get_dim_col_id;

x_desig_clmn_name := get_desig_clmn_name (x_cs_definition_id);

l_sql_stmt := ' insert into msd_level_values_ds_temp ' ||
              ' ( ' ||
              '   DEMAND_PLAN_ID,   ' ||
              '   INSTANCE,         ' ||
              '   LEVEL_ID,         ' ||
              '   SR_LEVEL_PK,      ' ||
              '   LEVEL_PK,         ' ||
              '   LAST_UPDATE_DATE, ' ||
              '   LAST_UPDATED_BY,   ' ||
              '   CREATION_DATE,    ' ||
              '   CREATED_BY,   ' ||
	      '   SYSTEM_ATTRIBUTE1,  ' ||
	      '   SYSTEM_ATTRIBUTE2,  ' ||
	      '   DP_ENABLED_FLAG     ' ||
	      '  ) ' ||
              '  select distinct ' || p_demand_plan_id || ' , ' ||
              ' mlv.instance, ' ||
              ' mlv.level_id, ' ||
              '  mlv.sr_level_pk, ' ||
              '  mlv.level_pk, ' ||
              '  sysdate, ' ||
              '  fnd_global.user_id, ' ||
              '  sysdate, ' ||
              '  fnd_global.user_id, ' ||
	      '  mlv.system_attribute1, ' ||
	      '  mlv.system_attribute2, ' ||
	      '  mlv.dp_enabled_flag  ' ||
	  ' from msd_level_values mlv, ' ||
               x_planning_server_view_name || ' fact ' ||
        ' where mlv.level_pk = fact.' || p_dim_code || '_LEVEL_VALUE_PK ' ||
        ' and mlv.level_id = fact.' ||  x_dim_lvl_clmn_name ||
         ' and fact.action_code = ''I''';

        if (x_stripe_flag = 'Y') then
          l_sql_stmt := l_sql_stmt || ' and fact.cs_definition_id = ' || x_cs_definition_id;
          end if;

        if ((p_stripe_stream_desig is not null) and (x_multiple_stream_flag = 'Y')) then
        l_sql_stmt := l_sql_stmt || ' and fact.' || x_desig_clmn_name || ' = ''' || replace(p_stripe_stream_desig, '''', '''''') || '''';
        end if;
       debug_out(l_sql_stmt);
       execute immediate l_sql_stmt;



if l_debug = C_YES_FLAG then
    debug_out( 'Exiting insert_stream_items ' || to_char(sysdate, 'hh24:mi:ss'));
end if;

end;

   /***********************************************************************
    * Returns True or False if user changed stripe stream value from
    * that previously used.
    */

   function is_new_stream_stripe (errbuf           out nocopy varchar2,
                                  retcode          out nocopy varchar2,
                                  p_demand_plan_id in         number,
                                  p_build_stripe_level_pk in number,
                                  p_stripe_stream_name in varchar2,
                                  p_stripe_stream_desig in varchar2,
                                  p_build_stripe_stream_name in varchar2,
                                  p_build_stripe_stream_desig in varchar2,
                                  p_build_stripe_stream_ref_num in number) return varchar2 is

  x_curr_ref_num number;

  begin

  --
  -- check to see if previous stripe existed with stripe lob
  -- if so, then this time stripe could be new.
  --
  if (p_build_stripe_level_pk is not null ) then
    return C_TRUE;
  end if;

  -- Is this the same selection

  if (((p_build_stripe_stream_name = p_stripe_stream_name)
         and (((p_build_stripe_stream_desig is null) and (p_stripe_stream_desig is null))
        or (p_build_stripe_stream_desig = p_stripe_stream_desig)))
       and (p_build_stripe_level_pk is null)) then

      -- Check to see if the refresh num has increased
      open get_refresh_num(p_stripe_stream_name, p_stripe_stream_desig);
      fetch get_refresh_num into x_curr_ref_num;
      close get_refresh_num;

      if (x_curr_ref_num > p_build_stripe_stream_ref_num) then
        return C_TRUE;
      else
        return C_FALSE;
      end if;
  else
     return C_TRUE;
  end if;
end is_new_stream_stripe;


/***********************************************************************
 * Returns True or False if user changed stripe stream value from
 * that previously used.
 */

function is_new_lob_stream_stripe (errbuf           out nocopy varchar2,
                                   retcode          out nocopy varchar2,
                                   p_demand_plan_id in         number,
                                   p_stripe_instance in varchar2,
                                   p_stripe_level_id in number,
                                   p_stripe_sr_level_pk in varchar2,
                                   p_build_stripe_level_pk in number,
                                   p_stripe_stream_name in varchar2,
                                   p_stripe_stream_desig in varchar2,
                                   p_build_stripe_stream_name in varchar2,
                                   p_build_stripe_stream_desig in varchar2,
                                   p_build_stripe_stream_ref_num in number) return varchar2 is
cursor c1(p_instance in varchar2,
          p_level_id in number,
          p_sr_level_pk in varchar2) is
select level_pk, level_value
  from msd_level_values
 where instance = p_instance
   and level_id = p_level_id
   and sr_level_pk = p_sr_level_pk;

l_new_stripe varchar2(100) := C_TRUE;
l_c1_rec c1%rowtype;
x_curr_ref_num number;

begin

    open c1 (p_stripe_instance, p_stripe_level_id, p_stripe_sr_level_pk);
    fetch c1 into l_c1_rec;
    close c1;

    if (l_c1_rec.level_pk = p_build_stripe_level_pk)
        and
        ((p_build_stripe_stream_name = p_stripe_stream_name)
           and (((p_build_stripe_stream_desig is null) and (p_stripe_stream_desig is null))
           or (p_build_stripe_stream_desig = p_stripe_stream_desig))) then

        -- Check to see if the refresh num has increased
        open get_refresh_num(p_stripe_stream_name, p_stripe_stream_desig);
        fetch get_refresh_num into x_curr_ref_num;
        close get_refresh_num;

        if (x_curr_ref_num > p_build_stripe_stream_ref_num) then
          return C_TRUE;
        else
          return C_FALSE;
        end if;
    else
       return C_TRUE;
    end if;

end is_new_lob_stream_stripe;


procedure filter_stream_items(errbuf out nocopy varchar2,
                                        retcode out nocopy varchar2,
                                        p_demand_plan_id in number,
                                        p_stripe_stream_name in varchar2,
                                        p_stripe_stream_desig in varchar2,
                                        p_dim_code in varchar2) IS

cursor get_stream_defn(p_name in varchar2) is
select mcd.cs_definition_id,
       mcd.name,
       mcd.multiple_stream_flag,
       mcd.stripe_flag,
       nvl(mcd.planning_server_view_name,'MSD_CS_DATA_V')
from msd_cs_definitions mcd
where name = p_name;

cursor get_dim_col_id (p_cs_id in number) is
SELECT collect_level_id
  FROM msd_cs_defn_dim_dtls
 where dimension_code = p_dim_code
   and collect_flag = 'Y'
   and cs_definition_id = p_cs_id;

cursor get_dim_lvl_clmn_name(p_cs_id in number) IS
SELECT planning_view_column_name
  FROM msd_cs_defn_column_dtls_v
 WHERE column_identifier  = upper(p_dim_code)||'_LEVEL_ID'
   AND identifier_type    = 'DIMENSION_ID'
   AND cs_definition_id   = p_cs_id;

l_sql_stmt varchar2(2000);
x_cs_definition_id number;
x_name varchar2(30);
x_multiple_stream_flag varchar2(30);
x_stripe_flag varchar2(30);
x_planning_server_view_name varchar2(30);
x_dim_col_id number;
x_dim_lvl_clmn_name varchar2(30);
x_dim_val_clmn_name varchar2(30);
x_desig_clmn_name varchar2(30);

begin

if l_debug = C_YES_FLAG then
    debug_out( 'Entering filter_stream_items ' || to_char(sysdate, 'hh24:mi:ss'));
end if;

open get_stream_defn(p_stripe_stream_name);
fetch get_stream_defn into x_cs_definition_id,
                           x_name,
x_multiple_stream_flag,
x_stripe_flag,
x_planning_server_view_name;
close get_stream_defn;

open get_dim_col_id (x_cs_definition_id);
fetch get_dim_col_id into x_dim_col_id;
close get_dim_col_id;

x_desig_clmn_name := get_desig_clmn_name(x_cs_definition_id);

l_sql_stmt := ' delete from msd_level_values_ds_temp ' ||
              ' where level_id = ' || C_ITEM_LEVEL_ID ||
	      ' and demand_plan_id = ' || p_demand_plan_id ||
	      ' and level_pk in ( ' ||
              ' select to_char(level_pk) from msd_level_values_ds_temp ' ||
              ' where demand_plan_id = ' || p_demand_plan_id ||
              '  minus select to_char(' ||
              ' fact.' || p_dim_code || '_LEVEL_VALUE_PK) ' ||
          ' from ' || x_planning_server_view_name || ' fact ' ||
            ' where 1 = 1 ';

        if (x_stripe_flag = 'Y') then
          l_sql_stmt := l_sql_stmt || ' and fact.cs_definition_id = ' || x_cs_definition_id;
          end if;

        if ((p_stripe_stream_desig is not null) and (x_multiple_stream_flag = 'Y')) then
        l_sql_stmt := l_sql_stmt || ' and fact.' || x_desig_clmn_name || ' = ''' || p_stripe_stream_desig || '''';
        end if;

	l_sql_stmt := l_sql_stmt || ')';


	execute immediate l_sql_stmt;

if l_debug = C_YES_FLAG then
    debug_out( 'Exiting filter_stream_items ' || to_char(sysdate, 'hh24:mi:ss'));
end if;

end filter_stream_items;

procedure insert_supercession_items (errbuf out nocopy varchar2,
                                        retcode out nocopy varchar2,
                                        p_demand_plan_id in number) IS

begin

if l_debug = C_YES_FLAG then
    debug_out( 'Entering insert_supercession_items ' || to_char(sysdate, 'hh24:mi:ss'));
end if;

    insert into msd_level_values_ds_temp
        (
          DEMAND_PLAN_ID,
          INSTANCE,
          LEVEL_ID,
          SR_LEVEL_PK,
          LEVEL_PK,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
	  SYSTEM_ATTRIBUTE1,
	  SYSTEM_ATTRIBUTE2,
	  DP_ENABLED_FLAG
	  )
        select p_demand_plan_id,
               mlv.instance,
               mlv.level_id,
               mlv.sr_level_pk,
               mlv.level_pk,
               sysdate,
               fnd_global.user_id,
               sysdate,
               fnd_global.user_id,
	       mlv.system_attribute1,
	       mlv.system_attribute2,
	       mlv.dp_enabled_flag
	  from msd_dp_events mde,
               msd_events me,
               msd_event_products mep,
               msd_evt_prod_relationships mepr,
               msd_level_values_ds_temp mlvd,
               msd_level_values mlv
         where mepr.instance = mlvd.instance
           and mepr.product_lvl_id = mlvd.level_id
           and mlvd.level_id = 1
           and mepr.sr_product_lvl_pk = mlvd.sr_level_pk
           and mep.event_id = mepr.event_id
           and mep.seq_id = mepr.seq_id
           and mepr.npi_prod_relationship = C_NPI_BASE_PRODUCT
           and me.event_id = mep.event_id
           and me.event_type = 3
           and mde.event_id = me.event_id
           and mde.demand_plan_id = p_demand_plan_id
           and mlv.instance = mep.instance
           and mlv.sr_level_pk = mep.sr_product_lvl_pk
           and mlv.level_id = mep.product_lvl_id
           and mlvd.demand_plan_id = p_demand_plan_id
               minus
        select p_demand_plan_id,
               instance,
               level_id,
               sr_level_pk,
               level_pk,
               sysdate,
               fnd_global.user_id,
               sysdate,
               fnd_global.user_id,
	       system_attribute1,
	       system_attribute2,
	       dp_enabled_flag
         from msd_level_values_ds_temp
         where demand_plan_id = p_demand_plan_id;

if l_debug = C_YES_FLAG then
    debug_out( 'Exiting insert_supercession_items ' || to_char(sysdate, 'hh24:mi:ss'));
end if;

end;

function get_desig_clmn_name (p_cs_id in number) return VARCHAR2 IS

    CURSOR get_str_name (p_id NUMBER) IS
    SELECT planning_view_column_name
    FROM   msd_cs_defn_column_dtls_v
    WHERE  cs_definition_id = p_id
    AND    identifier_type = 'CSIDEN';

    x_str_name varchar2(30);

BEGIN

    open get_str_name (p_cs_id);
    fetch get_str_name into x_str_name;
    close get_str_name;

    if (x_str_name is null) then
      x_str_name := 'CS_NAME';
    end if;

    return x_str_name;
end;

procedure handle_fact_data (errbuf out nocopy varchar2,
                            retcode out nocopy varchar2,
                            p_demand_plan_id in number) IS

BEGIN

    --
    -- For each input parameter insert data into stripe fact table.
    --
    insert_fact_data  (errbuf, retcode, p_demand_plan_id, l_fast_refresh_fact);

    --
    -- For deleted input parameter remove data from stripe fact table.
    --
    delete_fact_data  (errbuf, retcode, p_demand_plan_id);

    --
    -- Record what information was used to build the stripe.
    --
    update_dp_parameters_ds (errbuf, retcode, p_demand_plan_id);

    commit;
    MSD_ANALYZE_TABLES.analyze_table(null,7);

END Handle_Fact_data;

-- Bug 3239820. Insert Level Value Pk of 0 to optimize
-- striped view for input scenario.
-- Inserts a row of level_pk 0 into the plan stripe.
-- MSD_DP_SCENARIO_ENTRIES contains 0 in level_pk
-- columns if that particular dimension is not used.

procedure ins_pseudo_level_pk (errbuf out nocopy varchar2,
                               retcode out nocopy varchar2,
                               p_demand_plan_id in number) is

cursor chk_pseudo is
select 1
  from msd_level_values_ds_temp
 where demand_plan_id = p_demand_plan_id
   and level_pk = C_PSEUDO_PK;

x_cnt number;

begin

if l_debug = C_YES_FLAG then
    debug_out( 'Entering  ins_pseudo_level_pk ' || to_char(sysdate, 'hh24:mi:ss'));
end if;

    open chk_pseudo;
    fetch chk_pseudo into x_cnt;
    if (chk_pseudo%NOTFOUND) then

      insert into msd_level_values_ds_temp
      (
       DEMAND_PLAN_ID,
       INSTANCE,
       LEVEL_ID,
       SR_LEVEL_PK,
       LEVEL_PK,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       CREATION_DATE,
       CREATED_BY
      ) VALUES
      (
        p_demand_plan_id,
        C_PSEUDO_PK,
        C_PSEUDO_PK,
        C_PSEUDO_PK,
        C_PSEUDO_PK,
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id
      );

     end if;

     close chk_pseudo;

     open chk_pseudo;
     fetch chk_pseudo into x_cnt;
     if (chk_pseudo%NOTFOUND) then
       if l_debug = C_YES_FLAG then
         debug_out( 'Error Insert Pseudo Level Value into Stripe.');
         retcode := '2';
       end if;
     end if;
     close chk_pseudo;

if l_debug = C_YES_FLAG then
    debug_out( 'Exiting  ins_pseudo_level_pk ' || to_char(sysdate, 'hh24:mi:ss'));
end if;

end ins_pseudo_level_pk;

procedure ins_other_level_val (errbuf out nocopy varchar2,
                               retcode out nocopy varchar2,
                               p_demand_plan_id in number) is

x_other_sr_level_pk varchar2(30) := '-777';

begin

if l_debug = C_YES_FLAG then
    debug_out( 'Entering  ins_other_level_val ' || to_char(sysdate, 'hh24:mi:ss'));
end if;

    insert into msd_level_values_ds_temp
        (
          DEMAND_PLAN_ID,
          INSTANCE,
          LEVEL_ID,
          SR_LEVEL_PK,
          LEVEL_PK,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
	  SYSTEM_ATTRIBUTE1,
	  SYSTEM_ATTRIBUTE2,
	  DP_ENABLED_FLAG
	  )
        select p_demand_plan_id,
               mlv.instance,
               mlv.level_id,
               mlv.sr_level_pk,
               mlv.level_pk,
               sysdate,
               fnd_global.user_id,
               sysdate,
               fnd_global.user_id,
	       mlv.system_attribute1,
	       mlv.system_attribute2,
	       mlv.dp_enabled_flag
	 from msd_level_values mlv
         where mlv.sr_level_pk = x_other_sr_level_pk
               minus
        select p_demand_plan_id,
               instance,
               level_id,
               sr_level_pk,
               level_pk,
               sysdate,
               fnd_global.user_id,
               sysdate,
               fnd_global.user_id,
	       system_attribute1,
	       system_attribute2,
	       dp_enabled_flag
	 from msd_level_values_ds_temp
         where demand_plan_id = p_demand_plan_id;

if l_debug = C_YES_FLAG then
    debug_out( 'Exiting  ins_other_level_val ' || to_char(sysdate, 'hh24:mi:ss'));
end if;

end ins_other_level_val;

/*Bug 6672593*/
procedure ins_all_level_val (errbuf out nocopy varchar2,
 	                                 retcode out nocopy varchar2,
 	                                 p_demand_plan_id in number) is

 	 begin

 	 if l_debug = C_YES_FLAG then
 	         debug_out( 'Entering ins_all_level_val ' || to_char(sysdate, 'hh24:mi:ss'));
 	 end if;

 	 insert into msd_level_values_ds_temp
 	         (
 	           DEMAND_PLAN_ID,
 	           INSTANCE,
 	           LEVEL_ID,
 	           SR_LEVEL_PK,
 	           LEVEL_PK,
 	           LAST_UPDATE_DATE,
 	           LAST_UPDATED_BY,
 	           CREATION_DATE,
 	           CREATED_BY,
 	           SYSTEM_ATTRIBUTE1,
 	           SYSTEM_ATTRIBUTE2,
 	           DP_ENABLED_FLAG
 	         )
 	         select  p_demand_plan_id,
 	                 mlv.instance,
 	                 mlv.level_id,
 	                 mlv.sr_level_pk,
 	                 mlv.level_pk,
 	                 sysdate,
 	                 fnd_global.user_id,
 	                 sysdate,
 	                 fnd_global.user_id,
 	                 mlv.system_attribute1,
 	                 mlv.system_attribute2,
 	                 mlv.dp_enabled_flag
 	             from msd_level_values mlv
 	             where (mlv.level_id, mlv.sr_level_pk) IN (select level_id, sr_level_pk from msd_level_values where level_id in
 	                                       (select level_id from msd_levels where level_type_code = 1))
 	                 minus
 	         select  p_demand_plan_id,
 	                 instance,
 	                 level_id,
 	                 sr_level_pk,
 	                 level_pk,
 	                 sysdate,
 	                 fnd_global.user_id,
 	                 sysdate,
 	                 fnd_global.user_id,
 	                 system_attribute1,
 	                 system_attribute2,
 	                 dp_enabled_flag
 	             from msd_level_values_ds_temp
 	             where demand_plan_id = p_demand_plan_id;

 	 if l_debug = C_YES_FLAG then
 	         debug_out( 'Exiting ins_all_level_val ' || to_char(sysdate, 'hh24:mi:ss'));
 	 end if;

 end ins_all_level_val;


function is_dim_in_plan (p_demand_plan_id in number, p_dim_code in varchar2) return varchar2 is

cursor chk_dim is
select C_TRUE
from msd_dp_dimensions
where dimension_code = p_dim_code
and demand_plan_id = p_demand_plan_id;

x_is_dim_in_plan varchar2(30) := C_FALSE;

begin

open chk_dim;
fetch chk_dim into x_is_dim_in_plan;
close chk_dim;

return x_is_dim_in_plan;

end is_dim_in_plan;

procedure chk_insert_org_no_associations (errbuf              out nocopy varchar2,
                                      retcode             out nocopy varchar2,
                                      p_demand_plan_id    in         number,
                                      p_level_id          in         number) IS

cursor chk_row_count is
select 1
  from msd_level_values_ds_temp
 where demand_plan_id = p_demand_plan_id
   and level_id = p_level_id
   and rownum = 1;

x_cnt number;

begin

open chk_row_count;
fetch chk_row_count into x_cnt;

if (chk_row_count%NOTFOUND) then
  insert into msd_level_values_ds_temp
  (
          DEMAND_PLAN_ID,
          INSTANCE,
          LEVEL_ID,
          SR_LEVEL_PK,
          LEVEL_PK,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
	  SYSTEM_ATTRIBUTE1,
	  SYSTEM_ATTRIBUTE2,
	  DP_ENABLED_FLAG
	  )
        select p_demand_plan_id,
               mlv.instance,
               mlv.level_id,
               mlv.sr_level_pk,
               mlv.level_pk,
               sysdate,
               fnd_global.user_id,
               sysdate,
               fnd_global.user_id,
	       mlv.system_attribute1,
	       mlv.system_attribute2,
	       mlv.dp_enabled_flag
	 from msd_level_values mlv
         where mlv.level_id = p_level_id
         minus
        select p_demand_plan_id,
               instance,
               level_id,
               sr_level_pk,
               level_pk,
               sysdate,
               fnd_global.user_id,
               sysdate,
               fnd_global.user_id,
	       system_attribute1,
	       system_attribute2,
	       dp_enabled_flag
	 from msd_level_values_ds_temp
         where demand_plan_id = p_demand_plan_id;
end if;
close chk_row_count;
end chk_insert_org_no_associations;


   /********************************************************************
   * ISO Code Change
   * This function checks whether there is any change in the ISO orgs
   * attached to the demand plan
   */
   FUNCTION is_iso_orgs_changed (errbuf           OUT NOCOPY VARCHAR2,
                                 retcode          OUT NOCOPY VARCHAR2,
                                 p_demand_plan_id IN         NUMBER)
      RETURN VARCHAR2
   IS

      /*
       * This cursor checks whether any new internal orgs/sites have been added
       */
      CURSOR c_is_added_iso_orgs
      IS
      SELECT 1
         FROM dual
         WHERE EXISTS (SELECT mloa.sr_level_pk
                          FROM msd_dp_iso_organizations mdio,
                               msd_level_org_asscns mloa
                          WHERE
                                 mdio.demand_plan_id = p_demand_plan_id
                             AND mloa.instance = mdio.sr_instance_id
                             AND mloa.level_id = 11
                             AND mloa.org_level_id    = 7
                             AND mloa.org_sr_level_pk = mdio.sr_organization_id
                       MINUS
                       SELECT sr_level_pk
                          FROM msd_level_values_ds
                          WHERE
                                 demand_plan_id = p_demand_plan_id
                             AND level_id = 11);

      /*
       * This cursor checks whether any existing internal orgs/sites have been deleted
       */
      CURSOR c_is_deleted_iso_orgs
      IS
      SELECT 1
         FROM dual
         WHERE EXISTS (SELECT sr_level_pk
                          FROM msd_level_values_ds
                          WHERE
                                 demand_plan_id = p_demand_plan_id
                             AND level_id = 11
                       MINUS
                       SELECT mloa.sr_level_pk
                          FROM msd_dp_iso_organizations mdio,
                               msd_level_org_asscns mloa
                          WHERE
                                 mdio.demand_plan_id = p_demand_plan_id
                             AND mloa.instance = mdio.sr_instance_id
                             AND mloa.level_id = 11
                             AND mloa.org_level_id    = 7
                             AND mloa.org_sr_level_pk = mdio.sr_organization_id);

      x_is_present     NUMBER := -1;

   BEGIN

      /* Check if any new internal orgs/sites have been added */
      OPEN  c_is_added_iso_orgs;
      FETCH c_is_added_iso_orgs INTO x_is_present;
      CLOSE c_is_added_iso_orgs;

      IF x_is_present = 1 THEN
         RETURN C_TRUE;
      END IF;

      x_is_present := -1;
      /* Check if any existing internal orgs/sites have been deleted */
      OPEN  c_is_deleted_iso_orgs;
      FETCH c_is_deleted_iso_orgs INTO x_is_present;
      CLOSE c_is_deleted_iso_orgs;

      IF x_is_present = 1 THEN
         RETURN C_TRUE;
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
         retcode := 2;
         errbuf := substr( sqlerrm, 1, 80);
         RETURN C_FALSE;

   END is_iso_orgs_changed;

End;

/
