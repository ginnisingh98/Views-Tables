--------------------------------------------------------
--  DDL for Package Body BOMPAVBM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOMPAVBM" as
/* $Header: BOMAVBMB.pls 115.2 99/07/16 05:09:35 porting ship $ */
-- ==========================================================================
--    Copyright (c) 1993 Oracle Corporation Belmont, California, USA
--                           All rights reserved.
-- ==========================================================================
--
--  File Name    : BOMAVBMB.pls
--  DESCRIPTION  : This is the main package used to assign and verify bill
--                 data
--  Parameters:	org_id		organization_id
-- 		all_org		process all orgs or just current org
-- 				1 - all orgs
-- 				2 - only org_id
--     		prog_appid      program application_id
--     		prog_id  	program id
--     		request_id      request_id
--     		user_id		user id
--     		login_id	login id
--  Return:	1 if success
-- 		SQLCODE if failure
--  History:
--     04/08/94   Julie Maeyama	creation date
--
-- =========================================================================

  G_maxlen constant number := 60; -- maximum size of sql error

FUNCTION bmasbill_assign_bill_data (
    org_id		NUMBER,
    all_org		NUMBER		:= 1,
    prog_appid		NUMBER		:= -1,
    prog_id		NUMBER		:= -1,
    request_id		NUMBER		:= -1,
    user_id		NUMBER		:= -1,
    login_id		NUMBER		:= -1,
    err_text     OUT 	VARCHAR2
)
    return INTEGER
IS
    err_msg		VARCHAR2(2000);
    ret_code		NUMBER := 1;

begin

	ret_code := BOMPASGB.bmablorg_assign_bill_orgid(
		err_text => err_msg);
	if (ret_code <> 0) then
            err_msg := ret_code || ' bmablorg_assign_bill_orgid ' || substrb(err_msg,1,100);
            rollback;
 	    goto error_label;
	end if;
	commit;

        ret_code := BOMPASGB.bmasrev_assign_revision(
                org_id => org_id,
                all_org => all_org,
                user_id => user_id,
                login_id => login_id,
                prog_appid => prog_appid,
                prog_id => prog_id,
                req_id => request_id,
                err_text => err_msg);
        if (ret_code <> 0) then
            err_msg := ' bmasrev_assign_revision ' || substr(err_msg,1,100);
            rollback;
            goto error_label;
        end if;
        commit;

	ret_code := BOMPASGB.bmasbilh_assign_bill_header(
		org_id => org_id,
                all_org => all_org,
                user_id => user_id,
                login_id => login_id,
                prog_appid => prog_appid,
                prog_id => prog_id,
                req_id => request_id,
		err_text => err_msg);
	if (ret_code <> 0) then
            err_msg := ' bmasbilh_assign_bill_header ' || substr(err_msg,1,100);
            rollback;
	    goto error_label;
	end if;
        commit;

        ret_code := BOMPASGB.bmascomp_assign_comp(
                org_id => org_id,
                all_org => all_org,
                user_id => user_id,
                login_id => login_id,
                prog_appid => prog_appid,
                prog_id => prog_id,
                req_id => request_id,
                err_text => err_msg);
        if (ret_code <> 0) then
            err_msg := ' bmascomp_assign_comp ' || substr(err_msg,1,100);
            rollback;
            goto error_label;
        end if;
        commit;

        ret_code := BOMPASGB.bmasrefd_assign_ref_desg_data(
                org_id => org_id,
                all_org => all_org,
                user_id => user_id,
                login_id => login_id,
                prog_appid => prog_appid,
                prog_id => prog_id,
                req_id => request_id,
                err_text => err_msg);
        if (ret_code <> 0) then
            err_msg := ' bmasrefd_assign_ref_desg_data ' || substr(err_msg,1,100);
            rollback;
            goto error_label;
        end if;
        commit;

        ret_code := BOMPASGB.bmassubd_assign_sub_comp_data(
                org_id => org_id,
                all_org => all_org,
                user_id => user_id,
                login_id => login_id,
                prog_appid => prog_appid,
                prog_id => prog_id,
                req_id => request_id,
                err_text => err_msg);
        if (ret_code <> 0) then
            err_msg := ' bmassubd_assign_sub_comp_data ' || substr(err_msg,1,100);
            rollback;
            goto error_label;
        end if;
        commit;

    return(0);

