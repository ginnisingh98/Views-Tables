--------------------------------------------------------
--  DDL for Package Body JTF_TTY_GEO_TERRGP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TTY_GEO_TERRGP" AS
/* $Header: jtftggpb.pls 120.6.12010000.2 2010/02/02 11:55:52 rajukum ship $ */
--    Start of Comments
--    PURPOSE
--      For handling Geography Territor Groups, like delete,create,update
--
--    NOTES
--      ORACLE INTERNAL USE ONLY: NOT for customer use
--
--    HISTORY
--      06/02/03    SGKUMAR  Created
--      06/20/03    SGKUMAR  Modified as per new data model
--      06/24/03    SGKUMAR  Added new procedure add_geo_to_grp
--      12/23/03    ACHANDA  Added the log_event procedure and also call to it while deleting TG
--      01/07/04    SGKUMAR  Checking Postal Code ranges by geo name and not id
--      11/09/04    SGKUMAR  Added procedure replace_geo_terr_rsc for 3889970
--      09/22/05    JRADHAKR Added procedure POPULATE_SELF_SRV_SCHEMA to populate
--                           TTY tables for self service geo territories.
--    End of Comments
--    End of Comments
----

/* Procedure to populate the TTY table from TERR tables
   for the self service geo territories */

PROCEDURE POPULATE_SELF_SRV_SCHEMA (p_terr_id IN NUMBER
                                  , x_return_status     OUT NOCOPY VARCHAR2
                                  , x_msg_count         OUT NOCOPY VARCHAR2
                                  , x_msg_data          OUT NOCOPY VARCHAR2)
IS
   l_terr_grp_id NUMBER;
   l_geo_terr_id NUMBER;
   lp_terr_grp_role_id NUMBER;

   L_GEO_GRP_VALUES_ID NUMBER;
   L_GEO_ID_FROM NUMBER;
   L_GEO_ID_TO NUMBER;

   l_return_status      VARCHAR2(2);


   /* Cursor to get the roles defined for the self service geo territories */

   CURSOR csr_get_terr_grp_roles(cr_terr_id IN NUMBER) IS
   select terr_rsc_id
        , resource_id
        , role
        , resource_type
        , creation_date
        , created_by
        , last_update_date
        , last_updated_by
     from jtf_terr_rsc_all
    where terr_id = cr_terr_id
      and resource_type = 'RS_ROLE'; --  Need to Fix before ARCS

   /* Cursor that convert the TERR go values to TTY geo values */

   CURSOR csr_get_terr_grp_values(cr_terr_id IN NUMBER) IS
     select decode(jtq.qual_usg_id, -1007, 'POSTAL_CODE'
          , -1003, 'COUNTRY', -1013, 'PROVINCE', -1011, 'COUNTY'
          , -1008, 'STATE', -1006,'CITY') geo_type
          , jtv.comparison_operator
          , jtv.low_value_char
          , jtv.high_value_char
          , jtq.terr_id
          , jtv.creation_date
          , jtv.created_by
          , jtv.last_update_date
          , jtv.last_updated_by
     from jtf_terr_values_all jtv
         , jtf_terr_qual_all jtq
         , jtf_qual_usgs_all qsg
     where jtv.terr_qual_id = jtq.terr_qual_id
       and jtq.terr_id = cr_terr_id
       and jtq.qual_usg_id = qsg.qual_usg_id
       and jtq.org_id = qsg.org_id
       and qsg.hierarchy_type = 'GEOGRAPHY' ;

