--------------------------------------------------------
--  DDL for Package Body CSI_ASSIGN_ROLE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_ASSIGN_ROLE_PUB" AS
-- $Header: csipuplb.pls 120.1 2006/01/11 14:17 epajaril noship $

PROCEDURE ROLE_ASSIGNMENT(
   x_errbuf        OUT nocopy varchar2,
   x_retcode       OUT nocopy number)  AS

   l_freeze_flag    VARCHAR2(1);

   CURSOR get_user IS
   SELECT  us.user_name, (
           select decode(count(*), 0, 'CSI_END_USER', 'CSI_NORMAL_USER')
           from   fnd_user_resp_groups fg, fnd_responsibility fr
           where  fg.user_id = us.user_id
           and    (fg.end_date is null or fg.end_date > sysdate)
           and    fr.responsibility_id = fg.responsibility_id
           and    fr.responsibility_key = 'ORACLE_SUPPORT'
           and    rownum = 1 ) user_type
   FROM    fnd_user us
   WHERE   (us.end_date is null or us.end_date > sysdate)
   AND     EXISTS (select /*+ no_unnest */ null
                   from   jtf_auth_principals_b p,
                          jtf_auth_principal_maps pr
                   where  p.principal_name = us.user_name
                   and    p.is_user_flag = 1
                   and    p.jtf_auth_principal_id = pr.jtf_auth_principal_id
                   and    exists (select /*+ no_unnest */ null
                                  from   jtf_auth_principals_b r
                                  where  pr.jtf_auth_parent_principal_id = r.jtf_auth_principal_id
                                  and    r.is_user_flag = 0
                                  and    r.principal_name like 'IBU%')
                   and    not exists (select /*+ no_unnest */ null
                                      from   jtf_auth_principals_b r
                                      where  pr.jtf_auth_parent_principal_id = r.jtf_auth_principal_id
                                      and r.is_user_flag = 0
                                      and r.principal_name like 'CSI%'));
BEGIN
   /* Check if the script will run or not */
   BEGIN
      SELECT nvl(freeze_flag,'N')
      INTO   l_freeze_flag
      FROM   csi_install_parameters;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_freeze_flag := 'N';
      WHEN TOO_MANY_ROWS THEN
         l_freeze_flag := 'Y';
   END;

   IF l_freeze_flag = 'Y' THEN
      RETURN;
   END IF;

   FOR get_user_rec in get_user LOOP
      IF get_user_rec.user_type = 'CSI_END_USER' THEN
         jtf_auth_bulkload_pkg.assign_role(get_user_rec.user_name,'CSI_END_USER');
      ELSIF get_user_rec.user_type = 'CSI_NORMAL_USER' THEN
         jtf_auth_bulkload_pkg.assign_role(get_user_rec.user_name,'CSI_NORMAL_USER');
      END IF;
   END LOOP;
   x_retcode := AD_CONC_UTILS_PKG.CONC_SUCCESS;
   COMMIT;
EXCEPTION
   WHEN OTHERS THEN
      x_retcode := AD_CONC_UTILS_PKG.CONC_FAIL;
      raise;
END;

END CSI_ASSIGN_ROLE_PUB;

/
