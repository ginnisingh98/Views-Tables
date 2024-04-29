--------------------------------------------------------
--  DDL for Package Body OZF_DRILLDOWN_PUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_DRILLDOWN_PUB_PKG" AS
/* $Header: ozfpdrlb.pls 120.0.12010000.2 2010/03/10 08:38:13 bkunjan noship $ */

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
)
IS

l_fund_id                    NUMBER;
l_custom_setup_id            NUMBER;
l_org_id                     NUMBER;

BEGIN

   p_user_interface_type := 'HTML';

   IF (p_event_class_code = 'ACCRUAL') THEN

      SELECT fund.fund_id, fund.custom_setup_id
      INTO l_fund_id, l_custom_setup_id
      FROM ozf_funds_utilized_all_b util, ozf_funds_all_b fund
      WHERE util.utilization_id = p_source_id_int_1
      AND util.fund_id = fund.fund_id;

         IF p_event_type_code = 'PAID_ADJUSTMENT' THEN --navigate to Budget Paid Checkbook UI

            p_parameters := '/OA_HTML/OA.jsp?OAFunc=OZF_FUND_PAIDCHK&PAGE.OBJ.ID_NAME0=objId&PAGE.OBJ.ID0=' || l_fund_id ||
	                    '&PAGE.OBJ.objType=FUND&PAGE.OBJ.ID_NAME1=utilizationId&PAGE.OBJ.ID1=' || p_source_id_int_1;

         ELSE --navigate to Budget Earned Checkbook UI

            p_parameters := '/OA_HTML/OA.jsp?OAFunc=OZF_FUND_EARNCHK&PAGE.OBJ.ID_NAME0=objId&PAGE.OBJ.ID0=' || l_fund_id ||
	                    '&PAGE.OBJ.ID_NAME1=customSetupId&PAGE.OBJ.ID1=' || l_custom_setup_id ||
			    '&PAGE.OBJ.objType=FUND&PAGE.OBJ.ID_NAME2=utilizationId&PAGE.OBJ.ID2=' || p_source_id_int_1;

         END IF;

      ELSIF (p_event_class_code = 'CLAIM_SETTLEMENT') THEN --navigate to Claim Detail UI

         SELECT custom_setup_id, org_id
           INTO l_custom_setup_id, l_org_id
           FROM ozf_claims_all
          WHERE claim_id = p_source_id_int_1;

         p_parameters := '/OA_HTML/OA.jsp?OAFunc=OZF_CLAM_DETL&PAGE.OBJ.ID_NAME0=objId&PAGE.OBJ.ID0=' || p_source_id_int_1 ||
	                 '&PAGE.OBJ.objType=CLAM&PAGE.OBJ.objAttribute=DETL&PAGE.OBJ.ID_NAME1=customSetupId&PAGE.OBJ.ID1=' || l_custom_setup_id ||
			 '&PAGE.OBJ.ID_NAME2=orgId&PAGE.OBJ.ID2=' || l_org_id;

      END IF;

EXCEPTION
  WHEN OTHERS THEN
    NULL;

END DRILLDOWN;
---------------------------------------------------------------------
END OZF_DRILLDOWN_PUB_PKG;

/