BEGIN

  l_return_status      := 'S' ;

  BEGIN
    select geo_territory_id, terr_group_id
      into l_geo_terr_id, l_terr_grp_id
      from jtf_terr_all
     where terr_id = p_terr_id;

  EXCEPTION
     when FND_API.G_EXC_ERROR then
           x_return_status := 'E';
           x_msg_data := substr(sqlerrm, 1, 200) ;
           return;

     when others then
           x_return_status := 'E';
           x_msg_data := substr(sqlerrm, 1, 200) ;
           return;

  END;

  if l_geo_terr_id is not null
  then

    /* following code deletes the data first in case of an update and
      coninue with the create statements */

    delete from  jtf_tty_role_access
    where TERR_GROUP_ROLE_ID in (select TERR_GROUP_ROLE_ID
         from jtf_tty_terr_grp_roles
         where terr_group_id = l_terr_grp_id);

    delete from  jtf_tty_terr_grp_roles where terr_group_id = l_terr_grp_id;

    delete from  jtf_tty_geo_grp_values where terr_group_id = l_terr_grp_id;

    delete from  jtf_tty_terr_groups where terr_group_id = l_terr_grp_id;

    delete from  jtf_tty_geo_terr_rsc where geo_territory_id = l_geo_terr_id;

    delete from  jtf_tty_geo_terr where geo_territory_id = l_geo_terr_id;


  else
    select jtf_tty_terr_groups_s.nextval
      into l_terr_grp_id
      from dual;

    select jtf_tty_geo_terr_s.nextval
      into l_geo_terr_id
      from dual;

  end if;

  BEGIN


    INSERT INTO jtf_tty_terr_groups
     ( TERR_GROUP_ID
    , TERR_GROUP_NAME
    , RANK
    , ACTIVE_FROM_DATE
    , ACTIVE_TO_DATE
    , PARENT_TERR_ID
    , CREATED_BY
    , CREATION_DATE
    , LAST_UPDATED_BY
    , LAST_UPDATE_DATE
    , LAST_UPDATE_LOGIN
    , NUM_WINNERS
    , SELF_SERVICE_TYPE
    , DESCRIPTION
    , OBJECT_VERSION_NUMBER
    )
   select l_terr_grp_id
    , name
    , RANK
    , START_DATE_ACTIVE
    , END_DATE_ACTIVE
    , PARENT_TERRITORY_ID
    , CREATED_BY
    , CREATION_DATE
    , LAST_UPDATED_BY
    , LAST_UPDATE_DATE
    , LAST_UPDATE_LOGIN
    , NUM_WINNERS
    , 'GEOGRAPHY'
    , DESCRIPTION
    , 1
    from jtf_terr_all
    where terr_id = p_terr_id;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
        WHEN OTHERS THEN
           x_return_status := 'E';
           x_msg_data := substr(sqlerrm, 1, 200) ;
          return;

   END;

   BEGIN


   insert into jtf_tty_geo_terr
           (geo_territory_id,
            parent_geo_terr_id,
            child_node_flag,
            geo_terr_name,
            terr_group_id,
            owner_resource_id ,
            owner_rsc_group_id,
            owner_rsc_role_code,
            OBJECT_VERSION_NUMBER,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date)
    select l_geo_terr_id
          ,- l_geo_terr_id
          ,'N'
          ,name
          ,l_terr_grp_id
          ,-999
          ,-999
          ,-999
          ,1
          , CREATED_BY
          , CREATION_DATE
          , LAST_UPDATED_BY
          , LAST_UPDATE_DATE
    from jtf_terr_all
    where terr_id = p_terr_id;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
        WHEN OTHERS THEN
          x_return_status := 'E';
          x_msg_data := substr(sqlerrm, 1, 200) ;
          return;

   END;

   BEGIN

   insert into jtf_tty_geo_terr_rsc
           (geo_terr_resource_id,
            object_version_number,
            geo_territory_id,
            resource_id,
            rsc_group_id,
            rsc_role_code,
            rsc_resource_type,
            assigned_flag,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            LAST_UPDATE_LOGIN)
     SELECT jtf_tty_geo_terr_rsc_s.nextval
       , 1
       , l_geo_terr_id
       , resource_id
       , group_id
       , role
       , resource_type
       , 'N'
       , CREATED_BY
       , CREATION_DATE
       , LAST_UPDATED_BY
       , LAST_UPDATE_DATE
       , LAST_UPDATE_LOGIN
     FROM jtf_terr_rsc_all
     where terr_id = p_terr_id
       and resource_type = 'RS_EMPLOYEE';

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
        WHEN OTHERS THEN
          x_return_status := 'E';
          x_msg_data := substr(sqlerrm, 1, 200) ;
          return;

    END;

    BEGIN

    Insert into jtf_tty_terr_grp_owners
     ( TERR_GROUP_OWNER_ID
       , OBJECT_VERSION_NUMBER
       , TERR_GROUP_ID
       , RSC_GROUP_ID
       , RESOURCE_ID
       , RSC_ROLE_CODE
       , RSC_RESOURCE_TYPE
       , CREATED_BY
       , CREATION_DATE
       , LAST_UPDATED_BY
       , LAST_UPDATE_DATE
       , LAST_UPDATE_LOGIN
      )
     SELECT jtf_tty_terr_grp_owners_s.nextval
       , 1
       , l_terr_grp_id
       , group_id
       , resource_id
       , role
       ,  resource_type
       , CREATED_BY
       , CREATION_DATE
       , LAST_UPDATED_BY
       , LAST_UPDATE_DATE
       , LAST_UPDATE_LOGIN
     FROM jtf_terr_rsc_all
     where terr_id = p_terr_id
        and resource_type = 'RS_EMPLOYEE';

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
        WHEN OTHERS THEN
          x_return_status := 'E';
          x_msg_data := substr(sqlerrm, 1, 200) ;
          return;


    END;

     for get_terr_grp_values in csr_get_terr_grp_values (p_terr_id)
     --
     loop
     --
       BEGIN

       IF get_terr_grp_values.geo_type = 'POSTAL_CODE'
       THEN
         select geo_id
           into L_GEO_ID_FROM
         from jtf_tty_geographies
         where geo_type = get_terr_grp_values.geo_type
         and geo_code = (
             select min(geo_code)
             from jtf_tty_geographies
             where geo_type = get_terr_grp_values.geo_type
             and geo_code >= get_terr_grp_values.low_value_char
             and geo_code <= get_terr_grp_values.high_value_char);

       Begin
         select geo_id
           into L_GEO_ID_TO
         from jtf_tty_geographies
         where geo_type = get_terr_grp_values.geo_type
         and geo_code = (
             select max(geo_code)
             from jtf_tty_geographies
             where geo_type = get_terr_grp_values.geo_type
             and geo_code <= get_terr_grp_values.high_value_char
             and geo_code >= get_terr_grp_values.low_value_char);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
       END;
       ELSE -- not postal code
         select geo_id
           into L_GEO_ID_FROM
         from jtf_tty_geographies
         where geo_type = get_terr_grp_values.geo_type
         and geo_code = get_terr_grp_values.low_value_char
         and rownum < 2;

       Begin
         select geo_id
           into L_GEO_ID_TO
         from jtf_tty_geographies
         where geo_type = get_terr_grp_values.geo_type
         and geo_code = get_terr_grp_values.high_value_char
         and rownum < 2;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
       END;
       END IF;

         select jtf_tty_geo_grp_values_s.nextval
           into L_GEO_GRP_VALUES_ID
         from dual;

         insert into jtf_tty_geo_grp_values (
              GEO_GRP_VALUES_ID
              , OBJECT_VERSION_NUMBER
              , TERR_GROUP_ID
              , COMPARISON_OPERATOR
              , GEO_TYPE
              , GEO_ID_FROM
              , GEO_ID_TO
              , CREATED_BY
              , CREATION_DATE
              , LAST_UPDATED_BY
              , LAST_UPDATE_DATE )
              VALUES
              (
                L_GEO_GRP_VALUES_ID
              , 1
              , l_terr_grp_id
              , get_terr_grp_values.comparison_operator
              , get_terr_grp_values.geo_type
              , L_GEO_ID_FROM
              , L_GEO_ID_TO
              , get_terr_grp_values.CREATED_BY
              , get_terr_grp_values.CREATION_DATE
              , get_terr_grp_values.LAST_UPDATED_BY
              , get_terr_grp_values.LAST_UPDATE_DATE
              );

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
          x_return_status := 'E';

          FND_MESSAGE.Set_Name('JTF', 'JTF_TTY_NO_GEO_VALUES');
          FND_MSG_PUB.Add;
          FND_MSG_PUB.Count_And_Get
               (   p_count           =>      x_msg_count,
                   p_data            =>      x_msg_data
               );
          return;

          WHEN OTHERS THEN
          x_return_status := 'E';
          x_msg_data := substr(sqlerrm, 1, 200) ;
          return;

       END;

     end loop;

     for get_terr_grp_roles in csr_get_terr_grp_roles (p_terr_id)
       --
       loop
       --
       select jtf_tty_terr_grp_roles_s.nextval
         into lp_terr_grp_role_id
       from dual;
       --
       BEGIN

         insert into jtf_tty_terr_grp_roles (
         TERR_GROUP_ROLE_ID
         ,TERR_GROUP_ID
         ,ROLE_CODE
         ,OBJECT_VERSION_NUMBER
         ,CREATED_BY
         ,CREATION_DATE
         ,LAST_UPDATED_BY
         ,LAST_UPDATE_DATE)
         values(
             lp_terr_grp_role_id
            ,l_terr_grp_id
            ,get_terr_grp_roles.ROLE
            , 1
            ,get_terr_grp_roles.CREATED_BY
            ,get_terr_grp_roles.creation_date
            ,get_terr_grp_roles.LAST_UPDATED_BY
            ,get_terr_grp_roles.LAST_UPDATE_DATE);

         EXCEPTION
             WHEN NO_DATA_FOUND THEN
               NULL;
             WHEN OTHERS THEN
             x_return_status := 'E';
             x_msg_data := substr(sqlerrm, 1, 200) ;
             return;

       END;
       --
       BEGIN
         --
       insert into jtf_tty_role_access (
         TERR_GROUP_ROLE_ACCESS_ID
         ,TERR_GROUP_ROLE_ID
         ,ACCESS_TYPE
         ,OBJECT_VERSION_NUMBER
         ,CREATED_BY
         ,CREATION_DATE
         ,LAST_UPDATED_BY
         ,LAST_UPDATE_DATE
         ,TRANS_ACCESS_CODE)
         select
           jtf_tty_role_access_s.nextval
           ,lp_terr_grp_role_id
           ,ACCESS_TYPE
           , 1
           ,CREATED_BY
           ,CREATION_DATE
           ,LAST_UPDATED_BY
           ,LAST_UPDATE_DATE
           ,trans_access_code
         from jtf_terr_rsc_access_all
         where terr_rsc_id = get_terr_grp_roles.terr_rsc_id;

         EXCEPTION
             WHEN NO_DATA_FOUND THEN
               NULL;
             WHEN OTHERS THEN
             x_return_status := 'E';
             x_msg_data := substr(sqlerrm, 1, 200) ;
             return;

       END;

       --
    end loop;
    --
    commit;

    BEGIN
       --
       update jtf_terr_all
          set terr_group_id = l_terr_grp_id
            , terr_group_flag = 'Y'
            , catch_all_flag = 'N'
            , geo_territory_id = l_geo_terr_id
         where terr_id = p_terr_id;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
        WHEN OTHERS THEN
             x_return_status := 'E';
             x_msg_data := substr(sqlerrm, 1, 200) ;
             return;

    END;

   commit;
    x_return_status := 'S';

