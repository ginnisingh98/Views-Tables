--------------------------------------------------------
--  DDL for Package PER_MANAGE_CONTRACTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_MANAGE_CONTRACTS_PKG" AUTHID CURRENT_USER AS
  /* $Header: pemancon.pkh 115.2 2002/12/06 11:56:23 pkakar noship $ */
  --
  --
  -- Returns a summary flag indicating the type of association between a person and their contracts.
  --
  -- 'N' - Person has no contracts.
  -- 'A' - Person has one or more contracts of which at least one covers an assignment.
  -- 'P' - Person has one of more contracts and none cover any assignments.
  --
  FUNCTION contract_association
  (p_person_id NUMBER) RETURN VARCHAR2;
  PRAGMA restrict_references(contract_association, WNPS, WNDS);
  --
  --
  -- Returns the flexfield structures for a business group.
  --
  PROCEDURE get_flex_structures
  (p_business_group_id      IN NUMBER
  ,p_grade_structure        IN OUT NOCOPY NUMBER
  ,p_people_group_structure IN OUT NOCOPY NUMBER
  ,p_job_structure          IN OUT NOCOPY NUMBER
  ,p_position_structure     IN OUT NOCOPY NUMBER);
  --
  --
  -- Calls hr_contract_api.update_contract in date-track CORRECTION mode for all records
  -- matching supplied contract_id argument, excluding that which matches the object_version_number argument,
  -- passing only the required arguements plus current values for doc_status and doc_status_date_change.
  --
  PROCEDURE update_contracts
  (p_contract_id                  IN      number
  ,p_object_version_number        IN OUT NOCOPY  number
  ,p_doc_status                   IN      varchar2
  ,p_doc_status_change_date       IN      date
  ,p_exclude_flag                 IN      char);
--
end per_manage_contracts_pkg;

 

/
