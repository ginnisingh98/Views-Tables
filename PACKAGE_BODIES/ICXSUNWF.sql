--------------------------------------------------------
--  DDL for Package Body ICXSUNWF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICXSUNWF" as
--$Header: ICXWFSNB.pls 115.4 2001/01/03 16:10:52 pkm ship      $
--

procedure Add_Domain(itemtype        in varchar2,
                     itemkey                in varchar2,
                     actid                  in number,
                     funmode                in varchar2,
                     result                 out varchar2 ) is

l_user_name     varchar2(100);
l_supplier_id   number;
l_email_address varchar2(240);
l_new_user_name varchar2(100);

begin

if funmode = 'RUN' then
        --
	l_user_name := wf_engine.GetItemAttrText(itemtype => itemtype,
						 itemkey => itemkey,
					         aname => 'ICX_USER_NAME');
        --
        l_supplier_id := wf_engine.GetItemAttrNumber(itemtype  => itemtype,
                                                     itemkey   => itemkey,
                                                     aname  => 'SUPPLIER_ID');
        --
        l_email_address := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                     itemkey   => itemkey,
                                                     aname  => 'CONTACT_EMAIL_ADDRESS');
        --
	icx_supp_custom.setDomain(p_username => l_user_name,
				  p_supplier_id => l_supplier_id,
				  p_email_address => l_email_address,
			          p_new_username => l_new_user_name);
	--
	wf_engine.SetItemAttrText(itemtype        => itemtype,
                                  itemkey         => itemkey,
                                  aname           => 'ICX_USER_NAME',
                                  avalue          => l_new_user_name);

elsif ( funmode = 'CANCEL' ) then
     result := 'COMPLETE';
end if;
     result := '';

exception
   when others then
      wf_core.context('icxsunwf','Add_Domain',itemtype,itemkey);
      raise;
end;

procedure Verify_Name(itemtype        in varchar2,
                      itemkey                in varchar2,
                      actid                  in number,
                      funmode                in varchar2,
                      result                 out varchar2 ) is


   l_user_name     varchar2(500);
   l_count         number;
   l_accept_status varchar2(1);

begin

if funmode = 'RUN' then
        --
	l_user_name := wf_engine.GetItemAttrText(itemtype => itemtype,
						 itemkey => itemkey,
					         aname => 'ICX_USER_NAME');
        --
   if length(l_user_name) <= 30
   then
       -- check if already exists in wf_roles
       select count(*)
       into   l_count
       from   wf_roles
       where  name = l_user_name;

       if l_count > 0 then

          l_accept_status := 'D';
          result := 'COMPLETE:FAILED';
       else

          l_accept_status := 'Y';
          result := 'COMPLETE:PASSED';
       end if;
   else

	l_accept_status := 'L';
        result := 'COMPLETE:FAILED';
   end if;

   --
   wf_engine.SetItemAttrText  (    itemtype        => itemtype,
				   itemkey 	   => itemkey,
				   aname  	   => 'ICX_ACCEPT_STATUS',
				   avalue 	   => l_accept_status);

elsif ( funmode = 'CANCEL' ) then
     result := 'COMPLETE';
else
     result := '';
end if;

exception
   when others then
      wf_core.context('icxsunwf','Verify_Name',itemtype,itemkey);
      raise;
end;

procedure StartNameProcess(p_username           in varchar2,
			   p_supplier_id        in number,
			   p_email_address      in varchar2,
			   p_itemkey	        in varchar2) is
--
l_ItemType 		varchar2(100) := 'ICXSUNAM';
--
begin
	wf_engine.threshold := 9999999.99;
	--
	wf_engine.createProcess( ItemType => l_ItemType,
				 ItemKey  => p_ItemKey,
				 process  => 'ICXSUNAP' );
	--
	--
        wf_engine.SetItemAttrText (itemtype => l_ItemType,
                                   itemkey => p_itemkey,
                                   aname => 'ICX_USER_NAME',
                                   avalue => upper(p_username));
        --
        --
	wf_engine.SetItemAttrNumber (itemtype	=> l_ItemType,
			      	     itemkey  	=> p_itemkey,
  		 	      	     aname 	=> 'SUPPLIER_ID',
			      	     avalue	=> p_supplier_id);
        --
        --
        wf_engine.SetItemAttrText (itemtype => l_ItemType,
				   itemkey => p_itemkey,
				   aname => 'CONTACT_EMAIL_ADDRESS',
				   avalue => p_email_address);
        --
        --
	wf_engine.StartProcess ( ItemType => l_ItemType,
				 ItemKey  => p_ItemKey );
	--
	--
exception
   when others then
      wf_core.context('icxsunwf','StartNameProcess',l_itemtype,p_itemkey);
      raise;
end StartNameProcess;
--
--
end icxsunwf;

/
