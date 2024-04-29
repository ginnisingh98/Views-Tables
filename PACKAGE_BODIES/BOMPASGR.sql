--------------------------------------------------------
--  DDL for Package Body BOMPASGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOMPASGR" as
/* $Header: BOMASGRB.pls 115.7 2002/10/31 07:19:39 djebar ship $ */
/*==========================================================================+
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMASGRB.pls                                               |
| DESCRIPTION  : This package contains functions used to assign routing     |
| 		 data in the interface tables                               |
| Parameters:	org_id		organization_id                             |
|		all_org		process all orgs or just current org        |
|				1 - all orgs                                |
|				2 - only org_id                             |
|    		prog_appid      program application_id                      |
|    		prog_id  	program id                                  |
|    		req_id          request_id                                  |
|    		user_id		user id                                     |
|    		login_id	login id                                    |
| History:	                                                            |
|    09/28/93   Shreyas Shah	creation date                               |
|    11/05/93   Shreyas Shah    added all_org option                        |
|    05/03/94   Julie Maeyama   Update logic                                |
|                                                                           |
+===========================================================================+
-------------------------- bmartorg_assign_rtg_orgid ------------------------
NAME
    bmartorg_assign_rtg_orgid - assign organization_id to all routing tables
DESCRIPTION
    assign org id to all routing and its child tables

REQUIRES
    err_text 	out buffer to return error message
MODIFIES
    BOM_OP_ROUTINGS_INTERFACE
    BOM_OP_SEQUENCES_INTERFACE
    BOM_OP_RESOURCES_INTERFACE
    MTL_RTG_ITEM_REVS_INTERFACE
    MTL_INTERFACE_ERRORS
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
----------------------------------------------------------------------------*/
FUNCTION bmartorg_assign_rtg_orgid (
    err_text	IN OUT 	VARCHAR2
)
    return INTEGER

IS
    stmt_num            NUMBER;
BEGIN
    stmt_num := 1;
    loop
    update bom_op_routings_interface ori
	set organization_id = (select organization_id from
	    mtl_parameters a
	    where a.organization_code = ori.organization_code)
    where process_flag = 1
    and   organization_id is null
    and   organization_code is not null
    and   exists (select organization_code
		    from mtl_parameters b
 		   where b.organization_code = ori.organization_code)
    and   rownum < 2000;
    EXIT when SQL%NOTFOUND;
    commit;

    end loop;

    stmt_num := 2;
    loop
    update bom_op_sequences_interface ori
	set organization_id = (select organization_id from
	    mtl_parameters a
	    where a.organization_code = ori.organization_code)
    where process_flag = 1
    and   organization_id is null
    and   organization_code is not null
    and   exists (select organization_code
                    from mtl_parameters b
                   where b.organization_code = ori.organization_code)
    and   rownum < 2000;
    EXIT when SQL%NOTFOUND;
    commit;

    end loop;

    stmt_num := 3;
    loop
    update bom_op_resources_interface ori
	set organization_id = (select organization_id from
	    mtl_parameters a
	    where a.organization_code = ori.organization_code)
    where process_flag = 1
    and   organization_id is null
    and   organization_code is not null
    and   exists (select organization_code
                    from mtl_parameters b
                   where b.organization_code = ori.organization_code)
    and   rownum < 2000;
    EXIT when SQL%NOTFOUND;
    commit;

    end loop;

    stmt_num := 4;
    loop
    update mtl_rtg_item_revs_interface ori
	set organization_id = (select organization_id from
	    mtl_parameters a
	    where a.organization_code = ori.organization_code)
    where process_flag = 1
    and   organization_id is null
    and   organization_code is not null
    and   exists (select organization_code
                    from mtl_parameters b
                   where b.organization_code = ori.organization_code)
    and   rownum < 2000;
    EXIT when SQL%NOTFOUND;
    commit;

    end loop;

    return(0);
exception
    when others then
	err_text := 'BOMPASGR(bmartorg-'||stmt_num||') '|| substrb(SQLERRM,1,60);
  	return(SQLCODE);
end bmartorg_assign_rtg_orgid;

/*------------------------ bmasrrev_assign_rtg_revision -------------------*/
/* NAME
    bmasrrev_assign_rtg_revision - assign routing revision
DESCRIPTION
    assign defaults and various ids in the interface table
    MTL_RTG_ITEM_REVS_INTERFACE.  If any application error occurs, it
    inserts record into MTL_INTERFACE_ERRORS.

REQUIRES
    err_text 	out buffer to return error message
MODIFIES
    MTL_RTG_ITEM_REVS_INTERFACE
    MTL_INTERFACE_ERRORS
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmasrrev_assign_rtg_revision (
    org_id		NUMBER,
    all_org		NUMBER,
    user_id		NUMBER,
    login_id		NUMBER,
    prog_appid		NUMBER,
    prog_id		NUMBER,
    req_id		NUMBER,
    err_text  IN OUT 	VARCHAR2
)
    return INTEGER

IS
    stmt_num 	NUMBER := 0;
    ret_code	NUMBER;
    commit_cnt  NUMBER;
    continue_loop BOOLEAN := TRUE;
    CURSOR c1 is
	select organization_code OC, organization_id OI,
                process_revision PR,
		inventory_item_id III, inventory_item_number IIN,
		transaction_id TI, change_notice CN, ecn_initiation_date CID,
                implementation_date ID, effectivity_date ED
	from mtl_rtg_item_revs_interface
	where process_flag = 1
	and   (all_org = 1
		or
		(all_org = 2 and organization_id = org_id)
	      )
	and rownum < 500;

BEGIN
/*
** assign transaction ids to all rows first
*/
    loop
    update mtl_rtg_item_revs_interface
	set transaction_id = mtl_system_items_interface_s.nextval
    where transaction_id is null
    and   process_flag = 1
    and   rownum < 500;
    EXIT when SQL%NOTFOUND;
    commit;

    end loop;

    while continue_loop loop
      commit_cnt := 0;
      for c1rec in c1 loop
	commit_cnt := commit_cnt + 1;
	stmt_num := 1;
	if  (c1rec.OI is null) then
	    ret_code := INVPUOPI.mtl_log_interface_err(
			org_id => NULL,
			user_id => user_id,
			login_id => login_id,
			prog_appid => prog_appid,
			prog_id => prog_id,
			req_id => req_id,
			trans_id => c1rec.TI,
			error_text => err_text,
			tbl_name => 'MTL_RTG_ITEM_REVS_INTERFACE',
			msg_name => 'BOM_ORG_ID_MISSING',
			err_text => err_text);
	    update mtl_rtg_item_revs_interface set
		    process_flag = 3
	    where transaction_id = c1rec.TI;

	    goto continue_loop;
	end if;

	stmt_num := 2;
	if  (c1rec.III is null) then
	    ret_code := INVPUOPI.mtl_pr_parse_flex_name(
		org_id => c1rec.OI,
		flex_code => 'MSTK',
		flex_name => c1rec.IIN,
		flex_id => c1rec.III,
		set_id => -1,
		err_text => err_text);
	    if (ret_code <> 0) then
		ret_code := INVPUOPI.mtl_log_interface_err(
			org_id => c1rec.OI,
			user_id => user_id,
			login_id => login_id,
			prog_appid => prog_appid,
			prog_id => prog_id,
			req_id => req_id,
			trans_id => c1rec.TI,
			error_text => err_text,
			tbl_name => 'MTL_RTG_ITEM_REVS_INTERFACE',
			msg_name => 'BOM_INV_ITEM_ID_MISSING',
			err_text => err_text);
		update mtl_rtg_item_revs_interface set
		    process_flag = 3
		where transaction_id = c1rec.TI;

		if (ret_code <> 0) then
		    return(ret_code);
		end if;
		goto continue_loop;
	    end if;
	end if;

	stmt_num := 3;

	update mtl_rtg_item_revs_interface set
	    organization_id = nvl(organization_id, c1rec.OI),
	    inventory_item_id = nvl(inventory_item_id, c1rec.III),
            process_revision = UPPER(c1rec.PR),
	    process_flag = 2,
	    last_update_date = nvl(last_update_date, sysdate),
	    last_updated_by = nvl(last_updated_by, user_id),
	    creation_date = nvl(creation_date, sysdate),
	    created_by = nvl(created_by, user_id),
	    last_update_login = nvl(last_update_login, user_id),
            request_id = nvl(request_id, req_id),
            program_application_id = nvl(program_application_id, prog_appid),
            program_id = nvl(program_id, prog_id),
            program_update_date = nvl(program_update_date, sysdate),
	    effectivity_date = nvl(effectivity_date, sysdate),
	    IMPLEMENTATION_DATE = nvl(effectivity_date, sysdate)
	where transaction_id = c1rec.TI;

	if (SQL%NOTFOUND) then
	    err_text := 'BOMPASGR(' || stmt_num || ')' || substrb(SQLERRM,1,60);
	    return(SQLCODE);
	end if;

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
	err_text := 'BOMPASGR(bmasrrev-'|| stmt_num ||') ' || substrb(SQLERRM,1,60);
	return(SQLCODE);

