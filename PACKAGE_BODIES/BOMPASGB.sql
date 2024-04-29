--------------------------------------------------------
--  DDL for Package Body BOMPASGB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOMPASGB" as
/* $Header: BOMASGBB.pls 115.4 99/07/16 05:08:51 porting sh $ */
/*==========================================================================+
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMPASGB.plb                                               |
| DESCRIPTION  : This package contains functions used to assign bill        |
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
|    11/07/93   Shreyas Shah	creation date                               |
|    04/14/94   Julie Maeyama   Added fixes                                 |
|                                                                           |
+===========================================================================+

 ------------------------ bmablorg_assign_bill_orgid ------------------------
   NAME
    bmablorg_assign_bill_orgid - assign organization_id to all bill tables
 DESCRIPTION
    assign org id to all bills and their child tables

 REQUIRES
    err_text 	out buffer to return error message
 MODIFIES
    BOM_BILL_OF_MTLS_INTERFACE
    BOM_INVENTORY_COMPS_INTERFACE
    BOM_REF_DESGS_INTERFACE
    BOM_SUB_COMPS_INTERFACE
    MTL_INTERFACE_ERRORS
 RETURNS
    0 if successful
    SQLCODE if unsuccessful
 NOTES
 ---------------------------------------------------------------------------*/
FUNCTION bmablorg_assign_bill_orgid (
    err_text	IN OUT 	VARCHAR2
)
    return INTEGER

IS
    stmt_num            NUMBER;
BEGIN
    stmt_num := 1;
    loop
    update bom_bill_of_mtls_interface ori
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
    update bom_inventory_comps_interface ori
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
    update bom_ref_desgs_interface ori
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

    stmt_num := 5;
    loop
    update bom_sub_comps_interface ori
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

    stmt_num := 6;
    loop
    update mtl_item_revisions_interface ori
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

    commit;
    return(0);
exception
    when others then
	err_text := 'BOMPASGB(bmablorg) ' || substrb(SQLERRM, 1, 60);
  	return(SQLCODE);
end bmablorg_assign_bill_orgid;

/*------------------------ bmasrev_assign_revision --------------------------*/
/* NAME
    bmasrev_assign_revision - assign item revision
DESCRIPTION
    assign defaults and various ids in the interface table
    BOM_ITEM_REVISIONS_INTERFACE.  If any application error occurs, it
    inserts record into MTL_INTERFACE_ERRORS.

REQUIRES
    err_text    out buffer to return error message
MODIFIES
    MTL_ITEM_REVISIONS_INTERFACE
    MTL_INTERFACE_ERRORS
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmasrev_assign_revision (
    org_id              NUMBER,
    all_org             NUMBER,
    user_id             NUMBER,
    login_id            NUMBER,
    prog_appid          NUMBER,
    prog_id             NUMBER,
    req_id              NUMBER,
    err_text  IN OUT    VARCHAR2
)
    return INTEGER

IS
    stmt_num    NUMBER := 0;
    ret_code    NUMBER;
    commit_cnt  NUMBER;
    continue_loop BOOLEAN := TRUE;

    CURSOR c1 is
        select organization_code OC, organization_id OI,
               revision R,
                inventory_item_id III, item_number IIN,
                transaction_id TI,
                implementation_date ID, effectivity_date ED
        from mtl_item_revisions_interface
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
    update mtl_item_revisions_interface
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
                        tbl_name => 'MTL_ITEM_REVISIONS_INTERFACE',
                        msg_name => 'BOM_ORG_ID_MISSING',
                        err_text => err_text);
            update mtl_item_revisions_interface set
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
                        tbl_name => 'MTL_ITEM_REVISIONS_INTERFACE',
                        msg_name => 'BOM_INV_ITEM_ID_MISSING',
                        err_text => err_text);
                update mtl_item_revisions_interface set
                    process_flag = 3
                where transaction_id = c1rec.TI;

                if (ret_code <> 0) then
                    return(ret_code);
                end if;
                goto continue_loop;
            end if;
        end if;

        stmt_num := 3;

        update mtl_item_revisions_interface set
            organization_id = nvl(organization_id, c1rec.OI),
            inventory_item_id = nvl(inventory_item_id, c1rec.III),
            revision = UPPER(c1rec.R),
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
            err_text := 'BOMPASGB(' || stmt_num || ')' ||
                         substrb(SQLERRM, 1, 60);
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
        err_text := 'BOMPASGB(bmasrev) ('|| stmt_num ||') ' ||
                     substrb(SQLERRM, 1, 60);
        return(SQLCODE);

END bmasrev_assign_revision;

/*---------------------- bmasbilh_assign_bill_header -----------------------*/
/* NAME
     bmasbilh_assign_bill_header - assign bill header data
DESCRIPTION
     assign bill header data
     create record in mtl_item_revs_interface if a REVISION given

REQUIRES
    err_text 	out buffer to return error message
MODIFIES
    MTL_INTERFACE_ERRORS
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmasbilh_assign_bill_header (
    org_id		NUMBER,
    all_org		NUMBER := 2,
    user_id		NUMBER,
    login_id		NUMBER,
    prog_appid		NUMBER,
    prog_id		NUMBER,
    req_id		NUMBER,
    err_text  IN OUT 	VARCHAR2
)
    return INTEGER
IS
    stmt_num		NUMBER;
    org_code		VARCHAR2(3);
    assy_id		NUMBER;
    c_org_id		NUMBER;
    proc_flag		NUMBER;
    ret_code		NUMBER;
    assembly_org_id	NUMBER;
    assembly_id		NUMBER;
    item_rev		VARCHAR2(4);
    x_dummy		NUMBER := 0;
    dummy_alt           VARCHAR2(10);
    commit_cnt  	NUMBER;
    continue_loop 	BOOLEAN := TRUE;

    cursor c1 is select
	organization_id OI, organization_code OC,
	assembly_item_id AII, item_number AIN,
	common_assembly_item_id CAII, common_item_number CAIN,
	common_organization_id COI, common_org_code COC,
	alternate_bom_designator ABD, transaction_id TI,
	bill_sequence_id BSI, common_bill_sequence_id CBSI,
	revision R, last_update_date LUD, last_updated_by LUB,
	creation_date CD, created_by CB, last_update_login LUL
	from bom_bill_of_mtls_interface
	where process_flag = 1
	and   (all_org = 1
		or
		(all_org = 2 and organization_id = org_id)
	      )
	and rownum < 500;

    cursor c2 is select
	transaction_id TI, common_bill_sequence_id CBSI,
	assembly_item_id AII, common_assembly_item_id CAAI,
	common_assembly_item_id CAID, organization_id OI,
	alternate_bom_designator ABD, common_organization_id COI,
	bill_Sequence_id BSI
	from bom_bill_of_mtls_interface
	where process_flag = 99
	and   (all_org = 1
		or
		(all_org = 2 and organization_id = org_id)
	      )
	and rownum < 500;

    cursor c3 is select 1
 	from dual where exists ( select 1
				 from MTL_ITEM_REVISIONS_INTERFACE
			 	 where inventory_item_id = assembly_id
				 and organization_id = assembly_org_id
				 and revision = item_rev);

BEGIN
/*
** assign transaction ids for every row first
*/
    stmt_num := 1;
    loop
    update bom_bill_of_mtls_interface ori
	set transaction_id = mtl_system_items_interface_s.nextval,
	    bill_sequence_id = nvl(bill_sequence_id,
			bom_inventory_components_s.nextval)
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
			tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
			msg_name => 'BOM_ORG_ID_MISSING',
			err_text => err_text);
	    update bom_bill_of_mtls_interface set
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
			tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
			msg_name => 'BOM_ASSY_ITEM_MISSING',
			err_text => err_text);
		update bom_bill_of_mtls_interface set
		    process_flag = 3
		where transaction_id = c1rec.TI;

		if (ret_code <> 0) then
		    return(ret_code);
		end if;
		goto continue_loop;
	    end if;
	end if;

