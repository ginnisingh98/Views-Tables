--------------------------------------------------------
--  DDL for Package Body ARI_REG_VERIFICATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARI_REG_VERIFICATIONS_PKG" as
/* $Header: ARIREGVB.pls 120.1.12010000.2 2010/04/30 11:19:55 avepati ship $ */

G_PKG_NAME      CONSTANT VARCHAR(31) := 'ARI_REG_VERIFICATIONS_PKG';

------------------------------------------------------------------------------
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

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
                     x_created_by                                NUMBER)
------------------------------------------------------------------------------
IS

 l_procedure_name   VARCHAR2(31)    := '.Insert_Row';
 l_debug_info      VARCHAR2(200);
BEGIN

  ----------------------------------------------------------------------------
  l_debug_info := 'In debug mode, log we have entered this procedure';
  ----------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(G_PKG_NAME || l_procedure_name || '+');
  END IF;

  ----------------------------------------------------------------------------
  l_debug_info := 'Insert into ari_reg_verifications_gt';
  ----------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(l_debug_info);
  END IF;

  INSERT INTO ARI_REG_VERIFICATIONS_GT(
                     client_ip_address,
                     question,
                     expected_answer,
                     first_answer,
                     second_answer,
                     third_answer,
                     number_of_attempts,
                     result_code,
                     customer_id,
                     customer_site_use_id,
                     last_update_login,
                     last_update_date,
                     last_updated_by,
                     creation_date,
                     created_by
   ) VALUES (
                     x_client_ip_address,
                     x_question,
                     x_expected_answer,
                     x_first_answer,
                     x_second_answer,
                     x_third_answer,
                     x_number_of_attempts,
                     x_result_code,
                     x_customer_id,
                     x_customer_site_use_id,
                     x_last_update_login,
                     x_last_update_date,
                     x_last_updated_by,
                     x_creation_date,
                     x_created_by);

   l_debug_info := 'After insert';

   IF (PG_DEBUG = 'Y') THEN
      arp_standard.debug(l_debug_info);
   END IF;

  ----------------------------------------------------------------------------
  l_debug_info := 'In debug mode, log that we have exited this procedure';
  ----------------------------------------------------------------------------
  IF (PG_DEBUG = 'Y') THEN
     arp_standard.debug(G_PKG_NAME || l_procedure_name || '-');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
         IF (SQLCODE <> -20001) THEN
           IF (PG_DEBUG = 'Y') THEN
              arp_standard.debug('Unexpected Exception in ' || G_PKG_NAME || l_procedure_name);
              arp_standard.debug('Debug: ' || l_debug_info);
              arp_standard.debug(SQLERRM);
           END IF;
	       FND_MESSAGE.SET_NAME ('AR','ARI_REG_DISPLAY_UNEXP_ERROR');
           FND_MSG_PUB.ADD;
         END IF;
       APP_EXCEPTION.RAISE_EXCEPTION;
END Insert_Row;

END ARI_REG_VERIFICATIONS_PKG;

/
