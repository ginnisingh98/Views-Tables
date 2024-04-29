--------------------------------------------------------
--  DDL for Package IEM_ROUTE_RUN_PROC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_ROUTE_RUN_PROC_PVT" AUTHID CURRENT_USER AS
/* $Header: iemvruns.pls 115.6 2002/12/14 02:25:08 liangxia noship $ */

--
--
-- Purpose: Assistant api to dynamically run procedure.
--
-- MODIFICATION HISTORY
-- Person      Date         Comments
--  Liang Xia   5/29/2002  created
--  Liang Xia   12/6/2002  Fixed GSCC warning: NOCOPY, no G_MISS ..
--  Liang Xia   12/13/2002 Shipped dummy procedures for testing Dyanmic Classification,
--                         Route and Excecute External Procedure/workflow
-- ---------   ------  ------------------------------------------

  G_key_value             IEM_ROUTE_PUB.keyVals_tbl_type;


--  Start of Comments
--  API name    : run_Procedure
--  Type        : Private
--  Function    : This procedure run a procedure
--  Pre-reqs    : None.
--  Parameters  :

 PROCEDURE run_Procedure (
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
            	 p_procedure_name      IN   VARCHAR2,
  				 p_key_value   	       IN   IEM_ROUTE_PUB.keyVals_tbl_type,
                 p_param_type          IN   VARCHAR2,
                 x_result              OUT  NOCOPY VARCHAR2,
                 x_return_status	   OUT  NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT	NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT	NOCOPY VARCHAR2
			 );

PROCEDURE validProcedure
                  (     p_api_version_number      IN  NUMBER,
                        P_init_msg_list           IN  VARCHAR2 := null,
                        p_commit                  IN  VARCHAR2 := null,
                        p_ProcName                IN  VARCHAR2,
                        p_return_type             IN  VARCHAR2,
                        x_return_status           OUT NOCOPY VARCHAR2,
                        x_msg_count               OUT NOCOPY NUMBER,
                        x_msg_data                OUT NOCOPY VARCHAR2);


--  Start of Comments
--  API name    : dummy_procedure_number
--  Type        : Private
--  Function    : This procedure is used to test Dynamic Classification, Route
--  Pre-reqs    : None.
--  Parameters  :
procedure dummy_procedure_number( key_value IN IEM_ROUTE_PUB.keyVals_tbl_type,
                               result OUT NOCOPY NUMBER) ;


--  Start of Comments
--  API name    : dummy_procedure_varchar
--  Type        : Private
--  Function    : This procedure is used to test Dynamic Classification, Route
--  Pre-reqs    : None.
--  Parameters  :
procedure dummy_procedure_varchar( key_value IN IEM_ROUTE_PUB.keyVals_tbl_type,
                               result OUT NOCOPY VARCHAR2) ;

--  Start of Comments
--  API name    : dummy_procedure_stop
--  Type        : Private
--  Function    : This procedure is used to test Dyanmic Tag, Email Process Rule:Execute
--                External Procedure/Workflow.
--  Pre-reqs    : None.
--  Parameters  :
procedure dummy_procedure_stop( key_value IN IEM_TAGPROCESS_PUB.keyVals_tbl_type,
                               result OUT NOCOPY VARCHAR2);

--  Start of Comments
--  API name    : dummy_procedure_stop
--  Type        : Private
--  Function    : This procedure is used to test Dynamic Tag, Email Process Rule:Execute
--                External Procedure/Workflow.
--  Pre-reqs    : None.
--  Parameters  :
procedure dummy_procedure_continue( key_value IN IEM_TAGPROCESS_PUB.keyVals_tbl_type,
                               result OUT NOCOPY VARCHAR2);

 --  Start of Comments
--  API name    : dummy_procedure
--  Type        : Private
--  Function    : This procedure is used to test, Dyanmic Tag, Email Process Rule:Execute
--                External Procedure/Workflow.
--  Pre-reqs    : None.
--  Parameters  :
procedure dummy_procedure( key_value IN IEM_TAGPROCESS_PUB.keyVals_tbl_type,
                               result OUT NOCOPY VARCHAR2);

END IEM_ROUTE_RUN_PROC_PVT;

 

/
