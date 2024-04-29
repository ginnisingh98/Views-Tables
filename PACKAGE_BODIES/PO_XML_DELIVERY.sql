--------------------------------------------------------
--  DDL for Package Body PO_XML_DELIVERY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_XML_DELIVERY" AS
/* $Header: POXWXMLB.pls 120.13.12010000.11 2014/04/09 18:11:58 prilamur ship $ */

-- Read the profile option that enables/disables the debug log
g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');

 /*=======================================================================+
 | FILENAME
 |   POXWXMLB.pls
 |
 | DESCRIPTION
 |   PL/SQL body for package: PO_XML_DELIVERY
 |
 | NOTES        jbalakri Created 5/3/2001
 | MODIFIED    (MM/DD/YY)
 *=======================================================================*/
--

-- B4407795
-- Added new helper function to check if supplier is setup to use the
-- rosettanet CANCELPO_REQ transaction.
-- This is used the the set_delivery_data routine
FUNCTION isRosettaNetTxn(
        l_party_id           IN VARCHAR2,
        l_party_site_id      IN VARCHAR2) RETURN BOOLEAN
IS
        l_result        boolean;
        l_retcode       VARCHAR2(100);
        l_errmsg        VARCHAR2(2000);
BEGIN
        l_result := FALSE;
        ecx_document.isDeliveryRequired
                         (
                         transaction_type    => 'M4R',
                         transaction_subtype => 'CANCELPO_REQ',
                         party_id            => l_party_id,
                         party_site_id       => l_party_site_id,
                         resultout           => l_result,
                         retcode             => l_retcode,
                         errmsg              => l_errmsg
                         );
        return l_result;
EXCEPTION
          WHEN OTHERS THEN
            RETURN false;
END;

Procedure call_txn_delivery (  itemtype  in varchar2,
itemkey         in varchar2,
actid           in number,
funcmode        in varchar2,
resultout       out nocopy varchar2) IS
x_progress                  VARCHAR2(100) := '000';
x_msg number;
  x_ret number;
  x_err_msg varchar2(2000);
  l_vendor_site_id  number;
  l_vendor_id number;
  l_doc_id number;
  l_revision_num  number:=0;
  l_doc_subtype  varchar2(5);
  l_doc_type      varchar2(20);
  l_doc_rel_id  number:=null;
  BEGIN

  --NOTE - This procedure is obsoleted from FPG onwards.
  x_progress := 'PO_XML_DELIVERY.call_txn_delivery : 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;  --do not raise the exception, as it would end the wflow.

  end if;

   --get the po_header_id for item passed and assign it to document_id.
   --get the version number (in case PO Change) and assign it to PARAMETER1.
   -- if (if revision_num in po_headers_all for the document id is 0,
-- it is a new PO) then
   --    document_type = 'POO';
 -- else
   --    document_type = 'POCO'

    l_doc_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'DOCUMENT_ID');

    l_doc_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'DOCUMENT_TYPE');
    begin
     if l_doc_type = 'RELEASE' then
      l_doc_rel_id := l_doc_id;

      select por.revision_num,poh.vendor_id,poh.vendor_site_id,
             poh.po_header_id
      into   l_revision_num,l_vendor_id ,l_vendor_site_id,l_doc_id
      from   po_headers_all poh,po_releases_all por
      where  poh.po_header_id=por.po_header_id
      and    por.po_release_id  = l_doc_rel_id;
     elsif (l_doc_type = 'PO' or l_doc_type = 'STANDARD')    then --for standard POs.
        select revision_num,vendor_id,vendor_site_id
        into l_revision_num,l_vendor_id ,l_vendor_site_id
        from po_headers_all
        where po_header_id= l_doc_id;
     else
        x_progress :=  'PO_XML_DELIVERY.: call_txn_delivery:02: POs of type ' || l_doc_type || 'is not supported for XML Delivery';
    wf_core.context('PO_XML_DELIVERY','call_txn_delivery',x_progress);
        return;

     end if;

    exception
     when others then
      x_progress :=  'PO_XML_DELIVERY.: call_txn_delivery:02';
    wf_core.context('PO_XML_DELIVERY','call_txn_delivery',x_progress);
      return;   --do not raise the exception as that would end the wflow.
    end ;

    if nvl(l_revision_num,0)=0 then
       l_doc_subtype :='PRO';
    else
       l_doc_subtype :='POCO';
    end if;

/*  removed ecx_document.send . To avoid unnecessary dependency on ECX. */



     resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';
 x_progress :=  'PO_XML_DELIVERY.call_txn_delivery: 03';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;
   EXCEPTION
    WHEN OTHERS THEN
    wf_core.context('PO_XML_DELIVERY','call_txn_delivery',x_progress);
        return;

  END call_txn_delivery;

Procedure initialize_wf_parameters (
   itemtype  in varchar2,
   itemkey         in varchar2,
   actid           in number,
   funcmode        in varchar2,
   resultout       out nocopy varchar2)
IS
x_progress      varchar2(3) := '000';
l_po_header_id  number;
l_po_type       varchar2(20);
l_po_subtype    varchar2(20);
l_revision_num   number;
l_po_number       varchar2(40);
l_org_id          number;
l_party_id        number;
l_party_site_id   number;
l_po_desc         varchar2(240);
l_doc_rel_id      number;
l_doc_creation_date date;
begin

 -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;  --do not raise the exception, as it would end the wflow.

  end if;


l_po_header_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'DOCUMENT_ID');
l_po_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'DOCUMENT_TYPE');
l_revision_num :=  wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'PO_REVISION_NUM');



if (l_po_type = 'STANDARD' or l_po_type = 'PO') then
   select segment1, org_id, vendor_id, vendor_site_id, comments, type_lookup_code,creation_date
   into l_po_number, l_org_id, l_party_id, l_party_site_id, l_po_desc, l_po_subtype,l_doc_creation_date
   from po_headers_all
   where po_header_id = l_po_header_id;
elsif (l_po_type = 'RELEASE') then
  --In case of RELEASE DOCUMENT_ID will have the RELEASE_ID.
  --Copy it over here so, it is less confusing.
  l_doc_rel_id := l_po_header_id;
  -- dbms_output.put_line ('The l_doc_rel_id in intiailize is : ' || to_char(l_doc_rel_id));
  select poh.segment1 || ':' || to_char(por.release_num), poh.org_id,
         poh.vendor_id, poh.vendor_site_id, poh.comments,poh.creation_date
  into   l_po_number, l_org_id, l_party_id, l_party_site_id, l_po_desc,
         l_doc_creation_date
  from   po_headers_all poh,po_releases_all por
  where  poh.po_header_id=por.po_header_id
  and    por.po_release_id  = l_doc_rel_id;

  l_po_subtype := 'RELEASE';

else

  /*  in case of BLANKET, PLANNED, etc where we are not interested in sending XML
      To be graceful we still want to initialize the parameters and continue.
      If we don't want XML transaction it will terminate as is_XML_chosen will end it.
   */
      select segment1, org_id, vendor_id, vendor_site_id, comments,creation_date
      into l_po_number, l_org_id, l_party_id, l_party_site_id,l_po_desc,
           l_doc_creation_date
      from po_headers_all
   where po_header_id = l_po_header_id;


end if;

        --
        wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'PO_NUMBER' ,
                              avalue     => l_po_number);
        --
        wf_engine.SetItemAttrNumber ( itemtype        => itemtype,
                                      itemkey         => itemkey,
                                      aname           => 'ORG_ID',
                                      avalue          =>  l_org_id);
        --
        wf_engine.SetItemAttrNumber ( itemtype        => itemtype,
                                      itemkey         => itemkey,
                                      aname           => 'ECX_PARTY_ID',
                                      avalue          =>  l_party_id);
        --
        wf_engine.SetItemAttrNumber ( itemtype        => itemtype,
                                      itemkey         => itemkey,
                                      aname           => 'ECX_PARTY_SITE_ID',
                                      avalue          =>  l_party_site_id);
        --
        wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'PO_DESCRIPTION' ,
                              avalue     => l_po_desc);

        --
        wf_engine.SetItemAttrText ( itemtype   => itemType,
                                      itemkey    => itemkey,
                                      aname      => 'DOCUMENT_SUBTYPE' ,
                                      avalue     => l_po_subtype);

        --  CLN scpecific attributes
        wf_engine.SetItemAttrText ( itemtype   => itemType,
                                              itemkey    => itemkey,
                                              aname      => 'XMLG_DOCUMENT_ID' ,
                                              avalue     => to_char(l_po_header_id));

        wf_engine.SetItemAttrText ( itemtype   => itemType,
                                              itemkey    => itemkey,
                                              aname      => 'TRADING_PARTNER_ID' ,
                                              avalue     => to_char(l_party_id));
        wf_engine.SetItemAttrText ( itemtype   => itemType,
                                              itemkey    => itemkey,
                                              aname      => 'TRADING_PARTNER_SITE' ,
                                              avalue     => to_char(l_party_site_id));



         --
         wf_engine.SetItemAttrText ( itemtype   => itemType,
                                     itemkey    => itemkey,
                                     aname      => 'DOCUMENT_NO' ,
                                     avalue     => l_po_number);

         wf_engine.SetItemAttrText ( itemtype   => itemType,
                                     itemkey    => itemkey,
                                     aname      => 'TRADING_PARTNER_TYPE' ,
                                     avalue     => 'S');
         wf_engine.SetItemAttrText ( itemtype   => itemType,
                                     itemkey    => itemkey,
                                     aname      => 'DOCUMENT_DIRECTION' ,
                                     avalue     => 'OUT');

         wf_engine.SetItemAttrText ( itemtype   => itemType,
                                     itemkey    => itemkey,
                                     aname      => 'DOCUMENT_CREATION_DATE',
                                     avalue     => TO_CHAR(l_doc_creation_date,
                                                   'YYYY/MM/DD HH24:MI:SS'));





exception
when others then
   wf_core.context('PO_XML_DELIVERY','initialize_wf_parameters',x_progress);
  raise;
  --return;

