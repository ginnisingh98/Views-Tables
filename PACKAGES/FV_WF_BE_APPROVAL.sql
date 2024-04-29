--------------------------------------------------------
--  DDL for Package FV_WF_BE_APPROVAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_WF_BE_APPROVAL" AUTHID CURRENT_USER AS
    /* $Header: FVBEWFPS.pls 120.5 2005/08/16 15:30:24 pmamdaba ship $ */

-- BCPSA-BE enhancements
-- Added application_id,doc_type,event_type,accounting_date,calling_sequence and bc_mode parameters

PROCEDURE Main(
        errbuf          OUT NOCOPY     VARCHAR2,
        retcode         OUT NOCOPY     NUMBER,
	p_sob_id		IN			NUMBER,
        p_submitter_id   IN         NUMBER,
        p_approver_id    IN         NUMBER,
        p_doc_id         IN         NUMBER,
        p_note           IN         VARCHAR2,
        p_to_rpr_doc_id  IN         NUMBER,
        p_user_id        IN         NUMBER,
        p_resp_id        IN         NUMBER);


PROCEDURE VerifyStatus(itemtype VARCHAR2,
                        itemkey VARCHAR2,
                        actid   NUMBER,
                        funcmode VARCHAR2,
                        resultout IN OUT NOCOPY VARCHAR2 );

PROCEDURE CheckRPRDocId(itemtype VARCHAR2,
                        itemkey VARCHAR2,
                        actid   NUMBER,
                        funcmode VARCHAR2,
                        resultout IN OUT NOCOPY VARCHAR2 ) ;

PROCEDURE GetRPRDetails(itemtype VARCHAR2,
                        itemkey VARCHAR2,
                        actid   NUMBER,
                        funcmode VARCHAR2,
                        resultout IN OUT NOCOPY VARCHAR2 );

PROCEDURE ApproverPostNtf(itemtype VARCHAR2,
                        itemkey VARCHAR2,
                        actid   NUMBER,
                        funcmode VARCHAR2,
                        resultout IN OUT NOCOPY VARCHAR2 );

PROCEDURE Update_Status(p_sob_id  NUMBER,
                        p_doc_id NUMBER,
                        p_doc_status VARCHAR2,
                        errbuf OUT NOCOPY VARCHAR2,
                        retcode OUT NOCOPY NUMBER) ;

PROCEDURE ApproveDoc(itemtype VARCHAR2,
                        itemkey VARCHAR2,
                        actid   NUMBER,
                        funcmode VARCHAR2,
                        resultout IN OUT NOCOPY VARCHAR2 );

PROCEDURE TimeoutPostNtf(itemtype VARCHAR2,
                        itemkey VARCHAR2,
                        actid   NUMBER,
                        funcmode VARCHAR2,
                        resultout IN OUT NOCOPY VARCHAR2 );

PROCEDURE Get_Revision_Number(sob_id NUMBER,
                           doc_id NUMBER,
                           errbuf OUT NOCOPY VARCHAR2,
                           retcode OUT NOCOPY NUMBER) ;

PROCEDURE Get_Orig_System(p_user_id NUMBER,
                     p_orig_system OUT NOCOPY VARCHAR2,
                     p_new_user_id OUT NOCOPY NUMBER,
                     errbuf OUT NOCOPY VARCHAR2,
                     retcode OUT NOCOPY NUMBER) ;

PROCEDURE Get_Trx_Doc_Details( document_id IN VARCHAR2,
                                display_type IN VARCHAR2,
                                document IN OUT NOCOPY VARCHAR2,
                                document_type IN OUT NOCOPY VARCHAR2) ;

PROCEDURE Get_RPR_Doc_Details( document_id IN VARCHAR2,
                                display_type IN VARCHAR2,
                                document IN OUT NOCOPY VARCHAR2,
                                document_type IN OUT NOCOPY VARCHAR2) ;

PROCEDURE Build_Document(rpr_flag VARCHAR2,
                        disp_type VARCHAR2,
                        doc   OUT NOCOPY VARCHAR2,
			errbuf    OUT NOCOPY VARCHAR2,
                        retcode   OUT NOCOPY NUMBER) ;

END Fv_Wf_Be_Approval;

 

/
