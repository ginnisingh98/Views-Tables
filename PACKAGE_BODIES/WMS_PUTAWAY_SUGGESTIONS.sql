--------------------------------------------------------
--  DDL for Package Body WMS_PUTAWAY_SUGGESTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_PUTAWAY_SUGGESTIONS" AS
/* $Header: WMSPRGEB.pls 120.8.12010000.6 2010/02/19 09:02:47 vissubra ship $ */

-- Global constant holding the package name
   g_pkg_name constant varchar2(50) := 'WMS_PUTAWAY_SUGGESTIONS';

/*===========================================================================+
 | Procedure:                                                                |
 |    conc_pre_generate                                                      |
 |                                                                           |
 | Description:                                                              |
 |    This is a wrapper API that calls WMS_PUTAWAY_SUGGESTIONS.PRE_GENERATE  |
 | API. It has the necessary parameters required for being a concurrent      |
 | program.                                                                  |
 |                                                                           |
 | Input Parameters:                                                         |
 |       p_organization_id                                                   |
 |         Mandatory parameter. Organization where putaway suggestions have  |
 |         to be pre-generated.                                              |
 |       p_lpn_id                                                            |
 |         Optional parameter. LPN for which suggestions have to be created. |
 |                                                                           |
 | Output Parameters:                                                        |
 |        x_errorbuf                                                         |
 |          Standard Concurrent program parameter - Holds error message.     |
 |        x_retcode                                                          |
 |          Standard Concurrent program parameter - Normal, Warning, Error.  |
 |                                                                           |
 | API Used:                                                                 |
 |     PRE_GENERATE API to generate the putaway suggestions.                 |
 +===========================================================================*/

PROCEDURE print_debug(p_err_msg VARCHAR2,
		      p_level NUMBER := 4)
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   inv_mobile_helper_functions.tracelog
     (p_err_msg => p_err_msg,
      p_module => 'wms_putaway_suggestions',
      p_level => p_level);

END;

PROCEDURE conc_pre_generate(
     x_errorbuf         OUT NOCOPY VARCHAR2,
     x_retcode          OUT NOCOPY VARCHAR2,
     p_organization_id   IN  NUMBER,
     p_lpn_id            IN  NUMBER,
     p_is_srs_call       IN VARCHAR2 DEFAULT NULL
     )
     IS

--Variables

      l_return_status             VARCHAR2(1);
      l_msg_count                 NUMBER;
      l_msg_data                  VARCHAR2(2000);
      l_msg 			  VARCHAR2(200);
      l_conc_status               BOOLEAN;
      l_lpn_line_error_tbl        lpn_line_error_tbl;

      l_partial_success           VARCHAR2(1);
--partial_success is a flag used to denote whether suggestions have been
--generated successfully for all LPNs.
--l_partial_success = 'N', if all LPN have been succesfully processed.
      --                    'Y', if one or more LPN have errored out.


    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      print_debug('Entered WMS_PUTAWAY_SUGGESTIONS.conc_pre_generate');
      print_debug('Org:'||p_organization_id);
      print_debug('LPN:'||p_lpn_id);
      print_debug('p_is_srs_call: '||p_is_srs_call);
   END IF;


      WMS_PUTAWAY_SUGGESTIONS.pre_generate
	(x_return_status       =>    l_return_status,
	 x_msg_count           =>    l_msg_count,
	 x_msg_data            =>    l_msg_data,
	 x_partial_success     =>    l_partial_success,
	 x_lpn_line_error_tbl  =>    l_lpn_line_error_tbl,
	 p_from_conc_pgm       =>    'Y',
	 p_commit              =>    'Y',
	 p_organization_id     =>    p_organization_id,
	 p_lpn_id              =>    p_lpn_id,
	 p_is_srs_call         =>    Nvl(p_is_srs_call, 'Y')
	 );


      IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
	 IF (l_return_status = fnd_api.g_ret_sts_error) THEN
	    RAISE fnd_api.g_exc_error;
	  ELSE
	    RAISE fnd_api.g_exc_unexpected_error;
	 END IF;
       ELSE
	 IF (l_partial_success = 'Y') THEN
	    fnd_message.set_name('WMS', 'WMS_LPN_PROC_WARN');
	    fnd_msg_pub.add;
	    print_message();
	    l_msg := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
	    l_conc_status := fnd_concurrent.set_completion_status('WARNING',l_msg);
	    x_retcode := RETCODE_WARNING;
	    x_errorbuf := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
	  ELSE
	    print_message();
	    l_conc_status := fnd_concurrent.set_completion_status('NORMAL','NORMAL');
	    x_retcode := RETCODE_SUCCESS;
	    x_errorbuf := NULL;
	 END IF;
      END IF;


EXCEPTION
  WHEN fnd_api.g_exc_error THEN

       print_message();
       l_conc_status := fnd_concurrent.set_completion_status('ERROR','ERROR');
       x_retcode := RETCODE_ERROR;
       x_errorbuf := fnd_msg_pub.get(p_encoded => fnd_api.g_false);

  WHEN fnd_api.g_exc_unexpected_error THEN

       print_message();
       l_conc_status := fnd_concurrent.set_completion_status('ERROR','ERROR');
       x_retcode := RETCODE_ERROR;
       x_errorbuf := fnd_msg_pub.get(p_encoded => fnd_api.g_false);

  WHEN OTHERS THEN

       print_message();
       l_conc_status := fnd_concurrent.set_completion_status('ERROR','ERROR');
       x_retcode := RETCODE_ERROR;
       x_errorbuf := fnd_msg_pub.get(p_encoded => fnd_api.g_false);

END conc_pre_generate;


-- Procedure called by receiving. The procedure submits a request to start
--the concurrent program
PROCEDURE start_pregenerate_program
  (p_org_id               IN   NUMBER,
   p_lpn_id               IN   NUMBER,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2
   )
  IS

     l_req_id    NUMBER;
     l_wms_install               BOOLEAN  := FALSE;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF (l_debug = 1) THEN
      print_debug('Entered start_pregenerate_program');
      print_debug('Org:'||p_org_id);
      print_debug('LPN:'||p_lpn_id);
   END IF;

