--------------------------------------------------------
--  DDL for Package HRI_BPL_TERMINATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_BPL_TERMINATION" AUTHID CURRENT_USER AS
/* $Header: hribterm.pkh 120.0 2005/05/29 07:04:44 appldev noship $ */

FUNCTION get_separation_category(p_leaving_reason   IN VARCHAR2)
    RETURN VARCHAR2;

END hri_bpl_termination;

 

/
