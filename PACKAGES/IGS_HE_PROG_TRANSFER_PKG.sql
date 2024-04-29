--------------------------------------------------------
--  DDL for Package IGS_HE_PROG_TRANSFER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_PROG_TRANSFER_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSHE17S.pls 115.2 2002/11/29 00:42:59 nsidana noship $ */


PROCEDURE Hesa_Stud_Susa_Trans(
                               p_person_id IN NUMBER,
                               p_old_course_cd IN VARCHAR2,
                               p_new_course_cd IN VARCHAR2,
                               p_old_unit_set_cd IN VARCHAR2,
                               p_new_unit_set_cd IN VARCHAR2,
                               p_old_us_version_number IN NUMBER,
                               p_new_us_version_number IN NUMBER,
                               p_status  OUT NOCOPY VARCHAR2,
                               p_message_name OUT NOCOPY VARCHAR2 );

PROCEDURE HESA_Stud_Stat_Trans(
                               p_person_id IN NUMBER,
                               p_old_course_cd IN VARCHAR2,
                               p_new_course_cd IN VARCHAR2,
                               p_status OUT NOCOPY VARCHAR2,
                               p_message_name OUT NOCOPY VARCHAR2);

END IGS_HE_PROG_TRANSFER_PKG;


 

/
