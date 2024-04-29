--------------------------------------------------------
--  DDL for Package Body IEX_STRY_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_STRY_API_PUB" as
/* $Header: iexpsapb.pls 120.6.12010000.3 2009/03/16 17:53:31 ehuh ship $ */
-- Start of Comments
-- Package name     : IEX_STRY_API_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME      CONSTANT    VARCHAR2(100):=  'IEX_STRY_API_PUB ';
G_FILE_NAME     CONSTANT    VARCHAR2(12) := 'iexpsapb.pls';
G_USER_ID    NUMBER ;


/**Name   AddInvalidArgMsg
  **Appends to a message  the api name, parameter name and parameter Value
 */

--PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
PG_DEBUG NUMBER ;

PROCEDURE AddInvalidArgMsg
  ( p_api_name	    IN	VARCHAR2,
    p_param_value	IN	VARCHAR2,
    p_param_name	IN	VARCHAR2 ) IS
BEGIN
   IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
      fnd_message.set_name('IEX', 'IEX_API_ALL_INVALID_ARGUMENT');
      fnd_message.set_token('API_NAME', p_api_name);
      fnd_message.set_token('VALUE', p_param_value);
      fnd_message.set_token('PARAMETER', p_param_name);
      fnd_msg_pub.add;
   END IF;


END AddInvalidArgMsg;

/**Name   AddMissingArgMsg
  **Appends to a message  the api name, parameter name and parameter Value
 */

PROCEDURE AddMissingArgMsg
  ( p_api_name	    IN	VARCHAR2,
    p_param_name	IN	VARCHAR2 )IS
BEGIN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('IEX', 'IEX_API_ALL_MISSING_PARAM');
            fnd_message.set_token('API_NAME', p_api_name);
            fnd_message.set_token('MISSING_PARAM', p_param_name);
            fnd_msg_pub.add;
        END IF;
END AddMissingArgMsg;

/**Name   AddNullArgMsg
**Appends to a message  the api name, parameter name and parameter Value
*/

PROCEDURE AddNullArgMsg
  ( p_api_name	    IN	VARCHAR2,
    p_param_name	IN	VARCHAR2 )IS
BEGIN
   IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
      fnd_message.set_name('IEX', 'IEX_API_ALL_NULL_PARAMETER');
      fnd_message.set_token('API_NAME', p_api_name);
      fnd_message.set_token('NULL_PARAM', p_param_name);
      fnd_msg_pub.add;
   END IF;


END AddNullArgMsg;

/**Name   AddFailMsg
  **Appends to a message  the name of the object anf the operation (insert, update ,delete)
*/
PROCEDURE AddfailMsg
  ( p_object	    IN	VARCHAR2,
    p_operation 	IN	VARCHAR2 ) IS

BEGIN
      fnd_message.set_name('IEX', 'IEX_FAILED_OPERATION');
      fnd_message.set_token('OBJECT',    p_object);
      fnd_message.set_token('OPERATION', p_operation);
      fnd_msg_pub.add;

END    AddfailMsg;



/** reassagin strategy
  * send signal first
  * then call create_Strategy_pub
  * to create the new strategy
  * the new strategy will launch the work flow*
  **/
PROCEDURE REASSIGN_STRATEGY(
                             p_strategy_temp_id IN NUMBER,
                             p_strategy_id   IN NUMBER,
                             p_status        IN VARCHAR2,
                             p_commit        IN VARCHAR2,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_msg_count     OUT NOCOPY NUMBER,
                             x_msg_data      OUT NOCOPY VARCHAR2) IS

l_object_type varchar2(30) ;
l_object_id   number ;
l_delinquency_id number ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);
l_status   varchar2(100) ;

cursor c_status(p_strategy_id IN NUMBER) is
       select status_code
       from iex_strategies
       where strategy_id = p_strategy_id ;

cursor c_object(p_strategy_id IN NUMBER) is
  select delinquency_id,object_id,object_type
  from iex_strategies
  where strategy_id = p_strategy_id ;

BEGIN

     SAVEPOINT REASSIGN_STRATEGY_PUB;

     x_return_status := FND_API.G_RET_STS_ERROR;

     l_object_type := 'DELINQUENT' ;

      IEX_STRATEGY_WF.SEND_SIGNAL(process     => 'IEXSTRY',
                                  strategy_id => p_strategy_id,
                                  status      => p_status ) ;

--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.logmessage('REASSIGN_STRATEGY: ' || 'AFTER SEND SIGNAL');
      END IF;

      OPEN c_status(p_strategy_id);
      FETCH c_status INTO l_status;
      CLOSE  c_status;

      if ( l_status = 'CANCELLED' ) then
--           IF PG_DEBUG < 10  THEN
           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              IEX_DEBUG_PUB.logmessage('REASSIGN_STRATEGY: ' || 'After Send Signal and it successfull ');
           END IF;
            OPEN c_object(p_strategy_id);
            FETCH c_object INTO  l_delinquency_id,l_object_id,l_object_type;
            CLOSE c_object;

