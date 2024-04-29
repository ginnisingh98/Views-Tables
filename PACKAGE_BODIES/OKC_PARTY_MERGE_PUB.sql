--------------------------------------------------------
--  DDL for Package Body OKC_PARTY_MERGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_PARTY_MERGE_PUB" AS
/* $Header: OKCPPMGB.pls 120.2.12010000.3 2009/03/04 09:38:27 spingali ship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

-- Start of Comments
-- API Name     :OKC_PARTY_MERGE_PUB
-- Type         :Public
-- Purpose      :Manage Party merges
--
-- NOTES
-- Merging Rules:
--   Account merges across parties, when the "duplicate" or source party
--   is referenced in a contract are not allowed.
--
--   Merges where the duplicate party is not referenced in a contract are
--   processed (account, site, site use).
--
--   Account merges within the same party are processed (account, site,
--   site use).
--
--   Site merges in the same account are processed (site, site use).
--
--   When merging Party ids are looked for in:
--      OKC_K_PARTY_ROLES
--      OKC_RULES
--      OKC_K_ITEMS
--      OKC_CONTACTS
--   For customer site merges, cust_acct_site_ids are looked for in:
--      OKC_K_PARTY_ROLES
--      OKC_RULES
--      OKC_K_ITEMS
--      OKC_CONTACTS
--   For customer site use merges, site_use_ids are looked for in:
--      OKC_K_PARTY_ROLES
--      OKC_RULES
--      OKC_K_ITEMS
--      OKC_CONTACTS
--
-- JTF Objects:
--   The merge depends upon the proper usages being set for the JTF objects used
--   as party roles, rules, and items.  These usages are as follows:
--          OKX_PARTY       This object is based on a view which returns the
--                          party_id as id1.
--          OKX_P_SITE      This object is based on a view which returns
--                          party_site_id as id1.
--          OKX_P_SITE_USE  This object is based on a view which returns
--                          party_site_use_id as id1.
--
-- To be defined in JTF: This code is define under OKX_PCONTACT
--
--          OKX_CONTACTS    This object is based on a view which returns
--                          site_use_id as id1.
--
-- Following JTF object usages are only applicable if its a Customer Merge
--
--          OKX_ACCOUNT     This object is based on a view which returns
--                          cust_account_id as id1.
--          OKX_C_SITE      This object is based on a view which returns
--                          cust_acct_site_id as id1.
--          OKX_C_SITE_USE  This object is based on a view which returns
--                          site_use_id as id1.
--   The usages are how the merge determines which jtot_object_codes are candidates
--   for the different types of merges.
--
--
-- End of comments


-- Global constants
  c_party          CONSTANT VARCHAR2(20) := 'OKX_PARTY';      -- HZ_PARTIES
  c_p_site         CONSTANT VARCHAR2(20) := 'OKX_P_SITE';     -- HZ_PARTY_SITES
  c_p_site_use     CONSTANT VARCHAR2(20) := 'OKX_P_SITE_USE'; -- HZ_PARTY_SITE_USES
--
  c_contact        CONSTANT VARCHAR2(20) := 'OKX_CONTACTS';   -- HZ_PARTIES
--
--  c_account        CONSTANT VARCHAR2(20) := 'OKX_ACCOUNT';    -- HZ_CUST_ACCOUNTS
--  c_c_site         CONSTANT VARCHAR2(20) := 'OKX_C_SITE';     -- HZ_CUST_ACCT_SITES_ALL
--  c_c_site_use     CONSTANT VARCHAR2(20) := 'OKX_C_SITE_USE'; -- HZ_CUST_SITE_USES_ALL
--
  G_PROC_NAME      CONSTANT  VARCHAR2(30)  := 'OKC_PARTY_MERGE_PUB';
  G_USER_ID        CONSTANT  NUMBER(15)    := FND_GLOBAL.USER_ID;
  G_LOGIN_ID       CONSTANT  NUMBER(15)    := FND_GLOBAL.LOGIN_ID;
 --   Parameters:
 --   IN - All IN parameters are REQUIRED.
 --     p_entity_name         VARCHAR2 - Name of the entity that is being merged
 --     p_from_id             NUMBER   - Id of the record that is being merged
 --     p_from_fk_id          NUMBER   - Id of the Old Parent
 --     p_to_fk_id            NUMBER   - Id of the New Parent
 --     p_parent_entity_name  VARCHAR2 - Parent entity name
 --     p_batch_id            NUMBER   - Id of the Batch
 --     p_batch_party_id      NUMBER   - Id of the batch and party record
 --   OUT:
 --     x_to_id               NUMBER   - Id of the record under the new parent
 --                                      that its merged to
 --     x_return_status       VARCHAR2 - Return the status of the procedure

--
-- Merge Procedure for OKC_K_PARTY_ROLES_B
--
PROCEDURE OKC_CPL_MERGE_PARTY (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2)
IS
--
   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'OKC_CPL_MERGE_PARTY';
   l_count                      NUMBER(10)   := 0;
   l_object_user_code           VARCHAR2(20);
   l_return_status              VARCHAR2(1);    -- Bug 2949149

   --npalepu added on 10-feb-2006 for bug # 5005475
   cursor l_get_cpl_ids_csr is
   select role1.id from_cpl_id, role2.id to_cpl_id
   from okc_k_party_roles_b role1,okc_k_party_roles_b role2
   where role1.cle_id = role2.cle_id
   and  role1.rle_code = role2.rle_code
   and  role1.jtot_object1_code = role2.jtot_object1_code
   and  role1.jtot_object1_code IN (SELECT ojt.object_code
                                    FROM jtf_objects_b ojt
                                         ,jtf_object_usages oue
                                    WHERE ojt.object_code      = oue.object_code
                                    AND oue.object_user_code   = l_object_user_code)
   and  role1.object1_id1 = to_char( p_from_fk_id)  /*added to_char() for bug7655288*/
   and  role2.object1_id1 =to_char( p_to_fk_id);

   TYPE l_CPL_ID IS TABLE OF okc_k_party_roles_b.id%TYPE INDEX BY BINARY_INTEGER;
   l_from_cpl_id l_CPL_ID;
   l_to_cpl_id l_CPL_ID;
   --end npalepu

