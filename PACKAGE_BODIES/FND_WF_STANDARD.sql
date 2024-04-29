--------------------------------------------------------
--  DDL for Package Body FND_WF_STANDARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_WF_STANDARD" as
/* $Header: AFWFSTDB.pls 120.1.12010000.3 2008/08/27 17:29:00 alepe ship $ */


-------------------------------------------------------------------
-- Name:        SubmitConcProgram
-- Description: submits a concurrent program ONLY.
--              returns the request_id to the choosen item attribute
-- Notes:
-- APPS context must already be set
-- use fnd_global.apps_initialize(user_id,resp_id,resp_appl_id);
-------------------------------------------------------------------

Procedure SubmitConcProgram(itemtype  in varchar2,
                  itemkey   in varchar2,
                  actid     in number,
                  funcmode  in varchar2,
                  resultout in out nocopy varchar2)
is
req_id number;
BEGIN

   -- Do nothing in cancel or timeout mode
   if (funcmode <> wf_engine.eng_run) then
       resultout := wf_engine.eng_null;
       return;
   end if;

   fnd_wf_standard.Submit_CP(itemtype, itemkey, actid, req_id);

   resultout := wf_engine.eng_completed;

exception
 when others then
    Wf_Core.Context('FND_WF_STANDARD', 'SubmitConcProgram', itemtype, itemkey);
    raise;
end SubmitConcProgram;


-------------------------------------------------------------------
-- Name:        ExecuteConcProgram
-- Description: Executes a concurrent program.
--              This submits the request and waits for it to complete.
-- Notes:
-- APPS context must already be set
-- use fnd_global.apps_initialize(user_id,resp_id,resp_appl_id);
-------------------------------------------------------------------
Procedure ExecuteConcProgram(itemtype  in varchar2,
                  itemkey   in varchar2,
                  actid     in number,
                  funcmode  in varchar2,
                  resultout in out nocopy varchar2)
is
result boolean;
num_val number;
req_id number;
BEGIN
   -- Do nothing in cancel or timeout mode
   if (funcmode <> wf_engine.eng_run) then
       resultout := wf_engine.eng_null;
       return;
   end if;

   fnd_wf_standard.Submit_CP(itemtype, itemkey, actid, req_id);

   -- if we get here, the request must have been succesfully submitted.
   -- also, it cannot have been run yet because we havent committed
   -- so seed the callback
   num_val := fnd_wf_standard.Seed_CB(itemtype, itemkey, actid, req_id);


   -- put this activity in wait/notified state
   resultout := wf_engine.eng_notified||':'||wf_engine.eng_null||
                 ':'||wf_engine.eng_null;

exception
 when others then
    Wf_Core.Context('FND_WF_STANDARD', 'ExecuteConcProgram', itemtype, itemkey);
    raise;

end ExecuteConcProgram;


-------------------------------------------------------------------
-- Name:        WaitForConcProgram
-- Description: Waits for a concurrent program to complete.
-------------------------------------------------------------------
Procedure WaitForConcProgram(itemtype  in varchar2,
                  itemkey   in varchar2,
                  actid     in number,
                  funcmode  in varchar2,
                  resultout in out nocopy varchar2)
is
req_id number;
phase  varchar2(20);
s0     varchar2(200); --dummy
devphase  varchar2(200);      /* Bug 2220527 */
complete_status varchar2(10):=null;

cursor avgCPtime(c_reqID in number) is
  select avg(fr1.actual_completion_date - fr1.actual_start_date)
  from fnd_concurrent_requests fr1, fnd_concurrent_requests fr2
  where fr2.request_id = c_reqID
  and fr1.concurrent_program_id = fr2.concurrent_program_id
  and fr1.program_application_id = fr2.program_application_id
  and fr1.actual_start_date is not null
  and fr1.actual_completion_date is not null;

avgTime number;
l_minute number;

