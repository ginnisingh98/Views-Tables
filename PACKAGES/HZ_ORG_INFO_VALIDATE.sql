--------------------------------------------------------
--  DDL for Package HZ_ORG_INFO_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_ORG_INFO_VALIDATE" AUTHID CURRENT_USER as
/* $Header: ARHORIVS.pls 120.1 2005/06/16 21:13:14 jhuang ship $ */

procedure validate_stock_markets(
        p_stock_markets_rec        IN  HZ_ORG_INFO_PUB.stock_markets_rec_type,
        p_create_update_flag       IN  VARCHAR2,
        x_return_status            IN OUT  NOCOPY VARCHAR2
        );

procedure validate_security_issued(
        p_security_issued_rec      IN  HZ_ORG_INFO_PUB.security_issued_rec_type,
        p_create_update_flag       IN  VARCHAR2,
        x_return_status            IN OUT  NOCOPY VARCHAR2
        );

procedure validate_financial_reports(
        p_financial_reports_rec    IN  HZ_ORG_INFO_PUB.financial_reports_rec_type,
        p_create_update_flag       IN  VARCHAR2,
        x_return_status            IN OUT  NOCOPY VARCHAR2
        );

procedure validate_financial_numbers(
        p_financial_numbers_rec    IN  HZ_ORG_INFO_PUB.financial_numbers_rec_type,
        p_create_update_flag       IN  VARCHAR2,
        x_return_status            IN OUT  NOCOPY VARCHAR2,
        x_rep_content_source_type  OUT  NOCOPY VARCHAR2,
        x_rep_actual_content_source     OUT  NOCOPY VARCHAR2
        );

procedure validate_certifications(
        p_certifications_rec       IN  HZ_ORG_INFO_PUB.certifications_rec_type,
        p_create_update_flag       IN  VARCHAR2,
        x_return_status            IN OUT  NOCOPY VARCHAR2
        );

procedure validate_industrial_reference(
        p_industrial_reference_rec IN  HZ_ORG_INFO_PUB.industrial_reference_rec_type,
        p_create_update_flag       IN  VARCHAR2,
        x_return_status            IN OUT  NOCOPY VARCHAR2
        );

procedure validate_industrial_classes(
        p_industrial_classes_rec   IN  HZ_ORG_INFO_PUB.industrial_classes_rec_type,
        p_create_update_flag       IN  VARCHAR2,
        x_return_status            IN OUT  NOCOPY VARCHAR2
        );

procedure validate_industrial_class_app(
        p_industrial_class_app_rec IN  HZ_ORG_INFO_PUB.industrial_class_app_rec_type,
        p_create_update_flag       IN  VARCHAR2,
        x_return_status            IN OUT  NOCOPY VARCHAR2
        );


END HZ_ORG_INFO_VALIDATE;

 

/
