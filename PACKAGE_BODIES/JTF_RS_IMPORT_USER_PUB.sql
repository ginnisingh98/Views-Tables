--------------------------------------------------------
--  DDL for Package Body JTF_RS_IMPORT_USER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_IMPORT_USER_PUB" AS
  /* $Header: jtfrsiub.pls 115.3 2002/12/20 07:39:58 smuniraj ship $ */

  /*****************************************************************************************
   ******************************************************************************************/

  /* Package variables. */

  G_PKG_NAME         VARCHAR2(30) := 'JTF_RS_IMPORT_USER_PUB';

  PROCEDURE crt_bulk_import (
      ERRBUF              OUT NOCOPY VARCHAR2,
      RETCODE             OUT NOCOPY VARCHAR2,
      P_TRANSACTION_NO    IN   NUMBER
  ) IS

    l_api_name          constant varchar2(30) := 'CRT_BULK_IMPORT';
    l_return_status     varchar2(100) := fnd_api.g_ret_sts_success;
    l_msg_count         number;
    l_msg_data          varchar2(2000);
    l_msg_data1         varchar2(2000);
    l_msg_index_out     varchar2(2000);

    l_first_name        jtf_rs_resource_extns.source_first_name%type ;
    l_last_name         jtf_rs_resource_extns.source_last_name%type ;
    l_user_name         jtf_rs_resource_extns.user_name%type ;
    l_email             jtf_rs_resource_extns.source_email%type ;
    l_mgr_user_name     jtf_rs_resource_extns.user_name%type ;

    l_nav_group1        jtf_iapp_families_vl.app_family_display_name%type;
    l_resp_group1       fnd_responsibility_vl.responsibility_name%type;
    l_res_role1         jtf_rs_roles_vl.role_name%type;

    l_nav_group2        jtf_iapp_families_vl.app_family_display_name%type;
    l_resp_group2       fnd_responsibility_vl.responsibility_name%type;
    l_res_role2         jtf_rs_roles_vl.role_name%type;

    l_employee_number   per_all_people_f.employee_number%type ;
    l_resource_group    jtf_rs_groups_vl.group_name%type ;
    l_default_resp      fnd_responsibility_vl.responsibility_name%type ;

    l_business_group_id per_all_people_f.business_group_id%type;
    l_mgr_employee_id   fnd_user.employee_id%type;

    cursor upload_data is
      select column1, column2, column3, column4, column5, column6, column7, column8,
             column9, column10, column11, column12, column13, record_no
      from jtf_rs_upload_data
      where transaction_no = p_transaction_no;

    cursor get_mgr_emp_id (p_mgr_user_name fnd_user.user_name%type) is
      select employee_id
      from fnd_user
      where user_name = p_mgr_user_name;

    cursor c_dup_user_name (l_user_name fnd_user.user_name%type) is
      select 1 from fnd_user
      where user_name = l_user_name;

    cursor c_mgr_user_name (l_mgr_user_name fnd_user.user_name%type) is
      select user_id from fnd_user
      where user_name = l_mgr_user_name;

    cursor c_mgr_resource_id (l_mgr_user_id jtf_rs_resource_extns.user_id%type) is
      select resource_id
      from jtf_rs_resource_extns
      where user_id = l_mgr_user_id;

    cursor c_nav_group (l_nav_group jtf_iapp_families_vl.app_family_display_name%type) is
      select app_family_id
      from jtf_iapp_families_vl
      where app_family_display_name = l_nav_group;

    cursor c_resp_group (l_resp_group fnd_responsibility_vl.responsibility_name%type) is
      select responsibility_id
      from fnd_responsibility_vl
      where responsibility_name = l_resp_group;

    cursor c_nav_resp_group (l_app_family_id jtf_iapp_families_b.app_family_id%type,
                             l_responsibility_id fnd_responsibility.responsibility_id%type) is
      select 1 from jtf_iapp_families_b jif, fnd_responsibility fr,
                    jtf_iapp_family_app_map jpm
      where jif.app_family_id = jpm.app_family_id
        and jpm.application_id = fr.application_id
        and fr.responsibility_id = l_responsibility_id
        and jif.app_family_id = l_app_family_id;

    cursor c_method_emp_gen (l_business_group_id per_all_people_f.business_group_id%type) is
      select method_of_generation_emp_num
      from per_business_groups
      where business_group_id =l_business_group_id;

    cursor c_res_group (l_resource_group jtf_rs_groups_vl.group_name%type) is
      select group_id
      from jtf_rs_groups_vl
      where group_name = l_resource_group;

    cursor c_res_role (l_role_name jtf_rs_roles_vl.role_name%type) is
      select role_id, role_code
      from jtf_rs_roles_vl
      where role_name = l_role_name;

    cursor c_get_user_id (l_user_name jtf_rs_resource_extns.user_name%type) is
      select user_id
      from fnd_user
      where user_name = l_user_name;

    l_resource_id                   number;
    l_user_id                       number;
    l_user_password                 fnd_user.encrypted_user_password%type := NULL;
    l_group_member_id               number;
    l_role_relate_id                number;

    l_mgr_user_id                   jtf_rs_resource_extns.user_id%type;
    l_mgr_resource_id               jtf_rs_resource_extns.resource_id%type;
    l_group_id                      jtf_rs_groups_b.group_id%type;
    l_role_id1                      jtf_rs_roles_b.role_id%type;
    l_role_id2                      jtf_rs_roles_b.role_id%type;
    l_role_code1                    jtf_rs_roles_b.role_code%type;
    l_role_code2                    jtf_rs_roles_b.role_code%type;

    l_app_family_id1                jtf_iapp_families_b.app_family_id%type;
    l_app_family_id2                jtf_iapp_families_b.app_family_id%type;
    l_responsibility_id1            fnd_responsibility.responsibility_id%type;
    l_responsibility_id2            fnd_responsibility.responsibility_id%type;

    l_num                           number;
    l_method_emp_gen                varchar2(150);
    l_assign_def_resp               boolean;
    l_error_flag                    varchar2(1) := 'N';
    l_error_flag_resp               varchar2(1) := 'N';
    l_error_flag_role               varchar2(1) := 'N';
    l_error_flag_grp                varchar2(1) := 'N';
    l_record_no                     jtf_rs_upload_data.record_no%type;
    l_error_text                    jtf_rs_upload_data.error_text%type := null;

  BEGIN

    for i_upload_data in upload_data loop
      fnd_msg_pub.Initialize;

    begin
      savepoint jtf_rs_bulk_import;

      l_first_name      := i_upload_data.column1;
      l_last_name       := i_upload_data.column2;
      l_user_name       := upper(i_upload_data.column3);
      l_employee_number := i_upload_data.column4;
      l_email           := i_upload_data.column5;
      l_mgr_user_name   := upper (i_upload_data.column6);
      l_resource_group  := i_upload_data.column7;
      l_nav_group1      := i_upload_data.column8;
      l_resp_group1     := i_upload_data.column9;
      l_res_role1       := i_upload_data.column10;
      l_nav_group2      := i_upload_data.column11;
      l_resp_group2     := i_upload_data.column12;
      l_res_role2       := i_upload_data.column13;
      l_default_resp    := l_resp_group1;
      l_record_no       := i_upload_data.record_no;

      l_error_flag      := 'N';
      l_error_flag_resp := 'N';
      l_error_flag_role := 'N';
      l_error_flag_grp  := 'N';

      l_error_text      := null;
      l_msg_data        := null;
      l_msg_data1       := null;
      l_msg_index_out   := null;

      --Employee Number Generation

      fnd_profile.get('PER_BUSINESS_GROUP_ID',l_business_group_id);

      open c_method_emp_gen (l_business_group_id);
      fetch c_method_emp_gen into l_method_emp_gen;
      close c_method_emp_gen;

      if l_method_emp_gen = 'A' then
        l_employee_number := null;
      end if;

      --Put all the Validations here

      --Validate Last Name
      if l_last_name is null then
        fnd_message.set_name ('JTF','JTF_RS_LAST_NAME_NULL');
        fnd_msg_pub.add;
        l_error_flag := 'Y';
      end if;

      --Validate User Name
      if l_user_name is null then
        fnd_message.set_name ('JTF','JTF_RS_USER_NAME_NULL');
        fnd_msg_pub.add;
        l_error_flag := 'Y';
      else
        open c_dup_user_name (l_user_name);
        fetch c_dup_user_name into l_num;
        if c_dup_user_name%found then
          fnd_message.set_name ('JTF','JTF_RS_USER_EXISTS');
          fnd_message.set_token ('P_USER_NAME',l_user_name);
          fnd_msg_pub.add;
          l_error_flag := 'Y';
        end if;
        close c_dup_user_name;
      end if;

      --Validate Manager User
      if l_mgr_user_name is not null then
        open c_mgr_user_name (l_mgr_user_name);
        fetch c_mgr_user_name into l_mgr_user_id;
        if c_mgr_user_name%notfound then
          fnd_message.set_name ('JTF','JTF_RS_INV_MGR_USER');
          fnd_message.set_token ('P_MGR_USER_NAME',l_mgr_user_name);
          fnd_msg_pub.add;
          l_error_flag := 'Y';
        else
          open c_mgr_resource_id (l_mgr_user_id);
          fetch c_mgr_resource_id into l_mgr_resource_id;
          if c_mgr_resource_id%notfound then
            fnd_message.set_name ('JTF','JTF_RS_MGR_INV_RESOURCE');
            fnd_message.set_token ('P_MGR_USER_NAME',l_mgr_user_name);
            fnd_msg_pub.add;
            l_error_flag := 'Y';
          end if;
          close c_mgr_resource_id;
        end if;
        close c_mgr_user_name;
      end if;

      --Validate Nav Groups
      if l_nav_group1 is null then
        fnd_message.set_name ('JTF','JTF_RS_NAV_GRP_NULL');
        fnd_msg_pub.add;
        l_error_flag_resp := 'Y';
      else
        open c_nav_group (l_nav_group1);
        fetch c_nav_group into l_app_family_id1;
        if c_nav_group%notfound then
          fnd_message.set_name ('JTF','JTF_RS_INV_NAV_GRP');
          fnd_message.set_token ('P_NAV_GROUP',l_nav_group1);
          fnd_msg_pub.add;
          l_error_flag_resp := 'Y';
        end if;
        close c_nav_group;
      end if;

      if l_nav_group2 is not null then
        open c_nav_group (l_nav_group2);
        fetch c_nav_group into l_app_family_id2;
        if c_nav_group%notfound then
          fnd_message.set_name ('JTF','JTF_RS_INV_NAV_GRP');
          fnd_message.set_token ('P_NAV_GROUP',l_nav_group2);
          fnd_msg_pub.add;
          l_error_flag_resp := 'Y';
        end if;
        close c_nav_group;
      end if;

      --Validate Responsibility
      if l_resp_group1 is null then
        fnd_message.set_name ('JTF','JTF_RS_RESP_NAME_NULL');
        fnd_msg_pub.add;
        l_error_flag_resp := 'Y';
      else
        open c_resp_group (l_resp_group1);
        fetch c_resp_group into l_responsibility_id1;
        if c_resp_group%notfound then
          fnd_message.set_name ('JTF','JTF_RS_INV_RESP_NAME');
          fnd_message.set_token ('P_RESP_NAME',l_resp_group1);
          fnd_msg_pub.add;
          l_error_flag_resp := 'Y';
        end if;
        close c_resp_group;
      end if;

      if l_resp_group2 is not null then
        open c_resp_group (l_resp_group2);
        fetch c_resp_group into l_responsibility_id2;
        if c_resp_group%notfound then
          fnd_message.set_name ('JTF','JTF_RS_INV_RESP_NAME');
          fnd_message.set_token ('P_RESP_NAME',l_resp_group2);
          fnd_msg_pub.add;
          l_error_flag_resp := 'Y';
        end if;
        close c_resp_group;
      end if;

      --Validate Nav-Resp Groups
      if (l_app_family_id1 is not null) AND (l_responsibility_id1 is not null) then
        open c_nav_resp_group (l_app_family_id1, l_responsibility_id1);
        fetch c_nav_resp_group into l_num;
        if c_nav_resp_group%notfound then
          fnd_message.set_name ('JTF','JTF_RS_INV_NAV_RESP_MAP');
          fnd_message.set_token ('P_RESP_NAME',l_resp_group1);
          fnd_message.set_token ('P_NAV_GROUP',l_nav_group1);
          fnd_msg_pub.add;
          l_error_flag_resp := 'Y';
        end if;
        close c_nav_resp_group;
      end if;

      if (l_app_family_id2 is not null) AND (l_responsibility_id2 is not null) then
        open c_nav_resp_group (l_app_family_id2, l_responsibility_id2);
        fetch c_nav_resp_group into l_num;
        if c_nav_resp_group%notfound then
          fnd_message.set_name ('JTF','JTF_RS_INV_NAV_RESP_MAP');
          fnd_message.set_token ('P_RESP_NAME',l_resp_group2);
          fnd_message.set_token ('P_NAV_GROUP',l_nav_group2);
          fnd_msg_pub.add;
          l_error_flag_resp := 'Y';
        end if;
        close c_nav_resp_group;
      end if;

      --Validate Resource Group
      if l_resource_group is not null then
        open c_res_group (l_resource_group);
        fetch c_res_group into l_group_id;
        if c_res_group%notfound then
          fnd_message.set_name ('JTF','JTF_RS_INV_RES_GRP');
          fnd_message.set_token ('P_RES_GRP',l_resource_group);
          fnd_msg_pub.add;
          l_error_flag_grp := 'Y';
        end if;
        close c_res_group;
      end if;

      --Validate Resource Roles
      if l_res_role1 is not null then
        open c_res_role (l_res_role1);
        fetch c_res_role into l_role_id1, l_role_code1;
        if c_res_role%notfound then
          fnd_message.set_name ('JTF','JTF_RS_INV_ROLE_NAME');
          fnd_message.set_token ('P_ROLE_NAME',l_res_role1);
          fnd_msg_pub.add;
          l_error_flag_role := 'Y';
        end if;
        close c_res_role;
      end if;

      if l_res_role2 is not null then
        open c_res_role (l_res_role2);
        fetch c_res_role into l_role_id2, l_role_code2;
        if c_res_role%notfound then
          fnd_message.set_name ('JTF','JTF_RS_INV_ROLE_NAME');
          fnd_message.set_token ('P_ROLE_NAME',l_res_role2);
          fnd_msg_pub.add;
          l_error_flag_role := 'Y';
        end if;
        close c_res_role;
      end if;

      if l_error_flag <> 'Y' then
        --Create the Employee Resource
        jtf_rs_res_sswa_pub.create_emp_resource (
               P_API_VERSION          => 1.0,
               P_INIT_MSG_LIST        => 'F',
               P_SOURCE_FIRST_NAME    => l_first_name,
               P_SOURCE_LAST_NAME     => l_last_name,
               P_EMPLOYEE_NUMBER      => l_employee_number,
               P_SOURCE_SEX           => 'M',
               P_SOURCE_EMAIL         => l_email,
               P_SOURCE_START_DATE    => trunc(sysdate),
               P_SOURCE_END_DATE      => null,
               P_USER_NAME            => l_user_name,
               P_SALESREP_NUMBER      => NULL,
               P_SALES_CREDIT_TYPE_ID => 1,                 /* This needs to be figured out  */
               P_SOURCE_MGR_ID        => l_mgr_resource_id, /* Resource_id of the manager */
               P_CALLED_FROM          => 'CRT_BULK_IMPORT',
               P_USER_PASSWORD        => l_user_password,
               X_RESOURCE_ID          => l_resource_id,
               X_RETURN_STATUS        => l_return_status,
               X_MSG_COUNT            => l_msg_count,
               X_MSG_DATA             => l_msg_data
        );
        if not (l_return_status = fnd_api.g_ret_sts_success) THEN
          l_error_flag := 'Y';
        end if;
      end if;

        if (l_error_flag <> 'Y' AND l_error_flag_grp <> 'Y') then
          -- Create Group Member
          if l_group_id is not null then
            jtf_rs_group_members_pub.create_resource_group_members (
               p_api_version        => 1.0,
               p_init_msg_list      => 'F',
               p_group_id           => l_group_id,
               p_resource_id        => l_resource_id,
               p_group_number       => null,
               p_resource_number    => null,
               x_return_status      => l_return_status,
               x_msg_count          => l_msg_count,
               x_msg_data           => l_msg_data,
               x_group_member_id    => l_group_member_id
            );
            if not (l_return_status = fnd_api.g_ret_sts_success) THEN
              l_error_flag_grp := 'Y';
            end if;
          end if;
        end if;

        if (l_error_flag <> 'Y' AND l_error_flag_role <> 'Y') then
          if (l_role_id1 is not null) then
            -- Create Roles for the Resource created above
            jtf_rs_role_relate_pub.create_resource_role_relate (
               p_api_version        => 1.0,
               p_init_msg_list      => 'F',
               p_role_resource_type => 'RS_INDIVIDUAL',
               p_role_resource_id   => l_resource_id,
               p_role_id            => l_role_id1,
               p_role_code          => l_role_code1,
               p_start_date_active  => trunc(sysdate),
               p_end_date_active    => null,
               x_return_status      => l_return_status,
               x_msg_count          => l_msg_count,
               x_msg_data           => l_msg_data,
               x_role_relate_id     => l_role_relate_id
            );
            if not (l_return_status = fnd_api.g_ret_sts_success) THEN
              l_error_flag_role := 'Y';
            end if;
          end if;

          if (l_role_id2 is not null) then
            jtf_rs_role_relate_pub.create_resource_role_relate (
               p_api_version        => 1.0,
               p_init_msg_list      => 'F',
               p_role_resource_type => 'RS_INDIVIDUAL',
               p_role_resource_id   => l_resource_id,
               p_role_id            => l_role_id2,
               p_role_code          => l_role_code2,
               p_start_date_active  => trunc(sysdate),
               p_end_date_active    => null,
               x_return_status      => l_return_status,
               x_msg_count          => l_msg_count,
               x_msg_data           => l_msg_data,
               x_role_relate_id     => l_role_relate_id
            );
            if not (l_return_status = fnd_api.g_ret_sts_success) THEN
              l_error_flag_role := 'Y';
            end if;
          end if;
        end if;

        if (l_error_flag <> 'Y' AND l_error_flag_role <> 'Y' AND l_error_flag_grp <> 'Y') then
          if (l_role_id1 is not null AND l_group_id is not null) then
            -- Create Group Member Roles
            jtf_rs_role_relate_pub.create_resource_role_relate (
               p_api_version        => 1.0,
               p_init_msg_list      => 'F',
               p_role_resource_type => 'RS_GROUP_MEMBER',
               p_role_resource_id   => l_group_member_id,
               p_role_id            => l_role_id1,
               p_role_code          => l_role_code1,
               p_start_date_active  => trunc(sysdate),
               p_end_date_active    => null,
               x_return_status      => l_return_status,
               x_msg_count          => l_msg_count,
               x_msg_data           => l_msg_data,
               x_role_relate_id     => l_role_relate_id
            );
            if not (l_return_status = fnd_api.g_ret_sts_success) THEN
              l_error_flag_role := 'Y';
            end if;
          end if;

          if (l_role_id2 is not null AND l_group_id is not null) then
            jtf_rs_role_relate_pub.create_resource_role_relate (
               p_api_version        => 1.0,
               p_init_msg_list      => 'F',
               p_role_resource_type => 'RS_GROUP_MEMBER',
               p_role_resource_id   => l_group_member_id,
               p_role_id            => l_role_id2,
               p_role_code          => l_role_code2,
               p_start_date_active  => trunc(sysdate),
               p_end_date_active    => null,
               x_return_status      => l_return_status,
               x_msg_count          => l_msg_count,
               x_msg_data           => l_msg_data,
               x_role_relate_id     => l_role_relate_id
            );
            if not (l_return_status = fnd_api.g_ret_sts_success) THEN
              l_error_flag_role := 'Y';
            end if;
          end if;
        end if;

        if (l_error_flag <> 'Y' AND l_error_flag_resp <> 'Y') then

          open c_get_user_id (l_user_name);
          fetch c_get_user_id into l_user_id;
          close c_get_user_id;

          --Create Fnd User Responsibility Groups
          Fnd_User_Resp_Groups_Api.Insert_Assignment(
              l_user_id,
              l_responsibility_id1,
              690,
              0,
              trunc(sysdate),
              null,
              null
          );

          if l_responsibility_id2 is not null then

             Fnd_User_Resp_Groups_Api.Insert_Assignment(
                 l_user_id,
                 l_responsibility_id2,
                 690,
                 0,
                 trunc(sysdate),
                 null,
                 null
             );
          end if;

          --Create Default Responsibility
          l_assign_def_resp := fnd_profile.save
                (X_NAME        => 'JTF_PROFILE_DEFAULT_RESPONSIBILITY',
                X_VALUE       => l_responsibility_id1,
                X_LEVEL_NAME  => 'USER',
                X_LEVEL_VALUE => l_user_id);
        end if;

        if (l_error_flag = 'Y' OR l_error_flag_resp = 'Y' OR
          l_error_flag_grp = 'Y' OR l_error_flag_role = 'Y') then
          if (fnd_msg_pub.count_msg > 0) then
            for i in 1..fnd_msg_pub.count_msg loop
              fnd_msg_pub.get
                (p_msg_index     => i,
                 p_data          => l_msg_data,
                 p_encoded       => 'F',
                 p_msg_index_out => l_msg_index_out
              );
              l_msg_data1 := l_msg_data1||FND_GLOBAL.Local_Chr(10)||l_msg_data;
            end loop;
              fnd_message.set_encoded(l_msg_data1);
              l_error_text := l_msg_data1;
          end if;

          fnd_message.set_name ('JTF','JTF_RS_USER_NOT_CREATED');
          fnd_message.set_token ('P_USER_NAME',l_user_name);
          l_error_text := fnd_message.get||l_error_text;

          update_upload_data (
            P_TRANSACTION_NO  => p_transaction_no,
            P_RECORD_NO       => l_record_no,
            P_PROCESS_STATUS  => 'U',
            P_ERROR_TEXT      => l_error_text
          );
          rollback to jtf_rs_bulk_import;
        else
          -- initiate the workflow to send the password
          jtf_um_password_pvt.send_password(
             p_api_version_number       => 1.0,
             p_requester_user_name      => l_user_name,
             p_requester_password       => l_user_password,
             p_first_time_user          => 'Y',
             p_user_verified            => 'Y',
             x_return_status            => l_return_status,
             x_msg_count                => l_msg_count,
             x_msg_data                 => l_msg_data
          );

          if not (l_return_status = fnd_api.g_ret_sts_success) THEN
            fnd_message.set_name ('JTF','JTF_RS_USER_CRT_WITH_WARNING');
            fnd_message.set_token ('P_USER_NAME',l_user_name);
            l_error_text := fnd_message.get;

            fnd_message.set_name ('JTF','JTF_RS_UNABLE_SEND_PASSWD');
            l_error_text := l_error_text||FND_GLOBAL.Local_Chr(10)||fnd_message.get;

            update_upload_data (
              P_TRANSACTION_NO  => p_transaction_no,
              P_RECORD_NO       => l_record_no,
              P_PROCESS_STATUS  => 'W',
              P_ERROR_TEXT      => l_error_text
            );
          else
            fnd_message.set_name ('JTF','JTF_RS_USER_CREATED');
            fnd_message.set_token ('P_USER_NAME',l_user_name);
            l_error_text := fnd_message.get;

            fnd_message.set_name ('JTF','JTF_RS_USER_PASSWD');
            fnd_message.set_token ('P_USER_PASSWD',l_user_password);
            l_error_text := l_error_text||FND_GLOBAL.Local_Chr(10)||fnd_message.get;

            update_upload_data (
              P_TRANSACTION_NO  => p_transaction_no,
              P_RECORD_NO       => l_record_no,
              P_PROCESS_STATUS  => 'S',
              P_ERROR_TEXT      => l_error_text
            );
            commit work;
          end if;
        end if;

      exception
        when others then
          if (fnd_msg_pub.count_msg > 0) then
            for i in 1..fnd_msg_pub.count_msg loop
              fnd_msg_pub.get
                (p_msg_index     => i,
                 p_data          => l_msg_data,
                 p_encoded       => 'F',
                 p_msg_index_out => l_msg_index_out
              );
              l_msg_data1 := l_msg_data1||FND_GLOBAL.Local_Chr(10)||l_msg_data;
            end loop;
            fnd_message.set_encoded(l_msg_data1);
            l_error_text := l_msg_data1;
          end if;

          l_error_text := l_error_text||FND_GLOBAL.Local_Chr(10)||sqlcode||' : '||sqlerrm;

          update_upload_data (
            P_TRANSACTION_NO  => p_transaction_no,
            P_RECORD_NO       => l_record_no,
            P_PROCESS_STATUS  => 'U',
            P_ERROR_TEXT      => l_error_text
          );
          rollback to jtf_rs_bulk_import;
      end;
    end loop;

  END crt_bulk_import;

  PROCEDURE  import_user
   (P_API_VERSION          IN   NUMBER,
    P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
    P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
    P_TRANSACTION_NO       IN   JTF_RS_UPLOAD_DATA.TRANSACTION_NO%TYPE,
    P_REQUEST_NO           OUT NOCOPY  NUMBER,
    X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT            OUT NOCOPY  NUMBER,
    X_MSG_DATA             OUT NOCOPY  VARCHAR2
  )
  IS

    l_api_name CONSTANT VARCHAR2(30) := 'IMPORT_USER';
    l_request  NUMBER;

    begin

      x_return_status := fnd_api.g_ret_sts_success;

      l_request := fnd_request.submit_request(application => 'JTF',
                                              program     => 'JTFRSIMPUSER',
                                              argument1   => p_transaction_no);

      p_request_no := l_request;

      update jtf_rs_upload_data
        set request_id = l_request
        where transaction_no = p_transaction_no;

      exception when others then
        fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
        fnd_message.set_token('P_SQLCODE',SQLCODE);
        fnd_message.set_token('P_SQLERRM',SQLERRM);
        fnd_message.set_token('P_API_NAME', l_api_name);
        FND_MSG_PUB.add;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        RAISE fnd_api.g_exc_unexpected_error;

  END import_user;

  procedure update_upload_data (
    P_TRANSACTION_NO IN JTF_RS_UPLOAD_DATA.TRANSACTION_NO%TYPE,
    P_RECORD_NO      IN JTF_RS_UPLOAD_DATA.RECORD_NO%TYPE,
    P_PROCESS_STATUS IN JTF_RS_UPLOAD_DATA.PROCESS_STATUS%TYPE,
    P_ERROR_TEXT     IN JTF_RS_UPLOAD_DATA.ERROR_TEXT%TYPE
  ) IS

  pragma autonomous_transaction;
  begin

  update jtf_rs_upload_data
    set error_text       = p_error_text,
        process_status   = p_process_status
    where transaction_no = p_transaction_no
    and record_no        = p_record_no;

    commit;
  end;

END jtf_rs_import_user_pub;

/
