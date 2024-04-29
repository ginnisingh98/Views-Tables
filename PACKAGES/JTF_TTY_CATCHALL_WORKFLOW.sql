--------------------------------------------------------
--  DDL for Package JTF_TTY_CATCHALL_WORKFLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TTY_CATCHALL_WORKFLOW" AUTHID CURRENT_USER AS
/* $Header: jtfvwkfs.pls 120.0 2005/06/02 18:23:16 appldev ship $ */
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TTY_CATCHALL_WORKFLOW
--    PURPOSE
--
--      Procedures:
--         (see below for specification)
--
--
--
--
--    NOTES
--
--
--
--
--    HISTORY
--      12/15/02    JRADHAKR         CREATED
--
--
--    End of Comments
--
-- Data Types: Records

TYPE workflow_param_rec_type IS RECORD
(
    ACCESS_ID       NUMBER
  , NAME            VARCHAR2(360)
  , POSTAL_CODE     VARCHAR2(60)
  , STATE           VARCHAR2(60)
  , TERRGROUP_ID    NUMBER
  , PARTY_ID        NUMBER
);

Procedure Process_catch_all_rec
    ( x_return_status         OUT NOCOPY  VARCHAR2
    , x_error_message         OUT NOCOPY  VARCHAR2
    );

Procedure  Get_workflow_details
    ( p_TERR_GROUP_ID         IN  NUMBER
    , x_WORKFLOW_ITEM_TYPE    OUT NOCOPY  VARCHAR2
    , x_WORKFLOW_PROCESS_NAME OUT NOCOPY  VARCHAR2
    , x_return_status         OUT NOCOPY  VARCHAR2
    , x_error_message         OUT NOCOPY  VARCHAR2
    );

Procedure Start_Workflow_Process
  ( p_item_type         IN Varchar2
   ,p_wf_process        IN Varchar2
   ,p_wf_params         IN JTF_TTY_CATCHALL_WORKFLOW.workflow_param_rec_type
   ,x_return_status     OUT NOCOPY  VARCHAR2
  );


END  JTF_TTY_CATCHALL_WORKFLOW;

 

/
