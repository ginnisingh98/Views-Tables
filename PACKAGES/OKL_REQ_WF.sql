--------------------------------------------------------
--  DDL for Package OKL_REQ_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_REQ_WF" AUTHID CURRENT_USER AS
/* $Header: OKLRRQWS.pls 115.2 2002/11/30 08:58:53 spillaip noship $ */

---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			      CONSTANT VARCHAR2(200) := okl_api.G_FND_APP;
  G_REQUIRED_VALUE		  CONSTANT VARCHAR2(200) := 'OKL_REQUIRED_VALUE';
  G_INVALID_VALUE		  CONSTANT VARCHAR2(200) := okl_api.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		  CONSTANT VARCHAR2(200) := 'COL_NAME';
  G_COL_NAME1_TOKEN		  CONSTANT VARCHAR2(200) := 'COL_NAME1';
  G_COL_NAME2_TOKEN		  CONSTANT VARCHAR2(200) := 'COL_NAME2';
  G_PARENT_TABLE_TOKEN	  CONSTANT VARCHAR2(200) := 'PARENT_TABLE';
  G_UNEXPECTED_ERROR	  CONSTANT VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN         CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN         CONSTANT VARCHAR2(200) := 'SQLCODE';
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_REQ_WF';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  'OKL';

---------------------------------------------------------------------
-- GLOBAL EXCEPTION
------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION   EXCEPTION;

   --------------------------------------------------------------------------
  -- Concurrent API to invoke the workflow for requesting approval of a Cure
  ---------------------------------------------------------------------------

  PROCEDURE invoke_workflow(
     errbuf                     OUT NOCOPY VARCHAR2,
     retcode                    OUT NOCOPY NUMBER);
  ---------------------------------------------------------------------------

  PROCEDURE raise_request_business_event( p_trans_id   IN NUMBER);


  PROCEDURE Request_Approved(itemtype	in varchar2,
       				 itemkey  	in varchar2,
    				 actid		in number,
    				 funcmode	in varchar2,
    				 resultout out nocopy varchar2	);
  PROCEDURE Request_Rejected(itemtype	in varchar2,
				             itemkey  	in varchar2,
                   			actid		in number,
                 			funcmode	in varchar2,
                			resultout out nocopy varchar2);

  PROCEDURE populate_notif_attributes(itemtype	in varchar2,
				             itemkey  	in varchar2,
                   			actid		in number,
                 			funcmode	in varchar2,
                			resultout out nocopy varchar2);

END OKL_REQ_WF;

 

/
