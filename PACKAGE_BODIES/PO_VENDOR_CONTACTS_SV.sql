--------------------------------------------------------
--  DDL for Package Body PO_VENDOR_CONTACTS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_VENDOR_CONTACTS_SV" AS
/* $Header: POXVDVCB.pls 120.0.12010000.3 2013/01/21 04:49:29 xueche ship $*/

/*===========================================================================

 FUNCTION NAME :  val_vendor_contact()

===========================================================================*/
FUNCTION  val_vendor_contact( p_vendor_contact_id IN NUMBER,
                              p_vendor_site_id IN NUMBER  --<Bug 3692519>
) return BOOLEAN IS

  X_progress 		varchar2(3) := NULL;
  X_vendor_contact_id_v number 	    := NULL;

BEGIN

  X_progress := '010';

  /* Check if the given Vendor Contact is active */

  SELECT  vendor_contact_id
  INTO    X_vendor_contact_id_v
  FROM    po_vendor_contacts
  WHERE   sysdate < nvl(inactive_date, sysdate + 1)
  AND     vendor_contact_id = p_vendor_contact_id
  AND     vendor_site_id = p_vendor_site_id; --<Bug 3692519>

  return (TRUE);

EXCEPTION

  when no_data_found then
    return (FALSE);
  when others then
    po_message_s.sql_error('val_vendor_contact',X_progress,sqlcode);
    raise;

END val_vendor_contact;

/*===========================================================================

  PROCEDURE NAME:	get_vendor_contact()

===========================================================================*/

PROCEDURE get_vendor_contact(X_vendor_site_id IN NUMBER,
                             X_vendor_contact_id IN OUT NOCOPY number,
                             X_vendor_contact_name IN OUT NOCOPY varchar2 ) IS

 X_progress VARCHAR2(3) := NULL;
 X_vendor_contact_count number;

BEGIN
    X_Progress := '010';

   /* Return the count of Vendor Contacts
   ** who are still active for the  given site */


   SELECT count(pvc.vendor_contact_id),
          -- bug 590653: need to handle null first_name
          -- max((last_name||', '||first_name)),
          --bug 16059899, get contact name from hz_parties table.
          max((hp.person_last_name || decode(hp.PERSON_FIRST_NAME,null,null,', ') || hp.PERSON_FIRST_NAME)),
          max(vendor_contact_id)
   INTO   X_vendor_contact_count,
          X_vendor_contact_name,
          X_vendor_contact_id
   FROM   po_vendor_contacts pvc,
          hz_parties hp    --bug 16059899
   WHERE  pvc.vendor_site_id       = X_vendor_site_id
   AND    pvc.PER_PARTY_ID = hp.party_id --16059899
   AND    sysdate < nvl(inactive_date, sysdate + 1);
   /* If there is more than 1 ACTIVE vendor contact for the
   ** site, we cannot determine the default, so
   ** return NULL for the DEFAULT VENDOR CONTACT */

   if X_vendor_contact_count  <>  1 then
          X_vendor_contact_id := '';
          X_vendor_contact_name := '';
   end if;

   EXCEPTION
      when too_many_rows then
            X_vendor_contact_id := '';
            X_vendor_contact_name := '';
      when no_data_found then
            X_vendor_contact_id := '';
            X_vendor_contact_name := '';


     when others then
          po_message_s.sql_error('get_vendor_contact', X_progress, sqlcode);
          raise;

END get_vendor_contact;


/*===========================================================================

  PROCEDURE NAME:	get_contact_info

===========================================================================*/

PROCEDURE get_contact_info  (x_vendor_contact_id   IN     NUMBER,
			     x_vendor_site_id      IN     NUMBER,
                             x_vendor_contact_name IN OUT NOCOPY VARCHAR2,
			     x_vendor_phone        IN OUT NOCOPY VARCHAR2) IS

 X_progress VARCHAR2(3) := NULL;

BEGIN
    x_progress := '010';
--bug#3441462 modified the query  because the length of phone number fields in PO is
--25 characters. If the contact has a telephone number of 15 digits and area code of
--10 digits then with the space the total length goes up to 26 digits. To prevent
--this we check if the length is less than 25 if yes then we concatenate
--area code and phone number with a space. Or else we concatenate without a space.

    SELECT pvc.last_name || decode(pvc.last_name,null,null,
				   decode(pvc.first_name,null,null,', '))
			 || pvc.first_name,
	decode(trunc(length(pvc.area_code ||' '||pvc.phone)/26),0,
	pvc.area_code || decode(pvc.area_code,null,null,decode(pvc.phone,null,null,' '))||pvc.phone,
	pvc.area_code||pvc.phone )

    INTO  x_vendor_contact_name,
	  x_vendor_phone
    FROM  po_vendor_contacts pvc
    WHERE pvc.vendor_contact_id = x_vendor_contact_id
    AND   pvc.vendor_site_id = nvl(x_vendor_site_id,pvc.vendor_site_id);

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
            X_vendor_contact_name := '';
            X_vendor_phone        := '';

     --<Bug 3564169 mbhargav START>
     WHEN TOO_MANY_ROWS THEN
            X_vendor_contact_name := '';
            X_vendor_phone        := '';
     --<Bug 3564169 mbhargav END>

     WHEN OTHERS THEN
          po_message_s.sql_error('get_vendor_contact', X_progress, sqlcode);
          raise;

END get_contact_info;

--==============================================================================
-- FUNCTION    : get_vendor_contact_id                    -- <Bug 3692519>
-- TYPE        : Private
--
-- REQUIRES    : p_po_header_id must be a valid document ID.
-- MODIFIES    : -
--
-- DESCRIPTION : Gets the vendor_contact_id specified on a particular PO document.
--
-- PARAMETERS  : p_po_header_id - document ID
--
-- RETURNS     : vendor_contact_id specified for the p_po_header_id
--               NULL if no contact is specified for the p_po_header_id
--                    or if the p_po_header_id does not exist
--
-- EXCEPTIONS  : -
--==============================================================================
FUNCTION get_vendor_contact_id
(
    p_po_header_id        IN   NUMBER
)
RETURN NUMBER
IS
    x_vendor_contact_id      PO_HEADERS_ALL.vendor_contact_id%TYPE;
BEGIN

    SELECT    vendor_contact_id
    INTO      x_vendor_contact_id
    FROM      po_headers_all
    WHERE     po_header_id = p_po_header_id;

    return (x_vendor_contact_id);

EXCEPTION
    WHEN OTHERS THEN
        return (NULL);

END get_vendor_contact_id;

END PO_VENDOR_CONTACTS_SV;

/
