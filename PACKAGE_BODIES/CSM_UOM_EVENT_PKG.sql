--------------------------------------------------------
--  DDL for Package Body CSM_UOM_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_UOM_EVENT_PKG" AS
/* $Header: csmeuomb.pls 120.2 2006/04/06 05:19:34 trajasek noship $ */

PROCEDURE INSERT_CSM_UOM_TL_ACC (p_access_id IN number,
                                 p_uom_code mtl_units_of_measure_tl.uom_code%TYPE,
                                 p_language mtl_units_of_measure_tl.language%TYPE
                                 )
IS
    l_sysdate 	DATE;
BEGIN
    l_sysdate := SYSDATE;

  	INSERT INTO csm_unit_of_measure_tl_acc (access_id, uom_code,    language,   created_by,         creation_date,
                  							last_updated_by,    last_update_date, last_update_login
                                           )
                           			VALUES (p_access_id, p_uom_code, p_language, fnd_global.user_id, l_sysdate,
									       fnd_global.user_id,  l_sysdate,        fnd_global.login_id);
EXCEPTION
     WHEN others THEN
	    RAISE;

END;-- end INSERT_CSM_UOM_TL_ACC


PROCEDURE Refresh_acc(p_status OUT NOCOPY VARCHAR2,
                       p_message OUT NOCOPY VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;

--variable Declartions
l_pub_item     varchar2(30) := 'CSF_M_UOM';
l_run_date 	   date;
l_sqlerrno 	   varchar2(20);
l_sqlerrmsg    varchar2(2000);
l_mark_dirty   boolean;
l_prog_update_date           jtm_con_request_data.last_run_date%TYPE;
l_access_id 	   			 jtm_fnd_lookups_acc.access_id%TYPE;
l_tl_omfs_palm_resource_list asg_download.user_list;
l_null_resource_list 		 asg_download.user_list;
l_single_access_id_list 	 asg_download.access_list;
l_null_access_list 			 asg_download.access_list;
l_pkvalueslist 				 asg_download.pk_list;
l_null_pkvalueslist 		 asg_download.pk_list;

CURSOR l_last_run_date_csr(p_pub_item IN varchar2)
IS
SELECT nvl(last_run_date, (sysdate - 365*50))
FROM   jtm_con_request_data
WHERE  package_name   = 'CSM_UOM_EVENT_PKG'
AND    procedure_name = 'REFRESH_ACC';

-- inserts cursor
CURSOR l_uom_ins_csr
IS
SELECT uom.uom_code,
	   uom.language
FROM   mtl_units_of_measure_tl uom
WHERE  NOT EXISTS
(SELECT 1
 FROM  csm_unit_of_measure_tl_acc acc
 WHERE acc.uom_code = uom.uom_code
 AND   acc.language = uom.language
 );

 -- updates cur
CURSOR l_uom_upd_csr(p_last_upd_date date)
IS
SELECT acc.access_id,
	   uom.uom_code,
	   uom.language
FROM   mtl_units_of_measure_tl uom,
       csm_unit_of_measure_tl_acc acc
WHERE  acc.uom_code = uom.uom_code
AND    acc.language = uom.language
AND    uom.last_update_date > p_last_upd_date;

-- deletes cursor
CURSOR l_uom_del_csr
IS
SELECT acc.access_id,
	   acc.uom_code,
	   acc.language
FROM   csm_unit_of_measure_tl_acc acc
WHERE NOT EXISTS
(SELECT 1
 FROM  mtl_units_of_measure_tl uom
 WHERE acc.uom_code = uom.uom_code
 AND   acc.language = uom.language
 );

BEGIN
 -- data program is run
 l_run_date := SYSDATE;

-- SAVEPOINT pre_refresh;

 -- get last conc program update date
 OPEN  l_last_run_date_csr(l_pub_item);
 FETCH l_last_run_date_csr INTO l_prog_update_date;
 CLOSE l_last_run_date_csr;

 l_pkvalueslist := l_null_pkvalueslist;

   -- process all deletes
  FOR r_uom_del_rec IN l_uom_del_csr LOOP

     --get the users with this language
     l_tl_omfs_palm_resource_list := l_null_resource_list;
     l_tl_omfs_palm_resource_list := csm_util_pkg.get_tl_omfs_palm_resources(r_uom_del_rec.language);

     l_access_id := r_uom_del_rec.access_id;

     --nullify the access list
     l_single_access_id_list := l_null_access_list;

     FOR i in 1 .. l_tl_omfs_palm_resource_list.COUNT LOOP
         l_single_access_id_list(i) := l_access_id;
     END LOOP;

     l_pkvalueslist(1) := r_uom_del_rec.uom_code;
     l_pkvalueslist(2) := r_uom_del_rec.language;

     --mark dirty the SDQ for all users
     IF l_single_access_id_list.count > 0 THEN
      l_mark_dirty := CSM_UTIL_PKG.MakeDirtyForResource(l_pub_item,
          		   	  									l_single_access_id_list,
														l_tl_omfs_palm_resource_list,
          												ASG_DOWNLOAD.DEL,
														SYSDATE );
     END IF;

     -- delete from acc table
     DELETE FROM csm_unit_of_measure_tl_acc WHERE access_id = l_access_id;
  END LOOP;

  -- process all updates
  FOR r_uom_upd_rec IN l_uom_upd_csr(l_prog_update_date) LOOP

     --get the users with this language
     l_tl_omfs_palm_resource_list := l_null_resource_list;
     l_tl_omfs_palm_resource_list := csm_util_pkg.get_tl_omfs_palm_resources(r_uom_upd_rec.language);

     l_access_id := r_uom_upd_rec.access_id;

     --nullify the access list
     l_single_access_id_list := l_null_access_list;

     FOR i in 1 .. l_tl_omfs_palm_resource_list.COUNT LOOP
         l_single_access_id_list(i) := l_access_id;
     END LOOP;

     --mark dirty the SDQ for all users
     IF l_single_access_id_list.count > 0 THEN
      l_mark_dirty := CSM_UTIL_PKG.MakeDirtyForResource(l_pub_item,
          		   	  									l_single_access_id_list,
														l_tl_omfs_palm_resource_list,
          												ASG_DOWNLOAD.UPD,
														sysdate);
     END IF;

  END LOOP;

  -- process all inserts
  FOR r_uom_ins_rec IN l_uom_ins_csr LOOP

     --get the users with this language
     l_tl_omfs_palm_resource_list := l_null_resource_list;
     l_tl_omfs_palm_resource_list := csm_util_pkg.get_tl_omfs_palm_resources(r_uom_ins_rec.language);

     SELECT csm_unit_of_measure_tl_acc_s.nextval
     INTO l_access_id
     FROM dual;

     --nullify the access list
     l_single_access_id_list := l_null_access_list;

     FOR i in 1 .. l_tl_omfs_palm_resource_list.COUNT LOOP
         l_single_access_id_list(i) := l_access_id;
     END LOOP;

     --mark dirty the SDQ for all users
     IF l_single_access_id_list.count > 0 THEN
          l_mark_dirty := CSM_UTIL_PKG.MakeDirtyForResource(l_pub_item,
          		  	 								        l_single_access_id_list,
													   		l_tl_omfs_palm_resource_list,
          											   		ASG_DOWNLOAD.INS,
													   		sysdate);
     END IF;

     -- insert into csm_unit_of_measure_tl_acc
     INSERT_CSM_UOM_TL_ACC (l_access_id, r_uom_ins_rec.uom_code , r_uom_ins_rec.language);

  END LOOP;

  -- set the program update date in jtm_con_request_data to sysdate
  UPDATE jtm_con_request_data
  SET 	 last_run_date  = l_run_date
  WHERE  package_name   = 'CSM_UOM_EVENT_PKG'
  AND 	 procedure_name = 'REFRESH_ACC';

  COMMIT;

  p_status  := 'FINE';
  p_message := 'CSM_UOM_EVENT_PKG.Refresh_Acc Executed successfully';

 EXCEPTION
  WHEN others THEN
     l_sqlerrno  := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,1000);
     p_status 	 := 'ERROR';
     p_message 	 :=  'Error in CSM_UOM_EVENT_PKG.Refresh_Acc :' || l_sqlerrno || ':' || l_sqlerrmsg;
     ROLLBACK TO pre_refresh;
     fnd_file.put_line(fnd_file.log, 'CSM_UOM_EVENT_PKG ERROR : ' || l_sqlerrno || ':' || l_sqlerrmsg);
END Refresh_acc;

END CSM_UOM_EVENT_PKG;

/
