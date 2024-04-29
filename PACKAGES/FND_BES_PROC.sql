--------------------------------------------------------
--  DDL for Package FND_BES_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_BES_PROC" AUTHID CURRENT_USER as
/* $Header: AFBESPROCS.pls 120.2 2005/10/20 21:47:32 mputhiya ship $ */

--------------------------------------------------------------------------------
function process_event(p_subscription_guid in     raw,
                       p_event             in out nocopy wf_event_t)
   return varchar2;

end fnd_bes_proc;

 

/
