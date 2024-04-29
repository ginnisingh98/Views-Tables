--------------------------------------------------------
--  DDL for Package AHL_PRD_MATERIAL_TXN_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_PRD_MATERIAL_TXN_CUHK" AUTHID CURRENT_USER AS
/*$Header: AHLCMTXS.pls 120.1 2007/10/26 22:32:21 sracha noship $*/

------------------------
-- Declare Procedures --
------------------------
        --  Start of Comments  --
        --
        --  Procedure name      : PERFORM_MTL_TXN_PRE
        --  Type                : Public
        --  Function            : Provide User Hooks for the customer to add validations/default values
        --                        before Material Issue or Return.
        --  Pre-reqs            :
        --
        --  Standard IN  Parameters :
        --
        --  Standard OUT Parameters :
        --    x_return_status                 OUT     VARCHAR2              Required
        --    x_msg_count                     OUT     NUMBER                Required
        --    x_msg_data                      OUT     VARCHAR2              Required
        --
        --  PERFORM_MTLTXN_PRE  Parameters :
        --    p_x_material_txn_tbl  IN OUT AHL_PRD_MATERIAL_TXN_PUB.Ahl_Material_Txn_Tbl_Type Required
        --    Record structure containing transaction details.
        --    see $AHL_TOP/patch/115/sql/AHLPMTXS.pls for attribute details.
        --
        --  Version :
        --      Initial Version   1.0
        --
        --  End of Comments  --

 PROCEDURE PERFORM_MTLTXN_PRE (
        p_x_material_txn_tbl IN OUT NOCOPY AHL_PRD_MATERIAL_TXN_PUB.Ahl_Material_Txn_Tbl_Type,
        x_return_status      OUT NOCOPY    VARCHAR2,
        x_msg_count          OUT NOCOPY    NUMBER,
        x_msg_data           OUT NOCOPY    VARCHAR2
        );

        --Start of Comments  --
        --
        --  Procedure name      : PERFORM_MTLTXN_POST
        --  Type                : Public
        --  Function            : Provide User Hooks for the customer for post-processing
        --                        after Material Return or Material Issue transactions.
        --  Pre-reqs            :
        --
        --  Standard IN  Parameters :
        --
        --  Standard OUT Parameters :
        --      x_return_status                 OUT     VARCHAR2              Required
        --      x_msg_count                     OUT     NUMBER                Required
        --      x_msg_data                      OUT     VARCHAR2              Required
        --
        --  PERFORM_MTLTXN_POST Parameters :
        --    p_material_txn_tbl  IN AHL_PRD_MATERIAL_TXN_PUB.Ahl_Material_Txn_Tbl_Type Required
        --    Record structure containing transaction details.
        --    see $AHL_TOP/patch/115/sql/AHLPMTXS.pls for attribute details.
        --
        --  Version :
        --      Initial Version   1.0
        --
        --  End of Comments  --

 PROCEDURE PERFORM_MTLTXN_POST (
        p_material_txn_tbl   IN OUT NOCOPY AHL_PRD_MATERIAL_TXN_PUB.Ahl_Material_Txn_Tbl_Type,
        x_return_status      OUT NOCOPY    VARCHAR2,
        x_msg_count          OUT NOCOPY    NUMBER,
        x_msg_data           OUT NOCOPY    VARCHAR2
        );


END AHL_PRD_MATERIAL_TXN_CUHK;

/
