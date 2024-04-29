--------------------------------------------------------
--  DDL for Package HZ_CUSTOMER_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_CUSTOMER_INT" AUTHID CURRENT_USER AS
/*$Header: ARHCUSIS.pls 120.9 2006/01/09 15:33:58 nkanbapu ship $*/

  FUNCTION get_cust_account_id(p_orig_system_customer_ref IN VARCHAR2)
    RETURN NUMBER;
 /* bug 4454799 - added argument for org_id below. */
  FUNCTION get_cust_acct_site_id(p_orig_system_address_ref IN VARCHAR2,p_org_id IN NUMBER)
    RETURN NUMBER;
  FUNCTION get_cust_account_role_id(p_orig_system_contact_ref IN VARCHAR2)
    RETURN NUMBER;
  FUNCTION get_prel_party_id(p_orig_system_contact_ref IN VARCHAR2)
    RETURN NUMBER;
/* bug 4454799 - added argument for org_id below. */
  FUNCTION get_party_site_id(p_orig_system_address_ref IN VARCHAR2,p_org_id IN NUMBER)
 RETURN NUMBER;
  FUNCTION get_party_id(p_orig_system_customer_ref IN VARCHAR2) RETURN NUMBER;
  FUNCTION validate_contact_ref(p_orig_system_contact_ref IN VARCHAR2)
    RETURN VARCHAR2;
  FUNCTION get_language_code(p_language IN VARCHAR2) RETURN VARCHAR2;
  PROCEDURE validate_ccid(p_request_id NUMBER);
  FUNCTION validate_ref_party(p_orig_system_customer_ref IN VARCHAR2,
                              p_insert_update_flag IN VARCHAR2)
    RETURN VARCHAR2;
  FUNCTION get_cust_party_id(p_orig_system_customer_ref IN VARCHAR2,
                             p_request_id IN NUMBER)
    RETURN NUMBER;
  FUNCTION get_subject_id(p_orig_system_contact_ref IN VARCHAR2,
                          p_request_id IN NUMBER)
    RETURN NUMBER;
  FUNCTION get_prel_party_id(p_orig_system_contact_ref IN VARCHAR2,
                             p_request_id IN NUMBER)
    RETURN NUMBER;
  FUNCTION get_prel_id(p_orig_system_contact_ref IN VARCHAR2,
                       p_request_id IN NUMBER)
    RETURN NUMBER;
 /* bug 4454799 - added argument for org_id below. */
  FUNCTION val_bill_to_orig_address_ref(p_orig_system_customer_ref IN VARCHAR2,
                                        p_orig_system_address_ref IN VARCHAR2,
                                        p_bill_to_orig_address_ref IN VARCHAR2,
                                        p_orig_system_parent_ref IN VARCHAR2,
					p_org_id IN NUMBER,
                                        req_id IN NUMBER) RETURN VARCHAR2;

  FUNCTION val_party_number(p_orig_system_customer_ref IN VARCHAR2,
                            p_orig_system_party_ref IN VARCHAR2,
                            p_party_number IN VARCHAR2,
                            p_rowid IN ROWID,
                            req_id IN NUMBER) RETURN VARCHAR2;

  FUNCTION val_party_numb_ref(p_orig_system_customer_ref IN VARCHAR2,
                            p_orig_system_party_ref IN VARCHAR2,
                            p_party_number IN VARCHAR2,
                            p_rowid IN ROWID,
                            req_id IN NUMBER) RETURN VARCHAR2;

  FUNCTION val_cust_number(p_orig_system_customer_ref IN VARCHAR2,
                            p_customer_number IN VARCHAR2,
                            p_rowid IN ROWID,
                            req_id IN NUMBER) RETURN VARCHAR2;

