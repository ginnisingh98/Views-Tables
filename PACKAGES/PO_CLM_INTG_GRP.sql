--------------------------------------------------------
--  DDL for Package PO_CLM_INTG_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_CLM_INTG_GRP" AUTHID CURRENT_USER AS
                -- $Header: PO_CLM_INTG_GRP.pls 120.0.12010000.5 2010/06/03 12:17:44 grohit noship $

		--  This function will determine whether a PO is a clm PO.
    FUNCTION is_clm_po
                            (
                                    p_po_header_id        IN NUMBER DEFAULT NULL,
                                    p_po_line_id          IN NUMBER DEFAULT NULL,
                                    p_po_line_location_id IN NUMBER DEFAULT NULL,
                                    p_po_distribution_id  IN NUMBER DEFAULT NULL
                            )
                RETURN VARCHAR2;

		--  This function will determine whether CLM is installed
	FUNCTION is_clm_installed
                RETURN VARCHAR2;

        -- This function will determine wheter its a clm document or Not
	FUNCTION is_clm_document(p_doc_type IN VARCHAR2, p_document_id IN NUMBER) RETURN VARCHAR2;

		-- This procedure returns the PO Funding Information for a given entity id
	PROCEDURE Get_Funding_Info
                                    (
                                            p_PO_HEADER_ID		IN NUMBER DEFAULT NULL,
                                            p_PO_LINE_ID		IN NUMBER DEFAULT NULL,
                                            p_LINE_LOCATION_ID		IN NUMBER DEFAULT NULL,
                                            p_PO_DISTRIBUTION_ID	IN NUMBER DEFAULT NULL,
                                            x_DISTRIBUTION_TYPE		OUT NOCOPY VARCHAR2,
                                            x_MATCHING_BASIS		OUT NOCOPY VARCHAR2,
                                            x_ACCRUE_ON_RECEIPT_FLAG	OUT NOCOPY VARCHAR2,
                                            x_CODE_COMBINATION_ID	OUT NOCOPY NUMBER,
                                            x_BUDGET_ACCOUNT_ID		OUT NOCOPY NUMBER,
                                            x_PARTIAL_FUNDED_FLAG	OUT NOCOPY VARCHAR2,
					    x_UNIT_MEAS_LOOKUP_CODE	OUT NOCOPY VARCHAR2,
                                            x_FUNDED_VALUE		OUT NOCOPY NUMBER,
                                            x_QUANTITY_FUNDED		OUT NOCOPY NUMBER,
                                            x_AMOUNT_FUNDED		OUT NOCOPY NUMBER,
                                            x_QUANTITY_RECEIVED		OUT NOCOPY NUMBER,
                                            x_AMOUNT_RECEIVED		OUT NOCOPY NUMBER,
                                            x_QUANTITY_DELIVERED	OUT NOCOPY NUMBER,
                                            x_AMOUNT_DELIVERED		OUT NOCOPY NUMBER,
                                            x_QUANTITY_BILLED		OUT NOCOPY NUMBER,
                                            x_AMOUNT_BILLED		OUT NOCOPY NUMBER,
					    x_quantity_cancelled 	OUT NOCOPY NUMBER,
					    x_amount_cancelled 		OUT NOCOPY NUMBER,
                                            X_RETURN_STATUS		OUT NOCOPY VARCHAR2
                                    );

        END PO_CLM_INTG_GRP;

/