--------------------------------------------------------
--  DDL for Package PER_IN_EXTRA_ASG_INFO_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_IN_EXTRA_ASG_INFO_LEG_HOOK" AUTHID CURRENT_USER AS
/* $Header: peinlhae.pkh 120.0 2005/05/31 10:12 appldev noship $ */

PROCEDURE check_asg_extra_info_insert(
         p_assignment_id            IN NUMBER
        ,p_aei_information_category IN VARCHAR2
        ,p_aei_information1         IN VARCHAR2
        ,p_aei_information2         IN VARCHAR2
        ,p_aei_information3         IN VARCHAR2
        ,p_aei_information4         IN VARCHAR2
        ,p_aei_information5         IN VARCHAR2
        ,p_aei_information6         IN VARCHAR2
        ,p_aei_information7         IN VARCHAR2
        ,p_aei_information8         IN VARCHAR2
        ,p_aei_information9         IN VARCHAR2
        ,p_aei_information10        IN VARCHAR2
        ,p_aei_information11        IN VARCHAR2
        ,p_aei_information12        IN VARCHAR2
        ,p_aei_information13        IN VARCHAR2
        ,p_aei_information14        IN VARCHAR2
        ,p_aei_information15        IN VARCHAR2
        ,p_aei_information16        IN VARCHAR2
        ,p_aei_information17        IN VARCHAR2
        ,p_aei_information18        IN VARCHAR2
        ,p_aei_information19        IN VARCHAR2
        ,p_aei_information20        IN VARCHAR2
        ,p_aei_information21        IN VARCHAR2
        ,p_aei_information22        IN VARCHAR2
        ,p_aei_information23        IN VARCHAR2
        ,p_aei_information24        IN VARCHAR2
        ,p_aei_information25        IN VARCHAR2
        ,p_aei_information26        IN VARCHAR2
        ,p_aei_information27        IN VARCHAR2
        ,p_aei_information28        IN VARCHAR2
        ,p_aei_information29        IN VARCHAR2
        ,p_aei_information30        IN VARCHAR2
        ) ;

PROCEDURE check_asg_extra_info_update(
         p_assignment_extra_info_id IN NUMBER
        ,p_aei_information_category IN VARCHAR2
        ,p_aei_information1         IN VARCHAR2
        ,p_aei_information2         IN VARCHAR2
        ,p_aei_information3         IN VARCHAR2
        ,p_aei_information4         IN VARCHAR2
        ,p_aei_information5         IN VARCHAR2
        ,p_aei_information6         IN VARCHAR2
        ,p_aei_information7         IN VARCHAR2
        ,p_aei_information8         IN VARCHAR2
        ,p_aei_information9         IN VARCHAR2
        ,p_aei_information10        IN VARCHAR2
        ,p_aei_information11        IN VARCHAR2
        ,p_aei_information12        IN VARCHAR2
        ,p_aei_information13        IN VARCHAR2
        ,p_aei_information14        IN VARCHAR2
        ,p_aei_information15        IN VARCHAR2
        ,p_aei_information16        IN VARCHAR2
        ,p_aei_information17        IN VARCHAR2
        ,p_aei_information18        IN VARCHAR2
        ,p_aei_information19        IN VARCHAR2
        ,p_aei_information20        IN VARCHAR2
        ,p_aei_information21        IN VARCHAR2
        ,p_aei_information22        IN VARCHAR2
        ,p_aei_information23        IN VARCHAR2
        ,p_aei_information24        IN VARCHAR2
        ,p_aei_information25        IN VARCHAR2
        ,p_aei_information26        IN VARCHAR2
        ,p_aei_information27        IN VARCHAR2
        ,p_aei_information28        IN VARCHAR2
        ,p_aei_information29        IN VARCHAR2
        ,p_aei_information30        IN VARCHAR2
        ) ;

PROCEDURE check_asg_extra_info_int(
         p_assignment_id            IN NUMBER
        ,p_assignment_extra_info_id IN NUMBER   default null
        ,p_aei_information_category IN VARCHAR2
        ,p_aei_information1         IN VARCHAR2
        ,p_aei_information2         IN VARCHAR2
        ,p_aei_information3         IN VARCHAR2
        ,p_aei_information4         IN VARCHAR2
        ,p_aei_information5         IN VARCHAR2
        ,p_aei_information6         IN VARCHAR2
        ,p_aei_information7         IN VARCHAR2
        ,p_aei_information8         IN VARCHAR2
        ,p_aei_information9         IN VARCHAR2
        ,p_aei_information10        IN VARCHAR2
        ,p_aei_information11        IN VARCHAR2
        ,p_aei_information12        IN VARCHAR2
        ,p_aei_information13        IN VARCHAR2
        ,p_aei_information14        IN VARCHAR2
        ,p_aei_information15        IN VARCHAR2
        ,p_aei_information16        IN VARCHAR2
        ,p_aei_information17        IN VARCHAR2
        ,p_aei_information18        IN VARCHAR2
        ,p_aei_information19        IN VARCHAR2
        ,p_aei_information20        IN VARCHAR2
        ,p_aei_information21        IN VARCHAR2
        ,p_aei_information22        IN VARCHAR2
        ,p_aei_information23        IN VARCHAR2
        ,p_aei_information24        IN VARCHAR2
        ,p_aei_information25        IN VARCHAR2
        ,p_aei_information26        IN VARCHAR2
        ,p_aei_information27        IN VARCHAR2
        ,p_aei_information28        IN VARCHAR2
        ,p_aei_information29        IN VARCHAR2
        ,p_aei_information30        IN VARCHAR2
        ,p_message                  OUT NOCOPY VARCHAR2
        ,p_token_name               OUT NOCOPY pay_in_utils.char_tab_type
        ,p_token_value              OUT NOCOPY pay_in_utils.char_tab_type) ;

END  per_in_extra_asg_info_leg_hook;

 

/
