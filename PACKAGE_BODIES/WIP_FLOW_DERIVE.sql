--------------------------------------------------------
--  DDL for Package Body WIP_FLOW_DERIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_FLOW_DERIVE" as
 /* $Header: wipwodfb.pls 120.1 2006/01/18 12:15:40 ksuleman noship $ */

/* *********************************************************************
			Public Procedures
***********************************************************************/


function class_code( p_class_code in out NOCOPY varchar2,
		     p_err_mesg in out NOCOPY varchar2,
		     p_org_id in number,
		     p_item_id in number,
		     p_wip_entity_type in number,
		     p_project_id in number) return number is
x_success number := 0;
x_err_code1 varchar2(30);
x_token1 varchar2(10);
x_err_code2 varchar2(30);
x_token2 varchar2(10);
begin

	if (p_class_code is null) then
		p_class_code := wip_common.default_acc_class(
         				X_ORG_ID    => p_org_id,
         				X_ITEM_ID   => p_item_id,
         				X_ENTITY_TYPE => p_wip_entity_type,
         				X_PROJECT_ID   => p_project_id,
         				X_ERR_MESG_1  => x_err_code1,
         				X_ERR_CLASS_1 => x_token1,
         				X_ERR_MESG_2  => x_err_code2,
         				X_ERR_CLASS_2 => x_token2
         			) ;

		if(p_class_code is null) then

			fnd_message.set_name('WIP',x_err_code1);
			fnd_message.set_token('CLASS_CODE',x_token1);
			p_err_mesg := fnd_message.get;
			return 0 ;
		end if;

	end if ;

	return 1;

    exception
     when others then
	return 0;

end class_code ;



function bom_revision(
			   p_bom_rev in out NOCOPY varchar2,
		           p_rev in out NOCOPY varchar2,
			   p_bom_rev_date in out NOCOPY date,
			   p_item_id in number,
			   p_start_date in date,
			   p_Org_id in number) return number is
x_success number := 0;
x_rev_exists number ;
x_bom_rev_exists number;
x_bom_rev varchar2(3);
begin

	/* Try to handle the corner case when the rev and Bom_rev
	   are not in Sync - That is done in the Validation
	   Routine */

	x_bom_rev := p_bom_rev ;


	x_bom_rev_exists := wip_common.bill_exists(
				p_item_id => p_item_id,
				p_org_id => p_org_id );

	if (x_bom_rev_exists = -1) then
	  /* SQLERROR occured in bill_exists routine */
	  raise PROGRAM_ERROR ;
	end if ;

	x_rev_exists := wip_common.revision_exists(
                                p_item_id => p_item_id,
                                p_org_id => p_org_id );

	if(x_rev_exists in (-1, -2)) then
	  /* SQLERROR or Application Error occured in
	     the revision_exists routine */
	  raise PROGRAM_ERROR ;
	end if ;

	/* This basically fetches you the revision for
	   the Item - doesnot worry about whether it is
	   a Bill or the Item			*/

	wip_revisions.bom_revision(
                  P_Organization_Id => p_org_id,
                  P_Item_Id => p_item_id,
                  P_Revision => x_bom_rev,
                  P_Revision_Date => p_bom_rev_date,
                  P_Start_Date => p_start_date );

	-- If revision exists
	if (x_rev_exists = 2) and (p_rev is null) then
	    p_rev := x_bom_rev  ;
	end if ;

	-- If the Bill exists
	if (x_bom_rev_exists = 1) and (p_bom_rev is null) then
	   p_bom_rev := x_bom_rev ;
	end if ;

	return 1;

        exception
           when others then
                   return 0;

end bom_revision ;



function routing_revision(  p_rout_rev in out NOCOPY varchar2,
			    p_rout_rev_date in out NOCOPY date,
			    p_item_id in number,
			    p_start_date in date,
                            p_Org_id in number) return number is