BEGIN
--
   fnd_file.put_line(fnd_file.log, 'OKC_PARTY_MERGE_PKG.OKC_CPL_MERGE_PARTY');

   fnd_file.put_line(fnd_file.log, '******             PARAMETERS                          ****** ');
   fnd_file.put_line(fnd_file.log, 'p_entity_name :        '||p_entity_name);
   fnd_file.put_line(fnd_file.log, 'p_from_id :            '||p_from_id);
   fnd_file.put_line(fnd_file.log, 'p_from_fk_id :         '||p_from_fk_id);
   fnd_file.put_line(fnd_file.log, 'p_to_fk_id :           '||p_to_fk_id);
   fnd_file.put_line(fnd_file.log, 'p_parent_entity_name : '||p_parent_entity_name);
   fnd_file.put_line(fnd_file.log, 'p_batch_id :           '||p_batch_id);
   fnd_file.put_line(fnd_file.log, 'p_batch_party_id :     '||p_batch_party_id);
--
   arp_message.set_line('OKC_PARTY_MERGE_PKG.OKC_CPL_MERGE_PARTY()+');

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

--
--
  if p_parent_entity_name = 'HZ_PARTIES' then
    l_object_user_code := c_party;
  end if;
--

   fnd_file.put_line(fnd_file.log, 'l_object_user_code :     '||l_object_user_code);


--
   select merge_reason_code
   into   l_merge_reason_code
   from   hz_merge_batch
   where  batch_id  = p_batch_id;

   if l_merge_reason_code = 'DUPLICATE' then
	 -- if reason code is duplicate then allow the party merge to happen without
	 -- any validations.
	 null;
   else
	 -- if there are any validations to be done, include it in this section
	 null;
   end if;

   -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
   -- needs to be done. Set Merged To Id is same as Merged From Id and return

   if p_from_fk_id = p_to_fk_id then
	 x_to_id := p_from_id;
      return;
   end if;

   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent. Before transferring check if a similar
   -- dependent record exists on the new parent. If a duplicate exists then do
   -- not transfer and return the id of the duplicate record as the Merged To Id

   if p_from_fk_id <> p_to_fk_id then
--
     begin

       arp_message.set_name('AR','AR_UPDATING_TABLE');
       arp_message.set_token('TABLE_NAME','OKC_K_PARTY_ROLES',FALSE);
  fnd_file.put_line(fnd_file.log, 'Updating Table okc_k_party_roles_b');
