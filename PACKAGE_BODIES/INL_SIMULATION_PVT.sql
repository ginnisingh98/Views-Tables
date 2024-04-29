--------------------------------------------------------
--  DDL for Package Body INL_SIMULATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INL_SIMULATION_PVT" AS
/* $Header: INLVSIMB.pls 120.0.12010000.5 2012/10/03 18:53:34 acferrei noship $ */

-- API name   : Duplicate_Tax
-- Type       : Group
-- Function   : Duplicate the Tax Line for a copyed Simulated component
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version                IN NUMBER
--              p_init_msg_list              IN VARCHAR2 := FND_API.G_FALSE
--              p_commit                     IN VARCHAR2 := FND_API.G_FALSE
--              p_current_ship_header_id     IN NUMBER
--              p_new_ship_header_id         IN NUMBER
--              p_from_parent_table_id       IN NUMBER
--              p_to_parent_table_name       IN VARCHAR2
--              p_current_to_parent_table_id IN NUMBER
--              p_new_to_parent_table_id     IN NUMBER
--
-- OUT        : x_return_status OUT NOCOPY VARCHAR2
--              x_msg_count     OUT NOCOPY NUMBER
--              x_msg_data      OUT NOCOPY VARCHAR2
--
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Duplicate_Tax (p_api_version                IN NUMBER,
                         p_init_msg_list              IN VARCHAR2 := FND_API.G_FALSE,
                         p_commit                     IN VARCHAR2 := FND_API.G_FALSE,
                         p_current_ship_header_id     IN NUMBER,
                         p_new_ship_header_id         IN NUMBER,
                         p_from_parent_table_id       IN NUMBER,
                         p_to_parent_table_name       IN VARCHAR2,
                         p_current_to_parent_table_id IN NUMBER,
                         p_new_to_parent_table_id     IN NUMBER,
                         x_return_status              OUT NOCOPY VARCHAR2,
                         x_msg_count                  OUT NOCOPY NUMBER,
                         x_msg_data                   OUT NOCOPY VARCHAR2) IS

    l_api_name CONSTANT VARCHAR2(30) := 'Duplicate_Tax';
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);
    l_api_version CONSTANT NUMBER := 1.0;
    l_init_msg_list VARCHAR2(2000) := FND_API.G_FALSE;
    l_commit VARCHAR2(1) := FND_API.G_FALSE;
    l_debug_msg VARCHAR2(400);

    l_tax_line_id NUMBER;

    CURSOR TaxLines IS
        SELECT itl.tax_line_id,
               itl.tax_line_num,
               itl.tax_code,
               itl.ship_header_id,
               itl.parent_tax_line_id,
               itl.adjustment_num,
               itl.match_id,
               itl.match_amount_id,
               itl.source_parent_table_name,
               itl.source_parent_table_id,
               itl.tax_amt,
               itl.nrec_tax_amt,
               itl.currency_code,
               itl.currency_conversion_type,
               itl.currency_conversion_date,
               itl.currency_conversion_rate,
               itl.tax_amt_included_flag,
               itl.created_by,
               itl.creation_date,
               itl.last_updated_by,
               itl.last_update_date,
               itl.last_update_login,
               ias.allocation_basis,
               ias.allocation_uom_code
          FROM inl_tax_lines itl,
               inl_associations ias
         WHERE ias.from_parent_table_name = 'INL_TAX_LINES'
           AND ias.from_parent_table_id = p_from_parent_table_id
           AND ias.to_parent_table_name = p_to_parent_table_name
           AND ias.to_parent_table_id = p_current_to_parent_table_id
           AND itl.tax_line_id = p_from_parent_table_id
           AND ias.ship_header_id = p_current_ship_header_id;

    TYPE TaxLines_List_Type IS
    TABLE OF TaxLines%ROWTYPE;
    TaxLines_List TaxLines_List_Type;

BEGIN

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(p_module_name    => g_module_name,
                                  p_procedure_name => l_api_name) ;

    -- Standard Start of API savepoint
    SAVEPOINT Duplicate_Tax_GRP;

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
                                  p_var_name => 'p_current_ship_header_id',
                                  p_var_value => p_current_ship_header_id);
    INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                  p_procedure_name => l_api_name,
                                  p_var_name => 'p_new_ship_header_id',
                                  p_var_value => p_new_ship_header_id);
    INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                  p_procedure_name => l_api_name,
                                  p_var_name => 'p_to_parent_table_name',
                                  p_var_value => p_to_parent_table_name);
    INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                  p_procedure_name => l_api_name,
                                  p_var_name => 'p_current_to_parent_table_id',
                                  p_var_value => p_current_to_parent_table_id);
    INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                  p_procedure_name => l_api_name,
                                  p_var_name => 'p_new_to_parent_table_id',
                                  p_var_value => p_new_to_parent_table_id);

    OPEN TaxLines;
    FETCH TaxLines BULK COLLECT INTO TaxLines_List;
    CLOSE TaxLines;

    FOR i IN 1..TaxLines_List.COUNT
    LOOP
        INL_LOGGING_PVT.Log_Variable(p_module_name    => g_module_name,
                                     p_procedure_name => l_api_name,
                                     p_var_name       => 'tax_line_id',
                                     p_var_value      => TaxLines_List(i).tax_line_id);

        INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                       p_procedure_name => l_api_name,
                                       p_debug_info => 'Get the next Tax Line Id');

        -- Get Charge Line nextval
        SELECT inl_tax_lines_s.NEXTVAL
          INTO l_tax_line_id
          FROM dual;

        INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                       p_procedure_name => l_api_name,
                                       p_debug_info => 'Insert into INL_TAX_LINES');

        INSERT INTO inl_tax_lines (tax_line_id,
                                   tax_line_num,
                                   tax_code,
                                   ship_header_id,
                                   parent_tax_line_id,
                                   adjustment_num,
                                   match_id,
                                   match_amount_id,
                                   source_parent_table_name,
                                   source_parent_table_id,
                                   tax_amt,
                                   nrec_tax_amt,
                                   currency_code,
                                   currency_conversion_type,
                                   currency_conversion_date,
                                   currency_conversion_rate,
                                   tax_amt_included_flag,
                                   created_by,
                                   creation_date,
                                   last_updated_by,
                                   last_update_date,
                                   last_update_login)
                          VALUES  (l_tax_line_id,
                                   TaxLines_List(i).tax_line_num,
                                   TaxLines_List(i).tax_code,
                                   p_new_ship_header_id,
                                   TaxLines_List(i).parent_tax_line_id,
                                   TaxLines_List(i).adjustment_num,
                                   TaxLines_List(i).match_id,
                                   TaxLines_List(i).match_amount_id,
                                   TaxLines_List(i).source_parent_table_name,
                                   TaxLines_List(i).source_parent_table_id,
                                   TaxLines_List(i).tax_amt,
                                   TaxLines_List(i).nrec_tax_amt,
                                   TaxLines_List(i).currency_code,
                                   TaxLines_List(i).currency_conversion_type,
                                   TaxLines_List(i).currency_conversion_date,
                                   TaxLines_List(i).currency_conversion_rate,
                                   TaxLines_List(i).tax_amt_included_flag,
                                   fnd_global.user_id,
                                   SYSDATE,
                                   fnd_global.user_id,
                                   SYSDATE,
                                   fnd_global.login_id);

        INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                       p_procedure_name => l_api_name,
                                       p_debug_info => 'Insert Charge association into INL_ASSOCIATIONS');

        INSERT INTO inl_associations (association_id,
                                      ship_header_id,
                                      from_parent_table_name,
                                      from_parent_table_id,
                                      to_parent_table_name,
                                      to_parent_table_id,
                                      allocation_basis,
                                      allocation_uom_code,
                                      created_by,
                                      creation_date,
                                      last_updated_by,
                                      last_update_date,
                                      last_update_login)
                              VALUES (inl_associations_s.NEXTVAL,
                                      p_new_ship_header_id,
                                      'INL_TAX_LINES',
                                      l_tax_line_id,
                                      p_to_parent_table_name,
                                      p_new_to_parent_table_id,
                                      TaxLines_List(i).allocation_basis,
                                      TaxLines_List(i).allocation_uom_code,
                                      fnd_global.user_id,
                                      SYSDATE,
                                      fnd_global.user_id,
                                      SYSDATE,
                                      fnd_global.login_id);
    END LOOP;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                              p_count => x_msg_count,
                              p_data => x_msg_data) ;

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(p_module_name    => g_module_name,
                                p_procedure_name => l_api_name);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (p_module_name    => g_module_name,
                                        p_procedure_name => l_api_name);
        ROLLBACK TO Duplicate_Tax_GRP;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                                  p_count   => x_msg_count,
                                  p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (p_module_name    => g_module_name,
                                          p_procedure_name => l_api_name);
       -- ROLLBACK TO Import_FromPO_GRP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_encoded  => FND_API.g_false,
                                  p_count    => x_msg_count,
                                  p_data     => x_msg_data);
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (p_module_name    => g_module_name,
                                          p_procedure_name => l_api_name);
        ROLLBACK TO Duplicate_Tax_GRP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(p_pkg_name       => g_pkg_name,
                                    p_procedure_name => l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                                  p_count   => x_msg_count,
                                  p_data    => x_msg_data);
END Duplicate_Tax;

