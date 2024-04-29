--------------------------------------------------------
--  DDL for Package BIX_POP_AO_SUM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIX_POP_AO_SUM_PKG" AUTHID CURRENT_USER AS
/* $Header: bixxaoss.pls 115.2 2003/01/10 00:14:55 achanda noship $ */

PROCEDURE populate(p_start_date_time in date,
                   p_end_date_time in date);
END BIX_POP_AO_SUM_PKG;

 

/
