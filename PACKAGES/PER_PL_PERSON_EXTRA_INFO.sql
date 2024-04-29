--------------------------------------------------------
--  DDL for Package PER_PL_PERSON_EXTRA_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PL_PERSON_EXTRA_INFO" AUTHID CURRENT_USER AS
/* $Header: peplpeip.pkh 120.0.12000000.1 2007/01/22 01:44:02 appldev noship $ */

PROCEDURE CREATE_PL_PERSON_EXTRA_INFO
    (P_PERSON_ID                in NUMBER
    ,P_INFORMATION_TYPE         in VARCHAR2
    ,P_PEI_INFORMATION_CATEGORY in VARCHAR2
    ,P_PEI_INFORMATION1         in VARCHAR2
    ,P_PEI_INFORMATION2         in VARCHAR2
    ,P_PEI_INFORMATION3         in VARCHAR2
    ,P_PEI_INFORMATION4         in VARCHAR2
    ,P_PEI_INFORMATION5         in VARCHAR2
    ,P_PEI_INFORMATION6         in VARCHAR2
    ,P_PEI_INFORMATION7         in VARCHAR2
    ,P_PEI_INFORMATION8         in VARCHAR2
    ,P_PEI_INFORMATION9         in VARCHAR2
    ,P_PEI_INFORMATION10        in VARCHAR2
    ,P_PEI_INFORMATION11        in VARCHAR2
    ,P_PEI_INFORMATION12        in VARCHAR2
    ,P_PEI_INFORMATION13        in VARCHAR2
    ,P_PEI_INFORMATION14        in VARCHAR2
    ,P_PEI_INFORMATION15        in VARCHAR2
    ,P_PEI_INFORMATION16        in VARCHAR2
    ,P_PEI_INFORMATION17        in VARCHAR2
    ,P_PEI_INFORMATION18        in VARCHAR2
    ,P_PEI_INFORMATION19        in VARCHAR2
    ,P_PEI_INFORMATION20        in VARCHAR2
    ,P_PEI_INFORMATION21        in VARCHAR2
    ,P_PEI_INFORMATION22        in VARCHAR2
    ,P_PEI_INFORMATION23        in VARCHAR2
    ,P_PEI_INFORMATION24        in VARCHAR2
    ,P_PEI_INFORMATION25        in VARCHAR2
    ,P_PEI_INFORMATION26        in VARCHAR2
    ,P_PEI_INFORMATION27        in VARCHAR2
    ,P_PEI_INFORMATION28        in VARCHAR2
    ,P_PEI_INFORMATION29        in VARCHAR2
    ,P_PEI_INFORMATION30        in VARCHAR2);
  --
PROCEDURE UPDATE_PL_PERSON_EXTRA_INFO
   (P_PERSON_EXTRA_INFO_ID     in NUMBER
   ,P_PEI_INFORMATION_CATEGORY in VARCHAR2
   ,P_PEI_INFORMATION1         in VARCHAR2
   ,P_PEI_INFORMATION2         in VARCHAR2
   ,P_PEI_INFORMATION3         in VARCHAR2
   ,P_PEI_INFORMATION4         in VARCHAR2
   ,P_PEI_INFORMATION5         in VARCHAR2
   ,P_PEI_INFORMATION6         in VARCHAR2
   ,P_PEI_INFORMATION7         in VARCHAR2
   ,P_PEI_INFORMATION8         in VARCHAR2
   ,P_PEI_INFORMATION9         in VARCHAR2
   ,P_PEI_INFORMATION10        in VARCHAR2
   ,P_PEI_INFORMATION11        in VARCHAR2
   ,P_PEI_INFORMATION12        in VARCHAR2
   ,P_PEI_INFORMATION13        in VARCHAR2
   ,P_PEI_INFORMATION14        in VARCHAR2
   ,P_PEI_INFORMATION15        in VARCHAR2
   ,P_PEI_INFORMATION16        in VARCHAR2
   ,P_PEI_INFORMATION17        in VARCHAR2
   ,P_PEI_INFORMATION18        in VARCHAR2
   ,P_PEI_INFORMATION19        in VARCHAR2
   ,P_PEI_INFORMATION20        in VARCHAR2
   ,P_PEI_INFORMATION21        in VARCHAR2
   ,P_PEI_INFORMATION22        in VARCHAR2
   ,P_PEI_INFORMATION23        in VARCHAR2
   ,P_PEI_INFORMATION24        in VARCHAR2
   ,P_PEI_INFORMATION25        in VARCHAR2
   ,P_PEI_INFORMATION26        in VARCHAR2
   ,P_PEI_INFORMATION27        in VARCHAR2
   ,P_PEI_INFORMATION28        in VARCHAR2
   ,P_PEI_INFORMATION29        in VARCHAR2
   ,P_PEI_INFORMATION30        in VARCHAR2);
  --
END PER_PL_PERSON_EXTRA_INFO;

 

/