-- API name   : Duplicate_Charges
-- Type       : Group
-- Function   : Duplicate the Charge Line for a copyed Simulated component
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version                IN NUMBER
--              p_init_msg_list              IN VARCHAR2 := FND_API.G_FALSE
--              p_commit                     IN VARCHAR2 := FND_API.G_FALSE
--              p_current_ship_header_id     IN NUMBER
--              p_new_ship_header_id         IN NUMBER
--              p_from_parent_table_id       IN NUMBER
--              p_to_parent_table_name       IN VARCHAR2
--              p_current_to_parent_table_id IN NUMBER
--              p_new_to_parent_table_id     IN NUMBER
--
-- OUT        : x_return_status OUT NOCOPY VARCHAR2
--              x_msg_count     OUT NOCOPY NUMBER
--              x_msg_data      OUT NOCOPY VARCHAR2
--
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Duplicate_Charge (p_api_version                IN NUMBER,
                            p_init_msg_list              IN VARCHAR2 := FND_API.G_FALSE,
                            p_commit                     IN VARCHAR2 := FND_API.G_FALSE,
                            p_current_ship_header_id     IN NUMBER,
                            p_new_ship_header_id         IN NUMBER,
                            p_from_parent_table_id       IN NUMBER,
                            p_to_parent_table_name       IN VARCHAR2,
                            p_current_to_parent_table_id IN NUMBER,
                            p_new_to_parent_table_id     IN NUMBER,
                            x_return_status              OUT NOCOPY VARCHAR2,
                            x_msg_count                  OUT NOCOPY NUMBER,
                            x_msg_data                   OUT NOCOPY VARCHAR2) IS

    l_api_name CONSTANT VARCHAR2(30) := 'Duplicate_Charge';
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);
    l_api_version CONSTANT NUMBER := 1.0;
    l_init_msg_list VARCHAR2(2000) := FND_API.G_FALSE;
    l_commit VARCHAR2(1) := FND_API.G_FALSE;
    l_debug_msg VARCHAR2(400);

    l_charge_line_id NUMBER;

    CURSOR ChargeLines IS
        SELECT icl.charge_line_id,
               icl.charge_line_num,
               icl.charge_line_type_id,
               icl.landed_cost_flag,
               icl.update_allowed,
               icl.source_code,
               icl.parent_charge_line_id,
               icl.adjustment_num,
               icl.match_id,
               icl.match_amount_id,
               icl.charge_amt,
               icl.currency_code,
               icl.currency_conversion_type,
               icl.currency_conversion_date,
               icl.currency_conversion_rate,
               icl.party_id,
               icl.party_site_id,
               icl.trx_business_category,
               icl.intended_use,
               icl.product_fiscal_class,
               icl.product_category,
               icl.product_type,
               icl.user_def_fiscal_class,
               icl.tax_classification_code,
               icl.assessable_value,
               icl.tax_already_calculated_flag,
               icl.ship_from_party_id,
               icl.ship_from_party_site_id,
               icl.ship_to_organization_id,
               icl.ship_to_location_id,
               icl.bill_from_party_id,
               icl.bill_from_party_site_id,
               icl.bill_to_organization_id,
               icl.bill_to_location_id,
               icl.poa_party_id,
               icl.poa_party_site_id,
               icl.poo_organization_id,
               icl.poo_location_id,
               icl.created_by,
               icl.creation_date,
               icl.last_updated_by,
               icl.last_update_date,
               icl.last_update_login,
               ias.allocation_basis,
               ias.allocation_uom_code
          FROM inl_charge_lines icl,
               inl_associations ias
         WHERE ias.from_parent_table_name = 'INL_CHARGE_LINES'
           AND ias.from_parent_table_id = p_from_parent_table_id
           AND ias.to_parent_table_name = p_to_parent_table_name
           AND ias.to_parent_table_id = p_current_to_parent_table_id
           AND icl.charge_line_id = p_from_parent_table_id
           AND ias.ship_header_id = p_current_ship_header_id;

    TYPE ChargeLines_List_Type IS
    TABLE OF ChargeLines%ROWTYPE;
    ChargeLines_List ChargeLines_List_Type;

BEGIN

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(p_module_name    => g_module_name,
                                  p_procedure_name => l_api_name) ;

    -- Standard Start of API savepoint
    SAVEPOINT Duplicate_Charge_GRP;

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
                                  p_var_name => 'p_current_ship_header_id',
                                  p_var_value => p_current_ship_header_id);
    INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                  p_procedure_name => l_api_name,
                                  p_var_name => 'p_new_ship_header_id',
                                  p_var_value => p_new_ship_header_id);
    INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                  p_procedure_name => l_api_name,
                                  p_var_name => 'p_to_parent_table_name',
                                  p_var_value => p_to_parent_table_name);
    INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                  p_procedure_name => l_api_name,
                                  p_var_name => 'p_current_to_parent_table_id',
                                  p_var_value => p_current_to_parent_table_id);
    INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                  p_procedure_name => l_api_name,
                                  p_var_name => 'p_new_to_parent_table_id',
                                  p_var_value => p_new_to_parent_table_id);

    OPEN ChargeLines;
    FETCH ChargeLines BULK COLLECT INTO ChargeLines_List;
    CLOSE ChargeLines;

    FOR i IN 1..ChargeLines_List.COUNT
    LOOP
        INL_LOGGING_PVT.Log_Variable(p_module_name    => g_module_name,
                                     p_procedure_name => l_api_name,
                                     p_var_name       => 'charge_line_id',
                                     p_var_value      => ChargeLines_List(i).charge_line_id);

        INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                       p_procedure_name => l_api_name,
                                       p_debug_info => 'Get the next Charge Line Id');

        -- Get Charge Line nextval
        SELECT inl_charge_lines_s.NEXTVAL
          INTO l_charge_line_id
          FROM dual;

        INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                       p_procedure_name => l_api_name,
                                       p_debug_info => 'Insert into INL_CHARGE_LINES');

        INSERT INTO inl_charge_lines (charge_line_id,
                                      charge_line_num,
                                      charge_line_type_id,
                                      landed_cost_flag,
                                      update_allowed,
                                      source_code,
                                      parent_charge_line_id,
                                      adjustment_num,
                                      match_id,
                                      match_amount_id,
                                      charge_amt,
                                      currency_code,
                                      currency_conversion_type,
                                      currency_conversion_date,
                                      currency_conversion_rate,
                                      party_id,
                                      party_site_id,
                                      trx_business_category,
                                      intended_use,
                                      product_fiscal_class,
                                      product_category,
                                      product_type,
                                      user_def_fiscal_class,
                                      tax_classification_code,
                                      assessable_value,
                                      tax_already_calculated_flag,
                                      ship_from_party_id,
                                      ship_from_party_site_id,
                                      ship_to_organization_id,
                                      ship_to_location_id,
                                      bill_from_party_id,
                                      bill_from_party_site_id,
                                      bill_to_organization_id,
                                      bill_to_location_id,
                                      poa_party_id,
                                      poa_party_site_id,
                                      poo_organization_id,
                                      poo_location_id,
                                      created_by,
                                      creation_date,
                                      last_updated_by,
                                      last_update_date,
                                      last_update_login)
                             VALUES  (l_charge_line_id,
                                      ChargeLines_List(i).charge_line_num,
                                      ChargeLines_List(i).charge_line_type_id,
                                      ChargeLines_List(i).landed_cost_flag,
                                      ChargeLines_List(i).update_allowed,
                                      ChargeLines_List(i).source_code,
                                      ChargeLines_List(i).parent_charge_line_id,
                                      ChargeLines_List(i).adjustment_num,
                                      ChargeLines_List(i).match_id,
                                      ChargeLines_List(i).match_amount_id,
                                      ChargeLines_List(i).charge_amt,
                                      ChargeLines_List(i).currency_code,
                                      ChargeLines_List(i).currency_conversion_type,
                                      ChargeLines_List(i).currency_conversion_date,
                                      ChargeLines_List(i).currency_conversion_rate,
                                      ChargeLines_List(i).party_id,
                                      ChargeLines_List(i).party_site_id,
                                      ChargeLines_List(i).trx_business_category,
                                      ChargeLines_List(i).intended_use,
                                      ChargeLines_List(i).product_fiscal_class,
                                      ChargeLines_List(i).product_category,
                                      ChargeLines_List(i).product_type,
                                      ChargeLines_List(i).user_def_fiscal_class,
                                      ChargeLines_List(i).tax_classification_code,
                                      ChargeLines_List(i).assessable_value,
                                      ChargeLines_List(i).tax_already_calculated_flag,
                                      ChargeLines_List(i).ship_from_party_id,
                                      ChargeLines_List(i).ship_from_party_site_id,
                                      ChargeLines_List(i).ship_to_organization_id,
                                      ChargeLines_List(i).ship_to_location_id,
                                      ChargeLines_List(i).bill_from_party_id,
                                      ChargeLines_List(i).bill_from_party_site_id,
                                      ChargeLines_List(i).bill_to_organization_id,
                                      ChargeLines_List(i).bill_to_location_id,
                                      ChargeLines_List(i).poa_party_id,
                                      ChargeLines_List(i).poa_party_site_id,
                                      ChargeLines_List(i).poo_organization_id,
                                      ChargeLines_List(i).poo_location_id,
                                      fnd_global.user_id,
                                      SYSDATE,
                                      fnd_global.user_id,
                                      SYSDATE,
                                      fnd_global.login_id);

        INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                       p_procedure_name => l_api_name,
                                       p_debug_info => 'Insert Charge association into INL_ASSOCIATIONS');

        INSERT INTO inl_associations (association_id,
                                      ship_header_id,
                                      from_parent_table_name,
                                      from_parent_table_id,
                                      to_parent_table_name,
                                      to_parent_table_id,
                                      allocation_basis,
                                      allocation_uom_code,
                                      created_by,
                                      creation_date,
                                      last_updated_by,
                                      last_update_date,
                                      last_update_login)
                              VALUES (inl_associations_s.NEXTVAL,
                                      p_new_ship_header_id,
                                      'INL_CHARGE_LINES',
                                      l_charge_line_id,
                                      p_to_parent_table_name,
                                      p_new_to_parent_table_id,
                                      ChargeLines_List(i).allocation_basis,
                                      ChargeLines_List(i).allocation_uom_code,
                                      fnd_global.user_id,
                                      SYSDATE,
                                      fnd_global.user_id,
                                      SYSDATE,
                                      fnd_global.login_id);
    END LOOP;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                              p_count => x_msg_count,
                              p_data => x_msg_data) ;

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(p_module_name    => g_module_name,
                                p_procedure_name => l_api_name);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (p_module_name    => g_module_name,
                                        p_procedure_name => l_api_name);
        ROLLBACK TO Duplicate_Charge_GRP;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                                  p_count   => x_msg_count,
                                  p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (p_module_name    => g_module_name,
                                          p_procedure_name => l_api_name);
       -- ROLLBACK TO Import_FromPO_GRP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_encoded  => FND_API.g_false,
                                  p_count    => x_msg_count,
                                  p_data     => x_msg_data);
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (p_module_name    => g_module_name,
                                          p_procedure_name => l_api_name);
        ROLLBACK TO Duplicate_Charge_GRP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(p_pkg_name       => g_pkg_name,
                                    p_procedure_name => l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                                  p_count   => x_msg_count,
                                  p_data    => x_msg_data);
END Duplicate_Charge;

