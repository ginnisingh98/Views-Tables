--------------------------------------------------------
--  DDL for Package Body INL_INTEGRATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INL_INTEGRATION_GRP" AS
/* $Header: INLGITGB.pls 120.0.12010000.78 2014/01/02 14:22:58 anandpra noship $ */

--Bug#9109573
g_currency_code   VARCHAR2(15);
g_return_mask     VARCHAR2(100);
g_field_length    NUMBER;
g_precision       NUMBER;   /* number of digits to right of decimal*/
g_ext_precision   NUMBER;   /* precision where more precision is needed*/
g_min_acct_unit   NUMBER;   /* minimum value by which amt can vary */
--Bug#9109573

-- API name   : Insert_LCMInterface
-- Type       : Group
-- Function   : Insert data on LTI tables
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version   IN NUMBER,
--              p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE
--              p_commit        IN VARCHAR2 := FND_API.G_FALSE
--              p_lci_table     IN OUT NOCOPY  lci_table
--
-- OUT          x_return_status OUT NOCOPY VARCHAR2
--              x_msg_count     OUT NOCOPY NUMBER
--              x_msg_data      OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Insert_LCMInterface (
    p_api_version    IN NUMBER,
    p_init_msg_list  IN VARCHAR2 := FND_API.G_FALSE,
    p_commit         IN VARCHAR2 := FND_API.G_FALSE,
    p_lci_table      IN OUT NOCOPY  lci_table,
    x_return_status  OUT NOCOPY VARCHAR2,
    x_msg_count      OUT NOCOPY NUMBER,
    x_msg_data       OUT NOCOPY VARCHAR2
)IS


    l_api_name       CONSTANT VARCHAR2(30) := 'Insert_LCMInterface';
    l_api_version    CONSTANT NUMBER := 1.0;

    l_return_status  VARCHAR2(1);
    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(2000);
    l_debug_info     VARCHAR2(200);

    l_ship_header_int_id           NUMBER;
    l_current_shipment_header_id   NUMBER;
    l_group_id                     NUMBER;
    l_ship_line_int_id             NUMBER;
    l_current_organization_id      NUMBER;
    l_current_location_id          NUMBER;

BEGIN

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name);

    -- Standard Start of API savepoint
    SAVEPOINT Insert_LCMInterface_GRP;

    -- Initialize message list IF p_init_msg_list is SET to TRUE.
    IF FND_API.to_Boolean (p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Check FOR call compatibility.
    IF NOT FND_API.Compatible_API_Call (
        p_current_version_number => l_api_version,
        p_caller_version_number => p_api_version,
        p_api_name => l_api_name,
        p_pkg_name => g_pkg_name
    ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize API RETURN status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- API Body
    BEGIN
        l_current_shipment_header_id := -9999;
        l_current_organization_id := -9999;
        l_current_location_id := -9999;
        FOR i IN 1..p_lci_table.COUNT LOOP

            INL_LOGGING_PVT.Log_Variable (
                p_module_name => g_module_name,
                p_procedure_name => l_api_name,
                p_var_name => 'p_lci_table('||i||').shipment_header_id',
                p_var_value => p_lci_table(i).shipment_header_id);
            INL_LOGGING_PVT.Log_Variable (
                p_module_name => g_module_name,
                p_procedure_name => l_api_name,
                p_var_name => 'p_lci_table('||i||').header_interface_id',
                p_var_value => p_lci_table(i).header_interface_id);

            IF NVL(p_lci_table(i).shipment_header_id,p_lci_table(i).header_interface_id) = -9999 THEN --Bug#9737425
                INL_LOGGING_PVT.Log_Statement (
                    p_module_name => g_module_name,
                    p_procedure_name => l_api_name,
                    p_debug_info => 'Record ignored' );
            ELSE    --Bug#8971617

                INL_LOGGING_PVT.Log_Variable (
                    p_module_name => g_module_name,
                    p_procedure_name => l_api_name,
                    p_var_name => 'l_current_location_id',
                    p_var_value => l_current_location_id);

                INL_LOGGING_PVT.Log_Variable (
                    p_module_name => g_module_name,
                    p_procedure_name => l_api_name,
                    p_var_name => 'p_lci_table(i).location_id',
                    p_var_value => p_lci_table(i).location_id);

                -- Bug #9194035
                --IF (l_current_shipment_header_id <> p_lci_table(i).hdr_interface_source_line_id) THEN
                IF ((l_current_organization_id <> p_lci_table(i).organization_id OR
                    l_current_location_id <> p_lci_table(i).location_id)OR
                    l_current_shipment_header_id <> p_lci_table(i).hdr_interface_source_line_id) THEN   -- Bug #9232742

                    SELECT INL_SHIP_HEADERS_INT_S.nextval, INL_INTERFACE_GROUPS_S.nextval
                    INTO l_ship_header_int_id, l_group_id
                    FROM dual;

                    p_lci_table(i).group_id := l_group_id; -- Bug#9279355

                    INL_LOGGING_PVT.Log_Variable (
                        p_module_name => g_module_name,
                        p_procedure_name => l_api_name,
                        p_var_name => 'l_ship_header_int_id',
                        p_var_value => l_ship_header_int_id);

                    INL_LOGGING_PVT.Log_Variable (
                        p_module_name => g_module_name,
                        p_procedure_name => l_api_name,
                        p_var_name => 'l_group_id',
                        p_var_value => l_group_id);

                    INL_LOGGING_PVT.Log_Statement (
                        p_module_name => g_module_name,
                        p_procedure_name => l_api_name,
                        p_debug_info => 'Inserting into inl_ship_headers_int' );

                    INSERT INTO inl_ship_headers_int(
                        ship_header_int_id,                                   /* 01 */
                        group_id,                                             /* 02 */
                        transaction_type,                                     /* 03 */
                        processing_status_code,                               /* 04 */
                        interface_source_code,                                /* 05 */
                        interface_source_table,                               /* 06 */
                        interface_source_line_id,                             /* 07 */
                        validation_flag,                                      /* 08 */
                        rcv_enabled_flag,                                     /* 09 */
                        ship_num,                                             /* 10 */
                        ship_date,                                            /* 11 */
                        ship_type_id,                                         /* 12 */
                        ship_type_code,                                       /* 13 */
                        organization_id,                                      /* 14 */
                        organization_code,                                    /* 15 */
                        location_id,                                          /* 16 */
                        location_code,                                        /* 17 */
                        taxation_country,                                     /* 18 */
                        document_sub_type,                                    /* 19 */
                        ship_header_id,                                       /* 20 */
                        last_task_code,                                       /* 21 */
                        created_by,                                           /* 22 */
                        creation_date,                                        /* 23 */
                        last_updated_by,                                      /* 24 */
                        last_update_date,                                     /* 25 */
                        last_update_login,                                    /* 26 */
                        request_id,                                           /* 27 */
                        program_id,                                           /* 28 */
                        program_application_id,                               /* 29 */
                        program_update_date                                   /* 30 */
                    )
                    VALUES(
                        l_ship_header_int_id,                                 /* 01 */
                        l_group_id,                                           /* 02 */
                        p_lci_table(i).transaction_type,                      /* 03 */
                        p_lci_table(i).processing_status_code,                /* 04 */
                        p_lci_table(i).interface_source_code,                 /* 05 */
                        p_lci_table(i).hdr_interface_source_table,            /* 06 */
                        p_lci_table(i).hdr_interface_source_line_id,          /* 07 */
                        p_lci_table(i).validation_flag,                       /* 08 */
                        p_lci_table(i).rcv_enabled_flag,                      /* 09 */--Bug#9279355
                        p_lci_table(i).ship_num,                              /* 10 */--Bug#8971617
                        p_lci_table(i).ship_date,                             /* 11 */
                        p_lci_table(i).ship_type_id,                          /* 12 */
                        p_lci_table(i).ship_type_code,                        /* 13 */
                        p_lci_table(i).organization_id,                       /* 14 */
                        p_lci_table(i).organization_code,                     /* 15 */
                        p_lci_table(i).location_id,                           /* 16 */
                        p_lci_table(i).location_code,                         /* 17 */
                        p_lci_table(i).taxation_country,                      /* 18 */
                        p_lci_table(i).document_sub_type,                     /* 19 */
                        p_lci_table(i).ship_header_id,                        /* 20 */
                        p_lci_table(i).last_task_code,                        /* 21 */
                        fnd_global.user_id,                                   /* 22 */
                        SYSDATE,                                              /* 23 */
                        fnd_global.user_id,                                   /* 24 */
                        SYSDATE,                                              /* 25 */
                        fnd_global.login_id,                                  /* 26 */
                        fnd_global.conc_request_id,                           /* 27 */
                        fnd_global.conc_program_id,                           /* 28 */
                        fnd_global.prog_appl_id,                              /* 29 */
                        decode(fnd_global.conc_request_id, -1, NULL, SYSDATE) /* 30 */
                    );

                    l_current_shipment_header_id := p_lci_table(i).hdr_interface_source_line_id; -- Bug #9232742
                    l_current_organization_id:= p_lci_table(i).organization_id;
                    l_current_location_id := p_lci_table(i).location_id;
                END IF;

                SELECT INL_SHIP_LINES_INT_S.nextval
                INTO l_ship_line_int_id
                FROM dual;

                INL_LOGGING_PVT.Log_Variable (
                    p_module_name => g_module_name,
                    p_procedure_name => l_api_name,
                    p_var_name => 'l_ship_line_int_id',
                    p_var_value => l_ship_line_int_id);

                INSERT INTO inl_ship_lines_int (
                    ship_header_int_id,                                     /* 01 */
                    ship_line_int_id,                                       /* 02 */
                    processing_status_code,                                 /* 03 */
                    ship_line_group_reference,                              /* 04 */
                    party_id,                                               /* 05 */
                    party_number,                                           /* 06 */
                    party_site_id,                                          /* 07 */
                    party_site_number,                                      /* 08 */
                    source_organization_id,                                 /* 09 */
                    source_organization_code,                               /* 10 */
                    ship_line_num,                                          /* 11 */
                    ship_line_type_id,                                      /* 12 */
                    ship_line_type_code,                                    /* 13 */
                    ship_line_src_type_code,                                /* 14 */
                    ship_line_source_id,                                    /* 15 */
                    currency_code,                                          /* 16 */
                    currency_conversion_type,                               /* 17 */
                    currency_conversion_date,                               /* 18 */
                    currency_conversion_rate,                               /* 19 */
                    inventory_item_id,                                      /* 20 */
                    txn_qty,                                                /* 21 */
                    txn_uom_code,                                           /* 22 */
                    txn_unit_price,                                         /* 23 */
                    primary_qty,                                            /* 24 */
                    primary_uom_code,                                       /* 25 */
                    primary_unit_price,                                     /* 26 */
                    secondary_qty,                                          /* 27 */
                    secondary_uom_code,                                     /* 28 */
                    secondary_unit_price,                                   /* 29 */
                    landed_cost_flag,                                       /* 30 */
                    allocation_enabled_flag,                                /* 31 */
                    trx_business_category,                                  /* 32 */
                    intended_use,                                           /* 33 */
                    product_fiscal_class,                                   /* 34 */
                    product_category,                                       /* 35 */
                    product_type,                                           /* 36 */
                    user_def_fiscal_class,                                  /* 37 */
                    tax_classification_code,                                /* 38 */
                    assessable_value,                                       /* 39 */
                    ship_from_party_id,                                     /* 40 */
                    ship_from_party_number,                                 /* 41 */
                    ship_from_party_site_id,                                /* 42 */
                    ship_from_party_site_number,                            /* 43 */
                    ship_to_organization_id,                                /* 44 */
                    ship_to_organization_code,                              /* 45 */
                    ship_to_location_id,                                    /* 46 */
                    ship_to_location_code,                                  /* 47 */
                    bill_from_party_id,                                     /* 48 */
                    bill_from_party_number,                                 /* 49 */
                    bill_from_party_site_id,                                /* 50 */
                    bill_from_party_site_number,                            /* 51 */
                    bill_to_organization_id,                                /* 52 */
                    bill_to_organization_code,                              /* 53 */
                    bill_to_location_id,                                    /* 54 */
                    bill_to_location_code,                                  /* 55 */
                    poa_party_id,                                           /* 56 */
                    poa_party_number,                                       /* 57 */
                    poa_party_site_id,                                      /* 58 */
                    poa_party_site_number,                                  /* 59 */
                    poo_organization_id,                                    /* 60 */
                    poo_to_organization_code,                               /* 61 */
                    poo_location_id,                                        /* 62 */
                    poo_location_code,                                      /* 63 */
                    ship_header_id,                                         /* 64 */
                    ship_line_id,                                           /* 65 */
                    interface_source_table,                                 /* 66 */
                    interface_source_line_id,                               /* 67 */
                    created_by,                                             /* 68 */
                    creation_date,                                          /* 69 */
                    last_updated_by,                                        /* 70 */
                    last_update_date,                                       /* 71 */
                    last_update_login,                                      /* 72 */
                    request_id,                                             /* 73 */
                    program_id,                                             /* 74 */
                    program_application_id,                                 /* 75 */
                    program_update_date)                                    /* 76 */
                VALUES(
                    l_ship_header_int_id,                                   /* 01 */
                    l_ship_line_int_id,                                     /* 02 */
                    p_lci_table(i).processing_status_code,                  /* 03 */
                    p_lci_table(i).ship_line_group_reference,               /* 04 */
                    p_lci_table(i).party_id,                                /* 05 */
                    p_lci_table(i).party_number,                            /* 06 */
                    p_lci_table(i).party_site_id,                           /* 07 */
                    p_lci_table(i).party_site_number,                       /* 08 */
                    p_lci_table(i).source_organization_id,                  /* 09 */
                    p_lci_table(i).source_organization_code,                /* 10 */
                    p_lci_table(i).ship_line_num,                           /* 11 */
                    p_lci_table(i).ship_line_type_id,                       /* 12 */
                    p_lci_table(i).ship_line_type_code,                     /* 13 */
                    p_lci_table(i).ship_line_src_type_code,                 /* 14 */
                    p_lci_table(i).ship_line_source_id,                     /* 15 */
                    p_lci_table(i).currency_code,                           /* 16 */
                    p_lci_table(i).currency_conversion_type,                /* 17 */
                    p_lci_table(i).currency_conversion_date,                /* 18 */
                    p_lci_table(i).currency_conversion_rate,                /* 19 */
                    p_lci_table(i).inventory_item_id,                       /* 20 */
                    p_lci_table(i).txn_qty,                                 /* 21 */
                    p_lci_table(i).txn_uom_code,                            /* 22 */
                    p_lci_table(i).txn_unit_price,                          /* 23 */
                    p_lci_table(i).primary_qty,                             /* 24 */
                    p_lci_table(i).primary_uom_code,                        /* 25 */
                    p_lci_table(i).primary_unit_price,                      /* 26 */
                    p_lci_table(i).secondary_qty,                           /* 27 */
                    p_lci_table(i).secondary_uom_code,                      /* 28 */
                    p_lci_table(i).secondary_unit_price,                    /* 29 */
                    p_lci_table(i).landed_cost_flag,                        /* 30 */
                    p_lci_table(i).allocation_enabled_flag,                 /* 31 */
                    p_lci_table(i).trx_business_category,                   /* 32 */
                    p_lci_table(i).intended_use,                            /* 33 */
                    p_lci_table(i).product_fiscal_class,                    /* 34 */
                    p_lci_table(i).product_category,                        /* 35 */
                    p_lci_table(i).product_type,                            /* 36 */
                    p_lci_table(i).user_def_fiscal_class,                   /* 37 */
                    p_lci_table(i).tax_classification_code,                 /* 38 */
                    p_lci_table(i).assessable_value,                        /* 39 */
                    p_lci_table(i).ship_from_party_id,                      /* 40 */
                    p_lci_table(i).ship_from_party_number,                  /* 41 */
                    p_lci_table(i).ship_from_party_site_id,                 /* 42 */
                    p_lci_table(i).ship_from_party_site_number,             /* 43 */
                    p_lci_table(i).ship_to_organization_id,                 /* 44 */
                    p_lci_table(i).ship_to_organization_code,               /* 45 */
                    p_lci_table(i).ship_to_location_id,                     /* 46 */
                    p_lci_table(i).ship_to_location_code,                   /* 47 */
                    p_lci_table(i).bill_from_party_id,                      /* 48 */
                    p_lci_table(i).bill_from_party_number,                  /* 49 */
                    p_lci_table(i).bill_from_party_site_id,                 /* 50 */
                    p_lci_table(i).bill_from_party_site_number,             /* 51 */
                    p_lci_table(i).bill_to_organization_id,                 /* 52 */
                    p_lci_table(i).bill_to_organization_code,               /* 53 */
                    p_lci_table(i).bill_to_location_id,                     /* 54 */
                    p_lci_table(i).bill_to_location_code,                   /* 55 */
                    p_lci_table(i).poa_party_id,                            /* 56 */
                    p_lci_table(i).poa_party_number,                        /* 57 */
                    p_lci_table(i).poa_party_site_id,                       /* 58 */
                    p_lci_table(i).poa_party_site_number,                   /* 59 */
                    p_lci_table(i).poo_organization_id,                     /* 60 */
                    p_lci_table(i).poo_to_organization_code,                /* 61 */
                    p_lci_table(i).poo_location_id,                         /* 62 */
                    p_lci_table(i).poo_location_code,                       /* 63 */
                    p_lci_table(i).ship_header_id,                          /* 64 */
                    p_lci_table(i).ship_line_id,                            /* 65 */
                    p_lci_table(i).line_interface_source_table,             /* 66 */
                    p_lci_table(i).line_interface_source_line_id,           /* 67 */
                    fnd_global.user_id,                                     /* 68 */
                    SYSDATE,                                                /* 69 */
                    fnd_global.user_id,                                     /* 70 */
                    SYSDATE,                                                /* 71 */
                    fnd_global.login_id,                                    /* 72 */
                    fnd_global.conc_request_id,                             /* 73 */
                    fnd_global.conc_program_id,                             /* 74 */
                    fnd_global.prog_appl_id,                                /* 75 */
                    decode(fnd_global.conc_request_id, -1, NULL, SYSDATE)   /* 76 */
                );
            END IF;
        END LOOP;
    END; -- End of API Body

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.g_false,
        p_count => x_msg_count,
        p_data => x_msg_data);

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name);
        ROLLBACK TO Insert_LCMInterface_GRP;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.g_false,
            p_count => x_msg_count,
            p_data => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name);
        ROLLBACK TO Insert_LCMInterface_GRP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.g_false,
            p_count =>  x_msg_count,
            p_data =>  x_msg_data);
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name);
        ROLLBACK TO Insert_LCMInterface_GRP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
          FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.g_false,
            p_count => x_msg_count,
            p_data => x_msg_data);
END Insert_LCMInterface;

-- API name   : Import_FromRCV
-- Type       : Group
-- Function   : Creates LTI entries based on Receiving
--              transactions inserted through the Black Box flow.
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_int_rec       IN RCV_CALL_LCM_WS.rti_rec
--
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Import_FromRCV (p_int_rec        IN RCV_CALL_LCM_WS.rti_rec,
                          x_return_status  OUT NOCOPY VARCHAR2,
                          x_msg_count      OUT NOCOPY NUMBER,
                          x_msg_data       OUT NOCOPY VARCHAR2) IS

    l_return_status                VARCHAR2(1);
    l_msg_count                    NUMBER;
    l_msg_data                     VARCHAR2(2000);
    l_proc_name                    CONSTANT VARCHAR2(30) := 'Import_FromRCV';
    l_api_version                  CONSTANT NUMBER := 1.0;
    l_debug_msg                    VARCHAR2(500);
    l_user_defined_ship_num_code   VARCHAR2(25);
    l_ship_num                     NUMBER;
    l_ship_type_id                 NUMBER;
    l_legal_entity_id              NUMBER;
    l_taxation_country             VARCHAR2(2);
    l_ship_header_int_id           NUMBER;
    l_group_id                     NUMBER;
    l_party_id                     NUMBER;
    l_party_site_id                NUMBER;
    l_ship_line_type_id            NUMBER;
    l_trx_business_category        VARCHAR2(240);
    l_line_intended_use            VARCHAR2(240);
    l_product_fisc_classification  VARCHAR2(240);
    l_product_category             VARCHAR2(240);
    l_product_type                 VARCHAR2(240);
    l_user_defined_fisc_class      VARCHAR2(30);
    l_output_tax_classf_code       VARCHAR2(50);
    l_ship_lines_int_id            NUMBER;
    l_org_id                       NUMBER;
    l_vendor_id                    NUMBER;
    l_vendor_site_id               NUMBER;
    l_curr_vendor_site_id          NUMBER:= -9999;    --Bug#8820297
    l_ship_to_org_id               NUMBER;
    l_ship_to_location_id          NUMBER;
    l_receipt_num                  VARCHAR2(500);
    erroredHeaderId                NUMBER := -9999;
    currentHeaderId                NUMBER := -9999;
    l_ship_to_org_name             VARCHAR2(240);
    l_ship_to_location_code        VARCHAR2(240);
    l_source_document_code         VARCHAR2(25);
    l_ship_line_src_id             NUMBER;
    l_txn_unit_price               NUMBER;
    l_src_organization_id          NUMBER;
    l_dflt_currency_code           VARCHAR2(10);
    l_customer_id                  NUMBER;
    l_lci_table                    lci_table;
    l_records_processed            NUMBER := 0;
    l_records_inserted             NUMBER := 0;
    l_sec_uom_code                 VARCHAR2(25);
    l_sec_unit_price               NUMBER;

    l_begin_of_this_header         NUMBER := 1;     --Bug#8971617
    l_ind_lci                      NUMBER := 1;     --Bug#8971617
    l_po_UOM_code                  VARCHAR2(25);    --Bug#9884458

    --Bug#10381495
    l_previous_access_mode  VARCHAR2(1) :=mo_global.get_access_mode();
    l_previous_org_id       NUMBER(15)  :=mo_global.get_current_org_id();
    l_current_org_id        NUMBER(15);
    --Bug#10381495

BEGIN

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name    => g_module_name,
        p_procedure_name => l_proc_name);

    -- Initialize message list IF p_init_msg_list is SET to TRUE.
--    IF FND_API.to_Boolean (p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
--    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name,
        p_var_name => 'p_int_rec.COUNT',
        p_var_value => p_int_rec.COUNT);

--Bug#10381495
    l_current_org_id := NVL(l_previous_org_id,-999);
    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_proc_name,
        p_var_name       => 'l_current_org_id',
        p_var_value      => l_current_org_id
    ) ;
--Bug#10381495


    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name,
        p_debug_info => 'Get value from profile INL_SHIP_TYPE_ID_OI' );

    l_ship_type_id := NVL(FND_PROFILE.VALUE('INL_SHIP_TYPE_ID_OI'),0);

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name,
        p_var_name => 'l_ship_type_id',
        p_var_value => l_ship_type_id );

    -- Bug #8271747
    -- In order to import data from RCV to LCM OI tables,
    -- the INL:Default Shipment Type profile must be setup.
    IF l_ship_type_id IS NULL OR l_ship_type_id = 0 THEN
        FND_MESSAGE.SET_NAME ('INL', 'INL_ERR_CHK_SHIP_TYP_PROF') ;
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Set the number of records to be processed
    -- This value will be latter stamped in the concurrent log
    l_records_processed := p_int_rec.COUNT;

    FOR i IN 1..p_int_rec.COUNT LOOP
        IF (erroredHeaderId <> Nvl(p_int_rec(i).shipment_header_id, p_int_rec(i).header_interface_id)) THEN
            BEGIN
                IF (currentHeaderId <> Nvl(p_int_rec(i).shipment_header_id, p_int_rec(i).header_interface_id)
                    OR l_curr_vendor_site_id <> p_int_rec(i).vendor_site_id    --Bug#8820297
                )
                THEN
                    -- IF an error occurs in one of the lines, all lines of the current header
                    -- should be removed from memory table

