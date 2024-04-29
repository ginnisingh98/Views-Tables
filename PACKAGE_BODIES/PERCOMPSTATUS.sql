--------------------------------------------------------
--  DDL for Package Body PERCOMPSTATUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PERCOMPSTATUS" AS
/* $Header: hrcpstats.pkb 120.0 2005/05/31 23:55:44 appldev noship $*/
/* this fucntion returns the status of the competency
   it checks for the outcomes defined for the competency
   and if all the outcomes are achieved then return ACHIEVED else
   IN_PROGRESS*/
FUNCTION Get_Competence_Status
    (p_competence_id           in varchar2
    ,p_competence_element_id   in varchar2
    ,p_item_type               IN VARCHAR2 DEFAULT null
    ,p_item_key                IN VARCHAR2 DEFAULT null
    ,p_activity_id             IN VARCHAR2 DEFAULT null
    ,p_eff_date                in date default trunc(sysdate)
    ) return VARCHAR2 is
CURSOR getEndDatedOutcomes(compEleId IN Number) is
       Select max(ceo.date_to),ceo.outcome_id
       FROM per_comp_element_outcomes ceo , per_competence_outcomes pco
       where competence_element_id = compEleId
       AND ceo.date_to < p_eff_date
       and pco.outcome_id = ceo.outcome_id
       and pco.date_from <= p_eff_date
       and nvl(pco.date_to,p_eff_date) >= p_eff_date
       group by ceo.outcome_id;

l_competence_cluster   per_competences_vl.competence_cluster%type;
l_noof_outcomes        number;
p_person_id    per_competence_elements.person_id%type;
l_status       per_competence_elements.status%type;
l_achieved_date per_competence_elements.Achieved_date%type;
begin
Select competence_cluster INTO l_competence_cluster FROM per_competences_vl
       WHERE competence_id = p_competence_id;
IF l_competence_cluster = 'UNIT_STANDARD'  then
 IF p_competence_element_id IS NOT NULL then
