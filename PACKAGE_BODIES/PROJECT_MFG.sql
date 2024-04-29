--------------------------------------------------------
--  DDL for Package Body PROJECT_MFG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PROJECT_MFG" AS
/* $Header: CSTPJCMB.pls 115.3 2002/11/11 18:59:38 awwang ship $ */

FUNCTION matl_subelement (
	   I_ITEM_ID                    IN      NUMBER,
           I_RATES_COST_TYPE_ID         IN      NUMBER,
           I_ORG_ID                     IN      NUMBER)
RETURN VARCHAR2
is

	   l_expend_type		VARCHAR2(30);

 BEGIN

	BEGIN

		select
		br.expenditure_type
 		into l_expend_type
		from
		BOM_RESOURCES br,
		CST_ITEM_COST_DETAILS cicd
		where
		cicd.inventory_item_id		=	I_ITEM_ID	and
		cicd.organization_id		=	I_ORG_ID	and
		cicd.cost_type_id		=  nvl(I_RATES_COST_TYPE_ID,-1)	and
		cicd.resource_id		=	br.resource_id	and
		cicd.cost_element_id		=	1		and
		br.organization_id		=	I_ORG_ID	and
		rownum 				=	1
		order by cicd.resource_id;

	EXCEPTION

	 WHEN NO_DATA_FOUND then l_expend_type := 'NO Val';

	END;


	BEGIN


	IF (l_expend_type = 'NO Val') then

	select nvl(br.expenditure_type,'No Val')
	into
	l_expend_type
	from
	BOM_RESOURCES br,
	MTL_PARAMETERS mp
	where
	mp.organization_id	=	I_ORG_ID	and
	mp.default_material_cost_id	=	br.resource_id	and
	br.organization_id		=	I_ORG_ID;

	END IF;

	EXCEPTION

	WHEN NO_DATA_FOUND then l_expend_type := 'NO Val';

	END;

	return(l_expend_type);



 EXCEPTION

 WHEN OTHERS THEN
 return('-999');



 END matl_subelement;

 END project_mfg;

/
