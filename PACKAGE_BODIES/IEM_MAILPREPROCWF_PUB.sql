--------------------------------------------------------
--  DDL for Package Body IEM_MAILPREPROCWF_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_MAILPREPROCWF_PUB" as
/* $Header: iempwfpb.pls 120.4 2006/06/14 01:10:54 rtripath noship $*/

/**********************Global Variable Declaration **********************/

g_msg_count	number:=0;
g_first		number;
g_part_count	number:=0;
TYPE g_theme_part_rec is RECORD(
part_id		number,
theme		varchar2(150),
weight		number);
TYPE t_part_theme_tab IS TABLE OF g_theme_part_rec
INDEX By BINARY_INTEGER;
G_PKG_NAME	varchar2(30):='IEM_Mailpreprocwf_PUB';
G_DEFAULT_FOLDER	varchar2(50):='/Inbox';
G_APP_ID		number:=520;
G_LOG			char(1):='T';
g_topscore		number;
g_topclass		varchar2(100);
g_flow			varchar2(1);
g_process			varchar2(1);
g_outval			varchar2(200);

/**********************End Of Global Variable Declaration *******************/

	PROCEDURE 	IEM_STARTPROCESS(
     		WorkflowProcess IN VARCHAR2,
     		ItemType in VARCHAR2 ,
			ItemKey in number,
			p_itemuserkey in varchar2,
			p_msgid in varchar2,
			p_msgsize in number,
			p_sender in varchar2,
			p_username in varchar2,
			p_domain in varchar2,
			p_priority in varchar2,
			p_msg_status in varchar2,
			p_email_account_id in number,
			p_flow in varchar2,
			x_outval out nocopy varchar2,
			x_process		OUT NOCOPY varchar2)

			IS

          l_proc_name    varchar2(20):='IEM_STARTPROCESS';
		l_ret		number;
		l_ret1		number;

begin
               -- invoke an instance of workflow process
                    wf_engine.CreateProcess( ItemType => itemtype,
                    ItemKey  => ItemKey,
                    process  => WorkflowProcess );
               wf_engine.SetItemAttrNumber(itemtype => itemtype,
               itemkey  => itemkey,
               aname      => 'MSGID',
               avalue     =>  p_msgid );
          wf_engine.SetItemAttrText (itemtype => itemtype,
         itemkey  => itemkey,
         aname      => 'USER_NAME',
         avalue     =>  p_username );
         wf_engine.SetItemAttrText (itemtype => itemtype,
         itemkey  => itemkey,
         aname      => 'DOMAIN',
         avalue     =>  p_domain );
		G_STAT:='S'	;		-- Process Intialized To Success
		G_LOG:='T';
		g_flow:=p_flow;		-- Indicate new flow or old flow
		g_process:='N';
		g_outval:=null;

	IF p_sender is not null then 	-- Regular Processing

               wf_engine.SetItemAttrNumber ( itemtype => itemtype,
               itemkey  => itemkey,
               aname => 'MSG_SIZE',
               avalue     =>  p_msgsize);

          wf_engine.SetItemAttrText (itemtype => itemtype,
          itemkey  => itemkey,
          aname      => 'SENDER',
          avalue     =>  p_sender );


         wf_engine.SetItemAttrText (itemtype => itemtype,
         itemkey  => itemkey,
		aname      => 'PRIORITY',
         avalue     =>  p_priority );

         wf_engine.SetItemAttrText (itemtype => itemtype,
         itemkey  => itemkey,
         aname      => 'MSG_STATUS',
         avalue     =>  p_msg_status );
	ELSE					-- Processing The Retry Folder
		wf_engine.SetItemAttrNumber (itemtype => ItemType,
	      				itemkey  => ItemKey,
  	      				aname 	 => 'EMAILACCOUNTID',
					avalue	 =>  p_email_account_id);
	END IF;
         wf_engine.StartProcess(itemtype => itemtype,
         itemkey    => itemkey );
	    x_outval:=g_outval;
	    x_process:=g_process;
   exception
          when others then
               wf_core.context(G_PKG_NAME, l_proc_name,
               itemtype, itemkey);
			G_STAT:='E';
               raise;
