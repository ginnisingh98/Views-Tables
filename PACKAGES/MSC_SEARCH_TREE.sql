--------------------------------------------------------
--  DDL for Package MSC_SEARCH_TREE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_SEARCH_TREE" AUTHID CURRENT_USER AS
        /* $Header: MSCSRCHS.pls 120.0 2005/05/25 20:30:13 appldev noship $ */

PROCEDURE query_results(p_query_id NUMBER, p_where VARCHAR2, p_type VARCHAR2);

END MSC_SEARCH_TREE;

 

/
