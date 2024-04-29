--------------------------------------------------------
--  DDL for Package Body WIP_FLOW_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_FLOW_UTILITIES" as
/* $Header: wipfcomb.pls 120.2 2006/04/27 17:25:35 yulin noship $ */

/* *********************************************************************
			Public Procedures
***********************************************************************/
wip_line_ops BOM_RTG_Network_API.Op_Tbl_Type;


Procedure Update_Completion_UOM(p_item_id in number, p_org_id in number,
				p_txn_qty in number, p_txn_uom in varchar2,
				p_pri_qty in out nocopy number) is
   x_primary_uom VARCHAR2(3);
BEGIN


        Select PRIMARY_UOM_CODE INTO x_primary_uom
        FROM   mtl_system_items
        WHERE  inventory_item_Id = p_item_id
               AND organization_Id = p_org_id;

        -- Call the Inventory Conversion Routine to get the Quantity
        -- in the Original UOM, if the Primary Uom and the transaction
        -- uom are not the same
        if (x_primary_uom <> p_txn_uom ) then

            p_pri_qty := inv_convert.inv_um_convert(
                                item_id => p_item_id,
                                precision => NULL,
                                from_quantity => p_txn_qty,
                                from_unit => p_txn_uom,
                                to_unit => x_primary_uom,
                                from_name => NULL,
                                to_name => NULL ) ;

        else

            p_pri_qty := p_txn_qty ;


        end if;


end Update_Completion_UOM ;




function Subs_Check(
                        p_parent_id in number,
                        p_organization_id in number,
                        p_err_num in out nocopy number,
                        p_err_mesg in out nocopy varchar2
                          ) return number is

/********************************************
*   Cursor for Substitutions
*********************************************/
CURSOR Substitute_Cursor(p_parent_id NUMBER,
                         P_organization_id NUMBER) is
        Select
                INVENTORY_ITEM_ID,
                SUBSTITUTION_ITEM_ID,
                SUBSTITUTION_TYPE_ID,
                OPERATION_SEQ_NUM,
		FLOW_SCHEDULE
        from Mtl_transactions_interface
        where parent_id = p_parent_id
        and   substitution_type_id is not null
        and   process_flag = 2
        and   organization_id = p_organization_Id ;

x_error   VARCHAR2(240);
x_message VARCHAR2(240);
x_success number := 0;
x_see_eng_item number := 2; -- default it to not a eng item
x_parent_op_seq NUMBER;
x_rout_rev_date DATE;
x_rout_seq_id NUMBER;
begin


        -- Get the WIP profile for the whole section
        begin
                x_see_eng_item := to_number(fnd_profile.value('WIP_SEE_ENG_ITEMS'));

          exception
           when others then
                x_see_eng_item := 2;    --Default to not an engineering item

        end ;

        select operation_seq_num
          into x_parent_op_seq
          from mtl_transactions_interface
         where transaction_interface_id = p_parent_id;

      begin
	SELECT mti.routing_revision_date, bor.routing_sequence_id 	-- CFM Scrap
	  INTO x_rout_rev_date, x_rout_seq_id
	  FROM mtl_transactions_interface mti, bom_operational_routings bor
	  WHERE mti.transaction_interface_id = p_parent_id
	  AND mti.inventory_item_id = bor.assembly_item_id(+)
	  AND mti.organization_id = bor.organization_id(+)
	  AND Nvl(mti.alternate_routing_designator,'@@@@') = Nvl(bor.alternate_routing_designator,'@@@@');
     exception
       when others then
         x_rout_rev_date := null;
         x_rout_seq_id := null;
     end;

        For sub_rec in Substitute_Cursor(p_parent_id, p_organization_id) LOOP


                x_success := 0;
                select 1 into x_success
                from sys.dual
                where Sub_Rec.substitution_type_id in (
                        select lookup_code from mfg_lookups
                        where lookup_type = 'WIP_SUBSTITUTION_TYPE') ;

                if (x_success = 0) then


                        fnd_message.set_name('WIP', 'WIP_ERROR_SUBST_TYPE');
                        fnd_message.set_token('ENTITY1',
                                        to_char(sub_rec.operation_seq_num) );
                        p_err_mesg := fnd_message.get ;
                        return 0;

                end if ;

                --
                -- We will fail it only if it is 'N', if it is NULL, we will
                -- derive it later in Post_SubsMerge
                --

                if( UPPER(NVL(Sub_Rec.flow_schedule,'Y')) = 'N' ) then
                        fnd_message.set_name('WIP', 'WIP_FLOW_FLAG_ERROR');
                        p_err_mesg := fnd_message.get ;
                        return 0;
		end if;

                x_success := 0;		-- CFM Scrap
		IF x_parent_op_seq IS NOT NULL AND
                   x_rout_seq_id is not null and
		  sub_rec.substitution_type_id <> 3 AND
		  event_in_same_or_prior_lineop(x_rout_seq_id,
						x_rout_rev_date,
						Sub_Rec.operation_seq_num,
						x_parent_op_seq,
						'N') <> 1 THEN
		   fnd_message.set_name('WIP', 'WIP_INVALID_COMP_OP_SEQ');
		   p_err_mesg := fnd_message.get ;
		   RETURN 0;
		END IF;


                if (Sub_Rec.substitution_type_id <> 3) then

			x_success := 0;
                        select 1 into x_success
                        from mtl_system_items
                        where organization_id = p_organization_id
                        and inventory_item_id = Sub_Rec.inventory_item_id
                        and mtl_transactions_enabled_flag = 'Y'
                        and inventory_item_flag = 'Y'
			and bom_enabled_flag = 'Y'
			and eng_item_flag = decode(x_see_eng_item,
						1, eng_item_flag,
						'N')
                        and bom_item_type = 4 ; -- Standard Type
                        if (x_success = 0) then


                                fnd_message.set_name('WIP', 'WIP_ERROR_SUBST_ASSEMBLY');
                                x_error := 'Original Item Id' ||to_char(Sub_Rec.inventory_item_id)
                                                || ' at OP Seq :'
                                                || to_char(sub_rec.operation_seq_num) || '.' ;
                                fnd_message.set_token('ENTITY1', x_error);
                                fnd_message.set_token('ENTITY2', 'Original Component');
                                p_err_mesg := fnd_message.get ;
                                return 0;

                        end if ;
                end if ;

                if (Sub_Rec.substitution_type_id in(1,3) ) then

			x_success := 0;
                        select 1 into x_success
                        from mtl_system_items
                        where organization_id = p_organization_id
                        and inventory_item_id = Sub_Rec.substitution_item_id
                        and mtl_transactions_enabled_flag = 'Y'
                        and inventory_item_flag = 'Y'
			and bom_enabled_flag = 'Y'
			and eng_item_flag = decode(x_see_eng_item,
						1, eng_item_flag,
						'N')
                        and sub_rec.substitution_type_id in (1,3)
                        and bom_item_type = 4 ; -- Standard Type

                        if (x_success = 0) then


                         fnd_message.set_name('WIP', 'WIP_ERROR_SUBST_ASSEMBLY');
                         x_error := 'Substitution Item Id' ||to_char(Sub_Rec.substitution_item_id)
                                         || ' at OP Seq :'
                                         || to_char(sub_rec.operation_seq_num) || '.' ;
                         fnd_message.set_token('ENTITY1', x_error);
                         fnd_message.set_token('ENTITY2', 'Substitute Component');
                         p_err_mesg := fnd_message.get ;
                         return 0;

                        end if ;
                end if ;

        END LOOP ;

        return 1;

        exception

         when others then

		/**********************************************************************
		* The Error Message in this case is handled by the calling wilctv.ppc *
		***********************************************************************/

                return 0;

end Subs_Check ;





function Derive_Completion(
                        p_org_id in out nocopy number,
                        p_txn_src_name in out nocopy varchar2,
                        p_txn_src_id in out nocopy number,
                        p_sched_num in out nocopy varchar2,
                        p_src_proj_id in out nocopy number,
                        p_proj_id in out nocopy number,
                        p_src_task_id in out nocopy number,
                        p_task_id in out nocopy number,
                        p_bom_rev in out nocopy varchar2,
                        p_rev in out nocopy varchar2,
                        p_bom_rev_date  in out nocopy date,
                        p_rout_rev in out nocopy varchar2,
                        p_rout_rev_date in out nocopy date,
                        p_comp_sub in out nocopy varchar2,
                        p_class_code in out nocopy varchar2,
                        p_wip_entity_type in out nocopy number,
                        p_comp_loc in out nocopy number,
                        p_alt_rtg_des in out nocopy varchar2,
                        p_alt_bom_des in out nocopy varchar2,
                        p_scheduled_flag in out nocopy number,
                        p_transaction_date in out nocopy date,
                        p_item_id in out nocopy number,
                        p_txn_int_id in out nocopy number,
                        p_txn_action_id IN NUMBER		 -- CFM Scrap
  ) return number is
x_err_mesg varchar2(240);
begin


    if (p_scheduled_flag <> 1) then

    /****************************************************************
    * Removed the call for defaulting the Transaction Source Id and *
    * Transaction Source Name as it doesnot make sense to call in   *
    * the Unscheduled Case, as we will not have a Wip_Entity exist  *
    * ing already - as we create a New WIP Entity Id at runtime     *
    * 					- dsoosai 11/12/97	    *
    ****************************************************************/

        if(
             (Wip_Flow_Derive.schedule_number(
                                p_sched_num => p_sched_num) = 0 )

             or (Wip_Flow_Derive.src_project_id(
                                p_src_proj_id => p_src_proj_id,
                                p_proj_id => p_proj_id) = 0 )

             or (Wip_Flow_Derive.src_task_id(
                                p_src_task_id => p_src_task_id,
                                p_task_id => p_task_id) = 0)

             or (Wip_Flow_Derive.bom_revision(
                                p_bom_rev => p_bom_rev,
                                p_rev => p_rev,
                                p_bom_rev_date   => p_bom_rev_date,
                                p_item_id => p_item_id,
                                p_start_date => p_transaction_date,
                                p_Org_id => p_Org_id) = 0 )

             or (Wip_Flow_Derive.routing_revision(
                                p_rout_rev => p_rout_rev,
                                p_rout_rev_date   => p_rout_rev_date,
                                p_item_id => p_item_id,
                                p_start_date => p_transaction_date,
                                p_Org_id => p_Org_id) = 0 )

             or (p_txn_action_id <> 30 AND			 -- CFM Scrap
		 Wip_Flow_Derive.completion_sub(p_comp_sub => p_comp_sub,
                                p_item_id  => p_item_id,
                                p_org_id => p_org_id,
                                p_alt_rtg_des => p_alt_rtg_des) = 0 )

             or (Wip_Flow_Derive.class_code(
                                p_class_code =>p_class_code,
                                p_err_mesg => x_err_mesg,
                                p_org_id => p_org_id,
                                p_item_id => p_item_id,
                                p_wip_entity_type => p_wip_entity_type,
                                p_project_id => p_src_proj_id) = 0 )

             or (p_txn_action_id <> 30 AND			 -- CFM Scrap
		 Wip_Flow_Derive.completion_loc(p_comp_loc => p_comp_loc,
                                p_item_id => p_item_id,
                                p_org_id => p_org_id,
                                p_alt_rtg_des => p_alt_rtg_des,
                                p_proj_id => p_src_proj_id,
                                p_task_id => p_src_task_id,
				p_comp_sub => p_comp_sub,
                                p_txn_int_id => p_txn_int_id) = 0 )
           ) then

                -- This is failure
                return 0 ;
        end if ;

    elsif (p_scheduled_flag = 1) then

        if (

                (Wip_Flow_Derive.Transaction_Source_Name(
                                 p_txn_src_name => p_txn_src_name,
                                 p_txn_src_id => p_txn_src_id,
                                 p_org_id => p_org_id) = 0 )

             or (Wip_Flow_Derive.Scheduled_Flow_Derivation(
				p_txn_action_id => p_txn_action_id,-- CFM Scrap
				p_item_id => p_item_id,
                                p_org_id => p_org_id,
                                p_txn_src_id => p_txn_src_id,
                                p_sched_num => p_sched_num,
                                p_src_proj_id => p_src_proj_id,
                                p_proj_id => p_proj_id,
                                p_src_task_id => p_src_task_id,
                                p_task_id => p_task_id,
                                p_bom_rev => p_bom_rev,
                                p_rev => p_rev,
                                p_bom_rev_date  => p_bom_rev_date,
                                p_rout_rev => p_rout_rev,
                                p_rout_rev_date => p_rout_rev_date,
                                p_comp_sub => p_comp_sub,
                                p_class_code => p_class_code,
                                p_wip_entity_type => p_wip_entity_type,
                                p_comp_loc => p_comp_loc,
                                p_alt_rtg_des => p_alt_rtg_des,
                                p_alt_bom_des => p_alt_bom_des) = 0 )
             ) then

                return 0;

        end if ;

     end if ;

     return 1;

   exception
    when others then
        return 0;


