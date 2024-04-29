--------------------------------------------------------
--  DDL for Package Body BOMPVALR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOMPVALR" as
/* $Header: BOMVALRB.pls 120.2.12010000.2 2008/11/14 16:41:56 snandana ship $
+===========================================================================+
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMPVALR.plb                                               |
| DESCRIPTION  : This package contains functions used to validate routing   |
| 		 data in the interface tables                               |
| Parameters:	org_id		organization_id                             |
|		all_org		process all orgs or just current org        |
|				1 - all orgs                                |
|				2 - only org_id                             |
|    		prog_appid      program application_id                      |
|    		prog_id  	program id                                  |
|    		request_id      request_id                                  |
|    		user_id		user id                                     |
|    		login_id	login id                                    |
| History:	                                                            |
|    10/05/93   Shreyas Shah	creation date                               |
|    05/04/94   Julie Maeyama   updated code                                |
|                                                                           |
+==========================================================================*/

/*---------------------- bmvrtgh_validate_rtg_header -----------------------*/
/* NAME
    bmvrtgh_validate_rtg_header - validate routing data
DESCRIPTION
    validate the routing header information before loading into the
    production tables.

REQUIRES
    err_text 	out buffer to return error message
MODIFIES
    MTL_INTERFACE_ERRORS
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmvrtgh_validate_rtg_header (
    org_id		NUMBER,
    all_org		NUMBER,
    user_id		NUMBER,
    login_id		NUMBER,
    prog_appid		NUMBER,
    prog_id		NUMBER,
    request_id		NUMBER,
    err_text  IN OUT NOCOPY 	VARCHAR2
)
    return INTEGER
IS
    CURSOR c1 is select
	organization_id OI, routing_sequence_id RSI,
	assembly_item_id AII, common_routing_sequence_id CRSI,
	completion_locator_id CLI, routing_type RT,
	common_assembly_item_id CAII, completion_subinventory CS,
	alternate_routing_designator ARD, transaction_id TI
	from bom_op_routings_interface
	where process_flag = 2
	and rownum < 500;

    ret_code 		NUMBER;
    stmt_num		NUMBER;
    dummy_id		NUMBER;
    commit_cnt  	NUMBER;
    inv_asst            VARCHAR2(1);
    r_subinv            NUMBER;
    r_loc               NUMBER;
    loc_ctl             NUMBER;
    org_loc             NUMBER;
    sub_loc_code        NUMBER;
    dummy               VARCHAR2(50);
    continue_loop 	BOOLEAN := TRUE;
    X_expense_to_asset_transfer NUMBER;

BEGIN
/*
** Check for valid org id
*/
    while continue_loop loop
      commit_cnt := 0;
      for c1rec in c1 loop
        commit_cnt := commit_cnt + 1;
	stmt_num := 1;
        BEGIN
           select organization_id
             into dummy_id
            from mtl_parameters
           where organization_id = c1rec.OI;
        EXCEPTION
           when NO_DATA_FOUND then
              ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c1rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => request_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_OP_ROUTINGS_INTERFACE',
                        msg_name => 'BOM_INVALID_ORG_ID',
                        err_text => err_text);
               update bom_op_routings_interface set
                       process_flag = 3
               where transaction_id = c1rec.TI;
               if (ret_code <> 0) then
                   return(ret_code);
               end if;
               goto continue_loop;
        END;

        stmt_num := 2;
        if (c1rec.ARD is not null) then     /* Check for valid alternate */
           BEGIN
              select 1
                into dummy_id
                from bom_alternate_designators
               where organization_id = c1rec.OI
                 and alternate_designator_code = c1rec.ARD;
           EXCEPTION
              when NO_DATA_FOUND then
                 ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c1rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => request_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_OP_ROUTINGS_INTERFACE',
                        msg_name => 'BOM_INVALID_RTG_ALTERNATE',
                        err_text => err_text);
                  update bom_op_routings_interface set
                          process_flag = 3
                  where transaction_id = c1rec.TI;

                  if (ret_code <> 0) then
                      return(ret_code);
                  end if;
                  goto continue_loop;
           END;
         end if;

        stmt_num := 3;                    /* Check if assembly item exists */
        ret_code := BOMPVALB.bmvassyid_verify_assembly_id(
                org_id => c1rec.OI,
                assy_id => c1rec.AII,
                err_text => err_text);
        if (ret_code <> 0) then
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c1rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => request_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_OP_ROUTINGS_INTERFACE',
                        msg_name => 'BOM_ASSEMBLY_ITEM_INVALID',
                        err_text => err_text);
            update bom_op_routings_interface set
                    process_flag = 3
            where transaction_id = c1rec.TI;

            if (ret_code <> 0) then
                return(ret_code);
            end if;
            goto continue_loop;
        end if;

        stmt_num := 4;  /* routing_type must be 1 or 2 */
        if (c1rec.RT <> 1) and (c1rec.RT <> 2) then
           ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c1rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => request_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_OP_ROUTINGS_INTERFACE',
                        msg_name => 'BOM_ROUTING_TYPE_INVALID',
                        err_text => err_text);
            update bom_op_routings_interface set
                    process_flag = 3
            where transaction_id = c1rec.TI;

            if (ret_code <> 0) then
                return(ret_code);
            end if;
            goto continue_loop;
         end if;

/* Check for unique routing seq id */
	ret_code :=bmvurtg_verify_routing(
		rtg_seq_id => c1rec.RSI,
		mode_type => 1,
		err_text => err_text);
	if (ret_code <> 0) then
	    ret_code := INVPUOPI.mtl_log_interface_err(
			org_id => NULL,
			user_id => user_id,
			login_id => login_id,
			prog_appid => prog_appid,
			prog_id => prog_id,
			req_id => request_id,
			trans_id => c1rec.TI,
			error_text => err_text,
			tbl_name => 'BOM_OP_ROUTINGS_INTERFACE',
			msg_name => 'BOM_DUPLICATE_RTG',
			err_text => err_text);
	    update bom_op_routings_interface set
		    process_flag = 3
	    where transaction_id = c1rec.TI;

	    if (ret_code <> 0) then
	        return(ret_code);
	    end if;
	    goto continue_loop;
	end if;

/*
** Check for duplicate assy,org,alt combo
** Check alternate routing has a primary
** Check alternate mfg routing does not have an eng primary routing
*/
        stmt_num := 6;
	ret_code :=bmvduprt_verify_duplicate_rtg(
		org_id => c1rec.OI,
		assy_id => c1rec.AII,
		alt_desg => c1rec.ARD,
                rtg_type => c1rec.RT,
		err_text => err_text);
	if (ret_code <> 0) then
	    ret_code := INVPUOPI.mtl_log_interface_err(
			org_id => c1rec.OI,
			user_id => user_id,
			login_id => login_id,
			prog_appid => prog_appid,
			prog_id => prog_id,
			req_id => request_id,
			trans_id => c1rec.TI,
			error_text => err_text,
			tbl_name => 'BOM_OP_ROUTINGS_INTERFACE',
			msg_name => 'BOM_RTG_INVALID',
			err_text => err_text);
	    update bom_op_routings_interface set
		    process_flag = 3
	    where transaction_id = c1rec.TI;

	    if (ret_code <> 0) then
	        return(ret_code);
	    end if;
	    goto continue_loop;
	end if;

/* Check routing type and item attributes */
        stmt_num := 7;
	ret_code :=bmvrtg_verify_rtg_type(
	   	org_id => c1rec.OI,
		assy_id => c1rec.AII,
		rtg_type => c1rec.RT,
		err_text => err_text);
	if (ret_code <> 0) then
	    ret_code := INVPUOPI.mtl_log_interface_err(
			org_id => NULL,
			user_id => user_id,
			login_id => login_id,
			prog_appid => prog_appid,
			prog_id => prog_id,
			req_id => request_id,
			trans_id => c1rec.TI,
			error_text => err_text,
			tbl_name => 'BOM_OP_ROUTINGS_INTERFACE',
			msg_name => 'BOM_ROUTING_TYPE_ERR',
			err_text => err_text);
	    update bom_op_routings_interface set
		    process_flag = 3
	    where transaction_id = c1rec.TI;

	    if (ret_code <> 0) then
	        return(ret_code);
	    end if;
	    goto continue_loop;
	end if;

/* Check cmn rtg seq id existence */
        stmt_num := 8;
        if c1rec.RSI = c1rec.CRSI then
           NULL;
        else
           ret_code :=bmvurtg_verify_routing(
                rtg_seq_id => c1rec.CRSI,
                mode_type => 2,
                err_text => err_text);
           if (ret_code <> 0) then
                ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c1rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => request_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_OP_ROUTINGS_INTERFACE',
                        msg_name => 'BOM_COMMON_RTG_NOT_EXIST',
                        err_text => err_text);
                update bom_op_routings_interface set
                    process_flag = 3
                 where transaction_id = c1rec.TI;

                if (ret_code <> 0) then
                   return(ret_code);
                end if;
                goto continue_loop;
           end if;


/* Verify common routing attributes */
	ret_code :=bmvcmrtg_verify_common_routing(
		rtg_id => c1rec.RSI,
		cmn_rtg_id => c1rec.CRSI,
		rtg_type => c1rec.RT,
		item_id => c1rec.AII,
                org_id => c1rec.OI,
		alt_desg => c1rec.ARD,
		err_text => err_text);
	if (ret_code <> 0) then
	    ret_code := INVPUOPI.mtl_log_interface_err(
			org_id => NULL,
			user_id => user_id,
			login_id => login_id,
			prog_appid => prog_appid,
			prog_id => prog_id,
			req_id => request_id,
			trans_id => c1rec.TI,
			error_text => err_text,
			tbl_name => 'BOM_OP_ROUTINGS_INTERFACE',
			msg_name => 'BOM_COMMON_RTG_ERROR',
			err_text => err_text);
	    update bom_op_routings_interface set
		    process_flag = 3
	    where transaction_id = c1rec.TI;

	    if (ret_code <> 0) then
	        return(ret_code);
	    end if;
	    goto continue_loop;
	end if;
    end if;
/*
** Validate subinventory
*/
        if (c1rec.CLI is not null and c1rec.CS is null) then
           goto write_loc_error;
        end if;

        if (c1rec.CLI is null and c1rec.CS is null) then
          goto update_comp;
        end if;

        select inventory_asset_flag,restrict_subinventories_code,
               restrict_locators_code, location_control_code
          into inv_asst, r_subinv, r_loc, loc_ctl
          from mtl_system_items
         where inventory_item_id = c1rec.AII
           and organization_id = c1rec.OI;
