--------------------------------------------------------
--  DDL for Package Body PO_CLM_PAY_INSTR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_CLM_PAY_INSTR_PKG" AS
/* $Header: PO_CLM_PAY_INSTR_PKG.plb 120.0.12010000.2 2014/01/30 10:33:26 amalick noship $ */

d_pkg_name CONSTANT varchar2(50) :=  PO_LOG.get_package_base('PO_CLM_PAY_INSTR_PKG');


--This is the main api being called by AP code.x_dist_tab is the parameter that is returned
--to AP which has the info about each distribution being invoiced.
PROCEDURE GET_CLM_PAY_INSTR_PRORATION
  ( p_invoice_type         IN  VARCHAR2,
    p_match_mode           IN  VARCHAR2,
    p_match_type           IN  VARCHAR2,
    p_po_line_location_id  IN  NUMBER,
    p_match_quantity       IN  NUMBER,
    p_match_amount         IN  NUMBER,
    p_overbill_flag        IN  VARCHAR2,
    p_unit_price           IN  NUMBER,
    p_min_acct_unit        IN  NUMBER,
    p_precision            IN  NUMBER,
    x_dist_tab             OUT NOCOPY  dist_tab_type,
    x_return_status OUT NOCOPY VARCHAR2,
    x_return_msg     OUT NOCOPY VARCHAR2
  )
IS

BEGIN

   null;

END GET_CLM_PAY_INSTR_PRORATION;



--This function returns whether the payment instruction is enabled for the passed
--shipment or not.
FUNCTION IS_CLM_PAY_INSTRUCTION_ENABLED
  (  p_po_line_location_id  IN  NUMBER,
     p_invoice_type         IN  VARCHAR2
  ) RETURN BOOLEAN

IS

BEGIN

  RETURN(FALSE);

END IS_CLM_PAY_INSTRUCTION_ENABLED;

END PO_CLM_PAY_INSTR_PKG;


/
