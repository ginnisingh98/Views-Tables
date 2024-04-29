--------------------------------------------------------
--  DDL for Package AMS_WFMOD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_WFMOD_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvwmds.pls 115.12 2002/12/09 11:32:56 choang noship $*/

--  Start of Comments
--
-- NAME
--   AMS_WFMOD_PVT
--
-- PURPOSE
--   This package contains the workflow procedures for
--   Model Building/Scoring in Oracle Marketing
--
-- HISTORY
--   11/30/2000   sveerave@us CREATED
-- 30-Mar-2001    choang      Added cancel_process and change_schedule
-- 12-Jul-2001    choang      Added validate_concurrency.
-- 07-Dec-2001    choang      Modified change_schedule spec.
-- 17-Jul-2002    choang      Added default itemtype to spec for bug
--                            2410322.
-- 29-Aug-2002    nyostos     Added Reset_Status procedure to reset model/
--                            score status to DRAFT.
--
/************* GLOBAL VARIABLES *******************/
   G_DEFAULT_ITEMTYPE         CONSTANT VARCHAR2(30) := 'AMSDMMOD';

/***************************  PRIVATE ROUTINES  *******************************/
-- Start of Comments
--
-- NAME
--   StartProcess
--
-- PURPOSE
--   This Procedure will Start the flow
--
-- IN
--   p_object_id          Object ID - Model or Score ID
--   p_object_type        Object Type - MODL or SCOR
--   p_request_type       Request Type for data mining engine, Darwin
--   p_select_list        Select List for data mining engine, Darwin
--   processowner         Owner Of the Process
--   workflowprocess      Work Flow Process Name (MODEL_BUILD_SCORE)
--   itemtype             Item type DEFAULT NULL(AMSDMMOD)


--
-- OUT
--
-- Used By Activities
--
-- NOTES
--
--
-- HISTORY
--   11/30/1999   sveerave@us created
-- 04-Apr-2001    choang      Added scheduled_timezone_id and scheduled_date to params.
-- End of Comments

PROCEDURE StartProcess(  p_object_id         IN    NUMBER
                       , p_object_type       IN    VARCHAR2
                       , p_user_status_id    IN    NUMBER
                       , p_scheduled_timezone_id   IN NUMBER
                       , p_scheduled_date    IN    DATE
                       , p_request_type      IN    VARCHAR2    DEFAULT NULL
                       , p_select_list       IN    VARCHAR2    DEFAULT NULL
                       , p_enqueue_message   IN    VARCHAR2    DEFAULT NULL
                       , processowner        IN    VARCHAR2    DEFAULT NULL
                       , workflowprocess     IN    VARCHAR2    DEFAULT NULL
                       , itemtype            IN    VARCHAR2    DEFAULT G_DEFAULT_ITEMTYPE
                       , x_itemkey           OUT NOCOPY   VARCHAR2
                      );

-- Start of Comments
--
-- NAME
--   Selector
--
-- PURPOSE
--   This Procedure will determine which process to run
--
-- IN
-- itemtype     - A Valid item type from (WF_ITEM_TYPES Table).
-- itemkey      - A string generated from application object's primary key.
-- actid        - The function Activity
-- funcmode     - Run / Cancel
--
-- OUT
-- resultout    - Name of workflow process to run
--
-- Used By Activities
--
-- NOTES
--
--
-- HISTORY
--   11/30/1999        sveerave@us	created
-- End of Comments


PROCEDURE selector (  itemtype    IN      VARCHAR2
                    , itemkey     IN      VARCHAR2
                    , actid       IN      NUMBER
                    , funcmode    IN      VARCHAR2
                    , resultout   OUT NOCOPY     VARCHAR2
                    ) ;

-- Start of Comments
--
-- NAME
--   Validate
--
-- PURPOSE
--   This Procedure will aggregate sources based on user selections, and will return
--   Success or Failure
--
-- IN
--       Itemtype - AMSDMMOD
--       Itemkey  - ObjectID+Time
--       Accid    - Activity ID
--       Funmode  - Run/Cancel/Timeout
--
-- OUT
--       Result - 'COMPLETE:T' If the validation is successfully completed
--              - 'COMPLETE:F' If there is an error in validation
--
-- Used By Activities
--       Item Type - AMSDMMOD
--       Activity  - VALIDATE
--
-- NOTES
--
--
-- HISTORY
--   02/27/2001        sveerave@us  created
-- End of Comments