x_success number := 0;
x_rtg_exists number := 0;
begin

	x_rtg_exists := wip_common.routing_exists(
			   	p_item_id => p_item_id,
				p_org_id => p_org_id );

	if (x_rtg_exists >= 1 ) then

	        wip_revisions.Routing_Revision(
                        P_Organization_Id => p_org_id,
                        P_Item_Id => p_item_id,
                        P_Revision => p_rout_rev,
                        P_Revision_Date => p_rout_rev_date,
                        P_Start_Date => p_start_date );

	elsif(x_rtg_exists = -1) then
		/* SQLERROR from the routing_exists routine */
		raise PROGRAM_ERROR ;
	end if ;

	return 1;

     exception
	when others then
		return 0;

end routing_revision ;




function completion_sub(p_comp_sub in out NOCOPY varchar2,
                        p_item_id in number,
                        p_org_id in number,
		        p_alt_rtg_des in varchar2) return number is
x_success number := 0;
begin

	if p_comp_sub is null then

	     select BOR.COMPLETION_SUBINVENTORY
	     into   p_comp_sub
             from   BOM_OPERATIONAL_ROUTINGS BOR
             where  BOR.ORGANIZATION_ID = p_org_id
             and    BOR.ASSEMBLY_ITEM_ID = p_item_id
             and    NVL(BOR.ALTERNATE_ROUTING_DESIGNATOR,'@@@') =
                          NVL(p_alt_rtg_des, '@@@');

	end if;

	return 1;

  exception
       when no_data_found then
	return 1;  	-- This was not defined in the routing

       when others then
        return 0;

end completion_sub ;


/* Defaulting Routing Completion Locator Id */
function routing_completion_sub_loc(
                        p_rout_comp_sub in out NOCOPY varchar2,
                        p_rout_comp_loc in out NOCOPY number,
                        p_item_id in number,
                        p_org_id in number,
                        p_alt_rtg_des in varchar2) return number is
x_success number := 0;
begin


	if p_rout_comp_sub is null and p_rout_comp_loc is null  then

               select BOR.COMPLETION_SUBINVENTORY,
                      BOR.COMPLETION_LOCATOR_ID
               into   p_rout_comp_sub,
                      p_rout_comp_loc
               from   BOM_OPERATIONAL_ROUTINGS BOR
               where  BOR.ORGANIZATION_ID = p_org_id
               and    BOR.ASSEMBLY_ITEM_ID = p_item_id
               and    NVL(BOR.ALTERNATE_ROUTING_DESIGNATOR,'@@@') =
                            NVL(p_alt_rtg_des, '@@@') ;

	end if ;


   return 1 ;

   exception

      when no_data_found then
           return 1 ;

      when others then
           return 0 ;

end routing_completion_sub_loc ;

/* Defaulting completion locator id. In completion_loc, we only default locator id from
   the routing if p_proj_id is not null. I don't think we need that restriction. Also,
   p_txn_int_id is unneccessary. INV validation should derive the locator id from the
   segments provided. We only need to check the existence of locator id */
function completion_locator_id(p_comp_loc in out NOCOPY number,
                               p_item_id in number,
                               p_org_id in number,
                               p_alt_rtg_des in varchar2,
                               p_proj_id in number,
                               p_task_id in number,
                               p_comp_sub in varchar2) return number is
  l_success number := 0;
  l_comp_sub varchar2(10);
  general exception;
begin
  l_comp_sub := null;

  l_success := routing_completion_sub_loc(
                   p_rout_comp_sub => l_comp_sub,
                   p_rout_comp_loc => p_comp_loc,
                   p_item_id => p_item_id,
                   p_org_id => p_org_id,
                   p_alt_rtg_des => p_alt_rtg_des) ;

  if (l_success = 0) then
    raise general;
  end if;

  if (l_comp_sub <> p_comp_sub) then
    p_comp_loc := null ;
  end if ;

  if ((p_proj_id is not null) and
      (p_comp_sub is not null) and
      (p_comp_loc is not null)) then

    --The following piece of code that checks for dynamic
    --locator creation, will be replaced by call to pacifia's routine.

    if (pjm_project_locator.check_itemlocatorcontrol(
                        p_organization_id => p_org_id,
                        p_sub => p_comp_sub,
                        p_loc => p_comp_loc,
                        p_item_id => p_item_id,
                        p_hardpeg_only => 2 ) = TRUE ) then

      select count(*) into l_success
      from mtl_item_locations
      where inventory_location_id = p_comp_loc
      and organization_id = p_org_id
      and subinventory_code = p_comp_sub ;

      if (l_success = 1 ) then
        pjm_project_locator.Get_DefaultProjectLocator(
                        p_organization_id => p_org_id,
                        p_locator_id => p_comp_loc,
                        p_project_id => p_proj_id,
                        p_task_id => p_task_id,
                        p_project_locator_id => p_comp_loc ) ;
      end if ;
    end if ;
  end if ;

  return 1;

  exception
  when others then
    return 0;
