--------------------------------------------------------
--  DDL for Package Body PAY_IP_STARTUP_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IP_STARTUP_UTIL" AS
 /* $Header: pyintstu.pkb 120.3 2006/01/10 03:20:36 sspratur noship $ */

-- ---------------------------------------------------------------------
-- Procedure to write Output and Log files. It can handle up to two
-- tokens.
-- ---------------------------------------------------------------------

g_logging VARCHAR2(1) := 'N';
g_start_of_time CONSTANT DATE := TO_DATE('01/01/0001','DD/MM/YYYY');

FUNCTION logging(p_action_parameter_group_id NUMBER) RETURN VARCHAR2 IS
  CURSOR csr_logging IS
    SELECT *
    FROM   pay_action_parameters
    WHERE  parameter_name = 'LOGGING';
  l_rec csr_logging%ROWTYPE;
BEGIN
  pay_core_utils.set_pap_group_id(p_action_parameter_group_id);
  OPEN  csr_logging;
  FETCH csr_logging INTO l_rec;
  IF csr_logging%NOTFOUND THEN
    CLOSE csr_logging;
    RETURN 'N';
  ELSE
    CLOSE csr_logging;
    RETURN 'Y';
  END IF;
END logging;

-- -------------------------------------------------------------
-- This
PROCEDURE write_log
	(p_file_type	VARCHAR2,
	 p_message	VARCHAR2,
	 p_token1	VARCHAR2,
	 p_token2	VARCHAR2) IS

BEGIN
hr_utility.set_location('pay_ip_startup_util.write_log',10);
IF p_message  IS NOT NULL THEN
  fnd_message.set_name('PAY', p_message);

  IF p_token1 IS NOT NULL THEN
    fnd_message.set_token('1', p_token1);
  END IF;

  IF p_token2 IS NOT NULL THEN
     fnd_message.set_token('2', p_token2);
  END IF;
  IF p_file_type ='LOG' and g_logging = 'Y' THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);
  ELSIF p_file_type ='OUTPUT' THEN
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.GET);
  ELSE
   NULL;
  END IF;
ELSE
  IF p_file_type ='LOG' AND g_logging = 'Y' THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, '');
  ELSIF p_file_type ='OUTPUT' THEN
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
  ELSE
  NULL;
  END IF;
END IF;
hr_utility.set_location('pay_ip_startup_util.write_log',20);
END;

-- ----------------------------------------------------------------
-- Procedure to write into output file.
-- ----------------------------------------------------------------

PROCEDURE write_out  IS

CURSOR get_element_class_csr IS
  SELECT distinct classification_id, legislation_code, classification_name
  FROM hr_s_element_classifications pec
      ,hr_s_application_ownerships ao
      ,fnd_product_installations b
      ,fnd_application c
  WHERE nvl(legislation_code,'X') = 'ZZ'
  AND 	ao.key_name             = 'CLASSIFICATION_ID'
  AND  	TO_NUMBER(ao.key_value) = pec.classification_id
  AND   ao.product_name = c.application_short_name
  AND   c.application_id = b.application_id
  AND   ((b.status = 'I' AND c.application_short_name <> 'PQP')
            OR
        (b.status in ('I', 'S') AND c.application_short_name = 'PQP'));

CURSOR get_balance_type_csr IS
 SELECT distinct balance_type_id, currency_code, balance_name
 FROM hr_s_balance_types         pbt
     ,hr_s_application_ownerships ao
     ,fnd_product_installations b
     ,fnd_application c
 WHERE  pbt.legislation_code     = 'ZZ'
 AND  ao.key_name             = 'BALANCE_TYPE_ID'
 AND  TO_NUMBER(ao.key_value) = pbt.balance_type_id
 AND  ao.product_name = c.application_short_name
 AND  c.application_id = b.application_id
 AND  ((b.status = 'I' AND c.application_short_name <> 'PQP')
           OR
       (b.status in ('I', 'S') AND c.application_short_name = 'PQP'));

CURSOR get_defined_balances_csr IS
 SELECT distinct defined_balance_id, pbt.balance_name bname
 FROM hr_s_defined_balances pdb
     ,hr_s_balance_types  pbt
     ,hr_s_application_ownerships ao
     ,fnd_product_installations b
     ,fnd_application c
 WHERE  pdb.legislation_code  ='ZZ'
 AND  ao.key_name             = 'DEFINED_BALANCE_ID'
 AND  pbt.balance_type_id     = pdb.balance_type_id
 AND  TO_NUMBER(ao.key_value) = pdb.defined_balance_id
 AND  ao.product_name = c.application_short_name
 AND  c.application_id = b.application_id
 AND  ((b.status = 'I' AND c.application_short_name <> 'PQP')
          OR
      (b.status in ('I', 'S') AND c.application_short_name = 'PQP'));

CURSOR get_balance_dimensions_csr IS
 SELECT distinct balance_dimension_id, dimension_name
 FROM hr_s_application_ownerships ao
     ,hr_s_balance_dimensions pbd
     ,fnd_product_installations b
     ,fnd_application c
 WHERE  pbd.legislation_code    ='ZZ'
 AND    ao.key_name             = 'BALANCE_DIMENSION_ID'
 AND    TO_NUMBER(ao.key_value) = pbd.balance_dimension_id
 AND  ao.product_name = c.application_short_name
 AND  c.application_id = b.application_id
 AND  ((b.status = 'I' AND c.application_short_name <> 'PQP')
          OR
      (b.status in ('I', 'S') AND c.application_short_name = 'PQP'));


CURSOR get_routes_csr IS
 SELECT distinct fr.route_id, route_name
 FROM hr_s_application_ownerships ao
     ,hr_s_routes fr
     ,hr_s_balance_dimensions pbd
     ,fnd_product_installations b
     ,fnd_application c
 WHERE  pbd.legislation_code ='ZZ'
 AND  ao.key_name          = 'ROUTE_ID'
 AND  TO_NUMBER(ao.key_value) = fr.route_id
 AND  fr.route_id = pbd.route_id
 AND  ao.product_name = c.application_short_name
 AND  c.application_id = b.application_id
 AND  ((b.status = 'I' AND c.application_short_name <> 'PQP')
          OR
      (b.status in ('I', 'S') AND c.application_short_name = 'PQP'));

CURSOR get_leg_field_info_csr IS
 SELECT field_name
 FROM hr_s_legislative_field_info
 WHERE legislation_code = 'ZZ';


CURSOR get_leg_rules_csr IS
 SELECT rule_type
 FROM hr_s_legislation_rules
 WHERE legislation_code = 'ZZ';

CURSOR get_balance_class_csr IS
 SELECT distinct pbc.balance_classification_id, pbt.balance_name bname
 FROM hr_s_balance_classifications pbc
     ,hr_s_balance_types  pbt
 WHERE pbc.legislation_code  ='ZZ'
 AND   pbc.balance_type_id   = pbt.balance_type_id;

BEGIN

-- write output file for Element Classifications to be Installed.
write_log('OUTPUT',NULL,NULL,NULL);
--write_log ('OUTPUT','PAY_34011_IP_INS_DATA_IN_TABLE', 'Element Classifications', 'HR_S_ELEMENT_CLASSIFICATIONS');

FOR rec IN get_element_class_csr LOOP
write_log ('OUTPUT','PAY_34012_IP_INS_DATA', 'Element Classification', rec.classification_name);
END LOOP;

-- write output file for Balance Types to be Installed.

write_log('OUTPUT',NULL,NULL,NULL);
--write_log ('OUTPUT','PAY_34011_IP_INS_DATA_IN_TABLE', 'Balance Types', 'HR_S_BALANCE_TYPES');

FOR rec IN get_balance_type_csr LOOP
	write_log ('OUTPUT','PAY_34012_IP_INS_DATA', 'Balance Types', rec.balance_name);
END LOOP;

-- write output file for Defined Balance to be Installed.

write_log('OUTPUT',NULL,NULL,NULL);
--write_log ('OUTPUT','PAY_34011_IP_INS_DATA_IN_TABLE', 'Defined Balances', 'HR_S_DEFINED_BALANCES');

FOR rec IN get_defined_balances_csr LOOP
	write_log ('OUTPUT','PAY_34012_IP_INS_DATA', 'Defined Balances for Balance Type', rec.bname);
END LOOP;

-- write output file for Balance Dimensions to be Installed.

write_log('OUTPUT',NULL,NULL,NULL);
--write_log ('OUTPUT','PAY_34011_IP_INS_DATA_IN_TABLE', 'Balance Dimensions', 'HR_S_BALANCE_DIMENSIONS');

FOR rec IN get_balance_dimensions_csr LOOP
	write_log ('OUTPUT','PAY_34012_IP_INS_DATA', 'Balance Dimension', rec.dimension_name);
END LOOP;

-- write output file for Balance Dimensions to be Installed.

write_log('OUTPUT',NULL,NULL,NULL);
--write_log ('OUTPUT','PAY_34011_IP_INS_DATA_IN_TABLE', 'Routes', 'HR_S_ROUTES');

FOR rec IN get_routes_csr LOOP
	write_log ('OUTPUT','PAY_34012_IP_INS_DATA', 'Route', rec.route_name);
END LOOP;

write_log('OUTPUT',NULL,NULL,NULL);
--write_log ('OUTPUT','PAY_34011_IP_INS_DATA_IN_TABLE', 'Legislative Field Info', 'HR_S_LEGISLATIVE_FIELD_INFO');

FOR rec IN get_leg_field_info_csr LOOP
	write_log ('OUTPUT','PAY_34012_IP_INS_DATA', 'Legislative Field Info', rec.field_name);
END LOOP;

write_log('OUTPUT',NULL,NULL,NULL);
--write_log ('OUTPUT','PAY_34011_IP_INS_DATA_IN_TABLE', 'Legislation Rules', 'HR_S_LEGISLATION_RULES');

FOR rec IN get_leg_rules_csr LOOP
	write_log ('OUTPUT','PAY_34012_IP_INS_DATA', 'Legislation Rule', rec.rule_type);
END LOOP;

write_log('OUTPUT',NULL,NULL,NULL);
--write_log ('OUTPUT','PAY_34011_IP_INS_DATA_IN_TABLE', 'Balance Classifications', 'HR_S_BALANCE_CLASSIFICATIONS');

FOR rec IN get_balance_class_csr LOOP
	write_log ('OUTPUT','PAY_34012_IP_INS_DATA', 'Balance Classification for balance', rec.bname);
END LOOP;


END write_out;


-- ---------------------------------------------------------------------
-- This procedure inserts the Ownership in hr_s_application_ownerships
-- table. It takes the required values from where it is being called.
-- ---------------------------------------------------------------------
PROCEDURE insert_ownership(p_key_name     IN VARCHAR2,
                           p_product_name IN VARCHAR2,
               		   p_key_value 	  IN VARCHAR2) AS