--           IF PG_DEBUG < 10  THEN
           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              IEX_DEBUG_PUB.logmessage('REASSIGN_STRATEGY: ' || 'IEXSTTAB-Delinquency id'||
                      'before calling create strategy is '
                      ||l_delinquency_id||
                      ' object_id is '||l_object_id ||
                      ' object_type is' || l_object_type );
           END IF;

--           IF PG_DEBUG < 10  THEN
           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              IEX_DEBUG_PUB.logmessage('REASSIGN_STRATEGY: ' || 'BEFORE CALLING CREATE_STRATEGY ');
           END IF;

           IEX_STRATEGY_PUB.CREATE_STRATEGY
                                     (p_api_version_number => 2.0,
                                       p_init_msg_list      => FND_API.G_TRUE,
                                       p_commit             => p_commit,
                                       p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
                                       p_delinquencyId      => l_delinquency_id ,
                                       p_objecttype        =>  l_object_type,
                                       p_objectid          =>  l_object_id ,
                                       x_return_status      => l_return_status,
                                       x_msg_count          => l_msg_count,
                                       x_msg_data           => l_msg_data,
                                       p_strategy_temp_id   => p_strategy_temp_id) ;

--               IF PG_DEBUG < 10  THEN
               IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                  iex_debug_pub.logmessage('REASSIGN_STRATEGY: ' || 'status of create strategy  ' ||l_return_status);
               END IF;

                x_msg_count     :=l_msg_count;
                x_msg_data      :=l_msg_data;
                x_return_status :=l_return_status;


      ELSE
          ROLLBACK TO REASSIGN_STRATEGY_PUB;
          RETURN;
       END if; --l_status =cancelled

        -- Standard check of p_commit
       IF FND_API.To_Boolean(p_commit) THEN
         COMMIT WORK;
       END IF;

EXCEPTION
WHEN OTHERS THEN
     ROLLBACK TO REASSIGN_STRATEGY_PUB;
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.logmessage('REASSIGN_STRATEGY: ' || 'inexception of reassign strategy '||sqlerrm);
     END IF;
END REASSIGN_STRATEGY;

--Start bug 6794510 gnramasa 5th Feb 08
/** assign strategy
  * call create_Strategy_pub
  * to create the new strategy
  * the new strategy will launch the work flow*
  **/

PROCEDURE ASSIGN_STRATEGY( p_strategy_temp_id IN NUMBER,
                             p_objectid      IN NUMBER,
			     p_objecttype    IN VARCHAR2,
                             p_commit        IN VARCHAR2  DEFAULT    FND_API.G_FALSE,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_msg_count     OUT NOCOPY NUMBER,
                             x_msg_data      OUT NOCOPY VARCHAR2) IS

l_delinquency_id number ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);
l_status   varchar2(100) ;

BEGIN

     SAVEPOINT ASSIGN_STRATEGY_PUB;

     x_return_status := FND_API.G_RET_STS_ERROR;

  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.logmessage('ASSIGN_STRATEGY: ' || 'IEXSTTAB-Delinquency id'||
	      'before calling create strategy is '
	      ||l_delinquency_id||
	      ' object_id is '||p_objectid ||
	      ' object_type is' || p_objecttype );
   END IF;

--           IF PG_DEBUG < 10  THEN
   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.logmessage('ASSIGN_STRATEGY: ' || 'BEFORE CALLING CREATE_STRATEGY ');
   END IF;

   IEX_STRATEGY_PUB.CREATE_STRATEGY
			     (p_api_version_number => 2.0,
			       p_init_msg_list      => FND_API.G_TRUE,
			       p_commit             => p_commit,
			       p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
			       p_delinquencyId      => l_delinquency_id ,
			       p_objecttype        =>  p_objecttype,
			       p_objectid          =>  p_objectid ,
			       x_return_status      => l_return_status,
			       x_msg_count          => l_msg_count,
			       x_msg_data           => l_msg_data,
			       p_strategy_temp_id   => p_strategy_temp_id) ;

--               IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	  iex_debug_pub.logmessage('ASSIGN_STRATEGY: ' || 'status of create strategy  ' ||l_return_status);
       END IF;

	x_msg_count     :=l_msg_count;
	x_msg_data      :=l_msg_data;
	x_return_status :=l_return_status;


       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          ROLLBACK TO ASSIGN_STRATEGY_PUB;
          RETURN;
       END if; --l_status =cancelled

        -- Standard check of p_commit
       IF FND_API.To_Boolean(p_commit) THEN
         COMMIT WORK;
       END IF;

EXCEPTION
WHEN OTHERS THEN
     ROLLBACK TO ASSIGN_STRATEGY_PUB;
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.logmessage('ASSIGN_STRATEGY: ' || 'inexception of reassign strategy '||sqlerrm);
     END IF;
END ASSIGN_STRATEGY;
--End bug 6794510 gnramasa 5th Feb 08

 /** update work item and call send signal
  * if send signal fails, roolback the work item
  **/

PROCEDURE UPDATE_AND_SENDSIGNAL( P_strategy_work_item_Rec  IN
                                          iex_strategy_work_items_pvt.strategy_work_item_Rec_Type,
                                 p_commit                  IN VARCHAR2,
                                 x_return_status           OUT NOCOPY VARCHAR2,
                                 x_msg_count               OUT NOCOPY NUMBER,
                                 x_msg_data                OUT NOCOPY VARCHAR2)IS

