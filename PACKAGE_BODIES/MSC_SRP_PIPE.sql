--------------------------------------------------------
--  DDL for Package Body MSC_SRP_PIPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_SRP_PIPE" AS
-- $Header: MSCRPLNB.pls 120.5.12010000.2 2008/06/27 22:44:46 hulu ship $

PLANNER_READY		constant number :=6;
PLANNER_STARTED		constant number :=8;
PLANNER_ERROR		constant number :=9;
LOAD_FILE		constant number :=1;
LOAD_ITEM		constant number :=11;
LOAD_SUPPLY		constant number :=12;
LOAD_DEMAND		constant number :=13;
LOAD_BOM		constant number :=14;
DELETING		constant number :=3;
SELECT_DATA		constant number :=2;
REPLANNING		constant number :=4;
FLUSHING		constant number :=5;

SRP_FORECASTING       constant number:=20;
SRP_LOAD_ITEM         constant number:=21;
SRP_REPLANNING	      constant number:=22;
SRP_PEGGING           constant number:=23;
SRP_FLUSHING          constant number:=24;
SRP_DELETING          constant number:=25;
SRP_NOTHING_TO_REPLAN constant number:=26;
SRP_OLP_ERROR         constant number:=28;
SRP_OLP_COMPLETE      constant number:=27;



/*
REM Currently, in DRP/ASCP, this is the list of command code engine accept
REM #define OLP_REPLAN  2
REM #define OLP_PING    4
REM #define OLP_EXIT    5

REM Currently, in DRP/ASCP, replan engine returns following status code
REM to indicate planner status.
REM #define OLP_READY   6
REM #define OLP_INFO    7    ---> this status returns with two additional number
REM 			 ---> num#1 --> current milestone
REM 			 ---> num#2 --> percentage of completion in this stage, not total
REM #define OLP_STARTED 8
REM #define OLP_ERROR   9

REM Planner can be return following stage code in OLP_INFO
REM #define OLP_LOAD_FILES  1
REM #define OLP_LOAD_ITEMS  11
REM #define OLP_LOAD_SUPPLY  12
REM #define OLP_LOAD_DEMAND  13
REM #define OLP_LOAD_BOM  14
REM #define OLP_SELECT_DATA 2
REM #define OLP_DELETING    3
REM #define OLP_REPLANNING  4
REM #define OLP_FLUSHING    5

REM /*
REM Currently, in DRP/ASCP UI (MSCFNSIM.pld), it has 4 timer
REM 1. start_olp_timer,which is started when CP is sbumit and before got OLP_READY code
REM 2. ready_olp_timer,which is started once engine return OLP_READY -- engine is ready for replan request
REM 3. planing_olp_timer,which is started once submit replan reqest
REM 3. stop_olp_times, which is started when stop command is sent
REM
REM The normal way to get the status from engine is to
REM 1. ping engine in outpipe  with comamnd=4
REM 2. read iputpipe to get engine return. Engine could return (6,7,8,9)

REM #OLP_Ready ==>100%
REM /* this procedure is called from java servlet once user click ok button in replan option window
REM in DRP/ASCP,planner could be in stage (started,ready,plan,error stage). user can only submit request
REM if it is in ready status. but in srp, there is only 1 menu for user, so ui code need to start cp(if
REM it is not currently started, submit replan request only after planner is in ready status)
REM
REM ping engine, if engine return the following code
REM #define OLP_READY   6   ===> replan is 100% finished. (??? is this true)
REM #define OLP_ERROR   9   ===> replan is 100% finished. with error. (milestone=Error,percentage=100%)
REM #define OLP_INFO    7   ===> show milestone=??, percentage=??
REM #define OLP_STARTED 8
REM */

/*this procedure is called by servlet periodically.
REM p_error_code =-1 -->pipe error
REM p_error_code =0  --> normal status
REM p_error_code =2  -->no planner
REM p_stage_code  --> return the stage code of the planner
REM p_pcnt  -->percentage of completion
*/

Procedure get_replan_progress(p_request_id in number,
			      p_outPipe in varchar2,
                              p_inPipe in varchar2,
			      p_error_code out nocopy number,
			      p_stage_code out nocopy number,
			      p_pcnt   out nocopy number) is

l_engine_ping_return_code  number;  -- (6.7.8.9)
l_engine_stage_code number;  -- (6,8,9,1,2,3,4,5,11,12,13,14)
l_engine_percentage number;   --  (only if ping return 7)
l_cp_status number;

