--------------------------------------------------------
--  DDL for Package BEN_IREC_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_IREC_PROCESS" AUTHID CURRENT_USER as
/* $Header: benirecp.pkh 120.0.12000000.1 2007/01/19 18:29:24 appldev noship $ */
--
procedure p_transfer_bckdt_data
  (p_business_group_id in number,
   p_effective_date    in date,
   p_assignment_id     in number,
   p_irec_per_in_ler_id in number
  );
--
procedure create_enrollment_for_irec(p_irec_per_in_ler_id  in number
                                    ,p_person_id           in number
                                    ,p_business_group_id   in number
                                    ,p_effective_date      in date );
--
end ben_irec_process;

 

/
