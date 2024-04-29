--------------------------------------------------------
--  DDL for Package PNRX_SP_ASSIGN_BY_LOC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PNRX_SP_ASSIGN_BY_LOC" AUTHID CURRENT_USER AS
/* $Header: PNRXSALS.pls 115.7 2002/11/14 20:24:19 stripath ship $ */

PROCEDURE pn_space_assign_loc(
                       property_code_low               IN     VARCHAR2,
                       property_code_high              IN     VARCHAR2,
                       location_code_low               IN     VARCHAR2,
                       location_code_high              IN     VARCHAR2,
                       location_type                   IN     VARCHAR2,
                       as_of_date                      IN     DATE,
                       report_type                     IN     VARCHAR2,
                       l_request_id                    IN     NUMBER,
                       l_user_id                       IN     NUMBER,
                       retcode                            OUT NOCOPY VARCHAR2,
                       errbuf                             OUT NOCOPY VARCHAR2
                   );
FUNCTION compare_assign_emploc(
                       p_location_id                   IN     NUMBER,
                       p_person_id                     IN     NUMBER,
                       p_cost_center                   IN     VARCHAR2,
                       p_request_id                    IN     NUMBER)
RETURN BOOLEAN;

FUNCTION compare_assign_custloc(
                       p_location_id                   IN     NUMBER,
                       p_account_id                    IN     VARCHAR2,
                       p_request_id                    IN     NUMBER)
RETURN BOOLEAN;
END pnrx_sp_assign_by_loc;

 

/
