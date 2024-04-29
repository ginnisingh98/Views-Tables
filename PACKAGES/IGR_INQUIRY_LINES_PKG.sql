--------------------------------------------------------
--  DDL for Package IGR_INQUIRY_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGR_INQUIRY_LINES_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSRT04S.pls 120.0 2005/06/01 16:38:50 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_sales_lead_line_id                OUT NOCOPY    NUMBER,
    x_person_id                         IN     NUMBER,
    x_enquiry_appl_number               IN     NUMBER,
    x_enquiry_dt                        IN     DATE,
    x_inquiry_method_code               IN     VARCHAR2,
    x_preference                        IN     NUMBER DEFAULT NULL,
    x_ret_status                        OUT NOCOPY VARCHAR2,
    x_msg_data                          OUT NOCOPY VARCHAR2,
    x_msg_count                         OUT NOCOPY NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_product_category_id               IN  NUMBER,
    x_product_category_set_id           IN  NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_sales_lead_line_id                IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_enquiry_appl_number               IN     NUMBER,
    x_enquiry_dt                        IN     DATE,
    x_inquiry_method_code               IN     VARCHAR2,
    x_preference                        IN     NUMBER DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_ret_status                        OUT NOCOPY VARCHAR2,
    x_msg_data                          OUT NOCOPY VARCHAR2,
    x_msg_count                         OUT NOCOPY NUMBER,
    x_product_category_id               IN  NUMBER,
    x_product_category_set_id           IN  NUMBER
  );

  FUNCTION get_uk_for_validation (
    x_person_id           IN     NUMBER,
    x_enquiry_appl_number  IN     NUMBER,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_product_category_id               IN  NUMBER,
    x_product_category_set_id           IN  NUMBER
  ) RETURN BOOLEAN ;

END IGR_INQUIRY_LINES_PKG;

 

/
