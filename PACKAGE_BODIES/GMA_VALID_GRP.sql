--------------------------------------------------------
--  DDL for Package Body GMA_VALID_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMA_VALID_GRP" AS
--$Header: GMAGVALB.pls 115.1 1999/11/11 08:49:15 pkm ship      $
-- Body start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| FILE NAME                                                                |
--|    GMAGVALB.pls                                                          |
--|                                                                          |
--| PACKAGE NAME                                                             |
--|    GMA_VALID_GRP                                                         |
--|                                                                          |
--| DESCRIPTION                                                              |
--|    This package contains various validation functions                    |
--|                                                                          |
--| CONTENTS                                                                 |
--|    NumRangeCheck                                                         |
--|    Validate_um                                                           |
--|    Validate_Reason_Code                                                  |
--|    Validate_Orgn_code                                                    |
--|    Validate_Co_Code                                                      |
--|    Validate_Orgn_For_Company                                             |
--|    Validate_Doc_No                                                       |
--|    Validate_Type                                                         |
--|                                                                          |
--| HISTORY                                                                  |
--|        28-OCT-1999  H.Verdding    Bug 1042739 Added Extra Parameter      |
--|                                   p_orgn_code To Validate_Doc_No         |
--|                                                                          |
--+==========================================================================+
-- Body end of comments

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|    NumRangeCheck                                                         |
--|                                                                          |
--|  USAGE                                                                   |
--|    Validates parameter is within given numeric range                     |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|    This generic function checks that a numeric parameter is within       |
--|    a given numeric range                                                 |
--|                                                                          |
--|  PARAMETERS                                                              |
--|    p_min   IN NUMBER - Minimum value                                     |
--|    p_max   IN NUMBER - Maximum value                                     |
--|    p_value IN NUMBER - Value to be checked                               |
--|                                                                          |
--|  RETURNS                                                                 |
--|    TRUE  - If p_value falls within the specified range                   |
--|    FALSE - If p_value does not fall within the specified range           |
--|                                                                          |
--|  HISTORY                                                                 |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION NumRangeCheck
( p_min   IN NUMBER
, p_max   IN NUMBER
, p_value IN NUMBER
)
RETURN BOOLEAN
IS

BEGIN

  IF (p_value < p_min OR p_value > p_max)
  THEN
    RETURN FALSE;
  ELSE
    RETURN TRUE;
  END IF;

END NumRangeCheck;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|    Validate_Um                                                           |
--|                                                                          |
--|  USAGE                                                                   |
--|    Validates Unit Of Measure exists                                      |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|    This generic function validates that the Unit Of Measure supplied     |
--|    exists on sy_uoms_mst                                                 |
--|                                                                          |
--|  PARAMETERS                                                              |
--|    p_um IN VARCHAR2 - Unit Of Measure Code                               |
--|                                                                          |
--|  RETURNS                                                                 |
--|    TRUE  - If UoM Code exists                                            |
--|    FALSE - If UoM Code does not exist                                    |
--|                                                                          |
--|  HISTORY                                                                 |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Validate_Um
( p_um IN sy_uoms_mst.um_code%TYPE
)
RETURN BOOLEAN
IS
l_um_desc SY_UOMS_MST.um_desc%TYPE;
CURSOR sy_uoms_mst_c1 IS
SELECT
  um_desc
FROM
  sy_uoms_mst
WHERE
    um_code     = p_um
AND delete_mark = 0;

BEGIN

  OPEN sy_uoms_mst_c1;

  FETCH sy_uoms_mst_c1 INTO l_um_desc;
  IF (sy_uoms_mst_c1%NOTFOUND)
  THEN
    CLOSE sy_uoms_mst_c1;
    RETURN FALSE;
  ELSE
    CLOSE sy_uoms_mst_c1;
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Validate_Um;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|    Validate_Reason_Code                                                  |
--|                                                                          |
--|  USAGE                                                                   |
--|    Validates Reason Code                                                 |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|    This generic function validates that the Reason Code passed exists    |
--|    on sy_reas_cds                                                        |
--|                                                                          |
--|  PARAMETERS                                                              |
--|    p_reason_code IN VARCHAR2 - Reason Code                               |
--|                                                                          |
--|  RETURNS                                                                 |
--|    TRUE  - If Reason Code is valid                                       |
--|    FALSE - If Reason Code is not valid                                   |
--|                                                                          |
--|  HISTORY                                                                 |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Validate_reason_code
(p_reason_code IN sy_reas_cds.reason_code%TYPE
)
RETURN BOOLEAN
IS
l_reason_code VARCHAR2(4);
CURSOR sy_reas_cds_c1 IS
SELECT
  reason_code
