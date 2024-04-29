--------------------------------------------------------
--  DDL for Package ASO_BI_POPULATE_FACTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_BI_POPULATE_FACTS" AUTHID CURRENT_USER AS
 /* $Header: asovbipfs.pls 120.0 2005/05/31 01:26:50 appldev noship $ */

 --This is the Main Procedure for Incremental Data collection from Quote Header
 --transaction table.

  PROCEDURE Populate_Facts(errbuf 	OUT NOCOPY  VARCHAR2,
                           retcode 	OUT NOCOPY  NUMBER,
                           p_from_date  IN  VARCHAR2,
                           p_to_date    IN  VARCHAR2,
			   p_no_worker  IN  NUMBER);

  --This is the Main Procedure for Initial Data collection from Quote Header
  --transaction table.

  PROCEDURE Initial_Load_Hdr(errbuf    OUT NOCOPY VARCHAR2,
                           retcode     OUT NOCOPY NUMBER,
                           p_from_date IN  VARCHAR2,
                           p_to_date   IN  VARCHAR2 );


  --This is the Main Procedure for Incremental Data collection from Quote Lines
  --transaction table.

  PROCEDURE Populate_Lines_Fact(errbuf 	OUT NOCOPY VARCHAR2,
                           retcode 	OUT NOCOPY NUMBER,
                           p_from_date  IN  VARCHAR2,
                           p_to_date    IN  VARCHAR2,
			   p_worker_no  IN  NUMBER);

  --This is the Main Procedure for Initial Data collection from Quote Lines
  --transaction table.

  PROCEDURE Initial_Load_Lines(errbuf    OUT NOCOPY VARCHAR2,
                           retcode     OUT NOCOPY NUMBER,
                           p_from_date IN  VARCHAR2,
                           p_to_date   IN  VARCHAR2 );
END ASO_BI_POPULATE_FACTS;

 

/