BEGIN

null;

/*hr_utility.set_location('--pay_ip_startup_util.insert_ownership',10);
  INSERT INTO  hr_s_application_ownerships
    ( key_name
     ,product_name
     ,key_value)
  SELECT
      p_key_name
     ,p_product_name
     ,p_key_value
  FROM dual
  WHERE NOT EXISTS (SELECT NULL
		    FROM hr_s_application_ownerships
		    WHERE product_name = p_product_name
                    AND key_name = p_key_name
                    AND key_value = p_key_value);


hr_utility.set_location('--pay_ip_startup_util.insert_ownership',20);  */
END insert_ownership;
-- ---------------------------------------------------------------------
-- Function to check if
--  <i> Localisation is available for the given legislation
-- <ii> HRGLOBAL is currently running
--<iii> Reference data is not available
-- In all the above three cases the program exits giving proper Log
-- information. Else it proceeds to create the required values.
-- ---------------------------------------------------------------------

FUNCTION check_to_install (
		p_legislation_code	IN VARCHAR2) RETURN BOOLEAN IS

v_check_installation     boolean := TRUE;
l_Installed number := 0;
l_reference number := 0;

BEGIN
hr_utility.set_location('pay_ip_startup_util.check_to_install',10);
--Returns TRUE if the HR_LEGISLATION_INSTALLATIONS do not have PAY or PER
--for the given legislation and if no other patch is getting applied
--and reference data is available.

SELECT count(*)
INTO l_Installed
FROM hr_legislation_installations
WHERE application_short_name IN('PAY','PER')
AND legislation_code = p_legislation_code;

IF l_installed > 0 THEN
        g_logging := 'Y';
	write_log ('LOG','PAY_34020_IP_LOCAL_SUPPORT',NULL,NULL);
	v_check_installation   := FALSE;
	RETURN v_check_installation ;
END IF;

SELECT count(*)
INTO l_Installed
FROM hr_legislation_installations
WHERE action IS NOT NULL;

IF l_installed > 0 THEN
        g_logging := 'Y';
	write_log ('LOG','PAY_34019_IP_HRGLOBAL_RUNNING',NULL,NULL);
	v_check_installation    := FALSE;
	RETURN v_check_installation ;
END IF;

BEGIN
SELECT 1
INTO l_reference
FROM dual WHERE EXISTS (SELECT NULL FROM pay_element_classifications
                                    WHERE nvl(legislation_code,'X') = 'ZZ'
                                    AND business_group_id IS NULL);

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		NULL;
END;

IF l_reference = 0 THEN
        g_logging := 'Y';
	write_log ('LOG','PAY_34021_IP_NO_REF_DATA',NULL,NULL);
	v_check_installation    := FALSE;
	RETURN v_check_installation ;
END IF;

RETURN v_check_installation ;
hr_utility.set_location('pay_ip_startup_util.check_to_install',20);
END check_to_install;

-- ---------------------------------------------------------------------
-- Procedure to clear all HR_S tables
-- ---------------------------------------------------------------------
PROCEDURE clear_shadow_tables IS

BEGIN
hr_utility.set_location('pay_ip_startup_util.clear_shadow_table',10);
write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_FORMULA_TYPES',NULL);
DELETE hr_s_formula_types;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_FTYPE_CONTEXT_USAGES',NULL);
DELETE hr_s_ftype_context_usages;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_FORMULAS_F',NULL);
DELETE hr_s_formulas_f;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_ROUTES',NULL);
DELETE hr_s_routes;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_ROUTE_CONTEXT_USAGES',NULL);
DELETE hr_s_route_context_usages;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_CONTEXTS',NULL);
DELETE hr_s_contexts;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_ROUTE_PARAMETERS',NULL);
DELETE hr_s_route_parameters;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_USER_ENTITIES',NULL);
DELETE hr_s_user_entities;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_DATABASE_ITEMS',NULL);
DELETE hr_s_database_items;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_ROUTE_PARAMETER_VALUES',NULL);
DELETE hr_s_route_parameter_values;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_FUNCTIONS',NULL);
DELETE hr_s_functions;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_FUNCTION_PARAMETERS',NULL);
DELETE hr_s_function_parameters;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_FUNCTION_CONTEXT_USAGES',NULL);
DELETE hr_s_function_context_usages;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_ASSIGNMENT_STATUS_TYPES',NULL);
DELETE hr_s_assignment_status_types;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_ELEMENT_CLASSIFICATIONS',NULL);
DELETE hr_s_element_classifications;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_ELEMENT_TYPES_F',NULL);
DELETE hr_s_element_types_f;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_INPUT_VALUES_F',NULL);
DELETE hr_s_input_values_f;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_STATUS_PROCESSING_RULES_F',NULL);
DELETE hr_s_status_processing_rules_f;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_FORMULA_RESULT_RULES_F',NULL);
DELETE hr_s_formula_result_rules_f;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_SUB_CLASSN_RULES_F',NULL);
DELETE hr_s_sub_classn_rules_f;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_BALANCE_TYPES',NULL);
DELETE hr_s_balance_types;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_BALANCE_CLASSIFICATIONS',NULL);
DELETE hr_s_balance_classifications;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_DEFINED_BALANCES',NULL);
DELETE hr_s_defined_balances;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_BALANCE_FEEDS_F',NULL);
DELETE hr_s_balance_feeds_f;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_BALANCE_DIMENSIONS',NULL);
DELETE hr_s_balance_dimensions;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_ELEMENT_SETS',NULL);
DELETE hr_s_element_sets;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_ELEMENT_TYPE_RULES',NULL);
DELETE hr_s_element_type_rules;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_ELE_CLASSN_RULES',NULL);
DELETE hr_s_ele_classn_rules;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_USER_TABLES',NULL);
DELETE hr_s_user_tables;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_USER_COLUMNS',NULL);
DELETE hr_s_user_columns;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_USER_ROWS_F',NULL);
DELETE hr_s_user_rows_f;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_USER_COLUMN_INSTANCES_F',NULL);
DELETE hr_s_user_column_instances_f;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_QP_REPORTS',NULL);
DELETE hr_s_qp_reports;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_ORG_INFORMATION_TYPES',NULL);
DELETE hr_s_org_information_types;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_ORG_INFO_TYPES_BY_CLASS',NULL);
DELETE hr_s_org_info_types_by_class;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_ASSIGNMENT_INFO_TYPES',NULL);
DELETE hr_s_assignment_info_types;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_GLOBALS_F',NULL);
DELETE hr_s_globals_f;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_LEGISLATIVE_FIELD_INFO',NULL);
DELETE hr_s_legislative_field_info;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_LEGISLATION_SUBGROUPS',NULL);
DELETE hr_s_legislation_subgroups;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_APPLICATION_OWNERSHIPS',NULL);
DELETE hr_s_application_ownerships;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_PAYMENT_TYPES',NULL);
DELETE hr_s_payment_types;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_BENEFIT_CLASSIFICATIONS',NULL);
DELETE hr_s_benefit_classifications;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_COBRA_QFYING_EVENTS_F',NULL);
DELETE hr_s_cobra_qfying_events_f;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_VALID_DEPENDENT_TYPES',NULL);
DELETE hr_s_valid_dependent_types;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_HISTORY',NULL);
DELETE hr_s_history;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_STATE_RULES',NULL);
DELETE hr_s_state_rules;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_TAXABILITY_RULES',NULL);
DELETE hr_s_taxability_rules;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_MONETARY_UNITS',NULL);
DELETE hr_s_monetary_units;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_WC_STATE_SURCHARGES',NULL);
DELETE hr_s_wc_state_surcharges;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_LEGISLATION_RULES',NULL);
DELETE hr_s_legislation_rules;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_TAXABILITY_RULES_DATES',NULL);
DELETE HR_S_TAXABILITY_RULES_DATES;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_MAGNETIC_RECORDS',NULL);
DELETE HR_S_MAGNETIC_RECORDS;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_MAGNETIC_BLOCKS',NULL);
DELETE HR_S_MAGNETIC_BLOCKS;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_REPORT_FORMAT_MAPPINGS_F',NULL);
DELETE HR_S_REPORT_FORMAT_MAPPINGS_F;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_US_CITY_TAX_INFO_F',NULL);
DELETE HR_S_US_CITY_TAX_INFO_F;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_US_COUNTY_TAX_INFO_F',NULL);
DELETE HR_S_US_COUNTY_TAX_INFO_F;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_US_STATE_TAX_INFO_F',NULL);
DELETE HR_S_US_STATE_TAX_INFO_F;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_US_FEDERAL_TAX_INFO_F',NULL);
DELETE HR_S_US_FEDERAL_TAX_INFO_F;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_US_GARN_EXEMPTION_RULES_F',NULL);
DELETE HR_S_US_GARN_EXEMPTION_RULES_F;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_US_GARN_LIMIT_RULES_F',NULL);
DELETE HR_S_US_GARN_LIMIT_RULES_F;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_US_GARN_FEE_RULES_F',NULL);
DELETE HR_S_US_GARN_FEE_RULES_F;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_REPORT_LOOKUPS',NULL);
DELETE HR_S_REPORT_LOOKUPS;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_REPORT_FORMAT_ITEMS_F',NULL);
DELETE HR_S_REPORT_FORMAT_ITEMS_F;
COMMIT;

write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S_STATE_RULES',NULL);
DELETE HR_S_STATE_RULES;
COMMIT;
hr_utility.set_location('pay_ip_startup_util.clear_shadow_table',20);
END clear_shadow_tables;


-- -----------------------------------------------------------------------
-- This procedure will move the data with dummy legislation to HR_S
-- tables from LIVE HRMS tables. The ownership for Elemnet Classifications
-- Balance types, Balance Dimensions, Routes arealso inserted.
-- -----------------------------------------------------------------------
PROCEDURE move_to_shadow_tables (p_legislation_code IN VARCHAR2,
				 p_install_tax_unit IN VARCHAR2) IS



--
CURSOR get_element_class_csr IS
  SELECT
    classification_id,business_group_id,legislation_code,classification_name,description,
    legislation_subgroup,costable_flag,default_high_priority,default_low_priority,
    default_priority,distributable_over_flag,non_payments_flag,costing_debit_or_credit,
    parent_classification_id,create_by_default_flag,last_update_date,last_updated_by,
    last_update_login,created_by,creation_date,balance_initialization_flag,object_version_number
  FROM pay_element_classifications
  WHERE nvl(legislation_code,'X') = 'ZZ'
  AND business_group_id IS NULL;