end Derive_Completion ;




function Validate_Completion(
                        p_rowid in rowid,
                        p_item_id in number,
                        p_schedule_number in out nocopy varchar2,
                        p_organization_id in number,
                        p_class_code in varchar2,
                        p_scheduled_flag in number,
                        p_txn_src_id in number,
                        p_see_eng_item in number) return number is
x_success number := 0;
x_message varchar2(240);
begin



        if (p_scheduled_flag = 1) then

           begin

                /* We don't have to validate on the
                   status type, as the schedule has to
                   be open */

		select 1 into x_success
                from wip_flow_schedules wfs,
                     mtl_transactions_interface mti
                where wfs.wip_entity_id = p_txn_src_id
                and   wfs.organization_id = p_organization_id
                and   trunc(wfs.scheduled_completion_date,WIP_CONSTANTS.DATE_FMT) =
                      trunc(mti.transaction_date,WIP_CONSTANTS.DATE_FMT)
                and   mti.rowid = p_rowid;


                exception
                  when others then
                        -- It is closed
                        return 0 ;
           end ;

        end if ;

	/* Notes :
	   1. The messages are being set in this routine because the actual validation routines may be called by planning.
	   2. I am reusing the "ML" messages instead of creating new ones because the message text fits this validation also.
	*/

        IF     (Wip_Flow_Validation.primary_item_id(p_rowid => p_rowid) = 0 ) THEN
	   fnd_message.set_name('WIP', 'WIP_CANNOT_BUILD_ITEM');

	 ELSIF (Wip_Flow_Validation.class_code(p_rowid => p_rowid) = 0 ) THEN
	   fnd_message.set_name('WIP', 'WIP_INTERFACE_INVALID_CLASS');

	 ELSIF (Wip_Flow_Validation.bom_rev_date(p_rowid => p_rowid) = 0 ) THEN
 	   fnd_message.set_name('WIP', 'WIP_INVALID_BOM_REVISION_DATE');

	 ELSIF (Wip_Flow_Validation.bom_revision(p_rowid => p_rowid) = 0 ) THEN
 	   fnd_message.set_name('WIP', 'WIP_INVALID_BOM_REVISION');

	 ELSIF (Wip_Flow_Validation.rout_rev_date(p_rowid => p_rowid) = 0 ) THEN
  	   fnd_message.set_name('WIP', 'WIP_INVALID_ROUT_REVISION_DATE');

	 ELSIF (Wip_Flow_Validation.routing_revision(p_rowid => p_rowid) = 0 ) THEN
  	   fnd_message.set_name('WIP', 'WIP_INVALID_ROUT_REVISION');

	 ELSIF (Wip_Flow_Validation.alt_bom_desg(p_rowid => p_rowid) = 0 ) THEN
  	   fnd_message.set_name('WIP', 'WIP_ML_ALTERNATE_BOM');

	 ELSIF (Wip_Flow_Validation.alt_rout_desg(p_rowid => p_rowid) = 0 ) THEN
 	   fnd_message.set_name('WIP', 'WIP_ML_ALTERNATE_ROUTING');

	 ELSIF (Wip_Flow_Validation.completion_sub(p_rowid => p_rowid) = 0 ) THEN
  	   fnd_message.set_name('WIP', 'WIP_INVALID_COMPLETION_SUB');

	 ELSIF (Wip_Flow_Validation.completion_locator_id(p_rowid => p_rowid) = 0 ) THEN
  	   fnd_message.set_name('WIP', 'WIP_INVALID_LOCATOR');

	 ELSIF (Wip_Flow_Validation.demand_class(p_rowid => p_rowid) = 0 ) THEN
  	   fnd_message.set_name('WIP', 'WIP_ML_DEMAND_CLASS');

	 ELSIF (Wip_Flow_Validation.schedule_group_id(p_rowid => p_rowid) = 0 ) THEN
  	   fnd_message.set_name('WIP', 'WIP_ML_SCHEDULE_GROUP');

	 ELSIF (Wip_Flow_Validation.build_sequence(p_rowid => p_rowid) = 0 ) THEN
  	   fnd_message.set_name('WIP', 'WIP_BUILD_SEQUENCE');

	 ELSIF (Wip_Flow_Validation.line_id(p_rowid => p_rowid) = 0 ) THEN
  	   fnd_message.set_name('WIP', 'WIP_ML_LINE_ID');

	 ELSIF (Wip_Flow_Validation.project_id(p_rowid => p_rowid) = 0 ) THEN
  	   fnd_message.set_name('WIP', 'WIP_INVALID_PROJECT');

	 ELSIF (Wip_Flow_Validation.task_id(p_rowid => p_rowid) = 0 ) THEN
  	   fnd_message.set_name('WIP', 'WIP_INVALID_TASK');

	 ELSIF (Wip_Flow_Validation.schedule_number(p_rowid => p_rowid) = 0 ) THEN
  	   fnd_message.set_name('WIP', 'WIP_INVALID_SCHEDULE_NUMBER');

	 ELSIF (Wip_Flow_Validation.scheduled_flag(p_rowid => p_rowid) = 0 ) THEN
  	   fnd_message.set_name('WIP', 'WIP_INVALID_SCHEDULED_FLAG');

	 ELSIF (Wip_Flow_Validation.unit_number(p_rowid => p_rowid) = 0 ) THEN
	   fnd_message.set_name('WIP', 'UEFF-UNIT NUMBER INVALID');

	 ELSE
	   RETURN 1;
	END IF;

	-- This is failure

	x_message := fnd_message.get ;

	UPDATE MTL_TRANSACTIONS_INTERFACE MTI
	  SET     LAST_UPDATE_DATE = SYSDATE,
	  PROGRAM_UPDATE_DATE = SYSDATE,
	  PROCESS_FLAG = 3,
	  LOCK_FLAG = 2,
	  ERROR_CODE = NULL,
	  ERROR_EXPLANATION = x_message
	  WHERE rowid = p_rowid ;


	return 0 ;

  exception
        when others then

                fnd_message.set_name('WIP', 'WIP_ERROR_FLOW_VALIDATION');
		fnd_message.set_token('ENTITY1', p_schedule_number);
                x_message := fnd_message.get ;

                UPDATE MTL_TRANSACTIONS_INTERFACE MTI
                SET     LAST_UPDATE_DATE = SYSDATE,
                        PROGRAM_UPDATE_DATE = SYSDATE,
                        PROCESS_FLAG = 3,
                        LOCK_FLAG = 2,
                        ERROR_CODE = NULL,
                        ERROR_EXPLANATION = x_message
                WHERE rowid = p_rowid ;

                return 0;

end Validate_Completion ;



function Revision_Generation(
                                p_interface_id in number,
                                p_err_num in out nocopy number,
                                p_err_mesg in out nocopy varchar2) return number is
begin


    UPDATE mtl_transactions_interface MTI
       SET LAST_UPDATE_DATE = SYSDATE,
           PROGRAM_UPDATE_DATE = SYSDATE,
           REVISION =
            (SELECT NVL(mti.revision, MAX(mir.revision))
             FROM mtl_item_revisions mir
             WHERE mir.organization_id = mti.organization_id
             AND mir.inventory_item_id = mti.inventory_item_id
             AND mir.effectivity_date <=
                        mti.transaction_date
             AND mir.effectivity_date =
              (SELECT MAX(mir2.effectivity_date)
               FROM mtl_item_revisions mir2
               WHERE mir2.organization_id = mti.organization_id
               AND mir2.inventory_item_id = mti.inventory_item_id
               AND mir2.effectivity_date <=
                        mti.transaction_date
                        ))
     WHERE
       	   PARENT_ID = p_interface_id
       AND TRANSACTION_SOURCE_TYPE_ID = 5
       AND FLOW_SCHEDULE = 'Y'
       AND TRANSACTION_ACTION_ID IN (1,27,33,34)
       AND PROCESS_FLAG = 2
       AND REVISION IS NULL
       AND EXISTS (
       SELECT 'X'
       FROM MTL_SYSTEM_ITEMS msi
       WHERE msi.ORGANIZATION_ID = mti.ORGANIZATION_ID
       AND msi.inventory_item_id = mti.inventory_item_id
       AND msi.revision_qty_control_code = 2);

	return 1 ;

exception

 when others then

        /**********************************************************************
        * The Error Message in this case is handled by the calling wilctv.ppc *
        ***********************************************************************/

	return 0;

end Revision_Generation ;





/* Generate the issue locators for all the issues associated with a completion
   This would be called only for a project related completions*/
function Generate_Issue_Locator_Id(
                                p_parent_id in number,
                                p_organization_id in number,
				p_src_prj_id in number,
				p_src_tsk_id in number,
				p_wip_entity_id in number,
                                p_err_num in out nocopy number,
                                p_err_mesg in out nocopy varchar2) return number is
x_project_id number;
x_task_id number;
x_wip_entity_id number;
x_org_id number;
x_success number := 1 ;

begin

  /*******************************************************
  *  The cursor for going through the Material Issues in *
  *  this program is not required as this is being done  *
  *  in the PJM_Project_Locator.Get_Flow_ProjectSupply in*
  *  PJMLOCB.pls - this is the fix required for Bug# :   *
  *  598471						 *
  *				- dsoosai 12/11/97	 *
  *******************************************************/

  /*******************************************************
  *  The actual cursor for going through each one of the *
  *  Material Issue that is associated with Completion   *
  *  is done in the PJM_Project_Locator routine	  	 *
  *******************************************************/

  PJM_Project_Locator.Get_Flow_ProjectSupply(
	p_organization_id => p_organization_id,
	p_wip_entity_id => p_wip_entity_id,
	p_project_id => p_src_prj_id,
	p_task_id => p_src_tsk_id,
	p_parent_id => p_parent_id,
	p_success => x_success );

  if (x_success = 0) then
	return x_success ;
  end if;

  return x_success ;

