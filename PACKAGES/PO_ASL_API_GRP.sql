--------------------------------------------------------
--  DDL for Package PO_ASL_API_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_ASL_API_GRP" AUTHID CURRENT_USER AS
/* $Header: PO_ASL_API_GRP.pls 120.2.12010000.1 2013/12/16 14:47:00 vpeddi noship $*/

--------------------------------------------------------------------------------
  --Start of Comments

  --Name: process

  --Function:
  --  This will determine whether to do insert or update.
  --  Create will throw error if you are passing diuplicate asl.
  --  Update will throw error if asl does not exists.
  --  Call Validation interface to perform field validations
  --  Call PO_ASL_API_PVT.reject_asl_record for the records in case any
  --  validation error.

  --Parameters:

  --IN:
  --  p_session_key     NUMBER

  --OUT:
  --  x_return_status   VARCHAR2
  --  x_return_msg      VARCHAR2

  --End of Comments
--------------------------------------------------------------------------------

PROCEDURE process(
  p_session_key     IN         NUMBER
, x_return_status   OUT NOCOPY VARCHAR2
, x_return_msg      OUT NOCOPY VARCHAR2
);

FUNCTION determine_action(
  p_item_id                IN  NUMBER
, p_category_id            IN  NUMBER
, p_using_organization_id  IN  NUMBER
, p_vendor_id              IN  NUMBER
, p_vendor_site_id         IN  NUMBER
)
RETURN VARCHAR2;

FUNCTION validate_vmi(
  p_item_id                IN  NUMBER
, p_using_organization_id  IN  NUMBER
, p_vendor_site_id         IN  NUMBER
)
RETURN VARCHAR2;


END PO_ASL_API_GRP;

/