l_return_status VARCHAR2(1);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);
l_status   varchar2(100) ;
l_object_version_number NUMBER;
v_result NUMBER;
l_status_code   varchar2(100) ;
BEGIN

      SAVEPOINT UPDATE_AND_SENDSIGNAL;

      x_return_status := FND_API.G_RET_STS_SUCCESS;

      begin
        select  status_code INTO l_status_code from iex_strategy_work_items
          where strategy_id = p_strategy_work_item_rec.strategy_id
          and work_item_id = p_strategy_work_item_rec.work_item_id;

        if (l_status_code not in ('OPEN', 'ONHOLD','PRE-WAIT')) then  --Added PRE-WAIT for bug#5474793 by schekuri on 21-Aug-2006
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            IEX_DEBUG_PUB.logmessage('UPDATE_AND_SENDSIGNAL: ' || 'work item not in status OPEN or ONHOLD');
          end if;
          return;
        end if;

      EXCEPTION
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          IEX_DEBUG_PUB.logmessage('UPDATE_AND_SENDSIGNAL: ' || 'work item not found');
        end if;
        return;
      end;

      iex_strategy_work_items_pvt.update_strategy_work_items(
                 p_api_version_number     => 2.0,
                 p_init_msg_list          =>  FND_API.G_TRUE,
                 p_validation_level       =>  FND_API.G_VALID_LEVEL_FULL,
                 p_commit                 =>  p_commit,
                 x_return_status          => l_return_status,
                 x_msg_count              => l_msg_count,
                 x_msg_data               => l_msg_data,
                 p_strategy_work_item_rec => p_strategy_work_item_rec,
                 xo_object_version_number => l_object_version_number);

      If l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           x_msg_count     :=l_msg_count;
           x_msg_data      :=l_msg_data;
           x_return_status :=l_return_status;
           ROLLBACK TO UPDATE_AND_SENDSIGNAL;
           return;
      ELSE
           --call send signal
             IEX_STRATEGY_WF.SEND_SIGNAL(process     => 'IEXSTRY',
                                         strategy_id => p_strategy_work_item_rec.strategy_id,
                                         status      => p_strategy_work_item_rec.status_code,
                                         work_item_id => p_strategy_work_item_rec.work_item_id);

--             IF PG_DEBUG < 10  THEN
             IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                IEX_DEBUG_PUB.logmessage('UPDATE_AND_SENDSIGNAL: ' || 'AFTER SEND SIGNAL');
             END IF;
            --check  if it the strategy is open
            -- and next work item is not the same as the updated work item
            -- then the send signal has been successful and it has created
            -- the next work item . other wise, the send signal failed.
            -- id send signal is successful, commit , else rollback
            /* comment out by kali and ctlee
               select  count(*) INTO v_result from iex_strategies
               where strategy_id =p_strategy_work_item_rec.strategy_id
               and next_work_item_id =p_strategy_work_item_rec.work_item_id
               and status_code ='OPEN';

              if v_result >0 THEN
--                  IF PG_DEBUG < 10  THEN
                  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                     IEX_DEBUG_PUB.logmessage('UPDATE_AND_SENDSIGNAL: ' || 'send signal has failed ');
                  END IF;
                  rollback to  UPDATE_AND_SENDSIGNAL;
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  return;
             else
--               IF PG_DEBUG < 10  THEN
               IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                  IEX_DEBUG_PUB.logmessage('UPDATE_AND_SENDSIGNAL: ' || 'send signal is successful ');
               END IF;
             end if;
             */
        END IF; --if status is successful

        -- Standard check of p_commit
       IF FND_API.To_Boolean(p_commit) THEN
         COMMIT WORK;
       END IF;

EXCEPTION
WHEN OTHERS THEN
     ROLLBACK TO UPDATE_AND_SENDSIGNAL;
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.logmessage('inexception of UPDATE_AND_SENDSIGNAL '||sqlerrm);
     END IF;

END UPDATE_AND_SENDSIGNAL;

/** update work item and call send signal
  * if send signal fails, roolback the work item
  * this is called from the JSP page , so passing
  * columns instead of record type
  * temporary fix till rosetta is fixed
  * if the status is not changed to 'CLOSED'
  * 'CANCELLED' THEN just update the work item
  * do not call send signal
  *06/21/02 --jsanju
  **/

PROCEDURE UPDATE_AND_SENDSIGNAL(p_status         IN  VARCHAR2
                                ,p_work_item_id  IN  NUMBER
                                ,p_resource_id   IN  NUMBER
                                ,p_execute_start IN  DATE
                                ,p_execute_end   IN  DATE
                                ,p_commit        IN VARCHAR2
                                ,x_return_status OUT NOCOPY VARCHAR2
                                ,x_msg_count     OUT NOCOPY NUMBER
                                ,x_msg_data      OUT NOCOPY VARCHAR2) IS
