--------------------------------------------------------
--  DDL for Package IGS_AD_ASSIGN_REVIEW_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_ASSIGN_REVIEW_GRP" AUTHID CURRENT_USER AS
/* $Header: IGSADB3S.pls 120.0 2005/06/02 04:21:55 appldev noship $ */
PROCEDURE assign_review_group(
	ERRBUF                         OUT NOCOPY VARCHAR2,
        RETCODE                        OUT NOCOPY NUMBER,
	P_APPL_REV_PROFILE_ID          IN NUMBER,
	P_ENTRY_STAT_ID                IN NUMBER,
	P_NOMINATED_COURSE_CD          IN VARCHAR2,
	P_PERSON_ID                    IN NUMBER,
	P_UNIT_SET_CD                  IN VARCHAR2,
	P_CALENDAR_DETAILS             IN VARCHAR2,
	P_ADMISSION_PROCESS_CATEGORY   IN VARCHAR2,
        P_ORG_ID                       IN NUMBER) ;
END Igs_ad_assign_review_grp ;

 

/
