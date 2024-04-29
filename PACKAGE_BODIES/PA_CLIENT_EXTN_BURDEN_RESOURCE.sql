--------------------------------------------------------
--  DDL for Package Body PA_CLIENT_EXTN_BURDEN_RESOURCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CLIENT_EXTN_BURDEN_RESOURCE" AS
/* $Header: PAXBRGCB.pls 120.1 2005/08/23 19:18:40 spunathi noship $ */

  FUNCTION CLIENT_GROUPING
 ( p_job_id				IN       PA_EXPENDITURE_ITEMS_ALL.job_id%type DEFAULT NULL,
   p_non_labor_resource                 IN       PA_EXPENDITURE_ITEMS_ALL.non_labor_resource%type DEFAULT NULL,
   p_non_labor_resource_orgn_id   	IN       PA_EXPENDITURE_ITEMS_ALL.organization_id%type DEFAULT NULL,
   p_wip_resource_id                    IN       PA_EXPENDITURE_ITEMS_ALL.wip_resource_id%type DEFAULT NULL,
   p_incurred_by_person_id           	IN       PA_EXPENDITURES_ALL.incurred_by_person_id%type DEFAULT NULL,
   p_inventory_item_id                  IN       PA_EXPENDITURE_ITEMS_ALL.inventory_item_id%type DEFAULT NULL,
   p_vendor_id                          IN       PA_COMMITMENT_TXNS.vendor_id%type DEFAULT NULL,
   p_bom_equipment_resource_id  	IN       PA_COMMITMENT_TXNS.bom_equipment_resource_id%type DEFAULT NULL,
   p_bom_labor_resource_id          	IN       PA_COMMITMENT_TXNS.bom_labor_resource_id%type DEFAULT NULL
  ) RETURN varchar2 IS

   v_grouping_method   varchar2(2000) default null;

  BEGIN

  IF NVL(FND_PROFILE.value('PA_RPT_BTC_SRC_RESRC'), 'N') = 'Y' THEN

  null;

    /*
    ** CLIENT CUSTOMIZATIONS BEGINS HERE .
    ** modify the value of v_grouping_method with the additional grouping criteria
    */

  END IF;

     RETURN v_grouping_method;

  EXCEPTION

    WHEN OTHERS THEN
        RAISE;

  END CLIENT_GROUPING;

 PROCEDURE CLIENT_COLUMN_VALUES
 ( p_job_id                             IN OUT NOCOPY       PA_EXPENDITURE_ITEMS_ALL.job_id%type,
   p_non_labor_resource               	IN OUT NOCOPY       PA_EXPENDITURE_ITEMS_ALL.non_labor_resource%type,
   p_non_labor_resource_orgn_id   	IN OUT NOCOPY       PA_EXPENDITURE_ITEMS_ALL.organization_id%type,
   p_wip_resource_id                    IN OUT NOCOPY       PA_EXPENDITURE_ITEMS_ALL.wip_resource_id%type,
   p_incurred_by_person_id           	IN OUT NOCOPY       PA_EXPENDITURES_ALL.incurred_by_person_id%type,
   p_inventory_item_id                  IN OUT NOCOPY       PA_EXPENDITURE_ITEMS_ALL.inventory_item_id%type,
   p_vendor_id                          IN OUT NOCOPY       PA_COMMITMENT_TXNS.vendor_id%type,
   p_bom_equipment_resource_id  	IN OUT NOCOPY       PA_COMMITMENT_TXNS.bom_equipment_resource_id%type,
   p_bom_labor_resource_id          	IN OUT NOCOPY       PA_COMMITMENT_TXNS.bom_labor_resource_id%type
  )

  IS

  BEGIN

  null;

  /* This client extension filters out the column values needs to be
     populated in pa_expenditure_items table, when a new expenditure item is created by the
     Burden Summarization process based on the additional summarization grouping.
     These column values, which have been included in the grouping criteria in the function
     CLIENT_GROUPING, should be commented out from the below code.
  */
   p_job_id                    	:= null;
   p_non_labor_resource         := null;
   p_non_labor_resource_orgn_id := null;
   p_incurred_by_person_id      := null;
   p_inventory_item_id          := null;
   p_vendor_id                  := null;
   p_bom_equipment_resource_id 	:= null;
   p_bom_labor_resource_id      := null;

   EXCEPTION
     WHEN OTHERS THEN
        RAISE;
 END CLIENT_COLUMN_VALUES;

END PA_CLIENT_EXTN_BURDEN_RESOURCE;

/
