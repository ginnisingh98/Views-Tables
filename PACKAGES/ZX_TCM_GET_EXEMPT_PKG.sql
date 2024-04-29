--------------------------------------------------------
--  DDL for Package ZX_TCM_GET_EXEMPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TCM_GET_EXEMPT_PKG" AUTHID CURRENT_USER AS
/* $Header: zxcgetexempts.pls 120.8.12010000.1 2008/07/28 13:29:05 appldev ship $ */

TYPE exemption_rec_type IS RECORD
  (exemption_id                NUMBER,
   percent_exempt              NUMBER,
   discount_special_rate       VARCHAR2(30),
   apply_to_lower_levels_flag  VARCHAR2(1),
   exempt_reason_code          VARCHAR2(30),
   exempt_reason               VARCHAR2(240),
   exempt_certificate_number   VARCHAR2(80)
   );

/*TYPE tax_jurisdiction_rec_type IS RECORD
  (tax_jurisdiction_id     NUMBER,
   tax_jurisdiction_code   VARCHAR2(30)
   );

TYPE tax_jurisdiction_tbl_type IS TABLE of tax_jurisdiction_rec_type INDEX BY BINARY_INTEGER;
*/

PROCEDURE get_tax_exemptions(p_bill_to_cust_site_use_id      IN NUMBER,
                             p_bill_to_cust_acct_id          IN NUMBER,
                             p_bill_to_party_site_ptp_id     IN NUMBER,
                             p_bill_to_party_ptp_id          IN NUMBER,
                             p_sold_to_party_site_ptp_id     IN NUMBER,
                             p_sold_to_party_ptp_id          IN NUMBER,
                             p_inventory_org_id              IN NUMBER,
                             p_inventory_item_id             IN NUMBER,
                             p_exempt_certificate_number     IN VARCHAR2,
                             p_reason_code                   IN VARCHAR2,
                             p_exempt_control_flag           IN VARCHAR2,
                             p_tax_date                      IN DATE,
                             p_tax_regime_code               IN VARCHAR2,
                             p_tax                           IN VARCHAR2,
                             p_tax_status_code               IN VARCHAR2,
                             p_tax_rate_code                 IN VARCHAR2,
                             p_tax_jurisdiction_id           IN NUMBER,
                             p_multiple_jurisdictions_flag   IN VARCHAR2,
                             p_event_class_rec               IN zx_api_pub.event_class_rec_type,
                             x_return_status                 OUT NOCOPY VARCHAR2,
                             x_exemption_rec                 OUT NOCOPY exemption_rec_type);

END;

/
