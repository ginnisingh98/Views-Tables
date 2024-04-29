--------------------------------------------------------
--  DDL for Package Body EDR_ERES_EVENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDR_ERES_EVENT_PUB" AS
/* $Header: EDRPEVTB.pls 120.3.12000000.1 2007/01/18 05:54:30 appldev ship $*/

-- Private Utility Functions and/or procedures --

/** Validate if the event name exists in the WF_EVENTS table **/

FUNCTION VALID_EVENT_NAME (p_event_name IN varchar2)
  return BOOLEAN
is
  cursor l_count_csr is
  select count(*)
  from wf_events_vl
  where name = p_event_name;

  l_count NUMBER;

  l_return_value boolean := FALSE;
begin
  open l_count_csr;

  fetch l_count_csr into l_count;

  if (l_count > 0) THEN
    l_return_value := TRUE;
  END IF;

  close l_count_csr;

  return l_return_value;

end VALID_EVENT_NAME;

/** Read the individual statuses of the eres events in a table and
    provide an overall status
**/

FUNCTION GET_OVERALL_STATUS
( p_events  IN  ERES_EVENT_TBL_TYPE)
RETURN VARCHAR2

IS
  l_total_events    pls_integer;
  l_status    varchar2(20)  ;
  l_count     pls_integer   := 0;
  l_overall_status  VARCHAR2(20);
  i     pls_integer;
BEGIN
  l_status := EDR_CONSTANTS_GRP.g_indetermined_status;
  --read the status of each of the events and maintain a count
  l_total_events := p_events.COUNT;

  if (l_total_events > 0) then
    i := p_events.FIRST;

    --keep on adding to the count till there is no
    --break on the status value
    while i is not null loop
      if (p_events(i).event_status = l_status
       OR l_status = EDR_CONSTANTS_GRP.g_indetermined_status)
      then
        l_status := p_events(i).event_status;
        l_count := l_count + 1;
      else
        EXIT;
      end if;
      i := p_events.NEXT(i);
    end loop;

    --if the status was not all the same the counts would
    --differ and overall status would be INDETERMINED

    if (l_count = l_total_events) then
      l_overall_status := l_status;
    else
      l_overall_status
        := EDR_CONSTANTS_GRP.g_indetermined_status;
    end if;

  end if;

  if l_overall_status = EDR_CONSTANTS_GRP.g_no_action_status
  then
    l_overall_status := EDR_CONSTANTS_GRP.g_complete_status;
  end if;

  return l_overall_status;

END GET_OVERALL_STATUS;

/** Validate that the parent-child relationship defined in the subscription
 ** parameters of an event is valid or not
 ** IN: p_event_name            IN VARCHAR2(80)
 **       child event name
 **     p_parent_event_name     IN VARCHAR2(80)
 **       parent event name
 ** OUT: Boolean TRUE or FALSE
 **/

FUNCTION VALIDATE_RELATIONSHIP
( p_event_name    IN  VARCHAR2       ,
  p_parent_event_name IN  VARCHAR2
)
RETURN BOOLEAN
AS
  l_return_value  BOOLEAN := TRUE ;
  l_sub_guid  RAW(16)   ;
  l_relationship  VARCHAR2(200) ;
BEGIN
  --get the guid of the parent event
  l_sub_guid := EDR_ERES_EVENT_PVT.GET_SUBSCRIPTION_GUID
          (p_event_name   => p_parent_event_name);

  l_relationship :=
    EDR_INDEXED_XML_UTIL.GET_WF_PARAMS
    ( p_param_name    => p_event_name,
      p_event_guid    => l_sub_guid
    );

  l_relationship := upper(l_relationship);

  --l_relationship can have three possible values
  --EVALUATE_NORMAL, IGNORE_SIGNATURE, ERECORD_ONLY

  if (l_relationship is null          OR
      (l_relationship <> EDR_CONSTANTS_GRP.g_evaluate_normal  AND
       l_relationship <> EDR_CONSTANTS_GRP.g_erecord_only   AND
       l_relationship <> EDR_CONSTANTS_GRP.g_ignore_signature)
      )
  then
    l_return_value := FALSE;
  end if;

  RETURN l_return_value;

END VALIDATE_RELATIONSHIP;

-- Public APIs --

PROCEDURE VALIDATE_ERECORD
( p_api_version           IN  NUMBER        ,
  p_init_msg_list   IN  VARCHAR2      ,
  x_return_status   OUT NOCOPY VARCHAR2       ,
  x_msg_count     OUT NOCOPY NUMBER     ,
  x_msg_data      OUT NOCOPY VARCHAR2     ,
  p_erecord_id      IN  NUMBER
)
AS
  l_api_name  CONSTANT VARCHAR2(30) := 'VALIDATE_ERECORD';
  l_api_version   CONSTANT NUMBER   := 1.0;

  l_count      NUMBER;
  l_mesg_text      VARCHAR2(2000);

  cursor l_count_csr is
  SELECT COUNT(DOCUMENT_ID)
  FROM EDR_PSIG_DOCUMENTS
  WHERE DOCUMENT_ID = p_erecord_id;

BEGIN
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version         ,
              p_api_version         ,
              l_api_name          ,
              G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --  API Body
-- BEGIN Bug : 3834375. Added Secure context to allow query of all rows
         edr_ctx_pkg.set_secure_attr;
      -- END  Bug : 3834375
  open l_count_csr;
  fetch l_count_csr into l_count;
-- BEGIN Bug : 3834375. remove security context
         edr_ctx_pkg.unset_secure_attr;
      -- END  Bug : 3834375
  if (l_count = 0) then
    x_return_status := FND_API.G_RET_STS_ERROR;
  end if;

  close l_count_csr;

  --  End of API Body

  -- Standard call to get message count and if count is 1, get
  --message info.
  FND_MSG_PUB.Count_And_Get
      (   p_count         =>      x_msg_count       ,
          p_data          =>      x_msg_data
      );

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    FND_MSG_PUB.Count_And_Get
        (  p_count          =>      x_msg_count     ,
             p_data           =>      x_msg_data
        );

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
              FND_MSG_PUB.Add_Exc_Msg
              ( G_PKG_NAME        ,
                l_api_name
          );
    END IF;

    FND_MSG_PUB.Count_And_Get
        (   p_count           =>      x_msg_count     ,
            p_data            =>      x_msg_data
    );

END VALIDATE_ERECORD;


/*** Determine if the payload to an ERES event is valid or not ***/