end;


Procedure set_delivery_data (  itemtype  in varchar2,
itemkey         in varchar2,
actid           in number,
funcmode        in varchar2,
resultout       out nocopy varchar2) IS
x_progress                  VARCHAR2(100) := '000';

  l_vendor_site_id  number;
  l_vendor_id number;
  l_doc_id number;
  l_revision_num  number:=0;
  l_doc_subtype  varchar2(5);
  l_doc_type      varchar2(20);
  l_doc_rel_id  number:=null;
  l_user_id           number;
  l_responsibility_id number;
  l_application_id    varchar2(30);
  l_po_num            varchar2(100);
  l_trnx_doc_id      varchar2(200);
  l_user_resp_appl    varchar2(200);
  l_cancel_flag       varchar2(10);

  l_xml_event_key varchar2(100);
  l_wf_item_seq number;
  x_org_id number;

  BEGIN
  -- dbms_output.put_line('here in set_delivery_date ' || itemkey);

   -- set the org context
    x_org_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'ORG_ID');
   if (x_org_id is not null) then
      PO_MOAC_UTILS_PVT.set_org_context(x_org_id) ;       -- <R12 MOAC>
   end if;

  x_progress := 'PO_XML_DELIVERY.set_delivery_data : 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;  --do not raise the exception, as it would end the wflow.

  end if;


   --get the po_header_id for item passed and assign it to document_id.
   --get the version number (in case PO Change) and assign it to PARAMETER1.
   -- if (if revision_num in po_headers_all for the document id is 0,
-- it is a new PO) then
   --    document_type = 'POO';
 -- else
   --    document_type = 'POCO'

    l_doc_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'DOCUMENT_ID');

    l_doc_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'DOCUMENT_TYPE');

    l_user_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'USER_ID');

    l_responsibility_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'RESPONSIBILITY_ID');
    --bug#5442045
    /*l_application_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'APPLICATION_ID');*/

    l_application_id := wf_engine.GetItemAttrText ( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'APPLICATION_ID');

  x_progress := 'PO_XML_DELIVERY.set_delivery_data : 01.1';


   if instrb(l_application_id,'.') > 0 then
      l_application_id := substrb(l_application_id,1,instrb(l_application_id,'.')-1);
      l_application_id := replace(l_application_id,'.','');
   end if;

    x_progress := 'PO_XML_DELIVERY.set_delivery_data : 01.3';

      wf_engine.SetItemAttrText (     itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'APPLICATION_ID',
                                        avalue     =>  l_application_id);
    --bug#5442045 ends


    l_user_resp_appl := l_user_id || ':' || l_responsibility_id || ':' || l_application_id;

    l_po_num := wf_engine.GetItemAttrText ( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'PO_NUMBER');

    begin

     wf_engine.SetItemAttrText (     itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'ECX_TRANSACTION_TYPE',
                                        avalue     =>  'PO');

     if l_doc_type = 'RELEASE' then

      l_doc_rel_id := l_doc_id;

      wf_engine.SetItemAttrText (     itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'ECX_PARAMETER1',
                                        avalue     =>  l_doc_id);

      select por.revision_num,poh.vendor_id,poh.vendor_site_id,
             poh.po_header_id, por.cancel_flag
      into   l_revision_num,l_vendor_id ,l_vendor_site_id,l_doc_id, l_cancel_flag --B4407795,reading cancel flag
      from   po_headers_all poh,po_releases_all por
      where  poh.po_header_id=por.po_header_id
      and    por.po_release_id  = l_doc_rel_id;


     elsif (l_doc_type = 'PO' or l_doc_type = 'STANDARD')    then --for standard POs.
        select revision_num,vendor_id,vendor_site_id,cancel_flag
        into l_revision_num,l_vendor_id ,l_vendor_site_id, l_cancel_flag --B4407795,reading cancel flag
        from po_headers_all
        where po_header_id= l_doc_id;
     else
        x_progress :=  'PO_XML_DELIVERY.: set_delivery_data:02: POs of type ' || l_doc_type || 'is not supported for XML Delivery';
    wf_core.context('PO_XML_DELIVERY', 'set_delivery_data',x_progress);
        return;

     end if;

    exception
     when others then
      x_progress :=  'PO_XML_DELIVERY.: set_delivery_data:02';
    wf_core.context('PO_XML_DELIVERY','set_delivery_data',x_progress);
      return;   --do not raise the exception as that would end the wflow.
    end ;

    select PO_WF_ITEMKEY_S.nextval
      into l_wf_item_seq
      from dual;

    l_xml_event_key := to_char(l_doc_id) || '-' ||
                       to_char(l_wf_item_seq);

    wf_engine.SetItemAttrText (   itemtype   => itemType,
                                        itemkey    => itemkey,
                                        aname      => 'XML_EVENT_KEY',
                                        avalue     => l_xml_event_key);

    wf_engine.SetItemAttrText (   itemtype   => itemType,
                                        itemkey    => itemkey,
                                        aname      => 'ECX_PARAMETER2',
                                        avalue     => to_char(l_revision_num));

   l_trnx_doc_id := l_po_num||':'||l_revision_num||':'||to_char(x_org_id);

    wf_engine.SetItemAttrText (   itemtype   => itemType,
                                        itemkey    => itemkey,
                                        aname      => 'ECX_DOCUMENT_ID',
                                        avalue     => l_trnx_doc_id);


    wf_engine.SetItemAttrText (   itemtype   => itemType,
                                        itemkey    => itemkey,
                                        aname      => 'ECX_PARTY_ID',
                                        avalue     => to_char(l_vendor_id));

    wf_engine.SetItemAttrText (   itemtype   => itemType,
                                        itemkey    => itemkey,
                                        aname      => 'ECX_PARTY_SITE_ID',
                                        avalue     => to_char(l_vendor_site_id));

    wf_engine.SetItemAttrText (   itemtype   => itemType,
                                        itemkey    => itemkey,
                                        aname      => 'ECX_PARAMETER3',
                                        avalue     => l_user_resp_appl);

    wf_engine.SetItemAttrText (   itemtype   => itemType,
                                        itemkey    => itemkey,
                                        aname      => 'ECX_PARAMETER4',
                                        avalue     => to_char(l_doc_id));


    wf_engine.SetItemAttrText (   itemtype   => itemType,
                                        itemkey    => itemkey,
                                        aname      => 'ECX_PARAMETER5',
                                        avalue     => to_char(x_org_id));



    wf_engine.SetItemAttrText ( itemtype   => itemType,
                                itemkey    => itemkey,
                                aname      => 'XMLG_INTERNAL_TXN_TYPE' ,
                                avalue     => 'PO');



    if nvl(l_revision_num,0)=0 then
      wf_engine.SetItemAttrText (     itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'ECX_TRANSACTION_SUBTYPE',
                                        avalue     =>  'PRO');
      wf_engine.SetItemAttrText ( itemtype   => itemType,
                                itemkey    => itemkey,
                                aname      => 'XMLG_INTERNAL_TXN_SUBTYPE' ,
                                avalue     => 'PRO');
    else

        -- B4407795
        -- For PO Changes, check if it is a Cancel PO or Cancel PO Release
        -- If yes, check if a rosettanet txn is defined for the supplier
        -- and set the transaction type, subtype accordingly
        if nvl(l_cancel_flag,'N') = 'Y' and isRosettaNetTxn(l_vendor_id, l_vendor_site_id) then

                wf_engine.SetItemAttrText (     itemtype   => itemtype,
                                                itemkey    => itemkey,
                                                aname      => 'ECX_TRANSACTION_TYPE',
                                                avalue     =>  'M4R');

                wf_engine.SetItemAttrText (     itemtype   => itemType,
                                                itemkey    => itemkey,
                                                aname      => 'XMLG_INTERNAL_TXN_TYPE' ,
                                                avalue     => 'M4R');

                wf_engine.SetItemAttrText (     itemtype   => itemtype,
                                                itemkey    => itemkey,
                                                aname      => 'ECX_TRANSACTION_SUBTYPE',
                                                avalue     =>  'CANCELPO_REQ');

                wf_engine.SetItemAttrText (     itemtype   => itemType,
                                                itemkey    => itemkey,
                                                aname      => 'XMLG_INTERNAL_TXN_SUBTYPE',
                                                avalue     => 'CANCELPO_REQ');

        else

                wf_engine.SetItemAttrText (     itemtype   => itemtype,
                                                itemkey    => itemkey,
                                                aname      => 'ECX_TRANSACTION_SUBTYPE',
                                                avalue     =>  'POCO');

                wf_engine.SetItemAttrText (     itemtype   => itemType,
                                                itemkey    => itemkey,
                                                aname      => 'XMLG_INTERNAL_TXN_SUBTYPE' ,
                                                avalue     => 'POCO');
        end if;
   end if;

        resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';
        x_progress :=  'PO_XML_DELIVERY.set_delivery_data: 03';
        IF (g_po_wf_debug = 'Y') THEN
                /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
        END IF;

   EXCEPTION
    WHEN OTHERS THEN
    wf_core.context('PO_XML_DELIVERY','set_delivery_data',x_progress);
        --return;
        raise;

  END set_delivery_data;

-- as of current implementation, ecx standard activity raises exception if trading partner setup has problem
-- this procedure will check the setup and return no if  trading partner setup has problem

Procedure is_partner_setup (  itemtype  in varchar2,
itemkey         in varchar2,
actid           in number,
funcmode        in varchar2,
resultout       out nocopy varchar2) IS
x_progress                  VARCHAR2(100) := '000';

  l_document_id            number;
  l_document_type varchar2(25);
  l_document_subtype varchar2(25);

  transaction_type       varchar2(240);
  transaction_subtype    varchar2(240);
  party_id               varchar2(240);
  party_site_id          varchar2(240);
  retcode                pls_integer;
  errmsg                 varchar2(2000);
  result                 boolean := FALSE;

-- <FPJ Refactor Archiving API>
l_return_status varchar2(1) ;
l_msg_count NUMBER := 0;
l_msg_data VARCHAR2(2000);


