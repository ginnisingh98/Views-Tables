--------------------------------------------------------
--  DDL for Package IRC_JOB_BASKET_ITEMS_BE1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_JOB_BASKET_ITEMS_BE1" AUTHID CURRENT_USER as 
--Code generated on 29/08/2013 09:58:19
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure create_job_basket_item_a (
p_effective_date               date,
p_object_version_number        number,
p_job_basket_item_id           number,
p_recruitment_activity_id      number,
p_person_id                    number);
end irc_job_basket_items_be1;

/
