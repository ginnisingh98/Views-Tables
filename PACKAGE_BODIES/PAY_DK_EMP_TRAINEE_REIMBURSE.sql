--------------------------------------------------------
--  DDL for Package Body PAY_DK_EMP_TRAINEE_REIMBURSE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_DK_EMP_TRAINEE_REIMBURSE" AS
/* $Header: pydkaerrpt.pkb 120.16.12010000.2 2009/10/12 14:43:56 rsahai ship $ */
 --
 -- Global Data
 --
 TYPE t_xml_element_rec IS RECORD
  (tagname  VARCHAR2(100)
  ,tagvalue VARCHAR2(500));
 --
 TYPE t_xml_element_table IS TABLE OF t_xml_element_rec INDEX BY BINARY_INTEGER;
 --
 g_xml_element_table     t_xml_element_table;
 --
 -- -----------------------------------------------------------------------------
 -- Get the correct characterset for XML generation
 -- -----------------------------------------------------------------------------
 --
 FUNCTION get_IANA_charset RETURN VARCHAR2 IS
   CURSOR csr_get_iana_charset IS
     SELECT tag
       FROM fnd_lookup_values
      WHERE lookup_type = 'FND_ISO_CHARACTER_SET_MAP'
        AND lookup_code = SUBSTR(USERENV('LANGUAGE'),
                                    INSTR(USERENV('LANGUAGE'), '.') + 1)
        AND language = 'US';
 --
  lv_iana_charset fnd_lookup_values.tag%type;
 BEGIN
   OPEN csr_get_iana_charset;
     FETCH csr_get_iana_charset INTO lv_iana_charset;
   CLOSE csr_get_iana_charset;
   RETURN (lv_iana_charset);
 END get_IANA_charset;
 --
 --
 -- -----------------------------------------------------------------------------
 -- Takes XML element from a table and puts them into a CLOB.
 -- -----------------------------------------------------------------------------
 --
 PROCEDURE write_to_clob
 (p_clob OUT NOCOPY CLOB) IS
  --
  l_xml_element_template1 VARCHAR2(30) := '<TAG>VALUE</TAG>';
  l_xml_element_template2 VARCHAR2(10) := '<TAG>';
  l_xml_element_template3 VARCHAR2(10) := '</TAG>';
  l_str1                  VARCHAR2(80) ;
  l_str2                  VARCHAR2(20) := ' </ROOT>';
  l_xml_element           VARCHAR2(800);
  l_clob                  CLOB;
  --
 BEGIN
  --
--  l_str1 := '<?xml version="1.0" encoding="UTF-8"?> <ROOT>';
  l_str1 := '<?xml version="1.0" encoding="' || get_IANA_charset || '"?> <ROOT>';

  dbms_lob.createtemporary(l_clob, FALSE, DBMS_LOB.CALL);
  dbms_lob.open(l_clob, DBMS_LOB.LOB_READWRITE);
  --
  dbms_lob.writeappend(l_clob, LENGTH(l_str1), l_str1);
  --
  IF g_xml_element_table.COUNT > 0 THEN
   FOR table_counter IN g_xml_element_table.FIRST .. g_xml_element_table.LAST LOOP
    IF g_xml_element_table(table_counter).tagvalue = '_START_' THEN
     l_xml_element := REPLACE(l_xml_element_template2, 'TAG', g_xml_element_table(table_counter).tagname);
    ELSIF g_xml_element_table(table_counter).tagvalue = '_END_' THEN
     l_xml_element := REPLACE(l_xml_element_template3, 'TAG', g_xml_element_table(table_counter).tagname);
    ELSE
     l_xml_element := REPLACE(
                        REPLACE (l_xml_element_template1, 'TAG', g_xml_element_table(table_counter).tagname)
                          ,'VALUE', g_xml_element_table(table_counter).tagvalue);
    END IF;
    --
    dbms_lob.writeappend(l_clob, LENGTH(l_xml_element), l_xml_element);
   END LOOP;
  END IF;
  --
  dbms_lob.writeappend(l_clob, LENGTH(l_str2), l_str2);
  --
  p_clob := l_clob;
  --
  EXCEPTION
   WHEN OTHERS THEN
     hr_utility.set_location(sqlerrm(sqlcode),110);
  --
 END write_to_clob;
