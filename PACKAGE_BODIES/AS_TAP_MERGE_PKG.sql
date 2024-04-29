--------------------------------------------------------
--  DDL for Package Body AS_TAP_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_TAP_MERGE_PKG" as
/* $Header: asxpmteb.pls 120.1.12010000.4 2010/03/09 12:26:12 sariff ship $ */
--
-- NAME
-- AS_TAP_MERGE_PKG
--
-- HISTORY
--
 G_PKG_NAME      CONSTANT VARCHAR2(30):='AS_TAP_MERGE_PKG';

PROCEDURE ACCESS_MERGE
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2)
IS
  l_api_name            CONSTANT VARCHAR2(30) := 'ACCESS_MERGE';
  l_api_version_number  CONSTANT NUMBER       := 2.0;
  l_merge_reason_code   VARCHAR2(30);

  -- added for bug 6431278/6455932
  salesforce_id_null	EXCEPTION;
  PRAGMA EXCEPTION_INIT (salesforce_id_null, -01407);

  CURSOR c_get_pm_access_id (c_from_fk_id NUMBER, c_to_fk_id NUMBER) IS
      select access_id from as_accesses_all a
      where customer_id= c_from_fk_id
      and exists (select null from as_accesses_all b
                  where customer_id =c_to_fk_id
                  and (b.lead_id = a.lead_id or
                      (b.lead_id is null and a.lead_id is null))
                  and (b.org_id =a.org_id or
                      (b.org_id is null and a.org_id is null))
                  and (b.salesforce_id =a.salesforce_id or
                      (b.salesforce_id is null and a.salesforce_id is null))
                  and (b.sales_lead_id =a.sales_lead_id or
                      (b.sales_lead_id is null and a.sales_lead_id is null))
                  and (b.sales_group_id = a.sales_group_id or
                     (b.sales_group_id is null and a.sales_group_id is null)));

  CURSOR c_get_psm_access_id (c_from_fk_id NUMBER, c_to_fk_id NUMBER) IS
      select access_id
      from as_accesses_all b
      where b.address_id = c_from_fk_id
        and b.customer_id in
            (select customer_id
             from as_accesses_all c
             where (c.address_id = c_to_fk_id or
                    (b.address_id is null and c.address_id is null))
               and (b.lead_id = c.lead_id or
                    (b.lead_id is null and c.lead_id is null))
               and (b.org_id =c.org_id or
                    (b.org_id is null and c.org_id is null))
               and (b.salesforce_id =c.salesforce_id or
                    (b.salesforce_id is null and c.salesforce_id is null))
               and (b.sales_lead_id =c.sales_lead_id or
                    (b.sales_lead_id is null and c.sales_lead_id is null))
               and (b.sales_group_id = c.sales_group_id or
                    (b.sales_group_id is null and c.sales_group_id is null)));

