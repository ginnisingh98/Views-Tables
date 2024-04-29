--------------------------------------------------------
--  DDL for Package Body ARP_ACCT_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_ACCT_EVENT_PKG" AS
/* $Header: ARXLUTB.pls 120.11 2008/02/07 10:03:20 arnkumar ship $ */

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

--{Local routines
PROCEDURE log(
  message       IN VARCHAR2,
  newline       IN BOOLEAN DEFAULT TRUE) IS
BEGIN
 IF message = 'NEWLINE' THEN
    FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
  ELSIF (newline) THEN
    FND_FILE.put_line(fnd_file.log,message);
  ELSE
    FND_FILE.put(fnd_file.log,message);
  END IF;
  IF  PG_DEBUG = 'Y' THEN
     ARP_STANDARD.DEBUG(message);
  END IF;
END log;

PROCEDURE out(
  message      IN      VARCHAR2,
  newline      IN      BOOLEAN DEFAULT TRUE) IS
BEGIN
  IF message = 'NEWLINE' THEN
   FND_FILE.NEW_LINE(FND_FILE.output, 1);
  ELSIF (newline) THEN
    FND_FILE.put_line(fnd_file.output,message);
  ELSE
    FND_FILE.put(fnd_file.output,message);
  END IF;
END out;

PROCEDURE outandlog(
  message      IN      VARCHAR2,
  newline      IN      BOOLEAN DEFAULT TRUE) IS
BEGIN
  out(message, newline);
  log(message, newline);
END outandlog;


PROCEDURE validate_parameter
(p_start_date       IN DATE,
 p_end_date         IN DATE,
 p_org_id           IN NUMBER DEFAULT NULL,
 p_type             IN VARCHAR2,
 p_entity           IN VARCHAR2,
 x_return_status    IN OUT NOCOPY VARCHAR2)
IS
 CURSOR c_ou(p_org_id  NUMBER) IS
 SELECT org_id
   FROM ar_system_parameters_all
  WHERE org_id  = p_org_id;
 l_org_id     NUMBER;
BEGIN
  IF p_start_date IS NULL THEN
     FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
     FND_MESSAGE.SET_TOKEN( 'COLUMN', 'p_start_date' );
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF p_end_date IS NULL THEN
     FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
     FND_MESSAGE.SET_TOKEN( 'COLUMN', 'p_end_date' );
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    IF p_start_date < p_end_date THEN
      arp_standard.debug('  end date should be greater than the start date');
      fnd_message.set_name('AR', 'HZ_API_DATE_GREATER');
      fnd_message.set_token('DATE2', p_end_date);
      fnd_message.set_token('DATE1', p_start_date);
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
    END IF;
  END IF;

  IF p_org_id IS NOT NULL THEN
    OPEN c_ou(p_org_id);
    FETCH c_ou INTO l_org_id;
    IF c_ou%NOTFOUND THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_FK');
      FND_MESSAGE.SET_TOKEN('FK', 'org id');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'org_id');
      FND_MESSAGE.SET_TOKEN('TABLE', 'ar_system_parameters_all');
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    CLOSE c_ou;
  END IF;

  IF p_entity = 'RA_CUST_TRX_LINE_GL_DIST_ALL' THEN
    IF p_type NOT IN ('INV', 'CM', 'CB', 'DM', 'DEP', 'GUAR', 'ALL','INVDEPGUAR') THEN
      FND_MESSAGE.SET_NAME( 'AR', 'AR_ONLY_VALUE_ALLOWED' );
      FND_MESSAGE.SET_TOKEN( 'COLUMN', 'trx_type' );
      FND_MESSAGE.SET_TOKEN( 'VALUES', 'INV,CM,CB,DM,DEP,GUAR,ALL,INVDEPGUAR');
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  ELSIF p_entity = 'AR_CASH_RECEIPT_HISTORY_ALL' THEN
    IF p_type NOT IN ('CASH', 'MISC', 'ALL') THEN
      FND_MESSAGE.SET_NAME( 'AR', 'AR_ONLY_VALUE_ALLOWED' );
      FND_MESSAGE.SET_TOKEN( 'COLUMN', 'trx_type' );
      FND_MESSAGE.SET_TOKEN( 'VALUES', 'CASH,MISC,ALL');
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  ELSIF p_entity = 'AR_RECEIVABLE_APPLICATIONS_ALL' THEN
    IF p_type NOT IN ('APP', 'CMAPP', 'ALL') THEN
      FND_MESSAGE.SET_NAME( 'AR', 'AR_ONLY_VALUE_ALLOWED' );
      FND_MESSAGE.SET_TOKEN( 'COLUMN', 'trx_type' );
      FND_MESSAGE.SET_TOKEN( 'VALUES', 'APP,CMAPP,ALL');
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END IF;

END;
--}


PROCEDURE update_dates_for_trx_event
(p_source_id_int_1    IN NUMBER,
 p_trx_number         IN VARCHAR2,
 p_legal_entity_id    IN NUMBER,
 p_ledger_id          IN NUMBER,
 p_org_id             IN NUMBER,
 p_event_id           IN NUMBER,
 p_valuation_method   IN VARCHAR2,
 p_entity_type_code   IN VARCHAR2,
 p_event_type_code    IN VARCHAR2,
 p_curr_event_date    IN DATE,
 p_event_date         IN DATE,
 p_status             IN VARCHAR2,
 p_action             IN VARCHAR2,
 p_curr_trx_date      IN DATE,
 p_transaction_date   IN DATE,
 x_event_id           OUT NOCOPY NUMBER)
IS
  CURSOR c IS
  SELECT gld.cust_trx_line_gl_dist_id    dist_ctlgd_id,
         gld.gl_date                     dist_gl_date,
         gld.account_set_flag            dist_account_set_flag,
         trx.customer_trx_id             trx_trx_id,
         trx.complete_flag               trx_complete_flag,
         trx.trx_date                    trx_trx_date,
         trx.invoicing_rule_id           trx_invoicing_rule_id,
         ctt.post_to_gl                  trx_post_to_gl,
         xet.entity_id                   ent_entity_id,
         ev.event_id                     trx_event_id,
         ev.event_date                   trx_event_date,
         ev.event_status_code            trx_event_status,
         ev.transaction_date             trx_ev_trx_date,
         gld.event_id                    dist_event_id,
         distev.event_status_code        dist_event_status,
         distev.event_date               dist_event_date,
         distev.transaction_date         dist_ev_trx_date
  FROM ra_customer_trx               trx,
       ra_cust_trx_line_gl_dist      gld,
       ra_cust_trx_types             ctt,
       xla_transaction_entities_upg  xet,
       xla_events                    ev,
       xla_events                    distev
  WHERE trx.customer_trx_id     = p_source_id_int_1
  AND trx.customer_trx_id       = gld.customer_trx_id
  AND gld.account_class         = 'REC'
  AND gld.posting_control_id    = -3
  AND gld.latest_rec_flag	= 'Y'
  AND ctt.cust_trx_type_id      = trx.cust_trx_type_id
  AND trx.SET_OF_BOOKS_ID       = xet.LEDGER_ID
  AND xet.application_id        = 222
  AND nvl(xet.source_id_int_1, -99)       = trx.customer_trx_id
  AND xet.entity_code           = 'TRANSACTIONS'
  AND xet.entity_id             = ev.entity_id
  AND ev.application_id         = 222
  AND ev.event_date             = gld.gl_date(+)
  AND distev.application_id(+)  = 222
  AND gld.event_id              = distev.event_id(+)
  ORDER BY DECODE(gld.account_set_flag,'N',1,2) asc;

  l_rec    c%ROWTYPE;
  l_upg_trx_date        DATE := FND_API.G_MISS_DATE;
  l_upg_gl_date         DATE := FND_API.G_MISS_DATE;

  l_event_source_info   xla_events_pub_pkg.t_event_source_info;
  l_event_id            NUMBER;
  l_valuation_method    VARCHAR2(10);
  l_event_info_t        xla_events_pub_pkg.t_array_event_info;
  l_security            xla_events_pub_pkg.t_security;

  not_suffisant_info    EXCEPTION;
  done                  EXCEPTION;
  not_supported_action  EXCEPTION;
  more_than_one_event   EXCEPTION;
  no_event_found        EXCEPTION;
  ent_ev_no_exist       EXCEPTION;

