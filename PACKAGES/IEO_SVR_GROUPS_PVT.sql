--------------------------------------------------------
--  DDL for Package IEO_SVR_GROUPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEO_SVR_GROUPS_PVT" AUTHID CURRENT_USER AS
/* $Header: IEOSVRGS.pls 120.1 2005/06/12 01:21:40 appldev  $ */


     PROCEDURE insert_row(
          x_rowid                          IN OUT NOCOPY VARCHAR2
        , x_server_group_id                  NUMBER
        , x_created_by                       NUMBER
        , x_creation_date                    DATE
        , x_last_updated_by                  NUMBER
        , x_last_update_date                 DATE
        , x_last_update_login                NUMBER
        , x_group_name                       VARCHAR2
        , x_group_group_id                   NUMBER
        , x_location                         VARCHAR2
        , x_description                      VARCHAR2
     );

     PROCEDURE delete_row(
        x_server_group_id                  NUMBER
     );

     PROCEDURE update_row(
          x_rowid                          VARCHAR2
        , x_server_group_id                NUMBER
        , x_created_by                     NUMBER
        , x_creation_date                  DATE
        , x_last_updated_by                NUMBER
        , x_last_update_date               DATE
        , x_last_update_login              NUMBER
        , x_group_name                     VARCHAR2
        , x_group_group_id                 NUMBER
        , x_location                       VARCHAR2
        , x_description                    VARCHAR2
     );

     PROCEDURE lock_row(
          x_rowid                          VARCHAR2
        , x_server_group_id                NUMBER
        , x_created_by                     NUMBER
        , x_creation_date                  DATE
        , x_last_updated_by                NUMBER
        , x_last_update_date               DATE
        , x_last_update_login              NUMBER
        , x_group_name                     VARCHAR2
        , x_group_group_id                 NUMBER
        , x_location                       VARCHAR2
        , x_description                    VARCHAR2
     );
END ieo_svr_groups_pvt;

 

/
