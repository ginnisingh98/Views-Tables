--------------------------------------------------------
--  DDL for Package PNRX_LEASE_OPTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PNRX_LEASE_OPTIONS" AUTHID CURRENT_USER AS
/* $Header: PNRXLOPS.pls 115.4 2002/11/14 20:23:27 stripath ship $ */

PROCEDURE pn_lease_options(
          lease_number_low                  IN                    VARCHAR2,
          lease_number_high                 IN                    VARCHAR2,
          location_code_low                 IN                    VARCHAR2,
          location_code_high                IN                    VARCHAR2,
          lease_responsible_user            IN                    VARCHAR2,
          option_type                       IN                    VARCHAR2,
          exer_window_termination_from      IN                    DATE,
          exer_window_termination_to        IN                    DATE,
          lease_termination_from            IN                    DATE,
          lease_termination_to              IN                    DATE,
          l_request_id                      IN                    NUMBER,
          l_user_id                         IN                    NUMBER,
          retcode                           OUT NOCOPY                   VARCHAR2,
          errbuf                            OUT NOCOPY                   VARCHAR2
                   );

END pnrx_lease_options;

 

/