END bmasrrev_assign_rtg_revision;

/*------------------------ bmprtgh_assign_rtg_header ------------------------*/
/* NAME
    bmprtgh_assign_rtg_header - assign routing data
DESCRIPTION
    assign defaults and various ids in the interface table,
    BOM_OP_ROUTINGS_INTERFACE.  If any application error occurs, it
    inserts record into MTL_INTERFACE_ERRORS.

REQUIRES
    err_text 	out buffer to return error message
MODIFIES
    BOM_OP_ROUTINGS_INTERFACE
    MTL_INTERFACE_ERRORS
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmprtgh_assign_rtg_header (
    org_id		NUMBER,
    all_org		NUMBER,
    user_id		NUMBER,
    login_id		NUMBER,
    prog_appid		NUMBER,
    prog_id		NUMBER,
    req_id		NUMBER,
    err_text	IN OUT 	VARCHAR2
)
    return INTEGER

IS

    stmt_num		NUMBER;
    org_code		VARCHAR2(3);
    assy_id		NUMBER;
    proc_flag		NUMBER;
    ret_code		NUMBER;
    revs		NUMBER := 0;
    revs_int		NUMBER := 0;
    revs_prod		NUMBER := 0;
    dummy_alt		VARCHAR2(10);
    commit_cnt		NUMBER;
    continue_loop 	BOOLEAN := TRUE;

    cursor c1 is select
	organization_id OI, organization_code OC,
	assembly_item_id AII, assembly_item_number AIN,
	completion_locator_id CLI, location_name LN,
	common_assembly_item_id CAII, common_item_number CAIN,
        common_routing_sequence_id CRSI,
	alternate_routing_designator ARD, transaction_id TI,
	routing_sequence_id RSI, process_revision PR,
	creation_date CD, created_by CB, last_update_login LUL,
	last_update_date LUD, last_updated_by LUB
	from bom_op_routings_interface
	where process_flag = 1
	and   (all_org = 1
		or
		(all_org = 2 and organization_id = org_id)
	      )
	and rownum < 500;

    cursor c2 is select
	transaction_id TI, common_routing_sequence_id CRSI,
	assembly_item_id AII, routing_sequence_id RSI,
	common_assembly_item_id CAID, organization_id OI,
	alternate_routing_designator ARD
	from bom_op_routings_interface
	where process_flag = 99
	and   (all_org = 1
		or
		(all_org = 2 and organization_id = org_id)
	      )
	and rownum < 500;

BEGIN
/*
** assign transaction ids for every row first
*/
    stmt_num := 1;
    loop
    update bom_op_routings_interface ori
	set transaction_id = mtl_system_items_interface_s.nextval,
	    routing_sequence_id = nvl(routing_sequence_id,
			bom_operational_routings_s.nextval)
    where transaction_id is null
    and   process_flag = 1
    and   rownum < 500;
    EXIT when SQL%NOTFOUND;
    commit;

    end loop;

    while continue_loop loop
      commit_cnt := 0;
      for c1rec in c1 loop
        commit_cnt := commit_cnt + 1;
        stmt_num := 2;
	if (c1rec.OI is null) then
  	    ret_code := INVPUOPI.mtl_log_interface_err(
			org_id => NULL,
			user_id => user_id,
			login_id => login_id,
			prog_appid => prog_appid,
			prog_id => prog_id,
			req_id => req_id,
			trans_id => c1rec.TI,
			error_text => err_text,
			tbl_name => 'BOM_OP_ROUTINGS_INTERFACE',
			msg_name => 'BOM_ORG_ID_MISSING',
			err_text => err_text);
	    update bom_op_routings_interface set
		    process_flag = 3
	    where transaction_id = c1rec.TI;

	    goto continue_loop;
	end if;