FROM
  sy_reas_cds
WHERE
    reason_code = p_reason_code
AND delete_mark = 0;

BEGIN
  OPEN sy_reas_cds_c1;
  FETCH sy_reas_cds_c1 INTO l_reason_code;
  IF (sy_reas_cds_c1%NOTFOUND)
  THEN
    CLOSE sy_reas_cds_c1;
    RETURN FALSE;
  ELSE
    CLOSE sy_reas_cds_c1;
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Validate_Reason_Code;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|    Validate_Orgn_Code                                                    |
--|                                                                          |
--|  USAGE                                                                   |
--|    Validates Organization Code                                           |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|    This generic function validates that the Organization Code exists     |
--|    on sy_orgn_mst                                                        |
--|                                                                          |
--|  PARAMETERS                                                              |
--|    p_orgn_code IN VARCHAR2 - Organization Code                           |
--|                                                                          |
--|  RETURNS                                                                 |
--|    TRUE  - If Organization Code is valid                                 |
--|    FALSE - If Organization Code is not valid                             |
--|                                                                          |
--|  HISTORY                                                                 |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Validate_Orgn_Code
(p_orgn_code IN sy_orgn_mst.orgn_code%TYPE
)
RETURN BOOLEAN
IS
l_orgn_code VARCHAR2(4);
CURSOR sy_orgn_mst_c1 IS
SELECT
  orgn_code
FROM
  sy_orgn_mst
WHERE
    orgn_code   = p_orgn_code
AND delete_mark = 0;

BEGIN
  OPEN sy_orgn_mst_c1;
  FETCH sy_orgn_mst_c1 INTO l_orgn_code;
  IF (sy_orgn_mst_c1%NOTFOUND)
  THEN
    CLOSE sy_orgn_mst_c1;
    RETURN FALSE;
  ELSE
    CLOSE sy_orgn_mst_c1;
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Validate_Orgn_Code;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|    Validate_Co_Code                                                      |
--|                                                                          |
--|  USAGE                                                                   |
--|    Validates Company Code                                                |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|    This generic function validates that the Organization Code exists     |
--|    on sy_orgn_mst and is defined as a company                            |
--|                                                                          |
--|  PARAMETERS                                                              |
--|    p_co_code IN VARCHAR2 - Company Code                                  |
--|                                                                          |
--|  RETURNS                                                                 |
--|    TRUE  - If Comapny Code is valid                                      |
--|    FALSE - If Company Code is not valid                                  |
--|                                                                          |
--|  HISTORY                                                                 |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Validate_Co_Code
(p_co_code IN sy_orgn_mst.orgn_code%TYPE
)
RETURN BOOLEAN
IS
l_co_code VARCHAR2(4);
CURSOR sy_orgn_mst_c1 IS
SELECT
  co_code
FROM
  sy_orgn_mst
WHERE
    orgn_code   = p_co_code
AND co_code     = p_co_code
AND delete_mark = 0;

BEGIN
  OPEN sy_orgn_mst_c1;
  FETCH sy_orgn_mst_c1 INTO l_co_code;
  IF (sy_orgn_mst_c1%NOTFOUND)
  THEN
    CLOSE sy_orgn_mst_c1;
    RETURN FALSE;
  ELSE
    CLOSE sy_orgn_mst_c1;
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Validate_Co_Code;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|    Validate_Orgn_For_Company                                             |
--|                                                                          |
--|  USAGE                                                                   |
--|    Validates Organization for Company                                    |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|    This generic function validates that the Organization Code belongs to |
--|    to the given company                                                  |
--|                                                                          |
--|  PARAMETERS                                                              |
--|    p_orgn_code IN VARCHAR2 - Organization Code                           |
--|    p_co_code   IN VARCHAR2 - Company Code                                |
--|                                                                          |
--|  RETURNS                                                                 |
--|    TRUE  - If Organization belongs to the Company                        |
--|    FALSE - If Organization does not belongs to the Company               |
--|                                                                          |
--|  HISTORY                                                                 |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Validate_Orgn_For_Company
( p_orgn_code IN sy_orgn_mst.orgn_code%TYPE
, p_co_code   IN sy_orgn_mst.orgn_code%TYPE
)
RETURN BOOLEAN
IS
l_co_code VARCHAR2(4);
CURSOR sy_orgn_mst_c1 IS
SELECT
  co_code
