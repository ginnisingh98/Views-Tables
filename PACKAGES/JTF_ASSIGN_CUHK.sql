--------------------------------------------------------
--  DDL for Package JTF_ASSIGN_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_ASSIGN_CUHK" AUTHID CURRENT_USER AS
/* $Header: jtfamwfs.pls 120.2 2005/10/21 03:58:36 sbarat ship $ */


-- ********************************************************************************

-- Start of Comments

--     	Package Name	: JTF_ASSIGN_CUHK
--	Purpose		: Joint Task Force Core Foundation Assignment Manager
--                        API for Workflow execution.
--	Procedures	: (See below for specification)
--	Notes		: This package is publicly available for use
--	History		: 01/04/00	VVUYYURU	created
--                        21/10/05 Added NOCOPY by SBARAT to fix GSCC error
--

-- End of Comments

-- *******************************************************************************

-- Start of comments

--	API name 	: OK_TO_LAUNCH_WORKFLOW
--	Type		:
--	Function	: Determines if it is OK to launch the workflow.
--	Pre-reqs	: None

--	Parameters	:

--	IN		: p_api_version   	IN 	NUMBER	Required
--			  p_init_msg_list 	IN 	VARCHAR2 Optional
--					      	DEFAULT = FND_API.G_FALSE
--                        p_commit              IN      VARCHAR2 optional
--					      	DEFAULT = FND_API.G_FALSE

--     OUT		: x_return_status        OUT     VARCHAR2(1)
--			  x_msg_count            OUT     NUMBER
--			  x_msg_data             OUT     VARCHAR2(2000)


--	Version		: Current version	 1.0
--			  Initial version 	 1.0
--
--	Notes		:
--

-- End of comments

-- *********************************************************************************


  G_PKG_NAME  CONSTANT VARCHAR2(30):= 'JTF_ASSIGN_CUHK';


  FUNCTION OK_TO_LAUNCH_WORKFLOW
    (   p_api_version                         IN  NUMBER,
        p_init_msg_list                       IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
        x_return_status                       OUT NOCOPY VARCHAR2,
        x_msg_count                           OUT NOCOPY NUMBER,
        x_msg_data                            OUT NOCOPY VARCHAR2
    ) RETURN BOOLEAN;


END JTF_ASSIGN_CUHK;

 

/
