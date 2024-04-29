--------------------------------------------------------
--  DDL for Package Body EAM_ASSET_MOVE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_ASSET_MOVE_UTIL" AS
  /* $Header: EAMAMUTB.pls 120.12.12010000.4 2008/10/23 08:01:53 vchidura ship $ */

-- validate whether an asset under context can be moved or not (before Asset Move UI is thrown)
-- Also called by AssetMove() which will be called for a list of asset records
g_pkg_name CONSTANT VARCHAR2(30):= 'EAM_ASSET_MOVE_UTIL';

Procedure isValidMove(
		p_instance_id	IN	NUMBER,
		p_transaction_date	IN DATE,
		p_inventory_item_id	IN NUMBER,
		p_curr_org_id	IN NUMBER,
		x_return_status IN OUT NOCOPY varchar2,
		x_return_message OUT NOCOPY varchar2
		)
IS
   isValidMove varchar2(1) := 'N';

    --logging variables
   l_api_name  constant VARCHAR2(30) := 'isValidMove';
   l_module    VARCHAR2(200);
   l_log_level CONSTANT NUMBER       := fnd_log.g_current_runtime_level;
   l_uLog      CONSTANT BOOLEAN      := fnd_log.level_unexpected >= l_log_level;
   l_pLog      CONSTANT BOOLEAN      := l_uLog AND fnd_log.level_procedure >= l_log_level;
   l_exLog     CONSTANT BOOLEAN      := l_uLog AND fnd_log.level_exception >= l_log_level;
   l_sLog      CONSTANT BOOLEAN      := l_pLog AND fnd_log.level_statement >= l_log_level;
   l_full_name CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;



  BEGIN

	IF (l_ulog) THEN
            l_module := 'eam.plsql.'|| l_full_name;
        END IF;

	IF (l_plog) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'Entering ' || l_full_name);
        END IF;

        if(eam_asset_move_util.isOpenPeriod(p_curr_org_id,p_transaction_date)) then
                isValidMove := 'Y';
	    else
	        isValidMove := 'N';
	        x_return_status:='N';
	        x_return_message:='EAM_INV_NO_OPEN_PERIOD';
	        Return;
	    end if;

	     if(NOT(eam_asset_move_util.isAssetRoute(p_instance_id))) then
                 isValidMove := 'Y';
	     else
	        isValidMove := 'N';
	        x_return_status:='N';
	        x_return_message:='EAM_ASSET_ROUTE';
	        Return;
	     End if;

	     if(NOT(eam_asset_move_util.hasPropMngrLink(p_instance_id))) then
                 isValidMove := 'Y';
	     else
	        isValidMove := 'N';
	        x_return_status:='N';
	        x_return_message:='EAM_ASSET_PROP_MNGR';
	        Return;
	     End if;

	   if(eam_asset_move_util.isTransactable(p_inventory_item_id,p_curr_org_id)) then
               isValidMove := 'Y';
	     else
	        isValidMove := 'N';
	        x_return_status:='N';
	        x_return_message:='EAM_ASSET_NON_TRANSACT';
	        Return;
	     End if;

	     if(NOT(eam_asset_move_util.isInTransit( p_instance_id))) then
                 isValidMove := 'Y';
	     else
	        isValidMove := 'N';
	        x_return_status:='N';
	        x_return_message:='EAM_ASSET_IN_TRANSIT';
	        Return;
	     End if;

             if(NOT(eam_asset_move_util.hasProdEquipLink(p_instance_id))) then
                 isValidMove := 'Y';
	     else
	        isValidMove := 'N';
	        x_return_status:='N';
	        x_return_message:='EAM_ASSET_PROD_EQUIP';
	        Return;
	     End if;


	  IF isValidMove = 'Y' THEN
	      x_return_status := 'Y';
	      --x_return_message:='Is valid Move';
	      Return;
	  ELSE
	      x_return_status := 'N';
	  END IF;

     IF (l_plog) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'Exiting ' || l_full_name);
     END IF;

  END isValidMove;


PROCEDURE isValidAssetMove(
		p_asset_hierarchy_REC	IN	eam_asset_move_pub.asset_move_hierarchy_REC_TYPE,
		p_dest_org_id IN NUMBER,
		p_counter     IN NUMBER,
		x_return_status OUT NOCOPY varchar2,
		x_return_message OUT NOCOPY varchar2
		)
