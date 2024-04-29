--------------------------------------------------------
--  DDL for Package Body AR_DEFERRAL_REASONS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_DEFERRAL_REASONS_GRP" AS
/* $Header: ARXRDRB.pls 120.8.12010000.3 2009/04/08 12:59:39 dgaurab ship $ */


/*=======================================================================+
 |  Global Constants
 +=======================================================================*/

  g_pkg_name  CONSTANT VARCHAR2(30):= 'AR_DEFERREAL_REASONS_GRP';
  g_om_context  ra_interface_lines.interface_line_context%type :=
     NVL(fnd_profile.value('ONT_SOURCE_CODE'),'###NOT_SET###');

  pg_debug VARCHAR2(1) := nvl(fnd_profile.value('AFLOG_ENABLED'), 'N');

PROCEDURE default_reasons (
  p_api_version    IN  NUMBER,
  p_init_msg_list  IN  VARCHAR2 := fnd_api.g_false,
  p_commit         IN  VARCHAR2 := fnd_api.g_false,
  p_mode           IN  VARCHAR2 DEFAULT 'ALL',
  x_return_status  OUT NOCOPY  VARCHAR2,
  x_msg_count      OUT NOCOPY  NUMBER,
  x_msg_data       OUT NOCOPY  VARCHAR2) IS

  l_api_version  CONSTANT NUMBER := 1.0;
  l_api_name	 CONSTANT VARCHAR2(30)	:= 'default_reasons';

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT default_reasons_grp;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (
           p_current_version_number => l_api_version,
           p_caller_version_number  => p_api_version,
   	   p_api_name               => l_api_name,
           p_pkg_name 	    	    => g_pkg_name) THEN

    RAISE fnd_api.g_exc_unexpected_error;

  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    fnd_msg_pub.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  fun_rule_pub.apply_rule_bulk (
    p_application_short_name  => 'AR',
    p_rule_object_name        => ar_revenue_management_pvt.c_rule_object_name,
    p_param_view_name         => 'AR_RDR_PARAMETERS_GT',
    p_additional_where_clause => '1=1',
    p_primary_key_column_name => 'SOURCE_LINE_ID'
  );

EXCEPTION
  WHEN fnd_api.g_exc_error THEN
    ROLLBACK TO default_reasons_grp;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    fnd_msg_pub.count_and_get (
      p_encoded => fnd_api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data);

  WHEN fnd_api.g_exc_unexpected_error THEN
    ROLLBACK TO default_reasons_grp;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.count_and_get (
      p_encoded => fnd_api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data);

  WHEN OTHERS THEN
    ROLLBACK TO default_reasons_grp;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.count_and_get (
      p_encoded => fnd_api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data);

END default_reasons;


PROCEDURE record_acceptance (
  p_api_version    IN  NUMBER,
  p_init_msg_list  IN  VARCHAR2 := fnd_api.g_false,
  p_commit         IN  VARCHAR2 := fnd_api.g_false,
  p_order_line     IN  line_flex_rec,
  x_return_status  OUT NOCOPY  VARCHAR2,
  x_msg_count      OUT NOCOPY  NUMBER,
  x_msg_data       OUT NOCOPY  VARCHAR2) IS

  l_api_version   CONSTANT NUMBER := 1.0;
  l_api_name	  CONSTANT VARCHAR2(30)	:= 'record_acceptance';

  l_scenario            NUMBER;
  l_first_adj_num       NUMBER;
  l_last_adj_num        NUMBER;
  l_ram_desc_flexfield  ar_revenue_management_pvt.desc_flexfield;
  l_line_count          NUMBER;
  l_acctd_adjustable_amount    NUMBER;
  l_adjustable_amount          NUMBER;
  l_rows                NUMBER;
  l_target_in_ar        BOOLEAN := FALSE;
  l_first_row           BOOLEAN := TRUE;
  l_sum_dist            NUMBER;

  CURSOR parent_lines IS
    SELECT customer_trx_line_id, customer_trx_id,
           NVL(autorule_complete_flag,'Y') autorule_complete_flag
    FROM   ra_customer_trx_lines
    WHERE  interface_line_context    = p_order_line.interface_line_context
    AND    interface_line_attribute1 = p_order_line.interface_line_attribute1
    AND    interface_line_attribute2 = p_order_line.interface_line_attribute2
    AND    interface_line_attribute3 = p_order_line.interface_line_attribute3
    AND    interface_line_attribute4 = p_order_line.interface_line_attribute4
    AND    interface_line_attribute5 = p_order_line.interface_line_attribute5
    AND    interface_line_attribute6 = p_order_line.interface_line_attribute6;

  CURSOR child_lines(parent_trx_line_id NUMBER) IS
    SELECT child.customer_trx_line_id,
           child.customer_trx_id,
           NVL(cline.autorule_complete_flag,'Y') autorule_complete_flag
    FROM   ra_customer_trx_lines pline,
           ar_deferred_lines     child,
           ra_customer_trx_lines cline
    WHERE  pline.customer_trx_line_id = parent_trx_line_id
    AND    pline.interface_line_context = g_om_context
    AND    child.parent_line_id = to_number(pline.interface_line_attribute6)
    AND    child.customer_trx_id = cline.customer_trx_id
    AND    child.customer_trx_line_id = cline.customer_trx_line_id;

