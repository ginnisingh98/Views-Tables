--------------------------------------------------------
--  DDL for Package PAYWSFGT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAYWSFGT_PKG" AUTHID CURRENT_USER AS
-- $Header: pyfgtpkg.pkh 115.3 2002/12/10 18:44:42 dsaxby noship $
--
--
-- +---------------------------------------------------------------------------+
-- | NAME       : write_fgt_check                                              |
-- | DESCRIPTION: Used by the Dynamic Trigger code generator to write the call |
-- |              to the Functional Area checking routine into the source code |
-- |              of the trigger                                               |
-- | PARAMETERS : p_id      - The primary key of the event record which is     |
-- |                          being used to generate this trigger              |
-- |              p_sql     - The PL/SQL code to add the call to               |
-- |              p_has_bus - Flag to indicate if the base table has a         |
-- |                          mandatory business_group_id column               |
-- |              p_has_pay - Flag to indicate if the base table has a         |
-- |                          mandatory payroll_id column                      |
-- | RETURNS    : The modified PL/SQL code, via the OUT parameter              |
-- | RAISES     : None - n/a                                                   |
-- +---------------------------------------------------------------------------+
  PROCEDURE write_fgt_check(
    p_id      IN     NUMBER,
    p_sql     IN OUT NOCOPY VARCHAR2,
    p_has_bus IN     BOOLEAN,
    p_has_pay IN     BOOLEAN
  );
--
-- +---------------------------------------------------------------------------+
-- | NAME       : trigger_is_not_enabled                                       |
-- | DESCRIPTION: Used by the triggers that have been Dynamically Generated    |
-- |              to determine whether they should execute the logic           |
-- |              that they contain or not. See the description of the table   |
-- |              PAY_FUNCTIONAL_USAGES for an explaination of the logic that  |
-- |              this function encapsulates.                                  |
-- | PARAMETERS : p_event_id          - The primary key of the event record    |
-- |                                    from which this trigger was generated  |
-- |              p_legislation_code  - The legislation value of the current   |
-- |                                    record                                 |
-- |              p_business_group_id - The current record's business group ID |
-- |              p_payroll_id        - The payroll ID of the current record   |
-- | RETURNS    : TRUE if the trigger logic _SHOULD NOT_ be executed, FALSE    |
-- |              otherwise. See the PAY_FUNCTIONAL_USAGES table description   |
-- |              for the logic which determines this. The logic is reversed   |
-- |              from that in the table description to make the generated code|
-- |              simpler.                                                     |
-- | RAISES     : None - n/a                                                   |
-- +---------------------------------------------------------------------------+
  FUNCTION trigger_is_not_enabled(
    p_event_id          IN NUMBER,
    p_legislation_code  IN VARCHAR2 DEFAULT NULL,
    p_business_group_id IN NUMBER   DEFAULT NULL,
    p_payroll_id        IN NUMBER   DEFAULT NULL
  ) RETURN BOOLEAN;
--
END paywsfgt_pkg;

 

/
