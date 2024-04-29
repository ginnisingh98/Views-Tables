--------------------------------------------------------
--  DDL for Package IGR_I_A_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGR_I_A_LINES_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSRH17S.pls 120.0 2005/06/01 22:06:12 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_enquiry_appl_number               IN     NUMBER,
    x_sales_lead_line_id                IN     NUMBER,
    x_preference                        IN     NUMBER  DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_enquiry_appl_number               IN     NUMBER,
    x_sales_lead_line_id                IN     NUMBER,
    x_preference                        IN     NUMBER  DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_enquiry_appl_number               IN     NUMBER,
    x_sales_lead_line_id                IN     NUMBER,
    x_preference                        IN     NUMBER  DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_enquiry_appl_number               IN     NUMBER,
    x_sales_lead_line_id                IN     NUMBER,
    x_preference                        IN     NUMBER  DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_sales_lead_line_id                IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igr_i_appl (
    x_person_id                         IN     NUMBER,
    x_enquiry_appl_number               IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_enquiry_appl_number               IN     NUMBER      DEFAULT NULL,
    x_sales_lead_line_id                IN     NUMBER      DEFAULT NULL,
    x_preference                        IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igr_i_a_lines_pkg;

 

/
