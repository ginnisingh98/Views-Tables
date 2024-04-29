--------------------------------------------------------
--  DDL for Package Body BOMPVALB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOMPVALB" as
/* $Header: BOMVALBB.pls 115.4 99/07/16 05:16:42 porting sh $ */
/*==========================================================================+
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMPVALB.plb                                         |
| DESCRIPTION  : This package contains functions used to validate bill      |
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
|    11/22/93   Shreyas Shah	creation date                               |
|    04/24/94   Julie Maeyama   Modified code                               |
+==========================================================================*/
/*---------------------- bmvbomh_validate_bom_header -----------------------*/
/* NAME
    bmvbomh_validate_bom_header - validate bom data
DESCRIPTION
    validate the bom header information before loading into the
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
FUNCTION bmvbomh_validate_bom_header (
    org_id		NUMBER,
    all_org		NUMBER := 2,
    user_id		NUMBER,
    login_id		NUMBER,
    prog_appid		NUMBER,
    prog_id		NUMBER,
    request_id		NUMBER,
    err_text  IN OUT 	VARCHAR2
)
    return INTEGER
IS
    CURSOR c1 is select
	organization_id OI, bill_sequence_id BSI,
	assembly_item_id AII, common_bill_sequence_id CBSI,
	common_assembly_item_id CAII, assembly_type AST,
	common_organization_id COI,
	alternate_bom_designator ABD, transaction_id TI
	from bom_bill_of_mtls_interface
	where process_flag = 2
        and rownum < 500;

    ret_code 		NUMBER;
    stmt_num		NUMBER;
    dummy_id            NUMBER;
    commit_cnt  	NUMBER;
    continue_loop 	BOOLEAN := TRUE;
BEGIN
/*
** do row by row verification
*/
    while continue_loop loop
      commit_cnt := 0;
      for c1rec in c1 loop
 	commit_cnt := commit_cnt + 1;
	stmt_num := 1;       /* Check for valid org id */
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
                        tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
                        msg_name => 'BOM_INVALID_ORG_ID',
                        err_text => err_text);
               update bom_bill_of_mtls_interface set
                       process_flag = 3
               where transaction_id = c1rec.TI;

               if (ret_code <> 0) then
                   return(ret_code);
               end if;
               goto continue_loop;
        END;

        stmt_num := 2;
        if (c1rec.ABD is not null) then     /* Check for valid alternate */
           BEGIN
              select 1
                into dummy_id
                from bom_alternate_designators
               where organization_id = c1rec.OI
                 and alternate_designator_code = c1rec.ABD;
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
                        tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
                        msg_name => 'BOM_INVALID_ALTERNATE',
                        err_text => err_text);
                  update bom_bill_of_mtls_interface set
                          process_flag = 3
                  where transaction_id = c1rec.TI;

                  if (ret_code <> 0) then
                      return(ret_code);
                  end if;
                  goto continue_loop;
           END;
         end if;

        stmt_num := 3;                    /* Check if assembly item exists */
        ret_code := bmvassyid_verify_assembly_id(
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
                        tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
                        msg_name => 'BOM_ASSEMBLY_ITEM_INVALID',
                        err_text => err_text);
            update bom_bill_of_mtls_interface set
                    process_flag = 3
            where transaction_id = c1rec.TI;

            if (ret_code <> 0) then
                return(ret_code);
            end if;
            goto continue_loop;
        end if;

        stmt_num := 4;  /* assembly_type must be 1 or 2 */
        if (c1rec.AST <> 1) and (c1rec.AST <> 2) then
           ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c1rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => request_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
                        msg_name => 'BOM_ASSEMBLY_TYPE_INVALID',
                        err_text => err_text);
            update bom_bill_of_mtls_interface set
                    process_flag = 3
            where transaction_id = c1rec.TI;

            if (ret_code <> 0) then
                return(ret_code);
            end if;
            goto continue_loop;
         end if;

        stmt_num := 5;
	ret_code :=bmvrbom_verify_bom(    /* Check for unique bill seq id */
		bom_seq_id => c1rec.BSI,
		mode_type => 1,
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
			tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
			msg_name => 'BOM_DUPLICATE_BILL',
			err_text => err_text);
	    update bom_bill_of_mtls_interface set
		    process_flag = 3
	    where transaction_id = c1rec.TI;

	    if (ret_code <> 0) then
	        return(ret_code);
	    end if;
	    goto continue_loop;
	end if;

        stmt_num := 6;
