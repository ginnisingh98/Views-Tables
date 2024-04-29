--------------------------------------------------------
--  DDL for Package Body PER_US_VISA_MIGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_US_VISA_MIGR" AS
/* $Header: peusvsmi.pkb 120.0 2005/05/31 22:45:57 appldev noship $ */
procedure convert_visa(p_bg_id number)
is
--
-- Local Variables
--
l_cnt number;
l_codes_len number;
l_comma_all number;
l_orig_pos number;
l_orig_num number;
l_new_start number;
l_new_end number;
l_new_num number;
l_new_code varchar2(20);
l_category varchar2(2);
--
l_counter number := 0;
l_person_id number := 0;
l_business_group_id number := 0;
l_full_name varchar2(240);
l_start_date date;
l_per_information4 varchar2(150);
--
l_orig_codes varchar2(300);
l_new_codes varchar2(300);
l_codes_left varchar2(300);
--
CURSOR per_visa_exists(cp_bgid number) IS
  SELECT DISTINCT full_name,
                  person_id,
                  start_date,
                  per_information4,
                  business_group_id
  FROM per_all_people_f
  WHERE per_information4 IS NOT NULL
  AND business_group_id = cp_bgid
  AND effective_end_date = to_date('4712/12/31','YYYY/MM/DD')
  ORDER BY full_name;
--

begin
  l_orig_codes := 'A1,A2,A3,ASLM,B1,B2,C1,C2,C3,' ||
                  'CPO,CPR,D1,E1,E2,F1,F2,G1,G2,G3,G4,' ||
                  'H1,H1B,H2A,H2B,H3,H4,H1B3,H1B4,H1B5,' ||
                  'I,K1,L1,L2,PR,M1,M2,N8,N9,NATO,' ||
                  'O1,O2,O3,P1,P2,P3,Q,Q1,R1,R2,RFGE,' ||
                  'SK1,SK2,SK3,TC,VWB,VWT,';
  l_new_codes  := 'A-1,A-2,A-3,ASLM,B-1,B-2,C-1,C-2,C-3,' ||
                  'CPO,CPR,D-1,E-1,E-2,F-1,F-2,G-1,G-2,G-3,G-4,' ||
                  'H-1A,H-1B,H-2A,H-2B,H-3,H-4,P-2,P-1,P-1,' ||
                  'I,K-1,L-1,L-2,LPR,M-1,M-2,N-8,N-9,NATO,' ||
                  'O-1,O-2,O-3,P-1,P-2,P-3,Q-1,*Q1,R-1,R-2,RFGE,' ||
                  'SK-1,SK-2,SK-3,TN,VW,VW,';
  --
  open per_visa_exists(p_bg_id);
  LOOP
    FETCH per_visa_exists INTO l_full_name,
                               l_person_id,
                               l_start_date,
                               l_per_information4,
                               l_business_group_id;
    IF per_visa_exists%NOTFOUND THEN
      EXIT;
    END IF;
    --
    -- J code processing
    --
    l_new_code := '';
    l_category := '';
    IF LENGTH(l_per_information4)>=2
       AND SUBSTR(l_per_information4,1,1) = 'J' THEN
       l_new_code := SUBSTR(l_per_information4,1,1) || '-' ||
                     SUBSTR(l_per_information4,2,1);
       IF LENGTH(l_per_information4) = 4 THEN
         l_category := SUBSTR(l_per_information4,3,2);
       END IF;
    END IF;
    --
    l_orig_pos := INSTR(l_orig_codes,RTRIM(l_per_information4),1);
    IF l_orig_pos > 0 THEN
      IF l_orig_pos = 1 THEN
        l_orig_num := 1;
      ELSE
        l_codes_left := SUBSTR(l_orig_codes,1,l_orig_pos-1);
        l_codes_len := LENGTH(l_codes_left);
        l_cnt := 1;
        l_comma_all := 0;
        WHILE l_cnt <= l_codes_len
        LOOP
          IF SUBSTR(l_orig_codes,l_cnt,1) = ',' THEN
            l_comma_all := l_comma_all + 1;
          END IF;
          l_cnt := l_cnt + 1;
        END LOOP;
        l_orig_num := l_comma_all + 1;
      END IF;
      --
      l_new_num := l_orig_num;
      l_new_code := '';
      --
      IF l_new_num = 1 THEN
        l_new_start := 1;
        l_new_end   := INSTR(l_new_codes,',',1,1) - 1;
      ELSE
        l_new_start := INSTR(l_new_codes,',',1,l_new_num-1) + 1;
        l_new_end   := INSTR(l_new_codes,',',1,l_new_num) - 1;
      END IF;
      --
      l_new_code := SUBSTR(l_new_codes,l_new_start,l_new_end-l_new_start+1);
      --
    END IF;
    --
    -- Insert statement here
    --
    IF l_new_code IS NOT NULL THEN
      INSERT INTO per_people_extra_info
      (person_extra_info_id,
       person_id,
       information_type,
       pei_information_category,
       pei_information5,
       pei_information9,
       object_version_number,
       last_update_date,
       creation_date)
       SELECT
        per_people_extra_info_s.nextval,
        l_person_id,
        'PER_US_VISA_DETAILS',
        'PER_US_VISA_DETAILS',
        l_new_code,
        l_category,
        1,
        sysdate,
        sysdate
       FROM sys.dual
       WHERE NOT EXISTS
       (SELECT 1
        FROM PER_PEOPLE_EXTRA_INFO
        WHERE person_id = l_person_id
          AND pei_information5 = l_new_code
          AND information_type = 'PER_US_VISA_DETAILS'
          AND pei_information_category = 'PER_US_VISA_DETAILS');
       l_counter := l_counter+1;
       if MOD(l_counter,50) = 0 then
          commit;
       end if;
     END IF;
  END LOOP;
  CLOSE per_visa_exists;
  COMMIT;
end convert_visa;
--
END PER_US_VISA_MIGR;

/
