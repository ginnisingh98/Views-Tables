--------------------------------------------------------
--  DDL for Package AD_PA_MISC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AD_PA_MISC" AUTHID CURRENT_USER as
/* $Header: adpamiss.pls 120.2.12010000.1 2010/03/30 15:10:59 mkumandu noship $*/

function get_total_time_stringformat(prid number,
                        tsid number,
                        prd varchar2,
                        pname varchar2)
return varchar2;

function get_total_time(prid number,
                        tsid number,
                        prd varchar2,
                        pname varchar2)
return number;

function get_total_time(ssid number,
                        prd varchar2,
                        pname varchar2) return
varchar2;
end ad_pa_misc;

/
