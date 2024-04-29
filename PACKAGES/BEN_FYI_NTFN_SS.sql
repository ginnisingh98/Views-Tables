--------------------------------------------------------
--  DDL for Package BEN_FYI_NTFN_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_FYI_NTFN_SS" AUTHID CURRENT_USER AS
/* $Header: befyintf.pkh 115.2 2002/12/04 21:59:45 shdas noship $*/
--
-- ---------------------------------------------------------------------------+
-- Purpose: This function will set the value of the workflow attribute
--          receiver name to the seeded workflow role.
--          Workflow engine will send notification to this role.
-- ---------------------------------------------------------------------------+
procedure set_role_to_send_ntfn
  (itemtype in     varchar2
  ,itemkey  in     varchar2
  ,actid    in     number
  ,funcmode in     varchar2
  ,result   out nocopy varchar2
  );
--
procedure build_url(
           p_item_type                 in varchar2
          ,p_item_key                  in varchar2
          ,p_from_ntfn                 in varchar2 default 'Y'
          );
end ben_fyi_ntfn_ss;

 

/
