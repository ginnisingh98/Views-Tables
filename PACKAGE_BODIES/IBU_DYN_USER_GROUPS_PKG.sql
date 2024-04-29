--------------------------------------------------------
--  DDL for Package Body IBU_DYN_USER_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBU_DYN_USER_GROUPS_PKG" AS
/* $Header: ibudyugb.pls 120.2.12010000.2 2008/08/07 06:52:44 mkundali ship $ */
-- ---------   ------  ------------------------------------------
G_USER_ID           NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID          NUMBER := FND_GLOBAL.LOGIN_ID;

-- =================================================================================================================
Procedure Log_Message(p_Message IN VARCHAR2)
IS
    now               VARCHAR2(60);
Begin
     --select to_char(sysdate, 'mm-dd-yyyy hh24:mi:ss') into now from dual;
     --dbms_output.put_line( p_Message || ' ' || now);
     --FND_FILE.PUT_LINE(FND_FILE.LOG, p_Message || ' ' || now);
     FND_FILE.PUT_LINE(FND_FILE.LOG, p_Message);
     --insert into ibu_usrgrp_results values (ibu_usrgrp_results_s.nextval , p_Message, now);
End;

-- =================================================================================================================
Procedure Status_Log_Message(p_Message IN VARCHAR2, p_return_status varchar2, p_msg_count number, p_msg_data varchar2 )
IS
    now               VARCHAR2(60);
Begin
     Log_Message( p_Message);
     Log_Message( 'Return Status = ' || p_return_status  || ' ;Msg count ' || p_msg_count);
     FOR i IN 1 .. p_msg_count LOOP
         Log_Message( ' Fnd Msg in loop = ' || fnd_msg_pub.get(i, 'F'));
     END LOOP;
     --Log_Message( ' Msg data ' || p_msg_data );
     FND_MSG_PUB.Initialize;
End;
-- =================================================================================================================
PROCEDURE get_curr_usr_resouce_info
(
   x_resource_id OUT NOCOPY jtf_rs_resource_extns.resource_id%TYPE,
   x_resource_number OUT NOCOPY jtf_rs_resource_extns.resource_number%TYPE
)
IS
     l_current_user_id   NUMBER := FND_GLOBAL.User_Id;

     -- Temporary variables
     l_creby_source_id  jtf_rs_resource_extns.source_id%TYPE;
     l_creby_empid      fnd_user.employee_id%TYPE;
     l_creby_custid     fnd_user.customer_id%TYPE;
     l_creby_supid      fnd_user.supplier_id%TYPE;
     l_creby_category         jtf_rs_resource_extns.category%TYPE;
     l_creby_res_cnt          NUMBER;
     l_category varchar2(50);

Begin
     begin
        select employee_id, customer_id, supplier_id
        into l_creby_empid, l_creby_custid, l_creby_supid
        from fnd_user
        where user_id = l_current_user_id;

        If l_creby_empid is not null Then
            l_creby_category := 'EMPLOYEE';
            l_creby_source_id := l_creby_empid ;
        ElsIf l_creby_custid is not null Then
            l_creby_category := 'PARTY';
            l_creby_source_id := l_creby_custid  ;
        ElsIf  l_creby_supid is not null Then
            l_creby_category := 'SUPPLIER_CONTACT';
            l_creby_source_id := l_creby_supid  ;
        End If;
      exception
      When no_data_found then
            l_creby_category := 'CREATED_BY_UNKNOWN';
            l_creby_source_id := 0;
      When others then
            raise;
      end;
      begin
        select resource_id, resource_number
        into x_resource_id, x_resource_number
        from jtf_rs_resource_extns
        where source_id = l_creby_source_id
        and category = l_creby_category
        and ( (end_date_active is null) or (end_date_active > sysdate) );
      exception
      When no_data_found then
          x_resource_id := 0;
          x_resource_number := 0;
      When others then
          raise;
      end;
END;
-- =================================================================================================================
-- For a given source_id, it returns count>0 if atleast there is one fnd_user record which is not end_dated.
Procedure GetFndUserActiveCnt (p_source_id IN jtf_rs_resource_extns.source_id%TYPE,
                               p_category IN jtf_rs_resource_extns.category%TYPE,
                               x_Cnt OUT NOCOPY NUMBER )
IS
Begin
     If p_category = 'EMPLOYEE' Then
         select count(*) into x_cnt
         from fnd_user
         where employee_id = p_source_id
         and ( ( end_date is null) or (end_date > sysdate) ) ;
     ElsIf p_category = 'PARTY' Then
         select max(user_id) into x_cnt
         from fnd_user
         where customer_id = p_source_id
         and ( ( end_date is null) or (end_date > sysdate) ) ;
     ElsIf p_category = 'SUPPLIER_CONTACT' Then
         select max(user_id)  into x_cnt
         from fnd_user
         where supplier_id = p_source_id
         and ( ( end_date is null) or (end_date > sysdate) ) ;
     Else
         x_cnt := 0;
     End If;

End;
-- =================================================================================================================
Procedure Get_UserID (p_source_id IN jtf_rs_resource_extns.source_id%TYPE,
                        p_category IN jtf_rs_resource_extns.category%TYPE,
                        x_user_id OUT NOCOPY fnd_user.user_id%TYPE )
IS
    l_cnt NUMBER;
Begin
           -- Find out user_id for the source_id, we need to have a link for user_id, source_id, category in jtf_rs_resource_extns table
           If p_category = 'EMPLOYEE' Then
               select max(user_id) into x_user_id
               from fnd_user
               where employee_id = p_source_id;
           ElsIf p_category = 'PARTY' Then
               select max(user_id) into x_user_id
               from fnd_user
               where customer_id = p_source_id;
           ElsIf p_category = 'SUPPLIER_CONTACT' Then
               select max(user_id)  into x_user_id
               from fnd_user
               where supplier_id = p_source_id;
           Else
               x_user_id := 0;
           End If;
End;
-- =================================================================================================================
Procedure Get_Category (p_sql_text IN varchar2, x_category OUT NOCOPY varchar2)
IS
    l_q_str jtf_rs_dynamic_groups_vl.sql_text%TYPE;
    l_num NUMBER;
    l_party_num NUMBER;
    l_emp_num NUMBER;
    l_substring VARCHAR2(2000);
Begin
    Log_Message('Query in Get_Category = { ' || p_sql_text || ' } ');

    SELECT UPPER(p_sql_text) into l_q_str from DUAL;

    SELECT INSTR (l_q_str, 'FROM', 1, 1) INTO l_num FROM DUAL;
    SELECT SUBSTR (l_q_str, 1, l_num) INTO l_substring FROM DUAL;

    SELECT INSTR (l_substring, 'PARTY_ID', 1, 1) INTO l_party_num FROM DUAL;
    IF (l_party_num  <> 0) THEN
    	x_category := 'PARTY';
    Else
    	SELECT INSTR (l_substring, 'EMPLOYEE_ID', 1, 1) INTO l_emp_num FROM DUAL;
		IF (l_emp_num  <> 0) THEN
            x_category := 'EMPLOYEE';
        Else
            x_category := 'UNKNOWN';
		END IF;
    END IF;
    Log_Message('Category output = ' || x_category );
End ;

-- =================================================================================================================

Procedure Insert_Temp_Table (p_sql_text varchar2, p_category varchar2)
IS
   cid INTEGER;
   l_ins_qry varchar2(2000);
   l_cnt NUMBER;
   l_rows_processed NUMBER;

   l_q_str varchar2(2000);
   l_first_substring varchar2(2000);
   l_last_substring varchar2(2000);

   l_num NUMBER;
   l_length NUMBER;
BEGIN

      SELECT UPPER(p_sql_text) into l_q_str from DUAL;
      SELECT INSTR (l_q_str, 'FROM', 1, 1) INTO l_num FROM DUAL;
      SELECT SUBSTR (l_q_str, 1, l_num-1) INTO l_first_substring FROM DUAL;
      SELECT length (l_q_str) INTO l_length FROM DUAL;
      --SELECT SUBSTR (l_q_str, l_num, l_length) INTO l_last_substring FROM DUAL;
	 -- For case sensitive queries
	 SELECT SUBSTR (p_sql_text, l_num, l_length) INTO l_last_substring FROM DUAL;

      l_first_substring := l_first_substring  || ' , ' || '''' || p_category ||  '''' || ' , sysdate, ' || FND_GLOBAL.USER_ID || ' , sysdate, ' || FND_GLOBAL.USER_ID || ' ' ;
      l_q_str := l_first_substring  || l_last_substring;
      l_ins_qry := 'insert into ibu_usergroups_temp(source_id, category,creation_date, created_by, last_update_date, last_updated_by )  ';
      l_ins_qry := l_ins_qry || l_q_str;
      Log_Message(' Insert Temp table query = { ' || l_ins_qry || ' } ');

      cid := dbms_sql.open_cursor;

      -- Fixed Bug# 6641845
      -- Delete the old records before inserting the new records in table ibu_usergroups_temp

      dbms_sql.parse(cid, 'delete from ibu_usergroups_temp',   dbms_sql.v7);
      l_rows_processed  := dbms_sql.execute(cid);
      Log_Message(' Insert Temp table rows deleted = ' || l_rows_processed);

      dbms_sql.parse(cid, l_ins_qry,   dbms_sql.v7);
      l_rows_processed  := dbms_sql.execute(cid);
      Log_Message(' Insert Temp table rows inserted = ' || l_rows_processed);

      --dbms_sql.parse(cid, 'commit' , dbms_sql.v7);
      dbms_sql.close_cursor(cid);

      select count(*) into l_cnt from ibu_usergroups_temp;
      Log_Message('Count in ibu_usergroups_temp =  ' || to_char(l_cnt) );
