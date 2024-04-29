--------------------------------------------------------
--  DDL for Package Body FND_CP_OPP_IPC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CP_OPP_IPC" AS
/* $Header: AFCPOPIB.pls 120.6 2006/09/15 17:06:51 pferguso noship $ */



-- Name of the OPP AQ
QUEUE_NAME   constant VARCHAR2(30) := 'FND_CP_GSM_OPP_AQ';


-- All names will be prefixed with this prefix before being used.
-- The prefix will be stripped off if returned outside this package.
-- Necessary because subscriber names and consumer names cannot begin with a number
OPPPREFIX    constant VARCHAR2(3)  := 'OPP';


-- Name of the schema that owns the AQ
Q_Schema varchar2(30) := NULL;


TYPE CurType is REF CURSOR;


-- Largest increment to wait for dequeue (in seconds)
TIMEOUT_INCREMENT constant number := 5;


DAY_PER_SEC constant number := 1 / (24 * 60 * 60); -- Days in a second
SEC_PER_DAY constant number := (24 * 60 * 60); -- Seconds in a day

--------------------------------------------------------------------------------


-- =========================================================
-- Subscription procedures
-- =========================================================


--
-- Subscribe to the OPP AQ
--
procedure Subscribe(subscriber in varchar2) is

pragma AUTONOMOUS_TRANSACTION;

Begin
    DBMS_AQADM.ADD_SUBSCRIBER(queue_name =>Q_Schema || '.' || QUEUE_NAME,
                              subscriber => sys.aq$_agent(OPPPREFIX || subscriber, NULL, NULL));


  commit;

Exception
  when others then
     rollback;
	 raise;

end;



--
-- Subscribe to the OPP AQ using a particular group
--
-- Subscribers will only receive messages targeted to this group,
-- i.e. where payload.message_group matches the subscriber's group
--
-- The OPP service will subscribe using the node name (or APPL_TOP name)
-- as its group id.
--
procedure Subscribe_to_group(subscriber in varchar2, groupid in varchar2) is

pragma AUTONOMOUS_TRANSACTION;

