--------------------------------------------------------
--  DDL for Package Body AD_PA_SUBMIT_REQUEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AD_PA_SUBMIT_REQUEST" as
/* $Header: adpasrb.pls 120.3.12010000.2 2009/03/25 10:26:39 bbhumire ship $ */

-- Procedure to submit InfoBundle Upload Request for Patch Advisor
-- repeatOption is 'yes' if want to recur the request
-- repeatInterval is number of repeatUnit
-- repeatUnit is either MINUTES/HOURS/DAYS/MONTHS
-- repeatEndDate is the end date
-- errMsg is the Error Message

procedure SUBMIT_INFOBUNDLE_REQUEST(
reqId           out NOCOPY number ,
submitDate      in  varchar2,
repeatOption    in  varchar2,
repeatInterval  in  varchar2,
repeatUnit      in  varchar2,
repeatEndDate   in  varchar2,
errMsg          out NOCOPY varchar2
)
is
retVal boolean;
begin
   retVal := true;
   /** Set repeat parameters if want to repeat the request**/
   if ( repeatOption = 'yes' ) then
     retVal := false;
     if (length(repeatInterval) <> 0 ) then
       --if the repeat inteval is not null, then recurr the request after this
       --interval
       retVal := FND_REQUEST.SET_REPEAT_OPTIONS('' , repeatInterval ,repeatUnit
                                                 , 'START', repeatEndDate);
     else
      --if the repeatInteval is null, then recurr the request daily at this time
       --Extract the time  from submitDate
       retVal := FND_REQUEST.SET_REPEAT_OPTIONS(SUBSTR('submitDate' ,
                    - INSTR('submitDate',' ', -8, 1) ,
                      INSTR('submitDate',' ', -8, 1)) , '' , '',
                      'START', repeatEndDate);
     end if;
     if (retval = false) then
       errMsg := fnd_message.get();
       return;
     end if;
   end if;

   --Submit the request
   if (retVal = true) then
      reqId := FND_REQUEST.submit_request ('AD','FND_PAUPLOAD',
              'PatchWizard - Information Bundle Upload',submitDate, FALSE);
   end if;

   -- This is to get the actual error in case concurrent program fails.
   if ( reqId <= 0 ) then
      errMsg := fnd_message.get();
   end if;

   commit;

end submit_infobundle_request;

-- Procedure to submit Patch Upload and Patch Analysis Request set for Patch Advisor
-- pIsAggregate is the flag to determine whether aggregate impact is to be done or not.