--
--
-- Fix for bug 4105272 Insert into okc_k_vers_numbers_h
    INSERT INTO OKC_K_VERS_NUMBERS_H(
        chr_id,
        major_version,
        minor_version,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
    (SELECT
        chr_id,
        major_version,
        minor_version,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login
    FROM OKC_K_VERS_NUMBERS
    WHERE chr_id IN (select dnz_chr_id
                    from okc_k_party_roles_b kpr
                    where kpr.object1_id1 = to_char(p_from_fk_id)
                    AND kpr.jtot_object1_code IN
                        (SELECT ojt.object_code
                         FROM jtf_objects_b ojt
                              ,jtf_object_usages oue
                         WHERE ojt.object_code      = oue.object_code
                         AND oue.object_user_code = l_object_user_code)));
--
   UPDATE okc_k_vers_numbers ver
     SET  ver.minor_version         = ver.minor_version + 1
         ,ver.object_version_number = ver.object_version_number + 1
         ,ver.last_update_date      = SYSDATE
         ,ver.last_updated_by       = arp_standard.profile.user_id
         ,ver.last_update_login     = arp_standard.profile.last_update_login
   WHERE chr_id IN (select dnz_chr_id
                    from okc_k_party_roles_b kpr
                    where kpr.object1_id1 = to_char(p_from_fk_id)   -- added for Bug 3611998
                      AND kpr.jtot_object1_code IN (SELECT ojt.object_code
                                                    FROM jtf_objects_b ojt
                                                        ,jtf_object_usages oue
                                                    WHERE ojt.object_code      = oue.object_code
                                                      AND oue.object_user_code = l_object_user_code));

  --npalepu added on 10-feb-2006 for bug # 5005475
  l_count := sql%rowcount;

  fnd_file.put_line(fnd_file.log, 'No of Rows Updated :   '||l_count);
  arp_message.set_name('AR','AR_ROWS_UPDATED');
  arp_message.set_token('NUM_ROWS',to_char(l_count));

  OPEN l_get_cpl_ids_csr;
  LOOP
        FETCH l_get_cpl_ids_csr BULK COLLECT INTO l_from_cpl_id, l_to_cpl_id LIMIT 1000;

        -- nechatur for bug#5378426 added on 9/7/06
        EXIT WHEN l_from_cpl_id.COUNT <= 0 ;
	-- end nechatur

        fnd_file.put_line(fnd_file.log, 'Updating Table okc_contacts');

        FORALL i IN l_from_cpl_id.FIRST .. l_from_cpl_id.LAST
        UPDATE okc_contacts cntc
        SET cntc.cpl_id                = l_to_cpl_id(i)
           ,cntc.object_version_number = cntc.object_version_number + 1
           ,cntc.last_update_date      = SYSDATE
           ,cntc.last_updated_by       = arp_standard.profile.user_id
           ,cntc.last_update_login     = arp_standard.profile.last_update_login
        WHERE  cntc.cpl_id = l_from_cpl_id(i);

        l_count := sql%rowcount;
        fnd_file.put_line(fnd_file.log, 'No of Rows Updated :   '||l_count);
        arp_message.set_name('AR','AR_ROWS_UPDATED');
        arp_message.set_token('NUM_ROWS',to_char(l_count));

        fnd_file.put_line(fnd_file.log, 'Deleting Table OKC_K_PARTY_ROLES_TL');
        -- Delete party_roles_tl table to handle related party merge Bug # 4529376

        FORALL i IN l_from_cpl_id.FIRST .. l_from_cpl_id.LAST
        DELETE from okc_k_party_roles_tl rtl
        WHERE rtl.id = l_from_cpl_id(i);

        l_count := sql%rowcount;
        fnd_file.put_line(fnd_file.log, 'No of Rows Deleted :   '||l_count);

        fnd_file.put_line(fnd_file.log, 'Deleting Table OKC_K_PARTY_ROLES');
        -- Delete party_roles table to handle related party merge Bug # 4529376

        FORALL i IN l_from_cpl_id.FIRST .. l_from_cpl_id.LAST
        DELETE FROM okc_k_party_roles_B role1
        WHERE role1.id = l_from_cpl_id(i);

        l_count := sql%rowcount;
        fnd_file.put_line(fnd_file.log, 'No of Rows Deleted :   '||l_count);

	--nechatur added on 9/7/2006 for bug # 5378426
        l_from_cpl_id.DELETE;
        l_to_cpl_id.DELETE;
        --end nechatur

        Exit When l_get_cpl_ids_csr%NOTFound;

  END LOOP;
  CLOSE l_get_cpl_ids_csr;
  --end npalepu
--
--
 fnd_file.put_line(fnd_file.log, 'Updating Table okc_k_party_roles_b');
  UPDATE okc_k_party_roles_b kpr
     SET kpr.object1_id1           = p_to_fk_id
        ,kpr.object_version_number = kpr.object_version_number + 1
        ,kpr.last_update_date      = SYSDATE
        ,kpr.last_updated_by       = arp_standard.profile.user_id
        ,kpr.last_update_login     = arp_standard.profile.last_update_login
   WHERE kpr.object1_id1 = to_char(p_from_fk_id)
     AND kpr.jtot_object1_code IN (SELECT ojt.object_code
                                  FROM jtf_objects_b ojt
                                      ,jtf_object_usages oue
                                  WHERE ojt.object_code      = oue.object_code
                                    AND oue.object_user_code = l_object_user_code) ;

   l_count := sql%rowcount;
   fnd_file.put_line(fnd_file.log, 'No of Rows Updated :   '||l_count);
 --
 -- Bug 2949149 calling OKS procedure OKS_UPDATE_CONTRACT to update the short description
 --
 fnd_file.put_line(fnd_file.log, 'Before call to OKC_OKS_PUB.OKS_UPDATE_CONTRACT ');
 OKC_OKS_PUB.OKS_UPDATE_CONTRACT(p_from_id  => p_from_fk_id,
                                 p_to_id    => p_to_fk_id,
                                 x_return_status => l_return_status);

 IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
 ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
     RAISE OKC_API.G_EXCEPTION_ERROR;
 END IF;

--
-- Following where clause removed after update from TCA (02/09/2001)
--
--   WHERE kpr.object1_id1 = p_from_fk_id
--     AND kpr.jtot_object1_code IN (SELECT ojt.object_code
--                                  FROM jtf_objects_b ojt
--                                      ,jtf_object_usages oue
--                                  WHERE ojt.object_code      = oue.object_code
--                                    AND oue.object_user_code = l_object_user_code)
--
-- Reason: TCA calling routine will pass on the p_from_id as a parameter that holds the
-- primary key of entity being updated based on the WHERE clause defined in the
-- Party Merge Dictionary
--
  l_count := sql%rowcount;

  fnd_file.put_line(fnd_file.log, 'No of Rows Updated :   '||l_count);
  arp_message.set_name('AR','AR_ROWS_UPDATED');
  arp_message.set_token('NUM_ROWS',to_char(l_count));
--
  exception
    when OKC_API.G_EXCEPTION_ERROR THEN                        -- Bug 2949149
           arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || sqlerrm);
           fnd_file.put_line(fnd_file.log, g_proc_name||'.'||l_api_name||':'||sqlerrm);
           x_return_status :=  FND_API.G_RET_STS_ERROR;
    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN             -- Bug 2949149
          arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || sqlerrm);
          fnd_file.put_line(fnd_file.log, g_proc_name||'.'||l_api_name||':'||sqlerrm);
          x_return_status :=  FND_API.G_RET_STS_ERROR;
    when others then
          arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || sqlerrm);
