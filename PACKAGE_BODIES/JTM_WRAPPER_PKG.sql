--------------------------------------------------------
--  DDL for Package Body JTM_WRAPPER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTM_WRAPPER_PKG" AS
/* $Header: jtmwrppb.pls 120.1 2005/08/24 02:21:12 saradhak noship $ */

FUNCTION CREATE_ENTRY(p_LangCode IN VARCHAR2, p_nls_language IN VARCHAR2) RETURN VARCHAR2;
PROCEDURE Init_Olite_All_Entries;

TYPE Olite_Entry_Type IS RECORD(
      Lang_Code         VARCHAR2(30),
      Bundle_ID         VARCHAR2(30),
      Bundle_Name       VARCHAR2(300),
      Bundle_Link       VARCHAR2(2000)
);

TYPE Olite_Entry_Table_Type IS TABLE of Olite_Entry_Type;

G_Entry_Table Olite_Entry_Table_Type := Olite_Entry_Table_Type();

PROCEDURE Init_Olite_All_Entries is
   lang_code   VARCHAR2(200);
   bundle_name VARCHAR2(100);
BEGIN
   lang_code   := 'US';
   bundle_name := 'Mobile Client for Laptop';
  if (G_Entry_Table.count = 0) then

      G_Entry_Table.extend(18);
      lang_code := 'US';
      G_Entry_Table(1).Lang_Code := lang_code;
      G_Entry_Table(1).Bundle_ID := 'JTM_' || lang_code;
      G_Entry_Table(1).Bundle_Name := bundle_name;
      G_Entry_Table(1).Bundle_Link := 'Please click ' ||
            ' <A HREF="/webtogo/setup/setup.exe">here</A> to download ';
      lang_code := 'PTB';
      G_Entry_Table(2).Lang_Code := lang_code;
      G_Entry_Table(2).Bundle_ID := 'JTM_' || lang_code;
      G_Entry_Table(2).Bundle_Name := bundle_name;
      G_Entry_Table(2).Bundle_Link := 'Please click ' ||
            ' <A HREF="/webtogo/setup/setup.exe">here</A> to download ';
      lang_code := 'FRC';
      G_Entry_Table(3).Lang_Code := lang_code;
      G_Entry_Table(3).Bundle_ID := 'JTM_' || lang_code;
      G_Entry_Table(3).Bundle_Name := bundle_name;
      G_Entry_Table(3).Bundle_Link := 'Please click ' ||
            ' <A HREF="/webtogo/setup/setup.exe">here</A> to download ';
      lang_code := 'DK';
      G_Entry_Table(4).Lang_Code := lang_code;
      G_Entry_Table(4).Bundle_ID := 'JTM_' || lang_code;
      G_Entry_Table(4).Bundle_Name := bundle_name;
      G_Entry_Table(4).Bundle_Link := 'Please click ' ||
            ' <A HREF="/webtogo/setup/setup.exe">here</A> to download ';
      lang_code := 'NL';
      G_Entry_Table(5).Lang_Code := lang_code;
      G_Entry_Table(5).Bundle_ID := 'JTM_' || lang_code;
      G_Entry_Table(5).Bundle_Name := bundle_name;
      G_Entry_Table(5).Bundle_Link := 'Please click ' ||
            ' <A HREF="/webtogo/setup/setup.exe">here</A> to download ';
      lang_code := 'SF';
      G_Entry_Table(6).Lang_Code := lang_code;
      G_Entry_Table(6).Bundle_ID := 'JTM_' || lang_code;
      G_Entry_Table(6).Bundle_Name := bundle_name;
      G_Entry_Table(6).Bundle_Link := 'Please click ' ||
            ' <A HREF="/webtogo/setup/setup.exe">here</A> to download ';
      lang_code := 'FR';
      G_Entry_Table(7).Lang_Code := lang_code;
      G_Entry_Table(7).Bundle_ID := 'JTM_' || lang_code;
      G_Entry_Table(7).Bundle_Name := bundle_name;
      G_Entry_Table(7).Bundle_Link := 'Please click ' ||
            ' <A HREF="/webtogo/setup/setup.exe">here</A> to download ';
      lang_code := 'DE';
      G_Entry_Table(8).Lang_Code := lang_code;
      G_Entry_Table(8).Bundle_ID := 'JTM_' || lang_code;
      G_Entry_Table(8).Bundle_Name := bundle_name;
      G_Entry_Table(8).Bundle_Link := 'Please click ' ||
            ' <A HREF="/webtogo/setup/setup.exe">here</A> to download ';
      lang_code := 'IT';
      G_Entry_Table(9).Lang_Code := lang_code;
      G_Entry_Table(9).Bundle_ID := 'JTM_' || lang_code;
      G_Entry_Table(9).Bundle_Name := bundle_name;
      G_Entry_Table(9).Bundle_Link := 'Please click ' ||
            ' <A HREF="/webtogo/setup/setup.exe">here</A> to download ';
      lang_code := 'JA';
      G_Entry_Table(10).Lang_Code := lang_code;
      G_Entry_Table(10).Bundle_ID := 'JTM_' || lang_code;
      G_Entry_Table(10).Bundle_Name := bundle_name;
      G_Entry_Table(10).Bundle_Link := 'Please click ' ||
            ' <A HREF="/webtogo/setup/setup.exe">here</A> to download ';
      lang_code := 'KO';
      G_Entry_Table(11).Lang_Code := lang_code;
      G_Entry_Table(11).Bundle_ID := 'JTM_' || lang_code;
      G_Entry_Table(11).Bundle_Name := bundle_name;
      G_Entry_Table(11).Bundle_Link := 'Please click ' ||
            ' <A HREF="/webtogo/setup/setup.exe">here</A> to download ';
      lang_code := 'ESA';
      G_Entry_Table(12).Lang_Code := lang_code;
      G_Entry_Table(12).Bundle_ID := 'JTM_' || lang_code;
      G_Entry_Table(12).Bundle_Name := bundle_name;
      G_Entry_Table(12).Bundle_Link := 'Please click ' ||
            ' <A HREF="/webtogo/setup/setup.exe">here</A> to download ';
      lang_code := 'N';
      G_Entry_Table(13).Lang_Code := lang_code;
      G_Entry_Table(13).Bundle_ID := 'JTM_' || lang_code;
      G_Entry_Table(13).Bundle_Name := bundle_name;
      G_Entry_Table(13).Bundle_Link := 'Please click ' ||
            ' <A HREF="/webtogo/setup/setup.exe">here</A> to download ';
      lang_code := 'PT';
      G_Entry_Table(14).Lang_Code := lang_code;
      G_Entry_Table(14).Bundle_ID := 'JTM_' || lang_code;
      G_Entry_Table(14).Bundle_Name := bundle_name;
      G_Entry_Table(14).Bundle_Link := 'Please click ' ||
            ' <A HREF="/webtogo/setup/setup.exe">here</A> to download ';
      lang_code := 'ZHS';
      G_Entry_Table(15).Lang_Code := lang_code;
      G_Entry_Table(15).Bundle_ID := 'JTM_' || lang_code;
      G_Entry_Table(15).Bundle_Name := bundle_name;
      G_Entry_Table(15).Bundle_Link := 'Please click ' ||
            ' <A HREF="/webtogo/setup/setup.exe">here</A> to download ';
      lang_code := 'E';
      G_Entry_Table(16).Lang_Code := lang_code;
      G_Entry_Table(16).Bundle_ID := 'JTM_' || lang_code;
      G_Entry_Table(16).Bundle_Name := bundle_name;
      G_Entry_Table(16).Bundle_Link := 'Please click ' ||
            ' <A HREF="/webtogo/setup/setup.exe">here</A> to download ';
      lang_code := 'S';
      G_Entry_Table(17).Lang_Code := lang_code;
      G_Entry_Table(17).Bundle_ID := 'JTM_' || lang_code;
      G_Entry_Table(17).Bundle_Name := bundle_name;
      G_Entry_Table(17).Bundle_Link := 'Please click ' ||
            ' <A HREF="/webtogo/setup/setup.exe">here</A> to download ';
      lang_code := 'ZHT';
      G_Entry_Table(18).Lang_Code := lang_code;
      G_Entry_Table(18).Bundle_ID := 'JTM_' || lang_code;
      G_Entry_Table(18).Bundle_Name := bundle_name;
      G_Entry_Table(18).Bundle_Link := 'Please click ' ||
            ' <A HREF="/webtogo/setup/setup.exe">here</A> to download ';
   end if;

