--------------------------------------------------------
--  DDL for Package OPI_DBI_WMS_RTP_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_WMS_RTP_F_C" AUTHID CURRENT_USER AS
/* $Header: OPIDEWMSRTPS.pls 120.0 2005/05/24 18:36:24 appldev noship $ */
PROCEDURE initial_load (errbuf          OUT NOCOPY VARCHAR2,
			retcode         OUT NOCOPY NUMBER);

PROCEDURE populate_rtp_fact  (errbuf          OUT NOCOPY VARCHAR2,
 		       		  retcode         OUT NOCOPY NUMBER);

END OPI_DBI_WMS_RTP_F_C ;

 

/