PROCEDURE VALIDATE_PAYLOAD
( p_api_version             IN  NUMBER          ,
  p_init_msg_list   IN  VARCHAR2                                ,
  x_return_status   OUT NOCOPY VARCHAR2         ,
  x_msg_count     OUT NOCOPY NUMBER       ,
  x_msg_data      OUT NOCOPY VARCHAR2       ,
  p_event_name      IN  VARCHAR2        ,
  p_event_key     IN  VARCHAR2        ,
  p_payload       IN  fnd_wf_event.param_table    ,
  p_mode      IN  VARCHAR2
)
AS
  l_api_name  CONSTANT VARCHAR2(30) := 'VALIDATE_PAYLOAD';
  l_api_version   CONSTANT NUMBER   := 1.0;

  l_param_name     varchar2(30);
  l_param_value      varchar2(2000);
  l_error_param_name   varchar2(30);
  l_error_param_value    varchar2(2000);

  l_count      pls_integer  := 0;
  l_inter_event_count    pls_integer  := 0;
  l_source     varchar2(30);
  l_deferred     varchar2(15);
  l_parent_event_name    varchar2(240);
  l_parent_event_key   varchar2(2000);
  l_parent_erecord_id  number;
  i      pls_integer;

  l_mesg_text      VARCHAR2(2000);
  l_return_status    VARCHAR2(1);
  l_msg_count    NUMBER;
  l_msg_data     VARCHAR2(2000);

    l_event_name     VARCHAR2(80);
    l_event_key    VARCHAR2(240);
    l_error_event  varchar2(240);

  l_no_enabled_eres_sub NUMBER;

  l_valid_relationship   BOOLEAN  := TRUE;

  INVALID_SOURCE_ERROR    EXCEPTION;
  INVALID_PAYLOAD_ERROR     EXCEPTION;
  DEFERRED_DB_ERROR     EXCEPTION;
  INTEREVENT_PARAM_ERROR    EXCEPTION;
  INTEREVENT_DB_PARAM_ERROR   EXCEPTION;
  PARENT_ERECORD_ID_ERROR   EXCEPTION;
  PARENT_EVENT_ERROR    EXCEPTION;
  DEFERRED_PARAM_ERROR    EXCEPTION;
  INVALID_PARAM_ERROR   EXCEPTION;
  BAD_RELATIONSHIP_ERROR    EXCEPTION;

BEGIN
  -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (l_api_version         ,
                                p_api_version         ,
                          l_api_name          ,
                          G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --  API Body

  -- Bug Start: 5087502
  -- Verify if an active ERES subscription is available for current event.
     select count(*)  INTO l_no_enabled_eres_sub
       from wf_events a, wf_event_subscriptions b
       where a.GUID = b.EVENT_FILTER_GUID
       and a.name = p_event_name
       and b.RULE_FUNCTION='EDR_PSIG_RULE.PSIG_RULE'
       and b.STATUS = 'ENABLED'
       and b.source_type = 'LOCAL'
       and b.system_guid = hextoraw(wf_core.translate('WF_SYSTEM_GUID')) ;

      IF l_no_enabled_eres_sub = 0 THEN
      --Diagnostics Start
        if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_MESSAGE.SET_NAME('EDR','EDR_VAL_NO_ERES_SUBSCRIPTIONS');
          FND_MESSAGE.SET_TOKEN('EVENT_NAME',p_event_name);
          FND_MESSAGE.SET_TOKEN('EVENT_KEY',p_event_key);
          FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,
                    'edr.plsql.EDR_ERES_EVENT_PUB.VALIDATE_PAYLOAD',
                    FALSE
                   );
        end if;
      --Diagnostics End
      END IF;

  IF l_no_enabled_eres_sub > 0 THEN
  --  read each of the payload parameters and validate
    i := p_payload.FIRST;
  while i is not null loop
    l_param_name := p_payload(i).Param_Name;
    l_param_value := p_payload(i).Param_Value;

    if (l_param_name = EDR_CONSTANTS_GRP.g_source_param) then
      l_source := l_param_value;

      if (l_source = EDR_CONSTANTS_GRP.g_db_mode
       OR l_source = EDR_CONSTANTS_GRP.g_forms_mode
       OR l_source = EDR_CONSTANTS_GRP.g_oaf_mode)
      then
        l_count := l_count + 1;
      else
        RAISE INVALID_SOURCE_ERROR;
      end if;
    end if;

    if (l_param_name = EDR_CONSTANTS_GRP.g_deferred_param) then
      l_deferred := l_param_value;

      if (l_deferred = 'Y' OR l_deferred = 'N') then
        l_count := l_count + 1;
      else
        RAISE DEFERRED_PARAM_ERROR;
      end if;
    end if;

    if (l_param_name = EDR_CONSTANTS_GRP.g_postop_param) then
      l_count := l_count + 1;
    end if;

    if (l_param_name = EDR_CONSTANTS_GRP.g_user_label_param) then
      l_count := l_count + 1;
    end if;

    if (l_param_name = EDR_CONSTANTS_GRP.g_user_value_param) then
      l_count := l_count + 1;
    end if;

    if (l_param_name = EDR_CONSTANTS_GRP.g_audit_param) then
      l_count := l_count + 1;
    end if;

    if (l_param_name = EDR_CONSTANTS_GRP.g_requester_param) then
      l_count := l_count + 1;
    end if;

    -- additional parameters for inter event processing --
    if (l_param_name = EDR_CONSTANTS_GRP.g_parent_event_name)
    then
      l_parent_event_name := l_param_value;
      IF NOT valid_event_name(l_parent_event_name) then
        l_error_param_name := l_param_name;
        l_error_param_value := l_param_value;
        RAISE INVALID_PARAM_ERROR;
      END IF;

      -- validate the relationship defined in the
      -- parent event
      l_valid_relationship :=
        VALIDATE_RELATIONSHIP
        (p_event_name   => p_event_name,
         p_parent_event_name  => l_parent_event_name
        );

      if not l_valid_relationship then
        RAISE BAD_RELATIONSHIP_ERROR;
      end if;

      l_inter_event_count := l_inter_event_count + 1;
    end if;

    if (l_param_name = EDR_CONSTANTS_GRP.g_parent_event_key) then
      l_parent_event_key := l_param_value;

      IF l_parent_event_key is null  then
        l_error_param_name := l_param_name;
        l_error_param_value := l_param_value;
        RAISE INVALID_PARAM_ERROR;
      END IF;

      l_inter_event_count := l_inter_event_count + 1;
    end if;

    if (l_param_name = EDR_CONSTANTS_GRP.g_parent_erecord_id) then
                  --SKARIMIS
      /*As we are comparing to -1 we need to treate NULL also as -1   */
      l_parent_erecord_id := NVL(l_param_value,-1);

      if (l_parent_erecord_id <>
        EDR_CONSTANTS_GRP.g_default_num_param_value)
      then

        VALIDATE_ERECORD
        ( p_api_version     => 1.0,
            x_return_status   => l_return_status,
            x_msg_count       => l_msg_count,
          x_msg_data        => l_msg_data,
          p_erecord_id      => l_parent_erecord_id
        );

        -- If any errors happen abort API.
        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE PARENT_ERECORD_ID_ERROR;
        END IF;
      end if;

      l_inter_event_count := l_inter_event_count + 1;

    end if;

    i := p_payload.NEXT(i);

  end LOOP;



  if (l_count <> EDR_CONSTANTS_GRP.g_param_count)
  then
    RAISE INVALID_PAYLOAD_ERROR;
  elsif (p_mode = EDR_CONSTANTS_GRP.g_db_mode AND l_source <> EDR_CONSTANTS_GRP.g_db_mode)
  then
    RAISE DEFERRED_DB_ERROR;
  elsif (l_source = EDR_CONSTANTS_GRP.g_db_mode AND l_deferred <> 'Y')
  then
    RAISE DEFERRED_DB_ERROR;
  end if;

  END IF;
  -- Bug End: 5087502

  -- find out if right values are passed in the case of inter event


  if (l_inter_event_count > 0) then

         /* SKARIMIS bug fix 3135118 */
                if (p_event_name = l_parent_event_name) and (p_event_key = l_parent_event_key) then
      RAISE INTEREVENT_PARAM_ERROR;
    end if;
   /* End of Bug Fix */
    if (l_inter_event_count <> EDR_CONSTANTS_GRP.g_inter_event_param_count) then
      RAISE INTEREVENT_PARAM_ERROR;

    /* We will not perform this validating as we agreed on not bothering about parent erecord is being -1
             elsif (p_mode =  EDR_CONSTANTS_GRP.g_strict_mode
           AND   l_parent_erecord_id = EDR_CONSTANTS_GRP.g_default_num_param_value)
    then
      RAISE INTEREVENT_DB_PARAM_ERROR;
    */
    elsif (l_inter_event_count = EDR_CONSTANTS_GRP.g_inter_event_param_count
        AND l_parent_event_key = EDR_CONSTANTS_GRP.g_default_char_param_value)
    then
      l_error_param_name := EDR_CONSTANTS_GRP.g_parent_event_key;
      l_error_param_value := l_parent_event_key;
      RAISE INVALID_PARAM_ERROR;

    else
                       /* SKARIMIS . Addef id condition to get event details only for a valid erecord */
                     if l_parent_erecord_id <> EDR_CONSTANTS_GRP.g_default_num_param_value then
      EDR_ERES_EVENT_PUB.GET_EVENT_DETAILS
      ( p_api_version         => 1.0      ,
        x_return_status => l_return_status  ,
        x_msg_count   => l_msg_count    ,
        x_msg_data    => l_msg_data   ,
        p_erecord_id    => l_parent_erecord_id  ,
        x_event_name    => l_event_name   ,
        x_event_key     => l_event_key
      );

      if ( l_event_name <> l_parent_event_name
        OR l_event_key <> l_parent_event_key) then
        RAISE PARENT_EVENT_ERROR;
      end if;
                       end if;
    end if;
  end if;

  --  End of API Body

  -- Standard call to get message count and if count is 1,
  --get message info.
  FND_MSG_PUB.Count_And_Get
      (   p_count         =>      x_msg_count       ,
          p_data          =>      x_msg_data
      );

