--------------------------------------------------------
--  DDL for Package Body MTL_CROSS_REFERENCES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_CROSS_REFERENCES_PUB" AS
/* $Header: INVPXRFB.pls 120.0.12010000.4 2010/01/13 01:17:34 akbharga noship $ */

PROCEDURE Process_XRef(
  p_api_version        IN           NUMBER,
  p_init_msg_list      IN           VARCHAR2   DEFAULT  FND_API.G_FALSE,
  p_commit             IN           VARCHAR2   DEFAULT  FND_API.G_FALSE,
  p_XRef_Tbl           IN OUT NOCOPY MTL_CROSS_REFERENCES_PUB.XRef_Tbl_Type,
  x_return_status      OUT NOCOPY   VARCHAR2,
  x_msg_count          OUT NOCOPY   NUMBER,
  x_message_list       OUT NOCOPY Error_Handler.Error_Tbl_Type) IS

BEGIN

  -- Save point for MTL_CROSS_REFERENCES_PUB
     SAVEPOINT MTL_CROSS_REFERENCES_PUB;

  -- Initialize message list
     IF FND_API.To_Boolean (p_init_msg_list) THEN
	   Error_Handler.Initialize;
     END IF;

  -- Set business object identifier in the System Information record
     Error_Handler.Set_BO_Identifier ( p_bo_identifier  =>  G_BO_Identifier );

  -- Calling Private API to process XRef table
     MTL_CROSS_REFERENCES_PVT.Process_Xref
	 (
	   p_init_msg_list   =>  p_init_msg_list,
       p_commit          =>  p_commit,
       p_XRef_Tbl        =>  p_XRef_tbl,
       x_return_status   =>  x_return_status,
       x_msg_count       =>  x_msg_count,
       x_message_list    =>  x_message_list
	  );

  -- Printing error messges
     IF x_return_status <> FND_API.g_RET_STS_SUCCESS then
       Error_Handler.GET_MESSAGE_LIST(x_message_list=>x_message_list);
     END IF;

EXCEPTION
     WHEN OTHERS THEN
       x_return_status  :=  FND_API.G_RET_STS_UNEXP_ERROR;
       ROLLBACK TO MTL_CROSS_REFERENCES_PUB; -- rolling back to savepoint

END Process_XRef;

END MTL_CROSS_REFERENCES_PUB;

/
