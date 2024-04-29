--------------------------------------------------------
--  DDL for Package PAY_NO_ABS_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NO_ABS_VALIDATION" AUTHID CURRENT_USER AS
/* $Header: pynoabsval.pkh 120.0.12000000.1 2007/07/09 12:55:23 pdavidra noship $ */

PROCEDURE CREATE_ABS_VALIDATION ( P_ABS_INFORMATION_CATEGORY varchar2
                                    ,P_PERSON_ID in NUMBER
				    ,P_EFFECTIVE_DATE in DATE
				    ,P_ABS_INFORMATION1 in VARCHAR2
                                    ,P_ABS_INFORMATION2 in VARCHAR2
                                    ,P_ABS_INFORMATION3 in VARCHAR2
                                    ,P_ABS_INFORMATION5 in VARCHAR2
                                    ,P_ABS_INFORMATION6 in VARCHAR2
                                    ,P_ABS_INFORMATION15 in VARCHAR2
                                    ,P_ABS_INFORMATION16 in VARCHAR2
                                    ,P_DATE_START in DATE
                                    ,P_DATE_END in DATE
				    ,P_DATE_PROJECTED_START in DATE
				    ,P_DATE_PROJECTED_END in DATE
                                    ,P_ABS_ATTENDANCE_REASON_ID in NUMBER);

PROCEDURE UPDATE_ABS_VALIDATION (P_ABS_INFORMATION_CATEGORY in varchar2
                                    ,P_ABSENCE_ATTENDANCE_ID in NUMBER
                                    ,P_EFFECTIVE_DATE in DATE
                                    ,P_ABS_INFORMATION1 in VARCHAR2
                                    ,P_ABS_INFORMATION2 in VARCHAR2
                                    ,P_ABS_INFORMATION3 in VARCHAR2
                                    ,P_ABS_INFORMATION5 in VARCHAR2
                                    ,P_ABS_INFORMATION6 in VARCHAR2
                                    ,P_ABS_INFORMATION15 in VARCHAR2
                                    ,P_ABS_INFORMATION16 in VARCHAR2
                                    ,P_DATE_START in DATE
                                    ,P_DATE_END in DATE
				    ,P_DATE_PROJECTED_START in DATE
				    ,P_DATE_PROJECTED_END in DATE
                                    ,P_ABS_ATTENDANCE_REASON_ID in NUMBER) ;

END PAY_NO_ABS_VALIDATION;

 

/