/*
** Check for duplicate assy,org,alt combo
** Check for primary/alternate violation
*/
	ret_code :=bmvdupbom_verify_duplicate_bom(
		org_id => c1rec.OI,
		assy_id => c1rec.AII,
		alt_desg => c1rec.ABD,
                assy_type => c1rec.AST,
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
			tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
			msg_name => 'BOM_BILL_VALIDATION_ERR',
			err_text => err_text);
	    update bom_bill_of_mtls_interface set
		    process_flag = 3
	    where transaction_id = c1rec.TI;

	    if (ret_code <> 0) then
	        return(ret_code);
	    end if;
	    goto continue_loop;
	end if;

        stmt_num := 7;        /* Check assembly type and BOM enabled flag */
	ret_code :=bmvbitm_verify_assembly_type(
	   	org_id => c1rec.OI,
		assy_id => c1rec.AII,
		assy_type => c1rec.AST,
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
			tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
			msg_name => 'BOM_ASSY_TYPE_ERR',
			err_text => err_text);
	    update bom_bill_of_mtls_interface set
		    process_flag = 3
	    where transaction_id = c1rec.TI;

	    if (ret_code <> 0) then
	        return(ret_code);
	    end if;
	    goto continue_loop;
	end if;

        stmt_num := 8;
        if c1rec.BSI = c1rec.CBSI then
           NULL;
        else
           ret_code :=bmvrbom_verify_bom(  /* Check cmn bill seq id existence*/
                bom_seq_id => c1rec.CBSI,
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
                        tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
                        msg_name => 'BOM_COMMON_BILL_NOT_EXIST',
                        err_text => err_text);
                update bom_bill_of_mtls_interface set
                    process_flag = 3
                 where transaction_id = c1rec.TI;

                if (ret_code <> 0) then
                   return(ret_code);
                end if;
                goto continue_loop;
           end if;

           stmt_num := 9;  /* Verify common bill attributes */
   	   ret_code :=bmvcmbom_verify_common_bom(
		   bom_id => c1rec.BSI,
       		   cmn_bom_id => c1rec.CBSI,
		   bom_type => c1rec.AST,
		   item_id => c1rec.AII,
		   cmn_item_id => c1rec.CAII,
		   org_id => c1rec.OI,
		   cmn_org_id => c1rec.COI,
		   alt_desg => c1rec.ABD,
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
			tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
			msg_name => 'BOM_COMMON_BOM_ERROR',
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

     stmt_num := 10;
     update bom_bill_of_mtls_interface
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
	err_text := 'BOMPVALB(bmvbomh-' || stmt_num || ') ' || substrb(SQLERRM,1,60);
	return(SQLCODE);
END bmvbomh_validate_bom_header;


/*---------------------- bmvassyid_verify_assembly_id -----------------------*/
/* NAME
    bmvassyid_verify_assembly_id - verify assembly item id exists in item
                                   master
DESCRIPTION
    Verifies in MTL_SYSTEM_ITEMS if assembly item exists.

REQUIRES
    org_id      organization_id
    assy_id     assembly_item_id
    err_text    out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    SQLCODE if error
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmvassyid_verify_assembly_id(
        org_id          NUMBER,
        assy_id         NUMBER,
        err_text  OUT   VARCHAR2
)
    return INTEGER
IS
    cnt         NUMBER := 0;
BEGIN
        select inventory_item_id
        into cnt
        from mtl_system_items
        where organization_id = org_id
        and   inventory_item_id = assy_id;
        return(0);
EXCEPTION
        when NO_DATA_FOUND then
            err_text := 'BOMPVALB(bmvassyid): Assembly item does not exist';
            return(9999);
        when others then
            err_text := 'BOMPVALB(bmvassyid) ' || substrb(SQLERRM,1,60);
            return(SQLCODE);

END bmvassyid_verify_assembly_id;

/*--------------------------- bmvrbom_verify_bom ----------------------------*/
/* NAME
    bmvrbom_verify_bom - verify for uniqueness or existence of bom
	sequence id
DESCRIPTION
    verifies if the given bom sequence id is unique in prod and
	interface tables

REQUIRES
    bom_sq_id   bom_sequecne_id
    mode_type	1 - verify uniqueness of bom
		2 - verify existence of bom
    err_text 	out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    count of routings with same bom_sequence_id if any found
    SQLCODE if error
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmvrbom_verify_bom(
	bom_seq_id	NUMBER,
	mode_type	NUMBER,
	err_text  OUT	VARCHAR2
)
    return INTEGER
IS
    cnt		NUMBER := 0;
    NOT_UNIQUE  EXCEPTION;
BEGIN
/*
** first check in prod tables
*/
    BEGIN
    	select bill_sequence_id
	into cnt
	from bom_bill_of_materials
	where bill_sequence_id = bom_seq_id;
	if (mode_type = 2) then
	    return(0);
	else
            raise NOT_UNIQUE;
	end if;
    EXCEPTION
	when NO_DATA_FOUND then
	    NULL;
        when NOT_UNIQUE then
            raise NOT_UNIQUE;
	when others then
	    err_text := 'BOMPVALB(bmvrbom) ' || substrb(SQLERRM,1,60);
	    return(SQLCODE);
    END;

/*
** check in interface table
*/
    select count(*)
	into cnt
	from bom_bill_of_mtls_interface
	where bill_sequence_id = bom_seq_id
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
	err_text := substrb('BOMPVALB(bmvrbom): Bill does not exist ' || SQLERRM,1,70);
	return(9999);
    when NOT_UNIQUE then
	err_text := 'BOMPVALB(bmvrbom) ' || 'Duplicate bill sequence id';
	return(9999);
    when others then
	err_text := 'BOMPVALB(bmvrbom) ' || substrb(SQLERRM,1,60);
    	return(SQLCODE);
END bmvrbom_verify_bom;

/*--------------------- bmvdupbom_verify_duplicate_bom ----------------------*/
/* NAME
    bmvdupbom_verify_duplicate_bom - verify if there is another bom
	with same alt.
DESCRIPTION
    Verifies in the production and interface tables if bom with
    same alt exists.  Also verifies for an alternate bom, if the
    primary already exists.

REQUIRES
    org_id	organization_id
    assy_id	assembly_item_id
    alt_desg	alternate routing designator
    err_text 	out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    cnt  if bom already exists
    9999 if primary does not exist
    SQLCODE if error
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmvdupbom_verify_duplicate_bom(
	org_id		NUMBER,
	assy_id		NUMBER,
	alt_desg  	VARCHAR2,
        assy_type       NUMBER,
	err_text  OUT 	VARCHAR2
)
    return INTEGER
IS
    cnt		NUMBER := 0;
    ALREADY_EXISTS EXCEPTION;
BEGIN
    begin
        select bill_sequence_id
	into cnt
	from bom_bill_of_materials
	where organization_id = org_id
	and   assembly_item_id = assy_id
	and   nvl(alternate_bom_designator, 'NONE') =
		nvl(alt_desg, 'NONE');
	raise ALREADY_EXISTS;
    exception
        when ALREADY_EXISTS then
          err_text := 'BOMPVALB(bmvdupbom): Bill already exists in production';
          return(cnt);
	when NO_DATA_FOUND then
	    NULL;
	when others then
	    err_text := 'BOMPVALB(bmvdupbom) ' || substrb(SQLERRM,1,60);
	    return(SQLCODE);
    end;

    begin
        select bill_sequence_id
	into cnt
	from bom_bill_of_mtls_interface
	where organization_id = org_id
	and   assembly_item_id = assy_id
	and   nvl(alternate_bom_designator, 'NONE') =
		nvl(alt_desg, 'NONE')
        and   rownum = 1
	and   process_flag = 4;

	raise ALREADY_EXISTS;
    exception
        when ALREADY_EXISTS then
          err_text := 'BOMPVALB(bmvdupbom): Bill already exists in interface';
          return(cnt);
	when NO_DATA_FOUND then
	    NULL;
	when others then
	    err_text := 'BOMPVALB(bmvdupbom) ' || substrb(SQLERRM,1,60);
	    return(SQLCODE);
    end;

/*
** for alternate bills, verify if primary exists (or will exist)
** Alternate mfg bills cannot have primary eng bills
*/
    if (alt_desg is not null) then
	begin
	    select bill_sequence_id
	    into cnt
	    from bom_bill_of_materials
	    where organization_id = org_id
	    and   assembly_item_id = assy_id
	    and   alternate_bom_designator is null
            and   ((assy_type = 2)
                  or
                   (assy_type =1 and assembly_type = 1)
                  );
	    return(0);
	exception
	    when NO_DATA_FOUND then
	 	NULL;
	    when others then
		err_text := 'BOMPVALB(bmvdupbom) ' || substrb(SQLERRM,1,60);
		return(SQLCODE);
	end;

	begin
	    select bill_sequence_id
	    into cnt
	    from bom_bill_of_mtls_interface
	    where organization_id = org_id
	    and   assembly_item_id = assy_id
	    and   alternate_bom_designator is null
            and   ((assy_type = 2)
                  or
                   (assy_type =1 and assembly_type = 1)
                  )
	    and   process_flag = 4
	    and   rownum = 1;
	exception
	    when NO_DATA_FOUND then
	     err_text := 'BOMPVALB(bmvdupbom): Valid primary does not exist';
		return(9999);
	    when others then
		err_text := 'BOMPVALB(bmvdupbom) ' || substrb(SQLERRM,1,60);
		return(SQLCODE);
	end;
    end if;

    return(0);

EXCEPTION
    when others then
	err_text := 'BOMPVALB(bmvdupbom) ' || substrb(SQLERRM,1,60);
    	return(SQLCODE);
END bmvdupbom_verify_duplicate_bom;


/*--------------------- bmvbitm_verify_assembly_type ----------------------*/
/* NAME
     bmvbitm_verify_assembly_type - verify assembly type
DESCRIPTION
     a bom can be defined only if the bom_enabled_flag = 'Y.
     Also verifies if assembly_type = mfg, then item must also be mfg.

REQUIRES
    assy_type   assembly_type
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
FUNCTION bmvbitm_verify_assembly_type(
	org_id		NUMBER,
	assy_id		NUMBER,
	assy_type	NUMBER,
	err_text  OUT 	VARCHAR2
)
    return INTEGER
IS
    cnt 	NUMBER := 0;
BEGIN
    select 1
       into cnt
       from mtl_system_items
      where organization_id = org_id
	and inventory_item_id = assy_id
	and bom_enabled_flag = 'Y'
	and ((assy_type = 2)
	     or
	     (assy_type = 1 and
              eng_item_flag = 'N')
	    );
       return(0);

    EXCEPTION
      when NO_DATA_FOUND then
        err_text := 'BOMPVALB(bmvbitm): Assembly type invalid or item not BOM enabled';
        return(9999);
      when others then
        err_text := 'BOMPVALB(bmvbitm) ' || substrb(SQLERRM,1,60);
        return(SQLCODE);

END bmvbitm_verify_assembly_type;

/*----------------------- bmvcmbom_verify_common_bom ------------------------*/
/* NAME
    bmvcmbom_verify_common_bom - verify common_bom
DESCRIPTION
    if bom is mfg then it cannot point to engineerging bom
    if common bom then bill cannot have components
    if inter-org common then all components items must be in both orgs
    Common bill's org and current bill's org must have same master org
    Common bill's alt must be same as current bill's alt
    Common bill cannot have same assembly_item_id/org_id as current bill
    Common bill cannot reference a common bill

REQUIRES
    bom_id	bill_sequence_id
    cmn_bom_id  common bill_seqience_id
    bom_type    assembly_type
    item_id     assembly item id
    cmn_item_id common item id
    org_id      org id
    cmn_org_id  common org id
    err_text 	out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    9999 if invalid item
    SQLCODE if error
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmvcmbom_verify_common_bom(
	bom_id		NUMBER,
	cmn_bom_id	NUMBER,
	bom_type	NUMBER,
	item_id		NUMBER,
	cmn_item_id	NUMBER,
	org_id		NUMBER,
	cmn_org_id	NUMBER,
        alt_desg	VARCHAR2,
	err_text  OUT	VARCHAR2
)
    return INTEGER
IS
    cnt		         NUMBER;
    bit			 NUMBER;
    base_id		 NUMBER;
    ato		    VARCHAR2(1);
    pto		    VARCHAR2(1);
    MISSING_ITEMS     EXCEPTION;
    MISSING_SUB_ITEMS EXCEPTION;

BEGIN
/*
** Common bill's org and current bill's org must have same master org
*/
    begin
        select 1
          into cnt
          from mtl_parameters mp1, mtl_parameters mp2
         where mp1.organization_id = org_id
           and mp2.organization_id = cmn_org_id
           and mp1.master_organization_id = mp2.master_organization_id;
    exception
       when NO_DATA_FOUND then
            err_text := 'BOMPVALB(bmvcmbom): Invalid common master org id';
            return(9999);
       when others then
            err_text := 'BOMPVALB(bmvcmbom) ' || substrb(SQLERRM,1,60);
            return(SQLCODE);
    end;
/*
** Common bill's alt must be same as current bill's alt
** Common bill cannot have same assembly_item_id/org_id as current bill
** Common bill must be mfg bill if current bill is a mfg bill
** Common bill cannot reference a common bill
** Common bill sequence id must have the correct common_assembly_item_id
**  and common_organization_id
*/
    begin
        select bill_sequence_id
	into cnt
	from bom_bill_of_materials
	where bill_sequence_id = cmn_bom_id
        and   assembly_item_id = cmn_item_id
        and   organization_id  = cmn_org_id
	and   nvl(alternate_bom_designator, 'NONE') =
		nvl(alt_desg, 'NONE')
        and   common_bill_sequence_id = bill_sequence_id
        and   (assembly_item_id <> item_id
               or
               organization_id <> org_id
               )
	and   ((bom_type <> 1)
		or
  	       (bom_type = 1
		and
		assembly_type = 1
	       )
	      );
        goto check_ops;
    exception
	when NO_DATA_FOUND then
	    NULL;
	when others then
	    err_text := 'BOMPVALB(bmvmbom) ' || substrb(SQLERRM,1,60);
	    return(SQLCODE);
    end;

        select bill_sequence_id
	into cnt
	from bom_bill_of_mtls_interface
	where bill_sequence_id = cmn_bom_id
        and   assembly_item_id = cmn_item_id
        and   organization_id  = cmn_org_id
	and   nvl(alternate_bom_designator, 'NONE') =
		nvl(alt_desg, 'NONE')
        and   common_bill_sequence_id = bill_sequence_id
        and   (assembly_item_id <> item_id
               or
               organization_id <> org_id
               )
	and   process_flag = 4
	and   ((bom_type <> 1)
		or
  	       (bom_type = 1
		and
		assembly_type = 1
	       )
	      );

<<check_ops>>

/*
** check to see if components exist in both orgs for inter-org commons
*/
    if (org_id <> cmn_org_id) then

	/* Get item attributes for the bill */
        select bom_item_type, base_item_id, replenish_to_order_flag,
               pick_components_flag
          into bit, base_id, ato, pto
          from mtl_system_items
         where inventory_item_id = item_id
           and organization_id = org_id;

        select count(*)
	    into cnt
	    from bom_inventory_components bic
	    where bic.bill_sequence_id = cmn_bom_id
              and NOT EXISTS
                 (SELECT 'x'
                    FROM MTL_SYSTEM_ITEMS S
                   WHERE S.ORGANIZATION_ID = org_id
                     AND S.INVENTORY_ITEM_ID = bic.COMPONENT_ITEM_ID
                     AND   ((bom_type = 1
                             AND S.ENG_ITEM_FLAG = 'N')
                            OR (bom_type = 2))
                     AND  S.BOM_ENABLED_FLAG = 'Y'
                     AND  S.INVENTORY_ITEM_ID <> item_id
                     AND ((bit = 1
                           AND S.BOM_ITEM_TYPE <> 3)
                         OR (bit = 2
                             AND S.BOM_ITEM_TYPE <> 3)
                         OR (bit = 3)
                         OR (bit = 4
                             AND (S.BOM_ITEM_TYPE = 4
                                 OR (S.BOM_ITEM_TYPE IN (2, 1)
                                     AND S.REPLENISH_TO_ORDER_FLAG = 'Y'
                                     AND base_id IS NOT NULL
                                     AND ato = 'Y')))
                             )
                     AND (bit = 3
                          OR
                          pto = 'Y'
                          OR
                          S.PICK_COMPONENTS_FLAG = 'N')
                     AND (bit = 3
                          OR
                          NVL(S.BOM_ITEM_TYPE, 4) <> 2
                          OR
                          (S.BOM_ITEM_TYPE = 2
                           AND ((pto = 'Y'
                                 AND S.PICK_COMPONENTS_FLAG = 'Y')
                               OR (ato = 'Y'
                                   AND S.REPLENISH_TO_ORDER_FLAG = 'Y'))))
                     AND NOT(bit = 4
                             AND pto = 'Y'
                             AND S.BOM_ITEM_TYPE = 4
                             AND S.REPLENISH_TO_ORDER_FLAG = 'Y')
	 	);

	if (cnt > 0) then
	    raise MISSING_ITEMS;
	end if;

        select count(*)
	    into cnt
	    from bom_inventory_comps_interface bic
	    where bill_sequence_id = cmn_bom_id
	    and process_flag in (2, 4)
            and NOT EXISTS
                 (SELECT 'x'
                    FROM MTL_SYSTEM_ITEMS S
                   WHERE S.ORGANIZATION_ID = org_id
                     AND S.INVENTORY_ITEM_ID = bic.COMPONENT_ITEM_ID
                     AND   ((bom_type = 1
                             AND S.ENG_ITEM_FLAG = 'N')
                            OR (bom_type = 2))
                     AND  S.BOM_ENABLED_FLAG = 'Y'
                     AND  S.INVENTORY_ITEM_ID <> item_id
                     AND ((bit = 1
                           AND S.BOM_ITEM_TYPE <> 3)
                         OR (bit = 2
                             AND S.BOM_ITEM_TYPE <> 3)
                         OR (bit = 3)
                         OR (bit = 4
                             AND (S.BOM_ITEM_TYPE = 4
                                 OR (S.BOM_ITEM_TYPE IN (2, 1)
                                     AND S.REPLENISH_TO_ORDER_FLAG = 'Y'
                                     AND base_id IS NOT NULL
                                     AND ato = 'Y')))
                             )
                     AND (bit = 3
                          OR
                          pto = 'Y'
                          OR
                          S.PICK_COMPONENTS_FLAG = 'N')
                     AND (bit = 3
                          OR
                          NVL(S.BOM_ITEM_TYPE, 4) <> 2
                          OR
                          (S.BOM_ITEM_TYPE = 2
                           AND ((pto = 'Y'
                                 AND S.PICK_COMPONENTS_FLAG = 'Y')
                               OR (ato = 'Y'
                                   AND S.REPLENISH_TO_ORDER_FLAG = 'Y'))))
                     AND NOT(bit = 4
                             AND pto = 'Y'
                             AND S.BOM_ITEM_TYPE = 4
                             AND S.REPLENISH_TO_ORDER_FLAG = 'Y')
	 	);

	if (cnt > 0) then
	    raise MISSING_ITEMS;
	end if;

    end if;
/*
** check if substitute components exist in both orgs for inter-org commons
*/
    if (org_id <> cmn_org_id) then    /* Comp and sub comp in production */
        select count(*)
          into cnt
          from bom_inventory_components bic,
               bom_substitute_components bsc
         where bic.bill_sequence_id = cmn_bom_id
           and bic.component_sequence_id = bsc.component_sequence_id
           and bsc.substitute_component_id not in
               (select msi1.inventory_item_id
                  from mtl_system_items msi1, mtl_system_items msi2
                 where msi1.organization_id = org_id
                   and   msi1.inventory_item_id = bsc.substitute_component_id
                   and   msi2.organization_id = cmn_org_id
                   and   msi2.inventory_item_id = msi1.inventory_item_id);
        if (cnt > 0) then
            raise MISSING_SUB_ITEMS;
        end if;

        select count(*)              /* Comp and sub comp in interface */
            into cnt
            from bom_inventory_comps_interface bic,
                 bom_sub_comps_interface bsc
            where bic.bill_sequence_id = cmn_bom_id
            and bic.process_flag in (2, 4)
            and bsc.process_flag in (2, 4)
            and bic.component_sequence_id = bsc.component_sequence_id
            and bsc.substitute_component_id not in
                (select msi1.inventory_item_id
                   from mtl_system_items msi1, mtl_system_items msi2
                  where msi1.organization_id = org_id
                    and   msi1.inventory_item_id = bsc.substitute_component_id
                    and   msi2.organization_id = cmn_org_id
                    and   msi2.inventory_item_id = msi1.inventory_item_id);
        if (cnt > 0) then
            raise MISSING_SUB_ITEMS;
        end if;

        select count(*)   /* Comp in production and sub comp in interface */
            into cnt
            from bom_inventory_components bic,
                 bom_sub_comps_interface bsc
            where bic.bill_sequence_id = cmn_bom_id
            and bsc.process_flag in (2, 4)
            and bic.component_sequence_id = bsc.component_sequence_id
            and bsc.substitute_component_id not in
                (select msi1.inventory_item_id
                   from mtl_system_items msi1, mtl_system_items msi2
                  where msi1.organization_id = org_id
                    and   msi1.inventory_item_id = bsc.substitute_component_id
                    and   msi2.organization_id = cmn_org_id
                    and   msi2.inventory_item_id = msi1.inventory_item_id);
        if (cnt > 0) then
            raise MISSING_SUB_ITEMS;
        end if;


    end if;

/*
** check to see if bill item and common item have same bom_item_type,
** pick_components_flag and replenish_to_order_flag
** Common item must have bom_enabled_flag = 'Y'
*/
    begin
    	select 1
	into cnt
	from mtl_system_items msi1, mtl_system_items msi2
	where msi1.organization_id = org_id
	and   msi1.inventory_item_id = item_id
	and   msi2.organization_id = cmn_org_id
	and   msi2.inventory_item_id = cmn_item_id
        and   msi2.bom_enabled_flag = 'Y'
	and   msi1.bom_item_type = msi2.bom_item_type
	and   msi1.pick_components_flag = msi2.pick_components_flag
	and   msi1.replenish_to_order_flag = msi2.replenish_to_order_flag;
    exception
	when NO_DATA_FOUND then
	    err_text := 'BOMPVALB(bmvcmbom): Invalid item attributes';
	    return(9999);
	when others then
	    err_text := 'BOMPVALB(bmvcmbom) ' || substrb(SQLERRM,1,60);
	    return(SQLCODE);
    end;

    return(0);
EXCEPTION
    when NO_DATA_FOUND then
	err_text := 'BOMPVALB(bmvcmbom):Invalid common bill';
	return(9999);
    when MISSING_ITEMS then
	err_text := 'BOMPVALB(bmvcmbom): Component items not in both orgs or invalid';
	return(9999);
    when MISSING_SUB_ITEMS then
        err_text := 'BOMPVALB(bmvcmbom): Substitute items not in both orgs';
        return(9999);
    when others then
	err_text := 'BOMPVALB(bmvcmbom) ' || substrb(SQLERRM,1,60);
	return(SQLCODE);
END bmvcmbom_verify_common_bom;

/*---------------------- bmvcomp_validate_components -----------------------*/
/* NAME
    bmvcomp_validate_components - validate component data
DESCRIPTION
    validate the component data in the interface tables before loading
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
FUNCTION bmvcomp_validate_components (
    org_id		NUMBER,
    all_org		NUMBER := 2,
    user_id		NUMBER,
    login_id		NUMBER,
    prog_appid		NUMBER,
    prog_id		NUMBER,
    request_id		NUMBER,
    err_text	IN OUT 	VARCHAR2
)
    return INTEGER
IS
    ret_code		NUMBER;
    ret_code_error	exception; -- ret_code <> 0
    stmt_num		NUMBER := 0;
    dummy		VARCHAR2(50);
    eng_bill            NUMBER;
    oe_install          VARCHAR2(1);
    commit_cnt  	constant NUMBER := 500; -- commit every 500 rows
    inv_asst            VARCHAR2(1);
    r_subinv            NUMBER;
    r_loc               NUMBER;
    loc_ctl             NUMBER;
    org_loc             NUMBER;
    sub_loc_code        NUMBER;
    X_expense_to_asset_transfer NUMBER;
    continue_loop 	exception;
    write_loc_error     exception;
    write_subinv_error  exception;
    update_comp         exception;

    cursor c1 is
	select component_sequence_id CSI, bill_sequence_id BSI,
		transaction_id TI,
                to_char(effectivity_date,'YYYY/MM/DD HH24:MI') ED,
                effectivity_date EDD,
		to_char(disable_date,'YYYY/MM/DD HH24:MI') DD,
                to_char(implementation_date,'YYYY/MM/DD HH24:MI') ID,
                operation_seq_num OSN, supply_locator_id SLI,
                supply_subinventory SS,
		msic.organization_id OI, component_item_id CII,
		assembly_item_id AII, alternate_bom_designator ABD,
		planning_factor PF, optional O, check_atp CATP,
		msic.atp_flag AF, so_basis SB, required_for_revenue RFR,
		required_to_ship RTS, mutually_exclusive_options MEO,
                low_quantity LQ, high_quantity HQ,
		quantity_related QR, include_in_cost_rollup ICR,
		shipping_allowed SA, include_on_ship_docs ISD,
                component_yield_factor CYF, ici.wip_supply_type WST,
		component_quantity CQ, msic.bom_item_type BITC,
		msic.pick_components_flag PCF, msia.bom_item_type BITA,
                msia.pick_components_flag PCFA,
		msia.replenish_to_order_flag RTOF,
		msic.replenish_to_order_flag RTOFC,
                msia.atp_components_flag ACF,
                msic.ato_forecast_control AFC
        from    mtl_system_items msic,
		mtl_system_items msia,
                bom_inventory_comps_interface ici
	where process_flag = 2
	and   msic.organization_id = ici.organization_id
        and   msia.organization_id = ici.organization_id
	and   msic.inventory_item_id = ici.component_item_id
	and   msia.inventory_item_id = ici.assembly_item_id;

BEGIN
      for c1rec in c1 loop
      Begin
/*
** verify for uniqueness of component seq ID
*/
        stmt_num := 1;
     	ret_code := BOMPVALB.bmvuncmp_verify_unique_comp (
		cmp_seq_id => c1rec.CSI,
		exist_flag => 2,
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
			tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
			msg_name => 'BOM_COMP_SEQ_ID_DUPLICATE',
			err_text => err_text);
	    update bom_inventory_comps_interface set
		    process_flag = 3
	    where transaction_id = c1rec.TI;

	    if (ret_code <> 0) then
	        raise ret_code_error;
	    end if;
	    raise continue_loop;
	end if;
/*
** verify uniqueness of bill seq id,effective date,op seq, and component item
*/
    stmt_num := 2;
        ret_code := BOMPVALB.bmvdupcmp_verify_duplicate_cmp (
                bill_seq_id => c1rec.BSI,
                eff_date => c1rec.ED,
                cmp_item_id => c1rec.CII,
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
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_COMPONENT_DUPLICATE',
                        err_text => err_text);
            update bom_inventory_comps_interface set
                    process_flag = 3
            where transaction_id = c1rec.TI;

            if (ret_code <> 0) then
                raise ret_code_error;
            end if;
            raise continue_loop;
        end if;
/*
** check for existence of bill
*/
    stmt_num := 3;
	ret_code :=bmvrbom_verify_bom(
		bom_seq_id => c1rec.BSI,
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
			tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
			msg_name => 'BOM_BILL_SEQ_MISSING',
			err_text => err_text);
	    update bom_inventory_comps_interface set
		    process_flag = 3
	    where transaction_id = c1rec.TI;

	    if (ret_code <> 0) then
	        raise ret_code_error;
	    end if;
	    raise continue_loop;
	end if;
/*
** make sure there is no overlapping components
*/
    stmt_num := 4;
     if (c1rec.ID is not null) then
	ret_code :=bmvovlap_verify_overlaps (
		bom_id => c1rec.BSI,
		op_num => c1rec.OSN,
		cmp_id => c1rec.CII,
		eff_date => c1rec.ED,
		dis_date => c1rec.DD,
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
			tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
			msg_name => 'BOM_IMPL_COMP_OVERLAP',
			err_text => err_text);
	    update bom_inventory_comps_interface set
		    process_flag = 3
	    where transaction_id = c1rec.TI;

	    if (ret_code <> 0) then
	        raise ret_code_error;
	    end if;
	    raise continue_loop;
	end if;
     end if;
/*
** verify that the bill is not a common bill.  If so it cannot have
** components
*/
    stmt_num := 5;
  	begin
	    select 'Is pointing to a common'
	    into dummy
	    from bom_bill_of_materials
	    where bill_sequence_id = c1rec.BSI
	    and   common_bill_sequence_id <> c1rec.BSI;

	    ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c1rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => request_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_COMMON_COMP',
                        err_text => err_text);
            update bom_inventory_comps_interface set
                    process_flag = 3
            where transaction_id = c1rec.TI;

            if (ret_code <> 0) then
                raise ret_code_error;
            end if;
            raise continue_loop;
	exception
	    when NO_DATA_FOUND then
		NULL;
	end;
	begin
	    select 'Is pointing to a common'
	    into dummy
	    from bom_bill_of_mtls_interface
	    where bill_sequence_id = c1rec.BSI
            and   process_flag = 4
	    and   common_bill_sequence_id <> c1rec.BSI;

            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c1rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => request_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_COMMON_COMP',
                        err_text => err_text);
            update bom_inventory_comps_interface set
                    process_flag = 3
            where transaction_id = c1rec.TI;

            if (ret_code <> 0) then
                raise ret_code_error;
            end if;
            raise continue_loop;

	exception
	    when NO_DATA_FOUND then
		NULL;
	end;

