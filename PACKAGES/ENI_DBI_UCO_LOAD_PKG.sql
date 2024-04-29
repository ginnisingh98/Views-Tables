--------------------------------------------------------
--  DDL for Package ENI_DBI_UCO_LOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENI_DBI_UCO_LOAD_PKG" AUTHID CURRENT_USER AS
/* $Header: ENIUCOLS.pls 115.2 2003/12/01 22:56:30 gratnam noship $ */

-- Initial collection of the cost fact
PROCEDURE initial_item_cost_collect
( o_error_msg OUT NOCOPY VARCHAR2,
  o_error_code OUT NOCOPY VARCHAR2,
  p_start_date IN VARCHAR2,
  p_end_date IN VARCHAR2
);

FUNCTION Report_Missing_Rate return NUMBER;


-- Incremental collection of the cost fact
PROCEDURE incremental_item_cost_collect
(
  o_error_msg OUT NOCOPY VARCHAR2,
  o_error_code OUT NOCOPY VARCHAR2
);


END ENI_DBI_UCO_LOAD_PKG;

 

/
