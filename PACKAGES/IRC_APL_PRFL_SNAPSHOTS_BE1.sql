--------------------------------------------------------
--  DDL for Package IRC_APL_PRFL_SNAPSHOTS_BE1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_APL_PRFL_SNAPSHOTS_BE1" AUTHID CURRENT_USER as 
--Code generated on 29/08/2013 09:58:17
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure create_applicant_snapshot_a (
p_effective_date               date,
p_person_id                    number,
p_profile_snapshot_id          number,
p_object_version_number        number);
end irc_apl_prfl_snapshots_be1;

/