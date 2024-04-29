--------------------------------------------------------
--  DDL for Package Body POA_DBI_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_DBI_ITEMS_PKG" as
/* $Header: poadbiitemb.pls 120.4 2006/10/13 13:50:51 nchava noship $ */


function insertion  (p_item_id IN number,
		       p_org_id IN number,
		       p_category_id IN number,
		       p_vendor_product_num IN VARCHAR2,
		       p_vendor_id IN NUMBER,
                       p_description IN VARCHAR2) return number;


function  getItemKey(p_item_id IN number,
                     p_org_id IN number,
                     p_category_id IN number,
                     p_vendor_product_num IN varchar2,
		     p_vendor_id IN NUMBER,
                     p_description IN VARCHAR2,
                    p_auto_insert_flag boolean) return number
is
  l_item_key number;
  l_category_id number := p_category_id;
  l_vendor_id NUMBER := p_vendor_id;
  l_org_id NUMBER := null;
  l_description VARCHAR2(240) := p_description;
  l_vendor_prod po_lines_all.vendor_product_num%TYPE := p_vendor_product_num;
BEGIN
  begin
    if(p_item_id is not null) then
       l_category_id := null;
       l_vendor_id := NULL;
       l_vendor_prod := NULL;
       l_org_id := p_org_id;

       if (l_org_id is null) then
         bis_collection_utilities.log('Item ' || p_item_id || ' has problems with its defining org', 2);
         return -1;
      end if;

      SELECT /*+ FIRST_ROWS */ po_item_id
        into l_item_key
        from poa_items
       where item_id = p_item_id
         and organization_id = l_org_id
	 --and category_id = p_category_id
	  ;
    ELSIF (p_vendor_product_num is NULL or p_vendor_id IS null) THEN /* null vendor_id should only happen to req-based items */
       l_vendor_id := NULL;
       l_vendor_prod := NULL;
       IF (p_category_id IS NULL) THEN
	  raise_application_error (-20001, 'category_id is null for the record being collected.
				   itemdescription=' || p_description
				   ||' Sysdate=' ||To_char(Sysdate, 'DD/MM/YYYY HH24:MI:SS'), true );
       END IF;
       IF (p_description IS NULL) THEN
	  raise_application_error (-20002, 'item_description is null for the record being collected.
				   category=' || p_category_id
				   ||' Sysdate=' ||To_char(Sysdate, 'DD/MM/YYYY HH24:MI:SS'), true );
       END IF;

      select /*+ FIRST_ROWS */ po_item_id
        into l_item_key
        from poa_items
	where item_id is NULL
	  AND organization_id IS null
	    and category_id = p_category_id
            and description = p_description
	    and vendor_product_num is NULL
	      and vendor_id IS null ;
    else
       IF (p_description IS NULL) THEN
	  raise_application_error (-20002, 'item_description is null for the record being collected.
				   category=' || p_category_id
				   ||' Sysdate=' ||To_char(Sysdate, 'DD/MM/YYYY HH24:MI:SS'), true );
       END IF;
       select /*+ FIRST_ROWS */ po_item_id
	 into l_item_key
	 from poa_items
	 where item_id is NULL
	   AND organization_id IS null
	       and vendor_product_num = p_vendor_product_num
	       AND vendor_id = p_vendor_id;
    end if;
  exception
    when no_data_found then
      if(p_auto_insert_flag) THEN
        l_item_key := insertion (p_item_id,l_org_id,l_category_id,l_vendor_prod,l_vendor_id, l_description);
      else
        return 0; -- EDW unassigned
      end if;
    when others then
       raise;
  end getItemKey;
  return l_item_key;
end getItemKey;

function insertion  (p_item_id IN number,
                     p_org_id IN number,
                     p_category_id IN number,
                     p_vendor_product_num IN VARCHAR2,
		     p_vendor_id IN number,
                     p_description IN varchar2) return number
IS
pragma AUTONOMOUS_TRANSACTION;
l_item_key NUMBER ;
begin
	--lock table poa_items in exclusive mode;
   insert into poa_items (po_item_id, item_id, organization_id, category_id, vendor_product_num, vendor_id, description)
     values (poa_items_s.nextval,p_item_id,p_org_id,p_category_id,p_vendor_product_num, p_vendor_id, p_description)
     returning po_item_id INTO l_item_key;
   commit;
   return l_item_key;
EXCEPTION
   WHEN dup_val_on_index THEN
      RETURN getitemkey(p_item_id, p_org_id, p_category_id, p_vendor_product_num, p_vendor_id, p_description);
   WHEN OTHERS THEN
      RAISE;
end insertion;



PROCEDURE  refresh(Errbuf      in out NOCOPY Varchar2,
		   Retcode     in out NOCOPY VARCHAR2 ) IS
BEGIN
   POA_DBI_UTIL_PKG.refresh('poa_items_mv');
EXCEPTION
WHEN OTHERS THEN
   Errbuf:= Sqlerrm;
   Retcode:=sqlcode;

   ROLLBACK;
   POA_LOG.debug_line('poa_dbi_items_pkg.refresh' || Sqlerrm || sqlcode || sysdate);
   RAISE_APPLICATION_ERROR(-20000,'Stack Dump Follows =>', true);
END refresh;


end poa_dbi_items_pkg;

/