l_return_status VARCHAR2(1);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);
l_status   varchar2(1) ;
l_version_number NUMBER;
v_result NUMBER;
l_strategy_work_item_rec
    IEX_STRATEGY_WORK_ITEMS_PVT.STRATEGY_WORK_ITEM_REC_TYPE;
l_strategy_id number ;

cursor c_work_item(p_work_item_id NUMBER) is
    select object_version_number,strategy_id
    from iex_strategy_work_items
    where work_item_id = p_work_item_id ;

BEGIN
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.logmessage('UPDATE_AND_SENDSIGNAL: ' || 'START UPDATE AND  SEND SIGNAL');
      END IF;
      SAVEPOINT UPDATE_AND_SENDSIGNAL;
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      OPEN c_work_item(p_work_item_id);
      fetch c_work_item into  l_version_number,l_strategy_id;
      close c_work_item;

     l_strategy_work_item_rec.work_item_id := p_work_item_id ;
     l_strategy_work_item_rec.object_version_number := l_version_number ;
     l_strategy_work_item_rec.execute_start := p_execute_start ;
     l_strategy_work_item_rec.execute_end := p_execute_end ;
     l_strategy_work_item_rec.status_code := p_status ;
     l_strategy_work_item_rec.resource_id :=p_resource_id;
     l_strategy_work_item_rec.strategy_id :=l_strategy_id;

--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.logmessage('UPDATE_AND_SENDSIGNAL: ' || 'BEFORE CALLING UPDATE WORK ITEM PVT');
     END IF;
          iex_strategy_work_items_pvt.update_strategy_work_items(
                 p_api_version_number     => 2.0,
                 p_init_msg_list          =>  FND_API.G_TRUE,
                 p_validation_level       =>  FND_API.G_VALID_LEVEL_FULL,
                 p_commit                 =>  FND_API.G_FALSE,
                 x_return_status          => l_return_status,
                 x_msg_count              => l_msg_count,
                 x_msg_data               => l_msg_data,
                 p_strategy_work_item_rec => l_strategy_work_item_rec,
                 xo_object_version_number => l_version_number);
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.logmessage('UPDATE_AND_SENDSIGNAL: ' || 'Status of work item update ' ||l_return_status);
     END IF;

      If l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           x_msg_count     :=l_msg_count;
           x_msg_data      :=l_msg_data;
           x_return_status :=l_return_status;
           ROLLBACK TO UPDATE_AND_SENDSIGNAL;
           return;
      ELSE
           --call send signal
           --only if status = 'CLOSED or 'CANCELLED'
             IF p_status IN ('CLOSED','CANCELLED','COMPLETE') THEN
                 IEX_STRATEGY_WF.SEND_SIGNAL(process     => 'IEXSTRY',
                                             strategy_id => l_strategy_work_item_rec.strategy_id,
                                             status      => l_strategy_work_item_rec.status_code,
                                             work_item_id =>l_strategy_work_item_rec.work_item_id);

--                IF PG_DEBUG < 10  THEN
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                   IEX_DEBUG_PUB.logmessage('UPDATE_AND_SENDSIGNAL: ' || 'AFTER SEND SIGNAL');
                END IF;
                --check  if it the strategy is open
                -- and next work item is not the same as the updated work item
                -- then the send signal has been successful and it has created
                -- the next work item . other wise, the send signal failed.
                -- id send signal is successful, commit , else rollback
               /* comment out by kali and ctlee
               select  count(*) INTO v_result from iex_strategies
               where strategy_id =l_strategy_work_item_rec.strategy_id
               and next_work_item_id =l_strategy_work_item_rec.work_item_id
               and status_code ='OPEN';

                if v_result >0 THEN
--                    IF PG_DEBUG < 10  THEN
                    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                       IEX_DEBUG_PUB.logmessage('UPDATE_AND_SENDSIGNAL: ' || 'send signal has failed ');
                    END IF;
                    rollback to  UPDATE_AND_SENDSIGNAL;
                     x_return_status := FND_API.G_RET_STS_ERROR;
                    return;
               else
--                  IF PG_DEBUG < 10  THEN
                  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                     IEX_DEBUG_PUB.logmessage('UPDATE_AND_SENDSIGNAL: ' || 'send signal is successful ');
                  END IF;
               end if;
               */
            END IF ; -- p_status in 'closed' or cancelled'
        END IF; --if status is successful

        -- Standard check of p_commit
       IF FND_API.To_Boolean(p_commit) THEN
         COMMIT WORK;
       END IF;

EXCEPTION
WHEN OTHERS THEN
     ROLLBACK TO UPDATE_AND_SENDSIGNAL;
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.logmessage('inexception of UPDATE_AND_SENDSIGNAL '||sqlerrm);
     END IF;


END    UPDATE_AND_SENDSIGNAL;

--06/27
--this procedure check the status of the workflow
--will be called before "changing the strategy"
-- " update and skip to next work item"
-- if the work flow is in error, then
--display on the screen that the work flow is in error
--along with the error_message attribute
--if the workflow is not suspended and
--if the activity_name is null( that means
--it is not a escalation or optional task)
-- there has been a error. display message.
PROCEDURE CHECK_STRATEGY_WORKFLOW ( p_strategy       IN  NUMBER
                                    ,x_return_status  OUT NOCOPY VARCHAR2
                                    ,x_return_message OUT NOCOPY VARCHAR2
                                    ,x_wf_status      OUT NOCOPY VARCHAR2) IS

 l_result            VARCHAR2(10);
 l_return_status     VARCHAR2(20);
 l_activity_name     VARCHAR2(100);
 l_wf_error  VARCHAR2(32627);