begin



     p_error_code :=0 ; --- normal status
     p_stage_code :=-99 ;--- not a valid stage code
     p_pcnt       :=-1;   --- no change from previous percentage



     ---dbms_pipe.purge(p_outPipe); --
     dbms_pipe.pack_message(4);  ---
     if (dbms_pipe.send_message(p_outPipe,0,8192)) =3 then   ---
        p_error_code:=-1 ;-- pipe error
	return;
     end if;

     if (DBMS_PIPE.RECEIVE_MESSAGE(p_inPipe,0) in (2,3) )then
         p_error_code :=-1;
	 return;
     else

       dbms_pipe.unpack_message(l_engine_ping_return_code);
       if (l_engine_ping_return_code is null) then

	  -- this could be that engine is not running or
	  -- does not reponse ping
	  -- need to check cp status
	  -- if it is not running, p_error_code=2;
        if (check_cp_status(p_request_id,l_cp_status) =0) then
	     if (l_cp_status in (0,1)) then
	        p_error_code :=2 ;    ---- no planner
	     elsif (l_cp_status =-1) then
	        p_error_code :=0 ;   --- make sure p_error_code =0
	        p_pcnt       :=1;
                p_stage_code :=SRP_OLP_ERROR;
	     end if;
	     return;
        end if;
       elsif (l_engine_ping_return_code = 6 ) then
	   p_stage_code :=PLANNER_READY;
       elsif (l_engine_ping_return_code =8) then
	    p_stage_code :=PLANNER_STARTED;
       elsif (l_engine_ping_return_code =9) then
	    p_stage_code :=PLANNER_ERROR;
       elsif (l_engine_ping_return_code=7) then

       dbms_pipe.unpack_message(l_engine_stage_code);
       dbms_pipe.unpack_message(l_engine_percentage);

	    p_pcnt :=l_engine_percentage;
	    if (l_engine_stage_code =1) then
	       p_stage_code :=LOAD_FILE;
	    elsif (l_engine_stage_code=11) then
	        p_stage_code:=LOAD_ITEM;
	    elsif (l_Engine_stage_code=12) then
	        p_stage_code:=LOAD_SUPPLY;
	    elsif (l_engine_stage_code=13) then
	        p_stage_code:=LOAD_DEMAND;
	    elsif (l_engine_stage_code=14) then
	        p_stage_code:=LOAD_BOM;
	    elsif (l_engine_stage_code=2) then
	        p_stage_code:=SELECT_DATA;
	    elsif(l_engine_stage_code=3) then
	        p_stage_code:=DELETING;
	    elsif (l_Engine_stage_code=4) then
	        p_stage_code:=REPLANNING;
	    elsif(l_engine_stage_code=5) then
	        p_stage_code:=FLUSHING;
	    elsif (l_engine_stage_code=20) then
                p_stage_code:=SRP_FORECASTING;
            elsif (l_engine_stage_code=21) then
                p_stage_code:=SRP_LOAD_ITEM;
            elsif(l_engine_stage_code=22) then
                p_stage_code:=SRP_REPLANNING;
            elsif (l_Engine_stage_code=23) then
                p_stage_code:=SRP_PEGGING;
            elsif(l_engine_stage_code=24) then
                p_stage_code:=SRP_FLUSHING;
	    elsif(l_engine_stage_code=25) then
                p_stage_code:=SRP_DELETING;
	    elsif(l_engine_stage_code=26) then
                p_stage_code:=SRP_NOTHING_TO_REPLAN;

            end if;
            if (p_pcnt =1) then
	        p_stage_code:=SRP_OLP_COMPLETE;
	     end if;

        end if;
     end if;

exception
   when others then
       if (check_cp_status(p_request_id,l_cp_status) =0) then
	  if (l_cp_status in (0,1)) then
	        p_error_code :=2 ;    ---- no planner
		return;
	   elsif (l_cp_status =-1) then
	       p_error_code :=0 ;   --- make sure p_error_code =0
	       p_pcnt       :=1;
               p_stage_code :=SRP_OLP_ERROR;
	   else
	       p_error_code :=0;
	   end if;

      end if;

   -- return;


end get_replan_progress;



Function load_pipe( p_pipeName in varchar2,
                    p_msg      in varchar2) return number is

l_reStatus number;
begin
    DBMS_PIPE.PACK_MESSAGE(p_msg);

    l_reStatus := DBMS_PIPE.SEND_MESSAGE(p_pipeName,
                                         1000,
                                        8192);


   --- possible returns are
   --  0 --> successfully
   --  1 --> time out
   --  3 --> internal error

     return l_reStatus;

