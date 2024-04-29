--------------------------------------------------------
--  DDL for Package IEX_WF_BAN_STATUS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_WF_BAN_STATUS_PUB" AUTHID CURRENT_USER AS
/* $Header: iexwfbss.pls 120.0.12010000.2 2009/01/09 02:35:03 gnramasa ship $ */

-- PROCEDURE start workflow
-- DESCRIPTION	This procedure is called to start collections Bankruptcy Status Approval workflow
-- AUTHOR	chewang 2/26/2002	created

PROCEDURE start_workflow
           (p_api_version       IN NUMBER := 1.0,
            p_init_msg_list     IN VARCHAR2 := FND_API.G_FALSE,
            p_commit            IN VARCHAR2 := FND_API.G_FALSE,
            p_user_id   				IN NUMBER,
	    			p_delinquency_id 		IN NUMBER,
            p_party_id 		      IN NUMBER,
	    p_bankruptcy_id	   IN  NUMBER,  --Added for bug 7661724 gnramasa 8th Jan 09
            x_return_status     OUT NOCOPY VARCHAR2,
            x_msg_count         OUT NOCOPY NUMBER,
            x_msg_data          OUT NOCOPY VARCHAR2);

PROCEDURE update_approval_status(
						itemtype    				IN VARCHAR2,
            itemkey     				IN VARCHAR2,
            actid								IN NUMBER,
            funcmode    				IN VARCHAR2,
            result      				OUT NOCOPY VARCHAR2);

procedure update_rejection_status(
						itemtype    				IN VARCHAR2,
            itemkey     				IN VARCHAR2,
            actid								IN NUMBER,
            funcmode    				IN VARCHAR2,
            result      				OUT NOCOPY VARCHAR2);

PROCEDURE set_no_contact_in_tca(
						itemtype    				IN VARCHAR2,
            itemkey     				IN VARCHAR2,
            actid								IN NUMBER,
            funcmode    				IN VARCHAR2,
            result      				OUT NOCOPY VARCHAR2);

procedure turnoff_collection_profile(
						itemtype    				IN VARCHAR2,
            itemkey     				IN VARCHAR2,
            actid								IN NUMBER,
            funcmode    				IN VARCHAR2,
            result      				OUT NOCOPY VARCHAR2);

PROCEDURE turnoff_collections(
						itemtype    				IN VARCHAR2,
            itemkey     				IN VARCHAR2,
            actid								IN NUMBER,
            funcmode    				IN VARCHAR2,
            result      				OUT NOCOPY VARCHAR2);

PROCEDURE no_turnoff_collections(
						itemtype    				IN VARCHAR2,
            itemkey     				IN VARCHAR2,
            actid								IN NUMBER,
            funcmode    				IN VARCHAR2,
            result      				OUT NOCOPY VARCHAR2);

procedure create_strategy(
            p_api_version       IN NUMBER := 1.0,
            p_init_msg_list     IN VARCHAR2 := FND_API.G_FALSE,
            p_commit            IN VARCHAR2 := FND_API.G_FALSE,
	    			p_delinquency_id 		IN NUMBER,
            p_bankruptcy_id 		IN NUMBER,
            p_party_id 		      IN NUMBER,
            x_return_status     OUT NOCOPY VARCHAR2,
            x_msg_count         OUT NOCOPY NUMBER,
            x_msg_data          OUT NOCOPY VARCHAR2);

--Start bug 7661724 gnramasa 8th Jan 09
procedure cancel_strategy_and_workflow(
            p_party_id 		IN NUMBER,
	    p_bankruptcy_id     IN NUMBER,
	    p_disposition_code  IN VARCHAR2);
--End bug 7661724 gnramasa 8th Jan 09

END IEX_WF_BAN_STATUS_PUB;

/
