--------------------------------------------------------
--  DDL for Package Body MSC_DRP_SRC_ALLOC_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_DRP_SRC_ALLOC_RULES" AS
/* $Header: MSCALOCB.pls 120.0 2005/10/26 12:41 rawasthi noship $ */
l_debug     varchar2(30) := FND_PROFILE.Value('MRP_DEBUG');


/********************************************************
PROCEDURE : log_message
********************************************************/

PROCEDURE log_message( p_user_info IN VARCHAR2) IS
BEGIN
       FND_FILE.PUT_LINE(FND_FILE.LOG, p_user_info);
EXCEPTION
   WHEN OTHERS THEN
   RAISE;
END log_message;


PROCEDURE MISSING_SRC_ALLOC_RULES (
                                          errbuf        OUT NOCOPY VARCHAR2,
                                          retcode       OUT NOCOPY VARCHAR2,
                                          p_instance_id IN  NUMBER,
										  p_assignment_set IN VARCHAR2,
										  p_validation IN NUMBER  ) IS

  CURSOR c1 (l_instance_id number, l_assignment_set VARCHAR2 ) IS
  SELECT
  distinct
  MAS.ASSIGNMENT_SET_NAME,
  MSR.SOURCING_RULE_NAME,
  MTP1.ORGANIZATION_CODE FROM_ORG,
  MTP2.ORGANIZATION_CODE TO_ORG,
  MSI.ITEM_NAME,
  decode(MSA.ASSIGNMENT_TYPE,3,'Item-Instance',6,'Item-Instance-Organization',9,'Item-Instance-region') ASSIGNMENT_LEVEL
FROM
  MSC_ASSIGNMENT_SETS MAS,
  MSC_SR_ASSIGNMENTS MSA,
  MSC_SR_SOURCE_ORG MSSO,
  MSC_SR_RECEIPT_ORG MSRO,
  MSC_SOURCING_RULES MSR,
  MSC_SYSTEM_ITEMS MSI,
  MSC_TRADING_PARTNERS MTP1,
  MSC_TRADING_PARTNERS MTP2
WHERE MAS.ASSIGNMENT_SET_NAME= l_assignment_set
  AND MAS.ASSIGNMENT_SET_ID = MSA.ASSIGNMENT_SET_ID
  AND MSA.SR_INSTANCE_ID = MSI.SR_INSTANCE_ID
  AND MSA.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
  AND nvl(MSA.ORGANIZATION_ID, MSI.ORGANIZATION_ID) = MSI.ORGANIZATION_ID
  AND MSI.PLAN_ID = -1
  AND MSI.DRP_PLANNED = 1
  AND MSA.SOURCING_RULE_ID = MSR.SOURCING_RULE_ID
  AND MSA.SOURCING_RULE_ID = MSRO.SOURCING_RULE_ID
  AND MSA.SOURCING_RULE_TYPE =1
  AND MSA.ASSIGNMENT_TYPE in (3,6,9)
  AND MSRO.SR_RECEIPT_ID = MSSO.SR_RECEIPT_ID
  AND MSSO.SOURCE_TYPE=1
  AND MSSO.SOURCE_ORGANIZATION_ID = MTP1.SR_TP_ID
  AND MSSO.SR_INSTANCE_ID= MTP1.SR_INSTANCE_ID
  AND MTP1.PARTNER_TYPE=3
  AND nvl(MSA.ORGANIZATION_ID, MSI.ORGANIZATION_ID) = MTP2.SR_TP_ID
  AND MSA.SR_INSTANCE_ID= MTP2.SR_INSTANCE_ID
  AND MTP2.PARTNER_TYPE=3
  AND MSA.SR_INSTANCE_ID=l_instance_id
  and NOT EXISTS (SELECT 1 from msc_sr_assignments msa1 where
                                MSA1.ASSIGNMENT_SET_ID = MSA.ASSIGNMENT_SET_ID
                            AND MSA1.SR_INSTANCE_ID = MSA.SR_INSTANCE_ID
							AND MSA1.sourcing_rule_type =3
                            AND MSA1.ORGANIZATION_ID = MSSO.SOURCE_ORGANIZATION_ID
				 )
UNION ALL
  SELECT
  MAS.ASSIGNMENT_SET_NAME,
  MSR.SOURCING_RULE_NAME,
  MTP1.ORGANIZATION_CODE FROM_ORG,
  MTP2.ORGANIZATION_CODE TO_ORG,
  MSI.ITEM_NAME,
  decode(MSA.ASSIGNMENT_TYPE,5,'Category-Instance-Org',8,'Category-Instance-Region') ASSIGNMENT_LEVEL
