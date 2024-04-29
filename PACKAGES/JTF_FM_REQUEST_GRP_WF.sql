--------------------------------------------------------
--  DDL for Package JTF_FM_REQUEST_GRP_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_FM_REQUEST_GRP_WF" AUTHID CURRENT_USER AS
/* $Header: jtffmwfs.pls 115.2 2000/02/15 10:51:16 pkm ship     $ */

---------------------------------------------------------------------
-- PROCEDURE
--    StartFulfillProcess
--
-- PURPOSE
--    Start the fulfillment workflow process
--
-- PARAMETERS
--
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE StartFulfillProcess(
  l_api_version        IN NUMBER,
  l_commit             IN VARCHAR2,
  l_validation_level   IN NUMBER,
  l_content_xml        IN VARCHAR2,
  l_request_id         IN NUMBER,
  l_template_id        IN NUMBER,
  l_status             OUT VARCHAR2,
  l_result             OUT VARCHAR2 );

---------------------------------------------------------------------
-- PROCEDURE
--    Resubmit_Request
--
-- PURPOSE
--    Calling JTF_FM_REQUEST_GRP.SUBMIT_REQUEST
--
-- PARAMETERS
--
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE submit_request (
  itemtype  IN VARCHAR2,
    itemkey   IN VARCHAR2,
    actid     IN NUMBER,
    funcmode  IN VARCHAR2,
    resultout OUT VARCHAR2);

---------------------------------------------------------------------
-- PROCEDURE
--    Resubmit_Request
--
-- PURPOSE
--    Calling JTF_FM_REQUEST_GRP.RESUBMIT_REQUEST
--
-- PARAMETERS
--
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE resubmit_request (
  itemtype  IN VARCHAR2,
    itemkey   IN VARCHAR2,
    actid     IN NUMBER,
    funcmode  IN VARCHAR2,
    resultout OUT VARCHAR2);

END jtf_fm_request_grp_wf ;

 

/
