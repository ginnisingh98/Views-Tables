--------------------------------------------------------
--  DDL for Package Body HR_KI_WF_MISC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_KI_WF_MISC" AS
/* $Header: hrkiwfms.pkb 120.1 2005/08/31 00:12 santosin noship $ */
PROCEDURE RAISE_EVENT
  ( p_party_site_id     IN NUMBER
  , p_party_id          IN NUMBER
  , p_event_name        IN VARCHAR2
                           default 'oracle.apps.per.ki.tradingpartner.initiate'
  , p_party_type        IN VARCHAR2 DEFAULT 'I'
  , p_response_expected IN VARCHAR2 DEFAULT 'T'
  , p_event_key         OUT NOCOPY NUMBER
  )
IS
  l_joining_value_1    VARCHAR2(100) DEFAULT '2';
  l_transaction_type    VARCHAR2(100) DEFAULT 'HR';
  l_transaction_subtype VARCHAR2(100) DEFAULT 'SIO';
  l_parameter_list      wf_parameter_list_t;
  l_event_key           NUMBER;
  l_user_name           VARCHAR2(100);
BEGIN
  --
  -- Obtain a unique eventkey, which is based on a sequence
  --
  SELECT hr_ki_be_s.nextval INTO l_event_key FROM dual;
  --
  -- Set required profile values
  --
  l_user_name := fnd_profile.value('USERNAME');
  --
  -- Now build up the parameter list to pass into the Business Event.
  --
  wf_event.AddParameterToList(
     p_name         => 'USER'
    ,p_value        => l_user_name
    ,p_parameterlist=> l_parameter_list
    );
  wf_event.AddParameterToList(
     p_name         => 'RESPONSE_EXPECTED'
    ,p_value        => p_response_expected
    ,p_parameterlist=> l_parameter_list
    );
  wf_event.AddParameterToList (
     p_name         => 'TRANSACTION_TYPE'
    ,p_value        => l_transaction_type
    ,p_parameterlist=> l_parameter_list
    );
  wf_event.AddParameterToList(
     p_name         => 'TRANSACTION_SUBTYPE'
    ,p_value        => l_transaction_subtype
    ,p_parameterlist=> l_parameter_list
    );
  wf_event.AddParameterToList(
     p_name         => 'PARTY_ID'
    ,p_value        => p_party_id
    ,p_parameterlist=> l_parameter_list
    );
  wf_event.AddParameterToList(
     p_name         => 'PARTY_SITE_ID'
    ,p_value        => p_party_site_id
    ,p_parameterlist=> l_parameter_list
    );
  wf_event.AddParameterToList(
     p_name         => 'PARTY_TYPE'
    ,p_value        => p_party_type
    ,p_parameterlist=> l_parameter_list
    );
  wf_event.AddParameterToList(
     p_name         => 'DOCUMENT_ID'
    ,p_value        => l_joining_value_1
    ,p_parameterlist=> l_parameter_list
    );
  --
  -- Raise the Business Event with the parameter list and sequence
  --
  wf_event.raise(
     p_event_name => p_event_name
    ,p_event_key  => l_event_key
    ,p_parameters => l_parameter_list
    );
  --
  -- Set the OUT parameter
  --
  p_event_key := l_event_key;
  --
EXCEPTION
WHEN OTHERS THEN
  raise;
END ;


PROCEDURE ConfirmBodEnabled(
    itemtype  in VARCHAR2,
    itemkey   in VARCHAR2,
    actid     in NUMBER,
    funcmode  in VARCHAR2,
    result    in out NOCOPY VARCHAR2)
IS

  l_trans_type    ecx_tp_details_v.transaction_type%type;
  l_trans_subtype ecx_tp_details_v.transaction_subtype%type;
  l_party_id      ecx_tp_headers_v.party_id%type;
  l_party_site_id ecx_tp_headers_v.party_site_id%type;

  l_enabled number;
BEGIN
  if (funcmode = 'RUN') then

    l_party_id := wf_engine.GetItemAttrText(    itemtype =>itemtype,
                                                itemkey =>itemkey,
                                                aname =>'PARTY_ID');

    l_party_site_id:=wf_engine.GetItemAttrText( itemtype =>itemtype,
                                                itemkey =>itemkey,
                                                aname =>'PARTY_SITE_ID');

    l_trans_type := wf_engine.GetItemAttrText(  itemtype =>itemtype,
                                                itemkey =>itemkey,
                                                aname =>'TRANSACTION_TYPE');

    l_trans_subtype := wf_engine.GetItemAttrText( itemtype =>itemtype,
                                                  itemkey =>itemkey,
                                                  aname =>'TRANSACTION_SUBTYPE');


     select etd.confirmation
       into l_enabled
       from ecx_tp_headers_v eth
            ,ecx_tp_details_v etd
       where eth.tp_header_id=etd.tp_header_id
         and eth.party_id = l_party_id
         and eth.party_site_id =l_party_site_id
         and etd.transaction_type=l_trans_type
         and etd.transaction_subtype=l_trans_subtype;

     if (l_enabled = 0 or l_enabled= 1) Then
       result := 'F';
     else
      result := 'T';
     end if;

    return;
  end if;
