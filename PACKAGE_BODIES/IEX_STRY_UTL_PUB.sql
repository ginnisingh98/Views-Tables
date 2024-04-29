--------------------------------------------------------
--  DDL for Package Body IEX_STRY_UTL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_STRY_UTL_PUB" as
/* $Header: iexpsutb.pls 120.1.12010000.9 2010/03/18 10:14:45 pnaveenk ship $ */
-- Start of Comments
-- Package name     : IEX_STRY_UTL_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME      CONSTANT    VARCHAR2(100):=  'IEX_STRY_UTL_PUB ';
G_FILE_NAME     CONSTANT    VARCHAR2(12) := 'iexpsutb.pls';


/**Name   AddInvalidArgMsg
  **Appends to a message  the api name, parameter name and parameter Value
 */

--PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
PG_DEBUG NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

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


PROCEDURE GET_NEXT_WORK_ITEMS
                          (p_api_version   IN  NUMBER,
                           p_commit        IN VARCHAR2          DEFAULT    FND_API.G_FALSE,
                           p_init_msg_list IN  VARCHAR2         DEFAULT    FND_API.G_FALSE,
                           p_strategy_id   IN NUMBER,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_msg_count     OUT NOCOPY NUMBER,
                           x_msg_data      OUT NOCOPY VARCHAR2,
                           x_work_item_tab OUT NOCOPY work_item_tab_type) IS

  CURSOR c_get_strategy_template_id(c_strategy_id NUMBER)  IS
    SELECT strategy_template_id
    FROM   iex_strategies
    WHERE  strategy_id =c_strategy_id;


  CURSOR c_get_work_items(c_strategy_id NUMBER, c_template_id NUMBER) IS

     select sxref.strategy_temp_id TEMPLATE_ID,
            sxref.work_item_temp_id WORK_ITEM_TEMPLATE_ID,
            sxref.work_item_order ORDER_BY
           ,nvl(swit.status_code,'NOTCREATED') STATUS
           ,swit.work_item_id     WORK_ITEM_ID
           ,swit.strategy_id      STRATEGY_ID
     from iex_strategy_work_temp_xref sxref
          ,iex_strategy_work_items swit
     where sxref.strategy_temp_id =c_template_id
     and   swit.work_item_template_id(+)  =sxref.work_item_temp_id
     and   swit.strategy_id(+) =c_strategy_id
     union all
     select susit.strategy_template_id TEMPLATE_ID,
            susit.work_item_temp_id WORK_ITEM_TEMPLATE_ID,
            susit.work_item_order ORDER_BY
           ,nvl(swit.status_code,'NOTCREATED') STATUS
           ,swit.work_item_id     WORK_ITEM_ID
          ,susit.strategy_id      STRATEGY_ID
     from iex_strategy_user_items susit
          ,iex_strategy_work_items swit
     where susit.strategy_id =c_strategy_id
     and   swit.work_item_template_id(+)  =susit.work_item_temp_id
     and   swit.strategy_id(+) =c_strategy_id
     order by order_by;


  l_api_version      CONSTANT NUMBER   := 1.0;
  l_api_name VARCHAR2(100) := 'GET_NEXT_WORK_ITEMS';
  l_api_name_full	          CONSTANT VARCHAR2(61) := g_pkg_name || '.' || l_api_name;
  l_init_msg_list VARCHAR2(1)  := p_init_msg_list;
  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(32767);
  idx NUMBER := 0;
  l_template_id NUMBER :=0;
BEGIN

  SAVEPOINT	GET_NEXT_WORK_ITEMS_PUB;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)    THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Check p_init_msg_list
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check for required parameter p_strategy_id
       IF (p_strategy_id IS NULL) OR (p_strategy_id = FND_API.G_MISS_NUM) THEN
--           IF PG_DEBUG < 10  THEN
           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              IEX_DEBUG_PUB.LogMessage('GET_NEXT_WORK_ITEMS: ' || 'Required Parameter p_strategy_id is invalid');
           END IF;
            AddMissingArgMsg(
                   p_api_name    =>  l_api_name_full,
                   p_param_name  =>  'p_strategy_id' );
            RAISE FND_API.G_EXC_ERROR;
       END IF;
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage('GET_NEXT_WORK_ITEMS: ' || 'after p_strategy_id check');
      END IF;

    OPEN c_get_strategy_template_id (p_strategy_id);
    FETCH c_get_strategy_template_id INTO l_template_id;
    CLOSE c_get_strategy_template_id;

     -- Check for required parameter p_template_id
       IF (l_template_id IS NULL) THEN
--           IF PG_DEBUG < 10  THEN
           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              IEX_DEBUG_PUB.LogMessage('GET_NEXT_WORK_ITEMS: ' || 'template_id is invalid');
           END IF;
            AddMissingArgMsg(
                   p_api_name    =>  l_api_name_full,
                   p_param_name  =>  'l_template_id' );
            RAISE FND_API.G_EXC_ERROR;
       END IF;
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage('GET_NEXT_WORK_ITEMS: ' || 'after l_template_id check'||l_template_id);
      END IF;

    FOR c_get_work_items_rec in c_get_work_items (p_strategy_id,l_template_id)
    LOOP
	   idx := idx + 1;
	  x_work_item_tab(idx).TEMPLATE_ID := c_get_work_items_rec.TEMPLATE_ID;
      x_work_item_tab(idx).WORK_ITEM_TEMPLATE_ID := c_get_work_items_rec.WORK_ITEM_TEMPLATE_ID;
	  x_work_item_tab(idx).ORDER_BY := c_get_work_items_rec.ORDER_BY;
      x_work_item_tab(idx).STATUS := c_get_work_items_rec.STATUS;
      x_work_item_tab(idx).WORK_ITEM_ID := c_get_work_items_rec.WORK_ITEM_ID;
	  x_work_item_tab(idx).STRATEGY_ID := c_get_work_items_rec.STRATEGY_ID;
    END LOOP;



  -- Standard check of p_commit
  IF FND_API.To_Boolean(p_commit) THEN
   COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);


  EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO GET_NEXT_WORK_ITEMS_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO GET_NEXT_WORK_ITEMS_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN OTHERS THEN
        ROLLBACK TO GET_NEXT_WORK_ITEMS_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END GET_NEXT_WORK_ITEMS;

