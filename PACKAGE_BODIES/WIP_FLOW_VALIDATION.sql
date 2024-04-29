--------------------------------------------------------
--  DDL for Package Body WIP_FLOW_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_FLOW_VALIDATION" as
 /* $Header: wipwovlb.pls 120.2.12010000.2 2009/10/06 06:41:23 adasa ship $ */

/* *********************************************************************
			Public Procedures
***********************************************************************/

/* Is it a valid Buildable Item */
function primary_item_id(p_rowid in rowid) return number is
x_success number := 0;
x_see_eng_item number := 2;     --Default to not an engineering item
BEGIN


        begin
          x_see_eng_item := to_number(fnd_profile.value('WIP_SEE_ENG_ITEMS'));

        exception
          when others then
             x_see_eng_item := 2;    --Default to not an engineering item
        end ;


	select 1 into x_success
	from mtl_transactions_interface mti
	where rowid = p_rowid
	and exists (
		select 1
		from mtl_system_items msi
		where msi.inventory_item_id = mti.inventory_item_id
        	and   msi.organization_id = mti.organization_id
        	and   msi.build_in_wip_flag = 'Y'
        	and   msi.pick_components_flag = 'N'
                and   eng_item_flag = decode( x_see_eng_item,
                                        1, eng_item_flag,
                                        'N') );

	return x_success ;

   exception
	when others then
		return 0;

end primary_item_id ;


function class_code( p_rowid in rowid) return number is
x_success number := 0;
begin


	select 1 into x_success
	from mtl_transactions_interface mti
        where mti.rowid = p_rowid
	and mti.accounting_class is not null
        and (  ( mti.source_project_id is null
	         and exists (
                		select 'class is valid'
		                from cst_cg_wip_acct_classes_v cwac
		                where cwac.class_code = mti.accounting_class
				and   cwac.organization_id = mti.organization_id
				and   cwac.class_type = 1
			      )
		)
	     or( mti.source_project_id is not null
	         and exists (
                		select 'class is valid'
		                from cst_cg_wip_acct_classes_v cwac,
				     mrp_project_parameters mpp, mtl_parameters mp
		                where cwac.class_code = mti.accounting_class
				and   cwac.class_type = 1
				and   mpp.project_id = mti.source_project_id
				and   mpp.organization_id = mti.organization_id
				and   mpp.organization_id = mp.organization_id
				and   cwac.cost_group_id = decode(mp.primary_cost_method,1,-1,mpp.costing_group_id)
				and   cwac.organization_id = mti.organization_id
			      )
		)
	     );

	return x_success ;

  exception
    when others then
	return 0;

end class_code ;



