--------------------------------------------------------
--  DDL for Package Body PO_VMI_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_VMI_GRP" as
--$Header: POXGVMIB.pls 115.10 2002/12/14 01:07:50 fdubois noship $

--===============+============================================================+
--|                    Copyright (c) 2002 Oracle Corporation                  |
--|                       Redwood Shores, California, USA                     |
--|                            All rights reserved.                           |
--============================================================================+
--|                                                                           |
--|  FILENAME :            POXGVMIB.pls                                       |
--|                                                                           |
--|  DESCRIPTION:          This package contains the function that return TRUE|
--|                        if there exist a VMI ASL within the Operating Unit |
--|                                                                           |
--|  FUNCTION/PROCEDURE:   exist_vmi_asl                                      |
--|                                                                           |
--|  HISTORY:              Created : fdubois - 27-FEB-2002: Empty Stubb       |
--|                        Modified: fdubois - 28-FEB-2002: Add logic for the |
--|                                  function                                 |
--|                        Modified: fdubois - 13-MAR-2002 : Modified dbdrv   |
--|                                  syntax                                   |
--|                        Modified :fdubois - 15-APR-2002 : Add              |
--|                                  validate_global_vmi_asl function         |
--|===========================================================================+


/*===========================================================================
  FUNCTION NAME:	exist_vmi_asl

  DESCRIPTION:		the function retunrs TRUE if there exist a VMI ASL
                        within the Operating Unit. If there are none it
                        returns FALSE

  PARAMETERS:		In:
			Out: TRUE if exists VMI ASL

  DESIGN REFERENCES:	APXSSFSO_VMI_DLD.doc


  CHANGE HISTORY:	Created		27-FEB-02	FDUBOIS
                        Empty Stubb
===========================================================================*/
FUNCTION  exist_vmi_asl RETURN BOOLEAN is

l_exist_VMI_ASL         BOOLEAN ;
l_count_exist_VMI_ASL   NUMBER  ;

/* VMI FPH Start  */
BEGIN

   -- Returns 1 if there exist a VMI ASL within the current OU
   SELECT count('x')
   INTO   l_count_exist_VMI_ASL
   FROM   dual
   WHERE  exists
  (  SELECT 'X'
     FROM   po_approved_supplier_list  pasl,
            po_vendor_sites pvs ,
            po_asl_status_rules_v pasr ,
            po_asl_attributes paa
     WHERE  pasl.vendor_site_id = pvs.vendor_site_id
     AND    pasr.status_id = pasl.asl_status_id
     AND    pasr.business_rule like '2_SOURCING'
     AND    pasr.allow_action_flag like 'Y'
     AND   ( pasl.disable_flag = 'N'
           OR pasl.disable_flag IS NULL)
     AND paa.asl_id = pasl.asl_id
     AND paa.enable_vmi_flag =  'Y' ) ;


   -- Assign the boolean value depending on the return count
   IF l_count_exist_VMI_ASL = 1
   THEN
      l_exist_VMI_ASL := TRUE ;
   ELSE
      l_exist_VMI_ASL := FALSE ;
   END IF ;

   -- Return the value
   return l_exist_VMI_ASL ;

END exist_vmi_asl ;


/*===========================================================================
  FUNCTION NAME:	validate_global_vmi_asl

  DESCRIPTION:		the function retunrs TRUE if the Global ASL can be
                        VMI for the IN parameters (define the ASL). False
                        otherwize. It then also return the Validation Error
                        Message name

  PARAMETERS:		In: INVENTORY_ITEM_ID      :Item identifier
                            SUPPLIER_SITE_ID       : supplier site identifier

			Out:VALIDATION_ERROR_NAME  : Error message name

                        Return: TRUE if OK to have Global VMI ASL

  DESIGN REFERENCES:	MGD_VMI_ASL_DLD.rtf


  CHANGE HISTORY:	Created		15-APR-02	FDUBOIS
===========================================================================*/
FUNCTION  validate_global_vmi_asl  (x_inventory_item_id       IN   number ,
                                    x_supplier_site_id        IN   number ,
                                    x_validation_error_name   OUT  NOCOPY varchar2 )
RETURN BOOLEAN is

l_purch_encumbrance_flag   varchar2(1) ;
l_req_encumbrance_flag     varchar2(1) ;


-- This cursor brings the info needed to validate the VMI Global ASL
-- It brings back the Item/Inventory Org Info for all inventory Org
-- / Item linked to the SOB that is associated with the supplier site
-- Operating Unit
cursor c_vmi_global_asl (x_inventory_item_id      NUMBER ,
                         x_supplier_site_id       NUMBER ) is
select hoi.organization_id ,
       DECODE(HOI.ORG_INFORMATION_CONTEXT, 'Accounting Information',
       TO_NUMBER(HOI.ORG_INFORMATION3), TO_NUMBER(NULL)) operating_unit ,
       mp.wms_enabled_flag ,
       imst.whse_code ,
       msi.item_type ,
       msi.outside_operation_flag ,
       msi.eam_item_type ,
       msi.base_item_id ,
       msi.bom_item_type ,
       msi.replenish_to_order_flag ,
       msi.auto_created_config_flag
