--------------------------------------------------------
--  DDL for Package PER_ES_ABSENCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ES_ABSENCE" AUTHID CURRENT_USER AS
/* $Header: peesabsp.pkh 120.1 2007/06/21 15:33:11 rbaker ship $  */
    --
    PROCEDURE person_entry_create(p_business_group_id            IN NUMBER
                                 ,p_absence_attendance_id        IN NUMBER
                                 ,p_date_start                   IN DATE
                                 ,p_date_end                     IN DATE
                                 ,p_abs_information_category     IN VARCHAR2
                                 ,p_abs_information1             IN VARCHAR2
                                 ,p_abs_information2             IN VARCHAR2
                                 ,p_abs_information3             IN VARCHAR2
                                 ,p_abs_information4             IN VARCHAR2
                                 ,p_abs_information5             IN VARCHAR2
                                 ,p_abs_information6             IN VARCHAR2
                                 ,p_abs_information7             IN VARCHAR2
                                 ,p_abs_information8             IN VARCHAR2
                                 ,p_abs_information9             IN VARCHAR2
                                 ,p_abs_information10            IN VARCHAR2);
    --
    PROCEDURE person_entry_update(p_absence_attendance_id        IN NUMBER
                                 ,p_date_start                   IN DATE
                                 ,p_date_end                     IN DATE
                                 ,p_abs_information_category     IN VARCHAR2
                                 ,p_abs_information1             IN VARCHAR2
                                 ,p_abs_information2             IN VARCHAR2
                                 ,p_abs_information3             IN VARCHAR2
                                 ,p_abs_information4             IN VARCHAR2
                                 ,p_abs_information5             IN VARCHAR2
                                 ,p_abs_information6             IN VARCHAR2
                                 ,p_abs_information7             IN VARCHAR2
                                 ,p_abs_information8             IN VARCHAR2
                                 ,p_abs_information9             IN VARCHAR2
                                 ,p_abs_information10            IN VARCHAR2);
    --
    PROCEDURE validate_abs_create(p_business_group_id            IN NUMBER
                                 ,p_person_id                    IN NUMBER
                                 ,p_absence_attendance_type_id   IN NUMBER
                                 ,p_date_start                   IN DATE
                                 ,p_time_start                   IN VARCHAR2
                                 ,p_date_end                     IN DATE
                                 ,p_time_end                     IN VARCHAR2
                                 ,p_abs_information_category     IN VARCHAR2
                                 ,p_abs_information1             IN VARCHAR2
                                 ,p_abs_information2             IN VARCHAR2
                                 ,p_abs_information3             IN VARCHAR2
                                 ,p_abs_information4             IN VARCHAR2
                                 ,p_abs_information5             IN VARCHAR2
                                 ,p_abs_information6             IN VARCHAR2
                                 ,p_abs_information7             IN VARCHAR2
                                 ,p_abs_information8             IN VARCHAR2
                                 ,p_abs_information9             IN VARCHAR2
                                 ,p_abs_information10            IN VARCHAR2);
    --
    PROCEDURE validate_abs_update(p_absence_attendance_id        IN NUMBER
                                 ,p_date_start                   IN DATE
                                 ,p_time_start                   IN VARCHAR2
                                 ,p_date_end                     IN DATE
                                 ,p_time_end                     IN VARCHAR2
                                 ,p_abs_information_category     IN VARCHAR2
                                 ,p_abs_information1             IN VARCHAR2
                                 ,p_abs_information2             IN VARCHAR2
                                 ,p_abs_information3             IN VARCHAR2
                                 ,p_abs_information4             IN VARCHAR2
                                 ,p_abs_information5             IN VARCHAR2
                                 ,p_abs_information6             IN VARCHAR2
                                 ,p_abs_information7             IN VARCHAR2
                                 ,p_abs_information8             IN VARCHAR2
                                 ,p_abs_information9             IN VARCHAR2
                                 ,p_abs_information10            IN VARCHAR2);
    --
END per_es_absence;

/
