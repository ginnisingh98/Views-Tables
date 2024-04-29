--------------------------------------------------------
--  DDL for Package HR_SA_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SA_UTILITY" AUTHID CURRENT_USER AS
 /* $Header: hrsautil.pkh 115.0 2003/04/03 09:34:52 jahobbs noship $ */
 --
 --
 -- Formats the full name for the Saudi legislation.
 --
 FUNCTION per_sa_full_name
 (p_first_name        IN VARCHAR2
 ,p_middle_names      IN VARCHAR2
 ,p_last_name         IN VARCHAR2
 ,p_known_as          IN VARCHAR2
 ,p_title             IN VARCHAR2
 ,p_suffix            IN VARCHAR2
 ,p_pre_name_adjunct  IN VARCHAR2
 ,p_per_information1  IN VARCHAR2
 ,p_per_information2  IN VARCHAR2
 ,p_per_information3  IN VARCHAR2
 ,p_per_information4  IN VARCHAR2
 ,p_per_information5  IN VARCHAR2
 ,p_per_information6  IN VARCHAR2
 ,p_per_information7  IN VARCHAR2
 ,p_per_information8  IN VARCHAR2
 ,p_per_information9  IN VARCHAR2
 ,p_per_information10 IN VARCHAR2
 ,p_per_information11 IN VARCHAR2
 ,p_per_information12 IN VARCHAR2
 ,p_per_information13 IN VARCHAR2
 ,p_per_information14 IN VARCHAR2
 ,p_per_information15 IN VARCHAR2
 ,p_per_information16 IN VARCHAR2
 ,p_per_information17 IN VARCHAR2
 ,p_per_information18 IN VARCHAR2
 ,p_per_information19 IN VARCHAR2
 ,p_per_information20 IN VARCHAR2
 ,p_per_information21 IN VARCHAR2
 ,p_per_information22 IN VARCHAR2
 ,p_per_information23 IN VARCHAR2
 ,p_per_information24 IN VARCHAR2
 ,p_per_information25 IN VARCHAR2
 ,p_per_information26 IN VARCHAR2
 ,p_per_information27 IN VARCHAR2
 ,p_per_information28 IN VARCHAR2
 ,p_per_information29 IN VARCHAR2
 ,p_per_information30 IN VARCHAR2) RETURN VARCHAR2;
END hr_sa_utility;

 

/
