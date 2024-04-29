--------------------------------------------------------
--  DDL for Package AD_PA_SUBMIT_REQUEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AD_PA_SUBMIT_REQUEST" AUTHID CURRENT_USER as
/* $Header: adpasrs.pls 120.2.12010000.2 2009/03/25 10:27:16 bbhumire ship $ */

-- Procedure to submit InfoBundle Upload Request set for Patch Advisor
-- reqId is the Id of concurrent request submitted
-- repeatOption is 'yes' if want to recur the request
-- repeatInterval is number of repeatUnit
-- repeatUnit is either MINUTES/HOURS/DAYS/MONTHS
-- repeatEndDate is the end date
-- errMsg is the Error Message

procedure submit_infobundle_request(
reqId out NOCOPY number ,
submitDate in varchar2,
repeatOption in varchar2,
repeatInterval in varchar2,
repeatUnit in varchar2,
repeatEndDate in varchar2,
errMsg out NOCOPY varchar2
);

-- Procedure to submit Patch Upload and Patch Analysis Request set for Patch Advisor
-- reqId is the Id of concurrent request submitted
-- errMsg is the Error Message
procedure submit_patches_request(
reqId out NOCOPY number,
patchList in varchar2 ,
submitDate in varchar2,
repeatOption in varchar2,
repeatInterval in varchar2,
repeatUnit in varchar2,
repeatEndDate in varchar2,
pIsAggregate in varchar2,
errMsg out NOCOPY varchar2
);

-- Procedure to submit Analysis Request set for Patch Advisor
-- reqId is the Id of concurrent request submitted
-- errMsg is the Error Message
procedure submit_advisor_request(
reqId out NOCOPY number,
criteriaId in varchar2 ,
submitDate in varchar2 ,
repeatOption in varchar2,
repeatInterval in varchar2,
repeatUnit in varchar2,
repeatEndDate in varchar2,
pUploadPatchInfo in varchar2,
pIsAggregate in varchar2,
errMsg out NOCOPY varchar2,
useproducts in varchar2
);

-- Procedure to call download patches Request Set.
-- errMsg is the Error Message
procedure submit_download_patch_reqset(
reqId out NOCOPY number ,
pSubmitDate in varchar2,
pPatchList in varchar2 ,
pAutoMerge in varchar2,
pMergeName in varchar2,
pMergeType in varchar2,
pLanguages in varchar2,
pPlatform  in varchar2,
pStagingDir in varchar2,
pOptions    in varchar2,
errMsg out NOCOPY varchar2
);

--  Procedure for the tracking the status of the overall request set and
--  setting the right status to the request set..
PROCEDURE StatusTracker(
	ERRBUF           OUT NOCOPY VARCHAR2,
	RETCODE          OUT NOCOPY NUMBER
);

-- Procedure to submit Aggregate Patch Impact Request.
-- reqId is the request id for the newly submitted request.
-- pReqId is the Id of concurrent request which analysed the patches.
-- pPatchList is the comma separated list of patches show impact is to be aggregated.
-- errMsg is the Error Message.

procedure submit_aggregate_impact(
reqId       out NOCOPY number,
pReqId      in  number,
pPatchList  in  varchar2,
errMsg      out NOCOPY varchar2
);

end ad_pa_submit_request;


/
