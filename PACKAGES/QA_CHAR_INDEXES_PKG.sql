--------------------------------------------------------
--  DDL for Package QA_CHAR_INDEXES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_CHAR_INDEXES_PKG" AUTHID CURRENT_USER AS
/* $Header: qaindexs.pls 120.0 2005/05/24 18:25:57 appldev noship $ */

    err_element_not_in_use       CONSTANT INTEGER := -1;
    err_string_overflow          CONSTANT INTEGER := -2;
    err_create_index             CONSTANT INTEGER := -3;
    err_drop_index               CONSTANT INTEGER := -4;
    err_unsupported_element_type CONSTANT INTEGER := -5;
    err_insert_row               CONSTANT INTEGER := -6;
    err_delete_row               CONSTANT INTEGER := -7;
    err_disable_index            CONSTANT INTEGER := -8;
    err_index_name               CONSTANT INTEGER := -9;

    PROCEDURE wrapper(
        errbuf    OUT NOCOPY VARCHAR2,
        retcode   OUT NOCOPY NUMBER,
        argument1            VARCHAR2,
        argument2            VARCHAR2,
        argument3            VARCHAR2,
        argument4            VARCHAR2);

    PROCEDURE get_predicate(
        p_char_id NUMBER,
        p_alias VARCHAR2,
        x_predicate OUT NOCOPY VARCHAR2);

    FUNCTION index_exists(p_char_id NUMBER) RETURN INTEGER;

    FUNCTION index_exists_and_enabled(p_char_id NUMBER) RETURN INTEGER;

    FUNCTION get_default_result_column(p_char_id NUMBER) RETURN VARCHAR2;

    FUNCTION disable_index(p_char_id NUMBER) RETURN INTEGER;

    FUNCTION drop_index(p_char_id NUMBER) RETURN INTEGER;

    FUNCTION create_or_regenerate_index(
        p_char_id NUMBER,
        p_index_name VARCHAR2,
        p_additional_parameters VARCHAR2)
        RETURN INTEGER;

    PROCEDURE insert_row(
        x_rowid                     OUT NOCOPY VARCHAR2,
        p_created_by                NUMBER,
        p_creation_date             DATE,
        p_last_updated_by           NUMBER,
        p_last_update_date          DATE,
        p_last_update_login         NUMBER,
        p_request_id                NUMBER,
        p_program_application_id    NUMBER,
        p_program_id                NUMBER,
        p_program_update_date       DATE,
        p_char_id                   NUMBER,
        p_enabled_flag              NUMBER,
        p_index_name                VARCHAR2,
        p_default_result_column     VARCHAR2,
        p_text                      VARCHAR2,
        p_additional_parameters     VARCHAR2);

    PROCEDURE delete_row(p_char_id NUMBER);

    FUNCTION get_index_predicate(
        p_char_id NUMBER,
        p_alias VARCHAR2)
        RETURN VARCHAR2;

    --
    -- Bug 3930666.  This bug does not impact this
    -- current package.  But it is most efficient to
    -- fix it by exposing a new function to the public.
    -- To be used in qlthrb.plb.
    --
    -- bso Tue Apr  5 17:24:07 PDT 2005
    --
    -- It was found out later that this function is not
    -- needed by qlthrb; rather construct_decode_function
    -- (existing) should be exposed instead.  Keeping this
    -- here as it is generally useful.
    --
    FUNCTION get_decode_function(
        p_char_id NUMBER,
        p_alias VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;


    FUNCTION construct_decode_function(
        p_char_id NUMBER,
        p_alias VARCHAR2,
        x_most_common OUT NOCOPY VARCHAR2,
        x_function OUT NOCOPY dbms_sql.varchar2s)
        RETURN INTEGER;

END qa_char_indexes_pkg;

 

/
