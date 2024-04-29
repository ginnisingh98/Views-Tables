--------------------------------------------------------
--  DDL for Package Body PQP_CANDM_UPG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_CANDM_UPG" AS
/* $Header: pqpcnmupg.pkb 120.1.12010000.7 2009/07/30 09:52:35 nchinnam ship $ */
/*
   Copyright (c) Oracle Corporation 1991,1992,1993. All rights reserved
--
--

--
*/

function get_version(p_formula_text pay_shadow_formulas.formula_text%TYPE) RETURN VARCHAR2
as
  l_ver_start_idx INTEGER;
  l_ver_end_idx   INTEGER;
  l_version       VARCHAR2(100);

begin
      l_ver_start_idx:=INSTR(p_formula_text,'pqgbtcam.sql')+13;
      l_ver_end_idx:=INSTR(p_formula_text,' ',l_ver_start_idx);
      l_version:=substr(p_formula_text,l_ver_start_idx,l_ver_end_idx - l_ver_start_idx);
      return l_version;
end get_version;

function get_token (p_text varchar2,p_token_num number,p_delim varchar2 :='.')return varchar2
as
    l_start_pos number;
    l_end_pos number;
begin
    if p_token_num <= 0 then
       return null;
    end if;

    if p_token_num = 1 then
        l_start_pos := 1;
    else
        l_start_pos := instr(p_text, p_delim, 1, p_token_num - 1);
        if l_start_pos = 0 then
            return null;
        else
            l_start_pos := l_start_pos + length(p_delim);
        end if;
    end if;

    l_end_pos := instr(p_text, p_delim, l_start_pos, 1);
    if l_end_pos = 0 then
        return substr(p_text, l_start_pos);
    else
        return substr(p_text, l_start_pos, l_end_pos - l_start_pos);
    end if;
end get_token;

function version_compare(p_low_version VARCHAR2,p_high_version VARCHAR2) RETURN BOOLEAN
as
  l_count     INTEGER:=1;
  l_low_cur   VARCHAR2(100);
  l_high_cur  VARCHAR2(100);
  l_ret_value BOOLEAN;

begin

   LOOP
     l_low_cur:=get_token(p_low_version,l_count);
     l_high_cur:=get_token(p_high_version,l_count);
     if (l_low_cur is null) AND (l_high_cur is not null) then
        return true;
     elsif (l_low_cur is not null) AND (l_high_cur is null) then
        return true;
     elsif (l_low_cur is null) AND (l_high_cur is null) then
        return false;
     end if;

     if (to_number(l_low_cur) < to_number(l_high_cur)) then
        return true;
     elsif to_number(l_low_cur) > to_number(l_high_cur) then
        return false;
     end if;
     l_count:=l_count+1;
     if l_count > 100 then
        return false;
     END IF;
   END LOOP;

end version_compare;

procedure upgrade_formula (errbuf OUT NOCOPY VARCHAR2
                   ,retcode OUT NOCOPY NUMBER
                   ,p_formula_cat    IN VARCHAR2
                   ,p_formula_name   IN VARCHAR2
                   )
AS
 -- Get the shadow formula details
 CURSOR c_sh_formula_details IS
 SELECT formula_name
       ,formula_text
   FROM pay_shadow_formulas
  WHERE template_type='T'
    AND  formula_name like p_formula_cat;

-- Get the Actual formula details
 CURSOR c_formula_details IS
 SELECT fff.formula_id
       ,fff.effective_start_date
       ,fff.effective_end_date
       ,fff.formula_type_id
       ,fff.formula_name
       ,fff.business_group_id
       ,fff.description
       ,fff.sticky_flag
       ,fff.compile_flag
       ,paf.status_processing_rule_id status_processing_rule_id
       ,fff.formula_text
       ,fff.legislation_code
  FROM ff_formulas_f fff
       ,PAY_STATUS_PROCESSING_RULES_F  paf
  WHERE fff.formula_name like NVL(p_formula_name,p_formula_cat)
  AND fff.formula_id=paf.formula_id
  AND paf.assignment_status_type_id IS NULL
  AND fff.business_group_id=paf.business_group_id
  AND fff.business_group_id=fnd_global.per_business_group_id
  AND SYSDATE BETWEEN fff.effective_start_date and fff.effective_end_date
    ORDER BY fff.formula_id,fff.effective_start_date ;


l_sh_formula_name       pay_shadow_formulas.formula_name%TYPE;
l_sh_formula_text       pay_shadow_formulas.formula_text%TYPE;
l_sh_formula_ver        VARCHAR2(50);

l_formula               c_formula_details%ROWTYPE;
l_formula_ver           VARCHAR2(50);
l_formula_prefix        VARCHAR2(50);
l_formula_text_buffer   ff_formulas_f.formula_text%TYPE;