BEGIN
  arp_standard.debug('do_on_existing_events+');
  arp_standard.debug(' p_trx_number         :'||p_trx_number);
  arp_standard.debug(' p_legal_entity_id    :'||p_legal_entity_id);
  arp_standard.debug(' p_ledger_id          :'||p_ledger_id);
  arp_standard.debug(' p_org_id             :'||p_org_id);
  arp_standard.debug(' p_event_id           :'||p_event_id);
  arp_standard.debug(' p_valuation_method   :'||p_valuation_method);
  arp_standard.debug(' p_entity_type_code   :'||p_entity_type_code);
  arp_standard.debug(' p_event_type_code    :'||p_event_type_code);
  arp_standard.debug(' p_status             :'||p_status);
  arp_standard.debug(' p_action             :'||p_action);
  arp_standard.debug(' p_event_date         :'||p_event_date);
  arp_standard.debug(' p_curr_event_date    :'||p_curr_event_date);
  arp_standard.debug(' p_curr_trx_date      :'||p_curr_trx_date);

  -- get the eve
  IF   p_ledger_id IS NULL OR  p_org_id IS NULL THEN
     RAISE not_suffisant_info;
  END IF;

  OPEN c;
  FETCH c INTO l_rec;
  IF c%NOTFOUND THEN
    RAISE ent_ev_no_exist;
  END IF;
  CLOSE c;


  l_event_source_info.application_id    := 222;
  l_event_source_info.legal_entity_id   := p_legal_entity_id;
  l_event_source_info.ledger_id         := p_ledger_id;
  l_event_source_info.entity_type_code  := p_entity_type_code;
  l_event_source_info.transaction_number:= p_trx_number;
  l_event_source_info.source_id_int_1   := p_source_id_int_1;

  l_security.security_id_int_1          := p_org_id;


  arp_standard.debug('    dist_ctlgd_id         :'|| l_rec.dist_ctlgd_id         );
  arp_standard.debug('    dist_gl_date          :'|| l_rec.dist_gl_date          );
  arp_standard.debug('    dist_account_set_flag :'|| l_rec.dist_account_set_flag );
  arp_standard.debug('    trx_trx_id            :'|| l_rec.trx_trx_id            );
  arp_standard.debug('    trx_complete_flag     :'|| l_rec.trx_complete_flag     );
  arp_standard.debug('    trx_trx_date          :'|| l_rec.trx_trx_date          );
  arp_standard.debug('    trx_invoicing_rule_id :'|| l_rec.trx_invoicing_rule_id );
  arp_standard.debug('    trx_post_to_gl        :'|| l_rec.trx_post_to_gl        );
  arp_standard.debug('    ent_entity_id         :'|| l_rec.ent_entity_id         );
  arp_standard.debug('    trx_event_id          :'|| l_rec.trx_event_id          );
  arp_standard.debug('    trx_event_date        :'|| l_rec.trx_event_date        );
  arp_standard.debug('    trx_event_status      :'|| l_rec.trx_event_status      );
  arp_standard.debug('    trx_ev_trx_date       :'|| l_rec.trx_ev_trx_date       );
  arp_standard.debug('    dist_event_id         :'|| l_rec.dist_event_id         );
  arp_standard.debug('    dist_event_status     :'|| l_rec.dist_event_status     );
  arp_standard.debug('    dist_event_date       :'|| l_rec.dist_event_date       );
  arp_standard.debug('    dist_ev_trx_date      :'|| l_rec.dist_ev_trx_date      );


  IF l_rec.dist_account_set_flag = 'Y' THEN
    --
    -- Case the transaction with rule
    -- Rev Rec has not run
    -- Only one event should exist and no denormalization on distributions
    --
    -- User transaction level event
    --
    l_event_id := l_rec.trx_event_id;


  ELSIF  l_rec.dist_account_set_flag = 'N' THEN
    --
    -- Case the transaction with rule REVREC run or none rule based trx
    -- one single tied back to rec distribution should exist
    --
    -- distribution level event_id
    l_event_id := l_rec.dist_event_id;

  END IF;


  --
  --Determination of the dates
  --
  IF (p_curr_event_date <> p_event_date AND
      p_curr_event_date IS NOT NULL     AND
      p_event_date      IS NOT NULL     )
     OR
     (p_curr_event_date IS NULL AND p_event_date IS NOT NULL)
     OR
     (p_curr_event_date IS NOT NULL AND p_event_date IS NULL)
  THEN
     l_upg_gl_date   := p_event_date;
  END IF;


  IF (p_curr_trx_date    <> p_event_date AND
      p_curr_trx_date    IS NOT NULL     AND
      p_transaction_date IS NOT NULL )
     OR
     (p_curr_trx_date  IS NOT NULL AND p_transaction_date IS NULL)
     OR
     (p_curr_trx_date  IS NULL AND p_transaction_date IS NOT NULL)
  THEN
     l_upg_trx_date   := p_transaction_date;
  END IF;



  IF l_upg_trx_date <> FND_API.G_MISS_DATE OR l_upg_gl_date <> FND_API.G_MISS_DATE THEN
       arp_standard.debug(' call update event with at transaction level');
       xla_events_pub_pkg.update_event
               (p_event_source_info    => l_event_source_info,
                p_event_id             => l_event_id,
                p_event_date           => p_event_date,
                p_valuation_method     => p_valuation_method,
                p_transaction_date     => p_transaction_date,
                p_security_context     => l_security);
  END IF;

  arp_standard.debug('do_on_existing_events-');

EXCEPTION
  WHEN ent_ev_no_exist      THEN
    arp_standard.debug(' EXCEPTION ent_ev_no_exist - no event update required');
  WHEN no_event_found       THEN
    arp_standard.debug(' EXCEPTION no_event_found - no event update required');
  WHEN more_than_one_event  THEN
    arp_standard.debug(' EXCEPTION more_than_one_event can not update');
  WHEN not_suffisant_info THEN
    arp_standard.debug(' EXCEPTION not_suffisant_info do_on_existing_events has done nothing');
  WHEN done THEN
    arp_standard.debug(' do_on_existing_events has done '||p_action);
    arp_standard.debug('do_on_existing_events has done -');
  WHEN not_supported_action THEN
    arp_standard.debug(' EXCEPTION not_supported_action do_on_existing_events '||p_action);
END;



PROCEDURE get_ar_trx_event_info
(p_entity_code      IN VARCHAR2,
 p_source_int_id    IN NUMBER)
