--------------------------------------------------------
--  DDL for Package OZF_TIME_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_TIME_PVT" AUTHID CURRENT_USER AS
/*$Header: ozfvtims.pls 115.1 2003/10/23 22:57:46 mkothari noship $*/

 PROCEDURE LOAD(x_errbuf OUT NOCOPY varchar2,
                x_retcode OUT NOCOPY varchar2,
                p_from_date varchar2,
                p_to_date varchar2,
                p_all_level varchar2);

 PROCEDURE LOAD_TIME_RPT_STRUCT(p_from_date date,
                                p_to_date date);

END OZF_TIME_PVT;

 

/