/* bug 4454799 - added argument for org_id below. */
  FUNCTION val_party_site_number(p_orig_system_address_ref IN VARCHAR2,
                            p_party_site_number IN VARCHAR2,
                            p_rowid IN ROWID,
			    p_org_id IN NUMBER,
                            req_id IN NUMBER) RETURN VARCHAR2;

  FUNCTION get_ultimate_parent_party_ref(p_orig_system_customer_ref VARCHAR2)
    RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES (get_ultimate_parent_party_ref, WNDS,WNPS,RNPS);

  --This function is created to make the customer interface run
  --in parallel.
  FUNCTION check_assigned_worker(p_string VARCHAR2,
                                 p_total_workers NUMBER,
                                 p_worker NUMBER) RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES (check_assigned_worker,WNDS,WNPS,RNPS);

  --This procedure has been created for customer interface master
  --conc program.
  PROCEDURE conc_main (errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2);

  -- Bug 2092530 - Overload conc_main such that it can be called with a
  --               create_reciprocal_flag parameter
  PROCEDURE conc_main (errbuf                  OUT NOCOPY VARCHAR2,
                       retcode                 OUT NOCOPY VARCHAR2,
                       p_create_reciprocal_flag IN VARCHAR2,
                       p_org_id                 IN NUMBER := 0 );
  -- Bug 1795019

/* bug 4454799 - added argument for org_id below. */
  FUNCTION validate_profile(v_insert_update_flag IN VARCHAR,
                            v_orig_system_customer_ref IN VARCHAR,
                            v_orig_system_address_ref IN VARCHAR,
			    v_org_id IN NUMBER,
                            v_request_id IN NUMBER )
    RETURN VARCHAR2 ;

  FUNCTION validate_address(p_location_structure_id IN NUMBER,
                            p_creation_date IN DATE,
                            p_state IN VARCHAR2,
                            p_city IN VARCHAR2,
                            p_county IN VARCHAR2,
                            p_postal_code IN VARCHAR2,
                            p_province IN VARCHAR2 default null)
    RETURN VARCHAR2 ;
 /* bug 4454799 - added argument for org_id below. */
  FUNCTION validate_tax_location( p_orig_system_address_ref IN VARCHAR2,
                                  p_country IN VARCHAR2,
                                  p_city IN VARCHAR2,
                                  p_state IN VARCHAR2,
                                  p_county IN VARCHAR2,
                                  p_province IN VARCHAR2,
                                  p_postal_code IN VARCHAR2,
				  p_org_id IN NUMBER
                                   )
   RETURN VARCHAR2 ;

   PROCEDURE update_org_ue_profile (
     p_request_id                    IN     NUMBER
   );

   PROCEDURE update_per_ue_profile (
     p_request_id                    IN     NUMBER
   );

  FUNCTION get_contact_name(p_orig_system_contact_ref IN VARCHAR2,
                            p_orig_system_customer_ref IN VARCHAR2
                           )
  RETURN VARCHAR2 ;

  PROCEDURE update_party_prel_name( p_party_id IN NUMBER );

 /* bug 4454799 - added argument for org_id below. */
  FUNCTION validate_primary_flag( p_orig_system_customer_ref IN VARCHAR2,
                                  p_site_use_code IN VARCHAR2,
				  p_org_id IN NUMBER
                                  )
  RETURN VARCHAR2;

  FUNCTION get_account_party_id (p_orig_system_customer_ref IN VARCHAR2,
  				 p_person_flag  IN VARCHAR2 DEFAULT 'N',
  				 p_ref_flag   IN VARCHAR2 DEFAULT 'C')  RETURN NUMBER;

  PROCEDURE sync_tax_profile(p_request_id IN NUMBER);
  PROCEDURE insert_ci_party_usages(p_request_id IN NUMBER);
  PROCEDURE insert_nci_party_usages(p_request_id IN NUMBER);
  /*Bug: 4588090*/
  PROCEDURE set_primary_flag( p_orig_system_customer_ref IN VARCHAR2,
                              p_site_use_code IN VARCHAR2,
                              p_org_id IN NUMBER );
  PRAGMA RESTRICT_REFERENCES (get_account_party_id,WNDS,WNPS,RNPS);


END HZ_CUSTOMER_INT;

 

/
