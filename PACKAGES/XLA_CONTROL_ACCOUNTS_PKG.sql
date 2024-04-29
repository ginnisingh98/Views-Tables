--------------------------------------------------------
--  DDL for Package XLA_CONTROL_ACCOUNTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_CONTROL_ACCOUNTS_PKG" AUTHID CURRENT_USER AS
/* $Header: xlabacta.pkh 120.5 2003/07/09 08:32:11 aquaglia ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_control_accounts_pkg                                           |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Control Accounts Package                                       |
|                                                                       |
| HISTORY                                                               |
|    27-AUG-02 A.Quaglia      Created                                   |
|    10-DEC-02 A. Quaglia     Overloaded update_balance_flag with       |
|                             p_event_id,p_entity_id,p_application_id   |
|    12-DEC-02 A. Quaglia     update_balance_flag: added parameter      |
|                             p_application_id where missing, added     |
|                                                                       |
+======================================================================*/
   --
   -- Public constants
   --
   C_CONTROL_BALANCE_FLAG_PENDING     CONSTANT VARCHAR2(1) := 'P';

   C_IS_CONTROL_ACCOUNT               CONSTANT INTEGER     :=   0;
   C_NOT_CONTROL_ACCOUNT              CONSTANT INTEGER     :=   1;
   C_IS_CONTROL_ACCOUNT_OTHER_APP     CONSTANT INTEGER     :=   2;
   C_ERR_CONTROL_ACCOUNT              CONSTANT INTEGER     :=   3;

FUNCTION is_control_account
  ( p_code_combination_id     IN INTEGER
   ,p_natural_account         IN VARCHAR2
   ,p_ledger_id               IN INTEGER
   ,p_application_id          IN INTEGER
  ) RETURN INTEGER;