/*
** if item locator control is null, set to 1 (no loc control)
*/
       if (loc_ctl is null) then
           loc_ctl := 1;
       end if;
/*
** if subinv is not restricted and locator is, then make
** locator unrestricted
*/

        if (r_subinv = 2) and (r_loc = 1) then
            r_loc := 2;
        end if;
/*
** Check if subinventory is valid
*/

/*
** get value of profile INV:EXPENSE_TO_ASSET_TRANSFER
*/
    BOMPRFIL.bom_pr_get_profile(
		appl_short_name => 'INV',
		profile_name => 'INV:EXPENSE_TO_ASSET_TRANSFER',
		user_id => user_id,
		resp_appl_id => prog_appid,
	    	resp_id => 401,
		profile_value => X_expense_to_asset_transfer,
		return_code => ret_code,
		return_message => err_text);
    if (ret_code <> 0) then
	return(ret_code);
    end if;

    IF (r_subinv = 2) THEN    /* non-restricted subinventory */
         IF (X_expense_to_asset_transfer = 1) THEN
             begin
               select locator_type
                 into sub_loc_code
                 from mtl_secondary_inventories
                where secondary_inventory_name = c1rec.CS
                  and organization_id = c1rec.OI
                  and nvl(disable_date,TRUNC(SYSDATE)+1) > TRUNC(SYSDATE)
                  and quantity_tracked = 1;
             exception
                when no_data_found then
                     goto write_subinv_error;
             end;
         ELSE
             begin
               select locator_type
                 into sub_loc_code
                 from mtl_secondary_inventories
                where secondary_inventory_name = c1rec.CS
                  and organization_id = c1rec.OI
                  and nvl(disable_date,TRUNC(SYSDATE)+1) > TRUNC(SYSDATE)
                  and ((inv_asst = 'Y' and asset_inventory = 1 and
                        quantity_tracked = 1)
                       or
                       (inv_asst = 'N')
                      );
             exception
                when no_data_found then
                     goto write_subinv_error;
             end;
          END IF;
     ELSE                           /* restricted subinventory */
         IF (X_expense_to_asset_transfer = 1) THEN
            begin
               select locator_type
                 into sub_loc_code
                 from mtl_secondary_inventories sub,
                      mtl_item_sub_inventories item
                where item.organization_id = sub.organization_id
                  and item.secondary_inventory = sub.secondary_inventory_name
                  and item.inventory_item_id = c1rec.AII
                  and sub.secondary_inventory_name = c1rec.CS
                  and sub.organization_id = c1rec.OI
                  and nvl(sub.disable_date,TRUNC(SYSDATE)+1) >
                      TRUNC(SYSDATE)
                  and sub.quantity_tracked = 1;
             exception
                when no_data_found then
                     goto write_subinv_error;
             end;
	 ELSE
            begin
               select locator_type
                 into sub_loc_code
                 from mtl_secondary_inventories sub,
                      mtl_item_sub_inventories item
                where item.organization_id = sub.organization_id
                  and item.secondary_inventory = sub.secondary_inventory_name
                  and item.inventory_item_id = c1rec.AII
                  and sub.secondary_inventory_name = c1rec.CS
                  and sub.organization_id = c1rec.OI
                  and nvl(sub.disable_date,TRUNC(SYSDATE)+1) >
                      TRUNC(SYSDATE)
                  and ((inv_asst = 'Y' and sub.asset_inventory = 1 and
                        sub.quantity_tracked = 1)
                       or
                       (inv_asst = 'N')
                      );
             exception
                when no_data_found then
                     goto write_subinv_error;
             end;
         END IF;
     END IF;
/*
** Validate locator
*/
/* Org level */
        select stock_locator_control_code
          into org_loc
          from mtl_parameters
         where organization_id = c1rec.OI;

        if (org_loc = 1) and (c1rec.CLI is not null) then
           goto write_loc_error;
        end if;

        if ((org_loc = 2) or (org_loc = 3))and (c1rec.CLI is null) then
           goto write_loc_error;
        end if;

        if ((org_loc = 2) or (org_loc = 3)) and (c1rec.CLI is not null) then
             if (r_loc = 2) then    /* non-restricted locator */
                begin
                 select 'loc exists'
                   into dummy
                   from mtl_item_locations
                  where inventory_location_id = c1rec.CLI
                    and organization_id = c1rec.OI
                    and subinventory_code = c1rec.CS
                   and nvl(disable_date,trunc(SYSDATE)+1) > trunc(SYSDATE);
               exception
                when no_data_found then
                     goto write_loc_error;
               end;
            else                   /* restricted locator */
               begin
                 select 'restricted loc exists'
                   into dummy
                   from mtl_item_locations loc,
                        mtl_secondary_locators item
                  where loc.inventory_location_id = c1rec.CLI
                    and loc.organization_id = c1rec.OI
                    and loc.subinventory_code = c1rec.CS
                    and nvl(loc.disable_date,trunc(SYSDATE)+1) >
                        trunc(SYSDATE)
                    and loc.inventory_location_id = item.secondary_locator
                    and loc.organization_id = item.organization_id
                    and item.inventory_item_id = c1rec.AII;
               exception
                when no_data_found then
                     goto write_loc_error;
               end;
            end if;
      end if;

      if (org_loc not in (1,2,3,4) and c1rec.CLI is not null) then
           goto write_loc_error;
      end if;

/* Subinv level */
      if (org_loc = 4 and sub_loc_code = 1 and c1rec.CLI is not null) then
           goto write_loc_error;
      end if;

      if (org_loc = 4) then
           if ((sub_loc_code = 2) or (sub_loc_code = 3))
               and (c1rec.CLI is null) then
                 goto write_loc_error;
           end if;

           if ((sub_loc_code = 2) or (sub_loc_code = 3))
               and (c1rec.CLI is not null) then
                 if (r_loc = 2) then    /* non-restricted locator */
                     begin
                        select 'loc exists'
                          into dummy
                          from mtl_item_locations
                         where inventory_location_id = c1rec.CLI
                           and organization_id = c1rec.OI
                           and subinventory_code = c1rec.CS
                           and nvl(disable_date,trunc(SYSDATE)+1) >
                               trunc(SYSDATE);
                    exception
                       when no_data_found then
                          goto write_loc_error;
                    end;
                else                   /* restricted locator */
                    begin
                       select 'restricted loc exists'
                         into dummy
                         from mtl_item_locations loc,
                              mtl_secondary_locators item
                        where loc.inventory_location_id = c1rec.CLI
                         and loc.organization_id = c1rec.OI
                         and loc.subinventory_code = c1rec.CS
                         and nvl(loc.disable_date,trunc(SYSDATE)+1) >
                             trunc(SYSDATE)
                         and loc.inventory_location_id = item.secondary_locator
                         and loc.organization_id = item.organization_id
                         and item.inventory_item_id = c1rec.AII;
                   exception
                        when no_data_found then
                           goto write_loc_error;
                   end;
               end if;
          end if;

          if (sub_loc_code not in (1,2,3,5) and c1rec.CLI is not null) then
               goto write_loc_error;
          end if;
      end if;

/* Item level */
      if (org_loc = 4 and sub_loc_code = 5 and loc_ctl = 1
          and c1rec.CLI is not null) then
           goto write_loc_error;
      end if;

      if (org_loc = 4 and sub_loc_code = 5) then
           if ((loc_ctl = 2) or (loc_ctl = 3))
               and (c1rec.CLI is null) then
                 goto write_loc_error;
           end if;

           if ((loc_ctl = 2) or (loc_ctl = 3))
               and (c1rec.CLI is not null) then
                 if (r_loc = 2) then    /* non-restricted locator */
                     begin
                        select 'loc exists'
                          into dummy
                          from mtl_item_locations
                         where inventory_location_id = c1rec.CLI
                           and organization_id = c1rec.OI
                           and subinventory_code = c1rec.CS
                           and nvl(disable_date,trunc(SYSDATE)+1) >
                               trunc(SYSDATE);
                    exception
                       when no_data_found then
                          goto write_loc_error;
                    end;
                else                   /* restricted locator */
                    begin
                       select 'restricted loc exists'
                         into dummy
                         from mtl_item_locations loc,
                              mtl_secondary_locators item
                        where loc.inventory_location_id = c1rec.CLI
                         and loc.organization_id = c1rec.OI
                         and loc.subinventory_code = c1rec.CS
                         and nvl(loc.disable_date,trunc(SYSDATE)+1) >
                             trunc(SYSDATE)
                         and loc.inventory_location_id = item.secondary_locator
                         and loc.organization_id = item.organization_id
                         and item.inventory_item_id = c1rec.AII;
                   exception
                        when no_data_found then
                           goto write_loc_error;
                   end;
               end if;
          end if;

          if (loc_ctl not in (1,2,3) and c1rec.CLI is not null) then
               goto write_loc_error;
          end if;
      end if;

      goto update_comp;

<<write_loc_error>>
        ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => org_id,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => request_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_OP_ROUTINGS_INTERFACE',
                        msg_name => 'BOM_LOCATOR_INVALID',
                        err_text => err_text);
        update bom_op_routings_interface set
            process_flag = 3
        where transaction_id = c1rec.TI;

        if (ret_code <> 0) then
           return(ret_code);
        end if;
        goto continue_loop;

<<write_subinv_error>>
        ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => org_id,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => request_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_OP_ROUTINGS_INTERFACE',
                        msg_name => 'BOM_SUBINV_INVALID',
                        err_text => err_text);
        update bom_op_routings_interface set
            process_flag = 3
        where transaction_id = c1rec.TI;

        if (ret_code <> 0) then
           return(ret_code);
        end if;
        goto continue_loop;

<<update_comp>>
     stmt_num := 10;
     update bom_op_routings_interface
        set process_flag = 4
      where transaction_id = c1rec.TI;

<<continue_loop>>
    	NULL;
    end loop;
    commit;

    if (commit_cnt < (500 - 1)) then
       continue_loop := FALSE;
    end if;

end loop;

    return(0);

EXCEPTION
    when others then
	err_text := 'BOMPVALR(bmvrtgh-' || stmt_num || ') ' || substrb(SQLERRM,1,60);
	return(SQLCODE);
END bmvrtgh_validate_rtg_header;

