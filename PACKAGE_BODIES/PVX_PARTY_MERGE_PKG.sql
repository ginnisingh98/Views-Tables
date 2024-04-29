--------------------------------------------------------
--  DDL for Package Body PVX_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PVX_PARTY_MERGE_PKG" AS
/* $Header: pvxvmrgb.pls 120.7 2006/06/12 10:37:33 rdsharma ship $ */

-- Start of Comments
-- Package name     : PVX_PARTY_MERGE_PKG
-- Purpose          : Merges duplicate parties in PV tables. The

--
-- History
-- MM-DD-YYYY    NAME          MODIFICATIONS
-- 02-21-2001    ajchatto      added MERGE_PARTNER_ENTITY_ATTRIBUTES procedure to merge party
--
-- End of Comments


G_PROC_NAME        CONSTANT  VARCHAR2(30)  := 'PV_PARTY_MERGE_PKG';
G_USER_ID          CONSTANT  NUMBER(15)    := FND_GLOBAL.USER_ID;
G_LOGIN_ID         CONSTANT  NUMBER(15)    := FND_GLOBAL.LOGIN_ID;
G_PKG_NAME         CONSTANT VARCHAR2(30)   := 'PVX_PARTY_MERGE_PKG';


-- -----------------------------------------------------------------------------------
-- Use for inserting output messages to the message table.
-- -----------------------------------------------------------------------------------
PROCEDURE Debug(
   p_msg_string    IN VARCHAR2
);

PROCEDURE Set_Message(
    p_msg_level     IN      NUMBER,
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2,
    p_token1_value  IN      VARCHAR2,
    p_token2        IN      VARCHAR2 := NULL,
    p_token2_value  IN      VARCHAR2 := NULL,
    p_token3        IN      VARCHAR2 := NULL,
    p_token3_value  IN      VARCHAR2 := NULL
);