EXCEPTION
   WHEN OTHERS THEN
      Log_Message('Error in Insert_Temp_Table' ||TO_CHAR(SQLCODE)||': '||SQLERRM );
      dbms_sql.close_cursor(cid);
      raise;
End ;

-- =================================================================================================================
Procedure Update_Category_SourceID (p_category varchar2)
Is
   l_emp_id  fnd_user.employee_id%TYPE;

   Cursor l_source_csr IS
     select source_id
     from ibu_usergroups_temp ;
BEGIN
    -- Some of the customers could be valid employees, so update the category column to 'EMPLOYEE' for those customers and change the sourcE_id to employee_id instead of customer_id.
    If p_category = 'PARTY' Then
        For l_source_rec in l_source_csr Loop

            select max(employee_id) into l_emp_id
            from fnd_user A
            Where A.customer_id = l_source_rec.source_id
            and  A.employee_id is not null
            and exists ( select person_id
                         from per_workforce_current_x
                         Where person_id = A.employee_id)
            and ( (A.end_date is null) OR (A.end_date > sysdate) );

            If l_emp_id is not null Then
                Update ibu_usergroups_temp
                Set Category = 'EMPLOYEE', Source_id = l_emp_id
                Where source_id = l_source_rec.source_id;
            End If;

        End Loop;
    End If;
EXCEPTION
   WHEN OTHERS THEN
      Log_Message('Error in Update_Category_SourceID' ||TO_CHAR(SQLCODE)||': '||SQLERRM );
      raise;
End ;

-- =================================================================================================================

PROCEDURE    IBU_USER_GROUP_UPD
IS
-- A.last_update_date should be checked with the date the concurrent program was last run
  l_return_status varchar2(1);
  l_msg_count number;
  l_msg_data varchar2(2000);

--     select B.group_id, B.group_name, B.group_number,
--            A.start_date_active, A.end_date_active,
--            B.exclusive_flag, B.group_desc, B.object_version_number,
--            A.sql_text
--     from jtf_rs_dynamic_groups_vl A, jtf_rs_groups_vl B
--     Where A.group_name || '(' || A.group_number || ')' =  B.GROUP_NAME
--     and (  ( A.end_date_active is null ) or ( A.end_date_active > sysdate ) )
--     and  A.Usage =  'ISUPPORT';

-- Updated the group_name to match the (11111) patterns only
-- see bug 2925331, when user updated the group name
-- the original code created a new static group instead of updating
-- the old one

--  Cursor l_upd_usrgrp_csr IS
--     select B.group_id, A.group_name || '(' || A.group_number || ')' group_name, B.group_number,
--            A.start_date_active, A.end_date_active,
--            B.exclusive_flag, B.group_desc, B.object_version_number,
--            A.sql_text
--     from jtf_rs_dynamic_groups_vl A, jtf_rs_groups_vl B
--     Where B.GROUP_NAME like '%(' || A.group_number || ')'
--     and (  ( A.end_date_active is null ) or ( A.end_date_active > sysdate ) )
--     and  A.Usage =  'ISUPPORT';
     --and A.last_update_date > Sysdate - 1;

-- bug 4861793 : performance fix
-- this leaves a FTS on jtf_rs_dynamic_groups_b since it has no index except the
-- key column. should be ok for us, since this is a small setup table.
  Cursor l_upd_usrgrp_csr IS
     select
     B.group_id,
     ATL.group_name || '(' || A.group_number || ')' group_name,
     B.group_number,
     A.start_date_active,
     A.end_date_active,
     B.exclusive_flag,
     BTL.group_desc,
     B.object_version_number,
     A.sql_text
     from
     jtf_rs_dynamic_groups_b A,
     jtf_rs_dynamic_groups_tl ATL,
     jtf_rs_groups_b B,
     jtf_rs_groups_tl BTL
     Where
     B.group_id = BTL.group_id
     and
     A.group_id = ATL.group_id
     and
     BTL.language = userenv('LANG')
     and
     ATL.language = BTL.language
     and
     BTL.GROUP_NAME = ATL.group_name || '(' || A.group_number || ')'
     and
     nvl(a.end_date_active,trunc(sysdate)) >= trunc(sysdate)
     and
     A.Usage =  'ISUPPORT' ;


    l_group_id jtf_rs_groups_vl.group_id%TYPE;
    l_group_name  jtf_rs_groups_vl.group_name%TYPE;
    l_group_number jtf_rs_groups_vl.group_number%TYPE;
    l_start_date_active jtf_rs_dynamic_groups_vl.start_date_active%TYPE;
    l_end_date_active  jtf_rs_dynamic_groups_vl.end_date_active%TYPE;
    l_exclusive_flag jtf_rs_groups_vl.exclusive_flag%TYPE;
    l_group_desc jtf_rs_groups_vl.group_desc%TYPE;
    l_obj_grp_version_num  jtf_rs_groups_vl.object_version_number%TYPE;
    l_sql_text jtf_rs_dynamic_groups_vl.sql_text%TYPE;
    l_category varchar2(50);
    l_role_relate_id  jtf_rs_role_relations.role_relate_id%TYPE;
    l_object_version_number jtf_rs_role_relations.object_version_number%TYPE;
    l_user_id  fnd_user.user_id%TYPE;

  Cursor l_del_mem_csr(p_group_id jtf_rs_groups_vl.group_id%TYPE)
  IS
    select  A.group_member_id,
        	B.resource_id,
        	B.resource_number ,
            B.source_id,
        	A.object_version_number
    from jtf_rs_group_members_vl A, jtf_rs_resource_extns B
    where group_id = p_group_id
    and A.resource_id = B.resource_id
    and A.delete_flag = 'N'
    and A.resource_id not in (  select resource_id
                                from jtf_rs_resource_extns C, ibu_usergroups_temp D
                                where C.source_id = D.source_id
                                and C.category = D.category);

  Cursor l_cre_res_csr
  IS
    select source_id, category
    from ibu_usergroups_temp A
    where not exists (select source_id
                      from jtf_rs_resource_extns
                      where source_id = A.source_id
                      and category = A.category
                      and ( (end_date_active is null ) OR (end_date_active > sysdate) )
                      );

  -- Do not create members whose resource records are end dated
  Cursor l_cre_csr (p_group_id jtf_rs_groups_vl.group_id%TYPE)
  IS
    select B.resource_id, B.resource_number
    from ibu_usergroups_temp A, jtf_rs_resource_extns B
    where A.source_id = B.source_id
    and A.category = B.category
    and not exists ( select resource_id
                     from jtf_rs_group_members
                     where resource_id = B.resource_id
                     and group_id = p_group_id
                     and delete_flag = 'N')
    and ( ( B.end_date_active is null ) or (B.end_date_active > sysdate) )  ;

    l_resource_cnt number;
    l_resource_id jtf_rs_resource_extns.resource_id%TYPE;
    l_resource_number jtf_rs_resource_extns.resource_number%TYPE;
    l_group_member_id jtf_rs_group_members.group_member_id%TYPE;

    l_fndactive_cnt NUMBER;
    l_res_start_date_active jtf_rs_resource_extns.start_date_active%TYPE;
    l_res_end_date_active jtf_rs_resource_extns.end_date_active%TYPE;
    l_source_name                 jtf_rs_resource_extns.source_name%TYPE;
    l_dbl_res_cnt NUMBER;

  -- bug 3032219
  -- to get the first start date of the employee
  CURSOR c_emp_start_date(c_person_id IN NUMBER) IS
  SELECT date_start
  FROM   per_periods_of_service
  WHERE  person_id = c_person_id
  ORDER BY date_start asc;

  -- to get the person detail of an employee
  CURSOR c_emp_dtls(c_person_id IN NUMBER) IS
  SELECT full_name
  FROM   per_all_people_f
  WHERE  person_id = c_person_id
  ORDER BY effective_start_date desc;

begin

