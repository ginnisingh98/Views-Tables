--------------------------------------------------------
--  DDL for Package ZX_TCM_GET_EXCEPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TCM_GET_EXCEPT_PKG" AUTHID CURRENT_USER AS
/* $Header: zxcgetexcepts.pls 120.2 2005/09/01 22:55:08 sachandr ship $ */

TYPE exception_rec_type IS RECORD
  (tax_exception_id        NUMBER,
   exception_type_code     VARCHAR2(30),
   exception_rate          NUMBER
   );

TYPE tax_jurisdiction_rec_type IS RECORD
  (tax_jurisdiction_id     NUMBER,
   tax_jurisdiction_code   VARCHAR2(30)
   );

TYPE tax_jurisdiction_tbl_type IS TABLE of tax_jurisdiction_rec_type INDEX BY BINARY_INTEGER;

PROCEDURE get_tax_exceptions(p_inventory_item_id IN NUMBER,
                             p_inventory_organization_id IN NUMBER,
                             p_product_category  IN VARCHAR2,
                             p_tax_regime_code   IN VARCHAR2,
                             p_tax               IN VARCHAR2,
                             p_tax_status_code   IN VARCHAR2,
                             p_tax_rate_code     IN VARCHAR2,
                             p_trx_date          IN DATE,
                             p_tax_jurisdiction_id IN NUMBER,
                             p_multiple_jurisdictions_flag   IN VARCHAR2,
                             x_exception_rec     OUT NOCOPY exception_rec_type,
                             x_return_status     OUT NOCOPY VARCHAR2);


END;

 

/
