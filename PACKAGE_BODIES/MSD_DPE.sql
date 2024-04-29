--------------------------------------------------------
--  DDL for Package Body MSD_DPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_DPE" AS
/* $Header: msddpprb.pls 120.0 2005/05/25 20:25:29 appldev noship $ */

    -- Constants

    INFORMATION Constant varchar2(30):='INFORMATION';
    HEADING     Constant varchar2(30):='HEADING';
    SECTION     Constant varchar2(30):='SECTION';

    -- USED BY DISPLAY_MESSAGE
    --
    l_last_msg_type varchar2(30);


 /* Overloaded method. Added so that defaults could be removed,
  * for performance reasons.
  */

 procedure Purge (errbuf out nocopy varchar2,
                  retcode out nocopy varchar2,
                  PlanID in varchar2,
		  Demand_Plan_Name in varchar2,
		  Shared_DB_Prefix in varchar2,
		  Code_Location in varchar2,
		  Shared_DB_Location in varchar2,
		  Express_Machine_Port in varchar2,
	  	  OWA_Virtual_Path_Name in varchar2,
		  EAD_Name in varchar2,
		  Express_Connect_String in varchar2,
		  DelIfWFActive in varchar2) is
 begin
           Purge (errbuf 			=> errbuf,
                  retcode 			=> retcode,
                  PlanID 			=> PlanID,
		  Demand_Plan_Name 		=> Demand_Plan_Name,
		  Shared_DB_Prefix 		=> Shared_DB_Prefix,
		  Code_Location 		=> Code_Location,
		  Shared_DB_Location 		=> Shared_DB_Location,
		  Express_Machine_Port 		=> Express_Machine_Port,
	  	  OWA_Virtual_Path_Name 	=> OWA_Virtual_Path_Name,
		  EAD_Name 			=> EAD_Name,
		  Express_Connect_String 	=> Express_Connect_String,
		  DelIfWFActive 		=> DelIfWFActive,
                  DelIfconFail 			=> 'NO');

           /* update the build refresh num if the plans are deleted. */

           if (nvl(retcode, '0') <> '2') then

             update msd_demand_plans
             set dp_build_refresh_num = null,
                 dp_build_error_flag = null
             where demand_plan_id = PlanID;

           end if;

  end;


--
-- Purge (PUBLIC)
--
-- 1.Checks the state for the plan to be deleted.
-- 2.If plan doesn't have Active process
-- 	delets all DPE databases and all obsolete workfdlow data for current plan.
-- 3.Removes validation status for this plan (DPE_BUILD field in MSD_DEMAND_PLANS table).
-- 4.Populates log file with the process's messages.
--
-- IN
--   number of msd_demand_plans_v columns -	PlanID ,
--		    	  		        Shared_DB_Prefix ,
--		    	  		        Code_Location,
--		    	  			Shared_DB_Location,
--		    	  			Express_Machine_Port,
--	  	    	  			OWA_Virtual_Path_Name,
--		    	  			EAD_Name,
--		    	  			Express_Connect_String
--
--  DeleteAnyway - depends on 'Delete even Plan has an Active process' checkbox in
--                 the Purge plan dialog box. Values:
--                 YES - checkbox is checked,
--                 NO  - checkbox is unchecked
-- OUT
--   errbuf -  error message : process or PL/SQL error
--   retcode - return code (0 = success, 2 = error)
--
--
procedure Purge (errbuf out nocopy varchar2,
                  retcode out nocopy varchar2,
                  PlanID in varchar2,
		  Demand_Plan_Name in varchar2,
		  Shared_DB_Prefix in varchar2,
		  Code_Location in varchar2,
		  Shared_DB_Location in varchar2,
		  Express_Machine_Port in varchar2,
	  	  OWA_Virtual_Path_Name in varchar2,
		  EAD_Name in varchar2,
		  Express_Connect_String in varchar2,
		  DelIfWFActive in varchar2,
                  DelIfconFail in varchar2)

    IS
    ItemType   varchar2(20);
    CurrStatus varchar2(20);
    retText     varchar2(200);
    planName varchar2(100);
    dispMesg varchar2(500);
    ActRetcode varchar2(10);
    ExpRetcode varchar2(10);
    WfRetcode varchar2(10);

    pos number;

    ERROR       Constant varchar2(30):='ERROR';
    INFORMATION Constant varchar2(30):='INFORMATION';
    SECTION     Constant varchar2(30):='SECTION';
    SPLPROB_NODEL EXCEPTION;
    PROBWF_NODEL EXCEPTION;
