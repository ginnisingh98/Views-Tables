--------------------------------------------------------
--  DDL for Package FUN_NET_APPROVAL_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_NET_APPROVAL_WF" AUTHID CURRENT_USER AS
/* $Header: funntwfs.pls 120.1 2006/07/20 15:39:59 akonatha noship $ */

    PROCEDURE Raise_Approval_Event(
                                --p_event_key       IN VARCHAR2,
                                --p_event_name      IN VARCHAR2,
                                p_batch_id IN NUMBER);


    PROCEDURE Initialize(p_item_type    IN VARCHAR2,
                        p_item_key     IN VARCHAR2,
                        p_actid        IN NUMBER,
                        p_funmode      IN VARCHAR2,
                        p_result       OUT NOCOPY VARCHAR2);


    PROCEDURE Validate_Settle_Batch(p_item_type    IN VARCHAR2,
                        p_item_key     IN VARCHAR2,
                        p_actid        IN NUMBER,
                        p_funmode      IN VARCHAR2,
                        p_result       OUT NOCOPY VARCHAR2);

    PROCEDURE Get_NoResponse_Action(p_item_type    IN VARCHAR2,
                        p_item_key     IN VARCHAR2,
                        p_actid        IN NUMBER,
                        p_funmode      IN VARCHAR2,
                        p_result       OUT NOCOPY VARCHAR2);


    PROCEDURE Update_Batch_status_rej(p_item_type    IN VARCHAR2,
                        p_item_key     IN VARCHAR2,
                        p_actid        IN NUMBER,
                        p_funmode      IN VARCHAR2,
                        p_result       OUT NOCOPY VARCHAR2);

    PROCEDURE Update_Batch_status_err(p_item_type    IN VARCHAR2,
                        p_item_key     IN VARCHAR2,
                        p_actid        IN NUMBER,
                        p_funmode      IN VARCHAR2,
                        p_result       OUT NOCOPY VARCHAR2);


END FUN_NET_APPROVAL_WF; -- Package spec

 

/