exception

	when others then

        /**********************************************************************
        * The Error Message in this case is handled by the calling wilctv.ppc *
        ***********************************************************************/
	return 0 ;

end Generate_Issue_Locator_Id ;


procedure Create_Flow_Schedules( p_header_id in number) is

/* **********************************************
        Cursor to get all the Flow Completions
   ********************************************** */
   CURSOR Flow_Completion (header_id number) is
   SELECT
       transaction_interface_id,
       transaction_action_id,					 -- CFM Scrap
       organization_id,
       last_update_date,
       last_updated_by,
       creation_date,
       created_by,
       last_update_login,
       request_id,
       program_application_id,
       program_id,
       program_update_date,
       inventory_item_id,
       accounting_class,
       transaction_date,
       transaction_quantity,   -- we have to convert it to primary qty
       transaction_uom,
       primary_quantity,
       transaction_source_id,
       transaction_source_name,
       revision,
       bom_revision,
       routing_revision,
       bom_revision_date,
       routing_revision_date,
       alternate_bom_designator,
       alternate_routing_designator,
       subinventory_code,
       locator_id,
       demand_class,
       schedule_group,
       build_sequence,
       repetitive_line_id,
       source_project_id,
       project_id,
       source_task_id,
       task_id,
       schedule_number,
       scheduled_flag,
       wip_entity_type,
       end_item_unit_number,
       rowid
   FROM   mtl_transactions_interface
   WHERE  transaction_header_id = header_id
       	  AND TRANSACTION_SOURCE_TYPE_ID = 5
       	  AND FLOW_SCHEDULE = 'Y'
	  AND transaction_action_id in (31, 32, 30)  -- CFM Scrap
	  AND scheduled_flag in (1, 2, 3) -- Unscheduled from form and interface
	  AND process_flag = 1;

x_message	varchar2(240);

x_sql_err_num number;
x_sql_message varchar2(240);
x_material_account number;
x_material_overhead_account number;
x_resource_account number;
x_outside_processing_account number;
x_material_variance_account number;
x_resource_variance_account number;
x_outside_proc_var_account number;
x_std_cost_adjustment_account number;
x_overhead_account number;
x_overhead_variance_account number ;
x_see_eng_item number := 2;	--Default to not an engineering item
x_wip_entity_id number;
x_success number := 0;
general	exception;
begin

	-- Get the WIP profile for the whole section
	begin
		x_see_eng_item := to_number(fnd_profile.value('WIP_SEE_ENG_ITEMS'));

	  exception
	   when others then
		x_see_eng_item := 2;	--Default to not an engineering item

	end ;



	FOR flow_rec in Flow_Completion(p_header_id) LOOP

	BEGIN

	  x_success := 0;

	  /* we do the defaulting for scheduled, Unscheduled and for the
		 records coming from the Form, the derive completions
	     procedure differenciates between the various cases and
	     performs actions accordingly */

           flow_rec.wip_entity_type := 4 ; -- Set it to Flow Schedule

	   IF((flow_rec.transaction_source_id is not null)
             and (flow_rec.scheduled_flag = 2)) THEN
              -- Reset these for resubmission records.
              flow_rec.transaction_source_id := null;
              flow_rec.transaction_source_name := null;
              flow_rec.schedule_number := null;
           end if;

           if(
               derive_completion(
                        p_org_id => flow_rec.organization_id,
                        p_txn_src_name => flow_rec.transaction_source_name,
                        p_txn_src_id => flow_rec.transaction_source_id,
                        p_sched_num => flow_rec.schedule_number,
                        p_src_proj_id => flow_rec.source_project_id,
                        p_proj_id => flow_rec.project_id,
                        p_src_task_id => flow_rec.source_task_id,
                        p_task_id => flow_rec.task_id,
                        p_bom_rev => flow_rec.bom_revision,
                        p_rev => flow_rec.revision,
                        p_bom_rev_date  => flow_rec.bom_revision_date,
                        p_rout_rev => flow_rec.routing_revision,
                        p_rout_rev_date => flow_rec.routing_revision_date,
                        p_comp_sub => flow_rec.subinventory_code,
                        p_class_code => flow_rec.accounting_class,
                        p_wip_entity_type => flow_rec.wip_entity_type,
                        p_comp_loc => flow_rec.locator_id,
			p_alt_rtg_des => flow_rec.alternate_routing_designator,
                        p_alt_bom_des => flow_rec.alternate_bom_designator,
                        p_scheduled_flag => flow_rec.scheduled_flag,
                        p_transaction_date => flow_rec.transaction_date,
                        p_item_id => flow_rec.inventory_item_id,
                        p_txn_int_id => flow_rec.transaction_interface_id,
	                p_txn_action_id => flow_rec.transaction_action_id -- CFM Scrap
                ) = 1) then

                   Update Mtl_Transactions_Interface
		   Set
			transaction_source_id = flow_rec.transaction_source_id,
			schedule_number = flow_rec.schedule_number,
			source_project_id = flow_rec.source_project_id,
			project_id = flow_rec.project_id,
			source_task_id = flow_rec.source_task_id,
			task_id = flow_rec.task_id,
			bom_revision = flow_rec.bom_revision,
			revision = flow_rec.revision,
			bom_revision_date = flow_rec.bom_revision_date,
			routing_revision = flow_rec.routing_revision,
			routing_revision_date = flow_rec.routing_revision_date,
			subinventory_code = flow_rec.subinventory_code,
			accounting_class = flow_rec.accounting_class,
			wip_entity_type = flow_rec.wip_entity_type,
			locator_id = flow_rec.locator_id
		    Where
			rowid = flow_rec.rowid ;

		else

                	fnd_message.set_name('WIP', 'WIP_ERROR_FLOW_DEFAULTING');
                	fnd_message.set_token('ENTITY1',to_char(flow_rec.transaction_interface_id));

                	x_message := fnd_message.get ;

                	UPDATE MTL_TRANSACTIONS_INTERFACE MTI
                	SET     LAST_UPDATE_DATE = SYSDATE,
                       	 	PROGRAM_UPDATE_DATE = SYSDATE,
                        	PROCESS_FLAG = 3,
                        	LOCK_FLAG = 2,
                        	ERROR_CODE = NULL,
                        	ERROR_EXPLANATION = x_message
                		WHERE rowid = flow_rec.rowid ;


               end if ;


	 If  (flow_rec.transaction_source_id is null)
	     and (flow_rec.scheduled_flag<> 1) then


	   -- This will convert the Completion UOM to the corresponding primary
	   -- UOM. Note : you have to convert the column types in the record
	   -- to the corresponding values inorder to make the function call
	   -- correctly
	   Update_Completion_UOM(
			p_item_id => flow_rec.inventory_item_id,
                        p_org_id =>  flow_rec.organization_id,
			p_txn_qty => flow_rec.transaction_quantity,
                        p_txn_uom => flow_rec.transaction_uom,
			p_pri_qty => flow_rec.primary_quantity);


		/* We do the validation and completion only for interface
		   records */
		If (flow_rec.scheduled_flag =2) then

		    x_success := Validate_Completion(
				p_rowid => flow_rec.rowid,
			        p_item_id => flow_rec.inventory_item_id,
				p_schedule_number => flow_rec.schedule_number,
				p_organization_id => flow_rec.organization_id,
                        	p_class_code => flow_rec.accounting_class,
                        	p_scheduled_flag => flow_rec.scheduled_flag,
                        	p_txn_src_id => flow_rec.transaction_source_id,
                        	p_see_eng_item => x_see_eng_item);


		elsif (flow_rec.scheduled_flag = 3) then

		    if (wip_flow_validation.schedule_number(
					p_rowid => flow_rec.rowid ) = 0 ) then

		       fnd_message.set_name('WIP', 'WIP_INVALID_SCHEDULE_NUMBER');

		       x_message := fnd_message.get ;

		       UPDATE MTL_TRANSACTIONS_INTERFACE MTI
			 SET     LAST_UPDATE_DATE = SYSDATE,
			 PROGRAM_UPDATE_DATE = SYSDATE,
			 PROCESS_FLAG = 3,
			 LOCK_FLAG = 2,
			 ERROR_CODE = NULL,
			 ERROR_EXPLANATION = x_message
			 WHERE rowid = flow_rec.rowid ;


		    end if ;

		End if ;

		/* We enter this section only if the scheduled_flag = 3 or if it
		   passed all the validation for scheduled_flag = 2 */
		Select wip_entities_s.nextval into x_wip_entity_id
		from dual ;

		x_success := Create_Flow_Schedule(
			x_wip_entity_id,
                        flow_rec.organization_id,
                        flow_rec.last_update_date,
                        flow_rec.last_updated_by,
                        flow_rec.creation_date,
                        flow_rec.created_by,
                        flow_rec.last_update_login,
                        flow_rec.request_id,
                        flow_rec.program_application_id,
                        flow_rec.program_id,
                        flow_rec.program_update_date,
                        flow_rec.inventory_item_id,
                        flow_rec.accounting_class,
                        flow_rec.transaction_date,
                        NULL,
                        0,
                        0,              -- We have to insert it as the primary_quantity
		        0,					 -- CFM Scrap
                        NULL,
                        NULL,
                        flow_rec.bom_revision,
                        flow_rec.routing_revision,
                        flow_rec.bom_revision_date,
                        flow_rec.routing_revision_date,
                        flow_rec.alternate_bom_designator,
                        flow_rec.alternate_routing_designator,
                        flow_rec.subinventory_code,
                        flow_rec.locator_id,    -- actually this will be validated by INV proc
                        flow_rec.demand_class,
                        flow_rec.transaction_date,
                        flow_rec.schedule_group,
                        flow_rec.build_sequence,
                        flow_rec.repetitive_line_id,
                        flow_rec.project_id,
                        flow_rec.task_id,
                        1,                      -- 1. Open, 2. Close
                        flow_rec.schedule_number,
                        2,			-- Unscheduled
		        flow_rec.end_item_unit_number,	-- end item unit number
			NULL,
			NULL, NULL, NULL, NULL, NULL,
                        NULL, NULL, NULL, NULL, NULL,
                        NULL, NULL, NULL, NULL, NULL );


		if(x_success = 0) then
			raise general ;
		end if;

		Update Mtl_transactions_interface
		set transaction_source_id = wip_entities_s.currval,
		    scheduled_flag = 2,		-- No
		    schedule_number = flow_rec.schedule_number,
		    primary_quantity = flow_rec.primary_quantity
		where rowid = flow_rec.rowid ;


	  elsif (flow_rec.transaction_source_id is not null)
                 and (flow_rec.scheduled_flag = 1) then

               x_success := Validate_Completion(
                                p_rowid => flow_rec.rowid,
                                p_item_id => flow_rec.inventory_item_id,
                                p_schedule_number => flow_rec.schedule_number,
                                p_organization_id => flow_rec.organization_id,
                                p_class_code => flow_rec.accounting_class,
                                p_scheduled_flag => flow_rec.scheduled_flag,
                                p_txn_src_id => flow_rec.transaction_source_id,
                                p_see_eng_item => x_see_eng_item);

	  else

		raise general ;

	  End if ;

       	  exception

            when others then
                -- Error creating the wip flow schedule
                fnd_message.set_name('WIP', 'WIP_ERROR_FLOW_CREATION');
                fnd_message.set_token('ENTITY1',to_char(flow_rec.transaction_interface_id));

                x_message := fnd_message.get ;
		x_sql_err_num := SQLCODE;
		x_sql_message := substr(SQLERRM,1,240);

                UPDATE MTL_TRANSACTIONS_INTERFACE MTI
                SET     LAST_UPDATE_DATE = SYSDATE,
                        PROGRAM_UPDATE_DATE = SYSDATE,
                        PROCESS_FLAG = 3,
                        LOCK_FLAG = 2,
                        ERROR_CODE = x_message,
                        ERROR_EXPLANATION = decode(x_sql_err_num,0,NULL,x_sql_message)
                WHERE rowid = flow_rec.rowid ;


	 END ;
	END LOOP ;


    exception

	when others then

                -- Error creating the wip flow schedules
                fnd_message.set_name('WIP', 'WIP_ERROR_FLOW_CREATION');
                fnd_message.set_token('ENTITY1',to_char(p_header_id));
                x_message := fnd_message.get ;

		x_sql_err_num := SQLCODE;
                x_sql_message := substr(SQLERRM,1,240);


		UPDATE MTL_TRANSACTIONS_INTERFACE MTI
                SET     LAST_UPDATE_DATE = SYSDATE,
                        PROGRAM_UPDATE_DATE = SYSDATE,
                        PROCESS_FLAG = 3,
                        LOCK_FLAG = 2,
                        ERROR_CODE = x_message,
                        ERROR_EXPLANATION = decode(x_sql_err_num,0,NULL,x_sql_message)
                WHERE 	transaction_header_id = p_header_id
		and 	transaction_source_type_id = 5
		and 	transaction_action_id in (31, 32, 30);	 -- CFM Scrap

