--------------------------------------------------------
--  DDL for Package PQP_GB_TP_EXTRACT_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GB_TP_EXTRACT_FUNCTIONS" AUTHID CURRENT_USER AS
--  /* $Header: pqgbtpxf.pkh 120.1 2006/02/06 05:49:05 bsamuel noship $ */
--
--
--  GET_CURRENT_EXTRACT_PERSON
--
--    Returns the ext_rslt_id for the current extract process
--    if one is running, else returns -1
--
  FUNCTION get_current_extract_result RETURN NUMBER;
--
--  GET_CURRENT_EXTRACT_RESULT
--
--    Returns the person id associated with the given assignment.
--    If none is found,it returns NULL. This may arise if the
--    user calls this from a header/trailer record, where
--    a dummy context of assignment_id = -1 is passed.
--
--
  FUNCTION get_current_extract_person
    (p_assignment_id NUMBER  -- context
    ) RETURN NUMBER;
--
--    RAISE_EXTRACT_WARNING
--
--    "Smart" warning function.
--    When called from the Rule of a extract detail data element
--    it logs a warning in the ben_ext_rslt_err table against
--    the person being processed (or as specified by context of
--    assignment id ). It prefixes all warning messages with a
--    string "Warning raised in data element "||element_name
--    This allows the same Rule to be called from different data
--    elements.
--    Optionally seeded error messages may also be raised by
--    passing the error number.
--
--    usage example.
--
--    RAISE_EXTRACT_WARNING("No initials were found.")
--
--    RRTURNCODE  MEANING
--    -1          Cannot raise warning against a header/trailer
--                record. System Extract does not allow it.
--
--    -2          No current extract process was found.
--
--    -3          No person was found.A Warning in System Extract
--                is always raised against a person.
--
--
--
  FUNCTION raise_extract_warning
    (p_assignment_id     IN     NUMBER    -- context
    ,p_error_text        IN     VARCHAR2
    ,p_error_number      IN     NUMBER    DEFAULT NULL
    ,p_token1            IN     VARCHAR2  DEFAULT NULL  --added to pass tokens to messages.
    ,p_token2            IN     VARCHAR2  DEFAULT NULL  --added to pass tokens to messages.
    ) RETURN NUMBER;
--
  FUNCTION raise_extract_error
    (p_business_group_id IN     NUMBER    -- Context
    ,p_assignment_id     IN     NUMBER    -- context
    ,p_error_text        IN     VARCHAR2
    ,p_error_number      IN     NUMBER    DEFAULT NULL
    ,p_token1            IN     VARCHAR2  DEFAULT NULL  --added to pass tokens to messages.
    ,p_fatal_flag        IN     VARCHAR2  DEFAULT 'Y' -- Default it to Y for existing pkgs
    ) RETURN NUMBER;

--
END pqp_gb_tp_extract_functions;

 

/