-- API name   : Duplicate_ShipLines
-- Type       : Group
-- Function   : Duplicate all Shipment Lines for a given Simulated Line Group Id
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version                IN NUMBER
--              p_init_msg_list              IN VARCHAR2 := FND_API.G_FALSE
--              p_commit                     IN VARCHAR2 := FND_API.G_FALSE
--              p_current_ship_line_group_id IN  NUMBER
--              p_new_ship_line_group_id     IN  NUMBER
--
-- OUT        : x_return_status OUT NOCOPY VARCHAR2
--              x_msg_count     OUT NOCOPY NUMBER
--              x_msg_data      OUT NOCOPY VARCHAR2
--
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Duplicate_ShipLines (p_api_version                IN NUMBER,
                               p_init_msg_list              IN VARCHAR2 := FND_API.G_FALSE,
                               p_commit                     IN VARCHAR2 := FND_API.G_FALSE,
                               p_current_ship_line_group_id IN NUMBER,
                               p_new_ship_line_group_id     IN NUMBER,
                               x_return_status              OUT NOCOPY VARCHAR2,
                               x_msg_count                  OUT NOCOPY NUMBER,
                               x_msg_data                   OUT NOCOPY VARCHAR2) IS

    l_api_name CONSTANT VARCHAR2(30) := 'Duplicate_ShipLines';
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);
    l_api_version CONSTANT NUMBER := 1.0;
    l_debug_msg VARCHAR2(400);
    l_init_msg_list VARCHAR2(2000) := FND_API.G_FALSE;
    l_commit VARCHAR2(1) := FND_API.G_FALSE;

    l_ship_header_id NUMBER;
    l_ship_line_id NUMBER;
    l_from_association_tbl from_association_tbl;

    CURSOR ShipLines IS
        SELECT ship_header_id,
               ship_line_group_id,
               ship_line_id,
               ship_line_num,
               ship_line_type_id,
               ship_line_src_type_code,
               ship_line_source_id,
               parent_ship_line_id,
               adjustment_num,
               match_id,
               currency_code,
               currency_conversion_type,
               currency_conversion_date,
               currency_conversion_rate,
               inventory_item_id,
               txn_qty,
               txn_uom_code,
               txn_unit_price,
               primary_qty,
               primary_uom_code,
               primary_unit_price,
               secondary_qty,
               secondary_uom_code,
               secondary_unit_price,
               landed_cost_flag,
               allocation_enabled_flag,
               trx_business_category,
               intended_use,
               product_fiscal_class,
               product_category,
               product_type,
               user_def_fiscal_class,
               tax_classification_code,
               assessable_value,
               tax_already_calculated_flag,
               ship_from_party_id,
               ship_from_party_site_id,
               ship_to_organization_id,
               ship_to_location_id,
               bill_from_party_id,
               bill_from_party_site_id,
               bill_to_organization_id,
               bill_to_location_id,
               poa_party_id,
               poa_party_site_id,
               poo_organization_id,
               poo_location_id,
               org_id,
               ship_line_int_id,
               interface_source_table,
               interface_source_line_id,
               created_by,
               creation_date,
               last_updated_by,
               last_update_date,
               last_update_login,
               program_id,
               program_update_date,
               program_application_id,
               request_id,
               attribute_category,
               attribute1,
               attribute2,
               attribute3,
               attribute4,
               attribute5,
               attribute6,
               attribute7,
               attribute8,
               attribute9,
               attribute10,
               attribute11,
               attribute12,
               attribute13,
               attribute14,
               attribute15,
               nrq_zero_exception_flag
          FROM inl_ship_lines_all
         WHERE ship_line_group_id = p_current_ship_line_group_id;

    TYPE ShipLines_List_Type IS
    TABLE OF ShipLines%ROWTYPE;
    ShipLines_List ShipLines_List_Type;

BEGIN

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(p_module_name    => g_module_name,
                                  p_procedure_name => l_api_name) ;

    -- Standard Start of API savepoint
    SAVEPOINT Duplicate_ShipLines_GRP;

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
                                  p_var_name => 'p_current_ship_line_group_id',
                                  p_var_value => p_current_ship_line_group_id);
    INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                  p_procedure_name => l_api_name,
                                  p_var_name => 'p_new_ship_line_group_id',
                                  p_var_value => p_new_ship_line_group_id);

    INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                   p_procedure_name => l_api_name,
                                   p_debug_info => 'Get Shipment Header Id');
    SELECT ship_header_id
    INTO l_ship_header_id
    FROM inl_ship_line_groups
    WHERE ship_line_group_id = p_new_ship_line_group_id;

    OPEN ShipLines;
    FETCH ShipLines BULK COLLECT INTO ShipLines_List;
    CLOSE ShipLines;

    FOR i IN 1..ShipLines_List.COUNT
    LOOP
        INL_LOGGING_PVT.Log_Variable(p_module_name    => g_module_name,
                                     p_procedure_name => l_api_name,
                                     p_var_name       => 'ship_line_id',
                                     p_var_value      => ShipLines_List(i).ship_line_id);

        INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                       p_procedure_name => l_api_name,
                                       p_debug_info => 'Get the next Shipment Line Id');

        -- Get Shipment Lines's nextval
        SELECT inl_ship_lines_all_s.NEXTVAL
          INTO l_ship_line_id
          FROM dual;

        INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                       p_procedure_name => l_api_name,
                                       p_debug_info => 'Insert into INL_SHIP_LINES_ALL');

        INSERT INTO inl_ship_lines_all (ship_header_id,
                                        ship_line_group_id,
                                        ship_line_id,
                                        ship_line_num,
                                        ship_line_type_id,
                                        ship_line_src_type_code,
                                        ship_line_source_id,
                                        parent_ship_line_id,
                                        adjustment_num,
                                        match_id,
                                        currency_code,
                                        currency_conversion_type,
                                        currency_conversion_date,
                                        currency_conversion_rate,
                                        inventory_item_id,
                                        txn_qty,
                                        txn_uom_code,
                                        txn_unit_price,
                                        primary_qty,
                                        primary_uom_code,
                                        primary_unit_price,
                                        secondary_qty,
                                        secondary_uom_code,
                                        secondary_unit_price,
                                        landed_cost_flag,
                                        allocation_enabled_flag,
                                        trx_business_category,
                                        intended_use,
                                        product_fiscal_class,
                                        product_category,
                                        product_type,
                                        user_def_fiscal_class,
                                        tax_classification_code,
                                        assessable_value,
                                        tax_already_calculated_flag,
                                        ship_from_party_id,
                                        ship_from_party_site_id,
                                        ship_to_organization_id,
                                        ship_to_location_id,
                                        bill_from_party_id,
                                        bill_from_party_site_id,
                                        bill_to_organization_id,
                                        bill_to_location_id,
                                        poa_party_id,
                                        poa_party_site_id,
                                        poo_organization_id,
                                        poo_location_id,
                                        org_id,
                                        ship_line_int_id,
                                        interface_source_table,
                                        interface_source_line_id,
                                        created_by,
                                        creation_date,
                                        last_updated_by,
                                        last_update_date,
                                        last_update_login,
                                        program_id,
                                        program_update_date,
                                        program_application_id,
                                        request_id,
                                        attribute_category,
                                        attribute1,
                                        attribute2,
                                        attribute3,
                                        attribute4,
                                        attribute5,
                                        attribute6,
                                        attribute7,
                                        attribute8,
                                        attribute9,
                                        attribute10,
                                        attribute11,
                                        attribute12,
                                        attribute13,
                                        attribute14,
                                        attribute15,
                                        nrq_zero_exception_flag)
                               VALUES  (l_ship_header_id,
                                        p_new_ship_line_group_id,
                                        l_ship_line_id,
                                        ShipLines_List(i).ship_line_num,
                                        ShipLines_List(i).ship_line_type_id,
                                        ShipLines_List(i).ship_line_src_type_code,
                                        ShipLines_List(i).ship_line_source_id,
                                        ShipLines_List(i).parent_ship_line_id,
                                        ShipLines_List(i).adjustment_num,
                                        ShipLines_List(i).match_id,
                                        ShipLines_List(i).currency_code,
                                        ShipLines_List(i).currency_conversion_type,
                                        ShipLines_List(i).currency_conversion_date,
                                        ShipLines_List(i).currency_conversion_rate,
                                        ShipLines_List(i).inventory_item_id,
                                        ShipLines_List(i).txn_qty,
                                        ShipLines_List(i).txn_uom_code,
                                        ShipLines_List(i).txn_unit_price,
                                        ShipLines_List(i).primary_qty,
                                        ShipLines_List(i).primary_uom_code,
                                        ShipLines_List(i).primary_unit_price,
                                        ShipLines_List(i).secondary_qty,
                                        ShipLines_List(i).secondary_uom_code,
                                        ShipLines_List(i).secondary_unit_price,
                                        ShipLines_List(i).landed_cost_flag,
                                        ShipLines_List(i).allocation_enabled_flag,
                                        ShipLines_List(i).trx_business_category,
                                        ShipLines_List(i).intended_use,
                                        ShipLines_List(i).product_fiscal_class,
                                        ShipLines_List(i).product_category,
                                        ShipLines_List(i).product_type,
                                        ShipLines_List(i).user_def_fiscal_class,
                                        ShipLines_List(i).tax_classification_code,
                                        ShipLines_List(i).assessable_value,
                                        ShipLines_List(i).tax_already_calculated_flag,
                                        ShipLines_List(i).ship_from_party_id,
                                        ShipLines_List(i).ship_from_party_site_id,
                                        ShipLines_List(i).ship_to_organization_id,
                                        ShipLines_List(i).ship_to_location_id,
                                        ShipLines_List(i).bill_from_party_id,
                                        ShipLines_List(i).bill_from_party_site_id,
                                        ShipLines_List(i).bill_to_organization_id,
                                        ShipLines_List(i).bill_to_location_id,
                                        ShipLines_List(i).poa_party_id,
                                        ShipLines_List(i).poa_party_site_id,
                                        ShipLines_List(i).poo_organization_id,
                                        ShipLines_List(i).poo_location_id,
                                        ShipLines_List(i).org_id,
                                        NULL, -- ship_line_int_id
                                        ShipLines_List(i).interface_source_table,
                                        ShipLines_List(i).interface_source_line_id,
                                        fnd_global.user_id,
                                        SYSDATE,
                                        fnd_global.user_id,
                                        SYSDATE,
                                        fnd_global.login_id,
                                        ShipLines_List(i).program_id,
                                        ShipLines_List(i).program_update_date,
                                        ShipLines_List(i).program_application_id,
                                        ShipLines_List(i).request_id,
                                        ShipLines_List(i).attribute_category,
                                        ShipLines_List(i).attribute1,
                                        ShipLines_List(i).attribute2,
                                        ShipLines_List(i).attribute3,
                                        ShipLines_List(i).attribute4,
                                        ShipLines_List(i).attribute5,
                                        ShipLines_List(i).attribute6,
                                        ShipLines_List(i).attribute7,
                                        ShipLines_List(i).attribute8,
                                        ShipLines_List(i).attribute9,
                                        ShipLines_List(i).attribute10,
                                        ShipLines_List(i).attribute11,
                                        ShipLines_List(i).attribute12,
                                        ShipLines_List(i).attribute13,
                                        ShipLines_List(i).attribute14,
                                        ShipLines_List(i).attribute15,
                                        ShipLines_List(i).nrq_zero_exception_flag);

        INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                       p_procedure_name => l_api_name,
                                       p_debug_info => 'Check if exists Associations for the copyed Ship. Line');

        BEGIN
            SELECT from_parent_table_name,
                   from_parent_table_id
            BULK COLLECT INTO l_from_association_tbl
               FROM inl_associations
              WHERE to_parent_table_name = 'INL_SHIP_LINES'
                AND to_parent_table_id = ShipLines_List(i).ship_line_id
                AND ship_header_id = ShipLines_List(i).ship_header_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;

        -- Generate associated Charges/Taxes for the new Shipment Line
        FOR j IN 1..l_from_association_tbl.COUNT LOOP
            INL_LOGGING_PVT.Log_Variable(p_module_name    => g_module_name,
                                         p_procedure_name => l_api_name,
                                         p_var_name       => 'from_parent_table_name',
                                         p_var_value      => l_from_association_tbl(j).from_parent_table_name);
            INL_LOGGING_PVT.Log_Variable(p_module_name    => g_module_name,
                                         p_procedure_name => l_api_name,
                                         p_var_name       => 'from_parent_table_id',
                                         p_var_value      => l_from_association_tbl(j).from_parent_table_id);

            IF l_from_association_tbl(j).from_parent_table_name = 'INL_CHARGE_LINES' THEN
                INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                               p_procedure_name => l_api_name,
                                               p_debug_info => 'Call Duplicate_Charge');

                Duplicate_Charge (p_api_version                => 1.0,
                                  p_init_msg_list              => l_init_msg_list,
                                  p_commit                     => l_commit,
                                  p_current_ship_header_id     => ShipLines_List(i).ship_header_id,
                                  p_new_ship_header_id         => l_ship_header_id,
                                  p_from_parent_table_id       => l_from_association_tbl(j).from_parent_table_id,
                                  p_to_parent_table_name       => 'INL_SHIP_LINES',
                                  p_current_to_parent_table_id => ShipLines_List(i).ship_line_id,
                                  p_new_to_parent_table_id     => l_ship_line_id,
                                  x_return_status              => l_return_status,
                                  x_msg_count                  => l_msg_count,
                                  x_msg_data                   => l_msg_data);

                -- If any errors happen abort the process.
                IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;

            ELSIF l_from_association_tbl(j).from_parent_table_name = 'INL_TAX_LINES' THEN
                INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                               p_procedure_name => l_api_name,
                                               p_debug_info => 'Call Duplicate_Tax');

                Duplicate_Tax (p_api_version                   => 1.0,
                               p_init_msg_list              => l_init_msg_list,
                               p_commit                     => l_commit,
                               p_current_ship_header_id     => ShipLines_List(i).ship_header_id,
                               p_new_ship_header_id         => l_ship_header_id,
                               p_from_parent_table_id       => l_from_association_tbl(j).from_parent_table_id,
                               p_to_parent_table_name       => 'INL_SHIP_LINES',
                               p_current_to_parent_table_id => ShipLines_List(i).ship_line_id,
                               p_new_to_parent_table_id     => l_ship_line_id,
                               x_return_status              => l_return_status,
                               x_msg_count                  => l_msg_count,
                               x_msg_data                   => l_msg_data);

                -- If any errors happen abort the process.
                IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
            END IF;
        END LOOP;
    END LOOP;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                              p_count => x_msg_count,
                              p_data => x_msg_data) ;

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(p_module_name    => g_module_name,
                                p_procedure_name => l_api_name);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (p_module_name    => g_module_name,
                                        p_procedure_name => l_api_name);
        ROLLBACK TO Duplicate_ShipLines_GRP;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                                  p_count   => x_msg_count,
                                  p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (p_module_name    => g_module_name,
                                          p_procedure_name => l_api_name);
       -- ROLLBACK TO Import_FromPO_GRP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_encoded  => FND_API.g_false,
                                  p_count    => x_msg_count,
                                  p_data     => x_msg_data);
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (p_module_name    => g_module_name,
                                          p_procedure_name => l_api_name);
        ROLLBACK TO Duplicate_ShipLines_GRP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(p_pkg_name       => g_pkg_name,
                                    p_procedure_name => l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                                  p_count   => x_msg_count,
                                  p_data    => x_msg_data);
