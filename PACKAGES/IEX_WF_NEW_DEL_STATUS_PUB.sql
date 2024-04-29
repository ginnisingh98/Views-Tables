--------------------------------------------------------
--  DDL for Package IEX_WF_NEW_DEL_STATUS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_WF_NEW_DEL_STATUS_PUB" AUTHID CURRENT_USER AS
/* $Header: iexwfdws.pls 120.2 2005/12/12 19:28:42 ehuh ship $ */

PROCEDURE invoke_new_del_status_wf
    (
      p_api_version           IN NUMBER := 1.0,
      p_init_msg_list         IN VARCHAR2, -- fix a bug 3975142  := FND_API.G_FALSE,
      p_commit                IN VARCHAR2, -- fix a bug 3975142  := FND_API.G_FALSE,
      p_delinquency_id        IN NUMBER,
      p_object_id             IN NUMBER,
      p_object_type           IN VARCHAR2,
      p_user_id               IN NUMBER,
      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2
);

PROCEDURE invoke_upd_del_status_wf
(
      p_api_version           IN NUMBER := 1.0,
      p_init_msg_list         IN VARCHAR2, -- fix a bug 3975142  := FND_API.G_FALSE,
      p_commit                IN VARCHAR2, -- fix a bug 3975142  := FND_API.G_FALSE,
      p_delinquency_id        IN NUMBER,
      p_object_id             IN NUMBER,
      p_object_type           IN VARCHAR2,
      p_user_id               IN NUMBER,
      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2
);


END IEX_WF_NEW_DEL_STATUS_PUB;

 

/