Log_Message('Begin ibu_user_group_upd procedure.... ');
For l_upd_rec  in l_upd_usrgrp_csr Loop

    /* Find category for the SQL_TEXT */
    get_category(l_upd_rec.sql_text, l_category);

    If (  ( l_category = 'PARTY' ) OR ( l_category = 'EMPLOYEE' ) ) Then
        l_group_id := l_upd_rec.group_id;
        l_group_name := l_upd_rec.group_name;
        l_group_number := l_upd_rec.group_number;
        l_start_date_active := l_upd_rec.start_date_active;
        l_end_date_active := l_upd_rec.end_date_active;
        l_exclusive_flag := l_upd_rec.exclusive_flag;
        l_group_desc := l_upd_rec.group_desc;
        l_obj_grp_version_num := l_upd_rec.object_version_number;
        l_sql_text := l_upd_rec.sql_text;
        Log_Message( '+----------------------------------------------------------------------+');
        Log_Message( '%%%Start Update Processing for Group Name = ' || l_group_name || '%%%');
        Log_Message( 'Group Id = ' || l_group_id);
        Log_Message( 'Group Number = ' || l_group_number);

        /* call update role_relations */
    	select role_relate_id, object_version_number
    	into l_role_relate_id, l_object_version_number
    	from  jtf_rs_role_relations
    	where role_resource_type = 'RS_GROUP'
    	and role_resource_id = l_group_id;
        jtf_rs_role_relate_pub.UPDATE_RESOURCE_ROLE_RELATE (
                                                            P_API_VERSION  => 1.0,
                                                            P_INIT_MSG_LIST  => fnd_api.g_false,
                                                            P_COMMIT  =>  FND_API.G_FALSE,
                                                            P_ROLE_RELATE_ID   =>  l_role_relate_id,
                                                            P_START_DATE_ACTIVE  => l_start_date_active,
                                                            P_END_DATE_ACTIVE    => l_end_date_active,
                                                            P_OBJECT_VERSION_NUM   =>  l_object_version_number,
                                                            X_RETURN_STATUS    => l_return_status,
                                                            X_MSG_COUNT => l_msg_count,
                                                            X_MSG_DATA => l_msg_data
                                                            );
        Status_Log_Message('Return status of JTF_RS_ROLE_RELATE_PUB.UPDATE_RESOURCE_ROLE_RELATE api ',
                            l_return_status , l_msg_count , l_msg_data );

        /* Update Resource Group.*/
        JTF_RS_GROUPS_PUB.UPDATE_RESOURCE_GROUP(
                                                P_API_VERSION => 1,
                                                P_INIT_MSG_LIST => FND_API.G_FALSE,
                                                P_COMMIT => FND_API.G_FALSE,
                                                P_GROUP_ID => l_group_id,
                                                P_GROUP_NUMBER => l_group_number,
                                                P_GROUP_NAME => l_group_name,
                                                P_GROUP_DESC => l_group_desc,
                                                P_EXCLUSIVE_FLAG => l_exclusive_flag,
                                                P_EMAIL_ADDRESS => NULL,
                                                P_START_DATE_ACTIVE => l_start_date_active,
                                                P_END_DATE_ACTIVE => l_end_date_active,
                                                P_ACCOUNTING_CODE => NULL,
                                                P_OBJECT_VERSION_NUM   => l_obj_grp_version_num,
                                                X_RETURN_STATUS => l_return_status,
                                                X_MSG_COUNT => l_msg_count,
                                                X_MSG_DATA => l_msg_data
                                                );
        Status_Log_Message('Return status of JTF_RS_GROUPS_PUB.UPDATE_RESOURCE_GROUP api ',
                            l_return_status , l_msg_count , l_msg_data );

        /* Insert into temporary table, results of user group 'dynamic' query. */
        insert_temp_table(l_sql_text, l_category);

        /* In case of customer user group, Some of the customers could be valid employees, so update the category column to 'EMPLOYEE' for those customers, source_id column to employee_id */
        Update_Category_SourceId(l_category);

        /* Delete existing members in the group who should not be part of this user group. Reason : because of change in the user group query */
        For l_del_mem_rec IN l_del_mem_csr(l_group_id) Loop
        	JTF_RS_GROUP_MEMBERS_PUB.delete_resource_group_members
                                                        		  (P_API_VERSION => 1,
                                                        		   P_INIT_MSG_LIST =>FND_API.G_FALSE,
                                                        		   P_COMMIT =>FND_API.G_FALSE,
                                                        		   P_GROUP_ID =>l_upd_rec.group_id ,
                                                        		   P_GROUP_NUMBER => l_upd_rec.group_number,
                                                        		   P_RESOURCE_ID  => l_del_mem_rec.resource_id,
                                                        		   P_RESOURCE_NUMBER => l_del_mem_rec.resource_number,
                                                        		   P_OBJECT_VERSION_NUM => l_del_mem_rec.object_version_number,
                                                                   X_RETURN_STATUS => l_return_status,
                                                        		   X_MSG_COUNT => l_msg_count,
                                                        		   X_MSG_DATA => l_msg_data
                                                        		  );
             Status_Log_Message('Return status of JTF_RS_GROUP_MEMBERS_PUB.delete_resource_group_members api ' ||
                                ' l_mem_id = ' || to_char(l_del_mem_rec.group_member_id)  || ' ',
                                 l_return_status , l_msg_count , l_msg_data );
        End Loop;

        /* Create resources for new members if they are not already resources */

        For l_cre_res_rec IN l_cre_res_csr Loop
            select count(*) into l_resource_cnt
            from jtf_rs_resource_extns
            where source_id = l_cre_res_rec.source_id
            and category = l_cre_res_rec.category;

            If l_resource_cnt = 0 then

              If ( l_cre_res_rec.category = 'EMPLOYEE') Then
                -- bug 3032219
                OPEN c_emp_start_date(l_cre_res_rec.source_id);
                FETCH c_emp_start_date INTO l_res_start_date_active;
                  IF c_emp_start_date%NOTFOUND THEN
                    l_res_start_date_active := sysdate;
                  END IF; -- for employee existence check
                CLOSE c_emp_start_date;

                -- source name
                OPEN c_emp_dtls(l_cre_res_rec.source_id);
                  FETCH c_emp_dtls into l_source_name;
                  IF c_emp_dtls%NOTFOUND THEN
                    l_source_name := null;
                  END IF;
                CLOSE c_emp_dtls;

              else
                -- party
                BEGIN
                  SELECT party_name,creation_date
                    INTO l_source_name, l_res_start_date_active
                  FROM hz_parties
                  WHERE party_id = l_cre_res_rec.source_id;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                   l_source_name := null;
                   l_res_start_date_active := sysdate;
                  WHEN OTHERS THEN
                   l_source_name := null;
                   l_res_start_date_active := sysdate;
                END;
              end if;

               JTF_RS_RESOURCE_PUB.CREATE_RESOURCE(
                                                   P_API_VERSION                  => 1.0,
                                                   P_INIT_MSG_LIST 		            => FND_API.G_FALSE,
                                                   P_COMMIT 			                => FND_API.G_FALSE,
                                                   P_CATEGORY                     => l_cre_res_rec.category,
                                                   P_SOURCE_ID                    => l_cre_res_rec.source_id,
                                                   P_SOURCE_NAME                  => l_source_name,
                                                   P_START_DATE_ACTIVE            => l_res_start_date_active,
                                                   X_RETURN_STATUS                => l_return_status,
                                                   X_MSG_COUNT                    => l_msg_count,
                                                   X_MSG_DATA                     => l_msg_data,
                                                   X_RESOURCE_ID                  => l_resource_id,
                                                   X_RESOURCE_NUMBER              => l_resource_number
                                                  );
                If (l_return_status <> fnd_api.g_ret_sts_success) Then
                    Status_Log_Message('Return status of JTF_RS_RESOURCE_PUB.create_resource api ' ||
                                        ' l_cre_res_rec.category = ' || l_cre_res_rec.category  ||
                                        ' l_source_name = ' || l_source_name  ||
                                        ' l_res_start_date_active = ' || l_res_start_date_active  ||
                                        ' l_cre_rec.source_id = ' || to_char(l_cre_res_rec.source_id)  || ' ',
                                        l_return_status , l_msg_count , l_msg_data );
                End If;
             Else -- If l_resource_cnt = 0 then
                select count(*)
                into l_dbl_res_cnt
                from jtf_rs_resource_extns
                where source_id = l_cre_res_rec.source_id
                and category = l_cre_res_rec.category
                and ( (end_date_active is null) or (end_date_active > sysdate) );
                If l_dbl_res_cnt > 1 Then
                    -- Multiple active resource records for one fnd_user record.
                    Log_Message( 'This user has not been added to user group.  This fnd_user record has mutltiple active resource records. Please correct this.' ||
                                 ' source_id = ' || l_cre_res_rec.source_id ||
                                 ' category = ' || l_cre_res_rec.category);
                ElsIf l_dbl_res_cnt = 0 Then
                    -- All the resource records are end_dated
                    select resource_id, resource_number, object_version_number, end_date_active
                    into l_resource_id, l_resource_number , l_object_version_number, l_res_end_date_active
                    from jtf_rs_resource_extns
                    where source_id = l_cre_res_rec.source_id
                    and category = l_cre_res_rec.category
                    and resource_id = (select max(resource_id)
                                       from  jtf_rs_resource_extns
                                       Where source_id = l_cre_res_rec.source_id
                                       and category = l_cre_res_rec.category);
                    -- Check if resource records are end dated
                    GetFndUserActiveCnt(l_cre_res_rec.source_id, l_cre_res_rec.category, l_fndactive_cnt);
                    If l_fndactive_cnt = 0 Then
                      Log_Message( ' resource_id = ' || to_char(l_resource_id) ||
                                   ' resource_number = ' || l_resource_number ||
                                   ' ; source_id = ' || to_char(l_cre_res_rec.source_id) ||
                                   ' ; category = ' || l_cre_res_rec.category ||
                                   ' Safely skip this record, all fnd_user records belonging to this source_id are' ||
                                   ' end_dated. So, resource record is also end dated ;'
                                 );
                    Else
                      -- Atleast one fnd_user record is still active. So, Log_Message a message that Resource is end_dated even though fnd_user is valid
                      Log_Message(' * resource_id = ' || to_char(l_resource_id) ||
                                  ' resource_number = ' || l_resource_number ||
                                  ' ; source_id = ' || to_char(l_cre_res_rec.source_id) ||
                                  ' ; category = ' || l_cre_res_rec.category ||
                                  ' This user has not been added to user group. Fnd User record is active.' ||
                                  ' But resource record is end dated. ' ||
                                  ' Correct the end_date_active of resource record' );
                    End If;
                End If; -- If l_dbl_res_cnt > 1 Then
             End If; --If l_resource_cnt = 0 then
        End Loop;

        /* create news members in the group who are not part of this user group. Reason : because of change in the user group query */
        For l_cre_rec IN l_cre_csr(l_group_id) Loop
            JTF_RS_GROUP_MEMBERS_PUB.create_resource_group_members(P_API_VERSION          => 1.0,
                                                                   P_INIT_MSG_LIST        => FND_API.G_FALSE,
                                                                   P_COMMIT               => FND_API.G_FALSE,
                                                                   P_GROUP_ID             => l_group_id,
                                                                   P_GROUP_NUMBER         => l_group_number,
                                                                   P_RESOURCE_ID          => l_cre_rec.resource_id,
                                                                   P_RESOURCE_NUMBER      => l_cre_rec.resource_number,
                                                                   X_RETURN_STATUS        => l_return_status,
                                                                   X_MSG_COUNT            => l_msg_count,
                                                                   X_MSG_DATA             => l_msg_data,
                                                                   X_GROUP_MEMBER_ID      => l_group_member_id
                                                                   );
             If (l_return_status <> fnd_api.g_ret_sts_success) Then
                 Status_Log_Message('Return status of JTF_RS_GROUP_MEMBERS_PUB.create_resource_group_members api ' ||
                                    ' l_cre_rec.resource_id = ' || to_char(l_cre_rec.resource_id)  || ' ',
                                    l_return_status , l_msg_count , l_msg_data );
             End If;
        End Loop;
        Log_Message( '%%%End Update Processing for Group Name = ' || l_group_name || '%%%');
        Log_Message( '+----------------------------------------------------------------------+');
    Else
        Log_Message( '%%%Not a Valid SQL : Update Processing for Group Name = ' || l_group_name || '%%%');
    End If; --(  ( l_category = 'PARTY' ) OR ( l_category = 'EMPLOYEE' ) )
    commit;
