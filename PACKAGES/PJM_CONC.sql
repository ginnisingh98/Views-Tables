--------------------------------------------------------
--  DDL for Package PJM_CONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJM_CONC" AUTHID CURRENT_USER AS
/* $Header: PJMCONCS.pls 115.1 99/07/16 01:02:51 porting s $ */
--  ---------------------------------------------------------------------
--  Package Global Variables
--  ---------------------------------------------------------------------
G_conc_success  CONSTANT NUMBER := 0;
G_conc_warning  CONSTANT NUMBER := 1;
G_conc_failure  CONSTANT NUMBER := 2;

--  ---------------------------------------------------------------------
--  Public Functions / Procedures
--  ---------------------------------------------------------------------

PROCEDURE PUT_LINE (mesg IN VARCHAR2);

PROCEDURE NEW_LINE (num IN NUMBER);


END PJM_CONC;

 

/
