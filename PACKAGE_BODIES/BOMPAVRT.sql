--------------------------------------------------------
--  DDL for Package Body BOMPAVRT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOMPAVRT" as
/* $Header: BOMAVRTB.pls 115.2 99/07/16 05:09:43 porting ship $ */
/*==========================================================================+
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMAVRTB.pls                                               |
| DESCRIPTION  : This is the main package used to assign and verify         |
|                routing data                                               |
| Parameters:	org_id		organization_id                             |
|		all_org		process all orgs or just current org        |
|				1 - all orgs                                |
|				2 - only org_id                             |
|    		prog_appid      program application_id                      |
|    		prog_id  	program id                                  |
|    		request_id      request_id                                  |
|    		user_id		user id                                     |
|    		login_id	login id                                    |
| Return:	1 if success                                                |
|		SQLCODE if failure                                          |
| History:	                                                            |
|    04/27/94   Russ Chaney     creation date                               |
|                                                                           |
+==========================================================================*/
FUNCTION bmasrtg_assign_rtg_data (
    org_id		NUMBER,
    all_org		NUMBER,
    prog_appid		NUMBER,
    prog_id		NUMBER,
    request_id		NUMBER,
    user_id		NUMBER,
    login_id		NUMBER,
    err_text     OUT 	VARCHAR2
)
    return INTEGER
IS
    err_msg		VARCHAR2(2000);
    ret_code		NUMBER := 1;

begin

	ret_code := BOMPASGR.bmartorg_assign_rtg_orgid(
		err_text => err_msg);
	if (ret_code <> 0) then
            err_msg := ret_code || ' bmartorg_assign_rtg_orgid ' || substrb( err_msg,1,100);
            rollback;
 	    goto error_label;
	end if;
	commit;

        ret_code := BOMPASGR.bmasrrev_assign_rtg_revision(
                org_id => org_id,
                all_org => all_org,
                user_id => user_id,
                login_id => login_id,
                prog_appid => prog_appid,
                prog_id => prog_id,
                req_id => request_id,
                err_text => err_msg);
        if (ret_code <> 0) then
            err_msg := ret_code||' bmasrrev_assign_rtg_revision '|| substrb(err_msg,1,100);
            rollback;
            goto error_label;
        end if;
        commit;

	ret_code := BOMPASGR.bmprtgh_assign_rtg_header(
		org_id => org_id,
                all_org => all_org,
                user_id => user_id,
                login_id => login_id,
                prog_appid => prog_appid,
                prog_id => prog_id,
                req_id => request_id,
		err_text => err_msg);
	if (ret_code <> 0) then
            err_msg := ret_code||' bmprtgh_assign_rtg_header '|| substrb(err_msg,1,100);
            rollback;
	    goto error_label;
	end if;
        commit;

        ret_code := BOMPASGR.bmasopd_assign_operation_data(
                org_id => org_id,
                all_org => all_org,
                user_id => user_id,
                login_id => login_id,
                prog_appid => prog_appid,
                prog_id => prog_id,
                req_id => request_id,
                err_text => err_msg);
        if (ret_code <> 0) then
            err_msg := ret_code||' bmasopd_assign_operation_data '|| substrb(err_msg,1,100);
            rollback;
            goto error_label;
        end if;
        commit;

        ret_code := BOMPASGR.bmasrsd_assign_resource_data(
                org_id => org_id,
                all_org => all_org,
                user_id => user_id,
                login_id => login_id,
                prog_appid => prog_appid,
                prog_id => prog_id,
                req_id => request_id,
                err_text => err_msg);
        if (ret_code <> 0) then
            err_msg := ret_code||' bmasrsd_assign_resource_data '|| substrb(err_msg,1,100);
            rollback;
            goto error_label;
        end if;
        commit;

    return(0);

<<error_label>>
    err_text := substrb('BOMPAVRT.bmasrtg_assign_rtg_data' || err_msg,1,200);
    return(ret_code);

exception
    when others then
	err_text := substrb('BOMPAVRT.bmasrtg_assign_rtg_data' || SQLERRM,1,60);
	return(ret_code);
end bmasrtg_assign_rtg_data;


FUNCTION bmvrrtg_verify_rtg_data (
    org_id              NUMBER,
    all_org             NUMBER,
    prog_appid          NUMBER,
    prog_id             NUMBER,
    request_id          NUMBER,
    user_id             NUMBER,
    login_id            NUMBER,
    err_text     OUT    VARCHAR2
)
    return INTEGER
IS
    err_msg             VARCHAR2(2000);
    ret_code            NUMBER := 1;

begin
        ret_code := BOMPVALR.bmvrtgh_validate_rtg_header(
                org_id => org_id,
                all_org => all_org,
                user_id => user_id,
                login_id => login_id,
                prog_appid => prog_appid,
                prog_id => prog_id,
                request_id => request_id,
                err_text => err_msg);
        if (ret_code <> 0) then
            err_msg := ret_code||' bmvrtgh_validate_rtg_header ' || substrb(err_msg,1,100);
            rollback;
            goto error_label;
        end if;
        commit;

        ret_code := BOMPVALR.bmvopr_validate_operations(
                org_id => org_id,
                all_org => all_org,
                user_id => user_id,
                login_id => login_id,
                prog_appid => prog_appid,
                prog_id => prog_id,
                request_id => request_id,
                err_text => err_msg);
        if (ret_code <> 0) then
            err_msg := ret_code||' bmvopr_validate_operations ' || substrb( err_msg,1,100);
            rollback;
            goto error_label;
        end if;
        commit;

        ret_code := BOMPVALR.bmvres_validate_resources(
                org_id => org_id,
                all_org => all_org,
                user_id => user_id,
                login_id => login_id,
                prog_appid => prog_appid,
                prog_id => prog_id,
                request_id => request_id,
                err_text => err_msg);
        if (ret_code <> 0) then
            err_msg := ret_code||' bmvres_validate_resources ' || substrb( err_msg,1,100);
            rollback;
            goto error_label;
        end if;
        commit;

        ret_code := BOMPVALR.bmvrtgrev_validate_rtg_rev(
                org_id => org_id,
                all_org => all_org,
                user_id => user_id,
                login_id => login_id,
                prog_appid => prog_appid,
                prog_id => prog_id,
                req_id => request_id,
                err_text => err_msg);
        if (ret_code <> 0) then
            err_msg := ret_code||' bmvrtgrev_validate_rtg_rev ' || substrb( err_msg,1,100);
            rollback;
            goto error_label;
        end if;
        commit;

    return(0);

<<error_label>>
    err_text := substrb('BOMPAVRT.bmvrrtg_verify_rtg_data ' ||  err_msg,1,200);
    return(ret_code);

exception
    when others then
        err_text := substrb('BOMPAVRT.bmvrrtg_verify_rtg_data ' || SQLERRM,1,60);
        return(ret_code);
end bmvrrtg_verify_rtg_data;

END BOMPAVRT;

/