End Loop; -- End of l_upd_csr loop
Log_Message('End ibu_user_group_upd procedure.... ');
Exception
    When Others Then
        Log_Message(' Error in IBU_USER_GROUP_UPD' || TO_CHAR(SQLCODE)||': '||SQLERRM );
        raise;
End;
-- =================================================================================================================
PROCEDURE    IBU_USER_GROUP_CRE
IS
-- A.last_update_date should be checked with the date the concurrent program was last run
  l_return_status varchar2(1);
  l_msg_count number;
  l_msg_data varchar2(2000);

  Cursor l_cre_usrgrp_csr IS
     select A.group_id, A.group_name, A.group_number,
            A.group_name || '(' || A.group_number || ')' static_group_name,
            A.start_date_active, A.end_date_active,
            A.group_desc,
            A.sql_text,
            A.created_by
     from jtf_rs_dynamic_groups_vl A
     Where  not exists ( Select B.group_name
                        from jtf_rs_groups_vl B
                        Where B.group_name = A.group_name || '(' || A.group_number || ')'  )
     and (  ( A.end_date_active is null ) or ( A.end_date_active > sysdate ) )
     and  A.Usage =  'ISUPPORT';

  Cursor l_cre_mem_csr IS
     select source_id, category
     from ibu_usergroups_temp ;

  -- bug 3032219
  -- to get the first start date of the employee
  CURSOR c_emp_start_date(c_person_id IN NUMBER) IS
  SELECT date_start
  FROM   per_periods_of_service
  WHERE  person_id = c_person_id
  ORDER BY date_start asc;

  -- to get the person detail of an employee
  CURSOR c_emp_dtls(c_person_id IN NUMBER) IS
  SELECT full_name
  FROM   per_all_people_f
  WHERE  person_id = c_person_id
  ORDER BY effective_start_date desc;

   createResGrpExp   Exception;
   creByFndUserExp   Exception;

   -- IN/OUT variables for APIs
   l_group_id            jtf_rs_groups_vl.group_id%type;
   l_group_number        jtf_rs_groups_vl.group_number%type;
   l_resource_id		 jtf_rs_resource_extns.resource_id%TYPE;
   l_resource_number	 jtf_rs_resource_extns.resource_number%TYPE;
   l_channel_rec		 AMV_CHANNEL_PVT.AMV_CHANNEL_OBJ_TYPE;

   -- constants in this program
   l_exclusive_flag	     jtf_rs_groups_vl.exclusive_flag%TYPE	DEFAULT 'N';
   l_role_code		jtf_rs_role_relations_vl.ROLE_TYPE_CODE%TYPE :=  'IBUUG';
   l_usage			JTF_RS_GROUP_USAGES.USAGE%TYPE  := 'ISUPPORT';

   -- Temporary variables
   l_creby_source_id  jtf_rs_resource_extns.source_id%TYPE;
   l_creby_empid      fnd_user.employee_id%TYPE;
   l_creby_custid     fnd_user.customer_id%TYPE;
   l_creby_supid      fnd_user.supplier_id%TYPE;
   l_creby_category         jtf_rs_resource_extns.category%TYPE;
   l_creby_res_cnt          NUMBER;
   l_creby_resource_id      jtf_rs_resource_extns.resource_id%TYPE;
   l_creby_resource_number  jtf_rs_resource_extns.resource_number%TYPE;
   l_creby_obj_ver_num      jtf_rs_resource_extns.object_version_number%TYPE;
   l_channel_id             NUMBER;
   l_role_relate_id	        JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE;
   l_group_usage_id	        JTF_RS_GROUP_USAGES.GROUP_USAGE_ID%TYPE;
   l_category               varchar2(50);
   l_res_cnt                NUMBER;
   l_group_member_id	    JTF_RS_GROUP_MEMBERS.GROUP_MEMBER_ID%TYPE;
   l_object_version_number  jtf_rs_resource_extns.object_version_number%TYPE;
   l_user_id                fnd_user.user_id%TYPE;

    l_fndactive_cnt NUMBER;
    l_res_end_date_active jtf_rs_resource_extns.end_date_active%TYPE;
    l_res_start_date_active jtf_rs_resource_extns.start_date_active%TYPE;

    l_source_name     jtf_rs_resource_extns.source_name%TYPE;
    l_address_id     jtf_rs_resource_extns.address_id%TYPE;
    l_temp_cnt       NUMBER;
    l_dbl_res_cnt    NUMBER;
