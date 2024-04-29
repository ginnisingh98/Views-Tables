--------------------------------------------------------
--  DDL for Package IEX_AG_DN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_AG_DN_PKG" AUTHID CURRENT_USER AS
/* $Header: iextadus.pls 120.1 2004/11/24 19:00:57 clchang ship $ */

     PROCEDURE insert_row(
          px_rowid                          IN OUT NOCOPY VARCHAR2
        , px_ag_dn_xref_id                  IN OUT NOCOPY NUMBER
        , p_aging_bucket_id                  NUMBER
        , p_aging_bucket_line_id             NUMBER
        , p_callback_flag                    VARCHAR2
        , p_callback_days                    NUMBER
        , p_FM_METHOD                        VARCHAR2
        , p_template_id                      NUMBER
        , p_xdo_template_id                  NUMBER
        , p_score_RANGE_LOW                  NUMBER
        , p_score_RANGE_HIGH                 NUMBER
        , p_dunning_level                    VARCHAR2
        , p_object_version_number            NUMBER
        , p_last_update_date                 DATE
        , p_last_updated_by                  NUMBER
        , p_creation_date                    DATE
        , p_created_by                       NUMBER
        , p_last_update_login                NUMBER
     );

     PROCEDURE delete_row(
        p_ag_dn_xref_id                      NUMBER
     );

     PROCEDURE update_row(
          p_rowid                            VARCHAR2
        , p_ag_dn_xref_id                    NUMBER
        , p_aging_bucket_id                  NUMBER
        , p_aging_bucket_line_id             NUMBER
        , p_callback_flag                    VARCHAR2
        , p_callback_days                    NUMBER
        , p_FM_METHOD                        VARCHAR2
        , p_template_id                      NUMBER
        , p_xdo_template_id                  NUMBER
        , p_score_RANGE_LOW                  NUMBER
        , p_score_RANGE_HIGH                 NUMBER
        , p_dunning_level                    VARCHAR2
        , p_object_version_number            NUMBER
        , p_last_update_date                 DATE
        , p_last_updated_by                  NUMBER
        , p_creation_date                    DATE
        , p_created_by                       NUMBER
        , p_last_update_login                NUMBER
     );


     PROCEDURE lock_row(
          p_rowid                            VARCHAR2
        , p_ag_dn_xref_id                    NUMBER
        , p_aging_bucket_id                  NUMBER
        , p_aging_bucket_line_id             NUMBER
        , p_callback_flag                    VARCHAR2
        , p_callback_days                    NUMBER
        , p_FM_METHOD                        VARCHAR2
        , p_template_id                      NUMBER
        , p_xdo_template_id                  NUMBER
        , p_score_RANGE_LOW                  NUMBER
        , p_score_RANGE_HIGH                 NUMBER
        , p_dunning_level                    VARCHAR2
        , p_object_version_number            NUMBER
        , p_last_update_date                 DATE
        , p_last_updated_by                  NUMBER
        , p_creation_date                    DATE
        , p_created_by                       NUMBER
        , p_last_update_login                NUMBER
     );



END iex_ag_dn_pkg;

 

/
