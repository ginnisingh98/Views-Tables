--------------------------------------------------------
--  DDL for Package Body JTF_RS_CONC_GRP_DENORM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_CONC_GRP_DENORM_PUB" AS
/* $Header: jtfrsbdb.pls 120.0 2005/05/11 08:19:16 appldev ship $ */


  /*****************************************************************************************
     This is a concurrent program to fetch all the records which are avaialble in
     in JTF_RS_CHGD_GRP_RELATIONS Table. This is the intermidiate table which will keep all
     the records which have to be  updated / deleted / inserted in JTF_RS_GROUP_RELATIONS.
     After successful processing the row will be deleted from JTF_RS_CHGD_GRP_RELATIONS.

   ******************************************************************************************/


    /* Package variables. */

  G_PKG_NAME         VARCHAR2(30) := 'JTF_RS_CONC_GRP_DENORM_PUB';


   PROCEDURE  sync_grp_denorm
   (ERRBUF                    OUT NOCOPY VARCHAR2,
   RETCODE                    OUT NOCOPY VARCHAR2
   )
   IS
     l_operation_flag       VARCHAR2(1);
     l_group_id             NUMBER;
     l_init_msg_list        VARCHAR2(10) := FND_API.G_FALSE;
     l_return_status        VARCHAR2(200);
     l_msg_count            NUMBER;
     l_msg_data             VARCHAR2(200);
     x_return_status        VARCHAR2(200);
     i                      NUMBER;
     halt_operation         EXCEPTION;
     l_commit               VARCHAR2(10) := FND_API.G_TRUE;


     CURSOR c_get_grp IS
            SELECT  group_relate_id,
                    group_id,
                    related_group_id,
                    relation_type,
                    operation_flag,
                    rowid row_id
              FROM  JTF_RS_CHGD_GRP_RELATIONS
          ORDER BY  creation_date;
	--      FOR   UPDATE OF group_relate_id;

   BEGIN

        FOR l_grp IN c_get_grp LOOP

         BEGIN

         SAVEPOINT CONC_GROUP_SP;

          IF l_grp.operation_flag = 'I' THEN

           JTF_RS_GROUP_DENORM_PVT.INSERT_GROUPS
                   ( P_API_VERSION     => 1.0,
                     P_INIT_MSG_LIST   => l_init_msg_list,
                     P_COMMIT          => 'F',
                     P_GROUP_ID        => l_grp.group_id,
                     X_RETURN_STATUS   => l_return_status,
                     X_MSG_COUNT       => l_msg_count,
                     X_MSG_DATA        => l_msg_data);

               IF(l_return_status <>  fnd_api.g_ret_sts_success)
               THEN
               FOR i in 1..l_msg_count
                 LOOP
                  fnd_file.put_line(fnd_file.log, (fnd_msg_pub.get(i,
                                                p_encoded => fnd_api.g_false)));

                 END LOOP;

                   RAISE halt_operation;

                END IF;


                 --call to insert records in jtf_rs_rep_managers
		 -- commented out on 04/25/2001 because now rep_managers will now be populated by
		 -- JTF_RS_GROUP_DENORM_PVT.INSERT_GROUPS api (called above)

/*            JTF_RS_REP_MGR_DENORM_PVT.INSERT_GRP_RELATIONS
                   ( P_API_VERSION      => 1.0,
                     P_INIT_MSG_LIST    => l_init_msg_list,
                     P_COMMIT           => l_commit,
                     P_GROUP_RELATE_ID  => l_grp.group_relate_id,
                     X_RETURN_STATUS    => l_return_status,
                     X_MSG_COUNT        => l_msg_count,
                     X_MSG_DATA         => l_msg_data);

               IF(l_return_status <>  fnd_api.g_ret_sts_success)
               THEN
               FOR i in 1..l_msg_count
                 LOOP
                  fnd_file.put_line(fnd_file.log, (fnd_msg_pub.get(i,
                                                p_encoded => fnd_api.g_false)));

                 END LOOP;

                   RAISE halt_operation;
               END IF;
*/

        END IF;

        IF  l_grp.operation_flag = 'U' THEN

  	     JTF_RS_GROUP_DENORM_PVT.UPDATE_GROUPS
	               ( P_API_VERSION     => 1.0,
	                 P_INIT_MSG_LIST   => l_init_msg_list,
	                 P_COMMIT          => 'F',
	                 P_GROUP_ID        => l_grp.group_id,
	                 X_RETURN_STATUS   => l_return_status,
                         X_MSG_COUNT       => l_msg_count,
                         X_MSG_DATA        => l_msg_data);

                IF(l_return_status <>  fnd_api.g_ret_sts_success)
		THEN
                 FOR i in 1..l_msg_count
                 LOOP
                  fnd_file.put_line(fnd_file.log, (fnd_msg_pub.get(i,
                                                p_encoded => fnd_api.g_false)));

                 END LOOP;

                    RAISE halt_operation;
                END IF;
        END IF;

        IF  l_grp.operation_flag = 'D' THEN

             JTF_RS_GROUP_DENORM_PVT.DELETE_GRP_RELATIONS
                                 ( P_API_VERSION     => 1.0,
                                   P_INIT_MSG_LIST   => l_init_msg_list,
                                   P_COMMIT          => 'F',
                                   P_group_relate_id => l_grp.group_relate_id,
                                   P_GROUP_ID        => l_grp.group_id,
                                   P_RELATED_GROUP_ID => l_grp.related_group_id,
                                   X_RETURN_STATUS   => l_return_status,
                                   X_MSG_COUNT       => l_msg_count,
                                   X_MSG_DATA        => l_msg_data);
              IF(l_return_status <>  fnd_api.g_ret_sts_success)
   	      THEN
               FOR i in 1..l_msg_count
                 LOOP
                  fnd_file.put_line(fnd_file.log, (fnd_msg_pub.get(i,
                                                p_encoded => fnd_api.g_false)));

                 END LOOP;

         	  RAISE halt_operation;
              END IF;
        END IF;

       -- After sucessful completion delete the row

	DELETE FROM JTF_RS_CHGD_GRP_RELATIONS
        WHERE  group_relate_id = l_grp.group_relate_id
        AND    rowid = l_grp.row_id ;
--	WHERE  CURRENT OF c_get_grp ;


        COMMIT;

        EXCEPTION WHEN halt_operation THEN
                  ROLLBACK TO CONC_GROUP_SP;
      END;

      END LOOP;

    EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
       fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);
       ROLLBACK TO CONC_GROUP_SP;
    WHEN OTHERS
    THEN
       fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);
       ROLLBACK TO CONC_GROUP_SP;

   END sync_grp_denorm;

END jtf_rs_conc_grp_denorm_pub;

/