exception
  when others then
    wf_core.context('WF_KI', 'ConfirmBodEnabled', itemtype, itemkey
                   , actid, funcmode);
    raise;
END ConfirmBodEnabled;

PROCEDURE ConfirmBodError(
    itemtype  in VARCHAR2,
    itemkey   in VARCHAR2,
    actid     in NUMBER,
    funcmode  in VARCHAR2,
    result    in out NOCOPY VARCHAR2)
is
 l_statuslvl varchar2(5);
 l_url varchar2(1000);
 unknown_error exception;

begin

    if (funcmode = 'RUN') then

     l_statuslvl := wf_engine.GetItemAttrText (itemtype =>itemtype,
                                               itemkey =>itemkey,
                                               aname =>'PARAMETER6');

     l_url := wf_engine.GetItemAttrText (itemtype =>itemtype,
                                               itemkey =>itemkey,
                                               aname =>'PARAMETER7');
     --insert into rq_table values(l_url,itemkey);

     if l_statuslvl = '00' then
        result :='F';
     elsif l_statuslvl = '99' then
        result :='T';
     else
        raise unknown_error;
     end if;


    end if;

   return;
exception
  when others then
    wf_core.context('WF_KI', 'ConfirmBodError', itemtype, itemkey
                   , actid, funcmode);
    raise;

end ConfirmBodError;

PROCEDURE isResponseRequired(
    itemtype  in VARCHAR2,
    itemkey   in VARCHAR2,
    actid     in NUMBER,
    funcmode  in VARCHAR2,
    result    in out NOCOPY VARCHAR2)
IS
  l_response varchar2(100);
begin

    if (funcmode = 'RUN') then
      -- Set the flag RECEIVED_XML_FLAG to F.
      -- This will get set to T once the XML is
      -- received (should there be any to receive)
      wf_engine.SetItemAttrText
               (itemtype => itemtype
               ,itemkey => itemkey
               ,aname =>'RECEIVED_XML_FLAG'
               ,avalue=>'F'
                );
      --
      result :=NVL(wf_engine.GetItemAttrText
               (itemtype => itemtype
               ,itemkey => itemkey
               ,aname =>'RESPONSE_EXPECTED'),'F');
      --
    end if;
    --
exception
  when others then
    wf_core.context('WF_KI', 'IsResponseRequired', itemtype, itemkey
                   , actid, funcmode);
    raise;
    --
End isResponseRequired;

PROCEDURE AlterReceivedFlag(
    itemtype  in VARCHAR2,
    itemkey   in VARCHAR2,
    actid     in NUMBER,
    funcmode  in VARCHAR2,
    result    in out NOCOPY VARCHAR2)
is
  --
begin

    if (funcmode = 'RUN') then

      wf_engine.SetItemAttrText
               (itemtype => itemtype
               ,itemkey => itemkey
               ,aname =>'RECEIVED_XML_FLAG'
               ,avalue=>'T'
                );
   end if;
   result := 'COMPLETE';

exception
  when others then
    wf_core.context('WF_KI', 'AlterReceivedFlag', itemtype, itemkey
                   , actid, funcmode);
    raise;
    --
END AlterReceivedFlag;

FUNCTION HasResponseArrived(
  itemkey  in VARCHAR2
 ) return BOOLEAN
 is
 l_itemtype varchar2(10) := 'HR_KI';
 l_result varchar2(10);
 begin
 -- get the value of the item_attribute RECEIVED_XML_FLAG and return true
 -- if RECEIVED_XML_FLAG = 'T'

 l_result :=  wf_engine.GetItemAttrText
                  (itemtype => l_itemtype
                  ,itemkey => itemkey
                  ,aname =>'RECEIVED_XML_FLAG');
if l_result = 'T' then
 return TRUE;
else
 return FALSE;
end if;

end HasResponseArrived;
--
PROCEDURE ContinueWorkflow(
 itemkey in VARCHAR2,
 another_response_expected in BOOLEAN DEFAULT FALSE)
 is
 l_itemtype varchar2(10) := 'HR_KI';
 l_response_expected varchar2(5);
 l_event_name varchar2(50) := 'oracle.apps.per.ki.tradingpartner.continue';
 begin
 -- set the value of the item_attribute RESPONSE_EXPECTED and raise the
 -- continue event
 if another_response_expected then
  l_response_expected := 'T';
 else
  l_response_expected := 'F';
 end if;

 wf_engine.SetItemAttrText
               (itemtype => l_itemtype
               ,itemkey => itemkey
               ,aname =>'RESPONSE_EXPECTED'
               ,avalue=> l_response_expected
                );

wf_event.raise(
     p_event_name => l_event_name
    ,p_event_key  => itemkey
   );

end ContinueWorkFlow;
END hr_ki_wf_misc;

/
