--------------------------------------------------------
--  DDL for Package Body INV_FA_INTERFACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_FA_INTERFACE_PVT" AS
/* $Header: INVFAAPB.pls 115.1 2003/08/14 23:11:25 vputcha noship $ */

--  Global constant holding the package name
G_PKG_NAME  CONSTANT VARCHAR2(30) := 'INV_FA_INTERFACE_PVT';
-- Package global

FUNCTION Get_IC_CCID(p_inv_dist_id             IN    NUMBER,
                     p_inv_cc_id               IN    NUMBER,
                     p_line_type               IN    VARCHAR2 )
RETURN NUMBER IS

l_trx_src_line_id    NUMBER := NULL;
l_dist_cc_id         NUMBER := NULL;
l_temp_cc_id         NUMBER := NULL;
BEGIN

  l_dist_cc_id := p_inv_cc_id;

  BEGIN
     SELECT MMT.trx_source_line_id
     INTO   l_trx_src_line_id
     FROM   ap_invoice_distributions_all APINVD
        ,   ra_customer_trx_lines_all RCTL
        ,   mtl_material_transactions MMT
     WHERE   APINVD.invoice_distribution_id = p_inv_dist_id
     AND     RCTL.customer_trx_line_id = to_number(APINVD.reference_1)
     AND     RCTL.interface_line_context = 'INTERCOMPANY'
     AND     MMT.transaction_id = to_number(RCTL.interface_line_attribute7)
     AND     MMT.transaction_source_type_id = 8
     AND     MMT.transaction_action_id = 21;
  EXCEPTION WHEN OTHERS THEN
    Return(l_dist_cc_id);
  END;

  if (l_trx_src_line_id IS NOT NULL ) then

    BEGIN
      SELECT   PORD.code_combination_id
      INTO     l_temp_cc_id
      FROM     oe_order_lines_all OEL
         ,     po_req_distributions_all PORD
      WHERE    OEL.line_id = l_trx_src_line_id
      AND      OEL.source_document_type_id = 10
      AND      PORD.requisition_line_id = OEL.source_document_line_id
      GROUP BY PORD.code_combination_id;

      l_dist_cc_id := l_temp_cc_id;

    EXCEPTION WHEN OTHERS THEN
      Return(l_dist_cc_id);
    END;

  end if;

  Return(l_dist_cc_id);

EXCEPTION

    WHEN OTHERS THEN
       l_dist_cc_id := p_inv_cc_id;
       Return(l_dist_cc_id);
END;



FUNCTION Get_REF_CCID(p_inv_ref_id             IN    VARCHAR2,
                      p_inv_cc_id              IN    NUMBER,
                      p_line_type              IN    VARCHAR2 )
RETURN NUMBER IS

l_trx_src_line_id    NUMBER := NULL;
l_dist_cc_id         NUMBER := NULL;
l_temp_cc_id         NUMBER := NULL;
BEGIN

  l_dist_cc_id := p_inv_cc_id;

  if (p_inv_ref_id is NULL) then
     Return(l_dist_cc_id);
  end if;

  BEGIN
     SELECT MMT.trx_source_line_id
     INTO   l_trx_src_line_id
     FROM   ra_customer_trx_lines_all RCTL
        ,   mtl_material_transactions MMT
     WHERE  RCTL.customer_trx_line_id = to_number(p_inv_ref_id)
     AND    RCTL.interface_line_context = 'INTERCOMPANY'
     AND    MMT.transaction_id = to_number(RCTL.interface_line_attribute7)
     AND    MMT.transaction_source_type_id = 8
     AND    MMT.transaction_action_id = 21;
  EXCEPTION WHEN OTHERS THEN
    Return(l_dist_cc_id);
  END;

  if (l_trx_src_line_id IS NOT NULL ) then

    BEGIN
      SELECT   PORD.code_combination_id
      INTO     l_temp_cc_id
      FROM     oe_order_lines_all OEL
         ,     po_req_distributions_all PORD
      WHERE    OEL.line_id = l_trx_src_line_id
      AND      OEL.source_document_type_id = 10
      AND      PORD.requisition_line_id = OEL.source_document_line_id
      GROUP BY PORD.code_combination_id;

      l_dist_cc_id := l_temp_cc_id;

    EXCEPTION WHEN OTHERS THEN
      Return(l_dist_cc_id);
    END;

  end if;

  Return(l_dist_cc_id);

EXCEPTION

    WHEN OTHERS THEN
       l_dist_cc_id := p_inv_cc_id;
       Return(l_dist_cc_id);
END;


END INV_FA_INTERFACE_PVT;

/
