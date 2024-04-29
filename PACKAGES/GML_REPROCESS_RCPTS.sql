--------------------------------------------------------
--  DDL for Package GML_REPROCESS_RCPTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_REPROCESS_RCPTS" AUTHID CURRENT_USER AS
/* $Header: GMLRRCTS.pls 115.1 2002/12/04 19:12:53 gmangari ship $ */


PROCEDURE update_records(errbufx  OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2);

PROCEDURE reprocess_adjust_errors(errbufx  OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2);

END GML_REPROCESS_RCPTS;


 

/