END Duplicate_ShipLines;

-- API name   : Duplicate_LineGroups
-- Type       : Group
-- Function   : Duplicate all Line Groups for a given Simulated Shipment Header Id
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version            IN NUMBER
--              p_init_msg_list          IN VARCHAR2 := FND_API.G_FALSE
--              p_commit                 IN VARCHAR2 := FND_API.G_FALSE
--              p_current_ship_header_id IN  NUMBER
--              p_new_ship_header_id     IN  NUMBER
--
-- OUT        : x_return_status OUT NOCOPY VARCHAR2
--              x_msg_count     OUT NOCOPY NUMBER
--              x_msg_data      OUT NOCOPY VARCHAR2
--
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Duplicate_LineGroups (p_api_version            IN NUMBER,
                                p_init_msg_list          IN VARCHAR2 := FND_API.G_FALSE,
                                p_commit                 IN VARCHAR2 := FND_API.G_FALSE,
                                p_current_ship_header_id IN NUMBER,
                                p_new_ship_header_id     IN NUMBER,
                                x_return_status          OUT NOCOPY VARCHAR2,
                                x_msg_count              OUT NOCOPY NUMBER,
                                x_msg_data               OUT NOCOPY VARCHAR2) IS

    l_api_name CONSTANT VARCHAR2(30) := 'Duplicate_LineGroups';
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);
    l_api_version CONSTANT NUMBER := 1.0;
    l_init_msg_list VARCHAR2(2000) := FND_API.G_FALSE;
    l_commit VARCHAR2(1) := FND_API.G_FALSE;
    l_debug_msg VARCHAR2(400);

    l_ship_line_group_id NUMBER;
    l_from_association_tbl from_association_tbl;

    CURSOR LineGroups IS
        SELECT ship_line_group_id,
               ship_line_group_reference,
               ship_header_id,
               ship_line_group_num,
               src_type_code,
               party_id,
               party_site_id,
               source_organization_id,
               ship_line_int_id,
               interface_source_table,
               interface_source_line_id,
               created_by,
               creation_date,
               last_updated_by,
               last_update_date,
               last_update_login,
               program_id,
               program_update_date,
               program_application_id,
               request_id,
               attribute_category,
               attribute1,
               attribute2,
               attribute3,
               attribute4,
               attribute5,
               attribute6,
               attribute7,
               attribute8,
               attribute9,
               attribute10,
               attribute11,
               attribute12,
               attribute13,
               attribute14,
               attribute15
          FROM inl_ship_line_groups
         WHERE ship_header_id = p_current_ship_header_id;

    TYPE LineGroups_List_Type IS
    TABLE OF LineGroups%ROWTYPE;
    LineGroups_List LineGroups_List_Type;

BEGIN

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(p_module_name    => g_module_name,
                                  p_procedure_name => l_api_name) ;

    -- Standard Start of API savepoint
    SAVEPOINT Duplicate_LineGroups_GRP;

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
                                  p_var_name => 'p_current_ship_header_id',
                                  p_var_value => p_current_ship_header_id);
    INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                  p_procedure_name => l_api_name,
                                  p_var_name => 'p_new_ship_header_id',
                                  p_var_value => p_new_ship_header_id);

    OPEN LineGroups;
    FETCH LineGroups BULK COLLECT INTO LineGroups_List;
    CLOSE LineGroups;

    FOR i IN 1..LineGroups_List.COUNT
    LOOP
        INL_LOGGING_PVT.Log_Variable(p_module_name    => g_module_name,
                                     p_procedure_name => l_api_name,
                                     p_var_name       => 'ship_line_group_id',
                                     p_var_value      => LineGroups_List(i).ship_line_group_id);

        INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                       p_procedure_name => l_api_name,
                                       p_debug_info => 'Get the next Line Group Id');

        -- Get Shipment Header's nextval
        SELECT inl_ship_line_groups_s.NEXTVAL
          INTO l_ship_line_group_id
          FROM dual;

        INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                       p_procedure_name => l_api_name,
                                       p_debug_info => 'Insert into INL_SHIP_LINE_GROUPS');

        INSERT INTO inl_ship_line_groups (ship_line_group_id,
                                          ship_line_group_reference,
                                          ship_header_id,
                                          ship_line_group_num,
                                          src_type_code,
                                          party_id,
                                          party_site_id,
                                          source_organization_id,
                                          ship_line_int_id,
                                          interface_source_table,
                                          interface_source_line_id,
                                          created_by,
                                          creation_date,
                                          last_updated_by,
                                          last_update_date,
                                          last_update_login,
                                          program_id,
                                          program_update_date,
                                          program_application_id,
                                          request_id,
                                          attribute_category,
                                          attribute1,
                                          attribute2,
                                          attribute3,
                                          attribute4,
                                          attribute5,
                                          attribute6,
                                          attribute7,
                                          attribute8,
                                          attribute9,
                                          attribute10,
                                          attribute11,
                                          attribute12,
                                          attribute13,
                                          attribute14,
                                          attribute15)
                                 VALUES  (l_ship_line_group_id,
                                          LineGroups_List(i).ship_line_group_reference,
                                          p_new_ship_header_id,
                                          LineGroups_List(i).ship_line_group_num,
                                          LineGroups_List(i).src_type_code,
                                          LineGroups_List(i).party_id,
                                          LineGroups_List(i).party_site_id,
                                          LineGroups_List(i).source_organization_id,
                                          NULL, --ship_line_int_id
                                          LineGroups_List(i).interface_source_table,
                                          LineGroups_List(i).interface_source_line_id,
                                          fnd_global.user_id,
                                          SYSDATE,
                                          fnd_global.user_id,
                                          SYSDATE,
                                          fnd_global.login_id,
                                          LineGroups_List(i).program_id,
                                          LineGroups_List(i).program_update_date,
                                          LineGroups_List(i).program_application_id,
                                          LineGroups_List(i).request_id,
                                          LineGroups_List(i).attribute_category,
                                          LineGroups_List(i).attribute1,
                                          LineGroups_List(i).attribute2,
                                          LineGroups_List(i).attribute3,
                                          LineGroups_List(i).attribute4,
                                          LineGroups_List(i).attribute5,
                                          LineGroups_List(i).attribute6,
                                          LineGroups_List(i).attribute7,
                                          LineGroups_List(i).attribute8,
                                          LineGroups_List(i).attribute9,
                                          LineGroups_List(i).attribute10,
                                          LineGroups_List(i).attribute11,
                                          LineGroups_List(i).attribute12,
                                          LineGroups_List(i).attribute13,
                                          LineGroups_List(i).attribute14,
                                          LineGroups_List(i).attribute15);

        INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                       p_procedure_name => l_api_name,
                                       p_debug_info => 'Check if exists Associations for the copyed Ship. Line Group');

        BEGIN
            SELECT from_parent_table_name,
                   from_parent_table_id
            BULK COLLECT INTO l_from_association_tbl
                FROM inl_associations
                WHERE to_parent_table_name = 'INL_SHIP_LINE_GROUPS'
                  AND to_parent_table_id = LineGroups_List(i).ship_line_group_id
                  AND ship_header_id = p_current_ship_header_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;

        -- Generate associated Charges for the new Line Group
        FOR j IN 1..l_from_association_tbl.COUNT LOOP
            INL_LOGGING_PVT.Log_Variable(p_module_name    => g_module_name,
                                         p_procedure_name => l_api_name,
                                         p_var_name       => 'from_parent_table_name',
                                         p_var_value      => l_from_association_tbl(j).from_parent_table_name);
            INL_LOGGING_PVT.Log_Variable(p_module_name    => g_module_name,
                                         p_procedure_name => l_api_name,
                                         p_var_name       => 'from_parent_table_id',
                                         p_var_value      => l_from_association_tbl(j).from_parent_table_id);

            IF l_from_association_tbl(j).from_parent_table_name = 'INL_CHARGE_LINES' THEN
                INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                               p_procedure_name => l_api_name,
                                               p_debug_info => 'Call Duplicate_Charge');

                Duplicate_Charge (p_api_version                => 1.0,
                                  p_init_msg_list              => l_init_msg_list,
                                  p_commit                     => l_commit,
                                  p_current_ship_header_id     => p_current_ship_header_id,
                                  p_new_ship_header_id         => p_new_ship_header_id,
                                  p_from_parent_table_id       => l_from_association_tbl(j).from_parent_table_id,
                                  p_to_parent_table_name       => 'INL_SHIP_LINE_GROUPS',
                                  p_current_to_parent_table_id => LineGroups_List(i).ship_line_group_id,
                                  p_new_to_parent_table_id     => l_ship_line_group_id,
                                  x_return_status              => l_return_status,
                                  x_msg_count                  => l_msg_count,
                                  x_msg_data                   => l_msg_data);

                -- If any errors happen abort the process.
                IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
            END IF;
        END LOOP;

        INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                       p_procedure_name => l_api_name,
                                       p_debug_info => 'Call Duplicate_ShipLines');

        Duplicate_ShipLines (p_api_version                => 1.0,
                             p_init_msg_list              => l_init_msg_list,
                             p_commit                     => l_commit,
                             p_current_ship_line_group_id => LineGroups_List(i).ship_line_group_id,
                             p_new_ship_line_group_id     => l_ship_line_group_id,
                             x_return_status              => l_return_status,
                             x_msg_count                  => l_msg_count,
                             x_msg_data                   => l_msg_data);

        -- If any errors happen abort the process.
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END LOOP;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                              p_count => x_msg_count,
                              p_data => x_msg_data) ;

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(p_module_name    => g_module_name,
                                p_procedure_name => l_api_name);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (p_module_name    => g_module_name,
                                        p_procedure_name => l_api_name);
        ROLLBACK TO Duplicate_LineGroups_GRP;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                                  p_count   => x_msg_count,
                                  p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (p_module_name    => g_module_name,
                                          p_procedure_name => l_api_name);
       -- ROLLBACK TO Import_FromPO_GRP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_encoded  => FND_API.g_false,
                                  p_count    => x_msg_count,
                                  p_data     => x_msg_data);
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (p_module_name    => g_module_name,
                                          p_procedure_name => l_api_name);
        ROLLBACK TO Duplicate_LineGroups_GRP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(p_pkg_name       => g_pkg_name,
                                    p_procedure_name => l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                                  p_count   => x_msg_count,
                                  p_data    => x_msg_data);
