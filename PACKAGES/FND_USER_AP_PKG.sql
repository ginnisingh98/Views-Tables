--------------------------------------------------------
--  DDL for Package FND_USER_AP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_USER_AP_PKG" AUTHID CURRENT_USER AS
/* $Header: fndusers.pls 115.0 99/07/17 07:47:26 porting ship $ */

    FUNCTION get_user_name(l_user_id IN NUMBER) RETURN VARCHAR2;


    PRAGMA RESTRICT_REFERENCES(get_user_name, WNDS, WNPS, RNPS);

END FND_USER_AP_PKG;

 

/
