--------------------------------------------------------
--  DDL for Package Body PAY_GRADE_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GRADE_RULES_PKG" AS
/* $Header: pygrr01t.pkb 120.0 2005/05/29 05:33:51 appldev noship $ */


PROCEDURE CHECK_UNIQUENESS(P_GRADE_RULE_ID_2 IN OUT NOCOPY        NUMBER,
                           P_GRADE_OR_SPINAL_POINT_ID          NUMBER,
            P_RATE_TYPE              VARCHAR2,
                 P_RATE_ID              NUMBER,
            P_BUSINESS_GROUP_ID                 NUMBER,
            P_MODE                              VARCHAR2) IS
  L_DUMMY varchar2(1);


  CURSOR G1 IS
  SELECT NULL
  FROM   PAY_GRADE_RULES_F GR
  WHERE  (GR.GRADE_RULE_ID           <> P_GRADE_RULE_ID_2
         OR P_GRADE_RULE_ID_2 IS NULL)
  AND    GR.GRADE_OR_SPINAL_POINT_ID  = P_GRADE_OR_SPINAL_POINT_ID
  AND    GR.RATE_TYPE                 = P_RATE_TYPE
  AND    GR.RATE_ID                   = P_RATE_ID
  AND    GR.business_group_id + 0         = P_BUSINESS_GROUP_ID;

 CURSOR c1 IS
  SELECT PAY_GRADE_RULES_S.NEXTVAL
  FROM SYS.DUAL;


 BEGIN

  OPEN G1;
  FETCH G1 INTO L_DUMMY;


  IF G1%FOUND THEN
     CLOSE G1;
     IF  P_RATE_TYPE = 'G' THEN
             HR_UTILITY.SET_MESSAGE('801','PAY_6701_DEF_GRD_RULE_EXISTS');
             HR_UTILITY.RAISE_ERROR;
     ELSE
             HR_UTILITY.SET_MESSAGE('801','PAY_6705_DEF_RATE_POINT_EXISTS');
             HR_UTILITY.RAISE_ERROR;
     END IF;

  ELSE

     CLOSE G1;

         IF P_MODE = 'U' THEN

               NULL;
         ELSE

    /*
    -- ***TEMP, I had a call to a procedure to get next value of the sequence
    --         over here but for some reason it gave me an ORA-03113 'End
    --         of file communicaton channel' error. Replaced the procedure
    --         call with the following
    */

        OPEN c1;
             FETCH c1 INTO P_GRADE_RULE_ID_2;
             CLOSE c1;

          END IF;

  END IF;

 END CHECK_UNIQUENESS;

--procedure inserted for use by the spinal point placements form KLS

procedure pop_flds(p_name IN OUT NOCOPY VARCHAR2,
                   p_rt_id IN NUMBER,
                   p_mean IN OUT NOCOPY VARCHAR2,
                   p_bgroup_id IN NUMBER) is

cursor c10 is
select r.name,
       u.meaning
from   hr_lookups u,
       pay_rates r
where  u.lookup_type = 'UNITS'
and    u.lookup_code = r.rate_uom
and    r.rate_id = p_rt_id
and    r.business_group_id + 0 = p_bgroup_id;
--
begin
--
hr_utility.set_location('pay_grade_rules_pkg.pop_flds',1);
--
open c10;
--
  fetch c10 into p_name,
                 p_mean;