/**
   update all the work_items status to  depending on the status passed
   update the stragey status to  depending on the status passed
**/

PROCEDURE CLOSE_STRY_AND_WITEMS
                          (p_api_version   IN  NUMBER,
                           p_commit        IN VARCHAR2          DEFAULT    FND_API.G_TRUE,
                           p_init_msg_list IN  VARCHAR2         DEFAULT    FND_API.G_FALSE,
                           p_strategy_id   IN NUMBER,
                           p_status        IN VARCHAR2,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_msg_count     OUT NOCOPY NUMBER,
                           x_msg_data      OUT NOCOPY VARCHAR2
                           )IS

  l_api_version      CONSTANT NUMBER   := 1.0;
  l_api_name VARCHAR2(100) := 'CLOSE_STRATEGY_AND WORK_ITEMS';
  l_api_name_full	          CONSTANT VARCHAR2(61) := g_pkg_name || '.' || l_api_name;
  l_init_msg_list VARCHAR2(1)  := p_init_msg_list;
  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(32767);
  l_api_version_number      CONSTANT NUMBER   := 2.0;
  l_strategy_work_item_rec IEX_strategy_work_items_PVT.strategy_work_item_Rec_Type;
  l_strategy_rec           IEX_strategy_PVT.strategy_Rec_Type;
  l_object_version_number  NUMBER;

  Cursor c_get_work_items (p_strategy_id NUMBER) is
  SELECT work_item_id, object_version_number
  FROM   iex_strategy_work_items
  WHERE  strategy_id = p_strategy_id
  and    status_code IN ('OPEN','PRE-WAIT','INERROR_CHECK_NOTIFY');  -- Changed for bug#7703351 by PNAVEENK on 22-1-2009
   -- NOT IN ('COMPLETE' ,'CANCELLED','CLOSED','TIMEOUT');


BEGIN

  SAVEPOINT	CLOSE_STRY_AND_WITEMS_PUB;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)    THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Check p_init_msg_list
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;
-- IF PG_DEBUG < 10  THEN
 IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage('CLOSE_STRY_AND_WITEMS: ' || 'after init');
 END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check for required parameter p_strategy_id
       IF (p_strategy_id IS NULL) OR (p_strategy_id = FND_API.G_MISS_NUM) THEN
--           IF PG_DEBUG < 10  THEN
           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              IEX_DEBUG_PUB.LogMessage('CLOSE_STRY_AND_WITEMS: ' || 'Required Parameter p_strategy_id is invalid');
           END IF;
            AddMissingArgMsg(
                   p_api_name    =>  l_api_name_full,
                   p_param_name  =>  'p_strategy_id' );
            RAISE FND_API.G_EXC_ERROR;
       END IF;
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage('CLOSE_STRY_AND_WITEMS: ' || 'after p_strategy_id check');
     END IF;

 -- Check for required parameter p_status_id
       IF (p_status IS NULL) OR (p_status = FND_API.G_MISS_CHAR) THEN
--           IF PG_DEBUG < 10  THEN
           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              IEX_DEBUG_PUB.LogMessage('CLOSE_STRY_AND_WITEMS: ' || 'Required Parameter p_status is invalid');
           END IF;
            AddMissingArgMsg(
                   p_api_name    =>  l_api_name_full,
                   p_param_name  =>  'p_status' );
            RAISE FND_API.G_EXC_ERROR;
       END IF;
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage('CLOSE_STRY_AND_WITEMS: ' || 'after p_status check');
     END IF;

    FOR c_get_work_items_rec in c_get_work_items (p_strategy_id)
    LOOP
        l_strategy_work_item_Rec.work_item_id  :=c_get_work_items_rec.work_item_id;
        l_strategy_work_item_Rec.status_code   := p_status;
        l_strategy_work_item_Rec.object_version_number
                                               :=c_get_work_items_rec.object_version_number;
        l_strategy_work_item_Rec.execute_end   := sysdate;
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           iex_debug_pub.logMessage('CLOSE_STRY_AND_WITEMS: ' || 'Before Calling IEX_STRATEGY_WORK_ITEMS_PVT.Update_strategy_work_items');
        END IF;
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           iex_debug_pub.logMessage('CLOSE_STRY_AND_WITEMS: ' || '---------------------------------');
        END IF;

	-- Start for bug 8740185 PNAVEENK
	if p_status = 'CLOSED' then
	   l_strategy_work_item_Rec.status_code := 'CANCELLED';
	end if;
        -- End for bug 8740185

        IEX_STRATEGY_WORK_ITEMS_PVT.Update_strategy_work_items(
              P_Api_Version_Number         =>l_api_version_number,
              P_strategy_work_item_Rec     =>l_strategy_work_item_Rec,
              P_Init_Msg_List             => p_init_msg_list, --FND_API.G_TRUE,  bug 9462104
              p_commit                    => p_commit, --FND_API.G_TRUE,
              p_validation_level          => FND_API.G_VALID_LEVEL_FULL,
              x_msg_count                  => l_msg_count,
              x_msg_data                   => l_msg_data,
              x_return_status              => l_return_status,
              XO_OBJECT_VERSION_NUMBER     =>l_object_version_number );
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           iex_debug_pub.logMessage('CLOSE_STRY_AND_WITEMS: ' || 'After Calling IEX_STRATEGY_WORK_ITEMS_PVT.Update_strategy_work_items '||
                                           'and Status =>'||l_return_status);
        END IF;
        IF l_return_status = FND_API.G_RET_STS_ERROR then
                       AddFailMsg( p_object      =>  'STRATEGY_WORK_ITEMS',
                                   p_operation  =>  'UPDATE' );
                       raise FND_API.G_EXC_ERROR;
        elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

    END LOOP;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage('CLOSE_STRY_AND_WITEMS: ' || 'End of work items update ');
    END IF;

    l_strategy_Rec.strategy_id  :=p_strategy_id;
    l_strategy_Rec.status_code  := p_status;

    BEGIN
       select object_version_number INTO l_object_version_number
       FROM iex_strategies
       where strategy_id =p_strategy_id;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