function bom_revision(p_rowid in rowid) return number is
x_success number := 0;
x_bom_rev varchar2(3);
x_rev varchar2(3);
x_rev_exists number ;
x_bom_rev_exists number;
x_item_id number ;
x_org_id number;
begin


        begin

		select 	inventory_item_id,
			organization_id,
			revision,
			bom_revision
		into    x_item_id,
			x_org_id,
			x_rev,
			x_bom_rev
		from 	mtl_transactions_interface
		where 	rowid = p_rowid ;

	   exception
		when no_data_found then
			null ;
	 end ;



        x_bom_rev_exists := wip_common.bill_exists(
                                p_item_id => x_item_id,
                                p_org_id => x_org_id );

	if (x_bom_rev_exists = -1) then
	  /* SQLERROR occured in bill_exists routine */
	  raise PROGRAM_ERROR ;
	end if ;


        x_rev_exists := wip_common.revision_exists(
                                p_item_id => x_item_id,
                                p_org_id => x_org_id );

	if(x_rev_exists in (-1, -2)) then
	  /* SQLERROR or Application Error occured in
	     the revision_exists routine */
	  raise PROGRAM_ERROR ;
	end if ;


	if (x_rev_exists in (1, 2) ) then

	/*********************************************
	   This is done already in inltwv.ppc, should be
	   cleaned up for R12
	 **********************************************/

		select 1 into x_success
        	from mtl_transactions_interface mti,
	     	mtl_system_items msi
        	where mti.rowid = p_rowid
		and   msi.inventory_item_id = mti.inventory_item_id
		and   msi.organization_id = mti.organization_id
		and (   (
		  	msi.revision_qty_control_code = 2
	          	and exists
			       	(
					select 1
					from  mtl_item_revisions mir
         				where mir.organization_id = mti.organization_id
           				and   mir.inventory_item_id = mti.inventory_item_id
           				and   mir.revision = mti.revision
			       	)
			)
	     	or
			(
		  	msi.revision_qty_control_code = 1
		  	and mti.revision is null
			)
	    	);

	end if ;


	if (x_bom_rev_exists in (1, 0) ) and (x_success = 1 ) then

                select 1 into x_success
                from mtl_transactions_interface mti,
                mtl_system_items msi
                where mti.rowid = p_rowid
                and   msi.inventory_item_id = mti.inventory_item_id
                and   msi.organization_id = mti.organization_id
                and (   (
			x_bom_rev_exists = 1
                        and exists
                                (
                                        select 1
                                        from  mtl_item_revisions mir
                                        where mir.organization_id = mti.organization_id
                                        and   mir.inventory_item_id = mti.inventory_item_id
                                        and   mir.revision = mti.bom_revision
                                )
                        )
                or
                        (
			x_bom_rev_exists = 0
                        and mti.bom_revision is null
                        )
                );

	end if ;


	/*************************************************
	 Make sure that if both the revision as well as
	 the Bom revision are populated, then they should
	 be the same as both of them are based out of the
	 same table MTL_ITEM_REVISIONS.
	**************************************************/

	if (x_bom_rev is not null) and (x_rev is not null)
	   and (x_success =1 ) then

		/* The revision and the bom revision are not sync, so
		   they will fail */
		if (x_bom_rev <> x_rev) then
			x_success := 0 ;
		end if ;

	end if;

	return x_success;

  exception
    when others then

	return 0;


end bom_revision ;


function routing_revision(p_rowid in rowid) return number is
x_success number := 0;
x_rtg_exists number := 0;
x_item_id number ;
x_org_id number;
x_txn_date DATE;
begin

        begin

                select  inventory_item_id,
                        organization_id,
                        transaction_date
                into    x_item_id,
                        x_org_id,
                        x_txn_date
                from    mtl_transactions_interface
                where   rowid = p_rowid ;

           exception
                when no_data_found then
                        null ;
         end ;


        x_rtg_exists := wip_common.routing_exists(
                                p_item_id => x_item_id,
                                p_org_id => x_org_id,
                                p_eff_date => x_txn_date );


	if ( x_rtg_exists >=0 ) then

	        select 1 into x_success
       		from	mtl_transactions_interface mti,
			mtl_system_items msi
        	where	mti.rowid = p_rowid
			and msi.inventory_item_id = mti.inventory_item_id
			and msi.organization_id = mti.organization_id
			and ( (x_rtg_exists >= 1
			       and exists (
                                	select	1
					   from	mtl_rtg_item_revisions mrir
                                	where	mrir.organization_id = mti.organization_id
						and mrir.inventory_item_id = mti.inventory_item_id
					        and mrir.process_revision = mti.routing_revision
					        and mrir.implementation_date is not null
                               	)
                	      )
			      or
			      (
				x_rtg_exists = 0
				and mti.routing_revision is null
                	      )
            	            );

	elsif (  x_rtg_exists = -1 ) then
	   /* SQLERROR in routing_exists routine */
	   raise PROGRAM_ERROR ;

	end if ;

	return x_success;

  exception
    when others then
	return 0;

end routing_revision;



function bom_rev_date(p_rowid in rowid) return number is
x_success number := 0;
x_bom_rev varchar2(3);
x_bom_rev_date date ;
x_org_id number;
x_item_id number;
x_check_rev varchar2(3);
x_bom_exists NUMBER;
x_released_revs_type	NUMBER;
x_released_revs_meaning Varchar2(30);

