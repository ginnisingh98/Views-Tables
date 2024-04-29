--------------------------------------------------------
--  DDL for Package OZF_DRILLDOWN_PUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_DRILLDOWN_PUB_PKG" AUTHID CURRENT_USER AS
/* $Header: ozfpdrls.pls 120.0.12010000.1 2010/03/09 09:39:14 bkunjan noship $ */

---------------------------------------------------------------------
-- API Name
--     DRILLDOWN
--Type
--   Public
-- PURPOSE
--    This procedure procedure provides a public API for sla to return
--    the appropriate information via OUT parameters to open the
--    appropriate transaction form.
-- PARAMETERS
-- p_application_id     : Subledger application internal identifier
--   p_ledger_id          : Event ledger identifier
--   p_legal_entity_id    : Legal entity identifier
--   p_entity_code        : Event entity internal code
--   p_event_class_code   : Event class internal code
--   p_event_type_code    : Event type internal code
--   p_source_id_int_1    : Generic system transaction identifiers
--   p_source_id_int_2    : Generic system transaction identifiers
--   p_source_id_int_3    : Generic system transaction identifiers
--   p_source_id_int_4    : Generic system transaction identifiers
--   p_source_id_char_1   : Generic system transaction identifiers
--   p_source_id_char_2   : Generic system transaction identifiers
--   p_source_id_char_3   : Generic system transaction identifiers
--   p_source_id_char_4   : Generic system transaction identifiers
--   p_security_id_int_1  : Generic system transaction identifiers
--   p_security_id_int_2  : Generic system transaction identifiers
--   p_security_id_int_3  : Generic system transaction identifiers
--   p_security_id_char_1 : Generic system transaction identifiers
--   p_security_id_char_2 : Generic system transaction identifiers
--   p_security_id_char_3 : Generic system transaction identifiers
--   p_valuation_method   : Valuation Method internal identifier
--   p_user_interface_type: This parameter determines the user interface type.
--                          The possible values are FORM, HTML, or NONE.
--   p_function_name      : The name of the Oracle Application Object
--                          Library function defined to open the transaction
--                          form. This parameter is used only if the page
--                          is a FORM page.
--   p_parameters         : An Oracle Application Object Library Function
--                          can have its own arguments/parameters. SLA
--                          expects developers to return these arguments via
--                          p_parameters.
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE DRILLDOWN(
   p_application_id            IN              INTEGER
  ,p_ledger_id                 IN              INTEGER
  ,p_legal_entity_id           IN              INTEGER    DEFAULT NULL
  ,p_entity_code               IN              VARCHAR2
  ,p_event_class_code          IN              VARCHAR2
  ,p_event_type_code           IN              VARCHAR2
  ,p_source_id_int_1           IN              INTEGER    DEFAULT NULL
  ,p_source_id_int_2           IN              INTEGER    DEFAULT NULL
  ,p_source_id_int_3           IN              INTEGER    DEFAULT NULL
  ,p_source_id_int_4           IN              INTEGER    DEFAULT NULL
  ,p_source_id_char_1          IN              VARCHAR2   DEFAULT NULL
  ,p_source_id_char_2          IN              VARCHAR2   DEFAULT NULL
  ,p_source_id_char_3          IN              VARCHAR2   DEFAULT NULL
  ,p_source_id_char_4          IN              VARCHAR2   DEFAULT NULL
  ,p_security_id_int_1         IN              INTEGER    DEFAULT NULL
  ,p_security_id_int_2         IN              INTEGER    DEFAULT NULL
  ,p_security_id_int_3         IN              INTEGER    DEFAULT NULL
  ,p_security_id_char_1        IN              VARCHAR2   DEFAULT NULL
  ,p_security_id_char_2        IN              VARCHAR2   DEFAULT NULL
  ,p_security_id_char_3        IN              VARCHAR2   DEFAULT NULL
  ,p_valuation_method          IN              VARCHAR2   DEFAULT NULL
  ,p_user_interface_type       IN  OUT  NOCOPY VARCHAR2
  ,p_function_name             IN  OUT  NOCOPY VARCHAR2
  ,p_parameters                IN  OUT  NOCOPY VARCHAR2
);

---------------------------------------------------------------------
END OZF_DRILLDOWN_PUB_PKG;

/
