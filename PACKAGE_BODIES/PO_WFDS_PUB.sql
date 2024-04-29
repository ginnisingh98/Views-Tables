--------------------------------------------------------
--  DDL for Package Body PO_WFDS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_WFDS_PUB" AS
/* $Header: POXPWFDB.pls 120.0.12010000.2 2011/02/11 11:10:50 kcthirum noship $ */

-- Read the profile option that enables/disables the debug log
g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');

 /*=======================================================================+
 | FILENAME
 |   POXPWFDB.pls
 |
 | DESCRIPTION
 |   PL/SQL body for package: PO_WFDS_PUB
 |
 *=======================================================================*/
--

procedure synch_supp_wth_wf_dir_srvcs(  itemtype        in varchar2,
                               itemkey         in varchar2,
                               actid           in number,
                               funcmode        in varchar2,
                               resultout       out nocopy varchar2)
is

   l_party_type     varchar2(1);
   l_event_reason   varchar2(30);
   l_site_address   varchar2(2000);
   l_vendor_id      number;
   l_vendor_site_id number;
   l_vendor_name    varchar2(255);
   l_language       varchar2(30);
   l_email          varchar2(2000);
   l_fax            varchar2(15);
   l_site_code      varchar2(15);

   l_parameter_list wf_parameter_list_t := wf_parameter_list_t();

begin

   /*  Get vendor_id, vendor_site_id etc., from workflow item attributes  */
   l_event_reason := wf_engine.GetItemAttrText (itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'ECX_TP_MOD_TYPE');

   if (l_event_reason = 'DELETE') then
      return; /* we don't want to do anything in case of delete */
   end if;

   l_vendor_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'ECX_PARTY_ID');

   l_vendor_site_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'ECX_PARTY_SITE_ID');

   l_party_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'ECX_PARTY_TYPE');

   l_email := wf_engine.GetItemAttrText (itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'ECX_COMPANY_ADMIN_EMAIL');

   /*  Get all the necessary data from po_vendors_all and po_vendors */

   select vendor_name
     into l_vendor_name
     from po_vendors
    where vendor_id = l_vendor_id;

   select language, fax, vendor_site_code,
          ADDRESS_LINE1 || ' ' || ADDRESS_LINE2 || ' ' || ADDRESS_LINE3 || ' ' || CITY || ' ' || STATE || ' ' || ' ' || ZIP || ' ' || COUNTRY  site_address
     into l_language, l_fax, l_site_code, l_site_address
     from po_vendor_sites_all
    where vendor_site_id = l_vendor_site_id;

  /*  First synch the PO_VENDORS  */
   -- Add Parameters
   wf_event.AddParameterToList(p_name=>'USER_NAME', p_value=>'PO_VENDORS:'||l_vendor_id, p_parameterlist=>l_parameter_list);
   wf_event.AddParameterToList(p_name=>'DISPLAYNAME', p_value=>l_vendor_name, p_parameterlist=>l_parameter_list);
   wf_event.AddParameterToList(p_name=>'ORCLISENABLED', p_value=>'ACTIVE', p_parameterlist=>l_parameter_list);
   wf_event.AddParameterToList(p_name=>'EXPIRATIONDATE', p_value=>null, p_parameterlist=>l_parameter_list);
   wf_event.AddParameterToList(p_name=>'ORCLWFORIGSYSTEM', p_value=>'PO_VENDORS', p_parameterlist=>l_parameter_list);
   wf_event.AddParameterToList(p_name=>'ORCLWFORIGSYSTEMID', p_value=>l_vendor_id, p_parameterlist=>l_parameter_list);
   wf_event.AddParameterToList(p_name =>'UPDATEONLY',  p_value =>'TRUE', p_parameterlist=>l_parameter_list);

   WF_LOCAL_SYNCH.propagate_role(p_orig_system => 'PO_VENDORS', /* in varchar2 */
                         p_orig_system_id => l_vendor_id,  /* in number */
                         p_attributes => l_parameter_list,  /* in wf_parameter_list_t */
                         p_start_date  => sysdate,   /* in date */
                         p_expiration_date  => null /* in date */);

   l_parameter_list.DELETE;

   /*  Next synch the PO_VENDOR_SITES  */
   -- Add Parameters
   wf_event.AddParameterToList(p_name=>'USER_NAME', p_value=>'PO_VENDOR_SITES:'||l_vendor_site_id, p_parameterlist=>l_parameter_list);
   wf_event.AddParameterToList(p_name=>'DISPLAYNAME', p_value=>l_vendor_name||' '||l_site_address, p_parameterlist=>l_parameter_list);
   wf_event.AddParameterToList(p_name=>'PREFERREDLANGUAGE', p_value=>l_language, p_parameterlist=>l_parameter_list);
   --wf_event.AddParameterToList(p_name=>'ORCLNLSTERRITORY', p_value=>l_language, p_parameterlist=>l_parameter_list);
   wf_event.AddParameterToList(p_name=>'MAIL', p_value=>l_email, p_parameterlist=>l_parameter_list);
   wf_event.AddParameterToList(p_name=>'FACSIMILETELEPHONENUMBER', p_value=>l_fax, p_parameterlist=>l_parameter_list);
   wf_event.AddParameterToList(p_name=>'ORCLISENABLED', p_value=>'ACTIVE', p_parameterlist=>l_parameter_list);
   wf_event.AddParameterToList(p_name=>'EXPIRATIONDATE', p_value=>null, p_parameterlist=>l_parameter_list);
   wf_event.AddParameterToList(p_name=>'ORCLWFORIGSYSTEM', p_value=>'PO_VENDOR_SITES', p_parameterlist=>l_parameter_list);
   wf_event.AddParameterToList(p_name=>'ORCLWFORIGSYSTEMID', p_value=>l_vendor_site_id, p_parameterlist=>l_parameter_list);
   wf_event.AddParameterToList(p_name =>'UPDATEONLY', p_value =>'TRUE', p_parameterlist => l_parameter_list);

   WF_LOCAL_SYNCH.propagate_role(p_orig_system => 'PO_VENDOR_SITES',
                         p_orig_system_id => l_vendor_site_id,
                         p_attributes => l_parameter_list,
                         p_start_date  => sysdate,
                         p_expiration_date  => null);

   l_parameter_list.DELETE;

  exception
      WHEN No_Data_Found then
 	           -- do nothing, as the event might be raised for customer case and we do not handle customer case here.
	return;
      when others then
         l_parameter_list.DELETE;
         raise;

end synch_supp_wth_wf_dir_srvcs;

end PO_WFDS_PUB;

/