/*------------------------ bmvopr_validate_operations -----------------------*/
/* NAME
    bmvopr_validate_operations - validate operation data
DESCRIPTION
    validate the operation data in the interface tables before loading
    into production tables
REQUIRES
    err_text 	out buffer to return error message
MODIFIES
    MTL_INTERFACE_ERRORS
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmvopr_validate_operations (
    org_id		NUMBER,
    all_org		NUMBER := 2,
    user_id		NUMBER,
    login_id		NUMBER,
    prog_appid		NUMBER,
    prog_id		NUMBER,
    request_id		NUMBER,
    err_text	 IN OUT NOCOPY 	VARCHAR2
)
    return INTEGER
IS
    ret_code		NUMBER;
    stmt_num		NUMBER := 0;
    commit_cnt  	NUMBER;
    dummy		VARCHAR2(40);
    continue_loop 	BOOLEAN := TRUE;
    cursor c1 is
	select operation_sequence_id OSI, routing_sequence_id RSI,
		department_id DI, count_point_type CPT,
		backflush_flag BF, option_dependent_flag ODF,
		minimum_transfer_quantity MTQ, standard_operation_id SOI,
		transaction_id TI, operation_lead_time_percent OLTP,
		to_char(effectivity_date,'YYYY/MM/DD HH24:MI:SS') ED,
		to_char(disable_date,'YYYY/MM/DD HH24:MI:SS') DD,
/** Changed for bug 2647027
		to_char(effectivity_date,'YYYY/MM/DD HH24:MI') ED,
		to_char(disable_date,'YYYY/MM/DD HH24:MI') DD,
**/		operation_seq_num OSN,
		organization_id OI
	from bom_op_sequences_interface
	where process_flag = 2
          and rownum < 500;

BEGIN
    while continue_loop loop
      commit_cnt := 0;
      for c1rec in c1 loop
/*
** verify operation seq num is not null
*/
        commit_cnt := commit_cnt + 1;
	stmt_num := 1;
        if (c1rec.OSN is null) then
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => NULL,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => request_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_OP_SEQUENCES_INTERFACE',
                        msg_name => 'BOM_OP_SEQ_NUM_MISSING',
                        err_text => err_text);
            update bom_op_sequences_interface set
                    process_flag = 3
            where transaction_id = c1rec.TI;

            if (ret_code <> 0) then
                return(ret_code);
            end if;
            goto continue_loop;
        end if;
/*
** verify for uniqueness of operation seq ID
*/
        stmt_num := 2;
    	ret_code :=bmvunop_verify_unique_op (
		op_seq_id => c1rec.OSI,
		exist_flag => 2,
		err_text => err_text);
	if (ret_code <> 0) then
	    ret_code := INVPUOPI.mtl_log_interface_err(
			org_id => NULL,
			user_id => user_id,
			login_id => login_id,
			prog_appid => prog_appid,
			prog_id => prog_id,
			req_id => request_id,
			trans_id => c1rec.TI,
			error_text => err_text,
			tbl_name => 'BOM_OP_SEQUENCES_INTERFACE',
			msg_name => 'BOM_OP_SEQ_ID_DUPLICATE',
			err_text => err_text);
	    update bom_op_sequences_interface set
		    process_flag = 3
	    where transaction_id = c1rec.TI;

	    if (ret_code <> 0) then
	        return(ret_code);
	    end if;
	    goto continue_loop;
	end if;
/*
** verify uniqueness of routing seq id, op seq num, and effectivity date
*/
    stmt_num := 3;
        ret_code := BOMPVALR.bmvdupop_verify_duplicate_op (
                rtg_seq_id => c1rec.RSI,
                eff_date => c1rec.ED,
                op_seq => c1rec.OSN,
                err_text => err_text);
        if (ret_code <> 0) then
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c1rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => request_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_OP_SEQUENCES_INTERFACE',
                        msg_name => 'BOM_OPERATION_DUPLICATE',
                        err_text => err_text);
            update bom_op_sequences_interface set
                    process_flag = 3
            where transaction_id = c1rec.TI;

            if (ret_code <> 0) then
                return(ret_code);
            end if;
            goto continue_loop;
        end if;
/*
** check for existence of routing
*/
        stmt_num := 4;
	ret_code :=bmvurtg_verify_routing(
		rtg_seq_id => c1rec.RSI,
		mode_type => 2,
		err_text => err_text);
	if (ret_code <> 0) then
	    ret_code := INVPUOPI.mtl_log_interface_err(
			org_id => NULL,
			user_id => user_id,
			login_id => login_id,
			prog_appid => prog_appid,
			prog_id => prog_id,
			req_id => request_id,
			trans_id => c1rec.TI,
			error_text => err_text,
			tbl_name => 'BOM_OP_SEQUENCES_INTERFACE',
			msg_name => 'BOM_RTG_SEQ_INVALID',
                        err_text => err_text);
	    update bom_op_sequences_interface set
		    process_flag = 3
	    where transaction_id = c1rec.TI;

	    if (ret_code <> 0) then
	        return(ret_code);
	    end if;
	    goto continue_loop;
	end if;
/*
** make sure there is no overlapping operations
*/
        stmt_num := 5;
	ret_code :=bmvovlap_verify_overlaps (
		rtg_id => c1rec.RSI,
		op_num => c1rec.OSN,
		eff_date => c1rec.ED,
		dis_date => c1rec.DD,
		err_text => err_text);
	if (ret_code <> 0) then
	    ret_code := INVPUOPI.mtl_log_interface_err(
			org_id => NULL,
			user_id => user_id,
			login_id => login_id,
			prog_appid => prog_appid,
			prog_id => prog_id,
			req_id => request_id,
			trans_id => c1rec.TI,
			error_text => err_text,
			tbl_name => 'BOM_OP_SEQUENCES_INTERFACE',
			msg_name => 'BOM_IMPL_OP_OVERLAP',
			err_text => err_text);
	    update bom_op_sequences_interface set
		    process_flag = 3
	    where transaction_id = c1rec.TI;

	    if (ret_code <> 0) then
	        return(ret_code);
	    end if;
	    goto continue_loop;
	end if;
/*
** verify department is valid and enabled
*/
        stmt_num := 6;
	ret_code := bmvdept_validate_department (
		org_id => c1rec.OI,
		dept_id => c1rec.DI,
		eff_date => c1rec.ED,
		err_text => err_text);
	if (ret_code <> 0) then
	    ret_code := INVPUOPI.mtl_log_interface_err(
			org_id => NULL,
			user_id => user_id,
			login_id => login_id,
			prog_appid => prog_appid,
			prog_id => prog_id,
			req_id => request_id,
			trans_id => c1rec.TI,
			error_text => err_text,
			tbl_name => 'BOM_OP_SEQUENCES_INTERFACE',
			msg_name => 'BOM_DEPT_ID_INVALID',
			err_text => err_text);
	    update bom_op_sequences_interface set
		    process_flag = 3
	    where transaction_id = c1rec.TI;

	    if (ret_code <> 0) then
	        return(ret_code);
	    end if;
	    goto continue_loop;
	end if;
/*
** verify that the routing does not have a common.  If so, it cannot have
** operations
*/
    stmt_num := 7;
        begin
            select 'Is pointing to a common'
            into dummy
            from bom_operational_routings
            where routing_sequence_id = c1rec.RSI
            and   common_routing_sequence_id <> c1rec.RSI;

            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c1rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => request_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_OP_SEQUENCES_INTERFACE',
                        msg_name => 'BOM_COMMON_OP',
                        err_text => err_text);
            update bom_op_sequences_interface set
                    process_flag = 3
            where transaction_id = c1rec.TI;

            if (ret_code <> 0) then
                return(ret_code);
            end if;
            goto continue_loop;
        exception
            when NO_DATA_FOUND then
                NULL;
        end;
        begin
            select 'Is pointing to a common'
            into dummy
            from bom_op_routings_interface
            where routing_sequence_id = c1rec.RSI
            and   process_flag = 4
            and   common_routing_sequence_id <> c1rec.RSI;

            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c1rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => request_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_OP_SEQUENCES_INTERFACE',
                        msg_name => 'BOM_COMMON_OP',
                        err_text => err_text);
            update bom_op_sequences_interface set
                    process_flag = 3
            where transaction_id = c1rec.TI;

            if (ret_code <> 0) then
                return(ret_code);
            end if;
            goto continue_loop;

        exception
            when NO_DATA_FOUND then
                NULL;
        end;
/*
** validate operation details
*/
        stmt_num := 8;
        err_text := NULL;

	if (c1rec.MTQ < 0) then
	    err_text := 'Minimum transfer quantity cannot be negative';
	end if;

        if (to_date(c1rec.ED,'YYYY/MM/DD HH24:MI') >
            nvl(to_date(c1rec.DD,'YYYY/MM/DD HH24:MI'),
                to_date(c1rec.ED,'YYYY/MM/DD HH24:MI') + 1) ) then
       err_text := 'Effective date must be less than or equal to disable date';
	end if;

	if (c1rec.CPT not in (1,2,3)) then
            err_text := 'COUNT_POINT_TYPE must be 1, 2, or 3';
       end if;

	if (c1rec.BF not in (1,2)) then
	    err_text := 'BACKFLUSH_FLAG must be 1 or 2';
	end if;

	if (c1rec.ODF not in (1,2)) then
	    err_text := 'OPTION_DEPENDENT_FLAG must be 1 or 2';
	end if;

	if (c1rec.CPT = 3 and c1rec.BF <>1) then
	    err_text := 'BACKFLUSH_FLAG must be Yes if COUNT_POINT_TYPE is No-direct charge';
	end if;

	if (c1rec.OLTP not between 0 and 100) then
	   err_text := 'OPERATION_LEAD_TIME_PERCENT must be between 0 and 100';
	end if;

        if (err_text is not null) then
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c1rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => request_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_OP_SEQUENCES_INTERFACE',
                        msg_name => 'BOM_OPERATION_ERROR',
                        err_text => err_text);
            update bom_op_sequences_interface set
                    process_flag = 3
            where transaction_id = c1rec.TI;

            if (ret_code <> 0) then
                return(ret_code);
            end if;
            goto continue_loop;
        end if;

	update bom_op_sequences_interface
           set process_flag = 4
	where transaction_id = c1rec.TI;

<<continue_loop>>
    	NULL;
    end loop;
    commit;

    if (commit_cnt < (500 - 1)) then
       continue_loop := FALSE;
    end if;

end loop;

    return(0);
EXCEPTION
    when others then
	err_text := 'BOMPVALR(bmvopr-' || stmt_num || ') ' || substrb(SQLERRM,1,60);
	return(SQLCODE);
END bmvopr_validate_operations;

