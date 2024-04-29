--------------------------------------------------------
--  DDL for Package Body PAY_GET_TAX_EXISTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GET_TAX_EXISTS_PKG" AS
/* $Header: pytaxexi.pkb 120.23.12010000.12 2009/12/11 17:43:23 tclewis ship $ */

/*
We are using the contexts JURISDICTION_CODE, DATE_EARNED, TAX_UNIT_ID
, ASSIGNMENT_ID  Different values on p_type that we can have: SIT_WK,SIT_RS,
SDI_EE, SDI_ER, CITY_WK, CITY_RS, COUNTY_WK, COUNTY_RS, SUI taxes. We are
also using NR but the Vertex formula doesn't ever call the function with a
p_type of NR. We have SDI_EE and SDI_ER because Rhode Island for example has EE
SDI but not ER SDI so why keep the ER balances.  Only SIT and Local exemption
rules can be set from the GRE level.  We are not going to touch school tax as
that is dependent on Residence location.  We are not going to touch head tax
the only way we would get a balance for head tax is if we take out any head tax.
If the user marks a city as non exempt then we check the jit table and see if
the city has a city tax. We are placing the City and County call to this
function only if the jurisidiction being calculated is that of a city or county
jurisdiction.  If it isn't then the Vertex formulae logic will bypass this
function. The responsibility of the NR certificate being valid will be held
responsible by the customer.  So if the user checks the NR flag then we will not
withhold SIT. SUI taxes we are calculating based on if their is a value in the j
it tables and also if it is a retiree GRE.  We are calling a retiree GRE if the GRE has a value for Transmitter Control Code.
*/

/*
New function that will check for limit tax exempts at the assignment level and
accordingly return value to the main function.
*/

FUNCTION assignment_tax_exists (p_tax_type        IN  varchar2,
                                p_assign_id       IN  number,
                                p_date_earned     IN  date,
                                p_jurisdiction_code IN varchar2)
RETURN VARCHAR2    IS

l_sdi         varchar2(5);
l_sui         varchar2(5);
l_futa        varchar2(5);
l_medi        varchar2(5);
l_fica        varchar2(5);
l_change_date varchar2(20);

CURSOR sdi_exempt IS
SELECT DECODE(pest.sdi_exempt, NULL, 'N', pest.sdi_exempt)
FROM pay_us_emp_state_tax_rules_f pest
WHERE pest.assignment_id = p_assign_id
AND  TO_DATE(l_change_date, 'DD-MM-YYYY') BETWEEN
     pest.effective_start_date AND pest.effective_end_date
AND  pest.state_code = SUBSTR(p_jurisdiction_code, 1, 2);

CURSOR sui_exempt IS
SELECT DECODE(pest.sui_exempt, NULL, 'N', pest.sui_exempt)
FROM pay_us_emp_state_tax_rules_f pest
WHERE pest.assignment_id = p_assign_id
AND  TO_DATE(l_change_date, 'DD-MM-YYYY') BETWEEN
     pest.effective_start_date AND pest.effective_end_date
AND  pest.state_code = SUBSTR(p_jurisdiction_code, 1, 2);

CURSOR futa_exempt IS
SELECT DECODE(pest.futa_tax_exempt, NULL, 'N', pest.futa_tax_exempt)
FROM pay_us_emp_fed_tax_rules_f pest
WHERE pest.assignment_id = p_assign_id
AND  TO_DATE(l_change_date, 'DD-MM-YYYY') BETWEEN
     pest.effective_start_date AND pest.effective_end_date;

CURSOR fica_exempt IS
SELECT DECODE(pest.ss_tax_exempt, NULL, 'N', pest.ss_tax_exempt)
FROM pay_us_emp_fed_tax_rules_f pest
WHERE pest.assignment_id = p_assign_id
AND  TO_DATE(l_change_date, 'DD-MM-YYYY') BETWEEN
     pest.effective_start_date AND pest.effective_end_date;

CURSOR medi_exempt IS
SELECT DECODE(pest.medicare_tax_exempt, NULL, 'N', pest.medicare_tax_exempt)
FROM pay_us_emp_fed_tax_rules_f pest
WHERE pest.assignment_id = p_assign_id
AND  TO_DATE(l_change_date, 'DD-MM-YYYY') BETWEEN
     pest.effective_start_date AND pest.effective_end_date;

BEGIN
  hr_utility.set_location('pay_get_tax_exists_pkg.assignment_tax_exists', 210);
  hr_utility.trace('The date earned is : ' || p_date_earned);
  hr_utility.trace('The assign id is : ' || TO_CHAR(p_assign_id));
  hr_utility.trace('The jurisdiction code is : ' || p_jurisdiction_code);

  l_change_date := TO_CHAR(p_date_earned, 'dd-mm-yyyy');

  hr_utility.trace('The change date earned is : ' || SUBSTR(l_change_date, 7));
  hr_utility.trace('The tax type passed is : ' || p_tax_type);

  IF p_tax_type = 'SDI' THEN

      OPEN sdi_exempt;
      FETCH sdi_exempt INTO l_sdi;

      IF sdi_exempt%NOTFOUND THEN
         l_sdi := 'N';
      END IF;
      CLOSE sdi_exempt;

      hr_utility.trace('SDI Exempt : ' || l_sdi);

      RETURN(l_sdi);

  ELSIF p_tax_type = 'SUI' THEN

      OPEN sui_exempt;
      FETCH sui_exempt INTO l_sui;

      IF sui_exempt%NOTFOUND THEN
         l_sui := 'N';
      END IF;
      CLOSE sui_exempt;

      hr_utility.trace('SUI Exempt : ' || l_sui);

      RETURN(l_sui);

  ELSIF p_tax_type = 'FUTA' THEN

      OPEN futa_exempt;
      FETCH futa_exempt INTO l_futa;

      IF futa_exempt%NOTFOUND THEN
         l_futa := 'N';
      END IF;
      CLOSE futa_exempt;

      hr_utility.trace('FUTA Exempt : ' || l_futa);

      RETURN(l_futa);

  ELSIF p_tax_type = 'FICA' THEN

      OPEN fica_exempt;
      FETCH fica_exempt INTO l_fica;

      IF fica_exempt%NOTFOUND THEN
         l_fica := 'N';
      END IF;
      CLOSE fica_exempt;

      hr_utility.trace('FICA Exempt : ' || l_fica);

      RETURN(l_fica);

  ELSIF p_tax_type = 'MEDICARE' THEN

      OPEN medi_exempt;
      FETCH medi_exempt INTO l_medi;

      IF medi_exempt%NOTFOUND THEN
         l_medi := 'N';
      END IF;
      CLOSE medi_exempt;

      hr_utility.trace('MEDI Exempt : ' || l_medi);

      RETURN(l_medi);

  END IF;

END assignment_tax_exists;

FUNCTION GET_RESIDENCE_AS_OF_1ST_JAN (p_assign_id    number,
                                      l_date_earned  varchar2)
RETURN varchar2 IS

CURSOR c_override_state_county IS
SELECT puc.state_code || '-' || puc.county_code
FROM pay_us_counties puc,
  pay_us_states pus,
  per_addresses pa,
  per_assignments_f paf
WHERE paf.assignment_id = p_assign_id
AND paf.person_id = pa.person_id
AND pa.primary_flag = 'Y'
AND TO_DATE(l_date_earned, 'DD-MM-YYYY') BETWEEN
    paf.effective_start_date AND paf.effective_end_date
AND TO_DATE(l_date_earned, 'DD-MM-YYYY') BETWEEN
    pa.date_from AND NVL(pa.date_to, TO_DATE('12-31-4712', 'mm-dd-yyyy'))
AND pus.state_abbrev = pa.add_information17 --override state
AND pus.state_code = '15' --for INDIANA
AND puc.state_code = pus.state_code
AND puc.county_name = pa.add_information19;

l_rs_county_code     varchar2(15);
l_res_adr_date_start date;

BEGIN

/*{*/
  /*
   * check to see if there is an override if there is then we do not check
   * for 1st Jan else see if the default county is valid as of 1st Jan.
   */
--  hr_utility.trace_on(null,'TAXEXIST');
  hr_utility.trace('5000 START of function GET_RESIDENCE_AS_OF_1ST_JAN ');

  OPEN  c_override_state_county;
  FETCH c_override_state_county
   INTO l_rs_county_code;
  hr_utility.trace('5010 OVERRIDE County Code : '||l_rs_county_code);
  IF c_override_state_county%NOTFOUND THEN
       hr_utility.trace('5020 OVERRIDE County Code NOT found ');
  /*{*/
    /*
     * override does not exists so get the actual address / override as of
     * 1st Jan .
     */

    BEGIN
    /*{*/
      hr_utility.trace('5030  Fetching County Code for Res Jurisdiction ');
      SELECT puc.state_code || '-' || puc.county_code,
             pa.date_from
      INTO l_rs_county_code, l_res_adr_date_start
      FROM pay_us_counties puc,
        pay_us_states pus,
        per_addresses pa,
        per_assignments_f paf
      WHERE paf.assignment_id = p_assign_id
      AND paf.person_id = pa.person_id
      AND pa.primary_flag = 'Y'
      AND TO_DATE(l_date_earned, 'DD-MM-YYYY') BETWEEN
          paf.effective_start_date AND paf.effective_end_date
      AND TO_DATE(l_date_earned, 'DD-MM-YYYY') BETWEEN
          pa.date_from AND NVL(pa.date_to, TO_DATE('12-31-4712', 'mm-dd-yyyy'))
      AND pus.state_abbrev = pa.region_2                   --actual state
      AND pus.state_code   = '15' --for INDIANA
      AND puc.state_code   = pus.state_code
      AND puc.county_name  = pa.region_1;                   --actual county
      hr_utility.trace('5040  Resident County Code Found : '||l_rs_county_code);
      hr_utility.trace('5050  Resident County Code Eff Start Date : '
                       ||to_char(l_res_adr_date_start,'DD-MON-YYYY'));
      /* This condition added to fix bug # 3710639 */
      IF  (l_res_adr_date_start <= TRUNC(TO_DATE(l_date_earned, 'DD-MM-YYYY'),'Y'))
      THEN
          hr_utility.trace('5055  Resident County Eff Start Date '||
                     to_char(l_res_adr_date_start,'DD-MON-YYYY'));
          hr_utility.trace('5060  As of 1st Jan Date '||
            to_char(TRUNC(TO_DATE(l_date_earned, 'DD-MM-YYYY'),'Y'),'DD-MON-YYYY'));
          hr_utility.trace('5070  County Code Returned '||l_rs_county_code);
      ELSE
          hr_utility.trace('5075  Resident County Eff Start Date '||
                     to_char(l_res_adr_date_start,'DD-MON-YYYY'));
          hr_utility.trace('5076  As of 1st Jan Date '||
            to_char(TRUNC(TO_DATE(l_date_earned, 'DD-MM-YYYY'),'Y'),'DD-MON-YYYY'));
          hr_utility.trace('5077  Resident County Code Eff Start Date '||
                           to_char(l_res_adr_date_start,'DD-MON-YYYY'));
          hr_utility.trace('5080  County Code Returned 00-000 ');
          l_rs_county_code := '00-000';
      END IF;
    CLOSE c_override_state_county;
    hr_utility.trace('5090 END of function GET_RESIDENCE_AS_OF_1ST_JAN ');
    RETURN (l_rs_county_code);
    EXCEPTION --the residence county is not in Indiana
    WHEN others THEN
      hr_utility.trace('5100  Exception: '||substr(sqlerrm,1,30));
      hr_utility.trace('5110 END of function GET_RESIDENCE_AS_OF_1ST_JAN ');
      CLOSE c_override_state_county;
      l_rs_county_code := '00-000';
      RETURN (l_rs_county_code);
    /*}*/
    END;
  /*}*/
  ELSE
       hr_utility.trace('5120 OVERRIDE County Code Found ');
       hr_utility.trace('5130 County Code Retunred : '||l_rs_county_code);
  END IF;
  CLOSE c_override_state_county;
  hr_utility.trace('5140 END of function GET_RESIDENCE_AS_OF_1ST_JAN ');
  RETURN(l_rs_county_code);
/*}*/
END; --function GET_RESIDENCE_AS_OF_1ST_JAN


FUNCTION GET_LOCATION_AS_OF_1ST_JAN (p_assign_id   number,
                                     p_date_earned varchar2, /*Bug#6768746: date earned is required to fetch active assignments attached to the employee*/
                                     p_effective_date varchar2,
                                     p_juri_code   varchar2)
RETURN boolean IS

l_date_earned date;
l_is_exist number(2);
/*Bug#6768746: IN County Tax not deducted from second assignments created
  after first of January. County tax should be withheld even when the current
  assignment's work location is valid for other assignments as of 1st January.
  */
l_is_valid_location boolean ;

cursor c_multiple_assignments is
select assignment_id
  from per_all_assignments_f
 where TO_DATE(p_date_earned, 'dd-mm-yyyy') between effective_start_date
                         and effective_end_date
   and person_id in (select person_id
                       from per_all_assignments_f
                      where assignment_id =p_assign_id);
/*Bug#6768746: Changes ends here*/

CURSOR c_override_location IS
SELECT 'Y'
FROM pay_us_counties puc,
  pay_us_states pus,
  hr_locations hl,
  hr_soft_coding_keyflex hscf,
  per_assignments_f paf
WHERE paf.assignment_id = p_assign_id
/* Bug#8606659 */
-- AND l_date_earned BETWEEN /*6519715*/
AND TO_DATE(p_date_earned, 'dd-mm-yyyy') BETWEEN
/* Bug#8606659: changes end here */
    paf.effective_start_date AND paf.effective_end_date
AND hscf.soft_coding_keyflex_id = paf.soft_coding_keyflex_id
AND hscf.segment18 = hl.location_id
AND NVL(hl.loc_information17, hl.region_2) = pus.state_abbrev --actual state
AND pus.state_code = '15'  --check only for Indiana
AND puc.state_code = pus.state_code
AND NVL(hl.loc_information19, hl.region_1) = puc.county_name --actual county
AND puc.state_code = SUBSTR(p_juri_code, 1, 2)
AND puc.county_code  = SUBSTR(p_juri_code, 4, 3);

l_curr_county_code    varchar2(2);

/*
 * is this the work county as of 1st Jan.
 */
