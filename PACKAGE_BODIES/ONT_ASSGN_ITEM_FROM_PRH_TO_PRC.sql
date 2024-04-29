--------------------------------------------------------
--  DDL for Package Body ONT_ASSGN_ITEM_FROM_PRH_TO_PRC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_ASSGN_ITEM_FROM_PRH_TO_PRC" AS
/* $Header: ontcai2b.pls 120.0 2005/06/01 02:19:32 appldev noship $  */
-- Global Variables
g_error  boolean:= false;
g_errbuf  varchar2(10000);
g_warn boolean:= false;

--
-- Purpose: This assigns an item to an item category based on the value stored in attribute2
-- of the item decriptive flexfield
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
-- MAGUPTA     10/12/01 Changed it for Order Summary


   -- Main procedure for error handling
   -- Standard concurrent manager parameters

procedure      ONT_ASSIGN_MAIN
( Errbuf out nocopy Varchar2,

retcode out nocopy Varchar2)

is

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
begin

    -- FND_FILE.PUT_NAMES('eniasscat.log', 'eniasscat.out',fnd_profile.value('EDW_LOGFILE_DIR'));
    ONT_ASSIGN_CATEGORY;
    if g_warn = true then
        Errbuf:=g_errbuf;
        retcode:=1;
    end if;

    if g_error = true then
        Errbuf:=g_errbuf;
        retcode:=2;
    end if;
end ONT_ASSIGN_MAIN;

/* Wrapper for printing report line */
PROCEDURE PRINT_LINE
	(line_text	IN	VARCHAR2) IS
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN
	 FND_FILE.PUT_LINE ( FND_FILE.OUTPUT,line_text);


END;

   -- Procedure which actually looks at attribute2 of the item
   -- and assigns it to the item category