EXCEPTION
  WHEN INVALID_SOURCE_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;

    fnd_message.set_name('EDR','EDR_VAL_INVALID_SOURCE');
    fnd_message.set_token('EVENT_NAME', p_event_name);
    fnd_message.set_token('EVENT_KEY', p_event_key);
    l_mesg_text := fnd_message.get();

    FND_MSG_PUB.Add_Exc_Msg
    ( G_PKG_NAME        ,
      l_api_name        ,
      l_mesg_text
    );
    FND_MSG_PUB.Count_And_Get
        (  p_count        =>      x_msg_count     ,
             p_data         =>      x_msg_data
        );

    WHEN DEFERRED_PARAM_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;

    fnd_message.set_name('EDR','EDR_VAL_INVALID_DEFERRED');
    fnd_message.set_token('EVENT_NAME', p_event_name);
    fnd_message.set_token('EVENT_KEY', p_event_key);
    l_mesg_text := fnd_message.get();


    FND_MSG_PUB.Add_Exc_Msg
    ( G_PKG_NAME        ,
      l_api_name        ,
      l_mesg_text
    );
    FND_MSG_PUB.Count_And_Get
        (  p_count        =>      x_msg_count     ,
             p_data         =>      x_msg_data
        );

  WHEN INVALID_PAYLOAD_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;

    fnd_message.set_name('EDR','EDR_VAL_INVALID_PAYLOAD');
    fnd_message.set_token('EVENT_NAME', p_event_name);
    fnd_message.set_token('EVENT_KEY', p_event_key);
    l_mesg_text := fnd_message.get();

    FND_MSG_PUB.Add_Exc_Msg
    ( G_PKG_NAME        ,
      l_api_name        ,
      l_mesg_text
    );

    FND_MSG_PUB.Count_And_Get
        (  p_count        =>      x_msg_count     ,
             p_data         =>      x_msg_data
        );

      WHEN DEFERRED_DB_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;

    fnd_message.set_name('EDR','EDR_VAL_INVALID_DEFERRED');
    fnd_message.set_token('EVENT_NAME', p_event_name);
    fnd_message.set_token('EVENT_KEY', p_event_key);
    l_mesg_text := fnd_message.get();

    FND_MSG_PUB.Add_Exc_Msg
    ( G_PKG_NAME        ,
      l_api_name        ,
      l_mesg_text
    );

    FND_MSG_PUB.Count_And_Get
        (  p_count        =>      x_msg_count     ,
             p_data         =>      x_msg_data
        );

  WHEN INTEREVENT_PARAM_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;

    fnd_message.set_name('EDR','EDR_VAL_INVALID_INTER_EVENT');
    fnd_message.set_token('EVENT_NAME', p_event_name);
    fnd_message.set_token('EVENT_KEY', p_event_key);
    l_mesg_text := fnd_message.get();

    FND_MSG_PUB.Add_Exc_Msg
    ( G_PKG_NAME        ,
      l_api_name        ,
      l_mesg_text
    );

    FND_MSG_PUB.Count_And_Get
        (  p_count        =>      x_msg_count     ,
             p_data         =>      x_msg_data
        );

  WHEN INTEREVENT_DB_PARAM_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;

    fnd_message.set_name('EDR','EDR_VAL_INTER_EVENT_DB');
    fnd_message.set_token('EVENT_NAME', p_event_name);
    fnd_message.set_token('EVENT_KEY', p_event_key);
    l_mesg_text := fnd_message.get();

    FND_MSG_PUB.Add_Exc_Msg
    ( G_PKG_NAME        ,
      l_api_name        ,
      l_mesg_text
    );

    FND_MSG_PUB.Count_And_Get
        (  p_count        =>      x_msg_count     ,
             p_data         =>      x_msg_data
        );

  WHEN PARENT_ERECORD_ID_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;

    fnd_message.set_name('EDR','EDR_VAL_INVALID_PARENT_ID');
    fnd_message.set_token('ERECORD_ID', l_parent_erecord_id);
    fnd_message.set_token('EVENT_NAME', p_event_name);
    fnd_message.set_token('EVENT_KEY', p_event_key);
    l_mesg_text := fnd_message.get();

        FND_MSG_PUB.Add_Exc_Msg
    ( G_PKG_NAME        ,
              l_api_name          ,
              l_mesg_text
        );

    FND_MSG_PUB.Count_And_Get
        (  p_count          =>      x_msg_count     ,
             p_data           =>      x_msg_data
        );


  WHEN PARENT_EVENT_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;

    fnd_message.set_name('EDR','EDR_VAL_INVALID_PARENT_EVENT');
    fnd_message.set_token('EVENT_NAME', p_event_name);
    fnd_message.set_token('EVENT_KEY', p_event_key);
    fnd_message.set_token('CHILD_NAME', l_event_name);
    fnd_message.set_token('CHILD_KEY', l_event_key);

    l_mesg_text := fnd_message.get();

        FND_MSG_PUB.Add_Exc_Msg
    ( G_PKG_NAME        ,
              l_api_name          ,
              l_mesg_text
        );

    FND_MSG_PUB.Count_And_Get
        (  p_count          =>      x_msg_count     ,
             p_data           =>      x_msg_data
        );

  WHEN INVALID_PARAM_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;

    fnd_message.set_name('EDR','EDR_VAL_INVALID_PARAM');
    fnd_message.set_token('EVENT_NAME', p_event_name);
    fnd_message.set_token('EVENT_KEY', p_event_key);
    fnd_message.set_token('PARAM_NAME', l_error_param_name);
    fnd_message.set_token('PARAM_VALUE', l_error_param_value);
    l_mesg_text := fnd_message.get();

        FND_MSG_PUB.Add_Exc_Msg
    ( G_PKG_NAME        ,
              l_api_name          ,
              l_mesg_text
        );

    FND_MSG_PUB.Count_And_Get
        (  p_count          =>      x_msg_count     ,
             p_data           =>      x_msg_data
        );

  WHEN  BAD_RELATIONSHIP_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;

    FND_MESSAGE.SET_NAME('EDR','EDR_VAL_INVALID_RELATIONSHIP');
          FND_MESSAGE.SET_TOKEN('PARENT_EVENT', l_parent_event_name);
          FND_MESSAGE.SET_TOKEN('EVENT_NAME', p_event_name);
    fnd_message.set_token('EVENT_KEY', p_event_key);
    l_mesg_text := fnd_message.get();

        FND_MSG_PUB.Add_Exc_Msg
    ( G_PKG_NAME        ,
              l_api_name          ,
              l_mesg_text
        );

    FND_MSG_PUB.Count_And_Get
        (  p_count          =>      x_msg_count     ,
             p_data           =>      x_msg_data
        );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    FND_MSG_PUB.Count_And_Get
        (  p_count          =>      x_msg_count     ,
             p_data           =>      x_msg_data
        );

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
              FND_MSG_PUB.Add_Exc_Msg
              ( G_PKG_NAME  ,
              l_api_name
          );
    END IF;

    FND_MSG_PUB.Count_And_Get
        (p_count          =>      x_msg_count    ,
           p_data           =>      x_msg_data
        );

