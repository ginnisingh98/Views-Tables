--------------------------------------------------------
--  DDL for Package Body AS_JTF_RS_GROUP_MEM_TRG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_JTF_RS_GROUP_MEM_TRG" as
/* $Header: asxrstgb.pls 120.1 2005/12/22 22:54:09 subabu noship $ */
--
--
-- HISTORY
-- 11/17/00	ACNG     	Created
-- 03/19/01    ACNG      Add logic to move sales group info
--                       only if sales leads/opp is in open status
-- 03/20/01    ACNG      Put profile options in order to move
--                       opp/lead in open only/other status

-- NOTE
-- If a resource is moved from one group to another group
-- a record will be written into JTF_RS_GROUP_MEMBERS_AUD
-- The record will have new_resource_id, null old_resource_id,
-- new_group_id and old_group_id.
--
-- Only two options available for the profile
-- 1) AS_MOVE_OPPORTUNITIES : Open/All
-- 2) AS_MOVE_SALES_LEADS   : Open/All
--

PROCEDURE Group_Mem_Trigger_Handler(
               x_group_member_id  NUMBER,
               x_new_group_id     NUMBER,
               x_old_group_id     NUMBER,
               x_new_resource_id  NUMBER,
               x_old_resource_id  NUMBER,
               Trigger_Mode       VARCHAR2 ) IS

   l_opp_profile VARCHAR2(50);
   l_lead_profile VARCHAR2(50);

   l_forecast_id NUMBER := null;

   CURSOR get_forecasts (sg_id number, sf_id number) IS
     SELECT forecast_id
       FROM as_internal_forecasts
      WHERE sales_group_id = sg_id
        AND salesforce_id = sf_id
        AND status_code = 'SUBMITTED'
        AND end_date_active is null;
