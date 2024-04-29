--------------------------------------------------------
--  DDL for Package QP_JAVA_ENGINE_CACHE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_JAVA_ENGINE_CACHE_PVT" AUTHID CURRENT_USER as
/* $Header: QPXJCCVS.pls 120.2 2006/03/09 16:09:06 hwong noship $ */

type number_tbl_type is table of number index by binary_integer;
type date_tbl_type is table of date index by binary_integer;
type varchar30_tbl_type is table of varchar2(30) index by binary_integer;
type varchar240_tbl_type is table of varchar2(240) index by binary_integer;
type varchar300_tbl_type is table of varchar2(300) index by binary_integer;
type varchar1000_tbl_type is table of varchar2(1000) index by binary_integer;

--G_CR CONSTANT VARCHAR2(1) := CHR(13);

PROCEDURE UPDATE_CACHE_STATS
(
 err_buff                OUT NOCOPY VARCHAR2,
 retcode                 OUT NOCOPY NUMBER
);

--PROCEDURE UPDATE_CAT_NO_PROD_PRICING;

PROCEDURE WARM_UP
(
 err_buff                OUT NOCOPY VARCHAR2,
 retcode                 OUT NOCOPY NUMBER
);

PROCEDURE SYNCHRONIZE
(
 err_buff                OUT NOCOPY VARCHAR2,
 retcode                 OUT NOCOPY NUMBER,
 p_list_header_id NUMBER,
 p_price_formula_id NUMBER,
 p_currency_header_id NUMBER,
 p_all_others VARCHAR2,
 p_full_cache VARCHAR2
);

PROCEDURE MANAGE
(
 err_buff                OUT NOCOPY VARCHAR2,
 retcode                 OUT NOCOPY NUMBER,
 p_manage_action VARCHAR2,
 p_dump_type VARCHAR2,
 p_dump_input1 VARCHAR2,
 p_dump_input2 VARCHAR2,
 p_dump_input3 VARCHAR2
);

END QP_JAVA_ENGINE_CACHE_PVT;

 

/
