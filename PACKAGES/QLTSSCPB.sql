--------------------------------------------------------
--  DDL for Package QLTSSCPB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QLTSSCPB" AUTHID CURRENT_USER as
/* $Header: qltsscpb.pls 115.3 2002/11/27 19:32:11 jezheng ship $ */


--  This is a wrapper for the ss plan/element mapping for AK
--  It is needed for the concurrent manager to run


  PROCEDURE WRAPPER(ERRBUF OUT NOCOPY VARCHAR2,
		    RETCODE OUT NOCOPY NUMBER,
		    ARGUMENT1 IN VARCHAR2,
		    ARGUMENT2 IN VARCHAR2,
		    ARGUMENT3 IN NUMBER);


END qltsscpb;


 

/
