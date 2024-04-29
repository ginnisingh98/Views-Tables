--------------------------------------------------------
--  DDL for Package BIV_HS_SR_ARRIVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIV_HS_SR_ARRIVAL_PKG" AUTHID CURRENT_USER As
-- $Header: bivsrats.pls 115.5 2002/11/18 17:25:27 smisra noship $ */
    PROCEDURE Agnt_sr_arrival_time(p_param_str in varchar2)  ;
    PROCEDURE Prd_sr_arrival_time(p_param_str in varchar2)  ;
END;

 

/