--
-------------------------------------------------------------------------------------------------------------------------
/*  Populate details procedure to construct XML output */
   -- NAME
   --  populate_details
   -- PURPOSE
   --  To generate XML output for employer trainee reimbursement report.
   -- ARGUMENTS
   --  P_QUARTER           - Quarter the report to run.
   --  P_LEGAL_EMPLOYER_ID - Legal employer id.
   --  P_BUSINESS_GROUP_ID - Business group id.
   --  P_TEMPLATE_NAME     - The name of the template.
   --  P_XML               - Output variable keeps the resulted xml.
   -- USES
   -- NOTES
   --  This is used to generate XML output for Employer trainee reimbursement report.
   --  This will fetch all person's available under the inputted business group and legal employer.
   --  It calculates the sum of employer and employee's reimbursement for the given input quarter
   --  to arrive the total AER contribution.
-------------------------------------------------------------------------------------------------------------------------

PROCEDURE POPULATE_DETAILS ( P_QUARTER            IN  VARCHAR2,
                             P_LEGAL_EMPLOYER_ID  IN  NUMBER,
                             P_BUSINESS_GROUP_ID  IN  NUMBER,
                             P_EFFECTIVE_DATE1    IN  VARCHAR2, --Bug 4895163 fix
                             P_TEMPLATE_NAME      IN  VARCHAR2,
                             P_XML                OUT NOCOPY CLOB
			                 )
    IS
--       XMLRESULT      CLOB;
--       XMLIDENT       DBMS_XMLQUERY.CTXTYPE;
--       SQLSTR         VARCHAR2(4000);
       L_QTR_START    DATE;
       L_QTR_END      DATE;
       L_EMPR_BAL     NUMBER;
       L_EMPE_BAL     NUMBER;
       L_TOTAL_ATP    NUMBER := 0;
       L_GLOBAL_RATE  NUMBER(30,7);
       L_GLOBAL_ATP   NUMBER(30,7);
       L_OLDEMP       NUMBER := 0;
       L_EMPR_BAL_ID  NUMBER;
       L_EMPE_BAL_ID  NUMBER;

       l_emp_count    NUMBER := 0;
       l_ded_1        NUMBER := 1;
       l_ded_50       NUMBER := 0;
       l_ded_trainee  NUMBER := 0;
       l_tot_emp_aer  NUMBER := 0;
       l_tot_qtr_aer  NUMBER := 0;

       P_EFFECTIVE_DATE     DATE;
       l_trainee_status CHAR ;
       -- Introduced for character set conversion on XML generation
--       lv_clob        CLOB;
--       l_iana_charset VARCHAR2(100);
--       lv_offset      NUMBER;
  l_xml_element_count NUMBER := 1;

    -- Cursor to fetch the payroll details of all the persons with primary assignment for the inputted quarter.