end IEM_STARTPROCESS;

-- PROCEDURE IEM_WF_CHKAUTH
--
-- Check The user and domain for a valid user
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode. this is set by the engine
--               as either 'RUN', 'CANCEL', 'TIMEOUT'
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.
procedure IEM_WF_CHKAUTH(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out nocopy  varchar2)
is

l_proc_name	varchar2(20):='IEM_WF_CHKAUTH';
l_user	varchar2(40);
l_domain	varchar2(30);
l_pass	varchar2(100);
l_ret	number;
l_ret1	number;
l_str	varchar2(200);
l_msgid	number;
l_email_account_id	number;
l_errmsg	varchar2(200);
l_sender	varchar2(70);
l_db_server_id	number;
l_stat	varchar2(10);
l_count	number;
l_data	varchar2(255);
begin
	l_msgid := wf_engine.GetItemAttrText(
					itemtype => ItemType,
    					itemkey => ItemKey,
    					aname  	=> 'MSGID' );
	select email_account_id into l_email_account_id from
	iem_rt_preproc_emails where message_id=l_msgid;
		wf_engine.SetItemAttrNumber (itemtype => ItemType,
	      				itemkey  => ItemKey,
  	      				aname 	 => 'EMAILACCOUNTID',
					avalue	 =>  l_email_account_id);
		result:='COMPLETE:T';
