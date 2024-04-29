--------------------------------------------------------
--  DDL for Package IEO_SVR_SERVERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEO_SVR_SERVERS_PVT" AUTHID CURRENT_USER AS
/* $Header: IEOSVRSS.pls 120.1 2005/06/12 01:22:03 appldev  $ */


     PROCEDURE insert_row(
          x_rowid                          IN OUT NOCOPY VARCHAR2
        , x_server_id                        NUMBER
        , x_created_by                       NUMBER
        , x_creation_date                    DATE
        , x_last_updated_by                  NUMBER
        , x_last_update_date                 DATE
        , x_last_update_login                NUMBER
        , x_type_id                          NUMBER
        , x_server_name                      VARCHAR2
        , x_member_svr_group_id              NUMBER
        , x_using_svr_group_id               NUMBER
        , x_dns_name                         VARCHAR2
        , x_ip_address                       VARCHAR2
        , x_location                         VARCHAR2
        , x_description                      VARCHAR2
        , x_user_address                     VARCHAR2
     );

     PROCEDURE delete_row(
        x_server_id                        NUMBER
     );

     PROCEDURE update_row(
          x_rowid                          VARCHAR2
        , x_server_id                      NUMBER
        , x_created_by                     NUMBER
        , x_creation_date                  DATE
        , x_last_updated_by                NUMBER
        , x_last_update_date               DATE
        , x_last_update_login              NUMBER
        , x_type_id                        NUMBER
        , x_server_name                    VARCHAR2
        , x_member_svr_group_id            NUMBER
        , x_using_svr_group_id             NUMBER
        , x_dns_name                       VARCHAR2
        , x_ip_address                     VARCHAR2
        , x_location                       VARCHAR2
        , x_description                    VARCHAR2
        , x_user_address                   VARCHAR2
     );

     PROCEDURE lock_row(
          x_rowid                          VARCHAR2
        , x_server_id                      NUMBER
        , x_created_by                     NUMBER
        , x_creation_date                  DATE
        , x_last_updated_by                NUMBER
        , x_last_update_date               DATE
        , x_last_update_login              NUMBER
        , x_type_id                        NUMBER
        , x_server_name                    VARCHAR2
        , x_member_svr_group_id            NUMBER
        , x_using_svr_group_id             NUMBER
        , x_dns_name                       VARCHAR2
        , x_ip_address                     VARCHAR2
        , x_location                       VARCHAR2
        , x_description                    VARCHAR2
        , x_user_address                   VARCHAR2
     );
END ieo_svr_servers_pvt;

 

/
