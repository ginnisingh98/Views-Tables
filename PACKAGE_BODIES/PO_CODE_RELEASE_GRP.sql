--------------------------------------------------------
--  DDL for Package Body PO_CODE_RELEASE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_CODE_RELEASE_GRP" AS
/* $Header: POXGCRLB.pls 115.1 2003/08/06 02:23:32 bmunagal noship $*/

-------------------------------------------------------------------------------
--Start of Comments
--Name: Current_Release
--Pre-reqs:
--  Only 115.0 version should be included in any ARU with a dependency on this file
--  Versions >= 115.1 should be shipped ONLY as part of final PRC Family Pack ARU
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  To identify the current PO Family Pack code release on a customer instance
--Parameters:
--  None.
--Returns:
--  Encoded String representing current PO Family Pack Code Release
--  The following format with 4 segments separated by a dot . is used:
--   11.05.00.00 indicates Base 11i. Returned in base version 115.0 of this file
--   11.05.10.00 indicates 11.5.10 or PRC Family Pack J. Returned in version 115.1
--   The last segment may be used in the future for releases in between family packs
--Notes:
--  How to use this package functions in your code:
--
--  If you have new features that need to be enabled only if the code is
--   delivered as part of PRC Family Pack, but hidden if the same code
--   is delivered as part of a one-off patch, wrap your code in
--   the following IF condition.
--
--   IF PO_CODE_RELEASE_GRP.Current_Release >= PO_CODE_RELEASE_GRP.PRC_11i_Family_Pack_J THEN
--     <code that gets executed only if customer gets this as part of FPJ>
--   END IF
--
--  The above wrapping should be necessary **only** in the interfaces to new code.
--  The interfaces could be Forms UI, Import Programs like Req Import, etc.
--
--Testing:
--  If the instance has 115.0 version, then the below check should be false
--  If the instance has 115.1 or higher, then the below check should be true
--    PO_CODE_RELEASE_GRP.Current_Release >= PO_CODE_RELEASE_GRP.PRC_11i_Family_Pack_J
--
--  Also, at the time of releasing FPJ, verify in ARU system that version 115.1
--    of this file is included only by one aru: the final prc-fpj aru
--End of Comments
-------------------------------------------------------------------------------

Function Current_Release
return varchar2
is
Begin
  return '11.05.10.00'; -- Indicates 11.5.10 or FPJ in this file version of 115.1
End Current_Release;


-------------------------------------------------------------------------------
--Start of Comments
--Name: PRC_11i_Family_Pack_J
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Convenience Function to return encoded string for PRC 11i Family Pack J
--Parameters:
--  None.
--Returns:
--  Encoded string corresponding to Procurement 11i Family Pack J
--Notes:
--  Refer to Function Current_Release in this Package for usage/encoding details
--Testing:
--  Should return string 11.05.10.00
--End of Comments
-------------------------------------------------------------------------------

Function PRC_11i_Family_Pack_J
return varchar2
is
Begin
  Return '11.05.10.00';
End PRC_11i_Family_Pack_J;

END PO_CODE_RELEASE_GRP;

/