EXCEPTION
   when FND_API.G_EXC_ERROR then

             x_return_status := 'E';
             x_msg_data := substr(sqlerrm, 1, 200) ;
             return;

   when others then
             x_return_status := 'E';
             x_msg_data := substr(sqlerrm, 1, 200) ;
             return;

END POPULATE_SELF_SRV_SCHEMA;


PROCEDURE log_event(p_object_id IN NUMBER,
                    p_action_type IN VARCHAR2,
                    p_from_where IN VARCHAR2,
                    p_object_type IN VARCHAR2,
                    p_user_id in NUMBER)
IS
BEGIN
  INSERT INTO JTF_TTY_NAMED_ACCT_CHANGES(
              NAMED_ACCT_CHANGE_ID,
              OBJECT_VERSION_NUMBER,
              OBJECT_TYPE,
              OBJECT_ID,
              CHANGE_TYPE,
              FROM_WHERE,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_DATE
   )
  VALUES(JTF_TTY_NAMED_ACCT_CHANGES_S.nextval,
         1,
         p_object_type,
         p_object_id,
         p_action_type,
         p_from_where,
         p_user_id,
         sysdate,
         p_user_id,
         sysdate);

END log_event;

PROCEDURE delete_terrgp(p_terr_gp_id IN NUMBER)
AS
 p_user_id NUMBER;