FROM
  MSC_ASSIGNMENT_SETS MAS,
  MSC_SR_ASSIGNMENTS MSA,
  MSC_SR_SOURCE_ORG MSSO,
  MSC_SR_RECEIPT_ORG MSRO,
  MSC_SOURCING_RULES MSR,
  MSC_ITEM_CATEGORIES CAT,
  MSC_SYSTEM_ITEMS MSI,
  MSC_TRADING_PARTNERS MTP1,
  MSC_TRADING_PARTNERS MTP2
WHERE MAS.ASSIGNMENT_SET_NAME= l_assignment_set
  AND MAS.ASSIGNMENT_SET_ID = MSA.ASSIGNMENT_SET_ID
  AND NVL(MSA.ORGANIZATION_ID, CAT.ORGANIZATION_ID)
               = CAT.ORGANIZATION_ID
  AND MSA.SR_INSTANCE_ID = CAT.SR_INSTANCE_ID
  AND CAT.CATEGORY_NAME = MSA.CATEGORY_NAME
  AND CAT.CATEGORY_SET_ID = MSA.CATEGORY_SET_ID
  AND MSI.INVENTORY_ITEM_ID = CAT.INVENTORY_ITEM_ID
  AND MSI.ORGANIZATION_ID = CAT.ORGANIZATION_ID
  AND MSI.SR_INSTANCE_ID = CAT.SR_INSTANCE_ID
  AND MSI.PLAN_ID = -1
  AND MSI.DRP_PLANNED = 1
  AND MSA.SOURCING_RULE_ID = MSR.SOURCING_RULE_ID
  AND MSA.SOURCING_RULE_ID = MSRO.SOURCING_RULE_ID
  AND MSA.SOURCING_RULE_TYPE =1
  AND MSA.ASSIGNMENT_TYPE in (5,8)
  AND MSRO.SR_RECEIPT_ID = MSSO.SR_RECEIPT_ID
  AND MSSO.SOURCE_TYPE=1
  AND MSSO.SOURCE_ORGANIZATION_ID = MTP1.SR_TP_ID
  AND MSSO.SR_INSTANCE_ID= MTP1.SR_INSTANCE_ID
  AND MTP1.PARTNER_TYPE=3
  AND nvl(MSA.ORGANIZATION_ID, CAT.ORGANIZATION_ID) = MTP2.SR_TP_ID
  AND MSA.SR_INSTANCE_ID= MTP2.SR_INSTANCE_ID
  AND MTP2.PARTNER_TYPE=3
  AND MSA.SR_INSTANCE_ID=l_instance_id
  and NOT EXISTS (SELECT 1 from msc_sr_assignments msa1 where
                                MSA1.ASSIGNMENT_SET_ID = MSA.ASSIGNMENT_SET_ID
                            AND MSA1.SR_INSTANCE_ID = MSA.SR_INSTANCE_ID
							AND MSA1.sourcing_rule_type =3
                            AND MSA1.ORGANIZATION_ID = MSSO.SOURCE_ORGANIZATION_ID
				 );



  CURSOR src_rule_cur (l_instance_id number, l_assignment_set VARCHAR2) IS
  SELECT
  distinct
  MAS.ASSIGNMENT_SET_NAME,
  MSR.SOURCING_RULE_NAME,
  MTP1.ORGANIZATION_CODE FROM_ORG,
  MTP2.ORGANIZATION_CODE TO_ORG,
  MSI.ITEM_NAME,
  decode(MSA.ASSIGNMENT_TYPE,3,'Item-Instance',6,'Item-Instance-Organization',9,'Item-Instance-region') ASSIGNMENT_LEVEL
FROM
  MSC_ASSIGNMENT_SETS MAS,
  MSC_SR_ASSIGNMENTS MSA,
  MSC_SR_SOURCE_ORG MSSO,
  MSC_SR_RECEIPT_ORG MSRO,
  MSC_SOURCING_RULES MSR,
  MSC_SYSTEM_ITEMS MSI,
  MSC_TRADING_PARTNERS MTP1,
  MSC_TRADING_PARTNERS MTP2
