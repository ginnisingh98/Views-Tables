--------------------------------------------------------
--  DDL for Package Body ICX_RQS_ATTACHMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_RQS_ATTACHMENT" as
/* $Header: ICXRQATB.pls 115.1 99/07/17 03:22:39 porting ship $ */

procedure header(c_inputs1 in varchar2 default null,
                        c_inputs2 in varchar2 default null,
                        c_inputs3 in varchar2 default null,
                        c_inputs4 in varchar2 default null,
                        c_inputs5 in varchar2 default null,
                        c_inputs6 in varchar2 default null,
                        c_inputs7 in varchar2 default null,
                        c_inputs8 in varchar2 default null,
                        c_inputs9 in varchar2 default null,
                        c_inputs10 in varchar2 default null,
                        c_outputs1 out varchar2,
                        c_outputs2 out varchar2,
                        c_outputs3 out varchar2,
                        c_outputs4 out varchar2,
                        c_outputs5 out varchar2,
                        c_outputs6 out varchar2,
                        c_outputs7 out varchar2,
                        c_outputs8 out varchar2,
                        c_outputs9 out varchar2,
                        c_outputs10 out varchar2)is

c_rowid varchar2(18);
c_dcdname	varchar(200);
url		varchar(300);
l_param		varchar(240);
l_session_id            number;

begin

-- The following information needs to be set up through ON forms, on particular
-- Page rlations.

if icx_sec.validateSession
then
l_session_id := icx_sec.getID(icx_sec.PV_SESSION_ID);
/*
c_dcdname := owa_util.get_cgi_env('SCRIPT_NAME');


select  rowidtochar(ROWID)
into    c_rowid
from    AK_FLOW_REGION_RELATIONS
where   FROM_REGION_CODE = 'ICX_RQS_HISTORY_1'
and     FROM_REGION_APPL_ID = 178
and     FROM_PAGE_CODE = 'ICX_RQS_HISTORY_1'
and     FROM_PAGE_APPL_ID = 178
and     TO_PAGE_CODE = 'ICX_RQS_HISTORY_DTL_D'
and     TO_PAGE_APPL_ID = 178
and     FLOW_CODE = 'ICX_EMPLOYEES'
and     FLOW_APPLICATION_ID = 178;

l_param := icx_on_utilities.buildOracleONstring
                (p_rowid => c_rowid,
                 p_primary_key => 'ICX_RQS_HISTORY_PK',
                 p1 => c_inputs1);

if l_session_id is null then
        url := c_dcdname || '/OracleOn.IC?Y=' || icx_call.encrypt2(l_param,-999);
else
        url := c_dcdname || '/OracleOn.IC?Y=' || icx_call.encrypt2(l_param,l_session_id);
end if;
*/

fnd_webattch.Summary	(function_name=>icx_call.encrypt2('ICX_REQS'),
			     entity_name=>icx_call.encrypt2('REQ_HEADERS'),
			     pk1_value=>icx_call.encrypt2(c_inputs1),
			     pk2_value=>icx_call.encrypt2(NULL),
   			  	pk3_value=>icx_call.encrypt2(NULL),
				pk4_value=>icx_call.encrypt2( NULL),
				pk5_value=>icx_call.encrypt2(NULL),
				from_url=>icx_call.encrypt2(NULL),
				query_only=>icx_call.encrypt2('Y'));

end if;
end;

procedure lines(c_inputs1 in varchar2 default null,
                        c_inputs2 in varchar2 default null,
                        c_inputs3 in varchar2 default null,
                        c_inputs4 in varchar2 default null,
                        c_inputs5 in varchar2 default null,
                        c_inputs6 in varchar2 default null,
                        c_inputs7 in varchar2 default null,
                        c_inputs8 in varchar2 default null,
                        c_inputs9 in varchar2 default null,
                        c_inputs10 in varchar2 default null,
                        c_outputs1 out varchar2,
                        c_outputs2 out varchar2,
                        c_outputs3 out varchar2,
                        c_outputs4 out varchar2,
                        c_outputs5 out varchar2,
                        c_outputs6 out varchar2,
                        c_outputs7 out varchar2,
                        c_outputs8 out varchar2,
                        c_outputs9 out varchar2,
                        c_outputs10 out varchar2)is

c_rowid varchar2(18);
c_dcdname	varchar(200);
url		varchar(300);
l_param		varchar(240);
l_session_id            number;

begin

-- The following information needs to be set up through ON forms, on particular
-- Page rlations.