/*
** verify the validity of item attributes
*/
    stmt_num := 6;
        declare
          Cursor CheckBOM is
            select assembly_type
            from bom_bill_of_materials
            where bill_sequence_id = c1rec.BSI;
          Cursor CheckInterface is
           select assembly_type
             from bom_bill_of_mtls_interface
            where bill_sequence_id = c1rec.BSI
              and process_flag = 4;
        begin
	   eng_bill := null;
           For X_bill in CheckBOM loop
             eng_bill := X_Bill.assembly_type;
           End loop;
           If eng_bill is null then
             For X_Interface in CheckInterface loop
               eng_bill := X_Interface.assembly_type;
             End loop;
           End if;
        end;

    stmt_num := 7;
 	ret_code := BOMPVALB.bmvitmatt_verify_item_attr (
		org_id => c1rec.OI,
		cmp_id => c1rec.CII,
                eng_bill => eng_bill,
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
			tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
			msg_name => 'BOM_INVALID_ITEM_ATTRIBUTES',
			err_text => err_text);
	    update bom_inventory_comps_interface set
		    process_flag = 3
	    where transaction_id = c1rec.TI;

	    if (ret_code <> 0) then
	        raise ret_code_error;
	    end if;
	    raise continue_loop;
	end if;

/*
** check for validity of operation sequences
*/
    stmt_num := 8;
 	ret_code := BOMPVALB.bmvopseqs_valid_op_seqs (
		org_id => c1rec.OI,
		assy_id => c1rec.AII,
		alt_desg => c1rec.ABD,
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
			tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
			msg_name => 'BOM_INVALID_OP_SEQ',
			err_text => err_text);
	    update bom_inventory_comps_interface set
		    process_flag = 3
	    where transaction_id = c1rec.TI;

	    if (ret_code <> 0) then
	        raise ret_code_error;
	    end if;
	    raise continue_loop;
	end if;
