--------------------------------------------------------
--  DDL for Package IGS_AS_DUP_DOCS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_DUP_DOCS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSDI76S.pls 115.2 2002/11/28 23:30:57 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_order_number                      IN     NUMBER,
    x_item_number                       IN     NUMBER,
    x_requested_by                      IN     NUMBER,
    x_requested_date                    IN     DATE,
    x_fulfilled_by                      IN     NUMBER,
    x_fulfilled_date                    IN     DATE,
    x_return_status                     OUT NOCOPY    VARCHAR2,
    x_msg_data                          OUT NOCOPY    VARCHAR2,
    x_msg_count                         OUT NOCOPY    NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_order_number                      IN     NUMBER,
    x_item_number                       IN     NUMBER,
    x_requested_by                      IN     NUMBER,
    x_requested_date                    IN     DATE,
    x_fulfilled_by                      IN     NUMBER,
    x_fulfilled_date                    IN     DATE,
    x_return_status                     OUT NOCOPY    VARCHAR2,
    x_msg_data                          OUT NOCOPY    VARCHAR2,
    x_msg_count                         OUT NOCOPY    NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_order_number                      IN     NUMBER,
    x_item_number                       IN     NUMBER,
    x_requested_by                      IN     NUMBER,
    x_requested_date                    IN     DATE,
    x_fulfilled_by                      IN     NUMBER,
    x_fulfilled_date                    IN     DATE,
    x_return_status                     OUT NOCOPY    VARCHAR2,
    x_msg_data                          OUT NOCOPY    VARCHAR2,
    x_msg_count                         OUT NOCOPY    NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_order_number                      IN     NUMBER      DEFAULT NULL,
    x_item_number                       IN     NUMBER      DEFAULT NULL,
    x_requested_by                      IN     NUMBER      DEFAULT NULL,
    x_requested_date                    IN     DATE        DEFAULT NULL,
    x_fulfilled_by                      IN     NUMBER      DEFAULT NULL,
    x_fulfilled_date                    IN     DATE        DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_as_dup_docs_pkg;

 

/