/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
|                                                                       |
| Description                                                           |
| -----------                                                           |
|                                                                       |
|                                                                       |
|  p_code_combination_id  can be NULL.                                  |
|                         If p_natural_account is NULL it  cannot be    |
|                         NULL.                                         |
|                         If p_natural_account is NOT NULL it must be   |
|                         NULL.                                         |
|                                                                       |
|  p_natural_account      can be NULL                                   |
|                         If p_code_combination_id is NULL it cannot be |
|                         NULL.                                         |
|                         If p_code_combination_id is NOT NULL it must  |
|                         be NULL.                                      |
|                                                                       |
|  p_ledger_id            can be NULL                                   |
|                         If p_natural_account is NOT NULL it cannot be |
|                         NULL.                                         |
|                         If p_code_combination_id is NOT NULL it must  |
|                         be NULL.                                      |
|                                                                       |
|  p_application_id       can be NULL.                                  |
|                                                                       |
|                                                                       |
|  If p_code_combination_id IS NOT NULL it checks whether the code      |
|  combination is flagged as control account.                           |
|                                                                       |
|  If p_natural_account is not null it checks whether the account       |
|  is flagged as control account, in the chart of accounts attached     |
|  to the ledger p_ledger_id.                                           |
|                                                                       |
|  If p_application_id is not null it checks whether the GL JE Source   |
|  Name attached to it in the table XLA_SUBLEDGERS is the one           |
|  associated to code combination or to the account.                    |
|                                                                       |
|                                                                       |
|  RETURNS:                                                             |
|                                                                       |
|  C_IS_CONTROL_ACCOUNT                                                 |
|    if the code combination or the natural account is a control        |
|    account. If p_application_id is NOT NULL, it must also be that     |
|    the value of the field JE_SOURCE_NAME in the table XLA_SUBLEDGERS  |
|    for that application_id must match the one for which the control   |
|    account is setup.                                                  |
|                                                                       |
|  C_NOT_CONTROL_ACCOUNT                                                |
|    if the code combination or the natural account are not flagged as  |
|    control account.                                                   |
|                                                                       |
|  C_IS_CONTROL_ACCOUNT_OTHER_APP                                       |
|    if the code combination or the natural account are flagged as      |
|    control account but the value of                                   |
|    the field JE_SOURCE_NAME in the table XLA_SUBLEDGERS for that      |
|    application_id does not match the one for which the control account|
|    or the code combination is setup.                                  |                                                                       |
|                                                                       |
|  C_ERR_CONTROL_ACCOUNT                                                |
|    in case of inconsistency in the input parameters                   |
|                                                                       |
|                                                                       |
|  The fastest response is given for the following pattern of           |
|  parameters (the one the Accounting Program uses):                    |
|   p_code_combination_id NOT NULL                                      |
|   p_application_id      NOT NULL                                      |
|  And within this scenario the most probable case is that              |
|  the code combination is not a control account.                       |
|                                                                       |
|                                                                       |
| Pseudo-code                                                           |
| -----------                                                           |
|                                                                       |
|  IF  p_code_combination_id IS NOT NULL                                |
|  AND p_natural_account IS NULL THEN                                   |
|      retrieve REFERENCE3 from GL_CODE_COMBINATIONS for the ccid       |
|         and store it in l_qualifier_value                             |
|      IF NVL(l_qualifier_value, 'N') = 'N' THEN                        |
|         RETURN 1                                                      |
|      END IF                                                           |
|      --From here on we are sure the ccid is a control one             |
|      IF p_application_id IS NOT NULL THEN                             |
|         retrieve JE_SOURCE_NAME into l_je_source from XLA_SUBLEDGERS  |
|         IF l_qualifier_value = l_je_source   THEN                     |
|            RETURN 0                                                   |
|         ELSE                                                          |
|            RETURN 2                                                   |
|         END IF                                                        |
|      ELSE --p_application_id is NULL                                  |
|         RETURN 0                                                      |
|      END IF                                                           |
|                                                                       |
|  ELSIF p_natural_account IS NOT NULL THEN                             |
|     IF p_ledger_id IS NULL                                            |
|     THEN                                                              |
|        RETURN 3                                                       |
|     END IF                                                            |
|     retrieve the chart_of_accounts_id of the ledger                   |
|     retrieve the control account segment qualifier value for the      |
|      account and store it in l_qualifier_value                        |
|     IF NVL(l_qualifier_value, 'N') IS NULL THEN                       |
|        RETURN 1                                                       |
|     END IF                                                            |
|     --From here on we are sure the account  is a control one          |
|     IF p_application_id IS NOT NULL THEN                              |
|         retrieve JE_SOURCE_NAME into l_je_source from XLA_SUBLEDGERS  |
|        IF l_qualifier_value = l_je_source   THEN                      |
|           RETURN 0                                                    |
|        ELSE                                                           |
|           RETURN 2                                                    |
|        END IF                                                         |
|     ELSE --p_application_id is NULL                                   |
|        RETURN 0                                                       |
|     END IF                                                            |
|                                                                       |
|  ELSE                                                                 |
|     RETURN 3                                                          |
|                                                                       |
|  END IF;                                                              |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
| Open issues                                                           |
| -----------                                                           |
|                                                                       |
|  MUST SOLVE                                                           |
|                                                                       |
|  - Why is je_source_name in gl_je_source varchar2(25)                 |
|       and je_source_name in xla_subledgers varchar2(30)?              |
|                                                                       |
|  - GL must resize REFERENCE3 column in GL_CODE_COMBINATIONS           |
|    table from VARCHAR2(1) to VARCHAR2(25)                             |
|                                                                       |
|  - How will it be possible to store the JE Source Name in the         |
|    compiled_value_attributes column of fnd_flex_values table ?        |
|                                                                       |
|  - Error treatment and return values.                                 |
|                                                                       |
|  - Implementation for p_natural_account NOT NULL not completed        |
|    (waiting feedback from GL).                                        |
|                                                                       |
|  NICE TO SOLVE                                                        |
|                                                                       |
|  -  The Accounting Program could pass the JE_SOURCE_NAME instead of   |
|     the APPLICATION_ID. This would avoid useless accesses  to the     |
|     XLA_SUBLEDGERS table for each code combination.                   |
|                                                                       |
|  -  The Accounting Program already validates the code_combination_id  |
|     through a GL/FND API. But this means that GL_CODE_COMBINATIONS is |
|     already accessed for the same record. If the REFERENCE fields     |
|     could be read during that first access and passed over to this    |
|     function there would be an important performance gain and issue 2 |
|     would be avoided.                                                 |
|     If this cannot be done, should we implement a cache for the       |
|     code combinations?                                                |
|                                                                       |
+======================================================================*/

FUNCTION update_balance_flag ( p_application_id  IN INTEGER
                              ,p_ae_header_id    IN INTEGER
                              ,p_ae_line_num     IN INTEGER
                             )
RETURN BOOLEAN;

FUNCTION update_balance_flag ( p_event_id        IN INTEGER
                              ,p_entity_id       IN INTEGER
                              ,p_application_id  IN INTEGER
                             )
RETURN BOOLEAN;




END xla_control_accounts_pkg;
 

/
