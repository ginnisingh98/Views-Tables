--------------------------------------------------------
--  DDL for Package Body AP_PO_LOCN_ASSOCIATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_PO_LOCN_ASSOCIATION_PKG" AS
/* $Header: appolocb.pls 120.2 2004/10/28 23:28:01 pjena noship $ */
--
--
-- PROCEDURE
--      insert_row
--
-- DESCRIPTION
--	This procedure inserts rows into the table po_location_associations
--
PROCEDURE insert_row ( 	p_location_id 		IN NUMBER,
			p_vendor_id   		IN NUMBER,
			p_vendor_site_id 	IN NUMBER,
			p_last_update_date 	IN DATE,
			p_last_updated_by  	IN NUMBER,
			p_last_update_login 	IN NUMBER,
			p_creation_date 	IN DATE,
			p_created_by 		IN NUMBER,
			p_org_id		IN NUMBER) IS		/* MO Access Control */

l_po_location_exist  VARCHAR2(2);

BEGIN

 l_po_location_exist := 'N';

 --Check if the location_id already exists in po_location_associations table.

 BEGIN
	select  'Y'
	  into 	l_po_location_exist
	  from 	po_location_associations pla
	 where	pla.location_id = nvl(p_location_id,0);
 EXCEPTION
  	when no_data_found then
	    l_po_location_exist := 'N';
 END;

 --If the parameter p_location_id is not null and it exists in
 --po_location_associations table then update the table with the vendor_id,
 --vendor_site_id, last_update_date, last_updated_by, last_update_login
 --details. Else we insert the record with all the details above alongwith
 --creation_date, created_by.

 if (p_location_id is not null) then
  if (l_po_location_exist = 'Y') then

   UPDATE po_location_associations
      SET vendor_id = p_vendor_id,
	  vendor_site_id = p_vendor_site_id,
	  last_update_date = p_last_update_date,
          last_updated_by = p_last_updated_by,
	  last_update_login = p_last_update_login,
	  org_id	    = p_org_id		--MO Access Control
    WHERE location_id = p_location_id;

  else

   INSERT into po_location_associations(location_id,
					vendor_id,
					vendor_site_id,
					last_update_date,
					last_updated_by,
					last_update_login,
					creation_date,
					created_by,
					org_id)		--MO Access Control
   VALUES (p_location_id, p_vendor_id, p_vendor_site_id, p_last_update_date,
           p_last_updated_by, p_last_update_login, p_creation_date, p_created_by,
	   p_org_id);		--MO Access Control

  end if;
 end if;

END;
--
--
PROCEDURE update_row ( 	p_location_id 		IN NUMBER,
			p_vendor_id   		IN NUMBER,
			p_vendor_site_id 	IN NUMBER,
			p_last_update_date 	IN DATE,
			p_last_updated_by  	IN NUMBER,
			p_last_update_login 	IN NUMBER,
			p_creation_date 	IN DATE,
			p_created_by 		IN NUMBER,
			p_org_id		IN NUMBER)  IS		--MO Access Control

l_po_location_exist  	VARCHAR2(2);
l_site_associated      	VARCHAR2(2);
l_location_id 	        NUMBER := 0;

BEGIN
	l_po_location_exist := 'N';
	l_site_associated := 'N';

      BEGIN
	select  'Y', nvl(location_id,0)
	  into 	l_site_associated, l_location_id
	  from 	po_location_associations pla
	 where	pla.vendor_site_id = p_vendor_site_id;

       EXCEPTION
	when no_data_found then
	     l_site_associated := 'N';
	     l_location_id := NULL;
      END;

 --if location_id has not been modified, then do nothing.

 if((l_location_id = p_location_id) or
    (l_location_id is null and p_location_id is null)) then
     return;
 end if;

 -- if there is a vendor site, then null out the vendor_id and vendor_site_id

 if (l_site_associated = 'Y') then
	UPDATE 	po_location_associations
           SET 	vendor_id = NULL,
		vendor_site_id = NULL,
      		last_update_date = p_last_update_date,
      		last_updated_by = p_last_updated_by,
	        last_update_login = p_last_update_login,
		org_id		  = p_org_id		--MO Access Control
         WHERE  vendor_site_id = p_vendor_site_id;
 end if;

 if (p_location_id is not null) then
   BEGIN
	select  'Y'
	  into 	l_po_location_exist
	  from 	po_location_associations pla
	 where	pla.location_id = p_location_id;

    EXCEPTION
	when no_data_found then
	     l_po_location_exist := 'N';
   END;

   -- if po_location exists in the po_location_associations table, then update vendor_id,
   -- vendor_site_id and other details with the new values passed by the table handler.
   -- Else insert a row with the new values.

   if (l_po_location_exist = 'Y') then
   	UPDATE 	po_location_associations
           SET 	vendor_id = p_vendor_id,
		vendor_site_id = p_vendor_site_id,
		last_update_date = p_last_update_date,
		last_updated_by = p_last_updated_by,
	       	last_update_login = p_last_update_login,
		org_id		  = p_org_id	--MO Access Control
         WHERE  location_id = p_location_id;
   else
   	INSERT into po_location_associations (	location_id,
						vendor_id,
						vendor_site_id,
						last_update_date,
						last_updated_by,
						last_update_login,
						creation_date,
						created_by ,
						org_id)		--MO Access Control
      	VALUES (p_location_id, p_vendor_id, p_vendor_site_id, p_last_update_date,
		p_last_updated_by, p_last_update_login, p_creation_date, p_created_by,
		p_org_id);       --MO Access Control
    end if;
 end if;

END;
--
END ap_po_locn_association_pkg;

/