--Bug#10381495
                    IF (p_int_rec(i).org_id <> l_current_org_id) THEN
                        INL_LOGGING_PVT.Log_Statement(
                            p_module_name => g_module_name,
                            p_procedure_name => l_proc_name,
                            p_debug_info => 'Seting a new context from '||l_current_org_id||' to '||p_int_rec(i).org_id
                        );
                        l_current_org_id:=p_int_rec(i).org_id;
                        mo_global.set_policy_context( 'S', l_current_org_id);
                        INL_LOGGING_PVT.Log_Statement(
                            p_module_name => g_module_name,
                            p_procedure_name => l_proc_name,
                            p_debug_info => 'l_current_org_id: '||l_current_org_id
                        );
                    END IF;
--Bug#10381495

                    l_begin_of_this_header := l_ind_lci;

                    l_source_document_code := p_int_rec(i).source_document_code;
                    IF l_source_document_code = 'REQ' THEN
                        l_source_document_code := 'IR';
                    END IF;

                    INL_LOGGING_PVT.Log_Variable (
                        p_module_name => g_module_name,
                        p_procedure_name => l_proc_name,
                        p_var_name => 'p_int_rec(i).shipment_header_id',
                        p_var_value => p_int_rec(i).shipment_header_id);

                    INL_LOGGING_PVT.Log_Variable (
                        p_module_name => g_module_name,
                        p_procedure_name => l_proc_name,
                        p_var_name => 'p_int_rec(i).header_interface_id',
                        p_var_value => p_int_rec(i).header_interface_id);

                    INL_LOGGING_PVT.Log_Statement (
                        p_module_name => g_module_name,
                        p_procedure_name => l_proc_name,
                        p_debug_info => 'Get RCV_SHIPMENT_HEADERS info.');

                    IF p_int_rec(i).shipment_header_id IS NOT NULL THEN

                        SELECT
                            ship_to_org_id,
                            ship_to_location_id,
                            receipt_num,
                            vendor_id,
                            nvl(vendor_site_id,p_int_rec(i).vendor_site_id), --Bug#8820297
                            customer_id
                        INTO
                            l_ship_to_org_id,
                            l_ship_to_location_id,
                            l_receipt_num,
                            l_vendor_id,
                            l_vendor_site_id,
                            l_customer_id
                        FROM
                            rcv_shipment_headers
                        WHERE
                            shipment_header_id = p_int_rec(i).shipment_header_id;

                        -- BUG #8235596

                        INL_LOGGING_PVT.Log_Variable (
                            p_module_name => g_module_name,
                            p_procedure_name => l_proc_name,
                            p_var_name => 'l_ship_to_org_id',
                            p_var_value => l_ship_to_org_id );

                        INL_LOGGING_PVT.Log_Variable (
                            p_module_name => g_module_name,
                            p_procedure_name => l_proc_name,
                            p_var_name => 'l_ship_to_location_id',
                            p_var_value => l_ship_to_location_id );

                        INL_LOGGING_PVT.Log_Variable (
                            p_module_name => g_module_name,
                            p_procedure_name => l_proc_name,
                            p_var_name => 'l_receipt_num',
                            p_var_value => l_receipt_num );

                        INL_LOGGING_PVT.Log_Variable (
                            p_module_name => g_module_name,
                            p_procedure_name => l_proc_name,
                            p_var_name => 'l_vendor_id',
                            p_var_value => l_vendor_id );

                        INL_LOGGING_PVT.Log_Variable (
                            p_module_name => g_module_name,
                            p_procedure_name => l_proc_name,
                            p_var_name => 'l_vendor_site_id',
                            p_var_value => l_vendor_site_id );

                        INL_LOGGING_PVT.Log_Variable (
                            p_module_name => g_module_name,
                            p_procedure_name => l_proc_name,
                            p_var_name => 'l_customer_id',
                            p_var_value => l_customer_id );

                        IF(l_receipt_num IS NULL AND p_int_rec(i).header_interface_id IS NOT NULL) THEN

                            -- If receipt num is NULL get it from rcv_headers_interface
                            l_debug_msg := 'Receipt num is NULL get it from rcv_headers_interface';
                            INL_LOGGING_PVT.Log_Statement (
                                p_module_name => g_module_name,
                                p_procedure_name => l_proc_name,
                                p_debug_info => l_debug_msg);

                            SELECT receipt_num
                            INTO l_receipt_num
                            FROM rcv_headers_interface rhi
                            WHERE header_interface_id = p_int_rec(i).header_interface_id;

                            INL_LOGGING_PVT.Log_Variable (
                                p_module_name => g_module_name,
                                p_procedure_name => l_proc_name,
                                p_var_name => 'l_receipt_num',
                                p_var_value => l_receipt_num );

                        END IF;

                    ELSIF p_int_rec(i).header_interface_id IS NOT NULL THEN

                        SELECT
                            SHIP_TO_ORGANIZATION_ID,
                            location_id,
                            receipt_num,
                            vendor_id,
                            nvl(vendor_site_id,p_int_rec(i).vendor_site_id), --Bug#8820297
                            customer_id
                        INTO
                            l_ship_to_org_id,
                            l_ship_to_location_id,
                            l_receipt_num,
                            l_vendor_id,
                            l_vendor_site_id,
                            l_customer_id
                        FROM rcv_headers_interface
                        WHERE header_interface_id = p_int_rec(i).header_interface_id;
                    END IF;

                    l_curr_vendor_site_id := l_vendor_site_id; --Bug#8820297

                    INL_LOGGING_PVT.Log_Variable (
                        p_module_name => g_module_name,
                        p_procedure_name => l_proc_name,
                        p_var_name => 'l_ship_to_org_id',
                        p_var_value => l_ship_to_org_id);

                    INL_LOGGING_PVT.Log_Variable (
                        p_module_name => g_module_name,
                        p_procedure_name => l_proc_name,
                        p_var_name => 'l_ship_to_location_id',
                        p_var_value => l_ship_to_location_id );

                    INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                        p_procedure_name => l_proc_name,
                        p_var_name => 'l_receipt_num',
                        p_var_value => l_receipt_num);

                    INL_LOGGING_PVT.Log_Variable (
                        p_module_name => g_module_name,
                        p_procedure_name => l_proc_name,
                        p_var_name => 'l_vendor_id',
                        p_var_value => l_vendor_id);

                    INL_LOGGING_PVT.Log_Variable (
                        p_module_name => g_module_name,
                        p_procedure_name => l_proc_name,
                        p_var_name => 'l_vendor_site_id',
                        p_var_value => l_vendor_site_id);

                    INL_LOGGING_PVT.Log_Variable (
                        p_module_name => g_module_name,
                        p_procedure_name => l_proc_name,
                        p_var_name => 'l_customer_id',
                        p_var_value => l_customer_id);

                    INL_LOGGING_PVT.Log_Statement (
                        p_module_name => g_module_name,
                        p_procedure_name => l_proc_name,
                        p_debug_info => 'Get Operating Unit Id');
                    SELECT operating_unit, organization_name
                    INTO l_org_id, l_ship_to_org_name
                    FROM org_organization_definitions
                    WHERE organization_id = l_ship_to_org_id;

                    INL_LOGGING_PVT.Log_Variable (
                        p_module_name => g_module_name,
                        p_procedure_name => l_proc_name,
                        p_var_name => 'l_org_id',
                        p_var_value => l_org_id);

                    INL_LOGGING_PVT.Log_Statement (
                        p_module_name => g_module_name,
                        p_procedure_name => l_proc_name,
                        p_debug_info => 'Check if the Ship To Organization has been setup in LCM Options');

                    BEGIN
                        SELECT nvl(user_defined_ship_num_code,'AUTOMATIC')        --Bug#8971617
                          INTO l_user_defined_ship_num_code
                          FROM inl_parameters ipa
                         WHERE ipa.organization_id = l_ship_to_org_id;
                    EXCEPTION
                    -- Bug #8418356
                    -- Check whether the current organization has
                    -- been defined in LCM Parameters.
                    WHEN OTHERS THEN
                        INL_LOGGING_PVT.Log_Statement (
                            p_module_name => g_module_name,
                            p_procedure_name => l_proc_name,
                            p_debug_info => 'Ship To Organization has not been setup in LCM Options');

                        FND_MESSAGE.SET_NAME ('INL', 'INL_ERR_NO_LCM_OPT_DEF_ORG') ;
                        FND_MESSAGE.SET_TOKEN ('INV_ORG_NAME', l_ship_to_org_name) ;
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    END;

                    IF l_user_defined_ship_num_code = 'AUTOMATIC' THEN  --Bug#8971617
                      l_ship_num := NULL;
                    ELSIF l_user_defined_ship_num_code = 'MANUAL' THEN  --Bug#8971617
                      l_ship_num := l_receipt_num;
                    END IF;

                    IF l_source_document_code = 'PO' THEN
                        INL_LOGGING_PVT.Log_Statement (
                            p_module_name => g_module_name,
                            p_procedure_name => l_proc_name,
                            p_debug_info => 'Get Party Id from PO_VENDORS');

                        SELECT party_id
                        INTO l_party_id
                        FROM po_vendors
                        WHERE vendor_id = l_vendor_id;
                    ELSIF l_source_document_code = 'RMA' THEN
                        INL_LOGGING_PVT.Log_Statement (
                            p_module_name => g_module_name,
                            p_procedure_name => l_proc_name,
                            p_debug_info => 'Get Party Id from hz_customer_party_find_v');

                        SELECT party_id
                        INTO l_party_id
                        FROM hz_customer_party_find_v
                        WHERE customer_id = l_customer_id;
                    END IF;

                    INL_LOGGING_PVT.Log_Variable (
                        p_module_name => g_module_name,
                        p_procedure_name => l_proc_name,
                        p_var_name => 'l_party_id',
                        p_var_value => l_party_id);

                    INL_LOGGING_PVT.Log_Statement (
                        p_module_name => g_module_name,
                        p_procedure_name => l_proc_name,
                        p_debug_info => 'Get Taxation Country');

                    -- Bug #8690464
                    -- Taxation country must be derived from
                    -- Location as well as in prereceiving flow
                    -- Bug #9194035. Location Id should come from PLL
                    l_lci_table(l_ind_lci).location_id := p_int_rec(i).ship_to_location_id;

                    IF l_lci_table(l_ind_lci).location_id IS NOT NULL THEN
                        SELECT hl.location_code, hl.country
                        INTO l_ship_to_location_code,
                             l_taxation_country
                        FROM hr_locations hl
                        WHERE hl.location_id = l_lci_table(l_ind_lci).location_id
                        AND hl.receiving_site_flag = 'Y';
                    END IF;

                    /*
                    SELECT hl.location_code, hl.country
                      INTO l_ship_to_location_code,
                           l_taxation_country
                      FROM hr_organization_units hou,
                           hr_locations hl
                     WHERE hl.location_id = hou.location_id
                       AND hl.receiving_site_flag = 'Y'
                       AND hou.organization_id = l_ship_to_org_id;
                    */
                    INL_LOGGING_PVT.Log_Variable (
                        p_module_name => g_module_name,
                        p_procedure_name => l_proc_name,
                        p_var_name => 'l_ship_to_location_code',
                        p_var_value => l_ship_to_location_code);

                    INL_LOGGING_PVT.Log_Variable (
                        p_module_name => g_module_name,
                        p_procedure_name => l_proc_name,
                        p_var_name => 'l_taxation_country',
                        p_var_value => l_taxation_country);

                    -- Taxation country cannot be null, otherwise there
                    -- is no way to validate Third Party Sites Allowed
                    IF l_taxation_country IS NULL THEN
                      FND_MESSAGE.SET_NAME ('INL', 'INL_ERR_LOC_COUNTRY_NULL') ;
                      FND_MESSAGE.SET_TOKEN ('LOCATION_CODE', l_ship_to_location_code) ;
                      FND_MSG_PUB.ADD;
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;

                    INL_LOGGING_PVT.Log_Statement (
                        p_module_name => g_module_name,
                        p_procedure_name => l_proc_name,
                        p_debug_info => 'Get Legal Entity and functional Currency Code');

                   --Bug #8271811, #11651775
                   SELECT hou.default_legal_context_id legal_entity,
                          gl.currency_code
                     INTO l_legal_entity_id,
                          l_dflt_currency_code
                     FROM hr_operating_units hou,
                          gl_sets_of_books gl
                    WHERE gl.set_of_books_id = hou.set_of_books_id
                      AND hou.organization_id = l_org_id;

                    INL_LOGGING_PVT.Log_Variable (
                        p_module_name => g_module_name,
                        p_procedure_name => l_proc_name,
                        p_var_name => 'l_legal_entity_id',
                        p_var_value => l_legal_entity_id);
                    INL_LOGGING_PVT.Log_Variable (
                        p_module_name => g_module_name,
                        p_procedure_name => l_proc_name,
                        p_var_name => 'l_ship_header_int_id',
                        p_var_value => l_ship_header_int_id);
                    INL_LOGGING_PVT.Log_Variable (
                        p_module_name => g_module_name,
                        p_procedure_name => l_proc_name,
                        p_var_name => 'l_group_id',
                        p_var_value => l_group_id);
                    INL_LOGGING_PVT.Log_Statement (
                        p_module_name => g_module_name,
                        p_procedure_name => l_proc_name,
                        p_debug_info => 'Insert into inl_ship_headers_int table');

                END IF;
                l_lci_table(l_ind_lci).shipment_header_id := p_int_rec(i).shipment_header_id;   --Bug#8971617
                l_lci_table(l_ind_lci).header_interface_id := p_int_rec(i).header_interface_id;
                l_lci_table(l_ind_lci).transaction_type := 'CREATE';
                l_lci_table(l_ind_lci).processing_status_code := 'PENDING';
                l_lci_table(l_ind_lci).interface_source_code := 'RCV';
                l_lci_table(l_ind_lci).ship_num                 := l_ship_num;  --Bug#8971617
                IF p_int_rec(i).shipment_header_id IS NOT NULL THEN
                    l_lci_table(l_ind_lci).hdr_interface_source_table := 'RCV_SHIPMENT_HEADERS';
                ELSIF p_int_rec(i).header_interface_id IS NOT NULL THEN
                    l_lci_table(l_ind_lci).hdr_interface_source_table := 'RCV_HEADERS_INTERFACE';
                END IF;

                l_lci_table(l_ind_lci).hdr_interface_source_line_id := NVL(p_int_rec(i).shipment_header_id,p_int_rec(i).header_interface_id);
                l_lci_table(l_ind_lci).validation_flag := 'N';
                l_lci_table(l_ind_lci).receipt_num := l_receipt_num;
                l_lci_table(l_ind_lci).ship_date := SYSDATE;
                l_lci_table(l_ind_lci).ship_type_id := l_ship_type_id;

                l_lci_table(l_ind_lci).organization_id := l_ship_to_org_id;
                -- Bug #9194035. Location come from PLL
                --l_lci_table(l_ind_lci).location_id := l_ship_to_location_id;
                l_lci_table(l_ind_lci).taxation_country := l_taxation_country;
                l_lci_table(l_ind_lci).last_task_code := 60;

                IF l_source_document_code = 'PO' THEN
                    INL_LOGGING_PVT.Log_Variable (
                        p_module_name => g_module_name,
                        p_procedure_name => l_proc_name,
                        p_var_name => 'l_vendor_site_id',
                        p_var_value => l_vendor_site_id );
                    SELECT pvs.party_site_id
                    INTO l_party_site_id
                    FROM po_vendor_sites_all pvs
                    WHERE  pvs.vendor_site_id = l_vendor_site_id
                    AND pvs.org_id = p_int_rec(i).org_id;
                END IF;

                INL_LOGGING_PVT.Log_Variable (
                    p_module_name => g_module_name,
                    p_procedure_name => l_proc_name,
                    p_var_name => 'l_party_site_id',
                    p_var_value => l_party_site_id );

                INL_LOGGING_PVT.Log_Statement (
                    p_module_name => g_module_name,
                    p_procedure_name => l_proc_name,
                    p_debug_info => 'Get value to INL_SHIP_LINE_TYPE_ID');

                SELECT ship_line_type_id
                INTO l_ship_line_type_id
                FROM inl_alwd_line_types
                WHERE parent_table_name = 'INL_SHIP_TYPES'
                AND parent_table_id = l_ship_type_id
                AND dflt_ship_line_type_flag='Y';

                INL_LOGGING_PVT.Log_Variable (
                    p_module_name => g_module_name,
                    p_procedure_name => l_proc_name,
                    p_var_name => 'l_ship_line_type_id',
                    p_var_value => l_ship_line_type_id);

                INL_LOGGING_PVT.Log_Variable (
                    p_module_name => g_module_name,
                    p_procedure_name => l_proc_name,
                    p_var_name => 'l_source_document_code',
                    p_var_value => l_source_document_code);

                IF l_source_document_code = 'PO' THEN
                    INL_LOGGING_PVT.Log_Statement (
                        p_module_name => g_module_name,
                        p_procedure_name => l_proc_name,
                        p_debug_info => 'Get values from zx_lines_det_factors and po_line_locations_all');


                    SELECT zdf.trx_business_category,
                           zdf.line_intended_use,
                           zdf.product_fisc_classification,
                           zdf.product_category,
                           zdf.product_type,
                           zdf.user_defined_fisc_class,
                           zdf.output_tax_classification_code,
                           muom.uom_code                    --Bug#9884458
                    INTO l_trx_business_category,
                         l_line_intended_use,
                         l_product_fisc_classification,
                         l_product_category,
                         l_product_type,
                         l_user_defined_fisc_class,
                         l_output_tax_classf_code,
                         l_po_UOM_code                      --Bug#9884458
                    FROM zx_lines_det_factors zdf,
                          po_line_locations_all pll,
                          po_lines_all pl,                  --Bug#9884458
                          mtl_units_of_measure muom         --Bug#9884458
                    WHERE pll.line_location_id = p_int_rec(i).po_line_location_id
                    AND pll.po_line_id = pl.po_line_id      --Bug#9884458
                    AND muom.unit_of_measure = pl.unit_meas_lookup_code  --Bug#9884458
                    AND zdf.application_id = 201
                    AND zdf.trx_id = NVL(pll.po_release_id,pll.po_header_id)                            --Bug 7680733
                    AND zdf.trx_line_id = pll.line_location_id
                    AND zdf.entity_code = DECODE(pll.po_release_id,NULL,'PURCHASE_ORDER','RELEASE')     --Bug 7680733
                    AND zdf.event_class_code = DECODE(pll.po_release_id,NULL,'PO_PA','RELEASE');        --Bug 7680733
/*--Bug#9884458
                END IF;

                IF l_source_document_code = 'PO' THEN
*/

                    l_ship_line_src_id := p_int_rec(i).po_line_location_id;

--Bug#9884458
                    IF l_po_UOM_code = p_int_rec(i).uom_code THEN
                        l_txn_unit_price := p_int_rec(i).po_unit_price;
                    ELSE
                        l_txn_unit_price := INL_LANDEDCOST_PVT.Converted_Price(
                                                p_unit_price        => p_int_rec(i).po_unit_price,
                                                p_organization_id   => l_lci_table(l_ind_lci).organization_id,
                                                p_inventory_item_id => p_int_rec(i).item_id,
                                                p_from_uom_code     => l_po_UOM_code,
                                                p_to_uom_code       => p_int_rec(i).uom_code
                                            );

                    END IF;