--
close c10;
--
end pop_flds;



 PROCEDURE INSERT_ROW(P_ROWID IN OUT NOCOPY                  VARCHAR2,
            P_GRADE_RULE_ID                            NUMBER,
            P_EFFECTIVE_START_DATE                     DATE,
                      P_EFFECTIVE_END_DATE                       DATE,
                      P_BUSINESS_GROUP_ID                        NUMBER,
                      P_RATE_TYPE                                VARCHAR2,
                      P_GRADE_OR_SPINAL_POINT_ID                 NUMBER,
                      P_RATE_ID                                  NUMBER,
                      P_MAXIMUM                                  VARCHAR2,
                      P_MID_VALUE                                VARCHAR2,
                      P_MINIMUM                                  VARCHAR2,
                      P_SEQUENCE                                 NUMBER,
                      P_VALUE                                    VARCHAR2,
                      P_REQUEST_ID                               NUMBER,
                      P_PROGRAM_APPLICATION_ID                   NUMBER,
                      P_PROGRAM_ID                               NUMBER,
                      P_PROGRAM_UPDATE_DATE                      DATE,
                      P_CURRENCY_CODE                            VARCHAR2)
            IS

  -- Fix for bug 2400465
  P_DATE_TO DATE;
  P_END_DATE DATE;
  --
  CURSOR c2 IS
  SELECT ROWID
  FROM PAY_GRADE_RULES_F
  WHERE GRADE_RULE_ID = P_GRADE_RULE_ID;

  -- Fix for bug 2400465
  CURSOR GRADE_DATE_TO IS
  SELECT DATE_TO
  FROM PER_GRADES P
  WHERE P.GRADE_ID = P_GRADE_OR_SPINAL_POINT_ID;
  --

 BEGIN

 -- Fix for bug 2400465
 OPEN GRADE_DATE_TO;
 FETCH GRADE_DATE_TO INTO P_DATE_TO;
 CLOSE GRADE_DATE_TO;
 IF TRIM(P_DATE_TO) IS NOT NULL THEN
    P_END_DATE := P_DATE_TO;
 ELSE
    P_END_DATE := P_EFFECTIVE_END_DATE;
 END IF;
 -- End of fix


 INSERT INTO PAY_GRADE_RULES_F(GRADE_RULE_ID, EFFECTIVE_START_DATE,
                EFFECTIVE_END_DATE, BUSINESS_GROUP_ID,
                RATE_ID, GRADE_OR_SPINAL_POINT_ID, RATE_TYPE,
                MAXIMUM, MID_VALUE, MINIMUM, SEQUENCE, VALUE,
                               REQUEST_ID, PROGRAM_APPLICATION_ID,
                               PROGRAM_ID, PROGRAM_UPDATE_DATE, CURRENCY_CODE)
 VALUES (P_GRADE_RULE_ID, P_EFFECTIVE_START_DATE, P_END_DATE,
         P_BUSINESS_GROUP_ID, P_RATE_ID, P_GRADE_OR_SPINAL_POINT_ID,
         P_RATE_TYPE, P_MAXIMUM, P_MID_VALUE, P_MINIMUM, P_SEQUENCE,
         P_VALUE, P_REQUEST_ID, P_PROGRAM_APPLICATION_ID, P_PROGRAM_ID,
         P_PROGRAM_UPDATE_DATE, P_CURRENCY_CODE);
  OPEN c2;
  FETCH c2 INTO P_ROWID;
  CLOSE c2;


END INSERT_ROW;
--
PROCEDURE UPDATE_ROW( P_ROWID                       VARCHAR2,
            P_GRADE_RULE_ID                            NUMBER,
            P_EFFECTIVE_START_DATE                     DATE,
                      P_EFFECTIVE_END_DATE                       DATE,
                      P_BUSINESS_GROUP_ID                        NUMBER,
                      P_RATE_TYPE                                VARCHAR2,
                      P_GRADE_OR_SPINAL_POINT_ID                 NUMBER,
                      P_RATE_ID                                  NUMBER,
                      P_MAXIMUM                                  VARCHAR2,
                      P_MID_VALUE                                VARCHAR2,
                      P_MINIMUM                                  VARCHAR2,
                      P_SEQUENCE                                 NUMBER,
                      P_VALUE                                    VARCHAR2,
                      P_REQUEST_ID                               NUMBER,
                      P_PROGRAM_APPLICATION_ID                   NUMBER,
                      P_PROGRAM_ID                               NUMBER,
                      P_PROGRAM_UPDATE_DATE                      DATE,
                      P_CURRENCY_CODE                            VARCHAR2)
            IS
 BEGIN
  UPDATE PAY_GRADE_RULES_F
  SET GRADE_RULE_ID                 =            P_GRADE_RULE_ID,
      EFFECTIVE_START_DATE          =            P_EFFECTIVE_START_DATE,           EFFECTIVE_END_DATE            =            P_EFFECTIVE_END_DATE,
      BUSINESS_GROUP_ID             =            P_BUSINESS_GROUP_ID,
      RATE_TYPE                     =            P_RATE_TYPE,
      GRADE_OR_SPINAL_POINT_ID      =            P_GRADE_OR_SPINAL_POINT_ID,
      RATE_ID                       =            P_RATE_ID,
      MAXIMUM                       =            P_MAXIMUM,
      MID_VALUE                     =            P_MID_VALUE,
      MINIMUM                       =            P_MINIMUM,
      SEQUENCE                      =            P_SEQUENCE,
      VALUE                         =            P_VALUE,
      REQUEST_ID                    =            P_REQUEST_ID,
      PROGRAM_APPLICATION_ID        =            P_PROGRAM_APPLICATION_ID,
      PROGRAM_ID                    =            P_PROGRAM_ID,
      PROGRAM_UPDATE_DATE           =            P_PROGRAM_UPDATE_DATE,
      CURRENCY_CODE                 =            P_CURRENCY_CODE

       WHERE ROWID = chartorowid(P_ROWID);
  END UPDATE_ROW;
