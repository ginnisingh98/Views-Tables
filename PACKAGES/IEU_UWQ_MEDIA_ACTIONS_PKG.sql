--------------------------------------------------------
--  DDL for Package IEU_UWQ_MEDIA_ACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_UWQ_MEDIA_ACTIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: IEUMACLS.pls 120.0 2005/06/02 15:51:47 appldev noship $ */
     PROCEDURE insert_row(
          x_rowid                          IN OUT  NOCOPY VARCHAR2
        , x_media_action_id                  NUMBER
        , x_created_by                       NUMBER
        , x_creation_date                    DATE
        , x_last_updated_by                  NUMBER
        , x_last_update_date                 DATE
        , x_last_update_login                NUMBER
        , x_media_type_id                    NUMBER
        , x_maction_def_id                   NUMBER
        , x_application_id                   NUMBER
        , x_classification                   VARCHAR2
        , x_other_params                     VARCHAR2
     );

     PROCEDURE delete_row(
        x_media_action_id                  NUMBER
     );

     PROCEDURE update_row(
          x_rowid                          VARCHAR2
        , x_media_action_id                NUMBER
        , x_created_by                     NUMBER
        , x_creation_date                  DATE
        , x_last_updated_by                NUMBER
        , x_last_update_date               DATE
        , x_last_update_login              NUMBER
        , x_media_type_id                  NUMBER
        , x_maction_def_id                 NUMBER
        , x_application_id                 NUMBER
        , x_classification                 VARCHAR2
        , x_other_params                   VARCHAR2
     );

     PROCEDURE lock_row(
          x_rowid                          VARCHAR2
        , x_media_action_id                NUMBER
        , x_created_by                     NUMBER
        , x_creation_date                  DATE
        , x_last_updated_by                NUMBER
        , x_last_update_date               DATE
        , x_last_update_login              NUMBER
        , x_media_type_id                  NUMBER
        , x_maction_def_id                 NUMBER
        , x_application_id                 NUMBER
        , x_classification                 VARCHAR2
        , x_other_params                   VARCHAR2
     );
END ieu_uwq_media_actions_pkg;
 

/
