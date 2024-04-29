--------------------------------------------------------
--  DDL for Package Body PER_ORG_MAN_COUNT_NAME_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ORG_MAN_COUNT_NAME_PKG" AS
/* $Header: pewspor1.pkb 120.1.12010000.1 2008/07/28 06:08:05 appldev ship $ */
--
/*
+======================================================================+
|                Copyright (c) 1993 Oracle Corporation                 |
|                   Redwood Shores, California, USA                    |
|                        All rights reserved.                          |
+======================================================================+

   Name
	Richard Metcalf
   Purpose
        Count the number of managers in the organization and
	if there is one put the managers name
	count the number of organizations the employee is in
        and if there is only puts the organization name
   History
    28-OCT-93 R Metcalf created
    04-OCT-94 R Fine	Renamed package to conform to naming standards.
    31-JUL-96 J Alloun  Added error handling.
    20-JUN-97 70.7  LMA 1) Fixed bug 507611
    		            NLSP16.1 FRM-40735 WHEN-VALIDATE-ITEM
    		            TRIGGER RAISED UNHANDLED EXCEPTION VALUE_E
    		            by change MANAGER_NAME from varchar2(60) to
    		            PER_ALL_PEOPLE_F.E.FULL_NAME%type and
    		            ORGANIZATION_NAME from varchar2(60) to
    		            HR_ALL_ORGANIZATION_UNITS.NAME%type
    		            2) Fixed hard coded messages
    24-Jun-97 70.8 teyres   Changed as to is on create or replace line
    25-Jun-97 110.1/70.9 teyres 110.1 and 70.9 are the same
    03-DEC-97 110.2      mbocutt Add missing token substitution in message
                                 HR_NUM_ORGANIZATIONS.
    04-DEC-98 115.1      tfilippi Changed ORGANIZATION_COUNT_NAME to support MLS
18-JUN-1999 714621 115.2 asahay  added p_manager_flag to
				 organization_count_name procedure
    30-DEC-99 115.3 ccarter Bug 1123545, changed length of manager_desc_flex
                            to 80 and manager_flag to 30.
    14-SEP-00 115.4 jpbard  Added support for global org hierarchies
    17-JUL-07 115.6 sathkris Changed the length of the variable NO_OF_MANAGERS
                             FROM 3 TO 4 for bug 6219536
*/
--
PROCEDURE MANAGER_COUNT_NAME(P_ORGANIZATION_ID IN NUMBER,
	       P_BUSINESS_GROUP_ID IN NUMBER,
			     P_SESSION_DATE IN DATE,
			     P_MANAGER IN OUT NOCOPY VARCHAR2 ) IS
        MANAGER_NAME PER_ALL_PEOPLE_F.FULL_NAME%type;
   	    NO_OF_MANAGERS NUMBER(4); --FIX FOR BUG 6219536
BEGIN
        SELECT COUNT(DISTINCT E.PERSON_ID),
           MAX(E.FULL_NAME)
        INTO
	       NO_OF_MANAGERS,
	       MANAGER_NAME
	    FROM
	       PER_ALL_PEOPLE_F E,
	       PER_ALL_ASSIGNMENTS_F A
      WHERE (E.CURRENT_EMPLOYEE_FLAG = 'Y' OR
             E.CURRENT_NPW_FLAG = 'Y')
      AND A.PERSON_ID             = E.PERSON_ID
	     AND A.ORGANIZATION_ID       = P_ORGANIZATION_ID
	     AND ((A.ASSIGNMENT_TYPE       = 'E' AND
            A.MANAGER_FLAG          = 'Y') OR
           (A.ASSIGNMENT_TYPE       = 'C' AND
            A.MANAGER_FLAG          = 'Y'))
	     AND P_SESSION_DATE BETWEEN
	     E.EFFECTIVE_START_DATE AND E.EFFECTIVE_END_DATE
	     AND P_SESSION_DATE BETWEEN
	     A.EFFECTIVE_START_DATE AND A.EFFECTIVE_END_DATE;

         --
         --If there is only one manager put the mnager's name
         --

	     IF NO_OF_MANAGERS = 0 THEN
	        fnd_message.set_name('PER', 'HR_NO_CURRENT_MANAGERS');
	        P_MANAGER := fnd_message.get; --'** No Current Managers **';
	     ELSIF NO_OF_MANAGERS = 1 THEN
	        P_MANAGER := MANAGER_NAME;
	     ELSE
		    fnd_message.set_name('PER', 'HR_NUM_CURRENT_MANAGERS');
		    fnd_message.set_token('number', to_char(NO_OF_MANAGERS)); --'** num Current Managers **';
	        P_MANAGER := fnd_message.get;
         END IF;