Begin
     Log_Message('Begin ibu_user_group_cre procedure.... ');
     For l_cre_rec IN l_cre_usrgrp_csr Loop

        /* Find category for the SQL_TEXT */
        get_category(l_cre_rec.sql_text, l_category);

        If (  ( l_category = 'PARTY' ) OR ( l_category = 'EMPLOYEE' ) ) Then
             Log_Message( '+----------------------------------------------------------------------+');
             Log_Message( '%%%Start Create Processing for Group Name = ' || l_cre_rec.static_group_name || '%%%');
             /* Call the Resource Group API, to create the group and it's members */
             jtf_rs_groups_pub.create_resource_group
                                              	(P_API_VERSION => 1.0,
                                              	P_INIT_MSG_LIST => FND_API.G_FALSE,
                                              	P_COMMIT => FND_API.G_FALSE,
                                              	P_GROUP_NAME => l_cre_rec.static_group_name,
                                              	P_GROUP_DESC => l_cre_rec.group_desc,
                                              	P_EXCLUSIVE_FLAG => l_exclusive_flag, --'N'
                                              	P_START_DATE_ACTIVE => l_cre_rec.start_date_active,
                                              	P_END_DATE_ACTIVE => l_cre_rec.end_date_active,
                                              	P_ACCOUNTING_CODE => NULL,
                                              	X_RETURN_STATUS => l_return_status,
                                              	X_MSG_COUNT => l_msg_count,
                                              	X_MSG_DATA => l_msg_data,
                                              	X_GROUP_ID => l_group_id,
                                              	X_GROUP_NUMBER => l_group_number
                                              	);
             Status_Log_Message('Return status of jtf_rs_groups_pub.create_resource_group api ' ||
                                ' l_cre_rec.static_group_name = ' || l_cre_rec.static_group_name  ||
                                ' ; l_group_id = ' || to_char(l_group_id) || ' ',
                                 l_return_status , l_msg_count , l_msg_data );
             IF NOT (l_return_status = fnd_api.g_ret_sts_success) THEN
                    raise createResGrpExp;
             End If;

             /* for MES channel_rec, to pass a valid resource_id for owner id.
             First check if, resource_id exists for that user_id.
             If, not then create a resource. But before that, check if resource, is an employee, vendor or customer. Accordingly, populate category and source_id */
             -- get the sysadmin's resource_id, resource_number
            get_curr_usr_resouce_info(l_creby_resource_id, l_creby_resource_number);

            /* Call the MES Channel API to Create a Channel for the Group */
         	l_channel_rec.CHANNEL_ID :=	 		        FND_API.G_MISS_NUM;
            l_channel_rec.OBJECT_VERSION_NUMBER	:= 	    FND_API.G_MISS_NUM;
            l_channel_rec.CHANNEL_NAME	:=		        FND_API.G_MISS_CHAR;
            l_channel_rec.DESCRIPTION	:=		        FND_API.G_MISS_CHAR;
            l_channel_rec.CHANNEL_TYPE	:=		'GROUP';
            l_channel_rec.CHANNEL_CATEGORY_ID :=		FND_API.G_MISS_NUM;
            l_channel_rec.STATUS :=				        FND_API.G_MISS_CHAR;
            l_channel_rec.OWNER_USER_ID	:=		l_creby_resource_id;
            l_channel_rec.DEFAULT_APPROVER_USER_ID:=l_creby_resource_id;
    	    l_channel_rec.EFFECTIVE_START_DATE	:= 	    FND_API.G_MISS_DATE;
            l_channel_rec.EXPIRATION_DATE :=		    FND_API.G_MISS_DATE;
            l_channel_rec.ACCESS_LEVEL_TYPE :=		'PUBLIC';
            l_channel_rec.PUB_NEED_APPROVAL_FLAG := 	FND_API.G_FALSE;
            l_channel_rec.SUB_NEED_APPROVAL_FLAG :=		FND_API.G_FALSE;
            l_channel_rec.MATCH_ON_ALL_CRITERIA_FLAG :=	FND_API.G_FALSE;
            l_channel_rec.MATCH_ON_KEYWORD_FLAG	:=	    FND_API.G_FALSE;
            l_channel_rec.MATCH_ON_AUTHOR_FLAG	:=	    FND_API.G_FALSE;
            l_channel_rec.MATCH_ON_PERSPECTIVE_FLAG :=	FND_API.G_FALSE;
            l_channel_rec.MATCH_ON_ITEM_TYPE_FLAG :=	FND_API.G_FALSE;
            l_channel_rec.MATCH_ON_CONTENT_TYPE_FLAG :=	FND_API.G_FALSE;
            l_channel_rec.MATCH_ON_TIME_FLAG	:=	    FND_API.G_FALSE;
            l_channel_rec.APPLICATION_ID :=			170;
            l_channel_rec.EXTERNAL_ACCESS_FLAG :=		FND_API.G_FALSE;
            l_channel_rec.ITEM_MATCH_COUNT :=		0;
            l_channel_rec.LAST_MATCH_TIME :=		null;
            l_channel_rec.NOTIFICATION_INTERVAL_TYPE :=	null;
            l_channel_rec.LAST_NOTIFICATION_TIME :=	null;
            l_channel_rec.ATTRIBUTE_CATEGORY :=		null;
            l_channel_rec.ATTRIBUTE1 :=			    null;
            l_channel_rec.ATTRIBUTE2 :=			    null;
            l_channel_rec.ATTRIBUTE3 :=			    null;
            l_channel_rec.ATTRIBUTE4 :=			    null;
            l_channel_rec.ATTRIBUTE5 :=			    null;
            l_channel_rec.ATTRIBUTE6 :=			    null;
            l_channel_rec.ATTRIBUTE7 :=			    null;
            l_channel_rec.ATTRIBUTE8 :=			    null;
            l_channel_rec.ATTRIBUTE9 :=			    null;
            l_channel_rec.ATTRIBUTE10 :=			null;
            l_channel_rec.ATTRIBUTE11 :=			null;
            l_channel_rec.ATTRIBUTE12 :=			null;
            l_channel_rec.ATTRIBUTE13 :=			null;
            l_channel_rec.ATTRIBUTE14 :=			null;
        	l_channel_rec.ATTRIBUTE15 :=			null;

            AMV_CHANNEL_GRP.ADD_GROUPCHANNEL ( P_API_VERSION => 1.0,
                                             P_INIT_MSG_LIST  => FND_API.G_FALSE,
                                             P_COMMIT  => FND_API.G_FALSE,
                                             P_CHECK_LOGIN_USER    => fnd_api.g_false,
                                             P_VALIDATION_LEVEL  => FND_API.G_VALID_LEVEL_FULL,
                                             P_GROUP_ID   =>  l_group_id,
                                             P_CHANNEL_RECORD   => l_channel_rec,
                                             X_RETURN_STATUS   => l_return_status,
                                             X_MSG_COUNT   =>  l_msg_count,
                                             X_MSG_DATA   =>   l_msg_data,
                                             X_CHANNEL_ID   => l_channel_id
                                            ) ;
            Status_Log_Message('Return status of AMV_CHANNEL_GRP.add_groupchannel api ' ||
                                ' l_group_id = ' || to_char(l_group_id)  ||
                                ' {OWNER_USER_ID} -> l_creby_resource_id = ' || to_char(l_creby_resource_id) || ' ',
                                 l_return_status , l_msg_count , l_msg_data );

            /* Call the resource roles API to create a role relationship for the group. */
            jtf_rs_role_relate_pub.create_resource_role_relate
                                                            (P_API_VERSION => 1,
                                                             P_INIT_MSG_LIST => fnd_api.g_false,
                                                             P_COMMIT => fnd_api.g_false,
                                                             P_ROLE_RESOURCE_TYPE => 'RS_GROUP',
                                                             P_ROLE_RESOURCE_ID => l_group_id,
                                                             P_ROLE_ID => NULL,
                                                             P_ROLE_CODE => l_role_code, --'IBUUG'
                                                             P_START_DATE_ACTIVE => l_cre_rec.start_date_active,
                                                             P_END_DATE_ACTIVE => l_cre_rec.end_date_active,
                                                             X_RETURN_STATUS => l_return_status,
                                                             X_MSG_COUNT => l_msg_count,
                                                             X_MSG_DATA => l_msg_data,
                                                             X_ROLE_RELATE_ID => l_role_relate_id
                                                            );
            Status_Log_Message('Return status of jtf_rs_role_relate_pub.create_resource_role_relate api ' ||
                                ' l_group_id = ' || to_char(l_group_id)  ||
                                ' l_role_relate_id = ' || to_char(l_role_relate_id) || ' ',
                                l_return_status , l_msg_count , l_msg_data );

            /* Call the Usage API to create a relationship between the usage and Group */
            jtf_rs_group_usages_pub.create_group_usage
                                                      (P_API_VERSION => 1,
                                                       P_INIT_MSG_LIST => FND_API.G_FALSE,
                                                       P_COMMIT => FND_API.G_FALSE,
                                                       P_GROUP_ID => l_group_id,
                                                       P_GROUP_NUMBER => l_group_number,
                                                       P_USAGE => l_usage,
                                                       X_RETURN_STATUS => l_return_status,
                                                       X_MSG_COUNT => l_msg_count,
                                                       X_MSG_DATA => l_msg_data,
                                                       X_GROUP_USAGE_ID =>l_group_usage_id
                                                      );
            Status_Log_Message('Return status of jtf_rs_group_usages_pub.create_group_usage api ' ||
                               ' l_group_id = ' || to_char(l_group_id)  ||
                               ' l_group_usage_id = ' || to_char(l_group_usage_id) || ' ',
                               l_return_status , l_msg_count , l_msg_data );

            /* Insert into temporary table, results of user group 'dynamic' query. */
            insert_temp_table(l_cre_rec.sql_text, l_category);

            /* In case of customer user group, Some of the customers could be valid employees, so update the category column to 'EMPLOYEE' for those customers, source_id column to employee_id */
            Update_Category_SourceId(l_category);

            /* Check for each member, a resouce exists, if not create a resource. Then make this user member of the group*/
            For l_cre_mem_rec IN l_cre_mem_csr Loop
                -- check if resource needs to be created - begin
                SELECT count(*) INTO l_res_cnt
          			FROM jtf_rs_resource_extns a
    	      		WHERE a.source_id = l_cre_mem_rec.source_id
    			      and category = l_cre_mem_rec.category;

                If l_res_cnt = 0 Then

                  If ( l_cre_mem_rec.category = 'EMPLOYEE') Then
                    -- bug 3032219
                    OPEN c_emp_start_date(l_cre_mem_rec.source_id);
                    FETCH c_emp_start_date INTO l_res_start_date_active;
                      IF c_emp_start_date%NOTFOUND THEN
                        l_res_start_date_active := sysdate;
                      END IF; -- for employee existence check
                    CLOSE c_emp_start_date;

                    -- source name
                    OPEN c_emp_dtls(l_cre_mem_rec.source_id);
                      FETCH c_emp_dtls into l_source_name;
                      IF c_emp_dtls%NOTFOUND THEN
                        l_source_name := null;
                      END IF;
                    CLOSE c_emp_dtls;

                  else
                    -- party
                    BEGIN
                      SELECT party_name,creation_date
                        INTO l_source_name, l_res_start_date_active
                      FROM hz_parties
                      WHERE party_id = l_cre_mem_rec.source_id;
                    EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                       l_source_name := null;
                       l_res_start_date_active := sysdate;
                      WHEN OTHERS THEN
                       l_source_name := null;
                       l_res_start_date_active := sysdate;
                    END;
                  end if;

                    -- create a resource
                    JTF_RS_RESOURCE_PUB.CREATE_RESOURCE(
                                                         P_API_VERSION                  => 1.0,
                                                         P_INIT_MSG_LIST 		        => FND_API.G_FALSE,
                                                         P_COMMIT 			            => FND_API.G_FALSE,
                                                         P_CATEGORY                     => l_cre_mem_rec.category,
                                                         P_SOURCE_ID                    => l_cre_mem_rec.source_id,
                                                         P_SOURCE_NAME                  => l_source_name,
                                                         P_START_DATE_ACTIVE            => l_res_start_date_active,
                                                         X_RETURN_STATUS                => l_return_status,
                                                         X_MSG_COUNT                    => l_msg_count,
                                                         X_MSG_DATA                     => l_msg_data,
                                                         X_RESOURCE_ID                  => l_resource_id,
                                                         X_RESOURCE_NUMBER              => l_resource_number
                                                        );
                    If (l_return_status <> fnd_api.g_ret_sts_success) Then
                        Status_Log_Message('Return status of JTF_RS_RESOURCE_PUB.create_resource api ' ||
                                          ' l_cre_mem_rec.category = ' || l_cre_mem_rec.category  ||
                                          ' l_source_name = ' || l_source_name  ||
                                          ' l_res_start_date_active = ' || l_res_start_date_active  ||
                                           ' l_cre_mem_rec.source_id = ' || to_char(l_cre_mem_rec.source_id)  || ' ',
                                            l_return_status , l_msg_count , l_msg_data );
                    End If;
                Else -- Resource already exists -- If l_res_cnt = 0 Then
                    select count(*)
                    into l_dbl_res_cnt
                    from jtf_rs_resource_extns
                    where source_id = l_cre_mem_rec.source_id
                    and category = l_cre_mem_rec.category
                    and ( (end_date_active is null ) OR (end_date_active > sysdate) );

                    If l_dbl_res_cnt = 0 Then
                        -- No active resources. So, see if there are active fnd user records.
                        select resource_id, resource_number, object_version_number, end_date_active
                        into l_resource_id, l_resource_number, l_object_version_number , l_res_end_date_active
                        from jtf_rs_resource_extns
                        where source_id = l_cre_mem_rec.source_id
                        and category = l_cre_mem_rec.category
                        and resource_id = (select max(resource_id)
                                           from  jtf_rs_resource_extns
                                           Where source_id = l_cre_mem_rec.source_id
                                           and category = l_cre_mem_rec.category);
                        GetFndUserActiveCnt(l_cre_mem_rec.source_id, l_cre_mem_rec.category, l_fndactive_cnt);
                        If l_fndactive_cnt = 0 Then
                           Log_Message(  ' resource_number = ' || l_resource_number ||
                                         ' ; source_id = ' || to_char(l_cre_mem_rec.source_id) ||
                                         ' ; category = ' || l_cre_mem_rec.category ||
                                         ' Safely skip this record, all fnd_user records belonging to this source_id are' ||
                                         ' end_dated. So, resource record is also end dated ;'
                                       );
                        Else
                            -- Atleast one fnd_user record is still active. So, Log_Message a message that Resource is end_dated even though fnd_user is valid
                            Log_Message(' * resource_number = ' || l_resource_number ||
                                        ' ; source_id = ' || to_char(l_cre_mem_rec.source_id) ||
                                        ' ; category = ' || l_cre_mem_rec.category ||
                                        ' This user has not been added to user group. Fnd User record is active.' ||
                                        ' But resource record is end dated. ' ||
                                        ' Correct the end_date_active of resource record' );
                        End If;
                        l_resource_id := 0;
                        l_resource_number := 0;
                    ElsIf  l_dbl_res_cnt > 1 Then -- If l_dbl_res_cnt = 0 Then
                        -- Mulitple active resources
                         log_message('This user has not been added to user group. ' ||
                                     'l_cre_mem_rec.source_id = ' || l_cre_mem_rec.source_id ||
                                     ' l_cre_mem_rec.category = ' || l_cre_mem_rec.category ||
                                     ' multiple active resource record are found. please correct it and rerun the concurrent program'
                                      );
                         log_message ( ' Use this following query to find the duplicate resource records for this user');
                         log_message ( 'select resource_number, end_date_active, start_date ' ||
                                       ' from jtf_rs_resource_extns ' ||
                                       '  where source_id = ? ' ||
                                       '   and category_id = ?  ' );
                        l_resource_id := 0;
                        l_resource_number := 0;
                    Else
                        -- only one resource is active.
                        select resource_id, resource_number, object_version_number, end_date_active
                        into l_resource_id, l_resource_number, l_object_version_number , l_res_end_date_active
                        from jtf_rs_resource_extns
                        where source_id = l_cre_mem_rec.source_id
                        and category = l_cre_mem_rec.category
                        and ( (end_date_active is null ) OR (end_date_active > sysdate) );
                    End If;
                End If; -- End of (l_res_cnt = 0)
                -- check if resource needs to be created - end
                -- Resource exists by now, so create resource member.

                If l_resource_id <> 0 Then
                        /* resource already exists and it is active. So, call create group members api */
                        jtf_rs_group_members_pub.create_resource_group_members
                                                                            (P_API_VERSION          => 1.0,
                                                                             P_INIT_MSG_LIST        => FND_API.G_FALSE,
                                                                             P_COMMIT               => FND_API.G_FALSE,
                                                                             P_GROUP_ID             => l_group_id,
                                                                             P_GROUP_NUMBER         => l_group_number,
                                                                             P_RESOURCE_ID          => l_resource_id,
                                                                             P_RESOURCE_NUMBER      => l_resource_number,
                                                                             X_RETURN_STATUS        => l_return_status,
                                                                             X_MSG_COUNT            => l_msg_count,
                                                                             X_MSG_DATA             => l_msg_data,
                                                                             X_GROUP_MEMBER_ID      => l_group_member_id
                                                                            );
                        If (l_return_status <> fnd_api.g_ret_sts_success) Then
                            select count(*) into l_temp_cnt
                            from jtf_rs_group_members
                            Where group_id = l_group_id
                            and resource_id = l_resource_id
                            and delete_flag = 'N';
                            If l_temp_cnt = 0 Then
                                  Status_Log_Message('Return status of JTF_RS_GROUP_MEMBERS_PUB.create_resource_group_members api ' ||
                                                         ' l_resource_id = ' || to_char(l_resource_id)  || ' ',
                                                         l_return_status , l_msg_count , l_msg_data );
                            End If;
                        End If;
                End If; -- End of l_resource_id <> 0

            End Loop; -- End of l_cre_mem_csr
            Log_Message( '%%%End Create Processing for Group Name = ' || l_cre_rec.static_group_name || '%%%');
            Log_Message( '+----------------------------------------------------------------------+');
        Else
            Log_Message( '%%%Not a valid SQL for Create Processing for Group Name = ' || l_cre_rec.static_group_name || '%%%');
        End If; -- End of (  ( l_category = 'PARTY' ) OR ( l_category = 'EMPLOYEE' ) )
        commit;
     End Loop; -- End of l_cre_usrgrp_csr
     Log_Message('End ibu_user_group_cre procedure.... ');
