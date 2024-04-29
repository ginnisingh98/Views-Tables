--------------------------------------------------------
--  DDL for Package Body IEC_CUSTOM_RMI_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_CUSTOM_RMI_UTIL_PVT" AS
/* $Header: IECVRMIB.pls 115.8 2003/08/22 20:42:51 hhuang ship $ */

-- Sub-Program Unit Declarations

PROCEDURE ADD_EMPTY_BLOB
  (P_SERVER_ID   IN            NUMBER
  ,P_COMP_DEF_ID IN            NUMBER
  ,X_RESULT         OUT NOCOPY NUMBER
  )
AS

  l_result NUMBER;
  l_flag  NUMBER;
  l_flagb  NUMBER;
  l_comp_name IEO_SVR_COMPS.COMP_NAME%TYPE;

BEGIN

  x_result := NULL;

  IF( ( P_SERVER_ID is null ) OR
      ( P_COMP_DEF_ID is null )
    )
  THEN
    raise_application_error
      ( -20000
       , 'P_SERVER_ID or P_COMP_DEF_ID  cannot be null.'
         || 'Values sent are server id (' || P_SERVER_ID || ')'
         || 'comp def id (' || P_COMP_DEF_ID || ')'
       ,TRUE
      );
   END IF;

   -- dbms_output.put_line('IEC_CUSTOM_RMI_UTIL_PVT: ADD_EMPTY_BLOB:  Done null check..');

   l_result := 0;
   l_flag := 0;
   l_comp_name := '';

   -- Check if server_id and comp_id are valid
   select 1 into l_flag
    from  ieo_svr_servers a,
          ieo_svr_comp_defs b
   where  a.server_id = P_SERVER_ID
     and  b.comp_def_id = P_COMP_DEF_ID
     and  a.type_id = b.server_type_id;

   -- dbms_output.put_line('IEC_CUSTOM_RMI_UTIL_PVT: ADD_EMPTY_BLOB:  Done valid check..');

   IF ( l_flag <> 1 )
   THEN
    raise_application_error
      ( -20000
       , 'Data sent is not valid.'
         || 'Values sent are server id (' || P_SERVER_ID || ')'
         || 'comp def id (' || P_COMP_DEF_ID || ')'
       ,TRUE
      );
   END IF;

   BEGIN
      select 1 into l_flag
        from  ieo_svr_comps
       where  server_id = P_SERVER_ID
         and  comp_def_id = P_COMP_DEF_ID
         and  object_ref is not null;

      IF ( l_flag = 1 )
      THEN
        -- dbms_output.put_line('IEC_CUSTOM_RMI_UTIL_PVT: ADD_EMPTY_BLOB:  ServerID and CompDefId already present in comp table.');
        l_result := l_flag;
      END IF;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
        -- dbms_output.put_line('IEC_CUSTOM_RMI_UTIL_PVT: ADD_EMPTY_BLOB:  Adding empty blob. ');

        select comp_def_name into l_comp_name
          from ieo_svr_comp_defs
         where comp_def_id = P_COMP_DEF_ID;

        -- dbms_output.put_line(' Comp_def_name is <' || l_comp_name || '>');

        insert into IEO_SVR_COMPS
               ( COMP_ID
               , SERVER_ID
               , COMP_DEF_ID
               , COMP_NAME
               , OBJECT_REF
               )
        values ( IEO_SVR_COMPS_S1.NEXTVAL
               , P_SERVER_ID
               , P_COMP_DEF_ID
               , l_comp_name
               , empty_blob()
               );

        l_result := 1;
--        commit;

        -- dbms_output.put_line('IEC_CUSTOM_RMI_UTIL_PVT: ADD_EMPTY_BLOB:  Done insert empty blob');
  END;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END ADD_EMPTY_BLOB;


PROCEDURE BIND
  (P_SERVER_ID   IN            NUMBER
  ,P_COMP_DEF_ID IN            NUMBER
  ,P_OBJECT_REF  IN            BLOB
  ,X_RESULT         OUT NOCOPY NUMBER
  )
  AS
  l_result NUMBER;
  l_data_valid_flag  NUMBER;
  l_comp_name IEO_SVR_COMPS.COMP_NAME%TYPE;
BEGIN

  x_result := NULL;

  IF( ( P_SERVER_ID is null )
    OR( P_COMP_DEF_ID is null )
    OR( P_OBJECT_REF is null ) )
  THEN
    raise_application_error
      ( -20000
       , 'P_SERVER_ID , P_COMP_DEF_ID or P_OBJECT_ID cannot be null.'
         || 'Values sent are server id (' || P_SERVER_ID || ')'
         || 'comp def id (' || P_COMP_DEF_ID || ')'
       ,TRUE
      );
   END IF;

   l_result := 0;
   l_data_valid_flag := 0;
   l_comp_name := '';

   -- Check if server_id and comp_id are valid
   select 1 into l_data_valid_flag
    from  ieo_svr_servers a,
          ieo_svr_comp_defs b
   where  a.server_id = P_SERVER_ID
     and  b.comp_def_id = P_COMP_DEF_ID
     and  a.type_id = b.server_type_id;

   IF ( l_data_valid_flag <> 1 )
   THEN
    raise_application_error
      ( -20000
       , 'Data sent is not valid.'
         || 'Values sent are server id (' || P_SERVER_ID || ')'
         || 'comp def id (' || P_COMP_DEF_ID || ')'
       ,TRUE
      );
   END IF;

   -- Data is valid. update/insert block.
   update IEO_SVR_COMPS
      set OBJECT_REF = P_OBJECT_REF
    where server_id = P_SERVER_ID
      and comp_def_id = P_COMP_DEF_ID;

   IF (SQL%NOTFOUND OR (SQL%ROWCOUNT <= 0))
   THEN


     select comp_def_name into l_comp_name
       from ieo_svr_comp_defs
      where comp_def_id = P_COMP_DEF_ID;

     insert into IEO_SVR_COMPS
            ( COMP_ID
            , SERVER_ID
            , COMP_DEF_ID
            , COMP_NAME
            , OBJECT_REF
            )
     values ( IEO_SVR_COMPS_S1.NEXTVAL
            , P_SERVER_ID
            , P_COMP_DEF_ID
            , l_comp_name
            , empty_blob()
            );

     update IEO_SVR_COMPS
        set OBJECT_REF = P_OBJECT_REF
      where server_id = P_SERVER_ID
        and comp_def_id = P_COMP_DEF_ID;

    END IF;

    l_result := 1;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END BIND;

END IEC_CUSTOM_RMI_UTIL_PVT;

/
