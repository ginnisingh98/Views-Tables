--------------------------------------------------------
--  DDL for Package M4R_7B1_WSM_IN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."M4R_7B1_WSM_IN" AUTHID CURRENT_USER AS
/* $Header: M4R7B1OS.pls 120.3 2005/10/27 02:19:00 smuthuav noship $ */


--  Package : M4R_7B1_WSM_IN

--  Purpose : Spec of package M4R_7B1_WSM_IN. This package is called from the Workflow 'M4R 7B1 OSFM Distribute WIP'.

   g_debug_level                NUMBER;
   g_exception_tracking_msg     VARCHAR2(200);
   g_error_code                 NUMBER;
   g_errmsg                     VARCHAR2(2000);
   g_intrl_cntrl_num            NUMBER;
   g_tp_frm_code                NUMBER;

PROCEDURE PROCESS_STAGING (         p_itemtype               IN               VARCHAR2,
                                    p_itemkey                IN               VARCHAR2,
				    p_actid                  IN               NUMBER,
				    p_funcmode               IN               VARCHAR2,
				    x_resultout              IN  OUT NOCOPY   VARCHAR2);


PROCEDURE UPDATE_COLL_HIST (        p_int_ctrl_num           IN         NUMBER,
                             	    p_coll_hist_msg          IN         VARCHAR2,
				    x_resultout              OUT NOCOPY VARCHAR2);


PROCEDURE ADD_MSG_COLL_HIST (       p_err_string             IN VARCHAR2,
                                    p_ref_id2                IN VARCHAR2,
				    p_ref_id3                IN VARCHAR2,
				    p_ref_id4                IN VARCHAR2,
				    p_ref_id5                IN VARCHAR2,
				    p_hdr_id                 IN NUMBER,
				    p_msg_id                 IN NUMBER);


PROCEDURE GET_TP_DETAILS (          p_tp_hdr_id              IN         NUMBER,
                             	    x_party_id               OUT NOCOPY NUMBER,
				    x_party_site_id          OUT NOCOPY NUMBER);


PROCEDURE PROCESS_NOTIFICATION (    p_itemtype               IN              VARCHAR2,
                                    p_itemkey                IN              VARCHAR2,
				    p_actid                  IN              NUMBER,
				    p_funcmode               IN              VARCHAR2,
				    x_resultout              IN OUT NOCOPY   VARCHAR2);


PROCEDURE CHECK_VALID_RECORDS (	    p_itemtype               IN              VARCHAR2,
                                    p_itemkey                IN              VARCHAR2,
				    p_actid                  IN              NUMBER,
				    p_funcmode               IN              VARCHAR2,
				    x_resultout              IN OUT NOCOPY   VARCHAR2);


PROCEDURE CHECK_CP_IMPORT_STATUS ( p_itemtype                IN              VARCHAR2,
                                         p_itemkey           IN              VARCHAR2,
					 p_actid             IN              NUMBER,
					 p_funcmode          IN              VARCHAR2,
					 x_resultout         IN OUT NOCOPY   VARCHAR2) 	;


END M4R_7B1_WSM_IN;

 

/