Exception
    When Others Then
        Log_Message(' Error in IBU_USER_GROUP_CRE ' || TO_CHAR(SQLCODE)||': '||SQLERRM );
        raise;
End;
-- =================================================================================================================
PROCEDURE    IBU_USER_GROUP_DEL
IS
-- A.last_update_date should be checked with the date the concurrent program was last run
  l_return_status varchar2(1);
  l_msg_count number;
  l_msg_data varchar2(2000);

  Cursor l_del_usrgrp_csr IS
     select  A.group_id  dyn_group_id,
             A.group_name dyn_group_name,
             A.group_number dyn_group_number,
             B.group_id  static_group_id,
             B.group_name static_group_name,
             B.group_number static_group_number,
             A.start_date_active, A.end_date_active, A.sql_text,
             B.exclusive_flag, B.group_desc, B.object_version_number
     from jtf_rs_dynamic_groups_vl A, jtf_rs_groups_vl B
     Where A.group_name || '(' || A.group_number || ')' =  B.GROUP_NAME
     and (  ( B.end_date_active is null ) OR ( B.end_date_active > sysdate ) )
     and (  ( A.end_date_active is not null ) AND ( A.end_date_active <= sysdate ) )
     and A.usage = 'ISUPPORT';

     Cursor l_del_chnl_csr (p_group_name  amv_c_channels_vl.channel_name%TYPE ) IS
      	select channel_id
      	from amv_c_channels_vl
      	where channel_name = p_group_name;

    Cursor l_del_mem_csr(p_group_id jtf_rs_group_members.group_id%TYPE )
    IS
       select B.group_member_id,
              A.group_id,
              A.group_number,
              B.object_version_number,
              B.resource_id,
              C.resource_number
       from  jtf_rs_groups_vl A, jtf_rs_group_members B, jtf_rs_resource_extns C
       Where A.group_id = p_group_id
       and   A.group_id = B.group_id
       and   B.resource_id = C.resource_id
       and   B.delete_flag = 'N' ;

     -- Temporary variables
     l_creby_source_id  jtf_rs_resource_extns.source_id%TYPE;
     l_creby_empid      fnd_user.employee_id%TYPE;
     l_creby_custid     fnd_user.customer_id%TYPE;
     l_creby_supid      fnd_user.supplier_id%TYPE;
     l_creby_category         jtf_rs_resource_extns.category%TYPE;
     l_creby_res_cnt          NUMBER;
     l_creby_resource_id      jtf_rs_resource_extns.resource_id%TYPE;
     l_creby_resource_number  jtf_rs_resource_extns.resource_number%TYPE;
     l_creby_obj_ver_num      jtf_rs_resource_extns.object_version_number%TYPE;
     l_category varchar2(50);
     l_role_relate_id  jtf_rs_role_relations.role_relate_id%TYPE;
     l_object_version_number jtf_rs_role_relations.object_version_number%TYPE;

     -- constant
     l_current_user_id   NUMBER := FND_GLOBAL.User_Id;

     l_res_end_date_active jtf_rs_resource_extns.end_date_active%TYPE;
     l_source_name     jtf_rs_resource_extns.source_name%TYPE;
     l_address_id     jtf_rs_resource_extns.address_id%TYPE;

     creByFndUserExp Exception;