end Create_Flow_Schedules ;



/* Whenever we call this all the class accounts should be
   a snapshot of the class code at that particular time,
   before calling this they should have validated the
   class code */
function Create_Flow_Schedule(
                        p_wip_entity_id in number,
                        p_organization_id in number,
                        p_last_update_date in date,
                        p_last_updated_by in number,
                        p_creation_date in date,
                        p_created_by in number,
                        p_last_update_login in number,
                        p_request_id in number,
                        p_program_application_id in number,
                        p_program_id in number,
                        p_program_update_date in date,
                        p_primary_item_id in number,
                        p_class_code in varchar2,
                        p_scheduled_start_date in date,
                        p_date_closed in date,
                        p_planned_quantity in number,
                        p_quantity_completed in number,
			p_quantity_scrapped in number,	 -- CFM Scrap
                        p_mps_sched_comp_date in date,
                        p_mps_net_quantity in number,
                        p_bom_revision in varchar2,
                        p_routing_revision in varchar2,
                        p_bom_revision_date in date,
                        p_routing_revision_date in date,
                        p_alternate_bom_designator in varchar2,
                        p_alternate_routing_designator in varchar2,
                        p_completion_subinventory in varchar2,
                        p_completion_locator_id in number,
                        p_demand_class in varchar2,
                        p_scheduled_completion_date in date,
                        p_schedule_group_id in number,
                        p_build_sequence in number,
                        p_line_id in number,
                        p_project_id in number,
                        p_task_id in number,
                        p_status in number,
                        p_schedule_number in varchar2,
                        p_scheduled_flag in number,
                        p_unit_number IN VARCHAR2,
 			p_attribute_category in varchar2,
 			p_attribute1 in varchar2,
 			p_attribute2 in varchar2,
 			p_attribute3 in varchar2,
 			p_attribute4 in varchar2,
 			p_attribute5 in varchar2,
 			p_attribute6 in varchar2,
 			p_attribute7 in varchar2,
 			p_attribute8 in varchar2,
 			p_attribute9 in varchar2,
 			p_attribute10 in varchar2,
 			p_attribute11 in varchar2,
 			p_attribute12 in varchar2,
 			p_attribute13 in varchar2,
 			p_attribute14 in varchar2,
 			p_attribute15 in varchar2 ) return number is
x_material_account number;
x_material_overhead_account number;
x_resource_account number;
x_outside_processing_account number;
x_material_variance_account number;
x_resource_variance_account number;
x_outside_proc_var_account number;
x_std_cost_adjustment_account number;
x_overhead_account number;
x_overhead_variance_account number ;

begin


		/* Get the snapshot of the account class */
                select  material_account,
                        material_overhead_account,
                        resource_account,
                        outside_processing_account,
                        material_variance_account,
                        resource_variance_account,
                        outside_proc_variance_account,
                        std_cost_adjustment_account,
                        overhead_account,
                        overhead_variance_account
                into
			x_material_account,
			x_material_overhead_account,
			x_resource_account,
			x_outside_processing_account,
			x_material_variance_account,
			x_resource_variance_account,
			x_outside_proc_var_account,
			x_std_cost_adjustment_account,
			x_overhead_account,
			x_overhead_variance_account
                from
                        wip_accounting_classes
                where
                        class_code = p_class_code
                and     organization_id = p_organization_id;


		/* Create the New Flow Schedule */
		Insert into wip_flow_schedules(
 			WIP_ENTITY_ID,
 			ORGANIZATION_ID,
 			LAST_UPDATE_DATE,
 			LAST_UPDATED_BY,
 			CREATION_DATE,
 			CREATED_BY,
 			LAST_UPDATE_LOGIN,
 			REQUEST_ID,
 			PROGRAM_APPLICATION_ID,
 			PROGRAM_ID,
 			PROGRAM_UPDATE_DATE,
 			PRIMARY_ITEM_ID,
 			CLASS_CODE,
 			SCHEDULED_START_DATE,
 			DATE_CLOSED,
 			PLANNED_QUANTITY,
 			QUANTITY_COMPLETED,
			QUANTITY_SCRAPPED,			 -- CFM Scrap
 			MPS_SCHEDULED_COMPLETION_DATE,
 			MPS_NET_QUANTITY,
 			BOM_REVISION,
 			ROUTING_REVISION,
 			BOM_REVISION_DATE,
 			ROUTING_REVISION_DATE,
 			ALTERNATE_BOM_DESIGNATOR,
 			ALTERNATE_ROUTING_DESIGNATOR,
 			COMPLETION_SUBINVENTORY,
 			COMPLETION_LOCATOR_ID,
 			MATERIAL_ACCOUNT,
 			MATERIAL_OVERHEAD_ACCOUNT,
 			RESOURCE_ACCOUNT,
 			OUTSIDE_PROCESSING_ACCOUNT,
 			MATERIAL_VARIANCE_ACCOUNT,
 			RESOURCE_VARIANCE_ACCOUNT,
 			OUTSIDE_PROC_VARIANCE_ACCOUNT,
 			STD_COST_ADJUSTMENT_ACCOUNT,
 			OVERHEAD_ACCOUNT,
 			OVERHEAD_VARIANCE_ACCOUNT,
 			DEMAND_CLASS,
 			SCHEDULED_COMPLETION_DATE,
 			SCHEDULE_GROUP_ID,
 			BUILD_SEQUENCE,
 			LINE_ID,
 			PROJECT_ID,
 			TASK_ID,
 			STATUS,
 			SCHEDULE_NUMBER,
		        SCHEDULED_FLAG,
		        END_ITEM_UNIT_NUMBER,
			ATTRIBUTE_CATEGORY,
 			ATTRIBUTE1,
 			ATTRIBUTE2,
 			ATTRIBUTE3,
 			ATTRIBUTE4,
 			ATTRIBUTE5,
 			ATTRIBUTE6,
 			ATTRIBUTE7,
 			ATTRIBUTE8,
 			ATTRIBUTE9,
 			ATTRIBUTE10,
 			ATTRIBUTE11,
 			ATTRIBUTE12,
 			ATTRIBUTE13,
 			ATTRIBUTE14,
 			ATTRIBUTE15
			 )
		VALUES (
                        p_wip_entity_id,
                        p_organization_id,
                        p_last_update_date,
                        p_last_updated_by,
                        p_creation_date,
                        p_created_by,
                        p_last_update_login,
                        p_request_id,
                        p_program_application_id,
                        p_program_id,
                        p_program_update_date,
                        p_primary_item_id,
                        p_class_code,
                        p_scheduled_start_date,
                        p_date_closed,
                        p_planned_quantity,
                        p_quantity_completed,
			p_quantity_scrapped,			 -- CFM Scrap
                        p_mps_sched_comp_date,
                        p_mps_net_quantity,
                        p_bom_revision,
                        p_routing_revision,
                        p_bom_revision_date,
                        p_routing_revision_date,
                        p_alternate_bom_designator,
                        p_alternate_routing_designator,
                        p_completion_subinventory,
                        p_completion_locator_id,
                        x_material_account,
                        x_material_overhead_account,
                        x_resource_account,
                        x_outside_processing_account,
                        x_material_variance_account,
                        x_resource_variance_account,
                        x_outside_proc_var_account,
                        x_std_cost_adjustment_account,
                        x_overhead_account,
                        x_overhead_variance_account,
                        p_demand_class,
                        p_scheduled_completion_date,
                        p_schedule_group_id,
                        p_build_sequence,
                        p_line_id,
                        p_project_id,
                        p_task_id,
                        p_status,
                        p_schedule_number,
                        p_scheduled_flag,
		        p_unit_number,
                        p_attribute_category,
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
                        p_attribute15)  ;

		return 1;

     exception
      when others then

        /*********************************************************************************
        * The Error Message in this case is handled by the calling Create_Flow_Schedules *
        **********************************************************************************/

		return 0;

end Create_Flow_Schedule;





procedure Delete_Flow_Schedules( p_header_id in number ) is

-- **********************************************
--       Cursor to get all the Failed Flow Completions
--  **********************************************
   CURSOR Del_Flow(header_id number) is
   SELECT transaction_interface_id, rowid,
          transaction_source_id, organization_Id
   FROM   mtl_transactions_interface
   WHERE  transaction_header_id = header_id
       	  AND TRANSACTION_SOURCE_TYPE_ID = 5
          AND FLOW_SCHEDULE = 'Y'
          AND scheduled_flag <> 1
          AND transaction_action_id in (31, 32, 30)		 -- CFM Scrap
          AND process_flag = 3;

x_message       varchar2(240);

