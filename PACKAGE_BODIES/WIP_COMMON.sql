--------------------------------------------------------
--  DDL for Package Body WIP_COMMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_COMMON" AS
/* $Header: wipcommb.pls 120.0 2005/05/27 09:49:32 appldev noship $ */

--forward declarations
function check_disabled(
        X_CLASS IN VARCHAR2,
        X_ORG_ID IN NUMBER,
        X_ENTITY_TYPE IN NUMBER)
return number;

function check_valid_class(
        X_CLASS IN VARCHAR2,
        X_ORG_ID IN NUMBER)
return number;


function default_acc_class
         (X_ORG_ID       IN     NUMBER,
          X_ITEM_ID      IN     NUMBER,
          X_ENTITY_TYPE  IN     NUMBER,
          X_PROJECT_ID   IN     NUMBER,
 	  X_ERR_MESG_1   OUT NOCOPY    VARCHAR2,
	  X_ERR_CLASS_1  OUT NOCOPY    VARCHAR2,
 	  X_ERR_MESG_2   OUT NOCOPY    VARCHAR2,
	  X_ERR_CLASS_2  OUT NOCOPY    VARCHAR2
         )
return VARCHAR2 IS
  V_PRODUCT_LINE CONSTANT NUMBER := 8;
  V_COST_METHOD NUMBER(1);
  V_COST_GROUP_ID NUMBER;
  V_DISC_CLASS VARCHAR2(10);
  V_EAM_CLASS VARCHAR2(10);
  V_REP_CLASS VARCHAR2(10);
  V_PRJ_DEF_CLASS VARCHAR2(10);
  V_DISABLE_DATE DATE;
  V_RET NUMBER;
  V_RET1 NUMBER;
