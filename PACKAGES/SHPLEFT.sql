--------------------------------------------------------
--  DDL for Package SHPLEFT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."SHPLEFT" AUTHID CURRENT_USER AS
/* $Header: SHPLEFTS.pls 115.1 99/07/16 08:17:34 porting shi $ */


function SOMETHING_LEFT_TO_SHIP(
   O_LINE_ID                           IN NUMBER       DEFAULT NULL)
   return VARCHAR2;



pragma restrict_references(SOMETHING_LEFT_TO_SHIP, WNDS, WNPS);

END SHPLEFT;

 

/
