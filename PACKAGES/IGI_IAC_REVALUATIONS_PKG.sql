--------------------------------------------------------
--  DDL for Package IGI_IAC_REVALUATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_REVALUATIONS_PKG" AUTHID CURRENT_USER AS
-- $Header: igiiarxs.pls 120.6.12010000.2 2008/08/04 13:03:14 sasukuma ship $

  PROCEDURE insert_row (
    X_rowid                             IN OUT NOCOPY  VARCHAR2,
    X_revaluation_id                    IN OUT NOCOPY  NUMBER,
    X_book_type_code                    IN      VARCHAR2,
    X_revaluation_date                  IN      DATE,
    X_revaluation_period                IN      VARCHAR2,
    X_status                            IN      VARCHAR2,
    X_reval_request_id                  IN      NUMBER,
    X_create_request_id                 IN      NUMBER,
    X_calling_program                   IN      VARCHAR2,
    X_mode                              IN      VARCHAR2    DEFAULT 'R',
    X_event_id                          IN      NUMBER           -- for R12 SLA upgrade
  );

  PROCEDURE delete_row (
    x_revaluation_id                    IN      NUMBER
  );

END igi_iac_revaluations_pkg;

/