--
	     fnd_file.put_line(fnd_file.log,(g_proc_name || '.' || l_api_name ||
	       'OKC_K_PARTY_ROLES  = ' ||l_object_user_code||'-'|| p_from_id));
--
          fnd_file.put_line(fnd_file.log, g_proc_name||'.'||l_api_name||':'||sqlerrm);
          x_return_status :=  FND_API.G_RET_STS_ERROR;
  end;
 end if;
END OKC_CPL_MERGE_PARTY;
--
-- Merge Procedure for OKC_RULES_B (OBJECT1_CODE)
--
PROCEDURE OKC_RUL_MERGE_PARTY_ID1 (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2)
IS
--
   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'OKC_RUL_MERGE_PARTY_ID1';
   l_count                      NUMBER(10)   := 0;
   l_object_user_code           VARCHAR2(20);
--
--
BEGIN
--
   fnd_file.put_line(fnd_file.log, 'OKC_PARTY_MERGE_PKG.OKC_RUL_MERGE_PARTY_ID1');

   fnd_file.put_line(fnd_file.log, '******             PARAMETERS                          ****** ');
   fnd_file.put_line(fnd_file.log, 'p_entity_name :        '||p_entity_name);
   fnd_file.put_line(fnd_file.log, 'p_from_id :            '||p_from_id);
   fnd_file.put_line(fnd_file.log, 'p_from_fk_id :         '||p_from_fk_id);
   fnd_file.put_line(fnd_file.log, 'p_to_fk_id :           '||p_to_fk_id);
   fnd_file.put_line(fnd_file.log, 'p_parent_entity_name : '||p_parent_entity_name);
   fnd_file.put_line(fnd_file.log, 'p_batch_id :           '||p_batch_id);
   fnd_file.put_line(fnd_file.log, 'p_batch_party_id :     '||p_batch_party_id);
--
   arp_message.set_line('OKC_PARTY_MERGE_PKG.OKC_RUL_MERGE_PARTY_ID1()+');

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

--
--
  if p_parent_entity_name    = 'HZ_PARTIES'              then l_object_user_code := c_party;
  elsif p_parent_entity_name = 'HZ_PARTY_SITE_USES'      then l_object_user_code := c_p_site_use;
  elsif p_parent_entity_name = 'HZ_PARTY_SITES'          then l_object_user_code := c_p_site;
  end if;
--

   fnd_file.put_line(fnd_file.log, 'l_object_user_code :     '||l_object_user_code);


--
   select merge_reason_code
   into   l_merge_reason_code
   from   hz_merge_batch
   where  batch_id  = p_batch_id;

   if l_merge_reason_code = 'DUPLICATE' then
	 -- if reason code is duplicate then allow the party merge to happen without
	 -- any validations.
	 null;
   else
	 -- if there are any validations to be done, include it in this section
	 null;
   end if;

   -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
   -- needs to be done. Set Merged To Id is same as Merged From Id and return

   if p_from_fk_id = p_to_fk_id then
	 x_to_id := p_from_id;
      return;
   end if;

   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent. Before transferring check if a similar
   -- dependent record exists on the new parent. If a duplicate exists then do
   -- not transfer and return the id of the duplicate record as the Merged To Id

   if p_from_fk_id <> p_to_fk_id then
      begin
  -- Rules ID1
       arp_message.set_name('AR','AR_UPDATING_TABLE');
       arp_message.set_token('TABLE_NAME','OKC_RULES_B.OBJECT1_ID1',FALSE);
  fnd_file.put_line(fnd_file.log, 'Updating Table okc_rules_b');
--
  UPDATE okc_rules_b rle
     SET rle.object1_id1 = p_to_fk_id
        ,rle.object_version_number = rle.object_version_number + 1
        ,rle.last_update_date      = SYSDATE
        ,rle.last_updated_by       = arp_standard.profile.user_id
        ,rle.last_update_login     = arp_standard.profile.last_update_login