CURSOR get_balance_type_csr IS
  SELECT
    balance_type_id, business_group_id, legislation_code, currency_code,
    assignment_remuneration_flag, balance_name,balance_uom, NULL comments, jurisdiction_level,
    legislation_subgroup, reporting_name, tax_type, attribute_category,
    attribute1, attribute2, attribute3, attribute4, attribute5, attribute6, attribute7,
    attribute8, attribute9, attribute10, attribute11, attribute12, attribute13, attribute14,
    attribute15, attribute16, attribute17, attribute18, attribute19, attribute20,
    last_update_date, last_updated_by, last_update_login, created_by, creation_date
  FROM pay_balance_types
  WHERE nvl(legislation_code,'X') = 'ZZ'
  AND business_group_id IS NULL;

CURSOR get_defined_balances_csr IS
  SELECT
    d.defined_balance_id, d.business_group_id, d.legislation_code, d.balance_type_id,
    d.balance_dimension_id, d.force_latest_balance_flag, d.legislation_subgroup,
    d.last_update_date, d.last_updated_by, d.last_update_login, d.created_by, d.creation_date,
    d.object_version_number, d.grossup_allowed_flag, b.balance_name bname
  FROM  pay_defined_balances d, pay_balance_types b
  WHERE d.balance_type_id = b.balance_type_id
  AND EXISTS (SELECT NULL FROM hr_s_balance_types b
              WHERE d.balance_type_id = b.balance_type_id);


--Cursors to install route and dimension if install_tax_unit is true.

CURSOR get_balance_dimensions_csr IS
  SELECT
    balance_dimension_id, business_group_id, legislation_code, route_id,
    database_item_suffix, dimension_name, dimension_type, description,
    feed_checking_code, feed_checking_type, legislation_subgroup, payments_flag,
    expiry_checking_code, expiry_checking_level, dimension_level, period_type
  FROM  pay_balance_dimensions
  WHERE nvl(legislation_code,'X') = 'ZZ'
  AND business_group_id IS NULL;


CURSOR get_routes_csr IS
  SELECT
    route_id, route_name, user_defined_flag, description, text, last_update_date,
    last_updated_by, last_update_login, created_by, creation_date
   FROM ff_routes a
   WHERE EXISTS (SELECT NULL
                 FROM pay_balance_dimensions c
                 WHERE c.route_id = a.route_id
                 AND c.legislation_code = 'ZZ');


CURSOR get_balance_class_csr IS
  SELECT
    balance_classification_id, business_group_id, legislation_code, balance_type_id,
    classification_id, scale, legislation_subgroup, last_update_date, last_updated_by,
    last_update_login, created_by, creation_date, object_version_number
  FROM pay_balance_classifications
  WHERE nvl(legislation_code,'X') = 'ZZ'
  AND business_group_id IS NULL;



BEGIN
hr_utility.set_location('pay_ip_startup_util.move_to_shadow_tables ',10);
--Legislation Rules
write_log ('LOG','PAY_34011_IP_INS_DATA_IN_TABLE','Legislation Rules', 'HR_S_LEGISLATION_RULES');

INSERT INTO hr_s_application_ownerships
(key_name
,product_name
,key_value)
SELECT ao.key_name
      ,ao.product_name
      ,ao.key_value
FROM   hr_application_ownerships   ao
      ,pay_element_classifications pec
WHERE  pec.legislation_code     = 'ZZ'
  AND  ao.key_name             = 'CLASSIFICATION_ID'
  AND  TO_NUMBER(ao.key_value) = pec.classification_id
UNION ALL
SELECT ao.key_name
      ,ao.product_name
      ,ao.key_value
FROM   hr_application_ownerships ao
      ,pay_balance_types         pbt
WHERE  pbt.legislation_code     = 'ZZ'
  AND  ao.key_name             = 'BALANCE_TYPE_ID'
  AND  TO_NUMBER(ao.key_value) = pbt.balance_type_id
UNION ALL
SELECT ao.key_name
      ,ao.product_name
      ,ao.key_value
FROM   hr_application_ownerships ao
      ,pay_balance_dimensions pbd
WHERE  pbd.legislation_code ='ZZ'
  AND  ao.key_name          = 'BALANCE_DIMENSION_ID'
  AND  TO_NUMBER(ao.key_value) = pbd.balance_dimension_id
UNION ALL
SELECT ao.key_name
      ,ao.product_name
      ,ao.key_value
FROM   hr_application_ownerships ao
      ,pay_defined_balances pdb
WHERE  pdb.legislation_code ='ZZ'
  AND  ao.key_name          = 'DEFINED_BALANCE_ID'
  AND  TO_NUMBER(ao.key_value) = pdb.defined_balance_id
UNION ALL
SELECT ao.key_name
      ,ao.product_name
      ,ao.key_value
FROM   hr_application_ownerships ao
      ,ff_routes fr
      ,pay_balance_dimensions pbd
WHERE  pbd.legislation_code ='ZZ'
  AND  ao.key_name          = 'ROUTE_ID'
  AND  TO_NUMBER(ao.key_value) = fr.route_id
  AND  fr.route_id = pbd.route_id;


-- Element Classifictions

write_log('LOG',NULL,NULL,NULL);
write_log ('LOG','PAY_34011_IP_INS_DATA_IN_TABLE', 'Element Classifications', 'HR_S_ELEMENT_CLASSIFICATIONS');

FOR rec IN get_element_class_csr LOOP
write_log ('LOG','PAY_34012_IP_INS_DATA', 'Element Classification', rec.classification_name);

  INSERT INTO hr_s_element_classifications
    ( classification_id
     ,business_group_id
     ,legislation_code
     ,classification_name
     ,description
     ,legislation_subgroup
     ,costable_flag
     ,default_high_priority
     ,default_low_priority
     ,default_priority
     ,distributable_over_flag
     ,non_payments_flag
     ,costing_debit_or_credit
     ,parent_classification_id
     ,create_by_default_flag
     ,last_update_date
     ,last_updated_by
     ,last_update_login
     ,created_by
     ,creation_date
     ,balance_initialization_flag
     ,object_version_number
    )

  VALUES
    ( rec.classification_id
     ,rec.business_group_id
     ,rec.legislation_code
     ,rec.classification_name
     ,rec.description
     ,rec.legislation_subgroup
     ,rec.costable_flag
     ,rec.default_high_priority
     ,rec.default_low_priority
     ,rec.default_priority
     ,rec.distributable_over_flag
     ,rec.non_payments_flag
     ,rec.costing_debit_or_credit
     ,rec.parent_classification_id
     ,rec.create_by_default_flag
     ,rec.last_update_date
     ,rec.last_updated_by
     ,rec.last_update_login
     ,rec.created_by
     ,rec.creation_date
     ,rec.balance_initialization_flag
     ,rec.object_version_number
    );

  write_log ('LOG','PAY_34013_IP_INS_OWNERSHIP', 'Element Classification', rec.classification_name);
  ----pay_ip_startup_util.insert_ownership('CLASSIFICATION_ID','PER',rec.classification_id);
  ----pay_ip_startup_util.insert_ownership('CLASSIFICATION_ID','PAY',rec.classification_id);

END LOOP;

hr_utility.set_location('pay_ip_startup_util.move_to_shadow_tables',20);
--Balance Types
write_log('LOG',NULL,NULL,NULL);
write_log ('LOG','PAY_34011_IP_INS_DATA_IN_TABLE', 'Balance Types', 'HR_S_BALANCE_TYPES');
FOR rec IN get_balance_type_csr LOOP
write_log ('LOG','PAY_34012_IP_INS_DATA', 'Balance Types', rec.balance_name);

  INSERT INTO hr_s_balance_types
    ( balance_type_id
     ,business_group_id
     ,legislation_code
     ,currency_code
     ,assignment_remuneration_flag
     ,balance_name
     ,balance_uom
     ,comments
     ,jurisdiction_level
     ,legislation_subgroup
     ,reporting_name
     ,tax_type
     ,attribute_category
     ,attribute1
     ,attribute2
     ,attribute3
     ,attribute4
     ,attribute5
     ,attribute6
     ,attribute7
     ,attribute8
     ,attribute9
     ,attribute10
     ,attribute11
     ,attribute12
     ,attribute13
     ,attribute14
     ,attribute15
     ,attribute16
     ,attribute17
     ,attribute18
     ,attribute19
     ,attribute20
     ,last_update_date
     ,last_updated_by
     ,last_update_login
     ,created_by
     ,creation_date
    )

  VALUES
    ( rec.balance_type_id
     ,rec.business_group_id
     ,rec.legislation_code
     ,rec.currency_code
     ,rec.assignment_remuneration_flag
     ,rec.balance_name
     ,rec.balance_uom
     ,rec.comments
     ,rec.jurisdiction_level
     ,rec.legislation_subgroup
     ,rec.reporting_name
     ,rec.tax_type
     ,rec.attribute_category
     ,rec.attribute1
     ,rec.attribute2
     ,rec.attribute3
     ,rec.attribute4
     ,rec.attribute5
     ,rec.attribute6
     ,rec.attribute7
     ,rec.attribute8
     ,rec.attribute9
     ,rec.attribute10
     ,rec.attribute11
     ,rec.attribute12
     ,rec.attribute13
     ,rec.attribute14
     ,rec.attribute15
     ,rec.attribute16
     ,rec.attribute17
     ,rec.attribute18
     ,rec.attribute19
     ,rec.attribute20
     ,rec.last_update_date
     ,rec.last_updated_by
     ,rec.last_update_login
     ,rec.created_by
     ,rec.creation_date
    );

  write_log ('LOG','PAY_34013_IP_INS_OWNERSHIP', 'Balance Type', rec.balance_name);
  ----pay_ip_startup_util.insert_ownership('BALANCE_TYPE_ID','PER',rec.balance_type_id);
  --pay_ip_startup_util.insert_ownership('BALANCE_TYPE_ID','PAY',rec.balance_type_id);
END LOOP;

hr_utility.set_location('pay_ip_startup_util.move_to_shadow_tables ',30);

--Defined Balance
write_log('LOG',NULL,NULL,NULL);
write_log ('LOG','PAY_34011_IP_INS_DATA_IN_TABLE', 'Defined Balances', 'HR_S_DEFINED_BALANCES');
FOR rec IN get_defined_balances_csr LOOP
write_log ('LOG','PAY_34012_IP_INS_DATA', 'Defined Balances for Balance Type', rec.bname);
  INSERT INTO hr_s_defined_balances
    ( defined_balance_id
     ,business_group_id
     ,legislation_code
     ,balance_type_id
     ,balance_dimension_id
     ,force_latest_balance_flag
     ,legislation_subgroup
     ,last_update_date
     ,last_updated_by
     ,last_update_login
     ,created_by
     ,creation_date
     ,object_version_number
     ,grossup_allowed_flag
    )
  VALUES
    ( rec.defined_balance_id
     ,rec.business_group_id
     ,rec.legislation_code
     ,rec.balance_type_id
     ,rec.balance_dimension_id
     ,rec.force_latest_balance_flag
     ,rec.legislation_subgroup
     ,rec.last_update_date
     ,rec.last_updated_by
     ,rec.last_update_login
     ,rec.created_by
     ,rec.creation_date
     ,rec.object_version_number
     ,rec.grossup_allowed_flag
    );

