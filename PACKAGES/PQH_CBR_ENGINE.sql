--------------------------------------------------------
--  DDL for Package PQH_CBR_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_CBR_ENGINE" AUTHID CURRENT_USER as
/* $Header: pqcbreng.pkh 115.1 2003/02/08 00:50:56 sgoyal noship $ */

-- this record will contain details of the rule_attribute, so that we don't have to go back again
-- status will be updated with the result of attribute row run

  type t_rule_details is record (
    rule_set_id pqh_rule_sets.rule_set_id%type,
    rule_name pqh_rule_sets.rule_set_name%type,
    rule_applicability pqh_rule_sets.rule_applicability%type,
    rule_level_cd pqh_rule_sets.rule_level_cd%type,
    message_cd fnd_new_messages.message_name%type,
    txn_id number,
    entity_id number);

  type t_rule_matx is table of t_rule_details
   index by binary_integer ;

  type t_attr_row is record (
    attribute_id pqh_attributes.attribute_id%type,
    column_name pqh_attributes.column_name%type,
    column_type pqh_attributes.column_type%type,
    txn_catg_attribute_id number,
    entity_type varchar2(30),
    applicability varchar2(30));

  type t_attr_matx is table of t_attr_row
   index by binary_integer ;

  type t_cond_details is record (
    rule_attribute_id pqh_rule_attributes.rule_attribute_id%type,
    attribute_id pqh_attributes.attribute_id%type,
    column_type pqh_attributes.column_type%type,
    column_name pqh_attributes.column_name%type,
    operation_code pqh_rule_attributes.operation_code%type,
    attribute_value pqh_rule_attributes.attribute_value%type,
    transaction_value varchar2(400),
    status     varchar2(30));

  type t_cond_matx is table of t_cond_details
   index by binary_integer ;

--  globals which will be used by this package

  g_package varchar2(30) := 'PQH_CBR_ENGINE.';
  g_budget_id number;
  g_budget_version_id number;
  g_budget_entity varchar2(30);
  g_business_group_id number;
  g_folder_id number;
  g_budget_name varchar2(30);
  g_budget_currency varchar2(30);
  g_budget_start_date date;
  g_budget_end_date date;
  g_measurement_unit varchar2(80);
  g_budget_unit_type varchar2(15);
  g_budget_unit_name varchar2(80);
  g_budget_unit_num number;
  g_budget_unit_id number;
  g_folder_name pqh_budget_pools.name%type;

procedure populate_globals(p_transaction_id in number);

function get_transaction_value(p_entity_id in number,
                               p_attribute_id in number) return varchar2;
function check_attribute_result(p_rule_value     in varchar2,
                                p_txn_value      in varchar2,
                                p_operation_code in varchar2,
                                p_attribute_type in varchar2) return BOOLEAN;

-- routine, which will be called by page.
PROCEDURE apply_rules(p_transaction_type in varchar2,
                      p_business_group_id  IN Number,
                      p_transaction_id     IN number,
                      p_effective_date     IN date DEFAULT sysdate,
                      p_status_flag           OUT NOCOPY varchar2);

-- routine which cntrols reallocation related rule applications
PROCEDURE apply_CBR_realloc(p_transaction_id    IN number,
                            p_business_group_id IN number,
                            p_effective_date    IN DATE,
                            p_status_flag           OUT NOCOPY varchar2);

-- process rules are applied for donor/ receivers
PROCEDURE apply_defined_rules(p_transaction_id    IN number,
                              p_business_group_id IN number,
                              p_effective_date    IN DATE,
                              p_status_flag           OUT NOCOPY varchar2);

-- business rules related to Reallocation are applied
PROCEDURE apply_business_rules(p_transaction_id    IN number,
                               p_business_group_id IN number,
                               p_effective_date    IN DATE,
                               p_status_flag           OUT NOCOPY BOOLEAN);

-- populates valid rule conditions for an entity
procedure valid_rule_conditions(p_entity_type        in varchar2 ,
                                p_rule_set_id        in number,
                                p_rule_applicability in varchar2,
                                p_attr_matx          in t_attr_matx,
                                p_cond_matx             out NOCOPY t_cond_matx);

-- populates valid rules for an entity of a transaction folder
procedure valid_process_rules(p_transaction_id    in varchar2,
                              p_business_group_id in number,
                              p_rule_category     in varchar2,
                              p_effective_date    in date,
                              l_rule_matx            out NOCOPY t_rule_matx);
--
-- this procedure populates the attribute matrix, which is to be used for identifying which attribute
-- is used for which entity and applicability.
--
procedure populate_attr_matx(p_attr_matx out nocopy t_attr_matx);
--
--
-- This function will be checking that rule is applicable for the provided organization and details
--
function check_org_valid_rule(p_organization_id    in number,
                              p_rule_org_id        in number,
                              p_rule_applicability in varchar2,
                              p_rule_category      in varchar2,
                              p_rule_org_str_id    in number,
                              p_rule_start_org_id  in number) return boolean;
--
Procedure get_org_structure_version_id (p_org_structure_id         IN NUMBER,
                                        p_org_structure_version_id OUT nocopy  NUMBER);
--
-- This function checks whether for this org hier and start org rule exists for this category and applicability
--
function check_rule_existence(p_organization_structure_id in number,
                              p_starting_organization_id  in number,
                              p_business_group_id         in number,
                              p_rule_category             in varchar2,
                              p_rule_applicability        in varchar2) return boolean ;
end;

 

/
