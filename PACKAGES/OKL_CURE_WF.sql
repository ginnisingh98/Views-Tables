--------------------------------------------------------
--  DDL for Package OKL_CURE_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CURE_WF" AUTHID CURRENT_USER as
/* $Header: OKLCOWFS.pls 115.1 2003/04/24 22:03:15 jsanju noship $ */


  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME              CONSTANT VARCHAR2(200)
                                            := 'OKL_CURE_WF';
  G_APP_NAME              CONSTANT VARCHAR2(3)   := OKC_API.G_APP_NAME;
  G_UNEXPECTED_ERROR      CONSTANT VARCHAR2(200)
                                            := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
  PG_DEBUG NUMBER     := TO_NUMBER(NVL(FND_PROFILE.value('OKL_DEBUG_LEVEL'), '20'));



PROCEDURE  approve_cure_reports
             (  p_api_version          IN NUMBER
               ,p_init_msg_list        IN VARCHAR2 DEFAULT OKC_API.G_TRUE
               ,p_commit               IN VARCHAR2 DEFAULT OKC_API.G_FALSE
               ,p_report_id            IN NUMBER
               ,x_return_status       OUT NOCOPY VARCHAR2
               ,x_msg_count           OUT NOCOPY NUMBER
               ,x_msg_data            OUT NOCOPY VARCHAR2
               );


/**
  called from the workflow to update cure reports based on
  the approval
 **/

  PROCEDURE set_approval_status (itemtype        in varchar2,
                                 itemkey         in varchar2,
                                 actid           in number,
                                 funcmode        in varchar2,
                                 result       out nocopy varchar2);


  PROCEDURE set_reject_status (itemtype        in varchar2,
                                 itemkey         in varchar2,
                                 actid           in number,
                                 funcmode        in varchar2,
                                 result       out nocopy varchar2);


end OKL_CURE_WF;

 

/
