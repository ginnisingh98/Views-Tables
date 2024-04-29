--------------------------------------------------------
--  DDL for Package M4R_OM_CONF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."M4R_OM_CONF_PKG" AUTHID CURRENT_USER as
/* $Header: M4ROMCFS.pls 120.3 2006/03/02 06:10:04 kkram noship $ */

-- Start of comments
--        API name         : GET_OM_CONF_PARAMS
--        Type             : Private
--        Pre-reqs         : None.
--        Function         : Sets the necessary parameters for the ECX Send Document activity.
--        Version          : Current version         1.0
--                           Initial version         1.0
--        Notes            : This procedure is called from workflow(M4RPOCO).
-- End of comments

PROCEDURE GET_OM_CONF_PARAMS(p_itemtype               IN              VARCHAR2,
                                p_itemkey                IN              VARCHAR2,
                                p_actid                  IN              NUMBER,
                                p_funcmode               IN              VARCHAR2,
                                x_resultout              IN OUT NOCOPY   VARCHAR2);


-- Start of comments
--        API name         : IS_OAG_OR_ROSETTANET
--        Type             : Private
--        Pre-reqs         : None.
--        Function         : Checks whether the message is OAG or Rosettanet and return True if OAG and False if RosettaNet.
--        Version          : Current version         1.0
--                           Initial version         1.0
--        Notes            : This procedure is called from workflow(OEOA).
-- End of comments


PROCEDURE IS_OAG_OR_ROSETTANET(p_itemtype                IN              VARCHAR2,
                                p_itemkey                IN              VARCHAR2,
                                p_actid                  IN              NUMBER,
                                p_funcmode               IN              VARCHAR2,
                                x_resultout              IN OUT NOCOPY   VARCHAR2);

FUNCTION UPDATE_CH_OM_EVENT_SUB(
        p_subscription_guid             IN RAW,
        p_event                         IN OUT NOCOPY WF_EVENT_T
) RETURN VARCHAR2;

END;

 

/
