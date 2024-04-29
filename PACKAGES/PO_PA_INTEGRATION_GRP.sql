--------------------------------------------------------
--  DDL for Package PO_PA_INTEGRATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_PA_INTEGRATION_GRP" AUTHID CURRENT_USER AS
/* $Header: POXGPAVS.pls 120.2 2008/04/28 08:35:13 adbharga ship $ */

PROCEDURE validate_temp_labor_po(p_api_version    IN NUMBER,
                                 p_project_id     IN NUMBER,
                                 p_task_id        IN NUMBER,
                                 p_po_number      IN VARCHAR2,--bug 7003781
                                 p_po_line_num    IN NUMBER,
                                 p_price_type     IN VARCHAR2,
                                 p_org_id         IN NUMBER,
                                 p_person_id      IN NUMBER,
                                 p_po_header_id   IN OUT NOCOPY NUMBER,
                                 p_po_line_id     IN OUT NOCOPY NUMBER,
                                 x_po_line_amt    OUT NOCOPY NUMBER,
                                 x_po_rate        OUT NOCOPY NUMBER,
                                 x_currency_code  OUT NOCOPY VARCHAR2,
                                 x_curr_rate_type OUT NOCOPY VARCHAR2,
                                 x_curr_rate_date OUT NOCOPY DATE,
                                 x_currency_rate  OUT NOCOPY NUMBER,
                                 x_vendor_id      OUT NOCOPY NUMBER,
                                 x_return_status  OUT NOCOPY VARCHAR2,
                                 x_message_code   OUT NOCOPY VARCHAR2,
                                 p_effective_date IN DATE DEFAULT NULL
                                );

FUNCTION is_rate_based_line (p_po_line_id         IN NUMBER,
                             p_po_distribution_id IN NUMBER)
RETURN BOOLEAN;

PROCEDURE get_line_rate_info (p_api_version    IN NUMBER,
                              p_price_type     IN VARCHAR2,
                              p_po_line_id     IN NUMBER,
                              p_project_id     IN NUMBER,
                              p_task_id        IN NUMBER,
                              x_po_rate        OUT NOCOPY NUMBER,
                              x_currency_code  OUT NOCOPY VARCHAR2,
                              x_curr_rate_type OUT NOCOPY VARCHAR2,
                              x_curr_rate_date OUT NOCOPY DATE,
                              x_currency_rate  OUT NOCOPY NUMBER,
                              x_vendor_id      OUT NOCOPY NUMBER,
                              x_return_status  OUT NOCOPY VARCHAR2,
                              x_message_code   OUT NOCOPY VARCHAR2
                             );

FUNCTION is_PO_active
    (p_person_id            IN         NUMBER
    ,p_effective_date       IN         DATE
    ,p_po_header_id         IN         NUMBER
    ,p_po_line_id           IN         NUMBER
    )
RETURN BOOLEAN;

END PO_PA_INTEGRATION_GRP;

/
