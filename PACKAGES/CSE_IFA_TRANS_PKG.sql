--------------------------------------------------------
--  DDL for Package CSE_IFA_TRANS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSE_IFA_TRANS_PKG" AUTHID CURRENT_USER AS
-- $Header: CSEIFATS.pls 115.3 2002/11/11 22:04:12 jpwilson noship $
PROCEDURE transfer_fa_distribution
    (p_asset_id              IN NUMBER,
     p_book_type_code        IN VARCHAR2,
     p_units                 IN NUMBER,
     p_from_location_id      IN NUMBER,
     p_from_expense_ccid     IN NUMBER,
     p_from_employee_id      IN NUMBER DEFAULT NULL,
     p_to_location_id        IN NUMBER,
     p_to_expense_ccid       IN NUMBER,
     p_to_employee_id        IN NUMBER DEFAULT NULL,
     x_new_from_dist_id      OUT NOCOPY NUMBER,
     x_new_to_dist_id        OUT NOCOPY NUMBER,
     x_return_status         OUT NOCOPY VARCHAR2,
     x_error_msg             OUT NOCOPY VARCHAR2
    );

PROCEDURE adjust_fa_distribution
    (p_asset_id              IN NUMBER,
     p_book_type_code        IN VARCHAR2,
     p_units                 IN NUMBER,
     p_location_id           IN NUMBER,
     p_expense_ccid          IN NUMBER,
     p_employee_id           IN NUMBER DEFAULT NULL,
     x_new_dist_id           OUT NOCOPY NUMBER,
     x_return_status         OUT NOCOPY VARCHAR2,
     x_error_msg             OUT NOCOPY VARCHAR2
    );

END CSE_IFA_TRANS_PKG;

 

/
