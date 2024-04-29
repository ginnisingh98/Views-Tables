--------------------------------------------------------
--  DDL for Package ARI_SELF_REG_CONFIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARI_SELF_REG_CONFIG" AUTHID CURRENT_USER AS
/* $Header: ARISRCGS.pls 120.1.12010000.2 2010/03/19 11:32:24 avepati ship $ */


/* -------------------------------------------------------------
 *                User Configuration Section
 * -------------------------------------------------------------
 * The section below can be modified to configure iReceivables
 * Self-Registration to Customer's needs.
 */

---------------------------------------------------------------------------------------------------------
--This procedure can be customised to specify access verification questions
--when the user selects the location of the customer requesting access.
PROCEDURE  verify_customer_site_access( p_customer_id          IN VARCHAR2,
                                   p_customer_site_use_id IN VARCHAR2 DEFAULT NULL,
                                   x_verify_access        OUT NOCOPY ARI_SELF_REGISTRATION_PKG.VerifyAccessTable,
                                   x_attempts             OUT NOCOPY NUMBER);
---------------------------------------------------------------------------------------------------------
--This procedure can be customised to specify access verification questions
--when the user selects the customer requesting access.
PROCEDURE  validate_cust_detail_access( p_customer_id          IN VARCHAR2,
                                           x_verify_access        OUT NOCOPY ARI_SELF_REGISTRATION_PKG.VerifyAccessTable,
                                           x_attempts             OUT NOCOPY NUMBER);
---------------------------------------------------------------------------------------------------------
--This function returns the customer id of the customer that the user requests access to.
--This can be customised to return the customer id in case of custom search queries.
--(Future Enhancement)
FUNCTION  get_customer_id ( p_search_type VARCHAR2,
                            p_search_number  VARCHAR2) RETURN NUMBER;
---------------------------------------------------------------------------------------------------------
--This function can be customised to specify if the password is to automatically generated
--at a customer/site level.
FUNCTION auto_generate_passwd_option (p_customer_id  IN  VARCHAR2,
                                 p_customer_site_use_id IN  VARCHAR2)
                                 RETURN VARCHAR2;
---------------------------------------------------------------------------------------------------------

--This function returns the self registration custom question answere defined
--at a customer/site level.
FUNCTION validate_access (   p_customer_id           IN  VARCHAR2,
                                          p_customer_site_use_id  IN  VARCHAR2 DEFAULT NULL,
                                          p_answer_table          IN  VARCHAR2,
                                          p_answer_column         IN  VARCHAR2,
                                          p_answer_join_column    IN  VARCHAR2,
                                          p_hz_join_column        IN  VARCHAR2 ) RETURN VARCHAR2;
---------------------------------------------------------------------------------------------------------
END ari_self_reg_config;

/