BEGIN
   -- Do nothing in cancel or timeout mode
   if (funcmode <> wf_engine.eng_run) then
       resultout := wf_engine.eng_null;
   else
     req_id := wf_engine.GetActivityAttrNumber(itemtype,itemkey,actid,
                                               'REQUEST_ID');

     if (fnd_concurrent.get_request_status(REQUEST_ID => req_id,
                                           PHASE      => phase,
                                           STATUS     => s0,
                                           DEV_PHASE  => devphase,
                                           DEV_STATUS => complete_status,
                                           MESSAGE    => s0)) then
       if devphase = 'COMPLETE' then
         resultout := wf_engine.eng_completed||':'||complete_status;
       elsif devphase = 'RUNNING' then
         --Calculate a minute as 1 day / 24 hours / 60 minutes.
         l_minute := 1/24/60;
         --The request is running but could be in post-processing so we will
         --calculate a delay to defer to the background engine.
         --The assumption here is that the average will give enough of an
         --approximation to allow only one defer and not wait too long to
         --recheck.  If we find need, we can enhance to calculate from the
         --start time of this request.
         open avgCPTime(req_id);
           fetch avgCPTime into avgTime;
         close avgCPTime;

         --If avgTime is < 1 minute or null, we will default to 1 minute.
         resultout := wf_engine.eng_deferred||':'||
                      to_char(sysdate+greatest(nvl(avgTime,0),l_minute),
                              wf_engine.date_format);
       else
         if fnd_wf_standard.Seed_CB(itemtype, itemkey, actid, req_id) < 0 then
              resultout := wf_engine.eng_completed||':'||complete_status;
         else
           -- put this activity in wait/notified state
           resultout := wf_engine.eng_notified||':'||wf_engine.eng_null||
                        ':'||wf_engine.eng_null;
         end if; --Seed_CB
       end if; -- devphase
     end if; -- get_request_status
   end if; -- funcmode
exception
  when others then
    if (avgCPTime%ISOPEN) then
      close avgCPTime;
    end if;

    Wf_Core.Context('FND_WF_STANDARD', 'WaitForConcProgram', itemtype, itemkey);
    raise;

end WaitForConcProgram;




-------------------------------------------------------------------
-- Name:        Submit_CP (PRIVATE)
-- Description: submits a concurrent program
-- Notes:
-- APPS context must already be set
-- use fnd_global.apps_initialize(user_id,resp_id,resp_appl_id);
-------------------------------------------------------------------
Procedure Submit_CP(itemtype  in varchar2,
                    itemkey   in varchar2,
                    actid     in number,
                    req_id    in out nocopy number)
is

type AttrArrayTyp is table of varchar2(240) index by binary_integer;
conc_arg   AttrArrayTyp;     -- Array of item attributes
conc_count pls_integer := 0; -- Array size

appl_name varchar2(30);
prog_name varchar2(30);
arg_count number;
aname varchar2(30);
msg   varchar2(2000);
i number;

submission_error exception;

BEGIN