IS
BEGIN
  arp_standard.debug('get_ar_trx_event_info +');
  IF    p_entity_code = 'TRANSACTIONS' THEN
    --
    -- If the transaction is rule based then no records will be inserted by
    --   by this statement if REVREC has not run.
    -- If gl_date is null the transaction is non postable
    --   there is no need to verify the xla upgrade
    --
    INSERT INTO ar_detect_gt(gl_date       ,
                             source_int_id ,
                             entity_code   ,
                             event_id      ,
                             from_application)
    SELECT  DISTINCT a.gl_date         ,
            a.trx_id          ,
            p_entity_code     ,
            a.event_id        ,
            'AR'
    FROM
     (SELECT d.gl_date             gl_date,
             d.customer_trx_id     trx_id,
             d.event_id            event_id
       FROM ra_cust_trx_line_gl_dist d
      WHERE customer_trx_id  = p_source_int_id
        AND account_set_flag = 'N'
        AND gl_date         IS NOT NULL
     UNION ALL
      SELECT ra.gl_date           gl_date,
             ra.customer_trx_id   trx_id,
             ra.event_id          event_id
        FROM ra_customer_trx             trx,
             ra_cust_trx_types           ctt,
             ar_receivable_applications  ra
       WHERE trx.customer_trx_id = p_source_int_id
         AND ctt.cust_trx_type_id= trx.cust_trx_type_id
         AND ctt.org_id          = trx.org_id
         AND ctt.type            = 'CM'
         AND trx.customer_trx_id = ra.customer_trx_id
         AND ra.status           = 'APP') a;

   -- Need to insert the CMAPP events


  ELSIF p_entity_code = 'RECEIPTS' THEN

    INSERT INTO ar_detect_gt(gl_date       ,
                             source_int_id ,
                             entity_code   ,
                             event_id      ,
                             from_application)
    SELECT DISTINCT gl_date,
                    cash_receipt_id,
                    p_entity_code,
                    event_id,
                    'AR'
    FROM
    (SELECT gl_date          gl_date,
            cash_receipt_id  cash_receipt_id,
            event_id         event_id
       FROM ar_cash_receipt_history  crh
      WHERE cash_receipt_id  = p_source_int_id
     UNION ALL
      SELECT ra.gl_date           gl_date,
             ra.cash_receipt_id   cash_receipt_id,
             ra.event_id          event_id
        FROM ar_receivable_applications  ra
       WHERE ra.cash_receipt_id  = p_source_int_id
         AND ra.status           = 'APP');


  ELSIF p_entity_code = 'ADJUSTMENTS' THEN

    INSERT INTO ar_detect_gt(gl_date       ,
                             source_int_id ,
                             entity_code   ,
                             event_id      ,
                             from_application)
     SELECT gl_date,
            adjustment_id,
            p_entity_code,
            event_id,
            'AR'
       FROM ar_adjustments  crh
      WHERE adjustment_id  = p_source_int_id;

  ELSIF p_entity_code = 'BILLS_RECEIVABLE' THEN

    INSERT INTO ar_detect_gt(gl_date       ,
                             source_int_id ,
                             entity_code   ,
                             event_id      ,
                             from_application)
    SELECT DISTINCT gl_date,
           customer_trx_id,
           p_entity_code,
           event_id,
           'AR'
      FROM ar_transaction_history  crh
    WHERE customer_trx_id  = p_source_int_id;


  END IF;
  arp_standard.debug('get_ar_trx_event_info -');
END;




PROCEDURE get_xla_event_info
(p_entity_code     IN VARCHAR2,
 p_source_int_id   IN NUMBER)
IS
BEGIN
  arp_standard.debug('get_xla_event_info +');
  arp_standard.debug('  p_entity_code     :'||p_entity_code);
  arp_standard.debug('  p_source_int_id   :'||p_source_int_id);

  INSERT INTO ar_detect_gt(gl_date       ,
                           source_int_id ,
                           entity_code   ,
                           event_id      ,
                           from_application)
   SELECT e.event_date,
          t.source_id_int_1,
          t.entity_code,
          e.event_id,
          'XLA'
     FROM xla_events                   e,
          xla_transaction_entities_upg t
    WHERE t.application_id  = 222
      AND t.ledger_id = arp_global.set_of_books_id
      AND t.entity_code     = p_entity_code
      AND nvl(t.source_id_int_1,-99) = p_source_int_id
      AND t.entity_id       = e.entity_id
      AND e.application_id  = 222;

  arp_standard.debug('get_xla_event_info -');
END;


PROCEDURE ar_event_existence
(p_entity_code       IN VARCHAR2,
 p_source_int_id     IN NUMBER,
 x_result           OUT NOCOPY VARCHAR2)
IS
CURSOR c IS
SELECT gl_date
  FROM ar_detect_gt
 WHERE source_int_id = p_source_int_id
   AND entity_code   = p_entity_code
   AND from_application = 'AR'
   AND event_id     IS NULL;

l_date  DATE;
BEGIN
  arp_standard.debug('ar_event_existence +');
  arp_standard.debug('  p_entity_code     :'||p_entity_code);
  arp_standard.debug('  p_source_int_id   :'||p_source_int_id);
  OPEN c;
  FETCH c INTO l_date;
  IF c%NOTFOUND THEN
     x_result := 'Y';
  ELSE
     x_result := 'N';
  END IF;
  CLOSE c;
  arp_standard.debug('  x_result  :'||x_result);
  arp_standard.debug('ar_event_existence -');
END;



PROCEDURE ar_xla_all_match_exist
(p_entity_code       IN VARCHAR2,
 p_source_int_id     IN NUMBER,
 x_result            OUT NOCOPY VARCHAR2)
IS
CURSOR c IS
SELECT a1.gl_date
  FROM ar_detect_gt a1
 WHERE a1.source_int_id = p_source_int_id
   AND a1.entity_code   = p_entity_code
   AND a1.from_application = 'AR'
   AND NOT EXISTS
    (SELECT a2.gl_date
       FROM ar_detect_gt a2
      WHERE a2.source_int_id = a1.source_int_id
        AND a2.entity_code   = a1.entity_code
        AND a2.from_application = 'XLA'
        AND a2.gl_date = a1.gl_date);
l_date    DATE;
BEGIN
  arp_standard.debug('ar_xla_all_match_exist +');
  OPEN c;
  FETCH c INTO l_date;
  IF c%NOTFOUND THEN
    x_result := 'Y';
  ELSE
    x_result := 'N';
  END IF;
  CLOSE c;
  arp_standard.debug('    l_date   :'||l_date);
  arp_standard.debug('    x_result :'||x_result);
  arp_standard.debug('ar_xla_all_match_exist -');
END;




PROCEDURE upgrade_status_per_doc
(p_init_msg_list     IN VARCHAR2 := FND_API.G_FALSE,
 p_entity_code       IN VARCHAR2,
 p_source_int_id     IN NUMBER,
 x_upgrade_status    OUT NOCOPY VARCHAR2,
 x_return_status     OUT NOCOPY  VARCHAR2,
 x_msg_count         OUT NOCOPY  NUMBER,
 x_msg_data          OUT NOCOPY  VARCHAR2)
IS
  x_result        VARCHAR2(30);
  end_execution   EXCEPTION;
