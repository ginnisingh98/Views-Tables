--------------------------------------------------------
--  DDL for Package POS_PARTY_MANAGEMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_PARTY_MANAGEMENT_PKG" AUTHID CURRENT_USER as
--$Header: POSPMNGS.pls 120.4 2005/10/07 02:45:25 bitang noship $

PROCEDURE classify_party
  ( p_party_id           IN  NUMBER
  , p_category           IN  VARCHAR2
  , p_code               IN  VARCHAR2
  , p_primary_flag       IN  VARCHAR2
  , x_code_assignment_id OUT NOCOPY NUMBER
  , x_status             OUT NOCOPY VARCHAR2
  , x_exception_msg      OUT NOCOPY VARCHAR2
  );

PROCEDURE classify_party
  ( p_party_id      IN  NUMBER
  , p_category      IN  VARCHAR2
  , p_code          IN  VARCHAR2
  , x_status        OUT NOCOPY VARCHAR2
  , x_exception_msg OUT NOCOPY VARCHAR2
  );

PROCEDURE pos_create_organization
  (p_organization_name   IN  VARCHAR2,
   p_duns_number         IN  NUMBER   DEFAULT NULL,
   p_corp_hq_flag        IN  VARCHAR2 DEFAULT NULL,
   p_sic_code            IN  VARCHAR2 DEFAULT NULL,
   x_org_party_id        OUT NOCOPY NUMBER,
   x_org_party_number    OUT NOCOPY VARCHAR2,
   x_profile_id          OUT NOCOPY NUMBER,
   x_exception_msg       OUT NOCOPY VARCHAR2,
   x_status              OUT NOCOPY VARCHAR2
   );

-- in release 12, this procedure should not be used to create supplier user
-- it should be used for boot strap enterprise user for Sourcing
PROCEDURE pos_create_user
  (p_username      IN  VARCHAR2,
   p_firstname     IN  VARCHAR2,
   p_lastname      IN  VARCHAR2,
   p_emailaddress  IN  VARCHAR2,
   x_party_id      OUT NOCOPY NUMBER, -- party id of the user
   x_exception_msg OUT NOCOPY VARCHAR2,
   x_status        OUT NOCOPY VARCHAR2
   );

FUNCTION check_for_vendor_user(p_username IN VARCHAR2) RETURN NUMBER;

FUNCTION check_for_enterprise_user(p_username IN VARCHAR2) RETURN NUMBER;

FUNCTION get_emp_or_ctgt_wrkr_pty_id (p_userid IN NUMBER) RETURN NUMBER;

-- bitang: the implementation here works for release 11.5.10 but might be changed for r12
-- due to TCA Supplier project.
-- this procedure is used in POSISPAB.pls. need to find out whether the
-- caller passes in a supplier username or internal user name
FUNCTION get_job_title_for_user (p_user_id IN NUMBER) RETURN VARCHAR2;

-- return Y if the employee_id column of the user is not null
-- and the employee_id is a current employee or contingent worker;
-- N otherwise.
FUNCTION is_user_employee_cont_worker(p_userid IN NUMBER)
  RETURN VARCHAR2;

END POS_PARTY_MANAGEMENT_PKG;

 

/