procedure      ONT_ASSIGN_CATEGORY
is
    l_return_status    VARCHAR2(10000);
    l_errorcode        NUMBER;
    l_msg_count        NUMBER;
    l_msg_data         VARCHAR2(10000);
    l_category_id      NUMBER;
    l_category_set_id  NUMBER;
    l_inventory_item_id  NUMBER;
    l_item_name       varchar2(10000);
    l_structure_id      NUMBER;
    l_data varchar2(10000);
    l_msg_index_out varchar2(10000);
    l_organization_id  NUMBER;
    l_organization_code varchar2(5);
    l_attribute2 varchar2(100);
    l_dummy_for_x varchar2(100);

    prh_structure_id     NUMBER;
    prh_category_set_id  NUMBER;

    prc_structure_id     NUMBER := 0;
    prc_category_set_id  NUMBER := 1000000006; -- change it to 6 for production.

    p_mode  NUMBER := 2;
    l_segment8  varchar2(50) ;

    cat_not_found exception;
    catset_not_found exception;


	cursor missing_item_associations is
 		select ic.inventory_item_id,
                        ic.organization_id,
                        prh.segment8,
                        prh.category_id,
                        prh.description
                from 	mtl_item_categories ic,
			mtl_categories_b prc,
			mtl_categories_b prh
                where prc.category_id = ic.category_id
                  and prc.structure_id = prc_structure_id
                  and ic.category_set_id = prc_category_set_id
                  and prh.enabled_flag = 'Y'
		  and prh.segment8 = prc.segment1
                  and prh.structure_id = prh_structure_id
                  and not EXISTS
                        (select  'x'
                          from  mtl_item_categories ic2, mtl_categories_b c2
                          where c2.category_id = ic2.category_id
                            and c2.structure_id = prh_structure_id
                            and ic2.category_set_id = prh_category_set_id
			    and ic2.inventory_item_id = ic.inventory_item_id
			    and ic2.organization_id = ic.organization_id
			    and c2.segment8 = prc.segment1
                        );

      -----------------------------------------------------
      -- Only those items which are existing in this cursor
      ------------------------------------------------------
         CURSOR c_get_valid_item(p_org_id number, p_inventory_item_id number) IS
           select  'x'
           from mtl_item_categories ic,
           	mtl_system_items_b msi,
           	mtl_categories_b c
           where msi.organization_id = p_org_id
           and  msi.inventory_item_id = p_inventory_item_id
           and	msi.inventory_item_id = ic.inventory_item_id
           and	msi.organization_id = ic.organization_id
           and ic.category_id = c.category_id
           and c.structure_id = 101
           and c.segment1 in ('SW LIC', 'SW FIN')
           and msi.enabled_flag = 'Y'
           and msi.attribute10||''='IBOM';
           --
           l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
           --
  begin

    -- Get the structure id associate with category set 'Product Reporting Heirarchy'
    begin
        select structure_id, category_set_id
	  into prh_structure_id, prh_category_set_id
          from mtl_category_sets
         where category_set_name ='Product Reporting Hierarchy' ;
    exception
         -- When category set not found
        when no_data_found then
             raise catset_not_found;
    end;

    -- Get the structure id associate with category set 'Product Classification'
    begin
        select structure_id
	  into prc_structure_id
          from mtl_category_sets
         where category_set_id = prc_category_set_id;
    exception
         -- When category set not found
        when no_data_found then
            -- Try to find the category by the name
             begin
                 select structure_id,category_set_id
                 into prc_structure_id,prc_category_set_id
                 from mtl_category_sets
                 where category_set_name = 'Product Classification';
              exception  -- Now raise the exception that category set not found
                  when no_data_found then
                    raise catset_not_found;
             end;
    end;

 /**
   * Remove all the associations for disabled categories from
   * mtl_item_categories.
  **/

     delete from mtl_item_categories
     where category_id in
       (
	select	c.category_id
	from	mtl_categories_b c
	where	c.structure_id = prh_structure_id
	and	c.enabled_flag = 'N'
       );

        -- For each item in the master org, find the category
	-- and assign the item to the category

        for c1rec in missing_item_associations  loop

            l_inventory_item_id:= c1rec.inventory_item_id;
            l_organization_id := c1rec.organization_id;
            l_category_id := c1rec.category_id;

          if (c_get_valid_item%ISOPEN) then
            close c_get_valid_item;
          end if;
            open c_get_valid_item(l_organization_id,l_inventory_item_id);
            fetch c_get_valid_item into l_dummy_for_x;
            close c_get_valid_item;
            if nvl(l_dummy_for_x,'y')='x' then   -- Insert only when this item satisfies the cursor.
             l_dummy_for_x := null;

             if p_mode = 2 THEN
              -- Call the public API to assign item to categories
             fnd_msg_pub.initialize;
             INV_ITEM_CATEGORY_PUB.Create_Category_Assignment
               (
                p_api_version       => 1,
                p_init_msg_list     => FND_API.G_FALSE,
                p_commit            => FND_API.G_TRUE,
                x_return_status     => l_return_status,
                x_errorcode         => l_errorcode,
                x_msg_count         => l_msg_count,
                x_msg_data          => l_msg_data,
                p_category_id       => l_category_id,
                p_category_set_id   => prh_category_set_id,
                p_inventory_item_id => l_inventory_item_id,
                p_organization_id   => l_organization_id
               )   ;
	    end if;

	   print_line(c1rec.segment8 || ' ' || c1rec.description
			|| ' ' || l_category_id || ' ' ||l_inventory_item_id );

            if l_msg_count > 0 then
                FND_MSG_PUB.Get(p_msg_index=>fnd_msg_pub.G_LAST,
				p_encoded=>FND_API.G_FALSE,
				p_msg_index_out=>l_msg_index_out,
				p_data=>l_data);
                print_line( 'Item '||l_item_name||' in organization '||l_organization_code|| ' was not assigned. '||l_data);
                g_warn:=true;

            end if;

           end if;  -- Dummy_for_x
         end loop c1rec;

        exception

        -- When category set not found
        when catset_not_found then
             FND_FILE.PUT_LINE(FND_FILE.LOG,'Product Reporting Hierarchy Set not found');
             g_error:=true;
        when others then
	    --rollback; -- this undo any deletions of item category associations
            g_errbuf:= 'Error in Category Assignment'||sqlerrm;
            g_error:=true;
            raise;
end;


END;

/