/*
   l_wms_install := WMS_INSTALL.check_install
     (x_return_status       =>    x_return_status,
      x_msg_count           =>    x_msg_count,
      x_msg_data            =>    x_msg_data,
      p_organization_id     =>    p_org_id
      );

   IF (NOT l_wms_install) THEN
      fnd_message.set_name('WMS', 'WMS_NOT_INSTALLED');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
   END IF;
*/

   IF (p_org_id is null) THEN
      fnd_message.set_name('INV', 'INV_ORG_REQUIRED');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
   END IF;


   l_req_id := fnd_request.submit_request
     (application  =>  'WMS',
      program      =>  'WMSPRPUT',
      description  =>  'Pregenerate putaway suggestions',
      argument1    =>  TO_CHAR(p_org_id),
      argument2    =>  TO_CHAR(p_lpn_id),
      argument3    =>  'N');

   IF (l_debug = 1) THEN
      print_debug('After calling the suggestions:'||l_req_id);
   END IF;
   IF l_req_id = 0 THEN
      IF (l_debug = 1) THEN
   	 print_debug('error calling the conc. request');
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);

END start_pregenerate_program;




/*===========================================================================+
 | Procedure:                                                                |
 |     pre_generate                                                          |
 |                                                                           |
 | Description:                                                              |
 |    This API polls receipts table for receipts yet to be put away and      |
 | create suggestions for their put away.                                    |
 |                                                                           |
 | Input Parameters:                                                         |
 |       p_from_conc_pgm                                                     |
 |         Mandatory parameter. Default 'Y'. Indicates if the caller is      |
 |         concurrent program or otherwise. This is needed to know if        |
 |         messages have to be logged in a file.                             |
 |       p_commit                                                            |
 |         Mandatory parameter. Default 'Y'. Indicates if commit has to      |
 |         happen.                                                           |
 |       p_organization_id                                                   |
 |         Mandatory parameter. Organization where putaway suggestions have  |
 |         to be pre-generated.                                              |
 |       p_lpn_id                                                            |
 |         Optional parameter. LPN for which suggestions have to be created. |
 |                                                                           |
 | Output Parameters:                                                        |
 |        x_return_status                                                    |
 |          Standard API return status - Success, Error, Unexpected Error.   |
 |        x_msg_count                                                        |
 |          Number of messages in the message queue                          |
 |        x_msg_data                                                         |
 |          If the number of messages in the message queue is one,           |
 |          x_msg_data has the message text.                                 |
 |        x_partial_success                                                  |
 |          Indicates if one or more lpns errored out.                       |
 |        x_lpn_line_error_tbl                                               |
 |          Plsql table to hold the errored out lpn_ids and line_ids.        |
 |                                                                           |
 | Tables Used:                                                              |
 |        1. mtl_txn_request_headers                                         |
 |        2. mtl_txn_request_lines                                           |
 +===========================================================================*/
--
PROCEDURE pre_generate(
    x_return_status        OUT NOCOPY VARCHAR2,
    x_msg_count            OUT NOCOPY NUMBER,
    x_msg_data             OUT NOCOPY VARCHAR2,
    x_partial_success      OUT NOCOPY VARCHAR2,
    x_lpn_line_error_tbl   OUT NOCOPY lpn_line_error_tbl,
    p_from_conc_pgm         IN   VARCHAR2,
    p_commit                IN   VARCHAR2,
    p_organization_id       IN   NUMBER,
    p_lpn_id                IN   NUMBER,
    p_is_srs_call           IN   VARCHAR2 DEFAULT NULL
    )
    IS

