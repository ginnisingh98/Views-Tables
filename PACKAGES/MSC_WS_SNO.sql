--------------------------------------------------------
--  DDL for Package MSC_WS_SNO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_WS_SNO" AUTHID CURRENT_USER AS
/* $Header: MSCWSNOS.pls 120.5.12010000.1 2008/05/02 19:09:19 appldev ship $ */

  -- =============================================================
  -- Desc: This procedure is invoke from web services to extract SNO
  --       plan model.  It mirrors all the parameters from the Launch
  --       SNO Plan concurrent program.
  -- Input:
  --        solveOnServer can be conditionally be Y or N
  -- Output:  possible output status value include following
  --       INVALID_PLANID, INVALID_FND_USERID
  -- =============================================================

  PROCEDURE     GENERATE_SNO_MODEL (
                           processId          OUT NOCOPY NUMBER,
                           status             OUT NOCOPY VARCHAR2,
                           userId             IN NUMBER,
                           respId             IN NUMBER,
                           planId             IN NUMBER,
                           solveOnServer      IN VARCHAR2
                          ) ;


  PROCEDURE     GENERATE_SNO_MODEL_PUBLIC (
                           processId          OUT NOCOPY NUMBER,
                           status             OUT NOCOPY VARCHAR2,
                           UserName               IN VARCHAR2,
			   RespName     IN VARCHAR2,
			   RespApplName IN VARCHAR2,
			   SecurityGroupName      IN VARCHAR2,
			   Language            IN VARCHAR2,
                           planId             IN NUMBER,
                           solveOnServer      IN VARCHAR2
                          ) ;

  -- =============================================================
  -- Desc: This procedure is invoke from web services to publish SNO
  --       plan.  It mirrors all the parameters from the Publish
  --       SNO Plan concurrent program.
  -- Input:
  --        solveOnServer can be conditionally be Y or N
  -- Output:  possible output status value include following
  --       INVALID_PLANID, INVALID_FND_USERID
  -- =============================================================

  PROCEDURE     PUBLISH_SNO_PLAN (
                           processId          OUT NOCOPY NUMBER,
                           status             OUT NOCOPY VARCHAR2,
                           userId             IN NUMBER,
                           respId             IN NUMBER,
                           planId             IN NUMBER,
                           appProfile         IN VARCHAR2
                          ) ;

   PROCEDURE     PUBLISH_SNO_PLAN_PUBLIC (
                           processId          OUT NOCOPY NUMBER,
                           status             OUT NOCOPY VARCHAR2,
                            UserName               IN VARCHAR2,
			   RespName     IN VARCHAR2,
			   RespApplName IN VARCHAR2,
			   SecurityGroupName      IN VARCHAR2,
			   Language            IN VARCHAR2,
                           planId             IN NUMBER,
                           appProfile         IN VARCHAR2
                          ) ;
END MSC_WS_SNO;

/
