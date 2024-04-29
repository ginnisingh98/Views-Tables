--------------------------------------------------------
--  DDL for Package IGS_PE_HZ_PTY_SITES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_HZ_PTY_SITES_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNIB5S.pls 120.2 2005/09/22 02:31:19 appldev ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_party_site_id                     IN OUT NOCOPY NUMBER,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_party_site_id                     IN     NUMBER,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_party_site_id                     IN     NUMBER,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_party_site_id                     IN OUT NOCOPY NUMBER,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
  );

  PROCEDURE BeforeRowInsertUpdate_ss(
    p_party_id  IN NUMBER,
    p_start_dt IN Date ,
    p_end_dt   IN Date
    );

  PROCEDURE BeforeRowInsertUpdate(
    p_party_site_id  IN NUMBER,
    p_start_dt IN Date ,
    p_end_dt   IN Date
    );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_party_site_id                     IN     NUMBER      DEFAULT NULL,
    x_start_date                        IN     DATE        DEFAULT NULL,
    x_end_date                          IN     DATE        DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_pe_hz_pty_sites_pkg;

 

/