-- --------------------------------------------------------------------------
-- MERGE_REFERRALS_B
--
-- --------------------------------------------------------------------------
PROCEDURE MERGE_REFERRALS_B (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    p_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2)
IS
   l_api_name                   VARCHAR2(30) := 'MERGE_REFERRALS_B';
   l_msg_count                  NUMBER;
   l_msg_data                   VARCHAR2(4000);

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN
   Debug(G_PKG_NAME || '.' || l_api_name || ' starts: ' ||
         TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'));


   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   IF (p_from_fk_id = p_to_fk_id) THEN
      p_to_id := p_from_id;
      RETURN;
   END IF;

   IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
          -- ---------------------------------------------------------------
          -- Merge party (hz_parties)
          -- ---------------------------------------------------------------
          IF (p_parent_entity_name = 'HZ_PARTIES') THEN
             UPDATE pv_referrals_b
             SET    partner_id         = p_to_fk_id,
                    last_update_date   = SYSDATE,
                    last_updated_by    = G_USER_ID,
	            last_update_login  = G_LOGIN_ID
             WHERE  partner_id         = p_from_fk_id;

             UPDATE pv_referrals_b
             SET    customer_party_id  = p_to_fk_id,
                    last_update_date   = SYSDATE,
                    last_updated_by    = G_USER_ID,
	            last_update_login  = G_LOGIN_ID
             WHERE  customer_party_id  = p_from_fk_id;

          -- ---------------------------------------------------------------
          -- Merge party_sites (hz_party_sites)
          -- ---------------------------------------------------------------
          ELSIF (p_parent_entity_name = 'HZ_PARTY_SITES') THEN
             UPDATE pv_referrals_b
             SET    customer_party_site_id = p_to_fk_id,
                    last_update_date       = SYSDATE,
                    last_updated_by        = G_USER_ID,
	            last_update_login      = G_LOGIN_ID
             WHERE  customer_party_site_id = p_from_fk_id;

          -- ---------------------------------------------------------------
          -- Merge contact_points (hz_contact_points)
          -- ---------------------------------------------------------------
          ELSIF (p_parent_entity_name = 'HZ_CONTACT_POINTS') THEN
             UPDATE pv_referrals_b
             SET    customer_contact_party_id = p_to_fk_id,
                    last_update_date          = SYSDATE,
                    last_updated_by           = G_USER_ID,
	            last_update_login         = G_LOGIN_ID
             WHERE  customer_contact_party_id = p_from_fk_id;

          -- ---------------------------------------------------------------
          -- Merge org_contacts (hz_org_contacts)
          -- ---------------------------------------------------------------
          ELSIF (p_parent_entity_name = 'HZ_ORG_CONTACTS') THEN
             UPDATE pv_referrals_b
             SET    customer_org_contact_id = p_to_fk_id,
                    last_update_date        = SYSDATE,
                    last_updated_by         = G_USER_ID,
	            last_update_login       = G_LOGIN_ID
             WHERE  customer_org_contact_id = p_from_fk_id;
          END IF;

       EXCEPTION
          WHEN OTHERS THEN
             Debug(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
   END IF;

   Debug(G_PKG_NAME || '.' || l_api_name || ' ends: ' ||
         TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'));
END MERGE_REFERRALS_B;

-----------------------------------------------------------------------------
--Function to check if the party is a PV Partner
-----------------------------------------------------------------------------

FUNCTION IsPVPartner(p_party_id NUMBER)
return VARCHAR2
IS
    CURSOR IsPVPartner IS
    SELECT partner_party_id from pv_partner_profiles where
                        partner_party_id = p_party_id and
                        (status = 'A' OR STATUS = 'I');

    l_partner_party_id  number;

BEGIN
    OPEN  IsPVPartner;
    FETCH IsPVPartner into l_partner_party_id;
    if IsPVPartner%found then
        CLOSE IsPVPartner;
        return 'Y';
    else
        CLOSE IsPVPartner;
        return 'N';
    end if;

END;

-- --------------------------------------------------------------------------

-----------------------------------------------------------------------------
--Function to get the Internal Vendor PARTY_ID
-----------------------------------------------------------------------------

FUNCTION get_intVendorOrg(p_party_id NUMBER, p_partner_id NUMBER)
return NUMBER
IS

      CURSOR intVendOrg_csr(cv_party_id NUMBER, cv_partner_id NUMBER) IS
	SELECT hzr.object_id
	FROM pv_partner_profiles  ppp,
	     hz_relationships hzr
	WHERE ppp.partner_party_id = cv_party_id
	AND ppp.partner_id = cv_partner_id
	AND hzr.subject_id = ppp.partner_party_id
	AND hzr.party_id = ppp.partner_id
	AND hzr.subject_type = 'ORGANIZATION'
	AND hzr.subject_table_name = 'HZ_PARTIES'
	AND hzr.object_type = 'ORGANIZATION'
	AND hzr.object_table_name = 'HZ_PARTIES'
	AND hzr.relationship_code = 'PARTNER_OF' ;

    l_vendor_id  number;

BEGIN
    OPEN  intVendOrg_csr(p_party_id, p_partner_id);
    FETCH intVendOrg_csr into l_vendor_id;
    CLOSE intVendOrg_csr;

    return l_vendor_id;
END;

-- --------------------------------------------------------------------------

-- --------------------------------------------------------------------------
-- MERGE_PARTNER_PROFILES1
--
-- This is a blank API which does not do any updates.
-- --------------------------------------------------------------------------
PROCEDURE MERGE_PARTNER_PROFILES1 (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    p_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2)
IS
   l_api_name                   VARCHAR2(30) := 'MERGE_PARTNER_PROFILES1';
   l_msg_count                  NUMBER;
   l_msg_data                   VARCHAR2(4000);

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN
   Debug(G_PKG_NAME || '.' || l_api_name || ' starts: ' ||
         TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'));

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   Debug(G_PKG_NAME || '.' || l_api_name || ' ends: ' ||
         TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'));

      exception
         WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MSG_PUB.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                       p_count     =>  l_msg_count,
                                       p_data      =>  l_msg_data);

         when others then
	       fnd_message.set_name('AR','HZ_API_OTHERS_EXCEP');
               fnd_message.set_token('ERROR',SQLERRM);
               fnd_msg_pub.add;
               x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
	       raise;

END MERGE_PARTNER_PROFILES1;

-- --------------------------------------------------------------------------
-- MERGE_PARTNER_PROFILES2
-- --------------------------------------------------------------------------

PROCEDURE MERGE_PARTNER_PROFILES2 (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    p_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2)
IS
   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'MERGE_PARTNER_PROFILES2';
   l_msg_count                  NUMBER;
   l_msg_data                   VARCHAR2(4000);
   l_to_partner_id              NUMBER;
   l_exist                      NUMBER;

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

   -- ------------------------------------------------------------------
   -- These are the "from" records that are still "active" in
   -- hz_relationships. We don't need any that have been "merged."
   -- ------------------------------------------------------------------
   /* CURSOR c1 IS
      SELECT DISTINCT a.partner_profile_id, a.partner_party_id, b.party_id partner_id
      FROM   pv_partner_profiles a,
             hz_relationships    b
      WHERE  a.partner_party_id = p_from_fk_id AND
             a.partner_id = b.party_id AND
             b.relationship_code = 'PARTNER_OF' AND
             b.status = 'A'; */

   /**** Fixed the issue reported in bug # 5307731 by adding STATUS check **********/
      CURSOR c1 IS
            SELECT partner_profile_id, partner_party_id, partner_id
            FROM   pv_partner_profiles
            WHERE  partner_party_id = p_from_fk_id
	    AND status = 'A';

   /**** Fixed the issue reported in bug # 5307731 by adding STATUS check **********/
      CURSOR c2 IS
            SELECT partner_profile_id, partner_party_id, partner_id
            FROM   pv_partner_profiles
            WHERE  partner_party_id = p_to_fk_id
	    AND status = 'A';

BEGIN

   Debug(G_PKG_NAME || '.' || l_api_name || ' starts: ' ||
         TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'));

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   IF (p_from_fk_id = p_to_fk_id) THEN
      p_to_id := p_from_id;
      RETURN;
   END IF;

   -- -------------------------------------------------------------------
   -- We do not want to update partner_party_id of any records if the
   -- corresponding PARTNER_OF relationship has a status of 'M'. We are
   -- only interested in "active" ones.
   -- -------------------------------------------------------------------
  /* FOR x IN c1 LOOP
      UPDATE pv_partner_profiles
      SET    partner_party_id   = p_to_fk_id,
             last_update_date   = SYSDATE,
             last_updated_by    = G_USER_ID,
	     last_update_login  = G_LOGIN_ID
      WHERE  partner_profile_id = x.partner_profile_id;
   END LOOP; */


--PN Coding starts here
   if  IsPVPartner(p_from_fk_id) = 'Y' THEN
      if IsPVPartner(p_to_fk_id) = 'Y' THEN
      -- Update the status of the from to merged
           FOR x IN c1 LOOP
	       FOR y IN c2 LOOP
	         IF get_intVendorOrg(x.partner_party_id, x.partner_id) = get_intVendorOrg(y.partner_party_id, y.partner_id)
		 THEN
			UPDATE pv_partner_profiles
			SET    status   =  'M',
				last_update_date   = SYSDATE,
				last_updated_by    = G_USER_ID,
           			last_update_login  = G_LOGIN_ID
			WHERE  partner_profile_id = x.partner_profile_id;
		 ELSE

			UPDATE pv_partner_profiles
			SET    partner_party_id   =  p_to_fk_id,
				last_update_date   = SYSDATE,
				last_updated_by    = G_USER_ID,
           			last_update_login  = G_LOGIN_ID
			WHERE  partner_profile_id = x.partner_profile_id;
		 END IF;
               END LOOP;
	   END LOOP;
      else

      -- Update the party id of the partner to that of customer/Non PRM partner
           FOR x IN c1 LOOP
                 UPDATE pv_partner_profiles
                 SET    partner_party_id   =  p_to_fk_id,
                        last_update_date   = SYSDATE,
                        last_updated_by    = G_USER_ID,
           	        last_update_login  = G_LOGIN_ID
                 WHERE  partner_profile_id = x.partner_profile_id;
           END LOOP;
      end if;

   end if;

   -- --------------------------------------------------------
   -- Exception Handling
   -- --------------------------------------------------------
      exception
         WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MSG_PUB.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                       p_count     =>  l_msg_count,
                                       p_data      =>  l_msg_data);

         when others then
	       fnd_message.set_name('AR','HZ_API_OTHERS_EXCEP');
               fnd_message.set_token('ERROR',SQLERRM);
               fnd_msg_pub.add;
               x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
	       raise;

END MERGE_PARTNER_PROFILES2;



-- --------------------------------------------------------------------------
-- MERGE_PARTNER_ENTITY_ATTRS
--
-- This is a blank API which does not do any updates.
-- --------------------------------------------------------------------------
PROCEDURE MERGE_PARTNER_ENTITY_ATTRS (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    p_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2)
IS
   l_api_name                   VARCHAR2(30) := 'MERGE_PARTNER_PROFILES';

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN
   Debug(G_PKG_NAME || '.' || l_api_name || ' starts: ' ||
         TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'));

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   Debug(G_PKG_NAME || '.' || l_api_name || ' ends: ' ||
         TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'));

      exception
         when others then
	       fnd_message.set_name('AR','HZ_API_OTHERS_EXCEP');
               fnd_message.set_token('ERROR',SQLERRM);
               fnd_msg_pub.add;
               x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
	       raise;

END MERGE_PARTNER_ENTITY_ATTRS;


-- --------------------------------------------------------------------------
-- MERGE_LEAD_ASSIGNMENTS
-- --------------------------------------------------------------------------
PROCEDURE MERGE_LEAD_ASSIGNMENTS (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    p_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2)
IS
   cursor c1 is
   select 1
   from   PV_LEAD_ASSIGNMENTS
   where  partner_id = p_from_fk_id
   for    update nowait;


   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'MERGE_LEAD_ASSIGNMENTS';
   l_count                      NUMBER(10)   := 0;
   l_ppf_id			NUMBER := Null;

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN
   Debug(G_PKG_NAME || '.' || l_api_name || ' starts: ' ||
         TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'));

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

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
	 p_to_id := p_from_id;
      return;
   end if;

   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent. Before transferring check if a similar
   -- dependent record exists on the new parent. If a duplicate exists then do
   -- not transfer and return the id of the duplicate record as the Merged To Id


   IF p_from_fk_id <> p_to_fk_id THEN
      FOR x IN (SELECT DISTINCT partner_id
                FROM   pv_lead_assignments
		WHERE  partner_id = p_to_fk_id)
      LOOP
         p_to_id := x.partner_id;
      END LOOP;

      IF (p_to_id IS NULL) THEN
         FOR x IN (SELECT DISTINCT related_party_id
	           FROM   pv_lead_assignments
	           WHERE  related_party_id = p_to_fk_id)
         LOOP
	    p_to_id := x.related_party_id;
         END LOOP;
      END IF;

      UPDATE PV_LEAD_ASSIGNMENTS
      SET    partner_id         = p_to_fk_id,
	     last_update_date   = SYSDATE,
             last_updated_by    = G_USER_ID,
             last_update_login  = G_LOGIN_ID
      WHERE  partner_id         = p_from_fk_id;
   END IF;

   Debug(G_PKG_NAME || '.' || l_api_name || ' ends: ' ||
         TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'));


      exception
         when others then
	       fnd_message.set_name('AR','HZ_API_OTHERS_EXCEP');
               fnd_message.set_token('ERROR',SQLERRM);
               fnd_msg_pub.add;
               x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
	       raise;

END MERGE_LEAD_ASSIGNMENTS;


PROCEDURE MERGE_ASSIGNMENT_LOGS (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    p_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2)
IS
   cursor c1 is
   select 1
   from   PV_ASSIGNMENT_LOGS
   where  partner_id = p_from_fk_id
   for    update nowait;


   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'MERGE_ASSIGNMENT_LOGS';
   l_count                      NUMBER(10)   := 0;
   l_ppf_id			NUMBER := Null;

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN
   Debug(G_PKG_NAME || '.' || l_api_name || ' starts: ' ||
         TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'));

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

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
	 p_to_id := p_from_id;
      return;
   end if;

   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent. Before transferring check if a similar
   -- dependent record exists on the new parent. If a duplicate exists then do
   -- not transfer and return the id of the duplicate record as the Merged To Id


   if p_from_fk_id <> p_to_fk_id then

      begin
            select DISTINCT partner_id into l_ppf_id
            from   PV_ASSIGNMENT_LOGS
            where  partner_id = p_to_fk_id;
      exception
              When NO_DATA_FOUND then
               l_ppf_id := Null;
      end;


	 update PV_ASSIGNMENT_LOGS
	 set    partner_id          = decode(partner_id, p_from_fk_id, p_to_fk_id, partner_id),
	        last_update_date   = SYSDATE,
	        last_updated_by    = G_USER_ID,
	        last_update_login  = G_LOGIN_ID
	 where  partner_id          = p_from_fk_id;

         if l_ppf_id is not Null then
               p_to_id := l_ppf_id;
         end if;

     end if;

   Debug(G_PKG_NAME || '.' || l_api_name || ' ends: ' ||
         TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'));

      exception
         when others then
	       fnd_message.set_name('AR','HZ_API_OTHERS_EXCEP');
               fnd_message.set_token('ERROR',SQLERRM);
               fnd_msg_pub.add;
               x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
	       raise;

END MERGE_ASSIGNMENT_LOGS;


-- --------------------------------------------------------------------------
-- MERGE_SEARCH_ATTR_VALUES
--
-- This is a blank API which does not do any updates.
-- --------------------------------------------------------------------------
PROCEDURE MERGE_SEARCH_ATTR_VALUES (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    p_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2)
IS
   l_api_name                   VARCHAR2(30) := 'MERGE_SEARCH_ATTR_VALUES';

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN
   Debug(G_PKG_NAME || '.' || l_api_name || ' starts: ' ||
         TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'));

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   Debug(G_PKG_NAME || '.' || l_api_name || ' ends: ' ||
         TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'));

      exception
         when others then
	       fnd_message.set_name('AR','HZ_API_OTHERS_EXCEP');
               fnd_message.set_token('ERROR',SQLERRM);
               fnd_msg_pub.add;
               x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
	       raise;

END MERGE_SEARCH_ATTR_VALUES;


PROCEDURE MERGE_LEAD_PSS_LINES (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    p_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2)
IS
   cursor c1 is
   select 1
   from   PV_LEAD_PSS_LINES
   where  partner_id = p_from_fk_id
   for    update nowait;


   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'MERGE_LEAD_PSS_LINES';
   l_count                      NUMBER(10)   := 0;
   l_ppf_id			NUMBER := Null;

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN
   Debug(G_PKG_NAME || '.' || l_api_name || ' starts: ' ||
         TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'));

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

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
	 p_to_id := p_from_id;
      return;
   end if;

   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent. Before transferring check if a similar
   -- dependent record exists on the new parent. If a duplicate exists then do
   -- not transfer and return the id of the duplicate record as the Merged To Id


   if p_from_fk_id <> p_to_fk_id then

      begin
            select DISTINCT partner_id into l_ppf_id
            from   PV_LEAD_PSS_LINES
            where  partner_id = p_to_fk_id;
      exception
              When NO_DATA_FOUND then
               l_ppf_id := Null;
      end;


	 update PV_LEAD_PSS_LINES
	 set    partner_id          = decode(partner_id, p_from_fk_id, p_to_fk_id, partner_id),
	        last_update_date    = SYSDATE,
	        last_updated_by     = G_USER_ID,
	        last_update_login   = G_LOGIN_ID
         where  partner_id          = p_from_fk_id;

         if l_ppf_id is not Null then
               p_to_id := l_ppf_id;
         end if;

     end if;

   Debug(G_PKG_NAME || '.' || l_api_name || ' ends: ' ||
         TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'));


      exception
         when others then
	       fnd_message.set_name('AR','HZ_API_OTHERS_EXCEP');
               fnd_message.set_token('ERROR',SQLERRM);
               fnd_msg_pub.add;
               x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
	       raise;

END MERGE_LEAD_PSS_LINES;


PROCEDURE MERGE_GE_PARTY_NOTIFICATIONS (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    p_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2)
IS
   cursor c1 is
   select 1
   from   PV_GE_PARTY_NOTIFICATIONS
   where  partner_id = p_from_fk_id
   for    update nowait;


   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'MERGE_GE_PARTY_NOTIFICATIONS';
   l_count                      NUMBER(10)   := 0;
   l_ppf_id			NUMBER := Null;

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN
   Debug(G_PKG_NAME || '.' || l_api_name || ' starts: ' ||
         TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'));

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

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
	 p_to_id := p_from_id;
      return;
   end if;

   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent. Before transferring check if a similar
   -- dependent record exists on the new parent. If a duplicate exists then do
   -- not transfer and return the id of the duplicate record as the Merged To Id


   if p_from_fk_id <> p_to_fk_id then


          BEGIN
            SELECT DISTINCT partner_id INTO l_ppf_id
            FROM   PV_GE_PARTY_NOTIFICATIONS
            WHERE  partner_id = p_to_fk_id;
          EXCEPTION
              WHEN NO_DATA_FOUND THEN
               l_ppf_id := Null;
          END;



	 update PV_GE_PARTY_NOTIFICATIONS
	 set    partner_id          = p_to_fk_id,
	        last_update_date   = SYSDATE,
	        last_updated_by    = G_USER_ID,
	        last_update_login  = G_LOGIN_ID
	 where  partner_id          = p_from_fk_id;

         if l_ppf_id is not Null then
               p_to_id := l_ppf_id;
         end if;

     end if;

   Debug(G_PKG_NAME || '.' || l_api_name || ' ends: ' ||
         TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'));

      exception
         when others then
	       fnd_message.set_name('AR','HZ_API_OTHERS_EXCEP');
               fnd_message.set_token('ERROR',SQLERRM);
               fnd_msg_pub.add;
               x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
	       raise;

END MERGE_GE_PARTY_NOTIFICATIONS;

-- blank api
PROCEDURE MERGE_PG_ENRL_REQUESTS (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    p_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2)
IS
   cursor c1 is
   select 1
   from   PV_PG_ENRL_REQUESTS
   where  partner_id = p_from_fk_id
   for    update nowait;


   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'MERGE_PG_ENRL_REQUESTS';
   l_count                      NUMBER(10)   := 0;
   l_ppf_id			NUMBER := Null;

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN
   Debug(G_PKG_NAME || '.' || l_api_name || ' starts: ' ||
         TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'));

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
   -- needs to be done. Set Merged To Id is same as Merged From Id and return

   if p_from_fk_id = p_to_fk_id then
	 p_to_id := p_from_id;
      return;
   end if;


   Debug(G_PKG_NAME || '.' || l_api_name || ' ends: ' ||
         TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'));


      exception
         when others then
	       fnd_message.set_name('AR','HZ_API_OTHERS_EXCEP');
               fnd_message.set_token('ERROR',SQLERRM);
               fnd_msg_pub.add;
               x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
	       raise;

END MERGE_PG_ENRL_REQUESTS;


PROCEDURE MERGE_PG_MEMBERSHIPS (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    p_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2)
IS

   CURSOR memb_type_cur( p_ptr_id NUMBER)  IS
   SELECT attr_value
   FROM   pv_enty_attr_values
   WHERE  entity='PARTNER'
   AND    entity_id=p_ptr_id
   AND    attribute_id=6
   AND    latest_flag='Y';

   l_merge_reason_code          VARCHAR2(30);
   l_current_memb_type          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'MERGE_PG_MEMBERSHIPS';
   l_count                      NUMBER(10)   := 0;
   l_ppf_id			NUMBER := Null;
   l_msg_count                  NUMBER(10);
   l_msg_data                   VARCHAR2(2000);

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN
   Debug(G_PKG_NAME || '.' || l_api_name || ' starts: ' ||
         TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'));

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;


   -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
   -- needs to be done. Set Merged To Id is same as Merged From Id and return

   IF p_from_fk_id = p_to_fk_id THEN
	 p_to_id := p_from_id;
      return;
   END IF;


   IF p_from_fk_id <> p_to_fk_id THEN

       BEGIN
         SELECT DISTINCT partner_id INTO l_ppf_id
         FROM   PV_PG_MEMBERSHIPS
         WHERE  partner_id = p_to_fk_id;
       EXCEPTION
           WHEN NO_DATA_FOUND THEN
            l_ppf_id := Null;
       END;


      /*
      update PV_PG_MEMBERSHIPS
      set    partner_id          = p_to_fk_id,
             last_update_date   = SYSDATE,
             last_updated_by    = G_USER_ID,
             last_update_login  = G_LOGIN_ID
             where  partner_id          = p_from_fk_id;
      */

      /*

         PV_PG_MEMBERSHIPS_PVT.Terminate_ptr_memberships does the following
         1. Terminate all Active/future Program Memberships of partner and cancel incomplete and awaiting approvals enrollment requests
         2. also if partner is global,t will terminate subsidiary memberships and cancel the subsidiary incompelete and  awaiting approvals enrollment requests
      */

      OPEN memb_type_cur( p_from_fk_id );
         FETCH memb_type_cur INTO l_current_memb_type;
      CLOSE memb_type_cur;

      PV_PG_MEMBERSHIPS_PVT.Terminate_ptr_memberships
      (
          p_api_version_number            => 1.0
         ,p_init_msg_list                 => FND_API.G_FALSE
         ,p_commit                        => FND_API.G_FALSE
         ,p_validation_level              => FND_API.G_VALID_LEVEL_FULL
         ,p_partner_id                    => p_from_fk_id
         ,p_memb_type                     => l_current_memb_type
         ,p_status_reason_code            => 'PARTY_MERGE' -- seed PARTY_MERGE it validates against PV_MEMB_STATUS_REASON_CODE
         ,p_comments                      => null
         ,x_return_status                 => x_return_status
         ,x_msg_count                     => l_msg_count
         ,x_msg_data                      => l_msg_data
      );

     Debug(G_PKG_NAME || '.' || l_api_name || 'after Terminate_ptr_memberships API call : ' ||
         TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'));

      /*
         Pv_ptr_member_type_pvt.Register_term_ptr_memb_type does the following
         1. If Partner is Global, end date the global subsidiary relationship with all its subsidiaries
         2. If Partner is Subsdiary, end date the subsidiary-gloabl relationship with all its global
      */

      IF  l_current_memb_type IN ( 'GLOBAL', 'SUBSIDIARY' )  THEN
         Pv_ptr_member_type_pvt.Register_term_ptr_memb_type
         (
             p_api_version_number      => 1.0
            ,p_init_msg_list           => FND_API.G_FALSE
            ,p_commit                  => FND_API.G_FALSE
            ,p_validation_level        => FND_API.G_VALID_LEVEL_FULL
            ,p_partner_id              => p_from_fk_id
            ,p_current_memb_type       => l_current_memb_type
            ,p_new_memb_type           => null
            ,p_global_ptr_id           => null
            ,x_return_status           => x_return_status
            ,x_msg_count               => l_msg_count
            ,x_msg_data                => l_msg_data
         );
      END IF;

      IF l_ppf_id is not Null THEN
            p_to_id := l_ppf_id;
      END IF;

   END IF;

   Debug(G_PKG_NAME || '.' || l_api_name || ' ends: ' ||
         TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'));

      EXCEPTION
         WHEN OTHERS THEN
	       fnd_message.set_name('AR','HZ_API_OTHERS_EXCEP');
               fnd_message.set_token('ERROR',SQLERRM);
               fnd_msg_pub.add;
               x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
	       RAISE;

END MERGE_PG_MEMBERSHIPS;




--   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  MERGE_PARTNER_ACCESSES
   --   Purpose :  Merges partner_id in PV_PARTNER_ACCESSES   table
   --   Type    :  Private
   --   Pre-Req :  None.
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
   --   Version : Current version 1.0
   --
   --   End of Comments
   --

PROCEDURE MERGE_PARTNER_ACCESSES
(   p_entity_name             IN              VARCHAR2
   ,p_from_id                 IN              NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN              NUMBER
   ,p_to_fk_id                IN              NUMBER
   ,p_parent_entity_name      IN              VARCHAR2
   ,p_batch_id                IN              NUMBER
   ,p_batch_party_id          IN              NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
)
IS

  CURSOR c_get_pm_access_id (c_from_fk_id NUMBER, c_to_fk_id NUMBER) IS
      select partner_access_id from pv_partner_accesses a
      where partner_id= c_from_fk_id
      and exists (select null from pv_partner_accesses b
                  where partner_id = c_to_fk_id
		  and b.resource_id = a.resource_id );

  -- Cursor l_chng_partner_exist_csr.
  CURSOR l_chng_partner_exist_csr(cv_partner_id NUMBER) IS
    SELECT processed_flag, object_version_number
    FROM   pv_tap_batch_chg_partners
    WHERE  partner_id = cv_partner_id;

   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'MERGE_PARTNER_ACCESSES';
   l_count                      NUMBER(10)   := 0;
   l_ppf_id			NUMBER := Null;
   l_processed_flag             VARCHAR2(1);
   l_return_status		VARCHAR2(1);
   l_msg_count			NUMBER;
   l_msg_data			VARCHAR(2000);
   l_object_version		NUMBER;
   l_partner_id			NUMBER;

   l_batch_chg_prtnrs_rec PV_BATCH_CHG_PRTNR_PVT.Batch_Chg_Prtnrs_Rec_Type:= PV_BATCH_CHG_PRTNR_PVT.g_miss_Batch_Chg_Prtnrs_rec;


   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN
   FND_FILE.PUT_LINE(FND_FILE.LOG,'AS_TAP_MERGE_PKG.ACCESS_MERGE start : '
				  ||to_char(sysdate,'DD-MON-YYYY HH24:MI'));
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Entity: '||p_parent_entity_name);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'from_fk: '||p_from_fk_id);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'to_fk: '||p_to_fk_id);

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   select merge_reason_code into l_merge_reason_code
   from HZ_MERGE_BATCH
   where batch_id = p_batch_id;

   IF l_merge_reason_code = 'DUPLICATE' THEN
      -- *********************************************************************
      -- if reason code is duplicate then allow the party merge to happen
      -- without any validations.
      -- *********************************************************************
	 null;
   ELSE
      -- *********************************************************************
      -- if there are any validations to be done, include it in this section
      -- *********************************************************************
	 null;
   END IF;

   -- ************************************************************************
   -- If the parent has NOT changed (ie. Parent getting transferred) then
   -- nothing needs to be done. Set Merged To Id is same as Merged From Id
   -- and return
   -- ************************************************************************
   if p_from_fk_id = p_to_fk_id then
      p_to_id := p_from_id;
      return;
   end if;

   -- ************************************************************************
   -- If the parent has changed(ie. Parent is getting merged) then transfer
   -- the dependent record to the new parent. Before transferring check if a
   -- similar dependent record exists on the new parent. If a duplicate exists
   -- then do not transfer and return the id of the duplicate record as the
   -- Merged To Id
   -- ************************************************************************
   IF p_from_fk_id <> p_to_fk_id THEN
      BEGIN
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'Processing PV_PARTNER_ACCESSES Table');
          IF p_parent_entity_name = 'HZ_PARTIES' THEN
	     FOR I in  c_get_pm_access_id (p_from_fk_id, p_to_fk_id) LOOP
                  FND_FILE.PUT_LINE(FND_FILE.LOG,
                                    'Deleting  PARTY partner_access_id: '||I.partner_access_id);
                  DELETE FROM  pv_tap_access_terrs
                  WHERE partner_access_id = I.partner_access_id;

                  DELETE FROM pv_partner_accesses
                  WHERE partner_access_id = I.partner_access_id;
             END LOOP;

             -- merge party
             UPDATE PV_PARTNER_ACCESSES
             set object_version_number =  nvl(object_version_number,0) + 1,
                  partner_id = p_to_fk_id,
                  last_update_date = SYSDATE,
	          last_updated_by    = G_USER_ID,
	          last_update_login  = G_LOGIN_ID,
                  program_application_id=hz_utility_pub.program_application_id,
                  program_id = hz_utility_pub.program_id,
                  program_update_date = SYSDATE
             where partner_id = p_from_fk_id;

	     OPEN l_chng_partner_exist_csr(p_to_fk_id);
             FETCH l_chng_partner_exist_csr INTO l_processed_flag, l_object_version;
             l_batch_chg_prtnrs_rec.partner_id := p_to_fk_id;
             l_batch_chg_prtnrs_rec.processed_flag := 'P';
             IF l_chng_partner_exist_csr%NOTFOUND THEN

                CLOSE l_chng_partner_exist_csr;

                -- Call Channel_Team_Organization_Update to re-assign the Channel team
                PV_BATCH_CHG_PRTNR_PVT.Create_Batch_Chg_Partners(
                   p_api_version_number    => 1.0 ,
                   p_init_msg_list         => FND_API.G_FALSE,
                   p_commit                => FND_API.G_FALSE,
                   p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
                   x_return_status         => l_return_status,
                   x_msg_count             => l_msg_count,
                   x_msg_data              => l_msg_data,
                   p_batch_chg_prtnrs_rec  => l_batch_chg_prtnrs_rec,
                   x_partner_id            => l_partner_id );

		IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                         RAISE FND_API.G_EXC_ERROR;
                    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;
                END IF;
             ELSE
                  CLOSE l_chng_partner_exist_csr;
                  IF (l_processed_flag <> 'P') THEN
                      l_batch_chg_prtnrs_rec.object_version_number := l_object_version;
                      PV_BATCH_CHG_PRTNR_PVT.Update_Batch_Chg_Partners(
                         p_api_version_number    => 1.0
                         ,p_init_msg_list        => FND_API.G_FALSE
                         ,p_commit               => FND_API.G_FALSE
                         ,p_validation_level     => FND_API.G_VALID_LEVEL_FULL
                         ,x_return_status        => l_return_status
                         ,x_msg_count            => l_msg_count
                         ,x_msg_data             => l_msg_data
                         ,p_batch_chg_prtnrs_rec => l_batch_chg_prtnrs_rec);

                       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                             RAISE FND_API.G_EXC_ERROR;
                          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                             FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
                             FND_MESSAGE.SET_TOKEN('API_NAME', 'PV_BATCH_CHG_PRTNR_PVT.Update_Batch_Chg_Partners');
                             FND_MSG_PUB.Add;
                             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                          END IF;
                       END IF;
                  END IF; --l_processed_flag <> 'P'
              END IF;  -- l_chng_partner_exist_csr%NOTFOUND

  	  END IF; -- p_parent_entity_name = 'HZ_PARTIES'
       EXCEPTION
          WHEN OTHERS THEN
	       fnd_message.set_name('AR','HZ_API_OTHERS_EXCEP');
               fnd_message.set_token('ERROR',SQLERRM);
               fnd_msg_pub.add;
               x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
               raise;
       END;
    END IF; -- p_from_fk_id <> p_to_fk_id

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'PVX_PARTY_MERGE_PKG.MERGE_PARTNER_ACCESSES end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

 end MERGE_PARTNER_ACCESSES;


PROCEDURE MERGE_PV_GE_PTNR_RESPS (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    p_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2)
IS
   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'MERGE_PV_GE_PTNR_RESPS';
   l_msg_count		              NUMBER;
   l_msg_data		              VARCHAR(2000);

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN
   Debug(G_PKG_NAME || '.' || l_api_name || ' starts: ' ||
         TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'));

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   if p_from_fk_id = p_to_fk_id then
	 p_to_id := p_from_id;
      return;
   end if;

   Pv_User_Resp_Pvt.manage_merged_party_memb_resp(
       p_api_version_number         => 1.0
      ,p_init_msg_list              => FND_API.G_FALSE
      ,p_commit                     => FND_API.G_FALSE
      ,x_return_status              => x_return_status
      ,x_msg_count                  => l_msg_count
      ,x_msg_data                   => l_msg_data
      ,p_from_partner_id            => p_from_fk_id
      ,p_to_partner_id              => p_to_fk_id
   );
   IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   Debug(G_PKG_NAME || '.' || l_api_name || ' ends: ' ||
         TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'));

   -- --------------------------------------------------------
   -- Exception Handling
   -- --------------------------------------------------------
      exception
         WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MSG_PUB.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                       p_count     =>  l_msg_count,
                                       p_data      =>  l_msg_data);

         when others then
	       fnd_message.set_name('AR','HZ_API_OTHERS_EXCEP');
               fnd_message.set_token('ERROR',SQLERRM);
               fnd_msg_pub.add;
               x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
	       raise;
END MERGE_PV_GE_PTNR_RESPS;

PROCEDURE MERGE_CONTRACT_BINDING_CONTACT (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    p_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2
)
IS
   cursor c1 is
   select 1
   from   PV_PG_ENRL_REQUESTS
   where  partner_id = p_from_fk_id
   for    update nowait;


   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'MERGE_CONTRACT_BINDING_CONTACT';
   l_count                      NUMBER(10)   := 0;
   l_ppf_id			NUMBER := Null;

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN
   Debug(G_PKG_NAME || '.' || l_api_name || ' starts: ' ||
         TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'));

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

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
	 p_to_id := p_from_id;
      return;
   end if;

   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent. Before transferring check if a similar
   -- dependent record exists on the new parent. If a duplicate exists then do
   -- not transfer and return the id of the duplicate record as the Merged To Id


   if p_from_fk_id <> p_to_fk_id then


          BEGIN
            SELECT DISTINCT partner_id INTO l_ppf_id
            FROM   PV_PG_ENRL_REQUESTS
            WHERE  partner_id = p_to_fk_id;
          EXCEPTION
              WHEN NO_DATA_FOUND THEN
               l_ppf_id := Null;
          END;



	 update PV_PG_ENRL_REQUESTS
	 set    contract_binding_contact_id = p_to_fk_id,
	        last_update_date   = SYSDATE,
	        last_updated_by    = G_USER_ID,
	        last_update_login  = G_LOGIN_ID
	 where  contract_binding_contact_id = p_from_fk_id;

         if l_ppf_id is not Null then
               p_to_id := l_ppf_id;
         end if;

     end if;

   Debug(G_PKG_NAME || '.' || l_api_name || ' ends: ' ||
         TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'));

      exception
         when others then
	       fnd_message.set_name('AR','HZ_API_OTHERS_EXCEP');
               fnd_message.set_token('ERROR',SQLERRM);
               fnd_msg_pub.add;
               x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
	       raise;

END MERGE_CONTRACT_BINDING_CONTACT;

--=============================================================================+
--|  Private Procedure                                                         |
--|                                                                            |
--|    Debug                                                                   |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Debug(
   p_msg_string       IN VARCHAR2
)
IS
   l_count                  NUMBER;
   l_msg   VARCHAR2(2000);

BEGIN
   FND_MESSAGE.Set_Name('PV', 'PV_DEBUG_MESSAGE');
   FND_MESSAGE.Set_Token('TEXT', p_msg_string);
   FND_MSG_PUB.Add;

   l_count := FND_MSG_PUB.count_msg;

   FOR l_cnt IN 1 .. l_count LOOP
      l_msg := FND_MSG_PUB.get(l_cnt, FND_API.g_false);
      FND_FILE.PUT_LINE(FND_FILE.LOG, '(' || l_cnt || ') ' || l_msg);
   END LOOP;
END Debug;


--=============================================================================+
--|  Private Procedure                                                         |
--|                                                                            |
--|    Set_Message                                                             |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Set_Message(
    p_msg_level     IN      NUMBER,
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2,
    p_token1_value  IN      VARCHAR2,
    p_token2        IN      VARCHAR2 := NULL ,
    p_token2_value  IN      VARCHAR2 := NULL,
    p_token3        IN      VARCHAR2 := NULL,
    p_token3_value  IN      VARCHAR2 := NULL
)
IS
   l_count                  NUMBER;
   l_msg   VARCHAR2(2000);

BEGIN
   FND_MESSAGE.Set_Name('PV', p_msg_name);
   FND_MESSAGE.Set_Token(p_token1, p_token1_value);

   IF (p_token2 IS NOT NULL) THEN
      FND_MESSAGE.Set_Token(p_token2, p_token2_value);
   END IF;

   IF (p_token3 IS NOT NULL) THEN
      FND_MESSAGE.Set_Token(p_token3, p_token3_value);
   END IF;

   FND_MSG_PUB.Add;

   l_count := FND_MSG_PUB.count_msg;

   FOR l_cnt IN 1 .. l_count LOOP
      l_msg := FND_MSG_PUB.get(l_cnt, FND_API.g_false);
      FND_FILE.PUT_LINE(FND_FILE.LOG, '(' || l_cnt || ') ' || l_msg);
   END LOOP;
END Set_Message;
-- ==============================End of Set_Message==============================

END PVX_PARTY_MERGE_PKG ;

/