--Variables
    l_wms_install       BOOLEAN     := FALSE;
    l_error	        BOOLEAN     := FALSE;
    l_entry_loop        BOOLEAN     := FALSE;
    l_from_conc_pgm     VARCHAR2(1) := p_from_conc_pgm;
    l_partial_success   VARCHAR2(1) := 'N';
    l_tbl_index         NUMBER      := 1;
    l_cnt_success       NUMBER      := 0;
    l_cnt_failed        NUMBER      := 0;

    l_mtl_reservation	inv_reservation_global.mtl_reservation_tbl_type;
    l_return_status	VARCHAR2(1);
    l_mol_line_id	NUMBER;
    l_mol_line_no       NUMBER;
    l_lpn_id		NUMBER;
    l_lpn_no 		VARCHAR2(30);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_label_status      VARCHAR2(300);
    l_temp_id           NUMBER;
    -- Following 3 variables were added for Bug# 4178478
    -- l_lpn_table l_lpn_table_type; -- Commented out as part of fix for bug # 4964866
    l_temp_lpn_id       NUMBER;
    l_print_lpn_label   VARCHAR2(5);
    l_organization_id   NUMBER;          -- Added for  bug # 4964866
    l_subinventory_code VARCHAR2(10);    -- Added for  bug # 4964866
    l_locator_id        NUMBER;          -- Added for  bug # 4964866
    l_mmtt_table        mmtt_table_type; -- Added for bug # 4964866

    l_discrepancy       NUMBER;   -- Bug 7460112


    -- Following variables added in ATF_J

    l_backorder_delivery_detail_id NUMBER;
    l_crossdock_type NUMBER;
    l_wip_supply_type NUMBER;
    l_lpn_context       NUMBER;
    l_process_flag_count NUMBER := 0;
    l_inspect_req_rej_count NUMBER := 0;
    l_cross_dock_flag   NUMBER;
    l_ret_crossdock  NUMBER := 1;
    l_ATF_error_code NUMBER;
    l_operation_plan_id NUMBER;
    l_mmtt_record_count NUMBER;
    l_pregen_putaway_tasks_flag NUMBER;
    l_txn_source_id NUMBER;
    l_insp_status   NUMBER; --Added for Bug 8373292
    label_mmtt_record_count NUMBER;
    record_locked  EXCEPTION;
    PRAGMA EXCEPTION_INIT (record_locked, -54);

    -- End variables added in ATF_J

    --Cursors
    /*
    ATF_J:
    comment out following definition since its not referred in the code

    CURSOR mol_cursor IS
    SELECT mol.line_id, mol.line_number
    FROM mtl_txn_request_headers moh,
	 mtl_txn_request_lines   mol
    WHERE mol.header_id	        = moh.header_id
    AND   moh.move_order_type   = INV_GLOBALS.g_move_order_put_away
    AND   mol.organization_id   = p_organization_id
    AND   mol.lpn_id is not null
    AND   mol.lpn_id            = NVL(p_lpn_id, mol.lpn_id)
    AND  (NVL(mol.quantity_delivered,0) + NVL(mol.quantity_detailed,0)) <
		NVL(mol.quantity,0)
    FOR UPDATE;
    */

     /* for bug 6918744 */
    CURSOR mol_lpn_cursor IS
         SELECT
	 distinct mol.lpn_id,
	 lpn.license_plate_number,
	 lpn.lpn_context,                          --- for bug 5175569
	   mol.line_id,
	   mol.txn_source_id                       --- for bug 7190056
	 FROM
	 mtl_txn_request_headers   moh,
         mtl_txn_request_lines     mol,
	 wms_license_plate_numbers lpn
	 WHERE mol.header_id          = moh.header_id
	 AND   moh.move_order_type    = INV_GLOBALS.g_move_order_put_away
	 AND   mol.organization_id    = p_organization_id
	 AND   mol.lpn_id is not null
	 AND   mol.lpn_id             = nvl(p_lpn_id, mol.lpn_id)  --BUG3497572 p_lpn_id is an optional argument for concurrent request
	 AND   mol.lpn_id             = lpn.lpn_id
	 AND  (NVL(mol.quantity_delivered,0) + NVL(mol.quantity_detailed,0)) <
	       NVL(mol.quantity,0)
	 ORDER BY mol.txn_source_id ASC;           --bug 6189438,6160359,6716184,7190056
       /* for bug 6918744 */



	 --ATF_J
	 -- select operation_plan_ID from MMTT
	 -- This makes this file depending on patchset I and above.
	 -- We need to at least break the dual maintanance between H and I,
	 -- but can keep the dual maintanance between I and J

    CURSOR mmtt_cursor (l_line_id IN NUMBER) IS
       SELECT
    nvl(mmtt.LPN_ID, mmtt.CONTENT_LPN_ID),
    mmtt.organization_id,   -- Added for bug # 4964866
    mmtt.subinventory_code, -- Added for bug # 4964866
    mmtt.locator_id,        -- Added for bug # 4964866
	 mmtt.transaction_temp_id,
	 mmtt.operation_plan_id,   -- added for ATF_J
	 mol.backorder_delivery_detail_id,   -- added for ATF_J
	 mol.crossdock_type   -- added for ATF_J
	 FROM
	 mtl_material_transactions_temp mmtt,
	 mtl_txn_request_lines mol
	 WHERE mmtt.move_order_line_id = l_line_id
	 AND mol.line_id = l_line_id;


    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF (l_debug = 1) THEN
       print_debug('pre_generate: Starting pre_generate API');
       print_debug('p_from_conc_pgm => ' || p_from_conc_pgm);
       print_debug('p_commit => ' || p_commit);
       print_debug('p_organization_id => '|| p_organization_id);
       print_debug('p_lpn_id => '||p_lpn_id);
       print_debug('p_is_srs_call => '||p_is_srs_call);
    END IF;



    IF (p_organization_id is null) THEN
       fnd_message.set_name('INV', 'INV_ORG_REQUIRED');
       fnd_msg_pub.add;
       IF (l_debug = 1) THEN
	  print_debug('pre_generate: p_organization_ID is null');
       END IF;

       RAISE fnd_api.g_exc_error;
    END IF;

    --This savepoint is used to rollback if p_commit = 'N' and an error
    --ocurrs.
    SAVEPOINT suggestions_start_sp;

    -- ATF_J:
    -- Following validation is added along with ATF project in patchset J. But it
    -- is general validation that should be performed for every patchset. It does
    -- not pertain to ATF functionality.


    -- 1. Do not pre-generate if LPN context is not WIP or Receiving
    -- 2. Do not pre-generate if LPN is locked (either by a different pre-generate process, or putaway load page).
    IF p_lpn_id IS NOT NULL THEN   --BUG3497572 p_lpn_id is an optional when pre_generate called from concurrent request
       BEGIN
	  SELECT lpn_context
	    INTO l_lpn_context
	    FROM wms_license_plate_numbers
	    WHERE lpn_id = p_lpn_id
	    AND organization_id = p_organization_id
	    FOR UPDATE nowait;

       EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	     fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LPN');
	     fnd_msg_pub.add;

	     IF (l_debug = 1) THEN
		print_debug('pre_generate: p_lpn_id '||p_lpn_id||' does not exist. ' );
	     END IF;

	     RAISE fnd_api.g_exc_error;

	  WHEN record_locked THEN
	     fnd_message.set_name('WMS', 'WMS_LPN_UNAVAIL');
	     fnd_msg_pub.ADD;

	     IF (l_debug = 1) THEN
		print_debug('pre_generate: LPN not available. It is locked by someone else, either by different pre-generate process, or putaway load page');
	     END IF;

	     RAISE fnd_api.g_exc_error;

       END;

       IF (l_debug = 1) THEN
	  print_debug('pre_generate: l_lpn_context = '||l_lpn_context);
       END IF;

       IF l_lpn_context NOT IN (2, 3) THEN
      	  fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LPN_CONTEXT');
	  fnd_msg_pub.add;

	  IF (l_debug = 1) THEN
	     print_debug('pre_generate: l_lpn_context is not WIP or Receiving, do not pre-generate.' );
	  END IF;

	  RAISE fnd_api.g_exc_error;
       END IF;

       -- Do not pre-generate if any move order line in this LPN with wms_process_flag = 2


       BEGIN
	  SELECT 1
	    INTO l_process_flag_count
	    FROM DUAL WHERE  exists
	    (SELECT 1
	     FROM mtl_txn_request_lines
	     WHERE lpn_id = p_lpn_id
	     AND line_status <> inv_globals.g_to_status_closed /* 3867448 */
	     AND Nvl(wms_process_flag, 1) = 2);
       EXCEPTION
	  WHEN no_data_found THEN
	     l_process_flag_count := 0;

       END ;

       IF l_process_flag_count > 0 THEN
       	  fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LPN');
	  fnd_msg_pub.add;

	  IF (l_debug = 1) THEN
	     print_debug('pre_generate: move order wms_process_flag indicates allocation is not yet allowed.');
	  END IF;

	  RAISE fnd_api.g_exc_error;
       END IF;

       -- End of validation added in ATF_J
    END IF;  --BUG3497572 p_lpn_id is an optional when pre_generate called from concurrent request


    IF (l_debug = 1) THEN
       print_debug('Before calling WMS_Cross_Dock_Pvt.crossdock');
       print_debug('p_organization_id = '||p_organization_id);
       print_debug('p_lpn_id = '||p_lpn_id);
       print_debug('p_move_order_line_id = '||l_mol_line_id);
    END IF;

    --{{
    -- Test cases related to pre_generate
    -- 1. pre_generate should always be called after receipt, but not necessarily generate task.
    -- 2. If check crossdock indicates crossdock occurs, or org level pregeneration flag
    --    is set, or the call is from SRS, then need to pregenerate task.
    -- 3. In otherwords, if no crossdock occurs, and call is from PL/SQL api, and org level
    --    pregenerate flag is off, do not pregenerate task.
    --}}

    WMS_Cross_Dock_Pvt.crossdock
      (p_org_id         => p_organization_id,
       p_lpn            => p_lpn_id,
       p_move_order_line_id => l_mol_line_id,
       x_ret            => l_ret_crossdock,
       x_return_status  => l_return_status,
       x_msg_count      => l_msg_count,
       x_msg_data       => l_msg_data);

    IF (l_debug = 1) THEN
       print_debug('After calling WMS_Cross_Dock_Pvt.crossdock');
       print_debug('l_ret_crossdock = '||l_ret_crossdock);
       print_debug('l_return_status = '||l_return_status);
       print_debug('l_msg_count = '||l_msg_count);
       print_debug('l_msg_data = '||l_msg_data);
    END IF;

    IF (l_return_status = fnd_api.g_ret_sts_success) THEN
       IF (l_debug = 1) THEN
	  print_debug('pre_generate: Success returned from WMS_Cross_Dock_Pvt.crossdock API');
       END IF;
     ELSE
       IF (l_debug = 1) THEN
	  print_debug('pre_generate: Failure returned from WMS_Cross_Dock_Pvt.crossdock API');
       END IF;
       RAISE fnd_api.g_exc_error;

    END IF; -- (l_return_status = fnd_api.g_ret_sts_success)

    IF l_ret_crossdock <> 0  THEN
       IF (l_debug = 1) THEN
	  print_debug('pre_generate:Crossdock did not happen, get org level flag');
       END IF;

       SELECT pregen_putaway_tasks_flag
	 INTO l_pregen_putaway_tasks_flag
	 FROM mtl_parameters
	 WHERE organization_id = p_organization_id;

       IF (l_debug = 1) THEN
	  print_debug('l_pregen_putaway_tasks_flag = '||l_pregen_putaway_tasks_flag);
       END IF;

       IF l_pregen_putaway_tasks_flag <> 1 AND Nvl(p_is_srs_call, 'Y') = 'N' THEN
	  IF (l_debug = 1) THEN
	     print_debug('Return and do not pregenerate since not called from SRS, AND org level flag not set, AND no crossdock.');
	  END IF;
	  RETURN;
       END IF;
    END IF; -- (l_ret_crossdock=1)



    --Each line of all the pending lpns are processed int the foll. logic.
    --If a line of one of the lpns errors out then the entire lpn is not
    --processed. A savepoint is defined at the start of each lpn. Commit
    --is made after every lpn is processed.
    OPEN mol_lpn_cursor;
    label_mmtt_record_count := 0;
    LOOP
       FETCH mol_lpn_cursor
	 INTO
	 l_lpn_id,
	 l_lpn_no,
	 l_lpn_context,   -- for bug 5175569
	 l_mol_line_id,
	 l_txn_source_id; -- for bug 7190056
       EXIT WHEN mol_lpn_cursor%notfound;

       IF (l_debug = 1) THEN
          print_debug('l_lpn_id: ' || l_lpn_id);
       END IF;

       SAVEPOINT suggestions_lpn_sp;
       l_entry_loop := TRUE;

       l_error := FALSE;

       IF (l_debug = 1) THEN
          print_debug('l_mol_line_id: ' || l_mol_line_id);
       END IF;


       --Calling Rules Engine.
       INV_PPEngine_PVT.create_suggestions
	 (p_api_version         => 1.0,
	  p_init_msg_list       => FND_API.G_TRUE,
	  p_commit              => FND_API.G_FALSE,
	  p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
	  x_return_status       => l_return_status,
	  x_msg_count           => l_msg_count,
	  x_msg_data            => l_msg_data,
	  p_transaction_temp_id => l_mol_line_id,
	  p_reservations        => l_mtl_reservation,
	  p_suggest_serial      => 'N'
	  );

       IF (l_debug = 1) THEN
	  print_debug('l_return_status => ' || l_return_status);
       END IF;

       -- if rules engine fails to create suggestion, the idea is to rollback all changes to
       -- the MOL that might have been set by crossdock. However,
       -- l_return_status is always success even though the rules engine cannot create suggestion
       -- thus, this if statement will never be true until the rules engine is fixed
       -- for now, a work around is to check the mmtt cursor record count. if it is 0, then
       -- we raise the fnd_api.g_exc_error
       IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
	  l_error := TRUE;
	  l_partial_success := 'Y';

	  --Log Errored lpn_id and line_id with the error msg in msg file.
	  fnd_message.set_name('WMS', 'WMS_LPN_LINE_ERROR');
	  fnd_message.set_token('lpn_no', l_lpn_no);
	  fnd_message.set_token('lpn_id', to_char(l_lpn_id));
	  --fnd_message.set_token('line_no',to_char(l_mol_line_no));
	  fnd_message.set_token('line_id',to_char(l_mol_line_id));
	  fnd_msg_pub.add;
	  x_lpn_line_error_tbl(l_tbl_index).lpn_id := l_lpn_id;
	  x_lpn_line_error_tbl(l_tbl_index).line_id := l_mol_line_id;
	  l_tbl_index := l_tbl_index+1;

	  IF (l_from_conc_pgm = 'Y') THEN
	     print_message();
	  END IF;
	  RAISE fnd_api.g_exc_error;

	ELSE

	  -- Log Success in msg file.
	  fnd_message.set_name('WMS', 'WMS_PUTAWAY_SUCCESS');
	  fnd_message.set_token('lpn_no', l_lpn_no);
	  fnd_message.set_token('lpn_id', to_char(l_lpn_id));
	  --fnd_message.set_token('line_no',to_char(l_mol_line_no));
	  fnd_message.set_token('line_id',to_char(l_mol_line_id));
	  fnd_msg_pub.add;

	  IF (l_from_conc_pgm = 'Y') THEN
	     print_message();
	  END IF;

       END IF;

        UPDATE mtl_txn_request_lines
	 SET
	 last_update_date = Sysdate,
	 quantity_detailed = (SELECT SUM(transaction_quantity)
			      FROM mtl_material_transactions_temp
			      WHERE move_order_line_id = l_mol_line_id),
         secondary_quantity_detailed = (SELECT SUM(secondary_transaction_quantity)  --bug 8217008
 	                               FROM mtl_material_transactions_temp
                               WHERE move_order_line_id = l_mol_line_id)
	 WHERE line_id = l_mol_line_id;

       -- a workaround to problem described above (rules engine always return success status)
       l_mmtt_record_count := 0;

       OPEN mmtt_cursor(l_mol_line_id);
       LOOP
	  FETCH mmtt_cursor INTO
       l_temp_lpn_id,
       l_organization_id,   -- Added for bug # 4964866
       l_subinventory_code, -- Added for bug # 4964866
       l_locator_id,        -- Added for bug # 4964866
	    l_temp_id,
	    l_operation_plan_id,
	    l_backorder_delivery_detail_id,
	    l_crossdock_type;
	  EXIT WHEN
	    mmtt_cursor%notfound;

	  l_mmtt_record_count := l_mmtt_record_count + 1; --bug8775458

     l_print_lpn_label := 'Y';

     FOR i IN 1..l_mmtt_table.count() LOOP
        -- the following IF condition has been modified for the bug # 4964866
        IF (l_mmtt_table(i).lpn_id = l_temp_lpn_id
       AND l_mmtt_table(i).organization_id = l_organization_id
       AND l_mmtt_table(i).subinventory_code = l_subinventory_code
       AND l_mmtt_table(i).locator_id = l_locator_id)
       AND l_backorder_delivery_detail_id IS NOT NULL AND l_mmtt_table(i).backorder_delivery_detail_id=l_backorder_delivery_detail_id THEN
           l_print_lpn_label := 'N';
           EXIT;
        END IF;
     END LOOP;

      /*Bug 8373292  If Inspection is done only then print label*/
     SELECT inspection_status
     INTO l_insp_status
     FROM mtl_txn_request_lines mtrl, mtl_material_transactions_temp mmtt
     WHERE mtrl.line_id=mmtt.move_order_line_id
     AND mmtt.transaction_temp_id=l_temp_id;

     IF (l_debug = 1) THEN
        print_debug('pre_generate: l_insp_status='||l_insp_status);
	   END IF;

     IF (Nvl(l_insp_status, 2) = 1) THEN
        l_print_lpn_label := 'N';

        IF (l_debug = 1) THEN
          print_debug('pre_generate: Do not print label for receive transaction if inspection is required');
        END IF;
     END IF;
     /*Bug 8373292  If Inspection is done only then print label*/


     IF(l_print_lpn_label = 'Y') THEN
            inv_label.print_label_wrap(x_return_status        => l_return_status
              , x_msg_count          => l_msg_count
              , x_msg_data           => l_msg_data
              , x_label_status       => l_label_status
              , p_business_flow_code => 27
              , p_transaction_id     => l_temp_id);

      /* Start of fix for bug # 4964866*/
      --l_lpn_table(l_mmtt_record_count) := l_temp_lpn_id;

      label_mmtt_record_count := label_mmtt_record_count + 1;
      l_mmtt_table(label_mmtt_record_count).lpn_id := l_temp_lpn_id;
      l_mmtt_table(label_mmtt_record_count).organization_id := l_organization_id;
      l_mmtt_table(label_mmtt_record_count).subinventory_code := l_subinventory_code;
      l_mmtt_table(label_mmtt_record_count).locator_id := l_locator_id;
      l_mmtt_table(label_mmtt_record_count).backorder_delivery_detail_id := l_backorder_delivery_detail_id;

      /* End of fix for bug # 4964866*/

     END IF;

	  IF (l_return_status <> fnd_api.g_ret_sts_success) THEN

	     IF (l_debug = 1) THEN
		print_debug('pre_generate: Label printing failed. Continue');
	     END IF;
	  END IF;

	  -- ATF_J:
	  -- Following two apis,
	  -- operation_plan_assignment and init_op_plan_instance,
	  -- are only called if customer is at patchset J or above.
	  -- Also, only need to call these APIs if current MMTT does not yet have
	  -- operation_plan_id stamped.


	  IF (l_debug = 1) THEN
	     print_debug('pre_generate: crdk_wip_info_table.count = '||wms_task_dispatch_put_away.crdk_wip_info_table.count );
	  END IF;

	  IF (l_debug = 1) THEN
	     print_debug('pre_generate: Current release is above J.');
	  END IF;


	  IF l_operation_plan_id IS NULL
	    AND l_lpn_context = 3 THEN  -- LPN context resides in receiving
	     IF (l_debug = 1) THEN
		print_debug(' operation_plan_id is null on MMTT and this is a receiving LPN, assign operation plan and initialize operation plan instance.');

		--Following API assigns operation plan to an MMTT
		print_debug('pre_generate: Before calling wms_rule_pvt.assign_operation_plan with following parameters: ');
		print_debug('p_task_id = ' || l_temp_id);
		print_debug('p_activity_type_id = ' || 1);
		print_debug('p_organization_id = ' || p_organization_id);
	     END IF;
	     WMS_ATF_Util_APIs.assign_operation_plan
	       (
		p_api_version        => 1.0,
		x_return_status      => l_return_status,
		x_msg_count          => l_msg_count,
		x_msg_data           => l_msg_data,
		p_task_id            => l_temp_id,
		p_activity_type_id   => 1, -- Inbound
		p_organization_id    => p_organization_id
		);

	     IF (l_debug = 1) THEN
		print_debug('pre_generate: After calling wms_rule_pvt.assign_operation_plan');
		print_debug('l_return_status = ' || l_return_status);
	     END IF;

	     IF (l_return_status <> fnd_api.g_ret_sts_success) THEN

		IF (l_debug = 1) THEN
		   print_debug('pre_generate: wms_rule_pvt.assign_operation_plan failed.');
		END IF;

		RAISE fnd_api.g_exc_error;

	     END IF;  -- (l_return_status <> fnd_api.g_ret_sts_success)

	     IF (l_debug = 1) THEN
		--Following API initializes the operation plan instance
		print_debug('pre_generate: Before calling wms_op_runtime_pub_apis.init_op_plan_instance with following parameters: ');
		print_debug('p_source_task_id = ' || l_temp_id);
		print_debug('p_activity_id = ' || 1);
	     END IF;


	     wms_atf_runtime_pub_apis.init_op_plan_instance
	       (
		x_return_status  => l_return_status,
		x_msg_data       => l_msg_data,
		x_msg_count      => l_msg_count,
		x_error_code     => l_ATF_error_code,
		p_source_task_id => l_temp_id,
		p_activity_id    => 1 -- Inbound
		);

	     IF (l_debug = 1) THEN
		print_debug('pre_generate: After calling wms_op_runtime_pub_apis.init_plan_instance');
		print_debug('l_return_status = ' || l_return_status);
	     END IF;

	     IF (l_return_status <> fnd_api.g_ret_sts_success) THEN

		IF (l_debug = 1) THEN
		   print_debug('pre_generate: wms_op_runtime_pub_apis.init_plan_instance failed.');
		END IF;

		RAISE fnd_api.g_exc_error;

	     END IF;  -- (l_return_status <> fnd_api.g_ret_sts_success)

	  END IF; -- (l_operation_plan_id IS NULL)

	  -- End new API calls added for ATF_J

       END LOOP;
       CLOSE mmtt_cursor;


       IF (l_debug = 1) THEN
	  print_debug('l_mmtt_record_count = ' || l_mmtt_record_count);
       END IF;

       -- workaround to rules engine problem (always returning success status)
       IF (l_mmtt_record_count = 0) THEN
	  l_error := TRUE;
       END IF;

       IF (l_error) THEN
	  ROLLBACK TO SAVEPOINT suggestions_lpn_sp;
	  --Counts the no. of lpns that failed to process.
	  l_cnt_failed := l_cnt_failed + 1;
	ELSE
	  IF (p_commit = 'Y' and p_lpn_id IS NULL) THEN  -- 7460112
	  		     COMMIT;
          END IF;
          -- Counts the no. of lpns processed successfully.
	  l_cnt_success := l_cnt_success + 1;
       END IF;

    END LOOP;
    CLOSE mol_lpn_cursor;

    -- start of fix for -- 7460112


 	 IF p_lpn_id IS NOT NULL THEN

 	        BEGIN
 	         SELECT /*+ ORDERED INDEX(MTRL MTL_TXN_REQUEST_LINES_N7) */ 1
 	           INTO l_discrepancy
 	           FROM mtl_txn_request_lines mtrl,
 	           (SELECT wlpn.lpn_id
 	                 FROM wms_license_plate_numbers wlpn
 	                 START WITH  wlpn.lpn_id = p_lpn_id
 	                 CONNECT BY PRIOR wlpn.lpn_id = wlpn.parent_lpn_id) wlpn
 	           WHERE mtrl.lpn_id = wlpn.lpn_id
 	           AND mtrl.line_status = 7
 	           AND (mtrl.quantity-Nvl(mtrl.quantity_delivered,0)) <> Nvl(mtrl.quantity_detailed,0)
 	           AND mtrl.organization_id = p_organization_id;
 	      EXCEPTION
 	         WHEN too_many_rows THEN
 	            l_discrepancy := 1;
 	         WHEN no_data_found THEN
 	            l_discrepancy := 0;
 	         WHEN OTHERS THEN
 	            l_discrepancy := 0;
 	      END;

 	      IF (l_debug = 1) THEN
 	         print_debug('l_discrepancy = ' || l_discrepancy);
 	      END IF;

 	      IF l_discrepancy = 1 THEN

 	      print_debug(' Suggested locator capacity should be reverted as putaway fails');
 	      print_debug(' Before calling the revert_loc_suggested_capacity');
 	      wms_task_dispatch_put_away.revert_loc_suggested_capacity(
 	               x_return_status       => l_return_status
 	             , x_msg_count           => l_msg_count
 	             , x_msg_data            => l_msg_data
 	             , p_organization_id     => p_organization_id
 	             , p_lpn_id              => p_lpn_id
 	             );
 	       print_debug(' After calling the revert_loc_suggested_capacity');
 	        ROLLBACK;

 	         RAISE fnd_api.g_exc_error;
 	       else
 	         if (p_commit = 'Y') then
 	                 print_debug(' Before LPN Commit');
 	                 commit;
 	          end if;
 	      END IF;

 	       END IF;


 	 -- End of fix for bug 7460112



    fnd_message.set_name('WMS', 'WMS_COUNT_LPN_SUCCESS');
    fnd_message.set_token('CNT_SUCCESS', to_char(l_cnt_success));
    fnd_msg_pub.add;

    fnd_message.set_name('WMS', 'WMS_COUNT_LPN_FAILED');
    fnd_message.set_token('CNT_FAILED', to_char(l_cnt_failed));
    fnd_msg_pub.add;

    --If all the lpns have failed then we raise ERROR.
    IF (l_cnt_success = 0) AND (l_cnt_failed > 0) THEN
        RAISE fnd_api.g_exc_error;
    END IF;

    IF (l_from_conc_pgm = 'Y') THEN
        print_message();
    END IF;

    x_partial_success := l_partial_success;
    IF (l_debug = 1) THEN
       print_debug('pre_generate: End of pre_generate API');
    END IF;

