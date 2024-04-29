--------------------------------------------------------
--  DDL for Package Body PO_VAL_GA_ORG_ASSIGNMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_VAL_GA_ORG_ASSIGNMENTS" AS
-- $Header: PO_VAL_GA_ORG_ASSIGNMENTS.plb 120.0 2005/08/12 17:44:47 sbull noship $

c_ENTITY_TYPE_GA_ORG_ASSIGN CONSTANT VARCHAR2(30) := PO_VALIDATIONS.C_ENTITY_TYPE_GA_ORG_ASSIGN;

-- Constants for column names
c_PURCHASING_ORG_ID CONSTANT VARCHAR2(30) := 'PURCHASING_ORG_ID';
c_VENDOR_SITE_ID CONSTANT VARCHAR2(30) := 'VENDOR_SITE_ID';

-- The module base for this package.
D_PACKAGE_BASE CONSTANT VARCHAR2(50) :=
  PO_LOG.get_package_base('PO_VAL_GA_ORG_ASSIGNMENTS');

-- The module base for the subprogram.
D_purchasing_org_id_not_null CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'purchasing_org_id_not_null');
D_vendor_site_id_not_null CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'vendor_site_id_not_null');


-------------------------------------------------------------------------------
-- Ensures that the Purchasing Org is not null.
-------------------------------------------------------------------------------
PROCEDURE purchasing_org_id_not_null(
  p_org_assignment_id_tbl       IN PO_TBL_NUMBER
, p_purchasing_org_id_tbl       IN PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.not_null(
  p_calling_module => D_purchasing_org_id_not_null
, p_value_tbl => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_purchasing_org_id_tbl)
, p_entity_id_tbl => p_org_assignment_id_tbl
, p_entity_type => c_entity_type_GA_ORG_ASSIGN
, p_column_name => c_PURCHASING_ORG_ID
, p_message_name => PO_MESSAGE_S.PO_ALL_NOT_NULL
, x_results => x_results
, x_result_type => x_result_type
);

END purchasing_org_id_not_null;


-------------------------------------------------------------------------------
-- Ensures that the Supplier Site is not null.
-------------------------------------------------------------------------------
PROCEDURE vendor_site_id_not_null(
  p_org_assignment_id_tbl   IN PO_TBL_NUMBER
, p_vendor_site_id_tbl      IN PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.not_null(
  p_calling_module => D_vendor_site_id_not_null
, p_value_tbl => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_vendor_site_id_tbl)
, p_entity_id_tbl => p_org_assignment_id_tbl
, p_entity_type => c_entity_type_GA_ORG_ASSIGN
, p_column_name => c_VENDOR_SITE_ID
, p_message_name => PO_MESSAGE_S.PO_ALL_NOT_NULL
, x_results => x_results
, x_result_type => x_result_type
);

END vendor_site_id_not_null;


END PO_VAL_GA_ORG_ASSIGNMENTS;

/