procedure submit_patches_request(
reqId          out NOCOPY number,
patchList      in  varchar2,
submitDate     in  varchar2 ,
repeatOption   in  varchar2,
repeatInterval in  varchar2,
repeatUnit     in  varchar2,
repeatEndDate  in  varchar2,
pIsAggregate   in  varchar2,
errMsg         out NOCOPY varchar2
)
is
retVal  boolean;
n0    number;
n3    number;
n5    number;
n10    number;
n20    number;
n30   number;
n35   number;
n40   number;
n50    number;
n60    number;
n65    number;
n70    number;
lRepeatFlag    number := 1;
begin
 /** Set repeat parameters if want to repeat the request **/
   if ( repeatOption = 'yes' ) then
     retVal := false;
     if (length(repeatInterval) <> 0 ) then
       --if the repeat inteval is not null, then recurr the request after this interval
       retVal := FND_SUBMIT.SET_REPEAT_OPTIONS('' , repeatInterval ,repeatUnit, 'START', repeatEndDate);
     else
       --if the repeatInteval is null, then recurr the request daily at this time
       --Extract the time  from submitDate
       retVal := FND_SUBMIT.SET_REPEAT_OPTIONS(SUBSTR('submitDate' ,
                        - INSTR('submitDate',' ', -8, 1) ,
                         INSTR('submitDate',' ', -8, 1)) , '' , '',
                        'START', repeatEndDate);
     end if;
   end if;
   if(retVal = false) then
     lRepeatFlag := -1;
     errMsg := fnd_message.get();
     return;
   end if;

   retVal := FND_SUBMIT.SET_REQUEST_SET('AD','FNDRSSUB1242');
   if ( retVal = true ) then
     n0 := 1;
   else
     errMsg := fnd_message.get();
     return;
   end if;

   -- bug#3984358 Call the PAANALYZEPATCHES wrapper.
   retVal := FND_SUBMIT.SUBMIT_PROGRAM('AD','PAANALYZEPATCHES','STAGE3',patchList);
   if ( retVal = true ) then
     n3 := 1;
   else
     errMsg := fnd_message.get();
     return;
   end if;

   -- bug#3984358 PAPATCHDOWNLOADER is now dummy request. replaced by PAANALYZEPATCHES wrapper.
   retVal := FND_SUBMIT.SUBMIT_PROGRAM('AD','PAPATCHDOWNLOADER','STAGE5',patchList);
   if ( retVal = true ) then
     n5 := 1;
   else
     errMsg := fnd_message.get();
     return;
   end if;

   -- bug#3984358 PATCHUPLOAD is now dummy request. replaced by PAANALYZEPATCHES wrapper.
   retVal := FND_SUBMIT.SUBMIT_PROGRAM('AD','PATCHUPLOAD','STAGE10',patchList);
   if ( retVal = true ) then
     n10 := 1;
   else
     errMsg := fnd_message.get();
     return;
   end if;

   -- bug#3984358 PATCHANALYSIS is now dummy request. replaced by PAANALYZEPATCHES wrapper.
   retVal := FND_SUBMIT.SUBMIT_PROGRAM('AD','PATCHANALYSIS','STAGE20',patchList);
   if ( retVal = true ) then
     n20 := 1;
   else
     errMsg := fnd_message.get();
     return;
   end if;

   retVal := FND_SUBMIT.SUBMIT_PROGRAM('FND','BUILDJSPDEP','STAGE30');
   if ( retVal = true ) then
     n30 := 1;
   else
     errMsg := fnd_message.get();
     return;
   end if;

   retVal := FND_SUBMIT.SUBMIT_PROGRAM('FND','COMPDIAGTESTVER','STAGE35');
   if ( retVal = true ) then
     n35 := 1;
   else
     errMsg := fnd_message.get();
     return;
   end if;

   retVal := FND_SUBMIT.SUBMIT_PROGRAM('FND','ANALYZEIMPACT','STAGE40');
   if ( retVal = true ) then
     n40 := 1;
   else
     errMsg := fnd_message.get();
     return;
   end if;

   retVal := FND_SUBMIT.SUBMIT_PROGRAM('FND','MENUTREEANALYSIS','STAGE50');
   if ( retVal = true ) then
     n50 := 1;
   else
     errMsg := fnd_message.get();
     return;
   end if;

   retVal := FND_SUBMIT.SUBMIT_PROGRAM('FND','ANALYZEIMPACT2','STAGE60');
   if ( retVal = true )
     then n60 := 1;
   else
     errMsg := fnd_message.get();
     return;
   end if;

   -- bug#3984358 Call the Agggregate PIA request with proper values.
   if(pIsAggregate = 'Y') then
     retVal := FND_SUBMIT.SUBMIT_PROGRAM('FND','AGGREGATEIMPACT','STAGE65',null);
   else
     retVal := FND_SUBMIT.SUBMIT_PROGRAM('FND','AGGREGATEIMPACT','STAGE65', -1);
   end if;
   if ( retVal = true )
     then n65 := 1;
   else
     errMsg := fnd_message.get();
     return;
   end if;

   retVal := FND_SUBMIT.SUBMIT_PROGRAM('AD','PWSTATUSTRACKER','STAGE70');
   if ( retVal = true )
     then n70 := 1;
   else
     errMsg := fnd_message.get();
     return;
   end if;

   -- if  ( (n1 = 1 ) and (n1_0 = 1 ) and (n1_1 = 1 ) and (n2 = 1 ) and (n3 = 1 ) and (n4 = 1 ) and (n5 = 1) and (n6 = 1) and (n7 = 1) and (n8 = 1) and (n9 = 1) and (lRepeatFlag = 1)) then
   if  ( (n0 = 1 ) and (n3 = 1 ) and (n5 = 1 ) and (n10 = 1 ) and (n20 = 1 ) and (n30 = 1 ) and (n35 = 1 ) and (n40 = 1 ) and (n50 = 1 ) and (n60 = 1) and (n65 = 1) and (n70 = 1) and (lRepeatFlag = 1)) then
     reqId := FND_SUBMIT.SUBMIT_SET(submitDate);
   else
     reqId := 0;
     errMsg := fnd_message.get();
     return;
   end if;

   -- This is to get the actual error in case concurrent program fails.
   if ( reqId <= 0 ) then
     errMsg := fnd_message.get();
   end if;


