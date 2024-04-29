--------------------------------------------------------
--  DDL for Package Body MSD_SALES_OPERATION_PLAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_SALES_OPERATION_PLAN" AS
/* $Header: msdsoplb.pls 120.18 2006/05/25 09:28:58 brampall noship $ */

 v_retcode        varchar2(5) := '0';
 v_demand_plan_id number;

 procedure log_debug( pBUFF  in varchar2)
 is
 begin

         if C_MSC_DEBUG = 'Y' then
	    null;
            --fnd_file.put_line( fnd_file.log, pBUFF);
         else
            null;
            --dbms_output.put_line( pBUFF);
         end if;

 end log_debug;

 PROCEDURE LOG_MESSAGE( pBUFF           IN  VARCHAR2)
 IS
 BEGIN
	    null;
	    -- Bug 4395606. Cannot call fnd file from DPE.
             --FND_FILE.PUT_LINE( FND_FILE.LOG, pBUFF);

 END LOG_MESSAGE;


function calculate_cu_and_lt ( p_cu_or_lt IN NUMBER,
                               p_instance_id IN NUMBER,
                               p_supply_plan_id IN NUMBER,
                               p_assembly_pk IN VARCHAR2,
                               p_component_pk IN VARCHAR2,
                               p_res_comp IN VARCHAR2,
                               p_effectivity_date DATE,
                               p_disable_date DATE)
return number
is

l_numerator         NUMBER :=0;
l_denominator       NUMBER :=0;

l_return_value      NUMBER :=0;

