--------------------------------------------------------
--  DDL for Package Body CSM_IB_TXN_SUB_TYPES_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_IB_TXN_SUB_TYPES_EVENT_PKG" AS
/* $Header: csmeibtb.pls 120.3 2006/09/05 07:02:36 trajasek noship $*/
--
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

PROCEDURE Refresh_Acc (p_status OUT NOCOPY VARCHAR2,
                       p_message OUT NOCOPY VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_updates_cur CSM_UTIL_PKG.Changed_Records_Cur_Type;
l_inserts_cur CSM_UTIL_PKG.Changed_Records_Cur_Type;
l_dsql varchar2(3000);
l_pub_item varchar2(30) := 'CSF_M_TXN_SUB_TYPES';
l_prog_update_date jtm_con_request_data.last_run_date%TYPE;
l_mark_dirty boolean;
l_access_id  CSM_IB_TXN_TYPES_ACC.ACCESS_ID%TYPE;
l_language cs_transaction_types_tl.language%TYPE;
l_sub_type_id csi_ib_txn_types.sub_type_id%TYPE;

l_tl_omfs_palm_resource_list asg_download.user_list;
l_single_access_id_list asg_download.access_list;
--a null list
l_null_access_list asg_download.access_list;
l_null_resource_list asg_download.user_list;
l_run_date DATE;
l_sqlerrno varchar2(20);
l_sqlerrmsg varchar2(2000);

CURSOR l_last_run_date_csr
IS
SELECT nvl(last_run_date, (sysdate - 365*50))
FROM jtm_con_request_data
WHERE package_name = 'CSM_IB_TXN_SUB_TYPES_EVENT_PKG'
AND procedure_name = 'REFRESH_ACC';

CURSOR l_deletes_cur
IS
SELECT acc.access_id
FROM csm_ib_txn_types_acc acc
WHERE NOT EXISTS
(SELECT cit.sub_type_id
 FROM csi_ib_txn_types cit , csi_source_ib_types cst , csi_txn_types ctt ,
      csi_instance_statuses cis , cs_transaction_types_b ttb
WHERE acc.sub_type_id = cit.sub_type_id
AND cit.cs_transaction_type_id = ttb.transaction_type_id(+)
AND ctt.source_application_id = 513
AND ctt.source_transaction_type = 'FIELD_SERVICE_REPORT'
AND cst.sub_type_id = cit.sub_type_id
AND ctt.transaction_type_id = cst.transaction_type_id
AND cit.src_status_id = cis.instance_status_id(+)
AND (NVL(cst.update_IB_flag, 'N') = 'N' --Non IB
     OR ( cst.update_ib_flag = 'Y'
          and trunc(sysdate) between nvl(cis.start_date_active,trunc(sysdate)) and nvl(cis.end_date_active,trunc(sysdate))
          and nvl(cis.terminated_flag, 'N') <> 'Y'
          and (
		  	  	(--Return IB
		  	  	 cit.src_change_owner_to_code = 'I'
		  	  	 and nvl(cit.parent_reference_reqd, 'N') = 'N'
				 and ttb.line_order_category_code ='RETURN'
          		 and cit.src_change_owner = 'Y'
          	  	 and nvl(cit.src_return_reqd, 'N') = 'N'

				)
             or (--Order IB
			 	cit.src_change_owner_to_code = 'E'
			 	--and cit.src_reference_reqd = 'Y'
			 	and ttb.line_order_category_code='ORDER'
          		and cit.src_change_owner = 'Y'
          		and nvl(cit.src_return_reqd, 'N') = 'N'

			    )
              or
			    (--Loaner IB
				ttb.line_order_category_code='ORDER'
				and NVL(cit.src_change_owner,'N') = 'N'
				and nvl(cit.src_return_reqd, 'Y') = 'Y'
				AND NVL(cit.src_change_owner_to_code,'N') ='N'

				)

              )
        )
     )
);

l_temp_date date;

CURSOR l_txn_types_tl_cur (p_transaction_type_id IN cs_transaction_types_b.transaction_type_id%TYPE)
IS
SELECT tt_tl.LANGUAGE
FROM cs_transaction_types_tl tt_tl
WHERE tt_tl.transaction_type_id = p_transaction_type_id;

cursor record_exists_csr( p_sub_type_id csi_ib_txn_types.sub_type_id%TYPE)
IS
SELECT 1
FROM csm_ib_txn_types_acc
WHERE sub_type_id = p_sub_type_id;

l_dummy number;

BEGIN
  -- get last conc program update date
  OPEN l_last_run_date_csr;
  FETCH l_last_run_date_csr INTO l_prog_update_date;
  CLOSE l_last_run_date_csr;

  -- conc program run date
  l_run_date := SYSDATE;

  --get all the OMFS Palm users
  g_all_palm_res_list := CSM_UTIL_PKG.get_all_omfs_palm_res_list;

  /****** DELETES  **********/
  --open the cursor
   open l_deletes_cur;
   --loop over cursor entries, and update in the acc table, as well as mark dirty the SDQ
   LOOP
     FETCH l_deletes_cur INTO l_access_id;
     EXIT WHEN l_deletes_cur%NOTFOUND;

     --mark dirty the SDQ for all users
     FOR i IN 1 .. g_all_palm_res_list.COUNT LOOP
       l_mark_dirty := CSM_UTIL_PKG.MakeDirtyForResource(l_pub_item,
                                                         l_access_id,
                                                         g_all_palm_res_list(i),
                                                         ASG_DOWNLOAD.DEL,
                                                         SYSDATE);
     END LOOP;

     --remove from ACC
     DELETE FROM CSM_IB_TXN_TYPES_ACC
       WHERE ACCESS_ID = l_access_id;

   END LOOP;
   --close the cursor
   close l_deletes_cur;

  /******* UPDATES **********/
  --generate sql for updates
  l_dsql := 'SELECT acc.access_id
             FROM csm_ib_txn_types_acc acc ,
                  csi_ib_txn_types cit,
                  csi_source_ib_types cst ,
                  csi_txn_types ctt ,
                  csi_instance_statuses cis ,
                  cs_transaction_types_b ttb
             WHERE acc.sub_type_id = cit.sub_type_id
             AND cit.cs_transaction_type_id = ttb.transaction_type_id(+)
             AND ctt.source_application_id = 513
             AND ctt.source_transaction_type = ''FIELD_SERVICE_REPORT''
             AND cst.sub_type_id = cit.sub_type_id
             AND ctt.transaction_type_id = cst.transaction_type_id
             AND cit.src_status_id = cis.instance_status_id(+)
             AND (NVL(cst.update_IB_flag, ''N'') = ''N''
                  OR ( cst.update_ib_flag = ''Y''
                     and trunc(sysdate) between nvl(cis.start_date_active,trunc(sysdate)) and nvl(cis.end_date_active,trunc(sysdate))
                     and nvl(cis.terminated_flag, ''N'') <> ''Y''
                     and (
					 	   (cit.src_change_owner_to_code = ''I''
						    and nvl(cit.parent_reference_reqd, ''N'') = ''N''
							and ttb.line_order_category_code =''RETURN''
                  		    and cit.src_change_owner = ''Y''
                  		    and nvl(cit.src_return_reqd, ''N'') = ''N''

							)
                          or
						    (cit.src_change_owner_to_code = ''E''
							and ttb.line_order_category_code=''ORDER''
                  		    and cit.src_change_owner = ''Y''
                  		    and nvl(cit.src_return_reqd, ''N'') = ''N''

							)
                         or (
   						    ttb.line_order_category_code=''ORDER''
                 		    and NVL(cit.src_change_owner,''N'') = ''N''
				            and nvl(cit.src_return_reqd, ''Y'') = ''Y''
						    AND NVL(cit.src_change_owner_to_code,''N'') =''N''

					        )

                         )
                     )
                 )
              AND (cit.last_update_date > :1
                 or cst.last_update_date > :2
                 or ctt.last_update_date > :3
                 or cis.last_update_date > :4
                 or ttb.last_update_date > :5
               )';

  --open the cursor
   open l_updates_cur for l_dsql USING l_prog_update_date, l_prog_update_date, l_prog_update_date, l_prog_update_date, l_prog_update_date;
   --loop over cursor entries, and update in the acc table, as well as mark dirty the SDQ
   LOOP
     FETCH l_updates_cur INTO l_access_id;
     EXIT WHEN l_updates_cur%NOTFOUND;

     --get all Palm users
     g_all_palm_res_list := CSM_UTIL_PKG.get_all_omfs_palm_res_list;

     --nullify the access list
     l_single_access_id_list := l_null_access_list;
     FOR i in 1 .. g_all_palm_res_list.COUNT LOOP
         l_single_access_id_list(i) := l_access_id;
     END LOOP;

     --mark dirty the SDQ for all users
     IF l_single_access_id_list.count > 0 then
      l_mark_dirty := CSM_UTIL_PKG.MakeDirtyForResource(l_pub_item,
          l_single_access_id_list, g_all_palm_res_list,
          ASG_DOWNLOAD.UPD, sysdate);
     END IF;

     --update ACC
     UPDATE CSM_IB_TXN_TYPES_ACC
       SET LAST_UPDATE_DATE = l_run_date
       WHERE ACCESS_ID = l_access_id;

   END LOOP;

   --close the cursor
   close l_updates_cur;

  /****** INSERTS  **********/
  --generate sql for inserts
  l_dsql := 'SELECT cit.sub_type_id
            FROM csi_ib_txn_types cit , csi_source_ib_types cst , csi_txn_types ctt ,
                 csi_instance_statuses cis , cs_transaction_types_b ttb
           WHERE cit.cs_transaction_type_id = ttb.transaction_type_id(+)
           AND ctt.source_application_id = 513
           AND ctt.source_transaction_type = ''FIELD_SERVICE_REPORT''
           AND cst.sub_type_id = cit.sub_type_id
           AND ctt.transaction_type_id = cst.transaction_type_id
           AND cit.src_status_id = cis.instance_status_id(+)
           AND (NVL(cst.update_IB_flag, ''N'') = ''N''--Non IB
               OR ( cst.update_ib_flag = ''Y''
                  and trunc(sysdate) between nvl(cis.start_date_active,trunc(sysdate)) and nvl(cis.end_date_active,trunc(sysdate))
                  and nvl(cis.terminated_flag, ''N'') <> ''Y''
                  and (   (--Retirn IB
				          cit.src_change_owner_to_code = ''I''
				  	      and nvl(cit.parent_reference_reqd, ''N'') = ''N''
						  and ttb.line_order_category_code =''RETURN''
                  		  and cit.src_change_owner = ''Y''
                  		  and nvl(cit.src_return_reqd, ''N'') = ''N''

						  )
                       or (--Order IB
					      cit.src_change_owner_to_code = ''E''
					 	  and ttb.line_order_category_code=''ORDER''
                  		  and cit.src_change_owner = ''Y''
                  		  and nvl(cit.src_return_reqd, ''N'') = ''N''

					      )
                       or (--Loaner IB
   						   ttb.line_order_category_code=''ORDER''
                 		   and NVL(cit.src_change_owner,''N'') = ''N''
						   and nvl(cit.src_return_reqd, ''Y'') = ''Y''
						   AND NVL(cit.src_change_owner_to_code,''N'') =''N''

					      )
                      )
                  )
               )
            AND NOT EXISTS
            (SELECT 1
             FROM csm_ib_txn_types_acc acc
             WHERE acc.sub_type_id = cit.sub_type_id
             ) ';

  --open the cursor
   open l_inserts_cur for l_dsql;
   --loop over cursor entries, and update in the acc table, as well as mark dirty the SDQ
   LOOP
     FETCH l_inserts_cur INTO l_sub_type_id;
     EXIT WHEN l_inserts_cur%NOTFOUND;

     --generate access_id
     select CSM_IB_TXN_TYPES_ACC_S.NEXTVAL into l_access_id from dual;

     --get all Palm users
     g_all_palm_res_list := CSM_UTIL_PKG.get_all_omfs_palm_res_list;

     --nullify the access list
     l_single_access_id_list := l_null_access_list;
     FOR i in 1 .. g_all_palm_res_list.COUNT LOOP
         l_single_access_id_list(i) := l_access_id;
     END LOOP;

     --mark dirty the SDQ for all users
     IF l_single_access_id_list.count > 0 then
      l_mark_dirty := CSM_UTIL_PKG.MakeDirtyForResource(l_pub_item,
          l_single_access_id_list, g_all_palm_res_list,
          ASG_DOWNLOAD.INS, sysdate);
     END IF;

     --insert into
     --check if the record exists
     OPEN record_exists_csr (l_sub_type_id);
     FETCH record_exists_csr into l_dummy;

     IF record_exists_csr%NOTFOUND then
         --insert if the value does not already exists
          INSERT INTO csm_ib_txn_types_acc(access_id, sub_type_id, CREATED_BY,
                       CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN)
          VALUES (l_access_id,l_sub_type_id, fnd_global.user_id, l_run_date,
                fnd_global.user_id, l_run_date, fnd_global.login_id);

     END IF;
     CLOSE record_exists_csr;

   END LOOP;
   --close the cursor
   close l_inserts_cur;

   -- set the program update date in jtm_con_request_data to sysdate
   UPDATE jtm_con_request_data
   SET last_run_date = l_run_date
   WHERE package_name = 'CSM_IB_TXN_SUB_TYPES_EVENT_PKG'
     AND procedure_name = 'REFRESH_ACC';

 COMMIT;

  p_status := 'FINE';
  p_message :=  'CSM_IB_TXN_SUB_TYPES_EVENT_PKG.Refresh_Acc Executed successfully';

 EXCEPTION
  WHEN others THEN
     if record_exists_csr%isopen then
     	close record_exists_csr;
     end if;
     l_sqlerrno := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     p_status := 'ERROR';
     p_message :=  'Error in CSM_IB_TXN_SUB_TYPES_EVENT_PKG.Refresh_Acc: '|| l_sqlerrno || ':' || l_sqlerrmsg;
     ROLLBACK;
     fnd_file.put_line(fnd_file.log, 'CSM_IB_TXN_SUB_TYPES_EVENT_PKG.REFRESH_ACC ERROR : ' || l_sqlerrno || ':' || l_sqlerrmsg);
END Refresh_Acc;

END CSM_IB_TXN_SUB_TYPES_EVENT_PKG;

/