--Bug#9884458
                ELSIF l_source_document_code = 'IR' THEN

                    INL_LOGGING_PVT.Log_Variable (
                        p_module_name => g_module_name,
                        p_procedure_name => l_proc_name,
                        p_var_name => 'p_int_rec(i).requisition_line_id',
                        p_var_value => p_int_rec(i).requisition_line_id);

                    INL_LOGGING_PVT.Log_Statement (
                        p_module_name => g_module_name,
                        p_procedure_name => l_proc_name,
                        p_debug_info => 'Get value to shipment_line_id');

                    SELECT rsl.shipment_line_id
                    INTO l_ship_line_src_id
                    FROM rcv_shipment_lines rsl
                    WHERE requisition_line_id = p_int_rec(i).requisition_line_id;

                    l_src_organization_id := p_int_rec(i).from_organization_id;

                    INL_LOGGING_PVT.Log_Statement (
                        p_module_name => g_module_name,
                        p_procedure_name => l_proc_name,
                        p_debug_info => 'Get value to unit price');

                    SELECT  unit_price
                    INTO    l_txn_unit_price
                    FROM    po_requisition_lines_all prl
                    WHERE   prl.requisition_line_id = p_int_rec(i).requisition_line_id;
                ELSIF l_source_document_code = 'RMA' THEN
                    l_ship_line_src_id := p_int_rec(i).oe_order_line_id;

                    SELECT unit_selling_price
                    INTO l_txn_unit_price
                    FROM oe_order_lines_all
                    WHERE line_id = p_int_rec(i).oe_order_line_id;
                ELSE
                    l_ship_line_src_id := 0;
                    l_txn_unit_price := 0;
                END IF;

                -- Bug 8932386
                l_sec_unit_price := NULL;

                -- If secondary quantity is null, the uom code should be null
                IF p_int_rec(i).secondary_quantity IS NULL THEN
                    l_sec_uom_code := NULL;
                ELSE
                    l_sec_uom_code := p_int_rec(i).secondary_uom_code;
                    IF l_sec_uom_code IS NULL AND
                       p_int_rec(i).secondary_unit_of_measure IS NOT NULL THEN

                       INL_LOGGING_PVT.Log_Statement (
                            p_module_name => g_module_name,
                            p_procedure_name => l_proc_name,
                            p_debug_info => 'Get secondary_uom_code from secondary_unit_of_measure');

                        SELECT mum.uom_code
                        INTO l_sec_uom_code
                        FROM  mtl_units_of_measure mum
                        WHERE mum.unit_of_measure = p_int_rec(i).secondary_unit_of_measure;
                    END IF;
                END IF;

                -- Calculate the secondary unit price
                IF l_sec_uom_code IS NOT NULL AND
                   p_int_rec(i).secondary_quantity IS NOT NULL AND
                   p_int_rec(i).secondary_quantity <> 0 THEN

                   INL_LOGGING_PVT.Log_Statement (
                        p_module_name => g_module_name,
                        p_procedure_name => l_proc_name,
                        p_debug_info => 'Get the secondary unit price');

                    l_sec_unit_price := (p_int_rec(i).quantity * l_txn_unit_price) / p_int_rec(i).secondary_quantity;

                    INL_LOGGING_PVT.Log_Variable (
                        p_module_name => g_module_name,
                        p_procedure_name => l_proc_name,
                        p_var_name => 'l_sec_unit_price',
                        p_var_value => l_sec_unit_price);
                END IF;
                -- /Bug 8932386

                INL_LOGGING_PVT.Log_Variable (
                    p_module_name => g_module_name,
                    p_procedure_name => l_proc_name,
                    p_var_name => 'l_ship_line_src_id',
                    p_var_value => l_ship_line_src_id);

                INL_LOGGING_PVT.Log_Variable (
                    p_module_name => g_module_name,
                    p_procedure_name => l_proc_name,
                    p_var_name => 'l_txn_unit_price',
                    p_var_value => l_txn_unit_price);

                INL_LOGGING_PVT.Log_Variable (
                    p_module_name => g_module_name,
                    p_procedure_name => l_proc_name,
                    p_var_name => 'p_int_rec(i).po_line_location_id',
                    p_var_value => p_int_rec(i).po_line_location_id);
                INL_LOGGING_PVT.Log_Variable (
                    p_module_name => g_module_name,
                    p_procedure_name => l_proc_name,
                    p_var_name => 'p_int_rec(i).currency_code',
                    p_var_value => p_int_rec(i).currency_code);
                INL_LOGGING_PVT.Log_Variable (
                    p_module_name => g_module_name,
                    p_procedure_name => l_proc_name,
                    p_var_name => 'p_int_rec(i).item_id',
                    p_var_value => p_int_rec(i).item_id);
                INL_LOGGING_PVT.Log_Variable (
                    p_module_name => g_module_name,
                    p_procedure_name => l_proc_name,
                    p_var_name => 'p_int_rec(i).quantity',
                    p_var_value => p_int_rec(i).quantity);
                INL_LOGGING_PVT.Log_Variable (
                    p_module_name => g_module_name,
                    p_procedure_name => l_proc_name,
                    p_var_name => 'l_txn_unit_price',
                    p_var_value => l_txn_unit_price);
                INL_LOGGING_PVT.Log_Variable (
                    p_module_name => g_module_name,
                    p_procedure_name => l_proc_name,
                    p_var_name => 'l_trx_business_category',
                    p_var_value => l_trx_business_category);
                INL_LOGGING_PVT.Log_Variable (
                    p_module_name => g_module_name,
                    p_procedure_name => l_proc_name,
                    p_var_name => 'l_line_intended_use',
                    p_var_value => l_line_intended_use);
                INL_LOGGING_PVT.Log_Variable (
                    p_module_name => g_module_name,
                    p_procedure_name => l_proc_name,
                    p_var_name => 'l_product_fisc_classification',
                    p_var_value => l_product_fisc_classification);
                INL_LOGGING_PVT.Log_Variable (
                    p_module_name => g_module_name,
                    p_procedure_name => l_proc_name,
                    p_var_name => 'l_product_category',
                    p_var_value => l_product_category);
                INL_LOGGING_PVT.Log_Variable (
                    p_module_name => g_module_name,
                    p_procedure_name => l_proc_name,
                    p_var_name => 'l_product_type',
                    p_var_value => l_product_type);
                INL_LOGGING_PVT.Log_Variable (
                    p_module_name => g_module_name,
                    p_procedure_name => l_proc_name,
                    p_var_name => 'l_user_defined_fisc_class',
                    p_var_value => l_user_defined_fisc_class);
                INL_LOGGING_PVT.Log_Variable (
                    p_module_name => g_module_name,
                    p_procedure_name => l_proc_name,
                    p_var_name => 'l_output_tax_classf_code',
                    p_var_value => l_output_tax_classf_code);
                INL_LOGGING_PVT.Log_Statement (
                    p_module_name => g_module_name,
                    p_procedure_name => l_proc_name,
                    p_debug_info => 'Insert inl_ship_lines_int values in PL/SQL table.');

                l_lci_table(l_ind_lci).ship_line_group_reference := l_receipt_num;
                l_lci_table(l_ind_lci).party_id := l_party_id;
                l_lci_table(l_ind_lci).party_site_id := l_party_site_id;
                l_lci_table(l_ind_lci).source_organization_id := l_src_organization_id;
                l_lci_table(l_ind_lci).ship_line_type_id := l_ship_line_type_id;
                l_lci_table(l_ind_lci).ship_line_src_type_code := l_source_document_code; --'PO';
                l_lci_table(l_ind_lci).ship_line_source_id := l_ship_line_src_id; --p_int_rec(i).po_line_location_id;
                l_lci_table(l_ind_lci).currency_code := NVL(p_int_rec(i).currency_code,l_dflt_currency_code);
                l_lci_table(l_ind_lci).currency_conversion_type := p_int_rec(i).currency_conversion_type;
                l_lci_table(l_ind_lci).currency_conversion_date := p_int_rec(i).currency_conversion_date;
                l_lci_table(l_ind_lci).currency_conversion_rate := p_int_rec(i).currency_conversion_rate;
                l_lci_table(l_ind_lci).inventory_item_id := p_int_rec(i).item_id;
                l_lci_table(l_ind_lci).txn_qty := p_int_rec(i).quantity;
                l_lci_table(l_ind_lci).txn_uom_code := p_int_rec(i).uom_code;
                l_lci_table(l_ind_lci).txn_unit_price := l_txn_unit_price; --p_int_rec(i).po_unit_price;
                -- Bug # 8932386
                l_lci_table(l_ind_lci).secondary_uom_code := l_sec_uom_code;
                l_lci_table(l_ind_lci).secondary_qty := p_int_rec(i).secondary_quantity;
                l_lci_table(l_ind_lci).secondary_unit_price := l_sec_unit_price;
                -- /Bug # 8932386
               -- l_lci_table(l_ind_lci).landed_cost_flag := 'Y'; -- # Bug 9866323
               -- l_lci_table(l_ind_lci).allocation_enabled_flag := 'Y'; -- # Bug 9866323
                l_lci_table(l_ind_lci).trx_business_category := l_trx_business_category;
                l_lci_table(l_ind_lci).intended_use := l_line_intended_use;
                l_lci_table(l_ind_lci).product_fiscal_class := l_product_fisc_classification;
                l_lci_table(l_ind_lci).product_category := l_product_category;
                l_lci_table(l_ind_lci).product_type := l_product_type;
                l_lci_table(l_ind_lci).user_def_fiscal_class := l_user_defined_fisc_class;
                l_lci_table(l_ind_lci).tax_classification_code := l_output_tax_classf_code;
                l_lci_table(l_ind_lci).ship_from_party_id := l_party_id;
                l_lci_table(l_ind_lci).ship_from_party_site_id := l_party_site_id;
                l_lci_table(l_ind_lci).ship_to_organization_id := l_ship_to_org_id;
                l_lci_table(l_ind_lci).ship_to_location_id := p_int_rec(i).ship_to_location_id;
                l_lci_table(l_ind_lci).bill_from_party_id := l_party_id;
                l_lci_table(l_ind_lci).bill_from_party_site_id := l_party_site_id;
                l_lci_table(l_ind_lci).bill_to_organization_id := l_ship_to_org_id;
                l_lci_table(l_ind_lci).bill_to_location_id := p_int_rec(i).ship_to_location_id;
                l_lci_table(l_ind_lci).poa_party_id := l_party_id;
                l_lci_table(l_ind_lci).poa_party_site_id := l_party_site_id;
                l_lci_table(l_ind_lci).poo_organization_id := l_ship_to_org_id;
                l_lci_table(l_ind_lci).poo_location_id := p_int_rec(i).ship_to_location_id;
                l_lci_table(l_ind_lci).line_interface_source_table := 'RCV_TRANSACTIONS_INTERFACE';
                l_lci_table(l_ind_lci).line_interface_source_line_id := p_int_rec(i).interface_transaction_id;
                l_lci_table(l_ind_lci).rcv_enabled_flag := 'Y'; --Bug#9279355
                l_ind_lci := l_ind_lci + 1;
            EXCEPTION
                WHEN OTHERS THEN
                    FND_MESSAGE.SET_NAME ('INL', 'INL_UNEXPECTED_ERR') ;    --Bug#9737425
                    FND_MESSAGE.SET_TOKEN ('ERROR_CODE', substr(SQLERRM, 1, 1000)) ; --Bug#9737425
                    FND_MSG_PUB.ADD;                                        --Bug#9737425
                    INL_LOGGING_PVT.Log_UnexpecError (
                        p_module_name => g_module_name,
                        p_procedure_name => l_proc_name);
                    INL_LOGGING_PVT.Log_Variable (
                        p_module_name => g_module_name,
                        p_procedure_name => l_proc_name,
                        p_var_name => 'Error: ',
                        p_var_value => sqlcode ||' '||substr(SQLERRM, 1, 1000));
                    erroredHeaderId := Nvl(p_int_rec(i).shipment_header_id,p_int_rec(i).header_interface_id);
                    INL_LOGGING_PVT.Log_Variable (
                        p_module_name => g_module_name,
                        p_procedure_name => l_proc_name,
                        p_var_name => 'l_begin_of_this_header',
                        p_var_value => l_begin_of_this_header);
                    INL_LOGGING_PVT.Log_Variable (
                        p_module_name => g_module_name,
                        p_procedure_name => l_proc_name,
                        p_var_name => 'l_ind_lci',
                        p_var_value => l_ind_lci);
                    INL_LOGGING_PVT.Log_Variable (
                        p_module_name => g_module_name,
                        p_procedure_name => l_proc_name,
                        p_var_name => 'l_lci_table.COUNT',
                        p_var_value => l_lci_table.COUNT);
                    FOR j in l_begin_of_this_header..l_lci_table.COUNT LOOP --Bug#9737425

                        INL_LOGGING_PVT.Log_Variable (
                            p_module_name => g_module_name,
                            p_procedure_name => l_proc_name,
                            p_var_name => 'l_lci_table('||j||').shipment_header_id',
                            p_var_value => l_lci_table(j).shipment_header_id);

                        INL_LOGGING_PVT.Log_Variable (
                            p_module_name => g_module_name,
                            p_procedure_name => l_proc_name,
                            p_var_name => 'l_lci_table('||j||').header_interface_id',
                            p_var_value => l_lci_table(j).header_interface_id);
                        --Bug#9737425

                        IF l_lci_table(j).shipment_header_id IS NULL THEN
                            l_lci_table(j).header_interface_id := -9999;
                        ELSE
                            l_lci_table(j).shipment_header_id := -9999;
                        END IF;
                        --Bug#9737425

                        INL_LOGGING_PVT.Log_Statement (
                            p_module_name => g_module_name,
                            p_procedure_name => l_proc_name,
                            p_debug_info => 'End loop');
                    END LOOP;
                    l_ind_lci := l_begin_of_this_header;    --Bug#8971617
            END;
        END IF;
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_proc_name,
            p_debug_info => 'End loop');
    END LOOP;
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name,
        p_debug_info => 'Call Insert_LCMInterface to insert data in lcm interface table');

    -- Call Insert_LCMInterface to insert data in lcm interface table
    INL_INTEGRATION_GRP.Insert_LCMInterface(p_api_version    => l_api_version,
                                            p_init_msg_list  => FND_API.G_FALSE,
                                            p_commit         => FND_API.G_FALSE,
                                            p_lci_table      => l_lci_table,
                                            x_return_status  => l_return_status,
                                            x_msg_count      => l_msg_count,
                                            x_msg_data       => l_msg_data);

    -- If any errors happen abort the process.
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    currentHeaderId := -9999;
    FOR i IN 1..l_lci_table.COUNT LOOP      --Bug#8971617
        -- Update RTIs to LC_INTERFACED
        INL_LOGGING_PVT.Log_Variable (
            p_module_name => g_module_name,
            p_procedure_name => l_proc_name,
            p_var_name => 'l_lci_table('||i||').shipment_header_id',
            p_var_value => l_lci_table(i).shipment_header_id);

        INL_LOGGING_PVT.Log_Variable (
            p_module_name => g_module_name,
            p_procedure_name => l_proc_name,
            p_var_name => 'l_lci_table('||i||').header_interface_id',
            p_var_value => l_lci_table(i).header_interface_id);

        IF NVL(l_lci_table(i).shipment_header_id,l_lci_table(i).header_interface_id) <> -9999 THEN  --Bug#9737425
            IF currentHeaderId <> l_lci_table(i).hdr_interface_source_line_id THEN
                currentHeaderId := l_lci_table(i).hdr_interface_source_line_id;
                IF l_lci_table(i).header_interface_id IS NOT NULL THEN
                    UPDATE rcv_headers_interface rhi
                       SET processing_status_code = 'LC_INTERFACED'
                     WHERE processing_status_code='LC_PENDING'
                       AND header_interface_id=l_lci_table(i).header_interface_id;
                END IF;
                UPDATE rcv_transactions_interface rti
                   SET processing_status_code = 'LC_INTERFACED'
                 WHERE transaction_status_code = 'PENDING'
                   AND processing_status_code = 'LC_PENDING'
                   AND (transaction_type in ('RECEIVE', 'MATCH') OR --Bug#9275335
                       (transaction_type ='SHIP' AND auto_transact_code  IN ('RECEIVE','DELIVER')))
                   AND source_document_code IN ('PO', 'REQ', 'RMA')
                   AND Nvl(shipment_header_id,Header_interface_id) =  Nvl(l_lci_table(i).shipment_header_id,l_lci_table(i).header_interface_id);
            END IF;
            -- Set the number of records interfaced successfully
            -- This value will be latter stamped in the concurrent log
            l_records_inserted := l_records_inserted + 1;
        END IF;
    END LOOP;

    -- Write the number of records processed and inserted by this concurrent process
    FND_FILE.put_line( FND_FILE.log, '< **************************************>');
    FND_FILE.put_line( FND_FILE.log, '< ***** ' || 'Records Processed: ' || l_records_processed); -- Bug#9258936
    FND_FILE.put_line( FND_FILE.log, '< ***** ' || 'Records Inserted: ' || l_records_inserted);  -- Bug#9258936
    FND_FILE.put_line( FND_FILE.log, '< **************************************>');

    --Bug#10381495
    IF (l_current_org_id <> NVL(l_previous_org_id,-999)) THEN
        INL_LOGGING_PVT.Log_Statement(
            p_module_name => g_module_name,
            p_procedure_name => l_proc_name,
            p_debug_info => 'Restore previous context: from '||l_current_org_id||' to '||l_previous_org_id
        );
        mo_global.set_policy_context( l_previous_access_mode, l_previous_org_id);
    END IF;
    --Bug#10381495

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get (
        p_encoded => FND_API.g_false,
        p_count => x_msg_count,
        p_data => x_msg_data) ;

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name    => g_module_name,
        p_procedure_name => l_proc_name);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name => g_module_name,
            p_procedure_name => l_proc_name) ;
        INL_LOGGING_PVT.Log_Statement (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name,
            p_debug_info     => 'the error is:  ' || sqlcode ||' '||substr(SQLERRM, 1, 1000));
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_ERROR;
        --Bug#10381495
        IF (l_current_org_id <> NVL(l_previous_org_id,-999)) THEN
            INL_LOGGING_PVT.Log_Statement(
                p_module_name => g_module_name,
                p_procedure_name => l_proc_name,
                p_debug_info => 'Restore previous context: from '||l_current_org_id||' to '||l_previous_org_id
            );
            mo_global.set_policy_context( l_previous_access_mode, l_previous_org_id);
        END IF;
        --Bug#10381495
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.g_false,
            p_count => x_msg_count,
            p_data => x_msg_data) ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name);
        INL_LOGGING_PVT.Log_Statement (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name,
            p_debug_info     => 'the error is:  ' || sqlcode ||' '||substr(SQLERRM, 1, 1000));
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --Bug#10381495
        IF (l_current_org_id <> NVL(l_previous_org_id,-999)) THEN
            INL_LOGGING_PVT.Log_Statement(
                p_module_name => g_module_name,
                p_procedure_name => l_proc_name,
                p_debug_info => 'Restore previous context: from '||l_current_org_id||' to '||l_previous_org_id
            );
            mo_global.set_policy_context( l_previous_access_mode, l_previous_org_id);
        END IF;
        --Bug#10381495
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.g_false,
            p_count => x_msg_count,
            p_data => x_msg_data) ;
    WHEN OTHERS THEN
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name);
        INL_LOGGING_PVT.Log_Statement (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name,
            p_debug_info     => 'the error is:  ' || sqlcode ||' '||substr(SQLERRM, 1, 1000));
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --Bug#10381495
        IF (l_current_org_id <> NVL(l_previous_org_id,-999)) THEN
            INL_LOGGING_PVT.Log_Statement(
                p_module_name => g_module_name,
                p_procedure_name => l_proc_name,
                p_debug_info => 'Restore previous context: from '||l_current_org_id||' to '||l_previous_org_id
            );
            mo_global.set_policy_context( l_previous_access_mode, l_previous_org_id);
        END IF;
        --Bug#10381495
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.g_false,
            p_count => x_msg_count,
            p_data => x_msg_data) ;
END Import_FromRCV;

-- API name   : Get_LandedCost
-- Type       : Group
-- Function   : Get the Unit Landed Cost.
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version             IN NUMBER,
--              p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE
--              p_commit                  IN VARCHAR2 := FND_API.G_FALSE
--              p_ship_line_id            IN NUMBER
-- Bug 17536452
--              p_transaction_date        IN DATE DEFAULT SYSDATE
-- Bug 17536452
--
-- OUT          x_return_status           OUT NOCOPY VARCHAR2
--              x_msg_count               OUT NOCOPY NUMBER
--              x_msg_data                OUT NOCOPY VARCHAR2
--              x_actual_unit_landed_cost OUT NOCOPY NUMBER
--              x_adjustment_num           OUT NOCOPY NUMBER,
--
-- Version    : Current version 1.0
--
-- Notes      :

PROCEDURE  Get_LandedCost (
    p_api_version             IN NUMBER,
    p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE,
    p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
    p_ship_line_id            IN NUMBER,
    --Bug 17536452
	  p_transaction_date        IN DATE DEFAULT SYSDATE,
    --Bug 17536452
    x_actual_unit_landed_cost OUT NOCOPY NUMBER,
    x_adjustment_num           OUT NOCOPY NUMBER,        -- OPM Integration
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2
) IS
     l_api_name                   CONSTANT VARCHAR2(30) := 'Get_LandedCost';
     l_api_version                CONSTANT NUMBER := 1.0;
     l_return_status              VARCHAR2(100);
     l_msg_count                  NUMBER;
     l_msg_data                   VARCHAR2(2000);
     l_organization_id            NUMBER;
     l_inventory_item_id          NUMBER;
     l_primary_qty                NUMBER;
     l_primary_uom_code           VARCHAR2(30);
     l_estimated_item_price       NUMBER;
     l_estimated_charges          NUMBER;
     l_estimated_taxes            NUMBER;
     l_estimated_unit_landed_cost NUMBER;
     l_actual_item_price          NUMBER;
     l_actual_charges             NUMBER;
     l_actual_taxes               NUMBER;

BEGIN

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (p_module_name => g_module_name,
                                   p_procedure_name => l_api_name) ;

    -- Standard Start of API savepoint
    SAVEPOINT Get_LandedCost_GRP;

    -- Initialize message list IF p_init_msg_list is SET to TRUE.
    IF FND_API.to_Boolean (p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Check FOR call compatibility.
    IF NOT FND_API.Compatible_API_Call (p_current_version_number => l_api_version,
                                        p_caller_version_number => p_api_version,
                                        p_api_name => l_api_name,
                                        p_pkg_name => g_pkg_name) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize API RETURN status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    BEGIN

        INL_LOGGING_PVT.Log_Statement (p_module_name    => g_module_name,
                                       p_procedure_name => l_api_name,
                                       p_debug_info     => 'Before calling INL_LANDEDCOST_PUB.Get_LandedCost');

        INL_LANDEDCOST_PUB.Get_LandedCost (p_api_version                => l_api_version,
                                           p_ship_line_id               => p_ship_line_id,
                                           --Bug 17536452
                                           p_transaction_date           => p_transaction_date,
                                           --Bug 17536452
                                           x_return_status              => l_return_status,
                                           x_msg_count                  => l_msg_count,
                                           x_msg_data                   => l_msg_data,
                                           x_organization_id            => l_organization_id,
                                           x_inventory_item_id          => l_inventory_item_id,
                                           x_primary_qty                => l_primary_qty,
                                           x_primary_uom_code           => l_primary_uom_code,
                                           x_estimated_item_price       => l_estimated_item_price,
                                           x_estimated_charges          => l_estimated_charges,
                                           x_estimated_taxes            => l_estimated_taxes,
                                           x_estimated_unit_landed_cost => l_estimated_unit_landed_cost,
                                           x_actual_item_price          => l_actual_item_price,
                                           x_actual_charges             => l_actual_charges,
                                           x_actual_taxes               => l_actual_taxes,
                                           x_actual_unit_landed_cost    => x_actual_unit_landed_cost,
                                           x_adjustment_num             => x_adjustment_num);  -- opm integration

        INL_LOGGING_PVT.Log_Statement (p_module_name    => g_module_name,
                                       p_procedure_name => l_api_name,
                                       p_debug_info     => 'After calling INL_LANDEDCOST_PUB.Get_LandedCost');

        INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                      p_procedure_name => l_api_name,
                                      p_var_name => 'INL_LANDEDCOST_PUB.Get_LandedCost Return Status: ',
                                      p_var_value => l_return_status);

        -- If any errors happen abort the process.
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END;
    -- Standard check of p_commit.
    IF FND_API.To_Boolean (p_commit) THEN
        COMMIT WORK;
    END IF;

    -- Get message count AND IF count is 1, get message info.
    FND_MSG_PUB.Count_And_Get ( p_encoded => FND_API.g_false,
                                p_count => x_msg_count,
                                p_data => x_msg_data) ;

    -- End of Procedure Logging
    INL_LOGGING_PVT.Log_EndProc ( p_module_name => g_module_name,
                                  p_procedure_name => l_api_name) ;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError ( p_module_name => g_module_name,
                                         p_procedure_name => l_api_name) ;
        ROLLBACK TO Get_LandedCost_GRP;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get ( p_encoded => FND_API.g_false,
                                    p_count => x_msg_count,
                                    p_data => x_msg_data) ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError ( p_module_name => g_module_name,
                                           p_procedure_name => l_api_name) ;
        ROLLBACK TO Get_LandedCost_GRP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get ( p_encoded => FND_API.g_false,
                                    p_count => x_msg_count,
                                    p_data => x_msg_data) ;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError ( p_module_name => g_module_name,
                                           p_procedure_name => l_api_name) ;
        ROLLBACK TO Get_LandedCost_GRP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg ( p_pkg_name => g_pkg_name,
                                      p_procedure_name => l_api_name) ;
        END IF;
        FND_MSG_PUB.Count_And_Get ( p_encoded => FND_API.g_false,
                                    p_count => x_msg_count,
                                    p_data => x_msg_data);
END Get_LandedCost;


-- API name   : Get_LandedCost
-- Type       : Group
-- Function   : Update RCV Transactions Interface with
--              the calculated Unit Landed Cost.
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_rti_rec         IN RCV_LCM_WEB_SERVICE.rti_cur_table
--              p_group_id        IN NUMBER
--              p_processing_mode IN VARCHAR2
--
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE  Get_LandedCost (
    p_rti_rec         IN RCV_LCM_WEB_SERVICE.rti_cur_table,
    p_group_id        IN NUMBER,
    p_processing_mode IN VARCHAR2)