FROM
  sy_orgn_mst
WHERE
    orgn_code   = p_orgn_code
AND co_code     = p_co_code
AND delete_mark = 0;

BEGIN
  OPEN sy_orgn_mst_c1;
  FETCH sy_orgn_mst_c1 INTO l_co_code;
  IF (sy_orgn_mst_c1%NOTFOUND)
  THEN
    CLOSE sy_orgn_mst_c1;
    RETURN FALSE;
  ELSE
    CLOSE sy_orgn_mst_c1;
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Validate_Orgn_For_Company;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|    Validate_Doc_No                                                       |
--|                                                                          |
--|  USAGE                                                                   |
--|    Validates Document Number                                             |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|    This generic function validates that the Document number for the      |
--|    passed document type is valid. If manual numbering then any non NULL  |
--|    or non BLANK value is allowed. If Automatic numbering then value      |
--|    must be BLANK or NULL.                                                |
--|                                                                          |
--|  PARAMETERS                                                              |
--|    p_doc_type IN VARCHAR2 - Document Type                                |
--|    p_doc_no   IN VARCHAR2 - Document Number                              |
--|                                                                          |
--|  RETURNS                                                                 |
--|    TRUE  - If Document Number is valid                                   |
--|    FALSE - If Document Number is not valid                               |
--|                                                                          |
--|  HISTORY                                                                 |
--|  28-OCT-1999  H.Verdding      Bug 1042739 Added Extra Parameter          |
--|                               p_orgn_code To Validate_Doc_No             |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Validate_Doc_No
( p_doc_type  IN sy_docs_seq.doc_type%TYPE
, p_doc_no    IN VARCHAR2
, p_orgn_code IN sy_orgn_mst.orgn_code%TYPE
)
RETURN BOOLEAN
IS
l_assignment_type sy_docs_seq.assignment_type%TYPE;
CURSOR sy_docs_seq_c1 IS
SELECT
  assignment_type
FROM
  sy_docs_seq
WHERE
    doc_type    = p_doc_type
AND orgn_code   = p_orgn_code
AND delete_mark = 0;

BEGIN

  OPEN sy_docs_seq_c1;
  FETCH sy_docs_seq_c1 INTO l_assignment_type;
  IF (sy_docs_seq_c1%NOTFOUND)
  THEN
    CLOSE sy_docs_seq_c1;
    RETURN FALSE;
  ELSE
    CLOSE sy_docs_seq_c1;
    IF (l_assignment_type = 1)
    THEN
      IF (p_doc_no = ' ' OR p_doc_no IS NULL)
      THEN
        RETURN FALSE;
      ELSE
	RETURN TRUE;
      END IF;
    ELSIF (l_assignment_type = 2)
    THEN
      IF (p_doc_no = ' ' OR p_doc_no IS NULL)
      THEN
        RETURN TRUE;
      ELSE
	RETURN FALSE;
      END IF;
    ELSE
      RETURN TRUE;
    END IF;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Validate_Doc_No;

--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|    Validate_Type                                                         |
--|                                                                          |
--|  USAGE                                                                   |
--|    Validates type fields                                                 |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|    This generic function validates that the type value passed is         |
--|    valid for table and field name                                        |
--|                                                                          |
--|  PARAMETERS                                                              |
--|    p_lookup_type  IN VARCHAR2 - field name of type field                 |
--|    p_lookup_code  IN VARCHAR2 - field value                              |
--|                                                                          |
--|  RETURNS                                                                 |
--|    TRUE  - If type value is valid                                        |
--|    FALSE - If type value is not valid                                    |
--|                                                                          |
--|  HISTORY                                                                 |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Validate_Type
( p_lookup_type  IN gem_lookups.lookup_type%TYPE
, p_lookup_code  IN gem_lookups.lookup_code%TYPE
)
RETURN BOOLEAN
IS
l_lookup_type    gem_lookups.lookup_type%TYPE;
CURSOR gem_lookups_c1 IS
SELECT
  lookup_type
FROM
  gem_lookups
WHERE
  lookup_type   = p_lookup_type
AND lookup_code = p_lookup_code;

BEGIN
  OPEN gem_lookups_c1;
  FETCH gem_lookups_c1 INTO l_lookup_type;
  IF (gem_lookups_c1%NOTFOUND)
  THEN
    CLOSE gem_lookups_c1;
    RETURN FALSE;
  ELSE
    CLOSE gem_lookups_c1;
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Validate_Type;

END GMA_VALID_GRP;

/