END VALIDATE_PAYLOAD;

/* Validate payload for call from forms and raise exceptions */

FUNCTION VALIDATE_PAYLOAD_FORMS
( p_event_name    IN    VARCHAR2    ,
  p_event_key   IN    VARCHAR2    ,
  p_payload     IN    fnd_wf_event.param_table
)
RETURN BOOLEAN
AS
  L_RETURN_STATUS   VARCHAR2(1);
  L_MSG_COUNT     NUMBER;
  L_MSG_index     NUMBER;
  L_MSG_data    VARCHAR2(2000);

  l_return_value boolean := false;
BEGIN
  EDR_ERES_EVENT_PUB.VALIDATE_PAYLOAD
  ( p_api_version         => 1.0      ,
    p_init_msg_list       => FND_API.G_TRUE ,
    x_return_status       => l_return_status  ,
    x_msg_count           => l_msg_count    ,
    x_msg_data            => l_msg_data   ,
    p_event_name          => p_event_name   ,
    p_event_key           => p_event_key    ,
    p_payload             => p_payload    ,
    p_mode                => null
  );

  if (l_msg_count > 1) then
    fnd_msg_pub.get
    ( p_data      => l_msg_data ,
      p_msg_index_out => l_msg_index
    );
  end if;

  -- If any errors happen abort API.
  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    fnd_message.set_encoded(l_msg_data);
    APP_EXCEPTION.RAISE_EXCEPTION;

  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
    fnd_message.set_encoded(l_msg_data);
    APP_EXCEPTION.RAISE_EXCEPTION;

  END IF;

  IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
    l_return_value := true;
  end if;

  RETURN l_return_value;

END VALIDATE_PAYLOAD_FORMS;


/*** Get the event name and event key for an erecord id from evidence store ***/

PROCEDURE GET_EVENT_DETAILS
( p_api_version             IN  NUMBER          ,
  p_init_msg_list   IN  VARCHAR2                                ,
  x_return_status   OUT NOCOPY VARCHAR2         ,
  x_msg_count     OUT NOCOPY NUMBER       ,
  x_msg_data      OUT NOCOPY VARCHAR2       ,
  p_erecord_id      IN  NUMBER          ,
  x_event_name      OUT   NOCOPY VARCHAR2       ,
  x_event_key       OUT   NOCOPY VARCHAR2
)
AS
  l_api_name  CONSTANT VARCHAR2(30) := 'GET_EVENT_DETAILS';
  l_api_version   CONSTANT NUMBER   := 1.0;

  l_mesg_text      VARCHAR2(2000);

  cursor l_event_csr is
  SELECT EVENT_NAME, EVENT_KEY
  FROM EDR_PSIG_DOCUMENTS
  WHERE DOCUMENT_ID = p_erecord_id;

  NO_DATA_ERROR             EXCEPTION;
BEGIN
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version         ,
              p_api_version         ,
              l_api_name          ,
              G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --  API Body
  open l_event_csr;

  fetch l_event_csr
  into x_event_name, x_event_key;

  close l_event_csr;

  if (x_event_name is null) then
    RAISE NO_DATA_ERROR;
  end if;

  --  End of API Body

  -- Standard call to get message count and if count is 1, get
  --message info.
  FND_MSG_PUB.Count_And_Get
      (   p_count         =>      x_msg_count       ,
          p_data          =>      x_msg_data
      );

EXCEPTION
  WHEN NO_DATA_ERROR then
    x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    FND_MSG_PUB.Count_And_Get
        (  p_count          =>      x_msg_count     ,
             p_data           =>      x_msg_data
        );

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
              FND_MSG_PUB.Add_Exc_Msg
              ( G_PKG_NAME        ,
                l_api_name
          );
    END IF;

    FND_MSG_PUB.Count_And_Get
        (   p_count           =>      x_msg_count     ,
            p_data            =>      x_msg_data
    );

END GET_EVENT_DETAILS;

/*** Raise an ERES event ***/

PROCEDURE RAISE_ERES_EVENT
( p_api_version             IN  NUMBER,
  p_init_msg_list           IN  VARCHAR2,
  p_validation_level        IN  NUMBER,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_msg_count               OUT NOCOPY NUMBER,
  x_msg_data                OUT NOCOPY VARCHAR2,
  p_child_erecords          IN  ERECORD_ID_TBL_TYPE,
  x_event                   IN OUT  NOCOPY ERES_EVENT_REC_TYPE

)
AS
  l_api_name  CONSTANT VARCHAR2(30) := 'RAISE_ERES_EVENT';
  l_api_version   CONSTANT NUMBER   := 1.0;

  i      pls_integer;

  l_return_status    VARCHAR2(1);
  l_msg_count    NUMBER;
  l_msg_data     VARCHAR2(2000);

  l_child      BOOLEAN := FALSE;

  l_parent_event_name      varchar2(80);
  l_parent_event_key   varchar2(240);
  l_parent_erecord_id    number;

  l_child_event_name       varchar2(80);
  l_child_event_key    varchar2(240);
  l_child_erecord_id   number;

  l_relationship_id NUMBER;

  l_parameter_list   FND_WF_EVENT.PARAM_TABLE;
  l_param_name    varchar2(30);
  l_param_value     varchar2(2000);

  --Bug 4122622: Start
  l_child_erecord_ids VARCHAR2(4000);
  j pls_integer;
  CHILD_ERECORD_ID_ERROR          EXCEPTION;
  l_wrong_child_id NUMBER;
  l_mesg_text      VARCHAR2(2000);
  --Bug 4122622: End

