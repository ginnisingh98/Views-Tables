--------------------------------------------------------
--  DDL for Package ECE_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECE_RULES_PKG" AUTHID CURRENT_USER AS
-- $Header: ECERULES.pls 120.3.12010000.2 2008/11/24 18:21:49 akemiset ship $

g_pkg_name              CONSTANT VARCHAR2(30) := 'ECE_RULES_PKG';
g_file_name             CONSTANT VARCHAR2(12) := 'ECERULEB.pls';

-- Global constants representing the type of different rules and actions.

g_p_trading_partner     CONSTANT VARCHAR2(80) := 'INVALID_TRADING_PARTNER';
g_p_test_prod           CONSTANT VARCHAR2(80) := 'TEST_PROD_DISCREPANCY';
g_p_invalid_addr        CONSTANT VARCHAR2(80) := 'INVALID_ADDRESS';
g_c_value_required      CONSTANT VARCHAR2(80) := 'VALUE_REQUIRED';
g_c_simple_lookup       CONSTANT VARCHAR2(80) := 'SIMPLE_LOOKUP';
g_c_valueset            CONSTANT VARCHAR2(80) := 'VALUESET';
g_c_null_dependency     CONSTANT VARCHAR2(80) := 'NULL_DEPENDENCY';
g_c_predefined_list     CONSTANT VARCHAR2(80) := 'PREDEFINED_LIST';
g_c_null_default        CONSTANT VARCHAR2(80) := 'NULL_DEFAULT';
g_c_datatype_checking   CONSTANT VARCHAR2(80) := 'DATATYPE_CHECKING';

g_disabled              CONSTANT VARCHAR2(20) := 'DISABLED';
g_insert                CONSTANT VARCHAR2(20) := 'INSERT';
g_skip_doc              CONSTANT VARCHAR2(20) := 'SKIP_DOCUMENT';
g_abort                 CONSTANT VARCHAR2(20) := 'ABORT';
g_log_only              CONSTANT VARCHAR2(20) := 'LOG_ONLY';
g_new                   CONSTANT VARCHAR2(20) := 'NEW';
g_reprocess             CONSTANT VARCHAR2(20) := 'RE_PROCESS';

g_process_rule          CONSTANT VARCHAR2(20) := 'PROCESS';
g_column_rule           CONSTANT VARCHAR2(20) := 'COLUMN';

g_bank                  CONSTANT VARCHAR2(15) := 'BANK';
g_customer              CONSTANT VARCHAR2(15) := 'CUSTOMER';
g_supplier              CONSTANT VARCHAR2(15) := 'SUPPLIER';
g_hr_location           CONSTANT VARCHAR2(15) := 'HR_LOCATION';

TYPE rule_violation_record_type is RECORD (
   violation_id          ece_rule_violations.violation_id%TYPE,
   document_id           ece_rule_violations.document_id%TYPE,
   stage_id              ece_rule_violations.stage_id%TYPE,
   interface_column_id   ece_rule_violations.interface_column_id%TYPE,
   rule_id               ece_rule_violations.rule_id%TYPE,
   transaction_type      ece_rule_violations.transaction_type%TYPE,
   document_number       ece_rule_violations.document_number%TYPE,
   violation_level       ece_rule_violations.violation_level%TYPE,
   ignore_flag           ece_rule_violations.ignore_flag%TYPE,
   message_text          ece_rule_violations.message_text%TYPE);

TYPE Rule_Violation_Table is TABLE of rule_violation_record_type index by BINARY_INTEGER;
g_party_name varchar2(32767);
g_party_number varchar2(32767);
g_rule_violation_tbl     Rule_Violation_Table;

-- Bug 2617428
Type address_rec is Record
(
  address_type		pls_integer,
  org_id                pls_integer,
  address_id            pls_integer,
  parent_id             pls_integer,
  tp_location_code      VARCHAR2(3200),
  tp_location_name      VARCHAR2(3200),
  tp_translator_code    VARCHAR2(3200),
  address_code          VARCHAR2(3200),
  address_line1         VARCHAR2(3200),
  address_line2         VARCHAR2(3200),
  address_line3         VARCHAR2(3200),
  address_line4         VARCHAR2(3200),
  address_line_alt      VARCHAR2(3200),
  city                  VARCHAR2(3200),
  county                VARCHAR2(3200),
  state                 VARCHAR2(3200),
  zip                   VARCHAR2(3200),
  province              VARCHAR2(3200),
  country               VARCHAR2(3200),
  region_1              VARCHAR2(3200),
  region_2              VARCHAR2(3200),
  region_3              VARCHAR2(3200)
);