BEGIN
  x_progress := 'PO_XML_DELIVERY.is_partner_setup : 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,x_progress);
  END IF;

  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;  --do not raise the exception, as it would end the wflow.

  end if;

  --
  -- Retreive Activity Attributes
  --
  transaction_type  := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'ECX_TRANSACTION_TYPE');

  if ( transaction_type is null ) then
        wf_core.token('ECX_TRANSACTION_TYPE','NULL');
        wf_core.raise('WFSQL_ARGS');
  end if;
  --
  transaction_subtype  := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'ECX_TRANSACTION_SUBTYPE');

  if ( transaction_subtype is null ) then
        wf_core.token('ECX_TRANSACTION_SUBTYPE','NULL');
        wf_core.raise('WFSQL_ARGS');
  end if;

  --
  party_site_id  := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'ECX_PARTY_SITE_ID');

  if ( party_site_id is null ) then
        wf_core.token('ECX_PARTY_SITE_ID','NULL');
        wf_core.raise('WFSQL_ARGS');
  end if;

  --
  -- party_id is optional. Only party_site_id is required
  --
  party_id  := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'ECX_PARTY_ID');
  --

  ecx_document.isDeliveryRequired
                        (
                        transaction_type    => transaction_type,
                        transaction_subtype => transaction_subtype,
                        party_id            => party_id,
                        party_site_id       => party_site_id,
                        resultout           => result,
                        retcode             => retcode,
                        errmsg              => errmsg
                        );

  if (result) then

    x_progress := 'PO_XML_DELIVERY.is_partner_setup : 02';

    -- Reached Here. Successful execution.

    resultout := 'COMPLETE:T';

    l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

    l_document_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

    l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

    -- <FPJ Refactor Archiving API>
    PO_DOCUMENT_ARCHIVE_GRP.Archive_PO(
      p_api_version => 1.0,
      p_document_id => l_document_id,
      p_document_type => l_document_type,
      p_document_subtype => l_document_subtype,
      p_process => 'PRINT',
      x_return_status => l_return_status,
      x_msg_count => l_msg_count,
      x_msg_data => l_msg_data);

  else

     x_progress := 'PO_XML_DELIVERY.is_partner_setup : 03';

     resultout := 'COMPLETE:F';

  end if;


  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,x_progress);
  END IF;
exception

when others then
  x_progress := 'PO_XML_DELIVERY.is_partner_setup : 04';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,x_progress);
  END IF;
  resultout := 'COMPLETE:F';

END is_partner_setup;

/* XML Delivery Project, FPG+ */
Procedure is_xml_chosen (  itemtype  in varchar2,
itemkey         in varchar2,
actid           in number,
funcmode        in varchar2,
resultout       out nocopy varchar2)
IS
l_doc_id number;
l_doc_rel_id number;
l_doc_type varchar2(20);
l_xml_flag varchar2(1);
l_agent_id number;
l_buyer_user_name varchar2(100);
x_progress VARCHAR2(100) := '000';
BEGIN
    x_progress := 'PO_XML_DELIVERY.is_xml_chosen : 01';
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;  --do not raise the exception, as it would end the wflow.

  end if;
        resultout := 'COMPLETE:F';
    l_doc_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'DOCUMENT_ID');


    l_doc_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'DOCUMENT_TYPE');

    x_progress := 'PO_XML_DELIVERY.is_xml_chosen : 02';
        if l_doc_type = 'RELEASE' then
    x_progress := 'PO_XML_DELIVERY.is_xml_chosen : 03';
                l_doc_rel_id := l_doc_id;


            select por.xml_flag,poh.agent_id into l_xml_flag, l_agent_id
            from   po_headers_all poh,po_releases_all por
            where  poh.po_header_id=por.po_header_id
            and    por.po_release_id  = l_doc_rel_id;

        elsif (l_doc_type = 'STANDARD'  or l_doc_type = 'PO')   then --for standard POs.
    x_progress := 'PO_XML_DELIVERY.is_xml_chosen : 04';
        select poh.xml_flag, poh.agent_id into l_xml_flag, l_agent_id
        from po_headers_all poh
        where po_header_id= l_doc_id;
        end if;
    x_progress := 'PO_XML_DELIVERY.is_xml_chosen : 05';
        if l_xml_flag = 'Y' then
                resultout := 'COMPLETE:T';
        end if;
    x_progress := 'PO_XML_DELIVERY.is_xml_chosen : 06';
exception when others then
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,x_progress);
  END IF;
        resultout := 'COMPLETE:F';
        -- dbms_output.put_line (SQLERRM);
        null;
END is_xml_chosen;

/* XML Delivery Project, FPG+ */
procedure xml_time_stamp        (        p_header_id       in varchar2,
                                         p_release_id    in     varchar2,
                                         p_org_id          in number,
                                         p_txn_type        in varchar2,
                                         p_document_type in varchar2)
is
--Bug 7436414- FP of 7423133 - Changed this proc to automonous to avoid deadlock
PRAGMA AUTONOMOUS_TRANSACTION;
begin
        if(p_document_type ='STANDARD') then
                if(p_txn_type = 'PRO') then
                        update po_headers_all
                        set xml_send_date = sysdate
                        where
                                po_header_id = p_header_id and
                                org_id = p_org_id;

                        update po_headers_archive_all
                        set xml_send_date = sysdate
                        where
                                po_header_id = p_header_id and
                                org_id = p_org_id and
                                revision_num = 0;

                elsif(p_txn_type = 'POCO') then
                        update po_headers_all
                        set xml_change_send_date = sysdate
                        where
                                po_header_id = p_header_id and
                                org_id = p_org_id;

                        update po_headers_archive_all
                        set xml_change_send_date = sysdate
                        where
                                po_header_id = p_header_id and
                                org_id = p_org_id and
                                latest_external_flag = 'Y';
                end if;
        else
                if(p_txn_type = 'PRO') then
                        update po_releases_all
                        set xml_send_date = sysdate
                        where
                                po_header_id  = p_header_id and
                                po_release_id = p_release_id and
                                org_id        = p_org_id;

                        update po_releases_archive_all
                        set xml_send_date = sysdate
                        where
                                po_header_id  = p_header_id and
                                  po_release_id = p_release_id and
                                org_id        = p_org_id and
                                revision_num  = 0;

                elsif(p_txn_type = 'POCO') then
                        update po_releases_all
                        set xml_change_send_date = sysdate
                        where
                                po_header_id  = p_header_id and
                                po_release_id = p_release_id and
                                org_id        = p_org_id;

                        update po_releases_archive_all
                        set xml_change_send_date = sysdate
                        where
                                po_header_id = p_header_id and
                                po_release_id = p_release_id and
                                org_id = p_org_id and
                                latest_external_flag = 'Y';
                end if;
        end if;
 commit;
end xml_time_stamp;

/* XML Delivery Project, FPG+ */
procedure get_line_requestor(   p_header_id in varchar2,
                                                                p_line_id in varchar2,
                                                                p_release_num in number,
                                                                p_document_type in varchar2,
                                                                p_revision_num in varchar2,
                                                                p_requestor out nocopy varchar2)
is
l_count number;
l_count_distinct number;
l_agent_id number;
begin
p_requestor := '';
if(p_document_type = 'STANDARD') then
        select count(1) into l_count_distinct from (
                select distinct(deliver_to_person_id)
                from po_distributions_archive_all pda
                where pda.po_header_id = p_header_id
                and pda.po_line_id = p_line_id
                and pda.revision_num = p_revision_num);

        if(     l_count_distinct = 1) then
                select distinct(deliver_to_person_id) into l_agent_id
                from po_distributions_archive_all pda
                where pda.po_header_id = p_header_id
                and pda.po_line_id = p_line_id
                and pda.revision_num = p_revision_num;

                if(l_agent_id is not null) then
                        select full_name into p_requestor from PER_ALL_PEOPLE_F where
                        person_id = l_agent_id and
                        effective_end_date >= sysdate;

                end if;
        end if;
else -- Release
        select count(1) into l_count_distinct from (
                select distinct(deliver_to_person_id) from po_distributions_archive_all pda
                where pda.po_header_id = p_header_id
                and pda.po_line_id = p_line_id
                and pda.revision_num = p_revision_num
                and pda.po_release_id = p_release_num);

        if(     l_count_distinct = 1) then
                select distinct(deliver_to_person_id) into l_agent_id from po_distributions_archive_all pda
                where pda.po_header_id = p_header_id
                and pda.po_line_id = p_line_id
                and pda.revision_num = p_revision_num
                and pda.po_release_id = p_release_num;

                if(l_agent_id is not null) then
                        select full_name into p_requestor from PER_ALL_PEOPLE_F where
                        person_id = l_agent_id and
                        effective_end_date >= sysdate;

                end if;
        end if;
end if;
exception when others then
        null;
end get_line_requestor;

/* XML Delivery Project, FPG+ */
procedure get_xml_send_date(    p_header_id in varchar2,
                                                                p_release_id in varchar2,
                                                                p_document_type in varchar2,
                                                                out_date out nocopy date)
is
l_poco_date date;
l_pro_date date;
begin
        if(p_document_type = 'STANDARD') then
                select xml_change_send_date, xml_send_date into
                l_poco_date, l_pro_date
                from po_headers_all
                where po_header_id = p_header_id;
                if(l_poco_date is not null) then
                        out_date := l_poco_date;
                elsif(l_pro_date is not null) then
                        out_date := l_pro_date;
                else
                        out_date := '';
                end if;
        else
                select xml_change_send_date, xml_send_date into
                l_poco_date, l_pro_date
                from po_releases_all
                where po_header_id = p_header_id
                and po_release_id = p_release_id;
                if(l_poco_date is not null) then
                        out_date := l_poco_date;
                elsif(l_pro_date is not null) then
                        out_date := l_pro_date;
                else
                        out_date := '';
                end if;
        end if;
exception when others then
        out_date := '';
end get_xml_send_date;