BEGIN
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version         ,
              p_api_version         ,
              l_api_name          ,
              G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --  API Body

  --Bug 4122622: Start
  --if the child e-records are set then validate them against the evidence store.
  if p_child_erecords.count > 0 then

    i := p_child_erecords.FIRST;

     VALIDATE_ERECORD
     ( p_api_version     => 1.0,
       x_return_status   => l_return_status,
       x_msg_count       => l_msg_count,
       x_msg_data        => l_msg_data,
       p_erecord_id      => p_child_erecords(i)
    );
    -- If any errors happen abort API.
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
     l_wrong_child_id := p_child_erecords(i);
     RAISE CHILD_ERECORD_ID_ERROR;
    END IF;

    l_child_erecord_ids := to_char(p_child_erecords(i));
    i := p_child_erecords.NEXT(i);
    while i is not null loop
      VALIDATE_ERECORD
      ( p_api_version     => 1.0,
        x_return_status   => l_return_status,
        x_msg_count       => l_msg_count,
        x_msg_data        => l_msg_data,
        p_erecord_id      => p_child_erecords(i)
      );
      -- If any errors happen abort API.
      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        l_wrong_child_id := p_child_erecords(i);
        RAISE CHILD_ERECORD_ID_ERROR;
      END IF;

      --Create a comma separated string of child e-record IDs
      l_child_erecord_ids := l_child_erecord_ids||','||to_char(p_child_erecords(i));

      i := p_child_erecords.NEXT(i);

    end loop;
  end if;

  --If the child e-record IDs were set then create a payload parameter list.
  if l_child_erecord_ids is not null then
    EDR_ERES_EVENT_PVT.CREATE_PAYLOAD
    ( p_event               => x_event,
      p_starting_position   => 4,
      x_payload             => l_parameter_list
    );

    --Iterate to the end of the parameter list.
    j := null;
    i := l_parameter_list.FIRST;
    while i is not null loop
      j := i;
      i := l_parameter_list.NEXT(i);
    end loop;

    --Set the comma separated child e-record ID string on the payload.
    l_parameter_list(j+1).param_name := EDR_CONSTANTS_GRP.G_CHILD_ERECORD_IDS;
    l_parameter_list(j+1).param_value := l_child_erecord_ids;

    --Call raise event with the parameter list as the argument.
    EDR_ERES_EVENT_PVT.RAISE_EVENT
    ( p_api_version      => 1.0,
      p_init_msg_list    => FND_API.G_FALSE,
      p_validation_level => p_validation_level,
      x_return_status    => l_return_status,
      x_msg_count        => l_msg_count,
      x_msg_data         => l_msg_data,
      x_event            => x_event,
      p_mode             => EDR_CONSTANTS_GRP.g_strict_mode,
      x_is_child_event   => l_child,
      p_parameter_list   => l_parameter_list
    );
  else

    -- raise the event
    EDR_ERES_EVENT_PVT.RAISE_EVENT
    ( p_api_version      => 1.0,
      p_init_msg_list   => FND_API.G_FALSE,
      p_validation_level  => p_validation_level,
      x_return_status     => l_return_status,
      x_msg_count         => l_msg_count,
      x_msg_data          => l_msg_data,
      x_event             => x_event,
      p_mode              => EDR_CONSTANTS_GRP.g_strict_mode,
      x_is_child_event    => l_child
    );
  end if;
  --Bug 4122622: End

  -- If any errors happen abort API.
  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- inter event: proceed only if the event has been raised
  -- successfully and erecord created

  if (x_event.erecord_id is not null) then

    -- child event: now do processing in case this is a child
    -- event in an inter event context
    if (l_child = TRUE)  then

      --Bug 3136403: Start
      --Copy the individual parameters to a structure
      --of type fnd_wf_event.param_table

      EDR_ERES_EVENT_PVT.CREATE_PAYLOAD
      ( p_event     => x_event           ,
        p_starting_position   => 1                 ,
        x_payload           => l_parameter_list
      );

      i := l_parameter_list.FIRST;

      while i is not null loop
        l_param_name := l_parameter_list(i).Param_Name;
        l_param_value := l_parameter_list(i).Param_Value;

        if (l_param_name = EDR_CONSTANTS_GRP.g_parent_event_name)
        then
          l_parent_event_name := l_param_value;
        end if;

        if (l_param_name = EDR_CONSTANTS_GRP.g_parent_event_key)
        then
          l_parent_event_key := l_param_value;
        end if;

        if (l_param_name = EDR_CONSTANTS_GRP.g_parent_erecord_id)
        then
          l_parent_erecord_id := l_param_value;
        end if;

        i := l_parameter_list.NEXT(i);
            end loop;

      --Bug 3136403: End

      -- now that we know its an inter event mode and we
      -- have all the information to create the
      -- relationship, insert a row in the relationship
      -- table

      --no need to do validation in the called proc as we
          --have already done validation
                /* SKARIMIS . Added condition to post relation only if l_parent_erecord_id in > 0 */
               IF nvl(l_parent_erecord_id,-1)  > 0 THEN
      EDR_EVENT_RELATIONSHIP_PUB.CREATE_RELATIONSHIP
      ( p_api_version          => 1.0       ,
          p_init_msg_list  => FND_API.G_FALSE   ,
        p_commit         => FND_API.G_FALSE       ,
        p_validation_level   => FND_API.G_VALID_LEVEL_NONE  ,
        x_return_status  => l_return_status   ,
        x_msg_count    => l_msg_count     ,
        x_msg_data     => l_msg_data      ,
        P_PARENT_ERECORD_ID    => l_parent_erecord_id   ,
        P_PARENT_EVENT_NAME    => l_parent_event_name   ,
        P_PARENT_EVENT_KEY   => l_parent_event_key    ,
        P_CHILD_ERECORD_ID     => x_event.erecord_id    ,
        P_CHILD_EVENT_NAME     => x_event.event_name    ,
        P_CHILD_EVENT_KEY      => x_event.event_key   ,
        X_RELATIONSHIP_ID      => l_relationship_id
      );

      -- If any errors happen abort API.
      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
                END IF;
    end if; --end of the if for child event

    -- parent event:do processing in case this is a parent event
    -- in an inter event context

    if (p_child_erecords.COUNT > 0) then

      i := p_child_erecords.FIRST;

      while i is not null loop

        GET_EVENT_DETAILS
        ( p_api_version         => 1.0,
          p_init_msg_list       => FND_API.G_FALSE,
          x_return_status       => l_return_status,
          x_msg_count           => l_msg_count,
          x_msg_data            => l_msg_data,
          p_erecord_id          => p_child_erecords(i),
          x_event_name          => l_child_event_name,
          x_event_key           => l_child_event_key
        );

        -- If any errors happen abort API.
        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- now that we know its an inter event mode and we
        -- have all the information to create the relationship
        -- insert a row in the relationship table

        -- no need to do validation as the above call to get the child
        -- event details would have done that.
        -- no need for validation of parent as its anyhow valid

        EDR_EVENT_RELATIONSHIP_PUB.CREATE_RELATIONSHIP
        ( p_api_version          => 1.0       ,
          p_init_msg_list  => FND_API.G_FALSE   ,
          p_commit         => FND_API.G_FALSE       ,
          p_validation_level   => FND_API.G_VALID_LEVEL_NONE  ,
          x_return_status  => l_return_status   ,
          x_msg_count    => l_msg_count     ,
          x_msg_data     => l_msg_data      ,
          P_PARENT_ERECORD_ID    => x_event.erecord_id    ,
          P_PARENT_EVENT_NAME    => x_event.event_name    ,
          P_PARENT_EVENT_KEY   => x_event.event_key   ,
          P_CHILD_ERECORD_ID     => p_child_erecords(i)   ,
          P_CHILD_EVENT_NAME     => l_child_event_name    ,
          P_CHILD_EVENT_KEY      => l_child_event_key   ,
          X_RELATIONSHIP_ID      => l_relationship_id
        );

        -- If any errors happen abort API.
        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        i := p_child_erecords.NEXT(i);
      end loop;

    end if; --end of the if for parent event

  end if; --end of the if for inter event

  -- End of API Body

  -- Standard call to get message count and if count is 1,
  --get message info.
  FND_MSG_PUB.Count_And_Get
      (   p_count         =>      x_msg_count       ,
          p_data          =>      x_msg_data
      );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    --no need to set the event status its been set
    --in the called API
    x_return_status := FND_API.G_RET_STS_ERROR ;

    FND_MSG_PUB.Count_And_Get
    (   p_count        =>      x_msg_count  ,
            p_data         =>      x_msg_data
    );


  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- in case of unexpected errors. no need to manipulate the
    -- return status. the product teams should do an unqualified
    -- rollback

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    FND_MSG_PUB.Count_And_Get
        (  p_count          =>      x_msg_count     ,
             p_data           =>      x_msg_data
        );

  --Bug 4122622: Start
  WHEN CHILD_ERECORD_ID_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    fnd_message.set_name('EDR','EDR_VAL_INVALID_CHILD_ID');
    fnd_message.set_token('ERECORD_ID', l_wrong_child_id);
    l_mesg_text := fnd_message.get();
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                            l_api_name,
                            l_mesg_text);

    FND_MSG_PUB.Count_And_Get
    (  p_count              =>      x_msg_count     ,
       p_data               =>      x_msg_data
    );
  --Bug 4122622: End
  WHEN OTHERS THEN
    -- in case of unexpected errors. no need to manipulate the
    -- return status. the product teams should do an unqualified
    -- rollback

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
              FND_MSG_PUB.Add_Exc_Msg
              ( G_PKG_NAME  ,
              l_api_name
          );
    END IF;

    FND_MSG_PUB.Count_And_Get
        (p_count          =>      x_msg_count    ,
           p_data           =>      x_msg_data
        );