-- added for the 4187713 bug.
-- Getting the End date outcome rec which were achieved earlier.
  Select pce.status, pce.Achieved_date, pce.person_id
         INTO l_status, l_achieved_date, p_person_id
    FROM per_competence_elements pce
    Where pce.competence_element_id = p_competence_element_id;
  IF l_status = 'ACHIEVED' AND l_achieved_date <= p_eff_date then
   FOR EndDatedRec IN getEndDatedOutcomes(p_competence_element_id)
   loop
        -- checking if the end dated outcome has achieved rec for the effective date.
     Select count(*) INTO l_noof_outcomes
        FROM Per_comp_element_outcomes CEO
        Where ceo.outcome_id = EndDatedRec.outcome_id
        AND ceo.competence_element_id = p_competence_element_id
        AND ceo.date_from <= p_eff_date
        AND nvl(ceo.date_to,p_eff_date) >= p_eff_date;
      IF l_noof_outcomes = 0 Then
        IF p_item_type IS NULL OR p_item_key IS NULL then
           RETURN 'IN_PROGRESS';
        else
        -- checking if the outcome is achieved in current session.
          Select count(*) INTO l_noof_outcomes
          FROM hr_api_transaction_steps S, hr_api_transaction_values tv,
             hr_api_transaction_values tv1, hr_api_transaction_values tv2,
             hr_api_transaction_values tv3
             Where  s.item_type = p_item_type
                and s.item_key = p_item_key
                and s.activity_id = nvl(to_number(p_activity_id),s.activity_id)
                AND s.API_NAME = 'HR_COMP_OUTCOME_PROFILE_SS.PROCESS_API'
                and tv.transaction_step_id = s.transaction_step_id
                and tv1.transaction_step_id = s.transaction_step_id
                and tv2.transaction_step_id = s.transaction_step_id
                and tv3.transaction_step_id = s.transaction_step_id
                AND tv3.NAME = 'P_COMPETENCE_ELEMENT_ID'
                AND tv3.Number_Value = p_competence_element_id
                AND tv.NAME = 'P_OUTCOME_ID'
                AND tv1.NAME = 'P_DATE_FROM'
                AND tv2.NAME = 'P_DATE_TO'
                AND tv.number_value = EndDatedRec.outcome_id
                AND tv1.date_value <= p_eff_date
                AND nvl(tv2.date_value,p_eff_date) >= p_eff_date;


            IF l_noof_outcomes = 0 then
             RETURN 'IN_PROGRESS';
            END if;
        END if;
      END if;

   END loop;

   IF p_item_type IS NULL OR p_item_key IS NULL then
      RETURN 'ACHIEVED';
   ELSE -- p_ietm_type and p_item_key is not null
      Select count(*) into l_noof_outcomes FROM hr_api_transaction_steps S, hr_api_transaction_values C,
                                   Per_comp_element_outcomes CEO
                                    Where  s.item_type = p_item_type
                                    and s.item_key = p_item_key
                                    and s.activity_id = nvl(to_number(p_activity_id),s.activity_id)
                                    and s.api_name = 'HR_COMP_OUTCOME_PROFILE_SS.DELETE'
                                    and c.transaction_step_id = s.transaction_step_id
                                    AND C.NAME = 'P_COMP_ELEMENT_OUTCOME_ID'
                                    AND C.NUMBER_VALUE = CEO.COMP_ELEMENT_OUTCOME_ID
                                    AND ceo.Competence_element_id = p_competence_element_id;

       IF l_noof_outcomes > 0 then
          RETURN 'IN_PROGRESS';
       ELSE -- l_noof_outcomes = 0

         Select count(*) INTO l_noof_outcomes
          FROM hr_api_transaction_steps ts,
          hr_api_transaction_values tv,
                             hr_api_transaction_values tv1, hr_api_transaction_values tv2,
                             hr_api_transaction_values tv3, per_competence_outcomes pco
          Where ts.ITEM_TYPE  = p_item_type
                                      AND ts.item_key  = p_item_key
                                      And ts.activity_id = nvl(to_number(p_activity_id),ts.activity_id)
                                      AND ts.API_NAME = 'HR_COMP_OUTCOME_PROFILE_SS.PROCESS_API'
                                      AND ts.TRANSACTION_STEP_ID = tv.TRANSACTION_STEP_ID
                                      AND ts.TRANSACTION_STEP_ID = tv1.TRANSACTION_STEP_ID
                                      AND ts.TRANSACTION_STEP_ID = tv2.TRANSACTION_STEP_ID
                                      AND ts.TRANSACTION_STEP_ID = tv3.TRANSACTION_STEP_ID
                                      AND tv3.NAME = 'P_PERSON_ID'
                                      AND tv3.Number_Value = p_person_id
                                      AND tv.NAME = 'P_OUTCOME_ID'
                                      AND tv1.NAME = 'P_DATE_FROM'
                                      AND tv2.NAME = 'P_DATE_TO'
                                      And tv.number_value = pco.outcome_id
                                      AND pco.competence_id = p_competence_id
            AND nvl(p_eff_date,trunc(sysdate)) BETWEEN pco.date_from AND nvl(pco.date_to,nvl(p_eff_date,trunc(sysdate)))
                                      AND nvl(tv2.date_value,trunc(p_eff_date)) < trunc(p_eff_date);
        IF l_noof_outcomes = 0 then
        RETURN 'ACHIEVED';
        ELSE
        RETURN 'IN_PROGRESS';
        END if;

     END if; -- end of l_noof_outcomes > 0


   END if; --End  p_ietm_type or p_item_key is null

  END if; -- end of status = 'ACHIEVED'