WHERE MAS.ASSIGNMENT_SET_NAME= l_assignment_set
  AND MAS.ASSIGNMENT_SET_ID = MSA.ASSIGNMENT_SET_ID
  AND MSA.SR_INSTANCE_ID = MSI.SR_INSTANCE_ID
  AND MSA.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
  AND nvl(MSA.ORGANIZATION_ID, MSI.ORGANIZATION_ID) = MSI.ORGANIZATION_ID
  AND MSI.PLAN_ID = -1
  AND MSI.DRP_PLANNED = 1
  AND MSA.SOURCING_RULE_ID = MSR.SOURCING_RULE_ID
  AND MSA.SOURCING_RULE_ID = MSRO.SOURCING_RULE_ID
  AND MSA.SOURCING_RULE_TYPE =1
  AND MSA.ASSIGNMENT_TYPE in (3,6,9)
  AND MSRO.SR_RECEIPT_ID = MSSO.SR_RECEIPT_ID
  AND MSSO.SOURCE_TYPE=1
  AND MSSO.SOURCE_ORGANIZATION_ID = MTP1.SR_TP_ID
  AND MSSO.SR_INSTANCE_ID= MTP1.SR_INSTANCE_ID
  AND MTP1.PARTNER_TYPE=3
  AND nvl(MSA.ORGANIZATION_ID, MSI.ORGANIZATION_ID) = MTP2.SR_TP_ID
  AND MSA.SR_INSTANCE_ID= MTP2.SR_INSTANCE_ID
  AND MTP2.PARTNER_TYPE=3
  AND MSA.SR_INSTANCE_ID=l_instance_id
  AND NOT EXISTS (
                   select 1 from MSC_SR_ASSIGNMENTS MSA1, MSC_DRP_ALLOC_RULES MDAR, MSC_DRP_ALLOC_RULE_DATES MDARD,
				                 MSC_DRP_ALLOC_RECEIPT_RULES MDARR
                            WHERE MSA1.ASSIGNMENT_SET_ID = MAS.ASSIGNMENT_SET_ID
                              AND MSA1.SOURCING_RULE_TYPE = 3
							  AND (MSA1.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID OR MSA1.INVENTORY_ITEM_ID is null)
							  AND MSA1.ALLOCATION_RULE_ID = MDAR.RULE_ID
							  AND MDAR.RULE_ID = MDARD.RULE_ID
							  AND nvl(MDARD.DISABLE_DATE, SYSDATE) >= SYSDATE
							  AND MDARD.TIME_PHASE_ID = MDARR.TIME_PHASE_ID
							  AND MDARR.SR_INSTANCE_ID = MSA1.SR_INSTANCE_ID
							  AND (MDARR.TO_ORGANIZATION_ID = nvl(MSA.ORGANIZATION_ID, MSI.ORGANIZATION_ID) AND
							       MSA1.ORGANIZATION_ID = MSSO.SOURCE_ORGANIZATION_ID)
					)
 UNION ALL
  SELECT
  MAS.ASSIGNMENT_SET_NAME,
  MSR.SOURCING_RULE_NAME,
  MTP1.ORGANIZATION_CODE FROM_ORG,
  MTP2.ORGANIZATION_CODE TO_ORG,
  MSI.ITEM_NAME,
  decode(MSA.ASSIGNMENT_TYPE,5,'Category-Instance-Org',8,'Category-Instance-Region') ASSIGNMENT_LEVEL
FROM
  MSC_ASSIGNMENT_SETS MAS,
  MSC_SR_ASSIGNMENTS MSA,
  MSC_SR_SOURCE_ORG MSSO,
  MSC_SR_RECEIPT_ORG MSRO,
  MSC_SOURCING_RULES MSR,
  MSC_ITEM_CATEGORIES CAT,
  MSC_SYSTEM_ITEMS MSI,
  MSC_TRADING_PARTNERS MTP1,
  MSC_TRADING_PARTNERS MTP2
