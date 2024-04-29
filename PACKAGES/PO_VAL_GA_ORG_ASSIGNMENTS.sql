--------------------------------------------------------
--  DDL for Package PO_VAL_GA_ORG_ASSIGNMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_VAL_GA_ORG_ASSIGNMENTS" AUTHID CURRENT_USER AS
-- $Header: PO_VAL_GA_ORG_ASSIGNMENTS.pls 120.0 2005/08/12 17:44:06 sbull noship $

PROCEDURE purchasing_org_id_not_null(
  p_org_assignment_id_tbl       IN PO_TBL_NUMBER
, p_purchasing_org_id_tbl       IN PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

PROCEDURE vendor_site_id_not_null(
  p_org_assignment_id_tbl   IN PO_TBL_NUMBER
, p_vendor_site_id_tbl      IN PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
);

END PO_VAL_GA_ORG_ASSIGNMENTS;

 

/