END LOOP;

hr_utility.set_location('pay_ip_startup_util.move_to_shadow_tables ',40);

--Balance Dimensions

write_log('LOG',NULL,NULL,NULL);
write_log ('LOG','PAY_34011_IP_INS_DATA_IN_TABLE', 'Balance Dimensions', 'HR_S_BALANCE_DIMENSIONS');
FOR rec IN get_balance_dimensions_csr LOOP
write_log ('LOG','PAY_34012_IP_INS_DATA', 'Balance Dimension', rec.dimension_name);

  INSERT INTO hr_s_balance_dimensions
    ( balance_dimension_id
     ,business_group_id
     ,legislation_code
     ,route_id
     ,database_item_suffix
     ,dimension_name
     ,dimension_type
     ,description
     ,feed_checking_code
     ,feed_checking_type
     ,legislation_subgroup
     ,payments_flag
     ,expiry_checking_code
     ,expiry_checking_level
     ,dimension_level
     , period_type
	 )

  VALUES
    ( rec.balance_dimension_id
     ,rec.business_group_id
     ,rec.legislation_code
     ,rec.route_id
     ,rec.database_item_suffix
     ,rec.dimension_name
     ,rec.dimension_type
     ,rec.description
     ,rec.feed_checking_code
     ,rec.feed_checking_type
     ,rec.legislation_subgroup
     ,rec.payments_flag
     ,rec.expiry_checking_code
     ,rec.expiry_checking_level
     ,rec.dimension_level
     ,rec.period_type
     );

write_log ('LOG','PAY_34013_IP_INS_OWNERSHIP', 'Balance Dimension', rec.dimension_name);

END LOOP;

hr_utility.set_location('pay_ip_startup_util.move_to_shadow_tables ',50);

--Routes

write_log('LOG',NULL,NULL,NULL);
write_log ('LOG','PAY_34011_IP_INS_DATA_IN_TABLE', 'Routes', 'HR_S_ROUTES');
FOR rec IN get_routes_csr LOOP
write_log ('LOG','PAY_34012_IP_INS_DATA', 'Route', rec.route_name);

  INSERT INTO hr_s_routes
    ( route_id
     ,route_name
     ,user_defined_flag
     ,description
     ,text
     ,last_update_date
     ,last_updated_by
     ,last_update_login
     ,created_by
     ,creation_date
    )

  VALUES
    ( rec.route_id
     ,rec.route_name
     ,rec.user_defined_flag
     ,rec.description
     ,rec.text
     ,rec.last_update_date
     ,rec.last_updated_by
     ,rec.last_update_login
     ,rec.created_by
     ,rec.creation_date
    );

 write_log ('LOG','PAY_34013_IP_INS_OWNERSHIP', 'Route', rec.route_name);

END LOOP;


IF p_install_tax_unit = 'N' THEN

	DELETE FROM hr_s_application_ownerships
	WHERE key_name = 'BALANCE_DIMENSION_ID'
	AND TO_NUMBER(key_value) IN (SELECT balance_dimension_id
				     FROM hr_s_balance_dimensions
				     WHERE legislation_code = 'ZZ'
				     AND INSTR(database_item_suffix,'_TU_') > 0);

END IF;



hr_utility.set_location('pay_ip_startup_util.move_to_shadow_tables ',60);
-- Route Parameters
write_log('LOG',NULL,NULL,NULL);
write_log ('LOG','PAY_34011_IP_INS_DATA_IN_TABLE', 'Route Parameters', 'HR_S_ROUTE_PARAMETERS');
INSERT INTO hr_s_route_parameters
  (SELECT
     route_parameter_id
    ,route_id
    ,data_type
    ,parameter_name
    ,sequence_no
  FROM ff_route_parameters a
  WHERE EXISTS ( SELECT NULL
                 FROM hr_s_routes b
                 WHERE b.route_id = a.route_id));
write_log('LOG',NULL,NULL,NULL);
write_log ('LOG','PAY_34011_IP_INS_DATA_IN_TABLE', 'Route Context Usages', 'HR_S_ROUTE_CONTEXT_USAGES');
INSERT INTO hr_s_route_context_usages
  (SELECT
     route_id
    ,context_id
    ,sequence_no
  FROM ff_route_context_usages a
  WHERE EXISTS ( SELECT NULL
                 FROM hr_s_routes b
                 WHERE b.route_id = a.route_id));

hr_utility.set_location('pay_ip_startup_util.move_to_shadow_tables ',70);

-- Used column to column mapping in the insert statement to remove
-- error caused by mismatch in number of fields. Bug No 3720975.

INSERT into hr_s_legislative_field_info
(FIELD_NAME,
LEGISLATION_CODE,
PROMPT,
VALIDATION_NAME,
VALIDATION_TYPE,
TARGET_LOCATION,
RULE_TYPE,
RULE_MODE)
(SELECT
FIELD_NAME,
LEGISLATION_CODE,
PROMPT,
VALIDATION_NAME,
VALIDATION_TYPE,
TARGET_LOCATION,
RULE_TYPE,
RULE_MODE
 FROM pay_legislative_field_info
WHERE nvl(legislation_code,'X') = 'ZZ');

hr_utility.set_location('pay_ip_startup_util.move_to_shadow_tables ',80);

--Balance Classifications

write_log('LOG',NULL,NULL,NULL);
write_log ('LOG','PAY_34011_IP_INS_DATA_IN_TABLE', 'Balance Classifications', 'HR_S_BALANCE_CLASSIFICATIONS');
FOR rec IN get_balance_class_csr LOOP
write_log ('LOG','PAY_34012_IP_INS_DATA', 'Balance Classifications', rec.balance_classification_id);

  INSERT INTO hr_s_balance_classifications
    (  balance_classification_id
      ,business_group_id
      ,legislation_code
      ,balance_type_id
      ,classification_id
      ,scale
      ,legislation_subgroup
      ,last_update_date
      ,last_updated_by
      ,last_update_login
      ,created_by
      ,creation_date
      ,object_version_number
    )
  VALUES
    (  rec.balance_classification_id
      ,rec.business_group_id
      ,rec.legislation_code
      ,rec.balance_type_id
      ,rec.classification_id
      ,rec.scale
      ,rec.legislation_subgroup
      ,rec.last_update_date
      ,rec.last_updated_by
      ,rec.last_update_login
      ,rec.created_by
      ,rec.creation_date
      ,rec.object_version_number
    );

write_log ('LOG','PAY_34013_IP_INS_OWNERSHIP', 'Balance Classifications', rec.balance_classification_id);

END LOOP;

hr_utility.set_location('pay_ip_startup_util.move_to_shadow_tables ',90);


	EXCEPTION
 		WHEN OTHERS THEN
 		IF get_element_class_csr%ISOPEN THEN
 			CLOSE get_element_class_csr;
 		END IF;
 		IF get_balance_type_csr%ISOPEN THEN
 			CLOSE get_balance_type_csr;
 		END IF;
 		IF get_defined_balances_csr%ISOPEN THEN
 			CLOSE get_defined_balances_csr;
 		END IF;
		IF get_balance_dimensions_csr%ISOPEN THEN
 			CLOSE get_balance_dimensions_csr;
 		END IF;
 		IF get_routes_csr%ISOPEN THEN
 			CLOSE get_routes_csr;
 		END IF;
		IF get_balance_class_csr%ISOPEN THEN
			CLOSE get_balance_class_csr;
		END IF;

 		RAISE_APPLICATION_ERROR(-20001, SQLERRM);

END move_to_shadow_tables;
-- ---------------------------------------------------------------------
-- Function to create Bank Key Flexfield , It will be created as
--  " <legislation_code>_BANK_DETAILS "
-- ---------------------------------------------------------------------

FUNCTION create_key_flexfield
		 (p_appl_Short_Name		IN VARCHAR2,
		 p_flex_code			IN VARCHAR2,
                 p_structure_code		IN VARCHAR2,
                 p_structure_title		IN VARCHAR2,
                 p_description			IN VARCHAR2,
                 p_view_name			IN VARCHAR2,
                 p_freeze_flag			IN VARCHAR2,
                 p_enabled_flag			IN VARCHAR2,
                 p_cross_val_flag		IN VARCHAR2,
                 p_freeze_rollup_flag		IN VARCHAR2,
                 p_dynamic_insert_flag		IN VARCHAR2,
                 p_shorthand_enabled_flag	IN VARCHAR2,
                 p_shorthand_prompt		IN VARCHAR2,
                 p_shorthand_length		IN NUMBER) RETURN NUMBER IS

     l_flexfield               fnd_flex_key_api.flexfield_type;
     l_structure               fnd_flex_key_api.structure_type;
     l_application_id	       NUMBER(15);
     l_exists                  varchar2(1);



     CURSOR duplicate_structure_check (p_application_id NUMBER,
                                      p_flexfield_code VARCHAR2,
				      p_structure_title VARCHAR2) IS
		SELECT null
		  FROM fnd_id_flex_structures_vl
		 WHERE application_id = p_application_id
		   AND id_flex_code = p_flexfield_code
		   AND id_flex_structure_name = p_structure_title;


BEGIN

  SELECT application_id
      INTO l_application_id
      FROM FND_APPLICATION
      WHERE application_short_name = p_appl_Short_Name;

  hr_utility.set_location('pay_ip_startup_util.create_key_flexfield ',10);
  fnd_flex_key_api.set_session_mode('seed_data');

  l_flexfield := fnd_flex_key_api.find_flexfield
    ( appl_short_name         => p_appl_short_name,
      flex_code               => p_flex_code );

  hr_utility.set_location('pay_ip_startup_util.create_key_flexfield ',20);
  BEGIN

    l_structure := fnd_flex_key_api.find_structure
       ( flexfield              => l_flexfield,
         structure_code         => p_structure_code );

    return l_structure.structure_number;
    hr_utility.set_location('pay_ip_startup_util.create_key_flexfield ',30);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN

      -- Bug 4544374. Check if the structure code exists with this title already.
      OPEN duplicate_structure_check(l_application_id, l_flexfield.flex_code, p_structure_title);
      FETCH duplicate_structure_check INTO l_exists;

      IF duplicate_structure_check%FOUND then
        close duplicate_structure_check;
	fnd_message.set_name('PAY', 'PAY_34291_IP_BANK_STRUCT_EXIST');
	fnd_message.set_token('TITLE', p_structure_title);
	fnd_message.raise_error;
      END IF;

      CLOSE duplicate_structure_check;

      l_structure:=fnd_flex_key_api.new_structure
          		(flexfield             => l_flexfield,
                        structure_code         => p_structure_code,
                        structure_title        => p_structure_title,
                        description            => p_description,
                        view_name              => p_view_name,
                        freeze_flag            => p_freeze_flag,
                        enabled_flag           => p_enabled_flag,
                        segment_separator      => '.',
                        cross_val_flag         => p_cross_val_flag,
                        freeze_rollup_flag     => p_freeze_rollup_flag,
                        dynamic_insert_flag    => p_dynamic_insert_flag,
                        shorthand_enabled_flag => p_shorthand_enabled_flag,
                        shorthand_prompt       => p_shorthand_prompt,
                        shorthand_length       => p_shorthand_length);

      SELECT application_id
      INTO l_application_id
      FROM FND_APPLICATION
      WHERE application_short_name = p_appl_short_name;

      SELECT NVL(MAX(ifs.id_flex_num),0) + 1
	INTO l_structure.structure_number
	FROM fnd_id_flex_structures ifs
       WHERE ifs.application_id = l_application_id
	 AND ifs.id_flex_code = p_flex_code
	 AND ifs.id_flex_num < 101;

      fnd_flex_key_api.add_structure
               ( flexfield              => l_flexfield,
                 structure              => l_structure );

      RETURN l_structure.structure_number;
  END;
  hr_utility.set_location('pay_ip_startup_util.create_key_flexfield ',40);
