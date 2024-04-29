--------------------------------------------------------
--  DDL for Package QLTSSMPB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QLTSSMPB" AUTHID CURRENT_USER as
/* $Header: qltssmpb.pls 115.2 2002/11/27 19:33:19 jezheng ship $ */


--  This is a wrapper for the ss plan/element mapping for AK
--  It is needed for the concurrent manager to run


  PROCEDURE WRAPPER(ERRBUF OUT NOCOPY VARCHAR2,
		    RETCODE OUT NOCOPY NUMBER,
		    ARGUMENT1 IN VARCHAR2,
		    ARGUMENT2 IN NUMBER);


END qltssmpb;


 

/
