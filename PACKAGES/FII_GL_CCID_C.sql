--------------------------------------------------------
--  DDL for Package FII_GL_CCID_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_GL_CCID_C" AUTHID CURRENT_USER AS
/* $Header: FIIGLCCS.pls 115.5 2003/07/28 21:16:27 phu noship $ */

PROCEDURE MAIN (Errbuf         IN OUT  NOCOPY VARCHAR2,
                Retcode       IN OUT  NOCOPY VARCHAR2,
                pmode         IN   VARCHAR2);

FUNCTION NEW_CCID_IN_GL RETURN BOOLEAN;

END FII_GL_CCID_C;

 

/