IS

     l_api_name                   CONSTANT VARCHAR2(30) := 'Get_LandedCost-2';
     l_api_version                CONSTANT NUMBER := 1.0;
     l_return_status              VARCHAR2(100);
     l_msg_count                  NUMBER;
     l_msg_data                   VARCHAR2(2000);
     l_actual_unit_landed_cost    NUMBER;
     l_actual_ajust_num           NUMBER;

BEGIN

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (p_module_name => g_module_name,
                                   p_procedure_name => l_api_name) ;

    FOR i IN 1..p_rti_rec.COUNT LOOP
        INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                      p_procedure_name => l_api_name,
                                      p_var_name => 'p_rti_rec(i).line_id',
                                      p_var_value => p_rti_rec(i).line_id);

        INL_LOGGING_PVT.Log_Statement (p_module_name    => g_module_name,
                                       p_procedure_name => l_api_name,
                                       p_debug_info     => 'Before calling INL_LANDEDCOST_PUB.Get_LandedCost');

        INL_INTEGRATION_GRP.Get_LandedCost (p_api_version             => l_api_version,
                                            p_init_msg_list           => FND_API.G_FALSE,
                                            p_commit                  => FND_API.G_FALSE,
                                            p_ship_line_id            => p_rti_rec(i).line_id,
                                            x_actual_unit_landed_cost => l_actual_unit_landed_cost,
                                            x_adjustment_num          => l_actual_ajust_num,     -- opm integration
                                            x_return_status           => l_return_status,
                                            x_msg_count               => l_msg_count,
                                            x_msg_data                => l_msg_data);

        INL_LOGGING_PVT.Log_Statement (p_module_name    => g_module_name,
                                       p_procedure_name => l_api_name,
                                       p_debug_info     => 'After calling INL_LANDEDCOST_PUB.Get_LandedCost');

        INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                      p_procedure_name => l_api_name,
                                      p_var_name => 'l_actual_unit_landed_cost',
                                      p_var_value => l_actual_unit_landed_cost);

        IF (l_actual_unit_landed_cost IS NOT NULL) THEN
            INL_LOGGING_PVT.Log_Statement (p_module_name    => g_module_name,
                                           p_procedure_name => l_api_name,
                                           p_debug_info     => 'Updating RTIs with the new landed cost');


            UPDATE rcv_transactions_interface
            SET   unit_landed_cost = l_actual_unit_landed_cost,
                  lcm_adjustment_num = l_actual_ajust_num  -- opm integration
            WHERE processing_status_code  = 'RUNNING'
            AND transaction_status_code = 'PENDING'
            AND processing_mode_code = p_processing_mode
            AND group_id = nvl(p_group_id, group_id)
            AND mo_global.check_access(org_id) = 'Y'
            AND processing_mode_code = p_processing_mode
            AND source_document_code = 'PO'
-- SCM-051            AND transaction_type NOT IN('SHIP', 'RECEIVE', 'ACCEPT', 'REJECT','TRANSFER','UNORDERED')
            AND lcm_shipment_line_id IS NOT NULL
            AND lcm_shipment_line_id =  p_rti_rec(i).line_id;

            INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                          p_procedure_name => l_api_name,
                                          p_var_name => 'RTIs updated',
                                          p_var_value => sql%rowcount);
        ELSE
            INL_LOGGING_PVT.Log_Statement (p_module_name    => g_module_name,
                                           p_procedure_name => l_api_name,
                                           p_debug_info     => 'Setting RTIs to ERROR. Landed Cost is null.');

            UPDATE rcv_transactions_interface rti
            SET   unit_landed_cost = NULL,
                  lcm_adjustment_num = NULL, -- opm integration
                  processing_status_code  = 'ERROR'
            WHERE processing_status_code  = 'RUNNING'
            AND transaction_status_code = 'PENDING'
            AND processing_mode_code = p_processing_mode
            AND group_id = nvl(p_group_id, group_id)
            AND processing_mode_code = p_processing_mode
            AND mo_global.check_access(org_id) = 'Y'
            AND source_document_code = 'PO'
-- SCM-051    AND transaction_type NOT IN('SHIP', 'RECEIVE', 'ACCEPT', 'REJECT','TRANSFER','UNORDERED')
            AND lcm_shipment_line_id IS NOT NULL
            AND lcm_shipment_line_id =  p_rti_rec(i).line_id;

        END IF;
    END LOOP;

    -- End of Procedure Logging
    INL_LOGGING_PVT.Log_EndProc ( p_module_name => g_module_name,
                                  p_procedure_name => l_api_name) ;
EXCEPTION
    WHEN OTHERS THEN
        INL_LOGGING_PVT.Log_UnexpecError (p_module_name    => g_module_name,
                                          p_procedure_name => l_api_name);
        INL_LOGGING_PVT.Log_Statement (p_module_name    => g_module_name,
                                       p_procedure_name => l_api_name,
                                       p_debug_info     => 'the error is:  ' || sqlcode ||' '||substr(SQLERRM, 1, 1000));
        UPDATE rcv_transactions_interface
        SET    processing_status_code  = 'ERROR'
        WHERE  processing_status_code  = 'RUNNING'
        AND    transaction_status_code = 'PENDING'
        AND    mo_global.check_access(org_id) = 'Y'
        AND    processing_mode_code = p_processing_mode
        AND    group_id = nvl(p_group_id, group_id)
        AND    source_document_code = 'PO'
-- SCM-051         AND    transaction_type NOT IN ('SHIP', 'RECEIVE', 'ACCEPT', 'REJECT','TRANSFER','UNORDERED')
        AND    lcm_shipment_line_id IS NOT NULL;

        INL_LOGGING_PVT.Log_Statement (p_module_name    => g_module_name,
                                       p_procedure_name => l_api_name,
                                       p_debug_info     => sql%rowcount || ' RTIs updated to Error');
END Get_LandedCost;

/*Bug 17536452 New overload of Get_LandedCost receives rti.lcm_shipment_line_id line_id, rti.interface_transaction_id and rti.transaction_date
as part of p_rti_opm_rec (for OPM orgs only)*/


-- API name   : Get_LandedCost
-- Type       : Group
-- Function   : Update RCV Transactions Interface with
--              the calculated Unit Landed Cost.
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_rti_opm_rec         IN RCV_LCM_WEB_SERVICE.rti_opm_cur_table
--              p_group_id        IN NUMBER
--              p_processing_mode IN VARCHAR2
--
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE  Get_LandedCost (
--Bug 17536452
    p_rti_opm_rec         IN RCV_LCM_WEB_SERVICE.rti_opm_cur_table,
--Bug 17536452
    p_group_id        IN NUMBER,
    p_processing_mode IN VARCHAR2)
IS

     l_api_name                   CONSTANT VARCHAR2(30) := 'Get_LandedCost-3';
     l_api_version                CONSTANT NUMBER := 1.0;
     l_return_status              VARCHAR2(100);
     l_msg_count                  NUMBER;
     l_msg_data                   VARCHAR2(2000);
     l_actual_unit_landed_cost    NUMBER;
     l_actual_ajust_num           NUMBER;

BEGIN

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (p_module_name => g_module_name,
                                   p_procedure_name => l_api_name) ;

    FOR i IN 1..p_rti_opm_rec.COUNT LOOP
        INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                      p_procedure_name => l_api_name,
                                      p_var_name => 'p_rti_opm_rec(i).line_id',
                                      p_var_value => p_rti_opm_rec(i).line_id);

--Bug 17536452
        INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                      p_procedure_name => l_api_name,
                                      p_var_name => 'p_rti_opm_rec(i).interface_transaction_id',
                                      p_var_value => p_rti_opm_rec(i).interface_transaction_id);

		    INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                      p_procedure_name => l_api_name,
                                      p_var_name => 'p_rti_opm_rec(i).transaction_date',
                                      p_var_value => p_rti_opm_rec(i).transaction_date);

--Bug 17536452
        INL_LOGGING_PVT.Log_Statement (p_module_name    => g_module_name,
                                       p_procedure_name => l_api_name,
                                       p_debug_info     => 'Before calling INL_LANDEDCOST_PUB.Get_LandedCost');

 --Calling Get_LandedCost-1 with transaction date.

        INL_INTEGRATION_GRP.Get_LandedCost (p_api_version             => l_api_version,
                                            p_init_msg_list           => FND_API.G_FALSE,
                                            p_commit                  => FND_API.G_FALSE,
                                            p_ship_line_id            => p_rti_opm_rec(i).line_id,
                                            --Bug 17536452
											                      p_transaction_date        => p_rti_opm_rec(i).transaction_date,
                                            --Bug 17536452
                                            x_actual_unit_landed_cost => l_actual_unit_landed_cost,
                                            x_adjustment_num          => l_actual_ajust_num,     -- opm integration
                                            x_return_status           => l_return_status,
                                            x_msg_count               => l_msg_count,
                                            x_msg_data                => l_msg_data);

        INL_LOGGING_PVT.Log_Statement (p_module_name    => g_module_name,
                                       p_procedure_name => l_api_name,
                                       p_debug_info     => 'After calling INL_LANDEDCOST_PUB.Get_LandedCost');

        INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                      p_procedure_name => l_api_name,
                                      p_var_name => 'l_actual_unit_landed_cost',
                                      p_var_value => l_actual_unit_landed_cost);

        IF (l_actual_unit_landed_cost IS NOT NULL) THEN
            INL_LOGGING_PVT.Log_Statement (p_module_name    => g_module_name,
                                           p_procedure_name => l_api_name,
                                           p_debug_info     => 'Updating RTIs with the new landed cost');


            UPDATE rcv_transactions_interface
            SET   unit_landed_cost = l_actual_unit_landed_cost,
                  lcm_adjustment_num = l_actual_ajust_num  -- opm integration
            WHERE processing_status_code  = 'RUNNING'
            AND transaction_status_code = 'PENDING'
            AND processing_mode_code = p_processing_mode
            AND group_id = nvl(p_group_id, group_id)
            AND mo_global.check_access(org_id) = 'Y'
            AND processing_mode_code = p_processing_mode
            AND source_document_code = 'PO'
-- SCM-051            AND transaction_type NOT IN('SHIP', 'RECEIVE', 'ACCEPT', 'REJECT','TRANSFER','UNORDERED')
            AND lcm_shipment_line_id IS NOT NULL
            AND lcm_shipment_line_id =  p_rti_opm_rec(i).line_id
--Bug 17536452 Update RCV Transactions Interface (OPM) with the calculated Unit Landed Cost
            AND interface_transaction_id = p_rti_opm_rec(i).interface_transaction_id;
--Bug 17536452
            INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                          p_procedure_name => l_api_name,
                                          p_var_name => 'RTIs updated',
                                          p_var_value => sql%rowcount);
        ELSE
            INL_LOGGING_PVT.Log_Statement (p_module_name    => g_module_name,
                                           p_procedure_name => l_api_name,
                                           p_debug_info     => 'Setting RTIs to ERROR. Landed Cost is null.');

            UPDATE rcv_transactions_interface rti
            SET   unit_landed_cost = NULL,
                  lcm_adjustment_num = NULL, -- opm integration
                  processing_status_code  = 'ERROR'
            WHERE processing_status_code  = 'RUNNING'
            AND transaction_status_code = 'PENDING'
            AND processing_mode_code = p_processing_mode
            AND group_id = nvl(p_group_id, group_id)
            AND processing_mode_code = p_processing_mode
            AND mo_global.check_access(org_id) = 'Y'
            AND source_document_code = 'PO'
-- SCM-051    AND transaction_type NOT IN('SHIP', 'RECEIVE', 'ACCEPT', 'REJECT','TRANSFER','UNORDERED')
            AND lcm_shipment_line_id IS NOT NULL
            AND lcm_shipment_line_id =  p_rti_opm_rec(i).line_id
--Bug 17536452 Update RCV Transactions Interface (OPM) with the calculated Unit Landed Cost
            AND interface_transaction_id = p_rti_opm_rec(i).interface_transaction_id;
--Bug 17536452
        END IF;
    END LOOP;

    -- End of Procedure Logging
    INL_LOGGING_PVT.Log_EndProc ( p_module_name => g_module_name,
                                  p_procedure_name => l_api_name) ;
EXCEPTION
    WHEN OTHERS THEN
        INL_LOGGING_PVT.Log_UnexpecError (p_module_name    => g_module_name,
                                          p_procedure_name => l_api_name);
        INL_LOGGING_PVT.Log_Statement (p_module_name    => g_module_name,
                                       p_procedure_name => l_api_name,
                                       p_debug_info     => 'the error is:  ' || sqlcode ||' '||substr(SQLERRM, 1, 1000));
        UPDATE rcv_transactions_interface
        SET    processing_status_code  = 'ERROR'
        WHERE  processing_status_code  = 'RUNNING'
        AND    transaction_status_code = 'PENDING'
        AND    mo_global.check_access(org_id) = 'Y'
        AND    processing_mode_code = p_processing_mode
        AND    group_id = nvl(p_group_id, group_id)
        AND    source_document_code = 'PO'
-- SCM-051         AND    transaction_type NOT IN ('SHIP', 'RECEIVE', 'ACCEPT', 'REJECT','TRANSFER','UNORDERED')
        AND    lcm_shipment_line_id IS NOT NULL;

        INL_LOGGING_PVT.Log_Statement (p_module_name    => g_module_name,
                                       p_procedure_name => l_api_name,
                                       p_debug_info     => sql%rowcount || ' RTIs updated to Error');
END Get_LandedCost;



-- Utility    : Call_UpdateRCV
-- Type       : Group
-- Function   : Update RCV tables with the calculated Unit
--              Landed Cost and its related LCM Shipment Line Id.
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_lines_table     IN ship_lines_table
--
-- OUT          x_return_status  OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Call_UpdateRCV (p_ship_lines_table IN ship_lines_table,
                          x_return_status  OUT NOCOPY VARCHAR2)
IS


    l_proc_name CONSTANT VARCHAR2(30) := 'Call_UpdateRCV';
    l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

    l_rti_lc_info_table  RCV_UPDATE_RTI_LC.rcv_cost_table := RCV_UPDATE_RTI_LC.rcv_cost_table();
    l_rcv_int_table  RCV_UPDATE_RTI_LC.lcm_int_table := RCV_UPDATE_RTI_LC.lcm_int_table();

BEGIN

    --  Initialize return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (p_module_name    => g_module_name,
                                  p_procedure_name => l_proc_name);

    INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                  p_procedure_name => l_proc_name,
                                  p_var_name => 'p_ship_lines_table.COUNT',
                                  p_var_value => p_ship_lines_table.COUNT);

    FOR i IN 1..p_ship_lines_table.COUNT LOOP
            l_rti_lc_info_table.EXTEND;
            l_rti_lc_info_table(i).interface_id := p_ship_lines_table(i).interface_source_line_id;
            l_rti_lc_info_table(i).lcm_shipment_line_id := p_ship_lines_table(i).ship_line_id;
            l_rti_lc_info_table(i).unit_landed_cost := p_ship_lines_table(i).unit_landed_cost;
    END LOOP;

    INL_LOGGING_PVT.Log_Statement (p_module_name    => g_module_name,
                                   p_procedure_name => l_proc_name,
                                   p_debug_info     => 'Before calling RCV_UPDATE_RTI_LC.Update_RTI: ' || to_char(SYSDATE,'DD-MON-YYYY HH:MI:SS'));

    RCV_UPDATE_RTI_LC.Update_RTI(p_int_rec => l_rti_lc_info_table,
                                 x_lcm_int => l_rcv_int_table);

    INL_LOGGING_PVT.Log_Statement (p_module_name    => g_module_name,
                                   p_procedure_name => l_proc_name,
                                   p_debug_info     => 'After calling RCV_UPDATE_RTI_LC.Update_RTI: ' || to_char(SYSDATE,'DD-MON-YYYY HH:MI:SS'));

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc (p_module_name    => g_module_name,
                                 p_procedure_name => l_proc_name);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name);
        x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(
              p_pkg_name       => g_pkg_name,
              p_procedure_name => l_proc_name);
        END IF;
END Call_UpdateRCV;

-- API name : Call_StampLC
-- Type       : Group
-- Function   : Call Stamp LC with the calculated Unit
--              Landed Cost and its related LCM Shipment Line Id.
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version    IN NUMBER,
--              p_init_msg_list  IN VARCHAR2 := FND_API.G_FALSE
--              p_commit         IN VARCHAR2 := FND_API.G_FALSE
--              p_ship_header_id IN NUMBER
--
-- OUT          x_return_status  OUT NOCOPY VARCHAR2
--              x_msg_count      OUT NOCOPY NUMBER
--              x_msg_data       OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Call_StampLC (p_api_version    IN NUMBER,
                        p_init_msg_list  IN VARCHAR2 := FND_API.G_FALSE,
                        p_commit         IN VARCHAR2 := FND_API.G_FALSE,
                        p_ship_header_id IN NUMBER,
                        x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count      OUT NOCOPY NUMBER,
                        x_msg_data       OUT NOCOPY VARCHAR2) IS

    l_api_name         CONSTANT VARCHAR2(30) := 'Call_StampLC';
    l_api_version      CONSTANT NUMBER := 1.0;
    l_return_status    VARCHAR2(1);
    l_msg_count        NUMBER;
    l_msg_data         VARCHAR2(2000);
    l_ship_lines_table ship_lines_table;

BEGIN

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (p_module_name => g_module_name,
                                   p_procedure_name => l_api_name) ;

    -- Standard Start of API savepoint
    SAVEPOINT Call_StampLC_GRP;

    -- Initialize message list IF p_init_msg_list is SET to TRUE.
    IF FND_API.to_Boolean (p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Check FOR call compatibility.
    IF NOT FND_API.Compatible_API_Call (p_current_version_number => l_api_version,
                                        p_caller_version_number => p_api_version,
                                        p_api_name => l_api_name,
                                        p_pkg_name => g_pkg_name) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize API RETURN status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN c_ship_lines(p_ship_header_id, /*'PO'*/ NULL, 'RCV_TRANSACTIONS_INTERFACE');
    FETCH c_ship_lines BULK COLLECT INTO l_ship_lines_table;

    IF c_ship_lines%ISOPEN THEN
      CLOSE c_ship_lines;
    END IF;

    INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                  p_procedure_name => l_api_version,
                                  p_debug_info => 'Before calling Call_UpdateRCV');

    Call_UpdateRCV (p_ship_lines_table => l_ship_lines_table,
                    x_return_status  => l_return_status);

    INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                   p_procedure_name => l_api_name,
                                   p_debug_info => 'After calling Call_UpdateRCV');

    INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                  p_procedure_name => l_api_name,
                                  p_var_name => 'Call_UpdateRCV l_return_status: ',
                                  p_var_value => l_return_status);

    -- If any errors happen abort the process.
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

      -- Standard check of p_commit.
    IF FND_API.To_Boolean (p_commit) THEN
        COMMIT WORK;
    END IF;

    -- Get message count AND IF count is 1, get message info.
    FND_MSG_PUB.Count_And_Get ( p_encoded => FND_API.g_false,
                                p_count => x_msg_count,
                                p_data => x_msg_data);

    -- End of Procedure Logging
    INL_LOGGING_PVT.Log_EndProc ( p_module_name => g_module_name,
                                  p_procedure_name => l_api_name);
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
    -- Standard Expected Error Logging
    INL_LOGGING_PVT.Log_ExpecError ( p_module_name => g_module_name,
                                     p_procedure_name => l_api_name);
    ROLLBACK TO Call_StampLC_GRP;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_encoded => FND_API.g_false,
                                p_count => x_msg_count,
                                p_data => x_msg_data);
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError ( p_module_name => g_module_name,
                                       p_procedure_name => l_api_name);
    ROLLBACK TO Call_StampLC_GRP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_encoded => FND_API.g_false,
                                p_count => x_msg_count,
                                p_data => x_msg_data) ;
WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError ( p_module_name => g_module_name,
                                       p_procedure_name => l_api_name) ;
    ROLLBACK TO Call_StampLC_GRP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg ( p_pkg_name => g_pkg_name,
                                  p_procedure_name => l_api_name) ;
    END IF;
    FND_MSG_PUB.Count_And_Get ( p_encoded => FND_API.g_false,
                                p_count => x_msg_count,
                                p_data => x_msg_data) ;
END Call_StampLC;

---
-- Utility name: Call_InsertRCV
-- Type       : Group
-- Function   : Call RCV code to insert in RCV tables
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_header_id IN NUMBER
--              p_rti_rec        IN ship_lines_table
--
-- OUT          x_return_status  OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Call_InsertRCV(p_ship_header_id IN NUMBER,
                         p_ship_lines_table IN ship_lines_table,
                         x_return_status  OUT NOCOPY VARCHAR2)
IS
    l_proc_name CONSTANT VARCHAR2(30) := 'Call_InsertRCV';
    l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_ship_lines_table RCV_INSERT_FROM_INL.rti_rec_table:= RCV_INSERT_FROM_INL.rti_rec_table();