begin

        FOR del_rec in del_flow(p_header_id) LOOP

        BEGIN

                delete wip_flow_schedules
		where wip_entity_id = del_rec.transaction_source_id
		and organization_id = del_rec.organization_id ;

		update mtl_transactions_interface
		set    transaction_source_id = NULL
		where  rowid = del_rec.rowid ;

        exception

            when others then

                -- Error deleting the wip flow schedules
                fnd_message.set_name('WIP', 'WIP_ERROR_FLOW_DELETION');
                fnd_message.set_token('ENTITY1',
                		to_char(del_rec.transaction_interface_id) );
                x_message := fnd_message.get ;

                UPDATE MTL_TRANSACTIONS_INTERFACE MTI
                SET     LAST_UPDATE_DATE = SYSDATE,
                        PROGRAM_UPDATE_DATE = SYSDATE,
                        PROCESS_FLAG = 3,
                        LOCK_FLAG = 2,
                        ERROR_CODE = NULL,
                        ERROR_EXPLANATION = x_message
                WHERE rowid = del_rec.rowid ;

		Commit ;
	END ;

	END LOOP ;


    exception

        when others then

                -- Error deleting the wip flow schedules
                fnd_message.set_name('WIP', 'WIP_ERROR_FLOW_DELETION');
                fnd_message.set_token('ENTITY1',
                                to_char(p_header_id) );
                x_message := fnd_message.get ;


                UPDATE MTL_TRANSACTIONS_INTERFACE MTI
                SET     LAST_UPDATE_DATE = SYSDATE,
                        PROGRAM_UPDATE_DATE = SYSDATE,
                        PROCESS_FLAG = 3,
                        LOCK_FLAG = 2,
                        ERROR_CODE = NULL,
                        ERROR_EXPLANATION = x_message
                WHERE   transaction_header_id = p_header_id
                and     transaction_source_type_id = 5
                and     transaction_action_id in (31, 32);

		Commit ;

end Delete_Flow_Schedules ;






procedure Delete_Flow_Schedule( p_wip_entity_id in number ) is
begin

    delete wip_flow_schedules
    where wip_entity_id = p_wip_entity_id ;

    exception
      when others then

        /*********************************************************************************
        * The Error Message in this case is handled by the calling Delete_Flow_Schedules *
        **********************************************************************************/

	  null ;

end Delete_Flow_Schedule ;


/*
   It's a function called by Update_Flow_Schedule.
   This function determines if the schedule need to open / close :
   - 0 means : no change
   - 1 means : reopen the schedule
   - 2 means : close the schedule
*/
function Status_Change(p_planned_qty number,
                       p_cur_completed_qty number,
                       p_qty_completed number) return number is
l_new_completed_qty number;
begin
  l_new_completed_qty := p_cur_completed_qty + p_qty_completed;

  if (l_new_completed_qty >= p_planned_qty) then
    -- Only close the schedule if the current completed quantity < planned quantity
    if (p_cur_completed_qty < p_planned_qty) then
      return 2;
    else
      return 0;
    end if;
  else
    -- This logic is to reopen the schedule that has been previously closed
    -- and need to be reopen. It's caused from the Assembly return of
    -- the schedule that has been fully completed/over completed before.
    -- This schedule is characterized by the fact that
    -- 1. New completed quantity < planned quantity
    -- 2. Current completed quantity >= planned quantity
    if (p_cur_completed_qty >= p_planned_qty) then
      return 1;
    else
      return 0;
    end if;
  end if;
end Status_Change;


function Update_Flow_Schedule( p_wip_entity_id in number,
			       p_quantity_completed in number,	 -- CFM Scrap (primary qty)
			       p_quantity_scrapped IN NUMBER,	 -- CFM Scrap (primary qty)
			       p_transaction_date in date,
			       p_schedule_flag in varchar2,
			       p_last_updated_by number ) return number is
begin

	-- This has to atleast perform the following functions
        --	1. Update the Completed Quantity (or the scrapped quantity)
        --         (the sign is changed to handle it from WIP perspective.)
	--	2. Completion_Date
	--	3. set the status flag
	-- ----------------------------------------------------

        -- Set the DATE_CLOSED and STATUS based on :
        -- 	1. NVL(p_schedule_flag,'N') = 'Y'
        -- 	2. Status_Change() returns value

	Update wip_flow_schedules
	set	QUANTITY_COMPLETED = Nvl(QUANTITY_COMPLETED,0)+(p_quantity_completed * -1), -- CFM Scrap
	        QUANTITY_SCRAPPED = Nvl(QUANTITY_SCRAPPED,0)+(p_quantity_scrapped * -1), -- CFM Scrap
          TRANSACTED_FLAG = 'Y',
		DATE_CLOSED =
                  decode(UPPER(NVL(p_schedule_flag,'N')), 'Y',
                    decode(Wip_Flow_Utilities.Status_Change(PLANNED_QUANTITY,QUANTITY_COMPLETED,p_quantity_completed*-1),
                      0,DATE_CLOSED,1,null,2,p_transaction_date),
                    DATE_CLOSED),
		STATUS =
                  decode(UPPER(NVL(p_schedule_flag,'N')), 'Y',
                    decode(Wip_Flow_Utilities.Status_Change(PLANNED_QUANTITY,QUANTITY_COMPLETED,p_quantity_completed*-1),
                      0,STATUS,1,1,2,2),
		    STATUS),
		 LAST_UPDATED_BY = p_last_updated_by,
		 LAST_UPDATE_DATE = sysdate
	where wip_entity_id = p_wip_entity_id ;

	return 1;

     exception
       when others then

        /*********************************************************************************
        * The Error Message in this case is handled by the calling Delete_Flow_Schedules *
        **********************************************************************************/
	    return 0;

end Update_Flow_Schedule ;




function Pre_Inv_Validations(p_interface_id in number,
			     p_org_id in number,
			     p_user_id in number,
			     p_login_id in number,
			     p_appl_id in number,
			     p_prog_id in number,
			     p_reqstid in number,
			     p_err_num in out nocopy number,
			     p_err_mesg in out nocopy varchar2,
			     p_hdr_id in out nocopy number)
				return number is
x_new_txn_hdr number;
begin

	select MTL_MATERIAL_TRANSACTIONS_S.nextval into x_new_txn_hdr
	from sys.dual ;


	Update Mtl_transactions_interface
	set	TRANSACTION_HEADER_ID = x_new_txn_hdr,
		PROCESS_FLAG = 1,
                LAST_UPDATE_DATE = SYSDATE,
                LAST_UPDATED_BY = p_user_id,
                LAST_UPDATE_LOGIN = p_login_id,
                PROGRAM_APPLICATION_ID = p_appl_id,
                PROGRAM_ID = p_prog_id,
                REQUEST_ID = p_reqstid,
                PROGRAM_UPDATE_DATE = SYSDATE,
                LOCK_FLAG = 1,
                ERROR_CODE = NULL,
                ERROR_EXPLANATION = NULL,
		TRANSACTION_MODE = 3
	where
		parent_id = p_interface_id
       		AND TRANSACTION_SOURCE_TYPE_ID = 5
       		AND FLOW_SCHEDULE = 'Y'
       		AND TRANSACTION_ACTION_ID IN (1,27,33,34)
       		AND PROCESS_FLAG = 2
		AND NVL(LOCK_FLAG,2) = 2;


	p_hdr_id := x_new_txn_hdr ;
	return 1;

  exception
   when others then

        /*********************************************************************************
        * The Error Message in this case is handled by the calling wilctv.ppc		 *
        **********************************************************************************/
	return 0;


end Pre_Inv_Validations;







function Post_Inv_Validations(p_interface_id in number,
                             p_org_id in number,
                             p_user_id in number,
                             p_login_id in number,
                             p_appl_id in number,
                             p_prog_id in number,
                             p_reqstid in number,
                             p_err_num in out nocopy number,
                             p_err_mesg in out nocopy varchar2,
                             p_hdr_id in number,
                             p_org_hdr_id in number)
                                return number is
x_new_txn_hdr number;
begin


        -- Update the header id of the original completion
        Update Mtl_transactions_interface
        set TRANSACTION_HEADER_ID = p_hdr_id
        where transaction_interface_id = p_interface_id ;

        -- Set the information for the backflushed/substitution
        -- issues
        Update Mtl_transactions_interface
        set     PROCESS_FLAG = 1,
                LAST_UPDATE_DATE = SYSDATE,
                LAST_UPDATED_BY = p_user_id,
                LAST_UPDATE_LOGIN = p_login_id,
                PROGRAM_APPLICATION_ID = p_appl_id,
                PROGRAM_ID = p_prog_id,
                REQUEST_ID = p_reqstid,
                PROGRAM_UPDATE_DATE = SYSDATE,
                LOCK_FLAG = 1,
                ERROR_CODE = NULL,
                ERROR_EXPLANATION = NULL
        where
                parent_id = p_interface_id
        and     transaction_header_id = p_hdr_id;

        return 1;

  exception
   when others then

        /*********************************************************************************
        * The Error Message in this case is handled by the calling wilctv.ppc            *
        **********************************************************************************/
        return 0;

end Post_Inv_Validations;



function Post_Transaction_Cleanup(p_header_id in number)
	return number is
x_wip_entity_id number;
x_txn_date date;
x_cpl_qty number;
x_scr_qty NUMBER;						 -- CFM Scrap
x_flow_schedule varchar(1) := 'N';
x_success number := 0;
x_last_updated_by number ; /* Fix for Bug#2517396 */

begin

   SELECT DISTINCT
     transaction_source_id,
     Decode( transaction_action_id, 30, 0, (primary_quantity)*-1),-- CFM Scrap
     Decode( transaction_action_id, 30, (primary_quantity)*-1, 0),-- CFM Scrap
     transaction_date,
     flow_schedule,
     last_updated_by
     into x_wip_entity_id,
          x_cpl_qty,			                          -- CFM Scrap
          x_scr_qty,						  -- CFM Scrap
	  x_txn_date,
	  x_flow_schedule,
          x_last_updated_by
     from mtl_material_transactions
     where transaction_set_id = p_header_id
     and transaction_action_id in (31, 32, 30);                   -- CFM Scrap

     x_success := Update_Flow_Schedule(	x_wip_entity_id, x_cpl_qty, x_scr_qty, -- CFM Scrap
					x_txn_date, x_flow_schedule, x_last_updated_by) ;

     if(x_success=0) then

        /**********************************************************************
        * The Error Message in this case is handled by the calling wilctv.ppc *
        **********************************************************************/
	return 0;

     end if;


     /******************************************************************
     * All the Correlated Sub Queries that we used for cleaning up the *
     * Serial and Lot Information for the Completion/Return are now    *
     * changed to joins inorder to remove Full Table Scans on the child*
     * tables - MSNI, MTLI					       *
     *        			- bbaby, dsoosai 12/11/97	       *
     ******************************************************************/

     DELETE FROM MTL_SERIAL_NUMBERS_INTERFACE
     WHERE TRANSACTION_INTERFACE_ID IN (
     SELECT MTI.TRANSACTION_INTERFACE_ID
     FROM MTL_TRANSACTIONS_INTERFACE MTI
     WHERE MTI.TRANSACTION_HEADER_ID = p_header_id
     AND MTI.PROCESS_FLAG = 1);

     DELETE FROM MTL_SERIAL_NUMBERS_INTERFACE MSNI
     WHERE TRANSACTION_INTERFACE_ID IN (
     SELECT MTLI.SERIAL_TRANSACTION_TEMP_ID
     FROM MTL_TRANSACTION_LOTS_INTERFACE MTLI,
	  MTL_TRANSACTIONS_INTERFACE MTI
     WHERE MTI.TRANSACTION_INTERFACE_ID =
	   MTLI.TRANSACTION_INTERFACE_ID
     AND MTI.TRANSACTION_HEADER_ID = p_header_id
     AND MTI.PROCESS_FLAG = 1);

     DELETE FROM MTL_TRANSACTION_LOTS_INTERFACE
     WHERE TRANSACTION_INTERFACE_ID IN (
     SELECT MTI.TRANSACTION_INTERFACE_ID
     FROM MTL_TRANSACTIONS_INTERFACE MTI
     WHERE MTI.TRANSACTION_HEADER_ID = p_header_id
     AND MTI.PROCESS_FLAG = 1);

     DELETE FROM MTL_TRANSACTIONS_INTERFACE
     WHERE TRANSACTION_HEADER_ID = p_header_id
     AND PROCESS_FLAG = 1;

     return 1;

 exception
   when others then

        /*********************************************************************************
        * The Error Message in this case is handled by the calling wilctv.ppc            *
        **********************************************************************************/
     return 0;