END;
--
--Count the number of organizations that the employee is in
--
PROCEDURE ORGANIZATION_COUNT_NAME
     (P_ORGANIZATION               IN OUT NOCOPY VARCHAR2,
				  P_MANAGER_FLAG_DESC          IN OUT NOCOPY VARCHAR2,
				  P_MANAGER_FLAG               IN OUT NOCOPY VARCHAR2,
			   P_PERSON_ID                  IN            NUMBER,
			   P_SESSION_DATE               IN            DATE,
      P_ORGANIZATION_ID            IN            NUMBER,
			   P_ORGANIZATION_STRUCTURE_ID  IN            NUMBER,
			   P_BUSINESS_GROUP_ID          IN            NUMBER,
			   P_VERSION_ID                 IN            NUMBER,
      P_USER_PERSON_TYPE              OUT NOCOPY VARCHAR2) IS
  --
  NO_OF_ORGS NUMBER(3);
  ORGANIZATION_NAME HR_ALL_ORGANIZATION_UNITS.NAME%type;
  MANAGER_FLAG_DESC VARCHAR2(80);
  MANAGER_FLAG      VARCHAR2(30);
  --
BEGIN
    SELECT
COUNT(DISTINCT(TO_CHAR(A.ORGANIZATION_ID)||NVL(MANAGER_FLAG,'N'))),
	       MAX(OTL.NAME),
	       MAX(L.MEANING),
	       MAX(NVL(A.MANAGER_FLAG,'N'))
    INTO   NO_OF_ORGS,
	       ORGANIZATION_NAME,
           MANAGER_FLAG_DESC,
           MANAGER_FLAG
    FROM   PER_ALL_ASSIGNMENTS_F A,
           HR_ALL_ORGANIZATION_UNITS O,
           HR_ALL_ORGANIZATION_UNITS_TL OTL,
	   FND_LOOKUPS L
    WHERE  A.PERSON_ID = P_PERSON_ID
    AND    (A.ASSIGNMENT_TYPE = 'E' OR A.ASSIGNMENT_TYPE = 'C')
    AND    P_SESSION_DATE BETWEEN
                A.EFFECTIVE_START_DATE AND A.EFFECTIVE_END_DATE
    AND    O.ORGANIZATION_ID = A.ORGANIZATION_ID
    AND    O.ORGANIZATION_ID = OTL.ORGANIZATION_ID
    AND    OTL.LANGUAGE = USERENV('LANG')
    AND    ((O.ORGANIZATION_ID = P_ORGANIZATION_ID AND
           P_ORGANIZATION_STRUCTURE_ID IS NULL)
    OR     (P_ORGANIZATION_STRUCTURE_ID IS NOT NULL AND
    EXISTS
	           (SELECT 1
                   FROM   PER_ORG_STRUCTURE_ELEMENTS E
        	   WHERE  O.ORGANIZATION_ID
		       IN (E.ORGANIZATION_ID_CHILD,E.ORGANIZATION_ID_PARENT)
                   AND    E.ORG_STRUCTURE_VERSION_ID = P_VERSION_ID)))
    AND     L.LOOKUP_CODE = NVL(A.MANAGER_FLAG,'N')
    AND     L.LOOKUP_TYPE = 'YES_NO';

    --
	--If there is only one organization then put the organization name
	--

     IF NO_OF_ORGS = 0 THEN
        fnd_message.set_name('PER', 'HR_NO_ORGANIZATIONS');
        P_ORGANIZATION := fnd_message.get; --'** No Organizations **'
        P_MANAGER_FLAG_DESC := NULL;
        P_MANAGER_FLAG := NULL;
     ELSIF NO_OF_ORGS = 1 THEN
       --
      	P_ORGANIZATION := ORGANIZATION_NAME;
      	P_MANAGER_FLAG_DESC := MANAGER_FLAG_DESC;
      	P_MANAGER_FLAG := MANAGER_FLAG;
       --
       p_user_person_type := hr_person_type_usage_info.get_user_person_type
                               (p_effective_date => p_session_date
                               ,p_person_id      => p_person_id);
       --
     ELSE
        fnd_message.set_name('PER', 'HR_NUM_ORGANIZATIONS');
	fnd_message.set_token('number', to_char(NO_OF_ORGS));
        P_ORGANIZATION := fnd_message.get; --'** num Organizations **'
        P_MANAGER_FLAG_DESC := NULL;
        P_MANAGER_FLAG := NULL;
     END IF;
END;
end per_org_man_count_name_pkg;

/
