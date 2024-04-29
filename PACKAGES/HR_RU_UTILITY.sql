--------------------------------------------------------
--  DDL for Package HR_RU_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_RU_UTILITY" AUTHID CURRENT_USER AS
/* $Header: peruutil.pkh 120.0 2005/05/31 20:19:48 appldev noship $ */

   PROCEDURE check_lookup_value (
      p_argument         IN   VARCHAR2,
      p_argument_value   IN   VARCHAR2,
      p_lookup_type      IN   VARCHAR2,
      p_effective_date   IN   DATE
   );

   FUNCTION validate_spifn (spif_number VARCHAR2, p_session_date DATE)
      RETURN NUMBER;

   PROCEDURE validate_mil_reg_board_code (p_military_reg_board_code VARCHAR2);

   PROCEDURE check_spif_number_unique (
      p_spifn               VARCHAR2
     ,p_person_id           NUMBER
     ,p_business_group_id   NUMBER
   );

   FUNCTION per_ru_full_name (
      p_first_name          IN   VARCHAR2
     ,p_middle_names        IN   VARCHAR2
     ,p_last_name           IN   VARCHAR2
     ,p_known_as            IN   VARCHAR2
     ,p_title               IN   VARCHAR2
     ,p_suffix              IN   VARCHAR2
     ,p_pre_name_adjunct    IN   VARCHAR2
     ,p_per_information1    IN   VARCHAR2
     ,p_per_information2    IN   VARCHAR2
     ,p_per_information3    IN   VARCHAR2
     ,p_per_information4    IN   VARCHAR2
     ,p_per_information5    IN   VARCHAR2
     ,p_per_information6    IN   VARCHAR2
     ,p_per_information7    IN   VARCHAR2
     ,p_per_information8    IN   VARCHAR2
     ,p_per_information9    IN   VARCHAR2
     ,p_per_information10   IN   VARCHAR2
     ,p_per_information11   IN   VARCHAR2
     ,p_per_information12   IN   VARCHAR2
     ,p_per_information13   IN   VARCHAR2
     ,p_per_information14   IN   VARCHAR2
     ,p_per_information15   IN   VARCHAR2
     ,p_per_information16   IN   VARCHAR2
     ,p_per_information17   IN   VARCHAR2
     ,p_per_information18   IN   VARCHAR2
     ,p_per_information19   IN   VARCHAR2
     ,p_per_information20   IN   VARCHAR2
     ,p_per_information21   IN   VARCHAR2
     ,p_per_information22   IN   VARCHAR2
     ,p_per_information23   IN   VARCHAR2
     ,p_per_information24   IN   VARCHAR2
     ,p_per_information25   IN   VARCHAR2
     ,p_per_information26   IN   VARCHAR2
     ,p_per_information27   IN   VARCHAR2
     ,p_per_information28   IN   VARCHAR2
     ,p_per_information29   IN   VARCHAR2
     ,p_per_information30   IN   VARCHAR2
   )
      RETURN VARCHAR2;

   FUNCTION per_ru_full_name_initials (
      p_first_name           IN   VARCHAR2,
      p_middle_names         IN   VARCHAR2,
      p_last_name            IN   VARCHAR2,
      p_genitive_last_name   IN   VARCHAR2 DEFAULT NULL,
      p_known_as             IN   VARCHAR2 DEFAULT NULL,
      p_title                IN   VARCHAR2 DEFAULT NULL,
      p_suffix               IN   VARCHAR2 DEFAULT NULL,
      use_genitive           IN   BOOLEAN DEFAULT TRUE
   )
      RETURN VARCHAR2;

   FUNCTION validate_tax_no (p_org_info VARCHAR2)
      RETURN NUMBER;

   FUNCTION validate_ogrn (p_org_info IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION check_tax_number_unique (p_tax_no VARCHAR2, p_org_id NUMBER, p_org_info_code VARCHAR2)
      RETURN NUMBER;

   FUNCTION validate_kpp (p_kpp VARCHAR2)
      RETURN NUMBER;

   FUNCTION validate_si (p_si VARCHAR2)
      RETURN NUMBER;

   FUNCTION validate_okogu (p_okogu VARCHAR2)
      RETURN NUMBER;

   FUNCTION validate_okpo (p_okpo VARCHAR2)
      RETURN NUMBER;

   FUNCTION validate_org_spifn (p_spifn VARCHAR2)
      RETURN NUMBER;

   FUNCTION validate_okved (p_okved VARCHAR2)
      RETURN NUMBER;

   FUNCTION validate_bik (p_bank_bik VARCHAR2)
      RETURN NUMBER;

   FUNCTION validate_acc_no (p_bank_acc_no VARCHAR2)
      RETURN NUMBER;

   FUNCTION validate_bank_info (p_bank_inn VARCHAR2)
      RETURN NUMBER;

   FUNCTION chk_id_format (p_id IN VARCHAR2, p_format_string IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION check_segment_number (entry_value IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION check_contract_number_unique (
      p_contract_number     VARCHAR2
     ,p_assignment_id       NUMBER
     ,p_business_group_id   NUMBER
   ) RETURN VARCHAR2;

   FUNCTION check_assign_category (
      p_eff_start_date    DATE
     ,p_eff_end_date      DATE
     ,p_assignment_id     NUMBER
     ,p_person_id         NUMBER
     ,p_business_group_id NUMBER
   ) RETURN VARCHAR2;

END hr_ru_utility;

 

/