BEGIN

 /* delete the geos or postal code belonging to the geo territores of this
 /* geo territory group */

  DELETE from JTF_TTY_GEO_TERR_VALUES
  WHERE  geo_territory_id IN
         (SELECT t.geo_territory_id
          FROM   jtf_tty_geo_terr t
          WHERE  t.terr_group_id = p_terr_gp_id);

 /* delete all the geo territories assignments for the geo terr group */

  DELETE from JTF_TTY_GEO_TERR_RSC
  WHERE  geo_territory_id IN
         (SELECT t.geo_territory_id
          FROM   jtf_tty_geo_terr t
          WHERE  t.terr_group_id = p_terr_gp_id);

  DELETE from JTF_TTY_GEO_TERR
  WHERE  terr_group_id = p_terr_gp_id;

 /* delete all the geographies for the geo terr group */

  DELETE from JTF_TTY_GEO_GRP_VALUES
  WHERE  terr_group_id = p_terr_gp_id;


 /* delete all the terr gp owners, access and product */
  delete from jtf_tty_terr_grp_owners
  where terr_group_id = p_terr_gp_id;

  delete from jtf_tty_role_prod_int
  where terr_group_role_id in
      (select terr_group_role_id from jtf_tty_terr_grp_roles
       where terr_group_id = p_terr_gp_id);


  delete from jtf_tty_role_access
  where terr_group_role_id in
      (select terr_group_role_id from jtf_tty_terr_grp_roles
       where terr_group_id = p_terr_gp_id);

  delete from jtf_tty_terr_grp_roles
  where terr_group_id = p_terr_gp_id;

  /* finally delete the terr gp itself */

  delete from jtf_tty_terr_groups
  where terr_group_id = p_terr_gp_id;

  /* ACHANDA : added to log the event of territory group delete for GTP to do incremental process */
  log_event(p_terr_gp_id, 'DELETE', 'Delete Territory Group', 'TG', fnd_global.user_id);
  commit;