BEGIN
/*{*/
  /*
   * check for override
   */
  /*Bug#6068328: Truncating date earned to 'Y' as location as of
    1st Jan has to be picked*/
   l_date_earned := TRUNC(TO_DATE(p_effective_date, 'DD-MM-YYYY'),'Y');


   hr_utility.trace('l_date_earned: ' || l_date_earned);
  OPEN c_override_location;

  FETCH c_override_location
  INTO l_curr_county_code;

  IF c_override_location%NOTFOUND THEN
  /*{*/
    BEGIN
    /*{*/
     hr_utility.trace('c_override_location%NOTFOUND ');
     l_is_valid_location := FALSE ;
     /*Bug#6768746: Check work location of this current assignment is valid
       as of 1st January. Check all the active assignments attached with this
       employee.*/
     for rec_multiassgn in c_multiple_assignments
     LOOP
       hr_utility.trace('rec_multiassgn.assignment_id: '|| to_char(rec_multiassgn.assignment_id));
       SELECT count(1)
         INTO l_is_exist
         FROM pay_us_counties puc,
              pay_us_states pus,
              hr_locations hl,
              hr_soft_coding_keyflex hscf,
              per_assignments_f paf
        WHERE paf.assignment_id = rec_multiassgn.assignment_id
           AND l_date_earned BETWEEN  /*6519715*/
          paf.effective_start_date AND paf.effective_end_date
      AND hscf.soft_coding_keyflex_id = paf.soft_coding_keyflex_id
      AND paf.location_id = hl.location_id
      AND NVL(hl.loc_information17, hl.region_2) = pus.state_abbrev
                                                                --actual state
      AND pus.state_code = '15'  --check only for Indiana
      AND puc.state_code = pus.state_code
      AND NVL(hl.loc_information19, hl.region_1) = puc.county_name
                                                                --actual county
      AND puc.state_code = SUBSTR(p_juri_code, 1, 2)
      AND puc.county_code  = SUBSTR(p_juri_code, 4, 3);

     IF l_is_exist > 0 then
        hr_utility.trace('l_is_exist >0');
        l_is_valid_location := TRUE ;
     end if;
     end loop;
     CLOSE c_override_location;
     RETURN (l_is_valid_location);

     EXCEPTION
     WHEN others THEN
      CLOSE c_override_location;
      hr_utility.trace('5100  Exception: '||substr(sqlerrm,1,30));
      RETURN (FALSE);
    /*  SELECT count(1)
      INTO l_is_exist
      FROM pay_us_counties puc,
        pay_us_states pus,
        hr_locations hl,
        hr_soft_coding_keyflex hscf,
        per_assignments_f paf
      WHERE paf.assignment_id = p_assign_id
      AND l_date_earned BETWEEN  /*6519715
          paf.effective_start_date AND paf.effective_end_date
      AND hscf.soft_coding_keyflex_id = paf.soft_coding_keyflex_id
      AND paf.location_id = hl.location_id
      AND NVL(hl.loc_information17, hl.region_2) = pus.state_abbrev
                                                                --actual state
      AND pus.state_code = '15'  --check only for Indiana
      AND puc.state_code = pus.state_code
      AND NVL(hl.loc_information19, hl.region_1) = puc.county_name
                                                                --actual county
      AND puc.state_code = SUBSTR(p_juri_code, 1, 2)
      AND puc.county_code  = SUBSTR(p_juri_code, 4, 3);

      CLOSE c_override_location;
      --RETURN (TRUE);
      hr_utility.trace('query count: ' || to_char(l_is_exist));
      IF l_is_exist = 0 then
        RETURN (FALSE);
      else
        return(TRUE);
      end if;
    EXCEPTION
    WHEN others THEN
      CLOSE c_override_location;
      RETURN (FALSE); */
    /*}*/
    END;
  /*}*/
  END IF;

  CLOSE c_override_location;
  RETURN(TRUE);
/*}*/
END GET_LOCATION_AS_OF_1ST_JAN;

FUNCTION DOES_TAX_EXISTS (p_juri_code    varchar2,
                         l_date_earned  varchar2,
                         p_tax_unit_id  number,
                         p_assign_id    number,
                         p_pact_id      number,
                         p_called_from  varchar2)
RETURN varchar2  IS

l_county_tax_exists     varchar2(10);

BEGIN
/*{*/

  SELECT COUNTYTAX.county_tax
  INTO l_county_tax_exists
  FROM pay_us_county_tax_info_f COUNTYTAX
  WHERE COUNTYTAX.JURISDICTION_CODE = SUBSTR(p_juri_code, 1, 6) || '-0000'
  AND TO_DATE(l_date_earned, 'dd-mm-yyyy') BETWEEN
      COUNTYTAX.effective_start_date AND COUNTYTAX.effective_end_date;

  /*
   * If tax exists then check does the customer have tax defined for the state
   */
  IF l_county_tax_exists = 'Y' THEN
  /*{*/
    IF p_called_from = 'COUNTY_WK' THEN
    /*{*/
      l_county_tax_exists := get_tax_exists(p_juri_code,
                                           TO_DATE(l_date_earned, 'DD-MM-YYYY'),
                                           p_tax_unit_id,
                                           p_assign_id,
                                           p_pact_id,
                                           'SIT_WK',
                                           p_called_from);
    /*}*/
    ELSE
    /*{*/
      l_county_tax_exists := get_tax_exists(p_juri_code,
                                           TO_DATE(l_date_earned, 'DD-MM-YYYY'),
                                           p_tax_unit_id,
                                           p_assign_id,
                                           p_pact_id,
                                           'SIT_RS',
                                           p_called_from);
    /*}*/
    END IF;
    hr_utility.trace('DOES_TAX_EXISTS County Tax Exists : '
                                                   || l_county_tax_exists);
    RETURN(l_county_tax_exists);
  /*}*/
  ELSE
  /*{*/
    hr_utility.trace('DOES_TAX_EXISTS County Tax Exists : '
                                                   || l_county_tax_exists);
    RETURN(l_county_tax_exists);
  /*}*/
  END IF;
EXCEPTION
WHEN others THEN
  hr_utility.trace('DOES_TAX_EXISTS EXception Raised ');
  hr_utility.trace('DOES_TAX_EXISTS County Tax Exists : N');
  RETURN('N');
/*}*/
END DOES_TAX_EXISTS;


FUNCTION STATE_LOCAL_LEVEL_TAX (p_tax_unit_id   number,
                               l_state_abbrev  varchar2,
                               p_juri_code     varchar2 )
RETURN varchar2   IS

l_rs_county_code              varchar2(10);
l_rs_county_tax_exists        varchar2(10);
l_state_level_tax_exists      varchar2(10);
l_local_level_tax_exists      varchar2(10);
-- This variable will be used to check the local Tax Rules defined
-- for the GRE or not.
l_wh_work_localities varchar2(100);
l_jd_type            varchar2(100);
BEGIN
--{
  --
  -- WORK_LOCALITIES Rules added to fix bug # 3953687
  --
  SELECT DECODE(hoi.ORG_INFORMATION19, 'ALL', 'Y',
                                       'LOCALITIES', 'N',
                                       'WORK_LOCALITIES','N',
                                       'Y')
  INTO l_state_level_tax_exists
  FROM hr_organization_information hoi
  WHERE hoi.org_information_context = 'State Tax Rules'
  AND hoi.organization_id = p_tax_unit_id
  AND hoi.org_information1 = l_state_abbrev;
  BEGIN
    --
    -- Following query added for OH/KY courtesy withholding enhancement
    -- Bug # 3953687
    l_wh_work_localities := 'Y';
    SELECT DECODE(hoi.ORG_INFORMATION19,
                  'WORK_LOCALITIES','N',
                  'Y') -- State Tax Rules level
      INTO l_wh_work_localities
      FROM hr_organization_information hoi
     WHERE hoi.org_information_context = 'State Tax Rules'
       AND hoi.organization_id = p_tax_unit_id
       AND hoi.org_information1 = l_state_abbrev;
    IF l_wh_work_localities = 'Y'
    THEN
    --
    -- Check if there's any locality defined under Local tax rule for a locality
    --
       BEGIN  -- Check if the locality is exempt
       --{
          SELECT DECODE(hoi.ORG_INFORMATION3,'Y','N','N','Y','Y')
                   --local level have to check if exempt
            INTO l_local_level_tax_exists
            FROM HR_ORGANIZATION_INFORMATION hoi
           WHERE hoi.ORG_INFORMATION_CONTEXT = 'Local Tax Rules'
             AND hoi.organization_id = p_tax_unit_id
             AND hoi.org_information1 = SUBSTR(p_juri_code,1,6)||'-0000';
          /* Bug 2934494
            AND hoi.org_information1 = SUBSTR(p_juri_code,1,6)||' - 0000';
          */
          hr_utility.set_location('pay_get_tax_exists_pkg.STATE_LOCAL_LEVEL_TAX', 52);
          hr_utility.trace('County Income Tax Exists :  '||l_local_level_tax_exists);
          RETURN(l_local_level_tax_exists);

          EXCEPTION
          WHEN OTHERS THEN
           -- If there is no value then return l_state_level_tax_exists
              hr_utility.set_location(
                            'pay_get_tax_exists_pkg.STATE_LOCAL_LEVEL_TAX', 53);
              hr_utility.trace(
                     'No rexord defined in Local Tax rules for this Locality : '
                                                   || l_local_level_tax_exists);
    /*
     * This will return Y, if ALL Localities are selected under State Tax Rules
     * and there's no record defined under local tax rules for the given
     * locality and will return N, if option "LOCALITIES defined under Local Tax
     * Rules" is selected under State Tax Rules and there's no record defined
     * under local tax rules for the given locality
     */
              RETURN (l_state_level_tax_exists);
       --}
       END; -- end check for locality exemption
    ELSE
    --{
       /*
          If Employer setup for State's Resident Tax is Only Withhold Tax
          at Work Location return No, so that Resident tax is not withhold
          for the resident jurisdiction
       */
       hr_utility.set_location('py_gt_tax_exists_pkg.STATE_LOCAL_LEVEL_TAX',54);
       hr_utility.trace('Local Income Tax Exists :  ' ||l_wh_work_localities);
       --
       -- This is added to tax a jurisdiction if it is tagged OR
       -- resident jurisdiction is same Work
       l_jd_type := hr_us_ff_udf1.get_jurisdiction_type(p_juri_code);
       hr_utility.trace('Jurisdiction Type : '||l_jd_type);
       if (nvl(l_jd_type,'NL') = 'RT' OR
           nvl(l_jd_type,'NL') = 'RW' OR
           nvl(l_jd_type,'NL') = 'HW'    -- added to fix bug # 4463475
          ) then
       --{
           hr_utility.trace('COUNTY Tax to be withheld :  Y');
           return('Y');
       --}
       else
           hr_utility.trace('County Tax to be withheld :  ' || l_wh_work_localities);
           RETURN l_wh_work_localities;
       end if;
    --}
    END IF;
  END;
  EXCEPTION /* The ct has nothing at the EI level set up */
  WHEN OTHERS THEN
    l_local_level_tax_exists := 'Y';
    hr_utility.set_location('py_gt_tax_exists_pkg.STATE_LOCAL_LEVEL_TAX', 55);
    hr_utility.trace('Local Income Tax Exists : ' || l_local_level_tax_exists);
    RETURN l_local_level_tax_exists;
--}
END STATE_LOCAL_LEVEL_TAX;

/* This version matches with the forms call */
FUNCTION  get_tax_exists (p_juri_code   IN VARCHAR2,
                          p_date_earned IN DATE,
                          p_tax_unit_id IN NUMBER,
                          p_assign_id   IN NUMBER,
                          p_type        IN VARCHAR2
                          )  RETURN VARCHAR2 IS
-- This function when called from get_wage_accum_rule ,p_date_earned will be given Date Paid for bug 7441418
BEGIN

  RETURN get_tax_exists(p_juri_code,
                        p_date_earned,
                        p_tax_unit_id,
                        p_assign_id,
                        NULL,
                        p_type);

END get_tax_exists;

/* This version matches with the formula function call */
FUNCTION get_tax_exists (p_juri_code  IN varchar2,
                        p_date_earned IN date,
                        p_tax_unit_id IN NUMBER,
                        p_assign_id IN NUMBER,
                        p_pact_id   IN NUMBER,
                        p_type IN varchar2)
RETURN VARCHAR2 IS

BEGIN
/*{*/
--  hr_utility.trace_on(null,'EXIST');
  RETURN get_tax_exists(p_juri_code,
                       p_date_earned,
                       p_tax_unit_id,
                       p_assign_id,
                       p_pact_id,
                       p_type,
                       'F');
  /*
   * This additional parameter(for p_call) defaults to 'F' which stands for
   * formula, meaning this function was called from the vertex formula.
   * When this function is called from any other place, CITY_WK
   * or COUNTY_WK, then it will bypass the 'NR' check.
   */
/*}*/
END get_tax_exists;


FUNCTION get_tax_exists (p_juri_code  IN varchar2,
                        p_date_earned IN date,
                        p_tax_unit_id IN NUMBER,
                        p_assign_id IN NUMBER,
                        p_pact_id   IN NUMBER,
                        p_type IN varchar2,
                        p_call IN varchar2)
RETURN VARCHAR2 IS

l_sit_wk_exists           varchar2(2);
l_sit_rs_exists           varchar2(2);
l_sdi_ee_exists           varchar2(2);
l_sdi_er_exists           varchar2(2);
l_county_wk_exists        varchar2(2);
l_county_rs_exists        varchar2(2);
l_city_wk_exists          varchar2(2);
l_ht_wk_exists            varchar2(2);
l_city_rs_exists          varchar2(2);
l_school_exists           varchar2(2);
l_sui_exists              varchar2(2);
l_state_abbrev            varchar2(2);
l_exists                  varchar2(2);
l_step                    varchar2(10);
l_nr_exists               varchar2(2);
l_date_earned             varchar2(20);
l_date                    varchar2(20);
l_payroll_installed       boolean := FALSE;
l_org_info2               varchar2(2);
l_org_info19              varchar2(2);
l_rs_county_as_of_1st_jan varchar2(15);
l_county_tax_exists       varchar2(10);
l_does_tax_exists         varchar2(10);
l_state_local_level_tax   varchar2(10);
l_misc1_state_tax         varchar2(2);
l_eic_rs_exists           varchar2(2);
l_eic_wk_exists           varchar2(2);
l_wc_exists               varchar2(2);
-- This variable will be used to check the local Tax Rules defined
-- for the GRE or not. p_type = CITY_RS
l_wh_work_localities      varchar2(100);
l_jd_type                 varchar2(100);
l_local_tax_rules_type    varchar2(100);
l_indiana_override        varchar2(10);
l_across_years            varchar2(2);

cursor override_state is
select nvl(ADDR.add_information17,'ZZ')
from
 per_addresses            ADDR,
 per_all_assignments_f    ASSIGN