from   gl_sets_of_books gsob ,
       hr_organization_units hou ,
       hr_organization_information hoi ,
       mtl_parameters mp ,
       hr_organization_information hoi2 ,
       mtl_system_items msi ,
       ic_whse_mst imst
where  HOU.ORGANIZATION_ID = HOI.ORGANIZATION_ID
and    HOU.ORGANIZATION_ID = MP.ORGANIZATION_ID
and    HOI.ORG_INFORMATION_CONTEXT||'' ='Accounting Information'
and    HOI.ORG_INFORMATION1 = TO_CHAR(GSOB.SET_OF_BOOKS_ID)
and    hoi.organization_id = hoi2.organization_id
and    hoi2.org_information_context = 'CLASS'
and    hoi2.org_information1 = 'INV'
and    msi.organization_id = hoi.organization_id
and    msi.inventory_item_id = x_inventory_item_id
and    hoi.organization_id = imst.mtl_organization_id (+)
and    GSOB.SET_OF_BOOKS_ID =  (
       select set_of_books_id
       from   po_vendor_sites_all pvsa ,
              HR_ORGANIZATION_INFORMATION HOI	,
              GL_SETS_OF_BOOKS GSOB
       where  pvsa.vendor_site_id = x_supplier_site_id
       and    NVL(DECODE(HOI.ORG_INFORMATION_CONTEXT,'Accounting Information',
	      TO_NUMBER(HOI.ORG_INFORMATION3),TO_NUMBER(NULL)),-99)= NVL(pvsa.org_id,-99)
       and    HOI.ORG_INFORMATION1 = TO_CHAR(GSOB.SET_OF_BOOKS_ID)
       and    rownum < 2) ;

BEGIN


-- First Validate the Encumbrance for the GLobal ASL
-- get the encumbrance flags for the OU linked to the vendor site id
SELECT  fspa.purch_encumbrance_flag,
        fspa.req_encumbrance_flag
INTO    l_purch_encumbrance_flag ,
        l_req_encumbrance_flag
FROM    FINANCIALS_SYSTEM_PARAMS_ALL fspa ,
        po_vendor_sites_all pvs
WHERE   pvs.vendor_site_id = x_supplier_site_id
AND     NVL(fspa.org_id,-99) = NVL(pvs.org_id,-99) ;


-- *** ENCUMBRANCE ACCOUNTING VALIDATION ***
-- First check for the encumbrance
IF l_purch_encumbrance_flag = 'Y' OR l_req_encumbrance_flag = 'Y'
THEN
    -- Set the Validation error message
    x_validation_error_name := 'PO_VMI_ENCUMBRANCE_ENABLED' ;
    -- Fail validation
    RETURN FALSE ;
END IF ;


-- Fetch the cursor into the record and loop
FOR c_vmi_global_asl_rec IN
c_vmi_global_asl(x_inventory_item_id,x_supplier_site_id)
LOOP


  -- *** OPM ITEM VALIDATION ***
  -- First check for OPM Item
  IF c_vmi_global_asl_rec.whse_code IS NOT NULL
  THEN
    -- Set the Validation error message
    x_validation_error_name := 'PO_VMI_OPM_ORG_GLOBAL' ;
    -- Exit the cursor loop
    EXIT ;
  END IF ;


  -- *** WMS INV. ORG VALIDATION ***
  -- First check for WMS enable flag
  IF c_vmi_global_asl_rec.wms_enabled_flag IN ('Y','y')
  THEN
    -- Set the Validation error message
    x_validation_error_name := 'PO_VMI_WMS_INSTALLED_GLOBAL' ;
    -- Exit the cursor loop
    EXIT ;
  END IF ;


  -- *** OSP ITEM VALIDATION ***
  -- First check for OSP Item
  IF c_vmi_global_asl_rec.outside_operation_flag = 'Y'
  THEN
    -- Set the Validation error message
    x_validation_error_name := 'PO_VMI_OSP_ITEM' ;
    -- Exit the cursor loop
    EXIT ;
  END IF ;


  -- *** CTO ITEM VALIDATION ***
  -- First check for CTO Item
  IF c_vmi_global_asl_rec.bom_item_type IN (1,2)
  OR ( c_vmi_global_asl_rec.replenish_to_order_flag = 'Y' AND
       c_vmi_global_asl_rec.base_item_id IS NULL AND
       c_vmi_global_asl_rec.auto_created_config_flag = 'Y')
  THEN
    -- Set the Validation error message
    x_validation_error_name := 'PO_VMI_CTO_ITEM' ;
    -- Exit the cursor loop
    EXIT ;
  END IF ;


  -- *** EAM ITEM VALIDATION ***
  -- First check for EAM Item
  IF c_vmi_global_asl_rec.eam_item_type IS NOT NULL
  THEN
    -- Set the Validation error message
    x_validation_error_name := 'PO_VMI_EAM_ITEM' ;
    -- Exit the cursor loop
    EXIT ;
  END IF ;


END LOOP ;


-- Test the If one record failed the validation
IF x_validation_error_name IS NOT NULL
THEN
  -- Fail validation
  RETURN FALSE ;
ELSE
  -- Pass validation
  RETURN TRUE ;
END IF ;

END validate_global_vmi_asl ;

/* VMI FPH End*/

END PO_VMI_GRP;

/