/*------------------------ bmvres_validate_resources ------------------------*/
/* NAME
    bmvres_validate_resources - validates resources
DESCRIPTION
    validate the resource data in the interface tables before loading
    into production tables
    verify if resource exists in department
    verify if resource seq num is unique
    verify if resoruce is enabled
    can schedule resource if time class UOM and conversion exists to
    hour UOM
    cannot have more than one 'Prior' or 'Next' schedule per op
    negative usage rates only for non-schedulable resources
    non-negative assigned units
    activity must be valid and enabled
    cannot have PO move or PO receipt if dept does not have location
    or resource does not have purchase item
    only one PO Move per operation

REQUIRES
    err_text 	out buffer to return error message
MODIFIES
    MTL_INTERFACE_ERRORS
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmvres_validate_resources (
    org_id		NUMBER,
    all_org		NUMBER,
    user_id		NUMBER,
    login_id		NUMBER,
    prog_appid		NUMBER,
    prog_id		NUMBER,
    request_id		NUMBER,
    err_text	 IN OUT NOCOPY 	VARCHAR2
)
    return INTEGER
IS
    cursor c1 is
	select operation_sequence_id OSI, transaction_id TI,
		organization_id OI
	from bom_op_resources_interface
        where process_flag = 2
        and rownum < 500
        group by transaction_id, operation_sequence_id, organization_id;

    stmt_num	NUMBER := 0;
    ret_code 	NUMBER;
    dept_id	NUMBER;
    dummy_eff   DATE;
    dummy_code  VARCHAR2(3);
    res_cnt	NUMBER := 0;
    dummy	NUMBER;
    hr_uom_code VARCHAR2(30);
    hr_uom      VARCHAR2(3);
    hr_uom_class MTL_UNITS_OF_MEASURE.UOM_CLASS%TYPE;
    commit_cnt  NUMBER;
    continue_loop BOOLEAN := TRUE;
    total_recs          NUMBER;

BEGIN
/*
** check for null resource seq num
*/
select count(distinct operation_sequence_id)
  into total_recs
  from bom_op_resources_interface
 where process_flag = 2;

continue_loop := TRUE;
commit_cnt := 0;

while continue_loop loop
      for c1rec in c1 loop
        commit_cnt := commit_cnt + 1;
        select count(*)
          into dummy
          from bom_op_resources_interface
         where transaction_id = c1rec.TI
           and resource_seq_num is null;

      if (dummy = 0) then
        NULL;
      else
        ret_code := INVPUOPI.mtl_log_interface_err(
               org_id => org_id,
               user_id => user_id,
               login_id => login_id,
               prog_appid => prog_appid,
               prog_id => prog_id,
               req_id => request_id,
               trans_id => c1rec.TI,
               error_text => err_text,
               tbl_name => 'BOM_OP_RESOURCES_INTERFACE',
               msg_name => 'BOM_NULL_RESOURCE_SEQ_NUM',
               err_text => err_text);
         update bom_op_resources_interface set
             process_flag = 3
          where transaction_id = c1rec.TI;

         if (ret_code <> 0) then
            return(ret_code);
         end if;
         goto continue_loop;
       end if;

/*
** verify for existence of operation seq id
*/
        ret_code := bmvunop_verify_unique_op (
                op_seq_id => c1rec.OSI,
                exist_flag => 1,
                err_text => err_text);
        if (ret_code <> 0) then
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => NULL,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => request_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_OP_RESOURCES_INTERFACE',
                        msg_name => 'BOM_OP_SEQ_INVALID',
                        err_text => err_text);
            update bom_op_resources_interface set
                    process_flag = 3
            where transaction_id = c1rec.TI;

            if (ret_code <> 0) then
                return(ret_code);
            end if;
            goto continue_loop;
        end if;

/*
** get dept id and eff date.  first bom interface table and if op not
** exists then from prod table.
*/
	begin
	    select department_id, effectivity_date
	    into dept_id, dummy_eff
	    from bom_op_sequences_interface
	    where operation_sequence_id = c1rec.OSI
              and process_flag = 4;
	exception
	    when NO_DATA_FOUND then
	        select department_id, effectivity_date
	        into dept_id, dummy_eff
	        from bom_operation_sequences
	        where operation_sequence_id = c1rec.OSI;
	    when others then
		err_text := 'BOMPVALR(bmvres) ' || substrb(SQLERRM,1,60);
		return(SQLCODE);
	end;

/*
** validate resource exists and is enabled and belongs to dept
*/
	select count(*)
	into res_cnt
	from bom_op_resources_interface ori
	where ori.operation_sequence_id = c1rec.OSI
	and   ori.resource_id not in (select br.resource_id
		from bom_Resources br, bom_department_resources bdr
		where br.resource_id = ori.resource_id
		and   nvl(br.disable_date, dummy_eff + 1) > dummy_eff
		and   bdr.department_id = dept_id
		and   bdr.resource_id = ori.resource_id);
	if (res_cnt <> 0) then
	    ret_code := INVPUOPI.mtl_log_interface_err(
			org_id => NULL,
			user_id => user_id,
			login_id => login_id,
			prog_appid => prog_appid,
			prog_id => prog_id,
			req_id => request_id,
			trans_id => c1rec.TI,
			error_text => err_text,
			tbl_name => 'BOM_OP_RESOURCES_INTERFACE',
			msg_name => 'BOM_DEPT_RES_INVALID',
			err_text => err_text);
	    update bom_op_resources_interface set
		    process_flag = 3
	    where transaction_id = c1rec.TI;

	    if (ret_code <> 0) then
	        return(ret_code);
	    end if;
	    goto continue_loop;
	end if;

/*
** verify activity is enabled
*/
        select count(*)
        into   res_cnt
        from bom_op_resources_interface ori
        where operation_Sequence_id = c1rec.OSI
        and   activity_id is not null
        and   activity_id not in (select activity_id
                from cst_activities ca
                where ca.activity_id = ori.activity_id
                and   nvl(ca.organization_id, ori.organization_id)
                        = ori.organization_id
                and   nvl(ca.disable_date, dummy_eff + 1) > dummy_eff);
        if (res_cnt <> 0) then
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => NULL,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => request_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_OP_RESOURCES_INTERFACE',
                        msg_name => 'BOM_ACTIVITY_ID_INVALID',
                        err_text => err_text);
            update bom_op_resources_interface set
                process_flag = 3
            where transaction_id = c1rec.TI;

            if (ret_code <> 0) then
                return(ret_code);
            end if;
            goto continue_loop;
        end if;
/*
**  check for duplicate resource seq num/operation sequence id
*/
        ret_code := bmvunres_verify_unique_res (
                trans_id => c1rec.TI,
                err_text => err_text);
        if (ret_code <> 0) then
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => NULL,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => request_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_OP_RESOURCES_INTERFACE',
                        msg_name => 'BOM_DUPLICATE_RES_NUM',
                        err_text => err_text);
            update bom_op_resources_interface set
                    process_flag = 3
            where transaction_id = c1rec.TI;

            if (ret_code <> 0) then
                return(ret_code);
            end if;
            goto continue_loop;
        end if;

/*
** Schedule must be No if any one of the following are true:
** 1) res uom = currency code 2) res uom class <> hour uom class
** 3) no conversion between resource uom and hour uom
*/
/*
** get value of profile BOM:HOUR_UOM_CODE
*/
    BOMPRFIL.bom_pr_get_profile(
		appl_short_name => 'BOM',
		profile_name => 'BOM:HOUR_UOM_CODE',
		user_id => user_id,
		resp_appl_id => prog_appid,
	    	resp_id => 702,
		profile_value => hr_uom_code,
		return_code => ret_code,
		return_message => err_text);
    if (ret_code <> 0) then
	return(ret_code);
    end if;

/*
** get the hour_uom class
*/
   hr_uom := ltrim(rtrim(hr_uom_code));

    select uom_class
	into hr_uom_class
	from mtl_units_of_measure
	where uom_code = hr_uom;

/* get currency code */
	select SUBSTRB(CURRENCY_CODE, 1, 3)
	  into dummy_code
	   from org_organization_definitions ood,
	        gl_sets_of_books gsb
	  where ood.organization_id = c1rec.OI
            and ood.set_of_books_id = gsb.set_of_books_id;

	select count(*)
	into res_cnt
	from bom_op_resources_interface ori, bom_resources br,
		mtl_units_of_measure uom
	where ori.operation_sequence_id = c1rec.OSI
	and   ori.schedule_flag = 1
	and   ori.resource_id = br.resource_id
        and   uom.uom_code = br.unit_of_measure
  	and  ((br.unit_of_measure = dummy_code)
              or
	      (uom.uom_class <> hr_uom_class)
	      or
 	      (not exists (select 'No conversion exists'
			from mtl_uom_conversions a,
			     mtl_uom_conversions b
			where a.uom_code = uom.uom_code
			and   a.uom_class = uom.uom_class
			and   a.inventory_item_id = 0
			and   nvl(a.disable_date, sysdate + 1) > sysdate
			and   b.uom_code = hr_uom
			and   b.inventory_item_id = 0
			and   b.uom_class = hr_uom_class ))
		);

	if (res_cnt > 0) then
	    ret_code := INVPUOPI.mtl_log_interface_err(
			org_id => NULL,
			user_id => user_id,
			login_id => login_id,
			prog_appid => prog_appid,
			prog_id => prog_id,
			req_id => request_id,
			trans_id => c1rec.TI,
			error_text => err_text,
			tbl_name => 'BOM_OP_RESOURCES_INTERFACE',
			msg_name => 'BOM_OP_RES_SCHED_NO',
			err_text => err_text);
	    update bom_op_resources_interface set
		process_flag = 3
	    where transaction_id = c1rec.TI;

	    if (ret_code <> 0) then
	        Return(ret_code);
	    end if;
	    goto continue_loop;
	end if;

/*
** cannot have more than one Next or Prior scheduled resource
** for an operation
*/
	ret_code := bmvrsch_verify_resource_sched (
		op_seq => c1rec.OSI,
		sched_type => 3,	/* Prior */
		err_text => err_text);
	if (ret_code <> 0) then
	    ret_code := INVPUOPI.mtl_log_interface_err(
			org_id => NULL,
			user_id => user_id,
			login_id => login_id,
			prog_appid => prog_appid,
			prog_id => prog_id,
			req_id => request_id,
			trans_id => c1rec.TI,
			error_text => err_text,
			tbl_name => 'BOM_OP_RESOURCES_INTERFACE',
			msg_name => 'BOM_OP_RES_PRIOR_ERROR',
			err_text => err_text);
	    update bom_op_resources_interface set
		process_flag = 3
	    where transaction_id = c1rec.TI;

	    if (ret_code <> 0) then
                return(ret_code);
	    end if;
	    goto continue_loop;
	end if;

	ret_code := bmvrsch_verify_resource_sched (
		op_seq => c1rec.OSI,
		sched_type => 4,	/* Next */
		err_text => err_text);
	if (ret_code <> 0) then
	    ret_code := INVPUOPI.mtl_log_interface_err(
			org_id => NULL,
			user_id => user_id,
			login_id => login_id,
			prog_appid => prog_appid,
			prog_id => prog_id,
			req_id => request_id,
			trans_id => c1rec.TI,
			error_text => err_text,
			tbl_name => 'BOM_OP_RESOURCES_INTERFACE',
			msg_name => 'BOM_OP_RES_NEXT_ERROR',
			err_text => err_text);
	    update bom_op_resources_interface set
		process_flag = 3
	    where transaction_id = c1rec.TI;

	    if (ret_code <> 0) then
	        return(ret_code);
	    end if;
	    goto continue_loop;
	end if;

