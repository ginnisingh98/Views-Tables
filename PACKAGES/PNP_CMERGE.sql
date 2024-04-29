--------------------------------------------------------
--  DDL for Package PNP_CMERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PNP_CMERGE" AUTHID CURRENT_USER AS
/* $Header: PNCMERGS.pls 115.5 2004/05/06 17:57:19 kkhegde ship $ */

PROCEDURE merge ( req_id NUMBER,
                  set_num NUMBER,
                  process_mode VARCHAR2);

PROCEDURE update_leases ( req_id       NUMBER,
                          set_num      NUMBER,
                          process_mode VARCHAR2);

PROCEDURE update_tenancies ( req_id       NUMBER,
                             set_num      NUMBER,
                             process_mode VARCHAR2);

PROCEDURE update_tenancies_history ( req_id       NUMBER,
                                     set_num      NUMBER,
                                     process_mode VARCHAR2);

PROCEDURE update_term_templates ( req_id       NUMBER,
                                  set_num      NUMBER,
                                  process_mode VARCHAR2);

PROCEDURE update_payment_terms ( req_id       NUMBER,
                                 set_num      NUMBER,
                                 process_mode VARCHAR2);

PROCEDURE update_payment_items ( req_id       NUMBER,
                                 set_num      NUMBER,
                                 process_mode VARCHAR2);

PROCEDURE update_rec_agreements ( req_id       NUMBER,
                                  set_num      NUMBER,
                                  process_mode VARCHAR2);

PROCEDURE update_rec_arcl_dtln ( req_id       NUMBER,
                                 set_num      NUMBER,
                                 process_mode VARCHAR2);

PROCEDURE update_rec_expcl_dtln ( req_id       NUMBER,
                                  set_num      NUMBER,
                                  process_mode VARCHAR2);

PROCEDURE update_rec_period_lines ( req_id       NUMBER,
                                    set_num      NUMBER,
                                    process_mode VARCHAR2);

PROCEDURE update_space_assign_cust ( req_id       NUMBER,
                                     set_num      NUMBER,
                                     process_mode VARCHAR2);

END PNP_CMERGE;

 

/