BEGIN
  arp_standard.debug('upgrade_status_per_doc +');
  arp_standard.debug('  p_entity_code  :'||p_entity_code);
  arp_standard.debug('  p_source_int_id:'||p_source_int_id);
  x_return_status  := fnd_api.g_ret_sts_success;

  -- initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF p_entity_code NOT IN
     ('TRANSACTIONS','RECEIPTS',
      'ADJUSTMENTS', 'BILLS_RECEIVABLE')
  THEN
    arp_standard.debug('Value for entity code should be TRANSACTIONS RECEIPTS ADJUSTMENTS BILLS_RECEIVABLE');
    FND_MESSAGE.SET_NAME( 'AR', 'AR_ONLY_VALUE_ALLOWED' );
    FND_MESSAGE.SET_TOKEN( 'COLUMN', 'ENTITY_CODE' );
    FND_MESSAGE.SET_TOKEN( 'VALUES', 'TRANSACTIONS,RECEIPTS,ADJUSTMENTS,BILLS_RECEIVABLE');
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RAISE fnd_api.G_EXC_ERROR;
  END IF;

  DELETE FROM ar_detect_gt
   WHERE entity_code   = p_entity_code
     AND source_int_id = p_source_int_id;

  -- 1 Get AR info
  get_ar_trx_event_info
   (p_entity_code     => p_entity_code,
    p_source_int_id   => p_source_int_id);

  -- 2 check if all AR infor has the event_id
  ar_event_existence
  (p_entity_code      => p_entity_code,
   p_source_int_id    => p_source_int_id,
   x_result           => x_result);

  IF   x_result = 'Y' THEN
    x_upgrade_status := 'Y';
    RAISE end_execution;
  END IF;

  -- 3 Get XLA events
  get_xla_event_info
   (p_entity_code     => p_entity_code,
    p_source_int_id   => p_source_int_id);

  -- 4 Check if all gl date has a event
  ar_xla_all_match_exist
   (p_entity_code     => p_entity_code,
    p_source_int_id   => p_source_int_id,
    x_result          => x_result);

  IF x_result = 'Y' THEN
    x_upgrade_status := 'Y';
  ELSE
    x_upgrade_status := 'N';
  END IF;

  arp_standard.debug('   x_upgrade_status :'||x_upgrade_status);
  arp_standard.debug('upgrade_status_per_doc -');
EXCEPTION
 WHEN end_execution THEN
   arp_standard.debug('   x_upgrade_status :'||x_upgrade_status);
 WHEN fnd_api.G_EXC_ERROR THEN
   fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                             p_count => x_msg_count,
                             p_data  => x_msg_data);
 WHEN OTHERS THEN
   arp_standard.debug('EXCEPTION OTHERS in upgrade_status_per_doc:'||SQLERRM);
   x_return_status := fnd_api.g_ret_sts_unexp_error;
   fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
   fnd_message.set_token('ERROR' ,SQLERRM);
   fnd_msg_pub.add;
   fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                             p_count => x_msg_count,
                             p_data  => x_msg_data);
END;




PROCEDURE r12_adj_in_xla
(p_start_date       IN DATE,
 p_end_date         IN DATE,
 p_org_id           IN NUMBER DEFAULT NULL,
 x_return_status    OUT NOCOPY VARCHAR2,
 x_msg_count        OUT NOCOPY NUMBER,
 x_msg_data         OUT NOCOPY VARCHAR2)
IS
 CURSOR c_adj(p_start_date       IN DATE,
              p_end_date         IN DATE,
              p_org_id           IN NUMBER)
 IS
 SELECT adj.adjustment_id
   FROM ar_distributions_all            ard,
        ar_adjustments_all              adj
  WHERE ard.source_table             = 'ADJ'
    AND ard.source_id                = adj.adjustment_id
    AND adj.gl_date                  BETWEEN p_start_date AND p_end_date
    AND adj.posting_control_id       = -3
    AND NVL(p_org_id,adj.org_id)     = adj.org_id
    AND adj.status                   = 'A'
    AND NOT EXISTS
      (SELECT NULL
         FROM xla_distribution_links          lk,
              xla_ae_lines                    ae
        WHERE ard.line_id                 = lk.source_distribution_id_num_1
          AND lk.application_id           = 222
          AND lk.source_distribution_type = 'AR_DISTRIBUTIONS_ALL'
          AND ae.application_id           = 222
          AND lk.ae_header_id             = ae.ae_header_id
          AND lk.ae_line_num              = ae.ae_line_num);
 l_adj_id    NUMBER;
 l_text      VARCHAR2(2000);
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  validate_parameter
  (p_start_date       => p_start_date,
   p_end_date         => p_end_date,
   p_org_id           => p_org_id,
   p_type             => 'ADJ',
   p_entity           => 'AR_ADJUSTMENTS_ALL',
   x_return_status    => x_return_status);
  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE fnd_api.g_exc_error;
  END IF;
  OPEN c_adj(p_start_date, p_end_date,p_org_id);
  FETCH c_adj INTO l_adj_id;
  IF c_adj%FOUND THEN
      l_text := ' There is at least one adjustment not posted and does not have a xla distribution paired.
That is the adjustment does not have accounting created - adjustment_id :'||l_adj_id;
      log(l_text);
      FND_MESSAGE.SET_NAME('AR','AR_SUBMIT_ACCT_REQ');
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
  CLOSE c_adj;
  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE fnd_api.g_exc_error;
  END IF;
EXCEPTION
 WHEN fnd_api.g_exc_error THEN
   fnd_msg_pub.count_and_get(
        p_encoded                    => fnd_api.g_false,
        p_count                      => x_msg_count,
        p_data                       => x_msg_data);
   log(x_msg_data);
 WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,'Insert_Head_Row:'||SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
   log(x_msg_data);
END;


--
--
-- p_type       INV, CM, CB, DM, DEP, GUAR, ALL ,INVDEPGUAR
--
--
PROCEDURE r12_trx_in_xla
(p_start_date       IN DATE,
 p_end_date         IN DATE,
 p_type             IN VARCHAR2,
 p_org_id           IN NUMBER DEFAULT NULL,
 x_return_status    OUT NOCOPY VARCHAR2,
 x_msg_count        OUT NOCOPY NUMBER,
 x_msg_data         OUT NOCOPY VARCHAR2)
IS
 CURSOR c_trx(p_start_date       IN DATE,
              p_end_date         IN DATE,
              p_org_id           IN NUMBER,
              p_type             IN VARCHAR2)
 IS
 SELECT ctlgd.customer_trx_id
   FROM ra_cust_trx_line_gl_dist_all    ctlgd,
        ra_customer_trx_all             trx,
        ra_cust_trx_types_all           tty
  WHERE ctlgd.gl_date                BETWEEN p_start_date AND p_end_date
    AND ctlgd.posting_control_id     = -3
    AND NVL(p_org_id,ctlgd.org_id)   = p_org_id
    AND ctlgd.account_set_flag       = 'N'
    AND ctlgd.customer_trx_id        = trx.customer_trx_id
    AND trx.cust_trx_type_id         = tty.cust_trx_type_id
    AND tty.org_id                   = trx.org_id
    AND tty.post_to_gl               = 'Y'
    AND DECODE(p_type,
              'ALL',tty.type,
       'INVDEPGUAR',DECODE( tty.type,'INV','INV',
                                     'DEP','DEP',
                                     'GUAR','GUAR','EXCLUDE'),
                     p_type)         = tty.type
    AND NOT EXISTS
      (SELECT NULL
         FROM xla_distribution_links          lk,
              xla_ae_lines                    ae
        WHERE ctlgd.cust_trx_line_gl_dist_id = lk.source_distribution_id_num_1
          AND lk.application_id           = 222
          AND lk.source_distribution_type = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
          AND ae.application_id           = 222
          AND lk.ae_header_id             = ae.ae_header_id
          AND lk.ae_line_num              = ae.ae_line_num);
 l_trx_id    NUMBER;
 l_text      VARCHAR2(2000);
 l_tag       VARCHAR2(80);
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  validate_parameter
  (p_start_date       => p_start_date,
   p_end_date         => p_end_date,
   p_org_id           => p_org_id,
   p_type             => p_type,
   p_entity           => 'RA_CUST_TRX_LINE_GL_DIST_ALL',
   x_return_status    => x_return_status);
  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE fnd_api.g_exc_error;
  END IF;
  IF     p_type = 'INV'  THEN  l_tag := 'Sales Invoice';
  ELSIF  p_type = 'CM'   THEN  l_tag := 'Credit Memo';
  ELSIF  p_type = 'DM'   THEN  l_tag := 'Debit Memo';
  ELSIF  p_type = 'DEP'  THEN  l_tag := 'Deposite';
  ELSIF  p_type = 'GUAR' THEN  l_tag := 'Guarantee';
  ELSE   l_tag := 'Transaction';
  END IF;
  OPEN c_trx(p_start_date,p_end_date,p_org_id, p_type);
  FETCH c_trx INTO l_trx_id;
  IF c_trx%FOUND THEN
      l_text := ' There is at least one '|| l_tag ||' not posted but does not have at least xla distribution paired.
 The '|| l_tag ||' does not have accounting created - customer_trx_id :'||l_trx_id;
      log(l_text);
      FND_MESSAGE.SET_NAME('AR','AR_SUBMIT_ACCT_REQ');
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
  CLOSE c_trx;
  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE fnd_api.g_exc_error;
  END IF;
