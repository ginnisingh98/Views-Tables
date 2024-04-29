--------------------------------------------------------
--  DDL for Package Body PAY_ES_RUN_TYPES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ES_RUN_TYPES" AS
/* $Header: pyesrunt.pkb 120.0 2005/05/29 04:38:50 appldev noship $ */

l_index                 NUMBER := 0;
l_prod_flag             BOOLEAN := True;
l_user_flag             BOOLEAN := True;
--------------------------------------------------------------------------------
-- rebuild_run_types
--------------------------------------------------------------------------------
PROCEDURE rebuild_run_types(errbuf  out nocopy  VARCHAR2
                           ,retcode out nocopy  VARCHAR2
                           ,p_business_group_id VARCHAR2)
IS

--
    Cursor csr_element_all(c_business_group_id number) IS
    SELECT  pet.element_type_id
           ,pet.element_name
           ,pet.business_group_id
           ,pet.legislation_code
           ,pet.indirect_only_flag
           ,MIN(pet.effective_start_date) effective_date
    FROM    pay_element_types_f pet
           ,per_business_groups pbg
    WHERE   Nvl(pet.indirect_only_flag, 'N') = 'N'
    AND     pet.business_group_id = c_business_group_id
    AND     pbg.business_group_id = pet.business_group_id
    AND     pbg.legislation_code = 'ES'
    AND     pet.legislation_code IS NULL
    GROUP BY pet.element_type_id
            ,pet.element_name
            ,pet.business_group_id
            ,pet.legislation_code
            ,pet.indirect_only_flag;
    --
    l_element_rec  csr_element_all%ROWTYPE;
    l_effective_start_date DATE;
    l_effective_end_date   DATE;
    l_header VARCHAR2(500);
    l_underline VARCHAR2(500);
    l_business_group_id NUMBER;
    --
Begin
    hr_utility.trace('Entering pay_es_run_types.rebuild_run_types ');
    --
    l_business_group_id := fnd_number.canonical_to_number(p_business_group_id);
    --
    l_header :=   rpad(hr_general.decode_lookup('ES_FORM_LABELS','ELE_NAME'),60)||'  '||
                  rpad(hr_general.decode_lookup('ES_FORM_LABELS','ELE_CLASS'),60)||'  '||
                  rpad(hr_general.decode_lookup('ES_FORM_LABELS','RUN_TYPE'),30)||'  '||
                  rpad(hr_general.decode_lookup('ES_FORM_LABELS','STATUS'),20);
    --
    l_underline :=rpad('-',60,'-')||'  '||
                  rpad('-',60,'-')||'  '||
                  rpad('-',30,'-')||'  '||
                  rpad('-',20,'-');
    Fnd_File.New_Line(FND_FILE.LOG,1);
    Fnd_file.put_line(FND_FILE.LOG,hr_general.decode_lookup('ES_FORM_LABELS','RRT'));
    Fnd_File.New_Line(FND_FILE.LOG,1);
    Fnd_file.put_line(FND_FILE.LOG,l_underline);
    Fnd_file.put_line(FND_FILE.LOG,l_header);
    Fnd_file.put_line(FND_FILE.LOG,l_underline);

    FOR l_element_rec IN csr_element_all(l_business_group_id) LOOP
        hr_utility.set_location('Creating run type usage For Element '||l_element_rec.element_name,20);
        IF l_element_rec.indirect_only_flag = 'N' THEN
        --
            create_element_run_type_usages(p_effective_date  => l_element_rec.effective_date
                                          ,p_element_name    => l_element_rec.element_name
                                          ,p_element_type_id => l_element_rec.element_type_id
                                          ,p_legislation_code=> l_element_rec.legislation_code
                                          ,p_business_gr_id  => l_element_rec.business_group_id);
        END IF;
    END LOOP;
    hr_utility.trace('Leaving pay_es_run_types.rebuild_run_types ');
    --
END rebuild_run_types;
--------------------------------------------------------------------------------
-- create_element_run_type_usages
--------------------------------------------------------------------------------
PROCEDURE create_element_run_type_usages(p_effective_date      IN  DATE
                                        ,p_element_name        IN  VARCHAR2
                                        ,p_element_type_id     IN  NUMBER
                                        ,p_legislation_code    IN  VARCHAR2
                                        ,p_business_gr_id      IN  NUMBER)
