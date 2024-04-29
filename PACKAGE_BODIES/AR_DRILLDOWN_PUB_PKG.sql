--------------------------------------------------------
--  DDL for Package Body AR_DRILLDOWN_PUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_DRILLDOWN_PUB_PKG" AS
/* $Header: ARXLADDB.pls 120.5.12010000.4 2008/11/24 08:36:31 mpsingh ship $*/
-- MODIFICATION HISTORY
-- Person         Date
-- ---------      ------
-- Shishir Joshi  27-AUG-2003
-- Enter procedure, function bodies as shown below

PROCEDURE DRILLDOWN
      (p_application_id         IN              INTEGER    DEFAULT NULL
      ,p_ledger_id              IN              INTEGER    DEFAULT NULL
      ,p_legal_entity_id        IN              INTEGER    DEFAULT NULL
      ,p_entity_code            IN              VARCHAR2   DEFAULT NULL
      ,p_event_class_code       IN              VARCHAR2   DEFAULT NULL
      ,p_event_type_code        IN              VARCHAR2   DEFAULT NULL
      ,p_source_id_int_1        IN              INTEGER    DEFAULT NULL
      ,p_source_id_int_2        IN              INTEGER    DEFAULT NULL
      ,p_source_id_int_3        IN              INTEGER    DEFAULT NULL
      ,p_source_id_int_4        IN              INTEGER    DEFAULT NULL
      ,p_source_id_char_1       IN              VARCHAR2   DEFAULT NULL
      ,p_source_id_char_2       IN              VARCHAR2   DEFAULT NULL
      ,p_source_id_char_3       IN              VARCHAR2   DEFAULT NULL
      ,p_source_id_char_4       IN              VARCHAR2   DEFAULT NULL
      ,p_security_id_int_1      IN              INTEGER    DEFAULT NULL
      ,p_security_id_int_2      IN              INTEGER    DEFAULT NULL
      ,p_security_id_int_3      IN              INTEGER    DEFAULT NULL
      ,p_security_id_char_1     IN              VARCHAR2   DEFAULT NULL
      ,p_security_id_char_2     IN              VARCHAR2   DEFAULT NULL
      ,p_security_id_char_3     IN              VARCHAR2   DEFAULT NULL
      ,p_valuation_method       IN              VARCHAR2   DEFAULT NULL
      ,p_user_interface_type    IN  OUT  NOCOPY VARCHAR2
      ,p_function_name               IN  OUT  NOCOPY VARCHAR2
      ,p_parameters             IN  OUT  NOCOPY VARCHAR2
      )
IS

BEGIN

  IF (p_application_id = 222) THEN

    IF    (p_entity_code = 'TRANSACTIONS') THEN

     -- For Bug 5337978 - Removed the logic that fetches inventory_org_id based
     -- based on Multi-Org org_id, since org context is not determined yet for MOAC.
     -- Moved the logic to pre-form trigger.

      p_user_interface_type := 'FORM';
      p_function_name       := 'XLA_ARXTWMAI';
      p_parameters          :=  ' FORM_USAGE_MODE="GL_DRILLDOWN"'||
	                            ' AR_TRANSACTION_ID="' ||TO_CHAR(p_source_id_int_1)||'"';

    ELSIF (p_entity_code = 'RECEIPTS') THEN

      p_user_interface_type := 'FORM';
      p_function_name       := 'XLA_ARXRWMAI';
      p_parameters          := ' FORM_USAGE_MODE="GL_DRILLDOWN"'||
                               ' AR_RECEIPT_ID="' || TO_CHAR(p_source_id_int_1)||'"'
                                    ||' ORG_ID="'||TO_CHAR(p_security_id_int_1)||'"';

    ELSIF (p_entity_code = 'ADJUSTMENTS') THEN

      p_user_interface_type := 'FORM';
      p_function_name       := 'XLA_ARXTWADA';
      p_parameters          := ' FORM_USAGE_MODE="GL_DRILLDOWN"'||
                               ' AR_ADJUSTMENT_ID="' || TO_CHAR(p_source_id_int_1)||'"'
                                    ||' ORG_ID="'||TO_CHAR(p_security_id_int_1)||'"';
  -- bug 7434092
  ELSIF (p_entity_code = 'BILLS_RECEIVABLE') THEN
     p_user_interface_type := 'FORM';
     p_function_name       := 'XLA_ARBRMAIN';
     p_parameters          :=  ' FORM_USAGE_MODE="GL_DRILLDOWN"'||
                             ' FP_CUSTOMER_TRX_ID="' ||TO_CHAR(p_source_id_int_1)||'"'
                                ||' ORG_ID="'||TO_CHAR(p_security_id_int_1)||'"';


    END IF;

      --dbms_output.put_line('p_parameters = ' || p_parameters);
   END IF;
END drilldown;
END AR_DRILLDOWN_PUB_PKG;

/