/* XML Delivery Project, FPG+ */
function get_max_line_revision(
                                p_header_id varchar2,
                                p_line_id varchar2,
                                p_line_revision_num number,
                                p_revision_num number) return number
is
l_line_revision number;
l_max_location_revision number;
l_max_distribution_revision number;
l_maxof_line_n_loc number;
l_one number;
doc_type varchar2(10);
begin

       --To fix bug# 5877293
        select type_lookup_code into doc_type
        from po_headers_all
        where po_header_id= p_header_id;

        if doc_type = 'BLANKET' then

            select max(revision_num) into l_one
            from po_lines_archive_all
            where po_header_id = p_header_id
            and po_line_id = p_line_id ;

       else

            select max(revision_num) into l_one
            from po_lines_archive_all
            where po_header_id = p_header_id
            and po_line_id = p_line_id
            and revision_num <= p_revision_num;
       end if;

        if(l_one = p_line_revision_num) then

                select max(revision_num) into l_line_revision
                from po_lines_archive_all
                where po_header_id = p_header_id
                and po_line_id = p_line_id
                and revision_num <= p_revision_num;

                select max(revision_num) into l_max_location_revision
                from po_line_locations_archive_all
                where po_header_id = p_header_id
                and po_line_id = p_line_id
                and revision_num <= p_revision_num;

                select max(revision_num) into l_max_distribution_revision
                from po_distributions_archive_all
                where po_header_id = p_header_id
                and po_line_id = p_line_id
                and revision_num <= p_revision_num;

                if(l_max_location_revision >= l_max_distribution_revision ) then
                        l_maxof_line_n_loc  := l_max_location_revision;
                else
                        l_maxof_line_n_loc  := l_max_distribution_revision;
                end if;

                if(l_line_revision >= l_maxof_line_n_loc) then
                        return l_line_revision;
                else
                        return l_maxof_line_n_loc;
                end if;
        else
                return -1;
        end if;

exception when others then
        return null;
end get_max_line_revision;


function get_max_location_revision(     p_header_id varchar2,
                                                                        p_line_id varchar2,
                                                                        p_location_id varchar2,
                                                                        p_location_revision_num number,
                                                                        p_revision_num number) return number
is
l_max_loc_revision number;
l_max_dist_revision number;
l_one number;
doc_type varchar2(10);
begin
        --To fix bug# 5877293
        select type_lookup_code into doc_type
        from po_headers_all
        where po_header_id= p_header_id;

    if doc_type = 'BLANKET' then
        select max(revision_num) into l_one
        from po_line_locations_archive_all
        where po_header_id = p_header_id
        and po_line_id = p_line_id
        and line_location_id = p_location_id;

    else
        select max(revision_num) into l_one
        from po_line_locations_archive_all
        where po_header_id = p_header_id
        and po_line_id = p_line_id
        and line_location_id = p_location_id
        and revision_num <= p_revision_num;

   end if;

  if (l_one = p_location_revision_num ) then

                select max(revision_num) into l_max_loc_revision
                from po_line_locations_archive_all
                where po_header_id = p_header_id
                and po_line_id = p_line_id
                and line_location_id = p_location_id
                and revision_num <= p_revision_num;

                select max(revision_num) into l_max_dist_revision
                from po_distributions_archive_all
                where po_header_id = p_header_id
                and po_line_id = p_line_id
                and line_location_id = p_location_id
                and revision_num <= p_revision_num;

                if(l_max_loc_revision >= l_max_dist_revision) then
                        return l_max_loc_revision ;
                else
                        return l_max_dist_revision;
                end if;
        else
                return -1;
        end if;

exception when others then
        return null;
end get_max_location_revision;


/* XML Delivery Project, FPG+ */
procedure get_card_info( p_header_id in varchar2,
       p_document_type in varchar2,
       p_release_id in varchar2,
       p_card_num out nocopy varchar2,
       p_card_name out nocopy varchar2,
       p_card_exp_date out nocopy date,
       p_card_brand out nocopy varchar2)
is
is_supplier_pcard number;
begin
 if(p_document_type = 'STANDARD') then
  select nvl(aca.card_number,icc.ccnumber ),nvl( aca.cardmember_name,icc.chname) ,
  nvl(aca.card_expiration_date,icc.expirydate) ,acpa.card_brand_lookup_code
  into p_card_num, p_card_name, p_card_exp_date, p_card_brand
  from ap_cards_all aca, ap_card_programs_all acpa, po_headers_all pha, iby_creditcard icc
  where pha.po_header_id = p_header_id
  and pha.pcard_id = aca.card_id
  and aca.card_program_id = acpa.card_program_id
  and aca.card_reference_id (+) = icc.instrid;
 else
  select nvl(aca.card_number,icc.ccnumber ),nvl( aca.cardmember_name,icc.chname) ,
  nvl(aca.card_expiration_date,icc.expirydate) ,acpa.card_brand_lookup_code
  into p_card_num, p_card_name, p_card_exp_date, p_card_brand
  from ap_cards_all aca, ap_card_programs_all acpa, po_releases_all pra, iby_creditcard icc
  where pra.po_header_id = p_header_id
  and pra.po_release_id = p_release_id
  and pra.pcard_id = aca.card_id
  and aca.card_program_id = acpa.card_program_id
  and aca.card_reference_id (+) = icc.instrid;
 end if;

 if(p_document_type = 'STANDARD') then
  select count(1)
  into is_supplier_pcard
  from ap_card_suppliers_all acsa, po_headers_all pha, iby_creditcard icc, ap_cards_all aca
  where acsa.card_id = pha.pcard_id
        and po_header_id = p_header_id
        and pha.pcard_id = aca.card_id
        and aca.card_reference_id (+) = icc.instrid;
 else
  select count(1)
  into is_supplier_pcard
  from ap_card_suppliers_all acsa, po_releases_all pra, iby_creditcard icc, ap_cards_all aca
  where acsa.card_id = pra.pcard_id
        and pra.po_header_id = p_header_id
        and pra.po_release_id = p_release_id
        and pra.pcard_id = aca.card_id
        and aca.card_reference_id (+) = icc.instrid;
 end if;

 if(is_supplier_pcard > 0) then
    select pva.vendor_name into p_card_name
    from po_vendors pva, po_headers_all pha
    where pha.po_header_id = p_header_id and
          pva.vendor_id = pha.vendor_id;
--  p_card_name := 'Supplier P-Card';

 end if;



exception when others then
 p_card_num := '0';  --cXML fails if number is not present
 p_card_name := '';
 p_card_exp_date := sysdate;  --cXML needs a card expiration date.
 p_card_brand := '';


end get_card_info;

/*Modified the signature, bug#6912518*/
procedure get_cxml_shipto_info( p_header_id  in number, p_line_location_id  in number,
                           p_ship_to_location_id in number,
                           p_ECE_TP_LOCATION_CODE out nocopy varchar2,
                           P_SHIP_TO_LOCATION_CODE OUT NOCOPY VARCHAR2,
                           p_ADDRESS_LINE_1 out nocopy varchar2,
			                     p_ADDRESS_LINE_2 out nocopy varchar2,
			                     p_ADDRESS_LINE_3 out nocopy varchar2,
			                     p_TOWN_OR_CITY out nocopy varchar2,
                           p_COUNTRY out nocopy varchar2, p_POSTAL_CODE out nocopy varchar2,
                           p_STATE out nocopy varchar2, p_TELEPHONE_NUMBER_1 out nocopy varchar2,
                           p_TELEPHONE_NUMBER_2 out nocopy varchar2, p_TELEPHONE_NUMBER_3 out nocopy varchar2,
                           p_iso_country_code out nocopy VARCHAR2)
is
begin
   get_shipto_info( p_header_id, p_line_location_id,
                    p_ship_to_location_id,
                    p_ECE_TP_LOCATION_CODE,
                    P_SHIP_TO_LOCATION_CODE,
                    p_ADDRESS_LINE_1, p_ADDRESS_LINE_2,
                    p_ADDRESS_LINE_3, p_TOWN_OR_CITY,
                    p_COUNTRY, p_POSTAL_CODE,
                    p_STATE, p_TELEPHONE_NUMBER_1,
                    p_TELEPHONE_NUMBER_2, p_TELEPHONE_NUMBER_3);

    if (p_COUNTRY is null) then
       p_COUNTRY := 'US';  --country is not  mandatory in hr_locations_all
    end if;
    p_iso_country_code := p_COUNTRY;

end;

procedure get_shipto_info( p_header_id  in number, p_line_location_id  in number,
                           p_ship_to_location_id in number,
                           p_ECE_TP_LOCATION_CODE out nocopy varchar2,
                           P_SHIP_TO_LOCATION_CODE OUT NOCOPY VARCHAR2,
                           p_ADDRESS_LINE_1 out nocopy varchar2, p_ADDRESS_LINE_2 out nocopy varchar2,
                           p_ADDRESS_LINE_3 out nocopy varchar2, p_TOWN_OR_CITY out nocopy varchar2,
                           p_COUNTRY out nocopy varchar2, p_POSTAL_CODE out nocopy varchar2,
                           p_STATE out nocopy varchar2, p_TELEPHONE_NUMBER_1 out nocopy varchar2,
                           p_TELEPHONE_NUMBER_2 out nocopy varchar2, p_TELEPHONE_NUMBER_3 out nocopy varchar2)
is
cnt   number := 0;
begin

/*  See if it is a drop-ship location or not  */

select count(*) into cnt
from OE_DROP_SHIP_SOURCES
where po_header_id = p_header_id and
      line_location_id = p_line_location_id;

/*  if drop ship  */
if (cnt > 0) then
select null, null, HZA.ADDRESS1, HZA.ADDRESS2,
       HZA.ADDRESS3, HZA.CITY, HZA.COUNTRY,
       HZA.POSTAL_CODE, HZA.STATE,
       null, --HZA.TELEPHONE_NUMBER_1,
       null, --HZA.TELEPHONE_NUMBER_2,
       null  -- HZA.TELEPHONE_NUMBER_3
