--------------------------------------------------------
--  DDL for Package AR_CMGT_REASSIGN_CONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_CMGT_REASSIGN_CONC" AUTHID CURRENT_USER AS
/* $Header: ARCMRACS.pls 115.1 2002/11/15 02:21:11 anukumar noship $ */

PROCEDURE reassign_credit_analyst(
       errbuf                           IN OUT NOCOPY VARCHAR2,
       retcode                          IN OUT NOCOPY VARCHAR2,
       p_credit_analyst_id_from         IN VARCHAR2,
       p_credit_analyst_id_to           IN VARCHAR2,
       p_assign_status                  IN VARCHAR2,
       p_start_date                     IN VARCHAR2,
       p_end_date                       IN VARCHAR2
  );


END AR_CMGT_REASSIGN_CONC;

 

/