BEGIN

	errbuf := ' ';

	-- get current plan's name
	planName := Demand_Plan_Name;

	dispMesg := 'Beginning Purge for demand plan ' || planName || ' (Plan ID = ' || PlanID || ').';
	MSD_DPE.display_message(dispMesg , SECTION);

--
if ((DelIfWFActive = 'YES') and (DelIfconFail = 'YES')) then

   -- delete all databases for this plan if no one in use
   dispMesg := 'Deleting Express Demand Planning Engine databases.';
   MSD_DPE.display_message(dispMesg , INFORMATION);

   MSD_DPE.DeleteBuildDBS(errbuf, retText, ExpRetcode,
			  inPlan => PlanID,
			  Demand_Plan_Name => Demand_Plan_Name,
		    	  Shared_DB_Prefix => Shared_DB_Prefix,
	    	  	  Code_Location => Code_Location,
	    	  	  Shared_DB_Location => Shared_DB_Location,
 	    	  	  Express_Machine_Port => Express_Machine_Port,
  	    	  	  OWA_Virtual_Path_Name => OWA_Virtual_Path_Name,
	    	  	  EAD_Name => EAD_Name,
	    	  	  Express_Connect_String => Express_Connect_String);

   if ExpRetcode = '2' or ExpRetcode = '1' then
      retcode := '1';
      --dispMesg := errbuf || retText;
	MSD_DPE.display_error_warning(errbuf, retText);
      errbuf := ' ';
   else
      retcode := '0';
   end if;

   -- purge all obsolete workfdlow data for current plan.
   dispMesg := 'Purging Workflow Processes.';
   MSD_DPE.display_message(dispMesg , INFORMATION);

   MSD_DPE.DeleteWorkflow (errbuf, WfRetcode, PlanID);
   -- Warning when DelIfWFActive = 'YES'
   if WFRetCode = '2' then
      retcode := '1';
      dispMesg := errbuf;
      MSD_DPE.display_message(dispMesg , INFORMATION);
      errbuf := ' ';
   end if;

 dispMesg := 'End of Purge processing.';
 MSD_DPE.display_message(dispMesg , SECTION);
 -- RETURN HERE!
 return;
 end if;

--

 if ((DelIfWFActive = 'NO') and (DelIfconFail = 'NO')) then

   dispMesg := 'Checking for active Workflow Processes.';
   MSD_DPE.display_message(dispMesg , INFORMATION);
   MSD_DPE.ActivityTest(errbuf, ActRetcode, PlanID);

 	if ActRetCode = '2' then
         retcode := '2';
         dispMesg := errbuf;
         errbuf := ' ';
      else
           retcode := '0';
	   -- delete all databases for this plan if no one in use

	   dispMesg := 'Deleting Express Demand Planning Engine databases.';
	   MSD_DPE.display_message(dispMesg , INFORMATION);

	   MSD_DPE.DeleteBuildDBS(errbuf, retText, ExpRetCode,
				  inPlan => PlanID,
				  Demand_Plan_Name => Demand_Plan_Name,
			    	  Shared_DB_Prefix => Shared_DB_Prefix,
		    	  	  Code_Location => Code_Location,
		    	  	  Shared_DB_Location => Shared_DB_Location,
		    	  	  Express_Machine_Port => Express_Machine_Port,
	  	    	  	  OWA_Virtual_Path_Name => OWA_Virtual_Path_Name,
		    	  	  EAD_Name => EAD_Name,
                   	  	  Express_Connect_String => Express_Connect_String);

	   if ExpRetcode = '2' then
            retcode := '2';
		MSD_DPE.display_error_warning(errbuf, retText);
            errbuf := ' ';
            raise SPLPROB_NODEL;
         else
            if ExpRetCode = '1' then
               retcode := '1';
               MSD_DPE.display_error_warning(errbuf, retText);
               errbuf := ' ';
            else
                retcode := '0';
            end if;

            -- purge all obsolete workfdlow data for current plan.
	      dispMesg := 'Purging Workflow Processes.';
	      MSD_DPE.display_message(dispMesg , INFORMATION);

            MSD_DPE.DeleteWorkflow (errbuf, WfRetcode, PlanID);

            if WFRetCode = '2' then
               retcode := '2';
               dispMesg := errbuf;
               MSD_DPE.display_message(dispMesg , INFORMATION);
               errbuf := ' ';
               raise PROBWF_NODEL;
            end if;

	end if;
    end if;

    dispMesg := 'End of Purge processing.';
    MSD_DPE.display_message(dispMesg , SECTION);
    -- RETURN HERE!
    return;
  end if;