END RAISE_ERES_EVENT;


--Bug 4122622: Start
--This method sets the parent/child e-record details in the current event, if they
--were raised earlier in the transaction.
PROCEDURE SET_INTER_EVENT_DETAILS(P_EVENTS IN ERES_EVENT_TBL_TYPE,
                                  P_INDEX IN NUMBER,
                                  X_PARAMETER_LIST IN OUT NOCOPY FND_WF_EVENT.PARAM_TABLE)

IS

l_parent_erecord_index pls_integer;
l_parent_name_set boolean;
l_parent_key_set boolean;
l_parent_erecord_set boolean;

l_parent_event_name varchar2(240);
l_parent_event_key varchar2(240);
l_parent_erecord_id varchar2(128);
l_parent_erecord NUMBER;

l_return_status VARCHAR2(1);
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);

i pls_integer;

j pls_integer;

k pls_integer;

l_child_erecord_ids VARCHAR2(4000);

l_parameter_list FND_WF_EVENT.PARAM_TABLE;

begin
  --Initialize the boolean variables to false.
  l_parent_name_set := false;
  l_parent_key_set := false;
  l_parent_erecord_set := false;


  i := X_PARAMETER_LIST.FIRST;

  --Iterate through the parameter list of the current event.
  --Obtain the parent event details if they are set.
  WHILE i is not null loop
    if x_parameter_list(i).param_name = EDR_CONSTANTS_GRP.g_parent_event_name then
      l_parent_event_name := x_parameter_list(i).param_value;
      l_parent_name_set := true;
    elsif x_parameter_list(i).param_name = EDR_CONSTANTS_GRP.g_parent_event_key then
      l_parent_event_key := x_parameter_list(i).param_value;
      l_parent_key_set := true;
    elsif x_parameter_list(i).param_name = EDR_CONSTANTS_GRP.g_parent_erecord_id then
      l_parent_erecord_id := x_parameter_list(i).param_value;
      l_parent_erecord_set := true;
      k := i;
    end if;

    --If the parent event details are set then exit.
    if l_parent_name_set and  l_parent_key_set and l_parent_erecord_set then
      exit;
    end if;

    i := x_parameter_list.NEXT(i);

  end loop;

  if l_parent_name_set and  l_parent_key_set and l_parent_erecord_set then
    --If the parent event details are set and the parent e-record ID is set to -1,
    --then fetch the corresponding e-record ID of the parent.

    if l_parent_erecord_id is not null and l_parent_erecord_id = EDR_CONSTANTS_GRP.G_DEFAULT_CHAR_ID_VALUE then
        GET_ERECORD_ID
        ( p_api_version     => 1.0,
          p_init_msg_list   => FND_API.G_FALSE,
          x_return_status   => l_return_status,
          x_msg_count       => l_msg_count,
          x_msg_data        => l_msg_data,
          p_events          => p_events,
          p_event_name      => l_parent_event_name,
          p_event_key       => l_parent_event_key,
          x_erecord_id      => l_parent_erecord
        );

        -- If any errors happen abort API.
        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;


        if l_parent_erecord is not null and l_parent_erecord <> EDR_CONSTANTS_GRP.G_DEFAULT_NUM_PARAM_VALUE
        then
          l_parent_erecord_id := to_char(l_parent_erecord);
          x_parameter_list(k).param_value := l_parent_erecord_id;
        end if;
    end if;
  end if;


  --The parent details have been set
  --Now we need to obtain the child details.
  j := p_events.FIRST;

  --Iterate through each event in the list raised prior to the current event.
  WHILE j is not null and j < p_index loop
    if p_events(j).erecord_id is not null and p_events(j).erecord_id > 0 then
      --Create the payload parameter list for each event
      EDR_ERES_EVENT_PVT.CREATE_PAYLOAD
      ( p_event               => p_events(j),
        p_starting_position   => 1,
        x_payload             => l_parameter_list
      );
      i := L_PARAMETER_LIST.FIRST;

      --Iterate through the parameter list. Obtain the parent event details if
      --they exist.
      WHILE i is not null loop
        if l_parameter_list(i).param_name = EDR_CONSTANTS_GRP.g_parent_event_name then
          l_parent_event_name := l_parameter_list(i).param_value;
          l_parent_name_set := true;
        elsif l_parameter_list(i).param_name = EDR_CONSTANTS_GRP.g_parent_event_key then
          l_parent_event_key := l_parameter_list(i).param_value;
          l_parent_key_set := true;
        elsif l_parameter_list(i).param_name = EDR_CONSTANTS_GRP.g_parent_erecord_id then
          l_parent_erecord_id := l_parameter_list(i).param_value;
          l_parent_erecord_set := true;
        end if;



        --if the parent event details were found and the parent e-record ID is set to -1 then
        --append it the event's e-record ID to a comma separated string. Primarily this means
        --that the event under scrutiny is a child of the event being processed in this procedure.
        if l_parent_name_set and  l_parent_key_set and l_parent_erecord_set then

          --Reset the boolean values to false.
          l_parent_name_set := false;
          l_parent_key_set := false;
          l_parent_erecord_set := false;

          if l_parent_event_name = p_events(p_index).event_name and l_parent_event_key = p_events(p_index).event_key
            and l_parent_erecord_id = EDR_CONSTANTS_GRP.G_DEFAULT_CHAR_ID_VALUE then

            if l_child_erecord_ids is null then
              l_child_erecord_ids := to_char(p_events(j).erecord_id);
            else
              l_child_erecord_ids := l_child_erecord_ids ||','||to_char(p_events(j).erecord_id);
            end if;
          end if;
          --As the parent event details have been found, exit the loop.
          exit;
        end if;
        i := l_parameter_list.NEXT(i);
      end loop;
    end if;
    j := p_events.NEXT(j);
  end loop;

  --If the child e-record ID string was set then set it on the event payload
  --through the parameter list.
  if l_child_erecord_ids is not null then
    j := null;
    i := x_parameter_list.FIRST;
    while i is not null loop
      j := i;
      i := x_parameter_list.NEXT(i);
    end loop;
    if j is not null then
      x_parameter_list(j+1).param_name := EDR_CONSTANTS_GRP.G_CHILD_ERECORD_IDS;
      x_parameter_list(j+1).param_value := l_child_erecord_ids;
    end if;
  end if;
