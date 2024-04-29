--------------------------------------------------------
--  DDL for Package MRP_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_UTIL" AUTHID CURRENT_USER AS
/* $Header: MRPUTILS.pls 115.1 2004/07/29 19:22:39 skanta ship $  */
-- variable for MRP:Debug profile option
G_MRP_DEBUG   VARCHAR2(1) := FND_PROFILE.Value('MRP_DEBUG');

-- log messaging if debug is turned on
PROCEDURE MRP_DEBUG(buf  IN  VARCHAR2);

-- log messaging irrespective of whether debug is turned on or off
PROCEDURE MRP_LOG(buf  IN  VARCHAR2);

-- out messaging
PROCEDURE MRP_OUT(buf IN VARCHAR2);
--
-- Procedure to get meaning from mfg_lookups
--
FUNCTION lookup_desc(l_type in mfg_lookups.lookup_type%TYPE,
                       l_code in mfg_lookups.lookup_code%TYPE) RETURN varchar2 ;

END MRP_UTIL;

 

/