/*
** cannot have negative usage rate if one of the following is true:
** 1) autocharge_type = 3 or 4     2) res uom class = hour_uom_class
*/
	select count(*)
	into res_cnt
	from bom_op_resources_interface bori
	where operation_sequence_id = c1rec.OSI
	and   process_flag <> 3 and process_flag <> 7
	and   usage_rate_or_amount < 0
        and   (autocharge_type in (3,4)
	      or
              (hr_uom_class in
         	      (select uom_class
                         from mtl_units_of_measure mum,
			      bom_resources br
                        where br.resource_id = bori.resource_id
			  and mum.uom_code = br.unit_of_measure))
              );
	if (res_cnt <> 0) then
	    ret_code := INVPUOPI.mtl_log_interface_err(
			org_id => NULL,
			user_id => user_id,
			login_id => login_id,
			prog_appid => prog_appid,
			prog_id => prog_id,
			req_id => request_id,
			trans_id => c1rec.TI,
			error_text => err_text,
			tbl_name => 'BOM_OP_RESOURCES_INTERFACE',
			msg_name => 'BOM_NEGATIVE_USAGE_RATE',
			err_text => err_text);
	    update bom_op_resources_interface set
		process_flag = 3
	    where transaction_id = c1rec.TI;

	    if (ret_code <> 0) then
	        return(ret_code);
	    end if;
	    goto continue_loop;
	end if;

/*
** assigned units cannot be less than or equal to .00001
** if resource is available 24 hours then assigned units must be 1
** (verified in ASSIGN)
*/
	select count(*)
	into res_cnt
	from bom_op_resources_interface ori
	where operation_sequence_id = c1rec.OSI
	and   assigned_units <= .00001;

	if (res_cnt <> 0) then
	    ret_code := INVPUOPI.mtl_log_interface_err(
			org_id => NULL,
			user_id => user_id,
			login_id => login_id,
			prog_appid => prog_appid,
			prog_id => prog_id,
			req_id => request_id,
			trans_id => c1rec.TI,
			error_text => err_text,
			tbl_name => 'BOM_OP_RESOURCES_INTERFACE',
			msg_name => 'BOM_ASSIGNED_UNIT_ERROR',
			err_text => err_text);
	    update bom_op_resources_interface set
		process_flag = 3
	    where transaction_id = c1rec.TI;

	    if (ret_code <> 0) then
	        return(ret_code);
	    end if;
	    goto continue_loop;
	end if;

/*
** check if basis type,standard rate flag, schedule flag
** and autocharge type are valid
*/
	select count(*)
	into res_cnt
	from bom_op_resources_interface ori
	where operation_sequence_id = c1rec.OSI
	and   ( (basis_type not in (1,2))
		or
		(standard_rate_flag not in (1, 2))
                or
		(schedule_flag not in (1,2,3,4))
		or
		(autocharge_type not in (1,2,3,4))
	      );
	if (res_cnt <> 0) then
	    ret_code := INVPUOPI.mtl_log_interface_err(
			org_id => NULL,
			user_id => user_id,
			login_id => login_id,
			prog_appid => prog_appid,
			prog_id => prog_id,
			req_id => request_id,
			trans_id => c1rec.TI,
			error_text => err_text,
			tbl_name => 'BOM_OP_RESOURCES_INTERFACE',
			msg_name => 'BOM_OP_RES_LOOKUP_ERROR',
			err_text => err_text);
	    update bom_op_resources_interface set
		process_flag = 3
	    where transaction_id = c1rec.TI;

	    if (ret_code <> 0) then
	        return(ret_code);
	    end if;
	    goto continue_loop;
	end if;
/*
** Only one PO move per operation
** Autocharge cannot be PO Move or PO Receipt if
** the department has no location
*/
	ret_code := BOMPVALR.bmvauto_verify_autocharge (
		op_seq => c1rec.OSI,
		dept_id => dept_id,
		err_text => err_text);
	if (ret_code <> 0) then
	    ret_code := INVPUOPI.mtl_log_interface_err(
			org_id => NULL,
			user_id => user_id,
			login_id => login_id,
			prog_appid => prog_appid,
			prog_id => prog_id,
			req_id => request_id,
			trans_id => c1rec.TI,
			error_text => err_text,
			tbl_name => 'BOM_OP_RESOURCES_INTERFACE',
			msg_name => 'BOM_AUTOCHARGE_INVALID',
			err_text => err_text);
	    update bom_op_resources_interface set
		process_flag = 3
	    where transaction_id = c1rec.TI;

	    if (ret_code <> 0) then
	        return(ret_code);
	    end if;
	    goto continue_loop;
	end if;

/* Check offset percent */
        select count(*)
        into res_cnt
        from bom_op_resources_interface ori
        where operation_sequence_id = c1rec.OSI
	  and resource_offset_percent not between 0 and 100
	  and resource_offset_percent is not null;

        if (res_cnt <> 0) then
	      ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => NULL,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => request_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_OP_RESOURCES_INTERFACE',
                        msg_name => 'BOM_OFFSET_PERCENT_INVALID',
                        err_text => err_text);
            update bom_op_resources_interface set
                process_flag = 3
            where transaction_id = c1rec.TI;

            if (ret_code <> 0) then
                return(ret_code);
            end if;
            goto continue_loop;
        end if;
/*
** Check usage rate and usage rate inverse -- Bug 7322996
*/
        select count(*)
        into res_cnt
        from bom_op_resources_interface ori
        where operation_sequence_id = c1rec.OSI
	  and round(usage_rate_or_amount,G_round_off_val) <>
              decode(usage_rate_or_amount_inverse,0,0,
                     round((1/usage_rate_or_amount_inverse),G_round_off_val)
                    );

        if (res_cnt <> 0) then
              ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => NULL,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => request_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_OP_RESOURCES_INTERFACE',
                        msg_name => 'BOM_USAGE_RATE_INVALID',
                        err_text => err_text);
            update bom_op_resources_interface set
                process_flag = 3
            where transaction_id = c1rec.TI;

            if (ret_code <> 0) then
                return(ret_code);
            end if;
            goto continue_loop;
        end if;

        update bom_op_resources_interface
           set process_flag = 4
         where transaction_id = c1rec.TI;

<<continue_loop>>
    	NULL;
    end loop;

    commit;

     if (commit_cnt < total_recs) then
        null;
     else
        continue_loop := FALSE;
     end if;

end loop;

return(0);
EXCEPTION
    when others then
	err_text := 'BOMPVALR(bmvres-' || stmt_num || ') ' || substrb(SQLERRM,1,60);
  	return(SQLCODE);
END bmvres_validate_resources;

/*---------------------- bmvunres_verify_unique_res -------------------------*/
/* NAME
    bmvunres_verify_unique_res - verify that the op resource is unique
DESCRIPTION
   verify that the op resource is unique in both prod and
   interface tables for any operation on a routing

REQUIRES
    trans_id    transaction_id
    err_text    IN OUT NOCOPY buffer to return error message
MODIFIES
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmvunres_verify_unique_res (
    trans_id            NUMBER,
    err_text    IN OUT NOCOPY     VARCHAR2
)
    return INTEGER
IS
    dummy       NUMBER;
    NOT_UNIQUE  EXCEPTION;
BEGIN
/*
** first check in prod tables
*/
    begin
        select 1
        into dummy
        from bom_operation_resources a, bom_op_resources_interface b
        where b.transaction_id = trans_id
        and   a.operation_sequence_id = b.operation_sequence_id
        and   a.resource_seq_num =
                b.resource_seq_num
        and rownum = 1;
        raise NOT_UNIQUE;
    exception
        when NO_DATA_FOUND then
            null;
        when NOT_UNIQUE then
            raise NOT_UNIQUE;
        when others then
            err_text := 'BOMPVALR(bmvunres) ' || substrb(SQLERRM,1,60);
            return(SQLCODE);
    end;

/*
** check in interface table
*/
    select count(*)
        into dummy
        from bom_op_resources_interface a
        where transaction_id = trans_id
        and   exists (select 'same resource'
                from bom_op_resources_interface b
                where b.transaction_id = trans_id
                and   b.rowid <> a.rowid
                and   b.resource_seq_num =
                        a.resource_seq_num
                and   b.process_flag <> 3
                and   b.process_flag <> 7)
        and   process_flag <> 3
        and   process_flag <> 7;

    if (dummy > 0) then
        raise NOT_UNIQUE;
    else
        return(0);
    end if;
exception
    when NOT_UNIQUE then
        err_text := 'BOMPVALR(bmvunres) ' ||'Duplicate resource seq nums';
        return(9999);
    when others then
        err_text := 'BOMPVALR(bmvunres) ' || substrb(SQLERRM,1,60);
        return(SQLCODE);
end bmvunres_verify_unique_res;