where TO_DATE(l_date_earned, 'dd-mm-yyyy')
              between ASSIGN.effective_start_date
                  and ASSIGN.effective_end_date
and   ASSIGN.assignment_id  = p_assign_id
and   ADDR.person_id      = ASSIGN.person_id
and   ADDR.primary_flag   = 'Y'
and   TO_DATE(l_date_earned, 'dd-mm-yyyy')
              between nvl(ADDR.date_from, TO_DATE(l_date_earned, 'dd-mm-yyyy'))
                  and nvl(ADDR.date_to, TO_DATE(l_date_earned, 'dd-mm-yyyy'));


BEGIN
/*{*/
  /*
   * Check to see if US Payroll is installed
   */

  l_payroll_installed := hr_utility.chk_product_install(
                                              p_product =>'Oracle Payroll',
                                              p_legislation => 'US');
  IF l_payroll_installed THEN
  /*{*/

--    hr_utility.trace_on(null,'TAXEXIST');
    hr_utility.set_location('Entering pay_get_tax_exists_pkg.get_tax_exists',1);
    hr_utility.trace('We are changing the date format, the before date is: '
                                                               ||p_date_earned);
    l_date_earned := TO_CHAR(p_date_earned,'dd-mm-yyyy');

    hr_utility.trace('The tax we are determining is  : '|| p_type);
    hr_utility.trace('The jurisdiction is   : ' || p_juri_code);
    hr_utility.trace('The date earned after change of format is    : '
                                                              || l_date_earned);
    hr_utility.trace('The tax unit id is    : ' || p_tax_unit_id);
    hr_utility.trace('The assignment id is  : ' || p_assign_id);

    /*
     * Let's take the jurisdiction code and get a state abbrev
     */

    SELECT DISTINCT pus.state_abbrev
    INTO l_state_abbrev
    FROM pay_us_states pus
    WHERE pus.state_code = SUBSTR(p_juri_code, 1, 2);

    hr_utility.trace('The state abbrev is:' || l_state_abbrev);


    /*
     * Let's only allow the function to work if date_earned is in 1999
     *
     * We will remove this code later on in the year of 1999
     * We only have this so customer do not have to apply this between last
     * 1998 run and first 1999 run
     */

    IF SUBSTR(l_date_earned, 7) < 1999 THEN
    /*{*/
       BEGIN
       /*{*/
         hr_utility.trace('The year of the date earned is: '
                                                  || SUBSTR(l_date_earned, 7));
         l_exists := 'Y';
         hr_utility.trace('The year is before 1999 so we will say tax exists '
                                                                       ||' =Y');
         RETURN l_exists;
       /*}*/
       END;
    /*}*/
    ELSE
    /*{*/
      hr_utility.trace('The year of the date earned is after 1998 so we will '
                                              || ' allow the function to calc');
      NULL;
    /*}*/
    END IF;

    /*
     * Let's start with the res state
     */

    IF p_type = 'SIT_RS' THEN  /* 1 */
    /*{*/
      BEGIN
      /*{*/
        SELECT DISTINCT sit_exists
        INTO l_sit_rs_exists
        FROM pay_us_state_tax_info_f
        WHERE state_code = SUBSTR(p_juri_code, 1, 2)
        AND TO_DATE(l_date_earned, 'dd-mm-yyyy') BETWEEN
            effective_start_date AND effective_end_date;

        /*
         * If l_sit_rs_exists = Y then the jit table says there is SIT,
         * if it equals N then the jit table says there is no SIT.
         * So l_sit_exist would return N regardless of what the ct marks
         * if the jit table does not have SIT.
         * If l_sit_rs_exists = Y then we have to see what the ct has set up.
         * If they put All States at the employer identification level then we
         * will have to check and see if the state is exempt. Because a customer
         * can take out from all states but then later on go and mark a single
         * state exempt.  If they put Only States Defined Under State Tax
         * Rules then we have to see if they have that state set up.
         * If they do have the state there then we have to check the exempt flag
         * If the e xempt flag is set to Y,exempt the state, but we have to
         * decode the Y to a N to pass to l_sit_rs_exists because to exempt,
         * l_sit_rs_exists has to be N, hence we have to decode the Y and N
         * when checking for exempt status.
         * If there is no row for the state then they do not have a place of
         * business. So the select into will fail going to the exception handler
         * which will return a l_sit_rs_exists = N for there is not state
         * income tax.
         */

        IF l_sit_rs_exists = 'Y' THEN  /* 2 */
        /*{*/
          SELECT DECODE(hoi.ORG_INFORMATION2, 'ALL', 'Y', 'STATES', 'N', 'Y')
                                                                 /* EI level */
          INTO l_org_info2
          FROM HR_ORGANIZATION_INFORMATION hoi
          WHERE hoi.ORG_INFORMATION_CONTEXT = 'Employer Identification'
          AND hoi.organization_id = p_tax_unit_id;

          BEGIN
          /*{*/
            SELECT DECODE(hoi.ORG_INFORMATION18, 'Y', 'N', 'N', 'Y', 'Y')
                                       /* state level have to check if exempt */
            INTO l_sit_rs_exists
            FROM HR_ORGANIZATION_INFORMATION hoi
            WHERE hoi.ORG_INFORMATION_CONTEXT = 'State Tax Rules'
            AND hoi.organization_id = p_tax_unit_id
            AND hoi.org_information1 = l_state_abbrev;

            hr_utility.set_location('pay_get_tax_exists_pkg.get_tax_exists',11);
            hr_utility.trace('SIT Exists  : ' || l_sit_rs_exists);

            IF l_sit_rs_exists = 'N' THEN

              IF hr_us_ff_udf1.get_work_state(substr(p_juri_code, 1, 2)) = 'Y' THEN
                  RETURN 'Y';
              END IF;

            END IF;

            RETURN l_sit_rs_exists;

          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            /*
             * If there is no value then return the value of l_org_info2
             */
            hr_utility.set_location('pay_get_tax_exists_pkg.get_tax_exists',12);
            hr_utility.trace('SIT Exists  : ' || l_org_info2);

            IF l_org_info2 = 'N' THEN

              IF hr_us_ff_udf1.get_work_state(substr(p_juri_code, 1, 2)) = 'Y' THEN
                  RETURN 'Y';
              END IF;

            END IF;

            RETURN l_org_info2;
          /*}*/
          END;
        /*}*/
        ELSE  /* 2 */
        /*{*/
          hr_utility.set_location('pay_get_tax_exists_pkg.get_tax_exists', 15);
          hr_utility.trace('SIT Exists  : ' || l_sit_rs_exists);

          RETURN l_sit_rs_exists;
          /*
           * jit level, this will be N, no sit for the state
           */

        /*}*/
        END IF; /* 2 */
      EXCEPTION
      WHEN others THEN

        l_sit_rs_exists := 'Y';
        hr_utility.set_location('pay_get_tax_exists_pkg.get_tax_exists', 16);
        hr_utility.trace('SIT Exists  : ' || l_sit_rs_exists);

        RETURN l_sit_rs_exists;

      /*}*/
      END;  /* SIT_RS */
    /*}*/
    ELSIF p_type = 'SIT_WK' THEN /* 1 */
    /*{*/
      BEGIN
      /*{*/
        SELECT DISTINCT sit_exists
        INTO l_sit_wk_exists
        FROM pay_us_state_tax_info_f
        WHERE state_code = SUBSTR(p_juri_code, 1, 2)
        AND TO_DATE(l_date_earned, 'dd-mm-yyyy') BETWEEN
            effective_start_date AND effective_end_date;

        IF l_sit_wk_exists = 'Y' THEN  /* 2 */
        /*{*/
          hr_utility.set_location('pay_get_tax_exists_pkg.get_tax_exists', 20);
          hr_utility.trace('SIT_WK Exists at the jit level, '
                              ||' now we check if the NR certificate is filed');
          IF p_call = 'F' THEN
          /*{*/
            l_sit_wk_exists := get_tax_exists(p_juri_code,
                                             p_date_earned,
                                             p_tax_unit_id,
                                             p_assign_id,
                                             p_pact_id,
                                             'NR');

            hr_utility.set_location('pay_get_tax_exists_pkg.get_tax_exists',21);
            hr_utility.trace('Do we take out sit based on the NR check?  '
                                                            || l_sit_wk_exists);
          /*}*/
          END IF;
          /*
           * if yes then NR is not checked, if no then NR is checked
           */
          RETURN l_sit_wk_exists;
        /*}*/
        ELSE /* 2 */
        /*{*/
           /*
            * jit level, this will be N, no sit for the state
            */
           hr_utility.set_location('pay_get_tax_exists_pkg.get_tax_exists' ,22);
           hr_utility.trace('SIT_WK Exists  : ' || l_sit_wk_exists);
           RETURN l_sit_wk_exists;

        /*}*/
        END IF; /* 2 */

      EXCEPTION
      WHEN others THEN
        l_sit_wk_exists := 'Y';
        hr_utility.set_location('pay_get_tax_exists_pkg.get_tax_exists', 23);
        hr_utility.trace('SIT_WK Exists  : ' || l_sit_wk_exists);
        RETURN l_sit_wk_exists;
      /*}*/
      END;  /* SIT_WK */
    /*}*/

    ELSIF p_type = 'WC' THEN /* 1 */
    /*{*/
      BEGIN
      /*{*/

        l_wc_exists := 'N';

        select 'Y'
        into l_wc_exists
        from hr_organization_information hoi,
             pay_us_states pus
        where organization_id = p_tax_unit_id
        and   hoi.org_information_context = 'State Tax Rules'
        and   hoi.org_information1 = pus.state_abbrev
        and   pus.state_code = substr(p_juri_code,1,2)
        and   hoi.org_information8 is not null;


        IF l_wc_exists = 'Y' THEN  /* 2 */
        /*{*/
          hr_utility.set_location('pay_get_tax_exists_pkg.get_tax_exists WC', 20);
          hr_utility.trace('WC Carrier Exists at the State Tax Levels level, '
                              ||' now check if this assignment is WC exempt');
          IF p_call = 'F' THEN
          /*{*/

            SELECT DISTINCT decode( nvl(str.wc_exempt,'N'),
                                    'Y','N',  -- if wc exemptthe don't take WC
                                    'Y')
            INTO l_wc_exists
            FROM pay_us_emp_state_tax_rules_f str
            WHERE str.state_code = SUBSTR(p_juri_code, 1, 2)
	    AND   str.assignment_id = p_assign_id /* 5772548 */
            AND TO_DATE(l_date_earned, 'dd-mm-yyyy') BETWEEN
                str.effective_start_date AND str.effective_end_date;

            hr_utility.set_location('pay_get_tax_exists_pkg.get_tax_exists WC',21);
            hr_utility.trace(' check for wc exemption ' || l_wc_exists);
          /*}*/
          END IF;
          /*
           * if yes then NR is not checked, if no then NR is checked
           */
          RETURN l_wc_exists;

        END IF; /* 2 */

      EXCEPTION
      WHEN others THEN
        l_wc_exists := 'Y';
        hr_utility.set_location('pay_get_tax_exists_pkg.get_tax_exists wc', 23);
        hr_utility.trace('WC Exists  : ' || l_wc_exists);
        RETURN l_wc_exists;
      /*}*/
      END;  /* WC */
    /*}*/

    ELSIF p_type = 'MISC1_TAX' THEN /* 1 */
    /*{*/
      BEGIN
      /*{*/
        SELECT STA_INFORMATION16
        INTO l_misc1_state_tax
        FROM pay_us_state_tax_info_f
        WHERE state_code = SUBSTR(p_juri_code, 1, 2)
        AND TO_DATE(l_date_earned, 'dd-mm-yyyy') BETWEEN
            effective_start_date AND effective_end_date;

        IF l_misc1_state_tax = 'Y' THEN  /* 2 */
        /*{*/
          hr_utility.set_location('pay_get_tax_exists_pkg.get_tax_exists', 25);
          hr_utility.trace('MISC1_TAX Exists at the jit level, '
                              ||' now we check if the NR certificate is filed');
         /*Bug 4344763, For SHI(MA) NR Certificate should not be checked*/
	 /* IF p_call = 'F' THEN
            l_misc1_state_tax := get_tax_exists(p_juri_code,
                                             p_date_earned,
                                             p_tax_unit_id,
                                             p_assign_id,
                                             'NR');

            hr_utility.set_location('pay_get_tax_exists_pkg.get_tax_exists',26);
            hr_utility.trace('Do we take out sit based on the NR check?  '
                                                            || l_sit_wk_exists);

          END IF;*/

          /*
           * if yes then NR is not checked, if no then NR is checked
           */
          RETURN l_misc1_state_tax;
        /*}*/
        ELSE /* 2 */
        /*{*/
           /*
            * jit level, this will be N, no misc1 tax for the state
            */
           l_misc1_state_tax := 'N';
           hr_utility.set_location('pay_get_tax_exists_pkg.get_tax_exists' ,27);
           hr_utility.trace('MISC1_TAX Exists  : ' || l_misc1_state_tax);
           RETURN l_misc1_state_tax;

        /*}*/
        END IF; /* 2 */

      EXCEPTION
      WHEN others THEN
        l_misc1_state_tax := 'N';
        hr_utility.set_location('pay_get_tax_exists_pkg.get_tax_exists', 28);
        hr_utility.trace('MISC1_TAX Exists  : ' || l_misc1_state_tax);
        RETURN l_misc1_state_tax;
      /*}*/
      END;  /* MISC1_TAX */
    /*}*/
    ELSIF p_type = 'SDI_EE' THEN  /* 1 */
    /*{*/
      IF assignment_tax_exists('SDI',
                              p_assign_id,
                              p_date_earned,
                              p_juri_code) = 'Y' THEN
      /*{*/

        /*
         * the assignment is exempt from SDI tax
         */

        l_sdi_ee_exists := 'N';
        RETURN(l_sdi_ee_exists);
      /*}*/
      ELSE
      /*{*/
        BEGIN
        /*{*/
          SELECT DISTINCT DECODE(STATETAX.sdi_ee_wage_limit,
                                 NULL, 'N',
                                 0, 'N',
                                 'Y')
          INTO l_sdi_ee_exists
          FROM pay_us_state_tax_info_f STATETAX,
            fnd_sessions SES
          WHERE STATETAX.state_code = SUBSTR(p_juri_code, 1, 2)
          AND SES.session_id = USERENV('SESSIONID')
          AND SES.effective_date BETWEEN
              STATETAX.effective_start_date AND STATETAX.effective_end_date;

          hr_utility.set_location('pay_get_tax_exists_pkg.get_tax_exists', 30);
          hr_utility.trace('SDI EE Exists :  ' || l_sdi_ee_exists);

          IF l_sdi_ee_exists = 'N' THEN  /* 2 */
          /*
           * see if their is a period limit
           */
          /*{*/
            BEGIN
            /*{*/
              hr_utility.set_location('pay_get_tax_exists_pkg.get_tax_exists',
                                                                            31);
              hr_utility.trace('No SDI wage limit, check for period limit');

              SELECT DISTINCT DECODE(STATETAX.STA_INFORMATION1,
                                     NULL, 'N',
                                     0, 'N',
                                     'Y')
              INTO l_sdi_ee_exists
              FROM pay_us_state_tax_info_f STATETAX,
                fnd_sessions SES
              WHERE STATETAX.state_code = SUBSTR(p_juri_code, 1, 2)
              AND SES.session_id = USERENV('SESSIONID')
              AND SES.effective_date BETWEEN
                 STATETAX.effective_start_date AND STATETAX.effective_end_date;

              hr_utility.set_location('pay_get_tax_exists_pkg.get_tax_exists',
                                                                           32);
              hr_utility.trace('SDI EE Exists:  ' ||  l_sdi_ee_exists);
              RETURN l_sdi_ee_exists;

            EXCEPTION
            WHEN OTHERS THEN
              l_sdi_ee_exists := 'N';
              hr_utility.set_location('pay_get_tax_exists_pkg.get_tax_exists',
                                                                            33);
              hr_utility.trace('SDI EE Exists :  ' || l_sdi_ee_exists);
              RETURN l_sdi_ee_exists;

            /*}*/
            END;
          /*}*/
          ELSE   /* 2 */
          /*{*/
            hr_utility.set_location('pay_get_tax_exists_pkg.get_tax_exists',
                                                                           34);
            hr_utility.trace('SDI EE Exists :  ' || l_sdi_ee_exists);
            RETURN l_sdi_ee_exists;
          /*}*/
          END IF;  /* 2 */

        EXCEPTION
        WHEN OTHERS THEN
          l_sdi_ee_exists := 'Y';
          hr_utility.set_location('pay_get_tax_exists_pkg.get_tax_exists',
                                                                          35);
          hr_utility.trace('SDI EE Exists :  ' || l_sdi_ee_exists);
          RETURN l_sdi_ee_exists;
        /*}*/
        END; /* p_type = SDI_EE */
      /*}*/
      END IF; /* assignment_tax_exists */
    /*}*/
    ELSIF p_type = 'SDI_ER' THEN  /* 1 */
    /*{*/
      IF assignment_tax_exists('SDI',
                               p_assign_id,
                               p_date_earned,
                               p_juri_code) = 'Y' THEN
      /*{*/
        /*
         * the assignment is exempt from SDI tax
         */
        l_sdi_er_exists := 'N';
        RETURN(l_sdi_er_exists);
      /*}*/
      ELSE /* assignment_tax_exists */
      /*{*/
        SELECT DECODE(STATETAX.sdi_er_wage_limit, NULL, 'N', 0, 'N', 'Y')
        INTO l_sdi_er_exists
        FROM pay_us_state_tax_info_f STATETAX,
          fnd_sessions SES
        WHERE STATETAX.state_code = SUBSTR(p_juri_code, 1, 2)
        AND SES.session_id = USERENV('SESSIONID')
        AND SES.effective_date BETWEEN
            STATETAX.effective_start_date AND STATETAX.effective_end_date;

        hr_utility.set_location('pay_get_tax_exists_pkg.get_tax_exists', 40);
        hr_utility.trace('SDI ER Exists :  ' || l_sdi_er_exists);

        RETURN l_sdi_er_exists;

      /*}*/
      END IF; /* assignment_tax_exists */
    /*}*/
    ELSIF p_type = 'EIC_RS' THEN /* 1 */
    /*{*/
      BEGIN
      /*{*/
        SELECT DISTINCT nvl(sta_information17,'N')
        INTO l_eic_rs_exists
        FROM pay_us_state_tax_info_f
        WHERE state_code = SUBSTR(p_juri_code, 1, 2)
        AND TO_DATE(l_date_earned, 'dd-mm-yyyy') BETWEEN
            effective_start_date AND effective_end_date;

        hr_utility.set_location('pay_get_tax_exists_pkg.get_tax_exists', 23);
        hr_utility.trace('STEIC Exists  : ' || l_eic_rs_exists);

        RETURN l_eic_rs_exists;

      EXCEPTION
      WHEN others THEN
        l_eic_rs_exists := 'N';
        hr_utility.set_location('pay_get_tax_exists_pkg.get_tax_exists', 23);
        hr_utility.trace('STEIC Exists  : ' || l_eic_rs_exists);

        RETURN l_eic_rs_exists;

      /*}*/
      END;  /* EIC_RS */
    /*}*/
    ELSIF p_type = 'EIC_WK' THEN /* 1 */
    /*{*/
      BEGIN
      /*{*/
        SELECT DISTINCT nvl(sta_information17,'N')
        INTO l_eic_wk_exists
        FROM pay_us_state_tax_info_f
        WHERE state_code = SUBSTR(p_juri_code, 1, 2)
        AND TO_DATE(l_date_earned, 'dd-mm-yyyy') BETWEEN
            effective_start_date AND effective_end_date;

        hr_utility.set_location('pay_get_tax_exists_pkg.get_tax_exists', 23);
        hr_utility.trace('STEIC Exists  : ' || l_eic_wk_exists);

        RETURN l_eic_wk_exists;

      EXCEPTION
      WHEN others THEN
        l_eic_wk_exists := 'N';
        hr_utility.set_location('pay_get_tax_exists_pkg.get_tax_exists', 23);
        hr_utility.trace('STEIC Exists  : ' || l_eic_wk_exists);

        RETURN l_eic_wk_exists;

      /*}*/
      END;  /* EIC_WK */
    /*}*/
    ELSIF p_type = 'COUNTY_RS' THEN  /* 1 */

      BEGIN

        hr_utility.trace('BEGIN TAX TYPE COUNTY_RS');

        IF SUBSTR(p_juri_code, 1, 2) = '15' THEN  /* check for Indiana state */

           if p_pact_id is not null then

              open override_state;
              fetch override_state into l_indiana_override;

              hr_utility.trace('l_indiana_override '||l_indiana_override);
              if override_state%found then

                l_across_years := hr_us_ff_udf1.across_calendar_years(p_pact_id);

                hr_utility.trace('l_across_years '||l_across_years);
                if (l_indiana_override = 'IN' and
                    l_across_years     = 'Y') then

                  select to_char(effective_date,'dd-mm-yyyy')
                  into l_date
                  from pay_payroll_actions
                  where payroll_action_id = p_pact_id;

                  hr_utility.trace('l_date '||to_char(l_date));
                else
                  l_date := l_date_earned;
                end if;

              else
                l_date := l_date_earned;
              end if;

              close override_state;

           else
              l_date := l_date_earned;
           end if;

          hr_utility.trace('Resident State is Indiana Jurisdiction '||p_juri_code);

          l_rs_county_as_of_1st_jan := get_residence_as_of_1st_jan(p_assign_id,
                                                                   l_date);

          hr_utility.trace('Resident JD Code as of 1st Jan '||
                            l_rs_county_as_of_1st_jan);
          IF l_rs_county_as_of_1st_jan = SUBSTR(p_juri_code, 1, 6)  THEN
                                                                  /* 1st Jan */
            hr_utility.trace('Resident JD Code as of 1st Jan = Primary JD code as of date');
            l_county_tax_exists := does_tax_exists(p_juri_code,
                                                   l_date,
                                                   p_tax_unit_id,
                                                   p_assign_id,
                                                   p_pact_id,
                                                   'COUNTY_RS');
            hr_utility.trace('County Tax exist for JD code '||l_county_tax_exists);
            IF l_county_tax_exists = 'Y' THEN  /* tax exists */
            /*{*/
              l_state_local_level_tax := state_local_level_tax(p_tax_unit_id,
                                                               l_state_abbrev,
                                                               p_juri_code);
              RETURN(l_state_local_level_tax);
            /*}*/
            ELSE  /* tax does not exists */
            /*{*/
              RETURN(l_county_tax_exists);
            /*}*/
            END IF; /* tax exists */
          /*}*/
          ELSE  /* 1st Jan */
          /*{*/
            hr_utility.trace('Resident JD Code as of 1st Jan <> Primary JD code as of date');
            hr_utility.trace('COUNTY_RS Tax Withheld = NO ');
            RETURN('N'); /* the county is not as of 1st Jan */
          /*}*/
          END IF; /* 1st Jan */
        /*}  END Indiana State Check */
        ELSE   /* check for Other State  */
        /*{*/
          l_county_tax_exists := does_tax_exists(p_juri_code,
                                                 l_date_earned,
                                                 p_tax_unit_id,
                                                 p_assign_id,
                                                 p_pact_id,
                                                 'COUNTY_RS');

          IF l_county_tax_exists = 'Y' THEN  /* tax exists */
          /*{*/
            l_state_local_level_tax := state_local_level_tax(p_tax_unit_id,
                                                             l_state_abbrev,
                                                             p_juri_code);
            hr_utility.trace('COUNTY_RS Tax Withheld = '||l_state_local_level_tax);
            RETURN(l_state_local_level_tax);

          ELSE /* tax does not exists */

            hr_utility.trace('COUNTY_RS Tax Withheld = NO ');
            RETURN('N');

          END IF; /* tax exists */

        END IF;  /* check for Indiana state */

      END;  /* COUNTY_RS */

      /*
       * For Indiana County there are special conditions that we need to check
       * For Indiana to check for tax exists or no we always have to check as of
       * 1st Jan. If a  work county has tax as of 1st Jan then we need to check
       * if the residence county is in Indiana as of 1st Jan if yes then check
       * if a tax exists for that county if yes then we have to return false to
       * the work county that is we will not withhold at work county but at
       * residence county.
       */
    /*}*/
    /*
     * there are multiple IF THEN ELSE statements so before making any changes
     * please sure that all the conditions are satisfied.
     */
    ELSIF p_type = 'COUNTY_WK' THEN  /* 1 */
    /*{*/
      hr_utility.trace('5300 BEGIN TAX TYPE COUNTY_WK');
      BEGIN
      /*{*/
        hr_utility.trace('5310 COUNTY_WK P_JURI_CODE ' || p_juri_code);
        IF SUBSTR(p_juri_code, 1, 2) = '15'  THEN /* check for Indiana state */
        /*{     Changed for Bug 1366176 */
          /*
           * get RS county and check taxes exists there or no
           */
          hr_utility.trace('5320 COUNTY_WK COUNTY IS in State of Indiana ');
          l_rs_county_as_of_1st_jan := get_residence_as_of_1st_jan(p_assign_id,
                                                                   l_date_earned);
          hr_utility.trace('5330 COUNTY_WK Residence as of 1st Jan '|| l_rs_county_as_of_1st_jan);
          /*
           * we need to check if residence state - county is same as
           * work state - county. If yes then we calculate taxes at work else we
           * need to check the following.
           */
          IF SUBSTR(p_juri_code, 1, 6) = l_rs_county_as_of_1st_jan THEN
          /*{*/
            hr_utility.trace('5340 Work County_Code = Resident County_Code as of 1st Jan');
            IF l_rs_county_as_of_1st_jan <> '00-000' THEN
            /*{*/
              hr_utility.trace('5350 COUNTY_WK RS County_Code as of 1st Jan '||l_rs_county_as_of_1st_jan);
              l_does_tax_exists := does_tax_exists(l_rs_county_as_of_1st_jan,
                                                   l_date_earned,
                                                   p_tax_unit_id,
                                                   p_assign_id,
                                                   p_pact_id,
                                                   'COUNTY_RS');
              hr_utility.trace('5360 COUNTY_WK Does tax exist for COUNTY RS '
                                                          || l_does_tax_exists);
              /*
               * If residence county has tax, which is same as work county in
               * this case. So we will withhold taxes at work county itself
               * Old Comment
               * if the residence county has tax then return flase to work
               * county because we will withhold tax at residence and not at
               * work. else if residence county does not have tax then return
               * true which means that we have to withhold tax at work.
               */
              /*  /if l_does_tax_exists
                               = 'N' then
                           return('Y');
                           else
                           return('N');
                           end if;
               */
              RETURN(l_does_tax_exists);
            /*}*/
            ELSE
            /*
             * l_rs_county_as_of_1st_jan <> '00-000'
             * that is it is not an Indiana county as of 1st Jan
             * so we have to withhold work county taxes.
             */
            /*{*/
              hr_utility.trace('5370 COUNTY_WK COUNTY CODE as of 1st-Jan 00-000');
              hr_utility.trace('5380 COUNTY_WK Does tax exist for COUNTY RS '
                                                          || l_does_tax_exists);

              RETURN('Y') ;
            /*}*/
            END IF;   /* l_rs_county_as_of_1st_jan  < > '00-000' */
          /*}*/
          ELSE /*  if substr(p_juri_code,1,6) <> l_rs_county_as_of_1st_jan */
          /*{*/
            hr_utility.trace('5390 Work County_Code <> Resident County_Code as of 1st Jan');
	    /*Bug#6742101: If payroll period ends in one calendar year and
              the check date is in the next following year then date paid should be
	      used. */
             if p_pact_id is not null then

                l_across_years := hr_us_ff_udf1.across_calendar_years(p_pact_id);

                hr_utility.trace('l_across_years '||l_across_years);
                if (l_across_years     = 'Y') then

                  select to_char(effective_date,'dd-mm-yyyy')
                  into l_date
                  from pay_payroll_actions
                  where payroll_action_id = p_pact_id;

                  hr_utility.trace('l_date '||to_char(l_date));
                else
                  l_date := l_date_earned;
                end if;

            else
                l_date := l_date_earned;
            end if;

            IF get_location_as_of_1st_jan(p_assign_id,
	                                  l_date_earned,
                                          l_date, --l_date_earned,
                                          p_juri_code) THEN
             /*Bug#6742101: Changes ends here */
               hr_utility.trace('5390 COUNTY_WK Work Location as of 1st Jan '|| p_juri_code);
            /*{*/
              /*
               * Indiana county as of 1st Jan
               */
              l_does_tax_exists := does_tax_exists(p_juri_code,
                                                   l_date_earned,
                                                   p_tax_unit_id,
                                                   p_assign_id,
                                                   p_pact_id,
                                                   'COUNTY_WK' );

              hr_utility.trace('5400 COUNTY_WK <Does_Tax_Exist for COUNTY_WK> returned '
                               || l_does_tax_exists);
              IF l_does_tax_exists = 'Y' THEN
              /*{*/
                /* get RS county and check taxes exists there or no
                 * commented as already go it
                 * l_rs_county_as_of_1st_jan :=
                 * get_residence_as_of_1st_jan(p_assign_id,l_date_earned);
                 * we need to check if residence state-county is same as
                 * work state-county. If yes then we calculate taxes
                 *  at work else we need to check the following.
                 */
                /* commented for bug 1366176
                   if substr(p_juri_code,1,6) = l_rs_county_as_of_1st_jan then
                       return('Y');
                   end if;
                 */
                IF l_rs_county_as_of_1st_jan <> '00-000' THEN
                /*{*/
                  l_does_tax_exists := does_tax_exists(l_rs_county_as_of_1st_jan,
                                                       l_date_earned,
                                                       p_tax_unit_id,
                                                       p_assign_id,
                                                       p_pact_id,
                                                       'COUNTY_RS');
                  hr_utility.trace('5410 COUNTY_WK <Does_Tax_Exist for COUNTY_RS> returned '
                                   || l_does_tax_exists);
                  /*
                   * if the residence county has tax then return flase to work
                   * county because we will withhold tax at residence and not at
                   * work. else if residence county does not have tax then
                   * return true which means that we have to withhold tax at
                   * work.
                   */
                  IF l_does_tax_exists = 'N' THEN
                  /*{*/
                      hr_utility.trace('5420 COUNTY_WK County Tax Exist Returned <Y> ');
                      RETURN('Y');
                  /*}*/
                  ELSE
                  /*{*/
                      hr_utility.trace('5430 COUNTY_WK County Tax Exist Returned <N> ');
                      RETURN('N');
                  /*}*/
                  END IF;
                /*}*/
                ELSE    /*  l_rs_county_as_of_1st_jan = '00-000' */
                /*{*/
                  /*
                   * that is it is not an Indiana county as of 1st Jan
                   * so we have to withhold work county taxes.
                   */
                  hr_utility.trace('5440 COUNTY_WK As CountyCode 00-000 Tax Exist returned <Y>');
                  RETURN('Y') ;
                /*}*/
                END IF;   /*  l_rs_county_as_of_1st_jan   '00-000' */
              /*}*/
              ELSE  /* l_does_tax_exists = 'Y' */
              /*{*/
                /*
                 * there are no work county taxes
                 */
                  hr_utility.trace('5450 COUNTY_WK There are No Work County Tax So Tax Exist returned '
                                   ||l_does_tax_exists );
                RETURN(l_does_tax_exists);
              /*}*/
              END IF;  /* l_does_tax_exists = 'Y' */
            /*}*/
            ELSE   /*  Indiana county as of 1st Jan */
            /*{*/
              /*
               * this is not the county as of 1st Jan so return false to
               * COUNTY_WK
               */
              hr_utility.trace('5460 COUNTY_WK As WorkCounty As of 1st Jan is Not-Taxable Tax Exist returned <N>');
              l_county_wk_exists := 'N';
              RETURN l_county_wk_exists;
            /*}*/
            END IF;  /* Indiana county as of 1st Jan */
          /*}*/
          END IF; /* substr(p_juri_code,1,6) = l_rs_county_as_of_1st_jan */
        /*}*/
        ELSE /*  check for state Other than Indiana */
        /*{*/
          hr_utility.trace('5470 COUNTY_WK County is not in Indiana ');
          l_county_wk_exists := does_tax_exists(p_juri_code,
                                                l_date_earned,
                                                p_tax_unit_id,
                                                p_assign_id,
                                                p_pact_id,
                                                'COUNTY_WK');
           hr_utility.trace('5480 COUNTY_WK <Does_Tax_Exist for COUNTY_WK> returned '
                            ||l_county_wk_exists);
           RETURN (l_county_wk_exists);
        /*}*/
        END IF;  /* check for Indiana state */
      EXCEPTION
      WHEN OTHERS THEN
        l_county_wk_exists := 'N';
        hr_utility.set_location('pay_get_tax_exists_pkg.get_tax_exists', 65);
        hr_utility.trace('5500 COUNTY_WK County Income Tax Exists :  ' || l_county_wk_exists);
        RETURN l_county_wk_exists;
      /*}*/
      END;  /* COUNTY_WK */
    /*}*/

    ELSIF p_type = 'CITY_RS' THEN  /* 1 */
    --{
      BEGIN
      --{
      --  Fetch record from JIT table to determine whether City is taxable or
      --        or Not
      --
        SELECT CITYTAX.city_tax
        INTO l_city_rs_exists
        FROM pay_us_city_tax_info_f CITYTAX,
          fnd_sessions SES
        WHERE CITYTAX.JURISDICTION_CODE = p_juri_code
        AND SES.session_id = USERENV('SESSIONID')
        AND SES.effective_date BETWEEN
            CITYTAX.effective_start_date AND CITYTAX.effective_end_date;

        /*
          city taxes:  If there is no city tax in the jit table then we return
          l_city_rs_exists = N hence we skip the city tax calculation.  If the
          jit table says yes then we have to check against what the user has
          set up.
        */

        IF l_city_rs_exists = 'Y' THEN /* 2        jit level */
        --{
          BEGIN /* see if the state has taxes in the ct setup */
          --{
            hr_utility.set_location('pay_get_tax_exists_pkg.get_tax_exists',
                                                                           70);
            hr_utility.trace('determining if the state is set up by the ct');
            l_city_rs_exists := get_tax_exists(p_juri_code,
                                               p_date_earned,
                                               p_tax_unit_id,
                                               p_assign_id,
                                               p_pact_id,
                                               'SIT_RS');
            hr_utility.set_location('pay_get_tax_exists_pkg.get_tax_exists',
                                                                           71);
            hr_utility.trace('Is the state withholding taxes ? '
                                                          ||l_city_rs_exists);
            IF l_city_rs_exists = 'Y' THEN /* 3 */
            --
            -- The state is taking taxes
            --
            --{
              BEGIN
              --{
                SELECT DECODE(hoi.ORG_INFORMATION19,
                              'ALL','Y',
                              'LOCALITIES','N',
                              'WORK_LOCALITIES','N',
                              'Y') /* State Tax Rules level */
                             , hoi.ORG_INFORMATION19
--              new column added in the fetch for fixing bug 4711572
--              INTO l_org_info19
		INTO l_org_info19,
                     l_local_tax_rules_type
                FROM hr_organization_information hoi
                WHERE hoi.org_information_context = 'State Tax Rules'
                AND hoi.organization_id = p_tax_unit_id
                AND hoi.org_information1 = l_state_abbrev;
               BEGIN
             --
             -- Following query added for OH courtesy withholding enhancement
             --
                l_wh_work_localities := 'Y';
                SELECT DECODE(hoi.ORG_INFORMATION19,
                              'WORK_LOCALITIES','N',
                              'Y') /* State Tax Rules level */
                INTO l_wh_work_localities
                FROM hr_organization_information hoi
                WHERE hoi.org_information_context = 'State Tax Rules'
                AND hoi.organization_id = p_tax_unit_id
                AND hoi.org_information1 = l_state_abbrev;

                IF l_wh_work_localities = 'Y' /* 3.1 */
                THEN
                   BEGIN                  /* Check if the locality is exempt */
                   --{
                    SELECT DECODE(hoi.ORG_INFORMATION3,'Y','N','N','Y','Y')
                     /* local level have to check if exempt */
                      INTO l_city_rs_exists
                      FROM HR_ORGANIZATION_INFORMATION hoi
                     WHERE hoi.ORG_INFORMATION_CONTEXT = 'Local Tax Rules'
                       AND hoi.organization_id         = p_tax_unit_id
                       AND hoi.org_information1        = p_juri_code;
                    hr_utility.set_location('py_gt_tx_exists_pkg.get_tax_exists'
                                                                          , 72);
                    hr_utility.trace('City Income Tax Exists : ' ||
                                                             l_city_rs_exists);
                    RETURN l_city_rs_exists;
                    EXCEPTION
                    WHEN OTHERS THEN
                    /*
                     *  If there is no value then return l_city_rs_exists = 'Y'
                    */
                    hr_utility.set_location('py_gt_tx_exists_pkg.get_tax_exists'
                                                                          , 73);
                    -- added for Bug # 4711572
                    if l_local_tax_rules_type = 'LOCALITIES'
                    then
                      l_jd_type := hr_us_ff_udf1.get_jurisdiction_type(p_juri_code);
                      hr_utility.trace('CITY_RS Jurisdiction Type : '||l_jd_type);
                     -- if (nvl(l_jd_type,'NL') = 'RW')
                     /*Modified for bug 7353397 to include Work at home scenario
                     for caluclating taxes when 'Only Locatlites Under Local Tax Rules'
                     is selected at GRE level */
                        if (nvl(l_jd_type,'NL') = 'RW' or nvl(l_jd_type,'NL') = 'HW' )
                      then
                         hr_utility.trace('CITY_RS City Income Tax Exists set to withhold Tax:  Y');
                         return('Y');
                      else
                         hr_utility.trace('CITY_RS City Income Tax Exists :  ' ||
                                                          l_wh_work_localities);
                         RETURN l_org_info19;
                      end if;
                    else
                      hr_utility.trace('City Income Tax Exists :  ' || l_org_info19);
                      RETURN l_org_info19;
                    end if;
                   --}
		   END; /* end check for locality exemption */
                ELSE   /* 3.1 */
                   /*  If Employer setup for State's Resident Tax is Only Withhold Tax at Work Location
                          return No, so that Resident tax is not withhold for the resident jurisdiction
                   */
                      hr_utility.set_location(
                                    'py_gt_tax_exists_pkg.get_tax_exists', 75);
                      -- This is added to tax a jurisdiction if it is tagged OR
                      -- resident jurisdiction is same Work
                      l_jd_type := hr_us_ff_udf1.get_jurisdiction_type(p_juri_code);
                      hr_utility.trace('CITY_RS Jurisdiction Type : '||l_jd_type);
                      if (nvl(l_jd_type,'NL') = 'RT' OR
                          nvl(l_jd_type,'NL') = 'RW' OR
                          nvl(l_jd_type,'NL') = 'HW' )then -- added for Bug # 4463475
                         hr_utility.trace('CITY_RS City Income Tax Exists set to withhold Tax:  Y');
                         return('Y');
                      else
                         hr_utility.trace('CITY_RS City Income Tax Exists :  ' ||
                                                          l_wh_work_localities);
                         RETURN l_wh_work_localities;
                      end if;
                END IF;  /* 3.1 */
               END;
              EXCEPTION /* The ct has nothing at the EI level set up */
              WHEN OTHERS THEN
                   l_city_rs_exists := 'Y';
                   hr_utility.set_location(
                                     'py_gt_tax_exists_pkg.get_tax_exists', 76);
                   hr_utility.trace(
                              'City Income Tax Exists :  ' || l_city_rs_exists);
                   RETURN l_city_rs_exists;
               --}
              END; /* end for city_exists = Y */
            --}
            ELSE   /* 3 */
              /*
               * The state is not withholding or is not setup no city tax
               */
            --{
              hr_utility.set_location('pay_get_tax_exists_pkg.get_tax_exists',
                                                                           77);
              hr_utility.trace('City Income Tax Exists :  ' ||
                                                             l_city_rs_exists);
              RETURN l_city_rs_exists;
            --}
            END IF;  /* 3 */
          --}
          END;
        --}
        ELSE  /* 2       jit level, no city tax */
        --{
          RETURN l_city_rs_exists;
        --}
        END IF; /* 2       jit level */
      EXCEPTION /* No rows in the city jit table */
      WHEN OTHERS THEN
        l_city_rs_exists := 'N';
        hr_utility.set_location('pay_get_tax_exists_pkg.get_tax_exists', 78);
        hr_utility.trace('City Income Tax Exists :  ' || l_city_rs_exists);
        RETURN l_city_rs_exists;
      --}
      END; /* CITY_RS */
    --}

    ELSIF p_type = 'HT_WK' THEN  /* 1 */
    /*{*/
      BEGIN
      /*{*/
        SELECT CITYTAX.head_tax
        INTO l_ht_wk_exists
        FROM pay_us_city_tax_info_f CITYTAX,
          fnd_sessions SES
        WHERE CITYTAX.JURISDICTION_CODE = p_juri_code
        AND SES.session_id = USERENV('SESSIONID')
        AND SES.effective_date BETWEEN
            CITYTAX.effective_start_date AND CITYTAX.effective_end_date;

        /*
         * Head taxes:  If there is no head tax in the jit table then
         * we return l_ht_wk_exists = N hence we skip the ht tax calculation.
         * If the jit table says yes then we have to check against what
         * the user has set up.
         */
        IF l_ht_wk_exists = 'Y' THEN /* 2        jit level */
        /*{*/
          BEGIN /* see if the state has taxes in the ct setup */
          /*{*/
            hr_utility.set_location('pay_get_tax_exists_pkg.get_tax_exists',
                                                                         180);
            hr_utility.trace('determining if the state is set up by the ct');

            l_ht_wk_exists := get_tax_exists(p_juri_code,
                                             p_date_earned,
                                             p_tax_unit_id,
                                             p_assign_id,
                                             p_pact_id,
                                             'SIT_WK');

            hr_utility.set_location('pay_get_tax_exists_pkg.get_tax_exists',
                                                                          181);
            hr_utility.trace('Is the state withholding taxes ? '||
                                                               l_ht_wk_exists);

            IF l_ht_wk_exists = 'Y' THEN /* 3      The state is taking taxes */
            /*{*/
              hr_utility.set_location('pay_get_tax_exists_pkg.get_tax_exists',
                                                                          182);
              hr_utility.trace('Head Tax Exists : ' || l_ht_wk_exists);
              RETURN l_ht_wk_exists;
            /*}*/
            ELSE /* 3 */
            /*
             * The state is not withholding or is not setup no head tax
             */
            /*{*/
              hr_utility.set_location('pay_get_tax_exists_pkg.get_tax_exists',
                                                                          183);
              hr_utility.trace('Head Tax Exists :  ' || l_ht_wk_exists);

              RETURN l_ht_wk_exists;
            /*}*/
            END IF;  /* 3 */
          /*}*/
          END;
        /*}*/
        ELSE  /* 2       jit level, no head tax */
        /*{*/
          RETURN l_ht_wk_exists;
        /*}*/
        END IF; /* 2       jit level */
      EXCEPTION /* No rows in the city jit table */
      WHEN OTHERS THEN
        l_ht_wk_exists := 'N';
        hr_utility.set_location('pay_get_tax_exists_pkg.get_tax_exists', 184);
        hr_utility.trace('Head Tax Exists :  ' || l_ht_wk_exists);
        RETURN l_ht_wk_exists;
      /*}*/
      END; /* HT_WK */
    /*}*/
    ELSIF p_type = 'CITY_WK' THEN  /* 1 */
    /*{*/
      BEGIN
      /*{*/
        SELECT CITYTAX.city_tax
        INTO l_city_wk_exists
        FROM pay_us_city_tax_info_f CITYTAX,
          fnd_sessions SES
        WHERE CITYTAX.JURISDICTION_CODE = p_juri_code
        AND SES.session_id = USERENV('SESSIONID')
        AND SES.effective_date BETWEEN
            CITYTAX.effective_start_date AND CITYTAX.effective_end_date;

        /*
         * city taxes: If there is no city tax in the jit table then we return
         * l_city_wk_exists = N hence we skip the city tax calculation. If the
         * jit table says yes then we have to check against what the user has
         * set up.
         */
        IF l_city_wk_exists = 'Y' THEN /* 2        jit level */
        /*{*/
          BEGIN /* see if the state has taxes in the ct setup */
          /*{*/
            hr_utility.set_location('pay_get_tax_exists_pkg.get_tax_exists',
                                                                          80);
            hr_utility.trace('determining if the state is set up by the ct');

            l_city_wk_exists := get_tax_exists(p_juri_code,
                                               p_date_earned,
                                               p_tax_unit_id,
                                               p_assign_id,
                                               p_pact_id,
                                               'SIT_WK',
                                               'CITY_WK');

            hr_utility.set_location('pay_get_tax_exists_pkg.get_tax_exists',
                                                                        81);
            hr_utility.trace('Is the state withholding taxes ? '
                                                         ||l_city_wk_exists);

            IF l_city_wk_exists = 'Y' THEN /* 3 */
            /*
             * The state is taking taxes
             */
            /*{*/
              hr_utility.set_location('py_get_tax_exists_pkg.get_tax_exists',
                                                                         82);
              hr_utility.trace('City Income Tax Exists : ' ||
                                                           l_city_wk_exists);
              RETURN l_city_wk_exists;

            /*}*/
            ELSE /* 3 */
            /*
             * The state is not withholding or is not setup no city tax
             */
            /*{*/
               hr_utility.set_location('py_gt_tx_exists_pkg.get_tax_exists',
                                                                        83);
               hr_utility.trace('City Income Tax Exists :  '
                                                       || l_city_wk_exists);

               RETURN l_city_wk_exists;

            /*}*/
            END IF;  /* 3 */
          /*}*/
          END;
        /*}*/
        ELSE  /* 2       jit level, no city tax */
        /*{*/
           RETURN l_city_wk_exists;
        /*}*/
        END IF; /* 2       jit level */
      EXCEPTION /* No rows in the city jit table */
      WHEN OTHERS THEN
        l_city_wk_exists := 'N';
        hr_utility.set_location('py_gt_tax_exists_pkg.get_tax_exists', 84);
        hr_utility.trace('City Income Tax Exists :  ' || l_city_wk_exists);
        RETURN l_city_wk_exists;
      /*}*/
      END; /* CITY_WK */
    /*}*/
    ELSIF p_type = 'NR' THEN  /* 1 */
    /*
     * this is the check for the NR flag, this part will never be called by
     * Vertex only in the SIT call above
     */
    /*{*/
      BEGIN
      /*{*/
        SELECT puesrf.STATE_NON_RESIDENT_CERT
        INTO l_nr_exists
        FROM pay_us_emp_state_tax_rules_f puesrf,
          fnd_sessions ses
        WHERE puesrf.assignment_id = p_assign_id
        AND SUBSTR(puesrf.jurisdiction_code,1,2) = SUBSTR(p_juri_code,1,2)
        AND ses.session_id = USERENV('SESSIONID')
        AND ses.effective_date BETWEEN
             puesrf.effective_start_date AND puesrf.effective_end_date;

        IF l_nr_exists = 'Y' THEN /* 2 */
        /*
         * we do not withhold, have to switch this to N for return to SIT
         */
        /*{*/
          hr_utility.set_location('pay_get_tax_exists_pkg.get_tax_exists',
                                                                         90);
          hr_utility.trace('NR Exists before need to return opp. to SIT : '
                                                              ||l_nr_exists);
          l_sit_rs_exists := 'N';

          hr_utility.set_location('py_gt_tx_exists_pkg.get_tax_exists', 91);
          hr_utility.trace('SIT Exists after switched the return from NR : '
                                                         ||l_sit_rs_exists);

          RETURN l_sit_rs_exists;

        /*}*/
        ELSE /* 2 */
        /*
         * the nr cert is not checked, the value stored is N in the table
         */
        /*{*/
          hr_utility.set_location('py_gt_tx_exists_pkg.get_tax_exists', 92);
          hr_utility.trace('NR Exist before need to return opp. to SIT: '
                                                              ||l_nr_exists);

          l_sit_rs_exists := 'Y';

          hr_utility.set_location('py_gt_tx_exists_pkg.get_tax_exists', 93);
          hr_utility.trace('SIT Exists after we switched the ret. from NR: '
                                                          ||l_sit_rs_exists);

          RETURN l_sit_rs_exists;

        /*}*/
        END IF;  /* 2 */
      EXCEPTION
      WHEN OTHERS THEN
        l_nr_exists := 'N';
        hr_utility.set_location('py_gt_tax_exists_pkg.get_tax_exists', 94);
        hr_utility.trace('NR Exists before need to return opp. to SIT: '
                                                              ||l_nr_exists);

        l_sit_rs_exists := 'Y';

        hr_utility.set_location('py_gt_tax_exists_pkg.get_tax_exists', 95);
        hr_utility.trace('SIT Exists after we switched the ret. from NR : '
                                                          ||l_sit_rs_exists);

        RETURN l_sit_rs_exists;
      /*}*/
      END;
    /*}*/
    ELSIF p_type = 'SUI' THEN  /* 1 */
    /*{*/
      IF assignment_tax_exists('SUI',
                               p_assign_id,
                               p_date_earned,
                               p_juri_code) = 'Y' THEN
      /*{*/
        /*
         * the assignment is exempt from SUI tax
         */

        l_sui_exists := 'N';
        RETURN(l_sui_exists);
      /*}*/
      ELSE
      /*{*/
        BEGIN
        /*{*/
          SELECT 'N'
          INTO l_sui_exists
          FROM hr_organization_information hoi
          WHERE hoi.org_information_context = '1099R Magnetic Report Rules'
          AND hoi.organization_id = p_tax_unit_id
          AND hoi.org_information2 IS NOT NULL;

          IF l_sui_exists = 'N' THEN /* 2 */
          /*{*/
            hr_utility.set_location('py_gt_tax_exists_pkg.get_tax_exists',
                                                                       100);
            hr_utility.trace('SUI EE Exists :  ' || l_sui_exists);

            RETURN l_sui_exists;
          /*}*/
          ELSE  /* 2 */
          /*{*/
            l_sui_exists := 'Y';
            hr_utility.set_location('py_gt_tax_exists_pkg.get_tax_exists',
                                                                       101);
            hr_utility.trace('SUI EE Exists :  ' || l_sui_exists);

            RETURN l_sui_exists;

          /*}*/
          END IF;  /* 2 */
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_sui_exists := 'Y';
          hr_utility.set_location('py_get_tax_exists_pkg.get_tax_exists',
                                                                      102);
          hr_utility.trace('SUI EE Exists :  ' || l_sui_exists);
          RETURN l_sui_exists;
        /*}*/
        END;
      /*}*/
      END IF;
    /*}*/
    ELSE  /* 1 */
    /*{*/
      l_exists := 'Y';
      RETURN l_exists;
    /*}*/
    END IF;  /* 1 */
  /*}*/
  ELSE
  /*{*/
    l_exists := 'N';
    RETURN l_exists;
  /*}*/
  END IF; /* chk_product_install */