--
--

 if ((DelIfWFActive = 'NO') and (DelIfconFail = 'YES')) then

   dispMesg := 'Checking for active Workflow Processes.';
   MSD_DPE.display_message(dispMesg , INFORMATION);
   MSD_DPE.ActivityTest(errbuf, ActRetcode, PlanID);

 	if ActRetCode = '2' then
           retcode := '2';
        else
           retcode := '0';
	   -- delete all databases for this plan if no one in use

	   dispMesg := 'Deleting Express Demand Planning Engine databases.';
	   MSD_DPE.display_message(dispMesg , INFORMATION);

	   MSD_DPE.DeleteBuildDBS(errbuf, retText, ExpRetCode,
				  inPlan => PlanID,
				  Demand_Plan_Name => Demand_Plan_Name,
			    	  Shared_DB_Prefix => Shared_DB_Prefix,
		    	  	  Code_Location => Code_Location,
		    	  	  Shared_DB_Location => Shared_DB_Location,
		    	  	  Express_Machine_Port => Express_Machine_Port,
	  	    	  	  OWA_Virtual_Path_Name => OWA_Virtual_Path_Name,
		    	  	  EAD_Name => EAD_Name,
                   	  	  Express_Connect_String => Express_Connect_String);

          if ExpRetcode = '2' or ExpRetcode = '1' then
            retcode := '1';
            --dispMesg := errbuf || retText;
		MSD_DPE.display_error_warning(errbuf, retText);
            errbuf := ' ';
          else
            retcode := '0';
          end if;

          -- purge all obsolete workfdlow data for current plan.
          dispMesg := 'Purging Workflow Processes.';
          MSD_DPE.display_message(dispMesg , INFORMATION);

          MSD_DPE.DeleteWorkflow (errbuf, WfRetcode, PlanID);

          if WFRetCode = '2' then
             retcode := '2';
             dispMesg := errbuf;
             MSD_DPE.display_message(dispMesg , INFORMATION);
             errbuf := ' ';
             raise PROBWF_NODEL;
          end if;

	end if;

    dispMesg := 'End of Purge processing.';
    MSD_DPE.display_message(dispMesg , SECTION);
    -- RETURN HERE!
    return;
  end if;

--
--

if ((DelIfWFActive = 'YES') and (DelIfconFail = 'NO')) then

   -- delete all databases for this plan if no one in use
   dispMesg := 'Deleting Express Demand Planning Engine databases.';
   MSD_DPE.display_message(dispMesg , INFORMATION);

   MSD_DPE.DeleteBuildDBS(errbuf, retText, ExpRetcode,
			  inPlan => PlanID,
			  Demand_Plan_Name => Demand_Plan_Name,
		    	  Shared_DB_Prefix => Shared_DB_Prefix,
	    	  	  Code_Location => Code_Location,
	    	  	  Shared_DB_Location => Shared_DB_Location,
 	    	  	  Express_Machine_Port => Express_Machine_Port,
  	    	  	  OWA_Virtual_Path_Name => OWA_Virtual_Path_Name,
	    	  	  EAD_Name => EAD_Name,
	    	  	  Express_Connect_String => Express_Connect_String);

   if ExpRetcode = '2' then
        retcode := '2';
	  MSD_DPE.display_error_warning(errbuf, retText);
        errbuf := ' ';
        raise SPLPROB_NODEL;
   else

       if ExpRetCode = '1' then
          retcode := '1';
 	    MSD_DPE.display_error_warning(errbuf, retText);
          errbuf := ' ';
       else
          retcode := '0';
       end if;

       -- purge all obsolete workfdlow data for current plan.
      dispMesg := 'Purging Workflow Processes.';
      MSD_DPE.display_message(dispMesg , INFORMATION);

      MSD_DPE.DeleteWorkflow (errbuf, WfRetcode, PlanID);

      if WFRetCode = '2' then
         retcode := '1';
         dispMesg := errbuf;
         MSD_DPE.display_message(dispMesg , INFORMATION);
         errbuf := ' ';
      end if;

   end if;

  dispMesg := 'End of Purge processing.';
  MSD_DPE.display_message(dispMesg , SECTION);
  -- RETURN HERE!
  return;