IS
    l_element_type_usage_id	NUMBER;
    l_object_version_number	NUMBER;
    l_effective_start_date 	DATE;
    l_effective_end_date   	DATE;
    l_flag VARCHAR2(1);
    l_print_element_info varchar2(2000);
    --
    CURSOR get_run_types(c_element_type_id NUMBER) IS
    SELECT prt.run_type_id
          ,prt.shortname
    FROM   pay_run_types_f prt
    WHERE  legislation_code = 'ES'
    AND    prt.shortname = 'TAX_WITHHOLDING_RATE'
    AND    p_effective_date between effective_start_date and effective_end_date
    AND    NOT EXISTS (SELECT /*+ ORDERED */ NULL
                       FROM  pay_element_type_usages_f petu
                       WHERE petu.RUN_TYPE_ID = prt.RUN_TYPE_ID
                       AND   petu.ELEMENT_TYPE_ID = p_ELEMENT_TYPE_ID
                       AND   p_effective_date between petu.effective_start_date and petu.effective_end_date);

    CURSOR csr_get_element_print_info(c_element_type_id NUMBER
                                     ,c_effective_date  DATE     ) IS
    SELECT petl.element_name element_name
          ,pecl.classification_name classification_name
    FROM   pay_element_types_f pet
          ,pay_element_types_f_tl petl
          ,pay_element_classifications_tl pecl
    WHERE  pet.element_type_id = c_element_type_id
    AND    pet.element_type_id = petl.element_type_id
    AND    petl.language       = USERENV('LANG')
    AND    pet.classification_id = pecl.classification_id
    AND    c_effective_date BETWEEN pet.effective_start_date and pet.effective_end_date;

    CURSOR csr_get_run_type_print_info(c_run_type_id NUMBER) IS
    SELECT prt.run_type_name run_type_name
    FROM   pay_run_types_f_tl prt
    WHERE  prt.run_type_id = c_run_type_id
    AND    prt.language       = USERENV('LANG');

    l_usage_exist varchar2(1);
    l_element_info  csr_get_element_print_info%ROWTYPE;
    l_runtype_info  csr_get_run_type_print_info%ROWTYPE;
BEGIN
    --
    IF p_legislation_code IS NULL THEN
        hr_startup_data_api_support.enable_startup_mode('USER');
    END IF;
    --
    FOR i IN get_run_types(p_element_type_id) LOOP
    --
        pay_element_type_usage_api.create_element_type_usage(
                 p_validate                      => FALSE
                ,p_effective_date                => p_effective_date
                ,p_run_type_id                   => i.run_type_id
                ,p_element_type_id               => p_element_type_id
                ,p_legislation_code              => p_legislation_code
                ,p_business_group_id             => p_business_gr_id
                ,p_element_type_usage_id         => l_element_type_usage_id
                ,p_object_version_number         => l_object_version_number
                ,p_effective_start_date          => l_effective_start_date
                ,p_effective_end_date            => l_effective_end_date);
        l_index := l_index + 1;

        OPEN csr_get_element_print_info(p_element_type_id, p_effective_date);
        FETCH csr_get_element_print_info into l_element_info;
        CLOSE csr_get_element_print_info;

        OPEN csr_get_run_type_print_info(i.run_type_id);
        FETCH csr_get_run_type_print_info into l_runtype_info;
        CLOSE csr_get_run_type_print_info;

        l_print_element_info:=  rpad(nvl(l_element_info.element_name,' '),60)||'  '||
        rpad(nvl(l_element_info.classification_name,' '),60)||'  '||
        rpad(nvl(l_runtype_info.run_type_name,' '),30)||'  '||
        rpad(hr_general.decode_lookup('ES_FORM_LABELS','EXCLUDE'),20);

        Fnd_file.put_line(FND_FILE.LOG,l_print_element_info);
    END LOOP;
END create_element_run_type_usages;
--
End pay_es_run_types;

/