/*
** get common organization id
*/
        stmt_num := 4;
	if (c1rec.COI is null) and (c1rec.COC is not null) and
           (c1rec.CBSI is null) then
	    ret_code := INVPUOPI.mtl_pr_trans_org_id(
		org_code => c1rec.COC,
		org_id => c1rec.COI,
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
			tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
			msg_name => 'BOM_COMMON_ORG_MISSING',
			err_text => err_text);
		update bom_bill_of_mtls_interface set
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
            c1rec.CBSI is null) then
	    if (c1rec.COI is null) then
		c1rec.COI := c1rec.OI;
	    end if;
	    ret_code := INVPUOPI.mtl_pr_parse_flex_name(
		org_id => c1rec.COI,
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
			tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
			msg_name => 'BOM_CMN_ASSY_ITEM_INVALID',
			err_text => err_text);
		update bom_bill_of_mtls_interface set
		    process_flag = 3
		where transaction_id = c1rec.TI;

		if (ret_code <> 0) then
		    return(ret_code);
		end if;
		goto continue_loop;
	    end if;
	end if;
/*
** Insert revision record
*/
        stmt_num := 6;
	if (c1rec.R is not null) then
          x_dummy := 0;
  	  assembly_id :=  c1rec.AII;
	  item_rev := c1rec.R;
       	  assembly_org_id := c1rec.OI;
          for x_count in c3 loop
	    x_dummy := 1;
          end loop;
            if x_dummy = 0 then
 	      insert into mtl_item_revisions_interface
 		(INVENTORY_ITEM_ID,
	 	 ORGANIZATION_ID,
		 REVISION,
	 	 LAST_UPDATE_DATE,
		 LAST_UPDATED_BY,
		 CREATION_DATE,
		 CREATED_BY,
		 LAST_UPDATE_LOGIN,
		 EFFECTIVITY_DATE,
		 IMPLEMENTATION_DATE,
		 TRANSACTION_ID,
		 PROCESS_FLAG,
		 REQUEST_ID,
		 PROGRAM_APPLICATION_ID,
		 PROGRAM_ID,
		 PROGRAM_UPDATE_DATE
   		) values
		(c1rec.AII, c1rec.OI, UPPER(c1rec.R),
		 nvl(c1rec.LUD, sysdate),
		 nvl(c1rec.LUB, user_id),
		 nvl(c1rec.CD, sysdate),
		 nvl(c1rec.CB, user_id),
                 nvl(c1rec.LUL, user_id),
		 sysdate,
		 sysdate,
		 mtl_system_items_interface_s.nextval,
		 2,
		 req_id,
		 prog_appid,
		 prog_id,
		 sysdate
		 );
              end if;
	end if;

        stmt_num := 7;
	update bom_bill_of_mtls_interface
	set organization_id = nvl(organization_id, c1rec.OI),
	    assembly_item_id = nvl(assembly_item_id, c1rec.AII),
            common_organization_id = nvl(common_organization_id, c1rec.COI),
	    common_assembly_item_id = nvl(common_assembly_item_id, c1rec.CAII),
	    assembly_type = nvl(assembly_type, 1),
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
	    err_text := 'BOMPASGB(' || stmt_num || ')' ||
                        substrb(SQLERRM, 1, 60);
	    return(SQLCODE);
	end if;
        stmt_num := 8;
/*
** assign assembly_item_id to all child recs
*/
        ret_code := bmasbitm_assign_bom_item_id(
		org_id => c1rec.OI,
		item_number => c1rec.AIN,
		item_id => c1rec.AII,
		err_text => err_text);

	if (ret_code <> 0) then
	    return(SQLCODE);
	end if;

   stmt_num := 9;
/*
** assign bill sequence id to all child tables
*/
      	ret_code := bmasbomid_assign_bom_seq_id(
		org_id => c1rec.OI,
		assy_id => c1rec.AII,
		alt_desg => c1rec.ABD,
		bom_id => c1rec.BSI,
		err_text => err_text);
	if (ret_code <> 0) then
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

continue_loop := TRUE;
while continue_loop loop
    commit_cnt := 0;
    for c2rec in c2 loop
        commit_cnt := commit_cnt + 1;
	stmt_num :=10;
	proc_flag := 2;
	if (c2rec.CBSI is null) then
	    if (c2rec.CAID is null) then
		c2rec.CBSI := c2rec.BSI;
	    else
		assy_id := c2rec.CAID;
	    	if (c2rec.COI is null) then
		   c_org_id := c2rec.OI;  /* Cmn org id defaults to org id */
	        else
		   c_org_id := c2rec.COI;
	        end if;
	        ret_code := bmgblsq_get_bill_sequence(
		   org_id => c_org_id,
		   item_id => assy_id,
		   alt_desg => c2rec.ABD,
		   bill_seq_id => c2rec.CBSI,
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
		      tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
		      msg_name => 'BOM_CMN_BILL_SEQ_MISSING',
	 	      err_text => err_text);
		   proc_flag := 3;
	        end if;
	    end if;
        else
            ret_code := bmgblin_get_bill_info(
               org_id => c_org_id,
               item_id => assy_id,
               alt_desg => dummy_alt,
               bill_seq_id => c2rec.CBSI,
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
                        tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
                        msg_name => 'BOM_CMN_BILL_SEQ_MISSING',
                        err_text => err_text);
                proc_flag := 3;
            end if;
	end if;
	if (c2rec.CBSI = c2rec.BSI) then
	    c_org_id := NULL;
	    assy_id := NULL;
	end if;
	stmt_num := 11;

        update bom_bill_of_mtls_interface set
	    process_flag = proc_flag,
	    common_bill_sequence_id = c2rec.CBSI,
	    common_organization_id = c_org_id,
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
	err_text := 'BOMPASGB(bmasbilh-' || stmt_num  || ') ' ||
                    substrb(SQLERRM, 1, 60);
	return(SQLCODE);
END bmasbilh_assign_bill_header;

