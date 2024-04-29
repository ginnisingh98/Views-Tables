--------------------------------------------------------
--  DDL for Package PNRX_SP_UTIL_BY_LOC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PNRX_SP_UTIL_BY_LOC" AUTHID CURRENT_USER AS
/* $Header: PNRXULOS.pls 115.4 2002/11/14 20:24:34 stripath ship $ */

PROCEDURE pn_space_util_loc(
          property_code_low           IN                    VARCHAR2,
          property_code_high          IN                    VARCHAR2,
          location_code_low           IN                    VARCHAR2,
          location_code_high          IN                    VARCHAR2,
          location_type               IN                    VARCHAR2,
          as_of_date                  IN                    DATE,
          l_request_id                IN                    NUMBER,
          l_user_id                   IN                    NUMBER,
          retcode                     OUT NOCOPY                   VARCHAR2,
          errbuf                      OUT NOCOPY                   VARCHAR2
                   );
END pnrx_sp_util_by_loc;

 

/
