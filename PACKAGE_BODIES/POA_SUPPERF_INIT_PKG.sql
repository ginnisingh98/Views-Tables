--------------------------------------------------------
--  DDL for Package Body POA_SUPPERF_INIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_SUPPERF_INIT_PKG" AS
/* $Header: POASPINB.pls 115.0 99/07/15 20:04:03 porting shi $: */

   -- init_supplier_performance
   -- -----------------------------
   -- This is the procedure that is called by the concurrenct program to
   -- populate the supplier performance fact table.  Instead of purging
   -- all rows and re-inserting them, it first gets the most recent update
   -- date from the table and only inserts rows later than that date or row
   -- that need to be updated.
   --

   PROCEDURE init_supplier_performance(p_start_date IN DATE, p_end_date IN DATE)
   IS
      v_num_rows          NUMBER:= 0;
      x_progress          VARCHAR2(3) := NULL;
   BEGIN

      POA_LOG.debug_line('init_supplier_performance:  entered');
      POA_LOG.put_line(' ');

      poa_supperf_populate_pkg.populate_fact_table(p_start_date, p_end_date);

   EXCEPTION
      WHEN OTHERS THEN
   	 POA_LOG.put_line('init_supplier_perf:  ' || x_progress
                          || ' ' || sqlerrm);
      	 POA_LOG.put_line(' ');
         RAISE;

   END init_supplier_performance;


END POA_SUPPERF_INIT_PKG;




/