Begin
    DBMS_AQADM.ADD_SUBSCRIBER(queue_name =>Q_Schema || '.' || QUEUE_NAME,
                              subscriber => sys.aq$_agent(OPPPREFIX || subscriber, NULL, NULL),
							  rule       => 'tab.user_data.message_group = ''' || groupid || '''');


  commit;

Exception
  when others then
     rollback;
	 raise;

end;



--
-- Unsubscribe a single subscriber from the OPP AQ
--
procedure Unsubscribe(subscriber in varchar2) is

pragma AUTONOMOUS_TRANSACTION;

Begin
    DBMS_AQADM.REMOVE_SUBSCRIBER(queue_name =>Q_Schema || '.' || QUEUE_NAME,
                                 subscriber => sys.aq$_agent(OPPPREFIX || subscriber, NULL, NULL));


  commit;

Exception
  when others then
     rollback;
	 raise;
end;



--
-- Return a count of how many subscribers are currently subscribed to the AQ
-- for a particular group.
--
function check_group_subscribers(groupid  in varchar2) return number is

cnt   number := 0;
stmt  varchar2(256);

begin

    -- For some reason, a select from aq$FND_CP_GSM_OPP_AQTBL_R is not working...

    stmt := 'select count(*) from ' ||
	        Q_Schema || '.aq$' || QUEUE_NAME || 'TBL_S qtab, ' ||
	        'fnd_concurrent_processes fcp ' ||
	        'where qtab.queue = ''' || QUEUE_NAME ||
	        ''' and fcp.node_name = :1 ' ||
	        ' and fcp.process_status_code in (''A'',''Z'') ' ||
	        ' and qtab.name = ''' || OPPPREFIX || ''' || fcp.concurrent_process_id';

	execute immediate stmt into cnt using groupid;
	return cnt;

end;



--
-- Select a random OPP AQ subscriber out of all the current subscribers.
-- Returns the subscriber name.
--
function select_random_subscriber return varchar2 is

stmt         varchar2(512);
subscriber   varchar2(30);

begin


  stmt := 'select * ' ||
          'from ' ||
          '( ' ||
          'select name from ' || Q_Schema || '.aq$' || QUEUE_NAME || 'TBL_S ' ||
          'ORDER BY DBMS_RANDOM.VALUE ' ||
          ') where rownum = 1';

  execute immediate stmt into subscriber;

  if instr(subscriber, OPPPREFIX, 1, 1) = 1 then
          subscriber := substr(subscriber, length(OPPPREFIX) + 1);
  end if;

  return subscriber;

exception
  when no_data_found then
    return null;

end;



--
-- Remove all subscribers of the OPP AQ
--
procedure remove_all_subscribers is

  c1       CurType;
  subname  varchar2(30);

begin

	open c1 for
	  'select name from ' || Q_Schema || '.aq$' || QUEUE_NAME || 'TBL_S ' || ' where QUEUE = ''' || QUEUE_NAME || '''';
	loop
	    fetch c1 into subname;
		exit when c1%NOTFOUND;

        DBMS_AQADM.REMOVE_SUBSCRIBER(queue_name => Q_Schema || '.' || QUEUE_NAME,
	                                 subscriber => sys.aq$_agent(subname, NULL, NULL));
	end loop;
    close c1;

end;



--
-- Return a list of all subscribers
--
function list_subscribers return subscriber_list is

  c1         CurType;
  sublist    subscriber_list := subscriber_list();

begin

    open c1 for
	    'select name from ' || Q_Schema || '.aq$' || QUEUE_NAME || 'TBL_S' || ' where QUEUE = ''' || QUEUE_NAME || '''';


	fetch c1 bulk collect into sublist;
    close c1;
	return sublist;

end;




-- =========================================================
-- Message sending procedures
-- =========================================================



--
-- send_message_private
-- All messages are enqueued using this private procedure
--
-- INPUT:
--   recipients   - List of recipients. If null, published to the entire queue.
--   groupid      - Group to send to. Pass NULL if sending to a specific recipient
--   sender       - Sender's name
--   type         - Message type
--   message      - Message contents
--   Parameters   - Message payload
--
procedure send_message_private (recipients  in subscriber_list,
                                groupid     in varchar2,
                                sender      in Varchar2,
                                type        in Number,
                                message     in Varchar2,
                                Parameters  in Varchar2,
							    correlation in Varchar2 default null) is

 enq_opts	DBMS_AQ.enqueue_options_t;
 msg_props	DBMS_AQ.message_properties_t;
 msg_id		raw(16);
 msg		system.FND_CP_GSM_OPP_AQ_PAYLOAD;


 pragma AUTONOMOUS_TRANSACTION;

 begin
     msg := system.FND_CP_GSM_OPP_AQ_PAYLOAD(groupid, type, message, Parameters);

     enq_opts.visibility := DBMS_AQ.ON_COMMIT;
     enq_opts.sequence_deviation := NULL;
     msg_props.delay := DBMS_AQ.NO_DELAY;
     msg_props.expiration := 365 * 24 * 3600;	 -- One Year

	 msg_props.sender_id := sys.aq$_agent(OPPPREFIX || sender, NULL, NULL);

	 if correlation is not null then
		msg_props.correlation := correlation;
	 end if;

	 if recipients is not null then
	   for i in 1 .. recipients.COUNT
	   loop
	     msg_props.recipient_list(i) := sys.aq$_agent(OPPPREFIX || recipients(i), NULL, NULL);
	   end loop;
	 end if;

     DBMS_AQ.Enqueue( queue_name 	     => Q_Schema || '.' || QUEUE_NAME,
 			          enqueue_options    => enq_opts,
 			          message_properties => msg_props,
 			          Payload 	         => msg,
 			          msgid	 	         => msg_id);

     commit;

 exception
     when OTHERS then
        rollback;
 		raise;


end;





--
-- Generic send message procedure
-- Send a message of any type to one or more recipients
--
procedure send_message (recipients in subscriber_list,
                        sender     in Varchar2,
                        type       in Number,
                        message    in Varchar2,
                        Parameters in Varchar2) is

begin

	if recipients is null then
	  return;
	end if;

    send_message_private(recipients, null, sender, type, message, parameters);

end;




--
-- Send a message of any type to a specific process
--
procedure send_targeted_message (recipient   in Varchar2,
                                 sender      in Varchar2,
                                 type        in Number,
                                 message     in Varchar2,
                                 Parameters  in Varchar2,
								 correlation in Varchar2 default null) is

   rlist    subscriber_list;
begin

  if recipient is null then
	  return;
  end if;

  rlist := subscriber_list(recipient);
  send_message_private(rlist, null, sender, type, message, parameters, correlation);


end;




--
-- Send a message to a group to post-process a request
--
procedure send_request (groupid       in Varchar2,
                        sender        in Varchar2,
                        request_id    in number,
                        Parameters    in Varchar2) is

  cnt   number;
begin


    if groupid is null then
	    return;
	end if;


	send_message_private(null, groupid, sender, REQUEST_TYPE, to_char(request_id), parameters);

end;



--
-- Send a message to a specific process to post-process a request
--
procedure send_targeted_request ( recipient  in Varchar2,
                                  sender     in Varchar2,
                                  request_id in number,
                                  parameters in Varchar2) is

begin
    if recipient is null then
	  return;
	end if;

    send_targeted_message(recipient, sender, REQUEST_TYPE, to_char(request_id), parameters);

end;




--
-- Send an OPP command to a specific process
--
procedure send_command ( recipient  in Varchar2,
                         sender     in Varchar2,
                         command    in Varchar2,
                         parameters in Varchar2) is

begin

    if recipient is null then
	  return;
	end if;

    send_targeted_message(recipient, sender, COMMAND_TYPE, command, parameters);

end;









-- =========================================================
-- Receiving messages
-- =========================================================


--
-- Dequeue a message from the OPP AQ
--
-- INPUT:
--   Handle               - Used as the consumer name
--   Message_Wait_Timeout - Timeout in seconds
--
-- OUTPUT:
--   Success_Flag   - Y if received message, T if timeout, N if error
--   Message_Type   - Type of message
--   Message_group  - Group message was sent to
--   Message        - Message contents
--   Parameters     - Message payload
--   Sender         - Sender of message
--
-- If an exception occurs, success_flag will contain 'N', and
-- Message will contain the error message.
--
Procedure Get_Message ( Handle               in Varchar2,
                        Success_Flag         OUT NOCOPY  Varchar2,
                        Message_Type         OUT NOCOPY  Number,
                        Message_group        OUT NOCOPY  Varchar2,
                        Message              OUT NOCOPY  Varchar2,
                        Parameters           OUT NOCOPY  Varchar2,
                        Sender               OUT NOCOPY  Varchar2,
                        Message_Wait_Timeout IN          Number   default 60,
					    Correlation          IN          Varchar2 default null) is


 payload          system.FND_CP_GSM_OPP_AQ_PAYLOAD;
 dq_opts          DBMS_AQ.DEQUEUE_OPTIONS_T;
 msg_props        DBMS_AQ.MESSAGE_PROPERTIES_T;
 msgid            raw(16);
 queue_timeout    exception;
 time_left        number;
 end_time         date;

 pragma exception_init(queue_timeout, -25228);

 pragma AUTONOMOUS_TRANSACTION;

 Begin
     payload := system.FND_CP_GSM_OPP_AQ_PAYLOAD(NULL,NULL,NULL,NULL);

     dq_opts.DEQUEUE_MODE := DBMS_AQ.REMOVE;
     dq_opts.NAVIGATION := DBMS_AQ.FIRST_MESSAGE;
     dq_opts.VISIBILITY := DBMS_AQ.IMMEDIATE;
     dq_opts.MSGID := NULL;
     dq_opts.consumer_name := OPPPREFIX || Handle;

	 if correlation is not null then
		dq_opts.correlation := correlation;
	 end if;


	 time_left := Message_Wait_Timeout;
	 end_time := sysdate + (Message_Wait_Timeout * DAY_PER_SEC);

	 -- Loop until the return message arrives or the timeout expires,
	 -- but do not wait on any single dequeue call more than TIMEOUT_INCREMENT seconds
	 loop
		if time_left > TIMEOUT_INCREMENT then
		   dq_opts.WAIT := TIMEOUT_INCREMENT;
		else
		   dq_opts.WAIT := time_left;
		end if;

		begin

          DBMS_AQ.DEQUEUE(QUEUE_NAME => Q_Schema ||  '.' || QUEUE_NAME,
                          DEQUEUE_OPTIONS => dq_opts,
                          MESSAGE_PROPERTIES => msg_props,
                          PAYLOAD => payload,
                          MSGID => msgid);

		  exit;

		exception
		   when queue_timeout then
			 if sysdate >= end_time then
			   Success_Flag := 'T';
               commit;
               return;
			 end if;

			 time_left := (end_time - sysdate) * SEC_PER_DAY;
		end;

	 end loop;

     message_type := payload.message_type;
     message_group := payload.message_group;
     message := payload.message;
     parameters := payload.parameters;

     -- strip off any OPP prefix from the sender's name,
     if instr(msg_props.sender_id.name, OPPPREFIX, 1, 1) = 1 then
       sender := substr(msg_props.sender_id.name, length(OPPPREFIX) + 1);
     else
       sender := msg_props.sender_id.name;
     end if;

     Success_Flag := 'Y';

     commit;

exception

    when OTHERS then
        Success_Flag := 'N';
        message := substr(sqlerrm, 1, 240);
        commit;

end;



--
-- Package Initialization
--
procedure initialize is

status    varchar2(1);
industry  varchar2(1);
retval    boolean;

begin

  retval := fnd_installation.get_app_info('FND', status, industry, Q_Schema);

end;




begin

    initialize;

END fnd_cp_opp_ipc;

/
