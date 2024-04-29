--------------------------------------------------------
--  DDL for Package IEX_STRY_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_STRY_API_PUB" AUTHID CURRENT_USER as
/* $Header: iexpsaps.pls 120.3.12010000.1 2008/07/29 10:02:54 appldev ship $ */


G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
G_YES         CONSTANT VARCHAR2(1) := 'Y';
G_NO          CONSTANT VARCHAR2(1) := 'N';
G_NUMBER      CONSTANT NUMBER := 1;  -- data type is number
G_VARCHAR2    CONSTANT NUMBER := 2;  -- data type is varchar2


/** reassgin strategy
  * send signal first
  * then call create_Strategy_pub
  * to create the new strategy
  * the new strategy will launch the work flow*
  **/
PROCEDURE REASSIGN_STRATEGY( p_strategy_temp_id IN NUMBER,
                             p_strategy_id   IN NUMBER,
                             p_status        IN VARCHAR2,
                             p_commit        IN VARCHAR2  DEFAULT    FND_API.G_FALSE,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_msg_count     OUT NOCOPY NUMBER,
                             x_msg_data      OUT NOCOPY VARCHAR2);

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
                             x_msg_data      OUT NOCOPY VARCHAR2);
--End bug 6794510 gnramasa 5th Feb 08

 /** update work item and call send signal
  * if send signal fails, roolback the work item
  **/

PROCEDURE UPDATE_AND_SENDSIGNAL( P_strategy_work_item_Rec  IN
                                    iex_strategy_work_items_pvt.strategy_work_item_Rec_Type,
                                 p_commit                  IN VARCHAR2  DEFAULT    FND_API.G_FALSE,
                                 x_return_status           OUT NOCOPY VARCHAR2,
                                 x_msg_count               OUT NOCOPY NUMBER,
                                 x_msg_data                OUT NOCOPY VARCHAR2);



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
                                ,p_execute_start IN  DATE     DEFAULT NULL
                                ,p_execute_end   IN  DATE     DEFAULT NULL
                                ,p_commit        IN VARCHAR2  DEFAULT FND_API.G_TRUE
                                ,x_return_status OUT NOCOPY VARCHAR2
                                ,x_msg_count     OUT NOCOPY NUMBER
                                ,x_msg_data      OUT NOCOPY VARCHAR2);

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
PROCEDURE CHECK_STRATEGY_WORKFLOW ( p_strategy        IN  NUMBER
                                    ,x_return_status  OUT NOCOPY VARCHAR2
                                    ,x_return_message OUT NOCOPY VARCHAR2
                                    ,x_wf_status      OUT NOCOPY VARCHAR2);
 /** update work item
  *09/09/02 --jsanju requested by ctlee .being called from
  * jsp/html
  **/

PROCEDURE UPDATE_WORKITEM       (p_status         IN  VARCHAR2
                                ,p_work_item_id  IN  NUMBER
                                ,p_resource_id   IN  NUMBER
                                ,p_execute_start IN  DATE     DEFAULT NULL
                                ,p_execute_end   IN  DATE     DEFAULT NULL
                                ,p_commit        IN VARCHAR2  DEFAULT FND_API.G_TRUE
                                ,x_return_status OUT NOCOPY VARCHAR2
                                ,x_msg_count     OUT NOCOPY NUMBER
                                ,x_msg_data      OUT NOCOPY VARCHAR2);

--
--show errors package body IEX_STRY_API_PUB
--/
--
--SELECT line, text FROM user_errors
--WHERE  name = 'IEX_STRY_API_PUB'
--AND    type = 'PACKAGE'
--/

  PROCEDURE SHOW_IN_UWQ(

        P_API_VERSION           IN      NUMBER,
        P_INIT_MSG_LIST         IN      VARCHAR2 DEFAULT 'F',
        P_COMMIT                IN      VARCHAR2 DEFAULT 'F',
        P_VALIDATION_LEVEL      IN      NUMBER DEFAULT 100,
        X_RETURN_STATUS         OUT NOCOPY     VARCHAR2,
        X_MSG_COUNT             OUT NOCOPY     NUMBER,
        X_MSG_DATA              OUT NOCOPY     VARCHAR2,
        P_WORK_ITEM_ID_TBL      IN      DBMS_SQL.NUMBER_TABLE,
        P_UWQ_STATUS            IN      VARCHAR2,
        P_NO_DAYS                       IN NUMBER DEFAULT NULL);

/**
   copy strategy work item template
  **/
PROCEDURE COPY_WORK_ITEM_TEMPLATE( p_work_item_temp_id IN NUMBER,
                             p_new_work_item_temp_id IN NUMBER
                             );

--Begin bug#5474793 schekuri 21-Aug-2006
--Added this procedure to provide a way in workitem details form to skip the pre-wait or post wait of the work item
PROCEDURE SKIP_WAIT(p_strategy_id in number,
		    p_workitem_id in number,
                    p_wkitem_status in varchar2,
		    x_return_status out nocopy varchar2);
--End bug#5474793 schekuri 21-Aug-2006

END IEX_STRY_API_PUB;



/
