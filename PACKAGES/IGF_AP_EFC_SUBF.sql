--------------------------------------------------------
--  DDL for Package IGF_AP_EFC_SUBF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_EFC_SUBF" AUTHID CURRENT_USER AS
/* $Header: IGFAP32S.pls 115.3 2003/03/09 13:50:50 gmuralid noship $ */
/*
  ||  Created By : gmuralid
  ||  Created On : 12- Feb- 2003
  ||  Purpose :    Bug# 2758804 - EFC TD
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  gmuralid        9-03-2003       Added a extra parameter l_call_type to procedure c_efc
  ||  gmuralid        7-03-2003       Added a new procedure to compute auto zero efc
  ||  (reverse chronological order - newest change first)
*/
    -- Exception to be raised while Error in Set up is Found.
   exception_in_setup  EXCEPTION;

  -- SUB FUNCTIONS  for calculating EFC with FORMULA A

   -- Get the Parents' Income in 2000
  PROCEDURE  a_p_inc   ( p_p_inc     OUT NOCOPY    NUMBER); -- Parents' Income

   -- Get Allowances against Parents' Income
  PROCEDURE  a_allow_ag_p_inc ( p_p_inc            IN           NUMBER,  -- Parents' Income
                                p_allow_ag_p_inc   OUT NOCOPY   NUMBER); -- Allowances against Parents' Income

   -- Get the Parents' Available Income
  PROCEDURE  a_available_inc ( p_p_inc            IN                NUMBER,  -- Parents' Income
                               p_allow_ag_p_inc   IN                NUMBER,  -- Allowances against Parents' Income
                               p_available_income     OUT NOCOPY    NUMBER); -- Available Income

   -- Get Parents' contribution from Assets
  PROCEDURE  a_p_cont_assets ( p_p_cont_assets        OUT NOCOPY    NUMBER); -- Parents' contribution from Assets

   -- Get Parents' Contribution
  PROCEDURE  a_p_cont ( p_available_income IN               NUMBER, -- Available Income
                        p_p_cont_assets    IN               NUMBER, -- Parents' contribution from Assets
                        p_p_aai               OUT NOCOPY    NUMBER, -- Parents' Adjustable Available Income
                        p_p_cont              OUT NOCOPY    NUMBER);-- Parents' Contribution from Income

   -- Get student's income in 2000
  PROCEDURE  a_s_inc ( p_s_inc                OUT NOCOPY    NUMBER);-- Student's Income

   -- Get Allowances against Student's income
  PROCEDURE  a_allow_ag_s_inc ( p_s_inc            IN                NUMBER, -- Student's Income
                                p_p_aai            IN                NUMBER, -- Parents' Adjustable Available Income
	                             p_allow_ag_s_inc       OUT NOCOPY    NUMBER);-- Allowances against Student's Income

   -- Get Student's contribution from income
  PROCEDURE  a_s_cont ( p_s_inc            IN                NUMBER, -- Student's Income
                        p_allow_ag_s_inc   IN                NUMBER, -- Allowances against Student's Income
	                     p_s_cont               OUT NOCOPY    NUMBER);-- Student's Contribution from Income

   -- Get Student's contribution from Assets
  PROCEDURE  a_s_cont_assets ( p_s_cont_assets    OUT NOCOPY    NUMBER);-- Student's contribution from Assets

   -- Get Expected Family Contribtion
  PROCEDURE  a_efc ( p_p_cont           IN               NUMBER, -- Parents' Contribution from Income
                     p_s_cont           IN               NUMBER, -- Student's Contribution from Income
                     p_s_cont_assets    IN               NUMBER, -- Student's contribution from Assets
                     p_efc                 OUT NOCOPY    NUMBER);-- EFC of the Student

   -- Get Parents' contribution for < 9 months
  PROCEDURE  a_p_cont_less_9 ( p_p_cont           IN                NUMBER, -- Parents' Contribution from Income
                               p_no_of_months     IN                NUMBER, -- Number of months of enrollment of student
                               p_p_cont_less_9        OUT NOCOPY    NUMBER);-- Parents' Contribution from Income for less than 9 months

   -- Get Student's contribution from Available Income for < 9 months
  PROCEDURE  a_s_cont_less_9 ( p_s_cont           IN              NUMBER, -- Student's Contribution from Income
                               p_no_of_months     IN              NUMBER, -- Number of months of enrollment of student
                               p_s_cont_less_9       OUT NOCOPY   NUMBER);-- Student's Contribution from Income for less than 9 months

   -- Get Student's EFC for <> 9 months
  PROCEDURE  a_efc_not_9 ( p_p_cont_not_9     IN              NUMBER, -- Parents' Contribution from Income for not equal to 9 months
                           p_s_cont_not_9     IN              NUMBER, -- Student's Contribution from Income for not equal to 9 months
	                        p_s_cont_assets    IN              NUMBER, -- Student's contribution from Assets
	                        p_efc                  OUT NOCOPY  NUMBER);-- EFC of the Student for No. of Months <> 9

   -- Get Parents contribution for > 9 months
  PROCEDURE  a_p_cont_more_9 ( p_p_aai            IN                NUMBER, -- Parents' Adjustable Available Income
                               p_p_cont           IN                NUMBER, -- Parents' Contribution from Income
	                            p_no_of_months     IN                NUMBER, -- Number of months of enrollment of student
	                            p_p_cont_more_9        OUT NOCOPY    NUMBER);-- Parents' Contribution from Income for more than 9 months


  -- SUB FUNCTIONS  for calculating EFC with FORMULA B
   -- Get Student/Spouse income in 2000
  PROCEDURE  b_s_inc ( p_s_inc             OUT NOCOPY    NUMBER);-- Student/Spouse Income

   -- Get Allowance against Student/Spouse income
  PROCEDURE  b_allow_ag_s_inc ( p_s_inc             IN               NUMBER, -- Student/Spouse Income
                                p_allow_ag_s_inc       OUT NOCOPY    NUMBER);-- Allowance against Student/Spouse income

   -- Get contribution from Available Income
  PROCEDURE  b_s_cont ( p_s_inc             IN             NUMBER, -- Student/Spouse Income
                        p_allow_ag_s_inc    IN             NUMBER, -- Allowance against Student/Spouse income
                        p_s_cont               OUT NOCOPY  NUMBER);-- Contribution from Available Income

   -- Get Student/Spouse contribution from Assets
  PROCEDURE  b_s_cont_assets ( p_s_cont_assets     OUT NOCOPY    NUMBER);-- Student/Spouse contribution from Assets

   -- Get Expected Family Contribution for 9 months
  PROCEDURE  b_efc ( p_s_cont            IN              NUMBER, -- Contribution from Available Income
                     p_s_cont_assets     IN              NUMBER, -- Student/Spouse contribution from Assets
                     p_efc                   OUT NOCOPY  NUMBER);-- EFC of the Student

   -- Get Expected Family Contribution for less than 9 months
  PROCEDURE  b_efc_less_9 ( p_no_of_months      IN             NUMBER, -- Number of months of enrollment of student
                            p_efc               IN OUT NOCOPY  NUMBER);-- EFC of the Student for No. of Months < 9


  -- SUB FUNCTIONS  for calculating EFC with FORMULA C

   -- Get Student/Spouse Income in 2000.
  PROCEDURE  c_s_inc ( p_s_inc             OUT NOCOPY    NUMBER);-- Student/Spouse Income

   -- Get Allowances against Student/Spouse Income
  PROCEDURE  c_allow_ag_s_inc ( p_s_inc             IN              NUMBER, -- Student/Spouse Income
                                p_allow_ag_s_inc        OUT NOCOPY  NUMBER);-- Allowance against Student/Spouse Income

   -- Get Available Income
  PROCEDURE  c_available_inc ( p_s_inc             IN              NUMBER, -- Student/Spouse Income
                               p_allow_ag_s_inc    IN              NUMBER, -- Allowance against Student/Spouse Income
	                            p_available_income      OUT NOCOPY  NUMBER);-- Available Income

   -- Get Student/Spouse contribution from Assets
  PROCEDURE  c_s_cont_assets ( p_s_cont_assets     OUT NOCOPY    NUMBER);-- Student/Spouse contribution from Assets

   -- Get Expected Family Contribution for 9 months
  PROCEDURE  c_efc ( p_available_income  IN             NUMBER, -- Available Income
                     p_s_cont_assets     IN             NUMBER, -- Student/Spouse contribution from Assets
                     p_efc                  OUT NOCOPY  NUMBER,
                     l_call_type         IN             VARCHAR2 );-- EFC of the Student

   -- Get Expected Family Contribution for less than 9 months
  PROCEDURE  c_efc_less_9 ( p_no_of_months      IN             NUMBER, -- Number of months of enrollment of student
                            p_efc               IN OUT NOCOPY  NUMBER);-- EFC of the Student for No. of Months < 9

  FUNCTION efc_cutoff_date ( p_sys_award_year IN VARCHAR2 )
  RETURN DATE;

  PROCEDURE get_par_stud_cont( p_sys_award_year IN            VARCHAR2,
                               p_parent_cont       OUT NOCOPY NUMBER,
                               p_student_cont      OUT NOCOPY NUMBER);

  PROCEDURE auto_zero_efc ( p_primary_efc_type  IN VARCHAR2);

END igf_ap_efc_subf;

 

/
