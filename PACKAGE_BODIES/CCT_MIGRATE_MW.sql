--------------------------------------------------------
--  DDL for Package Body CCT_MIGRATE_MW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_MIGRATE_MW" as
/* $Header: cctmigmb.pls 115.3 2004/06/22 02:47:02 gvasvani noship $ */
procedure migrate_middleware(p_mw1_id IN NUMBER,p_mw2_id IN NUMBER,p_name IN VARCHAR2 )
IS
l_mw_id NUMBER;
BEGIN
     l_mw_id := '';
     if (p_name is not null) then
       begin
       select middleware_id into l_mw_id from cct_middlewares
       where middleware_type_id= p_mw1_id
       and config_name=p_name
       and nvl(f_deletedflag,'Y') <> 'D';
       Exception
       WHEN OTHERS THEN
         return; --Given Config Name doesn't exists.
       end;

       update cct_middlewares set middleware_type_id=p_mw2_id
       where middleware_type_id=p_mw1_id
       and config_name=p_name;
     else
       update cct_middlewares set middleware_type_id=p_mw2_id
       where middleware_type_id=p_mw1_id;

     end if;
     delete_params(p_mw1_id,p_mw2_id,l_mw_id);
     update_params(p_mw1_id,p_mw2_id,l_mw_id);

     --Delete older middleware type id, so it doesn't appear in Admin UI.
     if (l_mw_id is null) then
       delete cct_middleware_types
	     where middleware_type_id=p_mw1_id;
     end if;
END;

procedure delete_params(p_mw1_id IN NUMBER,p_mw2_id IN NUMBER, p_mw_id IN NUMBER )
IS
BEGIN
 SAVEPOINT CCT_MIDDLEWARE_DELETE_SAV;

 if (p_mw_id is null) then
   delete from cct_middleware_values where nvl(f_deletedflag,'Y') <> 'D'
   and middleware_param_id IN
   (
   select mw.middleware_param_id
   from cct_middleware_params mw
   where middleware_type_id=p_mw1_id and nvl(mw.f_deletedflag,'Y') <> 'D'

   minus

   select mw1.middleware_param_id
         from cct_middleware_params mw1, cct_middleware_params mw2
         where mw1.middleware_type_id=p_mw1_id and mw2.middleware_type_id=p_mw2_id
         and mw1.name=mw2.name
         and nvl(mw1.f_deletedflag,'Y') <> 'D'
   ) ;
 else
   delete from cct_middleware_values where middleware_id=p_mw_id and  nvl(f_deletedflag,'Y') <> 'D'
   and middleware_param_id IN
   (
   select mw.middleware_param_id
   from cct_middleware_params mw
   where middleware_type_id=p_mw1_id and nvl(mw.f_deletedflag,'Y') <> 'D'

   minus

   select mw1.middleware_param_id
         from cct_middleware_params mw1, cct_middleware_params mw2
         where mw1.middleware_type_id=p_mw1_id and mw2.middleware_type_id=p_mw2_id
         and mw1.name=mw2.name
         and nvl(mw1.f_deletedflag,'Y') <> 'D'

   ) ;
 end if;
EXCEPTION
      WHEN OTHERS THEN
          rollback TO SAVEPOINT CCT_MIDDLEWARE_DELETE_SAV;
          raise_application_error(-20011, sqlerrm || 'Could not delete middlewares')  ;
END;

procedure update_params(p_mw1_id IN NUMBER,p_mw2_id IN NUMBER, p_mw_id IN NUMBER )
IS
    l_mw1_param_id cct_middleware_params.middleware_param_id%type;
    l_mw2_param_id cct_middleware_params.middleware_param_id%type;

    CURSOR c_mw IS
           select mw1.middleware_param_id, mw2.middleware_param_id
           from cct_middleware_params mw1, cct_middleware_params mw2
           where mw1.middleware_type_id=p_mw1_id and mw2.middleware_type_id=p_mw2_id
             and mw1.name=mw2.name
             and nvl(mw1.f_deletedflag,'Y') <> 'D';
   BEGIN
        SAVEPOINT CCT_MIDDLEWARE_UPDATE_SAV;
        OPEN c_mw;
        LOOP
          FETCH c_mw INTO l_mw1_param_id, l_mw2_param_id;
          IF c_mw%NOTFOUND THEN
            CLOSE c_mw;
            exit;
          ELSIF (p_mw_id is null) then
            update cct_middleware_values Set middleware_param_id = l_mw2_param_id
            where middleware_param_id = l_mw1_param_id  and nvl(f_deletedflag,'Y') <> 'D' ;
          ELSE
            update cct_middleware_values Set middleware_param_id = l_mw2_param_id
            where middleware_id=p_mw_id and middleware_param_id = l_mw1_param_id
                   and nvl(f_deletedflag,'Y') <> 'D' ;
          END IF;
       END LOOP;

   EXCEPTION
      WHEN OTHERS THEN
          rollback TO SAVEPOINT CCT_MIDDLEWARE_UPDATE_SAV;
          raise_application_error(-20012, sqlerrm || 'Could not update middlewares')  ;
end;

procedure update_agent_params(p_mw1_id IN NUMBER,p_mw2_id IN NUMBER, p_mw_id IN NUMBER )
IS
    l_mw1_param_id jtf_rs_resource_values.resource_param_id%type;
    l_mw2_param_id jtf_rs_resource_values.resource_param_id%type;

    CURSOR c_mw IS
           select mw1.resource_param_id, mw2.resource_param_id
           from jtf_rs_resource_params mw1, jtf_rs_resource_params mw2
           where mw1.param_type=p_mw1_id and mw2.param_type=p_mw2_id
             and mw1.name=mw2.name;
   BEGIN
        SAVEPOINT CCT_MIDDLEWARE_UPDATE_AGT_SAV;
        OPEN c_mw;
        LOOP
          FETCH c_mw INTO l_mw1_param_id, l_mw2_param_id;
          IF c_mw%NOTFOUND THEN
            CLOSE c_mw;
            exit;
          ELSIF (p_mw_id is null) then
            update jtf_rs_resource_values Set resource_param_id = l_mw2_param_id
            where resource_param_id = l_mw1_param_id  ;
          ELSE
            update jtf_rs_resource_values Set resource_param_id = l_mw2_param_id
            where value_type=p_mw_id and resource_param_id = l_mw1_param_id      ;
          END IF;
       END LOOP;

   EXCEPTION
      WHEN OTHERS THEN
          rollback TO SAVEPOINT CCT_MIDDLEWARE_UPDATE_AGT_SAV;
          raise_application_error(-20012, sqlerrm || 'Could not update agent paras')  ;
end;

END CCT_MIGRATE_MW;

/