begin
  X_ERR_MESG_1 := NULL;
  X_ERR_CLASS_1 := NULL;
  X_ERR_MESG_2 := NULL;
  X_ERR_CLASS_2 := NULL;

  if(x_entity_type = WIP_CONSTANTS.EAM) then
    begin
      select default_eam_class
        into V_EAM_CLASS
        from wip_eam_parameters
       where organization_id = X_ORG_ID;
      return V_EAM_CLASS;
    exception
      when no_data_found then
        return null;
    end;
  end if;

  select  primary_cost_method
    into  V_COST_METHOD
  from    mtl_parameters
  where
          organization_id = X_ORG_ID;
  if( V_COST_METHOD = WIP_CONSTANTS.COST_STD ) then
        -- Standard Costing Organization
    begin
    	select  wdcac.std_discrete_class, wdcac.repetitive_assy_class
        	into V_DISC_CLASS, V_REP_CLASS
    	from    mtl_default_category_sets mdcs, mtl_item_categories mic,
       	     	wip_def_cat_acc_classes wdcac
    	where
            	mdcs.functional_area_id = V_PRODUCT_LINE and
            	mdcs.category_set_id = mic.category_set_id and
            	mic.organization_id = X_ORG_ID and
            	mic.inventory_item_id = X_ITEM_ID and
            	wdcac.organization_id = X_ORG_ID and
            	mic.category_id = wdcac.category_id and
            	wdcac.cost_group_id IS NULL;

        if( X_ENTITY_TYPE in (1,4) ) then
    		v_ret := check_disabled(V_DISC_CLASS, X_ORG_ID, X_ENTITY_TYPE);
    	elsif ( X_ENTITY_TYPE = 2) then
        	v_ret := check_disabled(V_REP_CLASS, X_ORG_ID, X_ENTITY_TYPE);
	end if;

        if( v_ret = 1 ) then
		if (X_ENTITY_TYPE in (1,4) ) then
			return(V_DISC_CLASS);
		else
			return(V_REP_CLASS);
		end if;
	else
		if( X_ENTITY_TYPE in (1,4) ) then
			X_ERR_MESG_1 := 'WIP_CLASS_PRODLINE_DISABLED';
			X_ERR_CLASS_1 := V_DISC_CLASS;
			V_DISC_CLASS := NULL;
		elsif( X_ENTITY_TYPE = 2) then
			X_ERR_MESG_1 := 'WIP_CLASS_PRODLINE_DISABLED';
			X_ERR_CLASS_1 := V_REP_CLASS;
			return(NULL);
		end if;
	end if;

    exception
        when NO_DATA_FOUND then
		if( X_ENTITY_TYPE = 2) then
			return(NULL);
		end if;
    end;
    begin
        if X_PROJECT_ID IS NOT NULL then
                        select wip_acct_class_code
                                into V_PRJ_DEF_CLASS
                        from   mrp_project_parameters mpp
                        where
                                mpp.project_id = X_PROJECT_ID and
                                mpp.organization_id = X_ORG_ID;
        end if;
    exception
        when NO_DATA_FOUND then
                   NULL;
    end;
  elsif( V_COST_METHOD in ( WIP_CONSTANTS.COST_AVG,
                            WIP_CONSTANTS.COST_FIFO,
                            WIP_CONSTANTS.COST_LIFO ) ) then
        -- Average Costing Organization
      if X_PROJECT_ID IS NOT NULL then
         select NVL(costing_group_id,1), wip_acct_class_code
           into V_COST_GROUP_ID, V_PRJ_DEF_CLASS
         from   mrp_project_parameters mpp
         where
                mpp.project_id = X_PROJECT_ID and
		mpp.organization_id = X_ORG_ID;
      else
         /* Fix for bug 2491739
            Replacing hard-coding of COST_GROUP_ID with a select statement
            that gets Cost Group ID from mtl_parameters. */
         /* V_COST_GROUP_ID := 1; */
            select default_cost_group_id
            into   V_COST_GROUP_ID
            from   mtl_parameters
            where  organization_id = X_ORG_ID;
      end if;

      begin
      		select wdcac.std_discrete_class
        		into V_DISC_CLASS
      		from   mtl_default_category_sets mdcs, mtl_item_categories mic,
             		wip_def_cat_acc_classes wdcac
      		where
            		mdcs.functional_area_id = V_PRODUCT_LINE and
            		mdcs.category_set_id = mic.category_set_id and
            		mic.organization_id = X_ORG_ID and
            		mic.inventory_item_id = X_ITEM_ID and
            		wdcac.organization_id = X_ORG_ID and
            		mic.category_id = wdcac.category_id and
            		wdcac.cost_group_id = V_COST_GROUP_ID;

    		v_ret := check_disabled(V_DISC_CLASS, X_ORG_ID, X_ENTITY_TYPE);
		if( v_ret = 1) then
			return(V_DISC_CLASS);
		else
			X_ERR_MESG_1 := 'WIP_CLASS_PRODLINE_DISABLED';
			X_ERR_CLASS_1 := V_DISC_CLASS;
			V_DISC_CLASS := NULL;
		end if;
      exception
	   when NO_DATA_FOUND then
		NULL;
      end;
  end if;

  if X_PROJECT_ID is null and V_DISC_CLASS is null then
	-- Default from wip_parameters IFF there is no project and no class
        -- defined yet.

	SELECT wp.DEFAULT_DISCRETE_CLASS
       	  INTO V_DISC_CLASS
       	  FROM WIP_PARAMETERS wp
         WHERE wp.ORGANIZATION_ID = X_ORG_ID;

        v_ret :=  check_disabled(V_DISC_CLASS, X_ORG_ID, X_ENTITY_TYPE);
	if ( v_ret = 0) then
		X_ERR_MESG_2 := 'ACCT_CLASS_IS_DISABLED';
		X_ERR_CLASS_2 := V_DISC_CLASS;
		return(NULL);
	else
		v_ret1 := check_valid_class(V_DISC_CLASS, X_ORG_ID);
		if( v_ret1 = 1) then
                  return(V_DISC_CLASS);
		else
			X_ERR_MESG_2 := 'WIP_NO_ASSOC_CLASS_CG';
			X_ERR_CLASS_2 := V_DISC_CLASS;
			return(NULL);
		end if;
	end if;
  elsif X_PROJECT_ID is not NULL and V_PRJ_DEF_CLASS is not null then
	-- Default from mrp_project_parameters

	V_DISC_CLASS := V_PRJ_DEF_CLASS;
    	v_ret := check_disabled(V_DISC_CLASS, X_ORG_ID, X_ENTITY_TYPE);
	if( v_ret = 1) then
		return(V_DISC_CLASS);
	else
		X_ERR_MESG_2 := 'WIP_CLASS_PROJPARAM_DISABLED';
		X_ERR_CLASS_2 := V_DISC_CLASS;
		return(NULL);
	end if;
  else
	return(NULL);
	-- Project Id is defined but no class defined
	-- in mrp_project_parameters or wip_def_cat_acc_classes
  end if;

