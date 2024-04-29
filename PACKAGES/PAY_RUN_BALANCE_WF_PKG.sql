--------------------------------------------------------
--  DDL for Package PAY_RUN_BALANCE_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_RUN_BALANCE_WF_PKG" AUTHID CURRENT_USER AS
/* $Header: pyzzrbwf.pkh 120.0 2005/05/29 10:38:20 appldev noship $ */
--
procedure verify_revalidation(itemtype in varchar2
                             ,itemkey  in varchar2
                             ,actid    in number
                             ,funcmode in varchar2
                             ,resultout out nocopy varchar2);
--
procedure prepare_conc_prog_params(itemtype in varchar2
                                  ,itemkey  in varchar2
                                  ,actid    in number
                                  ,funcmode in varchar2
                                  ,resultout out nocopy varchar2);
--
end pay_run_balance_wf_pkg;

 

/