WHERE MAS.ASSIGNMENT_SET_NAME= l_assignment_set
  AND MAS.ASSIGNMENT_SET_ID = MSA.ASSIGNMENT_SET_ID
  AND NVL(MSA.ORGANIZATION_ID, CAT.ORGANIZATION_ID)
               = CAT.ORGANIZATION_ID
  AND MSA.SR_INSTANCE_ID = CAT.SR_INSTANCE_ID
  AND CAT.CATEGORY_NAME = MSA.CATEGORY_NAME
  AND CAT.CATEGORY_SET_ID = MSA.CATEGORY_SET_ID
  AND MSI.INVENTORY_ITEM_ID = CAT.INVENTORY_ITEM_ID
  AND MSI.ORGANIZATION_ID = CAT.ORGANIZATION_ID
  AND MSI.SR_INSTANCE_ID = CAT.SR_INSTANCE_ID
  AND MSI.PLAN_ID = -1
  AND MSI.DRP_PLANNED = 1
  AND MSA.SOURCING_RULE_ID = MSR.SOURCING_RULE_ID
  AND MSA.SOURCING_RULE_ID = MSRO.SOURCING_RULE_ID
  AND MSA.SOURCING_RULE_TYPE =1
  AND MSA.ASSIGNMENT_TYPE in (5,8)
  AND MSRO.SR_RECEIPT_ID = MSSO.SR_RECEIPT_ID
  AND MSSO.SOURCE_TYPE=1
  AND MSSO.SOURCE_ORGANIZATION_ID = MTP1.SR_TP_ID
  AND MSSO.SR_INSTANCE_ID= MTP1.SR_INSTANCE_ID
  AND MTP1.PARTNER_TYPE=3
  AND nvl(MSA.ORGANIZATION_ID, CAT.ORGANIZATION_ID) = MTP2.SR_TP_ID
  AND MSA.SR_INSTANCE_ID= MTP2.SR_INSTANCE_ID
  AND MTP2.PARTNER_TYPE=3
  AND MSA.SR_INSTANCE_ID=l_instance_id
  AND NOT EXISTS (
                   select 1 from MSC_SR_ASSIGNMENTS MSA1, MSC_DRP_ALLOC_RULES MDAR, MSC_DRP_ALLOC_RULE_DATES MDARD,
				                 MSC_DRP_ALLOC_RECEIPT_RULES MDARR
                            WHERE MSA1.ASSIGNMENT_SET_ID = MAS.ASSIGNMENT_SET_ID
                              AND MSA1.SOURCING_RULE_TYPE = 3
							  AND (MSA1.CATEGORY_NAME = CAT.CATEGORY_NAME OR MSA1.CATEGORY_NAME is null)
							  AND MSA1.ALLOCATION_RULE_ID = MDAR.RULE_ID
							  AND MDAR.RULE_ID = MDARD.RULE_ID
							  AND nvl(MDARD.DISABLE_DATE, SYSDATE) >= SYSDATE
							  AND MDARD.TIME_PHASE_ID = MDARR.TIME_PHASE_ID
							  AND MDARR.SR_INSTANCE_ID = MSA1.SR_INSTANCE_ID
							  AND (MDARR.TO_ORGANIZATION_ID = nvl(MSA.ORGANIZATION_ID, CAT.ORGANIZATION_ID) AND
							       MSA1.ORGANIZATION_ID = MSSO.SOURCE_ORGANIZATION_ID)
					)
order by ASSIGNMENT_SET_NAME,  SOURCING_RULE_NAME ;


 CURSOR alloc_rule_cur (l_instance_id number, l_assignment_set VARCHAR2) IS
 select MAS.ASSIGNMENT_SET_NAME,
        MDAR.NAME,
	    MTP1.ORGANIZATION_CODE FROM_ORG,
	    MTP2.ORGANIZATION_CODE TO_ORG,
	    MSI.ITEM_NAME,
        decode(MSA1.ASSIGNMENT_TYPE,6,'Item-Instance-Org') ASSIGNMENT_LEVEL
 FROM MSC_ASSIGNMENT_SETS MAS,
     MSC_SR_ASSIGNMENTS MSA1,
	 MSC_DRP_ALLOC_RULES MDAR,
	 MSC_DRP_ALLOC_RULE_DATES MDARD,
	 MSC_SYSTEM_ITEMS MSI,
	 MSC_DRP_ALLOC_RECEIPT_RULES MDARR,
	 MSC_TRADING_PARTNERS MTP1,
	 MSC_TRADING_PARTNERS MTP2
