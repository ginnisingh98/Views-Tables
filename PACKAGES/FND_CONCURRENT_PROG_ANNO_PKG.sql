--------------------------------------------------------
--  DDL for Package FND_CONCURRENT_PROG_ANNO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_CONCURRENT_PROG_ANNO_PKG" AUTHID CURRENT_USER as
/* $Header: AFCPANTS.pls 120.1 2005/07/02 03:58:31 appldev noship $ */

FUNCTION GET_ANNOTATION(X_APPLICATION_ID NUMBER, X_CONCURRENT_PROGRAM_ID NUMBER) RETURN VARCHAR2 ;

end FND_CONCURRENT_PROG_ANNO_PKG;

 

/
