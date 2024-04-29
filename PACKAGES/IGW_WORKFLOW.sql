--------------------------------------------------------
--  DDL for Package IGW_WORKFLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_WORKFLOW" AUTHID CURRENT_USER as
--$Header: igwwfros.pls 115.4 2002/03/28 19:40:24 pkm ship    $
procedure start_workflow(p_proposal_id   in   number,
                         p_run_id        in   number);
                         --p_error_message out  varchar2,
                         --p_return_status out  varchar2);


procedure select_persons_to_notify(itemtype    in   varchar2,
                           itemkey     in   varchar2,
                           actid       in   number,
                           funcmode    in   varchar2,
                           result      out  varchar2);


procedure select_approver(itemtype    in   varchar2,
                           itemkey     in   varchar2,
                           actid       in   number,
                           funcmode    in   varchar2,
                           result      out  varchar2);


procedure disable_reassign(itemtype    in   varchar2,
                           itemkey     in   varchar2,
                           actid       in   number,
                           funcmode    in   varchar2,
                           result      out  varchar2);

procedure update_approval_status(itemtype    in   varchar2,
                               itemkey     in   varchar2,
                               actid       in   number,
                               funcmode    in   varchar2,
                               result      out  varchar2);


procedure update_rejection_status(itemtype    in   varchar2,
                          itemkey     in   varchar2,
                          actid       in   number,
                          funcmode    in   varchar2,
                          result      out  varchar2);



procedure last_approver(itemtype    in   varchar2,
                      itemkey     in   varchar2,
                      actid       in   number,
                      funcmode    in   varchar2,
                      result      out  varchar2);


end igw_workflow;

 

/
