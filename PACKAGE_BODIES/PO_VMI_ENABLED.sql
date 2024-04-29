--------------------------------------------------------
--  DDL for Package Body PO_VMI_ENABLED
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_VMI_ENABLED" AS
/* $Header: POXPVIEB.pls 115.4 2004/05/27 23:54:07 jmcfadde ship $ */

-- Global constant holding package name
g_pkg_name constant varchar2(50) := 'PO_VMI_ENABLED';

/*
** -------------------------------------------------------------------------
** Function:    check_vmi_enabled
** Description: This function is called from Inventory OrganizationParameters
** form(INVSDOIO.fmb). When a value of true  is returned by the API, the form
** disallows enabling of wms for that organization.
** Output:
**      x_return_status
**              return status indicating success, error, unexpected error
**      x_msg_count
**              number of messages in message list
**      x_msg_data
**              if the number of messages in message list is 1, contains
**              message text
** Input:
**      p_organization_id
**             -specific inventory organization to be checked if VMI enabled.
**
** Returns:
**	TRUE if VMI installed, else FALSE
**
**      Please use return value to determine if VMI is installed or not.
**      Do not use x_return_status for this purpose as
**      . x_return_status could be success and yet VMI not be installed.
**      . x_return_status is set to error when an error(such as SQL error)
**        occurs.
** --------------------------------------------------------------------------
*/

  function check_vmi_enabled(
			     x_return_status               OUT NOCOPY VARCHAR2
			     ,x_msg_count                   OUT NOCOPY NUMBER
			     ,x_msg_data                    OUT NOCOPY VARCHAR2
			     ,p_organization_id             IN  NUMBER    )
  RETURN BOOLEAN IS

     --constant
     c_api_name              constant varchar(30) := 'CHECK_VMI_ENABLED';
     v_temp                  varchar2(1) :=NULL;
     l_sob_id                org_organization_definitions.set_of_books_id%TYPE; --bug 3648672


  BEGIN
     x_return_status := fnd_api.g_ret_sts_success ;


  BEGIN
     SELECT 'Y' into v_temp from dual
       WHERE exists
       (SELECT 1 from
	po_asl_attributes paa,
	po_approved_supplier_list pasl,
	po_asl_status_rules pasr --bug 3648705 join to table not view
	WHERE
	paa.using_organization_id = p_organization_id
	AND pasl.asl_id = paa.asl_id
	AND (pasl.disable_flag = 'N' OR pasl.disable_flag IS NULL)
	and pasr.status_id = pasl.asl_status_id
	AND pasr.business_rule like '2_SOURCING'
	AND pasr.allow_action_flag like 'Y'
	AND paa.enable_vmi_flag =  'Y');
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
	v_temp := NULL;
  END;

  if(v_temp ='Y') then
     return TRUE;
   ELSE

     BEGIN

     -- move this query out of below query for performance
     -- bug 3648672
     SELECT set_of_books_id
     INTO  l_sob_id
     FROM  org_organization_definitions OOD
     WHERE  OOD.organization_id = p_organization_id;

	select 'Y'  INTO v_temp from dual where exists
	  (
	   select paa.asl_id
	   from
	   po_vendors pv,
	   po_vendor_sites_all pvsa,
	   po_asl_attributes paa,
	   po_approved_supplier_list  pasl,
	   po_asl_status_rules pasr --bug 3648672, join to base table instead of view
	   where
	   --Getting all organizations associated with the particular set_of_books_id
	   pv.set_of_books_id = l_sob_id -- bug 3648672

	   --Getting the vendor_id,vendor_site_id
	   AND pvsa.vendor_id = pv.vendor_id


	   --Getting to the po_approved_supplier_list using vendor_id and vendor_site_id
	   AND pvsa.vendor_id = pasl.vendor_id
	   AND pvsa.vendor_site_id = pasl.vendor_site_id
	   AND (pasl.disable_flag = 'N' OR pasl.disable_flag IS NULL)
	   and paa.asl_id = pasl.asl_id

	   --getting the global_asl_id from paa and verifying its validity
	   and paa.using_organization_id = -1
	   and pasr.status_id = pasl.asl_status_id
	   AND pasr.business_rule like '2_SOURCING'
	   AND pasr.allow_action_flag like 'Y'
	   AND paa.enable_vmi_flag =  'Y'

	     );
        EXCEPTION
	 WHEN NO_DATA_FOUND THEN
	    v_temp := NULL;
     END;
  end if;

  if(v_temp ='Y') then
      return TRUE;
   ELSE
     RETURN FALSE;
  END IF;

  EXCEPTION
     when others then
	x_return_status := fnd_api.g_ret_sts_unexp_error;

	if (fnd_msg_pub.check_msg_level
	    (fnd_msg_pub.g_msg_lvl_unexp_error)) then
	   fnd_msg_pub.add_exc_msg(g_pkg_name, c_api_name);
	end if;
	RETURN TRUE;
  end check_vmi_enabled;
end PO_VMI_ENABLED;

/