IS
   isValidMove varchar2(1) := 'N';
 --logging variables
   l_api_name  constant VARCHAR2(30) := 'isValidAssetMove';
   l_module    VARCHAR2(200);
   l_log_level CONSTANT NUMBER       := fnd_log.g_current_runtime_level;
   l_uLog      CONSTANT BOOLEAN      := fnd_log.level_unexpected >= l_log_level;
   l_pLog      CONSTANT BOOLEAN      := l_uLog AND fnd_log.level_procedure >= l_log_level;
   l_exLog	    CONSTANT BOOLEAN      := l_uLog AND fnd_log.level_exception >= l_log_level;
   l_sLog      CONSTANT BOOLEAN      := l_pLog AND fnd_log.level_statement >= l_log_level;
   l_full_name CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;


BEGIN
                            --     Dbms_Output.put_line('Processing isValidAssetMove');
   IF (l_ulog) THEN
    l_module := 'eam.plsql.'|| l_full_name;
   END IF;
   IF (l_plog) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'Entering ' || l_full_name||'for'||p_asset_hierarchy_REC.instance_id);
   END IF;
    IF(p_counter<>1) THEN
    IF(isInMaintOrg(p_asset_hierarchy_REC.instance_id
                   ,p_asset_hierarchy_REC.current_org_id
                   ,p_asset_hierarchy_REC.gen_object_id)) THEN
	     isValidMove := 'Y';
	  else
	    isValidMove := 'N';
	    x_return_status:='N';
	    x_return_message:='EAM_ASSET_DIFF_MAINT_ORG';
	    Return;
	  end if;
    END IF;

--This is call to check whether the item is assigned to the Current organisation.
  --The check for the Destination organisation is done in the EAM_ASSET_MOVE_PUB.prepareMoveAsset
    IF(isItemAssigned(p_asset_hierarchy_REC.inventory_item_id,p_asset_hierarchy_REC.current_org_id )) THEN
       isValidMove := 'Y';
	  else
	    isValidMove := 'N';
	    x_return_status:='N';
	    x_return_message:='EAM_ITEM_NOT_ASSIGN';
	    Return;
	  end if;

    IF isValidMove = 'Y' THEN
	     -- x_return_status := 'Y';
	     -- x_return_message:='Is valid Move';
       --Dbms_Output.put_line('calling isValidAssetMoveProcedure');

	IF (l_plog) THEN
	 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'Entering ' || l_full_name||'for'||p_asset_hierarchy_REC.instance_id);
	END IF;

      eam_asset_move_util.isValidMove(p_asset_hierarchy_REC.instance_id,
	                               sysdate	,
		                       p_asset_hierarchy_REC.inventory_item_id	,
	                               p_asset_hierarchy_REC.CURRENT_ORG_ID	,
	                               x_return_status ,
		                       x_return_message );
    ELSE
	      x_return_status := 'N';
	      Return;
	  END IF;

     IF x_return_status = 'Y' THEN

--for 7370638-AMWB-MR
	if(eam_asset_move_util.hasSubInventory(p_asset_hierarchy_REC.instance_id)) then
                 x_return_status := 'Y';  --which means it's a valid asset
		else
		    x_return_status:='MR';--This status is used to perform the Misc. receipt into intermediate subinvenotry
		    return;
	  End if;

     ELSE
	 x_return_status := 'N';
--for 7370638-AMWB-MR
       Return;
     END IF;

END isValidAssetMove;


FUNCTION isOpenPeriod(
	p_organization_id	IN NUMBER,
	p_transaction_date      IN DATE
	)
RETURN BOOLEAN
IS
   x_period_id NUMBER;
   l_open_past_period BOOLEAN;