EXCEPTION
 WHEN fnd_api.g_exc_error THEN
   fnd_msg_pub.count_and_get(
        p_encoded                    => fnd_api.g_false,
        p_count                      => x_msg_count,
        p_data                       => x_msg_data);
   log(x_msg_data);
 WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,'Insert_Head_Row:'||SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
   log(x_msg_data);
END;


--
-- p_type     CASH, MISC, ALL
--
PROCEDURE r12_crh_in_xla
(p_start_date       IN DATE,
 p_end_date         IN DATE,
 p_org_id           IN NUMBER   DEFAULT NULL,
 p_type             IN VARCHAR2 DEFAULT 'ALL',
 x_return_status    OUT NOCOPY VARCHAR2,
 x_msg_count        OUT NOCOPY NUMBER,
 x_msg_data         OUT NOCOPY VARCHAR2)
IS
 CURSOR c_recp(p_start_date       IN DATE,
               p_end_date         IN DATE,
               p_org_id           IN NUMBER,
               p_type             IN VARCHAR2)
 IS
 SELECT crh.cash_receipt_id
   FROM ar_distributions_all            ard,
        ar_cash_receipt_history_all     crh,
        ar_cash_receipts_all            cr
  WHERE ard.source_table             = 'CRH'
    AND ard.source_id                = crh.cash_receipt_history_id
    AND crh.gl_date                  BETWEEN p_start_date AND p_end_date
    AND crh.posting_control_id       = -3
    AND NVL(p_org_id,crh.org_id)     = crh.org_id
    AND crh.cash_receipt_id          = cr.cash_receipt_id
    AND DECODE(p_type,
               'ALL',cr.type,
               p_type)               = cr.type
    AND NOT EXISTS
      (SELECT NULL
         FROM xla_distribution_links          lk,
              xla_ae_lines                    ae
        WHERE ard.line_id                 = lk.source_distribution_id_num_1
          AND lk.application_id           = 222
          AND lk.source_distribution_type = 'AR_DISTRIBUTIONS_ALL'
          AND ae.application_id           = 222
          AND lk.ae_header_id             = ae.ae_header_id
          AND lk.ae_line_num              = ae.ae_line_num);
 l_cr_id     NUMBER;
 l_text      VARCHAR2(2000);
 l_tag       VARCHAR2(80);
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  validate_parameter
  (p_start_date       => p_start_date,
   p_end_date         => p_end_date,
   p_org_id           => p_org_id,
   p_type             => p_type,
   p_entity           => 'AR_CASH_RECEIPT_HISTORY_ALL',
   x_return_status    => x_return_status);
  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE fnd_api.g_exc_error;
  END IF;
  IF p_type = 'CASH' THEN
    l_tag   := 'Trade Receipt';
  ELSE
    l_tag   := 'Miscellenaous Receipt';
  END IF;
  OPEN c_recp(p_start_date,p_end_date, p_org_id,p_type);
  FETCH c_recp INTO l_cr_id;
  IF c_recp%FOUND THEN
      l_text := ' There is at least one '|| l_tag ||' not posted and does not have a xla distribution paired.
That is the '|| l_tag ||' does not have accounting created - cash_receipt_id :'||l_cr_id;
      log(l_text);
      FND_MESSAGE.SET_NAME('AR','AR_SUBMIT_ACCT_REQ');
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
  CLOSE c_recp;
  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE fnd_api.g_exc_error;
  END IF;
EXCEPTION
 WHEN fnd_api.g_exc_error THEN
   fnd_msg_pub.count_and_get(
        p_encoded                    => fnd_api.g_false,
        p_count                      => x_msg_count,
        p_data                       => x_msg_data);
   log(x_msg_data);
 WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,'Insert_Head_Row:'||SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
   log(x_msg_data);
END;




--
-- p_type     APP, CMAPP, ALL
--
PROCEDURE r12_app_in_xla
(p_start_date       IN DATE,
 p_end_date         IN DATE,
 p_org_id           IN NUMBER DEFAULT NULL,
 p_type             IN VARCHAR2 DEFAULT 'ALL',
 x_return_status    OUT NOCOPY VARCHAR2,
 x_msg_count        OUT NOCOPY NUMBER,
 x_msg_data         OUT NOCOPY VARCHAR2)
IS
 CURSOR c_app(p_start_date       IN DATE,
              p_end_date         IN DATE,
              p_org_id           IN NUMBER,
              p_type             IN VARCHAR2)
 IS
 SELECT ra.receivable_application_id
   FROM ar_distributions_all            ard,
        ar_receivable_applications_all  ra
  WHERE ard.source_table             = 'RA'
    AND ra.status                    = 'APP'
    AND ard.source_id                = ra.receivable_application_id
    AND ra.gl_date                   BETWEEN p_start_date AND p_end_date
    AND ra.posting_control_id        = -3
    AND NVL(p_org_id,ra.org_id)      = ra.org_id
    AND DECODE(p_type,'ALL',p_type,
         DECODE(ra.cash_receipt_id,NULL,
               DECODE(ra.customer_trx_id,NULL,NULL,'CMAPP'),
               'APP'))               = p_type
    AND NOT EXISTS
      (SELECT NULL
         FROM xla_distribution_links          lk,
              xla_ae_lines                    ae
        WHERE ard.line_id                 = lk.source_distribution_id_num_1
          AND lk.application_id           = 222
          AND lk.source_distribution_type = 'AR_DISTRIBUTIONS_ALL'
          AND ae.application_id           = 222
          AND lk.ae_header_id             = ae.ae_header_id
          AND lk.ae_line_num              = ae.ae_line_num);
 l_ra_id     NUMBER;
 l_text      VARCHAR2(2000);
 l_tag       VARCHAR2(80);
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  validate_parameter
  (p_start_date       => p_start_date,
   p_end_date         => p_end_date,
   p_org_id           => p_org_id,
   p_type             => p_type,
   p_entity           => 'AR_RECEIVABLE_APPLICATIONS_ALL',
   x_return_status    => x_return_status);
  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE fnd_api.g_exc_error;
  END IF;
  IF     p_type = 'APP' THEN
     l_tag := 'Cash Receipt Application';
  ELSIF  p_type = 'CMAPP' THEN
     l_tag := 'Credit Memo Application';
  ELSE
     l_tag := 'Application';
  END IF;
  OPEN c_app(p_start_date,p_end_date, p_org_id, p_type);
  FETCH c_app INTO l_ra_id;
  IF c_app%FOUND THEN
      l_text := ' There is at least one '||l_tag||' not posted and does not have a xla distribution paired.
