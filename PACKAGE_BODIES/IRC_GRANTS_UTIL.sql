--------------------------------------------------------
--  DDL for Package Body IRC_GRANTS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_GRANTS_UTIL" AS
/* $Header: irgntutl.pkb 120.0.12000000.2 2007/05/07 14:39:22 vkaduban noship $ */
-- ----------------------------------------------------------------------------
-- |--------------------------< create_grants>--------------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_grants(
   errbuf    OUT NOCOPY VARCHAR2
  ,retcode   OUT NOCOPY NUMBER
  ,p_resp_key IN VARCHAR2
  ,p_resp_appl_name IN VARCHAR2
  ,p_permission_set IN VARCHAR2)
IS
  cursor csr_get_candidates(p_resp_id number, p_menu_id number) is
  select fu.user_id, fu.user_name, furg.security_group_id
  from
  fnd_user fu, fnd_user_resp_groups furg
  where furg.responsibility_id = p_resp_id
  and furg.user_id=fu.user_id
  and fu.user_id > 1000
  and trunc(sysdate) between nvl(fu.start_date,trunc(sysdate)) and nvl(fu.end_date,trunc(sysdate))
  and not exists (select /*+ NO_UNNEST */1 from fnd_grants where grantee_type='USER' and grantee_key=fu.user_name
  and ctx_resp_id=furg.responsibility_id and menu_id=p_menu_id);

  cursor get_menu_id is
  select menu_id from fnd_menus where menu_name=upper(p_permission_set);

  cursor get_responsibility_id is
  select responsibility_id, application_id
  from fnd_responsibility where responsibility_key=upper(p_resp_key);

  l_user_id number;

  TYPE l_user_id_typ IS TABLE OF FND_USER.USER_ID%TYPE index by binary_integer;
  TYPE l_user_name_typ IS TABLE OF FND_USER.USER_NAME%TYPE index by binary_integer;
  TYPE l_resp_id_typ IS TABLE OF FND_USER_RESP_GROUPS.RESPONSIBILITY_ID%TYPE index by binary_integer;
  TYPE l_resp_appl_id_typ IS TABLE OF FND_USER_RESP_GROUPS.RESPONSIBILITY_APPLICATION_ID%TYPE index by binary_integer;
  TYPE l_sec_group_id_typ IS TABLE OF FND_USER_RESP_GROUPS.SECURITY_GROUP_ID%TYPE index by binary_integer;

  l_user_id_tbl l_user_id_typ;
  l_user_name_tbl l_user_name_typ;
  l_sec_group_id_tbl l_sec_group_id_typ;

  l_menu_id number;
  l_responsibility_id number;
  l_resp_appl_id number;
  l_grant_name varchar2(80);
  l_user_name varchar2(100);
  l_o varchar2(30);
  l_plsql_max_array_size number := 1000;

  l_proc VARCHAR2(30) default 'create_grants';
BEGIN
  hr_utility.set_location('Entering'||l_proc, 10);
  -- get menu id for the permission set
  open get_menu_id;
  fetch get_menu_id into l_menu_id;
  close get_menu_id;
  -- get Resp info
  open get_responsibility_id;
  fetch get_responsibility_id into l_responsibility_id,l_resp_appl_id;
  close get_responsibility_id;

  hr_utility.set_location('before csr_get_candidates', 20);

  open csr_get_candidates(l_responsibility_id, l_menu_id);
  loop
    l_user_id_tbl.delete;
    l_user_name_tbl.delete;
    l_sec_group_id_tbl.delete;

    FETCH csr_get_candidates BULK COLLECT INTO
                     l_user_id_tbl
                    ,l_user_name_tbl
                    ,l_sec_group_id_tbl
                    limit l_plsql_max_array_size;

    IF (l_user_id_tbl.count = 0) THEN
      EXIT;
    END IF;

    FOR i in l_user_id_tbl.first..l_user_id_tbl.last LOOP
      --
      fnd_global.apps_initialize(user_id=>l_user_id_tbl(i),
                               resp_id=> l_responsibility_id,
                               resp_appl_id=> l_resp_appl_id,
                               security_group_id=>l_sec_group_id_tbl(i),
                               server_id=>null);
      --
      l_user_name := l_user_name_tbl(i);
      if length(l_user_name) > 65 then
        l_grant_name := 'IRC_'||substr(l_user_name,1,65)||'_CAND_GRANT';
      else
        l_grant_name := 'IRC_'||upper(l_user_name)||'_CAND_GRANT';
      end if;
      --
      irc_party_api.grant_access(p_user_name => l_user_name,
                             p_user_id   => l_user_id_tbl(i),
                             p_menu_id   => l_menu_id,
                             p_resp_id   => l_responsibility_id,
                             p_resp_appl_id => l_resp_appl_id,
                             p_sec_group_id => l_sec_group_id_tbl(i),
                             p_grant_name => l_grant_name,
                             p_description => ' ');
       --
    END LOOP ;
    -- commit the changes so far
    commit;
  end loop;

  IF csr_get_candidates%ISOPEN THEN
	   CLOSE csr_get_candidates;
  END IF;

  hr_utility.set_location('Leaving'||l_proc, 80);
end create_grants;
--
end irc_grants_util;

/