WHERE MAS.ASSIGNMENT_SET_NAME= l_assignment_set
AND MAS.ASSIGNMENT_SET_ID = MSA1.ASSIGNMENT_SET_ID
AND   MSA1.SOURCING_RULE_TYPE = 3
AND MSA1.ALLOCATION_RULE_ID = MDAR.RULE_ID
AND MDAR.RULE_ID = MDARD.RULE_ID
AND nvl(MDARD.DISABLE_DATE, SYSDATE) >= SYSDATE
AND MDARD.TIME_PHASE_ID = MDARR.TIME_PHASE_ID
AND MDARR.SR_INSTANCE_ID = MSA1.SR_INSTANCE_ID
AND MSA1.ASSIGNMENT_TYPE = 6
AND MSA1.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
AND MSA1.SR_INSTANCE_ID = MSI.SR_INSTANCE_ID
AND MSA1.ORGANIZATION_ID = MSI.ORGANIZATION_ID
AND MSI.PLAN_ID=-1
AND MSI.DRP_PLANNED = 1
AND MSA1.ORGANIZATION_ID = MTP1.SR_TP_ID
AND MSA1.SR_INSTANCE_ID= MTP1.SR_INSTANCE_ID
AND MTP1.PARTNER_TYPE=3
AND MDARR.TO_ORGANIZATION_ID = MTP2.SR_TP_ID
AND MDARR.SR_INSTANCE_ID = MTP2.SR_INSTANCE_ID
AND MTP2.PARTNER_TYPE=3
AND MSA1.ORGANIZATION_ID <> MDARR.TO_ORGANIZATION_ID
AND MSA1.SR_INSTANCE_ID= l_instance_id
AND NOT EXISTS (SELECT 1 FROM  MSC_SR_ASSIGNMENTS MSA, MSC_SR_SOURCE_ORG MSSO,
                               MSC_SR_RECEIPT_ORG MSRO,  MSC_SOURCING_RULES MSR
						 WHERE MSA.ASSIGNMENT_SET_ID = MSA1.ASSIGNMENT_SET_ID
						 AND   MSA.SR_INSTANCE_ID = MSA1.SR_INSTANCE_ID
						 AND MSA.SOURCING_RULE_ID = MSR.SOURCING_RULE_ID
                         AND MSA.SOURCING_RULE_ID = MSRO.SOURCING_RULE_ID
                         AND MSA.SOURCING_RULE_TYPE =1
                         AND MSA.ASSIGNMENT_TYPE in (3,4,6,9)
                         AND MSRO.SR_RECEIPT_ID = MSSO.SR_RECEIPT_ID
                         AND MSSO.SOURCE_TYPE=1
						 AND (MSA.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID OR MSA.INVENTORY_ITEM_ID is null)
						 AND MSA.SR_INSTANCE_ID = MSI.SR_INSTANCE_ID
						 AND (MDARR.TO_ORGANIZATION_ID = nvl(MSA.ORGANIZATION_ID, MSI.ORGANIZATION_ID) AND
							       MSA1.ORGANIZATION_ID = MSSO.SOURCE_ORGANIZATION_ID)
			   )
UNION ALL
select MAS.ASSIGNMENT_SET_NAME,
       MDAR.NAME,
	   MTP1.ORGANIZATION_CODE FROM_ORG,
	   MTP2.ORGANIZATION_CODE TO_ORG,
	   MSI.ITEM_NAME,
       decode(MSA1.ASSIGNMENT_TYPE,5,'Category-Instance-Org') ASSIGNMENT_LEVEL
FROM MSC_ASSIGNMENT_SETS MAS,
     MSC_SR_ASSIGNMENTS MSA1,
	 MSC_DRP_ALLOC_RULES MDAR,
	 MSC_DRP_ALLOC_RULE_DATES MDARD,
	 MSC_SYSTEM_ITEMS MSI,
	 MSC_ITEM_CATEGORIES CAT,
	 MSC_DRP_ALLOC_RECEIPT_RULES MDARR,
	 MSC_TRADING_PARTNERS MTP1,
	 MSC_TRADING_PARTNERS MTP2
WHERE MAS.ASSIGNMENT_SET_NAME= l_assignment_set
AND MAS.ASSIGNMENT_SET_ID = MSA1.ASSIGNMENT_SET_ID
AND   MSA1.SOURCING_RULE_TYPE = 3
AND MSA1.ALLOCATION_RULE_ID = MDAR.RULE_ID
AND MDAR.RULE_ID = MDARD.RULE_ID
AND nvl(MDARD.DISABLE_DATE, SYSDATE) >= SYSDATE
AND MDARD.TIME_PHASE_ID = MDARR.TIME_PHASE_ID
AND MDARR.SR_INSTANCE_ID = MSA1.SR_INSTANCE_ID
AND MSA1.ASSIGNMENT_TYPE = 5
AND MSA1.SR_INSTANCE_ID = CAT.SR_INSTANCE_ID
AND CAT.CATEGORY_NAME = MSA1.CATEGORY_NAME
AND CAT.CATEGORY_SET_ID = MSA1.CATEGORY_SET_ID
AND CAT.ORGANIZATION_ID = MSA1.ORGANIZATION_ID
AND MSI.INVENTORY_ITEM_ID = CAT.INVENTORY_ITEM_ID
AND MSI.ORGANIZATION_ID = CAT.ORGANIZATION_ID
AND MSI.SR_INSTANCE_ID = CAT.SR_INSTANCE_ID
AND MSI.PLAN_ID=-1
AND MSI.DRP_PLANNED = 1
AND MSA1.ORGANIZATION_ID = MTP1.SR_TP_ID
AND MSA1.SR_INSTANCE_ID= MTP1.SR_INSTANCE_ID
AND MTP1.PARTNER_TYPE=3
AND MDARR.TO_ORGANIZATION_ID = MTP2.SR_TP_ID
AND MDARR.SR_INSTANCE_ID = MTP2.SR_INSTANCE_ID
AND MTP2.PARTNER_TYPE=3
AND MSA1.ORGANIZATION_ID <> MDARR.TO_ORGANIZATION_ID
AND MSA1.SR_INSTANCE_ID= l_instance_id
AND NOT EXISTS (SELECT 1 FROM  MSC_SR_ASSIGNMENTS MSA, MSC_SR_SOURCE_ORG MSSO,
                               MSC_SR_RECEIPT_ORG MSRO,  MSC_SOURCING_RULES MSR
						 WHERE MSA.ASSIGNMENT_SET_ID = MSA1.ASSIGNMENT_SET_ID
						 AND   MSA.SR_INSTANCE_ID = MSA1.SR_INSTANCE_ID
						 AND MSA.SOURCING_RULE_ID = MSR.SOURCING_RULE_ID
                         AND MSA.SOURCING_RULE_ID = MSRO.SOURCING_RULE_ID
                         AND MSA.SOURCING_RULE_TYPE =1
                         AND MSA.ASSIGNMENT_TYPE in (5,8)
                         AND MSRO.SR_RECEIPT_ID = MSSO.SR_RECEIPT_ID
                         AND MSSO.SOURCE_TYPE=1
						 AND MSA.CATEGORY_NAME = MSA1.CATEGORY_NAME
						 AND MSA.CATEGORY_SET_ID = MSA1.CATEGORY_SET_ID
						 AND (MDARR.TO_ORGANIZATION_ID = nvl(MSA.ORGANIZATION_ID, CAT.ORGANIZATION_ID) AND
							       MSA1.ORGANIZATION_ID = MSSO.SOURCE_ORGANIZATION_ID)
			   )
