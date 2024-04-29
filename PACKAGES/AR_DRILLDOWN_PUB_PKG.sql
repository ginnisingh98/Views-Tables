--------------------------------------------------------
--  DDL for Package AR_DRILLDOWN_PUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_DRILLDOWN_PUB_PKG" AUTHID CURRENT_USER AS
/* $Header: ARXLADDS.pls 120.2 2003/08/28 21:34:37 hyu noship $ */
--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person         Date
-- ---------      ------
-- Shishir Joshi  27-AUG-2003
-- Enter package declarations as shown below

PROCEDURE drilldown
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
      ,p_function_name          IN  OUT  NOCOPY VARCHAR2
      ,p_parameters             IN  OUT  NOCOPY VARCHAR2
);

END AR_DRILLDOWN_PUB_PKG; -- Package spec

 

/