--apps content must already be set, see comments above
--for testing use something like:    fnd_global.apps_initialize( 0,20419,0);

   -- get all arguments.
   appl_name := wf_engine.GetActivityAttrText(itemtype,itemkey,actid, 'APPLNAME');
   prog_name := wf_engine.GetActivityAttrText(itemtype,itemkey,actid, 'PROGRAM');
   arg_count := wf_engine.GetActivityAttrNumber(itemtype,itemkey,actid, 'NUMBEROFARGS');

   if (appl_name is null)
   or (prog_name is null)
   or (arg_count is null) then
       Wf_Core.Raise('WFSQL_ARGS');
   end if;

   -- assign all 100 arguments for concurrent program
   i:=0;
   for i in 1..arg_count loop
       aname := 'ARG'||to_char(i);
       conc_arg(i) := wf_engine.GetActivityAttrText(itemtype,itemkey,actid,aname);
   end loop;

   -- if not all args used then set the last arg to chr(0)
   -- and all after it to null.
   if arg_count < 100 then
       i := arg_count+1;
       conc_arg(i) := chr(0);
       i := i+1;
   	  while i <= 100 loop
   	      aname := 'ARG'||to_char(i);
   	      conc_arg(i) := null;
              i := i+1;
   	  end loop;
   end if;


   -- submit the request
   req_id := fnd_request.submit_request(appl_name,
	     prog_name,
   	     null,
   	     null,
   	     false,
             conc_arg(1), conc_arg(2), conc_arg(3), conc_arg(4), conc_arg(5),
             conc_arg(6), conc_arg(7), conc_arg(8), conc_arg(9), conc_arg(10),
             conc_arg(11),conc_arg(12),conc_arg(13),conc_arg(14),conc_arg(15),
             conc_arg(16),conc_arg(17),conc_arg(18),conc_arg(19),conc_arg(20),
             conc_arg(21),conc_arg(22),conc_arg(23),conc_arg(24),conc_arg(25),
             conc_arg(26),conc_arg(27),conc_arg(28),conc_arg(29),conc_arg(30),
             conc_arg(31),conc_arg(32),conc_arg(33),conc_arg(34),conc_arg(35),
             conc_arg(36),conc_arg(37),conc_arg(38),conc_arg(39),conc_arg(40),
             conc_arg(41),conc_arg(42),conc_arg(43),conc_arg(44),conc_arg(45),
             conc_arg(46),conc_arg(47),conc_arg(48),conc_arg(49),conc_arg(50),
             conc_arg(51),conc_arg(52),conc_arg(53),conc_arg(54),conc_arg(55),
             conc_arg(56),conc_arg(57),conc_arg(58),conc_arg(59),conc_arg(60),
             conc_arg(61),conc_arg(62),conc_arg(63),conc_arg(64),conc_arg(65),
             conc_arg(66),conc_arg(67),conc_arg(68),conc_arg(69),conc_arg(70),
             conc_arg(71),conc_arg(72),conc_arg(73),conc_arg(74),conc_arg(75),
             conc_arg(76),conc_arg(77),conc_arg(78),conc_arg(79),conc_arg(80),
             conc_arg(81),conc_arg(82),conc_arg(83),conc_arg(84),conc_arg(85),
             conc_arg(86),conc_arg(87),conc_arg(88),conc_arg(89),conc_arg(90),
             conc_arg(91),conc_arg(92),conc_arg(93),conc_arg(94),conc_arg(95),
             conc_arg(96),conc_arg(97),conc_arg(98),conc_arg(99),conc_arg(100));

   if (req_id <= 0 or req_id is null) then
        raise submission_error;
   end if;


   -- update the item type, if it exists,  with the req_id
   aname := wf_engine.GetActivityAttrText(itemtype,itemkey,actid, 'REQIDNAME');
   if aname is not null then
     begin
       Wf_Engine.SetItemAttrNumber(itemtype, itemkey, aname, req_id);

       exception when others then
	-- if item attr doesnt exist then create it now
	if ( wf_core.error_name = 'WFENG_ITEM_ATTR' ) then
	  wf_engine.AddItemAttr(itemtype, itemkey, aname);
	  Wf_Engine.SetItemAttrNumber(itemtype, itemkey, aname, req_id);
	else
	  raise;
	end if;
      end;
   end if;

exception
    when submission_error then
       fnd_message.retrieve(msg);
       Wf_Core.Context('FND_WF_STANDARD', 'Submit_CP', itemtype, itemkey,
                        appl_name||':'||prog_name, msg);
       raise;
    when others then
       Wf_Core.Context('FND_WF_STANDARD', 'Submit_CP', itemtype, itemkey,
                    appl_name||':'||prog_name);
    raise;
END Submit_CP;

-------------------------------------------------------------------
-- Name:        Seed_CB (PRIVATE)
-- Description: performs the actual submit routine.
-------------------------------------------------------------------

--Name: Seed_CB (PRIVATE)
--      This seeds the callback  for a the concurrent program

Function  Seed_CB(itemtype  in varchar2,
                  itemkey   in varchar2,
                  actid     in number,
                  req_id    in number) RETURN number
is
result    number;
BEGIN

   -- seed  the callback for success
   result := fnd_conc_pp.assign(application =>'FND' ,
          executable_name => 'FND_WFCALLBACK',
          req_id => req_id,
          s_flag => 'Y',
          w_flag => 'N',
          f_flag => 'N',
          Arg1   => itemtype||':'||itemkey,
          arg2 => to_char(actid),
          arg3 => 'S', arg4 => null, arg5 => null, arg6 => null,
          arg7 => null, arg8 => null, arg9 => null, arg10 => null);

   -- seed  the callback for warning
   result := fnd_conc_pp.assign(application =>'FND' ,
          executable_name => 'FND_WFCALLBACK',
          req_id => req_id,
          s_flag => 'N',
          w_flag => 'Y',
          f_flag => 'N',
          Arg1   => itemtype||':'||itemkey,
          arg2 => to_char(actid),
          arg3 => 'W', arg4 => null, arg5 => null, arg6 => null,
          arg7 => null, arg8 => null, arg9 => null, arg10 => null);

   -- seed  the callback for failure
   result := fnd_conc_pp.assign(application =>'FND' ,
          executable_name => 'FND_WFCALLBACK',
          req_id => req_id,
          s_flag => 'N',
          w_flag => 'N',
          f_flag => 'Y',
          Arg1   => itemtype||':'||itemkey,
          arg2 => to_char(actid),
          arg3 => 'F', arg4 => null, arg5 => null, arg6 => null,
          arg7 => null, arg8 => null, arg9 => null, arg10 => null);

    if result < 0 then
       Wf_Core.Raise('WF_CONC_PP_SUBMIT');
    end if;


    return(result);

