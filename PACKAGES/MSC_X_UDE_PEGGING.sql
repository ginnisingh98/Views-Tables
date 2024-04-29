--------------------------------------------------------
--  DDL for Package MSC_X_UDE_PEGGING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_X_UDE_PEGGING" AUTHID CURRENT_USER AS
/*  $Header: MSCXCES.pls 120.0 2005/05/25 17:38:33 appldev noship $ */
   FUNCTION days_late(p_transaction_id NUMBER) RETURN NUMBER;
   FUNCTION days_early(p_transaction_id NUMBER) RETURN NUMBER;
   FUNCTION quantity_excess(p_transaction_id NUMBER) RETURN NUMBER;
   FUNCTION quantity_shortage(p_transaction_id NUMBER) RETURN NUMBER;
END msc_x_ude_pegging;

 

/
