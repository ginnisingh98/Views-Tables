--------------------------------------------------------
--  DDL for Package Body CN_SFP_ROLE_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SFP_ROLE_UTIL_PVT" AS
-- $Header: cnsfrolb.pls 115.2 2003/01/09 03:03:09 sbadami noship $
-- declare global variables...
G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_SFP_ROLE_UTIL_PVT';


FUNCTION is_org_valid_role
(
  p_role_id IN NUMBER
) RETURN VARCHAR2
IS
  l_rate_sch_id NUMBER;
  l_seas_id NUMBER;
  l_calc_formula_id NUMBER;
  l_org_id NUMBER;
  l_rate_sch_pass VARCHAR2(1) := 'Y';
  l_formula_pass VARCHAR2(1) := 'Y';
  l_seas_pass VARCHAR2(1) := 'Y';

  l_total_traversed VARCHAR2(1) := 'Y';

  l_return VARCHAR2(1) := 'Y';
  l_temp_org  NUMBER;

  CURSOR role_quota_cate_cur IS
  SELECT rqc.ROLE_ID,rqc.QUOTA_CATEGORY_ID,rqc.RATE_SCHEDULE_ID,rqc.CALC_FORMULA_ID,
         rqc.SEAS_SCHEDULE_ID FROM CN_ROLE_QUOTA_CATES rqc WHERE ROLE_ID = p_role_id;
BEGIN

  l_org_id := fnd_profile.value('ORG_ID');

  FOR eachq IN role_quota_cate_cur LOOP
     l_rate_sch_id     :=eachq.RATE_SCHEDULE_ID;
     l_calc_formula_id := eachq.calc_formula_id;
     l_seas_id         := eachq.SEAS_SCHEDULE_ID;

     -- Start doing the cheque for Rate Schedules
     IF l_rate_sch_id IS NOT NULL THEN
     	SELECT NVL(ORG_ID,-99) INTO l_temp_org FROM CN_RATE_SCHEDULES_ALL WHERE rate_schedule_id = l_rate_sch_id;
     	IF l_temp_org <> l_org_id THEN
     	   l_rate_sch_pass := 'N';
     	   EXIT;
     	END IF;
     END IF;

     IF l_calc_formula_id IS NOT NULL THEN
     	SELECT NVL(ORG_ID,-99) INTO l_temp_org FROM CN_CALC_FORMULAS_ALL WHERE CALC_FORMULA_ID = l_calc_formula_id and org_id = l_org_id;
     	IF l_temp_org <> l_org_id THEN
     	   l_formula_pass := 'N';
     	   EXIT;
     	END IF;
     END IF;

     IF l_seas_id IS NOT NULL THEN
     	SELECT NVL(ORG_ID,-99) INTO l_temp_org FROM CN_SEAS_SCHEDULES_ALL WHERE SEAS_SCHEDULE_ID = l_seas_id;
     	IF l_temp_org <> l_org_id THEN
     	   l_seas_pass := 'N';
     	   EXIT;
     	END IF;
     END IF;

  END LOOP;

  IF l_total_traversed = 'N' THEN
    NULL;
  END IF;

  IF (l_rate_sch_pass = 'Y' AND l_formula_pass = 'Y' AND l_seas_pass = 'Y') THEN
     l_return := 'Y';
  ELSE
     l_return := 'N';
  END IF;

 return l_return;
 EXCEPTION
      WHEN OTHERS THEN
        RAISE;
END;

-- Validating a give Role Quota Cate for the rates from ADMIN Tables.

FUNCTION validate_roleqc_for_rates
(
  p_role_quota_cate_id IN NUMBER
) RETURN VARCHAR2
IS
l_return VARCHAR2(1) := 'Y';
l_rate_schedule_id NUMBER;

CURSOR role_quota_rate_cur IS
  select nvl(attribute1,-1) rate_tier_id ,rate_tier_id rate_sequence from cn_role_quota_rates
  where role_quota_cate_id = p_role_quota_cate_id;


l_role_qc_cur role_quota_rate_cur%ROWTYPE;
l_count_rate_tiers NUMBER := 0;
BEGIN
  -- Get Rate Schedule ID for the given role quota cate
  BEGIN
  	select NVL(rate_schedule_id,-1) into l_rate_schedule_id
  	from cn_role_quota_cates where role_quota_cate_id = p_role_quota_cate_id;
  EXCEPTION
        WHEN OTHERS THEN
        l_rate_schedule_id := -1;
  END;

  -- If there is no rate schedule id for the given role quota
  -- cate you can return success.
  IF (l_rate_schedule_id > 0) THEN
    -- Identify the rate_tier_id and sequence and compare against
    -- CN_RATE_TIERS for the changes
    FOR eachq IN role_quota_rate_cur LOOP
  	l_role_qc_cur.rate_tier_id  := eachq.rate_tier_id;
  	l_role_qc_cur.rate_sequence := eachq.rate_sequence;

  	IF (l_role_qc_cur.rate_tier_id > 0) THEN
  	    select count(*) INTO l_count_rate_tiers from cn_rate_tiers
  	    where rate_tier_id = l_role_qc_cur.rate_tier_id
  	    and rate_sequence = l_role_qc_cur.rate_sequence;

  	    -- If the tiers don't match to 1 no need to check further.
  	    IF ((l_count_rate_tiers < 1) OR (l_count_rate_tiers > 1))THEN
  	       l_return := 'N';
  	       EXIT;
  	    END IF;
  	END IF;
  	l_count_rate_tiers := 0;
    END LOOP;
  END IF;

  return l_return;
EXCEPTION
      WHEN OTHERS THEN
        RAISE;
END;

END CN_SFP_ROLE_UTIL_PVT;

/
