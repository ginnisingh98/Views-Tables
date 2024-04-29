--------------------------------------------------------
--  DDL for Package PER_KR_EXTRA_CTR_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_KR_EXTRA_CTR_RULES" AUTHID CURRENT_USER as
/* $Header: pekrxctr.pkh 115.3 2003/04/30 05:24:35 krapolu noship $ */
--
procedure chk_primary_ctr_flag(
            p_contact_relationship_id in number,
            p_person_id               in number,
            p_contact_person_id       in number,
            p_date_start              in date,
            p_date_end                in date,
            p_cont_information1       in varchar2);
--
end per_kr_extra_ctr_rules;

 

/
