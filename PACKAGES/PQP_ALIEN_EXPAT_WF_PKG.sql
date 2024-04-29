--------------------------------------------------------
--  DDL for Package PQP_ALIEN_EXPAT_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_ALIEN_EXPAT_WF_PKG" AUTHID CURRENT_USER AS
/* $Header: pqpalntf.pkh 115.3 2003/02/14 19:19:57 tmehra noship $ */
--
--
procedure StartAlienExpatWFProcess
                                 ( p_process_event_id in number
                                  ,p_tran_type        in varchar2
                                  ,p_tran_date        in date
                                  ,p_itemtype         in varchar2
                                  ,p_alien_transaction_id in number
                                  ,p_assignment_id    in number
                                  ,p_process_name     in varchar2
                                  );
--
procedure check_req_ntf
                                ( itemtype in varchar2
                                 ,itemkey in varchar2
                                 ,actid in number
                                 ,funcmode in varchar2
                                 ,result in out nocopy varchar2
                                );
--
procedure find_ntfr
                                ( itemtype in varchar2
                                 ,itemkey in varchar2
                                 ,actid in number
                                 ,funcmode in varchar2
                                 ,result in out nocopy varchar2
                                );
--
procedure check_tran_type
                               ( itemtype in varchar2
                                 ,itemkey in varchar2
                                 ,actid in number
                                 ,funcmode in varchar2
                                 ,result in out nocopy varchar2
                                );
--

procedure reset_read_api_retry
                                ( itemtype in varchar2
                                 ,itemkey in varchar2
                                 ,actid in number
                                 ,funcmode in varchar2
                                 ,result in out nocopy varchar2
                                );
--
procedure abort_read_api_retry (
					   itemtype	in varchar2,
					   itemkey  in varchar2,
					   actid	in number,
					   funcmode	in varchar2,
					   result	in out nocopy varchar2);
--
PROCEDURE check_if_retro_loss    ( itemtype	in varchar2,
					   itemkey  in varchar2,
					   actid	in number,
					   funcmode	in varchar2,
					   result	in out nocopy varchar2);
--
PROCEDURE check_income_code_change( itemtype  in varchar2,
                                    itemkey   in varchar2,
                                    actid     in number,
                                    funcmode  in varchar2,
                                    result    in out nocopy varchar2);
--
end PQP_ALIEN_EXPAT_WF_PKG;

 

/