END Duplicate_LineGroups;

-- API name   : Duplicate_ShipHeaders
-- Type       : Group
-- Function   : Duplicated all Simulated Shipment Headers for a given Simulation Id
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version           IN NUMBER
--              p_init_msg_list         IN VARCHAR2 := FND_API.G_FALSE
--              p_commit                IN VARCHAR2 := FND_API.G_FALSE
--              p_current_simulation_id IN  NUMBER
--              p_new_simulation_id     IN  NUMBER
--
-- OUT        : x_return_status OUT NOCOPY VARCHAR2
--              x_msg_count     OUT NOCOPY NUMBER
--              x_msg_data      OUT NOCOPY VARCHAR2
--
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Duplicate_ShipHeaders (p_api_version           IN NUMBER,
                                 p_init_msg_list         IN VARCHAR2 := FND_API.G_FALSE,
                                 p_commit                IN VARCHAR2 := FND_API.G_FALSE,
                                 p_current_simulation_id IN NUMBER,
                                 p_new_simulation_id     IN NUMBER,
                                 x_return_status         OUT NOCOPY VARCHAR2,
                                 x_msg_count             OUT NOCOPY NUMBER,
                                 x_msg_data              OUT NOCOPY VARCHAR2) IS

    l_api_name CONSTANT VARCHAR2(30) := 'Duplicate_ShipHeaders';
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);
    l_api_version CONSTANT NUMBER := 1.0;
    l_debug_msg VARCHAR2(400);
    l_init_msg_list VARCHAR2(2000) := FND_API.G_FALSE;
    l_commit VARCHAR2(1) := FND_API.G_FALSE;

    l_ship_num VARCHAR2(25);
    l_next_ship_num VARCHAR2(25);
    l_ship_header_id NUMBER;
    l_from_parent_table_name VARCHAR2(30);
    l_from_parent_table_id NUMBER;
    l_from_association_tbl from_association_tbl;
    l_simulation_rec simulation_rec;
    l_src_number VARCHAR2(20);
    l_sequence NUMBER := 1;

    CURSOR ShipHeaders IS
        SELECT ship_header_id,
               ship_num,
               ship_date,
               ship_type_id,
               ship_status_code,
               pending_matching_flag,
               legal_entity_id,
               organization_id,
               location_id,
               org_id,
               taxation_country,
               document_sub_type,
               ship_header_int_id,
               interface_source_code,
               interface_source_table,
               interface_source_line_id,
               simulation_id,
               adjustment_num,
               created_by,
               creation_date,
               last_updated_by,
               last_update_date,
               last_update_login,
               program_id,
               program_update_date,
               program_application_id,
               request_id,
               attribute_category,
               attribute1,
               attribute2,
               attribute3,
               attribute4,
               attribute5,
               attribute6,
               attribute7,
               attribute8,
               attribute9,
               attribute10,
               attribute11,
               attribute12,
               attribute13,
               attribute14,
               attribute15,
               rcv_enabled_flag
          FROM inl_ship_headers_all
         WHERE simulation_id = p_current_simulation_id;

    TYPE ShipHeaders_List_Type IS
    TABLE OF ShipHeaders%ROWTYPE;
    ShipHeaders_List ShipHeaders_List_Type;

