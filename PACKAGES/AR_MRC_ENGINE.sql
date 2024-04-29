--------------------------------------------------------
--  DDL for Package AR_MRC_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_MRC_ENGINE" AUTHID CURRENT_USER AS
/* $Header: ARMCENGS.pls 120.1 2004/12/03 01:45:53 orashid noship $ */

/*============================================================================+
 |  Declare PUBLIC Data Types and Variables                                   |
 +============================================================================*/

 --  Init Record Type
 TYPE ar_mrc_init_rec_type is RECORD (
     p_table_name       VARCHAR2(50),    --  AR Base Table Name
     p_mc_table_name    VARCHAR2(50),    --  Corresponsing MRC table name
     p_application_id   NUMBER,          --  222 for AR
     p_mode             VARCHAR2(11),
     p_key_value        NUMBER,
     p_key_value_list   gl_ca_utility_pkg.r_key_value_arr
   );


/*=============================================================================
 |  PUBLIC PROCEDURE  Maintain_MRC_Data
 |
 |  DESCRIPTION:
 |                Initial Entry point for all AR code in order to maintain,
 |                create, and delete any MRC data
 |
 |                This procedure will call the appropriate MRC api with the
 |                information required.
 |
 |  PARAMETERS
 |   p_event_mode          IN     event to preform on MRC tables
 |   p_table_name          IN     Base Table Name.
 |   p_mode                IN     SINGLE /BATCH
 |   p_key_value           IN     primary key value
 |   p_key_value_list      IN
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date    	Author             	Description of Change
 |  10/03/00	Debbie Sue Jancis  	Created
 |  02/27/01	Debbie Sue Jancis	Modified due to complete rewrite of
 |					MRC API's.
 |  07/10/01    Debbie Sue Jancis       Modified due to change in parameters
 |                                      for MRC API's which include changes
 |                                      implemented to AP implementation.
 |  08/27/01    Debbie Sue Jancis       Modified due to changes in parameters
 |                                      for MRC API's which include performance
 |                                      changes and removal of dynamic sql.
 |
 *============================================================================*/
 PROCEDURE  Maintain_MRC_Data(
              p_event_mode     IN VARCHAR2,
              p_table_name     IN VARCHAR2,
              p_mode           IN VARCHAR2,
              p_key_value      IN NUMBER default null,
              p_key_value_list IN gl_ca_utility_pkg.r_key_value_arr default null
              );

/*===========================================================================
 |  PROCEDURE  init_struct
 |
 |  DESCRIPTION:
 |                 This procedure will initialize the global structure for MRC
 |                 which will provide the values necessary to call the MRC
 |                 api's for insert/update and delete into the MRC tables based
 |                 upon the base table name passed in.
 |
 |  PARAMETERS
 |     p_table_name          IN   AR Base table name
 |     p_mode                IN   SINGLE OR BATCH
 |     p_key_value           IN
 |     p_key_value_list      IN
 |
 |  KNOWN ISSUES:
 |        At first attempt this is a prototype for the AR_ADJUSTMENTS and
 |        AR_RATE_ADJUSTMENTS tables.  Once the prototype is complete, the
 |        other tables affected by MRC trigger logic will be incorporated.
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date      Author               Description of Change
 |  10/9/00   Debbie Sue Jancis    Created
 |  02/27/01  Debbie Sue Jancis    Modified due to complete redesign on MRC
 |				   API's.
 |  07/10/01  Debbie Sue Jancis    Modified due to change in parameters
 |                                 for MRC API's which include changes
 |                                 implemented to AP implementation.
 |  08/27/01  Debbie Sue Jancis    Modified due to complete rewrite of
 |                                 MRC API's
 |
 *============================================================================*/
 PROCEDURE init_struct(
                 p_table_name           IN VARCHAR2,
                 p_mode                 IN VARCHAR2,
                 p_key_value            IN NUMBER,
                 p_key_value_list       IN gl_ca_utility_pkg.r_key_value_arr
);

/*===========================================================================
 |  PROCEDURE  mrc_bulk_process
 |
 |  DESCRIPTION:
 |                 This procedure will be called by autoinvoice to insert
 |                 records into MRC tables using BULK processing
 |
 |  CALLS PROCEDURES / FUNCTIONS
 |
 |  ar_mc_info.insert_mc_imp_adj (MRC bulk processing API
 |                                called from AutoInvoice for
 |                                ar_adjustments inserts)
 |  PARAMETERS
 |     p_request_id          IN   NUMBER
 |     p_tablename           IN   VARCHAR2    - AR BASE TABLE NAME
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |     For the initial coding, it was determined that this was required for
 |     the AR_ADJUSTMENTS table processing used in AUTOINVOICE to improve
 |     performance.   Because a full analysis on the code has not been done
 |     for other tables, I am leaving in placeholders for those tables.
 |     if it is found that other calls will not be needed, those placeholders
 |     will be removed.
 |
 |  MODIFICATION HISTORY
 |  Date        Author                  Description of Change
 |  07/18/01    Debbie Sue Jancis       Created
 *============================================================================*/
PROCEDURE mrc_bulk_process (
                 p_request_id         IN VARCHAR2,
                 p_table_name         IN VARCHAR2);

END AR_MRC_ENGINE;

 

/
