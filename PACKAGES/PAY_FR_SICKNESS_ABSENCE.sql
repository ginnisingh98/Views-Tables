--------------------------------------------------------
--  DDL for Package PAY_FR_SICKNESS_ABSENCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FR_SICKNESS_ABSENCE" AUTHID CURRENT_USER AS
/* $Header: perfrabs.pkh 120.1.12000000.1 2007/01/22 03:13:59 appldev ship $  */
--
PROCEDURE PERSON_ABSENCE_CREATE(
         p_business_group_id            IN number
        ,p_abs_information_category     IN varchar2
        ,p_person_id                    IN Number
        ,p_date_start                   IN Date
        ,p_date_end                     IN Date
        ,p_abs_information1             IN Varchar2 default NULL
        ,p_abs_information4             IN Varchar2 default NULL
        ,p_abs_information5             IN Varchar2 default NULL
        ,p_abs_information6             IN Varchar2 default NULL
	,p_abs_information7             IN Varchar2 default NULL
	,p_abs_information8             IN Varchar2 default NULL
        ,p_abs_information9             IN Varchar2 default NULL
        ,p_abs_information10            IN Varchar2 default NULL
        ,p_abs_information11            IN Varchar2 default NULL
        ,p_abs_information12            IN Varchar2 default NULL
         );
--
procedure PERSON_ABSENCE_UPDATE(
 	 p_absence_attendance_id        IN Number
        ,p_abs_information_category     IN varchar2
        ,p_date_start                   IN Date
        ,p_date_end                     IN Date
        ,p_abs_information1             IN Varchar2 default NULL
        ,p_abs_information4             IN Varchar2 default NULL
        ,p_abs_information5             IN Varchar2 default NULL
        ,p_abs_information6             IN Varchar2 default NULL
	,p_abs_information7             IN Varchar2 default NULL
	,p_abs_information8             IN Varchar2 default NULL
	,p_abs_information9             IN Varchar2 default NULL
        ,p_abs_information10            IN Varchar2 default NULL
        ,p_abs_information11            IN Varchar2 default NULL
        ,p_abs_information12            IN Varchar2 default NULL
        );
--
procedure PERSON_ENTRY_CREATE(
         p_business_group_id		IN Number
	,p_absence_attendance_id        IN Number
	,p_abs_information_category     IN varchar2
        ,p_date_start                   IN Date
        );
--
procedure PERSON_ENTRY_UPDATE(
	 p_absence_attendance_id        IN Number
	,p_abs_information_category     IN varchar2
        ,p_date_start                   IN Date
        );
-- Added for additional holidays
PROCEDURE check_add_abs_ent_create(p_absence_days               in  number,
                                   p_absence_attendance_type_id in  number,
                                   p_date_start                 in  date,
                                   p_person_id                  in  number);
--
PROCEDURE check_add_abs_ent_update(p_absence_days               in  number,
                                   p_absence_attendance_id      in  number,
                                   p_date_start                 in  date);



PROCEDURE CHK_TRG_CATG_HRS(
         p_abs_information_category     IN varchar2
        ,p_abs_information1             IN Varchar2
        -- added for bug#4104220
	,p_abs_information5             IN Varchar2
	,p_abs_information6             IN Varchar2
	,p_abs_information7             IN Varchar2
	,p_abs_information8             IN Varchar2
	,p_abs_information9             IN Varchar2
	,p_abs_information10            IN Varchar2
	,p_abs_information11            IN Varchar2
	,p_abs_information12            IN Varchar2
	,p_abs_information13            IN Varchar2
	,p_abs_information14            IN Varchar2
	,p_abs_information15            IN Varchar2
	,p_abs_information16            IN Varchar2
	,p_abs_information18            IN Varchar2
	,p_abs_information19            IN Varchar2
        --
        ,p_abs_information20            IN Varchar2
        -- Added for bug 5218081
        ,p_abs_information21            IN Varchar2
        ,p_abs_information22            IN Varchar2
        -- added for validating leave category
        ,p_date_start                   IN Date);

--
END PAY_FR_SICKNESS_ABSENCE;

/