PROCEDURE validate_data (  itemtype  IN     VARCHAR2
                         , itemkey   IN     VARCHAR2
                         , actid     IN     NUMBER
                         , funcmode  IN     VARCHAR2
                         , result    OUT NOCOPY   VARCHAR2
                         );

-- Start of Comments
--
-- NAME
--   Aggregate_sources
--
-- PURPOSE
--   This Procedure will aggregate sources based on user selections, and will return
--   Success or Failure
--
-- IN
--       Itemtype - AMSDMMOD
--       Itemkey  - ObjectID+Time
--       Accid    - Activity ID
--       Funmode  - Run/Cancel/Timeout
--
-- OUT
--       Result - 'COMPLETE:SUCCESS' If the aggregation is successfully completed
--              - 'COMPLETE:FAILURE' If there is an error in aggregation
--
-- Used By Activities
--       Item Type - AMSDMMOD
--       Activity  - AGGREGATE_SOURCES
--
-- NOTES
--
--
-- HISTORY
--   11/30/2000        sveerave@us  created
-- End of Comments

PROCEDURE Aggregate_Sources(  itemtype  IN     VARCHAR2
                            , itemkey   IN     VARCHAR2
                            , actid     IN     NUMBER
                            , funcmode  IN     VARCHAR2
                            , result    OUT NOCOPY   VARCHAR2
                           );

-- Start of Comments
--
-- NAME
--   Transform
--
-- PURPOSE
--   This Procedure will transform the untransformed data, and will return
--   Success or Failure
--
-- IN
--       Itemtype - AMSDMMOD
--       Itemkey  - ObjectID+Time
--       Accid    - Activity ID
--       Funmode  - Run/Cancel/Timeout
--
-- OUT
--       Result   - 'COMPLETE:SUCCESS' If the transformation is successfully completed
--                - 'COMPLETE:FAILURE' If there is an error in transformation
--
-- Used By Activities
--   Item Type - AMSDMMOD
--   Activity  - TRANSFORM
--
-- NOTES
--
--
-- HISTORY
--   11/30/2000        sveerave@us	created
-- End of Comments

PROCEDURE Transform(  itemtype  IN     VARCHAR2
                    , itemkey   IN     VARCHAR2
                    , actid     IN     NUMBER
                    , funcmode  IN     VARCHAR2
                    , result    OUT NOCOPY   VARCHAR2
                   ) ;

-- Start of Comments
--
-- NAME
--   Command
--
-- PURPOSE
--   This Procedure will request for data mining by posting a request to AQ, and will return
--   Success or Failure
--
-- IN
--       Itemtype - AMSDMMOD
--       Itemkey  - ObjectID+Time
--       Accid    - Activity ID
--       Funmode  - Run/Cancel/Timeout
-- OUT
--       Result   - 'COMPLETE:SUCCESS' If sumbmitting aq request  is successfully completed
--                - 'COMPLETE:FAILURE' If there is an error in submitting the aq request
--
-- Used By Activities
--   Item Type - AMSDMMOD
--   Activity  - COMMAND
--
-- NOTES
--
--
-- HISTORY
--   11/30/2000        sveerave@us	created
-- End of Comments

PROCEDURE Command(  itemtype  IN   VARCHAR2
                  , itemkey   IN   VARCHAR2
                  , actid     IN   NUMBER
                  , funcmode  IN   VARCHAR2
                  , result    OUT NOCOPY   VARCHAR2
                  ) ;

-- Start of Comments
--
-- NAME
--   Check_response
--
-- PURPOSE
--   This Procedure will poll AQ to check whether there is any message
--   awaiting from Darwin after model is built/scored,
--   and will return:

--   ERROR (Successfully polled AQ with a message waiting, but the message is an Error message from mining application to build/score a model)
--   FAILURE (Failed to poll AQ for a message due to AQ system failure)
--   NO (Sucessfully polled AQ, but there are no messages waiting in the queue.)
--   YES (Sucessfully polled AQ with a message waiting, and also there are no errors from mining application (Darwin))

