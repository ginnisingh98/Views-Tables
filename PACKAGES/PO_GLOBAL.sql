--------------------------------------------------------
--  DDL for Package PO_GLOBAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_GLOBAL" AUTHID CURRENT_USER AS
/* $Header: PO_GLOBAL.pls 120.1 2005/06/15 16:47:01 bao noship $ */

g_role_BUYER CONSTANT PO_HEADERS_ALL.lock_owner_role%TYPE := 'BUYER';
g_role_CAT_ADMIN CONSTANT PO_HEADERS_ALL.lock_owner_role%TYPE := 'CAT_ADMIN';
g_role_SUPPLIER CONSTANT PO_HEADERS_ALL.lock_owner_role%TYPE := 'SUPPLIER';

g_role PO_HEADERS_ALL.lock_owner_role%TYPE;

PROCEDURE set_role
( p_role IN VARCHAR2
);

FUNCTION role RETURN VARCHAR2;


END PO_GLOBAL;

 

/