/*
** set assembly item ids
*/
        stmt_num := 3;
	if (c1rec.AII is null) then
	    ret_code := INVPUOPI.mtl_pr_parse_flex_name(
		org_id => c1rec.OI,
		flex_code => 'MSTK',
		flex_name => c1rec.AIN,
		flex_id => c1rec.AII,
		set_id => -1,
		err_text => err_text);
	    if (ret_code <> 0) then
		ret_code := INVPUOPI.mtl_log_interface_err(
			org_id => NULL,
			user_id => user_id,
			login_id => login_id,
			prog_appid => prog_appid,
			prog_id => prog_id,
			req_id => req_id,
			trans_id => c1rec.TI,
			error_text => err_text,
			tbl_name => 'BOM_OP_ROUTINGS_INTERFACE',
			msg_name => 'BOM_ASSY_ITEM_MISSING',
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
** set locator id
*/
        stmt_num := 4;
	if (c1rec.CLI is null and c1rec.LN is not null) then
	    ret_code := INVPUOPI.mtl_pr_parse_flex_name(
		org_id => c1rec.OI,
		flex_code => 'MTLL',
		flex_name => c1rec.LN,
		flex_id => c1rec.CLI,
		set_id => -1,
		err_text => err_text);
	    if (ret_code <> 0) then
		ret_code := INVPUOPI.mtl_log_interface_err(
			org_id => NULL,
			user_id => user_id,
			login_id => login_id,
			prog_appid => prog_appid,
			prog_id => prog_id,
			req_id => req_id,
			trans_id => c1rec.TI,
			error_text => err_text,
			tbl_name => 'BOM_OP_ROUTINGS_INTERFACE',
			msg_name => 'BOM_LOCATION_NAME_INVALID',
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
** set common assembly item ids
*/
        stmt_num := 5;
	if (c1rec.CAII is null and c1rec.CAIN is not null and
            c1rec.CRSI is null) then
	    ret_code := INVPUOPI.mtl_pr_parse_flex_name(
		org_id => c1rec.OI,
		flex_code => 'MSTK',
		flex_name => c1rec.CAIN,
		flex_id => c1rec.CAII,
		set_id => -1,
		err_text => err_text);
	    if (ret_code <> 0) then
		ret_code := INVPUOPI.mtl_log_interface_err(
			org_id => NULL,
			user_id => user_id,
			login_id => login_id,
			prog_appid => prog_appid,
			prog_id => prog_id,
			req_id => req_id,
			trans_id => c1rec.TI,
			error_text => err_text,
			tbl_name => 'BOM_OP_ROUTINGS_INTERFACE',
			msg_name => 'BOM_CMN_ASSY_ITEM_INVALID',
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
** insert given process_revision
*/
        if (c1rec.PR is not null) then
            insert into mtl_rtg_item_revs_interface
                   (organization_id,
		    inventory_item_id,
		    process_revision,
                    process_flag,
		    last_update_date,
		    last_updated_by,
                    creation_date,
		    created_by,
		    last_update_login,
		    request_id,
		    program_application_id,
		    program_id,
		    program_update_date,
		    effectivity_date,
                    IMPLEMENTATION_DATE,
		    transaction_id)
            values (c1rec.OI,
		    c1rec.AII,
		    UPPER(c1rec.PR),
		    2,
		    nvl(c1rec.LUD,sysdate),
		    nvl(c1rec.LUB,user_id),
                    nvl(c1rec.CD,sysdate),
		    nvl(c1rec.CB,user_id),
                    nvl(c1rec.LUL, user_id),
                    req_id,
                    prog_appid,
                    prog_id,
                    sysdate,
		    sysdate,
	 	    sysdate,
		    mtl_system_items_interface_s.nextval);
	    goto update_rtg;
        else
	    select starting_revision into c1rec.PR
		from mtl_parameters
		where organization_id = c1rec.OI;
	end if;

/*
** check to see if a record exists in the revs interface table for this
** item/org combination
*/
	select count(process_revision) into revs_int
	  from    mtl_rtg_item_revs_interface
  	 where organization_id = c1rec.OI
	   and inventory_item_id = c1rec.AII
           and process_flag <> 3 and process_flag <> 7;
/*
** check to see if a record exists in the revs production table for this
** item/org combination
*/
        select count(process_revision) into revs_prod
          from    mtl_rtg_item_revisions
         where organization_id = c1rec.OI
           and inventory_item_id = c1rec.AII;

	revs := revs_int + revs_prod;
/*
** insert a record into the revs interface table because one does not exist
*/
	if (revs = 0) then
	    insert into mtl_rtg_item_revs_interface
                   (organization_id,
		    inventory_item_id,
		    process_revision,
		    process_flag,
		    last_update_date,
		    last_updated_by,
 		    creation_date,
		    created_by,
		    last_update_login,
		    request_id,
		    program_application_id,
		    program_id,
		    program_update_date,
		    effectivity_date,
                    IMPLEMENTATION_DATE,
		    transaction_id)
	    values (c1rec.OI,
		    c1rec.AII,
		    c1rec.PR,
		    2,
		    nvl(c1rec.LUD, sysdate),
		    nvl(c1rec.LUB, user_id),
                    nvl(c1rec.CD, sysdate),
		    nvl(c1rec.CB, user_id),
		    nvl(c1rec.LUL, user_id),
		    req_id,
                    prog_appid,
                    prog_id,
                    sysdate,
		    sysdate,
		    sysdate,
		    mtl_system_items_interface_s.nextval);
	end if;

/*
** update bom_op_routings_interface with the modified column values
*/
<<update_rtg>>
	stmt_num := 6;
	update bom_op_routings_interface
	set organization_id = nvl(organization_id, c1rec.OI),
	    assembly_item_id = nvl(assembly_item_id, c1rec.AII),
	    completion_locator_id = nvl(completion_locator_id, c1rec.CLI),
	    common_assembly_item_id = nvl(common_assembly_item_id, c1rec.CAII),
	    routing_type = nvl(routing_type, 1),
	    last_update_date = nvl(last_update_date, sysdate),
	    last_updated_by = nvl(last_updated_by, user_id),
	    creation_date = nvl(creation_date, sysdate),
	    created_by = nvl(created_by, user_id),
            last_update_login = nvl(last_update_login, user_id),
            request_id = nvl(request_id, req_id),
            program_application_id = nvl(program_application_id, prog_appid),
            program_id = nvl(program_id, prog_id),
            program_update_date = nvl(program_update_date, sysdate),
	    process_flag = 99
	where transaction_id = c1rec.TI;

	if (SQL%NOTFOUND) then
	    err_text := 'BOMPASGR(bmprtgh-' || stmt_num || ')' || substrb(SQLERRM,1,60);
	    return(SQLCODE);
	end if;

/*
** assign assembly_item_id to all child recs
*/
        stmt_num := 7;
	ret_code := bmasritm_assign_rtg_item_id(
    		org_id => c1rec.OI,
    		item_num => c1rec.AIN,
    		item_id => c1rec.AII,
    		err_text => err_text);
  	if (ret_code <> 0) then
	    return(ret_code);
	end if;
/*
** assign routing sequence id to all child tables
*/
        stmt_num := 8;
      	ret_code := bmasrtgid_assign_rtg_seq_id(
		org_id => c1rec.OI,
		assy_id => c1rec.AII,
		alt_desg => c1rec.ARD,
		rtg_id => c1rec.RSI,
		err_text => err_text);
  	if (ret_code <> 0) then
	    return(ret_code);
	end if;

<<continue_loop>>
    NULL;
    end loop;

    commit;

    if (commit_cnt < (500 - 1)) then
       continue_loop := FALSE;
    end if;

end loop;

    continue_loop := TRUE;
    while continue_loop loop
      commit_cnt := 0;
      for c2rec in c2 loop
	commit_cnt := commit_cnt + 1;
	stmt_num := 9;
	proc_flag := 2;
	if (c2rec.CRSI is null) then
	    if (c2rec.CAID is null) then
		c2rec.CRSI := c2rec.RSI;
	    else
		assy_id := c2rec.CAID;
         	ret_code := bmgrtsq_get_routing_sequence(
		    org_id => c2rec.OI,
		    item_id => assy_id,
		    alt_desg => c2rec.ARD,
		    routing_seq_id => c2rec.CRSI,
		    err_text => err_text);
	        if (ret_code <> 0) then
		   ret_code := INVPUOPI.mtl_log_interface_err(
			org_id => NULL,
			user_id => user_id,
			login_id => login_id,
			prog_appid => prog_appid,
			prog_id => prog_id,
			req_id => req_id,
			trans_id => c2rec.TI,
			error_text => err_text,
			tbl_name => 'BOM_OP_ROUTINGS_INTERFACE',
			msg_name => 'BOM_CMN_RTG_SEQ_INVALID',
			err_text => err_text);
		   proc_flag := 3;
	        end if;
	   end if;
        else
            ret_code := bmgrtin_get_rtg_info(
               org_id => c2rec.OI,
               item_id => assy_id,
               alt_desg => dummy_alt,
               rtg_seq_id => c2rec.CRSI,
               err_text => err_text);
            if (ret_code <> 0) then
                ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c2rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c2rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_OP_ROUTINGS_INTERFACE',
                        msg_name => 'BOM_CMN_RTG_SEQ_INVALID',
                        err_text => err_text);
                proc_flag := 3;
            end if;
        end if;
        if (c2rec.CRSI = c2rec.RSI) then
            assy_id := NULL;
        end if;

	stmt_num := 8;
        update bom_op_routings_interface set
	    process_flag = proc_flag,
	    common_routing_sequence_id = c2rec.CRSI,
            common_assembly_item_id = assy_id
        where transaction_id = c2rec.TI;

        if (ret_code <> 0) then
	    return(ret_code);
        end if;

    end loop;

    commit;

    if (commit_cnt < (500 - 1)) then
       continue_loop := FALSE;
    end if;

end loop;

    return(0);
EXCEPTION
    when others then
	err_text := 'BOMPASGR(bmprtgh-' || stmt_num  || ') ' || substrb(SQLERRM,1,60);
	return(SQLCODE);
END bmprtgh_assign_rtg_header;

/*------------------------ bmasopd_assign_operation_data --------------------*/
/* NAME
    bmasopd_assign_operation_data - assign operation data
DESCRIPTION
    assign defaults and various ids in the interface table
    BOM_OP_SEQUENCES_INTERFACE.  If any application error occurs, it
    inserts record into MTL_INTERFACE_ERRORS.

REQUIRES
    err_text 	out buffer to return error message
MODIFIES
    BOM_OP_SEQUENCES_INTERFACE
    MTL_INTERFACE_ERRORS
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmasopd_assign_operation_data (
    org_id		NUMBER,
    all_org		NUMBER,
    user_id		NUMBER,
    login_id		NUMBER,
    prog_appid		NUMBER,
    prog_id		NUMBER,
    req_id		NUMBER,
    err_text  IN OUT 	VARCHAR2
)
    return INTEGER

IS
    stmt_num 	NUMBER := 0;
    ret_code	NUMBER;
    std_dept_id NUMBER;
    std_min_qty NUMBER;
    std_cnt_pt  NUMBER;
    std_desc    VARCHAR2(240);
    std_bkflsh  NUMBER;
    std_opt     NUMBER;
    std_attcat  VARCHAR2(30);
    std_att1    VARCHAR2(150);
    std_att2    VARCHAR2(150);
    std_att3    VARCHAR2(150);
    std_att4    VARCHAR2(150);
    std_att5    VARCHAR2(150);
    std_att6    VARCHAR2(150);
    std_att7    VARCHAR2(150);
    std_att8    VARCHAR2(150);
    std_att9    VARCHAR2(150);
    std_att10   VARCHAR2(150);
    std_att11   VARCHAR2(150);
    std_att12   VARCHAR2(150);
    std_att13   VARCHAR2(150);
    std_att14   VARCHAR2(150);
    std_att15   VARCHAR2(150);
    continue_loop BOOLEAN := TRUE;

    CURSOR c1 is
	select organization_code OC, organization_id OI,
	        operation_sequence_id OSI,
		assembly_item_id AII, assembly_item_number AIN,
		alternate_routing_designator ARD, routing_sequence_id RSI,
		department_id DI, department_code DC,
		operation_code SOC, standard_operation_id SOI,
		transaction_id TI, operation_seq_num OSN,
                to_char(effectivity_date,'YYYY/MM/DD HH24:MI:SS') ED,  -- Changed for bug 2647027
--		to_char(effectivity_date,'YYYY/MM/DD HH24:MI') ED,
 		minimum_transfer_quantity MTQ, count_point_type CPT,
                operation_description OD, backflush_flag BF,
		option_dependent_flag ODF, attribute_category AC,
                attribute1 A1, attribute1 A2, attribute1 A3,
		attribute1 A4,attribute1 A5,attribute1 A6,attribute1 A7,
		attribute1 A8,attribute1 A9,attribute1 A10,attribute1 A11,
		attribute1 A12,attribute1 A13,attribute1 A14,attribute1 A15
	from bom_op_sequences_interface
	where process_flag = 1
	and   (all_org = 1
		or
		(all_org = 2 and organization_id = org_id)
	      )
	and rownum < 500;

    curr_org_code	VARCHAR2(3);
    commit_cnt  	NUMBER;

BEGIN
/*
** assign transaction ids to all rows first
*/
    loop
    update bom_op_sequences_interface
	set transaction_id = mtl_system_items_interface_s.nextval,
	    operation_sequence_id = nvl(operation_sequence_id,
			bom_operation_sequences_s.nextval)
    where transaction_id is null
    and   process_flag = 1
    and   rownum < 500;
    EXIT when SQL%NOTFOUND;
    commit;

    end loop;

    while continue_loop loop
      commit_cnt := 0;
      for c1rec in c1 loop
        commit_cnt := commit_cnt + 1;
	stmt_num := 1;
	if  (c1rec.OI is null and (c1rec.RSI is null or
             c1rec.DI is null or (c1rec.SOI is null and
                                    c1rec.SOC is not null))) then
	    ret_code := INVPUOPI.mtl_log_interface_err(
			org_id => NULL,
			user_id => user_id,
			login_id => login_id,
			prog_appid => prog_appid,
			prog_id => prog_id,
			req_id => req_id,
			trans_id => c1rec.TI,
			error_text => err_text,
			tbl_name => 'BOM_OP_SEQUENCES_INTERFACE',
			msg_name => 'BOM_ORG_ID_MISSING',
			err_text => err_text);
	    update bom_op_sequences_interface set
		    process_flag = 3
	    where transaction_id = c1rec.TI;

	    goto continue_loop;
	end if;

        stmt_num := 1.5;
        if  (c1rec.ED is null) then
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => NULL,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_OP_SEQUENCES_INTERFACE',
                        msg_name => 'BOM_EFF_DATE_MISSING',
                        err_text => err_text);
            update bom_op_sequences_interface set
                    process_flag = 3
            where transaction_id = c1rec.TI;

            goto continue_loop;
        end if;


	stmt_num := 2;
	if  (c1rec.AII is null and c1rec.RSI is null) then
	    ret_code := INVPUOPI.mtl_pr_parse_flex_name(
		org_id => c1rec.OI,
		flex_code => 'MSTK',
		flex_name => c1rec.AIN,
		flex_id => c1rec.AII,
		set_id => -1,
		err_text => err_text);
	    if (ret_code <> 0) then
		ret_code := INVPUOPI.mtl_log_interface_err(
			org_id => c1rec.OI,
			user_id => user_id,
			login_id => login_id,
			prog_appid => prog_appid,
			prog_id => prog_id,
			req_id => req_id,
			trans_id => c1rec.TI,
			error_text => err_text,
			tbl_name => 'BOM_OP_SEQUENCES_INTERFACE',
			msg_name => 'BOM_ASSY_ITEM_MISSING',
			err_text => err_text);
		update bom_op_sequences_interface set
		    process_flag = 3
		where transaction_id = c1rec.TI;

		if (ret_code <> 0) then
		    return(ret_code);
		end if;
		goto continue_loop;
	    end if;
	end if;

	stmt_num := 3;
	if (c1rec.RSI is null) then
	    ret_code := bmgrtsq_get_routing_sequence(
		org_id => c1rec.OI,
		item_id => c1rec.AII,
		alt_desg => c1rec.ARD,
		routing_seq_id => c1rec.RSI,
		err_text => err_text);
	    if (ret_code <> 0) then
		ret_code := INVPUOPI.mtl_log_interface_err(
			org_id => c1rec.OI,
			user_id => user_id,
			login_id => login_id,
			prog_appid => prog_appid,
			prog_id => prog_id,
			req_id => req_id,
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
        else                     /* Needed for verify */
            ret_code := bmgrtin_get_rtg_info(
               org_id => c1rec.OI,
               item_id => c1rec.AII,
               alt_desg => c1rec.ARD,
               rtg_seq_id => c1rec.RSI,
               err_text => err_text);
            if (ret_code <> 0) then
                ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => NULL,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
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
	end if;

	stmt_num := 4;
	if (c1rec.SOI is null and c1rec.SOC is not null) then
	    ret_code := bmgtstdop_get_stdop(
		org_id => c1rec.OI,
		stdop_code => c1rec.SOC,
		stdop_id => c1rec.SOI,
		err_text => err_text);
	    if (ret_code <> 0) then
		ret_code := INVPUOPI.mtl_log_interface_err(
			org_id => c1rec.OI,
			user_id => user_id,
			login_id => login_id,
			prog_appid => prog_appid,
			prog_id => prog_id,
			req_id => req_id,
			trans_id => c1rec.TI,
			error_text => err_text,
			tbl_name => 'BOM_OP_SEQUENCES_INTERFACE',
			msg_name => 'BOM_STD_OP_CODE_INVALID',
			err_text => err_text);
		update bom_op_sequences_interface set
		    process_flag = 3
		where transaction_id = c1rec.TI;

		if (ret_code <> 0) then
		    return(ret_code);
		end if;
		goto continue_loop;
	    end if;
	end if;

	stmt_num := 5;
	if (c1rec.DI is null and c1rec.SOI is null) then
	    ret_code := bmgtdep_get_department(
		org_id => c1rec.OI,
		dept_code => c1rec.DC,
		dept_id => c1rec.DI,
		err_text => err_text);
	    if (ret_code <> 0) then
		ret_code := INVPUOPI.mtl_log_interface_err(
			org_id => c1rec.OI,
			user_id => user_id,
			login_id => login_id,
			prog_appid => prog_appid,
			prog_id => prog_id,
			req_id => req_id,
			trans_id => c1rec.TI,
			error_text => err_text,
			tbl_name => 'BOM_OP_SEQUENCES_INTERFACE',
			msg_name => 'BOM_DEPT_CODE_INVALID',
			err_text => err_text);
		update bom_op_sequences_interface set
		    process_flag = 3
		where transaction_id = c1rec.TI;

		if (ret_code <> 0) then
		    return(ret_code);
		end if;
		goto continue_loop;
			    end if;
	end if;

/*
** Set standard operation values as defaults
*/
        stmt_num := 6;
        if (c1rec.SOI is not null) then
	begin
           select DEPARTMENT_ID, MINIMUM_TRANSFER_QUANTITY,
                  COUNT_POINT_TYPE, OPERATION_DESCRIPTION,
		  BACKFLUSH_FLAG, OPTION_DEPENDENT_FLAG,
		  ATTRIBUTE_CATEGORY, ATTRIBUTE1, ATTRIBUTE2,ATTRIBUTE3,
		  ATTRIBUTE4, ATTRIBUTE5, ATTRIBUTE6, ATTRIBUTE7,
		  ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10, ATTRIBUTE11,
		  ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15
             into std_dept_id, std_min_qty, std_cnt_pt, std_desc,
                  std_bkflsh, std_opt, std_attcat, std_att1, std_att2,
		  std_att3, std_att4, std_att5, std_att6, std_att7,
		  std_att8, std_att9, std_att10, std_att11, std_att12,
		  std_att13, std_att14, std_att15
             from bom_standard_operations
            where organization_id = c1rec.OI
              and standard_operation_id = c1rec.SOI;
    	exception
	      when NO_DATA_FOUND then
 		 ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c1rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_OP_SEQUENCES_INTERFACE',
                        msg_name => 'BOM_STD_OP_ID_INVALID',
                        err_text => err_text);
                update bom_op_sequences_interface set
                    process_flag = 3
                where transaction_id = c1rec.TI;

                if (ret_code <> 0) then
                    return(ret_code);
                end if;
                goto continue_loop;
	end;

            if (c1rec.DI is null) then
               c1rec.DI := std_dept_id;
            end if;

            if (c1rec.MTQ is null) then
               c1rec.MTQ := std_min_qty;
            end if;

            if (c1rec.CPT is null) then
               c1rec.CPT := std_cnt_pt;
            end if;

            if (c1rec.OD is null) then
               c1rec.OD := std_desc;
            end if;

            if (c1rec.BF is null) then
               c1rec.BF := std_bkflsh;
            end if;

            if (c1rec.ODF is null) then
               c1rec.ODF := std_opt;
            end if;

            if (c1rec.AC is null) then
               c1rec.AC := std_attcat;
            end if;

            if (c1rec.A1 is null) then
               c1rec.A1 := std_att1;
            end if;

            if (c1rec.A2 is null) then
               c1rec.A2 := std_att2;
            end if;

            if (c1rec.A3 is null) then
               c1rec.A3 := std_att3;
            end if;

            if (c1rec.A4 is null) then
               c1rec.A4 := std_att4;
            end if;

            if (c1rec.A5 is null) then
               c1rec.A5 := std_att5;
            end if;

            if (c1rec.A6 is null) then
               c1rec.A6 := std_att6;
            end if;

            if (c1rec.A7 is null) then
               c1rec.A7 := std_att7;
            end if;

            if (c1rec.A8 is null) then
               c1rec.A8 := std_att8;
            end if;

            if (c1rec.A9 is null) then
               c1rec.A9 := std_att9;
            end if;

            if (c1rec.A10 is null) then
               c1rec.A10 := std_att10;
            end if;

            if (c1rec.A11 is null) then
               c1rec.A11 := std_att11;
            end if;

            if (c1rec.A12 is null) then
               c1rec.A12 := std_att12;
            end if;

            if (c1rec.A13 is null) then
               c1rec.A13 := std_att13;
            end if;

            if (c1rec.A14 is null) then
               c1rec.A14 := std_att14;
            end if;

            if (c1rec.A15 is null) then
               c1rec.A15 := std_att1;
            end if;

     end if;


	stmt_num := 7;
	update bom_op_sequences_interface set
	    department_id = nvl(department_id, c1rec.DI),
	    organization_id = nvl(organization_id, c1rec.OI),
	    assembly_item_id = nvl(assembly_item_id, c1rec.AII),
	    process_flag = 2,
	    standard_operation_id = nvl(standard_operation_id,c1rec.SOI),
	    routing_sequence_id = nvl(routing_sequence_id, c1rec.RSI),
	    operation_sequence_id = nvl(operation_sequence_id, c1rec.OSI),
	    last_update_date = nvl(last_update_date, sysdate),
	    last_updated_by = nvl(last_updated_by, user_id),
	    creation_date = nvl(creation_date, sysdate),
	    created_by = nvl(created_by, user_id),
            last_update_login = nvl(last_update_login, user_id),
            request_id = nvl(request_id, req_id),
            program_application_id = nvl(program_application_id, prog_appid),
            program_id = nvl(program_id, prog_id),
            program_update_date = nvl(program_update_date, sysdate),
	    backflush_flag = nvl(backflush_flag, nvl(c1rec.BF,1)),
            count_point_type = nvl(count_point_type,nvl(c1rec.CPT, 1)),
            operation_description = nvl(operation_description,
                nvl(c1rec.OD,NULL)),
            option_dependent_flag =nvl(option_dependent_flag,nvl(c1rec.ODF,2)),
	    minimum_transfer_quantity = nvl(minimum_transfer_quantity,
                nvl(c1rec.MTQ, 0.00)),
	    attribute_category = nvl(attribute_category,nvl(c1rec.AC,NULL)),
	    attribute1 = nvl(attribute1, nvl(c1rec.A1, NULL)),
            attribute2 = nvl(attribute2, nvl(c1rec.A2, NULL)),
            attribute3 = nvl(attribute3, nvl(c1rec.A3, NULL)),
            attribute4 = nvl(attribute4, nvl(c1rec.A4, NULL)),
            attribute5 = nvl(attribute5, nvl(c1rec.A5, NULL)),
            attribute6 = nvl(attribute6, nvl(c1rec.A6, NULL)),
            attribute7 = nvl(attribute7, nvl(c1rec.A7, NULL)),
            attribute8 = nvl(attribute8, nvl(c1rec.A8, NULL)),
            attribute9 = nvl(attribute9, nvl(c1rec.A9, NULL)),
            attribute10 = nvl(attribute10, nvl(c1rec.A10, NULL)),
            attribute11 = nvl(attribute11, nvl(c1rec.A11, NULL)),
            attribute12 = nvl(attribute12, nvl(c1rec.A12, NULL)),
            attribute13 = nvl(attribute13, nvl(c1rec.A13, NULL)),
            attribute14 = nvl(attribute14, nvl(c1rec.A14, NULL)),
            attribute15 = nvl(attribute15, nvl(c1rec.A15, NULL))
	where transaction_id = c1rec.TI;

	if (SQL%NOTFOUND) then
	    err_text := substrb('BOMPASGR(bmasopd-' || stmt_num || ') ' || SQLERRM,1,240);
	    return(SQLCODE);
	end if;
/*
** assign resources for standard operation
*/
   if (c1rec.SOI is not null) then
    insert into bom_op_resources_interface (
        OPERATION_SEQUENCE_ID,
        RESOURCE_SEQ_NUM,
        RESOURCE_ID,
        ACTIVITY_ID,
        STANDARD_RATE_FLAG,
        ASSIGNED_UNITS,
        USAGE_RATE_OR_AMOUNT,
        USAGE_RATE_OR_AMOUNT_INVERSE,
        BASIS_TYPE,
        SCHEDULE_FLAG,
        AUTOCHARGE_TYPE,
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
        ATTRIBUTE15,
        ASSEMBLY_ITEM_ID,
        ALTERNATE_ROUTING_DESIGNATOR,
        ORGANIZATION_ID,
        OPERATION_SEQ_NUM,
        EFFECTIVITY_DATE,
        ROUTING_SEQUENCE_ID,
        ORGANIZATION_CODE,
        ASSEMBLY_ITEM_NUMBER,
        RESOURCE_CODE,
        ACTIVITY,
        TRANSACTION_ID,
        PROCESS_FLAG) select
        c1rec.OSI,
        RESOURCE_SEQ_NUM,
        RESOURCE_ID,
        ACTIVITY_ID,
        STANDARD_RATE_FLAG,
        ASSIGNED_UNITS,
        USAGE_RATE_OR_AMOUNT,
        USAGE_RATE_OR_AMOUNT_INVERSE,
        BASIS_TYPE,
        SCHEDULE_FLAG,
        AUTOCHARGE_TYPE,
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
        ATTRIBUTE15,
        NULL,
        NULL,
        c1rec.OI,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        1
        from bom_std_op_resources
        where standard_operation_id = c1rec.SOI;

  end if;

/*
** assign resources and instructions with op seq for this operation
*/
	ret_code := bmasopid_assign_op_seq_id(
		org_id => c1rec.OI,
		assy_id => c1rec.AII,
		alt_desg => c1rec.ARD,
		op_seq => c1rec.OSN,
		op_id => c1rec.OSI,
		eff_date => c1rec.ED,
		err_text => err_text);

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
	err_text := substrb('BOMPASGR(bmasopd-' || stmt_num || ') ' || SQLERRM,1,240);
	return(SQLCODE);

END bmasopd_assign_operation_data;

/*------------------------ bmasrsd_assign_resource_data --------------------*/
/* NAME
    bmasrsd_assign_resource_data - assign resource data
DESCRIPTION
    assign defaults and various ids in the interface table
    BOM_OP_RESOURCES_INTERFACE.  If any application error occurs, it
    inserts record into MTL_INTERFACE_ERRORS.

REQUIRES
    err_text 	out buffer to return error message
MODIFIES
    BOM_OP_RESOURCES_INTERFACE
    MTL_INTERFACE_ERRORS
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmasrsd_assign_resource_data (
    org_id		NUMBER,
    all_org		NUMBER,
    user_id		NUMBER,
    login_id		NUMBER,
    prog_appid		NUMBER,
    prog_id		NUMBER,
    req_id		NUMBER,
    err_text	IN OUT 	VARCHAR2
)
    return INTEGER
IS
    stmt_num 	NUMBER := 0;
    ret_code	NUMBER;
    dummy_dept  NUMBER;
    dummy_loc   NUMBER;
    dummy_24hours NUMBER;
    dummy_txn     NUMBER;
    dummy_org_id  NUMBER;
    commit_cnt    NUMBER;
    continue_loop BOOLEAN := TRUE;
    total_recs    NUMBER;

    CURSOR c1 is
	select  operation_sequence_id OSI,assembly_item_number AIN,
		assembly_item_id AII, organization_id OI,
		organization_code OC,
		alternate_routing_designator ARD, operation_seq_num OSN,
		to_char(effectivity_date, 'YYYY/MM/DD HH24:MI:SS') ED,  -- Changed for bug 2647027
--		to_char(effectivity_date, 'YYYY/MM/DD HH24:MI') ED,
                routing_sequence_id RSI,
		transaction_id TI
	from bom_op_resources_interface
	where process_flag = 1
        and   operation_sequence_id is null
	and   (all_org = 1
		or
		(all_org = 2 and organization_id = org_id)
	      )
	and rownum < 500;

    CURSOR c2 is
	select transaction_id TI, organization_id OI,
               operation_sequence_id OSI, resource_id RI, resource_code RC,
 	       activity_id AI, activity A, usage_rate_or_amount URA,
               usage_rate_or_amount_inverse URAI, assigned_units AU,
               basis_type BT, autocharge_type AUT, standard_rate_flag SRF
	from bom_op_Resources_interface
	where process_flag = 1
        and   operation_sequence_id is not null
	and   (all_org = 1
		or
		(all_org = 2 and organization_id = org_id)
	      )
	and rownum < 500;

    CURSOR c3 is
        select operation_sequence_id OSI
        from bom_op_Resources_interface
        where process_flag = 99
        and   (all_org = 1
                or
                (all_org = 2 and organization_id = org_id)
              )
	and rownum < 500
        group by operation_sequence_id;

BEGIN
/*
** first load all rows from operations interface into resource interface
*/

    insert into bom_op_resources_interface (
	OPERATION_SEQUENCE_ID,
	RESOURCE_SEQ_NUM,
	RESOURCE_ID,
	RESOURCE_CODE,
	ORGANIZATION_ID,
	PROCESS_FLAG,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	CREATION_DATE,
	CREATED_BY) select
	operation_sequence_id,
	10,
	resource_id1,
	resource_code1,
	organization_id,
	1,
	sysdate,
	user_id,
	sysdate,
	user_id
	from bom_op_sequences_interface
    	where process_flag = 2
	and   (all_org = 1
		or
		(all_org = 2 and organization_id = org_id)
	      )
	and (resource_id1 is not null or resource_code1 is not null);
    commit;

    stmt_num := 1;
    insert into bom_op_resources_interface (
	OPERATION_SEQUENCE_ID,
	RESOURCE_SEQ_NUM,
	RESOURCE_ID,
	RESOURCE_CODE,
	ORGANIZATION_ID,
	PROCESS_FLAG,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	CREATION_DATE,
	CREATED_BY) select
	operation_sequence_id,
	20,
	resource_id2,
	resource_code2,
	organization_id,
	1,
	sysdate,
	user_id,
	sysdate,
	user_id
	from bom_op_sequences_interface
    	where process_flag = 2
	and   (all_org = 1
		or
		(all_org = 2 and organization_id = org_id)
	      )
	and (resource_id2 is not null or resource_code2 is not null);
    commit;

    stmt_num := 2;
    insert into bom_op_resources_interface (
	OPERATION_SEQUENCE_ID,
	RESOURCE_SEQ_NUM,
	RESOURCE_ID,
	RESOURCE_CODE,
	ORGANIZATION_ID,
	PROCESS_FLAG,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	CREATION_DATE,
	CREATED_BY) select
	operation_sequence_id,
	30,
	resource_id3,
	resource_code3,
	organization_id,
	1,
	sysdate,
	user_id,
	sysdate,
	user_id
	from bom_op_sequences_interface
    	where process_flag = 2
	and   (all_org = 1
		or
		(all_org = 2 and organization_id = org_id)
	      )
	and (resource_id3 is not null or resource_code3 is not null);
    commit;
/*
**  assign transaction ids for every row
*/
    stmt_num := 3;
    loop
    update bom_op_resources_interface
       set transaction_id = mtl_system_items_interface_s.nextval
      where transaction_id is null
        and process_flag = 1
    and   rownum < 500;
    EXIT when SQL%NOTFOUND;
    commit;

    end loop;
/*
** Check if organization id is null
*/
    stmt_num := 4;
    while continue_loop loop
      commit_cnt := 0;
      for c1rec in c1 loop
        commit_cnt := commit_cnt + 1;
        if (c1rec.OI is null and c1rec.RSI is null) then
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => NULL,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_OP_RESOURCES_INTERFACE',
                        msg_name => 'BOM_ORG_ID_MISSING',
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
**  Set assembly item id
*/
    stmt_num := 5;
        if (c1rec.AII is null and c1rec.RSI is null) then
           ret_code := INVPUOPI.mtl_pr_parse_flex_name(
                org_id=> c1rec.OI,
                flex_code => 'MSTK',
                flex_name => c1rec.AIN,
                flex_id => c1rec.AII,
                set_id => -1,
                err_text => err_text);
            if (ret_code <> 0) then
                ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c1rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_OP_RESOURCES_INTERFACE',
                        msg_name => 'BOM_ASSY_ITEM_MISSING',
                        err_text => err_text);
                update bom_op_resources_interface set
                    process_flag = 3
                where transaction_id = c1rec.TI;

                if (ret_code <> 0) then
                    return(ret_code);
                end if;
                goto continue_loop;
            end if;
        end if;

