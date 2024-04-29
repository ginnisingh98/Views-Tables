--------------------------------------------------------
--  DDL for Package Body JTF_RS_CONC_REPMGR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_CONC_REPMGR_PUB" as
  /* $Header: jtfrsbpb.pls 120.0 2005/05/11 08:19:21 appldev ship $ */
-- Type: Public
-- Purpose: Inserts IN  the JTF_RS_REP_MANAGERS
-- Modification History
-- DATE NAME       PURPOSE
-- 4-DEC-2000    SR CHOUDHURY  CREATED
-- 5-FEB-2001    N SINGHAI     Added procedure sync_role_relation to be called
--                             from new concurrent program JTFRSRMG
--

 G_PKG_NAME VARCHAR2(30) := 'JTF_RS_CONC_REPMGR_PUB';
procedure populate_repmgr
  (ERRBUF   OUT NOCOPY VARCHAR2,
   RETCODE  OUT NOCOPY VARCHAR2)
is

--alter sequence JTF.JTF_RS_REP_MANAGERS_S cache 1000;

   variable_mesg  varchar2(1000);
   validation_fail  EXCEPTION;

--***************************************--
-- This cursor only gets manager records --
--***************************************--
   cursor GET_GRPDENORM is
   select /*+ parallel(rrel) */ rrel.role_relate_id
   from JTF_RS_ROLE_RELATIONS rrel
   where rrel.role_resource_type = 'RS_GROUP_MEMBER';


   l_role_relate_id   NUMBER;
   x_return_status    VARCHAR2(1);
   x_msg_count        NUMBER;
   x_msg_data         VARCHAR2(2000);
   l_write_dir        VARCHAR2(2000);
   my_message         VARCHAR2(2000);
   Invalid_dir        EXCEPTION;

   i_commit             NUMBER := 0;
   commit_counter       NUMBER := 1000;
   i_analyze            NUMBER := 0;
   analyze_counter      NUMBER := 1000;
   i                    number;

BEGIN

--**************************--
-- Reporting manager denorm --
--**************************--
--************************************--
-- Take out denorm API in this script --
-- We will have another script to do  --
-- denormalization                    --
--************************************--

   i_commit := 0;
   i_analyze := 0;
   analyze_counter := 1000;


   x_return_status :=  FND_API.G_RET_STS_SUCCESS;
   open GET_GRPDENORM;
   loop
   begin
 savepoint RM_GRPDENORM;
 fetch GET_GRPDENORM into l_role_relate_id;
 exit when GET_GRPDENORM%NOTFOUND;

 jtf_rs_rep_mgr_denorm_pvt.insert_rep_manager_migr
      ( P_API_VERSION     =>     1.0,
        P_ROLE_RELATE_ID  =>     l_role_relate_id,
        X_RETURN_STATUS   =>     x_return_status,
        X_MSG_COUNT       =>     x_msg_count,
        X_MSG_DATA        =>     x_msg_data
 );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         for i in 1..x_msg_count
              loop
                 fnd_file.put_line(fnd_file.log, (fnd_msg_pub.get(i,
                                             p_encoded => fnd_api.g_false)));


               end loop;
      END IF;

      IF(i_commit > commit_counter) THEN
         commit;
         i_commit := 0;
      ELSE
         i_commit := i_commit + 1;
      END IF;

   exception
      when others then
       fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);
       ROLLBACK to RM_GRPDENORM;
   end;
   end loop;
   close GET_GRPDENORM;

   commit;

EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
    fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);
      ROLLBACK TO TERMINATE_EMPLOYEE_SP;

    WHEN OTHERS
    THEN
       fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);
      ROLLBACK TO TERMINATE_EMPLOYEE_SP;
      fnd_file.put_line(fnd_file.log, sqlerrm);

