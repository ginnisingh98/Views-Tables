--------------------------------------------------------
--  DDL for Package PER_PL_PEM_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PL_PEM_INFO" AUTHID CURRENT_USER AS
/* $Header: peplpemp.pkh 120.0.12000000.1 2007/01/22 01:44:10 appldev noship $ */

PROCEDURE CREATE_PL_PREV_EMPLOYER(p_effective_date           DATE,
                                  p_business_group_id        NUMBER,
                                  p_person_id                NUMBER,
                                  p_start_date               DATE,
                                  p_end_date                 DATE,
                                  p_period_years             NUMBER,
                                  p_period_months            NUMBER,
                                  p_period_days              NUMBER,
                                  p_employer_type            VARCHAR2,
                                  p_employer_name            VARCHAR2,
                                  p_party_id                 NUMBER,
                                  p_employer_subtype         VARCHAR2,
                                  p_pem_information_category VARCHAR2,
                                  p_pem_information1         VARCHAR2,
                                  p_pem_information2         VARCHAR2,
                                  p_pem_information3         VARCHAR2,
                                  p_pem_information4         VARCHAR2,
                                  p_pem_information5         VARCHAR2,
                                  p_pem_information6         VARCHAR2);

PROCEDURE UPDATE_PL_PREV_EMPLOYER(p_effective_date           DATE,
                                  p_previous_employer_id     NUMBER,
                                  p_start_date               DATE,
                                  p_end_date                 DATE,
                                  p_period_years             NUMBER,
                                  p_period_months            NUMBER,
                                  p_period_days              NUMBER,
                                  p_employer_type            VARCHAR2,
                                  p_employer_name            VARCHAR2,
                                  p_employer_subtype         VARCHAR2,
                                  p_pem_information_category VARCHAR2,
                                  p_pem_information1         VARCHAR2,
                                  p_pem_information2         VARCHAR2,
                                  p_pem_information3         VARCHAR2,
                                  p_pem_information4         VARCHAR2,
                                  p_pem_information5         VARCHAR2,
                                  p_pem_information6         VARCHAR2);



PROCEDURE CREATE_PL_PREV_JOB(p_effective_date       DATE,
                             p_previous_employer_id NUMBER,
                             p_start_date           DATE,
                             p_end_date             DATE,
                             p_period_years         NUMBER,
                             p_period_months        NUMBER,
                             p_period_days          NUMBER,
                             p_employment_category  VARCHAR2,
                             p_pjo_information1     VARCHAR2);


PROCEDURE UPDATE_PL_PREV_JOB(p_effective_date       DATE,
                             p_previous_job_id      NUMBER,
                             p_start_date           DATE,
                             p_end_date             DATE,
                             p_period_years         NUMBER,
                             p_period_months        NUMBER,
                             p_period_days          NUMBER,
                             p_employment_category  VARCHAR2,
                             p_pjo_information1     VARCHAR2);





END PER_PL_PEM_INFO;

 

/
