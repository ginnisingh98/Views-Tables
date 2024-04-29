--------------------------------------------------------
--  DDL for Package PAY_HK_AVG_PAY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_HK_AVG_PAY" AUTHID CURRENT_USER AS
/* $Header: pyhkavgpay.pkh 120.0 2007/12/14 09:03:57 vamittal noship $ */

/* Bug 6318006 This function finds the time period start date for dimension _ASG_12MTHS_PREV */
FUNCTION TIME_START
(
    p_effective_date             IN         DATE
   ,p_assignment_action_id       IN         NUMBER
) RETURN DATE ;

/* Bug 6318006
This Function will fetch the specified date from element entry of absence element for dimension _ASG_12MTHS_PREV */

Function SPECIFIED_DATE_ABSENCE
( p_date_earned                IN         DATE
 ,p_assignment_id              IN         NUMBER
) RETURN DATE;

/* Bug 6318006
This Function will fetch the specified date from element entry of Specified Date Element for dimension _ASG_12MTHS_PREV */

Function SPECIFIED_DATE_ELEMENT
( p_date_earned                IN         DATE
 ,p_assignment_id              IN         NUMBER
) RETURN DATE;

/* Bug 6318006
This Formula Function will fetch the Number of days for dimension _ASG_12MTHS_PREV */

Function NO_OF_DAYS
( p_assignment_action_id              IN         NUMBER
) RETURN NUMBER;

END PAY_HK_AVG_PAY;

/
