--------------------------------------------------------
--  DDL for Package Body ICX_SUPP_CUSTOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_SUPP_CUSTOM" as
/* $Header: ICXSUPCB.pls 115.2 2001/10/15 13:51:12 pkm ship     $ */


-- This function determines if a supplier record already exists.
-- Positive number indicates single match and SUPPLIER_ID returned.
-- 0 indicates no match
-- Negative number indicates multiple matches

function validateSupplier(p_supplier in varchar2,
                        p_addr1 in varchar2,
                        p_addr2 in varchar2,
                        p_addr3 in varchar2,
                        p_city in varchar2,
                        p_province in varchar2,
                        p_county in varchar2,
                        p_state in varchar2,
                        p_zip in varchar2,
                        p_country in varchar2)
			return number is

l_existing_supplier	number;
l_vendor_id		number;

cursor existing_supplier is
        select  count(*)
        from    PO_VENDORS
        where   upper(vendor_name) = upper(p_supplier);

begin

    open  existing_supplier;
    fetch existing_supplier into l_existing_supplier;
    close existing_supplier;

    if l_existing_supplier = 1
    then
	select	vendor_id
	into	l_vendor_id
	from	PO_VENDORS
	where	upper(vendor_name) = upper(p_supplier);
    elsif l_existing_supplier = 0 or l_existing_supplier is null
    then
	l_vendor_id := 0;
    else
	l_vendor_id := l_existing_supplier * -1;
    end if;

    return l_vendor_id;
end;

--
-- NAME
--   Set_Domain
--
-- PURPOSE
--    procedure to determine the domain for web user account name
--    based on customer information for business partner customer registration.
--
-- PARAMETERS
--    p_username - Requestor's preferred web account user name
--                 e.g. jdoe
--    p_supplier_id - Primary to PO_VENDORS, only valid if greater than 0
--    p_email_address - Email address supplier by requestor
--    p_new_username - web account user name including set domain name
--                     e.g. jdoe@oracle  (@oracle is the doamin name)
-- NOTES
procedure setDomain(p_username		in varchar2,
		    p_supplier_id	in number,
		    p_email_address	in varchar2,
                    p_new_username	out varchar2) is

l_domain_name varchar2(100);

-- Note, Username cannot exceed 100 characters total.

begin

   -- initialize to NULL
   -- expecting to be customized based on
   -- company data; p_supplier_id, only if > 0
   -- email address; p_email_address
   -- e.g. domain name can be '@oracle' etc..
   l_domain_name := NULL;
   --
   p_new_username := p_username || l_domain_name;
end;


-- This function determines if a supplier contact record already exists.
-- Positive number indicates single match and VENDOR_CONTACT_ID returned.
-- 0 indicates no match
-- Negative number indicates multiple matches

function validateContact(p_supplier_id in number,
                        p_first_name in varchar2,
                        p_last_name  in varchar2,
                        p_phone_number in varchar2,
                        p_mail_stop in varchar2,
                        p_addr1 in varchar2,
                        p_addr2 in varchar2,
                        p_addr3 in varchar2,
                        p_city in varchar2,
                        p_province in varchar2,
                        p_county in varchar2,
                        p_state in varchar2,
                        p_zip in varchar2,
                        p_country in varchar2)
                        return number is

l_existing_contact      number;
l_contact_id            number;

cursor existing_contact is
        select  count(*)
        from    PO_VENDOR_CONTACTS
        where   upper(last_name) = upper(p_last_name)
        and     upper(first_name) = upper(p_first_name);

cursor existing_contact_by_vendor is
        select  count(*)
        from    PO_VENDOR_CONTACTS b,
		PO_VENDOR_SITES_all a
        where   a.VENDOR_ID = p_supplier_id
	and	a.VENDOR_SITE_ID  = b.VENDOR_SITE_ID
        and     b.INACTIVE_DATE is null
	and	upper(b.last_name)  = upper(p_last_name)
	and	upper(b.first_name) = upper(p_first_name);

begin

if p_supplier_id <= 0
then
    open  existing_contact;
    fetch existing_contact into l_existing_contact;
    close existing_contact;

    if l_existing_contact = 1
    then
        select  vendor_contact_id
        into    l_contact_id
        from    PO_VENDOR_CONTACTS
        where   upper(last_name) = upper(p_last_name)
        and     upper(first_name) = upper(p_first_name);

        return l_contact_id;
    else
        l_existing_contact := l_existing_contact * -1;

        return l_existing_contact;
    end if;
else
    open  existing_contact_by_vendor;
    fetch existing_contact_by_vendor into l_existing_contact;
    close existing_contact_by_vendor;

    if l_existing_contact = 1
    then
        select  vendor_contact_id
        into    l_contact_id
        from    PO_VENDOR_CONTACTS b,
		PO_VENDOR_SITES_all a
        where   a.VENDOR_ID = p_supplier_id
	and	a.VENDOR_SITE_ID  = b.VENDOR_SITE_ID
        and     b.INACTIVE_DATE is null
        and     upper(b.last_name)  = upper(p_last_name)
        and     upper(b.first_name) = upper(p_first_name);

        return l_contact_id;
    else
        l_existing_contact := l_existing_contact * -1;

        return l_existing_contact;
    end if;
end if;

end;

-- procedure to determin the next approver to be routed for approving customer
-- registration.

procedure GetApprover (p_supplier_id     IN NUMBER,
                       p_contact_id      IN NUMBER,
                       p_user_id         IN NUMBER,
                       p_approver_id     IN OUT NUMBER,
                       p_approver_name   IN OUT VARCHAR2) is

begin

-- Check to see if User has self approved then set to next approver.

  if p_user_id = p_approver_id
  then
        -- Default to SYSADMIN
	p_approver_id := 0;
	p_approver_name := 'SYSADMIN';
  else
        -- Default to SYSADMIN
        p_approver_id := 0;
        p_approver_name := 'SYSADMIN';
  end if;

end;

-- procedure to determin the next approver to be routed for approving customer
-- registration.

procedure GetContactSelector (p_supplier_id     IN NUMBER,
			      p_approver_id     IN OUT NUMBER,
                              p_approver_name   IN OUT VARCHAR2) is

begin


     -- Default to SYSADMIN
     p_approver_id := 0;
     p_approver_name := 'SYSADMIN';

end;


procedure GetAcctAdmin(p_supplier_id in number,
		       p_admin_id out number,
                       p_admin_name out varchar2,
		       p_display_admin_name out varchar2) is
begin

  -- Default to SYSADMIN
  p_admin_id := 0;
  p_admin_name := 'SYSADMIN';
  p_display_admin_name := 'sysadmin';

end;

-- function to determine if the requestor/preparer can approve without selecting
-- an approver
function VerifySelfApproval(p_supplier_id in number)
                            return BOOLEAN is
begin

     return FALSE;

end;

-- function to determine if the current approver with the employee id(same as
-- forward to id in workflow) has the authorty to approve without further routing
-- of the registration request to another approver
function VerifyAuthority(p_supplier_id in number,
		         p_approver_id in number)
		         return BOOLEAN is

begin

   return TRUE;

end;

end icx_supp_custom;

/
