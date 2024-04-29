--------------------------------------------------------
--  DDL for Package PQP_HRTCA_SYNCHRONIZATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_HRTCA_SYNCHRONIZATION" AUTHID CURRENT_USER AS
/* $Header: pqphrtcasync.pkh 120.0 2005/05/29 02:22:12 appldev noship $ */

-- =============================================================================
-- ~ Pei_DDF_Ins:
-- =============================================================================
PROCEDURE Pei_DDF_Ins
         (p_person_extra_info_id     IN Number
         ,p_person_id                IN Number
         ,p_information_type         IN Varchar2
         -- DDF
         ,p_pei_information_category IN Varchar2
         ,p_pei_information1         IN Varchar2
         ,p_pei_information2         IN Varchar2
         ,p_pei_information3         IN Varchar2
         ,p_pei_information4         IN Varchar2
         ,p_pei_information5         IN Varchar2
         ,p_pei_information6         IN Varchar2
         ,p_pei_information7         IN Varchar2
         ,p_pei_information8         IN Varchar2
         ,p_pei_information9         IN Varchar2
         ,p_pei_information10        IN Varchar2
         ,p_pei_information11        IN Varchar2
         ,p_pei_information12        IN Varchar2
         ,p_pei_information13        IN Varchar2
         ,p_pei_information14        IN Varchar2
         ,p_pei_information15        IN Varchar2
         ,p_pei_information16        IN Varchar2
         ,p_pei_information17        IN Varchar2
         ,p_pei_information18        IN Varchar2
         ,p_pei_information19        IN Varchar2
         ,p_pei_information20        IN Varchar2
         ,p_pei_information21        IN Varchar2
         ,p_pei_information22        IN Varchar2
         ,p_pei_information23        IN Varchar2
         ,p_pei_information24        IN Varchar2
         ,p_pei_information25        IN Varchar2
         ,p_pei_information26        IN Varchar2
         ,p_pei_information27        IN Varchar2
         ,p_pei_information28        IN Varchar2
         ,p_pei_information29        IN Varchar2
         ,p_pei_information30        IN Varchar2
         );
-- =============================================================================
-- ~ Pei_DDF_Upd:
-- =============================================================================
PROCEDURE Pei_DDF_Upd
         (-- New PEI Information
          p_person_extra_info_id     IN Number
         ,p_person_id                IN Number
         ,p_information_type         IN Varchar2
          -- New DDF
         ,p_pei_information_category IN Varchar2
         ,p_pei_information1         IN Varchar2
         ,p_pei_information2         IN Varchar2
         ,p_pei_information3         IN Varchar2
         ,p_pei_information4         IN Varchar2
         ,p_pei_information5         IN Varchar2
         ,p_pei_information6         IN Varchar2
         ,p_pei_information7         IN Varchar2
         ,p_pei_information8         IN Varchar2
         ,p_pei_information9         IN Varchar2
         ,p_pei_information10        IN Varchar2
         ,p_pei_information11        IN Varchar2
         ,p_pei_information12        IN Varchar2
         ,p_pei_information13        IN Varchar2
         ,p_pei_information14        IN Varchar2
         ,p_pei_information15        IN Varchar2
         ,p_pei_information16        IN Varchar2
         ,p_pei_information17        IN Varchar2
         ,p_pei_information18        IN Varchar2
         ,p_pei_information19        IN Varchar2
         ,p_pei_information20        IN Varchar2
         ,p_pei_information21        IN Varchar2
         ,p_pei_information22        IN Varchar2
         ,p_pei_information23        IN Varchar2
         ,p_pei_information24        IN Varchar2
         ,p_pei_information25        IN Varchar2
         ,p_pei_information26        IN Varchar2
         ,p_pei_information27        IN Varchar2
         ,p_pei_information28        IN Varchar2

         ,p_pei_information29        IN Varchar2
         ,p_pei_information30        IN Varchar2
          -- Old PEI Information
         ,p_person_id_o              IN Number
         ,p_information_type_o       IN Varchar2
         ,p_pei_attribute_category_o IN Varchar2
          -- Old DDF
         ,p_pei_information_category_o IN Varchar2
         ,p_pei_information1_o       IN Varchar2
         ,p_pei_information2_o       IN Varchar2
         ,p_pei_information3_o       IN Varchar2
         ,p_pei_information4_o       IN Varchar2
         ,p_pei_information5_o       IN Varchar2
         ,p_pei_information6_o       IN Varchar2
         ,p_pei_information7_o       IN Varchar2
         ,p_pei_information8_o       IN Varchar2
         ,p_pei_information9_o       IN Varchar2
         ,p_pei_information10_o      IN Varchar2
         ,p_pei_information11_o      IN Varchar2
         ,p_pei_information12_o      IN Varchar2
         ,p_pei_information13_o      IN Varchar2
         ,p_pei_information14_o      IN Varchar2
         ,p_pei_information15_o      IN Varchar2
         ,p_pei_information16_o      IN Varchar2
         ,p_pei_information17_o      IN Varchar2
         ,p_pei_information18_o      IN Varchar2
         ,p_pei_information19_o      IN Varchar2
         ,p_pei_information20_o      IN Varchar2
         ,p_pei_information21_o      IN Varchar2
         ,p_pei_information22_o      IN Varchar2
         ,p_pei_information23_o      IN Varchar2
         ,p_pei_information24_o      IN Varchar2
         ,p_pei_information25_o      IN Varchar2
         ,p_pei_information26_o      IN Varchar2
         ,p_pei_information27_o      IN Varchar2
         ,p_pei_information28_o      IN Varchar2
         ,p_pei_information29_o      IN Varchar2
         ,p_pei_information30_o      IN Varchar2
         );
-- =============================================================================
-- ~ Pei_DDF_Del:
-- =============================================================================
PROCEDURE Pei_DDF_Del
         (p_person_id_o              IN Number
         ,p_information_type_o       IN Varchar2
         ,p_pei_attribute_category_o IN Varchar2
          -- Old DDF
         ,p_pei_information_category_o IN Varchar2
         ,p_pei_information1_o       IN Varchar2
         ,p_pei_information2_o       IN Varchar2
         ,p_pei_information3_o       IN Varchar2
         ,p_pei_information4_o       IN Varchar2
         ,p_pei_information5_o       IN Varchar2
         ,p_pei_information6_o       IN Varchar2
         ,p_pei_information7_o       IN Varchar2
         ,p_pei_information8_o       IN Varchar2
         ,p_pei_information9_o       IN Varchar2
         ,p_pei_information10_o      IN Varchar2
         ,p_pei_information11_o      IN Varchar2
         ,p_pei_information12_o      IN Varchar2
         ,p_pei_information13_o      IN Varchar2
         ,p_pei_information14_o      IN Varchar2
         ,p_pei_information15_o      IN Varchar2
         ,p_pei_information16_o      IN Varchar2
         ,p_pei_information17_o      IN Varchar2
         ,p_pei_information18_o      IN Varchar2
         ,p_pei_information19_o      IN Varchar2
         ,p_pei_information20_o      IN Varchar2
         ,p_pei_information21_o      IN Varchar2
         ,p_pei_information22_o      IN Varchar2
         ,p_pei_information23_o      IN Varchar2
         ,p_pei_information24_o      IN Varchar2
         ,p_pei_information25_o      IN Varchar2
         ,p_pei_information26_o      IN Varchar2
         ,p_pei_information27_o      IN Varchar2
         ,p_pei_information28_o      IN Varchar2
         ,p_pei_information29_o      IN Varchar2
         ,p_pei_information30_o      IN Varchar2
         );

END PQP_HRTCA_Synchronization;

 

/