--logging variables
   l_api_name  constant VARCHAR2(30) := 'isOpenPeriod';
   l_module    VARCHAR2(200);
   l_log_level CONSTANT NUMBER       := fnd_log.g_current_runtime_level;
   l_uLog      CONSTANT BOOLEAN      := fnd_log.level_unexpected >= l_log_level;
   l_pLog      CONSTANT BOOLEAN      := l_uLog AND fnd_log.level_procedure >= l_log_level;
   l_exLog	    CONSTANT BOOLEAN      := l_uLog AND fnd_log.level_exception >= l_log_level;
   l_sLog      CONSTANT BOOLEAN      := l_pLog AND fnd_log.level_statement >= l_log_level;
   l_full_name CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;


BEGIN
                            --     Dbms_Output.put_line('Processing isValidAssetMove');
   IF (l_ulog) THEN
    l_module := 'eam.plsql.'|| l_full_name;
   END IF;

   IF (l_plog) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'Entering ' || l_full_name);
   END IF;

         --Dbms_Output.put_line('Processing isOpenPeriod');
	l_open_past_period :=FALSE   ;                               /*important FOR TIME being 4th parameter IS made NULL*/
	INVTTMTX.tdatechk(p_organization_id,p_transaction_date,x_period_id,l_open_past_period);--as for time being

	 If (x_period_id <> 0) then
		 return TRUE;
	 else
		 return FALSE;
  END IF;

   IF (l_plog) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'Exiting ' || l_full_name);
   END IF;
end isOpenPeriod;


FUNCTION isTransactable(
	     p_inventory_item_id      IN    NUMBER
	     ,p_organization_id        IN     NUMBER
	     )
RETURN BOOlEAN
IS
   l_flag varchar2(30);
--logging variables
   l_api_name  constant VARCHAR2(30) := 'isTransactable';
   l_module    VARCHAR2(200);
   l_log_level CONSTANT NUMBER       := fnd_log.g_current_runtime_level;
   l_uLog      CONSTANT BOOLEAN      := fnd_log.level_unexpected >= l_log_level;
   l_pLog      CONSTANT BOOLEAN      := l_uLog AND fnd_log.level_procedure >= l_log_level;
   l_exLog	    CONSTANT BOOLEAN      := l_uLog AND fnd_log.level_exception >= l_log_level;
   l_sLog      CONSTANT BOOLEAN      := l_pLog AND fnd_log.level_statement >= l_log_level;
   l_full_name CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;


BEGIN

   IF (l_ulog) THEN
    l_module := 'eam.plsql.'|| l_full_name;
   END IF;

   IF (l_plog) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'Entering ' || l_full_name);
   END IF;
    --Dbms_Output.put_line('Processing isTransactable');

BEGIN
		select MTL_TRANSACTIONS_ENABLED_FLAG into l_flag from
		mtl_system_items_b where
		inventory_item_id = p_inventory_item_id
		and organization_id = p_organization_id;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      SELECT 'N' INTO  l_flag FROM dual;
 END;

		if (l_flag <> 'N') then
		RETURN TRUE;
		ELSE	RETURN FALSE;
    END IF;


   IF (l_plog) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'Exiting ' || l_full_name);
   END IF;

END isTransactable;


FUNCTION hasSubInventory(
	     p_instance_id      IN     NUMBER
	     )
RETURN BOOLEAN
IS

	l_subinv_code csi_item_instances.inv_subinventory_name%TYPE;
--logging variables
   l_api_name  constant VARCHAR2(30) := 'hasSubInventory';
   l_module    VARCHAR2(200);
   l_log_level CONSTANT NUMBER       := fnd_log.g_current_runtime_level;
   l_uLog      CONSTANT BOOLEAN      := fnd_log.level_unexpected >= l_log_level;
   l_pLog      CONSTANT BOOLEAN      := l_uLog AND fnd_log.level_procedure >= l_log_level;
   l_exLog	    CONSTANT BOOLEAN      := l_uLog AND fnd_log.level_exception >= l_log_level;
   l_sLog      CONSTANT BOOLEAN      := l_pLog AND fnd_log.level_statement >= l_log_level;
   l_full_name CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;