into
       p_ECE_TP_LOCATION_CODE, P_SHIP_TO_LOCATION_CODE, p_ADDRESS_LINE_1, p_ADDRESS_LINE_2,
       p_ADDRESS_LINE_3, p_TOWN_OR_CITY,  p_COUNTRY,
       p_POSTAL_CODE, p_STATE, p_TELEPHONE_NUMBER_1,
       p_TELEPHONE_NUMBER_2, p_TELEPHONE_NUMBER_3
from   HZ_LOCATIONS HZA
where  HZA.LOCATION_ID = p_ship_to_location_id;

/*  it is not drop ship  */

else
select HLA.ECE_TP_LOCATION_CODE, HLA.LOCATION_CODE, HLA.ADDRESS_LINE_1, HLA.ADDRESS_LINE_2,
       HLA.ADDRESS_LINE_3, HLA.TOWN_OR_CITY, HLA.COUNTRY,
       HLA.POSTAL_CODE, HLA.REGION_2, HLA.TELEPHONE_NUMBER_1,
       HLA.TELEPHONE_NUMBER_2, HLA.TELEPHONE_NUMBER_3
into
       p_ECE_TP_LOCATION_CODE, P_SHIP_TO_LOCATION_CODE, p_ADDRESS_LINE_1, p_ADDRESS_LINE_2,
       p_ADDRESS_LINE_3, p_TOWN_OR_CITY,  p_COUNTRY,
       p_POSTAL_CODE, p_STATE, p_TELEPHONE_NUMBER_1,
       p_TELEPHONE_NUMBER_2, p_TELEPHONE_NUMBER_3
from   HR_LOCATIONS_ALL HLA
where  HLA.LOCATION_ID = p_ship_to_location_id;

end if;
exception when others then
  -- there can be an exception only if the ship_to_location id is not valid
  --  or if it is a drop ship it is not in hz_location or vice versa.
  raise;
end;

--- Address details to be mapped depending on address style
--  previous mapping works only for US_GLB
--  B46115474
PROCEDURE get_oag_shipto_info(
		p_header_id		in number,
 	      p_line_location_id	in number,
 	      p_ship_to_location_id	in number,
 	      p_ECE_TP_LOCATION_CODE	out nocopy varchar2,
 	      p_ADDRESS_LINE_1		out nocopy varchar2,
 	      p_ADDRESS_LINE_2		out nocopy varchar2,
 	      p_ADDRESS_LINE_3		out nocopy varchar2,
 	      p_TOWN_OR_CITY		out nocopy varchar2,
 	      p_COUNTRY			out nocopy varchar2,
 	      P_COUNTY         		out nocopy varchar2,
 	      p_POSTAL_CODE          	out nocopy varchar2,
 	      p_STATE                	out nocopy varchar2,
 	      p_REGION               	out nocopy varchar2,
 	      p_TELEPHONE_NUMBER_1   	out nocopy varchar2,
 	      p_TELEPHONE_NUMBER_2   	out nocopy varchar2,
 	      p_TELEPHONE_NUMBER_3   	out nocopy varchar2)
is
	cnt   number := 0;
begin

	/*  See if it is a drop-ship location or not  */
	select	count(*) into cnt
	from 		OE_DROP_SHIP_SOURCES
	where 	po_header_id = p_header_id and
      		line_location_id = p_line_location_id;

	/*  if drop ship  */
	if (cnt > 0) then
		select null, HZA.ADDRESS1, HZA.ADDRESS2,
			HZA.ADDRESS3, HZA.CITY, HZA.COUNTRY,
			HZA.POSTAL_CODE, HZA.STATE,
			null, --HZA.TELEPHONE_NUMBER_1,
			null, --HZA.TELEPHONE_NUMBER_2,
			null  -- HZA.TELEPHONE_NUMBER_3
		into
			p_ECE_TP_LOCATION_CODE, p_ADDRESS_LINE_1, p_ADDRESS_LINE_2,
			p_ADDRESS_LINE_3, p_TOWN_OR_CITY,  p_COUNTRY,
			p_POSTAL_CODE, p_STATE, p_TELEPHONE_NUMBER_1,
			p_TELEPHONE_NUMBER_2, p_TELEPHONE_NUMBER_3
		from	HZ_LOCATIONS HZA
		where	HZA.LOCATION_ID = p_ship_to_location_id;

	/*  it is not drop ship  */
	else
		select	HLA.ECE_TP_LOCATION_CODE, HLA.ADDRESS_LINE_1, HLA.ADDRESS_LINE_2,
				HLA.ADDRESS_LINE_3, HLA.TOWN_OR_CITY, HLA.COUNTRY,
				HLA.POSTAL_CODE, HLA.REGION_2, HLA.TELEPHONE_NUMBER_1,
				HLA.TELEPHONE_NUMBER_2, HLA.TELEPHONE_NUMBER_3
		into
				p_ECE_TP_LOCATION_CODE, p_ADDRESS_LINE_1, p_ADDRESS_LINE_2,
				p_ADDRESS_LINE_3, p_TOWN_OR_CITY,  p_COUNTRY,
				p_POSTAL_CODE, p_STATE, p_TELEPHONE_NUMBER_1,
				p_TELEPHONE_NUMBER_2, p_TELEPHONE_NUMBER_3
		from   HR_LOCATIONS_ALL HLA
		where  HLA.LOCATION_ID = p_ship_to_location_id;

		--- Address details to be mapped depending on address style
		--  previous mapping works only for US_GLB
		--  B46115474
		GET_HRLOC_ADDRESS(
			p_location_id    => p_ship_to_location_id,
			addrline1        => p_address_line_1,
			addrline2        => p_address_line_2,
			addrline3        => p_address_line_3,
			city             => p_town_or_city,
			country          => p_country,
			county           => p_county,
			postalcode       => p_postal_code,
			region           => p_region,
			stateprovn       => p_state);
	end if;
exception
  when no_data_found then
  begin

  if(cnt=0) then

    select null, HZA.ADDRESS1, HZA.ADDRESS2,
			HZA.ADDRESS3, HZA.CITY, HZA.COUNTRY,
			HZA.POSTAL_CODE, HZA.STATE,
			null, --HZA.TELEPHONE_NUMBER_1,
			null, --HZA.TELEPHONE_NUMBER_2,
			null  -- HZA.TELEPHONE_NUMBER_3
		into
			p_ECE_TP_LOCATION_CODE, p_ADDRESS_LINE_1, p_ADDRESS_LINE_2,
			p_ADDRESS_LINE_3, p_TOWN_OR_CITY,  p_COUNTRY,
			p_POSTAL_CODE, p_STATE, p_TELEPHONE_NUMBER_1,
			p_TELEPHONE_NUMBER_2, p_TELEPHONE_NUMBER_3
		from	HZ_LOCATIONS HZA
		where	HZA.LOCATION_ID = p_ship_to_location_id;

  end if;

  exception
     when others then
     raise;

  end;
	when others then
	-- there can be an exception only if the ship_to_location id is not valid
	--  or if it is a drop ship it is not in hz_location or vice versa.
	raise;
end get_oag_shipto_info;


PROCEDURE get_oag_header_shipto_info(
		p_header_id		in number,
 	      p_revision_num in number,
 	      p_ship_to_location_code	out nocopy varchar2,
 	      p_ECE_TP_LOCATION_CODE	out nocopy varchar2,
 	      p_ADDRESS_LINE_1		out nocopy varchar2,
 	      p_ADDRESS_LINE_2		out nocopy varchar2,
 	      p_ADDRESS_LINE_3		out nocopy varchar2,
 	      p_TOWN_OR_CITY		out nocopy varchar2,
 	      p_COUNTRY			out nocopy varchar2,
 	      P_COUNTY         		out nocopy varchar2,
 	      p_POSTAL_CODE          	out nocopy varchar2,
 	      p_STATE                	out nocopy varchar2,
 	      p_REGION               	out nocopy varchar2,
 	      p_TELEPHONE_NUMBER_1   	out nocopy varchar2,
 	      p_TELEPHONE_NUMBER_2   	out nocopy varchar2,
 	      p_TELEPHONE_NUMBER_3   	out nocopy varchar2)
is
  l_shipto_loc_id number := 0;
  cnt   number := 0;
  l_flag number := 0;

CURSOR shipto_cur (headerid number, revisionnum number) IS
	select	DISTINCT SHIP_TO_LOCATION_ID
	from 		PO_LINE_LOCATIONS_ARCHIVE_ALL
	where 	po_header_id = headerid and
          revision_num = revisionnum;