END Init_Olite_All_Entries;

FUNCTION CREATE_ENTRY(p_LangCode VARCHAR2, p_nls_language IN VARCHAR2) RETURN VARCHAR2 IS
   l_count          NUMBER;
   l_return_val varchar2(30);
   l_execute_status number;
   l_cursorid  INTEGER;
   l_query_statement varchar2(300);
   l_execute_statement varchar2(300);
BEGIN
   l_count := -1;
   l_return_val := 'Y';
   l_query_statement := 'SELECT count(*) FROM mobileadmin.BUNDLES WHERE BUNDLE_ID = :1 ';
   l_execute_statement := ' begin ' ||
         'mobileadmin.setup.addBundle(:1,:2,:3); ' ||
         'mobileadmin.setup.targetBundle(:3,:4); ' ||
         'mobileadmin.setup.targetBundle(:3,:5); ' ||
         ' end; ';
  Init_Olite_All_Entries;

  FOR i in G_Entry_Table.first..G_Entry_Table.last LOOP
      if (G_Entry_Table(i).Lang_Code = p_LangCode) then
          EXECUTE IMMEDIATE l_query_statement
             INTO l_count USING G_Entry_Table(i).Bundle_ID;
          IF l_count = 0 THEN

             l_cursorid := DBMS_SQL.open_cursor;
             DBMS_SQL.parse (l_cursorid, l_execute_statement, DBMS_SQL.v7);
             DBMS_SQL.bind_variable (l_cursorid, ':1',
               G_Entry_Table(i).Bundle_Name || p_nls_language);
             DBMS_SQL.bind_variable (l_cursorid, ':2', G_Entry_Table(i).Bundle_Link);
             DBMS_SQL.bind_variable (l_cursorid, ':3', G_Entry_Table(i).Bundle_ID);
             DBMS_SQL.bind_variable (l_cursorid, ':4', 'WinNT');
             DBMS_SQL.bind_variable (l_cursorid, ':5', 'Win9x');

             begin
                l_execute_status := DBMS_SQL.execute (l_cursorid);
             exception
                when others then
                    l_return_val := 'N';
             end;
             DBMS_SQL.close_cursor (l_cursorid);
          END IF;
          Exit;
      END IF;
   END LOOP;

   RETURN l_return_val;
