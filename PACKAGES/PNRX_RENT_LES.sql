--------------------------------------------------------
--  DDL for Package PNRX_RENT_LES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PNRX_RENT_LES" AUTHID CURRENT_USER AS
/* $Header: PNRXRRLS.pls 115.5 2002/11/14 20:23:50 stripath ship $ */

PROCEDURE pn_rent_les(
          lease_resp_user             IN                    VARCHAR2,
          location_code_low           IN                    VARCHAR2,
          location_code_high          IN                    VARCHAR2,
          lease_type                  IN                    VARCHAR2,
          lease_number_low            IN                    VARCHAR2,
          lease_number_high           IN                    VARCHAR2,
          lease_termination_from      IN                    DATE,
          lease_termination_to        IN                    DATE,
          lease_status                IN                    VARCHAR2,
          lease_class                 IN                    VARCHAR2,	  		--bug#2099864
          l_request_id                IN                    NUMBER,
          l_user_id                   IN                    NUMBER,
          retcode                     OUT NOCOPY                   VARCHAR2,
          errbuf                      OUT NOCOPY                   VARCHAR2
                   );

END pnrx_rent_les;

 

/