BEGIN

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(p_module_name    => g_module_name,
                                  p_procedure_name => l_api_name) ;

    -- Standard Start of API savepoint
    SAVEPOINT Duplicate_ShipHeaders_GRP;

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
                                  p_var_name => 'p_current_simulation_id',
                                  p_var_value => p_current_simulation_id);
    INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                  p_procedure_name => l_api_name,
                                  p_var_name => 'p_new_simulation_id',
                                  p_var_value => p_new_simulation_id);

    OPEN ShipHeaders;
    FETCH ShipHeaders BULK COLLECT INTO ShipHeaders_List;
    CLOSE ShipHeaders;

    FOR i IN 1..ShipHeaders_List.COUNT
    LOOP
        INL_LOGGING_PVT.Log_Variable(p_module_name    => g_module_name,
                                     p_procedure_name => l_api_name,
                                     p_var_name       => 'ship_header_id',
                                     p_var_value      => ShipHeaders_List(i).ship_header_id);

        INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                       p_procedure_name => l_api_name,
                                       p_debug_info => 'Select data from_association_rec INL_SIMULATIONS');

        SELECT s.simulation_id,
               'N',
               s.parent_table_name,
               s.parent_table_id,
               s.parent_table_revision_num,
               s.version_num,
               s.vendor_id,
               s.vendor_site_id,
               s.freight_code
          INTO l_simulation_rec.simulation_id,
               l_simulation_rec.firmed_flag,
               l_simulation_rec.parent_table_name,
               l_simulation_rec.parent_table_id,
               l_simulation_rec.parent_table_revision_num,
               l_simulation_rec.version_num,
               l_simulation_rec.vendor_id,
               l_simulation_rec.vendor_site_id,
               l_simulation_rec.freight_code
          FROM inl_simulations s
         WHERE s.simulation_id = p_new_simulation_id;

        INL_LOGGING_PVT.Log_Variable(p_module_name    => g_module_name,
                                     p_procedure_name => l_api_name,
                                     p_var_name       => 'l_simulation_rec.parent_table_name',
                                     p_var_value      => l_simulation_rec.parent_table_name);
        INL_LOGGING_PVT.Log_Variable(p_module_name    => g_module_name,
                                     p_procedure_name => l_api_name,
                                     p_var_name       => 'l_simulation_rec.parent_table_revision_num',
                                     p_var_value      => l_simulation_rec.parent_table_revision_num);
        INL_LOGGING_PVT.Log_Variable(p_module_name    => g_module_name,
                                     p_procedure_name => l_api_name,
                                     p_var_name       => 'l_simulation_rec.version_num',
                                     p_var_value      => l_simulation_rec.version_num);
        INL_LOGGING_PVT.Log_Variable(p_module_name    => g_module_name,
                                     p_procedure_name => l_api_name,
                                     p_var_name       => 'l_simulation_rec.version_num',
                                     p_var_value      => l_simulation_rec.version_num);
        INL_LOGGING_PVT.Log_Variable(p_module_name    => g_module_name,
                                     p_procedure_name => l_api_name,
                                     p_var_name       => 'l_sequence',
                                     p_var_value      => l_sequence);

        IF l_simulation_rec.parent_table_name = 'PO_HEADERS' THEN
            SELECT segment1
              INTO l_src_number
              FROM po_headers_all ph
             WHERE ph.po_header_id = l_simulation_rec.parent_table_id;
        ELSIF l_simulation_rec.parent_table_name = 'PO_RELEASES' THEN -- Bug 14280113
            SELECT segment1
              INTO l_src_number
              FROM po_headers_all ph,
                   po_releases_all pr
             WHERE ph.po_header_id = pr.po_header_id
             AND pr.po_release_id = l_simulation_rec.parent_table_id;
        END IF;

        INL_LOGGING_PVT.Log_Variable(p_module_name    => g_module_name,
                                     p_procedure_name => l_api_name,
                                     p_var_name       => 'l_src_number',
                                     p_var_value      => l_src_number);

        INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                       p_procedure_name => l_api_name,
                                       p_debug_info => 'Call INL_CUSTOM_PUB.Get_SimulShipNum');

        INL_CUSTOM_PUB.Get_SimulShipNum(p_simulation_rec => l_simulation_rec,
                                        p_document_number => l_src_number,
                                        p_organization_id => ShipHeaders_List(i).organization_id,
                                        p_sequence => l_sequence,
                                        x_ship_num => l_next_ship_num,
                                        x_return_status => l_return_status);

        l_sequence := l_sequence + 1;

        INL_LOGGING_PVT.Log_Variable(p_module_name    => g_module_name,
                                     p_procedure_name => l_api_name,
                                     p_var_name       => 'l_next_ship_num',
                                     p_var_value      => l_next_ship_num);

        INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                       p_procedure_name => l_api_name,
                                       p_debug_info => 'Get the next Shipment Header Id');

        -- Get Shipment Header's nextval
        SELECT inl_ship_headers_all_s.NEXTVAL
          INTO l_ship_header_id
          FROM dual;

        INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                       p_procedure_name => l_api_name,
                                       p_debug_info => 'Insert into INL_SHIP_HEADERS_ALL');

        INSERT INTO inl_ship_headers_all (ship_header_id,
                                          ship_num,
                                          ship_date,
                                          ship_type_id,
                                          ship_status_code,
                                          pending_matching_flag,
                                          rcv_enabled_flag,
                                          legal_entity_id,
                                          organization_id,
                                          location_id,
                                          org_id,
                                          taxation_country,
                                          document_sub_type,
                                          ship_header_int_id,
                                          interface_source_code,
                                          interface_source_table,
                                          interface_source_line_id,
                                          simulation_id,
                                          adjustment_num,
                                          created_by,
                                          creation_date,
                                          last_updated_by,
                                          last_update_date,
                                          last_update_login,
                                          program_id,
                                          program_update_date,
                                          program_application_id,
                                          request_id,
                                          attribute_category,
                                          attribute1,
                                          attribute2,
                                          attribute3,
                                          attribute4,
                                          attribute5,
                                          attribute6,
                                          attribute7,
                                          attribute8,
                                          attribute9,
                                          attribute10,
                                          attribute11,
                                          attribute12,
                                          attribute13,
                                          attribute14,
                                          attribute15)
                                 VALUES  (l_ship_header_id,
                                          l_next_ship_num,
                                          SYSDATE, -- ship_date
                                          ShipHeaders_List(i).ship_type_id,
                                          'INCOMPLETE',
                                          NULL, -- pending_matching_flag
                                          ShipHeaders_List(i).rcv_enabled_flag,
                                          ShipHeaders_List(i).legal_entity_id,
                                          ShipHeaders_List(i).organization_id,
                                          ShipHeaders_List(i).location_id,
                                          ShipHeaders_List(i).org_id,
                                          ShipHeaders_List(i).taxation_country,
                                          ShipHeaders_List(i).document_sub_type,
                                          NULL, -- ship_header_int_id
                                          ShipHeaders_List(i).interface_source_code,
                                          ShipHeaders_List(i).interface_source_table,
                                          ShipHeaders_List(i).interface_source_line_id,
                                          p_new_simulation_id,
                                          0,
                                          fnd_global.user_id,
                                          SYSDATE,
                                          fnd_global.user_id,
                                          SYSDATE,
                                          fnd_global.login_id,
                                          fnd_global.conc_program_id,
                                          SYSDATE,
                                          fnd_global.prog_appl_id,
                                          fnd_global.conc_request_id,
                                          ShipHeaders_List(i).attribute_category,
                                          ShipHeaders_List(i).attribute1,
                                          ShipHeaders_List(i).attribute2,
                                          ShipHeaders_List(i).attribute3,
                                          ShipHeaders_List(i).attribute4,
                                          ShipHeaders_List(i).attribute5,
                                          ShipHeaders_List(i).attribute6,
                                          ShipHeaders_List(i).attribute7,
                                          ShipHeaders_List(i).attribute8,
                                          ShipHeaders_List(i).attribute9,
                                          ShipHeaders_List(i).attribute10,
                                          ShipHeaders_List(i).attribute11,
                                          ShipHeaders_List(i).attribute12,
                                          ShipHeaders_List(i).attribute13,
                                          ShipHeaders_List(i).attribute14,
                                          ShipHeaders_List(i).attribute15);

        INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                       p_procedure_name => l_api_name,
                                       p_debug_info => 'Check if exists Associations for the copyed Ship. Header');

        BEGIN
            SELECT from_parent_table_name,
                   from_parent_table_id
            BULK COLLECT INTO l_from_association_tbl
              FROM inl_associations
             WHERE to_parent_table_name = 'INL_SHIP_HEADERS'
               AND to_parent_table_id = ShipHeaders_List(i).ship_header_id
               AND ship_header_id = ShipHeaders_List(i).ship_header_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_from_parent_table_name := NULL;
                l_from_parent_table_id := NULL;
        END;

        -- Generate associated Charges for the new Shipment Header
        FOR j IN 1..l_from_association_tbl.COUNT LOOP
            INL_LOGGING_PVT.Log_Variable(p_module_name    => g_module_name,
                                         p_procedure_name => l_api_name,
                                         p_var_name       => 'from_parent_table_name',
                                         p_var_value      => l_from_association_tbl(j).from_parent_table_name);
            INL_LOGGING_PVT.Log_Variable(p_module_name    => g_module_name,
                                         p_procedure_name => l_api_name,
                                         p_var_name       => 'from_parent_table_id',
                                         p_var_value      => l_from_association_tbl(j).from_parent_table_id);

            IF l_from_association_tbl(j).from_parent_table_name = 'INL_CHARGE_LINES' THEN
                INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                               p_procedure_name => l_api_name,
                                               p_debug_info => 'Call Duplicate_Charge');

                Duplicate_Charge (p_api_version                => 1.0,
                                  p_init_msg_list              => l_init_msg_list,
                                  p_commit                     => l_commit,
                                  p_current_ship_header_id     => ShipHeaders_List(i).ship_header_id,
                                  p_new_ship_header_id         => l_ship_header_id,
                                  p_from_parent_table_id       => l_from_association_tbl(j).from_parent_table_id,
                                  p_to_parent_table_name       => 'INL_SHIP_HEADERS',
                                  p_current_to_parent_table_id => ShipHeaders_List(i).ship_header_id,
                                  p_new_to_parent_table_id     => l_ship_header_id,
                                  x_return_status              => l_return_status,
                                  x_msg_count                  => l_msg_count,
                                  x_msg_data                   => l_msg_data);

                -- If any errors happen abort the process.
                IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
            END IF;
        END LOOP;

        INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                       p_procedure_name => l_api_name,
                                       p_debug_info => 'Call Duplicate_LineGroups');

        Duplicate_LineGroups (p_api_version            => 1.0,
                              p_init_msg_list          => l_init_msg_list,
                              p_commit                 => l_commit,
                              p_current_ship_header_id => ShipHeaders_List(i).ship_header_id,
                              p_new_ship_header_id     => l_ship_header_id,
                              x_return_status          => l_return_status,
                              x_msg_count              => l_msg_count,
                              x_msg_data               => l_msg_data);

        -- If any errors happen abort the process.
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END LOOP;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                              p_count => x_msg_count,
                              p_data => x_msg_data) ;

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(p_module_name    => g_module_name,
                                p_procedure_name => l_api_name);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (p_module_name    => g_module_name,
                                        p_procedure_name => l_api_name);
        ROLLBACK TO Duplicate_ShipHeaders_GRP;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                                  p_count   => x_msg_count,
                                  p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (p_module_name    => g_module_name,
                                          p_procedure_name => l_api_name);
       -- ROLLBACK TO Import_FromPO_GRP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_encoded  => FND_API.g_false,
                                  p_count    => x_msg_count,
                                  p_data     => x_msg_data);
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (p_module_name    => g_module_name,
                                          p_procedure_name => l_api_name);
        ROLLBACK TO Duplicate_ShipHeaders_GRP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(p_pkg_name       => g_pkg_name,
                                    p_procedure_name => l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                                  p_count   => x_msg_count,
                                  p_data    => x_msg_data);
END Duplicate_ShipHeaders;

-- API name   : Copy_Simulation
-- Type       : Group
-- Function   : Copy and duplicate a given simulation
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version   IN NUMBER
--              p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE
--              p_commit        IN VARCHAR2 := FND_API.G_FALSE
--              p_simulation_id IN  NUMBER
--
-- OUT        : x_return_status  OUT NOCOPY VARCHAR2
--              x_msg_count      OUT NOCOPY NUMBER
--              x_msg_data       OUT NOCOPY VARCHAR2
--
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Copy_Simulation (p_api_version   IN NUMBER,
                           p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
                           p_commit        IN VARCHAR2 := FND_API.G_FALSE,
                           p_simulation_id IN NUMBER,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_msg_count     OUT NOCOPY NUMBER,
                           x_msg_data      OUT NOCOPY VARCHAR2) IS

    l_api_name CONSTANT VARCHAR2(30) := 'Copy_Simulation';
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);
    l_api_version CONSTANT NUMBER := 1.0;
    l_debug_msg VARCHAR2(400);
    l_init_msg_list VARCHAR2(2000) := FND_API.G_FALSE;
    l_commit VARCHAR2(1) := FND_API.G_FALSE;

    l_version_num NUMBER;
    l_simulation_id NUMBER;
    l_simulation_rec simulation_rec;

    l_lock_name VARCHAR2(50) := 'SIMULATION_LOCK_' || p_simulation_id;
    l_lock_handle VARCHAR2(100);
    l_lock_status NUMBER;

