--------------------------------------------------------
--  DDL for Package JTF_IH_RESULT_REASONS_SEED_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_IH_RESULT_REASONS_SEED_PUB" AUTHID CURRENT_USER AS
 /* $Header: JTFIHRRS.pls 115.2 2001/11/09 19:00:28 pkm ship      $ */

     PROCEDURE insert_row(
          x_rowid                          IN OUT VARCHAR2
        , x_result_id                        NUMBER
        , x_reason_id                        NUMBER
        , x_object_version_number            NUMBER
        , x_created_by                       NUMBER
        , x_creation_date                    DATE
        , x_last_updated_by                  NUMBER
        , x_last_update_date                 DATE
        , x_last_update_login                NUMBER
     );

     PROCEDURE delete_row(
        x_result_id                        NUMBER
     );

     PROCEDURE update_row(
          x_rowid                          VARCHAR2
        , x_result_id                      NUMBER
        , x_reason_id                      NUMBER
        , x_object_version_number          NUMBER
        , x_created_by                     NUMBER
        , x_creation_date                  DATE
        , x_last_updated_by                NUMBER
        , x_last_update_date               DATE
        , x_last_update_login              NUMBER
     );

     PROCEDURE lock_row(
          x_rowid                          VARCHAR2
        , x_result_id                      NUMBER
        , x_reason_id                      NUMBER
        , x_object_version_number          NUMBER
        , x_created_by                     NUMBER
        , x_creation_date                  DATE
        , x_last_updated_by                NUMBER
        , x_last_update_date               DATE
        , x_last_update_login              NUMBER
     );
END jtf_ih_result_reasons_seed_pub;

 

/
