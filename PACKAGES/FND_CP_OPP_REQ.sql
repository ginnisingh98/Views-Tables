--------------------------------------------------------
--  DDL for Package FND_CP_OPP_REQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_CP_OPP_REQ" AUTHID CURRENT_USER AS
/* $Header: AFCPOPRS.pls 120.4.12010000.2 2016/01/14 20:02:26 ckclark ship $ */


-- POST_REQUEST_STATUS status codes
PP_PENDING   constant varchar2(1) := 'P';
PP_COMPLETE  constant varchar2(1) := 'C';
PP_TIMEOUT   constant varchar2(1) := 'T';
PP_ERROR     constant varchar2(1) := 'E';

--------------------------------------------------------------------------------


--
-- published_request
--
-- Given a request id, determine if this request has publishing actions
--
function published_request(reqid in number) return boolean ;



-- ============================
-- OPP service procedures
-- ============================

-- Added for bug Bug 6275963
--
-- published_request
--
-- Used to determine whether the request is a published request. If the request is a
-- simple reprint request of a published request in that case parent request id is passed
-- as the published request in the out parameter pub_req_id
--
-- reqid        - Concurrent request id
-- is_published - boolean variable to return whether the request is a published request
-- pub_reqid    - Request id of the published request. Incase the request passed as reqid
--                is a simple reprint of a published request then the parent request id
--                will be passed as pub_reqid else it will be same as reqid

procedure published_request (reqid in number,
                             is_published out NOCOPY boolean,
			     pub_req_id out NOCOPY number);


--
-- update_actions_table
--
-- Used by the OPP service to update the FND_CONC_PP_ACTIONS table
-- The table is only updated if it has not been previously updated by another process
--
-- reqid   - Concurrent request id
-- procid  - Concurrent process id of the service. FND_CONC_PP_ACTIONS.PROCESSOR_ID will be updated
--           with this value for all pp actions for this request
-- success - Y if the table was updated, N if the table has already been updated.
--
procedure update_actions_table(reqid in number, procid in number,
				success out NOCOPY varchar2);




-- =======================================
-- Request-Processing Manager procedures
-- =======================================

--
-- select_postprocessor
--
-- Looks for a post-processor service to post-process a request
-- First uses the same node name the manager is running on.
-- If a PP service is running there, it returns that node name.
-- If one is not found, it picks a random PP service.
-- Errcode will be 0 if a post-processor was found.
-- If no post-processor is available, or an error occurs, errcode
-- will be < 0.
--
-- Note: Can only be called from a concurrent manager
--
procedure select_postprocessor(opp_name out NOCOPY varchar2,
				errcode out NOCOPY number,
			 	requestid in  number);


--
-- postprocess
--
-- Post-process a request
-- Used by request-processing managers to submit a request to the post-processor
--
-- reqid        - Request id to postprocess
-- groupid      - Group to send request to
-- success_flag - Y if request was postprocessed successfully, N otherwise
-- errmsg       - Reason for failure
--
procedure postprocess(reqid        in number,
                      groupid      in varchar2,
			  success_flag out NOCOPY varchar2,
			  errmsg       out NOCOPY varchar2);




-- ============================
-- Reprint procedures
-- ============================


--
-- adjust_outfile
--
-- Used by the Republish/Reprint program to properly set its output file for
-- republishing and/or reprinting
--
-- cur_reqid    - Current request id
-- prev_reqid   - Request to reprint/republish
-- success_flag - Y if output file updated, N otherwise
-- errmsg       - Reason for failure
--
procedure adjust_outfile(cur_reqid    in number,
                         prev_reqid   in number,
			 success_flag out NOCOPY varchar2,
			 errmsg       out NOCOPY varchar2);



END fnd_cp_opp_req;

/