-- END for the 4187713 bug.
     Select count(*) INTO l_noof_outcomes from
            per_competence_outcomes pco
            WHERE competence_id = p_competence_id
            AND nvl(p_eff_date,trunc(sysdate)) BETWEEN date_from AND nvl(date_to,nvl(p_eff_date,trunc(sysdate)))
            AND NOT EXISTS ( (Select 1 FROM per_comp_element_outcomes
                                      Where competence_element_id = p_competence_element_id
                                      AND per_comp_element_outcomes.outcome_id = pco.outcome_id
                                      AND nvl(p_eff_date,trunc(sysdate)) BETWEEN date_from AND nvl(date_to,nvl(p_eff_date,trunc(sysdate)))
                                      AND NOT EXISTS
                                      (Select 1 FROM hr_api_transaction_steps S, hr_api_transaction_values C,
                                          Per_comp_element_outcomes CEO
                                          Where  s.item_type = p_item_type
                                          and s.item_key = p_item_key
                                          and s.activity_id = nvl(to_number(p_activity_id),s.activity_id)
                                          and s.api_name = 'HR_COMP_OUTCOME_PROFILE_SS.DELETE'
                                          and c.transaction_step_id = s.transaction_step_id
                                          AND C.NAME = 'P_COMP_ELEMENT_OUTCOME_ID'
                                          AND C.NUMBER_VALUE = CEO.COMP_ELEMENT_OUTCOME_ID
                                          AND ceo.Competence_element_id = p_competence_element_id
                                          AND ceo.Outcome_id = pco.Outcome_id))
                                         Union All
                                          (Select 1 FROM hr_api_transaction_values tv,
                                         hr_api_transaction_values tv1, hr_api_transaction_values tv2,
                                          hr_api_transaction_values tv3 , hr_api_transaction_steps ts
                                      Where ts.ITEM_TYPE  = p_item_type
                                      AND ts.item_key  = p_item_key
                                      And ts.activity_id = nvl(to_number(p_activity_id),ts.activity_id)
                                      AND ts.API_NAME = 'HR_COMP_OUTCOME_PROFILE_SS.PROCESS_API'
                                      AND ts.TRANSACTION_STEP_ID = tv.TRANSACTION_STEP_ID
                                      AND ts.TRANSACTION_STEP_ID = tv1.TRANSACTION_STEP_ID
                                      AND ts.TRANSACTION_STEP_ID = tv2.TRANSACTION_STEP_ID(+)
                                      AND ts.TRANSACTION_STEP_ID = tv3.TRANSACTION_STEP_ID
                                      AND tv3.NAME = 'P_PERSON_ID'
                                      AND tv3.Number_Value = p_person_id
                                      AND tv.NAME = 'P_OUTCOME_ID'
                                      AND tv1.NAME = 'P_DATE_FROM'
                                      AND tv2.NAME(+) = 'P_DATE_TO'
                                      And tv.number_value = pco.outcome_id
                                      And trunc(p_eff_date) BETWEEN tv1.date_value
                                      AND nvl(tv2.date_value,trunc(p_eff_date))));
 else
   Select count(*) INTO l_noof_outcomes from
     per_competence_outcomes pco
     Where pco.Competence_id = p_competence_id
      AND pco.date_from <= p_eff_date
      AND nvl(pco.date_to,p_eff_date) >= p_eff_date;
 END if;
      IF l_noof_outcomes = 0 then
        RETURN 'ACHIEVED';
     else
        RETURN 'IN_PROGRESS';
     END if;
ELSE
    Return 'ACHIEVED';
END if;
End Get_Competence_Status;
------------
function get_status_meaning_and_id
    (p_competence_id         in varchar2
    ,p_competence_element_id in varchar2
    ,p_item_type               IN VARCHAR2 DEFAULT null
    ,p_item_key                IN VARCHAR2 DEFAULT null
    ,p_activity_id             IN VARCHAR2 DEFAULT null
    ,p_eff_date              IN DATE DEFAULT trunc(sysdate))
    RETURN VARCHAR2 is
l_status_id per_competence_elements.status%type;
l_status_meaning           varchar2(100);
l_noof_outcomes            number;
l_competence_cluster       per_competences.competence_cluster%type;
p_person_id    per_competence_elements.person_id%type;
begin
l_status_id := PerCompStatus.Get_Competence_Status(
                   p_competence_id          =>  p_competence_id
                   ,p_competence_element_id =>  p_competence_element_id
                   ,p_item_type            =>   p_item_type
                   ,p_item_key             =>   p_item_key
                   ,p_activity_id          =>   p_activity_id
                   ,p_eff_date             =>   p_eff_date );
Select HR_GENERAL.DECODE_LOOKUP('PER_QUAL_FWK_COMP_STATUS', l_status_id) INTO  l_status_meaning
       FROM dual;
       RETURN l_status_meaning;
END get_status_meaning_and_id;
----------
FUNCTION Get_Competence_Status
    (p_item_type       in varchar2
    ,p_item_key        IN varchar2
    ,p_activity_id     IN varchar2
    ,p_competence_id   in number
    ,p_competence_element_id IN NUMBER DEFAULT null
    ,p_person_id             IN number
    ,p_eff_date                in date default trunc(sysdate)
    ) return VARCHAR2 is
