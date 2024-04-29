--------------------------------------------------------
--  DDL for Package PER_DRT_METADATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_DRT_METADATA" AUTHID CURRENT_USER AS
/* $Header: pedrtmet.pkh 120.0.12010000.1 2019/06/21 10:42:20 hardeeps noship $ */
--
  PROCEDURE update_seeded_metadata
    (p_table_id          IN number
    ,p_table_phase       IN number   DEFAULT NULL
    ,p_record_identifier IN varchar2 DEFAULT NULL
    ,p_column_id         IN number   DEFAULT NULL
    ,p_ff_column_id      IN number   DEFAULT NULL
    ,p_column_phase      IN number   DEFAULT NULL
    ,p_attribute         IN varchar2 DEFAULT NULL
    ,p_ff_type           IN varchar2 DEFAULT NULL
    ,p_rule_type         IN varchar2 DEFAULT NULL
    ,p_parameter_1       IN varchar2 DEFAULT NULL
    ,p_parameter_2       IN varchar2 DEFAULT NULL
    ,p_comments          IN varchar2 DEFAULT NULL);

  PROCEDURE delete_seeded_metadata
    (p_table_id     IN number DEFAULT NULL
    ,p_column_id    IN number DEFAULT NULL
    ,p_ff_column_id IN number DEFAULT NULL);

END PER_DRT_METADATA;

/