end completion_locator_id;


function completion_loc(p_comp_loc in out NOCOPY number,
                        p_item_id in number,
                        p_org_id in number,
                        p_alt_rtg_des in varchar2,
			p_proj_id in number,
                        p_task_id in number,
			p_comp_sub in varchar2,
                        p_txn_int_id in number default null ) return number is
x_success number := 0;
x_comp_sub varchar2(10);
x_loc_seg_exists number := 0 ;
x_item_loc_control number := null ;
x_item_loc_restrict number := null ;
x_item_sub_restrict number := null ;
x_sub_loc_control number := null ;
x_org_loc_control number := null ;
general exception;
begin



        if (p_comp_loc is null) and (p_comp_sub is not null) and (p_proj_id is not null)  then

           if p_txn_int_id is not null then

                select count(*) into x_loc_seg_exists
                from mtl_transactions_interface
                where transaction_interface_id = p_txn_int_id
                and (  LOC_SEGMENT1 is not null
                       or LOC_SEGMENT2 is not null
                       or LOC_SEGMENT3 is not null
                       or LOC_SEGMENT4 is not null
                       or LOC_SEGMENT5 is not null
                       or LOC_SEGMENT6 is not null
                       or LOC_SEGMENT7 is not null
                       or LOC_SEGMENT8 is not null
                       or LOC_SEGMENT9 is not null
                       or LOC_SEGMENT10 is not null
                       or LOC_SEGMENT11 is not null
                       or LOC_SEGMENT12 is not null
                       or LOC_SEGMENT13 is not null
                       or LOC_SEGMENT14 is not null
                       or LOC_SEGMENT15 is not null
                       or LOC_SEGMENT16 is not null
                       or LOC_SEGMENT17 is not null
                       or LOC_SEGMENT18 is not null
                       or LOC_SEGMENT19 is not null
                       or LOC_SEGMENT20 is not null
                   ) ;

           end if;


           if (p_txn_int_id is null) or (x_loc_seg_exists = 0) then

	       x_success := routing_completion_sub_loc(
				p_rout_comp_sub => x_comp_sub,
                        	p_rout_comp_loc => p_comp_loc,
                        	p_item_id => p_item_id,
                        	p_org_id => p_org_id,
                        	p_alt_rtg_des => p_alt_rtg_des) ;

		if (x_success = 0) then
		 	raise general;
		end if;

	     	if x_comp_sub <> p_comp_sub then
		      p_comp_loc := null ;
	     	end if ;

	  end if ;

        end if;


        if (p_proj_id is not null) and (p_comp_sub is not null) and (p_comp_loc is not null) then

	/*****************************************************
	   The following piece of code that checks for dynamic
	   locator creation, will be replaced by call to
	   pacifia's routine.
	*****************************************************/

		if (pjm_project_locator.check_itemlocatorcontrol(
			p_organization_id => p_org_id,
			p_sub => p_comp_sub,
			p_loc => p_comp_loc,
			p_item_id => p_item_id,
			p_hardpeg_only => 2 ) = TRUE ) then

		     select count(*) into x_success
		     from mtl_item_locations
		     where inventory_location_id = p_comp_loc
		     and organization_id = p_org_id
		     and subinventory_code = p_comp_sub ;

		     if (x_success = 1 ) then

            		pjm_project_locator.Get_DefaultProjectLocator(
                  	p_organization_id => p_org_id,
                  	p_locator_id => p_comp_loc,
                  	p_project_id => p_proj_id,
                  	p_task_id => p_task_id,
                  	p_project_locator_id => p_comp_loc ) ;

		    end if ;

		end if ;


        end if ;

        return 1;

  exception

       when others then
        return 0;