/*
** effectivity date check
*/
    stmt_num := 9;
    if (to_date(c1rec.ED,'YYYY/MM/DD HH24:MI') >
        to_date(c1rec.DD,'YYYY/MM/DD HH24:MI'))  then
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c1rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => request_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_EFFECTIVE_DATE_ERR',
                        err_text => err_text);
            update bom_inventory_comps_interface set
                    process_flag = 3
            where transaction_id = c1rec.TI;

            if (ret_code <> 0) then
              raise ret_code_error;
            end if;
            raise continue_loop;
       end if;

/*
** planning_factor can be <>100 only if
** assembly_item bom_item_type = planning bill or
** assembly_item bom_item_type = model/OC and component is optional or
** assembly_item bom_item_type = model/OC and component is mandatory and
**     component's forecast control = Consume and derive
*/
    stmt_num := 10;
   	if (c1rec.PF <> 100) then
	    if (c1rec.BITA = 3 or
		((c1rec.BITA = 1 or c1rec.BITA = 2) and c1rec.O = 1) or
                ((c1rec.BITA = 1 or c1rec.BITA = 2) and c1rec.O = 2 and
                  c1rec.AFC = 2)
               ) then
                NULL;
            else
		err_text := 'Planning percentage must be 100';
                ret_code := INVPUOPI.mtl_log_interface_err(
			org_id => c1rec.OI,
			user_id => user_id,
			login_id => login_id,
			prog_appid => prog_appid,
			prog_id => prog_id,
			req_id => request_id,
			trans_id => c1rec.TI,
			error_text => err_text,
			tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
			msg_name => 'BOM_PLANNING_FACTOR_ERR',
			err_text => err_text);
	        update bom_inventory_comps_interface set
		    process_flag = 3
	        where transaction_id = c1rec.TI;

	        if (ret_code <> 0) then
	            raise ret_code_error;
	        end if;
	        raise continue_loop;
	    end if;
	end if;
/*
** If component is an ATO Standard item and the bill is a PTO Model or
** PTO Option Class, then Optional must be Yes
*/
    stmt_num := 11;
        if (c1rec.BITC = 4 and c1rec.RTOFC = 'Y' and c1rec.BITA in (1,2)
            and c1rec.PCFA = 'Y' and c1rec.O = 2) then
                ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c1rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => request_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_OPTIONAL_ERR',
                        err_text => err_text);
                update bom_inventory_comps_interface set
                    process_flag = 3
                where transaction_id = c1rec.TI;

                if (ret_code <> 0) then
                    raise ret_code_error;
                end if;
                raise continue_loop;
        end if;

/*
** if planning bill then
** yield must be 1 and order entry values should be defaulted
*/
    stmt_num := 12;
	if (c1rec.BITA = 3) then
	    update bom_inventory_comps_interface
	    set component_yield_factor = 1,
		check_atp = 2,
		include_on_ship_docs = 2,
		so_basis = 2,
		mutually_exclusive_options = 2,
		required_to_ship = 2,
		required_for_revenue = 2,
		low_quantity = NULL,
		high_quantity = NULL
	    where transaction_id = c1rec.TI;
	end if;

   	err_text := NULL;
/*
** validate component details
*/
    stmt_num := 13;
        if (c1rec.QR not in (1,2)) then
            err_text := 'QUANTITY_RELATED must be 1 or 2';
        end if;

        if (c1rec.SB not in (1,2)) then
            err_text := 'SO_BASIS must be 1 or 2';
        end if;

        if (c1rec.O not in(1,2)) then
            err_text := 'OPTIONAL must be 1 or 2';
        end if;

        if (c1rec.MEO not in(1,2)) then
            err_text := 'MUTUALLY_EXCLUSIVE_OPTIONS must be 1 or 2';
        end if;

        if (c1rec.ICR not in(1,2)) then
            err_text := 'INCLUDE_IN_COST_ROLLUP must be 1 or 2';
        end if;

        if (c1rec.CATP not in(1,2)) then
            err_text := 'CHECK_ATP must be 1 or 2';
        end if;

        if (c1rec.RTS not in(1,2)) then
            err_text := 'REQUIRED_TO_SHIP must be 1 or 2';
        end if;

        if (c1rec.RFR not in(1,2)) then
            err_text := 'REQUIRED_FOR_REVENUE must be 1 or 2';
        end if;

        if (c1rec.ISD not in(1,2)) then
            err_text := 'INCLUDE_ON_SHIP_DOCS must be 1 or 2';
        end if;

	if (c1rec.CATP = 1 and not(c1rec.ACF = 'Y' and c1rec.CQ > 0)) then
	    err_text := 'Component cannot have ATP check';
	end if;

	if (c1rec.BITA <> 1 and c1rec.BITA <> 2 and c1rec.O = 1) then
	    err_text := 'Component cannot be optional';
	end if;

	if (c1rec.BITC <> 2 and c1rec.SB = 1) then
	    err_text := 'Basis must be None';
	end if;

	if (c1rec.RTOF = 'Y' and c1rec.RFR = 1) then
	    err_text := 'An ATO item cannot be required for revenue';
	end if;

	if (c1rec.RTOF = 'Y' and c1rec.RTS = 1) then
	    err_text := 'An ATO item cannot be required to ship';
	end if;

        if (c1rec.MEO = 1 and c1rec.BITC <>2) then
            err_text := 'Component cannot be mutually exclusive';
        end if;

        if (c1rec.LQ > c1rec.CQ) and (c1rec.LQ is not null) then
   err_text := 'Low quantity must be less than or equal to component quantity';
        end if;

        if (c1rec.HQ < c1rec.CQ) and (c1rec.HQ is not null) then
err_text := 'High quantity must be greater than or equal to component quantity';
        end if;

        if (c1rec.CYF <> 1 and c1rec.BITC = 2) then
            err_text := 'Component yield factor must be 1';
        end if;

        if (c1rec.CYF <= 0) then
            err_text := 'Component yield factor must be greater than zero';
        end if;

        if (c1rec.BITC = 1 or c1rec.BITC = 2) and (c1rec.WST <> 6) then
            err_text := 'WIP supply type must be Phantom';
        end if;

        if (((c1rec.CATP = 1) or (c1rec.QR = 1) or
             (c1rec.BITC = 2 and c1rec.PCF = 'Y'))
           and c1rec.CQ < 0) then
            err_text := 'Component quantity cannot be negative';
        end if;

        if (c1rec.QR = 1) and (c1rec.CQ <> round(c1rec.CQ)) then
            err_text := 'Component quantity must be an integer value';
        end if;

/* check if Order Entry is installed */


	begin
             select distinct 'I'
               into oe_install
               from fnd_product_installations
              where application_id = 300
		and status = 'I';

        if (oe_install = 'I') and (c1rec.CQ <> round(c1rec.CQ)) and
           (c1rec.PCFA = 'Y') then
            err_text := 'Component quantity must be an integer value';
        end if;
	exception
	     when NO_DATA_FOUND then
                null;
	end;

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
			tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
			msg_name => 'BOM_COMPONENT_ERROR',
			err_text => err_text);
            update bom_inventory_comps_interface set
		    process_flag = 3
	    where transaction_id = c1rec.TI;

	    if (ret_code <> 0) then
	        raise ret_code_error;
	    end if;
            raise continue_loop;
	end if;

/*
** Validate subinventory
*/
        if (c1rec.SLI is not null and c1rec.SS is null) then
          raise write_loc_error;
        end if;

        if (c1rec.SLI is null and c1rec.SS is null) then
          raise update_comp;
        end if;

        select inventory_asset_flag,restrict_subinventories_code,
               restrict_locators_code, location_control_code
          into inv_asst, r_subinv, r_loc, loc_ctl
          from mtl_system_items
         where inventory_item_id = c1rec.CII
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

    if (r_subinv = 2) then    /* non-restricted subinventory */
         IF (X_expense_to_asset_transfer = 1) THEN
             begin
               select locator_type
                 into sub_loc_code
                 from mtl_secondary_inventories
                where secondary_inventory_name = c1rec.SS
                  and organization_id = c1rec.OI
                  and nvl(disable_date,TRUNC(c1rec.EDD)+1) > TRUNC(c1rec.EDD)
                  and quantity_tracked = 1;
             exception
                when no_data_found then
                     raise write_subinv_error;
             end;
         ELSE
             begin
               select locator_type
                 into sub_loc_code
                 from mtl_secondary_inventories
                where secondary_inventory_name = c1rec.SS
                  and organization_id = c1rec.OI
                  and nvl(disable_date,TRUNC(c1rec.EDD)+1) > TRUNC(c1rec.EDD)
                  and quantity_tracked = 1
                  and ((inv_asst = 'Y' and asset_inventory = 1)
                       or
                       (inv_asst = 'N')
                      );
             exception
                when no_data_found then
                     raise write_subinv_error;
             end;
         END IF;
    else                           /* restricted subinventory */
         IF (X_expense_to_asset_transfer = 1) THEN
            begin
               select locator_type
                 into sub_loc_code
                 from mtl_secondary_inventories sub,
                      mtl_item_sub_inventories item
                where item.organization_id = sub.organization_id
                  and item.secondary_inventory = sub.secondary_inventory_name
                  and item.inventory_item_id = c1rec.CII
                  and sub.secondary_inventory_name = c1rec.SS
                  and sub.organization_id = c1rec.OI
                  and nvl(sub.disable_date,TRUNC(c1rec.EDD)+1) >
                      TRUNC(c1rec.EDD)
                  and sub.quantity_tracked = 1;
             exception
                when no_data_found then
                     raise write_subinv_error;
             end;
         ELSE
            begin
               select locator_type
                 into sub_loc_code
                 from mtl_secondary_inventories sub,
                      mtl_item_sub_inventories item
                where item.organization_id = sub.organization_id
                  and item.secondary_inventory = sub.secondary_inventory_name
                  and item.inventory_item_id = c1rec.CII
                  and sub.secondary_inventory_name = c1rec.SS
                  and sub.organization_id = c1rec.OI
                  and nvl(sub.disable_date,TRUNC(c1rec.EDD)+1) >
                      TRUNC(c1rec.EDD)
                  and sub.quantity_tracked = 1
                  and ((inv_asst = 'Y' and sub.asset_inventory = 1)
                       or
                       (inv_asst = 'N')
                      );
             exception
                when no_data_found then
                     raise write_subinv_error;
             end;
         END IF;
    end if;