EXCEPTION
WHEN OTHERS THEN
  l_exists := 'Y';
  hr_utility.set_location('pay_get_tax_exists_pkg.get_tax_exists', 110);
  hr_utility.trace('The main Exception handler was called and returns '
                                               ||'tax exists: '||l_exists);
  RETURN l_exists;
  -- hr_utility.trace_off;
/*}*/
END get_tax_exists;


FUNCTION  check_tax_exists
		(
		p_date_earned IN date,
		p_tax_unit_id IN number,
		p_assign_id   IN number,
                p_pact_id     IN number,
		p_juri_code IN varchar2,
		p_type IN varchar2
		)
 		RETURN varchar2  IS

BEGIN

     RETURN get_tax_exists(p_juri_code,
                           p_date_earned,
                           p_tax_unit_id,
                           p_assign_id,
                           p_pact_id,
                           p_type,
                           'F');

END check_tax_exists;


FUNCTION get_wa_rule (p_juri_code   IN VARCHAR2,
                      p_date_earned IN DATE,
                      p_tax_unit_id IN NUMBER,
                      p_assign_id IN NUMBER,
                      p_pact_id   IN NUMBER,
                      p_type      IN VARCHAR2)
RETURN VARCHAR2 IS
-- This function when called from get_wage_accum_rule ,p_date_earned will be given Date Paid for bug 7441418
l_date_earned          varchar2(20);
l_date                 varchar2(20);
l_state_abbrev         varchar2(2);
l_state_employer_info  varchar2(2);
l_state_rule           varchar2(10);
l_state_rule_for_local varchar2(2);
l_local_rule           varchar2(10);
l_default_rule         varchar2(10);
l_jit8_rule            varchar2(10);
l_jit8_rule_nobypass   varchar2(10);
l_jd_type              varchar2(100);
l_indiana_override     varchar2(10);
l_rs_coty_1st_jan      varchar2(15);
l_across_years         varchar2(2);
l_sit_rs_exists        varchar2(2);
l_city_rs_exists       varchar2(2);
l_county_rs_exists     varchar2(2);

