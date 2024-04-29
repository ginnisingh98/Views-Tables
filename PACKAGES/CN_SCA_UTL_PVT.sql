--------------------------------------------------------
--  DDL for Package CN_SCA_UTL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SCA_UTL_PVT" AUTHID CURRENT_USER AS
-- $Header: cnvscaus.pls 120.1 2005/09/15 14:46:40 rchenna noship $
-- +======================================================================+
-- |                Copyright (c) 1994 Oracle Corporation                 |
-- |                   Redwood Shores, California, USA                    |
-- |                        All rights reserved.                          |
-- +======================================================================+
--
-- Package Name
--   CN_SCA_UTL_PVT
-- Purpose
--   This package has utilities and being used by other Rules Engine
--   PL/SQL packages.
-- History
--   06/23/03   Rao.Chenna         Created

FUNCTION get_valuset_query (l_valueset_id NUMBER) RETURN VARCHAR2;

PROCEDURE manage_indexes(
        p_transaction_source    IN      	VARCHAR2,
        p_org_id		IN		NUMBER,
	x_return_status		OUT NOCOPY 	VARCHAR2);

END; -- Package spec
 

/