cursor c_get_Wf_error (p_strategy IN NUMBER)is
select
       --ias.activity_result_code Result,
       -- ias.error_name ERROR_NAME,
        ias.error_message ERROR_MESSAGE
       -- ,ias.error_stack ERROR_STACK
from wf_item_activity_statuses ias
where
 ias.item_type ='IEXSTRY'
 and ias.item_key =p_strategy
 and  ias.activity_status     = 'ERROR';

BEGIN
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.logmessage('Begin IEX_STRY_API_PUB.CHECK_STRATEGY_WORKFLOW' );
     END IF;
     --check status of the workflow
      wf_engine.ItemStatus(  itemtype =>   'IEXSTRY',
                             itemkey  =>   p_strategy,
                             status   =>   l_return_status,
                             result   =>   l_result);
     x_wf_Status :=l_return_status;

     --07/31/02
     --get workflow error from wf_item_activity_statuses table
      OPEN c_get_Wf_error (p_strategy);
      FETCH c_get_Wf_error INTO l_wf_error;
      CLOSE c_get_wf_error;
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.logmessage('CHECK_STRATEGY_WORKFLOW: ' || 'wf error is ' ||l_wf_error);
      END IF;

    if l_return_status = wf_engine.eng_error THEN
        -- work flow is in error
        --get the error message from the error_message attribute
        x_return_message :=wf_engine.GetItemAttrText(itemtype  => 'IEXSTRY',
                                                     itemkey   =>  p_strategy,
                                                     aname     => 'ERROR_MESSAGE');
        x_return_status  := 'E';

        x_return_message := x_return_message || l_wf_error;
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.logmessage('CHECK_STRATEGY_WORKFLOW: ' || 'Work flow is in error for strategy Id'
                                  ||p_strategy || 'error is ' ||x_return_message);
        END IF;

    elsif  l_return_status =wf_engine.eng_active  THEN
        -- work flow is active
        -- and is in error if the activity name is not populated
        -- the activity name gets populated for optional and escalation work items
        -- if it is in error then get the error message from the error_message attribute
        -- this can happen if the work flow has not reached the node where it gets suspended
        --could be due to many reason. these profiles might not be set
        --IEX_STRY_MEATAPHOR_CREATION -- for uwq creation
        --IEX_STRY_DEFAULT_RESOURCE   --

        l_activity_name :=wf_engine.GetItemAttrText(itemtype  => 'IEXSTRY',
                                                    itemkey   =>  p_strategy,
                                                    aname     => 'ACTIVITY_NAME');
       If l_activity_name is null then
--          IF PG_DEBUG < 10  THEN
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             IEX_DEBUG_PUB.logmessage('CHECK_STRATEGY_WORKFLOW: ' || 'l_activity_name is  null ' );
          END IF;
          x_return_message :=wf_engine.GetItemAttrText(itemtype  => 'IEXSTRY',
                                                       itemkey   =>  p_strategy,
                                                       aname     => 'ERROR_MESSAGE');

          x_return_message := x_return_message || l_wf_error;
          x_return_status  := 'E';
--          IF PG_DEBUG < 10  THEN
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             IEX_DEBUG_PUB.logmessage('CHECK_STRATEGY_WORKFLOW: ' || 'Work flow is in error for strategy Id'
                                   ||p_strategy || 'error is ' ||x_return_message);
          END IF;
        -- set status to success
         -- cancel or complete optional or escalate work item
       else
          x_return_status  := 'S';
       end if;
   else
       -- the work flow is SUSPENDED or COMPLETE
       -- the form doesn't all ow any changes if the
       -- workflow is 'COMPLETE'
       -- set status to complete.
          x_return_status  := 'S';
          x_return_message := NULL;
    end if;

--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.logmessage('End IEX_STRY_API_PUB.CHECK_STRATEGY_WORKFLOW' );
    END IF;

EXCEPTION
WHEN OTHERS THEN
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.logmessage('CHECK_STRATEGY_WORKFLOW: ' || 'inexception of UPDATE_AND_SENDSIGNAL '||sqlerrm);
    END IF;
    x_return_status  := 'E';
    x_return_message := sqlerrm;
    x_wf_Status :=NULL;
END CHECK_STRATEGY_WORKFLOW;

PROCEDURE UPDATE_WORKITEM       (p_status         IN  VARCHAR2
                                ,p_work_item_id  IN  NUMBER
                                ,p_resource_id   IN  NUMBER
                                ,p_execute_start IN  DATE
                                ,p_execute_end   IN  DATE
                                ,p_commit        IN VARCHAR2
                                ,x_return_status OUT NOCOPY VARCHAR2
                                ,x_msg_count     OUT NOCOPY NUMBER
                                ,x_msg_data      OUT NOCOPY VARCHAR2) IS