EXCEPTION
   WHEN  fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_error;

         IF (l_from_conc_pgm = 'Y') THEN
   	     print_message();
         END IF;

	 IF (l_debug = 1) THEN
	    print_debug('pre_generate: fnd_api.g_exc_error');
	 END IF;

	 IF ((p_commit = 'N') OR (NOT(l_entry_loop))) THEN
 	    ROLLBACK TO SAVEPOINT suggestions_start_sp;
	  ELSE
 	    ROLLBACK TO SAVEPOINT suggestions_lpn_sp;
	 END IF;

	 IF mol_lpn_cursor%isopen THEN
	    CLOSE mol_lpn_cursor;
	 END IF;

	 IF mmtt_cursor%isopen THEN
	    CLOSE mmtt_cursor;
	 END IF;

   WHEN  fnd_api.g_exc_unexpected_error THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error ;

         IF (l_from_conc_pgm = 'Y') THEN
   	     print_message();
         END IF;

	 IF (l_debug = 1) THEN
	    print_debug('pre_generate: fnd_api.g_exc_unexpected_error');
	 END IF;

	 IF ((p_commit = 'N') OR (NOT(l_entry_loop))) THEN
 	    ROLLBACK TO SAVEPOINT suggestions_start_sp;
	  ELSE
 	    ROLLBACK TO SAVEPOINT suggestions_lpn_sp;
	 END IF;

	 IF mol_lpn_cursor%isopen THEN
	    CLOSE mol_lpn_cursor;
	 END IF;

	 IF mmtt_cursor%isopen THEN
	    CLOSE mmtt_cursor;
	 END IF;

   WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, 'PRE_GENERATE');
        END IF;

        IF (l_from_conc_pgm = 'Y') THEN
   	    print_message();
        END IF;

	IF (l_debug = 1) THEN
	   print_debug('pre_generate: other EXCEPTION');
	END IF;

        IF ((p_commit = 'N') OR (NOT(l_entry_loop))) THEN
 	    ROLLBACK TO SAVEPOINT suggestions_start_sp;
        ELSE
 	    ROLLBACK TO SAVEPOINT suggestions_lpn_sp;
	END IF;

	IF mol_lpn_cursor%isopen THEN
	   CLOSE mol_lpn_cursor;
	END IF;

	IF mmtt_cursor%isopen THEN
	   CLOSE mmtt_cursor;
	END IF;