/*
**  Get routing sequence id
*/
    stmt_num := 6;
     if (c1rec.RSI is null) then
        ret_code := bmgrtsq_get_routing_sequence(
                    org_id => c1rec.OI,
                    item_id => c1rec.AII,
                    alt_desg => c1rec.ARD,
                    routing_seq_id => c1rec.RSI,
                    err_text => err_text);
        if (ret_code <> 0) then
            ret_code := INVPUOPI.mtl_log_interface_err(
                      org_id => c1rec.OI,
                      user_id => user_id,
                      login_id => login_id,
                      prog_appid => prog_appid,
                      prog_id => prog_id,
                      req_id => req_id,
                      trans_id => c1rec.TI,
                      error_text => err_text,
                      tbl_name => 'BOM_OP_RESOURCES_INTERFACE',
                      msg_name => 'BOM_RTG_SEQ_INVALID',
                      err_text => err_text);
            update bom_op_resources_interface set
                   process_flag = 3
             where transaction_id = c1rec.TI;

            if (ret_code <> 0) then
                return(ret_code);
            end if;
            goto continue_loop;
        end if;
      end if;

/*
**  Get operation sequence id
*/
    stmt_num := 7;
        ret_code := bmgopsq_get_op_sequence(
                    rtg_seq_id => c1rec.RSI,
                    op_seq => c1rec.OSN,
                    eff_date => c1rec.ED,
                    op_seq_id => c1rec.OSI,
                    err_text => err_text);
        if (ret_code <> 0) then
            ret_code := INVPUOPI.mtl_log_interface_err(
                      org_id => NULL,
                      user_id => user_id,
                      login_id => login_id,
                      prog_appid => prog_appid,
                      prog_id => prog_id,
                      req_id => req_id,
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

        stmt_num := 8;
        update bom_op_resources_interface
           set operation_sequence_id = c1rec.OSI,
               assembly_item_id = c1rec.AII,
               routing_sequence_id = c1rec.RSI
         where transaction_id = c1rec.TI;

<<continue_loop>>
    NULL;
    end loop;
    commit;

    if (commit_cnt < (500 - 1)) then
       continue_loop := FALSE;
    end if;

end loop;

/*
** Get org id for all records. Needed for record verification.
*/
    continue_loop := TRUE;
    while continue_loop loop
      commit_cnt := 0;
      for c2rec in c2 loop
       begin
        commit_cnt := commit_cnt + 1;
	dummy_org_id := 0;

        select bor.organization_id
          into dummy_org_id
          from bom_operation_sequences bos,
               bom_operational_routings bor
         where operation_sequence_id = c2rec.OSI
           and bos.routing_sequence_id = bor.routing_sequence_id;
        goto get_resource;
     exception
        when NO_DATA_FOUND then
           NULL;
     end;

     begin
        select bori.organization_id
          into dummy_org_id
          from bom_op_sequences_interface bosi,
               bom_op_routings_interface bori
         where operation_sequence_id = c2rec.OSI
           and bosi.process_flag <>3 and bosi.process_flag <>7
           and bori.process_flag <>3 and bori.process_flag <>7
           and bosi.routing_sequence_id = bori.routing_sequence_id
           and rownum = 1;
        goto get_resource;
     exception
        when NO_DATA_FOUND then
           NULL;
     end;

     begin
        select bor.organization_id
          into dummy_org_id
          from bom_op_sequences_interface bosi,
               bom_operational_routings bor
         where operation_sequence_id = c2rec.OSI
           and bosi.process_flag <> 3 and bosi.process_flag <> 7
           and bosi.routing_sequence_id = bor.routing_sequence_id
	   and rownum = 1;
        goto get_resource;
     exception
        when NO_DATA_FOUND then
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => NULL,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c2rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_OP_RESOURCES_INTERFACE',
                        msg_name => 'BOM_OP_SEQ_INVALID',
                        err_text => err_text);
            update bom_op_resources_interface set
                    process_flag = 3
            where transaction_id = c2rec.TI;

            if (ret_code <> 0) then
                return(ret_code);
            end if;
            goto continue_loop2;
     end;