begin

   l_flag := 0;
   open shipto_cur(p_header_id, p_revision_num);
   loop
   fetch shipto_cur into l_shipto_loc_id;
     exit when shipto_cur%NOTFOUND;
     begin
       l_flag := l_flag + 1;
     end;
    end loop;
    close shipto_cur;

  if(l_flag=1) then

   begin

    /*  See if it is a drop-ship location or not  */
    select	count(*) into cnt
    from 		OE_DROP_SHIP_SOURCES
    where 	po_header_id = p_header_id;

	/*  if drop ship  */
	if (cnt > 0) then
		select null, null, HZA.ADDRESS1, HZA.ADDRESS2,
			HZA.ADDRESS3, HZA.CITY, HZA.COUNTRY,
			HZA.POSTAL_CODE, HZA.STATE,
			null, --HZA.TELEPHONE_NUMBER_1,
			null, --HZA.TELEPHONE_NUMBER_2,
			null  -- HZA.TELEPHONE_NUMBER_3
		into
			p_ECE_TP_LOCATION_CODE, p_ship_to_location_code, p_ADDRESS_LINE_1, p_ADDRESS_LINE_2,
			p_ADDRESS_LINE_3, p_TOWN_OR_CITY,  p_COUNTRY,
			p_POSTAL_CODE, p_STATE, p_TELEPHONE_NUMBER_1,
			p_TELEPHONE_NUMBER_2, p_TELEPHONE_NUMBER_3
		from	HZ_LOCATIONS HZA
		where	HZA.LOCATION_ID = l_shipto_loc_id;

	/*  it is not drop ship  */
	else
		select	HLA.ECE_TP_LOCATION_CODE, HLA.LOCATION_CODE, HLA.ADDRESS_LINE_1, HLA.ADDRESS_LINE_2,
				HLA.ADDRESS_LINE_3, HLA.TOWN_OR_CITY, HLA.COUNTRY,
				HLA.POSTAL_CODE, HLA.REGION_2, HLA.TELEPHONE_NUMBER_1,
				HLA.TELEPHONE_NUMBER_2, HLA.TELEPHONE_NUMBER_3
		into
				p_ECE_TP_LOCATION_CODE, p_ship_to_location_code, p_ADDRESS_LINE_1, p_ADDRESS_LINE_2,
				p_ADDRESS_LINE_3, p_TOWN_OR_CITY,  p_COUNTRY,
				p_POSTAL_CODE, p_STATE, p_TELEPHONE_NUMBER_1,
				p_TELEPHONE_NUMBER_2, p_TELEPHONE_NUMBER_3
		from   HR_LOCATIONS_ALL HLA
		where  HLA.LOCATION_ID = l_shipto_loc_id;

		--- Address details to be mapped depending on address style
		--  previous mapping works only for US_GLB
		--  B46115474
		GET_HRLOC_ADDRESS(
			p_location_id    => l_shipto_loc_id,
			addrline1        => p_address_line_1,
			addrline2        => p_address_line_2,
			addrline3        => p_address_line_3,
			city             => p_town_or_city,
			country          => p_country,
			county           => p_county,
			postalcode       => p_postal_code,
			region           => p_region,
			stateprovn       => p_state);
	end if;
exception
  when no_data_found then
  begin

  if(cnt=0) then

    select null, NULL, HZA.ADDRESS1, HZA.ADDRESS2,
			HZA.ADDRESS3, HZA.CITY, HZA.COUNTRY,
			HZA.POSTAL_CODE, HZA.STATE,
			null, --HZA.TELEPHONE_NUMBER_1,
			null, --HZA.TELEPHONE_NUMBER_2,
			null  -- HZA.TELEPHONE_NUMBER_3
		into
			p_ECE_TP_LOCATION_CODE, p_ship_to_location_code, p_ADDRESS_LINE_1, p_ADDRESS_LINE_2,
			p_ADDRESS_LINE_3, p_TOWN_OR_CITY,  p_COUNTRY,
			p_POSTAL_CODE, p_STATE, p_TELEPHONE_NUMBER_1,
			p_TELEPHONE_NUMBER_2, p_TELEPHONE_NUMBER_3
		from	HZ_LOCATIONS HZA
		where	HZA.LOCATION_ID = l_shipto_loc_id;

  end if;

  exception
     when others then
     raise;
  end;
	when others then
	-- there can be an exception only if the ship_to_location id is not valid
	--  or if it is a drop ship it is not in hz_location or vice versa.
	raise;
  end;
  end if;
  exception
     when others then
     raise;
end get_oag_header_shipto_info;


PROCEDURE get_oag_deliverto_info(
 	      p_deliver_to_location_id	in number,
 	      p_ECE_TP_LOCATION_CODE	out nocopy varchar2,
        p_deliver_to_location_code	out nocopy varchar2,
 	      p_ADDRESS_LINE_1		out nocopy varchar2,
 	      p_ADDRESS_LINE_2		out nocopy varchar2,
 	      p_ADDRESS_LINE_3		out nocopy varchar2,
 	      p_TOWN_OR_CITY		out nocopy varchar2,
 	      p_COUNTRY			out nocopy varchar2,
 	      P_COUNTY         		out nocopy varchar2,
 	      p_POSTAL_CODE          	out nocopy varchar2,
 	      p_STATE                	out nocopy varchar2,
 	      p_REGION               	out nocopy varchar2,
 	      p_TELEPHONE_NUMBER_1   	out nocopy varchar2,
 	      p_TELEPHONE_NUMBER_2   	out nocopy varchar2,
 	      p_TELEPHONE_NUMBER_3   	out nocopy varchar2)
is
begin

  select	HLA.ECE_TP_LOCATION_CODE, HLA.LOCATION_CODE, HLA.ADDRESS_LINE_1, HLA.ADDRESS_LINE_2,
      HLA.ADDRESS_LINE_3, HLA.TOWN_OR_CITY, HLA.COUNTRY,
      HLA.POSTAL_CODE, HLA.REGION_2, HLA.TELEPHONE_NUMBER_1,
      HLA.TELEPHONE_NUMBER_2, HLA.TELEPHONE_NUMBER_3
  into
      p_ECE_TP_LOCATION_CODE, p_deliver_to_location_code, p_ADDRESS_LINE_1, p_ADDRESS_LINE_2,
      p_ADDRESS_LINE_3, p_TOWN_OR_CITY,  p_COUNTRY,
      p_POSTAL_CODE, p_STATE, p_TELEPHONE_NUMBER_1,
      p_TELEPHONE_NUMBER_2, p_TELEPHONE_NUMBER_3
  from   HR_LOCATIONS_ALL HLA
  where  HLA.LOCATION_ID = p_deliver_to_location_id;

  --- Address details to be mapped depending on address style
  --  previous mapping works only for US_GLB
  --  B46115474
  GET_HRLOC_ADDRESS(
    p_location_id    => p_deliver_to_location_id,
    addrline1        => p_address_line_1,
    addrline2        => p_address_line_2,
    addrline3        => p_address_line_3,
    city             => p_town_or_city,
    country          => p_country,
    county           => p_county,
    postalcode       => p_postal_code,
    region           => p_region,
    stateprovn       => p_state);
  exception
    when others then
    -- there can be an exception only if the p_deliver_to_location_id is not valid
    raise;
end get_oag_deliverto_info;



procedure setXMLEventKey (  itemtype        in varchar2,
                          itemkey         in varchar2,
                          actid           in number,
                          funcmode        in varchar2,
                          resultout       out nocopy varchar2) is
l_doc_id  number;
l_xml_event_key  varchar2(100);
l_wf_item_seq  number;
l_document_type varchar2(15);

begin

    l_doc_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');


    select PO_WF_ITEMKEY_S.nextval
      into l_wf_item_seq
      from dual;

    l_xml_event_key := to_char(l_doc_id) || '-' ||
                       to_char(l_wf_item_seq);

    wf_engine.SetItemAttrText (   itemtype   => itemType,
                                        itemkey    => itemkey,
                                        aname      => 'XML_EVENT_KEY',
                                        avalue     => l_xml_event_key);


    -- <Bug 4950854 Begin>
    /* Need to set the print count also, when communicating through  XML */

    l_document_type := PO_WF_UTIL_PKG.GetItemAttrText(itemtype=> itemType,
                                                      itemkey => itemkey,
                                                      aname   => 'DOCUMENT_TYPE');

    PO_REQAPPROVAL_INIT1.update_print_count(l_doc_id,l_document_type);
    -- <Bug 4950854 End>


    exception when others then
    -- To handle rare case exceptions.  We should not proceed.
    raise;
end;

procedure setwfUserKey (  itemtype        in varchar2,
                          itemkey         in varchar2,
                          actid           in number,
                          funcmode        in varchar2,
                          resultout       out nocopy varchar2) is
l_document_id  number;
l_ponum        varchar2(20);
l_revision_num number;
l_release_id   number;
l_release_num  number;
l_user_key     varchar2(100);
x_progress     varchar2(100);

begin