BEGIN

   IF (l_ulog) THEN
    l_module := 'eam.plsql.'|| l_full_name;
   END IF;

   IF (l_plog) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'Entering ' || l_full_name);
   END IF;
     --Dbms_Output.put_line('Processing hasSubInventory');

  BEGIN
		SELECT  inv_subinventory_name into l_subinv_code
		FROM    csi_item_instances
		WHERE   instance_id = p_instance_id;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
    l_subinv_code := NULL;
  END;



		IF (l_subinv_code IS NOT NULL ) then
			--Dbms_Output.put_line('l_subinv_code is: '||l_subinv_code);
      RETURN TRUE;
		ELSE RETURN FALSE;

        END IF;

   IF (l_plog) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'Exiting ' || l_full_name);
   END IF;

      END   hasSubInventory;


FUNCTION isLocated(
	     p_instance_id      IN     NUMBER
	     )
RETURN boolean
IS

l_location_id NUMBER;
--logging variables
   l_api_name  constant VARCHAR2(30) := 'isLocated';
   l_module    VARCHAR2(200);
   l_log_level CONSTANT NUMBER       := fnd_log.g_current_runtime_level;
   l_uLog      CONSTANT BOOLEAN      := fnd_log.level_unexpected >= l_log_level;
   l_pLog      CONSTANT BOOLEAN      := l_uLog AND fnd_log.level_procedure >= l_log_level;
   l_exLog	    CONSTANT BOOLEAN      := l_uLog AND fnd_log.level_exception >= l_log_level;
   l_sLog      CONSTANT BOOLEAN      := l_pLog AND fnd_log.level_statement >= l_log_level;
   l_full_name CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;


BEGIN

   IF (l_ulog) THEN
    l_module := 'eam.plsql.'|| l_full_name;
   END IF;

   IF (l_plog) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'Entering ' || l_full_name);
   END IF;
    -- Dbms_Output.put_line('Processing isLocated');

BEGIN
select location_id
into l_location_id
from csi_item_instances  WHERE
instance_id=P_instance_id;

 EXCEPTION
    WHEN NO_DATA_FOUND THEN
    l_location_id := NULL;
 END;

if (l_location_id IS NOT NULL) then
			RETURN TRUE;
		ELSE	RETURN FALSE;

END IF;

   IF (l_plog) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'Exiting ' || l_full_name);
   END IF;

      END      isLocated;

FUNCTION isInTransit(
	     p_instance_id      IN     NUMBER
	     )
RETURN boolean

IS
     l_intransitFlag  NUMBER;


--logging variables
   l_api_name  constant VARCHAR2(30) := 'isInTransit';
   l_module    VARCHAR2(200);
   l_log_level CONSTANT NUMBER       := fnd_log.g_current_runtime_level;
   l_uLog      CONSTANT BOOLEAN      := fnd_log.level_unexpected >= l_log_level;
   l_pLog      CONSTANT BOOLEAN      := l_uLog AND fnd_log.level_procedure >= l_log_level;
   l_exLog	    CONSTANT BOOLEAN      := l_uLog AND fnd_log.level_exception >= l_log_level;
   l_sLog      CONSTANT BOOLEAN      := l_pLog AND fnd_log.level_statement >= l_log_level;
   l_full_name CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;


BEGIN

   IF (l_ulog) THEN
    l_module := 'eam.plsql.'|| l_full_name;
   END IF;

   IF (l_plog) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'Entering ' || l_full_name);
   END IF;
   --Dbms_Output.put_line('Processing isInTransit');

 BEGIN
select msn.current_status into l_intransitFlag  from mtl_serial_numbers msn,
                                                 csi_item_instances cii
                                            WHERE cii.INSTANCE_id=p_instance_id
                                            AND cii.INVENTORY_ITEM_ID = msn.INVENTORY_ITEM_ID
                                            AND cii.SERIAL_NUMBER = msn.SERIAL_NUMBER ;
                                           -- AND cii.INV_ORGANIZATION_ID = msn.CURRENT_ORGANIZATION_ID ;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      SELECT 0 INTO  l_intransitFlag FROM dual;
 END;


if(l_intransitFlag =5) then
			RETURN TRUE;
		ELSE	RETURN FALSE;
END IF;

   IF (l_plog) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'Exiting ' || l_full_name);
   END IF;

      END   isInTransit;

FUNCTION isAssetRoute(
	     p_instance_id      IN     NUMBER
	     )
RETURN boolean
IS
  l_network_asset_flag varchar2(1);