end populate_repmgr;

   PROCEDURE  sync_rep_mgr
          (ERRBUF                    OUT NOCOPY VARCHAR2,
           RETCODE                    OUT NOCOPY VARCHAR2)
   IS
     l_operation_flag       VARCHAR2(1);
     l_init_msg_list        VARCHAR2(10) := FND_API.G_FALSE;
     l_return_status        VARCHAR2(200);
     l_msg_count            NUMBER;
     l_msg_data             VARCHAR2(200);
     x_return_status        VARCHAR2(200);
     i                      NUMBER;
     halt_operation         EXCEPTION;


     CURSOR c_get_role IS
            SELECT  role_relate_id,
                    operation_flag,
                    rowid row_id
              FROM  JTF_RS_CHGD_ROLE_RELATIONS
          ORDER BY  creation_date ;
             -- FOR   UPDATE OF role_relate_id;

   BEGIN

     SAVEPOINT CONC_SP;

        FOR l_role IN c_get_role LOOP

         BEGIN

         SAVEPOINT CONC_ROLE_SP;

          IF l_role.operation_flag = 'I' THEN
                   JTF_RS_REP_MGR_DENORM_PVT.INSERT_REP_MANAGER
                          ( P_API_VERSION     => 1.0,
                            P_INIT_MSG_LIST   => l_init_msg_list,
                            P_COMMIT          => FND_API.G_TRUE,
                            P_ROLE_RELATE_ID  => l_role.role_relate_id,
                            X_RETURN_STATUS   => l_return_status,
                            X_MSG_COUNT       => l_msg_count,
                            X_MSG_DATA        => l_msg_data);

               IF(l_return_status <>  fnd_api.g_ret_sts_success)
               THEN
               FOR i in 1..l_msg_count
                 LOOP
                  fnd_file.put_line(fnd_file.log, (fnd_msg_pub.get(i, p_encoded => fnd_api.g_false)));
                 END LOOP;
                 RAISE halt_operation;
               END IF;
         END IF;

         IF  l_role.operation_flag = 'U' THEN

                --call to UPDATE records in jtf_rs_rep_managers
                JTF_RS_REP_MGR_DENORM_PVT.UPDATE_REP_MANAGER
                            ( P_API_VERSION => 1.0,
                              P_INIT_MSG_LIST  => l_init_msg_list,
                              P_COMMIT        =>  FND_API.G_TRUE,
                              P_ROLE_RELATE_ID  => l_role.role_relate_id,
                              X_RETURN_STATUS   => l_return_status,
                              X_MSG_COUNT       => l_msg_count,
                              X_MSG_DATA        => l_msg_data);

                 IF(l_return_status <>  fnd_api.g_ret_sts_success)
                 THEN
                    FOR i in 1..l_msg_count
                    LOOP
                     fnd_file.put_line(fnd_file.log, (fnd_msg_pub.get(i, p_encoded => fnd_api.g_false)));
                    END LOOP;
                    RAISE halt_operation;
                 END IF;
           END IF;

         IF  l_role.operation_flag = 'D' THEN

		      JTF_RS_REP_MGR_DENORM_PVT.DELETE_MEMBERS
                                  ( P_API_VERSION     => 1.0,
                                    P_INIT_MSG_LIST   => l_init_msg_list,
                                    P_COMMIT          => FND_API.G_TRUE,
                                    P_ROLE_RELATE_ID  => l_role.role_relate_id,
	     		            X_RETURN_STATUS   => l_return_status,
			            X_MSG_COUNT       => l_msg_count,
			            X_MSG_DATA        => l_msg_data);

		      IF(l_return_status <>  fnd_api.g_ret_sts_success)
		      THEN
		        FOR i in 1..l_msg_count
	                LOOP
	                  fnd_file.put_line(fnd_file.log, (fnd_msg_pub.get(i, p_encoded => fnd_api.g_false)));
	                END LOOP;
	                RAISE halt_operation;
	              END IF;
	   END IF;

       -- After sucessful completion delete the row

       DELETE FROM JTF_RS_CHGD_ROLE_RELATIONS
       --WHERE  CURRENT OF c_get_role ;
       WHERE  role_relate_id = l_role.role_relate_id
         AND  rowid          = l_role.row_id ;

       COMMIT;

       EXCEPTION WHEN halt_operation THEN
                 ROLLBACK TO CONC_ROLE_SP;
      END;

     END LOOP;

 EXCEPTION
     WHEN fnd_api.g_exc_unexpected_error THEN
           fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);
           ROLLBACK TO CONC_SP;
     WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);
      ROLLBACK TO CONC_SP;

 END sync_rep_mgr;

end jtf_rs_conc_repmgr_pub;

/