BEGIN

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(p_module_name    => g_module_name,
                                  p_procedure_name => l_api_name) ;

    -- Standard Start of API savepoint
    SAVEPOINT Copy_Simulation_GRP;

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
                                   p_debug_info => 'Acquiring lock on: ' || l_lock_name);

    DBMS_LOCK.Allocate_Unique(lockname => l_lock_name,
                              lockhandle => l_lock_handle);

    l_lock_status := DBMS_LOCK.Request(lockhandle => l_lock_handle,
                                       lockmode => dbms_lock.x_mode);

    IF l_lock_status = 0 THEN -- Successfully locked
        INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                       p_procedure_name => l_api_name,
                                       p_debug_info => 'Get the next simulation version');

        SELECT MAX(a.version_num) + 1
          INTO l_version_num
          FROM inl_simulations a,
               inl_simulations b
         WHERE a.parent_table_name = b.parent_table_name
           AND a.parent_table_id = b.parent_table_id
           AND a.parent_table_revision_num = b.parent_table_revision_num
           AND b.simulation_id = p_simulation_id;

        INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                       p_procedure_name => l_api_name,
                                       p_debug_info => 'Get the next Simulation Id');

        -- Get Simulation Id nextval
        SELECT inl_simulations_s.NEXTVAL
          INTO l_simulation_id
          FROM dual;

        INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                       p_procedure_name => l_api_name,
                                       p_debug_info => 'Populate Simulation record to be used on INSERT');

        SELECT 'N',
               parent_table_name,
               parent_table_id,
               parent_table_revision_num,
               vendor_id,
               vendor_site_id,
               freight_code,
               org_id,
               attribute_category,
               attribute1,
               attribute2,
               attribute3,
               attribute4,
               attribute5,
               attribute6,
               attribute7,
               attribute8,
               attribute9,
               attribute10,
               attribute11,
               attribute12,
               attribute13,
               attribute14,
               attribute15
          INTO l_simulation_rec.firmed_flag,
               l_simulation_rec.parent_table_name,
               l_simulation_rec.parent_table_id,
               l_simulation_rec.parent_table_revision_num,
               l_simulation_rec.vendor_id,
               l_simulation_rec.vendor_site_id,
               l_simulation_rec.freight_code,
               l_simulation_rec.org_id,
               l_simulation_rec.attribute_category,
               l_simulation_rec.attribute1,
               l_simulation_rec.attribute2,
               l_simulation_rec.attribute3,
               l_simulation_rec.attribute4,
               l_simulation_rec.attribute5,
               l_simulation_rec.attribute6,
               l_simulation_rec.attribute7,
               l_simulation_rec.attribute8,
               l_simulation_rec.attribute9,
               l_simulation_rec.attribute10,
               l_simulation_rec.attribute11,
               l_simulation_rec.attribute12,
               l_simulation_rec.attribute13,
               l_simulation_rec.attribute14,
               l_simulation_rec.attribute15
          FROM inl_simulations
         WHERE simulation_id = p_simulation_id;

        INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                       p_procedure_name => l_api_name,
                                       p_debug_info => 'Insert into Simulation table a copy of the existing record');

        INSERT INTO inl_simulations (simulation_id,
                                     firmed_flag,
                                     parent_table_name,
                                     parent_table_id,
                                     parent_table_revision_num,
                                     version_num,
                                     vendor_id,
                                     vendor_site_id,
                                     freight_code,
                                     org_id,
                                     created_by,
                                     creation_date,
                                     last_updated_by,
                                     last_update_date,
                                     last_update_login,
                                     attribute_category,
                                     attribute1,
                                     attribute2,
                                     attribute3,
                                     attribute4,
                                     attribute5,
                                     attribute6,
                                     attribute7,
                                     attribute8,
                                     attribute9,
                                     attribute10,
                                     attribute11,
                                     attribute12,
                                     attribute13,
                                     attribute14,
                                     attribute15)
                             VALUES (l_simulation_id,
                                     l_simulation_rec.firmed_flag,
                                     l_simulation_rec.parent_table_name,
                                     l_simulation_rec.parent_table_id,
                                     l_simulation_rec.parent_table_revision_num,
                                     l_version_num,
                                     l_simulation_rec.vendor_id,
                                     l_simulation_rec.vendor_site_id,
                                     l_simulation_rec.freight_code,
                                     l_simulation_rec.org_id,
                                     fnd_global.user_id,
                                     SYSDATE,
                                     fnd_global.user_id,
                                     SYSDATE,
                                     fnd_global.login_id,
                                     l_simulation_rec.attribute_category,
                                     l_simulation_rec.attribute1,
                                     l_simulation_rec.attribute2,
                                     l_simulation_rec.attribute3,
                                     l_simulation_rec.attribute4,
                                     l_simulation_rec.attribute5,
                                     l_simulation_rec.attribute6,
                                     l_simulation_rec.attribute7,
                                     l_simulation_rec.attribute8,
                                     l_simulation_rec.attribute9,
                                     l_simulation_rec.attribute10,
                                     l_simulation_rec.attribute11,
                                     l_simulation_rec.attribute12,
                                     l_simulation_rec.attribute13,
                                     l_simulation_rec.attribute14,
                                     l_simulation_rec.attribute15);

        INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                       p_procedure_name => l_api_name,
                                       p_debug_info => 'Call Duplicate_ShipHeaders');

        Duplicate_ShipHeaders (p_api_version           => 1.0,
                               p_init_msg_list         => l_init_msg_list,
                               p_commit                => l_commit,
                               p_current_simulation_id => p_simulation_id,
                               p_new_simulation_id     => l_simulation_id,
                               x_return_status         => l_return_status,
                               x_msg_count             => l_msg_count,
                               x_msg_data              => l_msg_data);

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
    -- Any other problems in acquiring the lock,
    -- raise error and return
    ELSE
        FND_MESSAGE.set_name('INL', 'INL_SIMUL_COPY_LOCKED');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- Release the lock
    l_lock_status := DBMS_LOCK.Release(l_lock_handle);
    l_lock_handle := NULL;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                              p_count => x_msg_count,
                              p_data => x_msg_data) ;

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(p_module_name    => g_module_name,
                                p_procedure_name => l_api_name);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (p_module_name    => g_module_name,
                                        p_procedure_name => l_api_name);
        ROLLBACK TO Copy_Simulation_GRP;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                                  p_count   => x_msg_count,
                                  p_data    => x_msg_data);
        IF l_lock_handle IS NOT NULL THEN
            l_lock_status := DBMS_LOCK.Release(l_lock_handle);
        END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (p_module_name    => g_module_name,
                                          p_procedure_name => l_api_name);
       -- ROLLBACK TO Import_FromPO_GRP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_encoded  => FND_API.g_false,
                                  p_count    => x_msg_count,
                                  p_data     => x_msg_data);
        IF l_lock_handle IS NOT NULL THEN
            l_lock_status := DBMS_LOCK.Release(l_lock_handle);
        END IF;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (p_module_name    => g_module_name,
                                          p_procedure_name => l_api_name);
        ROLLBACK TO Copy_Simulation_GRP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(p_pkg_name       => g_pkg_name,
                                    p_procedure_name => l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                                  p_count   => x_msg_count,
                                  p_data    => x_msg_data);
        IF l_lock_handle IS NOT NULL THEN
            l_lock_status := DBMS_LOCK.Release(l_lock_handle);
        END IF;
END Copy_Simulation;

-- API name   : Create_Simulation
-- Type       : Group
-- Function   : Insert data on INL_SIMULATION table
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version IN NUMBER,
--              p_init_msg_listIN VARCHAR2 := FND_API.G_FALSE
--              p_commit IN VARCHAR2 := FND_API.G_FALSE
--              p_simulation_rec IN OUT NOCOPY simulation_table
--
-- OUT          x_return_status OUT NOCOPY VARCHAR2
--              x_msg_count OUT NOCOPY NUMBER,
--              x_msg_data OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Create_Simulation (p_api_version IN NUMBER,
                             p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
                             p_commit IN VARCHAR2 := FND_API.G_FALSE,
                             p_simulation_rec IN OUT NOCOPY simulation_rec,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_msg_count OUT NOCOPY NUMBER,
                             x_msg_data OUT NOCOPY VARCHAR2)IS

    l_api_name CONSTANT VARCHAR2(30) := 'Create_Simulation';
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);
    l_api_version CONSTANT NUMBER := 1.0;
    l_debug_msg VARCHAR2(400);

    l_lock_name VARCHAR2(50) := 'SIMULATION_LOCK_' ||
                                p_simulation_rec.parent_table_name || '_' ||
                                p_simulation_rec.parent_table_id || '_' ||
                                p_simulation_rec.parent_table_revision_num;
    l_lock_handle VARCHAR2(100);
    l_lock_status NUMBER;

    l_flexfield_ln_rec INL_CUSTOM_PUB.flexfield_ln_rec;
    l_attribute_category VARCHAR2(150);
    l_attribute1 VARCHAR2(150);
    l_attribute2 VARCHAR2(150);
    l_attribute3 VARCHAR2(150);
    l_attribute4 VARCHAR2(150);
    l_attribute5 VARCHAR2(150);
    l_attribute6 VARCHAR2(150);
    l_attribute7 VARCHAR2(150);
    l_attribute8 VARCHAR2(150);
    l_attribute9 VARCHAR2(150);
    l_attribute10 VARCHAR2(150);
    l_attribute11 VARCHAR2(150);
    l_attribute12 VARCHAR2(150);
    l_attribute13 VARCHAR2(150);
    l_attribute14 VARCHAR2(150);
    l_attribute15 VARCHAR2(150);