EXCEPTION
   WHEN OTHERS THEN
        RETURN 'N';
END CREATE_ENTRY;



PROCEDURE INSERT_RESOURCE_RECORD( P_RESOURCE_ID IN NUMBER )
IS
BEGIN
  /*** Insert current user's resource record ***/
  JTM_HOOK_UTIL_PKG.Insert_Acc
  ( P_PUBLICATION_ITEM_NAMES => JTM_HOOK_UTIL_PKG.t_publication_item_list('JTF_RS_RESOURCE_EXTNS')
   ,P_ACC_TABLE_NAME         => 'JTM_JTF_RS_RESOURCE_EXTNS_ACC'
   ,P_PK1_NAME               => 'RESOURCE_PK'
   ,P_PK1_NUM_VALUE          => P_RESOURCE_ID
   ,P_RESOURCE_ID            => P_RESOURCE_ID
   );
END INSERT_RESOURCE_RECORD;

PROCEDURE DELETE_RESOURCE_RECORD( P_RESOURCE_ID IN NUMBER )
IS
BEGIN
  /*** Delete  current user's resource record ***/
  JTM_HOOK_UTIL_PKG.Delete_Acc
  ( P_PUBLICATION_ITEM_NAMES => JTM_HOOK_UTIL_PKG.t_publication_item_list('JTF_RS_RESOURCE_EXTNS')
   ,P_ACC_TABLE_NAME         => 'JTM_JTF_RS_RESOURCE_EXTNS_ACC'
   ,P_PK1_NAME               => 'RESOURCE_PK'
   ,P_PK1_NUM_VALUE          => P_RESOURCE_ID
   ,P_RESOURCE_ID            => P_RESOURCE_ID
   );
