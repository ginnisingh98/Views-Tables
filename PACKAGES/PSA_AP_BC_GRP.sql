--------------------------------------------------------
--  DDL for Package PSA_AP_BC_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSA_AP_BC_GRP" AUTHID CURRENT_USER AS
--$Header: psagapbs.pls 120.1 2006/07/10 13:26:19 bnarang noship $

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
                                       );
END;

 

/
