--------------------------------------------------------
--  DDL for Package PSP_ER_WF_CUSTOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_ER_WF_CUSTOM" AUTHID CURRENT_USER as
/* $Header: PSPERWCS.pls 120.0 2005/06/02 15:50 appldev noship $ */
procedure set_custom_wf_admin(itemtype IN  varchar2,
                              itemkey  IN  varchar2,
                              actid    IN  number,
                              funcmode IN  varchar2,
                              result   OUT nocopy varchar2);

procedure set_custom_timeout_approver(itemtype IN  varchar2,
                                      itemkey  IN  varchar2,
                                      actid    IN  number,
                                      funcmode IN  varchar2,
                                      result   OUT nocopy varchar2);
end;

 

/