l_return_status VARCHAR2(1);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);
l_status   varchar2(1) ;
l_version_number NUMBER;
v_result NUMBER;
l_strategy_work_item_rec
    IEX_STRATEGY_WORK_ITEMS_PVT.STRATEGY_WORK_ITEM_REC_TYPE;
l_strategy_id number ;

cursor c_work_item(p_work_item_id NUMBER) is
    select object_version_number,strategy_id
    from iex_strategy_work_items
    where work_item_id = p_work_item_id ;

BEGIN
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.logmessage('START UPDATE_WORKITEM');
      END IF;
      SAVEPOINT UPDATE_WORKITEM;
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      OPEN c_work_item(p_work_item_id);
      fetch c_work_item into  l_version_number,l_strategy_id;
      close c_work_item;

     l_strategy_work_item_rec.work_item_id := p_work_item_id ;
     l_strategy_work_item_rec.object_version_number := l_version_number ;
     l_strategy_work_item_rec.execute_start := p_execute_start ;
     l_strategy_work_item_rec.execute_end := p_execute_end ;
     l_strategy_work_item_rec.status_code := p_status ;
     l_strategy_work_item_rec.resource_id :=p_resource_id;
     l_strategy_work_item_rec.strategy_id :=l_strategy_id;

--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.logmessage('UPDATE_WORKITEM: ' || 'BEFORE CALLING UPDATE WORK ITEM PVT');
     END IF;
          iex_strategy_work_items_pvt.update_strategy_work_items(
                 p_api_version_number     => 2.0,
                 p_init_msg_list          =>  FND_API.G_TRUE,
                 p_validation_level       =>  FND_API.G_VALID_LEVEL_FULL,
                 p_commit                 =>  FND_API.G_FALSE,
                 x_return_status          => l_return_status,
                 x_msg_count              => l_msg_count,
                 x_msg_data               => l_msg_data,
                 p_strategy_work_item_rec => l_strategy_work_item_rec,
                 xo_object_version_number => l_version_number);
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.logmessage('UPDATE_WORKITEM: ' || 'Status of work item update ' ||l_return_status);
     END IF;

        -- Standard check of p_commit
       IF FND_API.To_Boolean(p_commit) THEN
         COMMIT WORK;
       END IF;

EXCEPTION
WHEN OTHERS THEN
     ROLLBACK TO UPDATE_WORKITEM;
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.logmessage('inexception of UPDATE_WORKITEM '||sqlerrm);
     END IF;

END UPDATE_WORKITEM;

/*********************
Set UWQ status for Strategy
***********************/
PROCEDURE SHOW_IN_UWQ(
        P_API_VERSION              IN      NUMBER,
        P_INIT_MSG_LIST            IN      VARCHAR2,
        P_COMMIT                   IN      VARCHAR2,
        P_VALIDATION_LEVEL         IN      NUMBER,
        X_RETURN_STATUS            OUT NOCOPY     VARCHAR2,
        X_MSG_COUNT                OUT NOCOPY     NUMBER,
        X_MSG_DATA                 OUT NOCOPY     VARCHAR2,
        P_WORK_ITEM_ID_TBL         IN      DBMS_SQL.NUMBER_TABLE,
        P_UWQ_STATUS               IN      VARCHAR2,
        P_NO_DAYS                  IN      NUMBER)
IS
    l_api_name          CONSTANT VARCHAR2(30) := 'SHOW_IN_UWQ';
    l_api_version     	CONSTANT NUMBER := 1.0;
    l_return_status     varchar2(10);
    l_msg_count			number;
    l_msg_data			varchar2(200);

    l_validation_item   varchar2(100);
    l_days				NUMBER;
    l_set_status_date   DATE;
    l_status			varchar2(20);
    nCount				number;

    Type refCur is Ref Cursor;
    l_cursor            refCur;
    l_SQL				VARCHAR2(10000);
    l_broken_promises   DBMS_SQL.NUMBER_TABLE;
    i                   number;
    j                   number;
    l_uwq_active_date   date;
    l_uwq_complete_date date;

begin
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': start');
END IF;

    	-- Standard start of API savepoint
    	SAVEPOINT SHOW_IN_UWQ_PVT;

    	-- Standard call to check for call compatibility
    	IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    	END IF;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.To_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;

    	-- Initialize API return status to success
    	l_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- START OF BODY OF API

	-- validating uwq status
	l_validation_item := 'P_UWQ_STATUS';
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': new uwq status: ' || P_UWQ_STATUS);
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Validating ' || l_validation_item);
END IF;
	if P_UWQ_STATUS is null then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || l_validation_item || ' failed validation');
END IF;
		FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
		FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.' || l_api_name);
		FND_MESSAGE.SET_TOKEN('API_PARAMETER', l_validation_item);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	end if;

	-- validating table of promises
	l_validation_item := 'P_WORK_ITEM_ID_TBL';
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': count of P_WORK_ITEM_ID_TBL: ' || P_WORK_ITEM_ID_TBL.count);
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Validating ' || l_validation_item);
END IF;
	if P_WORK_ITEM_ID_TBL.count = 0 then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || l_validation_item || ' failed validation');