end Post_Transaction_Cleanup ;





function Check_Validation_Errors(p_header_id in number,
				 p_err_num in out nocopy number,
				 p_err_mesg in out nocopy varchar2) return number is
l_err_mesg varchar2(5000);
begin

	select 	ERROR_EXPLANATION
	into    l_err_mesg
	from 	MTL_TRANSACTIONS_INTERFACE
	where 	PROCESS_FLAG = 3
	AND	LOCK_FLAG = 2
	AND	TRANSACTION_HEADER_ID = p_header_id
	AND	ROWNUM <2;

	p_err_mesg := SUBSTR(l_err_mesg, 1, 240);

        /*********************************************************************************
        * The Error Message in this case is handled by the calling wilctv.ppc            *
        **********************************************************************************/

	return 0;


  exception
    when no_data_found then
	return 1;
    when others then

        /*********************************************************************************
        * The Error Message in this case is handled by the calling wilctv.ppc            *
        **********************************************************************************/
	return 0;

end Check_Validation_Errors;


function Flow_Error_Cleanup(p_txn_int_id in number,
			    p_wip_entity_id in number,
			    p_user_id in number,
			    p_login_id in number,
                            p_err_mesg in out nocopy varchar2
                            ) return number is
l_unsched number := 0;
begin

    UPDATE MTL_TRANSACTIONS_INTERFACE MTI
       SET LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = p_user_id,
           LAST_UPDATE_LOGIN = p_login_id,
           PROGRAM_UPDATE_DATE = SYSDATE,
           PROCESS_FLAG = 3,
           LOCK_FLAG = 2,
           ERROR_CODE = substrb(p_err_mesg,1,240),
           ERROR_EXPLANATION = substrb(p_err_mesg,1,240)
     WHERE (TRANSACTION_INTERFACE_ID = p_txn_int_id
	   or parent_id = p_txn_int_id)
     AND   process_flag <> 3    ;


     select 1 into l_unsched
     from wip_flow_schedules
     where wip_entity_id = p_wip_entity_id
     and scheduled_flag <> 1;

     if(l_unsched = 1) then
	Delete_Flow_Schedule(p_wip_entity_id);
     end if ;

     return 1;

  exception
        when no_data_found then
                return 1;
        when others then
                -- Error Deleting the wip flow schedules
                fnd_message.set_name('WIP', 'WIP_FLOW_CLEANUP_ERROR');
                p_err_mesg := fnd_message.get ;
                return 0;

end Flow_Error_Cleanup;

/* Construct_Wip_Line_Ops: This function constructs the wip line ops table of records
by calling the appropriate BOM API.

  If the p_teriminal_op_seq_num is null, this API will try to derive the
  operation seq num from the operation seq id. Then it calls the BOM API to get all
  the line ops before the terminal line op in the primary path of the routing network.

  If the terminal line op is -1 then all the line ops in the primary path of the
  routing network are cached.

  If the terminal line op is -2 then all the line ops (except rework loops) in the
  routing network are cached.
  */

PROCEDURE Construct_Wip_Line_Ops(p_routing_sequence_id IN NUMBER,
				 p_terminal_op_seq_num IN NUMBER,
				 p_terminal_op_seq_id  IN NUMBER,
				 p_date                IN DATE DEFAULT NULL)

  IS
     /* Note: In this procedure op seq always refers to line op seq. */

l_op_exists_in_network NUMBER;
l_terminal_op_seq_num NUMBER;
l_assembly_item_id NUMBER;
l_org_id NUMBER;
l_alt_rout_desig VARCHAR2(10);
BEGIN

   IF (p_terminal_op_seq_num IS NULL
       AND Nvl(p_terminal_op_seq_id,-1) > 0) THEN
      SELECT operation_seq_num
	INTO l_terminal_op_seq_num
	FROM bom_operation_sequences
	WHERE routing_sequence_id = p_routing_sequence_id
	AND operation_sequence_id = p_terminal_op_seq_id;
    ELSIF p_terminal_op_seq_num IS NOT NULL THEN
      l_terminal_op_seq_num := p_terminal_op_seq_num;
   END IF;

   IF (wip_line_ops.COUNT = 0) THEN

      IF (l_terminal_op_seq_num > 0 ) THEN
	 Bom_RTG_Network_API.get_primary_prior_line_ops(p_routing_sequence_id,
							NULL,
							NULL,
							NULL,
							l_terminal_op_seq_num,
							wip_line_ops);
       ELSIF (l_terminal_op_seq_num = -1) THEN
	 Bom_RTG_Network_API.get_all_primary_line_ops(p_routing_sequence_id,
						      NULL,
						      NULL,
						      NULL,
						      wip_line_ops);

	 IF wip_line_ops.COUNT = 0 THEN
	    -- There are no line ops defined
	    wip_line_ops(1).operation_sequence_id := 0;
	    wip_line_ops(1).operation_seq_num := 0;
	 END IF;

       ELSIF (l_terminal_op_seq_num = -2) THEN
	 Bom_RTG_Network_API.get_all_line_ops(p_routing_sequence_id,
					      NULL,
					      NULL,
					      NULL,
					      wip_line_ops);

       ELSE
	 NULL;
      END IF;

   END IF;



EXCEPTION
   WHEN OTHERS THEN
      NULL;
      -- Check for exceptions from the BOM APIs.

END Construct_Wip_Line_Ops;

/* This function checks the wip_line_ops table of records to see if the given op_seq_id exists in the table */

FUNCTION line_op_exists(p_op_seq_id IN NUMBER)
  RETURN NUMBER
IS
l_success NUMBER := 0;
BEGIN

   FOR i IN 1..wip_line_ops.COUNT LOOP
      IF wip_line_ops(i).operation_sequence_id = p_op_seq_id THEN
	 l_success := 1;
	 EXIT;
      END IF;
   END LOOP;

   RETURN l_success;

END line_op_exists;

/* This procedure clears out nocopy the wip_line_ops table of records */

PROCEDURE clear_wip_line_ops_cache
  IS
general EXCEPTION;
BEGIN

      wip_line_ops.delete;

      IF wip_line_ops.COUNT > 0 THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

END clear_wip_line_ops_cache;

/* The following function is only for debugging purpose and is not used in the actual logic */

PROCEDURE show_wip_line_ops(x_all_ops OUT NOCOPY VARCHAR2)
  IS
l_all_ops VARCHAR2(4000) := NULL;
BEGIN

   FOR i IN 1..wip_line_ops.COUNT LOOP
      l_all_ops := l_all_ops||', '||To_char(wip_line_ops(i).operation_sequence_id);
   END LOOP;
   x_all_ops := l_all_ops;

EXCEPTION
   WHEN OTHERS THEN
      NULL;
END show_wip_line_ops;

/* This function checks the sequence of two line ops. It returns 1 if p_line_op_seq1 is
the same or prior to p_line_op_seq2. Otherwise it returns 2. In the case of error -1 is
returned. */

/* If line_op_seq_id is not specified it is derived from line_op_seq_num. However, if
both op_seq_num and op_seq_id are provided it doesnot check if op_seq_id and
op_seq_num are consistent with each other
Note that a line_op_seq_num of -1 is a fictitious line_op that is used to group all
events that do not belong to any line op. This fictitious line op is assumed to be
before the first line op in the routing of the assembly */

/*  If p_destroy_cache is set to Y then the wip_line_ops table of records will be
deleted. So set it to Y only if you are calling this function once. However if you
are calling it over and over again with the same p_line_op_seq2_id, it makes more
sense to set the destroy_cache to N because creating this table of records can be
expensive. */


FUNCTION Line_Op_same_or_prior(p_routing_sequence_id IN NUMBER,
			       p_eff_date            IN DATE,
			       p_line_op_seq1_id     IN NUMBER,
			       p_line_op_seq1_num    IN NUMBER,
			       p_line_op_seq2_id     IN NUMBER,
			       p_line_op_seq2_num    IN NUMBER,
			       p_destroy_cache       IN VARCHAR2) RETURN NUMBER
  IS
l_success NUMBER := 0;
l_line_op_seq2_id NUMBER;
l_line_op_seq1_id NUMBER;
BEGIN


   -- Raise unexpected error if insufficient parameters.

   IF (p_routing_sequence_id IS NULL
       OR p_eff_date IS NULL
       OR (p_line_op_seq1_id IS NULL AND p_line_op_seq1_num IS NULL)
       OR (p_line_op_seq2_id IS NULL AND p_line_op_seq2_num IS NULL)) THEN
      l_success := -1;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF p_line_op_seq2_id IS NULL
     AND p_line_op_seq2_num > 0 THEN
      SELECT operation_sequence_id
	INTO l_line_op_seq2_id
	FROM bom_operation_sequences
	WHERE routing_sequence_id = p_routing_sequence_id
	AND operation_seq_num = p_line_op_seq2_num
	AND operation_type = 3;
    ELSE
      l_line_op_seq2_id := p_line_op_seq2_id;
   END IF;

   IF p_line_op_seq1_id IS NULL
     AND p_line_op_seq1_num > 0 THEN
      SELECT operation_sequence_id
	INTO l_line_op_seq1_id
	FROM bom_operation_sequences
	WHERE routing_sequence_id = p_routing_sequence_id
	AND operation_seq_num = p_line_op_seq1_num
	AND operation_type = 3;
    ELSE
      l_line_op_seq1_id := p_line_op_seq1_id;
   END IF;



   -- If both the line ops are the same
   IF p_line_op_seq1_num = p_line_op_seq2_num THEN
      RETURN 1;
   END IF;

   -- If the second line op is fictitious (and the first one is not)
/*
   IF (p_line_op_seq2_num = -1 OR l_line_op_seq2_id = -1) THEN
      RETURN 2;
   END IF;
*/

   -- Create the wip_line_ops table of records if one doesn't exist

   IF wip_line_ops.COUNT = 0 THEN

      construct_wip_line_ops(p_routing_sequence_id,
			     p_line_op_seq2_num,
			     l_line_op_seq2_id,
			     p_eff_date);
   END IF;

   IF(line_op_exists(l_line_op_seq1_id) = 1) THEN
      l_success := 1;
    ELSE
      l_success := 2;
   END IF;


   IF p_destroy_cache = 'Y' THEN
      clear_wip_line_ops_cache;
   END IF;


   RETURN l_success;

EXCEPTION
   WHEN OTHERS THEN
      RETURN -1;

END Line_Op_same_or_prior;