/*    CURSOR C1(QUARTER_START DATE, QUARTER_END DATE)
    IS
    SELECT PASG.PERSON_ID, PASG.ASSIGNMENT_ID, MAX(PAA.ASSIGNMENT_ACTION_ID) AS ASSIGNMENT_ACTION_ID,
           PPA.PAYROLL_ID, MAX(PPA.DATE_EARNED) AS EFFECTIVE_DATE, PAP.PER_INFORMATION3
    FROM   PER_ALL_PEOPLE_F PAP
           ,PER_ALL_ASSIGNMENTS_F ASG
	       ,PAY_PAYROLL_ACTIONS PPA
           ,PAY_ASSIGNMENT_ACTIONS PAA
           ,PAY_RUN_RESULTS PRR
           ,PAY_ELEMENT_TYPES_F PET
           ,PER_ALL_ASSIGNMENTS_F PASG
    WHERE  PAP.PERSON_ID = ASG.PERSON_ID
      AND  ASG.PAYROLL_ID = PPA.PAYROLL_ID
      AND  ASG.ASSIGNMENT_ID = PAA.ASSIGNMENT_ID
      AND  PPA.PAYROLL_ACTION_ID = PAA.PAYROLL_ACTION_ID
      AND  PAA.ASSIGNMENT_ACTION_ID = PRR.ASSIGNMENT_ACTION_ID
      AND  PET.ELEMENT_TYPE_ID = PRR.ELEMENT_TYPE_ID
      AND  PASG.ASSIGNMENT_ID = PAA.ASSIGNMENT_ID
      AND  PET.LEGISLATION_CODE = 'DK'
      AND  PPA.BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID
      AND  PAA.TAX_UNIT_ID = P_LEGAL_EMPLOYER_ID
      AND  PET.ELEMENT_NAME IN ('Employee ATP', 'Employer ATP')
      AND  PPA.DATE_EARNED BETWEEN QUARTER_START AND QUARTER_END
      AND  QUARTER_END BETWEEN PET.EFFECTIVE_START_DATE AND PET.EFFECTIVE_END_DATE
      AND  PASG.ASSIGNMENT_STATUS_TYPE_ID = 1
      AND  PAP.CURRENT_EMPLOYEE_FLAG = 'Y'
      AND  PAP.EFFECTIVE_START_DATE <= QUARTER_END
      AND  PAP.EFFECTIVE_END_DATE >= QUARTER_START
      AND  PASG.EFFECTIVE_START_DATE <= QUARTER_END
      AND  PASG.EFFECTIVE_END_DATE >= QUARTER_START
      AND  ASG.EFFECTIVE_START_DATE <= QUARTER_END
      AND  ASG.EFFECTIVE_END_DATE >= QUARTER_START
      GROUP BY PASG.PERSON_ID, PASG.ASSIGNMENT_ID, PPA.PAYROLL_ID, PAP.PER_INFORMATION3
      ORDER BY PASG.PERSON_ID, PASG.ASSIGNMENT_ID;*/

  -- Cursor to fetch the payroll details of all the persons with primary assignment for the inputted quarter.
  /*Bug 4895163 fix- Modified the cursor to get the details for each month*/
    CURSOR C1(QUARTER_START DATE, QUARTER_END DATE)
    IS
    SELECT
        PERSON_ID ,
        ASSIGNMENT_ID ,
        ASSIGNMENT_ACTION_ID,
        PAYROLL_ID,
        EFFECTIVE_DATE,
        PER_INFORMATION3,
        EFFECTIVE_START_DATE,
        EFFECTIVE_END_DATE,
        LEAD (ASSIGNMENT_ID,1) OVER (ORDER BY PERSON_ID, ASSIGNMENT_ID,EFFECTIVE_DATE,EFFECTIVE_START_DATE,
           EFFECTIVE_END_DATE) AS LEAD_ASSIGNMENT_ID,
        LEAD (EFFECTIVE_DATE,1) OVER (ORDER BY PERSON_ID, ASSIGNMENT_ID,EFFECTIVE_DATE,EFFECTIVE_START_DATE,
           EFFECTIVE_END_DATE) AS LEAD_EFFECTIVE_DATE
   FROM (
    SELECT ASG.PERSON_ID, ASG.ASSIGNMENT_ID, PAA.ASSIGNMENT_ACTION_ID ASSIGNMENT_ACTION_ID,
           PPA.PAYROLL_ID, PPA.DATE_EARNED EFFECTIVE_DATE, PAP.PER_INFORMATION3,
           PAP.EFFECTIVE_START_DATE,
           PAP.EFFECTIVE_END_DATE
    FROM   PER_ALL_PEOPLE_F PAP
           ,PER_ALL_ASSIGNMENTS_F ASG
	       ,PAY_PAYROLL_ACTIONS PPA
           ,PAY_ASSIGNMENT_ACTIONS PAA
           ,PAY_RUN_RESULTS PRR
           ,PAY_ELEMENT_TYPES_F PET
    WHERE  PAP.PERSON_ID = ASG.PERSON_ID
      AND  ASG.PAYROLL_ID = PPA.PAYROLL_ID
      AND  ASG.ASSIGNMENT_ID = PAA.ASSIGNMENT_ID
      AND  PPA.PAYROLL_ACTION_ID = PAA.PAYROLL_ACTION_ID
      AND PPA.ACTION_TYPE IN ('R','Q')  -- Payroll Run or Quickpay Run
      AND  PAA.ASSIGNMENT_ACTION_ID = PRR.ASSIGNMENT_ACTION_ID
      AND  PET.ELEMENT_TYPE_ID = PRR.ELEMENT_TYPE_ID
      AND  PET.LEGISLATION_CODE = 'DK'
      AND  PPA.BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID
      AND  PAA.TAX_UNIT_ID = P_LEGAL_EMPLOYER_ID
      AND  PET.ELEMENT_NAME IN ('Employee ATP', 'Employer ATP')
      AND  PPA.DATE_EARNED BETWEEN QUARTER_START AND QUARTER_END
      AND  ASG.ASSIGNMENT_STATUS_TYPE_ID = 1
      AND  PAP.CURRENT_EMPLOYEE_FLAG = 'Y'
      /* Date check for the date tracked tables*/
      AND TO_CHAR(PPA.DATE_EARNED,'MM/YYYY') BETWEEN to_char(PAP.EFFECTIVE_START_DATE,'MM/YYYY') AND TO_CHAR(PAP.EFFECTIVE_END_DATE,'MM/YYYY')
      AND TO_CHAR (PPA.DATE_EARNED,'MM/YYYY') BETWEEN to_char(ASG.EFFECTIVE_START_DATE,'MM/YYYY') AND TO_CHAR(ASG.EFFECTIVE_END_DATE,'MM/YYYY')
      AND  PPA.DATE_EARNED BETWEEN PET.EFFECTIVE_START_DATE AND PET.EFFECTIVE_END_DATE
      GROUP BY ASG.PERSON_ID, ASG.ASSIGNMENT_ID, PAA.ASSIGNMENT_ACTION_ID,
               PPA.PAYROLL_ID, PPA.DATE_EARNED, PAP.PER_INFORMATION3,
               PAP.EFFECTIVE_START_DATE,PAP.EFFECTIVE_END_DATE
      ORDER BY ASG.PERSON_ID, ASG.ASSIGNMENT_ID,PPA.DATE_EARNED,PAP.EFFECTIVE_START_DATE,
               PAP.EFFECTIVE_END_DATE);


    -- Cursor to fetch the defined balance id for the given balance and dimension name.
    CURSOR C2 (BAL_NAME VARCHAR2, DIM_NAME VARCHAR2)
    IS
    SELECT DEFINED_BALANCE_ID
    FROM  PAY_BALANCE_TYPES PBT
        , PAY_DEFINED_BALANCES PDB
    	, PAY_BALANCE_DIMENSIONS PBD
    WHERE PDB.BALANCE_TYPE_ID = PBT.BALANCE_TYPE_ID
      AND PDB.BALANCE_DIMENSION_ID = PBD.BALANCE_DIMENSION_ID
      AND PBT.BALANCE_NAME = BAL_NAME
     AND PBD.DATABASE_ITEM_SUFFIX = DIM_NAME;

    -- Cursor to fetch global values
    CURSOR C3(GLB_NAME VARCHAR2, QUARTER_END DATE)
    IS
    SELECT TRIM(GLOBAL_VALUE)
    FROM  FF_GLOBALS_F GLB
    WHERE QUARTER_END BETWEEN GLB.EFFECTIVE_START_DATE AND GLB.EFFECTIVE_END_DATE
      AND GLB.GLOBAL_NAME = GLB_NAME
      AND GLB.LEGISLATION_CODE = 'DK';

    BEGIN
    g_xml_element_table.DELETE;
         -- Plsql block to select effective date from fnd_sessions table.
       /* Bug 4895163 fix- Taking the effective date as input parameter*/
       /* BEGIN
            SELECT TRUNC(EFFECTIVE_DATE)
            INTO P_EFFECTIVE_DATE
            FROM FND_SESSIONS
            WHERE SESSION_ID=USERENV('SESSIONID');
         EXCEPTION
            WHEN OTHERS THEN
            P_EFFECTIVE_DATE := SYSDATE;
         END;*/
      --lv_offset := 23;
      -- Create a temporary LOB to store the generated XML.
