--------------------------------------------------------
--  DDL for Package OKL_BPD_INV_MESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_BPD_INV_MESS" AUTHID CURRENT_USER AS
/* $Header: OKLRMESS.pls 115.3 2002/07/12 18:56:42 stmathew noship $ */

   FUNCTION func1
     ( p_cntr_id IN NUMBER)
     RETURN  BOOLEAN;

  FUNCTION func2
     ( p_cntr_id IN NUMBER)
     RETURN  BOOLEAN;

END;

 

/