Begin
     Log_Message('Inside ibu_user_group_del procedure.... ');
     For l_del_rec IN l_del_usrgrp_csr Loop
          Log_Message( '+----------------------------------------------------------------------+');
          Log_Message( '%%%Start Delete Processing for Group Name = ' || l_del_rec.static_group_name || '%%%');

          /* call the delete channel api of MES */
          For l_del_chnl_rec IN l_del_chnl_csr(l_del_rec.static_group_name) Loop
                AMV_CHANNEL_GRP.DELETE_CHANNEL( P_API_VERSION  => 1.0,
                                             P_INIT_MSG_LIST  => FND_API.G_FALSE,
                                             P_COMMIT  =>  FND_API.G_FALSE,
                                             P_VALIDATION_LEVEL =>FND_API.G_VALID_LEVEL_FULL,
                                             P_CHECK_LOGIN_USER =>FND_API.G_FALSE,
                                             P_CHANNEL_ID  => l_del_chnl_rec.channel_id,
                                             X_RETURN_STATUS  => l_return_status,
                                             X_MSG_COUNT =>  l_msg_count,
                                             X_MSG_DATA  =>l_msg_data
                                            );
                Status_Log_Message('Return status of AMV_CHANNEL_GRP.DELETE_CHANNEL api ' || ' l_del_chnl_rec.channel_id = ' ||
                                   to_char(l_del_chnl_rec.channel_id)  || ' ',
                                   l_return_status , l_msg_count , l_msg_data );
          End Loop; -- End of l_del_chnl_csr

         /* call update role_relations */
         Begin
           	select role_relate_id, object_version_number
          	into l_role_relate_id, l_object_version_number
          	from  jtf_rs_role_relations
          	where role_resource_type = 'RS_GROUP'
          	and role_resource_id = l_del_rec.static_group_id;
        Exception
            When no_data_found then
                l_role_relate_id := 0;
                l_object_version_number := 0;
            When others then
                raise;
        End;
        If l_role_relate_id <> 0 then
            jtf_rs_role_relate_pub.UPDATE_RESOURCE_ROLE_RELATE( P_API_VERSION  => 1.0,
                                                               P_INIT_MSG_LIST  => fnd_api.g_false,
                                                               P_COMMIT  =>  FND_API.G_FALSE,
                                                               P_ROLE_RELATE_ID   =>  l_role_relate_id,
                                                               P_START_DATE_ACTIVE  => l_del_rec.start_date_active,
                                                               P_END_DATE_ACTIVE    => l_del_rec.end_date_active,
                                                               P_OBJECT_VERSION_NUM   =>  l_object_version_number,
                                                               X_RETURN_STATUS    => l_return_status,
                                                               X_MSG_COUNT => l_msg_count,
                                                               X_MSG_DATA => l_msg_data
                                                               );
        End If;
        Status_Log_Message('Return status of jtf_rs_role_relate_pub.update_resource_role_relate api ',
                            l_return_status , l_msg_count , l_msg_data );

        /* call update resource group */
        jtf_rs_groups_pub.update_resource_group
                                              (P_API_VERSION => 1,
                                               P_INIT_MSG_LIST => fnd_api.g_false,
                                               P_COMMIT => FND_API.G_FALSE,
                                               P_GROUP_ID => l_del_rec.static_group_id,
                                               P_GROUP_NUMBER => l_del_rec.static_group_number,
                                               P_GROUP_NAME => l_del_rec.static_group_name,
                                               P_GROUP_DESC => l_del_rec.group_desc,
                                               P_EXCLUSIVE_FLAG => l_del_rec.exclusive_flag,
                                               P_START_DATE_ACTIVE => l_del_rec.start_date_active,
                                               P_END_DATE_ACTIVE => l_del_rec.end_date_active,
                                               P_ACCOUNTING_CODE => NULL,
                                               P_OBJECT_VERSION_NUM   => l_del_rec.object_version_number,
                                               X_RETURN_STATUS => l_return_status,
                                               X_MSG_COUNT => l_msg_count,
                                               X_MSG_DATA => l_msg_data
                                              );
        Status_Log_Message('Return status of JTF_RS_GROUPS_PUB.UPDATE_RESOURCE_GROUP api ',
                            l_return_status , l_msg_count , l_msg_data );

        /* Find category for the SQL_TEXT */
        get_category(l_del_rec.sql_text, l_category);

        For l_del_mem_rec IN l_del_mem_csr(l_del_rec.static_group_id) Loop
            jtf_rs_group_members_pub.delete_resource_group_members(P_API_VERSION          => 1.0,
                                                                   P_INIT_MSG_LIST        => FND_API.G_FALSE,
                                                                   P_COMMIT               => FND_API.G_FALSE,
                                                                   P_GROUP_ID             => l_del_mem_rec.group_id,
                                                                   P_GROUP_NUMBER         => l_del_mem_rec.group_number,
                                                                   P_RESOURCE_ID          => l_del_mem_rec.resource_id,
                                                                   P_RESOURCE_NUMBER      => l_del_mem_rec.resource_number,
                                                                   P_OBJECT_VERSION_NUM   => l_del_mem_rec.object_version_number,
                                                                   X_RETURN_STATUS        => l_return_status,
                                                                   X_MSG_COUNT            => l_msg_count,
                                                                   X_MSG_DATA             => l_msg_data
                                                                   );
             If (l_return_status <> fnd_api.g_ret_sts_success) Then
                 Status_Log_Message('Return status of JTF_RS_GROUP_MEMBERS_PUB.delete_resource_group_members api ' ||
                                    ' l_mem_id = ' || to_char(l_del_mem_rec.group_member_id)  || ' ',
                                    l_return_status , l_msg_count , l_msg_data );
             End If;
        End Loop; -- End of l_del_mem_csr loop
        Log_Message( '%%%End Delete Processing for Group Name = ' || l_del_rec.static_group_name || '%%%');
        Log_Message( '+----------------------------------------------------------------------+');
        commit;
     End Loop; -- End of l_del_csr loop
     Log_Message('End ibu_user_group_del procedure.... ');
Exception
    When Others Then
        Log_Message(' Error in IBU_USER_GROUP_DEL ' || TO_CHAR(SQLCODE)||': '||SQLERRM );
        raise;
