--------------------------------------------------------
--  DDL for Package Body WSH_OPM_CONV_MIG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_OPM_CONV_MIG_PKG" AS
/* $Header: WSHOPMDB.pls 120.0.12010000.2 2008/08/04 12:32:03 suppal ship $ */

/*====================================================================
--  PROCEDURE:
--   WSH_LOT_NUMBERS
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to OPM-OM Wdd lot number updates
--
--  PARAMETERS:
--    p_migration_run_id   This is used for message logging.
--    p_commit             Commit flag.
--    x_failure_count      count of the failed lines.An out parameter.
--
--  SYNOPSIS:
--
--    MIGRATE_OPM_OM_OPEN_LINES (  p_migration_run_id  IN NUMBER
--                          	, p_commit IN VARCHAR2
--                          	, x_failure_count OUT NUMBER)
--  HISTORY
--====================================================================*/

PROCEDURE WSH_LOT_NUMBERS( p_migration_run_id  IN NUMBER
                         , p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE
                         , x_failure_count OUT NOCOPY NUMBER
                         )
IS

/* Migration specific variables */
l_failure_count NUMBER := 0;
l_success_count NUMBER := 0;
l_table_name    VARCHAR2(30) DEFAULT NULL;
l_opm_table_name VARCHAR2(30) DEFAULT NULL;

-- Local Variables.
l_msg_count      NUMBER  :=0;
l_msg_data       VARCHAR2(2000);
l_return_status  VARCHAR2(1);

--l_wdd_rec		wsh_delivery_details%rowtype;
l_wdd_id               NUMBER;
l_so_line_id           NUMBER;
l_api_return_status    VARCHAR2(1);
l_api_error_code       NUMBER;
l_api_error_msg        VARCHAR2(100);
l_message              VARCHAR2(255);

l_odm_lot_number       VARCHAR2(80);
l_parent_lot_number    VARCHAR2(80);

  CURSOR get_opm_trans IS
  SELECT trans_id
     ,   line_id
     ,   line_detail_id
     ,   item_id
     ,   lot_id
     ,   whse_code
     ,   orgn_code
     ,   location
    FROM ic_tran_pnd      ictran
   WHERE ictran.doc_type = 'OMSO'
     AND ictran.delete_mark = 0
     AND ictran.staged_ind = 1               -- only for staged wdds, others lot_number is null
     AND abs(ictran.trans_qty) > 0
     AND (ictran.lot_id >0 )
     ;
BEGIN
   /* Begin by logging a message that reason_code migration has started */
   gma_common_logging.gma_migration_central_log (
                  p_run_id            => p_migration_run_id
                , p_log_level         => FND_LOG.LEVEL_PROCEDURE
                , p_app_short_name    => 'WSH'
                , p_message_token     => 'WSH_MIGRATION_TABLE_STARTED'
                , p_table_name        => 'wsh_delivery_details'
                , p_context           => 'LOT_NUMBER_UPDATES'
                );

   l_table_name := 'WSH_DELIVERY_DETAILS';
   l_opm_table_name := 'IC_TRAN_PND';

   /* Get all the transaction record related to OM lines to be processed */
   FOR opm_trans_rec IN get_opm_trans LOOP
       GMI_RESERVATION_UTIL.println('NNNNn In transaction loop');

      BEGIN
        l_so_line_id   := opm_trans_rec.line_id;
        l_wdd_id       := opm_trans_rec.line_detail_id;
        GMI_RESERVATION_UTIL.println('ic_tran_pnd wdd id , so_line_id'||'l_wdd_id:'||l_so_line_id);
        /* get the new convention for lot_Number in R12 */
        INV_OPM_LOT_MIGRATION.get_ODM_lot
           ( p_migration_run_id            => p_migration_run_id
           , p_item_id                     => opm_trans_rec.item_id
           , p_lot_id                      => opm_trans_rec.lot_id
           , p_whse_code                   => opm_trans_rec.whse_code
           , p_orgn_code                   => ''                          -- orgn code is null
           , p_location                    => opm_trans_rec.location
           , p_commit                      => p_commit
           , x_lot_number                  => l_odm_lot_number
           , x_parent_lot_number           => l_parent_lot_number
           , x_failure_count               => x_failure_count
           );

        GMI_RESERVATION_UTIL.println('ODM lot_number'||l_odm_lot_number);
        GMI_RESERVATION_UTIL.println('ODM parent lot number '||l_parent_lot_number);
        /* update wdd with the new lot_number */
        /* if the API get_odm_lot can not get the odm lot number, these wdds would not be updated */
        if (l_odm_lot_number is not null) and nvl(l_wdd_id, 0) <> 0 then
           Update wsh_delivery_details
           set lot_number = l_odm_lot_number
           where delivery_detail_id = l_wdd_id
           and lot_number is not null
           ;
           l_success_count := l_success_count + 1;
           GMI_RESERVATION_UTIL.println('update wdd successful id '||l_wdd_id);
        end if;

        EXCEPTION
           WHEN OTHERS THEN
               /* Failure count goes up by 1 */
               l_failure_count := l_failure_count+1;
               gma_common_logging.gma_migration_central_log (
                   p_run_id           => p_migration_run_id
                 , p_log_level        => FND_LOG.LEVEL_UNEXPECTED
                 , p_app_short_name   =>'WSH'
                 , p_message_token    => 'WSH_MIGRATION_DB_ERROR'
                 , p_db_error         => sqlerrm
                 , p_table_name       => 'wsh_delivery_details'
                 , p_context          => 'LOT_NUMBER_UPDATES'
                 );
      End;
   End Loop;
   /* End by logging a message that the migration has been succesful */
   gma_common_logging.gma_migration_central_log (
                  p_run_id      => p_migration_run_id
                , p_log_level   => FND_LOG.LEVEL_PROCEDURE
                , p_app_short_name => 'WSH'
                , p_message_token  => 'WSH_MIGRATION_TABLE_SUCCESS'
                , p_table_name  => NULL
                , p_context     => 'LOT_NUMBER_UPDTAES'
                , p_param1      => l_success_count
                , p_param2      => l_failure_count
                );

  x_failure_count := l_failure_count;

  if p_commit = FND_API.G_TRUE then
     commit;
  end if;

End WSH_LOT_NUMBERS;
End  WSH_OPM_CONV_MIG_PKG;

/