That is the '|| l_tag ||' does not have accounting created - receivable_application_id :'||l_ra_id;
      log(l_text);
      FND_MESSAGE.SET_NAME('AR','AR_SUBMIT_ACCT_REQ');
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
  CLOSE c_app;
  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE fnd_api.g_exc_error;
  END IF;
EXCEPTION
 WHEN fnd_api.g_exc_error THEN
   fnd_msg_pub.count_and_get(
        p_encoded                    => fnd_api.g_false,
        p_count                      => x_msg_count,
        p_data                       => x_msg_data);
   log(x_msg_data);
 WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,'Insert_Head_Row:'||SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
   log(x_msg_data);
END;



PROCEDURE r12_th_in_xla
(p_start_date       IN DATE,
 p_end_date         IN DATE,
 p_org_id           IN NUMBER DEFAULT NULL,
 x_return_status    OUT NOCOPY VARCHAR2,
 x_msg_count        OUT NOCOPY NUMBER,
 x_msg_data         OUT NOCOPY VARCHAR2)
IS
 CURSOR c(p_start_date       IN DATE,
          p_end_date         IN DATE,
          p_org_id           IN NUMBER)
 IS
 SELECT th.customer_trx_id
   FROM ar_distributions_all            ard,
        ar_transaction_history_all      th
  WHERE ard.source_table             = 'TH'
    AND ard.source_id                = th.transaction_history_id
    AND th.gl_date                   BETWEEN p_start_date AND p_end_date
    AND th.posting_control_id        = -3
    AND NVL(p_org_id,th.org_id)      = th.org_id
    AND NOT EXISTS
      (SELECT NULL
         FROM xla_distribution_links          lk,
              xla_ae_lines                    ae
        WHERE ard.line_id                 = lk.source_distribution_id_num_1
          AND lk.application_id           = 222
          AND lk.source_distribution_type = 'AR_DISTRIBUTIONS_ALL'
          AND ae.application_id           = 222
          AND lk.ae_header_id             = ae.ae_header_id
          AND lk.ae_line_num              = ae.ae_line_num);
 l_trx_id    NUMBER;
 l_text      VARCHAR2(2000);
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  validate_parameter
  (p_start_date       => p_start_date,
   p_end_date         => p_end_date,
   p_org_id           => p_org_id,
   p_type             => 'BILL',
   p_entity           => 'AR_TRANSACTION_HISTORY_ALL',
   x_return_status    => x_return_status);
  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE fnd_api.g_exc_error;
  END IF;
  OPEN c(p_start_date, p_end_date,p_org_id);
  FETCH c INTO l_trx_id;
  IF c%FOUND THEN
      l_text := ' There is at least one bill not posted and does not have a xla distribution paired.
That is the bill does not have accounting created - customer_trx_id :'||l_trx_id;
      log(l_text);
      FND_MESSAGE.SET_NAME('AR','AR_SUBMIT_ACCT_REQ');
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
  CLOSE c;
  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE fnd_api.g_exc_error;
  END IF;
EXCEPTION
 WHEN fnd_api.g_exc_error THEN
   fnd_msg_pub.count_and_get(
        p_encoded                    => fnd_api.g_false,
        p_count                      => x_msg_count,
        p_data                       => x_msg_data);
   log(x_msg_data);
 WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,'Insert_Head_Row:'||SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
   log(x_msg_data);
END;



PROCEDURE r12_dist_in_xla
(p_init_msg_list    IN VARCHAR2 := fnd_api.g_false,
 p_start_date       IN DATE,
 p_end_date         IN DATE,
 p_xla_post_status  IN VARCHAR2 DEFAULT 'Y',
 p_inv_flag         IN VARCHAR2 DEFAULT 'Y',
 p_dm_flag          IN VARCHAR2 DEFAULT 'Y',
 p_cb_flag          IN VARCHAR2 DEFAULT 'Y',
 p_cm_flag          IN VARCHAR2 DEFAULT 'Y',
 p_cmapp_flag       IN VARCHAR2 DEFAULT 'Y',
 p_adj_flag         IN VARCHAR2 DEFAULT 'Y',
 p_recp_flag        IN VARCHAR2 DEFAULT 'Y',
 p_misc_flag        IN VARCHAR2 DEFAULT 'Y',
 p_bill_flag        IN VARCHAR2 DEFAULT 'Y',
 p_org_id           IN NUMBER DEFAULT NULL,
 x_return_status    OUT NOCOPY VARCHAR2,
 x_msg_count        OUT NOCOPY NUMBER,
 x_msg_data         OUT NOCOPY VARCHAR2)
IS
  l_return_status   VARCHAR2(10);
  l_msg_count       NUMBER;
  l_msg_data        VARCHAR2(2000);
  only_posted_jle   EXCEPTION;