order by ASSIGNMENT_SET_NAME, NAME ;


CURSOR src_org_cur (l_instance_id number, l_assignment_set VARCHAR2) IS
select mas.assignment_set_name,
       mdar.name,
       mtp.organization_code FROM_ORG,
       decode(msa.assignment_type, 4, 'Instance-Org', 5, 'Category-Instance-Org', 6, 'Item-Instance-Org') ASSIGNMENT_LEVEL
FROM   msc_assignment_sets mas,
       msc_sr_assignments msa,
       msc_drp_alloc_rules mdar,
       msc_trading_partners mtp,
       msc_drp_alloc_rule_dates mdard
where mas.ASSIGNMENT_SET_NAME= l_assignment_set
and   mas.assignment_set_id=msa.assignment_set_id
and   msa.allocation_rule_id = mdar.rule_id
and   msa.organization_id = mtp.sr_tp_id
and   msa.sr_instance_id= mtp.sr_instance_id
and   msa.sourcing_rule_type =3
and   mtp.partner_type=3
and   msa.sr_instance_id = l_instance_id
and   mdard.rule_id = mdar.rule_id
and   nvl(mdard.disable_date, sysdate) >= sysdate
and   msa.organization_id not in (select to_organization_id from msc_drp_alloc_receipt_rules mdarr
	  					          where mdarr.time_phase_id = mdard.time_phase_id
								  and   mdarr.sr_instance_id = msa.sr_instance_id
								 );


CURSOR c2 (l_instance_id number, l_assignment_set VARCHAR2) IS
select mas.assignment_set_name,
       mdar.name,
       mtp.organization_code FROM_ORG,
	   mtp2.organization_code TO_ORG,
	   msi.item_name
FROM   msc_assignment_sets mas,
       msc_sr_assignments msa,
       msc_drp_alloc_rules mdar,
       msc_trading_partners mtp,
	   msc_trading_partners mtp2,
	   msc_system_items msi,
       msc_drp_alloc_rule_dates mdard,
	   msc_drp_alloc_receipt_rules mdarr
where mas.ASSIGNMENT_SET_NAME= l_assignment_set
and   mas.assignment_set_id=msa.assignment_set_id
and   msa.allocation_rule_id = mdar.rule_id
and   msa.organization_id = mtp.sr_tp_id
and   msa.sr_instance_id= mtp.sr_instance_id
and   msa.sourcing_rule_type =3
and   mtp.partner_type=3
and   msa.assignment_type=6
and   msa.inventory_item_id = msi.inventory_item_id
and   msa.sr_instance_id=msi.sr_instance_id
and   msa.organization_id = msi.organization_id
and   msi.plan_id=-1
and   msi.drp_planned=1
and   msa.sr_instance_id = l_instance_id
and   mdard.rule_id = mdar.rule_id
and   nvl(mdard.disable_date, sysdate) >= sysdate
and   mdard.dmd_pri_override=1
and   mdarr.time_phase_id = mdard.time_phase_id
and   mdarr.sr_instance_id = msa.sr_instance_id
and   mdarr.dmd_priority is null
and   mdarr.to_organization_id = mtp2.sr_tp_id
and   mdarr.sr_instance_id = mtp2.sr_instance_id
and   mtp2.partner_type=3
UNION ALL
select mas.assignment_set_name,
       mdar.name,
       mtp.organization_code FROM_ORG,
	   mtp2.organization_code TO_ORG,
	   msi.item_name