--  WHERE rle.object1_id1 = p_from_fk_id
     WHERE rle.object1_id1 = to_char(p_from_fk_id)   -- for Bug#	6896186
    AND rle.jtot_object1_code IN (SELECT ojt.object_code
                                  FROM jtf_objects_b ojt
                                      ,jtf_object_usages oue
                                  WHERE ojt.object_code      = oue.object_code
                                    AND oue.object_user_code = l_object_user_code)
  ;
--
  l_count := sql%rowcount;

  fnd_file.put_line(fnd_file.log, 'No of Rows Updated :   '||l_count);
  arp_message.set_name('AR','AR_ROWS_UPDATED');
  arp_message.set_token('NUM_ROWS',to_char(l_count));
--
--
  exception
    when others then
          arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || sqlerrm);
--
	     fnd_file.put_line(fnd_file.log,(g_proc_name || '.' || l_api_name ||
	       'OKC_K_PARTY_ROLES for = ' ||l_object_user_code||'-'|| p_from_id));
--
          fnd_file.put_line(fnd_file.log, g_proc_name||'.'||l_api_name||':'||sqlerrm);
          x_return_status :=  FND_API.G_RET_STS_ERROR;
  end;
 end if;
END OKC_RUL_MERGE_PARTY_ID1;
--
--
-- Merge Procedure for OKC_RULES_B (OBJECT2_CODE)
--
PROCEDURE OKC_RUL_MERGE_PARTY_ID2 (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2)
IS
--
   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'OKC_RUL_MERGE_PARTY_ID2';
   l_count                      NUMBER(10)   := 0;
   l_object_user_code           VARCHAR2(20);
--
--
BEGIN
--
   fnd_file.put_line(fnd_file.log, 'OKC_PARTY_MERGE_PKG.OKC_RUL_MERGE_PARTY_ID2');

   fnd_file.put_line(fnd_file.log, '******             PARAMETERS                          ****** ');
   fnd_file.put_line(fnd_file.log, 'p_entity_name :        '||p_entity_name);
   fnd_file.put_line(fnd_file.log, 'p_from_id :            '||p_from_id);
   fnd_file.put_line(fnd_file.log, 'p_from_fk_id :         '||p_from_fk_id);
   fnd_file.put_line(fnd_file.log, 'p_to_fk_id :           '||p_to_fk_id);
   fnd_file.put_line(fnd_file.log, 'p_parent_entity_name : '||p_parent_entity_name);
   fnd_file.put_line(fnd_file.log, 'p_batch_id :           '||p_batch_id);
   fnd_file.put_line(fnd_file.log, 'p_batch_party_id :     '||p_batch_party_id);
--
   arp_message.set_line('OKC_PARTY_MERGE_PKG.OKC_RUL_MERGE_PARTY_ID2()+');

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

--
--
  if p_parent_entity_name    = 'HZ_PARTIES'              then l_object_user_code := c_party;
  elsif p_parent_entity_name = 'HZ_PARTY_SITE_USES'      then l_object_user_code := c_p_site_use;
  elsif p_parent_entity_name = 'HZ_PARTY_SITES'          then l_object_user_code := c_p_site;
  end if;
--

   fnd_file.put_line(fnd_file.log, 'l_object_user_code :     '||l_object_user_code);


--
   select merge_reason_code
   into   l_merge_reason_code
   from   hz_merge_batch
   where  batch_id  = p_batch_id;

   if l_merge_reason_code = 'DUPLICATE' then
	 -- if reason code is duplicate then allow the party merge to happen without
	 -- any validations.
	 null;
   else
	 -- if there are any validations to be done, include it in this section
	 null;
   end if;

   -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
   -- needs to be done. Set Merged To Id is same as Merged From Id and return

   if p_from_fk_id = p_to_fk_id then
	 x_to_id := p_from_id;
      return;
   end if;

   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent. Before transferring check if a similar
   -- dependent record exists on the new parent. If a duplicate exists then do
   -- not transfer and return the id of the duplicate record as the Merged To Id

   if p_from_fk_id <> p_to_fk_id then
      begin
  -- Rules ID1
       arp_message.set_name('AR','AR_UPDATING_TABLE');
       arp_message.set_token('TABLE_NAME','OKC_RULES_B.OBJECT1_ID1',FALSE);
  fnd_file.put_line(fnd_file.log, 'Updating Table okc_rules_b');
--
  UPDATE okc_rules_b rle
     SET rle.object2_id1 = p_to_fk_id
        ,rle.object_version_number = rle.object_version_number + 1
        ,rle.last_update_date      = SYSDATE
        ,rle.last_updated_by       = arp_standard.profile.user_id
        ,rle.last_update_login     = arp_standard.profile.last_update_login
