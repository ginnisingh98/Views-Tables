--------------------------------------------------------
--  DDL for Package Body PSA_AP_BC_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSA_AP_BC_GRP" AS
--$Header: psagapbb.pls 120.0 2006/07/10 13:40:43 bnarang noship $

    G_PKG_NAME 	CONSTANT VARCHAR2(30):='PSA_AP_BC_GRP';
/*------------------------------------------------------------------------
                      Logging Declarations
-------------------------------------------------------------------------*/
    g_state_level NUMBER          :=    FND_LOG.LEVEL_STATEMENT;
    g_proc_level  NUMBER          :=    FND_LOG.LEVEL_PROCEDURE;
    g_event_level NUMBER          :=    FND_LOG.LEVEL_EVENT;
    g_excep_level NUMBER          :=    FND_LOG.LEVEL_EXCEPTION;
    g_error_level NUMBER          :=    FND_LOG.LEVEL_ERROR;
    g_unexp_level NUMBER          :=    FND_LOG.LEVEL_UNEXPECTED;
    g_full_path CONSTANT VARCHAR2(50) :='psa.plsql.psagapbb.psa_ap_bc_grp';

PROCEDURE Get_PO_Reversed_Encumb_Amount(
                                       p_api_version          IN            NUMBER,
                                       p_init_msg_list        IN            VARCHAR2 DEFAULT FND_API.G_FALSE ,
                                       x_return_status        OUT    NOCOPY VARCHAR2,
                                       x_msg_count            OUT    NOCOPY NUMBER,
                                       x_msg_data             OUT    NOCOPY VARCHAR2,
                                       P_Po_Distribution_Id   IN            NUMBER,
                                       P_Start_gl_Date        IN            DATE,
                                       P_End_gl_Date          IN            DATE,
                                       P_Calling_Sequence     IN            VARCHAR2 DEFAULT NULL,
                                       x_unencumbered_amount  OUT    NOCOPY NUMBER
                                       )

 IS
   l_api_name                   VARCHAR2(240);
   l_api_version          	CONSTANT NUMBER := 1.0;

   BEGIN
   l_api_name := g_full_path || '.Get_PO_Reversed_Encumb_Amount';
   x_unencumbered_amount := 0;

   psa_utils.debug_other_string(g_state_level,l_api_name,'Start of procedure PSA_AP_BC_GRP.Get_PO_Reversed_Encumb_Amount' );

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
   	  	                       l_api_name,
		    	     	       G_PKG_NAME )
   THEN
   psa_utils.debug_other_string(g_state_level,l_api_name,'API version not compatible');
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
     FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_msg_count     := 0;
   x_msg_data      := NULL;

   psa_utils.debug_other_string(g_state_level,l_api_name,'Calling PSA_AP_BC_PVT.Get_PO_Reversed_Encumb_Amount' );

   x_unencumbered_amount := PSA_AP_BC_PVT.Get_PO_Reversed_Encumb_Amount(P_Po_Distribution_Id => P_Po_Distribution_Id,
                                                                        P_Start_gl_Date      => P_Start_gl_Date,
                                                                        P_End_gl_Date        => P_End_gl_Date,
                                                                        P_Calling_Sequence   => P_Calling_Sequence);

   psa_utils.debug_other_string(g_state_level,l_api_name,'Call to PSA_AP_BC_PVT.Get_PO_Reversed_Encumb_Amount successful' );
   FND_MSG_PUB.Count_And_Get
   (
	p_count         	=>      x_msg_count,
        p_data          	=>      x_msg_data
    );
   psa_utils.debug_other_string(g_state_level,l_api_name,'End of procedure PSA_AP_BC_GRP.Get_PO_Reversed_Encumb_Amount' );
   EXCEPTION
    WHEN OTHERS THEN

     psa_utils.debug_other_string(g_unexp_level,l_api_name,'ERROR: ' || SQLERRM(sqlcode));
     psa_utils.debug_other_string(g_unexp_level,l_api_name,'Error in Get_PO_Reversed_Encumb_Amount Procedure');
     Fnd_Msg_Pub.Add_Exc_Msg(
 	                     p_pkg_name       => 'PSA_AP_BC_GRP',
	           	     p_procedure_name => 'GET_PO_REVERSED_ENCUMB_AMOUNT');
     FND_MSG_PUB.Count_And_Get
	   (
	    p_count         	=>      x_msg_count     	,
            p_data          	=>      x_msg_data
 	   );
 	 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END Get_PO_Reversed_Encumb_Amount;
END;

/
