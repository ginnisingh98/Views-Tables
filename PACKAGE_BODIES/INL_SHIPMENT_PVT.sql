--------------------------------------------------------
--  DDL for Package Body INL_SHIPMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INL_SHIPMENT_PVT" AS
/* $Header: INLVSHPB.pls 120.15.12010000.107 2013/10/10 14:28:34 ebarbosa ship $ */

L_FND_USER_ID               CONSTANT NUMBER        := fnd_global.user_id;           --Bug#9660082
L_FND_CONC_PROGRAM_ID       CONSTANT NUMBER        := fnd_global.conc_program_id;   --Bug#9660082
L_FND_PROG_APPL_ID          CONSTANT NUMBER        := fnd_global.prog_appl_id ;     --Bug#9660082
L_FND_CONC_REQUEST_ID       CONSTANT NUMBER        := fnd_global.conc_request_id;   --Bug#9660082
L_FND_LOCAL_CHR10           CONSTANT VARCHAR2(100) := fnd_global.local_chr (10);    --Bug#9660082
L_FND_LOGIN_ID              CONSTANT NUMBER        := fnd_global.login_id;          --Bug#9660082
L_FND_EXC_ERROR             EXCEPTION;                                              --Bug#9660082
L_FND_EXC_UNEXPECTED_ERROR  EXCEPTION;                                              --Bug#9660082
L_FND_RET_STS_SUCCESS       CONSTANT VARCHAR2(1)   := fnd_api.g_ret_sts_success;    --Bug#9660082
L_FND_RET_STS_ERROR         CONSTANT VARCHAR2(1)   := fnd_api.g_ret_sts_error;      --Bug#9660082
L_FND_RET_STS_UNEXP_ERROR   CONSTANT VARCHAR2(1)   := fnd_api.g_ret_sts_unexp_error;--Bug#9660082

/* unused --Bug#13987019 BEG
TYPE rcv_header_interface_rec_type
IS
    RECORD
    (
        header_interface_id NUMBER,
        notice_creation_date DATE,
        transaction_type        VARCHAR2 (25),
        processing_status_code  VARCHAR2 (25),
        receipt_source_code     VARCHAR2 (25),
        validation_flag         VARCHAR2 (1),
        ship_to_organization_id NUMBER,
        vendor_id               NUMBER,
        vendor_site_id          NUMBER,
        group_id                NUMBER,
        shipment_num            VARCHAR2 (30),
        shipped_date DATE,
        last_update_date DATE,
        last_updated_by NUMBER,
        creation_date DATE,
        created_by        NUMBER,
        last_update_login NUMBER) ;
TYPE rcv_header_interface_tbl
IS
    TABLE OF rcv_header_interface_rec_type INDEX BY BINARY_INTEGER;
    rcv_header_interface rcv_header_interface_tbl;
TYPE rcv_trx_interface_rec_type
IS
    RECORD
    (
        interface_transaction_id NUMBER,
        transaction_type         VARCHAR2 (25),
        quantity                 NUMBER,
        interface_source_code    VARCHAR2 (30),
        interface_source_line_id NUMBER,
        transaction_date DATE,
        processing_status_code  VARCHAR2 (25),
        processing_mode_code    VARCHAR2 (25),
        transaction_status_code VARCHAR2 (25),
        receipt_source_code     VARCHAR2 (25),
        source_document_code    VARCHAR2 (25),
        validation_flag         VARCHAR2 (1),
        po_header_id            NUMBER,
        po_line_id              NUMBER,
        po_line_location_id     NUMBER,
        po_release_id           NUMBER,
        item_id                 NUMBER,
        item_num                VARCHAR2 (50),
        item_description        VARCHAR2 (240),
        uom_code                VARCHAR2 (3),
        vendor_item_num         VARCHAR2 (25),
        vendor_id               NUMBER,
        vendor_site_id          NUMBER,
        ship_to_location_id     NUMBER,
        location_id             NUMBER,
        org_id                  NUMBER,
        to_organization_id      NUMBER,
        group_id                NUMBER,
        lpn_group_id            NUMBER,
        header_interface_id     NUMBER,
        last_update_date DATE,
        last_updated_by NUMBER,
        creation_date DATE,
        created_by        NUMBER,
        last_update_login NUMBER,
        unit_landed_cost NUMBER) ;

TYPE rcv_trx_interface_tbl
IS
    TABLE OF rcv_trx_interface_rec_type INDEX BY BINARY_INTEGER;
    rcv_trx_interface rcv_trx_interface_tbl;
    --Bug#13987019 END
*/
    -- Utl name   : Handle_ShipError
    -- Type       : Private
    -- Function   : Insert errors in INL_SHIP_HOLDS
    -- Pre-reqs   : None
    -- Parameters :
    -- IN         : p_ship_header_id     IN NUMBER  ,
    --              p_ship_line_id       IN NUMBER,
    --              p_charge_line_id     IN NUMBER,
    --              p_table_name         IN VARCHAR2,
    --              p_column_name        IN VARCHAR2,
    --              p_column_value       IN VARCHAR2,
    --              p_error_message      IN VARCHAR2,
    --              p_error_message_name IN VARCHAR2,
    --              p_token1_name        IN VARCHAR2,
    --              p_token1_value       IN VARCHAR2,
    --              p_token2_name        IN VARCHAR2,
    --              p_token2_value       IN VARCHAR2,
    --              p_token3_name        IN VARCHAR2,
    --              p_token3_value       IN VARCHAR2,
    --              p_token4_name        IN VARCHAR2,
    --              p_token4_value       IN VARCHAR2,
    --              p_token5_name        IN VARCHAR2,
    --              p_token5_value       IN VARCHAR2,
    --              p_token6_name        IN VARCHAR2,
    --              p_token6_value       IN VARCHAR2,
    --
    --
    -- OUT          x_return_status    OUT NOCOPY VARCHAR2
    --
    -- Version    : Current version 1.0
    --
    -- Notes      :
PROCEDURE Handle_ShipError(
        p_ship_header_id     IN NUMBER,
        p_ship_line_id       IN NUMBER,
        p_charge_line_id     IN NUMBER,
        p_table_name         IN VARCHAR2,
        p_column_name        IN VARCHAR2,
        p_column_value       IN VARCHAR2,
        p_error_message      IN VARCHAR2,
        p_error_message_name IN VARCHAR2,
        p_token1_name        IN VARCHAR2,
        p_token1_value       IN VARCHAR2,
        p_token2_name        IN VARCHAR2,
        p_token2_value       IN VARCHAR2,
        p_token3_name        IN VARCHAR2,
        p_token3_value       IN VARCHAR2,
        p_token4_name        IN VARCHAR2,
        p_token4_value       IN VARCHAR2,
        p_token5_name        IN VARCHAR2,
        p_token5_value       IN VARCHAR2,
        p_token6_name        IN VARCHAR2,
        p_token6_value       IN VARCHAR2,
        x_return_status OUT NOCOPY VARCHAR2
) IS
    l_program_name     CONSTANT VARCHAR2 (30) := 'Handle_ShipError';
    l_return_status VARCHAR2 (1) ;
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2 (2000) ;
    l_debug_info    VARCHAR2 (200) ;
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc ( p_module_name => g_module_name,
                                    p_procedure_name => l_program_name) ;
    --  Initialize return status to success
    x_return_status                              := L_FND_RET_STS_SUCCESS;
    l_debug_info                                 := 'Insert error details in inl_ship_holds.';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_debug_info => l_debug_info
    ) ;
     INSERT
       INTO inl_ship_holds
        (
            ship_hold_id          ,         /* 01 */
            ship_header_id        ,         /* 02 */
            ship_line_id          ,         /* 03 */
            table_name            ,         /* 04 */
            column_name           ,         /* 05 */
            column_value          ,         /* 06 */
            processing_date       ,         /* 07 */
            error_message_name    ,         /* 08 */
            error_message         ,         /* 09 */
            token1_name           ,         /* 10 */
            token1_value          ,         /* 11 */
            token2_name           ,         /* 12 */
            token2_value          ,         /* 13 */
            token3_name           ,         /* 14 */
            token3_value          ,         /* 15 */
            token4_name           ,         /* 16 */
            token4_value          ,         /* 17 */
            token5_name           ,         /* 18 */
            token5_value          ,         /* 19 */
            token6_name           ,         /* 20 */
            token6_value          ,         /* 21 */
            created_by            ,         /* 22 */
            creation_date         ,         /* 23 */
            last_updated_by       ,         /* 24 */
            last_update_date      ,         /* 25 */
            last_update_login     ,         /* 26 */
            program_id            ,         /* 27 */
            program_application_id,         /* 28 */
            program_update_date   ,         /* 29 */
            request_id                      /* 30 */
        )
        VALUES
        (
            inl_ship_holds_s.NEXTVAL  ,     /* 01 */
            p_ship_header_id          ,     /* 02 */
            p_ship_line_id            ,     /* 03 */
            p_table_name              ,     /* 04 */
            p_column_name             ,     /* 05 */
            p_column_value            ,     /* 06 */
            SYSDATE                   ,     /* 07 */
            p_error_message_name      ,     /* 08 */
            p_error_message           ,     /* 09 */
            p_token1_name             ,     /* 10 */
            p_token1_value            ,     /* 11 */
            p_token2_name             ,     /* 12 */
            p_token2_value            ,     /* 13 */
            p_token3_name             ,     /* 14 */
            p_token3_value            ,     /* 15 */
            p_token4_name             ,     /* 16 */
            p_token4_value            ,     /* 17 */
            p_token5_name             ,     /* 18 */
            p_token5_value            ,     /* 19 */
            p_token6_name             ,     /* 20 */
            p_token6_value            ,     /* 21 */
            L_FND_USER_ID             ,     /* 22 */
            SYSDATE                   ,     /* 23 */
            L_FND_USER_ID             ,     /* 24 */
            SYSDATE                   ,     /* 25 */
            L_FND_LOGIN_ID            ,     /* 26 */ --SCM-051
            L_FND_CONC_PROGRAM_ID     ,     /* 27 */
            L_FND_PROG_APPL_ID        ,     /* 28 */
            SYSDATE                   ,     /* 29 */
            L_FND_CONC_REQUEST_ID           /* 30 */
        ) ;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    );
EXCEPTION
WHEN L_FND_EXC_ERROR THEN
    -- Standard Expected Error Logging
    INL_LOGGING_PVT.Log_ExpecError(
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    );
    x_return_status := L_FND_RET_STS_ERROR;
WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError(
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    );
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError(
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    );
    x_return_status := L_FND_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
        FND_MSG_PUB.Add_Exc_Msg(
            p_pkg_name => g_pkg_name,
            p_procedure_name => l_program_name
        );
    END IF;
END Handle_ShipError;
-- Utility name   : Reset_ShipError
-- Type       : Private
-- Function   : Delete previous errors for the current shipment
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_header_id IN NUMBER     Required Id of Ship Header record
--              p_ship_line_id   IN NUMBER     Optional Id of Ship Line record
--              p_charge_line_id IN NUMBER     Optional Id of Ship Line record
--
-- OUT          x_return_status  OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Reset_ShipError(
        p_ship_header_id IN NUMBER,
        p_ship_line_id   IN NUMBER,
        p_charge_line_id IN NUMBER,
        x_return_status OUT NOCOPY VARCHAR2
) IS
    l_program_name CONSTANT VARCHAR2(30):= 'Reset_ShipError';
    l_api_version   CONSTANT NUMBER := 1.0;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data  VARCHAR2(2000);
    l_debug_info VARCHAR2(200);
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc    (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    );
    --  Initialize return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;
    l_debug_info    := 'Delete Errors from previous validation.';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_debug_info => l_debug_info
    ) ;
    IF p_ship_line_id IS NULL AND p_charge_line_id IS NULL THEN
         DELETE FROM inl_ship_holds
         WHERE ship_header_id = p_ship_header_id;
    ELSE
        IF p_ship_line_id IS NOT NULL THEN
             DELETE
               FROM inl_ship_holds
              WHERE ship_header_id = p_ship_header_id
                AND ship_line_id   = p_ship_line_id;
        END IF;
        IF p_charge_line_id IS NOT NULL THEN
             DELETE
               FROM inl_ship_holds
              WHERE ship_header_id = p_ship_header_id
                AND ship_line_id   = p_charge_line_id;
        END IF;
    END IF;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
EXCEPTION
WHEN L_FND_EXC_ERROR THEN
    -- Standard Expected Error Logging
    INL_LOGGING_PVT.Log_ExpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    x_return_status := L_FND_RET_STS_ERROR;
WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level (p_message_level  => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg (
            p_pkg_name => g_pkg_name,
            p_procedure_name => l_program_name) ;
    END IF;
END Reset_ShipError;
-- API name   : Complete_Shipment
-- Type       : Private
-- Function   : Complete a given LCM Shipment.
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version           IN NUMBER
--              p_init_msg_list         IN VARCHAR2  Default = L_FND_FALSE
--              p_commit                IN VARCHAR2  Default = L_FND_FALSE
--              p_ship_header_id        IN NUMBER
--              p_rcv_enabled_flag      IN VARCHAR2
--              p_pending_elc_flag      IN VARCHAR2
--              p_pending_matching_flag IN VARCHAR2
--              p_organization_id       IN NUMBER
--
-- OUT          x_return_status         OUT NOCOPY VARCHAR2
--              x_msg_count             OUT NOCOPY   NUMBER
--              x_msg_data              OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Complete_Shipment (
    p_api_version            IN NUMBER,
    p_init_msg_list          IN VARCHAR2 := L_FND_FALSE,
    p_commit                 IN VARCHAR2 := L_FND_FALSE,
    p_ship_header_id         IN NUMBER,
    p_rcv_enabled_flag       IN VARCHAR2,
    p_pending_matching_flag  IN VARCHAR2,
    p_pending_elc_flag       IN VARCHAR2, -- SCM-051
    p_organization_id        IN NUMBER,
    p_max_allocation_id      IN NUMBER, --Bug#10032820
    x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2)
IS
    l_api_name    CONSTANT VARCHAR2 (30) := 'Complete_Shipment';
    l_api_version CONSTANT NUMBER := 1.0;
    l_msg_count NUMBER;
    l_msg_data VARCHAR2 (2000);
    l_ship_status VARCHAR2 (30) ;
    l_exist_status NUMBER := 0;
    l_return_status VARCHAR2 (1) ;
    l_debug_info VARCHAR2 (200) ;
    l_errbuf VARCHAR2 (240) ;
    l_retcode NUMBER;
    l_pre_receive VARCHAR2 (1);
    l_ship_num VARCHAR2(25); -- SCM-051
BEGIN
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
    -- Standard Start of API savepoint
    SAVEPOINT Complete_Shipment_PVT;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean (p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    -- Check for call compatibility.
    IF NOT
    FND_API.Compatible_API_Call (
        p_current_version_number => l_api_version,
        p_caller_version_number => p_api_version,
        p_api_name => l_api_name,
        p_pkg_name => G_PKG_NAME
    ) THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;
    -------------------------------------------------
    -- Required steps only for NOT Pending Shipments
    -------------------------------------------------
    IF NVL (p_pending_matching_flag, 'N') = 'N' AND
       NVL (p_pending_elc_flag, 'N') = 'N' AND  -- SCM-051
       NVL (p_rcv_enabled_flag, 'N') = 'Y' THEN
        -- Check which scenario is setup in RCV
        -- Parameters for the current Inventory Organization
        SELECT pre_receive
        INTO l_pre_receive
        FROM rcv_parameters
        WHERE organization_id = p_organization_id;
        -- Pre-Receive scenario
        IF (NVL (l_pre_receive, 'N') = 'Y') THEN
          l_debug_info := 'Call INL_INTEGRATION_GRP.Export_toRCV';
            INL_LOGGING_PVT.Log_Statement (
                p_module_name => g_module_name,
                p_procedure_name => l_api_name,
                p_debug_info => l_debug_info) ;

          -- Run integration procedure to transport LCM to RCV
          INL_INTEGRATION_GRP.Export_toRCV (
                p_api_version       => l_api_version,
                p_init_msg_list     => L_FND_FALSE,
                p_commit            => L_FND_FALSE,
                p_ship_header_id    => p_ship_header_id,
                x_return_status     => l_return_status,
                x_msg_count         => l_msg_count,
                x_msg_data          => l_msg_data);

          l_debug_info := 'l_return_status: ' || l_return_status;
          INL_LOGGING_PVT.Log_Statement (
              p_module_name => g_module_name,
              p_procedure_name => l_api_name,
              p_debug_info => l_debug_info) ;

          -- If any errors happen abort the process.
          IF l_return_status = L_FND_RET_STS_ERROR THEN
              RAISE L_FND_EXC_ERROR;
          ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
              RAISE L_FND_EXC_UNEXPECTED_ERROR;
          END IF;
        -- Blackbox scenario
        ELSIF (NVL (l_pre_receive, 'N') = 'N') THEN
            l_debug_info := 'Call INL_INTEGRATION_GRP.Call_StampLC';
            INL_LOGGING_PVT.Log_Statement (
                p_module_name => g_module_name,
                p_procedure_name => l_api_name,
                p_debug_info => l_debug_info) ;

            INL_INTEGRATION_GRP.Call_StampLC (
                p_api_version    => l_api_version,
                p_init_msg_list  => L_FND_FALSE,
                p_commit         => L_FND_FALSE,
                p_ship_header_id  => p_ship_header_id,
                x_return_status  => l_return_status,
                x_msg_count      => l_msg_count,
                x_msg_data       => l_msg_data
            );
            -- If any errors happen abort the process.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
    ----------------------------------------------
    -- Required step only for Pending Shipments
    ----------------------------------------------
    ELSIF (NVL (p_pending_matching_flag, 'N') = 'Y' OR
           NVL (p_pending_elc_flag, 'N') = 'Y' ) AND -- SCM-051
          NVL(p_rcv_enabled_flag, 'N') = 'Y' THEN
        -- Run Create Costing Interfaces
        l_debug_info := 'Run INL_INTEGRATION_GRP.Export_ToCST';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name   => g_module_name,
            p_procedure_name=> l_api_name,
            p_debug_info    => l_debug_info) ;

        INL_INTEGRATION_GRP.Export_ToCST (
            p_api_version       => 1.0,
            p_init_msg_list     => L_FND_FALSE,
            p_commit            => L_FND_FALSE,
            p_ship_header_id    => p_ship_header_id,
            p_max_allocation_id => p_max_allocation_id, --Bug#10032820
            x_return_status     => l_return_status,
            x_msg_count         => l_msg_count,
            x_msg_data          => l_msg_data
        ) ;
        -- If any errors happen abort the process.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

    l_debug_info := 'Update the current INL_SHIP_HEADERS_ALL.ship_status_code to COMPLETED';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name   => g_module_name,
        p_procedure_name=> l_api_name,
        p_debug_info    => l_debug_info ) ;

    UPDATE inl_ship_headers
    SET ship_status_code = 'COMPLETED',
        last_updated_by  = L_FND_USER_ID,
        last_update_date = SYSDATE
    WHERE ship_header_id = p_ship_header_id;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean (p_commit) THEN
        COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data) ;
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
EXCEPTION
WHEN L_FND_EXC_ERROR THEN
    INL_LOGGING_PVT.Log_ExpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
    ROLLBACK TO Complete_Shipment_PVT;
    x_return_status := L_FND_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data) ;
WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
    ROLLBACK TO Complete_Shipment_PVT;
    x_return_status                      := L_FND_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data) ;
WHEN OTHERS THEN
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
    ROLLBACK TO Complete_Shipment_PVT;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg (
            p_pkg_name => g_pkg_name,
            p_procedure_name => l_api_name) ;
    END IF;
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data) ;
END Complete_Shipment;
-- Utility name   : Delete_Allocations
-- Type       : Private
-- Function   : Delete allocations from the previous landed cost calculation.
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_header_id  IN NUMBER
-- OUT          x_return_status OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Delete_Allocations(
        p_ship_header_id IN NUMBER,
        x_return_status OUT NOCOPY VARCHAR2
) IS
    l_program_name  CONSTANT VARCHAR2 (100) := 'Delete_Allocations ';
    l_debug_info VARCHAR2 (200) ;
BEGIN
    -- Verify if there is allocation for Shipment
     DELETE
       FROM inl_allocations cfa
      WHERE cfa.ship_header_id = p_ship_header_id
        AND NOT EXISTS
        (
             SELECT 'x'
               FROM inl_allocations al1
              WHERE al1.ship_header_id = cfa.ship_header_id
                AND al1.adjustment_num > 0
                AND ROWNUM             < 2
        ) ;
    l_debug_info := 'deleted '||sql%ROWCOUNT||' allocations rows ';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_debug_info => l_debug_info
    ) ;
EXCEPTION
WHEN L_FND_EXC_ERROR THEN
    x_return_status := L_FND_RET_STS_ERROR;
WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
WHEN OTHERS THEN
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg (
            p_pkg_name => g_pkg_name,
            p_procedure_name => l_program_name) ;
    END IF;
END Delete_Allocations;

-- API name   : Set_ToRevalidate
-- Type       : Private
-- Function   : Set a given LCM Shipment to "Validation Required" status.
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version     IN         NUMBER   Required
--              p_init_msg_list   IN         VARCHAR2 Optional  Default = L_FND_FALSE
--              p_commit          IN         VARCHAR2 Optional  Default = L_FND_FALSE
--              p_ship_header_id  IN         NUMBER   Required
-- OUT          x_msg_count       OUT NOCOPY NUMBER
--              x_msg_data        OUT NOCOPY VARCHAR2
--              x_return_status   OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Set_ToRevalidate(
        p_api_version    IN NUMBER,
        p_init_msg_list  IN VARCHAR2 := L_FND_FALSE,
        p_commit         IN VARCHAR2 := L_FND_FALSE,
        p_ship_header_id IN NUMBER,
        x_msg_count OUT NOCOPY     NUMBER,
        x_msg_data OUT NOCOPY      VARCHAR2,
        x_return_status OUT NOCOPY VARCHAR2
) IS
    l_ship_status   VARCHAR2 (30) ;
    l_api_name      CONSTANT VARCHAR2 (100) := 'Set_ToRevalidate';
    l_api_version   CONSTANT NUMBER         := 1.0;
    l_exist_event   VARCHAR2 (5) ;
    l_msg_data      VARCHAR2 (200) ;
    l_msg_count     NUMBER;
    l_return_status VARCHAR2 (1) ;
    l_exist_status  NUMBER := 0;
    l_exist_calc    NUMBER := 0;
    l_debug_info    VARCHAR2 (200) ;
BEGIN
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
    -- Standard Start of API savepoint
    SAVEPOINT Set_ToRevalidate_PVT;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean (p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    -- Check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
        p_current_version_number => l_api_version,
        p_caller_version_number => p_api_version,
        p_api_name => l_api_name,
        p_pkg_name => G_PKG_NAME
    ) THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;
     SELECT sh.ship_status_code
       INTO l_ship_status
       FROM inl_ship_headers sh
      WHERE sh.ship_header_id = p_ship_header_id;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'current Shipment status',
        p_var_value => l_ship_status
    ) ;
    IF (l_ship_status = 'VALIDATED' OR l_ship_status = 'ON HOLD') THEN
        Delete_Allocations (p_ship_header_id, l_return_status) ;
        -- If any errors happen abort API.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
        -- Update Shipment status to VALIDATION REQ
         UPDATE inl_ship_headers
        SET ship_status_code   = 'VALIDATION REQ'
          WHERE ship_header_id = p_ship_header_id;
    END IF;
    -- Standard check of p_commit.
    IF FND_API.To_Boolean (p_commit) THEN
        COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data
    ) ;
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
EXCEPTION
WHEN L_FND_EXC_ERROR THEN
    l_debug_info := 'MSG: '||SQLERRM;
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info => l_debug_info
    ) ;
    INL_LOGGING_PVT.Log_ExpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
    ROLLBACK TO Set_ToRevalidate_PVT;
    x_return_status := L_FND_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data) ;
WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
    l_debug_info := 'MSG: '||SQLERRM;
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info => l_debug_info
    ) ;
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
    ROLLBACK TO Set_ToRevalidate_PVT;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data) ;
WHEN OTHERS THEN
    l_debug_info := 'MSG: '||SQLERRM;
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info => l_debug_info
    ) ;
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
    ROLLBACK TO Set_ToRevalidate_PVT;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg (
            p_pkg_name => g_pkg_name,
            p_procedure_name => l_api_name) ;
    END IF;
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data) ;
END Set_ToRevalidate;

-- Utility name   : Has_ShipLine
-- Type       : Private
-- Function   : Checks if an LCM Shipment contains Shipment Lines
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_header_id  IN NUMBER
--
-- OUT        : x_group_line_num IN OUT NOCOPY  NUMBER
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Has_ShipLine(
        p_ship_header_id IN NUMBER,
        x_group_line_num IN OUT NOCOPY NUMBER -- Bug 12630218
) RETURN BOOLEAN IS
    l_program_name  CONSTANT VARCHAR2 (30) := 'Has_ShipLine';
    count_ship_line NUMBER;
    l_debug_info VARCHAR2 (200);
    l_count_group_no_line NUMBER := 0;

    -- Bug 12630218
    CURSOR c_group_lines IS
    SELECT slg.ship_line_group_id, slg.ship_line_group_num, COUNT(ol.ship_line_id) count_ship_line
    FROM inl_ship_line_groups slg,
         inl_adj_ship_lines_v ol
    WHERE ol.ship_header_id (+) = slg.ship_header_id
    AND ol.ship_line_group_id (+) = slg.ship_line_group_id
    AND slg.ship_header_id = p_ship_header_id
    GROUP BY slg.ship_line_group_id, slg.ship_line_group_num
    ORDER BY slg.ship_line_group_id;

    TYPE group_lines_type IS TABLE OF c_group_lines%ROWTYPE;
    c_group_lines_tl group_lines_type;
    l_group_lines group_lines_type;

BEGIN
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;

    -- Logging variables
    INL_LOGGING_PVT.Log_Variable (
          p_module_name => g_module_name,
          p_procedure_name => l_program_name,
          p_var_name => 'p_ship_header_id',
          p_var_value => p_ship_header_id);

    OPEN c_group_lines;
    FETCH c_group_lines BULK COLLECT INTO c_group_lines_tl;
    CLOSE c_group_lines;

    -- Logging variables
    INL_LOGGING_PVT.Log_Variable (
          p_module_name => g_module_name,
          p_procedure_name => l_program_name,
          p_var_name => 'NVL(c_group_lines_tl.LAST, 0)',
          p_var_value => NVL(c_group_lines_tl.LAST, 0));

    IF NVL(c_group_lines_tl.LAST, 0) = 0 THEN
        RETURN FALSE;
    ELSE
        FOR i IN NVL (c_group_lines_tl.FIRST, 0) ..NVL (c_group_lines_tl.LAST, 0)
        LOOP
            -- Logging variables
            INL_LOGGING_PVT.Log_Variable (
                p_module_name => g_module_name,
                p_procedure_name => l_program_name,
                p_var_name => 'c_group_lines_tl.count_ship_line(' || i || ')',
                p_var_value => c_group_lines_tl(i).count_ship_line);

            -- Group without Line
            IF NVL (c_group_lines_tl(i).count_ship_line, 0) <= 0 THEN
                l_count_group_no_line := 1;
                x_group_line_num := c_group_lines_tl(i).ship_line_group_num;
                EXIT WHEN l_count_group_no_line = 1;
            END IF;
        END LOOP;
    END IF;

   INL_LOGGING_PVT.Log_EndProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;

    IF NVL (l_count_group_no_line, 0) <> 0 THEN
        RETURN FALSE;
    ELSE
        RETURN TRUE;
    END IF;
END Has_ShipLine;

-- Utl name   : Get_ShipHeadNum
-- Type       : Private
-- Function   : Get Shipment Number
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_header_id  IN NUMBER
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Get_ShipHeadNum(
        p_ship_header_id IN NUMBER
) RETURN VARCHAR2 IS
    l_program_name       CONSTANT VARCHAR2 (30) := 'Get_ShipHeadNum';
    l_ship_header_num VARCHAR2 (25) ;
    l_debug_info      VARCHAR2 (200) ;
BEGIN
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    BEGIN
         SELECT ship_num
           INTO l_ship_header_num
           FROM inl_ship_headers
          WHERE ship_header_id = p_ship_header_id;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN '';
    END;
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    RETURN l_ship_header_num;
END Get_ShipHeadNum;

-- Utl name   : Get_ShipLineNum
-- Type       : Private
-- Function   : Get Shipment Line Number
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_line_id  IN NUMBER
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Get_ShipLineNum(
        p_ship_line_id IN NUMBER
) RETURN VARCHAR2 IS
    l_program_name     CONSTANT VARCHAR2 (30) := 'Get_ShipLineNum';
    l_ship_line_num VARCHAR2 (25) ;
    l_debug_info    VARCHAR2 (200) ;
BEGIN
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    BEGIN
         SELECT ship_line_num
           INTO l_ship_line_num
           FROM inl_adj_ship_lines_v
          WHERE NVL (parent_ship_line_id, ship_line_id) = p_ship_line_id;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN '';
    END;
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    RETURN TO_CHAR (l_ship_line_num) ;
END Get_ShipLineNum;

--Bug#16735112
-- Prg name   : verify_RTIinError
-- Type       : Private
-- Function   : Verify RTI records in error to exclude from available qty
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_parent_id           IN NUMBER     PLL or RSL ids
--              p_receipt_source_code IN VARCHAR2
--              p_unit_of_measure     IN  NOCOPY VARCHAR2
-- OUT          x_rti_quantity        OUT NOCOPY   NUMBER
--              x_return_status       OUT NOCOPY VARCHAR2
--              x_msg_count           OUT NOCOPY   NUMBER
--              x_msg_data            OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE verify_RTIinError(
    p_parent_id           IN NUMBER  ,
    p_receipt_source_code IN VARCHAR2,
    p_unit_of_measure     IN VARCHAR2,
    x_rti_quantity        OUT NOCOPY   NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY   NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2)
IS
    l_proc_name  CONSTANT VARCHAR2 (100) := 'verify_RTIinError ';
    l_debug_info VARCHAR2(2000);
    l_primary_uom VARCHAR2(30);
    l_item_id NUMBER;
    l_rti_quantity  NUMBER;
BEGIN
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name,
        p_var_name => 'p_parent_id',
        p_var_value => p_parent_id);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name,
        p_var_name => 'p_receipt_source_code',
        p_var_value => p_receipt_source_code);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name,
        p_var_name => 'p_unit_of_measure',
        p_var_value => p_unit_of_measure);
    l_rti_quantity:=0;
    IF p_receipt_source_code = 'VENDOR' THEN
        SELECT
              NVL(SUM(primary_quantity),0),
              min(primary_unit_of_measure),
              MIN(item_id)
        INTO   l_rti_quantity,
              l_primary_uom,
              l_item_id
        FROM   rcv_transactions_interface rti
        WHERE  transaction_status_code = 'PENDING'
        AND processing_status_code = 'ERROR'
        AND transaction_type IN ('RECEIVE', 'MATCH','CORRECT','SHIP')
        AND NOT EXISTS(SELECT 1 FROM rcv_transactions rt
                      WHERE rt.transaction_type='DELIVER'
                          AND rt.transaction_id = rti.parent_transaction_id
                          AND rti.transaction_type = 'CORRECT')
        AND    po_line_location_id = p_parent_id;
    ELSIF p_receipt_source_code = 'INVENTORY' THEN
        SELECT
              NVL(SUM(primary_quantity),0),
              min(primary_unit_of_measure),
              MIN(item_id)
        INTO
               l_rti_quantity,
               l_primary_uom,
               l_item_id
        FROM   rcv_transactions_interface
        WHERE  transaction_status_code = 'PENDING'
        AND processing_status_code = 'ERROR'
        AND transaction_type  = 'RECEIVE'
        AND shipment_line_id = p_parent_id;

    END IF;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name,
        p_var_name => 'l_rti_quantity',
        p_var_value => l_rti_quantity);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name,
        p_var_name => 'l_primary_uom',
        p_var_value => l_primary_uom);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name,
        p_var_name => 'l_item_id',
        p_var_value => l_item_id);

    IF l_rti_quantity > 0 AND
       l_primary_uom <> p_unit_of_measure
    THEN
        PO_UOM_S.uom_convert(
            l_rti_quantity,
            l_primary_uom,
            l_item_id,
            p_unit_of_measure,
            x_rti_quantity);
    ELSE
         x_rti_quantity:= l_rti_quantity;
    END IF;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name,
        p_var_name => 'x_rti_quantity',
        p_var_value => x_rti_quantity);
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name) ;
EXCEPTION
WHEN L_FND_EXC_ERROR THEN
    -- Standard Expected Error Logging
    INL_LOGGING_PVT.Log_ExpecError(
        p_module_name    => g_module_name,
        p_procedure_name => l_proc_name
    );
    x_return_status := L_FND_RET_STS_ERROR;
WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError(
        p_module_name    => g_module_name,
        p_procedure_name => l_proc_name
    );
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError(
        p_module_name    => g_module_name,
        p_procedure_name => l_proc_name
    );
    x_return_status := L_FND_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
        FND_MSG_PUB.Add_Exc_Msg(
            p_pkg_name      => g_pkg_name,
            p_procedure_name=> l_proc_name
        );
    END IF;

END verify_RTIinError;

-- API name   : Get_AvailableQty
-- Type       : Private
-- Function   : Encapsulate the logic to call RCV routines and return the Available and Tolerable quantities.
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version        IN NUMBER           Required
--              p_init_msg_list      IN VARCHAR2         Optional  Default = L_FND_FALSE
--              p_commit             IN VARCHAR2         Optional  Default = L_FND_FALSE
--              p_ship_line_src_code IN VARCHAR2
--              p_parent_id          IN NUMBER
--              p_available_quantity IN OUT NOCOPY NUMBER
--              p_tolerable_quantity IN OUT NOCOPY NUMBER
--              p_unit_of_measure    IN OUT NOCOPY VARCHAR2
-- OUT          x_return_status      OUT NOCOPY VARCHAR2
--              x_msg_count          OUT NOCOPY   NUMBER
--              x_msg_data           OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Get_AvailableQty(
    p_api_version        IN NUMBER,
    p_init_msg_list      IN VARCHAR2 := L_FND_FALSE,
    p_commit             IN VARCHAR2 := L_FND_FALSE,
    p_ship_line_src_code IN VARCHAR2,
    p_parent_id          IN NUMBER,
    p_available_quantity IN OUT NOCOPY NUMBER,
    p_tolerable_quantity IN OUT NOCOPY NUMBER,
    p_unit_of_measure    IN OUT NOCOPY VARCHAR2,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2)
IS
    CURSOR c_rcv_shipmt_lines IS
      SELECT rsl.shipment_line_id,
             rsl.item_id,
             pll.unit_meas_lookup_code
      FROM rcv_shipment_lines rsl,
           po_line_locations_all pll
      WHERE rsl.lcm_shipment_line_id IS NOT NULL
      AND pll.line_location_id = rsl.po_line_location_id
      AND rsl.po_line_location_id = p_parent_id
      AND NOT EXISTS(SELECT 1
                     FROM rcv_transactions_interface rti,
                          rcv_transactions rt
               WHERE rti.shipment_line_id (+) = rt.shipment_line_id -- Bug #8235573
                 AND rsl.shipment_line_id = rt.shipment_line_id);

    l_rcv_shipmt_lines c_rcv_shipmt_lines%ROWTYPE;
    l_api_name CONSTANT VARCHAR2(30) := 'Get_AvailableQty';
    l_api_version CONSTANT NUMBER := 1.0;
    l_return_status VARCHAR2(1) ;
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);
    l_debug_info VARCHAR2(200);
    l_transaction_type VARCHAR2(100);
    l_receipt_source_code VARCHAR2(100);
    l_quantity_rsl NUMBER;
    l_tolerable_quantity_rsl NUMBER;
    l_secondary_available_qty_rsl NUMBER;
    l_unit_of_measure_rsl VARCHAR2(30);
    l_converted_qty_rsl NUMBER;
    l_total_quantity_rsl NUMBER := 0;

    l_rti_quantity NUMBER; --Bug#16735112
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean (p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    -- Check for call compatibility.
    IF NOT
        FND_API.Compatible_API_Call (
            l_api_version,
            p_api_version,
            l_api_name,
            G_PKG_NAME)
    THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;
    -- Define the transaction type and receipt source code
    -- based the current Shipment Line Source Code.
    IF p_ship_line_src_code = 'PO' THEN
        l_transaction_type := 'RECEIVE';
        l_receipt_source_code := 'VENDOR';
    ELSIF p_ship_line_src_code = 'IR' THEN
        l_transaction_type := 'RECEIVE';
        l_receipt_source_code := 'INTERNAL ORDER';
    ELSIF p_ship_line_src_code = 'RMA' THEN
        l_transaction_type := 'RECEIVE';
        l_receipt_source_code := 'CUSTOMER';
    END IF;
    -- Logging variables
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'l_transaction_type',
        p_var_value => l_transaction_type) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'l_receipt_source_code',
        p_var_value => l_receipt_source_code) ;
    l_debug_info := 'Call RCV_QUANTITIES_S.get_available_quantity - PLL';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info => l_debug_info);
    -- This call will return the available qty not considering qty on RSL.
    RCV_QUANTITIES_S.get_available_quantity (
        p_transaction_type        => l_transaction_type,
        p_parent_id               => p_parent_id,
        p_receipt_source_code     => l_receipt_source_code,
        p_parent_transaction_type => NULL,
        p_grand_parent_id         => NULL,
        p_correction_type         => NULL,
        p_available_quantity      => p_available_quantity,
        p_tolerable_quantity      => p_tolerable_quantity,
        p_unit_of_measure         => p_unit_of_measure);
    -- Logging variables
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'p_available_quantity',
        p_var_value => p_available_quantity);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'p_tolerable_quantity',
        p_var_value => p_tolerable_quantity);

    --Bug#16735112 BEGIN
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info => 'Before verify_RTIinError');

    verify_RTIinError(
        p_parent_id               => p_parent_id,
        p_receipt_source_code     => l_receipt_source_code,
        p_unit_of_measure         => p_unit_of_measure,
        x_rti_quantity            => l_rti_quantity,
        x_return_status           => l_return_status,
        x_msg_count               => l_msg_count,
        x_msg_data                => l_msg_data
        );

    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info => 'After verify_RTIinError');
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'l_rti_quantity',
        p_var_value => l_rti_quantity);
    IF NVL(l_rti_quantity,0) > 0 THEN
        IF p_available_quantity > l_rti_quantity THEN
             p_available_quantity:=p_available_quantity-l_rti_quantity;
        ELSE
             p_available_quantity := 0;
        END IF;
        IF p_tolerable_quantity > l_rti_quantity THEN
             p_tolerable_quantity:=p_tolerable_quantity-l_rti_quantity;
        ELSE
             p_tolerable_quantity := 0;
        END IF;
    END IF;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => '2-p_available_quantity',
        p_var_value => p_available_quantity);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => '2-p_tolerable_quantity',
        p_var_value => p_tolerable_quantity);
    --Bug#16735112 END

    -- Iterate through all RCV Shipment Lines based on a given PLL.
    FOR l_rcv_shipmt_lines IN c_rcv_shipmt_lines
    LOOP
        l_debug_info := 'Call RCV_QUANTITIES_S.get_available_quantity - RSL';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_debug_info => l_debug_info);
        -- This call will return the quantity on RSL that should be deducted from the available quantity.
        RCV_QUANTITIES_S.get_available_quantity(
            p_transaction_type        => 'RECEIVE',
            p_parent_id               => l_rcv_shipmt_lines.shipment_line_id,
            p_receipt_source_code     => 'INVENTORY',
            p_parent_transaction_type => NULL,
            p_grand_parent_id         => NULL,
            p_correction_type         => NULL,
            p_available_quantity      => l_quantity_rsl,
            p_tolerable_quantity      => l_tolerable_quantity_rsl,
            p_unit_of_measure         => l_unit_of_measure_rsl,
            p_secondary_available_qty => l_secondary_available_qty_rsl);
        -- Necessary convertion so that the available quantity can be calculated in the PO UOM.
        PO_UOM_S.uom_convert(
            l_quantity_rsl,
            l_unit_of_measure_rsl,
            l_rcv_shipmt_lines.item_id,
            l_rcv_shipmt_lines.unit_meas_lookup_code,
            l_converted_qty_rsl);
        l_total_quantity_rsl := l_total_quantity_rsl + NVL(l_converted_qty_rsl,0);
    END LOOP;
    -- Deduct from the current available qty the converted qty from RSL
    p_available_quantity := NVL(p_available_quantity,0) - l_total_quantity_rsl;
    -- Deduct from the current tolerance the converted qty from RSL
    p_tolerable_quantity := NVL(p_tolerable_quantity,0) - l_total_quantity_rsl;
    -- Just to prevent negative if this shipment has been over received. In this
    -- case, the available/tolerable quantities that needs to be passed back should be 0.
    IF p_available_quantity < 0 THEN
      p_available_quantity := 0;
    END IF;
    IF p_tolerable_quantity < 0 THEN
      p_tolerable_quantity := 0;
    END IF;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'p_available_quantity',
        p_var_value => p_available_quantity);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'p_tolerable_quantity',
        p_var_value => p_tolerable_quantity);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'p_unit_of_measure',
        p_var_value => p_unit_of_measure) ;
    -- Standard check of p_commit.
    IF FND_API.To_Boolean (p_commit) THEN
        COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data) ;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
EXCEPTION
WHEN L_FND_EXC_ERROR THEN
    -- Standard Expected Error Logging
    INL_LOGGING_PVT.Log_ExpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
    x_return_status := L_FND_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data) ;
WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data) ;
WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg (
            p_pkg_name => g_pkg_name,
            p_procedure_name => l_api_name) ;
    END IF;
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data) ;
END Get_AvailableQty;
-- Utility name : Check_AvailableQty
-- Type       : Private
-- Function   : Check whether Shipment Line Qty is compliant with the PO available Qty
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_primary_qty             IN NUMBER
--              p_sum_primary_qty         IN NUMBER
--              p_primary_uom_code        IN VARCHAR2
--              p_txn_uom_code            IN VARCHAR2
--              p_inventory_item_id       IN NUMBER
--              p_inv_org_id              IN NUMBER
--              p_ship_line_id            IN NUMBER
--              p_ship_line_num           IN NUMBER
--              p_ship_line_src_type_code IN VARCHAR2
--              p_ship_line_src_id        IN NUMBER
--              p_same_shiph_id           IN NUMBER
--              p_ship_header_id          IN NUMBER
-- OUT          x_return_status           OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Check_AvailableQty(
    p_primary_qty             IN NUMBER,
    p_sum_primary_qty         IN NUMBER,
    p_primary_uom_code        IN VARCHAR2,
    p_txn_uom_code            IN VARCHAR2,
    p_inventory_item_id       IN NUMBER,
    p_inv_org_id              IN NUMBER,
    p_ship_line_id            IN NUMBER,
    p_ship_line_num           IN NUMBER,
    p_ship_line_src_type_code IN VARCHAR2,
    p_ship_line_src_id        IN NUMBER,
    p_same_shiph_id           IN NUMBER,
    p_ship_header_id          IN NUMBER,
    x_return_status           OUT NOCOPY VARCHAR2
) IS
    l_program_name CONSTANT VARCHAR2(30) := 'Check_AvailableQty';
    l_msg VARCHAR2(2000);
    l_debug_info VARCHAR2(200);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2 (2000);
    l_acpt_qty VARCHAR2(1);
    l_return_status VARCHAR2 (1);
    l_error_message_name VARCHAR2(200);
    l_shipln_duplicated BOOLEAN := FALSE;
    x_uom_code VARCHAR2(3);
    x_available_quantity NUMBER;
    x_tolerable_quantity NUMBER;
    x_unit_of_measure VARCHAR2(100);
    x_qty_in_others_ops NUMBER;
    l_txn_uom_tl VARCHAR2(30);
    l_txn_uom_code VARCHAR2(3);
    l_primary_uom_tl VARCHAR2(30);
    l_msg_tolerable_qty NUMBER;
    l_msg_uom_tl VARCHAR2(30);
    l_pre_receive VARCHAR2(1);
    l_ship_qty_validation_inf_tbl ship_qty_validation_inf_tbl;
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'x_qty_in_others_ops',
        p_var_value => x_qty_in_others_ops) ;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_primary_qty',
        p_var_value => p_primary_qty) ;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_sum_primary_qty',
        p_var_value => p_sum_primary_qty) ;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_primary_uom_code',
        p_var_value => p_primary_uom_code) ;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_inventory_item_id',
        p_var_value => p_inventory_item_id) ;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_inv_org_id',
        p_var_value => p_inv_org_id) ;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_ship_line_id',
        p_var_value => p_ship_line_id) ;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_ship_line_num',
        p_var_value => p_ship_line_num) ;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_ship_line_src_type_code',
        p_var_value => p_ship_line_src_type_code) ;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_ship_line_src_id',
        p_var_value => p_ship_line_src_id) ;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_same_shiph_id',
        p_var_value => p_same_shiph_id) ;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_ship_header_id',
        p_var_value => p_ship_header_id) ;


    -- Bug #9232187
    -- Just validate PO Available Qty for Pre-Receiving
    -- Organizations. In Blackbox, RCV handles this validation.
    SELECT pre_receive
      INTO l_pre_receive
      FROM rcv_parameters
     WHERE organization_id = p_inv_org_id;

    IF (NVL(l_pre_receive, 'N') = 'N') THEN
        RETURN;
    END IF;

    -- Check if primary qty is ZERO
    IF NVL (p_primary_qty, 0) = 0 THEN
        FND_MESSAGE.SET_NAME ('INL', 'INL_ERR_CHK_SHIP_LN_QTY_ZERO') ;
        FND_MESSAGE.SET_TOKEN ('SHIP_LINE_NUM', p_ship_line_num) ;
        FND_MSG_PUB.ADD;
        -- INCLUDE A LINE IN INL_SHIP_HOLdS
        Handle_ShipError (
            p_ship_header_id => p_ship_header_id,
            p_ship_line_id => p_ship_line_id,
            p_charge_line_id => NULL,
            p_table_name => 'INL_SHIP_LINES',
            p_column_name => 'PRIMARY_QTY',
            p_column_value => 0,
            p_error_message => SUBSTR (FND_MSG_PUB.Get(
                                            p_msg_index => FND_MSG_PUB.Count_Msg (),
                                            p_encoded => L_FND_FALSE), 1, 2000
                                ),
            p_error_message_name => 'INL_ERR_CHK_SHIP_LN_QTY_ZERO',
            p_token1_name => 'SHIP_LINE_NUM',
            p_token1_value => p_ship_line_num,
            p_token2_name => NULL,
            p_token2_value => NULL,
            p_token3_name => NULL,
            p_token3_value => NULL,
            p_token4_name => NULL,
            p_token4_value => NULL,
            p_token5_name => NULL,
            p_token5_value => NULL,
            p_token6_name => NULL,
            p_token6_value => NULL,
            x_return_status => l_return_status) ;
        -- If unexpected errors happen abort
        IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
    ELSE
        l_debug_info := 'INL_SHIPMENT_PVT.Get_AvailableQty';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_program_name,
            p_debug_info => l_debug_info ) ;
        -- Get the PO Avaliable and Tolerable Quantities
        INL_SHIPMENT_PVT.Get_AvailableQty(
            p_api_version        => 1.0,
            p_init_msg_list      => L_FND_FALSE,
            p_commit             => L_FND_FALSE,
            p_ship_line_src_code => p_ship_line_src_type_code,
            p_parent_id          => p_ship_line_src_id,
            p_available_quantity => x_available_quantity,
            p_tolerable_quantity => x_tolerable_quantity,
            p_unit_of_measure    => x_unit_of_measure,
            x_return_status      => l_return_status,
            x_msg_count          => l_msg_count,
            x_msg_data           => l_msg_data);
        INL_LOGGING_PVT.Log_Variable (
            p_module_name => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name => 'x_available_quantity',
            p_var_value => x_available_quantity);

        INL_LOGGING_PVT.Log_Variable (
            p_module_name => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name => 'x_tolerable_quantity',
            p_var_value => x_tolerable_quantity);

        INL_LOGGING_PVT.Log_Variable (
            p_module_name => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name => 'x_unit_of_measure',
            p_var_value => x_unit_of_measure);
        -- Get the UOM Code
        SELECT uom_code
        INTO x_uom_code
        FROM mtl_units_of_measure
        WHERE unit_of_measure = x_unit_of_measure;
        INL_LOGGING_PVT.Log_Variable (
            p_module_name  => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name => 'x_uom_code',
            p_var_value => x_uom_code) ;

        INL_LOGGING_PVT.Log_Variable (
            p_module_name  => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name => 'p_primary_uom_code',
            p_var_value => p_primary_uom_code
        ) ;
        l_debug_info := 'If necessary, it converts the qty (INL_landedcost_pvt.Converted_Qty).';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_program_name,
            p_debug_info => l_debug_info ) ;
        -- Convert to Primary Qty when Unit of Measure is different
        IF x_uom_code <> p_primary_uom_code THEN
            x_available_quantity := INL_LANDEDCOST_PVT.converted_qty (
                                        p_organization_id => p_inv_org_id,
                                        p_inventory_item_id => p_inventory_item_id,
                                        p_qty => x_available_quantity,
                                        p_from_uom_code => x_uom_code,
                                        p_to_uom_code => p_primary_uom_code);
            x_tolerable_quantity := INL_LANDEDCOST_PVT.converted_qty (
                                        p_organization_id => p_inv_org_id,
                                        p_inventory_item_id => p_inventory_item_id,
                                        p_qty => x_tolerable_quantity,
                                        p_from_uom_code => x_uom_code,
                                        p_to_uom_code => p_primary_uom_code);
        END IF;
        -- Get the transaction UOM description. This will be used to show the
        -- validation error message in the transaction uom instead of the primary uom.
        SELECT mum.unit_of_measure_tl
          INTO l_txn_uom_tl
          FROM mtl_units_of_measure_vl mum
         WHERE mum.uom_code = p_txn_uom_code;
        -- Since Primary and Transaction UOM are different, convert to Transaction UOM.
        IF p_txn_uom_code <> p_primary_uom_code THEN
            l_msg_tolerable_qty := INL_LANDEDCOST_PVT.converted_qty (
                                        p_organization_id => p_inv_org_id,
                                        p_inventory_item_id => p_inventory_item_id,
                                        p_qty => x_tolerable_quantity,
                                        p_from_uom_code => x_uom_code,
                                        p_to_uom_code => p_txn_uom_code);
            l_msg_uom_tl := l_txn_uom_tl;
        -- Otherwise keep the same value that comes from Primary UOM.
        ELSE
            -- Get the Primary Unit of Measure Description
            SELECT unit_of_measure_tl
            INTO l_primary_uom_tl
            FROM mtl_units_of_measure_vl
            WHERE uom_code = p_primary_uom_code;
            l_msg_tolerable_qty := x_tolerable_quantity;
            l_msg_uom_tl := l_primary_uom_tl;
        END IF;
        -- Validate the transaction primary qty with the tolerable qty
        IF p_primary_qty > x_tolerable_quantity OR p_sum_primary_qty > x_tolerable_quantity THEN
            l_acpt_qty  := 'N';
            -- Check if the validation message should be handled as
            -- a duplicated (two or more lines with the same Line
            -- Location Id) or as a single Shipment Line
            IF (p_sum_primary_qty    > p_primary_qty) THEN
                l_shipln_duplicated := TRUE;
            END IF;
            -- In Receiving (RCV_QUANTITIES_S) the rcv_exception_code is checked FOR POs only.
            IF p_ship_line_src_type_code = 'PO' THEN
                l_debug_info := 'Verify in po_line_locations_all the Over-Receipt Quantity Control Action';
                INL_LOGGING_PVT.Log_Statement (
                    p_module_name => g_module_name,
                    p_procedure_name => l_program_name,
                    p_debug_info => l_debug_info) ;

                 SELECT DECODE (pll.qty_rcv_exception_code, 'NONE', 'Y', 'N')
                   INTO l_acpt_qty
                   FROM po_line_locations pll
                  WHERE pll.line_location_id = p_ship_line_src_id;
            END IF;
            IF l_acpt_qty = 'N' THEN
                IF (l_shipln_duplicated = TRUE) THEN
                    FND_MESSAGE.SET_NAME ('INL', 'INL_ERR_CHK_SHIP_LN_QTY_TOL_S') ;
                ELSE
                    FND_MESSAGE.SET_NAME ('INL', 'INL_ERR_CHK_SHIP_LN_QTY_TOL') ;
                END IF;
                FND_MESSAGE.SET_TOKEN ('SHIP_LINE_NUM', p_ship_line_num) ;
                FND_MESSAGE.SET_TOKEN ('QTY', l_msg_tolerable_qty) ;
                FND_MESSAGE.SET_TOKEN ('UOM', l_msg_uom_tl) ;
                FND_MSG_PUB.ADD;
                -- INCLUDE A LINE IN INL_SHIP_HOLdS
                Handle_ShipError (
                    p_ship_header_id => p_ship_header_id,
                    p_ship_line_id => p_ship_line_id,
                    p_charge_line_id => NULL,
                    p_table_name => 'INL_SHIP_LINES',
                    p_column_name => 'PRIMARY_QTY',
                    p_column_value => p_primary_qty,
                    p_error_message => SUBSTR (FND_MSG_PUB.Get (
                                                p_msg_index => FND_MSG_PUB.Count_Msg (),
                                                p_encoded => L_FND_FALSE), 1, 2000),
                    p_error_message_name => l_error_message_name,
                    p_token1_name => 'SHIP_LINE_NUM',
                    p_token1_value => p_ship_line_num,
                    p_token2_name => 'QTY',
                    p_token2_value => l_msg_tolerable_qty,
                    p_token3_name => 'UOM',
                    p_token3_value => l_msg_uom_tl,
                    p_token4_name => NULL,
                    p_token4_value => NULL,
                    p_token5_name => NULL,
                    p_token5_value => NULL,
                    p_token6_name => NULL,
                    p_token6_value => NULL,
                    x_return_status => l_return_status) ;
                -- If unexpected errors happen abort
                IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
                    RAISE L_FND_EXC_UNEXPECTED_ERROR;
                END IF;
            END IF;
        ELSE
            -- Search for other Shipment lines in Validated Shipments
            -- with receipts for the same receipt_source_code and src_id
             SELECT NVL (SUM (sl.primary_qty), 0)
               INTO x_qty_in_others_ops
               FROM inl_ship_headers sh,
                inl_adj_ship_lines_v sl
              WHERE sl.ship_header_id = sh.ship_header_id
                AND NVL (sl.parent_ship_line_id, sl.ship_line_id) <> p_ship_line_id
                AND
                (
                    sh.ship_status_code  = 'VALIDATED'
                    OR sh.ship_header_id = NVL (p_same_shiph_id, 9999999999)
                )
                AND sh.rcv_enabled_flag = 'Y' -- Bug #8981485
                AND sl.ship_line_src_type_code = p_ship_line_src_type_code
                AND sl.ship_line_source_id = p_ship_line_src_id;
            INL_LOGGING_PVT.Log_Variable (
                p_module_name => g_module_name,
                p_procedure_name => l_program_name,
                p_var_name => 'x_qty_in_others_ops',
                p_var_value => x_qty_in_others_ops) ;

            IF x_qty_in_others_ops + p_primary_qty > x_tolerable_quantity THEN
                l_debug_info := 'x_qty_in_others_ops + p_primary_qty > x_tolerable_quantity';
                INL_LOGGING_PVT.Log_Statement (
                    p_module_name => g_module_name,
                    p_procedure_name => l_program_name,
                    p_debug_info => l_debug_info) ;

                -- Start of Bug #9755545
                FND_MESSAGE.SET_NAME ('INL', 'INL_ERR_CHK_SHIP_LN_QTY_OTH_L');
                FND_MESSAGE.SET_TOKEN ('SHIP_LINE_NUM', p_ship_line_num);
                FND_MESSAGE.SET_TOKEN ('SRC_TYPE', p_ship_line_src_type_code);
                FND_MESSAGE.SET_TOKEN ('QTY', l_msg_tolerable_qty);
                FND_MESSAGE.SET_TOKEN ('UOM', l_msg_uom_tl);
                FND_MSG_PUB.ADD;

                SELECT DISTINCT sh.ship_num,
                                sl.ship_line_num
                BULK COLLECT INTO l_ship_qty_validation_inf_tbl
                  FROM inl_ship_headers sh,
                       inl_adj_ship_lines_v sl
                 WHERE sl.ship_header_id = sh.ship_header_id
                   AND NVL (sl.parent_ship_line_id, sl.ship_line_id) <> p_ship_line_id
                   AND
                     (
                        sh.ship_status_code  = 'VALIDATED'
                        OR sh.ship_header_id = NVL (p_same_shiph_id, 9999999999)
                     )
                   AND sh.rcv_enabled_flag = 'Y' -- Bug 9735125
                   AND sl.ship_line_src_type_code = p_ship_line_src_type_code
                   AND sl. ship_line_source_id = p_ship_line_src_id
                ORDER BY sh.ship_num, sl.ship_line_num;

                FOR i IN 1 .. l_ship_qty_validation_inf_tbl.COUNT LOOP
                    FND_MESSAGE.SET_NAME ('INL', 'INL_ERR_CHK_SHIP_LN_QTY_INFO');
                    FND_MESSAGE.SET_TOKEN ('SHIP_NUM', l_ship_qty_validation_inf_tbl(i).ship_num);
                    FND_MESSAGE.SET_TOKEN ('SHIP_LINE_NUM', l_ship_qty_validation_inf_tbl(i).ship_line_num);
                    FND_MSG_PUB.ADD;
                END LOOP;
                -- End of Bug #9755545

                /*FOR c_ship_num IN
                (
                    SELECT DISTINCT sh.ship_num
                       FROM inl_ship_headers sh,
                        inl_adj_ship_lines_v sl
                      WHERE sl.ship_header_id = sh.ship_header_id
                        AND NVL (sl.parent_ship_line_id, sl.ship_line_id) <> p_ship_line_id
                        AND
                        (
                            sh.ship_status_code  = 'VALIDATED'
                            OR sh.ship_header_id = NVL (p_same_shiph_id, 9999999999)
                        )
                        AND sh.rcv_enabled_flag = 'Y' -- Bug 9735125
                        AND sl.ship_line_src_type_code = p_ship_line_src_type_code
                        AND sl. ship_line_source_id = p_ship_line_src_id
                   ORDER BY sh.ship_num
                )
                LOOP
                    l_msg := l_msg||c_ship_num.ship_num||', ';-- Bug 9735125
                    exit when LENGTH(l_msg)>30;
                END LOOP;
                IF LENGTH(l_msg)>2 THEN
                    l_msg := SUBSTR(l_msg,1,LENGTH(l_msg)-2);-- Bug 9735125
                END IF;
                FND_MESSAGE.SET_NAME ('INL', 'INL_ERR_CHK_SHIP_LN_QTY_OTH_L') ;
                FND_MESSAGE.SET_TOKEN ('SRC_TYPE', p_ship_line_src_type_code) ;
                FND_MESSAGE.SET_TOKEN ('QTY', l_msg_tolerable_qty) ;
                FND_MESSAGE.SET_TOKEN ('UOM', l_msg_uom_tl) ;
                FND_MESSAGE.SET_TOKEN ('SHIPHS', l_msg) ;--BUG#9735125
                FND_MSG_PUB.ADD;*/



                --INCLUDE A LINE IN INL_SHIP_HOLdS
                Handle_ShipError (
                    p_ship_header_id => p_ship_header_id,
                    p_ship_line_id => p_ship_line_id,
                    p_charge_line_id => NULL,
                    p_table_name => 'INL_SHIP_LINES',
                    p_column_name => NULL,
                    p_column_value => NULL,
                    p_error_message => SUBSTR (FND_MSG_PUB.Get (
                                                p_msg_index => FND_MSG_PUB.Count_Msg (),
                                                p_encoded => L_FND_FALSE), 1, 2000),
                    p_error_message_name => 'INL_ERR_CHK_SHIP_LN_QTY_OTH_L',
                    p_token1_name => 'SRC_TYPE',
                    p_token1_value => p_ship_line_src_type_code,
                    p_token2_name => 'QTY',
                    p_token2_value => l_msg_tolerable_qty,
                    p_token3_name => 'UOM',
                    p_token3_value => l_msg_uom_tl,
                    p_token4_name => 'SHIPHS',
                    p_token4_value => l_msg, --BUG#9735125
                    p_token5_name => NULL,
                    p_token5_value => NULL,
                    p_token6_name => NULL,
                    p_token6_value => NULL,
                    x_return_status => l_return_status) ;
            END IF;
        END IF;
    END IF;
    INL_LOGGING_PVT.Log_EndProc ( p_module_name => g_module_name,
                                  p_procedure_name => l_program_name) ;
EXCEPTION
WHEN L_FND_EXC_ERROR THEN
    x_return_status := L_FND_RET_STS_ERROR;
WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
WHEN OTHERS THEN
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg (
            p_pkg_name => g_pkg_name,
            p_procedure_name => l_program_name) ;
    END IF;
END Check_AvailableQty;
-- Utility name : Check_PoPriceTolerance
-- Type       : Private
-- Function   : Check whether Shipment Line Price is compliant with the PO
--              Price Tolerance defined in the INL Setup Options
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_header_id     IN NUMBER
--              p_ship_line_id             IN NUMBER,
--              p_organization_id          IN NUMBER,
--              p_ship_line_num            IN NUMBER,
--              p_ship_line_src_id         IN NUMBER,
--              p_pri_unit_price           IN NUMBER,
--              p_primary_uom_code         IN VARCHAR2,
--              p_currency_code            IN VARCHAR2,
--              p_currency_conversion_type IN VARCHAR2,
--              p_currency_conversion_date IN DATE,
--              p_currency_conversion_rate IN NUMBER,
--              x_return_status            OUT NOCOPY VARCHAR2
--
-- OUT          x_return_status      OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Check_PoPriceTolerance(
    p_ship_header_id           IN NUMBER,
    p_ship_line_id             IN NUMBER,
    p_organization_id          IN NUMBER,
    p_ship_line_num            IN NUMBER,
    p_ship_line_src_id         IN NUMBER,
    p_pri_unit_price           IN NUMBER,
    p_primary_uom_code         IN VARCHAR2, --BUG#7670307
    p_currency_code            IN VARCHAR2, --BUG#7670307
    p_currency_conversion_type IN VARCHAR2, --BUG#7670307
    p_currency_conversion_date IN DATE,     --BUG#7670307
    p_currency_conversion_rate IN NUMBER,   --BUG#7670307
    x_return_validation_status OUT NOCOPY VARCHAR2, -- SCM-051
    x_return_status            OUT NOCOPY VARCHAR2
) IS
    l_program_name           CONSTANT VARCHAR2(30) := 'Check_PoPriceTolerance';
    l_msg                 VARCHAR2(2000) ;
    l_debug_info          VARCHAR2(200) ;
    l_return_status       VARCHAR2(1) ;
    l_po_price_toler_perc NUMBER;
    l_actual_price_dif    NUMBER;
    l_tolerable_dif       NUMBER;
    l_po_unit_price       NUMBER;
   -- l_amount              NUMBER; -- Bug #11710754
    l_po_qty              NUMBER;
    l_inventory_item_id   NUMBER;
    l_po_currency_code             VARCHAR2(15);
    l_po_currency_conversion_type  VARCHAR2(30);
    l_po_currency_conversion_date  DATE;
    l_po_currency_conversion_rate  NUMBER;
    l_po_converted_price           NUMBER;
    l_p_converted_PUP              NUMBER;
    l_po_UOM_code                  VARCHAR2(30);
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    --  Initialize API return status variables
    x_return_status := L_FND_RET_STS_SUCCESS;
    x_return_validation_status := 'TRUE'; -- SCM-051

    -- Get the Price Tolerance from INL Setup Options
    SELECT po_price_toler_perc
      INTO l_po_price_toler_perc
      FROM inl_parameters
     WHERE organization_id = p_organization_id;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'l_po_price_toler_perc',
        p_var_value => l_po_price_toler_perc
    ) ;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_pri_unit_price',
        p_var_value => p_pri_unit_price
    ) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_primary_uom_code',
        p_var_value => p_primary_uom_code
    ) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_currency_code',
        p_var_value => p_currency_code
    ) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_currency_conversion_type',
        p_var_value => p_currency_conversion_type
    ) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_currency_conversion_date',
        p_var_value => p_currency_conversion_date
    ) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_currency_conversion_rate',
        p_var_value => p_currency_conversion_rate
    ) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_ship_header_id',
        p_var_value => p_ship_header_id
    ) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_ship_line_id',
        p_var_value => p_ship_line_id
    ) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_organization_id',
        p_var_value => p_organization_id
    ) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_ship_line_num',
        p_var_value => p_ship_line_num
    ) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_ship_line_src_id',
        p_var_value => p_ship_line_src_id
    ) ;

    -- Get the PO Unit Price
    SELECT po.unit_price,
           po.currency_code,                --BUG#7670307
           po.currency_conversion_type,     --BUG#7670307
           po.currency_conversion_date,     --BUG#7670307
           po.currency_conversion_rate,     --BUG#7670307
           muom.uom_code,                   --BUG#7670307
           po.ordered_qty,
           po.item_id
      INTO l_po_unit_price,
           l_po_currency_code,
           l_po_currency_conversion_type,
           l_po_currency_conversion_date,
           l_po_currency_conversion_rate,
           l_po_UOM_code,
           l_po_qty,
           l_inventory_item_id
      FROM inl_enter_receipts_v po,  -- BUG#8229331 (Pls see bug 9179775)
           mtl_units_of_measure muom
     WHERE po.po_line_location_id = p_ship_line_src_id
       AND muom.unit_of_measure (+) = po.ordered_uom;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'l_po_unit_price',
        p_var_value => l_po_unit_price
    ) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'l_po_currency_code',
        p_var_value => l_po_currency_code
    ) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'l_po_currency_conversion_type',
        p_var_value => l_po_currency_conversion_type
    ) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'l_po_currency_conversion_date',
        p_var_value => l_po_currency_conversion_date
    ) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'l_po_currency_conversion_rate',
        p_var_value => l_po_currency_conversion_rate
    ) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'l_po_UOM_code',
        p_var_value => l_po_UOM_code
    ) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'l_po_qty',
        p_var_value => l_po_qty
    ) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'l_inventory_item_id',
        p_var_value => l_inventory_item_id
    ) ;

    l_debug_info := 'Verifying if currency conversion is required. PO: '||l_po_currency_code ||' Shipment: '||p_currency_code;
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_debug_info => l_debug_info
    );
    IF  l_po_currency_code = p_currency_code THEN --BUG#7670307
        l_po_converted_price := l_po_unit_price;
        l_p_converted_PUP    := p_pri_unit_price;
    ELSE
        IF l_po_currency_conversion_rate IS NOT NULL THEN
            l_po_converted_price := l_po_unit_price * l_po_currency_conversion_rate;
        ELSE
            l_po_converted_price := l_po_unit_price;
        END IF;
        IF p_currency_conversion_rate IS NOT NULL THEN
            l_p_converted_PUP := p_pri_unit_price * p_currency_conversion_rate;
        ELSE
            l_p_converted_PUP := p_pri_unit_price;
        END IF;
    END IF;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'l_po_converted_price',
        p_var_value => l_po_converted_price
        ) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'l_p_converted_PUP',
        p_var_value => l_p_converted_PUP
        ) ;

    l_debug_info := 'Verifying if UOM conversion is required. PO: '||l_po_UOM_code ||' Shipment: '||p_primary_uom_code;
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_debug_info => l_debug_info
    );
    IF  p_primary_uom_code <> l_po_UOM_code THEN        --BUG#7670307
        -- Bug #11710754
        /*
        l_amount := l_po_converted_price * l_po_qty;
        l_po_qty := INL_LANDEDCOST_PVT.Converted_Qty(
                        p_organization_id   => p_organization_id,
                        p_inventory_item_id => l_inventory_item_id,
                        p_qty               => l_po_qty,
                        p_from_uom_code     => l_po_UOM_code,
                        P_to_uom_code       => p_primary_uom_code
                    );
        l_po_converted_price := l_amount / l_po_qty;
        */

        l_po_converted_price := INL_LANDEDCOST_PVT.Converted_Price(
                            p_unit_price        => l_po_converted_price,
                            p_organization_id   => p_organization_id,
                            p_inventory_item_id => l_inventory_item_id,
                            p_from_uom_code     => l_po_uom_code,
                            p_to_uom_code       => p_primary_uom_code);

        -- /Bug #11710754

        INL_LOGGING_PVT.Log_Variable (
            p_module_name => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name => 'l_po_converted_price',
            p_var_value => l_po_converted_price
            ) ;

    END IF;
    -- When there is no tolerance defined in
    -- INL Setup Options for the current Inventory
    -- Organization, the Shipment Line price is validated
    -- not to be greater than price defined in PO.
    IF l_po_price_toler_perc IS NULL THEN
        IF (l_p_converted_PUP  > l_po_converted_price) THEN
            x_return_validation_status := 'FALSE'; -- SCM-051
            FND_MESSAGE.SET_NAME ('INL', 'INL_ERR_NOT_DEF_PO_PRICE_TOLER') ;
            FND_MESSAGE.SET_TOKEN ('SHIPLN_NUM', p_ship_line_num) ;
            FND_MSG_PUB.ADD;
            -- INCLUDE A LINE IN INL_SHIP_HOLdS
            Handle_ShipError (
                p_ship_header_id => p_ship_header_id,
                p_ship_line_id => p_ship_line_id,
                p_charge_line_id => NULL,
                p_table_name => 'INL_SHIP_LINES',
                p_column_name => 'PRIMARY_UNIT_PRICE',
                p_column_value => 0,
                p_error_message => SUBSTR (FND_MSG_PUB.Get (
                                                p_msg_index => FND_MSG_PUB.Count_Msg (),
                                                p_encoded => L_FND_FALSE), 1, 2000),
                p_error_message_name => 'INL_ERR_NOT_DEF_PO_PRICE_TOLER',
                p_token1_name => 'SHIPLN_NUM',
                p_token1_value => p_ship_line_num,
                p_token2_name => NULL,
                p_token2_value => NULL,
                p_token3_name => NULL,
                p_token3_value => NULL,
                p_token4_name => NULL,
                p_token4_value => NULL,
                p_token5_name => NULL,
                p_token5_value => NULL,
                p_token6_name => NULL,
                p_token6_value => NULL,
                x_return_status => l_return_status) ;
        END IF;
    -- Otherwise will check a unique Shipment Line Unit Price
    -- Check the actual difference against the tolerable difference
    ELSE
        l_actual_price_dif := NVL (l_p_converted_PUP, 0) - NVL (l_po_converted_price, 0) ;
        IF l_actual_price_dif > 0 THEN
            l_tolerable_dif := (l_po_converted_price / 100) * l_po_price_toler_perc;
            IF (l_actual_price_dif > l_tolerable_dif) THEN
                x_return_validation_status := 'FALSE';
                FND_MESSAGE.SET_NAME ('INL', 'INL_ERR_PO_PRICE_TOLER') ;
                FND_MESSAGE.SET_TOKEN ('SHIPLN_NUM', p_ship_line_num) ;
                FND_MESSAGE.SET_TOKEN ('TOLER', l_po_price_toler_perc) ;
                FND_MSG_PUB.ADD;
                -- INCLUDE A LINE IN INL_SHIP_HOLdS
                Handle_ShipError (
                    p_ship_header_id => p_ship_header_id,
                    p_ship_line_id => p_ship_line_id,
                    p_charge_line_id => NULL,
                    p_table_name => 'INL_SHIP_LINES',
                    p_column_name => 'PRIMARY_UNIT_PRICE',
                    p_column_value => 0,
                    p_error_message => SUBSTR (FND_MSG_PUB.Get (
                                                p_msg_index => FND_MSG_PUB.Count_Msg (),
                                                p_encoded => L_FND_FALSE), 1, 2000),
                    p_error_message_name => 'INL_ERR_PO_PRICE_TOLER',
                    p_token1_name => 'SHIPLN_NUM',
                    p_token1_value => p_ship_line_num,
                    p_token2_name => 'TOLER',
                    p_token2_value => l_po_price_toler_perc,
                    p_token3_name => NULL,
                    p_token3_value => NULL,
                    p_token4_name => NULL,
                    p_token4_value => NULL,
                    p_token5_name => NULL,
                    p_token5_value => NULL,
                    p_token6_name => NULL,
                    p_token6_value => NULL,
                    x_return_status => l_return_status) ;
            END IF;
        END IF;
    END IF;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
EXCEPTION
WHEN L_FND_EXC_ERROR THEN
    x_return_status := L_FND_RET_STS_ERROR;
WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
WHEN OTHERS THEN
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg (
            p_pkg_name => g_pkg_name,
            p_procedure_name => l_program_name) ;
    END IF;
END Check_PoPriceTolerance;

-- SCM-051 Bug# 13590582
-- API name   : Check_PoTolerances
-- Type       : Private
-- Function   : API for PO Price and Quantity Tolerances validation.
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version              IN NUMBER    Required
--              p_init_msg_list            IN VARCHAR2  Optional  Default = L_FND_FALSE
--              p_commit                   IN VARCHAR2  Optional  Default = L_FND_FALSE
--              p_ship_header_id           IN NUMBER
--              p_ship_line_id             IN NUMBER
--              p_organization_id          IN NUMBER
--              p_ship_line_num            IN NUMBER
--              p_ship_line_src_id         IN NUMBER
--              p_inventory_item_id        IN NUMBER
--              p_primary_qty              IN NUMBER
--              p_primary_uom_code         IN VARCHAR2
--              p_txn_uom_code             IN VARCHAR2
--              p_new_txn_unit_price       IN NUMBER
--              p_pri_unit_price           IN NUMBER
--              p_currency_code            IN VARCHAR2
--              p_currency_conversion_type IN VARCHAR2
--              p_currency_conversion_date IN DATE
--              p_currency_conversion_rate IN NUMBER
--
-- OUT          x_return_status     OUT NOCOPY VARCHAR2
--              x_msg_count         OUT NOCOPY   NUMBER
--              x_msg_data          OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Check_PoTolerances(
    p_api_version              IN NUMBER,
    p_init_msg_list            IN VARCHAR2 := L_FND_FALSE,
    p_commit                   IN VARCHAR2 := L_FND_FALSE,
    p_ship_header_id           IN NUMBER,
    p_ship_line_id             IN NUMBER,
    p_organization_id          IN NUMBER,
    p_ship_line_num            IN NUMBER,
    p_ship_line_src_id         IN NUMBER,
    p_inventory_item_id        IN NUMBER,
    p_primary_qty              IN NUMBER,
    p_primary_uom_code         IN VARCHAR2,
    p_txn_uom_code             IN VARCHAR2,
    p_new_txn_unit_price       IN NUMBER,
    p_pri_unit_price           IN NUMBER,
    p_currency_code            IN VARCHAR2,
    p_currency_conversion_type IN VARCHAR2,
    p_currency_conversion_date IN DATE,
    p_currency_conversion_rate IN NUMBER,
    x_return_status            OUT NOCOPY VARCHAR2,
    x_msg_count                OUT NOCOPY NUMBER,
    x_msg_data                 OUT NOCOPY VARCHAR2)
IS
    l_program_name    CONSTANT VARCHAR2(30) := 'Check_PoTolerances';
    l_api_version CONSTANT NUMBER := 1.0;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);
    l_debug_info VARCHAR2(200);
    l_return_validation_status VARCHAR2(30);
    l_ship_status_code VARCHAR2(30);
    l_pri_unit_price NUMBER;

BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    -- Standard Start of API savepoint
    SAVEPOINT Check_PoTolerances_PVT;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean (p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    -- Check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_program_name,
                                       G_PKG_NAME) THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;

    INL_LOGGING_PVT.Log_Variable(p_module_name => g_module_name,
                                 p_procedure_name => l_program_name,
                                 p_var_name => 'p_new_txn_unit_price',
                                 p_var_value => p_new_txn_unit_price);

    l_pri_unit_price := p_pri_unit_price;

    BEGIN
        IF p_new_txn_unit_price IS NOT NULL THEN

            l_debug_info := 'Get Primary Unit Price for New Transaction Unit Price';
            INL_LOGGING_PVT.Log_Statement(p_module_name => g_module_name,
                                          p_procedure_name => l_program_name,
                                          p_debug_info => l_debug_info);

            l_pri_unit_price := INL_LANDEDCOST_PVT.Converted_Price(
                                                  p_unit_price => p_new_txn_unit_price,
                                                  p_organization_id   => p_organization_id,
                                                  p_inventory_item_id => p_inventory_item_id,
                                                  p_from_uom_code     => p_txn_uom_code,
                                                  p_to_uom_code       => p_primary_uom_code);

            INL_LOGGING_PVT.Log_Variable(p_module_name => g_module_name,
                                         p_procedure_name => l_program_name,
                                         p_var_name => 'l_pri_unit_price',
                                         p_var_value => l_pri_unit_price);

        END IF;

        INL_SHIPMENT_PVT.Check_PoTolerances(p_api_version              => 1.0,
                                            p_init_msg_list            => FND_API.G_TRUE,
                                            p_commit                   => FND_API.G_FALSE,
                                            p_ship_header_id           => p_ship_header_id ,
                                            p_ship_line_id             => p_ship_line_id ,
                                            p_organization_id          => p_organization_id,
                                            p_ship_line_num            => p_ship_line_num,
                                            p_ship_line_src_id         => p_ship_line_src_id,
                                            p_inventory_item_id        => p_inventory_item_id,
                                            p_primary_qty              => p_primary_qty,
                                            p_primary_uom_code         => p_primary_uom_code,
                                            p_txn_uom_code             => p_txn_uom_code,
                                            p_pri_unit_price           => l_pri_unit_price,
                                            p_currency_code            => p_currency_code,
                                            p_currency_conversion_type => p_currency_conversion_type,
                                            p_currency_conversion_date => p_currency_conversion_date,
                                            p_currency_conversion_rate => p_currency_conversion_rate,
                                            x_return_status            => l_return_status,
                                            x_msg_count                => l_msg_count,
                                            x_msg_data                 => l_msg_data);
    END;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean (p_commit) THEN
        COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data) ;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
EXCEPTION
WHEN L_FND_EXC_ERROR THEN
    -- Standard Expected Error Logging
    INL_LOGGING_PVT.Log_ExpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    ROLLBACK TO Check_PoTolerances_PVT;
    x_return_status := L_FND_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data) ;
WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    ROLLBACK TO Check_PoTolerances_PVT;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data) ;
WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    ROLLBACK TO Check_PoTolerances_PVT;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg (
            p_pkg_name => g_pkg_name,
            p_procedure_name => l_program_name) ;
    END IF;
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data) ;
END Check_PoTolerances;
-- /SCM-051



-- API name   : Check_PoTolerances
-- Type       : Private
-- Function   : API for PO Price and Quantity Tolerances validation.
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version              IN NUMBER    Required
--              p_init_msg_list            IN VARCHAR2  Optional  Default = L_FND_FALSE
--              p_commit                   IN VARCHAR2  Optional  Default = L_FND_FALSE
--              p_ship_header_id           IN NUMBER
--              p_ship_line_id             IN NUMBER
--              p_organization_id          IN NUMBER
--              p_ship_line_num            IN NUMBER
--              p_ship_line_src_id         IN NUMBER
--              p_inventory_item_id        IN NUMBER
--              p_primary_qty              IN NUMBER
--              p_primary_uom_code         IN VARCHAR2
--              p_txn_uom_code             IN VARCHAR2
--              p_pri_unit_price           IN NUMBER
--              p_currency_code            IN VARCHAR2
--              p_currency_conversion_type IN VARCHAR2
--              p_currency_conversion_date IN DATE
--              p_currency_conversion_rate IN NUMBER
--
-- OUT          x_return_status     OUT NOCOPY VARCHAR2
--              x_msg_count         OUT NOCOPY   NUMBER
--              x_msg_data          OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Check_PoTolerances(
    p_api_version              IN NUMBER,
    p_init_msg_list            IN VARCHAR2 := L_FND_FALSE,
    p_commit                   IN VARCHAR2 := L_FND_FALSE,
    p_ship_header_id           IN NUMBER,
    p_ship_line_id             IN NUMBER,
    p_organization_id          IN NUMBER,
    p_ship_line_num            IN NUMBER,
    p_ship_line_src_id         IN NUMBER,
    p_inventory_item_id        IN NUMBER,
    p_primary_qty              IN NUMBER,
    p_primary_uom_code         IN VARCHAR2,
    p_txn_uom_code             IN VARCHAR2,
    p_pri_unit_price           IN NUMBER,
    p_currency_code            IN VARCHAR2,  --BUG#7670307
    p_currency_conversion_type IN VARCHAR2,  --BUG#7670307
    p_currency_conversion_date IN DATE,      --BUG#7670307
    p_currency_conversion_rate IN NUMBER,    --BUG#7670307
    x_return_status            OUT NOCOPY VARCHAR2,
    x_msg_count                OUT NOCOPY NUMBER,
    x_msg_data                 OUT NOCOPY VARCHAR2)
IS
    l_program_name    CONSTANT VARCHAR2(30) := 'Check_PoTolerances';
    l_api_version CONSTANT NUMBER := 1.0;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);
    l_debug_info VARCHAR2(200);
    l_return_validation_status VARCHAR2(30); -- SCM-051
    l_ship_status_code VARCHAR2(30);
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    -- Standard Start of API savepoint
    SAVEPOINT Check_PoTolerances_PVT;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean (p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    -- Check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
        l_api_version,
        p_api_version,
        l_program_name,
        G_PKG_NAME
    ) THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_ship_line_id: ',
        p_var_value => p_ship_line_id);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_ship_header_id: ',
        p_var_value => p_ship_header_id);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_ship_line_src_id: ',
        p_var_value => p_ship_line_src_id);


    l_debug_info := 'Getting Shipment Status Code ';
    INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                   p_procedure_name => l_program_name,
                                   p_debug_info => l_debug_info);
    --SCM-051 Begin
    BEGIN
    -- during insert from UI at this point the record has not been posted yet
        SELECT ish.ship_status_code
          INTO l_ship_status_code
          FROM inl_ship_headers_all ish
         WHERE ish.ship_header_id = p_ship_header_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            l_ship_status_code := 'INCOMPLETE';
    END;
    -- SCM-051 (Check_AvailableQty should only be called for NOT Completed Shipments)
    IF l_ship_status_code <> 'COMPLETED' THEN
    --SCM-051 End
        -- Validate PO Quantity Available
        l_debug_info := 'Call Check_AvailableQty';
        INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                       p_procedure_name => l_program_name,
                                       p_debug_info => l_debug_info);

        Check_AvailableQty(p_primary_qty             => p_primary_qty,
                           p_sum_primary_qty         => NULL,
                           p_primary_uom_code        => p_primary_uom_code,
                           p_txn_uom_code            => p_txn_uom_code,
                           p_inventory_item_id       => p_inventory_item_id,
                           p_inv_org_id              => p_organization_id,
                           p_ship_line_id            => p_ship_line_id,
                           p_ship_line_num           => p_ship_line_num,
                           p_ship_line_src_type_code => 'PO',
                           p_ship_line_src_id        => p_ship_line_src_id,
                           p_same_shiph_id           => p_ship_header_id,
                           p_ship_header_id          => p_ship_header_id,
                           x_return_status           => l_return_status);

        -- If any errors happen abort the process.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get (
     p_encoded => L_FND_FALSE,
     p_count => x_msg_count,
     p_data => x_msg_data) ;

    IF x_msg_count = 0 THEN
        -- Validate PO Price Tolerance
        l_debug_info := 'Call Check_PoPriceTolerance';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_program_name,
            p_debug_info => l_debug_info) ;
        Check_PoPriceTolerance(
            p_ship_header_id           => p_ship_header_id,
            p_ship_line_id             => p_ship_line_id,
            p_organization_id          => p_organization_id,
            p_ship_line_num            => p_ship_line_num,
            p_ship_line_src_id         => p_ship_line_src_id,
            p_pri_unit_price           => p_pri_unit_price,
            p_primary_uom_code         => p_primary_uom_code,           --BUG#7670307
            p_currency_code            => p_currency_code,              --BUG#7670307
            p_currency_conversion_type => p_currency_conversion_type,   --BUG#7670307
            p_currency_conversion_date => p_currency_conversion_date,   --BUG#7670307
            p_currency_conversion_rate => p_currency_conversion_rate,   --BUG#7670307
            x_return_validation_status => l_return_validation_status, -- SCM-051
            x_return_status            => l_return_status
        );
        -- If any errors happen abort the process.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
           RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
           RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;
    -- Standard check of p_commit.
    IF FND_API.To_Boolean (p_commit) THEN
        COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data) ;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
EXCEPTION
WHEN L_FND_EXC_ERROR THEN
    -- Standard Expected Error Logging
    INL_LOGGING_PVT.Log_ExpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    ROLLBACK TO Check_PoTolerances_PVT;
    x_return_status := L_FND_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data) ;
WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    ROLLBACK TO Check_PoTolerances_PVT;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data) ;
WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    ROLLBACK TO Check_PoTolerances_PVT;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg (
            p_pkg_name => g_pkg_name,
            p_procedure_name => l_program_name) ;
    END IF;
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data) ;
END Check_PoTolerances;

-- Utility name   : Validate_ChargeLine
-- Type       : Private
-- Function   : Validate Charge Line
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_header_id              IN  NUMBER
--              p_to_parent_table_name        IN  VARCHAR2
--              p_to_parent_table_id          IN  NUMBER
--              p_functional_currency_code    IN  VARCHAR2
--              p_foreign_currency_flag       IN  VARCHAR2
--              p_third_parties_allowed       IN  VARCHAR2
--
-- OUT        : x_ch_line_tot_amt_func_curr   OUT NOCOPY NUMBER
--              x_return_status               OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Validate_ChargeLine (
    p_ship_header_id             IN NUMBER,
    p_to_parent_table_name       IN VARCHAR2,
    p_to_parent_table_id         IN NUMBER,
    p_functional_currency_code   IN VARCHAR2,
    p_foreign_currency_flag      IN VARCHAR2,
    p_third_parties_allowed      IN VARCHAR2,
    x_ch_line_tot_amt_func_curr OUT NOCOPY NUMBER,
    x_return_status             OUT NOCOPY VARCHAR2
) IS
    l_program_name CONSTANT VARCHAR2 (30) := 'Validate_ChargeLine';
    l_debug_info VARCHAR2 (200);
    l_return_status VARCHAR2 (1);
    CURSOR c_ch_lines IS
      SELECT DECODE (cl.currency_code,
                     p_functional_currency_code,
                     cl.charge_amt,
                     cl.charge_amt * cl.currency_conversion_rate) AS ch_line_amt_func_curr,
             cl.currency_code,
             cl.charge_line_id,
             cl.charge_line_num
      FROM inl_adj_charge_lines_v cl,
           inl_associations assoc
      WHERE assoc.from_parent_table_name = 'INL_CHARGE_LINES'
      AND assoc.from_parent_table_id = NVL (cl.parent_charge_line_id, cl.charge_line_id)
      AND assoc.ship_header_id = p_ship_header_id
      AND assoc.to_parent_table_name = p_to_parent_table_name
      AND assoc.to_parent_table_id = p_to_parent_table_id
      ORDER BY cl.charge_line_num;
      l_ch_lines_rec c_ch_lines%ROWTYPE;
BEGIN
    INL_LOGGING_PVT.Log_BeginProc ( p_module_name => g_module_name,
                                    p_procedure_name => l_program_name) ;
    x_return_status := L_FND_RET_STS_SUCCESS;
    x_ch_line_tot_amt_func_curr := 0;
    FOR l_ch_lines_rec IN c_ch_lines
    LOOP
        l_debug_info := 'Check Foreign Currency for Charge Line';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_program_name,
            p_debug_info => l_debug_info) ;
        IF l_ch_lines_rec.currency_code <> p_functional_currency_code AND p_foreign_currency_flag = 'N' THEN
            FND_MESSAGE.SET_NAME ('INL', 'INL_ERR_CHK_FRGN_CUR') ;
            FND_MESSAGE.SET_TOKEN ('CLNUM', l_ch_lines_rec.charge_line_num) ;
            FND_MSG_PUB.ADD;
            -- INCLUDE A LINE IN INL_SHIP_HOLdS
            Handle_ShipError (
                p_ship_header_id => p_ship_header_id,
                p_ship_line_id => NULL,
                p_charge_line_id => l_ch_lines_rec.charge_line_id,
                p_table_name => 'INL_CHARGE_LINES',
                p_column_name => 'CURRENCY_CODE',
                p_column_value => l_ch_lines_rec.CURRENCY_CODE,
                p_error_message => SUBSTR (FND_MSG_PUB.Get (
                                                p_msg_index => FND_MSG_PUB.Count_Msg (),
                                                p_encoded => L_FND_FALSE), 1, 2000),
                p_error_message_name => 'INL_ERR_CHK_FRGN_CUR',
                p_token1_name => 'CLNUM',
                p_token1_value => l_ch_lines_rec.charge_line_num,
                p_token2_name => NULL,
                p_token2_value => NULL,
                p_token3_name => NULL,
                p_token3_value => NULL,
                p_token4_name => NULL,
                p_token4_value => NULL,
                p_token5_name => NULL,
                p_token5_value => NULL,
                p_token6_name => NULL,
                p_token6_value => NULL,
                x_return_status => l_return_status) ;
            -- If unexpected errors happen abort
            IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
        -- the flag l_ch_lines_rec.dflt_charge_amt_flag has been removed from table, and the original pkg
        -- fas been  changed without the if clause, this is a temporarily wrk proc that will replace the actual
        x_ch_line_tot_amt_func_curr := x_ch_line_tot_amt_func_curr + NVL (l_ch_lines_rec.ch_line_amt_func_curr, 0) ;
    END LOOP;
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
EXCEPTION
WHEN L_FND_EXC_ERROR THEN
    -- Standard Expected Error Logging
    INL_LOGGING_PVT.Log_ExpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    x_return_status := L_FND_RET_STS_ERROR;
WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg (
            p_pkg_name => g_pkg_name,
            p_procedure_name => l_program_name) ;
    END IF;
END Validate_ChargeLine;

-- Utility name   : Validate_SrcOperatingUnit
-- Type       : Private
-- Function   : Check whether the Operating Unit from LCM Shipment is
--              the same of the Operating Unit from PO.
-- Pre-reqs   : None
-- Parameters :
-- IN         :  p_ship_header_id IN NUMBER,
--               p_ship_line_id   IN NUMBER,
--               p_ship_line_num  IN NUMBER
--               x_return_status  IN OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Validate_SrcOperatingUnit(
    p_ship_header_id IN NUMBER,
    p_ship_line_id    IN NUMBER,
    p_ship_line_num   IN NUMBER,
    x_return_status   IN OUT NOCOPY VARCHAR2
) IS
  l_program_name VARCHAR2 (200) := 'Validate_SrcOperatingUnit';
  l_return_status VARCHAR2 (1) := L_FND_RET_STS_SUCCESS;
  l_lcm_org_id NUMBER;
  l_po_org_id NUMBER;
  l_lcm_org_name VARCHAR2(240);
  l_po_org_name VARCHAR2(240);
BEGIN
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name);
    SELECT ish.org_id LCM_ORG_ID,
           ph.org_id PO_ORG_ID
     INTO  l_lcm_org_id,
           l_po_org_id
     FROM  inl_ship_headers_all ish,
           inl_ship_lines_all isl,
           po_headers_all ph,
           po_line_locations_all pll
     WHERE isl.ship_header_id = ish.ship_header_id
       AND ph.po_header_id = pll.po_header_id
       AND pll.line_location_id = isl.ship_line_source_id
       AND isl.ship_line_src_type_code = 'PO'
       AND ish.ship_header_id = p_ship_header_id
       AND isl.ship_line_id = p_ship_line_id;
    -- The Operating Unit from LCM Shipment must not be
    -- different from the Operating Unit from PO.
    IF l_lcm_org_id <> l_po_org_id THEN
        -- Get LCM Op Unit Name
        SELECT NAME
          INTO l_lcm_org_name
          FROM hr_operating_units
         WHERE organization_id = l_lcm_org_id;
         -- Get PO Op Unit Name
         SELECT NAME
          INTO l_po_org_name
          FROM hr_operating_units
         WHERE organization_id = l_po_org_id;
        FND_MESSAGE.SET_NAME ('INL', 'INL_ERR_INVALID_SRC_OPUNIT') ;
        FND_MESSAGE.SET_TOKEN ('SHIPLN_NUM', p_ship_line_num) ;
        FND_MESSAGE.SET_TOKEN ('LCM_OPUNIT', l_lcm_org_name) ;
        FND_MESSAGE.SET_TOKEN ('PO_OPUNIT', l_po_org_name) ;
        FND_MSG_PUB.ADD;
        -- INCLUDE A LINE IN INL_SHIP_HOLdS
        Handle_ShipError (
            p_ship_header_id => p_ship_header_id,
            p_ship_line_id => p_ship_line_id,
            p_charge_line_id => NULL,
            p_table_name => 'INL_SHIP_HEADERS',
            p_column_name => 'ORG_ID',
            p_column_value => 0,
            p_error_message => SUBSTR (FND_MSG_PUB.Get (
                                            p_msg_index => FND_MSG_PUB.Count_Msg (),
                                            p_encoded => L_FND_FALSE), 1, 2000),
            p_error_message_name => 'INL_ERR_INVALID_SRC_OPUNIT',
            p_token1_name => 'SHIPLN_NUM',
            p_token1_value => p_ship_line_num,
            p_token2_name => 'LCM_OPUNIT',
            p_token2_value => l_lcm_org_name,
            p_token3_name => 'PO_OPUNIT',
            p_token3_value => l_po_org_name,
            p_token4_name => NULL,
            p_token4_value => NULL,
            p_token5_name => NULL,
            p_token5_value => NULL,
            p_token6_name => NULL,
            p_token6_value => NULL,
            x_return_status => l_return_status);
        -- If unexpected errors happen abort
        IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
          RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
EXCEPTION
WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level (p_message_level  => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg (
            p_pkg_name => g_pkg_name,
            p_procedure_name => l_program_name) ;
    END IF;
END Validate_SrcOperatingUnit;
-- Utility name   : Validate_ThirdPartySiteAllowed
-- Type       : Private
-- Function   : Check whether the Third Patry Site from LCM Shipment is
--              following the setup.
-- Pre-reqs   : None
-- Parameters :
-- IN         :  p_ship_header_id        IN NUMBER,
--               p_ship_type_id          IN NUMBER,
--               p_ship_type_code        IN VARCHAR2,
--               p_group_reference       IN VARCHAR2,
--               p_party_site_id         IN NUMBER,
--               p_taxation_country      IN VARCHAR2,
--               p_third_parties_allowed IN VARCHAR2,
--               x_return_status         IN OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Validate_ThirdPartySiteAllowed(
    p_ship_header_id        IN NUMBER,
    p_ship_type_code        IN VARCHAR2,
    p_group_reference       IN VARCHAR2,
    p_party_site_id         IN NUMBER,
    p_party_site_name       IN VARCHAR2,
    p_taxation_country      IN VARCHAR2,
    p_third_parties_allowed IN VARCHAR2,
    x_return_status         IN OUT NOCOPY VARCHAR2
) IS
  l_program_name VARCHAR2 (200) := 'Validate_ThirdPartyAllowed';
  l_return_status VARCHAR2 (1) := L_FND_RET_STS_SUCCESS;
  l_party_site_id NUMBER;
BEGIN
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_ship_type_code: ',
        p_var_value => p_ship_type_code);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_party_site_id: ',
        p_var_value => p_party_site_id);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_taxation_country: ',
        p_var_value => p_taxation_country);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_third_parties_allowed: ',
        p_var_value => p_third_parties_allowed);
    BEGIN
      SELECT hps.party_site_id
      INTO   l_party_site_id
      FROM   hz_party_sites   hps,
             hz_locations     hl
      WHERE hps.location_id = hl.location_id
      AND   hps.party_site_id = p_party_site_id
      AND  ((p_third_parties_allowed = 1
      AND   hl.country = p_taxation_country )
      OR   (p_third_parties_allowed = 2
      AND   hl.country <> p_taxation_country )
      OR   ( p_third_parties_allowed = 3 ));
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME ('INL', 'INL_ERR_3RD_PTY_ST_ALLOWED') ;
        FND_MESSAGE.SET_TOKEN ('GROUP_REF', p_group_reference) ;
        FND_MESSAGE.SET_TOKEN ('PARTY_SITE', p_party_site_name) ;
        FND_MESSAGE.SET_TOKEN ('SHIP_TYPE', p_ship_type_code) ;
        FND_MSG_PUB.ADD;
        -- INCLUDE A LINE IN INL_SHIP_HOLDS
        Handle_ShipError (
            p_ship_header_id => p_ship_header_id,
            p_ship_line_id => NULL,
            p_charge_line_id => NULL,
            p_table_name => 'INL_SHIP_LINE_GROUPS',
            p_column_name => 'PARTY_SITE_ID',
            p_column_value => p_party_site_id,
            p_error_message => SUBSTR (FND_MSG_PUB.Get (
                                        p_msg_index => FND_MSG_PUB.Count_Msg (),
                                        p_encoded => L_FND_FALSE), 1, 2000),
            p_error_message_name => 'INL_ERR_3RD_PTY_ST_ALLOWED',
            p_token1_name => 'GROUP_REF',
            p_token1_value => p_group_reference,
            p_token2_name => 'PARTY_SITE',
            p_token2_value => p_party_site_id,
            p_token3_name => 'SHIP_TYPE',
            p_token3_value => p_ship_type_code,
            p_token4_name => NULL,
            p_token4_value => NULL,
            p_token5_name => NULL,
            p_token5_value => NULL,
            p_token6_name => NULL,
            p_token6_value => NULL,
            x_return_status => l_return_status);
        -- If unexpected errors happen abort
        IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
          RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
    END;
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
EXCEPTION
WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level (p_message_level  => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg (
            p_pkg_name => g_pkg_name,
            p_procedure_name => l_program_name) ;
    END IF;
END Validate_ThirdPartySiteAllowed;

-- Utility name   : Validate_LineGroup
-- Type       : Private
-- Function   : Validate Line Group
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_header_id        IN NUMBER,
--              p_ship_type_code        IN VARCHAR2,
--              p_inv_org_id            IN NUMBER  -- Bug 15956572
--              p_ln_group_id           IN NUMBER,
--              p_ln_group_num          IN NUMBER, --Bug#13987019
--              p_group_reference       IN  VARCHAR2,
--              p_party_id              IN NUMBER, --Bug#13987019
--              p_party_site_id         IN NUMBER,
--              p_party_site_name       IN VARCHAR2,
--              p_taxation_country      IN VARCHAR2,
--              p_third_parties_allowed IN VARCHAR2,
--
-- OUT        : x_return_status                OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Validate_LineGroup(
    p_ship_header_id        IN NUMBER,
    p_ship_type_code        IN VARCHAR2,
    p_inv_org_id            IN NUMBER, -- Bug 15956572
    p_ln_group_id           IN NUMBER,
    p_ln_group_num          IN NUMBER, --Bug#13987019
    p_group_reference       IN VARCHAR2,
    p_party_id              IN NUMBER, --Bug#13987019
    p_party_site_id         IN NUMBER,
    p_party_site_name       IN VARCHAR2,
    p_taxation_country      IN VARCHAR2,
    p_third_parties_allowed IN VARCHAR2,
    x_return_status         OUT NOCOPY VARCHAR2
) IS
    l_program_name CONSTANT VARCHAR2 (30) := 'Validate_LineGroup';
    l_return_status VARCHAR2 (1)  := L_FND_RET_STS_SUCCESS;
    l_debug_info VARCHAR2 (200);
    l_pre_receive VARCHAR2 (1) ; -- Bug 15956572

    --Bug#13987019 beg
    CURSOR c_sl_parties is
    SELECT
        ph.vendor_id,
        ph.vendor_site_id,
        pv.party_id,
        pvs.party_site_id,
        hps.party_site_name,
        pv.vendor_name,
        pvs.vendor_site_code,
        COUNT(*) how_many,
        MAX(sl.ship_line_num) max_ship_line_num
    FROM
        inl_ship_lines_all sl,
        po_headers_all ph,
        po_line_locations_all pll,
        po_vendors pv,
        po_vendor_sites_all pvs,
        hz_party_sites hps
    WHERE
        ph.po_header_id = pll.po_header_id
    AND hps.party_site_id = pvs.party_site_id
    AND pll.line_location_id = sl.ship_line_source_id
    AND pv.vendor_id = ph.vendor_id
    AND pvs.vendor_site_id = ph.vendor_site_id
    AND sl.ship_header_id = p_ship_header_id
    AND sl.ship_line_group_id  = p_ln_group_id
    GROUP BY
        ph.vendor_id,
        ph.vendor_site_id,
        pv.party_id,
        pvs.party_site_id,
        hps.party_site_name,
        pv.vendor_name,
        pvs.vendor_site_code
    ORDER BY 1,2
    ;
    TYPE sl_parties_Tp
    IS
        TABLE OF c_sl_parties%ROWTYPE;
    l_sl_parties_lst sl_parties_Tp;

    CURSOR c_sl_num (pc_party_site_id NUMBER) is
    SELECT
        sl.ship_line_num
    FROM
        inl_ship_lines_all sl,
        po_headers_all ph,
        po_line_locations_all pll,
        po_vendors pv,
        po_vendor_sites_all pvs,
        hz_party_sites hps
    WHERE
        ph.po_header_id = pll.po_header_id
    AND hps.party_site_id = pvs.party_site_id
    AND pll.line_location_id = sl.ship_line_source_id
    AND pv.vendor_id = ph.vendor_id
    AND pvs.vendor_site_id = ph.vendor_site_id
    AND sl.ship_header_id = p_ship_header_id
    AND sl.ship_line_group_id  = p_ln_group_id
    AND pvs.party_site_id = pc_party_site_id
    ORDER BY 1
    ;
    TYPE sl_num_Tp
    IS
        TABLE OF c_sl_num%ROWTYPE;
    l_sl_num_lst sl_num_Tp;

    l_vendor_record rcv_shipment_header_sv.vendorrectype;
    l_vendor_site_record rcv_shipment_header_sv.VendorSiteRecType;
    l_prev_party_id NUMBER;
    l_msg VARCHAR2(30);
    l_ln_num VARCHAR2(200);
    --Bug#13987019 end
BEGIN
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name     => g_module_name,
        p_procedure_name  => l_program_name) ;
    x_return_status := L_FND_RET_STS_SUCCESS;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_ship_type_code',
        p_var_value => p_ship_type_code);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_ln_group_num',
        p_var_value => p_ln_group_num);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_ln_group_id',
        p_var_value => p_ln_group_id);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_group_reference',
        p_var_value => p_group_reference);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_party_id',
        p_var_value => p_party_id);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_party_site_id',
        p_var_value => p_party_site_id);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_party_site_name',
        p_var_value => p_party_site_name);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_taxation_country',
        p_var_value => p_taxation_country);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_third_parties_allowed',
        p_var_value => p_third_parties_allowed);

    -- Bug 15956572
    -- Just validate Third Party Allowed for Pre-Receiving Organizations
    SELECT pre_receive
      INTO l_pre_receive
      FROM rcv_parameters
     WHERE organization_id = p_inv_org_id;
    -- /Bug 15956572

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'l_pre_receive',
        p_var_value => l_pre_receive);

    IF (NVL (l_pre_receive, 'N') = 'Y') THEN  -- Bug 15956572
        l_debug_info := 'Validate Third Party Allowed. Call Validate_ThirdPartyAllowed (Group)';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name     => g_module_name,
            p_procedure_name  => l_program_name,
            p_debug_info      => l_debug_info) ;
        Validate_ThirdPartySiteAllowed(
            p_ship_header_id        => p_ship_header_id,
            p_ship_type_code        => p_ship_type_code,
            p_group_reference       => p_group_reference,
            p_party_site_id         => p_party_site_id,
            p_party_site_name       => p_party_site_name,
            p_taxation_country      => p_taxation_country,
            p_third_parties_allowed => p_third_parties_allowed,
            x_return_status         => l_return_status);
        -- If unexpected errors happen abort API
        IF l_return_status   = L_FND_RET_STS_ERROR THEN
          x_return_status := l_return_status;
          RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
          x_return_status  := l_return_status;
          RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF; -- Bug 15956572

--Bug#13987019 BEG
    --Verifying the party and vendor of all lines (PO)
    INL_LOGGING_PVT.Log_Statement (
        p_module_name     => g_module_name,
        p_procedure_name  => l_program_name,
        p_debug_info      => 'Verifying the party and vendor of all lines (PO)') ;

    OPEN c_sl_parties;
    FETCH c_sl_parties BULK COLLECT INTO l_sl_parties_lst;
    CLOSE c_sl_parties;
    l_debug_info := l_sl_parties_lst.LAST||' lines have been retrieved.';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_debug_info => l_debug_info
    ) ;
    IF NVL (l_sl_parties_lst.LAST, 0) > 0 THEN
        FOR i IN NVL (l_sl_parties_lst.FIRST, 0) ..NVL (l_sl_parties_lst.LAST, 0)
        LOOP
            INL_LOGGING_PVT.Log_Variable (
                p_module_name => g_module_name,
                p_procedure_name => l_program_name,
                p_var_name => 'l_sl_parties_lst(i)',
                p_var_value => i);
            IF l_sl_parties_lst(i).party_id <> p_party_id THEN
                IF l_sl_parties_lst(i).party_id <> NVL(l_prev_party_id,-1)
                THEN
                    l_prev_party_id:= l_sl_parties_lst(i).party_id;
                    FND_MESSAGE.SET_NAME ('INL', 'INL_ERR_CHK_VEN_INV') ;
                    FND_MESSAGE.SET_TOKEN ('P_LN_GROUP_NUM', p_ln_group_num) ;
                    FND_MESSAGE.SET_TOKEN ('P_VENDOR_NAME', l_sl_parties_lst(i).vendor_name) ;
                    FND_MSG_PUB.ADD;

                    Handle_ShipError (
                        p_ship_header_id   => p_ship_header_id,
                        p_ship_line_id     => NULL,
                        p_charge_line_id   => NULL,
                        p_table_name       => 'INL_SHIP_LINE_GROUPS',
                        p_column_name      => 'PARTY_ID',
                        p_column_value     => p_party_id,
                        p_error_message    => SUBSTR (FND_MSG_PUB.Get (
                                                    p_msg_index => FND_MSG_PUB.Count_Msg (),
                                                    p_encoded => L_FND_FALSE), 1, 2000),
                        p_error_message_name => 'INL_ERR_CHK_VEN_INV',
                        p_token1_name      => 'P_LN_GROUP_NUM',
                        p_token1_value     => p_ln_group_num,
                        p_token2_name      => 'P_VENDOR_NAME',
                        p_token2_value     => l_sl_parties_lst(i).vendor_name,
                        p_token3_name      => NULL,
                        p_token3_value     => NULL,
                        p_token4_name      => NULL,
                        p_token4_value     => NULL,
                        p_token5_name      => NULL,
                        p_token5_value     => NULL,
                        p_token6_name      => NULL,
                        p_token6_value     => NULL,
                        x_return_status    => l_return_status);
                    -- If unexpected errors happen abort
                    IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
                      RAISE L_FND_EXC_UNEXPECTED_ERROR;
                    END IF;
                END IF;
            ELSE
                IF l_sl_parties_lst(i).party_id <> NVL(l_prev_party_id,-1)
                THEN
                    l_prev_party_id:= l_sl_parties_lst(i).party_id;
-- Based on rcv_roi_header.validate_vendor_info  CHECKING VENDOR  BEG
                    INL_LOGGING_PVT.Log_Statement (
                        p_module_name     => g_module_name,
                        p_procedure_name  => l_program_name,
                        p_debug_info      => 'Checking Vendor: '||l_sl_parties_lst(i).vendor_name) ;

                    IF  l_sl_parties_lst(i).vendor_name  IS NULL
                    AND l_sl_parties_lst(i).vendor_id    IS NULL
                    THEN
                        l_vendor_record.error_record.error_status   := 'E';
                        l_vendor_record.error_record.error_message  := 'TBD';

                        INL_LOGGING_PVT.Log_Statement (
                            p_module_name     => g_module_name,
                            p_procedure_name  => l_program_name,
                            p_debug_info      => 'Vendor ID and Vendor Name is null') ;

                    ELSE
                        l_vendor_record.vendor_name                   := l_sl_parties_lst(i).vendor_name;
                        l_vendor_record.vendor_num                    := NULL;
                        l_vendor_record.vendor_id                     := l_sl_parties_lst(i).vendor_id;
                        l_vendor_record.error_record.error_status     := NULL;
                        l_vendor_record.error_record.error_message    := NULL;

                        INL_LOGGING_PVT.Log_Variable (
                            p_module_name => g_module_name,
                            p_procedure_name => l_program_name,
                            p_var_name => 'l_vendor_record.vendor_name',
                            p_var_value => l_vendor_record.vendor_name);

                        INL_LOGGING_PVT.Log_Variable (
                            p_module_name => g_module_name,
                            p_procedure_name => l_program_name,
                            p_var_name => 'l_vendor_record.vendor_id',
                            p_var_value => l_vendor_record.vendor_id);

                        INL_LOGGING_PVT.Log_Statement (
                            p_module_name     => g_module_name,
                            p_procedure_name  => l_program_name,
                            p_debug_info      => 'Calling po_vendors_sv.validate_vendor_info') ;

                        po_vendors_sv.validate_vendor_info(l_vendor_record);

                        INL_LOGGING_PVT.Log_Variable (
                            p_module_name => g_module_name,
                            p_procedure_name => l_program_name,
                            p_var_name => 'l_vendor_record.error_record.error_status',
                            p_var_value => l_vendor_record.error_record.error_status);

                        INL_LOGGING_PVT.Log_Variable (
                            p_module_name => g_module_name,
                            p_procedure_name => l_program_name,
                            p_var_name => 'l_vendor_record.error_record.error_message',
                            p_var_value => l_vendor_record.error_record.error_message);

                    END IF;
                    IF l_vendor_record.error_record.error_status = 'E' THEN
                        IF l_vendor_record.error_record.error_message = 'VEN_DISABLED' THEN
                            l_msg:= 'INL_ERR_CHK_VEN_DIS';
                        ELSIF l_vendor_record.error_record.error_message = 'VEN_HOLD' THEN
                            l_msg:= 'INL_ERR_CHK_VEN_HLD';
                        ELSE -- 'VEN_ID','TOOMANYROWS'
                            l_msg:= 'INL_ERR_CHK_VEN_INV';
                        END IF;
                        INL_LOGGING_PVT.Log_Variable (
                            p_module_name => g_module_name,
                            p_procedure_name => l_program_name,
                            p_var_name => 'l_msg',
                            p_var_value => l_msg);

                        FND_MESSAGE.SET_NAME ('INL', l_msg) ;
                        FND_MESSAGE.SET_TOKEN ('P_LN_GROUP_NUM', p_ln_group_num) ;
                        FND_MESSAGE.SET_TOKEN ('P_VENDOR_NAME', l_sl_parties_lst(i).vendor_name) ;
                        FND_MSG_PUB.ADD;

                        Handle_ShipError (
                            p_ship_header_id   => p_ship_header_id,
                            p_ship_line_id     => NULL,
                            p_charge_line_id   => NULL,
                            p_table_name       => 'INL_SHIP_LINE_GROUPS',
                            p_column_name      => 'PARTY_ID',
                            p_column_value     => p_party_id,
                            p_error_message    => SUBSTR (FND_MSG_PUB.Get (
                                                        p_msg_index => FND_MSG_PUB.Count_Msg (),
                                                        p_encoded => L_FND_FALSE), 1, 2000),
                            p_error_message_name => l_msg,
                            p_token1_name      => 'P_LN_GROUP_NUM',
                            p_token1_value     => p_ln_group_num,
                            p_token2_name      => 'P_VENDOR_NAME',
                            p_token2_value     => l_sl_parties_lst(i).vendor_name,
                            p_token3_name      => NULL,
                            p_token3_value     => NULL,
                            p_token4_name      => NULL,
                            p_token4_value     => NULL,
                            p_token5_name      => NULL,
                            p_token5_value     => NULL,
                            p_token6_name      => NULL,
                            p_token6_value     => NULL,
                            x_return_status    => l_return_status);
                        -- If unexpected errors happen abort
                        IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
                          RAISE L_FND_EXC_UNEXPECTED_ERROR;
                        END IF;
                    END IF;
                END IF;
-- Based on rcv_roi_header.validate_vendor_info END
-- Based on rcv_roi_header.validate_vendor_site_info:  checking vendor site  BEG

                INL_LOGGING_PVT.Log_Statement (
                    p_module_name     => g_module_name,
                    p_procedure_name  => l_program_name,
                    p_debug_info      => 'Checking Vendor Site: '||l_sl_parties_lst(i).vendor_site_code) ;

                IF l_sl_parties_lst(i).party_site_id <> p_party_site_id THEN
                    l_debug_info := 'Validate Third Party Allowed (PO). Call Validate_ThirdPartyAllowed:'||l_sl_parties_lst(i).party_site_name;
                    INL_LOGGING_PVT.Log_Statement (
                        p_module_name     => g_module_name,
                        p_procedure_name  => l_program_name,
                        p_debug_info      => l_debug_info) ;
                    Validate_ThirdPartySiteAllowed(
                        p_ship_header_id        => p_ship_header_id,
                        p_ship_type_code        => p_ship_type_code,
                        p_group_reference       => p_group_reference,
                        p_party_site_id         => l_sl_parties_lst(i).party_site_id,
                        p_party_site_name       => l_sl_parties_lst(i).party_site_name,
                        p_taxation_country      => p_taxation_country,
                        p_third_parties_allowed => p_third_parties_allowed,
                        x_return_status         => l_return_status);
                    -- If unexpected errors happen abort API
                    IF l_return_status   = L_FND_RET_STS_ERROR THEN
                      x_return_status := l_return_status;
                      RAISE L_FND_EXC_ERROR;
                    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                      x_return_status  := l_return_status;
                      RAISE L_FND_EXC_UNEXPECTED_ERROR;
                    END IF;
                END IF;

                l_vendor_site_record.vendor_site_code            := NULL;
                l_vendor_site_record.vendor_id                   := l_sl_parties_lst(i).vendor_id;
                l_vendor_site_record.vendor_site_id              := l_sl_parties_lst(i).vendor_site_id;
                l_vendor_site_record.organization_id             := NULL;
                l_vendor_site_record.error_record.error_status   := NULL;
                l_vendor_site_record.error_record.error_message  := NULL;

                INL_LOGGING_PVT.Log_Variable (
                    p_module_name => g_module_name,
                    p_procedure_name => l_program_name,
                    p_var_name => 'l_vendor_site_record.vendor_site_id',
                    p_var_value => l_vendor_site_record.vendor_site_id);

                INL_LOGGING_PVT.Log_Statement (
                    p_module_name     => g_module_name,
                    p_procedure_name  => l_program_name,
                    p_debug_info      => 'Calling po_vendor_sites_sv.validate_vendor_site_info') ;

                po_vendor_sites_sv.validate_vendor_site_info(l_vendor_site_record);

                INL_LOGGING_PVT.Log_Variable (
                    p_module_name => g_module_name,
                    p_procedure_name => l_program_name,
                    p_var_name => 'l_vendor_site_record.error_record.error_status',
                    p_var_value => l_vendor_site_record.error_record.error_status);

                INL_LOGGING_PVT.Log_Variable (
                    p_module_name => g_module_name,
                    p_procedure_name => l_program_name,
                    p_var_name => 'l_vendor_site_record.error_record.error_message',
                    p_var_value => l_vendor_site_record.error_record.error_message);

                IF l_vendor_site_record.error_record.error_status = 'E'
                THEN

                    IF l_vendor_site_record.error_record.error_message = 'VEN_SITE_HOLD_PMT' THEN
                        NULL;
                    ELSIF l_vendor_site_record.error_record.error_message = 'VEN_SITE_NOT_POR_SITE' THEN
                        NULL;
                    ELSIF l_vendor_site_record.error_record.error_message = 'VEN_SITE_ID' THEN
                        NULL;
                    ELSE
                        IF l_vendor_site_record.error_record.error_message = 'VEN_SITE_DISABLED' THEN
                            l_msg:= 'INL_ERR_CHK_VEN_SITE_DIS';
                        ELSIF l_vendor_site_record.error_record.error_message = 'VEN_SITE_NOT_PURCH' THEN
                            l_msg:= 'INL_ERR_CHK_VEN_SITE_NP';
                        ELSE
                            l_msg:= 'INL_ERR_CHK_VEN_SITE_INV';
                        END IF;
                        INL_LOGGING_PVT.Log_Variable (
                            p_module_name => g_module_name,
                            p_procedure_name => l_program_name,
                            p_var_name => 'l_msg',
                            p_var_value => l_msg);

                        IF l_sl_parties_lst(i).how_many = 1 THEN
                            l_ln_num:= l_sl_parties_lst(i).max_ship_line_num;
                        ELSIF l_sl_parties_lst(i).how_many > 1 THEN
                            --Getting the affected lines
                            INL_LOGGING_PVT.Log_Statement (
                                p_module_name     => g_module_name,
                                p_procedure_name  => l_program_name,
                                p_debug_info      => 'Getting the affected lines') ;

                            l_ln_num:=NULL;
                            OPEN c_sl_num (l_sl_parties_lst(i).party_site_id);
                            FETCH c_sl_num BULK COLLECT INTO l_sl_num_lst;
                            CLOSE c_sl_num;
                            l_debug_info := l_sl_num_lst.LAST||' lines have been retrieved.';
                            INL_LOGGING_PVT.Log_Statement (
                                p_module_name => g_module_name,
                                p_procedure_name => l_program_name,
                                p_debug_info => l_debug_info
                            ) ;
                            IF NVL (l_sl_num_lst.LAST, 0) > 0 THEN
                                FOR j IN NVL (l_sl_num_lst.FIRST, 0) ..NVL (l_sl_num_lst.LAST, 0)
                                LOOP
                                    IF NVL(LENGTH(l_ln_num),0)+NVL(LENGTH(l_sl_num_lst(j).ship_line_num),0) < 200 THEN
                                        l_ln_num:=l_ln_num||l_sl_num_lst(j).ship_line_num||',';
                                    ELSE
                                        EXIT;
                                    END IF;
                                END LOOP;
                                IF LENGTH(l_ln_num)>2 THEN
                                    l_ln_num:=SUBSTR(l_ln_num,1,LENGTH(l_ln_num)-1);
                                END IF;
                                INL_LOGGING_PVT.Log_Variable (
                                    p_module_name => g_module_name,
                                    p_procedure_name => l_program_name,
                                    p_var_name => 'l_ln_num',
                                    p_var_value => l_ln_num);

                            END IF;
                        ELSE
                          l_ln_num:=NULL;
                        END IF;
                        FND_MESSAGE.SET_NAME ('INL', l_msg) ;
                        FND_MESSAGE.SET_TOKEN ('P_LN_GROUP_NUM', p_ln_group_num) ;
                        FND_MESSAGE.SET_TOKEN ('P_VENDOR_SITE_CODE', l_sl_parties_lst(i).vendor_site_code) ;
                        FND_MESSAGE.SET_TOKEN ('P_LINES', l_ln_num) ;
                        FND_MSG_PUB.ADD;
                        Handle_ShipError (
                            p_ship_header_id   => p_ship_header_id,
                            p_ship_line_id     => NULL,
                            p_charge_line_id   => NULL,
                            p_table_name       => 'INL_SHIP_LINE_GROUPS',
                            p_column_name      => 'PARTY_SITE_ID',
                            p_column_value     => p_party_site_id,
                            p_error_message    => SUBSTR (FND_MSG_PUB.Get (
                                                        p_msg_index => FND_MSG_PUB.Count_Msg (),
                                                        p_encoded => L_FND_FALSE), 1, 2000),
                            p_error_message_name => l_msg,
                            p_token1_name      => 'P_LN_GROUP_NUM',
                            p_token1_value     => p_ln_group_num,
                            p_token2_name      => 'P_VENDOR_SITE_CODE',
                            p_token2_value     => l_sl_parties_lst(i).vendor_site_code,
                            p_token3_name      => 'P_LINES',
                            p_token3_value     => l_ln_num,
                            p_token4_name      => NULL,
                            p_token4_value     => NULL,
                            p_token5_name      => NULL,
                            p_token5_value     => NULL,
                            p_token6_name      => NULL,
                            p_token6_value     => NULL,
                            x_return_status    => l_return_status);

                            -- If unexpected errors happen abort
                            IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
                              RAISE L_FND_EXC_UNEXPECTED_ERROR;
                            END IF;

                       END IF;
                END IF;
  -- Based on rcv_roi_header.validate_vendor_site_info:  checking vendor site  END

            END IF;
        END LOOP;
    END IF;
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name) ;
--Bug#13987019 END
EXCEPTION
WHEN L_FND_EXC_ERROR THEN
    -- Standard Expected Error Logging
    INL_LOGGING_PVT.Log_ExpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    x_return_status := L_FND_RET_STS_ERROR;
WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    x_return_status  := L_FND_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level (p_message_level  => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg (
            p_pkg_name => g_pkg_name,
            p_procedure_name => l_program_name) ;
    END IF;
END Validate_LineGroup;

-- Bug #8928896
-- Utility name   : Validate_AllocEnabledFlag
-- Type       : Private
-- Function   : Check if exists associations for the Ship Line Type for which
--              Associable flag is disabled.
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_header_id      IN NUMBER
--              p_alloc_enabled_flag  IN VARCHAR2
--              p_ship_line_type_code IN VARCHAR2
--              p_ship_line_id        IN NUMBER
--              p_ship_line_num       IN NUMBER
-- OUT        : x_return_status       OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :

PROCEDURE Validate_AllocEnabledFlag(
    p_ship_header_id      IN NUMBER,
    p_alloc_enabled_flag  IN VARCHAR2,
    p_ship_line_type_code IN VARCHAR2,
    p_ship_line_id        IN NUMBER,
    p_ship_line_num       IN NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2
)IS

    l_program_name          VARCHAR2 (200) := 'Validate_AllocEnabledFlag';
    l_count_associations NUMBER;
    l_debug_info         VARCHAR2 (400);
    l_return_status      VARCHAR2 (1) := L_FND_RET_STS_SUCCESS;

BEGIN

    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name => g_module_name,
        p_procedure_name => l_program_name);

    x_return_status := L_FND_RET_STS_SUCCESS;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_ship_header_id',
        p_var_value => p_ship_header_id);

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_ship_line_type_code',
        p_var_value => p_ship_line_type_code) ;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_ship_line_id',
        p_var_value => p_ship_line_id) ;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_alloc_enabled_flag',
        p_var_value => p_alloc_enabled_flag) ;

    IF p_alloc_enabled_flag = 'N' THEN
        -- Check if ship lines is associable to other line
        SELECT NVL(COUNT(1),0)
        INTO  l_count_associations
        FROM inl_associations ia
        WHERE ship_header_id = p_ship_header_id
        AND  ia.from_parent_table_name = 'INL_SHIP_LINES'
        AND  ia.from_parent_table_id = p_ship_line_id;

        INL_LOGGING_PVT.Log_Variable (
            p_module_name => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name => 'l_count_associations',
            p_var_value => l_count_associations) ;

        IF l_count_associations > 0 THEN
            FND_MESSAGE.SET_NAME ('INL', 'INL_ERR_ASSOC_ALLOC_FLAG_DISAB') ;
            FND_MESSAGE.SET_TOKEN ('SHIPLN_NUM', p_ship_line_num) ;
            FND_MESSAGE.SET_TOKEN ('SHIPLN_TYPE', p_ship_line_type_code) ;
            FND_MSG_PUB.ADD;
            -- INCLUDE A LINE IN INL_SHIP_HOLDS
            Handle_ShipError (
                p_ship_header_id => p_ship_header_id,
                p_ship_line_id => p_ship_line_id,
                p_charge_line_id => NULL,
                p_table_name => 'INL_SHIP_LINES',
                p_column_name => 'SHIP_LINE_TYPE_ID',
                p_column_value => 0,
                p_error_message => SUBSTR (FND_MSG_PUB.Get (
                                                p_msg_index => FND_MSG_PUB.Count_Msg (),
                                                p_encoded => L_FND_FALSE), 1, 2000),
                p_error_message_name => 'INL_ERR_ASSOC_ALLOC_FLAG_DISAB',
                p_token1_name => 'SHIPLN_NUM',
                p_token1_value => p_ship_line_num,
                p_token2_name => 'SHIPLN_TYPE',
                p_token2_value => p_ship_line_type_code,
                p_token3_name => NULL,
                p_token3_value => NULL,
                p_token4_name => NULL,
                p_token4_value => NULL,
                p_token5_name => NULL,
                p_token5_value => NULL,
                p_token6_name => NULL,
                p_token6_value => NULL,
                x_return_status => l_return_status);
        END IF;
    END IF;

    INL_LOGGING_PVT.Log_EndProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
EXCEPTION
WHEN L_FND_EXC_ERROR THEN
    x_return_status := L_FND_RET_STS_ERROR;
WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
WHEN OTHERS THEN
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg (
            p_pkg_name => g_pkg_name,
            p_procedure_name => l_program_name) ;
    END IF;
END Validate_AllocEnabledFlag;

-- Utility name   : Validate_ShipLine
-- Type       : Private
-- Function   : Validate Shipment Line
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_header_id               IN  NUMBER
--              p_rcv_enabled_flag             IN VARCHAR2
--              p_ln_group_id                  IN  NUMBER
--              p_functional_currency_code     IN  VARCHAR2
--              p_foreign_currency_flag        IN  VARCHAR2
--              p_organization_id              IN  NUMBER
--              p_country_code_location        IN  VARCHAR2
--              p_third_parties_allowed        IN  VARCHAR2
--
-- OUT        : x_return_status                OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Validate_ShipLine (
    p_ship_header_id           IN NUMBER,
    p_rcv_enabled_flag         IN VARCHAR2,
    p_ln_group_id              IN NUMBER,
    p_functional_currency_code IN VARCHAR2,
    p_foreign_currency_flag    IN VARCHAR2,
    p_organization_id          IN NUMBER,
    p_country_code_location    IN VARCHAR2,
    p_third_parties_allowed    IN VARCHAR2,
    x_return_status            OUT NOCOPY VARCHAR2
) IS
    l_program_name  CONSTANT    VARCHAR2 (30) := 'Validate_ShipLine';
    l_return_status             VARCHAR2 (1)  := L_FND_RET_STS_SUCCESS;
    l_debug_info                VARCHAR2 (200);


    l_ch_line_tot_amt_func_curr NUMBER;
    l_pre_receive               VARCHAR2 (1) ;
    l_return_validation_status  VARCHAR2(30); -- SCM-051

    -- Bug 13401780
    l_closed_code              VARCHAR2(20);
    l_ship_line_num            VARCHAR2(20);
    l_ship_ln_grp_num          VARCHAR2(20) ;
    -- Bug 13401780

    CURSOR c_ship_lines IS
        -- Bug 9814099 (Removed unecessary join with inl_ship_line_types_b)
        SELECT ol.ship_line_id,
            ol.ship_line_num,
            ol.ship_line_src_type_code,
            ol.ship_line_source_id,
            ol.inventory_item_id,
            (SELECT SUM (a.primary_qty)
             FROM inl_adj_ship_lines_v a
             WHERE a.ship_header_id = ol.ship_header_id
             AND a.ship_line_source_id = ol.ship_line_source_id) AS sum_primary_qty,
            ol.primary_qty,
            ol.primary_unit_price,
            ol.primary_uom_code,
            ol.txn_uom_code,
            ol.currency_code,
            ol.currency_conversion_type,
            ol.currency_conversion_date,
            ol.currency_conversion_rate,
            'INL_SHIP_LINES' to_parent_table_name
      FROM inl_adj_ship_lines_v ol
      WHERE ol.ship_header_id = p_ship_header_id
      AND ol.ship_line_group_id = p_ln_group_id
      ORDER BY ol.ship_line_num;
    l_ship_lines_rec c_ship_lines%ROWTYPE;
BEGIN
    INL_LOGGING_PVT.Log_BeginProc ( p_module_name => g_module_name,
                                    p_procedure_name => l_program_name) ;
    x_return_status := L_FND_RET_STS_SUCCESS;
    FOR l_ship_lines_rec IN c_ship_lines
    LOOP
        l_debug_info := 'Validate Charge Line. Call Validate_ChargeLine';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_program_name,
            p_debug_info => l_debug_info) ;
        Validate_ChargeLine (
            p_ship_header_id            => p_ship_header_id,
            p_to_parent_table_name      => l_ship_lines_rec.to_parent_table_name,
            p_to_parent_table_id        => l_ship_lines_rec.ship_line_id,
            p_functional_currency_code  => p_functional_currency_code,
            p_foreign_currency_flag     => p_foreign_currency_flag,
            p_third_parties_allowed     => p_third_parties_allowed,
            x_ch_line_tot_amt_func_curr => l_ch_line_tot_amt_func_curr,
            x_return_status             => l_return_status);
        -- If unexpected errors happen abort API
        IF l_return_status   = L_FND_RET_STS_ERROR THEN
            x_return_status := l_return_status;
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            x_return_status  := l_return_status;
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
        l_debug_info := 'Getting which scenartio is setup in RCV Parameters. Pre_Receive or BlackBox';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_program_name,
            p_debug_info => l_debug_info) ;
        SELECT pre_receive
        INTO l_pre_receive
        FROM rcv_parameters
        WHERE organization_id = p_organization_id;

        -- Bug 13401780 starts here - Added code to validate if the PO line is CLOSED FOR RECEIVING or NOT

        INL_LOGGING_PVT.Log_Variable (
                    p_module_name => g_module_name,
                    p_procedure_name => l_program_name,
                    p_var_name => 'Profile Option - RCV_CLOSED_PO_DEFAULT_OPTION',
                    p_var_value => FND_PROFILE.VALUE('RCV_CLOSED_PO_DEFAULT_OPTION')) ;

        SELECT DECODE(FND_PROFILE.VALUE('RCV_CLOSED_PO_DEFAULT_OPTION'),'N',NVL(pll.closed_code,'OPEN'), 'OPEN')
        INTO l_closed_code
        FROM po_line_locations pll
        WHERE pll.line_location_id= l_ship_lines_rec.ship_line_source_id;

        INL_LOGGING_PVT.Log_Variable (
                    p_module_name => g_module_name,
                    p_procedure_name => l_program_name,
                    p_var_name => 'l_closed_code',
                    p_var_value => l_closed_code) ;

        IF l_closed_code <> 'OPEN' THEN

            SELECT isl.ship_line_num, islg.ship_line_group_num
            INTO   l_ship_line_num,l_ship_ln_grp_num
            FROM   inl_ship_lines isl,
                   inl_ship_line_groups islg
            WHERE  isl.ship_line_group_id=islg.ship_line_group_id
              AND  isl.ship_line_id = l_ship_lines_rec.ship_line_id
              AND  isl.ship_header_id = p_ship_header_id;

            INL_LOGGING_PVT.Log_Variable (
                        p_module_name => g_module_name,
                        p_procedure_name => l_program_name,
                        p_var_name => 'l_ship_line_num',
                        p_var_value => l_ship_line_num) ;

            INL_LOGGING_PVT.Log_Variable (
                        p_module_name => g_module_name,
                        p_procedure_name => l_program_name,
                        p_var_name => 'l_ship_ln_grp_num',
                        p_var_value => l_ship_ln_grp_num) ;

            FND_MESSAGE.SET_NAME ('INL', 'INL_ERR_CHK_LOC_CLOSE_CODE') ;
            FND_MESSAGE.SET_TOKEN ('LNGRP_NUM', l_ship_ln_grp_num) ;
            FND_MESSAGE.SET_TOKEN ('SHIPLN_NUM', l_ship_line_num) ;
            FND_MSG_PUB.ADD;
            l_debug_info := 'Line Location is not in OPEN status';

            INL_LOGGING_PVT.Log_Statement (
                p_module_name => g_pkg_name,
                p_procedure_name => l_program_name,
                p_debug_info => l_debug_info) ;
            INL_LOGGING_PVT.Log_Variable (
                p_module_name  => g_module_name,
                p_procedure_name => l_program_name,
                p_var_name => 'l_ship_lines_rec.ship_line_source_id',
                p_var_value => l_ship_lines_rec.ship_line_source_id) ;
            -- INCLUDE A LINE IN INL_SHIP_HOLdS
            Handle_ShipError (
                p_ship_header_id => p_ship_header_id,
                p_ship_line_id => NULL,
                p_charge_line_id => NULL,
                p_table_name => 'INL_SHIP_LINES',
                p_column_name => 'SHIP_LINE_SOURCE_ID',
                p_column_value => l_ship_lines_rec.ship_line_source_id,
                p_error_message => SUBSTR (FND_MSG_PUB.Get (
                                                p_msg_index => FND_MSG_PUB.Count_Msg (),
                                                p_encoded => L_FND_FALSE), 1, 2000),
                p_error_message_name => 'INL_ERR_CHK_LOC_CLOSE_CODE',
                p_token1_name => 'LNGRP_NUM',
                p_token1_value => l_ship_ln_grp_num,
                p_token2_name => 'SHIPLN_NUM',
                p_token2_value => l_ship_line_num,
                p_token3_name => NULL,
                p_token3_value => NULL,
                p_token4_name => NULL,
                p_token4_value => NULL,
                p_token5_name => NULL,
                p_token5_value => NULL,
                p_token6_name => NULL,
                p_token6_value => NULL,
                x_return_status => l_return_status) ;
            -- If unexpected errors happen abort
            IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        -- Bug 13401780 ends

        -- Just validate PO Available Qty for Pre-Receive scenario
        -- In Blackbox, RCV handles this validation
        IF (NVL (l_pre_receive, 'N') = 'Y') THEN
            IF p_rcv_enabled_flag = 'Y' THEN
                l_debug_info := 'Call to Check_AvailableQty';
                INL_LOGGING_PVT.Log_Statement (
                    p_module_name => g_module_name,
                    p_procedure_name => l_program_name,
                    p_debug_info => l_debug_info) ;
                Check_AvailableQty (
                    l_ship_lines_rec.primary_qty,
                    l_ship_lines_rec.sum_primary_qty,
                    l_ship_lines_rec.primary_uom_code,
                    l_ship_lines_rec.txn_uom_code,
                    l_ship_lines_rec.inventory_item_id,
                    p_organization_id,
                    l_ship_lines_rec.ship_line_id,
                    l_ship_lines_rec.ship_line_num,
                    l_ship_lines_rec.ship_line_src_type_code,
                    l_ship_lines_rec.ship_line_source_id,
                    NULL,
                    p_ship_header_id,
                    l_return_status) ;
               -- If unexpected errors happen abort API
                IF l_return_status   = L_FND_RET_STS_ERROR THEN
                    x_return_status := l_return_status;
                    RAISE L_FND_EXC_ERROR;
                ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                    x_return_status  := l_return_status;
                    RAISE L_FND_EXC_UNEXPECTED_ERROR;
                END IF;
            END IF;

            IF l_ship_lines_rec.ship_line_src_type_code = 'PO' THEN

                l_debug_info := 'Call to Validate_SrcOperatingUnit';
                INL_LOGGING_PVT.Log_Statement (
                    p_module_name => g_module_name,
                    p_procedure_name => l_program_name,
                    p_debug_info => l_debug_info) ;
                Validate_SrcOperatingUnit(
                    p_ship_header_id => p_ship_header_id,
                    p_ship_line_id   => l_ship_lines_rec.ship_line_id,
                    p_ship_line_num  => l_ship_lines_rec.ship_line_num,
                    x_return_status  => l_return_status);
                -- If unexpected errors happen abort API
                IF l_return_status   = L_FND_RET_STS_ERROR THEN
                    x_return_status := l_return_status;
                    RAISE L_FND_EXC_ERROR;
                ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                    x_return_status  := l_return_status;
                    RAISE L_FND_EXC_UNEXPECTED_ERROR;
                END IF;
            END IF;
        END IF;
        -- Required validation only for Source Type Code = PO
        IF l_ship_lines_rec.ship_line_src_type_code   = 'PO' AND
           p_rcv_enabled_flag = 'Y' THEN
            l_debug_info := 'Call Check_PoPriceTolerance';
            INL_LOGGING_PVT.Log_Statement (
                p_module_name => g_module_name,
                p_procedure_name => l_program_name,
                p_debug_info => l_debug_info) ;
            Check_PoPriceTolerance (
                p_ship_header_id            => p_ship_header_id,
                p_ship_line_id              => l_ship_lines_rec.ship_line_id,
                p_organization_id           => p_organization_id,
                p_ship_line_num             => l_ship_lines_rec.ship_line_num,
                p_ship_line_src_id          => l_ship_lines_rec.ship_line_source_id,
                p_pri_unit_price            => l_ship_lines_rec.primary_unit_price,
                p_primary_uom_code          => l_ship_lines_rec.primary_uom_code,
                p_currency_code             => l_ship_lines_rec.currency_code,
                p_currency_conversion_type  => l_ship_lines_rec.currency_conversion_type,
                p_currency_conversion_date  => l_ship_lines_rec.currency_conversion_date,
                p_currency_conversion_rate  => l_ship_lines_rec.currency_conversion_rate,
                x_return_validation_status  => l_return_validation_status, -- SCM-051
                x_return_status             => l_return_status
            ) ;
            -- If unexpected errors happen abort API
            IF l_return_status  = L_FND_RET_STS_ERROR THEN
                x_return_status := l_return_status;
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                x_return_status  := l_return_status;
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        -- Bug 9814099 - Code commented as it is wrong to validate
        -- allocation_enabled_flag with the value setup on INL_SHIP_LINE_TYPES.
        -- Allocation Enabled flag on INL_SHIP_LINE_TYPES is just used as a
        -- default value to INL_SHIPMENT_LINE table. The correct value to be
        -- used in this case would be the Allocation Enabled flag on
        -- INL_SHIPMENT_LINE, however this validation is automatically handled
        -- by the UI, so the code below would be redundant.

        -- Bug #8928896
        -- Check associations when allocation enabled flag is disabled
        /*IF NVL(l_ship_lines_rec.dflt_allocation_enabled_flag, 'N') = 'N' THEN
          l_debug_info := 'Call Validate_AllocEnabledFlag';
            INL_LOGGING_PVT.Log_Statement (
                p_module_name => g_module_name,
                p_procedure_name => l_program_name,
                p_debug_info => l_debug_info) ;
            Validate_AllocEnabledFlag (
                p_ship_header_id      => p_ship_header_id,
                p_alloc_enabled_flag  => l_ship_lines_rec.dflt_allocation_enabled_flag,
                p_ship_line_type_code => l_ship_lines_rec.ship_line_type_code,
                p_ship_line_id        => l_ship_lines_rec.ship_line_id,
                p_ship_line_num       => l_ship_lines_rec.ship_line_num,
                x_return_status       => l_return_status ) ;

            -- If unexpected errors happen abort API
            IF l_return_status  = L_FND_RET_STS_ERROR THEN
                x_return_status := l_return_status;
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                x_return_status  := l_return_status;
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;*/
        -- Bug /#8928896

    END LOOP;
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
EXCEPTION
WHEN L_FND_EXC_ERROR THEN
    -- Standard Expected Error Logging
    INL_LOGGING_PVT.Log_ExpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    x_return_status := L_FND_RET_STS_ERROR;
WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    x_return_status  := L_FND_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level (p_message_level  => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg (
            p_pkg_name => g_pkg_name,
            p_procedure_name => l_program_name) ;
    END IF;
END Validate_ShipLine;
-- Utility name   : Validate_ShipHdr
-- Type       : Private
-- Function   : Validate Shipment Header
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_header_id IN  NUMBER
-- OUT        : x_return_status  OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Validate_ShipHdr (
    p_ship_header_id IN NUMBER,
    p_task_code        IN VARCHAR2,--Bug#9836174
    x_return_status  OUT NOCOPY VARCHAR2
) IS
    l_program_name CONSTANT VARCHAR2 (30) := 'Validate_ShipHdr';
    l_return_status VARCHAR2 (1) := L_FND_RET_STS_SUCCESS;
    l_debug_info VARCHAR2 (200);
    l_ship_type_id NUMBER;
    l_ship_status VARCHAR2 (30);
    l_inv_org_id NUMBER;
    l_ship_date DATE;
    l_error_type VARCHAR2 (3);
    l_pending_matching_flag VARCHAR2 (1);
    l_sob_id NUMBER (15);
    l_comp_num VARCHAR2 (50) ;
    l_func_curr_code VARCHAR2 (15);
    l_ship_type_code VARCHAR2 (15);
    l_shipt_third_parties_allowed VARCHAR2 (1);
    l_in_adjust_flag VARCHAR2 (1);
    l_location_id NUMBER;
    l_error_message_name VARCHAR2 (200);
    l_error_token_name VARCHAR2 (200);
    l_country_code_location VARCHAR2 (100);
    l_taxation_country VARCHAR2(30); -- Bug #8271690
    l_rcv_enabled_flag VARCHAR2(1);
    l_sysdate date := sysdate; --Bug#9836174
    l_group_line_num NUMBER; --Bug #12630218
    CURSOR c_ln_group IS
      SELECT ship_line_group_num, ship_line_group_id, lg.party_id, lg.party_site_id,
             lg.ship_line_group_reference, hps.party_site_name
      FROM inl_ship_line_groups lg,
           hz_party_sites hps
      WHERE hps.party_site_id = lg.party_site_id
      AND   ship_header_id = p_ship_header_id
      ORDER BY ship_line_group_num;
BEGIN
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    x_return_status := L_FND_RET_STS_SUCCESS;
    l_debug_info := 'Get Shipment Header and Shipment Type information';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_debug_info => l_debug_info) ;
     SELECT shipt.ship_type_id,
            shipt.ship_type_code,
            shipt.trd_pties_alwd_code,
            NVL(sh.rcv_enabled_flag,'Y') rcv_enabled_flag, -- dependence
            sh.ship_status_code,
            sh.organization_id,
            sh.location_id,
            sh.ship_date,
            sh.pending_matching_flag,
            sh.taxation_country -- Bug #8271690
     INTO   l_ship_type_id,
            l_ship_type_code,
            l_shipt_third_parties_allowed,
            l_rcv_enabled_flag,
            l_ship_status,
            l_inv_org_id,
            l_location_id,
            l_ship_date,
            l_pending_matching_flag,
            l_taxation_country
     FROM   inl_ship_headers_all sh,
            inl_ship_types_vl shipt
     WHERE sh.ship_type_id = shipt.ship_type_id
     AND sh.ship_header_id = p_ship_header_id;
    IF l_ship_status = 'COMPLETED' AND l_pending_matching_flag = 'Y' THEN
        l_in_adjust_flag := 'Y';
    ELSE
        l_in_adjust_flag := 'N';
        --Bug#9836174 BEGIN
        IF  l_rcv_enabled_flag = 'Y'
            AND p_task_code > '50'
            AND TRUNC(l_ship_date) > l_sysdate
        THEN

            FND_MESSAGE.SET_NAME ('INL', 'INL_ERR_CHK_RCV_SHIP_DATE') ;
            FND_MSG_PUB.ADD;
            l_debug_info := 'Shipment date greater than current date.';
            INL_LOGGING_PVT.Log_Statement (
                p_module_name => g_pkg_name,
                p_procedure_name => l_program_name,
                p_debug_info => l_debug_info) ;
            INL_LOGGING_PVT.Log_Variable (
                p_module_name  => g_module_name,
                p_procedure_name => l_program_name,
                p_var_name => 'l_ship_date',
                p_var_value => TO_CHAR (l_ship_date)) ;
            -- INCLUDE A LINE IN INL_SHIP_HOLdS
            Handle_ShipError (
                p_ship_header_id => p_ship_header_id,
                p_ship_line_id => NULL,
                p_charge_line_id => NULL,
                p_table_name => 'INL_SHIP_HEADERS',
                p_column_name => 'SHIP_DATE',
                p_column_value => TO_CHAR (l_ship_date),
                p_error_message => SUBSTR (FND_MSG_PUB.Get (
                                                p_msg_index => FND_MSG_PUB.Count_Msg (),
                                                p_encoded => L_FND_FALSE), 1, 2000),
                p_error_message_name => 'INL_ERR_CHK_RCV_SHIP_DATE',
                p_token1_name => NULL,
                p_token1_value => NULL,
                p_token2_name => NULL,
                p_token2_value => NULL,
                p_token3_name => NULL,
                p_token3_value => NULL,
                p_token4_name => NULL,
                p_token4_value => NULL,
                p_token5_name => NULL,
                p_token5_value => NULL,
                p_token6_name => NULL,
                p_token6_value => NULL,
                x_return_status => l_return_status) ;
            -- If unexpected errors happen abort
            IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
        --Bug#9836174 END

    END IF;
    l_debug_info := 'Get Set of Books by a given Inventory Organization';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_debug_info => l_debug_info) ;
    SELECT set_of_books_id
    INTO l_sob_id
    FROM org_organization_definitions ood
    WHERE organization_id = l_inv_org_id;
    l_debug_info := 'Check Shipment Date against the Inventory Open Period';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_debug_info => l_debug_info) ;
    IF l_rcv_enabled_flag = 'Y' THEN
        IF Validate_InvOpenPeriod (
            x_trx_date => TO_CHAR (l_ship_date, 'YYYY-MM-DD'),
            x_sob_id => l_sob_id,
            x_org_id => l_inv_org_id,
            x_return_status => l_return_status) = 'FALSE'
        THEN
            FND_MESSAGE.SET_NAME ('INL', 'INL_ERR_CHK_INV_SHIP_DATE') ;
            FND_MESSAGE.SET_TOKEN ('SHIP_DATE', TO_CHAR (l_ship_date)) ;
            FND_MSG_PUB.ADD;
            l_debug_info := 'Transaction period is not open in Inventory.';
            INL_LOGGING_PVT.Log_Statement (
                p_module_name => g_pkg_name,
                p_procedure_name => l_program_name,
                p_debug_info => l_debug_info) ;
            INL_LOGGING_PVT.Log_Variable (
                p_module_name  => g_module_name,
                p_procedure_name => l_program_name,
                p_var_name => 'l_ship_date',
                p_var_value => TO_CHAR (l_ship_date)) ;
            -- INCLUDE A LINE IN INL_SHIP_HOLdS
            Handle_ShipError (
                p_ship_header_id => p_ship_header_id,
                p_ship_line_id => NULL,
                p_charge_line_id => NULL,
                p_table_name => 'INL_SHIP_HEADERS',
                p_column_name => 'SHIP_DATE',
                p_column_value => TO_CHAR (l_ship_date),
                p_error_message => SUBSTR (FND_MSG_PUB.Get (
                                                p_msg_index => FND_MSG_PUB.Count_Msg (),
                                                p_encoded => L_FND_FALSE), 1, 2000),
                p_error_message_name => 'INL_ERR_CHK_INV_SHIP_DATE',
                p_token1_name => 'SHIP_DATE',
                p_token1_value => TO_CHAR (l_ship_date),
                p_token2_name => NULL,
                p_token2_value => NULL,
                p_token3_name => NULL,
                p_token3_value => NULL,
                p_token4_name => NULL,
                p_token4_value => NULL,
                p_token5_name => NULL,
                p_token5_value => NULL,
                p_token6_name => NULL,
                p_token6_value => NULL,
                x_return_status => l_return_status) ;
            -- If unexpected errors happen abort
            IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
    END IF;

    l_debug_info := 'Check if the current Shipment has Shipment Lines for each Group';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_debug_info => l_debug_info) ;
    IF (NOT Has_ShipLine (p_ship_header_id, l_group_line_num)) THEN -- Bug #12630218
        IF l_group_line_num IS NOT NULL THEN
            FND_MESSAGE.SET_NAME ('INL', 'INL_ERR_CHK_NO_SHIP_LN_GRP_NUM');
            FND_MESSAGE.SET_TOKEN('LINE_GROUP_NUM',l_group_line_num);
            FND_MSG_PUB.ADD;
            -- INCLUDE A LINE IN INL_SHIP_HOLDS
            Handle_ShipError (
                p_ship_header_id => p_ship_header_id,
                p_ship_line_id => NULL,
                p_charge_line_id => NULL,
                p_table_name => 'INL_SHIP_HEADERS',
                p_column_name => 'SHIP_TYPE_ID',
                p_column_value => l_ship_type_id,
                p_error_message => SUBSTR (FND_MSG_PUB.Get (
                                         p_msg_index => FND_MSG_PUB.Count_Msg (),
                                            p_encoded => L_FND_FALSE), 1, 2000),
                p_error_message_name => 'INL_ERR_CHK_NO_SHIP_LN_GRP_NUM',
                p_token1_name => 'LINE_GROUP_NUM',
                p_token1_value => l_group_line_num,
                p_token2_name => NULL,
                p_token2_value => NULL,
                p_token3_name => NULL,
                p_token3_value => NULL,
                p_token4_name => NULL,
                p_token4_value => NULL,
                p_token5_name => NULL,
                p_token5_value => NULL,
                p_token6_name => NULL,
                p_token6_value => NULL,
                x_return_status => l_return_status) ;
            -- If unexpected errors happen abort
            IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        ELSE -- Bug 12630218 Shipment has no Group Lines
            FND_MESSAGE.SET_NAME ('INL', 'INL_ERR_CHK_NO_SHIP_LN');
            FND_MSG_PUB.ADD;
            -- INCLUDE A LINE IN INL_SHIP_HOLDS
            Handle_ShipError (
                p_ship_header_id => p_ship_header_id,
                p_ship_line_id => NULL,
                p_charge_line_id => NULL,
                p_table_name => 'INL_SHIP_HEADERS',
                p_column_name => 'SHIP_TYPE_ID',
                p_column_value => l_ship_type_id,
                p_error_message => SUBSTR (FND_MSG_PUB.Get (
                                         p_msg_index => FND_MSG_PUB.Count_Msg (),
                                            p_encoded => L_FND_FALSE), 1, 2000),
                p_error_message_name => 'INL_ERR_CHK_NO_SHIP_LN',
                p_token1_name => NULL,
                p_token1_value => NULL,
                p_token2_name => NULL,
                p_token2_value => NULL,
                p_token3_name => NULL,
                p_token3_value => NULL,
                p_token4_name => NULL,
                p_token4_value => NULL,
                p_token5_name => NULL,
                p_token5_value => NULL,
                p_token6_name => NULL,
                p_token6_value => NULL,
                x_return_status => l_return_status) ;
            -- If unexpected errors happen abort
            IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
    ELSIF l_in_adjust_flag = 'N' THEN
        l_debug_info := 'Get the functional currency code';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_pkg_name,
            p_procedure_name => l_program_name,
            p_debug_info => l_debug_info) ;
        SELECT gsb.currency_code
        INTO l_func_curr_code
        FROM org_organization_definitions ood,
             gl_sets_of_books gsb
        WHERE gsb.set_of_books_id = ood.set_of_books_id
        AND organization_id = l_inv_org_id;
        l_debug_info := 'Get Country from Location';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_program_name,
            p_debug_info => l_debug_info) ;
        SELECT country
        INTO l_country_code_location
        FROM hr_locations
        WHERE location_id = l_location_id;
        FOR l_ln_group_rec IN c_ln_group
        LOOP
            l_debug_info := 'Call Validate_LineGroup';
            INL_LOGGING_PVT.Log_Statement (
                p_module_name => g_module_name,
                p_procedure_name => l_program_name,
                p_debug_info => l_debug_info) ;
            Validate_LineGroup(
                p_ship_header_id        => p_ship_header_id,
                p_ship_type_code        => l_ship_type_code,
                p_inv_org_id            => l_inv_org_id,  -- Bug 15956572
                p_ln_group_id           => l_ln_group_rec.ship_line_group_id,
                p_ln_group_num          => l_ln_group_rec.ship_line_group_num, --Bug#13987019
                p_group_reference       => l_ln_group_rec.ship_line_group_reference,
                p_party_id              => l_ln_group_rec.party_id, --Bug#13987019
                p_party_site_id         => l_ln_group_rec.party_site_id,
                p_party_site_name       => l_ln_group_rec.party_site_name,
                p_taxation_country      => l_taxation_country,
                p_third_parties_allowed => l_shipt_third_parties_allowed,
                x_return_status         => l_return_status);
            -- /Bug #8271690
            l_debug_info := 'Call Validate_ShipLine';
            INL_LOGGING_PVT.Log_Statement (
                p_module_name => g_module_name,
                p_procedure_name => l_program_name,
                p_debug_info => l_debug_info) ;
            Validate_ShipLine (
                p_ship_header_id => p_ship_header_id,
                p_rcv_enabled_flag => l_rcv_enabled_flag,
                p_ln_group_id => l_ln_group_rec.ship_line_group_id,
                p_functional_currency_code => l_func_curr_code,
                p_foreign_currency_flag => 'Y',
                p_organization_id => l_inv_org_id,
                p_country_code_location => l_country_code_location,
                p_third_parties_allowed => l_shipt_third_parties_allowed,
                x_return_status => l_return_status) ;
            -- If unexpected errors happen abort API
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                x_return_status := l_return_status;
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                x_return_status := l_return_status;
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END LOOP;
    END IF;
EXCEPTION
WHEN L_FND_EXC_ERROR THEN
    -- Standard Expected Error Logging
    INL_LOGGING_PVT.Log_ExpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    x_return_status := L_FND_RET_STS_ERROR;
WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level (p_message_level  => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg (
            p_pkg_name => g_pkg_name,
            p_procedure_name => l_program_name) ;
    END IF;
END Validate_ShipHdr;

-- Utility name   : Validate_InvOpenPeriod
-- Type       : Private
-- Function   : Check whether the Inventory Period is open
-- Pre-reqs   : None
-- Parameters :
-- IN         : x_trx_date      IN VARCHAR2
--              x_sob_id        IN NUMBER
--              x_org_id        IN NUMBER
-- OUT        : x_return_status IN OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Validate_InvOpenPeriod     (
    x_trx_date      IN VARCHAR2,
    x_sob_id        IN NUMBER,
    x_org_id        IN NUMBER,
    x_return_status IN OUT NOCOPY VARCHAR2
) RETURN VARCHAR2
                               IS
    l_program_name       VARCHAR2 (200) := 'Validate_InvOpenPeriod';
    l_boolean         BOOLEAN;
    l_boolean_to_char VARCHAR2 (10) ;
    l_trx_date DATE;
    l_debug_info VARCHAR2 (400) ;
BEGIN
    l_trx_date := TO_DATE (x_trx_date, 'YYYY-MM-DD') ;
    -- the x_return_status parameter mustn't been reseted
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    -- information about the input parameters
    INL_LOGGING_PVT.Log_APICallIn (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_call_api_name => 'po_dates_s.val_open_period',
        p_in_param_name1 => 'x_trx_date',
        p_in_param_value1 => x_trx_date,
        p_in_param_name2 => 'x_sob_id',
        p_in_param_value2 => x_sob_id,
        p_in_param_name3 => 'x_org_id',
        p_in_param_value3 => x_org_id,
        p_in_param_name4 => 'x_return_status',
        p_in_param_value4 => x_return_status) ;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;
    l_boolean       := po_dates_s.val_open_period (
                            x_trx_date => l_trx_date,
                            x_sob_id => x_sob_id,
                            x_app_name => 'INV',
                            x_org_id => x_org_id) ;
    IF l_boolean THEN
        l_boolean_to_char := 'TRUE';
    ELSE
        l_boolean_to_char := 'FALSE';
    END IF;
    -- information about the respose
    INL_LOGGING_PVT.Log_APICallIn (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_call_api_name => 'po_dates_s.val_open_period',
        p_in_param_name1 => 'l_boolean_to_char',
        p_in_param_value1 => l_boolean_to_char) ;
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    RETURN l_boolean_to_char;
EXCEPTION
WHEN L_FND_EXC_ERROR THEN
    -- Standard Expected Error Logging
    INL_LOGGING_PVT.Log_ExpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    x_return_status := L_FND_RET_STS_ERROR;
    RETURN 'FALSE';
WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    RETURN 'FALSE';
WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level (p_message_level  => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg (
            p_pkg_name => g_pkg_name,
            p_procedure_name => l_program_name) ;
    END IF;
    RETURN 'FALSE';
END Validate_InvOpenPeriod;

-- API name   : Validate_Shipment
-- Type       : Private
-- Function   : Controls the validation of a given LCM Shipment.
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version      IN NUMBER
--              p_init_msg_list    IN VARCHAR2 L_FND_FALSE
--              p_commit           IN VARCHAR2 L_FND_FALSE
--              p_validation_level IN NUMBER   L_FND_VALID_LEVEL_FULL
--              p_ship_header_id   IN NUMBER
--
-- OUT          x_return_status    OUT NOCOPY VARCHAR2
--              x_msg_count        OUT NOCOPY NUMBER
--              x_msg_data         OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Validate_Shipment (
    p_api_version      IN NUMBER,
    p_init_msg_list    IN VARCHAR2 := L_FND_FALSE,
    p_commit           IN VARCHAR2 := L_FND_FALSE,
    p_validation_level IN NUMBER := L_FND_VALID_LEVEL_FULL,
    p_ship_header_id   IN NUMBER,
    p_task_code        IN VARCHAR2 DEFAULT NULL,--Bug#9836174
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2
) IS
    l_api_name    CONSTANT VARCHAR2 (30) := 'Validate_Shipment';
    l_api_version CONSTANT NUMBER := 1.0;
    l_return_status VARCHAR2 (1) := L_FND_RET_STS_SUCCESS;
    l_ship_status VARCHAR2 (30) ;
    l_exist_event VARCHAR2 (5) ;
    l_exist_status NUMBER := 0;
    l_debug_info VARCHAR2 (200);
BEGIN
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
    -- Standard Start of API savepoint
    SAVEPOINT Validate_Shipment_PVT;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean (p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    -- Check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
        p_current_version_number => l_api_version,
        p_caller_version_number => p_api_version,
        p_api_name => l_api_name,
        p_pkg_name => G_PKG_NAME
    ) THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;
    l_debug_info := 'Reset errors in inl_ship_holds table';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info => l_debug_info
    ) ;
    Reset_ShipError (
        p_ship_header_id => p_ship_header_id,
        p_ship_line_id => NULL,
        p_charge_line_id => NULL,
        x_return_status => l_return_status) ;
    -- If unexpected errors happen abort API
    IF l_return_status = L_FND_RET_STS_ERROR THEN
        x_return_status := l_return_status;
        RAISE L_FND_EXC_ERROR;
    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
        x_return_status := l_return_status;
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
    l_debug_info := 'Shipment Header validation';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_pkg_name,
        p_procedure_name => l_api_name,
        p_debug_info => l_debug_info) ;
    Validate_ShipHdr (
        p_ship_header_id => p_ship_header_id,
        p_task_code      => p_task_code, --Bug#9836174
        x_return_status => l_return_status) ;
    -- If unexpected errors happen abort API
    IF l_return_status   = L_FND_RET_STS_ERROR THEN
        x_return_status := l_return_status;
        RAISE L_FND_EXC_ERROR;
    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
        x_return_status  := l_return_status;
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
    l_debug_info := 'fnd_msg_pub.count_msg';
    INL_LOGGING_PVT.Log_Variable (
        p_module_name  => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'fnd_msg_pub.count_msg',
        p_var_value => TO_CHAR (fnd_msg_pub.count_msg)) ;
    IF (NVL (fnd_msg_pub.count_msg, 0) = 0) THEN
         SELECT ship_status_code
           INTO l_ship_status
           FROM inl_ship_headers
          WHERE ship_header_id = p_ship_header_id;
        IF l_ship_status <> 'COMPLETED' THEN
            l_debug_info := 'Update INL_SHIP_HEADERS_ALL.ship_status_code to VALIDATED';
            INL_LOGGING_PVT.Log_Statement (
                p_module_name => g_module_name,
                p_procedure_name => l_api_name,
                p_debug_info => l_debug_info) ;
            UPDATE inl_ship_headers
            SET ship_status_code = 'VALIDATED',
                last_updated_by = L_FND_USER_ID,
                last_update_date = SYSDATE
            WHERE ship_header_id = p_ship_header_id;
        END IF;
    ELSE
         l_debug_info := 'Update INL_SHIP_HEADERS_ALL.ship_status_code to ON HOLD';
         INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_debug_info => l_debug_info) ;
         UPDATE inl_ship_headers
        SET ship_status_code = 'ON HOLD',
            last_updated_by = L_FND_USER_ID,
            last_update_date = SYSDATE
          WHERE ship_header_id = p_ship_header_id;
    END IF;
    -- Standard check of p_commit.
    IF FND_API.To_Boolean (p_commit) THEN
        COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data) ;
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
EXCEPTION
WHEN L_FND_EXC_ERROR THEN
    INL_LOGGING_PVT.Log_ExpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
    ROLLBACK TO Validate_Shipment_PVT;
    x_return_status := L_FND_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data) ;
WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
    ROLLBACK TO Validate_Shipment_PVT;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data) ;
WHEN OTHERS THEN
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
    ROLLBACK TO Validate_Shipment_PVT;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg (
            p_pkg_name => g_pkg_name,
            p_procedure_name => l_api_name) ;
    END IF;
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data) ;
END Validate_Shipment;
-- Utility name: Create_Assoc
-- Type       : Private
-- Function   : Create Associations
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_assoc                  IN inl_Assoc_tp
--              p_from_parent_table_name IN VARCHAR2,
--              p_new_line_id            IN NUMBER, charge line at a highest level
--
-- OUT        : x_return_status          OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Create_Assoc (
    p_Assoc                  IN inl_Assoc_tp,
    p_from_parent_table_name IN VARCHAR2,
    p_new_line_id            IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2
) IS
    l_program_name     CONSTANT VARCHAR2 (30) := 'Create_Assoc';
    l_return_status VARCHAR2 (1) ;
    l_debug_info    VARCHAR2 (200) ;
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    --  Initialize return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;
    l_debug_info := 'Insert in inl_associations.';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_debug_info => l_debug_info) ;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name  => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_new_line_id',
        p_var_value => p_new_line_id) ;

    IF p_Assoc.association_id IS NULL THEN
        l_debug_info := 'Including association';
        INSERT
           INTO inl_associations (
                association_id,               /* 01 */
                ship_header_id,               /* 02 */
                from_parent_table_name,       /* 03 */
                from_parent_table_id,         /* 04 */
                to_parent_table_name,         /* 05 */
                to_parent_table_id,           /* 06 */
                allocation_basis,             /* 07 */
                allocation_uom_code,          /* 08 */
                created_by,                   /* 09 */
                creation_date,                /* 10 */
                last_updated_by,              /* 11 */
                last_update_date,             /* 12 */
                last_update_login             /* 13 */
            )
        VALUES (
                inl_associations_s.nextval,   /* 01 */
                p_Assoc.ship_header_id,       /* 02 */
                p_from_parent_table_name,     /* 03 */
                p_new_line_id,                /* 04 */
                p_Assoc.to_parent_table_name, /* 05 */
                p_Assoc.to_parent_table_id,   /* 06 */
                p_Assoc.allocation_basis,     /* 07 */
                p_Assoc.allocation_uom_code,  /* 08 */
                L_FND_USER_ID,                /* 09 */
                sysdate,                      /* 10 */
                L_FND_USER_ID,                /* 11 */
                sysdate,                      /* 12 */
                l_fnd_login_id                /* 13 */ --SCM-051
        );
    ELSE
        l_debug_info := 'Updating association';
        UPDATE inl_associations
        SET
                ship_header_id               = p_Assoc.ship_header_id      ,
                from_parent_table_name       = p_from_parent_table_name    ,
                from_parent_table_id         = p_new_line_id               ,
                to_parent_table_name         = p_Assoc.to_parent_table_name,
                to_parent_table_id           = p_Assoc.to_parent_table_id  ,
                allocation_basis             = p_Assoc.allocation_basis    ,
                allocation_uom_code          = p_Assoc.allocation_uom_code ,
                last_updated_by              = L_FND_USER_ID               ,
                last_update_date             = SYSDATE                     ,
                last_update_login            = l_fnd_login_id --SCM-051
        WHERE association_id = p_Assoc.association_id
        ;
    END IF;
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_debug_info => l_debug_info) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name  => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_new_line_id',
        p_var_value => p_new_line_id) ;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    );
EXCEPTION
WHEN L_FND_EXC_ERROR THEN
    -- Standard Expected Error Logging
    INL_LOGGING_PVT.Log_ExpecError(
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    );
    x_return_status := L_FND_RET_STS_ERROR;
WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError(
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    );
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError(
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    );
    x_return_status := L_FND_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
    ) THEN
        FND_MSG_PUB.Add_Exc_Msg (
            p_pkg_name => g_pkg_name,
            p_procedure_name => l_program_name
        );
    END IF;
END Create_Assoc;
-- Utility name: Create_TxLines
-- Type       : Private
-- Function   : Create Tax Lines
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_TxLn_Assoc            IN inl_TxLn_Assoc_tp
--              p_include_assoc         IN VARCHAR2 := 'Y'
--              p_adjustment_num        IN NUMBER
--
-- OUT        : x_new_tax_line_id       OUT NOCOPY NUMBER,
--              x_return_status         OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Create_TxLines(
        p_TxLn_Assoc        IN inl_TxLn_Assoc_tp,
        p_include_assoc     IN VARCHAR2 := 'Y',
        p_adjustment_num    IN NUMBER,
        x_new_tax_line_id   OUT NOCOPY NUMBER,
        x_return_status     OUT NOCOPY VARCHAR2
    ) IS
    l_program_name CONSTANT VARCHAR2(30):= 'Create_TxLines';
    l_return_status VARCHAR2(1);
    l_debug_info VARCHAR2(200);
    l_tax_line_num    NUMBER;
    l_adjustment_num  NUMBER;
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    );
    --  Initialize return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;
    --
    -- Get Max val to tax line num
    --
    IF p_TxLn_Assoc.tax_line_num IS NULL THEN
        l_debug_info             := 'Get Max val from tax line num';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name   => g_module_name,
            p_procedure_name=> l_program_name,
            p_debug_info    => l_debug_info
        )
        ;
         SELECT NVL (MAX (tl.tax_line_num), 0) + 1
           INTO l_tax_line_num
           FROM inl_tax_lines tl
          WHERE NVL (tl.ship_header_id, 0) = NVL (p_TxLn_Assoc.inl_Assoc.ship_header_id, 0) ;
    ELSE
        l_tax_line_num := p_TxLn_Assoc.tax_line_num;
    END IF;
    --
    -- Get Val to adjustment num
    --
    IF p_TxLn_Assoc.adjustment_num IS NULL THEN
        l_debug_info     := 'Set l_adjustment_num to p_adjustment_num';
        l_adjustment_num := p_adjustment_num;
    ELSE
        l_debug_info     := 'Set l_adjustment_num to p_TxLn_Assoc.adjustment_num';
        l_adjustment_num := p_TxLn_Assoc.adjustment_num;
    END IF;
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_debug_info => l_debug_info) ;
    --
    -- Get inl_tax_lines_s.nextval
    --
    l_debug_info := 'Get inl_tax_lines_s.nextval';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_debug_info => l_debug_info
    ) ;
    SELECT inl_tax_lines_s.nextval
    INTO x_new_tax_line_id
    FROM dual;
    --
    -- include Tax Line record
    --
    l_debug_info := 'Including Tax Line record ';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_debug_info => l_debug_info) ;
     INSERT
       INTO inl_tax_lines        (
            tax_line_id,                           /* 01 */
            tax_line_num,                          /* 02 */
            tax_code,                              /* 03 */
            ship_header_id,                        /* 04 */
            parent_tax_line_id,                    /* 05 */
            adjustment_num,                        /* 06 */
            match_id,                              /* 07 */
            match_amount_id,                       /* 08 */
            source_parent_table_name,              /* 09 */
            source_parent_table_id,                /* 10 */
            tax_amt,                               /* 11 */
            nrec_tax_amt,                          /* 12 */
            currency_code,                         /* 13 */
            currency_conversion_type,              /* 14 */
            currency_conversion_date,              /* 15 */
            currency_conversion_rate,              /* 16 */
            tax_amt_included_flag,                 /* 17 */
            created_by,                            /* 18 */
            creation_date,                         /* 19 */
            last_updated_by,                       /* 20 */
            last_update_date,                      /* 21 */
            last_update_login                      /* 22 */
        )
        VALUES
        (
            x_new_tax_line_id,                     /* 01 */
            l_tax_line_num,                        /* 02 */
            p_TxLn_Assoc.tax_code,                 /* 03 */
            p_TxLn_Assoc.inl_Assoc.ship_header_id, /* 04 */
            p_TxLn_Assoc.parent_tax_line_id,       /* 05 */
            l_adjustment_num,                      /* 06 */
            p_TxLn_Assoc.match_id,                 /* 07 */
            p_TxLn_Assoc.match_amount_id,          /* 08 */
            p_TxLn_Assoc.source_parent_table_name, /* 09 */
            p_TxLn_Assoc.source_parent_table_id,   /* 10 */
            p_TxLn_Assoc.matched_amt,              /* 11 */
            p_TxLn_Assoc.nrec_tax_amt,             /* 12 */
            p_TxLn_Assoc.currency_code,            /* 13 */
            p_TxLn_Assoc.currency_conversion_type, /* 14 */
            p_TxLn_Assoc.currency_conversion_date, /* 15 */
            p_TxLn_Assoc.currency_conversion_rate, /* 16 */
            p_TxLn_Assoc.tax_amt_included_flag,    /* 17 */
            L_FND_USER_ID,                         /* 18 */
            sysdate,                               /* 19 */
            L_FND_USER_ID,                         /* 20 */
            sysdate,                               /* 21 */
            l_fnd_login_id --SCM-051               /* 22 */
        ) ;
    IF p_include_assoc = 'Y' THEN
        Create_Assoc(
            p_Assoc                  => p_TxLn_Assoc.inl_Assoc,
            p_from_parent_table_name => 'INL_TAX_LINES',
            p_new_line_id            => x_new_tax_line_id,
            x_return_status          => l_return_status
        )
        ;
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    );
EXCEPTION
WHEN L_FND_EXC_ERROR THEN
    -- Standard Expected Error Logging
    INL_LOGGING_PVT.Log_ExpecError(
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    );
    x_return_status := L_FND_RET_STS_ERROR;
WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError(
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    );
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError(
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    );
    x_return_status := L_FND_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
        FND_MSG_PUB.Add_Exc_Msg(
            p_pkg_name      => g_pkg_name,
            p_procedure_name=> l_program_name
        );
    END IF;
END Create_TxLines;

-- Utility name: Zero_EstimTaxLines
-- Type       : Private
-- Function   : Create a Adj Tax Line with amt = 0
-- Pre-reqs   : None
-- Parameters :
-- IN         :     p_ship_header_id    IN NUMBER, -- sent null to process only one component
--                  p_match_id          IN NUMBER,
--                  p_comp_name         IN VARCHAR2, -- name of the component to make tax = 0
--                  p_comp_id           IN NUMBER, -- id of the component to make tax = 0
--                  p_tax_code          IN VARCHAR2, -- IF NULL = ALL
--                  p_adjustment_num    IN NUMBER
--                  p_prev_adjustment_num
--
-- OUT        : x_return_status         OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Zero_EstimTaxLines (
    p_ship_header_id        IN NUMBER,
    p_match_id              IN NUMBER,
    p_comp_name             IN VARCHAR2,
    p_comp_id               IN VARCHAR2,
    p_tax_code              IN VARCHAR2,
    p_adjustment_num        IN NUMBER,
    p_prev_adjustment_num   IN NUMBER DEFAULT 0, -- BUG#8411594
    x_return_status OUT NOCOPY VARCHAR2
) IS
    l_program_name CONSTANT VARCHAR2(30) := 'Zero_EstimTaxLines';
    l_return_status VARCHAR2(1);
    l_debug_info VARCHAR2(200);
    CURSOR estimated_TL
    IS
         SELECT tl.tax_line_id         ,
            tl.tax_line_num            ,
            tl.tax_code                ,
            tl.ship_header_id          ,
            tl.parent_tax_line_id      ,
            tl.adjustment_num          ,
            tl.match_id                ,
            tl.source_parent_table_name,
            tl.source_parent_table_id  ,
            tl.tax_amt                 ,
            tl.nrec_tax_amt            ,
            tl.currency_code           ,
            tl.currency_conversion_type,
            tl.currency_conversion_date,
            tl.currency_conversion_rate,
            tl.tax_amt_included_flag
           FROM inl_adj_tax_lines_v tl
          WHERE  p_ship_header_id IS NOT NULL  --Bug#14044298
            AND tl.adjustment_num = p_prev_adjustment_num
            AND tl.ship_header_id = p_ship_header_id
            AND
            (
                p_tax_code    IS NULL
                OR tl.tax_code = p_tax_code
            )
  UNION ALL
     SELECT tl.tax_line_id         ,
        tl.tax_line_num            ,
        tl.tax_code                ,
        tl.ship_header_id          ,
        tl.parent_tax_line_id      ,
        tl.adjustment_num          ,
        tl.match_id                ,
        tl.source_parent_table_name,
        tl.source_parent_table_id  ,
        tl.tax_amt                 ,
        tl.nrec_tax_amt            ,
        tl.currency_code           ,
        tl.currency_conversion_type,
        tl.currency_conversion_date,
        tl.currency_conversion_rate,
        tl.tax_amt_included_flag
       FROM
            inl_adj_tax_lines_v tl,
            inl_associations assoc
      WHERE p_ship_header_id IS NULL
        AND (tl.tax_amt > 0
             OR tl.nrec_tax_amt > 0)        --SCM-051
        AND (tl.adjustment_num = p_prev_adjustment_num
             OR tl.adjustment_num < 1)
        AND
        (
            p_tax_code    IS NULL
            OR tl.tax_code = p_tax_code
        )
        -- SCM-051
        AND assoc.from_parent_table_name = 'INL_TAX_LINES'
        AND assoc.to_parent_table_name   = p_comp_name
        AND assoc.to_parent_table_id     = p_comp_id
        AND assoc.from_parent_table_id =
        (
            SELECT parntTxLn0.tax_line_id
            FROM inl_tax_lines parntTxLn0
            WHERE CONNECT_BY_ISLEAF = 1
            START WITH parntTxLn0.tax_line_id = tl.tax_line_id
            CONNECT BY PRIOR parntTxLn0.parent_tax_line_id = parntTxLn0.tax_line_id
        )
        -- SCM-051
        ;
TYPE est_TL_Type
IS
    TABLE OF estimated_TL%ROWTYPE;
    C_est_TL est_TL_Type;
    l_TxLn_Assoc inl_TxLn_Assoc_tp;
    l_new_tax_line_id NUMBER;
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    );
    --  Initialize return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_prev_adjustment_num',
        p_var_value => p_prev_adjustment_num
    );

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_comp_name',
        p_var_value => p_comp_name
    );
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_comp_id',
        p_var_value => p_comp_id
    );

    l_debug_info := 'Getting existent estimated TaxLine.';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_debug_info => l_debug_info
    ) ;
    OPEN estimated_TL;
    FETCH estimated_TL BULK COLLECT INTO C_est_TL;
    CLOSE estimated_TL;
    l_debug_info := C_est_TL.LAST||' lines have been retrieved.';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_debug_info => l_debug_info
    ) ;
    IF NVL (C_est_TL.LAST, 0) > 0 THEN
        l_TxLn_Assoc.inl_Assoc.allocation_basis := NULL;
        l_TxLn_Assoc.inl_Assoc.allocation_uom_code := NULL;
        l_TxLn_Assoc.inl_Assoc.to_parent_table_name := NULL;
        l_TxLn_Assoc.inl_Assoc.to_parent_table_id := NULL;
        l_TxLn_Assoc.adjustment_num := p_adjustment_num;
        l_TxLn_Assoc.match_id := p_match_id;
        l_TxLn_Assoc.matched_amt := 0;
        l_TxLn_Assoc.nrec_tax_amt := 0;
        l_TxLn_Assoc.source_parent_table_name := 'INL_TAX_LINES';
        FOR i IN NVL (C_est_TL.FIRST, 0) ..NVL (C_est_TL.LAST, 0)
        LOOP
            l_TxLn_Assoc.inl_Assoc.ship_header_id := C_est_TL (i) .ship_header_id;
            l_TxLn_Assoc.tax_code                 := C_est_TL (i) .tax_code;
            l_TxLn_Assoc.tax_line_num             := C_est_TL (i) .tax_line_num;
            l_TxLn_Assoc.parent_tax_line_id       := C_est_TL (i) .tax_line_id;
            l_TxLn_Assoc.source_parent_table_id   := C_est_TL (i) .tax_line_id; --Unique index U2 in INL_TAX_LINES
            l_TxLn_Assoc.currency_code            := C_est_TL (i) .currency_code;
            l_TxLn_Assoc.currency_conversion_type := C_est_TL (i) .currency_conversion_type;
            l_TxLn_Assoc.currency_conversion_date := C_est_TL (i) .currency_conversion_date;
            l_TxLn_Assoc.currency_conversion_rate := C_est_TL (i) .currency_conversion_rate;
            l_TxLn_Assoc.tax_amt_included_flag    := C_est_TL (i) .tax_amt_included_flag;
            -- Create_TxLines
            l_debug_info := 'Estimated Tax line found new with 0.';
            INL_LOGGING_PVT.Log_Statement (
                p_module_name => g_module_name,
                p_procedure_name => l_program_name,
                p_debug_info => l_debug_info
            ) ;
            Create_TxLines (
                p_TxLn_Assoc        => l_TxLn_Assoc,
                p_include_assoc     => 'N',
                p_adjustment_num    => p_adjustment_num,
                x_new_tax_line_id   => l_new_tax_line_id,
                x_return_status     => l_return_status
            ) ;
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END LOOP;
    END IF;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    ) ;
EXCEPTION
WHEN L_FND_EXC_ERROR THEN
    -- Standard Expected Error Logging
    INL_LOGGING_PVT.Log_ExpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    ) ;
    x_return_status := L_FND_RET_STS_ERROR;
WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    ) ;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    ) ;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level (p_message_level  => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg (
            p_pkg_name => g_pkg_name,
            p_procedure_name => l_program_name
        ) ;
    END IF;
END Zero_EstimTaxLines;

-- Utility name: Zero_TaxLinesPerMatchAmt
-- Type       : Private
-- Function   : Create a Adj Tax Line with amt = 0
-- Pre-reqs   : None
-- Parameters :
-- IN         :     p_match_amount_id   IN NUMBER,
--                  p_adjustment_num    IN NUMBER
--
-- OUT        : x_return_status         OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      : When a invoice is resubmited, in case of existence of new matches in the same match amount,
--              the lines from old match_amount has been made zero (charge and taxes)
PROCEDURE Zero_TaxLinesPerMatchAmt (
    p_match_amount_id IN NUMBER,
    p_adjustment_num IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2
) IS
    l_program_name CONSTANT VARCHAR2(30) := 'Zero_TaxLinesPerMatchAmt';
    l_return_status VARCHAR2(1);
    l_debug_info VARCHAR2(200);
    CURSOR original_TL
    IS
         SELECT tl.tax_line_id         ,
            tl.tax_line_num            ,
            tl.tax_code                ,
            tl.ship_header_id          ,
            tl.parent_tax_line_id      ,
            tl.adjustment_num          ,
            tl.match_id                ,
            tl.source_parent_table_name,
            tl.source_parent_table_id  ,
            tl.tax_amt                 ,
            tl.nrec_tax_amt            ,
            tl.currency_code           ,
            tl.currency_conversion_type,
            tl.currency_conversion_date,
            tl.currency_conversion_rate,
            tl.tax_amt_included_flag
           FROM inl_adj_tax_lines_v tl
          WHERE match_Amount_id = p_match_Amount_id
          AND NOT EXISTS (SELECT 1
                            FROM INL_TAX_LINES t
                            WHERE t.parent_tax_line_id = tl.tax_line_id)
          ;
    TYPE ori_TL_Type
    IS
        TABLE OF original_TL%ROWTYPE;
    C_ori_TL ori_TL_Type;
    l_TxLn_Assoc inl_TxLn_Assoc_tp;
    l_new_tax_line_id NUMBER;
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    );
    --  Initialize return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;
    l_debug_info := 'Getting existent estimated TaxLine.';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name       => g_module_name,
        p_procedure_name    => l_program_name,
        p_debug_info        => l_debug_info
    ) ;
    OPEN original_TL;
    FETCH original_TL BULK COLLECT INTO C_ori_TL;
    CLOSE original_TL;
    l_debug_info := C_ori_TL.LAST||' lines have been retrieved.';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_debug_info => l_debug_info
    ) ;
    IF NVL (C_ori_TL.LAST, 0) > 0 THEN
        l_TxLn_Assoc.inl_Assoc.allocation_basis     := NULL;
        l_TxLn_Assoc.inl_Assoc.allocation_uom_code  := NULL;
        l_TxLn_Assoc.inl_Assoc.to_parent_table_name := NULL;
        l_TxLn_Assoc.inl_Assoc.to_parent_table_id   := NULL;
        l_TxLn_Assoc.adjustment_num := p_adjustment_num;
        l_TxLn_Assoc.match_id       := null;
        l_TxLn_Assoc.match_Amount_id := p_match_Amount_id;
        l_TxLn_Assoc.matched_amt    := 0;
        l_TxLn_Assoc.nrec_tax_amt   := 0;
        l_TxLn_Assoc.source_parent_table_name := 'INL_TAX_LINES';
        FOR i IN NVL (C_ori_TL.FIRST, 0) ..NVL (C_ori_TL.LAST, 0)
        LOOP
            l_TxLn_Assoc.inl_Assoc.ship_header_id := C_ori_TL (i) .ship_header_id;
            l_TxLn_Assoc.tax_code                 := C_ori_TL (i) .tax_code;
            l_TxLn_Assoc.tax_line_num             := C_ori_TL (i) .tax_line_num;
            l_TxLn_Assoc.parent_tax_line_id       := C_ori_TL (i) .tax_line_id;
            l_TxLn_Assoc.source_parent_table_id   := C_ori_TL (i) .tax_line_id; --Unique index U2 in INL_TAX_LINES
            l_TxLn_Assoc.currency_code            := C_ori_TL (i) .currency_code;
            l_TxLn_Assoc.currency_conversion_type := C_ori_TL (i) .currency_conversion_type;
            l_TxLn_Assoc.currency_conversion_date := C_ori_TL (i) .currency_conversion_date;
            l_TxLn_Assoc.currency_conversion_rate := C_ori_TL (i) .currency_conversion_rate;
            l_TxLn_Assoc.tax_amt_included_flag    := C_ori_TL (i) .tax_amt_included_flag;
            -- Create_TxLines
            l_debug_info := 'Estimated Tax line found new with 0.';
            INL_LOGGING_PVT.Log_Statement (
                p_module_name => g_module_name,
                p_procedure_name => l_program_name,
                p_debug_info => l_debug_info
            ) ;
            Create_TxLines (
                p_TxLn_Assoc        => l_TxLn_Assoc,
                p_include_assoc     => 'N',
                p_adjustment_num    => p_adjustment_num,
                x_new_tax_line_id   => l_new_tax_line_id,
                x_return_status     => l_return_status
            ) ;
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END LOOP;
    END IF;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    ) ;
EXCEPTION
WHEN L_FND_EXC_ERROR THEN
    -- Standard Expected Error Logging
    INL_LOGGING_PVT.Log_ExpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    ) ;
    x_return_status := L_FND_RET_STS_ERROR;
WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    ) ;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    ) ;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level (p_message_level  => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg (
            p_pkg_name => g_pkg_name,
            p_procedure_name => l_program_name
        ) ;
    END IF;
END Zero_TaxLinesPerMatchAmt;

---
---
-- API name   : Adjust_ShipLines
-- Type       : Private
-- Function   : Create Adjustments for Shipment Lines
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version     IN NUMBER   Required
--              p_init_msg_list   IN VARCHAR2 Optional  Default = L_FND_FALSE
--              p_commit          IN VARCHAR2 Optional  Default = L_FND_FALSE
--              p_match_id        IN  NUMBER,
--              p_adjustment_num  IN NUMBER,
--              p_func_currency_code IN VARCHAR2 , --BUG#8468830
-- OUT          x_return_status   OUT NOCOPY VARCHAR2
--              x_msg_count       OUT NOCOPY NUMBER
--              x_msg_data        OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Adjust_ShipLines    (
        p_api_version        IN NUMBER,
        p_init_msg_list      IN VARCHAR2 := L_FND_FALSE,
        p_commit             IN VARCHAR2 := L_FND_FALSE,
        p_match_id           IN NUMBER,
        p_adjustment_num     IN NUMBER,
        p_func_currency_code IN VARCHAR2, --BUG#8468830
        x_return_status      OUT NOCOPY VARCHAR2,
        x_msg_count          OUT NOCOPY NUMBER,
        x_msg_data           OUT NOCOPY VARCHAR2
) IS
    -- Cursor to get previous matching values
    -- in order to calculate partial match
    CURSOR c_previous_matchings (
        pc_ship_line_id IN NUMBER,
        pc_curr_match_id IN NUMBER,
        pc_to_currency_code IN VARCHAR2,
        pc_to_curr_conversion_type IN VARCHAR2,
        pc_to_curr_conversion_date IN DATE)
                         IS
         SELECT mat.matched_qty,
            mat.match_id       ,
            DECODE (pc_to_currency_code,
                    mat.matched_curr_code,
                    mat.matched_amt,
                    inl_landedcost_pvt.Converted_Amt (
                        mat.matched_amt,
                        mat.matched_curr_code,
                        pc_to_currency_code,
                        pc_to_curr_conversion_type,
                        pc_to_curr_conversion_date
                    )) matched_amt
           FROM inl_corr_matches_v mat
          WHERE mat.to_parent_table_name = 'INL_SHIP_LINES'
            AND mat.match_type_code      = 'ITEM'
            AND mat.to_parent_table_id   = pc_ship_line_id
            AND NOT EXISTS
            (
                 SELECT 1
                   FROM inl_corr_matches_v m2
                  WHERE m2.from_parent_table_name = mat.from_parent_table_name
                    AND m2.from_parent_table_id   = mat.from_parent_table_id
                    AND m2.match_id               > mat.match_id
            )
        AND mat.match_id <> pc_curr_match_id
   ORDER BY match_id ;
    l_prev_matchings_rec c_previous_matchings%ROWTYPE;
    l_api_name                  CONSTANT VARCHAR2 (30) := 'Adjust_ShipLines';
    l_api_version               CONSTANT NUMBER        := 1.0;
    l_return_status             VARCHAR2 (1) ;
    l_next_adjust_num           NUMBER;
    l_sum_adj_price             NUMBER;
    l_shipl_qty_sub_match       NUMBER;
    l_final_qty                 NUMBER;
    l_final_price               NUMBER;
    l_sl_inv_item_id            NUMBER;
    l_net_rcv_txn_qty           NUMBER;
    l_shipl_unit_price          NUMBER;
    l_to_ship_header_id         NUMBER;
    l_to_ship_line_id           NUMBER;
    l_matched_qty               NUMBER;
    l_primary_qty               NUMBER;
    l_secondary_qty             NUMBER; --BUG#8924795
    l_primary_unit_price        NUMBER;
    l_secondary_unit_price      NUMBER; -- BUG#8924795
    l_inv_org_id                NUMBER;
    l_matched_uom_code          VARCHAR2 (3) ;
    l_primary_uom_code          VARCHAR2 (3) ;
    l_secondary_uom_code        VARCHAR2 (3) ; -- BUG#8924795
    l_txn_uom_code              VARCHAR2 (3) ; --BUG#7674121
    l_debug_info                VARCHAR2 (240) ;
    l_replace_estim_qty_flag    VARCHAR2 (1) ;
    l_ship_line_num             NUMBER;
    l_ship_line_group_id        NUMBER;
    l_matched_amt               NUMBER;
    l_ship_line_curr_code       VARCHAR2 (15) ;
    l_current_curr_code         VARCHAR2 (15) ;
    l_current_curr_conv_type    VARCHAR2 (15) ;
    l_ship_line_curr_conv_type  VARCHAR2 (15) ; --BUG#8468830
    l_current_curr_conv_date    DATE;
    l_ship_line_curr_conv_rate  NUMBER; --BUG#8468830
    l_current_curr_conv_rate    NUMBER;
    l_ori_unit_price            NUMBER;
    l_existing_match_info_flag  VARCHAR2 (1) ;
    l_curr_match_id             NUMBER;
    l_from_parent_table_name    VARCHAR2 (30) ;
    l_from_parent_table_id      NUMBER;
-- Bug #7702294
    l_rt_transaction_id         NUMBER;
    l_rt_uom_code               VARCHAR2(3);
    l_ordered_po_qty            NUMBER;
    l_cancelled_po_qty          NUMBER;
    l_received_po_qty           NUMBER;
    l_corrected_po_qty          NUMBER;
    l_delivered_po_qty          NUMBER;
    l_rtv_po_qty                NUMBER;
    l_billed_po_qty             NUMBER;
    l_accepted_po_qty           NUMBER;
    l_rejected_po_qty           NUMBER;
    l_ordered_txn_qty           NUMBER;
    l_cancelled_txn_qty         NUMBER;
    l_received_txn_qty          NUMBER;
    l_corrected_txn_qty         NUMBER;
    l_delivered_txn_qty         NUMBER;
    l_rtv_txn_qty               NUMBER;
    l_billed_txn_qty            NUMBER;
    l_accepted_txn_qty          NUMBER;
    l_rejected_txn_qty          NUMBER;
-- Bug #7702294
    l_nrq_zero_exception_flag   VARCHAR2(1):='N'; --BUG#8334078

   -- Bug 11775590
   CURSOR c_last_adj_sl(p_to_ship_line_id IN NUMBER) IS
     SELECT rt.transaction_id,
           um.uom_code
     INTO l_rt_transaction_id,
          l_rt_uom_code
     FROM mtl_units_of_measure um,
          rcv_transactions rt,
          inl_ship_lines sl
     WHERE um.unit_of_measure = rt.unit_of_measure
     AND rt.destination_type_code = 'RECEIVING'
     AND ((rt.transaction_type = 'RECEIVE'
            AND rt.parent_transaction_id = -1)
          OR (rt.transaction_type = 'MATCH' -- Bug#9275335
          ))
     AND  rt.lcm_shipment_line_id = sl.ship_line_id
     AND rt.po_line_location_id = sl.ship_line_source_id
     AND sl.ship_line_src_type_code = 'PO'
     AND sl.ship_line_id = p_to_ship_line_id;

     TYPE last_adj_sl IS
     TABLE OF c_last_adj_sl%ROWTYPE INDEX BY BINARY_INTEGER;
     l_last_adj_sl last_adj_sl;
     -- /Bug 11775590

BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name
    ) ;
    -- Standard Start of API savepoint
    SAVEPOINT Adjust_ShipLines_PVT;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean (p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    -- Check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
        p_current_version_number => l_api_version,
        p_caller_version_number => p_api_version,
        p_api_name => l_api_name,
        p_pkg_name => g_pkg_name
    ) THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;
    -- Getting Matching Data
    l_debug_info := 'Getting Matching Data';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info => l_debug_info
    ) ;
    SELECT
        mat.ship_header_id ,                                                        /* 01 */
        mat.to_parent_table_id,                                                     /* 02 */
        mat.matched_qty,                                                            /* 03 */
        mat.matched_uom_code,                                                       /* 04 */
        mat.replace_estim_qty_flag,                                                 /* 05 */
        mat.existing_match_info_flag,                                               /* 06 */
        mat.matched_amt,                                                            /* 07 */
--      sl.txn_qty,                                                                 /* 08 */ -- Bug #7702294
        sl.primary_uom_code,                                                        /* 09a*/
        sl.secondary_uom_code,                                                      /* 09b*/
        sl.txn_uom_code,                                                            /* 09c*/ --Bug #7674121
        sh.organization_id,                                                         /* 10 */
        sl.inventory_item_id,                                                       /* 11 */
        sl.ship_line_num,                                                           /* 12 */
        sl.ship_line_group_id,                                                      /* 13 */
        sl.currency_code,                                                           /* 14 */
        mat.matched_curr_code,                                                      /* 15 */
        mat.matched_curr_conversion_type,                                           /* 16 */ --BUG#8468830
        mat.matched_curr_conversion_rate  ,                                         /* 16a*/ --BUG#8468830
        sl.currency_conversion_type  ,                                              /* 16b*/ --BUG#8468830
        NVL (mat.matched_curr_conversion_date, sl.currency_conversion_date),        /* 17 */
        sl.currency_conversion_rate,                                                /* 17a*/ --BUG#8468830
        sl.txn_unit_price,                                                          /* 18 */
        mat.from_parent_table_name,                                                 /* 19 */
        mat.from_parent_table_id,                                                   /* 20 */
        mat.match_id                                                                /* 21 */
       INTO
        l_to_ship_header_id   ,                                                     /* 01 */
        l_to_ship_line_id         ,                                                 /* 02 */
        l_matched_qty             ,                                                 /* 03 */
        l_matched_uom_code        ,                                                 /* 04 */
        l_replace_estim_qty_flag  ,                                                 /* 05 */
        l_existing_match_info_flag,                                                 /* 06 */
        l_matched_amt             ,                                                 /* 07 */
--      l_net_rcv_txn_qty           ,                                               /* 08 */ -- Bug #7702294
        l_primary_uom_code        ,                                                 /* 09a*/
        l_secondary_uom_code      ,                                                 /* 09b*/
        l_txn_uom_code            ,                                                 /* 09c*/ --Bug #7674121
        l_inv_org_id              ,                                                 /* 10 */
        l_sl_inv_item_id          ,                                                 /* 11 */
        l_ship_line_num           ,                                                 /* 12 */
        l_ship_line_group_id      ,                                                 /* 13 */
        l_ship_line_curr_code     ,                                                 /* 14 */
        l_current_curr_code       ,                                                 /* 15 */
        l_current_curr_conv_type  ,                                                 /* 16 */
        l_current_curr_conv_rate  ,                                                 /* 16a*/ --BUG#8468830
        l_ship_line_curr_conv_type,                                                 /* 16b*/ --BUG#8468830
        l_current_curr_conv_date  ,                                                 /* 17 */
        l_ship_line_curr_conv_rate,                                                 /* 17a*/ --BUG#8468830
        l_ori_unit_price          ,                                                 /* 18 */
        l_from_parent_table_name  ,                                                 /* 19 */
        l_from_parent_table_id    ,                                                 /* 20 */
        l_curr_match_id                                                             /* 21 */
       FROM inl_corr_matches_v mat,
        inl_ship_lines sl         ,
        inl_ship_lines sl0        ,
        inl_ship_headers sh
      WHERE mat.match_id                   = p_match_id
        AND mat.to_parent_table_name       = 'INL_SHIP_LINES'
        AND mat.adj_already_generated_flag = 'N'
        AND sl.ship_header_id              = sh.ship_header_id
        AND sl0.ship_line_id = mat.to_parent_table_id
        AND sl0.ship_header_id     = sl.ship_header_id
        AND sl0.ship_line_group_id = sl.ship_line_group_id
        AND sl0.ship_line_num      = sl.ship_line_num
        AND sl.adjustment_num =
                (
                    SELECT MIN(sl2.adjustment_num)
                    FROM inl_ship_lines sl2
                    WHERE sl0.ship_header_id     = sl2.ship_header_id
                    AND   sl0.ship_line_group_id = sl2.ship_line_group_id
                    AND   sl0.ship_line_num      = sl2.ship_line_num
                )
        AND (mat.correction_match_id is null OR
            mat.correction_match_id = (select min(mat2.correction_match_id)
                                         FROM inl_corr_matches_v mat2
                                        WHERE mat2.match_id                   = p_match_id
                                          AND mat2.to_parent_table_name       = 'INL_SHIP_LINES'
                                          AND mat2.adj_already_generated_flag = 'N'
                                      ));
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'l_to_ship_line_id',
        p_var_value => l_to_ship_line_id
    );


    l_debug_info := 'Getting Receiving Data';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info => l_debug_info
    ) ;

-- BUG#7702294
-- We should always consider the net rcv quantity, instead of the quantity of the
-- last adjustment done in shipment line. That is because corrections/returns may have been done in RCV.
    -- BUG#8235284

 -- Bug 11775590 Replaced by cursor
    /*
    SELECT rt.transaction_id,
           um.uom_code
     INTO l_rt_transaction_id,
          l_rt_uom_code
     FROM mtl_units_of_measure um,
          rcv_transactions rt,
          inl_ship_lines sl
     WHERE um.unit_of_measure = rt.unit_of_measure
     AND rt.destination_type_code = 'RECEIVING'
     AND ((rt.transaction_type = 'RECEIVE'
            AND rt.parent_transaction_id = -1)
          OR (rt.transaction_type = 'MATCH' -- Bug#9275335
          ))
     AND  rt.lcm_shipment_line_id = sl.ship_line_id
     AND rt.po_line_location_id = sl.ship_line_source_id
     AND sl.ship_line_src_type_code = 'PO'
     AND sl.ship_line_id = l_to_ship_line_id;
    */

    OPEN c_last_adj_sl(l_to_ship_line_id);
    FETCH c_last_adj_sl BULK COLLECT INTO l_last_adj_sl;
    CLOSE c_last_adj_sl;

    IF NVL(l_last_adj_sl.LAST, 0) > 0 THEN

        FOR i IN NVL(l_last_adj_sl.FIRST, 0)..NVL(l_last_adj_sl.LAST, 0)
        LOOP

            l_rt_transaction_id := l_last_adj_sl(i).transaction_id;
            l_rt_uom_code :=  l_last_adj_sl(i).uom_code;

    l_debug_info := 'Call rcv_invoice_matching_sv';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info => l_debug_info
    ) ;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'l_rt_transaction_id',
        p_var_value => l_rt_transaction_id
    );

    rcv_invoice_matching_sv.get_quantities
     (top_transaction_id => l_rt_transaction_id,
      ordered_po_qty     => l_ordered_po_qty   ,
      cancelled_po_qty   => l_cancelled_po_qty ,
      received_po_qty    => l_received_po_qty  ,
      corrected_po_qty   => l_corrected_po_qty ,
      delivered_po_qty   => l_delivered_po_qty ,
      rtv_po_qty         => l_rtv_po_qty       ,
      billed_po_qty      => l_billed_po_qty    ,
      accepted_po_qty    => l_accepted_po_qty  ,
      rejected_po_qty    => l_rejected_po_qty  ,
      ordered_txn_qty    => l_ordered_txn_qty  ,
      cancelled_txn_qty  => l_cancelled_txn_qty,
      received_txn_qty   => l_received_txn_qty ,
      corrected_txn_qty  => l_corrected_txn_qty,
      delivered_txn_qty  => l_delivered_txn_qty,
      rtv_txn_qty        => l_rtv_txn_qty      ,
      billed_txn_qty     => l_billed_txn_qty   ,
      accepted_txn_qty   => l_accepted_txn_qty ,
      rejected_txn_qty   => l_rejected_txn_qty);

    --- Bug  11775590
    --l_net_rcv_txn_qty := l_received_txn_qty + l_corrected_txn_qty - l_rtv_txn_qty;
    l_net_rcv_txn_qty := NVL(l_net_rcv_txn_qty,0) + l_received_txn_qty + l_corrected_txn_qty - l_rtv_txn_qty;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'l_received_txn_qty',
        p_var_value => l_received_txn_qty
    );

    --BUG#8334078
    -- 3rd alternative: if net_rcv = 0 get 1st qty and put a mark in the record
    --Bug#17389001    IF l_net_rcv_txn_qty = 0 THEN
    IF l_net_rcv_txn_qty < 0.00001 THEN --Bug#17389001

        INL_LOGGING_PVT.Log_Variable (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_var_name => 'l_net_rcv_txn_qty',
            p_var_value => l_net_rcv_txn_qty
        );
        l_nrq_zero_exception_flag := 'Y';
        SELECT txn_qty
        INTO l_net_rcv_txn_qty
        FROM inl_ship_lines
        WHERE ship_header_id = l_to_ship_header_id
        AND   ship_line_num = l_ship_line_num
        AND   ship_line_group_id = l_ship_line_group_id
        AND   adjustment_num = 0
        ;
    END IF;
    --BUG#8334078

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'l_received_txn_qty',
        p_var_value => l_received_txn_qty
    );
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'l_corrected_txn_qty',
        p_var_value => l_corrected_txn_qty
    );

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'l_rtv_txn_qty',
        p_var_value => l_rtv_txn_qty
    );

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'l_net_rcv_txn_qty',
        p_var_value => l_net_rcv_txn_qty
    );
-- Bug #7849658
    l_net_rcv_txn_qty := INL_LANDEDCOST_PVT.Converted_Qty (
                            p_organization_id => l_inv_org_id,
                            p_inventory_item_id => l_sl_inv_item_id,
                            p_qty => l_net_rcv_txn_qty,
                            p_from_uom_code => l_rt_uom_code,
                            p_to_uom_code => l_txn_uom_code
    );

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'l_net_rcv_txn_qty',
        p_var_value => l_net_rcv_txn_qty
    );

        END LOOP;
    END IF;
    -- /Bug 11775590

-- Bug #7702294

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'l_ship_line_curr_code',
        p_var_value => l_ship_line_curr_code
    );
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'l_current_curr_code',
        p_var_value => l_current_curr_code
    );
    IF l_ship_line_curr_code <> l_current_curr_code
        AND nvl(l_current_curr_conv_type,l_ship_line_curr_conv_type)  IS NOT NULL THEN  --BUG#8468830
        INL_LOGGING_PVT.Log_Variable (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_var_name => 'l_current_curr_conv_type',
            p_var_value => l_current_curr_conv_type
        );

        IF l_current_curr_conv_type = 'User' THEN  --BUG#8468830
            -- if currency conversion rate is in match: divide
            l_shipl_unit_price :=  l_ori_unit_price / l_current_curr_conv_rate;
        ELSIF l_current_curr_conv_type IS NULL AND l_ship_line_curr_conv_type = 'User' THEN  --BUG#8468830
            -- else if currency conversion rate is in ship line: multiply
            l_shipl_unit_price :=  l_ori_unit_price * l_ship_line_curr_conv_rate;
        ELSE
            l_shipl_unit_price :=  inl_landedcost_pvt.Converted_Amt (
                                        l_ori_unit_price,
                                        l_ship_line_curr_code,
                                        l_current_curr_code,
                                        nvl(l_current_curr_conv_type,l_ship_line_curr_conv_type),  --BUG#8468830
                                        l_current_curr_conv_date
            );
        END IF;
    ELSE
        l_shipl_unit_price  := l_ori_unit_price;
    END IF;

    l_debug_info := 'l_to_ship_header_id';
    INL_LOGGING_PVT.Log_Variable (
        p_module_name     => g_module_name,
        p_procedure_name  => l_api_name,
        p_var_name        => l_debug_info,
        p_var_value       => l_to_ship_header_id) ;
    l_debug_info := 'l_to_ship_line_id';
    INL_LOGGING_PVT.Log_Variable (
        p_module_name     => g_module_name,
        p_procedure_name  => l_api_name,
        p_var_name        => l_debug_info,
        p_var_value       => l_to_ship_line_id) ;
    l_debug_info := 'l_matched_qty';
    INL_LOGGING_PVT.Log_Variable (
        p_module_name     => g_module_name,
        p_procedure_name  => l_api_name,
        p_var_name        => l_debug_info,
        p_var_value       => l_matched_qty) ;
    l_debug_info := 'l_matched_uom_code';
    INL_LOGGING_PVT.Log_Variable (
        p_module_name     => g_module_name,
        p_procedure_name  => l_api_name,
        p_var_name        => l_debug_info,
        p_var_value       => l_matched_uom_code) ;
    -- STEP 2: Get Estimated Shipment Line Data
    l_debug_info := 'Get Estimated Shipment Line Data';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name    => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info     => l_debug_info) ;
    l_debug_info := 'l_sl_inv_item_id';
    INL_LOGGING_PVT.Log_Variable (
        p_module_name     => g_module_name,
        p_procedure_name  => l_api_name,
        p_var_name        => l_debug_info,
        p_var_value       => l_sl_inv_item_id) ;
    l_debug_info := 'l_net_rcv_txn_qty';
    INL_LOGGING_PVT.Log_Variable (
        p_module_name     => g_module_name,
        p_procedure_name  => l_api_name,
        p_var_name        => l_debug_info,
        p_var_value       => l_net_rcv_txn_qty) ;
    l_debug_info := 'l_shipl_unit_price';
    INL_LOGGING_PVT.Log_Variable (
        p_module_name     => g_module_name,
        p_procedure_name  => l_api_name,
        p_var_name        => l_debug_info,
        p_var_value       => l_shipl_unit_price) ;
    -- STEP 3: Get the Adjustment Number
    l_debug_info := 'Get the Adjustment Number';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name    => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info     => l_debug_info) ;
    l_next_adjust_num := p_adjustment_num;
    l_debug_info := 'l_next_adjust_num';
    INL_LOGGING_PVT.Log_Variable (
        p_module_name     => g_module_name,
        p_procedure_name  => l_api_name,
        p_var_name        => l_debug_info,
        p_var_value       => l_next_adjust_num) ;

    -- STEP 4: Partial Matching handling
    --IF l_matched_qty < l_opl_txn_qty THEN
    --Calculate Partial Matching based on previous Adjustments
    l_debug_info := 'Calculate Partial Matching based on previous Adjustments';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info => l_debug_info
    );
    IF l_replace_estim_qty_flag = 'Y' THEN  --Match from RCV
        l_debug_info := 'Getting the values from Adj';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_debug_info => l_debug_info
        );
        SELECT txn_unit_price,
            txn_qty           ,
            primary_qty       ,
            primary_unit_price
           INTO l_final_price,
            l_final_qty      ,
            l_primary_qty    ,
            l_primary_unit_price
           FROM inl_adj_ship_lines_v
          WHERE ship_header_id     = l_to_ship_header_id
            AND ship_line_group_id = l_ship_line_group_id
            AND ship_line_num      = l_ship_line_num;
        l_final_price := l_matched_amt / l_matched_qty;
        l_debug_info := 'Setting the new quantity ';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_debug_info => l_debug_info
        ) ;
        INL_LOGGING_PVT.Log_Variable (
            p_module_name     => g_module_name,
            p_procedure_name  => l_api_name,
            p_var_name        => 'l_final_qty',
            p_var_value       => l_final_qty
        );
        INL_LOGGING_PVT.Log_Variable (
            p_module_name     => g_module_name,
            p_procedure_name  => l_api_name,
            p_var_name        => 'l_primary_qty',
            p_var_value       => l_primary_qty
        );
        INL_LOGGING_PVT.Log_Variable (
            p_module_name     => g_module_name,
            p_procedure_name  => l_api_name,
            p_var_name        => 'l_primary_unit_price',
            p_var_value       => l_primary_unit_price
        );

        IF l_final_qty = l_primary_qty THEN
            l_final_qty := l_matched_qty;
            l_primary_qty := l_matched_qty;
            l_primary_unit_price := l_final_price;
        ELSE
            l_final_qty := l_matched_qty;
            -- Getting Primary Quantity and Primary Unit Price
            l_primary_qty := INL_LANDEDCOST_PVT.Converted_Qty (
                                p_organization_id => l_inv_org_id,
                                p_inventory_item_id => l_sl_inv_item_id,
                                p_qty => l_final_qty,
                                p_from_uom_code => l_matched_uom_code,
                                p_to_uom_code => l_primary_uom_code
                            ) ;
            l_primary_unit_price := (l_final_qty * l_final_price) / l_primary_qty;
        END IF;
    ELSE

        INL_LOGGING_PVT.Log_Variable (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_var_name => 'l_existing_match_info_flag',
            p_var_value => l_existing_match_info_flag
        ) ;

        FOR l_prev_matchings_rec IN c_previous_matchings (
                                        l_to_ship_line_id,
                                        l_curr_match_id,
                                        l_current_curr_code,
                                        nvl(l_current_curr_conv_type,l_ship_line_curr_conv_type),
                                        l_current_curr_conv_date
                                        )
        LOOP

            l_sum_adj_price := NVL (l_sum_adj_price, 0) + NVL(l_prev_matchings_rec.matched_amt,0);
--shouldn't be consider            IF NVL(l_prev_matchings_rec.matched_qty,0) > 0 THEN  -- BUG#8198265
            l_final_qty     := NVL (l_final_qty, 0)     + NVL(l_prev_matchings_rec.matched_qty,0);
--shouldn't be consider            END IF;

        END LOOP;
        -- Add the current transaction values to the calculation
        l_debug_info := 'Add the current transaction values to the calculation';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_debug_info => l_debug_info
        ) ;


--shouldn't be consider        IF NVL(l_matched_qty,0) > 0 THEN  -- BUG#8198265
        l_final_qty           := NVL (l_final_qty, 0)     + NVL (l_matched_qty, 0) ;
--shouldn't be consider        END IF;
        IF l_final_qty < 0 then
            l_final_qty := 0;   -- BUG#8198265
        END IF;

        l_sum_adj_price       := NVL (l_sum_adj_price, 0) + l_matched_amt;
        IF NVL (l_final_qty, 0) < NVL (l_net_rcv_txn_qty, 0) THEN   -- BUG#8198265
            l_shipl_qty_sub_match := NVL (l_net_rcv_txn_qty, 0) - NVL (l_final_qty, 0) ;
        ELSE
            l_shipl_qty_sub_match := 0;
        END IF;

        l_sum_adj_price       := NVL (l_sum_adj_price, 0) + (l_shipl_qty_sub_match * nvl(l_shipl_unit_price,0)) ;
        l_final_qty           := NVL (l_final_qty, 0)     + l_shipl_qty_sub_match;
        --
        -- The code above this point should be review in order to verify the necessity of l_final_qty
        --
        l_final_qty           := l_net_rcv_txn_qty;  --BUG#8198265
        l_final_price         := l_sum_adj_price / l_final_qty;            --BUG#8198265

        INL_LOGGING_PVT.Log_Variable (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_var_name => 'l_final_qty',
            p_var_value => l_final_qty
        ) ;

        INL_LOGGING_PVT.Log_Variable (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_var_name => 'l_final_price',
            p_var_value => l_final_price
        ) ;
        IF l_matched_uom_code IS NULL THEN          --BUG#7674121
            l_matched_uom_code := l_txn_uom_code;   --BUG#7674121
        END IF;
        -- Verifying if UOM conversion are required
        IF l_primary_uom_code <>  l_matched_uom_code THEN     --BUG#7674121
            l_primary_qty := INL_LANDEDCOST_PVT.Converted_Qty (
                                p_organization_id => l_inv_org_id,
                                p_inventory_item_id => l_sl_inv_item_id,
                                p_qty => l_final_qty,
                                p_from_uom_code => l_matched_uom_code,
                                p_to_uom_code => l_primary_uom_code) ;
        ELSE
            l_primary_qty := l_final_qty;
        END IF;
        l_primary_unit_price := (l_final_qty * l_final_price) / l_primary_qty;

        l_debug_info := 'Ckecking secondary fields';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_debug_info => l_debug_info
        ) ;
        -- BUG 8924795
        IF l_secondary_uom_code IS NOT NULL THEN

            l_secondary_qty := INL_LANDEDCOST_PVT.Converted_Qty (
                p_organization_id => l_inv_org_id,
                p_inventory_item_id => l_sl_inv_item_id,
                p_qty => l_primary_qty,
                p_from_uom_code => l_primary_uom_code,
                p_to_uom_code => l_secondary_uom_code) ;

           l_secondary_unit_price := (l_final_qty * l_final_price) / l_secondary_qty;

            l_debug_info := 'l_secondary_qty';
            INL_LOGGING_PVT.Log_Variable ( p_module_name     => g_module_name,
                                   p_procedure_name  => l_api_name,
                                   p_var_name        => l_debug_info,
                                   p_var_value       => l_secondary_qty) ;

            l_debug_info := 'l_secondary_unit_price';
            INL_LOGGING_PVT.Log_Variable ( p_module_name     => g_module_name,
                                   p_procedure_name  => l_api_name,
                                   p_var_name        => l_debug_info,
                                   p_var_value       => l_secondary_unit_price) ;

        END IF;
        --
        -- STEP 5: Copy Shipment Line from Estimated to Actual
        l_debug_info := 'Copy Shipment Line from Estimated to Actual';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_debug_info => l_debug_info
        ) ;
    END IF;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name     => g_module_name,
        p_procedure_name  => l_api_name,
        p_var_name        => 'l_final_qty',
        p_var_value       => l_final_qty
    );
    INL_LOGGING_PVT.Log_Variable (
        p_module_name     => g_module_name,
        p_procedure_name  => l_api_name,
        p_var_name        => 'l_primary_qty',
        p_var_value       => l_primary_qty
    );
    INL_LOGGING_PVT.Log_Variable (
        p_module_name     => g_module_name,
        p_procedure_name  => l_api_name,
        p_var_name        => 'l_primary_unit_price',
        p_var_value       => l_primary_unit_price
    );

    --BUG#8468830
    IF p_func_currency_code <> l_current_curr_code THEN
        l_current_curr_conv_type:=nvl(l_current_curr_conv_type,l_ship_line_curr_conv_type);
    ELSE
        l_current_curr_conv_type:= NULL;
        l_current_curr_conv_rate:= NULL;
    END IF;

    --BUG#8468830
    INSERT
       INTO inl_ship_lines_all
        (
            ship_header_id,             /* 01 */
            ship_line_group_id,         /* 02 */
            ship_line_id,               /* 03 */
            ship_line_num,              /* 04 */
            ship_line_type_id,          /* 05 */
            ship_line_src_type_code,    /* 06 */
            ship_line_source_id,        /* 07 */
            parent_ship_line_id,        /* 08 */
            adjustment_num,             /* 09 */
            match_id,                   /* 10 */
            currency_code,              /* 12 */
            currency_conversion_type,   /* 13 */
            currency_conversion_date,   /* 14 */
            currency_conversion_rate,   /* 15 */
            inventory_item_id,          /* 16 */
            txn_qty,                    /* 17 */
            txn_uom_code,               /* 18 */
            txn_unit_price,             /* 19 */
            primary_qty,                /* 20 */
            primary_uom_code,           /* 21 */
            primary_unit_price,         /* 22 */
            secondary_qty,              /* 23 */
            secondary_uom_code,         /* 24 */
            secondary_unit_price,       /* 25 */
            landed_cost_flag,           /* 30 */
            allocation_enabled_flag,    /* 31 */
            trx_business_category,      /* 32 */
            intended_use,               /* 33 */
            product_fiscal_class,       /* 34 */
            product_category,           /* 35 */
            product_type,               /* 36 */
            user_def_fiscal_class,      /* 37 */
            tax_classification_code,    /* 38 */
            assessable_value,           /* 39 */
            tax_already_calculated_flag,/* 40 */
            ship_from_party_id,         /* 41 */
            ship_from_party_site_id,    /* 42 */
            ship_to_organization_id,    /* 43 */
            ship_to_location_id,        /* 44 */
            bill_from_party_id,         /* 45 */
            bill_from_party_site_id,    /* 46 */
            bill_to_organization_id,    /* 47 */
            bill_to_location_id,        /* 48 */
            poa_party_id,               /* 49 */
            poa_party_site_id,          /* 50 */
            poo_organization_id,        /* 51 */
            poo_location_id,            /* 52 */
            org_id,                     /* 53 */
            created_by,                 /* 54 */
            creation_date,              /* 55 */
            last_updated_by,            /* 56 */
            last_update_date,           /* 57 */
            last_update_login,          /* 58 */
            program_id,                 /* 59 */
            program_update_date,        /* 60 */
            program_application_id,     /* 61 */
            request_id,                 /* 62 */
            attribute_category,         /* 63 */
            attribute1,                 /* 64 */
            attribute2,                 /* 65 */
            attribute3,                 /* 66 */
            attribute4,                 /* 67 */
            attribute5,                 /* 68 */
            attribute6,                 /* 69 */
            attribute7,                 /* 70 */
            attribute8,                 /* 71 */
            attribute9,                 /* 72 */
            attribute10,                /* 73 */
            attribute11,                /* 74 */
            attribute12,                /* 75 */
            attribute13,                /* 76 */
            attribute14,                /* 77 */
            attribute15,                /* 78 */
            nrq_zero_exception_flag     /* 79 */ --BUG#8334078
            )
    SELECT sl.ship_header_id,          /* 01 */
        sl.ship_line_group_id,          /* 02 */
        inl_ship_lines_all_s.NEXTVAL,   /* 03 */
        sl.ship_line_num,               /* 04 */
        sl.ship_line_type_id,           /* 05 */
        sl.ship_line_src_type_code,     /* 06 */
        sl.ship_line_source_id,         /* 07 */
        sl.ship_line_id,                /* 08 */
        l_next_adjust_num,              /* 09 */
        p_match_id,                     /* 10 */
        l_current_curr_code,            /* 12 */
        l_current_curr_conv_type,       /* 13 */
        l_current_curr_conv_date,       /* 14 */
        l_current_curr_conv_rate,       /* 15 */
        sl.inventory_item_id,           /* 16 */
        l_final_qty,                    /* 17 */
        l_txn_uom_code,                 /* 18 */   --BUG#8198265
        l_final_price,                  /* 19 */
        l_primary_qty,                  /* 20 */
        l_primary_uom_code,             /* 21 */   --BUG#8198265
        l_primary_unit_price,           /* 22 */
        NVL(l_secondary_qty,sl.secondary_qty),               /* 23 */
        sl.secondary_uom_code,          /* 24 */
        NVL(l_secondary_unit_price, sl.secondary_unit_price), /* 25 */
        sl.landed_cost_flag,            /* 30 */
        sl.allocation_enabled_flag,     /* 31 */
        sl.trx_business_category,       /* 32 */
        sl.intended_use,                /* 33 */
        sl.product_fiscal_class,        /* 34 */
        sl.product_category,            /* 35 */
        sl.product_type,                /* 36 */
        sl.user_def_fiscal_class,       /* 37 */
        sl.tax_classification_code,     /* 38 */
        sl.assessable_value,            /* 39 */
        'N'                  , -- tax_already_calculated_flag/* 40 */
        sl.ship_from_party_id,          /* 41 */
        sl.ship_from_party_site_id,     /* 42 */
        sl.ship_to_organization_id,     /* 43 */
        sl.ship_to_location_id,         /* 44 */
        sl.bill_from_party_id,          /* 45 */
        sl.bill_from_party_site_id,     /* 46 */
        sl.bill_to_organization_id,     /* 47 */
        sl.bill_to_location_id,         /* 48 */
        sl.poa_party_id,                /* 49 */
        sl.poa_party_site_id,           /* 50 */
        sl.poo_organization_id,         /* 51 */
        sl.poo_location_id,             /* 52 */
        sl.org_id,                      /* 53 */
        sl.created_by,                  /* 54 */
        sl.creation_date,               /* 55 */
        sl.last_updated_by,             /* 56 */
        sl.last_update_date,            /* 57 */
        sl.last_update_login,           /* 58 */
        sl.program_id,                  /* 59 */
        sl.program_update_date,         /* 60 */
        sl.program_application_id,      /* 61 */
        sl.request_id,                  /* 62 */
        sl.attribute_category,          /* 63 */
        sl.attribute1,                  /* 64 */
        sl.attribute2,                  /* 65 */
        sl.attribute3,                  /* 66 */
        sl.attribute4,                  /* 67 */
        sl.attribute5,                  /* 68 */
        sl.attribute6,                  /* 69 */
        sl.attribute7,                  /* 70 */
        sl.attribute8,                  /* 71 */
        sl.attribute9,                  /* 72 */
        sl.attribute10,                 /* 73 */
        sl.attribute11,                 /* 74 */
        sl.attribute12,                 /* 75 */
        sl.attribute13,                 /* 76 */
        sl.attribute14,                 /* 77 */
        sl.attribute15,                 /* 78 */
        l_nrq_zero_exception_flag       /* 79 */ --BUG#8334078
    FROM inl_ship_lines sl
    WHERE ship_line_id        = l_to_ship_line_id;
    IF l_replace_estim_qty_flag = 'N' THEN --THIS TRANSACTION IS ABOUT AN ACTUAL VALUE
        -- IF SHIP LINE HAS ESTIMATED TAXES THEY WILL WILL BE = 0
        Zero_EstimTaxLines (
            p_ship_header_id => NULL,
            p_match_id => p_match_id,
            p_comp_name => 'INL_SHIP_LINES',
            p_comp_id => l_to_ship_line_id,
            p_tax_code => NULL,
            p_adjustment_num => p_adjustment_num,
            x_return_status => l_return_status
        ) ;
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;
    -- Standard check of p_commit.
    IF FND_API.To_Boolean (p_commit) THEN
        COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data
    ) ;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name
    ) ;
EXCEPTION
WHEN L_FND_EXC_ERROR THEN
    -- Standard Expected Error Logging
    INL_LOGGING_PVT.Log_ExpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name
    ) ;
    ROLLBACK TO Adjust_ShipLines_PVT;
    x_return_status := L_FND_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data
    ) ;
WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name
    ) ;
    ROLLBACK TO Adjust_ShipLines_PVT;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data
    ) ;
WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name
    ) ;
    ROLLBACK TO Adjust_ShipLines_PVT;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg (
            p_pkg_name        => g_pkg_name,
            p_procedure_name => l_api_name
        ) ;
    END IF;
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data
    ) ;
END Adjust_ShipLines;

-- Utility name: Create_ChLines
-- Type       : Private
-- Function   : Create Charge Lines
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ChLn_Assoc            IN inl_ChLn_Assoc_tp
--              p_include_assoc         IN VARCHAR2 := 'Y'
--              p_adjustment_num        IN NUMBER
--
-- OUT        : x_new_charge_line_id    OUT NUMBER  new charge line at a ship line level
--              x_return_status         OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Create_ChLines(
    p_ChLn_Assoc     IN inl_ChLn_Assoc_tp,
    p_include_assoc  IN VARCHAR2 := 'Y',
    p_adjustment_num IN NUMBER,
    x_new_charge_line_id OUT NOCOPY NUMBER,
    x_return_status OUT NOCOPY      VARCHAR2
) IS
    l_program_name       CONSTANT VARCHAR2 (30) := 'Create_ChLines';
    l_return_status   VARCHAR2 (1) ;
    l_debug_info      VARCHAR2 (200) ;
    l_charge_line_num NUMBER;
    l_adjustment_num  NUMBER;
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc ( p_module_name => g_module_name, p_procedure_name => l_program_name) ;
    --  Initialize return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;
    --
    -- Get Max val to charge line num
    --
    IF p_ChLn_Assoc.charge_line_num IS NULL THEN
        l_debug_info := 'Get Max val from charge line num';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_program_name,
            p_debug_info => l_debug_info
        ) ;
-- BUG#8411723 => MURALI
        IF p_ChLn_Assoc.match_amount_id IS NOT NULL THEN
            -- Get the max charge line num for all shipments affected by this match
            SELECT NVL(MAX(cl.charge_line_num),0) + 1
            INTO l_charge_line_num
            FROM inl_charge_lines cl
            WHERE EXISTS
                (SELECT 1
                 FROM inl_associations assoc
                 WHERE assoc.from_parent_table_name = 'INL_CHARGE_LINES'
                 AND assoc.from_parent_table_id   = cl.charge_line_id
                 AND assoc.ship_header_id
                    IN (select m1.ship_header_id
                        from inl_corr_matches_v m1
                        where m1.match_amount_id = p_ChLn_Assoc.match_amount_id
                       )
                )
           ;
-- BUG#8411723 => MURALI
        ELSE
            SELECT NVL (MAX (cl.charge_line_num), 0) + 1
              INTO l_charge_line_num
              FROM inl_charge_lines cl
             WHERE NVL (cl.parent_charge_line_id, cl.charge_line_id) IN
                (
                     SELECT assoc.from_parent_table_id
                       FROM inl_associations assoc
                      WHERE assoc.from_parent_table_name = 'INL_CHARGE_LINES'
                        AND assoc.ship_header_id = NVL (p_ChLn_Assoc.inl_Assoc.ship_header_id, 0)
                ) ;
        END IF;
    ELSE
        l_charge_line_num := p_ChLn_Assoc.charge_line_num;
    END IF;
    --
    -- Get Val to adjustment num
    --
    IF p_ChLn_Assoc.adjustment_num IS NULL THEN
        l_adjustment_num := p_adjustment_num;
    ELSE
        l_adjustment_num := p_ChLn_Assoc.adjustment_num;
    END IF;
    --
    -- Get inl_charge_lines_s.nextval
    --
    l_debug_info := 'Get inl_charge_lines_s.nextval';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_debug_info => l_debug_info
    ) ;
    SELECT inl_charge_lines_s.nextval
    INTO x_new_charge_line_id FROM dual;
    --
    -- include Charge Line record
    --
    l_debug_info := 'Including Charge Line record ';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_debug_info => l_debug_info
    ) ;
     INSERT
       INTO inl_charge_lines
        (
            charge_line_id,                          /* 01 */
            charge_line_num,                         /* 02 */
            charge_line_type_id,                     /* 03 */
            landed_cost_flag,                        /* 04 */
            parent_charge_line_id,                   /* 06 */
            adjustment_num,                          /* 07 */
            match_id,                                /* 08 */
            match_amount_id,                         /* 09 */
            charge_amt,                              /* 11 */
            currency_code,                           /* 12 */
            currency_conversion_type,                /* 13 */
            currency_conversion_date,                /* 14 */
            currency_conversion_rate,                /* 15 */
            party_id,                                /* 16 */
            party_site_id,                           /* 17 */
            trx_business_category,                   /* 18 */
            intended_use,                            /* 19 */
            product_fiscal_class,                    /* 20 */
            product_category,                        /* 21 */
            product_type,                            /* 22 */
            user_def_fiscal_class,                   /* 23 */
            tax_classification_code,                 /* 24 */
            assessable_value,                        /* 25 */
            tax_already_calculated_flag,             /* 26 */
            ship_from_party_id,                      /* 27 */
            ship_from_party_site_id,                 /* 28 */
            ship_to_organization_id,                 /* 29 */
            ship_to_location_id,                     /* 30 */
            bill_from_party_id,                      /* 31 */
            bill_from_party_site_id,                 /* 32 */
            bill_to_organization_id,                 /* 34 */
            bill_to_location_id,                     /* 34 */
            poa_party_id,                            /* 35 */
            poa_party_site_id,                       /* 36 */
            poo_organization_id,                     /* 37 */
            poo_location_id,                         /* 38 */
            created_by,                              /* 39 */
            creation_date,                           /* 40 */
            last_updated_by,                         /* 41 */
            last_update_date,                        /* 42 */
            last_update_login                        /* 43 */
        )
        VALUES
        (
            x_new_charge_line_id,                    /* 01 */
            l_charge_line_num,                       /* 02 */
            p_ChLn_Assoc.charge_line_type_id,        /* 03 */
            p_ChLn_Assoc.landed_cost_flag,           /* 04 */
            p_ChLn_Assoc.parent_charge_line_id,      /* 06 */
            l_adjustment_num,                        /* 07 */
            p_ChLn_Assoc.match_id,                   /* 08 */
            p_ChLn_Assoc.match_amount_id,            /* 09 */
            p_ChLn_Assoc.charge_amt,                 /* 11 */
            p_ChLn_Assoc.currency_code,              /* 12 */
            p_ChLn_Assoc.currency_conversion_type,   /* 13 */
            p_ChLn_Assoc.currency_conversion_date,   /* 14 */
            p_ChLn_Assoc.currency_conversion_rate,   /* 15 */
            p_ChLn_Assoc.party_id,                   /* 16 */
            p_ChLn_Assoc.party_site_id,              /* 17 */
            p_ChLn_Assoc.trx_business_category,      /* 18 */
            p_ChLn_Assoc.intended_use,               /* 19 */
            p_ChLn_Assoc.product_fiscal_class,       /* 20 */
            p_ChLn_Assoc.product_category,           /* 21 */
            p_ChLn_Assoc.product_type,               /* 22 */
            p_ChLn_Assoc.user_def_fiscal_class,      /* 23 */
            p_ChLn_Assoc.tax_classification_code,    /* 24 */
            p_ChLn_Assoc.assessable_value,           /* 25 */
            p_ChLn_Assoc.tax_already_calculated_flag,/* 26 */
            p_ChLn_Assoc.ship_from_party_id,         /* 27 */
            p_ChLn_Assoc.ship_from_party_site_id,    /* 28 */
            p_ChLn_Assoc.ship_to_organization_id,    /* 29 */
            p_ChLn_Assoc.ship_to_location_id,        /* 30 */
            p_ChLn_Assoc.bill_from_party_id,         /* 31 */
            p_ChLn_Assoc.bill_from_party_site_id,    /* 32 */
            p_ChLn_Assoc.bill_to_organization_id,    /* 33 */
            p_ChLn_Assoc.bill_to_location_id,        /* 34 */
            p_ChLn_Assoc.poa_party_id,               /* 35 */
            p_ChLn_Assoc.poa_party_site_id,          /* 36 */
            p_ChLn_Assoc.poo_organization_id,        /* 37 */
            p_ChLn_Assoc.poo_location_id,            /* 38 */
            L_FND_USER_ID,                           /* 39 */
            sysdate,                                 /* 40 */
            L_FND_USER_ID,                           /* 41 */
            sysdate,                                 /* 42 */
            l_fnd_login_id --SCM-051                 /* 43 */
        ) ;
    IF p_include_assoc = 'Y' THEN
        Create_Assoc (
            p_Assoc => p_ChLn_Assoc.inl_Assoc,
            p_from_parent_table_name => 'INL_CHARGE_LINES',
            p_new_line_id => x_new_charge_line_id,
            x_return_status => l_return_status
        );
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    );
EXCEPTION
WHEN L_FND_EXC_ERROR THEN
    -- Standard Expected Error Logging
    INL_LOGGING_PVT.Log_ExpecError(
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    );
    x_return_status := L_FND_RET_STS_ERROR;
WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError(
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    );
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError(
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    );
    x_return_status := L_FND_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level(p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        FND_MSG_PUB.Add_Exc_Msg(
            p_pkg_name => g_pkg_name,
            p_procedure_name => l_program_name
        );
    END IF;
END Create_ChLines;

-- Utility name: Zero_ChLnFromPrevMatchAmt -- BUG#8411594
-- Type       : Private
-- Function   : bring to zero the estimated charge line
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_prev_match_amount_id  IN NUMBER,
--              p_prev_match_id         IN NUMBER,
--              p_adjustment_num        IN NUMBER,
--
-- OUT        : x_return_status         OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Zero_ChLnFromPrevMatchAmt ( --BUG#9474491
    p_prev_match_amount_id  IN NUMBER,--BUG#9474491
    p_prev_match_id         IN NUMBER,--BUG#9804065
    p_adjustment_num        IN NUMBER,
    x_return_status         OUT NOCOPY VARCHAR2
) IS
    l_program_name CONSTANT VARCHAR2(30) := 'Zero_ChLnFromPrevMatchAmt';
    l_return_status VARCHAR2(1);
    l_debug_info VARCHAR2(200);
    CURSOR original_CL
    IS
         SELECT charge_line_num        ,
            charge_line_type_id        ,
            landed_cost_flag           ,
            charge_line_id             ,
            adjustment_num             ,
            match_id                   ,
            currency_code              ,
            currency_conversion_type   ,
            currency_conversion_date   ,
            currency_conversion_rate   ,
            party_id                   ,
            party_site_id              ,
            trx_business_category      ,
            intended_use               ,
            product_fiscal_class       ,
            product_category           ,
            product_type               ,
            user_def_fiscal_class      ,
            tax_classification_code    ,
            tax_already_calculated_flag,
            ship_from_party_id         ,
            ship_from_party_site_id    ,
            ship_to_organization_id    ,
            ship_to_location_id        ,
            bill_from_party_id         ,
            bill_from_party_site_id    ,
            bill_to_organization_id    ,
            bill_to_location_id        ,
            poa_party_id               ,
            poa_party_site_id          ,
            poo_organization_id        ,
            poo_location_id
           FROM inl_charge_lines cl
          WHERE cl.match_Amount_id = p_prev_match_amount_id
          AND cl.match_id IS NULL
        UNION --BUG#9804065
         SELECT charge_line_num        ,
            charge_line_type_id        ,
            landed_cost_flag           ,
            charge_line_id             ,
            adjustment_num             ,
            match_id                   ,
            currency_code              ,
            currency_conversion_type   ,
            currency_conversion_date   ,
            currency_conversion_rate   ,
            party_id                   ,
            party_site_id              ,
            trx_business_category      ,
            intended_use               ,
            product_fiscal_class       ,
            product_category           ,
            product_type               ,
            user_def_fiscal_class      ,
            tax_classification_code    ,
            tax_already_calculated_flag,
            ship_from_party_id         ,
            ship_from_party_site_id    ,
            ship_to_organization_id    ,
            ship_to_location_id        ,
            bill_from_party_id         ,
            bill_from_party_site_id    ,
            bill_to_organization_id    ,
            bill_to_location_id        ,
            poa_party_id               ,
            poa_party_site_id          ,
            poo_organization_id        ,
            poo_location_id
           FROM inl_charge_lines cl
          WHERE p_prev_match_id IS NOT NULL --Bug#14044298
          AND cl.match_id = p_prev_match_id
          AND cl.match_amount_id IS NULL
    ;
    TYPE ori_CL_Type
    IS
    TABLE OF original_CL%ROWTYPE;
    C_ori_CL ori_CL_Type;
    l_ChLn_Assoc inl_ChLn_Assoc_tp;
    l_new_charge_line_id NUMBER;
    l_level_charge_is_applied VARCHAR(5):= 'X';
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    );
    --  Initialize return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => p_prev_match_amount_id,
        p_var_value      => p_prev_match_amount_id
    );
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => p_prev_match_id,
        p_var_value      => p_prev_match_id
    );
    OPEN original_CL;
    FETCH original_CL BULK COLLECT INTO C_ori_CL;
    CLOSE original_CL;
    l_debug_info := C_ori_CL.LAST||' lines have been retrieved.';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_debug_info => l_debug_info
    ) ;
    IF NVL (C_ori_CL.LAST, 0)                        > 0 THEN
        l_ChLn_Assoc.inl_Assoc.allocation_basis     := NULL;
        l_ChLn_Assoc.inl_Assoc.allocation_uom_code  := NULL;
        l_ChLn_Assoc.inl_Assoc.to_parent_table_name := NULL;
        l_ChLn_Assoc.inl_Assoc.to_parent_table_id   := NULL;
        l_ChLn_Assoc.adjustment_num                 := p_adjustment_num;
        l_ChLn_Assoc.match_id                       := p_prev_match_id;   --BUG#9804065
        l_ChLn_Assoc.match_amount_id                := p_prev_match_amount_id;
        l_ChLn_Assoc.charge_amt                     := 0;
        l_ChLn_Assoc.assessable_value               := NULL;
        l_ChLn_Assoc.tax_already_calculated_flag    := 'N';
        FOR i IN NVL(C_ori_CL.FIRST, 0)..NVL(C_ori_CL.LAST, 0)
        LOOP
            l_ChLn_Assoc.charge_line_type_id      := C_ori_CL(i).charge_line_type_id;
            l_ChLn_Assoc.charge_line_num          := C_ori_CL(i).charge_line_num;
            l_ChLn_Assoc.landed_cost_flag         := C_ori_CL(i).landed_cost_flag;
            l_ChLn_Assoc.parent_charge_line_id    := C_ori_CL(i).charge_line_id;
            l_ChLn_Assoc.currency_code            := C_ori_CL(i).currency_code;
            l_ChLn_Assoc.currency_conversion_type := C_ori_CL(i).currency_conversion_type;
            l_ChLn_Assoc.currency_conversion_date := C_ori_CL(i).currency_conversion_date;
            l_ChLn_Assoc.currency_conversion_rate := C_ori_CL(i).currency_conversion_rate;
            l_ChLn_Assoc.party_id                 := C_ori_CL(i).party_id;
            l_ChLn_Assoc.party_site_id            := C_ori_CL(i).party_site_id;
            l_ChLn_Assoc.trx_business_category    := C_ori_CL(i).trx_business_category;
            l_ChLn_Assoc.intended_use             := C_ori_CL(i).intended_use;
            l_ChLn_Assoc.product_fiscal_class     := C_ori_CL(i).product_fiscal_class;
            l_ChLn_Assoc.product_category         := C_ori_CL(i).product_category;
            l_ChLn_Assoc.product_type             := C_ori_CL(i).product_type;
            l_ChLn_Assoc.user_def_fiscal_class    := C_ori_CL(i).user_def_fiscal_class;
            l_ChLn_Assoc.tax_classification_code  := C_ori_CL(i).tax_classification_code;
            l_ChLn_Assoc.ship_from_party_id       := C_ori_CL(i).ship_from_party_id;
            l_ChLn_Assoc.ship_from_party_site_id  := C_ori_CL(i).ship_from_party_site_id;
            l_ChLn_Assoc.ship_to_organization_id  := C_ori_CL(i).ship_to_organization_id;
            l_ChLn_Assoc.ship_to_location_id      := C_ori_CL(i).ship_to_location_id;
            l_ChLn_Assoc.bill_from_party_id       := C_ori_CL(i).bill_from_party_id;
            l_ChLn_Assoc.bill_from_party_site_id  := C_ori_CL(i).bill_from_party_site_id;
            l_ChLn_Assoc.bill_to_organization_id  := C_ori_CL(i).bill_to_organization_id;
            l_ChLn_Assoc.bill_to_location_id      := C_ori_CL(i).bill_to_location_id;
            l_ChLn_Assoc.poa_party_id             := C_ori_CL(i).poa_party_id;
            l_ChLn_Assoc.poa_party_site_id        := C_ori_CL(i).poa_party_site_id;
            l_ChLn_Assoc.poo_organization_id      := C_ori_CL(i).poo_organization_id;
            l_ChLn_Assoc.poo_location_id          := C_ori_CL(i).poo_location_id;
            -- Create_ChLines
            l_debug_info                                 := 'Create_ChLines';
            INL_LOGGING_PVT.Log_Statement (
                p_module_name => g_module_name,
                p_procedure_name => l_program_name,
                p_debug_info => l_debug_info
            ) ;
            Create_ChLines (
                p_ChLn_Assoc => l_ChLn_Assoc,
                p_include_assoc => 'N',
                p_adjustment_num => p_adjustment_num,
                x_new_charge_line_id => l_new_charge_line_id,
                x_return_status => l_return_status
            ) ;
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
            -- TxLines
            l_debug_info  := 'Amount = 0 for estimated taxes associated with estimated charge';
            INL_LOGGING_PVT.Log_Statement (
                p_module_name => g_module_name,
                p_procedure_name => l_program_name,
                p_debug_info => l_debug_info
            ) ;
            Zero_EstimTaxLines (
                p_ship_header_id        => NULL,
                p_match_id              => NULL,
                p_comp_name             => 'INL_CHARGE_LINES',
                p_comp_id               => C_ori_CL(i).charge_line_id,
                p_tax_code              => NULL,
                p_adjustment_num        => p_adjustment_num,
                p_prev_adjustment_num   => C_ori_CL(i).adjustment_num,
                x_return_status         => l_return_status
            ) ;
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END LOOP;
    END IF;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    ) ;
EXCEPTION
WHEN L_FND_EXC_ERROR THEN
    -- Standard Expected Error Logging
    INL_LOGGING_PVT.Log_ExpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    ) ;
    x_return_status := L_FND_RET_STS_ERROR;
WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    ) ;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    ) ;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level (p_message_level  => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg (
            p_pkg_name => g_pkg_name,
            p_procedure_name => l_program_name
        ) ;
    END IF;
END Zero_ChLnFromPrevMatchAmt;

-- Utility name: Zero_EstimChargeLinesPerMatch
-- Type       : Private
-- Function   : bring to zero the estimated charge line
-- Pre-reqs   : None
-- Parameters :
-- IN         :     p_match_id              IN NUMBER,
--                  p_match_Amount_id       IN NUMBER,
--                  p_charge_line_type_id   IN NUMBER,
--
-- OUT        : x_return_status         OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Zero_EstimChargeLinesPerMatch (
    p_match_id              IN NUMBER,
    p_match_Amount_id       IN NUMBER,
    p_charge_line_type_id   IN NUMBER,
    p_adjustment_num        IN NUMBER,
    x_return_status         OUT NOCOPY VARCHAR2
) IS
    l_program_name CONSTANT VARCHAR2(30) := 'Zero_EstimChargeLinesPerMatch';
    l_return_status VARCHAR2(1);
    l_debug_info VARCHAR2(200);

--Bug#9474491
    CURSOR estimated_CL
    IS
         SELECT distinct --Bug#9804065
            cl.charge_line_num        ,
            cl.charge_line_type_id        ,
            cl.landed_cost_flag           ,
            cl.charge_line_id             ,
            cl.adjustment_num             ,
            cl.match_id                   ,
            cl.currency_code              ,
            cl.currency_conversion_type   ,
            cl.currency_conversion_date   ,
            cl.currency_conversion_rate   ,
            cl.party_id                   ,
            cl.party_site_id              ,
            cl.trx_business_category      ,
            cl.intended_use               ,
            cl.product_fiscal_class       ,
            cl.product_category           ,
            cl.product_type               ,
            cl.user_def_fiscal_class      ,
            cl.tax_classification_code    ,
            cl.tax_already_calculated_flag,
            cl.ship_from_party_id         ,
            cl.ship_from_party_site_id    ,
            cl.ship_to_organization_id    ,
            cl.ship_to_location_id        ,
            cl.bill_from_party_id         ,
            cl.bill_from_party_site_id    ,
            cl.bill_to_organization_id    ,
            cl.bill_to_location_id        ,
            cl.poa_party_id               ,
            cl.poa_party_site_id          ,
            cl.poo_organization_id        ,
            cl.poo_location_id
    FROM inl_adj_charge_lines_v cl,
        inl_associations a,
        inl_matches m
    WHERE
        ((cl.match_id IS NULL
            AND cl.match_amount_id IS NULL)
         OR
         cl.adjustment_num < 0) -- SCM-051
    AND NVL(cl.charge_amt,0) <> 0
    AND a.from_parent_table_name = 'INL_CHARGE_LINES'
    AND a.ship_header_id  = m.ship_header_id
    AND a.from_parent_table_id
      = (SELECT
            cl1.charge_line_id
         FROM
            inl_charge_lines cl1
         WHERE
         CONNECT_BY_ISLEAF = 1
         START WITH cl1.charge_line_id = cl.charge_line_id
         CONNECT BY PRIOR cl1.parent_charge_line_id = cl1.charge_line_id)
    AND cl.charge_line_type_id = p_charge_line_type_id
    AND (
            m.match_id = p_match_id
            OR m.match_amount_id = p_match_amount_id
        )

    AND (
            (m.to_parent_table_name = 'INL_SHIP_HEADERS'
             AND a.to_parent_table_name = 'INL_SHIP_HEADERS'
             AND m.ship_header_id = a.ship_header_id)
            OR
            (m.to_parent_table_name = 'INL_SHIP_LINE_GROUPS'
             AND m.ship_header_id = a.ship_header_id
             AND (a.to_parent_table_name = 'INL_SHIP_HEADERS'
                  OR (a.to_parent_table_name = 'INL_SHIP_LINE_GROUPS'
                      AND a.to_parent_table_id = m.to_parent_table_id)
                )
            )
            OR
            (m.to_parent_table_name = 'INL_SHIP_LINES'
             AND m.ship_header_id = a.ship_header_id
             AND (a.to_parent_table_name = 'INL_SHIP_HEADERS'
                  OR (a.to_parent_table_name = 'INL_SHIP_LINE_GROUPS'
                      AND EXISTS (SELECT 1
                                  FROM inl_ship_lines sl
                                  WHERE sl.ship_line_id = m.to_parent_table_id -- the match ship line
                                  AND sl.ship_line_group_id =  a.to_parent_table_id --belong to group of association
                                  )
                    )
                  OR (a.to_parent_table_name = 'INL_SHIP_LINES'
                      AND m.to_parent_table_id = a.to_parent_table_id
                     )
                )
            )
        )
        ;
--Bug#9474491
    TYPE est_CL_Type
    IS
    TABLE OF estimated_CL%ROWTYPE;
    C_est_CL est_CL_Type;
    l_ChLn_Assoc inl_ChLn_Assoc_tp;
    l_new_charge_line_id NUMBER;
    l_level_charge_is_applied VARCHAR(5):= 'X';
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    );
    --  Initialize return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;
    l_debug_info := 'Getting the maximum level where this charge_line_type_id is applied.';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_debug_info => l_debug_info
    ) ;
    l_debug_info := 'p_match_Amount_id';
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => l_debug_info,
        p_var_value      => p_match_Amount_id
    );
    OPEN estimated_CL ;
    FETCH estimated_CL BULK COLLECT INTO C_est_CL;
    CLOSE estimated_CL;
    l_debug_info := C_est_CL.LAST||' lines have been retrieved.';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_debug_info => l_debug_info
    ) ;
    IF NVL (C_est_CL.LAST, 0)                        > 0 THEN
        l_ChLn_Assoc.inl_Assoc.allocation_basis     := NULL;
        l_ChLn_Assoc.inl_Assoc.allocation_uom_code  := NULL;
        l_ChLn_Assoc.inl_Assoc.to_parent_table_name := NULL;
        l_ChLn_Assoc.inl_Assoc.to_parent_table_id   := NULL;
        l_ChLn_Assoc.adjustment_num                 := p_adjustment_num;
        l_ChLn_Assoc.match_id                       := p_match_id;
        l_ChLn_Assoc.match_amount_id                := p_match_amount_id;
        l_ChLn_Assoc.charge_line_type_id            := p_charge_line_type_id;
        l_ChLn_Assoc.charge_amt                     := 0;
        l_ChLn_Assoc.assessable_value               := NULL;
        l_ChLn_Assoc.tax_already_calculated_flag    := 'N';
        FOR i                                       IN NVL (C_est_CL.FIRST, 0) ..NVL (C_est_CL.LAST, 0)
        LOOP

            INL_LOGGING_PVT.Log_Variable (
                p_module_name    => g_module_name,
                p_procedure_name => l_program_name,
                p_var_name       => 'C_est_CL ('||i||') .charge_line_id',
                p_var_value      => C_est_CL (i) .charge_line_id
            );
            l_ChLn_Assoc.charge_line_num          := C_est_CL (i) .charge_line_num;
            l_ChLn_Assoc.landed_cost_flag         := C_est_CL (i) .landed_cost_flag;
            l_ChLn_Assoc.parent_charge_line_id    := C_est_CL (i) .charge_line_id;
            l_ChLn_Assoc.currency_code            := C_est_CL (i) .currency_code;
            l_ChLn_Assoc.currency_conversion_type := C_est_CL (i) .currency_conversion_type;
            l_ChLn_Assoc.currency_conversion_date := C_est_CL (i) .currency_conversion_date;
            l_ChLn_Assoc.currency_conversion_rate := C_est_CL (i) .currency_conversion_rate;
            l_ChLn_Assoc.party_id                 := C_est_CL (i) .party_id;
            l_ChLn_Assoc.party_site_id            := C_est_CL (i) .party_site_id;
            l_ChLn_Assoc.trx_business_category    := C_est_CL (i) .trx_business_category;
            l_ChLn_Assoc.intended_use             := C_est_CL (i) .intended_use;
            l_ChLn_Assoc.product_fiscal_class     := C_est_CL (i) .product_fiscal_class;
            l_ChLn_Assoc.product_category         := C_est_CL (i) .product_category;
            l_ChLn_Assoc.product_type             := C_est_CL (i) .product_type;
            l_ChLn_Assoc.user_def_fiscal_class    := C_est_CL (i) .user_def_fiscal_class;
            l_ChLn_Assoc.tax_classification_code  := C_est_CL (i) .tax_classification_code;
            l_ChLn_Assoc.ship_from_party_id       := C_est_CL (i) .ship_from_party_id;
            l_ChLn_Assoc.ship_from_party_site_id  := C_est_CL (i) .ship_from_party_site_id;
            l_ChLn_Assoc.ship_to_organization_id  := C_est_CL (i) .ship_to_organization_id;
            l_ChLn_Assoc.ship_to_location_id      := C_est_CL (i) .ship_to_location_id;
            l_ChLn_Assoc.bill_from_party_id       := C_est_CL (i) .bill_from_party_id;
            l_ChLn_Assoc.bill_from_party_site_id  := C_est_CL (i) .bill_from_party_site_id;
            l_ChLn_Assoc.bill_to_organization_id  := C_est_CL (i) .bill_to_organization_id;
            l_ChLn_Assoc.bill_to_location_id      := C_est_CL (i) .bill_to_location_id;
            l_ChLn_Assoc.poa_party_id             := C_est_CL (i) .poa_party_id;
            l_ChLn_Assoc.poa_party_site_id        := C_est_CL (i) .poa_party_site_id;
            l_ChLn_Assoc.poo_organization_id      := C_est_CL (i) .poo_organization_id;
            l_ChLn_Assoc.poo_location_id          := C_est_CL (i) .poo_location_id;
            -- Create_ChLines
            l_debug_info                                 := 'Create_ChLines';
            INL_LOGGING_PVT.Log_Statement (
                p_module_name => g_module_name,
                p_procedure_name => l_program_name,
                p_debug_info => l_debug_info
            ) ;
            Create_ChLines (
                p_ChLn_Assoc => l_ChLn_Assoc,
                p_include_assoc => 'N',
                p_adjustment_num => p_adjustment_num,
                x_new_charge_line_id => l_new_charge_line_id,
                x_return_status => l_return_status
            ) ;
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
            -- TxLines
            l_debug_info  := 'Amount = 0 for estimated taxes associated with estimated charge';
            INL_LOGGING_PVT.Log_Statement (
                p_module_name => g_module_name,
                p_procedure_name => l_program_name,
                p_debug_info => l_debug_info
            ) ;
            Zero_EstimTaxLines (
                p_ship_header_id  => NULL,
                p_match_id => p_match_id,
                p_comp_name => 'INL_CHARGE_LINES',
                p_comp_id => C_est_CL (i) .charge_line_id,
                p_tax_code => NULL,
                p_adjustment_num => p_adjustment_num,
                x_return_status => l_return_status
            ) ;
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END LOOP;
    END IF;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    ) ;
EXCEPTION
WHEN L_FND_EXC_ERROR THEN
    -- Standard Expected Error Logging
    INL_LOGGING_PVT.Log_ExpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    ) ;
    x_return_status := L_FND_RET_STS_ERROR;
WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    ) ;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    ) ;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level (p_message_level  => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg (
            p_pkg_name => g_pkg_name,
            p_procedure_name => l_program_name
        ) ;
    END IF;
END Zero_EstimChargeLinesPerMatch;

-- BUG#9474491
-- Utility name: Create_NewEstimChLinesPerMatch
-- Type       : Private
-- Function   : Create new estimated lines in case of, after creating an adjustment, a given tax (or cost factor) becomes zero,
-- then the estimated tax (or cost factor) should come back as the current adjustment amount.
-- This new estimated lines should have NULL value in match_id and match_amount_id but with this we'll be unable to know about the match
-- that has generated this new charge lines
-- Pre-reqs   : None
-- Parameters :
-- IN         :     p_match_id              IN NUMBER,
--                  p_match_Amount_id       IN NUMBER,
--                  p_charge_line_type_id   IN NUMBER,
--
-- OUT        : x_return_status         OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Create_NewEstimChLinesPerMatch (
    p_match_id              IN NUMBER,
    p_match_Amount_id       IN NUMBER,
    p_charge_line_type_id   IN NUMBER,
    p_adjustment_num        IN NUMBER,
    x_return_status         OUT NOCOPY VARCHAR2
) IS
    l_program_name CONSTANT VARCHAR2(30) := 'Create_NewEstimChLinesPerMatch';
    l_return_status VARCHAR2(1);
    l_debug_info VARCHAR2(200);

    l_created_chLnId    NUMBER;
    l_created_chLnAmt   NUMBER;
    l_sum_chLnAmt       NUMBER;
    l_alc_zero          NUMBER; --Bug#11064618

    CURSOR c_affected_ship (pc_charge_line_id NUMBER)
    IS
        SELECT
            a.ship_header_id      ,
            a.to_parent_table_name,
            a.to_parent_table_id
        FROM
            inl_associations a
        WHERE
            a.from_parent_table_name = 'INL_CHARGE_LINES'
        AND a.from_parent_table_id   = pc_charge_line_id
    ;

    TYPE affected_ship_Type
        IS
        TABLE OF c_affected_ship%ROWTYPE INDEX BY BINARY_INTEGER;

    affected_by_alc_ship_lst affected_ship_Type;
    affected_by_elc_lst affected_ship_Type;

    CURSOR c_ELC_CLines (pc_ship_line_id NUMBER)
    IS
        SELECT
            cl.adjustment_num             ,
            cl.charge_line_id             ,
            cl.parent_charge_line_id      ,
            cl.charge_line_num            ,
            cl.landed_cost_flag           ,
            cl.update_allowed             ,
            cl.source_code                ,
            cl.charge_amt                 ,
            cl.currency_code              ,
            cl.currency_conversion_type   ,
            cl.currency_conversion_date   ,
            cl.currency_conversion_rate   ,
            cl.party_id                   ,
            cl.party_site_id              ,
            cl.trx_business_category      ,
            cl.intended_use               ,
            cl.product_fiscal_class       ,
            cl.product_category           ,
            cl.product_type               ,
            cl.user_def_fiscal_class      ,
            cl.tax_classification_code    ,
            cl.assessable_value           ,
            cl.tax_already_calculated_flag,
            cl.ship_from_party_id         ,
            cl.ship_from_party_site_id    ,
            cl.ship_to_organization_id    ,
            cl.ship_to_location_id        ,
            cl.bill_from_party_id         ,
            cl.bill_from_party_site_id    ,
            cl.bill_to_organization_id    ,
            cl.bill_to_location_id        ,
            cl.poa_party_id               ,
            cl.poa_party_site_id          ,
            cl.poo_organization_id        ,
            cl.poo_location_id            ,
            a.to_parent_table_name        ,
            a.to_parent_table_id
        FROM
            inl_charge_lines cl,
            inl_associations a,
            inl_ship_lines_all sl,
            inl_ship_line_groups slg,
            inl_ship_headers_all sh
        WHERE
            cl.adjustment_num        = 0
        AND a.from_parent_table_name = 'INL_CHARGE_LINES'
        AND a.from_parent_table_id   = cl.charge_line_id
        AND cl.charge_line_type_id    = p_charge_line_type_id
        AND a.ship_header_id         = sl.ship_header_id
        AND ((a.to_parent_table_name   = 'INL_SHIP_LINES'
              AND a.to_parent_table_id = sl.ship_line_id)
              OR
             (a.to_parent_table_name   = 'INL_SHIP_LINE_GROUPS'
              AND a.to_parent_table_id = sl.ship_line_group_id)
              OR
             (a.to_parent_table_name   = 'INL_SHIP_HEADERS'
              AND a.to_parent_table_id = sl.ship_header_id))
        AND sh.ship_header_id      = sl.ship_header_id
        AND slg.ship_line_group_id = sl.ship_line_group_id
        AND sl.ship_line_id        = pc_ship_line_id
        ;
    TYPE ELC_CLines_Type
        IS
        TABLE OF c_ELC_CLines%ROWTYPE INDEX BY BINARY_INTEGER;

    ELC_CLines_lst ELC_CLines_Type;
    l_ELC_ShouldBeCreatedFlag VARCHAR2(1);
    l_last_parentChargeLineID NUMBER;
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    );
    --  Initialize return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;

    -- - There isn't a link with the previous match_id/match_amount_id (the one that is being reverted).
    -- - Each match or match amount generate one charge line.
    -- - An action could be required when:
    --      - this new charge is negative
    --      - The sum of charge lines, with the same cost factor, in each point that it is being applyed, become 0
    --      - There was estimated charge line with the same cost factor applyed to the current line
    --      - There wasn't any actual value, with the same cost factor, in each point that it is being applyed.


    l_debug_info := ' Getting charge line information.';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_debug_info => l_debug_info
    ) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_match_id',
        p_var_value => p_match_id
    ) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_match_Amount_id',
        p_var_value => p_match_Amount_id
    ) ;
--Bug#11064618
/*
    IF p_match_id IS NOT NULL THEN

        SELECT
            cl.charge_line_id,
            cl.charge_amt
        INTO
            l_created_chLnId,
            l_created_chLnAmt
        FROM
            inl_charge_lines cl
        WHERE
            cl.match_id = p_match_id
        AND cl.charge_amt <> 0 --BUG#9804065  --discards lines to zeroes estimated
        ;
    ELSE

        SELECT
            cl.charge_line_id,
            cl.charge_amt
        INTO
            l_created_chLnId,
            l_created_chLnAmt
        FROM
            inl_charge_lines cl
        WHERE
            cl.match_Amount_id = p_match_Amount_id
        AND cl.charge_amt <> 0 --BUG#9804065 -- discards lines to zeroes estimated
        ;

    END IF;
*/
    SELECT
            cl.charge_line_id,
            cl.charge_amt
    INTO
            l_created_chLnId,
            l_created_chLnAmt
    FROM
            inl_charge_lines cl
    WHERE
        ((p_match_id IS NOT NULL
          AND cl.match_id = p_match_id)
             OR
         (p_match_Amount_id  IS NOT NULL
          AND cl.match_Amount_id = p_match_Amount_id))
    AND (cl.parent_charge_line_id IS NULL
--         OR 0 not in
         OR 0 < --SCM-051
            (SELECT
                cl1.adjustment_num
             FROM
                inl_charge_lines cl1
             WHERE
                 CONNECT_BY_ISLEAF = 1
             START WITH cl1.charge_line_id = cl.charge_line_id
             CONNECT BY PRIOR cl1.parent_charge_line_id = cl1.charge_line_id));
-- when a invoice with amt = 0 is canceled we are unable to redo the ELC
--Bug#11064618


    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'l_created_chLnId',
        p_var_value => l_created_chLnId
    ) ;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'l_created_chLnAmt',
        p_var_value => l_created_chLnAmt
    ) ;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_charge_line_type_id',
        p_var_value => p_charge_line_type_id
    ) ;

    -- is the current charge line negative?
    IF l_created_chLnAmt < 0 THEN

        -- get all points affected by current charge line
        OPEN c_affected_ship(l_created_chLnId);
        FETCH c_affected_ship BULK COLLECT INTO affected_by_alc_ship_lst;
        CLOSE c_affected_ship;

        l_debug_info := 'affected_by_alc: '||affected_by_alc_ship_lst.LAST||' line(s) have been retrieved.';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_program_name,
            p_debug_info => l_debug_info
        ) ;
        IF NVL (affected_by_alc_ship_lst.LAST, 0) > 0 THEN

            -- Go down in all points where charge line is applied
            -- in case of Actuals the point is ever a ship_line
            FOR i IN NVL (affected_by_alc_ship_lst.FIRST, 0)..NVL (affected_by_alc_ship_lst.LAST, 0)
            LOOP
                INL_LOGGING_PVT.Log_Variable (
                    p_module_name => g_module_name,
                    p_procedure_name => l_program_name,
                    p_var_name => 'affected_by_alc_ship_lst('||i||').ship_header_id',
                    p_var_value => affected_by_alc_ship_lst(i).ship_header_id
                ) ;

                INL_LOGGING_PVT.Log_Variable (
                    p_module_name => g_module_name,
                    p_procedure_name => l_program_name,
                    p_var_name => 'affected_by_alc_ship_lst('||i||').to_parent_table_name',
                    p_var_value => affected_by_alc_ship_lst(i).to_parent_table_name
                ) ;

                INL_LOGGING_PVT.Log_Variable (
                    p_module_name => g_module_name,
                    p_procedure_name => l_program_name,
                    p_var_name => 'affected_by_alc_ship_lst('||i||').to_parent_table_id',
                    p_var_value => affected_by_alc_ship_lst(i).to_parent_table_id
                ) ;

--                affected_by_alc_ship_lst.inl_Assoc.ship_header_id := affected_by_alc_ship_lst(i).ship_header_id;

                -- CURRENTLY ALL ASSOCIATIONS OF ACTUALS ARE MADE AT LINE LEVEL
                IF affected_by_alc_ship_lst(i).to_parent_table_name <> 'INL_SHIP_LINES' THEN

                    l_debug_info  := 'Problem in INL SHIPMENT PVT regarding canceled invoice applied at a level different from line';
                    INL_LOGGING_PVT.Log_Statement (
                        p_module_name => g_module_name,
                        p_procedure_name => l_program_name,
                        p_debug_info => l_debug_info
                    ) ;
                    RAISE L_FND_EXC_ERROR;
                END IF;

                -- sum all charge lines that come to each point
/* BEGIN BUG#16286469
                SELECT
                    SUM(cl.charge_amt)
                INTO
                    l_sum_chLnAmt
                FROM
                    inl_adj_charge_lines_v cl,
                    inl_adj_associations_v a, --BUG#9804065
                    inl_ship_lines_all sl,
                    inl_ship_line_groups slg,
                    inl_ship_headers_all sh
                WHERE
                    a.ship_header_id         = sl.ship_header_id
                AND cl.charge_line_type_id   = p_charge_line_type_id --same cost factor
                AND ((a.to_parent_table_name   = 'INL_SHIP_LINES'
                      AND a.to_parent_table_id = sl.ship_line_id)
                      OR
                     (a.to_parent_table_name   = 'INL_SHIP_LINE_GROUPS'
                      AND a.to_parent_table_id = sl.ship_line_group_id)
                      OR
                     (a.to_parent_table_name   = 'INL_SHIP_HEADERS'
                      AND a.to_parent_table_id = sl.ship_header_id))
                AND sh.ship_header_id      = sl.ship_header_id
                AND slg.ship_line_group_id = sl.ship_line_group_id
                AND sl.ship_line_id        = affected_by_alc_ship_lst(i).to_parent_table_id
                AND a.from_parent_table_name = 'INL_CHARGE_LINES'
                AND a.from_parent_table_id   = cl.charge_line_id
                ;
*/
                SELECT SUM(cl.charge_amt)
                INTO
                    l_sum_chLnAmt
                FROM inl_adj_charge_lines_v cl,           --Bug#16951712 (problem detected during tests, ELC was not being recreated when item line had adj)
                     (SELECT a2.ship_header_id,
                             a2.from_parent_table_id,
                             sl.ship_line_group_id,
                             a2.to_parent_table_name,
                             a2.to_parent_table_id
--                      FROM inl_adj_associations_v a2,  --Bug#16951712 (problem detected during tests, ELC was not being recreated when item line had adj)
                      FROM inl_associations a2,          --Bug#16951712
                           inl_ship_lines_all sl
                      WHERE a2.ship_header_id = sl.ship_header_id
                      AND a2.from_parent_table_name = 'INL_CHARGE_LINES'
                      AND sl.ship_line_id           = affected_by_alc_ship_lst(i).to_parent_table_id) a
                WHERE cl.charge_line_type_id = p_charge_line_type_id
                AND DECODE(a.to_parent_table_name,'INL_SHIP_LINES',affected_by_alc_ship_lst(i).to_parent_table_id,
                                                  'INL_SHIP_LINE_GROUPS',a.ship_line_group_id,
                                                  'INL_SHIP_HEADERS',a.ship_header_id,affected_by_alc_ship_lst(i).to_parent_table_id)
                                                  = a.to_parent_table_id
                AND a.from_parent_table_id  = cl.charge_line_id;
-- END BUG#16286469

                l_debug_info  := 'Sum all charge lines that come to this point: '||l_sum_chLnAmt;
                INL_LOGGING_PVT.Log_Statement (
                    p_module_name => g_module_name,
                    p_procedure_name => l_program_name,
                    p_debug_info => l_debug_info
                ) ;

                -- Verify if sum of lines with the same cost factor become 0
                IF l_sum_chLnAmt = 0 THEN --without nvl

                    -- Verify if exist any actual with amount = 0 coming to this point
                    --Bug#11064618

                    l_debug_info  := 'Verify if exist any actual with amount = 0 coming to this point ';
                    INL_LOGGING_PVT.Log_Statement (
                        p_module_name => g_module_name,
                        p_procedure_name => l_program_name,
                        p_debug_info => l_debug_info
                    ) ;

                    SELECT
                            COUNT(*)
                    INTO
                            l_alc_zero
                    FROM
                            inl_charge_lines cl,
                            inl_associations assoc
                    WHERE
                        assoc.to_parent_table_id = affected_by_alc_ship_lst(i).to_parent_table_id
                    AND assoc.to_parent_table_name = 'INL_SHIP_LINES'
                    AND assoc.from_parent_table_name = 'INL_CHARGE_LINES'
                    AND assoc.from_parent_table_id = cl.charge_line_id
                    AND cl.charge_line_type_id   = p_charge_line_type_id --same cost factor
                    AND cl.charge_amt = 0
                    AND (cl.parent_charge_line_id IS NULL
                         OR 0 not in
                            (SELECT
                                cl1.adjustment_num
                             FROM
                                inl_charge_lines cl1
                             WHERE
                                 CONNECT_BY_ISLEAF = 1
                             START WITH cl1.charge_line_id = cl.charge_line_id
                             CONNECT BY PRIOR cl1.parent_charge_line_id = cl1.charge_line_id));
                    IF NVL(l_alc_zero,0) = 0 THEN
                    --Bug#11064618

                        -- Get all ELC that came to this point

                        OPEN c_ELC_CLines(affected_by_alc_ship_lst(i).to_parent_table_id);
                        FETCH c_ELC_CLines BULK COLLECT INTO ELC_CLines_lst;
                        CLOSE c_ELC_CLines;

                        l_debug_info := ELC_CLines_lst.LAST||' line(s) have been retrieved (ELC_CLines_lst).';
                        INL_LOGGING_PVT.Log_Statement (
                            p_module_name => g_module_name,
                            p_procedure_name => l_program_name,
                            p_debug_info => l_debug_info
                        ) ;
                        IF NVL (ELC_CLines_lst.LAST, 0) > 0 THEN

                            FOR j IN NVL (ELC_CLines_lst.FIRST, 0)..NVL (ELC_CLines_lst.LAST, 0)
                            LOOP

                                l_ELC_ShouldBeCreatedFlag := 'Y';

                                INL_LOGGING_PVT.Log_Variable (
                                    p_module_name => g_module_name,
                                    p_procedure_name => l_program_name,
                                    p_var_name => 'ELC_CLines_lst('||j||').to_parent_table_name',
                                    p_var_value => ELC_CLines_lst(j).to_parent_table_name
                                ) ;

                                INL_LOGGING_PVT.Log_Variable (
                                    p_module_name => g_module_name,
                                    p_procedure_name => l_program_name,
                                    p_var_name => 'ELC_CLines_lst('||j||').to_parent_table_id',
                                    p_var_value => ELC_CLines_lst(j).to_parent_table_id
                                ) ;

                                INL_LOGGING_PVT.Log_Variable (
                                    p_module_name => g_module_name,
                                    p_procedure_name => l_program_name,
                                    p_var_name => 'ELC_CLines_lst('||j||').adjustment_num',
                                    p_var_value => ELC_CLines_lst(j).adjustment_num
                                ) ;

                                INL_LOGGING_PVT.Log_Variable (
                                    p_module_name => g_module_name,
                                    p_procedure_name => l_program_name,
                                    p_var_name => 'ELC_CLines_lst('||j||').charge_line_num',
                                    p_var_value => ELC_CLines_lst(j).charge_line_num
                                ) ;

                                INL_LOGGING_PVT.Log_Variable (
                                    p_module_name => g_module_name,
                                    p_procedure_name => l_program_name,
                                    p_var_name => 'ELC_CLines_lst('||j||').charge_amt',
                                    p_var_value => ELC_CLines_lst(j).charge_amt
                                ) ;

                                -- To each ELC verify if exist any ALC


                                -- get all points affected by current charge line
                                OPEN c_affected_ship(ELC_CLines_lst(j).charge_line_id);
                                FETCH c_affected_ship BULK COLLECT INTO affected_by_elc_lst;
                                CLOSE c_affected_ship;

                                l_debug_info := 'Affected_by_elc '||affected_by_elc_lst.LAST||' line(s) have been retrieved.';
                                INL_LOGGING_PVT.Log_Statement (
                                    p_module_name => g_module_name,
                                    p_procedure_name => l_program_name,
                                    p_debug_info => l_debug_info
                                ) ;
                                IF NVL (affected_by_elc_lst.LAST, 0) > 0 THEN

                                    -- Go down in all points where charge line is applied
                                    FOR k IN NVL (affected_by_elc_lst.FIRST, 0)..NVL (affected_by_elc_lst.LAST, 0)
                                    LOOP
                                        INL_LOGGING_PVT.Log_Variable (
                                            p_module_name => g_module_name,
                                            p_procedure_name => l_program_name,
                                            p_var_name => 'affected_by_elc_lst('||k||').ship_header_id',
                                            p_var_value => affected_by_elc_lst(k).ship_header_id
                                        ) ;

                                        INL_LOGGING_PVT.Log_Variable (
                                            p_module_name => g_module_name,
                                            p_procedure_name => l_program_name,
                                            p_var_name => 'affected_by_elc_lst('||k||').to_parent_table_name',
                                            p_var_value => affected_by_elc_lst(k).to_parent_table_name
                                        ) ;

                                        INL_LOGGING_PVT.Log_Variable (
                                            p_module_name => g_module_name,
                                            p_procedure_name => l_program_name,
                                            p_var_name => 'affected_by_elc_lst('||k||').to_parent_table_id',
                                            p_var_value => affected_by_elc_lst(k).to_parent_table_id
                                        ) ;

                                        -- Search for an actual for this cost factor
                                        IF affected_by_elc_lst(k).to_parent_table_name = 'INL_SHIP_HEADERS' then
                                            SELECT
                                                SUM(cl.charge_amt)
                                            INTO
                                                l_sum_chLnAmt
                                            FROM
                                                inl_adj_charge_lines_v cl,
                                                inl_associations a
                                            WHERE
                                                a.ship_header_id         = affected_by_elc_lst(k).ship_header_id
                                            AND cl.charge_line_type_id   = p_charge_line_type_id --same cost factor
                                            AND NVL(cl.match_id,cl.match_amount_id) IS NOT NULL --only ALC
                                            AND a.from_parent_table_name = 'INL_CHARGE_LINES'
                                            AND a.from_parent_table_id   = cl.charge_line_id
                                            ;

--Bug#11064618
                                            l_debug_info  := 'Verify if exist any actual with amount = 0 coming to this HEADER ';
                                            INL_LOGGING_PVT.Log_Statement (
                                                p_module_name => g_module_name,
                                                p_procedure_name => l_program_name,
                                                p_debug_info => l_debug_info
                                            ) ;

                                            SELECT
                                                    COUNT(*)
                                            INTO
                                                    l_alc_zero
                                            FROM
                                                    inl_charge_lines cl,
                                                    inl_associations assoc
                                            WHERE
                                                assoc.ship_header_id         = affected_by_elc_lst(k).ship_header_id
                                            AND assoc.to_parent_table_name = 'INL_SHIP_LINES'
                                            AND assoc.from_parent_table_name = 'INL_CHARGE_LINES'
                                            AND assoc.from_parent_table_id = cl.charge_line_id
                                            AND cl.charge_amt = 0
                                            AND cl.charge_line_type_id = p_charge_line_type_id --same cost factor
                                            AND NVL(cl.match_id,cl.match_amount_id) IS NOT NULL --only ALC
                                            AND (cl.parent_charge_line_id IS NULL
                                                 OR 0 not in
                                                    (SELECT
                                                        cl1.adjustment_num
                                                     FROM
                                                        inl_charge_lines cl1
                                                     WHERE
                                                         CONNECT_BY_ISLEAF = 1
                                                     START WITH cl1.charge_line_id = cl.charge_line_id
                                                     CONNECT BY PRIOR cl1.parent_charge_line_id = cl1.charge_line_id));
--Bug#11064618

                                        ELSIF affected_by_elc_lst(k).to_parent_table_name = 'INL_SHIP_LINE_GROUPS' then
                                            SELECT
                                                SUM(cl.charge_amt)
                                            INTO
                                                l_sum_chLnAmt
                                            FROM
                                                inl_adj_charge_lines_v cl,
                                                inl_associations a
                                            WHERE
                                                a.ship_header_id         = affected_by_elc_lst(k).ship_header_id
                                            AND cl.charge_line_type_id   = p_charge_line_type_id --same cost factor
                                            AND NVL(cl.match_id,cl.match_amount_id) IS NOT NULL --only ALC
                                            AND  EXISTS (SELECT 1
                                                         FROM inl_ship_lines_all sl
                                                         WHERE sl.ship_line_id     = a.to_parent_table_id
                                                         AND sl.ship_header_id     = affected_by_elc_lst(k).ship_header_id
                                                         AND sl.ship_line_group_id = affected_by_elc_lst(k).to_parent_table_id
                                                         AND ROWNUM < 2)
                                            AND a.from_parent_table_name = 'INL_CHARGE_LINES'
                                            AND a.from_parent_table_id   = cl.charge_line_id
                                            ;

--Bug#11064618
                                            l_debug_info  := 'Verify if exist any actual with amount = 0 coming to this GROUP ';
                                            INL_LOGGING_PVT.Log_Statement (
                                                p_module_name => g_module_name,
                                                p_procedure_name => l_program_name,
                                                p_debug_info => l_debug_info
                                            ) ;

                                            SELECT
                                                    COUNT(*)
                                            INTO
                                                    l_alc_zero
                                            FROM
                                                    inl_charge_lines cl,
                                                    inl_associations assoc
                                            WHERE
                                                assoc.ship_header_id         = affected_by_elc_lst(k).ship_header_id
                                            AND assoc.to_parent_table_name = 'INL_SHIP_LINES'
                                            AND assoc.from_parent_table_name = 'INL_CHARGE_LINES'
                                            AND assoc.from_parent_table_id = cl.charge_line_id
                                            AND cl.charge_amt = 0
                                            AND cl.charge_line_type_id = p_charge_line_type_id --same cost factor
                                            AND NVL(cl.match_id,cl.match_amount_id) IS NOT NULL --only ALC
                                            AND  EXISTS (SELECT 1
                                                         FROM inl_ship_lines_all sl
                                                         WHERE sl.ship_line_id     = assoc.to_parent_table_id
                                                         AND sl.ship_header_id     = affected_by_elc_lst(k).ship_header_id
                                                         AND sl.ship_line_group_id = affected_by_elc_lst(k).to_parent_table_id
                                                         AND ROWNUM < 2)
                                            AND (cl.parent_charge_line_id IS NULL
                                                 OR 0 not in
                                                    (SELECT
                                                        cl1.adjustment_num
                                                     FROM
                                                        inl_charge_lines cl1
                                                     WHERE
                                                         CONNECT_BY_ISLEAF = 1
                                                     START WITH cl1.charge_line_id = cl.charge_line_id
                                                     CONNECT BY PRIOR cl1.parent_charge_line_id = cl1.charge_line_id));
--Bug#11064618

                                        ELSIF affected_by_elc_lst(k).to_parent_table_name = 'INL_SHIP_LINES' then
                                            SELECT
                                                SUM(cl.charge_amt)
                                            INTO
                                                l_sum_chLnAmt
                                            FROM
                                                inl_adj_charge_lines_v cl,
                                                inl_associations a
                                            WHERE
                                                a.ship_header_id         = affected_by_elc_lst(k).ship_header_id
                                            AND cl.charge_line_type_id   = p_charge_line_type_id --same cost factor
                                            AND NVL(cl.match_id,cl.match_amount_id) IS NOT NULL --only ALC
                                            AND a.to_parent_table_id = affected_by_elc_lst(k).to_parent_table_id
                                            AND a.from_parent_table_name = 'INL_CHARGE_LINES'
                                            AND a.from_parent_table_id   = cl.charge_line_id
                                            ;
--Bug#11064618
                                            l_debug_info  := 'Verify if exist any actual with amount = 0 coming to this line ';
                                            INL_LOGGING_PVT.Log_Statement (
                                                p_module_name => g_module_name,
                                                p_procedure_name => l_program_name,
                                                p_debug_info => l_debug_info
                                            ) ;

                                            SELECT
                                                    COUNT(*)
                                            INTO
                                                    l_alc_zero
                                            FROM
                                                    inl_charge_lines cl,
                                                    inl_associations assoc
                                            WHERE
                                                assoc.ship_header_id         = affected_by_elc_lst(k).ship_header_id
                                            AND assoc.to_parent_table_name = 'INL_SHIP_LINES'
                                            AND assoc.to_parent_table_id = affected_by_elc_lst(k).to_parent_table_id
                                            AND assoc.from_parent_table_name = 'INL_CHARGE_LINES'
                                            AND assoc.from_parent_table_id = cl.charge_line_id
                                            AND cl.charge_amt = 0
                                            AND cl.charge_line_type_id = p_charge_line_type_id --same cost factor
                                            AND NVL(cl.match_id,cl.match_amount_id) IS NOT NULL --only ALC
                                            AND (cl.parent_charge_line_id IS NULL
                                                 OR 0 not in
                                                    (SELECT
                                                        cl1.adjustment_num
                                                     FROM
                                                        inl_charge_lines cl1
                                                     WHERE
                                                         CONNECT_BY_ISLEAF = 1
                                                     START WITH cl1.charge_line_id = cl.charge_line_id
                                                     CONNECT BY PRIOR cl1.parent_charge_line_id = cl1.charge_line_id));
--Bug#11064618
                                        ELSE
                                             -- CURRENTLY ALL ASSOCIATIONS OF ELC ARE MADE AT SHIPMENT, GROUP OR LINE LEVEL

                                            l_debug_info  := 'Problem in INL SHIPMENT PVT regarding canceled invoice: ELC applied at a level different from SHIPMENT, GROUP OR LINE';
                                            INL_LOGGING_PVT.Log_Statement (
                                                p_module_name => g_module_name,
                                                p_procedure_name => l_program_name,
                                                p_debug_info => l_debug_info
                                            ) ;
                                            RAISE L_FND_EXC_ERROR;

                                        END IF;
                                        INL_LOGGING_PVT.Log_Variable (
                                            p_module_name => g_module_name,
                                            p_procedure_name => l_program_name,
                                            p_var_name => 'l_sum_chLnAmt',
                                            p_var_value => l_sum_chLnAmt
                                        ) ;

                                        IF NVL(l_sum_chLnAmt,0)>0
                                        OR NVL(l_alc_zero,0)>0
                                        THEN
                                            l_ELC_ShouldBeCreatedFlag := 'N';
                                        END IF;
                                        exit when l_ELC_ShouldBeCreatedFlag = 'N';
                                    END LOOP;

                                END IF;
                                IF l_ELC_ShouldBeCreatedFlag = 'Y' THEN
                                    l_debug_info  := 'Getting last parent charge line id ***';
                                    INL_LOGGING_PVT.Log_Statement (
                                        p_module_name => g_module_name,
                                        p_procedure_name => l_program_name,
                                        p_debug_info => l_debug_info
                                    ) ;
                                        INL_LOGGING_PVT.Log_Variable (
                                            p_module_name => g_module_name,
                                            p_procedure_name => l_program_name,
                                            p_var_name => 'ELC_CLines_lst('||j||').charge_line_id',
                                            p_var_value => ELC_CLines_lst(j).charge_line_id
                                        ) ;

                                    SELECT
                                        cl1.charge_line_id
                                    INTO
                                        l_last_parentChargeLineID
                                    FROM
                                        inl_charge_lines cl1
                                    WHERE
                                        CONNECT_BY_ISLEAF = 1
                                        START WITH cl1.charge_line_id = ELC_CLines_lst(j).charge_line_id
                                        CONNECT BY PRIOR cl1.charge_line_id = cl1.parent_charge_line_id
                                    ;

                                    l_debug_info  := 'Inserting a new ELC ***';
                                    INL_LOGGING_PVT.Log_Statement (
                                        p_module_name => g_module_name,
                                        p_procedure_name => l_program_name,
                                        p_debug_info => l_debug_info
                                    ) ;
                                    --Create Charge lines and associations without use of bulk
                                    -- record should be generated before the evaluation of the next charge line
                                    --
                                    -- ASSOCIATIONS remain the same from original ELC charge
                                    INSERT INTO inl_charge_lines
                                        (
                                            charge_line_id             , /* 01 */
                                            charge_line_num            , /* 02 */
                                            charge_line_type_id        , /* 03 */
                                            landed_cost_flag           , /* 04 */
                                            update_allowed             , /* 05 */
                                            source_code                , /* 06 */
                                            parent_charge_line_id      , /* 07 */
                                            adjustment_num             , /* 08 */
                                            match_id                   , /* 09 */
                                            match_amount_id            , /* 10 */
                                            charge_amt                 , /* 11 */
                                            currency_code              , /* 12 */
                                            currency_conversion_type   , /* 13 */
                                            currency_conversion_date   , /* 14 */
                                            currency_conversion_rate   , /* 15 */
                                            party_id                   , /* 16 */
                                            party_site_id              , /* 17 */
                                            trx_business_category      , /* 18 */
                                            intended_use               , /* 19 */
                                            product_fiscal_class       , /* 20 */
                                            product_category           , /* 21 */
                                            product_type               , /* 22 */
                                            user_def_fiscal_class      , /* 23 */
                                            tax_classification_code    , /* 24 */
                                            assessable_value           , /* 25 */
                                            tax_already_calculated_flag, /* 26 */
                                            ship_from_party_id         , /* 27 */
                                            ship_from_party_site_id    , /* 28 */
                                            ship_to_organization_id    , /* 29 */
                                            ship_to_location_id        , /* 30 */
                                            bill_from_party_id         , /* 31 */
                                            bill_from_party_site_id    , /* 32 */
                                            bill_to_organization_id    , /* 33 */
                                            bill_to_location_id        , /* 34 */
                                            poa_party_id               , /* 35 */
                                            poa_party_site_id          , /* 36 */
                                            poo_organization_id        , /* 37 */
                                            poo_location_id            , /* 38 */
                                            created_by                 , /* 39 */
                                            creation_date              , /* 40 */
                                            last_updated_by            , /* 41 */
                                            last_update_date           , /* 42 */
                                            last_update_login            /* 43 */
                                        )
                                    VALUES
                                        (
                                            inl_charge_lines_s.nextval                   , /* 01 */
                                            ELC_CLines_lst(j).charge_line_num            , /* 02 */
                                            p_charge_line_type_id                        , /* 03 */
                                            ELC_CLines_lst(j).landed_cost_flag           , /* 04 */
                                            ELC_CLines_lst(j).update_allowed             , /* 05 */
                                            ELC_CLines_lst(j).source_code                , /* 06 */
                                            l_last_parentChargeLineID                    , /* 07 */
                                            p_adjustment_num                             , /* 08 */
                                            NULL                                         , /* 09 */
                                            NULL                                         , /* 10 */
                                            ELC_CLines_lst(j).charge_amt                 , /* 11 */
                                            ELC_CLines_lst(j).currency_code              , /* 12 */
                                            ELC_CLines_lst(j).currency_conversion_type   , /* 13 */
                                            ELC_CLines_lst(j).currency_conversion_date   , /* 14 */
                                            ELC_CLines_lst(j).currency_conversion_rate   , /* 15 */
                                            ELC_CLines_lst(j).party_id                   , /* 16 */
                                            ELC_CLines_lst(j).party_site_id              , /* 17 */
                                            ELC_CLines_lst(j).trx_business_category      , /* 18 */
                                            ELC_CLines_lst(j).intended_use               , /* 19 */
                                            ELC_CLines_lst(j).product_fiscal_class       , /* 20 */
                                            ELC_CLines_lst(j).product_category           , /* 21 */
                                            ELC_CLines_lst(j).product_type               , /* 22 */
                                            ELC_CLines_lst(j).user_def_fiscal_class      , /* 23 */
                                            ELC_CLines_lst(j).tax_classification_code    , /* 24 */
                                            ELC_CLines_lst(j).assessable_value           , /* 25 */
                                            'N'                                          , /* 26 */
                                            ELC_CLines_lst(j).ship_from_party_id         , /* 27 */
                                            ELC_CLines_lst(j).ship_from_party_site_id    , /* 28 */
                                            ELC_CLines_lst(j).ship_to_organization_id    , /* 29 */
                                            ELC_CLines_lst(j).ship_to_location_id        , /* 30 */
                                            ELC_CLines_lst(j).bill_from_party_id         , /* 31 */
                                            ELC_CLines_lst(j).bill_from_party_site_id    , /* 32 */
                                            ELC_CLines_lst(j).bill_to_organization_id    , /* 33 */
                                            ELC_CLines_lst(j).bill_to_location_id        , /* 34 */
                                            ELC_CLines_lst(j).poa_party_id               , /* 35 */
                                            ELC_CLines_lst(j).poa_party_site_id          , /* 36 */
                                            ELC_CLines_lst(j).poo_organization_id        , /* 37 */
                                            ELC_CLines_lst(j).poo_location_id            , /* 38 */
                                            L_FND_USER_ID                                , /* 39 */
                                            sysdate                                      , /* 40 */
                                            L_FND_USER_ID                                , /* 41 */
                                            sysdate                                      , /* 42 */
                                            l_fnd_login_id --SCM-051                       /* 43 */
                                        );
                                    END IF;
                            END LOOP;
                        END IF;
                    END IF;
                END IF;
            END LOOP;
        END IF;
    END IF;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    ) ;
EXCEPTION
WHEN L_FND_EXC_ERROR THEN
    -- Standard Expected Error Logging
    INL_LOGGING_PVT.Log_ExpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    ) ;
    x_return_status := L_FND_RET_STS_ERROR;
WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    ) ;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    ) ;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level (p_message_level  => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg (
            p_pkg_name => g_pkg_name,
            p_procedure_name => l_program_name
        ) ;
    END IF;
END Create_NewEstimChLinesPerMatch;


-- BUG#9474491
-- Utility name: Handle_EstimChLinesPerMatch  --BUG#9474491
-- Type       : Private
-- Function   : Concentrate calls to bring to zero the estimated charge line or create new Estimated when required
-- Pre-reqs   : None
-- Parameters :
-- IN         :     p_match_id              IN NUMBER,
--                  p_match_Amount_id       IN NUMBER,
--                  p_charge_line_type_id   IN NUMBER,
--
-- OUT        : x_return_status         OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Handle_EstimChLinesPerMatch (  --BUG#9474491
    p_match_id              IN NUMBER,
    p_match_Amount_id       IN NUMBER,
    p_charge_line_type_id   IN NUMBER,
    p_adjustment_num        IN NUMBER,
    x_return_status         OUT NOCOPY VARCHAR2
) IS
    l_program_name CONSTANT VARCHAR2(30) := 'Handle_EstimChLinesPerMatch';
    l_return_status VARCHAR2(1);
    l_debug_info VARCHAR2(200);
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    );
    --  Initialize return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;

    l_debug_info  := 'Calling Zero_EstimChargeLinesPerMatch';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_debug_info => l_debug_info
    ) ;
    Zero_EstimChargeLinesPerMatch (
        p_match_id           => p_match_id,
        p_match_Amount_id    => p_match_Amount_id,
        p_charge_line_type_id=> p_charge_line_type_id,
        p_adjustment_num     => p_adjustment_num,
        x_return_status      => l_debug_info
    );
    IF l_return_status = L_FND_RET_STS_ERROR THEN
        RAISE L_FND_EXC_ERROR;
    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;

    l_debug_info  := 'Calling Create_NewEstimChLinesPerMatch';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_debug_info => l_debug_info
    ) ;

    Create_NewEstimChLinesPerMatch (
        p_match_id           => p_match_id,
        p_match_Amount_id    => p_match_Amount_id,
        p_charge_line_type_id=> p_charge_line_type_id,
        p_adjustment_num     => p_adjustment_num,
        x_return_status      => l_return_status ----BUG#9804065
    );

    IF l_return_status = L_FND_RET_STS_ERROR THEN
        RAISE L_FND_EXC_ERROR;
    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    ) ;
EXCEPTION
WHEN L_FND_EXC_ERROR THEN
    -- Standard Expected Error Logging
    INL_LOGGING_PVT.Log_ExpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    ) ;
    x_return_status := L_FND_RET_STS_ERROR;
WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    ) ;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    ) ;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level (p_message_level  => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg (
            p_pkg_name => g_pkg_name,
            p_procedure_name => l_program_name
        ) ;
    END IF;
END Handle_EstimChLinesPerMatch;

-- API name   : Adjust_ChargeLines
-- Type       : Private
-- Function   : Create Adjustment Lines for Charge Lines
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version                              IN NUMBER   Required
--              p_init_msg_list                            IN VARCHAR2 Optional  Default = L_FND_FALSE
--              p_commit                                   IN VARCHAR2 Optional  Default = L_FND_FALSE
--              p_match_id                                 IN NUMBER,
--              p_adjustment_num                           IN NUMBER,
--              p_func_currency_code IN        VARCHAR2 , --BUG#8468830
-- OUT          x_return_status                            OUT NOCOPY VARCHAR2
--              x_msg_count                                OUT NOCOPY NUMBER
--              x_msg_data                                 OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Adjust_ChargeLines (
    p_api_version           IN NUMBER,
    p_init_msg_list         IN VARCHAR2 := L_FND_FALSE,
    p_commit                IN VARCHAR2 := L_FND_FALSE,
    p_match_id              IN NUMBER,
    p_adjustment_num        IN NUMBER,
    p_func_currency_code    IN VARCHAR2 , --BUG#8468830
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2
) IS
    l_api_name    CONSTANT VARCHAR2 (30) := 'Adjust_ChargeLines';
    l_api_version CONSTANT NUMBER        := 1.0;
    l_next_adjust_num              NUMBER;
    l_debug_info                   VARCHAR2 (240) ;
    l_parent_charge_line_id        NUMBER;
    l_return_status                VARCHAR2 (1) ;
    l_new_charge_line_id           NUMBER;
    l_ship_line_id                 NUMBER;
    l_ship_header_id               NUMBER;
    l_matched_uom_code             VARCHAR2 (30) ;
    l_matched_curr_code            VARCHAR2 (15) ;
    l_matched_curr_conversion_type VARCHAR2 (30) ;
    l_matched_curr_conversion_date DATE;
    l_matched_curr_conversion_rate NUMBER;
    l_replace_estim_qty_flag       VARCHAR2 (1) ;
    l_party_id                     NUMBER;
    l_party_site_id                NUMBER;
    l_matched_amt                  NUMBER;
    l_mat_curr_code                VARCHAR2 (15) ;
    l_corr_charge_line_id          NUMBER;
    l_corr_charge_line_num         NUMBER;
    l_corr_adj_num                 NUMBER;
    l_include_assoc                VARCHAR2 (1) := 'Y';
    l_existing_match_info_flag     VARCHAR2 (1) ;
    l_from_parent_table_name       VARCHAR2 (30) ;
    l_charge_line_type_id          NUMBER;
    l_from_parent_table_id         NUMBER;
    l_to_parent_table_name         VARCHAR2 (30) ;
    l_to_parent_table_id           NUMBER;
    l_prev_adjustment_num          NUMBER := NULL;
    l_ChLn_Assoc inl_ChLn_Assoc_tp;
    l_garb                         NUMBER ; --BUG#8468830

BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (p_module_name => g_module_name, p_procedure_name => l_api_name) ;
    -- Standard Start of API savepoint
    SAVEPOINT Adjust_ChargeLines_PVT;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean (p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    -- Check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
        p_current_version_number => l_api_version,
        p_caller_version_number => p_api_version,
        p_api_name => l_api_name,
        p_pkg_name => g_pkg_name
    ) THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;
    -- Getting the match information
    l_debug_info := 'Getting the match information';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info => l_debug_info
    ) ;
     SELECT m.to_parent_table_id      , /* 01 */
        m.from_parent_table_name      , /* 02 */
        m.from_parent_table_id        , /* 03 */
        m.to_parent_table_name        , /* 04 */
        m.to_parent_table_id          , /* 05 */
        m.matched_uom_code            , /* 06 */
        m.matched_amt                 , /* 07 */
        m.replace_estim_qty_flag      , /* 08 */
        m.existing_match_info_flag    , /* 09 */
        m.party_id                    , /* 10 */
        m.party_site_id               , /* 11 */
        m.charge_line_type_id         , /* 12 */
        m.matched_curr_code           , /* 13 */
        m.matched_curr_conversion_type, /* 14 */
        m.matched_curr_conversion_date, /* 15 */
        m.matched_curr_conversion_rate  /* 16 */
       INTO
        l_ship_line_id                , /* 01 */
        l_from_parent_table_name      , /* 02 */
        l_from_parent_table_id        , /* 03 */
        l_to_parent_table_name        , /* 04 */
        l_to_parent_table_id          , /* 05 */
        l_matched_uom_code            , /* 06 */
        l_matched_amt                 , /* 07 */
        l_replace_estim_qty_flag      , /* 08 */
        l_existing_match_info_flag    , /* 09 */
        l_party_id                    , /* 10 */
        l_party_site_id               , /* 11 */
        l_charge_line_type_id         , /* 12 */
        l_matched_curr_code           , /* 13 */
        l_matched_curr_conversion_type, /* 14 */
        l_matched_curr_conversion_date, /* 15 */
        l_matched_curr_conversion_rate  /* 16 */
       FROM inl_corr_matches_v m
      WHERE match_id = p_match_id;
    -- Getting the Ship information
    l_debug_info                                := 'Getting the ship line information';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info => l_debug_info
    ) ;
     SELECT sl.ship_header_id
       INTO l_ship_header_id
       FROM inl_ship_lines sl
      WHERE sl.ship_line_id = l_ship_line_id;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'l_existing_match_info_flag',
        p_var_value => l_existing_match_info_flag
    ) ;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'l_from_parent_table_name',
        p_var_value => l_from_parent_table_name
    ) ;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'l_from_parent_table_id',
        p_var_value => l_from_parent_table_id
    ) ;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'l_to_parent_table_name',
        p_var_value => l_to_parent_table_name
    ) ;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'l_to_parent_table_id',
        p_var_value => l_to_parent_table_id
    ) ;

    -- l_existing_match_info_flag = 'Y' When a match from the same FROM_PARENT_TABLE_NAME and FROM_PARENT_TABLE_ID
    -- has already been processed
    IF (l_existing_match_info_flag = 'Y') THEN
        -- Charge line has been processed
        l_debug_info  := 'Existing match info flag';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_debug_info => l_debug_info
        ) ;
         SELECT p_adjustment_num,
            cl.charge_line_id   ,
            cl.charge_line_num
           INTO l_prev_adjustment_num         ,
            l_ChLn_Assoc.parent_charge_line_id,
            l_ChLn_Assoc.charge_line_num
           FROM inl_matches m,
            inl_adj_charge_lines_v cl
          WHERE cl.match_id              = m.match_id
            AND m.match_id              <> p_match_id
            AND m.from_parent_table_name = l_from_parent_table_name
            AND m.from_parent_table_id   = l_from_parent_table_id
            AND m.to_parent_table_name   = l_to_parent_table_name
            AND m.to_parent_table_id     = l_to_parent_table_id
            AND m.match_id               =
            (
                 SELECT MAX (m2.match_id)
                   FROM inl_matches m2
                  WHERE m2.from_parent_table_name = m.from_parent_table_name
                    AND m2.from_parent_table_id   = m.from_parent_table_id
                    AND m2.to_parent_table_name   = m.to_parent_table_name
                    AND m2.to_parent_table_id     = m.to_parent_table_id
                    AND m2.match_id              <> p_match_id
            )
            AND cl.charge_line_num =
            (
                 SELECT MAX (cl1.charge_line_num)
                   FROM inl_adj_charge_lines_v cl1
                  WHERE cl1.match_id = m.match_id
            ) ;
        --       GROUP BY  cl.charge_line_id, cl.adjustment_num;
    ELSE
        l_ChLn_Assoc.parent_charge_line_id := NULL;
        -- Getting the charge line to correction
        l_debug_info := 'Getting the charge line to correction';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_debug_info => l_debug_info
        ) ;
        BEGIN
             SELECT cl.charge_line_id,
                cl.charge_line_num   ,
                cl.adjustment_num
               INTO l_corr_charge_line_id,
                l_corr_charge_line_num   ,
                l_corr_adj_num
               FROM inl_adj_charge_lines_v cl
              WHERE cl.match_id        = p_match_id
                AND cl.charge_line_num =
                (
                     SELECT MAX (cl1.charge_line_num)
                       FROM inl_adj_charge_lines_v cl1
                      WHERE cl1.match_id = p_match_id
                ) ;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
        END;
        IF (l_corr_charge_line_id              IS NOT NULL AND l_corr_charge_line_num IS NOT NULL)
        THEN
            l_ChLn_Assoc.charge_line_num       := l_corr_charge_line_num;
            l_ChLn_Assoc.parent_charge_line_id := l_corr_charge_line_id;

            INL_LOGGING_PVT.Log_Variable (
                p_module_name => g_module_name,
                p_procedure_name => l_api_name,
                p_var_name => 'l_corr_charge_line_id',
                p_var_value => l_corr_charge_line_id) ;
        ELSE
            l_ChLn_Assoc.charge_line_num := NULL;
        END IF;
    END IF;
    -- Handling estimated Charge Line and getting the parent_charge_line_id
    l_debug_info := 'Handling estimated Charge Line and getting the parent_charge_line_id';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info => l_debug_info
    ) ;
    -- For now:
    -- 1) Create a new charge line ADJ x with the new actual value with no ADJ 0
    -- 2) For the estimated charge line create a new charge line ADJ 1 with amount = 0
    -- Getting information for the new charge line
    l_debug_info                                := 'All Matched Amounts :'||l_matched_amt;
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info => l_debug_info
    ) ;
    l_ChLn_Assoc.inl_Assoc.ship_header_id       := l_ship_header_id;
    l_ChLn_Assoc.inl_Assoc.allocation_uom_code  := NULL;
    l_ChLn_Assoc.inl_Assoc.to_parent_table_name := 'INL_SHIP_LINES';
    l_ChLn_Assoc.inl_Assoc.to_parent_table_id   := l_to_parent_table_id;
    l_ChLn_Assoc.charge_line_type_id            := l_charge_line_type_id;
    l_ChLn_Assoc.landed_cost_flag               := 'Y';
    l_ChLn_Assoc.adjustment_num                 := l_prev_adjustment_num;
    l_ChLn_Assoc.match_id                       := p_match_id;
    l_ChLn_Assoc.charge_amt                     := l_matched_amt;


    --BUG#8468830
    IF p_func_currency_code <> l_matched_curr_code THEN
        IF l_matched_curr_conversion_type <> 'User' THEN -- Bug #10102991
        l_garb := inl_landedcost_pvt.Converted_Amt (
                                        1,
                                        l_matched_curr_code,
                                        p_func_currency_code,
                                            l_matched_curr_conversion_type,
                                            l_matched_curr_conversion_date,
                                            l_matched_curr_conversion_rate);

    END IF;
    ELSE
        l_matched_curr_conversion_type:= NULL;
        l_matched_curr_conversion_rate:= NULL;
    END IF;
    --BUG#8468830

    l_ChLn_Assoc.currency_code                  := l_matched_curr_code;
    l_ChLn_Assoc.currency_conversion_type       := l_matched_curr_conversion_type;
    l_ChLn_Assoc.currency_conversion_date       := l_matched_curr_conversion_date;
    l_ChLn_Assoc.currency_conversion_rate       := l_matched_curr_conversion_rate;
    l_ChLn_Assoc.party_id                       := l_party_id;
    l_ChLn_Assoc.party_site_id                  := l_party_site_id;
    l_ChLn_Assoc.trx_business_category          := NULL;
    l_ChLn_Assoc.intended_use                   := NULL;
    l_ChLn_Assoc.product_fiscal_class           := NULL;
    l_ChLn_Assoc.product_category               := NULL;
    l_ChLn_Assoc.product_type                   := NULL;
    l_ChLn_Assoc.user_def_fiscal_class          := NULL;
    l_ChLn_Assoc.tax_classification_code        := NULL;
    l_ChLn_Assoc.assessable_value               := NULL;
    l_ChLn_Assoc.tax_already_calculated_flag    := 'N';
    l_ChLn_Assoc.ship_from_party_id             := NULL;
    l_ChLn_Assoc.ship_from_party_site_id        := NULL;
    l_ChLn_Assoc.ship_to_organization_id        := NULL;
    l_ChLn_Assoc.ship_to_location_id            := NULL;
    l_ChLn_Assoc.bill_from_party_id             := NULL;
    l_ChLn_Assoc.bill_from_party_site_id        := NULL;
    l_ChLn_Assoc.bill_to_organization_id        := NULL;
    l_ChLn_Assoc.bill_to_location_id            := NULL;
    l_ChLn_Assoc.poa_party_id                   := NULL;
    l_ChLn_Assoc.poa_party_site_id              := NULL;
    l_ChLn_Assoc.poo_organization_id            := NULL;
    l_ChLn_Assoc.poo_location_id                := NULL;
    -- Create_ChLines
    l_debug_info := 'Create_ChLines';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info => l_debug_info
    ) ;
    -- It does not create associations for corrections
    IF (l_ChLn_Assoc.parent_charge_line_id IS NOT NULL) THEN
        l_include_assoc := 'N';
    ELSE
        l_include_assoc := 'Y';

--Bug#12313822

        l_debug_info := 'Getting the allocation basis';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_debug_info => l_debug_info
        ) ;
        SELECT
            NVL(clt.allocation_basis,'VALUE'),
            abv.base_uom_code
        INTO
            l_ChLn_Assoc.inl_Assoc.allocation_basis,
            l_ChLn_Assoc.inl_Assoc.allocation_uom_code
        FROM
            inl_charge_line_types_vl clt   ,
            inl_allocation_basis_vl abv
        WHERE abv.allocation_basis_code = clt.allocation_basis
        AND   clt.charge_line_type_id   = l_ChLn_Assoc.charge_line_type_id;

        INL_LOGGING_PVT.Log_Variable (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_var_name => 'l_ChLn_Assoc.inl_Assoc.allocation_basis',
            p_var_value => l_ChLn_Assoc.inl_Assoc.allocation_basis
        ) ;
        INL_LOGGING_PVT.Log_Variable (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_var_name => 'l_ChLn_Assoc.inl_Assoc.allocation_uom_code',
            p_var_value => l_ChLn_Assoc.inl_Assoc.allocation_uom_code
        ) ;

--Bug#12313822
    END IF;
    -- Create_ChLines
    Create_ChLines (
        p_ChLn_Assoc => l_ChLn_Assoc,
        p_include_assoc => l_include_assoc,
        p_adjustment_num => p_adjustment_num,
        x_new_charge_line_id => l_new_charge_line_id,
        x_return_status => l_return_status) ;
    IF l_return_status           = L_FND_RET_STS_ERROR THEN
        RAISE L_FND_EXC_ERROR;
    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
    Handle_EstimChLinesPerMatch ( --BUG#9474491
        p_match_id           => p_match_id,
        p_match_Amount_id    => null,
        p_charge_line_type_id=> l_charge_line_type_id,
        p_adjustment_num     => p_adjustment_num,
        x_return_status      => l_debug_info
    );
    IF l_return_status = L_FND_RET_STS_ERROR THEN
        RAISE L_FND_EXC_ERROR;
    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Standard check of p_commit.
    IF FND_API.To_Boolean (p_commit) THEN
        COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get ( p_encoded => L_FND_FALSE, p_count => x_msg_count, p_data => x_msg_data) ;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc ( p_module_name => g_module_name, p_procedure_name => l_api_name) ;
EXCEPTION
WHEN L_FND_EXC_ERROR THEN
    -- Standard Expected Error Logging
    INL_LOGGING_PVT.Log_ExpecError ( p_module_name => g_module_name, p_procedure_name => l_api_name) ;
    ROLLBACK TO Adjust_ChargeLines_PVT;
    x_return_status                      := L_FND_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_encoded => L_FND_FALSE, p_count => x_msg_count, p_data => x_msg_data) ;
WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError ( p_module_name => g_module_name, p_procedure_name => l_api_name) ;
    ROLLBACK TO Adjust_ChargeLines_PVT;
    x_return_status                      := L_FND_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_encoded => L_FND_FALSE, p_count => x_msg_count, p_data => x_msg_data) ;
WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError ( p_module_name => g_module_name, p_procedure_name => l_api_name) ;
    ROLLBACK TO Adjust_ChargeLines_PVT;
    x_return_status                                := L_FND_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg ( p_pkg_name        => g_pkg_name, p_procedure_name => l_api_name) ;
    END IF;
    FND_MSG_PUB.Count_And_Get ( p_encoded => L_FND_FALSE, p_count => x_msg_count, p_data => x_msg_data) ;
END Adjust_ChargeLines;
-- API name   : Adjust_ChargeLines
-- Type       : Private
-- Function   : Create Adjustmens Charge Lines and their associations
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version      IN NUMBER   Required
--              p_init_msg_list    IN VARCHAR2 Optional  Default = L_FND_FALSE
--              p_commit           IN VARCHAR2 Optional  Default = L_FND_FALSE
--              p_match_amount_id  IN NUMBER,
--              p_adjustment_num   IN NUMBER,
--              p_func_currency_code IN        VARCHAR2 , --BUG#8468830
-- OUT          x_return_status    OUT NOCOPY VARCHAR2
--              x_msg_count        OUT NOCOPY NUMBER
--              x_msg_data         OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Adjust_ChargeLines (
        p_api_version     IN NUMBER,
        p_init_msg_list   IN VARCHAR2 := L_FND_FALSE,
        p_commit          IN VARCHAR2 := L_FND_FALSE,
        p_match_amount_id IN NUMBER,
        p_adjustment_num  IN NUMBER,
        p_func_currency_code IN        VARCHAR2 , --BUG#8468830
        x_return_status  OUT NOCOPY VARCHAR2,
        x_msg_count      OUT NOCOPY NUMBER,
        x_msg_data       OUT NOCOPY VARCHAR2
) IS
    l_api_name    CONSTANT VARCHAR2 (30) := 'Adjust_ChargeLines-2';
    l_api_version CONSTANT NUMBER        := 1.0;
    CURSOR c_matches_cl (p_match_amount_id NUMBER)
    IS
         SELECT
            m.match_id          ,
            m.ship_header_id        ,
            m.from_parent_table_name,
            m.from_parent_table_id  ,
            m.to_parent_table_name  ,
            m.to_parent_table_id
           FROM inl_corr_matches_v m
          WHERE m.match_amount_id = p_match_amount_id
       ORDER BY m.match_id;
    TYPE c_matches_type
    IS
    TABLE OF c_matches_cl%ROWTYPE;
    c_matches c_matches_type;
    l_next_adjust_num              NUMBER;
    l_debug_info                   VARCHAR2 (240) ;
    l_parent_charge_line_id        NUMBER;
    l_return_status                VARCHAR2 (1) ;
    l_new_charge_line_id           NUMBER;
    l_ship_line_id                 NUMBER;
    l_ship_header_id               NUMBER;
    l_matched_curr_code            VARCHAR2 (15) ;
    l_matched_curr_conversion_type VARCHAR2 (30) ;
    l_matched_curr_conversion_date DATE;
    l_matched_curr_conversion_rate NUMBER;
    l_charge_line_type_id          NUMBER;
    l_party_id                     NUMBER;
    l_party_site_id                NUMBER;
    l_matched_amt                  NUMBER;
    l_mat_curr_code                VARCHAR2 (15) ;
    l_allocation_basis             VARCHAR2 (30) ;
    l_allocation_uom_code          VARCHAR2 (30) ;
    l_corr_charge_line_id          NUMBER;
    l_corr_charge_line_num         NUMBER;
    l_corr_adj_num                 NUMBER;
    l_existing_match_info_flag     VARCHAR2 (1) ;
    l_from_parent_table_name       VARCHAR2 (30) ;
    l_from_parent_table_id         NUMBER;
    l_to_parent_table_name         VARCHAR2 (30) ;
    l_tax_code                     VARCHAR2 (30) ;
    l_to_parent_table_id           NUMBER;
    l_prev_match_amount_id         NUMBER;
    l_count_new_matches            NUMBER;
    l_ChLn_Assoc inl_ChLn_Assoc_tp;
    l_AssocLn inl_Assoc_tp;
    l_garb                         NUMBER ; --BUG#8468830
    l_prev_match_id                NUMBER;
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (p_module_name => g_module_name, p_procedure_name => l_api_name) ;
    -- Standard Start of API savepoint
    SAVEPOINT Adjust_ChargeLines_PVT;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean (p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    -- Check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
        p_current_version_number => l_api_version,
        p_caller_version_number => p_api_version,
        p_api_name => l_api_name,
        p_pkg_name => g_pkg_name
    ) THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;
    -- Getting the match information
    l_debug_info := 'Getting the match information';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info => l_debug_info
    ) ;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'p_match_amount_id',
        p_var_value => p_match_amount_id
    ) ;
    SELECT
        -- m.ship_header_id            ,     --BUG#8198498
        m.from_parent_table_name       ,
        -- the min is one of the lines that alread exists in prior calculation
        m.from_parent_table_id         ,
        m.to_parent_table_name         ,
        m.to_parent_table_id           ,
        (SELECT SUM(INL_LANDEDCOST_PVT.Converted_Amt( NVL(a.matched_amt,0),
                                                     a.matched_curr_code,
                                                     ma.matched_curr_code,
                                                     ma.matched_curr_conversion_type,
                                                     ma.matched_curr_conversion_date))
          FROM inl_corr_matches_v a
         WHERE a.match_amount_id = ma.match_amount_id ) matched_amt,
        m.party_id                     ,
        m.party_site_id                ,
        ma.charge_line_type_id         ,
        ma.tax_code                    ,
        m.existing_match_info_flag     ,
        ma.matched_curr_code           ,
        ma.matched_curr_conversion_type,
        ma.matched_curr_conversion_date,
        ma.matched_curr_conversion_rate,
        clt.allocation_basis           ,
        abv.base_uom_code
       INTO
        -- l_ship_header_id          ,--BUG#8198498
        l_from_parent_table_name      ,
        l_from_parent_table_id        ,
        l_to_parent_table_name        ,
        l_to_parent_table_id          ,
        l_matched_amt                 ,
        l_party_id                    ,
        l_party_site_id               ,
        l_charge_line_type_id         ,
        l_tax_code                    ,
        l_existing_match_info_flag    ,
        l_matched_curr_code           ,
        l_matched_curr_conversion_type,
        l_matched_curr_conversion_date,
        l_matched_curr_conversion_rate,
        l_allocation_basis            ,
        l_allocation_uom_code
       FROM inl_match_amounts ma, -- Bug #9179775
        inl_corr_matches_v m           ,
        inl_charge_line_types_vl clt   ,
        inl_allocation_basis_vl abv
      WHERE abv.allocation_basis_code = clt.allocation_basis
        AND clt.charge_line_type_id   = m.charge_line_type_id
        AND m.match_amount_id         = ma.match_amount_id
        AND ma.match_amount_id        = p_match_amount_id
        AND m.match_id in (select min(match_id) -- BUG#8411594
                            FROM inl_corr_matches_v m
                          WHERE m.match_amount_id = p_match_amount_id);

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'l_existing_match_info_flag',
        p_var_value => l_existing_match_info_flag
    ) ;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'l_from_parent_table_name',
        p_var_value => l_from_parent_table_name
    ) ;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'l_from_parent_table_id',
        p_var_value => l_from_parent_table_id
    ) ;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'l_to_parent_table_name',
        p_var_value => l_to_parent_table_name
    ) ;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'l_to_parent_table_id',
        p_var_value => l_to_parent_table_id
    ) ;

    l_ChLn_Assoc.adjustment_num := p_adjustment_num;
-- BUG#8411594

    -- l_existing_match_info_flag = 'Y' When a match from the same FROM_PARENT_TABLE_NAME and FROM_PARENT_TABLE_ID
    -- has already been processed
    IF (l_existing_match_info_flag = 'Y') THEN
        -- a)Verify if exists any new match in this match amount
        -- a.1) Get the last match_amount_id
        SELECT max(match_amount_id)
        INTO l_prev_match_amount_id
        FROM inl_matches m
        WHERE m.charge_line_type_id = l_charge_line_type_id
        AND  nvl(m.tax_code,'-9') = nvl(l_tax_code,'-9')
        AND  m.match_amount_id <> p_match_amount_id
        AND adj_already_generated_flag = 'Y'
        AND (m.from_parent_table_name, m.from_parent_table_id)
        IN (SELECT m2.from_parent_table_name, m2.from_parent_table_id
            FROM inl_matches m2
            WHERE m2.match_amount_id = p_match_amount_id)
        ;

        INL_LOGGING_PVT.Log_Variable (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_var_name => 'l_prev_match_amount_id',
            p_var_value => l_prev_match_amount_id
        ) ;

        IF l_prev_match_amount_id IS NOT NULL THEN
            -- a.2) Count the new matches
            SELECT nvl(count(*),0)
            INTO l_count_new_matches
            FROM inl_matches m
            WHERE m.match_amount_id = p_match_amount_id
            AND not exists (SELECT 1
                            FROM inl_matches m2
                            WHERE m2.match_amount_id          = l_prev_match_amount_id
                            AND m2.from_parent_table_name     = m.from_parent_table_name
                            AND m2.from_parent_table_id       = m.from_parent_table_id
                            AND m2.to_parent_table_name       = m.to_parent_table_name
                            AND m2.to_parent_table_id         = m.to_parent_table_id
                            )
            ;
            -- b)Verify if any old match has been deleted
            IF l_count_new_matches = 0 THEN
                -- b.1) Count old matches
                SELECT nvl(count(*),0)
                INTO l_count_new_matches
                FROM inl_matches m
                WHERE m.match_amount_id = l_prev_match_amount_id
                AND not exists (SELECT 1
                                FROM inl_matches m2
                                WHERE m2.match_amount_id          = p_match_amount_id
                                AND m2.from_parent_table_name     = m.from_parent_table_name
                                AND m2.from_parent_table_id       = m.from_parent_table_id
                                AND m2.to_parent_table_name       = m.to_parent_table_name
                                AND m2.to_parent_table_id         = m.to_parent_table_id
                                )
                ;
            END IF;
            -- c) if exists any new match zeroes the previous charge line
            IF l_count_new_matches > 0 THEN
                Zero_ChLnFromPrevMatchAmt (
                    p_prev_match_amount_id  => l_prev_match_amount_id, --Bug#9474491
                    p_prev_match_id         => NULL, --Bug#9804065
                    p_adjustment_num        => p_adjustment_num,
                    x_return_status         => l_debug_info
                );
            END IF;
        ELSE  --BUG#9804065 -- The previous could be a match and not a match amount

            INL_LOGGING_PVT.Log_Statement (
                p_module_name => g_module_name,
                p_procedure_name => l_api_name,
                p_debug_info => 'Get previous match id.'
            ) ;
            SELECT m.parent_match_id
            INTO l_prev_match_id
            FROM inl_matches m
            WHERE m.match_amount_id = p_match_amount_id
            AND m.existing_match_info_flag = 'Y';

            INL_LOGGING_PVT.Log_Variable (
                p_module_name => g_module_name,
                p_procedure_name => l_api_name,
                p_var_name => 'l_prev_match_id',
                p_var_value => l_prev_match_id
            ) ;
            Zero_ChLnFromPrevMatchAmt (
                p_prev_match_amount_id  => NULL,
                p_prev_match_id         => l_prev_match_id,
                p_adjustment_num        => p_adjustment_num,
                x_return_status         => l_debug_info
            );

        END IF;  --BUG#9804065
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;
-- BUG#8411594

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'l_count_new_matches',
        p_var_value => l_count_new_matches
    ) ;
    IF (l_existing_match_info_flag = 'Y')
        AND l_count_new_matches = 0 THEN  -- BUG#8411594
        -- Charge has been already processed
        l_debug_info := 'Existing match info flag';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_debug_info => l_debug_info
        ) ;
        SELECT cl.charge_line_id   ,
            cl.charge_line_num
        INTO l_ChLn_Assoc.parent_charge_line_id,
            l_ChLn_Assoc.charge_line_num
        FROM inl_matches m,
            inl_adj_charge_lines_v cl
        WHERE cl.match_amount_id         = m.match_amount_id
        AND m.from_parent_table_name     = l_from_parent_table_name
        AND m.from_parent_table_id       = l_from_parent_table_id
        AND m.to_parent_table_name       = l_to_parent_table_name
        AND m.to_parent_table_id         = l_to_parent_table_id
        AND m.adj_already_generated_flag = 'Y'
        AND m.match_id                   =
        (
            SELECT MAX (m2.match_id)
            FROM inl_matches m2
            WHERE m2.from_parent_table_name   = m.from_parent_table_name
            AND m2.from_parent_table_id       = m.from_parent_table_id
            AND m2.to_parent_table_name       = m.to_parent_table_name
            AND m2.to_parent_table_id         = m.to_parent_table_id
            AND m2.adj_already_generated_flag = 'Y'
        )
        AND cl.charge_line_num =
        (
            SELECT MAX (cl1.charge_line_num)
            FROM inl_adj_charge_lines_v cl1
            WHERE cl1.match_amount_id = m.match_amount_id
        ) ;
        --        GROUP BY  cl.charge_line_id, cl.adjustment_num;
    ELSE
        l_ChLn_Assoc.parent_charge_line_id := NULL;
        -- Getting the charge line to correction
        l_debug_info                                := 'Getting the charge line to correction';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_debug_info => l_debug_info
        ) ;
        BEGIN
            SELECT
                cl.charge_line_id ,
                cl.charge_line_num,
                cl.adjustment_num
            INTO
                l_corr_charge_line_id ,
                l_corr_charge_line_num,
                l_corr_adj_num
            FROM inl_adj_charge_lines_v cl
            WHERE cl.match_amount_id = p_match_amount_id
            AND cl.charge_line_num =
                (
                     SELECT MAX (cl1.charge_line_num)
                       FROM inl_adj_charge_lines_v cl1
                      WHERE cl1.match_amount_id = p_match_amount_id
                ) ;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;
        -- Is a correction, necessary to create an adjustment
        IF l_corr_charge_line_id IS NOT NULL
           AND l_corr_charge_line_num IS NOT NULL
        THEN
            l_ChLn_Assoc.charge_line_num       := l_corr_charge_line_num;
            l_ChLn_Assoc.parent_charge_line_id := l_corr_charge_line_id;

            INL_LOGGING_PVT.Log_Variable (
                p_module_name => g_module_name,
                p_procedure_name => l_api_name,
                p_var_name => 'l_corr_charge_line_id',
                p_var_value => l_corr_charge_line_id
            );
        ELSE
            l_ChLn_Assoc.charge_line_num := NULL;
        END IF;
    END IF;
    -- Handling estimated Charge Line and getting the parent_charge_line_id
    l_debug_info := 'Handling estimated Charge Line and getting the parent_charge_line_id';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info => l_debug_info
    ) ;
    -- For now:
    -- 1) Create a new charge line ADJ x with the new actual value with no ADJ 0
    -- 2) For the estimated charge line create a new charge line ADJ 1 with amount = 0
    -- Getting information for the new charge line
    l_debug_info := 'All Matched Amounts :'||l_matched_amt;
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info => l_debug_info
    ) ;
    -- Creating a charge line
    l_ChLn_Assoc.charge_line_type_id         := l_charge_line_type_id;
    l_ChLn_Assoc.landed_cost_flag            := 'Y';
    l_ChLn_Assoc.match_amount_id             := p_match_amount_id;
    l_ChLn_Assoc.charge_amt                  := l_matched_amt;

    --BUG#8468830
    IF p_func_currency_code <> l_matched_curr_code THEN
        IF l_matched_curr_conversion_type <> 'User' THEN -- Bug #10102991
        l_garb := inl_landedcost_pvt.Converted_Amt (
                                        1,
                                        l_matched_curr_code,
                                        p_func_currency_code,
                                            l_matched_curr_conversion_type,
                                            l_matched_curr_conversion_date,
                                            l_matched_curr_conversion_rate);
        END IF;
    ELSE
        l_matched_curr_conversion_type:= NULL;
        l_matched_curr_conversion_rate:= NULL;
    END IF;
    --BUG#8468830

    l_ChLn_Assoc.currency_code               := l_matched_curr_code;
    l_ChLn_Assoc.currency_conversion_type    := l_matched_curr_conversion_type;
    l_ChLn_Assoc.currency_conversion_date    := l_matched_curr_conversion_date;
    l_ChLn_Assoc.currency_conversion_rate    := l_matched_curr_conversion_rate;
    l_ChLn_Assoc.party_id                    := l_party_id;
    l_ChLn_Assoc.party_site_id               := l_party_site_id;
    l_ChLn_Assoc.trx_business_category       := NULL;
    l_ChLn_Assoc.intended_use                := NULL;
    l_ChLn_Assoc.product_fiscal_class        := NULL;
    l_ChLn_Assoc.product_category            := NULL;
    l_ChLn_Assoc.product_type                := NULL;
    l_ChLn_Assoc.user_def_fiscal_class       := NULL;
    l_ChLn_Assoc.tax_classification_code     := NULL;
    l_ChLn_Assoc.assessable_value            := NULL;
    l_ChLn_Assoc.tax_already_calculated_flag := 'N';
    l_ChLn_Assoc.ship_from_party_id          := NULL;
    l_ChLn_Assoc.ship_from_party_site_id     := NULL;
    l_ChLn_Assoc.ship_to_organization_id     := NULL;
    l_ChLn_Assoc.ship_to_location_id         := NULL;
    l_ChLn_Assoc.bill_from_party_id          := NULL;
    l_ChLn_Assoc.bill_from_party_site_id     := NULL;
    l_ChLn_Assoc.bill_to_organization_id     := NULL;
    l_ChLn_Assoc.bill_to_location_id         := NULL;
    l_ChLn_Assoc.poa_party_id                := NULL;
    l_ChLn_Assoc.poa_party_site_id           := NULL;
    l_ChLn_Assoc.poo_organization_id         := NULL;
    l_ChLn_Assoc.poo_location_id             := NULL;
    -- Create Charge Line
    l_debug_info := 'Create_ChLines from a match_amount_id';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name       => g_module_name,
        p_procedure_name    => l_api_name,
        p_debug_info        => l_debug_info
    ) ;
    Create_ChLines (
        p_ChLn_Assoc => l_ChLn_Assoc,
        p_include_assoc => 'N',
        p_adjustment_num => l_ChLn_Assoc.adjustment_num,
        x_new_charge_line_id => l_new_charge_line_id,
        x_return_status => l_return_status
    ) ;
    IF l_return_status = L_FND_RET_STS_ERROR THEN
        RAISE L_FND_EXC_ERROR;
    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
    -- It does not create associations for corrections
    IF (l_corr_charge_line_id IS NULL
        AND l_ChLn_Assoc.parent_charge_line_id IS NULL) THEN
        -- Create_associations for the match amount id
        l_debug_info := 'Create association lines to a match_amount_id';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_debug_info => l_debug_info
        ) ;
        OPEN c_matches_cl (p_match_amount_id) ;
        FETCH c_matches_cl BULK COLLECT INTO c_matches;
        CLOSE c_matches_cl;
        l_debug_info := c_matches.LAST||' match lines have been retrieved.';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_debug_info => l_debug_info
        ) ;
        IF NVL (c_matches.LAST, 0) > 0 THEN
            FOR i IN NVL (c_matches.FIRST, 0) ..NVL (c_matches.LAST, 0)
            LOOP
                l_AssocLn.ship_header_id       := c_matches(i).ship_header_id;
                l_AssocLn.allocation_basis     := l_allocation_basis;
                l_AssocLn.allocation_uom_code  := l_allocation_uom_code;
                l_AssocLn.to_parent_table_name := c_matches(i).to_parent_table_name;
                l_AssocLn.to_parent_table_id   := c_matches(i).to_parent_table_id;
                --Verifying if association already exists
                --BUG#8198498
                l_debug_info := ' Verifying if association already exists ('||i||'): '||c_matches(i).to_parent_table_name||' - '||c_matches(i).to_parent_table_id;
                INL_LOGGING_PVT.Log_Statement (
                    p_module_name => g_module_name,
                    p_procedure_name => l_api_name,
                    p_debug_info => l_debug_info
                ) ;
                SELECT MAX(association_id)  --Bug#9907327
                INTO l_AssocLn.association_id
                FROM inl_associations
                WHERE from_parent_table_name = 'INL_CHARGE_LINES'
                AND from_parent_table_id     = l_new_charge_line_id
                AND to_parent_table_name     = c_matches(i).to_parent_table_name
                AND to_parent_table_id       = c_matches(i).to_parent_table_id
                ;
                INL_LOGGING_PVT.Log_Variable (
                    p_module_name  => g_module_name,
                    p_procedure_name => l_api_name,
                    p_var_name => 'l_AssocLn.association_id',
                    p_var_value => l_AssocLn.association_id) ;
                -- Create Association Line
                l_debug_info := 'Create association line for the charge';
                INL_LOGGING_PVT.Log_Statement (
                    p_module_name => g_module_name,
                    p_procedure_name => l_api_name,
                    p_debug_info => l_debug_info
                ) ;
                INL_LOGGING_PVT.Log_Variable (
                    p_module_name  => g_module_name,
                    p_procedure_name => l_api_name,
                    p_var_name => 'c_matches('||i||').to_parent_table_id',
                    p_var_value => c_matches(i).to_parent_table_id) ;
                Create_Assoc (
                    p_Assoc => l_AssocLn,
                    p_from_parent_table_name => 'INL_CHARGE_LINES',
                    p_new_line_id => l_new_charge_line_id,
                    x_return_status => l_return_status
                );
            END LOOP;
        END IF;
    END IF;
    Handle_EstimChLinesPerMatch ( --BUG#9474491
        p_match_id           => null,
        p_match_Amount_id    => p_match_amount_id,
        p_charge_line_type_id=> l_charge_line_type_id,
        p_adjustment_num     => l_ChLn_Assoc.adjustment_num,
        x_return_status      => l_debug_info
    );
    IF l_return_status = L_FND_RET_STS_ERROR THEN
        RAISE L_FND_EXC_ERROR;
    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Standard check of p_commit.
    IF FND_API.To_Boolean (p_commit) THEN
        COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get (p_encoded => L_FND_FALSE, p_count => x_msg_count, p_data => x_msg_data) ;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc (p_module_name => g_module_name, p_procedure_name => l_api_name) ;
EXCEPTION
WHEN L_FND_EXC_ERROR THEN
    -- Standard Expected Error Logging
    INL_LOGGING_PVT.Log_ExpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
    ROLLBACK TO Adjust_ChargeLines_PVT;
    x_return_status                     := L_FND_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count, p_data => x_msg_data) ;
WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
    ROLLBACK TO Adjust_ChargeLines_PVT;
    x_return_status                     := L_FND_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data) ;
WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (p_module_name => g_module_name, p_procedure_name => l_api_name) ;
    ROLLBACK TO Adjust_ChargeLines_PVT;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg (
            p_pkg_name         => g_pkg_name,
            p_procedure_name => l_api_name) ;
    END IF;
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data) ;
END Adjust_ChargeLines;

-- API name   : Adjust_TaxLines
-- Type       : Private
-- Function   : Create Adjustment Lines for Charge Lines
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version                              IN NUMBER   Required
--              p_init_msg_list                            IN VARCHAR2 Optional  Default = L_FND_FALSE
--              p_commit                                   IN VARCHAR2 Optional  Default = L_FND_FALSE
--              p_match_id                                 IN NUMBER,
--              p_adjustment_num                           IN NUMBER,
--              p_func_currency_code                       IN VARCHAR2 , --BUG#8468830
-- OUT          x_return_status                            OUT NOCOPY VARCHAR2
--              x_msg_count                                OUT NOCOPY NUMBER
--              x_msg_data                                 OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Adjust_TaxLines    (
        p_api_version        IN        NUMBER   ,
        p_init_msg_list      IN        VARCHAR2 := L_FND_FALSE,
        p_commit             IN        VARCHAR2 := L_FND_FALSE,
        p_match_id           IN        NUMBER   ,
        p_adjustment_num     IN        NUMBER   ,
        p_func_currency_code IN        VARCHAR2 , --BUG#8468830
        x_return_status     OUT NOCOPY VARCHAR2 ,
        x_msg_count         OUT NOCOPY NUMBER   ,
        x_msg_data          OUT NOCOPY VARCHAR2
) IS
    l_api_name                     CONSTANT VARCHAR2 (30) := 'Adjust_TaxLines';
    l_api_version                  CONSTANT NUMBER        := 1.0;
    l_next_adjust_num              NUMBER;
    l_debug_info                   VARCHAR2 (240) ;
    l_parent_tax_line_id           NUMBER;
    l_return_status                VARCHAR2 (1) ;
    l_table_id                     NUMBER;
    l_table_name                   VARCHAR2 (30) ;
    l_ship_header_id               NUMBER;
    l_matched_curr_code            VARCHAR2 (15) ;
    l_matched_curr_conversion_type VARCHAR2 (30) ;
    l_matched_curr_conversion_date DATE;
    l_matched_curr_conversion_rate NUMBER;
    l_mat_curr_code                VARCHAR2 (15) ;
    l_TxLn_Assoc inl_TxLn_Assoc_tp;
    l_tax_code               VARCHAR2 (30) ;
    l_matched_amt            NUMBER;
    l_nrec_tax_amt           NUMBER;
    l_include_assoc_flag     VARCHAR2 (1) ;
    l_tax_amt_included_flag  VARCHAR2 (1) ;
    l_from_parent_table_name VARCHAR2 (30) ;
    l_from_parent_table_id   NUMBER;
    l_ship_line_id           NUMBER;
    l_new_tax_line_id        NUMBER;
    l_garb                   NUMBER ; --BUG#8468830
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
    -- Standard Start of API savepoint
    SAVEPOINT Adjust_TaxLines_PVT;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean (p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    -- Check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
                        p_current_version_number => l_api_version,
                        p_caller_version_number => p_api_version,
                        p_api_name => l_api_name,
                        p_pkg_name => g_pkg_name
    ) THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;
    -- Getting the match information
    l_debug_info := 'Getting the match information';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info => l_debug_info
    ) ;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'p_match_id',
        p_var_value => p_match_id
    ) ;
     SELECT
        m.to_parent_table_name        ,
        m.to_parent_table_id          ,
        m.tax_code                    ,
        m.matched_amt                 ,
        m.nrec_tax_amt                ,
        m.tax_amt_included_flag       ,
        m.from_parent_table_name      ,
        m.from_parent_table_id        ,
        m.matched_curr_code           ,
        m.matched_curr_conversion_type,
        m.matched_curr_conversion_date,
        m.matched_curr_conversion_rate,
        m.ship_header_id
       INTO
        l_table_name                  ,
        l_table_id                    ,
        l_tax_code                    ,
        l_matched_amt                 ,
        l_nrec_tax_amt                ,
        l_tax_amt_included_flag       ,
        l_from_parent_table_name      ,
        l_from_parent_table_id        ,
        l_matched_curr_code           ,
        l_matched_curr_conversion_type,
        l_matched_curr_conversion_date,
        l_matched_curr_conversion_rate,
        l_ship_header_id
       FROM inl_corr_matches_v m
      WHERE match_id = p_match_id;
    -- Handling estimated tax Line and getting the parent_tax_line_id
    l_debug_info := 'Handling estimated tax Line and getting the parent_tax_line_id';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name    => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info     => l_debug_info
    ) ;
    -- For now:
    -- 1) Create a new tax line ADJ 1 with the new actual value with no ADJ 0
    -- 2) For the estimated tax line create a new tax line ADJ 1 with amount = 0
    -- Getting information for the new tax line
    l_debug_info := 'All Amounts :'||l_matched_amt;
    INL_LOGGING_PVT.Log_Statement (
        p_module_name    => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info     => l_debug_info
    ) ;
    l_TxLn_Assoc.inl_Assoc.to_parent_table_name := l_table_name;
    IF l_table_name = 'INL_SHIP_LINES' THEN
        l_TxLn_Assoc.inl_Assoc.to_parent_table_id := l_table_id;
    END IF;
--    l_TxLn_Assoc.adjustment_num                 := p_adjustment_num;
     SELECT NVL (MAX (adjustment_num), 0) + 1
       INTO l_TxLn_Assoc.adjustment_num
       FROM inl_tax_lines tx
      WHERE tx.source_parent_table_name = l_from_parent_table_name
        AND tx.source_parent_table_id   = l_from_parent_table_id
        AND tx.ship_header_id = l_ship_header_id;
    IF l_TxLn_Assoc.adjustment_num      > 1 THEN
         SELECT tax_line_num, tax_line_id
           INTO l_TxLn_Assoc.tax_line_num, l_TxLn_Assoc.parent_tax_line_id
           FROM inl_tax_lines tx
          WHERE tx.source_parent_table_name = l_from_parent_table_name
            AND tx.source_parent_table_id   = l_from_parent_table_id
            AND tx.ship_header_id = l_ship_header_id
            AND adjustment_num              =
            (
                 SELECT MAX (tx1.adjustment_num)
                   FROM inl_tax_lines tx1
                  WHERE tx1.source_parent_table_name = tx.source_parent_table_name
                    AND tx1.source_parent_table_id   = tx.source_parent_table_id
                    AND tx1.ship_header_id           = l_ship_header_id
            ) ;
    ELSE
        l_TxLn_Assoc.tax_line_num := NULL;
        l_TxLn_Assoc.parent_tax_line_id := NULL;
    END IF;
    l_TxLn_Assoc.inl_Assoc.ship_header_id       := l_ship_header_id;
    l_TxLn_Assoc.inl_Assoc.allocation_basis     := 'VALUE';
    l_TxLn_Assoc.inl_Assoc.allocation_uom_code  := NULL;
    l_TxLn_Assoc.tax_code                       := l_tax_code;
    l_TxLn_Assoc.match_id                       := p_match_id;
    l_TxLn_Assoc.matched_amt                    := l_matched_amt;
    l_TxLn_Assoc.nrec_tax_amt                   := l_nrec_tax_amt;
    l_TxLn_Assoc.source_parent_table_name       := l_from_parent_table_name;
    l_TxLn_Assoc.source_parent_table_id         := l_from_parent_table_id;

    --BUG#8468830
    IF p_func_currency_code <> l_matched_curr_code THEN
    IF l_matched_curr_conversion_type <> 'User' THEN -- Bug #10102991
            l_garb := inl_landedcost_pvt.Converted_Amt (
                                        1,
                                        l_matched_curr_code,
                                        p_func_currency_code,
                                        l_matched_curr_conversion_type,
                                        l_matched_curr_conversion_date,
                                        l_matched_curr_conversion_rate);
    END IF;
    ELSE
        l_matched_curr_conversion_type:= NULL;
        l_matched_curr_conversion_rate:= NULL;
    END IF;
    --BUG#8468830

    l_TxLn_Assoc.currency_code                  := l_matched_curr_code;
    l_TxLn_Assoc.currency_conversion_type       := l_matched_curr_conversion_type;
    l_TxLn_Assoc.currency_conversion_date       := l_matched_curr_conversion_date;
    l_TxLn_Assoc.currency_conversion_rate       := l_matched_curr_conversion_rate;
    l_TxLn_Assoc.tax_amt_included_flag          := l_tax_amt_included_flag;
    IF l_TxLn_Assoc.parent_tax_line_id IS NULL THEN
        l_include_assoc_flag:= 'Y';
    ELSE
        l_include_assoc_flag:= 'N';
    END IF;
    -- Create_TxLines
    l_debug_info := 'Create_TxLines';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info => l_debug_info
    ) ;
    Create_TxLines (
        p_TxLn_Assoc        => l_TxLn_Assoc,
        p_include_assoc     => l_include_assoc_flag,
        p_adjustment_num    => p_adjustment_num,
        x_new_tax_line_id   => l_new_tax_line_id,
        x_return_status     => l_return_status) ;
    IF l_return_status                           = L_FND_RET_STS_ERROR THEN
        RAISE L_FND_EXC_ERROR;
    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
    -- The estimated tax lines will made = 0 when as actual arrived on associated line
    -- i.e. when a charge became and actual value the estimated taxes will made 0 too
    -- Standard check of p_commit.
    IF FND_API.To_Boolean (p_commit) THEN
        COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get ( p_encoded => L_FND_FALSE, p_count => x_msg_count, p_data => x_msg_data) ;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
EXCEPTION
WHEN L_FND_EXC_ERROR THEN
    -- Standard Expected Error Logging
    INL_LOGGING_PVT.Log_ExpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
    ROLLBACK TO Adjust_TaxLines_PVT;
    x_return_status                      := L_FND_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count, p_data => x_msg_data) ;
WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
    ROLLBACK TO Adjust_TaxLines_PVT;
    x_return_status                      := L_FND_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data) ;
WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
    ROLLBACK TO Adjust_TaxLines_PVT;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg (
            p_pkg_name        => g_pkg_name,
            p_procedure_name => l_api_name) ;
    END IF;
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data) ;
END Adjust_TaxLines;

-- API name   : Adjust_TaxLines
-- Type       : Private
-- Function   : Create Adjustment Lines for Charge Lines
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version                              IN NUMBER   Required
--              p_init_msg_list                            IN VARCHAR2 Optional  Default = L_FND_FALSE
--              p_commit                                   IN VARCHAR2 Optional  Default = L_FND_FALSE
--              p_match_amount_id                          IN NUMBER,
--              p_adjustment_num                           IN NUMBER,
--              p_func_currency_code IN        VARCHAR2 , --BUG#8468830
-- OUT          x_return_status                            OUT NOCOPY VARCHAR2
--              x_msg_count                                OUT NOCOPY NUMBER
--              x_msg_data                                 OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Adjust_TaxLines(
    p_api_version     IN NUMBER,
    p_init_msg_list   IN VARCHAR2 := L_FND_FALSE,
    p_commit          IN VARCHAR2 := L_FND_FALSE,
    p_match_amount_id IN NUMBER,
    p_adjustment_num  IN NUMBER,
    p_func_currency_code IN        VARCHAR2 , --BUG#8468830
    x_return_status   OUT NOCOPY VARCHAR2,
    x_msg_count       OUT NOCOPY NUMBER,
    x_msg_data        OUT NOCOPY VARCHAR2
) IS
    l_api_name                     CONSTANT VARCHAR2 (30) := 'Adjust_TaxLines-2';
    l_api_version                  CONSTANT NUMBER        := 1.0;
    l_debug_info                   VARCHAR2 (240) ;
    l_return_status                VARCHAR2 (1) ;
--
    CURSOR c_matches_tl (p_match_amount_id NUMBER)
    IS
         SELECT distinct
            m.ship_header_id      , --BUG#8198498
            m.to_parent_table_name,
            m.to_parent_table_id
           FROM inl_corr_matches_v m
          WHERE m.match_amount_id = p_match_amount_id;
    TYPE c_matches_type
        IS
        TABLE OF c_matches_tl%ROWTYPE;
    c_matches c_matches_type;
    l_TxLn_Assoc                inl_TxLn_Assoc_tp;
    l_existing_match_info_flag  VARCHAR2(1);
    l_charge_line_type_id       NUMBER;
    l_new_tax_line_id           NUMBER;
    l_prev_match_amount_id      NUMBER;
    l_count_new_matches         NUMBER;
    l_garb                      NUMBER ; --BUG#8468830
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc ( p_module_name => g_module_name, p_procedure_name => l_api_name) ;
    -- Standard Start of API savepoint
    SAVEPOINT Adjust_TaxLines_2_PVT;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean (p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    -- Check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (p_current_version_number => l_api_version, p_caller_version_number => p_api_version, p_api_name => l_api_name, p_pkg_name => g_pkg_name) THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;
    -- Getting the matchAmount information
    l_debug_info := 'Getting the matchAmount information';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name       => g_module_name,
        p_procedure_name    => l_api_name,
        p_debug_info        => l_debug_info
    ) ;
    SELECT
        (SELECT SUM(INL_LANDEDCOST_PVT.Converted_Amt( NVL(a.matched_amt,0),
                                                     a.matched_curr_code,
                                                     ma.matched_curr_code,
                                                     ma.matched_curr_conversion_type,
                                                     ma.matched_curr_conversion_date))
          FROM inl_corr_matches_v a
         WHERE a.match_amount_id = ma.match_amount_id ) tax_amt,
        ma.matched_curr_code                currency_code,
        ma.matched_curr_conversion_type     currency_conversion_type,
        ma.matched_curr_conversion_date     currency_conversion_date,
        ma.matched_curr_conversion_rate     currency_conversion_rate,
--
        ma.tax_code                          tax_code,
--        m.ship_header_id                    ship_header_id          , --BUG#8198498
        m.from_parent_table_name            source_parent_table_name,
        m.from_parent_table_id              source_parent_table_id,
        ma.nrec_tax_amt                     nrec_tax_amt,
        m.tax_amt_included_flag             tax_amt_included_flag,
        ma.charge_line_type_id              charge_line_type_id,
--
        clt.allocation_basis                allocation_basis,
        abv.base_uom_code                   base_uom_code,
        m.existing_match_info_flag          existing_match_info_flag
   INTO
        l_TxLn_Assoc.matched_amt               ,
        l_TxLn_Assoc.currency_code             ,
        l_TxLn_Assoc.currency_conversion_type  ,
        l_TxLn_Assoc.currency_conversion_date  ,
        l_TxLn_Assoc.currency_conversion_rate  ,
--
        l_TxLn_Assoc.tax_code                  ,
--        l_TxLn_Assoc.inl_Assoc.ship_header_id  ,--BUG#8198498
        l_TxLn_Assoc.source_parent_table_name  ,
        l_TxLn_Assoc.source_parent_table_id    ,
        l_TxLn_Assoc.nrec_tax_amt              ,
        l_TxLn_Assoc.tax_amt_included_flag     ,
        l_charge_line_type_id                  ,
--
        l_TxLn_Assoc.inl_Assoc.allocation_basis,
        l_TxLn_Assoc.inl_Assoc.allocation_uom_code,
        l_existing_match_info_flag
    FROM
        inl_match_amounts ma , -- Bug #9179775
        inl_matches m               ,
        inl_charge_line_types_vl clt,
        inl_allocation_basis_vl  abv
    WHERE
        abv.allocation_basis_code     = clt.allocation_basis
        AND clt.charge_line_type_id   = m.charge_line_type_id
        AND m.match_amount_id         = ma.match_amount_id
        AND ma.match_amount_id        = p_match_amount_id
        AND m.match_id in (select min(match_id) -- BUG#8411594
                            FROM inl_corr_matches_v m
                           WHERE m.match_amount_id = p_match_amount_id);

    INL_LOGGING_PVT.Log_Variable (
        p_module_name     => g_module_name,
        p_procedure_name  => l_api_name,
        p_var_name        => 'l_existing_match_info_flag',
        p_var_value       => l_existing_match_info_flag) ;


    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'l_TxLn_Assoc.source_parent_table_name',
        p_var_value => l_TxLn_Assoc.source_parent_table_name
    ) ;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'l_TxLn_Assoc.source_parent_table_id',
        p_var_value => l_TxLn_Assoc.source_parent_table_id
    ) ;

    IF (l_existing_match_info_flag = 'Y') THEN

        -- Tax has been already processed
        l_debug_info := 'Existing match info flag';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_debug_info => l_debug_info
        ) ;
-- BUG#8411594
        -- a)Verify if exists any new match in this match amount
        -- a.1) Get the last match_amount_id
        SELECT max(match_amount_id)
        INTO l_prev_match_amount_id
        FROM inl_matches m
        WHERE m.charge_line_type_id = l_charge_line_type_id
        AND  nvl(m.tax_code,'-9') = nvl(l_TxLn_Assoc.tax_code,'-9')
        AND  m.match_amount_id <> p_match_amount_id
        AND adj_already_generated_flag = 'Y'
        AND (m.from_parent_table_name, m.from_parent_table_id)
        IN (SELECT m2.from_parent_table_name, m2.from_parent_table_id
            FROM inl_matches m2
            WHERE m2.match_amount_id = p_match_amount_id)
        ;

        INL_LOGGING_PVT.Log_Variable (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_var_name => 'l_prev_match_amount_id',
            p_var_value => l_prev_match_amount_id
        ) ;

        -- a.2) Count the new matches
        SELECT nvl(count(*),0)
        INTO l_count_new_matches
        FROM inl_matches m
        WHERE m.match_amount_id = p_match_amount_id
        AND not exists (SELECT 1
                        FROM inl_matches m2
                        WHERE m2.match_amount_id          = l_prev_match_amount_id
                        AND m2.from_parent_table_name     = m.from_parent_table_name
                        AND m2.from_parent_table_id       = m.from_parent_table_id
                        AND m2.to_parent_table_name       = m.to_parent_table_name
                        AND m2.to_parent_table_id         = m.to_parent_table_id
                        )
        ;
        -- b)Verify if any old match has been deleted
        IF l_count_new_matches = 0 THEN
            -- b.1) Count old matches
            SELECT nvl(count(*),0)
            INTO l_count_new_matches
            FROM inl_matches m
            WHERE m.match_amount_id = l_prev_match_amount_id
            AND not exists (SELECT 1
                            FROM inl_matches m2
                            WHERE m2.match_amount_id          = p_match_amount_id
                            AND m2.from_parent_table_name     = m.from_parent_table_name
                            AND m2.from_parent_table_id       = m.from_parent_table_id
                            AND m2.to_parent_table_name       = m.to_parent_table_name
                            AND m2.to_parent_table_id         = m.to_parent_table_id
                            )
            ;
        END IF;
        -- c) if exists any new match zeroes the previous charge line
        IF l_count_new_matches > 0 THEN

            l_debug_info := 'Calling Zero_TaxLinesPerMatchAmt';
            INL_LOGGING_PVT.Log_Statement (
                p_module_name => g_module_name,
                p_procedure_name => l_api_name,
                p_debug_info => l_debug_info
            ) ;
            Zero_TaxLinesPerMatchAmt (
                p_match_Amount_id    => l_prev_match_amount_id,
                p_adjustment_num     => p_adjustment_num,
                x_return_status      => l_debug_info
            );
        END IF;
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
-- BUG#8411594
    END IF;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'l_count_new_matches',
        p_var_value => l_count_new_matches
    ) ;
-- ====================
    IF (l_existing_match_info_flag = 'Y')
        AND l_count_new_matches = 0 THEN  -- BUG#8411594
        -- Charge has been already processed
        l_debug_info := 'Existing match info flag';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_debug_info => l_debug_info
        ) ;
        SELECT tl.tax_line_id, tl.tax_line_num
        INTO   l_TxLn_Assoc.parent_tax_line_id, l_TxLn_Assoc.tax_line_num
        FROM inl_matches m,
             inl_adj_tax_lines_v tl
        WHERE m.from_parent_table_name = l_TxLn_Assoc.source_parent_table_name
        AND   m.from_parent_table_id   = l_TxLn_Assoc.source_parent_table_id
        AND   m.match_id = (select max(m2.match_id)
                            FROM inl_matches m2
                            WHERE m2.from_parent_table_name = l_TxLn_Assoc.source_parent_table_name
                            AND   m2.from_parent_table_id   = l_TxLn_Assoc.source_parent_table_id
                            AND   m2.adj_already_generated_flag = 'Y'   -- BUG#8411723 => MURALI
                            )
        AND   tl.match_amount_id       = m.match_amount_id;
    ELSE
        l_TxLn_Assoc.parent_tax_line_id := NULL;
        l_TxLn_Assoc.tax_line_num       := NULL;
    END IF;
    l_TxLn_Assoc.match_id := NULL;
    l_TxLn_Assoc.match_amount_id := p_match_amount_id;
    -- Create_TxLines
    l_debug_info := 'Create_TxLines';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info => l_debug_info
    ) ;

    --BUG#8468830
    IF p_func_currency_code <> l_TxLn_Assoc.currency_code THEN
        l_garb := inl_landedcost_pvt.Converted_Amt (
                                    1,
                                    l_TxLn_Assoc.currency_code,
                                    p_func_currency_code,
                                    l_TxLn_Assoc.currency_conversion_type,
                                    l_TxLn_Assoc.currency_conversion_date,
                                    l_TxLn_Assoc.currency_conversion_rate);
    ELSE
        l_TxLn_Assoc.currency_conversion_type:= NULL;
        l_TxLn_Assoc.currency_conversion_rate:= NULL;
    END IF;
    --BUG#8468830

    Create_TxLines (
        p_TxLn_Assoc        => l_TxLn_Assoc,
        p_include_assoc     => 'N',
        p_adjustment_num    => p_adjustment_num,
        x_new_tax_line_id   => l_new_tax_line_id,
        x_return_status     => l_return_status) ;
    IF l_return_status                           = L_FND_RET_STS_ERROR THEN
        RAISE L_FND_EXC_ERROR;
    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
    -- It does not create associations for corrections neither to updates
    IF l_existing_match_info_flag = 'N'
       OR l_count_new_matches > 0   -- BUG#8411594
    THEN
        -- Create_associations for the match amount id
        l_debug_info := 'Create association lines to a match_amount_id';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_debug_info => l_debug_info
        ) ;
        OPEN c_matches_tl (p_match_amount_id) ;
        FETCH c_matches_tl BULK COLLECT INTO c_matches;
        CLOSE c_matches_tl;
        l_debug_info := c_matches.LAST||' match lines have been retrieved.';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_debug_info => l_debug_info
        ) ;
        IF NVL (c_matches.LAST, 0) > 0 THEN
            FOR i IN NVL (c_matches.FIRST, 0) ..NVL (c_matches.LAST, 0)
            LOOP
                l_TxLn_Assoc.inl_Assoc.ship_header_id       := c_matches(i).ship_header_id;   --BUG#8198498
                l_TxLn_Assoc.inl_Assoc.to_parent_table_name := c_matches(i).to_parent_table_name;
                l_TxLn_Assoc.inl_Assoc.to_parent_table_id   := c_matches(i).to_parent_table_id;
                -- Create Association Line
                l_debug_info := 'Create association line for the charge';
                INL_LOGGING_PVT.Log_Statement (
                    p_module_name => g_module_name,
                    p_procedure_name => l_api_name,
                    p_debug_info => l_debug_info
                ) ;
                l_debug_info := 'Creating association for Charge Id: '|| c_matches (i) .to_parent_table_id;
                INL_LOGGING_PVT.Log_Variable (
                    p_module_name     => g_module_name,
                    p_procedure_name  => l_api_name,
                    p_var_name        => l_debug_info,
                    p_var_value       => c_matches (i) .to_parent_table_id) ;
                Create_Assoc (
                    p_Assoc                   => l_TxLn_Assoc.inl_Assoc,
                    p_from_parent_table_name  => 'INL_TAX_LINES',
                    p_new_line_id             => l_new_tax_line_id,
                    x_return_status           => l_return_status) ;
            END LOOP;
        END IF;
    END IF;
    -- The estimated tax lines will made = 0 when as actual arrived on associated line
    -- i.e. when a charge became and actual value the estimated taxes will made 0 too
    -- Standard check of p_commit.
    IF FND_API.To_Boolean (p_commit) THEN
        COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data) ;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
EXCEPTION
WHEN L_FND_EXC_ERROR THEN
    -- Standard Expected Error Logging
    INL_LOGGING_PVT.Log_ExpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
    ROLLBACK TO Adjust_TaxLines_2_PVT;
    x_return_status                      := L_FND_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data) ;
WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError ( p_module_name => g_module_name, p_procedure_name => l_api_name) ;
    ROLLBACK TO Adjust_TaxLines_2_PVT;
    x_return_status                      := L_FND_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data) ;
WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
    ROLLBACK TO Adjust_TaxLines_2_PVT;
    x_return_status                                := L_FND_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level (
        p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
    ) THEN
        FND_MSG_PUB.Add_Exc_Msg (
            p_pkg_name        => g_pkg_name,
            p_procedure_name => l_api_name) ;
    END IF;
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data) ;
END Adjust_TaxLines;

-- API name   : Adjust_Lines
-- Type       : Private
-- Function   : Manages the Creation of Adjustment Lines for Shipment Lines and Charge Lines
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version                              IN NUMBER   Required
--              p_init_msg_list                            IN VARCHAR2 Optional  Default = L_FND_FALSE
--              p_commit                                   IN VARCHAR2 Optional  Default = L_FND_FALSE
--              p_ship_header_id                           IN  NUMBER,
-- OUT          x_return_status                            OUT NOCOPY VARCHAR2
--              x_msg_count                                OUT NOCOPY NUMBER
--              x_msg_data                                 OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Adjust_Lines(
    p_api_version    IN NUMBER,
    p_init_msg_list  IN VARCHAR2 := L_FND_FALSE,
    p_commit         IN VARCHAR2 := L_FND_FALSE,
    p_ship_header_id IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2
) IS
    l_api_name         CONSTANT VARCHAR2 (30) := 'Adjust_Lines';
    l_api_version      CONSTANT NUMBER        := 1.0;
    l_return_status    VARCHAR2 (1) ;
    l_msg_count        NUMBER;
    l_msg_data         VARCHAR2 (2000) ;
    l_debug_info       VARCHAR2 (200) ;

    l_initial_sysdate date:= TRUNC(SYSDATE);

    CURSOR c_match
    IS
        SELECT
            'B' Ttype,                --BUG#8198498
            m.match_id            ,
            m.correction_match_id ,
            NULL match_amount_id  ,  --BUG#8198498
            NVL(m.adj_group_date,l_initial_sysdate) adj_group_date,  --OPM Integration / dependence
            m.match_type_code     ,
            m.charge_line_type_id ,
            m.tax_code            ,
            m.to_parent_table_name,
            m.to_parent_table_id  ,
            sh.organization_id  --Bug#14044298
--Bug#14044298            gsb.currency_code func_currency_code  --BUG#8468830
        FROM
--Bug#14044298            inl_charge_lines cl ,
--Bug#14044298            inl_ship_lines sl   ,
            inl_ship_headers sh ,
            inl_corr_matches_v m
--Bug#14044298            org_organization_definitions ood,   --BUG#8468830
--Bug#14044298            gl_sets_of_books gsb                --BUG#8468830
        WHERE
            sh.ship_header_id                        = p_ship_header_id
--Bug#14044298            cl.charge_line_id (+)                   = DECODE (m.to_parent_table_name, 'INL_CHARGE_LINES', m.to_parent_table_id, NULL)
--Bug#14044298        AND sl.ship_line_id (+)                     = DECODE (m.to_parent_table_name, 'INL_SHIP_LINES', m.to_parent_table_id, NULL)
        AND sh.ship_header_id                       = m.ship_header_id
        AND m.ship_header_id                        = p_ship_header_id
        AND m.match_amount_id                      IS NULL
        AND m.match_type_code                      <> 'CORRECTION'
        AND NVL (m.adj_already_generated_flag, 'N') = 'N'
--Bug#14044298        AND gsb.set_of_books_id                     = ood.set_of_books_id
--Bug#14044298        AND ood.organization_id                     = sh.organization_id
      UNION
        SELECT DISTINCT
            'A' Ttype,                                       --BUG#8198498
            NULL               AS match_id            ,
            NULL               AS correction_match_id ,
            ma.match_amount_id AS match_amount_id     ,
            ma.adj_group_date  AS adj_group_date      ,  --OPM Integration
            m.match_type_code  AS match_type_code     ,
            NULL               AS charge_line_type_id ,
            NULL               AS tax_code            ,
            NULL               AS to_parent_table_name,
            NULL               AS to_parent_table_id  ,
            sh.organization_id  --Bug#14044298
--Bug#14044298            gsb.currency_code  AS func_currency_code  --BUG#8468830
        FROM
            inl_ship_headers sh,
            inl_match_amounts ma,
            inl_corr_matches_v m
--Bug#14044298            org_organization_definitions ood,   --BUG#8468830
--Bug#14044298            gl_sets_of_books gsb                --BUG#8468830
        WHERE
            sh.ship_header_id   = p_ship_header_id
        AND ma.match_amount_id  = m.match_amount_id
        AND m.ship_header_id    = p_ship_header_id
        AND m.match_type_code     <> 'CORRECTION'
        AND NVL (m.adj_already_generated_flag, 'N') = 'N'
--Bug#14044298        AND gsb.set_of_books_id        = ood.set_of_books_id
--Bug#14044298        AND ood.organization_id        = sh.organization_id
    ORDER BY Ttype,
             adj_group_date,          --OPM Integration
             match_id,
             match_amount_id;         --BUG#8198498, -- BUG#8411723 => MURALI
    TYPE c_match_type
    IS
    TABLE OF c_match%ROWTYPE;
    r_match c_match_type;

    TYPE match_ship_header_id_type
        IS RECORD (
            ship_header_id NUMBER,
            adjustment_num NUMBER
        )
    ;
    TYPE match_ship_header_id_tbl
    IS
    TABLE OF match_ship_header_id_type INDEX BY BINARY_INTEGER;
    match_ship_header_id_lst match_ship_header_id_tbl;
    --
    -- Create Adjustments for Shipment Lines and Charge Lines
    --
     l_func_currency_code VARCHAR2(5); --Bug#14044298
    l_adjust_updt_flag      VARCHAR2(1) := 'N';
    l_adjustment_num        NUMBER;
    l_adjustment_num_tmp    NUMBER;
    l_has_match_amt         VARCHAR2(1) := 'N';
    l_match_amt_proc_same_adj_num VARCHAR2(1) := 'N';
    l_match_ship_header_id_ind NUMBER :=0 ;
    l_adj_group_date_ant    DATE;     --OPM Integration
    l_adj_group_date        DATE;     --dependence
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc ( p_module_name => g_module_name, p_procedure_name => l_api_name) ;
    -- Standard Start of API savepoint
    SAVEPOINT Adjust_Lines_PVT;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean (p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    -- Check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (p_current_version_number => l_api_version, p_caller_version_number => p_api_version, p_api_name => l_api_name, p_pkg_name => g_pkg_name) THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;
    -- API Body
    BEGIN
        l_debug_info := 'Create Adjustments for Shipment Lines and Charge Lines';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_debug_info => l_debug_info
        ) ;
--
--BUG#8198498
--
        OPEN c_match;
        FETCH c_match BULK COLLECT INTO r_match;
        CLOSE c_match;
        l_debug_info := 'p_ship_header_id';
        INL_LOGGING_PVT.Log_Variable (
            p_module_name    => g_module_name,
            p_procedure_name => l_api_name,
            p_var_name       => l_debug_info,
            p_var_value      => p_ship_header_id
        );
        l_debug_info := r_match.LAST||' match lines have been retrieved.';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_debug_info => l_debug_info
        ) ;
        IF NVL (r_match.LAST, 0) > 0 THEN
            IF r_match(1).ttype = 'B' THEN -- no match_amounts to process
                l_has_match_amt := 'N';
            ELSE
                l_has_match_amt := 'Y';
                -- Verify if all match_amounts could be processed with the same adjustment number
                -- they will, if all matches have the same adj_group_date
                SELECT  -- dependence
                    DECODE(COUNT(DISTINCT(NVL(mFromMA.adj_group_date,l_initial_sysdate))),1,'Y','N')
                INTO
                    l_match_amt_proc_same_adj_num
                FROM
                    inl_match_amounts ma,
                    inl_corr_matches_v m,
                    inl_corr_matches_v mFromMA
                WHERE m.ship_header_id   = p_ship_header_id
                AND m.match_amount_id    = ma.match_amount_id
                AND m.match_type_code    <> 'CORRECTION'
                AND NVL (m.adj_already_generated_flag, 'N') = 'N'
                AND mFromMA.match_amount_id = ma.match_amount_id
                AND NVL (mFromMA.adj_already_generated_flag, 'N') = 'N'
                ;
                l_debug_info := 'l_match_amt_proc_same_adj_num';
                INL_LOGGING_PVT.Log_Variable (
                    p_module_name    => g_module_name,
                    p_procedure_name => l_api_name,
                    p_var_name       => l_debug_info,
                    p_var_value      => l_match_amt_proc_same_adj_num
                );
            END IF;

            l_debug_info := 'l_has_match_amt';
            INL_LOGGING_PVT.Log_Variable (
                p_module_name    => g_module_name,
                p_procedure_name => l_api_name,
                p_var_name       => l_debug_info,
                p_var_value      => l_has_match_amt
            );
            FOR i IN NVL (r_match.FIRST, 0) ..NVL (r_match.LAST, 0)
            LOOP
                l_debug_info := ' Begin the loop.';
                INL_LOGGING_PVT.Log_Statement (
                    p_module_name => g_module_name,
                    p_procedure_name => l_api_name,
                    p_debug_info => l_debug_info
                ) ;
                IF r_match(i).ttype = 'B' THEN -- isn't match_amt
                    IF NVL(l_adjustment_num,0) = 0 THEN
                        l_adj_group_date_ant := r_match(i).adj_group_date;   --OPM Integration
                        SELECT NVL(adjustment_num,0) + 1
                        INTO l_adjustment_num
                        FROM inl_ship_headers
                        WHERE ship_header_id = p_ship_header_id FOR UPDATE;
                        l_debug_info := 'l_adjustment_num';
                        INL_LOGGING_PVT.Log_Variable (
                            p_module_name    => g_module_name,
                            p_procedure_name => l_api_name,
                            p_var_name       => l_debug_info,
                            p_var_value      => l_adjustment_num
                        );
                    -- VERIFY IF adj_group_date IS DIFFERENT
                    ELSIF l_adj_group_date_ant IS NULL
                          OR l_adj_group_date_ant <> r_match(i).adj_group_date THEN   --OPM Integration
                        l_adj_group_date_ant := r_match(i).adj_group_date;
                        l_adjustment_num := l_adjustment_num + 1;
                        l_debug_info := ' New adjustment_num';
                        INL_LOGGING_PVT.Log_Statement (
                            p_module_name => g_module_name,
                            p_procedure_name => l_api_name,
                            p_debug_info => l_debug_info
                        ) ;
                        l_debug_info := 'l_adjustment_num';
                        INL_LOGGING_PVT.Log_Variable (
                            p_module_name    => g_module_name,
                            p_procedure_name => l_api_name,
                            p_var_name       => l_debug_info,
                            p_var_value      => l_adjustment_num
                        );
                    END IF;
                    IF l_has_match_amt = 'Y' THEN
                        l_match_ship_header_id_ind:=l_match_ship_header_id_ind+1;
                        match_ship_header_id_lst(l_match_ship_header_id_ind).ship_header_id:= p_ship_header_id;
                        match_ship_header_id_lst(l_match_ship_header_id_ind).adjustment_num:= l_adjustment_num;

                        l_debug_info := 'match_ship_header_id_lst(l_match_ship_header_id_ind).ship_header_id';
                        INL_LOGGING_PVT.Log_Variable (
                            p_module_name    => g_module_name,
                            p_procedure_name => l_api_name,
                            p_var_name       => l_debug_info,
                            p_var_value      => match_ship_header_id_lst(l_match_ship_header_id_ind).ship_header_id
                        );
                    END IF;
                ELSE  -- is a match_amt
                    IF l_match_amt_proc_same_adj_num = 'Y' THEN -- FETCH ONCE
                        IF NVL(l_adjustment_num,0) = 0 THEN -- no adjustment_num catched yet
                            l_adj_group_date_ant := r_match(i).adj_group_date;  --Bug#9141681
                        -- 1 Verify the next adjustment num
                            l_debug_info := ' Getting adjustment_num (match_amounts)';
                            INL_LOGGING_PVT.Log_Statement (
                                p_module_name => g_module_name,
                                p_procedure_name => l_api_name,
                                p_debug_info => l_debug_info
                            ) ;
                            SELECT NVL(MAX(sh.adjustment_num),0)+1
                            INTO l_adjustment_num
                            FROM inl_ship_headers sh
                            WHERE sh.ship_header_id
                                    IN (select m1.ship_header_id
                                        from inl_corr_matches_v m1
                                        where m1.match_amount_id
                                            IN (select DISTINCT(ma.match_amount_id)
                                                from inl_match_amounts ma, -- Bug #9179775
                                                    inl_corr_matches_v m2
                                                WHERE m2.match_amount_id = ma.match_amount_id
                                                AND m2.ship_header_id = p_SHIP_HEADER_ID
                                                AND m2.match_type_code    <> 'CORRECTION'
                                                AND NVL(m2.adj_already_generated_flag, 'N') = 'N')
                                            AND m1.match_type_code    <> 'CORRECTION')
                            ;

                            l_debug_info := 'l_adjustment_num';
                            INL_LOGGING_PVT.Log_Variable (
                                p_module_name    => g_module_name,
                                p_procedure_name => l_api_name,
                                p_var_name       => l_debug_info,
                                p_var_value      => l_adjustment_num
                            );
                            -- Getting the ship_header_ids that will be impacted for this matches in order to record the new adjustment_num
                             -- The main problem in Bug#14226493 refers to the query below;
                            -- the inner select ensure that the match amount in analysis is not a CORRECTION
                            -- then, in the outer select, we don't need verify the type and we can use the table
                            -- rather than the view
                             /*--Bug#14044298 BEGIN
                            FOR C_CUR_HEAD IN (select m1.ship_header_id
                                        from inl_corr_matches_v m1
                                        where m1.match_amount_id
                                            IN (select DISTINCT(ma.match_amount_id)
                                                from inl_match_amounts ma, -- Bug #9188553
                                                    inl_corr_matches_v m2
                                                WHERE m2.match_amount_id = ma.match_amount_id
                                                AND m2.ship_header_id = p_SHIP_HEADER_ID
                                                AND m2.match_type_code    <> 'CORRECTION'
                                                AND NVL(m2.adj_already_generated_flag, 'N') = 'N')
                                            AND m1.match_type_code    <> 'CORRECTION') LOOP
                               */
                                FOR C_CUR_HEAD IN (select m1.ship_header_id
                                        from inl_matches m1
                                        where m1.match_amount_id
                                            IN (select DISTINCT(ma.match_amount_id)
                                                from inl_match_amounts ma, -- Bug #9188553
                                                    inl_corr_matches_v m2
                                                WHERE m2.match_amount_id = ma.match_amount_id
                                                AND m2.ship_header_id = p_SHIP_HEADER_ID
                                                AND m2.match_type_code    <> 'CORRECTION'
                                                AND NVL(m2.adj_already_generated_flag, 'N') = 'N')) LOOP
                            --Bug#14044298 END

                                l_match_ship_header_id_ind:=l_match_ship_header_id_ind+1;
                                match_ship_header_id_lst(l_match_ship_header_id_ind).ship_header_id:= C_CUR_HEAD.ship_header_id;
                                match_ship_header_id_lst(l_match_ship_header_id_ind).adjustment_num:= l_adjustment_num;

                                l_debug_info := 'C_CUR_HEAD.ship_header_id';
                                INL_LOGGING_PVT.Log_Variable (
                                    p_module_name    => g_module_name,
                                    p_procedure_name => l_api_name,
                                    p_var_name       => l_debug_info,
                                    p_var_value      => C_CUR_HEAD.ship_header_id
                                );
                            END LOOP;
                        END IF;
                    ELSE  -- IF l_match_amt_proc_same_adj_num = 'N' THEN
                    -- fetch every time, because the group of matches from this match_amount
                    -- could be different from the previous one
                        l_debug_info := ' Getting the MAX adjustment_num for this group (match_amounts)';
                        INL_LOGGING_PVT.Log_Statement (
                            p_module_name => g_module_name,
                            p_procedure_name => l_api_name,
                            p_debug_info => l_debug_info
                        ) ;
                        l_debug_info := 'r_match(i).match_amount_id';
                        INL_LOGGING_PVT.Log_Variable (
                            p_module_name    => g_module_name,
                            p_procedure_name => l_api_name,
                            p_var_name       => l_debug_info,
                            p_var_value      => r_match(i).match_amount_id
                        );
                        SELECT NVL(MAX(sh.adjustment_num),0)
                        INTO l_adjustment_num_tmp
                        FROM inl_ship_headers sh
                        WHERE sh.ship_header_id
                                IN (SELECT m1.ship_header_id
                                    FROM inl_corr_matches_v m1
                                    WHERE m1.match_type_code    <> 'CORRECTION'
                                    AND m1.match_amount_id = r_match(i).match_amount_id)
                        ;

                        l_debug_info := 'l_adjustment_num_tmp';
                        INL_LOGGING_PVT.Log_Variable (
                            p_module_name    => g_module_name,
                            p_procedure_name => l_api_name,
                            p_var_name       => l_debug_info,
                            p_var_value      => l_adjustment_num_tmp
                        );
                        l_adj_group_date := r_match(i).adj_group_date;
                        IF r_match(i).adj_group_date IS NULL THEN  -- dependence
                            BEGIN
                                SELECT
                                    DISTINCT(m.adj_group_date)
                                INTO
                                    l_adj_group_date
                                FROM
                                    inl_corr_matches_v m
                                WHERE m.match_amount_id    = r_match(i).match_amount_id
                                AND m.match_type_code    <> 'CORRECTION'
                                AND NVL (m.adj_already_generated_flag, 'N') = 'N';
                            EXCEPTION
                                WHEN OTHERS THEN
                                    l_adj_group_date := NULL;
                            END;
                        END IF;
                        IF l_adjustment_num_tmp >= NVL(l_adjustment_num,0) THEN
                            l_adjustment_num := l_adjustment_num_tmp + 1;
                        ELSIF l_adj_group_date IS NULL
                            OR l_adj_group_date_ant IS NULL
                            OR r_match(i).adj_group_date <> l_adj_group_date_ant
                        THEN
                            l_adjustment_num := l_adjustment_num + 1;
                        END IF;
                        l_adj_group_date_ant := r_match(i).adj_group_date;
                        l_debug_info := 'l_adjustment_num';
                        INL_LOGGING_PVT.Log_Variable (
                            p_module_name    => g_module_name,
                            p_procedure_name => l_api_name,
                            p_var_name       => l_debug_info,
                            p_var_value      => l_adjustment_num
                        );
                        l_debug_info := 'l_adj_group_date_ant';
                        INL_LOGGING_PVT.Log_Variable (
                            p_module_name    => g_module_name,
                            p_procedure_name => l_api_name,
                            p_var_name       => l_debug_info,
                            p_var_value      => l_adj_group_date_ant
                        );

                        -- Getting the ship_header_ids that will be impact for this matches in order to record the new adjustment_num
                        FOR C_CUR_HEAD IN (select m1.ship_header_id
                                            from inl_corr_matches_v m1
                                            where m1.match_amount_id
                                            IN (SELECT m2.match_amount_id
                                                FROM inl_corr_matches_v m2
                                                WHERE m2.match_type_code    <> 'CORRECTION'
                                                AND m2.match_amount_id = r_match(i).match_amount_id)) LOOP

                            l_match_ship_header_id_ind:=l_match_ship_header_id_ind+1;
                            match_ship_header_id_lst(l_match_ship_header_id_ind).ship_header_id:= C_CUR_HEAD.ship_header_id;
                            match_ship_header_id_lst(l_match_ship_header_id_ind).adjustment_num:= l_adjustment_num;
                            l_debug_info := 'match_ship_header_id_lst(l_match_ship_header_id_ind).ship_header_id';
                            INL_LOGGING_PVT.Log_Variable (
                                p_module_name    => g_module_name,
                                p_procedure_name => l_api_name,
                                p_var_name       => l_debug_info,
                                p_var_value      => match_ship_header_id_lst(l_match_ship_header_id_ind).ship_header_id
                            );


                        END LOOP;
                    END IF;
                END IF;
--
--BUG#8198498
--

                INL_LOGGING_PVT.Log_Variable (
                    p_module_name => g_module_name,
                    p_procedure_name => l_api_name,
                    p_var_name => 'r_match('||i||').match_amount_id',
                    p_var_value => r_match(i).match_amount_id
                );

                INL_LOGGING_PVT.Log_Variable (
                    p_module_name           => g_module_name,
                    p_procedure_name        => l_api_name,
                    p_var_name             => 'r_match('||i||').to_parent_table_id',
                    p_var_value             => TO_CHAR (r_match(i).to_parent_table_id)
                ) ;

--Bug#14044298 BEG
                IF l_func_currency_code IS NULL
                THEN
                    INL_LOGGING_PVT.Log_Variable (
                        p_module_name           => g_module_name,
                        p_procedure_name        => l_api_name,
                        p_var_name             => 'r_match('||i||').organization_id',
                        p_var_value             => r_match(i).organization_id
                    ) ;
                    SELECT gsb.currency_code
                    INTO l_func_currency_code
                    FROM
                        org_organization_definitions ood,
                        gl_sets_of_books gsb
                    WHERE
                        gsb.set_of_books_id = ood.set_of_books_id
                    AND ood.organization_id = r_match(i).organization_id;
                    INL_LOGGING_PVT.Log_Variable (
                        p_module_name           => g_module_name,
                        p_procedure_name        => l_api_name,
                        p_var_name             => 'l_func_currency_code',
                        p_var_value             => l_func_currency_code
                    ) ;
                END IF;
--Bug#14044298 END

                IF r_match(i).match_type_code = 'ITEM' THEN
                    l_adjust_updt_flag      := 'Y';
                    Adjust_ShipLines (
                        p_api_version       => 1.0,
                        p_init_msg_list     => L_FND_FALSE,
                        p_commit            => L_FND_FALSE,
                        p_match_id          => r_match(i).match_id,
                        p_adjustment_num    => l_adjustment_num,
                        p_func_currency_code=> l_func_currency_code, --Bug#14044298 r_match(i).func_currency_code, --BUG#8468830
                        x_return_status     => l_return_status,
                        x_msg_count         => l_msg_count,
                        x_msg_data          => l_msg_data
                    ) ;
                ELSIF r_match(i).match_type_code = 'CHARGE' AND r_match(i).match_amount_id IS NULL THEN
                    l_adjust_updt_flag  := 'Y';
                    Adjust_ChargeLines (
                        p_api_version       => 1.0,
                        p_init_msg_list     => L_FND_FALSE,
                        p_commit            => L_FND_FALSE,
                        p_match_id          => r_match(i).match_id,
                        p_adjustment_num    => l_adjustment_num,
                        p_func_currency_code=> l_func_currency_code, --Bug#14044298 r_match(i).func_currency_code, --BUG#8468830
                        x_return_status     => l_return_status,
                        x_msg_count         => l_msg_count,
                        x_msg_data          => l_msg_data
                    ) ;
                ELSIF r_match(i).match_type_code = 'CHARGE' AND r_match(i).match_amount_id IS NOT NULL THEN
                    l_adjust_updt_flag := 'Y';
                    Adjust_ChargeLines (
                        p_api_version       => 1.0,
                        p_init_msg_list     => L_FND_FALSE,
                        p_commit            => L_FND_FALSE,
                        p_match_amount_id   => r_match(i).match_amount_id,
                        p_adjustment_num    => l_adjustment_num,
                        p_func_currency_code=> l_func_currency_code, --Bug#14044298  r_match(i).func_currency_code, --BUG#8468830
                        x_return_status     => l_return_status,
                        x_msg_count         => l_msg_count,
                        x_msg_data          => l_msg_data
                    ) ;
                ELSIF r_match(i).match_type_code = 'TAX' AND r_match(i).match_amount_id IS NOT NULL THEN
                    l_adjust_updt_flag  := 'Y';
                    Adjust_TaxLines (
                        p_api_version       => 1.0,
                        p_init_msg_list     => L_FND_FALSE,
                        p_commit            => L_FND_FALSE,
                        p_match_amount_id   => r_match(i).match_amount_id,
                        p_adjustment_num    => l_adjustment_num,
                        p_func_currency_code=> l_func_currency_code, --Bug#14044298  r_match(i).func_currency_code, --BUG#8468830
                        x_return_status     => l_return_status,
                        x_msg_count         => l_msg_count,
                        x_msg_data          => l_msg_data
                    ) ;
                ELSIF r_match(i).match_type_code = 'TAX' THEN
                    l_adjust_updt_flag  := 'Y';
                    Adjust_TaxLines (
                        p_api_version       => 1.0,
                        p_init_msg_list     => L_FND_FALSE,
                        p_commit            => L_FND_FALSE,
                        p_match_id          => r_match(i).match_id,
                        p_adjustment_num    => l_adjustment_num,
                         p_func_currency_code=> l_func_currency_code, --Bug#14044298  r_match(i).func_currency_code, --BUG#8468830
                        x_return_status     => l_return_status,
                        x_msg_count         => l_msg_count,
                        x_msg_data          => l_msg_data
                    ) ;
                END IF;

                -- If any errors happen abort API.
                IF l_return_status = L_FND_RET_STS_ERROR THEN
                    RAISE L_FND_EXC_ERROR;
                ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                    RAISE L_FND_EXC_UNEXPECTED_ERROR;
                END IF;
                -- Flag the matches that already generated ajustments
                UPDATE inl_matches m
                SET m.adj_already_generated_flag = 'Y'             ,
                    m.adjustment_num             = l_adjustment_num, --lcm/opm integration
                    m.last_updated_by            = L_FND_USER_ID,
                    m.last_update_date           = SYSDATE
                  WHERE m.match_id               = NVL (r_match(i).correction_match_id, r_match(i).match_id)
                    OR NVL(m.match_amount_id,-1) = NVL(r_match(i).match_amount_id,-2);
            END LOOP;
            l_debug_info := 'Update Shipment Header Adjustment Number';
            INL_LOGGING_PVT.Log_Statement (
                p_module_name => g_module_name,
                p_procedure_name => l_api_name,
                p_debug_info => l_debug_info
            ) ;
            -- Update Shipment Header Adjustment Number
            IF l_adjust_updt_flag = 'Y' THEN
                IF l_has_match_amt = 'Y' THEN
                    IF NVL (match_ship_header_id_lst.LAST, 0) > 0 THEN
                        FOR i IN NVL (match_ship_header_id_lst.FIRST, 0) ..NVL (match_ship_header_id_lst.LAST, 0)
                        LOOP
                            UPDATE inl_ship_headers
                            SET adjustment_num     = match_ship_header_id_lst(i).adjustment_num
                            WHERE ship_header_id = match_ship_header_id_lst(i).ship_header_id;

                            INL_LOGGING_PVT.Log_Variable (
                                p_module_name => g_module_name,
                                p_procedure_name => l_api_name,
                                p_var_name => 'match_ship_header_id_lst('||i||').adjustment_num',
                                p_var_value => match_ship_header_id_lst(i).adjustment_num
                            );

                            INL_LOGGING_PVT.Log_Variable (
                                p_module_name => g_module_name,
                                p_procedure_name => l_api_name,
                                p_var_name => 'match_ship_header_id_lst('||i||').ship_header_id',
                                p_var_value => match_ship_header_id_lst(i).ship_header_id
                            );

                        END LOOP;
                    END IF;
                ELSE
                    UPDATE inl_ship_headers
                    SET adjustment_num     = l_adjustment_num
                    WHERE ship_header_id = p_ship_header_id;
                END IF;
            END IF;
        END IF;
    END;
    -- End of API Body
    -- Standard check of p_commit.
    IF FND_API.To_Boolean (p_commit) THEN
        COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get ( p_encoded => L_FND_FALSE, p_count => x_msg_count, p_data => x_msg_data) ;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc ( p_module_name => g_module_name, p_procedure_name => l_api_name) ;
EXCEPTION
WHEN L_FND_EXC_ERROR THEN
    -- Standard Expected Error Logging
    INL_LOGGING_PVT.Log_ExpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
    ROLLBACK TO Adjust_Lines_PVT;
    x_return_status := L_FND_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data) ;
WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError ( p_module_name => g_module_name, p_procedure_name => l_api_name) ;
    ROLLBACK TO Adjust_Lines_PVT;
    x_return_status                      := L_FND_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_encoded => L_FND_FALSE, p_count => x_msg_count, p_data => x_msg_data) ;
WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError ( p_module_name => g_module_name, p_procedure_name => l_api_name) ;
    ROLLBACK TO Adjust_Lines_PVT;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level (
                p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
    ) THEN
        FND_MSG_PUB.Add_Exc_Msg (
            p_pkg_name        => g_pkg_name,
            p_procedure_name => l_api_name) ;
    END IF;
    FND_MSG_PUB.Count_And_Get ( p_encoded => L_FND_FALSE, p_count => x_msg_count, p_data => x_msg_data) ;
END Adjust_Lines;

-- START Bug 13914863
-- API name: Get_1aryQty
-- Type       : Public
-- Function   : Convert the Primary based on Transaction Qty and UOM
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version       IN NUMBER,
--              p_init_msg_list     IN VARCHAR2 := L_FND_FALSE,
--              p_commit            IN VARCHAR2 := L_FND_FALSE,
--              p_inventory_item_id IN NUMBER,
--              p_organization_id   IN NUMBER,
--              p_uom_code          IN VARCHAR2,
--              p_qty               IN NUMBER,
--              x_1ary_uom_code     OUT NOCOPY VARCHAR2,
--              x_1ary_qty          OUT NOCOPY NUMBER,
--              x_return_status     OUT NOCOPY VARCHAR2,
--              x_msg_count         OUT NOCOPY NUMBER,
--              x_msg_data          OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Get_1aryQty(p_api_version       IN NUMBER,
                      p_init_msg_list     IN VARCHAR2 := L_FND_FALSE,
                      p_commit            IN VARCHAR2 := L_FND_FALSE,
                      p_inventory_item_id IN NUMBER,
                      p_organization_id   IN NUMBER,
                      p_uom_code          IN VARCHAR2,
                      p_qty               IN NUMBER,
                      x_1ary_uom_code     OUT NOCOPY VARCHAR2,
                      x_1ary_qty          OUT NOCOPY NUMBER,
                      x_return_status     OUT NOCOPY VARCHAR2,
                      x_msg_count         OUT NOCOPY NUMBER,
                      x_msg_data          OUT NOCOPY VARCHAR2)
IS
l_debug_info VARCHAR2(240);
l_api_name CONSTANT VARCHAR2(30) := 'Get_1aryQty';
l_api_version CONSTANT NUMBER := 1.0;

BEGIN
    INL_LOGGING_PVT.Log_BeginProc (p_module_name => g_module_name,
                                   p_procedure_name => l_api_name);
    -- Standard Start of API savepoint
    SAVEPOINT Get_1aryQty_PVT;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean (p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    -- Check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (p_current_version_number => l_api_version,
                                        p_caller_version_number => p_api_version,
                                        p_api_name => l_api_name,
                                        p_pkg_name => g_pkg_name) THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize return status to SUCCESS
    x_return_status:= L_FND_RET_STS_SUCCESS;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'p_inventory_item_id',
        p_var_value => p_inventory_item_id) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'p_organization_id',
        p_var_value => p_organization_id) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'p_uom_code',
        p_var_value => p_uom_code) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'p_qty',
        p_var_value => p_qty) ;

    l_debug_info  := 'Get Primary UOM Code from MTL_SYSTEM_ITEMS_VL';
    INL_LOGGING_PVT.Log_Statement(p_module_name => g_module_name,
                                  p_procedure_name => l_api_name,
                                  p_debug_info => l_debug_info);
    SELECT msi.primary_uom_code
      INTO x_1ary_uom_code
      FROM mtl_system_items_vl msi
      WHERE msi.inventory_item_id = p_inventory_item_id
        AND msi.organization_id = p_organization_id;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name      => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'x_1ary_uom_code',
        p_var_value => x_1ary_uom_code) ;

    IF x_1ary_uom_code IS NOT NULL THEN
        l_debug_info := 'Before executing the Primary UOM convertion';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_debug_info => l_debug_info);

        INL_LOGGING_PVT.Log_APICallIn (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_call_api_name => 'INL_LANDEDCOST_PVT.Converted_Qty',
            p_in_param_name1 => 'p_organization_id',
            p_in_param_value1 => p_organization_id,
            p_in_param_name2 => 'p_inventory_item_id',
            p_in_param_value2 => p_inventory_item_id,
            p_in_param_name3 => 'p_qty',
            p_in_param_value3 => p_qty,
            p_in_param_name4 => 'p_uom_code',
            p_in_param_value4 => p_uom_code,
            p_in_param_name5 => 'x_1ary_uom_code',
            p_in_param_value5 => x_1ary_uom_code,
            p_in_param_name6 => NULL,
            p_in_param_value6 => NULL,
            p_in_param_name7 => NULL,
            p_in_param_value7 => NULL,
            p_in_param_name8 => NULL,
            p_in_param_value8 => NULL,
            p_in_param_name9 => NULL,
            p_in_param_value9 => NULL,
            p_in_param_name10 => NULL,
            p_in_param_value10 => NULL) ;

        x_1ary_qty := INL_LANDEDCOST_PVT.Converted_Qty (
                            p_organization_id => p_organization_id,
                            p_inventory_item_id => p_inventory_item_id,
                            p_qty => p_qty,
                            p_from_uom_code => p_uom_code,
                            P_to_uom_code => x_1ary_uom_code);

        INL_LOGGING_PVT.Log_Variable (p_module_name  => g_module_name,
                                      p_procedure_name => l_api_name,
                                      p_var_name => 'x_1ary_qty',
                                      p_var_value => x_1ary_qty) ;
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean (p_commit) THEN
        COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded => L_FND_FALSE,
                              p_count => x_msg_count,
                              p_data => x_msg_data) ;
    INL_LOGGING_PVT.Log_EndProc(p_module_name => g_module_name,
                                p_procedure_name => l_api_name) ;
EXCEPTION
WHEN L_FND_EXC_ERROR THEN
    INL_LOGGING_PVT.Log_ExpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
    x_return_status := L_FND_RET_STS_ERROR;
    ROLLBACK TO Get_1aryQty_PVT;
WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    ROLLBACK TO Get_1aryQty_PVT;
WHEN OTHERS THEN
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    ROLLBACK TO Get_1aryQty_PVT;
    IF FND_MSG_PUB.Check_Msg_Level (
        p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
    ) THEN
        FND_MSG_PUB.Add_Exc_Msg (
            p_pkg_name        => g_pkg_name,
            p_procedure_name => l_api_name) ;
    END IF;
END Get_1aryQty;

-- API name: Get_2aryQty
-- Type       : Public
-- Function   : Convert the Secondary based on Transaction Qty and UOM
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version       IN NUMBER,
--              p_init_msg_list     IN VARCHAR2 := L_FND_FALSE,
--              p_commit            IN VARCHAR2 := L_FND_FALSE,
--              p_inventory_item_id IN NUMBER,
--              p_organization_id   IN NUMBER,
--              p_uom_code          IN VARCHAR2,
--              p_qty               IN NUMBER,
--              x_1ary_uom_code     OUT NOCOPY VARCHAR2,
--              x_1ary_qty          OUT NOCOPY NUMBER,
--              x_return_status     OUT NOCOPY VARCHAR2,
--              x_msg_count         OUT NOCOPY NUMBER,
--              x_msg_data          OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Get_2aryQty(p_api_version       IN NUMBER,
                      p_init_msg_list     IN VARCHAR2 := L_FND_FALSE,
                      p_commit            IN VARCHAR2 := L_FND_FALSE,
                      p_inventory_item_id IN NUMBER,
                      p_organization_id   IN NUMBER,
                      p_uom_code          IN VARCHAR2,
                      p_qty               IN NUMBER,
                      x_2ary_uom_code     OUT NOCOPY VARCHAR2,
                      x_2ary_qty          OUT NOCOPY NUMBER,
                      x_return_status     OUT NOCOPY VARCHAR2,
                      x_msg_count         OUT NOCOPY NUMBER,
                      x_msg_data          OUT NOCOPY VARCHAR2)
IS
l_debug_info VARCHAR2(240);
l_api_name CONSTANT VARCHAR2(30) := 'Get_2aryQty';
l_api_version CONSTANT NUMBER := 1.0;

BEGIN
    INL_LOGGING_PVT.Log_BeginProc (p_module_name => g_module_name,
                                   p_procedure_name => l_api_name);
    -- Standard Start of API savepoint
    SAVEPOINT Get_2aryQty_PVT;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean (p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    -- Check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (p_current_version_number => l_api_version,
                                        p_caller_version_number => p_api_version,
                                        p_api_name => l_api_name,
                                        p_pkg_name => g_pkg_name) THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize return status to SUCCESS
    x_return_status:= L_FND_RET_STS_SUCCESS;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'p_inventory_item_id',
        p_var_value => p_inventory_item_id) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'p_organization_id',
        p_var_value => p_organization_id) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'p_uom_code',
        p_var_value => p_uom_code) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'p_qty',
        p_var_value => p_qty) ;

       l_debug_info  := 'Get Secondary UOM Code from MTL_SYSTEM_ITEMS_VL';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info => l_debug_info
    ) ;

    SELECT msi.secondary_uom_code
       INTO x_2ary_uom_code
       FROM mtl_system_items_vl msi
      WHERE msi.inventory_item_id = p_inventory_item_id
        AND msi.organization_id = p_organization_id;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name      => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'x_2ary_uom_code',
        p_var_value => x_2ary_uom_code) ;

    IF x_2ary_uom_code IS NOT NULL THEN
        l_debug_info := 'Before executing the Secondary UOM convertion';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_debug_info => l_debug_info
        ) ;
        INL_LOGGING_PVT.Log_APICallIn (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_call_api_name => 'INL_LANDEDCOST_PVT.Converted_Qty',
            p_in_param_name1 => 'p_organization_id',
            p_in_param_value1 => p_organization_id,
            p_in_param_name2 => 'p_inventory_item_id',
            p_in_param_value2 => p_inventory_item_id,
            p_in_param_name3 => 'p_qty',
            p_in_param_value3 => p_qty,
            p_in_param_name4 => 'p_uom_code',
            p_in_param_value4 => p_uom_code,
            p_in_param_name5 => 'x_2ary_uom_code',
            p_in_param_value5 => x_2ary_uom_code,
            p_in_param_name6 => NULL,
            p_in_param_value6 => NULL,
            p_in_param_name7 => NULL,
            p_in_param_value7 => NULL,
            p_in_param_name8 => NULL,
            p_in_param_value8 => NULL,
            p_in_param_name9 => NULL,
            p_in_param_value9 => NULL,
            p_in_param_name10 => NULL,
            p_in_param_value10 => NULL) ;
        x_2ary_qty := INL_LANDEDCOST_PVT.Converted_Qty (
            p_organization_id => p_organization_id,
            p_inventory_item_id => p_inventory_item_id,
            p_qty => p_qty,
            p_from_uom_code => p_uom_code,
            P_to_uom_code => x_2ary_uom_code) ;

        INL_LOGGING_PVT.Log_Variable (
            p_module_name  => g_module_name,
            p_procedure_name => l_api_name,
            p_var_name => 'x_2ary_qty',
            p_var_value => x_2ary_qty) ;
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean (p_commit) THEN
        COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded => L_FND_FALSE,
                              p_count => x_msg_count,
                              p_data => x_msg_data) ;
    INL_LOGGING_PVT.Log_EndProc(p_module_name => g_module_name,
                                p_procedure_name => l_api_name) ;
EXCEPTION
WHEN L_FND_EXC_ERROR THEN
    INL_LOGGING_PVT.Log_ExpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
    x_return_status := L_FND_RET_STS_ERROR;
    ROLLBACK TO Get_2aryQty_PVT;
WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    ROLLBACK TO Get_2aryQty_PVT;
WHEN OTHERS THEN
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    ROLLBACK TO Get_2aryQty_PVT;
    IF FND_MSG_PUB.Check_Msg_Level (
        p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
    ) THEN
        FND_MSG_PUB.Add_Exc_Msg (
            p_pkg_name        => g_pkg_name,
            p_procedure_name => l_api_name) ;
    END IF;
END Get_2aryQty;
-- END Bug 13914863


-- API name   : Get_1ary2aryQty
-- Type       : Private
-- Function   : Get    uom_class, uom_code, qty for 1ary and 2ary UOM
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version            IN NUMBER   Required
--              p_init_msg_list          IN VARCHAR2 Optional  Default = L_FND_FALSE
--              p_commit                 IN VARCHAR2 Optional  Default = L_FND_FALSE
--              p_inventory_item_id      IN NUMBER
--              p_organization_id        IN NUMBER
--              p_uom_code               IN VARCHAR2
--              p_qty                    IN NUMBER
-- OUT        :
--              x_1ary_uom_code         OUT NOCOPY VARCHAR2
--              x_1ary_qty              OUT NOCOPY NUMBER,
--              x_2ary_uom_code         OUT NOCOPY VARCHAR2
--              x_2ary_qty              OUT NOCOPY NUMBER,
--              x_return_status         OUT NOCOPY VARCHAR2
--              x_msg_count             OUT NOCOPY NUMBER
--              x_msg_data              OUT NOCOPY VARCHAR2
--
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Get_1ary2aryQty (
        p_api_version       IN NUMBER,
        p_init_msg_list     IN VARCHAR2 := L_FND_FALSE,
        p_commit            IN VARCHAR2 := L_FND_FALSE,
        p_inventory_item_id IN NUMBER,
        p_organization_id   IN NUMBER,
        p_uom_code          IN VARCHAR2,
        p_qty               IN NUMBER,
        x_1ary_uom_code OUT NOCOPY VARCHAR2,
        x_1ary_qty OUT NOCOPY      NUMBER,
        x_2ary_uom_code OUT NOCOPY VARCHAR2,
        x_2ary_qty OUT NOCOPY      NUMBER,
        x_return_status OUT NOCOPY VARCHAR2,
        x_msg_count OUT NOCOPY     NUMBER,
        x_msg_data OUT NOCOPY      VARCHAR2
) IS
    l_debug_info  VARCHAR2 (240) ;
    l_api_name    CONSTANT VARCHAR2 (30) := 'Get_1ary2aryQty';
    l_api_version CONSTANT NUMBER := 1.0;
    l_msg_data VARCHAR2 (200);
    l_msg_count NUMBER;
    l_return_status VARCHAR2 (1);
    l_1ary_uom_code VARCHAR2(3);
    l_1ary_qty NUMBER;
    l_2ary_uom_code VARCHAR2(3);
    l_2ary_qty NUMBER;
BEGIN
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
    -- Standard Start of API savepoint
    SAVEPOINT Get_1ary2aryQty_PVT;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean (p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    -- Check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
            p_current_version_number => l_api_version,
            p_caller_version_number => p_api_version,
            p_api_name => l_api_name,
            p_pkg_name => g_pkg_name
    ) THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize return status to SUCCESS
    x_return_status:= L_FND_RET_STS_SUCCESS;

    -- START Bug 13914863
    l_debug_info  := 'Call to Get_1aryQty API';
    INL_LOGGING_PVT.Log_Statement(p_module_name => g_module_name,
                                  p_procedure_name => l_api_name,
                                  p_debug_info => l_debug_info);
    Get_1aryQty(p_api_version       => 1.0,
                p_init_msg_list     => L_FND_FALSE,
                p_commit            => L_FND_FALSE,
                p_inventory_item_id => p_inventory_item_id,
                p_organization_id   => p_organization_id,
                p_uom_code          => p_uom_code,
                p_qty               => p_qty,
                x_1ary_uom_code     => l_1ary_uom_code,
                x_1ary_qty          => l_1ary_qty,
                x_return_status     => l_return_status,
                x_msg_count         => l_msg_count,
                x_msg_data          => l_msg_data);

    IF l_return_status = L_FND_RET_STS_ERROR THEN
        RAISE L_FND_EXC_ERROR;
    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;

    x_1ary_uom_code := l_1ary_uom_code;
    x_1ary_qty := l_1ary_qty;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'x_1ary_uom_code',
        p_var_value => x_1ary_uom_code) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'x_1ary_qty',
        p_var_value => x_1ary_qty) ;

    l_debug_info  := 'Call to Get_2aryQty API';
    INL_LOGGING_PVT.Log_Statement(p_module_name => g_module_name,
                                  p_procedure_name => l_api_name,
                                  p_debug_info => l_debug_info);

    Get_2aryQty(p_api_version       => 1.0,
                p_init_msg_list     => L_FND_FALSE,
                p_commit            => L_FND_FALSE,
                p_inventory_item_id => p_inventory_item_id,
                p_organization_id   => p_organization_id,
                p_uom_code          => p_uom_code,
                p_qty               => p_qty,
                x_2ary_uom_code     => l_2ary_uom_code,
                x_2ary_qty          => l_2ary_qty,
                x_return_status     => l_return_status,
                x_msg_count         => l_msg_count,
                x_msg_data          => l_msg_data);

    IF l_return_status = L_FND_RET_STS_ERROR THEN
        RAISE L_FND_EXC_ERROR;
    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;

    x_2ary_uom_code := l_2ary_uom_code;
    x_2ary_qty := l_2ary_qty;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'x_2ary_uom_code',
        p_var_value => x_2ary_uom_code) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'x_2ary_qty',
        p_var_value => x_2ary_qty) ;

    -- END Bug 13914863

    /*
    --
    -- Initialize return status to SUCCESS
    --
    x_return_status:= L_FND_RET_STS_SUCCESS;
    l_debug_info  := 'Getting 1ary and 2ary UOM Code from MTL tables';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info => l_debug_info
    ) ;
     SELECT msi.primary_uom_code,
        msi.secondary_uom_code
       INTO x_1ary_uom_code,
        x_2ary_uom_code
       FROM mtl_system_items_vl msi
      WHERE msi.inventory_item_id = p_inventory_item_id
        AND msi.organization_id   = p_organization_id;
    l_debug_info                                    := 'Have gotten from mtl_system_items_vl:';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info => l_debug_info
    ) ;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name      => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'x_1ary_uom_code',
        p_var_value => x_1ary_uom_code) ;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name      => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'x_2ary_uom_code',
        p_var_value => x_2ary_uom_code) ;
    IF x_1ary_uom_code                              IS NOT NULL THEN
        l_debug_info                                := 'Doing the 1ary UOM convertion';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_debug_info => l_debug_info
        ) ;
        INL_LOGGING_PVT.Log_APICallIn (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_call_api_name => 'INL_LANDEDCOST_PVT.Converted_Qty',
            p_in_param_name1 => 'p_organization_id',
            p_in_param_value1 => p_organization_id,
            p_in_param_name2 => 'p_inventory_item_id',
            p_in_param_value2 => p_inventory_item_id,
            p_in_param_name3 => 'p_qty',
            p_in_param_value3 => p_qty,
            p_in_param_name4 => 'p_uom_code',
            p_in_param_value4 => p_uom_code,
            p_in_param_name5 => 'x_1ary_uom_code',
            p_in_param_value5 => x_1ary_uom_code,
            p_in_param_name6 => NULL,
            p_in_param_value6 => NULL,
            p_in_param_name7 => NULL,
            p_in_param_value7 => NULL,
            p_in_param_name8 => NULL,
            p_in_param_value8 => NULL,
            p_in_param_name9 => NULL,
            p_in_param_value9 => NULL,
            p_in_param_name10 => NULL,
            p_in_param_value10 => NULL) ;
        x_1ary_qty := INL_LANDEDCOST_PVT.Converted_Qty (
                            p_organization_id => p_organization_id,
                            p_inventory_item_id => p_inventory_item_id,
                            p_qty => p_qty,
                            p_from_uom_code => p_uom_code,
                            P_to_uom_code => x_1ary_uom_code
                        ) ;
        l_debug_info  := 'x_1ary_qty';
        INL_LOGGING_PVT.Log_Variable (
            p_module_name  => g_module_name,
            p_procedure_name => l_api_name,
            p_var_name => 'x_1ary_qty',
            p_var_value => x_1ary_qty) ;
    END IF;
    --==========
    IF x_2ary_uom_code IS NOT NULL THEN
        l_debug_info := 'Doing the 2ary UOM convertion';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_debug_info => l_debug_info
        ) ;
        INL_LOGGING_PVT.Log_APICallIn (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_call_api_name => 'INL_LANDEDCOST_PVT.Converted_Qty',
            p_in_param_name1 => 'p_organization_id',
            p_in_param_value1 => p_organization_id,
            p_in_param_name2 => 'p_inventory_item_id',
            p_in_param_value2 => p_inventory_item_id,
            p_in_param_name3 => 'p_qty',
            p_in_param_value3 => p_qty,
            p_in_param_name4 => 'p_uom_code',
            p_in_param_value4 => p_uom_code,
            p_in_param_name5 => 'x_2ary_uom_code',
            p_in_param_value5 => x_2ary_uom_code,
            p_in_param_name6 => NULL,
            p_in_param_value6 => NULL,
            p_in_param_name7 => NULL,
            p_in_param_value7 => NULL,
            p_in_param_name8 => NULL,
            p_in_param_value8 => NULL,
            p_in_param_name9 => NULL,
            p_in_param_value9 => NULL,
            p_in_param_name10 => NULL,
            p_in_param_value10 => NULL) ;
        x_2ary_qty := INL_LANDEDCOST_PVT.Converted_Qty (
            p_organization_id => p_organization_id,
            p_inventory_item_id => p_inventory_item_id,
            p_qty => p_qty,
            p_from_uom_code => p_uom_code,
            P_to_uom_code => x_2ary_uom_code) ;

        INL_LOGGING_PVT.Log_Variable (
            p_module_name  => g_module_name,
            p_procedure_name => l_api_name,
            p_var_name => 'x_2ary_qty',
            p_var_value => x_2ary_qty) ;
    END IF;
    --==========
    */
    -- Standard check of p_commit.
    IF FND_API.To_Boolean (p_commit) THEN
        COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get (
        p_encoded        => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data) ;
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
EXCEPTION
WHEN L_FND_EXC_ERROR THEN
    INL_LOGGING_PVT.Log_ExpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
    x_return_status := L_FND_RET_STS_ERROR;
    ROLLBACK TO Get_1ary2aryQty_PVT;
WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    ROLLBACK TO Get_1ary2aryQty_PVT;
WHEN OTHERS THEN
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    ROLLBACK TO Get_1ary2aryQty_PVT;
    IF FND_MSG_PUB.Check_Msg_Level (
        p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
    ) THEN
        FND_MSG_PUB.Add_Exc_Msg (
            p_pkg_name        => g_pkg_name,
            p_procedure_name => l_api_name) ;
    END IF;
END Get_1ary2aryQty;
-- Utility name   : Get_SrcAvailableQty
-- Type       : Public
-- Function   : Returns the available quantity for a given PLL
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_line_src_type_code IN VARCHAR2
--              p_parent_id               IN NUMBER
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Get_SrcAvailableQty(
    p_ship_line_src_type_code IN VARCHAR2,
    p_parent_id               IN NUMBER
)  RETURN NUMBER IS
    l_program_name CONSTANT VARCHAR2(30) := 'Get_SrcAvailableQty';
    l_debug_info VARCHAR2(200);
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);
    l_available_qty NUMBER;
    l_tolerable_quantity NUMBER;
    l_unit_of_measure VARCHAR2(30);
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    -- Logging variables
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_ship_line_src_type_code',
        p_var_value => p_ship_line_src_type_code
    ) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_parent_id',
        p_var_value => p_parent_id) ;
    l_debug_info := 'Call INL_SHIPMENT_PVT.Get_AvailableQty';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_debug_info => l_debug_info) ;
    INL_SHIPMENT_PVT.Get_AvailableQty(
        p_api_version        => 1.0,
        p_init_msg_list      => L_FND_FALSE,
        p_commit             => L_FND_FALSE,
        p_ship_line_src_code => p_ship_line_src_type_code,
        p_parent_id          => p_parent_id,
        p_available_quantity => l_available_qty,
        p_tolerable_quantity => l_tolerable_quantity,
        p_unit_of_measure    => l_unit_of_measure,
        x_return_status      => l_return_status,
        x_msg_count          => l_msg_count,
        x_msg_data           => l_msg_data);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'l_available_qty',
        p_var_value => l_available_qty) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'l_tolerable_quantity',
        p_var_value => l_tolerable_quantity) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'l_unit_of_measure',
        p_var_value => l_unit_of_measure) ;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    RETURN NVL(l_available_qty,0);
END Get_SrcAvailableQty;

-- SCM-051
-- API name   : Adjust_ELCLines
-- Type       : Private
-- Function   : Manages the Creation of Adjustment Lines for Shipment Lines and Charge Lines
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version IN NUMBER   Required
--              p_init_msg_list IN VARCHAR2 Optional  Default = L_FND_FALSE
--              p_commit IN VARCHAR2 Optional  Default = L_FND_FALSE
--              p_ship_header_id IN  NUMBER,
-- OUT          x_return_status OUT NOCOPY VARCHAR2
--              x_msg_count OUT NOCOPY NUMBER
--              x_msg_data OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Adjust_ELCLines(p_api_version IN NUMBER,
                          p_init_msg_list IN VARCHAR2 := L_FND_FALSE,
                          p_commit IN VARCHAR2 := L_FND_FALSE,
                          p_ship_header_id IN NUMBER,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count OUT NOCOPY NUMBER,
                          x_msg_data OUT NOCOPY VARCHAR2
) IS
    l_program_name     CONSTANT VARCHAR2(30) := 'Adjust_ELCLines';
    l_api_version      CONSTANT NUMBER        := 1.0;
    l_return_status    VARCHAR2(1) ;
    l_msg_count        NUMBER;
    l_msg_data         VARCHAR2(2000);
    l_debug_info       VARCHAR2(200);

    l_count_assoc_changed NUMBER;
    l_count_charge_changed NUMBER;
    l_exist_associations NUMBER;
    l_adjustment_num NUMBER;
    l_charge_line_id NUMBER;
    l_association_id NUMBER;
    l_charge_line_num NUMBER;
    l_primary_unit_price NUMBER;
    l_secondary_unit_price NUMBER;

    -- Get ELC Adjustments for Shipment Lines
    CURSOR c_elc_adj_shiplines IS
      SELECT sl.ship_line_id, sl.new_txn_unit_price,
             sl.primary_qty, sl.secondary_qty, sl.txn_qty,
             sl.primary_uom_code, sl.secondary_uom_code
      FROM inl_ship_headers_all sh,
           inl_adj_ship_lines_v sl
      WHERE(sl.new_txn_unit_price IS NOT NULL
      OR sl.new_currency_conversion_type IS NOT NULL
      OR sl.new_currency_conversion_date IS NOT NULL
      OR sl.new_currency_conversion_rate IS NOT NULL)
      AND sl.ship_header_id = sh.ship_header_id
      AND sh.pending_update_flag = 'Y'
      AND sh.ship_header_id = p_ship_header_id;

    TYPE elc_adj_shiplines IS TABLE OF c_elc_adj_shiplines%ROWTYPE;
    l_elc_adj_shiplines elc_adj_shiplines;

    -- Get ELC Adjustments for Charge Lines
    CURSOR c_elc_adj_chlines IS
      SELECT DISTINCT charge_line_id
      FROM inl_ship_headers_all sh,
           inl_adj_charge_lines_v cl,
           inl_adj_associations_v a
      WHERE sh.ship_header_id = a.ship_header_id
      AND  a.from_parent_table_id = cl.charge_line_id
      AND sh.pending_update_flag = 'Y'
      AND a.from_parent_table_name = 'INL_CHARGE_LINES'
      AND a.ship_header_id = p_ship_header_id
      AND (cl.adjustment_type_flag IS NULL
      OR   cl.adjustment_type_flag <> 'Z')
      ORDER BY charge_line_id;

    TYPE elc_adj_chlines IS TABLE OF c_elc_adj_chlines%ROWTYPE;
    l_elc_adj_chlines elc_adj_chlines;

  -- ORA-00054 is the resource busy exception, which is raised when trying
  -- to lock a row that is already locked by another session.
  RESOURCE_BUSY EXCEPTION;
  PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -00054);

BEGIN

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(p_module_name => g_module_name,
                                  p_procedure_name => l_program_name) ;
    -- Standard Start of API savepoint
    SAVEPOINT Adjust_ELCLines_PVT;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean (p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    -- Check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(p_current_version_number => l_api_version,
                                       p_caller_version_number => p_api_version,
                                       p_api_name => l_program_name,
                                       p_pkg_name => g_pkg_name) THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;

    INL_LOGGING_PVT.Log_Variable(p_module_name => g_module_name,
                                 p_procedure_name => l_program_name,
                                 p_var_name => 'p_ship_header_id',
                                 p_var_value => p_ship_header_id);

    l_debug_info := 'Get next adjustment number';
    INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                   p_procedure_name => l_program_name,
                                   p_debug_info => l_debug_info);

    SELECT (ABS(adjustment_num) +1) *-1
    INTO l_adjustment_num
    FROM inl_ship_headers_all sh
    WHERE sh.ship_header_id = p_ship_header_id FOR UPDATE NOWAIT;

    INL_LOGGING_PVT.Log_Variable(p_module_name => g_module_name,
                                 p_procedure_name => l_program_name,
                                 p_var_name => 'l_adjustment_num',
                                 p_var_value => l_adjustment_num);

    -- Fetch ELC Adjusted Shipment Lines
    OPEN c_elc_adj_shiplines;
    FETCH c_elc_adj_shiplines BULK COLLECT INTO l_elc_adj_shiplines;
    CLOSE c_elc_adj_shiplines;

    -- Exist ship lines to be ELC adjusted
    IF NVL (l_elc_adj_shiplines.LAST, 0) > 0 THEN
        FOR i IN NVL(l_elc_adj_shiplines.FIRST, 0)..NVL(l_elc_adj_shiplines.LAST, 0)
        LOOP
            l_primary_unit_price := NULL;
            l_secondary_unit_price := NULL;
            IF l_elc_adj_shiplines(i).new_txn_unit_price IS NOT NULL THEN -- Price changed
                IF l_elc_adj_shiplines(i).primary_uom_code IS NOT NULL THEN
                   l_primary_unit_price := (l_elc_adj_shiplines(i).txn_qty * l_elc_adj_shiplines(i).new_txn_unit_price) / l_elc_adj_shiplines(i).primary_qty;
                END IF;

                IF l_elc_adj_shiplines(i).secondary_uom_code IS NOT NULL THEN
                   l_secondary_unit_price := (l_elc_adj_shiplines(i).txn_qty * l_elc_adj_shiplines(i).new_txn_unit_price) / l_elc_adj_shiplines(i).secondary_qty;
                END IF;
            END IF;

            INSERT INTO inl_ship_lines(
                               ship_header_id, -- 01
                               ship_line_group_id, -- 02
                               ship_line_id, -- 03
                               ship_line_num,  -- 04
                               ship_line_type_id,  -- 05
                               ship_line_src_type_code, -- 06
                               ship_line_source_id, -- 07
                               parent_ship_line_id, -- 08
                               adjustment_num, -- 09
                               match_id, -- 10
                               currency_code, -- 11
                               currency_conversion_type, -- 12
                               currency_conversion_date, -- 13
                               currency_conversion_rate, -- 14
                               inventory_item_id, -- 15
                               txn_qty, -- 16
                               txn_uom_code, -- 17
                               txn_unit_price, -- 18
                               primary_qty, -- 19
                               primary_uom_code, -- 20
                               primary_unit_price, -- 21
                               secondary_qty, -- 22
                               secondary_uom_code, -- 23
                               secondary_unit_price, -- 24
                               landed_cost_flag, -- 25
                               allocation_enabled_flag, -- 26
                               trx_business_category, -- 27
                               intended_use, -- 28
                               product_fiscal_class, -- 29
                               product_category, -- 30
                               product_type, -- 31
                               user_def_fiscal_class, -- 32
                               tax_classification_code, -- 33
                               assessable_value, -- 34
                               tax_already_calculated_flag, -- 35
                               ship_from_party_id, -- 36
                               ship_from_party_site_id, -- 37
                               ship_to_organization_id, -- 38
                               ship_to_location_id, -- 39
                               bill_from_party_id, -- 40
                               bill_from_party_site_id, -- 41
                               bill_to_organization_id, -- 42
                               bill_to_location_id, -- 43
                               poa_party_id, -- 44
                               poa_party_site_id, -- 45
                               poo_organization_id, -- 46
                               poo_location_id, -- 47
                               org_id,-- 48
                               ship_line_int_id, -- 49
                               interface_source_table, -- 50
                               interface_source_line_id, -- 51
                               created_by, -- 52
                               creation_date, -- 53
                               last_updated_by, -- 54
                               last_update_date, -- 55
                               last_update_login, -- 56
                               program_id, -- 57
                               program_update_date, -- 58
                               program_application_id, -- 59
                               request_id, -- 60
                               attribute_category, -- 61
                               attribute1, -- 62
                               attribute2, -- 63
                               attribute3, -- 64
                               attribute4, -- 65
                               attribute5, -- 66
                               attribute6, -- 67
                               attribute7, -- 68
                               attribute8, -- 69
                               attribute9, -- 70
                               attribute10, -- 71
                               attribute11, -- 72
                               attribute12, -- 73
                               attribute13, -- 74
                               attribute14, -- 75
                               attribute15, -- 76
                               nrq_zero_exception_flag, -- 77
                               new_txn_unit_price, -- 78
                               new_currency_conversion_type, -- 79
                               new_currency_conversion_date, -- 80
                               new_currency_conversion_rate -- 81
                             )
                       (SELECT p_ship_header_id, -- 01
                               sl.ship_line_group_id, -- 02
                               inl_ship_lines_all_s.nextval, -- 03
                               sl.ship_line_num, -- 04
                               sl.ship_line_type_id, -- 05
                               sl.ship_line_src_type_code, -- 06
                               sl.ship_line_source_id, -- 07
                               NVL(parent_ship_line_id, sl.ship_line_id), -- 08
                               l_adjustment_num, -- 09
                               sl.match_id, -- 10
                               sl.currency_code, -- 11
                               NVL(sl.new_currency_conversion_type, sl.currency_conversion_type), -- 12
                               NVL(sl.new_currency_conversion_date, sl.currency_conversion_date), -- 13
                               NVL(sl.new_currency_conversion_rate, sl.currency_conversion_rate), -- 14
                               sl.inventory_item_id, -- 15
                               sl.txn_qty, -- 16
                               sl.txn_uom_code, -- 17
                               NVL(sl.new_txn_unit_price, sl.txn_unit_price), -- 18
                               sl.primary_qty, -- 19
                               sl.primary_uom_code, -- 20
                               NVL(l_primary_unit_price,sl.primary_unit_price), -- 21
                               sl.secondary_qty, -- 22
                               sl.secondary_uom_code, -- 23
                               NVL(l_secondary_unit_price,sl.secondary_unit_price), -- 24
                               sl.landed_cost_flag, -- 25
                               sl.allocation_enabled_flag, -- 26
                               sl.trx_business_category, -- 27
                               sl.intended_use, -- 28
                               sl.product_fiscal_class, -- 29
                               sl.product_category, -- 30
                               sl.product_type, -- 31
                               sl.user_def_fiscal_class, -- 32
                               sl.tax_classification_code, -- 33
                               sl.assessable_value, -- 34
                               sl.tax_already_calculated_flag, -- 35
                               sl.ship_from_party_id, -- 36
                               sl.ship_from_party_site_id, -- 37
                               sl.ship_to_organization_id, -- 38
                               sl.ship_to_location_id, -- 39
                               sl.bill_from_party_id, -- 40
                               sl.bill_from_party_site_id, -- 41
                               sl.bill_to_organization_id, -- 42
                               sl.bill_to_location_id, -- 43
                               sl.poa_party_id, -- 44
                               sl.poa_party_site_id, -- 45
                               sl.poo_organization_id, -- 46
                               sl.poo_location_id, -- 47
                               sl.org_id, -- 48
                               sl.ship_line_int_id, -- 49
                               sl.interface_source_table, -- 50
                               sl.interface_source_line_id, -- 51
                               l_fnd_user_id, -- 52
                               SYSDATE, -- 53
                               l_fnd_user_id, -- 54
                               SYSDATE, -- 55
                               l_fnd_login_id, -- 56
                               sl.program_id, -- 57
                               sl.program_update_date, -- 58
                               sl.program_application_id, -- 59
                               sl.request_id, -- 60
                               sl.attribute_category, -- 61
                               sl.attribute1, -- 62
                               sl.attribute2, -- 63
                               sl.attribute3, -- 64
                               sl.attribute4, -- 65
                               sl.attribute5, -- 66
                               sl.attribute6, -- 67
                               sl.attribute7, -- 68
                               sl.attribute8, -- 69
                               sl.attribute9, -- 70
                               sl.attribute10, -- 71
                               sl.attribute11, -- 72
                               sl.attribute12, -- 73
                               sl.attribute13, -- 74
                               sl.attribute14, -- 75
                               sl.attribute15, -- 76
                               sl.nrq_zero_exception_flag, -- 77
                               NULL, -- 78
                               NULL, -- 80
                               NULL, -- 81
                               NULL
                        FROM inl_adj_ship_lines_v sl
                        WHERE sl.ship_line_id = l_elc_adj_shiplines(i).ship_line_id);
        END LOOP;
    END IF;

    -- Fetch ELC Adjusted Charge Lines
    OPEN c_elc_adj_chlines;
    FETCH c_elc_adj_chlines BULK COLLECT INTO l_elc_adj_chlines;
    CLOSE c_elc_adj_chlines;

    -- Exist charge lines to be ELC adjusted
    IF NVL (l_elc_adj_chlines.LAST, 0) > 0 THEN
        FOR i IN NVL(l_elc_adj_chlines.FIRST, 0)..NVL(l_elc_adj_chlines.LAST, 0)
        LOOP
            -- Check if associations changed
            SELECT COUNT(1)
            INTO l_count_assoc_changed
            FROM inl_adj_associations_v a
            WHERE a.from_parent_table_name = 'INL_CHARGE_LINES'
            AND a.from_parent_table_id = l_elc_adj_chlines(i).charge_line_id
            AND a.adjustment_type_flag IS NOT NULL
            AND a.ship_header_id = p_ship_header_id;

            INL_LOGGING_PVT.Log_Variable(p_module_name => g_module_name,
                                         p_procedure_name => l_program_name,
                                         p_var_name => 'l_count_assoc_changed',
                                         p_var_value => l_count_assoc_changed);

            IF NVL(l_count_assoc_changed,0) > 0 THEN -- associations changed
                -- Check if charge contains associations
                SELECT COUNT(1)
                INTO l_exist_associations
                FROM inl_adj_associations_v a
                WHERE a.from_parent_table_name = 'INL_CHARGE_LINES'
                AND a.from_parent_table_id = l_elc_adj_chlines(i).charge_line_id
                AND (a.adjustment_type_flag IS NULL
                OR   a.adjustment_type_flag = 'A')
                AND a.ship_header_id = p_ship_header_id;

                INL_LOGGING_PVT.Log_Variable(p_module_name => g_module_name,
                                             p_procedure_name => l_program_name,
                                             p_var_name => 'l_exist_associations',
                                             p_var_value => l_exist_associations);

                IF NVL(l_exist_associations, 0) > 0 THEN  -- Exist associations for charge

                    SELECT inl_charge_lines_s.nextval
                    INTO l_charge_line_id
                    FROM DUAL;

                    l_debug_info := 'Get next charge line number';
                    INL_LOGGING_PVT.Log_Statement(p_module_name => g_module_name,
                                                  p_procedure_name => l_program_name,
                                                  p_debug_info => l_debug_info);

                    SELECT NVL (MAX (cl.charge_line_num), 0) + 1
                    INTO l_charge_line_num
                    FROM inl_charge_lines cl
                    WHERE NVL (cl.parent_charge_line_id, cl.charge_line_id) IN(
                                              SELECT assoc.from_parent_table_id
                                              FROM inl_associations assoc
                                              WHERE assoc.from_parent_table_name = 'INL_CHARGE_LINES'
                                              AND assoc.ship_header_id = p_ship_header_id);

                    INL_LOGGING_PVT.Log_Variable(p_module_name => g_module_name,
                                                 p_procedure_name => l_program_name,
                                                 p_var_name => 'l_charge_line_num',
                                                 p_var_value => l_charge_line_num);

                    l_debug_info := 'Create new charge line';
                    INL_LOGGING_PVT.Log_Statement(p_module_name => g_module_name,
                                                  p_procedure_name => l_program_name,
                                                  p_debug_info => l_debug_info);

                    -- Create new charge line
                    INSERT INTO inl_charge_lines(charge_line_id, -- 01
                                                charge_line_num, -- 02
                                                charge_line_type_id, -- 03
                                                landed_cost_flag, -- 04
                                                update_allowed, -- 05
                                                source_code, -- 06
                                                parent_charge_line_id, -- 07
                                                adjustment_num, -- 08
                                                match_id, -- 09
                                                match_amount_id, -- 10
                                                charge_amt, -- 11
                                                currency_code, -- 12
                                                currency_conversion_type, -- 13
                                                currency_conversion_date, -- 14
                                                currency_conversion_rate, -- 15
                                                party_id, -- 16
                                                party_site_id, -- 17
                                                trx_business_category, -- 18
                                                intended_use, -- 19
                                                product_fiscal_class, -- 20
                                                product_category, -- 21
                                                product_type, -- 22
                                                user_def_fiscal_class, -- 23
                                                tax_classification_code, -- 24
                                                assessable_value, -- 25
                                                tax_already_calculated_flag, -- 26
                                                ship_from_party_id, -- 27
                                                ship_from_party_site_id, -- 278
                                                ship_to_organization_id, -- 29
                                                ship_to_location_id, -- 30
                                                bill_from_party_id, -- 31
                                                bill_from_party_site_id, -- 32
                                                bill_to_organization_id, -- 33
                                                bill_to_location_id, -- 34
                                                poa_party_id, -- 35
                                                poa_party_site_id, -- 36
                                                poo_organization_id, -- 37
                                                poo_location_id, -- 38
                                                created_by, -- 39
                                                creation_date, -- 40
                                                last_updated_by, -- 41
                                                last_update_date, -- 42
                                                last_update_login, -- 43
                                                new_charge_amt, -- 44
                                                new_currency_conversion_type, -- 45
                                                new_currency_conversion_date, -- 46
                                                new_currency_conversion_rate -- 47
                                               )
                                        (SELECT l_charge_line_id, -- 01
                                                l_charge_line_num, -- 02
                                                cl.charge_line_type_id, -- 03
                                                cl.landed_cost_flag, -- 04
                                                cl.update_allowed, -- 05
                                                cl.source_code, -- 06
                                                NULL, -- 07
                                                l_adjustment_num, -- 08
                                                cl.match_id, -- 09
                                                cl.match_amount_id, -- 10
                                                NVL(cl.new_charge_amt, cl.charge_amt), -- 11
                                                cl.currency_code, -- 12
                                                NVL(cl.new_currency_conversion_type, cl.currency_conversion_type), -- 13
                                                NVL(cl.new_currency_conversion_date, cl.currency_conversion_date), -- 14
                                                NVL(cl.new_currency_conversion_rate, cl.currency_conversion_rate), -- 15
                                                cl.party_id, -- 16
                                                cl.party_site_id, -- 17
                                                cl.trx_business_category, -- 18
                                                cl.intended_use, -- 19
                                                cl.product_fiscal_class, -- 20
                                                cl.product_category,-- 21
                                                cl.product_type,-- 22
                                                cl.user_def_fiscal_class,-- 23
                                                cl.tax_classification_code,-- 24
                                                cl.assessable_value,-- 25
                                                cl.tax_already_calculated_flag,-- 26
                                                cl.ship_from_party_id,-- 27
                                                cl.ship_from_party_site_id,-- 28
                                                cl.ship_to_organization_id,-- 29
                                                cl.ship_to_location_id,-- 30
                                                cl.bill_from_party_id, -- 31
                                                cl.bill_from_party_site_id, -- 32
                                                cl.bill_to_organization_id, -- 33
                                                cl.bill_to_location_id, -- 34
                                                cl.poa_party_id, -- 35
                                                cl.poa_party_site_id, -- 36
                                                cl.poo_organization_id, -- 37
                                                cl.poo_location_id, -- 38
                                                l_fnd_user_id, -- 39
                                                SYSDATE, -- 40
                                                l_fnd_user_id, -- 41
                                                SYSDATE, -- 42
                                                l_fnd_login_id, -- 43
                                                NULL, -- 44
                                                NULL, -- 45
                                                NULL, -- 46
                                                NULL -- 47
                    FROM inl_adj_charge_lines_v cl
                    WHERE cl.charge_line_id = l_elc_adj_chlines(i).charge_line_id);

                    l_debug_info := 'Create associations for charge line ID: ' || l_charge_line_id;
                    INL_LOGGING_PVT.Log_Statement(p_module_name => g_module_name,
                                                  p_procedure_name => l_program_name,
                                                  p_debug_info => l_debug_info);

                    -- Create associations according to adjustment_flag
                    INSERT INTO inl_associations(association_id, -- 01
                                                 ship_header_id, -- 02
                                                 from_parent_table_name, -- 03
                                                 from_parent_table_id, -- 04
                                                 to_parent_table_name, -- 05
                                                 to_parent_table_id, -- 06
                                                 allocation_basis, -- 07
                                                 allocation_uom_code, -- 08
                                                 created_by, -- 09
                                                 creation_date, -- 10
                                                 last_updated_by, -- 11
                                                 last_update_date, -- 12
                                                 last_update_login, -- 13
                                                 adjustment_type_flag) -- 14
                                         (SELECT INL_ASSOCIATIONS_S.NEXTVAL, -- 01
                                                 a.ship_header_id, -- 02
                                                 a.from_parent_table_name, -- 03
                                                 l_charge_line_id, -- 04
                                                 a.to_parent_table_name, -- 05
                                                 a.to_parent_table_id, -- 06
                                                 a.allocation_basis, -- 07
                                                 a.allocation_uom_code, -- 08
                                                 l_fnd_user_id, -- 09
                                                 SYSDATE, -- 10
                                                 l_fnd_user_id, -- 11
                                                 SYSDATE, -- 12
                                                 L_FND_LOGIN_ID, -- 13
                                                 NULL -- 14
                                          FROM inl_adj_associations_v a
                                          WHERE a.ship_header_id = p_ship_header_id
                                          AND a.from_parent_table_name = 'INL_CHARGE_LINES'
                                          AND a.from_parent_table_id = l_elc_adj_chlines(i).charge_line_id
                                          AND (a.adjustment_type_flag IS NULL
                                          OR   a.adjustment_type_flag = 'A'));
                END IF; -- END Exist associations

                l_debug_info := 'Create an adjustment with amount 0 for charge line ID: ' || l_elc_adj_chlines(i).charge_line_id;
                INL_LOGGING_PVT.Log_Statement(p_module_name => g_module_name,
                                              p_procedure_name => l_program_name,
                                              p_debug_info => l_debug_info);

                -- Charge_amt = 0 for current charge
                INSERT INTO inl_charge_lines(charge_line_id, -- 01
                                             charge_line_num, -- 02
                                             charge_line_type_id, -- 03
                                             landed_cost_flag, -- 04
                                             update_allowed, -- 05
                                             source_code, -- 06
                                             parent_charge_line_id, -- 07
                                             adjustment_num, -- 08
                                             match_id, -- 09
                                             match_amount_id, -- 10
                                             charge_amt, -- 11
                                             currency_code, -- 12
                                             currency_conversion_type, -- 13
                                             currency_conversion_date, -- 14
                                             currency_conversion_rate, -- 15
                                             party_id, -- 16
                                             party_site_id, -- 17
                                             trx_business_category, -- 18
                                             intended_use, -- 19
                                             product_fiscal_class, -- 20
                                             product_category,-- 21
                                             product_type,-- 22
                                             user_def_fiscal_class, -- 23
                                             tax_classification_code, -- 24
                                             assessable_value,-- 25
                                             tax_already_calculated_flag, -- 26
                                             ship_from_party_id, -- 27
                                             ship_from_party_site_id, -- 28
                                             ship_to_organization_id, -- 29
                                             ship_to_location_id, -- 30
                                             bill_from_party_id, -- 31
                                             bill_from_party_site_id, -- 32
                                             bill_to_organization_id, -- 33
                                             bill_to_location_id, -- 34
                                             poa_party_id, -- 35
                                             poa_party_site_id, -- 36
                                             poo_organization_id, -- 37
                                             poo_location_id, -- 38
                                             created_by, -- 39
                                             creation_date, -- 40
                                             last_updated_by, -- 41
                                             last_update_date, -- 42
                                             last_update_login, -- 43
                                             new_charge_amt, -- 44
                                             new_currency_conversion_type, -- 45
                                             new_currency_conversion_date, -- 46
                                             new_currency_conversion_rate, -- 47
                                             adjustment_type_flag) -- 48
                                    (SELECT INL_CHARGE_LINES_S.NEXTVAL, -- 01
                                            cl.charge_line_num, -- 02
                                            cl.charge_line_type_id, -- 03
                                            cl.landed_cost_flag, -- 04
                                            cl.update_allowed, -- 05
                                            cl.source_code, -- 06
                                            l_elc_adj_chlines(i).charge_line_id, -- 07
                                            l_adjustment_num, -- 08
                                            cl.match_id, -- 09
                                            cl.match_amount_id, -- 10
                                            0, -- 11
                                            cl.currency_code, -- 12
                                            cl.currency_conversion_type, -- 13
                                            cl.currency_conversion_date, -- 14
                                            cl.currency_conversion_rate, -- 15
                                            cl.party_id, -- 16
                                            cl.party_site_id, -- 17
                                            cl.trx_business_category, -- 18
                                            cl.intended_use, -- 19
                                            cl.product_fiscal_class, -- 20
                                            cl.product_category, -- 21
                                            cl.product_type, -- 22
                                            cl.user_def_fiscal_class, -- 23
                                            cl.tax_classification_code, -- 24
                                            cl.assessable_value, -- 25
                                            cl.tax_already_calculated_flag, -- 26
                                            cl.ship_from_party_id, -- 27
                                            cl.ship_from_party_site_id, -- 28
                                            cl.ship_to_organization_id, -- 29
                                            cl.ship_to_location_id, -- 30
                                            cl.bill_from_party_id, -- 31
                                            cl.bill_from_party_site_id, -- 32
                                            cl.bill_to_organization_id, -- 33
                                            cl.bill_to_location_id, -- 34
                                            cl.poa_party_id, -- 35
                                            cl.poa_party_site_id, -- 36
                                            cl.poo_organization_id, -- 37
                                            cl.poo_location_id, -- 38
                                            l_fnd_user_id, -- 39
                                            SYSDATE, -- 40
                                            l_fnd_user_id, -- 41
                                            SYSDATE, -- 42
                                            l_fnd_login_id, -- 43
                                            NULL, -- 44
                                            NULL, -- 45
                                            NULL, -- 46
                                            NULL, -- 47
                                            'Z' -- 48
                                     FROM inl_adj_charge_lines_v cl
                                     WHERE cl.charge_line_id = l_elc_adj_chlines(i).charge_line_id);
            ELSE   -- associations were not changed
                l_debug_info := 'Associations were not changed. Charge line ID: ' || l_elc_adj_chlines(i).charge_line_id;
                INL_LOGGING_PVT.Log_Statement(p_module_name => g_module_name,
                                              p_procedure_name => l_program_name,
                                              p_debug_info => l_debug_info);

                -- Check if charge was changed
                SELECT COUNT(1)
                INTO l_count_charge_changed
                FROM inl_adj_charge_lines_v c
                WHERE (c.new_charge_amt IS NOT NULL
                OR     c.new_currency_conversion_type IS NOT NULL
                OR     c.new_currency_conversion_date IS NOT NULL
                OR     c.new_currency_conversion_rate IS NOT NULL)
                AND charge_line_id = l_elc_adj_chlines(i).charge_line_id;

                INL_LOGGING_PVT.Log_Variable(p_module_name => g_module_name,
                                             p_procedure_name => l_program_name,
                                             p_var_name => 'l_count_charge_changed',
                                             p_var_value => l_count_charge_changed);

                IF NVL(l_count_charge_changed,0) > 0 THEN
                    -- Create new charge line
                    INSERT INTO inl_charge_lines(charge_line_id, -- 01
                                                 charge_line_num, -- 02
                                                 charge_line_type_id, -- 03
                                                 landed_cost_flag, -- 04
                                                 update_allowed, -- 05
                                                 source_code, -- 06
                                                 parent_charge_line_id, -- 07
                                                 adjustment_num, -- 08
                                                 match_id, -- 09
                                                 match_amount_id, -- 10
                                                 charge_amt, -- 11
                                                 currency_code, -- 12
                                                 currency_conversion_type, -- 13
                                                 currency_conversion_date, -- 14
                                                 currency_conversion_rate, -- 15
                                                 party_id, -- 16
                                                 party_site_id, -- 17
                                                 trx_business_category, -- 18
                                                 intended_use, -- 19
                                                 product_fiscal_class, -- 20
                                                 product_category, -- 21
                                                 product_type, -- 22
                                                 user_def_fiscal_class, -- 23
                                                 tax_classification_code, -- 24
                                                 assessable_value, -- 25
                                                 tax_already_calculated_flag, -- 26
                                                 ship_from_party_id, -- 27
                                                 ship_from_party_site_id, -- 28
                                                 ship_to_organization_id, -- 29
                                                 ship_to_location_id, -- 30
                                                 bill_from_party_id, -- 31
                                                 bill_from_party_site_id, -- 32
                                                 bill_to_organization_id, -- 33
                                                 bill_to_location_id, -- 34
                                                 poa_party_id, -- 35
                                                 poa_party_site_id, -- 36
                                                 poo_organization_id, -- 37
                                                 poo_location_id, -- 38
                                                 created_by, -- 39
                                                 creation_date, -- 40
                                                 last_updated_by, -- 41
                                                 last_update_date, -- 42
                                                 last_update_login, -- 43
                                                 new_charge_amt, -- 44
                                                 new_currency_conversion_type, -- 45
                                                 new_currency_conversion_date, -- 46
                                                 new_currency_conversion_rate -- 47
                                              )
                                         (SELECT INL_CHARGE_LINES_S.NEXTVAL, -- 01
                                                 cl.charge_line_num, -- 02
                                                 cl.charge_line_type_id, -- 03
                                                 cl.landed_cost_flag, -- 04
                                                 cl.update_allowed, -- 05
                                                 cl.source_code, -- 06
                                                 cl.charge_line_id, -- 07
                                                 l_adjustment_num, -- 08
                                                 cl.match_id, -- 09
                                                 cl.match_amount_id, -- 10
                                                 NVL(cl.new_charge_amt, cl.charge_amt), -- 11
                                                 cl.currency_code, -- 12
                                                 NVL(cl.new_currency_conversion_type,cl.currency_conversion_type), -- 13
                                                 NVL(cl.new_currency_conversion_date,cl.currency_conversion_date), -- 14
                                                 NVL(cl.new_currency_conversion_rate,cl.currency_conversion_rate), -- 15
                                                 cl.party_id, -- 16
                                                 cl.party_site_id, -- 17
                                                 cl.trx_business_category, -- 18
                                                 cl.intended_use, -- 19
                                                 cl.product_fiscal_class, -- 20
                                                 cl.product_category, -- 21
                                                 cl.product_type, -- 22
                                                 cl.user_def_fiscal_class, -- 23
                                                 cl.tax_classification_code, -- 24
                                                 cl.assessable_value, -- 25
                                                 cl.tax_already_calculated_flag, -- 26
                                                 cl.ship_from_party_id, -- 27
                                                 cl.ship_from_party_site_id, -- 28
                                                 cl.ship_to_organization_id, -- 29
                                                 cl.ship_to_location_id, -- 30
                                                 cl.bill_from_party_id, -- 31
                                                 cl.bill_from_party_site_id, -- 32
                                                 cl.bill_to_organization_id, -- 33
                                                 cl.bill_to_location_id, -- 34
                                                 cl.poa_party_id, -- 35
                                                 cl.poa_party_site_id, -- 36
                                                 cl.poo_organization_id, -- 37
                                                 cl.poo_location_id, -- 38
                                                 l_fnd_user_id, -- 39
                                                 SYSDATE, -- 40
                                                 l_fnd_user_id, -- 41
                                                 SYSDATE, -- 42
                                                 l_fnd_login_id, -- 43
                                                 NULL, -- 44
                                                 NULL, -- 45
                                                 NULL, -- 46
                                                 NULL -- 47
                                          FROM inl_adj_charge_lines_v cl
                                          WHERE cl.charge_line_id = l_elc_adj_chlines(i).charge_line_id);
                END IF;
            END IF;
        END LOOP;
    END IF;

    l_debug_info := 'Set pending_update_flag to N for Shipment';
    INL_LOGGING_PVT.Log_Statement(p_module_name => g_module_name,
                                  p_procedure_name => l_program_name,
                                  p_debug_info => l_debug_info);

    UPDATE inl_ship_headers_all sh
    SET sh.adjustment_num = ABS(l_adjustment_num),
        sh.pending_update_flag = 'N',
        sh.last_update_login    = l_fnd_login_id,
        sh.last_update_date     = SYSDATE,
        sh.last_updated_by      = l_fnd_user_id
    WHERE sh.ship_header_id = p_ship_header_id;

    l_debug_info := 'Call INL_INTERFACE_PVT.Reset_MatchInt';
    INL_LOGGING_PVT.Log_Statement(p_module_name => g_module_name,
                                  p_procedure_name => l_program_name,
                                  p_debug_info => l_debug_info);

    INL_INTERFACE_PVT.Reset_MatchInt(p_ship_header_id => p_ship_header_id,
                                     x_return_status => l_return_status);

    -- If unexpected errors happen abort API
    IF l_return_status   = L_FND_RET_STS_ERROR THEN
        x_return_status := l_return_status;
        RAISE L_FND_EXC_ERROR;
    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
        x_return_status  := l_return_status;
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.To_Boolean (p_commit) THEN
        COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded => L_FND_FALSE,
                              p_count => x_msg_count,
                              p_data => x_msg_data) ;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name);

EXCEPTION
--Handling deadlock with proper error message
WHEN RESOURCE_BUSY THEN
    x_return_status := FND_API.g_ret_sts_error;
    FND_MESSAGE.set_name('INL','INL_CANNOT_EXEC_ELC_SUBMIT_LCK');
    FND_MSG_PUB.ADD;
    -- Standard Expected Error Logging
    INL_LOGGING_PVT.Log_ExpecError(p_module_name => g_module_name,
                                   p_procedure_name => l_program_name);
    ROLLBACK TO Adjust_ELCLines_PVT;
    x_return_status := L_FND_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => L_FND_FALSE,
                              p_count => x_msg_count,
                              p_data => x_msg_data);
WHEN L_FND_EXC_ERROR THEN
    -- Standard Expected Error Logging
    INL_LOGGING_PVT.Log_ExpecError(p_module_name => g_module_name,
                                   p_procedure_name => l_program_name) ;
    ROLLBACK TO Adjust_ELCLines_PVT;
    x_return_status := L_FND_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => L_FND_FALSE,
                              p_count => x_msg_count,
                              p_data => x_msg_data) ;
WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError(p_module_name => g_module_name,
                                     p_procedure_name => l_program_name) ;
    ROLLBACK TO Adjust_ELCLines_PVT;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => L_FND_FALSE,
                              p_count => x_msg_count,
                              p_data => x_msg_data) ;
WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError(p_module_name => g_module_name,
                                     p_procedure_name => l_program_name) ;
    ROLLBACK TO Adjust_ELCLines_PVT;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg(p_pkg_name => g_pkg_name,
                                p_procedure_name => l_program_name) ;
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded => L_FND_FALSE,
                              p_count => x_msg_count,
                              p_data => x_msg_data) ;
END Adjust_ELCLines;
-- /SCM-051

-- API name   : ProcessAction
-- Type       : Private
-- Function   : Run all required steps to Complete a given LCM Shipment.
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version       IN NUMBER              Required
--              p_init_msg_list     IN VARCHAR2            Optional  Default = L_FND_FALSE
--              p_commit            IN VARCHAR2            Optional  Default = L_FND_FALSE
--              p_ship_header_id    IN NUMBER
--              p_task_code         IN VARCHAR2
--              p_caller            IN VARCHAR2 From UI (U) or Concurrent (C)
-- OUT          x_return_status     OUT NOCOPY VARCHAR2
--              x_msg_count         OUT NOCOPY   NUMBER
--              x_msg_data          OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE ProcessAction(
    p_api_version    IN NUMBER,
    p_init_msg_list  IN VARCHAR2 := L_FND_FALSE,
    p_commit         IN VARCHAR2 := L_FND_FALSE,
    p_ship_header_id IN NUMBER,
    p_task_code      IN VARCHAR2,
    p_caller         IN VARCHAR2, -- SCM-051 - From UI (U) or Concurrent (C)
    x_return_status  OUT NOCOPY VARCHAR2,
    x_msg_count      OUT NOCOPY NUMBER,
    x_msg_data       OUT NOCOPY VARCHAR2)
IS
    l_api_name    CONSTANT VARCHAR2 (30) := 'ProcessAction';
    l_api_version CONSTANT NUMBER := 1.0;
    l_return_status VARCHAR2 (1) ;
    l_msg_count NUMBER;
    l_msg_data VARCHAR2 (2000);
    l_debug_info VARCHAR2 (200);
    l_pending_matching_flag VARCHAR2 (1) ;
    l_ship_status VARCHAR2 (30);
    l_msg_count_validate NUMBER;
    l_organization_id NUMBER;
    l_rcv_enabled_flag VARCHAR2(1);
    l_max_allocation_id NUMBER; --Bug#10032820
    l_pending_update_flag VARCHAR2(1) ; -- SCM-051
    l_ship_num VARCHAR2(25); -- SCM-051
    l_rcv_running NUMBER; -- SCM-051
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
    -- Standard Start of API savepoint
    SAVEPOINT Run_Submit_PVT;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean (p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    -- Check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
            l_api_version,
            p_api_version,
            l_api_name,
            G_PKG_NAME
    ) THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'p_ship_header_id',
        p_var_value => p_ship_header_id) ;

    -- Get the Pending Match Flag and Organization Id
    l_debug_info := 'Get the Pending Match Flag, Pending Update Flag and Organization Id';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info => l_debug_info
    ) ;
    SELECT pending_matching_flag,
           pending_update_flag, -- SCM-051
           organization_id,
           NVL(rcv_enabled_flag,'Y') rcv_enabled_flag, -- dependence,
           ship_num -- SCM-051
    INTO l_pending_matching_flag,
         l_pending_update_flag, -- SCM-051
         l_organization_id,
         l_rcv_enabled_flag,
         l_ship_num
    FROM inl_ship_headers
    WHERE ship_header_id = p_ship_header_id;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'l_pending_matching_flag',
        p_var_value => l_pending_matching_flag) ;
    -- SCM-051
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'l_pending_update_flag',
        p_var_value => l_pending_update_flag) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'p_caller',
        p_var_value => p_caller) ;
    -- /SCM-051
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'l_organization_id',
        p_var_value => l_organization_id) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'l_rcv_enabled_flag',
        p_var_value => l_rcv_enabled_flag) ;

     -- SCM-051
     IF NVL(l_pending_update_flag, 'N') = 'Y' AND p_caller = 'U' THEN

        SELECT COUNT(1)
        INTO l_rcv_running
        FROM rcv_transactions_interface rti,
             inl_ship_lines_all sl
        WHERE rti.transaction_type = 'RECEIVE'
        AND rti.processing_status_code = 'RUNNING'
        AND rti.lcm_shipment_line_id = sl.ship_line_id
        AND sl.ship_header_id = p_ship_header_id;

        INL_LOGGING_PVT.Log_Variable (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_var_name => 'l_rcv_running',
            p_var_value => l_rcv_running) ;

        IF NVL(l_rcv_running,0) > 0 THEN
            FND_MESSAGE.SET_NAME('INL','INL_CANNOT_EXEC_ELC_SUBMIT');
            FND_MSG_PUB.ADD;
            RAISE L_FND_EXC_ERROR;
        END IF;

        Adjust_ELCLines (
            p_api_version => 1.0,
            p_init_msg_list => L_FND_FALSE,
            p_commit => L_FND_FALSE,
            p_ship_header_id => p_ship_header_id,
            x_return_status => l_return_status,
            x_msg_count => l_msg_count,
            x_msg_data => l_msg_data);
    END IF;
    -- /SCM-051

    -- SCM-051 Shipment with ELC Pending will not be processed
    IF NVL(l_pending_update_flag, 'N') = 'Y' AND p_caller = 'C' THEN
        l_debug_info := 'Shipment with ELC Pending';
        INL_LOGGING_PVT.Log_Statement (
                p_module_name   => g_module_name,
                p_procedure_name=> l_api_name,
                p_debug_info    => l_debug_info) ;

        FND_MESSAGE.SET_NAME('INL','INL_ERR_CHK_ELC_UPDATE');
        FND_MESSAGE.SET_TOKEN('SHIP_NUM',l_ship_num);
        FND_MSG_PUB.ADD;
        RAISE L_FND_EXC_ERROR;
    ELSE
    -- /SCM-051
        -- Run Adjust Lines for Pending Shipments
        IF l_pending_matching_flag = 'Y' AND NVL(l_rcv_running,0) = 0 THEN   -- SCM-051
            /* transfered to INL_INTERFACE_PVT      --BUG#8198498
            l_debug_info := 'Run INL_SHIPMENT_PVT.Adjust_Lines';
            INL_LOGGING_PVT.Log_Statement (
                p_module_name => g_module_name,
                p_procedure_name => l_api_name,
                p_debug_info => l_debug_info
            ) ;
            Adjust_Lines (
                p_api_version => 1.0,
                p_init_msg_list => L_FND_FALSE,
                p_commit => L_FND_FALSE,
                p_ship_header_id => p_ship_header_id,
                x_return_status => l_return_status,
                x_msg_count => l_msg_count,
                x_msg_data => l_msg_data
            ) ;
            -- If any errors happen abort the process.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        */
            -- Update Pending Matching Flag
            l_debug_info := 'Update PendingMatchingFlag';
            INL_LOGGING_PVT.Log_Statement (
                p_module_name => g_module_name,
                p_procedure_name => l_api_name,
                p_debug_info => l_debug_info
            ) ;
            -- Set Shipment Header's pending_matching_flag to 'Y'
            INL_SHIPMENT_PVT.Update_PendingMatchingFlag(  --BUG#8198498
                p_ship_header_id        => p_ship_header_id,
                p_pending_matching_flag => 'N',
                x_return_status     => l_return_status
            );
            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
        -- Run Generate Taxes Only for NOT Pending Shipments
        IF p_task_code >= '30' AND NVL(l_pending_matching_flag, 'N') = 'N' AND
           NVL(l_pending_update_flag, 'N') = 'N' THEN -- SCM-051
            l_debug_info := 'Run INL_TAX_PVT.Generate_Taxes';
            INL_LOGGING_PVT.Log_Statement (
                p_module_name => g_module_name,
                p_procedure_name => l_api_name,
                p_debug_info => l_debug_info
            ) ;
            INL_TAX_PVT.Generate_Taxes (
                p_api_version    => 1.0,
                p_init_msg_list => L_FND_FALSE,
                p_commit => L_FND_FALSE,
                p_ship_header_id => p_ship_header_id,
                x_return_status => l_return_status,
                x_msg_count => l_msg_count,
                x_msg_data => l_msg_data
            ) ;
            -- If any errors happen abort the process.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
        -- Run Validation only for NOT Pending Shipments
        IF p_task_code >= '40' AND NVL (l_pending_matching_flag, 'N') = 'N' AND
           NVL(l_pending_update_flag, 'N') = 'N' THEN -- SCM-051
            l_debug_info := 'Run INL_SHIPMENT_PVT.Validate_Shipment';
            INL_LOGGING_PVT.Log_Statement (
                p_module_name => g_module_name,
                p_procedure_name => l_api_name,
                p_debug_info => l_debug_info
            ) ;
            l_msg_count_validate := NVL (fnd_msg_pub.Count_Msg (), 0) ;
            Validate_Shipment (
                p_api_version => 1.0,
                p_init_msg_list => L_FND_FALSE,
                p_commit => L_FND_FALSE,
                p_validation_level => L_FND_VALID_LEVEL_FULL,
                p_ship_header_id => p_ship_header_id,
                p_task_code => p_task_code,--Bug#9836174
                x_return_status => l_return_status,
                x_msg_count => l_msg_count,
                x_msg_data => l_msg_data
            ) ;
            -- If any errors happen abort the process.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
            l_msg_count_validate := NVL (l_msg_count, 0) - l_msg_count_validate;
        END IF;
        ----------------------------------------------------------------------
        -- Actions for both Pending Shipments and Not Pending Shipments
        ----------------------------------------------------------------------
        -- Run Landed Cost Calculation
        IF p_task_code >= '50' AND NVL (l_msg_count_validate, 0) = 0 AND
           NVL(l_rcv_running,0) = 0 THEN
--Bug#10032820
            l_debug_info := 'Getting the l_max_allocation_id';
            INL_LOGGING_PVT.Log_Statement (
                p_module_name => g_module_name,
                p_procedure_name => l_api_name,
                p_debug_info => l_debug_info
            ) ;
            SELECT  MAX(allocation_id)
            INTO    l_max_allocation_id
            FROM    inl_allocations;

            INL_LOGGING_PVT.Log_Variable (
                p_module_name => g_module_name,
                p_procedure_name => l_api_name,
                p_var_name => 'l_max_allocation_id',
                p_var_value => l_max_allocation_id);

--Bug#10032820

            l_debug_info := 'Run INL_LANDEDCOST_PVT.Run_Calculation';
            INL_LOGGING_PVT.Log_Statement (
                p_module_name => g_module_name,
                p_procedure_name => l_api_name,
                p_debug_info => l_debug_info) ;

            INL_LANDEDCOST_PVT.Run_Calculation (
                p_api_version => 1.0,
                p_init_msg_list => L_FND_FALSE,
                p_commit => L_FND_FALSE,
                p_validation_level => L_FND_VALID_LEVEL_FULL,
                p_ship_header_id => p_ship_header_id,
                p_calc_scope_code => 0,
                x_return_status => l_return_status,
                x_msg_count => l_msg_count,
                x_msg_data => l_msg_data
            ) ;
            -- If any errors happen abort the process.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
        -- Submit Shipment and call final integrations
        IF p_task_code >= '60' AND NVL (l_msg_count_validate, 0) = 0 AND
           NVL(l_rcv_running,0) = 0 THEN
            l_debug_info := 'Run INL_SHIPMENT_PVT.Complete_Shipment';
            INL_LOGGING_PVT.Log_Statement (
                p_module_name => g_module_name,
                p_procedure_name => l_api_name,
                p_debug_info => l_debug_info) ;

            Complete_Shipment (
                p_api_version => 1.0,
                p_init_msg_list => L_FND_FALSE,
                p_commit => L_FND_FALSE,
                p_ship_header_id => p_ship_header_id,
                p_rcv_enabled_flag => l_rcv_enabled_flag,
                p_pending_matching_flag => l_pending_matching_flag,
                p_pending_elc_flag => l_pending_update_flag, -- SCM-051
                p_organization_id => l_organization_id,
                p_max_allocation_id => l_max_allocation_id, --Bug#10032820
                x_return_status => l_return_status,
                x_msg_count => l_msg_count,
                x_msg_data => l_msg_data) ;

            -- If any errors happen abort the process.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
    END IF;

    -- If any errors happen abort the process.
    IF l_return_status = L_FND_RET_STS_ERROR THEN
        RAISE L_FND_EXC_ERROR;
    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Standard check of p_commit.
    IF FND_API.To_Boolean (p_commit) THEN
        COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data
    ) ;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name
    ) ;
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name
        ) ;
        ROLLBACK TO Run_Submit_PVT;
        x_return_status := L_FND_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get (
            p_encoded => L_FND_FALSE,
            p_count => x_msg_count,
            p_data => x_msg_data
        ) ;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name
        ) ;
        ROLLBACK TO Run_Submit_PVT;
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get (
            p_encoded => L_FND_FALSE,
            p_count => x_msg_count,
            p_data => x_msg_data
        ) ;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name
        ) ;
        ROLLBACK TO Run_Submit_PVT;
        x_return_status := L_FND_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg (
                p_pkg_name => g_pkg_name,
                p_procedure_name => l_api_name
            ) ;
        END IF;
        FND_MSG_PUB.Count_And_Get (
            p_encoded => L_FND_FALSE,
            p_count => x_msg_count,
            p_data => x_msg_data
        ) ;
END ProcessAction;


-- Utility name   : Complete_PendingShipments
-- Type       : Private
-- Function   : This utility is called by an LCM Concurrent to process
--              either a specific Pending Matching/Correction Shipment
--              or ALL Pending Shipments.
-- Pre-reqs   : None
-- Parameters :
-- OUT           errbuf            OUT VARCHAR2
--               retcode           OUT VARCHAR2
--
-- IN            p_organization_id IN NUMBER
--               p_ship_header_id  IN NUMBER
--
--
-- Version    : Current version 1.0
--
-- Notes      : THIS PROCEDURE IS GOING TO COMMIT ALL PREVIOUS TRANSACTIONS --Bug#10359221

PROCEDURE Complete_PendingShipment (
    errbuf            OUT NOCOPY  VARCHAR2,
    retcode           OUT NOCOPY VARCHAR2,
    p_organization_id IN NUMBER,
    p_ship_header_id  IN NUMBER)
IS
    l_program_name CONSTANT VARCHAR2 (30) := 'Complete_PendingShipment';
    l_return_status VARCHAR2 (1)        := L_FND_RET_STS_SUCCESS;
    l_msg_count NUMBER;
    l_msg_data VARCHAR2 (2000);
    l_debug_info VARCHAR2 (200);
    l_records_processed NUMBER:=0;

    -- Cursor to get all Pending Shipments
    CURSOR c_pending_shipments  IS
         SELECT ship_header_id, org_id --Bug#10381495
           FROM inl_ship_headers_all  --Bug#10381495
          WHERE ship_status_code = 'COMPLETED'
            AND pending_matching_flag = 'Y'
            AND (p_organization_id IS NULL
                 OR organization_id = p_organization_id);
--Bug#10359221
    TYPE pending_shipments_lst_type
        IS TABLE OF c_pending_shipments%ROWTYPE INDEX BY BINARY_INTEGER;
    l_pending_shipments_lst pending_shipments_lst_type;
    l_records_err NUMBER:=0;
    l_records_read NUMBER:=0;
    l_ac_proc NUMBER:=0;
    l_partial_commit_at NUMBER:=500;
--Bug#10359221


    --Bug#10381495
    l_previous_access_mode  VARCHAR2(1) :=mo_global.get_access_mode();
    l_previous_org_id       NUMBER(15)  :=mo_global.get_current_org_id();
    l_current_org_id        NUMBER(15);
    l_org_id                NUMBER(15);
    --Bug#10381495

BEGIN
    -- Init conc. parameters
    errbuf  := NULL;
    retcode := 0;

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;

--Bug#10381495
    l_current_org_id := NVL(l_previous_org_id,-999);
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'l_current_org_id',
        p_var_value      => l_current_org_id
    ) ;
--Bug#10381495


    -- Submit only the given Shipment
    IF p_ship_header_id IS NOT NULL THEN


--Bug#10381495
        SELECT org_id
          INTO l_org_id
          FROM inl_ship_headers_all
         WHERE ship_header_id = p_ship_header_id;

        IF (l_org_id <> l_current_org_id) THEN
            INL_LOGGING_PVT.Log_Statement(
                p_module_name => g_module_name,
                p_procedure_name => l_program_name,
                p_debug_info => 'Seting a new context from '||l_current_org_id||' to '||l_org_id
            );
            l_current_org_id:=l_org_id;
            mo_global.set_policy_context( 'S', l_current_org_id);
            INL_LOGGING_PVT.Log_Statement(
                p_module_name => g_module_name,
                p_procedure_name => l_program_name,
                p_debug_info => 'l_current_org_id: '||l_current_org_id
            );
        END IF;
--Bug#10381495

        l_debug_info := 'Before runnig Submit process for the only Shipment Id: ' || p_ship_header_id;
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_program_name,
            p_debug_info => l_debug_info
        ) ;
        l_records_read := 1;
        ProcessAction (
            p_api_version => 1.0,
            p_init_msg_list => L_FND_FALSE,
            p_commit => L_FND_FALSE,
            p_ship_header_id => p_ship_header_id,
            p_task_code => '60', -- Process until Submit task
            p_caller => 'C',  -- SCM-051
            x_return_status => l_return_status,
            x_msg_count => l_msg_count,
            x_msg_data => l_msg_data) ;
        l_records_read := 1;
        -- If any errors happen change concurrent status. --Bug#10359221
        IF l_return_status = L_FND_RET_STS_ERROR OR l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            INL_LOGGING_PVT.Log_Statement (
                p_module_name => g_module_name,
                p_procedure_name => l_program_name,
                p_debug_info => 'Rollback '
            ) ;
            retcode := 1;
            ROLLBACK;
            l_records_err := 1;
        ELSE
            INL_LOGGING_PVT.Log_Statement (
                p_module_name => g_module_name,
                p_procedure_name => l_program_name,
                p_debug_info => 'Commit '
            ) ;
            l_records_processed := 1;
            COMMIT;
        END IF;
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_program_name,
            p_debug_info => 'retcode: '||retcode||' l_records_processed: '||l_records_processed
        ) ;
    -- Submit ALL Pending Shipments
    ELSE

--Bug#10359221
        --Opening the cursor of pending shipments
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_program_name,
            p_debug_info => 'Opening the cursor of pending shipments'
        ) ;

        OPEN c_pending_shipments;
        FETCH c_pending_shipments BULK COLLECT INTO l_pending_shipments_lst;
        CLOSE c_pending_shipments;
--Bug#10359221
        l_debug_info := l_pending_shipments_lst.LAST||' lines have been retrieved.';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_program_name,
            p_debug_info => l_debug_info
        ) ;
        IF NVL(l_pending_shipments_lst.LAST, 0) > 0 THEN
            FOR i IN NVL(l_pending_shipments_lst.FIRST, 0)..NVL(l_pending_shipments_lst.LAST, 0)
            LOOP
--Bug#10381495
                IF (l_pending_shipments_lst(i).org_id <> l_current_org_id) THEN
                    INL_LOGGING_PVT.Log_Statement(
                        p_module_name => g_module_name,
                        p_procedure_name => l_program_name,
                        p_debug_info => 'Seting a new context from '||l_current_org_id||' to '||l_pending_shipments_lst(i).org_id
                    );
                    l_current_org_id:=l_pending_shipments_lst(i).org_id;
                    mo_global.set_policy_context( 'S', l_current_org_id);
                    INL_LOGGING_PVT.Log_Statement(
                        p_module_name => g_module_name,
                        p_procedure_name => l_program_name,
                        p_debug_info => 'l_current_org_id: '||l_current_org_id
                    );
                END IF;
--Bug#10381495
                l_records_read := l_records_read + 1;
                SAVEPOINT Complete_PendingShipment_int;
                l_debug_info := 'Before runnig Submit process for the Shipment Id: ' || l_pending_shipments_lst(i).ship_header_id;
                INL_LOGGING_PVT.Log_Statement (
                    p_module_name => g_module_name,
                    p_procedure_name => l_program_name,
                    p_debug_info => l_debug_info
                ) ;
                ProcessAction (
                    p_api_version => 1.0,
                    p_init_msg_list => L_FND_FALSE,
                    p_commit => L_FND_FALSE,
                    p_ship_header_id => l_pending_shipments_lst(i).ship_header_id,
                    p_task_code => '60', -- Process until Submit task
                    p_caller => 'C',  -- SCM-051
                    x_return_status => l_return_status,
                    x_msg_count => l_msg_count,
                    x_msg_data => l_msg_data) ;

                -- If any errors happen change concurrent status. --Bug#10359221
                IF l_return_status = L_FND_RET_STS_ERROR
                    OR l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                    --Problem with ProcessAction
                    INL_LOGGING_PVT.Log_Statement (
                        p_module_name => g_module_name,
                        p_procedure_name => l_program_name,
                        p_debug_info => 'Problem with ProcessAction: Rollback'
                    ) ;

                    retcode := 1;
    --Bug#10359221
                    ROLLBACK TO Complete_PendingShipment_int;
                    INL_LOGGING_PVT.Log_Statement (
                        p_module_name => g_module_name,
                        p_procedure_name => l_program_name,
                        p_debug_info => 'Error found. '
                    ) ;
                    l_records_err   := l_records_err + 1;
                ELSE
                    l_records_processed := l_records_processed + 1;
                    l_ac_proc := l_ac_proc + 1;
                END IF;
                IF l_ac_proc >= l_partial_commit_at THEN
                    -- Partial commit limit reached
                    INL_LOGGING_PVT.Log_Statement (
                        p_module_name => g_module_name,
                        p_procedure_name => l_program_name,
                        p_debug_info => 'Partial commit limit reached. '
                    ) ;
                    COMMIT;
                    l_ac_proc := 0;
                END IF;
            END LOOP;
            COMMIT;
        END IF;
--Bug#10359221
    END IF;
    -- Setting error bufer and return code
    IF l_msg_count = 1 THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, l_msg_data);
        retcode := 1;
    ELSIF l_msg_count > 1 THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, l_msg_count|| ' warnings found.' );
        FOR i IN 1 ..l_msg_count
        LOOP
            FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MSG_PUB.get (i, L_FND_FALSE) );
        END LOOP;
        retcode := 1;
    END IF;
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_debug_info => '< ***** ' || 'Records Read        : ' || l_records_read
    ) ;
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_debug_info => '< ***** ' || 'Records Processed   : ' || l_records_processed
    ) ;
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_debug_info => '< ***** ' || 'Records Errored     : ' || l_records_err
    ) ;
    -- Write the number of records processed and inserted by this concurrent process
    FND_FILE.put_line( FND_FILE.log, '< **************************************>');
    FND_FILE.put_line( FND_FILE.log, '< ***** ' || 'Records Read     : ' || l_records_read); -- Bug#10359221
    FND_FILE.put_line( FND_FILE.log, '< ***** ' || 'Records Processed: ' || l_records_processed); -- Bug #9258936
    FND_FILE.put_line( FND_FILE.log, '< ***** ' || 'Records Errored  : ' || l_records_err); -- Bug#10359221
    FND_FILE.put_line( FND_FILE.log, '< **************************************>');
--Bug#10359221
    --Bug#10381495
    IF (l_current_org_id <> NVL(l_previous_org_id,-999)) THEN
        INL_LOGGING_PVT.Log_Statement(
            p_module_name => g_module_name,
            p_procedure_name => l_program_name,
            p_debug_info => 'Restore previous context: from '||l_current_org_id||' to '||l_previous_org_id
        );
        mo_global.set_policy_context( l_previous_access_mode, l_previous_org_id);
    END IF;
    --Bug#10381495

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
EXCEPTION
WHEN L_FND_EXC_ERROR THEN
    -- Standard Expected Error Logging
    INL_LOGGING_PVT.Log_ExpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    --Bug#10381495
    IF (l_current_org_id <> NVL(l_previous_org_id,-999)) THEN
        INL_LOGGING_PVT.Log_Statement(
            p_module_name => g_module_name,
            p_procedure_name => l_program_name,
            p_debug_info => 'Restore previous context: from '||l_current_org_id||' to '||l_previous_org_id
        );
        mo_global.set_policy_context( l_previous_access_mode, l_previous_org_id);
    END IF;
    --Bug#10381495
    retcode := 1;
    errbuf := errbuf ||' G_EXC_ERROR '||SQLERRM;
WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    --Bug#10381495
    IF (l_current_org_id <> NVL(l_previous_org_id,-999)) THEN
        INL_LOGGING_PVT.Log_Statement(
            p_module_name => g_module_name,
            p_procedure_name => l_program_name,
            p_debug_info => 'Restore previous context: from '||l_current_org_id||' to '||l_previous_org_id
        );
        mo_global.set_policy_context( l_previous_access_mode, l_previous_org_id);
    END IF;
    --Bug#10381495
    retcode := 2;
    errbuf := errbuf ||' G_EXC_UNEXPECTED_ERROR '||SQLERRM;
WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    --Bug#10381495
    IF (l_current_org_id <> NVL(l_previous_org_id,-999)) THEN
        INL_LOGGING_PVT.Log_Statement(
            p_module_name => g_module_name,
            p_procedure_name => l_program_name,
            p_debug_info => 'Restore previous context: from '||l_current_org_id||' to '||l_previous_org_id
        );
        mo_global.set_policy_context( l_previous_access_mode, l_previous_org_id);
    END IF;
    --Bug#10381495
    retcode := 2;
    errbuf := errbuf ||' OTHERS '||SQLERRM;
END Complete_PendingShipment;
-- Utility name   : Update_PendingMatchingFlag
-- Type       : Private
-- Function   : This is the Table Handler to be used for updating
--              the Pending Matching Flag for given Shipment Header.
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_header_id IN NUMBER
--              p_pending_matching_flag IN VARCHAR
-- OUT          x_return_status      OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Update_PendingMatchingFlag(
    p_ship_header_id        IN NUMBER,
    p_pending_matching_flag IN VARCHAR,
    x_return_status OUT NOCOPY VARCHAR2
) IS
    l_program_name CONSTANT VARCHAR2 (100) := 'Update_PendingMatchingFlag';
BEGIN
    INL_LOGGING_PVT.Log_BeginProc ( p_module_name => g_module_name, p_procedure_name => l_program_name) ;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;
    UPDATE inl_ship_headers_all sh --Bug#10381495
    SET sH.pending_matching_flag    = p_pending_matching_flag   ,
--        created_by                = L_FND_USER_ID             ,
--        creation_date             = SYSDATE                   ,
        sH.last_updated_by          = L_FND_USER_ID             ,
        sH.last_update_date         = SYSDATE                   ,
        sH.last_update_login        = L_FND_LOGIN_ID            ,
        sH.request_id               = L_FND_CONC_REQUEST_ID     ,
        sH.program_id               = L_FND_CONC_PROGRAM_ID     ,
        sH.program_update_date      = SYSDATE                   ,
        sH.program_application_id   = L_FND_PROG_APPL_ID
      WHERE sH.ship_header_id       = p_ship_header_id;
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    ) ;
EXCEPTION
WHEN L_FND_EXC_ERROR THEN
    -- Standard Expected Error Logging
    INL_LOGGING_PVT.Log_ExpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    ) ;
    x_return_status := L_FND_RET_STS_ERROR;
WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    ) ;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name
    ) ;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg (
            p_pkg_name => g_pkg_name,
            p_procedure_name => l_program_name
        ) ;
    END IF;
END Update_PendingMatchingFlag;
-- API name   : Delete_ChargeAssoc
-- Type       : Private
-- Function   : Check shipments affected by a charge deletion
--              or an association of charge deletion
--
-- Pre-reqs   : None
-- Parameters :
-- IN         :
--              p_api_version            IN NUMBER   Required
--              p_init_msg_list          IN VARCHAR2 Optional  Default = L_FND_FALSE
--              p_commit                 IN VARCHAR2 Optional  Default = L_FND_FALSE
--              p_ship_header_id         IN NUMBER
--              p_charge_line_id         IN NUMBER
-- OUT        :
--              x_return_status         OUT NOCOPY VARCHAR2
--              x_msg_count             OUT NOCOPY NUMBER
--              x_msg_data              OUT NOCOPY VARCHAR2
--
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Delete_ChargeAssoc(
        p_api_version    IN NUMBER,
        p_init_msg_list  IN VARCHAR2 := L_FND_FALSE,
        p_commit         IN VARCHAR2 := L_FND_FALSE,
        p_ship_header_id IN NUMBER,
        p_charge_line_id IN NUMBER,
        x_return_status OUT NOCOPY VARCHAR2,
        x_msg_count OUT NOCOPY     NUMBER,
        x_msg_data OUT NOCOPY      VARCHAR2
) IS
    l_api_name      CONSTANT VARCHAR2 (30) := 'Delete_ChargeAssoc';
    l_api_version   CONSTANT NUMBER        := 1.0;
    l_debug_info    VARCHAR2 (200) ;
    l_return_status VARCHAR2 (1) ;
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2 (2000) ;
    CURSOR c_affected_ship
    IS
         SELECT a.ship_header_id           ,
            sh.ship_status_code ship_status,
            sh.pending_matching_flag
           FROM inl_associations a,
            inl_ship_headers sh
          WHERE sh.ship_header_id        = a.ship_header_id
            AND a.from_parent_table_name = 'INL_CHARGE_LINES'
            AND a.from_parent_table_id   = p_charge_line_id
            AND a.ship_header_id        <> p_ship_header_id;
    r_affected_ship c_affected_ship%ROWTYPE;
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc ( p_module_name => g_module_name, p_procedure_name => l_api_name) ;
    -- Standard Start of API savepoint
    SAVEPOINT Delete_ChargeAssoc_PVT;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean (p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    -- Check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (p_current_version_number => l_api_version, p_caller_version_number => p_api_version, p_api_name => l_api_name, p_pkg_name => g_pkg_name) THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;
    -- API Body
    BEGIN
        OPEN c_affected_ship;
        LOOP
            FETCH c_affected_ship INTO r_affected_ship;
            EXIT
        WHEN c_affected_ship%NOTFOUND;
            INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name, p_procedure_name => l_api_name, p_var_name => 'ship_status', p_var_value => r_affected_ship.ship_status) ;
            IF (r_affected_ship.ship_status             = 'VALIDATED') THEN
                Set_ToRevalidate (1.0, L_FND_FALSE, L_FND_FALSE, r_affected_ship.ship_header_id, l_msg_count, l_msg_data, l_return_status) ;
                -- If any errors happen abort the process.
                IF l_return_status = L_FND_RET_STS_ERROR THEN
                    RAISE L_FND_EXC_ERROR;
                ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                    RAISE L_FND_EXC_UNEXPECTED_ERROR;
                END IF;
            ELSIF (r_affected_ship.ship_status = 'COMPLETED') THEN
                Update_PendingMatchingFlag (r_affected_ship.ship_header_id, 'Y', l_return_status) ;
                IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
                    FND_MESSAGE.SET_NAME ('INL', 'INL_UNEXPECTED_ERR') ;
                    FND_MSG_PUB.ADD;
                    IF l_return_status = L_FND_RET_STS_ERROR THEN
                        RAISE L_FND_EXC_ERROR;
                    ELSE
                        RAISE L_FND_EXC_UNEXPECTED_ERROR;
                    END IF;
                END IF;
            END IF;
        END LOOP;
        CLOSE c_affected_ship;
    END;
    -- Standard check of p_commit.
    IF FND_API.To_Boolean (p_commit) THEN
        COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data) ;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
EXCEPTION
WHEN L_FND_EXC_ERROR THEN
    -- Standard Expected Error Logging
    INL_LOGGING_PVT.Log_ExpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
    ROLLBACK TO Delete_ChargeAssoc_PVT;
    x_return_status                      := L_FND_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data) ;
WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
    ROLLBACK TO Delete_ChargeAssoc_PVT;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data) ;
WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
    ROLLBACK TO Delete_ChargeAssoc_PVT;
    x_return_status                                := L_FND_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level (
            p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
    ) THEN
        FND_MSG_PUB.Add_Exc_Msg (
            p_pkg_name        => g_pkg_name,
            p_procedure_name => l_api_name) ;
    END IF;
    FND_MSG_PUB.Count_And_Get ( p_encoded => L_FND_FALSE, p_count => x_msg_count, p_data => x_msg_data) ;
END Delete_ChargeAssoc;

-- Utility name   : Get_MatchedTaxNRecAmt
-- Type       : Public
-- Function   : Get the sum of Non-Recoverable Tax
--              amounts for a particular Tax Line on LCM.
--              This function can also return Taxes on a particular Cost Factor.
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_header_id       IN NUMBER
--              p_ship_line_id         IN NUMBER
--              p_charge_line_type_id  IN NUMBER
--              p_tax_code             IN VARCHAR2
--              p_functional_curr_code IN VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Get_MatchedTaxNRecAmt(
    p_ship_header_id       IN NUMBER,
    p_ship_line_id         IN NUMBER,
    p_charge_line_type_id  IN NUMBER,
    p_tax_code             IN VARCHAR2
--  p_functional_curr_code IN VARCHAR2  SCM-051

) RETURN NUMBER IS

    l_program_name CONSTANT VARCHAR2(30) := 'Get_MatchedTaxNRecAmt';
    l_debug_info VARCHAR2(200);
    l_nrec_tax_amt NUMBER;

BEGIN

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    -- Logging variables
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_ship_header_id',
        p_var_value => p_ship_header_id);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_ship_line_id',
        p_var_value => p_ship_line_id) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_charge_line_type_id',
        p_var_value => p_charge_line_type_id) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_tax_code',
        p_var_value => p_tax_code) ;
/* SCM-051
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_functional_curr_code',
        p_var_value => p_functional_curr_code) ;
*/
--SCM-051
        SELECT SUM(NVL(a.nrec_tax_amt,0) * NVL(a.matched_curr_conversion_rate,1)) -- Bug #10102991 --Bug#1405859
         INTO l_nrec_tax_amt
         FROM inl_matches a
        WHERE a.ship_header_id = p_ship_header_id
          AND a.to_parent_table_name  = 'INL_SHIP_LINES'
          AND a.to_parent_table_id = (SELECT NVL(MAX(b.parent_ship_line_id), p_ship_line_id)
                                      FROM inl_ship_lines_all b
                                      WHERE b.ship_line_id = p_ship_line_id)

          AND a.match_type_code = 'TAX'
          AND (p_charge_line_type_id IS NULL OR a.charge_line_type_id = p_charge_line_type_id)
          AND (p_tax_code IS NULL OR a.tax_code = p_tax_code)
          -- Bug 8879575
          AND a.adjustment_num =     (SELECT NVL(MAX(c.adjustment_num), a.adjustment_num)
                                      FROM inl_matches c
                                      WHERE c.ship_header_id = a.ship_header_id
                                      AND c.from_parent_table_name = a.from_parent_table_name
                                      AND c.from_parent_table_id = a.from_parent_table_id
                                      AND c.to_parent_table_name = a.to_parent_table_name
                                      AND c.to_parent_table_id = a.to_parent_table_id
                                      AND c.match_type_code = a.match_type_code
                                      AND c.tax_code = a.tax_code
                                      AND c.existing_match_info_flag = 'Y')
          AND NOT EXISTS (SELECT 1
                          FROM inl_matches d
                          WHERE d.ship_header_id = a.ship_header_id
                          AND d.from_parent_table_name = a.from_parent_table_name
                          AND d.from_parent_table_id = a.from_parent_table_id
                          AND d.to_parent_table_name = a.to_parent_table_name
                          AND d.to_parent_table_id = a.to_parent_table_id
                          AND d.existing_match_info_flag = 'Y'
                          AND d.parent_match_id = a.match_id)
          -- Bug 8879575
--Bug#14058596      GROUP BY a.matched_curr_code, a.matched_curr_conversion_rate
      ;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'l_nrec_tax_amt',
        p_var_value => l_nrec_tax_amt) ;

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    RETURN l_nrec_tax_amt;
EXCEPTION
WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    IF FND_MSG_PUB.Check_Msg_Level (
            p_message_level  => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
    ) THEN
        FND_MSG_PUB.Add_Exc_Msg (
            p_pkg_name => g_pkg_name,
            p_procedure_name => l_program_name) ;
    END IF;
    RETURN null;
END Get_MatchedTaxNRecAmt;

-- Utility name   : Get_MatchedChargeAmt
-- Type       : Public
-- Function   : Get the sum of Matched Amounts
--              for a particular Cost Factor.
--
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_header_id       IN NUMBER
--              p_ship_line_id         IN NUMBER
--              p_charge_line_type_id  IN NUMBER
--              p_functional_curr_code IN VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Get_MatchedChargeAmt(
    p_ship_header_id       IN NUMBER,
    p_ship_line_id         IN NUMBER,
    p_charge_line_type_id  IN NUMBER
--  p_functional_curr_code IN VARCHAR2  SCM-051
) RETURN NUMBER IS

    l_program_name CONSTANT VARCHAR2(30) := 'Get_MatchedChargeAmt';
    l_debug_info VARCHAR2(200);
    l_matched_charge_amt NUMBER;

BEGIN

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    -- Logging variables
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_ship_header_id',
        p_var_value => p_ship_header_id);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_ship_line_id',
        p_var_value => p_ship_line_id) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_charge_line_type_id',
        p_var_value => p_charge_line_type_id) ;
/* SCM-051
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_functional_curr_code',
        p_var_value => p_functional_curr_code) ;
*/
    --SCM-051
       SELECT SUM(NVL(a.matched_amt,0) * NVL(a.matched_curr_conversion_rate,1)) -- Bug #10102991--Bug#14058596
          INTO l_matched_charge_amt
          FROM inl_matches a
         WHERE a.ship_header_id = p_ship_header_id
           AND a.to_parent_table_name  = 'INL_SHIP_LINES'
           AND a.to_parent_table_id = (select NVL(MAX(b.parent_ship_line_id), p_ship_line_id)
                                            from inl_ship_lines_all b
                                           where b.ship_line_id = p_ship_line_id)
           AND a.match_type_code = 'CHARGE'
           AND a.charge_line_type_id = p_charge_line_type_id
           -- Bug 8879575
           AND a.adjustment_num = (select NVL(MAX(c.adjustment_num), a.adjustment_num)
                                        from inl_matches c
                                       where c.ship_header_id = a.ship_header_id
                                         and c.from_parent_table_name = a.from_parent_table_name
                                         and c.from_parent_table_id = a.from_parent_table_id
                                         and c.to_parent_table_name = a.to_parent_table_name
                                         and c.to_parent_table_id = a.to_parent_table_id
                                         and c.match_type_code = a.match_type_code
                                         and c.charge_line_type_id = a.charge_line_type_id
                                         and c.existing_match_info_flag = 'Y')
           AND NOT EXISTS (select 1
                             from inl_matches d
                            where d.ship_header_id = a.ship_header_id
                              and d.from_parent_table_name = a.from_parent_table_name
                              and d.from_parent_table_id = a.from_parent_table_id
                              and d.to_parent_table_name = a.to_parent_table_name
                              and d.to_parent_table_id = a.to_parent_table_id
                              and d.existing_match_info_flag = 'Y'
                              and d.parent_match_id = a.match_id)
           -- Bug 8879575
--        GROUP BY a.matched_curr_code, a.matched_curr_conversion_rate SCM-051
    ;
    --SCM-051

    INL_LOGGING_PVT.Log_Variable ( --Bug#14058596
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'l_matched_charge_amt',
        p_var_value => l_matched_charge_amt) ;

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc ( p_module_name => g_module_name,
                                  p_procedure_name => l_program_name) ;
    RETURN l_matched_charge_amt;
EXCEPTION
WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    IF FND_MSG_PUB.Check_Msg_Level (p_message_level  => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg (
            p_pkg_name => g_pkg_name,
            p_procedure_name => l_program_name) ;
    END IF;
    RETURN null;
END Get_MatchedChargeAmt;

-- Utility name   : Get_MatchedItemAmt
-- Type       : Public
-- Function   : Get the sum of match amounts for a particular Item or
--              depending on the p_summarized_matched_amt, it can also
--              return matched amount summarized for the LCM Ship. Line
--
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_header_id       IN NUMBER
--              p_ship_line_id         IN NUMBER
--              p_functional_curr_code IN VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Get_MatchedItemAmt(
    p_ship_header_id         IN NUMBER,
    p_ship_line_id           IN NUMBER,
    p_summarized_matched_amt IN VARCHAR2
--  p_functional_curr_code IN VARCHAR2  SCM-051
) RETURN NUMBER IS

    l_program_name CONSTANT VARCHAR2(30) := 'Get_MatchedItemAmt';
    l_debug_info VARCHAR2(200);
    l_matched_item_amt NUMBER;

BEGIN

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    -- Logging variables
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_ship_header_id',
        p_var_value => p_ship_header_id);

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_ship_line_id',
        p_var_value => p_ship_line_id) ;
/* SCM-051
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_functional_curr_code',
        p_var_value => p_functional_curr_code) ;
*/
--SCM-051
        SELECT SUM(NVL(a.matched_amt,0) * NVL(a.matched_curr_conversion_rate,1)) -- Bug #10102991--Bug#14058596
         INTO l_matched_item_amt
         FROM inl_matches a
        WHERE a.ship_header_id = p_ship_header_id
          AND a.to_parent_table_name  = 'INL_SHIP_LINES'
          AND a.to_parent_table_id = (SELECT NVL(MAX(b.parent_ship_line_id), p_ship_line_id)
                                      FROM inl_ship_lines_all b
                                      WHERE b.ship_line_id = p_ship_line_id)
          AND ((p_summarized_matched_amt = 'Y' AND a.match_type_code <> 'TAX')
               OR (p_summarized_matched_amt = 'N'
               AND a.match_type_code = 'ITEM'))
          -- Bug 8879575
          AND a.adjustment_num = (SELECT NVL(MAX(c.adjustment_num), a.adjustment_num)
                                  FROM inl_matches c
                                  WHERE c.ship_header_id = a.ship_header_id
                                  AND c.from_parent_table_name = a.from_parent_table_name
                                  AND c.from_parent_table_id = a.from_parent_table_id
                                  AND c.to_parent_table_name = a.to_parent_table_name
                                  AND c.to_parent_table_id = a.to_parent_table_id
                                  AND c.match_type_code = a.match_type_code
                                  AND c.existing_match_info_flag = 'Y')
          AND NOT EXISTS (SELECT 1
                          FROM inl_matches d
                          WHERE d.ship_header_id = a.ship_header_id
                          AND d.from_parent_table_name = a.from_parent_table_name
                          AND d.from_parent_table_id = a.from_parent_table_id
                          AND d.to_parent_table_name = a.to_parent_table_name
                          AND d.to_parent_table_id = a.to_parent_table_id
                          AND d.existing_match_info_flag = 'Y'
                          AND d.parent_match_id = a.match_id)
        --GROUP BY matched_curr_code, a.matched_curr_conversion_rate
        ;

    INL_LOGGING_PVT.Log_Variable ( --Bug#14058596
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'l_matched_item_amt',
        p_var_value => l_matched_item_amt) ;

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    RETURN l_matched_item_amt;
EXCEPTION
WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name) ;
    IF FND_MSG_PUB.Check_Msg_Level (
            p_message_level  => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
    ) THEN
        FND_MSG_PUB.Add_Exc_Msg (
            p_pkg_name => g_pkg_name,
            p_procedure_name => l_program_name) ;
    END IF;
    RETURN null;
END Get_MatchedItemAmt;

-- Utility name   : Get_MatchedAmt
-- Type       : Public
-- Function   : Get the sum of matched amounts for a given
--              Item, Charge or Tax and return it converted
--              into the Functional Currency Code. By using the
--              p_summarized_matched_amt parameter, it is also
--              possible to calculate the matched amount summarized
--              for a particular LCM Shipment Line.
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_header_id      IN NUMBER
--              p_ship_line_id        IN NUMBER
--              p_charge_line_type_id IN NUMBER
--              p_tax_code            IN VARCHAR2
--              p_match_table_name    IN VARCHAR2
--              p_summarized_matched_amt IN VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Get_MatchedAmt(
    p_ship_header_id         IN NUMBER,
    p_ship_line_id           IN NUMBER,
    p_charge_line_type_id    IN NUMBER,
    p_tax_code               IN VARCHAR2,
                        p_match_table_name       IN VARCHAR2,
                        p_summarized_matched_amt IN VARCHAR2) RETURN NUMBER
IS

    l_program_name CONSTANT VARCHAR2(30) := 'Get_MatchedAmt';
    l_debug_info VARCHAR2(200);
--    l_func_currency_code VARCHAR2(5); SCM-051
    l_matched_amt NUMBER:=0;
    l_match_type_code VARCHAR2(15);

BEGIN

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name) ;
    -- Logging variables
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_ship_header_id',
        p_var_value      => p_ship_header_id);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_ship_line_id',
        p_var_value      => p_ship_line_id) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_charge_line_type_id',
        p_var_value      => p_charge_line_type_id) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_tax_code',
        p_var_value      => p_tax_code) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_match_table_name',
        p_var_value      => p_match_table_name) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_summarized_matched_amt',
        p_var_value      => p_summarized_matched_amt) ;

    -- Handle Match Type Code
    IF(p_match_table_name = 'INL_SHIP_LINES' OR p_match_table_name IS NULL) THEN
        l_match_type_code := 'ITEM';
    ELSIF (p_match_table_name = 'INL_CHARGE_LINES') THEN
        l_match_type_code := 'CHARGE';
    ELSIF (p_match_table_name = 'INL_TAX_LINES') THEN
        l_match_type_code := 'TAX';
    END IF;
/* --SCM-051
    -- Get the functional currency code
    SELECT gsb.currency_code
      INTO l_func_currency_code
      FROM inl_ship_headers_all ish,
           gl_sets_of_books gsb,
           org_organization_definitions ood
     WHERE ish.organization_id = ood.organization_id
       AND gsb.set_of_books_id = ood.set_of_books_id
       AND ish.ship_header_id = p_ship_header_id;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'l_func_currency_code',
        p_var_value      => l_func_currency_code) ;
*/
    IF l_match_type_code = 'ITEM' THEN
        l_matched_amt:= Get_MatchedItemAmt(
                            p_ship_header_id => p_ship_header_id,
                            p_ship_line_id => p_ship_line_id,
                            p_summarized_matched_amt => p_summarized_matched_amt
--                            p_functional_curr_code => l_func_currency_code SCM-051
                            );

        -- In case of summarized match amount,
        -- we must add the non recoverable tax
        IF(p_summarized_matched_amt = 'Y') THEN
            INL_LOGGING_PVT.Log_Variable (
                p_module_name    => g_module_name,
                p_procedure_name => l_program_name,
                p_var_name       => '1-l_matched_amt',
                p_var_value      => l_matched_amt) ;
            l_matched_amt :=
                l_matched_amt + NVL(Get_MatchedTaxNRecAmt(p_ship_header_id => p_ship_header_id,
                                                      p_ship_line_id => p_ship_line_id,
                                                      p_charge_line_type_id => p_charge_line_type_id,
                                                      p_tax_code => p_tax_code
--                                                    p_functional_curr_code => l_func_currency_code SCM-051
                                                      ),0);
        END IF;
    ELSIF l_match_type_code = 'CHARGE' THEN
        l_matched_amt := Get_MatchedChargeAmt(p_ship_header_id => p_ship_header_id,
                                              p_ship_line_id => p_ship_line_id,
                                              p_charge_line_type_id => p_charge_line_type_id
--                                            p_functional_curr_code => l_func_currency_code SCM-051
                                              );
    ELSIF l_match_type_code = 'TAX' THEN
        l_matched_amt := Get_MatchedTaxNRecAmt(p_ship_header_id => p_ship_header_id,
                                               p_ship_line_id => p_ship_line_id,
                                               p_charge_line_type_id => p_charge_line_type_id,
                                               p_tax_code => p_tax_code
--                                            p_functional_curr_code => l_func_currency_code SCM-051
                                              );
    END IF;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'l_matched_amt',
        p_var_value      => l_matched_amt) ;

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc ( p_module_name => g_module_name,
                                  p_procedure_name => l_program_name) ;
    RETURN l_matched_amt;
EXCEPTION
WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError ( p_module_name => g_module_name,
                                       p_procedure_name => l_program_name) ;
    IF FND_MSG_PUB.Check_Msg_Level (p_message_level  => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg ( p_pkg_name => g_pkg_name,
                                  p_procedure_name => l_program_name) ;
    END IF;
    RETURN null;
END Get_MatchedAmt;


-- Bug #9098758
-- Utility name   : Get_LastUpdateDateForShip
-- Type       : Public
-- Function   : Get the higher last update date of all LCM Shipment tables
--              and return it.
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_header_id      IN NUMBER
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Get_LastUpdateDateForShip(p_ship_header_id IN NUMBER) RETURN DATE
IS
    l_header_last_update_date DATE;
    l_group_last_update_date DATE;
    l_line_last_update_date DATE;
    l_charge_last_update_date DATE;
    l_tax_last_update_date DATE;
    l_assoc_last_update_date DATE;

    --Lowest date supported by database as we need to handle null dates
    min_date DATE := TO_DATE('01/01/-4712','DD/MM/SYYYY');

    ship_last_update_date DATE;
    l_program_name CONSTANT VARCHAR2(30) := 'Get_LastUpdateDateForShip';
    l_debug_info VARCHAR2(200);

BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc ( p_module_name => g_module_name,
                                    p_procedure_name => l_program_name) ;
    -- Logging variables
    INL_LOGGING_PVT.Log_Variable ( p_module_name => g_module_name,
                                   p_procedure_name => l_program_name,
                                   p_var_name => 'p_ship_header_id',
                                   p_var_value => p_ship_header_id);

    SELECT NVL(MAX(last_update_date), min_date)
    INTO l_header_last_update_date
    FROM inl_ship_headers_all
    WHERE ship_header_id = p_ship_header_id;

    SELECT NVL(MAX(last_update_date), min_date)
    INTO l_group_last_update_date
    FROM inl_ship_line_groups
    WHERE ship_header_id = p_ship_header_id;

    SELECT NVL(MAX(last_update_date), min_date)
    INTO l_line_last_update_date
    FROM inl_ship_lines_all
    WHERE ship_header_id = p_ship_header_id;

    SELECT NVL(MAX(last_update_date), min_date)
    INTO l_assoc_last_update_date
    FROM inl_associations
    WHERE ship_header_id = p_ship_header_id;

    SELECT NVL(MAX(last_update_date), min_date)
    INTO l_tax_last_update_date
    FROM inl_tax_lines
    WHERE ship_header_id = p_ship_header_id;

    ship_last_update_date := greatest(l_header_last_update_date,
                                     l_group_last_update_date,
                                     l_line_last_update_date,
                                     l_assoc_last_update_date,
                                     l_tax_last_update_date);

    -- Logging variables
    INL_LOGGING_PVT.Log_Variable ( p_module_name => g_module_name,
                                   p_procedure_name => l_program_name,
                                   p_var_name => 'ship_last_update_date',
                                   p_var_value => ship_last_update_date);

    RETURN(ship_last_update_date);

EXCEPTION
WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError ( p_module_name => g_module_name,
                                       p_procedure_name => l_program_name) ;
    IF FND_MSG_PUB.Check_Msg_Level (p_message_level  => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg ( p_pkg_name => g_pkg_name,
                                  p_procedure_name => l_program_name) ;
    END IF;
    RETURN null;
END Get_LastUpdateDateForShip;
-- Bug /#9098758

-- START Bug #13914863
-- API name   : Validate_DualQuantities
-- Type       : Private
-- Function   : Validates Primary/Secondary quantity deviation
--              when processing Dual UOM controlled items.
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version         IN NUMBER
--              p_init_msg_list       IN VARCHAR2 := L_FND_FALSE
--              p_commit              IN VARCHAR2 := L_FND_FALSE
--              p_organization_id     IN NUMBER
--              p_inventory_item_id   IN NUMBER
--              p_primary_qty         IN NUMBER
--              p_primary_uom_code    IN VARCHAR2
--              p_secondary_qty       IN NUMBER
--              p_secondary_uom_code  IN VARCHAR2
-- OUT
--              x_return_status      OUT NOCOPY VARCHAR2
--              x_msg_count          OUT NOCOPY NUMBER
--              x_msg_data           OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Validate_DualQuantities( p_api_version         IN NUMBER,
                                   p_init_msg_list       IN VARCHAR2 := L_FND_FALSE,
                                   p_commit              IN VARCHAR2 := L_FND_FALSE,
                                   p_organization_id     IN NUMBER,
                                   p_inventory_item_id   IN NUMBER,
                                   p_primary_qty         IN NUMBER,
                                   p_primary_uom_code    IN VARCHAR2,
                                   p_secondary_qty       IN NUMBER,
                                   p_secondary_uom_code  IN VARCHAR2,
                                   x_return_status      OUT NOCOPY VARCHAR2,
                                   x_msg_count          OUT NOCOPY NUMBER,
                                   x_msg_data           OUT NOCOPY VARCHAR2) IS -- Bug #13914863

l_api_name CONSTANT VARCHAR2(30) := 'Validate_DualQuantities';
l_debug_info VARCHAR2(200);
l_api_version CONSTANT NUMBER := 1.0;
l_lot_number VARCHAR2(30);
l_primary_qty NUMBER;
l_secondary_qty NUMBER;
l_error_message VARCHAR2(2000);
l_item  VARCHAR2(40);                  -- Bug #15927464

BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (p_module_name => g_module_name,
                                   p_procedure_name => l_api_name);
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean (p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    -- Check for call compatibility.
    IF NOT
        FND_API.Compatible_API_Call (
            l_api_version,
            p_api_version,
            l_api_name,
            G_PKG_NAME)
    THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;

    -- Assign Primary and Secondary Qty
    l_primary_qty := p_primary_qty;
    l_secondary_qty := p_secondary_qty;

    -- Get Lot Number for the item
    BEGIN
        SELECT start_auto_lot_number, segment1 -- Bug #15927464
          INTO l_lot_number, l_item  -- Bug #15927464
          FROM mtl_system_items
         WHERE organization_id = p_organization_id
           AND inventory_item_id = p_inventory_item_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        l_lot_number := NULL;
    END;

    -- Bug #15927464
    IF p_secondary_uom_code IS NOT NULL AND l_secondary_qty IS NULL THEN
        l_debug_info := 'Secondary Qty should not be NULL for item: ' || l_item;
        INL_LOGGING_PVT.Log_Statement(p_module_name => g_module_name,
                                      p_procedure_name => l_api_name,
                                      p_debug_info => l_debug_info);

        FND_MESSAGE.SET_NAME('INL','INL_ERR_SECONDARY_QTY_NULL');
        FND_MESSAGE.SET_TOKEN ('ITEM', l_item) ;
        FND_MSG_PUB.ADD;
    END IF;
    -- Bug #15927464

    -- Quantities must be both positive or both negative
    IF (l_primary_qty < 0 AND l_secondary_qty > 0) OR
       (l_primary_qty > 0 AND l_secondary_qty < 0) THEN
        FND_MESSAGE.SET_NAME('INV','INV_QTYOUTOFBALANCE');
        FND_MSG_PUB.ADD;
    END IF;

    -- If necessary, convert to positive numbers for the deviation check
    IF (l_primary_qty < 0) THEN
        l_primary_qty := (l_primary_qty * -1);
        l_secondary_qty := (l_secondary_qty * -1);
    END IF;

    -- Check if quantities are in deviation
    l_debug_info := 'Call INV_CONVERT.within_deviation for validating deviation.';
    INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                   p_procedure_name => l_api_name,
                                   p_debug_info => l_debug_info);
    -- Bug 15827165
    IF(l_secondary_qty IS NOT NULL AND p_secondary_uom_code IS NOT NULL) THEN
        IF (INV_CONVERT.within_deviation (p_organization_id,
                                          p_inventory_item_id,
                                          l_lot_number,
                                          NULL,
                                          l_primary_qty,
                                          p_primary_uom_code,
                                          l_secondary_qty,
                                          p_secondary_uom_code,
                                          NULL,
                                          NULL) = 0) THEN
            RAISE L_FND_EXC_ERROR;
        END IF;
    END IF;
    -- Bug 15827165

    -- Standard check of p_commit.
    IF FND_API.To_Boolean (p_commit) THEN
        COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data) ;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
EXCEPTION
WHEN L_FND_EXC_ERROR THEN
    -- Standard Expected Error Logging
    INL_LOGGING_PVT.Log_ExpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
    x_return_status := L_FND_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data) ;
WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data) ;
WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name) ;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg (
            p_pkg_name => g_pkg_name,
            p_procedure_name => l_api_name) ;
    END IF;
    FND_MSG_PUB.Count_And_Get (
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data) ;
END Validate_DualQuantities;

-- Utility name: Derive_DualQuantities
-- Type       : Public
-- Function   : Derive Primary/Secondary Qty when processing
--              Dual Uom controlled items
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_organization_id     IN NUMBER
--              p_inventory_item_id   IN NUMBER
--              p_calling_field       IN VARCHAR2
--              p_txn_qty             IN NUMBER
--              p_txn_uom_code        IN VARCHAR2
--              p_secondary_qty       IN NUMBER
--              p_secondary_uom_code  IN VARCHAR2
--
-- Notes      :
FUNCTION Derive_DualQuantities(p_organization_id     IN NUMBER,
                               p_inventory_item_id   IN NUMBER,
                               p_calling_field       IN VARCHAR2,
                               p_txn_qty             IN NUMBER,
                               p_txn_uom_code        IN VARCHAR2,
                               p_secondary_qty       IN NUMBER,
                               p_secondary_uom_code  IN VARCHAR2) RETURN NUMBER IS -- Bug #13914863

l_func_name CONSTANT VARCHAR2(30) := 'Derive_DualQuantities';
l_debug_info VARCHAR2(200);

l_tracking_quantity_ind VARCHAR2(30);
l_secondary_default_ind VARCHAR2(30);
l_ont_pricing_qty_source VARCHAR2(30);
l_lot_number VARCHAR2(30);
l_converted_qty NUMBER;

BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name => g_module_name,
        p_procedure_name => l_func_name) ;
    -- Logging variables
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_func_name,
        p_var_name => 'p_organization_id',
        p_var_value => p_organization_id);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_func_name,
        p_var_name => 'p_inventory_item_id',
        p_var_value => p_inventory_item_id) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_func_name,
        p_var_name => 'p_calling_field',
        p_var_value => p_calling_field) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_func_name,
        p_var_name => 'p_txn_qty',
        p_var_value => p_txn_qty) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_func_name,
        p_var_name => 'p_txn_uom_code',
        p_var_value => p_txn_uom_code) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_func_name,
        p_var_name => 'p_secondary_qty',
        p_var_value => p_secondary_qty) ;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_func_name,
        p_var_name => 'p_secondary_uom_code',
        p_var_value => p_secondary_uom_code) ;

    -- Get the Item Attributes
    SELECT tracking_quantity_ind,
           secondary_default_ind,
           ont_pricing_qty_source,
           start_auto_lot_number
      INTO l_tracking_quantity_ind,
           l_secondary_default_ind,
           l_ont_pricing_qty_source,
           l_lot_number
      FROM mtl_system_items
     WHERE organization_id = p_organization_id
       AND inventory_item_id = p_inventory_item_id;

    -- If Defaulting method is 'Fixed', 'Default' or 'No Default'
    IF (l_secondary_default_ind = 'D' OR l_secondary_default_ind = 'F') OR
         ((l_secondary_default_ind = 'N') AND (p_txn_uom_code = p_secondary_uom_code)) THEN

        -- Branch depending on calling field. 'T' Transaction Qty, 'S' Secondary Qty.
        IF (p_calling_field = 'T') THEN
            l_debug_info := 'Call INV_CONVERT.inv_um_convert for deriving Secondary Qty based on Transaction Qty.';
            INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                           p_procedure_name => l_func_name,
                                           p_debug_info => l_debug_info);

            -- In this case we will use Primary Qty data as base to retrieve Secondary Qty
            l_converted_qty := INV_CONVERT.inv_um_convert(p_inventory_item_id,
                                                          l_lot_number,
                                                          p_organization_id,
                                                          NULL,
                                                          p_txn_qty,
                                                          p_txn_uom_code,
                                                          p_secondary_uom_code,
                                                          NULL, NULL);
            INL_LOGGING_PVT.Log_Variable (
            p_module_name => g_module_name,
            p_procedure_name => l_func_name,
            p_var_name => 'l_converted_qty',
            p_var_value => l_converted_qty) ;

            IF (l_converted_qty = -99999) THEN
                FND_MESSAGE.SET_NAME('INV','INV_NO_CONVERSION_ERR');
                FND_MSG_PUB.ADD;
            END IF;
        ELSIF (p_calling_field = 'S') THEN
            l_debug_info := 'Call INV_CONVERT.inv_um_convert for deriving Transaction Qty based on Secondary Qty.';
            INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                           p_procedure_name => l_func_name,
                                           p_debug_info => l_debug_info) ;

            -- In this case we will use Secondary Qty data as base to retrieve Transaction Qty
            l_converted_qty := INV_CONVERT.inv_um_convert(p_inventory_item_id,
                                                          l_lot_number,
                                                          p_organization_id,
                                                          NULL,
                                                          p_secondary_qty,
                                                          p_secondary_uom_code,
                                                          p_txn_uom_code,
                                                          NULL, NULL);
            INL_LOGGING_PVT.Log_Variable (
            p_module_name => g_module_name,
            p_procedure_name => l_func_name,
            p_var_name => 'l_converted_qty',
            p_var_value => l_converted_qty) ;

            IF (l_converted_qty = -99999) THEN
                FND_MESSAGE.SET_NAME('INV','INV_NO_CONVERSION_ERR');
                FND_MSG_PUB.ADD;
            END IF;
        END IF;
    END IF;
 RETURN l_converted_qty;
EXCEPTION
WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_func_name) ;
    IF FND_MSG_PUB.Check_Msg_Level (
            p_message_level  => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
    ) THEN
        FND_MSG_PUB.Add_Exc_Msg (
            p_pkg_name => g_pkg_name,
            p_procedure_name => l_func_name) ;
    END IF;
    RETURN 0;
END Derive_DualQuantities;

-- END  Bug #13914863


-- SCM-051
-- API name   : Discard_Updates
-- Type       : Private
-- Function   : Discard ELC changes
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version IN NUMBER   Required
--              p_init_msg_list IN VARCHAR2 Optional  Default = L_FND_FALSE
--              p_commit IN VARCHAR2 Optional  Default = L_FND_FALSE
--              p_ship_header_id IN  NUMBER,
-- OUT          x_return_status OUT NOCOPY VARCHAR2
--              x_msg_count OUT NOCOPY NUMBER
--              x_msg_data OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Discard_Updates(p_api_version    IN NUMBER,
                          p_init_msg_list  IN VARCHAR2 := L_FND_FALSE,
                          p_commit         IN VARCHAR2 := L_FND_FALSE,
                          p_ship_header_id IN NUMBER,
                          x_return_status  OUT NOCOPY VARCHAR2,
                          x_msg_count      OUT NOCOPY NUMBER,
                          x_msg_data       OUT NOCOPY VARCHAR2)
IS

    l_program_name CONSTANT VARCHAR2(30) := 'Discard_Updates';
    l_api_version CONSTANT NUMBER := 1.0;
    l_debug_info VARCHAR2(200);
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);

    -- charge lines to be deleted
    CURSOR c_delete_cl IS
        SELECT cl.charge_line_id
        FROM inl_charge_lines cl
        WHERE cl.adjustment_type_flag = 'A'
        AND cl.parent_charge_line_id IS NULL
        AND EXISTS (SELECT 1
                    FROM inl_associations a
                    WHERE a.from_parent_table_name = 'INL_CHARGE_LINES'
                    AND a.from_parent_table_id =  cl.charge_line_id
                    AND a.adjustment_type_flag = 'A'
                    AND a.ship_header_id = p_ship_header_id
                    AND ROWNUM < 2
                    )
        AND NOT EXISTS (SELECT 1
                    FROM inl_associations a
                    WHERE a.from_parent_table_name = 'INL_CHARGE_LINES'
                    AND a.from_parent_table_id =  cl.charge_line_id
                    AND a.adjustment_type_flag IS NOT NULL
                    AND a.adjustment_type_flag <> 'A'
                    AND a.ship_header_id = p_ship_header_id
                    AND ROWNUM < 2
                    )
        AND NOT EXISTS (SELECT 1
                    FROM inl_charge_lines cl0
                    WHERE cl0.parent_charge_line_id = cl.charge_line_id
                    AND ROWNUM < 2
                    );

    TYPE l_delete_cl_lst_tp IS
    TABLE OF c_delete_cl%ROWTYPE INDEX BY BINARY_INTEGER;
    l_delete_cl_lst l_delete_cl_lst_tp;

BEGIN
     INL_LOGGING_PVT.Log_BeginProc (p_module_name => g_module_name,
                                    p_procedure_name => l_program_name) ;

    -- Standard Start of API savepoint
    SAVEPOINT Discard_Updates_PVT;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean (p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (p_current_version_number => l_api_version,
                                        p_caller_version_number => p_api_version,
                                        p_api_name => l_program_name,
                                        p_pkg_name => G_PKG_NAME) THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;

    l_debug_info := 'Discard Shipment Line changes';
    INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                   p_procedure_name => l_program_name,
                                   p_debug_info => l_debug_info);

     UPDATE inl_ship_lines_all isl
       SET isl.last_update_login            = l_fnd_login_id,
           isl.last_update_date             = SYSDATE,
           isl.last_updated_by              = l_fnd_user_id,
           isl.new_txn_unit_price           = NULL,
           isl.new_currency_conversion_type = NULL,
           isl.new_currency_conversion_date = NULL,
           isl.new_currency_conversion_rate = NULL
     WHERE isl.ship_header_id = p_ship_header_id
       AND isl.adjustment_num = (SELECT MIN(a.adjustment_num)
                                   FROM inl_ship_lines_all a
                                  WHERE a.ship_header_id = p_ship_header_id)
    AND (   isl.new_txn_unit_price           IS NOT NULL
         OR isl.new_currency_conversion_type IS NOT NULL
         OR isl.new_currency_conversion_date IS NOT NULL
         OR isl.new_currency_conversion_rate IS NOT NULL)

     ;

    l_debug_info := 'Revert Charge Line adjustment values';
    INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                   p_procedure_name => l_program_name,
                                   p_debug_info => l_debug_info);
    UPDATE inl_charge_lines icl
       SET icl.last_update_login            = l_fnd_login_id,
           icl.last_update_date             = SYSDATE,
           icl.last_updated_by              = l_fnd_user_id,
           icl.new_charge_amt               = NULL,
           icl.new_currency_conversion_type = NULL,
           icl.new_currency_conversion_date = NULL,
           icl.new_currency_conversion_rate = NULL,
           icl.adjustment_type_flag         = NULL -- Bug #13643479
     WHERE icl.charge_line_id = (
                                 SELECT
                                     cl1.charge_line_id
                                  FROM
                                     inl_charge_lines cl1
                                 WHERE
                                 CONNECT_BY_ISLEAF = 1
                                  START WITH cl1.charge_line_id = icl.charge_line_id
                                  CONNECT BY PRIOR cl1.charge_line_id = cl1.parent_charge_line_id
                                )
    AND EXISTS (
                SELECT 1
                FROM inl_associations a
                WHERE a.from_parent_table_name  = 'INL_CHARGE_LINES'
                AND a.ship_header_id            = p_ship_header_id
                AND a.from_parent_table_id      = (
                                                SELECT
                                                    cl1.charge_line_id
                                                FROM
                                                    inl_charge_lines cl1
                                                WHERE
                                                CONNECT_BY_ISLEAF = 1
                                                START WITH cl1.charge_line_id = icl.charge_line_id
                                                CONNECT BY PRIOR cl1.parent_charge_line_id = cl1.charge_line_id
                                                )
                )
    AND (   icl.new_charge_amt               IS NOT NULL
         OR icl.new_currency_conversion_type IS NOT NULL
         OR icl.new_currency_conversion_date IS NOT NULL
         OR icl.new_currency_conversion_rate IS NOT NULL
         OR icl.adjustment_type_flag         IS NOT NULL)
    AND  NVL(icl.adjustment_type_flag, 'X') NOT IN ('Z', 'A')
 ;
--
    -- populate cursor with clines to be deleted
    OPEN c_delete_cl;
    FETCH c_delete_cl BULK COLLECT INTO l_delete_cl_lst;
    CLOSE c_delete_cl;

--
    l_debug_info := 'Delete new associations ADDED as part of the adjustment';
    INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                   p_procedure_name => l_program_name,
                                   p_debug_info => l_debug_info);

    DELETE FROM inl_associations a
    WHERE a.adjustment_type_flag = 'A'
    AND a.ship_header_id = p_ship_header_id
    AND a.from_parent_table_name = 'INL_CHARGE_LINES'
    AND a.from_parent_table_id = ( --Charge Line should be the top of charge lines
                                SELECT
                                    cl1.charge_line_id
                                FROM
                                    inl_charge_lines cl1
                                WHERE
                                CONNECT_BY_ISLEAF = 1
                                START WITH cl1.charge_line_id = a.from_parent_table_id
                                CONNECT BY PRIOR cl1.charge_line_id = cl1.parent_charge_line_id
                                );

--
    l_debug_info := 'Delete new charge lines ADDED as part of the adjustment';
    INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                   p_procedure_name => l_program_name,
                                   p_debug_info => l_debug_info);

    IF NVL (l_delete_cl_lst.LAST, 0) > 0 THEN
        FOR i IN NVL (l_delete_cl_lst.FIRST, 0) ..NVL (l_delete_cl_lst.LAST, 0)
        LOOP
            DELETE FROM inl_charge_lines
            WHERE charge_line_id = l_delete_cl_lst(i).charge_line_id;
        END LOOP;
    END IF;
--
    l_debug_info := 'Revert Association that were flagged to be removed';
    INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                   p_procedure_name => l_program_name,
                                   p_debug_info => l_debug_info);

    UPDATE inl_associations a
    SET a.adjustment_type_flag = NULL,
        a.last_update_login    = l_fnd_login_id,
        a.last_update_date     = SYSDATE,
        a.last_updated_by      = l_fnd_user_id
    WHERE a.adjustment_type_flag = 'R'
    AND a.ship_header_id = p_ship_header_id
    AND a.from_parent_table_name = 'INL_CHARGE_LINES'
    AND a.from_parent_table_id = ( --Charge Line should be the top of charge lines
                                SELECT
                                    cl1.charge_line_id
                                FROM
                                    inl_charge_lines cl1
                                WHERE
                                CONNECT_BY_ISLEAF = 1
                                START WITH cl1.charge_line_id = a.from_parent_table_id
                                CONNECT BY PRIOR cl1.parent_charge_line_id = cl1.charge_line_id
                                );

    l_debug_info := 'Set to N the ELC flag on Shipment Headers';
    INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                   p_procedure_name => l_program_name,
                                   p_debug_info => l_debug_info);
    UPDATE inl_ship_headers_all a
       SET a.pending_update_flag = 'N',
       a.last_update_login    = l_fnd_login_id,
       a.last_update_date     = SYSDATE,
       a.last_updated_by      = l_fnd_user_id
     WHERE a.ship_header_id = p_ship_header_id
     AND a.pending_update_flag IS NOT NULL
     ;

    l_debug_info := 'Call INL_INTERFACE_PVT.Reset_MatchInt';
    INL_LOGGING_PVT.Log_Statement(p_module_name => g_module_name,
                                  p_procedure_name => l_program_name,
                                  p_debug_info => l_debug_info);

    INL_INTERFACE_PVT.Reset_MatchInt(p_ship_header_id => p_ship_header_id,
                   x_return_status => l_return_status);

    -- If unexpected errors happen abort API
    IF l_return_status   = L_FND_RET_STS_ERROR THEN
        x_return_status := l_return_status;
        RAISE L_FND_EXC_ERROR;
    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
        x_return_status  := l_return_status;
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean (p_commit) THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get (p_encoded => L_FND_FALSE,
                               p_count => x_msg_count,
                               p_data => x_msg_data);

    INL_LOGGING_PVT.Log_EndProc (p_module_name => g_module_name,
                                 p_procedure_name => l_program_name);
EXCEPTION
WHEN L_FND_EXC_ERROR THEN
    INL_LOGGING_PVT.Log_ExpecError (p_module_name => g_module_name,
                                    p_procedure_name => l_program_name);
    ROLLBACK TO Discard_Updates_PVT;
    x_return_status := L_FND_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get (p_encoded => L_FND_FALSE,
                               p_count => x_msg_count,
                               p_data => x_msg_data);
WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
    INL_LOGGING_PVT.Log_UnexpecError (p_module_name => g_module_name,
                                      p_procedure_name => l_program_name);
    ROLLBACK TO Discard_Updates_PVT;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get (p_encoded => L_FND_FALSE,
                               p_count => x_msg_count,
                               p_data => x_msg_data);
WHEN OTHERS THEN
    INL_LOGGING_PVT.Log_UnexpecError (p_module_name => g_module_name,
                                      p_procedure_name => l_program_name);
    ROLLBACK TO Discard_Updates_PVT;
    x_return_status := L_FND_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg (p_pkg_name => g_pkg_name,
                                 p_procedure_name => l_program_name);
    END IF;
    FND_MSG_PUB.Count_And_Get (p_encoded => L_FND_FALSE,
                               p_count => x_msg_count,
                               p_data => x_msg_data);
END Discard_Updates;

END INL_SHIPMENT_PVT;

/