CURSOR override_state IS
SELECT NVL(addr.add_information17,'ZZ')
FROM per_addresses            addr,
     per_all_assignments_f    asg
WHERE TO_DATE(l_date_earned, 'dd-mm-yyyy')
              BETWEEN asg.effective_start_date
                  AND asg.effective_end_date
AND   asg.assignment_id  = p_assign_id
AND   addr.person_id     = asg.person_id
AND   addr.primary_flag  = 'Y'
AND   TO_DATE(l_date_earned, 'dd-mm-yyyy')
              BETWEEN NVL(addr.date_from, TO_DATE(l_date_earned, 'dd-mm-yyyy'))
                  AND NVL(addr.date_to, TO_DATE(l_date_earned, 'dd-mm-yyyy'));


CURSOR state_employer_info IS
SELECT DECODE(hoi.org_information2, 'ALL', 'Y', 'STATES', 'N', 'Y')
FROM hr_organization_information hoi
WHERE hoi.org_information_context = 'Employer Identification'
AND hoi.organization_id = p_tax_unit_id;

CURSOR state_rule IS
SELECT DECODE(NVL(hoi.org_information18,'00'), 'N', '00', NVL(hoi.org_information18,'00'))
FROM hr_organization_information hoi
WHERE hoi.org_information_context = 'State Tax Rules'
AND hoi.organization_id = p_tax_unit_id
AND hoi.org_information1 = l_state_abbrev;

