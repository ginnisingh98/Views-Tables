--------------------------------------------------------
--  DDL for Package PAYRPENP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAYRPENP" AUTHID CURRENT_USER AS
/* $Header: payrpenp.pkh 115.1 2004/01/21 03:30:12 saurgupt noship $ */
--
--
/*===========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                       |
 |                  Redwood Shores, California, USA                          |
 |                       All rights reserved.                                |
 +============================================================================
 Name
    PAYRPENP
  Purpose
    Supports the report PAYRPENP.rdf, Employee Assignments Not Processed.
Notes

  History
    Date         Name        Vers   Bug      Description
    -----------  ----------  ------ -------- -------------------------
    04-SEP-2000  H.Maclean   40.2            Created Package
    21-JAN-2004  saurgupt    115.1  3372714  Modify to make the package
                                             gscc compliant.
============================================================================*/

-----------------------------------------------------------------------------
-- Name                                                                    --
--   get_gre_name                                                          --
-- Purpose                                                                 --
--   This function returns the name of the government reporting entity     --
--   associated with the soft_coding_keyflex_id.  If this is null, the     --
--   function returns ' ', avoiding the need for an outer join to handle   --
--   non-US business groups.                                               --
-----------------------------------------------------------------------------
--
FUNCTION get_gre_name( p_soft_coding_keyflex_id   IN NUMBER )
RETURN VARCHAR2;

-----------------------------------------------------------------------------
-- Name                                                                    --
--  get_gre_id                                                             --
-- Purpose                                                                 --
--  This function returns the id of the government reporting entity        --
--  associated with the soft_coding_keyflex_id.  If this is null, the      --
--  function returns NULL, avoiding the need for an outer join to handle   --
--  non-US business groups.                                                --
--                                                                         --
-----------------------------------------------------------------------------

FUNCTION get_gre_id( p_soft_coding_keyflex_id   IN NUMBER )
RETURN NUMBER;

-----------------------------------------------------------------------------
-- Name                                                                    --
--  get_location_code                                                      --
-- Purpose                                                                 --
--  This function returns the location code associated with the            --
--  location_id.  If this is null, the function returns ' ', avoiding      --
--  the need for an outer join to handle non-US business groups in which   --
--  the location is not a mandatory field.                                 --
--                                                                         --
-----------------------------------------------------------------------------


FUNCTION get_location_code( p_location_id   IN NUMBER )
RETURN VARCHAR2;

-----------------------------------------------------------------------------
-- Name                                                                    --
--  missing_assignment_action                                              --
-- Purpose                                                                 --
--  This function identifies those assignments which do not have           --
--  completed assignment actions in a given payroll period.                --
--                                                                         --
-----------------------------------------------------------------------------

FUNCTION missing_assignment_action( p_assignment_id  IN NUMBER,
                                    p_time_period_id IN NUMBER )
RETURN VARCHAR2;

END PAYRPENP;

 

/
