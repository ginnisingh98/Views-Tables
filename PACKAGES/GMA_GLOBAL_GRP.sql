--------------------------------------------------------
--  DDL for Package GMA_GLOBAL_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMA_GLOBAL_GRP" AUTHID CURRENT_USER AS
-- $Header: GMAGGBLS.pls 115.8 2002/11/20 21:47:10 jbaird ship $
-- +=========================================================================+
-- |                Copyright (c) 1998 Oracle Corporation                    |
-- |                        TVP, Reading, England                            |
-- |                         All rights reserved                             |
-- +=========================================================================+
-- | FILENAME                                                                |
-- |     GMAGGBLS.pls                                                        |
-- |                                                                         |
-- | DESCRIPTION                                                             |
-- |     This package contains system-wide global functions and              |
-- |     procedures.                                                         |
-- |                                                                         |
-- | HISTORY                                                                 |
-- |     01-OCT-1998  M.Godfrey       Created                                |
-- |     15-FEB-1999  M.Godfrey       Upgrade to R11.                        |
-- |     21-Aug-1999  ppsriniv        Added the missing 'E' in 'REPLACE'.    |
-- |     02-Mar-2000  Liz Enstone     Bug 1196561 SY$MIN_DATE and SY$MAX_    |
-- |                                  DATE were hard-coded. Changed to call  |
-- |                                  to GMA_CORE_PKG.GET_DATE_CONSTANT      |
-- |     01-NOV-2002  RTARDIO         Added NOCOPY for bug 2650392           |
-- |     11-Nov-2002  Jeff Baird      Bug #2651809 Correct the format of the |
-- |                                  SY$MIN_DATE and SY$MAX_DATE profiles.  |
-- |     19-Nov-2002  Jeff Baird      Bug #2626977 Changed function name for |
-- |                                  the call to get the date constants.    |
-- +=========================================================================+
--  API Name  : GMA_GLOBAL_GRP
--  Type      : Group
--  Function  : This package contains system-wide global functions and
--              procedures
--  Pre-reqs  : N/A
--  Parameters: Per function
--
--  Current Vers  : 2.0
--
--  Previous Vers : 1.0
--
--  Initial Vers  : 1.0
--  Notes
--

SY$MIN_DATE CONSTANT DATE := gma_core_pkg.get_date_constant_d('SY$MIN_DATE');
SY$MAX_DATE CONSTANT DATE := gma_core_pkg.get_date_constant_d('SY$MAX_DATE');
-- Bug #2651809 (JKB) Changed format above.
-- Bug #2626977 (JKB) Changed function name above.

FUNCTION Get_doc_no
( p_doc_type    IN sy_docs_seq.doc_type%TYPE
, p_orgn_code   IN sy_docs_seq.orgn_code%TYPE
)
RETURN VARCHAR2;

PROCEDURE Get_Reason_Code
( p_reason_code  IN sy_reas_cds.reason_code%TYPE
, x_sy_reas_cds  OUT NOCOPY sy_reas_cds%ROWTYPE
);

PROCEDURE Get_Who
( p_user_name    IN fnd_user.user_name%TYPE
, x_user_id      OUT NOCOPY fnd_user.user_id%TYPE
);

END GMA_GLOBAL_GRP;

 

/
