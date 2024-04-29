--------------------------------------------------------
--  DDL for Package CSTPPPUR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPPPUR" AUTHID CURRENT_USER AS
/* $Header: CSTPPURS.pls 115.7 2002/11/11 21:25:13 awwang ship $*/

/*---------------------------------------------------------------------------*
|  PUBLIC PROCEDURE                                                          |
|       purge_period_data                                                    |
*----------------------------------------------------------------------------*/
PROCEDURE purge_period_data (
                        i_pac_period_id         IN      NUMBER,
                        i_legal_entity       	IN      NUMBER,
                        i_cost_group_id         IN      NUMBER,
			i_acquisition_flag	IN 	NUMBER DEFAULT 0,
                        i_user_id               IN      NUMBER,
                        i_login_id              IN      NUMBER DEFAULT -1,
                        i_request_id            IN      NUMBER,
                        i_prog_id               IN      NUMBER DEFAULT -1,
                        i_prog_app_id           IN      NUMBER DEFAULT -1,
                        o_err_num               OUT NOCOPY     NUMBER,
                        o_err_code              OUT NOCOPY     VARCHAR2,
                        o_err_msg               OUT NOCOPY     VARCHAR2
);

/*---------------------------------------------------------------------------*
|  PUBLIC PROCEDURE                                                          |
|       purge_distribution_data                                                    |
*----------------------------------------------------------------------------*/
PROCEDURE purge_distribution_data (
                        i_pac_period_id         IN      NUMBER,
                        i_legal_entity       	IN      NUMBER,
                        i_cost_group_id         IN      NUMBER,
                        i_user_id               IN      NUMBER,
                        i_login_id              IN      NUMBER DEFAULT -1,
                        i_request_id            IN      NUMBER,
                        i_prog_id               IN      NUMBER DEFAULT -1,
                        i_prog_app_id           IN      NUMBER DEFAULT -1,
                        o_err_num               OUT NOCOPY     NUMBER,
                        o_err_code              OUT NOCOPY     VARCHAR2,
                        o_err_msg               OUT NOCOPY     VARCHAR2
);

END CSTPPPUR;

 

/
