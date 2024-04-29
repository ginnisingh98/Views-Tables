--------------------------------------------------------
--  DDL for Package WSH_ITM_PARTY_SYNC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_ITM_PARTY_SYNC" AUTHID CURRENT_USER AS
/* $Header: WSHITPSS.pls 120.1.12010000.1 2008/07/29 06:14:30 appldev ship $ */
	PROCEDURE POPULATE_DATA (
				errbuf               OUT NOCOPY   VARCHAR2,
				retcode              OUT NOCOPY   NUMBER,
				p_party_type         IN VARCHAR2 ,
				p_from_party_code    IN VARCHAR2 ,
				p_to_party_code      IN VARCHAR2 ,
				p_dummy		     IN NUMBER DEFAULT NULL,
				p_site_use_code      IN VARCHAR2 ,
				p_created_n_days     IN NUMBER ,
				p_updated_n_days     IN NUMBER
									);

END;

/
