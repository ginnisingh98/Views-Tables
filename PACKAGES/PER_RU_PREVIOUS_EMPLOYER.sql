--------------------------------------------------------
--  DDL for Package PER_RU_PREVIOUS_EMPLOYER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RU_PREVIOUS_EMPLOYER" AUTHID CURRENT_USER as
/* $Header: perupemp.pkh 120.0.12000000.1 2007/01/22 03:58:56 appldev noship $ */
PROCEDURE CREATE_RU_PREVIOUS_EMPLOYER(P_BUSINESS_GROUP_ID	NUMBER
				     ,P_PERSON_ID		NUMBER
				     ,P_START_DATE		DATE
				     ,P_END_DATE		DATE
				     ,P_PEM_INFORMATION_CATEGORY VARCHAR2);

PROCEDURE UPDATE_RU_PREVIOUS_EMPLOYER(P_PREVIOUS_EMPLOYER_ID	NUMBER
				     ,P_START_DATE		DATE
				     ,P_END_DATE		DATE
				     ,P_PEM_INFORMATION_CATEGORY VARCHAR2);

PROCEDURE CREATE_RU_PREVIOUS_JOB(P_PREVIOUS_EMPLOYER_ID NUMBER
				,P_START_DATE		DATE
				,P_END_DATE		DATE);

PROCEDURE UPDATE_RU_PREVIOUS_JOB(P_PREVIOUS_JOB_ID	NUMBER
				,P_START_DATE		DATE
				,P_END_DATE		DATE);
END PER_RU_PREVIOUS_EMPLOYER;

 

/