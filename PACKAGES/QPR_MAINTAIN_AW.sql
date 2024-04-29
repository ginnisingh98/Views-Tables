--------------------------------------------------------
--  DDL for Package QPR_MAINTAIN_AW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QPR_MAINTAIN_AW" AUTHID CURRENT_USER AS
/* $Header: QPRUMNTS.pls 120.1 2007/11/22 05:42:19 bhuchand noship $ */
/* Public Procedures */
   TYPE num_type      IS TABLE OF Number         INDEX BY BINARY_INTEGER;
   TYPE char240_type  IS TABLE OF Varchar2(240)  INDEX BY BINARY_INTEGER;
   TYPE real_type     IS TABLE OF Number(32,10)  INDEX BY BINARY_INTEGER;
   TYPE date_type     IS TABLE OF Date           INDEX BY BINARY_INTEGER;

   TYPE QPRREFCUR IS REF CURSOR;

g_calendar_code varchar2(15);
g_instance number;
g_price_plan_id number;
g_run_number number;
g_start_date date;
g_end_date date;
g_base_uom varchar2(10);
g_currency_code varchar2(15);
g_ord_line varchar2(240);
g_item varchar2(240);
g_tp_site varchar2(240);
g_cus varchar2(240);
g_ou varchar2(240);
g_sr varchar2(240);
g_chn varchar2(240);
g_adj varchar2(240);
g_psg varchar2(240);

procedure maintanance_process(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_price_plan_id     NUMBER,
			p_from_date 	varchar2,
			p_to_date	varchar2,
			p_clean_temp varchar2 default 'Y',
			p_clean_meas varchar2 default 'N',
			p_clean_dim varchar2 default 'N',
			p_include_dim varchar2 default 'Y',
			p_run_number number default 0);

function get_calendar_code return varchar2;
function get_instance return number;
function get_price_plan_id return number;
function get_run_number return number;
function get_day(p_time_pk varchar2, p_low_lvl_time varchar2) return date;
function get_start_date return date;
function get_end_date return date;
function get_base_uom return varchar2;
function get_currency_code return varchar2;
FUNCTION get_ORD_LINE return varchar2 ;
FUNCTION get_ITEM return varchar2 ;
FUNCTION get_TP_SITE return varchar2 ;
FUNCTION get_CUS return varchar2 ;
FUNCTION get_OU return varchar2 ;
FUNCTION get_SR return varchar2 ;
FUNCTION get_CHN return varchar2 ;
FUNCTION get_ADJ return varchar2 ;
FUNCTION get_PSG return varchar2 ;
--

END QPR_MAINTAIN_AW ;

/
