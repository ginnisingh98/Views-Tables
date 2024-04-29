--------------------------------------------------------
--  DDL for Package PER_REC_ACTIVITY_FOR_BE1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_REC_ACTIVITY_FOR_BE1" AUTHID CURRENT_USER as 
--Code generated on 04/01/2007 09:33:05
/* $Header: hrapiwfe.pkb 120.3 2006/06/20 10:26:28 sayyampe noship $*/
procedure create_rec_activity_for_a (
p_rec_activity_for_id          number,
p_business_group_id            number,
p_vacancy_id                   number,
p_rec_activity_id              number,
p_object_version_number        number);
end per_rec_activity_for_be1;

 

/
