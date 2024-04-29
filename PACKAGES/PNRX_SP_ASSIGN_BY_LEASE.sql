--------------------------------------------------------
--  DDL for Package PNRX_SP_ASSIGN_BY_LEASE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PNRX_SP_ASSIGN_BY_LEASE" AUTHID CURRENT_USER as
/* $Header: PNRXLESS.pls 115.7 2002/11/14 20:23:21 stripath ship $ */

PROCEDURE pn_space_assign_lease(
          lease_number_low            IN                    VARCHAR2,
          lease_number_high           IN                    VARCHAR2,
          as_of_date                  IN                    DATE,
          report_type                 IN                    VARCHAR2,
          l_request_id                IN                    NUMBER,
          l_user_id                   IN                    NUMBER,
          retcode                     OUT NOCOPY                   VARCHAR2,
          errbuf                      OUT NOCOPY                   VARCHAR2
                   );
FUNCTION compare_assign_emplease(P_LOCATION_ID  IN NUMBER,
                              P_PERSON_ID    IN NUMBER,
                              P_COST_CENTER  IN VARCHAR2,
                              P_REQUEST_ID IN NUMBER)
RETURN BOOLEAN;

FUNCTION compare_assign_custlease(P_LOCATION_ID  IN NUMBER,
                              P_ACCOUNT_ID    IN VARCHAR2,
                              P_REQUEST_ID IN NUMBER)
RETURN BOOLEAN;

END pnrx_sp_assign_by_lease;

 

/
