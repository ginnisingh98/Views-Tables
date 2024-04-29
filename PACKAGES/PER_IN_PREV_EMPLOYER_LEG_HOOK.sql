--------------------------------------------------------
--  DDL for Package PER_IN_PREV_EMPLOYER_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_IN_PREV_EMPLOYER_LEG_HOOK" AUTHID CURRENT_USER AS
/* $Header: peinlhpr.pkh 120.1 2007/11/22 10:36:50 sivanara ship $ */

--------------------------------------------------------------------------
-- Name           : validate_ltc_availed                                --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Dummy Procedure is required as seed data  with      --
--                  call has already been shipped                       --
---------------------------------------------------------------------------
PROCEDURE validate_ltc_availed(
         p_pem_information_category IN VARCHAR2
        ,p_end_date                 IN DATE
        ) ;

--------------------------------------------------------------------------
-- Name           : check_prev_emp_create                               --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Main Procedure to be called from the PEM Info Hook  --
-- Parameters     :                                                     --
--             IN : p_effective_date            IN DATE                 --
--                  p_previous_employer_id      IN NUMBER               --
--                  p_business_group_id         IN NUMBER               --
--                  p_person_id                 IN NUMBER               --
--                  p_start_date                IN DATE                 --
--                  p_end_date                  IN DATE                 --
--                  p_pem_information_category  IN VARCHAR2             --
--                  p_pem_information1..30      IN VARCHAR2             --
--------------------------------------------------------------------------
PROCEDURE check_prev_emp_create(
          p_effective_date       IN DATE
         ,p_previous_employer_id IN NUMBER
	 ,p_business_group_id    IN NUMBER
	 ,p_person_id            IN NUMBER
         ,p_start_date           IN DATE
         ,p_end_date             IN DATE
         ,p_pem_information_category IN VARCHAR2
         ,p_pem_information1     IN VARCHAR2
         ,p_pem_information2     IN VARCHAR2
         ,p_pem_information3     IN VARCHAR2
         ,p_pem_information4     IN VARCHAR2
         ,p_pem_information5     IN VARCHAR2
         ,p_pem_information6     IN VARCHAR2
         ,p_pem_information7     IN VARCHAR2
         ,p_pem_information8     IN VARCHAR2
         ,p_pem_information9     IN VARCHAR2
         ,p_pem_information10    IN VARCHAR2
         ,p_pem_information11    IN VARCHAR2
         ,p_pem_information12    IN VARCHAR2
         ,p_pem_information13    IN VARCHAR2
         ,p_pem_information14    IN VARCHAR2
         ,p_pem_information15    IN VARCHAR2
         ,p_pem_information16    IN VARCHAR2
         ,p_pem_information17    IN VARCHAR2
         ,p_pem_information18    IN VARCHAR2
         ,p_pem_information19    IN VARCHAR2
         ,p_pem_information20    IN VARCHAR2
         ,p_pem_information21    IN VARCHAR2
         ,p_pem_information22    IN VARCHAR2
         ,p_pem_information23    IN VARCHAR2
         ,p_pem_information24    IN VARCHAR2
         ,p_pem_information25    IN VARCHAR2
         ,p_pem_information26    IN VARCHAR2
         ,p_pem_information27    IN VARCHAR2
         ,p_pem_information28    IN VARCHAR2
         ,p_pem_information29    IN VARCHAR2
         ,p_pem_information30    IN VARCHAR2);

--------------------------------------------------------------------------
-- Name           : check_prev_emp_update                               --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Main Procedure to be called from the PEM Info Hook  --
-- Parameters     :                                                     --
--             IN : p_effective_date            IN DATE                 --
--                  p_previous_employer_id      IN NUMBER               --
--                  p_business_group_id         IN NUMBER               --
--                  p_person_id                 IN NUMBER               --
--                  p_start_date                IN DATE                 --
--                  p_end_date                  IN DATE                 --
--                  p_pem_information_category  IN VARCHAR2             --
--                  p_pem_information1..30      IN VARCHAR2             --
--------------------------------------------------------------------------
PROCEDURE check_prev_emp_update(
          p_effective_date       IN DATE
         ,p_previous_employer_id IN NUMBER
         ,p_start_date           IN DATE
         ,p_end_date             IN DATE
         ,p_pem_information_category IN VARCHAR2
         ,p_pem_information1     IN VARCHAR2
         ,p_pem_information2     IN VARCHAR2
         ,p_pem_information3     IN VARCHAR2
         ,p_pem_information4     IN VARCHAR2
         ,p_pem_information5     IN VARCHAR2
         ,p_pem_information6     IN VARCHAR2
         ,p_pem_information7     IN VARCHAR2
         ,p_pem_information8     IN VARCHAR2
         ,p_pem_information9     IN VARCHAR2
         ,p_pem_information10    IN VARCHAR2
         ,p_pem_information11    IN VARCHAR2
         ,p_pem_information12    IN VARCHAR2
         ,p_pem_information13    IN VARCHAR2
         ,p_pem_information14    IN VARCHAR2
         ,p_pem_information15    IN VARCHAR2
         ,p_pem_information16    IN VARCHAR2
         ,p_pem_information17    IN VARCHAR2
         ,p_pem_information18    IN VARCHAR2
         ,p_pem_information19    IN VARCHAR2
         ,p_pem_information20    IN VARCHAR2
         ,p_pem_information21    IN VARCHAR2
         ,p_pem_information22    IN VARCHAR2
         ,p_pem_information23    IN VARCHAR2
         ,p_pem_information24    IN VARCHAR2
         ,p_pem_information25    IN VARCHAR2
         ,p_pem_information26    IN VARCHAR2
         ,p_pem_information27    IN VARCHAR2
         ,p_pem_information28    IN VARCHAR2
         ,p_pem_information29    IN VARCHAR2
         ,p_pem_information30    IN VARCHAR2);

END  per_in_prev_employer_leg_hook;

/