x_progress := 'PO_XML_DELIVERY.setwfUserKey : 01';
l_document_id := to_number(wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ECX_DOCUMENT_ID'));

l_release_id := to_number(wf_engine.GetItemAttrText (itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'ECX_PARAMETER1'));
l_revision_num := to_number(wf_engine.GetItemAttrText (itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'ECX_PARAMETER2'));

    x_progress := 'PO_XML_DELIVERY.setwfUserKey : 02';
    if (l_release_id is not null or l_release_id > 0) then

       x_progress := 'PO_XML_DELIVERY.setwfUserKey : 03';

       select PHA.SEGMENT1, PRAA.REVISION_NUM,
              PRAA.RELEASE_NUM
       into   l_ponum, l_revision_num,  l_release_num
       from   PO_RELEASES_ARCHIVE_ALL praa, po_headers_all pha
       where  PHA.PO_HEADER_ID = PRAA.PO_HEADER_ID and
              praa.po_release_id  = l_release_id and
              praa.revision_num = l_revision_num;

       l_user_key  := l_ponum || '-' || to_char(l_revision_num)
                      || '-' || to_char(l_release_num);

    else --for standard POs.
       x_progress := 'PO_XML_DELIVERY.setwfUserKey : 04';
        select segment1 into l_ponum
        from po_headers_archive_all poh
        where po_header_id= l_document_id and
              revision_num = l_revision_num;

        l_user_key  := l_ponum || '-' || to_char(l_revision_num);
    end if;
    x_progress := 'PO_XML_DELIVERY.setwfUserKey : 05';


    wf_engine.SetItemUserKey(itemtype => itemtype,
                                itemkey  => itemkey,
                                userkey  => l_user_key);
    x_progress := 'PO_XML_DELIVERY.setwfUserKey : 06';

    resultout := 'COMPLETE:T';
    wf_core.context('PO_XML_DELIVERY','setwfUserKey','completed');

exception when others then
   wf_engine.SetItemUserKey(itemtype => itemtype,
                            itemkey  => itemkey,
                            userkey  => 'Cannot set item key');
   wf_core.context('PO_XML_DELIVERY','setwfUserKey',x_progress || ':' || to_char(l_document_id));

   resultout := 'COMPLETE:F';
   -- raise;  if there is an exception can't do much; Do not raise - as it stops the workflow.
end;

procedure initTransaction (p_header_id  in number,
                           p_vendor_id  varchar2,
                           p_vendor_site_id varchar2,
                           transaction_type varchar2 ,
                           transaction_subtype varchar2,
                           p_release_id varchar2, /*parameter1*/
                           p_revision_num  varchar2, /*parameter2*/
                           p_parameter3  varchar2,
                           p_parameter4 varchar2,
                           p_parameter5  VARCHAR2,
                           x_initial_nls_context out NOCOPY VARCHAR2
                          )
is
lang_name   varchar2(100);
begin
  /*  default language be AMERICAN. */
 select nvl(pvsa.language, 'AMERICAN')  into lang_name
   from po_vendor_sites_all pvsa
   where vendor_id = p_vendor_id and
   vendor_site_id = p_vendor_site_id;


   /* Get the user session nls language and store it before setting to supplier language.
   This variable will be used to reset back after the end of xml generation*/

   SELECT fnd_global.NLS_LANGUAGE
   INTO x_initial_nls_context
   from dual;


   FND_GLOBAL.set_nls_context( lang_name);

end;

--Bug 18536351 -- Reset the nls context back to original value

procedure reset_nls_context (p_initial_nls_context VARCHAR2)
is

begin


   FND_GLOBAL.set_nls_context( p_initial_nls_context);

end;


/*
In cXML the deliverto information is provided as
 <DELIVERTO>
QUANTITY: PO_cXML_DELIVERTO_ARCH_V.QUANTITY ||
 NAME: || PO_cXML_DELIVERTO_ARCH_V.REQUESTOR ||
ADDRESS: || PO_cXML_DELIVERTO_ARCH_V.all the address tags
</DELIVERTO>
This is a helper function to concatinate all these values.
*/
Procedure get_cxml_deliverto_info(p_QUANTITY  in number, p_REQUESTOR in varchar2,
                                  p_LOCATION_CODE in varchar2, p_ADDRESS_LINE in varchar2,
                                  p_COUNTRY in varchar2, p_POSTAL_CODE in varchar2,
                                  p_TOWN_OR_CITY in varchar2, p_STATE in varchar2,
                                  p_deliverto out nocopy varchar2) is
BEGIN
  p_deliverto := p_REQUESTOR;
  --p_deliverto := 'QUANTITY: ' || ' ' || to_char( p_QUANTITY) || ' ' || 'NAME' || ' ' || p_REQUESTOR;
  --p_deliverto := p_deliverto || ' ' || 'ADDRESS:' || ' ' || p_LOCATION_CODE
  --                           || ' ' || p_ADDRESS_LINE || ' ' || p_TOWN_OR_CITY
  --                           || ' ' || p_STATE  || ' ' ||p_POSTAL_CODE
  --                           || ' ' || p_COUNTRY;
end;


Procedure get_cxml_header_info (p_tp_id  IN  number,
                                p_tp_site_id  IN number,
                                x_from_domain  OUT nocopy varchar2,
                                x_from_identity OUT nocopy varchar2,
                                x_to_domain    OUT nocopy varchar2,
                                x_to_identity  OUT nocopy varchar2,
                                x_sender_domain OUT nocopy varchar2,
                                x_sender_identity OUT nocopy varchar2,
                                x_sender_sharedsecret OUT nocopy varchar2,
                                x_user_agent  OUT nocopy varchar2,
                                x_deployment_mode OUT nocopy varchar2
                                ) is
begin

   x_user_agent := 'Oracle E-Business Suite Oracle Purchasing 11.5.9';
   x_deployment_mode := 'production';

   --getting destination information.  If not found use default.
   -- Note: Username can be null in case of SMTP.
   begin
     select etd.username, etd.source_tp_location_code
     into x_to_domain, x_to_identity
     from ecx_tp_details etd, ecx_tp_headers eth, ecx_ext_processes eep
     where eth.party_id = p_tp_id and eth.party_site_id = p_tp_site_id
         and etd.tp_header_id = eth.tp_header_id and
         eep.ext_type = 'ORDER' and eep.ext_subtype = 'REQUEST' and
         eep.ext_process_id = etd.ext_process_id;


   exception
     when no_data_found then
       x_to_domain := 'to_domain_default';
       x_to_identity := 'to_identity_default';
     when others then
       raise;    --if we are here, then there is really something wrong.

    end;

    if (x_to_domain is null or x_to_domain = '') then
       x_to_domain := 'to_domain_default';
    end if;

    begin
      --This has an OWF.G dependency.
      ecx_eng_utils.get_tp_pwd(x_sender_sharedsecret);
    exception
      when others then
        x_sender_sharedsecret := 'Shared Secret Not Set';
    end;

    --getting the source (buyer) information.
    fnd_profile.get('PO_CXML_FROM_DOMAIN',x_from_domain);
    if (x_from_domain is null) then
       x_from_domain := 'From domain not yet set';
    end if;
    x_sender_domain := x_from_domain;

    fnd_profile.get('PO_CXML_FROM_IDENTITY',x_from_identity);
    if (x_from_identity is null) then
      x_from_identity := 'From identity not yet set';
    end if;
    x_sender_identity := x_from_identity;

end;

procedure IS_XML_CHN_REQ_SOURCE(itemtype in varchar2,
                                itemkey in varchar2,
                                actid in number,
                                funcmode in varchar2,
                                resultout out NOCOPY varchar2)
IS
l_change_request_group_id  number;
src  varchar2(30);
BEGIN
  l_change_request_group_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                                   itemkey  => itemkey,
                                                 aname    => 'CHANGE_REQUEST_GROUP_ID');

    if (l_change_request_group_id is null) then
      resultout := 'N';
      return;
    end if;

    begin
     select distinct(request_origin) into src
     from po_change_requests
     where change_request_group_id = l_change_request_group_id
     and msg_cont_num is not null;
    exception when others then
      resultout := 'N';
      return;
    end;



    if (src is null or src = 'UI') then
       resultout := 'N';
    else --it can be XML or 9iAS or OTA
       resultout := 'Y';
  end if;
  exception when others then
    resultout := 'N';
END IS_XML_CHN_REQ_SOURCE;

-- For use in OAG Process/Change PO XML generation
-- bug 46115474
-- populate state, region, county tags of xml based on address style.
-- API called from process, change PO OAG xgms.
-- and from po_xml_delivery.get_oag_shipto
PROCEDURE get_hrloc_address(
	p_location_id	in varchar2,
	addrline1		out NOCOPY VARCHAR2,
	addrline2		out NOCOPY VARCHAR2,
	addrline3		out NOCOPY VARCHAR2,
	city			out NOCOPY VARCHAR2,
	country		out NOCOPY VARCHAR2,
	county		out NOCOPY VARCHAR2,
	postalcode		out NOCOPY VARCHAR2,
	region		out NOCOPY VARCHAR2,
	stateprovn		out NOCOPY VARCHAR2)
IS
	hrloc_rec	hr_locations_all%ROWTYPE;
	l_style		varchar2(50);
BEGIN

	SELECT *
	INTO   hrloc_rec
	FROM   hr_locations_all
	WHERE  location_id = p_location_id;

	l_style   := hrloc_rec.style;

	addrline1	:= hrloc_rec.address_line_1;
	addrline2	:= hrloc_rec.address_line_2;
	addrline3	:= hrloc_rec.address_line_3;
	city		:= hrloc_rec.town_or_city;
	postalcode	:= hrloc_rec.postal_code;
	country	:= hrloc_rec.country;
	region	:= hrloc_rec.region_1;
	stateprovn	:= hrloc_rec.region_2;

	IF l_style IN (	'AU_GLB','CA','CA_GLB',
				'ES_GLB','IT_GLB','MX','MX_GLB',
				'MY_GLB','NL','NL_GLB','PT_GLB',
				'TW_GLB','ZA','ZA_GLB') THEN
		stateprovn := hrloc_rec.region_1;
		region     := null;
	ELSIF l_style  IN ('BF_GLB','IE','OPM') THEN
		stateprovn := hrloc_rec.region_2 || ', ' || hrloc_rec.region_3;
	END IF;

	IF l_style  IN ('CA','CA_GLB','MX') THEN
		region := hrloc_rec.region_2;
	END IF;

	IF l_style  IN ('IN','IN_GLB') THEN
		addrline3	:= hrloc_rec.address_line_3 || ', '  || hrloc_rec.loc_information14;
		city		:= hrloc_rec.loc_information15;
		stateprovn	:= hrloc_rec.loc_information16;
	END IF;

	IF l_style IN ('GB','GB_GLB','IE','IE_GLB','US','US_GLB') THEN
		county := hrloc_rec.region_1;
		region := null;
	END IF;
EXCEPTION
	WHEN OTHERS THEN
		null;
END get_hrloc_address;

Procedure set_user_context (  itemtype  in varchar2,
itemkey         in varchar2,
actid           in number,
funcmode        in varchar2,
resultout       out nocopy varchar2) IS

  x_progress    VARCHAR2(100) := '000';
  l_user_id     number;
  l_resp_id     number;
  l_appl_id     number;
  l_cur_user_id number;
  l_cur_resp_id number;
  l_cur_appl_id number;

  --x_org_id number;