begin


       begin

	       select 	bom_revision,
	      		bom_revision_date,
	      		organization_id,
	      		inventory_item_id
       		into   	x_bom_rev,
	      		x_bom_rev_date,
	      		x_org_id,
	      		x_item_id
       		from 	mtl_transactions_interface
       		where 	rowid = p_rowid ;


	   exception
		when no_data_found then
			null ;

	end ;


        x_bom_exists := wip_common.bill_exists(
                                p_item_id => x_item_id,
                                p_org_id => x_org_id );

        IF (x_bom_exists = -1) then
          /* SQLERROR occured in bill_exists routine */
           raise PROGRAM_ERROR ;

         ELSIF (x_bom_exists = 0) THEN
           x_success := 1;

         ELSE
        /* 3033785 */
         wip_common.Get_Released_Revs_Type_Meaning (x_released_revs_type,
                                                    x_released_revs_meaning
                                                   );
	  BOM_REVISIONS.Get_Revision
          (type => 'PART',
           eco_status => x_released_revs_meaning,
           examine_type => 'ALL',
           org_id => x_Org_Id,
           item_id => x_item_id,
           rev_date => x_bom_rev_date,
           itm_rev =>x_check_rev);

	  if((x_bom_rev is null) or (x_check_rev = x_bom_rev)) then
	     x_success := 1;
	   else
	     x_success := 0 ;
	  end if ;

	END IF;

	return x_success;

  exception
    when others then
	return 0;

end bom_rev_date ;


function rout_rev_date(p_rowid in rowid) return number is
x_success number := 0;
x_rtg_rev varchar2(3);
x_rtg_rev_date date ;
x_org_id number;
x_item_id number;
x_txn_date DATE;
x_check_rev varchar2(3);
x_rtg_exists number := 0;
x_released_revs_type	NUMBER;
x_released_revs_meaning	Varchar2(30);

begin



	begin

       		select 	routing_revision,
	      		routing_revision_date,
	      		organization_id,
	      		inventory_item_id,
                        transaction_date
       		into   	x_rtg_rev,
	      		x_rtg_rev_date,
	      		x_org_id,
	      		x_item_id,
                        x_txn_date
       		from 	mtl_transactions_interface
       		where 	rowid = p_rowid ;


	      exception

		 when others then
			null ;

	end ;

        x_rtg_exists := wip_common.routing_exists(
                                p_item_id => x_item_id,
                                p_org_id => x_org_id,
                                p_eff_date => x_txn_date );


       if (x_rtg_exists = 1) then
          /* 3033785 */
          wip_common.Get_Released_Revs_Type_Meaning (x_released_revs_type,
                                                     x_released_revs_meaning
                                                    );
           BOM_REVISIONS.Get_Revision
               (type => 'PROCESS',
               	eco_status => x_released_revs_meaning,
               	examine_type => 'ALL',
               	org_id => x_Org_Id,
               	item_id => x_item_id,
               	rev_date => x_rtg_rev_date,
           	itm_rev =>x_check_rev);

      	   if(x_check_rev = x_rtg_rev) then
		x_success := 1;
      	   else
		x_success := 0 ;
      	   end if ;

       elsif (x_rtg_exists = 0 ) then

	   if(x_rtg_rev_date is null and x_rtg_rev is null ) then
		x_success := 1;
	   else
		x_success := 0;
	   end if ;

       elsif (x_rtg_exists = -1 ) then
	  /* SQLERROR in  routing exists routine */
	  raise PROGRAM_ERROR ;

       end if ;

       return x_success;


  exception
    when others then
	return 0;

end rout_rev_date;


function alt_bom_desg(p_rowid in rowid) return number is
x_success number := 0;
begin

	/* we look at only manufacturing bill */
	select 1 into x_success
	from mtl_transactions_interface mti
	where rowid = p_rowid
	and ( (alternate_bom_designator is null)
	      or (alternate_bom_designator is not null
		  and exists (
			select 1
			from bom_bill_alternates_v bba
                  	where bba.alternate_bom_designator =
                            mti.alternate_bom_designator
                    	and bba.organization_id = mti.organization_id
                     /* and bba.assembly_type = 1 */ /*changed condition to include engineering BOMs also as WOL transactions are currently supported for primary routings and erroring for alt routings due to this validation */
                        and bba.assembly_type in (1,2)
                    	and bba.assembly_item_id = mti.inventory_item_id)));

	return x_success ;

  exception
    when others then
	return 0;

