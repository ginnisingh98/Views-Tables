--------------------------------------------------------
--  DDL for Package CSTPPLCS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPPLCS" AUTHID CURRENT_USER AS
/* $Header: CSTPLCSS.pls 115.5 2002/11/11 19:13:38 awwang ship $ */
  -- The status returned is negative if an error occurred
  PROCEDURE purge_def_cat_acc_class(
    status OUT NOCOPY INTEGER,
    err_buf OUT NOCOPY VARCHAR2);
END cstpplcs;

 

/