--
  PROCEDURE DELETE_ROW(P_ROWID VARCHAR2) IS
  BEGIN
    DELETE FROM PAY_GRADE_RULES_F
    WHERE PAY_GRADE_RULES_F.ROWID = chartorowid(P_ROWID);
  END DELETE_ROW;
--
  PROCEDURE LOCK_ROW( P_ROWID                       VARCHAR2,
            P_GRADE_RULE_ID                            NUMBER,
            P_EFFECTIVE_START_DATE                     DATE,
                      P_EFFECTIVE_END_DATE                       DATE,
                      P_BUSINESS_GROUP_ID                        NUMBER,
                      P_RATE_TYPE                                VARCHAR2,
                      P_GRADE_OR_SPINAL_POINT_ID                 NUMBER,
                      P_RATE_ID                                  NUMBER,
                      P_MAXIMUM                                  VARCHAR2,
                      P_MID_VALUE                                VARCHAR2,
                      P_MINIMUM                                  VARCHAR2,
                      P_SEQUENCE                                 NUMBER,
                      P_VALUE                                    VARCHAR2,
                      P_REQUEST_ID                               NUMBER,
                      P_PROGRAM_APPLICATION_ID                   NUMBER,
                      P_PROGRAM_ID                               NUMBER,
                      P_PROGRAM_UPDATE_DATE                      DATE,
                      P_CURRENCY_CODE                            VARCHAR2)
            IS
   CURSOR C IS SELECT * FROM PAY_GRADE_RULES_F
          WHERE ROWID = chartorowid(P_ROWID)
          FOR UPDATE OF GRADE_RULE_ID NOWAIT;
   RECINFO C%ROWTYPE;
   BEGIN
   OPEN C;
   FETCH C INTO RECINFO;

   CLOSE C;