END delete_terrgp;
/*
* Adds the geography to the geo terr group
* Invoked during create or update of geo terr group
*/
PROCEDURE delete_geo_from_grp(p_terr_gp_id IN NUMBER)
AS
BEGIN
    DELETE from jtf_tty_geo_grp_values
    where TERR_GROUP_ID = p_terr_gp_id;

    COMMIT;
END delete_geo_from_grp;
/*
* Adds the geography to the geo terr group
* Invoked during create or update of geo terr group
*/
PROCEDURE add_geo_to_grp(p_terr_gp_id IN NUMBER,
                         p_geo_id_from IN NUMBER,
                         p_geo_id_to IN NUMBER,
                         p_operator IN VARCHAR2,
                         p_geo_type IN VARCHAR2,
                         p_user_id   IN NUMBER)
AS
BEGIN

    INSERT into jtf_tty_geo_grp_values(
              GEO_GRP_VALUES_ID,
              OBJECT_VERSION_NUMBER,
              TERR_GROUP_ID,
              COMPARISON_OPERATOR,
              GEO_TYPE,
              GEO_ID_FROM,
              GEO_ID_TO,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATED_BY,
              last_update_date)
    VALUES(
              jtf_tty_geo_grp_values_s.nextval,
              1,
              p_terr_gp_id,
              p_operator,
              p_geo_type,
              p_geo_id_from,
              p_geo_id_to,
              p_user_id,
              sysdate,
              p_user_id,
              sysdate);

    COMMIT;
END add_geo_to_grp;
/*
* create a top level geo territory for the geo terr group
* and assigns it to the owners of the geo terr group
* Invoked during create geo terr group
*/
PROCEDURE create_grp_geo_terr(p_terr_gp_id IN NUMBER,
                             p_user_id   IN NUMBER)
AS
 p_geo_territory_id NUMBER;
 p_geo_territory_name VARCHAR2(80);
 p_territory_label VARCHAR2(80);
BEGIN
   SELECT jtf_tty_geo_terr_s.nextval, terr_group_name
   INTO p_geo_territory_id, p_geo_territory_name
   FROM jtf_tty_terr_groups
   WHERE terr_group_id = p_terr_gp_id;
 /*
   fnd_message.set_name('JTF', 'JTF_TTY_TERR_LABEL');
   p_territory_label := fnd_message.Get();
*/
   /* create a top-level geo territory */
   insert into jtf_tty_geo_terr
           (geo_territory_id,
            parent_geo_terr_id,
            object_version_number,
            child_node_flag,
            geo_terr_name,
            terr_group_id,
            owner_resource_id ,
            owner_rsc_group_id,
            owner_rsc_role_code,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date)
 values(  p_geo_territory_id,
          - p_geo_territory_id,
          1,
          'N',
          p_geo_territory_name,
          p_terr_gp_id,
          -999,
          -999,
          -999,
          p_user_id,
          sysdate,
          p_user_id,
          sysdate);
   /* Assign the top level territory to all the geo terr gp owners */
   insert into jtf_tty_geo_terr_rsc
           (geo_terr_resource_id,
            object_version_number,
            geo_territory_id,
            resource_id,
            rsc_group_id,
            rsc_role_code,
            assigned_flag,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date)
     SELECT jtf_tty_geo_terr_rsc_s.nextval,
       1,
       p_geo_territory_id,
       tgo.resource_id,
       tgo.rsc_group_id,
       tgo.rsc_role_code,
       'N',
       p_user_id,
       sysdate,
       p_user_id,
       sysdate
     FROM jtf_tty_terr_grp_owners tgo
     WHERE tgo.terr_group_id = p_terr_gp_id;

    COMMIT;