BEGIN


   --set the org context
   --x_org_id := PO_WF_UTIL_PKG.GetItemAttrNumber ( itemtype => itemtype,
   --                                  	    itemkey  => itemkey,
   --                                       aname    => 'ORG_ID');
   --if (x_org_id is not null) then
   --  fnd_client__info.set_org_context(to_char(x_org_id));
   --end if;

   x_progress := 'PO_XML_DELIVERY.set_user_context : 001';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,x_progress);
   END IF;


   -- Do nothing in cancel or timeout mode
   --
   if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;  --do not raise the exception, as it would end the wflow.

   end if;


   l_user_id := PO_WF_UTIL_PKG.GetItemAttrNumber ( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'USER_ID');

   l_resp_id := PO_WF_UTIL_PKG.GetItemAttrNumber ( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'RESPONSIBILITY_ID');

   -- bug#5442045, receiving the APPLICATION_ID event parameter in a text item attribute
   -- If the event attribute is defined a number a decimal is being appended which causing a failure in CLN code
   /*
   l_appl_id := PO_WF_UTIL_PKG.GetItemAttrNumber ( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'APPLICATION_ID');*/
   -- bug#5415920
   l_appl_id := to_number(PO_WF_UTIL_PKG.GetItemAttrText(itemtype=>itemtype, itemkey=>itemkey, aname=>'APPLICATION_ID'));

   x_progress := 'PO_XML_DELIVERY.set_user_context : 002';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,x_progress
               || ':' || l_user_id || ':' || l_resp_id || ':' || l_appl_id);
   END IF;

   l_cur_user_id := fnd_global.user_id;
   l_cur_resp_id := fnd_global.resp_id;
   l_cur_appl_id := fnd_global.resp_appl_id;


   x_progress := 'PO_XML_DELIVERY.set_user_context : 003';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,x_progress
               || ':' || l_cur_user_id || ':' || l_cur_resp_id
	       || ':' || l_cur_appl_id);
   END IF;

   if (l_user_id is null or
       ( (l_user_id = l_cur_user_id) and
         (l_resp_id = l_cur_resp_id or (l_resp_id is null and l_cur_resp_id is null)) and
         (l_appl_id = l_cur_appl_id or (l_appl_id is null and l_cur_appl_id is null))
       )
      ) then
     resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_IGNORED';
   else
     FND_GLOBAL.apps_initialize( user_id      => l_user_id,
                              resp_id      => l_resp_id,
                              resp_appl_id => l_appl_id);

     resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';
   end if;

   x_progress :=  'PO_XML_DELIVERY.set_user_context: 004 ' || resultout;
   IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
   END IF;

EXCEPTION
    WHEN OTHERS THEN
    wf_core.context('PO_XML_DELIVERY','set_user_context',x_progress);
    resultout := wf_engine.eng_completed || ':' ||  'SET CONTEXT ERROR';
    return;
END set_user_context;

/*bug#6912518*/
Procedure get_header_shipto_info  (p_po_header_id  IN number,
				   p_po_release_id IN number,
				   x_partner_id  out nocopy number,
				   x_partner_id_x out nocopy varchar2,
				   x_address_line_1 out nocopy varchar2,
				   x_address_line_2 out nocopy varchar2,
				   x_address_line_3 out nocopy varchar2,
				   x_city  out nocopy varchar2,
				   x_country  out nocopy varchar2,
				   x_county  out nocopy varchar2,
				   x_postalcode  out nocopy varchar2,
				   x_region out nocopy varchar2,
				   x_stateprovn  out nocopy varchar2,
				   x_telephone_1 out nocopy varchar2,
				   x_telephone_2 out nocopy varchar2,
				   x_telephone_3 out nocopy varchar2
				   ) is
l_location_id  number;
begin


select ship_to_location_id, org_id
into l_location_id, x_partner_id
from po_headers_all
where po_header_id = p_po_header_id;



begin
       select distinct
	  -- hrl.description,
	   hrl.address_line_1,
	     hrl.address_line_2,
	   hrl.address_line_3,
	   hrl.town_or_city,
	   hrl.postal_code,
	   --ftv.territory_short_name,
	   hrl.country,
	   nvl(decode(hrl.region_1,
		null, hrl.region_2,
		decode(flv1.meaning,null, decode(flv2.meaning,null,flv3.meaning,flv2.lookup_code),flv1.lookup_code))
	    ,hrl.region_2),
	    hrl.TELEPHONE_NUMBER_1,
	    hrl.TELEPHONE_NUMBER_2,
	    hrl.TELEPHONE_NUMBER_3,
	    hrl.ECE_TP_LOCATION_CODE
	into
	  -- l_ship_to_desc,
	   x_address_line_1,
	   x_address_line_2,
	   x_address_line_3,
	   x_city,
	   x_postalcode,
	   x_country,
	   x_stateprovn,
	   x_telephone_1,
	   x_telephone_2,
	   x_telephone_3,
	   x_partner_id_x
     FROM  hr_locations_all hrl,
	   --fnd_territories_vl ftv,
	   fnd_lookup_values_vl flv1,
	   fnd_lookup_values_vl flv2,
	   fnd_lookup_values_vl flv3
	 where
    hrl.region_1 = flv1.lookup_code (+) and hrl.country || '_PROVINCE' = flv1.lookup_type (+)
    and hrl.region_2 = flv2.lookup_code (+) and hrl.country || '_STATE' = flv2.lookup_type (+)
    and hrl.region_1 = flv3.lookup_code (+) and hrl.country || '_COUNTY' = flv3.lookup_type (+)
    --and hrl.country = ftv.territory_code(+)
    and HRL.location_id = l_location_id;

/* Bug 2646120. The country code is not a mandatory one in hr_locations. So the country code may be null.
   Changed the join with ftv to outer join. */

 exception
   when no_data_found then

	   begin
	     select distinct
	   --   hrl.description,
		hzl.address1,
		hzl.address2,
		hzl.address3,
		hzl.city,
		hzl.postal_code,
		hzl.country,
		hzl.state
	     into
	    --  l_ship_to_desc,
		x_address_line_1,
		x_address_line_2,
		x_address_line_3,
		x_city,
		x_postalcode,
		x_country,
		x_stateprovn
	      FROM  hz_locations hzl
	      where  HzL.location_id = l_location_id;
	    /*
	       in case of drop ship no ece_tp_location_code?, telphone nubmers.
	     */
	    exception
	       when no_data_found then
		null;
	    end;
 end;


exception when others then
raise;

end;

Procedure get_cxml_header_shipto_info (p_po_header_id  IN number,
				   p_po_release_id IN number,
				   x_address_line_1 out nocopy varchar2,
				   x_address_line_2 out nocopy varchar2,
				   x_address_line_3 out nocopy varchar2,
				   x_city  out nocopy varchar2,
				   x_country  out nocopy varchar2,
				   x_postalcode  out nocopy varchar2,
				   x_stateprovn  out nocopy varchar2,
				   x_telephone_1 out nocopy varchar2,
                                   			   x_deliverto out nocopy varchar2,
				   x_requestor_email out nocopy varchar2
				   ) is
   x_partner_id  number;
   x_partner_id_x varchar2(35);
   x_county  varchar2(30);
   x_region varchar2(30);
   x_telephone_2 varchar2(60);
   x_telephone_3 varchar2(60);
   l_deliverto varchar2(240);
   l_flag number;

   CURSOR deliverto_cur (headerid number, releaseid number) IS
	   SELECT REQUESTOR,REQUESTOR_EMAIL
	   FROM   PO_CXML_DELIVERTO_ARCH_V
	   WHERE  PO_HEADER_ID = headerid
	   AND    ((PO_RELEASE_ID is null AND releaseid is null)
		   OR PO_RELEASE_ID = releaseid
		  );

 begin
   get_header_shipto_info (p_po_header_id,
			   p_po_release_id,
			   x_partner_id,
			   x_partner_id_x,
			   x_address_line_1,
			   x_address_line_2,
			   x_address_line_3,
			   x_city,
			   x_country,
			   x_county,
			   x_postalcode,
			   x_region,
			   x_stateprovn,
			   x_telephone_1,
			   x_telephone_2,
			   x_telephone_3);

	   x_deliverto := null;
 	   l_flag := 0;
 	   open deliverto_cur(p_po_header_id, p_po_release_id);
 	   loop
 	   fetch deliverto_cur into l_deliverto,x_requestor_email;
 	     exit when deliverto_cur%NOTFOUND;
 	     begin
 	       if (l_flag = 0) then -- the first distribution
 	         x_deliverto := l_deliverto;
 	         l_flag := 1;
 	       elsif (x_deliverto <> l_deliverto
 	              or (x_deliverto is not null and l_deliverto is null)
 	              or (x_deliverto is null and l_deliverto is not null)
 	             ) then
 	         x_deliverto := null;
	         x_requestor_email :=NULL;
 	         exit;
 	       end if;
              end;
	    end loop;
	    close deliverto_cur;

end get_cxml_header_shipto_info;

/*bug#6912518*/
PROCEDURE get_cXML_Header_Shipto_Name(
 	         p_org_name      in varchar2,
 	         x_shipto_name out nocopy varchar2
 	 )
IS
l_num_enterprises NUMBER;
BEGIN

	x_shipto_name := '';

	select count(*)
	into l_num_enterprises
	from hz_parties hp, hz_code_assignments hca
	where  hca.owner_table_id = hp.party_id
	and hca.owner_table_name = 'HZ_PARTIES'
	and hca.class_category = 'POS_PARTICIPANT_TYPE'
	and hca.class_code = 'ENTERPRISE'
	and hca.status= 'A'
	and hp.status= 'A'
	and ( hca.end_date_active > sysdate or hca.end_date_active is null );

	IF l_num_enterprises = 1 THEN
		select hp.party_name
		into x_shipto_name
		from hz_parties hp, hz_code_assignments hca
		where  hca.owner_table_id = hp.party_id
		and hca.owner_table_name = 'HZ_PARTIES'
		and hca.class_category = 'POS_PARTICIPANT_TYPE'
		and hca.class_code = 'ENTERPRISE'
		and hca.status= 'A'
		and hp.status= 'A'
		and ( hca.end_date_active > sysdate or hca.end_date_active is null );

		x_shipto_name := x_shipto_name || ' - ' || p_org_name;
	ELSE
	x_shipto_name := p_org_name;

	END IF;
EXCEPTION
WHEN OTHERS THEN
raise_application_error(-20001, 'Error querying the enterprise name in get_cXML_Header_Shipto_Name', true);
END get_cXML_Header_Shipto_Name;

procedure getSupplierSiteLanguage (p_vendor_id  in varchar2,
                                   p_vendor_site_id in varchar2,
                                   lang_name out nocopy varchar2 )
is

begin
  /*  default language be AMERICAN. */
 select nvl(pvsa.language, 'AMERICAN')  into lang_name
   from po_vendor_sites_all pvsa
   where vendor_id = p_vendor_id and
   vendor_site_id = p_vendor_site_id;
exception when others then
   null;
end getSupplierSiteLanguage;

end PO_XML_DELIVERY;

/