/*------------------------ bmvrtgrev_validate_rtg_rev -----------------------*/
/* NAME
   bmvrtgrev_validate_rtg_rev - validate the routing rev interface table
DESCRIPTION
   validate revs
        - ensure revs in ascending order
        - no duplicate revs
REQUIRES
    org_id      org id to validate
    all_org     all_org flag
    user_id     user id
    login_id    login id
    prog_appid  program application id
    prod_id     program id
    req_id      request id
    err_text    IN OUT NOCOPY buffer to return error message
MODIFIES
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmvrtgrev_validate_rtg_rev (
    org_id              NUMBER,
    all_org             NUMBER,
    user_id             NUMBER,
    login_id            NUMBER,
    prog_appid          NUMBER,
    prog_id             NUMBER,
    req_id              NUMBER,
    err_text    IN OUT NOCOPY  VARCHAR2
)
    return INTEGER
IS
    cursor c0 is
        select inventory_item_id AII, organization_id OI,
	       process_revision PR, transaction_id TI
        from mtl_rtg_item_revs_interface
        where process_flag = 2
          and rownum < 500;

    cursor c1 is
        select inventory_item_id AII, organization_id OI
        from mtl_rtg_item_revs_interface
        where process_flag = 99
          and rownum < 500
        group by organization_id, inventory_item_id;

    cursor c2 is
        select 'x'
          from mtl_rtg_item_revs_interface
         where process_flag = 99
        group by organization_id, inventory_item_id;

    ret_code    NUMBER;
    dummy	NUMBER;
    dummy_id	NUMBER;
    stmt_num	NUMBER;
    commit_cnt  NUMBER;
    dummy_rtg   NUMBER;
    continue_loop BOOLEAN := TRUE;
    total_recs  NUMBER;

BEGIN
/*
** Check if process revision is null
*/
    while continue_loop loop
      commit_cnt := 0;
      for c0rec in c0 loop
        commit_cnt := commit_cnt + 1;
	stmt_num := 1;
       	if (c0rec.PR is null) then
           ret_code := INVPUOPI.mtl_log_interface_err(
               org_id => org_id,
               user_id => user_id,
               login_id => login_id,
               prog_appid => prog_appid,
               prog_id => prog_id,
               req_id => req_id,
               trans_id => c0rec.TI,
               error_text => err_text,
               tbl_name => 'MTL_RTG_ITEM_REVS_INTERFACE',
               msg_name => 'BOM_NULL_RTG_REV',
               err_text => err_text);
         update mtl_rtg_item_revs_interface set
             process_flag = 3
          where transaction_id = c0rec.TI;

         if (ret_code <> 0) then
            return(ret_code);
         end if;
         goto continue_loop;
       end if;
/*
** Check for valid org id
*/
        stmt_num := 2;
        BEGIN
           select organization_id
             into dummy_id
            from mtl_parameters
           where organization_id = c0rec.OI;
        EXCEPTION
           when NO_DATA_FOUND then
              ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c0rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c0rec.TI,
                        error_text => err_text,
                        tbl_name => 'MTL_RTG_ITEM_REVS_INTERFACE',
                        msg_name => 'BOM_INVALID_ORG_ID',
                        err_text => err_text);
               update mtl_rtg_item_revs_interface set
                       process_flag = 3
               where transaction_id = c0rec.TI;
               if (ret_code <> 0) then
                   return(ret_code);
               end if;
               goto continue_loop;
        END;

/* Check if assembly item exists */
        stmt_num := 3;
        ret_code := BOMPVALB.bmvassyid_verify_assembly_id(
                org_id => c0rec.OI,
                assy_id => c0rec.AII,
                err_text => err_text);
        if (ret_code <> 0) then
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c0rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c0rec.TI,
                        error_text => err_text,
                        tbl_name => 'MTL_RTG_ITEM_REVS_INTERFACE',
                        msg_name => 'BOM_INV_ITEM_INVALID',
                        err_text => err_text);
            update mtl_rtg_item_revs_interface set
                    process_flag = 3
            where transaction_id = c0rec.TI;

            if (ret_code <> 0) then
                return(ret_code);
            end if;
            goto continue_loop;
        end if;
/*
** check if a valid routing exists for this revision
*/
     dummy_rtg := 0;

     select count(*)
       into dummy_rtg
      from bom_operational_routings
     where organization_id = c0rec.OI
       and assembly_item_id = c0rec.AII;

     if (dummy_rtg = 0) then
            select count(*)
	      into dummy_rtg
	      from bom_op_routings_interface
	     where process_flag = 4
	       and organization_id = c0rec.OI
               and assembly_item_id = c0rec.AII;

            if (dummy_rtg = 0) then
	       ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c0rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c0rec.TI,
                        error_text => err_text,
                        tbl_name => 'MTL_RTG_ITEM_REVS_INTERFACE',
                        msg_name => 'BOM_RTG_DOES_NOT_EXIST',
                        err_text => err_text);
               update mtl_rtg_item_revs_interface set
                    process_flag = 3
               where transaction_id = c0rec.TI;

               if (ret_code <> 0) then
                  return(ret_code);
               end if;
               goto continue_loop;
	   end if;
     end if;

     update mtl_rtg_item_revs_interface set
            process_flag = 99
      where transaction_id = c0rec.TI;

<<continue_loop>>
	NULL;
	end loop;
	commit;

    if (commit_cnt < (500 - 1)) then
       continue_loop := FALSE;
    end if;

end loop;

total_recs := 0;
for c2rec in c2 loop
    total_recs := total_recs + 1;
end loop;

continue_loop := TRUE;
commit_cnt := 0;

while continue_loop loop
      for c1rec in c1 loop
        commit_cnt := commit_cnt + 1;
        stmt_num := 4;
        ret_code := BOMPVALR.bmvrev_validate_rev (
                org_id => c1rec.OI,
                assy_id => c1rec.AII,
                user_id => user_id,
                login_id => login_id,
                prog_appid => prog_appid,
                prog_id => prog_id,
                req_id => req_id,
                err_text => err_text);
        if (ret_code <> 0) then
                return(ret_code);
        end if;

<<continue_loop>>
    NULL;
    end loop;

    commit;
     if (commit_cnt < total_recs) then
        null;
     else
        continue_loop := FALSE;
     end if;

end loop;

return(0);

EXCEPTION
    when others then
        err_text := 'BOMPVALR(bmvrtgrev)' || substrb(SQLERRM,1,60);
        return(SQLCODE);
END bmvrtgrev_validate_rtg_rev;

/*--------------------------- bmvrev_validate_rev ---------------------------*/
/* NAME
   bmvrev_validate_rev - validate routing rev
DESCRIPTION
   validate revs
        - ensure revs in ascending order
        - no duplicate revs
REQUIRES
    org_id              NUMBER,
    assy_id             NUMBER,
    err_text    IN OUT NOCOPY buffer to return error message
MODIFIES
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmvrev_validate_rev (
    org_id              NUMBER,
    assy_id             NUMBER,
    user_id             NUMBER,
    login_id            NUMBER,
    prog_appid          NUMBER,
    prog_id             NUMBER,
    req_id              NUMBER,
    err_text    IN OUT NOCOPY  VARCHAR2
)
    return INTEGER
IS
    cursor c1 is
        select process_revision PR, effectivity_date ED,
                transaction_id TI
        from mtl_rtg_item_revs_interface
        where organization_id = org_id
        and   inventory_item_id = assy_id
        and   process_flag = 99;
    ret_code            NUMBER;
    err_cnt             NUMBER;
    err_flag            NUMBER;
    stmt_num            NUMBER;
BEGIN
    for c1rec in c1 loop
        err_cnt := 0;
        stmt_num := 1;
/*
** check for ascending order and identical revs
*/
        select count(*)
          into err_cnt
          from mtl_rtg_item_revs_interface a
         where transaction_id <> c1rec.TI
           and   inventory_item_id = assy_id
           and   organization_id = org_id
           and   process_flag = 4
           and ( (process_revision = c1rec.PR)
                or
                 (effectivity_date > c1rec.ED
                  and process_revision < c1rec.PR)
                or
                 (effectivity_date < c1rec.ED
                  and process_revision > c1rec.PR)
                );

        if (err_cnt <> 0) then
            goto write_error;
        end if;

        stmt_num := 2;
        select count(*)
	    into err_cnt
            from mtl_rtg_item_revisions
            where inventory_item_id = assy_id
            and   organization_id = org_id
            and ( (process_revision = c1rec.PR)
                or
                  (effectivity_date > c1rec.ED
                   and process_revision < c1rec.PR)
                or
                  (effectivity_date < c1rec.ED
                   and process_revision > c1rec.PR)
                );

        if (err_cnt <> 0) then
            goto write_error;
        end if;

        stmt_num := 3;
        update mtl_rtg_item_revs_interface set
            process_flag = 4
        where transaction_id = c1rec.TI;
        goto continue_loop;

<<write_error>>
        ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => org_id,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'MTL_RTG_ITEM_REVS_INTERFACE',
                        msg_name => 'BOM_REV_INVALID',
                        err_text => err_text);
        update mtl_rtg_item_revs_interface set
            process_flag = 3
        where transaction_id = c1rec.TI;
<<continue_loop>>
        null;
    end loop;
    return(0);
exception
    when others then
        err_text := 'BOMPVALR(bmvrev(' || stmt_num || ') ' || substrb(SQLERRM,1,60);
        return(SQLCODE);
END bmvrev_validate_rev;


/*--------------------- bmvcmrtg_verify_common_routing ----------------------*/
/* NAME
    bmvcmrtg_verify_common_routing- verify common_routing
DESCRIPTION
    if routing is mfg then it cannot point to engineering routing
    Common routing's alt must be same as current routing's alt
    Common routing cannot have same assembly_item_id/org_id as current routing
    Common routing cannot reference a common routing

REQUIRES
    rtg_id	routing_sequence_id
    cmn_rtg_id  common routing_seqience_id
    rtg_type    routing_type
    err_text 	out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    9999 if invalid item
    SQLCODE if error
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmvcmrtg_verify_common_routing (
	rtg_id		NUMBER,
	cmn_rtg_id	NUMBER,
	rtg_type	NUMBER,
        item_id         NUMBER,
        org_id          NUMBER,
	alt_desg	VARCHAR2,
	err_text  IN OUT NOCOPY   VARCHAR2
)
    return INTEGER
IS
    cnt		NUMBER;

BEGIN
/*
** Common routing's alt must be same as current routing's alt
** Common routing cannot have same assembly_item_id as current routing
** Common routing must have the same org id as current routing
** Common routing must be mfg routing if current routing is a mfg routing
** Common routing cannot reference a common routing
*/
    begin
        select routing_sequence_id
	into cnt
	from bom_operational_routings
	where routing_sequence_id = cmn_rtg_id
        and   nvl(alternate_routing_designator, 'NONE') =
                nvl(alt_desg, 'NONE')
        and   common_routing_sequence_id = routing_sequence_id
        and   assembly_item_id <> item_id
        and   organization_id = org_id
	and   ((rtg_type <> 1)
		or
  	       (rtg_type = 1
		and
		routing_type = 1
	       )
	      );
        goto check_ops;
    exception
	when NO_DATA_FOUND then
	    NULL;
	when others then
	    err_text := 'BOMPVALR(bmvcmrtg) ' || substrb(SQLERRM,1,60);
	    return(SQLCODE);
    end;

        select routing_sequence_id
        into cnt
        from bom_op_routings_interface
        where routing_sequence_id = cmn_rtg_id
        and   nvl(alternate_routing_designator, 'NONE') =
                nvl(alt_desg, 'NONE')
        and   common_routing_sequence_id = routing_sequence_id
        and   assembly_item_id <> item_id
        and   organization_id = org_id
        and   process_flag = 4
        and   ((rtg_type <> 1)
                or
               (rtg_type = 1
                and
                routing_type = 1
               )
              );