EXCEPTION
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
		G_STAT:='E';
    wf_core.context(G_PKG_NAME, l_proc_name,
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;
end IEM_WF_CHKAUTH;

-- PROCEDURE IEM_WF_CHKUSERGRP
--
-- From the user name find the corresponding activity
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode. this is set by the engine
--               as either 'RUN', 'CANCEL', 'TIMEOUT'
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.
procedure IEM_WF_CHKUSERGRP(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out nocopy  varchar2)
is
l_user	varchar2(40);
l_proc_name	varchar2(20):='IEM_WF_CHKUSERGRP';
l_ret		number;
l_msgid		number;
begin
	l_user := wf_engine.GetItemAttrText(
					itemtype => ItemType,
    					itemkey => ItemKey,
    					aname  	=> 'USER_NAME' );
	l_msgid := wf_engine.GetItemAttrText(
					itemtype => ItemType,
    					itemkey => ItemKey,
    					aname  	=> 'MSGID' );
result:='COMPLETE:'||upper(l_user);
exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
		G_STAT:='E';
    wf_core.context(G_PKG_NAME, l_proc_name,
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;
end IEM_WF_CHKUSERGRP;

-- PROCEDURE IEM_WF_GETEXTHEADER
--
-- Get The extended header for the message id
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode. this is set by the engine
--               as either 'RUN', 'CANCEL', 'TIMEOUT'
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.

procedure IEM_WF_GETEXTHEADER(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out nocopy  varchar2)
is
l_proc_name	varchar2(20):='IEM_WF_GETEXTHEADER';
l_ret		number;
l_msgid		number;
l_str		varchar2(200);
l_errmsg		varchar2(200);
ext_hdr_exception   EXCEPTION;
begin
	result:='COMPLETE:';
exception
  when ext_hdr_exception then
	wf_engine.abortprocess(itemtype,itemkey);
	result:='COMPLETE:';
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context(G_PKG_NAME, l_proc_name,
                    itemtype, itemkey, to_char(actid), funcmode);
		G_STAT:='E';
    raise;
end IEM_WF_GETEXTHEADER;

-- PROCEDURE IEM_WF_MSGHDR
--
-- Process The Message To get the standard Header and populate the attribute
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode. this is set by the engine
--               as either 'RUN', 'CANCEL', 'TIMEOUT'
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.

procedure IEM_WF_MSGHDR(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out nocopy  varchar2)
is
l_ret	number;
l_proc_name	varchar2(20):='IEM_WF_MSGHDR';
l_str		varchar2(200);
l_total	number;
l_subject	varchar2(1000);
l_sender	varchar2(70);
l_to_recip	varchar2(240);
l_cc_recip	varchar2(240);
l_fwd_recip	varchar2(100);
l_frm_str	varchar2(80);
l_sent_date	date;
l_sent_dt1	date;
l_reply_to	varchar2(100);
l_msg_size 	number;
l_msgid 	number;
l_errmsg		varchar2(200);
msg_hdr_exception	EXCEPTION;
begin
	l_msgid := wf_engine.GetItemAttrNumber(
					itemtype => ItemType,
    					itemkey => ItemKey,
    					aname  	=> 'MSGID' );
	select to_str,cc_str,from_str,reply_to_str,subject,message_size into
	l_to_recip,l_cc_recip,l_frm_str,l_reply_to,l_subject,l_msg_size
	from iem_ms_base_headers
	where message_id=l_msgid;
		wf_engine.SetItemAttrText (itemtype => ItemType,
	      				itemkey  => ItemKey,
  	      				aname 	 => 'MSG_TO',
					avalue	 =>  l_to_recip);
		wf_engine.SetItemAttrText (itemtype => ItemType,
	      				itemkey  => ItemKey,
  	      				aname 	 => 'MSG_FROM',
					avalue	 =>  l_frm_str);
		wf_engine.SetItemAttrText (itemtype => ItemType,
	      				itemkey  => ItemKey,
  	      				aname 	 => 'MSG_CC',
					avalue	 =>  l_cc_recip);
		wf_engine.SetItemAttrText (itemtype => ItemType,
	      				itemkey  => ItemKey,
  	      				aname 	 => 'SUBJECT',
					avalue	 =>  l_subject);
		wf_engine.SetItemAttrText (itemtype => ItemType,
	      				itemkey  => ItemKey,
  	      				aname 	 => 'SENDER',
					avalue	 =>  l_frm_str);
		wf_engine.SetItemAttrText (itemtype => ItemType,
	      				itemkey  => ItemKey,
  	      				aname 	 => 'REPLY_TO',
					avalue	 =>  l_reply_to);
		wf_engine.SetItemAttrNumber (itemtype => ItemType,
	      				itemkey  => ItemKey,
  	      				aname 	 => 'MSG_SIZE',
					avalue	 =>  l_msg_size);
   		result:='COMPLETE:';
exception
  when msg_hdr_exception then
	if g_flow='N' then
		G_STAT:='E';
	end if;
	wf_engine.abortprocess(itemtype,itemkey);
	result:='COMPLETE:';
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context(G_PKG_NAME, l_proc_name,
                    itemtype, itemkey, to_char(actid), funcmode);
		G_STAT:='E';
    raise;
end IEM_WF_MSGHDR;

-- PROCEDURE IEM_WF_GETPART
--
-- Process The Message To get the part attached with the message
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode. this is set by the engine
--               as either 'RUN', 'CANCEL', 'TIMEOUT'
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.

procedure IEM_WF_GETPART(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out nocopy  varchar2)
is
 l_proc_name	varchar2(20):='IEM_WF_GETPART';
 l_errtext	varchar2(100);
 l_msg_id		number;
 l_ret		number;
 l_flag		number:=1;
 l_partcount	number:=1;
 l_themecount	number;
 l_themeindex	binary_integer;
 l_part_theme	number:=1;
 l_count		number:=0;
 l_errmsg		varchar2(300);
 l_part		number;
 l_str		varchar2(200);
 get_part_exception	EXCEPTION;
 begin
	result:='COMPLETE:';
exception
  when get_part_exception then
	wf_engine.abortprocess(itemtype,itemkey);
	result:='COMPLETE:';
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context(G_PKG_NAME, l_proc_name,
                    itemtype, itemkey, to_char(actid), funcmode);
		G_STAT:='E';
    raise;
end IEM_WF_GETPART;

-- PROCEDURE IEM_WF_AUTHFAILED
--
-- Show a Message that authorisation is failed and terminate the process
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode. this is set by the engine
--               as either 'RUN', 'CANCEL', 'TIMEOUT'
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.

procedure IEM_WF_AUTHFAILED(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out nocopy  varchar2)
is
 l_proc_name	varchar2(20):='IEM_WF_AUTHFAILED';
 auth_fail_exception	EXCEPTION;
l_msg_id		number;
begin
	l_msg_id := wf_engine.GetItemAttrNumber(
					itemtype => ItemType,
    					itemkey => ItemKey,
    					aname  	=> 'MSGID' );
	result:='COMPLETE:';
	raise auth_fail_exception;
exception
  when auth_fail_exception then
		G_STAT:='E';
	raise;
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context(G_PKG_NAME, l_proc_name,
                    itemtype, itemkey, to_char(actid), funcmode);
		G_STAT:='E';
    raise;
end IEM_WF_AUTHFAILED;

-- PROCEDURE IEM_WF_ENQUEUE
--
-- Enqueue a processed mail in AQ2
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode. this is set by the engine
--               as either 'RUN', 'CANCEL', 'TIMEOUT'
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           functioN ENCOUNTered an error.

procedure IEM_WF_ENQUEUE(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out nocopy  varchar2)
is
 l_proc_name	varchar2(20):='IEM_WF_ENQUEUE';
l_msg_count number;
l_ret_status varchar2(40);
l_msg_data varchar2(240);
l_count	number;
i_count	number;
l_key1	varchar2(100);
l_val1	varchar2(300);
l_key2	varchar2(100);
l_val2	varchar2(300);
l_key3	varchar2(100);
l_val3	varchar2(300);
l_key4	varchar2(100);
l_val4	varchar2(300);
l_key5	varchar2(100);
l_val5	varchar2(300);
l_key6	varchar2(100);
l_val6	varchar2(300);
l_key7	varchar2(100);
l_val7	varchar2(300);
l_key8	varchar2(100);
l_val8	varchar2(300);
l_key9	varchar2(100);
l_val9	varchar2(300);
l_key10	varchar2(100);
l_val10	varchar2(300);
l_msg_id	number;
l_email_account_id	number;
l_priority	varchar2(128);
l_domain	varchar2(50);
l_user	varchar2(50);
l_smtpid	varchar2(240);
l_sender	varchar2(70);
l_sentdate	date;
l_msg_status	varchar2(30);
l_msg_size	number;
l_class_score	number;
l_subject	varchar2(1000);
l_class	varchar2(50);
l_to_recip	varchar2(240);
l_cc_recip	varchar2(240);
l_fwd_recip	varchar2(100);
l_frm_str	varchar2(80);
l_reply_to	varchar2(100);
l_ret		number;
l_media_id	number;
l_errmsg		varchar2(200);
l_str		varchar2(200);
l_nqstr		varchar2(2000);
l_customer_id	number;
enq_exception		EXCEPTION;

begin
	result:='COMPLETE:';
exception
  when enq_exception then
	wf_engine.abortprocess(itemtype,itemkey);
	result:='COMPLETE:';
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context(G_PKG_NAME, l_proc_name,
                    itemtype, itemkey, to_char(actid), funcmode);
		G_STAT:='E';
    raise;
end IEM_WF_ENQUEUE;

-- PROCEDURE IEM_WF_NOGRP
--
-- Process The mail when no user group are defined for the mail.
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode. this is set by the engine
--               as either 'RUN', 'CANCEL', 'TIMEOUT'
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.
procedure IEM_WF_NOGRP(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out nocopy  varchar2)
is
l_proc_name	varchar2(20):='IEM_WF_NOGRP';
l_user		varchar2(50);
l_ret		number;
l_msg_id		number;
l_str		varchar2(200);
l_errmsg		varchar2(200);
begin
	l_msg_id := wf_engine.GetItemAttrNumber(
					itemtype => ItemType,
    					itemkey => ItemKey,
    					aname  	=> 'MSGID' );
	l_user := wf_engine.GetItemAttrText(
					itemtype => ItemType,
    					itemkey => ItemKey,
    					aname  	=> 'USER_NAME' );
result:='COMPLETE:';
exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context(G_PKG_NAME, l_proc_name,
                    itemtype, itemkey, to_char(actid), funcmode);
		G_STAT:='E';
    raise;
end IEM_WF_NOGRP;

-- PROCEDURE IEM_WF_IS_STRUCT
--
-- Do The Processing when the user belongs to Service
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode. this is set by the engine
--               as either 'RUN', 'CANCEL', 'TIMEOUT'
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.

procedure IEM_WF_IS_STRUCT(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out nocopy  varchar2)
is
l_ret	number;
l_ret1	number;
l_msg_id	number;
l_count	number;
l_struct	char(1):='F';
l_part         number;
l_flag         number:=1;
l_text         varchar2(700);
l_hlbuff       iem_im_wrappers_pvt.highlight_table;
l_text_query   varchar2(30):='X Structure ID Tag';
l_proc_name	varchar2(20):='IEM_WF_IS_STRUCT';
l_sender		varchar2(70);
l_errmsg		varchar2(200);
l_errtext		varchar2(200);
l_query		varchar2(1000);
struct_exception	EXCEPTION;
begin
		result:='COMPLETE:T';
exception
  when struct_exception then
	if g_flow='N' then
		G_STAT:='E';
	end if;
	wf_engine.abortprocess(itemtype,itemkey);
	result:='COMPLETE:';
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context(G_PKG_NAME, l_proc_name,
                    itemtype, itemkey, to_char(actid), funcmode);
		G_STAT:='E';
    raise;
end IEM_WF_IS_STRUCT;

-- PROCEDURE IEM_WF_STRUCT_PROC
--
-- Node For Processing Structured Mail. This Will call another workflow start
-- process for processing structured e-mail.
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode. this is set by the engine
--               as either 'RUN', 'CANCEL', 'TIMEOUT'
-- OUT
--   resulT
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.

procedure IEM_WF_STRUCT_PROC(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out nocopy  varchar2)
is
l_item_type	varchar2(30); -- :=VALUE To be provided by VA Team
l_item_key	number;
l_wf_process	varchar2(30); --:=VALUE To be provided by VA Team
l_proc_name	varchar2(30):='IEM_WF_STRUCT_PROC';
l_msg_id		number;
l_ret_stat	varchar2(20);

begin
			result:='COMPLETE:F';
  exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context(G_PKG_NAME,l_proc_name,
                    itemtype, itemkey, to_char(actid), funcmode);
		G_STAT:='E';
    raise;
end IEM_WF_STRUCT_PROC;

-- PROCEDURE IEM_WF_BCC_TO
--
-- Node For BCC The mail to a reciepient .
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode. this is set by the engine
--               as either 'RUN', 'CANCEL', 'TIMEOUT'
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.

procedure IEM_WF_BCC_TO(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out nocopy  varchar2)
is
l_bcc	varchar2(50);
l_proc_name	varchar2(30):='IEM_WF_BCC_TO';
l_msg_id		number;
l_ret		number;
l_errmsg		varchar2(200);
l_str		varchar2(200);

begin
 	result:='COMPLETE:';
exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context(G_PKG_NAME, l_proc_name,
                    itemtype, itemkey, to_char(actid), funcmode);
		G_STAT:='E';
    raise;
end IEM_WF_BCC_TO;

-- PROCEDURE IEM_WF_DELETEMSG
--
-- Delete The current Message .
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode. this is set by the engine
--               as either 'RUN', 'CANCEL', 'TIMEOUT'
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.

procedure IEM_WF_DELETEMSG(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out nocopy  varchar2)
is
l_msg_id		number;
l_folder		varchar2(50);
l_proc_name	varchar2(30):='IEM_WF_DELETEMSG';
l_errmsg		varchar2(200);
l_ret		varchar2(200);
l_str		varchar2(200);
del_exception	EXCEPTION;

begin
 	result:='COMPLETE:';
exception
  when del_exception then
	wf_engine.abortprocess(itemtype,itemkey);
	result:='COMPLETE:';
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context(G_PKG_NAME, l_proc_name,
                    itemtype, itemkey, to_char(actid), funcmode);
		G_STAT:='E';
    raise;
end IEM_WF_DELETEMSG ;

-- PROCEDURE IEM_WF_MOVETO
--
-- Move The Current Message To The Specified Folder
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode. this is set by the engine
--               as either 'RUN', 'CANCEL', 'TIMEOUT'
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.

procedure IEM_WF_MOVETO(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out nocopy  varchar2)
is
l_msg_id		number;
l_ret		number;
l_folder		varchar2(50);
l_proc_name	varchar2(30):='IEM_WF_MOVETO';
l_errmsg		varchar2(300);
l_str		varchar2(200);

begin
 result:='COMPLETE:';
exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context(G_PKG_NAME, l_proc_name,
                    itemtype, itemkey, to_char(actid), funcmode);
		G_STAT:='E';
    raise;
end IEM_WF_MOVETO ;

-- PROCEDURE IEM_WF_COPYTO
--
-- Copy The Current Message To The Specified Folder
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode. this is set by the engine
--               as either 'RUN', 'CANCEL', 'TIMEOUT'
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.

procedure IEM_WF_COPYTO(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out nocopy  varchar2)
is
l_msg_id		number;
l_ret		number;
l_folder		varchar2(50);
l_proc_name	varchar2(30):='IEM_WF_COPYTO';
l_errmsg		varchar2(200);
l_str		varchar2(200);

begin
		result:='COMPLETE:';
exception
 	 when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context(G_PKG_NAME, l_proc_name,
                    itemtype, itemkey, to_char(actid), funcmode);
		G_STAT:='E';
    raise;
end IEM_WF_COPYTO ;

-- PROCEDURE IEM_WF_FORWARDTO
--
-- Forward The Current Message With a Notes Attached
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode. this is set by the engine
--               as either 'RUN', 'CANCEL', 'TIMEOUT'
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.

procedure IEM_WF_FORWARDTO(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out nocopy  varchar2)
is
l_msg_id		number;
l_ret		number;
l_notes		varchar2(500);
l_subject		varchar2(500);
l_user		varchar2(500);
l_fwd_recip		varchar2(100);
l_proc_name	varchar2(30):='IEM_WF_FORWARDTO';
l_errmsg		varchar2(200);
l_str		varchar2(200);

begin
 result:='COMPLETE:';
exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context(G_PKG_NAME, l_proc_name,
                    itemtype, itemkey, to_char(actid), funcmode);
		G_STAT:='E';
    raise;
end IEM_WF_FORWARDTO ;

-- PROCEDURE IEM_WF_SIMPLESEARCH
--
-- Do a search on the KB Repository
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode. this is set by the engine
--               as either 'RUN', 'CANCEL', 'TIMEOUT'
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.

procedure IEM_WF_SIMPLESEARCH(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out nocopy  varchar2)
is
l_proc_name	varchar2(100):='IEM_WF_SIMPLESEARCH';
begin
 result:='COMPLETE:';
exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context(G_PKG_NAME, l_proc_name,
                    itemtype, itemkey, to_char(actid), funcmode);
		G_STAT:='E';
    raise;
end IEM_WF_SIMPLESEARCH ;

-- PROCEDURE IEM_WF_SPECIFICSEARCH
--
-- Do a specific search on the KB Repository
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode. this is set by the engine
--               as either 'RUN', 'CANCEL', 'TIMEOUT'
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.

procedure IEM_WF_SPECIFICSEARCH(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out nocopy  varchar2)
is
l_proc_name	varchar2(30):='IEM_WF_SPECIFICSEARCH';

begin
 result:='COMPLETE:';
exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context(G_PKG_NAME, l_proc_name,
                    itemtype, itemkey, to_char(actid), funcmode);
		G_STAT:='E';
    raise;
end IEM_WF_SPECIFICSEARCH;
procedure IEM_WF_SEARCHMESSAGE(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out nocopy  varchar2)
is
l_proc_name	varchar2(20):='IEM_WF_SEARCHMESSAGE';
begin
	result:='COMPLETE:F';
exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context(G_PKG_NAME, l_proc_name,
                    itemtype, itemkey, to_char(actid), funcmode);
		G_STAT:='E';
    raise;
end IEM_WF_SEARCHMESSAGE;

procedure IEM_WF_STORETHEME(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out nocopy  varchar2)
is
l_proc_name	varchar2(20):='IEM_WF_STORETHEME';
begin
	result:='COMPLETE:';
exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context(G_PKG_NAME, l_proc_name,
                    itemtype, itemkey, to_char(actid), funcmode);
		G_STAT:='E';
    raise;
end IEM_WF_STORETHEME;

procedure IEM_WF_THEMEPROC(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out nocopy  varchar2)
is
l_proc_name	varchar2(20):='IEM_WF_THEMEPROC';
begin
	result:='COMPLETE:';
exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context(G_PKG_NAME, l_proc_name,
                    itemtype, itemkey, to_char(actid), funcmode);
		G_STAT:='E';
    raise;
end IEM_WF_THEMEPROC;

-- PROCEDURE IEM_WF_KEYVAL
--
-- Find the value based on the key supplied in the message
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode. this is set by the engine
--               as either 'RUN', 'CANCEL', 'TIMEOUT'
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.

procedure IEM_WF_KEYVAL(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out nocopy  varchar2)
is

l_proc_name	varchar2(20):='IEM_WF_KEYVAL';
l_ret	number;
l_str	varchar2(250);
l_msgid	number;
l_api	number:=1.0;
l_key	varchar2(100);
l_val	varchar2(100);
l_sender	varchar2(70);
l_part	number;
l_err_text	varchar2(100);
begin
		result:='COMPLETE:F';
EXCEPTION
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
		G_STAT:='E';
    wf_core.context(G_PKG_NAME, l_proc_name,
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;
end IEM_WF_KEYVAL;

-- PROCEDURE IEM_WF_CLASSRULE
--
-- Check The Classifcation Score with thresh hold score
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode. this is set by the engine
--               as either 'RUN', 'CANCEL', 'TIMEOUT'
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.

procedure IEM_WF_CLASSRULE(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out nocopy  varchar2)
is

l_proc_name	varchar2(20):='IEM_WF_CLASSRULE';
l_ret	number;
l_str	varchar2(200);
l_msgid	number;
l_mscore	number;
l_score	number;
l_sender	varchar2(70);
begin
		result:='COMPLETE:F';
EXCEPTION
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
		G_STAT:='E';
    wf_core.context(G_PKG_NAME, l_proc_name,
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;
end IEM_WF_CLASSRULE;

-- PROCEDURE IEM_WF_CHKAUTO
--
-- Check The Classifcation Score with thresh hold score  for autoresponce
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode. this is set by the engine
--               as either 'RUN', 'CANCEL', 'TIMEOUT'
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.

procedure IEM_WF_CHKAUTO(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out nocopy  varchar2)
is

l_proc_name	varchar2(20):='IEM_WF_CHKAUTO';
l_ret	number;
l_str	varchar2(200);
l_msgid	number;
l_mscore	number;
l_score	number;
l_chk	number;
l_email_account_id	number;
l_sender	varchar2(70);
l_subject	varchar2(200);
begin

		result:='COMPLETE:F';
EXCEPTION
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
		G_STAT:='E';
    wf_core.context(G_PKG_NAME, l_proc_name,
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;
end IEM_WF_CHKAUTO;

-- PROCEDURE IEM_WF_AUTORESP
--
-- Autorespond to the sender with a set of documents
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode. this is set by the engine
--               as either 'RUN', 'CANCEL', 'TIMEOUT'
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.

procedure IEM_WF_AUTORESP(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out nocopy  varchar2)
is

l_proc_name	varchar2(20):='IEM_WF_AUTORESP';

begin
	result:='COMPLETE:F';
 END IEM_WF_AUTORESP;

-- PROCEDURE IEM_WF_ORDSTAT
--
-- Autorespond to the sender with order status
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode. this is set by the engine
--               as either 'RUN', 'CANCEL', 'TIMEOUT'
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.

procedure IEM_WF_ORDSTAT(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out nocopy  varchar2)
is

l_proc_name	varchar2(20):='IEM_WF_ORDSTAT';
begin
	result:='COMPLETE:F';
END IEM_WF_ORDSTAT;

end IEM_Mailpreprocwf_PUB ;

/