END IF;
		FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
		FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.' || l_api_name);
		FND_MESSAGE.SET_TOKEN('API_PARAMETER', l_validation_item);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	end if;

	-- validating p_days
	l_validation_item := 'P_NO_DAYS';
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': P_NO_DAYS: ' || P_NO_DAYS);
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': Validating ' || l_validation_item);
END IF;
	if P_NO_DAYS is not null and P_NO_DAYS < 0 then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': ' || l_validation_item || ' failed validation');
END IF;
		FND_MESSAGE.SET_NAME('IEX','IEX_BAD_API_INPUT');
		FND_MESSAGE.SET_TOKEN('API_NAME', G_PKG_NAME || '.' || l_api_name);
		FND_MESSAGE.SET_TOKEN('API_PARAMETER', l_validation_item);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	end if;

	-- set number of days
	if P_NO_DAYS is null then
	   	l_days := to_number(nvl(fnd_profile.value('IEX_UWQ_DEFAULT_PENDING_DAYS'), '0'));
	else
	   	l_days := P_NO_DAYS;
	end if;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': number of days: ' || l_days);
END IF;
	l_set_status_date := sysdate + l_days;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': set status date: ' || l_set_status_date);
END IF;

	-- check for status
	if P_UWQ_STATUS = 'ACTIVE' then
		l_uwq_active_date := NULL;
		l_uwq_complete_date := NULL;
	elsif P_UWQ_STATUS = 'PENDING' then
		l_uwq_active_date := l_set_status_date;
		l_uwq_complete_date := NULL;
	elsif P_UWQ_STATUS = 'COMPLETE' then
		l_uwq_active_date := NULL;
		l_uwq_complete_date := sysdate;
	end if;

        nCount := p_work_item_id_tbl.count;
        if nCount > 0 then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': l_uwq_active_date: ' || l_uwq_active_date);
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': l_uwq_complete_date: ' || l_uwq_complete_date);
        iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': updating promise details...');
END IF;
        	FORALL i in 1..nCount
                UPDATE iex_strategy_work_items
                SET uwq_status = p_uwq_status,
                    uwq_active_date = l_uwq_active_date,
                    uwq_complete_date = l_uwq_complete_date,
                    last_update_date = sysdate,
                    last_updated_by = g_user_id
                where
                    work_item_id = p_work_item_id_tbl(i);
        else
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ': nothing to update');
END IF;
        end if;

    	-- END OF BODY OF API

    	-- Standard check of p_commit.
    	IF FND_API.To_Boolean( p_commit ) THEN
        	COMMIT WORK;
    	END IF;

        x_return_status := l_return_status;
    	-- Standard call to get message count and if count is 1, get message info
        FND_MSG_PUB.Count_And_Get(p_encoded   => FND_API.G_FALSE,
                                    p_count   => x_msg_count,
                                    p_data    => x_msg_data);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO SHOW_IN_UWQ_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO SHOW_IN_UWQ_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO SHOW_IN_UWQ_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
end;

/**
   copy strategy work item template
  **/
PROCEDURE COPY_WORK_ITEM_TEMPLATE( p_work_item_temp_id IN NUMBER,
                             p_new_work_item_temp_id IN NUMBER)
is
    l_api_name          CONSTANT VARCHAR2(30) := 'COPY_WORK_ITEM_TEMPLATE';
    -- l_work_item_seq     number;
    Newworkitemname     varchar2(250);
    Newcnt              number;

