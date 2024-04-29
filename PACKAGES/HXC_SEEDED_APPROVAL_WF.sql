--------------------------------------------------------
--  DDL for Package HXC_SEEDED_APPROVAL_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_SEEDED_APPROVAL_WF" AUTHID CURRENT_USER AS
/* $Header: hxcseedaw.pkh 120.0 2005/05/29 05:53:02 appldev noship $ */

procedure do_approval_logic(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2);

procedure approved(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2);

procedure rejected(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2);

end hxc_seeded_approval_wf;

 

/