END create_grp_geo_terr;
/*
* Deletes the removed geographies from all the geo territories
* belong to this geo terr group
*/
PROCEDURE delete_geos_from_terrs(p_terr_gp_id IN NUMBER)
AS
BEGIN
 DELETE from JTF_TTY_GEO_TERR_VALUES gtv
 WHERE  gtv.geo_territory_id IN
        (SELECT geo_territory_id FROM jtf_tty_geo_terr
         where  terr_group_id = p_terr_gp_id)
 AND    gtv.geo_id NOT IN
        (SELECT g.geo_id FROM jtf_tty_geographies g, jtf_tty_geo_grp_values ggv,                jtf_tty_geographies g1
         WHERE  ggv.terr_group_id = p_terr_gp_id
         AND    ggv.geo_type = 'COUNTRY'
         AND    ggv.geo_id_from = g1.geo_id
         AND    g.geo_type = 'POSTAL_CODE'
         AND    g.country_code = g1.country_code
         UNION
         SELECT g.geo_id FROM jtf_tty_geographies g, jtf_tty_geo_grp_values ggv,                jtf_tty_geographies g1
         WHERE  ggv.terr_group_id = p_terr_gp_id
         AND    ggv.geo_type = 'STATE'
         AND    ggv.geo_id_from = g1.geo_id
         AND    g.geo_type = 'POSTAL_CODE'
         AND    g.country_code = g1.country_code
         AND    g.state_code = g1.state_code
         UNION
         SELECT g.geo_id FROM jtf_tty_geographies g, jtf_tty_geo_grp_values ggv,                jtf_tty_geographies g1
         WHERE  ggv.terr_group_id = p_terr_gp_id
         AND    ggv.geo_type = 'PROVINCE'
         AND    ggv.geo_id_from = g1.geo_id
         AND    g.geo_type = 'POSTAL_CODE'
         AND    g.country_code = g1.country_code
         AND    g.province_code = g1.province_code
         UNION
         SELECT g.geo_id FROM jtf_tty_geographies g, jtf_tty_geo_grp_values ggv,                jtf_tty_geographies g1
         WHERE  ggv.terr_group_id = p_terr_gp_id
         AND    ggv.geo_type = 'CITY'
         AND    ggv.geo_id_from = g1.geo_id
         AND    g.geo_type = 'POSTAL_CODE'
         AND    g.country_code = g1.country_code
         AND   ((g.state_code = g1.state_code AND g1.province_code is null)
                 or
                 (g1.province_code = g.province_code AND g1.state_code is null))
         AND    (g1.county_code is null or g.county_code = g1.county_code)
         AND    g.city_code = g1.city_code
         UNION
         SELECT ggv.geo_id_from FROM jtf_tty_geo_grp_values ggv
         WHERE  ggv.terr_group_id = p_terr_gp_id
         AND    ggv.geo_type = 'POSTAL_CODE'
         AND    ggv.comparison_operator = '='
         UNION
         SELECT g.geo_id
         FROM jtf_tty_geographies g,
              jtf_tty_geo_grp_values ggv,
              jtf_tty_geographies g1,
              jtf_tty_geographies g2
         WHERE  ggv.terr_group_id = p_terr_gp_id
         AND    ggv.geo_type = 'POSTAL_CODE'
         AND    ggv.comparison_operator = 'BETWEEN'
         AND    g1.geo_id = ggv.geo_id_from
         AND    g2.geo_id =  ggv.geo_id_to
         AND    g.geo_name BETWEEN g1.geo_name and g2.geo_name);

  commit;


END delete_geos_from_terrs;
/*
* Updates the geo terr assinments for removed and added owners
* of a geo territory group, invoked only for update geo terr group
* and if owners are updated
*/
PROCEDURE update_geo_grp_assignments (p_terr_gp_id IN NUMBER)
AS
 CURSOR removed_owners_c IS
 SELECT gtr.resource_id,
        gtr.rsc_group_id,
        gtr.rsc_role_code,
        gtr.geo_territory_id
 FROM   jtf_tty_geo_terr_rsc gtr,
        jtf_tty_geo_terr gt
 WHERE  gt.terr_group_id = p_terr_gp_id
 AND    gt.geo_territory_id = gtr.geo_territory_id
 AND    gt.owner_resource_id = -999
 AND    gtr.rsc_group_id
 NOT IN (SELECT  tgo.rsc_group_id
         FROM jtf_tty_terr_grp_owners tgo
         WHERE tgo.terr_group_id = p_terr_gp_id);

