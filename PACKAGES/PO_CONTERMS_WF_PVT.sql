--------------------------------------------------------
--  DDL for Package PO_CONTERMS_WF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_CONTERMS_WF_PVT" AUTHID CURRENT_USER AS
/* $Header: POXVWCTS.pls 115.7 2004/02/03 00:45:29 sahegde noship $ */

-- Contracts business events codes TBL Type
SUBTYPE Event_tbl_type IS OKC_MANAGE_DELIVERABLES_GRP.BUSDOCDATES_TBL_TYPE;

-- Checks if contract terms were changed in current revision
FUNCTION CONTRACT_TERMS_CHANGED(itemtype	IN VARCHAR2,
                                Itemkey      IN VARCHAR2)
return VARCHAR2;

--returns event codes and their due dates for deliverables
PROCEDURE Get_DELIVERABLE_EVENTS (p_po_header_id IN NUMBER,
                                  p_action_code IN VARCHAR2 DEFAULT 'A',
                                  p_doc_subtype IN VARCHAR2,
                                  x_event_tbl   OUT NOCOPY EVENT_TBL_TYPE);
--Get last update date for conterms date fields
PROCEDURE UPDATE_CONTERMS_DATES(
                             p_po_header_id        IN NUMBER,
                             p_po_doc_type         IN VARCHAR2,
                             p_po_doc_subtype      IN VARCHAR2,
                             p_conterms_exist_flag IN VARCHAR2,
                             x_return_status       OUT NOCOPY VARCHAR2,
                             x_msg_data            OUT NOCOPY VARCHAR2,
                             x_msg_count           OUT NOCOPY NUMBER);

-- informs contracts about approval
PROCEDURE UPDATE_CONTRACT_TERMS(p_po_header_id        IN NUMBER,
                                p_signed_date         IN DATE,
                                x_return_status       OUT NOCOPY VARCHAR2,
                                x_msg_data            OUT NOCOPY VARCHAR2,
                                x_msg_count           OUT NOCOPY NUMBER);

--Checks if any deviation from standard Contract template
PROCEDURE IS_STANDARD_CONTRACT (itemtype IN VARCHAR2,
                                itemkey  IN VARCHAR2,
                                actid    IN NUMBER,
                                funcmode IN VARCHAR2,
                                result   OUT NOCOPY VARCHAR2);
--Checks if template expired
PROCEDURE IS_CONTRACT_TEMPLATE_EXPIRED(itemtype IN VARCHAR2,
                                   itemkey  IN VARCHAR2,
                                   actid    IN NUMBER,
                                   funcmode IN VARCHAR2,
                                   result   OUT NOCOPY VARCHAR2);
--checks if articles attached to po
PROCEDURE IS_CONTRACT_ARTICLES_EXIST (itemtype IN VARCHAR2,
                                   itemkey  IN VARCHAR2,
                                   actid    IN NUMBER,
                                   funcmode IN VARCHAR2,
                                   result   OUT NOCOPY VARCHAR2);

--Checks if articles amended in this revision
PROCEDURE IS_CONTRACT_ARTICLES_AMENDED(itemtype IN VARCHAR2,
                                   itemkey  IN VARCHAR2,
                                   actid    IN NUMBER,
                                   funcmode IN VARCHAR2,
                                   result   OUT NOCOPY VARCHAR2);

--Checks if deliverables attached to purchase order
PROCEDURE IS_CONTRACT_DELIVRABLS_EXIST(itemtype IN VARCHAR2,
                                   itemkey  IN VARCHAR2,
                                   actid    IN NUMBER,
                                   funcmode IN VARCHAR2,
                                   result   OUT NOCOPY VARCHAR2);

--Checks if deliverables amended in this revision
PROCEDURE IS_CONTRACT_DELIVRABLS_AMENDED(itemtype IN VARCHAR2,
                                   itemkey  IN VARCHAR2,
                                   actid    IN NUMBER,
                                   funcmode IN VARCHAR2,
                                   result   OUT NOCOPY VARCHAR2);

--Cancels deliverables associated with the PO
PROCEDURE cancel_deliverables (p_bus_doc_id           IN NUMBER
                    ,p_bus_doc_type         IN VARCHAR2
                    ,p_bus_doc_subtype      IN VARCHAR2
                    ,p_bus_doc_version      IN NUMBER
                    ,p_event_code           IN VARCHAR2
                    ,p_event_date           IN DATE
                    ,p_busdocdates_tbl      IN EVENT_TBL_TYPE
                    ,x_return_status        OUT NOCOPY VARCHAR2  );


End PO_CONTERMS_WF_PVT;

 

/