END pre_generate;


PROCEDURE cleanup_suggestions
  (p_org_id                       IN  NUMBER,
   p_lpn_id                       IN  NUMBER,
   x_return_status                OUT NOCOPY VARCHAR2,
   x_msg_count                    OUT NOCOPY NUMBER,
   x_msg_data                     OUT NOCOPY VARCHAR2,
   p_move_order_line_id           IN  NUMBER DEFAULT NULL  -- added for ATF_J2
   )
  IS

    Cursor sugg_info is
    SELECT transaction_temp_id,
      locator_id,
      inventory_item_id,
      primary_quantity,
      operation_plan_id   -- added for ATF_J2
      FROM   mtl_material_transactions_temp
      WHERE  lpn_id =  p_lpn_id
      AND   move_order_line_id = Nvl(p_move_order_line_id, move_order_line_id) -- added for ATF_J2
      AND   organization_id = p_org_id;

    l_locator_id 		NUMBER;
    l_inventory_item_id   NUMBER;
    l_primary_quantity	NUMBER;

    -- Following variables added in ATF_J2

    l_ATF_error_code NUMBER;
    l_return_status	VARCHAR2(1);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);

    -- End variables added in ATF_J2

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

BEGIN

   IF (l_debug = 1) THEN
      print_debug('clean_up suggestions: Start of cleanup_suggestions API');
      print_debug('p_lpn_id = '|| p_lpn_id);
      print_debug('p_org_id = '|| p_org_id);
      print_debug('p_move_order_line_id = '|| p_move_order_line_id);
   END IF;

   SAVEPOINT sp_cleanup_suggs;

   BEGIN
      DELETE
	FROM mtl_transaction_lots_temp
	WHERE transaction_temp_id IN
	(SELECT transaction_temp_id
	 FROM mtl_material_transactions_temp
	 WHERE lpn_id = p_lpn_id
	 AND   move_order_line_id = Nvl(p_move_order_line_id, move_order_line_id) -- added for ATF_J2
	 AND   organization_id = p_org_id);

   EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
   END;

   FOR current_suggestion in sugg_info
   LOOP
  	 l_locator_id          := current_suggestion.locator_id;
      	 l_inventory_item_id   := current_suggestion.inventory_item_id;
      	 l_primary_quantity    := current_suggestion.primary_quantity;

	 IF (l_debug = 1) THEN
	    print_debug('clean_up suggestions: inside sugg_info cursor');
	    print_debug('clean_up suggestions: locator id =' || l_locator_id) ;
	    print_debug('clean_up suggestions: item='|| l_inventory_item_id);
	    print_debug('clean_up suggestions: primary qty='|| l_primary_quantity);
	    print_debug('clean_up suggestions: transaction_temp_id = ' || current_suggestion.transaction_temp_id);
	 END IF;

	 -- added following if statement for bug fix 3401817
	 -- Abort_Operation_Plan calls revert_loc_sugg_capacity_nauto
	 IF current_suggestion.operation_plan_id IS NULL THEN

	    inv_loc_wms_utils.revert_loc_suggested_capacity
	      (
	       x_return_status              => x_return_status
	       , x_msg_count                  => x_msg_count
	       , x_msg_data                   => x_msg_data
	       , p_organization_id            => p_org_id
	       , p_inventory_location_id      => l_locator_id
	       , p_inventory_item_id          => l_inventory_item_id
	       , p_primary_uom_flag           => 'Y'
	       , p_transaction_uom_code       => NULL
	       , p_quantity                   => l_primary_quantity
	       );
	    IF (l_debug = 1) THEN
	       print_debug('cleanup_suggestions: After calling inv_loc_wms_utils.revert_loc_suggested_capacity');
	       print_debug('  x_return_status = ' || x_return_status);
	    END IF;

	    IF x_return_status = fnd_api.g_ret_sts_error THEN
	       -- Bug 5393727: do not raise an exception if locator API returns an error
	       -- RAISE fnd_api.g_exc_error;
	       NULL;
	    END IF ;

	    IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
	       -- Bug 5393727: do not raise an exception if locator API returns an error
	       -- RAISE fnd_api.g_exc_unexpected_error;
	       NULL;
	    END IF;

	 END IF;


	-- ATF_J
	-- Need to call abort_operation_plan if J or above,
	-- which will abort and archive the operation plan and operation instances.
	-- Cancel_operation_plan also takes care of MMTT, MOL, etc.
	-- which is not appropriate being called here.

	IF current_suggestion.operation_plan_id IS NOT NULL THEN
	   IF (l_debug = 1) THEN
	      print_debug('cleanup_suggestions: Current release is above J, therefore need to call abort_operation_plan.');
	      print_debug('cleanup_suggestions: Before calling wms_op_runtime_pub_apis.Abort_Operation_Plan with following parameters: ');
	      print_debug('p_source_task_id = ' || current_suggestion.transaction_temp_id);
	      print_debug('p_activity_type_id = ' || 1);
	   END IF;

	   wms_atf_runtime_pub_apis.Abort_Operation_Plan
	     (
	      x_return_status  => l_return_status,
	      x_msg_data       => l_msg_data,
	      x_msg_count      => l_msg_count,
	      x_error_code     => l_ATF_error_code,
	      p_source_task_id => current_suggestion.transaction_temp_id,
	      p_activity_type_id    => 1, -- Inbound,
	      p_for_manual_drop  => TRUE -- added for bug fix 3866880
	      -- Pass TRUE in this argument so that abort_operation_plan
	      -- will call the revert_locator_capacity API with autonomous
	      -- commit. By doing this, we can decommission the cleanup_suggestions
	      -- api with autonomous commit, which is conflicting with
	      -- MMTT and MOL update from inbound UI for item load.

	      );

	   IF (l_debug = 1) THEN
	      print_debug('cleanup_suggestions: After calling wms_op_runtime_pub_apis.Abort_Operation_Plan');
	      print_debug('  l_return_status = ' || l_return_status);
	   END IF;

	   IF (l_return_status <> fnd_api.g_ret_sts_success) THEN

	      IF (l_debug = 1) THEN
		 print_debug('cleanup_suggestions: wms_op_runtime_pub_apis.Abort_Operation_Plan failed.');
	      END IF;

	      RAISE fnd_api.g_exc_error;

	   END IF;  -- (l_return_status <> fnd_api.g_ret_sts_success)


	END IF; --  current_suggestion.operation_plan_id IS NOT
	-- End ATF_J

   END LOOP;


   BEGIN
      DELETE
	FROM mtl_material_transactions_temp
	WHERE lpn_id = p_lpn_id
	AND   move_order_line_id = Nvl(p_move_order_line_id, move_order_line_id) -- added for ATF_J2
	AND   organization_id = p_org_id;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
   END;

   BEGIN
      UPDATE  mtl_txn_request_lines
	SET   quantity_detailed = Nvl(quantity_delivered, 0)
	WHERE lpn_id = p_lpn_id
	AND   line_id = Nvl(p_move_order_line_id, line_id) -- added for ATF_J2
	AND   organization_id = p_org_id;
