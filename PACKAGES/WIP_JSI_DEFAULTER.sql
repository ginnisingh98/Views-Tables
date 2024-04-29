--------------------------------------------------------
--  DDL for Package WIP_JSI_DEFAULTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_JSI_DEFAULTER" AUTHID CURRENT_USER as
/* $Header: wipjsids.pls 120.0 2005/05/25 08:42:57 appldev noship $ */

  procedure default_values(p_wjsi_row in out nocopy wip_job_schedule_interface%ROWTYPE);

  --This value can only be defaulted *after* the routing explosion. Thus it has
  --to be called independent of the initial defaulting
  --It depends on wip_jsi_utils.current_rowid being set.
  procedure default_serialization_op(p_rtgVal IN NUMBER);

end wip_jsi_defaulter;

 

/
