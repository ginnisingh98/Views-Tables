--------------------------------------------------------
--  DDL for Package Body AR_CMGT_REASSIGN_CONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CMGT_REASSIGN_CONC" AS
/* $Header: ARCMRACB.pls 115.3 2003/10/10 14:23:33 mraymond noship $ */

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE reassign_credit_analyst(
       errbuf                           IN OUT NOCOPY VARCHAR2,
       retcode                          IN OUT NOCOPY VARCHAR2,
       p_credit_analyst_id_from         IN VARCHAR2,
       p_credit_analyst_id_to           IN VARCHAR2,
       p_assign_status                  IN VARCHAR2,
       p_start_date                     IN VARCHAR2,
       p_end_date                       IN VARCHAR2
  ) IS

--Declare Local variables
  l_credit_analyst_id_from         NUMBER;
  l_credit_analyst_id_to           NUMBER;
  l_assign_status                  VARCHAR2(30);
  l_start_date                     DATE;
  l_end_date                       DATE;

  l_cf_return_status               VARCHAR2(1);
  l_req_return_status              VARCHAR2(1);
  l_prof_return_status             VARCHAR2(1);

BEGIN

     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('ar_cmgt_reassign_conc.reassign_credit_analyst (+) ');
     END IF;

   --Print all input variables
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('reassign_credit_analyst: ' || 'p_credit_analyst_id_from  :'||p_credit_analyst_id_from);
        arp_util.debug('reassign_credit_analyst: ' || 'p_credit_analyst_id_to    :'||p_credit_analyst_id_to);
        arp_util.debug('reassign_credit_analyst: ' || 'p_assign_status           :'||p_assign_status);
        arp_util.debug('reassign_credit_analyst: ' || 'p_start_date              :'||p_start_date);
        arp_util.debug('reassign_credit_analyst: ' || 'p_end_date                :'||p_end_date);
     END IF;

   --Convert the IN variables
     l_credit_analyst_id_from         := FND_NUMBER.CANONICAL_TO_NUMBER(p_credit_analyst_id_from);
     l_credit_analyst_id_to           := FND_NUMBER.CANONICAL_TO_NUMBER(p_credit_analyst_id_to);
     l_assign_status                  := p_assign_status;
     l_start_date                     := FND_DATE.CANONICAL_TO_DATE(p_start_date);
     l_end_date                       := FND_DATE.CANONICAL_TO_DATE(p_end_date);

   --Intialize the out NOCOPY variable
     l_cf_return_status  :=  FND_API.G_RET_STS_SUCCESS;
     l_req_return_status :=  FND_API.G_RET_STS_SUCCESS;
     l_prof_return_status :=  FND_API.G_RET_STS_SUCCESS;

   --Issue Save point
     SAVEPOINT assign_analyst_pvt;

     IF (NVL(l_assign_status,'NONE') = 'PERMANENT')
     THEN

     --Update pending case folders
       BEGIN
         UPDATE ar_cmgt_case_folders
         SET    credit_analyst_id = l_credit_analyst_id_to
         WHERE  credit_analyst_id = l_credit_analyst_id_from
         AND    status in ('CREATED','SAVED');
       EXCEPTION
         WHEN others THEN
          l_cf_return_status :=  FND_API.G_RET_STS_ERROR;
       END;

     --Update pending credit requests
       BEGIN
         UPDATE ar_cmgt_credit_requests
         SET    credit_analyst_id = l_credit_analyst_id_to
         WHERE  credit_analyst_id = l_credit_analyst_id_from
         AND    status in ('IN_PROCESS','SAVED','SUBMIT');
       EXCEPTION
         WHEN others THEN
          l_req_return_status :=  FND_API.G_RET_STS_ERROR;
       END;

     ELSIF (NVL(l_assign_status,'NONE') = 'TEMPORARY') THEN

       IF l_end_date is null THEN

          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug('reassign_credit_analyst: ' || 'End should be enterted, if it is temporary assignment ');
          END IF;
          FND_MESSAGE.SET_NAME('AR','AR_DEPOSIT_UI_ED_DATE_INV');
          FND_MSG_PUB.Add;
          ROLLBACK TO assign_analyst_pvt;
          app_exception.raise_exception;

      END IF;

     --Update pending case folders
       BEGIN
         UPDATE ar_cmgt_case_folders
         SET    credit_analyst_id = l_credit_analyst_id_to
         WHERE  credit_analyst_id = l_credit_analyst_id_from
         AND    creation_date_time between NVL(l_start_date,creation_date_time)
                                           AND NVL(l_end_date,creation_date_time)
         AND    status in ('CREATED','SAVED');
       EXCEPTION
         WHEN others THEN
          l_cf_return_status :=  FND_API.G_RET_STS_ERROR;
       END;

     --Update pending credit requests
       BEGIN
         UPDATE ar_cmgt_credit_requests
         SET    credit_analyst_id = l_credit_analyst_id_to
         WHERE  credit_analyst_id = l_credit_analyst_id_from
         AND    creation_date between NVL(l_start_date,creation_date)
                                           AND NVL(l_end_date,creation_date)
         AND    status in ('IN_PROCESS','SAVED','SUBMIT');
       EXCEPTION
         WHEN others THEN
          l_req_return_status :=  FND_API.G_RET_STS_ERROR;
       END;

     END IF;

   --Update customer profile
     BEGIN
       UPDATE hz_customer_profiles
       SET    credit_analyst_id = l_credit_analyst_id_to
       WHERE  credit_analyst_id = l_credit_analyst_id_from;
     EXCEPTION
       WHEN others THEN
         l_prof_return_status :=  FND_API.G_RET_STS_ERROR;
     END;

     IF l_cf_return_status <> FND_API.G_RET_STS_SUCCESS OR
        l_req_return_status <> FND_API.G_RET_STS_SUCCESS OR
        l_prof_return_status <> FND_API.G_RET_STS_SUCCESS
     THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION: ' ||'ar_cmgt_reassign_conc.reassign_credit_analyst :'||SQLERRM);
        END IF;
        ROLLBACK TO assign_analyst_pvt;
        app_exception.raise_exception;
     END IF;

     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('ar_cmgt_reassign_conc.reassign_credit_analyst (-) ');
     END IF;

END reassign_credit_analyst;

END AR_CMGT_REASSIGN_CONC;

/