end alt_bom_desg ;


function alt_rout_desg(p_rowid in rowid) return number is
x_success number := 0;
begin
	/* we look at only manufacturing routing */
        select 1 into x_success
        from mtl_transactions_interface mti
        where rowid = p_rowid
        and ( (alternate_routing_designator is null)
              or (alternate_routing_designator is not null
                  and exists (
                        select 1
                        from bom_routing_alternates_v bra
                        where bra.alternate_routing_designator =
                            mti.alternate_routing_designator
                        and bra.organization_id = mti.organization_id
                      /*and bra.routing_type = 1 *//*changed condition to include engineering routings also as WOL transactions are currently supported for primary routings and erroring for alt routings due to this validation*/
                        and bra.routing_type in (1,2)
                        and bra.assembly_item_id = mti.inventory_item_id)));

        return x_success ;


  exception
    when others then
        return 0;

end alt_rout_desg ;


function completion_sub(p_rowid in rowid) return number is
x_success number := 0;
x_subinv_code VARCHAR2(30);
x_txn_action NUMBER;
begin

	/******************************************************
	   Validation whether the subinventory is under locator
	   control and if so whether it the correct locator is
	   done as a part of inventory validation in inltev.ppc
	*******************************************************/

	SELECT subinventory_code, transaction_action_id  -- CFM Scrap Section
	INTO x_subinv_code, x_txn_action
	FROM mtl_transactions_interface mti
	WHERE ROWID = p_rowid;

	IF x_txn_action = 30 THEN
	   IF x_subinv_code IS NULL THEN
	     RETURN 1;
	    ELSE
	      RETURN 0;
	   END IF;
	END IF;				-- CFM Scrap Section End


	select 1 into x_success
        from mtl_transactions_interface mti
        where rowid = p_rowid
        and subinventory_code is not null
	and exists (
                       (
			select 1
                  	from mtl_system_items msi
                  	where mti.inventory_item_id = msi.inventory_item_id
                  	and   mti.organization_id = msi.organization_id
                  	and   msi.restrict_subinventories_code = 2
		       )
	     	     union (
		  	select 1
		  	from mtl_system_items msi, mtl_item_sub_val_v msvv
                  	where mti.inventory_item_id = msi.inventory_item_id
                  	and   mti.organization_id = msi.organization_id
                  	and   msi.restrict_subinventories_code = 1
                  	and   msi.inventory_asset_flag = 'N'
		  	and   msvv.organization_id =  mti.organization_id
                  	and   msvv.inventory_item_id = mti.inventory_item_id
                  	and   msvv.secondary_inventory_name =
                	mti.subinventory_code
		       )
	     	     union (
                  	select 1
                  	from mtl_system_items msi, mtl_item_sub_ast_trk_val_v msvv
                  	where mti.inventory_item_id = msi.inventory_item_id
                  	and   mti.organization_id = msi.organization_id
                  	and   msi.restrict_subinventories_code = 1
                  	and   msi.inventory_asset_flag = 'Y'
                  	and   msvv.organization_id =  mti.organization_id
                  	and   msvv.inventory_item_id = mti.inventory_item_id
                  	and   msvv.secondary_inventory_name =
                        mti.subinventory_code
		       )
		    );

        return x_success ;

  exception
    when others then
        return 0;

end completion_sub ;