BEGIN

    --  Initialize return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name    => g_module_name,
        p_procedure_name => l_proc_name
    );

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name,
        p_var_name => 'p_ship_lines_table.COUNT',
        p_var_value => p_ship_lines_table.COUNT
    );

    FOR i IN 1..p_ship_lines_table.COUNT LOOP

        INL_LOGGING_PVT.Log_Variable (
            p_module_name => g_module_name,
            p_procedure_name => l_proc_name,
            p_var_name => 'l_ship_lines_table.EXTEND',
            p_var_value => 'l_ship_lines_table.EXTEND'
        );
        l_ship_lines_table.EXTEND;
        INL_LOGGING_PVT.Log_Variable (
            p_module_name => g_module_name,
            p_procedure_name => l_proc_name,
            p_var_name => 'p_ship_lines_table('||i||').ship_line_num',
            p_var_value => p_ship_lines_table(i).ship_line_num
        );
        l_ship_lines_table(i).ship_line_id             := p_ship_lines_table(i).ship_line_id;
        l_ship_lines_table(i).ship_line_source_id      := p_ship_lines_table(i).ship_line_source_id;
        l_ship_lines_table(i).inventory_item_id        := p_ship_lines_table(i).inventory_item_id;
        l_ship_lines_table(i).txn_qty                  := p_ship_lines_table(i).txn_qty;
        l_ship_lines_table(i).txn_uom_code             := p_ship_lines_table(i).txn_uom_code;
        l_ship_lines_table(i).primary_qty              := p_ship_lines_table(i).primary_qty;
        l_ship_lines_table(i).primary_uom_code         := p_ship_lines_table(i).primary_uom_code;
        l_ship_lines_table(i).secondary_qty            := p_ship_lines_table(i).secondary_qty;      -- Bug 8911750
        l_ship_lines_table(i).secondary_uom_code       := p_ship_lines_table(i).secondary_uom_code; -- Bug 8911750
        l_ship_lines_table(i).currency_code            := p_ship_lines_table(i).currency_code;
        l_ship_lines_table(i).currency_conversion_type := p_ship_lines_table(i).currency_conversion_type;
        l_ship_lines_table(i).currency_conversion_date := p_ship_lines_table(i).currency_conversion_date;
        l_ship_lines_table(i).currency_conversion_rate := p_ship_lines_table(i).currency_conversion_rate;
        l_ship_lines_table(i).party_id                 := p_ship_lines_table(i).party_id;
        l_ship_lines_table(i).party_site_id            := p_ship_lines_table(i).party_site_id;
        l_ship_lines_table(i).src_type_code            := p_ship_lines_table(i).src_type_code;
        l_ship_lines_table(i).ship_line_group_id       := p_ship_lines_table(i).ship_line_group_id;
        l_ship_lines_table(i).organization_id          := p_ship_lines_table(i).organization_id;
        l_ship_lines_table(i).location_id              := p_ship_lines_table(i).location_id;
        l_ship_lines_table(i).org_id                   := p_ship_lines_table(i).org_id;
        l_ship_lines_table(i).item_description         := p_ship_lines_table(i).item_description;
        l_ship_lines_table(i).item                     := p_ship_lines_table(i).item;
        l_ship_lines_table(i).interface_source_code    := p_ship_lines_table(i).interface_source_code;
        l_ship_lines_table(i).interface_source_table   := p_ship_lines_table(i).interface_source_table;
        l_ship_lines_table(i).interface_source_line_id := p_ship_lines_table(i).interface_source_line_id;
        l_ship_lines_table(i).unit_landed_cost         := p_ship_lines_table(i).unit_landed_cost;
		l_ship_lines_table(i).VENDOR_PRODUCT_NUM			:= p_ship_lines_table(i).VENDOR_PRODUCT_NUM;		--Added for bug # 17334902
    END LOOP;

    IF l_ship_lines_table.FIRST IS NOT NULL THEN

        INL_LOGGING_PVT.Log_Statement (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name,
            p_debug_info     => 'Before call RCV_INSERT_FROM_INL.insert_rcv_tables'
        );

        RCV_INSERT_FROM_INL.insert_rcv_tables(
            p_int_rec => l_ship_lines_table,
            p_ship_header_id => p_ship_header_id
        );

        INL_LOGGING_PVT.Log_Statement (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name,
            p_debug_info     => 'After call RCV_INSERT_FROM_INL.insert_rcv_tables'
        );
    END IF;

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name    => g_module_name,
        p_procedure_name => l_proc_name
    );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError(
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name);
        x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError(
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError(
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_proc_name);
        END IF;
END Call_InsertRCV;

-- API name   : Export_ToRCV
-- Type       : Group
-- Function   : Format information based on LCM Shipments
--              and call Call_InsertRCV utility
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version     IN NUMBER,
--              p_init_msg_list   IN VARCHAR2 := FND_API.G_FALSE
--              p_commit          IN VARCHAR2 := FND_API.G_FALSE
--              p_ship_header_id  IN NUMBER
--
-- OUT          x_return_status   OUT NOCOPY VARCHAR2
--              x_msg_count       OUT NOCOPY NUMBER
--              x_msg_data        OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :

PROCEDURE Export_ToRCV (p_api_version    IN NUMBER,
                        p_init_msg_list  IN VARCHAR2 := FND_API.G_FALSE,
                        p_commit         IN VARCHAR2 := FND_API.G_FALSE,
                        p_ship_header_id IN NUMBER,
                        x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count      OUT NOCOPY NUMBER,
                        x_msg_data       OUT NOCOPY VARCHAR2)
IS

    l_api_name         CONSTANT VARCHAR2(30) := 'Export_ToRCV';
    l_api_version      CONSTANT NUMBER := 1.0;
    l_return_status    VARCHAR2(1);
    l_msg_count        NUMBER;
    l_msg_data         VARCHAR2(2000);
    l_ship_lines_table ship_lines_table;

BEGIN

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (p_module_name => g_module_name,
                                   p_procedure_name => l_api_name);

    -- Standard Start of API savepoint
    SAVEPOINT Export_ToRCV_GRP;

    -- Initialize message list IF p_init_msg_list is SET to TRUE.
    IF FND_API.to_Boolean (p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Check FOR call compatibility.
    IF NOT FND_API.Compatible_API_Call (p_current_version_number => l_api_version,
                                        p_caller_version_number => p_api_version,
                                        p_api_name => l_api_name,
                                        p_pkg_name => g_pkg_name) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize API RETURN status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                  p_procedure_name => l_api_name,
                                  p_var_name => 'p_ship_header_id',
                                  p_var_value => p_ship_header_id);

    OPEN c_ship_lines(p_ship_header_id, /*'PO'*/ NULL , NULL);
    FETCH c_ship_lines BULK COLLECT INTO l_ship_lines_table;

    IF l_ship_lines_table.FIRST IS NOT NULL THEN
        INL_LOGGING_PVT.Log_Statement (p_module_name    => g_module_name,
                                       p_procedure_name => l_api_name,
                                       p_debug_info     => 'Before call Call_InsertRCV');

        Call_InsertRCV(p_ship_header_id => p_ship_header_id,
                       p_ship_lines_table => l_ship_lines_table,
                       x_return_status  => l_return_status);

       -- If any errors happen abort the process.
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        INL_LOGGING_PVT.Log_Statement (p_module_name    => g_module_name,
                                       p_procedure_name => l_api_name,
                                       p_debug_info     => 'After call Call_InsertRCV');

        INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                      p_procedure_name => l_api_name,
                                      p_var_name => 'Call_InsertRCV l_return_status:',
                                      p_var_value => l_return_status);
    END IF;

    IF c_ship_lines%ISOPEN THEN
        CLOSE c_ship_lines;
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean (p_commit) THEN
        COMMIT WORK;
    END IF;
    -- Get message count AND IF count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                              p_count => x_msg_count,
                              p_data => x_msg_data) ;
    -- End of Procedure Logging
    INL_LOGGING_PVT.Log_EndProc(p_module_name => g_module_name,
                                p_procedure_name => l_api_name) ;
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
    -- Standard Expected Error Logging
    INL_LOGGING_PVT.Log_ExpecError(p_module_name => g_module_name,
                                   p_procedure_name => l_api_name) ;
    ROLLBACK TO Export_ToRCV_GRP;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                              p_count => x_msg_count,
                              p_data => x_msg_data) ;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError(p_module_name => g_module_name,
                                     p_procedure_name => l_api_name) ;
    ROLLBACK TO Export_ToRCV_GRP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                              p_count => x_msg_count,
                              p_data => x_msg_data) ;
WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError(p_module_name => g_module_name,
                                     p_procedure_name => l_api_name) ;
    ROLLBACK TO Export_ToRCV_GRP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg(p_pkg_name => g_pkg_name,
                                p_procedure_name => l_api_name) ;
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                              p_count => x_msg_count,
                              p_data => x_msg_data) ;
END Export_ToRCV;

-- API name   : Export_ToCST
-- Type       : Group
-- Function   : Controls the creation of Cost Adjustment Transactions
--              to be processed by Inventory/Costing applications.
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version     IN NUMBER,
--              p_init_msg_list   IN VARCHAR2 := FND_API.G_FALSE
--              p_commit          IN VARCHAR2 := FND_API.G_FALSE
--              p_ship_header_id  IN NUMBER
--              p_max_allocation_id  IN NUMBER the previous max allocation id
-- OUT          x_return_status   OUT NOCOPY VARCHAR2
--              x_msg_count       OUT NOCOPY NUMBER
--              x_msg_data        OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Export_ToCST (p_api_version    IN NUMBER,
                        p_init_msg_list  IN VARCHAR2 := FND_API.G_FALSE,
                        p_commit         IN VARCHAR2 := FND_API.G_FALSE,
                        p_ship_header_id IN NUMBER,
                        p_max_allocation_id  IN NUMBER, --Bug#10032820
                        x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count      OUT NOCOPY NUMBER,
                        x_msg_data       OUT NOCOPY VARCHAR2) IS

    CURSOR c_ship_ln_adj IS
      SELECT ish.organization_id,
             isl.ship_line_group_id,
             isl.ship_line_id,
             isl.inventory_item_id,
             isl.parent_ship_line_id,
             isl.ship_line_num,
             rtr.transaction_id
        FROM inl_ship_headers ish,
             inl_ship_lines isl,
             rcv_transactions rtr,
             mtl_parameters mp  --BUG#8933768
       WHERE ish.ship_header_id = isl.ship_header_id
         AND rtr.po_line_location_id = isl.ship_line_source_id
         AND rtr.lcm_shipment_line_id = isl.ship_line_id
         AND rtr.parent_transaction_id = -1
         AND ish.ship_header_id = p_ship_header_id
         AND rtr.organization_id = mp.organization_id    --BUG#8933768
         AND NVL(mp.process_enabled_flag,'N') <> 'Y' --BUG#8933768
    ORDER BY isl.ship_line_num;

    TYPE ship_ln_adj_type IS TABLE OF c_ship_ln_adj%ROWTYPE;
    ship_ln_list ship_ln_adj_type;


/*
    --
    --BUG#8198498
    --
    CURSOR c_islv_ulc (
        pc_adjustment_num NUMBER,
        pc_ship_line_group_id NUMBER,
        pc_ship_line_num  NUMBER) is
        SELECT islv.adjustment_num, islv.unit_landed_cost
        FROM inl_shipln_landed_costs_v islv
        WHERE islv.adjustment_num   <= pc_adjustment_num
        AND islv.ship_header_id     = p_ship_header_id
        AND islv.ship_line_group_id = pc_ship_line_group_id --Bug 7678900
        AND islv.ship_line_num      = pc_ship_line_num
    order by islv.adjustment_num desc
    ;
    r_islv_ulc c_islv_ulc%ROWTYPE;
    --
    --BUG#8198498
    --
*/

    --
    --BUG#10032820
    --

   CURSOR c_shipln_landed_costs_v (
        pc_ship_line_group_id NUMBER,
        pc_ship_line_num  NUMBER
    ) IS
        SELECT ABS(islv.adjustment_num) adjustment_num, islv.unit_landed_cost -- SCM-051
        FROM inl_shipln_landed_costs_v islv,
            (   SELECT  DISTINCT(adjustment_num) adjustment_num
                FROM    inl_allocations
                WHERE   allocation_id > p_max_allocation_id
                AND     ship_header_id = p_ship_header_id
                UNION
                SELECT  MAX(adjustment_num)
                FROM    inl_allocations
                WHERE   allocation_id <= p_max_allocation_id
                AND     ship_header_id = p_ship_header_id
             ) alloc
        WHERE
            islv.ship_header_id     = p_ship_header_id
        AND islv.ship_line_group_id = pc_ship_line_group_id --Bug 7678900
        AND islv.ship_line_num      = pc_ship_line_num
        AND islv.adjustment_num     = alloc.adjustment_num
        ORDER BY ABS(islv.adjustment_num) -- SCM-051
    ;

    TYPE shipln_landed_costs_v_type IS TABLE OF c_shipln_landed_costs_v%ROWTYPE;
    shipln_landed_costs_v_list shipln_landed_costs_v_type;
    --
    --BUG#10032820
    --

    l_api_name CONSTANT VARCHAR2 (30) := 'Export_ToCST';
    l_api_version CONSTANT NUMBER := 1.0;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2 (2000);
    l_debug_info VARCHAR2 (200);
    l_current_date DATE;
    l_prior_landed_cost NUMBER;

BEGIN

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (p_module_name => g_module_name,
                                   p_procedure_name => l_api_name) ;

    -- Standard Start of API savepoint
    SAVEPOINT Export_ToCST_GRP;

    -- Initialize message list IF p_init_msg_list is SET to TRUE.
    IF FND_API.to_Boolean (p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Check FOR call compatibility.
    IF NOT FND_API.Compatible_API_Call (p_current_version_number => l_api_version,
                                        p_caller_version_number => p_api_version,
                                        p_api_name => l_api_name,
                                        p_pkg_name => g_pkg_name) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize API RETURN status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN c_ship_ln_adj;
    FETCH c_ship_ln_adj BULK COLLECT INTO ship_ln_list;
    CLOSE c_ship_ln_adj;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'p_max_allocation_id',
        p_var_value => p_max_allocation_id);


    FOR i IN 1 .. ship_ln_list.COUNT
    LOOP
            INL_LOGGING_PVT.Log_Variable (
                p_module_name => g_module_name,
                p_procedure_name => l_api_name,
                p_var_name => 'p_ship_header_id',
                p_var_value => p_ship_header_id);

            INL_LOGGING_PVT.Log_Variable (
                p_module_name => g_module_name,
                p_procedure_name => l_api_name,
                p_var_name => 'ship_ln_list(i).ship_line_id',
                p_var_value => ship_ln_list(i).ship_line_id);

            INL_LOGGING_PVT.Log_Variable (
                p_module_name => g_module_name,
                p_procedure_name => l_api_name,
                p_var_name => 'ship_ln_list(i).ship_line_group_id',
                p_var_value => ship_ln_list(i).ship_line_group_id);

            INL_LOGGING_PVT.Log_Variable (
                p_module_name => g_module_name,
                p_procedure_name => l_api_name,
                p_var_name => 'ship_ln_list(i).ship_line_num',
                p_var_value => ship_ln_list(i).ship_line_num);

            l_debug_info := 'Get the Prior Unit Landed Cost';
            INL_LOGGING_PVT.Log_Statement (
                p_module_name => g_module_name,
                p_procedure_name => l_api_name,
                p_debug_info => l_debug_info);
            --
            --Bug#10032820
            --

            OPEN c_shipln_landed_costs_v(
                ship_ln_list(i).ship_line_group_id,
                ship_ln_list(i).ship_line_num
            );
            FETCH c_shipln_landed_costs_v BULK COLLECT INTO shipln_landed_costs_v_list;
            CLOSE c_shipln_landed_costs_v;

            IF shipln_landed_costs_v_list.COUNT < 2 THEN
                l_debug_info := 'ERROR Getting the Unit Landed Cost: '||shipln_landed_costs_v_list.COUNT;
                INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                               p_procedure_name => l_api_name,
                                               p_debug_info => l_debug_info);
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            l_prior_landed_cost:= shipln_landed_costs_v_list(1).unit_landed_cost;

            FOR j IN 2 .. shipln_landed_costs_v_list.COUNT
            LOOP
            --
            --Bug#10032820
            --
                INL_LOGGING_PVT.Log_Variable (
                    p_module_name => g_module_name,
                    p_procedure_name => l_api_name,
                    p_var_name => 'l_prior_landed_cost',
                    p_var_value => l_prior_landed_cost
                );
                INL_LOGGING_PVT.Log_Variable (
                    p_module_name => g_module_name,
                    p_procedure_name => l_api_name,
                    p_var_name => 'shipln_landed_costs_v_list(||j||).unit_landed_cost',
                    p_var_value => shipln_landed_costs_v_list(j).unit_landed_cost
                );
                INL_LOGGING_PVT.Log_Variable (
                    p_module_name => g_module_name,
                    p_procedure_name => l_api_name,
                    p_var_name => 'shipln_landed_costs_v_list(||j||).adjustment_num',
                    p_var_value => shipln_landed_costs_v_list(j).adjustment_num
                );

                -- Just INSERT those line which IN some way have had their costs changed
                IF l_prior_landed_cost <> shipln_landed_costs_v_list(j).unit_landed_cost THEN --Bug#10032820
                    l_current_date := SYSDATE;
                    l_debug_info := 'Insert INTO CST_LC_ADJ_INTERFACE TABLE';
                    INL_LOGGING_PVT.Log_Statement (
                        p_module_name => g_module_name,
                        p_procedure_name => l_api_name,
                        p_debug_info => l_debug_info
                    );
                     INSERT INTO cst_lc_adj_interface (
                         transaction_id,                                /* 01 */
                         rcv_transaction_id,                            /* 02 */
                         organization_id,                               /* 03 */
                         inventory_item_id,                             /* 04 */
                         transaction_date,                              /* 05 */
                         prior_landed_cost,                             /* 06 */
                         new_landed_cost,                               /* 07 */
                         process_status,                                /* 08 */
                         process_phase,                                 /* 09 */
                         group_id,                                      /* 10 */
                         creation_date,                                 /* 11 */
                         created_by,                                    /* 12 */
                         last_update_date,                              /* 13 */
                         last_updated_by,                               /* 14 */
                         last_update_login,                             /* 15 */
                         request_id,                                    /* 16 */
                         program_application_id,                        /* 17 */
                         program_id,                                    /* 18 */
                         program_update_date                            /* 19 */
                     ) VALUES (
                         NULL, -- transaction_id                        /* 01 */
                         ship_ln_list(i).transaction_id,                /* 02 */
                         ship_ln_list(i).organization_id,               /* 03 */
                         ship_ln_list(i).inventory_item_id,             /* 04 */
                         l_current_date,                                /* 05 */
                         l_prior_landed_cost,                           /* 06 */
                         shipln_landed_costs_v_list(j).unit_landed_cost,/* 07 */ --Bug#10032820
                         1,    --process_status (1 = Pending)           /* 08 */
                         1,    --process_phase  (1 = Pending)           /* 09 */
                         NULL, -- group_id                              /* 10 */
                         l_current_date, -- creation_date               /* 11 */
                         FND_GLOBAL.user_id, -- created_by              /* 12 */
                         l_current_date, -- last_update_date            /* 13 */
                         FND_GLOBAL.user_id, --last_updated_by          /* 14 */
                         FND_GLOBAL.login_id, --last_update_login       /* 15 */
                         NULL,  --request_id,                           /* 16 */
                         NULL,  --program_application_id,               /* 17 */
                         NULL,  --program_id,                           /* 18 */
                         NULL   --program_update_date                   /* 19 */
                     );
                END IF;
             l_prior_landed_cost:= shipln_landed_costs_v_list(j).unit_landed_cost;--Bug#10032820
        END LOOP;
    END LOOP;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean (p_commit) THEN
        COMMIT WORK;
    END IF;
    -- Get message count AND IF count is 1, get message info.
    FND_MSG_PUB.Count_And_Get (
        p_encoded => FND_API.g_false,
        p_count => x_msg_count,
        p_data => x_msg_data
    ) ;
    -- End of Procedure Logging
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name
    ) ;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
    -- Standard Expected Error Logging
    INL_LOGGING_PVT.Log_ExpecError ( p_module_name => g_module_name,
                                     p_procedure_name => l_api_name) ;
    ROLLBACK TO Export_ToCST_GRP;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_encoded => FND_API.g_false,
                                p_count => x_msg_count,
                                p_data => x_msg_data) ;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError ( p_module_name => g_module_name,
                                       p_procedure_name => l_api_name) ;
    ROLLBACK TO Export_ToCST_GRP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_encoded => FND_API.g_false,
                                p_count => x_msg_count,
                                p_data => x_msg_data) ;
WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError ( p_module_name => g_module_name,
                                       p_procedure_name => l_api_name) ;
    ROLLBACK TO Export_ToCST_GRP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg ( p_pkg_name => g_pkg_name,
                                  p_procedure_name => l_api_name) ;
    END IF;
    FND_MSG_PUB.Count_And_Get ( p_encoded => FND_API.g_false,
                                p_count => x_msg_count,
                                p_data => x_msg_data) ;
END Export_ToCST;



-- API name   : Get_CurrencyInfo
-- Type       : Group
-- Function   :
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version                IN NUMBER           Required
--              p_init_msg_list              IN VARCHAR2         Optional  Default = FND_API.G_FALSE
--              p_commit                     IN VARCHAR2         Optional  Default = FND_API.G_FALSE
--              p_ship_line_id               IN NUMBER           Required
--
-- OUT        : x_return_status              OUT NOCOPY VARCHAR2
--              x_msg_count                  OUT NOCOPY NUMBER
--              x_msg_data                   OUT NOCOPY VARCHAR2
--              x_currency_code              OUT NOCOPY VARCHAR2
--              x_currency_conversion_type   OUT NOCOPY VARCHAR2
--              x_currency_conversion_date   OUT NOCOPY DATE
--              x_currency_conversion_rate   OUT NOCOPY NUMBER
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Get_CurrencyInfo(
    p_api_version                IN NUMBER,
    p_init_msg_list              IN VARCHAR2 := FND_API.G_FALSE,
    p_commit                     IN VARCHAR2 := FND_API.G_FALSE,
    p_ship_line_id               IN NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,
    x_currency_code              OUT NOCOPY VARCHAR2,
    x_currency_conversion_type   OUT NOCOPY VARCHAR2,
    x_currency_conversion_date   OUT NOCOPY DATE,
    x_currency_conversion_rate   OUT NOCOPY NUMBER
) IS

  l_api_name              CONSTANT VARCHAR2(30) := 'Get_CurrencyInfo';
  l_api_version           CONSTANT NUMBER := 1.0;

  l_return_status         VARCHAR2(1);
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(2000);
  l_debug_info            VARCHAR2(200);
BEGIN

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name    => g_module_name,
        p_procedure_name => l_api_name
    );
    -- Standard Start of API savepoint
    SAVEPOINT Get_CurrencyInfo_GRP;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
        l_api_version,
        p_api_version,
        l_api_name,
        g_pkg_name)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Api Body

    -- Standard Statement Level Procedure/Function Logging
    l_debug_info := 'Get currency info for the ship_line_id: ' || p_ship_line_id;
    INL_LOGGING_PVT.Log_Statement (
        p_module_name    => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info     => l_debug_info
    );

    SELECT
        sl.currency_code,
        sl.currency_conversion_type,
        nvl(sl.currency_conversion_date,sl.creation_date),
        sl.currency_conversion_rate
    INTO
        x_currency_code,
        x_currency_conversion_type,
        x_currency_conversion_date,
        x_currency_conversion_rate
    FROM inl_ship_lines_all sl
    WHERE sl.ship_line_id = p_ship_line_id;

    -- End of Api Body

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data);

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name    => g_module_name,
        p_procedure_name => l_api_name);
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    -- Standard Expected Error Logging
    INL_LOGGING_PVT.Log_ExpecError (
        p_module_name    => g_module_name,
        p_procedure_name => l_api_name
    );
    ROLLBACK TO Get_CurrencyInfo_GRP;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name    => g_module_name,
        p_procedure_name => l_api_name);
    ROLLBACK TO Get_CurrencyInfo_GRP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data);
  WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name    => g_module_name,
        p_procedure_name => l_api_name);
    ROLLBACK TO Get_CurrencyInfo_GRP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg(
        g_pkg_name,
        l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data);
END Get_CurrencyInfo;

-- Fucntion Nm: Get_ExtPrecFormatMask Bug#9109573
-- Type       : Group
-- Function   : Currently the packages FND_CURRENCY and FND_CURRENCY_CACHE don't return the extended precision mask
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_currency_code              IN VARCHAR2
--              p_field_length               IN NUMBER
--
-- Version    : Current version 1.0
--
-- Notes      :

function Get_ExtPrecFormatMask(
    p_currency_code   IN VARCHAR2,
    p_field_length    IN NUMBER
)
    return VARCHAR2
is

begin

    /* Check whether field_length exceeds maximum length of return_mask
       or if currency_code is NULL. */
    if(p_field_length > 100) OR (p_currency_code is NULL) then
       return NULL;
    end if;

    IF NVL(g_currency_code,'1234567890123456') <> p_currency_code
        OR g_field_length <> p_field_length
    THEN

        g_currency_code := p_currency_code;
        g_field_length  := p_field_length;
        /* Get the precision information for a currency code */
        FND_CURRENCY.GET_INFO(
            currency_code => g_currency_code  ,
            precision     => g_precision,
            ext_precision => g_ext_precision,
            min_acct_unit => g_min_acct_unit);

        /* Create the format mask for the given currency value */
        FND_CURRENCY.BUILD_FORMAT_MASK(
            format_mask   => g_return_mask,
            field_length  => g_field_length,
            precision     => g_ext_precision,
            min_acct_unit => g_min_acct_unit);
    END IF;
    return g_return_mask;
