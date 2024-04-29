--------------------------------------------------------
--  DDL for Package Body ASP_ALERTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASP_ALERTS_PUB" as
/* $Header: asppaltb.pls 120.6 2005/10/10 17:17 axavier noship $ */
---------------------------------------------------------------------------
-- Package Name:   ASP_ALERTS_PUB
---------------------------------------------------------------------------
-- Description:
--      Public package for Sales Alerts Related Business logic.
--
-- Procedures:
--   (see the specification for details)
--
-- History:
--   08-Aug-2005  axavier created.
---------------------------------------------------------------------------

/*-------------------------------------------------------------------------*
 |                             Private Constants
 *-------------------------------------------------------------------------*/
G_PKG_NAME  CONSTANT VARCHAR2(30):= 'ASP_ALERTS_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asppaltb.pls';

G_MAX_FETCHES  CONSTANT NUMBER := 10000;


/*-------------------------------------------------------------------------*
 |                             Private Datatypes
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |                             Private Variables
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |                             Private Routines Specification
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |                             Public Routines
 *-------------------------------------------------------------------------*/

--------------------------------------------------------------------------------
--  Procedure: Get_Matching_Subscriptions
--   This method returns all the subscribers of a given Alert.
--
--------------------------------------------------------------------------------

PROCEDURE Get_Matching_Subscriptions (
  p_api_version_number  IN  NUMBER,
  p_init_msg_list       IN  VARCHAR2   DEFAULT  FND_API.G_FALSE,
  p_alert_code          IN  VARCHAR2,
  p_customer_id         IN  NUMBER,
  x_subscriber_list     OUT NOCOPY  SUBSCRIBER_TBL_TYPE,
  x_return_status       OUT NOCOPY  VARCHAR2,
  x_msg_count           OUT NOCOPY  NUMBER,
  x_msg_data            OUT NOCOPY  VARCHAR2)
IS
  l_errbuf   VARCHAR2(4000);
  l_errcode  VARCHAR2(30);
  l_debug_module  VARCHAR2(100);
  l_debug_level number;
  l_debug_proc_level number;
  l_debug_unexp_level number;

  cursor get_subs(c_alert_code in VARCHAR2) is
    select
      sub.subscription_id,
      sub.subscriber_name,
      sub.delivery_channel,
      sub.user_id
    from
      asp_alert_subscriptions sub
    where sub.alert_code = c_alert_code;

  cursor get_subs_secured(c_alert_code in VARCHAR2, c_customer_id in NUMBER) is
    select
      sub.subscription_id,
      sub.subscriber_name,
      sub.delivery_channel,
      sub.user_id
    from
      asp_alert_subscriptions sub,
      (select salesforce_id
       from as_accesses_all
       where customer_id = c_customer_id
         and lead_id is null
         and sales_lead_id is null
       group by salesforce_id) acc
    where sub.alert_code = c_alert_code
          and sub.resource_id = acc.salesforce_id;


BEGIN
  l_debug_module := 'asp.plsql.ASP_ALERTS_PUB.Get_Matching_Subscriptions.Begin';
  l_debug_level :=FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_debug_proc_level := FND_LOG.LEVEL_PROCEDURE;
  l_debug_unexp_level := FND_LOG.LEVEL_UNEXPECTED;
  if(l_debug_proc_level >= l_debug_level) then
    fnd_log.string(l_debug_proc_level, l_debug_module, 'Entering Get_Matching_Subscriptions' );
  end if;


  -- Initialize message list IF p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN get_subs_secured(p_alert_code, p_customer_id);
  FETCH get_subs_secured BULK COLLECT INTO
        x_subscriber_list
  LIMIT G_MAX_FETCHES;
  CLOSE get_subs_secured;

  if(l_debug_proc_level >= l_debug_level) then
    fnd_log.string(l_debug_proc_level, l_debug_module, 'After opening Cursor get_subs_secured' );
  end if;

  -- Standard call to get message count and IF count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(
    p_count => x_msg_count,
    p_data  => x_msg_data );

  l_debug_module := 'asp.plsql.ASP_ALERTS_PUB.Get_Matching_Subscriptions.End';
  if(l_debug_proc_level >= l_debug_level) then
    fnd_log.string(l_debug_proc_level, l_debug_module, 'End Get_Matching_Subscriptions' );
  end if;


EXCEPTION
WHEN NO_DATA_FOUND THEN
  l_debug_module := 'asp.plsql.ASP_ALERTS_PUB.Get_Matching_Subscriptions.NO_DATA_FOUND';
  if(l_debug_proc_level >= l_debug_level) then
    fnd_log.string(l_debug_proc_level, l_debug_module, 'Exception: NO_DATA_FOUND' );
  end if;
  if get_subs_secured%ISOPEN then CLOSE get_subs_secured; end if;
  FND_MSG_PUB.Count_And_Get(
    p_count => x_msg_count,
    p_data  => x_msg_data );
WHEN OTHERS THEN
  --Print_Debug('Exception: others in ASP_ALERTS_PUB::Get_Matching_Subscriptions');
  --Print_Debug();

  l_errbuf  := SQLERRM;
  l_errcode := to_char(SQLCODE);

  l_debug_module := 'asp.plsql.ASP_ALERTS_PUB.Get_Matching_Subscriptions.OTHERS';
  if(l_debug_unexp_level >= l_debug_level) then
    fnd_log.string(l_debug_unexp_level, l_debug_module, 'Exception: OTHERS - '||
                   'SQLCODE: ' || to_char(SQLCODE) || ' SQLERRM: ' || SQLERRM
                   );
  end if;

  x_return_status := FND_API.G_RET_STS_ERROR;
  if get_subs_secured%ISOPEN then CLOSE get_subs_secured; end if;
  FND_MSG_PUB.Count_And_Get(
    p_count => x_msg_count,
    p_data  => x_msg_data );

END Get_Matching_Subscriptions;


End ASP_ALERTS_PUB;

/
