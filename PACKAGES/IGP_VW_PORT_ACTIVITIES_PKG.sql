--------------------------------------------------------
--  DDL for Package IGP_VW_PORT_ACTIVITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGP_VW_PORT_ACTIVITIES_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPVWCS.pls 120.0 2005/06/01 19:07:38 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_activity_id                       IN OUT NOCOPY NUMBER,
    x_portfolio_id                      IN     NUMBER,
    x_org_party_id                      IN     NUMBER,
    x_access_date	                IN     DATE,
    x_note                              IN     VARCHAR2,
    x_object_version_number             IN     NUMBER,
    x_pincode                           IN     VARCHAR2,
    x_party_id                          IN     NUMBER,
    x_ACCESS_TYPE_CODE                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );
  PROCEDURE Insert_Row_Pub(
    x_msg_count			        OUT NOCOPY NUMBER,
    x_msg_data				OUT NOCOPY VARCHAR2,
    x_return_status                     OUT NOCOPY  VARCHAR2,
    x_rowid				IN OUT NOCOPY VARCHAR2,
    x_activity_id			IN OUT NOCOPY NUMBER,
    x_portfolio_id                      IN     NUMBER,
    x_access_date                       IN     DATE,
    x_note                              IN     VARCHAR2,
    x_object_version_number             IN     NUMBER,
    x_pincode                           IN     VARCHAR2,
    x_party_id                          IN     NUMBER,
    x_ACCESS_TYPE_CODE                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_activity_id                       IN     NUMBER      DEFAULT NULL,
    x_portfolio_id                      IN     NUMBER      DEFAULT NULL,
    x_org_party_id                      IN     NUMBER      DEFAULT NULL,
    x_access_date                       IN     DATE        DEFAULT NULL,
    x_note                              IN     VARCHAR2    DEFAULT NULL,
    x_object_version_number             IN     NUMBER      DEFAULT NULL,
    x_pincode                           IN     VARCHAR2    DEFAULT NULL,
    x_party_id                          IN     NUMBER      DEFAULT NULL,
    x_ACCESS_TYPE_CODE                  IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END IGP_VW_PORT_ACTIVITIES_pkg;

 

/