END create_key_flexfield;

-- ---------------------------------------------------------------------
-- Procedure for creating the Flex field segments
-- ---------------------------------------------------------------------

PROCEDURE create_flex_segments
		 (p_appl_Short_Name		IN VARCHAR2,
		 p_flex_code			IN VARCHAR2,
                 p_structure_code		IN VARCHAR2,
                 p_segment_name 		IN VARCHAR2,
                 p_column_name  		IN VARCHAR2,
                 p_segment_number  		IN VARCHAR2,
                 p_enabled_flag 		IN VARCHAR2,
                 p_displayed_flag 		IN VARCHAR2,
                 p_indexed_flag   		IN VARCHAR2,
                 p_value_set  			IN VARCHAR2,
                 p_display_size 		IN NUMBER,
                 p_description_size 		IN NUMBER,
                 p_concat_size 			IN NUMBER,
                 p_lov_prompt  			IN VARCHAR2,
                 p_window_prompt 		IN VARCHAR2
) IS

     l_flexfield               fnd_flex_key_api.flexfield_type;
     l_structure               fnd_flex_key_api.structure_type;
     l_application_id		NUMBER(15);
     l_flex_num			NUMBER(15);
     l_segment      fnd_flex_key_api.segment_type;
BEGIN

hr_utility.set_location('pay_ip_startup_util.create_key_segments ',10);
	fnd_flex_key_api.set_session_mode('seed_data');
   l_flexfield := fnd_flex_key_api.find_flexfield
    ( appl_short_name         => p_appl_short_name,
      flex_code               => p_flex_code );

hr_utility.set_location('pay_ip_startup_util.create_key_segments ',11);

      l_structure := fnd_flex_key_api.find_structure
       ( flexfield              => l_flexfield,
         structure_code         => p_structure_code );

hr_utility.set_location('pay_ip_startup_util.create_key_segments ',12);
begin

hr_utility.trace(p_segment_name);
 l_segment := fnd_flex_key_api.find_segment
               (
                       flexfield              => l_flexfield
                      ,structure              => l_structure
                      ,segment_name           => p_segment_name
               );
exception
	when no_data_found then
 l_segment:= fnd_flex_key_api.new_segment
                     (
                       flexfield              => l_flexfield
                      ,structure              => l_structure
                      ,segment_name           => p_segment_name
                      ,description            => null
                      ,column_name            => p_column_name
                      ,segment_number         => p_segment_number
                      ,enabled_flag           => p_enabled_flag
                      ,displayed_flag         => p_displayed_flag
                      ,indexed_flag           => p_indexed_flag
                      ,value_set              => p_value_set
                      ,default_type           => null
                      ,default_value          => null
                      ,required_flag          => 'N'
                      ,security_flag          => 'N'
                      ,display_size           => p_display_size
                      ,description_size       => p_description_size
                      ,concat_size            => p_concat_size
                      ,lov_prompt             => p_lov_prompt
                      ,window_prompt          => p_window_prompt
                     );

hr_utility.set_location('pay_ip_startup_util.create_key_segments ',13);

hr_utility.trace(p_segment_name);
begin
 fnd_flex_key_api.add_segment
                     (
                      flexfield               => l_flexfield
                     ,structure               => l_structure
                     ,segment                 => l_segment
                     );
exception
  when others then
    hr_utility.trace(substr(fnd_flex_key_api.message,1,256));
end;
hr_utility.set_location('pay_ip_startup_util.create_key_segments ',14);
 fnd_flex_key_api.assign_qualifier
                     (
                      flexfield               => l_flexfield
                     ,structure               => l_structure
                     ,segment                 => l_segment
                     ,flexfield_qualifier     => 'ASSIGNMENT'
                     ,enable_flag             => 'Y'
                     );

end;
END create_flex_segments;


-- ---------------------------------------------------------------------
-- Procedure for creating the rule for Bank key flexfield.
-- ---------------------------------------------------------------------
PROCEDURE create_leg_rule
		 (p_legislation_code	IN VARCHAR2,
		  p_Rule_Type		IN VARCHAR2,
		  p_Rule_mode		IN VARCHAR2) IS

BEGIN
hr_utility.set_location('pay_ip_startup_util.create_flex_leg_rule ',10);

INSERT INTO hr_s_legislation_rules
  ( legislation_code
   ,rule_type
   ,rule_mode)
  SELECT
  'ZZ'
  ,p_rule_type
  ,p_rule_mode
  FROM dual
  WHERE NOT EXISTS (SELECT NULL
                    FROM hr_s_legislation_rules
                    WHERE legislation_code = 'ZZ'
                    AND rule_type = p_rule_type);
IF SQL%NOTFOUND THEN
	UPDATE hr_s_legislation_rules SET
		rule_mode = p_rule_mode
	WHERE legislation_code = 'ZZ'
	AND rule_type = p_rule_type;
END IF;
hr_utility.set_location('pay_ip_startup_util.create_flex_leg_rule ',20);
END;

-- ---------------------------------------------------------------------
-- HR_S Tables are updated  to the choosen legislation_code and currency
-- ---------------------------------------------------------------------
PROCEDURE update_shadow_tables
		(p_legislation_code	IN VARCHAR2,
		 p_currency_code	IN VARCHAR2) IS

BEGIN
hr_utility.set_location('pay_ip_startup_util.update_shadow_tables ',10);
--Updating Element Classifications Table

write_log('LOG','PAY_34015_IP_UPD_TABLE','HR_S_ELEMENT_CLASSIFICATIONS',NULL);
UPDATE hr_s_element_classifications
SET legislation_code = p_legislation_code
WHERE legislation_code = 'ZZ';

--Updating Balance Types Table

write_log('LOG','PAY_34015_IP_UPD_TABLE','HR_S_BALANCE_TYPES',NULL);
UPDATE hr_s_BALANCE_TYPES
SET legislation_code = p_legislation_code,
currency_code = p_currency_code
WHERE legislation_code = 'ZZ';

--Updating Defined Balances Table

write_log('LOG','PAY_34015_IP_UPD_TABLE','HR_S_DEFINED_BALANCES',NULL);
UPDATE hr_s_defined_balances
SET legislation_code = p_legislation_code
WHERE legislation_code = 'ZZ';


--Updating Balance Dimensions Table

write_log('LOG','PAY_34015_IP_UPD_TABLE','HR_S_BALANCE_DIMENSIONS',NULL);
UPDATE hr_s_balance_dimensions
SET legislation_code = p_legislation_code
WHERE legislation_code = 'ZZ';

--Updating Legislation Rules Table

write_log('LOG','PAY_34015_IP_UPD_TABLE','HR_S_LEGISLATION_RULES',NULL);
UPDATE hr_s_legislation_rules
SET legislation_code = p_legislation_code
WHERE legislation_code = 'ZZ';

--Unpadting Legislative Field Info

write_log('LOG','PAY_34015_IP_UPD_TABLE','HR_S_LEGISLATIVE_FIELD_INFO',NULL);
UPDATE hr_s_legislative_field_info
SET legislation_code = p_legislation_code
WHERE legislation_code = 'ZZ';

--Updating Balance Classifications

write_log('LOG','PAY_34015_IP_UPD_TABLE','HR_S_BALANCE_CLASSIFICATIONS',NULL);
UPDATE hr_s_balance_classifications
SET legislation_code = p_legislation_code
WHERE legislation_code = 'ZZ';

hr_utility.set_location('pay_ip_startup_util.update_shadow_tables ',20);

EXCEPTION
	WHEN OTHERS THEN
		RAISE_APPLICATION_ERROR(-20001, SQLERRM);
END update_shadow_tables;

-- ---------------------------------------------------------------------
-- A record for the choosen legislation rule is inserted in to History
-- table as HR_LEGISLATION.INSTALL picks up the legislation_code from
-- this history table
-- ---------------------------------------------------------------------
PROCEDURE insert_history_table
		 (p_legislation_code	IN VARCHAR2) IS

BEGIN
hr_utility.set_location('pay_ip_startup_util.insert_history_table',10);
  INSERT INTO hr_s_history
    ( package_name
     ,date_of_export
     ,date_of_import
     ,status
     ,legislation_code)
  VALUES
    ( TO_CHAR(SYSDATE,'ddMonyyyy-hh:rr:ss') || '[' || p_legislation_code || ']'
     ,sysdate
     ,sysdate
     ,'HR_S tabes copied from reference account'
     ,p_legislation_code);
hr_utility.set_location('pay_ip_startup_util.insert_history_table',20);
END insert_history_table ;

-- ---------------------------------------------------------------------
-- The data from Shadow tables are moved in to the main tables with the
-- required legislation_code and currency, by HR_LEGISLATION.INSTALL
-- ---------------------------------------------------------------------
PROCEDURE move_to_main_tables IS

BEGIN
hr_utility.set_location('pay_ip_startup_util.move_to_main_tables',10);
hr_legislation.install;

EXCEPTION
	WHEN OTHERS THEN
		RAISE_APPLICATION_ERROR(-20001, SQLERRM);

hr_utility.set_location('pay_ip_startup_util.move_to_main_tables',20);
END move_to_main_tables;

-- ---------------------------------------------------------------------
-- Procedure to update the TL tables with the translated values.
-- ---------------------------------------------------------------------

-- Updating Element Classifications TL Table

PROCEDURE update_ele_class_tl
          (p_legislation_code	IN VARCHAR2) IS

CURSOR get_classid_btable_csr IS
  SELECT  b.classification_id bid , b.classification_name bname,
          t.language, t.classification_name tname, t.description, t.source_lang
  FROM    pay_element_classifications_tl t, pay_element_classifications b
  WHERE   b.classification_id = t.classification_id
  AND     b.legislation_code = 'ZZ'
  AND     b.business_group_id IS NULL;


