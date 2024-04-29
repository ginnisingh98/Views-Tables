--------------------------------------------------------
--  DDL for Package HR_360_MESSAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_360_MESSAGE" AUTHID CURRENT_USER as
/* $Header: perhrhd360vw.pkh 120.1 2008/01/25 12:40:26 sathkris noship $ */

procedure HR_360_PERSON_VIEW ( P_EMPLOYEE_NUMBER VARCHAR2 ,
			       p_effective_date date default sysdate,
                               P_BUSINESS_GROUP_ID NUMBER,
	                       p_tp_site_id number,
                               p_trxn_id varchar2);

procedure  hr_wflow_360
           (itemtype   in varchar2,
		   itemkey     in varchar2,
		   actid       in number,
		   funcmode    in varchar2,
	 	   resultout   in out NOCOPY varchar2);

end HR_360_MESSAGE ;

/