END DELETE_RESOURCE_RECORD;

PROCEDURE INSERT_USER_RECORD( P_USER_ID IN NUMBER, P_RESOURCE_ID IN NUMBER )
IS
l_count number;
BEGIN
  l_count := 0;
  JTM_HOOK_UTIL_PKG.Insert_Acc
  ( P_PUBLICATION_ITEM_NAMES => JTM_HOOK_UTIL_PKG.t_publication_item_list('FND_USER')
   ,P_ACC_TABLE_NAME         => 'JTM_FND_USER_ACC'
   ,P_PK1_NAME               => 'USER_ID'
   ,P_PK1_NUM_VALUE          => P_USER_ID
   ,P_RESOURCE_ID            => P_RESOURCE_ID
   );
   BEGIN
      select count(*) into l_count
      from JTM_ASG_USER_ACC
      where USER_ID = P_USER_ID;
      if (l_count = 0) then
         Insert into JTM_ASG_USER_ACC
         (ACCESS_ID,USER_ID,COUNTER,
         LAST_UPDATE_DATE,LAST_UPDATED_BY,CREATION_DATE,CREATED_BY)
         VALUES (JTM_ACC_TABLE_S.NEXTVAL,P_USER_ID,1,sysdate,1,sysdate,1);
      end if;
   EXCEPTION
       when others then
            NULL;
   END;
END INSERT_USER_RECORD;

PROCEDURE DELETE_USER_RECORD( P_USER_ID IN NUMBER, P_RESOURCE_ID IN NUMBER )
IS
BEGIN
  /*** Delete  current user user's record ***/
  JTM_HOOK_UTIL_PKG.Delete_Acc
  ( P_PUBLICATION_ITEM_NAMES => JTM_HOOK_UTIL_PKG.t_publication_item_list('FND_USER')
   ,P_ACC_TABLE_NAME         => 'JTM_FND_USER_ACC'
   ,P_PK1_NAME               => 'USER_ID'
   ,P_PK1_NUM_VALUE          => P_USER_ID
   ,P_RESOURCE_ID            => P_RESOURCE_ID
   );
   delete from JTM_ASG_USER_ACC where user_id = P_USER_ID;
END DELETE_USER_RECORD;


PROCEDURE POPULATE_ACCESS_RECORDS( P_USER_ID IN NUMBER )
IS
 PRAGMA AUTONOMOUS_TRANSACTION;
 CURSOR c_user( b_user_id NUMBER ) IS
  SELECT RESOURCE_ID
  FROM   ASG_USER
  WHERE USER_ID = b_user_id;
 r_user c_user%ROWTYPE;

 return_value1 BOOLEAN ;
 return_value2 BOOLEAN ;
 p_errtable JTM_CHECK_ACC_PKG.ERRTAB;
 g_debug_level NUMBER;
 l_log_id 	NUMBER;
 l_status	VARCHAR2(1);
 l_message	VARCHAR2(2000);