end SET_INTER_EVENT_DETAILS;
--Bug 4122622: End


/** Raise a set of ERES events in Inter-Event mode **/

PROCEDURE RAISE_INTER_EVENT
( p_api_version              IN NUMBER           ,
  p_init_msg_list    IN VARCHAR2       ,
  p_validation_level     IN   NUMBER         ,
  x_return_status    OUT  NOCOPY VARCHAR2      ,
  x_msg_count      OUT  NOCOPY NUMBER      ,
  x_msg_data       OUT  NOCOPY VARCHAR2      ,
  x_events                 IN OUT NOCOPY ERES_EVENT_TBL_TYPE ,
  x_overall_status     OUT    NOCOPY VARCHAR2
)
AS
  l_return_status    VARCHAR2(1);
  l_msg_count    NUMBER;
  l_msg_data     VARCHAR2(2000);

  l_api_name  CONSTANT VARCHAR2(30) := 'RAISE_INTER_EVENT';
  l_api_version   CONSTANT NUMBER   := 1.0;

  l_child     BOOLEAN := FALSE;
  l_inter_event_tbl
        EDR_EVENT_RELATIONSHIP_PUB.INTER_EVENT_TBL_TYPE;
  rel_number    pls_integer := 1;

  l_relationship_id   NUMBER;

  l_parameter_list        FND_WF_EVENT.PARAM_TABLE;
  l_param_name    varchar2(30);
  l_param_value     varchar2(2000);

  l_parent_event_name     varchar2(240);
  l_parent_event_key  varchar2(2000);
  l_parent_erecord_id   number;

  i     pls_integer;
  j     pls_integer;

BEGIN
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version         ,
              p_api_version         ,
              l_api_name          ,
              G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --  API Body

  --valiadate all the payloads only then start another loop
  --to raise the events and so forth

  if (p_validation_level > FND_API.G_VALID_LEVEL_NONE) then
    i := x_events.FIRST;
    while i is not null loop

      --Bug 3136403: Start
      EDR_ERES_EVENT_PVT.CREATE_PAYLOAD
      ( p_event     => x_events(i)       ,
        p_starting_position   => 1                 ,
        x_payload           => l_parameter_list
      );

      VALIDATE_PAYLOAD
      ( p_api_version         => 1.0      ,
        p_init_msg_list       => FND_API.G_FALSE,
        x_return_status       => l_return_status  ,
        x_msg_count           => l_msg_count    ,
        x_msg_data            => l_msg_data   ,
        p_event_name    => x_events(i).event_name,
        p_event_key   => x_events(i).event_key,
        p_payload             => l_parameter_list ,
        p_mode                => EDR_CONSTANTS_GRP.g_db_mode
      );