--logging variables
   l_api_name  constant VARCHAR2(30) := 'isAssetRoute';
   l_module    VARCHAR2(200);
   l_log_level CONSTANT NUMBER       := fnd_log.g_current_runtime_level;
   l_uLog      CONSTANT BOOLEAN      := fnd_log.level_unexpected >= l_log_level;
   l_pLog      CONSTANT BOOLEAN      := l_uLog AND fnd_log.level_procedure >= l_log_level;
   l_exLog	    CONSTANT BOOLEAN      := l_uLog AND fnd_log.level_exception >= l_log_level;
   l_sLog      CONSTANT BOOLEAN      := l_pLog AND fnd_log.level_statement >= l_log_level;
   l_full_name CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;


BEGIN

   IF (l_ulog) THEN
    l_module := 'eam.plsql.'|| l_full_name;
   END IF;

   IF (l_plog) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'Entering ' || l_full_name);
   END IF;

    -- Dbms_Output.put_line('Processing isAssetRoute');
  BEGIN
		SELECT  network_asset_flag INTO l_network_asset_flag
		FROM    csi_item_instances
		WHERE   instance_id = p_instance_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      SELECT 'N' INTO  l_network_asset_flag FROM dual;
 END;


		if (l_network_asset_flag ='Y') then
			RETURN TRUE;
		ELSE	RETURN FALSE;
  END IF;

   IF (l_plog) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'Exiting ' || l_full_name);
   END IF;
END isAssetRoute;


FUNCTION hasProdEquipLink(
	     p_instance_id      IN     NUMBER
	     )
RETURN boolean
IS

	l_EQUIPMENT_GEN_OBJECT_ID NUMBER;
--logging variables
   l_api_name  constant VARCHAR2(30) := 'hasProdEquipLink';
   l_module    VARCHAR2(200);
   l_log_level CONSTANT NUMBER       := fnd_log.g_current_runtime_level;
   l_uLog      CONSTANT BOOLEAN      := fnd_log.level_unexpected >= l_log_level;
   l_pLog      CONSTANT BOOLEAN      := l_uLog AND fnd_log.level_procedure >= l_log_level;
   l_exLog	    CONSTANT BOOLEAN      := l_uLog AND fnd_log.level_exception >= l_log_level;
   l_sLog      CONSTANT BOOLEAN      := l_pLog AND fnd_log.level_statement >= l_log_level;
   l_full_name CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;


BEGIN

   IF (l_ulog) THEN
    l_module := 'eam.plsql.'|| l_full_name;
   END IF;

   IF (l_plog) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'Entering ' || l_full_name);
   END IF;

   --Dbms_Output.put_line('Processing hasProdEquipLink');

BEGIN
SELECT EQUIPMENT_GEN_OBJECT_ID INTO l_EQUIPMENT_GEN_OBJECT_ID FROM csi_item_instances WHERE instance_id=p_instance_id;

  --Dbms_Output.put_line(l_EQUIPMENT_GEN_OBJECT_ID);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
    l_EQUIPMENT_GEN_OBJECT_ID := NULL;
END;

if(l_EQUIPMENT_GEN_OBJECT_ID IS NOT NULL) then
			RETURN TRUE  ;

		ELSE
      RETURN FALSE ;

END IF;
  --Dbms_Output.put_line('Completed Processing hasProdEquipLink');

  IF (l_plog) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'Exiting ' || l_full_name);
   END IF;


      END  hasProdEquipLink;


FUNCTION hasPropMngrLink(
	     p_instance_id      IN     NUMBER
	     )
RETURN boolean
IS

l_location_id Number;
--logging variables
   l_api_name  constant VARCHAR2(30) := 'hasPropMngrLink';
   l_module    VARCHAR2(200);
   l_log_level CONSTANT NUMBER       := fnd_log.g_current_runtime_level;
   l_uLog      CONSTANT BOOLEAN      := fnd_log.level_unexpected >= l_log_level;
   l_pLog      CONSTANT BOOLEAN      := l_uLog AND fnd_log.level_procedure >= l_log_level;
   l_exLog	    CONSTANT BOOLEAN      := l_uLog AND fnd_log.level_exception >= l_log_level;
   l_sLog      CONSTANT BOOLEAN      := l_pLog AND fnd_log.level_statement >= l_log_level;
   l_full_name CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;


