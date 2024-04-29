--------------------------------------------------------
--  DDL for Package PO_CORE_S2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_CORE_S2" AUTHID CURRENT_USER AS
/* $Header: POXCOC2S.pls 120.4.12010000.2 2012/08/16 14:50:24 ksrimatk ship $*/

PROCEDURE GET_REQ_CURRENCY (x_object_id       IN NUMBER,
                            x_base_currency  OUT NOCOPY VARCHAR2,
                            p_org_id          IN NUMBER);--bug#5092574


PROCEDURE GET_CURRENCY_INFO (x_currency_code IN VARCHAR2,
                             x_precision    OUT NOCOPY NUMBER,
                             x_min_unit     OUT NOCOPY NUMBER );

/* Bug# 14376121: Added to include default values for precision and extended precision */
PROCEDURE GET_CURRENCY_INFO_DETAILS (p_currency_code IN VARCHAR2,
                                    x_precision    OUT NOCOPY NUMBER,
                                    x_ext_precision    OUT NOCOPY NUMBER,
                                    x_min_unit     OUT NOCOPY NUMBER );

PROCEDURE GET_PO_CURRENCY (x_object_id      IN NUMBER,
                           x_base_currency OUT NOCOPY VARCHAR2,
                           x_po_currency   OUT NOCOPY VARCHAR2);


FUNCTION get_base_currency return VARCHAR2;

PROCEDURE GET_PO_CURRENCY_INFO (p_po_header_id      IN NUMBER,
                                x_currency_code     OUT NOCOPY VARCHAR2,
                                x_curr_rate_type    OUT NOCOPY VARCHAR2,
                                x_curr_rate_date    OUT NOCOPY DATE,
                                x_currency_rate     OUT NOCOPY NUMBER);

--<ENCUMBRANCE FPJ START>
--Added a centralized, bulk routine for currency conversion and rounding
PROCEDURE round_and_convert_currency(
   x_return_status                OUT    NOCOPY VARCHAR2
,  p_unique_id_tbl                IN     PO_TBL_NUMBER  --bug 4878973
,  p_amount_in_tbl                IN     PO_TBL_NUMBER
,  p_exchange_rate_tbl            IN     PO_TBL_NUMBER
,  p_from_currency_precision_tbl  IN     PO_TBL_NUMBER
,  p_from_currency_mau_tbl        IN     PO_TBL_NUMBER
,  p_to_currency_precision_tbl    IN     PO_TBL_NUMBER
,  p_to_currency_mau_tbl          IN     PO_TBL_NUMBER
,  p_round_only_flag_tbl          IN     PO_TBL_VARCHAR1  --bug 3568671
,  x_amount_out_tbl               OUT    NOCOPY PO_TBL_NUMBER
);
--<ENCUMBRANCE FPJ END>
--<R12 MOAC START>
FUNCTION get_base_currency(p_org_id po_system_parameters_all.org_id%TYPE)
RETURN   VARCHAR2;
--<R12 MOAC END>


END PO_CORE_S2;

/
