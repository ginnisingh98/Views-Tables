--------------------------------------------------------
--  DDL for Package Body WIP_STD_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_STD_WF" AS
/*$Header: wipwstdb.pls 115.6 2002/12/12 16:04:25 rmahidha ship $ */


--  Function: Get_EmployeeLogin
--  Desc: Given an employee_id, returns back the user login
--
FUNCTION GetEmployeeLogin ( p_employee_id NUMBER ) return VARCHAR2 is

   l_employee_login VARCHAR2(100) := NULL;
   l_employee_name  VARCHAR2(80);
/*
   cursor getemployeelogin ( c_employee_id number ) is
      select user_name
      from   fnd_user fu
      where  fu.employee_id = p_employee_id
      and    sysdate BETWEEN fu.start_date
 		         and nvl(fu.end_date, sysdate)
*/
BEGIN

   wf_directory.GetUserName(p_orig_system    => 'PER',
                            p_orig_system_id => p_employee_id,
                            p_name           => l_employee_login,
                            p_display_name   => l_employee_name);

   return l_employee_login;

/*
   open getemployeelogin ( p_employee_id );
   fetch getemployeelogin into l_employee_login;

   if (getemployeelogin%NOTFOUND) then
      close getemployeelogin;
      return NULL;
   else
      close getemployeelogin;
      return l_employee_login;
   end if;
*/

END GetEmployeeLogin;

--  Function: GetSupplierLogin
--  Desc: Given an supplier_id, returns back the user login
--
FUNCTION GetSupplierLogin ( p_supplier_id NUMBER ) return VARCHAR2 is

   l_supplier_login VARCHAR2(100) := NULL;

   cursor getsupplierlogin ( c_supplier_id number ) is
      select user_name
      from   fnd_user fu
      where  fu.supplier_id = p_supplier_id
      and    sysdate BETWEEN fu.start_date
    		         and nvl(fu.end_date, sysdate)
      order by user_name;

BEGIN

   open getsupplierlogin ( p_supplier_id );
   fetch getsupplierlogin into l_supplier_login;

   if (getsupplierlogin%NOTFOUND) then
      close getsupplierlogin;
      return NULL;
   else
      close getsupplierlogin;
      return l_supplier_login;
   end if;

END GetSupplierLogin;

-- Function: GetShipManagerLogin
-- Desc:  Finds the shipping manager id for an organization, and
--        then derives the shipping manager login
--
FUNCTION GetShipManagerLogin ( p_organization_id NUMBER ) return VARCHAR2 is
   l_shipper_id 	NUMBER := NULL;

BEGIN

   select shipping_manager_id
   into   l_shipper_id
   from   wip_parameters wp
   where  wp.organization_id = p_organization_id;

   return ( GetEmployeeLogin (l_shipper_id ));

   exception when no_data_found then
     return NULL;

END GetShipManagerLogin;

-- Function: GetProductionSchedLogin
-- Desc:  Finds the production scheduler id for an organization, and
--        then derives the production scheduler login
--
FUNCTION GetProductionSchedLogin ( p_organization_id NUMBER ) return VARCHAR2 is
   l_prod_sched_id	NUMBER := NULL;

BEGIN
   select production_scheduler_id
   into   l_prod_sched_id
   from   wip_parameters wp
   where  wp.organization_id = p_organization_id;

   return ( GetEmployeeLogin (l_prod_sched_id ));

   exception when no_data_found then
     return NULL;

END GetProductionSchedLogin;


-- Function: GetDefaultBuyerLogin
-- Desc:  Finds the login for the default buyer of an item in an organization
--        then derives the production scheduler login
--
FUNCTION GetDefaultBuyerLogin (p_organization_id	NUMBER,
			       p_item_id		NUMBER) return VARCHAR2 is

   l_default_buyer_id	NUMBER := NULL;

BEGIN

   select buyer_id
   into   l_default_buyer_id
   from   mtl_system_items msi
   where  msi.inventory_item_id = p_item_id
   and    msi.organization_id = p_organization_id;

   return ( GetEmployeeLogin (l_default_buyer_id));

   exception when no_data_found then
      return (NULL);

END GetDefaultBuyerLogin;


FUNCTION GetBuyerLogin (p_po_header_id	NUMBER,
			p_release_num NUMBER default NULL) return VARCHAR2 is

   l_buyer_id	NUMBER := NULL;

BEGIN
  if p_release_num is not null and p_release_num <> 0 then
      /* Fix for Bug#2344105 */
      select  pr.agent_id
      into    l_buyer_id
      from    po_releases_all  pr
      where   pr.po_header_id = p_po_header_id
      and     pr.release_num  = p_release_num ;
   else
      select  ph.agent_id
      into    l_buyer_id
      from    po_headers_all ph
      where   ph.po_header_id = p_po_header_id;
   end if ;

   return ( GetEmployeeLogin (l_buyer_id));

   exception when no_data_found then
      return (NULL);

END GetBuyerLogin;


FUNCTION GetSupplierContactLogin (p_po_header_id NUMBER) return VARCHAR2 is

   l_supplier_contact_id	  NUMBER := NULL;

BEGIN

    select vendor_contact_id
    into   l_supplier_contact_id
    from   po_headers_all ph
    where  ph.po_header_id = p_po_header_id;

   return ( GetSupplierLogin (l_supplier_contact_id));

   exception when no_data_found then
      return (NULL);

END GetSupplierContactLogin;

/* used for linking to PO webpage from notifications */
PROCEDURE OpenPO(p1     varchar2,
                 p2     varchar2,
                 p3     varchar2,
                 p4     varchar2,
                 p5     varchar2,
                 p6     varchar2,
                 p11    varchar2 default NULL) IS

l_param                 varchar2(240);
c_rowid                 varchar2(18);
l_session_id            number;

BEGIN

if icx_sec.validatesession then

   l_session_id := to_number(icx_sec.getID(icx_sec.PV_SESSION_ID));
   -- set multi org context
   if icx_call.decrypt(p11) is not NULL then
     icx_sec.set_org_context(l_session_id, icx_call.decrypt(p11));
   end if;

   select  rowidtochar(ROWID)
   into    c_rowid
   from    AK_FLOW_REGION_RELATIONS
   where   FROM_REGION_CODE = 'ICX_PO_OSP'
   and     FROM_REGION_APPL_ID = 178
   and     FROM_PAGE_CODE = 'ICX_RQS_HISTORY_1'
   and     FROM_PAGE_APPL_ID = 178
   and     TO_PAGE_CODE = 'ICX_RQS_HISTORY_DTL_D'
   and     TO_PAGE_APPL_ID = 178
   and     FLOW_CODE = 'ICX_INQUIRIES'
   and     FLOW_APPLICATION_ID = 178;


   l_param := icx_on_utilities.buildOracleONstring
                (p_rowid => c_rowid,
                 p_primary_key => 'ICX_RQS_HISTORY_PK',
                 p1 => icx_call.decrypt(p1));

   if l_session_id is null
   then
        OracleOn.IC(Y=>icx_call.encrypt2(l_param,-999));
   else
        OracleOn.IC(Y=>icx_call.encrypt2(l_param,l_session_id));
   end if;

end if;


END OpenPO;

END wip_std_wf;

/