-- Removed the backorder detail id from the where clause since the lines have TO clean up ALL lines FROM mmtt AND correspondingly UPDATE MTRL vipartha

   EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
   END;

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF (l_debug = 1) THEN
      print_debug('clean_up suggestions: End of cleanup_suggestions API');
   END IF;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
      ROLLBACK TO sp_cleanup_suggs;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
      ROLLBACK TO sp_cleanup_suggs;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
      ROLLBACK TO sp_cleanup_suggs;

END cleanup_suggestions;




/*===========================================================================+
 | Procedure:                                                                |
 |     print_message                                                         |
 |                                                                           |
 | Description:                                                              |
 |    Writes message text in log files.                                      |
 |                                                                           |
 | Input Parameters:                                                         |
 |       None                                                                |
 |                                                                           |
 | Output Parameters:                                                        |
 |        None                                                               |
 |                                                                           |
 | Tables Used:                                                              |
 |        None                                                               |
 +===========================================================================*/

PROCEDURE print_message(dummy IN VARCHAR2 DEFAULT NULL) IS

--Variables
   l_msg_count    NUMBER;
   l_msg_data     VARCHAR2(2000);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

       fnd_msg_pub.count_and_get(
         p_count   => l_msg_count,
         p_data    => l_msg_data,
         p_encoded => 'F'
         );

       FOR i IN 1..l_msg_count LOOP
           l_msg_data := fnd_msg_pub.get(i, 'F');
           fnd_file.put_line(fnd_file.log, l_msg_data);
       END LOOP;
       fnd_file.put_line(fnd_file.log, ' ');

       fnd_msg_pub.initialize;

EXCEPTION
   WHEN OTHERS THEN
        fnd_file.put_line(fnd_file.log, sqlerrm);

END print_message;

END wms_putaway_suggestions;

/
