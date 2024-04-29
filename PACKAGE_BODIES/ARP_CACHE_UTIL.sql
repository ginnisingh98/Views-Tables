--------------------------------------------------------
--  DDL for Package Body ARP_CACHE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CACHE_UTIL" AS
/* $Header: ARXCAUTB.pls 120.2.12010000.1 2008/07/24 16:59:50 appldev ship $ */

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE refresh_cache IS

BEGIN

  IF PG_DEBUG = 'Y' THEN
     arp_util.debug('arp_cache_util.Refresh_Cache()+');
  END IF;

  -- if the org_id has not changed, then do nothing, return.
  -- arp_global.init_global is called in several places, so not
  -- relying on sysparam record type, but checking if the  all other
  -- cache/global variables are refreshed

    IF (arp_trx_global.system_info.system_parameters.org_id is null
          and ((substrb(userenv('CLIENT_INFO'),1,1) = ' ')
               or (userenv('CLIENT_INFO') is null))) THEN
         IF PG_DEBUG = 'Y' THEN
           arp_util.debug('Non Multi-Org; '||
             'Trx Global org_id is null as well as  CLIENT_INFO org');
         END IF;

         IF arp_trx_global.system_info.system_parameters.set_of_books_id IS NOT NULL THEN
           IF PG_DEBUG = 'Y' THEN
             arp_util.debug('Non Multi-Org and cache exists ');
             arp_util.debug('SOB from arp_global is '|| arp_global.sysparam.set_of_books_id
                  || ' , SOB from trx_global is '|| arp_trx_global.system_info.system_parameters.set_of_books_id);
             arp_util.debug('Not Refreshing Cache');
           END IF;

           return;

         END IF;
    --5885313 compare with current operating unit because ARP_GLOBal itself initialized arp_trx_global
    ELSIF ( (arp_trx_global.system_info.system_parameters.org_id is not null)
        and (substrb(userenv('CLIENT_INFO'),1,1) <> ' ')
        and (pg_old_org_id =
              to_number(substrb(userenv('CLIENT_INFO'),1,10)))) THEN
         IF PG_DEBUG = 'Y' THEN
           arp_util.debug('Org from CLIENT_INFO matches Trx Global org');
           arp_util.debug(' Org from arp_global is ' || arp_global.sysparam.org_id
                  || ' , SOB from arp_global is '|| arp_global.sysparam.set_of_books_id
                  || ' , SOB from trx_global is '|| arp_trx_global.system_info.system_parameters.set_of_books_id);
           arp_util.debug('Not Refreshing Cache');
         END IF;
        return;
    END IF;

  -- Otherwise cache does not exist or
  -- Cache is incorrect, so need to be refreshed

  IF PG_DEBUG = 'Y' THEN
     arp_util.debug('Refreshing Cache');
  END IF;

  ARP_TRX_GLOBAL.init;
  ARP_PROCESS_CREDIT_UTIL.init;
  ARP_TRX_UTIL.init;
  ARPCURR.init;
  ARP_TRX_DEFAULTS_2.init;
  ARP_TRX_DEFAULTS_3.init;
  ARP_PROCESS_CREDIT.init;
  ARP_AUTO_ACCOUNTING.init;
  ARP_PROCESS_HEADER.init;
  ARP_CTLS_PKG.init;
  ARP_PROCESS_FREIGHT.init;
  ARP_CREDIT_MEMO_MODULE.init;
  -- ARP_TAX.initialize; -- obsolete
  ARP_PROCESS_HEADER_POST_COMMIT.init;
  ARP_TRX_VALIDATE.init;
  ARP_TRX_COMPLETE_CHK.init;
  ARP_MAINTAIN_PS.init;
  ARP_MAINTAIN_PS2.init;
  -- AR_MC_INFO.init;    -- obsolete
  --5885313 set variable to current org
  PG_OLD_ORG_ID := arp_trx_global.system_info.system_parameters.org_id;
  IF PG_DEBUG = 'Y' THEN
     arp_util.debug('arp_cache_util.Refresh_Cache()-');
  END IF;

END refresh_cache;

END arp_cache_util;

/