commit;

end submit_patches_request;


-- Procedure to submit Analysis Request set for Patch Advisor
-- pIsAggregate is the flag to determine whether aggregate impact is to be done or not.

procedure submit_advisor_request(
reqId            out NOCOPY number,
criteriaId       in  varchar2 ,
submitDate       in  varchar2 ,
repeatOption     in  varchar2,
repeatInterval   in  varchar2,
repeatUnit       in  varchar2,
repeatEndDate    in  varchar2,
pUploadPatchInfo in  varchar2,
pIsAggregate     in  varchar2,
errMsg           out NOCOPY varchar2,
useproducts      in  varchar2
)
is
retVal boolean;
n0    number ;
n3    number ;
n5    number ;
n10   number ;
n20   number ;
n25   number ;
n30   number ;
n40   number ;
n50   number ;
n55   number ;
n60   number ;
lRepeatFlag    number := 1;
begin

   /** Set repeat parameters if want to repeat the request**/
   if ( repeatOption = 'yes' ) then
     retVal := false;
     if (length(repeatInterval) <> 0 ) then
       --if the repeat inteval is not null, then recurr the request after this interval
       retVal := FND_SUBMIT.SET_REPEAT_OPTIONS('' , repeatInterval ,repeatUnit
                                                 , 'START', repeatEndDate);
     else
       --if the repeatInteval is null, then recurr the request daily at this time
       --Extract the time  from submitDate
       retVal := FND_SUBMIT.SET_REPEAT_OPTIONS(SUBSTR('submitDate' ,
                        - INSTR('submitDate',' ', -8, 1) ,
                         INSTR('submitDate',' ', -8, 1)) , '' , '',
                        'START', repeatEndDate);
     end if;
   end if;
   if(retVal = false) then
     lRepeatFlag := -1;
     errMsg := fnd_message.get();
     return;
   end if;

   retVal := FND_SUBMIT.SET_REQUEST_SET('AD','FNDRSSUB1243');
   if ( retVal = true ) then
     n0 := 1;
   else
     errMsg := fnd_message.get();
     return;
   end if;

   -- bug#3984358 Call PAANALYZEPATCHES wrapper request.
   retVal := FND_SUBMIT.SUBMIT_PROGRAM('AD','PARECOMMENDPATCHES','STAGE3', criteriaId, pUploadPatchInfo, useproducts);
   if ( retVal = true ) then
     n3 := 1;
   else
     errMsg := fnd_message.get();
     return;
   end if;

   -- bug#3984358 FND_PAUPLOAD is now dummy request. replaced by PAANALYZEPATCHES wrapper.
   retVal := FND_SUBMIT.SUBMIT_PROGRAM('AD','FND_PAUPLOAD','STAGE5', pUploadPatchInfo);
   if ( retVal = true ) then
     n5 := 1;
   else
     errMsg := fnd_message.get();
     return;
   end if;

   -- bug#3984358 PAANALYSIS is now dummy request. replaced by PAANALYZEPATCHES wrapper.
   retVal := FND_SUBMIT.SUBMIT_PROGRAM('AD','PAANALYSIS','STAGE10',criteriaId);
   if ( retVal = true ) then
     n10 := 1;
   else
     errMsg := fnd_message.get();
     return;
   end if;

   retVal := FND_SUBMIT.SUBMIT_PROGRAM('FND','BUILDJSPDEP','STAGE20');
   if ( retVal = true ) then
     n20 := 1;
   else
     errMsg := fnd_message.get();
     return;
   end if;

   retVal := FND_SUBMIT.SUBMIT_PROGRAM('FND','COMPDIAGTESTVER','STAGE25');
   if ( retVal = true ) then
     n25 := 1;
   else
     errMsg := fnd_message.get();
     return;
   end if;

   retVal := FND_SUBMIT.SUBMIT_PROGRAM('FND','ANALYZEIMPACT','STAGE30');
   if ( retVal = true ) then
     n30 := 1;
   else
     errMsg := fnd_message.get();
     return;
   end if;

   retVal := FND_SUBMIT.SUBMIT_PROGRAM('FND','MENUTREEANALYSIS','STAGE40');
   if ( retVal = true ) then
     n40 := 1;
   else
     errMsg := fnd_message.get();
     return;
   end if;

   -- bug#3984358 Call Aggregate PIA request.
   retVal := FND_SUBMIT.SUBMIT_PROGRAM('FND','ANALYZEIMPACT2','STAGE50');
   if ( retVal = true ) then
     n50 := 1;
   else
     errMsg := fnd_message.get();
     return;
   end if;

   retVal := FND_SUBMIT.SUBMIT_PROGRAM('AD','PWSTATUSTRACKER','STAGE60');
   if ( retVal = true ) then
     n60 := 1;
   else
     errMsg := fnd_message.get();
     return;
   end if;

   if(pIsAggregate = 'Y') then
     retVal := FND_SUBMIT.SUBMIT_PROGRAM('FND','AGGREGATEIMPACT','STAGE55',null);
   else
     retVal := FND_SUBMIT.SUBMIT_PROGRAM('FND','AGGREGATEIMPACT','STAGE55', -1);
   end if;
   if ( retVal = true )
     then n55 := 1;
   else
     errMsg := fnd_message.get();
     return;
   end if;

   -- if  ( (n1 = 1 ) and (n1_1 = 1) and (n2 = 1 ) and (n3 = 1 ) and (n4 = 1 ) and (n5 = 1) and (n6 = 1) and (n7 = 1) and (n8 = 1) and (lRepeatFlag = 1)) then
   if ( (n0 = 1 ) and (n3 = 1 ) and (n20 = 1 ) and (n25 = 1) and (n30 = 1) and (n40 = 1) and (n50 = 1) and (n55 = 1) and (n60 = 1 ) and (lRepeatFlag = 1)) then
     reqId := FND_SUBMIT.SUBMIT_SET(submitDate);
   else
     reqId := 0;
     errMsg := fnd_message.get();
     return;
   end if;

  -- This is to get the actual error in case concurrent program fails.
  if ( reqId <= 0 ) then
     errMsg := fnd_message.get();
  end if;

  commit;