/*
      VALIDATE_PAYLOAD
      ( p_api_version         => 1.0      ,
        p_init_msg_list       => FND_API.G_FALSE,
        x_return_status       => l_return_status  ,
        x_msg_count           => l_msg_count    ,
        x_msg_data            => l_msg_data   ,
        p_event_name    => x_events(i).event_name,
        p_event_key   => x_events(i).event_key,
        p_payload             => x_events(i).payload  ,
        p_mode                => EDR_CONSTANTS_GRP.g_db_mode
      );
*/
      --Bug 3136403: End

      -- If any errors happen abort API.
      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR
      THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      i := x_events.NEXT(i);
    end loop;

  end if;

  --raise eres events for each event in the event list
  i := x_events.FIRST;
  while i is not null loop

    --Bug 4122622: Start
    --Create the event payload parameter list.
    EDR_ERES_EVENT_PVT.CREATE_PAYLOAD
    ( p_event               => x_events(i),
      p_starting_position   => 4,
      x_payload             => l_parameter_list
    );
    --Set the parent/child event details if required.
    SET_INTER_EVENT_DETAILS
    ( P_EVENTS => X_EVENTS,
      P_INDEX => i,
      x_parameter_list => l_parameter_list
    );
   --Bug 4122622: End
    -- raise the event
    --since we have already done the validation set
    --the validation level to none

    EDR_ERES_EVENT_PVT.RAISE_EVENT
    ( p_api_version         => 1.0        ,
      p_init_msg_list => FND_API.G_FALSE    ,
      p_validation_level  => FND_API.G_VALID_LEVEL_NONE ,
      x_return_status => l_return_status    ,
      x_msg_count   => l_msg_count      ,
      x_msg_data    => l_msg_data     ,
      x_event     => x_events(i)      ,
      p_mode      => null       ,
      x_is_child_event  => l_child,
      --Bug 4122622: Start
      --Pass the parameter list variable while raising the event.
      p_parameter_list => l_parameter_list
      --Bug 4122622: End
    );

    -- If any errors happen abort API.
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --child event: now do processing in case this is a child event
    --in an inter event context

    if(l_child = TRUE AND x_events(i).erecord_id is not null) then

      --Bug 3136403: Start
      EDR_ERES_EVENT_PVT.CREATE_PAYLOAD
      ( p_event     => x_events(i)       ,
        p_starting_position   => 1                 ,
        x_payload           => l_parameter_list
      );
      j := l_parameter_list.FIRST;
      --j := x_events(i).payload.FIRST;

      while j is not null loop

        l_param_name := l_parameter_list(j).Param_Name;
        l_param_value := l_parameter_list(j).Param_Value;

        --l_param_name := x_events(i).payload(j).Param_Name;
        --l_param_value := x_events(i).payload(j).Param_Value;

        if (l_param_name = EDR_CONSTANTS_GRP.g_parent_event_name)
        then
          l_inter_event_tbl(rel_number).parent_event_name
            := l_param_value;
        end if;

        if (l_param_name = EDR_CONSTANTS_GRP.g_parent_event_key)
        then
          l_inter_event_tbl(rel_number).parent_event_key
            := l_param_value;
        end if;

        if (l_param_name = EDR_CONSTANTS_GRP.g_parent_erecord_id)
        then
          l_inter_event_tbl(rel_number).parent_erecord_id
            := l_param_value;
        end if;

        l_inter_event_tbl(rel_number).child_event_name
          := x_events(i).event_name;
        l_inter_event_tbl(rel_number).child_event_key
          :=  x_events(i).event_key;
        l_inter_event_tbl(rel_number).child_erecord_id
          := x_events(i).erecord_id;

        j := l_parameter_list.NEXT(j);
        --j := x_events(i).payload.NEXT(j);
      --Bug 3136403: End

      end loop;

      --increment the counter for the relationship table type
      rel_number := rel_number + 1;

    end if; --end of the if for child event

    i := x_events.NEXT(i);
  end loop;

  -- find out the overall status
  -- this status is just for the events. if there are any problems
  -- after this point this status would not be affected

  x_overall_status := GET_OVERALL_STATUS(x_events);

  --relationship: if there are rows in the relationship table
  --then post them to DB

  if (l_inter_event_tbl.COUNT > 0) then
    for i IN l_inter_event_tbl.FIRST..l_inter_event_tbl.LAST
    loop
      if (l_inter_event_tbl(i).parent_erecord_id =
        EDR_CONSTANTS_GRP.g_default_num_param_value)
      then

        GET_ERECORD_ID
        ( p_api_version     => 1.0,
          p_init_msg_list   => FND_API.G_FALSE                       ,
          x_return_status   => l_return_status                       ,
          x_msg_count     => l_msg_count                           ,
          x_msg_data      => l_msg_data          ,
          p_events      => x_events            ,
          p_event_name      => l_inter_event_tbl(i).parent_event_name,
          p_event_key       => l_inter_event_tbl(i).parent_event_key ,
          x_erecord_id      => l_inter_event_tbl(i).parent_erecord_id
        );

      end if;

      -- If any errors happen abort API.
      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- insert a row in the event relationship table
      -- we still need to do the validation

                        -- Call create relationship only when both parent and child eRecords are valid
                        -- add if condition to resolve bug 3129588
      IF NVL(l_inter_event_tbl(i).child_erecord_id, -1)  <> -1 AND
                           NVL(l_inter_event_tbl(i).parent_erecord_id, -1) <> -1 THEN
                        EDR_EVENT_RELATIONSHIP_PUB.CREATE_RELATIONSHIP
                          (p_api_version          => 1.0                   ,
               p_init_msg_list  => FND_API.G_FALSE               ,
               p_commit       => FND_API.G_FALSE                 ,
               p_validation_level => FND_API.G_VALID_LEVEL_FULL              ,
               x_return_status  => l_return_status               ,
               x_msg_count    => l_msg_count                 ,
               x_msg_data   => l_msg_data                ,
               P_PARENT_ERECORD_ID    => l_inter_event_tbl(i).parent_erecord_id  ,
               P_PARENT_EVENT_NAME    => l_inter_event_tbl(i).parent_event_name  ,
               P_PARENT_EVENT_KEY => l_inter_event_tbl(i).parent_event_key   ,
               P_CHILD_ERECORD_ID     => l_inter_event_tbl(i).child_erecord_id   ,
               P_CHILD_EVENT_NAME     => l_inter_event_tbl(i).child_event_name   ,
               P_CHILD_EVENT_KEY      => l_inter_event_tbl(i).child_event_key    ,
               X_RELATIONSHIP_ID      => l_relationship_id
              );
                    END IF;

      -- If any errors happen abort API.
      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    end loop;

  end if; --end of if for relationship


  -- End of API Body

  -- Standard call to get message count and if count is 1,
  --get message info.
  FND_MSG_PUB.Count_And_Get
      (   p_count         =>      x_msg_count       ,
          p_data          =>      x_msg_data
      );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_overall_status := EDR_CONSTANTS_GRP.g_error_status;
    x_return_status := FND_API.G_RET_STS_ERROR ;

    FND_MSG_PUB.Count_And_Get
    (   p_count        =>      x_msg_count  ,
            p_data         =>      x_msg_data
    );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- no need to manipulate the overall status. product teams should
    -- do an unqualified rollback on getting this exception

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    FND_MSG_PUB.Count_And_Get
        (  p_count          =>      x_msg_count     ,
             p_data           =>      x_msg_data
        );

  WHEN OTHERS THEN
    -- no need to manipulate the overall status. product teams should
    -- do an unqualified rollback on getting this exception

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
              FND_MSG_PUB.Add_Exc_Msg
              ( G_PKG_NAME  ,
              l_api_name
          );
    END IF;

    FND_MSG_PUB.Count_And_Get
        (p_count          =>      x_msg_count    ,
           p_data           =>      x_msg_data
        );


END RAISE_INTER_EVENT;

/** Get the erecord id for an event from a table of eres events **/
PROCEDURE GET_ERECORD_ID
( p_api_version              IN NUMBER          ,
  p_init_msg_list    IN VARCHAR2                                ,
  x_return_status    OUT  NOCOPY VARCHAR2         ,
  x_msg_count      OUT  NOCOPY NUMBER       ,
  x_msg_data       OUT  NOCOPY VARCHAR2       ,
  p_events       IN   ERES_EVENT_TBL_TYPE                   ,
  p_event_name             IN     VARCHAR2        ,
  p_event_key        IN   VARCHAR2        ,
  x_erecord_id             OUT    NOCOPY NUMBER
)
AS
  l_api_name  CONSTANT VARCHAR2(30) := 'GET_ERECORD_ID';
  l_api_version   CONSTANT NUMBER   := 1.0;

  i    pls_integer;
BEGIN
  -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (l_api_version         ,
                                p_api_version         ,
                          l_api_name          ,
                          G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --  API Body

  i := p_events.FIRST;
  while i is not null loop
    if (p_events(i).event_name = p_event_name
      AND p_events(i).event_key = p_event_key)
    then
      x_erecord_id := p_events(i).erecord_id;
      exit;
    end if;
    i := p_events.NEXT(i);
  end loop;
  -- Standard call to get message count and if count is 1,
  --get message info.
  FND_MSG_PUB.Count_And_Get
      (   p_count         =>      x_msg_count       ,
          p_data          =>      x_msg_data
      );

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    FND_MSG_PUB.Count_And_Get
        (  p_count          =>      x_msg_count     ,
             p_data           =>      x_msg_data
        );

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
              FND_MSG_PUB.Add_Exc_Msg
              ( G_PKG_NAME  ,
              l_api_name
          );
    END IF;

    FND_MSG_PUB.Count_And_Get
        (p_count          =>      x_msg_count    ,
           p_data           =>      x_msg_data
        );


END GET_ERECORD_ID;

end EDR_ERES_EVENT_PUB;

/
