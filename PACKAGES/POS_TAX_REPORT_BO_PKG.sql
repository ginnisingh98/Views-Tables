--------------------------------------------------------
--  DDL for Package POS_TAX_REPORT_BO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_TAX_REPORT_BO_PKG" AUTHID CURRENT_USER AS
  /* $Header: POSSPTXRS.pls 120.0.12010000.2 2010/02/08 14:24:57 ntungare noship $ */

  PROCEDURE get_pos_tax_report_bo_tbl
  (
    p_api_version           IN NUMBER DEFAULT NULL,
    p_init_msg_list         IN VARCHAR2 DEFAULT NULL,
    p_party_id              IN NUMBER,
    p_orig_system           IN VARCHAR2,
    p_orig_system_reference IN VARCHAR2,
    x_pos_tax_report_bo_tbl OUT NOCOPY pos_tax_report_bo_tbl,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2
  );
  PROCEDURE create_pos_tax_report_bo_row
  (
    p_api_version           IN NUMBER DEFAULT NULL,
    p_init_msg_list         IN VARCHAR2 DEFAULT NULL,
    p_party_id              IN NUMBER,
    p_orig_system           IN VARCHAR2,
    p_orig_system_reference IN VARCHAR2,
    p_create_update_flag    IN VARCHAR2,
    p_pos_tax_report_bo     IN pos_tax_report_bo_tbl,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2
  );

END pos_tax_report_bo_pkg;

/