l_competence_cluster   per_competences_vl.competence_cluster%type;
l_noof_outcomes        number;
l_comp_status          per_competence_elements.status%type;
begin
Select competence_cluster INTO l_competence_cluster FROM per_competences_vl
       WHERE competence_id = p_competence_id;
IF l_competence_cluster = 'UNIT_STANDARD' then
   IF p_competence_element_id IS NOT NULL OR p_competence_element_id > 0 then
      l_comp_status := Get_Competence_Status(
                 p_competence_id          => p_competence_id
                ,p_competence_element_id  => p_competence_element_id
                ,p_item_type              => p_item_type
                ,p_item_key               => p_item_key
                ,p_activity_id            => p_activity_id
                ,p_eff_date               => p_eff_date );
      RETURN l_comp_status;
   END if;
     Select count(*) INTO l_noof_outcomes
         from
            per_competence_outcomes pco
            WHERE pco.competence_id = p_competence_id
            AND nvl(p_eff_date,sysdate) BETWEEN pco.date_from AND nvl(pco.date_to,nvl(p_eff_date,trunc(sysdate)))
            AND NOT exists (Select 1 FROM hr_api_transaction_values tv,
                             hr_api_transaction_values tv1, hr_api_transaction_values tv2,
                             hr_api_transaction_values tv3 , hr_api_transaction_steps ts
                                      Where ts.ITEM_TYPE  = p_item_type
                                      AND ts.item_key  = p_item_key
                                      And ts.activity_id = nvl(to_number(p_activity_id),ts.activity_id)
                                      AND ts.API_NAME = 'HR_COMP_OUTCOME_PROFILE_SS.PROCESS_API'
                                      AND ts.TRANSACTION_STEP_ID = tv.TRANSACTION_STEP_ID
                                      AND ts.TRANSACTION_STEP_ID = tv1.TRANSACTION_STEP_ID
                                      AND ts.TRANSACTION_STEP_ID = tv2.TRANSACTION_STEP_ID(+)
                                      AND ts.TRANSACTION_STEP_ID = tv3.TRANSACTION_STEP_ID
                                      AND tv3.NAME = 'P_PERSON_ID'
                                      AND tv3.Number_Value = p_person_id
                                      AND tv.NAME = 'P_OUTCOME_ID'
                                      AND tv1.NAME = 'P_DATE_FROM'
                                      AND tv2.NAME(+) = 'P_DATE_TO'
                                      And tv.number_value = pco.outcome_id
                                      And trunc(p_eff_date) BETWEEN tv1.date_value
                                      AND nvl(tv2.date_value,trunc(p_eff_date))
                                      Union all
                                      (Select 1 FROM Per_comp_element_outcomes CEO
                                          Where ceo.Competence_element_id = p_competence_element_id
                                          AND ceo.Outcome_id = pco.Outcome_id
                                          And ceo.date_from <= trunc(p_eff_date)
                                          AND nvl(ceo.date_to,trunc(p_eff_date)) >= trunc(p_eff_date)
                                          AND NOT EXISTS ( SELECT 1 from
                                         hr_api_transaction_steps S, hr_api_transaction_values C
                                          Where  s.item_type = p_item_type
                                          and s.item_key = p_item_key
                                          and s.activity_id = nvl(to_number(p_activity_id),s.activity_id)
                                          and s.api_name = 'HR_COMP_OUTCOME_PROFILE_SS.DELETE'
                                          and c.transaction_step_id = s.transaction_step_id
                                          AND C.NAME = 'P_COMP_ELEMENT_OUTCOME_ID'
                                          AND C.NUMBER_VALUE = CEO.COMP_ELEMENT_OUTCOME_ID
                                          )));
     IF l_noof_outcomes = 0 then
        Select count(*) INTO l_noof_outcomes
          FROM hr_api_transaction_steps ts,
          hr_api_transaction_values tv,
                             hr_api_transaction_values tv1, hr_api_transaction_values tv2,
                             hr_api_transaction_values tv3, per_competence_outcomes pco
          Where ts.ITEM_TYPE  = p_item_type
                                      AND ts.item_key  = p_item_key
                                      And ts.activity_id = nvl(to_number(p_activity_id),ts.activity_id)
                                      AND ts.API_NAME = 'HR_COMP_OUTCOME_PROFILE_SS.PROCESS_API'
                                      AND ts.TRANSACTION_STEP_ID = tv.TRANSACTION_STEP_ID
                                      AND ts.TRANSACTION_STEP_ID = tv1.TRANSACTION_STEP_ID
                                      AND ts.TRANSACTION_STEP_ID = tv2.TRANSACTION_STEP_ID(+)
                                      AND ts.TRANSACTION_STEP_ID = tv3.TRANSACTION_STEP_ID
                                      AND tv3.NAME = 'P_PERSON_ID'
                                      AND tv3.Number_Value = p_person_id
                                      AND tv.NAME = 'P_OUTCOME_ID'
                                      AND tv1.NAME = 'P_DATE_FROM'
                                      AND tv2.NAME(+) = 'P_DATE_TO'
                                      And tv.number_value = pco.outcome_id
                                      AND pco.competence_id = p_competence_id
            AND p_eff_date BETWEEN pco.date_from AND nvl(pco.date_to,p_eff_date)
                                      AND nvl(tv2.date_value,p_eff_date) < p_eff_date;
        IF l_noof_outcomes = 0 then
        RETURN 'ACHIEVED';
        ELSE
        RETURN 'IN_PROGRESS';
        END if;
     else
        RETURN 'IN_PROGRESS';
     END if;
