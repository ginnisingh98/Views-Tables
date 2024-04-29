--------------------------------------------------------
--  DDL for Package WF_BES_CLEANUP_INIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_BES_CLEANUP_INIT" AUTHID CURRENT_USER as
/* $Header: WFBESCUIS.pls 120.1 2005/07/02 04:26:20 appldev ship $ */

--------------------------------------------------------------------------------
-- Initializes the apps context to SYSADMIN.
--------------------------------------------------------------------------------
procedure apps_initialize;

--------------------------------------------------------------------------------
-- Starts the control queue subscriber cleanup process.
--------------------------------------------------------------------------------
procedure start_cleanup_process;

end wf_bes_cleanup_init;

 

/
