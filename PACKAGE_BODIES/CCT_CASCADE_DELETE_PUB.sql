--------------------------------------------------------
--  DDL for Package Body CCT_CASCADE_DELETE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_CASCADE_DELETE_PUB" AS
/* $Header: cctcsdeb.pls 120.1 2005/11/09 22:20:19 dbhagat noship $ */

PROCEDURE delete_defunct_del_middlewares AS
   BEGIN
    SAVEPOINT CCT_MIDDLEWARE_DEFUNCT_DEL_DEL;

       delete_deleted_middlewares;
       delete_defunct_middlewares;

   EXCEPTION
      WHEN OTHERS THEN
          rollback TO SAVEPOINT CCT_MIDDLEWARE_DEFUNCT_DEL_DEL;
          raise_application_error(-20000, sqlerrm || '. Could not delete defunct deleted middlewares')  ;

   END;


  PROCEDURE delete_defunct_middlewares
   IS
    l_config_id cct_middlewares.middleware_id%type;

    CURSOR c_configs IS
           select a.middleware_id
           from cct_middlewares a
           where f_deletedflag <> 'D'
           OR f_deletedflag is null
           and not exists
           (select server_group_id from ieo_svr_groups b where b.server_group_id = a.server_group_id );


   BEGIN
        SAVEPOINT CCT_MIDDLEWARE_DEFUNCT_DEL;
        OPEN c_configs;

        LOOP

          FETCH c_configs INTO l_config_id;

          IF c_configs%NOTFOUND THEN
            CLOSE c_configs;
            exit;
          ELSE
            delete_middleware(p_middleware_id =>l_config_id);
          END IF;
       END LOOP;


   EXCEPTION
      WHEN OTHERS THEN
          rollback TO SAVEPOINT CCT_MIDDLEWARE_DEFUNCT_DEL;
          raise_application_error(-20000, sqlerrm || '. Could not delete defunct middlewares')  ;

   END;