exception
    when others then
       Wf_Core.Context('FND_WF_STANDARD', 'Seed_CB', itemtype, itemkey,
                    to_char(req_id));
    raise;
end Seed_CB;


------------------------------------------------------------------
-- Name:   CALLBACK
-- Parameters:
--   errbuff - standard error buffer required for conc mgr submission
--   retcode - standard return code  required for conc mgr submission
--   step    - handle to cocnurrent program that seeded the call
-- Notes:
-- this is called by the concurrent program's post-processsor
--
-- It executes the callback function to Oracle Workflow and
-- re-initiates the flow after a call to the conc-manager
--
-- It MUST be regestered as a concurrent program called WFCALLBACK
-- in the AOL application.
-------------------------------------------------------------------
Procedure CALLBACK (errbuff out nocopy varchar2,
                       retcode out nocopy varchar2,
                       step in number  ) is

args       varchar2(255);
request_id number;
itemtype   varchar2(8);
itemkey    varchar2(240);
actid      number;
result     varchar2(30);

firstcolon  number;
rid         number;

rslt     number;
sname    varchar2(50);
ename    varchar2(30);
sflag    varchar2(1);
wflag    varchar2(1);
fflag    varchar2(1);
arg2     varchar2(255);
arg3     varchar2(255);
arg4     varchar2(255);
arg5     varchar2(255);
arg6     varchar2(255);
arg7     varchar2(255);
arg8     varchar2(255);
arg9     varchar2(255);
arg10    varchar2(255);

phase varchar2(80);
stat  varchar2(80);
devphase varchar2(20);
msg   varchar2(2000);
req_stat boolean;
error_text varchar2(2000);

begin

     -- NOTE: this is executed by the concurrent manager when the initial request is COMPLETED
     -- from inside conc manager, get the request_id
     FND_PROFILE.get('CONC_REQUEST_ID',request_id);

     --retrieve the argument list.
     rslt:=fnd_conc_pp.retrieve(req_id => request_id,
                          step => callback.step,
                          app_short_name =>sname,
                          exec_name=>ename,
                          s_flag => sflag,
                          w_flag => wflag,
                          f_flag => fflag,
                          arg1 => args,
             arg2 => arg2, arg3 => arg3, arg4 => arg4, arg5 => arg5, arg6 => arg6,
             arg7 => arg7, arg8 => arg8, arg9 => arg9, arg10 => arg10);


     -- args has format itemtype:itemkey:actid
     firstcolon  := instr(args,':');
     itemtype := substr(args,1, firstcolon-1);
     itemkey  := substr(args,firstcolon+1);
     actid    := to_number(arg2);

     begin
	if arg3 = 'S' then
	   result:= 'NORMAL';
	elsif arg3 = 'F' then
	   result:= 'ERROR';
	elsif arg3 = 'W' then
	   result:= 'WARNING';
	end if;

        savepoint wf_savepoint;
        --complete activity inline. If user wants to defer the thread, they
        --should set cost above theshold.
        --wf_engine.threshold := -1;
        Wf_Engine_Util.Complete_Activity(itemtype, itemkey, actid, result, FALSE);
      exception
        when others then
          -- If anything in this process raises an exception:
          -- 1. rollback any work in this process thread
          -- 2. set this activity to error status
          -- 3. execute the error process (if any)
          -- 4. clear the error to continue with next activity
          rollback to wf_savepoint;
          Wf_Core.Context('Fnd_Wf_Standard', 'Callback', itemtype,
              itemkey, actid, result);
          Wf_Item_Activity_Status.Set_Error(itemtype,
              itemkey, actid, wf_engine.eng_exception, FALSE);
          Wf_Engine_Util.Execute_Error_Process(itemtype,
              itemkey, actid, wf_engine.eng_exception);
          Wf_Core.Clear;
     end;


     commit;
exception
  when others then
    Wf_Core.Context('FND_WF_STANDARD', 'Callback', itemtype, itemkey);
    raise;


END callback;

END FND_WF_STANDARD;

/
