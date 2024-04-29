--------------------------------------------------------
--  DDL for Package Body INVPASGI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVPASGI" as
/* $Header: INVPAG1B.pls 120.2 2007/05/14 14:01:02 anmurali ship $ */

--------------------------- mtl_pr_assign_item_data ---------------------------

FUNCTION mtl_pr_assign_item_data
(
org_id          number,
all_org         NUMBER          := 2,
prog_appid      NUMBER          := -1,
prog_id         NUMBER          := -1,
request_id      NUMBER          := -1,
user_id         NUMBER          := -1,
login_id        NUMBER          := -1,
err_text     IN  OUT NOCOPY varchar2,
xset_id      IN  NUMBER    DEFAULT  -999,
default_flag IN  NUMBER    DEFAULT  1
)
RETURN INTEGER
IS
   rtn_status     NUMBER  :=  0;
   dumm_status    NUMBER  :=  0;
   l_inv_debug_level	NUMBER := INVPUTLI.get_debug_level;  --Bug: 4667452
BEGIN

   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVPASGI.mtl_pr_assign_item_data : begin');
      INVPUTLI.info('INVPASGI.mtl_pr_assign_item_data: calling INVPAGI2.assign_item_header_recs');
   END IF;

   rtn_status := INVPAGI2.assign_item_header_recs (
                        org_id,
			all_org,
			prog_appid,
			prog_id,
			request_id,
			user_id,
			login_id,
                        err_text,
                        xset_id,
                        default_flag);

   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVPASGI.mtl_pr_assign_item_data: done INVPAGI2.assign_item_header_recs: rtn_status='||rtn_status);
   END IF;

   IF (rtn_status <> 0) THEN
      dumm_status := INVPUOPI.mtl_log_interface_err (
                                -1,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                -1,
                                '*** BAD RETURN CODE b ***' || err_text,
                                null,
				'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_ERR',
                                err_text);

      RETURN (rtn_status);
   END IF;

   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVPASGI.mtl_pr_assign_item_data: before INVPAGI3.assign_item_revs');
   END IF;


   rtn_status := INVPAGI3.assign_item_revs (
                      org_id,
                      all_org,
                      prog_appid,
                      prog_id,
                      request_id,
                      user_id,
                      login_id,
                      err_text,
                      xset_id,
                      default_flag);


   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVPASGI.mtl_pr_assign_item_data: after INVPAGI3.assign_item_revs: rtn_status = '||rtn_status);
   END IF;


   IF (rtn_status <> 0) THEN
      dumm_status := INVPUOPI.mtl_log_interface_err (
                                -1,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                -1,
                                '*** BAD RETURN CODE e ***' || err_text,
                                null,
                                'MTL_ITEM_REVISIONS_INTERFACE',
                                'INV_IOI_ERR',
                                err_text);
      RETURN (rtn_status);
   END IF;

   RETURN (rtn_status);

EXCEPTION

   WHEN others THEN
      err_text := substr('INVPASGI.mtl_pr_assign_item_data:' || SQLERRM, 1,240);
      RETURN (SQLCODE);

END mtl_pr_assign_item_data;


END INVPASGI;

/
