--------------------------------------------------------
--  DDL for Package Body AR_MRC_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_MRC_ENGINE" AS
/* $Header: ARMCENGB.pls 120.7 2005/04/14 23:21:06 hyu noship $ */

  mc_init_rec     ar_mrc_init_rec_type;

/*=============================================================================
 |   Public Functions / Procedures
 *============================================================================*/

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
 |  CALLS PROCEDURES / FUNCTIONS (local to this package body)
 |
 |  PARAMETERS
 |   p_event_mode          IN     event to preform on MRC tables
 |   p_table_name          IN     Base Table Name.
 |   p_mode                IN     SINGLE /BATCH
 |   p_key_value           IN     primary key value
 |   p_key_value_list      IN     list of primarty key values
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date        Author                  Description of Change
 |  10/03/00    Debbie Sue Jancis  	Created
 |  02/27/01    Debbie Sue Jancis       Modified due to complete rewrite of
 |                                      MRC API's.
 |  07/10/01    Debbie Sue Jancis       Modified due to change in parameters
 |                                      for MRC API's which include changes
 |                                      implemented to AP implementation.
 |  08/27/01    Debbie Sue Jancis       Modified due to changes in parameters
 |                                      for MRC API's which include performance
 |                                      changes and removal of dynamic sql.
 *============================================================================*/
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE  Maintain_MRC_Data(
              p_event_mode     IN VARCHAR2,
              p_table_name     IN VARCHAR2,
              p_mode           IN VARCHAR2,
              p_key_value      IN NUMBER default NULL,
              p_key_value_list IN gl_ca_utility_pkg.r_key_value_arr default NULL
              ) IS