--         IF PG_DEBUG < 10  THEN
         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            IEX_DEBUG_PUB.LogMessage('CLOSE_STRY_AND_WITEMS: ' || 'Required Parameter p_stragey_id is invalid');
         END IF;
         AddInvalidArgMsg(
                   p_api_name    =>  l_api_name_full,
                   p_param_value =>  p_strategy_id,
                   p_param_name  =>  'p_stragey_id' );
         RAISE FND_API.G_EXC_ERROR;
    WHEN OTHERS THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

    l_strategy_Rec.object_version_number := l_object_version_number;

--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logMessage('CLOSE_STRY_AND_WITEMS: ' || 'Before Calling IEX_STRATEGY_PVT.Update_strategy');
     END IF;
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logMessage('CLOSE_STRY_AND_WITEMS: ' || '---------------------------------');
     END IF;

     IEX_STRATEGY_PVT.Update_strategy(
              P_Api_Version_Number         =>l_api_version_number,
              P_strategy_Rec               =>l_strategy_Rec,
              P_Init_Msg_List             =>FND_API.G_TRUE,
              p_commit                    =>FND_API.G_TRUE,
              p_validation_level          => FND_API.G_VALID_LEVEL_FULL,
              x_msg_count                  => l_msg_count,
              x_msg_data                   => l_msg_data,
              x_return_status              => l_return_status,
              XO_OBJECT_VERSION_NUMBER     =>l_object_version_number );
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           iex_debug_pub.logMessage('CLOSE_STRY_AND_WITEMS: ' || 'After Calling IEX_STRATEGY_PVT.Update_strategy '||
                                           'and Status =>'||l_return_status);
        END IF;

        IF l_return_status = FND_API.G_RET_STS_ERROR then
                       AddFailMsg( p_object      =>  'STRATEGY',
                                   p_operation  =>  'UPDATE' );
                       raise FND_API.G_EXC_ERROR;
        elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


  -- Standard check of p_commit
  IF FND_API.To_Boolean(p_commit) THEN
   COMMIT WORK;
  END IF;
  --Begin bug#5874874 gnramasa 25-Apr-2007
  --Update the UWQ summary table after closing the strategy.
           if l_strategy_work_item_Rec.work_item_id is not null then
	           IEX_STRY_UTL_PUB.refresh_uwq_str_summ(l_strategy_work_item_Rec.work_item_id);
           end if;
  --End bug#5874874 gnramasa 25-Apr-2007

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);


  EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CLOSE_STRY_AND_WITEMS_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CLOSE_STRY_AND_WITEMS_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN OTHERS THEN
        ROLLBACK TO CLOSE_STRY_AND_WITEMS_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END CLOSE_STRY_AND_WITEMS;


/**
   update the stragey status to  depending on the status passed
**/

PROCEDURE CLOSE_STRATEGY
                          (p_api_version   IN  NUMBER,
                           p_commit        IN VARCHAR2  DEFAULT FND_API.G_FALSE,
                           p_init_msg_list IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                           p_strategy_id   IN NUMBER,
                           p_status        IN VARCHAR2,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_msg_count     OUT NOCOPY NUMBER,
                           x_msg_data      OUT NOCOPY VARCHAR2
                           )IS

  l_api_version       NUMBER   := 1.0;
  l_api_name VARCHAR2(100) := 'CLOSE_STRATEGY';
  --l_api_name_full     VARCHAR2(2000) := g_pkg_name || '.' || l_api_name;
  l_api_name_full VARCHAR2(100) := l_api_name;
  l_init_msg_list VARCHAR2(100)  := p_init_msg_list;
  l_return_status VARCHAR2(100);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(32767);
  l_strategy_rec           IEX_strategy_PVT.strategy_Rec_Type;
  l_object_version_number  NUMBER;

  Cursor c_get_work_items (p_strategy_id NUMBER) is
  SELECT work_item_id, object_version_number
  FROM   iex_strategy_work_items
  WHERE  strategy_id = p_strategy_id;


BEGIN

  SAVEPOINT	CLOSE_STRATEGY_PUB;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)    THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Check p_init_msg_list
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check for required parameter p_strategy_id
       IF (p_strategy_id IS NULL) OR (p_strategy_id = FND_API.G_MISS_NUM) THEN
--           IF PG_DEBUG < 10  THEN
           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              IEX_DEBUG_PUB.LogMessage('CLOSE_STRATEGY: ' || 'Required Parameter p_strategy_id is invalid');
           END IF;
            AddMissingArgMsg(
                   p_api_name    =>  l_api_name_full,
                   p_param_name  =>  'p_strategy_id' );
            RAISE FND_API.G_EXC_ERROR;
       END IF;
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage('CLOSE_STRATEGY: ' || 'after p_strategy_id check');
     END IF;

 -- Check for required parameter p_status_id
       IF (p_status IS NULL) OR (p_status = FND_API.G_MISS_CHAR) THEN
--           IF PG_DEBUG < 10  THEN
           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              IEX_DEBUG_PUB.LogMessage('CLOSE_STRATEGY: ' || 'Required Parameter p_status is invalid');
           END IF;
            AddMissingArgMsg(
                   p_api_name    =>  l_api_name_full,
                   p_param_name  =>  'p_status' );
            RAISE FND_API.G_EXC_ERROR;
       END IF;
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage('CLOSE_STRATEGY: ' || 'after p_status check');
     END IF;

    l_strategy_Rec.strategy_id  :=p_strategy_id;
    l_strategy_Rec.status_code  := p_status;

    BEGIN
       select object_version_number INTO l_object_version_number
       FROM iex_strategies
       where strategy_id =p_strategy_id;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
--         IF PG_DEBUG < 10  THEN
         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            IEX_DEBUG_PUB.LogMessage('CLOSE_STRATEGY: ' || 'Required Parameter p_stragey_id is invalid');
         END IF;
         AddInvalidArgMsg(
                   p_api_name    =>  l_api_name_full,
                   p_param_value =>  p_strategy_id,
                   p_param_name  =>  'p_stragey_id' );
         RAISE FND_API.G_EXC_ERROR;
    WHEN OTHERS THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

    l_strategy_Rec.object_version_number := l_object_version_number;

