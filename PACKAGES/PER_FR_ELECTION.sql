--------------------------------------------------------
--  DDL for Package PER_FR_ELECTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_FR_ELECTION" AUTHID CURRENT_USER as
/* $Header: pefrphmm.pkh 115.1 2002/11/25 12:21:15 jrhodes ship $ */
Procedure process(errbuf              OUT NOCOPY VARCHAR2,
                  retcode             OUT NOCOPY NUMBER,
                  p_company_id 	  IN NUMBER,
 			p_establishment_id  IN NUMBER,
 			p_reporting_est_id  IN NUMBER,
 			p_effective_date    IN VARCHAR2);
end;

 

/