BEGIN

   l_opp_profile := upper(ltrim(rtrim(nvl(FND_PROFILE.Value('AS_MOVE_OPPORTUNITIES'),'OPEN'))));
   l_lead_profile := upper(ltrim(rtrim(nvl(FND_PROFILE.Value('AS_MOVE_SALES_LEADS'),'OPEN'))));

   IF(Trigger_Mode = 'ON-INSERT') THEN

     IF(x_old_resource_id is null AND
        x_new_group_id is not null AND
        x_old_group_id is not null) THEN

        -- Update Customer Access
        update AS_ACCESSES_ALL acc
        set object_version_number =  nvl(object_version_number,0) + 1, acc.sales_group_id = x_new_group_id
        where acc.salesforce_id = x_new_resource_id
        and acc.sales_group_id = x_old_group_id
        and acc.lead_id is null
        and acc.sales_lead_id is null
        and not exists
        ( select 1
          from AS_ACCESSES_ALL acc2
          where acc2.sales_group_id = x_new_group_id
          and acc2.salesforce_id = x_new_resource_id
          and acc2.customer_id = acc.customer_id
          and acc2.lead_id is null
          and acc2.sales_lead_id is null
          and nvl(acc2.address_id,-99) = nvl(acc.address_id,-99)
          and nvl(acc2.org_id,-99) = nvl(acc.org_id,-99) );

        IF(l_opp_profile = 'OPEN') THEN

            -- Update Open Opportunity's Access
            update AS_ACCESSES_ALL acc
            set object_version_number =  nvl(object_version_number,0) + 1, acc.sales_group_id = x_new_group_id
            where acc.salesforce_id = x_new_resource_id
            and acc.sales_group_id = x_old_group_id
            and acc.lead_id is not null
            and acc.sales_lead_id is null
            and not exists
            ( select 1
              from AS_ACCESSES_ALL acc2
		    where acc2.sales_group_id = x_new_group_id
		    and acc2.salesforce_id = x_new_resource_id
		    and acc2.customer_id = acc.customer_id
		    and acc2.lead_id = acc.lead_id
		    and acc2.sales_lead_id is null
		    and nvl(acc2.address_id,-99) = nvl(acc.address_id,-99)
		    and nvl(acc2.org_id,-99) = nvl(acc.org_id,-99) )
            and exists
	       ( select 1
		    from AS_LEADS_ALL ld, AS_STATUSES_B st
		    where acc.lead_id = ld.lead_id
		    and ld.status = st.status_code
		    and st.opp_open_status_flag = 'Y' );

            -- Update Open Opportunities
            update AS_SALES_CREDITS sc
            set object_version_number =  nvl(object_version_number,0) + 1, sc.salesgroup_id = x_new_group_id
            where sc.salesforce_id = x_new_resource_id
            and sc.salesgroup_id = x_old_group_id
	       and exists
	       ( select 1
		    from AS_LEADS_ALL ld, AS_STATUSES_B st
		    where ld.status = st.status_code
		    and st.opp_open_status_flag = 'Y'
		    and sc.lead_id = ld.lead_id );

            update AS_LEADS_ALL ld
            set object_version_number =  nvl(object_version_number,0) + 1, ld.owner_sales_group_id = x_new_group_id
            where ld.owner_salesforce_id = x_new_resource_id
            and ld.owner_sales_group_id = x_old_group_id
	       and exists
	       ( select 1
		    from AS_STATUSES_B st
		    where ld.status = st.status_code
		    and st.opp_open_status_flag = 'Y');

        ELSIF(l_opp_profile = 'ALL') THEN

            update AS_ACCESSES_ALL acc
            set object_version_number =  nvl(object_version_number,0) + 1, acc.sales_group_id = x_new_group_id
            where acc.salesforce_id = x_new_resource_id
            and acc.sales_group_id = x_old_group_id
	       and acc.lead_id is not null
	       and acc.sales_lead_id is null
	       and not exists
	       ( select 1
		    from AS_ACCESSES_ALL acc2
		    where acc2.sales_group_id = x_new_group_id
		    and acc2.salesforce_id = x_new_resource_id
		    and acc2.customer_id = acc.customer_id
		    and acc2.lead_id = acc.lead_id
		    and acc2.sales_lead_id is null
		    and nvl(acc2.address_id,-99) = nvl(acc.address_id,-99)
		    and nvl(acc2.org_id,-99) = nvl(acc.org_id,-99) );

            update AS_SALES_CREDITS sc
            set object_version_number =  nvl(object_version_number,0) + 1, sc.salesgroup_id = x_new_group_id
            where sc.salesforce_id = x_new_resource_id
            and sc.salesgroup_id = x_old_group_id;

            update AS_LEADS_ALL ld
            set object_version_number =  nvl(object_version_number,0) + 1, ld.owner_sales_group_id = x_new_group_id
            where ld.owner_salesforce_id = x_new_resource_id
            and ld.owner_sales_group_id = x_old_group_id;

        END IF;

	   IF(l_lead_profile = 'OPEN') THEN

            -- Update Open Sales Leads' Access
            update AS_ACCESSES_ALL acc
            set object_version_number =  nvl(object_version_number,0) + 1, acc.sales_group_id = x_new_group_id
            where acc.salesforce_id = x_new_resource_id
            and acc.sales_group_id = x_old_group_id
	       and acc.sales_lead_id is not null
	       and acc.lead_id is null
	       and not exists
	       ( select 1
		    from AS_ACCESSES_ALL acc2
		    where acc2.sales_group_id = x_new_group_id
		    and acc2.salesforce_id = x_new_resource_id
		    and acc2.customer_id = acc.customer_id
		    and acc2.sales_lead_id = acc.sales_lead_id
		    and acc2.lead_id is null
		    and nvl(acc2.address_id,-99) = nvl(acc.address_id,-99)
		    and nvl(acc2.org_id,-99) = nvl(acc.org_id,-99) )
            and exists
	       ( select 1
		    from AS_SALES_LEADS sl, AS_STATUSES_B st
		    where acc.sales_lead_id = sl.sales_lead_id
		    and sl.status_code = st.status_code
		    and st.opp_open_status_flag = 'Y' );

            -- Update Open Sales Leads
            update AS_SALES_LEADS sl
            set sl.assign_sales_group_id = x_new_group_id
            where sl.assign_to_salesforce_id = x_new_resource_id
            and sl.assign_sales_group_id = x_old_group_id
	       and exists
	       ( select 1
		    from AS_STATUSES_B st
		    where st.status_code = sl.status_code
		    and st.opp_open_status_flag = 'Y' );

         ELSIF(l_lead_profile = 'ALL') THEN

            -- Update Sales Leads' Access
            update AS_ACCESSES_ALL acc
            set object_version_number =  nvl(object_version_number,0) + 1, acc.sales_group_id = x_new_group_id
            where acc.salesforce_id = x_new_resource_id
            and acc.sales_group_id = x_old_group_id
	       and acc.sales_lead_id is not null
	       and acc.lead_id is null
	       and not exists
	       ( select 1
		    from AS_ACCESSES_ALL acc2
		    where acc2.sales_group_id = x_new_group_id
		    and acc2.salesforce_id = x_new_resource_id
		    and acc2.customer_id = acc.customer_id
		    and acc2.sales_lead_id = acc.sales_lead_id
		    and acc2.lead_id is null
		    and nvl(acc2.address_id,-99) = nvl(acc.address_id,-99)
		    and nvl(acc2.org_id,-99) = nvl(acc.org_id,-99) );

            -- Update Sales Leads
            update AS_SALES_LEADS sl
            set sl.assign_sales_group_id = x_new_group_id
            where sl.assign_to_salesforce_id = x_new_resource_id
            and sl.assign_sales_group_id = x_old_group_id;

         END IF;

         update JTF_TERR_RSC_ALL jtr
         set jtr.group_id = x_new_group_id
         where jtr.resource_id = x_new_resource_id
         and jtr.group_id = x_old_group_id;

      END IF;

   /* End date any active submitted forecasts, worksheets etc..*/

      OPEN get_forecasts(x_old_group_id, x_new_resource_id);
      LOOP
          FETCH get_forecasts into l_forecast_id;
          EXIT WHEN get_forecasts%NOTFOUND;

          UPDATE as_prod_worksheet_lines
             SET object_version_number =  nvl(object_version_number,0) + 1, end_date_active = sysdate
           WHERE forecast_id = l_forecast_id
             AND end_date_active is null;

          UPDATE as_forecast_worksheets
             SET object_version_number =  nvl(object_version_number,0) + 1, end_date_active = sysdate
           WHERE forecast_id = l_forecast_id
             AND end_date_active is null;

          UPDATE as_internal_forecasts
             SET object_version_number =  nvl(object_version_number,0) + 1, end_date_active = sysdate
           WHERE forecast_id = l_forecast_id
             AND end_date_active is null;

      END LOOP;
      CLOSE get_forecasts;

 /* End forecast related code */

   END IF;

END Group_Mem_Trigger_Handler;

END AS_JTF_RS_GROUP_MEM_TRG;

/