END;

--=======================================
--Bug#9279355 - DEV1213: GTM-SCM-012 SUPPORT TO LC CALCULATION IN PURCHASING
--=======================================

-- Utility   : Import_FromPO
-- Type       : Group
-- Function   : Import from PO to LTI tables
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_po_hdr_rec IN po_hdr_rec
--
-- OUT        : x_return_status OUT NOCOPY VARCHAR2
--              x_msg_count OUT NOCOPY NUMBER
--              x_msg_data OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Import_FromPO(p_po_hdr_rec IN po_hdr_rec,
                        p_simulation_rec IN INL_SIMULATION_PVT.simulation_rec,
                        x_return_status OUT NOCOPY VARCHAR2,
                        x_msg_count OUT NOCOPY NUMBER,
                        x_msg_data OUT NOCOPY VARCHAR2) IS

    l_proc_name CONSTANT VARCHAR2(30) := 'Import_FromPO';
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);
    l_api_version CONSTANT NUMBER := 1.0;
    l_debug_msg VARCHAR2(400);
    l_ship_type_id NUMBER;
    l_ship_line_type_id NUMBER;
    l_lci_table lci_table;
    l_ind_lci NUMBER := 1;
    l_ship_to_location_id NUMBER;
    l_ship_to_organization_id NUMBER;
    l_ship_to_org_name VARCHAR2(240);
    l_ship_to_location_code VARCHAR2(240);
    l_user_defined_ship_num_code VARCHAR2(25);
    l_sec_unit_price NUMBER;
    l_sec_uom_code VARCHAR2(25);
    l_sec_qty NUMBER;
    l_taxation_country VARCHAR2(2);
    l_organization_id NUMBER;
    l_location_id NUMBER;
    l_req_id NUMBER := 0;
    l_shipments_processed NUMBER := 0;
    l_last_task_code VARCHAR2(5);
    l_party_id NUMBER;
    l_party_site_id NUMBER;
    l_sequence NUMBER := 1;
    l_current_organization_id NUMBER;
    l_current_location_id NUMBER;
    l_ship_num VARCHAR2(25);
    l_landed_cost_flag VARCHAR2(1);
    l_allocation_enabled_flag VARCHAR2(1);

    CURSOR c_pll (p_po_header_id NUMBER,
                  p_po_release_id NUMBER, -- Bug 14280113
                  p_vendor_id NUMBER,
                  p_vendor_site_id NUMBER)IS
    SELECT
        pl.po_line_id,
        pl.item_id,
        pl.item_revision,
        pl.category_id,
        pl.unit_price,
        pl.quantity pl_quantity,
        pl.amount pl_amount,
        pl.secondary_uom,
        pl.secondary_unit_of_measure,
        pl.secondary_qty,
        pl.line_num,
        pl.item_description,
        pll.secondary_quantity,
        pll.line_location_id,
        INL_SHIPMENT_PVT.Get_SrcAvailableQty('PO', pll.line_location_id) quantity,
        pll.unit_meas_lookup_code,
        pll.po_release_id,
        pll.ship_to_location_id,
        pll.ship_to_organization_id,
        ph.bill_to_location_id,
        pll.shipment_num,
        pll.org_id,
        pll.match_option,
        pll.amount,
        pll.value_basis,
        pll.matching_basis,
        'Y' lcm_flag
    FROM po_headers_all ph,
         po_lines_all pl,
         po_line_locations_all pll,
         po_releases_all pr -- Bug 9734841
    WHERE ph.po_header_id = p_po_header_id
      AND pl.po_header_id = ph.po_header_id
      AND pll.po_line_id = pl.po_line_id
      AND NVL(pll.po_release_id, -999) = NVL(p_po_release_id, -999) -- Bug 14280113
      AND pll.po_release_id = pr.po_release_id (+)
      AND NVL(pr.approved_flag, 'N') <> 'Y'
      AND NVL(pl.cancel_flag,'N') = 'N'
      AND NVL(pll.cancel_flag, 'N') = 'N'
      AND DECODE(ph.type_lookup_code, 'PLANNED', 'SCHEDULED', pll.shipment_type) = pll.shipment_type -- Bug 9746741
      AND INV_UTILITIES.inv_check_lcm(pl.item_id,
                pll.ship_to_organization_id,
                NULL,
                NULL,
                p_vendor_id,
                p_vendor_site_id) = 'Y'
      -- Debug 13064637 pick PO details based on the profile option set
      AND DECODE(FND_PROFILE.VALUE('RCV_CLOSED_PO_DEFAULT_OPTION'),'N',NVL(pll.closed_code,'OPEN'), 'OPEN') NOT IN ('CLOSED','CLOSED FOR RECEIVING')
    ORDER BY pll.ship_to_organization_id,
        pll.ship_to_location_id,
        pl.line_num,
        pll.line_location_id;

    TYPE c_pll_tp IS TABLE OF c_pll%ROWTYPE;
    c_pll_tab c_pll_tp;

BEGIN

    --  Initialize return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (p_module_name => g_module_name,
                                  p_procedure_name => l_proc_name);

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name,
        p_var_name => 'p_po_hdr_rec.po_header_id',
        p_var_value => p_po_hdr_rec.po_header_id);

    -- Verifying: the INL: Default Type for Simulated Shipment profile must be setup
    l_ship_type_id := NVL(FND_PROFILE.VALUE('INL_SHIP_TYPE_ID_OI'),0);

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name,
        p_var_name => 'l_ship_type_id',
        p_var_value => l_ship_type_id );

    IF l_ship_type_id IS NULL OR l_ship_type_id = 0 THEN
        FND_MESSAGE.SET_NAME ('INL', 'INL_ERR_CHK_SHIP_TYP_PROF') ;
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name,
        p_debug_info => 'Get value to INL_SHIP_LINE_TYPE_ID');

    BEGIN
        IF l_ship_line_type_id IS NULL THEN
            SELECT ialw.ship_line_type_id,
                   islt.dflt_landed_cost_flag,
                   islt.dflt_allocation_enabled_flag
              INTO l_ship_line_type_id,
                   l_landed_cost_flag,
                   l_allocation_enabled_flag
              FROM inl_alwd_line_types ialw,
                   inl_ship_line_types_b islt -- Bug 9814077
             WHERE ialw.parent_table_name = 'INL_SHIP_TYPES'
               AND ialw.parent_table_id = l_ship_type_id
               AND ialw.dflt_ship_line_type_flag = 'Y'
               AND ialw.ship_line_type_id = islt.ship_line_type_id;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            l_ship_line_type_id := NULL;
    END;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name,
        p_var_name => 'l_ship_line_type_id',
        p_var_value => l_ship_line_type_id);

    -- The Shipment Line Type should be defined for the Shipment Type
    IF l_ship_line_type_id IS NULL THEN
        FND_MESSAGE.SET_NAME ('INL', 'INL_ERR_NO_SHIP_LN_DEF') ;
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Get last task code from INL_CUSTOM_PUB.Get_LastTaskCodeForSimul
    l_last_task_code := INL_CUSTOM_PUB.Get_LastTaskCodeForSimul;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name,
        p_var_name => 'l_last_task_code',
        p_var_value => l_last_task_code );

    IF l_last_task_code IS NULL OR l_last_task_code NOT IN('10','20','30','40','50','60') THEN
        FND_MESSAGE.SET_NAME ('INL', 'INL_ERR_CHK_LAST_TASK_CODE') ;
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name,
        p_debug_info => 'Get PO Lines info');

    -- If any errors happen abort the process.
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name,
        p_debug_info => 'Get Party ID');

    -- Get Party Id
    SELECT pv.party_id
    INTO l_party_id
    FROM po_vendors pv
    WHERE pv.vendor_id = p_po_hdr_rec.vendor_id;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name,
        p_var_name => 'l_party_id',
        p_var_value => l_party_id);

    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name,
        p_debug_info => 'Get Party Site ID');

    -- Get Party Site Id
    SELECT pv.party_site_id
    INTO l_party_site_id
    FROM po_vendor_sites_all pv
    WHERE pv.vendor_site_id = p_po_hdr_rec.vendor_site_id;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name,
        p_var_name => 'l_party_site_id',
        p_var_value => l_party_site_id);

    -- Open Po Line Locations cursor
    OPEN c_pll (p_po_hdr_rec.po_header_id,
                p_po_hdr_rec.po_release_id, -- Bug 14280113
                p_po_hdr_rec.vendor_id,
                p_po_hdr_rec.vendor_site_id);
    FETCH c_pll  BULK COLLECT INTO c_pll_tab;
    CLOSE c_pll;

    IF c_pll_tab.COUNT IS NOT NULL THEN

        l_current_organization_id := -9999;
        l_current_location_id := - 9999;

        FOR i IN 1..c_pll_tab.COUNT
        LOOP
            g_records_processed := g_records_processed + 1;
            g_lines_processed := g_lines_processed ||
                                 '// Line Number: ' || c_pll_tab(i).line_num || '  LCM Flag: ' || c_pll_tab(i).lcm_flag;

            IF c_pll_tab(i).lcm_flag = 'Y'  THEN
                g_records_inserted := g_records_inserted + 1;
                g_lines_inserted := g_lines_inserted ||
                                    '// Line Number: ' || c_pll_tab(i).line_num || '  LCM Flag: ' || c_pll_tab(i).lcm_flag;

                -- By now keep in shipment_header_id the po_header_id
                l_lci_table(l_ind_lci).shipment_header_id            := p_po_hdr_rec.po_header_id;
                l_lci_table(l_ind_lci).transaction_type              := 'CREATE';
                l_lci_table(l_ind_lci).processing_status_code        := 'PENDING';
                l_lci_table(l_ind_lci).interface_source_code         := 'PO';
                l_lci_table(l_ind_lci).hdr_interface_source_table    := 'PO_HEADERS';
                l_lci_table(l_ind_lci).validation_flag               := 'N';
                l_lci_table(l_ind_lci).rcv_enabled_flag              := 'N';
                l_lci_table(l_ind_lci).last_task_code                := l_last_task_code;
                l_lci_table(l_ind_lci).processing_status_code        := 'PENDING';
                l_lci_table(l_ind_lci).validation_flag               := 'N';

        l_lci_table(l_ind_lci).landed_cost_flag              := l_landed_cost_flag; -- Bug 9814077
                l_lci_table(l_ind_lci).allocation_enabled_flag       := l_allocation_enabled_flag; -- Bug 9814077

        l_lci_table(l_ind_lci).line_interface_source_table   := 'PO_LINE_LOCATIONS';
                l_lci_table(l_ind_lci).ship_line_src_type_code       := 'PO';

                l_lci_table(l_ind_lci).ship_date                     := NVL(p_po_hdr_rec.approved_date,SYSDATE);
                l_lci_table(l_ind_lci).ship_type_id                  := l_ship_type_id;
                l_lci_table(l_ind_lci).ship_line_group_reference     := p_po_hdr_rec.segment1;
                l_lci_table(l_ind_lci).currency_code                 := p_po_hdr_rec.currency_code;
                l_lci_table(l_ind_lci).currency_conversion_type      := p_po_hdr_rec.rate_type;
                l_lci_table(l_ind_lci).currency_conversion_date      := p_po_hdr_rec.rate_date;
                l_lci_table(l_ind_lci).currency_conversion_rate      := p_po_hdr_rec.rate;
                l_ship_to_organization_id                            := c_pll_tab(i).ship_to_organization_id;
                l_ship_to_location_id                                := c_pll_tab(i).ship_to_location_id;
                l_lci_table(l_ind_lci).ship_to_organization_id       := l_ship_to_organization_id;
                l_lci_table(l_ind_lci).ship_to_location_id           := l_ship_to_location_id;
                l_lci_table(l_ind_lci).organization_id               := l_ship_to_organization_id;
                l_lci_table(l_ind_lci).location_id                   := l_ship_to_location_id;
                l_lci_table(l_ind_lci).hdr_interface_source_line_id  := p_po_hdr_rec.po_header_id;
                l_lci_table(l_ind_lci).ship_line_source_id           := c_pll_tab(i).line_location_id;
                l_lci_table(l_ind_lci).inventory_item_id             := c_pll_tab(i).item_id;
                l_lci_table(l_ind_lci).txn_qty                       := c_pll_tab(i).quantity;
                l_lci_table(l_ind_lci).txn_unit_price                := c_pll_tab(i).unit_price;
                l_lci_table(l_ind_lci).line_interface_source_line_id := c_pll_tab(i).line_location_id;
                l_lci_table(l_ind_lci).ship_line_type_id             := l_ship_line_type_id;

                INL_LOGGING_PVT.Log_Variable (
                    p_module_name => g_module_name,
                    p_procedure_name => l_proc_name,
                    p_var_name => 'l_ship_to_organization_id',
                    p_var_value => l_ship_to_organization_id);

                INL_LOGGING_PVT.Log_Variable (
                    p_module_name => g_module_name,
                    p_procedure_name => l_proc_name,
                    p_var_name => 'l_ship_to_location_id',
                    p_var_value => l_ship_to_location_id);

                IF l_location_id IS NULL OR
                    l_location_id <> l_ship_to_location_id THEN

                    INL_LOGGING_PVT.Log_Statement (
                          p_module_name => g_module_name,
                          p_procedure_name => l_proc_name,
                          p_debug_info => 'Get Location Code and Taxation Country');

                    SELECT hl.location_code,
                           hl.country
                    INTO l_ship_to_location_code,
                         l_taxation_country
                    FROM  hr_locations hl
                    WHERE hl.location_id = l_ship_to_location_id
                    AND hl.receiving_site_flag = 'Y';

                    l_location_id := l_ship_to_location_id;

                END IF;

                IF l_organization_id IS NULL OR
                    l_organization_id <> l_ship_to_organization_id THEN

                    INL_LOGGING_PVT.Log_Statement (
                        p_module_name => g_module_name,
                        p_procedure_name => l_proc_name,
                        p_debug_info => 'Check if the Ship To Organization has been setup in LCM Options');

                    BEGIN
                        SELECT NVL(user_defined_ship_num_code,'AUTOMATIC')
                        INTO l_user_defined_ship_num_code
                        FROM inl_parameters ipa
                        WHERE ipa.organization_id = l_ship_to_organization_id;
                   EXCEPTION
                    -- Check whether the current organization has
                    -- been defined in LCM Parameters.
                        WHEN OTHERS THEN
                            INL_LOGGING_PVT.Log_Statement (
                                p_module_name => g_module_name,
                                p_procedure_name => l_proc_name,
                                p_debug_info => 'Ship To Organization has not been setup in LCM Options');
                            FND_MESSAGE.SET_NAME ('INL', 'INL_ERR_NO_LCM_OPT_DEF_ORG') ;
                            FND_MESSAGE.SET_TOKEN ('INV_ORG_NAME', l_ship_to_location_code);
                            FND_MSG_PUB.ADD;
                            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    END;

                    l_organization_id := l_ship_to_organization_id;

                END IF;

                INL_LOGGING_PVT.Log_Variable (
                    p_module_name => g_module_name,
                    p_procedure_name => l_proc_name,
                    p_var_name => 'l_ship_to_location_code',
                    p_var_value => l_ship_to_location_code);

                INL_LOGGING_PVT.Log_Variable (
                    p_module_name => g_module_name,
                    p_procedure_name => l_proc_name,
                    p_var_name => 'l_taxation_country',
                    p_var_value => l_taxation_country);

                INL_LOGGING_PVT.Log_Variable (
                    p_module_name => g_module_name,
                    p_procedure_name => l_proc_name,
                    p_var_name => 'l_user_defined_ship_num_code',
                    p_var_value => l_user_defined_ship_num_code);

                IF ((l_current_organization_id <> c_pll_tab(i).ship_to_organization_id OR
                    l_current_location_id <> c_pll_tab(i).ship_to_location_id)) THEN

                    INL_LOGGING_PVT.Log_Statement (
                        p_module_name => g_module_name,
                        p_procedure_name => l_proc_name,
                        p_debug_info => 'Get Shipment Number from INL_CUSTOM_PUB.Get_SimulShipNum');

                    INL_CUSTOM_PUB.Get_SimulShipNum(
                                    p_simulation_rec => p_simulation_rec,
                                    p_document_number => p_po_hdr_rec.segment1,
                                    p_organization_id => c_pll_tab(i).ship_to_organization_id,
                                    p_sequence => l_sequence,
                                    x_ship_num => l_ship_num,
                                    x_return_status => l_return_status);

                    -- If any errors happen abort the process.
                    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                        RAISE FND_API.G_EXC_ERROR;
                    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;

                    l_sequence := l_sequence + 1;
                END IF;

                l_lci_table(l_ind_lci).ship_num := l_ship_num;

                -- Taxation country cannot be null, otherwise there is no way to
                -- validate Third Party Sites Allowed
                IF l_taxation_country IS NULL THEN
                    FND_MESSAGE.SET_NAME ('INL', 'INL_ERR_LOC_COUNTRY_NULL') ;
                    FND_MESSAGE.SET_TOKEN ('LOCATION_CODE', l_ship_to_location_code) ;
                    FND_MSG_PUB.ADD;
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;

                -- Get the UOM Code
                SELECT uom_code
                INTO l_lci_table(l_ind_lci).txn_uom_code
                FROM mtl_units_of_measure
                WHERE unit_of_measure = c_pll_tab(i).unit_meas_lookup_code;

                l_sec_unit_price := NULL;
                l_sec_uom_code := NULL;
                l_sec_qty := NULL;

                -- If secondary quantity is null, the uom code should be null
                IF c_pll_tab(i).secondary_qty IS NULL AND
                   c_pll_tab(i).secondary_quantity IS NULL THEN
                    l_sec_uom_code := NULL;
                ELSE
                    l_sec_qty := NVL(c_pll_tab(i).secondary_qty, c_pll_tab(i).secondary_quantity);
                    l_sec_uom_code := c_pll_tab(i).secondary_uom;
                    IF l_sec_uom_code IS NULL AND
                        c_pll_tab(i).secondary_unit_of_measure IS NOT NULL THEN

                        INL_LOGGING_PVT.Log_Statement (
                            p_module_name => g_module_name,
                            p_procedure_name => l_proc_name,
                            p_debug_info => 'Get secondary_uom_code from secondary_unit_of_measure');

                        SELECT mum.uom_code
                        INTO l_sec_uom_code
                        FROM mtl_units_of_measure mum
                        WHERE mum.unit_of_measure = c_pll_tab(i).secondary_unit_of_measure;
                    END IF;

                     l_sec_unit_price := (c_pll_tab(i).quantity * c_pll_tab(i).unit_price) / l_sec_qty;
                END IF;

                l_lci_table(l_ind_lci).secondary_qty := l_sec_qty;
                l_lci_table(l_ind_lci).secondary_uom_code := l_sec_uom_code;
                l_lci_table(l_ind_lci).secondary_unit_price := l_sec_unit_price;

                INL_LOGGING_PVT.Log_Statement (
                    p_module_name => g_module_name,
                    p_procedure_name => l_proc_name,
                    p_debug_info => 'Get data from zx lines');

                SELECT zdf.trx_business_category,
                    zdf.line_intended_use,
                    zdf.product_fisc_classification,
                    zdf.product_category,
                    zdf.product_type,
                    zdf.user_defined_fisc_class,
                    zdf.output_tax_classification_code
                INTO l_lci_table(l_ind_lci).trx_business_category ,
                    l_lci_table(l_ind_lci).intended_use,
                    l_lci_table(l_ind_lci).product_fiscal_class,
                    l_lci_table(l_ind_lci).product_category,
                    l_lci_table(l_ind_lci).product_type,
                    l_lci_table(l_ind_lci).user_def_fiscal_class,
                    l_lci_table(l_ind_lci).tax_classification_code
                FROM zx_lines_det_factors zdf,
                    po_line_locations_all pll
                WHERE pll.line_location_id = c_pll_tab(i).line_location_id
                AND zdf.application_id = 201
                AND zdf.trx_id = NVL(pll.po_release_id,pll.po_header_id)
                AND zdf.trx_line_id = pll.line_location_id
                AND zdf.entity_code = DECODE(pll.po_release_id,NULL,'PURCHASE_ORDER','RELEASE')
                AND zdf.event_class_code = DECODE(pll.po_release_id,NULL,'PO_PA','RELEASE');

                l_lci_table(l_ind_lci).taxation_country := l_taxation_country;
                l_lci_table(l_ind_lci).party_id := l_party_id;
                l_lci_table(l_ind_lci).party_site_id := l_party_site_id;
                l_lci_table(l_ind_lci).ship_from_party_id := l_party_id;
                l_lci_table(l_ind_lci).ship_from_party_site_id := l_party_site_id;
                l_lci_table(l_ind_lci).ship_to_organization_id := l_ship_to_organization_id;
                l_lci_table(l_ind_lci).ship_to_location_id := l_ship_to_location_id;
                l_lci_table(l_ind_lci).bill_from_party_id := l_party_id;
                l_lci_table(l_ind_lci).bill_from_party_site_id := l_party_site_id;
                l_lci_table(l_ind_lci).bill_to_organization_id := l_ship_to_organization_id;
                l_lci_table(l_ind_lci).bill_to_location_id := c_pll_tab(i).bill_to_location_id;
                l_lci_table(l_ind_lci).poa_party_id := l_party_id;
                l_lci_table(l_ind_lci).poa_party_site_id := l_party_site_id;
                l_lci_table(l_ind_lci).poo_organization_id := l_ship_to_organization_id;
                l_lci_table(l_ind_lci).poo_location_id := l_ship_to_location_id;
                l_ind_lci := l_ind_lci + 1;

                l_current_organization_id:= c_pll_tab(i).ship_to_organization_id;
                l_current_location_id := c_pll_tab(i).ship_to_location_id;

            END IF;
        END LOOP;

        INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                      p_procedure_name => l_proc_name,
                                      p_var_name => 'l_lci_table.COUNT',
                                      p_var_value => l_lci_table.COUNT);

        IF l_lci_table.COUNT > 0 THEN

            INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_proc_name,
            p_debug_info => 'Call Insert_LCMInterface to insert data in lcm interface table');

            INL_INTEGRATION_GRP.Insert_LCMInterface(p_api_version => 1.0,
                                                    p_init_msg_list => FND_API.G_FALSE,
                                                    p_commit => FND_API.G_FALSE,
                                                    p_lci_table  => l_lci_table,
                                                    x_return_status => l_return_status,
                                                    x_msg_count => l_msg_count,
                                                    x_msg_data => l_msg_data);

            -- If any errors happen abort the process.
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            l_ind_lci := 1;

            FOR i IN 1 .. l_lci_table.COUNT LOOP
                IF l_lci_table(l_ind_lci).group_id IS NOT NULL THEN
                    l_shipments_processed := NVL(l_shipments_processed, 0) + 1;

                    INL_LOGGING_PVT.Log_Statement (
                            p_module_name => g_module_name,
                            p_procedure_name => l_proc_name,
                            p_debug_info => 'Call INL_INTERFACE_PVT.Import_LCMShipments with group_id: ' || l_lci_table(l_ind_lci).group_id );

                    INL_INTERFACE_PVT.Import_LCMShipments (p_api_version => 1.0,
                                                           p_init_msg_list => FND_API.G_FALSE,
                                                           p_commit => FND_API.G_FALSE,
                                                           p_group_id => l_lci_table(l_ind_lci).group_id,
                                                           p_simulation_id => p_po_hdr_rec.simulation_id,
                                                           x_return_status => l_return_status,
                                                           x_msg_count => l_msg_count,
                                                           x_msg_data => l_msg_data);

                    -- If any errors happen abort the process.
                    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                        RAISE FND_API.G_EXC_ERROR;
                    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;
                END IF;
                l_ind_lci := l_ind_lci + 1;
            END LOOP;
        END IF;
    END IF;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name,
        p_var_name => 'g_records_processed',
         p_var_value => g_records_processed);

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name,
        p_var_name => 'g_records_inserted',
         p_var_value => g_records_inserted);

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc (p_module_name => g_module_name,
                                 p_procedure_name => l_proc_name);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name);
        x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(
              p_pkg_name       => g_pkg_name,
              p_procedure_name => l_proc_name);
        END IF;
