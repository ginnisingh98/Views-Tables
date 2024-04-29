--------------------------------------------------------
--  DDL for Package IEU_UWQ_NONMEDIA_ACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_UWQ_NONMEDIA_ACTIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: IEUNMACS.pls 115.4 2003/08/21 18:34:31 fsuthar ship $ */
     PROCEDURE insert_row(
          x_rowid                          IN OUT NOCOPY VARCHAR2
        , x_nonmedia_action_id               NUMBER
        , x_created_by                       NUMBER
        , x_creation_date                    DATE
        , x_last_updated_by                  NUMBER
        , x_last_update_date                 DATE
        , x_last_update_login                NUMBER
        , x_action_object_code               VARCHAR2
        , x_maction_def_id                   NUMBER
        , x_application_id                   NUMBER
        , x_source_for_task_flag             VARCHAR2
        , x_responsibility_id                NUMBER
     );

     PROCEDURE delete_row(
        x_nonmedia_action_id                  NUMBER
     );

     PROCEDURE update_row(
          x_rowid                          VARCHAR2
        , x_nonmedia_action_id             NUMBER
        , x_created_by                     NUMBER
        , x_creation_date                  DATE
        , x_last_updated_by                NUMBER
        , x_last_update_date               DATE
        , x_last_update_login              NUMBER
        , x_action_object_code             VARCHAR2
        , x_maction_def_id                 NUMBER
        , x_application_id                 NUMBER
        , x_source_for_task_flag             VARCHAR2
        , x_responsibility_id                NUMBER
     );

     PROCEDURE lock_row(
          x_rowid                          VARCHAR2
        , x_nonmedia_action_id             NUMBER
        , x_created_by                     NUMBER
        , x_creation_date                  DATE
        , x_last_updated_by                NUMBER
        , x_last_update_date               DATE
        , x_last_update_login              NUMBER
        , x_action_object_code             VARCHAR2
        , x_maction_def_id                 NUMBER
        , x_application_id                 NUMBER
        , x_source_for_task_flag             VARCHAR2
        , x_responsibility_id                NUMBER
     );
END ieu_uwq_nonmedia_actions_pkg;

 

/
