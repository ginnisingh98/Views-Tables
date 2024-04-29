--------------------------------------------------------
--  DDL for Package IEX_DISPUTE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_DISPUTE_PVT" AUTHID CURRENT_USER AS
/* $Header: iexvdiss.pls 120.2.12010000.2 2008/08/06 09:04:20 schekuri ship $ */
--Added parameters p_skip_workflow_flag and p_dispute_date
--for bug#6347547 by schekuri on 08-Nov-2007
-- Bug #6777367 bibeura 28-Jan-2008 Added parameter p_batch_source_name
PROCEDURE Create_Dispute(p_api_version      IN NUMBER,
                          p_init_msg_list   IN VARCHAR2 := FND_API.G_FALSE,
                          p_commit          IN VARCHAR2 := FND_API.G_FALSE,
                          p_disp_header_rec IN IEX_DISPUTE_PUB.DISP_HEADER_REC ,
                          p_disp_line_tbl   IN IEX_DISPUTE_PUB.DISPUTE_LINE_TBL,
			  x_request_id      OUT NOCOPY NUMBER,
                          x_return_status   OUT NOCOPY VARCHAR2,
                          x_msg_count       OUT NOCOPY NUMBER,
                          x_msg_data        OUT NOCOPY VARCHAR2,
			  p_skip_workflow_flag   IN VARCHAR2    DEFAULT 'N',
			  p_batch_source_name    IN VARCHAR2    DEFAULT NULL,
			  p_dispute_date	IN DATE	DEFAULT NULL);

/* this procedure will check to see if a particular delinquency_id is in dispute or not
 */
PROCEDURE is_delinquency_dispute(p_api_version         IN  NUMBER,
                                 p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
                                 p_delinquency_id      IN  NUMBER,
                                 x_return_status       OUT NOCOPY VARCHAR2,
                                 x_msg_count           OUT NOCOPY NUMBER,
                                 x_msg_data            OUT NOCOPY VARCHAR2);

--Start bug 6856035 gnramasa 28th May 08
PROCEDURE CANCEL_DISPUTE (p_api_version     IN NUMBER,
                          p_commit          IN VARCHAR2,
			  p_dispute_id      IN NUMBER,
			  p_cancel_comments IN VARCHAR2,
                          x_return_status   OUT NOCOPY VARCHAR2,
                          x_msg_count       OUT NOCOPY NUMBER,
                          x_msg_data        OUT NOCOPY VARCHAR2);
--End bug 6856035 gnramasa 28th May 08

END IEX_DISPUTE_PVT ;

/
