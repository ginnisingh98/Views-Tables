--------------------------------------------------------
--  DDL for Package HR_IE_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_IE_UTILITY" AUTHID CURRENT_USER AS
 /* $Header: hrieutil.pkh 120.0.12010000.2 2009/12/23 09:32:54 dchindar noship $ */
 --
 --
FUNCTION validate_account_entered
(p_acc_no        IN VARCHAR2,
 p_is_iban_acc   IN varchar2 ,
 p_iban_acc      in varchar2 default NULL
 ) RETURN NUMBER;
 --
 /* Bug# 9235816 fix start */
 FUNCTION per_ie_full_name(
        p_first_name       in varchar2
       ,p_middle_names     in varchar2
       ,p_last_name        in varchar2
       ,p_known_as         in varchar2
       ,p_title            in varchar2
       ,p_suffix           in varchar2
       ,p_pre_name_adjunct in varchar2
       ,p_per_information1 in varchar2
       ,p_per_information2 in varchar2
       ,p_per_information3 in varchar2
       ,p_per_information4 in varchar2
       ,p_per_information5 in varchar2
       ,p_per_information6 in varchar2
       ,p_per_information7 in varchar2
       ,p_per_information8 in varchar2
       ,p_per_information9 in varchar2
       ,p_per_information10 in varchar2
       ,p_per_information11 in varchar2
       ,p_per_information12 in varchar2
       ,p_per_information13 in varchar2
       ,p_per_information14 in varchar2
       ,p_per_information15 in varchar2
       ,p_per_information16 in varchar2
       ,p_per_information17 in varchar2
       ,p_per_information18 in varchar2
       ,p_per_information19 in varchar2
       ,p_per_information20 in varchar2
       ,p_per_information21 in varchar2
       ,p_per_information22 in varchar2
       ,p_per_information23 in varchar2
       ,p_per_information24 in varchar2
       ,p_per_information25 in varchar2
       ,p_per_information26 in varchar2
       ,p_per_information27 in varchar2
       ,p_per_information28 in varchar2
       ,p_per_information29 in varchar2
       ,p_per_information30 in varchar2
)RETURN VARCHAR2;
 /* Bug# 9235816 fix end */


END hr_ie_utility;

/