/*
** Validate locator
*/
/* Org level */
        select stock_locator_control_code
          into org_loc
          from mtl_parameters
         where organization_id = c1rec.OI;

        if (org_loc = 1) and (c1rec.SLI is not null) then
           raise write_loc_error;
        end if;

        if ((org_loc = 2) or (org_loc = 3))and (c1rec.SLI is null) then
           raise write_loc_error;
        end if;

        if ((org_loc = 2) or (org_loc = 3)) and (c1rec.SLI is not null) then
             if (r_loc = 2) then    /* non-restricted locator */
                begin
                 select 'loc exists'
                   into dummy
                   from mtl_item_locations
                  where inventory_location_id = c1rec.SLI
                    and organization_id = c1rec.OI
                    and subinventory_code = c1rec.SS
                   and nvl(disable_date,trunc(c1rec.EDD)+1) > trunc(c1rec.EDD);
               exception
                when no_data_found then
                     raise write_loc_error;
               end;
            else                   /* restricted locator */
               begin
                 select 'restricted loc exists'
                   into dummy
                   from mtl_item_locations loc,
                        mtl_secondary_locators item
                  where loc.inventory_location_id = c1rec.SLI
                    and loc.organization_id = c1rec.OI
                    and loc.subinventory_code = c1rec.SS
                    and nvl(loc.disable_date,trunc(c1rec.EDD)+1) >
                        trunc(c1rec.EDD)
                    and loc.inventory_location_id = item.secondary_locator
                    and loc.organization_id = item.organization_id
                    and item.inventory_item_id = c1rec.CII;
               exception
                when no_data_found then
                     raise write_loc_error;
               end;
            end if;
      end if;

      if (org_loc not in (1,2,3,4) and c1rec.SLI is not null) then
           raise write_loc_error;
      end if;

/* Subinv level */
      if (org_loc = 4 and sub_loc_code = 1 and c1rec.SLI is not null) then
           raise write_loc_error;
      end if;

      if (org_loc = 4) then
           if ((sub_loc_code = 2) or (sub_loc_code = 3))
               and (c1rec.SLI is null) then
                 raise write_loc_error;
           end if;

           if ((sub_loc_code = 2) or (sub_loc_code = 3))
               and (c1rec.SLI is not null) then
                 if (r_loc = 2) then    /* non-restricted locator */
                     begin
                        select 'loc exists'
                          into dummy
                          from mtl_item_locations
                         where inventory_location_id = c1rec.SLI
                           and organization_id = c1rec.OI
                           and subinventory_code = c1rec.SS
                           and nvl(disable_date,trunc(c1rec.EDD)+1) >
                               trunc(c1rec.EDD);
                    exception
                       when no_data_found then
                          raise write_loc_error;
                    end;
                else                   /* restricted locator */
                    begin
                       select 'restricted loc exists'
                         into dummy
                         from mtl_item_locations loc,
                              mtl_secondary_locators item
                        where loc.inventory_location_id = c1rec.SLI
                         and loc.organization_id = c1rec.OI
                         and loc.subinventory_code = c1rec.SS
                         and nvl(loc.disable_date,trunc(c1rec.EDD)+1) >
                             trunc(c1rec.EDD)
                         and loc.inventory_location_id = item.secondary_locator
                         and loc.organization_id = item.organization_id
                         and item.inventory_item_id = c1rec.CII;
                   exception
                        when no_data_found then
                           raise write_loc_error;
                   end;
               end if;
          end if;

          if (sub_loc_code not in (1,2,3,5) and c1rec.SLI is not null) then
               raise write_loc_error;
          end if;
      end if;

/* Item level */
      if (org_loc = 4 and sub_loc_code = 5 and loc_ctl = 1
          and c1rec.SLI is not null) then
           raise write_loc_error;
      end if;

      if (org_loc = 4 and sub_loc_code = 5) then
           if ((loc_ctl = 2) or (loc_ctl = 3))
               and (c1rec.SLI is null) then
                 raise write_loc_error;
           end if;

           if ((loc_ctl = 2) or (loc_ctl = 3))
               and (c1rec.SLI is not null) then
                 if (r_loc = 2) then    /* non-restricted locator */
                     begin
                        select 'loc exists'
                          into dummy
                          from mtl_item_locations
                         where inventory_location_id = c1rec.SLI
                           and organization_id = c1rec.OI
                           and subinventory_code = c1rec.SS
                           and nvl(disable_date,trunc(c1rec.EDD)+1) >
                               trunc(c1rec.EDD);
                    exception
                       when no_data_found then
                          raise write_loc_error;
                    end;
                else                   /* restricted locator */
                    begin
                       select 'restricted loc exists'
                         into dummy
                         from mtl_item_locations loc,
                              mtl_secondary_locators item
                        where loc.inventory_location_id = c1rec.SLI
                         and loc.organization_id = c1rec.OI
                         and loc.subinventory_code = c1rec.SS
                         and nvl(loc.disable_date,trunc(c1rec.EDD)+1) >
                             trunc(c1rec.EDD)
                         and loc.inventory_location_id = item.secondary_locator
                         and loc.organization_id = item.organization_id
                         and item.inventory_item_id = c1rec.CII;
                   exception
                        when no_data_found then
                           raise write_loc_error;
                   end;
               end if;
          end if;

          if (loc_ctl not in (1,2,3) and c1rec.SLI is not null) then
               raise write_loc_error;
          end if;
      end if;

      raise update_comp;

    if mod(c1%rowcount, commit_cnt) = 0 then
       commit;
--       dbms_output.put_line('Validate Component commited at row '||
--          to_char(c1%rowcount));
    end if;

  Exception
    when write_loc_error then
        ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => org_id,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => request_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_LOCATOR_INVALID',
                        err_text => err_text);
        update bom_inventory_comps_interface set
            process_flag = 3
        where transaction_id = c1rec.TI;

        if (ret_code <> 0) then
           raise ret_code_error;
        end if;

    when write_subinv_error then
        ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => org_id,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => request_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_SUBINV_INVALID',
                        err_text => err_text);
        update bom_inventory_comps_interface set
            process_flag = 3
        where transaction_id = c1rec.TI;

        if (ret_code <> 0) then
           raise ret_code_error;
        end if;

    when update_comp then
        update bom_inventory_comps_interface
           set process_flag = 4
         where transaction_id = c1rec.TI;

    when continue_loop then
      if mod(c1%rowcount, commit_cnt) = 0 then
        commit;
--        dbms_output.put_line('Validate Component commited at row '||
--          to_char(c1%rowcount));
      end if;
    end; -- each component
    end loop; -- cursor

    commit;
    return(0);

EXCEPTION
    when ret_code_error then
        return(ret_code);
    when others then
	err_text := 'BOMPVALB(bmvcomp-' || stmt_num || ') ' || substrb(SQLERRM,1,60);
	return(SQLCODE);
END bmvcomp_validate_components;

/*------------------------ bmvitmatt_verify_item_attr -----------------------*/
/* NAME
    bmvitmatt_verify_item_attr - verify if the item attributes
    of component item and assembly_item are compatible
DESCRIPTION
Component must be bom enabled
Component item cannot be same as assembly item
Mfg bills must have mfg component items

                                     Component Types

Bill            PTO     ATO     PTO   ATO             ATO    PTO   Standard
Types           Model   Model   OC    OC   Planning   Item   Item  Item
-------------  ------------------------------------------------------------
PTO Model       Yes     Yes     Yes   No   No         Yes    Yes   Yes
ATO Model       No      Yes     No    Yes  No         Yes    No    Yes
PTO OC          Yes     Yes     Yes   No   No         Yes    Yes   Yes
ATO OC          No      Yes     No    Yes  No         Yes    No    Yes
Planning        Yes     Yes     Yes   Yes  Yes        Yes    Yes   Yes
ATO Item        No      No      No    No   No         Yes    No    Yes
PTO Item        No      No      No    No   No          No    Yes   Yes
Standard Item   No      No      No    No   No         Yes    No    Yes
Config Item     No      Yes     No    Yes  No         Yes    No    Yes

REQUIRES
    org_id          organization id
    cmp_id          component item id
    assy_id         assembly item id
    eng_bill        engineering bill (1=no, 2=yes)
    err_text 	out buffer to return error message
MODIFIES
    MTL_INTERFACE_ERRORS
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmvitmatt_verify_item_attr (
    org_id 		NUMBER,
    cmp_id		NUMBER,
    assy_id		NUMBER,
    eng_bill            NUMBER,
    err_text   OUT	VARCHAR2
)
    return INTEGER
IS
    ret_code		NUMBER;
    stmt_num		NUMBER := 0;
    dummy		NUMBER;

BEGIN
    select 1
	into dummy
	from mtl_system_items assy, mtl_system_items comp
	where   comp.organization_id = org_id
	and     assy.organization_id = org_id
	and	comp.inventory_item_id = cmp_id
	and    	assy.inventory_item_id = assy_id
	and 	comp.bom_enabled_flag = 'Y'
        and	comp.inventory_item_id <> assy.inventory_item_id
        and     ((eng_bill = 1 and comp.eng_item_flag = 'N')
                  or
                 (eng_bill = 2))
        and	((assy.bom_item_type = 1 and comp.bom_item_type <> 3)
                 or
                 (assy.bom_item_type = 2 and comp.bom_item_type <> 3)
                 or
                 (assy.bom_item_type = 3)
                 or
                 (assy.bom_item_type = 4
                  and (comp.bom_item_type = 4
                       or (comp.bom_item_type in (2,1)
                           and comp.replenish_to_order_flag = 'Y'
                           and assy.base_item_id is not null
                           and assy.replenish_to_order_flag = 'Y')))
                )
                and (assy.bom_item_type = 3
                     or
                     assy.pick_components_flag = 'Y'
                     or
                     comp.pick_components_flag = 'N')
                and (assy.bom_item_type = 3
                     or
                     comp.bom_item_type <> 2
                     or
                     (comp.bom_item_type = 2
                      and ((assy.pick_components_flag = 'Y'
                            and comp.pick_components_flag = 'Y')
                           or (assy.replenish_to_order_flag = 'Y'
                               and comp.replenish_to_order_flag = 'Y'))))
                and not(assy.bom_item_type = 4
                        and assy.pick_components_flag = 'Y'
                        and comp.bom_item_type = 4
                        and comp.replenish_to_order_flag = 'Y');

        begin
           select 1
             into dummy
             from mtl_system_items assy, mtl_system_items comp
            where   comp.organization_id = org_id
            and     assy.organization_id = org_id
            and     comp.inventory_item_id = cmp_id
            and     assy.inventory_item_id = assy_id
            and     (comp.atp_components_flag = 'Y' or
                     comp.atp_flag = 'Y')
            and     assy.atp_components_flag = 'N'
            and     (nvl(assy.wip_supply_type,1) = 6
                     or assy.replenish_to_order_flag = 'Y'
                     or assy.pick_components_flag = 'Y');
           err_text := 'Component ATP flag item attributes invalid';
           return(9999);
        exception
           when NO_DATA_FOUND then
              return(0);
        end;

EXCEPTION
    when NO_DATA_FOUND then
	err_text := 'Component and assembly item attributes invalid';
        return(9999);
    when others then
	err_text := 'bmvitmatt: ' || substrb(SQLERRM,1,60);
	return(SQLCODE);
END bmvitmatt_verify_item_attr;

/*-------------------------- bmvopseqs_valid_op_seqs ------------------------*/
/* NAME
    bmvopseqs_valid_op_seqs - validate the operation seq nums
DESCRIPTION
    verify if op seq is valid.  For alternate bills, op seq can be of same
    alternate or primary if alternate does not exist
REQUIRES
    err_text 	out buffer to return error message
MODIFIES
    MTL_INTERFACE_ERRORS
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmvopseqs_valid_op_seqs (
    org_id		NUMBER,
    assy_id		NUMBER,
    alt_desg		VARCHAR2,
    op_seq		NUMBER,
    err_text	 OUT    VARCHAR2
)
    return INTEGER
IS
    ret_code		NUMBER;
    stmt_num		NUMBER := 0;
    dummy		NUMBER;

BEGIN
    select bom_item_type
	into dummy
	from mtl_system_items
	where organization_id = org_id
	and   inventory_item_id = assy_id;

    if dummy = 3 and op_seq <> 1 then
	err_text := 'Planning bom cannot have routing';
	return (9999);
    end if;

    if (op_seq <> 1) then
        select operation_seq_num
	into dummy
	from bom_operation_sequences a, bom_operational_routings b
	where b.organization_id = org_id
	and   b.assembly_item_id = assy_id
	and   operation_seq_num = op_seq
	and   b.common_routing_sequence_id = a.routing_sequence_id
	and   ( (alt_desg is null and b.alternate_routing_designator is null)
		or
		(alt_desg is not null
		and
		  ( (b.alternate_routing_designator = alt_desg)
			or
		    (b.alternate_routing_designator is null
			and not exists (select 'No alt routing'
			from bom_operational_routings c
			where c.organization_id = org_id
			and   c.assembly_item_id = assy_id
			and   c.alternate_routing_designator = alt_desg)
		    )
		  )
		)
	      );
    end if;
    return (0);

EXCEPTION
     when NO_DATA_FOUND then
	err_text := 'Invalid operation seq num';
	return (9999);
     when others then
	err_text := 'bmvopseqs: ' || substrb(SQLERRM,1,60);
 	return(SQLCODE);
END bmvopseqs_valid_op_seqs;

/*------------------------ bmvovlap_verify_overlaps -------------------------*/
/* NAME
    bmvovlap_verify_overlaps - verify component overlaps
DESCRIPTION
    verify the current component does not have overlapping effectivity
REQUIRES
    bom_id	bill sequence id
    op_num	operation sequence number
    cmp_id	component item id
    eff_date	effectivity date
    dis_date	disable date
    err_text 	out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmvovlap_verify_overlaps (
    bom_id		NUMBER,
    op_num		NUMBER,
    cmp_id		NUMBER,
    eff_date		VARCHAR2,
    dis_date		VARCHAR2,
    err_text    OUT	VARCHAR2
)
    return INTEGER
IS
    dummy		NUMBER;
    OVERLAP		EXCEPTION;
BEGIN
    select count(*)
	into dummy
	from bom_inventory_components
	where bill_sequence_id = bom_id
	and   component_item_id = cmp_id
	and   operation_seq_num = op_num
	and   implementation_date is not null
        and   ((dis_date is null
                and to_date(eff_date,'YYYY/MM/DD HH24:MI') <
                  nvl(disable_date, to_date(eff_date,'YYYY/MM/DD HH24:MI') +1))
              or
               (dis_date is not null
                and to_date(dis_date,'YYYY/MM/DD HH24:MI') > effectivity_date
                and to_date(eff_date,'YYYY/MM/DD HH24:MI') <
                   nvl(disable_date,to_date(eff_date,'YYYY/MM/DD HH24:MI') +1))
              );
    if (dummy <> 0) then
	raise OVERLAP;
    end if;

    select count(*)
	into dummy
	from bom_inventory_comps_interface
	where bill_sequence_id = bom_id
        and   process_flag = 4
	and   component_item_id = cmp_id
	and   operation_seq_num = op_num
	and   implementation_date is not null
        and   ((dis_date is null
                and to_date(eff_date,'YYYY/MM/DD HH24:MI') <
                  nvl(disable_date, to_date(eff_date,'YYYY/MM/DD HH24:MI') +1))
              or
               (dis_date is not null
                and to_date(dis_date,'YYYY/MM/DD HH24:MI') > effectivity_date
                and to_date(eff_date,'YYYY/MM/DD HH24:MI') <
                   nvl(disable_date,to_date(eff_date,'YYYY/MM/DD HH24:MI') +1))
	      );
    if (dummy <> 0) then
	raise OVERLAP;
    end if;

    return(0);
EXCEPTION
    when OVERLAP then
	err_text := 'Component causes overlapping effectivity';
	return(9999);
    when others then
	err_text := 'bmvovlap: ' || substrb(SQLERRM,1,60);
	return (SQLCODE);
END bmvovlap_verify_overlaps;

/*---------------------- bmvuncmp_verify_unique_comp ------------------------*/
/* NAME
    bmvuncmp_verify_unique_comp - verify uniqueness or existence
                                  of comp seq id
DESCRIPTION
   verifies if the given component sequence id is unique in prod and
        interface tables
REQUIRES
    cmp_seq_id  component sequence id
    exist_flag  1 - check for existence
		2 - check for uniqueness
    err_text 	out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmvuncmp_verify_unique_comp (
    cmp_seq_id 		NUMBER,
    exist_flag		NUMBER,
    err_text	 OUT	VARCHAR2
)
    return INTEGER
IS
    dummy		NUMBER;
    NOT_UNIQUE       EXCEPTION;
BEGIN
/*
** first check in prod tables
*/
    begin
	select 1
	    into dummy
	    from bom_inventory_components
	    where component_sequence_id = cmp_seq_id;
	if (exist_flag = 1) then
	    return(0);
        else
            raise NOT_UNIQUE;
    	end if;
    exception
 	when NO_DATA_FOUND then
	    null;
	when NOT_UNIQUE then
            raise NOT_UNIQUE;
        when others then
            err_text := 'BOMPVALB(bmvuncmp) ' || substrb(SQLERRM,1,60);
            return(SQLCODE);
    end;