FROM   msc_assignment_sets mas,
       msc_sr_assignments msa,
       msc_drp_alloc_rules mdar,
       msc_trading_partners mtp,
	   msc_trading_partners mtp2,
	   MSC_ITEM_CATEGORIES CAT,
	   msc_system_items msi,
       msc_drp_alloc_rule_dates mdard,
	   msc_drp_alloc_receipt_rules mdarr
where mas.ASSIGNMENT_SET_NAME= l_assignment_set
and   mas.assignment_set_id=msa.assignment_set_id
and   msa.allocation_rule_id = mdar.rule_id
and   msa.organization_id = mtp.sr_tp_id
and   msa.sr_instance_id= mtp.sr_instance_id
and   msa.sourcing_rule_type =3
and   mtp.partner_type=3
and   msa.assignment_type=5
and   msa.category_name = cat.category_name
and   msa.category_set_id = cat.category_set_id
and   msa.organization_id = cat.organization_id
and   msa.sr_instance_id = cat.sr_instance_id
and   msi.inventory_item_id = cat.inventory_item_id
and   msi.organization_id = cat.organization_id
and   msi.sr_instance_id = cat.sr_instance_id
and   msi.plan_id=-1
and   msi.drp_planned=1
and   msa.sr_instance_id = l_instance_id
and   mdard.rule_id = mdar.rule_id
and   nvl(mdard.disable_date, sysdate) >= sysdate
and   mdard.dmd_pri_override=1
and   mdarr.time_phase_id = mdard.time_phase_id
and   mdarr.sr_instance_id = msa.sr_instance_id
and   mdarr.dmd_priority is null
and   mdarr.to_organization_id = mtp2.sr_tp_id
and   mdarr.sr_instance_id = mtp2.sr_instance_id
and   mtp2.partner_type=3;

l_org_exists number;