function completion_locator_id(p_rowid in rowid) return number is
x_success number := 0;
x_proj_ref_exists number := 0 ;
x_loc_id NUMBER;
x_txn_action NUMBER;
begin


	/************************************************
	   Simple validation for the Sub Inventory
	   and the Completion Locator. For Project related
	   Locator validation, we do the validation only if
	   the locator id is specified. However if the locator
	   segments are specified, we leave it up to the
	   inventory validation to handle it (inltev.ppc).
	************************************************/


	SELECT locator_id, transaction_action_id  -- CFM Scrap Section
	INTO x_loc_id, x_txn_action
	FROM mtl_transactions_interface mti
	WHERE ROWID = p_rowid;

	IF x_txn_action = 30 THEN
	   IF x_loc_id IS NULL THEN
	     RETURN 1;
	    ELSE
	      RETURN 0;
	   END IF;
	END IF;				-- CFM Scrap Section End

        select 1 into x_success
        from mtl_transactions_interface mti
        where mti.rowid = p_rowid
	and mti.subinventory_code is not null
        and (   ( mti.locator_id is not null
		  and exists
			    (
			     select 1
			     from mtl_item_locations mil
			     where mil.inventory_location_id =
                                   mti.locator_id
			     and   mil.subinventory_code =
				   mti.subinventory_code
                     	     and   mil.organization_id =
				   mti.organization_id
			    )
		)
	      or
		(
		 locator_id is null
		)
	    );


	select count(*) into x_proj_ref_exists
        from mtl_transactions_interface mti
        where mti.rowid = p_rowid
        and source_project_id is not null ;

	if (x_proj_ref_exists = 1 ) then

	   select 1 into x_success
	   from mtl_transactions_interface mti,
	 	mtl_item_locations mil
	   where mti.rowid = p_rowid
	   and (    (   mti.locator_id is not null
			and mil.inventory_location_id = mti.locator_id
	   		and   mil.organization_id = mti.organization_id
	   		and   mil.segment19 = mti.source_project_id
			AND   nvl(mil.segment20, -1)
				= nvl(mti.source_task_id , -1)
		    )
		or ( 	mti.locator_id is null
                        and mti.organization_id = mil.organization_id --fix for 4896646
		     	and ( 	mil.segment1 is not null
			      	or mil.segment2 is not null
				or mil.segment3 is not null
				or mil.segment4 is not null
                                or mil.segment5 is not null
                                or mil.segment6 is not null
                                or mil.segment7 is not null
                                or mil.segment8 is not null
                                or mil.segment9 is not null
                                or mil.segment10 is not null
                                or mil.segment11 is not null
                                or mil.segment12 is not null
                                or mil.segment13 is not null
                                or mil.segment14 is not null
                                or mil.segment15 is not null
                                or mil.segment16 is not null
                                or mil.segment17 is not null
                                or mil.segment18 is not null
                                or mil.segment19 is not null
                                or mil.segment20 is not null
			    )
		   )
	     ) ;


       end if ;

        return x_success ;

  exception
    when others then
        return 0;

end completion_locator_id ;



function demand_class(p_rowid in rowid) return number is
x_success number := 0;
begin


        select 1 into x_success
        from mtl_transactions_interface mti
        where rowid = p_rowid
        and (   ( demand_class is not null
		  and exists
             		  (
			   select 1
              		   from so_demand_classes_active_v sdca
              		   where sdca.demand_class_code = mti.demand_class
			  )
	         )
	       or
		 (
		   demand_class is null
		 )
	     );

        return x_success ;

  exception
    when others then
        return 0;

end demand_class ;


function schedule_group_id(p_rowid in rowid) return number is
x_success number := 0;
begin


	/***********************************************
	   We don't have the creation of schedule group
	   for Automotive right now. But it may be added
	   in R11 +, discussed it with mmodi and jgu
	   and decided that it is not a business
	   requirement
	************************************************/

        select 1 into x_success
        from  mtl_transactions_interface mti
        where rowid = p_rowid
        and (  ( schedule_group is not null
        	 and   exists
                	( select 1
                  	  from wip_schedule_groups_val_v wsg
                  	  where wsg.schedule_group_id = mti.schedule_group
                  	  and wsg.organization_id = mti.organization_id
		        )
		)
	     or (
		 schedule_group is null
		)
	    ) ;

        return x_success ;

  exception
    when others then
        return 0;

