--------------------------------------------------------
--  DDL for Package JTY_MISC_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTY_MISC_UTILS_PKG" AUTHID CURRENT_USER AS
/* $Header: jtfmsuts.pls 120.1 2006/03/30 17:42:36 achanda noship $ */
---------------------------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTY_MISC_UTILS_PKG
--    ---------------------------------------------------
--    PURPOSE
--      This package conatins utilities APIs for territory
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      08/16/05    achanda    CREATED
--
--
--    End of Comments

  -- ***************************************************
  --    API Specifications
  -- ***************************************************
  --    api name       : alter_qual_denorm_tables
  --    type           : public.
  --    function       : Called from qualifiers enable page to add columns to the denorm value tables
  --
  PROCEDURE alter_qual_denorm_tables
  ( x_success_flag               OUT NOCOPY  VARCHAR2,
    x_err_code                   OUT NOCOPY  VARCHAR2,
    p_qual_usg_id                IN          NUMBER,
    p_comp_op_col                IN          VARCHAR2,
    p_low_value_char_col         IN          VARCHAR2,
    p_high_value_char_col        IN          VARCHAR2,
    p_low_value_char_id_col      IN          VARCHAR2,
    p_low_value_number_col       IN          VARCHAR2,
    p_high_value_number_col      IN          VARCHAR2,
    p_interest_type_id_col       IN          VARCHAR2,
    p_primary_int_code_id_col    IN          VARCHAR2,
    p_secondary_int_code_id_col  IN          VARCHAR2,
    p_value1_id_col              IN          VARCHAR2,
    p_value2_id_col              IN          VARCHAR2,
    p_value3_id_col              IN          VARCHAR2,
    p_value4_id_col              IN          VARCHAR2,
    p_first_char_col             IN          VARCHAR2,
    p_cur_code_col               IN          VARCHAR2
  );

END JTY_MISC_UTILS_PKG;

 

/