BEGIN

   retcode := 0;
   l_org_exists := 0;

   IF p_validation = 1 THEN
   FND_MESSAGE.SET_NAME('MSC', 'MSC_ALLOC_RULE_NOT_FOUND');
   LOG_MESSAGE(FND_MESSAGE.GET);
   log_message('                                                                                                ');

   log_message('Assignment Set Name      Sourcing Rule      From org    To Org      Item             Assignment Level');
   log_message('--------------------     --------------     ----------  --------   ------------      -----------------');

   FOR c1_rec in c1 (p_instance_id, p_assignment_set) LOOP

    BEGIN
     log_message(rpad(c1_rec.ASSIGNMENT_SET_NAME,25,' ')||
	       	                                rpad(c1_rec.SOURCING_RULE_NAME,20,' ')||
	       	                                rpad(c1_rec.FROM_ORG,11,' ')||
	       	                                rpad(c1_rec.TO_ORG,11,' ')||
	       	                                rpad(c1_rec.ITEM_NAME,20,' ')||
	       	                                rpad(c1_rec.ASSIGNMENT_LEVEL,27,' ')
	       	                                );
	  l_org_exists :=1 ;

     EXCEPTION
     WHEN NO_DATA_FOUND THEN
   		NULL;
     WHEN OTHERS THEN
       LOG_MESSAGE('Error in Concurrent program while looking orgs for Sourcing Rules');
             LOG_MESSAGE(SQLERRM);
             retcode := 2;
     END;
    END LOOP;

   END IF;


   IF p_validation = 2 THEN
   FND_MESSAGE.SET_NAME('MSC', 'MSC_SRC_ORG_NOT_FOUND');
   LOG_MESSAGE(FND_MESSAGE.GET);
   log_message('                                                                                                ');

   log_message('Assignment Set Name      Sourcing Rule      From org    To Org      Item             Assignment Level');
   log_message('--------------------     --------------     ----------  --------   ------------      -----------------');

   FOR src_rule in src_rule_cur (p_instance_id, p_assignment_set) LOOP

    BEGIN
     log_message(rpad(src_rule.ASSIGNMENT_SET_NAME,25,' ')||
	       	                                rpad(src_rule.SOURCING_RULE_NAME,20,' ')||
	       	                                rpad(src_rule.FROM_ORG,11,' ')||
	       	                                rpad(src_rule.TO_ORG,11,' ')||
	       	                                rpad(src_rule.ITEM_NAME,20,' ')||
	       	                                rpad(src_rule.ASSIGNMENT_LEVEL,27,' ')
	       	                                );
	  l_org_exists :=1 ;

     EXCEPTION
     WHEN NO_DATA_FOUND THEN
   		NULL;
     WHEN OTHERS THEN
       LOG_MESSAGE('Error in Concurrent program while looking orgs for Sourcing Rules');
             LOG_MESSAGE(SQLERRM);
             retcode := 2;
     END;
    END LOOP;
 END IF;


   IF p_validation = 3 THEN
   FND_MESSAGE.SET_NAME('MSC', 'MSC_ALLOC_ORG_NOT_FOUND');
   LOG_MESSAGE(FND_MESSAGE.GET);
   log_message('                                                                                                ');

   log_message('Assignment Set Name      Allocation Rule     From org   To Org      Item              Assignment Level');
   log_message('--------------------     ----------------    ---------  --------  -------------      ------------------');

   FOR alloc_rule in alloc_rule_cur (p_instance_id, p_assignment_set) LOOP

    BEGIN
     log_message(rpad(alloc_rule.ASSIGNMENT_SET_NAME,25,' ')||
	       	                                rpad(alloc_rule.NAME,20,' ')||
	       	                                rpad(alloc_rule.FROM_ORG,11,' ')||
	       	                                rpad(alloc_rule.TO_ORG,11,' ')||
	       	                                rpad(alloc_rule.ITEM_NAME,20,' ')||
	       	                                rpad(alloc_rule.ASSIGNMENT_LEVEL,27,' ')
	       	                                );
	  l_org_exists :=1 ;

     EXCEPTION
     WHEN NO_DATA_FOUND THEN
   		NULL;
     WHEN OTHERS THEN
       LOG_MESSAGE('Error in Concurrent program while looking orgs for Allocation Rules');
             LOG_MESSAGE(SQLERRM);
             retcode := 2;
     END;
    END LOOP;
   END IF;

   IF p_validation = 4 THEN
   FND_MESSAGE.SET_NAME('MSC', 'MSC_SOURCE_ORG_NOT_FOUND');
   LOG_MESSAGE(FND_MESSAGE.GET);
   log_message('                                                                                                ');

   log_message('Assignment Set Name      Allocation Rule     From org     Assignment Level');
   log_message('--------------------     ----------------    ----------   ----------------');

    FOR src_org in src_org_cur (p_instance_id, p_assignment_set) LOOP

    BEGIN
     log_message(rpad(src_org.ASSIGNMENT_SET_NAME,25,' ')||
	       	                                rpad(src_org.NAME,20,' ')||
	       	                                rpad(src_org.FROM_ORG,15,' ')||
	       	                                rpad(src_org.ASSIGNMENT_LEVEL,27,' ')
	       	                                );
	  l_org_exists :=1 ;

     EXCEPTION
     WHEN NO_DATA_FOUND THEN
   		NULL;
     WHEN OTHERS THEN
       LOG_MESSAGE('Error in Concurrent program while looking orgs for Allocation Rules');
             LOG_MESSAGE(SQLERRM);
             retcode := 2;
     END;
    END LOOP;
  END IF;

 IF p_validation = 5 THEN
   FND_MESSAGE.SET_NAME('MSC', 'MSC_MISSING_DMD_PRIORITY');
   LOG_MESSAGE(FND_MESSAGE.GET);
   log_message('                                                                                                ');

   log_message('Assignment Set Name      Allocation Rule     From org     To Org       Item');
   log_message('--------------------     ----------------    ----------   -------     ---------');

    FOR c2_rec in c2 (p_instance_id, p_assignment_set) LOOP

    BEGIN
     log_message(rpad(c2_rec.ASSIGNMENT_SET_NAME,25,' ')||
	       	                                rpad(c2_rec.NAME,20,' ')||
	       	                                rpad(c2_rec.FROM_ORG,15,' ')||
	       	                                rpad(c2_rec.TO_ORG,15,' ')||
	       	                                rpad(c2_rec.ITEM_NAME,27,' ')
	       	                                );
	  l_org_exists :=1 ;

     EXCEPTION
     WHEN NO_DATA_FOUND THEN
   		NULL;
     WHEN OTHERS THEN
       LOG_MESSAGE('Error in Concurrent program while looking orgs for Allocation Rules');
             LOG_MESSAGE(SQLERRM);
             retcode := 2;
     END;
    END LOOP;
  END IF;

    IF l_org_exists =1 THEN
    retcode := 1;
    END IF;

 EXCEPTION
  WHEN OTHERS THEN
    LOG_MESSAGE('Error in Concurrent program');
             LOG_MESSAGE(SQLERRM);
             retcode := 2;

 END MISSING_SRC_ALLOC_RULES;

END MSC_DRP_SRC_ALLOC_RULES;


/
