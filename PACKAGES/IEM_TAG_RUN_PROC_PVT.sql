--------------------------------------------------------
--  DDL for Package IEM_TAG_RUN_PROC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_TAG_RUN_PROC_PVT" AUTHID CURRENT_USER AS
/* $Header: iemvrprs.pls 115.2 2002/12/22 03:46:32 sboorela shipped $ */

--
--
-- Purpose: Assistant api to dynamically run procedure.
--
-- MODIFICATION HISTORY
-- Person      Date         Comments
--  Liang Xia   3/26/2002  created
-- ---------   ------  ------------------------------------------

  G_key_value             IEM_TAGPROCESS_PUB.keyVals_tbl_type;

--  Start of Comments
--  API name    : validProcedure
--  Type        : Private
--  Function    : This procedure valid a procedure
--  Pre-reqs    : None.
--  Parameters  :
 PROCEDURE validProcedure
                  (     p_api_version_number      IN  NUMBER,
                        P_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
                        p_commit                  IN  VARCHAR2 := FND_API.G_FALSE,
                        p_ProcName                IN VARCHAR2,
                        x_return_status           OUT NOCOPY VARCHAR2,
                        x_msg_count               OUT NOCOPY NUMBER,
                        x_msg_data                OUT NOCOPY VARCHAR2);


--  Start of Comments
--  API name    : run_Procedure
--  Type        : Private
--  Function    : This procedure run a procedure
--  Pre-reqs    : None.
--  Parameters  :
 PROCEDURE run_Procedure (
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := FND_API.G_FALSE,
		    	 p_commit              IN   VARCHAR2 := FND_API.G_FALSE,
            	 p_procedure_name      IN   VARCHAR2,
  				 p_key_value   	       IN   IEM_TAGPROCESS_PUB.keyVals_tbl_type,
                 x_result              OUT NOCOPY  VARCHAR2,
                 x_return_status	   OUT NOCOPY  VARCHAR2,
  		  	     x_msg_count	       OUT NOCOPY	NUMBER,
	  	  	     x_msg_data	           OUT NOCOPY	VARCHAR2
			 ) ;

procedure dummy_procedure( key_value IN IEM_TAGPROCESS_PUB.keyVals_tbl_type,
                               result OUT NOCOPY VARCHAR2) ;

procedure dummy_procedure2( key_value IN IEM_TAGPROCESS_PUB.keyVals_tbl_type,
                               result OUT NOCOPY VARCHAR2) ;
-- ***********************************************************************

END IEM_TAG_RUN_PROC_PVT; -- Package Specification IEM_TAG_RUN_PROC_PVT

 

/
