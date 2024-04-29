--------------------------------------------------------
--  DDL for Package CSTPPLLC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPPLLC" AUTHID CURRENT_USER as
/* $Header: CSTPLLCS.pls 120.0.12010000.1 2008/07/24 17:22:35 appldev ship $*/
PROCEDURE pac_low_level_codes(
        i_pac_period_id IN NUMBER,
        i_cost_group_id IN NUMBER,
        i_start_date     IN DATE,
        i_end_date       IN DATE,
        i_user_id        IN      NUMBER,
        i_login_id       IN      NUMBER,
        i_request_id     IN      NUMBER,
        i_prog_id        IN      NUMBER,
        i_prog_app_id    IN      NUMBER,
        o_err_num        OUT NOCOPY     NUMBER,
        o_err_code       OUT NOCOPY     VARCHAR2,
        o_err_msg        OUT NOCOPY     VARCHAR2)
;
END CSTPPLLC;

/
