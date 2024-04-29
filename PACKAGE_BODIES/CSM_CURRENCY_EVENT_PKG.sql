--------------------------------------------------------
--  DDL for Package Body CSM_CURRENCY_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_CURRENCY_EVENT_PKG" AS
/* $Header: csmecurb.pls 120.1 2005/07/22 09:29:28 trajasek noship $ */

-- To modify this template, edit file PKGBODY.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package body
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter procedure, function bodies as shown below

g_all_palm_res_list asg_download.user_list;


/**
  Makes corresponding entries in to SDQ for all deletes, updates and inserts
  Refreshes for all the users
*/
procedure Refresh_Acc (p_status OUT NOCOPY VARCHAR2,
                       p_message OUT NOCOPY VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_updates_cur CSM_UTIL_PKG.Changed_Records_Cur_Type;
l_inserts_cur CSM_UTIL_PKG.Changed_Records_Cur_Type;
l_dsql varchar2(2048);
l_pub_item varchar2(30) := 'CSF_M_CURRENCIES';
l_prog_update_date jtm_con_request_data.last_run_date%TYPE;
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg varchar2(2000);

CURSOR l_last_run_date_csr(p_pub_item IN varchar2)
IS
SELECT nvl(last_run_date, (sysdate - 365*50))
FROM jtm_con_request_data
WHERE package_name = 'CSM_CURRENCY_EVENT_PKG'
AND procedure_name = 'REFRESH_ACC';


CURSOR l_deletes_csr(p_last_upd_date date)
IS
SELECT acc.access_id, curr.currency_code, curr_tl.language
FROM fnd_currencies curr,
     fnd_currencies_tl curr_tl,
     csm_currencies_acc acc
WHERE curr.currency_code = curr_tl.currency_code
AND   curr.currency_code = acc.currency_code
AND  ((SYSDATE not BETWEEN nvl(curr.start_date_active, sysdate) AND nvl(curr.end_date_active, sysdate))
      OR curr.enabled_flag <> 'Y')
AND ((curr.creation_date < p_last_upd_date AND curr.last_update_date > p_last_upd_date)
     OR (curr_tl.creation_date < p_last_upd_date AND curr_tl.last_update_date > p_last_upd_date)
    );

CURSOR l_access_id_csr IS
select csm_currencies_acc_s.NEXTVAL  from dual;

l_mark_dirty boolean;
l_curr_last_update_date fnd_currencies.LAST_UPDATE_DATE%TYPE;
l_curr_tl_last_update_date fnd_currencies.LAST_UPDATE_DATE%TYPE;
l_max_update_date fnd_currencies.LAST_UPDATE_DATE%TYPE;
l_language fnd_currencies_tl.language%TYPE;
l_currency_code fnd_currencies.currency_code%TYPE;
l_access_id CSM_currencies_ACC.ACCESS_ID%TYPE;
l_tl_omfs_palm_resource_list asg_download.user_list;
l_single_access_id_list asg_download.access_list;
--a null list
l_null_access_list asg_download.access_list;
l_run_date date;

BEGIN
  -- get last conc program update date
  OPEN l_last_run_date_csr(l_pub_item);
  FETCH l_last_run_date_csr INTO l_prog_update_date;
  CLOSE l_last_run_date_csr;

  -- conc program run date
  l_run_date := SYSDATE;

  --get all the OMFS Palm users
  g_all_palm_res_list := CSM_UTIL_PKG.get_all_omfs_palm_res_list;

  /****** DELETES  **********/
  --open the cursor
   open l_deletes_csr(l_prog_update_date);
   --loop over cursor entries, and update in the acc table, as well as mark dirty the SDQ
   LOOP
     FETCH l_deletes_csr INTO l_access_id, l_currency_code, l_language;
     EXIT WHEN l_deletes_csr%NOTFOUND;

     --get the users with this language
     l_tl_omfs_palm_resource_list := csm_util_pkg.get_tl_omfs_palm_resources(l_language);

     --nullify the access list
     l_single_access_id_list := l_null_access_list;
     FOR i in 1 .. l_tl_omfs_palm_resource_list.COUNT LOOP
         l_single_access_id_list(i) := l_access_id;
     END LOOP;

     --mark dirty the SDQ for all users
     IF l_single_access_id_list.count > 0 THEN
              l_mark_dirty := CSM_UTIL_PKG.MakeDirtyForResource('CSF_M_CURRENCIES',
                                                         l_single_access_id_list,
                                                         l_tl_omfs_palm_resource_list,
                                                         ASG_DOWNLOAD.DEL,
                                                         SYSDATE);
     END IF;

     --remove from ACC
     DELETE FROM CSM_CURRENCIES_ACC
       WHERE ACCESS_ID = l_access_id;

   END LOOP;

   --close the cursor
   close l_deletes_csr;

  /******* UPDATES **********/
  --generate sql for updates
  l_dsql :=
     'select acc.access_id, curr_tl.language, curr.last_update_date, curr_tl.last_update_date
      from csm_currencies_acc acc,
           fnd_currencies curr,
           fnd_currencies_tl curr_tl
      where acc.currency_code = curr.currency_code
      and curr_tl.currency_code = curr.currency_code
      AND  SYSDATE BETWEEN nvl(curr.start_date_active, sysdate) AND nvl(curr.end_date_active, sysdate)
      AND curr.enabled_flag = ''Y''
      AND (curr.last_update_date > :1
            or curr_tl.last_update_date > :2
           )';

--      AND (curr.last_update_date > ' || '''' || l_prog_update_date || ''''  ||
--           ' or curr_tl.last_update_date > ' || '''' || l_prog_update_date || '''' ||
--           ')';


  --open the cursor
   open l_updates_cur for l_dsql USING l_prog_update_date, l_prog_update_date;
   --loop over cursor entries, and update in the acc table, as well as mark dirty the SDQ
   LOOP
     FETCH l_updates_cur INTO l_access_id, l_language, l_curr_last_update_date, l_curr_tl_last_update_date;
     EXIT WHEN l_updates_cur%NOTFOUND;

     --get the users with this language
     l_tl_omfs_palm_resource_list := csm_util_pkg.get_tl_omfs_palm_resources(l_language);

     --nullify the access list
     l_single_access_id_list := l_null_access_list;
     FOR i in 1 .. l_tl_omfs_palm_resource_list.COUNT LOOP
         l_single_access_id_list(i) := l_access_id;
     END LOOP;

     --mark dirty the SDQ for all users
     IF l_single_access_id_list.count > 0 THEN
      l_mark_dirty := CSM_UTIL_PKG.MakeDirtyForResource('CSF_M_CURRENCIES',
          l_single_access_id_list, l_tl_omfs_palm_resource_list,
          ASG_DOWNLOAD.UPD, sysdate);
     END IF;

     --get the max update date
     IF (l_curr_last_update_date > l_curr_tl_last_update_date) THEN
       l_max_update_date := l_curr_last_update_date;
     ELSE
       l_max_update_date := l_curr_tl_last_update_date;
     END IF;

     --update ACC
     UPDATE CSM_BUS_PROCESS_TXNS_ACC
       SET LAST_UPDATE_DATE = l_run_date --l_max_update_date
       WHERE ACCESS_ID = l_access_id;

   END LOOP;

   --close the cursor
   close l_updates_cur;

  /****** INSERTS  **********/
  --generate sql for inserts

  l_dsql :=
      'SELECT curr.currency_code, curr.last_update_date
       FROM fnd_currencies curr
       WHERE  SYSDATE BETWEEN nvl(curr.start_date_active, sysdate) AND nvl(curr.end_date_active, sysdate)
       AND curr.enabled_flag = ''Y''
       AND NOT EXISTS
          (SELECT 1
           FROM CSM_CURRENCIES_ACC acc
           WHERE acc.currency_code = curr.currency_code
           )';

  --open the cursor
   open l_inserts_cur for l_dsql;
   --loop over cursor entries, and update in the acc table, as well as mark dirty the SDQ
   LOOP
     FETCH l_inserts_cur INTO l_currency_code, l_curr_last_update_date;
     EXIT WHEN l_inserts_cur%NOTFOUND;

     --generate access_id
    -- select csm_currencies_acc_s.NEXTVAL into l_access_id from dual;
     OPEN l_access_id_csr;
     FETCH l_access_id_csr INTO l_access_id;
     CLOSE l_access_id_csr;
     --mark dirty the SDQ for all users
     FOR i IN 1 .. g_all_palm_res_list.COUNT LOOP
       l_mark_dirty := CSM_UTIL_PKG.MakeDirtyForResource('CSF_M_CURRENCIES',
          l_access_id, g_all_palm_res_list(i),
          ASG_DOWNLOAD.INS, sysdate);
     END LOOP;

     --insert into
     INSERT INTO csm_currencies_acc(currency_code, access_id, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY,
       LAST_UPDATE_DATE, LAST_UPDATE_LOGIN)
     VALUES (l_currency_code, l_access_id, fnd_global.user_id, sysdate, fnd_global.user_id,
             l_curr_last_update_date, fnd_global.login_id);

   END LOOP;
   --close the cursor
   close l_inserts_cur;

   -- set the program update date in asg_pub_item to sysdate
   UPDATE jtm_con_request_data
   SET last_run_date = l_run_date
   WHERE package_name = 'CSM_CURRENCY_EVENT_PKG'
     AND procedure_name = 'REFRESH_ACC';

 commit;

 p_status := 'FINE';
 p_message :=  'CSM_CURRENCY_EVENT_PKG.REFRESH_ACC Executed successfully';

 EXCEPTION
  WHEN others THEN
     l_sqlerrno := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     p_status := 'ERROR';
     p_message :=  'Error in CSM_CURRENCY_EVENT_PKG.REFRESH_ACC :' ||l_sqlerrno || ':' ||l_sqlerrmsg;
     ROLLBACK;
     fnd_file.put_line(fnd_file.log, p_message);
END refresh_acc;

/*
PROCEDURE refresh_acc
IS
l_pub_item varchar2(30) := 'CSF_M_CURRENCIES';
l_prog_update_date asg_pub_item.last_run_date%TYPE;
l_access_id jtm_fnd_lookups_acc.access_id%TYPE;
l_mark_dirty boolean;
l_tl_omfs_palm_resource_list asg_download.user_list;
l_null_resource_list asg_download.user_list;
l_single_access_id_list asg_download.access_list;
--a null list
l_null_access_list asg_download.access_list;
l_run_date date;

CURSOR l_last_run_date_csr(p_pub_item IN varchar2)
IS
SELECT nvl(last_run_date, (sysdate - 365*50))
FROM asg_pub_item
WHERE name = p_pub_item
AND pub_name = 'SERVICEP';

CURSOR l_currency_ins_csr(p_last_upd_date date)
IS
SELECT curr.currency_code, curr_tl.language, curr.last_update_date
FROM fnd_currencies curr,
     fnd_currencies_tl curr_tl
WHERE curr.currency_code = curr_tl.currency_code
AND  SYSDATE BETWEEN nvl(curr.start_date_active, sysdate) AND nvl(curr.end_date_active, sysdate)
AND curr.enabled_flag = 'Y'
AND (curr.creation_date > p_last_upd_date
      OR curr_tl.creation_date > p_last_upd_date);

CURSOR l_currency_upd_csr(p_last_upd_date date)
IS
SELECT curr.currency_code, curr_tl.language
FROM fnd_currencies curr,
     fnd_currencies_tl curr_tl
WHERE curr.currency_code = curr_tl.currency_code
AND  SYSDATE BETWEEN nvl(curr.start_date_active, sysdate) AND nvl(curr.end_date_active, sysdate)
AND curr.enabled_flag = 'Y'
AND ((curr.creation_date < p_last_upd_date AND curr.last_update_date > p_last_upd_date)
     OR (curr_tl.creation_date < p_last_upd_date AND curr_tl.last_update_date > p_last_upd_date)
    );

CURSOR l_currency_del_csr(p_last_upd_date date)
IS
SELECT curr.currency_code, curr_tl.language
FROM fnd_currencies curr,
     fnd_currencies_tl curr_tl
WHERE curr.currency_code = curr_tl.currency_code
AND  ((SYSDATE not BETWEEN nvl(curr.start_date_active, sysdate) AND nvl(curr.end_date_active, sysdate))
      OR curr.enabled_flag <> 'Y')
AND ((curr.creation_date < p_last_upd_date AND curr.last_update_date > p_last_upd_date)
     OR (curr_tl.creation_date < p_last_upd_date AND curr_tl.last_update_date > p_last_upd_date)
    );

BEGIN
 -- get last conc program update date
 OPEN l_last_run_date_csr(l_pub_item);
 FETCH l_last_run_date_csr INTO l_prog_update_date;
 CLOSE l_last_run_date_csr;

 -- conc program run date
 l_run_date := SYSDATE;

  -- process all inserts
  FOR r_currency_ins_rec IN l_currency_ins_csr(l_prog_update_date) LOOP

     --get the users with this language
     l_tl_omfs_palm_resource_list := l_null_resource_list;
     l_tl_omfs_palm_resource_list := csm_util_pkg.get_tl_omfs_palm_resources(r_currency_ins_rec.language);

     -- get the access_id
     l_access_id :=  csm_util_pkg.generate_NumPK_FromStr(r_currency_ins_rec.currency_code || '.'
                                || r_currency_ins_rec.language);

     --nullify the access list
     l_single_access_id_list := l_null_access_list;
     FOR i in 1 .. l_tl_omfs_palm_resource_list.COUNT LOOP
         l_single_access_id_list(i) := l_access_id;
     END LOOP;

     --mark dirty the SDQ for all users
      l_mark_dirty := CSM_UTIL_PKG.MakeDirtyForResource('CSF_M_CURRENCIES',
          l_single_access_id_list, l_tl_omfs_palm_resource_list,
          ASG_DOWNLOAD.INS, sysdate);
  END LOOP;

  -- process all updates
  FOR r_currency_upd_rec IN l_currency_upd_csr(l_prog_update_date) LOOP
     --get the users with this language
     l_tl_omfs_palm_resource_list := l_null_resource_list;
     l_tl_omfs_palm_resource_list := csm_util_pkg.get_tl_omfs_palm_resources(r_currency_upd_rec.language);

     -- get the access_id
     l_access_id :=  csm_util_pkg.generate_NumPK_FromStr(r_currency_upd_rec.currency_code || '.'
                                || r_currency_upd_rec.language);

     --nullify the access list
     l_single_access_id_list := l_null_access_list;
     FOR i in 1 .. l_tl_omfs_palm_resource_list.COUNT LOOP
         l_single_access_id_list(i) := l_access_id;
     END LOOP;

     --mark dirty the SDQ for all users
      l_mark_dirty := CSM_UTIL_PKG.MakeDirtyForResource('CSF_M_CURRENCIES',
          l_single_access_id_list, l_tl_omfs_palm_resource_list,
          ASG_DOWNLOAD.UPD, sysdate);

  END LOOP;

  -- process all deletes
  FOR r_currency_del_rec IN l_currency_del_csr(l_prog_update_date) LOOP
     --get the users with this language
     l_tl_omfs_palm_resource_list := l_null_resource_list;
     l_tl_omfs_palm_resource_list := csm_util_pkg.get_tl_omfs_palm_resources(r_currency_del_rec.language);

     -- get the access_id
     l_access_id :=  csm_util_pkg.generate_NumPK_FromStr(r_currency_del_rec.currency_code || '.'
                                || r_currency_del_rec.language);

     --nullify the access list
     l_single_access_id_list := l_null_access_list;
     FOR i in 1 .. l_tl_omfs_palm_resource_list.COUNT LOOP
         l_single_access_id_list(i) := l_access_id;
     END LOOP;

     --mark dirty the SDQ for all users
      l_mark_dirty := CSM_UTIL_PKG.MakeDirtyForResource('CSF_M_CURRENCIES',
          l_single_access_id_list, l_tl_omfs_palm_resource_list,
          ASG_DOWNLOAD.DEL, sysdate);

  END LOOP;

  -- set the program update date in asg_pub_item to sysdate
  UPDATE asg_pub_item
  SET last_run_date = l_run_date
  WHERE name = l_pub_item
  AND pub_name = 'SERVICEP';

END refresh_acc;
*/

END CSM_CURRENCY_EVENT_PKG;

/