BEGIN

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(p_module_name    => g_module_name,
                                  p_procedure_name => l_api_name) ;

    -- Standard Start of API savepoint
    SAVEPOINT Create_Simulation_GRP;

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

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'p_simulation_rec.parent_table_name',
        p_var_value => p_simulation_rec.parent_table_name);

    INL_LOGGING_PVT.Log_Variable (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name => 'p_simulation_rec.parent_table_id',
        p_var_value => p_simulation_rec.parent_table_id);


    INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                   p_procedure_name => l_api_name,
                                   p_debug_info => 'Acquiring lock on: ' || l_lock_name);

    DBMS_LOCK.Allocate_Unique(lockname => l_lock_name,
                              lockhandle => l_lock_handle);

    l_lock_status := DBMS_LOCK.Request(lockhandle => l_lock_handle,
                                       lockmode => dbms_lock.x_mode);

    IF l_lock_status = 0 THEN -- Successfully locked

        SELECT NVL(MAX(sml.version_num),0) + 1
        INTO p_simulation_rec.version_num
        FROM inl_simulations sml
        WHERE sml.parent_table_name = p_simulation_rec.parent_table_name
        AND sml.parent_table_id = p_simulation_rec.parent_table_id
        AND parent_table_revision_num = p_simulation_rec.parent_table_revision_num;

        INL_LOGGING_PVT.Log_Variable (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_var_name => 'p_simulation_rec.version_num',
            p_var_value => p_simulation_rec.version_num );

        SELECT inl_simulations_s.NEXTVAL
        INTO p_simulation_rec.simulation_id
        FROM dual;

        INL_LOGGING_PVT.Log_Variable (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_var_name => 'p_simulation_rec.simulation_id',
            p_var_value => p_simulation_rec.simulation_id );

        l_debug_msg := 'Call INL_CUSTOM_PUB.Get_SimulFlexFields to get flexfield valeus from Hook';

        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_debug_info => l_debug_msg);

        -- Get flexfield values from hook
        INL_CUSTOM_PUB.Get_SimulFlexFields(
            p_parent_table_name => p_simulation_rec.parent_table_name,
            p_parent_table_id => p_simulation_rec.parent_table_id,
            p_parent_table_revision_num => p_simulation_rec.parent_table_revision_num,
            x_flexfield_ln_rec => l_flexfield_ln_rec,
            x_return_status => l_return_status);

        -- If any errors happen abort API.
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        l_attribute_category := l_flexfield_ln_rec.attribute_category;
        l_attribute1 := l_flexfield_ln_rec.attribute1;
        l_attribute2 := l_flexfield_ln_rec.attribute2;
        l_attribute3 := l_flexfield_ln_rec.attribute3;
        l_attribute4 := l_flexfield_ln_rec.attribute4;
        l_attribute5 := l_flexfield_ln_rec.attribute5;
        l_attribute6 := l_flexfield_ln_rec.attribute6;
        l_attribute7 := l_flexfield_ln_rec.attribute7;
        l_attribute8 := l_flexfield_ln_rec.attribute8;
        l_attribute9 := l_flexfield_ln_rec.attribute9;
        l_attribute10 := l_flexfield_ln_rec.attribute10;
        l_attribute11 := l_flexfield_ln_rec.attribute11;
        l_attribute12 := l_flexfield_ln_rec.attribute12;
        l_attribute13 := l_flexfield_ln_rec.attribute13;
        l_attribute14 := l_flexfield_ln_rec.attribute14;
        l_attribute15 := l_flexfield_ln_rec.attribute15;

        l_debug_msg := 'Inserting data into inl_simulations table';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_debug_info => l_debug_msg);

        INSERT INTO inl_simulations sml
                             (sml.simulation_id,             -- 01
                              sml.firmed_flag,               -- 02
                              sml.parent_table_name,         -- 03
                              sml.parent_table_id,           -- 04
                              sml.parent_table_revision_num, -- 05
                              sml.version_num,               -- 06
                              sml.vendor_id,                 -- 09
                              sml.vendor_site_id,            -- 10
                              sml.freight_code,              -- 11
                              sml.org_id,                    -- 12
                              created_by,                    -- 13
                              creation_date,                 -- 14
                              last_updated_by,               -- 15
                              last_update_date,              -- 16
                              attribute_category,            -- 17
                              attribute1,                    -- 18
                              attribute2,                    -- 19
                              attribute3,                    -- 20
                              attribute4,                    -- 21
                              attribute5,                    -- 22
                              attribute6,                    -- 23
                              attribute7,                    -- 24
                              attribute8,                    -- 25
                              attribute9,                    -- 25
                              attribute10,                   -- 27
                              attribute11,                   -- 28
                              attribute12,                   -- 29
                              attribute13,                   -- 30
                              attribute14,                   -- 31
                              attribute15)                   -- 32
                    VALUES
                         (p_simulation_rec.simulation_id,             -- 01
                          p_simulation_rec.firmed_flag,               -- 02
                          p_simulation_rec.parent_table_name,         -- 03
                          p_simulation_rec.parent_table_id,           -- 04
                          p_simulation_rec.parent_table_revision_num, -- 05
                          p_simulation_rec.version_num,               -- 06
                          p_simulation_rec.vendor_id,                 -- 09
                          p_simulation_rec.vendor_site_id,            -- 10
                          p_simulation_rec.freight_code,              -- 11
                          p_simulation_rec.org_id,                    -- 12
                          fnd_global.user_id,                         -- 13
                          SYSDATE,                                    -- 14
                          fnd_global.user_id,                         -- 15
                          SYSDATE,                                    -- 16
                          l_attribute_category,                       -- 17
                          l_attribute1,                               -- 18
                          l_attribute2,                               -- 19
                          l_attribute3,                               -- 20
                          l_attribute4,                               -- 21
                          l_attribute5,                               -- 22
                          l_attribute6,                               -- 23
                          l_attribute7,                               -- 24
                          l_attribute8,                               -- 25
                          l_attribute9,                               -- 26
                          l_attribute10,                              -- 27
                          l_attribute11,                              -- 28
                          l_attribute12,                              -- 29
                          l_attribute13,                              -- 30
                          l_attribute14,                              -- 31
                          l_attribute15);                             -- 32

        -- Standard check of p_commit.
        IF FND_API.To_Boolean(p_commit) THEN
            COMMIT WORK;
        END IF;
        -- Any other problems in acquiring the lock,
        -- raise error and return
    ELSE
        FND_MESSAGE.set_name('INL', 'INL_SIMUL_CREATE_LOCKED');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- Release the lock
    l_lock_status := DBMS_LOCK.Release(l_lock_handle);
    l_lock_handle := NULL;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                              p_count => x_msg_count,
                              p_data => x_msg_data) ;

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(p_module_name    => g_module_name,
                                p_procedure_name => l_api_name);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (p_module_name    => g_module_name,
                                        p_procedure_name => l_api_name);
        ROLLBACK TO Create_Simulation_GRP;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                                  p_count   => x_msg_count,
                                  p_data    => x_msg_data);
        IF l_lock_handle IS NOT NULL THEN
            l_lock_status := DBMS_LOCK.Release(l_lock_handle);
        END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (p_module_name    => g_module_name,
                                          p_procedure_name => l_api_name);
        ROLLBACK TO Create_Simulation_GRP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_encoded  => FND_API.g_false,
                                  p_count    => x_msg_count,
                                  p_data     => x_msg_data);
        IF l_lock_handle IS NOT NULL THEN
            l_lock_status := DBMS_LOCK.Release(l_lock_handle);
        END IF;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (p_module_name    => g_module_name,
                                          p_procedure_name => l_api_name);
        ROLLBACK TO Create_Simulation_GRP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(p_pkg_name       => g_pkg_name,
                                    p_procedure_name => l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                                  p_count   => x_msg_count,
                                  p_data    => x_msg_data);
        IF l_lock_handle IS NOT NULL THEN
            l_lock_status := DBMS_LOCK.Release(l_lock_handle);
        END IF;
END Create_Simulation;

-- API name   : Purge_Simulations
-- Type       : Group
-- Function   : Purge simulations and its Shipments
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version IN NUMBER
--              p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE
--              p_commit IN VARCHAR2 := FND_API.G_FALSE
--              p_org_id IN NUMBER
--              p_simulation_table simulation_id_tbl
--
-- OUT        : x_return_status OUT NOCOPY VARCHAR2
--              x_msg_count OUT NOCOPY NUMBER
--              x_msg_data OUT NOCOPY VARCHAR2
--
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Purge_Simulations(p_api_version IN NUMBER,
                            p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
                            p_commit IN VARCHAR2 := FND_API.G_FALSE,
                            p_org_id IN NUMBER,
                            p_simulation_table IN simulation_id_tbl,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count OUT NOCOPY NUMBER,
                            x_msg_data OUT NOCOPY VARCHAR2) IS

    CURSOR c_simul IS
        SELECT simulation_id
        FROM inl_simulations s
        WHERE org_id = p_org_id
        ORDER BY s.parent_table_name,
                 s.parent_table_id,
                 s.parent_table_revision_num,
                 s.version_num;

    TYPE c_simul_tp IS TABLE OF c_simul%ROWTYPE;
    c_simul_tbl c_simul_tp;

    CURSOR c_ship_hdr(p_simulation_id NUMBER) IS
        SELECT sh.ship_header_id
        FROM inl_ship_headers sh
        WHERE sh.simulation_id = p_simulation_id;

    TYPE c_ship_hdr_tp IS TABLE OF c_ship_hdr%ROWTYPE;
    c_ship_hdr_tbl c_ship_hdr_tp;

    l_api_name CONSTANT VARCHAR2(30) := 'Purge_Simulations';
    l_return_status VARCHAR2(1);
    l_api_version CONSTANT NUMBER := 1.0;
    l_check_simul_tbl BOOLEAN := FALSE;
    l_remove_simulated BOOLEAN := FALSE;
BEGIN

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(p_module_name => g_module_name,
                                  p_procedure_name => l_api_name) ;

    -- Standard Start of API savepoint
    SAVEPOINT Purge_SimulShipments_GRP;

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

    OPEN c_simul;
    FETCH c_simul BULK COLLECT INTO c_simul_tbl;
    CLOSE c_simul;

    IF p_simulation_table.COUNT <> 0 THEN
        l_check_simul_tbl := TRUE;

        INL_LOGGING_PVT.Log_Statement(p_module_name => g_module_name,
                                      p_procedure_name => l_api_name,
                                      p_debug_info => 'Remove Simulations stored in p_simulation_table');
    END IF;

    FOR i IN 1..c_simul_tbl.COUNT
    LOOP
        INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                      p_procedure_name => l_api_name,
                                      p_var_name => 'c_simul_tbl(i).simulation_id',
                                      p_var_value => c_simul_tbl(i).simulation_id);

        IF l_check_simul_tbl THEN
            l_remove_simulated := FALSE;
            FOR j IN 1..p_simulation_table.COUNT
            LOOP
                IF c_simul_tbl(i).simulation_id = p_simulation_table(j) THEN
                    l_remove_simulated := TRUE;
                    EXIT;
                END IF;
            END LOOP;
        END IF;

        IF NOT l_check_simul_tbl OR (l_check_simul_tbl AND l_remove_simulated) THEN
            INL_LOGGING_PVT.Log_Statement(p_module_name => g_module_name,
                                          p_procedure_name => l_api_name,
                                          p_debug_info => 'Removing simulation: ' || c_simul_tbl(i).simulation_id);

            OPEN c_ship_hdr(c_simul_tbl(i).simulation_id);
            FETCH c_ship_hdr BULK COLLECT INTO c_ship_hdr_tbl;
            CLOSE c_ship_hdr;

            FOR j IN 1..c_ship_hdr_tbl.COUNT
            LOOP
                INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                              p_procedure_name => l_api_name,
                                              p_var_name => 'c_ship_hdr_tbl(j).ship_header_id',
                                              p_var_value => c_ship_hdr_tbl(j).ship_header_id);

                INL_INTERFACE_PVT.Delete_Ship(p_ship_header_id => c_ship_hdr_tbl(j).ship_header_id,
                                              x_return_status => l_return_status);

                -- If any errors happen abort the process.
                IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
            END LOOP;

            DELETE FROM inl_simulations s
            WHERE s.simulation_id = c_simul_tbl(i).simulation_id;
        END IF;
    END LOOP;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                              p_count => x_msg_count,
                              p_data => x_msg_data) ;

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(p_module_name => g_module_name,
                                p_procedure_name => l_api_name);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (p_module_name => g_module_name,
                                        p_procedure_name => l_api_name);
        ROLLBACK TO Purge_SimulShipments_GRP;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                                  p_count => x_msg_count,
                                  p_data => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (p_module_name => g_module_name,
                                          p_procedure_name => l_api_name);
        ROLLBACK TO Purge_SimulShipments_GRP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                                  p_count => x_msg_count,
                                  p_data => x_msg_data);
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (p_module_name => g_module_name,
                                          p_procedure_name => l_api_name);
        ROLLBACK TO Purge_SimulShipments_GRP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(p_pkg_name       => g_pkg_name,
                                    p_procedure_name => l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                                  p_count => x_msg_count,
                                  p_data => x_msg_data);
END Purge_Simulations;

END INL_SIMULATION_PVT;

/