BEGIN
  IF pg_debug IN ('Y','C')
  THEN
     arp_debug.debug('ar_deferral_reasons_grp.record_acceptance()+');
     arp_debug.debug('  acceptance_date = ' || p_order_line.acceptance_date);
  END IF;

  -- Standard Start of API savepoint
  SAVEPOINT record_acceptance_grp;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (
           p_current_version_number => l_api_version,
           p_caller_version_number  => p_api_version,
   	   p_api_name               => l_api_name,
           p_pkg_name 	    	    => g_pkg_name) THEN

    RAISE fnd_api.g_exc_unexpected_error;

  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    fnd_msg_pub.initialize;
  END IF;

  /* 5283886 - initialize ar_raapi_util */
  ar_raapi_util.constant_system_values;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /* Parent or target lines */
  FOR p_line_rec IN parent_lines LOOP
    IF pg_debug IN ('Y','C')
    THEN
       arp_debug.debug('accepting parent line : ' || p_line_rec.customer_trx_line_id);
       arp_debug.debug('   so_line_id : ' ||
                p_order_line.interface_line_attribute6);
    END IF;

    /* 8362201 - Check if rev rec has been run.  If not,
       run it for this transaction */
    IF l_first_row
    THEN
       l_first_row := FALSE;

       IF p_line_rec.autorule_complete_flag = 'N'
       THEN
          l_sum_dist := arp_auto_rule.create_distributions(
                             p_commit => 'N',
                             p_debug  => 'N',
                             p_trx_id => p_line_rec.customer_trx_id);

          IF pg_debug IN ('Y','C')
          THEN
             arp_debug.debug('Rev rec created ' || l_sum_dist ||
                             ' distributions for child trx_id ' ||
                             p_line_rec.customer_trx_id);
          END IF;

       END IF;
    END IF;

    /* 5501735 - found the target here, no need to sweep interface
        table for it at end of this routine */
    l_target_in_ar := TRUE;

    /* Removed fix for 5283886, zero adjustments are fine now */

    ar_revenue_management_pvt.process_event(
      p_cust_trx_line_id => p_line_rec.customer_trx_line_id,
      p_event_date       => TRUNC(NVL(p_order_line.acceptance_date,
                                sysdate)),
      p_event_code       => 'CUSTOMER_ACCEPTANCE');

    /* 5279702 - process child lines as well */

    FOR c_line_rec IN child_lines(p_line_rec.customer_trx_line_id) LOOP
       IF pg_debug IN ('Y','C')
       THEN
          arp_debug.debug('accepting child line : ' ||
               c_line_rec.customer_trx_line_id);
       END IF;

       /* 8362201 - run autoaccounting if needed */
       IF c_line_rec.autorule_complete_flag = 'N'
       THEN
          l_sum_dist := arp_auto_rule.create_distributions(
                             p_commit => 'N',
                             p_debug  => 'N',
                             p_trx_id => c_line_rec.customer_trx_id);

          IF pg_debug IN ('Y','C')
          THEN
             arp_debug.debug('Rev rec created ' || l_sum_dist ||
                             ' distributions for child trx_id ' ||
                             c_line_rec.customer_trx_id);
          END IF;
       END IF;

       ar_revenue_management_pvt.process_event(
         p_cust_trx_line_id => c_line_rec.customer_trx_line_id,
         p_event_date       => TRUNC(NVL(p_order_line.acceptance_date,
                                         sysdate)),
         p_event_code       => 'CUSTOMER_ACCEPTANCE');

    END LOOP;

  END LOOP;

  /* 5501735 - Lines might be in interface tables */
  /* This updates parent or target lines */
  IF l_target_in_ar = FALSE
  THEN
     UPDATE AR_INTERFACE_CONTS ic
     SET    COMPLETED_FLAG = 'Y',
            EXPIRATION_DATE = TRUNC(NVL(p_order_line.acceptance_date,
                                        sysdate))
     WHERE  ic.interface_line_context = g_om_context
     AND    interface_line_context    = p_order_line.interface_line_context
     AND    interface_line_attribute1 = p_order_line.interface_line_attribute1
     AND    interface_line_attribute2 = p_order_line.interface_line_attribute2
     AND    interface_line_attribute3 = p_order_line.interface_line_attribute3
     AND    interface_line_attribute4 = p_order_line.interface_line_attribute4
     AND    interface_line_attribute5 = p_order_line.interface_line_attribute5
     AND    interface_line_attribute6 = p_order_line.interface_line_attribute6
     AND EXISTS (SELECT 'acceptance contingency'
                 FROM   ar_deferral_reasons dr
                 WHERE  dr.contingency_id = ic.contingency_id
                 AND    dr.revrec_event_code = 'CUSTOMER_ACCEPTANCE');

     IF pg_debug IN ('Y','C')
     THEN
        l_rows := SQL%ROWCOUNT;
        arp_debug.debug('  parent interface lines updated : ' || l_rows);
     END IF;
   END IF;

  /* This updates any child lines in interface table */
  UPDATE AR_INTERFACE_CONTS ic
  SET    COMPLETED_FLAG = 'Y',
         EXPIRATION_DATE = NVL(p_order_line.acceptance_date,
                              TRUNC(sysdate))
  WHERE  interface_line_context = g_om_context
  AND    nvl(completed_flag, 'N') = 'N'
  AND EXISTS (SELECT 'child exists'
              FROM   ra_interface_lines il
              WHERE  il.parent_line_id =
                to_number(p_order_line.interface_line_attribute6)
              AND    il.interface_line_context = ic.interface_line_context
              AND    il.interface_line_attribute1 = ic.interface_line_attribute1
              AND    il.interface_line_attribute2 = ic.interface_line_attribute2
              AND    il.interface_line_attribute3 = ic.interface_line_attribute3
              AND    il.interface_line_attribute4 = ic.interface_line_attribute4
              AND    il.interface_line_attribute5 = ic.interface_line_attribute5
              AND    il.interface_line_attribute6 = ic.interface_line_attribute6)
  AND EXISTS (SELECT 'acceptance contingency'
              FROM   ar_deferral_reasons dr
              WHERE  dr.contingency_id = ic.contingency_id
              AND    dr.revrec_event_code = 'CUSTOMER_ACCEPTANCE');

  IF pg_debug IN ('Y','C')
  THEN
     l_rows := SQL%ROWCOUNT;
     arp_debug.debug('  child interface lines updated : ' || l_rows);
     arp_debug.debug('ar_deferral_reasons_grp.record_acceptance()-');
  END IF;

