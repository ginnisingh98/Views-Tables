--------------------------------------------------------
--  DDL for Package PER_DRT_UDF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_DRT_UDF" AUTHID CURRENT_USER AS
/* $Header: pedrtudf.pkh 120.0.12010000.1 2018/04/12 14:30:52 gahluwal noship $ */

  FUNCTION get_legislation_code
    (table_name IN varchar2
    ,person_id  IN number) RETURN varchar2;

  FUNCTION generate_unique_string
    (p_rid         IN rowid
    ,p_table_name  IN varchar2
    ,p_column_name IN varchar2
    ,p_party_id    IN number) RETURN varchar2;

  FUNCTION overwrite_id_number
    (rid         IN rowid
    ,table_name  IN varchar2
    ,column_name IN varchar2
    ,person_id   IN number) RETURN varchar2;

  FUNCTION overwrite_name
    (rid         IN rowid
    ,table_name  IN varchar2
    ,column_name IN varchar2
    ,person_id   IN number) RETURN varchar2;

  FUNCTION overwrite_phone
    (rid         IN varchar2
    ,table_name  IN varchar2
    ,column_name IN varchar2
    ,person_id   IN number) RETURN varchar2;

  FUNCTION overwrite_email
    (rid         IN varchar2
    ,table_name  IN varchar2
    ,column_name IN varchar2
    ,person_id   IN number) RETURN varchar2;

  FUNCTION overwrite_website
    (rid         IN varchar2
    ,table_name  IN varchar2
    ,column_name IN varchar2
    ,person_id   IN number) RETURN varchar2;

  FUNCTION overwrite_account_number
    (rid         IN varchar2
    ,table_name  IN varchar2
    ,column_name IN varchar2
    ,person_id   IN number) RETURN varchar2;
END PER_DRT_UDF;

/