--  WHERE rle.object2_id1 = p_from_fk_id
    WHERE rle.object2_id1 = to_char(p_from_fk_id)  -- For Bug# 6896186
    AND rle.jtot_object2_code IN (SELECT ojt.object_code
                                  FROM jtf_objects_b ojt
                                      ,jtf_object_usages oue
                                  WHERE ojt.object_code      = oue.object_code
                                    AND oue.object_user_code = l_object_user_code)
  ;
--
  l_count := sql%rowcount;

  fnd_file.put_line(fnd_file.log, 'No of Rows Updated :   '||l_count);
  arp_message.set_name('AR','AR_ROWS_UPDATED');
  arp_message.set_token('NUM_ROWS',to_char(l_count));
--
--
  exception
    when others then
          arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || sqlerrm);
--
	     fnd_file.put_line(fnd_file.log,(g_proc_name || '.' || l_api_name ||
	       'OKC_K_PARTY_ROLES for = ' ||l_object_user_code||'-'|| p_from_id));
--
          fnd_file.put_line(fnd_file.log, g_proc_name||'.'||l_api_name||':'||sqlerrm);
          x_return_status :=  FND_API.G_RET_STS_ERROR;
  end;
 end if;
END OKC_RUL_MERGE_PARTY_ID2;
--
-- Merge Procedure for OKC_RULES_B (OBJECT3_CODE)
--
PROCEDURE OKC_RUL_MERGE_PARTY_ID3 (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2)
IS
--
   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'OKC_RUL_MERGE_PARTY_ID3';
   l_count                      NUMBER(10)   := 0;
   l_object_user_code           VARCHAR2(20);
--
--
BEGIN
--
   fnd_file.put_line(fnd_file.log, 'OKC_PARTY_MERGE_PKG.OKC_RUL_MERGE_PARTY_ID3');

   fnd_file.put_line(fnd_file.log, '******             PARAMETERS                          ****** ');
   fnd_file.put_line(fnd_file.log, 'p_entity_name :        '||p_entity_name);
   fnd_file.put_line(fnd_file.log, 'p_from_id :            '||p_from_id);
   fnd_file.put_line(fnd_file.log, 'p_from_fk_id :         '||p_from_fk_id);
   fnd_file.put_line(fnd_file.log, 'p_to_fk_id :           '||p_to_fk_id);
   fnd_file.put_line(fnd_file.log, 'p_parent_entity_name : '||p_parent_entity_name);
   fnd_file.put_line(fnd_file.log, 'p_batch_id :           '||p_batch_id);
   fnd_file.put_line(fnd_file.log, 'p_batch_party_id :     '||p_batch_party_id);
--
   arp_message.set_line('OKC_PARTY_MERGE_PKG.OKC_RUL_MERGE_PARTY_ID3()+');

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;
--
--
  if p_parent_entity_name    = 'HZ_PARTIES'              then l_object_user_code := c_party;
  elsif p_parent_entity_name = 'HZ_PARTY_SITE_USES'      then l_object_user_code := c_p_site_use;
  elsif p_parent_entity_name = 'HZ_PARTY_SITES'          then l_object_user_code := c_p_site;
  end if;
--

   fnd_file.put_line(fnd_file.log, 'l_object_user_code :     '||l_object_user_code);


--
   select merge_reason_code
   into   l_merge_reason_code
   from   hz_merge_batch
   where  batch_id  = p_batch_id;

   if l_merge_reason_code = 'DUPLICATE' then
	 -- if reason code is duplicate then allow the party merge to happen without
	 -- any validations.
	 null;
   else
	 -- if there are any validations to be done, include it in this section
	 null;
   end if;

   -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
   -- needs to be done. Set Merged To Id is same as Merged From Id and return

   if p_from_fk_id = p_to_fk_id then
	 x_to_id := p_from_id;
      return;
   end if;

   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent. Before transferring check if a similar
   -- dependent record exists on the new parent. If a duplicate exists then do
   -- not transfer and return the id of the duplicate record as the Merged To Id

   if p_from_fk_id <> p_to_fk_id then
      begin
  -- Rules ID3
        arp_message.set_name('AR','AR_UPDATING_TABLE');
        arp_message.set_token('TABLE_NAME','OKC_RULES_B.OBJECT3_ID1',FALSE);
  fnd_file.put_line(fnd_file.log, 'Updating Table okc_rules_b');
--
  UPDATE okc_rules_b rle
     SET rle.object3_id1 = p_to_fk_id
        ,rle.object_version_number = rle.object_version_number + 1
        ,rle.last_update_date      = SYSDATE
        ,rle.last_updated_by       = arp_standard.profile.user_id
        ,rle.last_update_login     = arp_standard.profile.last_update_login
--  WHERE rle.object3_id1 = p_from_fk_id
     WHERE rle.object3_id1 = to_char(p_from_fk_id) -- For Bug# 6896186
    AND rle.jtot_object3_code IN (SELECT ojt.object_code
                                  FROM jtf_objects_b ojt
                                      ,jtf_object_usages oue
                                  WHERE ojt.object_code      = oue.object_code
                                    AND oue.object_user_code = l_object_user_code)
  ;