END Import_FromPO;

-- Bug #9279355
-- API name : Create_POSimulation
-- Type       : Group
-- Function   : Create PO Simulation from a given po_header_id
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version IN NUMBER,
--              p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE
--              p_commit  IN VARCHAR2 := FND_API.G_FALSE
--              p_po_header_id  IN  NUMBER
--               p_po_release_id IN NUMBER
--
-- OUT          x_return_status OUT NOCOPY VARCHAR2
--              x_msg_count OUT NOCOPY NUMBER
--              x_msg_data OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Create_POSimulation(
    p_api_version   IN NUMBER,
    p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
    p_commit        IN VARCHAR2 := FND_API.G_FALSE,
    p_po_header_id  IN  NUMBER,
    p_po_release_id IN NUMBER, -- Bug 14280113
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2) IS

    l_api_name CONSTANT VARCHAR2(30) := 'Create_POSimulation';
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);
    l_api_version CONSTANT NUMBER := 1.0;
    l_simulation_rec INL_SIMULATION_PVT.simulation_rec;
    l_po_hdr_rec po_hdr_rec;
    l_debug_msg VARCHAR2(400);
    l_debug_info VARCHAR2(400);

BEGIN

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(p_module_name => g_module_name,
                                  p_procedure_name => l_api_name) ;

    -- Standard Start of API savepoint
    SAVEPOINT Create_POSimulation_GRP;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(p_current_version_number => l_api_version,
                                       p_caller_version_number => p_api_version,
                                       p_api_name => l_api_name,
                                       p_pkg_name => g_pkg_name ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                  p_procedure_name => l_api_name,
                                  p_var_name => 'p_po_header_id',
                                  p_var_value => p_po_header_id);

    -- Bug 14280113
    INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                  p_procedure_name => l_api_name,
                                  p_var_name => 'p_po_release_id',
                                  p_var_value => p_po_release_id);


    IF p_po_release_id IS NOT NULL THEN -- Bug 14280113

      l_simulation_rec.parent_table_name := 'PO_RELEASES';
      l_simulation_rec.parent_table_id := p_po_release_id;

      INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                     p_procedure_name => l_api_name,
                                     p_debug_info => 'Get data from PO RELEASES');
      SELECT ph.segment1,       -- 01
             ph.vendor_id,      -- 02
             ph.vendor_site_id, -- 03
             pr.revision_num,   -- 04
             ph.currency_code,  -- 05
             ph.rate_type,      -- 06
             ph.rate_date,      -- 07
             ph.rate,           -- 08
             ph.org_id,         -- 09
             ph.approved_date,  -- 10
             ph.ship_via_lookup_code freight_code,  -- 11
             ph.org_id          -- 12

      INTO   l_po_hdr_rec.segment1,                -- 01
             l_simulation_rec.vendor_id,           -- 02
             l_simulation_rec.vendor_site_id,      -- 03
             l_simulation_rec.parent_table_revision_num, -- 04
             l_po_hdr_rec.currency_code,           -- 05
             l_po_hdr_rec.rate_type,               -- 06
             l_po_hdr_rec.rate_date,               -- 07
             l_po_hdr_rec.rate,                    -- 08
             l_po_hdr_rec.org_id,                  -- 09
             l_po_hdr_rec.approved_date,           -- 10
             l_simulation_rec.freight_code,        -- 11
             l_simulation_rec.org_id               -- 12
      FROM po_headers_all ph,
           po_releases_all pr
      WHERE ph.po_header_id = pr.po_header_id
      AND pr.po_release_id = p_po_release_id;

    ELSE

      l_simulation_rec.parent_table_name := 'PO_HEADERS';
      l_simulation_rec.parent_table_id := p_po_header_id;



        INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                       p_procedure_name => l_api_name,
                                      p_debug_info => 'Get data from PO HEADERS');

        SELECT ph.po_header_id,   -- 01
               ph.segment1,       -- 02
               ph.vendor_id,      -- 03
               ph.vendor_site_id, -- 04
               ph.revision_num,   -- 05
               ph.currency_code,  -- 06
               ph.rate_type,      -- 07
               ph.rate_date,      -- 08
               ph.rate,           -- 09
               ph.org_id,         -- 10
               ph.approved_date,  -- 11
               ph.ship_via_lookup_code freight_code,  -- 12
               ph.org_id          -- 13

        INTO   l_simulation_rec.parent_table_id,     -- 01
               l_po_hdr_rec.segment1,                -- 02
               l_simulation_rec.vendor_id,           -- 03
               l_simulation_rec.vendor_site_id,      -- 04
               l_simulation_rec.parent_table_revision_num, -- 05
               l_po_hdr_rec.currency_code,           -- 06
               l_po_hdr_rec.rate_type,               -- 07
               l_po_hdr_rec.rate_date,               -- 08
               l_po_hdr_rec.rate,                    -- 09
               l_po_hdr_rec.org_id,                  -- 10
               l_po_hdr_rec.approved_date,           -- 11
               l_simulation_rec.freight_code,        -- 12
               l_simulation_rec.org_id               -- 13
        FROM po_headers_all ph
        WHERE po_header_id = p_po_header_id;
    END IF;

    INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                  p_procedure_name => l_api_name,
                                  p_var_name => 'l_simulation_rec.parent_table_id',
                                  p_var_value => l_simulation_rec.parent_table_id);

    INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                  p_procedure_name => l_api_name,
                                  p_var_name => 'l_simulation_rec.vendor_id',
                                  p_var_value => l_simulation_rec.vendor_id);

    INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                  p_procedure_name => l_api_name,
                                  p_var_name => 'l_simulation_rec.vendor_site_id',
                                  p_var_value => l_simulation_rec.vendor_site_id);

    INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                  p_procedure_name => l_api_name,
                                  p_var_name => 'l_simulation_rec.parent_table_revision_num',
                                  p_var_value => l_simulation_rec.parent_table_revision_num);

    INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                  p_procedure_name => l_api_name,
                                  p_var_name => 'l_simulation_rec.freight_code',
                                  p_var_value => l_simulation_rec.freight_code);

    INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                  p_procedure_name => l_api_name,
                                  p_var_name => 'l_po_hdr_rec.segment1',
                                  p_var_value => l_po_hdr_rec.segment1);

    INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                  p_procedure_name => l_api_name,
                                  p_var_name => 'l_po_hdr_rec.currency_code',
                                  p_var_value => l_po_hdr_rec.currency_code);

    INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                  p_procedure_name => l_api_name,
                                  p_var_name => 'l_po_hdr_rec.rate_type',
                                  p_var_value => l_po_hdr_rec.rate_type);

    INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                  p_procedure_name => l_api_name,
                                  p_var_name => 'l_po_hdr_rec.rate_date',
                                  p_var_value => l_po_hdr_rec.rate_date);

    INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                  p_procedure_name => l_api_name,
                                  p_var_name => 'l_po_hdr_rec.rate',
                                  p_var_value => l_po_hdr_rec.rate);

    INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                  p_procedure_name => l_api_name,
                                  p_var_name => 'l_po_hdr_rec.org_id',
                                  p_var_value => l_po_hdr_rec.org_id);

    INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                  p_procedure_name => l_api_name,
                                  p_var_name => 'l_po_hdr_rec.approved_date',
                                  p_var_value => l_po_hdr_rec.approved_date);

    INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                  p_procedure_name => l_api_name,
                                  p_var_name => 'l_simulation_rec.org_id',
                                  p_var_value => l_simulation_rec.org_id);

    INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                   p_procedure_name => l_api_name,
                                   p_debug_info => 'Call INL_SIMULATION_PVT.Create_Simulation');

    -- Format data to create simulation
    l_simulation_rec.firmed_flag := 'N';
    -- l_simulation_rec.parent_table_name := 'PO_HEADERS'; -- Bug 14280113

    INL_SIMULATION_PVT.Create_Simulation(p_api_version => 1.0,
                                         p_init_msg_list => FND_API.G_FALSE,
                                         p_commit => FND_API.G_FALSE,
                                         p_simulation_rec => l_simulation_rec,
                                         x_return_status => l_return_status,
                                         x_msg_count => l_msg_count,
                                         x_msg_data => l_msg_data);

    -- If any errors happen abort the process.
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Format data in record to call procedure in order to create Simulated Shipment
    l_po_hdr_rec.po_header_id := p_po_header_id; -- Bug 14280113
    l_po_hdr_rec.po_release_id := p_po_release_id; -- Bug 14280113
    l_po_hdr_rec.vendor_id := l_simulation_rec.vendor_id;
    l_po_hdr_rec.vendor_site_id := l_simulation_rec.vendor_site_id;
    l_po_hdr_rec.ship_via_lookup_code := l_simulation_rec.freight_code;
    l_po_hdr_rec.revision_num := l_simulation_rec.parent_table_revision_num;
    l_po_hdr_rec.simulation_id := l_simulation_rec.simulation_id;

    l_debug_msg := 'Call INL_INTEGRATION_GRP.Import_FromPO';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info => l_debug_msg);

    Import_FromPO(p_po_hdr_rec => l_po_hdr_rec,
                  p_simulation_rec => l_simulation_rec,
                  x_return_status => l_return_status,
                  x_msg_count => l_msg_count,
                  x_msg_data => l_msg_data);

    -- If any errors happen abort the process.
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;

    IF FND_API.To_Boolean(p_commit) THEN
        l_debug_info := 'Last Commit in INL_INTEGRATION_GRP';
    ELSE
        l_debug_info := 'Cannot perform the last commit in INL_INTEGRATION_GRP';
    END IF;


    INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                   p_procedure_name => l_api_name,
                                   p_debug_info => l_debug_info);

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false, p_count => x_msg_count, p_data => x_msg_data) ;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_api_name);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_api_name);
        ROLLBACK TO Create_POSimulation_GRP;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_api_name);
        ROLLBACK TO Create_POSimulation_GRP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded  => FND_API.g_false,
            p_count    => x_msg_count,
            p_data     => x_msg_data);
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_api_name);
        ROLLBACK TO Create_POSimulation_GRP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);
END Create_POSimulation;

-- Bug #9279355
-- Utility    : Check_POAgainstShipLines
-- Type       : Group
-- Function   : Check PO Lines Against Ship Lines
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_simulation_id IN NUMBER
--
-- OUT          x_return_status  OUT NOCOPY VARCHAR2,
--              x_msg_count OUT NOCOPY NUMBER
--              x_msg_data OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Check_POAgainstShipLines(p_simulation_id IN NUMBER,
                                  x_return_status OUT NOCOPY VARCHAR2,
                                  x_msg_count OUT NOCOPY NUMBER,
                                  x_msg_data OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS

    l_proc_name CONSTANT VARCHAR2(30) := 'Check_POAgainstShipLines';
    l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_po_ship_check BOOLEAN := TRUE;
    l_src_type VARCHAR2(80);

    CURSOR c_po_ln_loc IS
    SELECT pll.line_location_id,
           pll.shipment_num,
           pl.line_num,
           ph.segment1
    FROM po_line_locations pll,
         po_lines pl,
         po_headers ph,
         inl_simulations s
    WHERE INV_UTILITIES.inv_check_lcm(
                pl.item_id,
                pll.ship_to_organization_id,
                NULL,
                NULL,
                ph.vendor_id,
                ph.vendor_site_id) = 'Y'
    AND ph.po_header_id = pl.po_header_id
    AND pll.po_header_id = pl.po_header_id
    AND pll.po_line_id = pl.po_line_id
    AND pl.po_header_id = s.parent_table_id
    AND s.parent_table_name = 'PO_HEADERS'
    AND s.simulation_id = p_simulation_id
    AND NOT EXISTS (SELECT sl.ship_line_id
                    FROM inl_ship_lines sl,
                         inl_ship_headers sh
                    WHERE sh.ship_header_id = sl.ship_header_id
                    AND sl.ship_line_source_id = pll.line_location_id
                    AND sl.ship_line_src_type_code = 'PO'
                    AND sh.simulation_id = s.simulation_id)
    -- Bug #9821615 -- AND (pll.po_release_id IS NULL
    -- Bug #9941402
    AND (ph.type_lookup_code IN ('PLANNED','BLANKET')
    AND  EXISTS (SELECT po_release_id
                 FROM po_releases pr
                 WHERE pr.po_release_id = pll.po_release_id)
    OR ph.type_lookup_code = 'STANDARD');

    TYPE c_po_ln_loc_tp IS TABLE OF c_po_ln_loc%ROWTYPE;
    c_po_ln_loc_tab c_po_ln_loc_tp;
BEGIN

    --  Initialize return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (p_module_name => g_module_name,
                                   p_procedure_name => l_proc_name);

    INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                  p_procedure_name => l_proc_name,
                                  p_var_name => 'p_simulation_id',
                                  p_var_value => p_simulation_id);

    INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                   p_procedure_name => l_proc_name,
                                   p_debug_info => 'Get PO Line Locations for Simulation');

    SELECT meaning
    INTO l_src_type
    FROM fnd_lookup_values_vl l
    WHERE l.lookup_type = 'INL_SHIP_LINE_SRC_TYPES'
    AND l.lookup_code = 'PO';

    -- Open PO Line Locations cursor
    OPEN c_po_ln_loc;
    FETCH c_po_ln_loc BULK COLLECT INTO c_po_ln_loc_tab;
    CLOSE c_po_ln_loc;

    FOR i IN 1..c_po_ln_loc_tab.COUNT
    LOOP

        INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                      p_procedure_name => l_proc_name,
                                      p_var_name => 'c_po_ln_loc_tab(i).line_location_id',
                                      p_var_value => c_po_ln_loc_tab(i).line_location_id);

        INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                       p_procedure_name => l_proc_name,
                                       p_debug_info => 'PO Shipment ' || c_po_ln_loc_tab(i).shipment_num|| ' does not have corresponding Simulated Shipments');

        FND_MESSAGE.SET_NAME('INL','INL_CHK_SIMUL_SRC_SHIP_NOT_FOU');
        FND_MESSAGE.SET_TOKEN ('PO_SHIP_NUM', c_po_ln_loc_tab(i).shipment_num);  -- Bug #9821615
        FND_MESSAGE.SET_TOKEN ('PO_LINE_NUM', c_po_ln_loc_tab(i).line_num);
        FND_MESSAGE.SET_TOKEN ('SOURCE_TYPE', l_src_type);
        FND_MESSAGE.SET_TOKEN ('SOURCE_NUM', c_po_ln_loc_tab(i).segment1);
        FND_MSG_PUB.ADD;
        l_po_ship_check := FALSE;

    END LOOP;

    RETURN l_po_ship_check;

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc (p_module_name => g_module_name,
                                 p_procedure_name => l_proc_name);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name => g_module_name,
            p_procedure_name => l_proc_name);
        x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name => g_module_name,
            p_procedure_name => l_proc_name);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name => g_module_name,
            p_procedure_name => l_proc_name);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(
              p_pkg_name => g_pkg_name,
              p_procedure_name => l_proc_name);
        END IF;
END Check_POAgainstShipLines;

-- Bug #9279355
-- Utility    : Check_ShipLinesAgainstPO
-- Type       : Group
-- Function   : Check Shipment Lines against PO
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_simulation_id IN NUMBER
--
-- OUT          x_return_status  OUT NOCOPY VARCHAR2,
--              x_msg_count OUT NOCOPY NUMBER
--              x_msg_data OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Check_ShipLinesAgainstPO(p_simulation_id IN NUMBER,
                                  x_return_status OUT NOCOPY VARCHAR2,
                                  x_msg_count OUT NOCOPY NUMBER,
                                  x_msg_data OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS

    l_proc_name CONSTANT VARCHAR2(30) := 'Check_ShipLinesAgainstPO';
    l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_ship_ln_check BOOLEAN := TRUE;

    l_po_line_id NUMBER;
    l_po_ln_loc_qty NUMBER;
    l_po_ln_uom VARCHAR2(25);
    l_po_ln_unit_price NUMBER;
    l_po_ln_cancel_flag VARCHAR2(1);
    l_po_ln_num NUMBER;
    l_po_currency VARCHAR2(15);
    l_po_ln_loc_cancel_flag VARCHAR2(1);
    l_po_number VARCHAR2(20);
    l_src_type VARCHAR2(80);

    CURSOR c_ship_ln IS
    SELECT sh.ship_num,
           sl.ship_line_id,
           sl.ship_line_num,
           sl.ship_line_src_type_code,
           sl.ship_line_source_id,
           sl.txn_qty,
           muv.unit_of_measure,
           sl.txn_unit_price,
           sl.currency_code
    FROM inl_ship_lines_all sl,
         inl_ship_headers sh,
         mtl_units_of_measure_vl muv
    WHERE muv.uom_code = sl.txn_uom_code
    AND sl.ship_header_id = sh.ship_header_id
    AND sl.ship_line_src_type_code = 'PO'
    AND sh.simulation_id = p_simulation_id
    ORDER BY sh.ship_num, sl.ship_line_num;

    TYPE c_ship_ln_tp IS TABLE OF c_ship_ln%ROWTYPE;
    c_ship_ln_tab c_ship_ln_tp;
BEGIN

    --  Initialize return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (p_module_name => g_module_name,
                                   p_procedure_name => l_proc_name);

    INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                  p_procedure_name => l_proc_name,
                                  p_var_name => 'p_simulation_id',
                                  p_var_value => p_simulation_id);

    INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                   p_procedure_name => l_proc_name,
                                   p_debug_info => 'Get Shipments that belong to simulation');

    -- Open Shipment Lines cursor
    OPEN c_ship_ln;
    FETCH c_ship_ln BULK COLLECT INTO c_ship_ln_tab;
    CLOSE c_ship_ln;

    FOR i IN 1..c_ship_ln_tab.COUNT
    LOOP
        INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                      p_procedure_name => l_proc_name,
                                      p_var_name => 'c_ship_ln_tab(i).ship_line_id',
                                      p_var_value => c_ship_ln_tab(i).ship_line_id);

        INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                      p_procedure_name => l_proc_name,
                                      p_var_name => 'c_ship_ln_tab(i).ship_line_source_id',
                                      p_var_value => c_ship_ln_tab(i).ship_line_source_id);

        INL_LOGGING_PVT.Log_Statement(p_module_name => g_module_name,
                                      p_procedure_name => l_proc_name,
                                      p_debug_info => 'Get corresponding PO line for Shipment Line');

        BEGIN
            SELECT INL_SHIPMENT_PVT.Get_SrcAvailableQty('PO', pll.line_location_id) quantity,
                    pll.cancel_flag,
                    pl.po_line_id,
                    pl.unit_meas_lookup_code,
                    pl.unit_price,
                    pl.cancel_flag,
                    pl.line_num,
                    ph.currency_code,
                    ph.segment1
               INTO l_po_ln_loc_qty,
                    l_po_ln_loc_cancel_flag,
                    l_po_line_id,
                    l_po_ln_uom,
                    l_po_ln_unit_price,
                    l_po_ln_cancel_flag,
                    l_po_ln_num,
                    l_po_currency,
                    l_po_number
               FROM po_line_locations pll,
                    po_lines pl,
                    po_headers ph
              WHERE ph.po_header_id = pl.po_header_id
                AND pl.po_line_id = pll.po_line_id
                AND pll.line_location_id = c_ship_ln_tab(i).ship_line_source_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                FND_MESSAGE.SET_NAME('INL','INL_CHK_SIMUL_SRC_LOC_NOT_FOUN');
                FND_MESSAGE.SET_TOKEN ('SHIP_LINE_NUM', c_ship_ln_tab(i).ship_line_num) ;
                FND_MESSAGE.SET_TOKEN ('SHIP_NUM', c_ship_ln_tab(i).ship_num) ;
                FND_MSG_PUB.ADD;
                l_ship_ln_check := FALSE;
        END;

        INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                      p_procedure_name => l_proc_name,
                                      p_var_name => 'l_po_line_id',
                                      p_var_value => l_po_line_id);

        INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                      p_procedure_name => l_proc_name,
                                      p_var_name => 'l_po_ln_loc_qty',
                                      p_var_value => l_po_ln_loc_qty);

        INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                      p_procedure_name => l_proc_name,
                                      p_var_name => 'l_po_ln_uom',
                                      p_var_value => l_po_ln_uom);

        INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                      p_procedure_name => l_proc_name,
                                      p_var_name => 'l_po_ln_unit_price',
                                      p_var_value => l_po_ln_unit_price);

        INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                      p_procedure_name => l_proc_name,
                                      p_var_name => 'l_po_currency',
                                      p_var_value => l_po_currency);

        INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                      p_procedure_name => l_proc_name,
                                      p_var_name => 'l_po_ln_loc_cancel_flag',
                                      p_var_value => l_po_ln_loc_cancel_flag);

        INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                      p_procedure_name => l_proc_name,
                                      p_var_name => 'l_po_ln_cancel_flag',
                                      p_var_value => l_po_ln_cancel_flag);

        SELECT meaning
        INTO l_src_type
        FROM fnd_lookup_values_vl l
        WHERE l.lookup_type = 'INL_SHIP_LINE_SRC_TYPES'
        AND l.lookup_code = 'PO';

        IF l_po_line_id IS NOT NULL THEN
            IF NVL(l_po_ln_cancel_flag, 'N') = 'Y' THEN
                FND_MESSAGE.SET_NAME('INL','INL_CHK_SIMUL_SRC_LN_CANCELED');
                FND_MESSAGE.SET_TOKEN('SOURCE_LINE_NUM', l_po_ln_num);
                FND_MESSAGE.SET_TOKEN('SHIP_NUM', c_ship_ln_tab(i).ship_num);
                FND_MESSAGE.SET_TOKEN('SHIP_LINE_NUM', c_ship_ln_tab(i).ship_line_num);
                FND_MESSAGE.SET_TOKEN('SOURCE_TYPE', l_src_type);
                FND_MESSAGE.SET_TOKEN('SOURCE_NUM', l_po_number);
                FND_MSG_PUB.ADD;
                l_ship_ln_check := FALSE;
            END IF;

            IF NVL(l_po_ln_loc_cancel_flag, 'N') = 'Y' THEN
                FND_MESSAGE.SET_NAME('INL','INL_CHK_SIMUL_SRC_LN_LOC_CANC');
                FND_MESSAGE.SET_TOKEN('SHIP_NUM', c_ship_ln_tab(i).ship_num);
                FND_MESSAGE.SET_TOKEN('SHIP_LINE_NUM', c_ship_ln_tab(i).ship_line_num);
                FND_MESSAGE.SET_TOKEN('SOURCE_TYPE', l_src_type);
                FND_MESSAGE.SET_TOKEN('SOURCE_NUM', l_po_number);
                FND_MSG_PUB.ADD;
                l_ship_ln_check := FALSE;
            END IF;

            IF c_ship_ln_tab(i).txn_qty <> l_po_ln_loc_qty THEN
                FND_MESSAGE.SET_NAME('INL','INL_CHK_SIMUL_SRC_LN_QTY');
                FND_MESSAGE.SET_TOKEN('QTY1', c_ship_ln_tab(i).txn_qty);
                FND_MESSAGE.SET_TOKEN('SHIP_NUM', c_ship_ln_tab(i).ship_num);
                FND_MESSAGE.SET_TOKEN('SHIP_LINE_NUM', c_ship_ln_tab(i).ship_line_num);
                FND_MESSAGE.SET_TOKEN('QTY2', l_po_ln_loc_qty);
                FND_MESSAGE.SET_TOKEN('SOURCE_TYPE', l_src_type);
                FND_MESSAGE.SET_TOKEN('SOURCE_NUM', l_po_number);
                FND_MESSAGE.SET_TOKEN('SOURCE_LINE_NUM', l_po_ln_num);
                FND_MSG_PUB.ADD;
                l_ship_ln_check := FALSE;
            END IF;

            IF c_ship_ln_tab(i).unit_of_measure <> l_po_ln_uom THEN
                FND_MESSAGE.SET_NAME('INL','INL_CHK_SIMUL_SRC_LN_UOM');
                FND_MESSAGE.SET_TOKEN('UOM1', c_ship_ln_tab(i).unit_of_measure);
                FND_MESSAGE.SET_TOKEN('SHIP_NUM', c_ship_ln_tab(i).ship_num);
                FND_MESSAGE.SET_TOKEN('SHIP_LINE_NUM', c_ship_ln_tab(i).ship_line_num);
                FND_MESSAGE.SET_TOKEN('UOM2', l_po_ln_uom);
                FND_MESSAGE.SET_TOKEN('SOURCE_TYPE', l_src_type);
                FND_MESSAGE.SET_TOKEN('SOURCE_NUM', l_po_number);
                FND_MESSAGE.SET_TOKEN('SOURCE_LINE_NUM', l_po_ln_num);
                FND_MSG_PUB.ADD;
                l_ship_ln_check := FALSE;
            END IF;

            IF c_ship_ln_tab(i).txn_unit_price <> l_po_ln_unit_price THEN
                FND_MESSAGE.SET_NAME('INL','INL_CHK_SIMUL_SRC_LN_UNIT_PRIC');
                FND_MESSAGE.SET_TOKEN('PRICE1', c_ship_ln_tab(i).txn_unit_price);
                FND_MESSAGE.SET_TOKEN('SHIP_LINE_NUM', c_ship_ln_tab(i).ship_line_num);
                FND_MESSAGE.SET_TOKEN('SHIP_NUM', c_ship_ln_tab(i).ship_num);
                FND_MESSAGE.SET_TOKEN('PRICE2', l_po_ln_unit_price);
                FND_MESSAGE.SET_TOKEN('PO_LINE_NUM', l_po_ln_num);
                FND_MESSAGE.SET_TOKEN('SOURCE_TYPE', l_src_type);
                FND_MESSAGE.SET_TOKEN('SOURCE_NUM', l_po_number);
                FND_MSG_PUB.ADD;
                l_ship_ln_check := FALSE;
            END IF;

            IF c_ship_ln_tab(i).currency_code <> l_po_currency THEN
                FND_MESSAGE.SET_NAME('INL','INL_CHK_SIMUL_SRC_LN_CURRENCY');
                FND_MESSAGE.SET_TOKEN('CURRENCY1', c_ship_ln_tab(i).currency_code);
                FND_MESSAGE.SET_TOKEN('SHIP_NUM', c_ship_ln_tab(i).ship_num);
                FND_MESSAGE.SET_TOKEN('SHIP_LINE_NUM', c_ship_ln_tab(i).ship_line_num);
                FND_MESSAGE.SET_TOKEN('CURRENCY2', c_ship_ln_tab(i).currency_code);
                FND_MESSAGE.SET_TOKEN('SOURCE_TYPE', l_src_type);
                FND_MESSAGE.SET_TOKEN('SOURCE_NUM', l_po_number);
                FND_MSG_PUB.ADD;
                l_ship_ln_check := FALSE;
            END IF;
        END IF;
    END LOOP;

    RETURN l_ship_ln_check;

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc (p_module_name => g_module_name,
                                 p_procedure_name => l_proc_name);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name => g_module_name,
            p_procedure_name => l_proc_name);
        x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name => g_module_name,
            p_procedure_name => l_proc_name);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name => g_module_name,
            p_procedure_name => l_proc_name);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(
              p_pkg_name => g_pkg_name,
              p_procedure_name => l_proc_name);
        END IF;