/*
** check in interface table
*/
    select count(*)
	into dummy
	from bom_inventory_comps_interface
	where component_sequence_id = cmp_seq_id
          and process_flag = 4;

    if (dummy = 0) then
        if (exist_flag = 2) then
            return(0);
        else
           raise NO_DATA_FOUND;
        end if;
    end if;

    if (dummy > 0) then
        if (exist_flag = 2) then
            raise NOT_UNIQUE;
        else
           return(0);
        end if;
    end if;

EXCEPTION
    when NO_DATA_FOUND then
        err_text := substrb('BOMPVALB(bmvuncmp): Component does not exist ' || SQLERRM,1,70);
        return(9999);
    when NOT_UNIQUE then
        err_text := 'BOMPVALB(bmvuncmp) ' ||'Duplicate component sequence ids';
        return(9999);
    when others then
	err_text := 'BOMPVALB(bmvuncmp) ' || substrb(SQLERRM,1,60);
	return(SQLCODE);
END bmvuncmp_verify_unique_comp;

/*--------------------- bmvdupcmp_verify_duplicate_cmp ----------------------*/
/* NAME
    bmvdupcmp_verify_duplicate_cmp - verify if there is another component
        with the same bill, effective date, and operation seq num.
DESCRIPTION
    Verifies in the production and interface tables if component with
    the same bill, effective date, and operation seq num exists.

REQUIRES
    bill_seq_id bill sequence id
    eff_date    effectivity date
    cmp_item_id component item id
    op_seq      operation seq
    err_text    out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    cnt  if component already exists
    SQLCODE if error
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmvdupcmp_verify_duplicate_cmp(
        bill_seq_id     NUMBER,
        eff_date        VARCHAR2,
        cmp_item_id     NUMBER,
        op_seq          NUMBER,
        err_text  OUT   VARCHAR2
)
    return INTEGER
IS
    cnt         NUMBER := 0;
    ALREADY_EXISTS EXCEPTION;
BEGIN
    begin
        select component_sequence_id
        into cnt
        from bom_inventory_components
        where bill_sequence_id = bill_seq_id
        and   to_char(effectivity_date,'YYYY/MM/DD HH24:MI') = eff_date
        and   component_item_id = cmp_item_id
        and   operation_seq_num = op_seq;
        raise ALREADY_EXISTS;
    exception
        when ALREADY_EXISTS then
     err_text := 'BOMPVALB(bmvdupcmp): Component already exists in production';
          return(cnt);
        when NO_DATA_FOUND then
            NULL;
        when others then
            err_text := 'BOMPVALB(bmvdupcmp) ' || substrb(SQLERRM,1,60);
            return(SQLCODE);
    end;

    begin
        select component_sequence_id
        into cnt
        from bom_inventory_comps_interface
        where bill_sequence_id = bill_seq_id
        and   to_char(effectivity_date,'YYYY/MM/DD HH24:MI') = eff_date
        and   component_item_id = cmp_item_id
        and   operation_seq_num = op_seq
        and   rownum = 1
        and   process_flag = 4;

        raise ALREADY_EXISTS;
    exception
        when ALREADY_EXISTS then
      err_text := 'BOMPVALB(bmvdupcmp): Component already exists in interface';
          return(cnt);
        when NO_DATA_FOUND then
            NULL;
        when others then
            err_text := 'BOMPVALB(bmvdupcmp) ' || substrb(SQLERRM,1,60);
            return(SQLCODE);
    end;
    return(0);

EXCEPTION
    when others then
        err_text := 'BOMPVALB(bmvdupcmp) ' || substrb(SQLERRM,1,60);
        return(SQLCODE);
END bmvdupcmp_verify_duplicate_cmp;


/*------------------------ bmvref_validate_ref_desgs ------------------------*/
/* NAME
    bmvref_validate_ref_desgs - validate reference designators
DESCRIPTION
    check for validity of component sequence id
    no ref desgns for planning or option class items
    if quantity related then # of ref desgs = component qty
REQUIRES
    err_text 	out buffer to return error message
MODIFIES
    MTL_INTERFACE_ERRORS
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmvref_validate_ref_desgs (
    org_id		NUMBER,
    all_org		NUMBER := 2,
    user_id		NUMBER,
    login_id		NUMBER,
    prog_appid		NUMBER,
    prog_id		NUMBER,
    request_id		NUMBER,
    err_text	IN OUT 	VARCHAR2
)
    return INTEGER
IS
    ret_code		NUMBER;
    stmt_num		NUMBER := 0;
    dummy		NUMBER;
    org_id_dummy        NUMBER;
    assy_id_dummy       NUMBER;
    commit_cnt  	NUMBER;
    comp_type		NUMBER;
    continue_loop 	BOOLEAN := TRUE;
    total_recs		NUMBER;

    cursor c1 is
	select component_sequence_id CSI, count(*) CNT,
		transaction_id TI, component_item_id CII
	 from bom_ref_desgs_interface
	where process_flag = 2
          and rownum < 500
	group by transaction_id, component_sequence_id, component_item_id;

BEGIN
select count(distinct component_sequence_id)
  into total_recs
  from bom_ref_desgs_interface
 where process_flag = 2;

continue_loop := TRUE;
commit_cnt := 0;

while continue_loop loop
      for c1rec in c1 loop
/*
** check for null ref desgs
*/
        commit_cnt := commit_cnt + 1;
        select count(*)
          into dummy
          from bom_ref_desgs_interface
         where transaction_id = c1rec.TI
           and component_reference_designator is null;

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
               tbl_name => 'BOM_REF_DESGS_INTERFACE',
               msg_name => 'BOM_NULL_REF_DESGS',
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
** verify for existence of component seq id
*/
     	ret_code := BOMPVALB.bmvuncmp_verify_unique_comp (
		cmp_seq_id => c1rec.CSI,
		exist_flag => 1,
		err_text => err_text);
	if (ret_code <> 0) then
	    ret_code := INVPUOPI.mtl_log_interface_err(
			org_id => org_id,
			user_id => user_id,
			login_id => login_id,
			prog_appid => prog_appid,
			prog_id => prog_id,
			req_id => request_id,
			trans_id => c1rec.TI,
			error_text => err_text,
			tbl_name => 'BOM_REF_DESGS_INTERFACE',
			msg_name => 'BOM_COMP_SEQ_ID_INVALID',
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
** check for duplicate component seq id/ref desg combinations
*/
        ret_code := BOMPVALB.bmvundesg_verify_unique_desg (
                trans_id => c1rec.TI,
                err_text => err_text);
        if (ret_code <> 0) then
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => org_id,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => request_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_REF_DESGS_INTERFACE',
                        msg_name => 'BOM_DUP_REF_DESG',
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
** count reference designators if quantity related is Yes
*/
        ret_code := BOMPVALB.bmvcdesg_cnt_ref_desgs (
                trans_id => c1rec.TI,
                cmp_seq_id => c1rec.CSI,
                err_text => err_text);
        if (ret_code <> 0) then
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => org_id,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => request_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_REF_DESGS_INTERFACE',
                        msg_name => 'BOM_REF_DESG_COUNT_INVALID',
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
** no ref desgns for planning bills and
** non-Standard components
*/
     begin
        select bbom.organization_id,
               bbom.assembly_item_id, bic.bom_item_type
          into org_id_dummy, assy_id_dummy, comp_type
          from bom_inventory_components bic,
               bom_bill_of_materials bbom
         where component_sequence_id = c1rec.CSI
           and bbom.bill_sequence_id = bic.bill_sequence_id;
        goto check_bom_type;
     exception
        when NO_DATA_FOUND then
           NULL;
     end;

     begin
        select bbom.organization_id,
               bbom.assembly_item_id, bic.bom_item_type
          into org_id_dummy, assy_id_dummy, comp_type
          from bom_inventory_comps_interface bic,
               bom_bill_of_mtls_interface bbom
         where component_sequence_id = c1rec.CSI
           and bic.process_flag = 4
           and bbom.process_flag = 4
           and bbom.bill_sequence_id = bic.bill_sequence_id;
        goto check_bom_type;
     exception
        when NO_DATA_FOUND then
           NULL;
     end;

     begin
        select bbom.organization_id,
               bbom.assembly_item_id, bic.bom_item_type
          into org_id_dummy, assy_id_dummy, comp_type
          from bom_inventory_comps_interface bic,
               bom_bill_of_materials bbom
         where component_sequence_id = c1rec.CSI
           and bic.process_flag = 4
           and bbom.bill_sequence_id = bic.bill_sequence_id;
        goto check_bom_type;
     exception
        when NO_DATA_FOUND then
           err_text := substrb('bmvref: Invalid component sequence id ' || SQLERRM,1,70);
           return(9999);
     end;

<<check_bom_type>>
     NULL;
	select bom_item_type
	into dummy
	from mtl_system_items msi
	where msi.organization_id = org_id_dummy
	and   msi.inventory_item_id = assy_id_dummy;

	if (dummy = 3) then
	    err_text := 'Cannot have reference desgs for planning bills';
	    ret_code := INVPUOPI.mtl_log_interface_err(
			org_id => org_id_dummy,
			user_id => user_id,
			login_id => login_id,
			prog_appid => prog_appid,
			prog_id => prog_id,
			req_id => request_id,
			trans_id => c1rec.TI,
			error_text => err_text,
			tbl_name => 'BOM_REF_DESGS_INTERFACE',
			msg_name => 'BOM_NO_REF_DESGS_ALLOWED',
			err_text => err_text);
	    update bom_ref_desgs_interface set
		    process_flag = 3
	    where transaction_id = c1rec.TI;

	    if (ret_code <> 0) then
	        return(ret_code);
	    end if;
	    goto continue_loop;
	end if;

        if (comp_type <> 4) then
            err_text := 'Cannot have reference desgs for model, option class, or planning components';
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => org_id_dummy,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => request_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_REF_DESGS_INTERFACE',
                        msg_name => 'BOM_NO_REF_DESGS_COMP',
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
           set process_flag = 4
         where transaction_id = c1rec.TI;

<<continue_loop>>
	null;
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
	err_text := 'bmvref(' || stmt_num || ') ' || substrb(SQLERRM,1,60);
	return(SQLCODE);
END bmvref_validate_ref_desgs;


/*---------------------- bmvundesg_verify_unique_desg -----------------------*/
/* NAME
    bmvundesg_verify_unique_desg - verify that the ref_desg is unique
DESCRIPTION
   verify that the ref_desg is unique in both prod and interface tables
   for any component on a bill

REQUIRES
    trans_id    transaction_id
    err_text    out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmvundesg_verify_unique_desg (
    trans_id            NUMBER,
    err_text    OUT     VARCHAR2
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
        from bom_reference_designators a, bom_ref_desgs_interface b
        where b.transaction_id = trans_id
        and   a.component_sequence_id = b.component_sequence_id
        and   a.COMPONENT_REFERENCE_DESIGNATOR =
                b.COMPONENT_REFERENCE_DESIGNATOR
        and rownum = 1;
        raise NOT_UNIQUE;
    exception
        when NO_DATA_FOUND then
            null;
        when NOT_UNIQUE then
            raise NOT_UNIQUE;
        when others then
            err_text := 'BOMPVALB(bmvundesg) ' || substrb(SQLERRM,1,60);
            return(SQLCODE);
    end;

/*
** check in interface table
*/
    select count(*)
        into dummy
        from bom_ref_desgs_interface a
        where transaction_id = trans_id
        and   exists (select 'same designator'
                from bom_ref_desgs_interface b
                where b.transaction_id = trans_id
                and   b.rowid <> a.rowid
                and   b.COMPONENT_REFERENCE_DESIGNATOR =
                        a.COMPONENT_REFERENCE_DESIGNATOR
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
        err_text := 'BOMPVALB(bmvundesg) ' ||'Duplicate ref desgs';
        return(9999);
    when others then
        err_text := 'BOMPVALB(bmvundesg) ' || substrb(SQLERRM,1,60);
        return(SQLCODE);
end bmvundesg_verify_unique_desg;

/*------------------------ bmvcdesg_cnt_ref_desgs  ------------------------*/
/* NAME
    bmvcdesg_cnt_ref_desgs - verify ref desg count
DESCRIPTION
    ensure that the number of ref desgs is same as component quantity
    if qty related
REQUIRES
    trans_id    transaction_id
    cmp_seq_id  component_sequence_id
    err_text    out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmvcdesg_cnt_ref_desgs (
    trans_id    NUMBER,
    cmp_seq_id  NUMBER,
    err_text  OUT  VARCHAR2
)
    return INTEGER
IS
    qty_flag    NUMBER := -1;
    cmp_qty     NUMBER;
    ref_qty     NUMBER;
    int_ref_qty NUMBER;
BEGIN
    begin
        select QUANTITY_RELATED, COMPONENT_QUANTITY
        into   qty_flag, cmp_qty
        from bom_inventory_components
        where component_sequence_id = cmp_seq_id;

    exception
        when NO_DATA_FOUND then
            null;
        when others then
            err_text := 'BOMPVALB(bmvcdesg) ' || substrb(SQLERRM,1,60);
            return(SQLCODE);
    end;

/*
** if not qty related then return
*/
    if (qty_flag = 2) then
        return(0);
    end if;

/*
** if no rows selected from prod table, then get from interface table
*/
    if (qty_flag <> 1 and qty_flag <> 2) then
        select QUANTITY_RELATED, COMPONENT_QUANTITY
        into   qty_flag, cmp_qty
        from bom_inventory_comps_interface
        where component_sequence_id = cmp_seq_id
          and process_flag = 4;
    end if;

   if (qty_flag = 1) then
        select count(*)
        into ref_qty
        from bom_reference_designators
        where component_sequencE_id = cmp_seq_id;

        select count(*)
        into int_ref_qty
        from bom_ref_desgs_interface
        where transaction_id = trans_id
        and   process_flag <> 3
        and   process_flag <> 7;
        if (ref_qty + int_ref_qty <> cmp_qty) then
            err_text := 'BOMPVALB(bmvcdesg) ' || 'Number of ref desg
not equal to component qty';
            return (9999);
        end if;
    end if;

    return(0);

exception
    when others then
        err_text := 'BOMPVALB(bmvcdesg) ' || substrb(SQLERRM,1,60);
        return(SQLCODE);
END bmvcdesg_cnt_ref_desgs;


/*------------------------ bmvsubs_validate_sub_comps -----------------------*/
/* NAME
    bmvsubs_validate_sub_comps - validate substitute components
DESCRIPTION
    check for validity of component sequence id
    check for validity of component item id
    sub item qty must not be negative
    no subs for planning or option class items
REQUIRES
    err_text 	out buffer to return error message
MODIFIES
    MTL_INTERFACE_ERRORS
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmvsubs_validate_sub_comps (
    org_id		NUMBER,
    all_org		NUMBER := 2,
    user_id		NUMBER,
    login_id		NUMBER,
    prog_appid		NUMBER,
    prog_id		NUMBER,
    request_id		NUMBER,
    err_text	IN OUT 	VARCHAR2
)
    return INTEGER
IS
    ret_code		NUMBER;
    stmt_num		NUMBER := 0;
    dummy		NUMBER;
    assy_id_dummy       NUMBER;
    org_id_dummy        NUMBER;
    assy_type_dummy     NUMBER;
    comp_id_dummy       NUMBER;
    commit_cnt  	NUMBER;
    comp_type		NUMBER;
    continue_loop 	BOOLEAN := TRUE;
    total_recs		NUMBER;

    cursor c1 is
	select component_sequence_id CSI, count(*) CNT,
		transaction_id TI, assembly_item_id AII,
		organization_id OI
		from bom_sub_comps_interface
	where process_flag = 2
          and rownum < 500
	group by transaction_id, component_sequence_id,
		organization_id, assembly_item_id;

BEGIN
select count(distinct component_sequence_id)
  into total_recs
  from bom_sub_comps_interface
 where process_flag = 2;

commit_cnt := 0;

while continue_loop loop
      for c1rec in c1 loop
/*
** verify for existence of component seq id
*/
        commit_cnt := commit_cnt + 1;
     	ret_code := BOMPVALB.bmvuncmp_verify_unique_comp (
		cmp_seq_id => c1rec.CSI,
		exist_flag => 1,
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
			tbl_name => 'BOM_SUB_COMPS_INTERFACE',
			msg_name => 'BOM_COMP_SEQ_ID_INVALID',
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
** no sub comps for planning bills and
** non-standard components
*/
     begin
        select bbom.assembly_item_id,bbom.organization_id,
               bbom.assembly_type, bic.component_item_id,
	       bic.bom_item_type
          into assy_id_dummy, org_id_dummy,assy_type_dummy,
               comp_id_dummy, comp_type
          from bom_inventory_components bic,
               bom_bill_of_materials bbom
         where component_sequence_id = c1rec.CSI
           and bbom.bill_sequence_id = bic.bill_sequence_id;
        goto check_bom_type;
     exception
        when NO_DATA_FOUND then
           NULL;
     end;

     begin
        select bbom.assembly_item_id,bbom.organization_id,
               bbom.assembly_type, bic.component_item_id,
	       bic.bom_item_type
          into assy_id_dummy, org_id_dummy,assy_type_dummy,
               comp_id_dummy, comp_type
          from bom_inventory_comps_interface bic,
               bom_bill_of_mtls_interface bbom
         where component_sequence_id = c1rec.CSI
           and bic.process_flag = 4
           and bbom.process_flag = 4
           and bbom.bill_sequence_id = bic.bill_sequence_id;
        goto check_bom_type;
     exception
        when NO_DATA_FOUND then
           NULL;
     end;

     begin
        select bbom.assembly_item_id,bbom.organization_id,
               bbom.assembly_type, bic.component_item_id,
	       bic.bom_item_type
          into assy_id_dummy, org_id_dummy,assy_type_dummy,
               comp_id_dummy, comp_type
          from bom_inventory_comps_interface bic,
               bom_bill_of_materials bbom
         where component_sequence_id = c1rec.CSI
           and bic.process_flag = 4
           and bbom.bill_sequence_id = bic.bill_sequence_id;
        goto check_bom_type;
     exception
        when NO_DATA_FOUND then
           err_text := substrb('bmvsubs: Invalid component sequence id ' || SQLERRM,1,70);
           return(9999);
     end;

<<check_bom_type>>
     NULL;
     select bom_item_type
     into dummy
     from mtl_system_items msi
     where msi.organization_id = org_id_dummy
       and   msi.inventory_item_id = assy_id_dummy;

     if (dummy = 3) then
      ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => org_id_dummy,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => request_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_SUB_COMPS_INTERFACE',
                        msg_name => 'BOM_NO_SUB_COMPS_ALLOWED',
                        err_text => err_text);
       update bom_sub_comps_interface set
                    process_flag = 3
        where transaction_id = c1rec.TI;

       if (ret_code <> 0) then
            return(ret_code);
       end if;
       goto continue_loop;
      end if;

    if (comp_type <> 4) then
      ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => org_id_dummy,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => request_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_SUB_COMPS_INTERFACE',
                        msg_name => 'BOM_NO_SUB_COMPS_COMP',
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
** Check substitute item existence in item master
*/
      select count(*)
        into dummy
        from bom_sub_comps_interface a
        where transaction_id = c1rec.TI
        and   process_flag <> 3 and process_flag <> 7
        and   not exists (select 'items exist'
            from mtl_system_items b
            where b.organization_id = org_id_dummy
            and   b.inventory_item_id = a.substitute_component_id);

        if (dummy <> 0) then
            err_text := 'Substitute item does not exist in item master';
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => org_id_dummy,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => request_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_SUB_COMPS_INTERFACE',
                        msg_name => 'BOM_SUB_COMP_ITEM_INVALID',
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
** Verify substitute component is unique for a component
*/
        ret_code := BOMPVALB.bmvunsub_verify_unique_sub (
                trans_id => c1rec.TI,
                err_text => err_text);
        if (ret_code <> 0) then
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => org_id_dummy,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => request_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_SUB_COMPS_INTERFACE',
                        msg_name => 'BOM_DUPLICATE_SUB_COMP',
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
** Verify sub comp is not the same as bill or component
*/
        select count(*)
        into dummy
        from bom_sub_comps_interface
        where transaction_id = c1rec.TI
        and   (SUBSTITUTE_COMPONENT_ID = assy_id_dummy
                or
               SUBSTITUTE_COMPONENT_ID = comp_id_dummy)
        and process_flag <> 3 and process_flag <> 7;

        if (dummy <> 0) then
            err_text := 'Substitute item is the same as assembly item or component item';
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => org_id_dummy,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => request_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_SUB_COMPS_INTERFACE',
                        msg_name => 'BOM_SUB_COMP_ITEM_SAME',
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
** Check substitute item attributes
*/
      select count(*)
        into dummy
        from bom_sub_comps_interface bsc
       where bsc.transaction_id = c1rec.TI
         and not exists (select 'x'
                           from mtl_system_items msi
                          where organization_id = org_id_dummy
                          and inventory_item_id = bsc.substitute_component_id
                          and bom_enabled_flag = 'Y'
                          and bom_item_type = 4
                          and ((assy_type_dummy = 2)
                                or
                                (assy_type_dummy = 1
                                 and eng_item_flag = 'N')));
      if (dummy <> 0) then
            err_text := 'Substitute item has invalid item attributes';
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => org_id_dummy,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => request_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_SUB_COMPS_INTERFACE',
                        msg_name => 'BOM_SUB_COMP_ITEM_ATTR_INVALID',
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
** Substitute item quantity cannot be zero
*/
	select count(*)
	into dummy
	from bom_sub_comps_interface
	where transaction_id = c1rec.TI
        and   process_flag <> 3 and process_flag <> 7
	and   substitute_item_quantity = 0;
   	if (dummy <> 0) then
	    err_text := 'Quantity cannot be zero';
            ret_code := INVPUOPI.mtl_log_interface_err(
			org_id => org_id_dummy,
			user_id => user_id,
			login_id => login_id,
			prog_appid => prog_appid,
			prog_id => prog_id,
			req_id => request_id,
			trans_id => c1rec.TI,
			error_text => err_text,
			tbl_name => 'BOM_SUB_COMPS_INTERFACE',
			msg_name => 'BOM_SUB_COMP_QTY_ZERO',
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
           set process_flag = 4
         where transaction_id = c1rec.TI;

<<continue_loop>>
	null;
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
	err_text := 'bmvsubs(' || stmt_num || ') ' || substrb(SQLERRM,1,60);
	return(SQLCODE);
END bmvsubs_validate_sub_comps;

/*---------------------- bmvunsub_verify_unique_sub -----------------------*/
/* NAME
    bmvunsub_verify_unique_sub - verify that the sub_comp is unique
DESCRIPTION
   verify that the substitute component is unique in both prod and
   interface tables for any component on a bill

REQUIRES
    trans_id    transaction_id
    err_text    out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmvunsub_verify_unique_sub (
    trans_id            NUMBER,
    err_text    OUT     VARCHAR2
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
        from bom_substitute_components a, bom_sub_comps_interface b
        where b.transaction_id = trans_id
        and   a.component_sequence_id = b.component_sequence_id
        and   a.SUBSTITUTE_COMPONENT_ID =
                b.SUBSTITUTE_COMPONENT_ID
        and rownum = 1;
        raise NOT_UNIQUE;
    exception
        when NO_DATA_FOUND then
            null;
        when NOT_UNIQUE then
            raise NOT_UNIQUE;
        when others then
            err_text := 'BOMPVALB(bmvunsub) ' || substrb(SQLERRM,1,60);
            return(SQLCODE);
    end;

/*
** check in interface table
*/
    select count(*)
        into dummy
        from bom_sub_comps_interface a
        where transaction_id = trans_id
        and   exists (select 'same substitue'
                from bom_sub_comps_interface b
                where b.transaction_id = trans_id
                and   b.rowid <> a.rowid
                and   b.SUBSTITUTE_COMPONENT_ID =
                        a.SUBSTITUTE_COMPONENT_ID
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
        err_text := 'BOMPVALB(bmvunsub) ' ||'Duplicate substitute components';
        return(9999);
    when others then
        err_text := 'BOMPVALB(bmvunsub) ' || substrb(SQLERRM,1,60);
        return(SQLCODE);
end bmvunsub_verify_unique_sub;


/*------------------------ bmvitmrev_validate_itm_rev -----------------------*/
/* NAME
   bmvitmrev_validate_itm_rev - validate the item rev interface table
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
    err_text    out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmvitmrev_validate_itm_rev (
    org_id              NUMBER,
    all_org             NUMBER,
    user_id             NUMBER,
    login_id            NUMBER,
    prog_appid          NUMBER,
    prog_id             NUMBER,
    req_id              NUMBER,
    err_text    IN OUT  VARCHAR2
)
    return INTEGER
IS
    cursor c0 is
        select inventory_item_id AII, organization_id OI,
               revision R, transaction_id TI
        from mtl_item_revisions_interface
        where process_flag = 2
          and rownum < 500;

    cursor c1 is
        select inventory_item_id AII, organization_id OI
        from mtl_item_revisions_interface
        where process_flag = 99
          and rownum < 500
        group by organization_id, inventory_item_id;

    cursor c2 is
        select 'x'
          from mtl_item_revisions_interface
         where process_flag = 99
        group by organization_id, inventory_item_id;

    ret_code    NUMBER;
    dummy       NUMBER;
    dummy_id    NUMBER;
    stmt_num    NUMBER;
    commit_cnt  NUMBER;
    dummy_bill  NUMBER;
    continue_loop BOOLEAN := TRUE;
    total_recs	NUMBER;

BEGIN
/*
** Check if revision is null
*/
    while continue_loop loop
      commit_cnt := 0;
      for c0rec in c0 loop
        commit_cnt := commit_cnt + 1;
        stmt_num := 1;
        if (c0rec.R is null) then
           ret_code := INVPUOPI.mtl_log_interface_err(
               org_id => org_id,
               user_id => user_id,
               login_id => login_id,
               prog_appid => prog_appid,
               prog_id => prog_id,
               req_id => req_id,
               trans_id => c0rec.TI,
               error_text => err_text,
               tbl_name => 'MTL_ITEM_REVISIONS_INTERFACE',
               msg_name => 'BOM_NULL_REV',
               err_text => err_text);
         update mtl_item_revisions_interface set
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
                        tbl_name => 'MTL_ITEM_REVISIONS_INTERFACE',
                        msg_name => 'BOM_INVALID_ORG_ID',
                        err_text => err_text);
               update mtl_item_revisions_interface set
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
                        tbl_name => 'MTL_ITEM_REVISIONS_INTERFACE',
                        msg_name => 'BOM_INV_ITEM_INVALID',
                        err_text => err_text);
            update mtl_item_revisions_interface set
                    process_flag = 3
            where transaction_id = c0rec.TI;

            if (ret_code <> 0) then
                return(ret_code);
            end if;
            goto continue_loop;
        end if;

/*
** check if a valid bill exists for this revision
*/
     dummy_bill := 0;

     select count(*)
       into dummy_bill
      from bom_bill_of_materials
     where organization_id = c0rec.OI
       and assembly_item_id = c0rec.AII;

     if (dummy_bill = 0) then
            select count(*)
              into dummy_bill
              from bom_bill_of_mtls_interface
             where process_flag = 4
               and organization_id = c0rec.OI
               and assembly_item_id = c0rec.AII;

            if (dummy_bill = 0) then
               ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c0rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c0rec.TI,
                        error_text => err_text,
                        tbl_name => 'MTL_ITEM_REVISIONS_INTERFACE',
                        msg_name => 'BOM_BILL_DOES_NOT_EXIST',
                        err_text => err_text);
               update mtl_item_revisions_interface set
                    process_flag = 3
               where transaction_id = c0rec.TI;

               if (ret_code <> 0) then
                  return(ret_code);
               end if;
               goto continue_loop;
           end if;
     end if;

     update mtl_item_revisions_interface set
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
        ret_code := BOMPVALB.bmvalrev_validate_rev (
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
        err_text := 'BOMPVALB(bmvitmrev)' || substrb(SQLERRM,1,60);
        return(SQLCODE);
END bmvitmrev_validate_itm_rev;

/*--------------------------- bmvalrev_validate_rev -------------------------*/
/* NAME
   bmvalrev_validate_rev - validate item revision
DESCRIPTION
   validate revs
        - ensure revs in ascending order
        - no duplicate revs
REQUIRES
    org_id              NUMBER,
    assy_id             NUMBER,
    err_text    out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION bmvalrev_validate_rev (
    org_id              NUMBER,
    assy_id             NUMBER,
    user_id             NUMBER,
    login_id            NUMBER,
    prog_appid          NUMBER,
    prog_id             NUMBER,
    req_id              NUMBER,
    err_text    IN OUT  VARCHAR2
)
    return INTEGER
IS
    cursor c1 is
        select revision R, effectivity_date ED,
                transaction_id TI
        from mtl_item_revisions_interface
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
          from mtl_item_revisions_interface a
         where transaction_id <> c1rec.TI
           and   inventory_item_id = assy_id
           and   organization_id = org_id
           and   process_flag = 4
           and ( (revision = c1rec.R)
                or
                  (effectivity_date > c1rec.ED
                   and revision < c1rec.R)
                or
                  (effectivity_date < c1rec.ED
                   and revision > c1rec.R)
                );

        if (err_cnt <> 0) then
            goto write_error;
        end if;

        stmt_num := 2;
        select count(*)
            into err_cnt
            from mtl_item_revisions
            where inventory_item_id = assy_id
            and   organization_id = org_id
            and ( (revision = c1rec.R)
                or
                  (effectivity_date > c1rec.ED
                   and revision < c1rec.R)
                or
                  (effectivity_date < c1rec.ED
                   and revision > c1rec.R)
                );

        if (err_cnt <> 0) then
            goto write_error;
        end if;

        stmt_num := 3;
        update mtl_item_revisions_interface set
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
                        tbl_name => 'MTL_ITEM_REVISIONS_INTERFACE',
                        msg_name => 'BOM_REV_INVALID',
                        err_text => err_text);
        update mtl_item_revisions_interface set
            process_flag = 3
        where transaction_id = c1rec.TI;
<<continue_loop>>
        null;
    end loop;
    return(0);
exception
    when others then
        err_text := 'BOMPVALB(bmvalrev-' || stmt_num || ')' || substrb(SQLERRM,1,60);
        return(SQLCODE);
END bmvalrev_validate_rev;

END BOMPVALB;

/