BEGIN
--{BUG4301323
NULL;
--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug( 'AR_MRC_ENGINE.Maintain_MRC_Data(+)');
--   END IF;

   /*-----------------------------------------------------------------+
    |  Dump the input parameters for debugging purposes               |
    +-----------------------------------------------------------------*/

--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug('Maintain_MRC_Data: ' || ' EVENT Mode        : ' || p_event_mode);
--      arp_standard.debug('Maintain_MRC_Data: ' || ' Table Name  : ' || p_table_name);
--      arp_standard.debug('Maintain_MRC_Data: ' || ' mode        : ' || p_mode);
--      arp_standard.debug('Maintain_MRC_Data: ' || 'key_value : ' || to_char(p_key_value));
--   END IF;

--   IF (p_key_value is NULL) THEN
--      IF PG_DEBUG in ('Y', 'C') THEN
--         arp_standard.debug('Maintain_MRC_Data: ' || 'count of value list =' || to_char(p_key_value_list.count));
--      END IF;
--   END IF;

   /*-----------------------------------------------------------------+
    | In order to work for backwards compatiability, we need to check |
    | for the table names which have had the trigger replaced.  So    |
    | each time a new table is added, it needs to be added here,      |
    | until all tables are added and this outside if statement can be |
    | removed. For the first iteration, only AR_ADJUSTMENTS and       |
    | AR_RATE_ADJUSTMENTS will be considered                          |
    +-----------------------------------------------------------------*/

--  IF (p_table_name = 'AR_ADJUSTMENTS'  or
--      p_table_name = 'AR_RATE_ADJUSTMENTS' or
--      p_table_name = 'AR_MISC_CASH_DISTRIBUTIONS' or
--      p_table_name = 'RA_BATCHES' or
--      p_table_name = 'AR_BATCHES' or
--      p_table_name = 'AR_CASH_RECEIPTS' or
--      p_table_name = 'AR_PAYMENT_SCHEDULES' or
--      p_table_name = 'RA_CUSTOMER_TRX' or
--      p_table_name = 'AR_CASH_RECEIPT_HISTORY' or
--      p_table_name = 'AR_DISTRIBUTIONS' or
--      p_table_name = 'RA_CUST_TRX_LINE_GL_DIST' or
--      p_table_name = 'AR_RECEIVABLE_APPLICATIONS' OR
      -- 3339072{
--      p_table_name = 'RA_CUSTOMER_TRX_LINES'
      --}
--      ) THEN

--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug('Maintain_MRC_Data: ' || 'Called with one of the supported table names ');
--   END IF;
   /*-----------------------------------------------------------------+
    |  First we need to check if MRC is enabled.  If it is than we    |
    |  continue processing.  If it is not then we are finished.       |
    +-----------------------------------------------------------------*/
--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug('Maintain_MRC_Data: ' || 'before checking to see if mrc is enabled..');
--   END IF;
--    IF (gl_ca_utility_pkg.mrc_enabled(p_sob_id => ar_mc_info.primary_sob_id,
--                               p_org_id => ar_mc_info.org_id,
--                               p_appl_id => 222
--                              ))  THEN

--   IF PG_DEBUG in ('Y', 'C') THEN
--      arp_standard.debug('Maintain_MRC_Data: ' || 'MRC is enabled...     ');
--   END IF;
       /* initialize stucture which will be used to call the mrc api */
--        ar_mrc_engine.init_struct (p_table_name,
--                                   p_mode,
--                                   p_key_value,
--                                   p_key_value_list);
--
       /*------------------------------------------------------------+
        | Branch based upon the mode of operation                    |
        +------------------------------------------------------------*/
--        IF  ( p_event_mode = 'INSERT' and
--              p_table_name <> 'AR_DISTRIBUTIONS' and
--              p_table_name <> 'AR_RECEIVABLE_APPLICATIONS') THEN
--          IF PG_DEBUG in ('Y', 'C') THEN
--             arp_standard.debug('Maintain_MRC_Data: ' || 'Before calling MRC api for Insertion');
--             arp_standard.debug('Maintain_MRC_Data: ' || '**** table name ' || mc_init_rec.p_table_name);
--             arp_standard.debug('Maintain_MRC_Data: ' || '**** mc name  ' || mc_init_rec.p_mc_table_name  );
--             arp_standard.debug('Maintain_MRC_Data: ' || '**** app id     ' || to_char(mc_init_rec.p_application_id ) );
--             arp_standard.debug('Maintain_MRC_Data: ' || '**** mode       ' || mc_init_rec.p_mode  );
--             arp_standard.debug('Maintain_MRC_Data: ' || '**** key_value  ' || to_char(mc_init_rec.p_key_value)  );
--          END IF;
--              BEGIN

--                ar_mc_info.insert_mc_data(
--                     p_table_name          => mc_init_rec.p_table_name,
--                     p_mc_table_name       => mc_init_rec.p_mc_table_name,
--                     p_application_id      => mc_init_rec.p_application_id,
--                     p_mode                => mc_init_rec.p_mode,
--                     p_key_value           => mc_init_rec.p_key_value,
--                     p_key_value_list      => mc_init_rec.p_key_value_list
--                   );

--              EXCEPTION
--               WHEN OTHERS THEN
--                  IF PG_DEBUG in ('Y', 'C') THEN
--                     arp_standard.debug('Maintain_MRC_Data: ' || SQLERRM);
--                    arp_standard.debug('Maintain_MRC_Data: ' || 'error during Insert for ' || p_table_name);
--                 END IF;
--                 APP_EXCEPTION.RAISE_EXCEPTION;
--              END;
--        END IF;   /* end p_event_mode = INSERT */

--        IF (p_event_mode = 'UPDATE' and
--            p_table_name <> 'AR_DISTRIBUTIONS' and
--            p_table_name <> 'AR_RECEIVABLE_APPLICATIONS') THEN

--           IF PG_DEBUG in ('Y', 'C') THEN
--              arp_standard.debug('Maintain_MRC_Data: ' || 'Before calling MRC api for Update');
--           END IF;
--           BEGIN
--              ar_mc_info.update_mc_data(
--                     p_table_name          => mc_init_rec.p_table_name,
--                     p_mc_table_name       => mc_init_rec.p_mc_table_name,
--                     p_application_id      => mc_init_rec.p_application_id,
--                     p_mode                => mc_init_rec.p_mode,
--                     p_key_value           => mc_init_rec.p_key_value,
--                     p_key_value_list      => mc_init_rec.p_key_value_list
--                      );

--           EXCEPTION
--              WHEN OTHERS THEN
--                 IF PG_DEBUG in ('Y', 'C') THEN
--                    arp_standard.debug('Maintain_MRC_Data: ' || 'error during update for ' || p_table_name);
--                 END IF;
--                 APP_EXCEPTION.RAISE_EXCEPTION;
--           END;
--        END IF;   /* end p_event_mode = UPDATE */

--        IF (p_event_mode = 'DELETE') THEN

--           IF PG_DEBUG in ('Y', 'C') THEN
--              arp_standard.debug('Maintain_MRC_Data: ' || 'Before calling MRC api for Deletion');
--           END IF;
--           BEGIN
--             ar_mc_info.delete_mc_data(
--                  p_table_name          => mc_init_rec.p_table_name,
--                  p_mc_table_name       => mc_init_rec.p_mc_table_name,
--                  p_mode                => mc_init_rec.p_mode,
--                  p_key_value           => mc_init_rec.p_key_value,
--                  p_key_value_list      => mc_init_rec.p_key_value_list
--                   );

--           EXCEPTION
--            WHEN OTHERS THEN
--              IF PG_DEBUG in ('Y', 'C') THEN
--                 arp_standard.debug('Maintain_MRC_Data: ' || 'Error deleting from: ' ||
--                                  mc_init_rec.p_mc_table_name);
--              END IF;
--              APP_EXCEPTION.RAISE_EXCEPTION;
--           END;
--        END IF;   /* end p_event_mode = DELETE */

--    END IF;  /* end of mrc is enabled */

--  END IF;   /* end of checking for specific tables */
--  IF PG_DEBUG in ('Y', 'C') THEN
--     arp_standard.debug( 'AR_MRC_ENGINE.Maintain_MRC_Data(-)');
--  END IF;

END Maintain_MRC_Data;

/*===========================================================================
 |  PROCEDURE  init_struct
 |
 |  DESCRIPTION:
 |                 This procedure will initialize the global structure for MRC
 |                 which will provide the values necessary to call the MRC
 |                 api's for insert/update and delete into the MRC tables based
 |                 upon the base table name passed in.
 |
 |  CALLS PROCEDURES / FUNCTIONS
 |
 |  PARAMETERS
 |     p_table_name	     IN   AR Base table name
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
 |  Date      	Author               	Description of Change
 |  10/09/00   	Debbie Sue Jancis     	Created
 |  02/27/01	Debbie Sue Jancis	Modified due to complete rewrite of
 |					MRC API's.
 |  07/10/01    Debbie Sue Jancis    	Modified due to change in parameters
 |                                 	for MRC API's which include changes
 |                                	implemented to AP implementation.
 |  08/27/01	Debbie Sue Jancis	Modified due to complete rewrite of
 |					MRC API's
 |
 *============================================================================*/
PROCEDURE init_struct(
                 p_table_name  		IN VARCHAR2,
                 p_mode                 IN VARCHAR2,
                 p_key_value            IN NUMBER,
                 p_key_value_list       IN gl_ca_utility_pkg.r_key_value_arr
                     ) IS
BEGIN
--{BUG#4301323
NULL;
--    IF PG_DEBUG in ('Y', 'C') THEN
--       arp_standard.debug('AR_MRC_ENGINE.init_struct(+)');
--       arp_standard.debug('init_struct: ' || 'Table Name : ' || p_table_name);
--    END IF;

    /*----------------------------------+
     | Populate items that are the same |
     | for each table                   |
     +----------------------------------*/

--    mc_init_rec.p_table_name := p_table_name;
--    mc_init_rec.p_application_id := 222;
--    mc_init_rec.p_mode := p_mode;
--    mc_init_rec.p_key_value_list := p_key_value_list;
--    mc_init_rec.p_key_value := p_key_value;

    /*----------------------------------+
     | Populate Table specific items    |
     +----------------------------------*/

--    IF (p_table_name = 'AR_ADJUSTMENTS') THEN
--        mc_init_rec.p_mc_table_name :=  'AR_MC_ADJUSTMENTS';

--    ELSIF (p_table_name = 'AR_RATE_ADJUSTMENTS') THEN
--        mc_init_rec.p_mc_table_name := 'AR_MC_RATE_ADJUSTMENTS' ;

--    ELSIF (p_table_name = 'AR_MISC_CASH_DISTRIBUTIONS') THEN
--        mc_init_rec.p_mc_table_name := 'AR_MC_MISC_CASH_DISTS' ;

--    ELSIF (p_table_name = 'AR_BATCHES') THEN
--        mc_init_rec.p_mc_table_name := 'AR_MC_BATCHES' ;

--    ELSIF (p_table_name = 'RA_BATCHES') THEN
--        mc_init_rec.p_mc_table_name := 'RA_MC_BATCHES' ;

--    ELSIF (p_table_name = 'AR_CASH_RECEIPTS') THEN
--        mc_init_rec.p_mc_table_name := 'AR_MC_CASH_RECEIPTS' ;

--    ELSIF (p_table_name = 'AR_PAYMENT_SCHEDULES') THEN
--        mc_init_rec.p_mc_table_name := 'AR_MC_PAYMENT_SCHEDULES' ;

--    ELSIF (p_table_name = 'RA_CUSTOMER_TRX') THEN
--        mc_init_rec.p_mc_table_name := 'RA_MC_CUSTOMER_TRX' ;

--    ELSIF (p_table_name = 'AR_CASH_RECEIPT_HISTORY') THEN
--        mc_init_rec.p_mc_table_name := 'AR_MC_CASH_RECEIPT_HIST' ;

--    ELSIF (p_table_name = 'AR_DISTRIBUTIONS') THEN
--        mc_init_rec.p_mc_table_name := 'AR_MC_DISTRIBTIONS' ;

--    ELSIF (p_table_name = 'AR_RECEIVABLE_APPLICATIONS') THEN
--        mc_init_rec.p_mc_table_name := 'AR_MC_RECEIVABLE_APPS' ;
    --{3339072
--    ELSIF (p_table_name = 'RA_CUSTOMER_TRX_LINES') THEN
--        mc_init_rec.p_mc_table_name := 'RA_MC_CUSTOMER_TRX_LINES' ;
    --}
--    ELSIF (p_table_name = 'RA_CUST_TRX_LINE_GL_DIST') THEN
--        mc_init_rec.p_mc_table_name := 'RA_MC_TRX_LINE_GL_DIST' ;
--    END IF;

--    IF PG_DEBUG in ('Y', 'C') THEN
--       arp_standard.debug('AR_MRC_ENGINE.init_struct(-)');
--    END IF;
END init_struct;


/*===========================================================================
 |  PROCEDURE  mrc_bulk_process
 |
 |  DESCRIPTION:
 |                 This procedure will be called by autoinvoice to insert
 |                 records into MRC tables using BULK processing
 |
 |  CALLS PROCEDURES / FUNCTIONS
 |
 |  ar_mc_info.inv_mrc_bulk_process    (MRC bulk processing API
 |				        called from AutoInvoice and copy trx
 |					for ar_adjustments, RA_CUSTOMER_TRX
 |				        and ar_payment_schedules inserts)
 |  PARAMETERS
 |     p_request_id          IN   VARCHAR2
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
 |  03/11/02    Debbie Sue Jancis       Modified for new strategy in calling
 | 					MRC API once for autoinv and
 |					cpy trx processing. p_tablename will
 |					no longer represent a tablename but
 | 					will have to represent a calling
 |					program.  it will have RAXTRX or
 |					CPYTRX populated.   Not changing the
 |					name as that would require the STUB
 |					program to have a change which would
 |					make a maintainance nightmare.
 |  08/30/02   Debbie Sue Jancis        Added additional program name
 |                                      'GL_DIST' to process just the
 |                                      gl_dist lines by request id.
 *============================================================================*/
PROCEDURE mrc_bulk_process (
                 p_request_id         IN VARCHAR2,
                 p_table_name         IN VARCHAR2
                           ) IS
BEGIN
--{BUG4301323
NULL;
--    IF PG_DEBUG in ('Y', 'C') THEN
--       arp_standard.debug('AR_MRC_ENGINE.mrc_bulk_process(+)');
--       arp_standard.debug('mrc_bulk_process: ' || 'CALLING PROGRAM : ' || p_table_name);
--       arp_standard.debug('mrc_bulk_process: ' || 'before checking to see if mrc is enabled..');
--    END IF;
--    IF (gl_ca_utility_pkg.mrc_enabled(p_sob_id => ar_mc_info.primary_sob_id,
--                               p_org_id => ar_mc_info.org_id,
--                               p_appl_id => 222
--                              ))  THEN

--        IF PG_DEBUG in ('Y', 'C') THEN
--           arp_standard.debug('mrc_bulk_process: ' || 'MRC is enabled...     ');
--        END IF;
--        IF (p_table_name = 'GL_DIST') THEN
--           ar_mc_info.inv_import_cld(p_request_id);
--        ELSE
--           ar_mc_info.inv_mrc_bulk_process(to_number(p_request_id),
--                                    p_table_name);
--        END IF;
--    END IF;

--    IF PG_DEBUG in ('Y', 'C') THEN
--       arp_standard.debug('AR_MRC_ENGINE.mrc_bulk_process(-)');
--    END IF;
END mrc_bulk_process;

END AR_MRC_ENGINE;

/