END Check_ShipLinesAgainstPO;

-- Bug #9279355
-- Utility    : Check_SimulAgainstPO
-- Type       : Group
-- Function   : Check simulation against PO
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_simulation_id IN NUMBER
--
-- OUT          x_return_status  OUT NOCOPY VARCHAR2,
--              x_msg_count OUT NOCOPY NUMBER
--              x_msg_data OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Check_SimulAgainstPO(p_simulation_id IN NUMBER,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_count OUT NOCOPY NUMBER,
                              x_msg_data OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS

    l_proc_name CONSTANT VARCHAR2(30) := 'Check_SimulAgainstPO';
    l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_simulation_check BOOLEAN := TRUE;
    l_po_number NUMBER;
    l_po_header_id NUMBER;
    l_po_vendor_id NUMBER;
    l_po_vendor_site_id NUMBER;
    l_po_freight_code VARCHAR2(25);
    l_simu_vendor_id NUMBER;
    l_simu_vendor_site_id NUMBER;
    l_simu_freight_code VARCHAR2(25);
    l_po_revision_num NUMBER;
    l_simu_revision_num NUMBER;
    l_simu_vendor_name VARCHAR2(240);
    l_simu_vendor_site_code VARCHAR2(15);
    l_po_vendor_name VARCHAR2(240);
    l_po_vendor_site_code VARCHAR2(15);
    l_src_type VARCHAR2(80);
    l_po_release_revision_num NUMBER; -- Bug 14280113
    l_parent_table_name VARCHAR2(30); -- Bug 14280113
    l_po_release_num NUMBER; -- Bug 14280113

BEGIN

    --  Initialize return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (p_module_name => g_module_name,
                                   p_procedure_name => l_proc_name);

    INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                  p_procedure_name => l_proc_name,
                                  p_var_name => 'p_simulation_id',
                                  p_var_value => p_simulation_id);

    INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                   p_procedure_name => l_proc_name,
                                   p_debug_info => 'Get PO data that belongs to simulation');

    SELECT meaning
    INTO l_src_type
    FROM fnd_lookup_values_vl l
    WHERE l.lookup_type = 'INL_SHIP_LINE_SRC_TYPES'
    AND l.lookup_code = 'PO';

    BEGIN
        SELECT ph.segment1,
               ph.po_header_id,
               ph.vendor_id po_vendor_id,
               ph.vendor_site_id po_vendor_site_id,
               ph.ship_via_lookup_code po_freight_code,
               ph.revision_num po_revision_num,
               s.vendor_id simu_vendor_id,
               s.vendor_site_id simu_vendor_site_id,
               s.freight_code simu_freight_code,
               s.parent_table_revision_num simu_revision_num,
               s.parent_table_name,   -- Bug 14280113
               pv.vendor_name,
               pvs.vendor_site_code,
               pv1.vendor_name,
               pvs1.vendor_site_code,
               pr.release_num po_release_num, -- Bug 14280113
               pr.revision_num po_release_revision_num  -- Bug 14280113
        INTO l_po_number,
             l_po_header_id,
             l_po_vendor_id,
             l_po_vendor_site_id,
             l_po_freight_code,
             l_po_revision_num,
             l_simu_vendor_id,
             l_simu_vendor_site_id,
             l_simu_freight_code,
             l_simu_revision_num,
             l_parent_table_name, -- Bug 14280113
             l_po_vendor_name,
             l_po_vendor_site_code,
             l_simu_vendor_name,
             l_simu_vendor_site_code,
             l_po_release_num, -- Bug 14280113
             l_po_release_revision_num -- Bug 14280113
        FROM po_vendor_sites pvs1,
             po_vendors pv1,
             po_vendor_sites pvs,
             po_vendors pv,
             po_releases pr, -- Bug 14280113
             po_headers_all ph,
             inl_simulations s
        WHERE pr.po_header_id (+) = ph.po_header_id -- Bug 14280113
        AND pvs1.vendor_site_id = s.vendor_site_id
        AND pv1.vendor_id = s.vendor_id
        AND pvs.vendor_site_id = ph.vendor_site_id
        AND pv.vendor_id = ph.vendor_id
        -- Bug 14280113
        --AND ph.po_header_id = s.parent_table_id
        AND ((s.parent_table_name = 'PO_HEADERS'
        AND   s.parent_table_id = ph.po_header_id)
        OR   (s.parent_table_name = 'PO_RELEASES'
        AND   s.parent_table_id = pr.po_release_id))
        AND s.simulation_id = p_simulation_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME('INL','INL_CHK_SIMUL_SRC_NOT_FOUND');
            FND_MESSAGE.SET_TOKEN ('SOURCE_TYPE', l_src_type);
            FND_MESSAGE.SET_TOKEN ('SOURCE_NUM', l_po_number);
            FND_MSG_PUB.ADD;
            l_simulation_check := FALSE;
    END;

    INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                  p_procedure_name => l_proc_name,
                                  p_var_name => 'l_po_number',
                                  p_var_value => l_po_number);

    INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                  p_procedure_name => l_proc_name,
                                  p_var_name => 'l_po_revision_num',
                                  p_var_value => l_po_revision_num);

    INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                  p_procedure_name => l_proc_name,
                                  p_var_name => 'l_simu_revision_num',
                                  p_var_value => l_simu_revision_num);

    INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                  p_procedure_name => l_proc_name,
                                  p_var_name => 'l_po_vendor_id',
                                  p_var_value => l_po_vendor_id);

    INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                  p_procedure_name => l_proc_name,
                                  p_var_name => 'l_simu_vendor_id',
                                  p_var_value => l_simu_vendor_id);

    INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                  p_procedure_name => l_proc_name,
                                  p_var_name => 'l_po_vendor_site_id',
                                  p_var_value => l_po_vendor_site_id);

    INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                  p_procedure_name => l_proc_name,
                                  p_var_name => 'l_simu_vendor_site_id',
                                  p_var_value => l_simu_vendor_site_id);

    INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                  p_procedure_name => l_proc_name,
                                  p_var_name => 'l_po_freight_code',
                                  p_var_value => l_po_freight_code);

    INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                  p_procedure_name => l_proc_name,
                                  p_var_name => 'l_simu_freight_code',
                                  p_var_value => l_simu_freight_code);
    -- Bug 14280113
    INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                  p_procedure_name => l_proc_name,
                                  p_var_name => 'l_parent_table_name',
                                  p_var_value => l_parent_table_name);
    -- Bug 14280113
    INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                  p_procedure_name => l_proc_name,
                                  p_var_name => 'l_po_release_revision_num',
                                  p_var_value => l_po_release_revision_num);

    IF l_po_header_id IS NOT NULL THEN
        -- Check revision
        IF NVL(l_po_revision_num,0) <> NVL(l_simu_revision_num,0) THEN

            INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                      p_procedure_name => l_proc_name,
                                      p_var_name => 'l_simu_revision_num',
                                      p_var_value => l_simu_revision_num);

            INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                      p_procedure_name => l_proc_name,
                                      p_var_name => 'l_po_revision_num',
                                      p_var_value => l_po_revision_num);

            INL_LOGGING_PVT.Log_Statement (
                        p_module_name => g_module_name,
                        p_procedure_name => l_proc_name,
                        p_debug_info => 'PO revision is different from Simulation revision');
            FND_MESSAGE.SET_NAME('INL','INL_CHK_SIMUL_SRC_REVISION');
            FND_MESSAGE.SET_TOKEN ('SOURCE_REV_NUM', l_simu_revision_num);
            FND_MESSAGE.SET_TOKEN ('SOURCE_REV_NUM1', l_po_revision_num);
            FND_MESSAGE.SET_TOKEN ('SOURCE_TYPE', l_src_type);
            FND_MESSAGE.SET_TOKEN ('SOURCE_NUM', l_po_number);
            FND_MSG_PUB.ADD;
            l_simulation_check := FALSE;
        END IF;

        -- Bug 14280113 Check PO Release revision
        IF NVL(l_po_release_revision_num,0) <> NVL(l_simu_revision_num,0) AND
           l_parent_table_name = 'PO_RELEASES' THEN
            INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                      p_procedure_name => l_proc_name,
                                      p_var_name => 'l_simu_revision_num',
                                      p_var_value => l_simu_revision_num);

            INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                      p_procedure_name => l_proc_name,
                                      p_var_name => 'l_po_release_revision_num',
                                      p_var_value => l_po_release_revision_num);

            INL_LOGGING_PVT.Log_Statement (
                        p_module_name => g_module_name,
                        p_procedure_name => l_proc_name,
                        p_debug_info => 'PO Release revision is different from Simulation revision');
            FND_MESSAGE.SET_NAME('INL','INL_CHK_SIMUL_SRC_REL_REVISION');
            FND_MESSAGE.SET_TOKEN ('SOURCE_REL_REV_NUM', l_simu_revision_num);
            FND_MESSAGE.SET_TOKEN ('SOURCE_REL_REV_NUM1', l_po_release_revision_num);
            FND_MESSAGE.SET_TOKEN ('SOURCE_REL_NUM', l_po_release_num);
            FND_MESSAGE.SET_TOKEN ('SOURCE_TYPE', l_src_type);
            FND_MESSAGE.SET_TOKEN ('SOURCE_NUM', l_po_number);
            FND_MSG_PUB.ADD;
            l_simulation_check := FALSE;
        END IF;
        -- Bug 14280113

        -- Check Vendor
        IF(l_po_vendor_id <> l_simu_vendor_id) THEN
            FND_MESSAGE.SET_NAME('INL','INL_CHK_SIMUL_SRC_PARTY');
            FND_MESSAGE.SET_TOKEN ('THIRD_PARTY', l_simu_vendor_name);
            FND_MESSAGE.SET_TOKEN ('THIRD_PARTY2', l_po_vendor_name);
            FND_MESSAGE.SET_TOKEN ('SOURCE_TYPE', l_src_type);
            FND_MESSAGE.SET_TOKEN ('SOURCE_NUM', l_po_number);
            FND_MSG_PUB.ADD;
            l_simulation_check := FALSE;
        END IF;

        -- Check Vendor Site
        IF(l_po_vendor_site_id <> l_simu_vendor_site_id) THEN
            FND_MESSAGE.SET_NAME('INL','INL_CHK_SIMUL_SRC_PARTY_SITE');
            FND_MESSAGE.SET_TOKEN ('THIRD_PARTY_SITE', l_simu_vendor_site_code);
            FND_MESSAGE.SET_TOKEN ('THIRD_PARTY_SITE2', l_po_vendor_site_code);
            FND_MESSAGE.SET_TOKEN ('SOURCE_TYPE', l_src_type);
            FND_MESSAGE.SET_TOKEN ('SOURCE_NUM', l_po_number);
            FND_MSG_PUB.ADD;
            l_simulation_check := FALSE;
        END IF;

        -- Check Freight
        IF(l_po_freight_code <> l_simu_freight_code) THEN
            FND_MESSAGE.SET_NAME('INL','INL_CHK_SIMUL_SRC_FREIGHT_CODE');
            FND_MESSAGE.SET_TOKEN ('CARRIER1', l_simu_freight_code);
            FND_MESSAGE.SET_TOKEN ('CARRIER2', l_po_freight_code);
            FND_MESSAGE.SET_TOKEN ('SOURCE_TYPE', l_src_type);
            FND_MESSAGE.SET_TOKEN ('SOURCE_NUM', l_po_number);
            FND_MSG_PUB.ADD;
            l_simulation_check := FALSE;
        END IF;
    END IF;

    RETURN l_simulation_check;

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc (p_module_name => g_module_name,
                                 p_procedure_name => l_proc_name);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name => g_module_name,
            p_procedure_name => l_proc_name);
        x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name => g_module_name,
            p_procedure_name => l_proc_name);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name => g_module_name,
            p_procedure_name => l_proc_name);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(
              p_pkg_name => g_pkg_name,
              p_procedure_name => l_proc_name);
        END IF;
END Check_SimulAgainstPO;

-- Bug #9279355
-- API name : Check_POLcmSynch
-- Type       : Group
-- Function   : Check Synchronicity Between PO and Simulation
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version IN NUMBER,
--              p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE
--              p_commit IN VARCHAR2 := FND_API.G_FALSE
--              p_simulation_id IN  NUMBER
--
-- OUT          x_return_status OUT NOCOPY VARCHAR2
--              x_msg_count OUT NOCOPY NUMBER
--              x_msg_data OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Check_POLcmSynch (
    p_api_version IN NUMBER,
    p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
    p_commit IN VARCHAR2 := FND_API.G_FALSE,
    p_simulation_id IN  NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

    l_api_name CONSTANT VARCHAR2(30) := 'Check_POLcmSynch';
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);
    l_api_version CONSTANT NUMBER := 1.0;
    l_debug_msg VARCHAR2(400);
    l_check_po_lcm_synch VARCHAR2(6) := 'TRUE';
    l_simul_against_po BOOLEAN := TRUE;
    l_ship_ln_check BOOLEAN := TRUE;
    l_po_ship_check BOOLEAN := TRUE;

BEGIN

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(p_module_name => g_module_name,
                                  p_procedure_name => l_api_name) ;

    -- Standard Start of API savepoint
    SAVEPOINT Check_POLcmSynch_GRP;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(p_current_version_number => l_api_version,
                                       p_caller_version_number => p_api_version,
                                       p_api_name => l_api_name,
                                       p_pkg_name => g_pkg_name ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                  p_procedure_name => l_api_name,
                                  p_var_name => 'p_simulation_id',
                                  p_var_value => p_simulation_id);


    INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                   p_procedure_name => l_api_name,
                                   p_debug_info => 'Call Check_SimulAgainstPO');

    l_simul_against_po := Check_SimulAgainstPO(
                                p_simulation_id => p_simulation_id,
                                x_return_status => l_return_status,
                                x_msg_count => l_msg_count,
                                x_msg_data => l_msg_data);

    -- If any errors happen abort API.
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                   p_procedure_name => l_api_name,
                                   p_debug_info => 'Call Check_ShipLinesAgainstPO');

    l_ship_ln_check := Check_ShipLinesAgainstPO(
                                    p_simulation_id => p_simulation_id,
                                    x_return_status => l_return_status,
                                    x_msg_count => l_msg_count,
                                    x_msg_data => l_msg_data);

    -- If any errors happen abort API.
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                   p_procedure_name => l_api_name,
                                   p_debug_info => 'Call Check_POAgainstShipLines');

    l_po_ship_check := Check_POAgainstShipLines(
                                p_simulation_id => p_simulation_id,
                                x_return_status => l_return_status,
                                x_msg_count => l_msg_count,
                                x_msg_data => l_msg_data);

    -- If any errors happen abort API.
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF NOT l_simul_against_po OR NOT l_ship_ln_check OR NOT l_po_ship_check THEN
        l_check_po_lcm_synch := 'FALSE';
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false, p_count => x_msg_count, p_data => x_msg_data) ;
    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_api_name);

    RETURN l_check_po_lcm_synch;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_api_name);
        ROLLBACK TO Check_POLcmSynch_GRP;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_api_name);
        ROLLBACK TO Check_POLcmSynch_GRP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded  => FND_API.g_false,
            p_count    => x_msg_count,
            p_data     => x_msg_data);
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_api_name);
        ROLLBACK TO Check_POLcmSynch_GRP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);
END Check_POLcmSynch;

--=======================================
--Bug#9279355 - DEV1213: GTM-SCM-012 SUPPORT TO LC CALCULATION IN PURCHASING
--=======================================

-- Function name   : Check_POEligibility
-- Type       : Group
-- Function   : Check whether a given PO is LCM eligible.
--              Returns 'N' if not eligible.
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_po_header_id   IN NUMBER
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Check_POEligibility(p_po_header_id  IN NUMBER) RETURN VARCHAR2 IS

CURSOR c_po_info IS
    SELECT ph.vendor_id,
           ph.vendor_site_id,
           pl.item_id,
           pll.ship_to_organization_id
      FROM po_headers_all ph,
           po_lines_all pl,
           po_line_locations_all pll
     WHERE ph.po_header_id = pl.po_header_id
       AND pl.po_line_id = pll.po_line_id
       AND ph.po_header_id = p_po_header_id;

TYPE po_info_list_type IS
TABLE OF c_po_info%ROWTYPE;
po_info_list po_info_list_type;

l_inv_check_lcm VARCHAR2(1);
l_is_po_eligible VARCHAR2(1) := 'N';
l_func_name VARCHAR2 (200) := 'Check_POEligibility';

BEGIN
    INL_LOGGING_PVT.Log_BeginProc (p_module_name => g_module_name,
                                   p_procedure_name => l_func_name);

    OPEN c_po_info;
    FETCH c_po_Info BULK COLLECT INTO po_info_list;
    CLOSE c_po_info;

    FOR i IN 1..po_info_list.COUNT
    LOOP
        l_inv_check_lcm := INV_UTILITIES.INV_CHECK_LCM(po_info_list(i).item_id,
                                                       po_info_list(i).ship_to_organization_id,
                                                       NULL,
                                                       NULL,
                                                       po_info_list(i).vendor_id,
                                                       po_info_list(i).vendor_site_id);
        IF l_inv_check_lcm = 'Y' THEN
            l_is_po_eligible := 'Y';
            EXIT; -- exit loop as an elegible PLL has been found
        END IF;
    END LOOP;

    INL_LOGGING_PVT.Log_EndProc (p_module_name => g_module_name,
                                 p_procedure_name => l_func_name);

    RETURN l_is_po_eligible;
EXCEPTION
WHEN NO_DATA_FOUND THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_ExpecError (p_module_name => g_module_name,
                                      p_procedure_name => l_func_name) ;
    RETURN l_is_po_eligible;
WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (p_module_name => g_module_name,
                                      p_procedure_name => l_func_name) ;
    IF FND_MSG_PUB.Check_Msg_Level (p_message_level  =>
FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg (p_pkg_name => g_pkg_name,
                                 p_procedure_name => l_func_name) ;
    END IF;
    RETURN l_is_po_eligible;
END Check_POEligibility;

END INL_INTEGRATION_GRP;

/