BEGIN
  log('r12_dist_in_xla  +');
  log('  p_start_date       :'||p_start_date);
  log('  p_end_date         :'||p_end_date);
  log('  p_xla_post_status  :'||p_xla_post_status);
  log('  p_inv_flag         :'||p_inv_flag);
  log('  p_dm_flag          :'||p_dm_flag);
  log('  p_cb_flag          :'||p_cb_flag);
  log('  p_cm_flag          :'||p_cm_flag);
  log('  p_cmapp_flag       :'||p_cmapp_flag);
  log('  p_adj_flag         :'||p_adj_flag);
  log('  p_recp_flag        :'||p_recp_flag);
  log('  p_misc_flag        :'||p_misc_flag);
  log('  p_bill_flag        :'||p_bill_flag);
  log('  p_org_id           :'||p_org_id);
  x_return_status    := fnd_api.g_ret_sts_success;
  l_return_status    := fnd_api.g_ret_sts_success;
  IF fnd_api.to_boolean(p_init_msg_list) THEN
     fnd_msg_pub.initialize;
  END IF;
  IF p_xla_post_status = 'Y' THEN
    RAISE only_posted_jle;
  END IF;
  validate_parameter
  (p_start_date       => p_start_date,
   p_end_date         => p_end_date,
   p_org_id           => p_org_id,
   p_type             => 'NOT_SPECIFIED',
   p_entity           => 'NOT_SPECIFIED',
   x_return_status    => l_return_status);
  IF l_return_status <> fnd_api.g_ret_sts_success THEN
    RAISE fnd_api.g_exc_error;
  END IF;
  --
  --Running for transactions
  --
  IF (p_inv_flag = 'Y' AND p_dm_flag = 'Y' AND p_cb_flag = 'Y' AND p_cm_flag = 'Y') THEN
     r12_trx_in_xla
     (p_start_date       => p_start_date,
      p_end_date         => p_end_date,
      p_type             => 'ALL',
      p_org_id           => p_org_id,
      x_return_status    => l_return_status,
      x_msg_count        => l_msg_count,
      x_msg_data         => l_msg_data);
     IF l_return_status <> fnd_api.g_ret_sts_success THEN
       x_return_status := l_return_status;
       RAISE fnd_api.g_exc_error;
     END IF;
  ELSE
    IF (p_inv_flag = 'Y') THEN
      r12_trx_in_xla
      (p_start_date       => p_start_date,
       p_end_date         => p_end_date,
       p_type             => 'INVDEPGUAR',
       p_org_id           => p_org_id,
       x_return_status    => l_return_status,
       x_msg_count        => l_msg_count,
       x_msg_data         => l_msg_data);
      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        x_return_status := l_return_status;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;
    IF (p_dm_flag = 'Y') THEN
      r12_trx_in_xla
      (p_start_date       => p_start_date,
       p_end_date         => p_end_date,
       p_type             => 'DM',
       p_org_id           => p_org_id,
       x_return_status    => l_return_status,
       x_msg_count        => l_msg_count,
       x_msg_data         => l_msg_data);
      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        x_return_status := l_return_status;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;
    IF (p_cb_flag = 'Y') THEN
      r12_trx_in_xla
      (p_start_date       => p_start_date,
       p_end_date         => p_end_date,
       p_type             => 'CB',
       p_org_id           => p_org_id,
       x_return_status    => l_return_status,
       x_msg_count        => l_msg_count,
       x_msg_data         => l_msg_data);
      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        x_return_status := l_return_status;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;
    IF (p_cm_flag = 'Y') THEN
      r12_trx_in_xla
      (p_start_date       => p_start_date,
       p_end_date         => p_end_date,
       p_type             => 'CM',
       p_org_id           => p_org_id,
       x_return_status    => l_return_status,
       x_msg_count        => l_msg_count,
       x_msg_data         => l_msg_data);
      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        x_return_status := l_return_status;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;
  END IF;
  --
  --Running for adjustment
  --
  IF p_adj_flag = 'Y' THEN
    r12_adj_in_xla
    (p_start_date       => p_start_date,
     p_end_date         => p_end_date,
     p_org_id           => p_org_id,
     x_return_status    => l_return_status,
     x_msg_count        => l_msg_count,
     x_msg_data         => l_msg_data);
    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      x_return_status := l_return_status;
      RAISE fnd_api.g_exc_error;
    END IF;
  END IF;
  --
  --Running for receipts
  --
  IF p_recp_flag = 'Y' AND p_misc_flag = 'Y' THEN
    r12_crh_in_xla
    (p_start_date     => p_start_date,
     p_end_date       => p_end_date,
     p_org_id         => p_org_id,
     p_type           => 'ALL',
     x_return_status  => l_return_status,
     x_msg_count      => l_msg_count,
     x_msg_data       => l_msg_data);
    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      x_return_status := l_return_status;
      RAISE fnd_api.g_exc_error;
    END IF;
  ELSE
    IF p_recp_flag = 'Y' THEN
      r12_crh_in_xla
      (p_start_date     => p_start_date,
       p_end_date       => p_end_date,
       p_org_id         => p_org_id,
       p_type           => 'CASH',
       x_return_status  => l_return_status,
       x_msg_count      => l_msg_count,
       x_msg_data       => l_msg_data);
      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        x_return_status := l_return_status;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;
    IF p_misc_flag  = 'Y' THEN
      r12_crh_in_xla
      (p_start_date     => p_start_date,
       p_end_date       => p_end_date,
       p_org_id         => p_org_id,
       p_type           => 'MISC',
       x_return_status  => l_return_status,
       x_msg_count      => l_msg_count,
       x_msg_data       => l_msg_data);
      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        x_return_status := l_return_status;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;
  END IF;
  --
  --Running for applications
  --
  IF p_recp_flag = 'Y' AND p_cmapp_flag = 'Y' THEN
    r12_app_in_xla
    (p_start_date     => p_start_date,
     p_end_date       => p_end_date,
     p_org_id         => p_org_id,
     p_type           => 'ALL',
     x_return_status  => l_return_status,
     x_msg_count      => l_msg_count,
     x_msg_data       => l_msg_data);
    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      x_return_status := l_return_status;
      RAISE fnd_api.g_exc_error;
    END IF;
  ELSE
    IF p_recp_flag = 'Y' THEN
      r12_app_in_xla
      (p_start_date     => p_start_date,
       p_end_date       => p_end_date,
       p_org_id         => p_org_id,
       p_type           => 'APP',
       x_return_status  => l_return_status,
       x_msg_count      => l_msg_count,
       x_msg_data       => l_msg_data);
      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        x_return_status := l_return_status;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;
    IF p_cmapp_flag = 'Y' THEN
      r12_app_in_xla
      (p_start_date     => p_start_date,
       p_end_date       => p_end_date,
       p_org_id         => p_org_id,
       p_type           => 'CMAPP',
       x_return_status  => l_return_status,
       x_msg_count      => l_msg_count,
       x_msg_data       => l_msg_data);
      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        x_return_status := l_return_status;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;
  END IF;
  --
  --Running for bill
  --
  IF p_bill_flag = 'Y' THEN
    r12_th_in_xla
    (p_start_date     => p_start_date,
     p_end_date       => p_end_date,
     p_org_id         => p_org_id,
     x_return_status  => l_return_status,
     x_msg_count      => l_msg_count,
     x_msg_data       => l_msg_data);
    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      x_return_status := l_return_status;
      RAISE fnd_api.g_exc_error;
    END IF;
  END IF;
  log('r12_dist_in_xla  -');
EXCEPTION
  WHEN  only_posted_jle THEN
    log('the user wants to see only posted documents, no check to verify data in XLA');
  WHEN fnd_api.g_exc_error THEN
    x_msg_count    := l_msg_count;
    IF l_msg_count    > 1 THEN
      FOR i IN 1..l_msg_count LOOP
        l_msg_data := FND_MSG_PUB.Get(FND_MSG_PUB.G_NEXT,FND_API.G_FALSE);
        x_msg_data := x_msg_data||'-'||l_msg_data;
        log(l_msg_data);
      END LOOP;
    ELSE
      x_msg_data := l_msg_data;
    END IF;
  WHEN OTHERS THEN
    x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
    log('EXCEPTION OTHERS in r12_dist_in_xla :'||SQLERRM);
END;



PROCEDURE update_cr_dist
( p_ledger_id                 IN NUMBER
 ,p_source_id_int_1           IN NUMBER
 ,p_third_party_merge_date    IN DATE
 ,p_original_third_party_id   IN NUMBER
 ,p_original_site_id          IN NUMBER
 ,p_new_third_party_id        IN NUMBER
 ,p_new_site_id               IN NUMBER
 ,p_create_update             IN VARCHAR2 DEFAULT 'U'
 ,p_entity_code               IN VARCHAR2 DEFAULT 'RECEIPTS'
 ,p_type_of_third_party_merge IN VARCHAR2 DEFAULT 'PARTIAL'
 ,p_mapping_flag              IN VARCHAR2 DEFAULT 'N'
 ,p_execution_mode            IN VARCHAR2 DEFAULT 'SYNC'
 ,p_accounting_mode           IN VARCHAR2 DEFAULT 'F'
 ,p_transfer_to_gl_flag       IN VARCHAR2 DEFAULT 'Y'
 ,p_post_in_gl_flag           IN VARCHAR2 DEFAULT 'Y'
 ,p_third_party_type          IN VARCHAR2 DEFAULT 'C'
 ,x_errbuf                    OUT NOCOPY  VARCHAR2
 ,x_retcode                   OUT NOCOPY  VARCHAR2
 ,x_event_ids                 OUT NOCOPY  xla_third_party_merge_pub.t_event_ids
 ,x_request_id                OUT NOCOPY  NUMBER)
IS
  creation_mode             EXCEPTION;
  no_existing_account       EXCEPTION;
  nullify_customer          EXCEPTION;
