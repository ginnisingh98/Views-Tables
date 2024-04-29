--------------------------------------------------------
--  DDL for Package Body FUN_TRX_ENTRY_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_TRX_ENTRY_UTIL" AS
--  $Header: funtrxentryutilb.pls 120.12 2006/03/27 23:19:25 dhaimes ship $

/****************************************************************
* FUNCTION  : get_concatenated_accounted                        *
*                                                               *
*       This function returns the concatenated segments  for a  *
*       transaction type name given ccid                        *
****************************************************************/

FUNCTION get_concatenated_account
(
 p_ccid in NUMBER
) RETURN VARCHAR2
IS

CURSOR c_details IS
SELECT  fifs.concatenated_segment_delimiter,
        gcc.segment1,
        gcc.segment2,
        gcc.segment3,
        gcc.segment4,
        gcc.segment5,
        gcc.segment6,
        gcc.segment7,
        gcc.segment8,
        gcc.segment9,
        gcc.segment10,
        gcc.segment11,
        gcc.segment12,
        gcc.segment13,
        gcc.segment14,
        gcc.segment15,
        gcc.segment16,
        gcc.segment17,
        gcc.segment18,
        gcc.segment19,
        gcc.segment20,
        gcc.segment21,
        gcc.segment22,
        gcc.segment23,
        gcc.segment24,
        gcc.segment25,
        gcc.segment26,
        gcc.segment27,
        gcc.segment28,
        gcc.segment29,
        gcc.segment30
FROM    fnd_id_flex_structures fifs,
        gl_code_combinations gcc
WHERE   fifs.application_id=101
AND     fifs.id_flex_code = 'GL#'
AND     fifs.id_flex_num = gcc.chart_of_accounts_id
AND     gcc.code_combination_id = p_ccid;

l_concat_value varchar2(1000);
l_details c_details%rowtype;
l_nseg number;

BEGIN

OPEN c_details;
FETCH c_details INTO l_details;

IF c_details%NOTFOUND  THEN
        return null;
END IF;

CLOSE c_details;

SELECT   count(1) into l_nseg
FROM     fnd_id_flex_segments fifs,
         gl_code_combinations glcc
WHERE    fifs.application_id = 101 and
         fifs.id_flex_code = 'GL#' and
         fifs.id_flex_num = glcc.chart_of_accounts_id and
         glcc.code_combination_id =p_ccid;

l_concat_value := FND_FLEX_SERVER.get_concatenated_value(
         P_DELIMITER            => l_details.concatenated_segment_delimiter,
         P_SEGMENT_COUNT        => l_nseg,
         P_SEGMENT1             => l_details.segment1,
         P_SEGMENT2             => l_details.segment2,
         P_SEGMENT3             => l_details.segment3,
         P_SEGMENT4             => l_details.segment4,
         P_SEGMENT5             => l_details.segment5,
         P_SEGMENT6             => l_details.segment6,
         P_SEGMENT7             => l_details.segment7,
         P_SEGMENT8             => l_details.segment8,
         P_SEGMENT9             => l_details.segment9,
         P_SEGMENT10            => l_details.segment10,
         P_SEGMENT11            => l_details.segment11,
         P_SEGMENT12            => l_details.segment12,
         P_SEGMENT13            => l_details.segment13,
         P_SEGMENT14            => l_details.segment14,
         P_SEGMENT15            => l_details.segment15,
         P_SEGMENT16            => l_details.segment16,
         P_SEGMENT17            => l_details.segment17,
         P_SEGMENT18            => l_details.segment18,
         P_SEGMENT19            => l_details.segment19,
         P_SEGMENT20            => l_details.segment20,
         P_SEGMENT21            => l_details.segment21,
         P_SEGMENT22            => l_details.segment22,
         P_SEGMENT23            => l_details.segment23,
         P_SEGMENT24            => l_details.segment24,
         P_SEGMENT25            => l_details.segment25,
         P_SEGMENT26            => l_details.segment26,
         P_SEGMENT27            => l_details.segment27,
         P_SEGMENT28            => l_details.segment28,
         P_SEGMENT29            => l_details.segment29,
         P_SEGMENT30            => l_details.segment30 );

RETURN (l_concat_value);

End get_concatenated_account;

/****************************************************************
* FUNCTION  : get_ledger_id                                     *
*                                                               *
*       This function returns the ledger_id for a               *
*       intercompany organization                               *
****************************************************************/

        FUNCTION get_ledger_id
        (
          p_party_id IN NUMBER,
          p_party_type IN Varchar2
        ) RETURN NUMBER
        IS
l_ledger_id Number;
l_return_id Number;

Begin

-- David Haimes bug 4962308
-- removed the hz_party table from the sql below as it was redundant.

SELECT ledger_id INTO l_return_id
FROM gl_ledger_le_v ledger_le, xle_firstparty_information_v le
WHERE fun_tca_pkg.get_le_id(p_party_id) = le.party_id
AND le.legal_entity_id = ledger_le.legal_entity_id
AND ledger_le.ledger_category_code = 'PRIMARY';

return l_return_id;

EXCEPTION
WHEN OTHERS THEN
  l_return_id := -99;
  return l_return_id;

end get_ledger_id;

/****************************************************************
* FUNCTION  : get_default_ccid             		        *
*								*
*	This function returns the default intercompany account (ccid)*
* for an initiator/recipient combination       			*
****************************************************************/

FUNCTION get_default_ccid
(
  p_from_le_id IN NUMBER,
  p_to_le_id   IN NUMBER,
  p_type       IN VARCHAR2
) RETURN NUMBER
IS
l_cc_id Number;
Begin

begin
 SELECT ccid INTO l_cc_id
 FROM fun_inter_accounts
 WHERE from_le_id = p_from_le_id
 AND to_le_id = p_to_le_id
 AND type = p_type
 AND rownum = 1
 ORDER by default_flag;
exception
when no_data_found then
 SELECT ccid INTO l_cc_id
 FROM fun_inter_accounts
 WHERE from_le_id = p_from_le_id
 AND to_le_id = -99
 AND type = p_type
 AND rownum = 1
 ORDER by default_flag;
end;

return l_cc_id;

EXCEPTION
WHEN OTHERS THEN
  l_cc_id := 0;
  return l_cc_id;
END get_default_ccid;

/****************************************************************
* FUNCTION  : log_debug          		                *
*						                *
*	This procedure calls fnd_log to log debug messages      *
*   Debug Levels:                                               *
*    LEVEL_UNEXPECTED CONSTANT NUMBER  := 6;                    *
*    LEVEL_ERROR      CONSTANT NUMBER  := 5;                    *
*    LEVEL_EXCEPTION  CONSTANT NUMBER  := 4;                    *
*    LEVEL_EVENT      CONSTANT NUMBER  := 3;                    *
*    LEVEL_PROCEDURE  CONSTANT NUMBER  := 2;                    *
*    LEVEL_STATEMENT  CONSTANT NUMBER  := 1;                    *
****************************************************************/

PROCEDURE log_debug
(
  p_log_level IN VARCHAR2 ,
  p_module    IN VARCHAR2,
  p_message   IN VARCHAR2
)
IS
l_debug_level NUMBER;
BEGIN
  l_debug_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  IF (p_log_level >= l_debug_level) THEN
    FND_LOG.STRING(p_log_level, p_module, p_message);
  END IF;
END log_debug;

END FUN_TRX_ENTRY_UTIL;

/