CURSOR replaced_owners_c IS
SELECT  tgo1.resource_id new_owner_resource_id,
        gtr.rsc_group_id,
        gtr.rsc_role_code,
        gtr.geo_territory_id,
        gtr.resource_id replaced_owner_resource_id
 FROM   jtf_tty_geo_terr_rsc gtr,
        jtf_tty_geo_terr gt,
        jtf_tty_terr_grp_owners tgo1
 WHERE  gt.terr_group_id = p_terr_gp_id
 AND    gt.geo_territory_id = gtr.geo_territory_id
 AND    gt.owner_resource_id = -999
 and    tgo1.terr_group_id = p_terr_gp_id
 and    tgo1.rsc_group_id  = gtr.rsc_group_id
 and    gtr.resource_id <> tgo1.resource_id;

 CURSOR added_owners_c IS
 SELECT tgo.resource_id,
        tgo.rsc_group_id,
        tgo.rsc_role_code,
        gt.geo_territory_id
 FROM   JTF_TTY_TERR_GRP_OWNERS tgo,
        jtf_tty_geo_terr gt
 WHERE  gt.terr_group_id = p_terr_gp_id
 AND    tgo.terr_group_id = p_terr_gp_id
 AND    gt.owner_resource_id = -999
 AND    (tgo.resource_id, tgo.rsc_group_id, tgo.rsc_role_code)
 NOT IN (SELECT  gtr.resource_id, gtr.rsc_group_id, gtr.rsc_role_code
         FROM  jtf_tty_geo_terr_rsc gtr
         WHERE gt.geo_territory_id = gtr.geo_territory_id);
BEGIN
 for removed_owners IN  removed_owners_c LOOP
     delete_geo_terr_rsc(removed_owners.geo_territory_id,
                         removed_owners.resource_id,
                         removed_owners.rsc_group_id,
                         removed_owners.rsc_role_code);
 END LOOP;
 for added_owners IN  added_owners_c LOOP
     assign_geo_terr(added_owners.geo_territory_id,
                         added_owners.resource_id,
                         added_owners.rsc_group_id,
                         added_owners.rsc_role_code);
 END LOOP;
 for replaced_owners IN  replaced_owners_c LOOP
     replace_geo_terr_rsc(replaced_owners.geo_territory_id,
                         replaced_owners.new_owner_resource_id,
                         replaced_owners.rsc_group_id,
                         replaced_owners.rsc_role_code,
                         replaced_owners.replaced_owner_resource_id);
 END LOOP;



END update_geo_grp_assignments;
/*
* delete the geo terr assignments for removed owner/Sales Rep
* for the given geo territory and all the children geo territories
*/
PROCEDURE delete_geo_terr_rsc (p_territory_id IN NUMBER,
                               p_resource_id IN NUMBER,
                               p_rsc_group_id IN NUMBER,
                               p_rsc_role_code IN VARCHAR2)
AS
BEGIN
  /* Delete goes for the geo terrs assigned by the given resource and down
  *  from the given territory */
  DELETE from JTF_TTY_GEO_TERR_VALUES gtv
  WHERE  gtv.geo_territory_id IN
         (SELECT gt.geo_territory_id
          FROM   JTF_TTY_GEO_TERR gt
          START  WITH gt.geo_territory_id IN
                (SELECT gt1.geo_territory_id
                 FROM   JTF_TTY_GEO_TERR gt1
                 WHERE  gt1.owner_resource_id = p_resource_id
                 AND    gt1.owner_rsc_group_id = p_rsc_group_id
                 AND    gt1.owner_rsc_role_code = p_rsc_role_code
                 AND    gt1.parent_geo_terr_id = p_territory_id)
          CONNECT BY PRIOR gt.geo_territory_id = gt.parent_geo_terr_id);
  /* Delete goes for the geo terrs created by the given resource
  *  from the given territory */
  DELETE from JTF_TTY_GEO_TERR_VALUES gtv
  WHERE  gtv.geo_territory_id IN
         (SELECT gt1.geo_territory_id
          FROM   JTF_TTY_GEO_TERR gt1
          WHERE  gt1.owner_resource_id = p_resource_id
          AND    gt1.owner_rsc_group_id = p_rsc_group_id
          AND    gt1.owner_rsc_role_code = p_rsc_role_code
          AND    gt1.parent_geo_terr_id = p_territory_id);

  /* Delete for the geo terrs assignments by the given resource and down
  *  from the given territory */
  DELETE from JTF_TTY_GEO_TERR_RSC gtr
  WHERE  gtr.geo_territory_id IN
         (SELECT gt.geo_territory_id
          FROM   JTF_TTY_GEO_TERR gt
          START  WITH gt.geo_territory_id IN
                (SELECT gt1.geo_territory_id
                 FROM   JTF_TTY_GEO_TERR gt1
                 WHERE  gt1.owner_resource_id = p_resource_id
                 AND    gt1.owner_rsc_group_id = p_rsc_group_id
                 AND    gt1.owner_rsc_role_code = p_rsc_role_code
                 AND    gt1.parent_geo_terr_id = p_territory_id)
          CONNECT BY PRIOR gt.geo_territory_id = gt.parent_geo_terr_id);
  /* Delete geo terrs assignments created by the given resource
  *  from the given territory */
  DELETE from JTF_TTY_GEO_TERR_RSC gtr
  WHERE  gtr.geo_territory_id IN
         (SELECT gt1.geo_territory_id
          FROM   JTF_TTY_GEO_TERR gt1
          WHERE  gt1.owner_resource_id = p_resource_id
          AND    gt1.owner_rsc_group_id = p_rsc_group_id
          AND    gt1.owner_rsc_role_code = p_rsc_role_code
          AND    gt1.parent_geo_terr_id = p_territory_id);
  DELETE from JTF_TTY_GEO_TERR_RSC gtr
  WHERE  gtr.geo_territory_id = p_territory_id
  AND    gtr.resource_id = p_resource_id
  AND    gtr.rsc_group_id = p_rsc_group_id
  AND    gtr.rsc_role_code = p_rsc_role_code;

  /* Now delete the geo territories down */
  /* first delete the geo territories created by the resource's
  * directs from the given territory */
  DELETE from jtf_tty_geo_terr t
  WHERE  t.geo_territory_id IN
         (SELECT gt.geo_territory_id
          FROM   JTF_TTY_GEO_TERR gt
          START  WITH gt.geo_territory_id IN
                (SELECT gt1.geo_territory_id
                 FROM   JTF_TTY_GEO_TERR gt1
                 WHERE  gt1.owner_resource_id = p_resource_id
                 AND    gt1.owner_rsc_group_id = p_rsc_group_id
                 AND    gt1.owner_rsc_role_code = p_rsc_role_code
                 AND    gt1.parent_geo_terr_id = p_territory_id)
          CONNECT BY PRIOR gt.geo_territory_id = gt.parent_geo_terr_id);

  /* now delete the geo territories created by the given resource and
  * from the given territory */
  DELETE from jtf_tty_geo_terr t
  WHERE  t.owner_resource_id = p_resource_id
  AND    t.owner_rsc_group_id = p_rsc_group_id
  AND    t.owner_rsc_role_code = p_rsc_role_code
  AND    t.parent_geo_terr_id = p_territory_id;

  commit;