--      DBMS_LOB.CREATETEMPORARY (XMLRESULT, TRUE, DBMS_LOB.SESSION);
--      DBMS_LOB.CREATETEMPORARY (lv_clob, TRUE, DBMS_LOB.SESSION);
      /*Converting the P_EFFECTIVE_DATE1 parameter to date and assigning it to P_EFFECTIVE_DATE*/
      P_EFFECTIVE_DATE :=FND_DATE.CANONICAL_TO_DATE(P_EFFECTIVE_DATE1);
      -- Control structure to identify which Quarter the report to be executed
      IF P_QUARTER = 1 THEN
           L_QTR_START := TO_DATE('01/01/'||TO_CHAR(P_EFFECTIVE_DATE,'YYYY'), 'DD/MM/YYYY');
           L_QTR_END   := TO_DATE('31/03/'||TO_CHAR(P_EFFECTIVE_DATE,'YYYY'), 'DD/MM/YYYY');
      ELSIF P_QUARTER = 2 THEN
           L_QTR_START := TO_DATE('01/04/'||TO_CHAR(P_EFFECTIVE_DATE,'YYYY'), 'DD/MM/YYYY');
           L_QTR_END   := TO_DATE('30/06/'||TO_CHAR(P_EFFECTIVE_DATE,'YYYY'), 'DD/MM/YYYY');

 --     ELSIF P_QUARTER = 1 THEN
     ELSIF P_QUARTER = 3 THEN --Bug 4895163 fix
           L_QTR_START := TO_DATE('01/07/'||TO_CHAR(P_EFFECTIVE_DATE,'YYYY'), 'DD/MM/YYYY');
           L_QTR_END   := TO_DATE('30/09/'||TO_CHAR(P_EFFECTIVE_DATE,'YYYY'), 'DD/MM/YYYY');