/*---------------------- bmascomp_assign_comp -----------------------*/
/* NAME
     bmascomp_assign_comp - assign component information
DESCRIPTION
    assign component default information

REQUIRES
    err_text 	out buffer to return error message
MODIFIES
    MTL_INTERFACE_ERRORS
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmascomp_assign_comp (
    org_id		NUMBER,
    all_org		NUMBER := 2,
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
    curr_org_code       VARCHAR2(3);
    continue_loop BOOLEAN := TRUE;

    CURSOR c1 is
	select organization_code OC, organization_id OI,
		assembly_item_id AII, assembly_item_number AIN,
		alternate_bom_designator ABD, bill_sequence_id BSI,
		component_sequence_id CSI, transaction_id TI,
		component_item_id CII, component_item_number CIN,
		location_name LN, supply_locator_id SLI,
		operation_seq_num OSN,
		to_char(effectivity_date, 'YYYY/MM/DD HH24:MI') ED,
                bom_item_type BIT
	from bom_inventory_comps_interface
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
    update bom_inventory_comps_interface
	set transaction_id = mtl_system_items_interface_s.nextval,
	    component_sequence_id = nvl(component_sequence_id,
			bom_inventory_components_s.nextval)
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
	if (c1rec.OI is null and (c1rec.BSI is null or c1rec.CII is null)) then
	    ret_code := INVPUOPI.mtl_log_interface_err(
			org_id => NULL,
			user_id => user_id,
			login_id => login_id,
			prog_appid => prog_appid,
			prog_id => prog_id,
			req_id => req_id,
			trans_id => c1rec.TI,
			error_text => err_text,
			tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
			msg_name => 'BOM_ORG_ID_MISSING',
			err_text => err_text);
	    update bom_inventory_comps_interface set
		    process_flag = 3
	    where transaction_id = c1rec.TI;

	    goto continue_loop;
	end if;

        stmt_num := 1.5;
        if (c1rec.ED is null) then
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => NULL,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_EFF_DATE_MISSING',
                        err_text => err_text);
            update bom_inventory_comps_interface set
                    process_flag = 3
            where transaction_id = c1rec.TI;

            goto continue_loop;
        end if;

	stmt_num := 2;
	if  (c1rec.AII is null and c1rec.BSI is null) then
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
			tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
			msg_name => 'BOM_ASSY_ITEM_MISSING',
			err_text => err_text);
		update bom_inventory_comps_interface set
		    process_flag = 3
		where transaction_id = c1rec.TI;

		if (ret_code <> 0) then
		    return(ret_code);
		end if;
		goto continue_loop;
	    end if;
	end if;

        stmt_num := 3;
        if  (c1rec.SLI is null and c1rec.LN is not null) then
            ret_code := INVPUOPI.mtl_pr_parse_flex_name(
                org_id => c1rec.OI,
                flex_code => 'MTLL',
                flex_name => c1rec.LN,
                flex_id => c1rec.SLI,
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
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_LOCATION_NAME_INVALID',
                        err_text => err_text);
                update bom_inventory_comps_interface set
                    process_flag = 3
                where transaction_id = c1rec.TI;

                if (ret_code <> 0) then
                    return(ret_code);
                end if;
                goto continue_loop;
            end if;
        end if;

	stmt_num := 4;
	if (c1rec.BSI is null) then
	    ret_code := bmgblsq_get_bill_sequence(
		org_id => c1rec.OI,
		item_id => c1rec.AII,
		alt_desg => c1rec.ABD,
		bill_seq_id => c1rec.BSI,
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
			tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
			msg_name => 'BOM_BILL_SEQ_MISSING',
			err_text => err_text);
		update bom_inventory_comps_interface set
		    process_flag = 3
		where transaction_id = c1rec.TI;

		if (ret_code <> 0) then
		    return(ret_code);
		end if;
		goto continue_loop;
	    end if;
        else                     /* Needed for verify */
            ret_code := bmgblin_get_bill_info(
               org_id => c1rec.OI,
               item_id => c1rec.AII,
               alt_desg => c1rec.ABD,
               bill_seq_id => c1rec.BSI,
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
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_BILL_SEQ_MISSING',
                        err_text => err_text);
                update bom_inventory_comps_interface set
                    process_flag = 3
                where transaction_id = c1rec.TI;

                if (ret_code <> 0) then
                    return(ret_code);
                end if;
                goto continue_loop;
            end if;
	end if;

	stmt_num := 5;
	if  (c1rec.CII is null) then
            ret_code := INVPUOPI.mtl_pr_trans_prod_item(
                        c1rec.CIN,
                        c1rec.OI,
                        c1rec.CII,
                        err_text);
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
			tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
			msg_name => 'BOM_COMP_ID_MISSING',
			err_text => err_text);
		update bom_inventory_comps_interface set
		    process_flag = 3
		where transaction_id = c1rec.TI;

		if (ret_code <> 0) then
		    return(ret_code);
		end if;
		goto continue_loop;
	    end if;
	end if;

        BEGIN
           BEGIN
              select bom_item_type
                into c1rec.BIT
                from mtl_system_items
               where organization_id = c1rec.OI
                 and inventory_item_id = c1rec.CII;
              goto default_op_seq;
           EXCEPTION
               when NO_DATA_FOUND then
		ret_code := INVPUOPI.mtl_log_interface_err(
			org_id => NULL,
			user_id => user_id,
			login_id => login_id,
			prog_appid => prog_appid,
			prog_id => prog_id,
			req_id => req_id,
			trans_id => c1rec.TI,
			error_text => err_text,
			tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
			msg_name => 'BOM_COMP_ID_MISSING',
			err_text => err_text);
		update bom_inventory_comps_interface set
		    process_flag = 3
		where transaction_id = c1rec.TI;

		if (ret_code <> 0) then
		    return(ret_code);
		end if;
		goto continue_loop;
               when others then
                  err_text := 'BOMPASGB(bmascomp) '||
                              substrb(SQLERRM, 1, 60);
                  return(SQLCODE);
           END;
        END;
<<default_op_seq>>

	update bom_inventory_comps_interface set
	component_item_id = nvl(component_item_id, c1rec.CII),
	item_num = nvl(item_num, 1),
	component_quantity = nvl(component_quantity, 1),
	component_yield_factor = nvl(component_yield_factor, 1),
	implementation_date = effectivity_date,
	planning_factor = nvl(planning_factor, 100),
	quantity_related = nvl(quantity_related, 2),
	so_basis = nvl(so_basis, 2),
	optional = nvl(optional, 2),
	mutually_exclusive_options = nvl(mutually_exclusive_options, 2),
	include_in_cost_rollup = nvl(include_in_cost_rollup, 1),
	check_atp = nvl(check_atp, 2),
	required_to_ship = nvl(required_to_ship, 2),
	required_for_revenue = nvl(required_for_Revenue, 2),
	include_on_ship_docs = nvl(include_on_ship_docs, 2),
	include_on_bill_docs = nvl(include_on_bill_docs, 2),
	low_quantity = nvl(low_quantity, nvl(high_quantity,null)),
	high_quantity = nvl(high_quantity,nvl(low_quantity,null)),
	bill_sequence_id = nvl(bill_Sequence_id, c1rec.BSI),
	pick_components = nvl(pick_components, 2),
	supply_locator_id = nvl(supply_locator_id, c1rec.SLI),
	assembly_item_id = nvl(assembly_item_id, c1rec.AII),
        alternate_bom_designator = nvl(alternate_bom_designator,c1rec.ABD),
	organization_id = nvl(organization_id, c1rec.OI),
	creation_date = nvl(creation_date, sysdate),
	created_by = nvl(created_by, user_id),
	last_update_date = nvl(last_update_date, sysdate),
	last_updated_by = nvl(last_updated_by, user_id),
	last_update_login = nvl(last_update_login, user_id),
        request_id = nvl(request_id, req_id),
        program_application_id = nvl(program_application_id, prog_appid),
        program_id = nvl(program_id, prog_id),
        program_update_date = nvl(program_update_date, sysdate),
	process_flag = 2,
        bom_item_type = c1rec.BIT
	where transaction_id = c1rec.TI;