end submit_advisor_request;



-- Procedure to submit Download Patches Request Set for Patch Wizard
-- patchList is the List of Patches
-- mergeName is the Merge Name
-- mergeType is the Merge Type
-- automerge is the option to merge patches or not.
-- Languages is the list of languages codes
-- Platform  is the platform code
-- StagingDir is the staging directory
-- Options is the options to download or download and analyze
-- errMsg is the Error Message
-- pIsAggregate is the flag to determine whether aggregate impact is to be done or not.

procedure submit_download_patch_reqset(
reqId            out NOCOPY number,
pSubmitDate      in varchar2,
pPatchList       in varchar2 ,
pAutoMerge       in varchar2,
pMergeName       in varchar2,
pMergeType       in varchar2,
pLanguages       in varchar2,
pPlatform        in varchar2,
pStagingDir      in varchar2,
pOptions         in varchar2,
errMsg           out NOCOPY varchar2
)
is
retVal boolean;

n0   number ;
n10   number ;
n20   number ;
n30   number ;
n40   number ;
n50   number ;
n60   number ;
n65   number ;
n70   number ;
begin
   retVal := FND_SUBMIT.SET_REQUEST_SET('AD','FNDRSSUB1623');

   if ( retVal = true ) then
     n0 := 1;
   else
     errMsg := fnd_message.get();
     return;
   end if;

   retVal := FND_SUBMIT.SUBMIT_PROGRAM('AD','PADOWNLOADPATCHES','STAGE10'
                        , pPatchList
                        , pAutoMerge
                        , pMergeName
                        , pMergeType
                        , pLanguages
                        , pPlatform
                        , pStagingDir
                        , pOptions);
   if ( retVal = true ) then
     n10 := 1;
   else
     errMsg := fnd_message.get();
     return;
   end if;

   retVal := FND_SUBMIT.SUBMIT_PROGRAM('FND','BUILDJSPDEP','STAGE20');
   if ( retVal = true ) then
     n20 := 1;
   else
     errMsg := fnd_message.get();
     return;
   end if;

   retVal := FND_SUBMIT.SUBMIT_PROGRAM('FND','COMPDIAGTESTVER','STAGE30');
   if ( retVal = true ) then
     n30 := 1;
   else
     errMsg := fnd_message.get();
     return;
   end if;

   retVal := FND_SUBMIT.SUBMIT_PROGRAM('FND','ANALYZEIMPACT','STAGE40');
   if ( retVal = true ) then
     n40 := 1;
   else
     errMsg := fnd_message.get();
     return;
   end if;

   retVal := FND_SUBMIT.SUBMIT_PROGRAM('FND','MENUTREEANALYSIS','STAGE50');
   if ( retVal = true ) then
     n50 := 1;
   else
     errMsg := fnd_message.get();
     return;
   end if;

   retVal := FND_SUBMIT.SUBMIT_PROGRAM('FND','ANALYZEIMPACT2','STAGE60');
   if ( retVal = true ) then
     n60 := 1;
   else
     errMsg := fnd_message.get();
     return;
   end if;

   -- If the user has chosen Option 3 (Download, Analyze and Aggregate Patch Impact) only then
   -- do the Aggregate PIA (otherwise we pass -1 not aggregate)
   if(pOptions = '3') then
     retVal := FND_SUBMIT.SUBMIT_PROGRAM('FND','AGGREGATEIMPACT','STAGE65', null);
   else
     retVal := FND_SUBMIT.SUBMIT_PROGRAM('FND','AGGREGATEIMPACT','STAGE65', -1);
   end if;
   if ( retVal = true )
     then n65 := 1;
   else
     errMsg := fnd_message.get();
     return;
   end if;

   retVal := FND_SUBMIT.SUBMIT_PROGRAM('AD','PWSTATUSTRACKER','STAGE70');
   if ( retVal = true ) then
     n70 := 1;
   else
     errMsg := fnd_message.get();
     return;
   end if;

   -- if  ( (n1 = 1 ) and (n2 = 1 ) and (n3 = 1 ) and (n4 = 1 ) and (n5 = 1) and (n6 = 1) and (n7 = 1) and (n8 = 1)) then
   if ( (n0 = 1 ) and (n10 = 1 ) and (n20 = 1 ) and (n30 = 1) and (n40 = 1) and (n50 = 1) and (n60 = 1 ) and (n65 = 1) and (n70 = 1) ) then
     reqId := FND_SUBMIT.SUBMIT_SET(pSubmitDate);
   else
     reqId := 0;
     errMsg := fnd_message.get();
     return;
   end if;

   -- This is to get the actual error in case concurrent program fails.
   if ( reqId <= 0 ) then
     errMsg := fnd_message.get();
   end if;

   commit;

