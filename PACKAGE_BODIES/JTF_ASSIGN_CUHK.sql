--------------------------------------------------------
--  DDL for Package Body JTF_ASSIGN_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_ASSIGN_CUHK" AS
/* $Header: jtfamwfb.pls 120.2 2005/10/21 03:59:02 sbarat ship $ */


-- ********************************************************************************

-- Start of Comments

--     	Package Name	: JTF_ASSIGN_CUHK
--	Purpose		: Joint Task Force Core Foundation Assignment Manager
--                        API for Workflow execution.
--	Procedures	: (See below for specification)
--	Notes		: This package is publicly available for use
--	History		: 01/04/00 ** VVUYYURU ** Vijay Vuyyuru ** created
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


  FUNCTION OK_TO_LAUNCH_WORKFLOW
    (   p_api_version                         IN  NUMBER,
        p_init_msg_list                       IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
        x_return_status                       OUT NOCOPY VARCHAR2,
        x_msg_count                           OUT NOCOPY NUMBER,
        x_msg_data                            OUT NOCOPY VARCHAR2
    ) RETURN BOOLEAN IS

    l_api_name                                VARCHAR2(30)  := 'OK_TO_LAUNCH_WORKFLOW';
    l_api_version                             NUMBER        := 1.0;

  BEGIN

    SAVEPOINT jtf_assign_wf;


    /* Standard call to check for call compatibility */

    IF NOT fnd_api.compatible_api_call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;


    /* Initialize message list if p_init_msg_list is set to TRUE */

    IF fnd_api.to_boolean (p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;




    /* Standard call to get message count and
       the message information */

    FND_MSG_PUB.Count_And_Get
    (
      p_count => x_msg_count,
      p_data  => x_msg_data
    );


    x_return_status := fnd_api.g_ret_sts_success;


    RETURN (TRUE);


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO jtf_assign_wf;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );
    RETURN (FALSE);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO jtf_assign_wf;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );
    RETURN (FALSE);

    WHEN OTHERS THEN
      ROLLBACK TO jtf_assign_wf;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )THEN
        FND_MSG_PUB.Add_Exc_Msg
        (
          G_PKG_NAME,
          l_api_name
        );
      END IF;

      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
       );
    RETURN (FALSE);

  END OK_TO_LAUNCH_WORKFLOW;


END JTF_ASSIGN_CUHK;


/
