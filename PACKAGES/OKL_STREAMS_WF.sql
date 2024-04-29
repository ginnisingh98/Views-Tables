--------------------------------------------------------
--  DDL for Package OKL_STREAMS_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_STREAMS_WF" AUTHID CURRENT_USER AS
/* $Header: OKLRPWFS.pls 120.1 2005/10/30 03:40:53 appldev noship $ */
  SUBTYPE LOG_MSG_TBL_TYPE IS OKL_STREAMS_UTIL.LOG_MSG_TBL;

  G_RET_STS_SUCCESS		            CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR		            CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR		        CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_UNEXP_ERROR;
  G_FALSE				            CONSTANT VARCHAR2(1)   :=  OKL_API.G_FALSE;

  G_FILENAME_PRE	CONSTANT VARCHAR2(15) := 'OKLSTXMLG_';
  G_FILENAME_EXT	CONSTANT VARCHAR2(15) := '.log';

 PROCEDURE process(itemtype	  in varchar2,
	       itemkey	  in varchar2,
	       actid	  in number,
	       funcmode	  in varchar2,
	       resultout  in out NOCOPY varchar2);

  PROCEDURE REPORT_ERROR(ITEMTYPE  IN VARCHAR2,
	                 ITEMKEY   IN VARCHAR2,
	                 ACTID	   IN NUMBER,
	                 FUNCMODE  IN VARCHAR2,
	                 RESULTOUT IN OUT NOCOPY VARCHAR2);

END OKL_STREAMS_WF;

 

/
