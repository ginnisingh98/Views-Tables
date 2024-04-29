--------------------------------------------------------
--  DDL for Package MTL_CROSS_REFERENCES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_CROSS_REFERENCES_PVT" AUTHID CURRENT_USER AS
/* $Header: INVVXRFS.pls 120.0.12010000.3 2010/01/13 00:21:30 akbharga noship $ */

G_Entity_Code                            VARCHAR2(30)    :=  'XRef';
G_Table_Name                             VARCHAR2(30)    :=  'MTL_CROSS_REFERENCES';
G_PKG_NAME                               VARCHAR2(30)    :=  'MTL_CROSS_REFERENCES_PVT';

-- -----------------------------------------------------------------------------
-- API Name: Process_XRef
--
-- Description :
--    Process (CREATE/UPDATE/DELETE) a set of Cross References based on data in
--    the pl/sql table.
-- -----------------------------------------------------------------------------
PROCEDURE Process_XRef(
   p_init_msg_list      IN               VARCHAR2       DEFAULT  FND_API.G_FALSE
  ,p_commit             IN               VARCHAR2        DEFAULT  FND_API.G_FALSE
  ,p_XRef_Tbl           IN OUT NOCOPY    MTL_CROSS_REFERENCES_PUB.XRef_Tbl_Type
  ,x_return_status      OUT NOCOPY       VARCHAR2
  ,x_msg_count          OUT NOCOPY       NUMBER
  ,x_message_list       OUT NOCOPY             Error_Handler.Error_Tbl_Type);

END ;

/
