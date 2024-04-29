--------------------------------------------------------
--  DDL for Package GMA_VALID_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMA_VALID_GRP" AUTHID CURRENT_USER AS
-- $Header: GMAGVALS.pls 115.1 1999/11/11 08:49:18 pkm ship      $
--+=========================================================================+
--|                Copyright (c) 1998 Oracle Corporation                    |
--|                        TVP, Reading, England                            |
--|                         All rights reserved                             |
--+=========================================================================+
--| FILENAME                                                                |
--|     GMAGVALS.pls                                                        |
--|                                                                         |
--| DESCRIPTION                                                             |
--|     This package contains system-wide validation functions and          |
--|     procedures.                                                         |
--|                                                                         |
--| HISTORY                                                                 |
--|     01-OCT-1998  M.Godfrey       Created                                |
--|     17-FEB-1999  M.Godfrey       Upgrade to R11                         |
--|     28-OCT-1999  H.Verdding      Bug 1042739 Added Extra Parameter      |
--|                                  p_orgn_code To Validate_Doc_No         |
--+=========================================================================+
-- API Name  : GMA_VALID_GRP
-- Type      : Group
-- Function  : This package contains system-wide validation functions and
--             procedures
-- Pre-reqs  : N/A
-- Parameters: Per function
--
-- Current Vers  : 2.0
--
-- Previous Vers : 1.0
--
-- Initial Vers  : 1.0
-- Notes
--
FUNCTION NumRangeCheck
( p_min           IN NUMBER
, p_max           IN NUMBER
, p_value         IN NUMBER
)
RETURN BOOLEAN;
--
FUNCTION Validate_um
( p_um            IN sy_uoms_mst.um_code%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_reason_code
( p_reason_code   IN sy_reas_cds.reason_code%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_orgn_code
( p_orgn_code     IN sy_orgn_mst.orgn_code%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_co_code
( p_co_code       IN sy_orgn_mst.orgn_code%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_orgn_for_company
( p_orgn_code     IN sy_orgn_mst.orgn_code%TYPE
, p_co_code       IN sy_orgn_mst.orgn_code%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_doc_no
( p_doc_type      IN sy_docs_seq.doc_type%TYPE
, p_doc_no        IN VARCHAR2
, p_orgn_code     IN sy_orgn_mst.orgn_code%TYPE
)
RETURN BOOLEAN;
--
FUNCTION Validate_Type
( p_lookup_type   IN gem_lookups.lookup_type%TYPE
, p_lookup_code   IN gem_lookups.lookup_code%TYPE
)
RETURN BOOLEAN;
--
END GMA_VALID_GRP;

 

/
