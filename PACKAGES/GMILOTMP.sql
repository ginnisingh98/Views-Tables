--------------------------------------------------------
--  DDL for Package GMILOTMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMILOTMP" AUTHID CURRENT_USER AS
/* $Header: gmilotcs.pls 115.0 2003/04/24 21:01:36 jdiiorio noship $ */

FUNCTION  GET_MAX_AUDIT (pconversion_id          IN NUMBER)
RETURN NUMBER;

END GMILOTMP;

 

/
