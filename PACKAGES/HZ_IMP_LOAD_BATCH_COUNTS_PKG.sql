--------------------------------------------------------
--  DDL for Package HZ_IMP_LOAD_BATCH_COUNTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_IMP_LOAD_BATCH_COUNTS_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHLBCS.pls 120.5 2005/10/30 04:20:14 appldev noship $*/

  /*
     pre_import_counts() is being called from
     hz_imp_batch_summary_v2pub.activate_batch ()
     This will calculate the counts from 11 interface tables.
  */

   PROCEDURE pre_import_counts
     ( P_BATCH_ID        IN HZ_IMP_BATCH_SUMMARY.BATCH_ID%TYPE,
       P_ORIGINAL_SYSTEM IN HZ_IMP_BATCH_SUMMARY.ORIGINAL_SYSTEM%TYPE);

  /*
     post_import_counts() is being called from
     HZ_IMP_LOAD_WRAPPER package.
     This will calculate various counts like number of inserted, updated,
     errored entities. This is called after stage 3 is complete i.e.,
     all the entities DML is complete.
  */

   PROCEDURE post_import_counts
     ( P_BATCH_ID        IN HZ_IMP_BATCH_SUMMARY.BATCH_ID%TYPE,
       P_ORIGINAL_SYSTEM IN HZ_IMP_BATCH_SUMMARY.ORIGINAL_SYSTEM%TYPE,
       P_BATCH_MODE_FLAG IN VARCHAR2,
       P_REQUEST_ID      IN NUMBER,
       P_RERUN_FLAG      IN VARCHAR2); -- N for First Run any other value is rerun

  /*
     what_if_import_counts() is being called from
      HZ_IMP_LOAD_STAGE2 package.
     This will calculate the potential new and unique counts per entity.
  */

  PROCEDURE what_if_import_counts
     ( P_BATCH_ID    IN HZ_IMP_BATCH_SUMMARY.BATCH_ID%TYPE,
       P_ORIGINAL_SYSTEM IN HZ_IMP_BATCH_SUMMARY.ORIGINAL_SYSTEM%TYPE);

END HZ_IMP_LOAD_BATCH_COUNTS_PKG; -- Package spec
 

/