<<check_ops>>
    return(0);
EXCEPTION
    when NO_DATA_FOUND then
	    err_text := 'BOMPVALR(bmvmrtg):Invalid common routing';
	    return(9999);
    when others then
	err_text := 'BOMPVALR(bmcvmrtg) ' || substrb(SQLERRM,1,60);
	return(SQLCODE);
END bmvcmrtg_verify_common_routing;

/*------------------------ bmvrtg_verify_rtg_type ---------------------------*/
/* NAME
     bmvrtg_verify_rtg_type - verify routing type
DESCRIPTION
     a routing can be defined only if the bom_enabled_flag = 'Y' and
     bom_item_type <> 3 (ie not a planning item).  Also verifies
     if routing_type = mfg, then item must also be mfg

REQUIRES
    rtg_type    routing_type
    org_id	organization_id
    assy_id	assembly_item_id
    err_text 	out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    9999 if invalid item
    SQLCODE if error
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmvrtg_verify_rtg_type (
	org_id		NUMBER,
	assy_id		NUMBER,
	rtg_type	NUMBER,
	err_text  IN OUT NOCOPY   VARCHAR2
)
    return INTEGER
IS
    cnt 	NUMBER := 0;
BEGIN
    select 1
	into cnt
	from mtl_system_items
	where organization_id = org_id
	and   inventory_item_id = assy_id
	and   bom_item_type <> 3
	and   bom_enabled_flag = 'Y'
	and   pick_components_flag = 'N'
	and   ((rtg_type = 2)
		or
	       (rtg_type = 1
		and
		eng_item_flag = 'N')
	      );
    return(0);

EXCEPTION
    when NO_DATA_FOUND then
	err_text := 'BOMPVALR(bmvrtg):Invalid routing type or item attribute';
	return(9999);
    when others then
	err_text := 'BOMPVALR(bmvrtg) ' || substrb(SQLERRM,1,60);
    	return(SQLCODE);

END bmvrtg_verify_rtg_type;

/*------------------------- bmvurtg_verify_routing --------------------------*/
/* NAME
    bmvurtg_verify_routing - verify for uniqueness or existence of routing
	sequence id
DESCRIPTION
    verifies if the given routing sequence id is unique in prod and
	interface tables

REQUIRES
    rtg_sq_id   routing_sequecne_id
    mode_type	1 - verify uniqueness of routing
		2 - verify existence of routing
    err_text 	out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    count of routings with same routing_sequence_id if any found
    SQLCODE if error
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmvurtg_verify_routing (
	rtg_seq_id 	NUMBER,
	mode_type	NUMBER,
	err_text   IN OUT NOCOPY  VARCHAR2
)
    return INTEGER
IS
    cnt		NUMBER := 0;
    NOT_UNIQUE  EXCEPTION;
BEGIN

/*
** first check in production tables
*/
    begin
    	select routing_sequence_id
	into cnt
	from bom_operational_routings
	where routing_sequence_id = rtg_seq_id;
	if (mode_type = 2) then
	    return(0);
	else
	    raise NOT_UNIQUE;
	end if;
    exception
	when NO_DATA_FOUND then
	    NULL;
        when NOT_UNIQUE then
            raise NOT_UNIQUE;
	when others then
	    err_text := 'BOMPVALR(bmvurtg) ' || substrb(SQLERRM,1,60);
	    return(SQLCODE);
    end;
/*
** check in interface table
*/
    select count(*)
	into cnt
	from bom_op_routings_interface
	where routing_sequence_id = rtg_seq_id
	and   process_flag = 4;

    if (cnt = 0) then
        if (mode_type = 1) then
            return(0);
        else
           raise NO_DATA_FOUND;
        end if;
    end if;

    if (cnt > 0) then
        if (mode_type = 1) then
            raise NOT_UNIQUE;
        else
           return(0);
        end if;
    end if;

EXCEPTION
    when NO_DATA_FOUND then
	err_text := substrb('BOMPVALR(bmvurtg): Routing does not exist  ' || SQLERRM,1,70);
	return(9999);
    when NOT_UNIQUE then
	err_text := 'BOMPVALR(bmvurtg) ' || 'Duplicate routing sequence id';
	return(9999);
    when others then
	err_text := 'BOMPVALR(bmvurtg) ' || substrb(SQLERRM,1,60);
    	return(SQLCODE);
END bmvurtg_verify_routing;

/*--------------------- bmvduprt_verify_duplicate_rtg ----------------------*/
/* NAME
    bmvduprt_verify_duplicate_rtg - verify if there is another routing
	with same alt.
DESCRIPTION
    Verifies in the production and interface tables if routing with
    same alt exists.  Also verifies for an alternate routing, if the
    primary already exists.

REQUIRES
    org_id	organization_id
    assy_id	assembly_item_id
    alt_Desg	alternate routing designator
    rtg_type    routing type
    err_text 	out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    cnt  if routing already exists
    9999 if primary does not exist
    SQLCODE if error
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmvduprt_verify_duplicate_rtg(
	org_id		NUMBER,
	assy_id		NUMBER,
	alt_desg  	VARCHAR2,
	rtg_type  	NUMBER,
	err_text  IN OUT NOCOPY 	VARCHAR2
)
    return INTEGER
IS
    cnt		NUMBER := 0;
    ALREADY_EXISTS EXCEPTION;
BEGIN
    begin
        select routing_sequence_id
	into cnt
	from bom_operational_routings
	where organization_id = org_id
	and   assembly_item_id = assy_id
	and   nvl(alternate_routing_designator, 'NONE') =
		nvl(alt_desg, 'NONE');
	raise ALREADY_EXISTS;
    exception
        when ALREADY_EXISTS then
          err_text := 'BOMPVALR(bmvduprt): Rtg already exists in production';
          return(cnt);
	when NO_DATA_FOUND then
	    NULL;
	when others then
	    err_text := 'BOMPVALR(bmvduprt) ' || substrb(SQLERRM,1,60);
	    return(SQLCODE);
    end;

    begin
        select routing_sequence_id
	into cnt
	from bom_op_routings_interface
	where organization_id = org_id
	and   assembly_item_id = assy_id
	and   nvl(alternate_routing_designator, 'NONE') =
		nvl(alt_desg, 'NONE')
        and   rownum = 1
	and   process_flag = 4;

	raise ALREADY_EXISTS;
    exception
        when ALREADY_EXISTS then
          err_text := 'BOMPVALR(bmvduprt): Rtg already exists in interface';
          return(cnt);
	when NO_DATA_FOUND then
	    NULL;
	when others then
	    err_text := 'BOMPVALR(bmvduprt) ' || substrb(SQLERRM,1,60);
	    return(SQLCODE);
    end;
/*
** for alternate routings, verify if primary exists (or will exist)
** Alternate mfg routings cannot have primary eng routings
*/
    if (alt_desg is not null) then
	begin
	    select routing_sequence_id
	    into cnt
	    from bom_operational_routings
	    where organization_id = org_id
	    and   assembly_item_id = assy_id
	    and   alternate_routing_designator is null
            and   ((rtg_type = 2)
                  or
                   (rtg_type =1 and routing_type = 1)
                  );
	    return(0);
	exception
	    when NO_DATA_FOUND then
	 	NULL;
	    when others then
		err_text := 'BOMPVALR(bmvduprt) ' || substrb(SQLERRM,1,60);
		return(SQLCODE);
	end;

	begin
	    select routing_sequence_id
	    into cnt
	    from bom_op_routings_interface
	    where organization_id = org_id
	    and   assembly_item_id = assy_id
	    and   alternate_routing_designator is null
            and   ((rtg_type = 2)
                  or
                   (rtg_type =1 and routing_type = 1)
                  )
            and   process_flag = 4
	    and   rownum = 1;
	exception
	    when NO_DATA_FOUND then
		err_text := 'BOMPVALR(bmvduprt): Valid primary does not exist';
		return(9999);
	    when others then
		err_text := 'BOMPVALR(bmvduprt) ' || substrb(SQLERRM,1,60);
		return(SQLCODE);
	end;
    end if;

    return(0);

EXCEPTION
    when others then
	err_text := 'BOMPVALR(bmvduprt) ' || substrb(SQLERRM,1,60);
    	return(SQLCODE);
END bmvduprt_verify_duplicate_rtg;

/*------------------------ bmvunop_verify_unique_op -------------------------*/
/* NAME
    bmvunop_verify_unique_op - verify if operation seq id is unique or exists
DESCRIPTION
    verify the uniqueness or existence of the operation_seq_id in prod and
    interface tables

REQUIRES
    op_seq_id   operation_sequence_id
    exist_flag  1 - check for existence
                2 - check for uniqueness
    err_text 	out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    cnt  if opeation already exists
    SQLCODE if error
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmvunop_verify_unique_op (
	op_seq_id	NUMBER,
	exist_flag	NUMBER,
	err_text   IN OUT NOCOPY  VARCHAR2
)
    return INTEGER
IS
    cnt 	NUMBER;
    NOT_UNIQUE       EXCEPTION;
BEGIN
/*
** first check in prod tables
*/
    begin
        select 1
	into cnt
	from bom_operation_sequences
	where operation_sequence_id = op_seq_id;
        if (exist_flag = 1) then
            return(0);
        else
            raise NOT_UNIQUE;
        end if;
    exception
	when NO_DATA_FOUND then
	    NULL;
        when NOT_UNIQUE then
            raise NOT_UNIQUE;
	when others then
	    err_text := 'BOMPVALR(bmvunop) ' || substrb(SQLERRM,1,60);
	    return(SQLCODE);
    end;
/*
** check in interface table
*/
    select count(*)
	into cnt
	from bom_op_sequences_interface
	where operation_sequence_id = op_seq_id
	and   process_flag = 4;

    if (cnt = 0) then
        if (exist_flag = 2) then
            return(0);
        else
           raise NO_DATA_FOUND;
        end if;
    end if;

    if (cnt > 0) then
        if (exist_flag = 2) then
            raise NOT_UNIQUE;
        else
           return(0);
        end if;
    end if;

EXCEPTION
    when NO_DATA_FOUND then
        err_text := substrb('BOMPVALR(bmvunop): Operation does not exist '|| SQLERRM,1,70);
	return(9999);
    when NOT_UNIQUE then
        err_text := 'BOMPVALR(bmvunop) ' ||'Duplicate op sequence ids';
        return(9999);
    when others then
	err_text := 'BOMPVALR(bmvunop) ' || substrb(SQLERRM,1,60);
	return (SQLCODE);