RECINFO.rate_type := rtrim(RECINFO.rate_type);
RECINFO.maximum := rtrim(RECINFO.maximum);
RECINFO.mid_value := rtrim(RECINFO.mid_value);
RECINFO.minimum := rtrim(RECINFO.minimum);
RECINFO.value := rtrim(RECINFO.value);

 IF (((RECINFO.GRADE_RULE_ID = P_GRADE_RULE_ID)
 OR (RECINFO.GRADE_RULE_ID IS NULL AND P_GRADE_RULE_ID IS NULL))
  AND((RECINFO.EFFECTIVE_START_DATE = P_EFFECTIVE_START_DATE)
 OR (RECINFO.EFFECTIVE_START_DATE IS NULL AND P_EFFECTIVE_START_DATE IS NULL))
 AND((RECINFO.EFFECTIVE_END_DATE = P_EFFECTIVE_END_DATE)
 OR (RECINFO.EFFECTIVE_END_DATE IS NULL AND P_EFFECTIVE_END_DATE IS NULL))
 AND((RECINFO.BUSINESS_GROUP_ID  = P_BUSINESS_GROUP_ID)
 OR(RECINFO.BUSINESS_GROUP_ID IS NULL AND P_BUSINESS_GROUP_ID IS NULL))
  AND((RECINFO.RATE_TYPE = P_RATE_TYPE)
 OR(RECINFO.RATE_TYPE IS NULL AND P_RATE_TYPE IS NULL))
 AND((RECINFO.GRADE_OR_SPINAL_POINT_ID = P_GRADE_OR_SPINAL_POINT_ID)
 OR(RECINFO.GRADE_OR_SPINAL_POINT_ID IS NULL AND P_GRADE_OR_SPINAL_POINT_ID IS NULL))
 AND((RECINFO.RATE_ID = P_RATE_ID)
 OR(RECINFO.RATE_ID IS NULL AND P_RATE_ID IS NULL))
 AND((RECINFO.MAXIMUM = P_MAXIMUM)
 OR(RECINFO.MAXIMUM IS NULL AND P_MAXIMUM IS NULL))
 AND((RECINFO.MID_VALUE = P_MID_VALUE)
 OR(RECINFO.MID_VALUE IS NULL AND P_MID_VALUE IS NULL))
 AND((RECINFO.MINIMUM = P_MINIMUM )
 OR(RECINFO.MINIMUM IS NULL AND P_MINIMUM IS NULL))
  AND((RECINFO.SEQUENCE = P_SEQUENCE)
 OR(RECINFO.SEQUENCE IS NULL AND P_SEQUENCE IS NULL))
 AND((RECINFO.VALUE = P_VALUE )
 OR(RECINFO.VALUE IS NULL AND P_VALUE IS NULL))
 AND((RECINFO.REQUEST_ID = P_REQUEST_ID)
 OR(RECINFO.REQUEST_ID IS NULL AND P_REQUEST_ID IS NULL))
 AND((RECINFO.PROGRAM_APPLICATION_ID = P_PROGRAM_APPLICATION_ID)
 OR(RECINFO.PROGRAM_APPLICATION_ID IS NULL AND P_PROGRAM_APPLICATION_ID IS NULL))
 AND((RECINFO.PROGRAM_ID = P_PROGRAM_ID)
 OR(RECINFO.PROGRAM_ID IS NULL AND P_PROGRAM_ID IS NULL))
 AND((RECINFO.PROGRAM_UPDATE_DATE = P_PROGRAM_UPDATE_DATE)
 OR(RECINFO.PROGRAM_UPDATE_DATE IS NULL AND P_PROGRAM_UPDATE_DATE IS NULL))
 AND((RECINFO.CURRENCY_CODE = P_CURRENCY_CODE)
 OR(RECINFO.CURRENCY_CODE IS NULL AND P_CURRENCY_CODE IS NULL)))
THEN
 RETURN;
ELSE
 FND_MESSAGE.SET_NAME('FND','FORM_RECORD_CHANGED');
 APP_EXCEPTION.RAISE_EXCEPTION;
END IF;

END LOCK_ROW;

FUNCTION POPULATE_RATE (p_spinal_point_id IN NUMBER, p_effective_date IN DATE)

RETURN VARCHAR IS

l_name pay_rates.name%TYPE;
l_spinal_point_id number := p_spinal_point_id;

begin

  select pr.name
  into l_name
  from pay_rates pr, pay_grade_rules_f g
  where pr.rate_id = g.rate_id
  and g.grade_or_spinal_point_id = l_spinal_point_id
  and p_effective_date between g.effective_start_date and g.effective_end_date
  and g.rate_type = 'SP'; -- Fix 3401079

  return l_name;

exception

  when too_many_rows then

    fnd_message.set_name('PER','HR_289938_MULTIPLE_RATES');
    l_name := fnd_message.get;
    return l_name;

  when no_data_found then

    fnd_message.set_name('PER','HR_289939_NO_RATES');
    l_name := fnd_message.get;
    return l_name;

END POPULATE_RATE;

FUNCTION POPULATE_VALUE(p_spinal_point_id IN NUMBER, p_effective_date IN DATE)

RETURN VARCHAR IS

l_value  pay_grade_rules_f.value%TYPE;
l_rate_uom pay_rates.rate_uom%TYPE;
l_currency_code pay_grade_rules_f.currency_code%TYPE;
l_format_value  varchar2(500);
l_spinal_point_id number := p_spinal_point_id;

begin

  select g.value, r.rate_uom, g.currency_code
  into l_value, l_rate_uom, l_currency_code
  from pay_grade_rules_f g, pay_rates r
  where g.rate_id = r.rate_id
  and g.grade_or_spinal_point_id = l_spinal_point_id
  and p_effective_date between g.effective_start_date and g.effective_end_date
  and g.rate_type = 'SP'; -- Fix 3401079

  hr_chkfmt.changeformat
      (l_value
      ,l_format_value
      ,l_rate_uom
      ,l_currency_code
      );

  return l_format_value;