end if;
--
--
 exception

   when SPLPROB_NODEL then
    retcode :='2';

    dispMesg := 'The demand plan databases have not been deleted.';
    MSD_DPE.display_message(dispMesg , INFORMATION);

    dispMesg := 'End of Purge processing.';
    MSD_DPE.display_message(dispMesg , SECTION);

    dispMesg := 'The demand plan was not deleted.';
    MSD_DPE.display_message(dispMesg , SECTION);
    errbuf:= ' ';


   when PROBWF_NODEL then
    retcode :='2';
    dispMesg := 'Problem encountered when purging Workflow processes.';
    MSD_DPE.display_message(dispMesg , INFORMATION);

    dispMesg := 'End of Purge processing.';
    MSD_DPE.display_message(dispMesg , SECTION);

    dispMesg := 'The demand plan was not deleted.';
    MSD_DPE.display_message(dispMesg , SECTION);
    errbuf:= ' ';


   when others then

    errbuf:=substr(sqlerrm, 1, 255);

    dispMesg := errbuf;
    MSD_DPE.display_message(dispMesg , INFORMATION);

   -- dispMesg := 'The demand plan databases have not been deleted.';
   -- MSD_DPE.display_message(dispMesg , INFORMATION);

    dispMesg := 'End of Purge processing.';
    MSD_DPE.display_message(dispMesg , SECTION);

    if ((DelIfWFActive = 'NO') or (DelIfconFail = 'NO')) then
        retcode :='2';
        dispMesg := 'The demand plan was not deleted.';
        MSD_DPE.display_message(dispMesg , SECTION);
    else
        retcode :='1';
    end if;
    errbuf:= ' ';

--     raise;

end Purge;


--
-- ActivityTest (PUBLIC)
--
-- 1. Selects all ItemKeys(instances) for current planID and checks if
--    any ACTIVITY_STATUS for each ItemKey is ACTIVE.
-- IN
--   PlanID -  ID of Plan to be deleted
-- OUT
--   errbuf -  error message : 'Process is ACTIVE' or PL/SQL error
--   retcode - return code (0 = success, 2 = error)
--
--

PROCEDURE ActivityTest (errbuf out nocopy varchar2,
			 retcode out nocopy varchar2,
		         inPlan  in number)
   IS
    itemType   varchar2(20);
    CurrStatus varchar2(200);
    result     varchar2(200);
    -- agb 01/21/02 added for select below
    inplanTXT  varchar2(16);



    CURSOR c_ItemKeys is
	select item_key
	   from WF_ITEM_ATTRIBUTE_VALUES
	   where item_type = itemType
	   and   name = 'ODPPLAN'
	   and   text_value = inPlanTXT;

    v_ItemKey c_ItemKeys%ROWTYPE;

BEGIN

    -- agb 01/21/02 convert to text for some selects
    inplanTXT := to_char(inPlan);

    itemType := 'ODPCYCLE';
    retcode := '0';

    -- Check activity process for current plan
    for  v_ItemKey in c_ItemKeys loop
	wf_engine.ItemStatus(itemType, v_ItemKey.item_key, currStatus, result);
	if RTRIM(currStatus) = 'ACTIVE' then
	   retcode := '2';
	   errbuf:='Cannot purge. The plan has an ACTIVE Workflow Process.';
	   exit;
	else
	   retcode := '0';
	end if;
    end loop;

      return;

  exception
   when NO_DATA_FOUND then
     retcode :='0';

   when others then
    retcode :='2';
    errbuf:=substr(sqlerrm, 1, 255);

--     raise;

end ActivityTest;


--
-- DeleteBuildDBS (PUBLIC)
--
-- 1. Selects data from MSD_DEMAND_PLANS_V table for the specific planID.
-- 2. Takes selected columns and uses that data to exercise an EPS/SNAPI
--    connection to OES and then, if connection is established,
--    runs ODPDELPLAN activity to run delete plan functionality.

-- IN
--   number of msd_demand_plans_v columns -	PlanID ,
--						Demand_Plan_Name,
--		    	  		        Shared_DB_Prefix ,
--		    	  		        Code_Location,
--		    	  			Shared_DB_Location,
--		    	  			Express_Machine_Port,
--	  	    	  			OWA_Virtual_Path_Name,
--		    	  			EAD_Name,
--		    	  			Express_Connect_String
-- OUT
--   errbuf -  error message : 'Database in use', Express error or PL/SQL error
--   actText out  varchar2,
--   retcode - return code (0 = success, 2 = error)
--
--