end submit_download_patch_reqset;


PROCEDURE StatusTracker(
	ERRBUF            OUT NOCOPY VARCHAR2,
	RETCODE           OUT NOCOPY NUMBER
) IS
    l_request_id	  INTEGER;
    l_request_set_id      INTEGER;
    l_sub_requests        FND_CONCURRENT.REQUESTS_TAB_TYPE;
    l_cnt                 NUMBER;
BEGIN

    -- Set the default value to 0 (Normal)
    RETCODE := 0;

    fnd_file.put_line(fnd_file.log, 'Status Tracker: This request set is the'||
    ' dummy request to track the status of individual requests and assign the'||
    ' right status to the request set');

    -- Get the request id for the current request, ie, StatusTracker
    SELECT fnd_global.conc_request_id INTO l_request_id from dual;

    fnd_file.put_line(fnd_file.log, 'Current request id : '|| l_request_id);

    -- Get the request set id for the current request, ie, StatusTracker
    SELECT parent_request_id INTO l_request_set_id FROM fnd_concurrent_requests
    WHERE request_id =
     ( SELECT  parent_request_id
       FROM    fnd_concurrent_requests
       WHERE request_id = l_request_id );

    fnd_file.put_line(fnd_file.log, 'Current request set id : '|| l_request_set_id);

    -- Get the data for all the requests in the current request set
    l_sub_requests := fnd_concurrent.get_sub_requests(l_request_set_id);

    -- Check the status of each request within the request set and assign the highest value to RETCODE
    l_cnt := l_sub_requests.first;
    WHILE l_cnt IS NOT NULL LOOP
       fnd_file.put_line(fnd_file.log, l_sub_requests(l_cnt).request_id ||'  '||l_sub_requests(l_cnt).status);
       IF (RETCODE <> 2 AND l_sub_requests(l_cnt).status = 'Warning') THEN
          RETCODE := 1;
       ELSIF (RETCODE <> 2 AND l_sub_requests(l_cnt).status = 'Error') THEN
          RETCODE := 2;
       END IF;
       l_cnt := l_sub_requests.next(l_cnt);
    END LOOP;

    IF (RETCODE = 0 ) THEN
       fnd_file.put_line(fnd_file.log,'Overall request set Status is Normal');
    ELSIF (RETCODE = 2 ) THEN
       fnd_file.put_line(fnd_file.log,'Overall request set Status is Warning');
    ELSE
       fnd_file.put_line(fnd_file.log,'Overall request set Status is Error');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
	RETCODE := 2;
	ERRBUF := sqlcode||':'||sqlerrm;
	fnd_file.put_line(fnd_file.log, 'StatusTracker failed ' || sqlcode||':'||sqlerrm);

