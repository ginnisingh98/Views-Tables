--------------------------------------------------------
--  DDL for Package IEX_STRY_UTL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_STRY_UTL_PUB" AUTHID CURRENT_USER as
/* $Header: iexpsuts.pls 120.0.12000000.2 2007/04/26 09:09:32 gnramasa ship $ */


G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
G_YES         CONSTANT VARCHAR2(1) := 'Y';
G_NO          CONSTANT VARCHAR2(1) := 'N';
G_NUMBER      CONSTANT NUMBER := 1;  -- data type is number
G_VARCHAR2    CONSTANT NUMBER := 2;  -- data type is varchar2

TYPE work_item_rec_type IS RECORD (
  template_id           NUMBER,
  work_item_template_id NUMBER,
  order_by              NUMBER,
  STATUS                VARCHAR2(100),
  work_item_id          NUMBER,
  strategy_id           NUMBER );

TYPE work_item_tab_type IS TABLE OF work_item_rec_type INDEX BY BINARY_INTEGER;

PROCEDURE GET_NEXT_WORK_ITEMS
                          (p_api_version   IN  NUMBER,
                           p_commit        IN VARCHAR2          DEFAULT    FND_API.G_FALSE,
                           p_init_msg_list IN  VARCHAR2         DEFAULT    FND_API.G_FALSE,
                           p_strategy_id   IN NUMBER,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_msg_count     OUT NOCOPY NUMBER,
                           x_msg_data      OUT NOCOPY VARCHAR2,
                           x_work_item_tab OUT NOCOPY work_item_tab_type);



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
                           );

/**
   update the stragey status to  depending on the status passed
**/
PROCEDURE CLOSE_STRATEGY
                          (p_api_version   IN  NUMBER,
                           p_commit        IN VARCHAR2          DEFAULT    FND_API.G_FALSE,
                           p_init_msg_list IN  VARCHAR2         DEFAULT    FND_API.G_FALSE,
                           p_strategy_id   IN NUMBER,
                           p_status        IN VARCHAR2,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_msg_count     OUT NOCOPY NUMBER,
                           x_msg_data      OUT NOCOPY VARCHAR2
                           );

/**
   update the work_item_id;
**/
PROCEDURE UPDATE_WORK_ITEM
                          (p_api_version   IN  NUMBER,
                           p_commit        IN VARCHAR2          DEFAULT    FND_API.G_TRUE,
                           p_init_msg_list IN  VARCHAR2         DEFAULT    FND_API.G_FALSE,
                           p_work_item_id   IN NUMBER,
                           p_status        IN VARCHAR2,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_msg_count     OUT NOCOPY NUMBER,
                           x_msg_data      OUT NOCOPY VARCHAR2
                           );

/**
   update the next work_item_id in the strategy table
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
                           );



/**
 **check all the work_items for the given strategy for status in
 ** CANCELLED,COMPLETE.
 ** set the return value to 0 if the all the work items are
 ** exhausted
 **/
FUNCTION CHECK_WORK_ITEM_STATUS(
                           p_strategy_id   IN NUMBER
                           )RETURN NUMBER;

/** Calculate  date  based on the template UOM and the wait
*/

FUNCTION  get_Date (p_date IN DATE,
                    l_UOM varchar2,
                    l_unit number) return date;



/** subscription function example
*
**/
 FUNCTION create_workitem_check
 ( p_subscription_guid      in raw,
   p_event                  in out NOCOPY wf_event_t)
 RETURN VARCHAR2;

 /** subscription function example
*   for complete work item
**/

 FUNCTION create_workitem_complete
 ( p_subscription_guid      in raw,
   p_event                  in out NOCOPY wf_event_t)
 return varchar2;

--Begin bug#5874874 gnramasa 25-Apr-2007
procedure clear_uwq_str_summ(p_object_id in number,
                             p_object_type in varchar2);

procedure refresh_uwq_str_summ(p_workitem_id in number);
--End bug#5874874 gnramasa 25-Apr-2007

/** reassgin strategy
  * send signal first
  * then call create_Strategy_pub
  * to create the new strategy
  * the new strategy will launch the work flow*
  **/
/*
PROCEDURE REASSIGN_STRATEGY( p_strategy_id   IN NUMBER,
                             p_status        IN VARCHAR2,
                             p_commit        IN VARCHAR2  DEFAULT    FND_API.G_FALSE,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_msg_count     OUT NOCOPY NUMBER,
                             x_msg_data      OUT NOCOPY VARCHAR2);

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
                                 x_msg_data                OUT NOCOPY VARCHAR2);


*/

END IEX_STRY_UTL_PUB;

 

/