CURSOR state_rule_for_local IS
SELECT DECODE(hoi.org_information19,
             'ALL','A',
             'LOCALITIES','L',
             'WORK_LOCALITIES','W',
             'A')
FROM hr_organization_information hoi
WHERE hoi.org_information_context = 'State Tax Rules'
AND hoi.organization_id = p_tax_unit_id
AND hoi.org_information1 = l_state_abbrev;

CURSOR local_rule IS
SELECT DECODE(NVL(hoi.org_information3,'00'),'N','00',NVL(hoi.org_information3,'00'))
FROM hr_organization_information hoi
WHERE hoi.org_information_context = 'Local Tax Rules'
AND hoi.organization_id         = p_tax_unit_id
AND hoi.org_information1        = p_juri_code;

CURSOR sit_exists IS
SELECT DISTINCT sit_exists
FROM pay_us_state_tax_info_f
WHERE state_code = SUBSTR(p_juri_code, 1, 2)
AND TO_DATE(l_date_earned, 'DD-MM-YYYY') BETWEEN
    effective_start_date AND effective_end_date;

CURSOR city_exists IS
SELECT city_tax
FROM pay_us_city_tax_info_f
WHERE jurisdiction_code = p_juri_code
AND TO_DATE(l_date_earned, 'DD-MM-YYYY') BETWEEN
    effective_start_date AND effective_end_date;

CURSOR county_exists IS
SELECT county_tax
FROM pay_us_county_tax_info_f
WHERE jurisdiction_code = substr(p_juri_code, 1, 6) || '-0000'
AND to_date(l_date_earned, 'DD-MM-YYYY') BETWEEN
      effective_start_date AND effective_end_date;