-- IN
--       Itemtype - AMSDMMOD
--       Itemkey  - ObjectID+Time
--       Accid    - Activity ID
--       Funmode  - Run/Cancel/Timeout
--
-- OUT
--    Result - 'COMPLETE:YES' If there is message awaiting from Darwin about model building/scoring.
--             'COMPLETE:NO' If there is no message awaiting from Darwin about model building/scoring.
--             'COMPLETE:ERROR' If there is error message from Darwin'
--             'COMPLETE:FAILURE' If it could not poll aq due to aq system failure

--
-- Used By Activities
--      Item Type - AMSDMMOD
--      Activity  - CHECK_RESPONSE
--
-- NOTES
--
--
-- HISTORY
--   11/30/2000        sveerave@uscreated
-- End of Comments

PROCEDURE Check_Response(  itemtype  IN   VARCHAR2
                         , itemkey   IN   VARCHAR2
                         , actid     IN   NUMBER
                         , funcmode  IN   VARCHAR2
                         , result    OUT NOCOPY   VARCHAR2
                        ) ;

-- Start of Comments
--
-- NAME
--   Collect_Results
--
-- PURPOSE
--   This Procedure will collect results once the model is built or scored by Darwin, and will return
--   Success or Failure
--
-- IN
--       Itemtype - AMSDMMOD
--       Itemkey  - ObjectID+Time
--       Accid    - Activity ID
--       Funmode  - Run/Cancel/Timeout
--
-- OUT
--       Result - 'COMPLETE:SUCCESS' If the collect results is successfully completed
--              - 'COMPLETE:FAILURE' If there is an error in collect results
--
-- Used By Activities
--   Item Type - AMSDMMOD
--   Activity  - COLLECT_RESULTS
--
-- NOTES
--
--
-- HISTORY
--   11/30/2000        sveerave@us	created
-- End of Comments

PROCEDURE Collect_Results(  itemtype  IN   VARCHAR2
                          , itemkey   IN   VARCHAR2
                          , actid     IN   NUMBER
                          , funcmode  IN   VARCHAR2
                          , result    OUT NOCOPY   VARCHAR2
                         ) ;

-- Start of Comments
--
-- NAME
--   Reset_Status
--
-- PURPOSE
--   This Procedure will reset the object status back to DRAFT regardless
--   of what status it is currently in.

-- IN
--       Itemtype - AMSDMMOD
--       Itemkey  - ObjectID+Time
--       Accid    - Activity ID
--       Funmode  - Run/Cancel/Timeout
--
-- OUT
--    Result - No Result

--
-- Used By Activities
--      Item Type - AMSDMMOD
--      Activity  - RESET_STATUS
--
-- NOTES
--
--
-- HISTORY
--   08/28/2002        nyostos created
-- End of Comments

PROCEDURE Reset_Status(  p_itemtype  IN   VARCHAR2
                       , p_itemkey   IN   VARCHAR2
                       , p_actid     IN   NUMBER
                       , p_funcmode  IN   VARCHAR2
                       , x_result    OUT NOCOPY  VARCHAR2
                       );



-- Start of Comments
--
-- NAME
--   Update_Obj_Status
--
-- PURPOSE
--   This Procedure will update object status to BUILDING or SCORING as per the object type
--   at the beginning. When error happens, it flips status to DRAFT, and succeeds, it flips status to
--   AVAILABLE

-- IN
--       Itemtype - AMSDMMOD
--       Itemkey  - ObjectID+Time
--       Accid    - Activity ID
--       Funmode  - Run/Cancel/Timeout
--
-- OUT
--    Result - No Result

--
-- Used By Activities
--      Item Type - AMSDMMOD
--      Activity  - UPDATE_OBJ_STATUS
--
-- NOTES
--
--
-- HISTORY
--   02/28/2001        sveerave@uscreated
-- End of Comments

PROCEDURE Update_Obj_Status(  itemtype  IN   VARCHAR2
                            , itemkey   IN   VARCHAR2
                            , actid     IN   NUMBER
                            , funcmode  IN   VARCHAR2
                            , result    OUT NOCOPY   VARCHAR2
                           );