BEGIN
 return_value1 := TRUE;
 return_value2 := TRUE;
 OPEN c_user( P_USER_ID );
 FETCH c_user INTO r_user;
 IF c_user%FOUND THEN
   INSERT_RESOURCE_RECORD( r_user.RESOURCE_ID );
   INSERT_USER_RECORD( P_USER_ID, r_user.RESOURCE_ID );
 END IF;
 CLOSE c_user;

 return_value1 := jtm_check_acc_pkg.check_profile_acc(p_errtable);

 return_value2 := jtm_check_acc_pkg.check_jtf_acc(p_errtable);

 IF return_value1 AND return_value2 THEN
 	ASG_HELPER.enable_pub_synch('JTM');
 ELSE
 	ASG_HELPER.disable_pub_synch('JTM');
 END IF;

 IF p_errtable.count > 0 THEN
 	FOR i IN p_errtable.first..p_errtable.last LOOP
 	  IF p_errtable.exists(i) THEN
 	  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    		JTM_message_log_pkg.Log_Msg
    		( v_object_id   => null
    		, v_object_name => p_errtable(i)
    		, v_message     => 'Entering ' || p_errtable(i) ||' Check data if get populated'
    		, v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    		, v_module      => 'jtm_wrapper_pkg');
  	  END IF;

  	  JTM_MESSAGE_LOG_PKG.INSERT_CONC_STATUS_LOG
  	(v_package_name => NULL
	,v_procedure_name => NULL
	,v_con_query_id => NULL
        ,v_query_stmt => p_errtable(i)
        ,v_start_time => NULL
        ,v_end_time => NULL
        ,v_status => 'FAILED'
        ,v_message => 'Fail to populate data into' || p_errtable(i)
        ,x_log_id => l_log_id
        ,x_status => l_status
        ,x_msg_data => l_message);

        IF (l_status = 'E') THEN
        RAISE JTM_MESSAGE_LOG_PKG.G_EXC_ERROR;
    	END IF;

     END IF;
    END LOOP;

   END IF;


 COMMIT;
EXCEPTION WHEN OTHERS THEN
 ROLLBACK;
 RAISE FND_API.G_EXC_ERROR;
END POPULATE_ACCESS_RECORDS;

PROCEDURE DELETE_ACCESS_RECORDS( P_USER_ID IN NUMBER )
IS
 PRAGMA AUTONOMOUS_TRANSACTION;
 CURSOR c_user( b_user_id NUMBER ) IS
  SELECT RESOURCE_ID
  FROM   ASG_USER
  WHERE USER_ID = b_user_id;
 r_user c_user%ROWTYPE;
BEGIN
 OPEN c_user( P_USER_ID );
 FETCH c_user INTO r_user;
 IF c_user%FOUND THEN
   /* comment out this problem due to the MDG issue */
   /*DELETE_RESOURCE_RECORD( r_user.RESOURCE_ID ); */
   DELETE_USER_RECORD( P_USER_ID, r_user.RESOURCE_ID );
 END IF;
 CLOSE c_user;
 COMMIT;
EXCEPTION WHEN OTHERS THEN
 ROLLBACK;
 RAISE FND_API.G_EXC_ERROR;
END DELETE_ACCESS_RECORDS;

PROCEDURE APPLY_CLIENT_CHANGES( P_USER_NAME IN VARCHAR2
                              , P_TRAN_ID   IN NUMBER )
IS
BEGIN
 NULL;
END APPLY_CLIENT_CHANGES;

FUNCTION CHECK_OLITE_SCHEMA RETURN VARCHAR2 IS

l_return_val varchar2(30);
l_bundle_id varchar2(30);
cursor get_lang_code is
select language_code, ' ('||decode(nls_language, 'AMERICAN', 'ENGLISH', nls_language)||')' as nls_language
from fnd_languages where installed_flag in ('I', 'B');

BEGIN

   l_return_val := 'Y';
   l_bundle_id  := 'JTM_US';
   EXECUTE IMMEDIATE 'BEGIN mobileadmin.setup.removeBundleById(''jtm''); end;';
   for c in get_lang_code loop
      l_bundle_id := 'JTM_' || c.language_code;
     EXECUTE IMMEDIATE 'DELETE MOBILEADMIN.bundles WHERE bundle_id = :1'
        USING l_bundle_id;

     /*
     if (CREATE_ENTRY(c.language_code, c.nls_language) = 'N') then
         l_return_val := 'N';
     end if;
     */
   end loop;
   commit;
   RETURN l_return_val;
EXCEPTION
   WHEN OTHERS THEN
        RETURN 'N';
END CHECK_OLITE_SCHEMA;

END JTM_WRAPPER_PKG;

/