/*
** update component_sequence_id for ref desgs and sub comps
*/
	ret_code := bmascmpid_assign_cmp_seq_id(
		org_id => c1rec.OI,
		assy_id => c1rec.AII,
		alt_desg => c1rec.ABD,
		op_seq => c1rec.OSN,
		cmp_seq_id => c1rec.CSI,
		cmp_id => c1rec.CII,
		eff_date => c1rec.ED,
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

   return(0);

EXCEPTION
    when others then
	err_text := 'BOMPASGB(bmascomp-' || stmt_num || ')' ||
                    substrb(SQLERRM, 1, 60);
	return(SQLCODE);
END bmascomp_assign_comp;

/*----------------------- bmgblsq_get_bill_sequence ----------------------*/
/* NAME
    bmgblsq_get_bill_sequence - get bill sequence id
DESCRIPTION
    searches the prod table first and then the interface table to
    determine the bill_sequence_id

REQUIRES
    org_id	organization_id
    item_id     assembly item id
    alt_desg    alternate_bom_designator
    bill_seq_id out parameter for bill sequence id
    err_text 	out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmgblsq_get_bill_sequence(
	org_id		NUMBER,
	item_id		NUMBER,
	alt_desg	VARCHAR2,
	bill_seq_id OUT NUMBER,
	err_text    OUT VARCHAR2
)
    return INTEGER
IS
    seq_id		NUMBER;
BEGIN

    BEGIN
        select bill_sequence_id
	into bill_seq_id
	from bom_bill_of_materials
	where organization_id = org_id
	and   assembly_item_id = item_id
	and   nvl(alternate_bom_designator, 'NONE') =
		nvl(alt_desg, 'NONE');
	return(0);
    EXCEPTION
	when NO_DATA_FOUND then
	    NULL;
	when others then
	    err_text := 'BOMPASGB(bmgblsq) ' || substrb(SQLERRM, 1, 60);
	    return(SQLCODE);
    END;

    select bill_sequence_id
	into bill_seq_id
	from bom_bill_of_mtls_interface
	where organization_id = org_id
	and assembly_item_id  = item_id
	and nvl(alternate_bom_designator, 'NONE') =
	    nvl(alt_desg, 'NONE')
        and process_flag <> 3 and process_flag <> 7
	and rownum = 1;

    return(0);

EXCEPTION
    when NO_DATA_FOUND then
       err_text := 'BOMPASGB(bmgblsq): Bill does not exist';
       return(9999);
    when others then
	bill_seq_id := -1;
	err_text := 'BOMPASGB(bmgblsq) ' || substrb(SQLERRM, 1, 60);
	return(SQLCODE);

END bmgblsq_get_bill_sequence;


/*----------------------- bmgcpsq_get_comp_sequence ----------------------*/
/* NAME
    bmgcpsq_get_comp_sequence - get component sequence id
DESCRIPTION
    searches the prod table first and then the interface table to
    determine the component_sequence_id

REQUIRES
    bill_seq_id bill sequence id
    op_seq      operation_seq_num
    cmp_id      component_item_id
    eff_date    effectivity_date
    cmp_seq_id  out component_sequence_id
    err_text    out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmgcpsq_get_comp_sequence(
        bill_seq_id     NUMBER,
        op_seq          NUMBER,
        cmp_id          NUMBER,
        eff_date        VARCHAR2,
        cmp_seq_id  OUT NUMBER,
        err_text    OUT VARCHAR2
)
    return INTEGER
IS
BEGIN

    BEGIN
        select component_sequence_id
        into cmp_seq_id
        from bom_inventory_components
        where bill_sequence_id = bill_seq_id
        and   component_item_id = cmp_id
        and   operation_seq_num = op_seq
        and   to_char(effectivity_date,'YYYY/MM/DD HH24:MI') = eff_date;
        return(0);
    EXCEPTION
        when NO_DATA_FOUND then
            NULL;
        when others then
            err_text := 'BOMPASGB(bmgcpsq) ' || substrb(SQLERRM, 1, 60);
            return(SQLCODE);
    END;

    select component_sequence_id
        into cmp_seq_id
        from bom_inventory_comps_interface
        where bill_sequence_id = bill_seq_id
        and   component_item_id = cmp_id
        and   operation_seq_num = op_seq
        and   to_char(effectivity_date,'YYYY/MM/DD HH24:MI') = eff_date
        and   process_flag <>3 and process_flag <> 7
        and   rownum = 1;
    return(0);

EXCEPTION
    when NO_DATA_FOUND then
       err_text := 'BOMPASGB(bmgcpsq): Component does not exist';
       return(9999);
    when others then
        cmp_seq_id := -1;
        err_text := 'BOMPASGB(bmgcpsq) ' || substrb(SQLERRM, 1, 60);
        return(SQLCODE);

END bmgcpsq_get_comp_sequence;

/*-------------------------- bmgblin_get_bill_info --------------------------*/
/* NAME
    bmgblin_get_bill_info- get assembly item id and org id
DESCRIPTION
    searches the prod table first and then the interface table to
    determine the assembly item id and org id for a bill seq id

REQUIRES
    org_id      out organization_id
    item_id     out assembly item id
    alt_desg    out alternate bom designator
    bill_seq_id     parameter for bill sequence id
    err_text    out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmgblin_get_bill_info(
        org_id      OUT NUMBER,
        item_id     OUT NUMBER,
        alt_desg    OUT VARCHAR2,
        bill_seq_id     NUMBER,
        err_text    OUT VARCHAR2
)
    return INTEGER
IS
    seq_id              NUMBER;
BEGIN

    BEGIN
        select assembly_item_id, organization_id, alternate_bom_designator
        into item_id, org_id, alt_desg
        from bom_bill_of_materials
        where bill_sequence_id = bill_seq_id;
        return(0);
    EXCEPTION
        when NO_DATA_FOUND then
            NULL;
        when others then
            err_text := 'BOMPASGB(bmgblin) ' || substrb(SQLERRM, 1, 60);
            return(SQLCODE);
    END;

    select assembly_item_id, organization_id, alternate_bom_designator
        into item_id, org_id, alt_desg
        from bom_bill_of_mtls_interface
        where bill_sequence_id = bill_seq_id
          and process_flag <> 3 and process_flag <> 7
          and rownum = 1;

    return(0);

EXCEPTION
    when NO_DATA_FOUND then
       err_text := 'BOMPASGB(bmgblin): Bill sequence id does not exist';
       return(9999);
    when others then
        err_text := 'BOMPASGB(bmgblin) ' || substrb(SQLERRM, 1, 60);
        return(SQLCODE);

END bmgblin_get_bill_info;


/*----------------------- bmasbitm_assign_bom_item_id -----------------------*/
/* NAME
    bmasbitm_assign_bom_item_id - assign item_id to all bill tables
DESCRIPTION
    assign item id to all bill child tables

REQUIRES
    err_text 	out buffer to return error message
MODIFIES
    BOM_BILL_OF_MTLS_INTERFACE
    BOM_INVENTORY_COMPS_INTERFACE
    BOM_REF_DESGS_INTERFACE
    BOM_SUB_COMPS_INTERFACE
    MTL_INTERFACE_ERRORS
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmasbitm_assign_bom_item_id(
    org_id		NUMBER,
    item_number		VARCHAR2,
    item_id		NUMBER,
    err_text	IN OUT 	VARCHAR2
)
    return INTEGER

IS
  Cursor GetComps is
    Select bici.rowid row_id
    From bom_inventory_comps_interface bici
    where bici.process_flag = 1
    and   bici.assembly_item_id is null
    and   bici.organization_id = org_id
    and   bici.assembly_item_number = item_number
    and   bici.bill_sequence_id is null;
  Cursor GetRefDesgs is
    Select brd.rowid row_id
    From bom_ref_desgs_interface brd
    where brd.process_flag = 1
    and   brd.assembly_item_id is null
    and   brd.organization_id = org_id
    and   brd.assembly_item_number = item_number
    and   brd.bill_sequence_id is null;
  Cursor GetSubComps is
    Select bsc.rowid row_id
    From bom_sub_comps_interface bsc
    where bsc.process_flag = 1
    and   bsc.assembly_item_id is null
    and   bsc.organization_id = org_id
    and   bsc.assembly_item_number = item_number
    and   bsc.bill_sequence_id is null;
BEGIN
  For  X_Component in GetComps loop
    update bom_inventory_comps_interface
	set assembly_item_id = item_id
    where rowid = X_Component.row_id;
    if mod(GetComps%rowcount, 500) = 0 then
      commit;
--      dbms_output.put_line('Assign assembly id to component committed at row '
--        ||to_char(GetComps%rowcount));
    end if; -- commit every 500 rows
  end loop;

  For X_Designator in GetRefDesgs loop
    update bom_ref_desgs_interface ori
	set ori.assembly_item_id = item_id
    where ori.rowid = X_Designator.row_id;
    If mod(GetRefDesgs%rowcount, 500) = 0 then
      commit;
--      dbms_output.put_line('Assign assembly id to designator committed at row '
--        ||to_char(GetRefDesgs%rowcount));
    end if; -- commit every 500 rows
  end loop;

  For X_Substitute in GetSubComps loop
    update bom_sub_comps_interface ori
	set ori.assembly_item_id = item_id
    where ori.rowid = X_Substitute.row_id;
    If mod(GetSubComps%rowcount, 500) = 0 then
      commit;
--      dbms_output.put_line('Assign assembly id to substitute committed at row '
--        ||to_char(GetSubComps%rowcount));
    end if; -- commit every 500 rows
  end loop;

  commit;
  return(0);
exception
    when others then
	err_text := 'BOMPASGB(bmasbitm) ' || substrb(SQLERRM, 1, 60);
  	return(SQLCODE);
end bmasbitm_assign_bom_item_id;

/*---------------------- bmasbomid_assign_bom_seq_id -----------------------*/
/* NAME
    bmasbomid_assign_bom_seq_id - assign bill_sequence_ids to
		child tables
DESCRIPTION
    assigns bill_seq_ids to bom child tables

REQUISTDOP
    org_id	organization_id
    assy_id	assembly_item_id
    alt_desg	alterante_routing_designator
    bom_id	bill_sequence_id
    err_text 	out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmasbomid_assign_bom_seq_id(
	org_id		NUMBER,
	assy_id  	NUMBER,
	alt_desg	VARCHAR2,
	bom_id		NUMBER,
	err_text IN OUT VARCHAR2
)
    return INTEGER

IS
    stmt_num 	NUMBER := 1;
BEGIN
    loop
    update bom_inventory_comps_interface set
	bill_sequence_id = bom_id
    where process_flag = 1
    and   organization_id = org_id
    and   assembly_item_id = assy_id
    and   nvl(alternate_bom_designator, 'NONE') =
		nvl(alt_desg, 'NONE')
    and   bill_sequence_id is null
    and   rownum < 500;
    EXIT when SQL%NOTFOUND;
    commit;
    end loop;

    loop
    update bom_ref_desgs_interface set
	bill_sequence_id = bom_id
    where process_flag = 1
    and   organization_id = org_id
    and   assembly_item_id = assy_id
    and   nvl(alternate_bom_designator, 'NONE') =
		nvl(alt_desg, 'NONE')
    and   bill_sequence_id is null
    and   rownum < 500;
    EXIT when SQL%NOTFOUND;
    commit;
    end loop;

    loop
    update bom_sub_comps_interface set
	bill_sequence_id = bom_id
    where process_flag = 1
    and   organization_id = org_id
    and   assembly_item_id = assy_id
    and   nvl(alternate_bom_designator, 'NONE') =
		nvl(alt_desg, 'NONE')
    and   bill_sequence_id is null
    and   rownum < 500;
    EXIT when SQL%NOTFOUND;
    commit;
    end loop;

    return(0);
EXCEPTION
    when others then
	err_text := 'BOMPASGB(' || stmt_num || ') ' || substrb(SQLERRM, 1, 60);
	return(SQLCODE);
END bmasbomid_assign_bom_seq_id;

/*----------------------- bmascmpid_assign_cmp_seq_id -----------------------*/
/* NAME
    bmascmpid_assign_cmp_seq_id - assign component_sequence_ids to
		child tables
DESCRIPTION
    assigns component_seq_ids to child tables

REQUIRES
    org_id	organization_id
    assy_id	assembly_item_id
    alt_desg	alterante_bom_designator
    op_seq	operation_seq_num
    cmp_seq_id	component_seq_id
    cmp_id	component_item_id
    err_text 	out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmascmpid_assign_cmp_seq_id(
	org_id		NUMBER,
	assy_id  	NUMBER,
	alt_desg	VARCHAR2,
	op_seq 		NUMBER,
	cmp_id		NUMBER,
	cmp_seq_id	NUMBER,
	eff_date 	VARCHAR2,
	err_text IN OUT VARCHAR2
)
    return INTEGER

IS
    stmt_num 	NUMBER := 1;
BEGIN
    loop
    update bom_ref_desgs_interface set
	component_sequence_id = cmp_seq_id
    where process_flag = 1
    and   organization_id = org_id
    and   assembly_item_id = assy_id
    and   nvl(alternate_bom_designator, 'NONE') =
		nvl(alt_desg, 'NONE')
    and   operation_seq_num = op_seq
    and   to_char(effectivity_date,'YYYY/MM/DD HH24:MI') = eff_date
    and   component_item_id = cmp_id
    and   component_sequence_id is null
    and   rownum < 500;
    EXIT when SQL%NOTFOUND;
    commit;
    end loop;


    stmt_num := 2;
    loop
    update bom_sub_comps_interface set
	component_sequence_id = cmp_seq_id
    where process_flag = 1
    and   organization_id = org_id
    and   assembly_item_id = assy_id
    and   nvl(alternate_bom_designator, 'NONE') =
		nvl(alt_desg, 'NONE')
    and   operation_seq_num = op_seq
    and   to_char(effectivity_date,'YYYY/MM/DD HH24:MI') = eff_date
    and   component_item_id = cmp_id
    and   component_sequence_id is null
    and   rownum < 500;
    EXIT when SQL%NOTFOUND;
    commit;
    end loop;

    return(0);

EXCEPTION
    when others then
	err_text := 'BOMPASGB(bmascmpid) ' || substrb(SQLERRM, 1, 60);
	return(SQLCODE);
END bmascmpid_assign_cmp_seq_id;

/*------------------------ bmgcpqy_get_comp_quantity ------------------------*/
/* NAME
    bmgcpqy_get_comp_quantity get component quantity
DESCRIPTION
    searches the prod table first and then the interface table to
    determine the component quantity for a component sequence id

REQUIRES
    comp_seq_id     component sequence id
    comp_qty    out component quantity
    err_text    out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmgcpqy_get_comp_quantity(
        comp_seq_id     NUMBER,
        comp_qty    OUT NUMBER,
        err_text    OUT VARCHAR2
)
    return INTEGER
IS
BEGIN

    BEGIN
        select component_quantity
        into comp_qty
        from bom_inventory_components
        where component_sequence_id = comp_seq_id;
        return(0);
    EXCEPTION
        when NO_DATA_FOUND then
            NULL;
        when others then
            err_text := 'BOMPASGB(bmgcpqy) ' || substrb(SQLERRM, 1, 60);
            return(SQLCODE);
    END;

    select component_quantity
        into comp_qty
        from bom_inventory_comps_interface
        where component_sequence_id = comp_seq_id
          and process_flag <> 3 and process_flag <> 7
          and rownum = 1;

    return(0);

EXCEPTION
    when others then
        err_text := 'BOMPASGB(bmgcpqy) ' || substrb(SQLERRM, 1, 60);
        return(SQLCODE);

END bmgcpqy_get_comp_quantity;


/*------------------------ bmasrefd_assign_ref_desg_data --------------------*/
/* NAME
    bmasrefd_assign_ref_desg_data - assign ref desg data
DESCRIPTION
    create new records if data in parent table.  Assign default values
    for existing records
REQUIRES
    err_text 	out buffer to return error message
MODIFIES
    BOM_REF_DESGS_INTERFACE
    MTL_INTERFACE_ERRORS
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmasrefd_assign_ref_desg_data (
    org_id		NUMBER,
    all_org		NUMBER := 2,
    user_id		NUMBER,
    login_id		NUMBER,
    prog_appid		NUMBER,
    prog_id		NUMBER,
    req_id		NUMBER,
    err_text	IN OUT 	VARCHAR2
)
    return INTEGER
IS
    ret_code		NUMBER;
    dummy_txn           NUMBER;
    commit_cnt  	NUMBER;
    continue_loop 	BOOLEAN := TRUE;
    total_recs		NUMBER;

    CURSOR c1 is
	select  component_sequence_id CSI,
		transaction_id TI, organization_id OI,
                bill_sequence_id BSI, assembly_item_id AII,
                assembly_item_number AIN, alternate_bom_designator ABD,
                component_item_id CII, component_item_number CIN,
                operation_seq_num OSN,
                to_char(effectivity_date,'YYYY/MM/DD HH24:MI') ED
	from bom_ref_desgs_interface
	where process_flag = 1
        and component_sequence_id is null
	and   (all_org = 1
		or
		(all_org = 2 and organization_id = org_id)
	      )
	and rownum < 500;

    CURSOR c2 is
	select transaction_id TI, organization_id OI
	from bom_ref_desgs_interface
	where process_flag = 1
        and component_sequence_id is not null
	and   (all_org = 1
		or
		(all_org = 2 and organization_id = org_id)
	      )
	and rownum < 500;

    CURSOR c3 is
        select component_sequence_id CSI
        from bom_ref_desgs_interface
        where process_flag = 99
        and   (all_org = 1
                or
                (all_org = 2 and organization_id = org_id)
              )
	and rownum < 500
        group by component_sequence_id;

BEGIN
/*
** first load all rows from components interface into ref desg interface
*/
    insert into bom_ref_desgs_interface (
	COMPONENT_REFERENCE_DESIGNATOR,
 	LAST_UPDATE_DATE,
 	LAST_UPDATED_BY,
 	CREATION_DATE,
 	CREATED_BY,
        LAST_UPDATE_LOGIN,
	REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE,
 	COMPONENT_SEQUENCE_ID,
	PROCESS_FLAG) select
	REFERENCE_DESIGNATOR,
	NVL(LAST_UPDATE_DATE, SYSDATE),
	NVL(LAST_UPDATED_BY, user_id),
	NVL(CREATION_DATE,SYSDATE),
	NVL(CREATED_BY, user_id),
        NVL(LAST_UPDATE_LOGIN, user_id),
	NVL(REQUEST_ID, req_id),
	NVL(PROGRAM_APPLICATION_ID, prog_appid),
	NVL(PROGRAM_ID, prog_id),
	NVL(PROGRAM_UPDATE_DATE, sysdate),
	COMPONENT_SEQUENCE_ID,
	1
	from bom_inventory_comps_interface
	where process_flag = 2
	and   reference_designator is not null;

    commit;

/*
**  assign transaction ids for every row
*/
    loop
    update bom_ref_desgs_interface
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
    while continue_loop loop
      commit_cnt := 0;
      for c1rec in c1 loop
        commit_cnt := commit_cnt + 1;
        if (c1rec.OI is null and (c1rec.BSI is null or c1rec.CII is null)) then
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => NULL,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_REF_DESGS_INTERFACE',
                        msg_name => 'BOM_ORG_ID_MISSING',
                        err_text => err_text);
            update bom_ref_desgs_interface set
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
        if (c1rec.AII is null and c1rec.BSI is null) then
           ret_code := INVPUOPI.mtl_pr_parse_flex_name(
                org_id=> c1rec.OI,
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
                        tbl_name => 'BOM_REF_DESGS_INTERFACE',
                        msg_name => 'BOM_ASSY_ITEM_MISSING',
                        err_text => err_text);
                update bom_ref_desgs_interface set
                    process_flag = 3
                where transaction_id = c1rec.TI;

                if (ret_code <> 0) then
                    return(ret_code);
                end if;
                goto continue_loop;
            end if;
        end if;

