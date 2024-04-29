--------------------------------------------------------
--  DDL for Package POA_FACTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_FACTS" AUTHID CURRENT_USER AS
/* $Header: poasvp0s.pls 120.0 2005/06/01 13:45:20 appldev noship $ */

  PROCEDURE populate_facts(errbuf 	OUT NOCOPY VARCHAR2,
                           retcode 	OUT NOCOPY NUMBER,
                           p_start_date IN  VARCHAR2,
                           p_end_date 	IN  VARCHAR2);

END poa_facts;

 

/