CURSOR get_classid_tltable_csr(l_legislation_code VARCHAR2 , l_name VARCHAR2 , l_language VARCHAR2) IS
  SELECT  t.classification_id tlid
  FROM    pay_element_classifications_tl t, pay_element_classifications b
  WHERE   b.classification_name = l_name
  AND     b.legislation_code = l_legislation_code
  AND     b.business_group_id is NULL
  AND     t.classification_id = b.classification_id
  AND     t.language = l_language;

rec_tltable_csr get_classid_tltable_csr%ROWTYPE;

BEGIN

hr_utility.set_location('pay_ip_startup_util.update_ele_class_tl',10);

    FOR l_record in get_classid_btable_csr LOOP

	OPEN get_classid_tltable_csr(p_legislation_code, l_record.bname, l_record.language);
	fetch get_classid_tltable_csr INTO rec_tltable_csr ;

	if get_classid_tltable_csr%found then

		UPDATE pay_element_classifications_tl
		SET   classification_name = l_record.tname,
		      description = l_record.description,
		      source_lang = l_record.source_lang
		WHERE classification_id = rec_tltable_csr.tlid
		AND   language = l_record.language;

	end if;

	CLOSE get_classid_tltable_csr;

    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
    IF get_classid_btable_csr%ISOPEN THEN
       CLOSE get_classid_btable_csr;
    END IF;
    IF get_classid_tltable_csr%ISOPEN THEN
       CLOSE get_classid_tltable_csr;
    END IF;
    RAISE_APPLICATION_ERROR(-20001, SQLERRM);
hr_utility.set_location('pay_ip_startup_util.update_ele_class_tl',20);
END update_ele_class_tl;

-- Updating Balance Types TL Table

PROCEDURE update_bal_type_tl
		(p_legislation_code	IN VARCHAR2) IS

--old reference data ids
CURSOR get_balid_btable_csr IS
        SELECT  b.balance_type_id bid , b.balance_name bname ,
		t.language, t.balance_name tname, t.reporting_name, t.source_lang
        FROM    pay_balance_types_tl t, pay_balance_types b
        WHERE   t.balance_type_id = b.balance_type_id
	AND     b.legislation_code = 'ZZ'
        AND     b.business_group_id IS NULL ;

--ids for newly created data
CURSOR get_balid_tltable_csr(l_legislation_code VARCHAR2, l_name VARCHAR2 , l_language VARCHAR2 ) IS
        SELECT  t.balance_type_id tlid
        FROM    pay_balance_types_tl t, pay_balance_types b
        WHERE   b.balance_name = l_name
	AND     b.legislation_code = l_legislation_code
        AND     b.business_group_id IS NULL
        AND     b.balance_type_id = t.balance_type_id
        AND     t.language = l_language;

rec_tltable_csr get_balid_tltable_csr%ROWTYPE;

BEGIN
hr_utility.set_location('pay_ip_startup_util.update_bal_type_tl',10);

  FOR l_record in get_balid_btable_csr LOOP

	OPEN get_balid_tltable_csr(p_legislation_code, l_record.bname, l_record.language);
	fetch get_balid_tltable_csr  INTO rec_tltable_csr;

	if get_balid_tltable_csr%found then

		UPDATE pay_balance_types_tl
		SET balance_name = l_record.tname,
		    reporting_name = l_record.reporting_name,
		    source_lang = l_record.source_lang
		WHERE balance_type_id = rec_tltable_csr.tlid
		AND   language = l_record.language;

	end if;

	CLOSE get_balid_tltable_csr;

  END LOOP;

EXCEPTION
    WHEN OTHERS THEN
    IF get_balid_btable_csr%ISOPEN THEN
      CLOSE get_balid_btable_csr;
    END IF;
    IF get_balid_tltable_csr%ISOPEN THEN
      CLOSE get_balid_tltable_csr;
    END IF;

    RAISE_APPLICATION_ERROR(-20001, SQLERRM);

hr_utility.set_location('pay_ip_startup_util.update_bal_type_tl',20);

END update_bal_type_tl;

PROCEDURE create_runtype
	(p_legislation_code 		IN VARCHAR2) IS

CURSOR run_type_csr IS
  SELECT
    run_type_id, run_type_name, run_method, effective_start_date, effective_end_date,
    business_group_id, legislation_code, shortname, last_update_date, last_updated_by,
    last_update_login, created_by, creation_date, object_version_number
   FROM pay_run_types_f
   WHERE nvl(legislation_code,'X') = 'ZZ'
   AND business_group_id IS NULL and sysdate between effective_start_date and effective_end_date;


Cursor run_type_parent_csr (l_legislation_code IN VARCHAR2)  IS
   SELECT run_type_id parent_id
   FROM pay_run_types_f
   WHERE (run_type_name,shortname) IN (SELECT RUN_TYPE_NAME, shortname from pay_run_types_f
				       WHERE RUN_TYPE_ID IN (SELECT PARENT_RUN_TYPE_ID
 				                             FROM pay_run_type_usages_f
							     WHERE LEGISLATION_CODE = 'ZZ'
				                             AND sysdate BETWEEN EFFECTIVE_START_DATE
							     AND EFFECTIVE_END_DATE
							     AND business_group_id is null
							     )
				     AND sysdate BETWEEN effective_start_date AND effective_end_date
					)
   AND sysdate BETWEEN effective_start_date
   AND effective_end_date
   AND legislation_code = l_legislation_code
   AND business_group_id is NULL;

Cursor run_type_child_csr (l_legislation_code IN VARCHAR2) IS
  SELECT prtf1.run_type_id child_id  , prtuf.sequence sequence , prtf1.run_type_name run_type_name
   FROM pay_run_types_f prtf1, pay_run_types_f prtf2 , pay_run_type_usages_f prtuf
   WHERE (prtf1.run_type_name,prtf1.shortname) IN (SELECT RUN_TYPE_NAME, shortname
				       FROM pay_run_types_f
				       WHERE RUN_TYPE_ID IN (SELECT child_RUN_TYPE_ID
				                             FROM pay_run_type_usages_f
				                             WHERE parent_run_type_id in (SELECT distinct PARENT_RUN_TYPE_ID
 				                             FROM pay_run_type_usages_f
							     WHERE LEGISLATION_CODE = 'ZZ'
				                             AND sysdate BETWEEN EFFECTIVE_START_DATE
							     AND EFFECTIVE_END_DATE
							     AND business_group_id is null)
				                             AND legislation_code = 'ZZ'
				                             AND sysdate BETWEEN EFFECTIVE_START_DATE
							     AND EFFECTIVE_END_DATE
							     AND business_group_id is null
                                                            )
				     AND sysdate BETWEEN effective_start_date AND effective_end_date
				      )
  AND sysdate BETWEEN prtf1.effective_start_date
  AND prtf1.effective_end_date
  AND prtf1.legislation_code = l_legislation_code
  AND prtf1.business_group_id is NULL
  AND prtuf.legislation_code = 'ZZ'
  AND prtf2.RUN_TYPE_NAME = prtf1.RUN_TYPE_NAME
  AND prtf2.SHORTNAME = prtf1.SHORTNAME
  AND prtf2.business_group_id is NULL
  AND prtuf.legislation_code = prtf2.legislation_code
  AND prtf2.run_type_id in (prtuf.parent_run_type_id, prtuf.child_run_type_id);


--local variables for Run Types

l_rt_id                 pay_run_types_f.run_type_id%TYPE;
l_rt_ovn    	      	pay_run_types_f.object_version_number%TYPE;
l_rt_eff_start_date     pay_run_types_f.effective_start_date%TYPE;
l_rt_eff_end_date       pay_run_types_f.effective_end_date%TYPE;

--local variables for Run Type Usages

l_rtu_id        	 pay_run_type_usages_f.run_type_usage_id%TYPE;
l_rtu_ovn    		 pay_run_type_usages_f.object_version_number%TYPE;
l_rtu_eff_start_date     pay_run_type_usages_f.effective_start_date%TYPE;
l_rtu_eff_end_date       pay_run_type_usages_f.effective_end_date%TYPE;
l_process                VARCHAR2(100);


BEGIN
-- Run Types

hr_utility.set_location('pay_ip_startup_util.create_runtype',10);

   write_log('LOG',NULL,NULL,NULL);
   write_log('LOG','PAY_34016_IP_CALL_PROC','PAY_RUN_TYPE_API',NULL);

   hr_startup_data_api_support.enable_startup_mode('STARTUP');
   hr_startup_data_api_support.create_owner_definition('PAY');

   FOR rec IN run_type_csr LOOP

	BEGIN
		SELECT run_type_id, object_version_number
		INTO l_rt_id, l_rt_ovn
		FROM pay_run_types_f
		WHERE run_type_name = rec.run_type_name
		AND shortname = rec.shortname
		AND legislation_code = p_legislation_code
		AND sysdate between effective_start_date and effective_end_date
		AND business_group_id IS NULL;


	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		      write_log ('LOG','PAY_34012_IP_INS_DATA', 'Run Type ', rec.run_type_name);
		      write_log ('OUTPUT','PAY_34012_IP_INS_DATA', 'Run Type ', rec.run_type_name);
		      pay_run_type_api.create_run_type (
		          p_effective_date            =>  g_start_of_time
		         ,p_run_type_name             =>  rec.run_type_name
		         ,p_run_method                =>  rec.run_method
		         ,p_business_group_id         =>  NULL
		         ,p_legislation_code          =>  p_legislation_code
		         ,p_shortname                 =>  rec.shortname
		         ,p_run_type_id               =>  l_rt_id
		         ,p_effective_start_date      =>  l_rt_eff_start_date
		         ,p_effective_end_date        =>  l_rt_eff_end_date
		         ,p_object_version_number     =>  l_rt_ovn
		         ) ;
	END;

    END LOOP;

-- Run Type Usages