/*
**  Get bill sequence id
*/

     if (c1rec.BSI is null) then
        ret_code := bmgblsq_get_bill_sequence(
                    org_id => c1rec.OI,
                    item_id => c1rec.AII,
                    alt_desg => c1rec.ABD,
                    bill_seq_id => c1rec.BSI,
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
                      tbl_name => 'BOM_REF_DESGS_INTERFACE',
                      msg_name => 'BOM_BILL_SEQ_MISSING',
                      err_text => err_text);
            update bom_ref_desgs_interface set
                   process_flag = 3
             where transaction_id = c1rec.TI;

            if (ret_code <> 0) then
                return(ret_code);
            end if;
            goto continue_loop;
        end if;
      else                     /* Needed for verify */
          ret_code := bmgblin_get_bill_info(
               org_id => c1rec.OI,
               item_id => c1rec.AII,
               alt_desg => c1rec.ABD,
               bill_seq_id => c1rec.BSI,
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
                        tbl_name => 'BOM_REF_DESGS_INTERFACE',
                        msg_name => 'BOM_BILL_SEQ_MISSING',
                        err_text => err_text);
                update bom_ref_desgs_interface set
                    process_flag = 3
                where transaction_id = c1rec.TI;

                if (ret_code <> 0) then
                    return(ret_code);
                end if;
                goto continue_loop;
            end if;
      end if;