END StatusTracker;
-- ababkuma bug#5488292 changed buglist type from t_rec_patch to t_recomm_patch_tab
-- Procedure to submit Aggregate Patch Impact Request.
PROCEDURE submit_aggregate_impact(
reqId       out NOCOPY number,
pReqId      in  number,
pPatchList  in  varchar2,
errMsg      out NOCOPY varchar2
)
IS
retVal      boolean ;
--bugno       varchar2(50);
patchid     varchar2(50);
lPatchList  varchar2(2000);
count1      number ;
pos         number ;
--buglist     ad_patch_impact_api.t_rec_patch;
buglist     ad_patch_impact_api.t_recomm_patch_tab;
l_rec       ad_patch_impact_api.t_recomm_patch_rec;
l_bugnum    number ;
l_baseline  varchar2(150);

BEGIN


   buglist := ad_patch_impact_api.t_recomm_patch_tab();

   retVal      := true;
   lPatchList  := pPatchList;
   count1      := 1;
   pos         := 1;
   l_bugnum    := 0;
   l_baseline  := '';
   -- Append a ',' to the patch list if it has some patches.
   -- Patchlist contains the set of unique patch_id from ad_pm_patches tables
   lPatchList := trim(pPatchList);
   if (length(lPatchList) > 1) then
      lPatchList := concat(lPatchList, ',');
   end if;

   --Prepare the patch list.
   while (pos <> 0) loop
      pos := instr(lPatchList, ',');
      if (pos <> 0) then
        patchid := trim(substr(lPatchList,1, pos-1));
        lPatchList := substr(lPatchList, pos+1);
        --buglist(count1) := to_number(bugno);
        SELECT bug_number, baseline
        INTO l_bugnum, l_baseline
        FROM ad_pm_patches
        WHERE patch_id = patchid;

        l_rec.bug_number  := l_bugnum;
        l_rec.baseline    := l_baseline;
        l_rec.patch_id    := patchid;
        buglist.extend;
        buglist(count1) := l_rec;

        count1 := count1 + 1;
      end if;
   end loop;

   --Set the list of patches to be aggregated.
   fnd_imp_pkg.set_aggregate_list(pReqId,buglist);

   --Submit the request.
   if (retVal = true) then
      reqId := FND_REQUEST.submit_request ('FND','AGGREGATEIMPACT',
              'Aggregate Patch Impact', NULL, FALSE, pReqId);
   end if;

   -- This is to get the actual error in case concurrent program fails.
   if ( reqId <= 0 ) then
      errMsg := fnd_message.get();
   end if;

END submit_aggregate_impact;

end ad_pa_submit_request;

/
