--------------------------------------------------------
--  DDL for Package Body CSTPACLM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPACLM" as
/* $Header: CSTACLMB.pls 120.1 2005/08/29 17:35:47 sheyu noship $ */

function layer_id (
  i_org_id                  in number,
  i_item_id       	    in number,
  i_cost_group_id     	    in number,
  o_err_num                 out NOCOPY number,
  o_err_code		    out NOCOPY varchar2,
  o_err_msg                 out NOCOPY varchar2
)
return integer
is
  retval                    number;
begin

  o_err_num := 0;
  o_err_code := '';
  o_err_msg := '';

  select layer_id
  into retval
  from cst_quantity_layers
  where organization_id = i_org_id
  and inventory_item_id = i_item_id
  and cost_group_id     = i_cost_group_id;

  return retval;
EXCEPTION

  when NO_DATA_FOUND THEN
    return 0;
  when others then
    o_err_num := SQLCODE;
    o_err_msg := 'CSTPACLM.LAYER_ID:' || substrb(SQLERRM,1,150);
    return 0;

end layer_id;


function layer_det_exist (
  i_org_id                  in number,
  i_item_id       	    in number,
  i_cost_group_id     	    in number,
  o_err_num                 out NOCOPY number,
  o_err_code		    out NOCOPY varchar2,
  o_err_msg                 out NOCOPY varchar2
)
return integer
is
  retval                    number;
begin

  o_err_num := 0;
  o_err_code := '';
  o_err_msg := '';


  SELECT distinct LAYER_ID
  INTO   retval
  FROM   CST_LAYER_COST_DETAILS
  WHERE  LAYER_ID =
    (SELECT LAYER_ID
     FROM   CST_QUANTITY_LAYERS
     WHERE  ORGANIZATION_ID = i_org_id
     AND    INVENTORY_ITEM_ID = i_item_id
     AND    COST_GROUP_ID = i_cost_group_id);

  return retval;
EXCEPTION

  when NO_DATA_FOUND THEN
    return 0;
  when others then
    o_err_num := SQLCODE;
    o_err_msg := 'CSTPACLM.LAYER_DET_EXIST:' || substrb(SQLERRM,1,150);
    return 0;

end layer_det_exist;


function create_layer (
  i_org_id                  in number,
  i_item_id       	    in number,
  i_cost_group_id      	    in number,
  i_user_id                 in number,
  i_request_id              in number,
  i_prog_id                 in number,
  i_prog_appl_id            in number,
  i_txn_id                  in number,
  o_err_num                 out NOCOPY number,
  o_err_code                out NOCOPY varchar2,
  o_err_msg                 out NOCOPY varchar2
)
return integer
is
  l_layer_id                number;
begin

  o_err_num := 0;
  o_err_code := '';
  o_err_msg := '';

  /*
  ** check for existing layer
  */
  l_layer_id := cstpaclm.layer_id(i_org_id,
				  i_item_id,
				  i_cost_group_id,
				  o_err_num,
				  o_err_code,
				  o_err_msg);

  if (l_layer_id = 0) then

    /*
    ** if the layer_id is 0, then the layer doesn't exist, so we
    ** should create it
    */
    select cst_quantity_layers_s.nextval
    into l_layer_id
    from dual;

    BEGIN
    insert into cst_quantity_layers (
      layer_id,
      organization_id,
      inventory_item_id,
      cost_group_id,
      layer_quantity,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      request_id,
      program_id,
      program_application_id,
      PL_MATERIAL,
      PL_MATERIAL_OVERHEAD,
      PL_RESOURCE,
      PL_OUTSIDE_PROCESSING,
      PL_OVERHEAD,
      TL_MATERIAL,
      TL_MATERIAL_OVERHEAD,
      TL_RESOURCE,
      TL_OUTSIDE_PROCESSING,
      TL_OVERHEAD,
      MATERIAL_COST,
      MATERIAL_OVERHEAD_COST ,
      RESOURCE_COST,
      OUTSIDE_PROCESSING_COST,
      OVERHEAD_COST,
      PL_ITEM_COST,
      TL_ITEM_COST,
      ITEM_COST,
      UNBURDENED_COST,
      BURDEN_COST,
      CREATE_TRANSACTION_ID
      )
    values (
      l_layer_id,
      i_org_id,
      i_item_id,
      i_cost_group_id,
      0,
      SYSDATE,
      i_user_id,
      SYSDATE,
      i_user_id,
      i_request_id,
      i_prog_id,
      i_prog_appl_id,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      i_txn_id
    );
	EXCEPTION
		WHEN DUP_VAL_ON_INDEX THEN
		/* Bug 4408497: A layer already exists for this org/item/cg, so return that layer */
			l_layer_id := cstpaclm.layer_id(i_org_id,
				  							i_item_id,
				  							i_cost_group_id,
				  							o_err_num,
				  							o_err_code,
				  							o_err_msg);
			return l_layer_id;
		WHEN OTHERS THEN
    		o_err_num := SQLCODE;
    		o_err_msg := 'CSTPACLM.CREATE_LAYER:' || substrb(SQLERRM,1,150);
    		return 0;
	END;
  end if;

  return l_layer_id;

EXCEPTION

  when others then
    o_err_num := SQLCODE;
    o_err_msg := 'CSTPACLM.CREATE_LAYER:' || substrb(SQLERRM,1,150);
    return 0;

end create_layer;

end cstpaclm;

/