hr_utility.set_location('pay_ip_startup_util.create_runtype',20);

    write_log('LOG',NULL,NULL,NULL);
    write_log('LOG','PAY_34016_IP_CALL_PROC','PAY_RUN_TYPE_USAGE_API',NULL);

    FOR rec_parent IN run_type_parent_csr (p_legislation_code)  LOOP
  	FOR rec_child IN run_type_child_csr(p_legislation_code) LOOP


	BEGIN
		SELECT run_type_usage_id, object_version_number
		INTO l_rtu_id, l_rtu_ovn
		FROM pay_run_type_usages_f
		WHERE parent_run_type_id = rec_parent.parent_id
		AND child_run_type_id = rec_child.child_id
		AND legislation_code = p_legislation_code
		AND sysdate between effective_start_date and effective_end_date
		AND business_group_id IS NULL;
		      l_process := 'Run Type Usage :' || rec_child.run_type_name;
 		      write_log('LOG','PAY_34015_IP_UPD_TABLE',l_process,NULL);
		      pay_run_type_usage_api.update_run_type_usage (
		          p_effective_date            =>  g_start_of_time
			 ,p_datetrack_update_mode     =>  'CORRECTION'
		         ,p_run_type_usage_id	      =>  l_rtu_id
			 ,p_object_version_number     =>  l_rtu_ovn
			 ,p_sequence		      =>  rec_child.sequence
		         ,p_business_group_id         =>  NULL
		         ,p_legislation_code          =>  p_legislation_code
		         ,p_effective_start_date      =>  l_rtu_eff_start_date
		         ,p_effective_end_date        =>  l_rtu_eff_end_date
		         ) ;
		EXCEPTION
		WHEN NO_DATA_FOUND THEN
  		     write_log ('LOG','PAY_34012_IP_INS_DATA', 'Run Type Usage', rec_child.run_type_name);
  		     write_log ('OUTPUT','PAY_34012_IP_INS_DATA', 'Run Type Usage', rec_child.run_type_name);
		     pay_run_type_usage_api.create_run_type_usage (
		         p_effective_date             =>  g_start_of_time
		        ,p_parent_run_type_id         =>  rec_parent.parent_id
		        ,p_child_run_type_id          =>  rec_child.child_id
		        ,p_sequence                   =>  rec_child.sequence
		        ,p_business_group_id          =>  NULL
		        ,p_legislation_code           =>  p_legislation_code
		        ,p_run_type_usage_id          =>  l_rtu_id
		        ,p_effective_start_date       =>  l_rtu_eff_start_date
		        ,p_effective_end_date         =>  l_rtu_eff_end_date
		        ,p_object_version_number      =>  l_rtu_ovn
		        );
	END;

          END LOOP;	  --child
    END LOOP; --parent

hr_utility.set_location('pay_ip_startup_util.create_runtype',30);

EXCEPTION
	WHEN OTHERS THEN
		IF run_type_csr%ISOPEN THEN
			CLOSE run_type_csr;
		END IF;

		IF run_type_parent_csr%ISOPEN THEN
			CLOSE run_type_parent_csr;
		END IF;

		IF run_type_child_csr%ISOPEN THEN
			CLOSE run_type_child_csr;
		END IF;

		RAISE_APPLICATION_ERROR(-20001, SQLERRM);
END create_runtype;
--

-- Bug 4159036. Create Balance Attribute Definitions

PROCEDURE create_bal_att_def
          (p_legislation_code in varchar2) IS
--
CURSOR get_bal_att_def IS
  SELECT
        attribute_name, alterable, user_attribute_name
  FROM pay_bal_attribute_definitions
  WHERE nvl(legislation_code,'X') = 'ZZ'
  AND business_group_id IS NULL;
--
BEGIN
--
  hr_utility.set_location('pay_ip_startup_util.create_bal_att_def',10);

  write_log('LOG',NULL,NULL,NULL);
  write_log ('LOG','PAY_34011_IP_INS_DATA_IN_TABLE', 'Balance Attribute Definitions', 'PAY_BAL_ATTRIBUTE_DEFINITIONS');

  FOR rec IN  get_bal_att_def LOOP

  write_log ('LOG','PAY_34012_IP_INS_DATA', 'Balance Attribute Definition', rec.attribute_name);

     PAY_BALANCES_UPLOAD_PKG.PAY_BAL_ADE_LOAD_ROW
          (
            p_ATTRIBUTE_NAME         => rec.attribute_name
           ,p_LEGISLATION_CODE       => p_legislation_code
           ,p_BUSINESS_GROUP_NAME    => null
           ,p_ALTERABLE              => rec.alterable
           ,p_user_attribute_name    => rec.user_attribute_name
           ,p_OWNER                  => 'SEED'
          );

  END LOOP;

  hr_utility.set_location('pay_ip_startup_util.create_bal_att_def',20);
--
EXCEPTION
  when others then
    if get_bal_att_def%isopen then
      close get_bal_att_def;
    end if;

    RAISE_APPLICATION_ERROR(-20001, SQLERRM);
--
END create_bal_att_def;
--

-- Updating Run Types TL Table

PROCEDURE update_run_type_tl
          (p_legislation_code	IN VARCHAR2) IS

CURSOR get_runid_btable_csr IS
  SELECT  b.run_type_id bid , b.run_type_name bname,
          t.language, t.run_type_name tname, t.shortname, t.source_lang
  FROM    pay_run_types_f_tl t, pay_run_types_f b
  WHERE   t.run_type_id = b.run_type_id
  AND     b.legislation_code = 'ZZ'
  AND     b.business_group_id IS NULL
  AND     sysdate BETWEEN b.effective_start_date AND b.effective_end_date ;

CURSOR get_runid_tltable_csr(l_legislation_code VARCHAR2, l_name VARCHAR2, l_language VARCHAR2) IS
  SELECT  t.run_type_id tlid
  FROM    pay_run_types_f_tl t, pay_run_types_f b
  WHERE   b.run_type_name = l_name
  AND     b.legislation_code = l_legislation_code
  AND     b.business_group_id IS NULL
  AND     t.run_type_id = b.run_type_id
  AND     t.language = l_language ;

rec_tltable_csr get_runid_tltable_csr%ROWTYPE;

BEGIN

hr_utility.set_location('pay_ip_startup_util.update_run_type_tl',10);

  FOR l_record in get_runid_btable_csr LOOP

	OPEN get_runid_tltable_csr(p_legislation_code, l_record.bname, l_record.language) ;
	fetch get_runid_tltable_csr INTO rec_tltable_csr ;

	if get_runid_tltable_csr%found then

		UPDATE pay_run_types_f_tl
		SET run_type_name = l_record.tname,
			shortname = l_record.shortname,
			source_lang = l_record.source_lang
		WHERE run_type_id = rec_tltable_csr.tlid
		AND language = l_record.language;

        end if;

	CLOSE get_runid_tltable_csr;

  END LOOP;

hr_utility.set_location('pay_ip_startup_util.update_run_type_tl',20);
EXCEPTION
    WHEN OTHERS THEN
    IF get_runid_btable_csr%ISOPEN THEN
       CLOSE get_runid_btable_csr;
    END IF;
    IF get_runid_tltable_csr%ISOPEN THEN
       CLOSE get_runid_tltable_csr;
    END IF;
    RAISE_APPLICATION_ERROR(-20001, SQLERRM);

END update_run_type_tl;

-- ----------------------------------------------------------------------
-- Main Procedure through which all process is done in the required order
-- This Setup gets the values for legislation_code and Currency from
-- the concurrent request and creates the required data.
-- ----------------------------------------------------------------------

PROCEDURE setup (p_errbuf			OUT NOCOPY VARCHAR2,
		 p_retcode			OUT NOCOPY NUMBER,
		 p_legislation_code		IN VARCHAR2,
		 p_currency_code		IN VARCHAR2,
		 p_Tax_Year			IN VARCHAR2,
		 p_install_tax_unit		IN VARCHAR2,
                 p_action_parameter_group_id 	IN NUMBER) IS

 l_id_flex_num NUMBER(15);
 l_Tax_Year	DATE;
 l_territory    FND_TERRITORIES_TL.TERRITORY_SHORT_NAME%TYPE;
 l_territory_with_code VARCHAR2(100);
 l_payroll_installed   VARCHAR2(1);
 l_segment_used        NUMBER;--Bug#4938455. Changed varchar2 to number.
 l_structure_code  fnd_id_flex_structures.id_flex_structure_code%type;

 CURSOR csr_payroll_installed is
   select 1 from fnd_product_installations
   where application_id = 801
   and status = 'I';

 cursor csr_flex_struct (p_id_flex_num number) is
   select id_flex_structure_code
    from  fnd_id_flex_structures
    where id_flex_code = 'SCL'
    and   id_flex_num = p_id_flex_num;

BEGIN

hr_utility.set_location('pay_ip_startup_util.setup',10);
IF check_to_install(p_legislation_code) THEN

-- Check if logging of message is required.
	g_logging := logging(p_action_parameter_group_id);

	SELECT territory_short_name, territory_short_name || ' (' || territory_code || ')'
	INTO l_territory, l_territory_with_code
	FROM fnd_territories_vl
	WHERE territory_code = p_legislation_code;


--Clearing all HRMS HR_S tables
  write_log('OUTPUT','PAY_34022_IP_LEG_INS_BEGINS', l_territory_with_code ,to_char(sysdate,'dd-Mon-yyyy hh:mi:ss'));
  hr_utility.set_location('pay_ip_startup_util.setup',20);
  write_log('LOG',NULL,NULL,NULL);
  write_log('LOG','PAY_34000_IP_TRUNCATE_TABLES','HR_S%',NULL);
  clear_shadow_tables;

--Moving data to shadow table

  hr_utility.set_location('pay_ip_startup_util.setup',30);
  write_log('LOG',NULL,NULL,NULL);
  write_log('LOG','PAY_34009_IP_MOVE_TO_HR_S',NULL,NULL);
  move_to_shadow_tables(p_legislation_code, p_install_tax_unit);

  l_Tax_Year := fnd_date.canonical_to_date(p_Tax_Year);

  write_log('LOG',NULL,NULL,NULL);
  write_log('LOG','PAY_34008_IP_INS_LEG_RULE', 'Tax Year', NULL);
  create_leg_rule(p_legislation_code => p_legislation_code,
  		  p_rule_type        => 'L',
  		  p_rule_mode        =>  to_char(l_Tax_Year,'dd/mm'));