/*
**  Set component item id
*/

        if (c1rec.CII is null) then
           ret_code := INVPUOPI.mtl_pr_parse_flex_name(
                org_id=> c1rec.OI,
                flex_code => 'MSTK',
                flex_name => c1rec.CIN,
                flex_id => c1rec.CII,
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
                        tbl_name => 'BOM_REF_DESGS_INTERFACE',
                        msg_name => 'BOM_COMP_ID_MISSING',
                        err_text => err_text);
                update bom_ref_desgs_interface set
                    process_flag = 3
                where transaction_id = c1rec.TI;

                if (ret_code <> 0) then
                    return(ret_code);
                end if;
                goto continue_loop;
            end if;
        end if;

/*
**  Get component sequence id
*/
        ret_code := bmgcpsq_get_comp_sequence(
                    bill_seq_id => c1rec.BSI,
                    op_seq => c1rec.OSN,
                    cmp_id => c1rec.CII,
                    eff_date => c1rec.ED,
                    cmp_seq_id => c1rec.CSI,
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
                      tbl_name => 'BOM_REF_DESGS_INTERFACE',
                      msg_name => 'BOM_COMP_SEQ_MISSING',
                      err_text => err_text);
            update bom_ref_desgs_interface set
                    process_flag = 3
             where transaction_id = c1rec.TI;

            if (ret_code <> 0) then
                return(ret_code);
            end if;
            goto continue_loop;
        end if;

        update bom_ref_desgs_interface
           set component_sequence_id = c1rec.CSI,
               assembly_item_id = c1rec.AII,
               component_item_id = c1rec.CII,
               bill_sequence_id = c1rec.BSI,
               organization_id = c1rec.OI
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
** Set default values and process_flag for valid records
*/
continue_loop := TRUE;
while continue_loop loop
      commit_cnt := 0;
      for c2rec in c2 loop
        commit_cnt := commit_cnt + 1;
        update bom_ref_desgs_interface
           set process_flag = 99,
               last_update_date = nvl(last_update_date,sysdate),
               last_updated_by = nvl(last_updated_by,user_id),
               creation_date = nvl(creation_date,sysdate),
               created_by = nvl(created_by,user_id),
	       last_update_login = nvl(last_update_login, user_id),
               request_id = nvl(request_id, req_id),
              program_application_id = nvl(program_application_id, prog_appid),
               program_id = nvl(program_id, prog_id),
               program_update_date = nvl(program_update_date, sysdate)
         where transaction_id = c2rec.TI;

     end loop;

     commit;
    if (commit_cnt < (500 - 1)) then
       continue_loop := FALSE;
    end if;