PROCEDURE DeleteBuildDBS (errbuf out nocopy varchar2,
		    	  actText out nocopy varchar2,
		    	  retcode out nocopy varchar2,
    		    	  inPlan  in number,
			  Demand_Plan_Name in varchar2,
		    	  Shared_DB_Prefix in varchar2,
		    	  Code_Location in varchar2,
		    	  Shared_DB_Location in varchar2,
		    	  Express_Machine_Port in varchar2,
	  	    	  OWA_Virtual_Path_Name in varchar2,
		    	  EAD_Name in varchar2,
		    	  Express_Connect_String in varchar2)
   IS
    ActEntry     varchar2(16);
    EPSRetErr    varchar2(2000);
    EPSRetcode   varchar2(100);
    EPSRetVal   varchar2(2000);
    EPSRetText   varchar2(2000);
    thisrole     varchar2(30);
    express_server varchar2(240);
    DBName varchar2(80);
    CodeLoc varchar2(240);
    SharedLoc varchar2(240);
    PlName    varchar2(30);
    Owner     varchar2(30);
    DPAdmin   varchar2(30);
    URLret    varchar2(10);
    OESPort   varchar2(80);
    thisURL   varchar2(100);

BEGIN

-- uses inPlan to get Express connection and DPE plan information

    	PlName := Demand_Plan_Name;
	CodeLoc := Code_Location;
	DBName := Shared_DB_Prefix;
	SharedLoc := Shared_DB_Location;
	express_server := Express_Connect_String;
	OESPort := Express_Machine_Port;


-- value activity.entry, points to program in Express
	ActEntry  := 'ODPDELPLAN';
/*
 	 SELECT C0, C1, C2
        into EPSretcode, EPSRetText, EPSRetErr
	from THE (SELECT CAST (EPS.query(express_server,
	'DB0='|| CodeLoc || '/ODPCODE\'
	|| 'DBCount=1\'
	|| 'MeasureCount=3\'
	|| 'Measure0=ACTIVITY.FORMULA\'
	|| 'Measure1= ACTIVITY.TEXT\'
  	|| 'Measure2=ACTIVITY.ERROR\'
	|| 'E0Count=2\'
	|| 'E0Dim0Name=PLACEHOLDER\'
	|| 'E0Dim1Name=ACTIVITY.ENTRY\'
	|| 'E0Dim1Script=CALL WF.SETACTIVITY('''|| ActEntry || ''', '''|| inPlan ||''',  '''|| DBName ||''', '''|| SharedLoc ||''',  '''|| DPAdmin ||''',  '''|| thisrole ||''')\'
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL)
	 AS EPS_express_list_t)
	 from DUAL);
*/
  msd_wf.execute_dml2(ActEntry, inPlan, DBName, SharedLoc,DPAdmin, thisrole,'','',
		'', EPSretcode, EPSRetText, EPSRetVal,EPSRetErr);





-- this means the test succeeded.
         if UPPER(RTRIM(EPSretcode)) = 'Y' then
	    actText := EPSRetText;
            retcode := '0';
         end if;

-- this means the test was completed with warnings.
         if UPPER(RTRIM(EPSretcode)) = 'W' then
	    actText := EPSRetText;
            retcode := '1';
         end if;

-- this means the test failed.  There was an error inside an Express program!
         if UPPER(RTRIM(EPSretcode)) = 'N' then
            errbuf:=substr(EPSRetErr, 1, 255);
		actText := EPSRetText;
            retcode := '2';
         end if;

       return;

  exception
   when others then

    retcode :='2';
    errbuf:=substr(sqlerrm, 1, 255);
    raise;

end DeleteBuildDBS;


--
-- DeleteWorkflow (PUBLIC)
--
-- 1. Selects all ItemKeys(instances) for current planID and checks if
--    any ACTIVITY_STATUS for each ItemKey is ACTIVE.
-- 2. Purge obsolete workflow depending on ACTIVITY_STATUS.
-- IN
--   PlanID -  ID of Plan to be deleted
-- OUT
--   errbuf -  error message : 'Process is ACTIVE' or PL/SQL error
--   retcode - return code (0 = success, 2 = error)
--
--
procedure DeleteWorkflow (errbuf out nocopy varchar2,
		    	retcode out nocopy varchar2,
                    	inPlan  in number)
   IS
    ItemType   varchar2(20);
    CurrStatus varchar2(20);
    result     varchar2(100);
    -- agb 01/21/02 added for select below
    inplanTXT  varchar2(16);


    CURSOR c_ItemKeys is
	select item_key
	   from WF_ITEM_ATTRIBUTE_VALUES
	   where item_type = itemType
	   and   name = 'ODPPLAN'
	   and   text_value = inPlanTXT;

    v_ItemKey c_ItemKeys%ROWTYPE;