end completion_loc ;



function schedule_group_id(p_sched_grp_id in out NOCOPY number) return number is
x_success number := 0;
begin

        return 1;

  exception
       when others then
        return 0;


end schedule_group_id ;



function build_sequence(p_build_seq in out NOCOPY number) return number is
x_success number := 0;
begin

        return 1;

  exception
       when others then
        return 0;


end build_sequence ;



function src_project_id(p_src_proj_id in out NOCOPY number,
			p_proj_id in out NOCOPY number) return number is
x_success number := 0;
begin

	if(p_src_proj_id is null) and (p_proj_id is not null) then
		p_src_proj_id := p_proj_id ;
	elsif (p_src_proj_id is not null) and (p_proj_id is null) then
		p_proj_id := p_src_proj_id ;
	end if ;

        return 1;

  exception
       when others then
        return 0;

end src_project_id ;


function src_task_id(p_src_task_id in out NOCOPY number,
		      p_task_id in out NOCOPY number) return number is
x_success number := 0;
begin


        if(p_src_task_id is null) and (p_task_id is not null) then
                p_src_task_id := p_task_id ;
        elsif (p_src_task_id is not null) and (p_task_id is null) then
                p_task_id := p_src_task_id ;
        end if ;

        return 1;

  exception
       when others then
        return 0;

end src_task_id ;



function schedule_number(p_sched_num in out NOCOPY varchar2) return number is
begin

        if(p_sched_num is null) then

                select WIP_JOB_NUMBER_S.nextval into p_sched_num
                from dual ;
                p_sched_num := substr(FND_PROFILE.value('WIP_JOB_PREFIX'),1,20)
                                     || p_sched_num ;

        end if ;

	return 1;

    exception
	when others then
	    return 0;
end schedule_number ;


function Last_Updated_Id(p_last_up_by_name in out NOCOPY varchar2,
			      p_last_up_id in out NOCOPY number) return number is
x_success number := 0;
BEGIN

	if (p_last_up_id is null) and (p_last_up_by_name is not null) then

	   select USER_ID
	   into p_last_up_id
	   from FND_USER
	   where USER_NAME = p_last_up_by_name ;

	elsif (p_last_up_id is not null) and (p_last_up_by_name is null) then

           select USER_NAME
           into p_last_up_by_name
           from FND_USER
           where USER_ID = p_last_up_id ;

	end if ;

	return 1;

  exception
       when others then
        return 0;

END Last_Updated_Id;

function Created_By_ID(p_created_by_name in out NOCOPY varchar2,
                              p_created_id in out NOCOPY number) return number is
x_success number := 0;
BEGIN

        if (p_created_id is null) and (p_created_by_name is not null) then

           select USER_ID
	   into p_created_id
           from FND_USER
           where USER_NAME = p_created_by_name ;

       elsif (p_created_id is not null) and (p_created_by_name is null) then

           select USER_NAME
           into p_created_by_name
           from FND_USER
           where USER_ID = p_created_id ;

        end if ;

        return 1;

  exception
       when others then
        return 0;

END Created_By_ID;



function Organization_Code(p_org_name in out NOCOPY varchar2,
                           p_org_id in out NOCOPY number) return number is
x_success number := 0;
BEGIN

	if (p_org_id is null) and (p_org_name is not null) then

	    select ORGANIZATION_ID
	    into p_org_id
	    --from ORG_ORGANIZATION_DEFINITIONS
            from mtl_parameters
	    where ORGANIZATION_CODE = p_org_name ;

	elsif (p_org_id is not null) and (p_org_name is null) then

            select ORGANIZATION_CODE
            into p_org_name
            --from ORG_ORGANIZATION_DEFINITIONS
            from mtl_parameters
            where ORGANIZATION_ID = p_org_id ;

	end if ;

        return 1;

  exception
       when others then
        return 0;



END Organization_Code;