if icx_sec.validateSession
then
l_session_id := icx_sec.getID(icx_sec.PV_SESSION_ID);
/*
c_dcdname := owa_util.get_cgi_env('SCRIPT_NAME');


select  rowidtochar(ROWID)
into    c_rowid
from    AK_FLOW_REGION_RELATIONS
where   FROM_REGION_CODE = 'ICX_RQS_HISTORY_1'
and     FROM_REGION_APPL_ID = 178
and     FROM_PAGE_CODE = 'ICX_RQS_HISTORY_1'
and     FROM_PAGE_APPL_ID = 178
and     TO_PAGE_CODE = 'ICX_RQS_HISTORY_DTL_D'
and     TO_PAGE_APPL_ID = 178
and     FLOW_CODE = 'ICX_EMPLOYEES'
and     FLOW_APPLICATION_ID = 178;

l_param := icx_on_utilities.buildOracleONstring
                (p_rowid => c_rowid,
                 p_primary_key => 'ICX_RQS_HISTORY_PK',
                 p1 => c_inputs1);

if l_session_id is null then
        url := c_dcdname || '/OracleOn.IC?Y=' || icx_call.encrypt2(l_param,-999);
else
        url := c_dcdname || '/OracleOn.IC?Y=' || icx_call.encrypt2(l_param,l_session_id);
end if;

*/
fnd_webattch.Summary	(function_name=>icx_call.encrypt2('ICX_REQS'),
			     entity_name=>icx_call.encrypt2('REQ_LINES'),
			     pk1_value=>icx_call.encrypt2(c_inputs2),
			     pk2_value=>icx_call.encrypt2(NULL),
   			  	pk3_value=>icx_call.encrypt2(NULL),
				pk4_value=>icx_call.encrypt2( NULL),
				pk5_value=>icx_call.encrypt2(NULL),
				from_url=>icx_call.encrypt2(NULL),
				query_only=>icx_call.encrypt2('Y'));

end if;
end;




procedure lines2(c_inputs1 in varchar2 default null,
                        c_inputs2 in varchar2 default null,
                        c_inputs3 in varchar2 default null,
                        c_inputs4 in varchar2 default null,
                        c_inputs5 in varchar2 default null,
                        c_inputs6 in varchar2 default null,
                        c_inputs7 in varchar2 default null,
                        c_inputs8 in varchar2 default null,
                        c_inputs9 in varchar2 default null,
                        c_inputs10 in varchar2 default null,
                        c_outputs1 out varchar2,
                        c_outputs2 out varchar2,
                        c_outputs3 out varchar2,
                        c_outputs4 out varchar2,
                        c_outputs5 out varchar2,
                        c_outputs6 out varchar2,
                        c_outputs7 out varchar2,
                        c_outputs8 out varchar2,
                        c_outputs9 out varchar2,
                        c_outputs10 out varchar2)is

c_rowid varchar2(18);
c_dcdname	varchar(200);
url		varchar(300);
l_param		varchar(240);
l_session_id            number;
pk1		varchar(30);
begin

-- The following information needs to be set up through ON forms, on particular
-- Page rlations.

if icx_sec.validateSession
then
l_session_id := icx_sec.getID(icx_sec.PV_SESSION_ID);
/*
c_dcdname := owa_util.get_cgi_env('SCRIPT_NAME');


select  rowidtochar(ROWID)
into    c_rowid
from    AK_FLOW_REGION_RELATIONS
where   FROM_REGION_CODE = 'ICX_RQS_HISTORY_1'
and     FROM_REGION_APPL_ID = 178
and     FROM_PAGE_CODE = 'ICX_RQS_HISTORY_1'
and     FROM_PAGE_APPL_ID = 178
and     TO_PAGE_CODE = 'ICX_RQS_HISTORY_DTL_D'
and     TO_PAGE_APPL_ID = 178
and     FLOW_CODE = 'ICX_EMPLOYEES'
and     FLOW_APPLICATION_ID = 178;

l_param := icx_on_utilities.buildOracleONstring
                (p_rowid => c_rowid,
                 p_primary_key => 'ICX_RQS_HISTORY_PK',
                 p1 => c_inputs1);

if l_session_id is null then
        url := c_dcdname || '/OracleOn.IC?Y=' || icx_call.encrypt2(l_param,-999);
else
        url := c_dcdname || '/OracleOn.IC?Y=' || icx_call.encrypt2(l_param,l_session_id);
end if;
*/
select REQUISITION_HEADER_ID into pk1
from icx_po_requisition_open_v
where REQUISITION_LINE_ID = c_inputs1;

fnd_webattch.Summary	(function_name=>icx_call.encrypt2('ICX_REQS'),
			     entity_name=>icx_call.encrypt2('REQ_LINES'),
			     pk1_value=>icx_call.encrypt2(c_inputs1),
			     pk2_value=>icx_call.encrypt2(NULL),
   			  	pk3_value=>icx_call.encrypt2(NULL),
				pk4_value=>icx_call.encrypt2( NULL),
				pk5_value=>icx_call.encrypt2(NULL),
				from_url=>icx_call.encrypt2(NULL),
				query_only=>icx_call.encrypt2('Y'));

end if;
end;



end icx_rqs_attachment;

/