Type address_tbl is table of address_rec index by BINARY_INTEGER;

g_address_tbl   address_tbl;

PROCEDURE Update_Status (
   p_transaction_type    IN      VARCHAR2,
   p_level               IN      NUMBER,
   p_valid_rule          IN      VARCHAR2,
   p_action              IN      VARCHAR2,
   p_interface_column_id IN      NUMBER DEFAULT NULL,
   p_rule_id             IN      NUMBER,
   p_stage_id            IN      NUMBER,
   p_document_id         IN      NUMBER,
   p_violation_level     IN      VARCHAR2,
   p_document_number     IN      VARCHAR2,
   p_msg_text            IN      VARCHAR2);

/*Bug 1854866
Assigned default values to the parameters
 p_init_msg_list,
 p_simulate
 p_commit
 p_validation_level
 of the procedure Validate_Process_Rules
 since the default values are assigned to these parameters
 in the package body
*/

/* Bug 2340691
   p_staging_tbl was modified to IN OUT NOCOPY
*/
PROCEDURE Validate_Process_Rules(
   p_api_version_number  IN      NUMBER,
   p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
   p_simulate            IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level    IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
   x_return_status       OUT NOCOPY    VARCHAR2,
   x_msg_count           OUT NOCOPY    NUMBER,
   x_msg_data            OUT NOCOPY    VARCHAR2,
   p_transaction_type    IN      VARCHAR2,
   p_address_type        IN      VARCHAR2,
   p_stage_id            IN      NUMBER,
   p_document_id         IN      NUMBER,
   p_document_number     IN      VARCHAR2,
   p_level               IN      NUMBER,
   p_map_id              IN      NUMBER,
   p_staging_tbl         IN OUT  NOCOPY ec_utils.mapping_tbl);


PROCEDURE Validate_Trading_Partner(
   p_transaction_type    IN      VARCHAR2,
   p_address_type        IN      VARCHAR2,
   p_level               IN      NUMBER,
   p_map_id              IN      NUMBER,
   p_staging_tbl         IN      ec_utils.mapping_tbl,
   x_tp_detail_id        OUT  NOCOPY   NUMBER,
   x_msg_text            OUT  NOCOPY   VARCHAR2,
   x_valid_rule          OUT  NOCOPY   VARCHAR2);


PROCEDURE Validate_Test_Prod(
   p_tp_detail_id        IN      NUMBER,
   p_level               IN      NUMBER,
   p_staging_tbl         IN      ec_utils.mapping_tbl,
   x_msg_text            OUT NOCOPY    VARCHAR2,
   x_valid_rule          OUT NOCOPY    VARCHAR2);

/*Bug 1854866
Assigned default values to the parameters
 p_init_msg_list,
 p_simulate
 p_commit
 p_validation_level
 of the procedure Validate_Column_Rules
 since the default values are assigned to these parameters
 in the package body
*/

/* Bug 1853627
   p_staging_tbl was modified to IN OUT NOCOPY
*/
PROCEDURE Validate_Column_Rules(
   p_api_version_number  IN      NUMBER,
   p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
   p_simulate            IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level    IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
   x_return_status       OUT NOCOPY    VARCHAR2,
   x_msg_count           OUT NOCOPY    NUMBER,
   x_msg_data            OUT NOCOPY    VARCHAR2,
   p_transaction_type    IN      VARCHAR2,
   p_stage_id            IN      NUMBER,
   p_document_id         IN      NUMBER,
   p_document_number     IN      VARCHAR2,
   p_level               IN      NUMBER,
   p_staging_tbl         IN OUT  NOCOPY ec_utils.mapping_tbl);


PROCEDURE Value_Required_Rule (
   p_column_name         IN      VARCHAR2,
   p_column_value        IN      VARCHAR2,
   x_valid_rule          OUT  NOCOPY   VARCHAR2,
   x_msg_text            OUT  NOCOPY   VARCHAR2);