/**********************************************************
* This particular function should be called only for      *
* Scheduled Flow Schedules as in the case of Unscheduled  *
* Flow Schedules we create a New Flow Schedule at runtime *
* and this does not make sense for them			  *
*							  *
*				- dsoosai 12/11/97	  *
**********************************************************/

function Transaction_Source_Name(
			p_txn_src_name in out NOCOPY varchar2,
                        p_txn_src_id in out NOCOPY number,
			p_Org_id in number) return number is

BEGIN


	if (p_txn_src_id is null) and (p_txn_src_name is not null) then

		select wip_entity_id
		into p_txn_src_id
		from wip_entities we
		where we.organization_id = p_org_id
		and we.wip_entity_name  = p_txn_src_name ;

	elsif (p_txn_src_id is not null) and (p_txn_src_name is null) then

                select wip_entity_name
                into p_txn_src_name
                from wip_entities we
                where we.organization_id = p_org_id
                and we.wip_entity_id  = p_txn_src_id ;

	end if ;

	return 1;

     exception
      when others then
	return 0 ;

END Transaction_Source_Name;



function Scheduled_Flow_Derivation(
			p_txn_action_id IN NUMBER,-- CFM Scrap
			p_item_id in number,
                        p_org_id in number,
                        p_txn_src_id in number,
                        p_sched_num in out NOCOPY varchar2,
                        p_src_proj_id in out NOCOPY number,
                        p_proj_id in out NOCOPY number,
                        p_src_task_id in out NOCOPY number,
                        p_task_id in out NOCOPY number,
                        p_bom_rev in out NOCOPY varchar2,
                        p_rev in out NOCOPY varchar2,
                        p_bom_rev_date  in out NOCOPY date,
                        p_rout_rev in out NOCOPY varchar2,
                        p_rout_rev_date in out NOCOPY date,
                        p_comp_sub in out NOCOPY varchar2,
                        p_class_code in out NOCOPY varchar2,
                        p_wip_entity_type in out NOCOPY number,
                        p_comp_loc in out NOCOPY number,
                        p_alt_rtg_des in out NOCOPY varchar2,
			p_alt_bom_des in out NOCOPY varchar2) return number is
