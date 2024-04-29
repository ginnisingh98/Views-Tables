--------------------------------------------------------
--  DDL for Package HZ_MERGE_DUP_CHECK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_MERGE_DUP_CHECK" AUTHID CURRENT_USER AS
/* $Header: ARHMDUPS.pls 120.5 2005/09/13 08:41:45 rbandi noship $ */

FUNCTION check_cust_account_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id	  IN OUT  NOCOPY NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  x_return_status IN OUT  NOCOPY VARCHAR2)
RETURN VARCHAR2;

FUNCTION check_cust_account_role_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id	  IN OUT  NOCOPY NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  x_return_status IN OUT  NOCOPY VARCHAR2)
RETURN VARCHAR2;

FUNCTION check_cust_account_site_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id	  IN OUT  NOCOPY NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  x_return_status IN OUT  NOCOPY VARCHAR2)
RETURN VARCHAR2;

FUNCTION check_financial_profile_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id	  IN OUT  NOCOPY NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  x_return_status IN OUT  NOCOPY VARCHAR2)
RETURN VARCHAR2;

FUNCTION check_contact_point_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id	  IN OUT  NOCOPY NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  p_owner_table_name IN     VARCHAR2,
  x_return_status IN OUT  NOCOPY VARCHAR2)
RETURN VARCHAR2;

FUNCTION check_references_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id	  IN OUT  NOCOPY NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  x_return_status IN OUT  NOCOPY VARCHAR2)
RETURN VARCHAR2;

FUNCTION check_certification_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id	  IN OUT  NOCOPY NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  x_return_status IN OUT  NOCOPY VARCHAR2)
RETURN VARCHAR2;

FUNCTION check_credit_ratings_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id	  IN OUT  NOCOPY NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  x_return_status IN OUT  NOCOPY VARCHAR2)
RETURN VARCHAR2;

FUNCTION check_security_issued_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id	  IN OUT  NOCOPY NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  x_return_status IN OUT  NOCOPY VARCHAR2)
RETURN VARCHAR2;

FUNCTION check_financial_reports_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id	  IN OUT  NOCOPY NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  x_return_status IN OUT  NOCOPY VARCHAR2)
RETURN VARCHAR2;

FUNCTION check_org_indicators_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id	  IN OUT  NOCOPY NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  x_return_status IN OUT  NOCOPY VARCHAR2)
RETURN VARCHAR2;

FUNCTION check_ind_reference_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id	  IN OUT  NOCOPY NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  x_return_status IN OUT  NOCOPY VARCHAR2)
RETURN VARCHAR2;

FUNCTION check_per_interest_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id	  IN OUT  NOCOPY NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  x_return_status IN OUT  NOCOPY VARCHAR2)
RETURN VARCHAR2;

FUNCTION check_citizenship_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id	  IN OUT  NOCOPY NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  x_return_status IN OUT  NOCOPY VARCHAR2)
RETURN VARCHAR2;

FUNCTION check_education_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id	  IN OUT  NOCOPY NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  x_return_status IN OUT  NOCOPY VARCHAR2)
RETURN VARCHAR2;

FUNCTION check_emp_history_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id	  IN OUT  NOCOPY NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  x_return_status IN OUT  NOCOPY VARCHAR2)
RETURN VARCHAR2;

FUNCTION check_work_class_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id	  IN OUT  NOCOPY NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  x_return_status IN OUT  NOCOPY VARCHAR2)
RETURN VARCHAR2;

FUNCTION check_languages_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id	  IN OUT  NOCOPY NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  x_return_status IN OUT  NOCOPY VARCHAR2)
RETURN VARCHAR2;

FUNCTION check_party_site_use_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id	  IN OUT  NOCOPY NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  x_return_status IN OUT  NOCOPY VARCHAR2)
RETURN VARCHAR2;

FUNCTION check_party_site_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id	  IN OUT  NOCOPY NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  x_return_status IN OUT  NOCOPY VARCHAR2)
RETURN VARCHAR2;

FUNCTION check_financial_number_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id	  IN OUT  NOCOPY NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  x_return_status IN OUT  NOCOPY VARCHAR2)
RETURN VARCHAR2;

FUNCTION check_org_contact_role_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id	  IN OUT  NOCOPY NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  x_return_status IN OUT  NOCOPY VARCHAR2)
RETURN VARCHAR2;

FUNCTION check_code_assignment_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id	  IN OUT  NOCOPY NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  p_owner_table_name IN     VARCHAR2,
  x_return_status IN OUT  NOCOPY VARCHAR2)
RETURN VARCHAR2;

FUNCTION check_contact_preference_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id         IN OUT  NOCOPY NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  p_owner_table_name IN     VARCHAR2,
  x_return_status IN OUT  NOCOPY VARCHAR2)
RETURN VARCHAR2;

--Bug Fix 4577535
FUNCTION check_address_dup(
  p_from_location_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id	  IN OUT   NOCOPY NUMBER,
  p_from_fk_id    IN       NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN       NUMBER:=FND_API.G_MISS_NUM,
  x_return_status IN OUT   NOCOPY VARCHAR2)
RETURN VARCHAR2;


END HZ_MERGE_DUP_CHECK;

 

/