/*
** Get resource_id
*/
<<get_resource>>
    if (c2rec.OI is null) then
        c2rec.OI := dummy_org_id;
    end if;

    stmt_num := 10;
        if (c2rec.RI is null) then
           BEGIN
              select resource_id
                into c2rec.RI
                from bom_resources
               where resource_code = c2rec.RC
                 and organization_id = c2rec.OI;
           EXCEPTION
               when NO_DATA_FOUND then
                   ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => NULL,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c2rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_OP_RESOURCES_INTERFACE',
                        msg_name => 'BOM_RESOURCE_ID_MISSING',
                        err_text => err_text);
                   update bom_op_resources_interface set
                       process_flag = 3
                    where transaction_id = c2rec.TI;

                   if (ret_code <> 0) then
                     return(ret_code);
                   end if;
                   goto continue_loop2;
            END;
        end if;
/*
** Get activity_id
*/
    stmt_num := 11;
        if (c2rec.AI is null and c2rec.A is not null) then
           BEGIN
              select activity_id
                into c2rec.AI
                from cst_activities
               where activity = c2rec.A
                 and nvl(organization_id,c2rec.OI) = c2rec.OI;
           EXCEPTION
               when NO_DATA_FOUND then
                   ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => NULL,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c2rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_OP_RESOURCES_INTERFACE',
                        msg_name => 'BOM_ACTIVITY_INVALID',
                        err_text => err_text);
                   update bom_op_resources_interface set
                       process_flag = 3
                    where transaction_id = c2rec.TI;

                   if (ret_code <> 0) then
                     return(ret_code);
		   end if;
                   goto continue_loop2;
            END;
        end if;
