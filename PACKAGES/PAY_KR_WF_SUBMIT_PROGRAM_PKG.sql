--------------------------------------------------------
--  DDL for Package PAY_KR_WF_SUBMIT_PROGRAM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_WF_SUBMIT_PROGRAM_PKG" AUTHID CURRENT_USER AS
/* $Header: pykrwfsp.pkh 120.0 2005/05/29 06:33:00 appldev noship $ */
        procedure submit_program (
                itemtype                        in              varchar2,       -- the name of the item type
                itemkey                         in              varchar2,       -- the unique item key
                actid                           in              number,         -- the activity id
                funcmode                        in              varchar2,       -- mode
                resultout                       in out nocopy   varchar2        -- the output
        ) ;
        procedure check_run_flags
        (
                p_itemtype                      in              varchar2,
                p_itemkey                       in              varchar2,
                p_actid                         in              number,
                p_funcmode                      in              varchar2,
                p_result                        in out nocopy   varchar2
        ) ;
	procedure get_assignment_count(
                p_itemtype                      in              varchar2,
                p_itemkey                       in              varchar2,
                p_actid                         in              number,
                p_funcmode                      in              varchar2,
                p_result                        in out nocopy   varchar2
        ) ;
end pay_kr_wf_submit_program_pkg;

 

/