/* This is the same as the previous function but lacks the cache handling part.
 This function is created especially for use with WNDS, WNPS restrictions.
 This means it neither creates nor destroys the wip_line_ops table of records,
 but just reads from it.*/

FUNCTION same_or_prior_safe(p_routing_sequence_id IN NUMBER,
			       p_eff_date            IN DATE,
			       p_line_op_seq1_id     IN NUMBER,
			       p_line_op_seq1_num    IN NUMBER,
			       p_line_op_seq2_id     IN NUMBER,
			       p_line_op_seq2_num    IN NUMBER) RETURN NUMBER
  IS
l_success NUMBER := 0;
l_line_op_seq2_id NUMBER;
l_line_op_seq1_id NUMBER;
BEGIN

   IF p_line_op_seq2_id IS NULL
     AND p_line_op_seq2_num > 0 THEN
      SELECT operation_sequence_id
	INTO l_line_op_seq2_id
	FROM bom_operation_sequences
	WHERE routing_sequence_id = p_routing_sequence_id
	AND operation_seq_num = p_line_op_seq2_num
	AND operation_type = 3;
    ELSE
      l_line_op_seq2_id := p_line_op_seq2_id;
   END IF;

   IF p_line_op_seq1_id IS NULL
     AND p_line_op_seq1_num > 0 THEN
      SELECT operation_sequence_id
	INTO l_line_op_seq1_id
	FROM bom_operation_sequences
	WHERE routing_sequence_id = p_routing_sequence_id
	AND operation_seq_num = p_line_op_seq1_num
	AND operation_type = 3;
    ELSE
      l_line_op_seq1_id := p_line_op_seq1_id;
   END IF;


   -- If both the line ops are the same
   IF p_line_op_seq1_num = p_line_op_seq2_num THEN
      RETURN 1;
   END IF;

   -- If the second line op is fictitious (and the first one is not)
/*
   IF p_line_op_seq2_num = -1
     OR l_line_op_seq2_id = -1 THEN
      RETURN 2;
   END IF;
*/

     IF(line_op_exists(l_line_op_seq1_id) = 1) THEN
      l_success := 1;
    ELSE
      l_success := 2;
   END IF;


   RETURN l_success;

END same_or_prior_safe;

/* This procedure returns the line op seq num and the line op seq id of the line op to
which a given event belongs. If no line op is found for this event, both the opseq_num
and the opseq_id are set to -1*/

PROCEDURE get_line_op_from_event(p_routing_sequence_id IN NUMBER,
				 p_eff_date            IN DATE,
				 p_event_op_seq_num    IN NUMBER,
				 x_line_op_seq_num     OUT NOCOPY NUMBER,
				 x_line_op_seq_id      OUT NOCOPY NUMBER)
  IS
     l_line_op_seq_num NUMBER := 0;
     l_line_op_seq_id NUMBER := 0;
BEGIN

   SELECT bos2.operation_seq_num, bos2.operation_sequence_id
     INTO l_line_op_seq_num, l_line_op_seq_id
     FROM bom_operation_sequences bos1, bom_operation_sequences bos2
     WHERE bos2.operation_sequence_id = bos1.line_op_seq_id
     AND bos1.routing_sequence_id = p_routing_sequence_id
     AND bos1.operation_seq_num = p_event_op_seq_num
     AND bos1.effectivity_date <= p_eff_date
     AND Nvl(bos1.disable_date,p_eff_date+1) > p_eff_date
     AND bos1.operation_type = 1;

   x_line_op_seq_num := l_line_op_seq_num;
   x_line_op_seq_id := l_line_op_seq_id;

EXCEPTION
   WHEN no_data_found THEN
      x_line_op_seq_num := -1;
      x_line_op_seq_id := -1;

   WHEN OTHERS THEN
      x_line_op_seq_num := NULL;
      x_line_op_seq_id := NULL;

END get_line_op_from_event;

/* This is the function version of the above procedure */

FUNCTION event_to_lineop_seq_num(p_routing_sequence_id IN NUMBER,
				 p_eff_date            IN DATE,
				 p_event_op_seq_num    IN NUMBER) RETURN NUMBER
IS
l_line_op_seq_num NUMBER := NULL;
l_line_op_seq_id NUMBER;
BEGIN
   get_line_op_from_event(p_routing_sequence_id => p_routing_sequence_id,
			  p_eff_date            => p_eff_date,
			  p_event_op_seq_num    => p_event_op_seq_num,
			  x_line_op_seq_num     => l_line_op_seq_num,
			  x_line_op_seq_id      => l_line_op_seq_id);
   RETURN l_line_op_seq_num;

EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;

END event_to_lineop_seq_num;

/* This function checks to see if a given event op seq is in the same line
ops as p_line_op_seq_num or if it is in a line op that is prior
to p_line_op_seq_num. This fucntion returns 1 on success, 2 or failure
and -1 on error. This function works by conventing the given event
to its line op and the calls the line op comparison function,
so destroy cache is used exactly in the same way as
in the lineop comparison function*/


FUNCTION Event_in_same_or_prior_lineop(p_routing_sequence_id IN NUMBER,
				       p_eff_date            IN DATE,
				       p_event_op_seq_num    IN NUMBER,
				       p_line_op_seq_num     IN NUMBER,
				       p_destroy_cache       IN VARCHAR2) RETURN NUMBER
  IS
l_success NUMBER := 0;
l_line_op_seq1_num NUMBER;
l_line_op_seq1_id NUMBER;
l_return_status VARCHAR2(1);
BEGIN


   -- Insufficient arguments

   IF (p_routing_sequence_id IS NULL
       OR p_eff_date IS NULL
       OR p_event_op_seq_num IS NULL
       OR p_line_op_seq_num IS NULL) THEN

      l_success := -1;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   get_line_op_from_event(p_routing_sequence_id,
			  p_eff_date,
			  p_event_op_seq_num,
			  l_line_op_seq1_num,
			  l_line_op_seq1_id);

--   IF l_line_op_seq1_num IS NULL THEN
--      l_success := -1;
--    ELSIF l_line_op_seq1_num = -1 THEN
--      -- The event specified does not have a line op return success.
--
--      l_success := 1;
--    ELSE
      l_success := Line_Op_same_or_prior(p_routing_sequence_id => p_routing_sequence_id,
					 p_eff_date         => p_eff_date,
					 p_line_op_seq1_id  => l_line_op_seq1_id,
					 p_line_op_seq1_num => l_line_op_seq1_num,
					 p_line_op_seq2_id  => NULL,
					 p_line_op_seq2_num => p_line_op_seq_num,
					 p_destroy_cache    => p_destroy_cache);
--   END IF;


   RETURN l_success;
EXCEPTION
   WHEN OTHERS THEN
      RETURN -1;

END Event_in_same_or_prior_lineop;

/* This function the similar to the one before but has the WNDS, WNPS pragma set so it calls the "safe" version of the lineop comparison function */

FUNCTION same_or_prior_lineop_safe(p_routing_sequence_id IN NUMBER,
				   p_eff_date            IN DATE,
				   p_event_op_seq_num    IN NUMBER,
				   p_line_op_seq_num     IN NUMBER) RETURN NUMBER
  IS
l_success NUMBER := 0;
l_line_op_seq1_num NUMBER;
l_line_op_seq1_id NUMBER;
l_return_status VARCHAR2(1);
BEGIN

   get_line_op_from_event(p_routing_sequence_id,
			  p_eff_date,
			  p_event_op_seq_num,
			  l_line_op_seq1_num,
			  l_line_op_seq1_id);

   IF l_line_op_seq1_num IS NULL THEN
      l_success := -1;
    ELSIF l_line_op_seq1_num = -1 THEN
      -- The event specified does not have a line op. All such events are grouped together before the first line op.

      l_success := 1;
    ELSE
      l_success := same_or_prior_safe(p_routing_sequence_id => p_routing_sequence_id,
					 p_eff_date         => p_eff_date,
					 p_line_op_seq1_id  => l_line_op_seq1_id,
					 p_line_op_seq1_num => l_line_op_seq1_num,
					 p_line_op_seq2_id  => NULL,
					 p_line_op_seq2_num => p_line_op_seq_num);
   END IF;


   RETURN l_success;
EXCEPTION
   WHEN OTHERS THEN
      RETURN -1;

END same_or_prior_lineop_safe;

PROCEDURE default_lots(txn_interface_id IN NUMBER, txn_source_name IN VARCHAR2,
  txn_type_id IN NUMBER, wip_entity_id IN NUMBER) IS

    /*  attributes of a given lot */
    Cursor c_lot(p_org_id NUMBER, p_inventory_item_id NUMBER, p_lot_number VARCHAR2) IS
        select
               lot_number,
               expiration_date as lot_expiration_date,
               description,
               vendor_name,
               supplier_lot_number,
               grade_code,
               origination_date,
               date_code,
               status_id,
               change_date,
               age,
               retest_date,
               maturity_date,
               lot_attribute_category,
               item_size,
               color,
               volume,
               volume_uom,
               place_of_origin,
               best_by_date,
               length,
               length_uom,
               recycled_content,
               thickness,
               thickness_uom,
               width,
               width_uom,
               curl_wrinkle_fold,
               c_attribute1,
               c_attribute2,
               c_attribute3,
               c_attribute4,
               c_attribute5,
               c_attribute6,
               c_attribute7,
               c_attribute8,
               c_attribute9,
               c_attribute10,
               c_attribute11,
               c_attribute12,
               c_attribute13,
               c_attribute14,
               c_attribute15,
               c_attribute16,
               c_attribute17,
               c_attribute18,
               c_attribute19,
               c_attribute20,
               d_attribute1,
               d_attribute2,
               d_attribute3,
               d_attribute4,
               d_attribute5,
               d_attribute6,
               d_attribute7,
               d_attribute8,
               d_attribute9,
               d_attribute10,
               n_attribute1,
               n_attribute2,
               n_attribute3,
               n_attribute4,
               n_attribute5,
               n_attribute6,
               n_attribute7,
               n_attribute8,
               n_attribute9,
               n_attribute10,
               vendor_id,
               territory_code
       from mtl_lot_numbers
       where organization_id = p_org_id
         and inventory_item_id = p_inventory_item_id
         and lot_number = p_lot_number;

        Cursor c_lotItems IS
        select mti.operation_seq_num,
               mti.inventory_item_id,
               msi.concatenated_segments,
               mti.primary_quantity * -1 primary_quantity,
               mti.transaction_quantity * -1 transaction_quantity,
               msi.primary_uom_code,
               mti.subinventory_code,
               mti.locator_id,
               msi.mtl_transactions_enabled_flag,
               msi.serial_number_control_code,
               msi.lot_control_code,
               mti.revision,
               mti.organization_id,
               mti.transaction_source_id,
               mti.transaction_action_id,
               mti.transaction_interface_id,
               mti.transaction_source_name,
               mti.transfer_cost_group_id  cost_group_id,
               least( 1, NVL(mti.transfer_lpn_id, 0) + NVL(mti.content_lpn_id, 0) )  containerized,
               mti.transaction_header_id        -- bugfix 4455722
          from mtl_transactions_interface mti,
               mtl_system_items_kfv msi
         where mti.parent_id = txn_interface_id
           and nvl(mti.operation_seq_num, 1) > 0 /* not for phatom assembly */
           and mti.transaction_action_id in (1,27,33,34)  /*wip_constants.isscomp_action, wip_constants.retcomp_action, wip_constants.issnegc_action, wip_constants.retnegc_action)*/
           and mti.inventory_item_id = msi.inventory_item_id
           and mti.organization_id = msi.organization_id
           and msi.lot_control_code = 2
           and msi.serial_number_control_code = 1;

        l_lotItemsRecords         c_lotItems%ROWTYPE;
        l_lotNumber               c_lot%ROWTYPE;

        x_returnStatus            varchar2(1);
        l_compObj                 system.wip_lot_serial_obj_t;
        l_lot                     system.wip_txn_lot_obj_t;
        l_org_id                  NUMBER;
        l_wipentityid             NUMBER;
        l_errorcode               NUMBER;
        l_errormesg               VARCHAR2(100);

        l_cur_item system.wip_component_obj_t := null;
        l_cur_lot system.wip_txn_lot_obj_t := null;
        l_more                    boolean;
        l_qty                     NUMBER;

        l_msg_count               NUMBER;
        l_msg_data                VARCHAR2(255);
        l_rev_code                VARCHAR2(255);
        l_is_revision_control     boolean;
        tree_id                   NUMBER;
        l_qoh                     NUMBER;
        l_rqoh                    NUMBER;
        l_qr                      NUMBER;
        l_qs                      NUMBER;
        l_att                     NUMBER;
        l_atr                     NUMBER;

        l_comp_txn_type_id        NUMBER;
        l_txn_type_id             NUMBER;
        l_txn_act_id              NUMBER;
