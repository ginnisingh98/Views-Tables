--------------------------------------------------------
--  DDL for Package POS_ORG_HASH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_ORG_HASH_PKG" AUTHID CURRENT_USER AS
/* $Header: POSORGHS.pls 115.1 2002/11/20 22:08:10 jazhang noship $ */

FUNCTION get_hashkey(p_org_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_org_id_by_key(p_hashkey IN VARCHAR2) RETURN NUMBER;

END pos_org_hash_pkg;

 

/