BEGIN

   l_default_rule       := '00';
   l_jit8_rule          := '08';
   l_jit8_rule_nobypass := 'NOBYPASS'; /* Do not bypass the tax - pass JIT
                                          08 along with earnings to Vertex */
   l_date_earned  := to_char(p_date_earned,'DD-MM-YYYY');

   hr_utility.trace('The tax type          : '|| p_type);
   hr_utility.trace('The jurisdiction      : '|| p_juri_code);
   hr_utility.trace('The date earned       : '|| l_date_earned);
   hr_utility.trace('The tax unit id       : '|| to_char(p_tax_unit_id));
   hr_utility.trace('The assignment id     : '|| to_char(p_assign_id));

   SELECT DISTINCT pus.state_abbrev
   INTO l_state_abbrev
   FROM pay_us_states pus
   WHERE pus.state_code = SUBSTR(p_juri_code, 1, 2);

   hr_utility.trace('The state abbrev is:' || l_state_abbrev);

   IF p_type = 'SIT_RS' THEN
   BEGIN

        OPEN sit_exists;
        FETCH sit_exists INTO l_sit_rs_exists;
        IF sit_exists%NOTFOUND THEN
          CLOSE sit_exists;
          RETURN l_jit8_rule;
        END IF;
        CLOSE sit_exists;

        IF l_sit_rs_exists = 'Y' THEN

           OPEN state_employer_info;
           FETCH state_employer_info INTO l_state_employer_info;
           IF state_employer_info%NOTFOUND THEN
              CLOSE state_employer_info;
              RETURN l_default_rule;
           END IF;

           CLOSE state_employer_info;

           OPEN state_rule;
           FETCH state_rule INTO l_state_rule;
           IF state_rule%NOTFOUND THEN

              CLOSE state_rule;
              IF l_state_employer_info = 'N' THEN

                 IF hr_us_ff_udf1.get_work_state(substr(p_juri_code, 1, 2)) = 'Y' THEN
                     RETURN l_default_rule;
                 ELSE
                     RETURN l_jit8_rule;
                 END IF;
              ELSE
                 RETURN l_default_rule;
              END IF;

           ELSE

              CLOSE state_rule;
              IF l_state_rule = 'Y' THEN

                 IF hr_us_ff_udf1.get_work_state(substr(p_juri_code, 1, 2)) = 'Y' THEN
                     RETURN l_default_rule;
                 ELSE
                     RETURN l_jit8_rule;
                 END IF;

              ELSE
                 IF l_state_rule = '08' THEN
                    l_state_rule := l_jit8_rule_nobypass;
                 END IF;
                 RETURN l_state_rule;
              END IF;

           END IF;

        ELSE
           RETURN l_jit8_rule;
        END IF;

   END;  /* SIT_RS */

   ELSIF (p_type = 'CITY_RS' OR
          p_type = 'SD_RS')  THEN
   BEGIN

        IF (p_type = 'CITY_RS') THEN
           OPEN city_exists;
           FETCH city_exists INTO l_city_rs_exists;
           IF city_exists%NOTFOUND THEN
             CLOSE city_exists;
             RETURN l_jit8_rule;
           END IF;
           CLOSE city_exists;
        ELSE
           l_city_rs_exists := 'Y';
        END IF;

        IF l_city_rs_exists = 'Y' THEN

           OPEN state_rule_for_local;
           FETCH state_rule_for_local INTO l_state_rule_for_local;

           IF state_rule_for_local%NOTFOUND THEN
              CLOSE state_rule_for_local;
              RETURN l_default_rule;
           END IF;

           CLOSE state_rule_for_local;

           OPEN local_rule;
           FETCH local_rule INTO l_local_rule;
           IF local_rule%NOTFOUND THEN

              CLOSE local_rule;
              IF l_state_rule_for_local = 'L' THEN

                 l_jd_type := hr_us_ff_udf1.get_jurisdiction_type(p_juri_code);
                 hr_utility.trace('Jurisdiction Type : '||l_jd_type);

                 IF (nvl(l_jd_type,'NL') = 'RT' OR
                     nvl(l_jd_type,'NL') = 'RW' OR
                     nvl(l_jd_type,'NL') = 'HW' OR
                     p_type              = 'SD_RS') THEN
                     RETURN l_default_rule;
                 ELSE
                     RETURN l_jit8_rule;
                 END IF;

              ELSIF (l_state_rule_for_local = 'W') THEN

                 IF (p_type = 'SD_RS') THEN
                    RETURN l_default_rule;
                 ELSE
                    RETURN l_jit8_rule_nobypass;
                 END IF;

              ELSE
                 RETURN l_default_rule;
              END IF;

           ELSE

              CLOSE local_rule;
              IF l_state_rule_for_local = 'W' THEN

                 IF l_local_rule = 'Y' THEN

                    l_jd_type := hr_us_ff_udf1.get_jurisdiction_type(p_juri_code);
                    hr_utility.trace('Jurisdiction Type : '||l_jd_type);

                    IF (nvl(l_jd_type,'NL') = 'RT' OR
                        nvl(l_jd_type,'NL') = 'RW' OR
                        nvl(l_jd_type,'NL') = 'HW' OR
                        p_type              = 'SD_RS') THEN
                       RETURN l_default_rule;
                    ELSE
                       RETURN l_jit8_rule;
                    END IF;

                 ELSIF l_local_rule = l_default_rule THEN

                    IF (p_type = 'SD_RS') THEN
                       RETURN l_default_rule;
                    ELSE
                       RETURN l_jit8_rule_nobypass;
                    END IF;

                 ELSE

                    IF (p_type = 'SD_RS') THEN

                       IF l_local_rule = l_jit8_rule THEN
                          RETURN l_default_rule;
                       ELSE
                          RETURN l_local_rule;
                       END IF;

                    ELSE

                       IF l_local_rule = l_jit8_rule THEN
                          l_local_rule := l_jit8_rule_nobypass;
                       END IF;

                       RETURN l_local_rule;

                    END IF;

                 END IF;

              ELSE

                 IF l_local_rule = 'Y' THEN

                    l_jd_type := hr_us_ff_udf1.get_jurisdiction_type(p_juri_code);
                    hr_utility.trace('Jurisdiction Type : '||l_jd_type);

                    IF (nvl(l_jd_type,'NL') = 'RT' OR
                        nvl(l_jd_type,'NL') = 'RW' OR
                        nvl(l_jd_type,'NL') = 'HW' OR
                        p_type              = 'SD_RS') THEN
                        RETURN l_default_rule;
                    ELSE
                        RETURN l_jit8_rule;
                    END IF;

                 ELSE

                    IF (p_type = 'SD_RS') THEN

                       IF l_local_rule = l_jit8_rule THEN
                          RETURN l_default_rule;
                       ELSE
                          RETURN l_local_rule;
                       END IF;

                    ELSE

                       IF l_local_rule = l_jit8_rule THEN
                          l_local_rule := l_jit8_rule_nobypass;
                       END IF;

                       RETURN l_local_rule;

                    END IF;

                 END IF;

              END IF;

           END IF;

        ELSE
           RETURN l_jit8_rule;
        END IF;

   END;  /* CITY_RS */
   ELSIF p_type = 'COUNTY_RS' THEN
   BEGIN

        IF SUBSTR(p_juri_code, 1, 2) = '15' THEN  /* check for Indiana state */

           IF p_pact_id is not null THEN

              OPEN override_state;
              FETCH override_state INTO l_indiana_override;

              hr_utility.trace('l_indiana_override '||l_indiana_override);
              IF override_state%found THEN

                l_across_years := hr_us_ff_udf1.across_calendar_years(p_pact_id);

                hr_utility.trace('l_across_years '||l_across_years);
                IF (l_indiana_override = 'IN' AND
                    l_across_years     = 'Y') THEN

                  SELECT to_char(effective_date,'dd-mm-yyyy')
                  INTO l_date
                  FROM pay_payroll_actions
                  WHERE payroll_action_id = p_pact_id;

                  hr_utility.trace('l_date '||to_char(l_date));
                ELSE
                  l_date := l_date_earned;
                END IF;

              ELSE
                l_date := l_date_earned;
              END IF;

              CLOSE override_state;

           ELSE
              l_date := l_date_earned;
           END IF;

           l_rs_coty_1st_jan := get_residence_as_of_1st_jan(p_assign_id,
                                                            l_date);

           hr_utility.trace('Resident State is Indiana Jurisdiction '||p_juri_code);
           hr_utility.trace('Resident JD Code as of 1st Jan '|| l_rs_coty_1st_jan);

           IF l_rs_coty_1st_jan = SUBSTR(p_juri_code, 1, 6)  THEN

              OPEN county_exists;
              FETCH county_exists INTO l_county_rs_exists;
              IF county_exists%NOTFOUND THEN
                 CLOSE county_exists;
                 RETURN l_jit8_rule;
              END IF;
              CLOSE county_exists;

              IF (l_county_rs_exists = 'Y') THEN
                 RETURN get_wa_rule (p_juri_code,
                                     p_date_earned,
                                     p_tax_unit_id,
                                     p_assign_id,
                                     p_pact_id,
                                     'SD_RS');
              ELSE
                 RETURN l_jit8_rule;
              END IF;

           ELSE  /* 1st Jan */

              hr_utility.trace('Resident JD Code as of 1st Jan <> Primary JD code as of date');

              RETURN l_jit8_rule; /* the county is not as of 1st Jan */

           END IF; /* 1st Jan */

        ELSE   /* check for Other State  */

           OPEN county_exists;
           FETCH county_exists INTO l_county_rs_exists;
           IF county_exists%NOTFOUND THEN
              CLOSE county_exists;
              RETURN l_jit8_rule;
           END IF;
           CLOSE county_exists;

           IF (l_county_rs_exists = 'Y') THEN

              RETURN get_wa_rule (p_juri_code,
                                  p_date_earned,
                                  p_tax_unit_id,
                                  p_assign_id,
                                  p_pact_id,
                                  'SD_RS');
           ELSE
              RETURN l_jit8_rule;
           END IF;

        END IF;

      END;  /* COUNTY_RS */

   ELSIF (p_type = 'FICA_EE' OR
          p_type = 'FICA_ER') THEN

      IF assignment_tax_exists('FICA',
                              p_assign_id,
                              p_date_earned,
                              p_juri_code) = 'Y' THEN

        RETURN 'N';
      ELSE
        RETURN 'Y';
      END IF;

   ELSIF (p_type = 'MEDI_EE' OR
          p_type = 'MEDI_ER') THEN

      IF assignment_tax_exists('MEDICARE',
                              p_assign_id,
                              p_date_earned,
                              p_juri_code) = 'Y' THEN

        RETURN 'N';
      ELSE
        RETURN 'Y';
      END IF;

   ELSIF p_type = 'FUTA' THEN

      IF assignment_tax_exists('FUTA',
                              p_assign_id,
                              p_date_earned,
                              p_juri_code) = 'Y' THEN

        RETURN 'N';
      ELSE
        RETURN 'Y';
      END IF;

   END IF; /*p_type*/

   RETURN l_default_rule;

END;

FUNCTION get_wage_accum_rule (p_juri_code   IN VARCHAR2,
                              p_date_earned IN DATE,
                              p_tax_unit_id IN NUMBER,
                              p_assign_id   IN NUMBER,
                              p_pact_id     IN NUMBER,
                              p_type        IN VARCHAR2,
                              p_wage_accum  IN VARCHAR2)
RETURN VARCHAR2 IS
--Added for bug 7441418
l_date_paid date;
CURSOR get_date_paid IS
SELECT ppa.effective_date
FROM
 pay_payroll_actions      ppa
WHERE ppa.payroll_action_id=p_pact_id;
--Bug 7441418 ends
BEGIN
  OPEN get_date_paid; --For bug 7441418
  FETCH get_date_paid INTO l_date_paid; --For bug 7441418

  IF get_date_paid%FOUND THEN   --For bug 7441418
   IF p_wage_accum = 'V' THEN

     RETURN get_wa_rule (p_juri_code,
                         l_date_paid,
                         p_tax_unit_id,
                         p_assign_id,
                         p_pact_id,
                         p_type);  --Introduced l_date_paid instead of p_date_earned for bug 7441418
   ELSE

     RETURN get_tax_exists(p_juri_code,
                           l_date_paid,
                           p_tax_unit_id,
                           p_assign_id,
                           p_pact_id,
                           p_type,
                           'F');   --Introduced l_date_paid instead of p_date_earned for bug 7441418
   END IF;
 END IF;
 CLOSE get_date_paid;              --For bug 7441418

END get_wage_accum_rule;

FUNCTION get_wage_accumulation_flag (p_pact_id   IN NUMBER)

RETURN varchar2
IS
l_wage_accumulation_flag   varchar2(2);

l_effective_date   date;
l_wa_date          date;
l_wa_year          varchar2(4);

CURSOR get_wage_acc_flag IS
SELECT parameter_value
FROM pay_action_parameters
WHERE parameter_name = 'WAGE_ACCUMULATION_ENABLED';

CURSOR get_wage_acc_year IS
SELECT parameter_value
FROM pay_action_parameters
WHERE parameter_name = 'WAGE_ACCUMULATION_YEAR';

BEGIN

  hr_utility.trace('Endering get_wage_accumulation_flag');

  OPEN get_wage_acc_flag;
  FETCH get_wage_acc_flag INTO l_wage_accumulation_flag;

  IF get_wage_acc_flag%NOTFOUND THEN

     hr_utility.trace('get_wage_acc_flag%NOTFOUND');

     l_wage_accumulation_flag := 'N';
  ELSE
     hr_utility.trace('get_wage_acc_flag%FOUND');
     IF l_wage_accumulation_flag = 'Y' THEN

        hr_utility.trace('l_wage_accumulation_flag = Y');
        hr_utility.trace('Need to check if WAGE_ACCUMULATION_YEAR IS SET AND COMPARE');

        OPEN get_wage_acc_year;
        FETCH get_wage_acc_year INTO l_wa_year;

        IF get_wage_acc_year%NOTFOUND THEN

            hr_utility.trace('get_wage_acc_year%NOTFOUND no change to l_wage_accumulation_flag');

        ELSE

            hr_utility.trace('get_wage_acc_year%FOUND compare to payroll effective date ');

            l_wa_date := to_date('01-01-' || l_wa_year, 'dd-mm-yyyy');

            hr_utility.trace('l_wa_date = ' || to_char(l_wa_date, 'dd-mon-yyyy') );

            SELECT effective_date
            INTO   l_effective_date
            FROM   pay_payroll_actions
            WHERE  payroll_action_id = p_pact_id;

 hr_utility.trace('l_effective_date = ' || to_char(l_effective_date,
'dd-mon-yyyy') );

            IF l_effective_date >= l_wa_date THEN
               hr_utility.trace('l_effective_date >= l_wa_date '  );
               l_wage_accumulation_flag := 'Y';
            ELSE
               hr_utility.trace('l_effective_date < l_wa_date '  );

               l_wage_accumulation_flag := 'N';
            END IF;

        END IF;

     END IF;
  END IF;

  CLOSE get_wage_acc_flag;

  IF get_wage_acc_year%ISOPEN THEN
     CLOSE get_wage_acc_year;
  END IF;

 hr_utility.trace('l_wage_accumulation_flag = ' || l_wage_accumulation_flag );

  return l_wage_accumulation_flag;

END get_wage_accumulation_flag;


FUNCTION store_pretax_redns
        (p_juri_code          IN varchar2,
         p_tax_type           IN varchar2,
         p_mode               IN varchar2,
         p_125_redns          IN OUT NOCOPY number,
         p_401_redns          IN OUT NOCOPY number,
         p_403_redns          IN OUT NOCOPY number,
         p_457_redns          IN OUT NOCOPY number,
         p_dep_care_redns     IN OUT NOCOPY number,
         p_other_pretax_redns IN OUT NOCOPY number,
         p_gross              IN OUT NOCOPY number,
         p_subj_nwhable       IN OUT NOCOPY number,
         p_location           IN varchar2,
         p_reduced_subj       IN number,
         p_subj               IN number)
RETURN NUMBER
IS

j              NUMBER;
l_ratio        NUMBER;
l_exempt       NUMBER;
l_total_redns  NUMBER;
l_subj_reduced NUMBER;
l_imputed_redns number;