PROCEDURE Simple_Lookup_Rule (
   p_column_name       IN      VARCHAR2,
   p_column_value      IN      VARCHAR2,
   p_rule_id           IN      NUMBER,
   x_valid_rule        OUT  NOCOPY   VARCHAR2,
   x_msg_text          OUT  NOCOPY   VARCHAR2);


PROCEDURE Valueset_Rule (
   p_column_name         IN      VARCHAR2,
   p_column_value        IN      VARCHAR2,
   p_rule_id             IN      NUMBER,
   x_valid_rule          OUT NOCOPY    VARCHAR2,
   x_msg_text            OUT NOCOPY    VARCHAR2);


PROCEDURE Null_Dependency_Rule (
   p_column_name         IN      VARCHAR2,
   p_column_value        IN      VARCHAR2,
   p_rule_id             IN      NUMBER,
   p_staging_tbl         IN      ec_utils.mapping_tbl,
   p_level               IN      NUMBER,
   x_valid_rule          OUT  NOCOPY   VARCHAR2,
   x_msg_text            OUT  NOCOPY   VARCHAR2);


PROCEDURE Predefined_List_Rule (
   p_column_name         IN      VARCHAR2,
   p_column_value        IN      VARCHAR2,
   p_rule_id             IN      NUMBER,
   x_valid_rule          OUT  NOCOPY   VARCHAR2,
   x_msg_text            OUT  NOCOPY   VARCHAR2);


PROCEDURE Null_Default_Rule (
   p_column_name         IN      VARCHAR2,
   p_column_value        IN      VARCHAR2,
   p_rule_id             IN      NUMBER,
   p_level               IN      NUMBER,
   p_staging_tbl         IN OUT NOCOPY ec_utils.mapping_tbl,
   x_valid_rule          OUT  NOCOPY   VARCHAR2,
   x_msg_text            OUT  NOCOPY   VARCHAR2);


PROCEDURE Datatype_Checking_Rule (
   p_column_datatype     IN      VARCHAR2,
   p_column_name         IN      VARCHAR2,
   p_column_value        IN      VARCHAR2,
   x_valid_rule          OUT  NOCOPY   VARCHAR2,
   x_msg_text            OUT  NOCOPY   VARCHAR2);


PROCEDURE Validate_Get_Address_Info (
   p_entity_id_pos           IN  NUMBER,
   p_org_id_pos              IN  NUMBER,
   p_addr_id_pos             IN  NUMBER,
   p_tp_location_code_pos    IN  NUMBER,
   p_tp_translator_code_pos  IN  NUMBER,
   p_tp_location_name_pos    IN  NUMBER,
   p_addr1_pos               IN  NUMBER,
   p_addr2_pos               IN  NUMBER,
   p_addr3_pos               IN  NUMBER,
   p_addr4_pos               IN  NUMBER,
   p_addr_alt_pos            IN  NUMBER,
   p_city_pos                IN  NUMBER,
   p_county_pos              IN  NUMBER,
   p_state_pos               IN  NUMBER,
   p_zip_pos                 IN  NUMBER,
   p_province_pos            IN  NUMBER,
   p_country_pos             IN  NUMBER,
   p_region1_pos             IN  NUMBER DEFAULT NULL,
   p_region2_pos             IN  NUMBER DEFAULT NULL,
   p_region3_pos             IN  NUMBER DEFAULT NULL,
   p_address                 IN  VARCHAR2);


PROCEDURE Validate_Ship_To_Address;

PROCEDURE Validate_Bill_To_Address;

PROCEDURE Validate_Sold_To_Address;

PROCEDURE Validate_Ship_From_Address;

PROCEDURE Validate_Bill_From_Address;

PROCEDURE Validate_Ship_To_Int_Address;

PROCEDURE Validate_Ship_To_Intrmd_Add;

PROCEDURE Validate_Bill_To_Int_Address;

PROCEDURE Validate_Ship_From_Int_Address;

PROCEDURE Validate_Bill_From_Int_Address;


PROCEDURE Validate_Form_Simple_Lookup (
   p_column_name       IN      VARCHAR2,
   p_table_name        IN      VARCHAR2,
   p_where_clause      IN      VARCHAR2,
   x_valid             OUT  NOCOPY   BOOLEAN);


PROCEDURE Get_Action_Ignore_Flag (
   x_action_code       OUT  NOCOPY   VARCHAR2,
   x_ignore_flag       OUT  NOCOPY   VARCHAR2);


END ECE_RULES_PKG;

/