END delete_geo_terr_rsc;
/*
* delete the geo terr assignments for removed owner/Sales Rep
* for the given geo territory and all the children geo territories
*/
PROCEDURE assign_geo_terr(p_territory_id IN NUMBER,
                               p_resource_id IN NUMBER,
                               p_rsc_group_id IN NUMBER,
                               p_rsc_role_code IN VARCHAR2)
AS
  p_user_id NUMBER;
BEGIN
   p_user_id := fnd_global.user_id;

  /* Assign the top level territory to the geo terr gp owner/sales rep */
   insert into jtf_tty_geo_terr_rsc
           (geo_terr_resource_id,
            object_version_number,
            geo_territory_id,
            resource_id,
            rsc_group_id,
            rsc_role_code,
            assigned_flag,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date)
     VALUES(jtf_tty_geo_terr_rsc_s.nextval,
       1,
       p_territory_id,
       p_resource_id,
       p_rsc_group_id,
       p_rsc_role_code,
       'N',
       p_user_id,
       sysdate,
       p_user_id,
       sysdate);

 COMMIT;
END assign_geo_terr;
/**
* replace the geo terr assignments for removed owner/Sales Rep
* for the given geo territory and all the children geo territories
*/
PROCEDURE replace_geo_terr_rsc(p_territory_id IN NUMBER,
                               p_new_owner_resource_id IN NUMBER,
                               p_rsc_group_id IN NUMBER,
                               p_rsc_role_code IN VARCHAR2,
                               p_replaced_owner_resource_id IN NUMBER)
AS
  p_user_id NUMBER;
BEGIN
   p_user_id := fnd_global.user_id;
   -- change the owner of all the territories created by replaced owner
   -- from this territory (as a parent)

   update jtf_tty_geo_terr
   set owner_resource_id = p_new_owner_resource_id,
       owner_rsc_group_id = p_rsc_group_id,
       owner_rsc_role_code = p_rsc_role_code
   where parent_geo_terr_id = p_territory_id
   and owner_resource_id = p_replaced_owner_resource_id;

  -- delete the replaced owner from geo terr assignment
  -- the territory is assigned to the new owner by assign geo terr api
  DELETE from JTF_TTY_GEO_TERR_RSC gtr
  WHERE  gtr.geo_territory_id = p_territory_id
  AND    gtr.resource_id = p_replaced_owner_resource_id
  AND    gtr.rsc_group_id = p_rsc_group_id
  AND    gtr.rsc_role_code = p_rsc_role_code;
 COMMIT;
END replace_geo_terr_rsc;

end JTF_TTY_GEO_TERRGP;

/