ELSE
    Return 'ACHIEVED';
END if;
End Get_Competence_Status;


Function IsAllCompAchieved
     ( p_qualification_type_id IN number
     , p_person_id             IN number)
     RETURN VARCHAR2 IS
CURSOR getCompIds(p_qualification_type_id IN number) is
       SELECT pce.competence_id from
              per_competence_elements pce
       Where pce.TYPE = 'QUALIFICATION'
             AND pce.Qualification_type_id = p_qualification_type_id
             AND pce.effective_date_from <= trunc(sysdate)
             AND nvl(pce.effective_date_to,trunc(sysdate)) >= trunc(sysdate);
Cursor getCompEleId(p_competence_id IN number
                    , p_person_id   IN number) is
       Select competence_element_id from
              per_competence_elements pce
       Where pce.TYPE = 'PERSONAL'
             AND pce.competence_id = p_competence_id
             AND pce.person_id = p_person_id
             AND pce.effective_date_from <= trunc(sysdate)
             AND nvl(pce.effective_date_to,trunc(sysdate)) >= trunc(sysdate);
l_ret_val  varchar2(10);
l_NoOfCompAchieved   number;
l_TotComps  number;
l_comp_status varchar2(20);
Begin
l_ret_val := 'NOT';
l_NoOfCompAchieved := 0;
l_TotComps := 0;
Select count(*) INTO l_TotComps
       from
              per_competence_elements pce
       Where pce.TYPE = 'QUALIFICATION'
             AND pce.Qualification_type_id = p_qualification_type_id
             AND pce.effective_date_from <= trunc(sysdate)
             AND nvl(pce.effective_date_to,trunc(sysdate)) >= trunc(sysdate);
 IF l_TotComps = 0 then
    l_ret_val := 'ACHIEVED';
    RETURN l_ret_val;
 END if;
For CompIds IN getCompIds ( p_qualification_type_id => p_qualification_type_id)
loop
    FOR CompEled IN getCompEleId ( p_competence_id => CompIds.competence_id
                                  ,p_person_id => p_person_id)
    loop
        l_comp_status := Get_Competence_Status
                        (p_competence_id          => CompIds.Competence_id
                         ,p_competence_element_id => CompEled.competence_element_id
                         ,p_item_type    => null
                         ,p_item_key     => null
                         ,p_activity_id  => null
                         ,p_eff_date   => trunc(sysdate));
      IF  l_comp_status = 'ACHIEVED' then
          l_NoOfCompAchieved := l_NoOfCompAchieved +1;
      else
        RETURN l_ret_val;
      END if;
    END loop;
END loop;
If l_NoOfCompAchieved = l_TotComps Then
   l_ret_val := 'ACHIEVED';
End if;
Return l_ret_val;
End IsAllCompAchieved;
END PerCompStatus;

/