end schedule_group_id ;



function build_sequence(p_rowid in rowid) return number is
x_success number := 0;
x_build_sequence NUMBER;
x_wip_entity_id NUMBER;
x_organization_id NUMBER;
x_line_id NUMBER;
x_schedule_group_id NUMBER;
begin


	  SELECT
	  mti.build_sequence,
	  mti.transaction_source_id,
	  mti.organization_id,
	  mti.repetitive_line_id,
	  mti.schedule_group
	  INTO
	  x_build_sequence,
	  x_wip_entity_id,
	  x_organization_id,
	  x_line_id,
	  x_schedule_group_id
	  FROM mtl_transactions_interface mti
	  WHERE rowid = p_rowid;

	  IF WIP_Validate.build_sequence(p_build_sequence    => x_build_sequence,
					 p_wip_entity_id     => x_wip_entity_id,
					 p_organization_id   => x_organization_id,
					 p_line_id           => x_line_id,
					 p_schedule_group_id => x_schedule_group_id)
	    THEN
	     x_success := 1;
	   ELSE
	     x_success := 0;
	  END IF;


        return x_success ;

  exception
    when others then
        return 0;

end build_sequence ;


function line_id(p_rowid in rowid) return number is
x_success number := 0;
begin

        select 1 into x_success
        from mtl_transactions_interface mti
        where rowid = p_rowid
        and (  ( repetitive_line_id is not null
                 and exists
                      (
			select 1
              		from wip_lines_val_v wl
              		where wl.line_id = mti.repetitive_line_id
              		and wl.organization_id = mti.organization_id
		      )
	       )
	     or(
		repetitive_line_id is null
	       )
	    );

        return x_success ;


  exception
    when others then
        return 0;

end line_id ;


function project_id(p_rowid in rowid) return number is
x_success number := 0;
l_org_id number;
begin
        -- fix MOAC, set id so project view works
        select organization_id into l_org_id
          from mtl_transactions_interface
         where rowid = p_rowid;
        fnd_profile.put('MFG_ORGANIZATION_ID', l_org_id);

	/*******************************************************
	  We can have non project related flow schedules in a project
	  enabled organization.
	  For Project Related Flow Schedules the Locator Validation
	  is done in inltev.ppc.
	*********************************************************/

        select 1 into x_success
        from mtl_transactions_interface mti
        where rowid = p_rowid
	and ( ( source_project_id is not null
	        and exists (
				select 1
				from mtl_parameters mps
                  		where nvl(mps.project_reference_enabled,2) = 1
                        	and   mps.organization_id = mti.organization_id
		       	   )
		and exists (
                     		select 1
                        	from mtl_project_v mp
                       		where mp.project_id = mti.project_id
		   	    )
	        )
	      or( source_project_id is null )
	     ) ;

       return x_success ;

  exception
    when others then
        return 0;

end project_id ;


function task_id(p_rowid in rowid) return number is
x_success number := 0;
begin



	/* ****************************************************
	   The logic for task validation in a simple condition
	   statement :

		If Org is task enabled
		    If Project not null
			if task is null
				Error ;
			else
				Check it in pa_tasks_expend_v;
			end if;
		   else
			if task is null ;
				success ;
			else
				Error ;
			end if;

		   end if;

		else

		    Success ;
		end if;
	***************************************************/

     select 1 into x_success
     from mtl_transactions_interface mti,
     mtl_parameters mps
     where mti.rowid = p_rowid
     and  mps.organization_id = mti.organization_id
     and  (  ( nvl(mps.project_control_level,1) = 2
               and (  ( mti.source_project_id is not null
                        and mti.source_task_id is not null
                        and exists (
                                     select 1
                                     from pa_tasks_expend_v pt
                                     where pt.project_id = mti.source_project_id
                                     and   pt.task_id = mti.source_task_id
                                   )
                       )
                    or ( mti.source_project_id is null
                         and mti.source_task_id is null
                       )
                   )
              )
            or( nvl(mps.project_control_level,1) = 1 )
          );

       return x_success ;

  exception
    when others then
        return 0;