BEGIN

   IF p_mode = 'IN'  THEN

       IF p_tax_type = 'FIT' THEN
          tax_balances.delete;
       END IF;

       l_exempt := 0;
       IF p_location <> 'NA' THEN

         l_total_redns := p_125_redns + p_401_redns + p_403_redns + p_457_redns +
                          p_dep_care_redns + p_other_pretax_redns;
         l_exempt := p_gross - (p_reduced_subj + l_total_redns) - p_subj_nwhable;
       END IF;

       j := tax_balances.COUNT + 1;

       tax_balances(j).jurisdiction_code := p_juri_code;
       tax_balances(j).location          := p_location;
       tax_balances(j).balance_name      := p_tax_type||'_125_REDNS';
       tax_balances(j).amount            := p_125_redns;
       j := j + 1;

       tax_balances(j).jurisdiction_code := p_juri_code;
       tax_balances(j).location          := p_location;
       tax_balances(j).balance_name      := p_tax_type||'_401_REDNS';
       tax_balances(j).amount            := p_401_redns;
       j := j + 1;

       tax_balances(j).jurisdiction_code := p_juri_code;
       tax_balances(j).location          := p_location;
       tax_balances(j).balance_name      := p_tax_type||'_403_REDNS';
       tax_balances(j).amount            := p_403_redns;
       j := j + 1;

       tax_balances(j).jurisdiction_code := p_juri_code;
       tax_balances(j).location          := p_location;
       tax_balances(j).balance_name      := p_tax_type||'_457_REDNS';
       tax_balances(j).amount            := p_457_redns;
       j := j + 1;

       tax_balances(j).jurisdiction_code := p_juri_code;
       tax_balances(j).location          := p_location;
       tax_balances(j).balance_name      := p_tax_type||'_DEP_CARE_REDNS';
       tax_balances(j).amount            := p_dep_care_redns;
       j := j + 1;

       tax_balances(j).jurisdiction_code := p_juri_code;
       tax_balances(j).location          := p_location;
       tax_balances(j).balance_name      := p_tax_type||'_OTHER_PRETAX_REDNS';
       tax_balances(j).amount            := p_other_pretax_redns;
       j := j + 1;

       tax_balances(j).jurisdiction_code := p_juri_code;
       tax_balances(j).location          := p_location;
       tax_balances(j).balance_name      := p_tax_type||'_GROSS';
       tax_balances(j).amount            := p_gross;
       j := j + 1;

       IF (p_location <> 'NA' or p_tax_type = 'FIT') THEN

          tax_balances(j).jurisdiction_code := p_juri_code;
          tax_balances(j).location          := p_location;
          tax_balances(j).balance_name      := p_tax_type||'_SUBJ_NWHABLE';
          tax_balances(j).amount            := p_subj_nwhable;
          j := j + 1;

       END IF;

       IF (p_location <> 'NA') THEN

          tax_balances(j).jurisdiction_code := p_juri_code;
          tax_balances(j).location          := p_location;
          tax_balances(j).balance_name      := p_tax_type||'_EXEMPT';
          tax_balances(j).amount            := l_exempt;
          j := j + 1;

          tax_balances(j).jurisdiction_code := p_juri_code;
          tax_balances(j).location          := p_location;
          tax_balances(j).balance_name      := p_tax_type||'_SUBJ_REDUCED';
          tax_balances(j).amount            := p_reduced_subj;

       END IF;


    ELSIF  p_mode = 'OUT' THEN

       p_125_redns          := 0;
       p_401_redns          := 0;
       p_403_redns          := 0;
       p_457_redns          := 0;
       p_dep_care_redns     := 0;
       p_other_pretax_redns := 0;
       p_gross              := 0;
       p_subj_nwhable       := 0;

       l_subj_reduced       := 0;
       l_imputed_redns      := 0;

       /* In mode OUT and Location RS for State, County and City
          we pass in the amount of Imputed Earnings calculated in the RUN
          as the ratio used to calculate the amount of pretax reductions
          in this procedure included imputed earnings.  The same calculation
          in the US_TAX_VERTEX_WORK formual does not include Imputed earnings */

       IF (p_location = 'RS' ) THEN
         l_imputed_redns  := nvl(p_reduced_subj, 0);
         hr_utility.trace('l_imputed_redns ='||l_imputed_redns);
       END IF;

       IF tax_balances.COUNT > 0 THEN

          l_subj_reduced := get_stored_balance(p_juri_code,
                                               p_tax_type||'_SUBJ_REDUCED',
                                               p_location);

          FOR i IN tax_balances.FIRST..tax_balances.LAST
          LOOP

            IF ((tax_balances(i).jurisdiction_code = p_juri_code) AND
                (tax_balances(i).balance_name      = p_tax_type||'_125_REDNS') AND
                (tax_balances(i).location          = p_location)) THEN

               p_125_redns := tax_balances(i).amount;

               IF (p_location = 'RS' and (l_subj_reduced - l_imputed_redns > 0)) THEN
                  l_ratio := (p_subj - l_imputed_redns) / (l_subj_reduced - l_imputed_redns);
--                  l_ratio := p_subj/l_subj_reduced;
                  p_125_redns := p_125_redns * l_ratio;
               END IF;

            ELSIF ((tax_balances(i).jurisdiction_code = p_juri_code) AND
                   (tax_balances(i).balance_name      = p_tax_type||'_401_REDNS') AND
                   (tax_balances(i).location          = p_location)) THEN

               p_401_redns := tax_balances(i).amount;

               IF (p_location = 'RS' and (l_subj_reduced - l_imputed_redns > 0)) THEN
                  l_ratio := (p_subj - l_imputed_redns) / (l_subj_reduced - l_imputed_redns);
--                  l_ratio := p_subj/l_subj_reduced;
                  p_401_redns := p_401_redns * l_ratio;
               END IF;

            ELSIF ((tax_balances(i).jurisdiction_code = p_juri_code) AND
                   (tax_balances(i).balance_name      = p_tax_type||'_403_REDNS') AND
                   (tax_balances(i).location          = p_location)) THEN

               p_403_redns := tax_balances(i).amount;

               IF (p_location = 'RS' and (l_subj_reduced - l_imputed_redns > 0)) THEN
                  l_ratio := (p_subj - l_imputed_redns) / (l_subj_reduced - l_imputed_redns);
--                  l_ratio := p_subj/l_subj_reduced;
                  p_403_redns := p_403_redns * l_ratio;
               END IF;

            ELSIF ((tax_balances(i).jurisdiction_code = p_juri_code) AND
                   (tax_balances(i).balance_name      = p_tax_type||'_457_REDNS') AND
                   (tax_balances(i).location          = p_location)) THEN

               p_457_redns := tax_balances(i).amount;

               IF (p_location = 'RS' and (l_subj_reduced - l_imputed_redns > 0)) THEN
                  l_ratio := (p_subj - l_imputed_redns) / (l_subj_reduced - l_imputed_redns);
--                  l_ratio := p_subj/l_subj_reduced;
                  p_457_redns := p_457_redns * l_ratio;
               END IF;

            ELSIF ((tax_balances(i).jurisdiction_code = p_juri_code) AND
                   (tax_balances(i).balance_name      = p_tax_type||'_DEP_CARE_REDNS') AND
                   (tax_balances(i).location          = p_location)) THEN

               p_dep_care_redns := tax_balances(i).amount;

               IF (p_location = 'RS' and (l_subj_reduced - l_imputed_redns > 0)) THEN
                  l_ratio := (p_subj - l_imputed_redns) / (l_subj_reduced - l_imputed_redns);
--                  l_ratio := p_subj/l_subj_reduced;
                  p_dep_care_redns := p_dep_care_redns * l_ratio;
               END IF;

            ELSIF ((tax_balances(i).jurisdiction_code = p_juri_code) AND
                   (tax_balances(i).balance_name      = p_tax_type||'_OTHER_PRETAX_REDNS') AND
                   (tax_balances(i).location          = p_location)) THEN

               p_other_pretax_redns := tax_balances(i).amount;

               IF (p_location = 'RS' and (l_subj_reduced - l_imputed_redns > 0)) THEN
                  l_ratio := (p_subj - l_imputed_redns) / (l_subj_reduced - l_imputed_redns);
--                  l_ratio := p_subj/l_subj_reduced;
                  p_other_pretax_redns := p_other_pretax_redns * l_ratio;
               END IF;

            ELSIF ((tax_balances(i).jurisdiction_code = p_juri_code) AND
                   (tax_balances(i).balance_name      = p_tax_type||'_GROSS') AND
                   (tax_balances(i).location          = p_location)) THEN

               IF (p_location = 'WK') THEN

                  IF p_subj = 0 THEN
                     reset_stored_balance(p_juri_code,
                                          p_tax_type||'_EXEMPT',
                                          p_location);
                  ELSE
                     p_gross := get_stored_balance(p_juri_code,
                                                   p_tax_type||'_SUBJ_NWHABLE',
                                                   p_location) +
                                p_subj +
                                get_stored_balance(p_juri_code,
                                                   p_tax_type||'_OTHER_PRETAX_REDNS',
                                                   p_location) +
                                get_stored_balance(p_juri_code,
                                                   p_tax_type||'_DEP_CARE_REDNS',
                                                   p_location) +
                                get_stored_balance(p_juri_code,
                                                   p_tax_type||'_457_REDNS',
                                                   p_location) +
                                get_stored_balance(p_juri_code,
                                                   p_tax_type||'_403_REDNS',
                                                   p_location) +
                                get_stored_balance(p_juri_code,
                                                   p_tax_type||'_401_REDNS',
                                                   p_location) +
                                get_stored_balance(p_juri_code,
                                                   p_tax_type||'_125_REDNS',
                                                   p_location) +
                                get_stored_balance(p_juri_code,
                                                   p_tax_type||'_EXEMPT',
                                                   p_location);
                   END IF;

               ELSIF (p_tax_type = 'SDI_EE' or
                      p_tax_type = 'SDI_ER' or
                      p_tax_type = 'SUI_EE' or
                      p_tax_type = 'SUI_ER')  THEN

                     p_gross := tax_balances(i).amount;

               ELSIF (p_location = 'RS') THEN

                  hr_utility.trace('p_location ='||p_location);
                  hr_utility.trace('p_tax_type ='||p_tax_type);
                  hr_utility.trace('l_subj_reduced ='||l_subj_reduced);
                  hr_utility.trace('p_subj='||p_subj);

                  IF l_subj_reduced  > 0 THEN

                     if l_subj_reduced - l_imputed_redns > 0 THEN
                        l_ratio := (p_subj - l_imputed_redns) / (l_subj_reduced -
l_imputed_redns);
                     else
                        l_ratio := 0;
                     end if;
--
--                  l_ratio := p_subj/l_subj_reduced;

                     p_gross :=(get_stored_balance(p_juri_code,
                                                   p_tax_type||'_SUBJ_NWHABLE',
                                                   p_location) -
                                get_stored_balance(p_juri_code,
                                                   p_tax_type||'_SUBJ_NWHABLE',
                                                   'WK')) +
                                p_subj +
                               (get_stored_balance(p_juri_code,
                                                   p_tax_type||'_EXEMPT',
                                                   p_location) -
                                get_stored_balance(p_juri_code,
                                                   p_tax_type||'_EXEMPT',
                                                   'WK')) +
                                (l_ratio *
                                 (get_stored_balance(p_juri_code,
                                                     p_tax_type||'_OTHER_PRETAX_REDNS',
                                                     p_location) +
                                  get_stored_balance(p_juri_code,
                                                     p_tax_type||'_DEP_CARE_REDNS',
                                                     p_location) +
                                  get_stored_balance(p_juri_code,
                                                     p_tax_type||'_457_REDNS',
                                                     p_location) +
                                  get_stored_balance(p_juri_code,
                                                     p_tax_type||'_403_REDNS',
                                                     p_location) +
                                  get_stored_balance(p_juri_code,
                                                     p_tax_type||'_401_REDNS',
                                                     p_location) +
                                  get_stored_balance(p_juri_code,
                                                     p_tax_type||'_125_REDNS',
                                                     p_location)) );

                  hr_utility.trace('p_gross ='||p_gross);
                  hr_utility.trace('l_ratio ='||l_ratio);

                  END IF;

               END IF;

            ELSIF ((tax_balances(i).jurisdiction_code = p_juri_code) AND
                   (tax_balances(i).balance_name      = p_tax_type||'_SUBJ_NWHABLE') AND
                   (tax_balances(i).location          = p_location)) THEN

               IF (p_location = 'WK') THEN

                  IF p_subj = 0 THEN
                     reset_stored_balance(p_juri_code,
                                          p_tax_type||'_SUBJ_NWHABLE',
                                          p_location);
                  ELSE
                     p_subj_nwhable := tax_balances(i).amount;
                  END IF;

               ELSIF (p_tax_type = 'FIT') THEN
                  p_subj_nwhable := tax_balances(i).amount;

               ELSIF (p_location = 'RS') THEN
                  p_subj_nwhable := tax_balances(i).amount -
                                    get_stored_balance(p_juri_code,
                                                       p_tax_type||'_SUBJ_NWHABLE',
                                                       'WK');
               END IF;

            END IF;

          END LOOP;

       END IF;

    END IF;

    RETURN(0);

END store_pretax_redns;

FUNCTION get_stored_balance
        (p_juri_code          IN varchar2,
         p_balance_name       IN varchar2,
         p_location           IN varchar2)
RETURN number
IS

BEGIN

    IF tax_balances.COUNT > 0 THEN

       FOR i IN tax_balances.FIRST..tax_balances.LAST
       LOOP
         IF ((tax_balances(i).jurisdiction_code = p_juri_code) AND
             (tax_balances(i).balance_name      = p_balance_name) AND
             (tax_balances(i).location          = p_location)) THEN

             RETURN tax_balances(i).amount;

         END IF;
       END LOOP;

     END IF;

     RETURN (0);

END get_stored_balance;

PROCEDURE reset_stored_balance
        (p_juri_code          IN varchar2,
         p_balance_name       IN varchar2,
         p_location           IN varchar2)
IS
BEGIN

    IF tax_balances.COUNT > 0 THEN

       FOR i IN tax_balances.FIRST..tax_balances.LAST
       LOOP
         IF ((tax_balances(i).jurisdiction_code = p_juri_code) AND
             (tax_balances(i).balance_name      = p_balance_name) AND
             (tax_balances(i).location          = p_location)) THEN

                 tax_balances(i).amount := 0;
         END IF;
       END LOOP;

     END IF;

END reset_stored_balance;

END pay_get_tax_exists_pkg;

/
