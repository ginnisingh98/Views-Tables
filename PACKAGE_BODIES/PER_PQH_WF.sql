--------------------------------------------------------
--  DDL for Package Body PER_PQH_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PQH_WF" as
/* $Header: perpqhwf.pkb 115.0 2002/06/21 22:46:42 scnair noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_pqh_wf.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |-------------------------< my_callbackable_routine >----------------------|
-- ----------------------------------------------------------------------------

procedure my_callbackable_routine(my_parms in wf_parameter_list_t) is
mykey   varchar2(100);
begin
        mykey := wf_event.getValueForParameter('USERKEY', my_parms);
        per_pqh_shr.my_synch_routine(mykey);
end my_callbackable_routine;
-- ----------------------------------------------------------------------------
-- |-------------------------< callbackable_routine >----------------------|
-- ----------------------------------------------------------------------------
--
procedure callbackable_routine(my_parms in wf_parameter_list_t) is
mykey   varchar2(100);
begin
        mykey := wf_event.getValueForParameter('USERKEY', my_parms);
        hr_psf_shd.my_synch_routine(mykey);
end callbackable_routine;
--
end per_pqh_wf;

/