end task_id ;



/* This is not mti column but a wfs column */
function status(p_status in number) return number is
x_success number := 0;
begin

	select 1 into x_success
        from dual
        where p_status in (
	  	select lookup_code
		from mfg_lookups
		where lookup_type = 'WIP_FLOW_SCHEDULE_STATUS');

       return x_success ;

  exception
    when others then
        return 0;

end status ;


function schedule_number(p_rowid in rowid) return number is
x_success number := 0;
begin

	/**************************************************
	   As we are inserting the flow schedules one after
	   the other into wip_flow_schedules, we don't have
	   to check for duplicate schedule_number in MTI
	   itself as this will error out by itself
	***************************************************/


         select 1 into x_success
         from mtl_transactions_interface mti
	 where mti.rowid = p_rowid
	 and((mti.scheduled_flag <> 1
	      and not exists(
		 select 'exists'
                 from wip_entities
		 where wip_entity_name = mti.schedule_number))
	     or(mti.scheduled_flag = 1
                and exists(
                  select 'exists'
                  from wip_entities
                  where wip_entity_id = mti.transaction_source_id)));

       return x_success ;


  exception
    when others then
        return 0;

end schedule_number ;

function schedule_number(p_schedule_number in varchar2) return number is
x_success number := 0;
begin

        /**************************************************
           As we are inserting the flow schedules one after
           the other into wip_flow_schedules, we don't have
           to check for duplicate schedule_number in MTI
           itself as this will error out by itself
        ***************************************************/

         select 1 into x_success
         from sys.dual
         where not exists(
                 select 'exists'
                 from wip_entities
                 where wip_entity_name = p_schedule_number );


       return x_success ;

  exception
    when others then
        return 0;

end schedule_number ;

function scheduled_flag(p_rowid in rowid) return number is
x_success number := 0;
begin


        select 1 into x_success
        from mtl_transactions_interface mti
	where  rowid = p_rowid
	and mti.scheduled_flag in (
                select lookup_code
                from mfg_lookups
                where lookup_type = 'SYS_YES_NO');

       return x_success ;


  exception
    when others then
        return 0;



end scheduled_flag ;

/*****************************************************************************
* Unit Number Validation:
*  There are two checks performed in this function:
*  1. Check to see that if a unit number is not provided then either there is
*     no unit number control OR the assembly is not under unit number control.
*  2. Check to see that if a unit number is provided, the organization is
*     enabled for model unit effectivity
*     AND the assembly is a unit effective item
*     AND that the unit number exists in the master org of the current organization
*     AND in the case of scheduled flow schedules the unit number provided matches
*         the unit number in wip_flow_schedules.
******************************************************************************/

function unit_number(p_rowid in rowid) return number is
x_success number := 0;
begin

   SELECT 1
     INTO x_success
     FROM mtl_transactions_interface mti
     WHERE rowid = p_rowid
     AND ((end_item_unit_number IS NULL
	   AND (pjm_unit_eff.enabled = 'N'
		OR pjm_unit_eff.unit_effective_item(mti.inventory_item_id,mti.organization_id) = 'N'))
	  OR (end_item_unit_number IS NOT NULL
	      AND (pjm_unit_eff.enabled = 'Y'
		   AND pjm_unit_eff.unit_effective_item(mti.inventory_item_id,mti.organization_id) = 'Y'
		   AND end_item_unit_number IN (SELECT unit_number
						FROM pjm_unit_numbers_lov_v N, mtl_parameters P
						WHERE P.organization_id = mti.organization_id and
						P.master_organization_id = N.master_organization_id)
		   AND (mti.scheduled_flag <> 1
			OR exists (SELECT 1
				   FROM wip_flow_schedules wfs
				   WHERE wfs.wip_entity_id = mti.transaction_source_id
				   AND wfs.end_item_unit_number = mti.end_item_unit_number
			       )))));

	      return x_success ;


  exception
    when others then
        return 0;



end unit_number;


End Wip_Flow_Validation ;

/
