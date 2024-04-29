--------------------------------------------------------
--  DDL for Package OKL_SUBSIDY_POOL_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SUBSIDY_POOL_WF" AUTHID CURRENT_USER AS
/* $Header: OKLRSWFS.pls 120.1 2005/10/30 03:17:26 appldev noship $ */

  G_APP_NAME    CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  G_PKG_NAME    CONSTANT VARCHAR2(200) := 'OKL_SUBSIDY_POOL_WF';
  G_API_TYPE    CONSTANT VARCHAR2(200)  := '_PVT';

  PROCEDURE check_approval_process(itemtype	IN VARCHAR2
				                               ,itemkey  	IN VARCHAR2
			                 	              ,actid		IN NUMBER
			                                ,funcmode	IN VARCHAR2
				                               ,resultout OUT NOCOPY VARCHAR2);

  PROCEDURE update_pool_approval_status(itemtype	IN VARCHAR2
                                        ,itemkey  	IN VARCHAR2
                                        ,actid		IN NUMBER
                                        ,funcmode	IN VARCHAR2
                                        ,resultout OUT NOCOPY VARCHAR2);

  PROCEDURE update_line_approval_status(itemtype	IN VARCHAR2
                                        ,itemkey  	IN VARCHAR2
                                        ,actid		IN NUMBER
                                        ,funcmode	IN VARCHAR2
                                        ,resultout OUT NOCOPY VARCHAR2);

  PROCEDURE get_subsidy_pool_approver (itemtype  IN VARCHAR2
                                       ,itemkey   IN VARCHAR2
                                       ,actid     IN NUMBER
                                       ,funcmode  IN VARCHAR2
                                       ,resultout OUT NOCOPY VARCHAR2);

  PROCEDURE get_pool_msg_doc(document_id   IN VARCHAR2,
                            display_type  IN VARCHAR2,
                            document      IN OUT nocopy VARCHAR2,
                            document_type IN OUT nocopy VARCHAR2);

  PROCEDURE get_pool_line_msg_doc(document_id   IN VARCHAR2,
                            display_type  IN VARCHAR2,
                            document      IN OUT nocopy VARCHAR2,
                            document_type IN OUT nocopy VARCHAR2);


  PROCEDURE set_msg_attributes (itemtype  IN VARCHAR2
                                ,itemkey   IN VARCHAR2
                                ,actid     IN NUMBER
                                ,funcmode  IN VARCHAR2
                                ,resultout OUT NOCOPY VARCHAR2);

  PROCEDURE  process_pool_ame (itemtype  IN VARCHAR2
                                ,itemkey   IN VARCHAR2
                                ,actid     IN NUMBER
                                ,funcmode  IN VARCHAR2
                                ,resultout OUT NOCOPY VARCHAR2);

  PROCEDURE process_pool_line_ame(itemtype  IN VARCHAR2
                                ,itemkey   IN VARCHAR2
                                ,actid     IN NUMBER
                                ,funcmode  IN VARCHAR2
                                ,resultout OUT NOCOPY VARCHAR2);

  PROCEDURE raise_pool_event_approval(p_api_version    IN  NUMBER
                                      ,p_init_msg_list  IN  VARCHAR2
                                      ,x_return_status  OUT NOCOPY VARCHAR2
                                      ,x_msg_count      OUT NOCOPY NUMBER
                                      ,x_msg_data       OUT NOCOPY VARCHAR2
                                      ,p_subsidy_pool_id IN okl_subsidy_pools_b.id%TYPE);

  PROCEDURE raise_budget_event_approval(p_api_version     IN 	NUMBER
                                        ,p_init_msg_list   IN  VARCHAR2
                                        ,x_return_status   OUT NOCOPY VARCHAR2
                                        ,x_msg_count       OUT NOCOPY NUMBER
                                        ,x_msg_data        OUT NOCOPY VARCHAR2
                                        ,p_subsidy_pool_budget_id IN okl_subsidy_pool_budgets_b.id%TYPE);

END okl_subsidy_pool_wf;

 

/
