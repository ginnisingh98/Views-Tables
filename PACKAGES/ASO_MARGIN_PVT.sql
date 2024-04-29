--------------------------------------------------------
--  DDL for Package ASO_MARGIN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_MARGIN_PVT" AUTHID CURRENT_USER AS
/* $Header: asovgmrs.pls 120.0.12010000.2 2015/05/28 19:45:49 rassharm noship $ */


FUNCTION Get_Cost (p_line_rec       IN   ASO_QUOTE_PUB.Qte_Line_Rec_Type   DEFAULT ASO_QUOTE_PUB.G_MISS_QTE_LINE_REC

		  ) RETURN NUMBER;

--Input line Record
--Output unit cost, margin amount and percent
Procedure Get_Line_Margin(p_qte_line_id IN NUMBER,
                          x_unit_cost Out NOCOPY Number,
                          x_unit_margin_amount Out NOCOPY Number,
                          x_margin_percent Out NOCOPY Number);


PROCEDURE Get_Quote_Margin
(p_qte_header_id              IN  NUMBER,
p_org_id  IN NUMBER default NULL,
x_quote_unit_cost OUT NOCOPY NUMBER,
x_quote_margin_percent OUT NOCOPY NUMBER,
x_quote_margin_amount OUT NOCOPY NUMBER);


End  ASO_MARGIN_PVT;

/