BEGIN

   IF (l_ulog) THEN
    l_module := 'eam.plsql.'|| l_full_name;
   END IF;

   IF (l_plog) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'Entering ' || l_full_name);
   END IF;

     --Dbms_Output.put_line('Processing hasPropMngrLink');

BEGIN
SELECT pn_location_id into l_location_id
FROM csi_item_instances
where instance_id=p_instance_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
    l_location_id := NULL;
END;

if (l_location_id is NOT NULL)
THEN RETURN TRUE;
ELSE RETURN FALSE;
END IF;

 IF (l_plog) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'Exiting ' || l_full_name);
   END IF;

END hasPropMngrLink;

-- isInMaintOrg(instance_id,org_id)
	-- Assets in Diff Maint Org
	-- Assets in Diff Prod Org which are not maintained by the current parent maint_org_id

FUNCTION isInMaintOrg(
	      p_instance_id      IN     NUMBER
	     ,p_organization_id  IN     NUMBER
	     ,p_gen_object_id IN NUMBER
	     )
RETURN boolean
IS

		l_parent_object_id		NUMBER  ;
		l_parent_organization_id	NUMBER;
   l_organization_id NUMBER;
   --logging variables
   l_api_name  constant VARCHAR2(30) := 'isInMaintOrg';
   l_module    VARCHAR2(200);
   l_log_level CONSTANT NUMBER       := fnd_log.g_current_runtime_level;
   l_uLog      CONSTANT BOOLEAN      := fnd_log.level_unexpected >= l_log_level;
   l_pLog      CONSTANT BOOLEAN      := l_uLog AND fnd_log.level_procedure >= l_log_level;
   l_exLog     CONSTANT BOOLEAN      := l_uLog AND fnd_log.level_exception >= l_log_level;
   l_sLog      CONSTANT BOOLEAN      := l_pLog AND fnd_log.level_statement >= l_log_level;
   l_full_name CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;


BEGIN

   IF (l_ulog) THEN
    l_module := 'eam.plsql.'|| l_full_name;
   END IF;

   IF (l_plog) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'Entering ' || l_full_name);
   END IF;

   --Dbms_Output.put_line('Processing isInMaintOrg');

select mp.maint_organization_id  into l_organization_id
from MTL_PARAMETERS mp,csi_item_instances cii
where mp.organization_id=cii.last_vld_organization_id
and cii.instance_id=p_instance_id  ;

--Dbms_Output.put_line('l_organization_id is'||l_organization_id);
--Dbms_Output.put_line(p_instance_id);

BEGIN
                        --selecting parent_object_id
/*
SELECT parent_object_id into l_parent_object_id FROM mtl_object_genealogy WHERE object_id =
(SELECT gen_object_id FROM mtl_serial_numbers WHERE serial_number =
(SELECT serial_number FROM csi_item_instances WHERE instance_id = p_instance_id)
)
AND parent_object_id IN (SELECT gen_object_id FROM mtl_serial_numbers)
AND    START_DATE_ACTIVE<=SYSDATE
AND Nvl(end_DATE_ACTIVE,SYSDATE+1)>=sysdate ;
*/     --commented for the bug 7129016

SELECT parent_object_id into l_parent_object_id
FROM mtl_object_genealogy
WHERE object_id =p_gen_object_id
AND parent_object_id IN (SELECT gen_object_id FROM mtl_serial_numbers)
AND    START_DATE_ACTIVE<=SYSDATE
AND Nvl(end_DATE_ACTIVE,SYSDATE+1)>=sysdate ;

   EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_parent_object_id := NULL;

END;

