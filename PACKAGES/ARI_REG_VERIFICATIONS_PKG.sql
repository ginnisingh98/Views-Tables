--------------------------------------------------------
--  DDL for Package ARI_REG_VERIFICATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARI_REG_VERIFICATIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: ARIREGVS.pls 120.1.12010000.2 2010/04/30 11:16:36 avepati ship $ */

------------------------------------------------------------------------------
PROCEDURE Insert_Row(
                     x_rowid                         IN OUT NOCOPY      VARCHAR2,
                     x_client_ip_address                         VARCHAR2,
                     x_question                                  VARCHAR2,
                     x_expected_answer                           VARCHAR2,
                     x_first_answer                              VARCHAR2 DEFAULT NULL,
                     x_second_answer                             VARCHAR2 DEFAULT NULL,
                     x_third_answer                              VARCHAR2 DEFAULT NULL,
                     x_number_of_attempts                        NUMBER   DEFAULT 0,
                     x_result_code                               VARCHAR2 DEFAULT NULL,
                     x_customer_id                               NUMBER,
                     x_customer_site_use_id                      NUMBER DEFAULT NULL,
                     x_last_update_login                         NUMBER,
                     x_last_update_date                          DATE,
                     x_last_updated_by                           NUMBER,
                     x_creation_date                             DATE,
                     x_created_by                                NUMBER);
------------------------------------------------------------------------------
END ARI_REG_VERIFICATIONS_PKG;

/