BEGIN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'AS_TAP_MERGE_PKG.ACCESS_MERGE start : '
				  ||to_char(sysdate,'DD-MON-YYYY HH24:MI'));
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Entity: '||p_parent_entity_name);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'from_fk: '||p_from_fk_id);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'to_fk: '||p_to_fk_id);

    x_return_status := FND_API.G_RET_STS_SUCCESS;

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

    -- ************************************************************************
    -- Add your own logic if you need to take care of the following cases
    -- Check the if record duplicate if change party_id from merge-from
    -- to merge-to id.  E.g. : in AS_ACCESSES_ALL, if you have the following
    -- situation
    --
    -- customer_id    address_id     contact_id
    -- ===========    ==========     ==========
    --   1200           1100
    --   1300           1400
    --
    -- if p_from_fk_id = 1200, p_to_fk_id = 1300 for customer_id
    --    p_from_fk_id = 1100, p_to_fk_id = 1400 for address_id
    -- therefore, if changing 1200 to 1300 (customer_id)
    -- and 1100 to 1400 (address_id), then it will cause unique
    -- key violation assume that all other fields are the same
    -- So, please check if you need to check for record duplication
    -- ************************************************************************

    IF p_from_fk_id <> p_to_fk_id THEN
      BEGIN
          IF p_parent_entity_name = 'HZ_PARTIES' THEN
              FOR I in  c_get_pm_access_id (p_from_fk_id, p_to_fk_id) LOOP
                  FND_FILE.PUT_LINE(FND_FILE.LOG,
                                    'Deleting  PARTY access_id: '||I.access_id);
                  DELETE FROM as_territory_accesses
                  WHERE access_id = I.access_id;

                  DELETE FROM as_accesses_all
                  WHERE access_id = I.access_id;
              END LOOP;

              -- merge party
              UPDATE AS_ACCESSES_ALL
              set object_version_number =  nvl(object_version_number,0) + 1,
                  customer_id = p_to_fk_id,
                  last_update_date = hz_utility_pub.last_update_date,
                  last_updated_by = hz_utility_pub.user_id,
                  last_update_login = hz_utility_pub.last_update_login,
                  program_application_id=hz_utility_pub.program_application_id,
                  program_id = hz_utility_pub.program_id,
                  program_update_date = sysdate
              where customer_id = p_from_fk_id;

              -- ffang 012204, bug 3395366, party merge for partners
              -- party merge for partner_customer_id
	      -- Exception clause is added for bug 6431278/6455932
	     Begin
              UPDATE AS_ACCESSES_ALL
              set partner_customer_id = p_to_fk_id,
	      salesforce_id=( select resource_id
	                        from jtf_rs_resource_extns
				where category = 'PARTNER'
				and source_id = p_to_fk_id),
                  last_update_date = hz_utility_pub.last_update_date,
                  last_updated_by = hz_utility_pub.user_id,
                  last_update_login = hz_utility_pub.last_update_login,
                  program_application_id=hz_utility_pub.program_application_id,
                  program_id = hz_utility_pub.program_id,
                  program_update_date = sysdate
              where partner_customer_id = p_from_fk_id;
	     Exception
	         when salesforce_id_null then
		       FND_FILE.PUT_LINE(FND_FILE.LOG,'At exception: '||sqlerrm);
		    UPDATE AS_ACCESSES_ALL
	                set partner_customer_id = p_to_fk_id,
		        last_update_date = hz_utility_pub.last_update_date,
			last_updated_by = hz_utility_pub.user_id,
			last_update_login = hz_utility_pub.last_update_login,
                        program_application_id=hz_utility_pub.program_application_id,
			program_id = hz_utility_pub.program_id,
			program_update_date = sysdate
		     where partner_customer_id = p_from_fk_id;
	     End;

              -- party merge for partner_cont_party_id
              UPDATE AS_ACCESSES_ALL
              set partner_cont_party_id = p_to_fk_id,
                  last_update_date = hz_utility_pub.last_update_date,
                  last_updated_by = hz_utility_pub.user_id,
                  last_update_login = hz_utility_pub.last_update_login,
                  program_application_id=hz_utility_pub.program_application_id,
                  program_id = hz_utility_pub.program_id,
                  program_update_date = sysdate
              where partner_cont_party_id = p_from_fk_id;
              -- end ffang 012204, bug 3395366

        ELSIF p_parent_entity_name = 'HZ_PARTY_SITES' THEN  -- merge party_site

              -- delete duplicate records (which will violate unique constraint)
              FOR I in  c_get_psm_access_id (p_from_fk_id, p_to_fk_id) LOOP
                  FND_FILE.PUT_LINE(FND_FILE.LOG,
                              'Deleting PARTY SITE access_id: '||I.access_id);
                  DELETE FROM as_territory_accesses
                  WHERE access_id = I.access_id;

                  DELETE FROM as_accesses_all
                  WHERE access_id = I.access_id;
              END LOOP;

-- The following statement will not update records if parties are merged
-- before party sites. As per TCA design docs, party sites are always
-- merged before parties. The subquery is to prevent updating new customer.

              -- merge party site
              UPDATE AS_ACCESSES_ALL
              set object_version_number =  nvl(object_version_number,0) + 1,
                  address_id = p_to_fk_id,
                  last_update_date = hz_utility_pub.last_update_date,
                  last_updated_by = hz_utility_pub.user_id,
                  last_update_login = hz_utility_pub.last_update_login,
                  program_application_id=hz_utility_pub.program_application_id,
                  program_id = hz_utility_pub.program_id,
                  program_update_date = sysdate
              where address_id = p_from_fk_id;

              -- ffang 012204, bug 3395366, party merge for partners
              -- party merge for partner_address_id
              UPDATE AS_ACCESSES_ALL
              set partner_address_id = p_to_fk_id,
                  last_update_date = hz_utility_pub.last_update_date,
                  last_updated_by = hz_utility_pub.user_id,
                  last_update_login = hz_utility_pub.last_update_login,
                  program_application_id=hz_utility_pub.program_application_id,
                  program_id = hz_utility_pub.program_id,
                  program_update_date = sysdate
              where partner_address_id = p_from_fk_id;
              -- end ffang 012204, bug 3395366

	  END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': '
                                  ||p_parent_entity_name|| sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'AS_TAP_MERGE_PKG .ACCESS_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

