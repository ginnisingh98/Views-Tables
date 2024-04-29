--------------------------------------------------------
--  DDL for Package Body CSTPPLCS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPPLCS" AS
/* $Header: CSTPLCSB.pls 115.6 2002/11/11 19:13:22 awwang ship $ */
  PROCEDURE purge_def_cat_acc_class (
    status OUT NOCOPY INTEGER,
    err_buf OUT NOCOPY VARCHAR2) IS
  BEGIN

    DELETE wip_def_cat_acc_classes;

  EXCEPTION
    WHEN OTHERS THEN
       status := -1;
       err_buf := 'CSTPPLCS:' || substrb(Sqlerrm,1,60);
       RETURN;
  END;
END CSTPPLCS;


/