exception

  when too_many_rows then

    fnd_message.set_name('PER','HR_289930_POINT_VALUE_RETURNED');
    l_format_value := fnd_message.get;
    return l_format_value;

  when no_data_found then

    fnd_message.set_name('PER','HR_289937_NO_VALUES');
    l_format_value := fnd_message.get;
    return l_format_value;

END POPULATE_VALUE;

FUNCTION POPULATE_UNITS(p_spinal_point_id IN NUMBER, p_effective_date IN DATE)

RETURN VARCHAR IS

l_meaning hr_lookups.meaning%TYPE;
l_bg_id pay_rates.business_group_id%TYPE;
l_rate_id pay_rates.rate_id%TYPE;
l_spinal_point_id number := p_spinal_point_id;

begin

    select r.rate_id, r.business_group_id
    into l_rate_id, l_bg_id
    from pay_grade_rules_f g, pay_rates r
    where r.rate_id = g.rate_id
    and GRADE_OR_SPINAL_POINT_ID = l_spinal_point_id
    and p_effective_date between g.effective_start_date and g.effective_end_date
    and g.rate_type = 'SP'; -- Fix 3401079

    select u.meaning
    into   l_meaning
    from   hr_lookups u,
    pay_rates r
    where  u.lookup_type = 'UNITS'
    and    u.lookup_code = r.rate_uom
    and    r.rate_id = l_rate_id
    and    r.business_group_id + 0 = l_bg_id;

    return l_meaning;

exception

  when too_many_rows  then

    fnd_message.set_name('PER','HR_289940_MULTIPLE_UNITS');
    l_meaning := fnd_message.get;
    return l_meaning;

  when no_data_found then

    fnd_message.set_name('PER','HR_289941_NO_UNITS');
    l_meaning := fnd_message.get;
    return l_meaning;

END POPULATE_UNITS;

-- Bug fix 2651173
procedure chk_emp_asgmnt_bef_del(p_spinal_point_id in number,
                                 p_parent_spine_id in number,
                                 p_effective_date in date,
                                 p_point_used out nocopy varchar2) is

l_exists varchar2(1);
-- Start of fix 3774889
/*
cursor emp_asgmnt_point is
select 'x'
from per_spinal_points psp,
     pay_grade_rules_f pgr,
     per_spinal_point_steps_f psps,
     per_spinal_point_placements_f pspp
where psp.spinal_point_id = pgr.grade_or_spinal_point_id
and psp.parent_spine_id = pspp.parent_spine_id
and psp.spinal_point_id = psps.spinal_point_id
and psps.step_id = pspp.step_id
and pgr.rate_type = 'SP'
and nvl(p_effective_date, hr_api.g_sot)
between pspp.effective_start_date
and pspp.effective_end_date
and psp.spinal_point_id = p_spinal_point_id
and psp.parent_spine_id = p_parent_spine_id;
*/
-- End of fix 3774889
cursor emp_asgmnt_point_used is
select 'x'
from per_spinal_points psp,
     pay_grade_rules_f pgr,
     per_spinal_point_steps_f psps,
     per_spinal_point_placements_f pspp
where psp.spinal_point_id = pgr.grade_or_spinal_point_id
and psp.parent_spine_id = pspp.parent_spine_id
and psp.spinal_point_id = psps.spinal_point_id
and psps.step_id = pspp.step_id
and pgr.rate_type = 'SP'
and psp.spinal_point_id = p_spinal_point_id
and psp.parent_spine_id = p_parent_spine_id;

begin
--
hr_utility.set_location('per_grade_rules_pkg.chk_emp_asgmnt_bef_del', 1);
--
-- Start of fix 3774889
/*
open emp_asgmnt_point;
fetch emp_asgmnt_point into l_exists;
IF emp_asgmnt_point%found THEN
  hr_utility.set_message(800, 'PER_289570_ASGMNT_POINT_VALUE');
  close emp_asgmnt_point;
  hr_utility.raise_error;
END IF;
--
close emp_asgmnt_point;
--
*/
-- End of fix 3774889
open emp_asgmnt_point_used;
fetch emp_asgmnt_point_used into l_exists;
IF emp_asgmnt_point_used%found THEN
   p_point_used := 'Y';
   close emp_asgmnt_point_used;
ELSE
   p_point_used := 'N';
   close emp_asgmnt_point_used;
END IF;
--
end chk_emp_asgmnt_bef_del;
--

END PAY_GRADE_RULES_PKG;

/
