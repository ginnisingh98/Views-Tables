--------------------------------------------------------
--  DDL for Package OKE_DTS_WORKFLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_DTS_WORKFLOW" AUTHID CURRENT_USER AS
/* $Header: OKEDTSWS.pls 115.3 2003/12/05 01:12:49 ybchen noship $ */

   PROCEDURE LAUNCH_MAIN_PROCESS
   ( P_DELIVERABLE_ID             IN      NUMBER
   , P_DTS_WF_MODE                IN      VARCHAR2
   );

   PROCEDURE DUE_NTF_TO_SENT
   ( ItemType            IN         VARCHAR2
   , ItemKey             IN         VARCHAR2
   , ActID               IN         NUMBER
   , FuncMode            IN         VARCHAR2
   , ResultOut           OUT NOCOPY VARCHAR2
   )
   ;

   PROCEDURE PAST_DUE_NTF_TO_SENT
   ( ItemType            IN         VARCHAR2
   , ItemKey             IN         VARCHAR2
   , ActID               IN         NUMBER
   , FuncMode            IN         VARCHAR2
   , ResultOut           OUT NOCOPY VARCHAR2
   )
   ;

   PROCEDURE SELECT_DATE
   ( ItemType            IN         VARCHAR2
   , ItemKey             IN         VARCHAR2
   , ActID               IN         NUMBER
   , FuncMode            IN         VARCHAR2
   , ResultOut           OUT NOCOPY VARCHAR2
   )
   ;

   PROCEDURE READY_TO_SHIP
   ( ItemType            IN         VARCHAR2
   , ItemKey             IN         VARCHAR2
   , ActID               IN         NUMBER
   , FuncMode            IN         VARCHAR2
   , ResultOut           OUT NOCOPY VARCHAR2
   )
   ;

   PROCEDURE READY_TO_CREATE_MDS
   ( ItemType            IN         VARCHAR2
   , ItemKey             IN         VARCHAR2
   , ActID               IN         NUMBER
   , FuncMode            IN         VARCHAR2
   , ResultOut           OUT NOCOPY VARCHAR2
   )
   ;

   PROCEDURE READY_TO_PROCURE
   ( ItemType            IN         VARCHAR2
   , ItemKey             IN         VARCHAR2
   , ActID               IN         NUMBER
   , FuncMode            IN         VARCHAR2
   , ResultOut           OUT NOCOPY VARCHAR2
   )
   ;

   PROCEDURE LAUNCH_SHIP
   ( ItemType            IN         VARCHAR2
   , ItemKey             IN         VARCHAR2
   , ActID               IN         NUMBER
   , FuncMode            IN         VARCHAR2
   , ResultOut           OUT NOCOPY VARCHAR2
   )
   ;

   PROCEDURE LAUNCH_PLAN
   ( ItemType            IN         VARCHAR2
   , ItemKey             IN         VARCHAR2
   , ActID               IN         NUMBER
   , FuncMode            IN         VARCHAR2
   , ResultOut           OUT NOCOPY VARCHAR2
   )
   ;

   PROCEDURE LAUNCH_REQ
   ( ItemType            IN         VARCHAR2
   , ItemKey             IN         VARCHAR2
   , ActID               IN         NUMBER
   , FuncMode            IN         VARCHAR2
   , ResultOut           OUT NOCOPY VARCHAR2
   )
   ;

   PROCEDURE READY_TO_COMPLETE
   ( ItemType            IN         VARCHAR2
   , ItemKey             IN         VARCHAR2
   , ActID               IN         NUMBER
   , FuncMode            IN         VARCHAR2
   , ResultOut           OUT NOCOPY VARCHAR2
   )
   ;

   PROCEDURE REQ_EXISTED
   ( ItemType            IN         VARCHAR2
   , ItemKey             IN         VARCHAR2
   , ActID               IN         NUMBER
   , FuncMode            IN         VARCHAR2
   , ResultOut           OUT NOCOPY VARCHAR2
   )
   ;

   PROCEDURE SHIP_EXISTED
   ( ItemType            IN         VARCHAR2
   , ItemKey             IN         VARCHAR2
   , ActID               IN         NUMBER
   , FuncMode            IN         VARCHAR2
   , ResultOut           OUT NOCOPY VARCHAR2
   )
   ;

   PROCEDURE PLAN_EXISTED
   ( ItemType            IN         VARCHAR2
   , ItemKey             IN         VARCHAR2
   , ActID               IN         NUMBER
   , FuncMode            IN         VARCHAR2
   , ResultOut           OUT NOCOPY VARCHAR2
   )
   ;

   PROCEDURE ABORT_PROCESS
   ( P_DELIVERABLE_ID    IN         NUMBER
   )
   ;

   PROCEDURE PERFORMER_EXISTED
   ( ItemType            IN         VARCHAR2
   , ItemKey             IN         VARCHAR2
   , ActID               IN         NUMBER
   , FuncMode            IN         VARCHAR2
   , ResultOut           OUT NOCOPY VARCHAR2
   )
   ;

   PROCEDURE ELIGIBLE_TO_SEND
   ( ItemType            IN         VARCHAR2
   , ItemKey             IN         VARCHAR2
   , ActID               IN         NUMBER
   , FuncMode            IN         VARCHAR2
   , ResultOut           OUT NOCOPY VARCHAR2
   )
   ;

   PROCEDURE LESS_THAN_TARGET_DATE
   ( ItemType            IN         VARCHAR2
   , ItemKey             IN         VARCHAR2
   , ActID               IN         NUMBER
   , FuncMode            IN         VARCHAR2
   , ResultOut           OUT NOCOPY VARCHAR2
   )
   ;


END OKE_DTS_WORKFLOW;

 

/