END bmvunop_verify_unique_op;

/*--------------------- bmvdupop_verify_duplicate_op ------------------------*/
/* NAME
    bmvdupop_verify_duplicate_op - verify if there is another operation
        with the same routing, effective date, and operation seq num.
DESCRIPTION
    Verifies in the production and interface tables if operation with
    the same routing, effective date, and operation seq num exists.

REQUIRES
    rtg_seq_id rtg sequence id
    eff_date    effectivity date
    op_seq      operation seq num
    err_text    IN OUT NOCOPY buffer to return error message
MODIFIES
RETURNS
    0 if successful
    cnt  if component already exists
    SQLCODE if error
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmvdupop_verify_duplicate_op(
        rtg_seq_id      NUMBER,
        eff_date        VARCHAR2,
        op_seq          NUMBER,
        err_text  IN OUT NOCOPY   VARCHAR2
)
    return INTEGER
IS
    cnt         NUMBER := 0;
    ALREADY_EXISTS EXCEPTION;
BEGIN
    begin
        select operation_sequence_id
        into cnt
        from bom_operation_sequences
        where routing_sequence_id = rtg_seq_id
        and   to_char(effectivity_date,'YYYY/MM/DD HH24:MI:SS') = eff_date  -- Changed for bug 2647027
--      and   to_char(effectivity_date,'YYYY/MM/DD HH24:MI') = eff_date
        and   operation_seq_num = op_seq;
        raise ALREADY_EXISTS;
    exception
        when ALREADY_EXISTS then
     err_text := 'BOMPVALR(bmvdupop): Operation already exists in production';
          return(cnt);
        when NO_DATA_FOUND then
            NULL;
        when others then
            err_text := 'BOMPVALR(bmvdupop) ' || substrb(SQLERRM,1,60);
            return(SQLCODE);
    end;

    begin
        select operation_sequence_id
        into cnt
        from bom_op_sequences_interface
        where routing_sequence_id = rtg_seq_id
        and   to_char(effectivity_date,'YYYY/MM/DD HH24:MI:SS') = eff_date  -- Changed for bug 2647027
--      and   to_char(effectivity_date,'YYYY/MM/DD HH24:MI') = eff_date
        and   operation_seq_num = op_seq
        and   rownum = 1
        and   process_flag = 4;

        raise ALREADY_EXISTS;
    exception
        when ALREADY_EXISTS then
      err_text := 'BOMPVALR(bmvdupop): Operation already exists in interface';
          return(cnt);
        when NO_DATA_FOUND then
            NULL;
        when others then
            err_text := 'BOMPVALR(bmvdupop) ' || substrb(SQLERRM,1,60);
            return(SQLCODE);
    end;
    return(0);

EXCEPTION
    when others then
        err_text := 'BOMPVALR(bmvdupop) ' || substrb(SQLERRM,1,60);
        return(SQLCODE);
END bmvdupop_verify_duplicate_op;

/*------------------------ bmvovlap_verify_overlaps -------------------------*/
/* NAME
    bmvovlap_verify_overlaps - verify operation overlaps
DESCRIPTION
    verifies if operation would cause overalpping effectivity

REQUIRES
    rtg_id	routing_sequence_id
    op_num	operation_seq_num
    eff_date	effectivity_date
    dis_date	disable date
    err_text 	out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    cnt  if opeation already exists
    SQLCODE if error
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmvovlap_verify_overlaps (
	rtg_id		NUMBER,
	op_num		NUMBER,
	eff_date	VARCHAR2,
	dis_date	VARCHAR2,
	err_text   IN OUT NOCOPY  VARCHAR2
)
    return INTEGER
IS
    cnt 	NUMBER := 0;
    OVERLAP     EXCEPTION;
BEGIN
/*
** first check in production tables
*/
        select count(*)
	into cnt
	from bom_operation_sequences
	where routing_sequence_id = rtg_id
	and   operation_seq_num = op_num
        and   ((dis_date is null
                and to_date(eff_date,'YYYY/MM/DD HH24:MI') <
                  nvl(disable_date, to_date(eff_date,'YYYY/MM/DD HH24:MI') +1))
              or
               (dis_date is not null
                and to_date(dis_date,'YYYY/MM/DD HH24:MI') > effectivity_date
                and to_date(eff_date,'YYYY/MM/DD HH24:MI') <
                   nvl(disable_date,to_date(eff_date,'YYYY/MM/DD HH24:MI') +1))
              );
    if (cnt <> 0) then
        raise OVERLAP;
    end if;
/*
** search in interface tables
*/
    select count(*)
	into cnt
	from bom_op_sequences_interface
	where routing_sequence_id = rtg_id
	and   operation_seq_num = op_num
        and   process_flag = 4
        and   ((dis_date is null
                and to_date(eff_date,'YYYY/MM/DD HH24:MI') <
                  nvl(disable_date, to_date(eff_date,'YYYY/MM/DD HH24:MI') +1))
              or
               (dis_date is not null
                and to_date(dis_date,'YYYY/MM/DD HH24:MI') > effectivity_date
                and to_date(eff_date,'YYYY/MM/DD HH24:MI') <
                   nvl(disable_date,to_date(eff_date,'YYYY/MM/DD HH24:MI') +1))
              );
    if (cnt <> 0) then
        raise OVERLAP;
    end if;

    return(0);

EXCEPTION
    when OVERLAP then
        err_text := 'Operation causes overlapping effectivity';
        return(9999);
    when others then
	err_text := 'BOMPVALR(bmvovlap)' || substrb(SQLERRM,1,60);
	return(SQLCODE);
END bmvovlap_verify_overlaps;

/*---------------------- bmvdept_validate_department  -----------------------*/
/* NAME
    bmvdept_validate_department - validates department id
DESCRIPTION
    verify if department is valid, in the same org and enabled

REQUIRES
    org_id	organization_id
    dept_id	return depratmetn id
    err_text 	out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmvdept_validate_department (
	org_id		NUMBER,
	dept_id	   	NUMBER,
        eff_date        VARCHAR2,
	err_text  IN OUT NOCOPY 	VARCHAR2
)
    return INTEGER
IS
    dummy	VARCHAR2(20);
BEGIN
   select 'x'
     into dummy
     from bom_departments
   where organization_id = org_id
    and   department_id = dept_id
    and   nvl(DISABLE_DATE, to_date(eff_date,'YYYY/MM/DD HH24:MI') +1) >
              to_date(eff_date,'YYYY/MM/DD HH24:MI');

    return(0);
EXCEPTION
    when NO_DATA_FOUND then
	err_text := 'BOMPVALR(bmvdept):Invalid department';
	return(SQLCODE);
    when others then
	err_text := 'BOMPVALR(bmvdept)' || substrb(SQLERRM,1,60);
	return(SQLCODE);
END bmvdept_validate_department;

/*-------------------- bmvrsch_verify_resource_sched  -----------------------*/
/* NAME
    bmvrsch_verify_resource_sched - verify scheduled resources
DESCRIPTION
    only one resource can be Next or Prior scheduled per operation
REQUIRES
    op_seq	operation_sequence_id
    sched_type	3 - Prior
		4 - Next
    err_text 	out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmvrsch_verify_resource_sched (
	op_seq		NUMBER,
	sched_type 	NUMBER,
	err_text  IN OUT NOCOPY VARCHAR2
)
    return INTEGER
IS
    res_cnt		NUMBER;

BEGIN
	select count(*)
	into res_cnt
	from bom_op_resources_interface
	where operation_sequence_id = op_seq
	and   schedule_flag = sched_type
	and   process_flag <> 3 and process_flag <> 7;

	if (res_cnt > 1) then
	    err_text := 'BOMPVALR(bmvrsch):More than one Next or Prior scheduled resource';
	    return (9999);
	end if;
/*
** if only one resource was found then make sure none exist in the
** prod tables.
*/
    if (res_cnt = 1) then
	select count(*)
	into res_cnt
	from bom_operation_resources bor
	where operation_sequence_id = op_seq
	and   schedule_flag = sched_type;

	if (res_cnt <> 0) then
	    err_text := 'BOMPVALR(bmvrsch):More than one Next or Prior scheduled resource';
	    return (9999);
	end if;
    end if;

    return(0);
EXCEPTION
    when NO_DATA_FOUND then
	return(0);
    when others then
	err_text := 'BOMPVALR(bmvrsch)' || substrb(SQLERRM,1,60);
	return(SQLCODE);
END bmvrsch_verify_resource_sched;

/*---------------------- bmvauto_verify_autocharge --------------------------*/
/* NAME
    bmvauto_verify_autocharge - verify autocharge for resources
DESCRIPTION
    -If department has no location, autocharge cannot be PO Move or PO Receipt
    -Only one PO move per operation

REQUIRES
    op_seq	operation sequence id
    dept_id	department id
    err_text 	out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    9999 if failed
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION  bmvauto_verify_autocharge (
	op_seq		NUMBER,
	dept_id		NUMBER,
	err_text   IN OUT NOCOPY  VARCHAR2
)
    return INTEGER
IS
    cnt		NUMBER;
BEGIN
    select count(*)
	into cnt
	from bom_op_resources_interface ori
	where operation_sequence_id = op_seq
	and   autocharge_type in (3,4)
	and   not exists (select 'no dept loc or res pur item'
		    from bom_departments bd
		    where bd.department_id = dept_id
		    and   bd.location_id is not null);

    if (cnt <> 0) then
	err_text := 'BOMPVALR(bmvauto):Invalid autocharge type, no loc';
	return(9999);
    end if;

    select count(*)
    	into cnt
    	from bom_op_resources_interface ori
	where operation_sequence_id = op_seq
	and autocharge_type = 4
        and process_flag <> 3 and process_flag <> 7;
    if (cnt > 1) then
	err_text := 'BOMPVALR(bmvauto):Invalid autocharge type, too many';
	return(9999);
    end if;

    if (cnt = 1) then
	select count(*)
	into cnt
	from bom_operation_resources
	where operation_sequence_id = op_seq
	and   autocharge_type = 4;
	if (cnt > 0) then
	    err_text := 'BOMPVALR(bmvauto):Invalid autocharge type, too many';
	    return(9999);
    	end if;
    end if;

    return (0);

EXCEPTION
    when others then
	err_text := 'BOMPVALR(bmvauto)' || substrb(SQLERRM,1,60);
	return (SQLCODE);
END bmvauto_verify_autocharge;

END BOMPVALR;

/