end;

PROCEDURE TAP_MERGE
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
)is
l_api_name            CONSTANT VARCHAR2(30) := 'TAP_MERGE';
  l_api_version_number  CONSTANT NUMBER       := 2.0;
  l_merge_reason_code   VARCHAR2(30);
begin
FND_FILE.PUT_LINE(FND_FILE.LOG,'AS_TAP_MERGE_PKG .TAP_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    select merge_reason_code into l_merge_reason_code
    from HZ_MERGE_BATCH
    where batch_id = p_batch_id;

    IF l_merge_reason_code = 'DUPLICATE' THEN
       -- ***************************************************************************
       -- if reason code is duplicate then allow the party merge to happen without
       -- any validations.
       -- ***************************************************************************
	  null;
    ELSE
       -- ***************************************************************************
       -- if there are any validations to be done, include it in this section
       -- ***************************************************************************
	  null;
    END IF;

    -- ***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    -- ***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;

    -- ***************************************************************************
    -- If the parent has changed(ie. Parent is getting merged) then transfer the
    -- dependent record to the new parent. Before transferring check if a similar
    -- dependent record exists on the new parent. If a duplicate exists then do
    -- not transfer and return the id of the duplicate record as the Merged To Id
    -- ***************************************************************************

    -- ***************************************************************************
    -- Add your own logic if you need to take care of the following cases
    -- Check the if record duplicate if change party_id from merge-from
    -- to merge-to id.  E.g. : in AS_ACCESSES_ALL, if you have the following
    -- situation
    --
    -- customer_id    address_id     contact_id
    -- ===========    ==========     ==========
    --   1200           1100
    --   1300           1400
    --
    -- if p_from_fk_id = 1200, p_to_fk_id = 1300 for customer_id
    --    p_from_fk_id = 1100, p_to_fk_id = 1400 for address_id
    -- therefore, if changing 1200 to 1300 (customer_id)
    -- and 1100 to 1400 (address_id), then it will cause unique
    -- key violation assume that all other fields are the same
    -- So, please check if you need to check for record duplication
    -- ***************************************************************************

    IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
	     IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party
	   	  delete from as_changed_accounts_all
                  where customer_id = p_to_fk_id;

	   	   UPDATE AS_CHANGED_ACCOUNTS_ALL
		   set object_version_number = nvl(object_version_number,0) + 1,
                       customer_id = p_to_fk_id,
			  last_update_date = hz_utility_pub.last_update_date,
			  last_updated_by = hz_utility_pub.user_id,
			  last_update_login = hz_utility_pub.last_update_login,
			  program_application_id = hz_utility_pub.program_application_id,
			  program_id = hz_utility_pub.program_id,
			  program_update_date = sysdate
		   where customer_id = p_from_fk_id;


	     ELSif p_parent_entity_name = 'HZ_PARTY_SITES' THEN    -- merge party_site

		    delete from as_changed_accounts_all b
		    where b.address_id=p_from_fk_id
		    and b.customer_id in
		    (select customer_id
		     from as_changed_accounts_all c
		     where c.address_id=p_to_fk_id)  ;


		   UPDATE AS_CHANGED_ACCOUNTS_ALL
		   set object_version_number = nvl(object_version_number,0) + 1,
                       address_id = p_to_fk_id,
			  last_update_date = hz_utility_pub.last_update_date,
			  last_updated_by = hz_utility_pub.user_id,
			  last_update_login = hz_utility_pub.last_update_login,
			  program_application_id = hz_utility_pub.program_application_id,
			  program_id = hz_utility_pub.program_id,
			  program_update_date = sysdate
		   where address_id = p_from_fk_id
		   and customer_id not in(select customer_id from as_changed_accounts_all
		                       where address_id=p_to_fk_id) ;

	      END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'AS_TAP_MERGE_PKG .TAP_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

end;
END AS_TAP_MERGE_PKG;

/