x_success number := 0;
x_sched_cmp_date date;
begin

	select
		nvl(p_sched_num, schedule_number),
		nvl(p_src_proj_id,project_id),
		nvl(p_src_task_id,task_id),
		nvl(p_proj_id,project_id),
		nvl(p_task_id,task_id),
		nvl(p_bom_rev,bom_revision),
		nvl(p_bom_rev_date,bom_revision_date),
		nvl(p_rout_rev,routing_revision),
		nvl(p_rout_rev_date,routing_revision_date),
		Decode(p_txn_action_id, 30, NULL, nvl(p_comp_sub,completion_subinventory)),-- CFM Scrap
		nvl(p_class_code,class_code),
		nvl(p_wip_entity_type,4),  -- Work Order-less Completions
		-- fix bug#956467
		Decode(p_txn_action_id, 30, NULL,nvl(p_comp_loc,completion_locator_id)),-- CFM Scrap
		nvl(p_alt_rtg_des,alternate_routing_designator),
		nvl(p_alt_bom_des,alternate_bom_designator),
		scheduled_completion_date
	into
		p_sched_num,
		p_src_proj_id,
		p_src_task_id,
		p_proj_id,
		p_task_id,
		p_bom_rev,
		p_bom_rev_date,
		p_rout_rev,
		p_rout_rev_date,
		p_comp_sub,
		p_class_code,
		p_wip_entity_type,
		p_comp_loc,
		p_alt_rtg_des,
		p_alt_bom_des,
		x_sched_cmp_date
	from
		wip_flow_schedules
	where
		wip_entity_id = p_txn_src_id
		and organization_id = p_org_id ;


       x_success := 1 ;

       --if p_bom_rev is null then(fix bug#1032431)

	  x_success :=  bom_revision(
                           	p_bom_rev => p_bom_rev,
                           	p_rev => p_rev,
                           	p_bom_rev_date => p_bom_rev_date,
                           	p_item_id => p_item_id,
                           	p_start_date => x_sched_cmp_date,
                           	p_Org_id => p_org_id ) ;
       --end if ;


       if (p_rout_rev is null) and (x_success = 1) then

	  x_success :=  routing_revision(
				p_rout_rev => p_rout_rev,
                            	p_rout_rev_date => p_rout_rev_date,
                            	p_item_id => p_item_id,
                            	p_start_date => x_sched_cmp_date,
                            	p_Org_id => p_org_id ) ;

       end if;

/* The revision should be derived based on the transaction date, but for CFM the scheduled completion date has to be the same as the transaction date. We are using this fact here to derive the bill and routing revisions */

	return x_success;

     exception

	when others then
		return 0;

end Scheduled_Flow_Derivation ;




function Flow_Form_Defaulting(
	  p_txn_action_id IN NUMBER,-- CFM Scrap
          p_txn_type_id in number,
          p_item_id in number,
          p_org_id in number,
          p_start_date in date,
          p_alt_rtg_des in varchar2,
          p_bom_rev in out NOCOPY varchar2,
          p_rev in out NOCOPY varchar2,
          p_bom_rev_date in out NOCOPY date,
          p_rout_rev in out NOCOPY varchar2,
          p_rout_rev_date in out NOCOPY date,
          p_comp_sub in out NOCOPY varchar2,
          p_comp_loc in out NOCOPY number,
          p_proj_id in number,
          p_task_id in number) return number is

x_bom_ret number := 0 ;
x_rout_ret number := 0;
x_sub_ret number := 0;
x_loc_ret number := 0 ;

begin


        x_bom_ret := bom_revision (
                           p_bom_rev => p_bom_rev,
                           p_rev => p_rev,
                           p_bom_rev_date => p_bom_rev_date,
                           p_item_id => p_item_id,
                           p_start_date => p_start_date,
                           p_Org_id => p_org_id );



     x_rout_ret := routing_revision(
                                p_rout_rev => p_rout_rev,
                                p_rout_rev_date => p_rout_rev_date,
                                p_item_id => p_item_id,
                                p_start_date => p_start_date,
                                p_Org_id => p_org_id );



     IF (p_txn_action_id <> 30) then
	x_sub_ret := routing_completion_sub_loc(
                                p_rout_comp_sub => p_comp_sub,
                                p_rout_comp_loc => p_comp_loc,
                                p_item_id => p_item_id,
                                p_org_id => p_org_id,
                                p_alt_rtg_des => p_alt_rtg_des);



	x_loc_ret := Completion_loc(
                                p_comp_loc => p_comp_loc,
                                p_item_id => p_item_id,
                                p_org_id => p_org_id,
                                p_alt_rtg_des => p_alt_rtg_des,
                                p_proj_id => p_proj_id,
                                p_task_id => p_task_id,
                                p_comp_sub => p_comp_sub,
                    p_txn_int_id => null) ;
        /* for bug 3710003
           check if subinventory is inactive, if yes then make subinv and locator null
        */
           if p_comp_sub is not null then
             BEGIN
               select null,null           /*completion subinventory is inactive */
               into p_comp_sub,p_comp_loc
               from   mtl_secondary_inventories
               where  organization_id = p_org_id
               and    secondary_inventory_name = p_comp_sub
               and   (
                        NVL(disable_date, TRUNC(p_start_date)+1) <= TRUNC(p_start_date)
                              OR
                       /*Bug3784658. Consider material status */
                        wip_utilities.is_status_applicable(NULL,
                                                           p_txn_type_id,
                                                           NULL,
                                                           NULL,
                                                           p_org_id,
                                                           p_item_id,
                                                           p_comp_sub,
                                                           NULL,
                                                           NULL,
                                                           NULL,
                                                           'Z') = 'N');
               x_sub_ret := 1;
               x_loc_ret := 1;
             EXCEPTION
               when no_data_found then /*completion subinventory is active */
                 null;
             END;
           end if;

      ELSE
	x_sub_ret := 1;
	x_loc_ret := 1;
     END IF;

     return  (x_bom_ret * x_rout_ret * x_sub_ret * x_loc_ret) ;

    exception

       when others then
          return 0 ;

End Flow_Form_Defaulting ;





End Wip_Flow_Derive ;

/