exception
	when NO_DATA_FOUND then
		return(NULL);

END;


function check_disabled(
	X_CLASS IN VARCHAR2,
	X_ORG_ID IN NUMBER,
	X_ENTITY_TYPE IN NUMBER)
return number is
  V_DISABLE_DATE DATE;

BEGIN
  select nvl(wac.disable_date, SYSDATE + 1) into V_DISABLE_DATE
  from wip_accounting_classes wac
  where
        wac.organization_id = X_ORG_ID and
        wac.class_type = DECODE(X_ENTITY_TYPE, 1, WIP_CONSTANTS.DISC_CLASS,
                                               2, WIP_CONSTANTS.REP_CLASS,
                                               4, WIP_CONSTANTS.DISC_CLASS,
                                               6, WIP_CONSTANTS.DISC_CLASS) and
        wac.class_code = X_CLASS;
  if V_DISABLE_DATE <= SYSDATE then
	return(0);
  else
	return(1);
  end if;

END;


function check_valid_class(
        X_CLASS IN VARCHAR2,
        X_ORG_ID IN NUMBER)
return number is
	dummy VARCHAR2(40);
	v_primary_cost_method number;
	v_project_reference_enabled number;
BEGIN
   select PRIMARY_COST_METHOD, PROJECT_REFERENCE_ENABLED
	into v_primary_cost_method, v_project_reference_enabled
   from mtl_parameters mp
   where
 	mp.organization_id = X_ORG_ID;

   if v_primary_cost_method in ( WIP_CONSTANTS.COST_AVG,
                                 WIP_CONSTANTS.COST_FIFO,
                                 WIP_CONSTANTS.COST_LIFO ) and
       v_project_reference_enabled = 1 then
      begin
   	select distinct class_code
		into dummy
   	from   cst_cg_wip_acct_classes ccwac
   	where
		  ccwac.organization_id = X_ORG_ID and
		  ccwac.class_code = X_CLASS and
		  nvl(ccwac.disable_date, SYSDATE + 1) > SYSDATE;
	return(1);
      exception
	when NO_DATA_FOUND then
		return(0);
      end ;
   else
	return(1); -- For any other org, we don't care about cost_group
   end if;

END;


function Bill_Exists(
         p_item_id in number,
         p_org_id in number) return number is
x_bom_rev_exists number := 0;
begin

       select count(*) into x_bom_rev_exists
       from bom_bill_of_materials
       where assembly_item_id = p_item_id
       and   organization_id = p_Org_id
       and   alternate_bom_designator is null ;

       if (x_bom_rev_exists > 0) then
		RETURN 1;
       else
		RETURN 0;
       end if;

   exception
	when others then
		return -1 ;

end Bill_Exists;




function Revision_Exists(
         p_item_id in number,
         p_org_id in number) return number is
x_rev_exists number := 0;
begin

       select revision_qty_control_code into x_rev_exists
       from mtl_system_items
       where inventory_item_id = p_item_id
       and   organization_id = p_Org_id ;


       return x_rev_exists ;

   exception
 	 when no_data_found then
		return -2 ;
         when others then
                return -1 ;

end Revision_Exists;




function Routing_Exists(
         p_item_id in number,
         p_org_id in number,
         p_eff_date IN DATE := null
) return number is
x_rtg_exists number := 0;
begin

   -- Modified for ECO implement.

   IF p_eff_date IS NULL THEN
        select count(*) into x_rtg_exists
        from mtl_rtg_item_revisions
        where inventory_item_id = p_item_id
	and   organization_id = p_Org_id
	and   implementation_date is not null;
    ELSE
        select count(*) into x_rtg_exists
        from mtl_rtg_item_revisions
        where inventory_item_id = p_item_id
        and   organization_id = p_Org_id
	AND   effectivity_date <= p_eff_date
	and   implementation_date is not null;

   END IF;

   if (x_rtg_exists > 0) then
	RETURN 1;
   else
	RETURN 0;
   end if;

   exception
        when others then
                return -1 ;

end Routing_Exists;




function Is_Primary_UOM(
        p_item_id in number,
        p_org_id in number,
        p_txn_uom in varchar2,
        p_pri_uom in out nocopy varchar2) return number is
