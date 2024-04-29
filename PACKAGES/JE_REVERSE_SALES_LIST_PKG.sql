--------------------------------------------------------
--  DDL for Package JE_REVERSE_SALES_LIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JE_REVERSE_SALES_LIST_PKG" AUTHID CURRENT_USER AS
/*$Header: jeukrslrs.pls 120.2 2007/12/20 09:29:40 ashdas noship $*/
P_LEGAL_ENTITY       VARCHAR2(30);
P_TAX_REG_NUM        VARCHAR2(30);
P_FROM_DATE          VARCHAR2(30);
P_TO_DATE            VARCHAR2(30);

FUNCTION beforeReport RETURN BOOLEAN;

END JE_REVERSE_SALES_LIST_PKG;

/