--
-- Purpose
--    Cancel the specified instance of a WF model building
--    or scoring process.
--
-- Parameters
--    p_itemkey   - the WF itemkey identifying the instance of the process.
--    x_return_status   - standard output indicating the completion status
--
PROCEDURE cancel_process (
   p_itemkey         VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
);


--
-- Purpose
--    Update the scheduled date of the model building or scoring process.
--
-- Parameters
--    p_itemkey   - the WF itemkey identifying the instance of the process.
--    x_return_status   - standard output indicating the completion status
--
PROCEDURE change_schedule (
   p_itemkey         IN VARCHAR2,
   p_scheduled_date  IN DATE,
   p_scheduled_timezone_id IN NUMBER,
   x_new_itemkey     OUT NOCOPY VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
);


--
-- Purpose
--
-- Parameters
--    p_itemtype - AMSDMMOD
--    p_itemkey - unique identifier of the workflow process instance.
--    p_actid - activity id
--    p_funcmode - Run/Cancel/Timeout
--    x_result - output result: TRUE, FALSE
PROCEDURE validate_concurrency (
   p_itemtype  IN VARCHAR2,
   p_itemkey   IN VARCHAR2,
   p_actid     IN NUMBER,
   p_funcmode  IN VARCHAR2,
   x_result    OUT NOCOPY VARCHAR2
);


-- Start of Comments
--
-- NAME
--   Is_Previewing
--
-- PURPOSE
--   This Procedure will be called after the aggregate sources is done. If the WF process has been
--   started to Preview data selections, the Model/Scoring Run status will be set to DRAFT and this
--   procedure will return True so that the WF Process ends. If the WF Process was started to perform a Build
--   or Score then the procedure will return F, so that the next step in the process proceeds.
--
-- IN
--       Itemtype - AMSDMMOD
--       Itemkey  - ObjectID+Time
--       Accid    - Activity ID
--       Funmode  - Run/Cancel/Timeout
--
-- OUT
--       Result - 'COMPLETE:T' If Previewing
--              - 'COMPLETE:F' Otherwise
--
--
-- NOTES
--
--
-- HISTORY
-- 20-Sep-2002    nyostos     Created.
-- End of Comments

PROCEDURE Is_Previewing (  p_itemtype  IN     VARCHAR2
                         , p_itemkey   IN     VARCHAR2
                         , p_actid     IN     NUMBER
                         , p_funcmode  IN     VARCHAR2
                         , x_result    OUT NOCOPY   VARCHAR2
                         );


--
-- Purpose
--    Returns the value of a the Model/Scoring Run original status for
--    a specific workflow process identified by p_itemkey
--
-- Parameters
--    p_itemkey            - the WF itemkey identifying the instance of the process.
--    x_orig_status_id     - original status id of the Model/Scoring Run
--    x_return_status      - standard output indicating the completion status
--
PROCEDURE get_original_status (
   p_itemkey               VARCHAR2,
   x_orig_status_id        OUT NOCOPY NUMBER,
   x_return_status         OUT NOCOPY VARCHAR2
);

-- Start of Comments
--
-- NAME
--   ok_to_proceed
--
-- PURPOSE
--   This Procedure will make final errors checks before the Build, Score or Preivew proceeds.
--   For Scoring Run, we check that the Model has not become INVALID.
--
-- IN
--       Itemtype - AMSDMMOD
--       Itemkey  - ObjectID+Time
--       Accid    - Activity ID
--       Funmode  - Run/Cancel/Timeout
--
-- OUT
--       Result - 'COMPLETE:T' If ok to proceed
--              - 'COMPLETE:F' Otherwise
--
--
-- NOTES
--
--
-- HISTORY
-- 08-Oct-2002    nyostos     Created.
-- End of Comments

PROCEDURE ok_to_proceed (  p_itemtype  IN     VARCHAR2
                         , p_itemkey   IN     VARCHAR2
                         , p_actid     IN     NUMBER
                         , p_funcmode  IN     VARCHAR2
                         , x_result    OUT NOCOPY   VARCHAR2
                         );

END AMS_WFMOD_PVT;

 

/
