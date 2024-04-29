--------------------------------------------------------
--  DDL for Package Body ECX_WF_ERRORS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECX_WF_ERRORS" as
-- $Header: ECXWERRB.pls 120.8 2008/05/21 05:50:24 deannava ship $

ecx_programunit_error	exception;

PROCEDURE CheckError ( 	p_package in varchar2,
			p_programunit in varchar2,
			p_ret_code in pls_integer,
			p_errmsg in varchar2)

is
begin
  if p_ret_code <> 0
  then
    raise ecx_programunit_error;
  end if;
exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context(p_package, p_programunit,
		    p_ret_code, p_errmsg);
    raise;
end checkerror;

procedure GetInErrorDetails(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
is
transaction_type	varchar2(200);
transaction_subtype	varchar2(200);
party_site_id		varchar2(256);
party_id		varchar2(256);
internal_control_number number;
message_id		varchar2(200);
return_code		pls_integer;
error_msg		varchar2(2000);
error_type		pls_integer;
i_org_id                number(15);
tp_header_id            number(15);
i_admin_email           varchar2(2000);
i_return_code           pls_integer;
i_error_msg             varchar2(2000);
party_type              varchar2(200); --Bug #2183619
error_id                number(15);
error_params		varchar2(2000);

error_item_type		varchar2(200);
error_item_key		varchar2(200);
i_event			wf_event_t;
begin


  -- RUN mode - normal process execution

  if (funcmode = 'RUN') then

	i_event  := Wf_Engine.GetItemAttrEvent(itemtype, itemkey, name => 'EVENT_MESSAGE');

	/** get the Values from the EventMessage **/
	return_code := i_event.getValueForParameter('ECX_RETURN_CODE');
	error_msg := i_event.getValueForParameter('ECX_ERROR_MSG');
	error_type := i_event.getValueForParameter('ECX_ERROR_TYPE');
	transaction_type := i_event.getValueForParameter('ECX_TRANSACTION_TYPE');
	transaction_subtype := i_event.getValueForParameter('ECX_TRANSACTION_SUBTYPE');
	tp_header_id := i_event.getValueForParameter('ECX_TP_HEADER_ID');
        -- Get the party type , change in bug #2183619
        party_type := i_event.getValueForParameter('ECX_PARTY_TYPE');
        error_id := i_event.getValueForParameter('ECX_ERROR_ID');
        error_params := i_event.getValueForParameter('ECX_ERROR_PARAMS');
         ecx_trading_partner_pvt.get_tp_info
          (
            p_tp_header_id     => tp_header_id,
            p_party_id         => party_id,
            p_party_site_id    => party_site_id,
            p_org_id           => i_org_id,
            p_admin_email      => i_admin_email,
            retcode            => i_return_code,
            retmsg             => i_error_msg
          );

        /** Getting translated message based on message and param values **/
	error_msg := ecx_debug.getMessage(error_msg, error_params);

      	/** Now we need to set these values into our Error Process
      	*** We could just continually reference back to the source of
      	*** of our errors, but safer to get our own copy.
      	**/

      	wf_engine.SetItemAttrText ( 	itemtype => itemtype,
	      				itemkey  => itemkey,
  	      				aname    => 'ECX_RETURN_CODE',
					avalue   =>  return_code);

      	wf_engine.SetItemAttrText ( 	itemtype => itemtype,
	      				itemkey  => itemkey,
  	      				aname    => 'ECX_ERROR_MSG',
					avalue   =>  error_msg);

      	wf_engine.SetItemAttrText ( 	itemtype => itemtype,
	      				itemkey  => itemkey,
  	      				aname    => 'ECX_ERROR_TYPE',
					avalue   => error_type);

      	wf_engine.SetItemAttrText ( 	itemtype => itemtype,
	      				itemkey  => itemkey,
  	      				aname    => 'ECX_TRANSACTION_TYPE',
					avalue   => transaction_type);

      	wf_engine.SetItemAttrText ( 	itemtype => itemtype,
	      				itemkey  => itemkey,
  	      				aname    => 'ECX_TRANSACTION_SUBTYPE',
					avalue   =>  transaction_subtype);

      	wf_engine.SetItemAttrText ( 	itemtype => itemtype,
	      				itemkey  => itemkey,
  	      				aname    => 'ECX_PARTY_SITE_ID',
					avalue   =>  party_site_id);

        wf_engine.SetItemAttrText (     itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'ECX_PARTY_ID',
                                        avalue   =>  party_id);

        wf_engine.SetItemAttrText (     itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'ECX_PARTY_ADMIN_EMAIL',
                                        avalue   =>  i_admin_email);
        /* Bug #2183619 */
        begin
            wf_engine.SetItemAttrText ( itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'ECX_PARTY_TYPE',
                                        avalue   =>  party_type);
        exception
            when others then
              if(wf_core.error_name = 'WFENG_ITEM_ATTR') then
                 wf_engine.addItemAttr(itemtype, itemkey, 'ECX_PARTY_TYPE');
                 wf_engine.SetItemAttrText ( itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'ECX_PARTY_TYPE',
                                             avalue   =>  party_type);
              else
                raise;
              end if;
        end;

        /* Bug 2260180 */
        wf_engine.SetItemAttrText (     itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'ECX_TP_HEADER_ID',
                                        avalue   => tp_header_id);

    -- example completion
    result  := 'COMPLETE';
    return;
  end if;



  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.

  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;



  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null

  result := '';
  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('ECX_WF_ERRORS', 'GETINERRORDETAILS',
		    itemtype, itemkey, to_char(actid), funcmode);
    raise;
end GetInErrorDetails;

procedure GetOutErrorDetails(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
is
transaction_type	varchar2(200);
transaction_subtype	varchar2(200);
party_site_id		varchar2(256);
document_id		varchar2(200);
party_id		varchar2(200);
return_code		pls_integer;
error_msg		varchar2(2000);
error_type		pls_integer;

error_item_type		varchar2(200);
error_item_key		varchar2(200);
error_activity_id       number;
party_type              varchar2(200); --Bug #2183619
begin


  -- RUN mode - normal process execution

  if (funcmode = 'RUN') then

    /** If we got here from a workflow process, we need to get a bunch
    *** of item attributes from the errored workflow process so that we
    *** can call ECX APIs from out Workflow Error Process
    **/

     /** Get the Error Item Type and Error Item Key **/

      error_item_type := wf_engine.GetItemAttrText(
				 	itemtype => itemtype,
			    		itemkey	=> itemkey,
			    		aname	=> 'ERROR_ITEM_TYPE' );

      error_item_key := wf_engine.GetItemAttrText(
				 	itemtype => itemtype,
			    		itemkey	=> itemkey,
			    		aname	=> 'ERROR_ITEM_KEY' );

      error_activity_id := wf_engine.GetItemAttrNumber(
                                        itemtype => itemtype,
                                        itemkey => itemkey,
                                        aname   => 'ERROR_ACTIVITY_ID' );

      transaction_type := wf_engine.GetActivityAttrText(
                                       itemtype,
                                       itemkey,
                                       error_activity_id,
                                       'ECX_TRANSACTION_TYPE',
                                       true);

      transaction_subtype := wf_engine.GetActivityAttrText(
                                       itemtype,
                                       itemkey,
                                       error_activity_id,
                                       'ECX_TRANSACTION_SUBTYPE',
                                       true);


      -- Are we sure all of these item attributes will exist
      -- If some are optional, pass ignore_notfound


      party_id := wf_engine.GetItemAttrText(
				 	itemtype => error_item_type,
			    		itemkey	=> error_item_key,
			    		aname	=> 'ECX_PARTY_ID',
                                        ignore_notfound=> true );

      party_site_id := wf_engine.GetItemAttrText(
				 	itemtype => error_item_type,
			    		itemkey	=> error_item_key,
			    		aname	=> 'ECX_PARTY_SITE_ID',
                                        ignore_notfound=> true );

      document_id := wf_engine.GetItemAttrText(
				 	itemtype => error_item_type,
			    		itemkey	=> error_item_key,
 		    			aname	=> 'ECX_DOCUMENT_ID' ,
					ignore_notfound=> true);

      /* start of chnages for bug #2183619 */
      party_type 		:= wf_engine.GetItemAttrText(
				 	itemtype => error_item_type,
			    		itemkey	=> error_item_key,
 		    			aname	=> 'ECX_PARTY_TYPE' ,
					ignore_notfound=> true);
      /* End of changes for bug #2183619*/


      if transaction_type is null then
          transaction_type := wf_engine.GetItemAttrText(
			 		itemtype => error_item_type,
		    			itemkey	=> error_item_key,
			    		aname	=> 'ECX_TRANSACTION_TYPE' ,
					ignore_notfound=> true);
      end if;

      if transaction_subtype is null then
          transaction_subtype := wf_engine.GetItemAttrText(
				 	itemtype => error_item_type,
			    		itemkey	=> error_item_key,
			    		aname	=> 'ECX_TRANSACTION_SUBTYPE' ,
					ignore_notfound=> true);
      end if;

	/** This won't be set because of the rollback **/

	/**
      error_type := wf_engine.GetItemAttrText(
				 	itemtype => error_item_type,
			    		itemkey	=> error_item_key,
			    		aname	=> 'ECX_ERROR_TYPE' );

      error_msg := wf_engine.GetItemAttrText(
				 	itemtype => error_item_type,
			    		itemkey	=> error_item_key,
			    		aname	=> 'ECX_ERROR_MSG' );

      return_code := wf_engine.GetItemAttrText(
				 	itemtype => error_item_type,
			    		itemkey	=> error_item_key,
			    		aname	=> 'ECX_RETURN_CODE' );
		**/


      /** Now we need to set these values into our Error Process
      *** We could just continually reference back to the source of
      *** of our errors, but safer to get our own copy.
      **/

      wf_engine.SetItemAttrText ( 	itemtype => itemtype,
	      				itemkey  => itemkey,
  	      				aname    => 'ECX_PARTY_ID',
					avalue   =>  party_id);

      wf_engine.SetItemAttrText ( 	itemtype => itemtype,
	      				itemkey  => itemkey,
  	      				aname    => 'ECX_PARTY_SITE_ID',
					avalue   => party_site_id);

      wf_engine.SetItemAttrText ( 	itemtype => itemtype,
	      				itemkey  => itemkey,
  	      				aname    => 'ECX_DOCUMENT_ID',
					avalue   => document_id);

      wf_engine.SetItemAttrText ( 	itemtype => itemtype,
	      				itemkey  => itemkey,
  	      				aname    => 'ECX_TRANSACTION_TYPE',
					avalue   =>  transaction_type);

      wf_engine.SetItemAttrText ( 	itemtype => itemtype,
	      				itemkey  => itemkey,
  	      				aname    => 'ECX_TRANSACTION_SUBTYPE',
					avalue   =>  transaction_subtype);

      /* Start of changes for bug #2183619 */
      begin
            wf_engine.SetItemAttrText ( itemtype => itemtype,
	      				itemkey  => itemkey,
  	      				aname    => 'ECX_PARTY_TYPE',
					avalue   =>  party_type);
      exception
            when others then
              if(wf_core.error_name = 'WFENG_ITEM_ATTR') then
                 wf_engine.addItemAttr(itemtype, itemkey, 'ECX_PARTY_TYPE');
                 wf_engine.SetItemAttrText ( itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'ECX_PARTY_TYPE',
                                             avalue   =>  party_type);
              else
                raise;
              end if;
      end;
      /* End of changes for bug #2183619*/

      error_msg := ecx_debug.getMessage(ecx_utils.i_errbuf, ecx_utils.i_errparams);

      /* Using g_rec_tp_id here as inbound and passthroughs
         will use the GetInErrorDetails
         which gets tp_header_id from the error event. */
      wf_engine.SetItemAttrText (      itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'ECX_TP_HEADER_ID',
                                        avalue   =>  ecx_utils.g_rec_tp_id);

      wf_engine.SetItemAttrText ( 	itemtype => itemtype,
	      				itemkey  => itemkey,
  	      				aname    => 'ECX_RETURN_CODE',
					avalue   =>  ecx_utils.i_ret_code);

      wf_engine.SetItemAttrText ( 	itemtype => itemtype,
	      				itemkey  => itemkey,
  	      				aname    => 'ECX_ERROR_MSG',
					avalue   =>  error_msg);

      wf_engine.SetItemAttrText ( 	itemtype => itemtype,
	      				itemkey  => itemkey,
  	      				aname    => 'ECX_ERROR_TYPE',
					avalue   =>  ecx_utils.error_type);


    -- example completion
    result  := 'COMPLETE';
    return;
  end if;



  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.

  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;



  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null

  result := '';
  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('ECX_WF_ERRORS', 'GETOUTERRORDETAILS',
		    itemtype, itemkey, to_char(actid), funcmode);
    raise;
end GetOutErrorDetails;

procedure GETTPROLE(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
is
transaction_type	varchar2(200);
transaction_subtype	varchar2(200);
party_site_id		varchar2(256);
party_id		varchar2(256);
rname			varchar2(200);
email_address		varchar2(2000);
display_name		varchar2(200);
error_item_type		varchar2(200);
error_item_key		varchar2(200);
ret_code		varchar2(200);
error_msg		varchar2(200);

i_notification_preference varchar2(200);
i_language                varchar2(200);
i_territory             varchar2(200);
i_wf_email_address        varchar2(200);
i_wf_display_name        varchar2(200);

i_email_addr        varchar2(2000);
i_party_id          varchar2(2000);
i_party_site_id     varchar2(2000);
party_type          varchar2(200); --bug #2183619
tp_header_id        varchar2(200);

l_params            wf_parameter_list_t;
begin


  -- RUN mode - normal process execution

  if (funcmode = 'RUN') then

    -- your run code goes here


 /** Get the Transaction Type , Transaction Subtype, Party_id, Party_site_id from Item Attributes ***/

    transaction_type := wf_engine.GetItemAttrText(
                                        itemtype => itemtype,
                                        itemkey =>  itemkey,
                                        aname   => 'ECX_TRANSACTION_TYPE' );

    transaction_subtype := wf_engine.GetItemAttrText(
                                        itemtype => itemtype,
                                        itemkey =>  itemkey,
                                        aname   => 'ECX_TRANSACTION_SUBTYPE' );

    party_id := wf_engine.GetItemAttrText(
                                        itemtype => itemtype,
                                        itemkey =>  itemkey,
                                        aname   => 'ECX_PARTY_ID' );

    party_site_id := wf_engine.GetItemAttrText(
                                        itemtype => itemtype,
                                        itemkey =>  itemkey,
                                        aname   => 'ECX_PARTY_SITE_ID' );

    email_address := wf_engine.GetItemAttrText(
                                        itemtype => itemtype,
                                        itemkey =>  itemkey,
                                        aname   => 'ECX_PARTY_ADMIN_EMAIL',
                                        ignore_notfound => true);
    /* Start of changes for bug #2183619 */
    party_type := wf_engine.GetItemAttrText(
                                        itemtype => itemtype,
                                        itemkey =>  itemkey,
                                        aname   => 'ECX_PARTY_TYPE',
                                        ignore_notfound => true);
    /* End of changes for bug #2183619 */

    tp_header_id := wf_engine.GetItemAttrText(
                                        itemtype => itemtype,
                                        itemkey =>  itemkey,
                                        aname   => 'ECX_TP_HEADER_ID',
                                        ignore_notfound => true);

    if (tp_header_id is null) then
       result := 'COMPLETE:F';
       return;
    end if;

    wf_directory.GetRoleName
    (
      p_orig_system=>'ECX_TP:'|| tp_header_id,
      p_orig_system_id=>tp_header_id,
      p_name=>rname,
      p_display_name=>display_name
    );

    /** Even though the tp_header form is populating role with email
        keeping the following for backward compatibility in case **/

    if rname is null then

      rname := 'ECX_TP-'|| tp_header_id;


      if (email_address is null) then
         ecx_trading_partner_pvt.get_tp_company_email(
			l_transaction_type      =>transaction_type,
                        l_transaction_subtype   =>transaction_subtype,
			l_party_site_id		=>party_site_id,
                        l_party_type            =>party_type, --Bug #2183619
 			l_email_addr 		=>email_address,
			retcode 		=>ret_code,
			errmsg 			=>error_msg);
      end if;

         if  (ret_code > 0) then
           result := 'COMPLETE:F';
           return;
         end if;

         l_params := wf_parameter_list_t();

         wf_event.addParameterToList(
                               p_name          => 'USER_NAME',
                               p_value         => rname,
                               p_parameterlist => l_params);

         wf_event.addParameterToList(
                               p_name          => 'DisplayName',
                               p_value         => rname,
                               p_parameterlist => l_params);

         wf_event.addParameterToList(
                               p_name          => 'mail',
                               p_value         => email_address,
                               p_parameterlist => l_params);

         wf_local_synch.propagate_role(
            p_orig_system => 'ECX_TP:' || tp_header_id,
            p_orig_system_id => tp_header_id,
            p_attributes => l_params,
            p_start_date => sysdate,
            p_expiration_date => sysdate +50000
         );

    else

       i_party_id := party_id;
       i_party_site_id := party_site_id;

       -- get the email address from tp headers
       begin
          select  company_admin_email
          into    i_email_addr
          from    ecx_tp_headers eth
          where   eth.party_id = i_party_id
          and     eth.party_site_id = i_party_site_id
          and     eth.party_type = nvl(party_type, eth.party_type);
       exception
          when too_many_rows then
            result := 'COMPLETE:F';
            return;
          when others then
            result  := 'COMPLETE:F';
            return;
            raise;
       end;

      wf_directory.getRoleInfo(
                      role => rname,
		      display_name => i_wf_display_name,
                      email_address => i_wf_email_address,
		      notification_preference => i_notification_preference,
                      language => i_language,
                      territory => i_territory
	       );


       if ((i_wf_email_address is null) OR
            (i_wf_email_address <> i_email_addr))
       then

         l_params := wf_parameter_list_t();

         wf_event.addParameterToList(
                               p_name          => 'UpdateOnly',
                               p_value         => 'TRUE',
                               p_parameterlist => l_params);

         wf_event.addParameterToList(
                               p_name          => 'mail',
                               p_value         => i_email_addr,
                               p_parameterlist => l_params);

         wf_event.addParameterToList(
                               p_name          => 'USER_NAME',
                               p_value         => rname,
                               p_parameterlist => l_params);

         wf_local_synch.propagate_role(
            p_orig_system => 'ECX_TP:' || tp_header_id,
            p_orig_system_id => tp_header_id,
            p_attributes => l_params,
            p_start_date => sysdate,
            p_expiration_date => sysdate +50000
         );

       end if;
    end if;

   wf_engine.SetItemAttrText ( 	itemtype => itemtype,
	      			itemkey  => itemkey,
  	      			aname    => 'ECX_TP_ROLE',
				avalue   =>  rname);

   -- example completion
    result  := 'COMPLETE:T';
    return;
  end if;


  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.

  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE:T';
    return;
  end if;


  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null

  result := 'COMPLETE:T';
  return;

exception
  when invalid_number then
    result := 'COMPLETE:F';
    return;
  when value_error then
    result := 'COMPLETE:F';
    return;
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('ECX_WF_ERRORS', 'GETTPROLE',
		    itemtype, itemkey, to_char(actid),
	    funcmode, ret_code, error_msg);
    raise;
end getTpRole;

Procedure GETSAROLE(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
is

rname			varchar2(200);
email_address		varchar2(2000);
display_name		varchar2(200);
ret_code		varchar2(200);
errmsg			varchar2(200);

i_notification_preference varchar2(200);
i_language                varchar2(200);
i_territory             varchar2(200);
i_wf_email_address        varchar2(200);
i_wf_display_name        varchar2(200);
i_email_addr        varchar2(200);
l_params                 wf_parameter_list_t;
Begin


 -- RUN mode - normal process execution


  if (funcmode = 'RUN') then

    -- your run code goes here

    /** Check First if the Sysadmin Role Exists**/

    wf_directory.GetRoleName(p_orig_system=>'ECX_SA_ROLE',
                         p_orig_system_id=>0,
                         p_name=>rname,
			 p_display_name=>display_name);

    if rname is null then

      rname := 'ECX_SA';
      display_name := 'ECX System Administrator';

   /**Get sys admin email from ecx_trading_partner_pvt.get_sysadmin_email api**/
      ecx_trading_partner_pvt.get_sysadmin_email(
				email_address 	=>email_address,
				retcode		=>ret_code,
				errmsg		=>errmsg);

      l_params := wf_parameter_list_t();

      wf_event.addParameterToList(
                               p_name          => 'USER_NAME',
                               p_value         => rname,
                               p_parameterlist => l_params);

      wf_event.addParameterToList(
                               p_name          => 'DisplayName',
                               p_value         => display_name,
                               p_parameterlist => l_params);

      wf_event.addParameterToList(
                               p_name          => 'mail',
                               p_value         => email_address,
                               p_parameterlist => l_params);

      wf_local_synch.propagate_role(
            p_orig_system => 'ECX_SA_ROLE',
            p_orig_system_id => 0,
            p_attributes => l_params,
            p_start_date => sysdate,
            p_expiration_date => sysdate +50000
         );

    else
    /**Get sys admin email from ecx_trading_partner_pvt.get_sysadmin_email api**/
       ecx_trading_partner_pvt.get_sysadmin_email(
				email_address 	=>i_email_addr,
				retcode		=>ret_code,
				errmsg		=>errmsg);

       -- Should check the return code
       if (ret_code > 0) then
          result := 'COMPLETE:F';
          return;
       elsif (i_email_addr is null) then
          result := 'COMPLETE:F';
          return;
       end if;

       wf_directory.getRoleInfo(
                               role => rname,
			       display_name => i_wf_display_name,
                               email_address => i_wf_email_address,
			       notification_preference => i_notification_preference,
                               language => i_language,
                               territory => i_territory
			       );

       if ((i_wf_email_address is null) OR
           (i_wf_email_address <> i_email_addr))
       then

           l_params := wf_parameter_list_t();

           wf_event.addParameterToList(
                               p_name          => 'UpdateOnly',
                               p_value         => 'TRUE',
                               p_parameterlist => l_params);

           wf_event.addParameterToList(
                               p_name          => 'mail',
                               p_value         => i_email_addr,
                               p_parameterlist => l_params);

           wf_event.addParameterToList(
                               p_name          => 'USER_NAME',
                               p_value         => rname,
                               p_parameterlist => l_params);


           wf_local_synch.propagate_role(
                 p_orig_system => 'ECX_SA_ROLE',
                 p_orig_system_id => 0,
                 p_attributes => l_params,
                 p_start_date => sysdate,
                 p_expiration_date => sysdate +50000
              );


       end if;
    end if;

    wf_engine.SetItemAttrText ( 	itemtype => itemtype,
	      				itemkey  => itemkey,
  	      				aname    => 'ECX_SA_ROLE',
					avalue   =>  rname);

   -- example completion
    result  := 'COMPLETE:T';
    return;
  end if;



  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.

  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;


  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null

  result := '';

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('ECX_WF_ERRORS', 'GETSAROLE',
		    itemtype, itemkey, to_char(actid),
	    funcmode, ret_code, errmsg);
    raise;
End GETSAROLE;
procedure GetErrorRetryCount(itemtype in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                result in      out NOCOPY varchar2) IS
  i_retry_count   varchar2(100);
  ttype varchar2(100);
  att1 varchar2(100);
  i_item_type  varchar2(30);
  i_item_key  varchar2(30);
  i_prof_error_count NUMBER;

  l_params                 wf_parameter_list_t;
  i_event wf_event_t;

BEGIN

  IF (funcmode='RUN') THEN
  i_event  := Wf_Engine.GetItemAttrEvent(itemtype, itemkey, name => 'EVENT_MESSAGE');
   i_retry_count :=wf_engine.GetItemAttrText (   itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => 'ECX_ATTRIBUTE2');
      i_prof_error_count:=fnd_profile.value_specific(name=>'ECX_MAX_RETRY',
                                 user_id=>0,
                                 responsibility_id=>20420,
                                 application_id=>174,
                                 org_id=>null,
                                 server_id=>null);

  IF (to_number(i_retry_count) < i_prof_error_count) then
   i_retry_count :=i_retry_count+1;
   i_event.addParameterToList('ECX_ATTRIBUTE2',i_retry_count);
   wf_engine.SetItemAttrEvent(itemtype,itemkey,'EVENT_MESSAGE',i_event);
   result:='COMPLETE:'||'Y'; -- retry
     return;

   ELSE
     result:='COMPLETE:'||'N';
     return;

   END IF;

  END IF; --run mode

EXCEPTION
 when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('ECX_WF_ERRORS', 'GetErrorRetryCount',
		    itemtype, itemkey, to_char(actid), funcmode);
    raise;
END GetErrorRetryCount;

procedure GetTimeoutValue (itemtype in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                result  in   out NOCOPY varchar2) IS
i_time_out NUMBER ;
BEGIN
i_time_out :=fnd_profile.value_specific(name=>'ECX_NOTIFY_TIMEOUT',
                                 user_id=>0,
                                 responsibility_id=>20420,
                                 application_id=>174,
                                 org_id=>null,
                                 server_id=>null);


wf_engine.SetItemAttrText ( 	itemtype => itemtype,
	      			itemkey  => itemkey,
  	      			aname    => 'ERROR_TIMEOUT',
				avalue   =>  i_time_out);
result:='COMPLETE';
return;

EXCEPTION
when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('ECX_WF_ERRORS', 'GetTimeoutValue',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

END GetTimeoutValue;

Procedure GETTOROLE(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
is

rname			varchar2(200);
email_address		varchar2(2000);
display_name		varchar2(200);
ret_code		varchar2(200);
errmsg			varchar2(200);
i_notification_preference varchar2(200);
i_language                varchar2(200);
i_territory             varchar2(200);
i_wf_email_address        varchar2(200);
i_wf_display_name        varchar2(200);
i_email_addr        varchar2(200);
l_params                 wf_parameter_list_t;
l_transaction_type    ecx_transactions.transaction_type%type;
l_transaction_subtype ecx_transactions.transaction_subtype%type;
l_party_type          ecx_transactions.party_type%type;
i_transaction_id      ecx_transactions.transaction_id%type;
l_standard_code      ecx_standards.standard_code%type;
l_standard_type      ecx_standards.standard_type%type;
l_party_site_id       ecx_tp_details.source_tp_location_code%type;
Begin


 -- RUN mode - normal process execution


  if (funcmode = 'RUN') then

    -- your run code goes here
    --get transaction_type,transaction_subtype,party_type from item_attributes

     l_transaction_type :=wf_engine.GetItemAttrText (   itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => 'ECX_TRANSACTION_TYPE');

     l_transaction_subtype :=wf_engine.GetItemAttrText (   itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => 'ECX_TRANSACTION_SUBTYPE');
     l_party_type := wf_engine.GetItemAttrText(
                                        itemtype => itemtype,
                                        itemkey =>  itemkey,
                                        aname   => 'ECX_PARTY_TYPE',
                                        ignore_notfound => true);

    l_standard_code    := wf_engine.GetItemAttrText (   itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => 'ECX_MESSAGE_STANDARD',
				   ignore_notfound => true);
    l_standard_type    := wf_engine.GetItemAttrText (   itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => 'ECX_MESSAGE_TYPE',
				   ignore_notfound => true);
    l_party_site_id :=  wf_engine.GetItemAttrText(
                                        itemtype => itemtype,
                                        itemkey =>  itemkey,
                                        aname   => 'ECX_PARTY_SITE_ID');

/**Get transaction owner email from ecx_transactions from the userid**/
    begin
      select  distinct et.transaction_id,usr.email_address
      into    i_transaction_id,i_email_addr
      from    ecx_ext_processes eep,
              ecx_standards es,
	      ecx_tp_details etd,
              ecx_tp_headers eth,
              ecx_transactions et,
	      fnd_user    usr
     where    eep.ext_type        = l_transaction_type
     and      eep.ext_subtype     = l_transaction_subtype
     and      eep.standard_id     = es.standard_id
     and      es.standard_code    = l_standard_code
     and      es.standard_type    = nvl(l_standard_type,'XML')
     and      et.transaction_id   = eep.transaction_id
     and      etd.ext_process_id  = eep.ext_process_id
     and      eth.party_site_id    = l_party_site_id
     and      (eth.party_type       = l_party_type or l_party_type is null)
     and      eth.tp_header_id    = etd.tp_header_id
     and      et.admin_user       = usr.user_name
     and      eep.direction       = 'IN'  ;
     exception
          when too_many_rows then
            result := 'COMPLETE:F';
            return;
          when others then
            result  := 'COMPLETE:F';
            return;
            raise;
      end;
/** Check First if the Transacion Owner Exists**/

    wf_directory.GetRoleName(p_orig_system=>'ECX_TO:'||i_transaction_id,
                         p_orig_system_id=>i_transaction_id,
                         p_name=>rname,
			 p_display_name=>display_name);
    if rname is null then

      rname := 'ECX_TO-'||i_transaction_id;
      display_name := 'ECX Transaction Owner';

      l_params := wf_parameter_list_t();

      wf_event.addParameterToList(
                               p_name          => 'USER_NAME',
                               p_value         => rname,
                               p_parameterlist => l_params);

      wf_event.addParameterToList(
                               p_name          => 'DisplayName',
                               p_value         => display_name,
                               p_parameterlist => l_params);

      wf_event.addParameterToList(
                               p_name          => 'mail',
                               p_value         => i_email_addr,
                               p_parameterlist => l_params);

      wf_local_synch.propagate_role(
            p_orig_system => 'ECX_TO:'||i_transaction_id,
            p_orig_system_id => i_transaction_id,
            p_attributes => l_params,
            p_start_date => sysdate,
            p_expiration_date => sysdate +50000
         );

    else

       wf_directory.getRoleInfo(
                               role => rname,
			       display_name => i_wf_display_name,
                               email_address => i_wf_email_address,
			       notification_preference => i_notification_preference,
                               language => i_language,
                               territory => i_territory
			       );

       if ((i_wf_email_address is null) OR
           (i_wf_email_address <> i_email_addr))
       then

           l_params := wf_parameter_list_t();

           wf_event.addParameterToList(
                               p_name          => 'UpdateOnly',
                               p_value         => 'TRUE',
                               p_parameterlist => l_params);

           wf_event.addParameterToList(
                               p_name          => 'mail',
                               p_value         => i_email_addr,
                               p_parameterlist => l_params);

           wf_event.addParameterToList(
                               p_name          => 'USER_NAME',
                               p_value         => rname,
                               p_parameterlist => l_params);


           wf_local_synch.propagate_role(
                 p_orig_system => 'ECX_TO:' || i_transaction_id,
                 p_orig_system_id => i_transaction_id,
                 p_attributes => l_params,
                 p_start_date => sysdate,
                 p_expiration_date => sysdate +50000
              );


       end if;
    end if;

    wf_engine.SetItemAttrText ( 	itemtype => itemtype,
	      				itemkey  => itemkey,
  	      				aname    => 'ECX_TO_ROLE',
					avalue   =>  rname);

   -- example completion
    result  := 'COMPLETE:T';
    return;
  end if;



  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.

  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;


  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null

  result := '';

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('ECX_WF_ERRORS', 'GETTOROLE',
		    itemtype, itemkey, to_char(actid),
	    funcmode, ret_code, errmsg);
    raise;
End GETTOROLE;

end ECX_WF_ERRORS;

/