l_year                  VARCHAR2(30);


BEGIN

   fnd_file.put_line(fnd_file.log,'p_formula_cat:'||p_formula_cat);
   fnd_file.put_line(fnd_file.log,'p_formula_name:'||p_formula_name);


   OPEN c_sh_formula_details;
   LOOP
      FETCH c_sh_formula_details INTO l_sh_formula_name,l_sh_formula_text;
      EXIT WHEN c_sh_formula_details%NOTFOUND;
      --l_sh_formula_ver:=substr(l_sh_formula_text,INSTR(l_sh_formula_text,'pqgbtcam.sql')+13,6);
      l_sh_formula_ver:=get_version(l_sh_formula_text);
   END LOOP;
   CLOSE c_sh_formula_details;

   fnd_file.put_line(fnd_file.log,'Shadow Formula Ver:'||l_sh_formula_ver);

   OPEN c_formula_details;
   LOOP
      FETCH c_formula_details INTO l_formula;
      EXIT WHEN c_formula_details%NOTFOUND;
      l_formula_prefix := substr(l_formula.formula_name,0,INSTR(l_formula.formula_name,substr(p_formula_cat,2))-1);
      --l_formula_ver := substr(l_formula.formula_text,INSTR(l_formula.formula_text,'pqgbtcam.sql')+13,6);
      l_formula_ver := get_version(l_formula.formula_text);

      fnd_file.put_line(fnd_file.log,'Formula Prefix:'||l_formula_prefix);
      fnd_file.put_line(fnd_file.log,'Formula Ver:'||l_formula_ver);

      IF version_compare(l_formula_ver,l_sh_formula_ver) THEN
         fnd_file.put_line(fnd_file.log,'Upgrading Formula:'||l_formula.formula_name);
         l_formula_text_buffer := replace(l_sh_formula_text,'<BASE NAME>',UPPER(REPLACE(l_formula_prefix,' ','_')));

         SELECT TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')
           INTO l_year
           FROM DUAL;

         UPDATE ff_formulas_f
            SET formula_name = l_formula.formula_name||'_'||l_year||'_BAK'
          WHERE formula_id = l_formula.formula_id;

         UPDATE ff_formulas_f_tl
            SET formula_name = l_formula.formula_name||'_'||l_year||'_BAK'
          WHERE formula_id = l_formula.formula_id;

         INSERT INTO ff_formulas_f(
                                  FORMULA_ID
                                 ,EFFECTIVE_START_DATE
                                 ,EFFECTIVE_END_DATE
                                 ,BUSINESS_GROUP_ID
                                 ,LEGISLATION_CODE
                                 ,FORMULA_TYPE_ID
                                 ,FORMULA_NAME
                                 ,DESCRIPTION
                                 ,FORMULA_TEXT
                                 ,STICKY_FLAG
                                 ,COMPILE_FLAG
                                 ,LAST_UPDATE_DATE
                                 ,LAST_UPDATED_BY
                                 ,LAST_UPDATE_LOGIN
                                 ,CREATED_BY
                                 ,CREATION_DATE )
                          VALUES(
                                   ff_formulas_s.nextval
                                  ,l_formula.EFFECTIVE_START_DATE
                                  ,l_formula.EFFECTIVE_end_DATE
                                  ,l_formula.business_group_id
                                  ,l_formula.legislation_code
                                  ,l_formula.formula_type_id
                                  ,l_formula.formula_name
                                  ,l_formula.description
                                  ,l_formula_text_buffer
                                  ,l_formula.sticky_flag
                                  ,l_formula.compile_flag
                                  ,sysdate
                                  ,1
                                  ,1
                                  ,1
                                  ,sysdate
                                );

         UPDATE pay_status_processing_rules_f
            SET formula_id=ff_formulas_s.currval
          WHERE status_processing_rule_id=l_formula.status_processing_rule_id
          AND SYSDATE BETWEEN effective_start_date and effective_end_date;

         fnd_file.put_line(fnd_file.output,'The Fast Formula '||l_formula.formula_name||' is successfully upgraded');
         fnd_file.put_line(fnd_file.output,'and the backup of old formula is in ' || l_formula.formula_name||'_'||l_year||'_BAK');
         retcode:=0;

      ELSE
        fnd_file.put_line(fnd_file.output,'Latest version of the formula '||l_formula.formula_name||' already exists.');
        retcode:=1;

      END IF;
   END LOOP;
   CLOSE c_formula_details;

EXCEPTION
   WHEN OTHERS THEN
       fnd_file.put_line(fnd_file.output,'Formula Upgrade Failed');
       fnd_file.put_line(fnd_file.log,substr(SQLERRM,1,200));
       errbuf:='Formula Upgrade Failed';
       retcode:=2;
END UPGRADE_FORMULA;


end PQP_CANDM_UPG;

/