begin

   Select PRIMARY_UOM_CODE INTO p_pri_uom
   FROM   mtl_system_items
   WHERE  inventory_item_Id = p_item_id
   AND    organization_Id = p_org_id;

   if (p_txn_uom = p_pri_uom) then
	return 1 ;
   else
	return 0 ;
   end if ;

   exception
	when no_data_found then
		return -2 ;
	when others then
		return -1 ;

end Is_Primary_UOM ;

/*=====================================================================+
 | PROCEDURE
 |   get_total_quantity
 |
 | PURPOSE
 |    This procedure would return the total quantity in a job/schedule
 | in an out nocopy variable. The total quantity is the sum of all assemblies in
 | all the operations, which may be different from the start quantity.
 |
 |
 | ARGUMENTS
 |
 | EXCEPTIONS
 |
 | NOTES
 |
 +=====================================================================*/

   PROCEDURE get_total_quantity
   (
    p_organization_id             IN   NUMBER,
    p_wip_entity_id               IN   NUMBER,
    p_repetitive_schedule_id      IN   NUMBER DEFAULT NULL,
    p_total_quantity              OUT NOCOPY  NUMBER
    ) IS
   BEGIN

      SELECT SUM(quantity_in_queue)
	+ SUM(quantity_running)
	+ SUM(quantity_waiting_to_move)
	+ SUM(quantity_rejected)
	+ SUM(quantity_scrapped)
	--	+ SUM(quantity_completed)
	-- These assemblies are in some other operation
	INTO p_total_quantity
	FROM wip_operations wop
	WHERE
	wop.organization_id = p_organization_id
	AND wop.wip_entity_id = p_wip_entity_id
	AND
	Decode(Decode(Nvl(p_repetitive_schedule_id,-1),
			-1, wip_constants.discrete,
			wip_constants.repetitive),
	       wip_constants.discrete,0,
	       wip_constants.repetitive,wop.repetitive_schedule_id)
	= Decode(Decode(Nvl(p_repetitive_schedule_id,-1),
			-1, wip_constants.discrete,
			wip_constants.repetitive),
		 wip_constants.discrete,0,
		 wip_constants.repetitive,p_repetitive_schedule_id);

      IF(p_repetitive_schedule_id IS NULL) THEN /* Discrete Job */

	 SELECT NVL(p_total_quantity,0) + Nvl(wdj.quantity_completed,0)
	   INTO p_total_quantity
	   FROM wip_discrete_jobs wdj
	   WHERE
	   wdj.organization_id = p_organization_id
	   AND wdj.wip_entity_id = p_wip_entity_id;

       ELSE

	 SELECT NVL(p_total_quantity,0) + Nvl(wrs.quantity_completed,0)
	   INTO p_total_quantity
	   FROM wip_repetitive_schedules wrs
	   WHERE
	   wrs.organization_id = p_organization_id
	   AND wrs.wip_entity_id = p_wip_entity_id
	   AND wrs.repetitive_schedule_id = p_repetitive_schedule_id;
      END IF;

   END;

/*=====================================================================+
 | PROCEDURE
 |   Get_Released_Revs_Type_Meaning
 |
 | PURPOSE
 |    This procedure would return the value and meaning of profile WIP profile
 |    'WIP:Exclude ECOs'.
 |
 | ARGUMENTS
 |
 | EXCEPTIONS
 |
 | NOTES
 |
 +=====================================================================*/


   PROCEDURE Get_Released_Revs_Type_Meaning
   (
    x_released_revs_type	OUT NOCOPY NUMBER,
    x_released_revs_meaning	OUT NOCOPY Varchar2
   ) IS
   BEGIN
          --  set up release type
          x_released_revs_type := fnd_profile.value('WIP_RELEASED_REVS');
          IF (x_released_revs_type is null) then
	     x_released_revs_type := 1;
	  END IF;
          IF (x_released_revs_type = 2) then
	    x_released_revs_meaning := 'EXCLUDE_HOLD';
          ELSIF (x_released_revs_type = 1) then
	    x_released_revs_meaning := 'EXCLUDE_OPEN_HOLD';
          ELSIF (x_released_revs_type = 0) then
	    x_released_revs_meaning := 'EXCLUDE_ALL';
          END IF;

  END  Get_Released_Revs_Type_Meaning;

END WIP_COMMON;

/
