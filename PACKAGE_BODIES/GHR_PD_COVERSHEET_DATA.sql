--------------------------------------------------------
--  DDL for Package Body GHR_PD_COVERSHEET_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PD_COVERSHEET_DATA" AS
/* $Header: ghrwspdc.pkb 120.0.12010000.2 2009/05/26 10:56:01 vmididho noship $ */

FUNCTION
get_fr_position_group(p_position_id IN number,
		p_info_type   IN varchar2,
		p_info_number IN number)
RETURN VARCHAR2
IS

 CURSOR c_get_position_group
 IS

    SELECT DECODE(p_info_number,
                  3,poei_information3,
                  5,poei_information5,
                  12,poei_information12)
    FROM  per_position_extra_info
    WHERE  information_type = p_info_type
    AND    position_id = p_position_id;

   l_position_group per_position_extra_info.poei_information1%TYPE;

BEGIN

   OPEN c_get_position_group;
   FETCH c_get_position_group INTO l_position_group;
   IF c_get_position_group%NOTFOUND THEN
      l_position_group := NULL;
   END IF;
   CLOSE c_get_position_group;

  RETURN l_position_group;

END;


FUNCTION
get_gen_emp(p_pa_req_id IN number,
        	p_info_number IN number)
RETURN VARCHAR2
IS

   CURSOR c_pdi_gen_emp
   IS
	SELECT decode(p_info_number,
                      3,rei_information3,
                      4,rei_information4,
                      5,rei_information5,
                      6,rei_information6)
		FROM   ghr_pa_request_extra_info
		WHERE  information_type = 'GHR_US_PD_GEN_EMP'
		AND    pa_request_id = p_pa_req_id;

   	l_gen_emp_return per_position_extra_info.poei_information1%TYPE;
BEGIN

        OPEN c_pdi_gen_emp;
        FETCH c_pdi_gen_emp INTO l_gen_emp_return;
        IF c_pdi_gen_emp%NOTFOUND THEN
           l_gen_emp_return := null;
        END IF;
        CLOSE c_pdi_gen_emp;
	RETURN l_gen_emp_return;
END;


FUNCTION get_pay_plan(p_lookup_cd IN VARCHAR2)
RETURN VARCHAR2
IS
     l_pay_plan     VARCHAR2(80);
  CURSOR c_pay_plan
  IS
     SELECT description
     FROM   GHR_PAY_PLANS
     WHERE  pay_plan = p_lookup_cd;

BEGIN
     OPEN c_pay_plan;
     FETCH c_pay_plan INTO l_pay_plan;
     IF c_pay_plan%NOTFOUND THEN
        l_pay_plan := null;
     END IF;

     RETURN l_pay_plan;
END;

FUNCTION flexfield( p_position_id IN NUMBER, p_structure IN VARCHAR2, p_segment IN VARCHAR2)
RETURN VARCHAR2
IS

    CURSOR GET_SEGMENT(p_position_id NUMBER, p_structure VARCHAR2, p_segment VARCHAR2) IS
    SELECT
            DECODE(flex_seg.SEGMENT_NUM,
                    1, ppd.SEGMENT1, 2,ppd.SEGMENT2, 3, ppd.SEGMENT3,
                    4,ppd.SEGMENT4, 5,ppd.SEGMENT5,6,ppd.SEGMENT6,
                    7, ppd.SEGMENT7,
                    8,ppd.SEGMENT8, 9,ppd.SEGMENT9,10,ppd.SEGMENT10,
                    11, ppd.SEGMENT11,
                    12,ppd.SEGMENT12, 13,ppd.SEGMENT13,14,ppd.SEGMENT14,                            15, ppd.SEGMENT15,
                    16,ppd.SEGMENT16, 17,ppd.SEGMENT17,18,ppd.SEGMENT18,                            19, ppd.SEGMENT19,
                    20,ppd.SEGMENT20, 21,ppd.SEGMENT21,22,ppd.SEGMENT22,
                    23, ppd.SEGMENT23,
                    24,ppd.SEGMENT24, 25,ppd.SEGMENT25,26,ppd.SEGMENT26,                            27, ppd.SEGMENT27,
                    28,ppd.SEGMENT28, 29,ppd.SEGMENT29,30,ppd.SEGMENT30)
    FROM
            PER_POSITION_DEFINITIONS PPD,
            FND_ID_FLEX_STRUCTURES_TL flex_struct ,
            FND_ID_FLEX_SEGMENTS  flex_seg,
		PER_POSITIONS pos
    WHERE   pos.POSITION_ID 		    = p_position_id
      AND   ppd.POSITION_DEFINITION_ID    = pos.POSITION_DEFINITION_ID
      AND   ppd.enabled_FLAG = 'Y'
      AND   NVL(ppd.START_DATE_ACTIVE,sysdate) <= sysdate
      AND  (ppd.END_DATE_ACTIVE IS NULL
           OR ppd.END_DATE_ACTIVE > sysdate)
      AND   flex_struct.ID_FLEX_NUM          = PPD.ID_FLEX_NUM
      AND   flex_struct.ID_FLEX_STRUCTURE_NAME = p_structure
      AND   flex_struct.LANGUAGE	     = 'US'
      AND   flex_seg.ID_FLEX_NUM           = flex_struct.ID_FLEX_NUM
      AND   flex_seg.ID_FLEX_CODE          = flex_struct.ID_FLEX_CODE
      AND   flex_seg.SEGMENT_NAME          = p_segment;

    l_flexfield     VARCHAR2(30);

    BEGIN
            OPEN GET_SEGMENT(p_position_id, p_structure,p_segment );
            FETCH  GET_SEGMENT INTO l_flexfield;
           	IF GET_SEGMENT%NOTFOUND THEN
              l_flexfield := NULL;
            END IF;
		CLOSE GET_SEGMENT;
            RETURN l_flexfield;
    END;
END ghr_pd_coversheet_data;

/
