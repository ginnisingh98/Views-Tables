--------------------------------------------------------
--  DDL for Package BEN_CWB_EMP_ELIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_EMP_ELIG" AUTHID CURRENT_USER AS
/* $Header: bencwbee.pkh 120.0.12000000.1 2007/01/19 15:24:44 appldev noship $ */
TYPE L_EMP_NUMBER is VARRAY(500) of NUMBER(15);

PROCEDURE isCompManagerRole
(
  p_person_id IN   NUMBER
 ,retValue    OUT NOCOPY VARCHAR2
);

-- Right now FYI notifications are not sent for the worksheet manager when the top person in the hierachy switches
-- manger and changes the eligibility. For the top person it should happen without any approval but notification has to
-- be sent to the worksheet manager informing him that the eligibility is changed. In June 3rd drop the notification
-- is not sent to the worksheet manager if top person changes the eligibility.
/*PROCEDURE fyiNotification
 ( p_message_type IN VARCHAR2
  ,p_person_id    IN NUMBER
  ,p_plan_name    IN VARCHAR2
  ,p_transaction_id IN NUMBER
 );*/

PROCEDURE select_next_approver
( itemtype    IN  VARCHAR2
, itemkey     IN  VARCHAR2
, actid       IN  NUMBER
, funcmode    IN  VARCHAR2
, result      OUT NOCOPY VARCHAR2
);


PROCEDURE store_transaction
( itemtype    IN  VARCHAR2
, itemkey     IN  VARCHAR2
, actid       IN  NUMBER
, funcmode    IN  VARCHAR2
, result      OUT NOCOPY VARCHAR2
);


PROCEDURE store_rejection
( itemtype    IN  VARCHAR2
, itemkey     IN  VARCHAR2
, actid       IN  NUMBER
, funcmode    IN  VARCHAR2
, result      OUT NOCOPY VARCHAR2
);

PROCEDURE store_approval
( itemtype    IN  VARCHAR2
, itemkey     IN  VARCHAR2
, actid       IN  NUMBER
, funcmode    IN  VARCHAR2
, result      OUT NOCOPY VARCHAR2
);

PROCEDURE is_req_wsmgr_same
( itemtype    IN  VARCHAR2
, itemkey     IN  VARCHAR2
, actid       IN  NUMBER
, funcmode    IN  VARCHAR2
, result      OUT NOCOPY VARCHAR2
);


PROCEDURE remove_transaction
( itemtype    IN  VARCHAR2
, itemkey     IN  VARCHAR2
, actid       IN  NUMBER
, funcmode    IN  VARCHAR2
, result      OUT NOCOPY VARCHAR2
);

PROCEDURE cwb_emp_elig_appr_api
(   p_ws_person_id        in number default null
  , p_rcvr_person_id      in number default null
  , p_plan_name           in varchar2
  , p_relationship_id     in number
  , p_group_per_in_ler_id in number
);

END;

 

/