begin

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || 'begin.' );
    END IF;

    	SAVEPOINT COPY_WORK_ITEM;

    -- begin Bug 8233425
    begin
       select b.name into Newworkitemname from iex_stry_temp_work_items_tl B
          where B.LANGUAGE = userenv('LANG')
            and b.work_item_temp_id = p_work_item_temp_id;

       Newcnt := 1;

       While  Newcnt >= 1
       Loop

          Newworkitemname := 'Copy of ' ||Newworkitemname;
          iex_debug_pub.LogMessage( 'Inside Loop ... Newworkitemname === '||Newworkitemname );

          select count(name) into Newcnt
             from iex_stry_temp_work_items_tl B, FND_LANGUAGES L
             where L.INSTALLED_FLAG in ('I', 'B') and B.LANGUAGE = userenv('LANG')
               and b.name = Newworkitemname;

       End Loop;

       exception
            when others then
                  iex_debug_pub.LogMessage( 'Exception from bug 8233425....' );
                  null;
    end;

    iex_debug_pub.LogMessage( 'Outside Loop ... Newworkitemname === '||Newworkitemname );
    -- end Bug 8233425


  -- SELECT IEX_STRATEGY_TEMP_WORK_ITEMS_S.NEXTVAL into l_work_item_seq FROM DUAL;

  insert into iex_stry_temp_work_items_b
    (work_item_temp_id, competence_id, work_type, category_type, priority_type, optional_yn,
     option_wait_time, option_wait_time_uom, pre_execution_wait, post_execution_wait, execution_time_uom,
     closure_time_limit, closure_time_uom, workflow_item_type, same_resource_yn,
     last_update_date, last_updated_by, last_update_login, creation_date, created_by, object_version_number,
     fulfil_temp_id, escalate_yn, notify_yn, schedule_wait, schedule_uom, enabled_flag, xdo_template_id
    )
    select p_new_work_item_temp_id, competence_id, work_type, category_type, priority_type, optional_yn,
      option_wait_time, option_wait_time_uom, pre_execution_wait, post_execution_wait, execution_time_uom,
      closure_time_limit, closure_time_uom, workflow_item_type, same_resource_yn,
      sysdate, fnd_global.user_id, fnd_global.user_id, sysdate, fnd_global.user_id, 1.0,
      fulfil_temp_id, escalate_yn, notify_yn, schedule_wait, schedule_uom, enabled_flag, xdo_template_id
    from iex_stry_temp_work_items_b
    where work_item_temp_id = p_work_item_temp_id;

   INSERT INTO IEX_STRY_TEMP_WORK_ITEMS_TL
     (WORK_ITEM_TEMP_ID,NAME,DESCRIPTION,LANGUAGE,SOURCE_LANG,
      CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,LAST_UPDATED_BY
     )
     -- Bug 8233425 select p_new_work_item_temp_id, 'Copy of ' || b.name,b.description,l.language_code ,b.SOURCE_LANG,
     select p_new_work_item_temp_id, Newworkitemname,b.description,l.language_code ,b.SOURCE_LANG,
       sysdate,fnd_global.user_id,sysdate,fnd_global.user_id,fnd_global.user_id
     from iex_stry_temp_work_items_tl B, FND_LANGUAGES L
     where L.INSTALLED_FLAG in ('I', 'B') and B.LANGUAGE = userenv('LANG')
           and b.work_item_temp_id = p_work_item_temp_id;

   INSERT INTO iex_strategy_work_skills
     (work_skill_id, WORK_ITEM_TEMP_ID,competence_id,
      CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,LAST_UPDATED_BY, object_version_number
     )
     select iex_strategy_work_skills_s.NEXTVAL, p_new_work_item_temp_id, a.competence_id,
       sysdate,fnd_global.user_id,sysdate,fnd_global.user_id,fnd_global.user_id, a.object_version_number
     from iex_strategy_work_skills a
     where a.work_item_temp_id = p_work_item_temp_id;

  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || 'end.' );
  END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO COPY_WORK_ITEM;
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || 'g_exc_error.' || sqlerrm );
      END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO COPY_WORK_ITEM;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || 'g_exc_unexpected_error.' || sqlerrm );
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO COPY_WORK_ITEM;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || 'others error.'  || sqlerrm);
      END IF;
end;


--Begin bug#5474793 schekuri 21-Aug-2006
--Added this procedure to provide a way in workitem details form to skip the pre-wait or post wait of the work item
PROCEDURE SKIP_WAIT(p_strategy_id in number,
		    p_workitem_id in number,
                    p_wkitem_status in varchar2,
		    x_return_status out nocopy varchar2) IS

l_return_status     varchar2(50);
l_activity_label varchar2(500);
l_work_item_id number;
BEGIN

	SAVEPOINT SKIP_WAIT;
	l_return_status := FND_API.G_RET_STS_SUCCESS;
	l_activity_label := wf_engine.GetItemAttrText(itemtype  => 'IEXSTRY',
	                                              itemkey   => p_strategy_id,
                                                      aname     => 'ACTIVITY_NAME');

        l_work_item_id := wf_engine.GetItemAttrNumber(itemtype  => 'IEXSTRY',
                                                      itemkey   => p_strategy_id,
                                                      aname     => 'WORK_ITEMID');

	IF (l_activity_label = 'STRATEGY_SUBPROCESS:PRE_WAIT_PROCESS' and p_wkitem_status = 'PRE-WAIT') OR
	   (l_activity_label = 'STRATEGY_WORKFLOW:WAIT_AFTER_PROCESS' and p_wkitem_status = 'COMPLETE' and p_workitem_id = l_work_item_id) THEN

                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(G_PKG_NAME || '.' || 'SKIP_WAIT' || ' Forcing to complete Wait Activity ' || l_activity_label);
	        END IF;

		wf_engine.CompleteActivity(itemtype    => 'IEXSTRY',
                                           itemkey     => p_strategy_id,
                                           activity    =>l_activity_label,
                                           result      =>'#TIMEOUT');
		COMMIT WORK;
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			iex_debug_pub.LogMessage(G_PKG_NAME || '.' || 'SKIP_WAIT' || ' Forcefully completed Wait Activity ' || l_activity_label);
	        END IF;
		x_return_status := l_return_status;
	END IF;
EXCEPTION WHEN OTHERS THEN
        ROLLBACK TO SKIP_WAIT;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;
--End bug#5474793 schekuri 21-Aug-2006



begin
  G_USER_ID  := FND_GLOBAL.User_Id;
  PG_DEBUG := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
END IEX_STRY_API_PUB ;



--
--show errors package body IEX_CASE_UTL_PUB
--/
--
--SELECT line, text FROM user_errors
--WHERE  name = 'IEX_STRY_API_PUB'
--AND    type = 'PACKAGE BODY'
--/

/