--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logMessage('CLOSE_STRATEGY: ' || 'Before Calling IEX_STRATEGY_PVT.Update_strategy');
     END IF;
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logMessage('CLOSE_STRATEGY: ' || '---------------------------------');
     END IF;

     IEX_STRATEGY_PVT.Update_strategy(
              P_Api_Version_Number        =>2.0,
              P_Init_Msg_List             =>FND_API.G_TRUE,
              p_commit                    =>FND_API.G_TRUE,
              p_validation_level          => FND_API.G_VALID_LEVEL_FULL,
              P_strategy_Rec              =>l_strategy_Rec,
              x_msg_count                 => l_msg_count,
              x_msg_data                  => l_msg_data,
              x_return_status             => l_return_status,
              XO_OBJECT_VERSION_NUMBER    =>l_object_version_number );
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           iex_debug_pub.logMessage('CLOSE_STRATEGY: ' || 'After Calling IEX_STRATEGY_PVT.Update_strategy '||
                                           'and Status =>'||l_return_status);
        END IF;

        IF l_return_status = FND_API.G_RET_STS_ERROR then
                       AddFailMsg( p_object      =>  'STRATEGY',
                                   p_operation  =>  'UPDATE' );
                       raise FND_API.G_EXC_ERROR;
        elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


  -- Standard check of p_commit
  IF FND_API.To_Boolean(p_commit) THEN
   COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);


  EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CLOSE_STRATEGY_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CLOSE_STRATEGY_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN OTHERS THEN
        ROLLBACK TO CLOSE_STRATEGY_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END CLOSE_STRATEGY;


/**
   update all the work_item status to  depending on the status passed

**/

PROCEDURE UPDATE_WORK_ITEM
                          (p_api_version   IN  NUMBER,
                           p_commit        IN VARCHAR2          DEFAULT    FND_API.G_TRUE,
                           p_init_msg_list IN  VARCHAR2         DEFAULT    FND_API.G_FALSE,
                           p_work_item_id  IN NUMBER,
                           p_status        IN VARCHAR2,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_msg_count     OUT NOCOPY NUMBER,
                           x_msg_data      OUT NOCOPY VARCHAR2
                           )IS

  l_api_version      CONSTANT NUMBER   := 1.0;
  l_api_name VARCHAR2(100) := 'UPDATE_WORK_ITEM';
  l_api_name_full	          CONSTANT VARCHAR2(61) := g_pkg_name || '.' || l_api_name;
  l_init_msg_list VARCHAR2(1)  := p_init_msg_list;
  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(32767);
  l_api_version_number      CONSTANT NUMBER   := 2.0;
  l_strategy_work_item_rec IEX_strategy_work_items_PVT.strategy_work_item_Rec_Type;
    l_object_version_number  NUMBER;

  Cursor c_get_work_items (p_work_item_id NUMBER) is
  SELECT object_version_number
  FROM   iex_strategy_work_items
  WHERE  work_item_id =p_work_item_id;



BEGIN

  SAVEPOINT	UPDATE_WORK_ITEM_PUB;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)    THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Check p_init_msg_list
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;
-- IF PG_DEBUG < 10  THEN
 IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage('UPDATE_WORK_ITEM: ' || 'after init');
 END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check for required parameter p_strategy_id
       IF (p_work_item_id IS NULL) OR (p_work_item_id = FND_API.G_MISS_NUM) THEN
--           IF PG_DEBUG < 10  THEN
           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              IEX_DEBUG_PUB.LogMessage('UPDATE_WORK_ITEM: ' || 'Required Parameter p_work_item_id is invalid');
           END IF;
            AddMissingArgMsg(
                   p_api_name    =>  l_api_name_full,
                   p_param_name  =>  'p_work_item_id' );
            RAISE FND_API.G_EXC_ERROR;
       END IF;
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage('UPDATE_WORK_ITEM: ' || 'after p_work_item_id check');
     END IF;

 -- Check for required parameter p_status_id
       IF (p_status IS NULL) OR (p_status = FND_API.G_MISS_CHAR) THEN
--           IF PG_DEBUG < 10  THEN
           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              IEX_DEBUG_PUB.LogMessage('UPDATE_WORK_ITEM: ' || 'Required Parameter p_status is invalid');
           END IF;
            AddMissingArgMsg(
                   p_api_name    =>  l_api_name_full,
                   p_param_name  =>  'p_status' );
            RAISE FND_API.G_EXC_ERROR;
       END IF;
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage('UPDATE_WORK_ITEM: ' || 'after p_status check');
     END IF;

    FOR c_get_work_items_rec in c_get_work_items (p_work_item_id)
    LOOP
        l_strategy_work_item_Rec.work_item_id  :=p_work_item_id;
        l_strategy_work_item_Rec.status_code   := p_status;
        l_strategy_work_item_Rec.object_version_number
                                               :=c_get_work_items_rec.object_version_number;
        l_strategy_work_item_Rec.execute_end   := sysdate;
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           iex_debug_pub.logMessage('UPDATE_WORK_ITEM: ' || 'Before Calling IEX_STRATEGY_WORK_ITEMS_PVT.Update_strategy_work_items');
        END IF;
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           iex_debug_pub.logMessage('UPDATE_WORK_ITEM: ' || '---------------------------------');
        END IF;

        IEX_STRATEGY_WORK_ITEMS_PVT.Update_strategy_work_items(
              P_Api_Version_Number         =>l_api_version_number,
              P_strategy_work_item_Rec     =>l_strategy_work_item_Rec,
              P_Init_Msg_List             => p_init_msg_list, --FND_API.G_TRUE,
              p_commit                    => p_commit , --FND_API.G_TRUE,
              p_validation_level          => FND_API.G_VALID_LEVEL_FULL,
              x_msg_count                  => l_msg_count,
              x_msg_data                   => l_msg_data,
              x_return_status              => l_return_status,
              XO_OBJECT_VERSION_NUMBER     =>l_object_version_number );
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           iex_debug_pub.logMessage('UPDATE_WORK_ITEM: ' || 'After Calling IEX_STRATEGY_WORK_ITEMS_PVT.Update_strategy_work_items '||
                                           'and Status =>'||l_return_status);
        END IF;
        IF l_return_status = FND_API.G_RET_STS_ERROR then
                       AddFailMsg( p_object      =>  'STRATEGY_WORK_ITEMS',
                                   p_operation  =>  'UPDATE' );
                       raise FND_API.G_EXC_ERROR;
        elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

    END LOOP;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage('UPDATE_WORK_ITEM: ' || 'End of work items update ');
    END IF;



  -- Standard check of p_commit
  IF FND_API.To_Boolean(p_commit) THEN
   COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);


  EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
        --ROLLBACK TO CLOSE_STRY_AND_WITEMS_PUB;
	ROLLBACK TO UPDATE_WORK_ITEM_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        --ROLLBACK TO CLOSE_STRY_AND_WITEMS_PUB;
	ROLLBACK TO UPDATE_WORK_ITEM_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN OTHERS THEN
        --ROLLBACK TO CLOSE_STRY_AND_WITEMS_PUB;
	ROLLBACK TO UPDATE_WORK_ITEM_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END UPDATE_WORK_ITEM;
