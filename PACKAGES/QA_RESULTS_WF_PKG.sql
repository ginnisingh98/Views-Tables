--------------------------------------------------------
--  DDL for Package QA_RESULTS_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_RESULTS_WF_PKG" AUTHID CURRENT_USER as
/* $Header: qanots.pls 115.1 2002/11/27 19:15:21 jezheng noship $ */




    PROCEDURE process_updates  (itemtype IN VARCHAR2,
    itemkey  IN VARCHAR2,
    actid    IN NUMBER,
    funcmode IN VARCHAR2,
    result   OUT NOCOPY VARCHAR2);

    PROCEDURE set_results_url  (itemtype IN VARCHAR2,
    itemkey  IN VARCHAR2,
    actid    IN NUMBER,
    funcmode IN VARCHAR2,
    result   OUT NOCOPY VARCHAR2);


END qa_results_wf_pkg;

 

/
