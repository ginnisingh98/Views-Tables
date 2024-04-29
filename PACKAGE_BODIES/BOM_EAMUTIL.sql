--------------------------------------------------------
--  DDL for Package Body BOM_EAMUTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_EAMUTIL" AS
/* $Header: BOMPEAMB.pls 120.0.12010000.3 2010/01/13 12:32:23 agoginen ship $ */
/*==========================================================================+
|   Copyright (c) 2001 Oracle Corporation, California, USA          	    |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMPEAMS.pls						    |
| Description  : EAM utility programs package				    |
| Created By   : Refaitheen Farook					    |
|									    |
|	item_id			Assembly_Item_Id			    |
|	org_id			Organization_id				    |
|                                                                           |
+==========================================================================*/

/***************************************************************************
* Function      : Enabled
* Returns       : VARCHAR2
* Parameters IN : None
* Parameters OUT: None
* Purpose       : Function will return the value of 'Y' or 'N'
*                 to check if eam is enabled.
*****************************************************************************/
FUNCTION Enabled RETURN VARCHAR2 IS

    x_install_eam             BOOLEAN ;
    x_status                  VARCHAR2(50);
    x_industry                VARCHAR2(50);
    x_schema                  VARCHAR2(50);


BEGIN

    x_install_eam :=
    Fnd_Installation.Get_App_Info
                         (application_short_name => 'EAM',
                          status                 => x_status,
                          industry               => x_industry,
                          oracle_schema          => x_schema);

    IF (x_status <> 'I' or x_status is NULL)
    THEN
          RETURN 'N' ;

    END IF;

    RETURN 'Y';

END;

/***************************************************************************
* Function      : Serial_Effective_Item
* Returns       : VARCHAR2
* Parameters IN : item_id,org_id
* Parameters OUT: None
* Purpose       : Function will return the value of 'Y' or 'N'
*                 to check if item is serial effective.
*****************************************************************************/
FUNCTION Serial_Effective_Item(item_id NUMBER,
                               org_id  NUMBER) RETURN VARCHAR2 IS
  l_serial_eff_item VARCHAR2(1);
BEGIN
  IF item_id IS NULL THEN
    RETURN ('N');
  END IF;

  SELECT   decode(effectivity_control , 2 , 'Y' , 'N')
    INTO   l_serial_eff_item
    FROM   mtl_system_items
   WHERE   inventory_item_id = item_id
     AND   organization_id = org_id
     AND   nvl(eam_item_type,0) IN (1,3); /*Bug 7286777: Serial Effectivity
			should be for both Asset Group as well as Rebuildable*/

     RETURN (l_serial_eff_item);

  EXCEPTION WHEN NO_DATA_FOUND THEN
    l_serial_eff_item := 'N';
    RETURN ( l_serial_eff_item );
  WHEN OTHERS THEN
    RETURN ( NULL );

END;


/***************************************************************************
* Function      : OrgIsEamEnabled
* Returns       : VARCHAR2
* Parameters IN : p_org_id
* Parameters OUT: None
* Purpose       : Function will return the value of 'Y' or 'N'
*                 to check if organization is eAM enabled.
*****************************************************************************/
FUNCTION OrgIsEamEnabled(p_org_id NUMBER) RETURN VARCHAR2
IS

    CURSOR GetEamEnabledFlag IS
     SELECT NVL(eam_enabled_flag, 'N') eam_enabled_flag
     FROM   mtl_parameters
     WHERE  organization_id = p_org_id ;


     x_eam_enabled_flag VARCHAR2(1) ;

BEGIN

   FOR X_Eam in GetEamEnabledFlag LOOP
      x_eam_enabled_flag := X_Eam.eam_enabled_flag ;
   END LOOP;

   RETURN x_eam_enabled_flag ;

END OrgIsEamEnabled  ;


/***************************************************************************
* Function      : Asset_Activity_Item
* Returns       : VARCHAR2
* Parameters IN : item_id,org_id
* Parameters OUT: None
* Purpose       : Function will return 'Y' for asset activity item
*****************************************************************************/
FUNCTION Asset_Activity_Item(item_id NUMBER,
                             org_id  NUMBER) RETURN VARCHAR2 IS
  l_asset_activity_item VARCHAR2(1);
BEGIN
  IF item_id IS NULL THEN
    RETURN ('N');
  END IF;

  SELECT   'Y'
    INTO   l_asset_activity_item
    FROM   mtl_system_items
    WHERE  inventory_item_id = item_id AND
           organization_id   = org_id AND
           nvl(eam_item_type,0) = 2;

  RETURN (l_asset_activity_item);

  EXCEPTION WHEN NO_DATA_FOUND THEN
    l_asset_activity_item := 'N';
    RETURN ( l_asset_activity_item );

  WHEN OTHERS THEN
    RETURN ( NULL );
END;


/***************************************************************************
* Function      : Asset_Group_Item
* Returns       : VARCHAR2
* Parameters IN : item_id,org_id
* Parameters OUT: None
* Purpose       : Function will return 'Y' for asset group item
*****************************************************************************/
FUNCTION Asset_Group_Item(item_id NUMBER,
                          org_id  NUMBER) RETURN VARCHAR2 IS
  l_asset_group_item VARCHAR2(1);
BEGIN
  IF item_id IS NULL THEN
    RETURN ('N');
  END IF;

  SELECT   'Y'
    INTO   l_asset_group_item
    FROM   mtl_system_items
    WHERE  inventory_item_id = item_id AND
           organization_id   = org_id AND
           nvl(eam_item_type,0) = 1;

  RETURN (l_asset_group_item);

  EXCEPTION WHEN NO_DATA_FOUND THEN
    l_asset_group_item := 'N';
    RETURN ( l_asset_group_item );

  WHEN OTHERS THEN
    RETURN ( NULL );
END;

/***************************************************************************
* Function      : Direct_Item
* Returns       : VARCHAR2
* Parameters IN : item_id,org_id
* Parameters OUT: None
* Purpose       : Function will return 'Y' for direct item
*****************************************************************************/
FUNCTION Direct_Item(item_id NUMBER,
                     org_id  NUMBER) RETURN VARCHAR2 IS
  l_direct_item VARCHAR2(1);
BEGIN
  IF item_id IS NULL THEN
    RETURN ('N');
  END IF;

  SELECT   'Y'
    INTO   l_direct_item
    FROM   mtl_system_items
    WHERE  inventory_item_id = item_id AND
           organization_id   = org_id AND
           /*inventory_item_flag = 'Y' AND  Bug 7566475 Removing the and condition on the column inventory_item_flag*/
	   stock_enabled_flag = 'N';

  RETURN (l_direct_item);

  EXCEPTION WHEN NO_DATA_FOUND THEN
    l_direct_item := 'N';
    RETURN ( l_direct_item );

  WHEN OTHERS THEN
    RETURN ( NULL );
END;

END BOM_EAMUTIL;

/
