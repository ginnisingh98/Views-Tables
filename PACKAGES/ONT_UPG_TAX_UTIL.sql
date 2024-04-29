--------------------------------------------------------
--  DDL for Package ONT_UPG_TAX_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ONT_UPG_TAX_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUPGTS.pls 120.1 2006/02/17 16:34:00 aycui noship $ */

Procedure calculate_order_tax
( p_org_id       IN  NUMBER
, p_start_date IN DATE
, p_end_date IN DATE
, x_return_status OUT NOCOPY VARCHAR2

  );

END ONT_UPG_TAX_UTIL;

 

/
