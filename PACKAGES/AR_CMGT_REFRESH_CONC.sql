--------------------------------------------------------
--  DDL for Package AR_CMGT_REFRESH_CONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_CMGT_REFRESH_CONC" AUTHID CURRENT_USER AS
/* $Header: ARCMRFHS.pls 115.4 2003/03/27 23:51:55 apandit noship $ */

PROCEDURE submit_refresh_request(
       p_case_folder_id               IN     NUMBER,
       p_called_from                  IN     VARCHAR2,
       p_conc_request_id              OUT NOCOPY    NUMBER
      );

PROCEDURE refresh_case_folder(
       errbuf                         IN OUT NOCOPY VARCHAR2,
       retcode                        IN OUT NOCOPY VARCHAR2,
       p_case_folder_id               IN     NUMBER,
       p_called_from                  IN     VARCHAR2
      );

END AR_CMGT_REFRESH_CONC;

 

/