--      ELSIF P_QUARTER = 1 THEN
      ELSIF P_QUARTER = 4 THEN  --Bug 4895163 fix
           L_QTR_START := TO_DATE('01/10/'||TO_CHAR(P_EFFECTIVE_DATE,'YYYY'), 'DD/MM/YYYY');
           L_QTR_END   := TO_DATE('31/12/'||TO_CHAR(P_EFFECTIVE_DATE,'YYYY'), 'DD/MM/YYYY');
      END IF;

        -- To fetch employer defined balance id
--        OPEN C2('Employer ATP Deductions', '_ASG_LE_QTD');
        OPEN C2('Employer ATP Deductions', '_ASG_PTD');	--8858949
        FETCH C2 INTO L_EMPR_BAL_ID;
        CLOSE C2;

        -- To fetch employee defined balance id
--        OPEN C2('Employee ATP Deductions', '_ASG_LE_QTD');
        OPEN C2('Employee ATP Deductions', '_ASG_PTD');	--8858949
        FETCH C2 INTO L_EMPE_BAL_ID;
        CLOSE C2;

        -- To fetch GLOBAL VALUE of AER_ATPAMOUNT_QUARTER
        OPEN C3 ('DK_AER_ATPAMOUNT_QUARTER', L_QTR_END);
        FETCH C3 INTO L_GLOBAL_ATP;
        CLOSE C3;

        -- To fetch GLOBAL VALUE of AER_RATE
        OPEN C3 ('DK_AER_RATE', L_QTR_END);
        FETCH C3 INTO L_GLOBAL_RATE;
        CLOSE C3;

     FOR C1REC IN C1(l_qtr_start, l_qtr_end)
     LOOP
     /*To check if there are multiple rows for the same assignment in the same payroll run,if present then taking the last one*/
     IF (C1REC.ASSIGNMENT_ID = NVL(C1REC.LEAD_ASSIGNMENT_ID,'-999')AND C1REC.EFFECTIVE_DATE = C1REC.LEAD_EFFECTIVE_DATE) THEN
        NULL; -- if true then go to next record
     ELSE
        IF NVL(C1REC.PER_INFORMATION3,'N') = 'N' THEN
           --  To get employer ATP contribution balance value
           L_EMPR_BAL := PAY_BALANCE_PKG.GET_VALUE (L_EMPR_BAL_ID,
                                                    C1REC.ASSIGNMENT_ACTION_ID,
                                                    P_LEGAL_EMPLOYER_ID,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    C1REC.EFFECTIVE_DATE
                                                    );

           -- To get employee ATP contribution balance value
           L_EMPE_BAL := PAY_BALANCE_PKG.GET_VALUE (L_EMPE_BAL_ID,
                                                    C1REC.ASSIGNMENT_ACTION_ID,
                                                    P_LEGAL_EMPLOYER_ID,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    C1REC.EFFECTIVE_DATE
                                                    );
        END IF ;
           -- Total ATP contribution both employer and employee.
           L_TOTAL_ATP := L_TOTAL_ATP + nvl(L_EMPR_BAL,0) + nvl(L_EMPE_BAL,0) ;
           L_EMPR_BAL := 0;
           L_EMPE_BAL := 0;
           -- To fetch the no of trainees
       /*    IF L_OLDEMP <> C1REC.PERSON_ID THEN
               IF C1REC.PER_INFORMATION3 = 'Y' THEN
                   L_DED_TRAINEE := L_DED_TRAINEE + 1;
               END IF;
           L_OLDEMP := C1REC.PERSON_ID;
           END IF;*/
           -- To fetch the no of trainees
    /*Bug 4895163 fix- Chcking the previous employee trainee status in order to get the latest value*/
           IF L_OLDEMP <> C1REC.PERSON_ID AND L_OLDEMP <> 0 THEN
              IF l_trainee_status = 'Y' THEN
                   L_DED_TRAINEE := L_DED_TRAINEE + 1;
               END IF;
            END IF;
          L_OLDEMP := C1REC.PERSON_ID;
        l_trainee_status := NVL(C1REC.PER_INFORMATION3,'N');
      END IF ;
      END LOOP;
  /*Bug 4895163 fix- Getting the trainee status for the last employee in the loop*/
      IF l_trainee_status = 'Y' THEN
              L_DED_TRAINEE := L_DED_TRAINEE + 1;
      END IF;
    l_emp_count := round((l_total_atp/l_global_atp),2);
      l_ded_50    := FLOOR(l_emp_count/50);
      l_tot_emp_aer := l_emp_count - (l_ded_1 + l_ded_50 + l_ded_trainee);

      IF l_tot_emp_aer < 0 OR NVL(l_total_atp,0) = 0 THEN
         l_total_atp := NULL;
         l_emp_count := NULL;
         l_ded_1     := NULL;
         l_ded_50    := NULL;
         l_ded_trainee := NULL;
         l_tot_emp_aer := NULL;
         l_tot_qtr_aer := NULL;

         -- Set the message
         hr_utility.set_message (801, 'PAY_377056_DK_NEGATIVE_ERR');
         -- Put the meassage in the log file
      ELSE
         l_tot_qtr_aer := round((round(l_tot_emp_aer,2) * l_global_rate),2);
      END IF;

      -- Constructing a dynamic string to feed query to dbms_xmlquery which will generate XML output.
