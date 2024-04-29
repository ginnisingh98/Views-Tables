--------------------------------------------------------
--  DDL for Package BEN_REOPEN_ENDED_RESULTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_REOPEN_ENDED_RESULTS" AUTHID CURRENT_USER as
/* $Header: benreopn.pkh 120.0.12000000.1 2007/01/19 18:54:33 appldev noship $ */
---
PROCEDURE reopen_routine (p_per_in_ler_id  IN number,
                          p_business_group_id IN number,
                          p_lf_evt_ocrd_dt  in date,
                          p_person_id   in number,
                          p_effective_date in date);
--
end ben_reopen_ended_results;

 

/