BEGIN
    savepoint defaultlotsp_10;
    x_returnStatus := fnd_api.g_ret_sts_success;

    l_compObj := system.wip_lot_serial_obj_t(null, null, null, null, null, null);
    l_compObj.initialize;

    if ( txn_type_id in (44, 90) ) then
      l_comp_txn_type_id := 35;
    elsif( txn_type_id in (17, 91) ) then
      l_comp_txn_type_id := 43;
    else
      l_comp_txn_type_id := 35;
    end if;

    select t.transaction_action_id
    into l_txn_act_id
    from mtl_transaction_types t
    where t.transaction_type_id = l_comp_txn_type_id;

    open c_lotItems;

    l_org_id := null;

    LOOP
      Fetch c_lotItems into l_lotItemsRecords;

      if ( c_lotItems%NOTFOUND ) THEN
        close c_lotItems;
        EXIT;
      end if;

      l_org_id    := l_lotItemsRecords.organization_id;
---    l_wipentityid    := l_lotItemsRecords.transaction_source_id;
      l_wipentityid := wip_entity_id;
      if(l_wipentityid is null ) then
        l_wipentityid := -1;
      end if;

      -- Add the items to the wip_lot_serial_obj_t
      l_compObj.addItem(p_opSeqNum         => l_lotItemsRecords.operation_seq_num,
            p_itemID         => l_lotItemsRecords.inventory_item_id,
            p_itemName         => l_lotItemsRecords.concatenated_segments,
            p_priQty         => l_lotItemsRecords.primary_quantity,
            p_priUomCode         => l_lotItemsRecords.primary_uom_code,
            p_supplySubinv         => l_lotItemsRecords.subinventory_code,
            p_supplyLocID        => l_lotItemsRecords.locator_id,
            p_wipSupplyType     => 3,
            p_txnActionID        => l_txn_act_id, --l_lotItemsRecords.transaction_action_id,
            p_mtlTxnsEnabledFlag     => l_lotItemsRecords.mtl_transactions_enabled_flag,
            p_revision         => l_lotItemsRecords.revision,
            p_lotControlCode    => l_lotItemsRecords.lot_control_code,
            p_serialControlCode    => l_lotItemsRecords.serial_number_control_code,
            p_genericid        => null );
    End LOOP; -- end of for loop

    if( l_org_id is null) then
      -- nothing to default lot
      return;
    end if;

    -- <Default the Lot>
    wip_autolotproc_priv.derivelots(
        x_compLots     => l_compObj,
        p_orgID        => l_org_id,
        p_wipEntityID    => l_wipentityid,
        p_initMsgList    => fnd_api.g_true,
        p_endDebug    => fnd_api.g_true,
        p_destroyTrees => fnd_api.g_false,
        p_treeMode => 3,   -- make sure we use the same tree_mode as inv lot entry form
        p_treeSrcName => txn_source_name,
        x_returnStatus    => x_returnStatus );

    if ( x_returnStatus = fnd_api.g_ret_sts_unexp_error ) then
    raise fnd_api.g_exc_unexpected_error;
    end if;

    open c_lotItems;

    LOOP
        l_more := l_compObj.setnextitem();
        exit when not l_more;

        Fetch c_lotItems into l_lotItemsRecords;

        if ( c_lotItems%NOTFOUND ) THEN
            close c_lotItems;
            EXIT;
        end if;

        l_more := l_compObj.getcurrentitem(l_cur_item);

        select decode(t.revision_qty_control_code, 2, 'T', 'F') into l_rev_code
        From mtl_system_items_b t
        Where t.inventory_item_id = l_lotItemsRecords.inventory_item_id
              and t.organization_id = l_lotItemsRecords.organization_id;

        if ( l_rev_code = 'T' ) then
            l_is_revision_control := true;
        else
            l_is_revision_control := false;
        end if;

        LOOP
            l_more := l_compObj.getnextlot(l_cur_lot);
            exit when not l_more;

            -- added to populate values to the table columns (expiration date, flex fields),
            -- which would be populated if you use the lot-entry form the usual way
            -- fix bug 2349555
            open c_lot(l_lotItemsRecords.organization_id,
                l_lotItemsRecords.inventory_item_id, l_cur_lot.lot_number);
            fetch c_lot into l_lotNumber;

            l_qty := abs(round(l_cur_lot.primary_quantity *
                 l_lotItemsRecords.transaction_quantity/l_lotItemsRecords.primary_quantity,
                        wip_constants.max_displayed_precision));
            insert into mtl_transaction_lots_temp
            (
              transaction_temp_id,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              request_id,
              program_application_id,
              program_id,
              program_update_date,
              transaction_quantity,
              primary_quantity,
              lot_number,
              group_header_id,          -- bugfix 4455722

              -- added
              lot_expiration_date,
              description,
              vendor_name,
              supplier_lot_number,
              grade_code,
              origination_date,
              date_code,
              status_id,
              change_date,
              age,
              retest_date,
              maturity_date,
              lot_attribute_category,
              item_size,
              color,
              volume,
              volume_uom,
              place_of_origin,
              best_by_date,
              length,
              length_uom,
              recycled_content,
              thickness,
              thickness_uom,
              width,
              width_uom,
              curl_wrinkle_fold,
              c_attribute1,
              c_attribute2,
              c_attribute3,
              c_attribute4,
              c_attribute5,
              c_attribute6,
              c_attribute7,
              c_attribute8,
              c_attribute9,
              c_attribute10,
              c_attribute11,
              c_attribute12,
              c_attribute13,
              c_attribute14,
              c_attribute15,
              c_attribute16,
              c_attribute17,
              c_attribute18,
              c_attribute19,
              c_attribute20,
              d_attribute1,
              d_attribute2,
              d_attribute3,
              d_attribute4,
              d_attribute5,
              d_attribute6,
              d_attribute7,
              d_attribute8,
              d_attribute9,
              d_attribute10,
              n_attribute1,
              n_attribute2,
              n_attribute3,
              n_attribute4,
              n_attribute5,
              n_attribute6,
              n_attribute7,
              n_attribute8,
              n_attribute9,
              n_attribute10,
              vendor_id,
              territory_code
            )
            values
            (
              l_lotItemsRecords.transaction_interface_id,
              sysdate,
              fnd_global.user_id,
              sysdate,
              fnd_global.user_id,
              fnd_global.login_id,
              fnd_global.conc_request_id,
              fnd_global.prog_appl_id,
              fnd_global.conc_program_id,
              sysdate,
              l_qty,
              abs(l_cur_lot.primary_quantity),
              l_cur_lot.lot_number,
              l_lotItemsRecords.transaction_header_id,  --bugfix 4455722

              -- added
              l_lotNumber.lot_expiration_date,
              l_lotNumber.description,
              l_lotNumber.vendor_name,
              l_lotNumber.supplier_lot_number,
              l_lotNumber.grade_code,
              l_lotNumber.origination_date,
              l_lotNumber.date_code,
              l_lotNumber.status_id,
              l_lotNumber.change_date,
              l_lotNumber.age,
              l_lotNumber.retest_date,
              l_lotNumber.maturity_date,
              l_lotNumber.lot_attribute_category,
              l_lotNumber.item_size,
              l_lotNumber.color,
              l_lotNumber.volume,
              l_lotNumber.volume_uom,
              l_lotNumber.place_of_origin,
              l_lotNumber.best_by_date,
              l_lotNumber.length,
              l_lotNumber.length_uom,
              l_lotNumber.recycled_content,
              l_lotNumber.thickness,
              l_lotNumber.thickness_uom,
              l_lotNumber.width,
              l_lotNumber.width_uom,
              l_lotNumber.curl_wrinkle_fold,
              l_lotNumber.c_attribute1,
              l_lotNumber.c_attribute2,
              l_lotNumber.c_attribute3,
              l_lotNumber.c_attribute4,
              l_lotNumber.c_attribute5,
              l_lotNumber.c_attribute6,
              l_lotNumber.c_attribute7,
              l_lotNumber.c_attribute8,
              l_lotNumber.c_attribute9,
              l_lotNumber.c_attribute10,
              l_lotNumber.c_attribute11,
              l_lotNumber.c_attribute12,
              l_lotNumber.c_attribute13,
              l_lotNumber.c_attribute14,
              l_lotNumber.c_attribute15,
              l_lotNumber.c_attribute16,
              l_lotNumber.c_attribute17,
              l_lotNumber.c_attribute18,
              l_lotNumber.c_attribute19,
              l_lotNumber.c_attribute20,
              l_lotNumber.d_attribute1,
              l_lotNumber.d_attribute2,
              l_lotNumber.d_attribute3,
              l_lotNumber.d_attribute4,
              l_lotNumber.d_attribute5,
              l_lotNumber.d_attribute6,
              l_lotNumber.d_attribute7,
              l_lotNumber.d_attribute8,
              l_lotNumber.d_attribute9,
              l_lotNumber.d_attribute10,
              l_lotNumber.n_attribute1,
              l_lotNumber.n_attribute2,
              l_lotNumber.n_attribute3,
              l_lotNumber.n_attribute4,
              l_lotNumber.n_attribute5,
              l_lotNumber.n_attribute6,
              l_lotNumber.n_attribute7,
              l_lotNumber.n_attribute8,
              l_lotNumber.n_attribute9,
              l_lotNumber.n_attribute10,
              l_lotNumber.vendor_id,
              l_lotNumber.territory_code
            );

         close c_lot;

         END LOOP;
     END LOOP;

  EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error then
          rollback to defaultlotsp1_10;
      WHEN OTHERS then
          l_errorcode := SQLCODE;
          l_errormesg := SUBSTR( SQLERRM, 1, 100 );
          rollback to defaultlotsp_10;

END default_lots;

end Wip_Flow_Utilities;

/