begin

 LOG_MESSAGE('Entering in the function to calculate CAPACITY_USAGE_RATIO and LEAD_TIME');

  --Calculations for Critical Components
 IF p_res_comp = 'C' THEN


    -- Calculating Capacity Usage Ratios for Critical Components
    IF p_cu_or_lt = C_CU THEN

      LOG_MESSAGE('Calculating the CAPACITY_USAGE_RATIO for Critical Component');
      LOG_MESSAGE('The SR_ASSEMBLY_PK is : '||p_assembly_pk);
      LOG_MESSAGE('The SR_COMPONENT_PK is : '||p_component_pk);

               select   sum(cmp_mfp.allocated_quantity)
                        --,sum(ass_mfp.allocated_quantity)
	             INTO l_numerator
	                --,l_denominator
	       from
               msc_plan_organizations ass_mpo,
               msc_system_items  ass_msi,
               msc_demands       md,
	       msc_supplies      ass_ms,
	       msc_full_pegging  ass_mfp,
               msc_full_pegging  cmp_mfp,
               msc_supplies      cmp_ms,
               msc_system_items  cmp_msi,
               msc_plan_organizations cmp_mpo
               where cmp_mpo.plan_id            = p_supply_plan_id
               /* mpo_plan_organizations - assembly  and msc_system_items - assembly  */
               and   ass_msi.sr_instance_id     = ass_mpo.sr_instance_id
               and   ass_msi.plan_id            = ass_mpo.plan_id
               and   ass_msi.organization_id    = ass_mpo.organization_id
	       /*    msc_system_items - assembly  and msc_supplies - assembly */
               and   ass_ms.inventory_item_id   = ass_msi.inventory_item_id
               and   ass_ms.plan_id             = ass_msi.plan_id
               and   ass_ms.sr_instance_id      = ass_msi.sr_instance_id
               and   ass_ms.organization_id     = ass_msi.organization_id
	       /* msc_demands - assembly and msc_full_pegging - assembly */
	       and   md.demand_id                 = ass_mfp.demand_id
	       and   md.plan_id                   = ass_mfp.plan_id
	       and   md.sr_instance_id            = ass_mfp.sr_instance_id
	       and   md.organization_id           = ass_mfp.organization_id
	       and   md.origination_type in (6,8,29,30)
	      /* msc_supplies - assembly and msc_full_pegging - assembly */
               and   ass_ms.transaction_id      = ass_mfp.transaction_id
               and   ass_ms.plan_id             = ass_mfp.plan_id
               and   ass_ms.sr_instance_id      = ass_mfp.sr_instance_id
               and   ass_ms.organization_id     = ass_mfp.organization_id
                /* msc_full_pegging - assembly and msc_full_pegging - components */  -- No organization_id join between ass_mfp and cmp_mfp because single demand can span across various orgs.
               and    ass_mfp.end_origination_type in (6,8,29,30)                    --Include all independent Demand Types
               and    ass_mfp.pegging_id        = cmp_mfp.end_pegging_id
               and    cmp_mfp.plan_id           = ass_mfp.plan_id
               and    cmp_mfp.sr_instance_id    = ass_mfp.sr_instance_id
               and    cmp_mfp.pegging_id        <> cmp_mfp.end_pegging_id
                 /* msc_full_pegging - components and msc_supplies - components */
               and    cmp_mfp.transaction_id    = cmp_ms.transaction_id
               and    cmp_mfp.organization_id   = cmp_ms.organization_id
               and    cmp_mfp.sr_instance_id    = cmp_ms.sr_instance_id
               and    cmp_mfp.plan_id           = cmp_ms.plan_id
                /* msc_supplies - components  and msc_system_items - components */
               and    cmp_ms.inventory_item_id  = cmp_msi.inventory_item_id
               and    cmp_ms.plan_id            = cmp_msi.plan_id
               and    cmp_ms.sr_instance_id     = cmp_msi.sr_instance_id
               and    cmp_ms.organization_id    = cmp_msi.organization_id
                 /* msc_system_items - components and mpo_plan_organizations - components  */
               and   cmp_msi.organization_id    = cmp_mpo.organization_id
               and   cmp_msi.sr_instance_id     = cmp_mpo.sr_instance_id
               and   cmp_msi.plan_id            = cmp_mpo.plan_id
                 /* For given PLAN,INSTANCE,ASSEMBLY,COMPONENT,EFF and DISABLE DATE */
               and   cmp_mpo.plan_id                     = p_supply_plan_id
               and   ass_msi.sr_instance_id              = p_instance_id
               and   ass_msi.sr_inventory_item_id        = p_assembly_pk
               and   cmp_msi.sr_inventory_item_id        = p_component_pk
                 /* Is this really required, as we know the ASSEMBLY and COMPONENT? */
               and   ass_msi.sr_inventory_item_id  <>  cmp_msi.sr_inventory_item_id
	       and   md.using_assembly_demand_date between p_effectivity_date and p_disable_date;

       	        /* Splitting Nmr and Dmr because a Critical Component can be used at numerous places
		   in BOM, hence can't aggregate the Assembly's allocated quantity
		   in above query which may cause double counting in Dmr */

	      select /*+ ORDERED */ sum(ass_mfp.allocated_quantity)
		      INTO l_denominator
		from msc_plan_organizations mpo,
	             msc_demands ass_md,
                     msc_system_items ass_msi,
		     msc_full_pegging ass_mfp,
		     msc_supplies ass_ms
               where ass_msi.plan_id                       = mpo.plan_id
		and  ass_msi.sr_instance_id                = mpo.sr_instance_id
		and  ass_msi.organization_id               = mpo.organization_id
                /* msc_system_items - assembly and msd_demands - assembly */
                and  ass_msi.plan_id                      = ass_md.plan_id
                and  ass_msi.sr_instance_id               = ass_md.sr_instance_id
		and  ass_msi.organization_id              = ass_md.organization_id
	        and  ass_msi.inventory_item_id            = ass_md.inventory_item_id
                and  ass_md.origination_type              in (6,8,29,30)    --Include all independent Demand Types
		/*msc_demands - assembly and msc_full_pegging - assembly */
               and ass_md.demand_id             = ass_mfp.demand_id
               and ass_md.plan_id               = ass_mfp.plan_id
               and ass_md.sr_instance_id        = ass_mfp.sr_instance_id
               and ass_md.organization_id       = ass_mfp.organization_id
               and ass_md.origination_type in (6,8,29,30)
		/* msc_full_pegging - assembly and msc_supplies - assembly */
               and ass_ms.transaction_id        = ass_mfp.transaction_id
               and ass_ms.plan_id               = ass_mfp.plan_id
               and ass_ms.sr_instance_id        = ass_mfp.sr_instance_id
               and ass_ms.organization_id       = ass_mfp.organization_id
	       and ass_ms.order_type not in ( 18 )                      -- Exclude On Hand Supplies
		/* For given PLAN,INSTANCE,ASSEMBLY,EFF and DISABLE DATE */
		and  mpo.plan_id                          = p_supply_plan_id
		and  ass_msi.sr_instance_id               = p_instance_id
		and  ass_msi.sr_inventory_item_id         = p_assembly_pk
		and  ass_md.using_assembly_demand_date between p_effectivity_date and p_disable_date;

	        LOG_MESSAGE('The value for numerator is:'||l_numerator);
       	        LOG_MESSAGE('The value for denominator is:'||l_denominator);


           IF l_denominator <> 0 THEN
                  l_return_value := l_numerator/l_denominator;
                  LOG_MESSAGE('The value of return value is:'||l_return_value);

          ELSE
                  l_return_value := 0;
                  LOG_MESSAGE('The return value is zero because of zero denominator');

          END IF;

          return l_return_value;

    -- Calculating Lead Times for Critical Components
    ELSE

	       LOG_MESSAGE('Calculating the LEAD_TIME for Critical Component');
               LOG_MESSAGE('The SR_ASSEMBLY_PK is :'||p_assembly_pk);
               LOG_MESSAGE('The SR_COMPONENT_PK is :'||p_component_pk);

	       select /*+ ORDERED */ sum(cmp_mfp.allocated_quantity*(greatest((ass_ms.new_schedule_date - cmp_ms.new_schedule_date),0)))
	             -- ,sum(cmp_mfp.allocated_quantity)
	             INTO l_numerator
	             -- ,l_denominator

	       from
               msc_plan_organizations ass_mpo,
               msc_system_items  ass_msi,
               msc_supplies      ass_ms,
               msc_full_pegging  ass_mfp,
               msc_full_pegging  cmp_mfp,
               msc_supplies      cmp_ms,
               msc_system_items  cmp_msi,
               msc_plan_organizations cmp_mpo
               where cmp_mpo.plan_id            = p_supply_plan_id
                  /* mpo_plan_organizations - assembly  and msc_system_items - assembly  */
               and   ass_msi.sr_instance_id     = ass_mpo.sr_instance_id
               and   ass_msi.plan_id            = ass_mpo.plan_id
               and   ass_msi.organization_id    = ass_mpo.organization_id
                /*    msc_system_items - assembly  and msc_supplies - assembly */
               and   ass_ms.inventory_item_id   = ass_msi.inventory_item_id
               and   ass_ms.plan_id             = ass_msi.plan_id
               and   ass_ms.sr_instance_id      = ass_msi.sr_instance_id
               and   ass_ms.organization_id     = ass_msi.organization_id
                /* msc_supplies - assembly and msc_full_pegging - assembly */
               and   ass_ms.transaction_id      = ass_mfp.transaction_id
               and   ass_ms.plan_id             = ass_mfp.plan_id
               and   ass_ms.sr_instance_id      = ass_mfp.sr_instance_id
               and   ass_ms.organization_id     = ass_mfp.organization_id
               and   ass_ms.order_type not in (18,3 )  -- Exclude On Hand Supplies and Discrete Jobs Bug 4878648
                /* msc_full_pegging - assembly and msc_full_pegging - components */  -- No organization_id join between ass_mfp and cmp_mfp because single demand can span across various orgs.
               and    ass_mfp.end_origination_type in (6,8,29,30)                    --Include all independent Demand Types
               and    ass_mfp.pegging_id        = cmp_mfp.end_pegging_id
               and    cmp_mfp.plan_id           = ass_mfp.plan_id
               and    cmp_mfp.sr_instance_id    = ass_mfp.sr_instance_id
               and    cmp_mfp.pegging_id        <> cmp_mfp.end_pegging_id
                 /* msc_full_pegging - components and msc_supplies - components */
               and    cmp_mfp.transaction_id    = cmp_ms.transaction_id
               and    cmp_mfp.organization_id   = cmp_ms.organization_id
               and    cmp_mfp.sr_instance_id    = cmp_ms.sr_instance_id
               and    cmp_mfp.plan_id           = cmp_ms.plan_id
                /* msc_supplies - components  and msc_system_items - components */
               and    cmp_ms.inventory_item_id  = cmp_msi.inventory_item_id
               and    cmp_ms.plan_id            = cmp_msi.plan_id
               and    cmp_ms.sr_instance_id     = cmp_msi.sr_instance_id
               and    cmp_ms.organization_id    = cmp_msi.organization_id
                 /* msc_system_items - components and mpo_plan_organizations - components   */
               and   cmp_msi.organization_id    = cmp_mpo.organization_id
               and   cmp_msi.sr_instance_id     = cmp_mpo.sr_instance_id
               and   cmp_msi.plan_id            = cmp_mpo.plan_id
                 /* For given PLAN,INSTANCE,ASSEMBLY,COMPONENT,EFF and DISABLE DATE */
               and   cmp_mpo.plan_id                     = p_supply_plan_id
               and   ass_msi.sr_instance_id              = p_instance_id
               and   ass_msi.sr_inventory_item_id        = p_assembly_pk
               and   cmp_msi.sr_inventory_item_id        = p_component_pk
               --and   ass_mfp.demand_date between p_effectivity_date and p_disable_date
                 /* Is this really required, as we know the ASSEMBLY and COMPONENT? */
               and   ass_msi.sr_inventory_item_id  <>  cmp_msi.sr_inventory_item_id;

                 /* Splitting Nmr and Dmr because a Critical Component can be used at numerous places
		   in BOM, hence can't aggregate the Assembly's allocated quantity
		   in above query which may cause double counting in Dmr */

               select /*+ ORDERED */ sum(cmp_mfp.allocated_quantity)
	             INTO l_denominator
	       from
               msc_plan_organizations ass_mpo,
               msc_system_items  ass_msi,
               msc_supplies      ass_ms,
               msc_full_pegging  ass_mfp,
               msc_full_pegging  cmp_mfp,
               msc_supplies      cmp_ms,
               msc_system_items  cmp_msi,
               msc_plan_organizations cmp_mpo
               where cmp_mpo.plan_id            = p_supply_plan_id
                  /* mpo_plan_organizations - assembly  and msc_system_items - assembly  */
               and   ass_msi.sr_instance_id     = ass_mpo.sr_instance_id
               and   ass_msi.plan_id            = ass_mpo.plan_id
               and   ass_msi.organization_id    = ass_mpo.organization_id
                /*    msc_system_items - assembly  and msc_supplies - assembly */
               and   ass_ms.inventory_item_id   = ass_msi.inventory_item_id
               and   ass_ms.plan_id             = ass_msi.plan_id
               and   ass_ms.sr_instance_id      = ass_msi.sr_instance_id
               and   ass_ms.organization_id     = ass_msi.organization_id
                /* msc_supplies - assembly and msc_full_pegging - assembly */
               and   ass_ms.transaction_id      = ass_mfp.transaction_id
               and   ass_ms.plan_id             = ass_mfp.plan_id
               and   ass_ms.sr_instance_id      = ass_mfp.sr_instance_id
               and   ass_ms.organization_id     = ass_mfp.organization_id
                /* msc_full_pegging - assembly and msc_full_pegging - components */  -- No organization_id join between ass_mfp and cmp_mfp because single demand can span across various orgs.
               and    ass_mfp.end_origination_type in (6,8,29,30)                    --Include all independent Demand Types
               and    ass_mfp.pegging_id        = cmp_mfp.end_pegging_id
               and    cmp_mfp.plan_id           = ass_mfp.plan_id
               and    cmp_mfp.sr_instance_id    = ass_mfp.sr_instance_id
               and    cmp_mfp.pegging_id        <> cmp_mfp.end_pegging_id
                 /* msc_full_pegging - components and msc_supplies - components */
               and    cmp_mfp.transaction_id    = cmp_ms.transaction_id
               and    cmp_mfp.organization_id   = cmp_ms.organization_id
               and    cmp_mfp.sr_instance_id    = cmp_ms.sr_instance_id
               and    cmp_mfp.plan_id           = cmp_ms.plan_id
                /* msc_supplies - components  and msc_system_items - components */
               and    cmp_ms.inventory_item_id  = cmp_msi.inventory_item_id
               and    cmp_ms.plan_id            = cmp_msi.plan_id
               and    cmp_ms.sr_instance_id     = cmp_msi.sr_instance_id
               and    cmp_ms.organization_id    = cmp_msi.organization_id
                 /* msc_system_items - components and mpo_plan_organizations - components   */
               and   cmp_msi.organization_id    = cmp_mpo.organization_id
               and   cmp_msi.sr_instance_id     = cmp_mpo.sr_instance_id
               and   cmp_msi.plan_id            = cmp_mpo.plan_id
                 /* For given PLAN,INSTANCE,ASSEMBLY,COMPONENT,EFF and DISABLE DATE */
               and   cmp_mpo.plan_id                     = p_supply_plan_id
               and   ass_msi.sr_instance_id              = p_instance_id
               and   ass_msi.sr_inventory_item_id        = p_assembly_pk
               and   cmp_msi.sr_inventory_item_id        = p_component_pk
               --and   ass_mfp.demand_date between p_effectivity_date and p_disable_date
                 /* Is this really required, as we know the ASSEMBLY and COMPONENT? */
               and   ass_msi.sr_inventory_item_id  <>  cmp_msi.sr_inventory_item_id;

                LOG_MESSAGE('The value for numerator is:'||l_numerator);
                LOG_MESSAGE('The value for denominator is:'||l_denominator);

          IF l_denominator <> 0 THEN
                  l_return_value := l_numerator/l_denominator;
                  LOG_MESSAGE('The value of return value is:'||l_return_value);
          ELSE
                  l_return_value := 0;
                  LOG_MESSAGE('The return value is zero because of zero denominator');
          END IF;

          return l_return_value;


    END IF; --IF p_cu_or_lt = C_CU THEN


  --Calculations for Resources
 ELSE

    -- Calculating Capacity Usage Ratios for Resources
    IF p_cu_or_lt = C_CU THEN

	        LOG_MESSAGE('Calculating the CAPACITY_USAGE_RATIO for Resource');
                LOG_MESSAGE('The SR_ASSEMBLY_PK is :'||p_assembly_pk);
                LOG_MESSAGE('The SR_RESOURCE_PK is :'||p_component_pk);

		/*
		Formulae = Sigma[ (Pegged Qty for Ass/Comp based on where resource instance is applied/Total Qty for Ass/Comp based on where resource instance is applied)* Resource Hours
		           ------------------------------------------------------------------------------------------------------------------------------------------------------------------
		           Sigma[  Pegged Qty for Assmb excluding On Hand Suppplies
		*/

		select sum((mfp2.allocated_quantity/ms2.new_order_quantity)*mrr.resource_hours)
		              --,sum(mfp2.allocated_quantity)
	                 INTO l_numerator
	                      --,l_denominator
	        from
                msc_plan_organizations    mpo1,
                msc_system_items          msi,
                msc_demands               md,
                msc_full_pegging          mfp1,
                msc_full_pegging          mfp2,
                msc_supplies              ms2,
		msc_resource_requirements mrr,
		msc_department_resources  mdr,
                msc_plan_organizations    mpo2
               where
                    mpo1.plan_id             = p_supply_plan_id
                and msi.sr_inventory_item_id = p_assembly_pk
                and msi.plan_id              = mpo1.plan_id
                and msi.organization_id      = mpo1.organization_id
                and msi.sr_instance_id       = mpo1.sr_instance_id
                 /* msc_system_items and msc_demands */
                and msi.inventory_item_id    = md.inventory_item_id
                and msi.plan_id              = md.plan_id
                and msi.organization_id      = md.organization_id
                and msi.sr_instance_id       = md.sr_instance_id
                 /*msc_demands and msc_full_pegging1 */
                and md.demand_id             = mfp1.demand_id
		and md.plan_id               = mfp1.plan_id
		and md.sr_instance_id        = mfp1.sr_instance_id
		and md.organization_id       = mfp1.organization_id
	        and md.origination_type in (6,8,29,30)
               /*msc_full_pegging1 and msc_full_pegging2 */
                and mfp1.pegging_id          = mfp2.end_pegging_id
                and mfp1.plan_id             = mfp2.plan_id
                and mfp1.sr_instance_id      = mfp2.sr_instance_id  -- (No organization id join between mfp1 and mfp2 because single demand can span across various orgs.
                 /* msc_full_pegging2 and msc_resource_requirements */
                and mfp2.transaction_id      = mrr.supply_id
                and mfp2.plan_id             = mrr.plan_id
                and mfp2.sr_instance_id      = mrr.sr_instance_id
                and mfp2.organization_id     = mrr.organization_id
		/* msc_full_pegging2 and msc_supplies */
		and ms2.transaction_id        = mfp2.transaction_id
                and ms2.plan_id               = mfp2.plan_id
                and ms2.sr_instance_id        = mfp2.sr_instance_id
                and ms2.organization_id       = mfp2.organization_id
	        /* msc_resource_requirements and msc_department_resources */
                and mrr.resource_id          = mdr.resource_id
                and mrr.plan_id              = mdr.plan_id
                and mrr.sr_instance_id       = mdr.sr_instance_id
                and mrr.organization_id      = mdr.organization_id
                 /* msc_department_resources and msc_plan_organizations */
                and decode(mdr.resource_id,-1,mdr.department_code,mdr.resource_code)= p_component_pk
                and mdr.plan_id              = p_supply_plan_id
                and mdr.sr_instance_id       = p_instance_id
                and mdr.organization_id      = mpo2.organization_id
                and mpo2.plan_id             = p_supply_plan_id
                and mrr.parent_id            = 2  -- Records Inserted by HLS as Net Resource Requirements
                and md.using_assembly_demand_date between p_effectivity_date and p_disable_date;

		/* Splitting Nmr and Dmr because a Resource can be used at numerous places
		   in routing, hence can't aggregate the Assembly's allocated quantity
		   in above query which may cause double counting in Dmr */

		select /*+ ORDERED */ sum(ass_mfp.allocated_quantity)
		      INTO l_denominator
		from msc_plan_organizations mpo,
	             msc_demands ass_md,
                     msc_system_items ass_msi,
		     msc_full_pegging ass_mfp,
		     msc_supplies ass_ms
               where ass_msi.plan_id                       = mpo.plan_id
		and  ass_msi.sr_instance_id                = mpo.sr_instance_id
		and  ass_msi.organization_id               = mpo.organization_id
                /* msc_system_items - assembly and msd_demands - assembly */
                and  ass_msi.plan_id                      = ass_md.plan_id
                and  ass_msi.sr_instance_id               = ass_md.sr_instance_id
		and  ass_msi.organization_id              = ass_md.organization_id
	        and  ass_msi.inventory_item_id            = ass_md.inventory_item_id
                and  ass_md.origination_type              in (6,8,29,30)    --Include all independent Demand Types
		/*msc_demands - assembly and msc_full_pegging - assembly */
               and ass_md.demand_id             = ass_mfp.demand_id
               and ass_md.plan_id               = ass_mfp.plan_id
               and ass_md.sr_instance_id        = ass_mfp.sr_instance_id
               and ass_md.organization_id       = ass_mfp.organization_id
               and ass_md.origination_type in (6,8,29,30)
		/* msc_full_pegging - assembly and msc_supplies - assembly */
               and ass_ms.transaction_id        = ass_mfp.transaction_id
               and ass_ms.plan_id               = ass_mfp.plan_id
               and ass_ms.sr_instance_id        = ass_mfp.sr_instance_id
               and ass_ms.organization_id       = ass_mfp.organization_id
	       and ass_ms.order_type not in ( 18 )                      -- Exclude On Hand Supplies
		/* For given PLAN,INSTANCE,ASSEMBLY,EFF and DISABLE DATE */
		and  mpo.plan_id                          = p_supply_plan_id
		and  ass_msi.sr_instance_id               = p_instance_id
		and  ass_msi.sr_inventory_item_id         = p_assembly_pk
		and  ass_md.using_assembly_demand_date between p_effectivity_date and p_disable_date;

                LOG_MESSAGE('The value for numerator is:'||l_numerator);
     	        LOG_MESSAGE('The value for denominator is:'||l_denominator);

          IF l_denominator <> 0 THEN
                  l_return_value := l_numerator/l_denominator;
                  LOG_MESSAGE('The value of return value is:'||l_return_value);
          ELSE
                  l_return_value := 0;
                  LOG_MESSAGE('The return value is zero because of zero denominator');
          END IF;

          return l_return_value;

     -- Calculating Lead Times for Resources
    ELSE

               LOG_MESSAGE('Calculating the LEAD_TIME for Resource');
               LOG_MESSAGE('The SR_ASSEMBLY_PK is :'||p_assembly_pk);
               LOG_MESSAGE('The SR_RESOURCE_PK is :'||p_component_pk);

               select sum(mfp2.allocated_quantity*(greatest((ms.new_schedule_date-mrr.end_date),0)))
                      --sum(mfp2.allocated_quantity),
                      INTO l_numerator
                       --l_denominator,
                from
                msc_plan_organizations    mpo1,
                msc_system_items          msi,
                msc_supplies              ms,
                msc_full_pegging          mfp1,
                msc_full_pegging          mfp2,
                msc_resource_requirements mrr,
                msc_department_resources  mdr,
                msc_plan_organizations    mpo2
               where
                    mpo1.plan_id             = p_supply_plan_id
                and msi.sr_inventory_item_id = p_assembly_pk
                and msi.plan_id              = mpo1.plan_id
                and msi.organization_id      = mpo1.organization_id
                and msi.sr_instance_id       = mpo1.sr_instance_id
                 /* msc_system_items - assembly and msc_supplies - assembly */
                and msi.inventory_item_id    = ms.inventory_item_id
                and msi.plan_id              = ms.plan_id
                and msi.organization_id      = ms.organization_id
                and msi.sr_instance_id       = ms.sr_instance_id
                 /*msc_supplies - assembly and msc_full_pegging1 - assembly */
                and ms.transaction_id        = mfp1.transaction_id
                and ms.plan_id               = mfp1.plan_id
                and ms.sr_instance_id        = mfp1.sr_instance_id
                and ms.organization_id       = mfp1.organization_id
                 /*msc_full_pegging1 - assembly and msc_full_pegging2 - component */
                and mfp1.pegging_id          = mfp2.end_pegging_id
                and mfp1.plan_id             = mfp2.plan_id
                and mfp1.sr_instance_id      = mfp2.sr_instance_id  -- (No organization id join between mfp1 and mfp2 because single demand ca span across various orgs.
                 /* msc_full_pegging2 - component and msc_resource_requirements */
                and mfp2.transaction_id      = mrr.supply_id
                and mfp2.plan_id             = mrr.plan_id
                and mfp2.sr_instance_id      = mrr.sr_instance_id
                and mfp2.organization_id     = mrr.organization_id
                 /* msc_resource_requirements and msc_department_resources */
                and mrr.resource_id          = mdr.resource_id
                and mrr.plan_id              = mdr.plan_id
                and mrr.sr_instance_id       = mdr.sr_instance_id
                and mrr.organization_id      = mdr.organization_id
                 /* msc_department_resources and msc_plan_organizations - component */
                and decode(mdr.resource_id,-1,mdr.department_code,mdr.resource_code)= p_component_pk
                and mdr.plan_id              = mpo2.plan_id
                and mdr.sr_instance_id       = mpo2.sr_instance_id
                and mdr.organization_id      = mpo2.organization_id
                and mpo2.plan_id             = p_supply_plan_id
                --and mfp1.demand_date between p_effectivity_date and p_disable_date
                and mrr.parent_id = 2;  -- Records Inserted by HLS as Net Resource Requirements

                /* Splitting Nmr and Dmr because a Resource can be used at numerous places
		   in routing, hence can't aggregate the Assembly's allocated quantity
		   in above query which may cause double counting in Dmr */

                select /*+ ORDERED */ sum(ass_mfp.allocated_quantity)
		      INTO l_denominator
		from msc_plan_organizations mpo,
	             msc_demands ass_md,
                     msc_system_items ass_msi,
		     msc_full_pegging ass_mfp,
		     msc_supplies ass_ms
               where ass_msi.plan_id                       = mpo.plan_id
		and  ass_msi.sr_instance_id                = mpo.sr_instance_id
		and  ass_msi.organization_id               = mpo.organization_id
                           /* msc_system_items and msd_demands */
                and  ass_msi.plan_id                      = ass_md.plan_id
                and  ass_msi.sr_instance_id               = ass_md.sr_instance_id
		and  ass_msi.organization_id              = ass_md.organization_id
	        and  ass_msi.inventory_item_id            = ass_md.inventory_item_id
                and  ass_md.origination_type              in (6,8,29,30)    --Include all independent Demand Types
		           /*msc_demands and msc_full_pegging */
               and ass_md.demand_id             = ass_mfp.demand_id
               and ass_md.plan_id               = ass_mfp.plan_id
               and ass_md.sr_instance_id        = ass_mfp.sr_instance_id
               and ass_md.organization_id       = ass_mfp.organization_id
               and ass_md.origination_type in (6,8,29,30)
		          /* msc_full_pegging and msc_supplies */
               and ass_ms.transaction_id        = ass_mfp.transaction_id
               and ass_ms.plan_id               = ass_mfp.plan_id
               and ass_ms.sr_instance_id        = ass_mfp.sr_instance_id
               and ass_ms.organization_id       = ass_mfp.organization_id
	       and ass_ms.order_type not in ( 18 )                      -- Exclude On Hand Supplies
		/* For given PLAN,INSTANCE,ASSEMBLY,EFF and DISABLE DATE */
		and  mpo.plan_id                          = p_supply_plan_id
		and  ass_msi.sr_instance_id               = p_instance_id
		and  ass_msi.sr_inventory_item_id         = p_assembly_pk;
		--and  ass_md.using_assembly_demand_date between p_effectivity_date and p_disable_date;

            LOG_MESSAGE('The value for numerator is:'||l_numerator);
            LOG_MESSAGE('The value for denominator is:'||l_denominator);


           IF l_denominator <> 0 THEN
                  l_return_value := l_numerator/l_denominator;
                  LOG_MESSAGE('The value of return value is:'||l_return_value);
          ELSE
                  l_return_value := 0;
                  LOG_MESSAGE('The return value is zero because of zero denominator');
          END IF;

          return l_return_value;

    END IF; --IF p_cu_or_lt = C_CU THEN


 END IF; --IF p_res_comp = 'C' THEN

  LOG_MESSAGE('Exiting the function to calculate CAPACITY_USAGE_RATIO and LEAD_TIMES sucessfully');


exception
 when others then
   l_return_value := 0;
   LOG_MESSAGE('Exiting the function to calculate CAPACITY_USAGE_RATIO and LEAD_TIMES from an exception block');
   return l_return_value;
end calculate_cu_and_lt;

function calc_eol_wur( p_instance_id    IN NUMBER,
                       p_supply_plan_id IN NUMBER,
                       p_assembly_pk    IN VARCHAR2,
                       p_component_pk   IN VARCHAR2 )
return number
is
l_numerator         NUMBER :=0;
l_denominator       NUMBER :=0;

l_return_value      NUMBER :=0;

begin

LOG_MESSAGE('Entering in the function - calc_eol_wur -  to calculate CAPACITY_USAGE_RATIO');

      LOG_MESSAGE('Calculating the CAPACITY_USAGE_RATIO..');
      LOG_MESSAGE('The SR_ASSEMBLY_PK is : '||p_assembly_pk);
      LOG_MESSAGE('The SR_COMPONENT_PK is : '||p_component_pk);

/*         Bug 5211017
   IF ( p_assembly_pk = p_component_pk ) THEN

     l_return_value := 1;
     LOG_MESSAGE('The return value is one because p_assembly_pk and p_component_pk are same.');

     return l_return_value;

   ELSE  */

               -- Sum of Allocated Qunatities of Component meeting Independent Demands of Assembly
               -- across All Organizations.
               select   sum(cmp_mfp.allocated_quantity)
                  INTO l_numerator
	       from
               msc_plan_organizations ass_mpo,
               msc_system_items  ass_msi,
               msc_demands       ass_md,
	       msc_full_pegging  ass_mfp,
               msc_full_pegging  cmp_mfp,
               msc_demands       cmp_md,
               msc_system_items  cmp_msi,
               msc_plan_organizations cmp_mpo
               where ass_mpo.plan_id            = p_supply_plan_id
               /* mpo_plan_organizations - components  and msc_system_items - assembly  */
               and   ass_msi.sr_instance_id     = ass_mpo.sr_instance_id
               and   ass_msi.plan_id            = ass_mpo.plan_id
               and   ass_msi.organization_id    = ass_mpo.organization_id
	       /*    msc_system_items - assembly  and msc_demands - assembly */
               and   ass_md.inventory_item_id   = ass_msi.inventory_item_id
               and   ass_md.plan_id             = ass_msi.plan_id
               and   ass_md.sr_instance_id      = ass_msi.sr_instance_id
               and   ass_md.organization_id     = ass_msi.organization_id
	       and   ass_md.origination_type in (6,8,29,30)
	       /* msc_demands - assembly and msc_full_pegging - assembly */
	       and   ass_md.demand_id                 = ass_mfp.demand_id
	       and   ass_md.plan_id                   = ass_mfp.plan_id
	       and   ass_md.sr_instance_id            = ass_mfp.sr_instance_id
	       and   ass_md.organization_id           = ass_mfp.organization_id
	       /* msc_full_pegging - assembly and msc_full_pegging - components */  -- No organization_id join between ass_mfp and cmp_mfp because single demand can span across various orgs.
               and    ass_mfp.end_origination_type in (6,8,29,30)                    --Include all independent Demand Types
               and    ass_mfp.pegging_id        = cmp_mfp.end_pegging_id
               and    cmp_mfp.plan_id           = ass_mfp.plan_id
               and    cmp_mfp.sr_instance_id    = ass_mfp.sr_instance_id
               /* and    cmp_mfp.pegging_id        <> cmp_mfp.end_pegging_id              Bug 5211017*/
               /* msc_full_pegging - components and msc_demands - components */
               and    cmp_mfp.demand_id         = cmp_md.demand_id
               and    cmp_mfp.organization_id   = cmp_md.organization_id
               and    cmp_mfp.sr_instance_id    = cmp_md.sr_instance_id
               and    cmp_mfp.plan_id           = cmp_md.plan_id
               /* msc_demands - components  and msc_system_items - components */
               and    cmp_md.inventory_item_id  = cmp_msi.inventory_item_id
               and    cmp_md.plan_id            = cmp_msi.plan_id
               and    cmp_md.sr_instance_id     = cmp_msi.sr_instance_id
               and    cmp_md.organization_id    = cmp_msi.organization_id
                /* msc_system_items - components and mpo_plan_organizations - components  */
               and   cmp_msi.organization_id    = cmp_mpo.organization_id
               and   cmp_msi.sr_instance_id     = cmp_mpo.sr_instance_id
               and   cmp_msi.plan_id            = cmp_mpo.plan_id
                /* For given PLAN,INSTANCE,ASSEMBLY and COMPONENT*/
               and   cmp_mpo.plan_id                     = p_supply_plan_id
               and   ass_msi.sr_instance_id              = p_instance_id
               and   ass_msi.sr_inventory_item_id        = p_assembly_pk
               and   cmp_msi.sr_inventory_item_id        = p_component_pk;

               -- Gross Requirements of Components across All Organizations.

               select   sum(cmp_md.USING_REQUIREMENT_QUANTITY)
                  INTO l_denominator
               from
               msc_plan_organizations cmp_mpo,
               msc_system_items cmp_msi,
               msc_demands cmp_md
               where cmp_mpo.plan_id            = p_supply_plan_id
               /* msc_system_items - comp and msc_plan_organizations - comp */
               and   cmp_msi.sr_instance_id     = cmp_mpo.sr_instance_id
               and   cmp_msi.plan_id            = cmp_mpo.plan_id
               and   cmp_msi.organization_id    = cmp_mpo.organization_id
               /* msc_demands - comp  and msc_system_items - comp */
               and    cmp_md.inventory_item_id  = cmp_msi.inventory_item_id
               and    cmp_md.plan_id            = cmp_msi.plan_id
               and    cmp_md.sr_instance_id     = cmp_msi.sr_instance_id
               and    cmp_md.organization_id    = cmp_msi.organization_id
               and    cmp_md.origination_type in (29,30,8,6,24,3,1,54)     -- Gross Requirements of Components across All Organizations.
               /* For given PLAN,INSTANCE and COMPONENT*/
               and   cmp_mpo.plan_id                     = p_supply_plan_id
               and   cmp_msi.sr_instance_id              = p_instance_id
               and   cmp_msi.sr_inventory_item_id        = p_component_pk;

      LOG_MESSAGE('The value for numerator is:'||l_numerator);
      LOG_MESSAGE('The value for denominator is:'||l_denominator);


           IF l_denominator <> 0 THEN
                  l_return_value := l_numerator/l_denominator;
                  LOG_MESSAGE('The value of return value is:'||l_return_value);

          ELSE
                  l_return_value := 0;
                  LOG_MESSAGE('The return value is zero because of zero denominator');

          END IF;

          return l_return_value;

    /* END IF; --IF p_assembly_pk = p_component_pk THEN         Bug 5211017*/


exception
 when others then
   l_return_value := 0;
   LOG_MESSAGE('Exiting the function to calculate CAPACITY_USAGE_RATIO for Where Used Report in EOL from an exception block');
   return l_return_value;
end calc_eol_wur;

function calc_eol_smb( p_cu_or_lt       IN NUMBER,
                       p_instance_id    IN NUMBER,
                       p_supply_plan_id IN NUMBER,
                       p_assembly_pk    IN VARCHAR2,
                       p_component_pk   IN VARCHAR2)
return number


is
l_numerator         NUMBER :=0;
l_denominator       NUMBER :=0;

l_return_value      NUMBER :=0;

begin

LOG_MESSAGE('Entering in the function - calc_eol_smb -  to calculate CAPACITY_USAGE_RATIO and LEAD_TIME');

 IF p_cu_or_lt = C_CU THEN

      LOG_MESSAGE('Calculating the CAPACITY_USAGE_RATIO..');
      LOG_MESSAGE('The SR_ASSEMBLY_PK is : '||p_assembly_pk);
      LOG_MESSAGE('The SR_COMPONENT_PK is : '||p_component_pk);


   IF ( p_assembly_pk = p_component_pk ) THEN

     l_return_value := 1;
     LOG_MESSAGE('The return value is one because p_assembly_pk and p_component_pk are same.');

     return l_return_value;

   ELSE

            -- Sum of Gross Requirements for Components across All Organizations
            -- that are end pegged to independent demands for Assembly across all Organizations.

               select   sum(cmp_mfp.allocated_quantity)
                  INTO l_numerator
	       from
               msc_plan_organizations ass_mpo,
               msc_system_items  ass_msi,
               msc_demands       ass_md,
	       msc_full_pegging  ass_mfp,
               msc_full_pegging  cmp_mfp,
               msc_demands       cmp_md,
               --msc_supplies      cmp_ms BUG 5210812,
               msc_system_items  cmp_msi,
               msc_plan_organizations cmp_mpo
               where ass_mpo.plan_id            = p_supply_plan_id
               /* mpo_plan_organizations - components  and msc_system_items - assembly  */
               and   ass_msi.sr_instance_id     = ass_mpo.sr_instance_id
               and   ass_msi.plan_id            = ass_mpo.plan_id
               and   ass_msi.organization_id    = ass_mpo.organization_id
	       /*    msc_system_items - assembly  and msc_demands - assembly */
               and   ass_md.inventory_item_id   = ass_msi.inventory_item_id
               and   ass_md.plan_id             = ass_msi.plan_id
               and   ass_md.sr_instance_id      = ass_msi.sr_instance_id
               and   ass_md.organization_id     = ass_msi.organization_id
	       and   ass_md.origination_type in (6,8,29,30)                             -- Independent Demands of Assembly
	       /* msc_demands - assembly and msc_full_pegging - assembly */
	       and   ass_md.demand_id                 = ass_mfp.demand_id
	       and   ass_md.plan_id                   = ass_mfp.plan_id
	       and   ass_md.sr_instance_id            = ass_mfp.sr_instance_id
	       and   ass_md.organization_id           = ass_mfp.organization_id
	       /* msc_full_pegging - assembly and msc_full_pegging - components */   -- No organization_id join between ass_mfp and cmp_mfp because single demand can span across various orgs.
               and    ass_mfp.end_origination_type in (6,8,29,30)                    -- Independent Demands of Assembly
               and    ass_mfp.pegging_id        = cmp_mfp.end_pegging_id
               and    cmp_mfp.plan_id           = ass_mfp.plan_id
               and    cmp_mfp.sr_instance_id    = ass_mfp.sr_instance_id
               and    cmp_mfp.pegging_id        <> cmp_mfp.end_pegging_id
               /* msc_full_pegging - components and msc_demands - components */
               and    cmp_mfp.demand_id         = cmp_md.demand_id
               and    cmp_mfp.organization_id   = cmp_md.organization_id
               and    cmp_mfp.sr_instance_id    = cmp_md.sr_instance_id
               and    cmp_mfp.plan_id           = cmp_md.plan_id
               and    cmp_md.origination_type in (29,30,8,6,24,3,1,54)     -- Gross Requirements of Components across All Organizations.
                /* msc_full_pegging - components and msc_supplies - componnets
	       and cmp_ms.transaction_id        = cmp_mfp.transaction_id
               and cmp_ms.plan_id               = cmp_mfp.plan_id
               and cmp_ms.sr_instance_id        = cmp_mfp.sr_instance_id
               and cmp_ms.organization_id       = cmp_mfp.organization_id
	       and cmp_ms.order_type not in ( 18 )                        -- Exclude On Hand Supplies
	       Commented above code for the BUG 5210812*/
               /* msc_demands - components  and msc_system_items - components */
               and    cmp_md.inventory_item_id  = cmp_msi.inventory_item_id
               and    cmp_md.plan_id            = cmp_msi.plan_id
               and    cmp_md.sr_instance_id     = cmp_msi.sr_instance_id
               and    cmp_md.organization_id    = cmp_msi.organization_id
                /* msc_system_items - components and mpo_plan_organizations - components  */
               and   cmp_msi.organization_id    = cmp_mpo.organization_id
               and   cmp_msi.sr_instance_id     = cmp_mpo.sr_instance_id
               and   cmp_msi.plan_id            = cmp_mpo.plan_id
                /* For given PLAN,INSTANCE,ASSEMBLY and COMPONENT*/
               and   cmp_mpo.plan_id                     = p_supply_plan_id
               and   ass_msi.sr_instance_id              = p_instance_id
               and   ass_msi.sr_inventory_item_id        = p_assembly_pk
               and   cmp_msi.sr_inventory_item_id        = p_component_pk;


              -- Independent Demands for Assembly across All Organizations.

               select   sum(ass_md.USING_REQUIREMENT_QUANTITY)
                  INTO l_denominator
               from
               msc_plan_organizations ass_mpo,
               msc_system_items ass_msi,
               msc_demands ass_md
               where ass_mpo.plan_id            = p_supply_plan_id
               /* msc_system_items - asmb and msc_plan_organizations - asmb */
               and   ass_msi.sr_instance_id     = ass_mpo.sr_instance_id
               and   ass_msi.plan_id            = ass_mpo.plan_id
               and   ass_msi.organization_id    = ass_mpo.organization_id
               /* msc_demands - asmb  and msc_system_items - asmb */
               and    ass_md.inventory_item_id  = ass_msi.inventory_item_id
               and    ass_md.plan_id            = ass_msi.plan_id
               and    ass_md.sr_instance_id     = ass_msi.sr_instance_id
               and    ass_md.organization_id    = ass_msi.organization_id
               and    ass_md.origination_type in (6,8,29,30)     -- Independent Demands for Assembly
               /* For given PLAN,INSTANCE and COMPONENT */
               and   ass_mpo.plan_id                     = p_supply_plan_id
               and   ass_msi.sr_instance_id              = p_instance_id
               and   ass_msi.sr_inventory_item_id        = p_assembly_pk;




      LOG_MESSAGE('The value for numerator is:'||l_numerator);
      LOG_MESSAGE('The value for denominator is:'||l_denominator);


           IF l_denominator <> 0 THEN
                  l_return_value := l_numerator/l_denominator;
                  LOG_MESSAGE('The value of return value is:'||l_return_value);

          ELSE
                  l_return_value := 0;
                  LOG_MESSAGE('The return value is zero because of zero denominator');

          END IF;

          return l_return_value;

   END IF;     -- IF ( p_assembly_pk = p_component_pk ) THEN


  ELSE

      LOG_MESSAGE('Calculating the LEAD_TIME ..');
      LOG_MESSAGE('The SR_ASSEMBLY_PK is :'||p_assembly_pk);
      LOG_MESSAGE('The SR_COMPONENT_PK is :'||p_component_pk);

   IF ( p_assembly_pk = p_component_pk ) THEN

     l_return_value := 0;
     LOG_MESSAGE('The return value is zero because p_assembly_pk and p_component_pk are same.');

     return l_return_value;

   ELSE


              select   sum(cmp_mfp.allocated_quantity*(ass_md.USING_ASSEMBLY_DEMAND_DATE - cmp_md.USING_ASSEMBLY_DEMAND_DATE))
                  INTO l_denominator
	       from
               msc_plan_organizations ass_mpo,
               msc_system_items  ass_msi,
               msc_demands       ass_md,
	       msc_full_pegging  ass_mfp,
               msc_full_pegging  cmp_mfp,
               msc_demands       cmp_md,
               msc_system_items  cmp_msi,
               msc_plan_organizations cmp_mpo
               where ass_mpo.plan_id            = p_supply_plan_id
               /* mpo_plan_organizations - components  and msc_system_items - assembly  */
               and   ass_msi.sr_instance_id     = ass_mpo.sr_instance_id
               and   ass_msi.plan_id            = ass_mpo.plan_id
               and   ass_msi.organization_id    = ass_mpo.organization_id
	       /*    msc_system_items - assembly  and msc_demands - assembly */
               and   ass_md.inventory_item_id   = ass_msi.inventory_item_id
               and   ass_md.plan_id             = ass_msi.plan_id
               and   ass_md.sr_instance_id      = ass_msi.sr_instance_id
               and   ass_md.organization_id     = ass_msi.organization_id
	       and   ass_md.origination_type in (6,8,29,30)                             -- Independent Demands of Assembly
	       /* msc_demands - assembly and msc_full_pegging - assembly */
	       and   ass_md.demand_id                 = ass_mfp.demand_id
	       and   ass_md.plan_id                   = ass_mfp.plan_id
	       and   ass_md.sr_instance_id            = ass_mfp.sr_instance_id
	       and   ass_md.organization_id           = ass_mfp.organization_id
	       /* msc_full_pegging - assembly and msc_full_pegging - components */   -- No organization_id join between ass_mfp and cmp_mfp because single demand can span across various orgs.
               and    ass_mfp.end_origination_type in (6,8,29,30)                    -- Independent Demands of Assembly
               and    ass_mfp.pegging_id        = cmp_mfp.end_pegging_id
               and    cmp_mfp.plan_id           = ass_mfp.plan_id
               and    cmp_mfp.sr_instance_id    = ass_mfp.sr_instance_id
               and    cmp_mfp.pegging_id        <> cmp_mfp.end_pegging_id
               /* msc_full_pegging - components and msc_demands - components */
               and    cmp_mfp.demand_id         = cmp_md.demand_id
               and    cmp_mfp.organization_id   = cmp_md.organization_id
               and    cmp_mfp.sr_instance_id    = cmp_md.sr_instance_id
               and    cmp_mfp.plan_id           = cmp_md.plan_id
               and    cmp_md.origination_type in (29,30,8,6,24,3,1,54)     -- Gross Requirements of Components across All Organizations.
               /* msc_demands - components  and msc_system_items - components */
               and    cmp_md.inventory_item_id  = cmp_msi.inventory_item_id
               and    cmp_md.plan_id            = cmp_msi.plan_id
               and    cmp_md.sr_instance_id     = cmp_msi.sr_instance_id
               and    cmp_md.organization_id    = cmp_msi.organization_id
                /* msc_system_items - components and mpo_plan_organizations - components  */
               and   cmp_msi.organization_id    = cmp_mpo.organization_id
               and   cmp_msi.sr_instance_id     = cmp_mpo.sr_instance_id
               and   cmp_msi.plan_id            = cmp_mpo.plan_id
                /* For given PLAN,INSTANCE,ASSEMBLY and COMPONENT*/
               and   cmp_mpo.plan_id                     = p_supply_plan_id
               and   ass_msi.sr_instance_id              = p_instance_id
               and   ass_msi.sr_inventory_item_id        = p_assembly_pk
               and   cmp_msi.sr_inventory_item_id        = p_component_pk;






            -- Sum of Gross Requirements for Components across All Organizations
            -- that are end pegged to independent demands for Assembly across all Organizations.

               select   sum(cmp_mfp.allocated_quantity)
                  INTO l_denominator
	       from
               msc_plan_organizations ass_mpo,
               msc_system_items  ass_msi,
               msc_demands       ass_md,
	       msc_full_pegging  ass_mfp,
               msc_full_pegging  cmp_mfp,
               msc_demands       cmp_md,
               msc_system_items  cmp_msi,
               msc_plan_organizations cmp_mpo
               where ass_mpo.plan_id            = p_supply_plan_id
               /* mpo_plan_organizations - components  and msc_system_items - assembly  */
               and   ass_msi.sr_instance_id     = ass_mpo.sr_instance_id
               and   ass_msi.plan_id            = ass_mpo.plan_id
               and   ass_msi.organization_id    = ass_mpo.organization_id
	       /*    msc_system_items - assembly  and msc_demands - assembly */
               and   ass_md.inventory_item_id   = ass_msi.inventory_item_id
               and   ass_md.plan_id             = ass_msi.plan_id
               and   ass_md.sr_instance_id      = ass_msi.sr_instance_id
               and   ass_md.organization_id     = ass_msi.organization_id
	       and   ass_md.origination_type in (6,8,29,30)                             -- Independent Demands of Assembly
	       /* msc_demands - assembly and msc_full_pegging - assembly */
	       and   ass_md.demand_id                 = ass_mfp.demand_id
	       and   ass_md.plan_id                   = ass_mfp.plan_id
	       and   ass_md.sr_instance_id            = ass_mfp.sr_instance_id
	       and   ass_md.organization_id           = ass_mfp.organization_id
	       /* msc_full_pegging - assembly and msc_full_pegging - components */   -- No organization_id join between ass_mfp and cmp_mfp because single demand can span across various orgs.
               and    ass_mfp.end_origination_type in (6,8,29,30)                    -- Independent Demands of Assembly
               and    ass_mfp.pegging_id        = cmp_mfp.end_pegging_id
               and    cmp_mfp.plan_id           = ass_mfp.plan_id
               and    cmp_mfp.sr_instance_id    = ass_mfp.sr_instance_id
               and    cmp_mfp.pegging_id        <> cmp_mfp.end_pegging_id
               /* msc_full_pegging - components and msc_demands - components */
               and    cmp_mfp.demand_id         = cmp_md.demand_id
               and    cmp_mfp.organization_id   = cmp_md.organization_id
               and    cmp_mfp.sr_instance_id    = cmp_md.sr_instance_id
               and    cmp_mfp.plan_id           = cmp_md.plan_id
               and    cmp_md.origination_type in (29,30,8,6,24,3,1,54)     -- Gross Requirements of Components across All Organizations.
               /* msc_demands - components  and msc_system_items - components */
               and    cmp_md.inventory_item_id  = cmp_msi.inventory_item_id
               and    cmp_md.plan_id            = cmp_msi.plan_id
               and    cmp_md.sr_instance_id     = cmp_msi.sr_instance_id
               and    cmp_md.organization_id    = cmp_msi.organization_id
                /* msc_system_items - components and mpo_plan_organizations - components  */
               and   cmp_msi.organization_id    = cmp_mpo.organization_id
               and   cmp_msi.sr_instance_id     = cmp_mpo.sr_instance_id
               and   cmp_msi.plan_id            = cmp_mpo.plan_id
                /* For given PLAN,INSTANCE,ASSEMBLY and COMPONENT*/
               and   cmp_mpo.plan_id                     = p_supply_plan_id
               and   ass_msi.sr_instance_id              = p_instance_id
               and   ass_msi.sr_inventory_item_id        = p_assembly_pk
               and   cmp_msi.sr_inventory_item_id        = p_component_pk;





      LOG_MESSAGE('The value for numerator is:'||l_numerator);
      LOG_MESSAGE('The value for denominator is:'||l_denominator);


           IF l_denominator <> 0 THEN
                  l_return_value := l_numerator/l_denominator;
                  LOG_MESSAGE('The value of return value is:'||l_return_value);

          ELSE
                  l_return_value := 0;
                  LOG_MESSAGE('The return value is zero because of zero denominator');

          END IF;

          return l_return_value;

   END IF; --IF ( p_assembly_pk = p_component_pk ) THEN

  END IF; --IF p_cu_or_lt = C_CU THEN

exception
 when others then
   l_return_value := 0;
   LOG_MESSAGE('Exiting the function to calculate CAPACITY_USAGE_RATIO and LEAD TIME for Simulation BOM in EOL from an exception block');
   return l_return_value;
end calc_eol_smb;




 procedure populate_bom ( errbuf   OUT NOCOPY VARCHAR2,
			  retcode  OUT NOCOPY NUMBER,
                          p_demand_plan_id IN NUMBER)
 is

 cursor Supply_Plans is
 select distinct supply_plan_id
 from msd_dp_scenarios
 where demand_plan_id = p_demand_plan_id
 and nvl(supply_plan_id,-1) > 0; -- For Legacy Supply Plans the Supply_Plan_Name field will be populated with the Designators.
                                 -- However, UI will populate supply_plan_id as -99.

 cursor c_assmb_comp (p_supply_plan_id NUMBER ) is
  select /*+ ORDERED */ distinct
        ass_msi.sr_instance_id                           SR_INSTANCE_ID,
        ass_msi.sr_inventory_item_id                     SR_ASSEMBLY_PK,
        cmp_msi.sr_inventory_item_id                     SR_COMPONENT_PK,
        trunc(ass_mfp.demand_date,'MM')                  EFFECTIVITY_DATE,
        last_day(ass_mfp.demand_date)                    DISABLE_DATE
 from
 msc_plan_organizations ass_mpo,
 msc_system_items  ass_msi,
 msd_level_values  ass_mlv,
 msc_demands       ass_md,
 msc_full_pegging  ass_mfp,
 msc_full_pegging  cmp_mfp,
 msc_demands       cmp_md,
 msd_level_values  cmp_mlv,
 msc_system_items  cmp_msi,
 msc_plan_organizations cmp_mpo
 where ass_mpo.plan_id = p_supply_plan_id
 and   ass_msi.sr_instance_id  = ass_mpo.sr_instance_id
 and   ass_msi.plan_id         = ass_mpo.plan_id
 and   ass_msi.organization_id = ass_mpo.organization_id
  /*   msc_system_items - assembly  and msd_leve_values - assembly */
 and   ass_mlv.instance       = ass_msi.sr_instance_id
 and   ass_mlv.level_id       = 1
 and   ass_mlv.sr_level_pk    = to_char(ass_msi.sr_inventory_item_id)
   /*   msc_system_items - assembly  and msc_demands - assembly  */
 and   ass_md.inventory_item_id = ass_msi.inventory_item_id
 and   ass_md.origination_type  in (6,8,29,30)         --Include all independent Demand Types
 and   ass_md.plan_id           = ass_msi.plan_id
 and   ass_md.sr_instance_id    = ass_msi.sr_instance_id
 and   ass_md.organization_id   = ass_msi.organization_id
 /* msc_demands - assembly and msc_full_pegging - assembly */
 and   ass_md.demand_id       = ass_mfp.demand_id
 and   ass_md.plan_id         = ass_mfp.plan_id
 and   ass_md.sr_instance_id  = ass_mfp.sr_instance_id
 and   ass_md.organization_id = ass_mfp.organization_id
 /* msc_full_pegging - assembly and msc_full_pegging - component */      -- No organization_id join between ass_mfp and cmp_mfp because single demand can span across various orgs.
 and    ass_mfp.pegging_id     = cmp_mfp.end_pegging_id
 and    cmp_mfp.plan_id        = ass_mfp.plan_id
 and    cmp_mfp.sr_instance_id = ass_mfp.sr_instance_id
 and    cmp_mfp.pegging_id     <> cmp_mfp.end_pegging_id
 /* msc_full_pegging - component and msc_demands - component */
 and    cmp_mfp.demand_id         = cmp_md.demand_id
 and    cmp_md.inventory_item_id  = cmp_msi.inventory_item_id
 and    cmp_md.plan_id            = cmp_msi.plan_id
 and    cmp_md.sr_instance_id     = cmp_msi.sr_instance_id
 and    cmp_md.organization_id    = cmp_msi.organization_id
   /*   msc_system_items - assembly  and msd_leve_values - assembly */
 and   cmp_mlv.instance       = ass_msi.sr_instance_id
 and   cmp_mlv.level_id       = 1
 and   cmp_mlv.sr_level_pk    = to_char(ass_msi.sr_inventory_item_id)
  /* msc_system_items - components  and msc_demands - components  */
 and   cmp_msi.sr_instance_id    = cmp_mpo.sr_instance_id
 and   cmp_msi.plan_id           = cmp_mpo.plan_id
 and   cmp_msi.organization_id   = cmp_mpo.organization_id
 and   cmp_msi.planning_make_buy_code   = 2                              -- Buy Items Only
 and   cmp_msi.critical_component_flag  = 1                              -- Critical Component Only
 and   cmp_mpo.plan_id                  = p_supply_plan_id               -- For a given ascp plan
 and   ass_msi.sr_inventory_item_id     <>  cmp_msi.sr_inventory_item_id;   -- This condition is required as we are getting the assembly as component to same assembly, in case of Inter Org Transfer.


cursor c_assmb_res(p_supply_plan_id NUMBER) is
select       /*+ ORDERED */
             distinct
             msi.sr_instance_id                SR_INSTANCE_ID,
             msi.sr_inventory_item_id          SR_ASSEMBLY_PK,
             decode(mdr.resource_id,-1,'L'||'.'||mdr.department_code,'R'||'.'||mdr.resource_code) SR_COMPONENT_PK,
             trunc(mfp1.demand_date,'MM')    EFFECTIVITY_DATE,
             last_day(mfp1.demand_date)      DISABLE_DATE
	   from
		 msc_plan_organizations    mpo1,
		 msc_system_items          msi,
		 msd_level_values          mlv1,
		 msc_demands               md,
		 msc_full_pegging          mfp1,
		 msc_full_pegging          mfp2,
		 msc_resource_requirements mrr,
		 msc_department_resources  mdr,
		 msd_level_values          mlv2,
		 msc_plan_organizations    mpo2
		where
		     mpo1.plan_id             = p_supply_plan_id
		 and msi.plan_id              = mpo1.plan_id
		 and msi.organization_id      = mpo1.organization_id
		 and msi.sr_instance_id       = mpo1.sr_instance_id
		  /*msc_system_items and msd_level_values */
		 and mlv1.instance            = msi.sr_instance_id
		 and mlv1.level_id            = 1
		 and mlv1.sr_level_pk         = to_char(msi.sr_inventory_item_id)
		  /* msc_system_items and msc_demands */
		 and msi.inventory_item_id    = md.inventory_item_id
		 and msi.plan_id              = md.plan_id
		 and msi.organization_id      = md.organization_id
		 and msi.sr_instance_id       = md.sr_instance_id
		  /*msc_demands and msc_full_pegging1 */
		 and md.demand_id             = mfp1.demand_id
		 and md.plan_id               = mfp1.plan_id
		 and md.sr_instance_id        = mfp1.sr_instance_id
		 and md.organization_id       = mfp1.organization_id
		  /*msc_full_pegging1 and msc_full_pegging2 */
		 and mfp1.pegging_id          = mfp2.end_pegging_id
		 and mfp1.plan_id             = mfp2.plan_id
		 and mfp1.sr_instance_id      = mfp2.sr_instance_id  -- (No organization id join between mfp1 and mfp2 because single demand ca span across various orgs.
		  /* msc_full_pegging2 and msc_resource_requirements */
		 and mfp2.transaction_id      = mrr.supply_id
		 and mfp2.plan_id             = mrr.plan_id
		 and mfp2.sr_instance_id      = mrr.sr_instance_id
		 and mfp2.organization_id     = mrr.organization_id
		  /* msc_resource_requirements and msc_department_resources */
		 and mrr.resource_id          = mdr.resource_id
		 and mrr.plan_id              = mdr.plan_id
		 and mrr.sr_instance_id       = mdr.sr_instance_id
		 and mrr.organization_id      = mdr.organization_id
		 /* msc_department_resources and msd_level_values */
		 and mlv2.instance            = mdr.sr_instance_id
		 and mlv2.level_id            = 1
		 and mlv2.sr_level_pk         = decode(mdr.resource_id,-1,'L'||'.'||mdr.department_code,'R'||'.'||mdr.resource_code)
		  /* msc_department_resources and msc_plan_organizations */
		 and mdr.plan_id              = mpo2.plan_id
		 and mdr.sr_instance_id       = mpo2.sr_instance_id
		 and mdr.organization_id      = mpo2.organization_id
		 and mpo2.plan_id             = p_supply_plan_id
		 and mrr.parent_id = 2;




cursor c_collapsed_bom(p_demand_plan_id NUMBER) is
select distinct
   sup_plan_bom.sr_instance_id,
   sup_plan_bom.sr_assembly_pk,
   sup_plan_bom.sr_component_pk,
   sup_plan_bom.effectivity_date,
   sup_plan_bom.disable_date,
   sup_plan_bom.res_comp
from msd_ascp_bom_comp sup_plan_bom,
     msc_plans sup_plan,
     msd_dp_scenarios dp_scen
where sup_plan_bom.cap_usg_ratio_obj = sup_plan.compile_designator
and   sup_plan.plan_id = dp_scen.supply_plan_id
and   dp_scen.demand_plan_id = p_demand_plan_id
and   dp_scen.supply_plan_id is not null
--and   dp_scen.supply_plan_id > 0  (Required or Redundant)..?
order by sup_plan_bom.sr_instance_id,sup_plan_bom.sr_assembly_pk,sup_plan_bom.sr_component_pk;


 cursor c_supply_plan_scenarios is
 select scenario_name,supply_plan_name,old_supply_plan_name
 from msd_dp_scenarios
 where demand_plan_id = p_demand_plan_id
 and supply_plan_name is not null;  -- No need to add condition of supply_plan_id > 0 because we need to
                                    -- consider scenarios with legacy loaded streams attached.

 cursor c_if_plan_still_attached(p_supply_plan_name varchar2) is
 select scenario_name
 from msd_dp_scenarios
 where demand_plan_id = p_demand_plan_id
 and   old_supply_plan_name = p_supply_plan_name
 AND   rownum < 2;

 cursor c_if_plan_removed_currently(p_supply_plan_name varchar2) is
 select scenario_name
 from msd_dp_scenarios
 where demand_plan_id = p_demand_plan_id
 and   supply_plan_name = p_supply_plan_name
 AND   rownum < 2;

 v_plan_comp_date       date         := C_NULL_DATE;
 v_plan_name            varchar2(30) := to_char(null);
 v_last_collected_date  date         := C_NULL_DATE;
 v_bom_cal              BOOLEAN      := FALSE;
/*
 l_effectivity_date     DATE;
 l_disable_date         DATE;
*/
 lb_FetchComplete  Boolean;
 ln_rows_to_fetch  Number := nvl(TO_NUMBER(FND_PROFILE.VALUE('MRP_PURGE_BATCH_SIZE')),75000);

 TYPE CharTblTyp IS TABLE OF VARCHAR2(240);
 TYPE NumTblTyp  IS TABLE OF NUMBER;
 TYPE DateTblTyp IS TABLE OF DATE;

 lb_instance_id        CharTblTyp;
 lb_assembly_pk        CharTblTyp;
 lb_component_pk       CharTblTyp;
 lb_res_comp           CharTblTyp;
 lb_effectivity_date   DateTblTyp;
 lb_disable_date       DateTblTyp;

 lv_new_plan_attached   BOOLEAN :=FALSE;
 lv_removed_plan        BOOLEAN :=FALSE;

 l_scenario_name                msd_dp_scenarios.scenario_name%TYPE;
 l_supply_plan_name             msd_dp_scenarios.supply_plan_name%TYPE;
 l_old_supply_plan_name         msd_dp_scenarios.old_supply_plan_name%TYPE;

 l_scen_name                    msd_dp_scenarios.scenario_name%TYPE;

 begin

   LOG_MESSAGE('***********************************************************************');
   LOG_MESSAGE('Entered in procedure POPULATE_BOM');
   LOG_MESSAGE('***********************************************************************');

   LOG_MESSAGE('The value for Demand plan ID is: '||p_demand_plan_id);

  retcode := 0;

  LOG_MESSAGE('***********************************************************************');
  LOG_MESSAGE('Entering the Loop for all Supply Plans Attached...');
  LOG_MESSAGE('***********************************************************************');
  For Supply_Plans_Rec in Supply_Plans Loop

     select compile_designator,trunc(plan_completion_date) into v_plan_name,v_plan_comp_date
     from msc_plans
     where plan_id = Supply_Plans_Rec.supply_plan_id;


     BEGIN

     select nvl(trunc(last_collected_date),C_NULL_DATE) into v_last_collected_date
     from msd_ascp_bom_comp
     where cap_usg_ratio_obj = v_plan_name
     and plan_type= 'SOP'
     and rownum < 2;

     EXCEPTION

      WHEN NO_DATA_FOUND THEN
          v_last_collected_date := C_NULL_DATE;
      WHEN OTHERS THEN
          LOG_MESSAGE('Error fetching the LAST_COLLECTED_DATE from MSD_ASCP_BOM_COMP');
          retcode := -1 ;
          errbuf  := substr(SQLERRM,1,150);
     END;

     LOG_MESSAGE('Supply Plans Name: '||v_plan_name);
     LOG_MESSAGE('Supply Plans ID: '||Supply_Plans_Rec.supply_plan_id);

     IF ( v_plan_comp_date > v_last_collected_date ) THEN

        LOG_MESSAGE('Entering to start the calculation for this Plan.');


         v_bom_cal := TRUE;

         LOG_MESSAGE('Deleting the table MSD_ASCP_BOM_COMP for this Plan');
         delete from msd_ascp_bom_comp
         where cap_usg_ratio_obj = v_plan_name
         and plan_type = 'SOP';

           lb_FetchComplete  := FALSE;

           LOG_MESSAGE('***********************************************************************');
           LOG_MESSAGE('Opening the Assembly Component cursor');
           LOG_MESSAGE('***********************************************************************');

           OPEN  c_assmb_comp(Supply_Plans_Rec.supply_plan_id);

            IF (c_assmb_comp%ISOPEN) THEN
             LOG_MESSAGE('Value of c_assmb_comp%ISOPEN is TRUE');
            ELSE
             LOG_MESSAGE('Value of c_assmb_comp%ISOPEN is FALSE');
            END IF;

             IF (c_assmb_comp%ISOPEN) THEN

                LOOP

                   IF (lb_FetchComplete) THEN
                     EXIT;
                   END IF;

                   FETCH c_assmb_comp BULK COLLECT INTO
                                         lb_instance_id,
                                         lb_assembly_pk,
                                         lb_component_pk,
                                         lb_effectivity_date,
                                         lb_disable_date
                   LIMIT ln_rows_to_fetch;


                   IF (c_assmb_comp%NOTFOUND) THEN
                      lb_FetchComplete := TRUE;
                   END IF;


                   if c_assmb_comp%ROWCOUNT > 0  then

                         FORALL j IN lb_instance_id.FIRST..lb_instance_id.LAST
                                    INSERT INTO msd_ascp_bom_comp
                                                      (  SR_INSTANCE_ID,
                                                         CAP_USG_RATIO_OBJ,
                                                         SR_ASSEMBLY_PK,
                                                         SR_COMPONENT_PK,
                                                         EFFECTIVITY_DATE,
                                                         DISABLE_DATE,
                                                         RES_COMP,
                                                         CAPACITY_USAGE_RATIO,
                                                         LEAD_TIME,
                                                         LAST_COLLECTED_DATE,
                                                         LAST_UPDATE_DATE,
                                                         LAST_UPDATED_BY,
                                                         CREATION_DATE,
                                                         CREATED_BY,
                                                         PLAN_TYPE,
                                                         BOM_TYPE )
                                                   SELECT
                                                        lb_instance_id(j),
                                                          v_plan_name,
                                                         lb_assembly_pk(j),
                                                         lb_component_pk(j),
                                                         lb_effectivity_date(j),
                                                         lb_disable_date(j),
                                                         'C',
                                                         calculate_cu_and_lt(C_CU,
                                                                             lb_instance_id(j),
                                                                             Supply_Plans_Rec.supply_plan_id,
                                                                             lb_assembly_pk(j),
                                                                             lb_component_pk(j),
                                                                             'C',
                                                                             lb_effectivity_date(j),
                                                                             lb_disable_date(j)),
                                                         calculate_cu_and_lt(C_LT,
                                                                             lb_instance_id(j),
                                                                             Supply_Plans_Rec.supply_plan_id,
                                                                             lb_assembly_pk(j),
                                                                             lb_component_pk(j),
                                                                             'C',
                                                                             lb_effectivity_date(j),
                                                                             lb_disable_date(j)),
                                                         sysdate,
                                                         sysdate,
                                                         FND_GLOBAL.USER_ID,
                                                         sysdate,
                                                         FND_GLOBAL.USER_ID,
                                                         'SOP',
                                                         'SOP'
                                                   FROM DUAL;

                   end if;

                END LOOP;  --LOOP

             END IF;  --IF (c_assmb_comp%ISOPEN) THEN
           CLOSE c_assmb_comp;

           LOG_MESSAGE('***********************************************************************');
           LOG_MESSAGE('Closed the Assembly Component cursor');
           LOG_MESSAGE('***********************************************************************');

      -- Populate Resources.

       lb_instance_id    := NULL;
       lb_assembly_pk    := NULL;
       lb_component_pk   := NULL;
       lb_FetchComplete  := FALSE;

       LOG_MESSAGE('***********************************************************************');
       LOG_MESSAGE('Opening the Assembly Resource cursor');
       LOG_MESSAGE('***********************************************************************');

       OPEN  c_assmb_res(Supply_Plans_Rec.supply_plan_id);
             IF (c_assmb_res%ISOPEN) THEN

                LOOP

                   IF (lb_FetchComplete) THEN
                     EXIT;
                   END IF;

                   FETCH c_assmb_res BULK COLLECT INTO
                                         lb_instance_id,
                                         lb_assembly_pk,
                                         lb_component_pk,
                                         lb_effectivity_date,
                                         lb_disable_date
                   LIMIT ln_rows_to_fetch;


                   IF (c_assmb_res%NOTFOUND) THEN
                      lb_FetchComplete := TRUE;
                   END IF;


                   if c_assmb_res%ROWCOUNT > 0  then

                         FORALL j IN lb_instance_id.FIRST..lb_instance_id.LAST
                                    INSERT INTO msd_ascp_bom_comp
                                                       ( SR_INSTANCE_ID,
                                                         CAP_USG_RATIO_OBJ,
                                                         SR_ASSEMBLY_PK,
                                                         SR_COMPONENT_PK,
                                                         EFFECTIVITY_DATE,
                                                         DISABLE_DATE,
                                                         RES_COMP,
                                                         CAPACITY_USAGE_RATIO,
                                                         LEAD_TIME,
                                                         LAST_COLLECTED_DATE,
                                                         LAST_UPDATE_DATE,
                                                         LAST_UPDATED_BY,
                                                         CREATION_DATE,
                                                         CREATED_BY,
                                                         PLAN_TYPE,
                                                         BOM_TYPE )
                                                   SELECT
                                                         lb_instance_id(j),
                                                          v_plan_name,
                                                         lb_assembly_pk(j),
                                                         lb_component_pk(j),
                                                         lb_effectivity_date(j),
                                                         lb_disable_date(j),
                                                         substr(lb_component_pk(j),1,1),
                                                         calculate_cu_and_lt(C_CU,
                                                                             lb_instance_id(j),
                                                                             Supply_Plans_Rec.supply_plan_id,
                                                                             lb_assembly_pk(j),
                                                                             substr(lb_component_pk(j),3,length(lb_component_pk(j))),
                                                                             substr(lb_component_pk(j),1,1),
                                                                             lb_effectivity_date(j),
                                                                             lb_disable_date(j)),
                                                         calculate_cu_and_lt(C_LT,
                                                                             lb_instance_id(j),
                                                                             Supply_Plans_Rec.supply_plan_id,
                                                                             lb_assembly_pk(j),
                                                                             substr(lb_component_pk(j),3,length(lb_component_pk(j))),
                                                                             substr(lb_component_pk(j),1,1),
                                                                             lb_effectivity_date(j),
                                                                             lb_disable_date(j)),
                                                         sysdate,
                                                         sysdate,
                                                         FND_GLOBAL.USER_ID,
                                                         sysdate,
                                                         FND_GLOBAL.USER_ID,
                                                         'SOP',
                                                         'SOP'
                                                    FROM DUAL;
                   end if;

                END LOOP;  --LOOP

             END IF;  --IF (c_assmb_res%ISOPEN) THEN

       CLOSE c_assmb_res;

       LOG_MESSAGE('***********************************************************************');
       LOG_MESSAGE('Closed the Assembly Resource cursor');
       LOG_MESSAGE('***********************************************************************');


     -- Calculate the Capacity Usage ratios and LeadTimes for
     -- Critical Components and Resources pertaining to a particular assembly.









     End IF; --IF ( v_plan_comp_date > v_last_collected_date ) THEN

  End Loop;
  LOG_MESSAGE('***********************************************************************');
  LOG_MESSAGE('Exiting the Loop for all Supply Plans Attached');
  LOG_MESSAGE('***********************************************************************');


    --Determining the Flags, so as to rec-populate the Collapsed BOM
    -- only if there is no calculation of Capacity Usage Ratios and Lead Times
    -- in which case, Collapsed BOM will always be populated.
    IF ( v_bom_cal = FALSE ) THEN

        LOG_MESSAGE('***********************************************************************');
        LOG_MESSAGE('Entering - to evaluate flags for Collapsed BOM');
        LOG_MESSAGE('***********************************************************************');

        OPEN c_supply_plan_scenarios;
            LOOP
              FETCH c_supply_plan_scenarios INTO l_scenario_name,
                                                 l_supply_plan_name,
                                                 l_old_supply_plan_name;

              EXIT WHEN c_supply_plan_scenarios%NOTFOUND;

               IF l_supply_plan_name <> nvl(l_old_supply_plan_name,'-999') THEN


                  --Setting the flag to recalculate the collapsed BOM if,
                  --any of the new ASCP Plans have been attached
                  OPEN c_if_plan_still_attached(l_supply_plan_name);
                    FETCH c_if_plan_still_attached INTO l_scen_name;

                     IF c_if_plan_still_attached%NOTFOUND THEN
                         lv_new_plan_attached := TRUE;

                       LOG_MESSAGE('Setting the Flag as New Supply Plan Attached');
                       LOG_MESSAGE('Name of the New Supply Plan Attached: '||l_supply_plan_name);

                     END IF;

                  CLOSE c_if_plan_still_attached;

              EXIT WHEN lv_new_plan_attached;


                  --Setting the flag to recalculate the collapsed BOM if,
                  --any of the ASCP Plans attached earlier but are not attcahed currently.
                  OPEN c_if_plan_removed_currently(l_old_supply_plan_name); -- or OPEN c_if_plan_removed_currently(nvl(l_old_supply_plan_name,'-999')); ??
                    FETCH c_if_plan_removed_currently INTO l_scen_name;

                     IF c_if_plan_removed_currently%NOTFOUND THEN
                         lv_removed_plan := TRUE;

                       LOG_MESSAGE('Setting the Flag as Supply Plan has been Removed');
                       LOG_MESSAGE('Name of the Existing Supply Plan Removed: '||l_old_supply_plan_name);

                     END IF;

                  CLOSE c_if_plan_removed_currently;



               END IF;

              EXIT WHEN lv_removed_plan;

            END LOOP;
        CLOSE c_supply_plan_scenarios;

        LOG_MESSAGE('***********************************************************************');
        LOG_MESSAGE('Exiting - to evaluate flags for Collapsed BOM');
        LOG_MESSAGE('***********************************************************************');

    END IF;

    IF lv_new_plan_attached THEN
      LOG_MESSAGE(' lv_new_plan_attached is true');
    ELSE
      LOG_MESSAGE(' lv_new_plan_attached is false');
    END IF;

    IF lv_removed_plan THEN
      LOG_MESSAGE(' lv_removed_plan is true');
    ELSE
      LOG_MESSAGE(' lv_removed_plan is false');
    END IF;


    -- Deleting the Collapsed BOM table and populating the same.
      IF v_bom_cal OR lv_new_plan_attached  OR lv_removed_plan  THEN

       LOG_MESSAGE('***********************************************************************');
       LOG_MESSAGE('Entering - to evaluate the Collapsed BOM');
       LOG_MESSAGE('***********************************************************************');

       --Initialize the l_effectivity_date and l_disable_date for this SOP Plan.
/*
        BEGIN
        select nvl(min(CURR_START_DATE),to_date(null)),to_date(null) INTO l_effectivity_date,l_disable_date
        from msc_plans
        where plan_id in ( select distinct supply_plan_id
                                    from msd_dp_scenarios
		                    where demand_plan_id = p_demand_plan_id
                                    and   supply_plan_id > 0 );
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
              l_effectivity_date := to_date(null);
              l_disable_date     := to_date(null);
              --RETURN;
           WHEN OTHERS THEN
              l_effectivity_date := to_date(null);
              l_disable_date     := to_date(null);
              log_debug ('There is an error while trying to fetch the Supply Plan Horizon Dates attached to the SNOP Plan.');
              --RETURN;
        END;
*/
       LOG_MESSAGE('Deleting the Collapsed BOM Data from table MSD_SOP_COLLAPESD_BOM_COMP');
       delete msd_sop_collapsed_bom_comp
       where demand_plan_id = p_demand_plan_id;  --where sop_plan_id = p_demand_plan_id;


        lb_instance_id    := NULL;
        lb_assembly_pk    := NULL;
        lb_component_pk   := NULL;
        lb_FetchComplete  := FALSE;

       LOG_MESSAGE('Opening the Collapsed BOM Cursor');
       OPEN  c_collapsed_bom(p_demand_plan_id);
             IF (c_collapsed_bom%ISOPEN) THEN

                LOOP

                   IF (lb_FetchComplete) THEN
                     EXIT;
                   END IF;

                   FETCH c_collapsed_bom BULK COLLECT INTO
                                         lb_instance_id,
                                         lb_assembly_pk,
                                         lb_component_pk,
                                         lb_effectivity_date,
                                         lb_disable_date,
                                         lb_res_comp
                   LIMIT ln_rows_to_fetch;


                   IF (c_collapsed_bom%NOTFOUND) THEN
                      lb_FetchComplete := TRUE;
                   END IF;


                   if c_collapsed_bom%ROWCOUNT > 0  then

                         FORALL j IN lb_instance_id.FIRST..lb_instance_id.LAST
                                    INSERT INTO msd_sop_collapsed_bom_comp
                                                       ( SR_INSTANCE_ID,
                                                         DEMAND_PLAN_ID,   --SOP_PLAN_ID,
                                                         SR_ASSEMBLY_PK,
                                                         SR_COMPONENT_PK,
                                                         EFFECTIVITY_DATE,
                                                         DISABLE_DATE,
                                                         RES_COMP,
                                                         LAST_UPDATE_DATE,
                                                         LAST_UPDATED_BY,
                                                         CREATION_DATE,
                                                         CREATED_BY,
                                                         PLAN_TYPE,
                                                         BOM_TYPE )
                                                   VALUES
                                                       ( lb_instance_id(j),
                                                         p_demand_plan_id,
                                                         lb_assembly_pk(j),
                                                         lb_component_pk(j),
                                                         lb_effectivity_date(j),  --l_effectivity_date,
                                                         lb_disable_date(j),      --l_disable_date,
                                                         lb_res_comp(j),
                                                         sysdate,
                                                         FND_GLOBAL.USER_ID,
                                                         sysdate,
                                                         FND_GLOBAL.USER_ID,
                                                         'SOP',
                                                         'SOP' );

                   end if;

                END LOOP;  --LOOP

             END IF;  --IF (c_collapsed_bom%ISOPEN) THEN
           CLOSE c_collapsed_bom;
           LOG_MESSAGE('Closed the Collapsed BOM Cursor');

      LOG_MESSAGE('Updating the Old Supply Plan Columns');
       -- Populating the Old_Supply_Plan_Name and Old_Supply_Plan_ID
       -- to track for the the next run if we need to re-populate the collapsed bom table for
       -- this plan or not.
       update msd_dp_scenarios
       set old_supply_plan_id      = supply_plan_id,
           old_supply_plan_name    = supply_plan_name
       where demand_plan_id   = p_demand_plan_id
       and   supply_plan_name is not null;


      LOG_MESSAGE('***********************************************************************');
      LOG_MESSAGE('Exiting - to evaluate the Collapsed BOM');
      LOG_MESSAGE('***********************************************************************');

      END IF;  --IF v_bom_cal OR lv_new_plan_attached  OR lv_removed_plan  THEN

/*
       LOG_MESSAGE('Updating the Old Supply Plan Columns');
       -- Populating the Old_Supply_Plan_Name and Old_Supply_Plan_ID
       -- to track for the the next run if we need to re-populate the collapsed bom table for
       -- this plan or not.
       update msd_dp_scenarios
       set old_supply_plan_id      = supply_plan_id,
           old_supply_plan_name    = supply_plan_name
       where demand_plan_id   = p_demand_plan_id
       and   supply_plan_name is not null;
*/

       -- Final Commit;
       commit;

       LOG_MESSAGE('***********************************************************************');
       LOG_MESSAGE('Exiting from the procedure POPULATE_BOM Sucessfully');
       LOG_MESSAGE('***********************************************************************');

 exception
  when others then
     retcode := -1 ;
     errbuf := substr(SQLERRM,1,150);


 end populate_bom;

 procedure populate_eol_bom (errbuf  OUT NOCOPY VARCHAR2,
                             retcode OUT NOCOPY NUMBER,
                             p_demand_plan_id IN NUMBER)

 is

 cursor Supply_Plans is
 select distinct supply_plan_id
 from msd_dp_scenarios
 where demand_plan_id = p_demand_plan_id
 and nvl(supply_plan_id,-1) > 0; -- For Legacy Supply Plans the Supply_Plan_Name field will be populated with the Designators.
                                 -- However, UI will populate supply_plan_id as -99.

cursor c_assmb_comp_wur_bom (p_supply_plan_id NUMBER ) is
select /*+ ORDERED */ distinct
        ass_msi.sr_instance_id                           SR_INSTANCE_ID,
        ass_msi.sr_inventory_item_id                     SR_ASSEMBLY_PK,
        cmp_msi.sr_inventory_item_id                     SR_COMPONENT_PK
 from
 msc_plan_organizations ass_mpo,
 msc_system_items  ass_msi,
 msd_level_values  ass_mlv,
 msc_demands       ass_md,
 msc_full_pegging  ass_mfp,
 msc_full_pegging  cmp_mfp,
 msc_demands       cmp_md,
 msd_level_values  cmp_mlv,
 msc_system_items  cmp_msi,
 msc_plan_organizations cmp_mpo
 where
  /* msc_system_items - assembly and msc_plans - assembly */
       ass_mpo.plan_id         = p_supply_plan_id
 and   ass_msi.sr_instance_id  = ass_mpo.sr_instance_id
 and   ass_msi.plan_id         = ass_mpo.plan_id
 and   ass_msi.organization_id = ass_mpo.organization_id
  /*   msc_system_items - assembly  and msd_level_values - assembly */
 and   ass_mlv.instance       = ass_msi.sr_instance_id
 and   ass_mlv.level_id       = 1
 and   ass_mlv.sr_level_pk    = to_char(ass_msi.sr_inventory_item_id)
   /*   msc_system_items - assembly  and msc_demands - assembly  */
 and   ass_md.inventory_item_id = ass_msi.inventory_item_id
 and   ass_md.origination_type  in (6,8,29,30)         --Include all independent Demand Types
 and   ass_md.plan_id           = ass_msi.plan_id
 and   ass_md.sr_instance_id    = ass_msi.sr_instance_id
 and   ass_md.organization_id   = ass_msi.organization_id
 /* msc_demands - assembly and msc_full_pegging - assembly */
 and   ass_md.demand_id       = ass_mfp.demand_id
 and   ass_md.plan_id         = ass_mfp.plan_id
 and   ass_md.sr_instance_id  = ass_mfp.sr_instance_id
 and   ass_md.organization_id = ass_mfp.organization_id
 /* msc_full_pegging - assembly and msc_full_pegging - component */      -- No organization_id join between ass_mfp and cmp_mfp because single demand can span across various orgs.
 and    ass_mfp.pegging_id     = cmp_mfp.end_pegging_id
 and    cmp_mfp.plan_id        = ass_mfp.plan_id
 and    cmp_mfp.sr_instance_id = ass_mfp.sr_instance_id
 /* msc_full_pegging - component and msc_demands - component */
 and    cmp_mfp.demand_id         = cmp_md.demand_id
 and    cmp_md.inventory_item_id  = cmp_msi.inventory_item_id
 and    cmp_md.plan_id            = cmp_msi.plan_id
 and    cmp_md.sr_instance_id     = cmp_msi.sr_instance_id
 and    cmp_md.organization_id    = cmp_msi.organization_id
   /*   msc_system_items - assembly  and msd_leve_values - assembly */
 and   cmp_mlv.instance       = ass_msi.sr_instance_id
 and   cmp_mlv.level_id       = 1
 and   cmp_mlv.sr_level_pk    = to_char(ass_msi.sr_inventory_item_id)
  /* msc_system_items - components  and msc_demands - components  */
 and   cmp_msi.sr_instance_id    = cmp_mpo.sr_instance_id
 and   cmp_msi.plan_id           = cmp_mpo.plan_id
 and   cmp_msi.organization_id   = cmp_mpo.organization_id
 and   cmp_mpo.plan_id           = p_supply_plan_id;              -- For a given ascp plan


cursor c_assmb_comp_smb_bom (p_supply_plan_id NUMBER ) is
select /*+ ORDERED */ distinct
        ass_msi.sr_instance_id                           SR_INSTANCE_ID,
        ass_msi.sr_inventory_item_id                     SR_ASSEMBLY_PK,
        cmp_msi.sr_inventory_item_id                     SR_COMPONENT_PK
 from
 msc_plan_organizations ass_mpo,
 msc_system_items  ass_msi,
 msd_level_values  ass_mlv,
 msc_demands       ass_md,
 msc_full_pegging  ass_mfp,
 msc_full_pegging  cmp_mfp,
 msc_demands       cmp_md,
 msd_level_values  cmp_mlv,
 msc_system_items  cmp_msi,
 msc_plan_organizations cmp_mpo
 where
  /* msc_system_items - assembly and msc_plans - assembly */
       ass_mpo.plan_id         = p_supply_plan_id
 and   ass_msi.sr_instance_id  = ass_mpo.sr_instance_id
 and   ass_msi.plan_id         = ass_mpo.plan_id
 and   ass_msi.organization_id = ass_mpo.organization_id
  /*   msc_system_items - assembly  and msd_level_values - assembly */
 and   ass_mlv.instance       = ass_msi.sr_instance_id
 and   ass_mlv.level_id       = 1
 and   ass_mlv.sr_level_pk    = to_char(ass_msi.sr_inventory_item_id)
   /*   msc_system_items - assembly  and msc_demands - assembly  */
 and   ass_md.inventory_item_id = ass_msi.inventory_item_id
 and   ass_md.origination_type  in (6,8,29,30)         --Include all independent Demand Types
 and   ass_md.plan_id           = ass_msi.plan_id
 and   ass_md.sr_instance_id    = ass_msi.sr_instance_id
 and   ass_md.organization_id   = ass_msi.organization_id
 /* msc_demands - assembly and msc_full_pegging - assembly */
 and   ass_md.demand_id       = ass_mfp.demand_id
 and   ass_md.plan_id         = ass_mfp.plan_id
 and   ass_md.sr_instance_id  = ass_mfp.sr_instance_id
 and   ass_md.organization_id = ass_mfp.organization_id
 /* msc_full_pegging - assembly and msc_full_pegging - component */      -- No organization_id join between ass_mfp and cmp_mfp because single demand can span across various orgs.
 and    ass_mfp.pegging_id     = cmp_mfp.end_pegging_id
 and    cmp_mfp.plan_id        = ass_mfp.plan_id
 and    cmp_mfp.sr_instance_id = ass_mfp.sr_instance_id
 /* msc_full_pegging - component and msc_demands - component */
 and    cmp_mfp.demand_id         = cmp_md.demand_id
 and    cmp_md.inventory_item_id  = cmp_msi.inventory_item_id
 and    cmp_md.plan_id            = cmp_msi.plan_id
 and    cmp_md.sr_instance_id     = cmp_msi.sr_instance_id
 and    cmp_md.organization_id    = cmp_msi.organization_id
   /*   msc_system_items - assembly  and msd_leve_values - assembly */
 and   cmp_mlv.instance       = ass_msi.sr_instance_id
 and   cmp_mlv.level_id       = 1
 and   cmp_mlv.sr_level_pk    = to_char(ass_msi.sr_inventory_item_id)
  /* msc_system_items - components  and msc_demands - components  */
 and   cmp_msi.sr_instance_id    = cmp_mpo.sr_instance_id
 and   cmp_msi.plan_id           = cmp_mpo.plan_id
 and   cmp_msi.organization_id   = cmp_mpo.organization_id
 and   cmp_mpo.plan_id           = p_supply_plan_id;              -- For a given ascp plan


cursor c_collapsed_bom(p_demand_plan_id NUMBER) is
select distinct
   sup_plan_bom.sr_instance_id,
   sup_plan_bom.sr_assembly_pk,
   sup_plan_bom.sr_component_pk,
   sup_plan_bom.bom_type
from msd_ascp_bom_comp sup_plan_bom,
     msc_plans sup_plan,
     msd_dp_scenarios dp_scen
where sup_plan_bom.cap_usg_ratio_obj = sup_plan.compile_designator
and   sup_plan.plan_id = dp_scen.supply_plan_id
and   dp_scen.demand_plan_id = p_demand_plan_id
and   dp_scen.supply_plan_id is not null
order by sup_plan_bom.sr_instance_id,sup_plan_bom.sr_assembly_pk,sup_plan_bom.sr_component_pk;

 cursor c_supply_plan_scenarios is
 select scenario_name,supply_plan_name,old_supply_plan_name
 from msd_dp_scenarios
 where demand_plan_id = p_demand_plan_id
 and supply_plan_name is not null;  -- No need to add condition of supply_plan_id > 0 because we need to
                                    -- consider scenarios with legacy loaded streams attached.

 cursor c_if_plan_still_attached(p_supply_plan_name varchar2) is
 select scenario_name
 from msd_dp_scenarios
 where demand_plan_id = p_demand_plan_id
 and   old_supply_plan_name = p_supply_plan_name
 AND   rownum < 2;

 cursor c_if_plan_removed_currently(p_supply_plan_name varchar2) is
 select scenario_name
 from msd_dp_scenarios
 where demand_plan_id = p_demand_plan_id
 and   supply_plan_name = p_supply_plan_name
 AND   rownum < 2;

 v_plan_comp_date       date         := C_NULL_DATE;
 v_plan_name            varchar2(30) := to_char(null);
 v_last_collected_date  date         := C_NULL_DATE;
 v_bom_cal              BOOLEAN      := FALSE;

 lb_FetchComplete  Boolean;
 ln_rows_to_fetch  Number := nvl(TO_NUMBER(FND_PROFILE.VALUE('MRP_PURGE_BATCH_SIZE')),75000);

 TYPE CharTblTyp IS TABLE OF VARCHAR2(240);
 TYPE NumTblTyp  IS TABLE OF NUMBER;
 TYPE DateTblTyp IS TABLE OF DATE;

 lb_instance_id        CharTblTyp;
 lb_assembly_pk        CharTblTyp;
 lb_component_pk       CharTblTyp;
 lb_bom_type           CharTblTyp;

 lv_new_plan_attached   BOOLEAN :=FALSE;
 lv_removed_plan        BOOLEAN :=FALSE;

 l_scenario_name                msd_dp_scenarios.scenario_name%TYPE;
 l_supply_plan_name             msd_dp_scenarios.supply_plan_name%TYPE;
 l_old_supply_plan_name         msd_dp_scenarios.old_supply_plan_name%TYPE;

 l_scen_name                    msd_dp_scenarios.scenario_name%TYPE;

 begin

   LOG_MESSAGE('***********************************************************************');
   LOG_MESSAGE('Entered in procedure POPULATE_EOL_BOM');
   LOG_MESSAGE('***********************************************************************');

   LOG_MESSAGE('The value for EOL plan ID is: '||p_demand_plan_id);

  retcode := 0;

  LOG_MESSAGE('***********************************************************************');
  LOG_MESSAGE('Entering the Loop for all Supply Plans Attached...');
  LOG_MESSAGE('***********************************************************************');

  For Supply_Plans_Rec in Supply_Plans Loop

     select compile_designator,trunc(plan_completion_date) into v_plan_name,v_plan_comp_date
     from msc_plans
     where plan_id = Supply_Plans_Rec.supply_plan_id;


     BEGIN

     select distinct nvl(trunc(last_collected_date),C_NULL_DATE) into v_last_collected_date
     from msd_ascp_bom_comp
     where cap_usg_ratio_obj = v_plan_name
     and plan_type = 'EOL'
     and rownum < 2;

     EXCEPTION

      WHEN NO_DATA_FOUND THEN
          v_last_collected_date := C_NULL_DATE;
      WHEN OTHERS THEN
          LOG_MESSAGE('Error fetching the LAST_COLLECTED_DATE from MSD_ASCP_BOM_COMP');
          retcode := -1 ;
          errbuf  := substr(SQLERRM,1,150);
     END;

     LOG_MESSAGE('Supply Plans Name: '||v_plan_name);
     LOG_MESSAGE('Supply Plans ID: '||Supply_Plans_Rec.supply_plan_id);

     IF ( v_plan_comp_date > v_last_collected_date ) THEN

        LOG_MESSAGE('Entering to start the calculation for this Plan.');


         v_bom_cal := TRUE;

         LOG_MESSAGE('Deleting the table MSD_ASCP_BOM_COMP for this Plan');
         delete from msd_ascp_bom_comp
         where cap_usg_ratio_obj = v_plan_name
         and plan_type = 'EOL';

           lb_FetchComplete  := FALSE;

           LOG_MESSAGE('***********************************************************************');
           LOG_MESSAGE('Opening the Assembly Component cursor for Where Used Report');
           LOG_MESSAGE('***********************************************************************');

           OPEN  c_assmb_comp_wur_bom(Supply_Plans_Rec.supply_plan_id);

            IF (c_assmb_comp_wur_bom%ISOPEN) THEN
             LOG_MESSAGE('Value of c_assmb_comp_wur_bom%ISOPEN is TRUE');
            ELSE
             LOG_MESSAGE('Value of c_assmb_comp_wur_bom%ISOPEN is FALSE');
            END IF;

             IF (c_assmb_comp_wur_bom%ISOPEN) THEN

                LOOP

                   IF (lb_FetchComplete) THEN
                     EXIT;
                   END IF;

                   FETCH c_assmb_comp_wur_bom BULK COLLECT INTO
                                         lb_instance_id,
                                         lb_assembly_pk,
                                         lb_component_pk
                   LIMIT ln_rows_to_fetch;


                   IF (c_assmb_comp_wur_bom%NOTFOUND) THEN
                      lb_FetchComplete := TRUE;
                   END IF;


                   if c_assmb_comp_wur_bom%ROWCOUNT > 0  then

                         FORALL j IN lb_instance_id.FIRST..lb_instance_id.LAST
                                    INSERT INTO msd_ascp_bom_comp
                                                      (  SR_INSTANCE_ID,
                                                         CAP_USG_RATIO_OBJ,
                                                         SR_ASSEMBLY_PK,
                                                         SR_COMPONENT_PK,
                                                         CAPACITY_USAGE_RATIO,
                                                         LAST_COLLECTED_DATE,
                                                         LAST_UPDATE_DATE,
                                                         LAST_UPDATED_BY,
                                                         CREATION_DATE,
                                                         CREATED_BY,
                                                         PLAN_TYPE,
                                                         BOM_TYPE )
                                                   SELECT
                                                        lb_instance_id(j),
                                                          v_plan_name,
                                                         lb_assembly_pk(j),
                                                         lb_component_pk(j),
                                                         calc_eol_wur(lb_instance_id(j),
                                                                      Supply_Plans_Rec.supply_plan_id,
                                                                      lb_assembly_pk(j),
                                                                      lb_component_pk(j)),
                                                         sysdate,
                                                         sysdate,
                                                         FND_GLOBAL.USER_ID,
                                                         sysdate,
                                                         FND_GLOBAL.USER_ID,
                                                         'EOL',
                                                         'WUR'
                                                   FROM DUAL;

                   end if;

                END LOOP;  --LOOP

             END IF;  --IF (c_assmb_comp_wur_bom%ISOPEN) THEN
           CLOSE c_assmb_comp_wur_bom;

           LOG_MESSAGE('***********************************************************************');
           LOG_MESSAGE('Closed the Assembly Component cursor for Where Used Report');
           LOG_MESSAGE('***********************************************************************');

       --Populating Simulation BOM

       lb_instance_id    := NULL;
       lb_assembly_pk    := NULL;
       lb_component_pk   := NULL;
       lb_FetchComplete  := FALSE;


           LOG_MESSAGE('***********************************************************************');
           LOG_MESSAGE('Opening the Assembly Component cursor for Simulation BOM');
           LOG_MESSAGE('***********************************************************************');

           OPEN  c_assmb_comp_smb_bom(Supply_Plans_Rec.supply_plan_id);

            IF (c_assmb_comp_smb_bom%ISOPEN) THEN
             LOG_MESSAGE('Value of c_assmb_comp_smb_bom%ISOPEN is TRUE');
            ELSE
             LOG_MESSAGE('Value of c_assmb_comp_smb_bom%ISOPEN is FALSE');
            END IF;

             IF (c_assmb_comp_smb_bom%ISOPEN) THEN

                LOOP

                   IF (lb_FetchComplete) THEN
                     EXIT;
                   END IF;

                   FETCH c_assmb_comp_smb_bom BULK COLLECT INTO
                                         lb_instance_id,
                                         lb_assembly_pk,
                                         lb_component_pk
                   LIMIT ln_rows_to_fetch;


                   IF (c_assmb_comp_smb_bom%NOTFOUND) THEN
                      lb_FetchComplete := TRUE;
                   END IF;


                   if c_assmb_comp_smb_bom%ROWCOUNT > 0  then

                         FORALL j IN lb_instance_id.FIRST..lb_instance_id.LAST
                                    INSERT INTO msd_ascp_bom_comp
                                                      (  SR_INSTANCE_ID,
                                                         CAP_USG_RATIO_OBJ,
                                                         SR_ASSEMBLY_PK,
                                                         SR_COMPONENT_PK,
                                                         CAPACITY_USAGE_RATIO,
                                                         LEAD_TIME,
                                                         LAST_COLLECTED_DATE,
                                                         LAST_UPDATE_DATE,
                                                         LAST_UPDATED_BY,
                                                         CREATION_DATE,
                                                         CREATED_BY,
                                                         PLAN_TYPE,
                                                         BOM_TYPE )
                                                   SELECT
                                                        lb_instance_id(j),
                                                          v_plan_name,
                                                         lb_assembly_pk(j),
                                                         lb_component_pk(j),
                                                         calc_eol_smb(C_CU,
                                                                      lb_instance_id(j),
                                                                      Supply_Plans_Rec.supply_plan_id,
                                                                      lb_assembly_pk(j),
                                                                      lb_component_pk(j)),
                                                         calc_eol_smb(C_LT,
                                                                      lb_instance_id(j),
                                                                      Supply_Plans_Rec.supply_plan_id,
                                                                      lb_assembly_pk(j),
                                                                      lb_component_pk(j)),
                                                         sysdate,
                                                         sysdate,
                                                         FND_GLOBAL.USER_ID,
                                                         sysdate,
                                                         FND_GLOBAL.USER_ID,
                                                         'EOL',
                                                         'SMB'
                                                   FROM DUAL;

                   end if;

                END LOOP;  --LOOP

             END IF;  --IF (c_assmb_comp_smb_bom%ISOPEN) THEN
           CLOSE c_assmb_comp_smb_bom;

           LOG_MESSAGE('***********************************************************************');
           LOG_MESSAGE('Closed the Assembly Component cursor for Simulation BOM');
           LOG_MESSAGE('***********************************************************************');


     End IF; --IF ( v_plan_comp_date > v_last_collected_date ) THEN

  End Loop;
  LOG_MESSAGE('***********************************************************************');
  LOG_MESSAGE('Exiting the Loop for all Supply Plans Attached');
  LOG_MESSAGE('***********************************************************************');


    --Determining the Flags, so as to rec-populate the Collapsed BOM
    -- only if there is no calculation of Capacity Usage Ratios and Lead Times
    -- in which case, Collapsed BOM will always be populated.
    IF ( v_bom_cal = FALSE ) THEN

        LOG_MESSAGE('***********************************************************************');
        LOG_MESSAGE('Entering - to evaluate flags for Collapsed BOM');
        LOG_MESSAGE('***********************************************************************');

        OPEN c_supply_plan_scenarios;
            LOOP
              FETCH c_supply_plan_scenarios INTO l_scenario_name,
                                                 l_supply_plan_name,
                                                 l_old_supply_plan_name;

              EXIT WHEN c_supply_plan_scenarios%NOTFOUND;

               IF l_supply_plan_name <> nvl(l_old_supply_plan_name,'-999') THEN


                  --Setting the flag to recalculate the collapsed BOM if,
                  --any of the new ASCP Plans have been attached
                  OPEN c_if_plan_still_attached(l_supply_plan_name);
                    FETCH c_if_plan_still_attached INTO l_scen_name;

                     IF c_if_plan_still_attached%NOTFOUND THEN
                         lv_new_plan_attached := TRUE;

                       LOG_MESSAGE('Setting the Flag as New Supply Plan Attached');
                       LOG_MESSAGE('Name of the New Supply Plan Attached: '||l_supply_plan_name);

                     END IF;

                  CLOSE c_if_plan_still_attached;

              EXIT WHEN lv_new_plan_attached;


                  --Setting the flag to recalculate the collapsed BOM if,
                  --any of the ASCP Plans attached earlier but are not attcahed currently.
                  OPEN c_if_plan_removed_currently(l_old_supply_plan_name); -- or OPEN c_if_plan_removed_currently(nvl(l_old_supply_plan_name,'-999')); ??
                    FETCH c_if_plan_removed_currently INTO l_scen_name;

                     IF c_if_plan_removed_currently%NOTFOUND THEN
                         lv_removed_plan := TRUE;

                       LOG_MESSAGE('Setting the Flag as Supply Plan has been Removed');
                       LOG_MESSAGE('Name of the Existing Supply Plan Removed: '||l_old_supply_plan_name);

                     END IF;

                  CLOSE c_if_plan_removed_currently;



               END IF;

              EXIT WHEN lv_removed_plan;

            END LOOP;
        CLOSE c_supply_plan_scenarios;

        LOG_MESSAGE('***********************************************************************');
        LOG_MESSAGE('Exiting - to evaluate flags for Collapsed BOM');
        LOG_MESSAGE('***********************************************************************');

    END IF;

    IF lv_new_plan_attached THEN
      LOG_MESSAGE(' lv_new_plan_attached is true');
    ELSE
      LOG_MESSAGE(' lv_new_plan_attached is false');
    END IF;

    IF lv_removed_plan THEN
      LOG_MESSAGE(' lv_removed_plan is true');
    ELSE
      LOG_MESSAGE(' lv_removed_plan is false');
    END IF;

      -- Deleting the Collapsed BOM table and populating the same.
      IF v_bom_cal OR lv_new_plan_attached  OR lv_removed_plan  THEN

       LOG_MESSAGE('***********************************************************************');
       LOG_MESSAGE('Entering - to evaluate the Collapsed BOM');
       LOG_MESSAGE('***********************************************************************');


       LOG_MESSAGE('Deleting the Collapsed BOM Data from table MSD_SOP_COLLAPESD_BOM_COMP');
       delete msd_sop_collapsed_bom_comp
       where demand_plan_id = p_demand_plan_id;


        lb_instance_id    := NULL;
        lb_assembly_pk    := NULL;
        lb_component_pk   := NULL;
        lb_bom_type       := NULL;
        lb_FetchComplete  := FALSE;

       LOG_MESSAGE('Opening the Collapsed BOM Cursor');
       OPEN  c_collapsed_bom(p_demand_plan_id);
             IF (c_collapsed_bom%ISOPEN) THEN

                LOOP

                   IF (lb_FetchComplete) THEN
                     EXIT;
                   END IF;

                   FETCH c_collapsed_bom BULK COLLECT INTO
                                         lb_instance_id,
                                         lb_assembly_pk,
                                         lb_component_pk,
                                         lb_bom_type
                   LIMIT ln_rows_to_fetch;


                   IF (c_collapsed_bom%NOTFOUND) THEN
                      lb_FetchComplete := TRUE;
                   END IF;


                   if c_collapsed_bom%ROWCOUNT > 0  then

                         FORALL j IN lb_instance_id.FIRST..lb_instance_id.LAST
                                    INSERT INTO msd_sop_collapsed_bom_comp
                                                       ( SR_INSTANCE_ID,
                                                         DEMAND_PLAN_ID,
                                                         SR_ASSEMBLY_PK,
                                                         SR_COMPONENT_PK,
                                                         LAST_UPDATE_DATE,
                                                         LAST_UPDATED_BY,
                                                         CREATION_DATE,
                                                         CREATED_BY,
                                                         PLAN_TYPE,
                                                         BOM_TYPE )
                                                   VALUES
                                                       ( lb_instance_id(j),
                                                         p_demand_plan_id,
                                                         lb_assembly_pk(j),
                                                         lb_component_pk(j),
                                                         sysdate,
                                                         FND_GLOBAL.USER_ID,
                                                         sysdate,
                                                         FND_GLOBAL.USER_ID,
                                                         'EOL',
                                                         lb_bom_type(j) );

                   end if;

                END LOOP;  --LOOP

             END IF;  --IF (c_collapsed_bom%ISOPEN) THEN
           CLOSE c_collapsed_bom;
           LOG_MESSAGE('Closed the Collapsed BOM Cursor');

      LOG_MESSAGE('Updating the Old Supply Plan Columns');
       -- Populating the Old_Supply_Plan_Name and Old_Supply_Plan_ID
       -- to track for the the next run if we need to re-populate the collapsed bom table for
       -- this plan or not.
       update msd_dp_scenarios
       set old_supply_plan_id      = supply_plan_id,
           old_supply_plan_name    = supply_plan_name
       where demand_plan_id   = p_demand_plan_id
       and   supply_plan_name is not null;


      LOG_MESSAGE('***********************************************************************');
      LOG_MESSAGE('Exiting - to evaluate the Collapsed BOM');
      LOG_MESSAGE('***********************************************************************');

      END IF;         --IF v_bom_cal OR lv_new_plan_attached  OR lv_removed_plan  THEN


       -- Final Commit;
       commit;

       LOG_MESSAGE('***********************************************************************');
       LOG_MESSAGE('Exiting from the procedure POPULATE_BOM Sucessfully');
       LOG_MESSAGE('***********************************************************************');

 exception
  when others then
     retcode := -1 ;
     errbuf := substr(SQLERRM,1,150);


 end populate_eol_bom;


 procedure msd_dp_pre_download_hook( errbuf   OUT NOCOPY VARCHAR2,
			             retcode  OUT NOCOPY NUMBER,
                                     p_demand_plan_id IN NUMBER )
 is
  v_plan_type NUMBER;
 begin
  retcode := 0;

  select decode(nvl(plan_type,C_DP),'SOP',C_SOP,'EOL',C_EOL,10) into v_plan_type
  from msd_demand_plans
  where demand_plan_id = p_demand_plan_id;

  IF ( v_plan_type = C_SOP ) THEN

       LOG_MESSAGE('Calling procedure - populate_bom');

       populate_bom (errbuf             => errbuf,
                     retcode            => retcode,
                     p_demand_plan_id   => p_demand_plan_id);

       if nvl(retcode,'0') <> '0' then
           v_retcode := retcode;
       else
          LOG_MESSAGE('Sucessfully completed procedure - populate_bom');
       end if;

  ELSIF ( v_plan_type = C_EOL ) THEN

       LOG_MESSAGE('Calling procedure - msd_eol_plan.msd_eol_pre_download_hook');

         msd_eol_plan.msd_eol_pre_download_hook(p_demand_plan_id);

       LOG_MESSAGE('Completed procedure - msd_eol_plan.msd_eol_pre_download_hook');

       LOG_MESSAGE('Calling procedure - populate_eol_bom');

       populate_eol_bom (errbuf             => errbuf,
                     retcode            => retcode,
                     p_demand_plan_id   => p_demand_plan_id);

       if nvl(retcode,'0') <> '0' then
           v_retcode := retcode;
       else
          LOG_MESSAGE('Sucessfully completed procedure - populate_eol_bom');
       end if;

  ELSE

        null;

  END IF;



 retcode := v_retcode;

 exception
   when others then
     retcode := -1 ;
     errbuf := substr(SQLERRM,1,150);

 end msd_dp_pre_download_hook;


END MSD_SALES_OPERATION_PLAN ;

/