/*
** Check usage rate or amount values
*/
    stmt_num := 12;
        if (c2rec.URA is null and c2rec.URAI is not null) then
           if (c2rec.URAI = 0) then
              c2rec.URA := 0;
           else
              c2rec.URA := 1/(c2rec.URAI);
           end if;
        end if;

        if (c2rec.URAI is null and c2rec.URA is not null) then
           if (c2rec.URA = 0) then
              c2rec.URAI := 0;
           else
              c2rec.URAI := 1/(c2rec.URA);
	   end if;
        end if;
/*
** Check if resource is available 24 hours
*/

    if (c2rec.AU is null) then
     	c2rec.AU := 1;
    end if;

    stmt_num := 13;
        BEGIN
           select department_id
             into dummy_dept
             from bom_operation_sequences
            where operation_sequence_id = c2rec.OSI;
           goto get_flag;
        EXCEPTION
           when NO_DATA_FOUND then
               NULL;
        END;

        BEGIN
           select department_id
             into dummy_dept
             from bom_op_sequences_interface
            where operation_sequence_id = c2rec.OSI
              and process_flag <>3 and process_flag <> 7
              and rownum = 1;

        EXCEPTION
           when NO_DATA_FOUND then
                   ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => NULL,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c2rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_OP_RESOURCES_INTERFACE',
                        msg_name => 'BOM_OP_SEQ_INVALID',
                        err_text => err_text);
                   update bom_op_resources_interface set
                       process_flag = 3
                    where transaction_id = c2rec.TI;

                   if (ret_code <> 0) then
                     return(ret_code);
                   end if;
                   goto continue_loop2;
        END;