End;
-- =================================================================================================================
 PROCEDURE check_resource_setup
 (
    x_resource_id OUT NOCOPY jtf_rs_resource_extns.resource_id%TYPE,
    x_resource_number OUT NOCOPY jtf_rs_resource_extns.resource_number%TYPE,
    x_setup_success OUT NOCOPY NUMBER
 )
 IS
     l_current_user_id   NUMBER := FND_GLOBAL.User_Id;

     -- Temporary variables
     l_creby_source_id  jtf_rs_resource_extns.source_id%TYPE;
     l_creby_empid      fnd_user.employee_id%TYPE;
     l_creby_custid     fnd_user.customer_id%TYPE;
     l_creby_supid      fnd_user.supplier_id%TYPE;
     l_creby_category         jtf_rs_resource_extns.category%TYPE;
     l_creby_res_cnt          NUMBER;
     l_creby_resource_id      jtf_rs_resource_extns.resource_id%TYPE;
     l_creby_resource_number  jtf_rs_resource_extns.resource_number%TYPE;
     l_creby_obj_ver_num      jtf_rs_resource_extns.object_version_number%TYPE;
     l_category varchar2(50);
     l_role_relate_id  jtf_rs_role_relations.role_relate_id%TYPE;
     l_object_version_number jtf_rs_role_relations.object_version_number%TYPE;

     l_return_status varchar2(1);
     l_msg_count number;
     l_msg_data varchar2(2000);
     l_dbl_res_cnt number;

     l_res_start_date_active jtf_rs_resource_extns.start_date_active%TYPE;
     l_source_name     jtf_rs_resource_extns.source_name%TYPE;

  -- bug 3032219
  -- to get the first start date of the employee
  CURSOR c_emp_start_date(c_person_id IN NUMBER) IS
  SELECT date_start
  FROM   per_periods_of_service
  WHERE  person_id = c_person_id
  ORDER BY date_start asc;

  -- to get the person detail of an employee
  CURSOR c_emp_dtls(c_person_id IN NUMBER) IS
  SELECT full_name
  FROM   per_all_people_f
  WHERE  person_id = c_person_id
  ORDER BY effective_start_date desc;


 Begin
                x_setup_success := 1;
                select employee_id, customer_id, supplier_id into l_creby_empid, l_creby_custid, l_creby_supid
                from fnd_user
                where user_id = l_current_user_id;
                If l_creby_empid is not null Then
                    l_creby_category := 'EMPLOYEE';
                    l_creby_source_id := l_creby_empid ;
                ElsIf l_creby_custid is not null Then
                    l_creby_category := 'PARTY';
                    l_creby_source_id := l_creby_custid  ;
                ElsIf  l_creby_supid is not null Then
                    l_creby_category := 'SUPPLIER_CONTACT';
                    l_creby_source_id := l_creby_supid  ;
                Else
                    l_creby_category := 'CREATED_BY_UNKNOWN';
                    l_creby_source_id := 0;
                End If;

                select count(*) into l_creby_res_cnt
                from jtf_rs_resource_extns
                where source_id = l_creby_source_id
                and category = l_creby_category;

                If l_creby_res_cnt = 0 then

                  if (l_creby_category = 'EMPLOYEE') then

                    -- bug 3032219
                    OPEN c_emp_start_date(l_creby_empid);
                    FETCH c_emp_start_date INTO l_res_start_date_active;
                      IF c_emp_start_date%NOTFOUND THEN
                        l_res_start_date_active := sysdate;
                      END IF; -- for employee existence check
                    CLOSE c_emp_start_date;

                    -- source name
                    OPEN c_emp_dtls(l_creby_empid);
                      FETCH c_emp_dtls into l_source_name;
                      IF c_emp_dtls%NOTFOUND THEN
                        l_source_name := null;
                      END IF;
                    CLOSE c_emp_dtls;
                  ElsIf (l_creby_category = 'PARTY') then

                    -- party
                    BEGIN
                      SELECT party_name,creation_date
                        INTO l_source_name, l_res_start_date_active
                      FROM hz_parties
                      WHERE party_id = l_creby_custid;
                    EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                       l_source_name := null;
                       l_res_start_date_active := sysdate;
                      WHEN OTHERS THEN
                       l_source_name := null;
                       l_res_start_date_active := sysdate;
                    END;
                  elsif (l_creby_category = 'SUPPLIER_CONTACT') then
                     BEGIN
                       SELECT  POC.LAST_NAME || ' , ' || POC.MIDDLE_NAME ||' '||
                             POC.FIRST_NAME|| ' - '|| POV.VENDOR_NAME, nvl(POC.CREATION_DATE,sysdate)
                       INTO l_source_name, l_res_start_date_active
                       FROM    PO_VENDOR_CONTACTS POC,
                               PO_VENDOR_SITES_ALL   POS,
                               PO_VENDORS            POV
                       WHERE   POC.VENDOR_CONTACT_ID = l_creby_supid
                       AND  POC.VENDOR_SITE_ID    =  POS.VENDOR_SITE_ID
                       AND  POS.VENDOR_ID         =  POV.VENDOR_ID;
                     EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                       l_res_start_date_active := sysdate;
                       l_source_name := null;
                     WHEN OTHERS THEN
                       l_res_start_date_active := sysdate;
                       l_source_name := null;
                     END;
                  else
                    l_res_start_date_active := sysdate;
                    l_source_name := null;
                  end if;

                    -- Resource needs to be created for created_by
                     JTF_RS_RESOURCE_PUB.CREATE_RESOURCE(
                                                         P_API_VERSION                  => 1.0,
                                                         P_INIT_MSG_LIST 		          => FND_API.G_FALSE,
                                                         P_COMMIT 			                => FND_API.G_FALSE,
                                                         P_CATEGORY                     => l_creby_category,
                                                         P_SOURCE_ID			              => l_creby_source_id,
                                                         P_SOURCE_NAME                  => l_source_name,
                                                         P_START_DATE_ACTIVE		        => l_res_start_date_active,
                                                         P_USER_ID                      => l_current_user_id,
                                                         X_RETURN_STATUS                => l_return_status,
                                                         X_MSG_COUNT                    => l_msg_count,
                                                         X_MSG_DATA                     => l_msg_data,
                                                         X_RESOURCE_ID                  => l_creby_resource_id,
                                                         X_RESOURCE_NUMBER              => l_creby_resource_number
                                                        );
                    Status_Log_Message('Return status of JTF_RS_RESOURCE_PUB.create_resource api ' ||
                                       ' l_creby_source_id = ' || to_char(l_creby_source_id)  ||
                                       ' l_creby_category = ' || l_creby_category  ||
                                       ' l_res_start_date_active = ' || l_res_start_date_active  ||
                                       ' l_source_name = ' || l_source_name  ||
                                       ' l_creby_resource_id = ' || to_char(l_creby_resource_id) || ' ',
                                       l_return_status , l_msg_count , l_msg_data );
                Else
                    select count(*)
                    into l_dbl_res_cnt
                    from jtf_rs_resource_extns
                    where source_id = l_creby_source_id
                    and category = l_creby_category
                    and ( (end_date_active is null) or (end_date_active > sysdate) );

                    If l_dbl_res_cnt = 0 Then
                        -- resource records are enddated
                        x_setup_success := 0;
                        log_message( 'CURRENT USER RESOURCE RECORD IS END DATED. please correct it and rerun the concurrent program. ' );
                        log_message('Current User_id = ' || l_current_user_id ||
                                    ' source_id = ' || l_creby_source_id ||
                                    ' category = ' || l_creby_category
                                    );
                        log_message ( 'In sqlplus Use this following query to find the resource numbers for the current login user');
                        log_message ( 'select resource_number, end_date_active, start_date ' ||
                                       ' from jtf_rs_resource_extns ' ||
                                       '  where source_id = ' || l_creby_source_id ||
                                       '   and category =  ' || '''' || l_creby_category  || '''' );
                        log_message('Log in to FORMS env with responsibility - CRM Resource Manager, Vision Enterprises');
                        log_message(' Maintain Resources -> Resources -> Enter resource_number from the above query -> Un End date the resource record or Create a new Resource record');
                    ElsIf l_dbl_res_cnt > 1 Then
                        -- multiple resource records are active - please correct it.
                        x_setup_success := 0;
                        log_message('1. MULTIPLE ACTIVE RESOURCE RECORDS ARE FOUND FOR THE CURRENT USER. please correct it and rerun the concurrent program. ' );
                        log_message(' Current User_id = ' || l_current_user_id ||
                                    ' source_id = ' || l_creby_source_id ||
                                    ' category = ' || l_creby_category
                                    );
                        log_message ( '2. In sqlplus Use this following query to find the duplicate resource records for the current login user');
                        log_message ( 'select resource_number, end_date_active, start_date ' ||
                                       ' from jtf_rs_resource_extns ' ||
                                       '  where source_id = ' || l_creby_source_id ||
                                       '   and category =  ' || '''' || l_creby_category  || '''' );
                        log_message('3. Log in to FORMS env with responsibility - CRM Resource Manager, Vision Enterprises');
                        log_message(' Maintain Resources -> Resources -> Enter resource_number from the above query -> End date the unwanted resource record');
                    Else
                        select resource_id, resource_number
                        into x_resource_id, x_resource_number
                        from jtf_rs_resource_extns
                        where source_id = l_creby_source_id
                        and category = l_creby_category
                        and ( (end_date_active is null) or (end_date_active > sysdate) );

                        /* MES Delete Channel API expects sysadmin to have MES_ADMIN, MES_SETUP_CHANNEL role_codes */
                        Log_Message ('Assigning MES_ADMIN, MES_SETUP_CHANNEL roles to current login user. Ignore exceptions raised by these APIs');
                        jtf_rs_role_relate_pub.create_resource_role_relate
                                                                        (P_API_VERSION => 1,
                                                                         P_INIT_MSG_LIST => fnd_api.g_false,
                                                                         P_COMMIT => fnd_api.g_false,
                                                                         P_ROLE_RESOURCE_TYPE => 'RS_INDIVIDUAL',
                                                                         P_ROLE_RESOURCE_ID => x_resource_id,
                                                                         P_ROLE_ID => NULL,
                                                                         P_ROLE_CODE => 'MES_ADMIN',
                                                                         P_START_DATE_ACTIVE => sysdate,
                                                                         X_RETURN_STATUS => l_return_status,
                                                                         X_MSG_COUNT => l_msg_count,
                                                                         X_MSG_DATA => l_msg_data,
                                                                         X_ROLE_RELATE_ID => l_role_relate_id
                                                                        );
                        Status_Log_Message('Return status of jtf_rs_role_relate_pub.create_resource_role_relate api MES_ADMIN',
                                            l_return_status , l_msg_count , l_msg_data );
                        jtf_rs_role_relate_pub.create_resource_role_relate
                                                                        (P_API_VERSION => 1,
                                                                         P_INIT_MSG_LIST => fnd_api.g_false,
                                                                         P_COMMIT => fnd_api.g_false,
                                                                         P_ROLE_RESOURCE_TYPE => 'RS_INDIVIDUAL',
                                                                         P_ROLE_RESOURCE_ID => x_resource_id,
                                                                         P_ROLE_ID => NULL,
                                                                         P_ROLE_CODE => 'MES_SETUP_CHANNEL',
                                                                         P_START_DATE_ACTIVE => sysdate,
                                                                         X_RETURN_STATUS => l_return_status,
                                                                         X_MSG_COUNT => l_msg_count,
                                                                         X_MSG_DATA => l_msg_data,
                                                                         X_ROLE_RELATE_ID => l_role_relate_id
                                                                        );
                        Status_Log_Message('Return status of jtf_rs_role_relate_pub.create_resource_role_relate api MES_SETUP_CHANNEL',
                                           l_return_status , l_msg_count , l_msg_data );
                    End If; -- If l_dbl_res_cnt = 0 Then
                 End If; -- l_creby_res_cnt = 0
END;

-- =================================================================================================================
 PROCEDURE run_conc_prog
 (
        ERRBUF OUT NOCOPY VARCHAR2,
		RETCODE OUT NOCOPY NUMBER
 )
 IS
    x_resource_id jtf_rs_resource_extns.resource_id%TYPE;
    x_resource_number jtf_rs_resource_extns.resource_number%TYPE;
    x_setup_success NUMBER;

    mesSysAdminSetupException   Exception;
 Begin

   FND_MSG_PUB.Initialize;
   check_resource_setup( x_resource_id ,  x_resource_number , x_setup_success );
   If x_setup_success = 1 Then
       Log_Message('******************Begin run_conc_prog********************'  );
       ibu_user_group_upd;
       ibu_user_group_cre;
       ibu_user_group_del;
       Log_Message('******************End run_conc_prog********************'  );
   Else
        raise mesSysAdminSetupException;
   End If;

   commit;
 Exception
    When mesSysAdminSetupException Then
        Log_Message(' Problem with Sysadmin resource record : Verify this log file for more details :  ' || TO_CHAR(SQLCODE)||': '||SQLERRM );
        raise;
    When Others Then
        Log_Message(' Error in run_conc_prog ' || TO_CHAR(SQLCODE)||': '||SQLERRM );
        raise;
 End;

-- =================================================================================================================
END; -- Package Body IBU_DYN_USER_GROUPS_PKG

/