BEGIN
    -- agb 01/21/02 convert to text for some selects
    inplanTXT := to_char(inPlan);
    ItemType := 'ODPCYCLE';
    retcode := '0';

-- Check activity process for current plan
    for  v_ItemKey in c_ItemKeys loop

	wf_engine.ItemStatus(itemType, v_ItemKey.item_key, currStatus, result);

	if  UPPER(RTRIM(currStatus)) = 'COMPLETE' then
	    WF_PURGE.Total(itemType, v_ItemKey.item_key);
	elsif UPPER(RTRIM(currStatus)) = 'ERROR' or UPPER(RTRIM(currStatus)) = 'ACTIVE' then
	    WF_ENGINE.AbortProcess(itemType, v_ItemKey.item_key);
	    WF_PURGE.Total(itemType, v_ItemKey.item_key);
	elsif UPPER(RTRIM(currStatus)) = 'SUSPENDED' then
	    NULL;
	else
	   retcode := '2';
	   errbuf:='Plan has an ACTIVE process and Workflow cannot be deleted.';
--	   exit;
	end if;

      end loop;

      return;

  exception

   when NO_DATA_FOUND then
     retcode :='0';

   when others then
    retcode :='2';
    errbuf:=substr(sqlerrm, 1, 255);

--     raise;

end DeleteWorkflow;


--
-- Display_Message (PUBLIC)  - this procedure was taken from msd_validate_demand_plan_new
--
-- 1. Populates log file with passed messages .
--
-- IN
--   p_text -  text of the message
--   msg_type - the message's location definition
--
--

Procedure display_message(p_text in varchar2, msg_type in varchar2) is

        l_tab           varchar2(4):='    ';
        L_MAX_LENGTH    number:=90;

BEGIN
        if msg_type = SECTION then
            if nvl(l_last_msg_type, 'xx') <> SECTION then
                show_message('');
            end if;
            show_message( substr(p_text, 1, L_MAX_LENGTH) );
        elsif msg_type in (INFORMATION, HEADING) then
            show_message( l_tab || substr(p_text, 1, L_MAX_LENGTH));
        else
            show_message( l_tab || rpad(p_text, L_MAX_LENGTH) || ' ' || msg_type);
        end if;

         l_last_msg_type := msg_type;

End display_message;


--
-- Show_Message (PUBLIC)  - this procedure was taken from msd_validate_demand_plan_new
--
-- 1. Populates log file with passed messages .
--
-- IN
--   p_text -  text of the message
--

 Procedure show_message(p_text in varchar2) is

BEGIN

  if (p_text is not NULL) then
    fnd_file.put_line(fnd_file.log, p_text);
  end if;

END;

/* Wrapper to call DeleteWorkflow from Express SPL named odpwf.cleanup. */
Procedure CallDelWF(inPlan  in number) is

retcode  varchar2(2);
errbuf   varchar2(100);

BEGIN
MSD_DPE.DeleteWorkflow(errbuf, retcode, inPlan);
return;

exception
   when others then
     RAISE_APPLICATION_ERROR(-20100, 'Error in MSD_DPE.CallDelWF');
END;

--+++++++++++++++++++++++++++++++++++++++++
--
-- display_error_warning(PUBLIC)
--
-- 1. Displays error/warning message returned by the DML procedure.
--    The symbols '++' are using as separators to divide too long messages in pieces.
-- IN
--   errbuf -  system part of error message.
--   retText - ODP's description of current error.
--
Procedure display_error_warning(errbuf in varchar2, retText in varchar2) is

pos  number;
dispMesg varchar2(500);
messageText varchar2(500);

BEGIN

dispMesg := errbuf;
MSD_DPE.display_message(dispMesg , INFORMATION);

messageText := retText;

if (messageText is not NULL) then
  --check if retText is too long and has a '++' separator,
  pos := instr(messageText, '++');
  while pos > 0 loop
    dispMesg := substr(messageText, 1, pos-1);
    MSD_DPE.display_message(dispMesg , INFORMATION);
    messageText := substr(messageText, pos+2);
    pos := instr(messageText, '++');
  end loop;

  dispMesg := messageText;
  MSD_DPE.display_message(dispMesg , INFORMATION);
end if;

return;

END;

--+++++++++++++++++++++++++++++++++++++++++


end MSD_DPE;

/
