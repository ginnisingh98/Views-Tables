--------------------------------------------------------
--  DDL for Package XLA_CMP_CALL_FCT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_CMP_CALL_FCT_PKG" AUTHID CURRENT_USER AS
/* $Header: xlacpcll.pkh 120.14 2005/03/29 14:40:40 kboussem ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_cmp_call_fct_pkg                                                   |
|                                                                            |
| DESCRIPTION                                                                |
|     This is a XLA private package, which contains all the logic required   |
|     to generate function/procedure calls                                   |                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     25-JUN-2002 K.Boussema    Created                                      |
|     18-FEB-2003 K.Boussema    Added 'dbdrv' command                        |
|     10-MAR-2003 K.Boussema    Made changes for the new bulk approach of the|
|                               accounting engine                            |
|     22-APR-2003 K.Boussema    Included error messages                      |
|     05-MAI-2003 K.Boussema    Modified to retrieve data base on ledger_id  |
|     17-JUL-2003 K.Boussema    Reviewd the code                             |
|     18-DEC-2003 K.Boussema    Changed to fix bug 3042840,3307761,3268940   |
|                               3310291 and 3320689                          |
|     23-FEB-2004 K.Boussema    Made changes for the FND_LOG.                |
|     12-MAR-2004 K.Boussema    Changed to incorporate the select of lookups |
|                               from the extract objects                     |
|     20-Sep-2004 S.Singhania   Made ffg chganges for the BULK performance   |
|                                 - Modified C_CALL_EVENT_CLASS_PROC,        |
|                                   C_ALT_ALT_PROC, C_CALL_EVENT_TYPE_PROC   |
|                                 - Modifed specs for GenerateCallHdrDescALT |
|                                 - Replaced LONG with CLOB                  |
|     21-Sep-2004 S.Singhania   Added NOCOPY hint to the OUT parameters.     |
|     12-Feb-2005 W. Shen       This is for ledger currency project          |
|                               Add calculate amts flag and calculate gain   |
|                               loss flag to acct line function              |
|                               other minus change related to C_CALL_ADR     |
|                               C_CALL_ADR_FCT                               |
|     07-Mar-2005 K.Boussema    Changed for ADR-enhancements.                |
+===========================================================================*/


/*-----------------------------------------------------------------+
|                                                                  |
|   Public Function                                                |
|                                                                  |
|   GetSourceParameters                                            |
|                                                                  |
|   Generates the source parameters in function/procedure call     |
|                                                                  |
|   Example: p_source_1 => p_source_1,                             |
|            p_source_2 => p_source_2,                             |
|            p_source_2_meaning => p_source_2_meaning, ...         |
|                                                                  |
+-----------------------------------------------------------------*/

FUNCTION GetSourceParameters(
  p_array_source_index    IN xla_cmp_source_pkg.t_array_ByInt
, p_rec_sources          IN xla_cmp_source_pkg.t_rec_sources
)
RETURN CLOB
;

/*-----------------------------------------------------------------+
|                                                                  |
|   Public Function                                                |
|                                                                  |
|   GetHeaderParameters                                            |
|                                                                  |
|   Generates the source parameters in header fct/prod call        |
|                                                                  |
|   Example: p_source_1 => l_source_1,                             |
|            p_source_2 => l_source_2,                             |
|            p_source_2_meaning => l_source_2_meaning, ...         |
|                                                                  |
+-----------------------------------------------------------------*/

FUNCTION GetHeaderParameters(
  p_array_source_index           IN xla_cmp_source_pkg.t_array_ByInt
, p_rec_sources                  IN xla_cmp_source_pkg.t_rec_sources
)
RETURN CLOB
;

/*--------------------------------------------------------------------------+
|                                                                           |
|   Public Function                                                         |
|                                                                           |
|   GetLineParameters                                                       |
|                                                                           |
|   Generates the source parameters in line fct/prod call                   |
|                                                                           |
|   Example: p_source_1 => l_array_source_1(Idx),                           |
|   p_source_1_meaning => l_array_source_1_meaning(Idx),                    |
|   p_source_2 => g_array_event(l_event_id).array_value_num('source_1') ... |
|                                                                           |
+--------------------------------------------------------------------------*/

FUNCTION GetLineParameters(
   p_array_source_index           IN xla_cmp_source_pkg.t_array_ByInt
 , p_array_source_level           IN xla_cmp_source_pkg.t_array_VL1
 , p_rec_sources                  IN xla_cmp_source_pkg.t_rec_sources
)
RETURN CLOB
;


END xla_cmp_call_fct_pkg; -- end of package spec
 

/