<<get_flag>>
    stmt_num := 14;
        BEGIN
           select bdr.AVAILABLE_24_HOURS_FLAG, bd.location_id
             into dummy_24hours, dummy_loc
             from bom_department_resources bdr,
                  bom_departments bd
            where bdr.resource_id = c2rec.RI
              and bdr.department_id = dummy_dept
              and bdr.department_id = bd.department_id;

        if (dummy_24hours = 1) then
           c2rec.AU := 1;
        end if;

        EXCEPTION
            when NO_DATA_FOUND then
                   ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => NULL,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c2rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_OP_RESOURCES_INTERFACE',
                        msg_name => 'BOM_DEPT_RES_INVALID',
                        err_text => err_text);
                   update bom_op_resources_interface set
                       process_flag = 3
                    where transaction_id = c2rec.TI;

                   if (ret_code <> 0) then
                     return(ret_code);
                   end if;
                   goto continue_loop2;
        END;

/*
** Get Basis and Autocharge defaults
*/
    stmt_num := 16;
        select nvl(c2rec.BT,default_basis_type),
	       nvl(c2rec.AI, default_activity_id),
               nvl(c2rec.AUT,decode(dummy_loc, NULL,
                 decode(AUTOCHARGE_TYPE, NULL, 2, 3, 2, 4, 2,
                 AUTOCHARGE_TYPE), nvl(AUTOCHARGE_TYPE, 2))),
               nvl(c2rec.SRF, standard_rate_flag)
          into c2rec.BT, c2rec.AI, c2rec.AUT, c2rec.SRF
          from bom_resources
         where resource_id = c2rec.RI;

    stmt_num := 17;
	update bom_op_resources_interface set
		resource_id = c2rec.RI,
		organization_id = c2rec.OI,
                BASIS_TYPE = nvl(c2rec.BT,1),
		AUTOCHARGE_TYPE = c2rec.AUT,
                ACTIVITY_ID = c2rec.AI,
		STANDARD_RATE_FLAG = nvl(c2rec.SRF, 1),
	    	ASSIGNED_UNITS = c2rec.AU,
		USAGE_RATE_OR_AMOUNT = nvl(c2rec.URA,1),
		USAGE_RATE_OR_AMOUNT_INVERSE = nvl(c2rec.URAI,1),
		SCHEDULE_FLAG = nvl(schedule_flag, 2),
		PROCESS_FLAG = 99,
		last_update_date = sysdate,
		last_updated_by = user_id,
		creation_date = sysdate,
	 	created_by = user_id,
                last_update_login = nvl(last_update_login, user_id),
                request_id = nvl(request_id, req_id),
              program_application_id = nvl(program_application_id, prog_appid),
                program_id = nvl(program_id, prog_id),
                program_update_date = nvl(program_update_date, sysdate)
	where transaction_id = c2rec.TI;

<<continue_loop2>>
        NULL;
    end loop;

    commit;

    if (commit_cnt < (500 - 1)) then
       continue_loop := FALSE;
    end if;

end loop;

/*
** Set records with same operation_sequence_id with the same txn id
** for set processing
*/
select count(distinct operation_sequence_id)
  into total_recs
  from bom_op_resources_interface
 where process_flag = 99;

continue_loop := TRUE;
commit_cnt := 0;

while continue_loop loop
      for c3rec in c3 loop
        commit_cnt := commit_cnt + 1;
        select mtl_system_items_interface_s.nextval
          into dummy_txn
          from sys.dual;

        update bom_op_resources_interface
           set transaction_id = dummy_txn,
               process_flag = 2
         where operation_sequence_id = c3rec.OSI
           and process_flag = 99;

     end loop;

    commit;

     if (commit_cnt < total_recs) then
        null;
     else
        continue_loop := FALSE;
     end if;

end loop;

    return (0);
EXCEPTION
    when others then
	err_text := substrb('BOMPASGR(bmasrsd-'||stmt_num||') '|| SQLERRM,1,240);
	return(SQLCODE);
END bmasrsd_assign_resource_data;


