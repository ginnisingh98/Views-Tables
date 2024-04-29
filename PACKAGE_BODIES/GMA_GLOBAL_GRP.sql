--------------------------------------------------------
--  DDL for Package Body GMA_GLOBAL_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMA_GLOBAL_GRP" AS
--$Header: GMAGGBLB.pls 115.2 2002/11/01 21:04:16 appldev ship $
-- Body start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| FILE NAME                                                                |
--|    GMAGGBLB.pls                                                          |
--|                                                                          |
--| PACKAGE NAME                                                             |
--|    GMA_GLOBAL_GRP                                                        |
--|                                                                          |
--| DESCRIPTION                                                              |
--|    This package contains all Utility functions pertaining to System      |
--|    Module                                                                |
--|                                                                          |
--| CONTENTS                                                                 |
--|    Get_Doc_No                                                            |
--|    Get_Reason_Code                                                       |
--|    Get_Who                                                               |
--|                                                                          |
--| HISTORY                                                                  |
--|    17-FEB-1999  M.Godfrey    Upgrade to R11                              |
--|    23-JUL-2002  Teresa Wong  Modified Get_Who to return -1 if user was   |
--|				 not defined.  (SYSADMIN has a valid user_id |
--|				 of 0.)   			             |
--|                                                                          |
--+==========================================================================+
-- Body end of comments

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|    Get_Doc_No                                                            |
--|                                                                          |
--|  USAGE                                                                   |
--|    Get next Document Number                                              |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|    This global function gets the next document numbr for a given         |
--|    document type/Oraganization Code                                      |
--|                                                                          |
--|  PARAMETERS                                                              |
--|    p_doc_type  IN VARCHAR2 - Document Type                               |
--|    p_orgn_code IN VARCHAR2 - Organization Code                           |
--|                                                                          |
--|  RETURNS                                                                 |
--|    Document Number - If successful                                       |
--|    Blank           - If errors                                           |
--|                                                                          |
--|  HISTORY                                                                 |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Get_Doc_No
( p_doc_type  IN sy_docs_seq.doc_type%TYPE
, p_orgn_code IN sy_docs_seq.orgn_code%TYPE
)
RETURN VARCHAR2
IS
l_doc_no        VARCHAR2(10);
l_doc_mask      VARCHAR2(10);
l_last_assigned NUMBER(10);
l_format_size   NUMBER(5);
l_pad_char      VARCHAR2(1);
CURSOR sy_docs_seq_c1 IS
SELECT
  last_assigned
, format_size
, pad_char
FROM
  sy_docs_seq
WHERE
    doc_type  = p_doc_type
AND orgn_code = p_orgn_code;

BEGIN

  -- Update sy_docs_seq
  UPDATE sy_docs_seq
  SET
    last_assigned = last_assigned + 1
  WHERE
    doc_type  = p_doc_type AND
    orgn_code = p_orgn_code;

  -- Now get new document no
  OPEN sy_docs_seq_c1;

  FETCH sy_docs_seq_c1 INTO
    l_last_assigned
  , l_format_size
  , l_pad_char;

  CLOSE sy_docs_seq_c1;

  -- Sort out format mask
  l_doc_mask := LTRIM(RPAD(l_pad_char,l_format_size,l_pad_char));
  l_doc_no   := LTRIM(TO_CHAR(l_last_assigned, l_doc_mask));

  RETURN l_doc_no;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Get_doc_no;

--+=========================================================================+
--| PROCEDURE NAME                                                          |
--|    Get_Reason_Code                                                      |
--|                                                                         |
--| USAGE                                                                   |
--|    Used to retrieve reason code details                                 |
--|                                                                         |
--| DESCRIPTION                                                             |
--|    This procedure is used to retrieve all details from sy_reas_cds      |
--|                                                                         |
--| PARAMETERS                                                              |
--|    p_reason_code IN  VARCHAR2(4)  - Reason code to be retrieved         |
--|    x_sy_reas_cds OUT RECORD       - Record containing sy_reas_cds       |
--|                                                                         |
--| HISTORY                                                                 |
--|    01-OCT-1998      M.Godfrey     Created                               |
--|    01-NOV-2002      RTARDIO       Added NOCOPY for bug 2650392          |
--+=========================================================================+
PROCEDURE Get_Reason_Code
( p_reason_code  IN  sy_reas_cds.reason_code%TYPE
, x_sy_reas_cds  OUT NOCOPY sy_reas_cds%ROWTYPE
)
IS
CURSOR sy_reas_cds_c1 IS
SELECT
  *
FROM
  sy_reas_cds
WHERE
  reason_code   = p_reason_code AND
  delete_mark = 0;

BEGIN

  OPEN sy_reas_cds_c1;

  FETCH sy_reas_cds_c1 INTO x_sy_reas_cds;

  IF (sy_reas_cds_c1%NOTFOUND)
  THEN
    x_sy_reas_cds.reason_code := NULL;
  END IF;

  CLOSE sy_reas_cds_c1;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Get_Reason_Code;

--+=========================================================================+
--| PROCEDURE NAME                                                          |
--|    Get_Who                                                              |
--|                                                                         |
--| USAGE                                                                   |
--|    Used to retrieve WHO information                                     |
--|                                                                         |
--| DESCRIPTION                                                             |
--|    This procedure is used to retrieve the who field information         |
--|                                                                         |
--| PARAMETERS                                                              |
--|    p_user_name   IN  VARCHAR2     - User name                           |
--|    x_user_id     OUT NUMBER       - user id of the user                 |
--|                                                                         |
--| HISTORY                                                                 |
--|    17-FEB-1999      M.Godfrey     Created for R11                       |
--|    23-JUL-2002      Teresa Wong   Modified code to return -1 if user    |
--|				      was not defined.  (SYSADMIN has       |
--|				      a valid user_id of 0.)                |
--|    01-NOV-2002      RTARDIO       Added NOCOPY for bug 2650392          |
--+=========================================================================+
PROCEDURE Get_Who
( p_user_name    IN  fnd_user.user_name%TYPE
, x_user_id      OUT NOCOPY fnd_user.user_id%TYPE
)
IS
CURSOR fnd_user_c1 IS
SELECT
  user_id
FROM
  fnd_user
WHERE
  user_name = p_user_name;

BEGIN

  OPEN fnd_user_c1;

  FETCH fnd_user_c1 INTO x_user_id;

  -- TKW B2476518 7/23/2002
  -- If user not found, return -1 instead of 0.
  IF (fnd_user_c1%NOTFOUND)
  THEN
    x_user_id := -1;
  END IF;

  CLOSE fnd_user_c1;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Get_Who;

END GMA_GLOBAL_GRP;

/
