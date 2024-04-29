--------------------------------------------------------
--  DDL for Package IGI_CIS_GET_PROFILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_CIS_GET_PROFILE" AUTHID CURRENT_USER AS
/* $Header: igicisas.pls 115.5 2002/08/29 14:58:53 sbrewer ship $ */

    FUNCTION Cis_Tax_Code RETURN VARCHAR2;
    PRAGMA RESTRICT_REFERENCES (Cis_Tax_Code,'WNDS','WNPS');

    FUNCTION Cis_Tax_Group RETURN VARCHAR2;
    PRAGMA RESTRICT_REFERENCES (Cis_Tax_Group,'WNDS','WNPS');

END IGI_CIS_GET_PROFILE;

 

/
