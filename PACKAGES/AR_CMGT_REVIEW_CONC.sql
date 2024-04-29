--------------------------------------------------------
--  DDL for Package AR_CMGT_REVIEW_CONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_CMGT_REVIEW_CONC" AUTHID CURRENT_USER AS
/* $Header: ARCMPRCS.pls 120.1 2004/12/03 01:17:10 orashid noship $ */


PROCEDURE periodic_review(
       errbuf                           IN OUT NOCOPY VARCHAR2,
       retcode                          IN OUT NOCOPY VARCHAR2,
       p_review_cycle                   IN VARCHAR2,
       p_review_cycle_as_of_date        IN VARCHAR2,
       p_currency_code                  hz_cust_profile_amts.currency_code%type,
       p_cust_level                     IN VARCHAR2,
       p_check_list_id                  IN VARCHAR2,
       p_party_id   	                IN NUMBER,
       p_cust_account_id   	            IN NUMBER,
       p_credit_classification          IN VARCHAR2,
       p_profile_class_id   	        IN VARCHAR2,
       p_processing_option   	        IN VARCHAR2 );

END AR_CMGT_REVIEW_CONC;

 

/