EXCEPTION
  WHEN fnd_api.g_exc_error THEN
    arp_debug.debug('EXCEPTION:  fnd_api.g_exc_error');
    ROLLBACK TO record_acceptance_grp;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    fnd_msg_pub.count_and_get (
      p_encoded => fnd_api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data);

  WHEN fnd_api.g_exc_unexpected_error THEN
    arp_debug.debug('EXCEPTION:  fnd_api.g_exc_unexpected_error');
    ROLLBACK TO record_acceptance_grp;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.count_and_get (
      p_encoded => fnd_api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data);

  WHEN OTHERS THEN
    arp_debug.debug('EXCEPTION:  Others');
    ROLLBACK TO record_acceptance_grp;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.count_and_get (
      p_encoded => fnd_api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data);

END record_acceptance;


PROCEDURE record_proof_of_delivery (
  p_api_version    IN  NUMBER,
  p_init_msg_list  IN  VARCHAR2 := fnd_api.g_false,
  p_commit         IN  VARCHAR2 := fnd_api.g_false,
  p_delivery_id    IN  NUMBER,
  p_pod_date       IN  DATE,
  x_return_status  OUT NOCOPY  VARCHAR2,
  x_msg_count      OUT NOCOPY  NUMBER,
  x_msg_data       OUT NOCOPY  VARCHAR2) IS

  l_api_version         CONSTANT NUMBER := 1.0;
  l_api_name	        CONSTANT VARCHAR2(30) := 'record_proof_of_delivery';

  l_sales_order_line_id NUMBER;
  l_delivery_id         NUMBER;
  l_pod_date            DATE;
  l_order_line          line_flex_rec;

  CURSOR so_line_id (p_delivery_id NUMBER) IS
    SELECT wdd.source_line_id order_line_id
    FROM   wsh_delivery_details wdd,
           wsh_delivery_assignments wda
    WHERE  wdd.delivery_detail_id = wda.delivery_detail_id
    AND    wda.delivery_id = p_delivery_id;

  CURSOR lines (p_order_line line_flex_rec) IS
    SELECT customer_trx_line_id, customer_trx_id
    FROM   ra_customer_trx_lines
    WHERE  interface_line_context    = p_order_line.interface_line_context
    AND    interface_line_attribute1 = p_order_line.interface_line_attribute1
    AND    interface_line_attribute1 = p_order_line.interface_line_attribute2
    AND    interface_line_attribute1 = p_order_line.interface_line_attribute3
    AND    interface_line_attribute1 = p_order_line.interface_line_attribute4
    AND    interface_line_attribute1 = p_order_line.interface_line_attribute5
    AND    interface_line_attribute1 = p_order_line.interface_line_attribute6;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT record_proof_of_delivery_grp;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (
           p_current_version_number => l_api_version,
           p_caller_version_number  => p_api_version,
   	   p_api_name               => l_api_name,
           p_pkg_name 	    	    => g_pkg_name) THEN

    RAISE fnd_api.g_exc_unexpected_error;

  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    fnd_msg_pub.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- event name: oracle.apps.fte.delivery.pod.podreceived
  -- l_delivery_id := p_event.GetValueForParameter('DELIVERY_ID');
  -- l_pod_date    := p_event.GetValueForParameter('POD_DATE');

  FOR so_line_rec IN so_line_id(p_delivery_id) LOOP

    -- call OM API to get the first 6 interface attributes
    -- and loop through them

    /* 5501735 - added this call as it was missing in
       POD routines */
    OE_AR_Acceptance_GRP.Get_interface_attributes
                (    p_line_id      =>  so_line_rec.order_line_id
                ,    x_line_flex_rec => l_order_line
                ,    x_return_status => x_return_status
                ,    x_msg_count     => x_msg_count
                ,    x_msg_data      => x_msg_data
                );

     IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
     THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    -- for each invoice line call ar_revenue_managemet_id with
    -- invoice line id andpod date

    FOR line_rec IN lines(l_order_line) LOOP

      ar_revenue_management_pvt.process_event(
        p_cust_trx_line_id => line_rec.customer_trx_line_id,
        p_event_date       => p_pod_date,
        p_event_code       => 'PROOF_OF_DELIVERY');

    END LOOP;

  END LOOP;

EXCEPTION
  WHEN fnd_api.g_exc_error THEN
    ROLLBACK TO record_proof_of_delivery_grp;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    fnd_msg_pub.count_and_get (
      p_encoded => fnd_api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data);

  WHEN fnd_api.g_exc_unexpected_error THEN
    ROLLBACK TO record_proof_of_delivery_grp;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.count_and_get (
      p_encoded => fnd_api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data);

  WHEN OTHERS THEN
    ROLLBACK TO record_proof_of_delivery_grp;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.count_and_get (
      p_encoded => fnd_api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data);

END record_proof_of_delivery;

END ar_deferral_reasons_grp;

/
