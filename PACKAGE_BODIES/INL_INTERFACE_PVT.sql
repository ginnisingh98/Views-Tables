--------------------------------------------------------
--  DDL for Package Body INL_INTERFACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INL_INTERFACE_PVT" AS
/* $Header: INLVINTB.pls 120.9.12010000.75 2013/09/06 18:30:43 acferrei ship $ */

    L_FND_USER_ID               CONSTANT NUMBER        := fnd_global.user_id;           --Bug#9660043
    L_FND_CONC_PROGRAM_ID       CONSTANT NUMBER        := fnd_global.conc_program_id;   --Bug#9660043
    L_FND_PROG_APPL_ID          CONSTANT NUMBER        := fnd_global.prog_appl_id ;     --Bug#9660043
    L_FND_CONC_REQUEST_ID       CONSTANT NUMBER        := fnd_global.conc_request_id;   --Bug#9660043
    L_FND_CONC_REQUEST_ID_INT            NUMBER        ;  --Bug#11794483B(error when submitted from sql plus)
    L_FND_LOGIN_ID              CONSTANT NUMBER        := fnd_global.login_id;          --Bug#9660043

    L_FND_EXC_ERROR             EXCEPTION;                                              --Bug#9660043
    L_FND_EXC_UNEXPECTED_ERROR  EXCEPTION;                                              --Bug#9660043

    L_FND_RET_STS_SUCCESS       CONSTANT VARCHAR2(1)   := fnd_api.g_ret_sts_success;    --Bug#9660043
    L_FND_RET_STS_ERROR         CONSTANT VARCHAR2(1)   := fnd_api.g_ret_sts_error;      --Bug#9660043
    L_FND_RET_STS_UNEXP_ERROR   CONSTANT VARCHAR2(1)   := fnd_api.g_ret_sts_unexp_error;--Bug#9660043

    CURSOR c_ship_hdr_int
    IS
        SELECT
            ship_header_int_id       ,
            group_id                 ,
            transaction_type         ,
            interface_source_code    ,
            interface_source_table   ,
            interface_source_line_id ,
            validation_flag          ,
            ship_num                 ,
            ship_date                ,
            ship_type_id             ,
            ship_type_code           ,
-- Bug#13582437 problem in 12.2
            NULL legal_entity_id     ,
--            legal_entity_name      ,
            organization_id          ,
            organization_code        ,
            location_id              ,
            location_code            ,
-- Bug#13056434 problem in 12.2
--            org_id                 ,
            NULL org_id              ,
-- Bug#13056434 problem in 12.2
            taxation_country         ,
            document_sub_type        ,
            ship_header_id           ,
            last_task_code           ,
            DECODE(h.transaction_type,'CREATE', NVL(h.rcv_enabled_flag,'Y'), h.rcv_enabled_flag) rcv_enabled_flag, -- dependence
            attribute_category       ,
            attribute1               ,
            attribute2               ,
            attribute3               ,
            attribute4               ,
            attribute5               ,
            attribute6               ,
            attribute7               ,
            attribute8               ,
            attribute9               ,
            attribute10              ,
            attribute11              ,
            attribute12              ,
            attribute13              ,
            attribute14              ,
            attribute15              ,
            NULL user_defined_ship_num_code, -- from inl_parameters (AUTOMATIC or MANUAL)
            NULL manual_ship_num_type,       -- from inl_parameters (NUMERIC or ALPHA)
            NULL LCM_FLOW,                   -- can be AAS=as a service PR= pre receiving
            NULL dflt_country
        FROM inl_ship_headers_int h
        WHERE h.request_id = l_fnd_conc_request_id_int
        ORDER BY h.organization_id -- Bug 16310024
        ;

    TYPE ship_hdr_int_list_type
        IS
        TABLE OF c_ship_hdr_int%ROWTYPE INDEX BY BINARY_INTEGER;

    CURSOR c_ship_ln_int (pc_ship_header_int_id NUMBER)
    IS
        SELECT
            ship_header_int_id         ,
            ship_line_int_id           ,
            group_id                   ,
            processing_status_code     ,
            validation_flag            ,
            ship_line_group_reference  ,
            party_id                   ,
            party_number               ,
            party_site_id              ,
            party_site_number          ,
            source_organization_id     ,
            source_organization_code   ,
            ship_line_num              ,
            ship_line_type_id          ,
            ship_line_type_code        ,
            ship_line_src_type_code    ,
            ship_line_source_id        ,
            currency_code              ,
            currency_conversion_type   ,
            currency_conversion_date   ,
            currency_conversion_rate   ,
            inventory_item_id          ,
            txn_qty                    ,
            txn_uom_code               ,
            txn_unit_price             ,
            primary_qty                ,
            primary_uom_code           ,
            primary_unit_price         ,
            secondary_qty              ,
            secondary_uom_code         ,
            secondary_unit_price       ,
            landed_cost_flag           ,
            allocation_enabled_flag    ,
            trx_business_category      ,
            intended_use               ,
            product_fiscal_class       ,
            product_category           ,
            product_type               ,
            user_def_fiscal_class      ,
            tax_classification_code    ,
            assessable_value           ,
            ship_from_party_id         ,
            ship_from_party_number     ,
            ship_from_party_site_id    ,
            ship_from_party_site_number,
            ship_to_organization_id    ,
            ship_to_organization_code  ,
            ship_to_location_id        ,
            ship_to_location_code      ,
            bill_from_party_id         ,
            bill_from_party_number     ,
            bill_from_party_site_id    ,
            bill_from_party_site_number,
            bill_to_organization_id    ,
            bill_to_organization_code  ,
            bill_to_location_id        ,
            bill_to_location_code      ,
            poa_party_id               ,
            poa_party_number           ,
            poa_party_site_id          ,
            poa_party_site_number      ,
            poo_organization_id        ,
            poo_to_organization_code   ,
            poo_location_id            ,
            poo_location_code          ,
-- Bug#13056434 problem in 12.2
--            org_id                   ,
            NULL org_id                ,
-- Bug#13056434 problem in 12.2
            ship_header_id             ,
            ship_line_id               ,
            interface_source_table     ,
            interface_source_line_id   ,
            created_by                 ,
            creation_date              ,
            last_updated_by            ,
            last_update_date           ,
            last_update_login          ,
            request_id                 ,
            program_id                 ,
            program_application_id     ,
            program_update_date        ,
            attribute_category_lg      ,
            attribute1_lg              ,
            attribute2_lg              ,
            attribute3_lg              ,
            attribute4_lg              ,
            attribute5_lg              ,
            attribute6_lg              ,
            attribute7_lg              ,
            attribute8_lg              ,
            attribute9_lg              ,
            attribute10_lg             ,
            attribute11_lg             ,
            attribute12_lg             ,
            attribute13_lg             ,
            attribute14_lg             ,
            attribute15_lg             ,
            attribute_category_sl      ,
            attribute1_sl              ,
            attribute2_sl              ,
            attribute3_sl              ,
            attribute4_sl              ,
            attribute5_sl              ,
            attribute6_sl              ,
            attribute7_sl              ,
            attribute8_sl              ,
            attribute9_sl              ,
            attribute10_sl             ,
            attribute11_sl             ,
            attribute12_sl             ,
            attribute13_sl             ,
            attribute14_sl             ,
            attribute15_sl             ,
            ship_line_group_num        ,
            inventory_item_name        ,
            ship_line_group_id
        FROM inl_ship_lines_int
        WHERE ship_header_int_id = pc_ship_header_int_id
        ORDER BY
            ship_line_group_reference,
            ship_line_src_type_code,
            ship_header_id,
            party_id,
            party_site_id,
            source_organization_id,
            ship_line_int_id
    ;
    TYPE ship_ln_int_list_type IS TABLE OF c_ship_ln_int%ROWTYPE INDEX BY BINARY_INTEGER;

    TYPE current_SLnGr_rec_type IS RECORD (
        ship_line_group_id        NUMBER,
        ship_line_group_num       NUMBER,
        ship_line_group_reference VARCHAR2(30),
        ship_header_id            NUMBER,
        src_type_code             VARCHAR2(30),
        party_id                  NUMBER,
        party_site_id             NUMBER,
        source_organization_id    NUMBER
    );

    current_SLnGr_rec current_SLnGr_rec_type;


    -- Utility name : Handle_InterfError
    -- Type         : Private
    -- Function     : Handle LCM open interface errors
    -- Pre-reqs     : None
    -- Parameters   :
    -- IN         : p_parent_table_name  IN  VARCHAR2, Identify the point of the error: table_name and
    --              p_parent_table_id    IN  NUMBER,                                    table_ID
    --              p_column_name        IN VARCHAR2   Conditionally Error column name
    --              p_column_value       IN VARCHAR2   Conditionally Error column value
    --              p_error_message_name IN VARCHAR2   Optional Message name(if exists)
    --              p_token1_name        IN VARCHAR2   Optional Message tokens names and values from 1 to 6
    --              p_token1_value       IN VARCHAR2   Optional
    --              p_token2_name        IN VARCHAR2   Optional
    --              p_token2_value       IN VARCHAR2   Optional
    --              p_token3_name        IN VARCHAR2   Optional
    --              p_token3_value       IN VARCHAR2   Optional
    --              p_token4_name        IN VARCHAR2   Optional
    --              p_token4_value       IN VARCHAR2   Optional
    --              p_token5_name        IN VARCHAR2   Optional
    --              p_token5_value       IN VARCHAR2   Optional
    --              p_token6_name        IN VARCHAR2   Optional
    --              p_token6_value       IN VARCHAR2   Optional
    --
    -- OUT          x_return_status      OUT NOCOPY VARCHAR2
    --
    -- Version    : Current version 1.0
    --
    -- Notes      :
PROCEDURE Handle_InterfError
    (
        p_parent_table_name  IN VARCHAR2,
        p_parent_table_id    IN NUMBER,
        p_column_name        IN VARCHAR2,
        p_column_value       IN VARCHAR2,
        p_error_message_name IN VARCHAR2,
        p_token1_name        IN VARCHAR2 DEFAULT NULL,
        p_token1_value       IN VARCHAR2 DEFAULT NULL,
        p_token2_name        IN VARCHAR2 DEFAULT NULL,
        p_token2_value       IN VARCHAR2 DEFAULT NULL,
        p_token3_name        IN VARCHAR2 DEFAULT NULL,
        p_token3_value       IN VARCHAR2 DEFAULT NULL,
        p_token4_name        IN VARCHAR2 DEFAULT NULL,
        p_token4_value       IN VARCHAR2 DEFAULT NULL,
        p_token5_name        IN VARCHAR2 DEFAULT NULL,
        p_token5_value       IN VARCHAR2 DEFAULT NULL,
        p_token6_name        IN VARCHAR2 DEFAULT NULL,
        p_token6_value       IN VARCHAR2 DEFAULT NULL,
        x_return_status      OUT NOCOPY VARCHAR2
    ) IS
    l_program_name          CONSTANT VARCHAR2(30) := 'Handle_InterfError';
    l_return_status      VARCHAR2(1) ;
    l_debug_info         VARCHAR2(2000) ;
    l_ship_header_int_id NUMBER;
    l_error_message      VARCHAR2(2000) ;
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name) ;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;
    -- Creation of Messages
    IF p_error_message_name IS NOT NULL THEN
        FND_MESSAGE.SET_NAME('INL', p_error_message_name) ;
        IF p_token1_name IS NOT NULL THEN
            FND_MESSAGE.SET_TOKEN(p_token1_name, p_token1_value) ;
            IF p_token2_name IS NOT NULL THEN
                FND_MESSAGE.SET_TOKEN(p_token2_name, p_token2_value) ;
                IF p_token3_name IS NOT NULL THEN
                    FND_MESSAGE.SET_TOKEN(p_token3_name, p_token3_value) ;
                    IF p_token4_name IS NOT NULL THEN
                        FND_MESSAGE.SET_TOKEN(p_token4_name, p_token4_value) ;
                        IF p_token5_name IS NOT NULL THEN
                            FND_MESSAGE.SET_TOKEN(p_token5_name, p_token5_value) ;
                            IF p_token6_name IS NOT NULL THEN
                                FND_MESSAGE.SET_TOKEN(p_token6_name, p_token6_value) ;
                            END IF;
                        END IF;
                    END IF;
                END IF;
            END IF;
        END IF;
        FND_MSG_PUB.ADD;
        l_error_message := SUBSTR(FND_MSG_PUB.get(FND_MSG_PUB.Count_Msg(), L_FND_FALSE), 1, 2000) ;
    END IF;
    l_debug_info := 'Error Mesage: '||l_error_message;
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info ) ;

    -- In case of error during Shipment Line import process
    IF p_parent_table_name = 'INL_SHIP_LINES_INT' THEN
        l_debug_info := 'Set Shipment Line Interface status to ERROR.';
        INL_LOGGING_PVT.LOG_STATEMENT(
           P_MODULE_NAME      => G_MODULE_NAME,
           P_PROCEDURE_NAME   => l_program_name,
           P_DEBUG_INFO       => L_DEBUG_INFO) ;

        UPDATE inl_ship_lines_int
        SET processing_status_code      = 'ERROR'              ,
            request_id                  = L_FND_CONC_REQUEST_ID,
            last_updated_by             = L_FND_USER_ID        ,
            last_update_date            = SYSDATE              ,
            last_update_login           = L_FND_LOGIN_ID       ,
            program_id                  = L_FND_CONC_PROGRAM_ID,
            program_update_date         = SYSDATE              ,
            program_application_id      = L_FND_PROG_APPL_ID
          WHERE ship_line_int_id        = p_parent_table_id
            AND processing_status_code <> 'ERROR';

         SELECT ship_header_int_id
           INTO l_ship_header_int_id
           FROM inl_ship_lines_int
          WHERE ship_line_int_id = p_parent_table_id;
/* --Bug#11794442 made in procedure Run_MatchPreProcessor
    ELSIF p_parent_table_name = 'INL_MATCHES_INT' THEN
        l_debug_info := 'Set Match Interface status to ERROR.';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info) ;

        UPDATE inl_matches_int
        SET processing_status_code      = 'ERROR'              ,
            request_id                  = L_FND_CONC_REQUEST_ID,
            last_updated_by             = L_FND_USER_ID        ,
            last_update_date            = SYSDATE              ,
            last_update_login           = L_FND_LOGIN_ID       ,
            program_id                  = L_FND_CONC_PROGRAM_ID,
            program_update_date         = SYSDATE              ,
            program_application_id      = L_FND_PROG_APPL_ID
          WHERE match_int_id            = p_parent_table_id
          AND processing_status_code <> 'ERROR';
*/
    END IF;
    IF p_parent_table_name = 'INL_SHIP_HEADERS_INT'
       OR l_ship_header_int_id IS NOT NULL
    THEN
        l_debug_info := 'Set Shipment Header Interface status to ERROR.';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info) ;

        UPDATE inl_ship_headers_int
        SET processing_status_code      = 'ERROR'              ,
            request_id                  = L_FND_CONC_REQUEST_ID,
            last_updated_by             = L_FND_USER_ID        ,
            last_update_date            = SYSDATE              ,
            last_update_login           = L_FND_LOGIN_ID       ,
            program_id                  = L_FND_CONC_PROGRAM_ID,
            program_update_date         = SYSDATE              ,
            program_application_id      = L_FND_PROG_APPL_ID
          WHERE ship_header_int_id      = NVL(l_ship_header_int_id, p_parent_table_id)
            AND processing_status_code <> 'ERROR';
    END IF;
    l_debug_info := 'Insert detailed error message into Interface Error table.';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info) ;

    INSERT INTO inl_interface_errors (
            interface_error_id,            /*01*/
            parent_table_name,             /*02*/
            parent_table_id,               /*03*/
            column_name,                   /*04*/
            column_value,                  /*05*/
            processing_date,               /*06*/
            error_message_name,            /*07*/
            error_message,                 /*08*/
            token1_name,                   /*09*/
            token1_value,                  /*10*/
            token2_name,                   /*11*/
            token2_value,                  /*12*/
            token3_name,                   /*13*/
            token3_value,                  /*14*/
            token4_name,                   /*15*/
            token4_value,                  /*16*/
            token5_name,                   /*17*/
            token5_value,                  /*18*/
            token6_name,                   /*19*/
            token6_value,                  /*20*/
            created_by,                    /*21*/
            creation_date,                 /*22*/
            last_updated_by,               /*23*/
            last_update_date,              /*24*/
            last_update_login,             /*25*/
            program_id,                    /*26*/
            program_application_id,        /*27*/
            program_update_date,           /*28*/
            request_id                     /*29*/
        )
        VALUES (
            inl_interface_errors_s.NEXTVAL,/*01*/
            p_parent_table_name,           /*02*/
            p_parent_table_id,             /*03*/
            p_column_name,                 /*04*/
            p_column_value,                /*05*/
            SYSDATE,                       /*06*/
            p_error_message_name,          /*07*/
            l_error_message,               /*08*/
            p_token1_name,                 /*09*/
            SUBSTR(p_token1_value,0,200),  /*10*/
            p_token2_name,                 /*11*/
            p_token2_value,                /*12*/
            p_token3_name,                 /*13*/
            p_token3_value,                /*14*/
            p_token4_name,                 /*15*/
            p_token4_value,                /*16*/
            p_token5_name,                 /*17*/
            p_token5_value,                /*18*/
            p_token6_name,                 /*19*/
            p_token6_value,                /*20*/
            L_FND_USER_ID,                 /*21*/
            SYSDATE,                       /*22*/
            L_FND_USER_ID,                 /*23*/
            SYSDATE,                       /*24*/
            L_FND_USER_ID,                 /*25*/
            L_FND_CONC_PROGRAM_ID,         /*26*/
            L_FND_PROG_APPL_ID,            /*27*/
            SYSDATE,                       /*28*/
            L_FND_CONC_REQUEST_ID          /*29*/
    );
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);

EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        x_return_status := L_FND_RET_STS_ERROR;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name);
        END IF;
END Handle_InterfError;

-- Utility name : Reset_InterfError
-- Type       : Private
-- Function   : Delete errors recorded by previous validations
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_parent_table_name IN VARCHAR2
--              p_parent_table_id   IN NUMBER
--
-- OUT          x_return_status     OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Reset_InterfError(
        p_parent_table_name IN VARCHAR2,
        p_parent_table_id   IN NUMBER,
        x_return_status OUT NOCOPY VARCHAR2
) IS
    l_program_name CONSTANT VARCHAR2(30):= 'Reset_InterfError';
    l_return_status VARCHAR2(1);
    l_debug_info VARCHAR2(200);
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    ) ;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;
    l_debug_info    := 'Delete Errors from previous validation.';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    ) ;
     DELETE
       FROM inl_interface_errors
      WHERE parent_table_name = p_parent_table_name
        AND parent_table_id   = p_parent_table_id;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        x_return_status := L_FND_RET_STS_ERROR;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name);
        END IF;
END Reset_InterfError;

-- Utility name : Derive_PartyID
-- Type       : Private
-- Function   : Get Party Id based on a given Party Number
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_party_number  IN VARCHAR2
--
-- OUT          x_return_status OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Derive_PartyID(
        p_party_number  IN VARCHAR2,
        x_return_status IN OUT NOCOPY VARCHAR2
) RETURN NUMBER IS
    l_program_name     CONSTANT VARCHAR2(30) := 'Derive_PartyID';
    l_return_status VARCHAR2(1) ;
    l_debug_info    VARCHAR2(200) ;
    l_return_value  NUMBER;
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    ) ;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;
    l_debug_info    := 'Getting party_id.';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    ) ;
     SELECT party_id
       INTO l_return_value
       FROM hz_parties
      WHERE PARTY_NUMBER = p_party_number;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    );
    RETURN l_return_value;
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        x_return_status := L_FND_RET_STS_ERROR;
        RETURN 0;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
        RETURN 0;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name
            );
        END IF;
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
        RETURN 0;
END Derive_PartyID;

-- Utility name : Derive_PartySiteID
-- Type       : Private
-- Function   : Get Party Site Id based on a given Party Site Number
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_party_site_number IN VARCHAR2
--
-- OUT          x_return_status     OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Derive_PartySiteID(
    p_party_site_number IN         VARCHAR2,
    x_return_status     OUT NOCOPY VARCHAR2
) RETURN NUMBER IS
    l_program_name     CONSTANT VARCHAR2(30) := 'Derive_PartySiteID';
    l_return_status VARCHAR2(1);
    l_debug_info    VARCHAR2(200);
    l_return_value  NUMBER;
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    ) ;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;
    l_debug_info := 'Getting PartySite_id.';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    ) ;
     SELECT party_site_id
       INTO l_return_value
       FROM hz_party_sites
      WHERE party_site_number = p_party_site_number;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    );
    RETURN l_return_value;
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        x_return_status := L_FND_RET_STS_ERROR;
        RETURN 0;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
        RETURN 0;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name
            );
        END IF;
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
        RETURN 0;
END Derive_PartySiteID;

-- Utility name   : Validate_ShipNum
-- Type       : Private
-- Function   : Shipment Number validation.
--              Check if the ship numbering is autiomatic and check the number informed
-- Pre-reqs   : None
-- Parameters :
-- IN         :     p_ship_header_int_id            IN NUMBER
--                  p_validation_flag               IN VARCHAR2
--                  p_organization_id               IN NUMBER
--                  p_transaction_type              IN VARCHAR2
--                  p_user_defined_ship_num_code    IN VARCHAR2,
--                  p_LCM_FLOW                      IN VARCHAR2,
--                  p_manual_ship_num_type          IN VARCHAR2,
--                  p_ship_num                      IN VARCHAR2,
--
-- OUT        :     x_return_status      OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      : ShipNum in create transactions, for LCM as a service, should be null  and automatic (Bug#9198199)
--                                                  in Pre receiving flow verify the LCM Option
--                                                      if it is manual => ship num should be informed and shouldn't exist in shipment header
--              ShipNum in Update transactions can be null if ship header id is informed (verified in validate_HdrUpdateTrxType)

FUNCTION Validate_ShipNum(
    p_ship_header_int_id            IN NUMBER,
    p_organization_id               IN NUMBER,
    p_validation_flag               IN VARCHAR2,
    p_transaction_type              IN VARCHAR2,
    p_user_defined_ship_num_code    IN VARCHAR2,
    p_LCM_FLOW                      IN VARCHAR2,
    p_manual_ship_num_type          IN VARCHAR2,
    p_ship_num                      IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
    l_program_name              CONSTANT VARCHAR2(30) := 'Validate_ShipNum';
    l_debug_info             VARCHAR2(400) ;
    l_result                 VARCHAR2(1) := L_FND_TRUE;
    l_return_status          VARCHAR2(1) := L_FND_TRUE;
    l_count_ship_num_exist   NUMBER;
    l_check_numeric          NUMBER;
    l_valid_ship_num         NUMBER;

BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name) ;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_ship_header_int_id',
        p_var_value      => p_ship_header_int_id) ;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_organization_id',
        p_var_value      => p_organization_id) ;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_transaction_type',
        p_var_value      => p_transaction_type) ;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_user_defined_ship_num_code',
        p_var_value      => p_user_defined_ship_num_code) ;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_LCM_FLOW',
        p_var_value      => p_LCM_FLOW) ;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_ship_num',
        p_var_value      => p_ship_num) ;

    l_debug_info := 'Ship Number validation';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info);

/* Verifyed at Validate_HdrUpdateTrxType

    IF x_ship_header_id IS NOT NULL THEN
        x_ship_num := NULL;
        l_debug_info := 'Ship Header Id IS NOT NULL, then Ship Num is set to be NULL';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);
    ELSIF x_ship_num IS NOT NULL AND p_transaction_type = 'UPDATE' THEN
        BEGIN
            SELECT sh.ship_header_id
            INTO x_ship_header_id
            FROM inl_ship_headers_all sh --Bug#10381495
            WHERE sh.ship_num = x_ship_num
            AND   sh.organization_id = p_organization_id;
        EXCEPTION
            WHEN OTHERS THEN
                l_debug_info := 'Ship Num: ' || x_ship_num || ' not found in inl_ship_headers';
                INL_LOGGING_PVT.Log_Statement(
                    p_module_name      => g_module_name,
                    p_procedure_name   => l_program_name,
                    p_debug_info       => l_debug_info);
                l_result := L_FND_FALSE;
                -- Add a line into inl_ship_errors
                Handle_InterfError(
                    p_parent_table_name  => 'INL_SHIP_HEADERS_INT',
                    p_parent_table_id    => p_ship_header_int_id,
                    p_column_name        => 'SHIP_NUM',
                    p_column_value       => x_ship_num,
                    p_error_message_name => 'INL_ERR_NO_SHIP_NUM',
                    p_token1_name        => 'SHIP_NUM',
                    p_token1_value       => x_ship_num,
                    p_token2_name        => 'ORGANIZATION_ID',
                    p_token2_value       => p_organization_id,
                    x_return_status      => l_return_status);
                -- If any errors happen abort API.
                IF l_return_status = L_FND_RET_STS_ERROR THEN
                    RAISE L_FND_EXC_ERROR;
                ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                    RAISE L_FND_EXC_UNEXPECTED_ERROR;
                END IF;
        END;
    END IF;
*/
    -- Bug #9198199- If LCM Shipment Numbering is MANUAL and is a LCM as a
    -- Service Organization, refuse it
    IF p_user_defined_ship_num_code = 'MANUAL'
        AND  p_LCM_FLOW = 'AAS'
    THEN
        l_debug_info := 'the import Shipment through LCM interface is only allowed for AUTOMATIC Shipment Number Generation in LCM as a Service Flow.';
        INL_LOGGING_PVT.Log_Statement(
           p_module_name      => g_module_name,
           p_procedure_name   => l_program_name,
           p_debug_info       => l_debug_info);

        l_result := L_FND_FALSE;
        -- Add a line into inl_ship_errors
        Handle_InterfError(
                p_parent_table_name  => 'INL_SHIP_HEADERS_INT',
                p_parent_table_id    => p_ship_header_int_id,
                p_column_name        => 'ORGANIZATION_ID',
                p_column_value       => p_organization_id,
                p_error_message_name => 'INL_ERR_IMPORT_SHIP_NUM_GEN',
                p_token1_name        => 'user_defined_ship_num_code',
                p_token1_value       => p_user_defined_ship_num_code,
                x_return_status      => l_return_status) ;

        -- If any errors happen abort API.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
           RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;
    -- /Bug #9198199

    IF p_validation_flag = 'Y' THEN
        l_debug_info := 'Validate Shipment Number according to transation type';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);

        IF p_transaction_type = 'CREATE' THEN
            IF p_user_defined_ship_num_code = 'MANUAL' AND p_LCM_FLOW = 'PR'
            THEN
                IF p_ship_num IS NULL THEN
                    l_debug_info := 'Ship Number cannot be null for a MANUAL defined organization';
                    INL_LOGGING_PVT.Log_Statement(
                        p_module_name      => g_module_name,
                        p_procedure_name   => l_program_name,
                        p_debug_info       => l_debug_info);

                    l_result := L_FND_FALSE;
                    -- Add a line into inl_ship_errors
                    Handle_InterfError(
                        p_parent_table_name  => 'INL_SHIP_HEADERS_INT',
                        p_parent_table_id    => p_ship_header_int_id,
                        p_column_name        => 'SHIP_NUM',
                        p_column_value       => p_ship_num,
                        p_error_message_name => 'INL_ERR_SHIP_NUM_NULL',
                        x_return_status      => l_return_status);
                    -- If any errors happen abort API.
                    IF l_return_status = L_FND_RET_STS_ERROR THEN
                        RAISE L_FND_EXC_ERROR;
                    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                        RAISE L_FND_EXC_UNEXPECTED_ERROR;
                    END IF;
                ELSIF p_ship_num IS NOT NULL
                    AND p_organization_id IS NOT NULL
                THEN
                    SELECT COUNT(1)
                    INTO   l_count_ship_num_exist
                    FROM   inl_ship_headers_all sh --Bug#10381495
                    WHERE  sh.ship_num = p_ship_num
                    AND    sh.organization_id = p_organization_id;

                    INL_LOGGING_PVT.Log_Variable(
                        p_module_name    => g_module_name,
                        p_procedure_name => l_program_name,
                        p_var_name       => 'l_count_ship_num_exist',
                        p_var_value      => l_count_ship_num_exist);

                    IF NVL(l_count_ship_num_exist,0) > 0 THEN
                        l_debug_info := 'Ship Number exists for this Organization';
                        INL_LOGGING_PVT.Log_Statement(
                            p_module_name      => g_module_name,
                            p_procedure_name   => l_program_name,
                            p_debug_info       => l_debug_info);

                        l_result := L_FND_FALSE;
                        -- Add a line into inl_ship_errors
                        Handle_InterfError(
                            p_parent_table_name  => 'INL_SHIP_HEADERS_INT',
                            p_parent_table_id    => p_ship_header_int_id,
                            p_column_name        => 'SHIP_NUM',
                            p_column_value       => p_ship_num,
                            p_error_message_name => 'INL_ERR_SHIP_NUM',
                            p_token1_name        => 'SHIP_NUM',
                            p_token1_value       => p_ship_num,
                            x_return_status      => l_return_status);

                        -- If any errors happen abort API.
                        IF l_return_status = L_FND_RET_STS_ERROR THEN
                            RAISE L_FND_EXC_ERROR;
                        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                            RAISE L_FND_EXC_UNEXPECTED_ERROR;
                        END IF;
                    END IF;

                    IF p_manual_ship_num_type = 'NUMERIC' THEN
                        BEGIN -- alternative approach
                            l_check_numeric := p_ship_num - p_ship_num;
                        EXCEPTION
                            WHEN OTHERS THEN
                                l_check_numeric := null;
                        END;

                        INL_LOGGING_PVT.Log_Variable(
                            p_module_name    => g_module_name,
                            p_procedure_name => l_program_name,
                            p_var_name       => 'l_check_numeric',
                            p_var_value      => l_check_numeric) ;

                        IF(l_check_numeric IS NULL OR l_check_numeric <> 0) THEN
                            l_debug_info := 'Ship Number should be numeric';
                            INL_LOGGING_PVT.Log_Statement(
                                p_module_name      => g_module_name,
                                p_procedure_name   => l_program_name,
                                p_debug_info       => l_debug_info);

                            l_result := L_FND_FALSE;
                            -- Add a line into inl_ship_errors
                            Handle_InterfError(
                                p_parent_table_name  => 'INL_SHIP_HEADERS_INT',
                                p_parent_table_id    => p_ship_header_int_id,
                                p_column_name        => 'SHIP_NUM',
                                p_column_value       => p_ship_num,
                                p_error_message_name => 'INL_SHIPMENT_NUMERIC',
                                p_token1_name        => 'SHIP_NUM',
                                p_token1_value       => p_ship_num,
                                x_return_status      => l_return_status);

                            -- If any errors happen abort API.
                            IF l_return_status = L_FND_RET_STS_ERROR THEN
                                RAISE L_FND_EXC_ERROR;
                            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                                RAISE L_FND_EXC_UNEXPECTED_ERROR;
                            END IF;
                        END IF;
                    END IF;
                END IF;
            ELSIF p_user_defined_ship_num_code = 'AUTOMATIC' THEN
                IF p_ship_num IS NOT NULL THEN
                    l_debug_info := 'For transaction type = CREATE, Ship_Num should be null';
                    INL_LOGGING_PVT.Log_Statement(
                        p_module_name      => g_module_name,
                        p_procedure_name   => l_program_name,
                        p_debug_info       => l_debug_info) ;
                        l_result := L_FND_FALSE;
                    -- Add a line into inl_ship_errors
                    Handle_InterfError(
                        p_parent_table_name  => 'INL_SHIP_HEADERS_INT',
                        p_parent_table_id    => p_ship_header_int_id,
                        p_column_name        => 'USER_DEF_SHIP_NUM_CODE',
                        p_column_value       => 'AUTOMATIC',
                        p_error_message_name => 'INL_ERR_TRX_TP_ID_NNULL',
                        p_token1_name        => 'COLUMN',
                        p_token1_value       => 'SHIP_NUM',
                        p_token2_name        => 'ID_NAME',
                        p_token2_value       => 'INL_SHIP_HEADERS_INT',
                        p_token3_name        => 'ID_VAL',
                        p_token3_value       => p_ship_header_int_id,
                        x_return_status      => l_return_status);
                    -- If any errors happen abort API.
                    IF l_return_status = L_FND_RET_STS_ERROR THEN
                        RAISE L_FND_EXC_ERROR;
                    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                       RAISE L_FND_EXC_UNEXPECTED_ERROR;
                    END IF;
                END IF;
            END IF;
        END IF;
    END IF;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);
    RETURN FND_API.to_boolean(l_result) ;

EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name);
        END IF;
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
END Validate_ShipNum;

-- Utility name   : Validate_ShipType
-- Type       : Private
-- Function   : Derive ship type columns and validate if required.
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_header_int_id IN NUMBER,
--              p_validation_flag    IN VARCHAR2
--
-- OUT        : x_ship_type_id       IN OUT NOCOPY NUMBER
--              x_ship_type_code     IN OUT NOCOPY VARCHAR2
--              x_return_status      IN OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Validate_ShipType(
    p_ship_header_int_id IN NUMBER,
    p_validation_flag    IN VARCHAR2,
    x_ship_type_id       IN OUT NOCOPY NUMBER,
    x_ship_type_code     IN OUT NOCOPY VARCHAR2,
    x_return_status      OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
    l_program_name     CONSTANT VARCHAR2(30) := 'Validate_ShipType';
    l_debug_info    VARCHAR2(400) ;
    l_result        VARCHAR2(1) := L_FND_TRUE;
    l_return_status VARCHAR2(1) := L_FND_TRUE;

    l_ship_type_code   VARCHAR2(400);
    l_active_from_date DATE;
    l_active_to_date   DATE;
    l_column_name      VARCHAR2(15) := 'SHIP_TYPE_ID';
    l_column_value     VARCHAR2(15) := x_ship_type_id;
    l_count_alw_ln_types NUMBER;
    l_count_alw_src_types NUMBER;

BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name) ;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;

    l_debug_info := 'Derive and validate Shipment Type if required';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info) ;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'x_ship_type_id',
        p_var_value      => x_ship_type_id) ;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'x_ship_type_code',
        p_var_value      => x_ship_type_code) ;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_validation_flag',
        p_var_value      => p_validation_flag) ;

    IF p_validation_flag = 'N' THEN
        l_debug_info := 'Validation is not required for Ship Type';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);

         IF x_ship_type_id IS NOT NULL
         THEN
            x_ship_type_code := NULL;
         ELSIF x_ship_type_code IS NOT NULL
         THEN
            l_column_name := 'SHIP_TYPE_CODE';
            l_column_value := x_ship_type_code;

            SELECT st.ship_type_id
            INTO   x_ship_type_id
            FROM   inl_ship_types_b st
            WHERE st.ship_type_code = x_ship_type_code;
         END IF;
    ELSIF p_validation_flag = 'Y' THEN
        l_column_name := 'SHIP_TYPE_ID';
        l_column_value := x_ship_type_id;
        SELECT
            st.ship_type_code,
            TRUNC(st.active_from_date),
            TRUNC(st.active_to_date),
            (   SELECT COUNT(1)
                FROM inl_alwd_line_types alt
                WHERE alt.parent_table_id = st.ship_type_id
                AND   alt.parent_table_name = 'INL_SHIP_TYPES'
            ),
            (   SELECT COUNT(1)
                FROM inl_alwd_source_types alst
                WHERE alst.ship_type_id = st.ship_type_id
            )
        INTO
            x_ship_type_code,
            l_active_from_date,
            l_active_to_date,
            l_count_alw_ln_types,
            l_count_alw_src_types
        FROM   inl_ship_types_vl st
        WHERE (x_ship_type_id IS NOT NULL
                AND st.ship_type_id = x_ship_type_id)
            OR st.ship_type_code = x_ship_type_code
        ;
        -- Validate Ship Type
        IF NOT SYSDATE BETWEEN NVL((TRUNC(l_active_from_date)),SYSDATE)
        AND NVL((TRUNC(l_active_to_date)+.99999)-1,SYSDATE) THEN
            l_debug_info := 'Date is closed for the Ship Type';
            INL_LOGGING_PVT.Log_Statement(
                p_module_name      => g_module_name,
                p_procedure_name   => l_program_name,
                p_debug_info       => l_debug_info) ;

            l_result := L_FND_FALSE;

            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name  => 'INL_SHIP_HEADERS_INT',
                p_parent_table_id    => p_ship_header_int_id,
                p_column_name        => 'SHIP_TYPE_ID',
                p_column_value       => x_ship_type_id,
                p_error_message_name => 'INL_ERR_SHIP_TYPE_CLOSED',
                x_return_status      => l_return_status);
            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        IF NVL(l_count_alw_ln_types,0) = 0 THEN
            l_debug_info := 'No Ship Line Type allowed for the Shipment Type: ' || x_ship_type_code;
            INL_LOGGING_PVT.Log_Statement(
                 p_module_name      => g_module_name,
                 p_procedure_name   => l_program_name,
                 p_debug_info       => l_debug_info) ;

            l_result := L_FND_FALSE;

            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name  => 'INL_SHIP_HEADERS_INT',
                p_parent_table_id    => p_ship_header_int_id,
                p_column_name        => 'SHIP_TYPE_ID',
                p_column_value       => x_ship_type_id,
                p_error_message_name => 'INL_ERR_NO_SHIP_LN_TYPE',
                x_return_status      => l_return_status);
            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        IF NVL(l_count_alw_src_types,0) = 0 THEN
            l_debug_info := 'No Ship Line Type allowed for the Shipment Type: ' || x_ship_type_code;
            INL_LOGGING_PVT.Log_Statement(
                p_module_name      => g_module_name,
                p_procedure_name   => l_program_name,
                p_debug_info       => l_debug_info) ;

            l_result := L_FND_FALSE;

            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name  => 'INL_SHIP_HEADERS_INT',
                p_parent_table_id    => p_ship_header_int_id,
                p_column_name        => 'SHIP_TYPE_ID',
                p_column_value       => x_ship_type_id,
                p_error_message_name => 'INL_ERR_NO_SRC_TYPE',
                x_return_status      => l_return_status);
            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
    END IF;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);
    RETURN FND_API.to_boolean(l_result) ;
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN OTHERS THEN
        -- Add a line into inl_ship_errors
        Handle_InterfError(
            p_parent_table_name  => 'INL_SHIP_HEADERS_INT',
            p_parent_table_id    => p_ship_header_int_id,
            p_column_name        => l_column_name,
            p_column_value       => l_column_value,
            p_error_message_name => 'INL_ERR_SHIP_TP',
            x_return_status      => l_return_status);

        -- If any errors happen abort API.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
END Validate_ShipType;

-- Utility name   : Validate_Party
-- Type       : Private
-- Function   : Derive Party fields and validate if required
--
-- Pre-reqs   : None
-- Parameters :
-- IN         :     p_ship_header_int_id    IN NUMBER
--                  p_ship_line_int_id      IN NUMBER
--                  p_validation_flag       IN VARCHAR2,
--                  p_src_organization_id   IN NUMBER
--                  p_src_organization_code IN VARCHAR2
--                  p_ship_type_id          IN NUMBER
--
-- OUT        :     x_party_id              IN OUT NOCOPY NUMBER
--                  x_party_number          IN OUT NOCOPY VARCHAR2
--                  x_return_status         OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      : Called only for transaction_type = CREATE
FUNCTION Validate_Party(
    p_ship_line_int_id      IN NUMBER,
    p_validation_flag       IN VARCHAR2,
    p_ship_type_id          IN NUMBER,
    x_party_id              IN OUT NOCOPY NUMBER,
    x_party_number          IN OUT NOCOPY VARCHAR2,
    x_return_status         OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
    l_program_name     CONSTANT VARCHAR2(30) := 'Validate_Party';
    l_debug_info    VARCHAR2(400) ;
    l_response        VARCHAR2(1) := L_FND_TRUE;
    l_return_status VARCHAR2(1) := L_FND_TRUE;

    l_column_name      VARCHAR2(15) := 'PARTY_ID';
    l_column_value     VARCHAR2(15) := x_party_id;
    l_count_alw_party_type NUMBER;
    l_count_alw_party_usg  NUMBER;

BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name) ;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_ship_line_int_id',
        p_var_value      => p_ship_line_int_id);

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_validation_flag',
        p_var_value      => p_validation_flag);

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_ship_type_id',
        p_var_value      => p_ship_type_id);


    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'x_party_id',
        p_var_value      => x_party_id);

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'x_party_number',
        p_var_value      => x_party_number);

    IF p_validation_flag = 'N' THEN
        IF x_party_id IS NOT NULL THEN
            x_party_number := NULL;
        ELSIF x_party_number IS NOT NULL THEN
            l_column_name := 'PARTY_NUMBER';
            l_column_value := x_party_NUMBER;

            SELECT party_id
            INTO x_party_id
            FROM hz_parties
            WHERE party_number = x_party_number;
        END IF;

    ELSIF p_validation_flag = 'Y' THEN
        IF x_party_id IS NOT NULL THEN
            l_column_name := 'PARTY_ID';
            l_column_value := x_party_id;
        ELSIF x_party_number IS NOT NULL THEN
            l_column_name := 'PARTY_NUMBER';
            l_column_value := x_party_number;
        END IF;

        SELECT
            party_id,
            party_number,
            (SELECT COUNT(1)
             FROM hz_party_usg_assignments ua
             WHERE ua.party_id = hp.party_id
             AND(UPPER(hp.party_type)
                IN (SELECT
                        UPPER(cfopt.party_type_code)
                    FROM
                        inl_ship_types_vl cfot,
                        inl_alwd_party_types cfopt
                    WHERE
                        cfopt.parent_table_id = cfot.ship_type_id
                    AND cfopt.parent_table_name = 'INL_SHIP_TYPES'
                    AND cfot.ship_type_id = p_ship_type_id))
             AND hp.party_id = hp.party_id),
            (SELECT
                COUNT(1)
             FROM
                hz_party_usages_vl pu,
                hz_party_usg_assignments ua,
                hz_parties hp1
             WHERE
                  pu.party_usage_code = ua.party_usage_code
             AND  ua.party_id = hp1.party_id
             AND  UPPER(pu.party_usage_code)
                    IN
                        (SELECT UPPER(party_usage_code)
                         FROM
                            inl_ship_types_vl cfot,
                            inl_alwd_party_usages cfopt
                         WHERE cfopt.parent_table_id = cfot.ship_type_id
                         AND cfopt.parent_table_name = 'INL_SHIP_TYPES'
                         AND cfot.ship_type_id = p_ship_type_id)
             AND hp1.party_id = hp.party_id)
        INTO
            x_party_id,
            x_party_number,
            l_count_alw_party_type,
            l_count_alw_party_usg
        FROM hz_parties hp
        WHERE
            (x_party_id IS NOT NULL
             AND party_id = x_party_id)
             OR party_number = x_party_number;

        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'l_count_alw_party_type',
            p_var_value      => l_count_alw_party_type);

        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'l_count_alw_party_usg',
            p_var_value      => l_count_alw_party_usg);

        IF NVL(l_count_alw_party_type, 0) = 0 AND x_party_id IS NOT NULL THEN
            l_debug_info := 'Party is not compliant with Party Types defined for the Shipment Type';
            INL_LOGGING_PVT.Log_Statement(
                p_module_name      => g_module_name,
                p_procedure_name   => l_program_name,
                p_debug_info       => l_debug_info);
            l_response := L_FND_FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
               p_parent_table_name  => 'INL_SHIP_LINES_INT',
               p_parent_table_id    => p_ship_line_int_id,
               p_column_name        => 'PARTY_ID',
               p_column_value       => x_party_id,
               p_error_message_name => 'INL_ERR_PARTY_TYPE',
               x_return_status      => l_return_status);
             -- If any errors happen abort API.
             IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
             END IF;
        END IF;
        IF NVL(l_count_alw_party_usg,0) = 0 AND x_party_id IS NOT NULL THEN
            l_debug_info := 'Party is not compliant with Party Usage defined for the Shipment Type';
            INL_LOGGING_PVT.Log_Statement(
              p_module_name      => g_module_name,
              p_procedure_name   => l_program_name,
              p_debug_info       => l_debug_info);
            l_response := L_FND_FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
               p_parent_table_name  => 'INL_SHIP_LINES_INT',
               p_parent_table_id    => p_ship_line_int_id,
               p_column_name        => 'PARTY_ID',
               p_column_value       => x_party_id,
               p_error_message_name => 'INL_ERR_PARTY_USAGE',
               x_return_status      => l_return_status);
             -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
    END IF;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);
    RETURN FND_API.to_boolean(l_response) ;
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN OTHERS THEN
        -- Add a line into inl_ship_errors
        Handle_InterfError(
            p_parent_table_name  => 'INL_SHIP_LINES_INT',
            p_parent_table_id    => p_ship_line_int_id,
            p_column_name        => l_column_name,
            p_column_value       => l_column_value,
            p_error_message_name => 'INL_ERR_PARTY',
            x_return_status      => l_return_status);

        -- If any errors happen abort API.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
END Validate_Party;

-- Utility name   : Validate_PartySite
-- Type       : Private
-- Function   : Derive Party Site fields and validate if required
--
-- Pre-reqs   : None
-- Parameters :
-- IN         :     p_ship_line_int_id      IN NUMBER
--                  p_validation_flag       IN VARCHAR2
--                  p_party_id              IN NUMBER
--                  p_dflt_country          IN VARCHAR2
--                  p_ship_type_id          IN NUMBER
--
-- OUT        : x_party_site_id      IN OUT NOCOPY NUMBER
--              x_party_site_number  IN OUT NOCOPY VARCHAR2
--              x_return_status      OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Validate_PartySite(
    p_ship_line_int_id      IN NUMBER,
    p_validation_flag       IN VARCHAR2,
    p_party_id              IN NUMBER,
    p_dflt_country          IN VARCHAR2,
    p_ship_type_id          IN NUMBER,
    x_party_site_id         IN OUT NOCOPY NUMBER,
    x_party_site_number     IN OUT NOCOPY VARCHAR2,
    x_return_status         OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
    l_program_name     CONSTANT VARCHAR2(30) := 'Validate_PartySite';
    l_debug_info    VARCHAR2(400) ;
    l_response        VARCHAR2(1) := L_FND_TRUE;
    l_return_status VARCHAR2(1) := L_FND_TRUE;

    l_column_name         VARCHAR2(25) := 'PARTY_SITE_ID';
    l_column_value        VARCHAR2(20) := x_party_site_id;
    l_count_belongs_party NUMBER;
    l_count_alw_party     NUMBER;

BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name) ;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_party_id',
        p_var_value      => p_party_id);

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'x_party_site_id',
        p_var_value      => x_party_site_id);

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'x_party_site_number',
        p_var_value      => x_party_site_number);

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_ship_line_int_id',
        p_var_value      => p_ship_line_int_id);

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_validation_flag',
        p_var_value      => p_validation_flag);

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_dflt_country',
        p_var_value      => p_dflt_country);

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_ship_type_id',
        p_var_value      => p_ship_type_id);

    IF p_validation_flag = 'N' THEN
        l_debug_info := 'Validation is not required for Party Site';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);
        IF x_party_site_id IS NOT NULL THEN
            x_party_site_number := NULL;
        ELSIF x_party_site_number IS NOT NULL THEN
            l_column_name  := 'PARTY_SITE_NUMBER';
            l_column_value := x_party_site_number;

            SELECT hps.party_site_id
            INTO x_party_site_id
            FROM hz_party_sites hps
            WHERE party_site_number = x_party_site_number;
        END IF;
    ELSE

        l_debug_info := 'Validation is required for Party Site';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);

        IF x_party_site_id IS NOT NULL THEN
            l_column_name  := 'PARTY_SITE_NUMBER';
            l_column_value := x_party_site_number;
        ELSIF x_party_site_number IS NOT NULL THEN
            l_column_name  := 'PARTY_SITE_NUMBER';
            l_column_value := x_party_site_number;
        END IF;

        l_debug_info := 'Derive Party Site Id from Party Site Number';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);

        SELECT hps.party_site_id,
               hps.party_site_number,
               (SELECT COUNT(1)
                FROM hz_party_sites hps1
                WHERE hps1.party_id = p_party_id
                AND   hps1.party_site_id = hps.party_site_id),
                (SELECT COUNT(1)
                 FROM   hz_party_sites   hps2,
                        hz_locations     hl,
                        fnd_territories_vl ftv,
                        inl_ship_types_vl shv
                 WHERE hps.location_id = hl.location_id
                 AND   ftv.territory_code = hl.country
                 AND   shv.ship_type_id = p_ship_type_id
                 AND   hps.party_id = p_party_id
                 AND  ((shv.trd_pties_alwd_code = 1 AND hl.country = p_dflt_country)
                 OR    (shv.trd_pties_alwd_code = 2 AND hl.country <> p_dflt_country)
                 OR    (shv.trd_pties_alwd_code = 3))
                 AND   hps.party_site_id = hps.party_site_id)
        INTO
            x_party_site_id,
            x_party_site_number,
            l_count_belongs_party,
            l_count_alw_party
        FROM hz_party_sites hps
        WHERE ( x_party_site_id IS NOT null
                AND party_site_id = x_party_site_id)
            OR party_site_number = x_party_site_number;

        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_party_site_id',
            p_var_value      => x_party_site_id);
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_party_site_number',
            p_var_value      => x_party_site_number);

        -- Party Site Validation
        IF p_party_id IS NULL AND
          (x_party_site_id IS NOT NULL OR x_party_site_number IS NOT NULL) THEN
            l_debug_info := 'Party is null, so party site should be null';
            INL_LOGGING_PVT.Log_Statement(
                p_module_name      => g_module_name,
                p_procedure_name   => l_program_name,
                p_debug_info       => l_debug_info);
            l_response := L_FND_FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name  => 'INL_SHIP_LINES_INT',
                p_parent_table_id    => p_ship_line_int_id,
                p_column_name        => 'PARTY_SITE_ID',
                p_column_value       => x_party_site_id,
                p_error_message_name => 'INL_ERR_3RD_PTY_ST_NNULL',
                x_return_status      => l_return_status);
            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
               RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        IF NVL(l_count_belongs_party, 0) = 0
            AND x_party_site_id IS NOT NULL
        THEN
            l_debug_info := 'Party Site should belong to the Party';
            INL_LOGGING_PVT.Log_Statement(
                p_module_name      => g_module_name,
                p_procedure_name   => l_program_name,
                p_debug_info       => l_debug_info);
            l_response := L_FND_FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name  => 'INL_SHIP_LINES_INT',
                p_parent_table_id    => p_ship_line_int_id,
                p_column_name        => 'PARTY_SITE_ID',
                p_column_value       => x_party_site_id,
                p_error_message_name => 'INL_ERR_NO_3RD_PTY_ST_DEF_PTY',
                x_return_status      => l_return_status);
            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
             END IF;
        ELSIF NVL(l_count_alw_party, 0) = 0 AND x_party_site_id IS NOT NULL THEN
            l_debug_info := 'Party Site does not match with the Third Party Sites Allowed defined in Ship Type';
            INL_LOGGING_PVT.Log_Statement(
                p_module_name      => g_module_name,
                p_procedure_name   => l_program_name,
                p_debug_info       => l_debug_info);
            l_response := L_FND_FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name  => 'INL_SHIP_LINES_INT',
                p_parent_table_id    => p_ship_line_int_id,
                p_column_name        => 'PARTY_SITE_ID',
                p_column_value       => x_party_site_id,
                p_error_message_name => 'INL_ERR_3RD_PTY_ST_ALLOWED',
                p_token1_name        => 'GROUP_REF',
                p_token1_value       => NULL,
                p_token2_name        => 'PARTY_SITE',
                p_token2_value       => x_party_site_id,
                p_token3_name        => 'SHIP_TYPE',
                p_token3_value       => p_ship_type_id,
                x_return_status      => l_return_status);
            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
    END IF;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);
    RETURN FND_API.to_boolean(l_response) ;
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN OTHERS THEN
        -- Add a line into inl_ship_errors
        Handle_InterfError(
            p_parent_table_name  => 'INL_SHIP_LINES_INT',
            p_parent_table_id    => p_ship_line_int_id,
            p_column_name        => l_column_name,
            p_column_value       => l_column_value,
            p_error_message_name => 'INL_ERR_PARTY_SITE',
            x_return_status      => l_return_status);

        -- If any errors happen abort API.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
        RETURN FND_API.to_boolean(L_FND_FALSE);
END Validate_PartySite;

-- Utility name   : Validate_SrcOrganization
-- Type       : Private
-- Function   : Derive Source Organization fields and validate it if required
--
-- Pre-reqs   : None
-- Parameters :
-- IN         :     p_ship_line_int_id      IN NUMBER
--                  p_validation_flag       IN VARCHAR2
--
-- OUT        : x_src_organization_id   IN NOUT NOCOPY NUMBER
--              x_src_organization_code IN OUT NOCOPY VARCHAR2
--              x_return_status         OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Validate_SrcOrganization(
    p_ship_line_int_id      IN NUMBER,
    p_validation_flag       IN VARCHAR2,
    x_src_organization_id   IN OUT NOCOPY NUMBER,
    x_src_organization_code IN OUT NOCOPY VARCHAR2,
    x_return_status         OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
    l_program_name     CONSTANT VARCHAR2(30) := 'Validate_SrcOrganization';
    l_debug_info    VARCHAR2(400) ;
    l_result        VARCHAR2(1) := L_FND_TRUE;
    l_return_status VARCHAR2(1) := L_FND_TRUE;

    l_column_name      VARCHAR2(40);
    l_column_value     VARCHAR2(25);
    l_count_alw_party_type NUMBER;
    l_count_alw_party_usg  NUMBER;

BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name) ;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;

    l_debug_info := 'Derive Source Organization and validate it if required ';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info);

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'x_src_organization_id',
        p_var_value      => x_src_organization_id);
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'x_src_organization_code',
        p_var_value      => x_src_organization_code);
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_ship_line_int_id',
        p_var_value      => p_ship_line_int_id);
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_validation_flag',
        p_var_value      => p_validation_flag);

    IF p_validation_flag = 'N' THEN
        l_debug_info := 'Validation is not required for Source Organization, only derivation';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info) ;
        IF x_src_organization_id IS NOT NULL THEN
            x_src_organization_code := NULL;
        ELSIF x_src_organization_code IS NOT NULL THEN
            l_column_name  := 'SOURCE_ORGANIZATION_CODE';
            l_column_value := x_src_organization_code;

            SELECT ood.organization_id
            INTO x_src_organization_id
            FROM org_organization_definitions ood
            WHERE ood.organization_code = x_src_organization_code;
        END IF;
    ELSIF p_validation_flag = 'Y' THEN
        l_debug_info := 'Derive and validate Source Organization';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info) ;

        IF x_src_organization_id IS NOT NULL THEN
            l_column_name  := 'SOURCE_ORGANIZATION_CODE';
            l_column_value := x_src_organization_code;
        ELSE -- x_src_organization_code IS NOT NULL
            l_column_name  := 'SOURCE_ORGANIZATION_CODE';
            l_column_value := x_src_organization_code;
        END IF;
        SELECT
            ood.organization_code,
            ood.organization_id
        INTO
            x_src_organization_code,
            x_src_organization_id
        FROM
            org_organization_definitions ood
        WHERE (
            x_src_organization_id IS NOT NULL
            AND ood.organization_id = x_src_organization_id
            )
            OR
            ood.organization_code = x_src_organization_code
        ;
   END IF;

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);
    RETURN FND_API.to_boolean(l_result) ;
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN OTHERS THEN
        -- Add a line into inl_ship_errors
        Handle_InterfError(
            p_parent_table_name  => 'INL_SHIP_LINES_INT',
            p_parent_table_id    => p_ship_line_int_id,
            p_column_name        => l_column_name,
            p_column_value       => l_column_value,
            p_error_message_name => 'INL_ERR_SRC_ORG',
            x_return_status      => l_return_status);
        -- If any errors happen abort API.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
END Validate_SrcOrganization;

-- Utility name   : Validate_ShipLineGrpNum
-- Type       : Private
-- Function   : Derive ship line group id when transaction_type = UPDATE
--
-- Pre-reqs   : None
-- Parameters :
-- IN         :     p_ship_header_int_id  IN NUMBER
--                  p_ship_line_int_id    IN NUMBER
--                  p_validation_flag     IN VARCHAR2
--                  p_ship_header_id      IN NUMBER
--                  p_ship_line_id        IN NUMBER
--
-- OUT        :     x_ship_line_group_num IN OUT NOCOPY NUMBER
--                  x_ship_line_group_id  IN OUT NOCOPY NUMBER
--                  x_return_status       OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      : Called only for transaction_type = UPDATE

FUNCTION Validate_ShipLineGrpNum(
    p_ship_header_int_id  IN NUMBER,
    p_ship_line_int_id    IN NUMBER,
    p_validation_flag     IN VARCHAR2,
    p_ship_header_id      IN NUMBER,
    p_ship_line_id        IN NUMBER,
    x_ship_line_group_num IN OUT NOCOPY NUMBER,
    x_ship_line_group_id  IN OUT NOCOPY NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
    l_program_name              CONSTANT VARCHAR2(30) := 'Validate_ShipLineGrpNum';
    l_debug_info             VARCHAR2(400) ;
    l_result                 VARCHAR2(1) := L_FND_TRUE;
    l_return_status          VARCHAR2(1) := L_FND_TRUE;
    l_column_name            VARCHAR2(30):= 'SHIP_LINE_GROUP_NUM';
    l_colum_value            VARCHAR2(30):= x_ship_line_group_num;
    l_valid_ln_group         NUMBER;

BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name) ;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;

    l_debug_info := 'Ship Line Group validation';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info);

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_ship_header_int_id',
        p_var_value      => p_ship_header_int_id) ;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_ship_line_int_id',
        p_var_value      => p_ship_line_int_id);

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_validation_flag',
        p_var_value      => p_validation_flag) ;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_ship_header_id',
        p_var_value      => p_ship_header_id) ;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_ship_line_id',
        p_var_value      => p_ship_line_id) ;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'x_ship_line_group_num',
        p_var_value      => x_ship_line_group_num) ;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'x_ship_line_group_id',
        p_var_value      => x_ship_line_group_id) ;

    IF x_ship_line_group_id IS NOT NULL THEN
        x_ship_line_group_num := NULL;

        IF p_validation_flag = 'Y' THEN

            l_debug_info := 'Validating Ship Line Group Number';
            INL_LOGGING_PVT.Log_Statement(
                p_module_name      => g_module_name,
                p_procedure_name   => l_program_name,
                p_debug_info       => l_debug_info);

            SELECT COUNT(1)
            INTO l_valid_ln_group
            FROM inl_ship_line_groups slg
            WHERE slg.ship_line_group_id = x_ship_line_group_id;

            INL_LOGGING_PVT.Log_Variable(
                p_module_name    => g_module_name,
                p_procedure_name => l_program_name,
                p_var_name       => 'l_valid_ln_group',
                p_var_value      => l_valid_ln_group);

            IF NVL(l_valid_ln_group, 0) = 0 THEN
                l_debug_info := 'No Group Number found';
                INL_LOGGING_PVT.Log_Statement(
                    p_module_name      => g_module_name,
                    p_procedure_name   => l_program_name,
                    p_debug_info       => l_debug_info);
                l_result := L_FND_FALSE;
                -- Add a line into inl_ship_errors
                Handle_InterfError(
                    p_parent_table_name  => 'INL_SHIP_LINES_INT',
                    p_parent_table_id    => p_ship_line_int_id,
                    p_column_name        => 'SHIP_LINE_GROUP_NUM',
                    p_column_value       => x_ship_line_group_num,
                    p_error_message_name => 'INL_ERR_NO_LN_GRP',
                    x_return_status      => l_return_status);
                -- If any errors happen abort API.
                IF l_return_status = L_FND_RET_STS_ERROR THEN
                    RAISE L_FND_EXC_ERROR;
                ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                   RAISE L_FND_EXC_UNEXPECTED_ERROR;
                END IF;
            END IF;
        END IF;
    ELSIF x_ship_line_group_num IS NOT NULL THEN
        l_debug_info := 'Deriving Ship Line Group from x_ship_line_group_num';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);
        BEGIN
            SELECT slg.ship_line_group_id
            INTO x_ship_line_group_id
            FROM inl_ship_line_groups slg
            WHERE slg.ship_header_id = p_ship_header_id
            AND   slg.ship_line_group_num = x_ship_line_group_num;
        EXCEPTION
            WHEN OTHERS THEN
                l_debug_info := 'No Group Number found';
                INL_LOGGING_PVT.Log_Statement(
                    p_module_name      => g_module_name,
                    p_procedure_name   => l_program_name,
                    p_debug_info       => l_debug_info);
                l_result := L_FND_FALSE;
                -- Add a line into inl_ship_errors
                Handle_InterfError(
                    p_parent_table_name  => 'INL_SHIP_LINES_INT',
                    p_parent_table_id    => p_ship_line_int_id,
                    p_column_name        => 'SHIP_LINE_GROUP_NUM',
                    p_column_value       => x_ship_line_group_num,
                    p_error_message_name => 'INL_ERR_NO_LN_GRP',
                    x_return_status      => l_return_status);
                -- If any errors happen abort API.
                IF l_return_status = L_FND_RET_STS_ERROR THEN
                    RAISE L_FND_EXC_ERROR;
                ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                   RAISE L_FND_EXC_UNEXPECTED_ERROR;
                END IF;
        END;
/* -- -- -- -- -- */
    ELSIF p_ship_line_id IS NOT NULL THEN
        l_debug_info := 'Deriving Ship Line Group from p_ship_line_id';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);
        BEGIN
            SELECT sl.ship_line_group_id, slg.ship_line_group_num
            INTO x_ship_line_group_id,
                 x_ship_line_group_num
            FROM inl_ship_lines_all sl, --Bug#10381495
                 inl_ship_line_groups slg
            WHERE sl.ship_header_id = p_ship_header_id
            AND   sl.ship_line_id = p_ship_line_id
            AND   sl.ship_line_group_id = slg.ship_line_group_id
            ;
        EXCEPTION
            WHEN OTHERS THEN
                l_debug_info := 'No Group Number found';
                INL_LOGGING_PVT.Log_Statement(
                    p_module_name      => g_module_name,
                    p_procedure_name   => l_program_name,
                    p_debug_info       => l_debug_info);
                l_result := L_FND_FALSE;
                -- Add a line into inl_ship_errors
                Handle_InterfError(
                    p_parent_table_name  => 'INL_SHIP_LINES_INT',
                    p_parent_table_id    => p_ship_line_int_id,
                    p_column_name        => 'SHIP_LINE_GROUP_NUM',
                    p_column_value       => x_ship_line_group_num,
                    p_error_message_name => 'INL_ERR_NO_LN_GRP',
                    x_return_status      => l_return_status);
                -- If any errors happen abort API.
                IF l_return_status = L_FND_RET_STS_ERROR THEN
                    RAISE L_FND_EXC_ERROR;
                ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                   RAISE L_FND_EXC_UNEXPECTED_ERROR;
                END IF;
        END;
/* -- -- -- -- -- */
    END IF;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'x_ship_line_group_num',
        p_var_value      => x_ship_line_group_num) ;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'x_ship_line_group_id',
        p_var_value      => x_ship_line_group_id) ;


    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);
    RETURN FND_API.to_boolean(l_result) ;
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN OTHERS THEN
      -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name);
        END IF;
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
END Validate_ShipLineGrpNum;

-- Utility name   : Validate_ShipLineNum
-- Type       : Private
-- Function   : Derive ship line id when transaction_type = UPDATE
--
-- Pre-reqs   : None
-- Parameters :
-- IN         :     p_ship_line_int_id    IN NUMBER
--                  p_validation_flag     IN VARCHAR2
--                  p_transaction_type    IN VARCHAR2
--                  p_ship_header_id      IN NUMBER
--                  p_ship_line_group_id  IN NUMBER
--                  p_ship_line_num       IN NUMBER
--
-- OUT        :     x_ship_line_id        IN OUT NOCOPY NUMBER
--                  x_return_status       OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      : Called only for transaction_type = UPDATE

FUNCTION Validate_ShipLineNum(
    p_ship_line_int_id    IN NUMBER,
    p_validation_flag     IN VARCHAR2,
    p_ship_header_id      IN NUMBER,
    p_ship_line_group_id  IN NUMBER,
    x_ship_line_num       IN OUT NOCOPY NUMBER,
    x_ship_line_id        IN OUT NOCOPY NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
    l_program_name               CONSTANT VARCHAR2(30) := 'Validate_ShipLineNum';
    l_debug_info              VARCHAR2(400) ;
    l_response                VARCHAR2(1) := L_FND_TRUE;
    l_return_status           VARCHAR2(1);
    l_count_ship_ln_num_exist NUMBER;
    l_column_name             VARCHAR2(30);
    l_colum_value             VARCHAR2(30);
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name) ;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_ship_line_int_id',
        p_var_value      => p_ship_line_int_id);

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_validation_flag',
        p_var_value      => p_validation_flag) ;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_ship_header_id',
        p_var_value      => p_ship_header_id) ;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_ship_line_group_id',
        p_var_value      => p_ship_line_group_id) ;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'x_ship_line_num',
        p_var_value      => x_ship_line_num) ;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'x_ship_line_id',
        p_var_value      => x_ship_line_id) ;

    IF x_ship_line_id IS NOT NULL THEN
        l_column_name := 'x_ship_line_id';
        l_colum_value := x_ship_line_id;

        x_ship_line_num := NULL;
        IF p_validation_flag = 'Y' THEN
            SELECT COUNT (1)
            INTO l_count_ship_ln_num_exist
            FROM inl_ship_lines_all sl --Bug#10381495
            WHERE sl.ship_line_id = x_ship_line_id;

            IF NVL(l_count_ship_ln_num_exist,0) = 0 THEN
                l_debug_info := 'No Shipment Line found';
                INL_LOGGING_PVT.Log_Statement(
                    p_module_name      => g_module_name,
                    p_procedure_name   => l_program_name,
                    p_debug_info       => l_debug_info);
                l_response := L_FND_FALSE;
                -- Add a line into inl_ship_errors
                Handle_InterfError(
                    p_parent_table_name  => 'INL_SHIP_LINES_INT',
                    p_parent_table_id    => p_ship_line_int_id,
                    p_column_name        => 'SHIP_LINE_ID',
                    p_column_value       => x_ship_line_id,
                    p_error_message_name => 'INL_ERR_CHK_NO_SHIP_LN',
                    x_return_status      => l_return_status);
                -- If any errors happen abort API.
                IF l_return_status = L_FND_RET_STS_ERROR THEN
                    RAISE L_FND_EXC_ERROR;
                ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                   RAISE L_FND_EXC_UNEXPECTED_ERROR;
                END IF;
            END IF;
        END IF;
    ELSIF x_ship_line_num IS NOT NULL THEN
        l_column_name := 'x_ship_line_num';
        l_colum_value := x_ship_line_num;
        BEGIN
            SELECT sl.ship_line_id
            INTO x_ship_line_id
            FROM inl_ship_lines_all sl --Bug#10381495
            WHERE sl.ship_header_id = p_ship_header_id
            AND sl.ship_line_group_id = p_ship_line_group_id
            AND sl.ship_line_num = x_ship_line_num;
        EXCEPTION
            WHEN OTHERS THEN
                l_debug_info := 'No Ship Line Number found';
                INL_LOGGING_PVT.Log_Statement(
                    p_module_name      => g_module_name,
                    p_procedure_name   => l_program_name,
                    p_debug_info       => l_debug_info);
                l_response := L_FND_FALSE;
                -- Add a line into inl_ship_errors
                Handle_InterfError(
                    p_parent_table_name  => 'INL_SHIP_LINES_INT',
                    p_parent_table_id    => p_ship_line_int_id,
                    p_column_name        => 'SHIP_LINE_NUM',
                    p_column_value       => x_ship_line_num,
                    p_error_message_name => 'INL_ERR_CHK_NO_SHIP_LN',
                    x_return_status      => l_return_status);
                -- If any errors happen abort API.
                IF l_return_status = L_FND_RET_STS_ERROR THEN
                    RAISE L_FND_EXC_ERROR;
                ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                   RAISE L_FND_EXC_UNEXPECTED_ERROR;
                END IF;
        END;
    END IF;

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);
    RETURN FND_API.to_boolean(l_response) ;
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN OTHERS THEN
        -- Add a line into inl_ship_errors
        Handle_InterfError(
            p_parent_table_name  => 'INL_SHIP_LINES_INT',
            p_parent_table_id    => p_ship_line_int_id,
            p_column_name        => 'SHIP_LINE_NUM',
            p_column_value       => x_ship_line_num,
            p_error_message_name => 'INL_ERR_CHK_NO_SHIP_LN',
            x_return_status      => l_return_status);
        -- If any errors happen abort API.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
END Validate_ShipLineNum;

-- Utility name   : Validate_ShipLineType
-- Type       : Private
-- Function   : Derive Shipment Line Type and validate it if required
--              Check if the ship Line type exists, is active for sysdate
--              and is associated with the ship type
-- Pre-reqs   : None
-- Parameters :
-- IN         :     p_ship_line_int_id    IN NUMBER,
--                  p_validation_flag     IN VARCHAR2,
--                  p_ship_type_id        IN NUMBER,
--
-- OUT        :     x_ship_line_type_id   IN OUT NOCOPY NUMBER,
--                  x_ship_line_type_code IN OUT NOCOPY VARCHAR2,
--                  x_landed_cost_flag    IN OUT NOCOPY VARCHAR2,
--                  x_alloc_enabled_flag  IN OUT NOCOPY VARCHAR2,
--                  x_return_status       OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Validate_ShipLineType(
    p_ship_line_int_id    IN NUMBER,
    p_validation_flag     IN VARCHAR2,
    p_ship_type_id        IN NUMBER,
    x_ship_line_type_id   IN OUT NOCOPY NUMBER,
    x_ship_line_type_code IN OUT NOCOPY VARCHAR2,
    x_landed_cost_flag    IN OUT NOCOPY VARCHAR2,
    x_alloc_enabled_flag  IN OUT NOCOPY VARCHAR2,
    x_return_status       OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
    l_program_name     CONSTANT VARCHAR2(30) := 'Validate_ShipLineType';
    l_debug_info    VARCHAR2(400) ;
    l_result        VARCHAR2(1) := L_FND_TRUE;
    l_return_status VARCHAR2(1) := L_FND_TRUE;

    l_ship_line_type_code VARCHAR2(400);
    l_active_from_date    DATE;
    l_active_to_date      DATE;
    l_count_alw_ship_ln   NUMBER;
    l_column_name         VARCHAR2(30);
    l_column_value        VARCHAR2(30);

BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name) ;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_ship_line_int_id',
        p_var_value      => p_ship_line_int_id);
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_validation_flag',
        p_var_value      => p_validation_flag);
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_ship_type_id',
        p_var_value      => p_ship_type_id);
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'x_ship_line_type_id',
        p_var_value      => x_ship_line_type_id);
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'x_ship_line_type_code',
        p_var_value      => x_ship_line_type_code);

    IF p_validation_flag = 'N' THEN
        l_debug_info := 'Validation is not required for Ship Line Type';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info) ;

        IF x_ship_line_type_id IS NOT NULL THEN
            l_column_name  := 'SHIP_LINE_TYPE_ID';
            l_column_value := x_ship_line_type_id;
            x_ship_line_type_code := NULL;
        ELSE
            l_column_name  := 'SHIP_LINE_TYPE_CODE';
            l_column_value := x_ship_line_type_code;
        END IF;
        SELECT slt.ship_line_type_id,
               slt.dflt_landed_cost_flag,       -- # Bug 9866323
               slt.dflt_allocation_enabled_flag -- # Bug 9866323
        INTO x_ship_line_type_id,
             x_landed_cost_flag,
             x_alloc_enabled_flag
        FROM inl_ship_line_types_b slt
        WHERE (
            x_ship_line_type_id IS NOT NULL
            AND slt.ship_line_type_id = x_ship_line_type_id
        ) OR
            slt.ship_line_type_code = x_ship_line_type_code;
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_landed_cost_flag',
            p_var_value      => x_landed_cost_flag);

        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_alloc_enabled_flag',
            p_var_value      => x_alloc_enabled_flag);

    ELSIF p_validation_flag = 'Y' THEN
        l_debug_info := 'Derive and validate Ship Line Type';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);
        IF x_ship_line_type_id IS NOT NULL THEN
            l_column_name  := 'SHIP_LINE_TYPE_ID';
            l_column_value := x_ship_line_type_id;
            x_ship_line_type_code := NULL;
        ELSE
            l_column_name  := 'SHIP_LINE_TYPE_CODE';
            l_column_value := x_ship_line_type_code;
        END IF;
        SELECT
            slt.ship_line_type_code,
            slt.active_from_date,
            slt.active_to_date,
                   (SELECT COUNT(1)
                    FROM inl_alwd_line_types sltallow
                    WHERE sltallow.ship_line_type_id = slt.ship_line_type_id
                    AND   sltallow.parent_table_name   = 'INL_SHIP_TYPES'
                    AND   sltallow.parent_table_id     = p_ship_type_id),
            slt.dflt_landed_cost_flag,       -- # Bug 9866323
            slt.dflt_allocation_enabled_flag -- # Bug 9866323
        INTO
            x_ship_line_type_code,
            l_active_from_date,
            l_active_to_date,
            l_count_alw_ship_ln,
            x_landed_cost_flag,
            x_alloc_enabled_flag
        FROM inl_ship_line_types_b slt
        WHERE (x_ship_line_type_id IS NOT NULL
               AND slt.ship_line_type_id = x_ship_line_type_id)
        OR slt.ship_line_type_code = x_ship_line_type_code;

        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_landed_cost_flag',
            p_var_value      => x_landed_cost_flag);

        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_alloc_enabled_flag',
            p_var_value      => x_alloc_enabled_flag);

        -- Validate Ship Line Type
        IF NOT SYSDATE BETWEEN NVL((TRUNC(l_active_from_date)),SYSDATE)
        AND NVL((TRUNC(l_active_to_date)+.99999)-1,SYSDATE) THEN
            l_debug_info := 'Date is closed for the Ship Line Type';
            INL_LOGGING_PVT.Log_Statement(
                p_module_name      => g_module_name,
                p_procedure_name   => l_program_name,
                p_debug_info       => l_debug_info);
            l_result := L_FND_FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name  => 'INL_SHIP_LINES_INT',
                p_parent_table_id    => p_ship_line_int_id,
                p_column_name        => 'SHIP_LINE_TYPE_ID',
                p_column_value       => x_ship_line_type_id,
                p_error_message_name => 'INL_ERR_SHIP_LN_TP_CLOSED',
                x_return_status      => l_return_status);
            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
               RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        IF NVL(l_count_alw_ship_ln,0) = 0 THEN
            l_debug_info := 'Ship Line Type is not defined for the specified Ship Type';
            INL_LOGGING_PVT.Log_Statement(
                p_module_name      => g_module_name,
                p_procedure_name   => l_program_name,
                p_debug_info       => l_debug_info);
            l_result := L_FND_FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name  => 'INL_SHIP_LINES_INT',
                p_parent_table_id    => p_ship_line_int_id,
                p_column_name        => 'SHIP_LINE_TYPE_ID',
                p_column_value       => x_ship_line_type_id,
                p_error_message_name => 'INL_ERR_NO_SHIP_LN_DEF',
                x_return_status      => l_return_status);
            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
               RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
    END IF;

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);
    RETURN FND_API.to_boolean(l_result);
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN OTHERS THEN
        -- Add a line into inl_ship_errors
        Handle_InterfError(
            p_parent_table_name  => 'INL_SHIP_HEADERS_INT',
            p_parent_table_id    => p_ship_line_int_id,
            p_column_name        => l_column_name,
            p_column_value       => l_column_value,
            p_error_message_name => 'INL_ERR_LN_TP',
            x_return_status      => l_return_status);

        -- If any errors happen abort API.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
END Validate_ShipLineType;

-- Utility name   : Validate_ShipLnSrcTypeCode
-- Type       : Private
-- Function   : Validate the ship line source type code if required.
--              Check against INL_SHIP_LINE_SRC_TYPES lookup
-- Pre-reqs   : None
-- Parameters :
-- IN         :     p_ship_line_int_id    IN NUMBER
--                  p_ship_ln_src_tp_code IN VARCHAR2
--
-- OUT        :     x_return_status      OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      : only when p_validation_flag = 'Y'
FUNCTION Validate_ShipLnSrcTypeCode(
    p_ship_line_int_id    IN NUMBER,
    p_ship_ln_src_tp_code IN VARCHAR2,
    x_return_status       OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
    l_program_name          CONSTANT VARCHAR2(30) := 'Validate_ShipLnSrcTypeCode';
    l_debug_info         VARCHAR2(400) ;
    l_result             VARCHAR2(1) := L_FND_TRUE;
    l_return_status      VARCHAR2(1) := L_FND_TRUE;
    l_count_alw_src_type NUMBER;

BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name) ;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_ship_line_int_id',
        p_var_value      => p_ship_line_int_id);

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_ship_ln_src_tp_code',
        p_var_value      => p_ship_ln_src_tp_code);

    SELECT COUNT(1)
    INTO l_count_alw_src_type
    FROM fnd_lookups fl
    WHERE fl.lookup_type = 'INL_SHIP_LINE_SRC_TYPES'
    AND   fl.lookup_code = p_ship_ln_src_tp_code;

    IF NVL(l_count_alw_src_type, 0) = 0 THEN
        l_debug_info := 'Invalid Shipment Line Source Type Code';
        INL_LOGGING_PVT.Log_Statement(
          p_module_name      => g_module_name,
          p_procedure_name   => l_program_name,
          p_debug_info       => l_debug_info);
        l_result := L_FND_FALSE;
        -- Add a line into inl_ship_errors
        Handle_InterfError(
           p_parent_table_name  => 'INL_SHIP_LINES_INT',
           p_parent_table_id    => p_ship_line_int_id,
           p_column_name        => 'SHIP_LINE_SRC_TYPE_CODE',
           p_column_value       => p_ship_ln_src_tp_code,
           p_error_message_name => 'INL_ERR_CHK_SHIP_LN_SRC_TP',
           p_token1_name        => 'SHIPL_SRC_T',
           p_token1_value       => p_ship_ln_src_tp_code,
           p_token2_name        => 'SHIP_LINE_NUM',
           p_token2_value       => NULL,
           x_return_status      => l_return_status);
         -- If any errors happen abort API.
         IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
         END IF;
    END IF;

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);
    RETURN FND_API.to_boolean(l_result) ;
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE);
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name);
        END IF;
END Validate_ShipLnSrcTypeCode;

-- Utility name   : Validate_Currency
-- Type       : Private
-- Function   : Validate Currency if required
--              Validate against FND_CURRENCIES
--
-- Pre-reqs   : None
-- Parameters :
-- IN         :     p_ship_line_int_id    IN NUMBER
--                  p_currency_code       IN VARCHAR2
--                  p_curr_conv_date      IN DATE,
--                  p_curr_conv_type      IN VARCHAR2,
--                  p_org_id              IN NUMBER,
--
-- OUT        :     x_curr_conv_rate      IN OUT NOCOPY NUMBER,
--                  x_return_status      OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Validate_Currency(
    p_ship_line_int_id    IN NUMBER,
    p_validation_flag     IN VARCHAR2,
    p_currency_code       IN VARCHAR2,
    p_curr_conv_date      IN DATE,
    p_curr_conv_type      IN VARCHAR2,
    p_org_id              IN NUMBER,
    x_curr_conv_rate      IN OUT NOCOPY NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
    l_program_name             CONSTANT VARCHAR2(30) := 'Validate_Currency';
    l_debug_info            VARCHAR2(400) ;
    l_response              VARCHAR2(1) := L_FND_TRUE;
    l_return_status         VARCHAR2(1) := L_FND_TRUE;
    l_count_curr_code_valid NUMBER;
    l_func_currency_code    VARCHAR2(15) ;
    l_count_conv_tp_valid   NUMBER;
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name) ;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_ship_line_int_id',
        p_var_value      => p_ship_line_int_id);
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_validation_flag',
        p_var_value      => p_validation_flag);
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_currency_code',
        p_var_value      => p_currency_code);
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_curr_conv_date',
        p_var_value      => p_curr_conv_date);
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'x_curr_conv_rate',
        p_var_value      => x_curr_conv_rate);
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_curr_conv_type',
        p_var_value      => p_curr_conv_type);
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_org_id',
        p_var_value      => p_org_id);

    l_debug_info := 'Get functional currency code';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info);

    SELECT gl.currency_code
    INTO   l_func_currency_code
    FROM   gl_sets_of_books gl,
           financials_system_params_all fsp --Bug#10381495
    WHERE gl.set_of_books_id = fsp.set_of_books_id
    AND   org_id = p_org_id;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'l_func_currency_code',
        p_var_value      => l_func_currency_code);

    IF p_validation_flag = 'Y'
    THEN
        SELECT COUNT(1)
        INTO  l_count_curr_code_valid
        FROM  fnd_currencies fc
        WHERE fc.currency_code = p_currency_code;

        IF NVL(l_count_curr_code_valid, 0) = 0 THEN
            l_debug_info := 'Currency Code is invalid';
            INL_LOGGING_PVT.Log_Statement(
              p_module_name      => g_module_name,
              p_procedure_name   => l_program_name,
              p_debug_info       => l_debug_info);
            l_response := L_FND_FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
               p_parent_table_name  => 'INL_SHIP_LINES_INT',
               p_parent_table_id    => p_ship_line_int_id,
               p_column_name        => 'CURRENCY_CODE',
               p_column_value       => p_currency_code,
               p_error_message_name => 'INL_ERR_CURR_CODE_INV',
               x_return_status      => l_return_status);
             -- If any errors happen abort API.
             IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
             ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
             END IF;
        ELSE
            IF l_func_currency_code = p_currency_code THEN
                IF p_curr_conv_type IS NOT NULL
                THEN
                    l_debug_info := 'Currency Conversion type should be null';
                    INL_LOGGING_PVT.Log_Statement(
                      p_module_name      => g_module_name,
                      p_procedure_name   => l_program_name,
                      p_debug_info       => l_debug_info);
                    l_response := L_FND_FALSE;
                    -- Add a line into inl_ship_errors
                    Handle_InterfError(
                       p_parent_table_name  => 'INL_SHIP_LINES_INT',
                       p_parent_table_id    => p_ship_line_int_id,
                       p_column_name        => 'CURRENCY_CONVERSION_TYPE',
                       p_column_value       => p_curr_conv_type,
                       p_error_message_name => 'INL_ERR_CURR_CONV_TP_NNULL',
                       x_return_status      => l_return_status);
                    -- If any errors happen abort API.
                    IF l_return_status = L_FND_RET_STS_ERROR THEN
                        RAISE L_FND_EXC_ERROR;
                    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                        RAISE L_FND_EXC_UNEXPECTED_ERROR;
                    END IF;
                END IF;
                IF x_curr_conv_rate IS NOT NULL
                THEN
                    l_debug_info := 'Currency Conversion Rate should be null';
                    INL_LOGGING_PVT.Log_Statement(
                      p_module_name      => g_module_name,
                      p_procedure_name   => l_program_name,
                      p_debug_info       => l_debug_info);
                    l_response := L_FND_FALSE;
                    -- Add a line into inl_ship_errors
                    Handle_InterfError(
                       p_parent_table_name  => 'INL_SHIP_LINES_INT',
                       p_parent_table_id    => p_ship_line_int_id,
                       p_column_name        => 'CURRENCY_CONVERSION_RATE',
                       p_column_value       => x_curr_conv_rate,
                       p_error_message_name => 'INL_ERR_CURR_CONV_RT_NNULL',
                       x_return_status      => l_return_status);
                    -- If any errors happen abort API.
                    IF l_return_status = L_FND_RET_STS_ERROR THEN
                        RAISE L_FND_EXC_ERROR;
                    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                        RAISE L_FND_EXC_UNEXPECTED_ERROR;
                    END IF;
                END IF;
                IF p_curr_conv_date IS NOT NULL
                THEN
                    l_debug_info := 'Currency Conversion Date should be null';
                    INL_LOGGING_PVT.Log_Statement(
                      p_module_name      => g_module_name,
                      p_procedure_name   => l_program_name,
                      p_debug_info       => l_debug_info);
                    l_response := L_FND_FALSE;
                    -- Add a line into inl_ship_errors
                    Handle_InterfError(
                       p_parent_table_name  => 'INL_SHIP_LINES_INT',
                       p_parent_table_id    => p_ship_line_int_id,
                       p_column_name        => 'CURRENCY_CONVERSION_DATE',
                       p_column_value       => p_curr_conv_date,
                       p_error_message_name => 'INL_ERR_CURR_CONV_DT_NNULL',
                       x_return_status      => l_return_status);
                    -- If any errors happen abort API.
                    IF l_return_status = L_FND_RET_STS_ERROR THEN
                        RAISE L_FND_EXC_ERROR;
                    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                        RAISE L_FND_EXC_UNEXPECTED_ERROR;
                    END IF;
                END IF;
            ELSE --p_func_currency_code <> p_currency_code
                IF p_curr_conv_date IS NULL
                THEN
                    l_debug_info := 'Currency Conversion Date should not be null';
                    INL_LOGGING_PVT.Log_Statement(
                      p_module_name      => g_module_name,
                      p_procedure_name   => l_program_name,
                      p_debug_info       => l_debug_info);
                    l_response := L_FND_FALSE;
                    -- Add a line into inl_ship_errors
                    Handle_InterfError(
                       p_parent_table_name  => 'INL_SHIP_LINES_INT',
                       p_parent_table_id    => p_ship_line_int_id,
                       p_column_name        => 'CURRENCY_CONVERSION_DATE',
                       p_column_value       => p_curr_conv_date,
                       p_error_message_name => 'INL_ERR_CURR_CONV_DT_NULL',
                       x_return_status      => l_return_status);
                    -- If any errors happen abort API.
                    IF l_return_status = L_FND_RET_STS_ERROR THEN
                        RAISE L_FND_EXC_ERROR;
                    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                        RAISE L_FND_EXC_UNEXPECTED_ERROR;
                    END IF;
                END IF;
                IF x_curr_conv_rate IS NULL
                THEN
                    l_debug_info := 'Currency Conversion Rate should not be null';
                    INL_LOGGING_PVT.Log_Statement(
                      p_module_name      => g_module_name,
                      p_procedure_name   => l_program_name,
                      p_debug_info       => l_debug_info);
                    l_response := L_FND_FALSE;
                    -- Add a line into inl_ship_errors
                    Handle_InterfError(
                       p_parent_table_name  => 'INL_SHIP_LINES_INT',
                       p_parent_table_id    => p_ship_line_int_id,
                       p_column_name        => 'CURRENCY_CONVERSION_RATE',
                       p_column_value       => x_curr_conv_rate,
                       p_error_message_name => 'INL_ERR_CURR_CONV_RT_NULL',
                       x_return_status      => l_return_status);
                    -- If any errors happen abort API.
                    IF l_return_status = L_FND_RET_STS_ERROR THEN
                        RAISE L_FND_EXC_ERROR;
                    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                        RAISE L_FND_EXC_UNEXPECTED_ERROR;
                    END IF;
                END IF;
                IF p_curr_conv_type IS NULL
                THEN
                    l_debug_info := 'Currency Conversion Type should not be null';
                    INL_LOGGING_PVT.Log_Statement(
                      p_module_name      => g_module_name,
                      p_procedure_name   => l_program_name,
                      p_debug_info       => l_debug_info);
                    l_response := L_FND_FALSE;
                    -- Add a line into inl_ship_errors
                    Handle_InterfError(
                       p_parent_table_name  => 'INL_SHIP_LINES_INT',
                       p_parent_table_id    => p_ship_line_int_id,
                       p_column_name        => 'CURRENCY_CONVERSION_TYPE',
                       p_column_value       => p_curr_conv_type,
                       p_error_message_name => 'INL_ERR_CURR_CONV_TP_NULL',
                       x_return_status      => l_return_status);
                    -- If any errors happen abort API.
                    IF l_return_status = L_FND_RET_STS_ERROR THEN
                        RAISE L_FND_EXC_ERROR;
                    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                        RAISE L_FND_EXC_UNEXPECTED_ERROR;
                    END IF;
                ELSE
                    l_debug_info := 'Checking conversion type';
                    INL_LOGGING_PVT.Log_Statement(
                      p_module_name      => g_module_name,
                      p_procedure_name   => l_program_name,
                      p_debug_info       => l_debug_info);
                    SELECT COUNT(1)
                    INTO  l_count_conv_tp_valid
                    FROM  gl_daily_conversion_types dct
                    WHERE dct.conversion_type = p_curr_conv_type;

                    IF NVL(l_count_conv_tp_valid, 0) = 0 THEN
                       l_debug_info := 'Currency Conversion Type is invalid';
                       INL_LOGGING_PVT.Log_Statement(
                        p_module_name      => g_module_name,
                        p_procedure_name   => l_program_name,
                        p_debug_info       => l_debug_info);
                        l_response := L_FND_FALSE;
                        -- Add a line into inl_ship_errors
                        Handle_InterfError(
                            p_parent_table_name  => 'INL_SHIP_LINES_INT',
                            p_parent_table_id    => p_ship_line_int_id,
                            p_column_name        => 'CURRENCY_CONVERSION_TYPE',
                            p_column_value       => p_curr_conv_type,
                            p_error_message_name => 'INL_ERR_CURR_CONV_TP_INV',
                            x_return_status      => l_return_status);
                         -- If any errors happen abort API.
                         IF l_return_status = L_FND_RET_STS_ERROR THEN
                            RAISE L_FND_EXC_ERROR;
                        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                            RAISE L_FND_EXC_UNEXPECTED_ERROR;
                        END IF;
                    END IF;
                END IF;
            END IF;
        END IF;
    END IF;


    IF l_func_currency_code <> p_currency_code
        AND l_response = L_FND_TRUE
    THEN
        IF p_curr_conv_type <> 'User' THEN
        l_debug_info := 'Conversion Type <> User, derive rate from currency code, type and dated';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info );
            -- Derive rate from code, type and date
            BEGIN
                SELECT conversion_rate
                INTO x_curr_conv_rate
                FROM gl_daily_rates
                WHERE from_currency = p_currency_code
                AND to_currency = l_func_currency_code
                AND conversion_type = p_curr_conv_type
                AND TRUNC(conversion_date) = TRUNC(p_curr_conv_date);
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                l_debug_info := 'No rate has been defined for the selected rate type and rate date';
                INL_LOGGING_PVT.Log_Statement(
                  p_module_name      => g_module_name,
                  p_procedure_name   => l_program_name,
                  p_debug_info       => l_debug_info);
                l_response := L_FND_FALSE;
                -- Add a line into inl_ship_errors
                Handle_InterfError(
                   p_parent_table_name  => 'INL_SHIP_LINES_INT',
                   p_parent_table_id    => p_ship_line_int_id,
                   p_column_name        => 'CURRENCY_CONVERSION_RATE',
                   p_column_value       => x_curr_conv_rate,
                   p_error_message_name => 'INL_NO_RATE_DEFINED',
                   x_return_status      => l_return_status);
                 -- If any errors happen abort API.
                 IF l_return_status = L_FND_RET_STS_ERROR THEN
                    RAISE L_FND_EXC_ERROR;
                ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                    RAISE L_FND_EXC_UNEXPECTED_ERROR;
                 END IF;
            END;
        END IF;
    END IF;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);
    RETURN FND_API.to_boolean(l_response) ;
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE);
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name);
        END IF;
END Validate_Currency;

-- Utility name   : Validate_InvItemId
-- Type       : Private
-- Function   : Inventory Item validation.
--              Check if a given Location is valid
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_header_int_id IN NUMBER
--              p_ship_line_int_id   IN NUMBER
--              p_validation_flag    IN VARCHAR2
--              p_organization_id    IN NUMBER
--
-- OUT        : x_inv_item_id        IN OUT NOCOPY NUMBER
--              x_inv_item_name      IN OUT NOCOPY VARCHAR2
--              x_return_status      IN OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Validate_InvItemId(
    p_ship_line_int_id   IN NUMBER,
    p_validation_flag    IN VARCHAR2,
    p_organization_id    IN NUMBER,
    x_inv_item_name      IN OUT NOCOPY VARCHAR2,
    x_inv_item_id        IN OUT NOCOPY NUMBER,
    x_return_status      OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
    l_program_name      CONSTANT VARCHAR2(30) := 'Validate_InvItemId';
    l_debug_info     VARCHAR2(400) ;
    l_return_status  VARCHAR2(1) := L_FND_TRUE;
    l_column_name    VARCHAR2(30);
    l_column_value   VARCHAR2(30);

BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name) ;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'x_inv_item_id',
        p_var_value      => x_inv_item_id) ;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'x_inv_item_name',
        p_var_value      => x_inv_item_name);
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_ship_line_int_id',
        p_var_value      => p_ship_line_int_id);
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_organization_id',
        p_var_value      => p_organization_id);
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_validation_flag',
        p_var_value      => p_validation_flag);

    IF p_validation_flag = 'N'
        AND x_inv_item_id IS NOT NULL
    THEN
        l_debug_info := 'Validation is not required for Inventory Item';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);
        x_inv_item_name := NULL;
    ELSE
        l_debug_info := 'Checking Inventory Item';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);
        IF x_inv_item_name IS NOT NULL THEN
            l_column_name  := 'INVENTORY_ITEM_NAME';
            l_column_value := x_inv_item_name;
        ELSE
            l_column_name  := 'INVENTORY_ITEM_ID';
            l_column_value := x_inv_item_id;
        END IF;

        SELECT
            msi.inventory_item_id,
            msi.concatenated_segments
        INTO x_inv_item_id,
             x_inv_item_name
        FROM mtl_system_items_kfv msi
        WHERE msi.organization_id = p_organization_id
        AND (
            (x_inv_item_id IS NOT NULL
             AND msi.inventory_item_id = x_inv_item_id)
             OR msi.concatenated_segments = x_inv_item_name)
        ;
    END IF;

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);
    RETURN FND_API.to_boolean(L_FND_TRUE) ;
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE);
    WHEN OTHERS THEN
        -- Add a line into inl_ship_errors
        Handle_InterfError(
            p_parent_table_name  => 'INL_SHIP_LINES_INT',
            p_parent_table_id    => p_ship_line_int_id,
            p_column_name        => l_column_name,
            p_column_value       => l_column_value,
            p_error_message_name => 'INL_ERR_INV_ITEM_INV',
            x_return_status      => l_return_status);

        -- If any errors happen abort API.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
        RETURN FND_API.to_boolean(L_FND_FALSE);
END Validate_InvItemId;

-- Utility name   : Validate_TxnUomCode
-- Type       : Private
-- Function   : Transaction Uom Code validation if required.
--
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_line_int_id   IN NUMBER
--              p_txn_uom_code       IN VARCHAR2
--
-- OUT        : x_return_status      IN OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Validate_TxnUomCode(
    p_ship_line_int_id   IN NUMBER,
    p_txn_uom_code       IN VARCHAR2,
    x_return_status      OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
    l_program_name           CONSTANT VARCHAR2(30) := 'Validate_TxnUomCode';
    l_debug_info          VARCHAR2(400) ;
    l_result              VARCHAR2(1) := L_FND_TRUE;
    l_return_status       VARCHAR2(1) := L_FND_TRUE;
    l_count_txn_uom_valid NUMBER;

BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name) ;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;

    -- Check if the Location is null
    l_debug_info := 'Validate Txn Uom Code if required';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info);

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_txn_uom_code',
        p_var_value      => p_txn_uom_code) ;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_ship_line_int_id',
        p_var_value      => p_ship_line_int_id) ;

    SELECT COUNT(1)
    INTO  l_count_txn_uom_valid
    FROM  mtl_units_of_measure mum
    WHERE mum.uom_code = p_txn_uom_code;

    IF NVL(l_count_txn_uom_valid, 0) = 0 THEN
        l_debug_info := 'Transaction Uom Code is invalid';
        INL_LOGGING_PVT.Log_Statement(
          p_module_name      => g_module_name,
          p_procedure_name   => l_program_name,
          p_debug_info       => l_debug_info);
        l_result := L_FND_FALSE;
        -- Add a line into inl_ship_errors
        Handle_InterfError(
           p_parent_table_name  => 'INL_SHIP_LINES_INT',
           p_parent_table_id    => p_ship_line_int_id,
           p_column_name        => 'TXN_UOM_CODE',
           p_column_value       => p_txn_uom_code,
           p_error_message_name => 'INL_ERR_UOM_CODE_INV',
           x_return_status      => l_return_status);
         -- If any errors happen abort API.
         IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
         ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
         END IF;
    END IF;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);
    RETURN FND_API.to_boolean(l_result) ;
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name);
        END IF;
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
END Validate_TxnUomCode;

-- Utility name   : Validate_PriSecFields
-- Type       : Private
-- Function   : Derive Primary fields
--
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_header_int_id    IN NUMBER
--              p_ship_line_int_id      IN NUMBER
--              p_validation_flag       IN VARCHAR2
--              p_organization_id       IN NUMBER
--              p_inventory_item_id     IN NUMBER
--              p_txn_uom_code          IN VARCHAR2
--              p_txn_qty               IN NUMBER
--              p_txn_unit_price        IN NUMBER
--              p_ship_line_id          IN NUMBER
--              p_interface_source_code IN VARCHAR2
--              p_interface_source_line_id IN NUMBER
--
-- OUT        : x_1ary_uom_code      IN OUT NOCOPY VARCHAR2
--             x_1ary_qty           IN OUT NOCOPY NUMBER
--             x_1ary_unit_price    IN OUT NOCOPY NUMBER
--             x_2ary_uom_code      IN OUT NOCOPY VARCHAR2
--             x_2ary_qty           IN OUT NOCOPY NUMBER
--             x_2ary_unit_price    IN OUT NOCOPY NUMBER
--             x_return_status      OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Validate_PriSecFields(
    p_ship_line_int_id         IN NUMBER,
    p_validation_flag          IN VARCHAR2,
    p_organization_id          IN NUMBER,
    p_inventory_item_id        IN NUMBER,
    p_txn_uom_code             IN VARCHAR2,
    p_txn_qty                  IN NUMBER,
    p_txn_unit_price           IN NUMBER,
    p_ship_line_id             IN NUMBER,
    p_interface_source_code    IN VARCHAR2,
    p_interface_source_line_id IN NUMBER,    -- Bug 11710754
    x_1ary_uom_code            IN OUT NOCOPY VARCHAR2,
    x_1ary_qty                 IN OUT NOCOPY NUMBER,
    x_1ary_unit_price          IN OUT NOCOPY NUMBER,
    x_2ary_uom_code            IN OUT NOCOPY VARCHAR2,
    x_2ary_qty                 IN OUT NOCOPY NUMBER,
    x_2ary_unit_price          IN OUT NOCOPY NUMBER,
    x_return_status               OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
    l_program_name           CONSTANT VARCHAR2(30) := 'Validate_PriSecFields';
    l_debug_info          VARCHAR2(400) ;
    l_result              VARCHAR2(1) := L_FND_TRUE;
    l_return_status       VARCHAR2(1) := L_FND_TRUE;
    l_count_txn_uom_valid NUMBER;
    l_1ary_uom_code       VARCHAR2(3);
    l_1ary_qty            NUMBER;
    l_2ary_uom_code       VARCHAR2(3);
    l_2ary_qty            NUMBER;
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(2000) ;
    l_count_2ary_uom_vld  VARCHAR2(3);
    l_inventory_item_id   NUMBER       := p_inventory_item_id;
    l_txn_uom_code        VARCHAR2(30) := p_txn_uom_code;
    l_txn_qty             NUMBER       := p_txn_qty;
    l_txn_unit_price      NUMBER       := p_txn_unit_price;
    l_rcv_uom_code        VARCHAR2(3);   -- Bug 11710754
    l_po_uom_code         VARCHAR2(25);  -- Bug 11710754
    l_po_unit_price       NUMBER;        -- Bug 11710754
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name) ;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;

    l_debug_info := 'Derive Primary and secondary fields if required';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info);

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_ship_line_int_id',
        p_var_value      => p_ship_line_int_id) ;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_validation_flag',
        p_var_value      => p_validation_flag) ;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_organization_id',
        p_var_value      => p_organization_id) ;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_inventory_item_id',
        p_var_value      => p_inventory_item_id) ;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_txn_uom_code',
        p_var_value      => p_txn_uom_code) ;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_txn_qty',
        p_var_value      => p_txn_qty) ;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_txn_unit_price',
        p_var_value      => p_txn_unit_price) ;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_ship_line_id',
        p_var_value      => p_ship_line_id) ;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_interface_source_code',
        p_var_value      => p_interface_source_code) ;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_interface_source_line_id',
        p_var_value      => p_interface_source_line_id) ;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'x_1ary_uom_code',
        p_var_value      => x_1ary_uom_code) ;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'x_1ary_qty',
        p_var_value      => x_1ary_qty) ;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'x_1ary_unit_price',
        p_var_value      => x_1ary_unit_price) ;

    IF (p_ship_line_id IS NOT NULL)
        AND
       (p_inventory_item_id IS NULL
        OR l_txn_uom_code IS NULL
        OR l_txn_qty IS NULL
        OR l_txn_unit_price IS NULL)
    THEN
        l_debug_info := 'Inventory Item IS NULL, getting from ship line';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);

        SELECT NVL(l_inventory_item_id, sl.inventory_item_id),
               NVL(l_txn_uom_code, sl.txn_uom_code),
               NVL(l_txn_qty, sl.txn_qty),
               NVL(l_txn_unit_price, sl.txn_unit_price)
        INTO l_inventory_item_id,
             l_txn_uom_code,
             l_txn_qty,
             l_txn_unit_price
        FROM  inl_ship_lines_all sl  --Bug#10381495
        WHERE sl.ship_line_id = p_ship_line_id;
    END IF;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'l_inventory_item_id',
        p_var_value      => l_inventory_item_id) ;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'l_txn_uom_code',
        p_var_value      => l_txn_uom_code) ;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'l_txn_qty',
        p_var_value      => l_txn_qty) ;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'l_txn_unit_price',
        p_var_value      => l_txn_unit_price) ;

    IF l_inventory_item_id IS NOT NULL
       AND p_organization_id IS NOT NULL
       AND l_txn_uom_code IS NOT NULL THEN
        l_debug_info := 'Derive Primary and Secondary Fields';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);

        INL_SHIPMENT_PVT.Get_1ary2aryQty(
            p_api_version       => 1.0,
            p_init_msg_list     => L_FND_FALSE,
            p_commit            => L_FND_FALSE,
            p_inventory_item_id => l_inventory_item_id,
            p_organization_id   => p_organization_id,
            p_uom_code          => l_txn_uom_code,
            p_qty               => NVL(l_txn_qty,0),
            x_1ary_uom_code     => l_1ary_uom_code,
            x_1ary_qty          => l_1ary_qty,
            x_2ary_uom_code     => l_2ary_uom_code,
            x_2ary_qty          => l_2ary_qty,
            x_return_status     => l_return_status,
            x_msg_count         => l_msg_count,
            x_msg_data          => l_msg_data
        ) ;

        IF l_return_status <> 'S' THEN
            l_debug_info := 'Error when converting txn uom code: ' || l_txn_uom_code;
            INL_LOGGING_PVT.Log_Statement(
                p_module_name      => g_module_name,
                p_procedure_name   => l_program_name,
                p_debug_info       => l_debug_info);

            INL_LOGGING_PVT.Log_Variable(
                p_module_name    => g_module_name,
                p_procedure_name => l_program_name,
                p_var_name       => 'l_return_status',
                p_var_value      => l_return_status) ;

            l_result := L_FND_FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
               p_parent_table_name  => 'INL_SHIP_LINES_INT',
               p_parent_table_id    => p_ship_line_int_id,
               p_column_name        => 'TXN_UOM_CODE',
               p_column_value       => l_txn_uom_code,
               p_error_message_name => 'INL_ERR_DERIVE_PRI_SEC_FLDS',
               p_token1_name        => 'TXN_UOM_CODE',
               p_token1_value       => l_txn_uom_code,
               x_return_status      => l_return_status);
             -- If any errors happen abort API.
             IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
             END IF;
            RAISE L_FND_EXC_ERROR;
        END IF;

        -- If any errors happen abort the process.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            l_debug_info := 'Error when deriving primary and secondary fields for txn uom code: ' || l_txn_uom_code;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;

        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'l_1ary_uom_code',
            p_var_value      => l_1ary_uom_code) ;

        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'l_1ary_qty',
            p_var_value      => l_1ary_qty) ;

        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'l_2ary_uom_code',
            p_var_value      => l_2ary_uom_code) ;

        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'l_2ary_qty',
            p_var_value      => l_2ary_qty) ;

        IF l_1ary_uom_code IS NOT NULL THEN
            x_1ary_qty      := l_1ary_qty;
            x_1ary_uom_code := l_1ary_uom_code;

            -- Bug 11710754
            -- x_1ary_unit_price := (l_txn_qty * l_txn_unit_price) / x_1ary_qty;
            IF p_interface_source_code = 'RCV' THEN
                l_debug_info := 'source table is RCV_TRANSACTIONS_INTERFACE';
                INL_LOGGING_PVT.Log_Statement(
                    p_module_name      => g_module_name,
                    p_procedure_name   => l_program_name,
                    p_debug_info       => l_debug_info);

                SELECT rti.uom_code, muom.uom_code, pl.unit_price
                INTO l_rcv_uom_code, l_po_uom_code, l_po_unit_price
                FROM rcv_transactions_interface rti,
                    po_lines_all pl,
                    mtl_units_of_measure muom
                WHERE  muom.unit_of_measure = pl.unit_meas_lookup_code
                AND pl.po_line_id = rti.po_line_id
                AND interface_transaction_id = p_interface_source_line_id;

                INL_LOGGING_PVT.Log_Variable(
                    p_module_name    => g_module_name,
                    p_procedure_name => l_program_name,
                    p_var_name       => 'l_rcv_uom_code',
                    p_var_value      => l_rcv_uom_code);

                INL_LOGGING_PVT.Log_Variable(
                    p_module_name    => g_module_name,
                    p_procedure_name => l_program_name,
                    p_var_name       => 'l_po_uom_code',
                    p_var_value      => l_po_uom_code);

                INL_LOGGING_PVT.Log_Variable(
                    p_module_name    => g_module_name,
                    p_procedure_name => l_program_name,
                    p_var_name       => 'l_po_unit_price',
                    p_var_value      => l_po_unit_price);

                IF l_1ary_uom_code = l_rcv_uom_code THEN
                    l_debug_info := 'Item primary uom is equal RCV uom code';
                    x_1ary_unit_price := p_txn_unit_price;
                ELSIF l_1ary_uom_code = l_po_uom_code THEN
                    l_debug_info := 'Item primary uom is equal PO uom code';
                    x_1ary_unit_price := l_po_unit_price;
                ELSE
                    l_debug_info := 'PO primary uom should be converted to : ' || l_1ary_uom_code;

                    x_1ary_unit_price := INL_LANDEDCOST_PVT.Converted_Price(
                                       p_unit_price        => l_po_unit_price,
                                       p_organization_id   => p_organization_id,
                                       p_inventory_item_id => l_inventory_item_id, --Bug#11794483C
                                       p_from_uom_code     => l_po_uom_code,
                                       p_to_uom_code       => l_1ary_uom_code);
                END IF;

                INL_LOGGING_PVT.Log_Statement(
                    p_module_name      => g_module_name,
                    p_procedure_name   => l_program_name,
                    p_debug_info       => l_debug_info);

           ELSE
                l_debug_info := 'Source is different from RCV_TRANSACTIONS_INTERFACE';
                INL_LOGGING_PVT.Log_Statement(
                    p_module_name      => g_module_name,
                    p_procedure_name   => l_program_name,
                    p_debug_info       => l_debug_info);

                IF l_1ary_uom_code = l_txn_uom_code
                THEN
                    x_1ary_unit_price := l_txn_unit_price;
                ELSE
                    x_1ary_unit_price :=
                            INL_LANDEDCOST_PVT.Converted_Price(
                                    p_unit_price        => l_txn_unit_price,
                                    p_organization_id   => p_organization_id,
                                    p_inventory_item_id => l_inventory_item_id, --Bug#11794483C
                                    p_from_uom_code     => l_txn_uom_code,
                                    p_to_uom_code       => l_1ary_uom_code);
               END IF;
           END IF;
           -- /Bug 11710754

            INL_LOGGING_PVT.Log_Variable(
                p_module_name    => g_module_name,
                p_procedure_name => l_program_name,
                p_var_name       => 'x_1ary_unit_price',
                p_var_value      => x_1ary_unit_price);
        END IF;

        -- Bug #8932386
        IF  x_2ary_uom_code IS NULL
        AND x_2ary_qty IS NULL
        AND x_2ary_unit_price IS NULL
        THEN
            l_debug_info := 'Secondary fields are null, then derivating them';
            INL_LOGGING_PVT.Log_Statement(
                p_module_name      => g_module_name,
                p_procedure_name   => l_program_name,
                p_debug_info       => l_debug_info);

            INL_LOGGING_PVT.Log_Variable(
                p_module_name    => g_module_name,
                p_procedure_name => l_program_name,
                p_var_name       => 'l_2ary_uom_code',
                p_var_value      => l_2ary_uom_code);

            INL_LOGGING_PVT.Log_Variable(
                p_module_name    => g_module_name,
                p_procedure_name => l_program_name,
                p_var_name       => 'l_2ary_qty',
                p_var_value      => l_2ary_qty) ;

            IF l_2ary_uom_code IS NOT NULL AND p_interface_source_code <> 'RCV' THEN

                l_debug_info := 'Derive secondary fields for interface source code <> RCV';
                INL_LOGGING_PVT.Log_Statement(
                    p_module_name      => g_module_name,
                    p_procedure_name   => l_program_name,
                    p_debug_info       => l_debug_info);

                x_2ary_qty := l_2ary_qty;
                x_2ary_uom_code := l_2ary_uom_code;
                x_2ary_unit_price := (l_txn_qty * l_txn_unit_price) / x_2ary_qty;

                INL_LOGGING_PVT.Log_Variable(
                    p_module_name    => g_module_name,
                    p_procedure_name => l_program_name,
                    p_var_name       => 'x_2ary_unit_price',
                    p_var_value      => x_2ary_unit_price);
            END IF;
        ELSE
            IF p_validation_flag = 'Y' THEN
                IF x_2ary_uom_code IS NULL OR x_2ary_qty IS NULL OR
                    x_2ary_unit_price IS NULL THEN
                    l_debug_info := 'If one of Secondary fields is populated, then all of them should be also populated';
                    INL_LOGGING_PVT.Log_Statement(
                        p_module_name      => g_module_name,
                        p_procedure_name   => l_program_name,
                        p_debug_info       => l_debug_info);
                    l_result := L_FND_FALSE;
                    -- Add a line into inl_ship_errors
                    Handle_InterfError(
                        p_parent_table_name  => 'INL_SHIP_LINES_INT',
                        p_parent_table_id    => p_ship_line_int_id,
                        p_column_name        => 'SECONDARY_UOM_CODE',
                        p_column_value       => x_2ary_uom_code,
                        p_error_message_name => 'INL_ERR_SEC_FLDS_NULL',
                        x_return_status      => l_return_status);
                    -- If any errors happen abort API.
                    IF l_return_status = L_FND_RET_STS_ERROR THEN
                        RAISE L_FND_EXC_ERROR;
                    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                        RAISE L_FND_EXC_UNEXPECTED_ERROR;
                    END IF;
                ELSIF x_2ary_uom_code IS NOT NULL AND x_2ary_qty IS NOT NULL AND
                      x_2ary_unit_price IS NOT NULL THEN
                    l_debug_info := 'Secondary Uom Code has been populated. Validating it';
                    INL_LOGGING_PVT.Log_Statement(
                        p_module_name      => g_module_name,
                        p_procedure_name   => l_program_name,
                        p_debug_info       => l_debug_info);

                    SELECT COUNT(1)
                    INTO  l_count_2ary_uom_vld
                    FROM  mtl_units_of_measure mum
                    WHERE mum.uom_code = x_2ary_uom_code;

                    IF NVL(l_count_2ary_uom_vld,0) = 0 THEN
                        l_debug_info := 'Secondary Uom Code populated is invalid';
                        INL_LOGGING_PVT.Log_Statement(
                            p_module_name      => g_module_name,
                            p_procedure_name   => l_program_name,
                            p_debug_info       => l_debug_info);
                            l_result := L_FND_FALSE;
                        -- Add a line into inl_ship_errors
                        Handle_InterfError(
                            p_parent_table_name  => 'INL_SHIP_LINES_INT',
                            p_parent_table_id    => p_ship_line_int_id,
                            p_column_name        => 'SECONDARY_UOM_CODE',
                            p_column_value       => x_2ary_uom_code,
                            p_error_message_name => 'INL_ERR_SEC_UOM_CODE_INV',
                            x_return_status      => l_return_status);
                        -- If any errors happen abort API.
                        IF l_return_status = L_FND_RET_STS_ERROR THEN
                            RAISE L_FND_EXC_ERROR;
                        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                            RAISE L_FND_EXC_UNEXPECTED_ERROR;
                        END IF;
                    END IF;
                END IF;
            END IF;
        END IF;
        -- /Bug #8932386
    END IF;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);
    RETURN FND_API.to_boolean(l_result) ;
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        x_return_status := L_FND_RET_STS_ERROR;
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN OTHERS THEN
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name);
        END IF;
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
END Validate_PriSecFields;

-- Utility name   : Validate_LandedCostFlag
-- Type       : Private
-- Function   : Validaye Landed Cost Flag if required
--
-- Pre-reqs   : None
-- Parameters :
-- IN         :     p_ship_line_int_id      IN NUMBER
--                  p_landed_cost_flag      IN VARCHAR2
--
-- OUT        : x_return_status      OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Validate_LandedCostFlag(
    p_ship_line_int_id      IN NUMBER,
    p_landed_cost_flag      IN VARCHAR2,
    x_return_status         OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
    l_program_name     CONSTANT VARCHAR2(30) := 'Validate_LandedCostFlag';
    l_debug_info    VARCHAR2(400) ;
    l_result        VARCHAR2(1) := L_FND_TRUE;
    l_return_status VARCHAR2(1) := L_FND_TRUE;

BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name) ;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;

    l_debug_info := 'Validate Landed Cost Flag';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info);

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_landed_cost_flag',
        p_var_value      => p_landed_cost_flag);

    l_debug_info := 'Validate Landed Cost Flag if required';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info) ;

    IF p_landed_cost_flag NOT IN ('Y', 'N') THEN
        l_debug_info := 'Landed Cost Flag should be Y or N';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);
        l_result := L_FND_FALSE;

        -- Add a line into inl_ship_errors
        Handle_InterfError(
            p_parent_table_name  => 'INL_SHIP_LINES_INT',
            p_parent_table_id    => p_ship_line_int_id,
            p_column_name        => 'LANDED_COST_FLAG',
            p_column_value       => p_landed_cost_flag,
            p_error_message_name => 'INL_ERR_LC_FLAG_INV',
            x_return_status      => l_return_status);
        -- If any errors happen abort API.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
           RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);
    RETURN FND_API.to_boolean(l_result) ;
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name);
        END IF;
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
END Validate_LandedCostFlag;

-- Utility name   : Validate_AllocEnabledFlag
-- Type       : Private
-- Function   : Validate Allocation Enabled Flag if required
--
-- Pre-reqs   : None
-- Parameters :
-- IN         :     p_ship_line_int_id      IN NUMBER
--                  p_alloc_enabled_flag    IN VARCHAR2
--
-- OUT        : x_return_status      OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Validate_AllocEnabledFlag(
    p_ship_line_int_id      IN NUMBER,
    p_alloc_enabled_flag    IN VARCHAR2,
    x_return_status         OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
    l_program_name     CONSTANT VARCHAR2(30) := 'Validate_AllocEnabledFlag';
    l_debug_info    VARCHAR2(400) ;
    l_result        VARCHAR2(1) := L_FND_TRUE;
    l_return_status VARCHAR2(1) := L_FND_TRUE;

BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name) ;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;

    l_debug_info := 'Validate Allocation Enabled Flag if required';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info) ;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_alloc_enabled_flag',
        p_var_value      => p_alloc_enabled_flag);

    IF p_alloc_enabled_flag NOT IN ('Y', 'N') THEN
        l_debug_info := 'Allocation Enabled Flag should be Y or N';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);
        l_result := L_FND_FALSE;

        -- Add a line into inl_ship_errors
        Handle_InterfError(
            p_parent_table_name  => 'INL_SHIP_LINES_INT',
            p_parent_table_id    => p_ship_line_int_id,
            p_column_name        => 'ALLOCATION_ENABLED_FLAG',
            p_column_value       => p_alloc_enabled_flag,
            p_error_message_name => 'INL_ERR_ALLOC_ENABLED_INV',
            p_token1_name        => 'ID_NAME',
            p_token1_value       => 'INL_SHIP_LINES_INT',
            p_token2_name        => 'ID_VAL',
            p_token2_value       => p_ship_line_int_id,
            x_return_status      => l_return_status);
        -- If any errors happen abort API.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
           RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);
    RETURN FND_API.to_boolean(l_result) ;
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name);
        END IF;
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
END Validate_AllocEnabledFlag;

-- Utility name   : Validate_Organization
-- Type       : Private
-- Function   : Inventory Organization derivation
--              Valid if required
--              Get the org_id
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_header_int_id IN NUMBER
--              p_validation_flag    IN VARCHAR2
--              p_ship_header_id             IN NUMBER,

--
-- OUT        : x_organization_id            IN OUT NOCOPY NUMBER
--              x_organization_code          IN OUT NOCOPY VARCHAR2
--              x_org_id                     IN OUT NOCOPY NUMBER
--              x_user_defined_ship_num_code IN OUT NOCOPY VARCHAR2,
--              x_manual_ship_num_type       IN OUT NOCOPY VARCHAR2,
--              x_LCM_FLOW                   IN OUT NOCOPY VARCHAR2,
--              x_return_status              IN OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Validate_Organization(
    p_ship_header_int_id         IN NUMBER,
    p_validation_flag            IN VARCHAR2,
    p_ship_header_id             IN NUMBER,
    x_organization_id            IN OUT NOCOPY NUMBER,
    x_organization_code          IN OUT NOCOPY VARCHAR2,
    x_org_id                     IN OUT NOCOPY NUMBER,
    x_user_defined_ship_num_code IN OUT NOCOPY VARCHAR2,
    x_manual_ship_num_type       IN OUT NOCOPY VARCHAR2,
    x_LCM_FLOW                   IN OUT NOCOPY VARCHAR2,
    x_legal_entity_id            IN OUT NOCOPY NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS

    l_program_name              CONSTANT VARCHAR2(30) := 'Validate_Organization';
    l_debug_info             VARCHAR2(400) ;
    l_result                 VARCHAR2(1) := L_FND_TRUE;
    l_return_status          VARCHAR2(1) := L_FND_TRUE;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000) ;
    l_column_name            VARCHAR2(50);
    l_column_value           VARCHAR2(30);
    l_count_org_def_lcm      NUMBER;

--    l_user_def_ship_num_code VARCHAR2(25); -- Bug #9198199
--    l_count_lcm_as_service   NUMBER; -- Bug #9198199

BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name) ;

    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;

    l_debug_info := 'Derive organization fields and validate them if required';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info) ;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_ship_header_int_id',
        p_var_value      => p_ship_header_int_id) ;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_validation_flag',
        p_var_value      => p_validation_flag) ;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'x_organization_code',
        p_var_value      => x_organization_code) ;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'x_org_id',
        p_var_value      => x_org_id) ;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_ship_header_id',
        p_var_value      => p_ship_header_id) ;

--=================================================================================
-- The inl_parameters table should always be checked
-- if a organization does not have this setup
-- the record should be rejected otherwise we'll get a exception in import process
-- BUG#8971635
-- Begin
--=================================================================================
/* -- BUG#8971635
    IF p_validation_flag = 'N' THEN
        l_debug_info := 'Validation is not required for Organization';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);
        IF x_organization_id IS NOT NULL THEN
            x_organization_code := NULL;
            SELECT ood.operating_unit
            INTO x_org_id
            FROM org_organization_definitions ood
            WHERE ood.organization_id = x_organization_id;
        ELSIF x_organization_code IS NOT NULL THEN
            l_column_name := 'ORGANIZATION_CODE';
            l_column_value := x_organization_code;

            l_debug_info := 'Derive organization id from organization code';
            INL_LOGGING_PVT.Log_Statement(
                p_module_name      => g_module_name,
                p_procedure_name   => l_program_name,
                p_debug_info       => l_debug_info);

             SELECT ood.organization_id, ood.operating_unit
             INTO x_organization_id, x_org_id
             FROM org_organization_definitions ood
             WHERE ood.organization_code = x_organization_code;
        END IF;
    ELSIF p_validation_flag = 'Y' THEN
*/ -- BUG#8971635
--=================================================================================
-- The inl_parameters table should always be checked
-- if a organization does not have this setup
-- the record should be rejected otherwise we'll get a exception in import process
-- BUG#8971635
-- End
--=================================================================================

    IF p_ship_header_id IS NOT NULL THEN
        l_column_name := 'ship_header_id';
        l_column_value := p_ship_header_id;

        SELECT organization_id
        INTO x_organization_id
        FROM inl_ship_headers_all
        WHERE ship_header_id = p_ship_header_id;

    END IF;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'x_organization_id',
        p_var_value      => x_organization_id) ;
    l_column_name := 'ORGANIZATION_ID';
    l_column_value := x_organization_id;
    l_debug_info := 'Derive organization information.';
    INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);

    SELECT
        ood.legal_entity,
        ood.organization_id,
        ood.organization_code,
        ood.operating_unit,
        DECODE(NVL(rp.pre_receive, 'N'),'N','AAS','PR'),
        ipa.user_defined_ship_num_code,
        ipa.manual_ship_num_type,
        DECODE(ipa.organization_id, NULL, 0 , 1)
    INTO
        x_legal_entity_id,
        x_organization_id,
        x_organization_code,
        x_org_id,
        x_LCM_FLOW,
        x_user_defined_ship_num_code,
        x_manual_ship_num_type,
        l_count_org_def_lcm
    FROM org_organization_definitions ood,
         inl_parameters ipa,
         rcv_parameters rp
    WHERE
        ipa.organization_id (+) = ood.organization_id
    AND rp.organization_id (+)  = ood.organization_id
    AND ((x_organization_id IS NOT NULL
          AND ood.organization_id = x_organization_id)
         OR
          ood.organization_code = x_organization_code)
    ;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'x_legal_entity_id',
        p_var_value      => x_legal_entity_id) ;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'x_organization_id',
        p_var_value      => x_organization_id) ;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'x_organization_code',
        p_var_value      => x_organization_code) ;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'x_org_id',
        p_var_value      => x_org_id) ;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'x_LCM_FLOW',
        p_var_value      => x_LCM_FLOW) ;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'x_user_defined_ship_num_code',
        p_var_value      => x_user_defined_ship_num_code) ;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'x_manual_ship_num_type',
        p_var_value      => x_manual_ship_num_type) ;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'l_count_org_def_lcm',
        p_var_value      => l_count_org_def_lcm) ;

    -- Validating Organization
    IF NVL(l_count_org_def_lcm,0) = 0 THEN
        l_debug_info := 'The organization has no LCM Options defined';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);

        l_result := L_FND_FALSE;
        -- Add a line into inl_ship_errors
        Handle_InterfError(
            p_parent_table_name  => 'INL_SHIP_HEADERS_INT',
            p_parent_table_id    => p_ship_header_int_id,
            p_column_name        => 'ORGANIZATION_ID',
            p_column_value       => x_organization_id,
            p_error_message_name => 'INL_ERR_NO_LCM_OPT_DEF_ORG',
            p_token1_name        => 'INV_ORG_NAME',
            p_token1_value       => x_organization_id,
            x_return_status      => l_return_status) ;

        -- If any errors happen abort API.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
--        END IF; -- BUG#8971635

        IF x_org_id IS NULL THEN
            l_debug_info := 'Operating Unit is not defined for the Organization';
            INL_LOGGING_PVT.Log_Statement(
               p_module_name      => g_module_name,
               p_procedure_name   => l_program_name,
               p_debug_info       => l_debug_info);

            l_result := L_FND_FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                    p_parent_table_name  => 'INL_SHIP_HEADERS_INT',
                    p_parent_table_id    => p_ship_header_int_id,
                    p_column_name        => 'ORGANIZATION_ID',
                    p_column_value       => x_organization_id,
                    p_error_message_name => 'INL_ERR_NO_OP_UNIT_DEF',
                    x_return_status      => l_return_status) ;

            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
    END IF;

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);

    RETURN FND_API.to_boolean(l_result) ;
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN OTHERS THEN
        -- Add a line into inl_ship_errors
        Handle_InterfError(
            p_parent_table_name  => 'INL_SHIP_HEADERS_INT',
            p_parent_table_id    => p_ship_header_int_id,
            p_column_name        => l_column_name,
            p_column_value       => l_column_value,
            p_error_message_name => 'INL_ERR_INVL_INV_ORG',
            x_return_status      => l_return_status);
        -- If any errors happen abort API.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
END Validate_Organization;

-- Utility name   : Validate_Location
-- Type       : Private
-- Function   : Location validation.
--              Check if a given Location is valid
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_header_int_id IN NUMBER
--              p_validation_flag    IN VARCHAR2
--              p_organization_id    IN NUMBER
--
-- OUT        : x_location_id        IN OUT NOCOPY NUMBER
--              x_location_code      IN OUT NOCOPY VARCHAR2
--              x_dflt_country       IN OUT NOCOPY VARCHAR2
--              x_return_status      OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Validate_Location(
    p_ship_header_int_id IN NUMBER,
    p_validation_flag    IN VARCHAR2,
    p_organization_id    IN NUMBER,
    x_location_id        IN OUT NOCOPY NUMBER,
    x_location_code      IN OUT NOCOPY VARCHAR2,
    x_dflt_country       IN OUT NOCOPY VARCHAR2,
    x_return_status      OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
    l_program_name      CONSTANT VARCHAR2(30) := 'Validate_Location';
    l_debug_info     VARCHAR2(400) ;
    l_result         VARCHAR2(1) := L_FND_TRUE;
    l_return_status  VARCHAR2(1) := L_FND_TRUE;
    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(2000) ;
    l_location_count NUMBER;
    l_column_name    VARCHAR2(30);
    l_column_value   VARCHAR2(30);
    l_count_loc_org  NUMBER;

BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name) ;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;

    -- Check if the Location is null
    l_debug_info := 'Derive location and validate if required';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info);

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_organization_id',
        p_var_value      => p_organization_id) ;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'x_location_id',
        p_var_value      => x_location_id) ;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'x_location_code',
        p_var_value      => x_location_code) ;

    IF x_location_id IS NULL AND x_location_code IS NULL THEN
        l_debug_info := 'Location Id and Location Code are null, derivating from organization';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);

        SELECT
            hou.location_id,
            hl.location_code,
            hl.country
        INTO
            x_location_id,
            x_location_code,
            x_dflt_country
        FROM
            hr_organization_units hou,
            hr_locations_all hl --Bug#11794483B
        WHERE hl.location_id    = hou.location_id
        AND hou.organization_id = p_organization_id;
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => '(a)x_location_id',
            p_var_value      => x_location_id) ;
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => '(a)x_location_code',
            p_var_value      => x_location_code) ;
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => '(a)x_dflt_country',
            p_var_value      => x_dflt_country) ;
    ELSE
        IF p_validation_flag = 'N' THEN
            l_debug_info := 'Validation is not required for Location';
            INL_LOGGING_PVT.Log_Statement(
                p_module_name      => g_module_name,
                p_procedure_name   => l_program_name,
                p_debug_info       => l_debug_info);
            IF x_location_id IS NOT NULL THEN
                x_location_code := NULL;
            ELSIF x_location_code IS NOT NULL THEN
                l_column_name  := 'LOCATION_CODE';
                l_column_value := x_location_code;

                SELECT
                    hl.location_id,
                    hl.country
                INTO
                    x_location_id,
                    x_dflt_country
                FROM
                    hr_locations_all hl --Bug#11794483B
                WHERE
                    hl.location_code = x_location_code;
            END IF;
            INL_LOGGING_PVT.Log_Variable(
                p_module_name    => g_module_name,
                p_procedure_name => l_program_name,
                p_var_name       => '(b)x_location_id',
                p_var_value      => x_location_id) ;
            INL_LOGGING_PVT.Log_Variable(
                p_module_name    => g_module_name,
                p_procedure_name => l_program_name,
                p_var_name       => '(b)x_dflt_country',
                p_var_value      => x_dflt_country) ;
        ELSE
            l_debug_info := 'Validation is required for Location';
            INL_LOGGING_PVT.Log_Statement(
                p_module_name      => g_module_name,
                p_procedure_name   => l_program_name,
                p_debug_info       => l_debug_info);

            SELECT
                hl.location_code,
                hl.location_id,
                hl.country,
                (SELECT COUNT(1)
                 FROM hr_locations_all hl1 --Bug#11794483B
                 WHERE hl1.location_id = hl.location_id
                 AND   hl1.inventory_organization_id = p_organization_id)
            INTO
                x_location_code,
                x_location_id,
                x_dflt_country,
                l_count_loc_org
            FROM
                hr_locations_all hl --Bug#11794483B
            WHERE
                (x_location_id IS NOT NULL
                 AND hl.location_id = x_location_id)
                OR hl.location_code = x_location_code
            ;
            INL_LOGGING_PVT.Log_Variable(
                p_module_name    => g_module_name,
                p_procedure_name => l_program_name,
                p_var_name       => '(c)x_location_id',
                p_var_value      => x_location_id) ;
            INL_LOGGING_PVT.Log_Variable(
                p_module_name    => g_module_name,
                p_procedure_name => l_program_name,
                p_var_name       => '(c)x_location_code',
                p_var_value      => x_location_code) ;
            INL_LOGGING_PVT.Log_Variable(
                p_module_name    => g_module_name,
                p_procedure_name => l_program_name,
                p_var_name       => '(c)x_dflt_country',
                p_var_value      => x_dflt_country) ;
            INL_LOGGING_PVT.Log_Variable(
                p_module_name    => g_module_name,
                p_procedure_name => l_program_name,
                p_var_name       => '(c)l_count_loc_org',
                p_var_value      => l_count_loc_org) ;

            IF NVL(l_count_loc_org,0) = 0 THEN
                l_debug_info := 'The Location is not compliant with the Inventory Organization';
                INL_LOGGING_PVT.Log_Statement(
                    p_module_name      => g_module_name,
                    p_procedure_name   => l_program_name,
                    p_debug_info       => l_debug_info) ;

                l_result := L_FND_FALSE;

                -- Add a line into inl_ship_errors
                Handle_InterfError(
                    p_parent_table_name  => 'INL_SHIP_HEADERS_INT',
                    p_parent_table_id    => p_ship_header_int_id,
                    p_column_name        => 'LOCATION_ID',
                    p_column_value       => x_location_id,
                    p_error_message_name => 'INL_ERR_NO_LOCATION_INV_ORG',
                    x_return_status      => l_return_status);
                -- If any errors happen abort API.
                IF l_return_status = L_FND_RET_STS_ERROR THEN
                    RAISE L_FND_EXC_ERROR;
                ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                   RAISE L_FND_EXC_UNEXPECTED_ERROR;
                END IF;
            END IF;

            IF x_dflt_country IS NULL THEN
                l_debug_info := 'Country is required to assign a valid Location for the Shipment';
                INL_LOGGING_PVT.Log_Statement(
                    p_module_name      => g_module_name,
                    p_procedure_name   => l_program_name,
                    p_debug_info       => l_debug_info);
                l_result := L_FND_FALSE;

                -- Add a line into inl_ship_errors
                Handle_InterfError(
                    p_parent_table_name  => 'INL_SHIP_HEADERS_INT',
                    p_parent_table_id    => p_ship_header_int_id,
                    p_column_name        => 'LOCATION_ID',
                    p_column_value       => x_location_id,
                    p_error_message_name => 'INL_ERR_COUNTRY_LOCATION',
                    x_return_status      => l_return_status);
                -- If any errors happen abort API.
                IF l_return_status = L_FND_RET_STS_ERROR THEN
                    RAISE L_FND_EXC_ERROR;
                ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                   RAISE L_FND_EXC_UNEXPECTED_ERROR;
                END IF;
            END IF;
        END IF;
    END IF;

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);

    RETURN FND_API.to_boolean(l_result) ;
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN OTHERS THEN
        -- Add a line into inl_ship_errors
        Handle_InterfError(
            p_parent_table_name  => 'INL_SHIP_HEADERS_INT',
            p_parent_table_id    => p_ship_header_int_id,
            p_column_name        => l_column_name,
            p_column_value       => l_column_value,
            p_error_message_name => 'INL_ERR_LOCATION_INV',
            x_return_status      => l_return_status);

        -- If any errors happen abort API.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
END Validate_Location;

-- Utility name : Validate_LnCreateTrxType
-- Type       : Private
-- Function   : Validate the CREATE transaction type
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_validation_flag IN VARCHAR2,
--              p_dflt_country    IN VARCHAR2,
--              p_ship_type_id    IN NUMBER,
--              p_organization_id IN NUMBER,
--              p_org_id          IN NUMBER,
--              p_interface_source_code IN VARCHAR2
--
-- IN OUT     : x_ship_ln_int_lst IN OUT NOCOPY ship_ln_int_list_type
--              x_return_status      OUT NOCOPY VARCHAR2
--              x_validate_inv_item  OUT NOCOPY BOOLEAN,
--
-- Version    : Current version 1.0
--
-- Notes
FUNCTION Validate_LnCreateTrxType(
        p_validation_flag IN VARCHAR2,
        p_dflt_country    IN VARCHAR2,
        p_ship_type_id    IN NUMBER,
        p_organization_id IN NUMBER,
        p_org_id          IN NUMBER,
        p_interface_source_code IN VARCHAR2,
        x_ship_ln_int_lst IN OUT NOCOPY ship_ln_int_list_type,
        x_return_status      OUT NOCOPY VARCHAR2
)RETURN BOOLEAN IS

    l_program_name     CONSTANT VARCHAR2(30) := 'Validate_LnCreateTrxType';
    l_return_status VARCHAR2(1) ;
    l_debug_info    VARCHAR2(400) ;
    l_response      BOOLEAN := TRUE;
    l_response_int  BOOLEAN := TRUE;
    l_ship_line_int_id NUMBER;
    l_lcm_flag      VARCHAR2(1); --Bug 13056120
    l_validate_inv_item     BOOLEAN := TRUE;
    l_validate_txn_uom_code BOOLEAN := TRUE;
BEGIN

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name) ;
    --  Initialize API return status to success
    x_return_status      := L_FND_RET_STS_SUCCESS;

    l_debug_info := 'Check Line columns for the CREATE transaction type';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info);

    FOR l_ship_ln_int_idx IN 1 .. x_ship_ln_int_lst.COUNT
    LOOP

        IF x_ship_ln_int_lst(l_ship_ln_int_idx).org_id IS NULL
        THEN
            x_ship_ln_int_lst(l_ship_ln_int_idx).org_id := p_org_id;
        END IF;

        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_ship_ln_int_lst('||l_ship_ln_int_idx||').currency_code',
            p_var_value      =>        x_ship_ln_int_lst(l_ship_ln_int_idx).currency_code);
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_ship_ln_int_lst('||l_ship_ln_int_idx||').inventory_item_id',
            p_var_value      =>        x_ship_ln_int_lst(l_ship_ln_int_idx).inventory_item_id);
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_ship_ln_int_lst('||l_ship_ln_int_idx||').inventory_item_name',
            p_var_value      =>        x_ship_ln_int_lst(l_ship_ln_int_idx).inventory_item_name);
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_ship_ln_int_lst('||l_ship_ln_int_idx||').party_id',
            p_var_value      =>        x_ship_ln_int_lst(l_ship_ln_int_idx).party_id);
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_ship_ln_int_lst('||l_ship_ln_int_idx||').party_number',
            p_var_value      =>        x_ship_ln_int_lst(l_ship_ln_int_idx).party_number);
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_ship_ln_int_lst('||l_ship_ln_int_idx||').party_site_id',
            p_var_value      =>        x_ship_ln_int_lst(l_ship_ln_int_idx).party_site_id);
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_ship_ln_int_lst('||l_ship_ln_int_idx||').party_site_number',
            p_var_value      =>        x_ship_ln_int_lst(l_ship_ln_int_idx).party_site_number);
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_ship_ln_int_lst('||l_ship_ln_int_idx||').ship_header_id',
            p_var_value      =>        x_ship_ln_int_lst(l_ship_ln_int_idx).ship_header_id);
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_ship_ln_int_lst('||l_ship_ln_int_idx||').ship_line_group_id',
            p_var_value      =>        x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_group_id);
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_ship_ln_int_lst('||l_ship_ln_int_idx||').ship_line_group_num',
            p_var_value      =>        x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_group_num);
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_ship_ln_int_lst('||l_ship_ln_int_idx||').ship_line_id',
            p_var_value      =>        x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_id);
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_ship_ln_int_lst('||l_ship_ln_int_idx||').ship_line_num',
            p_var_value      =>        x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_num);
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_ship_ln_int_lst('||l_ship_ln_int_idx||').ship_line_src_type_code',
            p_var_value      =>        x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_src_type_code);
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_ship_ln_int_lst('||l_ship_ln_int_idx||').ship_line_type_code',
            p_var_value      =>        x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_type_code);
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_ship_ln_int_lst('||l_ship_ln_int_idx||').ship_line_type_id',
            p_var_value      =>        x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_type_id);
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_ship_ln_int_lst('||l_ship_ln_int_idx||').source_organization_code',
            p_var_value      =>        x_ship_ln_int_lst(l_ship_ln_int_idx).source_organization_code);
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_ship_ln_int_lst('||l_ship_ln_int_idx||').source_organization_id',
            p_var_value      =>        x_ship_ln_int_lst(l_ship_ln_int_idx).source_organization_id);
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_ship_ln_int_lst('||l_ship_ln_int_idx||').txn_qty',
            p_var_value      =>        x_ship_ln_int_lst(l_ship_ln_int_idx).txn_qty);
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_ship_ln_int_lst('||l_ship_ln_int_idx||').txn_unit_price',
            p_var_value      =>        x_ship_ln_int_lst(l_ship_ln_int_idx).txn_unit_price);
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_ship_ln_int_lst('||l_ship_ln_int_idx||').txn_uom_code',
            p_var_value      =>        x_ship_ln_int_lst(l_ship_ln_int_idx).txn_uom_code);

        l_ship_line_int_id := x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_int_id;

        l_debug_info := 'Checking l_ship_line_int_id: ' || l_ship_line_int_id;
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);

        l_debug_info := 'Checking if ship_line_src_type_code IS NULL';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);

        IF(x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_src_type_code IS NULL)
        THEN
            l_response := FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name => 'INL_SHIP_LINES_INT',
                p_parent_table_id   => l_ship_line_int_id,
                p_column_name       => 'TRANSACTION_TYPE',
                p_column_value      => 'CREATE',
                p_error_message_name => 'INL_ERR_TRX_TP_ID_NULL',
                p_token1_name       => 'COLUMN',
                p_token1_value      => 'SHIP_LINE_SRC_TYPE_CODE',
                p_token2_name       => 'ID_NAME',
                p_token2_value      => 'INL_SHIP_LINES_INT',
                p_token3_name       => 'ID_VAL',
                p_token3_value      => l_ship_line_int_id,
                x_return_status     => l_return_status) ;
            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        l_debug_info := 'Checking parties to PO';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);

        -- PO Source Type required columns validations
        IF x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_src_type_code = 'PO'
        THEN
            IF (x_ship_ln_int_lst(l_ship_ln_int_idx).party_id IS NULL AND
                x_ship_ln_int_lst(l_ship_ln_int_idx).party_number IS NULL)
                OR
                (x_ship_ln_int_lst(l_ship_ln_int_idx).party_site_id IS NULL AND
                 x_ship_ln_int_lst(l_ship_ln_int_idx).party_site_number IS NULL)
            THEN
                l_response := FALSE;
                -- Add a line into inl_ship_errors
                Handle_InterfError(
                    p_parent_table_name => 'INL_SHIP_LINES_INT',
                    p_parent_table_id   => l_ship_line_int_id,
                    p_column_name       => 'TRANSACTION_TYPE',
                    p_column_value      => 'CREATE',
                    p_error_message_name => 'INL_ERR_PARTY_FLDS_NULL_SRC_TP',
                    p_token1_name       => 'SHIP_LN_SRC',
                    p_token1_value      => x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_src_type_code,
                    p_token2_name       => 'ID_NAME',
                    p_token2_value      => 'INL_SHIP_LINES_INT',
                    p_token3_name       => 'ID_VAL',
                    p_token3_value      => l_ship_line_int_id,
                    x_return_status     => l_return_status) ;
                -- If any errors happen abort API.
                IF l_return_status = L_FND_RET_STS_ERROR THEN
                    RAISE L_FND_EXC_ERROR;
                ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                    RAISE L_FND_EXC_UNEXPECTED_ERROR;
                END IF;

            END IF;

            --Bug 13056120 Starts
        l_debug_info := 'Checking if lines are compliant or not';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);

              SELECT INV_UTILITIES.inv_check_lcm(pla.item_id,
                                                   plla.ship_to_organization_id,
                                                   plla.consigned_flag,
                                                   NULL,
                                                   pha.vendor_id,
                                                   pha.vendor_site_id,
                                                   plla.line_location_id)
                INTO l_lcm_flag
                FROM    po_headers_all pha
                      , po_lines_all pla
                      , po_line_locations_all plla
                WHERE   pha.po_header_id = pla.po_header_id
                    AND pla.po_line_id = plla.po_line_id
                    AND pha.po_header_id = plla.po_header_id
                    AND plla.line_location_id = x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_source_id;

                INL_LOGGING_PVT.Log_Variable(
                    p_module_name    => g_module_name,
                    p_procedure_name => l_program_name,
                    p_var_name       => 'l_lcm_flag',
                    p_var_value      =>  NVL(l_lcm_flag,'NULL'));

                IF NVL(l_lcm_flag,'N') <> 'Y' THEN
                   l_response := FALSE;
                -- Add a line into inl_ship_errors
                Handle_InterfError(
                    p_parent_table_name => 'INL_SHIP_LINES_INT',
                    p_parent_table_id   => l_ship_line_int_id,
                    p_column_name       => 'TRANSACTION_TYPE',
                    p_column_value      => 'CREATE',
                    p_error_message_name => 'INL_ERR_SHIP_REC_NOT_COMPL',
                    p_token1_name       => 'ID_NAME1',
                    p_token1_value      => 'INL_SHIP_LINES_INT',
                    p_token2_name       => 'ID_VAL1',
                    p_token2_value      => l_ship_line_int_id,
                    p_token3_name       => 'ID_NAME2',
                    p_token3_value      => 'INL_SHIP_HEADERS_INT',
                    p_token4_name       => 'ID_VAL2',
                    p_token4_value      => x_ship_ln_int_lst(l_ship_ln_int_idx).ship_header_int_id,
                    x_return_status     => l_return_status) ;
                            -- If any errors happen abort API.
                            IF l_return_status = L_FND_RET_STS_ERROR THEN
                                RAISE L_FND_EXC_ERROR;
                            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                                RAISE L_FND_EXC_UNEXPECTED_ERROR;
                            END IF;
                  END IF;

            --Bug 13056120 Ends here

            IF(x_ship_ln_int_lst(l_ship_ln_int_idx).source_organization_id IS NOT NULL
            AND x_ship_ln_int_lst(l_ship_ln_int_idx).source_organization_code IS NOT NULL)
            THEN
                l_response := FALSE;
                -- Add a line into inl_ship_errors
                Handle_InterfError(
                    p_parent_table_name => 'INL_SHIP_LINES_INT',
                    p_parent_table_id   => l_ship_line_int_id,
                    p_column_name       => 'TRANSACTION_TYPE',
                    p_column_value      => 'CREATE',
                    p_error_message_name => 'INL_ERR_SRC_ORG_FLDS_NNULL',
                    p_token1_name       => 'SHIP_LN_SRC',
                    p_token1_value      => x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_src_type_code,
                    p_token2_name       => 'ID_NAME',
                    p_token2_value      => 'INL_SHIP_LINES_INT',
                    p_token3_name       => 'ID_VAL',
                    p_token3_value      => l_ship_line_int_id,
                    x_return_status     => l_return_status) ;
                -- If any errors happen abort API.
                IF l_return_status = L_FND_RET_STS_ERROR THEN
                    RAISE L_FND_EXC_ERROR;
                ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                    RAISE L_FND_EXC_UNEXPECTED_ERROR;
                END IF;

            END IF;
        ELSIF x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_src_type_code = 'RMA'
        THEN
            l_debug_info := 'Checking parties to RMA';
            INL_LOGGING_PVT.Log_Statement(
                p_module_name      => g_module_name,
                p_procedure_name   => l_program_name,
                p_debug_info       => l_debug_info);
            IF x_ship_ln_int_lst(l_ship_ln_int_idx).party_id IS NULL AND
               x_ship_ln_int_lst(l_ship_ln_int_idx).party_number IS NULL
            THEN
                l_response := FALSE;
                -- Add a line into inl_ship_errors
                Handle_InterfError(
                    p_parent_table_name => 'INL_SHIP_LINES_INT',
                    p_parent_table_id   => l_ship_line_int_id,
                    p_column_name       => 'TRANSACTION_TYPE',
                    p_column_value      => 'CREATE',
                    p_error_message_name => 'INL_ERR_PARTY_NULL',
                    p_token1_name       => 'SHIP_LN_SRC',
                    p_token1_value      => x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_src_type_code,
                    p_token2_name       => 'ID_NAME',
                    p_token2_value      => 'INL_SHIP_LINES_INT',
                    p_token3_name       => 'ID_VAL',
                    p_token3_value      => l_ship_line_int_id,
                    x_return_status     => l_return_status) ;
                -- If any errors happen abort API.
                IF l_return_status = L_FND_RET_STS_ERROR THEN
                    RAISE L_FND_EXC_ERROR;
                ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                    RAISE L_FND_EXC_UNEXPECTED_ERROR;
                END IF;
            END IF;
            IF(x_ship_ln_int_lst(l_ship_ln_int_idx).source_organization_id IS NOT NULL
                AND x_ship_ln_int_lst(l_ship_ln_int_idx).source_organization_code IS NOT NULL)
            THEN
                l_response := FALSE;
                -- Add a line into inl_ship_errors
                Handle_InterfError(
                    p_parent_table_name => 'INL_SHIP_LINES_INT',
                    p_parent_table_id   => l_ship_line_int_id,
                    p_column_name       => 'TRANSACTION_TYPE',
                    p_column_value      => 'CREATE',
                    p_error_message_name => 'INL_ERR_SRC_ORG_FLDS_NNULL',
                    p_token1_name       => 'SHIP_LN_SRC',
                    p_token1_value      => x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_src_type_code,
                    p_token2_name       => 'ID_NAME',
                    p_token2_value      => 'INL_SHIP_LINES_INT',
                    p_token3_name       => 'ID_VAL',
                    p_token3_value      => l_ship_line_int_id,
                    x_return_status     => l_return_status) ;
                -- If any errors happen abort API.
                IF l_return_status = L_FND_RET_STS_ERROR THEN
                    RAISE L_FND_EXC_ERROR;
                ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                    RAISE L_FND_EXC_UNEXPECTED_ERROR;
                END IF;
            END IF;
            IF x_ship_ln_int_lst(l_ship_ln_int_idx).party_site_id IS NOT NULL
                OR x_ship_ln_int_lst(l_ship_ln_int_idx).party_site_number IS NOT NULL
            THEN
                l_response := FALSE;
                -- Add a line into inl_ship_errors
                Handle_InterfError(
                    p_parent_table_name => 'INL_SHIP_LINES_INT',
                    p_parent_table_id   => l_ship_line_int_id,
                    p_column_name       => 'TRANSACTION_TYPE',
                    p_column_value      => 'CREATE',
                    p_error_message_name => 'INL_ERR_PTY_ST_NNULL_SRC_TP',
                    p_token1_name       => 'SHIP_LN_SRC',
                    p_token1_value      => x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_src_type_code,
                    p_token2_name       => 'ID_NAME',
                    p_token2_value      => 'INL_SHIP_LINES_INT',
                    p_token3_name       => 'ID_VAL',
                    p_token3_value      => l_ship_line_int_id,
                    x_return_status     => l_return_status) ;
                -- If any errors happen abort API.
                IF l_return_status = L_FND_RET_STS_ERROR THEN
                    RAISE L_FND_EXC_ERROR;
                ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                    RAISE L_FND_EXC_UNEXPECTED_ERROR;
                END IF;
            END IF;
        ELSIF x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_src_type_code = 'IR'
        THEN
            l_debug_info := 'Checking parties to IR';
            INL_LOGGING_PVT.Log_Statement(
                p_module_name      => g_module_name,
                p_procedure_name   => l_program_name,
                p_debug_info       => l_debug_info);
            IF x_ship_ln_int_lst(l_ship_ln_int_idx).source_organization_id IS NULL
                AND x_ship_ln_int_lst(l_ship_ln_int_idx).source_organization_code IS NULL
            THEN
                l_response := FALSE;
                -- Add a line into inl_ship_errors
                Handle_InterfError(
                    p_parent_table_name => 'INL_SHIP_LINES_INT',
                    p_parent_table_id   => l_ship_line_int_id,
                    p_column_name       => 'TRANSACTION_TYPE',
                    p_column_value      => 'CREATE',
                    p_error_message_name => 'INL_ERR_SRC_ORG_NULL_SRC_TP',
                    p_token1_name       => 'SHIP_LN_SRC_TYPE_CODE',
                    p_token2_name       => 'ID_NAME',
                    p_token2_value      => 'INL_SHIP_LINES_INT',
                    p_token3_name       => 'ID_VAL',
                    p_token3_value      => l_ship_line_int_id,
                    p_token1_value      => x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_src_type_code,
                    x_return_status     => l_return_status) ;
                -- If any errors happen abort API.
                IF l_return_status = L_FND_RET_STS_ERROR THEN
                    RAISE L_FND_EXC_ERROR;
                ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                    RAISE L_FND_EXC_UNEXPECTED_ERROR;
                END IF;
            END IF;

            IF x_ship_ln_int_lst(l_ship_ln_int_idx).party_site_id IS NOT NULL
                OR x_ship_ln_int_lst(l_ship_ln_int_idx).party_site_number IS NOT NULL
            THEN
                l_response := FALSE;
                -- Add a line into inl_ship_errors
                Handle_InterfError(
                    p_parent_table_name => 'INL_SHIP_LINES_INT',
                    p_parent_table_id   => l_ship_line_int_id,
                    p_column_name       => 'TRANSACTION_TYPE',
                    p_column_value      => 'CREATE',
                    p_error_message_name => 'INL_ERR_PTY_ST_NNULL_SRC_TP',
                    p_token1_name       => 'SHIP_LN_SRC',
                    p_token1_value      => x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_src_type_code,
                    p_token2_name       => 'ID_NAME',
                    p_token2_value      => 'INL_SHIP_LINES_INT',
                    p_token3_name       => 'ID_VAL',
                    p_token3_value      => l_ship_line_int_id,
                    x_return_status     => l_return_status) ;
                -- If any errors happen abort API.
                IF l_return_status = L_FND_RET_STS_ERROR THEN
                    RAISE L_FND_EXC_ERROR;
                ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                    RAISE L_FND_EXC_UNEXPECTED_ERROR;
                END IF;
            END IF;

            IF x_ship_ln_int_lst(l_ship_ln_int_idx).party_id IS NOT NULL
                OR x_ship_ln_int_lst(l_ship_ln_int_idx).party_number IS NOT NULL
            THEN
                l_response := FALSE;
                -- Add a line into inl_ship_errors
                Handle_InterfError(
                    p_parent_table_name => 'INL_SHIP_LINES_INT',
                    p_parent_table_id   => l_ship_line_int_id,
                    p_column_name       => 'TRANSACTION_TYPE',
                    p_column_value      => 'CREATE',
                    p_error_message_name => 'INL_ERR_PARTY_NNULL_SRC_TP',
                    p_token1_name       => 'SHIP_LN_SRC',
                    p_token1_value      => x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_src_type_code,
                    p_token2_name       => 'ID_NAME',
                    p_token2_value      => 'INL_SHIP_LINES_INT',
                    p_token3_name       => 'ID_VAL',
                    p_token3_value      => l_ship_line_int_id,
                    x_return_status     => l_return_status) ;
                -- If any errors happen abort API.
                IF l_return_status = L_FND_RET_STS_ERROR THEN
                    RAISE L_FND_EXC_ERROR;
                ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                    RAISE L_FND_EXC_UNEXPECTED_ERROR;
                END IF;
            END IF;
        ELSE
            l_debug_info := 'Bad trx type code';
            INL_LOGGING_PVT.Log_Statement(
                p_module_name      => g_module_name,
                p_procedure_name   => l_program_name,
                p_debug_info       => l_debug_info);
            l_response := FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name => 'INL_SHIP_LINES_INT',
                p_parent_table_id   => l_ship_line_int_id,
                p_column_name       => 'TRANSACTION_TYPE',
                p_column_value      => 'CREATE',
                p_error_message_name => 'INL_ERR_OI_CHK_TRX_TP_INVL',
                p_token1_name       => 'TTYPE',
                p_token1_value      => x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_src_type_code,
                p_token2_name       => 'ID_NAME',
                p_token2_value      => 'INL_SHIP_LINES_INT',
                p_token3_name       => 'ID_VAL',
                p_token3_value      => l_ship_line_int_id,
                x_return_status     => l_return_status) ;
            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        IF      (x_ship_ln_int_lst(l_ship_ln_int_idx).party_id IS NOT NULL
                OR x_ship_ln_int_lst(l_ship_ln_int_idx).party_number IS NOT NULL)
            AND (x_ship_ln_int_lst(l_ship_ln_int_idx).source_organization_id IS NOT NULL
                OR x_ship_ln_int_lst(l_ship_ln_int_idx).source_organization_code IS NOT NULL)
        THEN
            l_debug_info := 'Party and Source Organization are mutually exclusive. Only one field or the other may be populated.';
            INL_LOGGING_PVT.Log_Statement(
                p_module_name      => g_module_name,
                p_procedure_name   => l_program_name,
                p_debug_info       => l_debug_info);
            l_response := FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
               p_parent_table_name  => 'INL_SHIP_LINES_INT',
               p_parent_table_id    => l_ship_line_int_id,
               p_column_name        => 'PARTY_ID',
               p_column_value       => x_ship_ln_int_lst(l_ship_ln_int_idx).party_id,
               p_error_message_name => 'INL_ERR_PARTY_SRC_ORG_EXISTS',
               x_return_status      => l_return_status);
             -- If any errors happen abort API.
             IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
             END IF;
        END IF;

        l_debug_info := 'Checking currency';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);

        IF(x_ship_ln_int_lst(l_ship_ln_int_idx).currency_code IS NULL) THEN
            l_response := FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name => 'INL_SHIP_LINES_INT',
                p_parent_table_id   => l_ship_line_int_id,
                p_column_name       => 'TRANSACTION_TYPE',
                p_column_value      => 'CREATE',
                p_error_message_name => 'INL_ERR_TRX_TP_ID_NULL',
                p_token1_name       => 'COLUMN',
                p_token1_value      => 'CURRENCY_CODE',
                p_token2_name       => 'ID_NAME',
                p_token2_value      => 'INL_SHIP_LINES_INT',
                p_token3_name       => 'ID_VAL',
                p_token3_value      => l_ship_line_int_id,
                x_return_status     => l_return_status) ;
            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        l_debug_info := 'Checking Trx Qty';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);

        IF(x_ship_ln_int_lst(l_ship_ln_int_idx).txn_qty IS NULL) THEN
            l_response := FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name => 'INL_SHIP_LINES_INT',
                p_parent_table_id   => l_ship_line_int_id,
                p_column_name       => 'TRANSACTION_TYPE',
                p_column_value      => 'CREATE',
                p_error_message_name => 'INL_ERR_TRX_TP_ID_NULL',
                p_token1_name       => 'COLUMN',
                p_token1_value      => 'TXN_QTY',
                p_token2_name       => 'ID_NAME',
                p_token2_value      => 'INL_SHIP_LINES_INT',
                p_token3_name       => 'ID_VAL',
                p_token3_value      => l_ship_line_int_id,
                x_return_status     => l_return_status) ;
            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        l_debug_info := 'Checking UOM';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);

        IF(x_ship_ln_int_lst(l_ship_ln_int_idx).txn_uom_code IS NULL) THEN
            l_response := FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name => 'INL_SHIP_LINES_INT',
                p_parent_table_id   => l_ship_line_int_id,
                p_column_name       => 'TRANSACTION_TYPE',
                p_column_value      => 'CREATE',
                p_error_message_name => 'INL_ERR_TRX_TP_ID_NULL',
                p_token1_name       => 'COLUMN',
                p_token1_value      => 'TXN_UOM_CODE',
                p_token2_name       => 'ID_NAME',
                p_token2_value      => 'INL_SHIP_LINES_INT',
                p_token3_name       => 'ID_VAL',
                p_token3_value      => l_ship_line_int_id,
                x_return_status     => l_return_status) ;
            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        l_debug_info := 'Checking Trx Unit Price';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);

        IF(x_ship_ln_int_lst(l_ship_ln_int_idx).txn_unit_price IS NULL) THEN
            l_response := FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name => 'INL_SHIP_LINES_INT',
                p_parent_table_id   => l_ship_line_int_id,
                p_column_name       => 'TRANSACTION_TYPE',
                p_column_value      => 'CREATE',
                p_error_message_name => 'INL_ERR_TRX_TP_ID_NULL',
                p_token1_name       => 'COLUMN',
                p_token1_value      => 'TXN_UNIT_PRICE',
                p_token2_name       => 'ID_NAME',
                p_token2_value      => 'INL_SHIP_LINES_INT',
                p_token3_name       => 'ID_VAL',
                p_token3_value      => l_ship_line_int_id,
                x_return_status     => l_return_status) ;
            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        IF x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_type_id IS NULL AND
           x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_type_code IS NULL
        THEN
            l_response := FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name => 'INL_SHIP_LINES_INT',
                p_parent_table_id   => l_ship_line_int_id,
                p_column_name       => 'TRANSACTION_TYPE',
                p_column_value      => 'CREATE',
                p_error_message_name => 'INL_ERR_TRX_TP_ID_NULL',
                p_token1_name       => 'COLUMN',
                p_token1_value      => 'SHIP_LINE_TYPE_ID OR SHIP_LINE_TYPE_CODE',
                p_token2_name       => 'ID_NAME',
                p_token2_value      => 'INL_SHIP_LINES_INT',
                p_token3_name       => 'ID_VAL',
                p_token3_value      => l_ship_line_int_id,
                x_return_status     => l_return_status) ;
            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        IF x_ship_ln_int_lst(l_ship_ln_int_idx).inventory_item_id IS NULL AND
           x_ship_ln_int_lst(l_ship_ln_int_idx).inventory_item_name IS NULL
        THEN
            l_response := FALSE;

            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name => 'INL_SHIP_LINES_INT',
                p_parent_table_id   => l_ship_line_int_id,
                p_column_name       => 'TRANSACTION_TYPE',
                p_column_value      => 'CREATE',
                p_error_message_name => 'INL_ERR_TRX_TP_ID_NULL',
                p_token1_name       => 'COLUMN',
                p_token1_value      => 'INVENTORY_ITEM_ID OR INVENTORY_ITEM_NAME',
                p_token2_name       => 'ID_NAME',
                p_token2_value      => 'INL_SHIP_LINES_INT',
                p_token3_name       => 'ID_VAL',
                p_token3_value      => l_ship_line_int_id,
                x_return_status     => l_return_status) ;
            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        IF x_ship_ln_int_lst(l_ship_ln_int_idx).ship_header_id IS NOT NULL
        THEN
            l_response := FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name => 'INL_SHIP_LINES_INT',
                p_parent_table_id   => l_ship_line_int_id,
                p_column_name       => 'TRANSACTION_TYPE',
                p_column_value      => 'CREATE',
                p_error_message_name => 'INL_ERR_TRX_TP_ID_NNULL',
                p_token1_name       => 'COLUMN',
                p_token1_value      => 'SHIP_HEADER_ID',
                p_token2_name       => 'ID_NAME',
                p_token2_value      => 'INL_SHIP_LINES_INT',
                p_token3_name       => 'ID_VAL',
                p_token3_value      => l_ship_line_int_id,
                x_return_status     => l_return_status) ;
            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        IF x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_group_id IS NOT NULL OR
           x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_group_num IS NOT NULL
        THEN
            l_response := FALSE;

            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name => 'INL_SHIP_LINES_INT',
                p_parent_table_id   => l_ship_line_int_id,
                p_column_name       => 'TRANSACTION_TYPE',
                p_column_value      => 'CREATE',
                p_error_message_name => 'INL_ERR_TRX_TP_ID_NNULL',
                p_token1_name       => 'COLUMN',
                p_token1_value      => 'SHIP_LINE_GROUP_ID AND SHIP_LINE_GROUP_NUM',
                p_token2_name       => 'ID_NAME',
                p_token2_value      => 'INL_SHIP_LINES_INT',
                p_token3_name       => 'ID_VAL',
                p_token3_value      => l_ship_line_int_id,
                x_return_status     => l_return_status) ;
            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        IF x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_id IS NOT NULL OR
            x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_num IS NOT NULL
        THEN
            l_response := FALSE;

            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name => 'INL_SHIP_LINES_INT',
                p_parent_table_id   => l_ship_line_int_id,
                p_column_name       => 'TRANSACTION_TYPE',
                p_column_value      => 'CREATE',
                p_error_message_name => 'INL_ERR_TRX_TP_ID_NNULL',
                p_token1_name       => 'COLUMN',
                p_token1_value      => 'SHIP_LINE_ID AND SHIP_LINE_NUM',
                p_token2_name       => 'ID_NAME',
                p_token2_value      => 'INL_SHIP_LINES_INT',
                p_token3_name       => 'ID_VAL',
                p_token3_value      => l_ship_line_int_id,
                x_return_status     => l_return_status) ;
            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        IF x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_src_type_code <> 'IR'
        THEN
            l_debug_info := 'Calling Validate_Party';
            INL_LOGGING_PVT.Log_Statement(
                p_module_name      => g_module_name,
                p_procedure_name   => l_program_name,
                p_debug_info       => l_debug_info);

            l_response_int :=
                Validate_Party
                (
                    p_ship_line_int_id  => x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_int_id,
                    p_validation_flag   => p_validation_flag,
                    p_ship_type_id      => p_ship_type_id,
                    x_party_id          => x_ship_ln_int_lst(l_ship_ln_int_idx).party_id,
                    x_party_number      => x_ship_ln_int_lst(l_ship_ln_int_idx).party_number,
                    x_return_status     => l_return_status
            );

            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
            IF (l_response_int)
            THEN
                l_debug_info := 'True';
            ELSE
                l_debug_info := 'False';
                l_response := l_response_int;
            END IF;
            INL_LOGGING_PVT.Log_Variable(
                p_module_name    => g_module_name,
                p_procedure_name => l_program_name,
                p_var_name       => 'l_response_int',
                p_var_value      => l_debug_info);

            IF x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_src_type_code = 'PO'
            THEN

                l_debug_info := 'Calling Validate_Party Site';
                INL_LOGGING_PVT.Log_Statement(
                    p_module_name      => g_module_name,
                    p_procedure_name   => l_program_name,
                    p_debug_info       => l_debug_info);
                l_response_int :=
                    Validate_PartySite
                    (
                        p_ship_line_int_id  => x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_int_id,
                        p_validation_flag   => p_validation_flag,
                        p_party_id          => x_ship_ln_int_lst(l_ship_ln_int_idx).party_id,
                        p_dflt_country      => p_dflt_country,
                        p_ship_type_id      => p_ship_type_id,
                        x_party_site_id     => x_ship_ln_int_lst(l_ship_ln_int_idx).party_site_id,
                        x_party_site_number => x_ship_ln_int_lst(l_ship_ln_int_idx).party_site_number,
                        x_return_status     => l_return_status
                );

                -- If any errors happen abort API.
                IF l_return_status = L_FND_RET_STS_ERROR THEN
                    RAISE L_FND_EXC_ERROR;
                ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                    RAISE L_FND_EXC_UNEXPECTED_ERROR;
                END IF;
                IF (l_response_int)
                THEN
                    l_debug_info := 'True';
                ELSE
                    l_debug_info := 'False';
                    l_response := l_response_int;
                END IF;
                INL_LOGGING_PVT.Log_Variable(
                    p_module_name    => g_module_name,
                    p_procedure_name => l_program_name,
                    p_var_name       => 'l_response_int',
                    p_var_value      => l_debug_info);

            END IF;
        ELSE -- = 'IR'
            l_debug_info := 'Calling Validate_SrcOrganization';
            INL_LOGGING_PVT.Log_Statement(
                p_module_name      => g_module_name,
                p_procedure_name   => l_program_name,
                p_debug_info       => l_debug_info);

            l_response_int :=
                Validate_SrcOrganization
                (
                    p_ship_line_int_id      => x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_int_id,
                    p_validation_flag       => p_validation_flag,
                    x_src_organization_id   => x_ship_ln_int_lst(l_ship_ln_int_idx).source_organization_id,
                    x_src_organization_code => x_ship_ln_int_lst(l_ship_ln_int_idx).source_organization_code,
                    x_return_status         => l_return_status
            );

            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
            IF (l_response_int)
            THEN
                l_debug_info := 'True';
            ELSE
                l_debug_info := 'False';
                l_response := l_response_int;
            END IF;
            INL_LOGGING_PVT.Log_Variable(
                p_module_name    => g_module_name,
                p_procedure_name => l_program_name,
                p_var_name       => 'l_response_int',
                p_var_value      => l_debug_info);

        END IF;
        l_debug_info := 'Calling Validate_ShipLineType';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);

        l_response_int :=
            Validate_ShipLineType
            (
                p_ship_line_int_id      => x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_int_id,
                p_validation_flag       => p_validation_flag,
                p_ship_type_id          => p_ship_type_id,
                x_ship_line_type_id     => x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_type_id,
                x_ship_line_type_code   => x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_type_code,
                x_landed_cost_flag      => x_ship_ln_int_lst(l_ship_ln_int_idx).landed_cost_flag,
                x_alloc_enabled_flag    => x_ship_ln_int_lst(l_ship_ln_int_idx).allocation_enabled_flag,
                x_return_status         => l_return_status
        );

        -- If any errors happen abort API.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
        IF (l_response_int)
        THEN
            l_debug_info := 'True';
        ELSE
            l_debug_info := 'False';
            l_response := l_response_int;
        END IF;
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'l_response_int',
            p_var_value      => l_debug_info);

        IF p_validation_flag = 'Y' THEN

            l_debug_info := 'Calling Validate_ShipLnSrcTypeCode';
            INL_LOGGING_PVT.Log_Statement(
                p_module_name      => g_module_name,
                p_procedure_name   => l_program_name,
                p_debug_info       => l_debug_info);
            l_response_int :=
                Validate_ShipLnSrcTypeCode(
                    p_ship_line_int_id      => x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_int_id,
                    p_ship_ln_src_tp_code   => x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_src_type_code,
                    x_return_status         => l_return_status
            );

            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
            IF (l_response_int)
            THEN
                l_debug_info := 'True';
            ELSE
                l_debug_info := 'False';
                l_response := l_response_int;
            END IF;
            INL_LOGGING_PVT.Log_Variable(
                p_module_name    => g_module_name,
                p_procedure_name => l_program_name,
                p_var_name       => 'l_response_int',
                p_var_value      => l_debug_info);
        END IF;

        l_debug_info := 'Calling Validate_CurrencyCode';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);
        l_response_int :=
            Validate_Currency
            (   p_ship_line_int_id  => x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_int_id,
                p_validation_flag   => x_ship_ln_int_lst(l_ship_ln_int_idx).validation_flag,
                p_currency_code     => x_ship_ln_int_lst(l_ship_ln_int_idx).currency_code,
                p_curr_conv_date    => x_ship_ln_int_lst(l_ship_ln_int_idx).currency_conversion_date,
                p_curr_conv_type    => x_ship_ln_int_lst(l_ship_ln_int_idx).currency_conversion_type,
                p_org_id            => x_ship_ln_int_lst(l_ship_ln_int_idx).org_id,
                x_curr_conv_rate    => x_ship_ln_int_lst(l_ship_ln_int_idx).currency_conversion_rate,
                x_return_status     => l_return_status
        );

        -- If any errors happen abort API.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
        IF (l_response_int)
        THEN
            l_debug_info := 'True';
        ELSE
            l_debug_info := 'False';
            l_response := l_response_int;
        END IF;
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'l_response_int',
            p_var_value      => l_debug_info);

        l_debug_info := 'Calling Validate_InvItemId';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);
        l_response_int :=
            Validate_InvItemId
            (   p_ship_line_int_id  => x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_int_id,
                p_validation_flag   => x_ship_ln_int_lst(l_ship_ln_int_idx).validation_flag,
                p_organization_id   => p_organization_id,
                x_inv_item_name     => x_ship_ln_int_lst(l_ship_ln_int_idx).inventory_item_name,
                x_inv_item_id       => x_ship_ln_int_lst(l_ship_ln_int_idx).inventory_item_id,
                x_return_status     => l_return_status
        );

        -- If any errors happen abort API.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
        IF (l_response_int)
        THEN
            l_debug_info := 'True';
        ELSE
            l_debug_info := 'False';
            l_response := l_response_int;
            l_validate_inv_item := l_response_int;
        END IF;
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'l_response_int',
            p_var_value      => l_debug_info);

        IF x_ship_ln_int_lst(l_ship_ln_int_idx).txn_uom_code IS NOT NULL
        AND p_validation_flag = 'Y'
        THEN
            l_debug_info := 'Calling Validate_TxnUomCode';
            INL_LOGGING_PVT.Log_Statement(
                p_module_name      => g_module_name,
                p_procedure_name   => l_program_name,
                p_debug_info       => l_debug_info);
            l_response_int :=
                Validate_TxnUomCode(
                    p_ship_line_int_id  => x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_int_id,
                    p_txn_uom_code      => x_ship_ln_int_lst(l_ship_ln_int_idx).txn_uom_code,
                    x_return_status     => l_return_status
            );

            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
            IF (l_response_int)
            THEN
                l_debug_info := 'True';
            ELSE
                l_debug_info := 'False';
                l_response := l_response_int;
                l_validate_txn_uom_code := l_response_int;
            END IF;
            INL_LOGGING_PVT.Log_Variable(
                p_module_name    => g_module_name,
                p_procedure_name => l_program_name,
                p_var_name       => 'l_response_int',
                p_var_value      => l_debug_info);
        END IF;

        IF l_validate_txn_uom_code AND l_validate_inv_item
        THEN
            l_debug_info := 'Call Validate_PriSecFields';
            INL_LOGGING_PVT.Log_Statement(
                p_module_name      => g_module_name,
                p_procedure_name   => l_program_name,
                p_debug_info       => l_debug_info);

            l_response_int := Validate_PriSecFields(
                p_ship_line_int_id      => x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_int_id,
                p_validation_flag       => p_validation_flag,
                p_organization_id       => p_organization_id,
                p_inventory_item_id     => x_ship_ln_int_lst(l_ship_ln_int_idx).inventory_item_id,
                p_txn_uom_code          => x_ship_ln_int_lst(l_ship_ln_int_idx).txn_uom_code,
                p_txn_qty               => x_ship_ln_int_lst(l_ship_ln_int_idx).txn_qty,
                p_txn_unit_price        => x_ship_ln_int_lst(l_ship_ln_int_idx).txn_unit_price,
                p_ship_line_id          => x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_id,
                p_interface_source_code => p_interface_source_code, -- Bug #8932386
                p_interface_source_line_id => x_ship_ln_int_lst(l_ship_ln_int_idx).interface_source_line_id, -- Bug 11710754
                x_1ary_uom_code         => x_ship_ln_int_lst(l_ship_ln_int_idx).primary_uom_code,
                x_1ary_qty              => x_ship_ln_int_lst(l_ship_ln_int_idx).primary_qty,
                x_1ary_unit_price       => x_ship_ln_int_lst(l_ship_ln_int_idx).primary_unit_price,
                x_2ary_uom_code         => x_ship_ln_int_lst(l_ship_ln_int_idx).secondary_uom_code,
                x_2ary_qty              => x_ship_ln_int_lst(l_ship_ln_int_idx).secondary_qty,
                x_2ary_unit_price       => x_ship_ln_int_lst(l_ship_ln_int_idx).secondary_unit_price,
                x_return_status         => l_return_status);

            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
            IF (l_response_int)
            THEN
                l_debug_info := 'True';
            ELSE
                l_debug_info := 'False';
                l_response := l_response_int;
            END IF;
            INL_LOGGING_PVT.Log_Variable(
                p_module_name    => g_module_name,
                p_procedure_name => l_program_name,
                p_var_name       => 'l_response_int',
                p_var_value      => l_debug_info);
        END IF;


        IF p_validation_flag = 'Y'
        THEN
            l_debug_info := 'Call Validate_LandedCostFlag';
            INL_LOGGING_PVT.Log_Statement(
                p_module_name      => g_module_name,
                p_procedure_name   => l_program_name,
                p_debug_info       => l_debug_info);

            l_response_int := Validate_LandedCostFlag(
                p_ship_line_int_id      => x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_int_id,
                p_landed_cost_flag      => x_ship_ln_int_lst(l_ship_ln_int_idx).landed_cost_flag, -- # Bug 9866323 --ship_lin_int_list(p_line_index).landed_cost_flag,
                x_return_status         => l_return_status);

            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
            IF (l_response_int)
            THEN
                l_debug_info := 'True';
            ELSE
                l_debug_info := 'False';
                l_response := l_response_int;
            END IF;
            INL_LOGGING_PVT.Log_Variable(
                p_module_name    => g_module_name,
                p_procedure_name => l_program_name,
                p_var_name       => 'l_response_int',
                p_var_value      => l_debug_info);

            l_debug_info := 'Call Validate_AllocEnabledFlag';
            INL_LOGGING_PVT.Log_Statement(
                p_module_name      => g_module_name,
                p_procedure_name   => l_program_name,
                p_debug_info       => l_debug_info);

            l_response_int := Validate_AllocEnabledFlag(
                p_ship_line_int_id      => x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_int_id,
                p_alloc_enabled_flag    => x_ship_ln_int_lst(l_ship_ln_int_idx).allocation_enabled_flag, -- # Bug 9866323 ship_lin_int_list(p_line_index).allocation_enabled_flag,
                x_return_status         => l_return_status);

            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
            IF (l_response_int)
            THEN
                l_debug_info := 'True';
            ELSE
                l_debug_info := 'False';
                l_response := l_response_int;
            END IF;
            INL_LOGGING_PVT.Log_Variable(
                p_module_name    => g_module_name,
                p_procedure_name => l_program_name,
                p_var_name       => 'l_response_int',
                p_var_value      => l_debug_info);

        END IF;
    END LOOP;

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);
    RETURN l_response;
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name);
        END IF;
        RETURN FND_API.to_boolean(L_FND_FALSE) ;

END  Validate_LnCreateTrxType;

-- Utility name : Validate_RcvEnabledFlag
-- Type       : Private
-- Function   : Validate RCV enabled flag according to source
--              defined in ship lines
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_header_int_id IN NUMBER
--              p_transaction_type   IN VARCHAR2
--              p_rcv_enabled_flag   IN VARCHAR2
--
-- IN OUT     : x_return_status      IN OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Validate_RcvEnabledFlag
       (p_ship_header_int_id IN NUMBER,
        p_rcv_enabled_flag   IN VARCHAR2,
        x_return_status      IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN IS
    l_program_name               CONSTANT VARCHAR2(30) := 'Validate_RcvEnabledFlag';
    l_debug_info              VARCHAR2(400) ;
    l_response                BOOLEAN := TRUE;
    l_return_status           VARCHAR2(1) := L_FND_TRUE;
    l_ship_line_src_type_code VARCHAR2(10);

BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name) ;
    --  Initialize API return status to success
    x_return_status      := L_FND_RET_STS_SUCCESS;

    l_debug_info := 'Validate RCV enabled flag';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info);

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_rcv_enabled_flag',
        p_var_value      => p_rcv_enabled_flag);

    l_debug_info := 'Checking the source type against RCV enabled flag';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info);

    SELECT DISTINCT(sli.ship_line_src_type_code)
    INTO l_ship_line_src_type_code
    FROM inl_ship_lines_int sli
    WHERE sli.ship_header_int_id = p_ship_header_int_id;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'l_ship_line_src_type_code',
        p_var_value      => l_ship_line_src_type_code);

    IF p_rcv_enabled_flag = 'Y' THEN
        IF l_ship_line_src_type_code NOT IN ('PO', 'IR', 'RMA') THEN
             l_response := FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name  => 'INL_SHIP_HEADERS_INT',
                p_parent_table_id    => p_ship_header_int_id,
                p_column_name        => 'RCV_ENABLED_FLAG',
                p_column_value       => p_rcv_enabled_flag,
                p_error_message_name => 'INL_ERR_RECEIVED_SRC_LN_TYP',
                p_token1_name        => 'SHIP_LN_SRC_TYPE_CODE',
                p_token1_value       => l_ship_line_src_type_code,
                p_token2_name        => 'ID_NAME',
                p_token2_value       => 'INL_SHIP_HEADERS_INT',
                p_token3_name        => 'ID_VAL',
                p_token3_value       => p_ship_header_int_id,
                x_return_status      => l_return_status) ;
            -- If unexpected errors happen abort
            IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
    ELSIF p_rcv_enabled_flag <> 'N' THEN
        l_response := FALSE;
        -- Add a line into inl_ship_errors
        Handle_InterfError(
            p_parent_table_name  => 'INL_SHIP_HEADERS_INT',
            p_parent_table_id    => p_ship_header_int_id,
            p_column_name        => 'RCV_ENABLED_FLAG',
            p_column_value       => p_rcv_enabled_flag,
            p_error_message_name => 'INL_ERR_RCV_ENABLED_FLAG_INV',
            p_token1_name        => 'ID_NAME',
            p_token1_value       => 'INL_SHIP_HEADERS_INT',
            p_token2_name        => 'ID_VAL',
            p_token2_value       => p_ship_header_int_id,
            x_return_status      => l_return_status) ;
        -- If unexpected errors happen abort
        IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);
    RETURN l_response;
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name);
        END IF;
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
END Validate_RcvEnabledFlag;

-- Utility name : Validate_HdrCreateTrxType
-- Type       : Private
-- Function   : Validate the CREATE transaction type
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_header_int_id    IN NUMBER
--              p_ship_header_id        IN NUMBER
--              p_ship_num              IN VARCHAR2
--              p_ship_date             IN DATE
--              p_ship_type_id          IN NUMBER
--              p_ship_type_code        IN VARCHAR2
--              p_rcv_enabled_flag      IN VARCHAR2
--              p_organization_id       IN NUMBER
--              p_organization_code     IN VARCHAR2
--              p_last_task_code        IN VARCHAR2
-- IN OUT     : x_return_status      IN OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes
FUNCTION Validate_HdrCreateTrxType(
        p_ship_header_int_id    IN NUMBER,
        p_ship_header_id        IN NUMBER,
        p_ship_num              IN VARCHAR2,
        p_ship_date             IN DATE,
        p_ship_type_id          IN NUMBER,
        p_ship_type_code        IN VARCHAR2,
        p_rcv_enabled_flag      IN VARCHAR2,
        p_organization_id       IN NUMBER,
        p_organization_code     IN VARCHAR2,
        p_last_task_code        IN VARCHAR2,
        x_return_status         IN OUT NOCOPY VARCHAR2
)RETURN BOOLEAN IS

    l_program_name     CONSTANT VARCHAR2(30) := 'Validate_HdrCreateTrxType';
    l_return_status VARCHAR2(1) ;
    l_debug_info    VARCHAR2(400) ;
    l_response      BOOLEAN := TRUE;
    l_response_int  BOOLEAN := TRUE;
    l_ship_line_int_id NUMBER;

BEGIN

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name) ;
    --  Initialize API return status to success
    x_return_status      := L_FND_RET_STS_SUCCESS;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_ship_header_int_id',
        p_var_value      => p_ship_header_int_id) ;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_ship_header_id',
        p_var_value      => p_ship_header_id) ;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_ship_num',
        p_var_value      => p_ship_num) ;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_ship_date',
        p_var_value      => p_ship_date) ;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_ship_type_id',
        p_var_value      => p_ship_type_id) ;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_ship_type_code',
        p_var_value      => p_ship_type_code) ;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_rcv_enabled_flag',
        p_var_value      => p_rcv_enabled_flag) ;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_organization_id',
        p_var_value      => p_organization_id) ;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_organization_code',
        p_var_value      => p_organization_code) ;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_last_task_code',
        p_var_value      => p_last_task_code) ;

    l_debug_info := 'Check columns for the CREATE transaction type (HDR)';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info);

    l_debug_info := 'Check for columns that should be populated and null for CREATE. ship_header_int_id: ' ||p_ship_header_int_id;
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info);

    IF p_ship_date IS NULL THEN
        l_response := FALSE;
        -- Add a line into inl_ship_errors
        Handle_InterfError(
            p_parent_table_name => 'INL_SHIP_HEADERS_INT',
            p_parent_table_id   => p_ship_header_int_id,
            p_column_name       => 'TRANSACTION_TYPE',
            p_column_value      => 'CREATE',
            p_error_message_name => 'INL_ERR_TRX_TP_ID_NULL',
            p_token1_name       => 'COLUMN',
            p_token1_value      => 'SHIP_DATE',
            p_token2_name       => 'ID_NAME',
            p_token2_value      => 'INL_SHIP_HEADERS_INT',
            p_token3_name       => 'ID_VAL',
            p_token3_value      => p_ship_header_int_id,
            x_return_status     => l_return_status) ;
        -- If any errors happen abort API.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

    IF p_last_task_code IS NULL THEN
        l_response := FALSE;
        -- Add a line into inl_ship_errors
        Handle_InterfError(
            p_parent_table_name => 'INL_SHIP_HEADERS_INT',
            p_parent_table_id   => p_ship_header_int_id,
            p_column_name       => 'TRANSACTION_TYPE',
            p_column_value      => 'CREATE',
            p_error_message_name => 'INL_ERR_TRX_TP_ID_NULL',
            p_token1_name       => 'COLUMN',
            p_token1_value      => 'LAST_TASK_CODE',
            p_token2_name       => 'ID_NAME',
            p_token2_value      => 'INL_SHIP_HEADERS_INT',
            p_token3_name       => 'ID_VAL',
            p_token3_value      => p_ship_header_int_id,
            x_return_status     => l_return_status) ;
        -- If any errors happen abort API.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
    ELSIF p_last_task_code NOT IN ('10', '20', '30', '40', '50', '60') THEN
        l_response := FALSE;
        -- Add a line into inl_ship_errors
        Handle_InterfError(
            p_parent_table_name  => 'INL_SHIP_HEADERS_INT',
            p_parent_table_id    => p_ship_header_int_id,
            p_column_name        => 'LAST_TASK_CODE',
            p_column_value       => p_last_task_code,
            p_error_message_name => 'INL_OI_LAST_TASK_CODE_INVL',
            p_token1_name        => 'LTC',
            p_token1_value       => p_last_task_code,
            x_return_status      => l_return_status);

        -- If unexpected errors happen abort
        IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;

    END IF;

    IF p_ship_type_id   IS NULL AND
       p_ship_type_code IS NULL THEN
        l_response := FALSE;
        -- Add a line into inl_ship_errors
        Handle_InterfError(
            p_parent_table_name => 'INL_SHIP_HEADERS_INT',
            p_parent_table_id   => p_ship_header_int_id,
            p_column_name       => 'TRANSACTION_TYPE',
            p_column_value      => 'CREATE',
            p_error_message_name => 'INL_ERR_TRX_TP_ID_NULL',
            p_token1_name       => 'COLUMN',
            p_token1_value      => 'SHIP_TYPE_ID OR SHIP_TYPE_CODE',
            p_token2_name       => 'ID_NAME',
            p_token2_value      => 'INL_SHIP_HEADERS_INT',
            p_token3_name       => 'ID_VAL',
            p_token3_value      => p_ship_header_int_id,
            x_return_status     => l_return_status) ;
        -- If any errors happen abort API.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

    IF p_organization_id IS NULL AND
       p_organization_code IS NULL THEN
        l_response := FALSE;
        -- Add a line into inl_ship_errors
        Handle_InterfError(
            p_parent_table_name => 'INL_SHIP_HEADERS_INT',
            p_parent_table_id   => p_ship_header_int_id,
            p_column_name       => 'TRANSACTION_TYPE',
            p_column_value      => 'CREATE',
            p_error_message_name => 'INL_ERR_TRX_TP_ID_NULL',
            p_token1_name       => 'COLUMN',
            p_token1_value      => 'ORGANIZATION_ID or ORGANIZATION_CODE',
            p_token2_name       => 'ID_NAME',
            p_token2_value      => 'INL_SHIP_HEADERS_INT',
            p_token3_name       => 'ID_VAL',
            p_token3_value      => p_ship_header_int_id,
            x_return_status     => l_return_status) ;
        -- If any errors happen abort API.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

    IF p_rcv_enabled_flag IS NULL  THEN
        l_response := FALSE;
        -- Add a line into inl_ship_errors
        Handle_InterfError(
            p_parent_table_name => 'INL_SHIP_HEADERS_INT',
            p_parent_table_id   => p_ship_header_int_id,
            p_column_name       => 'TRANSACTION_TYPE',
            p_column_value      => 'CREATE',
            p_error_message_name => 'INL_ERR_TRX_TP_ID_NULL',
            p_token1_name       => 'COLUMN',
            p_token1_value      => 'RCV_ENABLED_FLAG',
            p_token2_name       => 'ID_NAME',
            p_token2_value      => 'INL_SHIP_HEADERS_INT',
            p_token3_name       => 'ID_VAL',
            p_token3_value      => p_ship_header_int_id,
            x_return_status     => l_return_status) ;
        -- If any errors happen abort API.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
    ELSE
        l_debug_info := 'Call Validate_RcvEnabledFlag';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);

        l_response_int := Validate_RcvEnabledFlag
           (p_ship_header_int_id => p_ship_header_int_id,
            p_rcv_enabled_flag   => p_rcv_enabled_flag,
            x_return_status      => l_return_status);

        -- If any errors happen abort API.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
        IF (l_response_int)
        THEN
            l_debug_info := 'True';
        ELSE
            l_debug_info := 'False';
            l_response := l_response_int;
        END IF;
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'l_response_int',
            p_var_value      => l_debug_info);

    END IF;

    IF p_ship_header_id IS NOT NULL THEN
        l_response := FALSE;
        -- Add a line into inl_ship_errors
        Handle_InterfError(
            p_parent_table_name => 'INL_SHIP_HEADERS_INT',
            p_parent_table_id   => p_ship_header_int_id,
            p_column_name       => 'TRANSACTION_TYPE',
            p_column_value      => 'CREATE',
            p_error_message_name => 'INL_ERR_TRX_TP_ID_NNULL',
            p_token1_name       => 'COLUMN',
            p_token1_value      => 'SHIP_HEADER_ID',
            p_token2_name       => 'ID_NAME',
            p_token2_value      => 'INL_SHIP_HEADERS_INT',
            p_token3_name       => 'ID_VAL',
            p_token3_value      => p_ship_header_int_id,
            x_return_status     => l_return_status) ;
        -- If any errors happen abort API.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;


    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);
    RETURN l_response;
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name);
        END IF;
        RETURN FND_API.to_boolean(L_FND_FALSE) ;

END  Validate_HdrCreateTrxType;

-- Utility name : Validate_HdrUpdateTrxType
-- Type       : Private
-- Function   : Validate the UPDATE transaction type
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_header_int_id IN NUMBER
--              p_organization_id    IN NUMBER
--              p_organization_code  IN VARCHAR2(3)
--              p_ship_type_id       IN NUMBER
--              p_ship_type_code     IN VARCHAR2(15)
--              p_location_id        IN NUMBER
--              p_location_code      IN VARCHAR2(60)
--              p_rcv_enabled_flag   IN VARCHAR2(1)
-- IN OUT     : x_return_status      IN OUT NOCOPY VARCHAR2
--              x_ship_header_id     IN OUT NOCOPY NUMBER
--              p_ship_num           IN OUT NOCOPY VARCHAR2(25)
--
-- Version    : Current version 1.0
--
-- Notes
FUNCTION Validate_HdrUpdateTrxType(
        p_ship_header_int_id IN NUMBER,
        p_organization_id    IN NUMBER,
        p_organization_code  IN VARCHAR2,
        p_ship_type_id       IN NUMBER,
        p_ship_type_code     IN VARCHAR2,
        p_location_id        IN NUMBER,
        p_location_code      IN VARCHAR2,
        p_rcv_enabled_flag   IN VARCHAR2,
        x_ship_num           IN OUT NOCOPY VARCHAR2,
        x_ship_header_id     IN OUT NOCOPY NUMBER,
        x_return_status      IN OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS

    l_program_name        CONSTANT VARCHAR2(30) := 'Validate_HdrUpdateTrxType';
    l_return_status    VARCHAR2(1) ;
    l_debug_info       VARCHAR2(400) ;
    l_response         BOOLEAN := TRUE;
    l_ship_status_code VARCHAR2(30);
    l_organization_id  NUMBER;
    l_ship_line_int_id NUMBER;
BEGIN

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name) ;
    --  Initialize API return status to success
    x_return_status      := L_FND_RET_STS_SUCCESS;

    l_debug_info := 'Check columns for the UPDATE transaction type';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info);

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_ship_header_int_id',
        p_var_value      => p_ship_header_int_id) ;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'x_ship_num',
        p_var_value      => x_ship_num) ;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_organization_id',
        p_var_value      => p_organization_id) ;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_organization_code',
        p_var_value      => p_organization_code) ;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_ship_type_id',
        p_var_value      => p_ship_type_id) ;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_ship_type_code',
        p_var_value      => p_ship_type_code) ;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_location_id',
        p_var_value      => p_location_id) ;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_location_code',
        p_var_value      => p_location_code) ;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_rcv_enabled_flag',
        p_var_value      => p_rcv_enabled_flag) ;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'x_ship_header_id',
        p_var_value      => x_ship_header_id) ;

--    1- In order to identify the shipment ship_header_id should be informed OR (ship_num + (organization))

    IF x_ship_header_id IS NOT NULL
    THEN
        BEGIN
            SELECT
                sh.ship_status_code
            INTO
                l_ship_status_code
            FROM inl_ship_headers_all sh --Bug#10381495
            WHERE sh.ship_header_id = x_ship_header_id;
            x_ship_num := NULL;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_debug_info := 'x_ship_header_id: ' || x_ship_header_id || ' not found in inl_ship_headers_all';
                INL_LOGGING_PVT.Log_Statement(
                    p_module_name      => g_module_name,
                    p_procedure_name   => l_program_name,
                    p_debug_info       => l_debug_info);
                l_response := FALSE;
                -- Add a line into inl_ship_errors
                Handle_InterfError(
                    p_parent_table_name  => 'INL_SHIP_HEADERS_INT',
                    p_parent_table_id    => p_ship_header_int_id,
                    p_column_name        => 'TRANSACTION_TYPE',
                    p_column_value       => 'UPDATE',
                    p_error_message_name => 'INL_ERR_OI_CHK_SHIP_HEADER_ID',
                    p_token1_name        => 'NAME',
                    p_token1_value       => 'INL_SHIP_HEADERS_INT',
                    p_token2_name        => 'ID',
                    p_token2_value       => p_ship_header_int_id,
                    x_return_status      => l_return_status);
                -- If any errors happen abort API.
                IF l_return_status = L_FND_RET_STS_ERROR THEN
                    RAISE L_FND_EXC_ERROR;
                ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                    RAISE L_FND_EXC_UNEXPECTED_ERROR;
                END IF;
        END;

    ELSIF x_ship_num IS NULL
        OR p_organization_id IS NULL
    THEN
        l_response := FALSE;
        -- Add a line into inl_ship_errors
        Handle_InterfError(
            p_parent_table_name => 'INL_SHIP_HEADERS_INT',
            p_parent_table_id   => p_ship_header_int_id,
            p_column_name       => 'TRANSACTION_TYPE',
            p_column_value      => 'UPDATE',
            p_error_message_name => 'INL_ERR_TRX_TP_ID_NULL',
            p_token1_name       => 'COLUMN',
            p_token1_value      => 'SHIP_HEADER_ID OR SHIP_NUM+ORG',
            p_token2_name       => 'ID_NAME',
            p_token2_value      => 'INL_SHIP_HEADERS_INT',
            p_token3_name       => 'ID_VAL',
            p_token3_value      => p_ship_header_int_id,
            x_return_status     => l_return_status) ;
        -- If any errors happen abort API.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
    ELSE
        l_debug_info := 'Get shipment information : '|| x_ship_num  ;
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);

        BEGIN
            SELECT
                sh.ship_status_code,
                sh.ship_header_id
            INTO
                l_ship_status_code,
                x_ship_header_id
            FROM inl_ship_headers_all sh --Bug#10381495
            WHERE sh.ship_num = x_ship_num
            AND organization_id = l_organization_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_debug_info := 'Invalid reference to the Shipment: ' || x_ship_num ||
                                ' and Organization: ' || l_organization_id ;
                INL_LOGGING_PVT.Log_Statement(
                    p_module_name      => g_module_name,
                    p_procedure_name   => l_program_name,
                    p_debug_info       => l_debug_info);
                l_response := FALSE;
                -- Add a line into inl_ship_errors
                Handle_InterfError(
                    p_parent_table_name  => 'INL_SHIP_HEADERS_INT',
                    p_parent_table_id    => p_ship_header_int_id,
                    p_column_name        => 'TRANSACTION_TYPE',
                    p_column_value       => 'UPDATE',
                    p_error_message_name => 'INL_ERR_NO_SHIP_NUM',
                    p_token1_name        => 'SHIP_NUM',
                    p_token1_value       => x_ship_num,
                    p_token2_name        => 'ORGANIZATION_ID',
                    p_token2_value       => l_organization_id,
                    x_return_status      => l_return_status);
                -- If any errors happen abort API.
                IF l_return_status = L_FND_RET_STS_ERROR THEN
                    RAISE L_FND_EXC_ERROR;
                ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                    RAISE L_FND_EXC_UNEXPECTED_ERROR;
                END IF;
        END;

    END IF;
    IF (l_response)
    THEN
        l_debug_info := 'Continuing';
    ELSE
        l_debug_info := 'Header has validation problem.';
    END IF;
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info);

    IF l_response THEN
        IF l_ship_status_code = 'COMPLETED' THEN
            l_debug_info := 'COMPLETED Shipments cannot be updated';
            INL_LOGGING_PVT.Log_Statement(
                p_module_name      => g_module_name,
                p_procedure_name   => l_program_name,
                p_debug_info       => l_debug_info);

            l_response := FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name  => 'INL_SHIP_HEADERS_INT',
                p_parent_table_id    => p_ship_header_int_id,
                p_column_name        => 'TRANSACTION_TYPE',
                p_column_value       => 'UPDATE',
                p_error_message_name => 'INL_ERR_OI_CHK_TRX_TP_STA_INVL',
                p_token1_name        => 'SHIP_HEADER_INT_ID',
                p_token1_value       => p_ship_header_int_id,
                x_return_status      => l_return_status) ;
            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
            RETURN FALSE;
        END IF;
    END IF;

    IF p_ship_type_id IS NOT NULL OR
        p_ship_type_code IS NOT NULL THEN
        l_response := FALSE;
        -- Add a line into inl_ship_errors
        Handle_InterfError(
            p_parent_table_name => 'INL_SHIP_HEADERS_INT',
            p_parent_table_id   => p_ship_header_int_id,
            p_column_name       => 'TRANSACTION_TYPE',
            p_column_value      => 'UPDATE',
            p_error_message_name => 'INL_ERR_TRX_TP_ID_NNULL',
            p_token1_name       => 'COLUMN',
            p_token1_value      => 'SHIP_TYPE_ID AND SHIP_TYPE_CODE',
            p_token2_name       => 'ID_NAME',
            p_token2_value      => 'INL_SHIP_HEADERS_INT',
            p_token3_name       => 'ID_VAL',
            p_token3_value      => p_ship_header_int_id,
            x_return_status     => l_return_status) ;
        -- If any errors happen abort API.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

    IF p_location_id IS NOT NULL OR
        p_location_code IS NOT NULL THEN
        l_response := FALSE;
        -- Add a line into inl_ship_errors
        Handle_InterfError(
            p_parent_table_name => 'INL_SHIP_HEADERS_INT',
            p_parent_table_id   => p_ship_header_int_id,
            p_column_name       => 'TRANSACTION_TYPE',
            p_column_value      => 'UPDATE',
            p_error_message_name => 'INL_ERR_TRX_TP_ID_NNULL',
            p_token1_name       => 'COLUMN',
            p_token1_value      => 'LOCATION_ID AND LOCATION_CODE',
            p_token2_name       => 'ID_NAME',
            p_token2_value      => 'INL_SHIP_HEADERS_INT',
            p_token3_name       => 'ID_VAL',
            p_token3_value      => p_ship_header_int_id,
            x_return_status     => l_return_status) ;
        -- If any errors happen abort API.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

    IF p_rcv_enabled_flag IS NOT NULL THEN
        l_response := FALSE;
        -- Add a line into inl_ship_errors
        Handle_InterfError(
            p_parent_table_name => 'INL_SHIP_HEADERS_INT',
            p_parent_table_id   => p_ship_header_int_id,
            p_column_name       => 'TRANSACTION_TYPE',
            p_column_value      => 'UPDATE',
            p_error_message_name => 'INL_ERR_TRX_TP_ID_NNULL',
            p_token1_name       => 'COLUMN',
            p_token1_value      => 'RCV_ENABLED_FLAG',
            p_token2_name       => 'ID_NAME',
            p_token2_value      => 'INL_SHIP_HEADERS_INT',
            p_token3_name       => 'ID_VAL',
            p_token3_value      => p_ship_header_int_id,
            x_return_status     => l_return_status) ;
        -- If any errors happen abort API.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);
    RETURN l_response;
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name);
        END IF;
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
END  Validate_HdrUpdateTrxType;

-- Utility name : Validate_LnUpdateTrxType
-- Type       : Private
-- Function   : Validate the UPDATE transaction type
--
-- Pre-reqs   : None
-- Parameters :
-- IN         :
--             p_validation_flag   IN VARCHAR2,
--             p_ship_header_id    IN NUMBER,
--             p_organization_id   IN NUMBER,
--             p_interface_source_code IN VARCHAR2,
--
-- IN OUT     : x_ship_ln_int_lst  IN OUT NOCOPY ship_ln_int_list_type,
--              x_return_status    IN OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes
FUNCTION Validate_LnUpdateTrxType(
        p_validation_flag   IN VARCHAR2,
        p_ship_header_id    IN NUMBER,
        p_organization_id   IN NUMBER,
        p_interface_source_code IN VARCHAR2,
        x_ship_ln_int_lst   IN OUT NOCOPY ship_ln_int_list_type,
        x_return_status     OUT NOCOPY VARCHAR2
)RETURN BOOLEAN IS

    l_program_name        CONSTANT VARCHAR2(30) := 'Validate_LnUpdateTrxType';
    l_return_status    VARCHAR2(1) ;
    l_debug_info       VARCHAR2(400) ;
    l_response         BOOLEAN := TRUE;
    l_response_int     BOOLEAN := TRUE;

    l_ship_line_int_id NUMBER;
    l_validate_txn_uom_code BOOLEAN := TRUE;

BEGIN

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name) ;
    --  Initialize API return status to success
    x_return_status      := L_FND_RET_STS_SUCCESS;

    l_debug_info := 'Check columns for the UPDATE transaction type';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info);

    l_debug_info := 'Check for columns that should be populated or null for UPDATE.';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info);


    FOR l_ship_ln_int_idx IN 1 .. x_ship_ln_int_lst.COUNT
    LOOP
        l_ship_line_int_id := x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_int_id;
        l_debug_info := 'Check ship_line_int_id: ' || l_ship_line_int_id;
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);


        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_ship_ln_int_lst(l_ship_ln_int_idx).currency_code ',
            p_var_value      =>  x_ship_ln_int_lst(l_ship_ln_int_idx).currency_code) ;

        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_ship_ln_int_lst(l_ship_ln_int_idx).currency_conversion_date ',
            p_var_value      =>  x_ship_ln_int_lst(l_ship_ln_int_idx).currency_conversion_date) ;
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_ship_ln_int_lst(l_ship_ln_int_idx).currency_conversion_rate ',
            p_var_value      =>  x_ship_ln_int_lst(l_ship_ln_int_idx).currency_conversion_rate) ;
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_ship_ln_int_lst(l_ship_ln_int_idx).currency_conversion_type ',
            p_var_value      =>  x_ship_ln_int_lst(l_ship_ln_int_idx).currency_conversion_type) ;
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_ship_ln_int_lst(l_ship_ln_int_idx).inventory_item_id ',
            p_var_value      =>  x_ship_ln_int_lst(l_ship_ln_int_idx).inventory_item_id) ;
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_ship_ln_int_lst(l_ship_ln_int_idx).inventory_item_name ',
            p_var_value      =>  x_ship_ln_int_lst(l_ship_ln_int_idx).inventory_item_name) ;
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_ship_ln_int_lst(l_ship_ln_int_idx).party_id ',
            p_var_value      =>  x_ship_ln_int_lst(l_ship_ln_int_idx).party_id) ;
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_ship_ln_int_lst(l_ship_ln_int_idx).party_number ',
            p_var_value      =>  x_ship_ln_int_lst(l_ship_ln_int_idx).party_number) ;
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_ship_ln_int_lst(l_ship_ln_int_idx).party_site_id ',
            p_var_value      =>  x_ship_ln_int_lst(l_ship_ln_int_idx).party_site_id) ;
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_ship_ln_int_lst(l_ship_ln_int_idx).party_site_number ',
            p_var_value      =>  x_ship_ln_int_lst(l_ship_ln_int_idx).party_site_number) ;
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_group_id ',
            p_var_value      =>  x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_group_id) ;
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_group_num ',
            p_var_value      =>  x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_group_num) ;
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_id ',
            p_var_value      =>  x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_id) ;
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_num ',
            p_var_value      =>  x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_num) ;
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_source_id ',
            p_var_value      =>  x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_source_id) ;
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_src_type_code ',
            p_var_value      =>  x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_src_type_code) ;
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_type_code ',
            p_var_value      =>  x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_type_code) ;
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_type_id ',
            p_var_value      =>  x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_type_id) ;
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_ship_ln_int_lst(l_ship_ln_int_idx).source_organization_code ',
            p_var_value      =>  x_ship_ln_int_lst(l_ship_ln_int_idx).source_organization_code) ;
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_ship_ln_int_lst(l_ship_ln_int_idx).source_organization_id ',
            p_var_value      =>  x_ship_ln_int_lst(l_ship_ln_int_idx).source_organization_id) ;

        l_debug_info := 'Checking ship_line_id and ship_line_group_id ';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);

        IF x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_id IS NULL AND
           x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_group_id IS NULL AND
           x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_group_num IS NULL THEN
            l_response := FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name => 'INL_SHIP_LINES_INT',
                p_parent_table_id   => l_ship_line_int_id,
                p_column_name       => 'TRANSACTION_TYPE',
                p_column_value      => 'UPDATE',
                p_error_message_name => 'INL_ERR_TRX_TP_ID_NULL',
                p_token1_name       => 'COLUMN',
                p_token1_value      => 'SHIP_LINE_GROUP_ID OR SHIP_LINE_GROUP_NUM',
                p_token2_name       => 'ID_NAME',
                p_token2_value      => 'INL_SHIP_LINES_INT',
                p_token3_name       => 'ID_VAL',
                p_token3_value      => l_ship_line_int_id,
                x_return_status     => l_return_status) ;
            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        l_debug_info := 'Checking ship_line_id and ship_line_num ';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);

        IF x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_id IS NULL AND
           x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_num IS NULL THEN
            l_response := FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name => 'INL_SHIP_LINES_INT',
                p_parent_table_id   => l_ship_line_int_id,
                p_column_name       => 'TRANSACTION_TYPE',
                p_column_value      => 'UPDATE',
                p_error_message_name => 'INL_ERR_TRX_TP_ID_NULL',
                p_token1_name       => 'COLUMN',
                p_token1_value      => 'SHIP_LINE_ID OR SHIP_LINE_NUM',
                p_token2_name       => 'ID_NAME',
                p_token2_value      => 'INL_SHIP_LINES_INT',
                p_token3_name       => 'ID_VAL',
                p_token3_value      => l_ship_line_int_id,
                x_return_status     => l_return_status) ;
            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        l_debug_info := 'Checking parties ';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);
       IF x_ship_ln_int_lst(l_ship_ln_int_idx).party_id IS NOT NULL OR
           x_ship_ln_int_lst(l_ship_ln_int_idx).party_number IS NOT NULL THEN
            l_response := FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name => 'INL_SHIP_LINES_INT',
                p_parent_table_id   => l_ship_line_int_id,
                p_column_name       => 'TRANSACTION_TYPE',
                p_column_value      => 'UPDATE',
                p_error_message_name => 'INL_ERR_TRX_TP_ID_NNULL',
                p_token1_name       => 'COLUMN',
                p_token1_value      => 'PARTY_ID AND PARTY_NUMBER',
                p_token2_name       => 'ID_NAME',
                p_token2_value      => 'INL_SHIP_LINES_INT',
                p_token3_name       => 'ID_VAL',
                p_token3_value      => l_ship_line_int_id,
                x_return_status     => l_return_status) ;
            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        l_debug_info := 'Checking party site ';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);
        IF x_ship_ln_int_lst(l_ship_ln_int_idx).party_site_id IS NOT NULL OR
           x_ship_ln_int_lst(l_ship_ln_int_idx).party_site_number IS NOT NULL THEN
            l_response := FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name => 'INL_SHIP_LINES_INT',
                p_parent_table_id   => l_ship_line_int_id,
                p_column_name       => 'TRANSACTION_TYPE',
                p_column_value      => 'UPDATE',
                p_error_message_name => 'INL_ERR_TRX_TP_ID_NNULL',
                p_token1_name       => 'COLUMN',
                p_token1_value      => 'PARTY_SITE_ID AND PARTY_SITE_NUMBER',
                p_token2_name       => 'ID_NAME',
                p_token2_value      => 'INL_SHIP_LINES_INT',
                p_token3_name       => 'ID_VAL',
                p_token3_value      => l_ship_line_int_id,
                x_return_status     => l_return_status) ;
            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        l_debug_info := 'Checking source_organization ';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);
        IF x_ship_ln_int_lst(l_ship_ln_int_idx).source_organization_id IS NOT NULL OR
           x_ship_ln_int_lst(l_ship_ln_int_idx).source_organization_code IS NOT NULL THEN
            l_response := FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name => 'INL_SHIP_LINES_INT',
                p_parent_table_id   => l_ship_line_int_id,
                p_column_name       => 'TRANSACTION_TYPE',
                p_column_value      => 'UPDATE',
                p_error_message_name => 'INL_ERR_TRX_TP_ID_NNULL',
                p_token1_name       => 'COLUMN',
                p_token1_value      => 'SOURCE_ORGANIZATION_ID AND SOURCE_ORGANIZATION_CODE',
                p_token2_name       => 'ID_NAME',
                p_token2_value      => 'INL_SHIP_LINES_INT',
                p_token3_name       => 'ID_VAL',
                p_token3_value      => l_ship_line_int_id,
                x_return_status     => l_return_status) ;
            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        l_debug_info := 'Checking ship_line_type ';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);
        IF x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_type_id IS NOT NULL OR
           x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_type_code IS NOT NULL THEN
            l_response := FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name => 'INL_SHIP_LINES_INT',
                p_parent_table_id   => l_ship_line_int_id,
                p_column_name       => 'TRANSACTION_TYPE',
                p_column_value      => 'UPDATE',
                p_error_message_name => 'INL_ERR_TRX_TP_ID_NNULL',
                p_token1_name       => 'COLUMN',
                p_token1_value      => 'SHIP_LINE_TYPE_ID AND SHIP_LINE_TYPE_CODE',
                p_token2_name       => 'ID_NAME',
                p_token2_value      => 'INL_SHIP_HEADERS_INT',
                p_token3_name       => 'ID_VAL',
                p_token3_value      => l_ship_line_int_id,
                x_return_status     => l_return_status) ;
            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        l_debug_info := 'Checking ship_line_id and ship_line_src_type_code ';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);
        IF x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_src_type_code IS NOT NULL THEN
            l_response := FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name => 'INL_SHIP_LINES_INT',
                p_parent_table_id   => l_ship_line_int_id,
                p_column_name       => 'TRANSACTION_TYPE',
                p_column_value      => 'UPDATE',
                p_error_message_name => 'INL_ERR_TRX_TP_ID_NNULL',
                p_token1_name       => 'COLUMN',
                p_token1_value      => 'SHIP_LINE_SRC_TYPE_CODE',
                p_token2_name       => 'ID_NAME',
                p_token2_value      => 'INL_SHIP_LINES_INT',
                p_token3_name       => 'ID_VAL',
                p_token3_value      => l_ship_line_int_id,
                x_return_status     => l_return_status) ;
            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        l_debug_info := 'Checking ship_line_id and ship_line_source_id ';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);
        IF x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_source_id IS NOT NULL THEN
            l_response := FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name => 'INL_SHIP_LINES_INT',
                p_parent_table_id   => l_ship_line_int_id,
                p_column_name       => 'TRANSACTION_TYPE',
                p_column_value      => 'UPDATE',
                p_error_message_name => 'INL_ERR_TRX_TP_ID_NNULL',
                p_token1_name       => 'COLUMN',
                p_token1_value      => 'SHIP_LINE_SOURCE_ID',
                p_token2_name       => 'ID_NAME',
                p_token2_value      => 'INL_SHIP_LINES_INT',
                p_token3_name       => 'ID_VAL',
                p_token3_value      => l_ship_line_int_id,
                x_return_status     => l_return_status) ;
            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        l_debug_info := 'Checking currency_code ';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);
        IF x_ship_ln_int_lst(l_ship_ln_int_idx).currency_code IS NOT NULL THEN
            l_response := FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name => 'INL_SHIP_LINES_INT',
                p_parent_table_id   => l_ship_line_int_id,
                p_column_name       => 'TRANSACTION_TYPE',
                p_column_value      => 'UPDATE',
                p_error_message_name => 'INL_ERR_TRX_TP_ID_NNULL',
                p_token1_name       => 'COLUMN',
                p_token1_value      => 'CURRENCY_CODE',
                p_token2_name       => 'ID_NAME',
                p_token2_value      => 'INL_SHIP_LINES_INT',
                p_token3_name       => 'ID_VAL',
                p_token3_value      => l_ship_line_int_id,
                x_return_status     => l_return_status) ;
            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        l_debug_info := 'Checking currency_conversion_type ';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);
        IF x_ship_ln_int_lst(l_ship_ln_int_idx).currency_conversion_type IS NOT NULL THEN
            l_response := FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name => 'INL_SHIP_LINES_INT',
                p_parent_table_id   => l_ship_line_int_id,
                p_column_name       => 'TRANSACTION_TYPE',
                p_column_value      => 'UPDATE',
                p_error_message_name => 'INL_ERR_TRX_TP_ID_NNULL',
                p_token1_name       => 'COLUMN',
                p_token1_value      => 'CURRENCY_CONVERSION_TYPE',
                p_token2_name       => 'ID_NAME',
                p_token2_value      => 'INL_SHIP_LINES_INT',
                p_token3_name       => 'ID_VAL',
                p_token3_value      => l_ship_line_int_id,
                x_return_status     => l_return_status) ;
            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        l_debug_info := 'Checking currency_conversion_date ';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);
        IF x_ship_ln_int_lst(l_ship_ln_int_idx).currency_conversion_date IS NOT NULL THEN
            l_response := FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name => 'INL_SHIP_LINES_INT',
                p_parent_table_id   => l_ship_line_int_id,
                p_column_name       => 'TRANSACTION_TYPE',
                p_column_value      => 'UPDATE',
                p_error_message_name => 'INL_ERR_TRX_TP_ID_NNULL',
                p_token1_name       => 'COLUMN',
                p_token1_value      => 'CURRENCY_CONVERSION_DATE',
                p_token2_name       => 'ID_NAME',
                p_token2_value      => 'INL_SHIP_LINES_INT',
                p_token3_name       => 'ID_VAL',
                p_token3_value      => l_ship_line_int_id,
                x_return_status     => l_return_status) ;
            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        l_debug_info := 'Checking currency_conversion_rate ';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);
        IF x_ship_ln_int_lst(l_ship_ln_int_idx).currency_conversion_rate IS NOT NULL THEN
            l_response := FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name => 'INL_SHIP_LINES_INT',
                p_parent_table_id   => l_ship_line_int_id,
                p_column_name       => 'TRANSACTION_TYPE',
                p_column_value      => 'UPDATE',
                p_error_message_name => 'INL_ERR_TRX_TP_ID_NNULL',
                p_token1_name       => 'COLUMN',
                p_token1_value      => 'CURRENCY_CONVERSION_RATE',
                p_token2_name       => 'ID_NAME',
                p_token2_value      => 'INL_SHIP_LINES_INT',
                p_token3_name       => 'ID_VAL',
                p_token3_value      => l_ship_line_int_id,
                x_return_status     => l_return_status) ;
            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        l_debug_info := 'Checking inventory_item_name and inventory_item_id';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);
        IF x_ship_ln_int_lst(l_ship_ln_int_idx).inventory_item_id IS NOT NULL OR
           x_ship_ln_int_lst(l_ship_ln_int_idx).inventory_item_name IS NOT NULL THEN
            l_response := FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name => 'INL_SHIP_LINES_INT',
                p_parent_table_id   => l_ship_line_int_id,
                p_column_name       => 'TRANSACTION_TYPE',
                p_column_value      => 'UPDATE',
                p_error_message_name => 'INL_ERR_TRX_TP_ID_NNULL',
                p_token1_name       => 'COLUMN',
                p_token1_value      => 'INVENTORY_ITEM_ID AND INVENTORY_ITEM_NAME',
                p_token2_name       => 'ID_NAME',
                p_token2_value      => 'INL_SHIP_LINES_INT',
                p_token3_name       => 'ID_VAL',
                p_token3_value      => l_ship_line_int_id,
                x_return_status     => l_return_status) ;
            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        l_debug_info := 'Calling Validate_ShipLineGrpNum';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);


        l_response_int :=
            Validate_ShipLineGrpNum(
                p_ship_header_int_id  => x_ship_ln_int_lst(l_ship_ln_int_idx).ship_header_int_id,
                p_ship_line_int_id    => x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_int_id,
                p_validation_flag     => p_validation_flag,
                p_ship_header_id      => p_ship_header_id,
                p_ship_line_id        => x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_id,
                x_ship_line_group_num => x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_group_num,
                x_ship_line_group_id  => x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_group_id,
                x_return_status       => l_return_status
        );


        -- If any errors happen abort API.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
        IF (l_response_int)
        THEN
            l_debug_info := 'True';
        ELSE
            l_debug_info := 'False';
            l_response := l_response_int;
        END IF;
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'l_response_int',
            p_var_value      => l_debug_info);


        l_debug_info := 'Calling Validate_ShipLineNum';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);

        l_response_int :=
            Validate_ShipLineNum(
                p_ship_line_int_id    => x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_int_id,
                p_validation_flag     => p_validation_flag,
                p_ship_header_id      => p_ship_header_id,
                p_ship_line_group_id  => x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_group_id,
                x_ship_line_num       => x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_num,
                x_ship_line_id        => x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_id,
                x_return_status       => l_return_status
        );

        -- If any errors happen abort API.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
        IF (l_response_int)
        THEN
            l_debug_info := 'True';
        ELSE
            l_debug_info := 'False';
            l_response := l_response_int;
        END IF;
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'l_response_int',
            p_var_value      => l_debug_info);

        IF x_ship_ln_int_lst(l_ship_ln_int_idx).txn_uom_code IS NOT NULL
        AND p_validation_flag = 'Y'
        THEN
            l_debug_info := 'Calling Validate_TxnUomCode';
            INL_LOGGING_PVT.Log_Statement(
                p_module_name      => g_module_name,
                p_procedure_name   => l_program_name,
                p_debug_info       => l_debug_info);
            l_response_int :=
                Validate_TxnUomCode(
                    p_ship_line_int_id  => x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_int_id,
                    p_txn_uom_code      => x_ship_ln_int_lst(l_ship_ln_int_idx).txn_uom_code,
                    x_return_status     => l_return_status
            );

            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
            IF (l_response_int)
            THEN
                l_debug_info := 'True';
            ELSE
                l_debug_info := 'False';
                l_response := l_response_int;
                l_validate_txn_uom_code := l_response_int;
            END IF;
            INL_LOGGING_PVT.Log_Variable(
                p_module_name    => g_module_name,
                p_procedure_name => l_program_name,
                p_var_name       => 'l_response_int',
                p_var_value      => l_debug_info);
        END IF;

        IF l_validate_txn_uom_code
        THEN

            l_debug_info := 'Call Validate_PriSecFields';
            INL_LOGGING_PVT.Log_Statement(
                p_module_name      => g_module_name,
                p_procedure_name   => l_program_name,
                p_debug_info       => l_debug_info);

            l_response_int := Validate_PriSecFields(
                p_ship_line_int_id      => x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_int_id,
                p_validation_flag       => p_validation_flag,
                p_organization_id       => p_organization_id,
                p_inventory_item_id     => x_ship_ln_int_lst(l_ship_ln_int_idx).inventory_item_id,
                p_txn_uom_code          => x_ship_ln_int_lst(l_ship_ln_int_idx).txn_uom_code,
                p_txn_qty               => x_ship_ln_int_lst(l_ship_ln_int_idx).txn_qty,
                p_txn_unit_price        => x_ship_ln_int_lst(l_ship_ln_int_idx).txn_unit_price,
                p_ship_line_id          => x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_id,
                p_interface_source_code => p_interface_source_code, -- Bug #8932386
                p_interface_source_line_id => x_ship_ln_int_lst(l_ship_ln_int_idx).interface_source_line_id, -- Bug 11710754
                x_1ary_uom_code         => x_ship_ln_int_lst(l_ship_ln_int_idx).primary_uom_code,
                x_1ary_qty              => x_ship_ln_int_lst(l_ship_ln_int_idx).primary_qty,
                x_1ary_unit_price       => x_ship_ln_int_lst(l_ship_ln_int_idx).primary_unit_price,
                x_2ary_uom_code         => x_ship_ln_int_lst(l_ship_ln_int_idx).secondary_uom_code,
                x_2ary_qty              => x_ship_ln_int_lst(l_ship_ln_int_idx).secondary_qty,
                x_2ary_unit_price       => x_ship_ln_int_lst(l_ship_ln_int_idx).secondary_unit_price,
                x_return_status         => l_return_status);

            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
            IF (l_response_int)
            THEN
                l_debug_info := 'True';
            ELSE
                l_debug_info := 'False';
                l_response := l_response_int;
            END IF;
            INL_LOGGING_PVT.Log_Variable(
                p_module_name    => g_module_name,
                p_procedure_name => l_program_name,
                p_var_name       => 'l_response_int',
                p_var_value      => l_debug_info);
        END IF;


        IF p_validation_flag = 'Y'
        THEN
            l_debug_info := 'Call Validate_LandedCostFlag';
            INL_LOGGING_PVT.Log_Statement(
                p_module_name      => g_module_name,
                p_procedure_name   => l_program_name,
                p_debug_info       => l_debug_info);

            l_response_int := Validate_LandedCostFlag(
                p_ship_line_int_id      => x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_int_id,
                p_landed_cost_flag      => x_ship_ln_int_lst(l_ship_ln_int_idx).landed_cost_flag, -- # Bug 9866323 --ship_lin_int_list(p_line_index).landed_cost_flag,
                x_return_status         => l_return_status);

            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
            IF (l_response_int)
            THEN
                l_debug_info := 'True';
            ELSE
                l_debug_info := 'False';
                l_response := l_response_int;
            END IF;
            INL_LOGGING_PVT.Log_Variable(
                p_module_name    => g_module_name,
                p_procedure_name => l_program_name,
                p_var_name       => 'l_response_int',
                p_var_value      => l_debug_info);

            l_debug_info := 'Call Validate_AllocEnabledFlag';
            INL_LOGGING_PVT.Log_Statement(
                p_module_name      => g_module_name,
                p_procedure_name   => l_program_name,
                p_debug_info       => l_debug_info);

            l_response_int := Validate_AllocEnabledFlag(
                p_ship_line_int_id      => x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_int_id,
                p_alloc_enabled_flag    => x_ship_ln_int_lst(l_ship_ln_int_idx).allocation_enabled_flag, -- # Bug 9866323 ship_lin_int_list(p_line_index).allocation_enabled_flag,
                x_return_status         => l_return_status);

            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
            IF (l_response_int)
            THEN
                l_debug_info := 'True';
            ELSE
                l_debug_info := 'False';
                l_response := l_response_int;
            END IF;
            INL_LOGGING_PVT.Log_Variable(
                p_module_name    => g_module_name,
                p_procedure_name => l_program_name,
                p_var_name       => 'l_response_int',
                p_var_value      => l_debug_info);

        END IF;

    END LOOP;

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);
    RETURN l_response;
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name);
        END IF;
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
END  Validate_LnUpdateTrxType;

-- Utility name : Validate_AllProcessingStatus
-- Type       : Private
-- Function   : Validate the PROCESSING STATUS CODE for lines.
--              None of them can be marked as ERROR
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_header_int_id IN NUMBER
--              p_ship_header_id     IN NUMBER
--
-- IN OUT     : x_return_status      IN OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes
FUNCTION Validate_AllProcessingStatus(
        p_ship_header_int_id IN NUMBER,
        x_return_status      IN OUT NOCOPY VARCHAR2
)RETURN BOOLEAN IS

    l_program_name           CONSTANT VARCHAR2(30) := 'Validate_AllProcessingStatus';
    l_return_status       VARCHAR2(1) ;
    l_debug_info          VARCHAR2(400) ;
    l_response            BOOLEAN := TRUE;
    l_count_ln_proc_error NUMBER;
BEGIN

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name) ;
    --  Initialize API return status to success
    x_return_status      := L_FND_RET_STS_SUCCESS;

    l_debug_info := 'Validate all ship line processins tatus code';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info);

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_ship_header_int_id',
        p_var_value      => p_ship_header_int_id);

    SELECT COUNT(1)
    INTO   l_count_ln_proc_error
    FROM   inl_ship_lines_int sli
    WHERE  sli.ship_header_int_id = p_ship_header_int_id
    AND    sli.processing_status_code = 'ERROR';

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'l_count_ln_proc_error',
        p_var_value      => l_count_ln_proc_error);

    IF NVL(l_count_ln_proc_error, 0) > 0 THEN
        l_debug_info := 'There are more than one source type code defined for the Shipment';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);
            l_response := FALSE;
        -- Add a line into inl_ship_errors
        Handle_InterfError(
            p_parent_table_name  => 'INL_SHIP_HEADERS_INT',
            p_parent_table_id    => p_ship_header_int_id,
            p_column_name        => NULL,
            p_column_value       => NULL,
            p_error_message_name => 'INL_ERR_ALL_PROCESSING_STATUS',
            p_token1_name        => 'ID_NAME',
            p_token1_value       => 'INL_SHIP_HEADERS_INT',
            p_token2_name        => 'ID_VAL',
            p_token2_value       => p_ship_header_int_id,
            x_return_status      => l_return_status) ;
        -- If any errors happen abort API.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);
    RETURN l_response;
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name);
        END IF;
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
END Validate_AllProcessingStatus;

-- Utility name : Validate_AllShipLnSrcTypeCode
-- Type       : Private
-- Function   : Validate all shipment line source type code for a Shipment
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_header_int_id IN NUMBER
--              p_transaction_type   IN VARCHAR2
--
-- IN OUT     : x_return_status      IN OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Validate_AllShipLnSrcTypeCode
       (p_ship_header_int_id IN NUMBER,
        x_return_status      IN OUT NOCOPY VARCHAR2)
    RETURN BOOLEAN IS
    l_program_name            CONSTANT VARCHAR2(30) := 'Validate_AllShipLnSrcTypeCode';
    l_debug_info           VARCHAR2(400) ;
    l_response             BOOLEAN := TRUE;
    l_return_status        VARCHAR2(1) := L_FND_TRUE;
    l_count_ln_src_tp_code NUMBER;

BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name) ;
    --  Initialize API return status to success
    x_return_status      := L_FND_RET_STS_SUCCESS;

    l_debug_info := 'Checking ship line source type code of Shipment';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info);

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_ship_header_int_id',
        p_var_value      => p_ship_header_int_id);

    SELECT COUNT(DISTINCT(sli.ship_line_src_type_code))
    INTO l_count_ln_src_tp_code
    FROM inl_ship_lines_int sli
    WHERE sli.ship_header_int_id = p_ship_header_int_id;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'l_count_ln_src_tp_code',
        p_var_value      => l_count_ln_src_tp_code);

    IF l_count_ln_src_tp_code > 1 THEN
        l_debug_info := 'There are more than one source type code defined for the Shipment';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);
            l_response := FALSE;
        -- Add a line into inl_ship_errors
        Handle_InterfError(
            p_parent_table_name => 'INL_SHIP_HEADERS_INT',
            p_parent_table_id   => p_ship_header_int_id,
            p_column_name       => NULL,
            p_column_value      => NULL,
            p_error_message_name => 'INL_ERR_ALL_SRC_TYPE',
            p_token1_name        => 'ID_NAME',
            p_token1_value       => 'INL_SHIP_HEADERS_INT',
            p_token2_name        => 'ID_VAL',
            p_token2_value       => p_ship_header_int_id,
            x_return_status     => l_return_status) ;
        -- If any errors happen abort API.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);
    RETURN l_response;
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name);
        END IF;
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
END Validate_AllShipLnSrcTypeCode;


-- Utility name : Validate_HdrTrxType
-- Type       : Private
-- Function   : Validate the transaction type
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_header_int_id IN NUMBER
--              p_transaction_type   IN NUMBER
--              p_ship_date          IN DATE
--              p_organization_id    IN NUMBER
--              p_organization_code  IN VARCHAR2
--              p_location_id        IN NUMBER
--              p_location_code      IN VARCHAR2
--              p_rcv_enabled_flag   IN VARCHAR2
--              p_last_task_code     IN VARCHAR2
--              p_ship_type_id       IN NUMBER
--              p_ship_type_code     IN VARCHAR2
--
-- IN OUT     : x_return_status      IN OUT NOCOPY VARCHAR2
--              x_ship_header_id     IN NUMBER
--              x_ship_num           OUT NOCOPY VARCHAR2,
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Validate_HdrTrxType(
    p_ship_header_int_id IN NUMBER,
    p_transaction_type   IN VARCHAR2,
    p_ship_date          IN DATE,
    p_organization_id    IN NUMBER,
    p_organization_code  IN VARCHAR2,
    p_location_id        IN NUMBER,
    p_location_code      IN VARCHAR2,
    p_rcv_enabled_flag   IN VARCHAR2,
    p_last_task_code     IN VARCHAR2,
    p_ship_type_id       IN NUMBER,
    p_ship_type_code     IN VARCHAR2,
    x_ship_num           IN OUT NOCOPY VARCHAR2,
    x_ship_header_id     IN OUT NOCOPY NUMBER,
    x_return_status      OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
    l_program_name     CONSTANT VARCHAR2(30) := 'Validate_HdrTrxType';
    l_return_status VARCHAR2(1) ;
    l_debug_info    VARCHAR2(400) ;
    l_response      BOOLEAN := TRUE;
    l_response_int  BOOLEAN := TRUE;
    l_column_null   VARCHAR2(300);
    l_column_nnull  VARCHAR2(300);

BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name) ;
    --  Initialize API return status to success
    x_return_status      := L_FND_RET_STS_SUCCESS;

    l_debug_info := 'Check columns for the specified transaction type';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info);

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'x_ship_num',
        p_var_value      => x_ship_num);

   IF p_transaction_type = 'CREATE' THEN
       l_response :=
            validate_HdrCreateTrxType(
                p_ship_header_int_id => p_ship_header_int_id,
                p_ship_header_id     => x_ship_header_id    ,
                p_ship_num           => x_ship_num          ,
                p_ship_date          => p_ship_date         ,
                p_last_task_code     => p_last_task_code    ,
                p_ship_type_id       => p_ship_type_id      ,
                p_ship_type_code     => p_ship_type_code    ,
                p_rcv_enabled_flag   => p_rcv_enabled_flag  ,
                p_organization_id    => p_organization_id   ,
                p_organization_code  => p_organization_code ,
                x_return_status      => l_return_status);
        -- If any errors happen abort API.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;

    ELSIF p_transaction_type = 'UPDATE' THEN
        l_response :=
            validate_HdrUpdateTrxType(
                p_ship_header_int_id => p_ship_header_int_id,
                p_organization_id    => p_organization_id   ,
                p_organization_code  => p_organization_code ,
                p_ship_type_id       => p_ship_type_id      ,
                p_ship_type_code     => p_ship_type_code    ,
                p_location_id        => p_location_id       ,
                p_location_code      => p_location_code     ,
                p_rcv_enabled_flag   => p_rcv_enabled_flag  ,
                x_ship_num           => x_ship_num          ,
                x_ship_header_id     => x_ship_header_id    ,
                x_return_status      => l_return_status
        );
        -- If any errors happen abort API.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

    IF l_response THEN

        l_debug_info := 'Call Validate_AllShipLnSrcTypeCode';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);

        l_response_int :=  Validate_AllShipLnSrcTypeCode
            (p_ship_header_int_id => p_ship_header_int_id,
             x_return_status      => l_return_status);

        -- If any errors happen abort API.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
        IF (l_response_int)
        THEN
            l_debug_info := 'True';
        ELSE
            l_debug_info := 'False';
            l_response := l_response_int;
        END IF;
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'l_response_int',
            p_var_value      => l_debug_info);

        l_debug_info := 'Call Validate_AllProcessingStatus';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);

        l_response_int := Validate_AllProcessingStatus(
            p_ship_header_int_id => p_ship_header_int_id,
            x_return_status      => l_return_status);

        -- If any errors happen abort API.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;

        IF (l_response_int)
        THEN
            l_debug_info := 'True';
        ELSE
            l_debug_info := 'False';
            l_response := l_response_int;
        END IF;
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'l_response_int',
            p_var_value      => l_debug_info);

    END IF;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'x_ship_num',
        p_var_value      => x_ship_num);

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);
    RETURN l_response;
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name);
        END IF;
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
END Validate_HdrTrxType;

-- Utility name : Delete_Ship
-- Type       : Private
-- Function   : Delete a LCM Shipment from inl_ship_holds, inl_associations, inl_matches, inl_match_amount
--              inl_allocations, inl_tax_lines, inl_charge_lines,
--              inl_ship_lines_all, inl_ship_line_groups and inl_ship_headers_all
--              If a Charge/Tax is associated with more than one Shipment, only the associations
--              of the current shipment are going to be deleted
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_header_id IN  NUMBER
--
-- OUT        : x_return_status  OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Delete_Ship (
    p_ship_header_id IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2
) IS
    l_program_name  CONSTANT VARCHAR2(100) := 'Delete_Ship';
    l_debug_info VARCHAR2(2000) ;
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name) ;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;

-- Table inl_ship_holds
    l_debug_info := 'Delete from inl_ship_holds';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info) ;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'p_ship_header_id',
        p_var_value => p_ship_header_id
    );

    DELETE FROM inl_ship_holds
    WHERE ship_header_id = p_ship_header_id;


    INL_LOGGING_PVT.Log_Variable(
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'sql%rowcount',
        p_var_value => sql%rowcount
    );

-- Table inl_match_amounts
-- Bug#9279355
    l_debug_info := 'Delete inl_match_amounts';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info) ;

    DELETE FROM inl_match_amounts ma
    WHERE EXISTS (SELECT 1
                FROM inl_matches m
                WHERE m.ship_header_id = p_ship_header_id
                AND ma.match_amount_id = m.match_amount_id
                )
    AND NOT EXISTS (SELECT 1
                FROM inl_matches m
                WHERE m.ship_header_id <> p_ship_header_id
                AND ma.match_amount_id = m.match_amount_id
                )
    ;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'sql%rowcount',
        p_var_value => sql%rowcount
    );

-- Table inl_matches
-- Bug#9279355
    l_debug_info := 'Delete inl_matches';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info) ;

    DELETE FROM inl_matches m
    WHERE m.ship_header_id = p_ship_header_id;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'sql%rowcount',
        p_var_value => sql%rowcount
    );

-- Table
    l_debug_info := 'Delete from inl_allocations';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info) ;

    DELETE FROM inl_allocations
    WHERE ship_header_id = p_ship_header_id;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'sql%rowcount',
        p_var_value => sql%rowcount
    );

-- Table
    l_debug_info := 'Delete from inl_tax_lines';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info) ;

    DELETE FROM inl_tax_lines tl
    WHERE
        tl.ship_header_id = p_ship_header_id
        OR --Bug#9279355
        tl.ship_header_id IS NULL
        AND
        (
            EXISTS (
                    SELECT 1
                      FROM inl_associations assoc
                     WHERE assoc.from_parent_table_name     = 'INL_TAX_LINES'
                       AND (assoc.from_parent_table_id      = tl.tax_line_id
                            OR assoc.from_parent_table_id   = tl.parent_tax_line_id)
                       AND assoc.ship_header_id             = p_ship_header_id
                    )
            AND
            NOT EXISTS (
                    SELECT 1
                      FROM inl_associations assoc
                     WHERE assoc.from_parent_table_name     = 'INL_TAX_LINES'
                       AND (assoc.from_parent_table_id      = tl.tax_line_id
                            OR assoc.from_parent_table_id   = tl.parent_tax_line_id)
                       AND assoc.ship_header_id             <> p_ship_header_id
                    )
        )
    ;


    INL_LOGGING_PVT.Log_Variable(
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'sql%rowcount',
        p_var_value => sql%rowcount
    );

-- Table
    l_debug_info := 'Delete from inl_charge_lines';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info) ;

    DELETE
    FROM inl_charge_lines cl
    WHERE  --Bug#9279355
        (
            EXISTS (
                    SELECT 1
                      FROM inl_associations assoc
                     WHERE assoc.from_parent_table_name     = 'INL_CHARGE_LINES'
                       AND (assoc.from_parent_table_id      = cl.charge_line_id
                            OR assoc.from_parent_table_id   = cl.parent_charge_line_id)
                       AND assoc.ship_header_id             = p_ship_header_id
                    )
            AND
            NOT EXISTS (
                    SELECT 1
                      FROM inl_associations assoc
                     WHERE assoc.from_parent_table_name     = 'INL_CHARGE_LINES'
                       AND (assoc.from_parent_table_id      = cl.charge_line_id
                            OR assoc.from_parent_table_id   = cl.parent_charge_line_id)
                       AND assoc.ship_header_id             <> p_ship_header_id
                    )
        )
    ;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'sql%rowcount',
        p_var_value => sql%rowcount
    );

-- Table
    l_debug_info := 'Delete from inl_associations';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info) ;

    DELETE FROM inl_associations
    WHERE ship_header_id = p_ship_header_id;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'sql%rowcount',
        p_var_value => sql%rowcount
    );

-- Table
    l_debug_info := 'Delete from inl_ship_lines_all';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info) ;

    DELETE FROM inl_ship_lines_all
    WHERE ship_header_id = p_ship_header_id;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'sql%rowcount',
        p_var_value => sql%rowcount
    );

-- Table
    l_debug_info := 'Delete from inl_ship_line_groups';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info) ;

    DELETE FROM inl_ship_line_groups
    WHERE ship_header_id = p_ship_header_id;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'sql%rowcount',
        p_var_value => sql%rowcount
    );

-- Table
    l_debug_info := 'Delete from inl_ship_headers_all';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info) ;

    DELETE FROM inl_ship_headers_all
    WHERE ship_header_id = p_ship_header_id;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name => 'sql%rowcount',
        p_var_value => sql%rowcount
    );

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name );
        x_return_status := L_FND_RET_STS_ERROR;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name);
        END IF;
END Delete_Ship;

-- Utility name : Handle_LineGroups
-- Type       : Private
-- Function   : Create a Line Group for a given Shipment Header only if
--              it hasn't been created yet in the current transaction
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_transaction_type IN  VARCHAR2
--
-- OUT        :  x_ship_ln_int_rec      IN OUT c_ship_ln_int%ROWTYPE,
--               x_return_status        IN OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Handle_LineGroups(
    p_transaction_type              IN VARCHAR2,
    x_ship_ln_int_rec               IN OUT NOCOPY c_ship_ln_int%ROWTYPE,
    x_return_status                 IN OUT NOCOPY VARCHAR2
) IS
    l_program_name  CONSTANT VARCHAR2(100) := 'Handle_LineGroups';
    l_debug_info VARCHAR2(2000) ;
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name) ;

    l_debug_info    := 'ship_header_id. LG:'||current_SLnGr_rec.ship_header_id||' SL:'||x_ship_ln_int_rec.ship_header_id;
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    ) ;
    l_debug_info    := 'ship_line_group_reference. LG:'||current_SLnGr_rec.ship_line_group_reference||' SL:'||x_ship_ln_int_rec.ship_line_group_reference;
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    ) ;
    l_debug_info    := 'src_type_code. LG:'||current_SLnGr_rec.src_type_code||' SL:'||x_ship_ln_int_rec.ship_line_src_type_code;
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    ) ;
    l_debug_info    := 'party_id. LG:'||current_SLnGr_rec.party_id||' SL:'||x_ship_ln_int_rec.party_id;
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    ) ;
    l_debug_info    := 'party_site_id. LG:'||current_SLnGr_rec.party_site_id||' SL:'||x_ship_ln_int_rec.party_site_id;
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    ) ;
    l_debug_info    := 'source_organization_id. LG:'||current_SLnGr_rec.source_organization_id||' SL:'||x_ship_ln_int_rec.source_organization_id;
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    ) ;

    IF p_transaction_type = 'CREATE'
    THEN
        IF(   NVL(current_SLnGr_rec.ship_header_id, L_FND_MISS_NUM)             <> x_ship_ln_int_rec.ship_header_id
           OR NVL(current_SLnGr_rec.ship_line_group_reference, L_FND_MISS_CHAR) <> NVL(x_ship_ln_int_rec.ship_line_group_reference, L_FND_MISS_CHAR)
           OR current_SLnGr_rec.src_type_code                                   <> x_ship_ln_int_rec.ship_line_src_type_code
           OR current_SLnGr_rec.party_id                                        <> x_ship_ln_int_rec.party_id
           OR current_SLnGr_rec.party_site_id                                   <> x_ship_ln_int_rec.party_site_id
           OR NVL(current_SLnGr_rec.source_organization_id, L_FND_MISS_NUM)     <> NVL(x_ship_ln_int_rec.source_organization_id, L_FND_MISS_NUM))
        THEN

            l_debug_info    := 'Is other group: Select Data from group';
            INL_LOGGING_PVT.Log_Statement(
                p_module_name      => g_module_name,
                p_procedure_name   => l_program_name,
                p_debug_info       => l_debug_info) ;

            BEGIN
                 SELECT ship_line_group_id,                        /* 01 */
                       ship_line_group_reference,                  /* 02 */
                       ship_header_id,                             /* 03 */
--                       ship_line_group_num,                      /* 04 */
                       src_type_code,                              /* 05 */
                       party_id,                                   /* 06 */
                       party_site_id,                              /* 07 */
                       source_organization_id                      /* 08 */
                   INTO
                       current_SLnGr_rec.ship_line_group_id,       /* 01 */
                       current_SLnGr_rec.ship_line_group_reference,/* 02 */
                       current_SLnGr_rec.ship_header_id,           /* 03 */
--                       current_SLnGr_rec.ship_line_group_num,    /* 04 */
                       current_SLnGr_rec.src_type_code,            /* 05 */
                       current_SLnGr_rec.party_id,                 /* 06 */
                       current_SLnGr_rec.party_site_id,            /* 07 */
                       current_SLnGr_rec.source_organization_id    /* 08 */
                   FROM inl_ship_line_groups
                   WHERE ship_header_id                       = x_ship_ln_int_rec.ship_header_id
                   AND NVL(src_type_code, L_FND_MISS_CHAR)    = NVL(x_ship_ln_int_rec.ship_line_src_type_code, L_FND_MISS_CHAR)
                   AND party_id                               = x_ship_ln_int_rec.party_id
                   AND party_site_id                          = x_ship_ln_int_rec.party_site_id
                   AND source_organization_id                 = x_ship_ln_int_rec.source_organization_id
                   AND NVL(ship_line_group_reference, L_FND_MISS_NUM)= NVL(x_ship_ln_int_rec.ship_line_group_reference, L_FND_MISS_NUM) ;

                   INL_LOGGING_PVT.Log_Variable(
                        p_module_name    => g_module_name,
                        p_procedure_name => l_program_name,
                        p_var_name       => 'current_SLnGr_rec.ship_line_group_id',
                        p_var_value      => current_SLnGr_rec.ship_line_group_id) ;

                   x_ship_ln_int_rec.ship_line_group_id        := current_SLnGr_rec.ship_line_group_id;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    -- Create a Line Group record
                    SELECT inl_ship_line_groups_s.NEXTVAL
                    INTO current_SLnGr_rec.ship_line_group_id
                    FROM dual;
                    SELECT MAX(ship_line_group_num)
                    INTO current_SLnGr_rec.ship_line_group_num
                    FROM inl_ship_line_groups
                    WHERE ship_header_id = x_ship_ln_int_rec.ship_header_id;

                    x_ship_ln_int_rec.ship_line_group_id        := current_SLnGr_rec.ship_line_group_id;

                    current_SLnGr_rec.ship_line_group_num       := NVL(current_SLnGr_rec.ship_line_group_num, 0) + 1;
                    current_SLnGr_rec.ship_line_group_reference := x_ship_ln_int_rec.ship_line_group_reference;
                    current_SLnGr_rec.ship_header_id            := x_ship_ln_int_rec.ship_header_id;
                    current_SLnGr_rec.src_type_code             := x_ship_ln_int_rec.ship_line_src_type_code;
                    current_SLnGr_rec.party_id                  := x_ship_ln_int_rec.party_id;
                    current_SLnGr_rec.party_site_id             := x_ship_ln_int_rec.party_site_id;
                    current_SLnGr_rec.source_organization_id    := x_ship_ln_int_rec.source_organization_id;

                    l_debug_info    := 'Inserting inl_ship_line_groups';
                    INL_LOGGING_PVT.Log_Statement(
                        p_module_name      => g_module_name,
                        p_procedure_name   => l_program_name,
                        p_debug_info       => l_debug_info) ;
                    INL_LOGGING_PVT.Log_Variable(
                        p_module_name    => g_module_name,
                        p_procedure_name => l_program_name,
                        p_var_name       => 'current_SLnGr_rec.ship_line_group_id',
                        p_var_value      => current_SLnGr_rec.ship_line_group_id) ;
                    INSERT INTO inl_ship_line_groups (
                        ship_line_group_id,                          --01
                        ship_line_group_reference,                   --02
                        ship_header_id,                              --03
                        ship_line_group_num,                         --04
                        src_type_code,                               --05
                        party_id,                                    --06
                        party_site_id,                               --07
                        source_organization_id,                      --08
                        ship_line_int_id,                            --09
                        interface_source_table,                      --10
                        interface_source_line_id,                    --11
                        created_by,                                  --12
                        creation_date,                               --13
                        last_updated_by,                             --14
                        last_update_date,                            --15
                        last_update_login,                           --16
                        program_id,                                  --17
                        program_update_date,                         --18
                        program_application_id,                      --19
                        request_id,                                  --20
                        attribute_category,                          --21
                        attribute1,                                  --22
                        attribute2,                                  --23
                        attribute3,                                  --24
                        attribute4,                                  --25
                        attribute5,                                  --26
                        attribute6,                                  --27
                        attribute7,                                  --28
                        attribute8,                                  --29
                        attribute9,                                  --30
                        attribute10,                                 --31
                        attribute11,                                 --32
                        attribute12,                                 --33
                        attribute13,                                 --34
                        attribute14,                                 --35
                        attribute15                                  --36
                        )
                    VALUES
                       (
                        x_ship_ln_int_rec.ship_line_group_id       , --01
                        x_ship_ln_int_rec.ship_line_group_reference, --02
                        x_ship_ln_int_rec.ship_header_id           , --03
                        current_SLnGr_rec.ship_line_group_num   , --04
                        current_SLnGr_rec.src_type_code         , --05
                        current_SLnGr_rec.party_id              , --06
                        current_SLnGr_rec.party_site_id         , --07
                        current_SLnGr_rec.source_organization_id, --08
                        x_ship_ln_int_rec.ship_line_int_id         , --09
                        x_ship_ln_int_rec.interface_source_table   , --10
                        x_ship_ln_int_rec.interface_source_line_id , --11
                        L_FND_USER_ID                              , --12
                        SYSDATE                                    , --13
                        L_FND_USER_ID                              , --14
                        SYSDATE                                    , --15
                        L_FND_LOGIN_ID                             , --16
                        L_FND_CONC_PROGRAM_ID                      , --17
                        SYSDATE                                    , --18
                        L_FND_PROG_APPL_ID                         , --19
                        L_FND_CONC_REQUEST_ID                      , --20
                        x_ship_ln_int_rec .attribute_category_lg   , --21
                        x_ship_ln_int_rec .attribute1_lg           , --22
                        x_ship_ln_int_rec .attribute2_lg           , --23
                        x_ship_ln_int_rec .attribute3_lg           , --24
                        x_ship_ln_int_rec .attribute4_lg           , --25
                        x_ship_ln_int_rec .attribute5_lg           , --26
                        x_ship_ln_int_rec .attribute6_lg           , --27
                        x_ship_ln_int_rec .attribute7_lg           , --28
                        x_ship_ln_int_rec .attribute8_lg           , --29
                        x_ship_ln_int_rec .attribute9_lg           , --30
                        x_ship_ln_int_rec .attribute10_lg          , --31
                        x_ship_ln_int_rec .attribute11_lg          , --32
                        x_ship_ln_int_rec .attribute12_lg          , --33
                        x_ship_ln_int_rec .attribute13_lg          , --34
                        x_ship_ln_int_rec .attribute14_lg          , --35
                        x_ship_ln_int_rec .attribute15_lg            --36
                      );
            END;
        ELSE
           INL_LOGGING_PVT.Log_Variable(
                p_module_name    => g_module_name,
                p_procedure_name => l_program_name,
                p_var_name       => 'current_SLnGr_rec.ship_line_group_id',
                p_var_value      => current_SLnGr_rec.ship_line_group_id) ;

           x_ship_ln_int_rec.ship_line_group_id        := current_SLnGr_rec.ship_line_group_id;

        END IF;
    ELSIF p_transaction_type = 'UPDATE' THEN

        l_debug_info    := 'Updating Ship Line Group';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info) ;

        UPDATE inl_ship_line_groups
        SET
            ship_line_group_reference  = NVL(x_ship_ln_int_rec.ship_line_group_reference,ship_line_group_reference),
            ship_line_int_id           = NVL(x_ship_ln_int_rec.ship_line_int_id         ,ship_line_int_id        ),
            interface_source_table     = NVL(x_ship_ln_int_rec.interface_source_table   ,interface_source_table  ),
            interface_source_line_id   = NVL(x_ship_ln_int_rec.interface_source_line_id ,interface_source_line_id),
            last_updated_by            = L_FND_USER_ID,
            last_update_date           = SYSDATE,
            last_update_login          = L_FND_LOGIN_ID,
            program_id                 = L_FND_CONC_PROGRAM_ID,
            program_update_date        = SYSDATE,
            program_application_id     = L_FND_PROG_APPL_ID,
            request_id                 = L_FND_CONC_REQUEST_ID,
            attribute_category         = NVL(x_ship_ln_int_rec.attribute_category_lg    ,attribute_category      ),
            attribute1                 = NVL(x_ship_ln_int_rec.attribute1_lg            ,attribute1              ),
            attribute2                 = NVL(x_ship_ln_int_rec.attribute2_lg            ,attribute2              ),
            attribute3                 = NVL(x_ship_ln_int_rec.attribute3_lg            ,attribute3              ),
            attribute4                 = NVL(x_ship_ln_int_rec.attribute4_lg            ,attribute4              ),
            attribute5                 = NVL(x_ship_ln_int_rec.attribute5_lg            ,attribute5              ),
            attribute6                 = NVL(x_ship_ln_int_rec.attribute6_lg            ,attribute6              ),
            attribute7                 = NVL(x_ship_ln_int_rec.attribute7_lg            ,attribute7              ),
            attribute8                 = NVL(x_ship_ln_int_rec.attribute8_lg            ,attribute8              ),
            attribute9                 = NVL(x_ship_ln_int_rec.attribute9_lg            ,attribute9              ),
            attribute10                = NVL(x_ship_ln_int_rec.attribute10_lg           ,attribute10             ),
            attribute11                = NVL(x_ship_ln_int_rec.attribute11_lg           ,attribute11             ),
            attribute12                = NVL(x_ship_ln_int_rec.attribute12_lg           ,attribute12             ),
            attribute13                = NVL(x_ship_ln_int_rec.attribute13_lg           ,attribute13             ),
            attribute14                = NVL(x_ship_ln_int_rec.attribute14_lg           ,attribute14             ),
            attribute15                = NVL(x_ship_ln_int_rec.attribute15_lg           ,attribute15             )
        WHERE ship_line_group_id = x_ship_ln_int_rec.ship_line_group_id
        ;
    END IF;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        x_return_status := L_FND_RET_STS_ERROR;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name
            );
        END IF;
END Handle_LineGroups;

-- Utility name : Run_ProcesstAction
-- Type       : Private
-- Function   : Set Shipment action
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_header_id IN NUMBER
--              p_last_task_code IN NUMBER
--
-- OUT        : x_return_status  OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Run_ProcessAction(p_ship_header_id IN NUMBER,
                            p_last_task_code IN NUMBER,
                            x_return_status  OUT NOCOPY VARCHAR2) IS

    l_program_name        CONSTANT VARCHAR2(100) := 'Run_ProcessAction';
    l_debug_info       VARCHAR2(2000);
    l_return_status    VARCHAR2(1);
    l_init_msg_list    VARCHAR2(2000) := L_FND_FALSE;
    l_commit           VARCHAR2(1)    := L_FND_FALSE;
    l_validation_level NUMBER         := L_FND_VALID_LEVEL_FULL;
    l_msg_data         VARCHAR2(2000) ;
    l_msg_count        NUMBER;

BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name) ;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;

    INL_LOGGING_PVT.Log_Variable(
                    p_module_name    => g_module_name,
                    p_procedure_name => l_program_name,
                    p_var_name       => 'p_ship_header_id',
                    p_var_value      => p_ship_header_id);

    INL_LOGGING_PVT.Log_Variable(
                    p_module_name    => g_module_name,
                    p_procedure_name => l_program_name,
                    p_var_name       => 'p_last_task_code',
                    p_var_value      => p_last_task_code);

    -- Generate Charges and Integration with QP
    IF p_last_task_code >= '20' THEN
        l_debug_info    := 'Generate Charges(Integration with QP). Call INL_CHARGE_PVT.Generate_Charges';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);

        INL_CHARGE_PVT.Generate_Charges(
            p_api_version    => 1.0,
            p_init_msg_list  => l_init_msg_list,
            p_commit         => l_commit,
            p_ship_header_id => p_ship_header_id,
            x_return_status  => l_return_status,
            x_msg_count      => l_msg_count,
            x_msg_data       => l_msg_data) ;
        -- If any errors happen abort the process.
        -- Bug #8304106
        IF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;

    END IF;
    -- Process LCM Shipment Actions
    IF p_last_task_code >= '30' THEN
        l_debug_info  := 'Call INL_SHIPMENT_PVT.ProcessAction';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_debug_info     => l_debug_info);

        INL_SHIPMENT_PVT.ProcessAction(
            p_api_version => 1.0,
            p_init_msg_list => l_init_msg_list,
            p_commit => l_commit,
            p_ship_header_id => p_ship_header_id,
            p_task_code => p_last_task_code,
            p_caller => 'C',  -- SCM-051
            x_return_status => l_return_status,
            x_msg_count => l_msg_count,
            x_msg_data => l_msg_data
        );

        -- If any errors happen abort the process.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);

EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        x_return_status := L_FND_RET_STS_ERROR;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name);
        END IF;
END Run_ProcessAction;


-- Utility name : Import_Lines
-- Type       : Private
-- Function   : Import Shipment Lines from the Interface table
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_transaction_type      IN VARCHAR2,
--              p_ship_header_int_id    IN NUMBER,
--              p_ship_header_id        IN NUMBER,
--
-- OUT        : x_ship_ln_int_lst       IN OUT NOCOPY ship_ln_int_list_type
--              x_return_status  OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Import_Lines (
    p_transaction_type      IN VARCHAR2,
    p_ship_header_int_id    IN NUMBER,
    p_ship_header_id        IN NUMBER,
    x_ship_ln_int_lst       IN OUT NOCOPY ship_ln_int_list_type,
    x_return_status            OUT NOCOPY VARCHAR2) IS

    l_program_name CONSTANT VARCHAR2(100) := 'Import_Lines';

    l_debug_info         VARCHAR2(2000);
    l_return_status      VARCHAR2(1);

BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name) ;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;

    l_debug_info := 'Processing Lines, p_transaction_type: '||p_transaction_type;
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info) ;

    FOR l_ship_ln_int_idx IN 1 .. x_ship_ln_int_lst.COUNT
    LOOP
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_ship_ln_int_lst(l_ship_ln_int_idx).ship_Line_int_id',
            p_var_value      => x_ship_ln_int_lst(l_ship_ln_int_idx).ship_Line_int_id) ;

        x_ship_ln_int_lst(l_ship_ln_int_idx).ship_header_id := p_ship_header_id;

        l_debug_info := 'Handle Import of Shipment Line Groups';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);
        -- Check if the Line Group has already been imported
        Handle_LineGroups(
            p_transaction_type  => p_transaction_type,
            x_ship_ln_int_rec   => x_ship_ln_int_lst(l_ship_ln_int_idx),
            x_return_status     => l_return_status)
        ;

        -- If any errors happen abort API.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;

        IF p_transaction_type = 'CREATE'
        THEN

            l_debug_info := 'Getting the next Shipment Line Number';
            INL_LOGGING_PVT.Log_Statement(
                p_module_name      => g_module_name,
                p_procedure_name   => l_program_name,
                p_debug_info       => l_debug_info);

            IF x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_num IS NULL THEN
                -- Get the next Ship Line Number
                 SELECT MAX(ship_line_num)
                   INTO x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_num
                   FROM inl_ship_lines_all
                  WHERE ship_header_id = x_ship_ln_int_lst(l_ship_ln_int_idx).ship_header_id
                    AND ship_line_group_id = x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_group_id;

                x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_num := NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_num, 0) + 1;

                INL_LOGGING_PVT.Log_Variable(
                    p_module_name    => g_module_name,
                    p_procedure_name => l_program_name,
                    p_var_name       => 'x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_num',
                    p_var_value      => x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_num) ;
            END IF;
            l_debug_info  := 'Getting Shipment Line Id';
            INL_LOGGING_PVT.Log_Statement(
                p_module_name      => g_module_name,
                p_procedure_name   => l_program_name,
                p_debug_info       => l_debug_info) ;
            -- Get the next Shipment Line Id
            SELECT inl_ship_Lines_all_s.NEXTVAL
            INTO x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_id
            FROM dual;

            INL_LOGGING_PVT.Log_Variable(
                p_module_name    => g_module_name,
                p_procedure_name => l_program_name,
                p_var_name       => 'ship_line_id',
                p_var_value      => x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_id);

            l_debug_info := 'Insert into Shipment Lines table';
            INL_LOGGING_PVT.Log_Statement(
                p_module_name      => g_module_name,
                p_procedure_name   => l_program_name,
                p_debug_info       => l_debug_info);

            --  Insert an INL SHIP LINE record
            INSERT INTO inl_ship_lines_all (
                ship_header_id,                                                --01
                ship_line_group_id,                                            --02
                ship_line_id,                                                  --03
                ship_line_num,                                                 --04
                ship_line_type_id,                                             --05
                ship_line_src_type_code,                                       --06
                ship_line_source_id,                                           --07
                parent_ship_line_id,                                           --08
                adjustment_num,                                                --09
                match_id,                                                      --10
                currency_code,                                                 --12
                currency_conversion_type,                                      --13
                currency_conversion_date,                                      --14
                currency_conversion_rate,                                      --15
                inventory_item_id,                                             --16
                txn_qty,                                                       --17
                txn_uom_code,                                                  --18
                txn_unit_price,                                                --19
                primary_qty,                                                   --20
                primary_uom_code,                                              --21
                primary_unit_price,                                            --22
                secondary_qty,                                                 --23
                secondary_uom_code,                                            --24
                secondary_unit_price,                                          --25
                landed_cost_flag,                                              --30
                allocation_enabled_flag,                                       --31
                trx_business_category,                                         --32
                intended_use,                                                  --33
                product_fiscal_class,                                          --34
                product_category,                                              --35
                product_type,                                                  --36
                user_def_fiscal_class,                                         --37
                tax_classification_code,                                       --38
                assessable_value,                                              --39
                tax_already_calculated_flag,                                   --40
                ship_from_party_id,                                            --41
                ship_from_party_site_id,                                       --42
                ship_to_organization_id,                                       --43
                ship_to_location_id,                                           --44
                bill_from_party_id,                                            --45
                bill_from_party_site_id,                                       --46
                bill_to_organization_id,                                       --47
                bill_to_location_id,                                           --48
                poa_party_id,                                                  --49
                poa_party_site_id,                                             --50
                poo_organization_id,                                           --51
                poo_location_id,                                               --52
                org_id,                                                        --53
                ship_line_int_id,                                              --54
                interface_source_table,                                        --55
                interface_source_line_id,                                      --56
                created_by,                                                    --57
                creation_date,                                                 --58
                last_updated_by,                                               --59
                last_update_date,                                              --60
                last_update_login,                                             --61
                program_id,                                                    --62
                program_update_date,                                           --63
                program_application_id,                                        --64
                request_id,                                                    --65
                attribute_category,                                            --66
                attribute1,                                                    --67
                attribute2,                                                    --68
                attribute3,                                                    --69
                attribute4,                                                    --70
                attribute5,                                                    --71
                attribute6,                                                    --72
                attribute7,                                                    --73
                attribute8,                                                    --74
                attribute9,                                                    --75
                attribute10,                                                   --76
                attribute11,                                                   --77
                attribute12,                                                   --78
                attribute13,                                                   --79
                attribute14,                                                   --80
                attribute15                                                    --81
                )
            VALUES
                (
                x_ship_ln_int_lst(l_ship_ln_int_idx).ship_header_id,           --01
                x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_group_id,       --02
                x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_id,             --03
                x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_num,            --04
                x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_type_id,        --05
                x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_src_type_code,  --06
                x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_source_id,      --07
                NULL,                                                          --08
                0,                                                             --09
                NULL,                                                          --10
                x_ship_ln_int_lst(l_ship_ln_int_idx).currency_code,            --12
                x_ship_ln_int_lst(l_ship_ln_int_idx).currency_conversion_type, --13
                x_ship_ln_int_lst(l_ship_ln_int_idx).currency_conversion_date, --14
                x_ship_ln_int_lst(l_ship_ln_int_idx).currency_conversion_rate, --15
                x_ship_ln_int_lst(l_ship_ln_int_idx).inventory_item_id,        --16
                x_ship_ln_int_lst(l_ship_ln_int_idx).txn_qty,                  --17
                x_ship_ln_int_lst(l_ship_ln_int_idx).txn_uom_code,             --18
                x_ship_ln_int_lst(l_ship_ln_int_idx).txn_unit_price,           --19
                x_ship_ln_int_lst(l_ship_ln_int_idx).primary_qty,              --20
                x_ship_ln_int_lst(l_ship_ln_int_idx).primary_uom_code,         --21
                x_ship_ln_int_lst(l_ship_ln_int_idx).primary_unit_price,       --22
                x_ship_ln_int_lst(l_ship_ln_int_idx).secondary_qty,            --23
                x_ship_ln_int_lst(l_ship_ln_int_idx).secondary_uom_code,       --24
                x_ship_ln_int_lst(l_ship_ln_int_idx).secondary_unit_price,     --25
                x_ship_ln_int_lst(l_ship_ln_int_idx).landed_cost_flag,         --30
                x_ship_ln_int_lst(l_ship_ln_int_idx).allocation_enabled_flag,  --31
                x_ship_ln_int_lst(l_ship_ln_int_idx).trx_business_category,    --32
                x_ship_ln_int_lst(l_ship_ln_int_idx).intended_use,             --33
                x_ship_ln_int_lst(l_ship_ln_int_idx).product_fiscal_class,     --34
                x_ship_ln_int_lst(l_ship_ln_int_idx).product_category,         --35
                x_ship_ln_int_lst(l_ship_ln_int_idx).product_type,             --36
                x_ship_ln_int_lst(l_ship_ln_int_idx).user_def_fiscal_class,    --37
                x_ship_ln_int_lst(l_ship_ln_int_idx).tax_classification_code,  --38
                x_ship_ln_int_lst(l_ship_ln_int_idx).assessable_value,         --39
                'N',                                                           --40
                x_ship_ln_int_lst(l_ship_ln_int_idx).ship_from_party_id,       --41
                x_ship_ln_int_lst(l_ship_ln_int_idx).ship_from_party_site_id,  --42
                x_ship_ln_int_lst(l_ship_ln_int_idx).ship_to_organization_id,  --43
                x_ship_ln_int_lst(l_ship_ln_int_idx).ship_to_location_id,      --44
                x_ship_ln_int_lst(l_ship_ln_int_idx).bill_from_party_id,       --45
                x_ship_ln_int_lst(l_ship_ln_int_idx).bill_from_party_site_id,  --46
                x_ship_ln_int_lst(l_ship_ln_int_idx).bill_to_organization_id,  --47
                x_ship_ln_int_lst(l_ship_ln_int_idx).bill_to_location_id,      --48
                x_ship_ln_int_lst(l_ship_ln_int_idx).poa_party_id,             --49
                x_ship_ln_int_lst(l_ship_ln_int_idx).poa_party_site_id,        --50
                x_ship_ln_int_lst(l_ship_ln_int_idx).poo_organization_id,      --51
                x_ship_ln_int_lst(l_ship_ln_int_idx).poo_location_id,          --52
                x_ship_ln_int_lst(l_ship_ln_int_idx).org_id,                   --53
                x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_int_id,         --54
                x_ship_ln_int_lst(l_ship_ln_int_idx).interface_source_table,   --55
                x_ship_ln_int_lst(l_ship_ln_int_idx).interface_source_line_id, --56
                L_FND_USER_ID,                                                 --57
                SYSDATE,                                                       --58
                L_FND_USER_ID,                                                 --59
                SYSDATE,                                                       --60
                L_FND_LOGIN_ID,                                                --61
                L_FND_CONC_PROGRAM_ID,                                         --62
                SYSDATE,                                                       --63
                L_FND_PROG_APPL_ID,                                            --64
                L_FND_CONC_REQUEST_ID,                                         --65
                x_ship_ln_int_lst(l_ship_ln_int_idx).attribute_category_sl,    --66
                x_ship_ln_int_lst(l_ship_ln_int_idx).attribute1_sl,            --67
                x_ship_ln_int_lst(l_ship_ln_int_idx).attribute2_sl,            --68
                x_ship_ln_int_lst(l_ship_ln_int_idx).attribute3_sl,            --69
                x_ship_ln_int_lst(l_ship_ln_int_idx).attribute4_sl,            --70
                x_ship_ln_int_lst(l_ship_ln_int_idx).attribute5_sl,            --71
                x_ship_ln_int_lst(l_ship_ln_int_idx).attribute6_sl,            --72
                x_ship_ln_int_lst(l_ship_ln_int_idx).attribute7_sl,            --73
                x_ship_ln_int_lst(l_ship_ln_int_idx).attribute8_sl,            --74
                x_ship_ln_int_lst(l_ship_ln_int_idx).attribute9_sl,            --75
                x_ship_ln_int_lst(l_ship_ln_int_idx).attribute10_sl,           --76
                x_ship_ln_int_lst(l_ship_ln_int_idx).attribute11_sl,           --77
                x_ship_ln_int_lst(l_ship_ln_int_idx).attribute12_sl,           --78
                x_ship_ln_int_lst(l_ship_ln_int_idx).attribute13_sl,           --79
                x_ship_ln_int_lst(l_ship_ln_int_idx).attribute14_sl,           --80
                x_ship_ln_int_lst(l_ship_ln_int_idx).attribute15_sl            --81
                ) ;
        ELSIF p_transaction_type = 'UPDATE' THEN
            l_debug_info := 'Update Shipment Lines table';
            INL_LOGGING_PVT.Log_Statement(
                p_module_name      => g_module_name,
                p_procedure_name   => l_program_name,
                p_debug_info       => l_debug_info) ;

            --  update the INL SHIP LINE record
            UPDATE inl_ship_lines_all sl
            SET adjustment_num           = 0,
                match_id                 = NULL,
                txn_qty                  = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).txn_qty                   , sl.txn_qty)                 ,
                txn_uom_code             = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).txn_uom_code              , sl.txn_uom_code)            ,
                txn_unit_price           = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).txn_unit_price            , sl.txn_unit_price)          ,
                primary_qty              = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).primary_qty               , sl.primary_qty)             ,
                primary_uom_code         = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).primary_uom_code          , sl.primary_uom_code)        ,
                primary_unit_price       = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).primary_unit_price        , sl.primary_unit_price)      ,
                secondary_qty            = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).secondary_qty             , sl.secondary_qty)           ,
                secondary_uom_code       = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).secondary_uom_code        , sl.secondary_uom_code)      ,
                secondary_unit_price     = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).secondary_unit_price      , sl.secondary_unit_price)    ,
                landed_cost_flag         = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).landed_cost_flag          , sl.landed_cost_flag)        ,
                allocation_enabled_flag  = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).allocation_enabled_flag   , sl.allocation_enabled_flag) ,
                trx_business_category    = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).trx_business_category     , sl.trx_business_category)   ,
                intended_use             = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).intended_use              , sl.intended_use)            ,
                product_fiscal_class     = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).product_fiscal_class      , sl.product_fiscal_class)    ,
                product_category         = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).product_category          , sl.product_category)        ,
                product_type             = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).product_type              , sl.product_type)            ,
                user_def_fiscal_class    = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).user_def_fiscal_class     , sl.user_def_fiscal_class)   ,
                tax_classification_code  = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).tax_classification_code   , sl.tax_classification_code) ,
                assessable_value         = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).assessable_value          , sl.assessable_value)        ,
                ship_from_party_id       = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).ship_from_party_id        , sl.ship_from_party_id)      ,
                ship_from_party_site_id  = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).ship_from_party_site_id   , sl.ship_from_party_site_id) ,
                ship_to_organization_id  = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).ship_to_organization_id   , sl.ship_to_organization_id) ,
                ship_to_location_id      = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).ship_to_location_id       , sl.ship_to_location_id)     ,
                bill_from_party_id       = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).bill_from_party_id        , sl.bill_from_party_id)      ,
                bill_from_party_site_id  = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).bill_from_party_site_id   , sl.bill_from_party_site_id) ,
                bill_to_organization_id  = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).bill_to_organization_id   , sl.bill_to_organization_id) ,
                bill_to_location_id      = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).bill_to_location_id       , sl.bill_to_location_id)     ,
                poa_party_id             = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).poa_party_id              , sl.poa_party_id)            ,
                poa_party_site_id        = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).poa_party_site_id         , sl.poa_party_site_id)       ,
                poo_organization_id      = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).poo_organization_id       , sl.poo_organization_id)     ,
                poo_location_id          = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).poo_location_id           , sl.poo_location_id)         ,
                org_id                   = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).org_id           , sl.org_id)                           , --NVL(p_org_id,org_id)
                ship_line_int_id         = x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_int_id                                            ,
                interface_source_table   = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).interface_source_table    , sl.interface_source_table)  ,
                interface_source_line_id = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).interface_source_line_id  , sl.interface_source_line_id),
                last_updated_by          = L_FND_USER_ID                                                                                    ,
                last_update_date         = SYSDATE                                                                                          ,
                last_update_login        = L_FND_LOGIN_ID                                                                                   ,
                program_id               = L_FND_CONC_PROGRAM_ID                                                                            ,
                program_update_date      = SYSDATE                                                                                          ,
                program_application_id   = L_FND_PROG_APPL_ID                                                                               ,
                request_id               = L_FND_CONC_REQUEST_ID                                                                            ,
                attribute_category       = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).attribute_category_sl     , sl.attribute_category)      ,
                attribute1               = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).attribute1_sl             , sl.attribute1)              ,
                attribute2               = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).attribute2_sl             , sl.attribute2)              ,
                attribute3               = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).attribute3_sl             , sl.attribute3)              ,
                attribute4               = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).attribute4_sl             , sl.attribute4)              ,
                attribute5               = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).attribute5_sl             , sl.attribute5)              ,
                attribute6               = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).attribute6_sl             , sl.attribute6)              ,
                attribute7               = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).attribute7_sl             , sl.attribute7)              ,
                attribute8               = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).attribute8_sl             , sl.attribute8)              ,
                attribute9               = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).attribute9_sl             , sl.attribute9)              ,
                attribute10              = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).attribute10_sl            , sl.attribute10)             ,
                attribute11              = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).attribute11_sl            , sl.attribute11)             ,
                attribute12              = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).attribute12_sl            , sl.attribute12)             ,
                attribute13              = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).attribute13_sl            , sl.attribute13)             ,
                attribute14              = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).attribute14_sl            , sl.attribute14)             ,
                attribute15              = NVL(x_ship_ln_int_lst(l_ship_ln_int_idx).attribute15_sl            , sl.attribute15)
            WHERE ship_line_id = x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_id;
        END IF;
        l_debug_info  := 'Set Shipment Line Interface status and imported Ids';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_debug_info     => l_debug_info) ;
        -- Set processing status code to COMPLETED
        -- for a given and imported Shipment Line
        UPDATE inl_ship_lines_int
        SET processing_status_code = 'COMPLETED'                                             ,
            ship_header_id         = x_ship_ln_int_lst(l_ship_ln_int_idx).ship_header_id     ,
            ship_line_group_id     = x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_group_id ,
            ship_line_id           = x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_id       ,
            request_id             = L_FND_CONC_REQUEST_ID                                   ,
            last_updated_by        = L_FND_USER_ID                                           ,
            last_update_date       = SYSDATE                                                 ,
            last_update_login      = L_FND_LOGIN_ID                                          ,
            program_id             = L_FND_CONC_PROGRAM_ID                                   ,
            program_update_date    = SYSDATE                                                 ,
            program_application_id = L_FND_PROG_APPL_ID
        WHERE ship_line_int_id     = x_ship_ln_int_lst(l_ship_ln_int_idx).ship_line_int_id   ;
    END LOOP;

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        x_return_status := L_FND_RET_STS_ERROR;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name);
        END IF;
END Import_Lines;

-- Utility name : Import_Headers
-- Type       : Private
-- Function   : Import Shipment Headers from Interface
--              table to INL_SHIP_HEADERS_ALL
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_simulation_id    IN            NUMBER,
--
--
-- OUT        : x_ship_hdr_int_rec IN OUT NOCOPY c_ship_hdr_int%ROWTYPE,
--              x_return_status       OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Import_Headers (
    p_simulation_id    IN            NUMBER,
    x_ship_hdr_int_rec IN OUT NOCOPY c_ship_hdr_int%ROWTYPE,
    x_return_status       OUT NOCOPY VARCHAR2) IS

    l_user_defined_ship_num_code VARCHAR2(30) ;
    l_next_ship_num              NUMBER;
    l_ship_num                   VARCHAR2(25);
    l_program_name                  CONSTANT VARCHAR2(100) := 'Import_Headers';
    l_debug_info                 VARCHAR2(2000);
    l_return_status              VARCHAR2(1);
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name) ;

    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'ship_header_int_id',
        p_var_value      => x_ship_hdr_int_rec.ship_header_int_id) ;

    IF x_ship_hdr_int_rec.transaction_type = 'DELETE' THEN
        IF x_ship_hdr_int_rec.last_task_code > 10 THEN --Bug#11794483C
            Delete_Ship(
                p_ship_header_id => x_ship_hdr_int_rec.ship_header_id,
                x_return_status  => l_return_status);
            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
    ELSIF x_ship_hdr_int_rec.transaction_type = 'UPDATE' THEN
        l_debug_info  := 'Updating the Shipment Header';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info) ;

        UPDATE inl_ship_headers_all sh --Bug#10381495
        SET ship_date                = NVL(x_ship_hdr_int_rec.ship_date               ,sh.ship_date               ),
            taxation_country         = NVL(x_ship_hdr_int_rec.taxation_country        ,sh.taxation_country        ),
            document_sub_type        = NVL(x_ship_hdr_int_rec.document_sub_type       ,sh.document_sub_type       ),
            ship_header_int_id       = NVL(x_ship_hdr_int_rec.ship_header_int_id      ,sh.ship_header_int_id      ),
            interface_source_code    = NVL(x_ship_hdr_int_rec.interface_source_code   ,sh.interface_source_code   ),
            interface_source_table   = NVL(x_ship_hdr_int_rec.interface_source_table  ,sh.interface_source_table  ),
            interface_source_line_id = NVL(x_ship_hdr_int_rec.interface_source_line_id,sh.interface_source_line_id),
            simulation_id            = NVL(p_simulation_id                            ,sh.simulation_id           ),  -- Bug#9279355
            ship_status_code         = 'VALIDATION REQ'                                                            ,
            last_updated_by          = L_FND_USER_ID                                                               ,
            last_update_date         = SYSDATE                                                                     ,
            last_update_login        = L_FND_LOGIN_ID                                                              ,
            program_id               = L_FND_CONC_PROGRAM_ID                                                       ,
            program_update_date      = SYSDATE                                                                     ,
            program_application_id   = L_FND_PROG_APPL_ID                                                          ,
            request_id               = L_FND_CONC_REQUEST_ID                                                       ,
            attribute_category       = NVL(x_ship_hdr_int_rec.attribute_category      ,sh.attribute_category      ),
            attribute1               = NVL(x_ship_hdr_int_rec.attribute1              ,sh.attribute1              ),
            attribute2               = NVL(x_ship_hdr_int_rec.attribute2              ,sh.attribute2              ),
            attribute3               = NVL(x_ship_hdr_int_rec.attribute3              ,sh.attribute3              ),
            attribute4               = NVL(x_ship_hdr_int_rec.attribute4              ,sh.attribute4              ),
            attribute5               = NVL(x_ship_hdr_int_rec.attribute5              ,sh.attribute5              ),
            attribute6               = NVL(x_ship_hdr_int_rec.attribute6              ,sh.attribute6              ),
            attribute7               = NVL(x_ship_hdr_int_rec.attribute7              ,sh.attribute7              ),
            attribute8               = NVL(x_ship_hdr_int_rec.attribute8              ,sh.attribute8              ),
            attribute9               = NVL(x_ship_hdr_int_rec.attribute9              ,sh.attribute9              ),
            attribute10              = NVL(x_ship_hdr_int_rec.attribute10             ,sh.attribute10             ),
            attribute11              = NVL(x_ship_hdr_int_rec.attribute11             ,sh.attribute11             ),
            attribute12              = NVL(x_ship_hdr_int_rec.attribute12             ,sh.attribute12             ),
            attribute13              = NVL(x_ship_hdr_int_rec.attribute13             ,sh.attribute13             ),
            attribute14              = NVL(x_ship_hdr_int_rec.attribute14             ,sh.attribute14             ),
            attribute15              = NVL(x_ship_hdr_int_rec.attribute15             ,sh.attribute15)
        WHERE ship_header_id       = x_ship_hdr_int_rec .ship_header_id;
    ELSIF x_ship_hdr_int_rec.transaction_type = 'CREATE' THEN
        l_debug_info  := 'Check if Shipment Number setup is AUTOMATIC or MANUAL';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info) ;
        --  Check if Shipment Number is setup as(AUTOMATIC or MANUAL)
        SELECT user_defined_ship_num_code,
               next_ship_num,
               inl_ship_headers_all_s.NEXTVAL
        INTO l_user_defined_ship_num_code,
             l_next_ship_num,
             x_ship_hdr_int_rec.ship_header_id
        FROM inl_parameters
        WHERE organization_id = x_ship_hdr_int_rec.organization_id
        FOR UPDATE OF next_ship_num;

        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'l_user_defined_ship_num_code',
            p_var_value      => l_user_defined_ship_num_code) ;

        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'l_next_ship_num',
            p_var_value      => l_next_ship_num) ;

        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'x_ship_hdr_int_rec.ship_header_id',
            p_var_value      => x_ship_hdr_int_rec.ship_header_id) ;

        l_debug_info := 'Setting the next Shipment Number in INL_PARAMETERS';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info) ;

        IF l_user_defined_ship_num_code = 'AUTOMATIC'
            AND p_simulation_id IS NULL
        THEN -- Bug #9279355
            l_ship_num  := l_next_ship_num;
            UPDATE inl_parameters
            SET next_ship_num              = l_next_ship_num + 1,
                last_updated_by            = L_FND_USER_ID ,
                last_update_date           = SYSDATE            ,
                last_update_login          = L_FND_LOGIN_ID
              WHERE organization_id        = x_ship_hdr_int_rec.organization_id;
        ELSIF l_user_defined_ship_num_code = 'MANUAL' THEN
            l_ship_num   := x_ship_hdr_int_rec.ship_num;
            l_debug_info := 'Ship Number is MANUAL: ' || l_ship_num;
            INL_LOGGING_PVT.Log_Statement(
                p_module_name      => g_module_name,
                p_procedure_name   => l_program_name,
                p_debug_info       => l_debug_info) ;
        ELSIF p_simulation_id IS NOT NULL THEN
            l_ship_num   := x_ship_hdr_int_rec.ship_num;
            l_debug_info := 'Ship Number for a Simulated Shipment: ' || l_ship_num;
            INL_LOGGING_PVT.Log_Statement(
                p_module_name      => g_module_name,
                p_procedure_name   => l_program_name,
                p_debug_info       => l_debug_info) ;
        END IF;

        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'l_ship_num',
            p_var_value      => l_ship_num) ;

        l_debug_info := 'Insert into Shipment Headers table';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info) ;

        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'rcv_enabled_flag',
            p_var_value      => x_ship_hdr_int_rec.rcv_enabled_flag);

        --  Insert an INL SHIP HEADER record
        INSERT
        INTO inl_ship_headers_all (                     --Bug#10381495
            ship_header_id                             ,-- 01
            ship_num                                   ,-- 02
            ship_date                                  ,-- 03
            ship_type_id                               ,-- 04
            ship_status_code                           ,-- 05
            pending_matching_flag                      ,-- 06
            rcv_enabled_flag                           ,-- 07
            legal_entity_id                            ,-- 08
            organization_id                            ,-- 09
            location_id                                ,-- 10
            org_id                                     ,-- 11
            taxation_country                           ,-- 12
            document_sub_type                          ,-- 13
            ship_header_int_id                         ,-- 14
            interface_source_code                      ,-- 15
            interface_source_table                     ,-- 16
            interface_source_line_id                   ,-- 17
            simulation_id                              ,-- 18  -- Bug#9279355
            adjustment_num                             ,-- 19
            created_by                                 ,-- 20
            creation_date                              ,-- 21
            last_updated_by                            ,-- 22
            last_update_date                           ,-- 23
            last_update_login                          ,-- 24
            program_id                                 ,-- 25
            program_update_date                        ,-- 26
            program_application_id                     ,-- 27
            request_id                                 ,-- 28
            attribute_category                         ,-- 29
            attribute1                                 ,-- 30
            attribute2                                 ,-- 31
            attribute3                                 ,-- 32
            attribute4                                 ,-- 33
            attribute5                                 ,-- 34
            attribute6                                 ,-- 35
            attribute7                                 ,-- 36
            attribute8                                 ,-- 37
            attribute9                                 ,-- 38
            attribute10                                ,-- 39
            attribute11                                ,-- 40
            attribute12                                ,-- 41
            attribute13                                ,-- 42
            attribute14                                ,-- 43
            attribute15                                 -- 44
        ) VALUES  (
            x_ship_hdr_int_rec.ship_header_id          ,--01
            l_ship_num                                 ,--02
            x_ship_hdr_int_rec.ship_date               ,--03
            x_ship_hdr_int_rec.ship_type_id            ,--04
            'INCOMPLETE'                               ,--05
            NULL                                       ,--06
            x_ship_hdr_int_rec.rcv_enabled_flag        ,--07
            x_ship_hdr_int_rec.legal_entity_id         ,--08
            x_ship_hdr_int_rec.organization_id         ,--09
            x_ship_hdr_int_rec.location_id             ,--10
            x_ship_hdr_int_rec.org_id                  ,--11
            x_ship_hdr_int_rec.taxation_country        ,--12
            x_ship_hdr_int_rec.document_sub_type       ,--13
            x_ship_hdr_int_rec.ship_header_int_id      ,--14
            x_ship_hdr_int_rec.interface_source_code   ,--15
            x_ship_hdr_int_rec.interface_source_table  ,--16
            x_ship_hdr_int_rec.interface_source_line_id,--17
            p_simulation_id                            ,--18 -- Bug#9279355
            0                                          ,--19
            L_FND_USER_ID                              ,--20
            SYSDATE                                    ,--21
            L_FND_USER_ID                              ,--22
            SYSDATE                                    ,--23
            L_FND_LOGIN_ID                             ,--24
            L_FND_CONC_PROGRAM_ID                      ,--25
            SYSDATE                                    ,--26
            L_FND_PROG_APPL_ID                         ,--27
            L_FND_CONC_REQUEST_ID                      ,--28
            x_ship_hdr_int_rec .attribute_category     ,--29
            x_ship_hdr_int_rec .attribute1             ,--30
            x_ship_hdr_int_rec .attribute2             ,--31
            x_ship_hdr_int_rec .attribute3             ,--32
            x_ship_hdr_int_rec .attribute4             ,--33
            x_ship_hdr_int_rec .attribute5             ,--34
            x_ship_hdr_int_rec .attribute6             ,--35
            x_ship_hdr_int_rec .attribute7             ,--36
            x_ship_hdr_int_rec .attribute8             ,--37
            x_ship_hdr_int_rec .attribute9             ,--38
            x_ship_hdr_int_rec .attribute10            ,--39
            x_ship_hdr_int_rec .attribute11            ,--40
            x_ship_hdr_int_rec .attribute12            ,--41
            x_ship_hdr_int_rec .attribute13            ,--42
            x_ship_hdr_int_rec .attribute14            ,--43
            x_ship_hdr_int_rec .attribute15             --44
        ) ;
    END IF;

    -- Bug 16310024
     x_ship_hdr_int_rec.ship_num := l_ship_num;

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        x_return_status := L_FND_RET_STS_ERROR;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name);
        END IF;
END Import_Headers;

-- Utility name : Set_existingMatchInfoFlag
-- Type       : Private
-- Function   : Import Match Lines
--
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_from_parent_table_name
--              p_from_parent_table_id
--              p_to_parent_table_name
--              p_to_parent_table_id
--
-- OUT        : x_existing_match_info_flag
--              x_parent_match_id
--              x_return_status
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Set_existingMatchInfoFlag(
    p_from_parent_table_name    IN VARCHAR2,
    p_from_parent_table_id      IN NUMBER,
    p_to_parent_table_name      IN VARCHAR2,
    p_to_parent_table_id        IN NUMBER,
    x_existing_match_info_flag  OUT NOCOPY VARCHAR2,
    x_parent_match_id           OUT NOCOPY NUMBER,
    x_return_status             OUT NOCOPY VARCHAR2
) IS
    l_program_name CONSTANT VARCHAR2(100) := 'Set_existingMatchInfoFlag';
    l_debug_info    VARCHAR2(2000) ;
    l_return_status VARCHAR2(1) ;
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name) ;
    -- Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;
    -- Include the lines with transaction_type = 'CREATE'
    l_debug_info := 'Deriving Existing_Match_Info_Flag';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name       => g_module_name,
        p_procedure_name    => l_program_name,
        p_debug_info        => l_debug_info
    ) ;
    SELECT MIN(match_id)
    INTO   x_parent_match_id
    FROM inl_matches
    WHERE to_parent_table_id = p_to_parent_table_id
    AND to_parent_table_name = p_to_parent_table_name
    AND from_parent_table_id = p_from_parent_table_id
    AND from_parent_table_name = p_from_parent_table_name
    ;
    IF x_parent_match_id IS NOT NULL THEN
        x_existing_match_info_flag:='Y';
    ELSE
        x_existing_match_info_flag:='N';
    END IF;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    );
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        x_return_status := L_FND_RET_STS_ERROR;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name
            );
        END IF;
END Set_existingMatchInfoFlag;

-- Utility name : Derive_FromAP
-- Type       : Private
-- Function   : Make AP derivation
--
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_from_parent_table_name  VARCHAR2,
--              p_from_parent_table_id    NUMBER,
--              p_match_type_code         VARCHAR2,
--
-- IN/OUT     : x_matched_amt                   NUMBER,
--              x_matched_qty                   NUMBER,
--              x_nrec_tax_amt                  NUMBER,
--              x_matched_uom_code              VARCHAR2,
--              x_new_to_parent_table_name      VARCHAR2,
--              x_new_to_parent_table_id        NUMBER,
--              x_matched_curr_code             VARCHAR2,
--              x_matched_curr_conversion_type  VARCHAR2,
--              x_matched_curr_conversion_date  DATE,
--              x_matched_curr_conversion_rate  NUMBER,
--              x_ship_header_id                NUMBER,
--              x_org_id                        NUMBER, --Bug#10381495
--
-- OUT        : x_existing_match_info_flag      VARCHAR2,
--              x_parent_match_id               NUMBER,
--              x_return_status                 VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      : When the information come from AP the amounts variations
--              are recorded in interface tables by the INL_MATCHES_GRP package
--              and the adjustment program wait for final amounts.
--              In order to equalize the information in this proc we:
--              - receive the values of the new match
PROCEDURE Derive_FromAP(
    p_from_parent_table_name        IN VARCHAR2,
    p_from_parent_table_id          IN NUMBER,
    p_match_type_code               IN VARCHAR2,
    x_matched_amt                   IN OUT NOCOPY NUMBER,
    x_matched_qty                   IN OUT NOCOPY NUMBER,
    x_nrec_tax_amt                  IN OUT NOCOPY NUMBER,
    x_matched_uom_code              IN OUT NOCOPY VARCHAR2,
    x_new_to_parent_table_name      IN OUT NOCOPY VARCHAR2,
    x_new_to_parent_table_id        IN OUT NOCOPY NUMBER,
    x_matched_curr_code             IN OUT NOCOPY VARCHAR2,
    x_matched_curr_conversion_type  IN OUT NOCOPY VARCHAR2,
    x_matched_curr_conversion_date  IN OUT NOCOPY DATE,
    x_matched_curr_conversion_rate  IN OUT NOCOPY NUMBER,
    x_ship_header_id                IN OUT NOCOPY NUMBER,
    x_org_id                        IN OUT NOCOPY NUMBER, --Bug#10381495
    x_existing_match_info_flag      OUT NOCOPY VARCHAR2,
    x_parent_match_id               OUT NOCOPY NUMBER,
    x_return_status                 OUT NOCOPY VARCHAR2
) IS
    l_program_name CONSTANT VARCHAR2(100) := 'Derive_FromAP';
    l_debug_info    VARCHAR2(2000) ;
    l_return_status VARCHAR2(1) ;

    l_inventory_item_id NUMBER;
    l_match_type VARCHAR2(30);
    l_line_type_lookup_code VARCHAR2(30);
    l_mat_curr_code_P VARCHAR2(30);
    l_mat_curr_rate_P NUMBER;
    l_mat_curr_type_P VARCHAR2(30);
    l_mat_curr_date_P DATE;
    l_mat_nrec_tax_amt_P NUMBER;
    l_mat_charge_line_type_id_P NUMBER;
    l_mat_qty_P NUMBER;
    l_mat_uom_code_P VARCHAR2(30);
    l_mat_amt_P NUMBER;
    l_mat_par_mat_id_P  NUMBER;
    l_ship_header_id_tab inl_int_table := inl_int_table() ;
    l_corr_from_parent_table_name VARCHAR2(30);
    l_corr_from_parent_table_id NUMBER;
    l_currency_conversion_rate NUMBER;

BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name) ;

    -- Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;
    -- Include the lines with transaction_type = 'CREATE'
    l_debug_info := 'Include the lines with transaction_type = CREATE';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name       => g_module_name,
        p_procedure_name    => l_program_name,
        p_debug_info        => l_debug_info
    ) ;
    IF x_new_to_parent_table_name = 'RCV_TRANSACTIONS' THEN
        x_new_to_parent_table_name := 'INL_SHIP_LINES';
        SELECT  lcm_shipment_line_id
        INTO x_new_to_parent_table_id
        FROM rcv_transactions rt
        WHERE rt.transaction_id = x_new_to_parent_table_id
        ;
    END IF;
    Set_existingMatchInfoFlag(
        p_from_parent_table_name    => p_from_parent_table_name,
        p_from_parent_table_id      => p_from_parent_table_id,
        p_to_parent_table_name      => x_new_to_parent_table_name,
        p_to_parent_table_id        => x_new_to_parent_table_id,
        x_existing_match_info_flag  => x_existing_match_info_flag,
        x_parent_match_id           => x_parent_match_id,
        x_return_status             => x_return_status
    );

     -- If any errors happen abort API.
    IF l_return_status = L_FND_RET_STS_ERROR THEN
        RAISE L_FND_EXC_ERROR;
    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
-- Migrated from matche_grp
    SELECT l.line_type_lookup_code,
           d.org_id,
           l.inventory_item_id,
           l.match_type
    INTO   l_line_type_lookup_code,
           x_org_id, --Bug#10381495
           l_inventory_item_id,
           l_match_type
    FROM   ap_invoice_distributions_all d, --Bug#10381495
           ap_invoice_lines_all l          --Bug#10381495
    WHERE  d.invoice_distribution_id = p_from_parent_table_id
    AND    d.invoice_id = l.invoice_id
    AND    d.invoice_line_number = l.line_number
    ;

    l_debug_info := 'Getting from inl_corr_matches_v the current value for transaction.';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_debug_info     => l_debug_info
    );

    IF p_match_type_code = 'CORRECTION'
    THEN
        l_debug_info := 'Is a correction. Type: '||l_match_type;
        INL_LOGGING_PVT.Log_Statement(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_debug_info     => l_debug_info) ;

        IF l_line_type_lookup_code = 'ITEM' THEN
            IF x_existing_match_info_flag = 'Y' THEN   -- RESUBMIT A CORRECTION
               -- select based on inl_corr_matches_v
                SELECT
                    mat1.matched_curr_code       ,
                    mat1.matched_curr_conversion_rate,
                    mat1.matched_curr_conversion_type,
                    mat1.matched_curr_conversion_date,
                    NULL nrec_tax_amt             ,
                    NULL charge_line_type_id      ,
                    mat1.matched_qty                ,
                    mat1.matched_uom_code           ,
                    NVL(DECODE(mat1.matched_curr_code, mat2.matched_curr_code, mat2.matched_amt,
                                                            inl_landedcost_pvt.Converted_Amt(
                                                                mat2.matched_amt,
                                                                mat2.matched_curr_code,
                                                                mat1.matched_curr_code,
                                                                mat1.matched_curr_conversion_type,
                                                                mat1.matched_curr_conversion_date))
                                                                , mat1.matched_amt) AS matched_amt,
                    mat1.match_id,
                    mat2.from_parent_table_name,
                    mat2.from_parent_table_id
                INTO
                    l_mat_curr_code_P          ,
                    l_mat_curr_rate_P          ,
                    l_mat_curr_type_P          ,
                    l_mat_curr_date_P          ,
                    l_mat_nrec_tax_amt_P       ,
                    l_mat_charge_line_type_id_P,
                    l_mat_qty_P                ,
                    l_mat_uom_code_P           ,
                    l_mat_amt_P                ,
                    l_mat_par_mat_id_P         ,
                    l_corr_from_parent_table_name,
                    l_corr_from_parent_table_id
                FROM
                    inl_matches mat1,
                    (select *
                       from inl_matches m2
                       where NOT (m2.from_parent_table_name = p_from_parent_table_name
                             AND m2.from_parent_table_id = p_from_parent_table_id)
                    ) mat2
                WHERE
                    mat2.parent_match_id (+) = mat1.match_id
                    AND mat2.match_type_code (+) = 'CORRECTION'
                    AND mat1.from_parent_table_name = x_new_to_parent_table_name
                    AND mat1.from_parent_table_id   = x_new_to_parent_table_id
                    AND mat1.match_id
                    =(
                        SELECT MAX(mat1B.match_id)
                        FROM inl_matches mat1B
                        WHERE mat1B.to_parent_table_name = mat1.to_parent_table_name
                        AND mat1B.to_parent_table_id     = mat1.to_parent_table_id
                        AND mat1B.from_parent_table_name = mat1.from_parent_table_name
                        AND mat1B.from_parent_table_id   = mat1.from_parent_table_id
                    )
                    AND (mat2.match_id is null
                         OR mat2.match_id = mat1.match_id
                         OR mat2.match_id
                        =(
                            SELECT MAX(DECODE(mat2.match_id, mat1.match_id, NULL, mat2.match_id))
                            FROM inl_matches mat1C,
                                 inl_matches mat2C
                            WHERE mat2C.parent_match_id (+) = mat1C.match_id
                            AND mat2C.match_type_code (+) = 'CORRECTION'
                            AND NOT (mat2C.from_parent_table_name = p_from_parent_table_name
                                     AND mat2C.from_parent_table_id = p_from_parent_table_id)
                            AND mat1C.from_parent_table_name = mat1.from_parent_table_name
                            AND mat1C.from_parent_table_id   = mat1.from_parent_table_id
                         ))
                ;
            ELSE
                l_corr_from_parent_table_name := NULL;
                l_corr_from_parent_table_id := NULL;
                SELECT
                    mP.matched_curr_code       ,
                    mP.matched_curr_conversion_rate,
                    mP.matched_curr_conversion_type,
                    mP.matched_curr_conversion_date,
                    NULL nrec_tax_amt             ,
                    NULL charge_line_type_id      ,
                    mP.matched_qty                ,
                    mP.matched_uom_code           ,
                    mP.matched_amt                ,
                    mP.match_id
                INTO
                    l_mat_curr_code_P          ,
                    l_mat_curr_rate_P          ,
                    l_mat_curr_type_P          ,
                    l_mat_curr_date_P          ,
                    l_mat_nrec_tax_amt_P       ,
                    l_mat_charge_line_type_id_P,
                    l_mat_qty_P                ,
                    l_mat_uom_code_P           ,
                    l_mat_amt_P                ,
                    l_mat_par_mat_id_P
                FROM
                    inl_corr_matches_v mP -- 1 get the parent
                WHERE mP.from_parent_table_name = x_new_to_parent_table_name
                AND mP.from_parent_table_id   = x_new_to_parent_table_id
                AND mP.match_id
                    =(
                        SELECT MAX(m1P.match_id)
                        FROM inl_corr_matches_v m1P
                        WHERE m1P.from_parent_table_name = mP.from_parent_table_name
                        AND m1P.from_parent_table_id   = mP.from_parent_table_id
                )
                AND (mP.correction_match_id IS NULL
                     OR mP.correction_match_id
                    =(
                        SELECT MAX(m1P.correction_match_id)
                        FROM inl_corr_matches_v m1P
                        WHERE m1P.from_parent_table_name = mP.from_parent_table_name
                        AND m1P.from_parent_table_id   = mP.from_parent_table_id
                ))
                ;
            END IF;

            l_debug_info := 'match_type: '||l_match_type;
            INL_LOGGING_PVT.Log_Statement(
                p_module_name    => g_module_name,
                p_procedure_name => l_program_name,
                p_debug_info     => l_debug_info
            );

            IF l_match_type = 'PRICE_CORRECTION' THEN
                x_matched_qty := l_mat_qty_P;

            ELSE
                IF l_mat_uom_code_P <> x_matched_uom_code THEN
                    x_matched_qty :=
                        INL_LANDEDCOST_PVT.Converted_Qty(
                            p_organization_id   => x_org_id,--Bug#10381495
                            p_inventory_item_id => l_inventory_item_id,
                            p_qty               => x_matched_qty,
                            p_from_uom_code     => x_matched_uom_code,
                            P_to_uom_code       => l_mat_uom_code_P
                        )
                    ;

                END IF;
                x_matched_qty := x_matched_qty + NVL(l_mat_qty_P, 0) ;
            END IF;
            x_matched_uom_code := l_mat_uom_code_P;
        ELSE -- isn't a ITEM
            SELECT
                m.matched_curr_code           ,
                m.matched_curr_conversion_rate,
                m.matched_curr_conversion_type,
                m.matched_curr_conversion_date,
                m.nrec_tax_amt                ,
                m.charge_line_type_id         ,
                m.matched_qty                 ,
                m.matched_uom_code            ,
                m.matched_amt                 ,
                m.match_id
            INTO
                l_mat_curr_code_P          ,
                l_mat_curr_rate_P          ,
                l_mat_curr_type_P          ,
                l_mat_curr_date_P          ,
                l_mat_nrec_tax_amt_P       ,
                l_mat_charge_line_type_id_P,
                l_mat_qty_P                ,
                l_mat_uom_code_P           ,
                l_mat_amt_P                ,
                l_mat_par_mat_id_P
            FROM inl_corr_matches_v m
            WHERE m.from_parent_table_name = x_new_to_parent_table_name
            AND m.from_parent_table_id   = x_new_to_parent_table_id
            AND m.match_id               =
               (
                     SELECT MAX(m1.match_id)
                       FROM inl_corr_matches_v m1
                      WHERE m1.from_parent_table_name = x_new_to_parent_table_name
                        AND m1.from_parent_table_id   = x_new_to_parent_table_id
                )
            ;
        END IF;

        IF l_mat_curr_code_P <> x_matched_curr_code THEN
            --correction
            l_debug_info := 'conversion required.';
            INL_LOGGING_PVT.Log_Statement(
                p_module_name    => g_module_name,
                p_procedure_name => l_program_name,
                p_debug_info     => l_debug_info
            );
            x_matched_amt := INL_LANDEDCOST_PVT.Converted_Amt(
                                p_amt                       => NVL(x_matched_amt, 0),
                                p_from_currency_code        => x_matched_curr_code,
                                p_to_currency_code          => l_mat_curr_code_P,
                                p_currency_conversion_type  => NVL(l_mat_curr_type_P,x_matched_curr_conversion_type),
                                p_currency_conversion_date  => NVL(l_mat_curr_date_P,x_matched_curr_conversion_date),
                                x_currency_conversion_rate  => l_currency_conversion_rate
                            )
            ;
            IF NVL(x_nrec_tax_amt, 0) <> 0 THEN
                l_debug_info := 'conversion required for Not recoverable tax.';
                INL_LOGGING_PVT.Log_Statement(
                    p_module_name    => g_module_name,
                    p_procedure_name => l_program_name,
                    p_debug_info     => l_debug_info
                );

                x_nrec_tax_amt := inl_landedcost_pvt.Converted_Amt(
                                      p_amt                       => NVL(x_nrec_tax_amt, 0),
                                      p_from_currency_code        => x_matched_curr_code,
                                      p_to_currency_code          => l_mat_curr_code_P,
                                      p_currency_conversion_type  => NVL(l_mat_curr_type_P,x_matched_curr_conversion_type),
                                      p_currency_conversion_date  => NVL(l_mat_curr_date_P,x_matched_curr_conversion_date),
                                      x_currency_conversion_rate  => l_currency_conversion_rate
                                  )
                ;
            END IF;
        END IF;
        x_matched_curr_code            := l_mat_curr_code_P;
        x_matched_curr_conversion_type := l_mat_curr_type_P;
        x_matched_curr_conversion_date := l_mat_curr_date_P;
        x_matched_curr_conversion_rate := l_currency_conversion_rate; --l_mat_curr_rate_P;

        IF x_existing_match_info_flag = 'Y'
            AND l_corr_from_parent_table_id IS NOT NULL
            AND l_corr_from_parent_table_id > p_from_parent_table_id
        THEN
            x_matched_amt := NVL(x_matched_amt,0) + NVL(x_nrec_tax_amt, 0); -- RESUBMIT A CORRECTION THAT ISN'T THE LAST CORRECTION
        ELSE
            x_matched_amt := NVL(x_matched_amt,0) + NVL(x_nrec_tax_amt, 0) + NVL(l_mat_amt_P, 0);
        END IF;
        x_parent_match_id := l_mat_par_mat_id_P;
        IF NVL(x_nrec_tax_amt, 0) <> 0 OR NVL(l_mat_nrec_tax_amt_P, 0) <> 0 THEN
            x_nrec_tax_amt := NVL(x_nrec_tax_amt, 0) + NVL(l_mat_nrec_tax_amt_P, 0) ;
        END IF;
    END IF;

    IF x_new_to_parent_table_name = 'INL_SHIP_HEADERS' THEN
        SELECT ship_header_id
        INTO x_ship_header_id
        FROM inl_ship_headers_all --Bug#10381495
        WHERE ship_header_id = x_new_to_parent_table_id;
    ELSIF x_new_to_parent_table_name = 'INL_SHIP_LINES' THEN
        SELECT ship_header_id
        INTO x_ship_header_id
        FROM inl_ship_lines_all --Bug#10381495
        WHERE ship_line_id  = x_new_to_parent_table_id;
    ELSIF x_new_to_parent_table_name = 'INL_SHIP_LINE_GROUPS' THEN
        SELECT ship_header_id
        INTO x_ship_header_id
        FROM inl_ship_line_groups
        WHERE ship_line_group_id = x_new_to_parent_table_id;
    ELSIF x_new_to_parent_table_name = 'INL_CHARGE_LINES' THEN
        l_ship_header_id_tab.DELETE;
        SELECT DISTINCT(a.ship_header_id) BULK COLLECT
        INTO l_ship_header_id_tab
        FROM inl_charge_lines c,
        inl_associations a
        WHERE c.charge_line_id              = x_new_to_parent_table_id
        AND a.from_parent_table_name      = 'INL_CHARGE_LINES'
        AND a.from_parent_table_id        = c.charge_line_id;
        IF NVL(l_ship_header_id_tab.COUNT, 0) = 1 THEN
            x_ship_header_id                 := l_ship_header_id_tab(1) ;
        END IF;
    ELSIF x_new_to_parent_table_name = 'INL_TAX_LINES' THEN
        SELECT ship_header_id
        INTO x_ship_header_id
        FROM inl_tax_lines
        WHERE tax_line_id   = x_new_to_parent_table_id;
    ELSE -- In case of correction, the table is out of LCM limit
        SELECT ship_header_id
        INTO x_ship_header_id
        FROM inl_matches
        WHERE match_id     = l_mat_par_mat_id_P;
    END IF;
--
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    );
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        x_return_status := L_FND_RET_STS_ERROR;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name
            );
        END IF;
END Derive_FromAP;


-- Utility name : call_ShpmtPvtAdjLin    --BUG#8198498
-- Type       : Private
-- Function   : Call INL_SHIPMENT_PVT.Adjust_Lines in order to get all
--              adjustment lines created in submit's time
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_match_type_code       IN VARCHAR2
--              p_correction_type       IN VARCHAR2
--              p_to_parent_table_name  IN VARCHAR2
--              p_to_parent_table_id    IN NUMBER
--              p_ship_header_id        IN NUMBER
--
-- OUT        : x_return_status OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE call_ShpmtPvtAdjLin(      --BUG#8198498
    p_match_type_code       IN VARCHAR2,
    p_correction_type       IN VARCHAR2,--Bug#14768732
    p_to_parent_table_name  IN VARCHAR2,
    p_to_parent_table_id    IN NUMBER,
    p_ship_header_id        IN NUMBER,
    x_return_status        OUT NOCOPY VARCHAR2
) IS
    l_program_name CONSTANT VARCHAR2(100) := 'call_ShpmtPvtAdjLin';
    l_debug_info    VARCHAR2(2000) ;
    l_return_status VARCHAR2(1) ;
    l_msg_count NUMBER;
    l_msg_data VARCHAR2 (2000);

    Cursor c_prorates_affctdByItem is
--Bug#14044298 BEG
    SELECT DISTINCT assoc2.ship_header_id
    FROM inl_associations assoc2
    WHERE (assoc2.from_parent_table_name,assoc2.from_parent_table_id)
            IN (select assoc.from_parent_table_name,assoc.from_parent_table_id
                from inl_associations assoc
               WHERE assoc.to_parent_table_name = p_to_parent_table_name
                AND assoc.to_parent_table_id    = p_to_parent_table_id
              )
    ;

/*
    SELECT DISTINCT assoc2.ship_header_id
    FROM inl_associations assoc2
    WHERE CONNECT_BY_ISLEAF = 1
    START WITH (assoc2.from_parent_table_name,assoc2.from_parent_table_id)
            IN (select assoc.from_parent_table_name,assoc.from_parent_table_id
                from inl_associations assoc
               WHERE assoc.to_parent_table_name = p_to_parent_table_name
                AND assoc.to_parent_table_id    = p_to_parent_table_id
              )
    CONNECT BY PRIOR assoc2.from_parent_table_name = assoc2.to_parent_table_name
                 AND assoc2.from_parent_table_id = assoc2.to_parent_table_id
    ;
*/
--Bug#14044298 END
    TYPE c_prorates_affctdByItem_Type IS
        TABLE OF c_prorates_affctdByItem%ROWTYPE;
    prorates_affctdByItem_lin c_prorates_affctdByItem_Type;

    l_count_unproc_match NUMBER; --Bug#14044298
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    ) ;
    -- Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;
    l_debug_info := 'Verifying match type to mark affected shipments'; --Bug#14768732
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    ) ;
--

    l_debug_info := 'Processing Match Amounts';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    ) ;
--
    IF p_match_type_code = 'ITEM'
    OR p_correction_type = 'ITEM'  --Bug#14768732
    THEN
        OPEN c_prorates_affctdByItem;
        FETCH c_prorates_affctdByItem BULK COLLECT INTO prorates_affctdByItem_lin;
        CLOSE c_prorates_affctdByItem;
        l_debug_info := prorates_affctdByItem_lin.COUNT||' lines have been retrieved.';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_program_name,
            p_debug_info => l_debug_info
        ) ;
        FOR i IN 1 .. prorates_affctdByItem_lin.COUNT
        LOOP
                l_debug_info := 'Updating : '||prorates_affctdByItem_lin(i).ship_header_id;
                INL_LOGGING_PVT.Log_Statement (
                    p_module_name => g_module_name,
                    p_procedure_name => l_program_name,
                    p_debug_info => l_debug_info
                ) ;
                -- Set Shipment Header's pending_matching_flag to 'Y'
                inl_shipment_pvt.Update_PendingMatchingFlag(  --BUG#8198498
                    p_ship_header_id        => prorates_affctdByItem_lin(i).ship_header_id,
                    p_pending_matching_flag => 'Y',
                    x_return_status         => l_return_status
                );
                -- If any errors happen abort API.
                IF l_return_status = L_FND_RET_STS_ERROR THEN
                    RAISE L_FND_EXC_ERROR;
                ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                    RAISE L_FND_EXC_UNEXPECTED_ERROR;
                END IF;
        END LOOP;
    END IF;

    --Bug#14044298 BEGING

    l_debug_info := 'Verify if call to Adjust Lines is required';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_debug_info => l_debug_info
    ) ;
    SELECT COUNT(*)
    INTO l_count_unproc_match
    FROM inl_matches m
    WHERE m.ship_header_id = p_ship_header_id
    AND NVL(m.adj_already_generated_flag, 'N') = 'N';

    l_debug_info := p_ship_header_id||' => '|| l_count_unproc_match ||' unprocessed match(es) ';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_debug_info => l_debug_info
    ) ;
    IF NVL(l_count_unproc_match,0) > 0 THEN
    --Bug#14044298 END
        l_debug_info := 'Run INL_SHIPMENT_PVT.Adjust_Lines';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_program_name,
            p_debug_info => l_debug_info
       ) ;

        inl_shipment_pvt.Adjust_Lines (
            p_api_version       => 1.0,
            p_init_msg_list     => L_FND_FALSE,
            p_commit            => L_FND_FALSE,
            p_ship_header_id    => p_ship_header_id,
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
--
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    );
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        x_return_status := L_FND_RET_STS_ERROR;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name
            );
        END IF;
END call_ShpmtPvtAdjLin;

-- Utility name : Import_Matches
-- Type       : Private
-- Function   : Import Match Lines
--
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_group_id      IN  NUMBER
--
-- OUT        : x_return_status OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Import_Matches(
    p_group_id      IN NUMBER,
    p_commit        IN VARCHAR2, --Bug#11794442
    x_return_status OUT NOCOPY VARCHAR2
) IS
    l_program_name CONSTANT VARCHAR2(100) := 'Import_Matches';
    l_debug_info    VARCHAR2(2000) ;
    l_return_status VARCHAR2(1) ;

    --Bug#11794442 begin
    -- in case of error during the processing of a match all matches belong to the same group_id should be rolled back
    -- in order to control this situation whe should run sepparetly each group id because we have 2 cursors that are run sepparetly
    -- one for match amounts creation and another for matches creation

    CURSOR c_distgroupid (p_initial_sysdate date)
    IS
        SELECT
            MIN(DECODE(mp.process_enabled_flag,'Y',NVL(mi.adj_group_date,p_initial_sysdate),p_initial_sysdate)) adj_group_date,  -- OPM Integration
            mi.group_id
        FROM inl_matches_int mi,
             rcv_transactions rt, -- OPM Integration
             mtl_parameters mp
        WHERE mi.processing_status_code = 'RUNNING' /* Point 1: If any change occur here the other 4 points might be affected */
        AND   (p_group_id   IS NULL
                OR p_group_id = mi.group_id)
        --Bug#14768732 BEGIN
        AND rt.transaction_id =
            DECODE(mi.to_parent_table_name, 'RCV_TRANSACTIONS', mi.to_parent_table_id,
                                            'AP_INVOICE_DISTRIBUTIONS',
                                           (SELECT aid.rcv_transaction_id
                                            FROM ap_invoice_distributions_all aid
                                            WHERE aid.invoice_distribution_id = mi.to_parent_table_id)
                )
        --Bug#14768732 END
     --   AND mi.to_parent_table_name = 'RCV_TRANSACTIONS'  --Bug#14768732
     --   AND mi.to_parent_table_id = rt.transaction_id     --Bug#14768732
        AND rt.organization_id = mp.organization_id
        AND mi.request_id = l_fnd_conc_request_id_int --Bug#11794442
        group by mi.group_id
        order by MIN(DECODE(mp.process_enabled_flag,'Y',NVL(mi.adj_group_date,p_initial_sysdate),p_initial_sysdate)), mi.group_id
    ;

    TYPE distgroupid_ListType IS TABLE OF c_distgroupid%ROWTYPE;
    distgroupid_List distgroupid_ListType;

    --Bug#11794442 end

    -- Cursor to get all valid and possible Matches
    -- that will be used in the import process
    CURSOR matchAmountsToProcess (pc_initial_sysdate DATE,
                                  pc_group_id NUMBER) --Bug#11794442
    IS
        SELECT NULL new_match_Amount_id, -- BUG#8411723 => MURALI --BUG#8264388
           max(DECODE(mp.process_enabled_flag,'Y',
                      NVL(mi.adj_group_date,pc_initial_sysdate),pc_initial_sysdate)) adj_group_date,  -- OPM Integration,
                                                                       -- if an freight invoice has 2 lines to different organization can have 2
                                                                       -- different dates but need to be consider as an unic match amount in order to be re-prorated
           sum(mi.matched_amt) matched_amt,
           sum(mi.nrec_tax_amt) nrec_tax_amt,
           count(distinct(
               DECODE(mp.process_enabled_flag,'Y',
                      NVL(mi.adj_group_date,pc_initial_sysdate),pc_initial_sysdate))) count_adj_group_date,
           mi.matched_curr_code           ,
           mi.matched_curr_conversion_type,
           mi.matched_curr_conversion_date,
           mi.matched_curr_conversion_rate,
           mi.transaction_type,
           mi.group_id,                --BUG#8264388
           mi.charge_line_type_id,     --BUG#8264388
           mi.tax_code                 --BUG#8264388
        FROM inl_matches_int mi,
             rcv_transactions rt, -- OPM Integration
             mtl_parameters mp    -- OPM Integration
        WHERE mi.processing_status_code = 'RUNNING'
        AND   ((pc_group_id IS NULL AND mi.group_id IS NULL)
               OR mi.group_id = pc_group_id) --Bug#11794442
        AND mi.match_amounts_flag = 'Y'
        --Bug#14768732 BEGIN
        AND rt.transaction_id =
            DECODE(mi.to_parent_table_name, 'RCV_TRANSACTIONS', mi.to_parent_table_id,
                                            'AP_INVOICE_DISTRIBUTIONS',
                                           (SELECT aid.rcv_transaction_id
                                            FROM ap_invoice_distributions_all aid
                                            WHERE aid.invoice_distribution_id = mi.to_parent_table_id)
                )
        --Bug#14768732 END
        AND mi.to_parent_table_name = 'RCV_TRANSACTIONS'
        AND mi.to_parent_table_id = rt.transaction_id
        AND rt.organization_id = mp.organization_id
        AND mi.request_id = l_fnd_conc_request_id_int --Bug#11794442
        GROUP BY
           mi.matched_curr_code           ,
           mi.matched_curr_conversion_type,
           mi.matched_curr_conversion_date,
           mi.matched_curr_conversion_rate,
           mi.transaction_type,
           mi.group_id,
           mi.charge_line_type_id,
           mi.tax_code
        ORDER BY mi.group_id  -- BUG#8411723 => MURALI  --BUG#8264388
;

    TYPE matchAmountsToProcess_ListType IS TABLE OF matchAmountsToProcess%ROWTYPE;
    matchAmountsToProcess_List matchAmountsToProcess_ListType;

    CURSOR matchesToProcess (pc_initial_sysdate date,
                             pc_group_id NUMBER) --Bug#11794442
    IS
         SELECT NULL new_match_id, -- BUG#8411723 => MURALI
           DECODE(mp.process_enabled_flag,'Y',NVL(mi.adj_group_date,pc_initial_sysdate),pc_initial_sysdate) adj_group_date,  -- OPM Integration
            mi.match_type_code       ,
            mi.from_parent_table_name,
            mi.from_parent_table_id  ,
            mi.to_parent_table_name  ,
            mi.to_parent_table_id    ,
            NULL new_to_parent_table_name  , --Bug#14768732
            NULL new_to_parent_table_id    , --Bug#14768732
            mi.matched_qty                 ,
            mi.matched_uom_code            ,
            mi.matched_amt                 ,
            mi.matched_curr_code           ,
            mi.matched_curr_conversion_type,
            mi.matched_curr_conversion_date,
            mi.matched_curr_conversion_rate,
            mi.replace_estim_qty_flag      ,
            mi.charge_line_type_id  ,
            mi.party_id             ,
            mi.party_site_id        ,
            mi.tax_code             ,
            mi.nrec_tax_amt         ,
            mi.tax_amt_included_flag,
            mi.match_int_id         ,
            mi.transaction_type     ,
            NULL ship_header_id     ,
            NULL org_id             , --Bug#10381495
            mi.match_amounts_flag   , --BUG#8264388
            mi.group_id             , --BUG#8264388
            rt.lcm_shipment_line_id         --Bug#14768732
         FROM inl_matches_int mi,
             rcv_transactions rt, -- OPM Integration
             mtl_parameters mp
         WHERE mi.processing_status_code = 'RUNNING' /* Point 1: If any change occur here the other 4 points might be affected */
        AND   ((pc_group_id IS NULL AND mi.group_id IS NULL)
               OR mi.group_id = pc_group_id) --Bug#11794442
        --Bug#14768732 BEGIN
        AND rt.transaction_id =
            DECODE(mi.to_parent_table_name, 'RCV_TRANSACTIONS', mi.to_parent_table_id,
                                            'AP_INVOICE_DISTRIBUTIONS',
                                           (SELECT aid.rcv_transaction_id
                                            FROM ap_invoice_distributions_all aid
                                            WHERE aid.invoice_distribution_id = mi.to_parent_table_id)
                )
        --Bug#14768732 END
       --  AND mi.to_parent_table_name = 'RCV_TRANSACTIONS'
       --  AND mi.to_parent_table_id = rt.transaction_id
         AND rt.organization_id = mp.organization_id
         AND mi.request_id = l_fnd_conc_request_id_int --Bug#11794442
        order by DECODE(mp.process_enabled_flag,'Y',NVL(mi.adj_group_date,pc_initial_sysdate),pc_initial_sysdate), -- OPM Integration
                 mi.match_int_id -- BUG#8411723 => MURALI
    ;

    TYPE matchesToProcess_ListType IS TABLE OF matchesToProcess%ROWTYPE;
    matchesToProcess_List matchesToProcess_ListType;

    -- SCM-051
    CURSOR c_shipToProcess(pc_group_id NUMBER)IS
    SELECT sh.ship_num
    FROM inl_ship_lines sl,
         inl_ship_headers sh,
         inl_matches_int mi,
         rcv_transactions rt
    WHERE sh.ship_header_id = sl.ship_header_id
    AND sl.ship_line_id = rt.lcm_shipment_line_id
    AND mi.to_parent_table_name = 'RCV_TRANSACTIONS'
    AND mi.to_parent_table_id = rt.transaction_id
    AND mi.group_id = pc_group_id
    FOR UPDATE OF sh.ship_header_id NOWAIT;

    TYPE shipToProcess IS TABLE OF c_shipToProcess%ROWTYPE;
    l_shipToProcess shipToProcess;
    -- /SCM-051

--Bug#14768732 not used        l_ship_line_id  NUMBER;
--Bug#14768732 not used        l_ship_header_id  NUMBER;
    l_parent_match_id  NUMBER;
    l_existing_match_info_flag VARCHAR2(1) ;
    l_match_id  NUMBER;
--Bug#14768732    l_new_to_parent_table_name VARCHAR2(30) ;
--Bug#14768732    l_new_to_parent_table_id NUMBER;
    l_match_type_correction VARCHAR2(30) ;--Bug#14768732
    l_matched_qty NUMBER;
    l_matched_amt NUMBER;
    l_nrec_tax_amt NUMBER;
    l_matched_uom_code VARCHAR2(30) ;
    l_matched_curr_code VARCHAR2(30) ;
    l_matched_curr_conversion_type  VARCHAR2(30);
    l_matched_curr_conversion_date DATE;
    l_matched_curr_conversion_rate  NUMBER;
    l_initial_sysdate date:= TRUNC(SYSDATE);

    --Bug#10381495
    l_previous_access_mode  VARCHAR2(1) :=mo_global.get_access_mode();
    l_previous_org_id       NUMBER(15)  :=mo_global.get_current_org_id();
    l_current_org_id        NUMBER(15);
    l_g_records_inserted_bkp NUMBER;
    --Bug#10381495

    -- SCM-051
    -- ORA-00054 is the resource busy exception, which is raised when trying
    -- to lock a row that is already locked by another session.
    RESOURCE_BUSY EXCEPTION;
    PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -00054);
    l_resource_busy BOOLEAN := FALSE;
    l_lock_error BOOLEAN := FALSE;

BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    ) ;
    -- Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;
    l_debug_info := 'Processing Match Amounts';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    ) ;
    l_current_org_id      := NVL(l_previous_org_id,-999);--Bug#10381495
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'l_current_org_id',
        p_var_value      => l_current_org_id
    ) ;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'l_initial_sysdate',
        p_var_value      => l_initial_sysdate
    ) ;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'l_fnd_conc_request_id_int',
        p_var_value      => l_fnd_conc_request_id_int
    ) ;

--Bug#11794442 Begin
    OPEN c_distgroupid (l_initial_sysdate);
    FETCH c_distgroupid BULK COLLECT INTO distgroupid_List;
    CLOSE c_distgroupid;
    l_debug_info := 'Fetched '||NVL(distgroupid_List.COUNT, 0)||' groups.';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    ) ;

    FOR iGroup IN 1 .. distgroupid_List.COUNT
    LOOP
        l_debug_info := 'Processing Group_id: '||distgroupid_List(iGroup).group_id;
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info
        ) ;
        BEGIN
            SAVEPOINT Import_MatchbyGroupId;

            -- SCM-051 Get Ship Header Id for p_group_id
            l_debug_info := 'Get lock for shipments Group_id: '||distgroupid_List(iGroup).group_id;
            INL_LOGGING_PVT.Log_Statement(
                p_module_name      => g_module_name,
                p_procedure_name   => l_program_name,
                p_debug_info       => l_debug_info) ;

            BEGIN
                -- Fetch Ship to Process
                OPEN c_shipToProcess(distgroupid_List(iGroup).group_id);
                FETCH c_shipToProcess BULK COLLECT INTO l_shipToProcess;
                CLOSE c_shipToProcess;
            EXCEPTION
                --Handling deadlock with proper error message
                WHEN RESOURCE_BUSY THEN
                    l_debug_info := 'Record for group_id ' || distgroupid_List(iGroup).group_id || 'cannot be reserved for update. It has already been reserved by another user.';
                    INL_LOGGING_PVT.Log_Statement(
                        p_module_name => g_module_name,
                        p_procedure_name => l_program_name,
                        p_debug_info => l_debug_info);

                    FND_MESSAGE.set_name('INL','INL_ERR_OI_CHK_LCK_SHIPMENT');
                    FND_MESSAGE.set_token('GROUP_ID',distgroupid_List(iGroup).group_id);
                    FND_MSG_PUB.ADD;

                    l_debug_info := 'Set Interface Status to PENDING for group id: '||distgroupid_List(iGroup).group_id;

                    UPDATE inl_matches_int mi
                    SET mi.processing_status_code = 'PENDING',
                        mi.request_id = L_FND_CONC_REQUEST_ID,
                        mi.last_updated_by = L_FND_USER_ID,
                        mi.last_update_date = SYSDATE,
                        mi.last_update_login = L_FND_LOGIN_ID,
                        mi.program_id = L_FND_CONC_PROGRAM_ID,
                        mi.program_update_date = SYSDATE,
                        mi.program_application_id = L_FND_PROG_APPL_ID
                    WHERE mi.group_id = distgroupid_List(iGroup).group_id;
                    l_resource_busy := TRUE;
                    l_lock_error := TRUE;
            END;
            -- /SCM-051

            IF NOT l_resource_busy THEN -- SCM-051
                l_g_records_inserted_bkp:= nvl(g_records_inserted,0);
--Bug#11794442 End

                l_debug_info := 'Openning Match Amounts Cursor: ';
                INL_LOGGING_PVT.Log_Statement(
                    p_module_name      => g_module_name,
                    p_procedure_name   => l_program_name,
                    p_debug_info       => l_debug_info
                ) ;

                OPEN matchAmountsToProcess (l_initial_sysdate,distgroupid_List(iGroup).group_id);
                FETCH matchAmountsToProcess BULK COLLECT INTO matchAmountsToProcess_List;
                CLOSE matchAmountsToProcess;
                l_debug_info := 'Fetched '||NVL(matchAmountsToProcess_List.COUNT, 0)||' records.';
                INL_LOGGING_PVT.Log_Statement(
                    p_module_name      => g_module_name,
                    p_procedure_name   => l_program_name,
                    p_debug_info       => l_debug_info
                ) ;

                FOR iMatch IN 1 .. matchAmountsToProcess_List.COUNT
                LOOP
                        l_debug_info := 'Processing Match Amount: '||iMatch;
                        INL_LOGGING_PVT.Log_Statement(
                            p_module_name      => g_module_name,
                            p_procedure_name   => l_program_name,
                            p_debug_info       => l_debug_info
                        ) ;

                        IF matchAmountsToProcess_List(iMatch).transaction_type <> 'CREATE' THEN
                            l_debug_info := 'Transaction_type '||matchAmountsToProcess_List(iMatch).transaction_type||'not supported.';
                                    INL_LOGGING_PVT.Log_Statement(
                                        p_module_name      => g_module_name,
                                        p_procedure_name   => l_program_name,
                                        p_debug_info       => l_debug_info
                                    ) ;

                            RAISE L_FND_EXC_UNEXPECTED_ERROR;
                        ELSE
                            SELECT inl_match_Amounts_s.NEXTVAL
                              INTO matchAmountsToProcess_List(iMatch).new_match_Amount_id
                              FROM dual; -- BUG#8411723 => MURALI

                            INL_LOGGING_PVT.Log_Variable(
                                p_module_name    => g_module_name,
                                p_procedure_name => l_program_name,
                                p_var_name       => 'matchAmountsToProcess_List(iMatch).new_match_Amount_id',
                                p_var_value      => matchAmountsToProcess_List(iMatch).new_match_Amount_id
                            ) ;

                            INSERT INTO inl_match_Amounts(
                                match_amount_id             ,
                                adj_group_date              ,-- OPM Integration
                                matched_amt                 ,
                                matched_curr_code           ,
                                matched_curr_conversion_type,
                                matched_curr_conversion_date,
                                matched_curr_conversion_rate,
                                group_id                    , --BUG#8264388
                                charge_line_type_id         , --BUG#8264388
                                tax_code                    , --BUG#8264388
                                nrec_tax_amt                , --BUG#8264388
                                program_id                  ,
                                program_update_date         ,
                                program_application_id      ,
                                request_id                  ,
                                created_by                  ,
                                creation_date               ,
                                last_updated_by             ,
                                last_update_date            ,
                                last_update_login
                            )   VALUES
                           (
                                matchAmountsToProcess_List(iMatch).new_match_Amount_id          ,
                                DECODE(matchAmountsToProcess_List(iMatch).count_adj_group_date,1
                                        ,matchAmountsToProcess_List(iMatch).adj_group_date
                                        ,NULL)                                                  , -- OPM Integration
                                matchAmountsToProcess_List(iMatch).matched_amt                  ,
                                matchAmountsToProcess_List(iMatch).matched_curr_code            ,
                                matchAmountsToProcess_List(iMatch).matched_curr_conversion_type ,
                                matchAmountsToProcess_List(iMatch).matched_curr_conversion_date ,
                                matchAmountsToProcess_List(iMatch).matched_curr_conversion_rate ,
                                matchAmountsToProcess_List(iMatch).group_id                     , --BUG#8264388
                                matchAmountsToProcess_List(iMatch).charge_line_type_id          , --BUG#8264388
                                matchAmountsToProcess_List(iMatch).tax_code                     , --BUG#8264388
                                matchAmountsToProcess_List(iMatch).nrec_tax_amt                 , --BUG#8264388
                                L_FND_CONC_PROGRAM_ID                                      ,
                                SYSDATE                                                         ,
                                L_FND_PROG_APPL_ID                                         ,
                                L_FND_CONC_REQUEST_ID                                      ,
                                L_FND_USER_ID                                              ,
                                SYSDATE                                                         ,
                                L_FND_USER_ID                                              ,
                                SYSDATE                                                         ,
                                L_FND_LOGIN_ID
                            );
                        END IF;
                END LOOP;

                l_debug_info := 'Processing Matches';
                INL_LOGGING_PVT.Log_Statement(
                    p_module_name      => g_module_name,
                    p_procedure_name   => l_program_name,
                    p_debug_info       => l_debug_info
                ) ;

                OPEN matchesToProcess (l_initial_sysdate, distgroupid_List(iGroup).group_id);
                FETCH matchesToProcess BULK COLLECT INTO matchesToProcess_List;
                CLOSE matchesToProcess;

                IF NVL(matchesToProcess_List.COUNT, 0) > 0 THEN
                    FOR iMatch IN 1 .. matchesToProcess_List.COUNT
                    LOOP

                        IF matchesToProcess_List(iMatch).from_parent_table_name = 'AP_INVOICE_DISTRIBUTIONS'
                        THEN
                            l_matched_qty                  := matchesToProcess_List(iMatch).matched_qty                    ;
                            l_matched_uom_code             := matchesToProcess_List(iMatch).matched_uom_code               ;
                            --Bug#14768732 BEGIN
                            --l_new_to_parent_table_name     := matchesToProcess_List(iMatch).to_parent_table_name           ;
                            --l_new_to_parent_table_id       := matchesToProcess_List(iMatch).to_parent_table_id             ;
                            matchesToProcess_List(iMatch).new_to_parent_table_name := matchesToProcess_List(iMatch).to_parent_table_name;
                            matchesToProcess_List(iMatch).new_to_parent_table_id   := matchesToProcess_List(iMatch).to_parent_table_id;
                            --Bug#14768732 END
                            l_matched_curr_code            := matchesToProcess_List(iMatch).matched_curr_code              ;
                            l_matched_curr_conversion_type := matchesToProcess_List(iMatch).matched_curr_conversion_type   ;
                            l_matched_curr_conversion_date := matchesToProcess_List(iMatch).matched_curr_conversion_date   ;
                            l_matched_curr_conversion_rate := matchesToProcess_List(iMatch).matched_curr_conversion_rate   ;
                            l_matched_amt                  := matchesToProcess_List(iMatch).matched_amt                    ;
                            l_nrec_tax_amt                 := matchesToProcess_List(iMatch).nrec_tax_amt                   ;
                            Derive_FromAP(
                                p_from_parent_table_name        => matchesToProcess_List(iMatch).from_parent_table_name,
                                p_from_parent_table_id          => matchesToProcess_List(iMatch).from_parent_table_id,
                                p_match_type_code               => matchesToProcess_List(iMatch).match_type_code,
                                x_matched_amt                   => l_matched_amt,
                                x_matched_qty                   => l_matched_qty,
                                x_nrec_tax_amt                  => l_nrec_tax_amt,
                                x_matched_uom_code              => l_matched_uom_code,
                                --Bug#14768732 BEGIN
                                --x_new_to_parent_table_name      => l_new_to_parent_table_name,
                                --x_new_to_parent_table_id        => l_new_to_parent_table_id,
                                x_new_to_parent_table_name      => matchesToProcess_List(iMatch).new_to_parent_table_name,
                                x_new_to_parent_table_id        => matchesToProcess_List(iMatch).new_to_parent_table_id,
                                --Bug#14768732 END
                                x_matched_curr_code             => l_matched_curr_code,
                                x_matched_curr_conversion_type  => l_matched_curr_conversion_type,
                                x_matched_curr_conversion_date  => l_matched_curr_conversion_date,
                                x_matched_curr_conversion_rate  => l_matched_curr_conversion_rate,
                                x_ship_header_id                => matchesToProcess_List(iMatch).ship_header_id,
                                x_org_id                        => matchesToProcess_List(iMatch).org_id, --Bug#10381495
                                x_existing_match_info_flag      => l_existing_match_info_flag,
                                x_parent_match_id               => l_parent_match_id,
                                x_return_status                 => l_return_status
                            );

                             -- If any errors happen abort API.
                            IF l_return_status = L_FND_RET_STS_ERROR THEN
                                RAISE L_FND_EXC_ERROR;
                            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                                RAISE L_FND_EXC_UNEXPECTED_ERROR;
                            END IF;
                        ELSE
                            --Bug#14768732 BEGIN
                            --l_new_to_parent_table_name := matchesToProcess_List(iMatch).to_parent_table_name;
                            --l_new_to_parent_table_id := matchesToProcess_List(iMatch).to_parent_table_id;
                            matchesToProcess_List(iMatch).new_to_parent_table_name := matchesToProcess_List(iMatch).to_parent_table_name;
                            matchesToProcess_List(iMatch).new_to_parent_table_id   := matchesToProcess_List(iMatch).to_parent_table_id;
                            --Bug#14768732 END
                            Set_existingMatchInfoFlag(
                                p_from_parent_table_name    => matchesToProcess_List(iMatch).from_parent_table_name,
                                p_from_parent_table_id      => matchesToProcess_List(iMatch).from_parent_table_id,
                                --Bug#14768732 BEGIN
                                --p_to_parent_table_name      => l_new_to_parent_table_name,
                                --p_to_parent_table_id        => l_new_to_parent_table_id,
                                p_to_parent_table_name      => matchesToProcess_List(iMatch).new_to_parent_table_name,
                                p_to_parent_table_id        => matchesToProcess_List(iMatch).new_to_parent_table_id,
                                --Bug#14768732 END
                                x_existing_match_info_flag  => l_existing_match_info_flag,
                                x_parent_match_id           => l_parent_match_id,
                                x_return_status             => l_return_status
                            );
                             -- If any errors happen abort API.
                            IF l_return_status = L_FND_RET_STS_ERROR THEN
                                RAISE L_FND_EXC_ERROR;
                            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                                RAISE L_FND_EXC_UNEXPECTED_ERROR;
                            END IF;
                        END IF;
                        l_debug_info := 'Processing Match: '||iMatch||'('||matchesToProcess_List(iMatch) .transaction_type||')';
                        INL_LOGGING_PVT.Log_Statement(
                            p_module_name      => g_module_name,
                            p_procedure_name   => l_program_name,
                            p_debug_info       => l_debug_info
                        ) ;

                        INL_LOGGING_PVT.Log_Variable(
                            p_module_name    => g_module_name,
                            p_procedure_name => l_program_name,
                            p_var_name       => 'matchesToProcess_List(iMatch).match_int_id',
                            p_var_value      => matchesToProcess_List(iMatch).match_int_id
                        ) ;
                        IF matchesToProcess_List(iMatch) .transaction_type <> 'CREATE' THEN
                            l_debug_info := 'Transaction_type '||matchesToProcess_List(iMatch) .transaction_type||'not supported.';
                            INL_LOGGING_PVT.Log_Statement(
                                p_module_name      => g_module_name,
                                p_procedure_name   => l_program_name,
                                p_debug_info       => l_debug_info
                            ) ;
                            RAISE L_FND_EXC_UNEXPECTED_ERROR;
                        ELSE
                            SELECT inl_matches_s.NEXTVAL
                              INTO matchesToProcess_List(iMatch).new_match_id
                              FROM dual;  -- BUG#8411723 => MURALI

                            INSERT INTO inl_matches(
                                match_id                     ,  /* 01 */
                                adj_group_date               ,  /* 01A*/  --OPM Integration
                                match_type_code              ,  /* 02 */
                                ship_header_id               ,  /* 03 */
                                from_parent_table_name       ,  /* 04 */
                                from_parent_table_id         ,  /* 05 */
                                to_parent_table_name         ,  /* 06 */
                                to_parent_table_id           ,  /* 07 */
                                parent_match_id              ,  /* 08 */
                                matched_qty                  ,  /* 09 */
                                matched_uom_code             ,  /* 10 */
                                matched_amt                  ,  /* 11 */
                                matched_curr_code            ,  /* 12 */
                                matched_curr_conversion_type ,  /* 13 */
                                matched_curr_conversion_date ,  /* 14 */
                                matched_curr_conversion_rate ,  /* 15 */
                                adj_already_generated_flag   ,  /* 16 */
                                replace_estim_qty_flag       ,  /* 17 */
                                existing_match_info_flag     ,  /* 18 */
                                charge_line_type_id          ,  /* 19 */
                                party_id                     ,  /* 20 */
                                party_site_id                ,  /* 21 */
                                tax_code                     ,  /* 22 */
                                nrec_tax_amt                 ,  /* 23 */
                                tax_amt_included_flag        ,  /* 24 */
                                match_amount_id              ,  /* 25 */
                                match_int_id                 ,  /* 26 */
                                program_id                   ,  /* 27 */
                                program_update_date          ,  /* 28 */
                                program_application_id       ,  /* 29 */
                                request_id                   ,  /* 30 */
                                created_by                   ,  /* 31 */
                                creation_date                ,  /* 32 */
                                last_updated_by              ,  /* 33 */
                                last_update_date             ,  /* 34 */
                                last_update_login               /* 35 */
                            )
                            VALUES(
                                matchesToProcess_List(iMatch).new_match_id           ,             /* 01 */
                                matchesToProcess_List(iMatch).adj_group_date         ,             /* 01A */   --OPM Integration
                                matchesToProcess_List(iMatch).match_type_code        ,             /* 02 */
                                matchesToProcess_List(iMatch).ship_header_id         ,             /* 03 */
                                matchesToProcess_List(iMatch).from_parent_table_name ,             /* 04 */
                                matchesToProcess_List(iMatch).from_parent_table_id   ,             /* 05 */
                                matchesToProcess_List(iMatch).new_to_parent_table_name,            /* 06 */ --Bug#14768732
                                matchesToProcess_List(iMatch).new_to_parent_table_id ,             /* 07 */ --Bug#14768732
                                l_parent_match_id                                    ,             /* 08 */
                                l_matched_qty                                        ,             /* 09 */
                                l_matched_uom_code                                   ,             /* 10 */
                                l_matched_amt                                        ,             /* 11 */
                                l_matched_curr_code                                  ,             /* 12 */
                                l_matched_curr_conversion_type                       ,             /* 13 */
                                l_matched_curr_conversion_date                       ,             /* 14 */
                                l_matched_curr_conversion_rate                       ,             /* 15 */
                                'N'   ,                                                            /* 16 */
                                matchesToProcess_List(iMatch).replace_estim_qty_flag ,             /* 17 */
                                l_existing_match_info_flag                           ,             /* 18 */
                                matchesToProcess_List(iMatch).charge_line_type_id    ,             /* 19 */
                                matchesToProcess_List(iMatch).party_id               ,             /* 20 */
                                matchesToProcess_List(iMatch).party_site_id          ,             /* 21 */
                                matchesToProcess_List(iMatch).tax_code               ,             /* 22 */
                                l_nrec_tax_amt                                       ,             /* 23 */
                                matchesToProcess_List(iMatch).tax_amt_included_flag  ,             /* 24 */
                                DECODE(matchesToProcess_List(iMatch).match_amounts_flag,
                                        'Y',
                                       (SELECT ima.match_amount_id
                                         FROM inl_match_amounts ima
                                         WHERE ima.group_id = matchesToProcess_List(iMatch).group_id
                                           AND nvl(ima.charge_line_type_id,-9) = nvl(matchesToProcess_List(iMatch).charge_line_type_id,-9)
                                           AND nvl(ima.tax_code,'XxX') = nvl(matchesToProcess_List(iMatch).tax_code,'XxX')
                                           AND ima.matched_curr_code = matchesToProcess_List(iMatch).matched_curr_code
                                         )
                                         , NULL
                                        ),                                                         /* 25 */
                                matchesToProcess_List(iMatch).match_int_id           ,             /* 26 */
                                L_FND_CONC_PROGRAM_ID                                ,             /* 27 */
                                SYSDATE                                              ,             /* 28 */
                                L_FND_PROG_APPL_ID                                   ,             /* 29 */
                                L_FND_CONC_REQUEST_ID                                ,             /* 30 */
                                L_FND_USER_ID                                        ,             /* 31 */
                                SYSDATE                                              ,             /* 32 */
                                L_FND_USER_ID                                        ,             /* 33 */
                                SYSDATE                                              ,             /* 34 */
                                L_FND_LOGIN_ID                                                     /* 35 */
                            );

                            l_debug_info := 'Call Set LCM Shipment pending_matching_flag to Y rotine';
                            INL_LOGGING_PVT.Log_Statement(
                                p_module_name => g_module_name,
                                p_procedure_name => l_program_name,
                                p_debug_info => l_debug_info
                            );
                            -- Set Shipment Header's pending_matching_flag to 'Y'
                            inl_shipment_pvt.Update_PendingMatchingFlag(  --BUG#8198498
                                p_ship_header_id        => matchesToProcess_List(iMatch).ship_header_id,
                                p_pending_matching_flag => 'Y',
                                x_return_status         => l_return_status
                            );
                            -- If any errors happen abort API.
                            IF l_return_status = L_FND_RET_STS_ERROR THEN
                                RAISE L_FND_EXC_ERROR;
                            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                                RAISE L_FND_EXC_UNEXPECTED_ERROR;
                            END IF;

                        END IF;
                        l_debug_info  := 'Set Shipment Line Interface status and imported Ids';
                        INL_LOGGING_PVT.Log_Statement(
                            p_module_name      => g_module_name,
                            p_procedure_name   => l_program_name,
                            p_debug_info       => l_debug_info
                        ) ;
                        -- Set processing status to COMPLETED for
                        -- the current and imported Match Line
                        UPDATE inl_matches_int m
                        SET m.processing_status_code = 'COMPLETED'               ,
                            m.request_id             = L_FND_CONC_REQUEST_ID,
                            m.last_updated_by        = L_FND_USER_ID        ,
                            m.last_update_date       = SYSDATE                   ,
                            m.last_update_login      = L_FND_LOGIN_ID       ,
                            m.program_id             = L_FND_CONC_PROGRAM_ID,
                            m.program_update_date    = SYSDATE                   ,
                            m.program_application_id = L_FND_PROG_APPL_ID
                          WHERE m.match_int_id       = matchesToProcess_List(iMatch).match_int_id;

                        -- Set the number of INL Macth records created successfully.
                        -- This value will be latter stamped in the concurrent log
                        g_records_inserted := g_records_inserted + 1;
                    END LOOP;

                    --BUG#8198498
                    -- In order to generate tax and charge lines correctly
                    -- all matches should be created before call inl_shipment_pvt.Adjust_Lines
                    FOR iMatch IN 1 .. matchesToProcess_List.COUNT
                    LOOP
                        IF matchesToProcess_List(iMatch).transaction_type = 'CREATE' THEN
                            -- Generate Adjust Lines
                            -- BUG#8198498 we have to change the order and the adjustment lines
                            -- have been generated before the submit action
                            l_debug_info := 'Generate Adjustment Lines';
                            INL_LOGGING_PVT.Log_Statement(
                                p_module_name => g_module_name,
                                p_procedure_name => l_program_name,
                                p_debug_info => l_debug_info
                            );

                            INL_LOGGING_PVT.Log_Statement(
                                p_module_name => g_module_name,
                                p_procedure_name => l_program_name,
                                p_debug_info => 'Comparing l_current_org_id: '||l_current_org_id||' with matchesToProcess_List(iMatch).org_id:'||matchesToProcess_List(iMatch).org_id
                            );
                            --Bug#10381495
                            IF (l_current_org_id <> matchesToProcess_List(iMatch).org_id) THEN
                                INL_LOGGING_PVT.Log_Statement(
                                    p_module_name => g_module_name,
                                    p_procedure_name => l_program_name,
                                    p_debug_info => 'Seting a new context from '||l_current_org_id||' to '||matchesToProcess_List(iMatch).org_id
                                );
                                mo_global.set_policy_context( 'S', matchesToProcess_List(iMatch).org_id);
                                l_current_org_id := matchesToProcess_List(iMatch).org_id;
                                INL_LOGGING_PVT.Log_Statement(
                                    p_module_name => g_module_name,
                                    p_procedure_name => l_program_name,
                                    p_debug_info => 'l_current_org_id: '||l_current_org_id
                                );
                            END IF;
                            --Bug#10381495

                        --Bug#14768732 BEGIN
                        INL_LOGGING_PVT.Log_Variable(
                            p_module_name    => g_module_name,
                            p_procedure_name => l_program_name,
                            p_var_name       => 'matchesToProcess_List('||iMatch||').match_type_code',
                            p_var_value      => matchesToProcess_List(iMatch).match_type_code
                        ) ;

                        IF matchesToProcess_List(iMatch).match_type_code = 'CORRECTION' THEN
                            INL_LOGGING_PVT.Log_Variable(
                                p_module_name    => g_module_name,
                                p_procedure_name => l_program_name,
                                p_var_name       => 'matchesToProcess_List('||iMatch||').to_parent_table_name',
                                p_var_value      => matchesToProcess_List(iMatch).to_parent_table_name
                            ) ;
                            INL_LOGGING_PVT.Log_Variable(
                                p_module_name    => g_module_name,
                                p_procedure_name => l_program_name,
                                p_var_name       => 'matchesToProcess_List('||iMatch||').to_parent_table_id',
                                p_var_value      => matchesToProcess_List(iMatch).to_parent_table_id
                            ) ;
                            SELECT ail.line_type_lookup_code, NVL(sl.parent_ship_line_id,sl.ship_line_id)
                            INTO l_match_type_correction, matchesToProcess_List(iMatch).new_to_parent_table_id
                            FROM
                                ap_invoice_distributions_all aid,
                                ap_invoice_lines_all ail,
                                inl_ship_lines_all sl
                            WHERE aid.invoice_distribution_id = matchesToProcess_List(iMatch).to_parent_table_id
                            AND aid.invoice_id = ail.invoice_id
                            AND aid.invoice_line_number = ail.line_number
                            AND sl.ship_line_id = matchesToProcess_List(iMatch).lcm_shipment_line_id
                            ;
                            matchesToProcess_List(iMatch).new_to_parent_table_name:='INL_SHIP_LINES';
                            INL_LOGGING_PVT.Log_Variable(
                                p_module_name    => g_module_name,
                                p_procedure_name => l_program_name,
                                p_var_name       => 'matchesToProcess_List('||iMatch||').new_to_parent_table_id',
                                p_var_value      => matchesToProcess_List(iMatch).new_to_parent_table_id
                            ) ;
                            INL_LOGGING_PVT.Log_Variable(
                                p_module_name    => g_module_name,
                                p_procedure_name => l_program_name,
                                p_var_name       => 'l_match_type_correction',
                                p_var_value      => l_match_type_correction
                            ) ;

                        ELSE
                            l_match_type_correction := NULL;
                        END IF;
                        --Bug#14768732 END

                            --BUG#8198498
                            call_ShpmtPvtAdjLin(
                                p_match_type_code       => matchesToProcess_List(iMatch).match_type_code,
                                p_correction_type       => l_match_type_correction, -- Bug#14768732
                                p_to_parent_table_name  => matchesToProcess_List(iMatch).new_to_parent_table_name, -- Bug#14768732
                                p_to_parent_table_id    => matchesToProcess_List(iMatch).new_to_parent_table_id, -- Bug#14768732
                                p_ship_header_id        => matchesToProcess_List(iMatch).ship_header_id,
                                x_return_status         => l_return_status
                            );
                             -- If any errors happen abort API.
                            IF l_return_status = L_FND_RET_STS_ERROR THEN
                                RAISE L_FND_EXC_ERROR;
                            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                                RAISE L_FND_EXC_UNEXPECTED_ERROR;
                            END IF;
                        END IF;
                    END LOOP;
                    --Bug#10381495
                    IF (l_current_org_id <> NVL(l_previous_org_id,l_current_org_id)) THEN --Bug#11931295
                        INL_LOGGING_PVT.Log_Statement(
                            p_module_name => g_module_name,
                            p_procedure_name => l_program_name,
                            p_debug_info => 'Restore previous context: from '||l_current_org_id||' to '||l_previous_org_id
                        );
                        mo_global.set_policy_context( l_previous_access_mode, l_previous_org_id);
                    END IF;
                    --Bug#10381495
                END IF;
            END IF; -- SCM-051
--Bug#11794442 Begin
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK TO Import_MatchbyGroupId;
                g_records_inserted := l_g_records_inserted_bkp;
                l_debug_info := 'Set Interface Status to ERROR for group id(1): '||distgroupid_List(iGroup).group_id||sqlerrm; --Bug#14044298
                INL_LOGGING_PVT.Log_Statement(
                    p_module_name      => g_module_name,
                    p_procedure_name   => l_program_name,
                    p_debug_info       => l_debug_info
                );
                UPDATE inl_matches_int mi
                SET mi.processing_status_code = 'ERROR'         ,
                    mi.request_id             = L_FND_CONC_REQUEST_ID       ,
                    mi.last_updated_by        = L_FND_USER_ID               ,
                    mi.last_update_date       = SYSDATE                          ,
                    mi.last_update_login      = L_FND_LOGIN_ID              ,
                    mi.program_id             = L_FND_CONC_PROGRAM_ID       ,
                    mi.program_update_date    = SYSDATE                          ,
                    mi.program_application_id = L_FND_PROG_APPL_ID
                WHERE  mi.request_id = l_fnd_conc_request_id_int  --Bug#11794442
                AND   ((distgroupid_List(iGroup).group_id IS NULL AND mi.group_id IS NULL)
                        OR mi.group_id = distgroupid_List(iGroup).group_id);
        END;

--Bug#11794442 End
    END LOOP;
    --Bug#14707257/16198838 Begin
    IF (l_current_org_id <> NVL(l_previous_org_id,l_current_org_id)) THEN --Bug#11931295
        INL_LOGGING_PVT.Log_Statement(
            p_module_name => g_module_name,
            p_procedure_name => l_program_name,
            p_debug_info => 'Restore previous context: from '||l_current_org_id||' to '||l_previous_org_id
        );
        mo_global.set_policy_context( l_previous_access_mode, l_previous_org_id);
        l_current_org_id := l_previous_org_id;
    END IF;
    --Bug#14707257/16198838 End

    /*
    IF l_lock_error THEN
        RAISE L_FND_EXC_ERROR;
    END IF;
    */
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    );
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        x_return_status := L_FND_RET_STS_ERROR;
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
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
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
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name
            );
        END IF;
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
END Import_Matches;

-- Utility name : Derive_MatchCols
-- Type         : Private
-- Function     : Get and Set Match Line values
--                before the first set of validations.
--
-- Pre-reqs     : None
-- Parameters   :
-- IN           : p_party_number      VARCHAR2
--                p_party_site_number VARCHAR2
--
--
-- IN OUT       : p_party_id          NUMBER
--                p_party_site_id     NUMBER
--
-- OUT          : x_return_status     VARCHAR2
--
-- Version      : Current version 1.0
--
-- Notes        :
PROCEDURE Derive_MatchCols(
    p_party_number          IN VARCHAR2,
    p_party_site_number     IN VARCHAR2,
    p_match_type_code       IN VARCHAR2,
    p_to_parent_table_name  IN VARCHAR2,
    p_to_parent_table_id    IN NUMBER,
    p_party_id              IN OUT NOCOPY NUMBER,
    p_party_site_id         IN OUT NOCOPY NUMBER,
    p_parent_match_id       IN OUT NOCOPY NUMBER,
    x_return_status            OUT NOCOPY VARCHAR2
) IS
    l_program_name     CONSTANT VARCHAR2(100) := 'Derive_MatchCols';
    l_debug_info    VARCHAR2(200) ;
    l_return_status VARCHAR2(1) ;
BEGIN

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    ) ;
    --  Initialize API return status to success
    x_return_status                             := L_FND_RET_STS_SUCCESS;
    l_debug_info := 'Derive values for Match Lines';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    ) ;
    IF p_party_number IS NOT NULL AND p_party_id IS NULL THEN
        p_party_id  := Derive_PartyID(
                            p_party_number => p_party_number,
                            x_return_status => l_return_status
                       )
        ;
        -- If any errors happen abort the process.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;
    IF p_party_site_number IS NOT NULL AND p_party_site_id IS NULL THEN
        p_party_site_id :=
            Derive_PartySiteID(p_party_site_number => p_party_site_number,
                               x_return_status     => l_return_status
                               )
        ;
        -- If any errors happen abort the process.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

    IF p_parent_match_id IS NULL
        AND p_match_type_code = 'CORRECTION'
    THEN
        SELECT MIN(match_id)
        INTO p_parent_match_id
        FROM inl_matches
        WHERE from_parent_table_id = p_to_parent_table_id
        AND from_parent_table_name = p_to_parent_table_name
        ;
    END IF;

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    );
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        x_return_status := L_FND_RET_STS_ERROR;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name
            );
        END IF;
END Derive_MatchCols;
-- Funct name : Validate_MatchChLnTpID
-- Type       : Private
-- Function   : Validate a given Charge Line Type that was used
--              by the Matching Process
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_match_int_id               IN NUMBER
--              p_match_type_code            IN VARCHAR2
--              p_parent_match_type_code     IN VARCHAR2
--              p_charge_line_type_id        IN NUMBER
--              p_match_amount_int_id        IN NUMBER
--
-- OUT        : x_return_status              OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Validate_MatchChLnTpID(
    p_match_int_id           IN NUMBER,
    p_match_type_code        IN VARCHAR2,
    p_parent_match_type_code IN VARCHAR2,
    p_charge_line_type_id    IN NUMBER,
    p_match_amounts_flag     IN VARCHAR2,
    x_return_status          OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
    l_program_name     CONSTANT VARCHAR2(30) := 'Validate_MatchChLnTpID';
    l_debug_info    VARCHAR2(400) ;
    l_return_status VARCHAR2(1) ;
    l_result        VARCHAR2(1) := L_FND_TRUE;
    l_allocation_basis VARCHAR2(30);
    l_allocation_basis_uom_class VARCHAR2(30);
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    ) ;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;
    l_debug_info := 'Check if CHARGE_LINE_TYPE_ID is valid';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    ) ;
    IF NVL(p_parent_match_type_code, p_match_type_code) = 'CHARGE' THEN
        IF p_charge_line_type_id IS NULL THEN
            l_result := L_FND_FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name  => 'INL_MATCHES_INT',
                p_parent_table_id    => p_match_int_id,
                p_column_name        => 'CHARGE_LINE_TYPE_ID',
                p_column_value       => p_charge_line_type_id,
                p_error_message_name => 'INL_ERR_OI_MAT_CH_LN_TP_ID_N',
                p_token1_name        => 'MATCH_INT_ID',
                p_token1_value       => p_match_int_id,
                x_return_status      => l_return_status
            ) ;
            -- If unexpected errors happen abort
            IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        ELSE
            SELECT UPPER(clt.allocation_basis)
            INTO l_allocation_basis
            FROM inl_charge_line_types_vl clt
            WHERE clt.charge_line_type_id = p_charge_line_type_id;
            --Bug#8898208
            l_debug_info:= '';
            IF l_allocation_basis = 'VOLUME' THEN
                FND_PROFILE.GET('INL_VOLUME_UOM_CLASS',l_allocation_basis_uom_class);
                IF l_allocation_basis_uom_class IS NULL THEN
                    l_debug_info:= 'INL_ERR_CHK_VOL_UOM_CLASS_PROF';
                END IF;
            ELSIF l_allocation_basis = 'QUANTITY' THEN

                FND_PROFILE.GET('INL_QUANTITY_UOM_CLASS',l_allocation_basis_uom_class);
                IF l_allocation_basis_uom_class IS NULL THEN
                    l_debug_info:= 'INL_ERR_CHK_QTY_UOM_CLASS_PROF';
                END IF;
            ELSIF l_allocation_basis = 'WEIGHT' THEN

                FND_PROFILE.GET('INL_WEIGHT_UOM_CLASS',l_allocation_basis_uom_class);
                IF l_allocation_basis_uom_class IS NULL THEN
                    l_debug_info:= 'INL_ERR_CHK_WEI_UOM_CLASS_PROF';
                END IF;
            END IF;
            IF l_debug_info IS NOT NULL THEN
                l_result := L_FND_FALSE;
                -- Add a line into inl_ship_errors
                Handle_InterfError(
                    p_parent_table_name  => 'INL_MATCHES_INT',
                    p_parent_table_id    => p_match_int_id,
                    p_column_name        => 'CHARGE_LINE_TYPE_ID',
                    p_column_value       => p_charge_line_type_id,
                    p_error_message_name => l_debug_info,
                    x_return_status      => l_return_status
                ) ;
                -- If unexpected errors happen abort

                IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
                    RAISE L_FND_EXC_UNEXPECTED_ERROR;
                END IF;
            END IF;
            --Bug#8898208
        END IF;
    ELSE
        IF p_charge_line_type_id IS NOT NULL
        AND p_match_amounts_flag IS NULL
        THEN
            l_result := L_FND_FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name  => 'INL_MATCHES_INT',
                p_parent_table_id    => p_match_int_id,
                p_column_name        => 'CHARGE_LINE_TYPE_ID',
                p_column_value       => p_charge_line_type_id,
                p_error_message_name => 'INL_ERR_OI_MAT_CH_LN_TP_ID_NN',
                p_token1_name        => 'MATCH_INT_ID',
                p_token1_value       => p_match_int_id,
                x_return_status      => l_return_status
            ) ;
            -- If unexpected errors happen abort

            IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
    END IF;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    );
    RETURN FND_API.to_boolean(l_result) ;
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN OTHERS THEN
          -- Standard Unexpected Error Logging
          INL_LOGGING_PVT.Log_UnexpecError (
              p_module_name    => g_module_name,
              p_procedure_name => l_program_name
          );
          IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name
            );
        END IF;
    RETURN FND_API.to_boolean(L_FND_FALSE) ;
END Validate_MatchChLnTpID;
-- Funct name : Validate_MatchFlags
-- Type       : Private
-- Function   : Validate Matching Flags
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_match_int_id               IN NUMBER
--              p_match_type_code            IN VARCHAR2
--              p_parent_match_type_code     IN VARCHAR2
--              p_replace_estim_qty_flag     IN VARCHAR2
--              p_existing_match_info_flag   IN VARCHAR2
--
-- OUT        : x_return_status              OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Validate_MatchFlags(
    p_match_int_id             IN NUMBER,
    p_match_type_code          IN VARCHAR2,
    p_parent_match_type_code   IN VARCHAR2,
    p_replace_estim_qty_flag   IN VARCHAR2,
    p_existing_match_info_flag IN VARCHAR2,
    x_return_status            OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
    l_program_name     CONSTANT VARCHAR2(30) := 'Validate_MatchFlags';
    l_debug_info    VARCHAR2(400) ;
    l_return_status VARCHAR2(1) ;
    l_result        VARCHAR2(1) := L_FND_TRUE;
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    ) ;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;
    l_debug_info    := 'Check if replace_estim_qty_flag = "Y" and it is not about an ITEM match';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    ) ;
    IF p_replace_estim_qty_flag = 'Y' THEN
        IF NVL(p_parent_match_type_code, p_match_type_code) <> 'ITEM' THEN
            l_result          := L_FND_FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name  => 'INL_MATCHES_INT',
                p_parent_table_id    => p_match_int_id,
                p_column_name        => 'REPLACE_ESTIM_QTY_FLAG',
                p_column_value       => p_replace_estim_qty_flag,
                p_error_message_name => 'INL_ERR_OI_CHK_RPL_EST_QT_FLAG',
                p_token1_name        => 'MATCH_INT_ID',
                p_token1_value       => p_match_int_id,
                x_return_status      => l_return_status) ;
            -- If unexpected errors happen abort
            IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
    END IF;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    );
    RETURN FND_API.to_boolean(l_result) ;
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name
            );
        END IF;
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
END Validate_MatchFlags;
-- Funct name : Validate_MatchQty
-- Type       : Private
-- Function   : Validate a given Match Quantity
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_match_int_id           IN NUMBER
--              p_corrected_match_id     IN NUMBER
--              p_updated_match_id       IN NUMBER
--              p_ship_line_id           IN NUMBER
--              p_matched_qty            IN NUMBER
--              p_matched_uom_code       IN VARCHAR2
--              p_replace_estim_qty_flag IN VARCHAR2
--              p_match_type_code        IN VARCHAR2
--
-- OUT        : x_return_status          IN OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Validate_MatchQty(
    p_match_int_id           IN NUMBER,
    p_corrected_match_id     IN NUMBER,
    p_updated_match_id       IN NUMBER,
    p_ship_line_id           IN NUMBER,
    p_matched_qty            IN NUMBER,
    p_matched_uom_code       IN VARCHAR2,
    p_replace_estim_qty_flag IN VARCHAR2,
    p_match_type_code        IN VARCHAR2,
    x_return_status          OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
    l_program_name     CONSTANT VARCHAR2(30) := 'Validate_MatchQty';
    l_debug_info    VARCHAR2(400) ;
    l_return_status VARCHAR2(1) ;
    l_result        VARCHAR2(1) := L_FND_TRUE;
    CURSOR processed_matches
    IS
         SELECT m1.match_id,
            m1.matched_qty ,
            m1.matched_uom_code
         FROM inl_corr_matches_v m1
         WHERE m1.to_parent_table_name   = 'INL_SHIP_LINES'
         AND m1.to_parent_table_id     = p_ship_line_id
         AND m1.match_type_code        = 'ITEM'
         AND m1.replace_estim_qty_flag = 'N'
         -- In case of resubmit the same actual value more than once, the
         -- new line is created as existing_match_info_flag = 'Y'.
         -- For checking purposes, it will consider only the latest record
         AND m1.match_id IN (SELECT MAX(m2.match_id)
                             FROM inl_corr_matches_v m2
                             WHERE m2.to_parent_table_name   = m1.to_parent_table_name
                             AND m2.to_parent_table_id     = m1.to_parent_table_id
                             AND m2.from_parent_table_name = m1.from_parent_table_name
                             AND m2.from_parent_table_id   = m1.from_parent_table_id
                             AND m2.match_type_code        = 'ITEM'
                             AND m2.replace_estim_qty_flag = 'N'
                            )
    ;

    TYPE processed_matches_List_Type IS TABLE OF processed_matches%ROWTYPE;
    processed_matches_List processed_matches_List_Type;
    CURSOR OI_matches
    IS
        SELECT m1.transaction_type,
            m1.match_type_code    ,
            m1.match_int_id       ,
            m1.matched_qty        ,
            m1.matched_uom_code   ,
            m1.replace_estim_qty_flag
        FROM inl_matches_int m1
        WHERE m1.to_parent_table_name   = 'INL_SHIP_LINES'
        AND m1.to_parent_table_id     = p_ship_line_id
        AND m1.match_int_id          <> NVL(p_updated_match_id, 0)
        AND m1.processing_status_code = 'RUNNING'
        ORDER BY m1.match_int_id
    ;

    TYPE OI_matches_List_Type IS TABLE OF OI_matches%ROWTYPE;
    OI_matches_List OI_matches_List_Type;
--Bug#9660043     l_ship_header_id     NUMBER;
--Bug#9660043     l_ship_line_num      NUMBER;
--Bug#9660043     l_ship_line_group_id NUMBER;
    l_qty                NUMBER;
    l_actual_qty         NUMBER := 0;
    l_aux_qty            NUMBER;
    l_match_qty          NUMBER;
    l_UOM_code           VARCHAR2(3) ;
    l_organization_id    NUMBER;
    l_inventory_item_id  NUMBER;
    l_matches            VARCHAR2(20000);
    l_unproc_actual_qty  NUMBER;
    l_unproc_UOM_code    VARCHAR2(3);
    l_unproc_match_id    NUMBER;
    OI_matches_qty       NUMBER;
    OI_matches_UOM_code  VARCHAR2(3);
    OI_match_type_code   VARCHAR2(30);
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    ) ;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;
    -- Get ship_header_id and the ship_line_num from Shipment Lines table
    -- to be used as criteria in the search for estimated values(Adjustment View)
    -- Get Organization_Id for UOM conversion purpose
    l_debug_info := 'Getting:  Organization_Id, Inventory_item_id and transaction qty and uom ';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    ) ;
    SELECT
        sh.organization_id      ,--Bug#9660043
--Bug#9660043         sl.ship_header_id       ,
--Bug#9660043         sl.ship_line_num        ,
        sl.inventory_item_id    ,
--Bug#9660043         sl.ship_line_group_id   ,
        sla.txn_qty             , --Bug#9660043
        sla.txn_uom_code          --Bug#9660043
    INTO
        l_organization_id   , --Bug#9660043
--Bug#9660043         l_ship_header_id    ,
--Bug#9660043         l_ship_line_num     ,
        l_inventory_item_id ,
--Bug#9660043         l_ship_line_group_id,
        l_qty               , --Bug#9660043
        l_uom_code            --Bug#9660043
    FROM
        inl_ship_lines_all sl, --Bug#10381495
        inl_ship_headers_all sh, --Bug#9660043 --Bug#10381495
        inl_adj_ship_lines_v sla
    WHERE sl.ship_line_id       = p_ship_line_id
    AND   sh.ship_header_id     = sl.ship_header_id --Bug#9660043
    AND   sla.ship_header_id    = sl.ship_header_id --Bug#9660043
    AND   sla.ship_line_group_id= sl.ship_line_group_id --Bug#9660043
    AND   sla.ship_line_num     = sl.ship_line_num; --Bug#9660043
/* --Bug#9660043
    -- Get Organization_Id for UOM conversion purpose
    SELECT sh.organization_id
    INTO l_organization_id
    FROM inl_ship_headers sh
    WHERE sh.ship_header_id = l_ship_header_id;
    l_debug_info := 'Get from Adjustment View the TXN_QTY and TXN_UOM_CODE';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    ) ;
    SELECT sla.txn_qty,
           sla.txn_uom_code
    INTO l_qty,
         l_uom_code
    FROM inl_adj_ship_lines_v sla
    WHERE sla.ship_header_id = l_ship_header_id
    AND sla.ship_line_group_id = l_ship_line_group_id
    AND sla.ship_line_num      = l_ship_line_num;
*/

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'l_qty',
        p_var_value      => l_qty
    ) ;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'l_UOM_code',
        p_var_value      => l_UOM_code
    ) ;
    -- Check if there is any match line as
    -- replace_estim_qty_flag = 'Y' and adj_already_generated_flag = 'N'
    -- In this case it will affect the estimated quantity when processed
    l_debug_info := 'Get values from unprocessed matches';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    ) ;
    BEGIN
        SELECT m1.matched_qty,
               m1.matched_uom_code,
               m1.match_id
        INTO l_unproc_actual_qty,
             l_unproc_uom_code,
             l_unproc_match_id
        FROM inl_corr_matches_v m1
        WHERE m1.to_parent_table_name = 'INL_SHIP_LINES'
        AND m1.to_parent_table_id = p_ship_line_id
        AND m1.match_type_code = 'ITEM'
        AND m1.replace_estim_qty_flag = 'Y'
        AND m1.adj_already_generated_flag = 'N'
        -- For checking purposes, it will consider only
        -- the latest and not processed record
        AND m1.match_id IN (SELECT MAX(m2.match_id)
                            FROM inl_corr_matches_v m2
                            WHERE m2.to_parent_table_name     = m1.to_parent_table_name
                            AND m2.to_parent_table_id         = m1.to_parent_table_id
                            AND m2.match_type_code            = 'ITEM'
                            AND m2.replace_estim_qty_flag     = 'Y'
                            AND m2.adj_already_generated_flag = 'N'
                            )
        ;
        l_qty        := l_unproc_actual_qty;
        l_UOM_code   := l_unproc_UOM_code;
        l_debug_info := 'Unprocessed value as replace_estim_qty_flag = Y:';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_debug_info     => l_debug_info
        ) ;
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'l_qty',
            p_var_value      => l_qty
        ) ;
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'l_uom_code',
            p_var_value      => l_uom_code
        ) ;
        IF p_updated_match_id = l_unproc_match_id THEN
            l_qty := p_matched_qty;
            l_UOM_code := p_matched_uom_code;
            l_debug_info := 'Unprocessed value will be updated by the current record(replace_estim_qty_flag = Y):';
            INL_LOGGING_PVT.Log_Statement(
                p_module_name      => g_module_name,
                p_procedure_name   => l_program_name,
                p_debug_info       => l_debug_info
            ) ;
                    INL_LOGGING_PVT.Log_Variable(
                        p_module_name    => g_module_name,
                        p_procedure_name => l_program_name,
                        p_var_name       => 'l_qty',
                        p_var_value      => l_qty
                    ) ;
                    INL_LOGGING_PVT.Log_Variable(
                        p_module_name    => g_module_name,
                        p_procedure_name => l_program_name,
                        p_var_name       => 'l_UOM_code',
                        p_var_value      => l_UOM_code
                    ) ;
        END IF;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        NULL;
    END;
    -- Check if there is any match line as
    -- replace_estim_qty_flag = 'N' and adj_already_generated_flag = 'N'
    l_debug_info := 'Get actual values from unprocessed matches';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    ) ;
    BEGIN
        SELECT SUM(decode(m1.matched_uom_code,
                          l_uom_code, m1.matched_qty,
                          NVL(inl_landedcost_pvt.Converted_Qty(l_organization_id,
                                                               l_inventory_item_id,
                                                               m1.matched_qty,
                                                               m1.matched_uom_code,
                                                               l_uom_code
                                                              )
                             ,0)
                         )
                  )
        INTO l_unproc_actual_qty
        FROM inl_corr_matches_v m1
        WHERE m1.to_parent_table_name = 'INL_SHIP_LINES'
        AND m1.to_parent_table_id     = p_ship_line_id
        AND m1.match_type_code        = 'ITEM'
        AND m1.replace_estim_qty_flag = 'N'
        AND m1.adj_already_generated_flag = 'N'
        ;
        l_debug_info := 'Actuals from unprocessed Matches(replace_estim_qty_flag = N):';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info
        ) ;
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'l_unproc_actual_qty',
            p_var_value      => l_unproc_actual_qty
        ) ;
        l_actual_qty := l_actual_qty + l_unproc_actual_qty;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
    END;
    l_debug_info := 'Get values from processed matches';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    ) ;
    OPEN processed_matches;
    FETCH processed_matches BULK COLLECT INTO processed_matches_List;
    CLOSE processed_matches;
    FOR iMat IN 1 .. processed_matches_List.COUNT
    LOOP
            IF NVL(processed_matches_List(iMat).matched_qty, 0) <> 0 THEN
                l_matches := l_matches ||processed_matches_List(iMat) .match_id||', ';
                IF processed_matches_List(iMat).matched_uom_code <> l_UOM_code THEN
                    l_actual_qty := NVL(l_actual_qty, 0) +
                                    NVL(inl_landedcost_pvt.Converted_Qty( p_organization_id => l_organization_id,
                                                                          p_inventory_item_id => l_inventory_item_id,
                                                                          p_qty => processed_matches_List(iMat) .matched_qty,
                                                                          p_from_uom_code => processed_matches_List(iMat) .matched_uom_code,
                                                                          P_to_uom_code => l_UOM_code), 0) ;
                ELSE
                    l_actual_qty := NVL(l_actual_qty, 0) + NVL(processed_matches_List(iMat).matched_qty, 0) ;
                END IF;
            END IF;
    END LOOP;
    l_debug_info := 'Actuals from processed matches:';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    ) ;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'l_actual_qty',
        p_var_value      => l_actual_qty
    ) ;
    l_debug_info := 'Get values from not interfaced matches';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    ) ;
    OPEN OI_matches;
    FETCH OI_matches BULK COLLECT INTO OI_matches_List;
    CLOSE OI_matches;
    l_matches := l_matches ||'/ OI_mathes: ';
    IF NVL(OI_matches_List.COUNT, 0) > 0 THEN
        FOR iMat IN 1 .. OI_matches_List.COUNT
        LOOP
            l_debug_info := 'Get values from not interfaced matches';
            INL_LOGGING_PVT.Log_Statement(
                p_module_name      => g_module_name,
                p_procedure_name   => l_program_name,
                p_debug_info       => l_debug_info
            ) ;
            l_matches := l_matches ||OI_matches_List(iMat) .MATCH_INT_ID ;
            IF OI_matches_List(iMat) .replace_estim_qty_flag = 'Y' THEN
                IF OI_matches_List(iMat).transaction_type <> 'DELETE' THEN
                    l_qty := OI_matches_List(iMat) .matched_qty;
                    l_UOM_code := OI_matches_List(iMat) .matched_UOM_code;
                    l_debug_info := 'New estimated values from match interface:';
                    INL_LOGGING_PVT.Log_Statement(
                        p_module_name      => g_module_name,
                        p_procedure_name   => l_program_name,
                        p_debug_info       => l_debug_info
                    ) ;
                    INL_LOGGING_PVT.Log_Variable(
                        p_module_name    => g_module_name,
                        p_procedure_name => l_program_name,
                        p_var_name       => 'l_qty',
                        p_var_value      => l_qty
                    ) ;
                    INL_LOGGING_PVT.Log_Variable(
                        p_module_name    => g_module_name,
                        p_procedure_name => l_program_name,
                        p_var_name       => 'l_uom_code',
                        p_var_value      => l_uom_code
                    ) ;

                END IF;
            ELSIF OI_matches_List(iMat).match_type_code   = 'ITEM' THEN
                IF OI_matches_List(iMat).transaction_type = 'CREATE' THEN
                    OI_matches_qty := OI_matches_List(iMat) .matched_qty;
                    OI_matches_UOM_code := OI_matches_List(iMat).matched_UOM_code;
                END IF;
                IF OI_matches_UOM_code <> l_UOM_code THEN
                    l_actual_qty := NVL(l_actual_qty, 0)
                                    + NVL(inl_landedcost_pvt.Converted_Qty(
                                              p_organization_id => l_organization_id,
                                              p_inventory_item_id => l_inventory_item_id,
                                              p_qty => OI_matches_qty,
                                              p_from_uom_code => OI_matches_UOM_code,
                                              P_to_uom_code => l_UOM_code)
                                    , 0)
                    ;
                ELSE
                    l_actual_qty := NVL(l_actual_qty, 0) + NVL(OI_matches_qty, 0) ;
                END IF;
            END IF;
            l_debug_info := 'End Loop';
            INL_LOGGING_PVT.Log_Statement(
                p_module_name      => g_module_name,
                p_procedure_name   => l_program_name,
                p_debug_info       => l_debug_info
            );
                    INL_LOGGING_PVT.Log_Variable(
                        p_module_name    => g_module_name,
                        p_procedure_name => l_program_name,
                        p_var_name       => 'l_actual_qty',
                        p_var_value      => l_actual_qty
                    ) ;

        END LOOP;
    END IF;
    IF p_matched_uom_code <> l_UOM_code THEN
        l_match_qty := NVL(inl_landedcost_pvt.Converted_Qty(
                            p_organization_id   => l_organization_id,
                            p_inventory_item_id => l_inventory_item_id,
                            p_qty               => p_matched_qty,
                            p_from_uom_code     => p_matched_uom_code,
                            P_to_uom_code       => l_UOM_code), 0)
        ;
    ELSE
        l_match_qty := NVL(p_matched_qty, 0) ;
    END IF;
    IF p_replace_estim_qty_flag = 'Y' THEN
        l_qty := NVL(l_match_qty, 0) ;
    ELSIF p_match_type_code <> 'CORRECTION' THEN
        l_actual_qty := NVL(l_actual_qty, 0) + NVL(l_match_qty, 0) ;
    END IF;
    IF NVL(l_actual_qty, 0) > NVL(l_qty, 0) THEN
        l_result := L_FND_FALSE;
        l_debug_info := 'Insufficient estimated quantity('||l_qty||') for the actuals received('||l_actual_qty||')'|| l_matches;
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info
        );
        -- Add a line into inl_ship_errors
        Handle_InterfError(
            p_parent_table_name  => 'INL_MATCHES_INT',
            p_parent_table_id    => p_match_int_id,
            p_column_name        => 'MATCHED_QTY',
            p_column_value       => p_matched_qty,
            p_error_message_name => 'INL_ERR_OI_MAT_INSUF_EST_QTY',
            p_token1_name        => 'EST_QTY',
            p_token1_value       => l_qty,
            p_token2_name        => 'ACT_QTY',
            p_token2_value       => l_actual_qty,
            p_token3_name        => 'MATCH_INT_ID',
            p_token3_value       => p_match_int_id,
            x_return_status      => l_return_status
        ) ;
        -- If unexpected errors happen abort
        IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;
    l_debug_info := 'Trace: '||l_matches;
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    );
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    );
    RETURN FND_API.to_boolean(l_result) ;
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name
            );
        END IF;
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
END Validate_MatchQty;
-- Funct name : Validate_MatchTax
-- Type       : Private
-- Function   : Validate a given Match Tax
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_match_int_id           IN NUMBER
--              p_tax_code               IN VARCHAR2
--              p_nrec_tax_amt           IN NUMBER
--              p_tax_amt_included_flag  IN VARCHAR2
--              p_matched_amt            IN NUMBER
--              p_match_type_code        IN VARCHAR2
--              p_parent_match_type_code IN VARCHAR2
--
-- OUT        : x_return_status          OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Validate_MatchTax(
    p_match_int_id           IN NUMBER,
    p_tax_code               IN VARCHAR2,
    p_nrec_tax_amt           IN NUMBER,
    p_tax_amt_included_flag  IN VARCHAR2,
    p_matched_amt            IN NUMBER,
    p_match_type_code        IN VARCHAR2,
    p_parent_match_type_code IN VARCHAR2,
    x_return_status          OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
    l_program_name     CONSTANT VARCHAR2(30) := 'Validate_MatchTax';
    l_debug_info    VARCHAR2(400) ;
    l_return_status VARCHAR2(1) ;
    l_result        VARCHAR2(1) := L_FND_TRUE;
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    ) ;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;
    IF NVL(p_parent_match_type_code, p_match_type_code) = 'TAX' THEN
        l_debug_info     := 'Check: The unrecoverable amount should be smaller or equal to matched amount';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info
        );
        IF (NVL(p_nrec_tax_amt, 0) > NVL(p_matched_amt, 0) --BUG#8198265
            AND NVL(p_nrec_tax_amt, 0) > 0)
            OR
            (NVL(p_nrec_tax_amt, 0) < NVL(p_matched_amt, 0)
            AND NVL(p_matched_amt, 0) < 0
            AND NVL(p_nrec_tax_amt, 0) < 0)
        THEN
            l_result     := L_FND_FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name  => 'INL_MATCHES_INT',
                p_parent_table_id    => p_match_int_id,
                p_column_name        => 'NREC_TAX_AMT',
                p_column_value       => p_nrec_tax_amt,
                p_error_message_name => 'INL_ERR_OI_CHK_NREC_TAX_AMT',
                p_token1_name        => 'MATCH_INT_ID',
                p_token1_value       => p_match_int_id,
                x_return_status      => l_return_status
            ) ;
            -- If unexpected errors happen abort
            IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
        l_debug_info := 'Check: TAX_CODE cannot be null';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info
        );
        IF p_tax_code                               IS NULL THEN
            l_result := L_FND_FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name  => 'INL_MATCHES_INT',
                p_parent_table_id    => p_match_int_id,
                p_column_name        => 'TAX_CODE',
                p_column_value       => p_tax_code,
                p_error_message_name => 'INL_ERR_OI_CHK_TX_CODE_NULL',
                p_token1_name        => 'MATCH_INT_ID',
                p_token1_value       => p_match_int_id,
                x_return_status      => l_return_status
            ) ;
            -- If unexpected errors happen abort
            IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
        l_debug_info := 'Check: TAX_AMT_INCLUDED_FLAG cannot be null';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info
        );
        IF p_tax_amt_included_flag IS NULL THEN
            l_result := L_FND_FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name  => 'INL_MATCHES_INT',
                p_parent_table_id    => p_match_int_id,
                p_column_name        => 'TAX_AMT_INCLUDED_FLAG',
                p_column_value       => p_tax_amt_included_flag,
                p_error_message_name => 'INL_ERR_OI_CHK_TX_AMT_FLG_NULL',
                p_token1_name        => 'MATCH_INT_ID',
                p_token1_value       => p_match_int_id,
                x_return_status      => l_return_status
            ) ;
            -- If unexpected errors happen abort
            IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
    ELSIF p_tax_amt_included_flag IS NOT NULL OR p_tax_code IS NOT NULL OR NVL(p_nrec_tax_amt, 0) <> 0 THEN
        l_result := L_FND_FALSE;
        -- Add a line into inl_ship_errors
        Handle_InterfError(
            p_parent_table_name  => 'INL_MATCHES_INT',
            p_parent_table_id    => p_match_int_id,
            p_column_name        => 'TAX_INT_ID',
            p_column_value       => p_match_int_id,
            p_error_message_name => 'INL_ERR_OI_CHK_TX_FIELD_NNULL',
            p_token1_name        => 'MATCH_INT_ID',
            p_token1_value       => p_match_int_id,
            x_return_status      => l_return_status
        ) ;
        -- If unexpected errors happen abort
        IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    );
    RETURN FND_API.to_boolean(l_result) ;
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name
            );
        END IF;
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
END Validate_MatchTax;
-- Funct name : Validate_MatchAmt
-- Type       : Private
-- Function   : Validate a given Match Amount
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_match_int_id             IN NUMBER
--              p_parent_matched_curr_code IN VARCHAR2
--              p_parent_match_type_code   IN VARCHAR2
--              p_match_type_code          IN VARCHAR2
--              p_matched_amt              IN NUMBER
--              p_matched_curr_code        IN VARCHAR2
--              p_matched_curr_conv_type   IN VARCHAR2
--              p_matched_curr_conv_date   IN DATE
--              p_matched_curr_conv_rate   IN NUMBER
--              p_replace_estim_qty_flag   IN VARCHAR2
--
-- IN OUT     : x_return_status            OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Validate_MatchAmt(
    p_match_int_id             IN NUMBER,
    p_parent_matched_curr_code IN VARCHAR2,
    p_parent_match_type_code   IN VARCHAR2,
    p_match_type_code          IN VARCHAR2,
    p_matched_amt              IN NUMBER,
    p_matched_curr_code        IN VARCHAR2,
    p_matched_curr_conv_type   IN VARCHAR2,
    p_matched_curr_conv_date   IN DATE,
    p_matched_curr_conv_rate   IN NUMBER,
    p_replace_estim_qty_flag   IN VARCHAR2,
    x_return_status            OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
    l_program_name     CONSTANT VARCHAR2(30) := 'Validate_MatchAmt';
    l_debug_info    VARCHAR2(400) ;
    l_return_status VARCHAR2(1) ;
    l_result        VARCHAR2(1) := L_FND_TRUE;
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    ) ;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;
    l_debug_info := 'Check in case of correction, the currency must be the same of the original';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    );
    IF p_match_type_code = 'CORRECTION' THEN
        IF p_parent_matched_curr_code           <> p_matched_curr_code THEN
            l_result                            := L_FND_FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name  => 'INL_MATCHES_INT',
                p_parent_table_id    => p_match_int_id,
                p_column_name        => 'MATCHED_AMT',
                p_column_value       => p_matched_amt,
                p_error_message_name => 'INL_ERR_OI_CHK_CURR_INV',
                p_token1_name        => 'CURR1',
                p_token1_value       => p_matched_curr_code,
                p_token2_name        => 'CURR2',
                p_token2_value       => p_parent_matched_curr_code,
                p_token3_name        => 'MATCH_INT_ID',
                p_token3_value       => p_match_int_id,
                x_return_status      => l_return_status) ;
            -- If unexpected errors happen abort
            IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
    END IF;
    l_debug_info := 'When replace_estim_qty_flag = "Y", the final Amount cannot be null';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    );
    IF p_replace_estim_qty_flag = 'Y'
       AND (p_matched_amt IS NULL OR NVL(p_matched_amt, 0) < 0)
    THEN
        l_result := L_FND_FALSE;
        -- Add a line into inl_ship_errors
        Handle_InterfError(
            p_parent_table_name  => 'INL_MATCHES_INT',
            p_parent_table_id    => p_match_int_id,
            p_column_name        => 'MATCHED_AMT',
            p_column_value       => p_matched_amt,
            p_error_message_name => 'INL_ERR_OI_CHK_AMT_NULL',
            p_token1_name        => 'MATCH_INT_ID',
            p_token1_value       => p_match_int_id,
            x_return_status      => l_return_status
        ) ;
        -- If unexpected errors happen abort
        IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    );
    RETURN FND_API.to_boolean(l_result) ;
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name
            );
        END IF;
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
END Validate_MatchAmt;
--/ SCM-051 Begin
-- Funct name : Validate_MatchElcOnGoing
-- Type       : Private
-- Function   : Validate a given UOM code used by the Matching Process
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_match_int_id              IN NUMBER
--              p_matched_uom_code          IN VARCHAR2
--              p_match_type_code           IN VARCHAR2
--              p_parent_match_type_code    IN VARCHAR2
--
-- IN OUT     : x_return_status      OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Validate_MatchElcOnGoing(
    p_match_int_id           IN NUMBER,
    p_to_parent_table_name   IN VARCHAR2,
    p_to_parent_table_id     IN VARCHAR2,
    p_match_type_code        IN VARCHAR2,
    p_charge_line_type_id    IN VARCHAR2,
    x_return_status          OUT NOCOPY VARCHAR2
)RETURN BOOLEAN IS
    l_program_name     CONSTANT VARCHAR2(30) := 'Validate_MatchElcOnGoing';
    l_debug_info    VARCHAR2(400) ;
    l_return_status VARCHAR2(1) ;
    l_result        VARCHAR2(1) := L_FND_TRUE;

    l_new_currency_conversion_rate NUMBER;
    l_new_currency_conversion_date DATE;
    l_new_currency_conversion_type VARCHAR2(30);
    l_new_txn_unit_price           NUMBER;
    l_count_elc_ong                NUMBER;
    l_ship_num                     VARCHAR2(25); -- SCM-051
    l_group_id                     NUMBER; -- SCM-051

  -- ORA-00054 is the resource busy exception, which is raised when trying
  -- to lock a row that is already locked by another session.
  RESOURCE_BUSY EXCEPTION;
  PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -00054);

BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    ) ;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;
    l_debug_info         := 'Validate if exist any ELC update on going.';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    );

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_match_int_id',
        p_var_value      =>  p_match_int_id);

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_to_parent_table_name',
        p_var_value      =>  p_to_parent_table_name);

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_to_parent_table_id',
        p_var_value      =>  p_to_parent_table_id);

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_match_type_code',
        p_var_value      =>  p_match_type_code);

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_charge_line_type_id',
        p_var_value      =>  p_charge_line_type_id);

    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => 'Verify if Ship Line has an ELC update'
    );
    -- If ship line has ELC on going any actual is unnacceptable
    IF p_match_type_code = 'ITEM' THEN

        INL_LOGGING_PVT.Log_Statement(
            p_module_name => g_module_name,
            p_procedure_name => l_program_name,
            p_debug_info => 'Verify if any related Ship Line has an ELC update');

        IF p_to_parent_table_name = 'RCV_TRANSACTIONS' THEN

            INL_LOGGING_PVT.Log_Statement(
                p_module_name => g_module_name,
                p_procedure_name => l_program_name,
                p_debug_info => 'Verify if Ship Line has an ELC update to parent RCV_TRANSACTIONS with FOR UPDATE of inl_ship_headers');

            SELECT
                sl.new_currency_conversion_rate,
                sl.new_currency_conversion_date,
                sl.new_currency_conversion_type,
                sl.new_txn_unit_price,
                sh.ship_num
            INTO
                l_new_currency_conversion_rate,
                l_new_currency_conversion_date,
                l_new_currency_conversion_type,
                l_new_txn_unit_price,
                l_ship_num -- SCM-051
            FROM
                rcv_transactions rt,
                inl_adj_ship_lines_v sl,
                inl_ship_headers_all sh -- SCM-051
            WHERE
                rt.transaction_id = p_to_parent_table_id
            AND sh.ship_header_id = sl.ship_header_id -- SCM-051
            AND NVL(sl.parent_ship_line_id,sl.ship_line_id)   = rt.lcm_shipment_line_id
            FOR UPDATE of sh.ship_header_id NOWAIT; -- SCM-051
        ELSIF p_to_parent_table_name = 'INL_SHIP_LINES' THEN

            INL_LOGGING_PVT.Log_Statement(
                p_module_name => g_module_name,
                p_procedure_name => l_program_name,
                p_debug_info => 'Verify if Ship Line has an ELC update to parent INL_SHIP_LINES with FOR UPDATE of inl_ship_headers');

            SELECT
                sl.new_currency_conversion_rate,
                sl.new_currency_conversion_date,
                sl.new_currency_conversion_type,
                sl.new_txn_unit_price,
                sh.ship_num
            INTO
                l_new_currency_conversion_rate,
                l_new_currency_conversion_date,
                l_new_currency_conversion_type,
                l_new_txn_unit_price,
                l_ship_num
            FROM
                inl_adj_ship_lines_v sl,
                inl_ship_headers_all sh -- SCM-051
            WHERE
                 sh.ship_header_id = sl.ship_header_id -- SCM-051
            AND  NVL(sl.parent_ship_line_id,sl.ship_line_id)   = p_to_parent_table_id
            FOR UPDATE of sh.ship_header_id NOWAIT; -- SCM-051

        END IF;
        IF l_new_currency_conversion_rate IS NOT NULL
        OR l_new_currency_conversion_date IS NOT NULL
        OR l_new_currency_conversion_type IS NOT NULL
        OR l_new_txn_unit_price IS NOT NULL
        THEN

            INL_LOGGING_PVT.Log_Statement(
                p_module_name => g_module_name,
                p_procedure_name => l_program_name,
                p_debug_info => 'ELC Update on going to p_to_parent_table_id: ' || p_to_parent_table_id);

            INL_LOGGING_PVT.Log_Variable(
                p_module_name    => g_module_name,
                p_procedure_name => l_program_name,
                p_var_name       => 'l_new_currency_conversion_rate',
                p_var_value      =>  l_new_currency_conversion_rate);
            INL_LOGGING_PVT.Log_Variable(
                p_module_name    => g_module_name,
                p_procedure_name => l_program_name,
                p_var_name       => 'l_new_currency_conversion_date',
                p_var_value      =>  l_new_currency_conversion_date);
            INL_LOGGING_PVT.Log_Variable(
                p_module_name    => g_module_name,
                p_procedure_name => l_program_name,
                p_var_name       => 'l_new_currency_conversion_type',
                p_var_value      =>  l_new_currency_conversion_type);
            INL_LOGGING_PVT.Log_Variable(
                p_module_name    => g_module_name,
                p_procedure_name => l_program_name,
                p_var_name       => 'l_new_txn_unit_price',
                p_var_value      =>  l_new_txn_unit_price);
            l_result := L_FND_FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name  => 'INL_MATCHES_INT',
                p_parent_table_id    => p_match_int_id,
                p_column_name        => 'p_match_int_id',
                p_column_value       => p_match_int_id,
                p_error_message_name => 'INL_ERR_OI_CHK_ELC_UPDATE',
                p_token1_name        => 'MATCH_INT_ID',
                p_token1_value       => p_match_int_id,
                p_token2_name        => 'SHIP_NUM',
                p_token2_value       => l_ship_num,
                p_token3_name        => 'SHIP_NUM',
                p_token3_value       => l_ship_num,
                x_return_status      => l_return_status
            ) ;
            -- If unexpected errors happen abort
            IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
    ELSIF p_match_type_code = 'CHARGE' THEN

        INL_LOGGING_PVT.Log_Statement(
            p_module_name => g_module_name,
            p_procedure_name => l_program_name,
            p_debug_info => 'Verify if any related charge Line has an ELC update');

        IF p_to_parent_table_name = 'RCV_TRANSACTIONS' THEN

            INL_LOGGING_PVT.Log_Statement(
                p_module_name => g_module_name,
                p_procedure_name => l_program_name,
                p_debug_info => 'Select FOR UPDATE of inl_ship_headers');

            -- SCM-051
            SELECT sh.ship_num
            INTO l_ship_num
            FROM inl_ship_headers_all sh,
                 inl_ship_lines_all sl,
                 rcv_transactions rt
            WHERE sh.ship_header_id = sl.ship_header_id
            AND rt.transaction_id = p_to_parent_table_id
            AND NVL(sl.parent_ship_line_id,sl.ship_line_id) = rt.lcm_shipment_line_id
            AND ROWNUM = 1
            FOR UPDATE OF sh.ship_header_id NOWAIT;
            -- /SCM-051

            INL_LOGGING_PVT.Log_Statement(
                p_module_name => g_module_name,
                p_procedure_name => l_program_name,
                p_debug_info => 'Verify if Charge Line has an ELC update to parent RCV_TRANSACTIONS');

            SELECT
                NVL(COUNT(*),0)
            INTO
                l_count_elc_ong
            FROM
                inl_adj_charge_lines_v cl,
                inl_associations a,
                inl_ship_lines_all sl,
                rcv_transactions rt
            WHERE
                rt.transaction_id = p_to_parent_table_id
            AND NVL(sl.parent_ship_line_id,sl.ship_line_id) = rt.lcm_shipment_line_id
            AND a.from_parent_table_name = 'INL_CHARGE_LINES'
            AND (
                 (a.to_parent_table_name = 'INL_SHIP_HEADERS'
                  AND a.to_parent_table_id = sl.ship_header_id)
                 OR
                 (a.to_parent_table_name = 'INL_SHIP_LINE_GROUPS'
                  AND a.to_parent_table_id = sl.ship_line_group_id)
                 OR
                 (a.to_parent_table_name = 'INL_SHIP_LINES'
                  AND a.to_parent_table_id = NVL(sl.parent_ship_line_id,sl.ship_line_id))
                 )
            AND cl.charge_line_type_id = p_charge_line_type_id
            AND cl.adjustment_num <= 0
            AND cl.charge_line_id IN
                (
                    SELECT
                        cl1.charge_line_id
                     FROM
                        inl_charge_lines cl1
                    WHERE
                    CONNECT_BY_ISLEAF = 1
                    START WITH cl1.charge_line_id = a.from_parent_table_id
                    CONNECT BY PRIOR cl1.charge_line_id = cl1.parent_charge_line_id
                )
            AND (cl.new_currency_conversion_rate IS NOT NULL
                 OR cl.new_currency_conversion_date IS NOT NULL
                 OR cl.new_currency_conversion_type IS NOT NULL
                 OR cl.new_charge_amt IS NOT NULL
                 OR cl.adjustment_type_flag = 'A') -- new ELC charge line waiting for submit
            ;

        ELSIF p_to_parent_table_name = 'INL_SHIP_LINES' THEN

            INL_LOGGING_PVT.Log_Statement(
                p_module_name => g_module_name,
                p_procedure_name => l_program_name,
                p_debug_info => 'Verify if Charge Line has an ELC update to parent INL_SHIP_LINES');

            -- SCM-051
            SELECT sh.ship_num
            INTO l_ship_num
            FROM inl_ship_headers_all sh,
                 inl_ship_lines_all sl
            WHERE sh.ship_header_id = sl.ship_header_id
            AND sl.ship_line_id = p_to_parent_table_id
            AND ROWNUM = 1
            FOR UPDATE OF sh.ship_header_id NOWAIT;
            -- /SCM-051

            INL_LOGGING_PVT.Log_Statement(
                p_module_name => g_module_name,
                p_procedure_name => l_program_name,
                p_debug_info => 'Verify if Charge Line has an ELC update to parent INL_SHIP_LINES');

            SELECT
                NVL(COUNT(*),0)
            INTO
                l_count_elc_ong
            FROM
                inl_adj_charge_lines_v cl,
                inl_associations a,
                inl_ship_lines_all sl
            WHERE
                sl.ship_line_id = p_to_parent_table_id
            AND a.from_parent_table_name = 'INL_CHARGE_LINES'
            AND (
                 (a.to_parent_table_name = 'INL_SHIP_HEADERS'
                  AND a.to_parent_table_id = sl.ship_header_id)
                 OR
                 (a.to_parent_table_name = 'INL_SHIP_LINE_GROUPS'
                  AND a.to_parent_table_id = sl.ship_line_group_id)
                 OR
                 (a.to_parent_table_name = 'INL_SHIP_LINES'
                  AND a.to_parent_table_id = NVL(sl.parent_ship_line_id,sl.ship_line_id))
                 )
            AND cl.charge_line_type_id = p_charge_line_type_id
            AND cl.adjustment_num <= 0
            AND (cl.new_currency_conversion_rate IS NOT NULL
                 OR cl.new_currency_conversion_date IS NOT NULL
                 OR cl.new_charge_amt IS NOT NULL
                 OR cl.adjustment_type_flag = 'A') -- new ELC charge line waiting for submit
            ;
        END IF;

        IF l_count_elc_ong > 0
        THEN
            INL_LOGGING_PVT.Log_Variable(
                p_module_name    => g_module_name,
                p_procedure_name => l_program_name,
                p_var_name       => 'l_count_elc_ong',
                p_var_value      =>  l_count_elc_ong);
            l_result     := L_FND_FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name  => 'INL_MATCHES_INT',
                p_parent_table_id    => p_match_int_id,
                p_column_name        => 'p_match_int_id',
                p_column_value       => p_match_int_id,
                p_error_message_name => 'INL_ERR_OI_CHK_ELC_UPDATE',
                p_token1_name        => 'MATCH_INT_ID',
                p_token1_value       => p_match_int_id,
                p_token2_name        => 'SHIP_NUM',
                p_token2_value       => l_ship_num,
                p_token3_name        => 'SHIP_NUM',
                p_token3_value       => l_ship_num,
                x_return_status      => l_return_status
            ) ;
            -- If unexpected errors happen abort
            IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
    END IF;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    );
    RETURN FND_API.to_boolean(l_result) ;
EXCEPTION
--Handling deadlock with proper error message
    WHEN RESOURCE_BUSY THEN

        SELECT m.group_id
        INTO l_group_id
        FROM inl_matches_int m
        WHERE m.match_int_id = p_match_int_id;

        x_return_status := FND_API.g_ret_sts_error;
        FND_MESSAGE.set_name('INL','INL_ERR_OI_CHK_LCK_SHIPMENT');
        FND_MESSAGE.set_token('GROUP_ID',l_group_id);
        FND_MSG_PUB.ADD;

        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE);
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name
            );
        END IF;
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
END Validate_MatchElcOnGoing;
--/ SCM-051 End

-- Funct name : Validate_MatchUOM
-- Type       : Private
-- Function   : Validate a given UOM code used by the Matching Process
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_match_int_id              IN NUMBER
--              p_matched_uom_code          IN VARCHAR2
--              p_match_type_code           IN VARCHAR2
--              p_parent_match_type_code    IN VARCHAR2
--
-- IN OUT     : x_return_status      OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Validate_MatchUOM(
    p_match_int_id           IN NUMBER,
    p_matched_uom_code       IN VARCHAR2,
    p_match_type_code        IN VARCHAR2,
    p_parent_match_type_code IN VARCHAR2,
    x_return_status          OUT NOCOPY VARCHAR2
)RETURN BOOLEAN IS
    l_program_name     CONSTANT VARCHAR2(30) := 'Validate_MatchUOM';
    l_debug_info    VARCHAR2(400) ;
    l_return_status VARCHAR2(1) ;
    l_result        VARCHAR2(1) := L_FND_TRUE;
    l_uom           VARCHAR2(100) ;
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    ) ;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;
    l_debug_info         := 'Validate the type of the corrected match in case of correction process.';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    );
    IF NVL(p_parent_match_type_code, p_match_type_code) = 'ITEM' THEN
        IF p_matched_uom_code IS NULL THEN
            l_result     := L_FND_FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name  => 'INL_MATCHES_INT',
                p_parent_table_id    => p_match_int_id,
                p_column_name        => 'MATCHED_UOM_CODE',
                p_column_value       => p_matched_uom_code,
                p_error_message_name => 'INL_ERR_OI_CHK_UOM_NULL',
                p_token1_name        => 'TYPE',
                p_token1_value       => p_match_type_code,
                p_token2_name        => 'MATCH_INT_ID',
                p_token2_value       => p_match_int_id,
                x_return_status      => l_return_status
            ) ;
            -- If unexpected errors happen abort
            IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        ELSE
            BEGIN
                -- Get UOM Code
                SELECT unit_of_measure
                INTO l_uom
                FROM mtl_units_of_measure
                WHERE uom_code = p_matched_uom_code;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_result := L_FND_FALSE;
                -- Add a line into inl_ship_errors
                Handle_InterfError(
                    p_parent_table_name  => 'INL_MATCHES_INT',
                    p_parent_table_id    => p_match_int_id,
                    p_column_name        => 'MATCHED_UOM_CODE',
                    p_column_value       => p_matched_uom_code,
                    p_error_message_name => 'INL_ERR_OI_CHK_UOM_INV',
                    p_token1_name        => 'MATCH_INT_ID',
                    p_token1_value       => p_match_int_id,
                    x_return_status      => l_return_status
                ) ;
                -- If unexpected errors happen abort
                IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
                    RAISE L_FND_EXC_UNEXPECTED_ERROR;
                END IF;
            END;
        END IF;
    ELSE
        IF p_matched_uom_code IS NOT NULL THEN
            l_result := L_FND_FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name  => 'INL_MATCHES_INT',
                p_parent_table_id    => p_match_int_id,
                p_column_name        => 'MATCHED_UOM_CODE',
                p_column_value       => p_matched_uom_code,
                p_error_message_name => 'INL_ERR_OI_CHK_UOM_NNULL',
                p_token1_name        => 'TYPE',
                p_token1_value       => p_match_type_code,
                p_token2_name        => 'MATCH_INT_ID',
                p_token2_value       => p_match_int_id,
                x_return_status      => l_return_status
            ) ;
            -- If unexpected errors happen abort
            IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
    END IF;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    );
    RETURN FND_API.to_boolean(l_result) ;
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name
            );
        END IF;
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
END Validate_MatchUOM;
-- Funct name : Validate_MatchMatIDS
-- Type       : Private
-- Function   : Validate Match Id and Parent Match Id
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_transaction_type IN VARCHAR2
--              p_match_int_id     IN NUMBER
--              p_match_id         IN NUMBER
--              p_parent_match_id  IN NUMBER
--              p_match_type_code  IN VARCHAR2
--              p_existing_match_info_flag IN VARCHAR2
--
-- IN OUT     : x_return_status    IN OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Validate_MatchMatIDS(
    p_transaction_type         IN VARCHAR2,
    p_match_int_id             IN NUMBER,
    p_match_id                 IN NUMBER,
    p_parent_match_id          IN NUMBER,
    p_match_type_code          IN VARCHAR2,
    p_existing_match_info_flag IN VARCHAR2,
    x_return_status            OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
    l_program_name        CONSTANT VARCHAR2(30) := 'Validate_MatchMatIDS';
    l_debug_info       VARCHAR2(400) ;
    l_return_status    VARCHAR2(1) ;
    l_result           VARCHAR2(1) := L_FND_TRUE;
    l_adj_alr_gen_flag VARCHAR2(1) ;
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    ) ;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;
    l_debug_info := 'Check: When match type code is CORRECTION, parent_match_id cannot be null';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    );
    IF p_match_type_code = 'CORRECTION' THEN
        IF p_parent_match_id IS NULL THEN
            l_result := L_FND_FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name  => 'INL_MATCHES_INT',
                p_parent_table_id    => p_match_int_id,
                p_column_name        => 'PARENT_MATCH_ID',
                p_column_value       => p_parent_match_id,
                p_error_message_name => 'INL_ERR_OI_CHK_MAT_ID_NULL',
                p_token1_name        => 'OPER',
                p_token1_value       => p_match_type_code,
                p_token2_name        => 'COL',
                p_token2_value       => 'PARENT_MATCH_ID',
                p_token3_name        => 'MATCH_INT_ID',
                p_token3_value       => p_match_int_id,
                x_return_status      => l_return_status
            ) ;
            -- If unexpected errors happen abort
            IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        ELSE
            BEGIN
                 SELECT adj_already_generated_flag
                   INTO l_adj_alr_gen_flag
                   FROM inl_matches
                  WHERE match_id = p_parent_match_id;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_result := L_FND_FALSE;
                    -- Add a line into inl_ship_errors
                    Handle_InterfError(
                        p_parent_table_name  => 'INL_MATCHES_INT',
                        p_parent_table_id    => p_match_int_id,
                        p_column_name        => 'PARENT_MATCH_ID',
                        p_column_value       => p_parent_match_id,
                        p_error_message_name => 'INL_ERR_OI_CHK_PAR_MAT_ID_NF',
                        p_token1_name        => 'COL_NAME',
                        p_token1_value       => 'PARENT_MATCH_ID',
                        p_token2_name        => 'COL_ID',
                        p_token2_value       => p_parent_match_id,
                        x_return_status      => l_return_status
                    ) ;
                    -- If unexpected errors happen abort
                    IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
                        RAISE L_FND_EXC_UNEXPECTED_ERROR;
                    END IF;
            END;
        END IF;
    ELSE -- p_match_type_code <> 'CORRECTION'
        IF p_parent_match_id IS NOT NULL AND p_existing_match_info_flag <> 'Y' THEN
            l_result := L_FND_FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name  => 'INL_MATCHES_INT',
                p_parent_table_id    => p_match_int_id,
                p_column_name        => 'PARENT_MATCH_ID',
                p_column_value       => p_parent_match_id,
                p_error_message_name => 'INL_ERR_OI_CHK_MAT_ID_NNULL',
                p_token1_name        => 'OPER',
                p_token1_value       => p_match_type_code,
                p_token2_name        => 'COL',
                p_token2_value       => 'PARENT_MATCH_ID',
                p_token3_name        => 'MATCH_INT_ID',
                p_token3_value       => p_match_int_id,
                x_return_status      => l_return_status
            ) ;
            -- If unexpected errors happen abort
            IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
        IF p_transaction_type <> 'CREATE' THEN
            l_debug_info := 'Check: When transaction type is not CREATE, match_id cannot be null';
            INL_LOGGING_PVT.Log_Statement(
                p_module_name      => g_module_name,
                p_procedure_name   => l_program_name,
                p_debug_info       => l_debug_info
            );
            IF p_match_id IS NULL THEN
                l_result := L_FND_FALSE;
                -- Add a line into inl_ship_errors
                Handle_InterfError(
                    p_parent_table_name  => 'INL_MATCHES_INT',
                    p_parent_table_id    => p_match_int_id,
                    p_column_name        => 'MATCH_ID',
                    p_column_value       => p_match_id,
                    p_error_message_name => 'INL_ERR_OI_CHK_MAT_ID_NULL',
                    p_token1_name        => 'OPER',
                    p_token1_value       => p_transaction_type,
                    p_token2_name        => 'COL',
                    p_token2_value       => 'MATCH_ID',
                    p_token3_name        => 'MATCH_INT_ID',
                    p_token3_value       => p_match_int_id,
                    x_return_status      => l_return_status
                ) ;
                -- If unexpected errors happen abort
                IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
                    RAISE L_FND_EXC_UNEXPECTED_ERROR;
                END IF;
            ELSE
                BEGIN
                     SELECT adj_already_generated_flag
                       INTO l_adj_alr_gen_flag
                       FROM inl_matches
                      WHERE match_id = p_match_id;
                    IF l_adj_alr_gen_flag <> 'N' THEN
                        l_result := L_FND_FALSE;
                        -- Add a line into inl_ship_errors
                        Handle_InterfError(
                            p_parent_table_name  => 'INL_MATCHES_INT',
                            p_parent_table_id    => p_match_int_id,
                            p_column_name        => 'MATCH_ID',
                            p_column_value       => p_match_id,
                            p_error_message_name => 'INL_ERR_OI_CHK_MAT_ADJUSTED',
                            p_token1_name        => 'MATCH_INT_ID',
                            p_token1_value       => p_match_int_id,
                            x_return_status      => l_return_status
                        ) ;
                        -- If unexpected errors happen abort
                        IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
                            RAISE L_FND_EXC_UNEXPECTED_ERROR;
                        END IF;
                    END IF;
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_result := L_FND_FALSE;
                    -- Add a line into inl_ship_errors
                    Handle_InterfError(
                        p_parent_table_name  => 'INL_MATCHES_INT',
                        p_parent_table_id    => p_match_int_id,
                        p_column_name        => 'MATCH_ID',
                        p_column_value       => p_match_id,
                        p_error_message_name => 'INL_ERR_OI_CHK_MAT_ID_NF',
                        p_token1_name        => 'COL_NAME',
                        p_token1_value       => 'MATCH_ID',
                        p_token2_name        => 'COL_ID',
                        p_token2_value       => p_match_id,
                        p_token3_name        => 'MATCH_INT_ID',
                        p_token3_value       => p_match_int_id,
                        x_return_status      => l_return_status
                    ) ;
                    -- If unexpected errors happen abort
                    IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
                        RAISE L_FND_EXC_UNEXPECTED_ERROR;
                    END IF;
                END;
            END IF;
        END IF;
    END IF;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    );
    RETURN FND_API.to_boolean(l_result) ;
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN OTHERS THEN
      -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name
            );
        END IF;
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
END Validate_MatchMatIDS;
-- Funct name : Validate_MatchToParTab
-- Type       : Private
-- Function   : Validate Match To_Parent values
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_transaction_type      IN VARCHAR2
--              p_match_int_id          IN NUMBER
--              p_match_id              IN NUMBER
--              p_parent_match_id       IN NUMBER
--              p_ship_header_id        IN NUMBER
--              p_to_parent_table_name  IN VARCHAR2
--              p_to_parent_table_id    IN NUMBER
--              p_match_type_code       IN VARCHAR2
--
-- IN OUT     : x_return_status         OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Validate_MatchToParTab(
    p_transaction_type     IN VARCHAR2,
    p_match_int_id         IN NUMBER,
    p_match_id             IN NUMBER,
    p_parent_match_id      IN NUMBER,
    p_ship_header_id       IN NUMBER,
    p_to_parent_table_name IN VARCHAR2,
    p_to_parent_table_id   IN NUMBER,
    p_match_type_code      IN VARCHAR2,
    x_return_status        OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
    l_program_name      CONSTANT VARCHAR2(30) := 'Validate_MatchToParTab';
    l_debug_info     VARCHAR2(400) ;
    l_return_status  VARCHAR2(1) ;
    l_result         VARCHAR2(1) := L_FND_TRUE;
    l_ship_header_id NUMBER;
    l_ship_line_id NUMBER;
    l_ship_header_id_tab inl_int_table := inl_int_table() ;
    l_nameOk         VARCHAR2(1) ;
    l_idOk           VARCHAR2(1) ;
    l_SHidOk         VARCHAR2(1) ;
    l_INT_importedOk VARCHAR2(1) ;
    l_matchTpCdOk    VARCHAR2(1) ;
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    ) ;
    --  Initialize API return status to success
    x_return_status                             := L_FND_RET_STS_SUCCESS;
    l_debug_info := 'Check to_parent_table value and all related information.';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    );
    l_nameOk          := 'N';
    l_idOk            := 'N';
    l_SHidOk          := 'N';
    l_matchTpCdOk     := 'N';
    l_INT_importedOk  := 'N';
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_to_parent_table_name',
        p_var_value      => p_to_parent_table_name
    ) ;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_to_parent_table_id',
        p_var_value      => p_to_parent_table_id
    ) ;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_transaction_type',
        p_var_value      => p_transaction_type
    ) ;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_match_type_code',
        p_var_value      => p_match_type_code
    ) ;

    IF p_to_parent_table_name IN('INL_SHIP_HEADERS',
                                 'INL_SHIP_LINES',
                                 'INL_SHIP_LINE_GROUPS',
                                 'INL_CHARGE_LINES',
                                 'INL_TAX_LINES',
                                 'RCV_TRANSACTIONS'
                                 )
    OR (p_transaction_type = 'CREATE'
        AND p_to_parent_table_name IN('INL_SHIP_LINES_INT',
                                      'INL_SHIP_HEADERS_INT')
       )
    OR(p_match_type_code = 'CORRECTION'
       AND p_to_parent_table_name IN('AP_INVOICE_DISTRIBUTIONS')
      )
    THEN
        l_nameOk := 'Y';
        BEGIN
            IF p_to_parent_table_name = 'INL_SHIP_HEADERS' THEN

                l_INT_importedOk     := 'Y';
                SELECT ship_header_id
                INTO l_ship_header_id
                FROM inl_ship_headers_all --Bug#10381495
                WHERE ship_header_id = p_to_parent_table_id;
                IF p_match_type_code   = 'CHARGE' THEN
                    l_matchTpCdOk     := 'Y';
                END IF;
            ELSIF p_to_parent_table_name = 'INL_SHIP_LINES' THEN
                l_INT_importedOk        := 'Y';
                SELECT ship_header_id
                INTO l_ship_header_id
                FROM inl_ship_lines_all --Bug#10381495
                WHERE ship_line_id  = p_to_parent_table_id;
                IF p_match_type_code IN('ITEM', 'CHARGE', 'TAX') THEN
                    l_matchTpCdOk    := 'Y';
                END IF;
            ELSIF p_to_parent_table_name = 'INL_SHIP_LINE_GROUPS' THEN
                l_INT_importedOk        := 'Y';
                SELECT ship_header_id
                INTO l_ship_header_id
                FROM inl_ship_line_groups
                WHERE ship_line_group_id = p_to_parent_table_id;
                IF p_match_type_code       = 'CHARGE' THEN
                    l_matchTpCdOk         := 'Y';
                END IF;
            ELSIF p_to_parent_table_name = 'INL_CHARGE_LINES' THEN
                l_INT_importedOk        := 'Y';
                l_ship_header_id_tab.DELETE;
                SELECT DISTINCT(a.ship_header_id)
                BULK COLLECT INTO l_ship_header_id_tab
                FROM inl_charge_lines c,
                inl_associations a
                WHERE c.charge_line_id              = p_to_parent_table_id
                AND a.from_parent_table_name      = 'INL_CHARGE_LINES'
                AND a.from_parent_table_id        = c.charge_line_id;
                IF NVL(l_ship_header_id_tab.COUNT, 0) = 1 THEN
                    l_ship_header_id                 := l_ship_header_id_tab(1) ;
                END IF;
                IF p_match_type_code IN('CHARGE', 'TAX') THEN
                    l_matchTpCdOk    := 'Y';
                END IF;
            ELSIF p_to_parent_table_name = 'INL_TAX_LINES' THEN
                l_INT_importedOk        := 'Y';
                SELECT ship_header_id
                INTO l_ship_header_id
                FROM inl_tax_lines
                WHERE tax_line_id   = p_to_parent_table_id;
                IF p_match_type_code IN('TAX') THEN
                    l_matchTpCdOk    := 'Y';
                END IF;
            ELSIF p_to_parent_table_name = 'INL_SHIP_LINES_INT' THEN
--Bug#9660043
                IF p_match_type_code IN('ITEM', 'CHARGE', 'TAX') THEN
                    l_matchTpCdOk       := 'Y';
                END IF;

                SELECT
                    NVL(sl.ship_header_id, sli.ship_header_id),
                    DECODE(sl.ship_header_id, NULL, 'N', 'Y')
                INTO
                    l_ship_header_id,
                    l_INT_importedOk
                FROM
                    inl_ship_lines_int sli,
                    inl_ship_lines_all sl --Bug#10381495
                WHERE
                    sli.ship_line_int_id = p_to_parent_table_id
                AND sl.ship_line_int_id  = p_to_parent_table_id;
--Bug#9660043

/* --Bug#9660043
                SELECT sli.ship_header_id
                INTO l_ship_header_id
                FROM inl_ship_lines_int sli
                WHERE sli.ship_line_int_id = p_to_parent_table_id;
                IF p_match_type_code IN('ITEM', 'CHARGE', 'TAX') THEN
                    l_matchTpCdOk       := 'Y';
                END IF;
                -- Check if the Interface has been imported
                SELECT sl.ship_header_id
                INTO l_ship_header_id
                FROM inl_ship_lines sl
                WHERE sl.ship_line_int_id = p_to_parent_table_id;
                l_INT_importedOk        := 'Y';
*/--Bug#9660043

            ELSIF p_to_parent_table_name = 'INL_SHIP_HEADERS_INT' THEN
--Bug#9660043
                IF p_match_type_code      IN('CHARGE') THEN
                    l_matchTpCdOk         := 'Y';
                END IF;

                SELECT
                    NVL(sh.ship_header_id, shi.ship_header_id),
                    DECODE(sh.ship_header_id, NULL, 'N', 'Y')
                INTO
                    l_ship_header_id,
                    l_INT_importedOk
                FROM
                    inl_ship_headers_int shi,
                    inl_ship_headers_all sh --Bug#10381495
                WHERE
                    shi.ship_header_int_id   = p_to_parent_table_id
                AND sh.ship_header_int_id    = p_to_parent_table_id
                ;
--Bug#9660043
/*--Bug#9660043
                SELECT shi.ship_header_id
                INTO l_ship_header_id
                FROM inl_ship_headers_int shi
                WHERE shi.ship_header_int_id = p_to_parent_table_id;

                IF p_match_type_code      IN('CHARGE') THEN
                    l_matchTpCdOk         := 'Y';
                END IF;

                -- Check if the Interface record has been imported
                SELECT sh.ship_header_id
                INTO l_ship_header_id
                FROM inl_ship_headers sh
                WHERE sh.ship_header_int_id = p_to_parent_table_id;
                l_INT_importedOk := 'Y';
*/--Bug#9660043

            ELSIF p_to_parent_table_name = 'RCV_TRANSACTIONS' THEN
--Bug#9660043
                l_INT_importedOk        := 'Y';

                IF p_match_type_code IN('ITEM', 'CHARGE', 'TAX') THEN
                    l_matchTpCdOk    := 'Y';
                END IF;

                SELECT
                    rt.lcm_shipment_line_id,
                    sl.ship_header_id
                INTO
                    l_ship_line_id,
                    l_ship_header_id
                FROM
                    rcv_transactions rt,
                    inl_ship_lines_all sl --Bug#10381495
                WHERE
                    rt.transaction_id = p_to_parent_table_id
                AND sl.ship_line_id   = rt.lcm_shipment_line_id
                ;
--Bug#9660043
/*--Bug#9660043
                SELECT  lcm_shipment_line_id
                INTO l_ship_line_id
                FROM rcv_transactions rt
                WHERE rt.transaction_id = p_to_parent_table_id;

               SELECT sl.ship_header_id
                INTO l_ship_header_id
                FROM inl_ship_lines sl
                WHERE sl.ship_line_id  = l_ship_line_id;
                IF p_match_type_code IN('ITEM', 'CHARGE', 'TAX') THEN
                    l_matchTpCdOk    := 'Y';
                END IF;
*/--Bug#9660043
            ELSE -- In case of correction, the table is out of LCM limit
                l_idOk           := 'Y';
                l_INT_importedOk := 'Y';
                SELECT ship_header_id
                INTO l_ship_header_id
                FROM inl_matches
                WHERE match_id     = p_parent_match_id;
                IF p_match_type_code = 'CORRECTION' THEN
                    l_matchTpCdOk   := 'Y';
                END IF;
            END IF;
            l_idOk              := 'Y';
            IF p_ship_header_id IS NULL OR l_ship_header_id = p_ship_header_id THEN
                l_SHidOk        := 'Y';
            END IF;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
        END;
    END IF;
    IF(l_nameOk  = 'N') THEN
        l_result := L_FND_FALSE;
        -- Add a line into inl_ship_errors
        Handle_InterfError(
            p_parent_table_name  => 'INL_MATCHES_INT',
            p_parent_table_id    => p_match_int_id,
            p_column_name        => 'TO_PARENT_TABLE_NAME',
            p_column_value       => p_to_parent_table_name,
            p_error_message_name => 'INL_ERR_OI_CHK_TO_PAR_TAB_NAME',
            p_token1_name        => 'NAME',
            p_token1_value       => 'INL_MATCHES_INT',
            p_token2_name        => 'ID',
            p_token2_value       => p_match_int_id,
            x_return_status      => l_return_status
        ) ;
        -- If unexpected errors happen abort

        IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
    ELSIF(l_idOk = 'N') THEN
        l_result := L_FND_FALSE;
        -- Add a line into inl_ship_errors
        Handle_InterfError(
            p_parent_table_name  => 'INL_MATCHES_INT',
            p_parent_table_id    => p_match_int_id,
            p_column_name        => 'TO_PARENT_TABLE_NAME',
            p_column_value       => p_to_parent_table_name,
            p_error_message_name => 'INL_ERR_OI_CHK_TO_PAR_TAB_ID',
            p_token1_name        => 'NAME',
            p_token1_value       => 'INL_MATCHES_INT',
            p_token2_name        => 'ID',
            p_token2_value       => p_match_int_id,
            x_return_status      => l_return_status
        ) ;
        -- If unexpected errors happen abort
        IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
    ELSE
        IF(l_SHidOk  = 'N') THEN
            l_result := L_FND_FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name  => 'INL_MATCHES_INT',
                p_parent_table_id    => p_match_int_id,
                p_column_name        => 'SHIP_HEADER_ID',
                p_column_value       => p_ship_header_id,
                p_error_message_name => 'INL_ERR_OI_CHK_SHIP_HEADER_ID',
                p_token1_name        => 'NAME',
                p_token1_value       => 'INL_MATCHES_INT',
                p_token2_name        => 'ID',
                p_token2_value       => p_match_int_id,
                x_return_status      => l_return_status) ;
            -- If unexpected errors happen abort
            IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
        IF(l_matchTpCdOk = 'N') THEN
            l_result     := L_FND_FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name  => 'INL_MATCHES_INT',
                p_parent_table_id    => p_match_int_id,
                p_column_name        => 'MATCH_TYPE_CODE',
                p_column_value       => p_match_type_code,
                p_error_message_name => 'INL_ERR_OI_CHK_MATCH_TP_CD',
                p_token1_name        => 'NAME',
                p_token1_value       => 'INL_MATCHES_INT',
                p_token2_name        => 'ID',
                p_token2_value       => p_match_int_id,
                x_return_status      => l_return_status
            ) ;
            -- If unexpected errors happen abort
            IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
        IF(l_INT_importedOk = 'N') THEN
            l_result        := L_FND_FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name  => 'INL_MATCHES_INT',
                p_parent_table_id    => p_match_int_id,
                p_column_name        => 'MATCH_TYPE_CODE',
                p_column_value       => p_match_type_code,
                p_error_message_name => 'INL_ERR_OI_CHK_TO_PAR_TAB_ID2',
                p_token1_name        => 'NAME',
                p_token1_value       => p_to_parent_table_name,
                p_token2_name        => 'ID',
                p_token2_value       => p_to_parent_table_id,
                p_token3_name        => 'MATCH_INT_ID',
                p_token3_value       => p_match_int_id,
                x_return_status      => l_return_status
            ) ;
            -- If unexpected errors happen abort
            IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
    END IF;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    );
    RETURN FND_API.to_boolean(l_result) ;
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name
            );
        END IF;
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
END Validate_MatchToParTab;
-- Funct name : Validate_MatchTrxType
-- Type       : Private
-- Function   : Validate Match Transaction Type
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_transaction_type       IN VARCHAR2
--              p_match_int_id           IN NUMBER
--              p_to_parent_table_name   IN VARCHAR2
--              p_to_parent_table_id     IN NUMBER
--              p_match_id               IN NUMBER
--              p_replace_estim_qty_flag IN VARCHAR2
--
-- OUT        : x_return_status          OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Validate_MatchTrxType(
    p_transaction_type       IN VARCHAR2,
    p_match_int_id           IN NUMBER,
    p_to_parent_table_name   IN VARCHAR2,
    p_to_parent_table_id     IN NUMBER,
    p_match_id               IN NUMBER,
    p_replace_estim_qty_flag IN VARCHAR2,
    x_return_status          OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
    l_program_name                  CONSTANT VARCHAR2(30) := 'Validate_MatchTrxType';
    l_debug_info                 VARCHAR2(400) ;
    l_return_status              VARCHAR2(1) ;
    l_result                     VARCHAR2(1) := L_FND_TRUE;
    l_adj_already_generated_flag VARCHAR2(1) ;
    l_replace_estim_qty_flag     VARCHAR2(1) ;
    l_other_REQF_Y_match_id      NUMBER;
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    ) ;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_transaction_type',
        p_var_value      => p_transaction_type
    ) ;

    IF p_transaction_type = 'CREATE' THEN
        IF p_match_id IS NOT NULL THEN
            l_result := L_FND_FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name  => 'INL_MATCHES_INT',
                p_parent_table_id    => p_match_int_id,
                p_column_name        => 'MATCH_ID',
                p_column_value       => p_match_id,
                p_error_message_name => 'INL_ERR_OI_CHK_MAT_ID_NNULL',
                p_token1_name        => 'OPER',
                p_token1_value       => p_transaction_type,
                p_token2_name        => 'COL',
                p_token2_value       => 'MATCH_ID',
                p_token3_name        => 'MATCH_INT_ID',
                p_token3_value       => p_match_int_id,
                x_return_status      => l_return_status) ;
            -- If unexpected errors happen abort
            IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
    ELSIF p_transaction_type IN('UPDATE', 'DELETE') THEN
        IF p_match_id IS NULL THEN
            l_result := L_FND_FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name  => 'INL_MATCHES_INT',
                p_parent_table_id    => p_match_int_id,
                p_column_name        => 'MATCH_ID',
                p_column_value       => p_match_id,
                p_error_message_name => 'INL_ERR_OI_CHK_TRX_TP_ID_NULL',
                p_token1_name        => 'COLUMN',
                p_token1_value       => 'MATCH_ID',
                p_token2_name        => 'ID_NAME',
                p_token2_value       => 'MATCH_INT_ID',
                p_token3_name        => 'ID_VAL',
                p_token3_value       => p_match_int_id,
                x_return_status      => l_return_status
            ) ;
            -- If unexpected errors happen abort
            IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        ELSE
            SELECT adj_already_generated_flag,
            replace_estim_qty_flag
            INTO l_adj_already_generated_flag,
            l_replace_estim_qty_flag
            FROM inl_matches m
            WHERE m.match_id = p_match_id;

            INL_LOGGING_PVT.Log_Variable(
                p_module_name    => g_module_name,
                p_procedure_name => l_program_name,
                p_var_name       => 'l_adj_already_generated_flag',
                p_var_value      => l_adj_already_generated_flag
            ) ;

            IF l_adj_already_generated_flag = 'Y' THEN
                l_debug_info := 'Matches that has adjustments already generated, cannot be changed.';
                INL_LOGGING_PVT.Log_Statement(
                    p_module_name      => g_module_name,
                    p_procedure_name   => l_program_name,
                    p_debug_info       => l_debug_info
                );
                l_result := L_FND_FALSE;
                -- Add a line into inl_ship_errors
                Handle_InterfError(
                    p_parent_table_name  => 'INL_MATCHES_INT',
                    p_parent_table_id    => p_match_int_id,
                    p_column_name        => 'TRANSACTION_TYPE',
                    p_column_value       => p_transaction_type,
                    p_error_message_name => 'INL_ERR_OI_CHK_PROC_MAT_INVL',
                    p_token1_name        => 'MATCH_INT_ID',
                    p_token1_value       => p_match_int_id,
                    x_return_status      => l_return_status
                ) ;
                -- If unexpected errors happen abort
                IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
                    RAISE L_FND_EXC_UNEXPECTED_ERROR;
                END IF;
            END IF;
            IF p_replace_estim_qty_flag <> l_replace_estim_qty_flag THEN
                l_debug_info := 'Matches that has adjustments already generated, cannot be changed.';
                INL_LOGGING_PVT.Log_Statement(
                    p_module_name      => g_module_name,
                    p_procedure_name   => l_program_name,
                    p_debug_info       => l_debug_info
                );
                l_result := L_FND_FALSE;
                -- Add a line into inl_ship_errors
                Handle_InterfError(
                    p_parent_table_name  => 'INL_MATCHES_INT',
                    p_parent_table_id    => p_match_int_id,
                    p_column_name        => 'REPLACE_ESTIM_QTY_FLAG',
                    p_column_value       => p_replace_estim_qty_flag,
                    p_error_message_name => 'INL_ERR_OI_CHK_TRX_TP_INVL',
                    p_token1_name        => 'MATCH_INT_ID',
                    p_token1_value       => p_match_int_id,
                    x_return_status      => l_return_status
                ) ;
                -- If unexpected errors happen abort
                IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
                    RAISE L_FND_EXC_UNEXPECTED_ERROR;
                END IF;
            END IF;
            INL_LOGGING_PVT.Log_Variable(
                p_module_name    => g_module_name,
                p_procedure_name => l_program_name,
                p_var_name       => 'l_replace_estim_qty_flag',
                p_var_value      => l_replace_estim_qty_flag
            ) ;
            IF l_replace_estim_qty_flag                 = 'Y' THEN
                -- Check if there is any new record as
                -- replace_estim_qty_flag = 'Y' and adj_already_generated_flag = 'N'
                BEGIN
                    SELECT m1.match_id
                    INTO l_other_REQF_Y_match_id
                    FROM inl_matches m1
                    WHERE m1.to_parent_table_name       = p_to_parent_table_name
                    AND m1.to_parent_table_id         = p_to_parent_table_id
                    AND m1.match_type_code            = 'ITEM'
                    AND m1.replace_estim_qty_flag     = 'Y'
                    AND m1.adj_already_generated_flag = 'N'
                    --For validation purpose, it will consider only the latest and not processed record
                    AND m1.match_id IN (SELECT MAX(m2.match_id)
                                        FROM inl_matches m2
                                        WHERE m2.to_parent_table_name       = m1.to_parent_table_name
                                         AND m2.to_parent_table_id         = m1.to_parent_table_id
                                         AND m2.match_type_code            = 'ITEM'
                                         AND m2.replace_estim_qty_flag     = 'Y'
                                         AND m2.adj_already_generated_flag = 'N'
                                        )
                    ;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        l_other_REQF_Y_match_id := 0;
                END;
                INL_LOGGING_PVT.Log_Variable(
                    p_module_name    => g_module_name,
                    p_procedure_name => l_program_name,
                    p_var_name       => 'p_match_id',
                    p_var_value      => p_match_id
                ) ;

                INL_LOGGING_PVT.Log_Variable(
                    p_module_name    => g_module_name,
                    p_procedure_name => l_program_name,
                    p_var_name       => 'l_other_REQF_Y_match_id',
                    p_var_value      => l_other_REQF_Y_match_id
                ) ;

                IF p_match_id < l_other_REQF_Y_match_id THEN
                    l_result := L_FND_FALSE;
                    -- Add a line into inl_ship_errors
                    Handle_InterfError(
                        p_parent_table_name  => 'INL_MATCHES_INT',
                        p_parent_table_id    => p_match_int_id,
                        p_column_name        => 'TRANSACTION_TYPE',
                        p_column_value       => p_transaction_type,
                        p_error_message_name => 'INL_ERR_OI_CHK_MAT_NO_EFFECT',
                        p_token1_name        => 'MATCH_INT_ID',
                        p_token1_value       => p_match_int_id,
                        x_return_status      => l_return_status
                    ) ;
                    -- If unexpected errors happen abort
                    IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
                        RAISE L_FND_EXC_UNEXPECTED_ERROR;
                    END IF;
                END IF;
            END IF;
        END IF;
    ELSE
        l_result := L_FND_FALSE;
        -- Add a line into inl_ship_errors
        Handle_InterfError(
            p_parent_table_name  => 'INL_MATCHES_INT',
            p_parent_table_id    => p_match_int_id,
            p_column_name        => 'TRANSACTION_TYPE',
            p_column_value       => p_transaction_type,
            p_error_message_name => 'INL_ERR_OI_CHK_TRX_TP_INVL',
            p_token1_name        => 'TTYPE',
            p_token1_value       => p_transaction_type,
            p_token2_name        => 'ID_NAME',
            p_token2_value       => 'MATCH_INT_ID',
            p_token3_name        => 'ID_VAL',
            p_token3_value       => p_match_int_id,
            x_return_status      => l_return_status
        ) ;
        -- If unexpected errors happen abort
        IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    );
    RETURN FND_API.to_boolean(l_result) ;
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name
            );
        END IF;
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
END Validate_MatchTrxType;
-- Funct Name : Validate_MatchParty
-- Type       : Private
-- Function   : Validate Match Party and Party Site
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_match_int_id           IN NUMBER
--              p_match_type_code        IN VARCHAR2
--              p_parent_match_type_code IN VARCHAR2
--              p_party_id               IN NUMBER
--              p_party_site_id          IN NUMBER
--
-- IN OUT     : x_return_status          OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Validate_MatchParty(
    p_match_int_id           IN NUMBER,
    p_match_type_code        IN VARCHAR2,
    p_parent_match_type_code IN VARCHAR2,
    p_party_id               IN NUMBER,
    p_party_site_id          IN NUMBER,
    x_return_status          OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
    l_program_name     CONSTANT VARCHAR2(30) := 'Validate_MatchParty';
    l_debug_info    VARCHAR2(400) ;
    l_return_status VARCHAR2(1) ;
    l_result        VARCHAR2(1) := L_FND_TRUE;
    l_field         VARCHAR2(30) ;
    l_field_id      NUMBER;
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    ) ;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;
    l_debug_info := 'Check if the Party information should be included based on a given Match Type Code ';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    );
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_parent_match_type_code',
        p_var_value      => p_parent_match_type_code
    ) ;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_match_type_code',
        p_var_value      => p_match_type_code
    ) ;

    IF NVL(p_parent_match_type_code, p_match_type_code) = 'CHARGE' THEN
        l_field := 'x';
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'p_party_id',
            p_var_value      => p_party_id
        ) ;

        l_debug_info     := 'party_id: ';
        IF p_party_id IS NOT NULL THEN
            BEGIN
                l_debug_info := 'Chech Party_Id in HZ_PARTIES table';
                INL_LOGGING_PVT.Log_Statement(
                    p_module_name      => g_module_name,
                    p_procedure_name   => l_program_name,
                    p_debug_info       => l_debug_info
                );
                SELECT 'x'
                INTO l_field
                FROM hz_parties
                WHERE p_party_id = party_id;

                l_debug_info := l_debug_info||'(OK) ';
            EXCEPTION
                WHEN OTHERS THEN
                    l_field      := 'PARTY_ID';
                    l_field_id   := p_party_id;
                    l_debug_info := l_debug_info||'(NOT OK) ';
            END;
        ELSE
            l_field    := 'PARTY_ID';
            l_field_id := NULL;
        END IF;
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info
        );
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'p_party_site_id',
            p_var_value      => p_party_site_id
        ) ;
        l_debug_info := 'p_party_site_id: ';
        IF p_party_site_id IS NOT NULL THEN
            BEGIN
                 SELECT 'x'
                 INTO l_field
                 FROM hz_party_sites
                 WHERE party_site_id = p_party_site_id;

                l_debug_info := l_debug_info||'(OK) ';
            EXCEPTION
            WHEN OTHERS THEN
                l_field      := 'PARTY_SITE_ID';
                l_field_id   := p_party_site_id;
                l_debug_info := l_debug_info||'(NOT OK) ';
            END;
        ELSE
            IF l_field     <> 'x' THEN
                l_field    := 'PARTY_SITE_ID';
                l_field_id := NULL;
            END IF;
        END IF;
        INL_LOGGING_PVT.Log_Statement(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_debug_info     => l_debug_info
        );
        IF l_field                                      <> 'x' THEN
            l_debug_info := 'ERROR l_field: '||l_field;
            INL_LOGGING_PVT.Log_Statement(
                p_module_name    => g_module_name,
                p_procedure_name => l_program_name,
                p_debug_info     => l_debug_info
            );
            l_result     := L_FND_FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name  => 'INL_MATCHES_INT',
                p_parent_table_id    => p_match_int_id,
                p_column_name        => l_field,
                p_column_value       => l_field_id,
                p_error_message_name => 'INL_ERR_OI_CHK_PARTY_INVAL',
                p_token1_name        => 'MATCH_INT_ID',
                p_token1_value       => p_match_int_id,
                x_return_status      => l_return_status
            ) ;
            -- If unexpected errors happen abort
            IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
    ELSE
        l_field := 'x';
        IF p_party_id  IS NOT NULL THEN
            l_field    := 'PARTY_ID';
            l_field_id := p_party_id;
        END IF;
        IF p_party_site_id IS NOT NULL THEN
            l_field    := 'PARTY_SITE_ID';
            l_field_id := p_party_site_id;
        END IF;
        IF l_field   <> 'x' THEN
            l_result := L_FND_FALSE;
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name  => 'INL_MATCHES_INT',
                p_parent_table_id    => p_match_int_id,
                p_column_name        => l_field,
                p_column_value       => l_field_id,
                p_error_message_name => 'INL_ERR_OI_CHK_PARTY_NNULL',
                p_token1_name        => 'MATCH_INT_ID',
                p_token1_value       => p_match_int_id,
                x_return_status      => l_return_status
            ) ;
            -- If unexpected errors happen abort
            IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
    END IF;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    );
    RETURN FND_API.to_boolean(l_result) ;
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name
            );
        END IF;
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
END Validate_MatchParty;

-- Utility name   : Validate_MatchInt
-- Type       : Private
-- Function   : Validate a Match before import it from interface to INL Tables
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_match_int_rec  IN  match_int_type%TYPE
--
-- OUT        : x_return_status  OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Validate_MatchInt(
    p_match_int_rec IN match_int_type,
    x_return_status OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
    l_program_name                   CONSTANT VARCHAR2(30) := 'Validate_MatchInt';
    l_return_status               VARCHAR2(1) ;
    l_debug_info                  VARCHAR2(400) ;
    x_result                      VARCHAR2(1) := L_FND_TRUE;
    l_result                      BOOLEAN;
    l_parent_match_type_code      VARCHAR2(100) ;
    l_parent_matched_curr_code    VARCHAR2(15) ;
    l_parent_to_parent_table_name VARCHAR2(100) ;
    l_parent_to_parent_table_ID   NUMBER;
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    ) ;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;
    l_debug_info := 'Validate Transaction Type. Call Validate_MatchTrxType';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    );

    l_result     := Validate_MatchTrxType(
                        p_transaction_type          => p_match_int_rec.transaction_type,
                        p_match_int_id              => p_match_int_rec.match_int_id,
                        p_to_parent_table_name => p_match_int_rec.to_parent_table_name,
                        p_to_parent_table_id => p_match_int_rec.to_parent_table_id,
                        p_match_id => p_match_int_rec.match_id,
                        p_replace_estim_qty_flag => p_match_int_rec.replace_estim_qty_flag,
                        x_return_status => l_return_status
    ) ;
    IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
    l_debug_info     := l_debug_info||': ';
    IF l_result       = FALSE THEN
        x_result     := L_FND_FALSE;
        l_debug_info := l_debug_info||'FALSE';
    ELSE
        l_debug_info := l_debug_info||'OK';
    END IF;
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    );

    l_debug_info := 'Get Match Type Code from Parent Match when processing corrections.';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    );

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_match_int_rec.parent_match_id',
        p_var_value      => p_match_int_rec.parent_match_id
    ) ;
    IF p_match_int_rec.match_type_code = 'CORRECTION' THEN
         SELECT match_type_code ,
            matched_curr_code   ,
            to_parent_table_name,
            to_parent_table_id
           INTO l_parent_match_type_code ,
            l_parent_matched_curr_code   ,
            l_parent_to_parent_table_name,
            l_parent_to_parent_table_ID
           FROM inl_matches
          WHERE match_id = p_match_int_rec.parent_match_id;
    ELSE
        l_parent_match_type_code      := NULL;
        l_parent_matched_curr_code    := NULL;
        l_parent_to_parent_table_name := NULL;
        l_parent_to_parent_table_ID   := NULL;
    END IF;
    l_debug_info := 'Validate TO_PARENT_TABLE information. Call Validate_MatchToParTab.';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    );
    l_result     := Validate_MatchToParTab(
                        p_transaction_type => p_match_int_rec.transaction_type,
                        p_match_int_id => p_match_int_rec.match_int_id,
                        p_match_id => p_match_int_rec.match_id,
                        p_parent_match_id => p_match_int_rec.parent_match_id,
                        p_ship_header_id => p_match_int_rec.ship_header_id,
                        p_to_parent_table_name => p_match_int_rec.to_parent_table_name,
                        p_to_parent_table_id => p_match_int_rec.to_parent_table_id,
                        p_match_type_code => p_match_int_rec.match_type_code,
                        x_return_status => l_return_status
    ) ;
    IF l_return_status                          <> L_FND_RET_STS_SUCCESS THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
    l_debug_info := l_debug_info||': ';
    IF l_result = FALSE THEN
        x_result     := L_FND_FALSE;
        l_debug_info := l_debug_info||'FALSE';
    ELSE
        l_debug_info := l_debug_info||'OK';
    END IF;
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    );
    l_debug_info := 'Validate Match IDs. Call Validate_MatchMatIDS';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    );
    l_result := Validate_MatchMatIDS(
                    p_transaction_type         => p_match_int_rec.transaction_type,
                    p_match_int_id             => p_match_int_rec.match_int_id,
                    p_match_id                 => p_match_int_rec.match_id,
                    p_parent_match_id          => p_match_int_rec.parent_match_id,
                    p_match_type_code          => p_match_int_rec.match_type_code,
                    p_existing_match_info_flag => p_match_int_rec.existing_match_info_flag,
                    x_return_status            => l_return_status
                    )
    ;
    IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
    l_debug_info := l_debug_info||': ';
    IF l_result = FALSE THEN
        x_result     := L_FND_FALSE;
        l_debug_info := l_debug_info||'FALSE';
    ELSE
        l_debug_info := l_debug_info||'OK';
    END IF;
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    );
    IF p_match_int_rec.matched_qty IS NOT NULL
    THEN
        l_debug_info := 'Validate Matched UOM Code. Call Validate_MatchUOM';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info
        );
        l_result := Validate_MatchUOM(
                        p_match_int_id           => p_match_int_rec.match_int_id,
                        p_matched_uom_code       => p_match_int_rec.matched_uom_code,
                        p_match_type_code        => p_match_int_rec.match_type_code,
                        p_parent_match_type_code => l_parent_match_type_code,
                        x_return_status          => l_return_status
                    )
        ;
        IF l_return_status                          <> L_FND_RET_STS_SUCCESS THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
        l_debug_info := l_debug_info||': ';
        IF l_result = FALSE THEN
            x_result     := L_FND_FALSE;
            l_debug_info := l_debug_info||'FALSE';
        ELSE
            l_debug_info := l_debug_info||'OK';
        END IF;
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info
        );
    END IF;
    l_debug_info := 'Validate Matched Amount. Call Validate_MatchAmt';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    );
    l_result := Validate_MatchAmt(
                    p_match_int_id             => p_match_int_rec.match_int_id,
                    p_parent_matched_curr_code => l_parent_matched_curr_code,
                    p_match_type_code          => p_match_int_rec.match_type_code,
                    p_parent_match_type_code   => l_parent_match_type_code,
                    p_matched_amt              => p_match_int_rec.matched_amt,
                    p_matched_curr_code        => p_match_int_rec.matched_curr_code,
                    p_matched_curr_conv_type   => p_match_int_rec.matched_curr_conversion_type,
                    p_matched_curr_conv_date   => p_match_int_rec.matched_curr_conversion_date,
                    p_matched_curr_conv_rate   => p_match_int_rec.matched_curr_conversion_rate,
                    p_replace_estim_qty_flag   => p_match_int_rec.replace_estim_qty_flag,
                    x_return_status            => l_return_status) ;
    IF l_return_status                          <> L_FND_RET_STS_SUCCESS THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
    l_debug_info     := l_debug_info||': ';
    IF l_result       = FALSE THEN
        x_result     := L_FND_FALSE;
        l_debug_info := l_debug_info||'FALSE';
    ELSE
        l_debug_info := l_debug_info||'OK';
    END IF;
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    );
    l_debug_info := 'Validate Matched Quantity. Call Validate_MatchQty';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    );
    IF((p_match_int_rec.to_parent_table_name = 'INL_SHIP_LINES'
         AND p_match_int_rec.match_type_code = 'ITEM')
      OR (l_parent_to_parent_table_name = 'INL_SHIP_LINES'
          AND l_parent_match_type_code = 'ITEM'
         )
      ) AND p_match_int_rec.matched_qty IS NOT NULL
    THEN
        l_result := Validate_MatchQty(
                        p_match_int_id           => p_match_int_rec.match_int_id,
                        p_corrected_match_id     => p_match_int_rec.parent_match_id,
                        p_updated_match_id       => p_match_int_rec.match_id,
                        p_ship_line_id           => NVL(l_parent_to_parent_table_id,
                                                        p_match_int_rec.to_parent_table_id),
                        p_matched_qty            => p_match_int_rec.matched_qty,
                        p_matched_uom_code       => p_match_int_rec.matched_uom_code,
                        p_replace_estim_qty_flag => p_match_int_rec.replace_estim_qty_flag,
                        p_match_type_code        => p_match_int_rec.match_type_code,
                        x_return_status          => l_return_status) ;
        IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;
    l_debug_info     := l_debug_info||': ';
    IF l_result       = FALSE THEN
        x_result     := L_FND_FALSE;
        l_debug_info := l_debug_info||'FALSE';
    ELSE
        l_debug_info := l_debug_info||'OK';
    END IF;
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    );
    l_debug_info := 'Validate Match Tax. Call Validate_MatchTax';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    );
    l_result := Validate_MatchTax(
                    p_match_int_id           => p_match_int_rec.match_int_id,
                    p_tax_code               => p_match_int_rec.tax_code,
                    p_nrec_tax_amt           => p_match_int_rec.nrec_tax_amt,
                    p_tax_amt_included_flag  => p_match_int_rec.tax_amt_included_flag,
                    p_matched_amt            => p_match_int_rec.matched_amt,
                    p_match_type_code        => p_match_int_rec.match_type_code,
                    p_parent_match_type_code => l_parent_match_type_code, x_return_status => l_return_status) ;
    IF l_return_status                          <> L_FND_RET_STS_SUCCESS THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
    l_debug_info     := l_debug_info||': ';
    IF l_result       = FALSE THEN
        x_result     := L_FND_FALSE;
        l_debug_info := l_debug_info||'FALSE';
    ELSE
        l_debug_info := l_debug_info||'OK';
    END IF;
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    );
    l_debug_info := 'Validate Matching Flags. Call Validate_MatchFlags';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    );
    l_result := Validate_MatchFlags(
                    p_match_int_id             => p_match_int_rec.match_int_id,
                    p_match_type_code          => p_match_int_rec.match_type_code,
                    p_parent_match_type_code   => l_parent_match_type_code,
                    p_replace_estim_qty_flag   => p_match_int_rec.replace_estim_qty_flag,
                    p_existing_match_info_flag => p_match_int_rec.existing_match_info_flag,
                    x_return_status            => l_return_status) ;
    IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
    l_debug_info     := l_debug_info||': ';
    IF l_result       = FALSE THEN
        x_result     := L_FND_FALSE;
        l_debug_info := l_debug_info||'FALSE';
    ELSE
        l_debug_info := l_debug_info||'OK';
    END IF;
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    );
    l_debug_info := 'Validate Charge Line Type Id. Call Validate_MatchChLnTpID';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    );
    l_result := Validate_MatchChLnTpID(
                    p_match_int_id           => p_match_int_rec.match_int_id,
                    p_match_type_code        => p_match_int_rec.match_type_code,
                    p_parent_match_type_code => l_parent_match_type_code,
                    p_charge_line_type_id    => p_match_int_rec.charge_line_type_id,
                    p_match_amounts_flag     => p_match_int_rec.match_amounts_flag,
                    x_return_status          => l_return_status)
    ;
    IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
    l_debug_info     := l_debug_info||': ';
    IF l_result       = FALSE THEN
        x_result     := L_FND_FALSE;
        l_debug_info := l_debug_info||'FALSE';
    ELSE
        l_debug_info := l_debug_info||'OK';
    END IF;
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    );
    l_debug_info := 'Validate Party and Party Site. Call Validate_MatchParty';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    );
    l_result := Validate_MatchParty(
                    p_match_int_id           => p_match_int_rec.match_int_id,
                    p_match_type_code        => p_match_int_rec.match_type_code,
                    p_parent_match_type_code => l_parent_match_type_code,
                    p_party_id               => p_match_int_rec.party_id,
                    p_party_site_id          => p_match_int_rec.party_site_id,
                    x_return_status          => l_return_status) ;
    IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
    l_debug_info     := l_debug_info||': ';
    IF l_result       = FALSE THEN
        x_result     := L_FND_FALSE;
        l_debug_info := l_debug_info||'FALSE';
    ELSE
        l_debug_info := l_debug_info||'OK';
    END IF;
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    );
    -- SCM-051 Begin
    l_debug_info := 'Validate any ELC Update on going. Call Validate_MatchElcOnGoing';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    );
    l_result := Validate_MatchElcOnGoing(
                    p_match_int_id          => p_match_int_rec.match_int_id,
                    p_to_parent_table_name  => p_match_int_rec.to_parent_table_name,
                    p_to_parent_table_id    => p_match_int_rec.to_parent_table_id,
                    p_match_type_code       => p_match_int_rec.match_type_code,
                    p_charge_line_type_id   => p_match_int_rec.charge_line_type_id,
                    x_return_status         => l_return_status
                ) ;
    IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
    l_debug_info     := l_debug_info||': ';
    IF l_result       = FALSE THEN
        x_result     := L_FND_FALSE;
        l_debug_info := l_debug_info||'FALSE';
    ELSE
        l_debug_info := l_debug_info||'OK';
    END IF;
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    );
    -- SCM-051 End
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_match_int_rec.transaction_type',
        p_var_value      => p_match_int_rec.transaction_type
    ) ;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_match_int_rec.match_int_id',
        p_var_value      => p_match_int_rec.match_int_id
    ) ;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_match_int_rec.match_id',
        p_var_value      => p_match_int_rec.match_id
    ) ;

    l_debug_info := 'Validate Transaction Type. Call Validate_MatchTrxType';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    );

/* this code appear twice in this procedure!     --Bug#10381495
    l_result := Validate_MatchTrxType(
                    p_transaction_type       => p_match_int_rec.transaction_type,
                    p_match_int_id           => p_match_int_rec.match_int_id,
                    p_to_parent_table_name   => p_match_int_rec.to_parent_table_name,
                    p_to_parent_table_id     => p_match_int_rec.to_parent_table_id,
                    p_match_id               => p_match_int_rec.match_id,
                    p_replace_estim_qty_flag => p_match_int_rec.replace_estim_qty_flag,
                    x_return_status          => l_return_status) ;
    IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
    l_debug_info := 'Consistency of Transaction Type: ';
    IF l_result THEN
        l_debug_info := l_debug_info||'OK';
    ELSE
        x_result     := L_FND_FALSE;
        l_debug_info := l_debug_info||'FALSE';
    END IF;
    -- If unexpected errors happen abort
    IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
*/
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    );
    RETURN FND_API.to_boolean(x_result) ;
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name
            );
        END IF;
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
END Validate_MatchInt;

-- Utility name : Select_MatchesToProc --Bug#11794442
-- Type         : Private
-- Function     : Select the interface records to process
-- Pre-reqs     :
-- Version    : Current version 1.0
--
-- IN         : p_group_id IN NUMBER
--
-- OUT        : x_return_status  OUT NOCOPY VARCHAR2
--
-- Notes      :

FUNCTION Select_MatchesToProc(
    p_group_id      IN NUMBER,
    p_commit        IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2
) RETURN NUMBER IS
    l_program_name     CONSTANT VARCHAR2(30) := 'Select_MatchesToProc';

    l_lines         CONSTANT NUMBER:=50; --NUMBER of lines to process in each iteration

    l_return_status VARCHAR2(1);
    l_debug_info    VARCHAR2(200);
    l_return_value  NUMBER:=0;
    l_count_records NUMBER;
    l_lock_name     VARCHAR2(50) := 'select_MatchesToProc';
    l_lock_handle   VARCHAR2(100);
    l_lock_status   NUMBER;
    l_count_had_aid NUMBER; --Bug#14768732 --considering all match_int, how many correction records
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    ) ;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_group_id',
        p_var_value      => p_group_id);

    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_debug_info => 'Acquiring lock (Allocate_Unique) on: ' || l_lock_name
    );

    DBMS_LOCK.Allocate_Unique(
        lockname   => l_lock_name,
        lockhandle => l_lock_handle
    );

    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_debug_info => 'Acquiring lock (Request)'
    );

    l_lock_status := DBMS_LOCK.Request(
                        lockhandle => l_lock_handle,
                        lockmode => DBMS_LOCK.x_mode
                     );

    IF l_lock_status <> 0 THEN
        INL_LOGGING_PVT.Log_Statement (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_debug_info     => 'Failled to get the lock '||l_lock_name||' status: '||l_lock_status);

        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --Bug#14768732 BEGIN
    -- IF m.to_parent_table_name not in ('RCV_TRANSACTIONS', 'AP_INVOICE_DISTRIBUTIONS') => ERROR
    UPDATE inl_matches_int m
    SET m.processing_status_code = 'ERROR'
    WHERE m.to_parent_table_name NOT IN ('RCV_TRANSACTIONS', 'AP_INVOICE_DISTRIBUTIONS');

    -- verify if exists corrections
    SELECT COUNT(*)
    INTO l_count_had_aid
    FROM inl_matches_int m
    WHERE
        m.processing_status_code = 'PENDING'
    AND m.to_parent_table_name = 'AP_INVOICE_DISTRIBUTIONS'
    AND (p_group_id IS NULL
         OR m.group_id = p_group_id)
    AND (nvl(m.request_id,1) > 0
         OR m.request_id = -1);
    --Bug#14768732 END

    --Step 1 mark a group of "l_lines" records (without HR sec restriction) to process
    UPDATE inl_matches_int m
        SET m.request_id = l_fnd_conc_request_id_int
        WHERE (nvl(m.request_id,1) > 0
                OR m.request_id = -1)
        AND m.processing_status_code = 'PENDING'
        AND (p_group_id IS NULL
             OR m.group_id = p_group_id)
        AND (ROWNUM < l_lines
             OR p_group_id IS NOT NULL)
        --Bug#16198838/14707257 Mark only records complying with hr:sec profile
        --Begin
        AND EXISTS
        (
            SELECT 1
            FROM
                rcv_transactions rt,
                org_organization_definitions ood
            WHERE
                rt.transaction_id = m.to_parent_table_id
            AND   m.to_parent_table_name = 'RCV_TRANSACTIONS' --Bug#14768732
            AND ood.organization_id = rt.organization_id
        )
        --Bug#16198838/14707257 End
    ; -- same group id should be process together

    l_return_value := NVL(SQL%ROWCOUNT,0);

    --Bug#14768732 BEGIN
    IF NVL(l_count_had_aid,0) > 0
    AND l_return_value < l_lines
    THEN
    --Step 1b mark a group of "l_lines" CORRECTION records (without HR sec restriction) to process
        UPDATE inl_matches_int m
            SET m.request_id = l_fnd_conc_request_id_int
            WHERE (nvl(m.request_id,1) > 0
                    OR m.request_id = -1)
            AND m.processing_status_code = 'PENDING'
            AND (p_group_id IS NULL
                 OR m.group_id = p_group_id)
            AND (ROWNUM < l_lines
                 OR p_group_id IS NOT NULL)
            --Bug#14707257 Mark only records complying with hr:sec profile
            --Begin
            AND EXISTS
            (
                SELECT 1
                FROM
                    rcv_transactions rt,
                    org_organization_definitions ood,
                    ap_invoice_distributions_all aid
                WHERE
                    m.to_parent_table_name = 'AP_INVOICE_DISTRIBUTIONS'
                AND m.to_parent_table_id   = aid.invoice_distribution_id
                AND rt.transaction_id      = aid.rcv_transaction_id
                AND ood.organization_id    = rt.organization_id
            )
            --Bug#14707257 End
        ;
        l_return_value := l_return_value + NVL(SQL%ROWCOUNT,0);

    END IF;
    --Bug#14768732 END

    IF p_group_id IS NULL THEN

        --same origin should be processed together

        UPDATE inl_matches_int mi
            SET mi.request_id = l_fnd_conc_request_id_int
            WHERE (nvl(mi.request_id,1) > 0
                    OR mi.request_id = -1)
            AND mi.processing_status_code = 'PENDING'
            AND EXISTS (
                SELECT 1
                FROM inl_matches_int mi2
                WHERE mi2.processing_status_code = 'PENDING'
                AND   mi2.request_id             = l_fnd_conc_request_id_int
                AND   mi2.from_parent_table_name = mi.from_parent_table_name
                AND   mi2.from_parent_table_id   = mi.from_parent_table_id
                AND   mi2.match_int_id           <> mi.match_int_id
            );
        l_return_value := l_return_value + NVL(SQL%ROWCOUNT,0);

        --Step 3a include in the selected records those that refers to the same line id
        --item matches to the same ship_line should be processed together

        UPDATE inl_matches_int mi
            SET mi.request_id = l_fnd_conc_request_id_int
            WHERE (nvl(mi.request_id,1) > 0
                    OR mi.request_id = -1)
            AND mi.processing_status_code = 'PENDING'
            AND mi.to_parent_table_name = 'RCV_TRANSACTIONS'
            AND EXISTS (
                SELECT 1
                FROM inl_matches_int mi2
                WHERE mi2.processing_status_code = 'PENDING'
                AND   mi2.request_id             = l_fnd_conc_request_id_int
                AND   mi2.match_int_id           <> mi.match_int_id
                AND   mi2.to_parent_table_name = 'RCV_TRANSACTIONS'
                AND   mi2.to_parent_table_id   = mi.to_parent_table_id
            );
        l_return_value := l_return_value + NVL(SQL%ROWCOUNT,0);

    --Bug#14768732 BEGIN
        IF l_count_had_aid > 0 THEN
            --Step 3b include in the selected records corrections that refers to a included line id
            -- due to the risk of process the correction before the main line

            UPDATE inl_matches_int mi
                SET mi.request_id = l_fnd_conc_request_id_int
                WHERE (nvl(mi.request_id,1) > 0
                        OR mi.request_id = -1)
                AND mi.processing_status_code = 'PENDING'
                AND mi.to_parent_table_name = 'AP_INVOICE_DISTRIBUTIONS'
                AND EXISTS (
                    SELECT 1
                    FROM inl_matches_int mi2,
                         ap_invoice_distributions_all aid
                    WHERE mi2.processing_status_code = 'PENDING'
                    AND   mi2.request_id             = l_fnd_conc_request_id_int
                    AND   mi2.match_int_id           <> mi.match_int_id
                    AND   mi2.to_parent_table_name = 'RCV_TRANSACTIONS'
                    AND   mi2.to_parent_table_id   = aid.rcv_transaction_id
                    AND   mi.to_parent_table_id   =  aid.invoice_distribution_id
                );
            l_return_value := l_return_value + NVL(SQL%ROWCOUNT,0);

        END IF;
        --Bug#14768732 END

        --same group_id should be processed together

        --Step 4 include in the selected records those belong to the same group id
        UPDATE inl_matches_int mi
            SET mi.request_id = l_fnd_conc_request_id_int
            WHERE (nvl(mi.request_id,1) > 0
                    OR mi.request_id = -1)
            AND mi.processing_status_code = 'PENDING'
            AND EXISTS (
                SELECT 1
                FROM inl_matches_int mi2
                WHERE mi2.processing_status_code = 'PENDING'
                AND   mi2.request_id             = l_fnd_conc_request_id_int
                AND   mi2.group_id               = mi.group_id
                AND   mi2.match_int_id           <> mi.match_int_id
            );
        l_return_value := l_return_value + NVL(SQL%ROWCOUNT,0);

    END IF;

    --Bug#14707257/16198838 If any record aren't complying with hr:sec profile the group should be unmarked
    --Begin
    FOR l_non_hrs IN
      (
          SELECT DISTINCT
              mi.group_id
          FROM
              inl_matches_int mi
          WHERE
              mi.processing_status_code = 'PENDING'
          AND mi.request_id             = l_fnd_conc_request_id_int
          AND mi.to_parent_table_name = 'RCV_TRANSACTIONS' --Bug#14768732
          AND NOT EXISTS
          (
            SELECT 1
            FROM
                rcv_transactions rt,
                org_organization_definitions ood
            WHERE
                rt.transaction_id = mi.to_parent_table_id
            AND ood.organization_id = rt.organization_id
          )
          --Bug#14768732 BEGIN
          UNION
          SELECT DISTINCT
              mi.group_id
          FROM
              inl_matches_int mi
          WHERE
              mi.processing_status_code = 'PENDING'
          AND mi.request_id = l_fnd_conc_request_id_int
          AND mi.to_parent_table_name = 'AP_INVOICE_DISTRIBUTIONS'
          AND NOT EXISTS
          (
            SELECT 1
            FROM
                rcv_transactions rt,
                org_organization_definitions ood,
                ap_invoice_distributions_all aid
            WHERE
                mi.to_parent_table_id   = aid.invoice_distribution_id
            AND rt.transaction_id       = aid.rcv_transaction_id
            AND ood.organization_id     = rt.organization_id
          )

          --Bug#14768732 END
      )
    LOOP
        INL_LOGGING_PVT.Log_Statement (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_debug_info     => ' Group unmarked:'||l_non_hrs.group_id);
        UPDATE
            inl_matches_int mi
        SET mi.request_id = ABS(l_fnd_conc_request_id_int)
        WHERE mi.group_id = l_non_hrs.group_id
        AND   mi.processing_status_code = 'PENDING';
        l_return_value := l_return_value - NVL(SQL%ROWCOUNT,0);
    END LOOP;
    --Bug#14707257/16198838 END

    INL_LOGGING_PVT.Log_Statement (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_debug_info     => l_return_value||' selected records');

    -- Standard check of p_commit.
    IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;

    -- Release the lock
    l_lock_status := DBMS_LOCK.RELEASE(l_lock_handle);
    l_lock_handle := NULL;

    RETURN l_return_value;

EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        x_return_status := L_FND_RET_STS_ERROR;
        IF l_lock_handle IS NOT NULL THEN
            l_lock_status := DBMS_LOCK.Release(l_lock_handle);
        END IF;
        RETURN 0;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
        IF l_lock_handle IS NOT NULL THEN
            l_lock_status := DBMS_LOCK.Release(l_lock_handle);
        END IF;
        RETURN 0;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name
            );
        END IF;
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
        IF l_lock_handle IS NOT NULL THEN
            l_lock_status := DBMS_LOCK.Release(l_lock_handle);
        END IF;
        RETURN 0;
END Select_MatchesToProc;

-- Utility name : Run_MatchPreProcessor
-- Type       : Private
-- Function   : Executes the first set of validations before import.
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_group_id       IN  NUMBER
--
-- OUT        : x_return_status  OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Run_MatchPreProcessor(
    p_group_id      IN NUMBER,
    p_commit        IN VARCHAR2, --Bug#11794442
    x_return_status OUT NOCOPY VARCHAR2
) IS

    --Bug#16198838/14707257 BEGIN
    CURSOR c_unproc_match_int (pc_max_id NUMBER)
    IS
        SELECT DISTINCT group_id
        FROM inl_matches_int
        WHERE match_int_id < pc_max_id
        AND (nvl(request_id,1) > 0
                 OR request_id = -1)
        AND processing_status_code = 'PENDING'
        AND (p_group_id IS NULL
             OR group_id = p_group_id)
    ;
    TYPE unproc_match_int_tp IS
      TABLE OF c_unproc_match_int%ROWTYPE INDEX BY BINARY_INTEGER;
    l_unproc_match_int_lst unproc_match_int_tp;
    --Bug#16198838/14707257 END

    -- Cursor to get all PENDING matches from the
    -- Interface table based on a given group id
    CURSOR c_match_int
    IS
         SELECT match_int_id             ,
            group_id                    ,
            processing_status_code      ,
            transaction_type            ,
            match_type_code             ,   --Bug#14768732 comments only
            null                        ,   /*ship_header_id               */
            from_parent_table_name      ,
            from_parent_table_id        ,
            to_parent_table_name        ,
            to_parent_table_id          ,
            null                        ,   /*parent_match_id              */
            matched_qty                 ,
            matched_uom_code            ,
            matched_amt                 ,
            matched_curr_code           ,
            matched_curr_conversion_type,
            matched_curr_conversion_date,
            matched_curr_conversion_rate,
            replace_estim_qty_flag      ,
            null                        ,   /*existing_match_info_flag     */
            charge_line_type_id         ,
            party_id                    ,
            party_number                ,
            party_site_id               ,
            party_site_number           ,
            tax_code                    ,
            nrec_tax_amt                ,
            tax_amt_included_flag       ,
            match_amounts_flag          ,
            null                            /*match_id                     */
          FROM inl_matches_int m
          WHERE (p_group_id   IS NULL
                 OR m.group_id = p_group_id)
          AND m.processing_status_code = 'PENDING'
          AND m.request_id = l_fnd_conc_request_id_int  --Bug#11794442
          ORDER BY group_id,match_int_id;               --Bug#11794442
    match_int_list match_int_list_type;

    l_rec_num       NUMBER; --Bug#11794442

    l_program_name      CONSTANT VARCHAR2(100) := 'Run_MatchPreProcessor';
    l_return_status     VARCHAR2(1) ;
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000) ;
    l_debug_info        VARCHAR2(200) ;
    l_import_validation BOOLEAN;
    l_amt_sum           NUMBER;
--    l_processing_status_code VARCHAR2(30) ; --Bug#11794442
    l_varchardate       VARCHAR2(10) := TO_CHAR(SYSDATE,'DDDSSSS'); --Bug#11794442
    l_bad_group_id      NUMBER; --Bug#11794442
    l_last_group_id     NUMBER; --Bug#11794442
    l_max_match_int_id  NUMBER; --Bug#16198838/14707257
    l_max_match_int_id2  NUMBER; --Bug#16198838/14707257

BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    ) ;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;

    --Bug#16198838/14707257
    SELECT NVL(MAX(match_int_id),0)
    INTO l_max_match_int_id
    FROM inl_matches_int;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'l_max_match_int_id',
        p_var_value      => l_max_match_int_id
    ) ;
    --Bug#16198838/14707257

--Bug#11794442 Begin

    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => 'Verify if request ID is generic:'||l_fnd_conc_request_id);

    IF l_fnd_conc_request_id = -1 THEN
        l_fnd_conc_request_id_int := TO_NUMBER(l_varchardate||TO_CHAR(SYSDATE,'DDDSSSS'))*-1;
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'l_fnd_conc_request_id_int',
            p_var_value      => l_fnd_conc_request_id_int
        ) ;
    ELSE
        l_fnd_conc_request_id_int := l_fnd_conc_request_id*-1;
    END IF;

    LOOP
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => 'Getting Matches_interface records to process');

        l_rec_num:= NVL(Select_MatchesToProc(
            p_group_id      => p_group_id,
            p_commit        => p_commit,
            x_return_status => l_return_status
        ),0);
        -- If any errors happen abort API.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_rec_num||' records to process');

        IF l_rec_num > 0  THEN
--Bug#11794442 End
            OPEN c_match_int;
            FETCH c_match_int
            BULK COLLECT INTO match_int_list;
            CLOSE c_match_int;

            -- Set the number of LCM Shipments to be processed
            -- This value will be latter stamped in the concurrent log
            g_records_processed := g_records_processed + match_int_list.COUNT();

            FOR i IN 1 .. match_int_list.COUNT
            LOOP
                --Bug#11794442 begin
                BEGIN
                    IF match_int_list(i).group_id IS NULL
                        OR l_last_group_id IS NULL
                        OR match_int_list(i).group_id <> l_last_group_id
                    THEN
                        SAVEPOINT Run_MatchPreProcSVPNT;
                        l_bad_group_id  := NULL;
                        l_last_group_id :=  match_int_list(i).group_id;
                    END IF;
--                    l_processing_status_code := 'RUNNING';
                --Bug#11794442 end

                    INL_LOGGING_PVT.Log_Variable(
                        p_module_name    => g_module_name,
                        p_procedure_name => l_program_name,
                        p_var_name       => 'match_int_list('||i||').group_id',
                        p_var_value      => match_int_list(i).group_id
                    ) ;

                    INL_LOGGING_PVT.Log_Variable(
                        p_module_name    => g_module_name,
                        p_procedure_name => l_program_name,
                        p_var_name       => 'match_int_list(i).match_int_id',
                        p_var_value      => match_int_list(i).match_int_id
                    ) ;

                    INL_LOGGING_PVT.Log_Variable(
                        p_module_name    => g_module_name,
                        p_procedure_name => l_program_name,
                        p_var_name       => 'match_int_list(i).transaction_type',
                        p_var_value      => match_int_list(i).transaction_type
                    ) ;

                    INL_LOGGING_PVT.Log_Variable(
                        p_module_name    => g_module_name,
                        p_procedure_name => l_program_name,
                        p_var_name       => 'match_int_list(i).to_parent_table_name',
                        p_var_value      => match_int_list(i).to_parent_table_name
                    ) ;

                    INL_LOGGING_PVT.Log_Variable(
                        p_module_name    => g_module_name,
                        p_procedure_name => l_program_name,
                        p_var_name       => 'match_int_list(i).to_parent_table_id',
                        p_var_value      => match_int_list(i).to_parent_table_id
                    ) ;

                    l_debug_info := 'Delete errors from previous analysis performed on the current line. Call Reset_InterfError';
                    INL_LOGGING_PVT.Log_Statement(
                        p_module_name      => g_module_name,
                        p_procedure_name   => l_program_name,
                        p_debug_info       => l_debug_info
                    );
                    Reset_InterfError(
                        p_parent_table_name       => 'INL_MATCHES_INT',
                        p_parent_table_id => match_int_list(i) .match_int_id,
                        x_return_status => l_return_status
                    ) ;
                    -- If any errors happen abort the process.
                    IF l_return_status = L_FND_RET_STS_ERROR THEN
                        RAISE L_FND_EXC_ERROR;
                    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                        RAISE L_FND_EXC_UNEXPECTED_ERROR;
                    END IF;
                    l_debug_info := 'Call Derive_MatchCols';
                    INL_LOGGING_PVT.Log_Statement(
                        p_module_name      => g_module_name,
                        p_procedure_name   => l_program_name,
                        p_debug_info       => l_debug_info
                    );
                    Derive_MatchCols(
                        p_party_number          => match_int_list(i).party_number,
                        p_party_site_number     => match_int_list(i).party_site_number,
                        p_match_type_code       => match_int_list(i).match_type_code,
                        p_to_parent_table_name  => match_int_list(i).to_parent_table_name,
                        p_to_parent_table_id    => match_int_list(i).to_parent_table_id,
                        p_party_id              => match_int_list(i).party_id,
                        p_party_site_id         => match_int_list(i).party_site_id,
                        p_parent_match_id       => match_int_list(i).parent_match_id,
                        x_return_status         => l_return_status) ;
                    -- If any errors happen abort the process.
                    IF l_return_status = L_FND_RET_STS_ERROR THEN
                        RAISE L_FND_EXC_ERROR;
                    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                        RAISE L_FND_EXC_UNEXPECTED_ERROR;
                    END IF;
                    l_debug_info := 'Validate Match before import it from interface. Call Validate_MatchInt';
                    INL_LOGGING_PVT.Log_Statement(
                        p_module_name      => g_module_name,
                        p_procedure_name   => l_program_name,
                        p_debug_info       => l_debug_info
                    );

                    l_import_validation := Validate_MatchInt(
                                            p_match_int_rec => match_int_list(i),
                                            x_return_status => l_return_status)
                    ;
                    -- If any errors happen abort the process.

                    IF l_return_status = L_FND_RET_STS_ERROR THEN
                        RAISE L_FND_EXC_ERROR;
                    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                        RAISE L_FND_EXC_UNEXPECTED_ERROR;
                    END IF;
                    -- Validation has been executed successfully and
                    -- processing status code has been changed to RUNNING
--Bug#11794442
                EXCEPTION
                    WHEN OTHERS THEN
                        l_import_validation := FALSE;
                        Handle_InterfError(
                            p_parent_table_name  => 'INL_MATCHES_INT',
                            p_parent_table_id    => match_int_list(i).match_int_id,
                            p_column_name        => 'match_int_list('||i||').match_int_id',
                            p_column_value       => match_int_list(i).match_int_id,
                            p_error_message_name => 'INL_FAILED_ON_CONC_SUB',
                            p_token1_name        => 'CONC',
                            p_token1_value       => 'Import_Matches exception',
                            x_return_status      => l_return_status);
                        -- If unexpected errors happen abort
                        IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
                            RAISE L_FND_EXC_UNEXPECTED_ERROR;
                        END IF;
                END; --Bug#11794442
                IF (l_import_validation = TRUE) THEN
                    INL_LOGGING_PVT.Log_Statement(
                        p_module_name      => g_module_name,
                        p_procedure_name   => l_program_name,
                        p_debug_info       => 'l_import_validation: TRUE'
                    );
                ELSE
                    INL_LOGGING_PVT.Log_Statement(
                        p_module_name      => g_module_name,
                        p_procedure_name   => l_program_name,
                        p_debug_info       => 'l_import_validation: FALSE'
                    );
                END IF;

                INL_LOGGING_PVT.Log_Variable(p_module_name => g_module_name,
                                 p_procedure_name => l_program_name,
                                 p_var_name => 'l_bad_group_id',
                                 p_var_value => l_bad_group_id);

                IF (l_import_validation = TRUE)
                AND (l_bad_group_id IS NULL
                     OR match_int_list(i).group_id IS NULL
                     OR match_int_list(i).group_id <> l_bad_group_id)
                THEN
                    l_debug_info := 'Set Interface Status to RUNNING';
                    INL_LOGGING_PVT.Log_Statement(
                        p_module_name      => g_module_name,
                        p_procedure_name   => l_program_name,
                        p_debug_info       => l_debug_info
                    );

                    UPDATE inl_matches_int
                    SET processing_status_code = 'RUNNING'         ,
                        party_id               = match_int_list(i).party_id       ,
                        party_site_id          = match_int_list(i).party_site_id  ,
--                        request_id             = L_FND_CONC_REQUEST_ID       ,--Bug#11794442
                        last_updated_by        = L_FND_USER_ID               ,
                        last_update_date       = SYSDATE                          ,
                        last_update_login      = L_FND_LOGIN_ID              ,
                        program_id             = L_FND_CONC_PROGRAM_ID       ,
                        program_update_date    = SYSDATE                          ,
                        program_application_id = L_FND_PROG_APPL_ID
                    WHERE match_int_id       = match_int_list(i).match_int_id;

                ELSIF (match_int_list(i).group_id IS NULL
                        OR l_bad_group_id IS NULL --SCM-051
                        OR match_int_list(i).group_id <> l_bad_group_id)
                THEN
                    l_bad_group_id := match_int_list(i).group_id;
                    ROLLBACK TO Run_MatchPreProcSVPNT;
                    SAVEPOINT Run_MatchPreProcSVPNT;
                    l_debug_info := 'Set Interface Status to ERROR for group id(2): '||match_int_list(i).group_id||sqlerrm; --Bug#14044298
                    INL_LOGGING_PVT.Log_Statement(
                        p_module_name      => g_module_name,
                        p_procedure_name   => l_program_name,
                        p_debug_info       => l_debug_info
                    );
                    UPDATE inl_matches_int mi
                    SET mi.processing_status_code = 'ERROR'         ,
                        mi.request_id             = L_FND_CONC_REQUEST_ID       ,
                        mi.last_updated_by        = L_FND_USER_ID               ,
                        mi.last_update_date       = SYSDATE                          ,
                        mi.last_update_login      = L_FND_LOGIN_ID              ,
                        mi.program_id             = L_FND_CONC_PROGRAM_ID       ,
                        mi.program_update_date    = SYSDATE                          ,
                        mi.program_application_id = L_FND_PROG_APPL_ID
                    WHERE (match_int_list(i).group_id IS NOT NULL
                            AND mi.group_id = match_int_list(i).group_id)
                    OR (match_int_list(i).group_id IS NULL
                        AND mi.match_int_id = match_int_list(i).match_int_id);
                ELSE
                    l_debug_info := 'Error in marked group id: '||match_int_list(i).group_id;
                    INL_LOGGING_PVT.Log_Statement(
                        p_module_name      => g_module_name,
                        p_procedure_name   => l_program_name,
                        p_debug_info       => l_debug_info
                    );
                END IF;

--Bug#11794442
            END LOOP;
            -- Standard check of p_commit.
            IF FND_API.To_Boolean(p_commit) THEN
                COMMIT WORK;
            END IF;

        ELSE
            IF g_records_processed = 0 THEN
                -- Add a line into inl_ship_errors
                -- Bug 13920858: Commented the code to avoid Error Messages getting Inserted into INL_INTERFACE_ERRORS table.
                l_debug_info := 'Error Mesage: No records found for processing.';
                INL_LOGGING_PVT.Log_Statement(
                    p_module_name      => g_module_name,
                    p_procedure_name   => l_program_name,
                    p_debug_info       => l_debug_info
                );

 /*               Handle_InterfError(
                    p_parent_table_name  => 'INL_MATCHES_INT',
                    p_parent_table_id    => 0,
                    p_column_name        => 'P_GROUP_ID',
                    p_column_value       => p_group_id,
                    p_error_message_name => 'INL_NO_RECORDS_FOUND_ERR',
                    x_return_status      => l_return_status
                );
                -- If unexpected errors happen abort
                IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
                    RAISE L_FND_EXC_UNEXPECTED_ERROR;
                END IF;
*/
            END IF;

            --Bug#16198838/14707257 BEGIN
            SELECT NVL(MAX(match_int_id),0)
            INTO l_max_match_int_id2
            FROM inl_matches_int
            WHERE match_int_id < l_max_match_int_id+1
            AND (nvl(request_id,1) > 0
                 OR request_id = -1)
            AND processing_status_code = 'PENDING'
            AND (p_group_id IS NULL
                 OR group_id = p_group_id)
            ;
            IF l_max_match_int_id2 > 0
            THEN
                OPEN c_unproc_match_int(l_max_match_int_id+1);
                FETCH c_unproc_match_int BULK COLLECT INTO l_unproc_match_int_lst;
                CLOSE c_unproc_match_int;

                IF NVL(l_unproc_match_int_lst.LAST, 0) > 0 THEN
                    l_debug_info := 'Unable to process the following groups (group_id): (review HR:security profile restriction)';
                    INL_LOGGING_PVT.Log_Statement(
                        p_module_name      => g_module_name,
                        p_procedure_name   => l_program_name,
                        p_debug_info       => l_debug_info
                    );
                    FND_FILE.put_line( FND_FILE.log, l_debug_info);
                    l_debug_info := '';
                    FOR i IN NVL(l_unproc_match_int_lst.FIRST, 0)..NVL(l_unproc_match_int_lst.LAST, 0)
                    LOOP
                        l_debug_info:=l_debug_info||l_unproc_match_int_lst(i).group_id||',';
                        IF LENGTH(l_debug_info)>70 THEN
                            INL_LOGGING_PVT.Log_Statement(
                                p_module_name      => g_module_name,
                                p_procedure_name   => l_program_name,
                                p_debug_info       => l_debug_info
                            );
                            FND_FILE.put_line( FND_FILE.log, SUBSTR(l_debug_info,1,LENGTH(l_debug_info)-1));
                            l_debug_info:=NULL;
                        END IF;
                    END LOOP;
                    IF LENGTH(l_debug_info)>1 THEN
                        INL_LOGGING_PVT.Log_Statement(
                            p_module_name      => g_module_name,
                            p_procedure_name   => l_program_name,
                            p_debug_info       => l_debug_info
                        );
                        FND_FILE.put_line( FND_FILE.log, SUBSTR(l_debug_info,1,LENGTH(l_debug_info)-1));
                        l_debug_info:=NULL;
                    END IF;
                END IF;
            END IF;
            --Bug#16198838/14707257 END

            EXIT;
        END IF;
    END LOOP; --Bug#11794442

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    );
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        x_return_status := L_FND_RET_STS_ERROR;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name
            );
        END IF;
END Run_MatchPreProcessor;

-- Bug #8264427
-- API name : Purge_LCMShipInt
-- Type       : Public
-- Function   : API that purges completed records
--              from LCM Shipment Interface tables.
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version   IN NUMBER
--              p_init_msg_list IN VARCHAR2 := L_FND_FALSE
--              p_commit        IN VARCHAR2 := L_FND_FALSE
--              p_group_id      IN NUMBER
--
-- OUT        : x_return_status OUT NOCOPY VARCHAR2
--              x_msg_count     OUT NOCOPY NUMBER
--              x_msg_data      OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Purge_LCMShipInt(p_api_version   IN NUMBER,
                           p_init_msg_list IN VARCHAR2 := L_FND_FALSE,
                           p_commit        IN VARCHAR2 := L_FND_FALSE,
                           p_group_id      IN NUMBER,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_msg_count     OUT NOCOPY NUMBER,
                           x_msg_data      OUT NOCOPY VARCHAR2) IS

    l_program_name      CONSTANT VARCHAR2(30) := 'Purge_LCMShipInt';
    l_api_version   CONSTANT NUMBER := 1.0;
    l_return_status VARCHAR2(1) ;
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);
    l_debug_info    VARCHAR2(200);

    CURSOR c_shipToDelete IS
        SELECT shi.ship_header_int_id
          FROM inl_ship_headers_int shi
         WHERE (p_group_id IS NULL OR shi.group_id = p_group_id)
           AND processing_status_code = 'COMPLETED';

    TYPE shipToDelete_ListType IS TABLE OF c_shipToDelete%ROWTYPE;
    shipToDelete_List shipToDelete_ListType;

BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(p_module_name => g_module_name,
                                  p_procedure_name => l_program_name ) ;

    -- Standard Start of API savepoint
    SAVEPOINT Purge_LCMShipInt_PVT;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(p_current_version_number => l_api_version,
                                       p_caller_version_number => p_api_version,
                                       p_api_name => l_program_name,
                                       p_pkg_name => g_pkg_name)
    THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;

    -- Logging variables
    INL_LOGGING_PVT.Log_Variable(p_module_name => g_module_name,
                                 p_procedure_name => l_program_name,
                                 p_var_name => 'p_group_id',
                                 p_var_value => p_group_id);

    OPEN c_shipToDelete;
    FETCH c_shipToDelete BULK COLLECT INTO shipToDelete_List;

    CLOSE c_shipToDelete;
    IF NVL(shipToDelete_List.COUNT, 0) > 0 THEN
        FOR iHead IN 1 .. shipToDelete_List.COUNT
        LOOP

          l_debug_info := 'Delete from INL_SHIP_HEADERS_INT ';
          INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                         p_procedure_name => l_program_name,
                                         p_debug_info => l_debug_info);

          DELETE FROM inl_ship_headers_int
          WHERE ship_header_int_id = shipToDelete_List(iHead).ship_header_int_id;

          l_debug_info := 'Delete from INL_SHIP_LINES_INT ';
          INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                         p_procedure_name => l_program_name,
                                         p_debug_info => l_debug_info);

          DELETE FROM inl_ship_lines_int
          WHERE ship_header_int_id = shipToDelete_List(iHead).ship_header_int_id;

        END LOOP;
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded => L_FND_FALSE,
                              p_count => x_msg_count,
                              p_data => x_msg_data) ;

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(p_module_name    => g_module_name,
                                p_procedure_name => l_program_name);

EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (p_module_name => g_module_name,
                                        p_procedure_name => l_program_name);
        ROLLBACK TO Purge_LCMShipInt_PVT;
        x_return_status := L_FND_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_encoded => L_FND_FALSE,
                                  p_count => x_msg_count,
                                  p_data => x_msg_data);
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (p_module_name => g_module_name,
                                          p_procedure_name => l_program_name);
        ROLLBACK TO Purge_LCMShipInt_PVT;
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_encoded => L_FND_FALSE,
                                  p_count => x_msg_count,
                                  p_data => x_msg_data);
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (p_module_name => g_module_name,
                                          p_procedure_name => l_program_name);
        ROLLBACK TO Purge_LCMShipInt_PVT;
        x_return_status := L_FND_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(p_pkg_name => g_pkg_name,
                                    p_procedure_name => l_program_name );
        END IF;
        FND_MSG_PUB.Count_And_Get(p_encoded => L_FND_FALSE,
                                  p_count => x_msg_count,
                                  p_data => x_msg_data);
END Purge_LCMShipInt;

-- Bug #8264437
-- API name   : Purge_LCMMatchesInt
-- Type       : Public
-- Function   : API that purges completed records
--              from LCM Match Interface tables.
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version   IN NUMBER
--              p_init_msg_list IN VARCHAR2 := L_FND_FALSE
--              p_commit        IN VARCHAR2 := L_FND_FALSE
--              p_group_id      IN NUMBER
--
-- OUT        : x_return_status OUT NOCOPY VARCHAR2
--              x_msg_count     OUT NOCOPY NUMBER
--              x_msg_data      OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Purge_LCMMatchesInt(
    p_api_version   IN NUMBER,
    p_init_msg_list IN VARCHAR2 := L_FND_FALSE,
    p_commit        IN VARCHAR2 := L_FND_FALSE,
    p_group_id      IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2
) IS

    l_program_name      CONSTANT VARCHAR2(30) := 'Purge_LCMMatchesInt';
    l_api_version   CONSTANT NUMBER := 1.0;
    l_return_status VARCHAR2(1) ;
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);
    l_debug_info    VARCHAR2(200);

BEGIN

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(p_module_name => g_module_name,
                                  p_procedure_name => l_program_name ) ;

    -- Standard Start of API savepoint
    SAVEPOINT Purge_LCMMatchesInt_PVT;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(p_current_version_number => l_api_version,
                                       p_caller_version_number => p_api_version,
                                       p_api_name => l_program_name,
                                       p_pkg_name => g_pkg_name)
    THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;

    -- Logging variables
    INL_LOGGING_PVT.Log_Variable(p_module_name => g_module_name,
                                 p_procedure_name => l_program_name,
                                 p_var_name => 'p_group_id',
                                 p_var_value => p_group_id);

    l_debug_info := 'Delete from INL_MATCHES_INT';
    INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                   p_procedure_name => l_program_name,
                                   p_debug_info => l_debug_info) ;

    DELETE FROM inl_matches_int
          WHERE (p_group_id IS NULL OR group_id = p_group_id)
            AND processing_status_code = 'COMPLETED';

    -- Standard check of p_commit.
    IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded => L_FND_FALSE,
                              p_count => x_msg_count,
                              p_data => x_msg_data) ;

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(p_module_name    => g_module_name,
                                p_procedure_name => l_program_name);

EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (p_module_name => g_module_name,
                                        p_procedure_name => l_program_name);
        ROLLBACK TO Purge_LCMMatchesInt_PVT;
        x_return_status := L_FND_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_encoded => L_FND_FALSE,
                                  p_count => x_msg_count,
                                  p_data => x_msg_data);
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (p_module_name => g_module_name,
                                          p_procedure_name => l_program_name);
        ROLLBACK TO Purge_LCMMatchesInt_PVT;
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_encoded => L_FND_FALSE,
                                  p_count => x_msg_count,
                                  p_data => x_msg_data);
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (p_module_name => g_module_name,
                                          p_procedure_name => l_program_name);
        ROLLBACK TO Purge_LCMMatchesInt_PVT;
        x_return_status := L_FND_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(p_pkg_name => g_pkg_name,
                                    p_procedure_name => l_program_name );
        END IF;
        FND_MSG_PUB.Count_And_Get(p_encoded => L_FND_FALSE,
                                  p_count => x_msg_count,
                                  p_data => x_msg_data);
END Purge_LCMMatchesInt;

-- Utility name : Run_MatchPostProcessor
-- Type       : Private
-- Function   : Post processor to import Match Lines.
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_group_id      IN NUMBER
--
-- OUT        : x_return_status OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Run_MatchPostProcessor(
    p_group_id      IN NUMBER,
    p_commit        IN VARCHAR2, --Bug#11794442
    x_return_status OUT NOCOPY VARCHAR2
) IS

    l_program_name     CONSTANT VARCHAR2(100) := 'Run_MatchPostProcessor';
    l_return_status VARCHAR2(1) ;
    l_debug_info    VARCHAR2(200);
    l_msg_data      VARCHAR2(2000) ;
    l_msg_count     NUMBER;
    l_init_msg_list VARCHAR2(2000) := L_FND_FALSE;

BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    ) ;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;
    l_debug_info := 'Import Matches. Call Import_Matches';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    );
    Import_Matches(
        p_group_id      => p_group_id,
        p_commit        => p_commit, --Bug#11794442
        x_return_status => l_return_status
    );
    -- If any errors happen abort API.
    IF l_return_status = L_FND_RET_STS_ERROR THEN
        RAISE L_FND_EXC_ERROR;
    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;

    -- Bug #8264437
    -- Interface records that got completed successfully
    -- are removed from INL_MACHES_INT
    Purge_LCMMatchesInt(p_api_version   => 1.0,
                        p_init_msg_list => l_init_msg_list,
                        p_commit        => p_commit,
                        p_group_id      => p_group_id,
                        x_return_status => l_return_status,
                        x_msg_count     => l_msg_count,
                        x_msg_data      => l_msg_data);

    -- If any errors happen abort API.
    IF l_return_status = L_FND_RET_STS_ERROR THEN
        RAISE L_FND_EXC_ERROR;
    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    );
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        x_return_status := L_FND_RET_STS_ERROR;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name
            );
        END IF;
END Run_MatchPostProcessor;

-- Utility name   : Import_LCMShipments
-- Type       : Public
-- Function   : This is called by a concurrent program to Import Shipments.
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_group_id      IN NUMBER
--
-- OUT        : errbuf          OUT NOCOPY VARCHAR2
--              retcode         OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Import_LCMShipments(
    errbuf     OUT NOCOPY  VARCHAR2,
    retcode    OUT NOCOPY VARCHAR2,
    p_group_id IN NUMBER
    --  p_org_id   IN NUMBER
)  IS

    l_program_name CONSTANT VARCHAR2(30) := 'Import_LCMShipments';
    l_return_status VARCHAR2(1) ;
    l_msg_data VARCHAR2(2000) ;
    l_debug_info VARCHAR2(200) ;
    l_msg_count NUMBER;

BEGIN

    errbuf  := NULL;
    retcode := 0;
    g_records_processed := 0;
    g_records_inserted := 0;

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name) ;

    l_debug_info := 'Call Import_LCMShipments';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_debug_info => l_debug_info
    );

    Import_LCMShipments(
        p_api_version   => 1.0,
        p_init_msg_list => L_FND_TRUE,
        p_commit        => L_FND_TRUE,
        p_group_id      => p_group_id,
        x_return_status => l_return_status,
        x_msg_count     => l_msg_count,
        x_msg_data      => l_msg_data
    ) ;

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
    ELSIF NVL(G_RECORDS_COMPLETED,0) <> NVL(G_RECORDS_INSERTED,0) THEN -- Bug #16310024
        retcode := 1;
    END IF;

    -- Write the number of records processed and inserted by this concurrent process
    FND_FILE.put_line( FND_FILE.log, '< **************************************>');
    FND_FILE.put_line( FND_FILE.log, '< ***** ' || 'LCM Shipments Processed: ' || g_records_processed); -- Bug #9258936
    FND_FILE.put_line( FND_FILE.log, '< ***** ' || 'LCM Shipments Inserted: ' || g_records_inserted);   -- Bug #9258936
    FND_FILE.put_line( FND_FILE.log, '< ***** ' || 'LCM Shipments Completed: ' || g_records_completed);   -- Bug #16310024
    FND_FILE.put_line( FND_FILE.log, '< **************************************>');

    -- If any errors happen abort API.
    IF l_return_status = L_FND_RET_STS_ERROR THEN
        RAISE L_FND_EXC_ERROR;
    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);

EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        retcode := 1;
        errbuf := errbuf ||' G_EXC_ERROR '||SQLERRM;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        retcode := 2;
        errbuf := errbuf ||' G_EXC_UNEXPECTED_ERROR '||SQLERRM;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        retcode := 2;
        errbuf := errbuf ||' OTHERS '||SQLERRM;
END Import_LCMShipments;

-- Utility name   : Import_LCMMatches
-- Type       : Public
-- Function   : This is called by a concurrent
--              program to import LCM Match Lines.
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_group_id      IN NUMBER
--
-- OUT        : errbuf          OUT NOCOPY VARCHAR2
--              retcode         OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Import_LCMMatches(errbuf     OUT NOCOPY  VARCHAR2,
                            retcode    OUT NOCOPY VARCHAR2,
                            p_group_id IN NUMBER)
IS

    l_program_name     CONSTANT VARCHAR2(30) := 'Import_LCMMatches';
    l_return_status VARCHAR2(1) ;
    l_msg_data      VARCHAR2(2000) ;
    l_debug_info    VARCHAR2(200) ;
    l_msg_count     NUMBER;

BEGIN

    errbuf  := NULL;
    retcode := 0;
    g_records_processed := 0;
    g_records_inserted := 0;

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(p_module_name => g_module_name,
                                  p_procedure_name => l_program_name);

    l_debug_info := 'Call Import_LCMMatches';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_debug_info => l_debug_info
    );

    Import_LCMMatches(
        p_api_version     => 1.0,
        p_init_msg_list   => L_FND_TRUE,
        p_commit          => L_FND_TRUE,
        p_group_id        => p_group_id,
        x_return_status   => l_return_status,
        x_msg_count       => l_msg_count,
        x_msg_data        => l_msg_data
    );

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

    -- Write the number of records processed and inserted by this concurrent process
    FND_FILE.put_line( FND_FILE.log, '< **************************************>');
    FND_FILE.put_line( FND_FILE.log, '< ***** ' || 'Records Processed: ' || g_records_processed);  -- Bug #9258936
    FND_FILE.put_line( FND_FILE.log, '< ***** ' || 'Records Inserted: ' || g_records_inserted);    -- Bug #9258936
    FND_FILE.put_line( FND_FILE.log, '< **************************************>');

    -- If any errors happen abort API.
    IF l_return_status = L_FND_RET_STS_ERROR THEN
        RAISE L_FND_EXC_ERROR;
    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(p_module_name => g_module_name,
                                p_procedure_name => l_program_name);
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        retcode := 1;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        retcode := 2;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        retcode := 2;
END Import_LCMMatches;

-- API name   : Import_LCMMatches
-- Type       : Public
-- Function   : Main Import procedure. It calls the
--              Pre and Post processors to import Match Lines
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version   IN NUMBER
--              p_init_msg_list IN VARCHAR2 := L_FND_FALSE
--              p_commit        IN VARCHAR2 := L_FND_FALSE
--              p_group_id      IN NUMBER
--
-- OUT        : x_return_status OUT NOCOPY VARCHAR2
--              x_msg_count     OUT NOCOPY NUMBER
--              x_msg_data      OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Import_LCMMatches(
    p_api_version   IN NUMBER,
    p_init_msg_list IN VARCHAR2 := L_FND_FALSE,
    p_commit        IN VARCHAR2 := L_FND_FALSE,
    p_group_id      IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2
) IS
    l_program_name      CONSTANT VARCHAR2(30) := 'Import_LCMMatches';
    l_api_version   CONSTANT NUMBER := 1.0;
    l_return_status VARCHAR2(1) ;
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000) ;
    l_debug_info    VARCHAR2(200) ;
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    ) ;

    -- Standard Start of API savepoint
    SAVEPOINT Import_LCMMatches_PVT;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(
                p_current_version_number => l_api_version,
                p_caller_version_number => p_api_version,
                p_api_name => l_program_name,
                p_pkg_name => g_pkg_name)
    THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;
    l_debug_info := 'Run Match Pre-Processor(first level validation). Call Run_MatchPreProcessor';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    );

    Run_MatchPreProcessor(
        p_group_id      => p_group_id,
        p_commit        => p_commit,
        x_return_status => l_return_status
    );
    -- If any errors happen abort API.
    IF l_return_status = L_FND_RET_STS_ERROR THEN
        RAISE L_FND_EXC_ERROR;
    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
    l_debug_info := 'Run Match Post-Processor. Call Run_MatchPostProcessor';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name   => g_module_name,
        p_procedure_name=> l_program_name,
        p_debug_info    => l_debug_info
    );
    Run_MatchPostProcessor(
        p_group_id      => p_group_id,
        p_commit        => p_commit,
        x_return_status => l_return_status
    ) ;
    -- If any errors happen abort API.
    IF l_return_status = L_FND_RET_STS_ERROR THEN
        RAISE L_FND_EXC_ERROR;
    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Standard check of p_commit.
    IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded   => L_FND_FALSE,
        p_count     => x_msg_count,
        p_data      => x_msg_data
    ) ;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    );
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        ROLLBACK TO Import_LCMMatches_PVT;
        x_return_status := L_FND_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded        =>      L_FND_FALSE,
            p_count          =>      x_msg_count,
            p_data           =>      x_msg_data
        );
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        ROLLBACK TO Import_LCMMatches_PVT;
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded        =>      L_FND_FALSE,
            p_count          =>      x_msg_count,
            p_data           =>      x_msg_data
        );
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        ROLLBACK TO Import_LCMMatches_PVT;
        x_return_status := L_FND_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name
            );
        END IF;
        FND_MSG_PUB.Count_And_Get(
            p_encoded        =>      L_FND_FALSE,
            p_count          =>      x_msg_count,
            p_data           =>      x_msg_data
        );

END Import_LCMMatches;

-- Utility name : select_LCMShipToProc
-- Type         : Private
-- Function     : Select the interface records to process
-- Pre-reqs     :
-- Version    : Current version 1.0
--
-- IN         : p_group_id IN NUMBER
--              p_simulation_id IN NUMBER
--
-- OUT        : x_return_status  OUT NOCOPY VARCHAR2
--
-- Notes      :

FUNCTION Select_LCMShipToProc(
    p_group_id          IN NUMBER,
    p_simulation_id     IN NUMBER,
    x_return_status     OUT NOCOPY VARCHAR2
) RETURN NUMBER IS
    l_program_name     CONSTANT VARCHAR2(30) := 'select_LCMShipToProc';

    l_lines         CONSTANT NUMBER:=50; --NUMBER of lines to process in each iteration

    l_return_status VARCHAR2(1);
    l_debug_info    VARCHAR2(200);
    l_return_value  NUMBER:=0;
    l_count_records NUMBER;
    l_lock_name     VARCHAR2(50) := 'select_LCMShipToProc';
    l_lock_handle   VARCHAR2(100);
    l_lock_status   NUMBER;
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    ) ;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_group_id',
        p_var_value      => p_group_id);

    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_debug_info => 'Acquiring lock (Allocate_Unique) on: ' || l_lock_name
    );

    DBMS_LOCK.Allocate_Unique(
        lockname   => l_lock_name,
        lockhandle => l_lock_handle
    );

    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_debug_info => 'Acquiring lock (Request)'
    );

    l_lock_status := DBMS_LOCK.Request(
                        lockhandle => l_lock_handle,
                        lockmode => DBMS_LOCK.x_mode
                     );

    IF l_lock_status <> 0 THEN
        INL_LOGGING_PVT.Log_Statement (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_debug_info     => 'Failled to get the lock '||l_lock_name||' status: '||l_lock_status);

        RAISE FND_API.G_EXC_ERROR;
    END IF;

    UPDATE inl_ship_headers_int
        SET request_id = l_fnd_conc_request_id_int
        WHERE (nvl(request_id,1) > 0
                OR request_id = -1) --Bug#11794483B
        AND processing_status_code = 'PENDING'
        AND (p_group_id IS NULL
             OR group_id = p_group_id)
        AND ROWNUM < l_lines;
    l_return_value := SQL%ROWCOUNT;
    INL_LOGGING_PVT.Log_Statement (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_debug_info     => l_return_value||' selected records');

    -- Release the lock
    l_lock_status := DBMS_LOCK.RELEASE(l_lock_handle);
    l_lock_handle := NULL;

    RETURN l_return_value;

EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        x_return_status := L_FND_RET_STS_ERROR;
        IF l_lock_handle IS NOT NULL THEN
            l_lock_status := DBMS_LOCK.Release(l_lock_handle);
        END IF;
        RETURN 0;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
        IF l_lock_handle IS NOT NULL THEN
            l_lock_status := DBMS_LOCK.Release(l_lock_handle);
        END IF;
        RETURN 0;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name
            );
        END IF;
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
        IF l_lock_handle IS NOT NULL THEN
            l_lock_status := DBMS_LOCK.Release(l_lock_handle);
        END IF;
        RETURN 0;
END Select_LCMShipToProc;



-- Utility name : Check_HeaderWithoutLine
-- Type         : Private
-- Function     : Select the interface records to process
-- Pre-reqs     :
-- Version    : Current version 1.0
--
-- Notes      :

FUNCTION Check_HeaderWithoutLine(
    x_return_status     OUT NOCOPY VARCHAR2
) RETURN NUMBER IS
    l_program_name     CONSTANT VARCHAR2(30) := 'Check_HeaderWithoutLine';

    l_return_status VARCHAR2(1);
    l_debug_info    VARCHAR2(200);

    l_count_records NUMBER;

BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    ) ;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;

    l_debug_info := 'Header records with transaction_type = CREATE should have at least one line, verifying...';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    ) ;

    INSERT INTO inl_interface_errors (
            interface_error_id,             /*01*/
            parent_table_name,              /*02*/
            parent_table_id,                /*03*/
            column_name,                    /*04*/
            column_value,                   /*05*/
            processing_date,                /*06*/
            error_message_name,             /*07*/
            error_message,                  /*08*/
            token1_name,                    /*09*/
            token1_value,                   /*10*/
            created_by,                     /*11*/
            creation_date,                  /*12*/
            last_updated_by,                /*13*/
            last_update_date,               /*14*/
            last_update_login,              /*15*/
            program_id,                     /*16*/
            program_application_id,         /*17*/
            program_update_date,            /*18*/
            request_id                      /*19*/
        )
        SELECT
            inl_interface_errors_s.NEXTVAL, /*01*/
            'INL_SHIP_HEADERS_INT',         /*02*/
            h.ship_header_int_id,           /*03*/
            'ship_header_int_id',           /*04*/
            h.ship_header_int_id,           /*05*/
            SYSDATE,                        /*06*/
            'INL_FAILED_ON_CONC_SUB',       /*07*/
            'No Line has been found',       /*08*/
            'CONC',                         /*09*/
            'Run_ShipPreProcessor (step0)', /*10*/
            L_FND_USER_ID,                  /*11*/
            SYSDATE,                        /*12*/
            L_FND_USER_ID,                  /*13*/
            SYSDATE,                        /*14*/
            L_FND_USER_ID,                  /*15*/
            L_FND_CONC_PROGRAM_ID,          /*16*/
            L_FND_PROG_APPL_ID,             /*17*/
            SYSDATE,                        /*18*/
            L_FND_CONC_REQUEST_ID           /*19*/
    FROM inl_ship_headers_int h
    WHERE NVL(h.request_id,1) > 0
    AND h.processing_status_code = 'PENDING'
    AND h.transaction_type = 'CREATE'
    AND NOT EXISTS
        (SELECT 1
         FROM inl_ship_lines_int l
         WHERE l.ship_header_int_id = h.ship_header_int_id
         AND ROWNUM < 2);

    l_debug_info := 'Inserted '||SQL%ROWCOUNT ||' error messages into Interface Error table.';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info) ;
    IF SQL%ROWCOUNT > 0 THEN
        l_debug_info := 'Set Shipment Header Interface status to ERROR.';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info) ;



        UPDATE inl_ship_headers_int h
        SET h.processing_status_code      = 'ERROR'              ,
            h.request_id                  = L_FND_CONC_REQUEST_ID,
            h.last_updated_by             = L_FND_USER_ID        ,
            h.last_update_date            = SYSDATE              ,
            h.last_update_login           = L_FND_LOGIN_ID       ,
            h.program_id                  = L_FND_CONC_PROGRAM_ID,
            h.program_update_date         = SYSDATE              ,
            h.program_application_id      = L_FND_PROG_APPL_ID
        WHERE NVL(h.request_id,1) > 0
        AND processing_status_code = 'PENDING'
        AND transaction_type = 'CREATE'
        AND NOT EXISTS
            (SELECT 1
             FROM inl_ship_lines_int l
             WHERE l.ship_header_int_id = h.ship_header_int_id
             AND ROWNUM < 2);
    END IF;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);

    RETURN NVL(sql%ROWCOUNT,0);
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        x_return_status := L_FND_RET_STS_ERROR;
        RETURN 0;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
        RETURN 0;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name
            );
        END IF;
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
        RETURN 0;
END Check_HeaderWithoutLine;

-- Utility name : Validate_shipHdrInt
-- Type       : Private
-- Function   : Validate the transaction type
--
-- Pre-reqs   : None
-- Parameters :
-- IN         :
--
-- IN OUT     : p_ship_hdr_int_rec  IN c_ship_hdr_int%ROWTYPE
--              x_return_status      IN OUT NOCOPY VARCHAR2

-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Validate_ShipHdrInt(
    x_ship_hdr_int_rec   IN OUT NOCOPY c_ship_hdr_int%ROWTYPE,
    x_return_status      IN OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
    l_program_name     CONSTANT VARCHAR2(30) := 'Validate_ShipHdrInt';
    l_return_status VARCHAR2(1) ;
    l_debug_info    VARCHAR2(400) ;
    l_response_int      BOOLEAN := TRUE;
    l_response      BOOLEAN := TRUE;
    l_ship_header_id NUMBER;
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name) ;
    --  Initialize API return status to success
    x_return_status      := L_FND_RET_STS_SUCCESS;

    IF x_ship_hdr_int_rec.transaction_type IN ('UPDATE','DELETE') --Bug#11794483C
    THEN
        l_ship_header_id := x_ship_hdr_int_rec.ship_header_id;
    END IF;

    l_debug_info := 'Call Validate_Organization';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_debug_info     => l_debug_info) ;

    l_response_int := Validate_Organization(
        p_ship_header_int_id            => x_ship_hdr_int_rec.ship_header_int_id,
        p_validation_flag               => x_ship_hdr_int_rec.validation_flag,
        p_ship_header_id                => l_ship_header_id,
        x_organization_id               => x_ship_hdr_int_rec.organization_id,
        x_organization_code             => x_ship_hdr_int_rec.organization_code,
        x_org_id                        => x_ship_hdr_int_rec.org_id,
        x_user_defined_ship_num_code    => x_ship_hdr_int_rec.user_defined_ship_num_code,
        x_manual_ship_num_type          => x_ship_hdr_int_rec.manual_ship_num_type,
        x_LCM_FLOW                      => x_ship_hdr_int_rec.LCM_FLOW,
        x_legal_entity_id               => x_ship_hdr_int_rec.legal_entity_id,
        x_return_status                 => l_return_status) ;

    -- If any errors happen abort API.
    IF l_return_status = L_FND_RET_STS_ERROR THEN
        RAISE L_FND_EXC_ERROR;
    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
    IF (l_response_int)
    THEN
        l_debug_info := 'True';
    ELSE
        l_debug_info := 'False';
        l_response := l_response_int;
    END IF;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'l_response_int',
        p_var_value      => l_debug_info);

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'x_ship_hdr_int_rec.ship_num',
        p_var_value      => x_ship_hdr_int_rec.ship_num);

    l_debug_info := 'Transaction Type validation';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info);

    l_response_int :=
        Validate_HdrTrxType(
                    p_ship_header_int_id => x_ship_hdr_int_rec.ship_header_int_id                ,
                    p_transaction_type   => x_ship_hdr_int_rec.transaction_type ,
                    p_ship_date          => x_ship_hdr_int_rec.ship_date        ,
                    p_organization_id    => x_ship_hdr_int_rec.organization_id  ,
                    p_organization_code  => x_ship_hdr_int_rec.organization_code,
                    p_location_id        => x_ship_hdr_int_rec.location_id      ,
                    p_location_code      => x_ship_hdr_int_rec.location_code    ,
                    p_rcv_enabled_flag   => x_ship_hdr_int_rec.rcv_enabled_flag ,
                    p_last_task_code     => x_ship_hdr_int_rec.last_task_code   ,
                    p_ship_type_id       => x_ship_hdr_int_rec.ship_type_id     ,
                    p_ship_type_code     => x_ship_hdr_int_rec.ship_type_code   ,
                    x_ship_num           => x_ship_hdr_int_rec.ship_num         ,
                    x_ship_header_id     => x_ship_hdr_int_rec.ship_header_id   ,
                    x_return_status      => l_return_status)
    ;

    -- If any errors happen abort API.
    IF l_return_status = L_FND_RET_STS_ERROR THEN
        RAISE L_FND_EXC_ERROR;
    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
    IF (l_response_int)
    THEN
        l_debug_info := 'True';
    ELSE
        l_debug_info := 'False';
        l_response := l_response_int;
    END IF;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'l_response_int',
        p_var_value      => l_debug_info);
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'x_ship_hdr_int_rec.ship_num',
        p_var_value      => x_ship_hdr_int_rec.ship_num);



    IF (l_response)
    THEN
        IF x_ship_hdr_int_rec.validation_flag NOT IN ('Y', 'N') THEN --FROM Validate_ValidationFlag
            l_response := FALSE;
            IF (l_response)
            THEN
                l_debug_info := 'True';
            ELSE
                l_debug_info := 'False';
            END IF;
            INL_LOGGING_PVT.Log_Variable(
                p_module_name    => g_module_name,
                p_procedure_name => l_program_name,
                p_var_name       => 'l_response',
                p_var_value      => l_debug_info);
            -- Add a line into inl_ship_errors
            Handle_InterfError(
                p_parent_table_name  => 'INL_SHIP_HEADERS_INT',
                p_parent_table_id    => x_ship_hdr_int_rec.ship_header_int_id,
                p_column_name        => 'VALIDATION_FLAG',
                p_column_value       => x_ship_hdr_int_rec.validation_flag,
                p_error_message_name => 'INL_ERR_VALIDATION_FLAG_INV',
                x_return_status      => l_return_status) ;
            -- If unexpected errors happen abort
            IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
        -- Shipment Number validation
        l_debug_info := 'Call Validate_ShipNum ';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_debug_info     => l_debug_info);

        l_response_int :=
            Validate_ShipNum(
                    p_ship_header_int_id            => x_ship_hdr_int_rec.ship_header_int_id,
                    p_organization_id               => x_ship_hdr_int_rec.organization_id,
                    p_validation_flag               => x_ship_hdr_int_rec.validation_flag,
                    p_transaction_type              => x_ship_hdr_int_rec.transaction_type,
                    p_user_defined_ship_num_code    => x_ship_hdr_int_rec.user_defined_ship_num_code,
                    p_LCM_FLOW                      => x_ship_hdr_int_rec.LCM_FLOW,
                    p_manual_ship_num_type          => x_ship_hdr_int_rec.manual_ship_num_type,
                    p_ship_num                      => x_ship_hdr_int_rec.ship_num,
                    x_return_status                 => l_return_status
        ) ;

        -- If any errors happen abort API.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
        IF (l_response_int)
        THEN
            l_debug_info := 'True';
        ELSE
            l_debug_info := 'False';
            l_response := l_response_int;
        END IF;
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'l_response_int',
            p_var_value      => l_debug_info);

        IF x_ship_hdr_int_rec.transaction_type = 'CREATE'
        THEN
            -- Shipment Type validation
            l_debug_info := 'Call Validate_ShipType';
            INL_LOGGING_PVT.Log_Statement(
                p_module_name      => g_module_name,
                p_procedure_name   => l_program_name,
                p_debug_info       => l_debug_info) ;

            l_response_int :=
                    Validate_ShipType(
                            p_ship_header_int_id => x_ship_hdr_int_rec.ship_header_int_id,
                            p_validation_flag    => x_ship_hdr_int_rec.validation_flag,
                            x_ship_type_id       => x_ship_hdr_int_rec.ship_type_id,
                            x_ship_type_code     => x_ship_hdr_int_rec.ship_type_code,
                            x_return_status      => l_return_status);
            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
            IF (l_response_int)
            THEN
                l_debug_info := 'True';
            ELSE
                l_debug_info := 'False';
                l_response := l_response_int;
            END IF;
            INL_LOGGING_PVT.Log_Variable(
                p_module_name    => g_module_name,
                p_procedure_name => l_program_name,
                p_var_name       => 'l_response_int',
                p_var_value      => l_debug_info);

            -- Location derivation and validation
            l_debug_info := 'Call Validate_Location';
            INL_LOGGING_PVT.Log_Statement(
                p_module_name      => g_module_name,
                p_procedure_name   => l_program_name,
                p_debug_info       => l_debug_info) ;

            l_response_int :=
                    Validate_Location(
                            p_ship_header_int_id => x_ship_hdr_int_rec.ship_header_int_id,
                            p_validation_flag    => x_ship_hdr_int_rec.validation_flag,
                            p_organization_id    => x_ship_hdr_int_rec.organization_id,
                            x_location_id        => x_ship_hdr_int_rec.location_id,
                            x_location_code      => x_ship_hdr_int_rec.location_code,
                            x_dflt_country       => x_ship_hdr_int_rec.dflt_country,
                            x_return_status      => l_return_status);

            -- If any errors happen abort API.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;
            IF (l_response_int)
            THEN
                l_debug_info := 'True';
            ELSE
                l_debug_info := 'False';
                l_response := l_response_int;
            END IF;
            INL_LOGGING_PVT.Log_Variable(
                p_module_name    => g_module_name,
                p_procedure_name => l_program_name,
                p_var_name       => 'l_response_int',
                p_var_value      => l_debug_info);

        END IF;
    END IF;

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);
    RETURN l_response;
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name);
        END IF;
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
END Validate_shipHdrInt;

-- Utility name : Validate_shipLinInt
-- Type       : Private
-- Function   : Validate the transaction type
--
-- Pre-reqs   : None
-- Parameters :
-- IN         :
--              p_transaction_type  IN VARCHAR2,
--              p_validation_flag   IN VARCHAR2,
--              p_dflt_country      IN VARCHAR2,
--              p_ship_type_id      IN NUMBER,
--              p_organization_id   IN NUMBER,
--              p_org_id            IN NUMBER,
--              p_ship_header_id    IN NUMBER,
--              p_interface_source_code IN VARCHAR2
--
-- IN OUT     : x_ship_ln_int_lst   IN OUT NOCOPY ship_ln_int_list_type,
--          .   x_return_status      IN OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Validate_ShipLinInt(
    p_transaction_type  IN VARCHAR2,
    p_validation_flag   IN VARCHAR2,
    p_dflt_country      IN VARCHAR2,
    p_ship_type_id      IN NUMBER,
    p_organization_id   IN NUMBER,
    p_org_id            IN NUMBER,
    p_ship_header_id    IN NUMBER,
    p_interface_source_code IN VARCHAR2,
    x_ship_ln_int_lst   IN OUT NOCOPY ship_ln_int_list_type,
    x_return_status     IN OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
    l_program_name     CONSTANT VARCHAR2(30) := 'Validate_ShipLinInt';
    l_return_status VARCHAR2(1) ;
    l_debug_info    VARCHAR2(400) ;
    l_response_int  BOOLEAN := TRUE;
    l_response      BOOLEAN := TRUE;

BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name) ;
    --  Initialize API return status to success
    x_return_status      := L_FND_RET_STS_SUCCESS;

    l_debug_info := 'Transaction Type validation: '||p_transaction_type;
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info);

   IF p_transaction_type = 'CREATE' THEN
       l_response_int :=
            validate_LnCreateTrxType(
                p_validation_flag => p_validation_flag,
                p_dflt_country    => p_dflt_country,
                p_ship_type_id    => p_ship_type_id,
                p_organization_id => p_organization_id,
                p_org_id          => p_org_id,
                p_interface_source_code => p_interface_source_code,
                x_ship_ln_int_lst => x_ship_ln_int_lst,
                x_return_status   => l_return_status
            );
        -- If any errors happen abort API.
    ELSIF p_transaction_type = 'UPDATE' THEN
        l_response_int :=
            validate_LnUpdateTrxType(
                p_validation_flag => p_validation_flag,
                p_ship_header_id  => p_ship_header_id,
                p_organization_id => p_organization_id,
                p_interface_source_code => p_interface_source_code,
                x_ship_ln_int_lst => x_ship_ln_int_lst,
                x_return_status   => l_return_status
            );
    END IF;
    -- If any errors happen abort API.
    IF l_return_status = L_FND_RET_STS_ERROR THEN
        RAISE L_FND_EXC_ERROR;
    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
    IF (l_response_int)
    THEN
        l_debug_info := 'True';
    ELSE
        l_debug_info := 'False';
        l_response := l_response_int;
    END IF;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'l_response_int',
        p_var_value      => l_debug_info);

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);
    RETURN l_response;
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name);
        END IF;
        RETURN FND_API.to_boolean(L_FND_FALSE) ;
END Validate_shipLinInt;

-- API name   : Import_LCMShipments
-- Type       : Public
-- Function   : Main Import procedure. It calls the Pre and Post
--              processors to validate and import a Shipment.
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version   IN NUMBER
--              p_init_msg_list IN VARCHAR2 := L_FND_FALSE
--              p_commit        IN VARCHAR2 := L_FND_FALSE
--              p_group_id      IN NUMBER
--              p_simulation_id IN NUMBER DEFAULT NULL
--
-- OUT        : x_return_status OUT NOCOPY VARCHAR2
-- OUT        : x_msg_count     OUT NOCOPY NUMBER
-- OUT        : x_msg_data      OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Import_LCMShipments(
    p_api_version   IN NUMBER,
    p_init_msg_list IN VARCHAR2 := L_FND_FALSE,
    p_commit        IN VARCHAR2 := L_FND_FALSE,
    p_group_id      IN NUMBER,
    p_simulation_id IN NUMBER DEFAULT NULL,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2
) IS

    l_ship_hdr_idx      NUMBER:=0;
    l_ship_ln_grp_idx   NUMBER;
    l_ship_ln_idx       NUMBER;

    l_program_name      CONSTANT VARCHAR2(30) := 'Import_LCMShipments2';
    l_api_version   CONSTANT NUMBER       := 1.0;
    l_return_status VARCHAR2(1);
    l_init_msg_list      VARCHAR2(2000) := L_FND_FALSE;
    l_commit             VARCHAR2(1)    := L_FND_FALSE;
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);
    l_debug_info    VARCHAR2(200);

    CURSOR c_ship_hdr_int_err
    IS
        SELECT
            ship_header_int_id
        FROM inl_ship_headers_int h
        WHERE request_id = l_fnd_conc_request_id_int
        AND processing_status_code = 'PENDING';

    TYPE ship_hdr_int_err_list_type
        IS
        TABLE OF c_ship_hdr_int_err%ROWTYPE INDEX BY BINARY_INTEGER;

    l_ship_hdr_int_err_list ship_hdr_int_err_list_type;

    l_commit_cycle  VARCHAR2(1);
    l_rec_num       NUMBER;
    l_ship_hdr_int_validation BOOLEAN;
    l_ship_ln_int_validation  BOOLEAN;

    l_ship_hdr_int_list ship_hdr_int_list_type;
    l_ship_ln_int_list   ship_ln_int_list_type;

    l_previous_access_mode  VARCHAR2(1) :=mo_global.get_access_mode();
    l_previous_org_id       NUMBER(15)  :=mo_global.get_current_org_id();
    l_current_org_id        NUMBER(15);
    l_varchardate           VARCHAR2(10) := TO_CHAR(SYSDATE,'DDDSSSS');

    -- Bug #16310024
    l_check_submit VARCHAR2(1);
    l_last_task_code VARCHAR2(25);
    l_organization_id NUMBER;
    l_rule_package_name VARCHAR2(100);
    -- Bug #16310024
BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name) ;
    -- Standard Start of API savepoint
    SAVEPOINT Import_LCMShipments_PVT;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(
            p_current_version_number => l_api_version,
            p_caller_version_number => p_api_version,
            p_api_name => l_program_name,
            p_pkg_name => g_pkg_name ) THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;

--Bug#11794483B
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => 'Verify if request ID is generic:'||l_fnd_conc_request_id);

    IF l_fnd_conc_request_id = -1 THEN
        l_fnd_conc_request_id_int := TO_NUMBER(l_varchardate||TO_CHAR(SYSDATE,'DDDSSSS'))*-1;
        INL_LOGGING_PVT.Log_Variable(
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'l_fnd_conc_request_id_int',
            p_var_value      => l_fnd_conc_request_id_int
        ) ;
    ELSE
        l_fnd_conc_request_id_int := l_fnd_conc_request_id*-1;
    END IF;
--Bug#11794483B

    l_current_org_id      := NVL(l_previous_org_id,-999);--Bug#10381495
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'l_current_org_id',
        p_var_value      => l_current_org_id
    ) ;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_group_id',
        p_var_value      => p_group_id
    ) ;
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_simulation_id',
        p_var_value      => p_simulation_id
    ) ;

-- <#Bug 8979947>
/*
    l_debug_info := 'Check profile INL_INTERFACE_IMPORT_COMMIT_CYCLE';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_program_name,
        p_debug_info => l_debug_info
    );

    IF FND_API.To_Boolean(p_commit) THEN
        l_commit_cycle := NVL(FND_PROFILE.VALUE('INL_SHIP_IMPORT_COMMIT_CYCLE'),'F');  -- dependence
    END IF;

*/

    IF FND_API.To_Boolean(p_commit) THEN
        l_commit_cycle := 'P';
    END IF;

-- <#Bug /8979947>

    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => 'Verify if exist any header record without line');

    G_RECORDS_PROCESSED:= Check_HeaderWithoutLine(
                                x_return_status => l_return_status
                            );

    -- If any errors happen abort API.
    IF l_return_status = L_FND_RET_STS_ERROR THEN
        RAISE L_FND_EXC_ERROR;
    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;

    LOOP
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => 'Getting header_interface records to process');

        l_rec_num:= select_LCMShipToProc(
            p_group_id      => p_group_id,
            p_simulation_id => p_simulation_id,
            x_return_status => l_return_status
        );
        -- If any errors happen abort API.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_rec_num||' records to process');

        OPEN c_ship_hdr_int;
        FETCH c_ship_hdr_int BULK COLLECT INTO l_ship_hdr_int_list;
        CLOSE c_ship_hdr_int;

        G_RECORDS_PROCESSED := G_RECORDS_PROCESSED + NVL(l_ship_hdr_int_list.COUNT, 0);

        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => NVL(l_ship_hdr_int_list.COUNT, 0)||' records have been found.');

        IF NVL(l_ship_hdr_int_list.COUNT, 0) > 0 THEN
            FOR l_ship_hdr_int_idx IN 1 .. l_ship_hdr_int_list.COUNT
            LOOP
                BEGIN
                    l_ship_hdr_int_validation := TRUE;
                    l_ship_ln_int_validation  := TRUE;
/*
                    IF l_commit_cycle = 'P'
                    THEN
*/
                        SAVEPOINT InlInterfacePvt_ILCMShip;
/*
                    END IF;
*/
                    INL_LOGGING_PVT.Log_Variable(
                        p_module_name    => g_module_name,
                        p_procedure_name => l_program_name,
                        p_var_name       => 'l_ship_hdr_int_list('||l_ship_hdr_int_idx||')ship_header_int_id',
                        p_var_value      => l_ship_hdr_int_list(l_ship_hdr_int_idx).ship_header_int_id) ;

                    INL_LOGGING_PVT.Log_Variable(
                        p_module_name    => g_module_name,
                        p_procedure_name => l_program_name,
                        p_var_name       => 'l_ship_hdr_int_list('||l_ship_hdr_int_idx||')group_id',
                        p_var_value      => l_ship_hdr_int_list(l_ship_hdr_int_idx).group_id) ;

                    INL_LOGGING_PVT.Log_Variable(
                        p_module_name    => g_module_name,
                        p_procedure_name => l_program_name,
                        p_var_name       => 'l_ship_hdr_int_list('||l_ship_hdr_int_idx||')transaction_type',
                        p_var_value      => l_ship_hdr_int_list(l_ship_hdr_int_idx).transaction_type) ;

                    INL_LOGGING_PVT.Log_Variable(
                        p_module_name    => g_module_name,
                        p_procedure_name => l_program_name,
                        p_var_name       => 'l_ship_hdr_int_list('||l_ship_hdr_int_idx||')interface_source_code',
                        p_var_value      => l_ship_hdr_int_list(l_ship_hdr_int_idx).interface_source_code) ;

                    INL_LOGGING_PVT.Log_Variable(
                        p_module_name    => g_module_name,
                        p_procedure_name => l_program_name,
                        p_var_name       => 'l_ship_hdr_int_list('||l_ship_hdr_int_idx||')interface_source_table',
                        p_var_value      => l_ship_hdr_int_list(l_ship_hdr_int_idx).interface_source_table) ;

                    INL_LOGGING_PVT.Log_Variable(
                        p_module_name    => g_module_name,
                        p_procedure_name => l_program_name,
                        p_var_name       => 'l_ship_hdr_int_list('||l_ship_hdr_int_idx||')interface_source_line_id',
                        p_var_value      => l_ship_hdr_int_list(l_ship_hdr_int_idx).interface_source_line_id) ;

                    INL_LOGGING_PVT.Log_Variable(
                        p_module_name    => g_module_name,
                        p_procedure_name => l_program_name,
                        p_var_name       => 'l_ship_hdr_int_list('||l_ship_hdr_int_idx||')validation_flag',
                        p_var_value      => l_ship_hdr_int_list(l_ship_hdr_int_idx).validation_flag) ;

                    INL_LOGGING_PVT.Log_Variable(
                        p_module_name    => g_module_name,
                        p_procedure_name => l_program_name,
                        p_var_name       => 'l_ship_hdr_int_list('||l_ship_hdr_int_idx||')ship_num',
                        p_var_value      => l_ship_hdr_int_list(l_ship_hdr_int_idx).ship_num) ;

                    INL_LOGGING_PVT.Log_Variable(
                        p_module_name    => g_module_name,
                        p_procedure_name => l_program_name,
                        p_var_name       => 'l_ship_hdr_int_list('||l_ship_hdr_int_idx||')ship_date',
                        p_var_value      => l_ship_hdr_int_list(l_ship_hdr_int_idx).ship_date) ;

                    INL_LOGGING_PVT.Log_Variable(
                        p_module_name    => g_module_name,
                        p_procedure_name => l_program_name,
                        p_var_name       => 'l_ship_hdr_int_list('||l_ship_hdr_int_idx||')ship_type_id',
                        p_var_value      => l_ship_hdr_int_list(l_ship_hdr_int_idx).ship_type_id) ;

                    INL_LOGGING_PVT.Log_Variable(
                        p_module_name    => g_module_name,
                        p_procedure_name => l_program_name,
                        p_var_name       => 'l_ship_hdr_int_list('||l_ship_hdr_int_idx||')legal_entity_id',
                        p_var_value      => l_ship_hdr_int_list(l_ship_hdr_int_idx).legal_entity_id) ;

                    INL_LOGGING_PVT.Log_Variable(
                        p_module_name    => g_module_name,
                        p_procedure_name => l_program_name,
                        p_var_name       => 'l_ship_hdr_int_list('||l_ship_hdr_int_idx||')organization_id',
                        p_var_value      => l_ship_hdr_int_list(l_ship_hdr_int_idx).organization_id) ;

                    INL_LOGGING_PVT.Log_Variable(
                        p_module_name    => g_module_name,
                        p_procedure_name => l_program_name,
                        p_var_name       => 'l_ship_hdr_int_list('||l_ship_hdr_int_idx||')location_id',
                        p_var_value      => l_ship_hdr_int_list(l_ship_hdr_int_idx).location_id) ;

                    INL_LOGGING_PVT.Log_Variable(
                        p_module_name    => g_module_name,
                        p_procedure_name => l_program_name,
                        p_var_name       => 'l_ship_hdr_int_list('||l_ship_hdr_int_idx||')org_id',
                        p_var_value      => l_ship_hdr_int_list(l_ship_hdr_int_idx).org_id) ;

                    INL_LOGGING_PVT.Log_Variable(
                        p_module_name    => g_module_name,
                        p_procedure_name => l_program_name,
                        p_var_name       => 'l_ship_hdr_int_list('||l_ship_hdr_int_idx||')last_task_code',
                        p_var_value      => l_ship_hdr_int_list(l_ship_hdr_int_idx).last_task_code) ;

                    INL_LOGGING_PVT.Log_Variable(
                        p_module_name    => g_module_name,
                        p_procedure_name => l_program_name,
                        p_var_name       => 'l_ship_hdr_int_list('||l_ship_hdr_int_idx||')rcv_enabled_flag',
                        p_var_value      => l_ship_hdr_int_list(l_ship_hdr_int_idx).rcv_enabled_flag) ;

                    Reset_InterfError(
                        p_parent_table_name => 'INL_SHIP_HEADERS_INT',
                        p_parent_table_id => l_ship_hdr_int_list(l_ship_hdr_int_idx).ship_header_int_id,
                        x_return_status => l_return_status
                    );
                    -- If any errors happen abort API.
                    IF l_return_status = L_FND_RET_STS_ERROR THEN
                        RAISE L_FND_EXC_ERROR;
                    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                        RAISE L_FND_EXC_UNEXPECTED_ERROR;
                    END IF;

                    l_debug_info := 'Validate Ship Header Int';
                    INL_LOGGING_PVT.Log_Statement(
                        p_module_name      => g_module_name,
                        p_procedure_name   => l_program_name,
                        p_debug_info       => l_debug_info);

                    l_ship_hdr_int_validation :=
                        Validate_shipHdrInt(
                            x_ship_hdr_int_rec   => l_ship_hdr_int_list(l_ship_hdr_int_idx),
                            x_return_status      => l_return_status);

                    -- If any errors happen abort API.
                    IF l_return_status = L_FND_RET_STS_ERROR THEN
                        RAISE L_FND_EXC_ERROR;
                    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                        RAISE L_FND_EXC_UNEXPECTED_ERROR;
                    END IF;

                    OPEN c_ship_ln_int(l_ship_hdr_int_list(l_ship_hdr_int_idx).ship_header_int_id);
                    FETCH c_ship_ln_int BULK COLLECT INTO l_ship_ln_int_list;
                    CLOSE c_ship_ln_int;

                    INL_LOGGING_PVT.Log_Statement(
                        p_module_name      => g_module_name,
                        p_procedure_name   => l_program_name,
                        p_debug_info       => NVL(l_ship_ln_int_list.COUNT, 0)||' lines have been found.');

                    IF NVL(l_ship_ln_int_list.COUNT, 0) > 0 THEN
                        l_ship_ln_int_validation :=
                            Validate_shipLinInt(
                                p_transaction_type   => l_ship_hdr_int_list(l_ship_hdr_int_idx).transaction_type,
                                p_validation_flag    => l_ship_hdr_int_list(l_ship_hdr_int_idx).validation_flag,
                                p_dflt_country       => l_ship_hdr_int_list(l_ship_hdr_int_idx).dflt_country,
                                p_ship_type_id       => l_ship_hdr_int_list(l_ship_hdr_int_idx).ship_type_id,
                                p_organization_id    => l_ship_hdr_int_list(l_ship_hdr_int_idx).organization_id,
                                p_org_id             => l_ship_hdr_int_list(l_ship_hdr_int_idx).org_id,
                                p_ship_header_id     => l_ship_hdr_int_list(l_ship_hdr_int_idx).ship_header_id,
                                p_interface_source_code => l_ship_hdr_int_list(l_ship_hdr_int_idx).interface_source_code,
                                x_ship_ln_int_lst    => l_ship_ln_int_list,
                                x_return_status      => l_return_status);
                        -- If any errors happen abort API.
                        IF l_return_status = L_FND_RET_STS_ERROR THEN
                            RAISE L_FND_EXC_ERROR;
                        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                            RAISE L_FND_EXC_UNEXPECTED_ERROR;
                        END IF;
                    END IF;

                    IF l_ship_ln_int_validation
                        AND l_ship_hdr_int_validation
                    THEN
                        IF l_ship_hdr_int_list(l_ship_hdr_int_idx).last_task_code >= '10' THEN -- check if import should be executed

                            l_debug_info := 'Import Shipment Headers. Call Import_Headers';
                            INL_LOGGING_PVT.Log_Statement(
                                p_module_name      => g_module_name,
                                p_procedure_name   => l_program_name,
                                p_debug_info       => l_debug_info);

                            Import_Headers(
                                p_simulation_id    => p_simulation_id,
                                x_ship_hdr_int_rec => l_ship_hdr_int_list(l_ship_hdr_int_idx),
                                x_return_status    => l_return_status);

                            -- If any errors happen abort API.
                            IF l_return_status = L_FND_RET_STS_ERROR THEN
                                RAISE L_FND_EXC_ERROR;
                            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                                RAISE L_FND_EXC_UNEXPECTED_ERROR;
                            END IF;

                            IF l_ship_hdr_int_list(l_ship_hdr_int_idx).transaction_type = 'CREATE'
                                OR l_ship_hdr_int_list(l_ship_hdr_int_idx).transaction_type = 'UPDATE'
                            THEN
                                l_debug_info := 'Import Shipment Lines. Call Import_Lines for ship_header_id: ' || l_ship_hdr_int_list(l_ship_hdr_int_idx).ship_header_int_id;
                                INL_LOGGING_PVT.Log_Statement(
                                        p_module_name => g_module_name,
                                        p_procedure_name => l_program_name,
                                        p_debug_info => l_debug_info);

                                Import_Lines(
                                    p_transaction_type  => l_ship_hdr_int_list(l_ship_hdr_int_idx).transaction_type,
                                    p_ship_header_int_id=> l_ship_hdr_int_list(l_ship_hdr_int_idx).ship_header_int_id,
                                    p_ship_header_id    => l_ship_hdr_int_list(l_ship_hdr_int_idx).ship_header_id,
                                    x_ship_ln_int_lst   => l_ship_ln_int_list,
                                    x_return_status     => l_return_status
                                );

                                -- If any errors happen abort API.
                                IF l_return_status = L_FND_RET_STS_ERROR THEN
                                    RAISE L_FND_EXC_ERROR;
                                ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                                    RAISE L_FND_EXC_UNEXPECTED_ERROR;
                                END IF;
                            END IF;

                            INL_LOGGING_PVT.Log_Statement(
                                p_module_name => g_module_name,
                                p_procedure_name => l_program_name,
                                p_debug_info => 'Comparing l_current_org_id: '||l_current_org_id||' with l_ship_hdr_int_list(l_ship_hdr_int_idx).org_id:'||l_ship_hdr_int_list(l_ship_hdr_int_idx).org_id
                            );
                            --Bug#10381495
                            IF (l_current_org_id <> l_ship_hdr_int_list(l_ship_hdr_int_idx).org_id) THEN
                                INL_LOGGING_PVT.Log_Statement(
                                    p_module_name => g_module_name,
                                    p_procedure_name => l_program_name,
                                    p_debug_info => 'Seting a new context from '||l_current_org_id||' to '||l_ship_hdr_int_list(l_ship_hdr_int_idx).org_id
                                );
                                mo_global.set_policy_context( 'S', l_ship_hdr_int_list(l_ship_hdr_int_idx).org_id);
                                l_current_org_id := l_ship_hdr_int_list(l_ship_hdr_int_idx).org_id;
                                INL_LOGGING_PVT.Log_Statement(
                                    p_module_name => g_module_name,
                                    p_procedure_name => l_program_name,
                                    p_debug_info => 'l_current_org_id: '||l_current_org_id
                                );
                            END IF;
                            --Bug#10381495

                            -- Bug #16310024
                            IF l_organization_id IS NULL OR
                               l_organization_id <> l_ship_hdr_int_list(l_ship_hdr_int_idx).organization_id THEN

                                l_organization_id := l_ship_hdr_int_list(l_ship_hdr_int_idx).organization_id;
                                l_rule_package_name := NULL;

                                INL_LOGGING_PVT.Log_Statement(
                                    p_module_name => g_module_name,
                                    p_procedure_name => l_program_name,
                                    p_debug_info => 'Get Rule package name for organization: ' || l_organization_id);

                                    SELECT r.package_name
                                    INTO l_rule_package_name
                                    FROM inl_rules_vl r,
                                        inl_parameters p
                                    WHERE r.rule_id (+) = p.rule_id
                                    AND r.enabled_flag (+) = 'Y'
                                    AND p.organization_id = l_organization_id;

                                INL_LOGGING_PVT.Log_Variable(
                                    p_module_name => g_module_name,
                                    p_procedure_name => g_module_name,
                                    p_var_name => 'l_rule_package_name',
                                    p_var_value => l_rule_package_name);

                            END IF;

                            l_last_task_code := l_ship_hdr_int_list(l_ship_hdr_int_idx).last_task_code;

                            IF l_ship_hdr_int_list(l_ship_hdr_int_idx).interface_source_code = 'RCV' AND
                               l_ship_hdr_int_list(l_ship_hdr_int_idx).last_task_code = '60' AND
                               (l_rule_package_name IS NOT NULL)THEN

                                l_debug_info := 'Call INL_RULE_GRP.Check_Condition.';
                                INL_LOGGING_PVT.Log_Statement(
                                        p_module_name => g_module_name,
                                        p_procedure_name => l_program_name,
                                        p_debug_info => l_debug_info);

                                l_check_submit := INL_RULE_GRP.Check_Condition(
                                                      p_api_version => 1.0,
                                                      p_init_msg_list => L_FND_FALSE,
                                                      p_commit =>  L_FND_FALSE,
                                                      p_ship_header_id => l_ship_hdr_int_list(l_ship_hdr_int_idx).ship_header_id,
                                                      p_rule_package_name => l_rule_package_name,
                                                      x_return_status => l_return_status,
                                                      x_msg_count => l_msg_count,
                                                      x_msg_data => l_msg_data);

                                -- If any errors happen abort API.
                                IF l_return_status = L_FND_RET_STS_ERROR THEN
                                    RAISE L_FND_EXC_ERROR;
                                ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                                    RAISE L_FND_EXC_UNEXPECTED_ERROR;
                                END IF;

                                INL_LOGGING_PVT.Log_Statement(
                                    p_module_name => g_module_name,
                                    p_procedure_name => l_program_name,
                                    p_debug_info => 'l_check_submit: '||l_check_submit);

                                IF l_check_submit = 'N'  THEN
                                    l_last_task_code := '50';
                                END IF;
                            END IF;
                            -- Bug #16310024


                            l_debug_info := 'Run the process action for each imported Shipment.';
                            INL_LOGGING_PVT.Log_Statement(
                                    p_module_name => g_module_name,
                                    p_procedure_name => l_program_name,
                                    p_debug_info => l_debug_info);

                            Run_ProcessAction(
                                p_ship_header_id => l_ship_hdr_int_list(l_ship_hdr_int_idx).ship_header_id,
                                p_last_task_code =>  l_last_task_code, -- l_ship_hdr_int_list(l_ship_hdr_int_idx).last_task_code, -- Bug #16310024
                                x_return_status  => l_return_status
                            );

                            -- If any errors happen abort API.
                            IF l_return_status = L_FND_RET_STS_ERROR THEN
                                RAISE L_FND_EXC_ERROR;
                            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                                RAISE L_FND_EXC_UNEXPECTED_ERROR;
                            END IF;
                            -- Set the number of LCM Shipments imported successfully.
                            -- This value will be latter stamped in the concurrent log
                            g_records_inserted := g_records_inserted + 1;

                            -- Bug #16310024
                            IF l_last_task_code = 60 THEN
                                g_records_completed := g_records_completed + 1;
                            END IF;
                            -- Bug #16310024

                        END IF;
                        l_debug_info := 'Change Interface Status Code to COMPLETED';
                        INL_LOGGING_PVT.Log_Statement(
                            p_module_name      => g_module_name,
                            p_procedure_name   => l_program_name,
                            p_debug_info       => l_debug_info);

                        UPDATE inl_ship_headers_int
                        SET processing_status_code = 'COMPLETED'           ,
                            request_id             = L_FND_CONC_REQUEST_ID ,
                            last_updated_by        = L_FND_USER_ID         ,
                            last_update_date       = SYSDATE               ,
                            last_update_login      = L_FND_LOGIN_ID        ,
                            program_id             = L_FND_CONC_PROGRAM_ID ,
                            program_update_date    = SYSDATE               ,
                            program_application_id = L_FND_PROG_APPL_ID    ,
                            ship_header_id         = l_ship_hdr_int_list(l_ship_hdr_int_idx).ship_header_id
                          WHERE ship_header_int_id = l_ship_hdr_int_list(l_ship_hdr_int_idx).ship_header_int_id;
                    ELSE
                        Handle_InterfError(
                            p_parent_table_name  => 'INL_SHIP_HEADERS_INT',
                            p_parent_table_id    => l_ship_hdr_int_list(l_ship_hdr_int_idx).ship_header_int_id,
                            p_column_name        => 'ship_header_int_id('||l_ship_hdr_int_idx||')',
                            p_column_value       => l_ship_hdr_int_list(l_ship_hdr_int_idx).ship_header_int_id,
                            p_error_message_name => 'INL_FAILED_ON_CONC_SUB',
                            p_token1_name        => 'CONC',
                            p_token1_value       => 'Validation failed',
                            x_return_status      => l_return_status);
                        -- If any errors happen abort API.
                        IF l_return_status = L_FND_RET_STS_ERROR THEN
                            RAISE L_FND_EXC_ERROR;
                        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                            RAISE L_FND_EXC_UNEXPECTED_ERROR;
                        END IF;

                    END IF;
                    IF l_commit_cycle = 'P' THEN
                        l_debug_info := 'Commit cycle is partial. Commiting every imported Shipment';
                        INL_LOGGING_PVT.Log_Statement(
                            p_module_name => g_module_name,
                            p_procedure_name => l_program_name,
                            p_debug_info => l_debug_info);
                        COMMIT WORK;
                    END IF;
                --Bug#10436018
                EXCEPTION
                    WHEN OTHERS THEN
--                        IF L_commit_cycle = 'P' THEN
                            ROLLBACK TO InlInterfacePvt_ILCMShip;
                            Handle_InterfError(
                                p_parent_table_name  => 'INL_SHIP_HEADERS_INT',
                                p_parent_table_id    => l_ship_hdr_int_list(l_ship_hdr_int_idx).ship_header_int_id,
                                p_column_name        => 'ship_header_int_id('||l_ship_hdr_int_idx||')',
                                p_column_value       => l_ship_hdr_int_list(l_ship_hdr_int_idx).ship_header_int_id,
                                p_error_message_name => 'INL_FAILED_ON_CONC_SUB',
                                p_token1_name        => 'CONC',
                                p_token1_value       => 'Import_Headers exception',
                                x_return_status      => l_return_status);
                            -- If unexpected errors happen abort
                            IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
                                RAISE L_FND_EXC_UNEXPECTED_ERROR;
                            END IF;
                        IF L_commit_cycle = 'P' THEN
                              COMMIT WORK;
--                        ELSE
--                            RAISE L_FND_EXC_UNEXPECTED_ERROR;
                        END IF;
                END;
                --Bug#10436018
            END LOOP;
        ELSE
            EXIT;
        END IF;
    END LOOP;

    --Bug#10381495
    IF (l_current_org_id <> NVL(l_previous_org_id,-999)) THEN
        INL_LOGGING_PVT.Log_Statement(
            p_module_name => g_module_name,
            p_procedure_name => l_program_name,
            p_debug_info => 'Restore previous context: from '||l_current_org_id||' to '||l_previous_org_id
        );
        mo_global.set_policy_context( l_previous_access_mode, l_previous_org_id);
        l_current_org_id:= l_previous_org_id; --Bug#16198838/14707257
    END IF;
    --Bug#10381495

    IF NVL(G_RECORDS_PROCESSED,0) = 0 THEN
        -- Add a line into inl_ship_errors, No records found for processing
        -- -- Bug 13920858: Commented the code to avoid Error Messages getting Inserted into INL_INTERFACE_ERRORS table.
        l_debug_info := 'Error Mesage: No records found for processing.';
            INL_LOGGING_PVT.Log_Statement(
                p_module_name      => g_module_name,
                p_procedure_name   => l_program_name,
                p_debug_info       => l_debug_info
            ) ;
/*
        Handle_InterfError(
            p_parent_table_name  => 'INL_SHIP_HEADERS_INT',
            p_parent_table_id    => 0,
            p_column_name        => 'P_GROUP_ID',
            p_column_value       => p_group_id,
            p_error_message_name => 'INL_NO_RECORDS_FOUND_ERR',
            x_return_status      => l_return_status);
        -- If unexpected errors happen abort
        IF l_return_status <> L_FND_RET_STS_SUCCESS THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
*/

    END IF;

    l_debug_info := 'Checking if any record remain from the selected records.';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    ) ;

    OPEN c_ship_hdr_int_err;
    FETCH c_ship_hdr_int_err BULK COLLECT INTO l_ship_hdr_int_err_list;
    CLOSE c_ship_hdr_int_err;

    IF NVL(l_ship_hdr_int_err_list.COUNT, 0) > 0 THEN
        l_debug_info := l_ship_hdr_int_err_list.COUNT||' records remain from the previous selected records('||l_fnd_conc_request_id_int||').';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info);

        FOR l_ship_hdr_int_idx IN 1 .. l_ship_hdr_int_err_list.COUNT
        LOOP
            Handle_InterfError(
                p_parent_table_name  => 'INL_SHIP_HEADERS_INT',
                p_parent_table_id    => l_ship_hdr_int_err_list(l_ship_hdr_int_idx).ship_header_int_id,
                p_column_name        => 'l_ship_hdr_int_err_list('||l_ship_hdr_int_idx||')',
                p_column_value       => l_ship_hdr_int_err_list(l_ship_hdr_int_idx).ship_header_int_id,
                p_error_message_name => 'INL_FAILED_ON_CONC_SUB',
                p_token1_name        => 'CONC',
                p_token1_value       => 'Import_Headers problem',
                x_return_status      => l_return_status);

        END LOOP;

    END IF;

    -- Bug #8264427
    -- Interface records that got completed successfully are removed
    -- from INL_SHIP_HEADERS_INT and INL_SHIP_LINES_INT
    Purge_LCMShipInt(
        p_api_version   => 1.0,
        p_init_msg_list => l_init_msg_list,
        p_commit        => l_commit,
        p_group_id      => p_group_id,
        x_return_status => l_return_status,
        x_msg_count     => l_msg_count,
        x_msg_data      => l_msg_data
    );

    -- If any errors happen abort API.
    IF l_return_status = L_FND_RET_STS_ERROR THEN
        RAISE L_FND_EXC_ERROR;
    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => L_FND_FALSE,
        p_count => x_msg_count,
        p_data => x_msg_data) ;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);

EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        ROLLBACK TO Import_LCMShipments_PVT;
        x_return_status := L_FND_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => L_FND_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);
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
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        ROLLBACK TO Import_LCMShipments_PVT;
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded  => L_FND_FALSE,
            p_count    => x_msg_count,
            p_data     => x_msg_data);
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
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        ROLLBACK TO Import_LCMShipments_PVT;
        x_return_status := L_FND_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => L_FND_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);
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
END Import_LCMShipments;

-- SCM-051
-- Utility name : Reset_MatchInt
-- Type       : Private
-- Function   : Reset Matches Interface records that got rejected because of
--              the existence of Pending Update shipments.
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_header_id IN NUMBER
--
-- OUT          x_return_status OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Reset_MatchInt (p_ship_header_id IN NUMBER,
                          x_return_status OUT NOCOPY VARCHAR2
) IS
    l_program_name CONSTANT VARCHAR2(30):= 'Reset_MatchInt';
    l_return_status VARCHAR2(1);
    l_debug_info VARCHAR2(200);
    l_count_elc_pend_shipment NUMBER;

    CURSOR c_matches_int_error IS
    SELECT DISTINCT m.group_id
    FROM inl_matches_int m,
        rcv_transactions rt,
        inl_ship_lines_all sl
    WHERE sl.ship_line_id = rt.lcm_shipment_line_id
    AND rt.transaction_id = m.to_parent_table_id
    AND m.to_parent_table_name = 'RCV_TRANSACTIONS'
    AND m.processing_status_code = 'ERROR'
    AND sl.ship_header_id = p_ship_header_id;

    TYPE matches_int_error IS TABLE OF c_matches_int_error%ROWTYPE;
    l_matches_int_error matches_int_error;

BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(p_module_name => g_module_name,
                                  p_procedure_name => l_program_name);

    INL_LOGGING_PVT.Log_Variable(p_module_name => g_module_name,
                                 p_procedure_name => l_program_name,
                                 p_var_name => 'p_ship_header_id',
                                 p_var_value => p_ship_header_id);

    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;

    l_debug_info := 'Open cursor c_matches_int_error';
    INL_LOGGING_PVT.Log_Statement(p_module_name => g_module_name,
                                  p_procedure_name => l_program_name,
                                  p_debug_info => l_debug_info);

    -- Fetch Match records with error for shipment
    OPEN c_matches_int_error;
    FETCH c_matches_int_error BULK COLLECT INTO l_matches_int_error;
    CLOSE c_matches_int_error;

    IF NVL (l_matches_int_error.LAST, 0) > 0 THEN -- exists record with status = ERROR
        FOR i IN NVL(l_matches_int_error.FIRST, 0)..NVL(l_matches_int_error.LAST, 0)
        LOOP
            INL_LOGGING_PVT.Log_Variable(p_module_name => g_module_name,
                                 p_procedure_name => l_program_name,
                                 p_var_name => 'group_id',
                                 p_var_value => l_matches_int_error(i).group_id);
            SELECT COUNT(1)
            INTO l_count_elc_pend_shipment
            FROM inl_matches_int m,
                 rcv_transactions rt,
                 inl_ship_lines_all sl,
                 inl_ship_headers_all sh
            WHERE sh.ship_header_id = sl.ship_header_id
            AND sl.ship_line_id = rt.lcm_shipment_line_id
            AND rt.transaction_id = m.to_parent_table_id
            AND m.group_id = l_matches_int_error(i).group_id
            AND m.to_parent_table_name = 'RCV_TRANSACTIONS'
            AND sh.pending_update_flag = 'Y';

            INL_LOGGING_PVT.Log_Variable(p_module_name => g_module_name,
                                 p_procedure_name => l_program_name,
                                 p_var_name => 'l_count_elc_pend_shipment',
                                 p_var_value => l_count_elc_pend_shipment);

            IF NVL(l_count_elc_pend_shipment,0) = 0 THEN
                l_debug_info := 'Update inl_matches_int to PENDING for group ID: ' || l_matches_int_error(i).group_id;
                INL_LOGGING_PVT.Log_Statement(p_module_name => g_module_name,
                                              p_procedure_name => l_program_name,
                                              p_debug_info => l_debug_info);

                UPDATE inl_matches_int mi
                SET processing_status_code = 'PENDING',
                    mi.last_updated_by = L_FND_USER_ID,
                    mi.last_update_date = SYSDATE,
                    mi.last_update_login = L_FND_LOGIN_ID
                WHERE group_id = l_matches_int_error(i).group_id;
             END IF;
        END LOOP;
    END IF;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        x_return_status := L_FND_RET_STS_ERROR;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_program_name);
        END IF;
END Reset_MatchInt;
-- /SCM-051

END INL_INTERFACE_PVT;

/
