--------------------------------------------------------
--  DDL for Package Body PO_NOTIFICATION_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_NOTIFICATION_UTIL" AS
/* $Header: PONOTIFUTLB.pls 120.0.12010000.4 2013/04/04 23:23:33 pravprak noship $ */
Function getTax(p_document_id po_headers_all.po_header_id%TYPE) return number
is

X_precision        number;
X_ext_precision    number;
X_min_acct_unit    number;
lv_tax_region        varchar2(30);        --tax region code
ln_jai_excl_nr_tax   NUMBER;              --exclusive non-recoverable tax
lv_document_type     VARCHAR2(25);        --document type
l_currency_code    fnd_currencies.CURRENCY_CODE%TYPE;
l_org_id           po_headers.org_id%TYPE;
l_tax_amt Number;

Begin

select poh.org_id,poh.TYPE_LOOKUP_CODE,gls.currency_code
into l_org_id,lv_document_type,l_currency_code
from po_headers_all poh, financials_system_params_all fsp,
  gl_sets_of_books gls
where poh.po_header_id = p_document_id
and fsp.set_of_books_id = gls.set_of_books_id
AND fsp.org_id            = poh.org_id;

  lv_tax_region      := JAI_PO_WF_UTIL_PUB.Get_Tax_Region (pn_org_id => l_org_id);

  IF (lv_tax_region ='JAI')
  THEN
    --Get document type

    --Indian localization tax calculation
    IF  lv_document_type = 'RELEASE'
    THEN
      JAI_PO_WF_UTIL_PUB.Get_Jai_Tax_Amount
      ( pv_document_type      => JAI_PO_WF_UTIL_PUB.G_REL_DOC_TYPE
      , pn_document_id        => p_document_id
      , xn_excl_tax_amount    => l_tax_amt
      , xn_excl_nr_tax_amount => ln_jai_excl_nr_tax
      );

    ELSE
      JAI_PO_WF_UTIL_PUB.Get_Jai_Tax_Amount
      ( pv_document_type      => JAI_PO_WF_UTIL_PUB.G_PO_DOC_TYPE
      , pn_document_id        => p_document_id
      , xn_excl_tax_amount    => l_tax_amt
      , xn_excl_nr_tax_amount => ln_jai_excl_nr_tax
      );
    END IF; --(lv_document_type = 'RELEASE')
  ELSE
    --original tax calc code

    fnd_currency.get_info( l_currency_code,
                            X_precision,
                            X_ext_precision,
                            X_min_acct_unit);


    IF (x_min_acct_unit IS NOT NULL) AND
        (x_min_acct_unit <> 0)
    THEN
      SELECT sum( round (POD.nonrecoverable_tax *
                         decode(quantity_ordered,
                                NULL,
                                (nvl(POD.amount_ordered,0) - nvl(POD.amount_cancelled,0)) / decode (nvl(POD.amount_ordered, 1),0,1,nvl(POD.amount_ordered, 1) ),
                                (nvl(POD.quantity_ordered,0) - nvl(POD.quantity_cancelled,0)) / decode ( nvl(POD.quantity_ordered, 1),0,1,nvl(POD.quantity_ordered, 1) )
                               ) / X_min_acct_unit
                         ) * X_min_acct_unit
                )
      INTO l_tax_amt
      FROM po_lines pol,
           po_distributions pod
     WHERE pol.po_header_id = p_document_id
       AND pod.po_line_id = pol.po_line_id;
    ELSE
      SELECT sum( round (POD.nonrecoverable_tax *
                         decode(quantity_ordered,
                                NULL,
                                (nvl(POD.amount_ordered,0) - nvl(POD.amount_cancelled,0)) / decode ( nvl(POD.amount_ordered, 1),0,1,nvl(POD.amount_ordered, 1) ),
                                (nvl(POD.quantity_ordered,0) - nvl(POD.quantity_cancelled,0)) / decode (nvl(POD.quantity_ordered, 1),0,1,nvl(POD.quantity_ordered, 1) )
                               ),
                         X_precision
                        )
                )
      INTO l_tax_amt
      FROM po_lines pol,
           po_distributions pod
     WHERE pol.po_header_id = p_document_id
       AND pod.po_line_id = pol.po_line_id;
    END IF;
  END IF;

  return l_tax_amt;
end getTax;



END PO_NOTIFICATION_UTIL;

/