--
  l_count := sql%rowcount;

  fnd_file.put_line(fnd_file.log, 'No of Rows Updated :   '||l_count);
  arp_message.set_name('AR','AR_ROWS_UPDATED');
  arp_message.set_token('NUM_ROWS',to_char(l_count));
--
--
  exception
    when others then
          arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || sqlerrm);
--
	     fnd_file.put_line(fnd_file.log,(g_proc_name || '.' || l_api_name ||
	       'OKC_K_PARTY_ROLES for = ' ||l_object_user_code||'-'|| p_from_id));
--
          fnd_file.put_line(fnd_file.log, g_proc_name||'.'||l_api_name||':'||sqlerrm);
          x_return_status :=  FND_API.G_RET_STS_ERROR;
  end;
 end if;
END OKC_RUL_MERGE_PARTY_ID3;
--
-- Merge Procedure for OKC_K_ITEMS
--
PROCEDURE OKC_CIM_MERGE_PARTY (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2)
IS
--
   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'OKC_CIM_MERGE_PARTY';
   l_count                      NUMBER(10)   := 0;
   l_object_user_code           VARCHAR2(20);
--
BEGIN
--
   fnd_file.put_line(fnd_file.log, 'OKC_PARTY_MERGE_PKG.OKC_CIM_MERGE_PARTY');

   fnd_file.put_line(fnd_file.log, '******             PARAMETERS                          ****** ');
   fnd_file.put_line(fnd_file.log, 'p_entity_name :        '||p_entity_name);
   fnd_file.put_line(fnd_file.log, 'p_from_id :            '||p_from_id);
   fnd_file.put_line(fnd_file.log, 'p_from_fk_id :         '||p_from_fk_id);
   fnd_file.put_line(fnd_file.log, 'p_to_fk_id :           '||p_to_fk_id);
   fnd_file.put_line(fnd_file.log, 'p_parent_entity_name : '||p_parent_entity_name);
   fnd_file.put_line(fnd_file.log, 'p_batch_id :           '||p_batch_id);
   fnd_file.put_line(fnd_file.log, 'p_batch_party_id :     '||p_batch_party_id);
--
   arp_message.set_line('OKC_PARTY_MERGE_PKG.OKC_CIM_MERGE_PARTY()+');

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

--
--
  if p_parent_entity_name    = 'HZ_PARTIES'              then l_object_user_code := c_party;
  elsif p_parent_entity_name = 'HZ_PARTY_SITE_USES'      then l_object_user_code := c_p_site_use;
  elsif p_parent_entity_name = 'HZ_PARTY_SITES'          then l_object_user_code := c_p_site;
  end if;
--

   fnd_file.put_line(fnd_file.log, 'l_object_user_code :     '||l_object_user_code);


--
   select merge_reason_code
   into   l_merge_reason_code
   from   hz_merge_batch
   where  batch_id  = p_batch_id;

   if l_merge_reason_code = 'DUPLICATE' then
	 -- if reason code is duplicate then allow the party merge to happen without
	 -- any validations.
	 null;
   else
	 -- if there are any validations to be done, include it in this section
	 null;
   end if;

   -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
   -- needs to be done. Set Merged To Id is same as Merged From Id and return

   if p_from_fk_id = p_to_fk_id then
	 x_to_id := p_from_id;
      return;
   end if;

   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent. Before transferring check if a similar
   -- dependent record exists on the new parent. If a duplicate exists then do
   -- not transfer and return the id of the duplicate record as the Merged To Id

   if p_from_fk_id <> p_to_fk_id then
      begin
        arp_message.set_name('AR','AR_UPDATING_TABLE');
        arp_message.set_token('TABLE_NAME','OKC_K_ITEMS',FALSE);
  fnd_file.put_line(fnd_file.log, 'Updating Table okc_k_items');
--
--
  UPDATE okc_k_items cim
  SET cim.object1_id1 = p_to_fk_id
     ,cim.object_version_number = cim.object_version_number + 1
     ,cim.last_update_date      = SYSDATE
     ,cim.last_updated_by       = arp_standard.profile.user_id
     ,cim.last_update_login     = arp_standard.profile.last_update_login
  WHERE cim.object1_id1 = p_from_fk_id
    AND cim.jtot_object1_code IN (SELECT ojt.object_code
                                  FROM jtf_objects_b ojt
                                      ,jtf_object_usages oue
                                  WHERE ojt.object_code      = oue.object_code
                                    AND oue.object_user_code = l_object_user_code)
  ;
--
--
  l_count := sql%rowcount;

  fnd_file.put_line(fnd_file.log, 'No of Rows Updated :   '||l_count);
  arp_message.set_name('AR','AR_ROWS_UPDATED');
  arp_message.set_token('NUM_ROWS',to_char(l_count));
--
  exception
    when others then
          arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || sqlerrm);
--
	     fnd_file.put_line(fnd_file.log,(g_proc_name || '.' || l_api_name ||
	       'OKC_K_PARTY_ROLES for = ' ||l_object_user_code||'-'|| p_from_id));
