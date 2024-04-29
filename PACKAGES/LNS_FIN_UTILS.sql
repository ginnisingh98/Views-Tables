--------------------------------------------------------
--  DDL for Package LNS_FIN_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."LNS_FIN_UTILS" AUTHID CURRENT_USER AS
/* $Header: LNS_FIN_UTILS_S.pls 120.5.12010000.6 2010/02/05 18:20:57 mbolli ship $ */

/*========================================================================+
|  Declare PUBLIC Data Types and Variables
+========================================================================*/
    TYPE DATE_TBL   IS TABLE OF DATE INDEX BY BINARY_INTEGER;


/*========================================================================+
|  types for building payment schedule
+========================================================================*/
    TYPE PAYMENT_SCHEDULE is record(PERIOD_BEGIN_DATE  DATE
                                   ,PERIOD_END_DATE    DATE
                                   ,PERIOD_DUE_DATE    DATE
                                   ,CONTENTS           VARCHAR(30)  -- row contents: PRIN, INT, PRIN_INT
                                   );

    TYPE PAYMENT_SCHEDULE_TBL is table of PAYMENT_SCHEDULE index by binary_integer;

/* BEGIN DATE FUNCTIONS */
function getNextDate(p_date          in date
                    ,p_interval_type in varchar2
                    ,p_direction     in number) return Date;

function getDayCount(p_start_date       in date
                    ,p_end_date         in date
                    ,p_day_count_method in varchar2) return number;

function daysInYear(p_year              in number
                   ,p_year_count_method in varchar2) return number;

function julian_date(p_date in date) return number;

function isLeapYear(p_year in number) return boolean;

function intervalsInPeriod(p_period_number in number
                          ,p_period_type1  in varchar2
                          ,p_period_type2  in varchar2) return number;

function buildPaymentSchedule(p_loan_start_date    in date
                             ,p_loan_maturity_date in date
                             ,p_first_pay_date     in date
                             ,p_num_intervals      in number
                             ,p_interval_type      in varchar2
                             ,p_pay_in_arrears     in boolean) return LNS_FIN_UTILS.PAYMENT_SCHEDULE_TBL;

function buildSIPPaymentSchedule(p_loan_start_date    in date
                             ,p_loan_maturity_date    in date
                             ,p_int_first_pay_date    in date
                             ,p_int_num_intervals     in number
                             ,p_int_interval_type     in varchar2
                             ,p_int_pay_in_arrears    in boolean
                             ,p_prin_first_pay_date   in date
                             ,p_prin_num_intervals    in number
                             ,p_prin_interval_type    in varchar2
                             ,p_prin_pay_in_arrears   in boolean) return LNS_FIN_UTILS.PAYMENT_SCHEDULE_TBL;

function convertPeriod(p_term                   in number
                      ,p_term_period            in varchar2) return number;

/* END DATE FUNCTIONS */

/* BEGIN LOAN PROPERTIES FUNCTIONS */
function getMaturityDate(p_term           in number
                        ,p_term_period    in varchar2
                        ,p_frequency      in varchar2
                        ,p_start_date     in date) return date;

-- fix for bug 5842639: added p_loan_start_date parameter
function getPaymentSchedule(p_loan_start_date in date
                           ,p_first_pay_date in date
                           ,p_maturity_date  in date
                           ,p_pay_in_arrears in boolean
                           ,p_num_intervals  in number
                           ,p_interval_type  in varchar2) return LNS_FIN_UTILS.DATE_TBL;

function getInstallmentDate(p_loan_id IN NUMBER
                           ,p_installment_number IN NUMBER) return date;

function getNumberInstallments(p_loan_id in number) return NUMBER;

function getNumberInstallments(p_loan_id in number
                              ,p_phase   in varchar2) return NUMBER;

function getActiveRate(p_loan_id in number) return number;

/* END LOAN PROPERTIES FUNCTIONS */

/* BEGIN RATE FUNCTIONS */
function convertRate(p_annualized_rate        in number
                    ,p_amortization_frequency in varchar2) return number;

function getRateForDate(p_index_rate_id   in number
                       ,p_rate_date       in date) return number;
/* END RATE FUNCTIONS */


function buildPaymentScheduleExt(p_loan_id in number
                              ,p_phase   in varchar2) return LNS_FIN_UTILS.PAYMENT_SCHEDULE_TBL;



/*=========================================================================
|| PUBLIC FUNCTION getNextInstallmentAfterDate - R12
||
|| DESCRIPTION
||
|| Overview:  returns the installmentNumber for the provided date for a loan
||
|| Parameter: p_loan_id  => loan_id
||	      p_date	 => date for which the installment exists
||            p_phase    => phase of the loan
||
|| Return value:  installment number
||
|| Source Tables: LNS_LOAN_HEADERS_ALL, LNS_TERMS
||
|| Target Tables:  NA
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 13-Jan-2010           mbolli         Bug#9255294 -  Created
 *=======================================================================*/
function getNextInstallmentAfterDate(p_loan_id in number
				    ,p_date in date
                                    ,p_phase   in varchar2) return NUMBER;


/*=========================================================================
|| PUBLIC FUNCTION getNextInstForDisbursement - R12
||
|| DESCRIPTION
||
|| Overview:  returns the installmentNumber for the provided disbursement
||
|| Parameter: p_loan_id  => disb_header_id
||
|| Return value:  installment number
||
|| Source Tables: LNS_DISB_HEADERS
||
|| Target Tables:  NA
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 05-Feb-2010           mbolli         Bug#9255294 -  Created
 *=======================================================================*/
function getNextInstForDisbursement(p_disb_hdr_id in number)   return NUMBER;


END LNS_FIN_UTILS;

/