/*      SQLSTR := 'SELECT '''|| TO_CHAR(NVL(FND_NUMBER.canonical_to_number(round(l_total_atp,2)),0) ,'999G999G990D99' ) || ''' as "TotalATP",'''
                         || TO_CHAR(NVL(FND_NUMBER.canonical_to_number(round(l_emp_count,2)),0) ,'999G999G990D99' ) || ''' as "FullTimeEmpCount",'''
                         || l_ded_1     ||''' as "Deduction1",'''
                         || l_ded_50    ||''' as "Deduction50",'''
                         || l_ded_trainee ||''' as "DeductionTrainee",'''
                         || TO_CHAR(NVL(FND_NUMBER.canonical_to_number(round(l_tot_emp_aer,2)),0) ,'999G999G990D99' ) ||''' as "TotalAER",'''
                         || TO_CHAR(NVL(FND_NUMBER.canonical_to_number(l_tot_qtr_aer),0) ,'999G999G990D99' ) ||''' as "TotalAERQuarter" from dual';
      XMLIDENT := DBMS_XMLQUERY.NEWCONTEXT(SQLSTR);
      DBMS_XMLQUERY.SETROWSETTAG (XMLIDENT, 'AERReport');
      DBMS_XMLQUERY.SETROWTAG (XMLIDENT, 'Employee');
      DBMS_XMLQUERY.GETXML(XMLIDENT, XMLRESULT);
      DBMS_XMLQUERY.CLOSECONTEXT(XMLIDENT);
      DBMS_LOB.ERASE(XMLRESULT, LV_OFFSET, 1 );
      l_iana_charset := PAY_DK_GENERAL.get_IANA_charset();
      LV_CLOB := '<?xml version="1.0" encoding="'||l_iana_charset||'"?> ' ;
      DBMS_LOB.APPEND (LV_CLOB, XMLRESULT );
      -- Assign the resulted XML into output variable
      */
   g_xml_element_table(l_xml_element_count).tagname  := 'AERReport';
   g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
   l_xml_element_count := l_xml_element_count + 1;
   --
   g_xml_element_table(l_xml_element_count).tagname  := 'TotalATP';
   g_xml_element_table(l_xml_element_count).tagvalue := TO_CHAR(NVL(FND_NUMBER.canonical_to_number(round(l_total_atp,2)),0) ,'999G999G990D99');
   l_xml_element_count := l_xml_element_count + 1;
   --
   g_xml_element_table(l_xml_element_count).tagname  := 'FullTimeEmpCount';
   g_xml_element_table(l_xml_element_count).tagvalue :=  TO_CHAR(NVL(FND_NUMBER.canonical_to_number(round(l_emp_count,2)),0) ,'999G999G990D99');
   l_xml_element_count := l_xml_element_count + 1;
   --
   g_xml_element_table(l_xml_element_count).tagname  := 'Deduction1';
   g_xml_element_table(l_xml_element_count).tagvalue := l_ded_1;
   l_xml_element_count := l_xml_element_count + 1;
   --
   g_xml_element_table(l_xml_element_count).tagname  := 'Deduction50';
   g_xml_element_table(l_xml_element_count).tagvalue := l_ded_50;
   l_xml_element_count := l_xml_element_count + 1;
   --
   g_xml_element_table(l_xml_element_count).tagname  := 'DeductionTrainee';
   g_xml_element_table(l_xml_element_count).tagvalue := l_ded_trainee;
   l_xml_element_count := l_xml_element_count + 1;
   --
   g_xml_element_table(l_xml_element_count).tagname  := 'TotalAER';
   g_xml_element_table(l_xml_element_count).tagvalue := TO_CHAR(NVL(FND_NUMBER.canonical_to_number(round(l_tot_emp_aer,2)),0) ,'999G999G990D99' );
   l_xml_element_count := l_xml_element_count + 1;
   --
   g_xml_element_table(l_xml_element_count).tagname  := 'TotalAERQuarter';
   g_xml_element_table(l_xml_element_count).tagvalue :=  TO_CHAR(NVL(FND_NUMBER.canonical_to_number(l_tot_qtr_aer),0) ,'999G999G990D99');
   l_xml_element_count := l_xml_element_count + 1;
   --
   g_xml_element_table(l_xml_element_count).tagname  := 'AERReport';
   g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
   l_xml_element_count := l_xml_element_count + 1;
   --
   write_to_clob(P_XML);
   --
   --      DBMS_LOB.FREETEMPORARY(XMLRESULT);
   --      DBMS_LOB.FREETEMPORARY(LV_CLOB);
   --
   END POPULATE_DETAILS;
 --
END PAY_DK_EMP_TRAINEE_REIMBURSE;

/
