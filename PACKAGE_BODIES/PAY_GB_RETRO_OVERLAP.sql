--------------------------------------------------------
--  DDL for Package Body PAY_GB_RETRO_OVERLAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GB_RETRO_OVERLAP" 
--  /* $Header: pygbenro.pkb 120.1 2007/08/29 10:35:16 rlingama noship $ */
AS
gv_package_name       VARCHAR2(100);

-- This procedure is used to Enable Retro Overlap functionality
-- ----------------------------------------------------------------------------
-- |-------------------------< enable_retro_overlap >--------------------------|
-- ----------------------------------------------------------------------------
 PROCEDURE enable_retro_overlap( errbuf      OUT NOCOPY varchar2
                                ,retcode     OUT NOCOPY varchar2
 )
 IS

-- Cursor to fetch legislation rule mode
   CURSOR c_retro_rule_check( cp_rule_type IN varchar2
                             ,cp_legislation_code IN Varchar2)
   IS
     SELECT rule_mode
       FROM pay_legislation_rules
      WHERE legislation_code = cp_legislation_code
        AND rule_type = cp_rule_type;

--  Cursor to fetch upgrade definition id of Enhanced Retropay
    CURSOR c_upgrade_definitions( cp_short_name IN varchar2
                                 ,cp_legislation_code IN Varchar2)
    IS
     SELECT upgrade_definition_id
       FROM pay_upgrade_definitions
      WHERE legislation_code = cp_legislation_code
        AND short_name=cp_short_name;

--  Cursor to fetch the status of Enhanced Retropay
    CURSOR c_upgrade_status( cp_upgrade_defINation_id IN varchar2
                            ,cp_legISlation_code IN Varchar2)
    IS
     SELECT status
       FROM pay_upgrade_status
      WHERE legislation_code = cp_legislation_code
        AND upgrade_definition_id = cp_upgrade_defination_id;
   --

   lv_qualified             VARCHAR2(1);
   lv_procedure_name        VARCHAR2(100);
   lv_legislation_code      VARCHAR2(150);
   lv_short_name            VARCHAR2(100);
   lv_upgrade_defination_id NUMBER;
   ln_exists                VARCHAR2(1);
   lv_upgrade_status        VARCHAR2(1);

   TYPE character_data_table IS TABLE OF VARCHAR2(280)
      INDEX BY BINARY_INTEGER;
   ltt_rule_type            character_data_table;
   ltt_rule_mode            character_data_table;

 BEGIN

   lv_procedure_name := '.enable_retro_overlap';
   fnd_file.put_line(fnd_file.log,'Entering ' || gv_package_name || lv_procedure_name);
   lv_legislation_code := 'GB';

-- These are the legislation rules to check whether Enhanced Retropay is enabled or not
   ltt_rule_type(1) := 'RETRO_DELETE';
   ltt_rule_mode(1) := 'N';
   ltt_rule_type(2) := 'ADVANCED_RETRO';
   ltt_rule_mode(2) := 'Y';

-- Legislation rules for enabling Retro Overlap
   ltt_rule_type(3) := 'RETRO_OVERLAP';
   ltt_rule_mode(3) := 'N';

-- Checking whether Enhanced Retropay is enabled or not
   FOR i in 1 ..2 LOOP
    OPEN c_retro_rule_check(ltt_rule_type(i),lv_legislation_code) ;
    FETCH c_retro_rule_check into ln_exists;

        IF (c_retro_rule_check%FOUND) AND (ltt_rule_mode(i) = ln_exists )
        THEN
            lv_qualified := 'Y';
        ELSE
            lv_qualified := 'N';
            fnd_file.put_line(fnd_file.log,'Retro Overlap upgrade not performed when '||ltt_rule_type(i)||' legislation rule is not set to '||ltt_rule_mode(i));
            fnd_file.put_line(fnd_file.log,'Enhanced RetroPay is not enabled');
            exit;
        END IF;

    CLOSE c_retro_rule_check;
   END LOOP;

    IF lv_qualified = 'Y'
    THEN
        lv_short_name := 'GB_ENHANCED_RETROPAY';
        OPEN c_upgrade_definitions(lv_short_name,lv_legislation_code);
        FETCH c_upgrade_definitions into lv_upgrade_defination_id;

        -- Checking whether Enhanced Retropay entire is found in the table  pay_upgrade_definitions or not
        IF(c_upgrade_definitions%FOUND)
        THEN
            lv_upgrade_status  := 'C';
            OPEN c_upgrade_status(lv_upgrade_defination_id,lv_legislation_code);
            FETCH c_upgrade_status into ln_exists;

            -- Checking the status of Enhanced Retro pay
                IF(c_upgrade_status%FOUND) AND lv_upgrade_status = ln_exists
                THEN
                    OPEN c_retro_rule_check(ltt_rule_type(3),lv_legislation_code);
                    FETCH c_retro_rule_check into ln_exists;

                    -- Checking whether Retro Overlap is Enabled or not
                    IF c_retro_rule_check%FOUND
                    THEN
                        IF (ltt_rule_mode(3)= ln_exists)
                        THEN
                            fnd_file.put_line(fnd_file.log,'Retro Overlap is already Enabled');
                        ELSE
                            -- Updating Rero Ovelap rule mode to N
                            UPDATE  pay_legislation_rules
                            SET     RULE_MODE = ltt_rule_mode(3)
                            WHERE   legislation_code = lv_legislation_code
                            AND     rule_type =  ltt_rule_type(3);
                            fnd_file.put_line(fnd_file.log,'Retro Overlap Enabled successfully');
                        END IF;

                    ELSE
                        --If Retro Overlap is not enabled inserting new legislation rule
                        INSERT INTO pay_legislation_rules(legislation_code,rule_type,rule_mode)
                        VALUES( lv_legislation_code,ltt_rule_type(3),ltt_rule_mode(3));
                        fnd_file.put_line(fnd_file.log,'Retro Overlap Enabled successfully');
                    END IF;

                    CLOSE c_retro_rule_check;
                ElSE
                    fnd_file.put_line(fnd_file.log,'The status of Enhanced RetroPay must be C in pay_upgrade_status table');
                END IF;
            CLOSE c_upgrade_status;
        ELSE
            fnd_file.put_line(fnd_file.log,'There is no entrie found in pay_upgrade_definitions table for Enhanced RetroPay');
        END IF;
     CLOSE c_upgrade_definitions;
    END IF;

   fnd_file.put_line(fnd_file.log,'Leaving ' || gv_package_name || lv_procedure_name);

   EXCEPTION
     WHEN others
     THEN
       fnd_file.put_line(fnd_file.log,gv_package_name || lv_procedure_name);
       fnd_file.put_line(fnd_file.log,'ERROR:' || sqlcode ||'-'|| substr(sqlerrm,1,80));
       RAISE;
 END enable_retro_overlap;

BEGIN
 gv_package_name := 'pay_gb_retro_overlap';
END pay_gb_retro_overlap;

/
