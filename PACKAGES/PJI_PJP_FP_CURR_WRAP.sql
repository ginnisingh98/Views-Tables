--------------------------------------------------------
--  DDL for Package PJI_PJP_FP_CURR_WRAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_PJP_FP_CURR_WRAP" AUTHID CURRENT_USER AS
/* $Header: PJIPUT2S.pls 120.2 2006/03/08 00:16:15 appldev noship $ */


-----------------------------------------------------------------
----- Misc apis.. wrappers for apis provided by Shane -----------
-----------------------------------------------------------------

function GET_GLOBAL1_CURR_CODE RETURN VARCHAR2;

function GET_GLOBAL2_CURR_CODE RETURN VARCHAR2;

function GET_GLOBAL_RATE_PRIMARY
(p_FROM_currency_code varchar2,
p_exchange_date date)
return number;

function GET_MAU_PRIMARY return number;

function GET_GLOBAL_RATE_SECONDARY
(p_FROM_currency_code VARCHAR2,
p_exchange_date DATE)
return number;

function GET_MAU_SECONDARY return number;

function GET_RATE
(p_FROM_currency_code varchar2,
 p_to_currency_code varchar2,
 p_exchange_date date) return number;

function GET_MAU (
p_currency_code varchar2)
return number;

FUNCTION GET_WORKER_ID RETURN NUMBER;

PROCEDURE get_ent_dates_info (
   x_global_start_date      OUT NOCOPY  DATE
 , x_ent_start_period_id    OUT NOCOPY  NUMBER
 , x_ent_start_period_name  OUT NOCOPY  VARCHAR2
 , x_ent_start_date         OUT NOCOPY  DATE
 , x_ent_END_date           OUT NOCOPY  DATE
 , x_global_start_J         OUT NOCOPY  VARCHAR2
 , x_ent_start_J            OUT NOCOPY  VARCHAR2
 , x_ent_END_J              OUT NOCOPY  VARCHAR2
);

PROCEDURE get_global_currency_info (
   x_currency_conversion_rule OUT NOCOPY  VARCHAR2
 , x_prorating_format         OUT NOCOPY  VARCHAR2
 , x_global1_currency_code    OUT NOCOPY  VARCHAR2
 , x_global2_currency_code    OUT NOCOPY  VARCHAR2
 , x_global1_currency_mau     OUT NOCOPY  NUMBER
 , x_global2_currency_mau     OUT NOCOPY  NUMBER
);


PROCEDURE PRINT_TIME(p_tag IN VARCHAR2);


PROCEDURE EXCP_HANDLER
( p_context        IN  VARCHAR2 := 'ERR'
, p_package_name   IN  VARCHAR2 := NULL
, p_procedure_name IN  VARCHAR2 := NULL
, x_return_status  OUT NOCOPY  VARCHAR2) ;


PROCEDURE INIT_ERR_STACK
( p_package_name   IN  VARCHAR2 := NULL
, x_return_status  OUT NOCOPY  VARCHAR2) ;


PROCEDURE SET_TABLE_STATS(
  p_own_name  IN VARCHAR2
, p_tab_name  IN VARCHAR2
, p_num_rows  IN NUMBER
, p_num_blks  IN NUMBER
, p_avg_r_len IN NUMBER
);


END PJI_PJP_FP_CURR_WRAP;

 

/