--
          fnd_file.put_line(fnd_file.log, g_proc_name||'.'||l_api_name||':'||sqlerrm);
          x_return_status :=  FND_API.G_RET_STS_ERROR;
  end;
 end if;
END OKC_CIM_MERGE_PARTY;
--
-- Merge procedure for OKC_CONTACTS
--
PROCEDURE OKC_CTC_MERGE_PARTY (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2)
IS
--
   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'OKC_CTC_MERGE_PARTY';
   l_count                      NUMBER(10)   := 0;
   l_object_user_code           VARCHAR2(20);
--
BEGIN
--
   fnd_file.put_line(fnd_file.log, 'OKC_PARTY_MERGE_PKG.OKC_CTC_MERGE_PARTY');

   fnd_file.put_line(fnd_file.log, '******             PARAMETERS                          ****** ');
   fnd_file.put_line(fnd_file.log, 'p_entity_name :        '||p_entity_name);
   fnd_file.put_line(fnd_file.log, 'p_from_id :            '||p_from_id);
   fnd_file.put_line(fnd_file.log, 'p_from_fk_id :         '||p_from_fk_id);
   fnd_file.put_line(fnd_file.log, 'p_to_fk_id :           '||p_to_fk_id);
   fnd_file.put_line(fnd_file.log, 'p_parent_entity_name : '||p_parent_entity_name);
   fnd_file.put_line(fnd_file.log, 'p_batch_id :           '||p_batch_id);
   fnd_file.put_line(fnd_file.log, 'p_batch_party_id :     '||p_batch_party_id);
--
   arp_message.set_line('OKC_PARTY_MERGE_PKG.OKC_CTC_MERGE_PARTY()+');

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

--
--
  if p_parent_entity_name    = 'HZ_PARTIES'              then l_object_user_code := c_contact;
  end if;
--

   fnd_file.put_line(fnd_file.log, 'l_object_user_code :     '||l_object_user_code);


--
   select merge_reason_code
   into   l_merge_reason_code
   from   hz_merge_batch
   where  batch_id  = p_batch_id;

   if l_merge_reason_code = 'DUPLICATE' then
	 -- if reason code is duplicate then allow the party merge to happen without
	 -- any validations.
	 null;
   else
	 -- if there are any validations to be done, include it in this section
	 null;
   end if;

   -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
   -- needs to be done. Set Merged To Id is same as Merged From Id and return

   if p_from_fk_id = p_to_fk_id then
	 x_to_id := p_from_id;
      return;
   end if;

   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent. Before transferring check if a similar
   -- dependent record exists on the new parent. If a duplicate exists then do
   -- not transfer and return the id of the duplicate record as the Merged To Id

   if p_from_fk_id <> p_to_fk_id then
      begin
        arp_message.set_name('AR','AR_UPDATING_TABLE');
        arp_message.set_token('TABLE_NAME','OKC_CONTACTS',FALSE);
  fnd_file.put_line(fnd_file.log, 'Updating Table okc_contacts');
--
--
  UPDATE okc_contacts ctc
  SET ctc.object1_id1 = p_to_fk_id
     ,ctc.object_version_number = ctc.object_version_number + 1
     ,ctc.last_update_date      = SYSDATE
     ,ctc.last_updated_by       = arp_standard.profile.user_id
     ,ctc.last_update_login     = arp_standard.profile.last_update_login
  WHERE ctc.object1_id1 = to_char(p_from_fk_id)
    AND ctc.jtot_object1_code IN (SELECT ojt.object_code
                                  FROM jtf_objects_b ojt
                                      ,jtf_object_usages oue
                                  WHERE ojt.object_code      = oue.object_code
                                    AND oue.object_user_code = l_object_user_code)
  ;
--
-- Following where clause removed after update from TCA (02/09/2001)
--
--WHERE ctc.object1_id1 = p_from_fk_id
--AND ctc.jtot_object1_code IN (SELECT ojt.object_code
--                                FROM jtf_objects_b ojt
--                                      ,jtf_object_usages oue
--                                  WHERE ojt.object_code      = oue.object_code
--                                    AND oue.object_user_code = l_object_user_code)
--
  l_count := sql%rowcount;

  fnd_file.put_line(fnd_file.log, 'No of Rows Updated :   '||l_count);
  arp_message.set_name('AR','AR_ROWS_UPDATED');
  arp_message.set_token('NUM_ROWS',to_char(l_count));
--
  exception
    when others then
          arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || sqlerrm);
--
	     fnd_file.put_line(fnd_file.log,(g_proc_name || '.' || l_api_name ||
	       'OKC_K_PARTY_ROLES for = ' ||l_object_user_code||'-'|| p_from_id));
--
          fnd_file.put_line(fnd_file.log, g_proc_name||'.'||l_api_name||':'||sqlerrm);
          x_return_status :=  FND_API.G_RET_STS_ERROR;
  end;
 end if;
END OKC_CTC_MERGE_PARTY;
--
--
END; -- Package Body OKC_PARTY_MERGE_PUB

/