--Dbms_Output.put_line('l_parent_object_id is'||l_parent_object_id)  ;


   IF(l_parent_object_id IS NULL) THEN
      RETURN TRUE;
   ELSE
          --Dbms_Output.put_line('searching l_parent_organization_id');
          select mp.maint_organization_id into l_parent_organization_id
          from MTL_PARAMETERS mp,csi_item_instances cii, mtl_serial_numbers msn
          where mp.organization_id=cii.last_vld_organization_id
          and cii.serial_number=msn.serial_number
	  and cii.INVENTORY_ITEM_ID = msn.INVENTORY_ITEM_ID
          and  cii.last_vld_organization_id = msn.CURRENT_ORGANIZATION_ID
          and msn.gen_object_id=l_parent_object_id ;

          --Dbms_Output.put_line('l_parent_organization_id is'||l_parent_organization_id)  ;


      IF (l_organization_id=l_parent_organization_id) THEN
          RETURN TRUE ;
      ELSE
          RETURN FALSE;
      END IF;

   END IF;

   IF (l_plog) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'Exiting ' || l_full_name);
   END IF;

END isInMaintOrg;

FUNCTION isItemAssigned(
	     p_inventory_item_id      IN     NUMBER
	     ,p_organization_id        IN     NUMBER
	     )
RETURN boolean
IS

	     l_org_assign_chk VARCHAR2(30);

--logging variables
   l_api_name  constant VARCHAR2(30) := 'isItemAssigned';
   l_module    VARCHAR2(200);
   l_log_level CONSTANT NUMBER       := fnd_log.g_current_runtime_level;
   l_uLog      CONSTANT BOOLEAN      := fnd_log.level_unexpected >= l_log_level;
   l_pLog      CONSTANT BOOLEAN      := l_uLog AND fnd_log.level_procedure >= l_log_level;
   l_exLog	    CONSTANT BOOLEAN      := l_uLog AND fnd_log.level_exception >= l_log_level;
   l_sLog      CONSTANT BOOLEAN      := l_pLog AND fnd_log.level_statement >= l_log_level;
   l_full_name CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;


BEGIN

   IF (l_ulog) THEN
    l_module := 'eam.plsql.'|| l_full_name;
   END IF;

   IF (l_plog) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'Entering ' || l_full_name);
   END IF;
--Dbms_Output.put_line('Processing isItemAssigned');

BEGIN
SELECT ORGANIZATION_ID
INTO l_org_assign_chk
FROM mtl_system_items_b
WHERE inventory_item_id =p_inventory_item_id
AND organization_id= p_organization_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      SELECT 'N' INTO  l_org_assign_chk FROM dual;
END;



	IF(l_org_assign_chk <>'N')
	THEN
  RETURN TRUE;
  	ELSE
   RETURN FALSE;
   END IF ;

IF (l_plog) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'Exiting ' || l_full_name);
   END IF;
END  isItemAssigned;


FUNCTION isUniqueShipmentNumber(
	     p_shipment_number IN VARCHAR2
	     )
RETURN boolean
IS
	l_shipment_number NUMBER;
--logging variables
   l_api_name  constant VARCHAR2(30) := 'isUniqueShipmentNumber';
   l_module    VARCHAR2(200);
   l_log_level CONSTANT NUMBER       := fnd_log.g_current_runtime_level;
   l_uLog      CONSTANT BOOLEAN      := fnd_log.level_unexpected >= l_log_level;
   l_pLog      CONSTANT BOOLEAN      := l_uLog AND fnd_log.level_procedure >= l_log_level;
   l_exLog	    CONSTANT BOOLEAN      := l_uLog AND fnd_log.level_exception >= l_log_level;
   l_sLog      CONSTANT BOOLEAN      := l_pLog AND fnd_log.level_statement >= l_log_level;
   l_full_name CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;


BEGIN

   IF (l_ulog) THEN
    l_module := 'eam.plsql.'|| l_full_name;
   END IF;

   IF (l_plog) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'Entering ' || l_full_name);
   END IF;
--Dbms_Output.put_line('Processing isUniqueShipmentNumber');

	IF((INVTTMTX.ship_number_validation(p_shipment_number))=1) THEN
  RETURN TRUE;
  ELSE
   RETURN FALSE;
   END IF;

    IF (l_plog) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'Exiting ' || l_full_name);
   END IF;
END isUniqueShipmentNumber;

FUNCTION translate_message(
		prod IN VARCHAR2
		,msg IN VARCHAR2
		)
RETURN VARCHAR2 IS
BEGIN
   fnd_message.set_name(prod, msg);
   return fnd_message.get;
END translate_message;

END eam_asset_move_util;

/
