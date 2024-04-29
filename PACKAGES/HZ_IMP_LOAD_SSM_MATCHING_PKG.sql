--------------------------------------------------------
--  DDL for Package HZ_IMP_LOAD_SSM_MATCHING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_IMP_LOAD_SSM_MATCHING_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHLSSMS.pls 120.5 2005/10/30 03:53:21 appldev noship $*/


   /* Party is the root entities - first entity to be processed */
   PROCEDURE match_parties(
     P_BATCH_ID                   IN       NUMBER,
     P_OS                         IN       VARCHAR2,
     P_FROM_OSR                   IN       VARCHAR2,
     P_TO_OSR                     IN       VARCHAR2,
     P_ACTUAL_CONTENT_SRC         IN       VARCHAR2,
     P_RERUN                      IN       VARCHAR2,
     P_BATCH_MODE_FLAG            IN       VARCHAR2
   );


   /* Address is the second entity to be processed. */
   PROCEDURE match_addresses(
     P_BATCH_ID                   IN       NUMBER,
     P_OS                         IN       VARCHAR2,
     P_FROM_OSR                   IN       VARCHAR2,
     P_TO_OSR                     IN       VARCHAR2,
     P_RERUN                      IN       VARCHAR2,
     P_BATCH_MODE_FLAG            IN       VARCHAR2
   );


   PROCEDURE match_contact_points(
     P_BATCH_ID                   IN       NUMBER,
     P_OS                         IN       VARCHAR2,
     P_FROM_OSR                   IN       VARCHAR2,
     P_TO_OSR                     IN       VARCHAR2,
     P_RERUN                      IN       VARCHAR2,
     P_BATCH_MODE_FLAG            IN       VARCHAR2
   );


   PROCEDURE match_credit_ratings(
     P_BATCH_ID                   IN       NUMBER,
     P_OS                         IN       VARCHAR2,
     P_FROM_OSR                   IN       VARCHAR2,
     P_TO_OSR                     IN       VARCHAR2,
     P_DEF_START_TIME             IN       DATE,
     P_ACTUAL_CONTENT_SRC         IN       VARCHAR2,
     P_RERUN                      IN       VARCHAR2,
     P_BATCH_MODE_FLAG            IN       VARCHAR2
   );


   PROCEDURE match_code_assignments(
     P_BATCH_ID                   IN       NUMBER,
     P_OS                         IN       VARCHAR2,
     P_FROM_OSR                   IN       VARCHAR2,
     P_TO_OSR                     IN       VARCHAR2,
     P_ACTUAL_CONTENT_SRC         IN       VARCHAR2,
     P_RERUN                      IN       VARCHAR2,
     P_BATCH_MODE_FLAG            IN       VARCHAR2
   );


   PROCEDURE match_financial_reports(
     P_BATCH_ID                   IN       NUMBER,
     P_OS                         IN       VARCHAR2,
     P_FROM_OSR                   IN       VARCHAR2,
     P_TO_OSR                     IN       VARCHAR2,
     P_ACTUAL_CONTENT_SRC         IN       VARCHAR2,
     P_RERUN                      IN       VARCHAR2,
     P_BATCH_MODE_FLAG            IN       VARCHAR2
   );


   PROCEDURE match_financial_numbers(
     P_BATCH_ID                   IN       NUMBER,
     P_OS                         IN       VARCHAR2,
     P_FROM_OSR                   IN       VARCHAR2,
     P_TO_OSR                     IN       VARCHAR2,
     P_ACTUAL_CONTENT_SRC         IN       VARCHAR2,
     P_RERUN                      IN       VARCHAR2,
     P_BATCH_MODE_FLAG            IN       VARCHAR2
   );


   PROCEDURE match_relationships(
     P_BATCH_ID                   IN       NUMBER,
     P_OS                         IN       VARCHAR2,
     P_FROM_OSR                   IN       VARCHAR2,
     P_TO_OSR                     IN       VARCHAR2,
     P_ACTUAL_CONTENT_SRC         IN       VARCHAR2,
     P_RERUN                      IN       VARCHAR2,
     P_BATCH_MODE_FLAG            IN       VARCHAR2
   );


   PROCEDURE match_contacts(
     P_BATCH_ID                   IN       NUMBER,
     P_OS                         IN       VARCHAR2,
     P_FROM_OSR                   IN       VARCHAR2,
     P_TO_OSR                     IN       VARCHAR2,
     P_ACTUAL_CONTENT_SRC         IN       VARCHAR2,
     P_RERUN                      IN       VARCHAR2,
     P_BATCH_MODE_FLAG            IN       VARCHAR2
   );


   PROCEDURE match_contactroles(
     P_BATCH_ID                   IN       NUMBER,
     P_OS                         IN       VARCHAR2,
     P_FROM_OSR                   IN       VARCHAR2,
     P_TO_OSR                     IN       VARCHAR2,
     P_ACTUAL_CONTENT_SRC         IN       VARCHAR2,
     P_RERUN                      IN       VARCHAR2,
     P_BATCH_MODE_FLAG            IN       VARCHAR2
   );


   PROCEDURE match_addruses(
     P_BATCH_ID                   IN       NUMBER,
     P_OS                         IN       VARCHAR2,
     P_FROM_OSR                   IN       VARCHAR2,
     P_TO_OSR                     IN       VARCHAR2,
     P_ACTUAL_CONTENT_SRC         IN       VARCHAR2,
     P_RERUN                      IN       VARCHAR2,
     P_BATCH_MODE_FLAG            IN       VARCHAR2
   );


END HZ_IMP_LOAD_SSM_MATCHING_PKG;
 

/