BEGIN
  arp_standard.debug('update_cr_dist +');
  arp_standard.debug(' p_ledger_id              :'||p_ledger_id);
  arp_standard.debug(' p_source_id_int_1        :'||p_source_id_int_1);
  arp_standard.debug(' p_original_third_party_id:'||p_original_third_party_id);
  arp_standard.debug(' p_original_site_id       :'||p_original_site_id);
  arp_standard.debug(' p_new_third_party_id     :'||p_new_third_party_id);
  arp_standard.debug(' p_original_site_id       :'||p_original_site_id);
  arp_standard.debug(' p_third_party_merge_date :'||p_third_party_merge_date);
  arp_standard.debug(' p_create_update          :'||p_create_update);
  arp_standard.debug(' p_entity_code            :'||p_entity_code);
  arp_standard.debug(' p_type_of_third_party_merge:'||p_type_of_third_party_merge);
  arp_standard.debug(' p_mapping_flag           :'||p_mapping_flag);
  arp_standard.debug(' p_execution_mode         :'||p_execution_mode);
  arp_standard.debug(' p_accounting_mode        :'||p_accounting_mode);
  arp_standard.debug(' p_transfer_to_gl_flag    :'||p_transfer_to_gl_flag);
  arp_standard.debug(' p_post_in_gl_flag        :'||p_post_in_gl_flag);
  arp_standard.debug(' p_third_party_type       :'||p_third_party_type);

  -- No need to create a merge event in creation mode
  IF p_create_update = 'C' THEN
    arp_standard.debug('Creation mode');
    RAISE creation_mode;
  END IF;

  -- This is when the receipt has been created a unidentified
  IF p_original_third_party_id IS NULL THEN
    arp_standard.debug('No original account');
    RAISE no_existing_account;
  END IF;

  -- This is when user null out the customer on the receipt
--  IF p_new_third_party_id IS NULL THEN
--    RAISE nullify_customer;
--  END IF;

  IF p_original_third_party_id <> p_new_third_party_id OR
     p_new_third_party_id      IS NULL
  THEN

    INSERT INTO xla_events_gt
    (APPLICATION_ID
    ,LEDGER_ID
    ,ENTITY_CODE
    ,SOURCE_ID_INT_1
    ,VALUATION_METHOD)
   VALUES
    (222               --APPLICATION_ID
    ,p_ledger_id       --LEDGER_ID
    ,p_entity_code     --ENTITY_CODE
    ,p_source_id_int_1 --p_cash_receipt_id --SOURCE_ID_INT_1
    ,NULL);            --VALUATION_METHOD

   xla_third_party_merge_pub.third_party_merge
   ( x_errbuf                    => x_errbuf
    ,x_retcode                   => x_retcode
    ,x_event_ids                 => x_event_ids
    ,x_request_id                => x_request_id
    ,p_source_application_id     => 222
    ,p_application_id            => 222
    ,p_ledger_id                 => p_ledger_id
    ,p_third_party_merge_date    => p_third_party_merge_date
    ,p_third_party_type          => p_third_party_type
    ,p_original_third_party_id   => p_original_third_party_id
    ,p_original_site_id          => p_original_site_id
    ,p_new_third_party_id        => p_new_third_party_id
    ,p_new_site_id               => p_new_site_id
    ,p_type_of_third_party_merge => p_type_of_third_party_merge
    ,p_mapping_flag              => p_mapping_flag
    ,p_execution_mode            => p_execution_mode
    ,p_accounting_mode           => p_accounting_mode
    ,p_transfer_to_gl_flag       => p_transfer_to_gl_flag
    ,p_post_in_gl_flag           => p_post_in_gl_flag);

    IF x_retcode = 'S' AND p_entity_code = 'RECEIPTS' THEN
      UPDATE ar_distributions
      SET third_party_id     = p_new_third_party_id
         ,third_party_sub_id = p_new_site_id
      WHERE
	( SOURCE_TABLE, SOURCE_ID ) IN
		( SELECT 'CRH', CASH_RECEIPT_HISTORY_ID
		  FROM AR_CASH_RECEIPT_HISTORY
		  WHERE CASH_RECEIPT_ID = p_source_id_int_1
		  UNION ALL
		  SELECT 'RA', RECEIVABLE_APPLICATION_ID
		  FROM AR_RECEIVABLE_APPLICATIONS
		  WHERE CASH_RECEIPT_ID = p_source_id_int_1 )
      AND source_type NOT IN ('UNID');
    ELSE
      RAISE fnd_api.g_exc_error;

    END IF;

  END IF;

  arp_standard.debug('update_cr_dist -');

EXCEPTION

WHEN creation_mode        THEN
 arp_standard.debug('EXCEPTION creation_mode : CREATION MODE');
 x_errbuf        := 'CREATION MODE';
 x_retcode       := 'S';
  arp_standard.debug('update_cr_dist -');

WHEN no_existing_account  THEN
 arp_standard.debug('EXCEPTION no_existing_account : NO ORIGINAL CUSTOMER');
 x_errbuf        := 'NO ORIGINAL CUSTOMER';
 x_retcode       := 'S';
  arp_standard.debug('update_cr_dist -');

WHEN OTHERS  THEN
 arp_standard.debug('EXCEPTION OTHERS :'||SQLERRM);
 x_errbuf        := 'SQLERRM';
 x_retcode       := 'U';

END;



PROCEDURE check_period_open
(p_entity_id        IN         NUMBER,
 x_return_status    OUT NOCOPY VARCHAR2,
 x_msg_count        OUT NOCOPY NUMBER,
 x_msg_data         OUT NOCOPY VARCHAR2)
IS
  CURSOR c_verif_date(p_entity_id   IN NUMBER) IS
  SELECT e.event_date
    FROM xla_events                   e,
         xla_transaction_entities_upg t
   WHERE e.application_id      = 222
     AND e.entity_id           = p_entity_id
     AND t.application_id      = 222
     AND t.entity_id           = e.entity_id
--    AND e.process_status_code = 'U'
     AND e.event_status_code  IN ('U','I')
     AND NOT EXISTS
      (SELECT 'Y'
         FROM gl_period_statuses  glp
        WHERE glp.application_id = 222
          AND e.event_date BETWEEN glp.start_date AND glp.end_date
          AND glp.set_of_books_id = t.ledger_id
          AND glp.closing_status IN ('O','F'));

  l_date      DATE;
BEGIN
  arp_standard.debug('check_period_open +');
  x_return_status  := FND_API.g_ret_sts_success;

  OPEN c_verif_date(p_entity_id);
  FETCH c_verif_date INTO l_date;
  IF c_verif_date%FOUND THEN
    x_return_status  := FND_API.g_ret_sts_error;
    arp_standard.debug(' event_date :' || l_date);
    FND_MESSAGE.SET_NAME('AR','AR_NOT_OPEN_PERIOD_EXISTS');
    FND_MSG_PUB.ADD; --BUG#5386043
  END IF;
  CLOSE c_verif_date;

  IF x_return_status  <> FND_API.g_ret_sts_success THEN
    RAISE fnd_api.G_EXC_ERROR;
  END IF;
  arp_standard.debug('check_period_open -');
EXCEPTION
  WHEN fnd_api.G_EXC_ERROR THEN
    arp_standard.debug('EXCEPTION G_EXC_ERROR');
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                              p_count   => x_msg_count,
                              p_data    => x_msg_data);
  WHEN OTHERS THEN
    arp_standard.debug('EXCEPTION OTHERS:'|| SQLERRM);
    x_return_status  := FND_API.g_ret_sts_error;
    x_msg_data       := SQLERRM;
    x_msg_count      := 1;
END;


END;

/