/*----------------------- bmgrtsq_get_routing_sequence ----------------------*/
/* NAME
    bmgrtsq_get_routing_sequence - get routing sequence id
DESCRIPTION
    searches the prod table first adn then the interface table to
    determine the routing_sequence_id

REQUIRES
    org_id	organization_id
    item_id     assembly item id
    alt_desg    alternate_routing_designator
    routing_seq_id out parameter for routing sequence id
    err_text 	out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmgrtsq_get_routing_sequence (
    org_id 		NUMBER,
    item_id		NUMBER,
    alt_desg		VARCHAR2,
    routing_seq_id OUT	NUMBER,
    err_text	   OUT	VARCHAR2
)
    return INTEGER
IS
    rtg_seq_id		NUMBER;
BEGIN

    BEGIN
        select routing_sequence_id
	into rtg_seq_id
	from bom_operational_routings
	where organization_id = org_id
	and   assembly_item_id = item_id
	and   nvl(alternate_routing_designator, 'NONE') =
		nvl(alt_desg, 'NONE');
	routing_seq_id := rtg_seq_id;
	return(0);
    EXCEPTION
	when NO_DATA_FOUND then
	    NULL;
	when others then
	    err_text := 'BOMPAVRT ' || substrb(SQLERRM,1,240);
	    return(SQLCODE);
    END;

    select routing_sequence_id
	into rtg_seq_id
	from bom_op_routings_interface
	where organization_id = org_id
	and assembly_item_id  = item_id
	and nvl(alternate_routing_designator, 'NONE') =
	    nvl(alt_desg, 'NONE')
        and process_flag <> 3 and process_flag <> 7
        and rownum = 1;

    routing_seq_id := rtg_seq_id;
    return(0);

EXCEPTION
    when others then
	routing_seq_id := -1;
	err_text := 'BOMPAVRT ' || substrb(SQLERRM,1,240);
	return(SQLCODE);

END bmgrtsq_get_routing_sequence;


/*------------------------- bmgopsq_get_op_sequence -------------------------*/
/* NAME
    bmgopsq_get_op_sequence - get operation sequence id
DESCRIPTION
    searches the prod table first and then the interface table to
    determine the operation_sequence_id

REQUIRES
    rtg_seq_id      routing sequence id
    op_seq          operation_seq_num
    eff_date        effectivity_date
    op_seq_id   out operation_sequence_id
    err_text    out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmgopsq_get_op_sequence(
        rtg_seq_id      NUMBER,
        op_seq          NUMBER,
        eff_date        VARCHAR2,
        op_seq_id   OUT NUMBER,
        err_text    OUT VARCHAR2
)
    return INTEGER
IS
BEGIN

    BEGIN
        select operation_sequence_id
        into op_seq_id
        from bom_operation_sequences
        where routing_sequence_id = rtg_seq_id
        and   operation_seq_num = op_seq
        and   to_char(effectivity_date,'YYYY/MM/DD HH24:MI:SS') = eff_date;  -- Changed for bug 2647027
--      and   to_char(effectivity_date,'YYYY/MM/DD HH24:MI') = eff_date;
        return(0);
    EXCEPTION
        when NO_DATA_FOUND then
            NULL;
        when others then
            err_text := 'BOMPASGR(bmgopsq) ' || substrb(SQLERRM,1,240);
            return(SQLCODE);
    END;

    select operation_sequence_id
        into op_seq_id
        from bom_op_sequences_interface
        where routing_sequence_id = rtg_seq_id
        and   operation_seq_num = op_seq
        and   to_char(effectivity_date,'YYYY/MM/DD HH24:MI:SS') = eff_date  -- Changed for bug 2647027
--      and   to_char(effectivity_date,'YYYY/MM/DD HH24:MI') = eff_date
        and   process_flag <> 3 and process_flag <> 7
        and   rownum = 1;
    return(0);

EXCEPTION
    when NO_DATA_FOUND then
       err_text := 'BOMPASGR(bmgopsq): Operation does not exist';
       return(9999);
    when others then
        op_seq_id := -1;
        err_text := 'BOMPASGR(bmgopsq) ' || substrb(SQLERRM,1,240);
        return(SQLCODE);

END bmgopsq_get_op_sequence;


/*------------------------ bmasopid_assign_op_seq_id ------------------------*/
/* NAME
    bmasopid_assign_op_seq_id - assign operation_sequence_ids to
		child tables
DESCRIPTION
    assigns operation_seq_ids to child table for op resoruces
    and op instructions

REQUISTDOP
    org_id	organization_id
    assy_id	assembly_itEM_ID
    alt_desg	alterante_routing_Designator
    op_seq	operation_seq_num
    op_id	operation_seq_id
    eff_date    effectivity_date
    err_text 	out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmasopid_assign_op_seq_id(
	org_id		NUMBER,
	assy_id  	NUMBER,
	alt_desg	VARCHAR2,
	op_seq 		NUMBER,
	op_id		NUMBER,
	eff_date 	VARCHAR2,
	err_text    OUT VARCHAR2
)
    return INTEGER

IS
    stmt_num 	NUMBER := 1;
BEGIN
    loop
    update bom_op_resources_interface set
	operation_sequence_id = op_id
    where process_flag = 1
    and   organization_id = org_id
    and   assembly_item_id = assy_id
    and   nvl(alternate_routing_designator, 'NONE') =
		nvl(alt_desg, 'NONE')
    and   operation_seq_num = op_seq
    and   to_char(effectivity_date,'YYYY/MM/DD HH24:MI:SS') = eff_date  -- Changed for bug 2647027
--  and   to_char(effectivity_date,'YYYY/MM/DD HH24:MI') = eff_date
    and   operation_sequence_id is null
    and   rownum < 500;
    EXIT when SQL%NOTFOUND;
    commit;
    end loop;

    return(0);

EXCEPTION
    when others then
	err_text := substrb('BOMPASGR(bmasopid-' || stmt_num || ') ' || SQLERRM,1,240);
	return(SQLCODE);
END bmasopid_assign_op_seq_id;

/*---------------------- bmasrtgid_assign_rtg_seq_id -----------------------*/
/* NAME
    bmasrtgid_assign_rtg_seq_id - assign routing_sequence_ids to
		child tables
DESCRIPTION
    assigns routing_seq_ids to routing child tables

REQUISTDOP
    org_id	organization_id
    assy_id	assembly_itEM_ID
    alt_desg	alterante_routing_Designator
    rtg_id	routing_sequence_id
    err_text 	out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmasrtgid_assign_rtg_seq_id(
	org_id		NUMBER,
	assy_id  	NUMBER,
	alt_desg	VARCHAR2,
	rtg_id		NUMBER,
	err_text    OUT VARCHAR2
)
    return INTEGER

IS
    stmt_num 	NUMBER := 1;
BEGIN
    loop
    update bom_op_sequences_interface set
	routing_sequence_id = rtg_id
    where process_flag = 1
    and   organization_id = org_id
    and   assembly_item_id = assy_id
    and   nvl(alternate_routing_designator, 'NONE') =
		nvl(alt_desg, 'NONE')
    and   routing_sequence_id is null
    and   rownum < 500;
    EXIT when SQL%NOTFOUND;
    commit;
    end loop;

    loop
    stmt_num := 2;
    update bom_op_resources_interface set
	routing_sequence_id = rtg_id
    where process_flag = 1
    and   organization_id = org_id
    and   assembly_item_id = assy_id
    and   nvl(alternate_routing_designator, 'NONE') =
		nvl(alt_desg, 'NONE')
    and   routing_sequence_id is null
    and   rownum < 500;
    EXIT when SQL%NOTFOUND;
    commit;
    end loop;

    return(0);
EXCEPTION
    when others then
	err_text := substrb('BOMPASGR(bmasrtgid-' || stmt_num || ') ' || SQLERRM,1,240);
	return(SQLCODE);
END bmasrtgid_assign_rtg_seq_id;

/*-------------------------- bmgrtin_get_rtg_info --------------------------*/
/* NAME
    bmgrtin_get_rtg_info- get assembly item id, org id and alternate
DESCRIPTION
    searches the prod table first and then the interface table to
    determine the assembly item id, org id and alternate for a rtg seq id

REQUIRES
    org_id      out organization_id
    item_id     out assembly item id
    alt_desg    out alternate bom designator
    rtg_seq_id     parameter for rtg sequence id
    err_text    out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmgrtin_get_rtg_info(
        org_id      OUT NUMBER,
        item_id     OUT NUMBER,
        alt_desg    OUT VARCHAR2,
        rtg_seq_id      NUMBER,
        err_text    OUT VARCHAR2
)
    return INTEGER
IS
    seq_id              NUMBER;
BEGIN

    BEGIN
        select assembly_item_id, organization_id, alternate_routing_designator
        into item_id, org_id, alt_desg
        from bom_operational_routings
        where routing_sequence_id = rtg_seq_id;
        return(0);
    EXCEPTION
        when NO_DATA_FOUND then
            NULL;
        when others then
            err_text := 'BOMPASGR(bmgrtin) ' || substrb(SQLERRM,1,240);
            return(SQLCODE);
    END;

    select assembly_item_id, organization_id, alternate_routing_designator
        into item_id, org_id, alt_desg
        from bom_op_routings_interface
        where routing_sequence_id = rtg_seq_id
          and process_flag <> 3 and process_flag <> 7
	  and rownum = 1;

    return(0);

EXCEPTION
    when NO_DATA_FOUND then
       err_text := 'BOMPASGR(bmgrtin): Routing sequence id does not exist';
       return(9999);
    when others then
        err_text := 'BOMPASGR(bmgrtin) ' || substrb(SQLERRM,1,240);
        return(SQLCODE);

END bmgrtin_get_rtg_info;


/*------------------------- bmgtdep_get_department --------------------------*/
/* NAME
    bmgtdep_get_department - get department id
DESCRIPTION
    given dept code, get department id

REQUISTDOP
    org_id	organization_id
    dept_code	department_code
    dept_id	return department id
    err_text 	out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmgtdep_get_department(
	org_id		NUMBER,
	dept_code 	VARCHAR2,
	dept_id	  OUT	NUMBER,
	err_text  OUT 	VARCHAR2
)
    return INTEGER
IS

BEGIN
    select department_id
	into dept_id
	from bom_departments
	where organization_id = org_id
	and   department_code = dept_code;
    return(0);
EXCEPTION
    when others then
	err_text := 'BOMPASGR(bmgtdep)' || substrb(SQLERRM,1,240);
	return(SQLCODE);
END bmgtdep_get_department;

/*-------------------------- bmgtstdop_get_stdop ----------------------------*/
/* NAME
    bmgtstdop_get_stdop - get std op id
DESCRIPTION
    given std op code, get std op id

REQUISTDOP
    org_id	organization_id
    stdop_code	std op code
    stdop_id	return std op id
    err_text 	out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmgtstdop_get_stdop(
	org_id		NUMBER,
	stdop_code	VARCHAR2,
	stdop_id   OUT	NUMBER,
	err_text   OUT	VARCHAR2
)
    return INTEGER
IS

BEGIN
    select standard_operation_id
	into stdop_id
	from bom_Standard_operations
	where organization_id = org_id
	and  operation_code = stdop_code;
    return(0);
EXCEPTION
    when others then
	err_text := 'BOMPASGR(bmgtstdop)' || substrb(SQLERRM,1,240);
	return(SQLCODE);
END bmgtstdop_get_stdop;

/*----------------------- bmasritm_assign_rtg_item_id -----------------------*/
/* NAME
    bmasritm_assign_rtg_item_id - assign item_id to all rtg tables
DESCRIPTION
    assign item id to all routing child tables

REQUIRES
    err_text 	out buffer to return error message
MODIFIES
    BOM_OP_ROUTINGS_INTERFACE
    BOM_OP_SEQUENCES_INTERFACE
    BOM_OP_RESOURCES_INTERFACE
    MTL_INTERFACE_ERRORS
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmasritm_assign_rtg_item_id(
    org_id		NUMBER,
    item_num		VARCHAR2,
    item_id		NUMBER,
    err_text	 OUT 	VARCHAR2
) return INTEGER IS

  Cursor GetOps is
    Select bos.rowid row_id
    From bom_op_sequences_interface bos
    where bos.process_flag = 1
    and   bos.assembly_item_id is null
    and   bos.organization_id = org_id
    and   bos.assembly_item_number = item_num
    and   bos.routing_sequence_id is null;
  Cursor GetResources is
    Select bor.rowid row_id
    From bom_op_resources_interface bor
    where bor.process_flag = 1
    and   bor.assembly_item_id is null
    and   bor.organization_id = org_id
    and   bor.assembly_item_number = item_num
    and   bor.routing_sequence_id is null;

BEGIN
    For X_Operation in GetOps loop
      update bom_op_sequences_interface
	set assembly_item_id = item_id
      where rowid = X_Operation.row_id;
      If mod(GetOps%rowcount, 500) = 0 then
        commit;
--        dbms_output.put_line(
--          'Operation assembly ids commited at row '||to_char(GetOps%rowcount));
      End if; -- commit every 500 rows
    end loop;
    commit;

    For X_Resource in GetResources loop
      update bom_op_resources_interface
	set assembly_item_id = item_id
      where rowid = X_Resource.row_id;
      If mod(GetResources%rowcount, 500) = 0 then
        commit;
--        dbms_output.put_line(
--          'Resource assembly ids commited at row '||to_char(GetResources%rowcount));
      End if; -- commit every 500 rows
    end loop;
    commit;

    return(0);
exception
    when others then
	err_text := 'BOMPASGR(bmasritm) ' || substrb(SQLERRM,1,240);
  	return(SQLCODE);
end bmasritm_assign_rtg_item_id;

END BOMPASGR;

/
