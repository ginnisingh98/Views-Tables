--------------------------------------------------------
--  DDL for Package Body AR_FIRSTPARTY_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_FIRSTPARTY_UTILS" AS
/* $Header: ARXLESTB.pls 120.1 2004/03/01 19:15:12 mraymond noship $ */


-----------------------------------------------------------------
-- PROCEDURE GET_LEGAL_ENTITY_ID_OU
-- Use this instead of XLE_FIRSTPARTY_UTILS.GET_LEGAL_ENTITY_ID_OU
--  to retrieve the value of legal_entity_id for org_id
-----------------------------------------------------------------
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE GET_LEGAL_ENTITY_ID_OU
	(p_operating_unit   IN number,
	 p_legal_entity_id  OUT NOCOPY number
	) is
l_legal_entity_id number;
BEGIN
 p_legal_entity_id := p_operating_unit;
 --Above call will be replaced by XLE_FIRSTPARTY_UTILS.GET_LEGAL_ENTITY_ID_OU
 -- as commented below
/*
XLE_FIRSTPARTY_UTILS.GET_LEGAL_ENTITY_ID_OU(p_operating_unit,l_legal_entity_id);
p_legal_entity_id := l_legal_entity_id;
*/
EXCEPTION
 when no_data_found then
   IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug('EXCEPTION: XLE_FIRSTPARTY_UTILS.GET_LEGAL_ENTITY_ID_OU no_data_found');
    RAISE;
   END IF;
 when others then
   IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug('EXCEPTION: XLE_FIRSTPARTY_UTILS.GET_LEGAL_ENTITY_ID_OU others');
    RAISE;
   END IF;
END GET_LEGAL_ENTITY_ID_OU;



END AR_FIRSTPARTY_UTILS;

/