END load_pipe;

/*
possible return are:
1. message in the pipe;
2. PIPE_ERROR if internal error while read pipe
3. null if there is no message in the pipe;
*/

Function read_pipe(p_pipeName in varchar2) return varchar2 is
l_msg varchar2(512) := NULL;
l_reStatus number;
begin
   l_reStatus := DBMS_PIPE.RECEIVE_MESSAGE(p_pipeName,0);
   --- possible return of dbms_pipe.receive_message are
   --- 0 --> successfully
   --- 1 --> time out
   --- 2 --> message is too large. internal error
   --- 3 --> internal error

   IF l_reStatus = 0 THEN
   DBMS_PIPE.UNPACK_MESSAGE(l_msg);
   elsif (l_reStatus =2 ) OR (l_reStatus =3) then
      l_msg := 'PIPE_ERROR';
   END IF;
   return l_msg;
END read_pipe;


/* check concurrent request status by calling fnd_concurrent.get_request_status
   possible return from fnd_concurrent.get_request_status are
   dev_phase: Running(R),Pending(P),Complete(C),Inactive(I);
------------------------------------
   dev_status:   Normal(R)
                 Terminating(T)
                 Waiting(A)
                 Resuming(B)
-------------------------------------
                 Normal(I)      -->pending normal
                 Standby(Q)     -->pending due to  incompatabilities
                 Scheduled(F)   -->
                 Paused(W)
------------------------------------
                 ON_HOLD(H)     -->Inactive onhold
                 Suspended(S)
                 Disabled(D)
                 No_manager(M)
------------------------------------
                 Normal(C)
                 Warning(G)    --->Completed with warning
                 Error(E)      --->Completed with Error
                 Terminated(X)    -->Terminated



return:
   -1   --> request is completed with error or is terminated
   0    --> not running
   1    --> inactive
   2    --> pending
   3    --> running

*/


/* The function is better to return a BOOLEAN, however, since we can
   not pass Types.BOOLEAN from jdbc to PLSQL. it returns number instead
   -1   -->FALSE
    0  --> TRUE
*/
Function check_cp_status(p_request_id in number,p_status out NOCOPY number) return number is

l_phase varchar2(80);
l_status varchar2(80);
l_dev_phase varchar2(30);
l_dev_status varchar2(30);
l_msg varchar2(255);
l_st number ;
l_request_id number :=p_request_id;

cursor c_child_req (p_parent_req_id number) is
       select request_id from Fnd_Concurrent_Requests
       where parent_request_Id = p_parent_req_id;


begin

   if (FND_CONCURRENT.GET_REQUEST_STATUS(request_id=>l_request_id,
                                          appl_shortname=>'',
                                          program =>'',
                                          phase=>l_phase,
                                          status=>l_status,
                                          dev_phase=>l_dev_phase,
                                          dev_status=>l_dev_status,
                                          message=>l_msg) = TRUE) then
       if (l_dev_phase = 'RUNNING' ) then
           if ( l_dev_status = 'TERMINATING') THEN   l_st := 0;
           else l_st :=3;
           end if;
       elsif (l_dev_phase ='INACTIVE')  then
             l_st :=1;
       elsif (l_dev_phase = 'PENDING' ) then
             l_St :=2 ;
       elsif (l_dev_phase='COMPLETE')   then
             if (l_dev_status ='ERROR')  OR (l_dev_status = 'TERMINATED') then
                       -- cp completes with errors or is terminated
                       -- we may need to set plan_completion_date to null
                 l_st :=-1;
             else
                 l_st:=0;
             end if;
       end if;

          -- check each child request. if any of the child request is in inactive status
          -- then set the l_st :=1;

       for cur in c_child_req(l_request_id) loop
           if (FND_CONCURRENT.GET_REQUEST_STATUS(request_id=>cur.request_id,
                                                appl_shortname=>'',
                                                program =>'',
                                                phase=>l_phase,
                                                status=>l_status,
                                                dev_phase=>l_dev_phase,
                                                dev_status=>l_dev_status,
                                                 message=>l_msg) = TRUE) then
              if  (l_dev_phase ='INACTIVE')    then
                   l_st :=1;  --Inactive
                   exit;
              end if;
            else
              return -1;
              exit;
            end if;
        end loop;
   else
       return -1;
   end if;
   p_status := l_st;
   return 0;

end check_cp_status;

END;



/