/**
* update next work item in the strategy table
* when a work item is created
**/
PROCEDURE UPDATE_NEXT_WORK_ITEM
                          (p_api_version   IN  NUMBER,
                           p_commit        IN VARCHAR2          DEFAULT    FND_API.G_FALSE,
                           p_init_msg_list IN  VARCHAR2         DEFAULT    FND_API.G_FALSE,
                           p_work_item_id  IN NUMBER,
                           p_strategy_id   IN NUMBER,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_msg_count     OUT NOCOPY NUMBER,
                           x_msg_data      OUT NOCOPY VARCHAR2
                           ) IS

  l_api_version       NUMBER   := 1.0;
  l_api_name VARCHAR2(100) := 'UPDATE_NEXT_WORK_ITEM';
  --l_api_name_full     VARCHAR2(2000) := g_pkg_name || '.' || l_api_name;
  l_api_name_full VARCHAR2(100) := l_api_name;
  l_init_msg_list VARCHAR2(100)  := p_init_msg_list;
  l_return_status VARCHAR2(100);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(32767);
  l_strategy_rec           IEX_strategy_PVT.strategy_Rec_Type;
  l_object_version_number  NUMBER;

  BEGIN


    SAVEPOINT	UPDATE_NEXT_WORK_ITEM_PUB;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)    THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Check p_init_msg_list
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check for required parameter p_strategy_id
       IF (p_strategy_id IS NULL) OR (p_strategy_id = FND_API.G_MISS_NUM) THEN
--           IF PG_DEBUG < 10  THEN
           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              IEX_DEBUG_PUB.LogMessage('UPDATE_NEXT_WORK_ITEM: ' || 'Required Parameter p_strategy_id is invalid');
           END IF;
            AddMissingArgMsg(
                   p_api_name    =>  l_api_name_full,
                   p_param_name  =>  'p_strategy_id' );
            RAISE FND_API.G_EXC_ERROR;
       END IF;
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage('UPDATE_NEXT_WORK_ITEM: ' || 'after p_strategy_id check');
     END IF;

  -- Check for required parameter p_work_item_id
       IF (p_work_item_id IS NULL) OR (p_work_item_id = FND_API.G_MISS_NUM) THEN
--           IF PG_DEBUG < 10  THEN
           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              IEX_DEBUG_PUB.LogMessage('UPDATE_NEXT_WORK_ITEM: ' || 'Required Parameter p_work_item_id is invalid');
           END IF;
            AddMissingArgMsg(
                   p_api_name    =>  l_api_name_full,
                   p_param_name  =>  'p_work_item_id' );
            RAISE FND_API.G_EXC_ERROR;
       END IF;
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage('UPDATE_NEXT_WORK_ITEM: ' || 'after p_work_item_id check');
     END IF;
    l_strategy_Rec.strategy_id  :=p_strategy_id;
    l_strategy_Rec.next_work_item_id  := p_work_item_id;

    BEGIN
       select object_version_number INTO l_object_version_number
       FROM iex_strategies
       where strategy_id =p_strategy_id;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
--         IF PG_DEBUG < 10  THEN
         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            IEX_DEBUG_PUB.LogMessage('UPDATE_NEXT_WORK_ITEM: ' || 'Required Parameter p_stratgey_id is invalid');
         END IF;
         AddInvalidArgMsg(
                   p_api_name    =>  l_api_name_full,
                   p_param_value =>  p_strategy_id,
                   p_param_name  =>  'p_stragey_id' );
         RAISE FND_API.G_EXC_ERROR;
    WHEN OTHERS THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

    l_strategy_Rec.object_version_number := l_object_version_number;

--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logMessage('UPDATE_NEXT_WORK_ITEM: ' || 'Before Calling IEX_STRATEGY_PVT.Update_strategy');
     END IF;
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logMessage('UPDATE_NEXT_WORK_ITEM: ' || '---------------------------------');
     END IF;

     IEX_STRATEGY_PVT.Update_strategy(
              P_Api_Version_Number        =>2.0,
              P_Init_Msg_List             =>FND_API.G_TRUE,
              p_commit                    =>FND_API.G_TRUE,
              p_validation_level          => FND_API.G_VALID_LEVEL_FULL,
              P_strategy_Rec              =>l_strategy_Rec,
              x_msg_count                 => l_msg_count,
              x_msg_data                  => l_msg_data,
              x_return_status             => l_return_status,
              XO_OBJECT_VERSION_NUMBER    =>l_object_version_number );
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           iex_debug_pub.logMessage('UPDATE_NEXT_WORK_ITEM: ' || 'After Calling IEX_STRATEGY_PVT.Update_strategy '||
                                           'and Status =>'||l_return_status);
        END IF;

        IF l_return_status = FND_API.G_RET_STS_ERROR then
                       AddFailMsg( p_object      =>  'STRATEGY',
                                   p_operation  =>  'UPDATE' );
                       raise FND_API.G_EXC_ERROR;
        elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


  -- Standard check of p_commit
  IF FND_API.To_Boolean(p_commit) THEN
   COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);


  EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO UPDATE_NEXT_WORK_ITEM_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO UPDATE_NEXT_WORK_ITEM_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN OTHERS THEN
        ROLLBACK TO UPDATE_NEXT_WORK_ITEM_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END UPDATE_NEXT_WORK_ITEM;


/**
 **check all the work_items for the given strategy for status in
 ** CANCELLED,COMPLETE.
 ** set the return value to 0 if the all the work items are
 ** exhausted
 **/
FUNCTION CHECK_WORK_ITEM_STATUS(
                           p_strategy_id   IN NUMBER
                           )RETURN NUMBER IS