end loop;

/*
** Set records with same component_sequence_id with the same txn id
** for set processing
*/
select count(distinct component_sequence_id)
  into total_recs
  from bom_ref_desgs_interface
 where process_flag = 99;

continue_loop := TRUE;
commit_cnt := 0;

while continue_loop loop
     for c3rec in c3 loop
        commit_cnt := commit_cnt + 1;
        select mtl_system_items_interface_s.nextval
          into dummy_txn
          from sys.dual;

        update bom_ref_desgs_interface
           set transaction_id = dummy_txn,
	       process_flag = 2
         where component_sequence_id = c3rec.CSI
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
        err_text := 'BOMPASGB(bmasrefd) ' || substrb(SQLERRM, 1, 60);
        return(SQLCODE);

END bmasrefd_assign_ref_desg_data;

/*------------------------ bmassubd_assign_sub_comp_data --------------------*/
/* NAME
    bmassubd_assign_sub_comp_data - assign substitute component data
DESCRIPTION
    create new records if data in parent table.  Assign default values
    for existing records
REQUIRES
    err_text 	out buffer to return error message
MODIFIES
    BOM_SUB_COMPS_INTERFACE
    MTL_INTERFACE_ERRORS
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmassubd_assign_sub_comp_data (
    org_id		NUMBER,
    all_org		NUMBER := 2,
    user_id		NUMBER,
    login_id		NUMBER,
    prog_appid		NUMBER,
    prog_id		NUMBER,
    req_id		NUMBER,
    err_text	IN OUT 	VARCHAR2
)
    return INTEGER
IS
    curr_org_id	NUMBER;
    curr_txn_id	NUMBER;
    ret_code    NUMBER;
    dummy_txn   NUMBER;
    commit_cnt  NUMBER;
    continue_loop BOOLEAN := TRUE;
    total_recs  NUMBER;

    CURSOR c0 is
	select organization_id OI, substitute_comp_number SCN,
		substitute_component_id SCI, transaction_id TI
	from bom_sub_comps_interface
	where process_flag = 1
	and   substitute_component_id is null
	and   (all_org = 1
		or
		(all_org = 2 and organization_id = org_id)
	      )
	and rownum < 500;

    CURSOR c1 is
	select  component_sequence_id CSI,
		transaction_id TI, organization_id OI,
                bill_sequence_id BSI, assembly_item_id AII,
                assembly_item_number AIN, alternate_bom_designator ABD,
                component_item_id CII, component_item_number CIN,
                operation_seq_num OSN,
                to_char(effectivity_date,'YYYY/MM/DD HH24:MI') ED
	from bom_sub_comps_interface
	where process_flag = 1
        and component_sequence_id is null
	and   (all_org = 1
		or
		(all_org = 2 and organization_id = org_id)
	      )
	and rownum < 500;

    CURSOR c2 is
	select transaction_id TI, organization_id OI,
               component_sequence_id CSI, substitute_item_quantity SIQ
	from bom_sub_comps_interface
	where process_flag = 1
        and component_sequence_id is not null
	and   (all_org = 1
		or
		(all_org = 2 and organization_id = org_id)
	      )
	and rownum < 500;

    CURSOR c3 is
        select component_sequence_id CSI
        from bom_sub_comps_interface
        where process_flag = 99
        and   (all_org = 1
                or
                (all_org = 2 and organization_id = org_id)
              )
	and rownum < 500
        group by component_sequence_id;

BEGIN
/*
** first load all rows from components interface into sub comps interface
*/
    insert into bom_sub_comps_interface (
	SUBSTITUTE_COMPONENT_ID,
	SUBSTITUTE_COMP_NUMBER,
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
 	COMPONENT_SEQUENCE_ID,
	PROCESS_FLAG,
        SUBSTITUTE_ITEM_QUANTITY)
        select
	SUBSTITUTE_COMP_ID,
	SUBSTITUTE_COMP_NUMBER,
	ORGANIZATION_ID,
	NVL(LAST_UPDATE_DATE, SYSDATE),
	NVL(LAST_UPDATED_BY, user_id),
	NVL(CREATION_DATE,SYSDATE),
	NVL(CREATED_BY, user_id),
	NVL(LAST_UPDATE_LOGIN, user_id),
        NVL(REQUEST_ID, req_id),
        NVL(PROGRAM_APPLICATION_ID, prog_appid),
        NVL(PROGRAM_ID, prog_id),
        NVL(PROGRAM_UPDATE_DATE, sysdate),
	COMPONENT_SEQUENCE_ID,
	1,
        COMPONENT_QUANTITY
	from bom_inventory_comps_interface
	where process_flag = 2
	and   (substitute_comp_id is not null
		or
		substitute_comp_number is not null);

     commit;
