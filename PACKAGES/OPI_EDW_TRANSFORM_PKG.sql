--------------------------------------------------------
--  DDL for Package OPI_EDW_TRANSFORM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_EDW_TRANSFORM_PKG" AUTHID CURRENT_USER AS
/* $Header: OPIMDECS.pls 115.8 2002/04/29 15:24:13 pkm ship     $ */
Function OPI_REV_PROD_DECODE(ITEM_FK_KEY  NUMBER,
                             LINE_CONTEXT VARCHAR,
                             PARENT_ITEM_FK_KEY NUMBER,
                             DATA_VALUE NUMBER) RETURN NUMBER;
Function OPI_IPS_BEG_BAL_DECODE(PERIOD_FLAG  NUMBER,
                            DATA_VALUE NUMBER) RETURN NUMBER;
Function OPI_IPS_END_BAL_DECODE(PERIOD_FLAG  NUMBER,
                            DATA_VALUE NUMBER) RETURN NUMBER;

END OPI_EDW_TRANSFORM_PKG;

 

/
