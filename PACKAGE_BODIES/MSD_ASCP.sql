--------------------------------------------------------
--  DDL for Package Body MSD_ASCP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_ASCP" AS
/* $Header: msdascpb.pls 115.7 2002/05/10 17:01:30 pkm ship      $ */

function partner_id(p_level_id	     VARCHAR2,
                    p_level_pk 	     VARCHAR2)   RETURN NUMBER IS

v_ret NUMBER := null;
v_parent_pk NUMBER;

BEGIN

  IF p_level_id = 15 THEN
    select mtp.partner_id into v_ret
    from msc_trading_partners mtp, msd_level_values mlv
    where  mtp.sr_instance_id = mlv.instance
      and  mlv.level_id       = p_level_id
      and  mlv.level_pk       = p_level_pk
      and  mtp.partner_type   = 2
      and  mtp.sr_tp_id       = mlv.sr_level_pk;
 ELSIF p_level_id = 11 THEN
    select mtp.partner_id into v_ret
    from msc_trading_partners mtp,
         msd_level_values site,
         msd_level_associations mla
    where  site.level_id         = 11
      and  site.level_pk         = p_level_pk
      and  site.instance         = mla.instance
      and  site.sr_level_pk      = mla.sr_level_pk
      and  mtp.partner_type      = 2
      and  to_char(mtp.sr_tp_id) = mla.sr_parent_level_pk
      and  mtp.sr_instance_id    = site.instance;
  END IF;

  return v_ret;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return null;

END partner_id;


function partner_site_id(p_level_id  VARCHAR2,
                         p_level_pk  VARCHAR2)   RETURN NUMBER IS

v_ret NUMBER := null;
v_sr_parent_pk NUMBER;

BEGIN

  IF p_level_id = 11 THEN
   /* look up unique reference in tps */
    select distinct mtps.partner_site_id into v_ret
    from msc_trading_partner_sites mtps,
         msd_level_values site,
         msd_level_associations mla
    where  site.level_id       = p_level_id
      and  site.level_pk       = p_level_pk
      and  mtps.sr_instance_id = site.instance
      and  mtps.partner_type   = 2
      and  mtps.sr_tp_site_id  = site.sr_level_pk
      and  mtps.sr_tp_id       = mla.sr_parent_level_pk
      /* and the customer is... */
      and  mla.sr_level_pk     = site.sr_level_pk
      and  mla.level_id        = 11
      and  mla.parent_level_id = 15
      and  mla.instance        = site.instance;
  END IF;

  return v_ret;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return null;

END partner_site_id;

END MSD_ASCP;

/