x_work_item_done NUMBER :=0;
BEGIN
   SELECT count(*) into x_work_item_done
          FROM   iex_strategy_work_items
   WHERE  strategy_id = p_strategy_id
          and status_code not in ('CANCELLED','COMPLETE');

   return x_work_item_done;

END CHECK_WORK_ITEM_STATUS;

FUNCTION  get_Date (p_date IN DATE,
                    l_UOM varchar2,
                    l_unit number) return date
IS
r_date Date;
l_conversion number := 0;
l_jtf_time_uom_class varchar2(255);  --Added for Bug 7434190 22-Jan-2009 barathsr
begin

  select sysdate into r_date from dual;  -- default to sysdate;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
  iex_debug_pub.logmessage ('get_date before get conversion rate  ');
END IF;
  --Start of  bug 7434190 22-Jan-2009 barathsr
  l_jtf_time_uom_class := fnd_profile.value_specific(NAME => 'JTF_TIME_UOM_CLASS',APPLICATION_ID =>695);
  select conversion_rate into l_conversion from mtl_uom_conversions
    --Use the profile 'unit of measure class' value if it is set at application level, else use it from site level
    /* where UOM_code = l_UOM and uom_class = (select fnd_profile.value('JTF_TIME_UOM_CLASS') from dual) */
    where UOM_code = l_UOM and uom_class = l_jtf_time_uom_class
    --End of Bug 7434190 22-Jan-2009 barathsr
    and inventory_item_id = 0;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
  iex_debug_pub.logmessage ('get_date  l_conversion => '|| l_conversion);
END IF;

  select p_date + l_conversion * l_unit / 24 into r_date from dual;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
  iex_debug_pub.logmessage ('get_date  => '|| to_char(r_date, 'yyyy/mm/dd/hh24:mi:ss'));
END IF;

  return r_date;
exception when others THEN
  r_date :=p_date;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
  iex_debug_pub.logmessage ('get_date exception return sysdate');
END IF;
  return r_date;

end get_date;

/** subscription function example
*
**/
 FUNCTION create_workitem_check
 ( p_subscription_guid      in raw,
   p_event                  in out NOCOPY wf_event_t)
 return varchar2
is
 l_key                    varchar2(240) := p_event.GetEventKey();
 x_return_status          VARCHAR2(10) := 'S';
 x_msg_count              NUMBER;
 x_msg_data               VARCHAR2(2000);
 exc                      EXCEPTION;


l_del_id                  NUMBER;
l_strategy_id             NUMBER;
l_workitem_id             NUMBER;

begin
-- put custom code
-- this is just an example
-- writes into the log file
l_del_id      := p_event.GetValueForParameter('DELINQUENCY_ID');
l_strategy_id := p_event.GetValueForParameter('STRATEGY_ID');
l_workitem_id := p_event.GetValueForParameter('WORK_ITEMID');

--IF PG_DEBUG < 10  THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   iex_debug_pub.logmessage ('create_workitem_check: ' || 'EVENT NAME  =>'||p_event.getEventName());
END IF;
--IF PG_DEBUG < 10  THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   iex_debug_pub.logmessage ('create_workitem_check: ' || 'DELID =>'    || l_del_id);
END IF;
--IF PG_DEBUG < 10  THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   iex_debug_pub.logmessage ('create_workitem_check: ' || 'strategy ID  =>'    ||l_strategy_id );
END IF;
--IF PG_DEBUG < 10  THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   iex_debug_pub.logmessage ('create_workitem_check: ' || 'work item ID =>'    || l_workitem_id);
END IF;

  IF x_return_status <> 'S' THEN
     RAISE EXC;
  END IF;
  RETURN 'SUCCESS';

