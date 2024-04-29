--------------------------------------------------------
--  DDL for Package FII_TIME_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_TIME_C" AUTHID CURRENT_USER AS
/*$Header: FIICMT1S.pls 120.7.12000000.1 2007/01/18 17:57:21 appldev ship $*/

 PROCEDURE LOAD(Errbuf out NOCOPY varchar2, retcode out NOCOPY Varchar2,
		p_from_date in varchar2, p_to_date in varchar2, p_all_level in varchar2,
  p_load_mode in varchar2);

 PROCEDURE LOAD_CAL_NAME;

 PROCEDURE LOAD_TIME_RPT_STRUCT(p_from_date in date,	p_to_date in date);

 PROCEDURE LOAD_TIME_CAL_RPT_STRUCT(p_from_date in date,	p_to_date in date);

 FUNCTION DEFAULT_LOAD_FROM_DATE(p_load_mode in varchar2) return varchar2;

 FUNCTION DEFAULT_LOAD_TO_DATE return varchar2;

END FII_TIME_C;

 

/
