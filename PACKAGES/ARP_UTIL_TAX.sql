--------------------------------------------------------
--  DDL for Package ARP_UTIL_TAX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_UTIL_TAX" AUTHID CURRENT_USER AS
/* $Header: ARPUTAXS.pls 120.2 2003/11/12 19:50:33 lxzhang ship $ */

--bug fix 3062098
--PROCEDURE  debug(p_line in VARCHAR2 );
PROCEDURE debug(
p_line   IN VARCHAR2,
p_module_name IN VARCHAR2 DEFAULT 'TAX',
p_log_level IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT
);

PROCEDURE initialize;

FUNCTION  is_debug_enabled return VARCHAR2;

END   ARP_UTIL_TAX;

 

/
