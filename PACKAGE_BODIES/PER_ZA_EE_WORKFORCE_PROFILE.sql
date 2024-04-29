--------------------------------------------------------
--  DDL for Package Body PER_ZA_EE_WORKFORCE_PROFILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ZA_EE_WORKFORCE_PROFILE" AS
/* $Header: PERZAEWP.pkb 120.0.12010000.1 2009/12/09 06:18:34 nchinnam noship $ */

   FUNCTION BEFOREREPORT RETURN BOOLEAN IS
   BEGIN
      PER_ZA_EMPLOYMENT_EQUITY_PKG.POPULATE_EE_TABLE_EEWF_NEW(P_REPORT_DATE
                                                         ,P_BUSINESS_GROUP_ID
                                                         ,P_LEGAL_ENTITY_ID);

      CP_TO_DATE := to_char(P_REPORT_DATE,'DD/MM/YYYY');
      CP_FROM_DATE := to_char(ADD_MONTHS(P_REPORT_DATE,-12) + 1,'DD/MM/YYYY');
      CP_SUBMISSION_DATE := to_char(P_SUBMISSION_DATE,'DD/MM/YYYY');
      RETURN (TRUE);
   END BEFOREREPORT;

   FUNCTION GET_SETA_CLASSIFICATION(P_LEGAL_ENTITY_ID IN NUMBER,P_BUSINESS_GROUP_ID IN NUMBER) RETURN CHAR IS
      CURSOR SETA_CLASS(P_ORG_ID IN NUMBER) IS
      SELECT ORG_INFORMATION4 SETA_CLASSIFICATION
        FROM HR_ORGANIZATION_INFORMATION HOI
       WHERE HOI.ORGANIZATION_ID = P_ORG_ID
         AND HOI.ORG_INFORMATION_CONTEXT = 'ZA_NQF_SETA_INFO';
   BEGIN
      FOR seta_rec IN SETA_CLASS(P_LEGAL_ENTITY_ID) LOOP
         RETURN (SETA_REC.SETA_CLASSIFICATION);
      END LOOP;
      FOR seta_rec1 IN SETA_CLASS(P_BUSINESS_GROUP_ID) LOOP
         RETURN (SETA_REC1.SETA_CLASSIFICATION);
      END LOOP;
      RETURN (NULL);
   END GET_SETA_CLASSIFICATION;

   FUNCTION CF_EQ2_ALL_TOTALFORMULA(REPORT_ID IN VARCHAR2,ALL_TOTAL IN NUMBER) RETURN NUMBER IS
   BEGIN
     IF REPORT_ID = 'EQ2' THEN
       RETURN (ALL_TOTAL);
     END IF;
     RETURN (0);
   END CF_EQ2_ALL_TOTALFORMULA;


   FUNCTION CF_PAGE_NUMBERSFORMULA(REPORT_ID IN VARCHAR2) RETURN VARCHAR2 IS
      V_PAGE_NO VARCHAR2(5);
   BEGIN
      IF REPORT_ID = 'EQ2' THEN
         V_PAGE_NO := '3';
     ELSIF REPORT_ID = 'EQ3' THEN
       V_PAGE_NO := '4';
     ELSIF REPORT_ID = 'EQ5' THEN
       V_PAGE_NO := '5';
     ELSIF REPORT_ID = 'EQ7' THEN
       V_PAGE_NO := '6';
     END IF;
     RETURN (V_PAGE_NO);
   END CF_PAGE_NUMBERSFORMULA;

   FUNCTION CF_HEADINGFORMULA(REPORT_ID IN VARCHAR2) RETURN VARCHAR2 IS
   BEGIN
      IF REPORT_ID = 'EQ2' THEN
         RETURN ('SECTION B: WORKFORCE PROFILE AND CORE & SUPPORT FUNCTIONS');
      END IF;
      IF REPORT_ID = 'EQ5' THEN
         RETURN ('SECTION C: WORKFORCE MOVEMENT');
      END IF;
      RETURN NULL;
   END CF_HEADINGFORMULA;

   FUNCTION CF_MAIN_TABLE_NOFORMULA(REPORT_ID IN VARCHAR2) RETURN CHAR IS
   BEGIN
     IF (REPORT_ID = 'EQ2') THEN
       RETURN ('1.');
     END IF;
     IF (REPORT_ID = 'EQ3') THEN
       RETURN ('2.');
     END IF;
     IF (REPORT_ID = 'EQ5') THEN
       RETURN ('3.');
     END IF;
     IF (REPORT_ID = 'EQ6') THEN
       RETURN ('4.');
     END IF;
     IF (REPORT_ID = 'EQ7') THEN
       RETURN ('5.');
     END IF;
     RETURN (NULL);
   END CF_MAIN_TABLE_NOFORMULA;

   FUNCTION CF_SUB_HEADINGFORMULA(REPORT_ID IN VARCHAR2) RETURN CHAR IS
   BEGIN
      IF REPORT_ID = 'EQ2' THEN
         RETURN ('WORKFORCE PROFILE');
      END IF;
      IF REPORT_ID = 'EQ3' THEN
         RETURN ('Core Operation Functions and Support Functions by Occupational level');
      END IF;
      IF REPORT_ID = 'EQ5' THEN
         RETURN ('Recruitment');
      END IF;
      IF REPORT_ID = 'EQ6' THEN
         RETURN ('Promotion');
      END IF;
      IF REPORT_ID = 'EQ7' THEN
         RETURN ('Termination');
      END IF;
      RETURN (NULL);
   END CF_SUB_HEADINGFORMULA;

   FUNCTION CF_SUB_TABLE_NOFORMULA(REPORT_ID IN VARCHAR2) RETURN CHAR IS
   BEGIN
      IF (REPORT_ID = 'EQ2') THEN
         RETURN ('1.1');
      END IF;
      IF (REPORT_ID = 'EQ3') THEN
         RETURN ('2.1');
      END IF;
      IF (REPORT_ID = 'EQ4') THEN
         RETURN ('2.2');
      END IF;
      IF (REPORT_ID = 'EQ5') THEN
         RETURN ('3.1');
      END IF;
      IF (REPORT_ID = 'EQ6') THEN
         RETURN ('4.1');
      END IF;
      IF (REPORT_ID = 'EQ7') THEN
         RETURN ('5.1');
      END IF;
      IF (REPORT_ID = 'EQ8') THEN
         RETURN ('5.2');
      END IF;
      RETURN (NULL);
   END CF_SUB_TABLE_NOFORMULA;

   FUNCTION CF_TITLEFORMULA(REPORT_ID IN VARCHAR2) RETURN VARCHAR2 IS
   BEGIN
     IF REPORT_ID = 'EQ2' THEN
       RETURN ('Please report the total number of');
     END IF;
     IF REPORT_ID = 'EQ3' THEN
       RETURN ('Please indicate the total number of employees (including people with disabilities), that are involved in');
     END IF;
     IF REPORT_ID = 'EQ4' THEN
       RETURN ('Please indicate the total number of employees (including people with disabilities), that are involved in');
     END IF;
     IF REPORT_ID = 'EQ5' THEN
       RETURN ('Please report the total number of new recruits, including people with disabilities.');
     END IF;
     IF REPORT_ID = 'EQ6' THEN
       RETURN ('Please report the total number of promotions into each occupational level, including people with disabilities.');
     END IF;
     IF REPORT_ID = 'EQ7' THEN
       RETURN ('Please report the total number of terminations in each occupational level, including people with disabilities.');
     END IF;
     IF REPORT_ID = 'EQ8' THEN
       RETURN ('Please report the total number of terminations, including people with disabilities, in each');
     END IF;
     RETURN NULL;
   END CF_TITLEFORMULA;

   FUNCTION CF_TITLE1FORMULA(REPORT_ID IN VARCHAR2) RETURN CHAR IS
   BEGIN
     IF (REPORT_ID = 'EQ2') THEN
       RETURN (' employees');
     END IF;
     IF (REPORT_ID = 'EQ3') THEN
       RETURN (' Core Operation Function');
     END IF;
     IF (REPORT_ID = 'EQ4') THEN
       RETURN (' Support Function');
     END IF;
     IF (REPORT_ID = 'EQ8') THEN
       RETURN (' termination category');
     END IF;
     RETURN (NULL);
   END CF_TITLE1FORMULA;

   FUNCTION CF_TITLE2FORMULA(REPORT_ID IN VARCHAR2) RETURN CHAR IS
   BEGIN
     IF (REPORT_ID = 'EQ2') THEN
       RETURN (' (including employees with disabilities) in each of the following');
     END IF;
     IF (REPORT_ID = 'EQ3') THEN
       RETURN (' positions at each level in your organization only.');
     END IF;
     IF (REPORT_ID = 'EQ4') THEN
       RETURN (' positions at each level in your organization.');
     END IF;
     IF (REPORT_ID = 'EQ8') THEN
       RETURN (' below.');
     END IF;
     RETURN (NULL);
   END CF_TITLE2FORMULA;

   FUNCTION CF_TITLE3FORMULA(REPORT_ID IN VARCHAR2) RETURN CHAR IS
   BEGIN
     IF (REPORT_ID = 'EQ2') THEN
       RETURN (' occupational levels:');
     END IF;
     IF (REPORT_ID = 'EQ2') THEN
       RETURN (' occupational levels:');
     END IF;
     RETURN (NULL);
   END CF_TITLE3FORMULA;

END PER_ZA_EE_WORKFORCE_PROFILE;

/
