--------------------------------------------------------
--  DDL for Package Body INVATTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVATTR" as
/* $Header: INVATTRB.pls 120.1 2005/07/01 12:11:45 appldev ship $ */

PROCEDURE correct_attr(master_org_id		number,
                       item_id         NUMBER
                       ) is
	CURSOR cc is
	select
         ORGANIZATION_ID,
	 INVENTORY_ITEM_FLAG,
	 STOCK_ENABLED_FLAG,
	 PURCHASING_ITEM_FLAG,
         INVOICEABLE_ITEM_FLAG,
         BOM_ITEM_TYPE,
	 CUSTOMER_ORDER_FLAG,
	 INTERNAL_ORDER_FLAG
       from mtl_system_items
       where inventory_item_id = item_id
        and organization_id  in ( select organization_id
            from mtl_parameters where master_organization_id =master_org_id
            and organization_id <> master_org_id);

	-- Attributes that are Item level (can't be different from master org's value)

        CURSOR ee is
        select attribute_name,
	       control_level
        from MTL_ITEM_ATTRIBUTES
        where control_level = 1
        order by attribute_name desc ;

	A_STOCK_ENABLED			number := 2;
	A_MTL_TRANSACTIONS_ENABLED	number := 2;
	A_PURCHASING_ENABLED		number := 2;
        A_INVOICE_ENABLED          	number := 2;
	A_BUILD_IN_WIP			number := 2;
	A_CUSTOMER_ORDER_ENABLED	number := 2;
	A_BOM_ENABLED			number := 2;
	A_INTERNAL_ORDER_ENABLED	number := 2;

	B_STOCK_ENABLED			varchar2(1);
	B_MTL_TRANSACTIONS_ENABLED	varchar2(1);
	B_PURCHASING_ENABLED		varchar2(1);
        B_INVOICE_ENABLED          	varchar2(1);
	B_BUILD_IN_WIP			varchar2(1);
	B_CUSTOMER_ORDER_ENABLED	varchar2(1);
	B_BOM_ENABLED			varchar2(1);
	B_INTERNAL_ORDER_ENABLED	varchar2(1);
begin

	for att in ee loop

		if substr(att.attribute_name,18) = 'STOCK_ENABLED_FLAG' then
			A_STOCK_ENABLED := att.control_level;
		end if;
	if substr(att.attribute_name,18) = 'MTL_TRANSACTIONS_ENABLED_FLAG' then
			A_MTL_TRANSACTIONS_ENABLED := att.control_level;
		end if;
	if substr(att.attribute_name,18) = 'PURCHASING_ENABLED_FLAG' then
			A_PURCHASING_ENABLED := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'INVOICE_ENABLED_FLAG' then
			A_INVOICE_ENABLED := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'CUSTOMER_ORDER_ENABLED_FLAG' then
			A_CUSTOMER_ORDER_ENABLED := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'INTERNAL_ORDER_ENABLED_FLAG' then
			A_INTERNAL_ORDER_ENABLED := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'BOM_ENABLED_FLAG' then
			A_BOM_ENABLED := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'BUILD_IN_WIP_FLAG' then
			A_BUILD_IN_WIP := att.control_level;
		end if;

	end loop;

-- validate the records

	for cr in cc loop

            if (cr.inventory_item_flag ='N' and A_STOCK_ENABLED=1) then
  	          B_STOCK_ENABLED := 'N' ;
            else
		  B_STOCK_ENABLED := 'Z' ;
            end if ;

           if ((cr.stock_enabled_flag ='N' or cr.inventory_item_flag ='N')
                      and A_MTL_TRANSACTIONS_ENABLED=1) then
  	          B_MTL_TRANSACTIONS_ENABLED := 'N' ;
            else
		  B_MTL_TRANSACTIONS_ENABLED := 'Z' ;
            end if ;


            if (cr.customer_order_flag ='N' and A_CUSTOMER_ORDER_ENABLED=1) then
  	          B_CUSTOMER_ORDER_ENABLED := 'N' ;
            else
		  B_CUSTOMER_ORDER_ENABLED := 'Z' ;
            end if ;

            if (cr.inventory_item_flag ='N' and A_BOM_ENABLED=1) then
  	          B_BOM_ENABLED := 'N' ;
            else
		  B_BOM_ENABLED := 'Z' ;
            end if ;

            if (cr.internal_order_flag ='N' and A_INTERNAL_ORDER_ENABLED=1) then
  	          B_INTERNAL_ORDER_ENABLED := 'N' ;
            else
		  B_INTERNAL_ORDER_ENABLED := 'Z' ;
            end if ;


            if (cr.invoiceable_item_flag ='N' and A_INVOICE_ENABLED=1) then
  	          B_INVOICE_ENABLED := 'N' ;
            else
		  B_INVOICE_ENABLED := 'Z' ;
            end if ;


            if (cr.purchasing_item_flag ='N' and A_PURCHASING_ENABLED=1) then
  	          B_PURCHASING_ENABLED := 'N' ;
            else
		  B_PURCHASING_ENABLED := 'Z' ;
            end if ;


            if ((cr.inventory_item_flag ='N' or cr.bom_item_type <> 4 ) and A_BUILD_IN_WIP=1) then
  	          B_BUILD_IN_WIP := 'N' ;
            else
		  B_BUILD_IN_WIP := 'Z' ;
            end if ;

            update mtl_system_items
		set
		 stock_enabled_flag = decode(B_STOCK_ENABLED,'N','N',stock_enabled_flag),
		 mtl_transactions_enabled_flag = decode(B_MTL_TRANSACTIONS_ENABLED,'N','N',mtl_transactions_enabled_flag),
		 purchasing_enabled_flag = decode(B_PURCHASING_ENABLED,'N','N',purchasing_enabled_flag),
		 invoice_enabled_flag = decode(B_INVOICE_ENABLED,'N','N',invoice_enabled_flag),
		 customer_order_enabled_flag = decode(B_CUSTOMER_ORDER_ENABLED,'N','N',customer_order_enabled_flag),
		 internal_order_enabled_flag = decode(B_INTERNAL_ORDER_ENABLED,'N','N',internal_order_enabled_flag),
	        bom_enabled_flag = decode(B_BOM_ENABLED,'N','N',bom_enabled_flag),
                build_in_wip_flag = decode(B_BUILD_IN_WIP,'N','N',build_in_wip_flag)
		where inventory_item_id = item_id
		  and organization_id = cr.organization_id;

	end loop;
exception
  when others then
    rollback;
end correct_attr;


end INVATTR;

/
