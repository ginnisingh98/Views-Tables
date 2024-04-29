--------------------------------------------------------
--  DDL for Package IEO_SVR_VALUES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEO_SVR_VALUES_PVT" AUTHID CURRENT_USER AS
/* $Header: IEOSVRVS.pls 120.1 2005/06/12 01:22:33 appldev  $ */

     PROCEDURE insert_row(
          x_rowid                          IN OUT NOCOPY VARCHAR2
        , x_value_id                         NUMBER
        , x_created_by                       NUMBER
        , x_creation_date                    DATE
        , x_last_updated_by                  NUMBER
        , x_last_update_date                 DATE
        , x_last_update_login                NUMBER
        , x_value_index                      NUMBER
        , x_param_id                         NUMBER
        , x_server_id                        NUMBER
        , x_value                            VARCHAR2
     );

     PROCEDURE delete_row(
        x_value_id                         NUMBER
     );

     PROCEDURE update_row(
          x_rowid                          VARCHAR2
        , x_value_id                       NUMBER
        , x_created_by                     NUMBER
        , x_creation_date                  DATE
        , x_last_updated_by                NUMBER
        , x_last_update_date               DATE
        , x_last_update_login              NUMBER
        , x_value_index                    NUMBER
        , x_param_id                       NUMBER
        , x_server_id                      NUMBER
        , x_value                          VARCHAR2
     );

     PROCEDURE lock_row(
          x_rowid                          VARCHAR2
        , x_value_id                       NUMBER
        , x_created_by                     NUMBER
        , x_creation_date                  DATE
        , x_last_updated_by                NUMBER
        , x_last_update_date               DATE
        , x_last_update_login              NUMBER
        , x_value_index                    NUMBER
        , x_param_id                       NUMBER
        , x_server_id                      NUMBER
        , x_value                          VARCHAR2
     );
END ieo_svr_values_pvt;

 

/