EXCEPTION
 WHEN EXC THEN
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('create_workitem_check: ' || 'raised exe error');
      END IF;
     WF_CORE.CONTEXT('IEX_STRY_UTL_PUB', 'create_workitem_check', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');
     RETURN 'ERROR';
 WHEN OTHERS THEN
     WF_CORE.CONTEXT('IEX_STRY_UTL_PUB', 'create_workitem_check', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');
     RETURN 'ERROR';


END create_workitem_check;

/** subscription function example
*   for complete work item
**/
 FUNCTION create_workitem_complete
 ( p_subscription_guid      in raw,
   p_event                  in out NOCOPY wf_event_t)
 return varchar2
is
 l_key                    varchar2(240) := p_event.GetEventKey();
 x_return_status          VARCHAR2(10) := 'S';
 x_msg_count              NUMBER;
 x_msg_data               VARCHAR2(2000);
 exc                      EXCEPTION;


l_del_id                  NUMBER;
l_strategy_id             NUMBER;
l_workitem_id             NUMBER;

begin
-- put custom code
-- this is just an example
-- writes into the log file

l_del_id      := p_event.GetValueForParameter('DELINQUENCY_ID');
l_strategy_id := p_event.GetValueForParameter('STRATEGY_ID');
l_workitem_id := p_event.GetValueForParameter('WORK_ITEMID');

--IF PG_DEBUG < 10  THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   iex_debug_pub.logmessage ('create_workitem_complete: ' || 'EVENT NAME  =>'||p_event.getEventName());
END IF;
--IF PG_DEBUG < 10  THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   iex_debug_pub.logmessage ('create_workitem_complete: ' || 'DELID =>'    || l_del_id);
END IF;
--IF PG_DEBUG < 10  THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   iex_debug_pub.logmessage ('create_workitem_complete: ' || 'strategy ID  =>'    ||l_strategy_id );
END IF;
--IF PG_DEBUG < 10  THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   iex_debug_pub.logmessage ('create_workitem_complete: ' || 'work item ID =>'    || l_workitem_id);
END IF;

 IF x_return_status <> 'S' THEN
     RAISE EXC;
  END IF;
  RETURN 'SUCCESS';

EXCEPTION
 WHEN EXC THEN
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage ('create_workitem_complete: ' || 'raised exe error');
    END IF;
     WF_CORE.CONTEXT('IEX_STRY_UTL_PUB', 'create_workitem_complete', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');
     RETURN 'ERROR';
 WHEN OTHERS THEN
     WF_CORE.CONTEXT('IEX_STRY_UTL_PUB', 'create_workitem_complete', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');
     RETURN 'ERROR';


END create_workitem_complete;

--Begin bug#5874874 gnramasa 25-Apr-2007
--Clear the Strategy related data in UWQ summary table.
procedure clear_uwq_str_summ(p_object_id in number,p_object_type in varchar2) is
begin
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.logmessage ('**** BEGIN : IEX_STRY_UTL_PUB.CLEAR_UWQ_STR_SUMM ************');
		iex_debug_pub.logmessage ('IEX_STRY_UTL_PUB.CLEAR_UWQ_STR_SUMM object_type='||p_object_type);
		iex_debug_pub.logmessage ('IEX_STRY_UTL_PUB.CLEAR_UWQ_STR_SUMM object_id='||p_object_id);
	END IF;

	IF p_object_type = 'PARTY' THEN

	       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.logmessage ('**** IEX_STRY_UTL_PUB.CLEAR_UWQ_STR_SUMM: Clearing party level strategy uwq summary ************');
	       END IF;
               UPDATE IEX_DLN_UWQ_SUMMARY
                  SET WORK_ITEM_ID = null,
                    SCHEDULE_START = null,
                    SCHEDULE_END = null,
                    WORK_TYPE = null,
                    CATEGORY_TYPE = null,
                    PRIORITY_TYPE = null,
		    WKITEM_RESOURCE_ID = null,
  	    	    STRATEGY_ID = null,
	    	    STRATEGY_TEMPLATE_ID = null,
		    WORK_ITEM_TEMPLATE_ID = null,
	            STATUS_CODE = null,
		    STR_STATUS = null,  -- Added for bug#7416344 by PNAVEENK
	            START_TIME = null,
	            END_TIME = null,
	            WORK_ITEM_ORDER = null,
		    WKITEM_ESCALATED_YN = null
                    WHERE PARTY_ID = p_object_id;

        ELSIF p_object_type = 'IEX_ACCOUNT' THEN
              IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.logmessage ('**** IEX_STRY_UTL_PUB.CLEAR_UWQ_STR_SUMM: Clearing account level strategy uwq summary ************');
	      END IF;
              UPDATE IEX_DLN_UWQ_SUMMARY
                   SET WORK_ITEM_ID = null,
                    SCHEDULE_START = null,
                    SCHEDULE_END = null,
                    WORK_TYPE = null,
                    CATEGORY_TYPE = null,
                    PRIORITY_TYPE = null,
		    WKITEM_RESOURCE_ID = null,
  	    	    STRATEGY_ID = null,
	    	    STRATEGY_TEMPLATE_ID = null,
		    WORK_ITEM_TEMPLATE_ID = null,
	            STATUS_CODE = null,
		    STR_STATUS = null,  -- Added for bug#7416344 by PNAVEENK
	            START_TIME = null,
	            END_TIME = null,
	            WORK_ITEM_ORDER = null,
		    WKITEM_ESCALATED_YN = null
                   WHERE CUST_ACCOUNT_ID = p_object_id;

         ELSIF p_object_type = 'IEX_BILLTO' THEN
              IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.logmessage ('**** IEX_STRY_UTL_PUB.CLEAR_UWQ_STR_SUMM: Clearing billto level strategy uwq summary ************');
	      END IF;
              UPDATE IEX_DLN_UWQ_SUMMARY
                   SET WORK_ITEM_ID = null,
                    SCHEDULE_START = null,
                    SCHEDULE_END = null,
                    WORK_TYPE = null,
                    CATEGORY_TYPE = null,
                    PRIORITY_TYPE = null,
		    WKITEM_RESOURCE_ID = null,
  	    	    STRATEGY_ID = null,
	    	    STRATEGY_TEMPLATE_ID = null,
		    WORK_ITEM_TEMPLATE_ID = null,
	            STATUS_CODE = null,
		    STR_STATUS = null,  -- Added for bug#7416344 by PNAVEENK
	            START_TIME = null,
	            END_TIME = null,
	            WORK_ITEM_ORDER = null,
		    WKITEM_ESCALATED_YN = null
                 WHERE SITE_USE_ID = p_object_id;
         END IF;
	 IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.logmessage ('**** IEX_STRY_UTL_PUB.CLEAR_UWQ_STR_SUMM: Clearing party level strategy uwq summary ************');
	 END IF;
exception
when others then
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	iex_debug_pub.logmessage ('**** EXCEPTION: IEX_STRY_UTL_PUB.CLEAR_UWQ_STR_SUMM ************');
END IF;
end;

--Update the Strategy related data in UWQ summary table.
procedure refresh_uwq_str_summ(p_workitem_id in number) is

     CURSOR c_strategy_summary(p_work_item_id number) IS
      select strat.jtf_object_id,
        strat.jtf_object_type,
        wkitem.WORK_ITEM_ID,
        wkitem.schedule_start schedule_start,
        wkitem.schedule_end schedule_end,
        stry_temp_wkitem.category_type category,
        stry_temp_wkitem.WORK_TYPE,
        stry_temp_wkitem.PRIORITY_TYPE,
        wkitem.resource_id,
        wkitem.strategy_id,
        strat.strategy_template_id,
        wkitem.work_item_template_id,
        wkitem.status_code workitem_status,
	strat.status_code startegy_status,
        wkitem.creation_date start_time,
        wkitem.execute_end end_time, -- snuthala 28/08/2008 bug #6745580
        wkitem.work_item_order wkitem_order,
	wkitem.escalated_yn escalated_yn
      from iex_strategies strat,
        iex_strategy_work_items wkitem,
        iex_stry_temp_work_items_b stry_temp_wkitem
      where wkitem.work_item_id=p_work_item_id
      AND wkitem.strategy_id = strat.strategy_id
      AND wkitem.work_item_template_id = stry_temp_wkitem.work_item_temp_id;

	l_jtf_object_id number;
	l_jtf_object_type varchar2(30);
        l_work_item_id number;
        l_schedule_start date;
        l_schedule_end date;
        l_work_type varchar2(30);
        l_category_type varchar2(30);
        l_priority_type varchar2(30);
	l_wkitem_resource_id number;
        l_strategy_id number;
	l_strategy_template_id number;
	l_work_item_template_id number;
	l_workitem_status varchar2(30);
	l_strategy_status varchar2(30);
	l_start_time date;
	l_end_time date;
	l_work_item_order number;
	l_escalated_yn varchar2(1);
begin

        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.logmessage ('**** BEGIN  refresh_uwq_str_summ ************');
	END IF;

	open c_strategy_summary(p_workitem_id);
	fetch c_strategy_summary into
  	    l_jtf_object_id,
	    l_jtf_object_type,
            l_work_item_id,
            l_schedule_start,
            l_schedule_end,
	    l_category_type,
            l_work_type,
            l_priority_type,
	    l_wkitem_resource_id,
	    l_strategy_id,
	    l_strategy_template_id,
	    l_work_item_template_id,
	    l_workitem_status,
	    l_strategy_status,
	    l_start_time,
	    l_end_time,
	    l_work_item_order,
	    l_escalated_yn;

	if l_strategy_status not in ('OPEN','ONHOLD') or l_workitem_status<>'OPEN' or l_work_type='AUTOMATIC' then
		close c_strategy_summary;
		clear_uwq_str_summ(l_jtf_object_id,l_jtf_object_type);
		commit work;
		return;
	end if;
	IF l_jtf_object_type = 'PARTY' THEN
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.logmessage ('**** IEX_STRY_UTL_PUB.REFRESH_UWQ_STR_SUMM: Updating party level strategy uwq summary ************');
	        END IF;
                update iex_dln_uwq_summary
                   set work_item_id = l_work_item_id,
                    schedule_start = l_schedule_start,
                    schedule_end = l_schedule_end,
                    work_type = l_work_type,
                    category_type = l_category_type,
                    priority_type = l_priority_type,
		    wkitem_resource_id = l_wkitem_resource_id,
  	    	    strategy_id = l_strategy_id,
	    	    strategy_template_id = l_strategy_template_id,
		    work_item_template_id = l_work_item_template_id,
	            status_code = l_workitem_status,
		    str_status = l_strategy_status,  -- Added for bug#7416344 by PNAVEENK on 16-3-2009
	            start_time = l_start_time,
	            end_time = l_end_time,
	            work_item_order = l_work_item_order,
		    wkitem_escalated_yn = l_escalated_yn
                   where party_id = l_jtf_object_id;

            ELSIF l_jtf_object_type = 'IEX_ACCOUNT' THEN
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.logmessage ('**** IEX_STRY_UTL_PUB.REFRESH_UWQ_STR_SUMM: Updating account level strategy uwq summary ************');
	        END IF;
                update iex_dln_uwq_summary
                   set work_item_id = l_work_item_id,
                    schedule_start = l_schedule_start,
                    schedule_end = l_schedule_end,
                    work_type = l_work_type,
                    category_type = l_category_type,
                    priority_type = l_priority_type,
		    wkitem_resource_id = l_wkitem_resource_id,
  	    	    strategy_id = l_strategy_id,
	    	    strategy_template_id = l_strategy_template_id,
		    work_item_template_id = l_work_item_template_id,
	            status_code = l_workitem_status,
		    str_status = l_strategy_status,  -- Added for bug#7416344 by PNAVEENK on 16-3-2009
	            start_time = l_start_time,
	            end_time = l_end_time,
	            work_item_order = l_work_item_order,
		    wkitem_escalated_yn = l_escalated_yn
                   where cust_account_id = l_jtf_object_id;

            ELSIF l_jtf_object_type = 'IEX_BILLTO' THEN
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.logmessage ('**** IEX_STRY_UTL_PUB.REFRESH_UWQ_STR_SUMM: Updating billto level strategy uwq summary ************');
	        END IF;
                update iex_dln_uwq_summary
                   set work_item_id = l_work_item_id,
                    schedule_start = l_schedule_start,
                    schedule_end = l_schedule_end,
                    work_type = l_work_type,
                    category_type = l_category_type,
                    priority_type = l_priority_type,
		    wkitem_resource_id = l_wkitem_resource_id,
  	    	    strategy_id = l_strategy_id,
	    	    strategy_template_id = l_strategy_template_id,
		    work_item_template_id = l_work_item_template_id,
	            status_code = l_workitem_status,
		    str_status = l_strategy_status,  -- Added for bug#7416344 by PNAVEENK on 16-3-2009
	            start_time = l_start_time,
	            end_time = l_end_time,
	            work_item_order = l_work_item_order,
		    wkitem_escalated_yn = l_escalated_yn
                 where site_use_id = l_jtf_object_id;

            END IF;
	    close c_strategy_summary;
	    commit work;
	    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		iex_debug_pub.logmessage ('**** END  refresh_uwq_str_summ ************');
	    END IF;
exception
when others then

iex_debug_pub.logmessage ('**** EXCEPTION  refresh_uwq_str_summ ************');

end;
--End bug#5874874 gnramasa 25-Apr-2007

/** reassagin strategy
  * send signal first
  * then call create_Strategy_pub
  * to create the new strategy
  * the new strategy will launch the work flow*
  **/
/*
PROCEDURE REASSIGN_STRATEGY( p_strategy_id   IN NUMBER,
                             p_status        IN VARCHAR2,
                             p_commit        IN VARCHAR2    DEFAULT    FND_API.G_FALSE,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_msg_count     OUT NOCOPY NUMBER,
                             x_msg_data      OUT NOCOPY VARCHAR2) IS

l_object_type varchar2(30) := 'DELINQUENT' ;
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
                                       x_msg_data           => l_msg_data) ;

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
*/
 /** update work item and call send signal
  * if send signal fails, roolback the work item
  **/

/*
PROCEDURE UPDATE_AND_SENDSIGNAL( P_strategy_work_item_Rec  IN
                                          iex_strategy_work_items_pvt.strategy_work_item_Rec_Type,
                                 p_commit                  IN VARCHAR2  DEFAULT    FND_API.G_FALSE,
                                 x_return_status           OUT NOCOPY VARCHAR2,
                                 x_msg_count               OUT NOCOPY NUMBER,
                                 x_msg_data                OUT NOCOPY VARCHAR2)IS

l_return_status VARCHAR2(1);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);
l_status   varchar2(100) ;
l_object_version_number NUMBER;
v_result NUMBER;
BEGIN

      SAVEPOINT UPDATE_AND_SENDSIGNAL;

      x_return_status := FND_API.G_RET_STS_SUCCESS;

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
*/

END IEX_STRY_UTL_PUB ;



/