--
-- Inserted legislation rule for currency. Bug No 3720975.
--
  write_log('LOG',NULL,NULL,NULL);
  write_log('LOG','PAY_34008_IP_INS_LEG_RULE', 'DC', NULL);
  create_leg_rule(p_legislation_code => p_legislation_code,
  		  p_rule_type        => 'DC',
  		  p_rule_mode        =>  p_currency_code);


  open csr_payroll_installed;
  fetch csr_payroll_installed into l_payroll_installed;

  if csr_payroll_installed%found then
	  write_log('LOG','PAY_34008_IP_INS_LEG_RULE', 'I', NULL);
	  create_leg_rule(p_legislation_code => p_legislation_code,
  			  p_rule_type        => 'I',
  			  p_rule_mode        => 'N');
  end if;

  close csr_payroll_installed;

  write_log('LOG','PAY_34008_IP_INS_LEG_RULE', 'Run Type', NULL);
  create_leg_rule(p_legislation_code => p_legislation_code,
  		  p_rule_type        => 'RUN_TYPE_FLAG',
  		  p_rule_mode        =>  'Y');

  write_log('LOG','PAY_34008_IP_INS_LEG_RULE', 'Tax Unit', NULL);
  create_leg_rule(p_legislation_code => p_legislation_code,
  		  p_rule_type        => 'TAX_UNIT',
  		  p_rule_mode        =>  'N');

  write_log('LOG','PAY_34008_IP_INS_LEG_RULE', 'BAL_INIT_VALIDATION', NULL);
  create_leg_rule(p_legislation_code => p_legislation_code,
  		  p_rule_type        => 'BAL_INIT_VALIDATION',
  		  p_rule_mode        =>  'N');

  write_log('LOG','PAY_34008_IP_INS_LEG_RULE', 'ACTION_CONTEXTS', NULL);
  create_leg_rule(p_legislation_code => p_legislation_code,
  		  p_rule_type        => 'ACTION_CONTEXTS',
  		  p_rule_mode        =>  'Y');

  write_log('LOG','PAY_34008_IP_INS_LEG_RULE', 'PAYWSACT_SOE', NULL);
  create_leg_rule(p_legislation_code => p_legislation_code,
  		  p_rule_type        => 'PAYWSACT_SOE',
  		  p_rule_mode        =>  'N');

  -- Setting the rule mode of PAYWSRQP_DS and SOE to 'Y' for bug 3286741

  write_log('LOG','PAY_34008_IP_INS_LEG_RULE', 'PAYWSRQP_DS', NULL);
  create_leg_rule(p_legislation_code => p_legislation_code,
  		  p_rule_type        => 'PAYWSRQP_DS',
  		  p_rule_mode        =>  'Y');

  write_log('LOG','PAY_34008_IP_INS_LEG_RULE', 'SOE', NULL);
  create_leg_rule(p_legislation_code => p_legislation_code,
  		  p_rule_type        => 'SOE',
  		  p_rule_mode        =>  'Y');

  write_log('LOG','PAY_34008_IP_INS_LEG_RULE', 'RETROELEMENT_CHECK', NULL);
  create_leg_rule(p_legislation_code => p_legislation_code,
                  p_rule_type        => 'RETROELEMENT_CHECK',
                  p_rule_mode        =>  'Y');

  IF p_install_tax_unit = 'Y' THEN

    create_leg_rule(p_legislation_code => p_legislation_code,
                    p_rule_type        => 'TAX_UNIT',
                    p_rule_mode        =>  'Y');

    hr_utility.set_location('pay_ip_startup_util.setup',40);
    write_log('LOG',NULL,NULL,NULL);
    write_log('LOG','PAY_34007_IP_CREATE_FLEX',p_Legislation_Code ||
                                                    '_STATUTORY_INFO', NULL);

    /* Identify if a non standard structure has already been
       created for this legislation (Bugfix 3070623).  If so, then
       skip the creation of the flexfields and set a flag to ensure the
       segment creation is also skipped                                */

    SELECT MIN(id_flex_num)
    INTO   l_id_flex_num
    FROM   fnd_id_flex_structures
    WHERE  id_flex_code = 'SCL'
    AND    id_flex_structure_code like
                                   p_legislation_code||'_STATUTORY_INFO'||'%';

    IF l_id_flex_num IS NULL THEN
      l_id_flex_num := create_key_flexfield
        (p_appl_short_name	=> 'PER',
	 p_flex_code		=> 'SCL',
         p_structure_code	=> p_legislation_code || '_STATUTORY_INFO',
         p_structure_title	=> p_legislation_code || ' Statutory Info.',
         p_description		=> 'SCL KeyFlex Structure for ' || l_territory,
         p_view_name		=> '',
         p_freeze_flag		=> 'Y',
         p_enabled_flag		=> 'Y',
         p_cross_val_flag	=> 'Y',
         p_freeze_rollup_flag	=> 'N',
         p_dynamic_insert_flag	=> 'Y',
         p_shorthand_enabled_flag => 'N',
         p_shorthand_prompt	=> '',
         p_shorthand_length	=> 10);
    END IF;

    write_log('LOG','PAY_34008_IP_INS_LEG_RULE', 'S', NULL);
    create_leg_rule
	 (p_legislation_code => p_legislation_code,
	  p_rule_type	     => 'S',
	  p_rule_mode        => l_id_flex_num);

    write_log('LOG','PAY_34008_IP_INS_LEG_RULE', 'SDL', NULL);
    create_leg_rule
	 (p_legislation_code => p_legislation_code,
	  p_rule_type	     => 'SDL',
	  p_rule_mode        => 'A');

    /* Only attempt the creation of the Tax Unit in Segment1 if this
       segment is not already in use                                 */

    select min(1)
    into   l_segment_used
    FROM   fnd_id_flex_segments
    WHERE  id_flex_num = l_id_flex_num
    AND    id_flex_code = 'SCL'
    AND    application_column_name = 'SEGMENT1';

    IF l_segment_used IS NULL THEN

        -- Bug 4544374. The structure code needs to be derived
        -- since the process may be trying to re-use the customer defined
        -- structure.

        open csr_flex_struct(p_id_flex_num => l_id_flex_num);
        fetch csr_flex_struct into l_structure_code;
        close csr_flex_struct;

	create_flex_segments
                (p_appl_Short_Name	=> 'PER',
		 p_flex_code		=> 'SCL',
                 p_structure_code	=> l_structure_code,
                 p_segment_name 	=> 'Tax_Unit',
                 p_column_name  	=> 'SEGMENT1',
                 p_segment_number  	=> 1,
                 p_enabled_flag 	=> 'Y',
                 p_displayed_flag 	=> 'Y',
                 p_indexed_flag   	=> 'Y',
                 p_value_set  		=> 'HR_TAX_UNIT_NAME',
                 p_display_size 	=> 25,
                 p_description_size 	=> 25,
                 p_concat_size 		=> 25,
                 p_lov_prompt  		=> 'Tax Unit',
                 p_window_prompt 	=> 'Tax Unit');
    END IF;

  hr_utility.set_location('pay_ip_startup_util.setup',50);
  END IF;

--Create FlexField

  hr_utility.set_location('pay_ip_startup_util.setup',40);
  write_log('LOG',NULL,NULL,NULL);
  write_log('LOG','PAY_34007_IP_CREATE_FLEX',p_Legislation_Code || '_BANK_DETAILS', NULL);
  l_id_flex_num := create_key_flexfield
        (p_appl_short_name	=> 'PAY',
	 p_flex_code		=> 'BANK',
         p_structure_code	=> p_legislation_code || '_BANK_DETAILS',
         p_structure_title	=> p_legislation_code || ' Bank Details',
         p_description		=> p_legislation_code || ' Bank Details',
         p_view_name		=> '',
         p_freeze_flag		=> 'Y',
         p_enabled_flag		=> 'Y',
         p_cross_val_flag	=> 'Y',
         p_freeze_rollup_flag	=> 'N',
         p_dynamic_insert_flag	=> 'Y',
         p_shorthand_enabled_flag => 'N',
         p_shorthand_prompt	=> '',
         p_shorthand_length	=> 10);

  hr_utility.set_location('pay_ip_startup_util.setup',50);
  write_log('LOG','PAY_34008_IP_INS_LEG_RULE',p_Legislation_Code || '_BANK_DETAILS', NULL);
  create_leg_rule
	 (p_legislation_code => p_legislation_code,
	  p_rule_type	     => 'E',
	  p_rule_mode        => l_id_flex_num);

  write_out;

--Updating shadow table

  hr_utility.set_location('pay_ip_startup_util.setup',60);
  write_log('LOG',NULL,NULL,NULL);
  write_log('LOG','PAY_34014_IP_UPD_LEG_CURR',p_Legislation_Code,p_currency_code);
  update_shadow_tables(p_legislation_code, p_currency_code);

-- Inserting in to HR_S_HISTORY table

  hr_utility.set_location('pay_ip_startup_util.setup',70);
  write_log('LOG',NULL,NULL,NULL);
  write_log('LOG','PAY_34011_IP_INS_DATA_IN_TABLE','record','HR_S_HISTORY');
  insert_history_table(p_legislation_code);

-- Moving to Main Tables
  hr_utility.set_location('pay_ip_startup_util.setup',80);
  write_log('LOG',NULL,NULL,NULL);
  write_log('LOG','PAY_34016_IP_CALL_PROC','HR_LEGISLATION.INSTALL',NULL);
  BEGIN
    move_to_main_tables;
    EXCEPTION
      WHEN OTHERS THEN
        g_logging := 'Y';
        write_log('LOG','PAY_34018_IP_HR_STU_EXCEPTION',NULL,NULL);
        RAISE_APPLICATION_ERROR(-20001, SQLERRM);
  END;

  write_log('LOG',NULL,NULL,NULL);
  write_log('LOG','PAY_34017_IP_UPD_TL_TABLE',NULL,NULL);

  hr_utility.set_location('pay_ip_startup_util.setup',90);
  write_log('LOG','PAY_34015_IP_UPD_TABLE','PAY_ELEMENT_CLASSIFICATIONS_TL',NULL);
  update_ele_class_tl(p_legislation_code);

  hr_utility.set_location('pay_ip_startup_util.setup',100);
  write_log('LOG','PAY_34015_IP_UPD_TABLE','PAY_BALANCE_TYPES_TL',NULL);
  update_bal_type_tl(p_legislation_code);

--Run Types
  hr_utility.set_location('pay_ip_startup_util.setup',110);
  create_runtype(p_legislation_code);

  hr_utility.set_location('pay_ip_startup_util.setup',120);
  write_log('LOG','PAY_34015_IP_UPD_TABLE','PAY_RUN_TYPES_TL',NULL);
  update_run_type_tl(p_legislation_code);

-- Bug 4159036. Deliver Balance Attribute Definitions

-- Balance Attribute Definitions
  hr_utility.set_location('pay_ip_startup_util.setup',130);
  create_bal_att_def(p_legislation_code);

-- Element Templates and other data needed for the legislation to use
-- Element Design Wizard(EDW)

  hr_utility.set_location('pay_ip_startup_util.setup', 135);
  pay_create_elemnt_tmplt_record.create_all_templates
                        (p_legislation_code,p_currency_code);

  p_retcode := 0;

  COMMIT;

  write_log('OUTPUT',NULL,NULL,NULL);
  write_log('OUTPUT','PAY_34023_IP_LEG_INS_ENDS',NULL,NULL);

  hr_utility.set_location('pay_ip_startup_util.setup',140);

ELSE
  p_retcode := 2;
END IF;

  hr_utility.set_location('pay_ip_startup_util.setup',150);

EXCEPTION
  WHEN OTHERS THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,  SQLERRM);
    FND_FILE.PUT_LINE(FND_FILE.LOG,  '');
    ROLLBACK;
    p_errbuf  := NULL;
    p_retcode := 2;
  RAISE_APPLICATION_ERROR(-20001, SQLERRM);
END setup;

END pay_ip_startup_util;

/
