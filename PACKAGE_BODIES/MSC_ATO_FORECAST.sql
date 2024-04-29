--------------------------------------------------------
--  DDL for Package Body MSC_ATO_FORECAST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_ATO_FORECAST" AS -- body
/* $Header: MSCATOFB.pls 115.0 2003/07/10 04:10:26 pmotewar noship $ */

FUNCTION   OC_COM_RT_EXISTS (
               p_inventory_item_id   IN  NUMBER,
               p_org_id              IN  NUMBER,
               p_sr_instance_id      IN  NUMBER,
               p_routing_sequence_id IN  NUMBER,
               p_bom_item_type       IN  NUMBER
              ) RETURN NUMBER
   IS
   G_OPTION_CLASS NUMBER := 2;
   G_MODEL NUMBER := 1;
   l_parent_item_id NUMBER;
   l_common_rout_seq_id NUMBER;
   l_parent_item_type NUMBER;
   SYS_YES NUMBER := 1;
   SYS_NO  NUMBER := 2;

   BEGIN

       /* Return FALSE if the item is not an Option Class */
       IF (nvl(p_bom_item_type,-1) <> G_OPTION_CLASS) THEN
           RETURN SYS_NO;
       END IF;

       /* Get the common_routing_sequence_id for given option class */
       SELECT common_routing_sequence_id into l_common_rout_seq_id
       from msc_routings mr
       where mr.plan_id = -1
       and   mr.sr_instance_id = p_sr_instance_id
       and   mr.organization_id = p_org_id
       and   mr.assembly_item_id = p_inventory_item_id;

       /* Return FALSE if the item does not have common routing sequence */
       IF (nvl(l_common_rout_seq_id, -1) = -1) THEN
           return SYS_NO;
       END IF;

       /* If common routing exists then return true only if the assembly item of this common
          routing is an ATO model */
       select bom_item_type into l_parent_item_type
       from msc_system_items msi,
            msc_routings mr
       where mr.routing_sequence_id = l_common_rout_seq_id
       and   mr.sr_instance_id = p_sr_instance_id
       and   mr.plan_id = -1
       and   mr.organization_id = p_org_id
       and   msi.inventory_item_id = mr.assembly_item_id
       and   msi.sr_instance_id = mr.sr_instance_id
       and   msi.organization_id = mr.organization_id
       and   msi.plan_id = mr.plan_id;

       IF (nvl(l_parent_item_type, -1) = G_MODEL) THEN
           return SYS_YES;
       ELSE
           return SYS_NO;
       END IF;

   EXCEPTION WHEN OTHERS THEN
       RETURN SYS_NO;
   END OC_COM_RT_EXISTS;

END MSC_ATO_FORECAST;

/
