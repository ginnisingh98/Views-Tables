--------------------------------------------------------
--  DDL for Package HRI_BPL_CCMGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_BPL_CCMGR" AUTHID CURRENT_USER AS
/* $Header: hribccmgr.pkh 120.0.12000000.2 2007/04/12 12:03:16 smohapat noship $ */

FUNCTION get_ccmgr_id(p_organization_id    IN NUMBER)
     RETURN NUMBER;

END hri_bpl_ccmgr;

 

/
