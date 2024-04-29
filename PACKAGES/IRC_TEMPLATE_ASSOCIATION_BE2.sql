--------------------------------------------------------
--  DDL for Package IRC_TEMPLATE_ASSOCIATION_BE2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_TEMPLATE_ASSOCIATION_BE2" AUTHID CURRENT_USER as 
--Code generated on 29/08/2013 09:58:20
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure update_template_association_a (
p_template_association_id      number,
p_template_id                  number,
p_effective_date               date,
p_default_association          varchar2,
p_job_id                       number,
p_position_id                  number,
p_organization_id              number,
p_start_date                   date,
p_end_date                     date);
end irc_template_association_be2;

/
