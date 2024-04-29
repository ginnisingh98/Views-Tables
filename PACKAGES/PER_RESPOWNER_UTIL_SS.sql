--------------------------------------------------------
--  DDL for Package PER_RESPOWNER_UTIL_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RESPOWNER_UTIL_SS" AUTHID CURRENT_USER AS
/* $Header: perroutl.pkh 120.0 2005/05/31 19:40:44 appldev noship $ */

-- Global Variables
gv_package                  CONSTANT VARCHAR2(100)   DEFAULT 'per_respowner_util_ss';

gv_user_name_stmt CONSTANT VARCHAR2(2000) DEFAULT
                             'select user_name from fnd_user  '||
                             ' where trunc(sysdate) between trunc(start_date) '||
                             ' and nvl(trunc(end_date), trunc(sysdate)) ';

TYPE resp_owner_table IS TABLE OF per_responsibility_owner%ROWTYPE INDEX BY BINARY_INTEGER ;
TYPE ref_cursor IS REF CURSOR;

PROCEDURE populate_respowner_temp_table (
     p_fnd_object in varchar2
    ,p_user_name in varchar2
);

PROCEDURE raise_wfevent(
     p_event_name in varchar2
    ,p_event_data in wf_parameter_list_t
    ,p_resp_name in varchar2
    ,p_owner in varchar2
    ,p_userid_clause in varchar2 default null
);


PROCEDURE revoke_block(
   itemtype     in  varchar2
  ,itemkey      in  varchar2
  ,actid        in  number
  ,funmode      in  varchar2
  ,result  in out nocopy varchar2
);

/*This is test subscription function to test the event 'oracle.apps.per.selfservice.respowner.revoke_access'.
Uncomment to test, btw needs to create revoke_access_table though.
FUNCTION revoke_access_wfevent_subscrb
 ( p_subscription_guid      in raw,
   p_event                  in out NOCOPY wf_event_t)
RETURN VARCHAR2;
*/

END PER_RESPOWNER_UTIL_SS;

 

/