<<error_label>>
    err_text := 'BOMPAVBM.bmasbill_assign_bill_data' || substr(err_msg,1,200);
    return(ret_code);

exception
    when others then
	err_text := 'BOMPAVBM.bmasbill_assign_bill_data' ||
                     substrb(SQLERRM, 1, G_maxlen);
	return(ret_code);
end bmasbill_assign_bill_data;


FUNCTION bmvrbill_verify_bill_data (
    org_id              NUMBER,
    all_org             NUMBER          := 1,
    prog_appid          NUMBER          := -1,
    prog_id             NUMBER          := -1,
    request_id          NUMBER          := -1,
    user_id             NUMBER          := -1,
    login_id            NUMBER          := -1,
    err_text     OUT    VARCHAR2
)
    return INTEGER
IS
    err_msg             VARCHAR2(2000);
    ret_code            NUMBER := 1;

begin

        ret_code := BOMPVALB.bmvbomh_validate_bom_header(
                org_id => org_id,
                all_org => all_org,
                user_id => user_id,
                login_id => login_id,
                prog_appid => prog_appid,
                prog_id => prog_id,
                request_id => request_id,
                err_text => err_msg);
        if (ret_code <> 0) then
            err_msg := ' bmvbomh_validate_bom_header ' || substr(err_msg,1,100);
            rollback;
            goto error_label;
        end if;
        commit;

        ret_code := BOMPVALB.bmvcomp_validate_components(
                org_id => org_id,
                all_org => all_org,
                user_id => user_id,
                login_id => login_id,
                prog_appid => prog_appid,
                prog_id => prog_id,
                request_id => request_id,
                err_text => err_msg);
        if (ret_code <> 0) then
            err_msg := ' bmvcomp_validate_components ' || substr(err_msg,1,100);
            rollback;
            goto error_label;
        end if;
        commit;

        ret_code := BOMPVALB.bmvref_validate_ref_desgs(
                org_id => org_id,
                all_org => all_org,
                user_id => user_id,
                login_id => login_id,
                prog_appid => prog_appid,
                prog_id => prog_id,
                request_id => request_id,
                err_text => err_msg);
        if (ret_code <> 0) then
            err_msg := ' bmvref_validate_ref_desgs ' || substr(err_msg,1,100);
            rollback;
            goto error_label;
        end if;
        commit;

        ret_code := BOMPVALB.bmvsubs_validate_sub_comps(
                org_id => org_id,
                all_org => all_org,
                user_id => user_id,
                login_id => login_id,
                prog_appid => prog_appid,
                prog_id => prog_id,
                request_id => request_id,
                err_text => err_msg);
        if (ret_code <> 0) then
            err_msg := ' bmvsubs_validate_sub_comps ' || substr(err_msg,1,100);
            rollback;
            goto error_label;
        end if;
        commit;

        ret_code := BOMPVALB.bmvitmrev_validate_itm_rev(
                org_id => org_id,
                all_org => all_org,
                user_id => user_id,
                login_id => login_id,
                prog_appid => prog_appid,
                prog_id => prog_id,
                req_id => request_id,
                err_text => err_msg);
        if (ret_code <> 0) then
            err_msg := ' bmvitmrev_validate_itm_rev ' || substr(err_msg,1,100);
            rollback;
            goto error_label;
        end if;
        commit;

    return(0);

<<error_label>>
    err_text := 'BOMPAVBM.bmvrbill_verify_bill_data ' || substr(err_msg,1,200);
    return(ret_code);

exception
    when others then
        err_text := 'BOMPAVBM.bmvrbill_verify_bill_data ' ||
                    substrb(SQLERRM, 1, G_maxlen);
        return(ret_code);
end bmvrbill_verify_bill_data;

END BOMPAVBM;

/