PROCEDURE delete_deleted_middlewares
   IS
    l_config_id cct_middlewares.middleware_id%type;

    CURSOR c_configs IS
           select distinct a.server_group_id
           from cct_middlewares a
           where f_deletedflag <> 'D'
           OR f_deletedflag is null
           and not exists
           (select server_group_id from ieo_svr_groups b where b.server_group_id = a.server_group_id );
   BEGIN
        SAVEPOINT CCT_MIDDLEWARE_DELETED_DEL;
        OPEN c_configs;

        LOOP

          FETCH c_configs INTO l_config_id;

          IF c_configs%NOTFOUND THEN
            CLOSE c_configs;
            exit;
          ELSE
            delete_middleware(p_middleware_id =>l_config_id);
          END IF;
       END LOOP;

   EXCEPTION
      WHEN OTHERS THEN
          rollback TO SAVEPOINT CCT_MIDDLEWARE_DELETED_DEL;
          raise_application_error(-20000, sqlerrm || '. Could not delete deleted middlewares')  ;
   END;

    PROCEDURE delete_middleware
    ( p_server_group_id IN NUMBER
      , p_commit_flag IN VARCHAR2)
   IS
    l_config_id cct_middlewares.middleware_id%type;

    CURSOR c_configs IS
       select middleware_id
       from cct_middlewares
       where server_group_id = p_server_group_id;

   BEGIN
      IF p_server_group_id is not null
      then
        SAVEPOINT CCT_MIDDLEWARE_SVR_DEL;
        OPEN c_configs;

        LOOP

          FETCH c_configs INTO l_config_id;

          IF c_configs%NOTFOUND THEN
            CLOSE c_configs;
            exit;
          ELSE
            delete_middleware(p_middleware_id =>l_config_id);
          END IF;
       END LOOP;


       END IF;
       IF p_commit_flag = 'Y' THEN
         commit;
       END IF;
   EXCEPTION
      WHEN OTHERS THEN
          rollback TO SAVEPOINT CCT_MIDDLEWARE_SVR_DEL;
          raise_application_error(-20000, sqlerrm || '. Could not delete teleset')  ;
   END;


    PROCEDURE delete_middleware
    ( p_middleware_id IN NUMBER
      , p_commit_flag IN VARCHAR2)
   IS

   CURSOR csr_jtf_rs_resource_values
   is
   select resource_param_value_id, value_type, object_version_number
   from jtf_rs_resource_values
   where value_type = to_char(p_middleware_id);

   l_param_value_id      jtf_rs_resource_values.resource_param_value_id%TYPE;
   l_value_type          jtf_rs_resource_values.value_type%TYPE;
   l_obj_ver             jtf_rs_resource_values.object_version_number%TYPE;
   l_return_status varchar2(32);
   l_msg_count    NUMBER;
   l_msg_data    VARCHAR2(32);

   BEGIN
      IF p_middleware_id is not null
      then
        SAVEPOINT CCT_MIDDLEWARE_DEL;

        -- Delete Child records first
       delete_teleset(p_middleware_id => p_middleware_id);
       delete_ivr(p_middleware_id => p_middleware_id);
       delete_multisite(p_middleware_id => p_middleware_id);
       delete_route_point(p_middleware_id => p_middleware_id);

       delete cct_middleware_values
       where middleware_id = p_middleware_id;

       --  delete jtf_rs_resource_values
       --  where value_type = to_char(p_middleware_id);
      BEGIN
      OPEN csr_jtf_rs_resource_values;

       -- Fixed bug 4676911 dbhagat 10-Nov-2005
       FETCH csr_jtf_rs_resource_values into l_param_value_id,l_value_type,l_obj_ver ;
       WHILE (csr_jtf_rs_resource_values%FOUND) LOOP
            jtf_rs_resource_values_pub.delete_rs_resource_values
           (
                 p_api_version             => 1
                 ,p_commit                 => fnd_api.g_true
                 ,p_resource_param_value_id => l_param_value_id
                 ,p_object_version_number => l_obj_ver
                 ,x_return_status => l_return_status
                 ,x_msg_count => l_msg_count
                 ,x_msg_data => l_msg_data
           );

           FETCH csr_jtf_rs_resource_values into l_param_value_id,l_value_type,l_obj_ver ;
       END LOOP;
       CLOSE csr_jtf_rs_resource_values;
      --LOOP
      --  FETCH csr_jtf_rs_resource_values into l_param_value_id,l_value_type,l_obj_ver ;
      --  IF csr_jtf_rs_resource_values%NOTFOUND THEN
      --     CLOSE csr_jtf_rs_resource_values;
      --  ELSE
      --     jtf_rs_resource_values_pub.delete_rs_resource_values
      --     (
      --           p_api_version             => 1
      --           ,p_commit                 => fnd_api.g_true
      --           ,p_resource_param_value_id => l_param_value_id
      --           ,p_object_version_number => l_obj_ver
      --           ,x_return_status => l_return_status
      --           ,x_msg_count => l_msg_count
      --           ,x_msg_data => l_msg_data
      --     );
      --  END IF;
      --END LOOP;

      END;

       delete cct_middlewares
       where middleware_id = p_middleware_id;
       END IF;
       IF p_commit_flag = 'Y' THEN
         commit;
       END IF;
   EXCEPTION
      WHEN OTHERS THEN
          rollback TO SAVEPOINT CCT_MIDDLEWARE_DEL;
          raise_application_error(-20000, sqlerrm || '. Could not delete middleware for middleware'||p_middleware_id)  ;
   END;


   --Tested
   PROCEDURE delete_teleset
    ( p_middleware_id IN NUMBER
      , p_commit_flag IN VARCHAR2)
   IS
   BEGIN
      IF p_middleware_id is not null
      then
        SAVEPOINT CCT_TELESET_DEL;
        -- Delete Child records first
        delete cct_lines
        where teleset_id in (select  teleset_id
                      from cct_telesets
                      where middleware_id = p_middleware_id);

       delete cct_telesets
       where middleware_id = p_middleware_id;
       END IF;
       IF p_commit_flag = 'Y' THEN
         commit;
       END IF;
   EXCEPTION
      WHEN OTHERS THEN
          rollback TO SAVEPOINT CCT_TELESET_DEL;
          raise_application_error(-20000, sqlerrm || '. Could not delete teleset')  ;

   END;


  /* Delete IVR values
  */
   --Tested
   PROCEDURE delete_ivr
    ( p_middleware_id IN NUMBER
      , p_commit_flag IN VARCHAR2)
   IS
   BEGIN
      IF p_middleware_id is not null
      then
        SAVEPOINT CCT_IVR_DEL;
        -- Delete Child records first
        delete cct_ivr_maps
        where mw_route_point_id in (select mw_route_point_id
                      from cct_mw_route_points
                      where middleware_id = p_middleware_id);
      END IF;
      IF p_commit_flag = 'Y' THEN
         commit;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
          rollback TO SAVEPOINT CCT_IVR_DEL;
          raise_application_error(-20000, sqlerrm || '. Could not delete IVR')  ;
   END;

   PROCEDURE delete_ivr
    ( p_route_point_id IN NUMBER
      , p_commit_flag IN VARCHAR2)
   IS
   BEGIN
      IF p_route_point_id is not null
      then
        SAVEPOINT CCT_IVR_RP_DEL;
        -- Delete Child records first
        delete cct_ivr_maps
        where mw_route_point_id = p_route_point_id;
      END IF;
      IF p_commit_flag = 'Y' THEN
         commit;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
          rollback TO SAVEPOINT CCT_IVR_RP_DEL;
          raise_application_error(-20000, sqlerrm || '. Could not delete IVR')  ;
   END;


   PROCEDURE delete_multisite
    ( p_middleware_id IN NUMBER
     , p_commit_flag IN VARCHAR2)
   IS
     l_config_id cct_multisite_configs.multisite_config_id%type;
     CURSOR c_configs IS
       select multisite_config_id
       from cct_multisite_configs
       where from_middleware_id = p_middleware_id
       or to_middleware_id =  p_middleware_id;
   BEGIN
      IF p_middleware_id is not null
      then
        SAVEPOINT CCT_MULTISITE_DEL;
        -- Delete Child records first
        OPEN c_configs;

        LOOP

          FETCH c_configs INTO l_config_id;
	      IF c_configs%NOTFOUND THEN
            CLOSE c_configs;
             exit;
          ELSE
            delete_multisite_paths(p_multisite_config_id =>l_config_id);

            delete cct_multisite_values
            where  multisite_config_id = l_config_id;

          END IF;
       END LOOP;

        delete cct_multisite_configs
        where from_middleware_id = p_middleware_id
        or to_middleware_id = p_middleware_id;
      END IF;
      IF p_commit_flag = 'Y' THEN
         commit;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
          rollback TO SAVEPOINT CCT_MULTISITE_DEL;
          raise_application_error(-20000, sqlerrm || '. Could not delete multisite')  ;

   END;

   PROCEDURE delete_multisite_paths
    ( p_multisite_config_id IN NUMBER
      , p_commit_flag IN VARCHAR2)
   IS
   BEGIN
      IF p_multisite_config_id is not null
      then
        SAVEPOINT CCT_MULTISITE_PATHS_DEL;
        -- Delete Child records first
        delete cct_multisite_path_values
        where multisite_path_id IN(select multisite_path_id
                           from cct_multisite_paths
                           where multisite_config_id = p_multisite_config_id);

        delete cct_multisite_paths
        where multisite_config_id = p_multisite_config_id;
      END IF;
      IF p_commit_flag = 'Y' THEN
         commit;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
          rollback TO SAVEPOINT CCT_MULTISITE_PATHS_DEL;
          raise_application_error(-20000, sqlerrm || '. Could not delete multisite paths')  ;
   END;

 PROCEDURE delete_route_point
    ( p_middleware_id IN NUMBER
     , p_commit_flag IN VARCHAR2)
   IS
     l_id cct_mw_route_points.mw_route_point_id%type;
     CURSOR c_rpts IS
       select mw_route_point_id
       from cct_mw_route_points
       where middleware_id = p_middleware_id;
   BEGIN
      IF p_middleware_id is not null
      then
        SAVEPOINT CCT_ROUTE_POINT_DEL;
        -- Delete Child records first
        OPEN c_rpts;

        LOOP

          FETCH c_rpts INTO l_id;
          IF c_rpts%NOTFOUND THEN
            CLOSE c_rpts;
            exit;

          ELSE
            delete_multisite_paths(p_mw_route_point_id =>l_id);
            delete_ivr(p_route_point_id=>l_id);
            delete cct_mw_route_point_values
            where  mw_route_point_id = l_id;
          END IF;
       END LOOP;

        delete cct_mw_route_points
        where middleware_id = p_middleware_id;

      END IF;
      IF p_commit_flag = 'Y' THEN
         commit;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
          rollback TO SAVEPOINT CCT_ROUTE_POINT_DEL;
          raise_application_error(-20000, sqlerrm || '. Could not delete Route Points')  ;
   END;



PROCEDURE delete_multisite_paths
    ( p_mw_route_point_id IN NUMBER
      , p_commit_flag IN VARCHAR2)
   IS
   BEGIN
      IF p_mw_route_point_id is not null
      then
        SAVEPOINT CCT_MULTISITE_PATHS_RP_DEL;
        -- Delete Child records first
        delete cct_multisite_path_values
        where multisite_path_id IN(select multisite_path_id
                           from cct_multisite_paths
                           where mw_route_point_id = p_mw_route_point_id);

        delete cct_multisite_paths
        where mw_route_point_id = p_mw_route_point_id;
      END IF;
      IF p_commit_flag = 'Y' THEN
         commit;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
          rollback TO SAVEPOINT CCT_MULTISITE_PATHS_RP_DEL;
          raise_application_error(-20000, sqlerrm || '. Could not delete multisite paths')  ;
   END;

END CCT_CASCADE_DELETE_PUB; -- Package Specification CCT_CASCADE_DELETE_PUB

/