/*
**  assign transaction ids for every row
*/
    loop
    update bom_sub_comps_interface
       set transaction_id = mtl_system_items_interface_s.nextval
      where transaction_id is null
        and process_flag = 1
    and   rownum < 500;
    EXIT when SQL%NOTFOUND;
    commit;

    end loop;
/*
** update substitute component id if null
*/
    while continue_loop loop
      commit_cnt := 0;
      for c0rec in c0 loop
        commit_cnt := commit_cnt + 1;
        ret_code := INVPUOPI.mtl_pr_parse_flex_name(
	    org_id => c0rec.OI,
	    flex_code => 'MSTK',
	    flex_name => c0rec.SCN,
	    flex_id => c0rec.SCI,
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
                        trans_id => c0rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_SUB_COMPS_INTERFACE',
                        msg_name => 'BOM_SUB_COMP_MISSING',
                        err_text => err_text);
                update bom_sub_comps_interface set
                    process_flag = 3
                where transaction_id = c0rec.TI;

                if (ret_code <> 0) then
                    return(ret_code);
                end if;
        else
	   update bom_sub_comps_interface
	      set substitute_component_id = c0rec.SCI
	    where transaction_id = c0rec.TI;
        end if;

    end loop;
    commit;
    if (commit_cnt < (500 - 1)) then
       continue_loop := FALSE;
    end if;

end loop;

/*
** Check if organization id is null
*/
    continue_loop := TRUE;
    while continue_loop loop
      commit_cnt := 0;
      for c1rec in c1 loop
        commit_cnt := commit_cnt + 1;
        if (c1rec.OI is null and (c1rec.BSI is null or c1rec.CII is null)) then
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => NULL,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_SUB_COMPS_INTERFACE',
                        msg_name => 'BOM_ORG_ID_MISSING',
                        err_text => err_text);
            update bom_sub_comps_interface set
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
        if (c1rec.AII is null and c1rec.BSI is null) then
           ret_code := INVPUOPI.mtl_pr_parse_flex_name(
                org_id=> c1rec.OI,
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
                        tbl_name => 'BOM_SUB_COMPS_INTERFACE',
                        msg_name => 'BOM_ASSY_ITEM_MISSING',
                        err_text => err_text);
                update bom_sub_comps_interface set
                    process_flag = 3
                where transaction_id = c1rec.TI;

                if (ret_code <> 0) then
                    return(ret_code);
                end if;
                goto continue_loop;
            end if;
        end if;

/*
**  Get bill sequence id
*/

     if (c1rec.BSI is null) then
        ret_code := bmgblsq_get_bill_sequence(
                    org_id => c1rec.OI,
                    item_id => c1rec.AII,
                    alt_desg => c1rec.ABD,
                    bill_seq_id => c1rec.BSI,
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
                      tbl_name => 'BOM_SUB_COMPS_INTERFACE',
                      msg_name => 'BOM_BILL_SEQ_MISSING',
                      err_text => err_text);
            update bom_sub_comps_interface set
                   process_flag = 3
             where transaction_id = c1rec.TI;

            if (ret_code <> 0) then
                return(ret_code);
            end if;
            goto continue_loop;
        end if;
      end if;

/*
**  Set component item id
*/

        if (c1rec.CII is null) then
           ret_code := INVPUOPI.mtl_pr_parse_flex_name(
                org_id=> c1rec.OI,
                flex_code => 'MSTK',
                flex_name => c1rec.CIN,
                flex_id => c1rec.CII,
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
                        tbl_name => 'BOM_SUB_COMPS_INTERFACE',
                        msg_name => 'BOM_COMP_ID_MISSING',
                        err_text => err_text);
                update bom_sub_comps_interface set
                    process_flag = 3
                where transaction_id = c1rec.TI;

                if (ret_code <> 0) then
                    return(ret_code);
                end if;
                goto continue_loop;
            end if;
        end if;

/*
**  Get component sequence id
*/
        ret_code := bmgcpsq_get_comp_sequence(
                    bill_seq_id => c1rec.BSI,
                    op_seq => c1rec.OSN,
                    cmp_id => c1rec.CII,
                    eff_date => c1rec.ED,
                    cmp_seq_id => c1rec.CSI,
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
                      tbl_name => 'BOM_SUB_COMPS_INTERFACE',
                      msg_name => 'BOM_COMP_SEQ_MISSING',
                      err_text => err_text);
            update bom_sub_comps_interface set
                    process_flag = 3
             where transaction_id = c1rec.TI;

            if (ret_code <> 0) then
                return(ret_code);
            end if;
            goto continue_loop;
        end if;

        update bom_sub_comps_interface
           set component_sequence_id = c1rec.CSI,
               assembly_item_id = c1rec.AII,
               component_item_id = c1rec.CII,
               bill_sequence_id = c1rec.BSI
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
** Set substitute component quantity if null
** Set default values and process_flag for valid records
*/
    continue_loop := TRUE;
    while continue_loop loop
      commit_cnt := 0;
      for c2rec in c2 loop
        commit_cnt := commit_cnt + 1;
        if (c2rec.SIQ is null) then
           ret_code := bmgcpqy_get_comp_quantity(
              comp_seq_id => c2rec.CSI,
              comp_qty => c2rec.SIQ,
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
                      tbl_name => 'BOM_SUB_COMPS_INTERFACE',
                      msg_name => 'BOM_SUB_COMP_QTY_MISSING',
                      err_text => err_text);
           update bom_sub_comps_interface set
              process_flag = 3
           where transaction_id = c2rec.TI;

           if (ret_code <> 0) then
              return(ret_code);
           end if;
           goto continue_loop2;
       end if;
    end if;

    update bom_sub_comps_interface
       set process_flag = 99,
           substitute_item_quantity = nvl(c2rec.SIQ,substitute_item_quantity),
           last_update_date = nvl(last_update_date,sysdate),
           last_updated_by = nvl(last_updated_by,user_id),
           creation_date = nvl(creation_date,sysdate),
           created_by = nvl(created_by,user_id),
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
** Set records with same component_sequence_id with the same txn id
** for set processing
*/
select count(distinct component_sequence_id)
  into total_recs
  from bom_sub_comps_interface
 where process_flag = 99;

continue_loop := TRUE;
commit_cnt := 0;

while continue_loop loop
      for c3rec in c3 loop
        commit_cnt := commit_cnt + 1;
        select mtl_system_items_interface_s.nextval
          into dummy_txn
          from sys.dual;

        update bom_sub_comps_interface
           set transaction_id = dummy_txn,
               process_flag = 2
         where component_sequence_id = c3rec.CSI
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
        err_text := 'BOMPASGB(bmassubd) ' || substrb(SQLERRM, 1, 60);
        return(SQLCODE);

END bmassubd_assign_sub_comp_data;


END BOMPASGB;

/
